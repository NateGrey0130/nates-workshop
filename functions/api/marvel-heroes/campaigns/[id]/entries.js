// /api/marvel-heroes/campaigns/:id/entries - the GM's own pages (the shared
// setting view, shared/js/campaign/setting.js). GM only, always: a page's
// title and body are never revealed. Its pictures can be, one at a time
// (images/[imageId].js), and a revealed picture is what players see as a
// handout (handouts.js).
//
//   GET  -> { entries }, most recently changed first, each with how many
//           pictures it has and how many are revealed
//   POST { title, kind?, body? } -> 201 { entry }

import { requireCampaign, json, readJson } from '../../_lib/campaigns.js';

export const KINDS = ['place', 'faction', 'lore', 'handout', 'prep'];

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const { results } = await env.DB_MARVEL.prepare(`SELECT e.*,
      (SELECT count(*) FROM msh_campaign_images i WHERE i.entry_id = e.id) AS image_count,
      (SELECT count(*) FROM msh_campaign_images i WHERE i.entry_id = e.id AND i.revealed_at IS NOT NULL) AS revealed_count
    FROM msh_campaign_entries e WHERE e.campaign_id = ? ORDER BY e.updated_at DESC, e.id DESC LIMIT 500`).bind(g.campaign.id).all();
  return json({ entries: results, total: results.length });
}

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const title = typeof b.title === 'string' ? b.title.trim() : '';
  if (!title) return json({ error: 'title is required' }, 400);
  if (title.length > 200) return json({ error: 'title is too long' }, 400);
  const kind = b.kind ?? 'lore';
  if (!KINDS.includes(kind)) return json({ error: `kind must be one of ${KINDS.join(', ')}` }, 400);
  const row = await env.DB_MARVEL.prepare(`INSERT INTO msh_campaign_entries (campaign_id, kind, title, body, created_by)
    VALUES (?, ?, ?, ?, ?) RETURNING *`)
    .bind(g.campaign.id, kind, title, typeof b.body === 'string' ? b.body.slice(0, 20000) : null, g.email).first();
  return json({ entry: row }, 201);
}
