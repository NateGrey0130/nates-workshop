// /api/marvel-heroes/campaigns/:id/heroes - which heroes are played here.
//
//   POST { hero_id }     -> link one of the CALLER'S OWN heroes to this open
//                           campaign. A hero already in another open campaign is
//                           a 409: the index in migration 086 refuses it, so two
//                           requests racing cannot both get through.
//   DELETE ?hero_id=<id> -> unlink it: the hero's owner, or the GM. Nothing about
//                           the hero changes; only the link goes.

import { requireCampaign, json, readJson, HERO_ID, isUniqueViolation } from '../../_lib/campaigns.js';

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id);
  if (g.res) return g.res;
  if (!g.campaign.open) return json({ error: 'This campaign is closed' }, 409);
  const body = await readJson(request);
  const heroId = body?.hero_id;
  if (typeof heroId !== 'string' || !HERO_ID.test(heroId)) return json({ error: 'not a hero id' }, 400);
  const db = env.DB_MARVEL;
  // Your own hero, and only your own: someone else's answers as missing.
  const hero = await db.prepare('SELECT id, name FROM msh_heroes WHERE id = ? AND owner_email = ?').bind(heroId, g.email).first();
  if (!hero) return json({ error: 'no such hero' }, 404);
  try {
    const res = await db.prepare(`INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by)
      SELECT id, ?, open, ? FROM msh_campaigns WHERE id = ? AND open = 1`).bind(heroId, g.email, g.campaign.id).run();
    if (!res.meta?.changes) return json({ error: 'This campaign is closed' }, 409);
  } catch (e) {
    if (!isUniqueViolation(e)) throw e;
    const other = await db.prepare(`SELECT c.id, c.name FROM msh_campaign_heroes ch JOIN msh_campaigns c ON c.id = ch.campaign_id
      WHERE ch.hero_id = ? AND ch.campaign_open = 1`).bind(heroId).first();
    if (other?.id === g.campaign.id) return json({ error: `${hero.name} is already in this campaign` }, 409);
    return json({ error: `${hero.name} is already in an open campaign${other ? `, ${other.name}` : ''}. A hero plays in one open campaign at a time.` }, 409);
  }
  return json({ ok: true, hero: { id: hero.id, name: hero.name } }, 201);
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id);
  if (g.res) return g.res;
  const heroId = new URL(request.url).searchParams.get('hero_id');
  if (!heroId || !HERO_ID.test(heroId)) return json({ error: 'not a hero id' }, 400);
  const res = await env.DB_MARVEL.prepare(`DELETE FROM msh_campaign_heroes WHERE campaign_id = ? AND hero_id = ?
      AND (? = 1 OR hero_id IN (SELECT id FROM msh_heroes WHERE owner_email = ?))`)
    .bind(g.campaign.id, heroId, g.isGm ? 1 : 0, g.email).run();
  return res.meta?.changes ? json({ ok: true }) : json({ error: 'no such hero in this campaign' }, 404);
}
