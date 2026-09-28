// POST /api/marvel-heroes/campaigns/:id/entries/:entryId/images - add a picture
// to one of the GM's pages. GM only. The raw file is the body, with its own
// Content-Type, which is the type check; ?caption= is optional. A new picture
// is the GM's alone until it is revealed. At most 20 a page.
// The key is msh/campaign/<campaign>/<page>/<uuid>.<ext>, under msh/ as the
// table's CHECK requires. -> 201 { image }.

import { requireCampaign, json, readImage, imageKey } from '../../../../_lib/campaigns.js';

const MAX_PER_ENTRY = 20;
const ROW_ID = /^[1-9]\d{0,11}$/;

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);
  const db = env.DB_MARVEL;
  const entry = ROW_ID.test(String(params.entryId)) && await db.prepare('SELECT id FROM msh_campaign_entries WHERE id = ? AND campaign_id = ?')
    .bind(Number(params.entryId), g.campaign.id).first();
  if (!entry) return json({ error: 'Page not found' }, 404);
  const { n } = await db.prepare('SELECT count(*) AS n FROM msh_campaign_images WHERE entry_id = ?').bind(entry.id).first();
  if (n >= MAX_PER_ENTRY) return json({ error: `A page holds at most ${MAX_PER_ENTRY} pictures` }, 409);
  const img = await readImage(request);
  if (img.res) return img.res;
  const key = imageKey(['campaign', g.campaign.id, entry.id], img.ext);
  await env.MEDIA.put(key, img.bytes, { httpMetadata: { contentType: img.contentType } });
  const caption = (new URL(request.url).searchParams.get('caption') || '').trim().slice(0, 300) || null;
  const row = await db.prepare(`INSERT INTO msh_campaign_images (campaign_id, entry_id, r2_key, content_type, byte_size, caption, sort, created_by)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id, caption, content_type, byte_size, revealed_at, sort, created_at`)
    .bind(g.campaign.id, entry.id, key, img.contentType, img.bytes.byteLength, caption, n, g.email).first();
  return json({ image: row }, 201);
}
