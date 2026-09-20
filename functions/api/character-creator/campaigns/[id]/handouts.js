// GET /api/character-creator/campaigns/:id/handouts — what the party has been
// shown. Members only, and REVEALED IMAGES ONLY, for everyone including the GM.
//
// This is the player-facing face of migration 078, and it returns exactly two
// things per picture: its id, so the image endpoint can be asked for the bytes,
// and its caption. No entry id, no title, no body - the page behind a handout
// is the GM's notebook and stays there. That is Nate's rule for this feature
// and this endpoint is where it is enforced rather than described.
//
// The GM gets the same list on purpose: it answers "what do they already have",
// which is a different question from "what have I got", and the GM's own view
// of everything is entries.js.

import { json, requireCampaign } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }

  const { limit, offset } = paging(request);
  // Newest first: a handout is shown at a moment, and the one from tonight is
  // the one being looked for.
  const page = await pagedQuery(env, {
    countSql: 'SELECT count(*) AS n FROM campaign_images WHERE campaign_id = ? AND revealed_at IS NOT NULL',
    countBinds: [params.id],
    rowsSql: `SELECT id, caption, content_type, revealed_at
                FROM campaign_images
               WHERE campaign_id = ? AND revealed_at IS NOT NULL
               ORDER BY revealed_at DESC, id DESC`,
    rowsBinds: [params.id],
    limit, offset,
  });
  return json(pageBody('handouts', page));
}
