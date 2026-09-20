// POST …/entries/:entryId/images — add a picture to a page. GM only.
//
// Raw body, `image/*`, exactly as npcs/[npcId]/portrait.js takes one: same
// 5MB cap, same four types, same reason for the allowlist. What differs is
// that a page holds MANY pictures rather than one, so this inserts a row
// instead of replacing a column, and nothing is deleted here.
//
// A PICTURE ARRIVES UNREVEALED. `revealed_at` stays NULL until the GM says so
// (PATCH images/:imageId), because the point of uploading before a session is
// having it ready, not showing it.

import { json, requireCampaign } from '../../../../_lib/auth.js';

const MAX_BYTES = 5 * 1024 * 1024;
const TYPES = {
  'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp', 'image/gif': 'gif',
};
// A page of pictures is a handout, not an album: past this many the list stops
// being scannable mid-session, and the cap is what stops a phone at the table
// pulling tens of megabytes. There is no image processing on this runtime, so
// what is uploaded is what gets served.
const MAX_PER_ENTRY = 20;

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);

  const entry = await env.DB.prepare(
    'SELECT id FROM campaign_entries WHERE id = ? AND campaign_id = ?'
  ).bind(params.entryId, params.id).first();
  if (!entry) return json({ error: 'Page not found' }, 404);

  const contentType = (request.headers.get('Content-Type') || '').split(';')[0].trim().toLowerCase();
  const ext = TYPES[contentType];
  if (!ext) {
    return json({ error: `Unsupported image type. Send one of: ${Object.keys(TYPES).join(', ')}` }, 415);
  }

  const count = await env.DB.prepare(
    'SELECT count(*) AS n FROM campaign_images WHERE entry_id = ?'
  ).bind(params.entryId).first();
  if ((count?.n ?? 0) >= MAX_PER_ENTRY) {
    return json({ error: `A page holds at most ${MAX_PER_ENTRY} pictures` }, 409);
  }

  const bytes = await request.arrayBuffer();
  if (!bytes.byteLength) return json({ error: 'Empty upload' }, 400);
  if (bytes.byteLength > MAX_BYTES) {
    return json({ error: `An image must be under ${MAX_BYTES / 1024 / 1024}MB` }, 413);
  }

  // Keyed by campaign and page so the store is browsable and a stray object is
  // traceable, with a uuid so every upload is a new key - which is what lets
  // the GET cache immutably.
  const key = `campaign/${params.id}/${params.entryId}/${crypto.randomUUID()}.${ext}`;
  await env.MEDIA.put(key, bytes, { httpMetadata: { contentType } });

  // The object exists before the row does. The other order can leave a row
  // pointing at nothing, which is a broken picture; this order can at worst
  // leave an orphan, which costs storage. Same trade portrait.js makes.
  const caption = (new URL(request.url).searchParams.get('caption') || '').trim() || null;
  const row = await env.DB.prepare(
    `INSERT INTO campaign_images (campaign_id, entry_id, r2_key, content_type, byte_size, caption, sort, created_by)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)
     RETURNING id, caption, content_type, byte_size, revealed_at, sort, created_at`
  ).bind(params.id, params.entryId, key, contentType, bytes.byteLength, caption,
    count?.n ?? 0, guard.email).first();
  return json({ image: row }, 201);
}
