// POST /api/character-creator/characters/:id/events/undo — reverse the LATEST
// not-yet-undone event that carries changes, in one batch: restore every
// `from` value and stamp the event's undone_at. Only the latest, by design:
// undoing an older event under newer ones is ambiguous arithmetic, and the
// button this backs is "take back the last thing", not a history editor.
// Pure records are skipped over when finding it. They are excluded BY KIND
// rather than by having no `changes`, which is worth saying because the two
// are not the same test: an event of an unlisted kind with nothing to restore
// is still selected, still stamped undone, and still restores nothing -- so it
// eats the press and leaves the real last change standing. Any new kind that
// carries no changes belongs in the list below, and `grant` is one.
//
// The undo is itself visible history — the row stays, marked, and the
// response says what was restored so the client can update in place.

import { json, requireCharacter } from '../../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const { results } = await env.DB.prepare(
    `SELECT id, kind, payload FROM play_events
     WHERE character_id = ? AND undone_at IS NULL AND kind NOT IN ('roll', 'recap', 'grant')
     ORDER BY id DESC LIMIT 1`
  ).bind(params.id).all();
  if (!results.length) return json({ error: 'Nothing to undo' }, 404);

  const ev = results[0];
  let payload;
  try { payload = JSON.parse(ev.payload); } catch { payload = {}; }
  const changes = payload.changes || {};
  const statements = [];
  const restored = { character: {}, item: null, armor: null, vehicle: null };

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

  // An armour or vessel hit (UI-AUDIT F40): the value the hit replaced, exactly
  // - blank armour back to blank, an untouched location back to absent.
  if (changes.armor && Number.isInteger(changes.armor.index)) {
    const { index, mdc_current: m } = changes.armor;
    const row = await env.DB.prepare('SELECT armor FROM characters WHERE id = ?').bind(params.id).first();
    let armor;
    try { armor = JSON.parse(row?.armor || '[]'); } catch { armor = []; }
    if (Array.isArray(armor) && armor[index]) {
      const back = typeof m?.raw_from === 'string' ? m.raw_from : String(m?.from ?? '');
      armor[index] = { ...armor[index], mdc_current: back };
      statements.push(env.DB.prepare(
        "UPDATE characters SET armor = ?, updated_at = datetime('now') WHERE id = ?"
      ).bind(JSON.stringify(armor), params.id));
      restored.armor = { index, mdc_current: back };
    }
  }
  if (changes.vehicle && typeof changes.vehicle.location === 'string') {
    const { id: vid, location, mdc: m } = changes.vehicle;
    const v = await env.DB.prepare(
      'SELECT id, mdc_current FROM character_vehicles WHERE id = ? AND character_id = ?'
    ).bind(vid, params.id).first();
    if (v) {
      let cur;
      try { cur = JSON.parse(v.mdc_current || '{}') || {}; } catch { cur = {}; }
      if (m?.absent) delete cur[location]; else cur[location] = m?.from;
      statements.push(env.DB.prepare('UPDATE character_vehicles SET mdc_current = ? WHERE id = ?')
        .bind(JSON.stringify(cur), v.id));
      restored.vehicle = { id: v.id, location, mdc: m?.absent ? null : m?.from };
    }
  }

  statements.push(env.DB.prepare(
    `UPDATE play_events SET undone_at = datetime('now') WHERE id = ?`
  ).bind(ev.id));

  await env.DB.batch(statements);
  return json({ ok: true, undone: { id: ev.id, kind: ev.kind, note: payload.note }, restored });
}
