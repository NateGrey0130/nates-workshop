// POST /api/media-vault/items/bulk-delete { ids: [...] } — the bulk bar's
// delete. Deletes exactly the named rows; there is deliberately no
// "delete everything" form.

import { getUserEmail, json, MAX_ITEMS } from '../_lib/common.js';

export async function onRequestPost(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }
  if (!body || !Array.isArray(body.ids) || body.ids.length === 0) {
    return json({ error: 'Body must be { ids: [...] }' }, 400);
  }
  if (body.ids.length > MAX_ITEMS) return json({ error: `Too many ids (max ${MAX_ITEMS})` }, 400);
  if (body.ids.some((id) => typeof id !== 'string' || !id || id.length > 100)) {
    return json({ error: 'Every id must be a string' }, 400);
  }

  const db = context.env.DB;
  try {
    // Chunked because D1 caps bound parameters per query.
    const statements = [];
    for (let i = 0; i < body.ids.length; i += 90) {
      const chunk = body.ids.slice(i, i + 90);
      const placeholders = chunk.map(() => '?').join(', ');
      statements.push(
        db.prepare(`DELETE FROM media_items WHERE user_email = ? AND item_id IN (${placeholders})`)
          .bind(email, ...chunk)
      );
    }
    const results = await db.batch(statements);
    const deleted = results.reduce((n, r) => n + (r.meta?.changes || 0), 0);
    return json({ ok: true, count: deleted });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
