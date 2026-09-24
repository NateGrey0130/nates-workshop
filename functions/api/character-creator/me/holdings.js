// GET /api/character-creator/me/holdings — which of the CALLER'S OWN characters
// hold what, keyed the way the codex keys its entries, so an entry can say
// "Your characters with this: Kevik, Ash" and link to their sheets.
//
// ONE REQUEST FOR THE WHOLE CODEX, not one per entry. A player holds a few
// characters and each holds a few dozen things, so the whole map is small,
// and the codex asks for it once when it loads rather than once for every row
// somebody opens.
//
// THE CALLER'S OWN, AND NOTHING ELSE. `player_email = caller AND kind = 'pc'`
// is the whole scope - the same rule as `characters?mine=1`, "the characters
// the caller PLAYS". Not the campaign's other players, whose sheets are
// readable elsewhere but whose inventories this page has no reason to list;
// and not a G.M.'s statted NPCs, which nobody plays. The email is the ONLY
// value bound into these queries - nothing in the request can widen them,
// which is why the route takes no parameters at all. regression.mjs asks as a
// second person and checks nothing of the first person's comes back.
//
// Keys, per codex section (apps/codex/codex.js SECTIONS `key`):
//   skills, spells, psionics, super-abilities, talents  -> lower-cased name
//   gear, vehicles                                      -> slug
//   classes                                             -> class id (the slug)
// The sheet links INTO the codex by the same rule (sheet.js codexLink).

import { getUserEmail, unauthorized, json } from '../_lib/auth.js';

const POWER_SECTION = { spell: 'spells', psionic: 'psionics', super: 'super-abilities', talent: 'talents' };

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const OWN = "c.player_email = ? AND c.kind = 'pc'";
  const [chars, items, vessels] = await env.DB.batch([
    env.DB.prepare(`SELECT c.id, c.name, c.class_id, c.occ_class_id, c.skills, c.powers
                      FROM characters c WHERE ${OWN} ORDER BY c.name`).bind(email),
    env.DB.prepare(`SELECT DISTINCT ci.character_id, ci.gear_slug FROM character_items ci
                      JOIN characters c ON c.id = ci.character_id
                     WHERE ${OWN} AND ci.removed_at IS NULL AND ci.gear_slug IS NOT NULL`).bind(email),
    env.DB.prepare(`SELECT DISTINCT cv.character_id, cv.vehicle_slug FROM character_vehicles cv
                      JOIN characters c ON c.id = cv.character_id
                     WHERE ${OWN} AND cv.removed_at IS NULL AND cv.vehicle_slug IS NOT NULL`).bind(email),
  ]);

  const holds = {};
  const add = (section, key, id) => {
    if (!section || key == null || String(key).trim() === '') return;
    const k = String(key).toLowerCase();
    const bucket = (holds[section] ||= {});
    const list = (bucket[k] ||= []);
    if (!list.includes(id)) list.push(id);
  };
  const parse = (s) => { try { const v = JSON.parse(s || '[]'); return Array.isArray(v) ? v : []; } catch { return []; } };

  const characters = [];
  for (const c of chars.results || []) {
    characters.push({ id: c.id, name: c.name });
    add('classes', c.class_id, c.id);
    add('classes', c.occ_class_id, c.id);
    for (const s of parse(c.skills)) add('skills', s?.name, c.id);
    for (const p of parse(c.powers)) add(POWER_SECTION[p?.type] || null, p?.name, c.id);
  }
  for (const r of items.results || []) add('gear', r.gear_slug, r.character_id);
  for (const r of vessels.results || []) add('vehicles', r.vehicle_slug, r.character_id);

  return json({ characters, holds });
}
