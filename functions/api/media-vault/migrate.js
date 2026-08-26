// POST /api/media-vault/migrate { items: [...] } — the one-shot merge that
// retires localStorage as a data store.
//
// The client calls this once per browser that still holds an old `mv_library`
// cache: items whose title+type already exist in the caller's cloud rows are
// skipped (cloud wins — the title match is case-insensitive), the rest are
// inserted with fresh server-side ids only if their own id collides. On a 2xx
// the client deletes the localStorage key, permanently; on failure it leaves
// the key alone and retries next load. Calling this twice with the same items
// is therefore safe: the second call skips everything the first inserted.

import { getUserEmail, json, sanitizeItem, UPSERT_SQL, bindUpsert, MAX_ITEMS } from './_lib/common.js';

export async function onRequestPost(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }
  if (!body || !Array.isArray(body.items)) {
    return json({ error: 'Body must be { items: [...] }' }, 400);
  }
  if (body.items.length === 0) return json({ ok: true, imported: 0, skipped: 0 });
  if (body.items.length > MAX_ITEMS) {
    return json({ error: `Too many items (max ${MAX_ITEMS})` }, 400);
  }

  const items = [];
  for (const raw of body.items) {
    const clean = sanitizeItem(raw);
    if (!clean) return json({ error: 'Every item needs a string id and non-empty title' }, 400);
    items.push(clean);
  }

  const db = context.env.DB;
  try {
    const { results } = await db
      .prepare('SELECT item_id, title, type FROM media_items WHERE user_email = ?')
      .bind(email)
      .all();
    const cloudKeys = new Set(results.map((r) => r.title.toLowerCase() + '|' + r.type));
    const cloudIds = new Set(results.map((r) => r.item_id));

    const toInsert = [];
    let skipped = 0;
    for (const it of items) {
      const key = it.title.toLowerCase() + '|' + it.type;
      if (cloudKeys.has(key)) { skipped++; continue; }
      cloudKeys.add(key); // dedupe within the batch too
      if (cloudIds.has(it.id)) it.id = crypto.randomUUID();
      toInsert.push(it);
    }

    if (results.length + toInsert.length > MAX_ITEMS) {
      return json({ error: `Migration would exceed the library cap (max ${MAX_ITEMS} items)` }, 400);
    }

    if (toInsert.length > 0) {
      const insert = db.prepare(UPSERT_SQL);
      await db.batch(toInsert.map((it) => bindUpsert(insert, email, it)));
    }
    return json({ ok: true, imported: toInsert.length, skipped });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
