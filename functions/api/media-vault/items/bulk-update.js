// POST /api/media-vault/items/bulk-update { ids: [...], set: { type } }
// — the bulk bar's "change type to →" action. The settable fields are a
// whitelist: everything else on an item goes through the single-item upsert,
// which validates the whole object.

import { getUserEmail, json, MAX_ITEMS } from '../_lib/common.js';

const SETTABLE = {
  type: ['audiobook', 'movie', 'series'],
  format: ['digital', 'physical'],
};

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
    return json({ error: 'Body must be { ids: [...], set: {...} }' }, 400);
  }
  if (body.ids.length > MAX_ITEMS) return json({ error: `Too many ids (max ${MAX_ITEMS})` }, 400);
  if (body.ids.some((id) => typeof id !== 'string' || !id || id.length > 100)) {
    return json({ error: 'Every id must be a string' }, 400);
  }
  const set = body.set;
  if (!set || typeof set !== 'object') return json({ error: 'Missing set object' }, 400);
  const fields = Object.keys(set);
  if (fields.length === 0) return json({ error: 'set names no fields' }, 400);
  for (const f of fields) {
    if (!SETTABLE[f]) return json({ error: `Field not bulk-settable: ${f}` }, 400);
    if (!SETTABLE[f].includes(set[f])) return json({ error: `Invalid value for ${f}: ${set[f]}` }, 400);
  }

  const assignments = fields.map((f) => `${f} = ?`).join(', ');
  const values = fields.map((f) => set[f]);
  const db = context.env.DB;
  try {
    // Chunked because D1 caps bound parameters per query.
    const statements = [];
    for (let i = 0; i < body.ids.length; i += 90) {
      const chunk = body.ids.slice(i, i + 90);
      const placeholders = chunk.map(() => '?').join(', ');
      statements.push(
        db.prepare(`UPDATE media_items SET ${assignments} WHERE user_email = ? AND item_id IN (${placeholders})`)
          .bind(...values, email, ...chunk)
      );
    }
    const results = await db.batch(statements);
    const changed = results.reduce((n, r) => n + (r.meta?.changes || 0), 0);
    return json({ ok: true, count: changed });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
