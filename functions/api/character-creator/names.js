// GET /api/character-creator/names
//     ?theme=&kind=&gender=&shape=&count=&avoid=&avoid=
// Any signed-in user. Returns { names, exhausted, reason }.
//
// The campaign-free list, for the character wizard's name box: the same
// generator and the same parameters as campaigns/:id/names, with no campaign
// to exclude names from - a new character belongs to no table yet. Only the
// `avoid` names (the chips already on screen) are left out. `count` is clamped
// to 1-12.
//
// REFUSE, NEVER PAD, as the campaign list does: a theme with fewer names than
// asked for returns the ones it has, `exhausted: true` and a `reason`.
//
// Open to anyone signed in because it reads nothing but the word lists, which
// the browser could load itself; the campaign list is G.M.-only because it
// reads the campaign's hidden NPCs.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';
import { readNameQuery } from './_lib/names.js';
import { generateNames, NameGenError } from '../../../shared/js/namegen.js';

export async function onRequestGet({ request }) {
  if (!getUserEmail(request)) return unauthorized();
  const q = readNameQuery(request.url);
  if (!q.theme) return json({ error: 'theme is required' }, 400);
  try {
    return json(generateNames({ ...q, exclude: q.avoid }));
  } catch (e) {
    if (e instanceof NameGenError) return json({ error: e.message }, 400);
    throw e;
  }
}
