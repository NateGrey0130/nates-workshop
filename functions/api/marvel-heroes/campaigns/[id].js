// /api/marvel-heroes/campaigns/:id - one campaign.
//
//   GET     -> { campaign, is_gm, heroes }. The GM gets gm_notes and every linked
//              hero's snapshot and sheet; anyone else gets no gm_notes, the sheet
//              of their own heroes only, and the other heroes' names.
//   PATCH   -> GM only: name, description, gm_notes, open. Reopening a campaign
//              whose hero has since joined another open one is a 409, from the
//              one-open-campaign index (migration 086).
//   DELETE  -> GM only. The links, notes and events go with it; the heroes do
//              not, because they were never copied in. Stored pictures are
//              deleted from R2 by hand first, since no cascade reaches a bucket.

import { requireCampaign, json, readJson, parseCampaign, heroView, isUniqueViolation } from '../_lib/campaigns.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id);
  if (g.res) return g.res;
  const { campaign, isGm, email } = g;
  const { results } = await env.DB_MARVEL.prepare(`
    SELECT h.id, h.name, h.owner_email, h.snapshot, h.sheet, h.updated_at, ch.added_at
    FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
    WHERE ch.campaign_id = ? ORDER BY h.name`).bind(campaign.id).all();
  if (!isGm) delete campaign.gm_notes;
  const heroes = results.map((r) => heroView(r, { full: isGm || r.owner_email === email }));
  return json({ campaign, is_gm: isGm, heroes });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const { fields, error } = parseCampaign(body, { partial: true });
  if (error) return json({ error }, 400);
  const keys = Object.keys(fields);
  try {
    await env.DB_MARVEL.prepare(`UPDATE msh_campaigns SET ${keys.map((k) => `${k} = ?`).join(', ')}, updated_at = datetime('now')
      WHERE id = ? AND gm_email = ?`).bind(...keys.map((k) => fields[k]), g.campaign.id, g.email).run();
  } catch (e) {
    if (isUniqueViolation(e)) return json({ error: 'A hero in this campaign has joined another open campaign since; they must leave it before this one reopens' }, 409);
    throw e;
  }
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const { results: keys } = await db.prepare(
    `SELECT r2_key AS k FROM msh_campaign_images WHERE campaign_id = ?
     UNION ALL SELECT portrait_key FROM msh_npcs WHERE campaign_id = ? AND portrait_key IS NOT NULL`
  ).bind(g.campaign.id, g.campaign.id).all();
  if (env.MEDIA) {
    for (const row of keys ?? []) {
      // The CHECK on both columns means every key is under msh/; a failed
      // delete is swallowed so the campaign is never left half-deleted.
      try { await env.MEDIA.delete(row.k); } catch { /* see above */ }
    }
  }
  await db.prepare('DELETE FROM msh_campaigns WHERE id = ? AND gm_email = ?').bind(g.campaign.id, g.email).run();
  return json({ ok: true, objects_deleted: (keys ?? []).length });
}
