// PATCH  /api/character-creator/characters/:id/items/:itemId — qty / equipped / notes (owner/GM)
// DELETE /api/character-creator/characters/:id/items/:itemId — soft-remove: sets
//        removed_at so inventory history survives (never hard-deletes).

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../../_lib/auth.js';

async function guard(env, params, email) {
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return { err: json({ error: 'Character not found' }, 404) };
  if (!access.canWrite) return { err: forbidden() };
  const row = await env.DB.prepare(
    'SELECT * FROM character_items WHERE id = ? AND character_id = ?'
  ).bind(params.itemId, params.id).first();
  if (!row) return { err: json({ error: 'Inventory row not found' }, 404) };
  return { row };
}

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err } = await guard(env, params, email);
  if (err) return err;

  const b = await request.json();
  const sets = [], binds = [];
  if ('qty' in b) {
    const qty = parseInt(b.qty, 10);
    if (!Number.isFinite(qty) || qty < 1) return json({ error: 'qty must be a positive number' }, 400);
    sets.push('qty = ?'); binds.push(qty);
  }
  if ('equipped' in b) { sets.push('equipped = ?'); binds.push(b.equipped ? 1 : 0); }
  if ('notes' in b) { sets.push('notes = ?'); binds.push(b.notes ?? null); }
  if (!sets.length) return json({ error: 'No editable fields in body' }, 400);

  await env.DB.prepare(`UPDATE character_items SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, params.itemId).run();
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err } = await guard(env, params, email);
  if (err) return err;

  await env.DB.prepare(
    "UPDATE character_items SET removed_at = datetime('now') WHERE id = ? AND removed_at IS NULL"
  ).bind(params.itemId).run();
  return json({ ok: true });
}
