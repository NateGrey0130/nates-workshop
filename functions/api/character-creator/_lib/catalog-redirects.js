// Forwarding pointers for retired catalog keys.
//
// Merging two catalog rows deletes one of them, and repointing the characters
// that held it is only half the job. Class markdown cites gear by SLUG in
// equipment_starting[].item_id, and skills, spells and psionics BY NAME —
// citations a merge deliberately never rewrites, because that markdown is
// frontmatter mixed with lore prose and a blind replace would hit both.
//
// So after a merge those citations name a key that no longer exists, and both
// consequences are silent rather than loud:
//
//   building a character   → the item drops to a bare custom line, no stats
//   re-importing the class → the stub the merge just deleted comes straight back
//
// Neither raises an error. The merge simply comes undone.
//
// A redirect closes that: the merge leaves a note saying where the key went,
// and the two places that resolve a key fall through to it. Old citations keep
// working permanently, and nobody has to remember to go and edit prose.
//
// Redirects are recorded for hand edits too. Renaming a slug in the catalog
// editor breaks exactly the same references as a merge does.

import { getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';

const norm = (s) => String(s ?? '').trim().toLowerCase();

// D1 caps bound parameters per query, and the key list comes from
// model-extracted class data, which is effectively unbounded.
const LOOKUP_BATCH = 50;

// The keys a row answers to: its unique key, and its display name when that is
// a different column (gear is the only catalog where it is — slug vs name).
export function keysOf(cat, row) {
  return [...new Set([row?.[cat.uniqueField], row?.[cat.displayField]].filter(Boolean).map(String))];
}

// Statements rather than writes, so a merge can record its redirects inside the
// same batch that repoints characters and deletes the losing row. If those came
// apart you would get a redirect to a row that still exists, or a deleted row
// with no forwarding address — both worse than doing nothing.
//
// `skipKeys` are the surviving row's own keys. Merging two rows whose names
// differ only by case would otherwise file a redirect that shadows the live key
// it points at, which is the exact ambiguity this table exists to remove.
export function redirectStatements(env, catalogKey, fromKeys, toId, reason, skipKeys = []) {
  const skip = new Set(skipKeys.map(norm));
  const keys = [...new Set(fromKeys.filter(Boolean).map(String))]
    .filter((k) => !skip.has(norm(k)));

  return keys.map((k) => env.DB.prepare(
    `INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
     VALUES (?, ?, ?, ?)
     ON CONFLICT (catalog, from_key)
     DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason`
  ).bind(catalogKey, k, toId, reason));
}

// Merging a row that other redirects already point at has to move them onto the
// survivor, or the chain breaks at the first hop and every key that arrived
// through it goes dangling again.
export function collapseStatement(env, catalogKey, fromId, toId) {
  return env.DB.prepare(
    `UPDATE catalog_redirects SET to_id = ? WHERE catalog = ? AND to_id = ?`
  ).bind(toId, catalogKey, fromId);
}

// Which of these keys redirect, as normalised key → target id.
export async function resolveKeys(env, catalogKey, keys) {
  const wanted = [...new Set(keys.filter(Boolean).map(String))];
  const out = new Map();
  if (!wanted.length) return out;

  for (let i = 0; i < wanted.length; i += LOOKUP_BATCH) {
    const batch = wanted.slice(i, i + LOOKUP_BATCH);
    const { results } = await env.DB.prepare(
      `SELECT from_key, to_id FROM catalog_redirects
       WHERE catalog = ? AND from_key IN (${batch.map(() => '?').join(',')})`
    ).bind(catalogKey, ...batch).all();
    for (const r of results) out.set(norm(r.from_key), r.to_id);
  }
  return out;
}

// One key, with the row it resolves to. INNER JOIN on purpose: a redirect whose
// target has itself been deleted is dead, and a dead redirect must not block
// anyone from reusing the key.
export async function redirectTarget(env, catalogKey, key) {
  if (!key) return null;
  const cat = getCatalog(catalogKey);
  if (!cat) return null;

  return env.DB.prepare(
    `SELECT r.id, r.from_key, r.reason, r.to_id,
            t.${cat.displayField} AS target_name, t.${cat.uniqueField} AS target_key
     FROM catalog_redirects r
     JOIN ${cat.table} t ON t.id = r.to_id
     WHERE r.catalog = ? AND r.from_key = ?`
  ).bind(catalogKey, String(key)).first();
}

// LEFT JOIN here, unlike redirectTarget: the point of the list is to be able to
// see and remove redirects, including the broken ones.
export async function listRedirects(env, catalogKey) {
  const cat = getCatalog(catalogKey);
  if (!cat) return [];

  const { results } = await env.DB.prepare(
    `SELECT r.id, r.from_key, r.reason, r.created_at, r.to_id,
            t.${cat.displayField} AS target_name, t.${cat.uniqueField} AS target_key
     FROM catalog_redirects r
     LEFT JOIN ${cat.table} t ON t.id = r.to_id
     WHERE r.catalog = ?
     ORDER BY r.created_at DESC, r.id DESC`
  ).bind(catalogKey).all();
  return results;
}

export async function deleteRedirect(env, catalogKey, id) {
  const res = await env.DB.prepare(
    `DELETE FROM catalog_redirects WHERE catalog = ? AND id = ?`
  ).bind(catalogKey, id).run();
  return (res.meta?.changes || 0) > 0;
}
