// GET /api/marvel-heroes/campaigns/:id/handouts - what the party has been
// shown: each REVEALED picture's id and caption, newest first. Members only,
// and revealed pictures only for everyone, the GM included - it answers "what
// do they already have". No page id, title or body ever leaves here: the page
// behind a picture is the GM's notebook (msh_campaign_entries).

import { requireMember, json } from '../../_lib/campaigns.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const { results } = await env.DB_MARVEL.prepare(`SELECT id, caption, content_type, revealed_at
    FROM msh_campaign_images WHERE campaign_id = ? AND revealed_at IS NOT NULL
    ORDER BY revealed_at DESC, id DESC LIMIT 200`).bind(g.campaign.id).all();
  return json({ handouts: results, total: results.length });
}
