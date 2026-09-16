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
         spellGrantsFor, psionicGrantsFor, talentGrantsFor, spellTraditionsAllowed,
         spellTraditionAllowed } from './leveling.js';

export async function listPendingPowers(env, characterId) {
  // No catch here. An earlier version swallowed failures into an empty list to
  // tolerate a database without the table, and what it actually swallowed was a
  // query naming a column that did not exist - the sheet showed no banked
  // powers and nothing said why. A missing migration is a prerequisite, and it
  // should fail loudly like every other one.
  const { results } = await env.DB.prepare(
    `SELECT id, granted_at_level, slot, count, kind, spell_levels, spell_traditions, categories,
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
    // NULL for a row banked before migration 055: unrestricted, the reach it was
    // granted with. See spellTraditionAllowed in js/leveling.js.
    traditions: r.spell_traditions ? safeParse(r.spell_traditions) : null,
    categories: r.categories ? safeParse(r.categories) : null,
    from: r.from_names ? safeParse(r.from_names) : null,
    note: r.note ?? null,
  }));
}

export function insertPowerGrantStatements(env, characterId, grants) {
  return grants.map((g) => env.DB.prepare(
    `INSERT INTO pending_power_picks
       (character_id, granted_at_level, slot, count, kind, spell_levels, spell_traditions, categories, from_names, note)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  ).bind(characterId, g.level, g.slot ?? 0, g.count, g.kind,
    g.spell_levels ? JSON.stringify(g.spell_levels) : null,
    g.kind === 'spell' && Array.isArray(g.traditions) ? JSON.stringify(g.traditions) : null,
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
                 // Frozen with the grant, like its level cap: BOOK-INGEST-AUDIT F57.
                 traditions: spellTraditionsAllowed(cls),
                 categories: null,
                 from: spellNamesForGrant(cls, g.level, g.slot),
                 note: grantNote(cls, 'spell', g.level, g.slot) });
    }
  }
  const psionics = psionicGrantsFor(cls, fromLevel, toLevel);
  if (psionics.applicable && !psionics.unknown) {
    for (const g of psionics.grants) {
      // A named list on the entry rides onto the grant and REPLACES its
      // categories, as a starting group's does in startingGroups: the list is
      // the restriction, and the Healing Shaman's eight listed Super powers sit
      // under a class gate with no Super in it. BOOK-INGEST-AUDIT F65 - this
      // wrote `from: null` over the list, so the claim check, the validator and
      // the sheet saw only the gate, which refused every listed power.
      const from = Array.isArray(g.from) && g.from.length ? g.from.map(String) : null;
      out.push({ ...g, kind: 'psionic', spell_levels: null, traditions: null,
                 categories: from ? null : psionicCategoriesForGrant(cls, g.level, g.slot),
                 from,
                 note: grantNote(cls, 'psionic', g.level, g.slot) });
    }
  }
  // Nightbane Talents. EVERY RESTRICTION COLUMN IS NULL, and that is the shape
  // rather than an omission: the book's free Talents arrive ungated - "one
  // additional free ability at levels four, seven, ten and twelve", printed
  // 106 - and what limits the pick is the catalog row's own
  // `min_character_level` and `prerequisite`, checked in resolvePowerPicks
  // when it is spent. A named list on the entry still rides along, because a
  // class MAY hand out a specific Talent and that is a real restriction.
  const talents = talentGrantsFor(cls, fromLevel, toLevel);
  if (talents.applicable && !talents.unknown) {
    for (const g of talents.grants) {
      const from = Array.isArray(g.from) && g.from.length ? g.from.map(String) : null;
      out.push({ ...g, kind: 'talent', spell_levels: null, traditions: null,
                 categories: null, from,
                 note: grantNote(cls, 'talent', g.level, g.slot) });
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
  const spent = new Map();
  // `spent` is returned alongside the powers: how many picks were taken from each
  // grant, keyed `kind:level:slot` exactly the way a banked row and
  // remainingPowerGrants key one. See the note at the return below.
  if (!Array.isArray(picks) || !picks.length) return { powers: [], errors, spent: new Map() };

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
  const tradFor = new Map(grants.map((g) => [key(g.kind, g.level, g.slot), g.traditions]));

  const names = [...new Set(picks.map((p) => String(p?.name || '').trim()).filter(Boolean))];
  const catalog = await loadPowerCatalog(env, names, system);

  for (const pick of picks) {
    const name = String(pick?.name || '').trim();
    // THREE-WAY, and it used to be two. The old line read
    // `pick?.kind === 'psionic' ? 'psionic' : 'spell'`, which coerces anything
    // unrecognised to a spell - so a talent pick would have been looked up in
    // the spell catalog and refused as "not in the spell catalog", naming the
    // wrong catalog for a row that exists.
    const kind = pick?.kind === 'psionic' ? 'psionic'
      : pick?.kind === 'talent' ? 'talent' : 'spell';
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
    // first. Its entry may also carry a level cap (BOOK-INGEST-AUDIT F61), and
    // the cap test below runs for a list grant too - which this path always
    // did, being the one reader that never dropped the cap beside a list.
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
      // Refused here because the picker no longer offers it - one rule, both
      // sides (BOOK-INGEST-AUDIT F57). A named list already decided above.
      if (!list && !spellTraditionAllowed(row, tradFor.get(k))) {
        errors.push(`${name} is ${row.tradition} magic; the level ${level} grant does not draw from that tradition`);
        continue;
      }
    } else if (kind === 'talent') {
      // THE ONLY MECHANICAL GATE ON A TALENT, and it lives on the ROW rather
      // than on the grant: the book's free Talents arrive ungated and it is the
      // Talent itself that says "Not available until the character has reached
      // fifth level". Ten of the core book's 25 say so.
      //
      // Compared against the level the GRANT is from, which is the level the
      // character reaches - so a level-4 grant cannot buy a fifth-level Talent
      // and a level-7 grant can.
      if (Number.isFinite(row.min_character_level) && level < row.min_character_level) {
        errors.push(`${name} is not available until level ${row.min_character_level}; `
          + `this grant is from level ${level}`);
        continue;
      }
      // `prerequisite` IS DELIBERATELY NOT ENFORCED. It is free text holding two
      // unlike things - a Morphus characteristic ("At least one biomechanical
      // characteristic") on four of the five that have one, and another TALENT
      // on the fifth, Mirror Search requiring Mirror Sight. Matching the second
      // by name would be a rule that reads prose, which is the shape
      // BOOK-INGEST-AUDIT F4 records missing one of three language picks; and
      // nothing can check the first at all, because a Morphus is not modelled.
      // So it travels to the sheet and the table decides, which is what the
      // `note` column on a banked grant exists to do for the same reason.
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
    spent.set(k, (spent.get(k) || 0) + 1);
    held.add(name.toLowerCase());
    // A TALENT CARRIES BOTH COSTS, which is the whole reason it has its own
    // table: `cost` is what an activation spends, the same field a spell and a
    // psionic power use so the sheet renders all three alike, and
    // `acquire_cost` is the permanent expenditure that bought it. Dropping the
    // second here would lose the number migration 063 was written for.
    chosen.push(kind === 'spell'
      ? { type: 'spell', name: row.name, level: row.level, cost: row.ppe,
          ...(row.ppe_note ? { cost_note: row.ppe_note } : {}), gained_at_level: level, slot }
      : kind === 'talent'
      ? { type: 'talent', name: row.name, tier: row.tier, cost: row.ppe,
          acquire_cost: row.acquire_ppe,
          ...(row.ppe_note ? { cost_note: row.ppe_note } : {}),
          ...(row.form_required ? { form_required: row.form_required } : {}),
          ...(row.prerequisite ? { prerequisite: row.prerequisite } : {}),
          gained_at_level: level, slot }
      : { type: 'psionic', name: row.name, category: row.category, cost: row.isp,
          ...(row.isp_note ? { cost_note: row.isp_note } : {}), gained_at_level: level, slot });
  }

  // THE KEY OF WHAT WAS CONSUMED TRAVELS OUT OF HERE, and the callers no longer
  // rebuild it.
  //
  // They used to. level-confirm.js and characters/[id]/power-picks.js each built
  // `${p.type === 'psionic' ? 'psionic' : 'spell'}:level:slot` from the returned
  // power - a two-way guess at a three-way answer. A spent TALENT was keyed
  // `spell`, matched no `talent` row, and so: at level-up the Talent was taken
  // AND its grant banked again in full, and in the spend endpoint a banked Talent
  // row was never consumed and could be spent over and over. Both reproduced
  // through the real remainingPowerGrants before this was changed.
  //
  // Rebuilding the key from the power's TYPE was the defect, not the mapping: a
  // purchased Talent's grant is a different kind from the power it yields, so no
  // mapping from type could stay right. This loop already holds the true key.
  return { powers: chosen, errors, spent };
}

// Only the rows actually named, rather than both catalogs whole: a level-up
// picks two or three, and the spell table is thousands of rows.
//
// Exported for the creation-time validator, which loads with `system` null and
// filters per character instead — the audit validates characters from several
// campaigns against one load. Rows keep their `system` column either way.
export async function loadPowerCatalog(env, names, system) {
  const empty = { spell: new Map(), psionic: new Map(), super: new Map(), talent: new Map() };
  if (!names.length) return empty;
  // Chunked: D1 binds at most 100 parameters per statement, and a high-level
  // caster holds more than a hundred spells - which is exactly the character
  // this function exists to load.
  const spells = [];
  const psionics = [];
  const supers = [];
  const talents = [];
  for (const batch of chunks(names)) {
    const placeholders = batch.map(() => '?').join(', ');
    // NO `description` on the super-ability row, for the reason the block
    // comment above gives about the other two: the descriptions are 994KB
    // across 364 rows and the validator needs a name and a tier.
    const [s, p, a, t] = await env.DB.batch([
      env.DB.prepare(
        `SELECT name, level, ppe, ppe_note, system, tradition FROM spells WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
      env.DB.prepare(
        `SELECT name, category, isp, isp_note, system FROM psionic_powers WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
      env.DB.prepare(
        `SELECT name, tier, system FROM super_abilities WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
      // BOTH costs and the level gate, which is what separates a Talent from
      // everything above it. `min_character_level` is enforced below;
      // `prerequisite` is carried so the sheet can show it and is NOT
      // enforced - see the note in resolvePowerPicks.
      env.DB.prepare(
        `SELECT name, tier, acquire_ppe, ppe, ppe_note, min_character_level,
                form_required, prerequisite, system
           FROM talents WHERE name COLLATE NOCASE IN (${placeholders})`
      ).bind(...batch),
    ]);
    if (s.results?.length) spells.push(...s.results);
    if (p.results?.length) psionics.push(...p.results);
    if (a.results?.length) supers.push(...a.results);
    if (t.results?.length) talents.push(...t.results);
  }
  // A NULL system is unrestricted, which is how every picker already reads it.
  const keep = (r) => !system || !r.system || r.system === system;
  for (const r of spells.filter(keep)) empty.spell.set(r.name.toLowerCase(), r);
  for (const r of psionics.filter(keep)) empty.psionic.set(r.name.toLowerCase(), r);
  for (const r of supers.filter(keep)) empty.super.set(r.name.toLowerCase(), r);
  for (const r of talents.filter(keep)) empty.talent.set(r.name.toLowerCase(), r);
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
  // A MAP RATHER THAN A TERNARY. "psionic, else spells" sent every unrecognised
  // type to the spell table, so a super ability would have been looked up where
  // it cannot be and its description silently dropped - and a description that
  // is merely absent is indistinguishable from a catalog row that has none.
  //
  // And then it did the same to a TALENT, which the map did not name when
  // BOOK-INGEST-AUDIT F76 added the kind: a Talent's description was looked up in
  // `spells`, found nothing, and the sheet showed none.
  const CATALOG_OF = { psionic: 'psionics', super: 'superAbilities', spell: 'spells', talent: 'talents' };
  for (const p of list) {
    const name = String(p?.name ?? '').trim();
    if (name) wanted.set(name.toLowerCase(), CATALOG_OF[p?.type] || 'spells');
  }

  for (const [catalogKey, table] of [['spells', 'spells'], ['psionics', 'psionic_powers'],
                                     ['superAbilities', 'super_abilities'], ['talents', 'talents']]) {
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
