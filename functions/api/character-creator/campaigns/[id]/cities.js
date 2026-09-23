// GET  /api/character-creator/campaigns/:id/cities - the campaign's saved cities
// POST /api/character-creator/campaigns/:id/cities {city} - save one (G.M. only)
//
// The City Creator's cities (migration 080). The G.M. lists all of them; anyone
// else lists only the cities whose map the G.M. has shown, and never more than
// a summary - a city's contents leave the server whole only for its G.M.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { citySummary, readCity } from '../../_lib/city-access.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  const { results } = await env.DB.prepare(
    `SELECT id, campaign_id, name, system, show_map, created_at, updated_at FROM cities
     WHERE campaign_id = ? ${guard.access.isGm ? '' : 'AND show_map = 1'} ORDER BY name COLLATE NOCASE, id`
  ).bind(params.id).all();
  return json({ cities: (results || []).map(citySummary), is_gm: guard.access.isGm });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const got = readCity(b.city);
  if (got.error) return json({ error: got.error }, 400);
  const row = await env.DB.prepare(
    `INSERT INTO cities (campaign_id, name, system, data, created_by) VALUES (?, ?, ?, ?, ?)
     RETURNING id, campaign_id, name, system, show_map, created_at, updated_at`
  ).bind(params.id, got.name, got.system, got.text, guard.email).first();
  return json({ city: citySummary(row) }, 201);
}
