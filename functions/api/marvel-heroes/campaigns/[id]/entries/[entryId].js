// /api/marvel-heroes/campaigns/:id/entries/:entryId - one of the GM's pages.
// GM only.
//
//   GET    -> { entry, images }: the page and its pictures, in their order
//   PATCH  { title?, kind?, body? } -> { entry }
//   DELETE -> the page and its pictures. The objects go from R2 first, by hand,
//             because no cascade reaches a bucket.

import { requireCampaign, json, readJson, dropObject } from '../../../_lib/campaigns.js';
import { KINDS } from '../entries.js';

const ROW_ID = /^[1-9]\d{0,11}$/;
const found = (db, campaignId, entryId) => (ROW_ID.test(String(entryId))
  ? db.prepare('SELECT * FROM msh_campaign_entries WHERE id = ? AND campaign_id = ?').bind(Number(entryId), campaignId).first()
  : null);

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const entry = await found(db, g.campaign.id, params.entryId);
  if (!entry) return json({ error: 'Page not found' }, 404);
  const { results } = await db.prepare(`SELECT id, caption, content_type, byte_size, revealed_at, sort, created_at
    FROM msh_campaign_images WHERE entry_id = ? ORDER BY sort, id`).bind(entry.id).all();
  return json({ entry, images: results });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const entry = await found(db, g.campaign.id, params.entryId);
  if (!entry) return json({ error: 'Page not found' }, 404);
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('title' in b) {
    const title = typeof b.title === 'string' ? b.title.trim() : '';
    if (!title) return json({ error: 'title cannot be emptied' }, 400);
    sets.push('title = ?'); binds.push(title.slice(0, 200));
  }
  if ('kind' in b) {
    if (!KINDS.includes(b.kind)) return json({ error: `kind must be one of ${KINDS.join(', ')}` }, 400);
    sets.push('kind = ?'); binds.push(b.kind);
  }
  if ('body' in b) { sets.push('body = ?'); binds.push(typeof b.body === 'string' ? b.body.slice(0, 20000) : null); }
  if (!sets.length) return json({ error: 'title, kind and body are the editable fields' }, 400);
  const row = await db.prepare(`UPDATE msh_campaign_entries SET ${sets.join(', ')}, updated_at = datetime('now')
    WHERE id = ? RETURNING *`).bind(...binds, entry.id).first();
  return json({ entry: row });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const entry = await found(db, g.campaign.id, params.entryId);
  if (!entry) return json({ error: 'Page not found' }, 404);
  const { results } = await db.prepare('SELECT r2_key FROM msh_campaign_images WHERE entry_id = ?').bind(entry.id).all();
  for (const r of results) await dropObject(env, r.r2_key);
  await db.prepare('DELETE FROM msh_campaign_entries WHERE id = ?').bind(entry.id).run();
  return json({ ok: true, images_deleted: results.length });
}
