// GET  /api/character-creator/characters/:id/events — recent play events,
//      newest last. ?since=<event id> returns only rows after it (the recap
//      uses the last 'recap' marker as its boundary); ?limit= caps (default
//      100, max 300).
// POST /api/character-creator/characters/:id/events — apply a play action and
//      record it, in ONE batch: {kind, note?, changes?}. `changes` carries
//      absolute from/to values — {character: {sdc_current: {from, to}}} and/or
//      {item: {id, notes: {from, to}}} — applied as given. The trust model is
//      the sheet's existing PATCH (client-side arithmetic, owner/GM enforced
//      server-side); what the event adds is atomicity and the undo trail. A
//      roll has no changes and is a pure record.
//
// Events are commentary, not a ledger: the character row stays the source of
// truth, and nothing replays these to derive state.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';

// The character columns a play event may touch. Anything else is the sheet
// lens's business and goes through PATCH, where the field list lives.
const POOL_FIELDS = new Set(['hp_current', 'sdc_current', 'mdc_current', 'ppe_current', 'isp_current']);
const KINDS = new Set(['damage', 'pool', 'power', 'ammo', 'roll', 'recap']);

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id, { write: false });
  if (guard.res) return guard.res;

  const url = new URL(request.url);
  const since = parseInt(url.searchParams.get('since') || '0', 10) || 0;
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '100', 10) || 100, 300);
  const { results } = await env.DB.prepare(
    `SELECT id, actor_email, kind, payload, undone_at, created_at FROM play_events
     WHERE character_id = ? AND id > ? ORDER BY id DESC LIMIT ?`
  ).bind(params.id, since, limit).all();
  results.reverse();
  for (const r of results) { try { r.payload = JSON.parse(r.payload); } catch { r.payload = {}; } }
  return json({ events: results });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { email } = guard;

  const b = await readJson(request);
  if (!b || !KINDS.has(b.kind)) return json({ error: 'kind must be one of damage/pool/power/ammo/roll/recap' }, 400);

  const changes = b.changes || {};
  const statements = [];

  const charFields = changes.character || {};
  const sets = [], binds = [];
  for (const [field, fv] of Object.entries(charFields)) {
    if (!POOL_FIELDS.has(field)) return json({ error: `${field} is not a play-adjustable field` }, 400);
    if (typeof fv?.to !== 'number' || typeof fv?.from !== 'number') {
      return json({ error: `${field} needs numeric from and to` }, 400);
    }
    sets.push(`${field} = ?`); binds.push(fv.to);
  }
  // GUARDED REPLAY. `from` has always been sent and validated and never used:
  // it is the client's belief about where the pool was, kept for undo. A queued
  // event replayed after a spell offline may be replaying onto a pool someone
  // else has moved, and applying `to` blindly would silently discard their
  // change - which is the whole failure the queue exists to avoid making
  // worse.
  //
  // Guarded PER FIELD rather than on the row, because two people touching
  // different pools are not in conflict. A row-level check would call that a
  // clash and a per-field one does not.
  //
  // Opt-in via `guard`, so every existing caller keeps the behaviour it has.
  if (sets.length) {
    const guards = [], guardBinds = [];
    if (b.guard) {
      for (const [field, fv] of Object.entries(charFields)) {
        guards.push(`${field} IS ?`);
        guardBinds.push(fv.from);
      }
    }
    statements.push(env.DB.prepare(
      `UPDATE characters SET ${sets.join(', ')}, updated_at = datetime('now')`
      + ` WHERE id = ?${guards.length ? ' AND ' + guards.join(' AND ') : ''}`
    ).bind(...binds, params.id, ...guardBinds));
  }

  // Checked BEFORE the batch, because a batch that applies nothing still
  // inserts the event and would leave a log entry for a change that never
  // happened.
  if (b.guard && sets.length) {
    const cols = Object.keys(charFields);
    const current = await env.DB.prepare(
      `SELECT ${cols.join(', ')} FROM characters WHERE id = ?`
    ).bind(params.id).first();
    if (!current) return json({ error: 'Character not found' }, 404);
    const moved = cols.filter((f) => current[f] !== charFields[f].from);
    if (moved.length) {
      return json({
        error: 'These pools changed somewhere else since this was queued',
        conflict: true,
        // Both sides, so the client can offer a real choice rather than
        // picking one on the player's behalf.
        fields: Object.fromEntries(moved.map((f) => [f, {
          mine: charFields[f].to, theirs: current[f], base: charFields[f].from,
        }])),
      }, 409);
    }
  }

  if (changes.item) {
    const { id: itemId, notes } = changes.item;
    if (typeof notes?.to !== 'string') return json({ error: 'item change needs notes.to' }, 400);
    const row = await env.DB.prepare(
      'SELECT id FROM character_items WHERE id = ? AND character_id = ?'
    ).bind(itemId, params.id).first();
    if (!row) return json({ error: 'No such inventory item' }, 404);
    statements.push(env.DB.prepare(
      'UPDATE character_items SET notes = ? WHERE id = ?'
    ).bind(notes.to, itemId));
  }

  const payload = JSON.stringify({ note: typeof b.note === 'string' ? b.note.slice(0, 300) : undefined, changes });
  statements.push(env.DB.prepare(
    'INSERT INTO play_events (character_id, actor_email, kind, payload) VALUES (?, ?, ?, ?)'
  ).bind(params.id, email, b.kind, payload));

  await env.DB.batch(statements);
  const row = await env.DB.prepare(
    'SELECT id, created_at FROM play_events WHERE character_id = ? ORDER BY id DESC LIMIT 1'
  ).bind(params.id).first();
  return json({ ok: true, event_id: row.id, created_at: row.created_at });
}
