// POST /api/media-vault/items/bulk { items: [...] } — upsert many at once.
// This is CSV import's endpoint: every item in the body is written, existing
// ids are overwritten. It is NOT a replace — rows not named in the body are
// untouched, which is the property the old whole-library PUT lacked.

import { getUserEmail, json, sanitizeItem, UPSERT_SQL, bindUpsert, countItems, MAX_ITEMS } from '../_lib/common.js';

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
  if (body.items.length === 0) return json({ ok: true, count: 0 });
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
    // The cap counts what the library will hold, not just this batch. Upserts
    // of existing ids don't grow it, so count only the genuinely new ids.
    // The IN() check is chunked because D1 caps bound parameters per query.
    const existingCount = await countItems(db, email);
    const ids = items.map((it) => it.id);
    const already = new Set();
    for (let i = 0; i < ids.length; i += 90) {
      const chunk = ids.slice(i, i + 90);
      const placeholders = chunk.map(() => '?').join(', ');
      const { results } = await db
        .prepare(`SELECT item_id FROM media_items WHERE user_email = ? AND item_id IN (${placeholders})`)
        .bind(email, ...chunk)
        .all();
      for (const r of results) already.add(r.item_id);
    }
    const newCount = ids.filter((id) => !already.has(id)).length;
    if (existingCount + newCount > MAX_ITEMS) {
      return json({ error: `Import would exceed the library cap (max ${MAX_ITEMS} items)` }, 400);
    }

    const insert = db.prepare(UPSERT_SQL);
    await db.batch(items.map((it) => bindUpsert(insert, email, it)));
    return json({ ok: true, count: items.length });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
