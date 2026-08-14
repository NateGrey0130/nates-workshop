// POST /api/character-creator/import/skills/confirm — admin only.
// Body: { source_book?, decisions: [{ action, name, category, base, per_level, note, as_name? }] }
//
// action is one of:
//   insert  — add as a new catalog row (also used for "keep both", where the
//             caller supplies a distinguished as_name, since name is UNIQUE)
//   update  — overwrite the existing row's numbers
//   ignore  — do nothing
//
// Everything is applied in one batch so a partial import can't happen.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';

const int = (v) => {
  const n = parseInt(v, 10);
  return Number.isFinite(n) && n >= 0 ? n : 0;
};

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  if (!Array.isArray(b.decisions)) return json({ error: 'decisions must be an array' }, 400);
  if (b.decisions.length > 500) return json({ error: 'Too many decisions in one import (max 500)' }, 400);

  const sourceBook = typeof b.source_book === 'string' && b.source_book.trim() ? b.source_book.trim() : null;
  const statements = [];
  const applied = { inserted: [], updated: [], ignored: [] };
  const conflicts = [];
  // Names already queued in THIS batch. Checking only the database would miss
  // two rows in one import claiming the same name, and the UNIQUE constraint
  // would then fail the whole batch with an opaque error.
  const queued = new Set();

  for (const d of b.decisions) {
    const action = d?.action;
    if (action === 'ignore' || !action) { if (d?.name) applied.ignored.push(d.name); continue; }

    const name = typeof d.name === 'string' ? d.name.trim() : '';
    if (!name) return json({ error: 'Every decision needs a name' }, 400);
    const category = typeof d.category === 'string' && d.category.trim() ? d.category.trim() : null;
    const note = typeof d.note === 'string' && d.note.trim() ? d.note.trim() : null;
    const base = int(d.base), perLevel = int(d.per_level);

    if (action === 'insert') {
      // "Keep both" supplies a distinguished name; a plain new skill uses its own.
      const target = typeof d.as_name === 'string' && d.as_name.trim() ? d.as_name.trim() : name;
      if (queued.has(target.toLowerCase())) {
        conflicts.push({ name: target, reason: 'Named twice in this same import' });
        continue;
      }
      const clash = await env.DB.prepare('SELECT name FROM skills WHERE name COLLATE NOCASE = ?').bind(target).first();
      if (clash) { conflicts.push({ name: target, reason: 'A skill with that name already exists' }); continue; }
      queued.add(target.toLowerCase());
      statements.push(env.DB.prepare(
        `INSERT INTO skills (name, category, base, per_level, source, source_book, note)
         VALUES (?, ?, ?, ?, 'import', ?, ?)`
      ).bind(target, category, base, perLevel, sourceBook, note));
      applied.inserted.push(target);
    } else if (action === 'update') {
      statements.push(env.DB.prepare(
        `UPDATE skills SET category = COALESCE(?, category), base = ?, per_level = ?,
                           source_book = COALESCE(?, source_book), note = COALESCE(?, note)
         WHERE name COLLATE NOCASE = ?`
      ).bind(category, base, perLevel, sourceBook, note, name));
      applied.updated.push(name);
    } else {
      return json({ error: `Unknown action: ${action}` }, 400);
    }
  }

  try {
    if (statements.length) await env.DB.batch(statements);
  } catch (err) {
    // All-or-nothing: nothing was written, so report it as such rather than
    // leaving the caller guessing which half landed.
    return json({ error: 'Nothing was imported — the database rejected the batch: ' + err.message }, 409);
  }

  return json({
    ok: true,
    counts: { inserted: applied.inserted.length, updated: applied.updated.length, ignored: applied.ignored.length },
    applied,
    conflicts,
  });
}
