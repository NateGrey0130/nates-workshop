// /api/marvel-heroes/campaigns/:id/events - the GM's changes to heroes' Health
// and Karma, and undoing one.
//
//   GET                 -> { events }: the last 50, newest first, with each hero's
//                          name and whether the event has been undone. GM only.
//   POST { undo: <id> } -> GM only, while the campaign is open. Writes the reverse
//                          change as a NEW event whose `undoes` names the old one,
//                          in one batch with the hero's row. An event is undone
//                          once (a unique index, migration 086) and an undo is
//                          not itself undone - make the change again instead.
//                          The reverse is a delta, so anything changed since
//                          stays changed. -> { hero, events }.

import { requireCampaign, json, readJson, playStatements, heroAndEvents, isUniqueViolation } from '../../_lib/campaigns.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const { results } = await env.DB_MARVEL.prepare(`
    SELECT e.*, h.name AS hero_name,
      (SELECT u.id FROM msh_hero_events u WHERE u.undoes = e.id) AS undone_by
    FROM msh_hero_events e JOIN msh_heroes h ON h.id = e.hero_id
    WHERE e.campaign_id = ? ORDER BY e.id DESC LIMIT 50`).bind(g.campaign.id).all();
  return json({ events: results });
}

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  if (!g.campaign.open) return json({ error: 'This campaign is closed' }, 409);
  const body = await readJson(request);
  const id = body?.undo;
  if (!Number.isInteger(id) || id < 1) return json({ error: 'Send { undo: <event id> }' }, 400);
  const db = env.DB_MARVEL;
  const e = await db.prepare('SELECT * FROM msh_hero_events WHERE id = ? AND campaign_id = ?').bind(id, g.campaign.id).first();
  if (!e) return json({ error: 'no such change in this campaign' }, 404);
  if (e.undoes !== null) return json({ error: 'That change was itself an undo; make the change again instead' }, 400);
  let results;
  try {
    results = await db.batch(playStatements(db, { campaignId: g.campaign.id, heroId: e.hero_id, email: g.email,
      field: e.field, delta: -e.delta, undoes: e.id }));
  } catch (err) {
    if (isUniqueViolation(err)) return json({ error: 'That change has already been undone' }, 409);
    throw err;
  }
  if (results.some((r) => !r.meta?.changes)) return json({ error: 'That hero is no longer in this campaign' }, 409);
  return json(await heroAndEvents(db, g.campaign.id, e.hero_id, 1));
}
