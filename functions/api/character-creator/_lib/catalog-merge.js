// Finding and merging duplicate catalog rows.
//
// The importers dedupe on an EXACT name, which is the right default and misses
// a whole class of real duplicate. A single skill chapter produced ten pairs the
// exact match could not see, because the book and the hand-seeded catalog use
// different conventions for the same skill:
//
//   Skin and Prepare Animal Hides  /  Skin & Prepare Animal Hides
//   Lore — Demons and Monsters     /  Lore: Demons & Monsters
//   Mathematics — Basic            /  Basic Math
//   Tracking                       /  Tracking (people)
//
// So: normalise hard, suggest pairs, and let a human confirm each one. Nothing
// here merges anything on its own.
//
// REFERENCES DIFFER BY CATALOG, and that is the part worth reading carefully.
// Skills, spells and psionic powers are referenced BY NAME inside characters'
// JSON columns. Gear is referenced BY ID, through character_items.item_id.
// Merging therefore rewrites JSON for the first three and repoints a foreign key
// for the last.

import { CATALOGS } from '../../../../apps/character-creator/js/catalog-fields.js';
import { safeParse } from './character-json.js';

export const MERGE_REFS = {
  skills: { kind: 'json', column: 'skills' },
  spells: { kind: 'json', column: 'powers', type: 'spell' },
  psionics: { kind: 'json', column: 'powers', type: 'psionic' },
  gear: { kind: 'fk', table: 'character_items', column: 'item_id' },
};

// ─── name normalisation ───

