// A saved city and who may do what with it (migration 080).
//
// A city has NO owner of its own: its G.M. is its campaign's gm_email, and the
// check is campaignAccess's, the one place that knows who runs a campaign.
// Everything about a city is the G.M.'s until they show it; nobody else gets a
// full city from any route, and a city whose map is not shown does not exist
// for them - a 404, not a 403, the rule isHiddenNpc and the NPC library keep.

import { campaignAccess } from './auth.js';

const MAX_CITY_BYTES = 1500000;

export async function cityAccess(env, id, email) {
  const row = await env.DB.prepare('SELECT * FROM cities WHERE id = ?').bind(id).first();
  if (!row) return { found: false };
  const camp = await campaignAccess(env, row.campaign_id, email);
  return { found: true, row, isGm: camp.isGm, shown: !!row.show_map };
}

// What a list shows: never the city's contents.
export const citySummary = (r) => ({
  id: r.id, campaign_id: r.campaign_id, name: r.name, system: r.system, show_map: !!r.show_map,
  created_at: r.created_at, updated_at: r.updated_at,
});

// A city from the page, checked for the shape the City Creator writes. It is
// the G.M.'s own prep and goes back only to the G.M., so this is a sanity
// check on size and shape, not a sanitiser: the player view is BUILT from it
// field by field (city-view.js), never passed through.
export function readCity(v) {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return { error: 'city must be an object' };
  if (v.version !== 1) return { error: 'Not a City Creator city (version 1)' };
  for (const k of ['districts', 'places', 'shops', 'npcs', 'quirks', 'rumours']) {
    if (!Array.isArray(v[k])) return { error: `city.${k} must be a list` };
  }
  if (!v.overview || typeof v.overview.name !== 'string' || !v.overview.name.trim()) {
    return { error: 'city.overview.name is required' };
  }
  const text = JSON.stringify(v);
  if (text.length > MAX_CITY_BYTES) return { error: 'That city is too large to save' };
  return { city: v, text, name: v.overview.name.trim().slice(0, 120), system: v.settings?.system ?? null };
}
