// /api/marvel-heroes/campaigns - Marvel Heroes campaigns.
//
//   GET                                   -> { campaigns: [...] }: every open campaign, and every
//                                            closed one the caller runs or has a hero in. Each
//                                            says is_gm, and my_heroes lists the caller's own
//                                            heroes linked to it
//   POST { name, description? }           -> create one; the caller is its GM
//
// gm_notes never appears in the list, even for the GM: the campaign's own GET
// carries it, and only to them.

import { owner, json, readJson, parseCampaign } from './_lib/campaigns.js';

export async function onRequestGet({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  const db = env.DB_MARVEL;
  const { results } = await db.prepare(`
    SELECT c.id, c.name, c.description, c.gm_email, c.open, c.created_at,
      (SELECT count(*) FROM msh_campaign_heroes WHERE campaign_id = c.id) AS hero_count
    FROM msh_campaigns c
    WHERE c.open = 1 OR c.gm_email = ?
      OR EXISTS (SELECT 1 FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
                 WHERE ch.campaign_id = c.id AND h.owner_email = ?)
    ORDER BY c.open DESC, c.name`).bind(email, email).all();
  const { results: mine } = await db.prepare(`
    SELECT ch.campaign_id, h.id, h.name FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
    WHERE h.owner_email = ? ORDER BY h.name`).bind(email).all();
  const campaigns = results.map((c) => ({
    ...c, is_gm: c.gm_email === email,
    my_heroes: mine.filter((m) => m.campaign_id === c.id).map((m) => ({ id: m.id, name: m.name })),
  }));
  return json({ campaigns });
}

export async function onRequestPost({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const { fields, error } = parseCampaign(body);
  if (error) return json({ error }, 400);
  const row = await env.DB_MARVEL.prepare(
    `INSERT INTO msh_campaigns (name, gm_email, description) VALUES (?, ?, ?)
     RETURNING id, name, gm_email, description, open, created_at`
  ).bind(fields.name, email, fields.description ?? null).first();
  return json({ campaign: row }, 201);
}
