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
import { safeParse } from './character-json.js';
import { categoryAllows, categoryBonus } from '../../../../apps/character-creator/js/parser.js';
import { REPEATABLE_ROWS, isFamilyName, otherRowFor } from '../../../../apps/character-creator/js/language-skills.js';
import { skillBase } from '../../../../apps/character-creator/js/skill-base.js';
import { selectInChunks } from './sql-chunk.js';

export async function listPending(env, characterId) {
  const { results } = await env.DB.prepare(
    `SELECT id, granted_at_level, count, categories, kind, created_at
     FROM pending_skill_picks
     WHERE character_id = ? AND claimed_at IS NULL
     ORDER BY granted_at_level, id`
  ).bind(characterId).all();
  return results.map((r) => ({
    id: r.id,
    granted_at_level: r.granted_at_level,
    count: r.count,
    categories: r.categories ? safeParse(r.categories) : null,
    // NULL means related, which is what every pick granted before secondary
    // schedules existed was.
    kind: r.kind === 'secondary' ? 'secondary' : 'related',
    created_at: r.created_at,
  }));
}

export function insertGrantStatements(env, characterId, grants) {
  return grants.map((g) => env.DB.prepare(
    `INSERT INTO pending_skill_picks (character_id, granted_at_level, count, categories, kind)
     VALUES (?, ?, ?, ?, ?)`
  ).bind(characterId, g.level, g.count,
    g.categories ? JSON.stringify(g.categories) : null,
    g.kind === 'secondary' ? 'secondary' : null));
}

// What is left of a set of grants after `spent` picks have been taken.
//
// Consumes ACROSS grants from the earliest first, rather than taking whole
// grants. Taking whole grants keeps the right total and attributes it to the
// wrong level: spending 1 of a level-3 pair would bank "level 3 x 2" and lose
// the level-6 grant entirely.
//
// Two callers now - a live level-up, and a character created above level 1 -
// which is why the rule and its reason live here rather than in either.
export function remainingGrants(grants, spent) {
  let toSpend = Math.max(0, spent);
  const remaining = [];
  for (const g of grants) {
    const consumed = Math.min(g.count, toSpend);
    toSpend -= consumed;
    const left = g.count - consumed;
    if (left > 0) remaining.push({ ...g, count: left });
  }
  return remaining;
}

// Merge category lists from several grants without duplicating.
//
// A plain `new Set(...)` dedupes strings but not objects: two grants naming the
// same `{ name: "Espionage", only: [...] }` are distinct references and both
// survive. Harmless for matching — categoryAllows() takes the first hit — but
// it makes the list grow every level, so key on the serialised entry.
export function dedupeCategories(entries) {
  const seen = new Map();
  for (const e of entries) {
    const key = typeof e === 'string' ? e.toLowerCase() : JSON.stringify(e);
    if (!seen.has(key)) seen.set(key, e);
  }
  return [...seen.values()];
}

// Turn requested picks into skill entries, or explain why not.
//
// `allowance` is the total number of picks available across the grants being
// spent, and `categories` what the RELATED grants among them permit.
//
// A class can grant both kinds at the same level — the Long Bowman earns
// related picks at 3, 7, 10 and 13 and a secondary at 4, 7, 10 and 13 — and the
// two are not interchangeable: related picks are bounded by the class's
// categories, secondary picks are not. Merging them would make one unrestricted
// secondary grant quietly unrestrict the related picks too.
//
// So a pick inside the categories spends a related slot; one outside spends a
// secondary slot, and is recorded as a secondary skill. Running out of
// secondary slots is what makes an out-of-category pick an error.
//
// `secondaryAllowance` of 0 restores the old behaviour exactly.
// `attributes` is the character's attribute block, needed because a skill's
// starting percentage can be DERIVED from one — Zero Gravity Movement & Combat
// is P.P. x5 (BOOK-INGEST-AUDIT F2). Without it that skill is stored at 0 and,
// because js/leveling.js advances from the stored `pct`, climbs from 0 forever
// (F18). Both callers already have the character loaded, so this costs no query.
export async function resolvePicks(env, { picks, existingSkills, allowance, categories, level, secondaryAllowance = 0, attributes = {} }) {
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
  // EVERY Other row rides along in the lookup: a pick named "Language: X" or
  // "Literacy: X" that misses the catalog is a custom one and takes its numbers
  // from its family's Other row, keeping the name it was given (see
  // js/language-skills.js).
  // Chunked: D1 binds at most 100 parameters per statement. The Other rows ride
  // along in EVERY chunk, not just the first - a custom language landing in the
  // second chunk needs them as much as one in the first.
  const results = await selectInChunks(names, (batch) => env.DB.prepare(
    `SELECT name, category, base, base_formula, per_level FROM skills
     WHERE name COLLATE NOCASE IN (${[...batch, ...REPEATABLE_ROWS].map(() => '?').join(',')})`
  ).bind(...batch, ...REPEATABLE_ROWS));
  const catalog = new Map(results.map((r) => [r.name.toLowerCase(), r]));

  const skills = [];
  const errors = [];
  let secondaryLeft = Number.isFinite(secondaryAllowance) ? secondaryAllowance : 0;
  // A category entry may be a plain name or an object stating what the class
  // allows inside it. Shared with the wizard's picker and the validator — this
  // is the third consumer, and it broke first: a Set of lowercased strings
  // threw outright on an object the moment restrictions were introduced.
  const allowed = Array.isArray(categories) && categories.length ? categories : null;

  for (const p of picks) {
    const name = String(p.name).trim();
    let row = catalog.get(name.toLowerCase());
    if (!row && isFamilyName(name)) {
      const other = catalog.get(String(otherRowFor(name)).toLowerCase());
      if (other) row = { ...other, name };
    }
    if (!row) { errors.push(`No skill called "${name}" in the catalog`); continue; }

    const outOfCategory = allowed && !categoryAllows(allowed, { name: row.name, category: row.category });
    // An out-of-category pick spends a secondary slot if one is left. Only when
    // none is does it become an error, or an override a human insisted on.
    let asSecondary = false;
    if (outOfCategory && secondaryLeft > 0) {
      asSecondary = true;
      secondaryLeft -= 1;
    } else if (outOfCategory && !p.override) {
      errors.push(`${row.name} is ${row.category || 'uncategorised'}, which this grant does not cover`);
      continue;
    }

    // The class's per-category bonus, on a related pick only. A pick that fell
    // out of category and is being spent as a secondary one does NOT get it,
    // which is the same rule the wizard applies at creation and the same rule
    // the books state: the parenthetical percentage is for related selections.
    //
    // Guarded on the RESOLVED percentage, not on the stored `base`. The guard
    // exists so a W.P. has no percentage for a percentage bonus to modify — and
    // a formula-derived base IS a real percentage, so it takes the bonus like
    // any other. Testing `row.base` here would trade F18's visible 0% for a
    // percentage quietly missing its class bonus, which is harder to notice than
    // the bug it replaces. BOOK-INGEST-AUDIT F18.
    const catBonus = !asSecondary && allowed
      ? categoryBonus(allowed, { name: row.name, category: row.category }) : 0;
    const base = skillBase(row, attributes);

    skills.push({
      name: row.name,
      category: row.category,
      // Base percentage as written. A skill learned at level 6 is still new.
      pct: base ? base + catBonus : 0,
      per_level: row.per_level ?? 0,
      type: asSecondary ? 'secondary' : 'related',
      gained_at_level: level,
      ...(outOfCategory && !asSecondary ? { override: true } : {}),
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

