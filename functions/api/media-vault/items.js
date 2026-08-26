// /api/media-vault/items — MediaVault's library, one row per item in D1.
//
// This replaced the old /api/media whole-library PUT: a save here touches only
// the row it changes, so two open tabs can no longer clobber each other's
// libraries with full replaces. D1 is the only store — the client keeps no
// localStorage copy (see apps/media-vault/app.js).

import { getUserEmail, json, sanitizeItem, rowToItem, UPSERT_SQL, bindUpsert, countItems, MAX_ITEMS } from './_lib/common.js';

// GET → { email, items } — the caller's whole library
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);
  try {
    const { results } = await context.env.DB
      .prepare('SELECT * FROM media_items WHERE user_email = ? ORDER BY added_at')
      .bind(email)
      .all();
    return json({ email, items: results.map(rowToItem) });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// POST { ...item } → upsert that one item
export async function onRequestPost(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }
  const item = sanitizeItem(body);
  if (!item) return json({ error: 'Item needs a string id and non-empty title' }, 400);

  const db = context.env.DB;
  try {
    const existing = await db
      .prepare('SELECT 1 FROM media_items WHERE user_email = ? AND item_id = ?')
      .bind(email, item.id)
      .first();
    if (!existing && (await countItems(db, email)) >= MAX_ITEMS) {
      return json({ error: `Library is full (max ${MAX_ITEMS} items)` }, 400);
    }
    await bindUpsert(db.prepare(UPSERT_SQL), email, item).run();
    return json({ ok: true, item });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// DELETE ?id=<item_id> → deletes one item
export async function onRequestDelete(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  const id = new URL(context.request.url).searchParams.get('id');
  if (!id) return json({ error: 'Missing id query parameter' }, 400);

  try {
    await context.env.DB
      .prepare('DELETE FROM media_items WHERE user_email = ? AND item_id = ?')
      .bind(email, id)
      .run();
    return json({ ok: true });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
