// /api/marvel-heroes/campaigns/:id/npcs/:npcId/portrait - a dossier's picture.
//
//   GET    -> the image, streamed through this Function. Members only: nothing
//             is ever served from a public bucket URL.
//   POST   -> upload one, the raw file as the body with its own Content-Type
//             (the People view downscales it to 512px first). Any member.
//   DELETE -> remove it. Any member.
// The key is msh/npc/<campaign>/<npc>/<uuid>.<ext>: under msh/, as migration
// 086's CHECK requires, and new on every upload, which is what lets the GET be
// cached as immutable. The row is written before the old object is deleted, so
// a failure leaves an orphan rather than a dossier pointing at nothing.

import { requireMember, json, readImage, imageKey, serveImage, dropObject } from '../../../../_lib/campaigns.js';

const ROW_ID = /^[1-9]\d{0,11}$/;
const found = (db, campaignId, npcId) => (ROW_ID.test(String(npcId))
  ? db.prepare('SELECT id, portrait_key FROM msh_npcs WHERE id = ? AND campaign_id = ?').bind(Number(npcId), campaignId).first()
  : null);

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const npc = await found(env.DB_MARVEL, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  if (!npc.portrait_key) return json({ error: 'No portrait' }, 404);
  return serveImage(env, npc.portrait_key);
}

export async function onRequestPost({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);
  const db = env.DB_MARVEL;
  const npc = await found(db, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  const img = await readImage(request);
  if (img.res) return img.res;
  const key = imageKey(['npc', g.campaign.id, npc.id], img.ext);
  await env.MEDIA.put(key, img.bytes, { httpMetadata: { contentType: img.contentType } });
  await db.prepare("UPDATE msh_npcs SET portrait_key = ?, updated_at = datetime('now') WHERE id = ?").bind(key, npc.id).run();
  if (npc.portrait_key !== key) await dropObject(env, npc.portrait_key);
  return json({ ok: true, portrait_key: key });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const npc = await found(db, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  if (!npc.portrait_key) return json({ ok: true });
  await db.prepare("UPDATE msh_npcs SET portrait_key = NULL, updated_at = datetime('now') WHERE id = ?").bind(npc.id).run();
  await dropObject(env, npc.portrait_key);
  return json({ ok: true });
}
