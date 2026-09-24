// GET /api/character-creator/cities/:id/view - what the PLAYERS may see of a city.
//
// The G.M. may open it (to see what the table sees); anyone else only when the
// G.M. has shown the city's map, and otherwise it does not exist - a 404, as
// every hidden thing here is.
//
// BUILT, NOT FILTERED. This response is assembled field by field from the
// parts a player may see: the map's shapes and district names, the pins the
// G.M. revealed with the text the G.M. wrote FOR THE PLAYERS, and the
// districts' players' lines. Nothing else is read out of the city, so nothing
// else can reach a player - not an NPC, a secret, a hook, a rumour (true or
// false), an encounter, a stat block, a shop's owner or stock, the overview,
// or a pin the G.M. has not revealed. A new field added to the city later is
// invisible here until someone adds it on purpose. The regression suite reads
// this response as a player and fails if any G.M.-only text appears in it.

import { getUserEmail, unauthorized, json } from '../../_lib/auth.js';
import { cityAccess } from '../../_lib/city-access.js';

const pt = (p) => (Array.isArray(p) && p.length === 2 ? [Number(p[0]), Number(p[1])] : null);
const pts = (list) => (Array.isArray(list) ? list.map(pt).filter(Boolean) : []);

function playerView(row, city) {
  const m = city.map || {};
  const reveal = city.reveal || {};
  const pub = city.public || {};
  const text = (id) => (typeof pub[id] === 'string' && pub[id].trim() ? pub[id].trim() : null);
  return {
    id: row.id,
    campaign_id: row.campaign_id,
    name: String(city.overview?.name || row.name),
    map: {
      view: Array.isArray(m.view) ? m.view.map(Number) : null,
      size: Number(m.size) || 1000,
      outline: pts(m.outline),
      wall: m.wall ? pts(m.wall) : null,
      gates: m.wall ? pts(m.gates) : [],
      roads: Array.isArray(m.roads) ? m.roads.map(pts) : [],
      river: m.river ? pts(m.river) : null,
      // A theme's street plan: shapes only. The theme's words never come here.
      canals: Array.isArray(m.canals) ? m.canals.map(pts) : null,
      streets: Array.isArray(m.streets) ? m.streets.map(pts) : null,
      rail: m.rail ? pts(m.rail) : null,
      station: m.rail ? pt(m.station) : null,
      core: m.core ? pts(m.core) : null,
      districts: (Array.isArray(m.districts) ? m.districts : []).map((d) => ({
        id: String(d.id), name: String(d.name || ''), quarter: !!d.race,
        polygon: pts(d.polygon), label: pt(d.label), text: text(d.id),
      })),
    },
    // Revealed pins only, renumbered 1..n so the count of hidden ones does
    // not show through gaps in the numbering.
    pins: (Array.isArray(m.pins) ? m.pins : []).filter((p) => reveal[p.id] === true).map((p, i) => ({
      id: String(p.id), n: i + 1, kind: p.kind === 'shop' ? 'shop' : 'place',
      label: String(p.label || ''), district: String(p.district || ''), at: pt(p.at), text: text(p.id),
    })),
  };
}

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const a = await cityAccess(env, params.id, email);
  if (!a.found || (!a.isGm && !a.shown)) return json({ error: 'City not found' }, 404);
  let city;
  try { city = JSON.parse(a.row.data); } catch { return json({ error: 'This city cannot be read' }, 500); }
  return json({ city: playerView(a.row, city), is_gm: a.isGm });
}
