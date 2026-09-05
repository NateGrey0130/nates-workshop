// Spending the spells and psionic powers a level-up granted.
//
// `skill-picks.js` with a different subject. A grant is banked in
// `pending_power_picks` the moment a level-up commits, and spent either in the
// same request or whenever the player comes back — the two paths share
// everything here so they cannot drift.
//
// The rule that makes this more than a copy: a SPELL grant carries the spell
// levels it may draw from, and that cap belongs to the level that earned it.
// A Ley Line Walker's two spells at level 2 are capped at spell level 2 even
// though its starting twelve came from levels 1-4. See
// `spellLevelsForGrant` in js/leveling.js.

import { json } from './auth.js';
import { chunks, selectInChunks } from './sql-chunk.js';
import { resolveKeys } from './catalog-redirects.js';
import { safeParse } from './character-json.js';
import { categoryAllows, categoryLabel } from '../../../../apps/character-creator/js/parser.js';
import { spellLevelsForGrant, psionicCategoriesForGrant, spellNamesForGrant, grantNote,
         spellGrantsFor, psionicGrantsFor } from './leveling.js';

export async function listPendingPowers(env, characterId) {
  // No catch here. An earlier version swallowed failures into an empty list to
  // tolerate a database without the table, and what it actually swallowed was a
  // query naming a column that did not exist - the sheet showed no banked
  // powers and nothing said why. A missing migration is a prerequisite, and it
  // should fail loudly like every other one.
  const { results } = await env.DB.prepare(
    `SELECT id, granted_at_level, slot, count, kind, spell_levels, categories,
            from_names, note, created_at
     FROM pending_power_picks
     WHERE character_id = ? AND claimed_at IS NULL
     ORDER BY granted_at_level, slot, id`
  ).bind(characterId).all();
  return (results || []).map((r) => ({
    id: r.id,
    granted_at_level: r.granted_at_level,
    count: r.count,
    kind: r.kind,
    slot: r.slot ?? 0,
    spell_levels: r.spell_levels ? safeParse(r.spell_levels) : null,
    categories: r.categories ? safeParse(r.categories) : null,
    from: r.from_names ? safeParse(r.from_names) : null,
    note: r.note ?? null,
  }));
}

