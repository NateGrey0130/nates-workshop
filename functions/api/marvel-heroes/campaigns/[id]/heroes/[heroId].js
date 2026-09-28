// /api/marvel-heroes/campaigns/:id/heroes/:heroId - one linked hero.
//
//   GET    -> { hero } with its snapshot and sheet: the GM of this campaign or the
//             hero's owner. This is how a GM reads a player's sheet; heroes.js
//             stays owner-only.
//   PATCH  -> GM of this campaign only, while it is open. Body { field: delta } for
//             health, karma, karma_pool and advancement, and nothing else: any
//             other key is a 400. Writes the hero's own row (msh_heroes.sheet) and
//             an msh_hero_events row per field, in ONE batch, each statement
//             guarded in its own SQL. -> { hero, events }.

import { requireCampaign, json, readJson, parsePlayPatch, playStatements, linkedHero, heroAndEvents, heroView, NUMBER_MAX } from '../../../_lib/campaigns.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id);
  if (g.res) return g.res;
  const row = await linkedHero(env.DB_MARVEL, g.campaign.id, params.heroId);
  if (!row || !(g.isGm || row.owner_email === g.email)) return json({ error: 'no such hero in this campaign' }, 404);
  return json({ hero: heroView(row, { full: true }) });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  if (!g.campaign.open) return json({ error: 'This campaign is closed' }, 409);
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const { changes, error } = parsePlayPatch(body);
  if (error) return json({ error }, 400);
  const db = env.DB_MARVEL;
  const row = await linkedHero(db, g.campaign.id, params.heroId);
  if (!row) return json({ error: 'no such hero in this campaign' }, 404);
  for (const [f, d] of changes) {
    if (Math.abs(row[`cur_${f}`] + d) > NUMBER_MAX) return json({ error: `${f} would pass ${NUMBER_MAX}` }, 400);
  }
  const results = await db.batch(changes.flatMap(([field, delta]) =>
    playStatements(db, { campaignId: g.campaign.id, heroId: row.id, email: g.email, field, delta })));
  // The guard is in the SQL as well as above; if anything moved between the two,
  // the batch changed nothing and says so.
  if (results.some((r) => !r.meta?.changes)) return json({ error: 'The hero or the campaign changed; nothing was written' }, 409);
  return json(await heroAndEvents(db, g.campaign.id, row.id, changes.length));
}
