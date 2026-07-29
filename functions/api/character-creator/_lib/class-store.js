// Storage for classes created by the import tool.
//
// Committed markdown under apps/character-creator/data/classes remains the
// source of truth and always wins on an id collision — a file you have
// deliberately committed should never be silently shadowed by a database row.
// This table exists so an import goes live immediately without a redeploy, and
// so an extraction is never lost to a closed browser tab.

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

export async function publish(env, { classId, name, system, markdown, email }) {
  await env.DB.prepare(
    `INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
     VALUES (?, ?, ?, ?, 'published', ?)
     ON CONFLICT(class_id) DO UPDATE SET
       markdown = excluded.markdown,
       name = excluded.name,
       system = excluded.system,
       status = 'published',
       updated_at = datetime('now')`
  ).bind(classId, name ?? null, system ?? null, markdown, email).run();
}

export async function listStored(env) {
  const { results } = await env.DB.prepare(
    `SELECT class_id, name, system, status, created_by, created_at, updated_at,
            length(markdown) AS markdown_length
     FROM imported_classes ORDER BY updated_at DESC`
  ).all();
  return results;
}

export async function getStored(env, classId) {
  return env.DB.prepare('SELECT * FROM imported_classes WHERE class_id = ?').bind(classId).first();
}

export async function deleteStored(env, classId) {
  const res = await env.DB.prepare('DELETE FROM imported_classes WHERE class_id = ?').bind(classId).run();
  return res.meta?.changes ?? 0;
}

// Published rows, parsed. Anything that no longer parses is skipped and
// reported rather than breaking the class list for everyone.
export async function loadPublished(env) {
  const classes = [];
  const failures = [];
  let results = [];
  try {
    ({ results } = await env.DB.prepare(
      "SELECT class_id, markdown FROM imported_classes WHERE status = 'published'"
    ).all());
  } catch {
    return { classes, failures }; // table not migrated yet — behave as before
  }
  for (const row of results) {
    const parsed = parseClassMarkdown(row.markdown);
    if (parsed.ok) classes.push({ ...parsed.data, _source: 'imported' });
    else failures.push({ file: `${row.class_id} (imported)`, errors: parsed.errors });
  }
  return { classes, failures };
}
