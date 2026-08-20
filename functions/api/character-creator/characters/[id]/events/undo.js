// POST /api/character-creator/characters/:id/events/undo — reverse the LATEST
// not-yet-undone event that carries changes, in one batch: restore every
// `from` value and stamp the event's undone_at. Only the latest, by design:
// undoing an older event under newer ones is ambiguous arithmetic, and the
// button this backs is "take back the last thing", not a history editor.
// Rolls and recaps carry no changes and are skipped over when finding it.
//
// The undo is itself visible history — the row stays, marked, and the
// response says what was restored so the client can update in place.

import { json, requireCharacter } from '../../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const { results } = await env.DB.prepare(
    `SELECT id, kind, payload FROM play_events
     WHERE character_id = ? AND undone_at IS NULL AND kind NOT IN ('roll', 'recap')
     ORDER BY id DESC LIMIT 1`
  ).bind(params.id).all();
  if (!results.length) return json({ error: 'Nothing to undo' }, 404);

  const ev = results[0];
  let payload;
  try { payload = JSON.parse(ev.payload); } catch { payload = {}; }
  const changes = payload.changes || {};
  const statements = [];
  const restored = { character: {}, item: null };

  const charFields = changes.character || {};
  const sets = [], binds = [];
  for (const [field, fv] of Object.entries(charFields)) {
    if (typeof fv?.from !== 'number') continue;
    sets.push(`${field} = ?`); binds.push(fv.from);
    restored.character[field] = fv.from;
  }
  if (sets.length) {
    statements.push(env.DB.prepare(
      `UPDATE characters SET ${sets.join(', ')}, updated_at = datetime('now') WHERE id = ?`
    ).bind(...binds, params.id));
  }

  if (changes.item && typeof changes.item.notes?.from === 'string') {
    statements.push(env.DB.prepare(
      'UPDATE character_items SET notes = ? WHERE id = ? AND character_id = ?'
    ).bind(changes.item.notes.from, changes.item.id, params.id));
    restored.item = { id: changes.item.id, notes: changes.item.notes.from };
  }

  statements.push(env.DB.prepare(
    `UPDATE play_events SET undone_at = datetime('now') WHERE id = ?`
  ).bind(ev.id));

  await env.DB.batch(statements);
  return json({ ok: true, undone: { id: ev.id, kind: ev.kind, note: payload.note }, restored });
}