// Everything that differs between two spellings of the same skill and carries
// no meaning: separators, ampersands, and trailing qualifiers like "(people)".
export function normaliseName(name) {
  return String(name ?? '')
    .toLowerCase()
    .replace(/\([^)]*\)/g, ' ')          // drop "(people)", "(self)", "(general)"
    .replace(/&/g, ' and ')
    .replace(/[—–:_/,.]/g, ' ')
    .replace(/[^a-z0-9 ]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

const STOPWORDS = new Set(['and', 'of', 'the', 'a', 'an']);

function tokens(name) {
  return normaliseName(name).split(' ').filter((t) => t && !STOPWORDS.has(t));
}

// "math" and "mathematics" are the same word for our purposes; "basic" and
// "basics" likewise. Prefix matching from 4 characters catches those without
// collapsing genuinely different short words.
function tokenPairs(a, b) {
  return a === b || (a.length >= 4 && b.length >= 4 && (a.startsWith(b) || b.startsWith(a)));
}

// How alike two names are, 0 to 1. Deliberately generous — a false suggestion
// costs a glance, a missed duplicate costs a wrong catalog.
export function similarity(nameA, nameB) {
  const a = tokens(nameA), b = tokens(nameB);
  if (!a.length || !b.length) return 0;
  if (normaliseName(nameA) === normaliseName(nameB)) return 1;

  const [small, large] = a.length <= b.length ? [a, b] : [b, a];
  const used = new Set();
  let matched = 0;
  for (const t of small) {
    const i = large.findIndex((u, idx) => !used.has(idx) && tokenPairs(t, u));
    if (i >= 0) { used.add(i); matched++; }
  }
  if (matched !== small.length) return matched / large.length;

  // Every word of the shorter name appears in the longer one. That is either
  // the same skill written two ways, or a genuine narrowing like
  // "Chemistry" vs "Chemistry Analytical" — hence a score, not a verdict.
  return small.length === large.length ? 0.95 : 0.75;
}

// ─── candidates ───

const THRESHOLD = 0.7;

export async function findDuplicates(env, catalogKey) {
  const cat = CATALOGS[catalogKey];
  const cols = ['id', cat.uniqueField, cat.displayField, ...cat.fields.map((f) => f.name)];
  const { results } = await env.DB.prepare(
    `SELECT ${[...new Set(cols)].join(', ')} FROM ${cat.table} ORDER BY id`
  ).all();

  // Fields whose disagreement is worth showing: the numbers, not the prose.
  const numeric = cat.fields.filter((f) => f.type === 'int' || f.type === 'real').map((f) => f.name);

  const pairs = [];
  for (let i = 0; i < results.length; i++) {
    for (let j = i + 1; j < results.length; j++) {
      const a = results[i], b = results[j];
      const score = similarity(a[cat.displayField], b[cat.displayField]);
      if (score < THRESHOLD) continue;
      const sameNumbers = numeric.every((f) => a[f] === b[f]);
      // The tiers have very different precision, measured against a real
      // catalog: `certain` and `likely` produced no false positives at all,
      // while `contains` was right about 40% of the time. Grouping by tier is
      // the difference between a usable list and 27 undifferentiated rows.
      const tier = score >= 1 ? 'certain' : score >= 0.9 ? 'likely' : 'contains';
      pairs.push({
        score: Math.round(score * 100) / 100,
        same_numbers: sameNumbers,
        tier,
        a, b,
        confidence: tier === 'certain' ? 'identical once punctuation is ignored'
          : tier === 'likely' ? 'same words, different order or ending'
          : 'one name contains the other — check this one',
      });
    }
  }
  // Strongest first, and identical numbers ahead of differing ones at the same
  // score, because that is the pair you can decide fastest.
  pairs.sort((x, y) => y.score - x.score || Number(y.same_numbers) - Number(x.same_numbers));
  return pairs;
}

// ─── merging ───

// Rewrite one name to another inside a character's JSON column.
function rewriteJson(raw, { column, type }, fromName, toName) {
  const list = safeParse(raw, null);
  if (!Array.isArray(list)) return null;

  let changed = false;
  const out = list.map((entry) => {
    if (!entry || typeof entry !== 'object') return entry;
    if (type && entry.type !== type) return entry;
    if (String(entry.name ?? '').toLowerCase() !== fromName.toLowerCase()) return entry;
    changed = true;
    return { ...entry, name: toName };
  });

  // A character holding BOTH names ends up with the same skill twice, which the
  // validator would then flag. Collapse them, keeping the first.
  const seen = new Set();
  const deduped = out.filter((entry) => {
    if (!entry || typeof entry !== 'object' || !entry.name) return true;
    const key = `${entry.type ?? ''}|${String(entry.name).toLowerCase()}`;
    if (seen.has(key)) { changed = true; return false; }
    seen.add(key);
    return true;
  });

  return changed ? JSON.stringify(deduped) : null;
}

// Which class definitions mention the losing name. Reported, never rewritten:
// class markdown is frontmatter plus prose, and a blind replace would hit lore
// text as readily as a skill list.
export async function classesMentioning(env, name) {
  const { results } = await env.DB.prepare(
    `SELECT class_id, name FROM imported_classes
     WHERE deleted_at IS NULL AND markdown LIKE ?`
  ).bind(`%${name}%`).all();
  return results;
}

// Merge `removeId` into `keepId`. Returns a description of everything it did.
export async function mergeRows(env, catalogKey, keepId, removeId) {
  const cat = CATALOGS[catalogKey];
  const ref = MERGE_REFS[catalogKey];
  if (!cat || !ref) return { error: 'Unknown catalog', status: 400 };
  if (keepId === removeId) return { error: 'Cannot merge a row into itself', status: 400 };

  const [keep, remove] = await Promise.all([
    env.DB.prepare(`SELECT * FROM ${cat.table} WHERE id = ?`).bind(keepId).first(),
    env.DB.prepare(`SELECT * FROM ${cat.table} WHERE id = ?`).bind(removeId).first(),
  ]);
  if (!keep || !remove) return { error: 'One of those rows no longer exists', status: 404 };

  const statements = [];
  const repointed = [];

  if (ref.kind === 'fk') {
    // Gear: inventory points at the row by id, so this is a straight repoint.
    // A character holding both rows keeps both inventory lines, which is
    // correct — two of the same item is a quantity, not a duplicate.
    const { results } = await env.DB.prepare(
      `SELECT id FROM ${ref.table} WHERE ${ref.column} = ?`
    ).bind(removeId).all();
    if (results.length) {
      statements.push(env.DB.prepare(
        `UPDATE ${ref.table} SET ${ref.column} = ? WHERE ${ref.column} = ?`
      ).bind(keepId, removeId));
      repointed.push({ table: ref.table, rows: results.length });
    }
  } else {
    // Skills, spells, psionics: referenced by name inside a JSON column.
    const { results } = await env.DB.prepare(
      `SELECT id, name, ${ref.column} AS payload FROM characters`
    ).all();
    for (const row of results) {
      const next = rewriteJson(row.payload, ref, remove[cat.displayField], keep[cat.displayField]);
      if (!next) continue;
      statements.push(env.DB.prepare(
        `UPDATE characters SET ${ref.column} = ?, updated_at = datetime('now') WHERE id = ?`
      ).bind(next, row.id));
      repointed.push({ character_id: row.id, character: row.name });
    }
  }

  statements.push(env.DB.prepare(`DELETE FROM ${cat.table} WHERE id = ?`).bind(removeId));

  // One batch: a repoint that landed without the delete would leave both rows
  // in the catalog with everything pointing at one of them, which is a stranger
  // state than either doing both or doing neither.
  await env.DB.batch(statements);

  return {
    ok: true,
    kept: { id: keep.id, name: keep[cat.displayField] },
    removed: { id: remove.id, name: remove[cat.displayField] },
    repointed,
    // Advisory: these still say the old name and need a human edit.
    classes_mentioning: ref.kind === 'json'
      ? await classesMentioning(env, remove[cat.displayField])
      : [],
  };
}
