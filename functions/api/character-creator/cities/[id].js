// GET    /api/character-creator/cities/:id - the whole city (G.M. only)
// PATCH  /api/character-creator/cities/:id {city?, show_map?, reveal?, public?} (G.M. only)
// DELETE /api/character-creator/cities/:id (G.M. only)
//
// A saved City Creator city (migration 080). Its G.M. is its campaign's G.M.;
// to anyone else the whole city does not exist - 404, whether or not its map
// is shown, because the map a player may see is a different, smaller thing
// the server builds (the player view), never this.
//
// PATCH:
//   city      the whole city again, after the G.M. rerolled or edited it
//   show_map  true/false - whether the campaign's players see the map
//   reveal    { entryId: true|false } - which pins the players see
//   public    { entryId: "text" } - what the players read about one; a G.M.'s
//             secret lives in fields the player view never reads, so it
//             cannot leak through this one

import { getUserEmail, unauthorized, json, readJson } from '../_lib/auth.js';
import { cityAccess, citySummary, readCity } from '../_lib/city-access.js';

async function gmOnly(request, env, id) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const a = await cityAccess(env, id, email);
  if (!a.found || !a.isGm) return { res: json({ error: 'City not found' }, 404) };
  return { email, row: a.row };
}

export async function onRequestGet({ request, env, params }) {
  const g = await gmOnly(request, env, params.id);
  if (g.res) return g.res;
  let city = null;
  try { city = JSON.parse(g.row.data); } catch { return json({ error: 'This city cannot be read' }, 500); }
  return json({ ...citySummary(g.row), city });
}

const ENTRY_ID = /^(overview|district-[\w-]+|place-\d+|shop-\d+|npc-\d+|quirk-\d+|rumour-\d+)$/;

export async function onRequestPatch({ request, env, params }) {
  const g = await gmOnly(request, env, params.id);
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);

  let city;
  if ('city' in b) {
    const got = readCity(b.city);
    if (got.error) return json({ error: got.error }, 400);
    city = got.city;
  } else {
    try { city = JSON.parse(g.row.data); } catch { return json({ error: 'This city cannot be read' }, 500); }
  }
  // Reveal and public text live in the city, keyed by entry id, so a reroll
  // that keeps an entry keeps what the players were shown of it.
  city.reveal = { ...(city.reveal || {}) };
  city.public = { ...(city.public || {}) };
  for (const [id, on] of Object.entries(b.reveal || {})) {
    if (!ENTRY_ID.test(id)) return json({ error: `Not an entry id: ${id}` }, 400);
    if (on) city.reveal[id] = true; else delete city.reveal[id];
  }
  for (const [id, text] of Object.entries(b.public || {})) {
    if (!ENTRY_ID.test(id)) return json({ error: `Not an entry id: ${id}` }, 400);
    if (text != null && typeof text !== 'string') return json({ error: 'public text must be text' }, 400);
    const t = (text || '').trim().slice(0, 2000);
    if (t) city.public[id] = t; else delete city.public[id];
  }
  const text = JSON.stringify(city);
  const showMap = 'show_map' in b ? (b.show_map ? 1 : 0) : g.row.show_map;
  const name = String(city.overview?.name || g.row.name).trim().slice(0, 120) || g.row.name;
  const row = await env.DB.prepare(
    `UPDATE cities SET data = ?, name = ?, show_map = ?, updated_at = datetime('now') WHERE id = ?
     RETURNING id, campaign_id, name, system, show_map, created_at, updated_at`
  ).bind(text, name, showMap, params.id).first();
  return json({ ...citySummary(row), reveal: city.reveal, public: city.public });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await gmOnly(request, env, params.id);
  if (g.res) return g.res;
  await env.DB.prepare('DELETE FROM cities WHERE id = ?').bind(params.id).run();
  return json({ ok: true });
}
