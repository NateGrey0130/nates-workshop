// POST /api/marvel-heroes/campaigns/:id/npcs/sweep - not in Marvel Heroes.
//
// The shared People view (shared/js/campaign/people.js) offers a sweep: Claude
// reads the notes nobody has swept and proposes the people nobody tagged. Nate
// decided on 2026-09-28 that Marvel does not have it: it would need two more
// tables (what has been swept, which names were dismissed) and a second paid
// call. The Marvel page hides the panel in its own CSS; this route exists so
// that anything which asks anyway gets a sentence rather than the site's
// landing page, which is what Pages serves for an unrouted path.

import { json } from '../../../_lib/campaigns.js';

export function onRequest() {
  return json({ error: 'Marvel Heroes has no sweep. Type @Name in a note to add someone to People.' }, 501);
}