export function insertPowerGrantStatements(env, characterId, grants) {
  return grants.map((g) => env.DB.prepare(
    `INSERT INTO pending_power_picks
       (character_id, granted_at_level, slot, count, kind, spell_levels, categories, from_names, note)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
  ).bind(characterId, g.level, g.slot ?? 0, g.count, g.kind,
    g.spell_levels ? JSON.stringify(g.spell_levels) : null,
    g.categories ? JSON.stringify(g.categories) : null,
    g.from ? JSON.stringify(g.from) : null,
    g.note ?? null));
}

// What a span of levels earns, in the shape this file banks and spends.
//
// The cap is resolved HERE rather than at spend time, because it depends on the
// level that earned the grant and that is the only moment both facts are in
// hand.
export function powerGrantsFor(cls, fromLevel, toLevel) {
  const out = [];
  const spells = spellGrantsFor(cls, fromLevel, toLevel);
  if (spells.applicable && !spells.unknown) {
    for (const g of spells.grants) {
      out.push({ ...g, kind: 'spell',
                 spell_levels: spellLevelsForGrant(cls, g.level, g.slot),
                 categories: null,
                 from: spellNamesForGrant(cls, g.level, g.slot),
                 note: grantNote(cls, 'spell', g.level, g.slot) });
    }
  }
  const psionics = psionicGrantsFor(cls, fromLevel, toLevel);
  if (psionics.applicable && !psionics.unknown) {
    for (const g of psionics.grants) {
      out.push({ ...g, kind: 'psionic', spell_levels: null,
                 categories: psionicCategoriesForGrant(cls, g.level, g.slot),
                 from: null,
                 note: grantNote(cls, 'psionic', g.level, g.slot) });
    }
  }
  return out;
}

// Turn requested picks into power entries, or explain why not.
//
// `picks` is [{ kind, name, granted_at_level }]. Every one is checked against
// the grant it claims: that such a grant exists, that it has room, and — for a
// spell — that the spell's level is inside the cap that grant carries. The cap
// is ENFORCED rather than advised, the same way a psychic tier is: a spell's
// level is a mechanical rule, not a table judgement.
export async function resolvePowerPicks(env, { picks, grants, existingPowers, system }) {
  const errors = [];
  const chosen = [];
  if (!Array.isArray(picks) || !picks.length) return { powers: [], errors };

  const held = new Set((existingPowers || [])
    .map((p) => String(p?.name || '').toLowerCase()).filter(Boolean));

  // Remaining room per grant, keyed by kind, level AND SLOT. Several grants can
  // share a level with different restrictions — a Shifter's three spells at
  // level 2 come from three different places — so the level alone no longer
  // identifies one.
  const key = (kind, level, slot) => `${kind}:${level}:${slot ?? 0}`;
  const room = new Map();
  for (const g of grants) {
    const k = key(g.kind, g.level, g.slot);
    room.set(k, (room.get(k) || 0) + g.count);
  }
  const capFor = new Map(grants.map((g) => [key(g.kind, g.level, g.slot), g.spell_levels]));
  const catFor = new Map(grants.map((g) => [key(g.kind, g.level, g.slot), g.categories]));
  const fromFor = new Map(grants.map((g) => [key(g.kind, g.level, g.slot), g.from]));

  const names = [...new Set(picks.map((p) => String(p?.name || '').trim()).filter(Boolean))];
  const catalog = await loadPowerCatalog(env, names, system);

  for (const pick of picks) {
    const name = String(pick?.name || '').trim();
    const kind = pick?.kind === 'psionic' ? 'psionic' : 'spell';
    const level = Number(pick?.granted_at_level);
    const slot = Number.isFinite(Number(pick?.slot)) ? Number(pick.slot) : 0;
    if (!name) { errors.push('A pick has no name'); continue; }

    const k = key(kind, level, slot);
    if (!room.has(k)) {
      errors.push(`${name}: this character has no ${kind} grant from level ${level}`);
      continue;
    }
    if (room.get(k) <= 0) {
      errors.push(`${name}: the level ${level} ${kind} grant is already full`);
      continue;
    }
    if (held.has(name.toLowerCase())) {
      errors.push(`${name} is already known — a power is learned once`);
      continue;
    }
    const row = catalog[kind].get(name.toLowerCase());
    if (!row) {
      errors.push(`${name} is not in the ${kind} catalog`);
      continue;
    }
    // A named list is the tightest restriction there is, so it is checked
    // first: a grant that names its spells is not also asking about levels.
    const list = fromFor.get(k);
    if (list && !list.some((n) => n.toLowerCase() === name.toLowerCase())) {
      errors.push(`${name} is not on the list the level ${level} grant draws from`);
      continue;
    }
    if (kind === 'spell') {
      const cap = capFor.get(k);
      if (cap && !cap.includes(row.level)) {
        errors.push(
          `${name} is a level ${row.level} spell; the level ${level} grant allows ${cap.join(', ')}`);
        continue;
      }
    } else {
      // A psionic grant may name its own categories, and when it does they
      // REPLACE the class's rather than narrowing them - a Mystic's level-4
      // power comes from Super, which its starting powers could not.
      const cats = catFor.get(k);
      // categoryAllows rather than a plain includes: since F16 an entry may
      // narrow itself with `only` / `except`, and the server has to refuse what
      // the picker would not offer. One function, three call sites - the wizard
      // twice and here - so they cannot disagree about what is legal.
      if (cats && cats.length && !categoryAllows(cats, row)) {
        errors.push(
          `${name} is a ${row.category || 'uncategorised'} power; the level ${level} grant allows `
          + cats.map(categoryLabel).join(', '));
        continue;
      }
    }

    room.set(k, room.get(k) - 1);
    held.add(name.toLowerCase());
    chosen.push(kind === 'spell'
      ? { type: 'spell', name: row.name, level: row.level, cost: row.ppe,
          ...(row.ppe_note ? { cost_note: row.ppe_note } : {}), gained_at_level: level, slot }
      : { type: 'psionic', name: row.name, category: row.category, cost: row.isp,
          ...(row.isp_note ? { cost_note: row.isp_note } : {}), gained_at_level: level, slot });
  }

  return { powers: chosen, errors };
}

// Only the rows actually named, rather than both catalogs whole: a level-up
// picks two or three, and the spell table is thousands of rows.
//
// Exported for the creation-time validator, which loads with `system` null and
// filters per character instead — the audit validates characters from several
// campaigns against one load. Rows keep their `system` column either way.
export async function loadPowerCatalog(env, names, system) {
  const empty = { spell: new Map(), psionic: new Map() };
  if (!names.length) return empty;
  // Chunked: D1 binds at most 100 parameters per statement, and a high-level
  // caster holds more than a hundred spells - which is exactly the character
  // this function exists to load.
  const spells = [];
  const psionics = [];
  for (const batch of chunks(names)) {
    const placeholders = batch.map(() => '?').join(', ');
    const [s, p] = await env.DB.batch([
      env.DB.prepare(
        `SELECT name, level, ppe, ppe_note, system FROM spells WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
      env.DB.prepare(
        `SELECT name, category, isp, isp_note, system FROM psionic_powers WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
    ]);
    if (s.results?.length) spells.push(...s.results);
    if (p.results?.length) psionics.push(...p.results);
  }
  // A NULL system is unrestricted, which is how every picker already reads it.
  const keep = (r) => !system || !r.system || r.system === system;
  for (const r of spells.filter(keep)) empty.spell.set(r.name.toLowerCase(), r);
  for (const r of psionics.filter(keep)) empty.psionic.set(r.name.toLowerCase(), r);
  return empty;
}

// The description text for the powers a character ALREADY HOLDS, so the sheet
// can render it inline without a second request at the table.
//
// This travels with the character rather than with the catalog, and that is the
// whole design: the two catalogs' description text is 74.5KB gzipped and would
// ride on every wizard boot and every sheet load, where the heaviest character
// on production needs 4.4KB of it. Measured in
// `docs/plans/20-power-descriptions.md`, which is also where the rejected
// options are recorded.
//
// Keyed by the LOWERCASED NAME THE CHARACTER HOLDS, not by the catalog row's
// name, because those two come apart: a stored power is a name-keyed snapshot,
// and `catalog_redirects` exists because merges and renames retire the key it
// snapshotted. Resolving through redirects is what class citations already do;
// without it a renamed spell quietly loses its text and nothing says why.
export async function loadPowerDescriptions(env, powers) {
  const out = {};
  const list = Array.isArray(powers) ? powers : [];
  if (!list.length) return out;

  // Which catalog each held name belongs to. A duplicate name across two
  // characters' powers is one lookup, not two.
  const wanted = new Map();
  for (const p of list) {
    const name = String(p?.name ?? '').trim();
    if (name) wanted.set(name.toLowerCase(), p?.type === 'psionic' ? 'psionics' : 'spells');
  }

  for (const [catalogKey, table] of [['spells', 'spells'], ['psionics', 'psionic_powers']]) {
    const names = [...wanted].filter(([, k]) => k === catalogKey).map(([n]) => n);
    if (!names.length) continue;

    // NOCASE, matching how loadPowerCatalog reads the same names.
    const rows = await selectInChunks(names, (chunk) => env.DB.prepare(
      `SELECT name, description FROM ${table}
       WHERE name COLLATE NOCASE IN (${chunk.map(() => '?').join(', ')})`
    ).bind(...chunk));
    for (const r of rows) {
      if (r.description) out[String(r.name).toLowerCase()] = r.description;
    }

    // Anything still unmatched may be a key that was retired under the
    // character's feet. Ask where it went.
    const missing = names.filter((n) => !(n in out));
    if (!missing.length) continue;
    const targets = await resolveKeys(env, catalogKey, missing);
    if (!targets.size) continue;

    const moved = await selectInChunks([...new Set(targets.values())], (chunk) => env.DB.prepare(
      `SELECT id, description FROM ${table} WHERE id IN (${chunk.map(() => '?').join(', ')})`
    ).bind(...chunk));
    const byId = new Map(moved.map((r) => [r.id, r.description]));
    for (const [heldName, id] of targets) {
      const text = byId.get(id);
      // Filed under the name the character holds, so the sheet can look it up
      // with the string it already has in hand.
      if (text) out[heldName] = text;
    }
  }
  return out;
}

// What is left of a set of grants after some were spent, consuming from the
// earliest first — the same rule `remainingGrants` applies to skill picks, and
// for the same reason: taking whole grants keeps the right total and attributes
// it to the wrong level.
export function remainingPowerGrants(grants, spentByKey) {
  const remaining = [];
  const left = new Map(spentByKey);
  for (const g of grants) {
    const key = `${g.kind}:${g.level}:${g.slot ?? 0}`;
    const spent = Math.min(g.count, left.get(key) || 0);
    left.set(key, (left.get(key) || 0) - spent);
    const rest = g.count - spent;
    if (rest > 0) remaining.push({ ...g, count: rest });
  }
  return remaining;
}

export function powerPickErrors(errors) {
  return json({ error: 'Those power picks are not allowed', errors }, 422);
}
