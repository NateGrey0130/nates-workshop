// Cloudflare Pages Function — MediaVault library CRUD against D1.
// Cloudflare Access fronts the whole site, so every request carries the
// authenticated user's email; each user only ever sees their own rows.

import { getAccessEmail as getUserEmail } from './_lib/access.js';

const ITEM_FIELDS = ['type', 'format', 'title', 'author', 'actors', 'producers', 'genre', 'series', 'location', 'cover', 'notes'];
const MAX_ITEMS = 5000;
const MAX_FIELD_LEN = 4000;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function rowToItem(row) {
  return {
    id: row.item_id,
    type: row.type,
    format: row.format,
    title: row.title,
    author: row.author,
    actors: row.actors,
    producers: row.producers,
    genre: row.genre,
    series: row.series,
    location: row.location,
    cover: row.cover,
    notes: row.notes,
    addedAt: row.added_at,
  };
}

function sanitizeItem(item) {
  if (!item || typeof item !== 'object') return null;
  if (typeof item.id !== 'string' || !item.id || item.id.length > 100) return null;
  if (typeof item.title !== 'string' || !item.title.trim()) return null;
  const clean = { id: item.id, addedAt: Number.isFinite(item.addedAt) ? item.addedAt : Date.now() };
  for (const f of ITEM_FIELDS) {
    const v = item[f];
    clean[f] = typeof v === 'string' ? v.slice(0, MAX_FIELD_LEN) : '';
  }
  if (!clean.type) clean.type = 'audiobook';
  if (!clean.format) clean.format = 'digital';
  return clean;
}

async function listItems(db, email) {
  const { results } = await db
    .prepare('SELECT * FROM media_items WHERE user_email = ? ORDER BY added_at')
    .bind(email)
    .all();
  return results.map(rowToItem);
}

// GET /api/media → { email, items: [...] }
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);
  try {
    const items = await listItems(context.env.DB, email);
    return json({ email, items });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// PUT /api/media { items: [...] } → replaces the caller's entire library
export async function onRequestPut(context) {
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
    const statements = [db.prepare('DELETE FROM media_items WHERE user_email = ?').bind(email)];
    const insert = db.prepare(
      `INSERT INTO media_items (user_email, item_id, type, format, title, author, actors, producers, genre, series, location, cover, notes, added_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const it of items) {
      statements.push(insert.bind(
        email, it.id, it.type, it.format, it.title, it.author, it.actors,
        it.producers, it.genre, it.series, it.location, it.cover, it.notes, it.addedAt
      ));
    }
    await db.batch(statements);
    return json({ ok: true, count: items.length });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// DELETE /api/media?id=<item_id> → deletes one item
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
