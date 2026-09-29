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
import { playerView } from '../../_lib/city-view.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const a = await cityAccess(env, params.id, email);
  if (!a.found || (!a.isGm && !a.shown)) return json({ error: 'City not found' }, 404);
  let city;
  try { city = JSON.parse(a.row.data); } catch { return json({ error: 'This city cannot be read' }, 500); }
  return json({ city: playerView(a.row, city), is_gm: a.isGm });
}
