// GET /api/character-creator/transfer-candidates - { candidates }
//
// Who a G.M. can transfer a character to: the Workshop's closed list of
// people, minus the caller (_lib/transfer.js). Empty when the list is unset,
// so the picker offers nobody rather than anybody.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';
import { transferCandidates } from './_lib/transfer.js';

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  return json({ candidates: transferCandidates(env, email) });
}
