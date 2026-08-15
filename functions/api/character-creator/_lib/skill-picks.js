// Spending the skill picks a level-up granted.
//
// A grant is banked in pending_skill_picks the moment a level-up commits, and
// spent either in the same request or whenever the player comes back to it. The
// two paths share everything here so they cannot drift.
//
// A picked skill starts at its catalog base percentage and advances per level
// from there. That is the standard Palladium reading: a newly learned skill is
// new regardless of the character's level.

import { json } from './auth.js';

export async function listPending(env, characterId) {
  const { results } = await env.DB.prepare(
    `SELECT id, granted_at_level, count, categories, created_at
     FROM pending_skill_picks
     WHERE character_id = ? AND claimed_at IS NULL
     ORDER BY granted_at_level, id`
  ).bind(characterId).all();
  return results.map((r) => ({
    id: r.id,
    granted_at_level: r.granted_at_level,
    count: r.count,
    categories: r.categories ? safeParse(r.categories) : null,
    created_at: r.created_at,
  }));
}

export async function countPending(env, characterId) {
  const row = await env.DB.prepare(
    `SELECT coalesce(sum(count), 0) AS n FROM pending_skill_picks
     WHERE character_id = ? AND claimed_at IS NULL`
  ).bind(characterId).first();
  return row?.n ?? 0;
}

export function insertGrantStatements(env, characterId, grants) {
  return grants.map((g) => env.DB.prepare(
    `INSERT INTO pending_skill_picks (character_id, granted_at_level, count, categories)
     VALUES (?, ?, ?, ?)`
  ).bind(characterId, g.level, g.count, g.categories ? JSON.stringify(g.categories) : null));
}

// Turn requested picks into skill entries, or explain why not.
//
// `allowance` is the total number of picks available across the grants being
// spent, and `categories` the union of what those grants permit. An out-of-
// category pick is allowed only when the caller says so explicitly, and is
// recorded as an override so the sheet and any later validation can see that a
// human decided it rather than the rules permitting it.
export async function resolvePicks(env, { picks, existingSkills, allowance, categories, level }) {
  if (!Array.isArray(picks) || !picks.length) return { skills: [], errors: [] };
  if (picks.length > allowance) {
    return { errors: [`That is ${picks.length} picks but only ${allowance} are available`] };
  }

  const names = picks.map((p) => (typeof p?.name === 'string' ? p.name.trim() : '')).filter(Boolean);
  if (names.length !== picks.length) return { errors: ['Every pick needs a skill name'] };

  const seen = new Set();
  for (const n of names) {
    const key = n.toLowerCase();
    if (seen.has(key)) return { errors: [`${n} was picked twice`] };
    seen.add(key);
  }

  const held = new Set((existingSkills || []).map((s) => String(s.name).toLowerCase()));
  const alreadyHave = names.filter((n) => held.has(n.toLowerCase()));
  if (alreadyHave.length) {
    return { errors: [`Already known: ${alreadyHave.join(', ')}`] };
  }

  // One batched lookup — the catalog supplies the starting percentage, so a
  // caller cannot invent one.
  const { results } = await env.DB.prepare(
    `SELECT name, category, base, per_level FROM skills
     WHERE name COLLATE NOCASE IN (${names.map(() => '?').join(',')})`
  ).bind(...names).all();
  const catalog = new Map(results.map((r) => [r.name.toLowerCase(), r]));

  const skills = [];
  const errors = [];
  const allowed = Array.isArray(categories) && categories.length
    ? new Set(categories.map((c) => c.toLowerCase()))
    : null;

  for (const p of picks) {
    const name = String(p.name).trim();
    const row = catalog.get(name.toLowerCase());
    if (!row) { errors.push(`No skill called "${name}" in the catalog`); continue; }

    const outOfCategory = allowed && !allowed.has(String(row.category ?? '').toLowerCase());
    if (outOfCategory && !p.override) {
      errors.push(`${row.name} is ${row.category || 'uncategorised'}, which this grant does not cover`);
      continue;
    }

    skills.push({
      name: row.name,
      category: row.category,
      // Base percentage as written. A skill learned at level 6 is still new.
      pct: row.base ?? 0,
      per_level: row.per_level ?? 0,
      type: 'related',
      gained_at_level: level,
      ...(outOfCategory ? { override: true } : {}),
    });
  }

  return { skills, errors };
}

// Marks grants claimed, oldest first, consuming `spent` picks. A grant only
// partly spent stays pending with its count reduced, so two picks earned at
// level 3 can be taken one at a time.
export function claimStatements(env, pending, spent) {
  const statements = [];
  let left = spent;
  for (const g of pending) {
    if (left <= 0) break;
    if (g.count <= left) {
      left -= g.count;
      statements.push(env.DB.prepare(
        `UPDATE pending_skill_picks SET claimed_at = datetime('now') WHERE id = ?`
      ).bind(g.id));
    } else {
      statements.push(env.DB.prepare(
        'UPDATE pending_skill_picks SET count = count - ? WHERE id = ?'
      ).bind(left, g.id));
      left = 0;
    }
  }
  return statements;
}

export function pickErrors(errors) {
  return json({ error: errors.join('; '), errors }, 422);
}

function safeParse(text) {
  try { return JSON.parse(text); } catch { return null; }
}
