// GET /api/character-creator/campaigns/:id/names
//     ?theme=&kind=&gender=&shape=&count=&avoid=&avoid=
// G.M. only. Returns { names, exhausted, reason }.
//
// A list of names from one theme (shared/js/namegen.js) that this campaign does
// not already use - none of its dossiers, none of its characters or statted
// NPCs - and none of the `avoid` names, which are the chips already on the
// G.M.'s screen. `count` is clamped to 1-12.
//
// REFUSE, NEVER PAD: a theme with fewer unused names than asked for returns
// the ones it has, `exhausted: true` and a `reason` saying how many it has in
// all and how many were ruled out. It never repeats one and never borrows
// from another theme.
//
// G.M.-only because the exclusion reads the campaign's statted NPCs, which
// nobody else may learn exist (isHiddenNpc) - not even as a name a list skipped.

import { json, requireCampaign } from '../../_lib/auth.js';
import { usedNames, readNameQuery } from '../../_lib/names.js';
import { generateNames, NameGenError } from '../../../../../shared/js/namegen.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;

  const q = readNameQuery(request.url);
  if (!q.theme) return json({ error: 'theme is required' }, 400);
  const used = await usedNames(env, params.id);
  try {
    return json(generateNames({ ...q, exclude: [...used, ...q.avoid] }));
  } catch (e) {
    if (e instanceof NameGenError) return json({ error: e.message }, 400);
    throw e;
  }
}
