// Storage for classes created by the import tool.
//
// D1 is the only source of class definitions. (An earlier design kept committed
// markdown under apps/character-creator/data/classes and let it win on an id
// collision; that is gone, and this comment used to still describe it.) A row
// goes live without a redeploy, and an extraction is saved as a draft the moment
// it parses so a closed browser tab never loses the work.
//
// Retirement is a soft delete: `deleted_at` NULL means live. A retired class
// disappears from the pickers but characters built on it keep working, which is
// why getStored() — the path the sheet and the level-up endpoints resolve
// through — deliberately does not filter on it.

import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

// Saved as soon as extraction succeeds. Re-importing the same class overwrites
// its draft rather than piling up rows; an already-published class stays
// published so a fresh extraction updates it in place.
export async function saveDraft(env, { classId, name, system, markdown, email }) {
  await env.DB.prepare(
    `INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
     VALUES (?, ?, ?, ?, 'draft', ?)
     ON CONFLICT(class_id) DO UPDATE SET
       markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       updated_at = datetime('now')`
  ).bind(classId, name ?? null, system ?? null, markdown, email).run();
}

// Returned as a statement so callers can batch publishing together with the
// catalog stubs, making the whole confirm step all-or-nothing.
export function publishStatement(env, { classId, name, system, markdown, email }) {
  return env.DB.prepare(
    `INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
     VALUES (?, ?, ?, ?, 'published', ?)
     ON CONFLICT(class_id) DO UPDATE SET
       markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now')`
  ).bind(classId, name ?? null, system ?? null, markdown, email);
}

// Published classes used as format examples in the extraction prompt. Pulled
// from the database so the examples stay current as classes are added.
export async function getExamples(env, limit = 2) {
  // Retired classes are excluded — a class you pulled is a poor thing to teach
  // the extraction prompt to imitate.
  const { results } = await env.DB.prepare(
    `SELECT class_id, markdown FROM imported_classes
     WHERE status = 'published' AND deleted_at IS NULL
     ORDER BY created_at, class_id LIMIT 6`
  ).all();
  // Prefer one of each category so the model sees both shapes.
  const occ = results.filter((r) => /^category:\s*occ\b/m.test(r.markdown));
  const rcc = results.filter((r) => /^category:\s*rcc\b/m.test(r.markdown));
  const picked = [occ[0], rcc[0]].filter(Boolean);
  for (const r of results) {
    if (picked.length >= limit) break;
    if (!picked.includes(r)) picked.push(r);
  }
  return picked.slice(0, limit).map((r) => ({ name: `${r.class_id}.md`, text: r.markdown.trim() }));
}

// `retired: true` lists only retired rows, for the restore view. The default
// lists only live ones.
export async function listStored(env, { retired = false } = {}) {
  const { results } = await env.DB.prepare(
    `SELECT class_id, name, system, status, created_by, created_at, updated_at, deleted_at,
            length(markdown) AS markdown_length
     FROM imported_classes
     WHERE deleted_at IS ${retired ? 'NOT NULL' : 'NULL'}
     ORDER BY updated_at DESC`
  ).all();
  return results;
}

// How many classes are sitting in the retired list, for the list's badge.
export async function countRetired(env) {
  const row = await env.DB.prepare(
    'SELECT count(*) AS n FROM imported_classes WHERE deleted_at IS NOT NULL'
  ).first();
  return row?.n ?? 0;
}

// Deliberately unfiltered on deleted_at. This is how a character's class is
// resolved for the sheet and for level-ups, and retiring a class must not break
// a character someone is in the middle of playing.
export async function getStored(env, classId) {
  return env.DB.prepare('SELECT * FROM imported_classes WHERE class_id = ?').bind(classId).first();
}

// Published classes retire (recoverable); drafts are removed outright. A draft
// is an in-progress extraction — usually a botched one being cleared on purpose
// — and keeping every discarded attempt would turn the retired list into noise.
// Returns what actually happened so the caller can report it accurately.
export async function deleteStored(env, classId) {
  const row = await env.DB.prepare(
    'SELECT status, deleted_at FROM imported_classes WHERE class_id = ?'
  ).bind(classId).first();
  if (!row) return { changes: 0, mode: 'none' };

  if (row.status !== 'published') {
    const res = await env.DB.prepare('DELETE FROM imported_classes WHERE class_id = ?').bind(classId).run();
    return { changes: res.meta?.changes ?? 0, mode: 'deleted' };
  }
  if (row.deleted_at) return { changes: 0, mode: 'already_retired' };

  const res = await env.DB.prepare(
    `UPDATE imported_classes SET deleted_at = datetime('now'), updated_at = datetime('now')
     WHERE class_id = ? AND deleted_at IS NULL`
  ).bind(classId).run();
  return { changes: res.meta?.changes ?? 0, mode: 'retired' };
}

export async function restoreStored(env, classId) {
  const res = await env.DB.prepare(
    `UPDATE imported_classes SET deleted_at = NULL, updated_at = datetime('now')
     WHERE class_id = ? AND deleted_at IS NOT NULL`
  ).bind(classId).run();
  return res.meta?.changes ?? 0;
}

// Parsing is deterministic for a given markdown, so results are memoised per
// isolate and keyed on updated_at. Three pages request the class list on load;
// without this, each request re-parses every class in the catalog.
const parseCache = new Map(); // class_id -> { updated_at, parsed }

// Published rows, parsed. Anything that no longer parses is skipped and
// reported rather than breaking the class list for everyone.
//
// Retired classes are excluded by default so every caller is safe without
// remembering to filter. `includeRetired` is for the two callers that need to
// resolve a name for a character that already exists — the sheet and the GM
// dashboard — and those rows carry `_retired: true`.
//
// Note the cache needs no invalidation on retirement: it is only consulted for
// rows this query returned, so an excluded row can never be served from it.
export async function loadPublished(env, { includeRetired = false } = {}) {
  const classes = [];
  const failures = [];
  let results = [];
  try {
    ({ results } = await env.DB.prepare(
      `SELECT class_id, markdown, updated_at, deleted_at FROM imported_classes
       WHERE status = 'published'${includeRetired ? '' : ' AND deleted_at IS NULL'}`
    ).all());
  } catch {
    return { classes, failures }; // table not migrated yet — behave as before
  }
  for (const row of results) {
    const hit = parseCache.get(row.class_id);
    let parsed = hit && hit.updated_at === row.updated_at ? hit.parsed : null;
    if (!parsed) {
      parsed = parseClassMarkdown(row.markdown);
      parseCache.set(row.class_id, { updated_at: row.updated_at, parsed });
    }
    if (parsed.ok) classes.push({ ...parsed.data, _source: 'imported', _retired: !!row.deleted_at });
    else failures.push({ file: `${row.class_id} (imported)`, errors: parsed.errors });
  }

  return { classes, failures };
}


