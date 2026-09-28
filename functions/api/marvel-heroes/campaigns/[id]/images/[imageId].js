// /api/marvel-heroes/campaigns/:id/images/:imageId - one picture from the GM's
// pages.
//
//   GET    -> the image. The GM sees any; another member sees it only once it is
//             revealed, and before that it answers exactly like one that does
//             not exist.
//   PATCH  { caption?, sort?, revealed? } -> { image }. GM only. `revealed` is
//          the one switch that makes a picture a handout, and turning it on
//          again keeps the first reveal's time.
//   DELETE -> GM only; the object goes from R2.

import { requireMember, requireCampaign, json, readJson, serveImage, dropObject } from '../../../_lib/campaigns.js';

const ROW_ID = /^[1-9]\d{0,11}$/;
const found = (db, campaignId, imageId) => (ROW_ID.test(String(imageId))
  ? db.prepare('SELECT * FROM msh_campaign_images WHERE id = ? AND campaign_id = ?').bind(Number(imageId), campaignId).first()
  : null);

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const image = await found(env.DB_MARVEL, g.campaign.id, params.imageId);
  if (!image || (!image.revealed_at && !g.isGm)) return json({ error: 'Image not found' }, 404);
  return serveImage(env, image.r2_key, image.content_type);
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const image = await found(db, g.campaign.id, params.imageId);
  if (!image) return json({ error: 'Image not found' }, 404);
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('caption' in b) { sets.push('caption = ?'); binds.push(typeof b.caption === 'string' ? b.caption.slice(0, 300) : null); }
  if ('sort' in b) {
    const n = Number(b.sort);
    if (!Number.isFinite(n)) return json({ error: 'sort must be a number' }, 400);
    sets.push('sort = ?'); binds.push(Math.trunc(n));
  }
  if ('revealed' in b) {
    if (!b.revealed) sets.push('revealed_at = NULL');
    else if (!image.revealed_at) sets.push("revealed_at = datetime('now')");
  }
  const cols = 'id, entry_id, caption, content_type, byte_size, revealed_at, sort, created_at';
  if (!sets.length) {
    if (!['caption', 'sort', 'revealed'].some((k) => k in b)) return json({ error: 'caption, sort and revealed are the editable fields' }, 400);
    return json({ image: await db.prepare(`SELECT ${cols} FROM msh_campaign_images WHERE id = ?`).bind(image.id).first() });
  }
  const row = await db.prepare(`UPDATE msh_campaign_images SET ${sets.join(', ')} WHERE id = ? RETURNING ${cols}`)
    .bind(...binds, image.id).first();
  return json({ image: row });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const image = await found(db, g.campaign.id, params.imageId);
  if (!image) return json({ error: 'Image not found' }, 404);
  await db.prepare('DELETE FROM msh_campaign_images WHERE id = ?').bind(image.id).run();
  await dropObject(env, image.r2_key);
  return json({ ok: true });
}
