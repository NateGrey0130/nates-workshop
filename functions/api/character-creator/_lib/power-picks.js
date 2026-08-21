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
import { safeParse } from './character-json.js';
import { spellLevelsForGrant, psionicCategoriesForGrant,
         spellGrantsFor, psionicGrantsFor } from './leveling.js';

export async function listPendingPowers(env, characterId) {
  // No catch here. An earlier version swallowed failures into an empty list to
  // tolerate a database without the table, and what it actually swallowed was a
  // query naming a column that did not exist - the sheet showed no banked
  // powers and nothing said why. A missing migration is a prerequisite, and it
  // should fail loudly like every other one.
  const { results } = await env.DB.prepare(
    `SELECT id, granted_at_level, count, kind, spell_levels, categories, created_at
     FROM pending_power_picks
     WHERE character_id = ? AND claimed_at IS NULL
     ORDER BY granted_at_level, id`
  ).bind(characterId).all();
  return (results || []).map((r) => ({
    id: r.id,
    granted_at_level: r.granted_at_level,
    count: r.count,
    kind: r.kind,
    spell_levels: r.spell_levels ? safeParse(r.spell_levels) : null,
    categories: r.categories ? safeParse(r.categories) : null,
  }));
}

export function insertPowerGrantStatements(env, characterId, grants) {
  return grants.map((g) => env.DB.prepare(
    `INSERT INTO pending_power_picks (character_id, granted_at_level, count, kind, spell_levels, categories)
     VALUES (?, ?, ?, ?, ?, ?)`
  ).bind(characterId, g.level, g.count, g.kind,
    g.spell_levels ? JSON.stringify(g.spell_levels) : null,
    g.categories ? JSON.stringify(g.categories) : null));
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
      out.push({ ...g, kind: 'spell', spell_levels: spellLevelsForGrant(cls, g.level),
                 categories: null });
    }
  }
  const psionics = psionicGrantsFor(cls, fromLevel, toLevel);
  if (psionics.applicable && !psionics.unknown) {
    for (const g of psionics.grants) {
      out.push({ ...g, kind: 'psionic', spell_levels: null,
                 categories: psionicCategoriesForGrant(cls, g.level) });
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

  // Remaining room per grant, keyed by the level and kind that identify it.
  const room = new Map();
  for (const g of grants) {
    const key = `${g.kind}:${g.level}`;
    room.set(key, (room.get(key) || 0) + g.count);
  }
  const capFor = new Map(grants.map((g) => [`${g.kind}:${g.level}`, g.spell_levels]));
  const catFor = new Map(grants.map((g) => [`${g.kind}:${g.level}`, g.categories]));

  const names = [...new Set(picks.map((p) => String(p?.name || '').trim()).filter(Boolean))];
  const catalog = await loadPowerCatalog(env, names, system);

  for (const pick of picks) {
    const name = String(pick?.name || '').trim();
    const kind = pick?.kind === 'psionic' ? 'psionic' : 'spell';
    const level = Number(pick?.granted_at_level);
    if (!name) { errors.push('A pick has no name'); continue; }

    const key = `${kind}:${level}`;
    if (!room.has(key)) {
      errors.push(`${name}: this character has no ${kind} grant from level ${level}`);
      continue;
    }
    if (room.get(key) <= 0) {
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
    if (kind === 'spell') {
      const cap = capFor.get(key);
      if (cap && !cap.includes(row.level)) {
        errors.push(
          `${name} is a level ${row.level} spell; the level ${level} grant allows ${cap.join(', ')}`);
        continue;
      }
    } else {
      // A psionic grant may name its own categories, and when it does they
      // REPLACE the class's rather than narrowing them - a Mystic's level-4
      // power comes from Super, which its starting powers could not.
      const cats = catFor.get(key);
      if (cats && !cats.includes(row.category)) {
        errors.push(
          `${name} is a ${row.category || 'uncategorised'} power; the level ${level} grant allows ${cats.join(', ')}`);
        continue;
      }
    }

    room.set(key, room.get(key) - 1);
    held.add(name.toLowerCase());
    chosen.push(kind === 'spell'
      ? { type: 'spell', name: row.name, level: row.level, cost: row.ppe,
          ...(row.ppe_note ? { cost_note: row.ppe_note } : {}), gained_at_level: level }
      : { type: 'psionic', name: row.name, category: row.category, cost: row.isp,
          ...(row.isp_note ? { cost_note: row.isp_note } : {}), gained_at_level: level });
  }

  return { powers: chosen, errors };
}

// Only the rows actually named, rather than both catalogs whole: a level-up
// picks two or three, and the spell table is thousands of rows.
async function loadPowerCatalog(env, names, system) {
  const empty = { spell: new Map(), psionic: new Map() };
  if (!names.length) return empty;
  const placeholders = names.map(() => '?').join(', ');
  const [spells, psionics] = await env.DB.batch([
    env.DB.prepare(
      `SELECT name, level, ppe, ppe_note, system FROM spells WHERE name COLLATE NOCASE IN (${placeholders})`
    ).bind(...names),
    env.DB.prepare(
      `SELECT name, category, isp, isp_note, system FROM psionic_powers WHERE name COLLATE NOCASE IN (${placeholders})`
    ).bind(...names),
  ]);
  // A NULL system is unrestricted, which is how every picker already reads it.
  const keep = (r) => !system || !r.system || r.system === system;
  for (const r of spells.results.filter(keep)) empty.spell.set(r.name.toLowerCase(), r);
  for (const r of psionics.results.filter(keep)) empty.psionic.set(r.name.toLowerCase(), r);
  return empty;
}

// What is left of a set of grants after some were spent, consuming from the
// earliest first — the same rule `remainingGrants` applies to skill picks, and
// for the same reason: taking whole grants keeps the right total and attributes
// it to the wrong level.
export function remainingPowerGrants(grants, spentByKey) {
  const remaining = [];
  const left = new Map(spentByKey);
  for (const g of grants) {
    const key = `${g.kind}:${g.level}`;
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
