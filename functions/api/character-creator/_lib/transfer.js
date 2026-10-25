// A G.M. MOVES a character they own to a player - the rules both transfer
// routes share (characters/[id]/transfer.js, npc-library/[id]/transfer.js).
//
// Nate's rulings (2026-10-25): a move, not a copy; instant, with no accept
// step and no notification; only a character the G.M. owns, and only the G.M.;
// the notes are cleared, because a G.M.'s notes on a sheet may hold the
// campaign's secrets.
//
// WHO CAN RECEIVE ONE is the Workshop's closed list of people
// (functions/api/_lib/people.js), minus the caller. It is checked before the
// database is read at all, so an address that is not on it - or a deployment
// where the list is unset - is refused the same way whatever the id names.

import { looksLikeEmail, normalizeEmail, shareCandidates } from '../../_lib/people.js';
import { json } from './auth.js';

// The people a G.M. can hand a character to: the list, minus themself.
export function transferCandidates(env, email) {
  const self = normalizeEmail(email);
  return shareCandidates(env).filter((c) => c !== self);
}

// `{ res }` to refuse, or `{ to }`, the recipient as normalized. 400 for a
// body that names nobody or the caller, 403 for an address the list does not
// hold, with a message that says which knob is wrong when the list is unset.
export function checkRecipient(env, email, raw) {
  const to = normalizeEmail(raw);
  if (!looksLikeEmail(to)) return { res: json({ error: 'to_email is required' }, 400) };
  if (to === normalizeEmail(email)) return { res: json({ error: 'That is you' }, 400) };
  const candidates = shareCandidates(env);
  if (!candidates.includes(to)) {
    return { res: json({
      error: candidates.length
        ? 'That address cannot sign in to the Workshop, so it cannot be given a character. Ask Nate to add them first.'
        : 'Transfers are not configured on this deployment (MV_SHARE_CANDIDATES is unset)',
      code: 'not_a_candidate',
    }, 403) };
  }
  return { to };
}

// HOW THE OWNER IS SPELLED. `player_email` holds the Access header verbatim
// (getUserEmail stores what it is given) and every read compares it with `=`,
// so the recipient must be written the way THEIR requests will arrive, or the
// character is theirs and missing from their own list. The list holds only
// lowercased addresses; the spelling Access sends for this person is known
// only if they have been seen here before. So: the spelling already on a row
// they own or a campaign they run, and the lowercased address when they have
// never been seen, which is what Access sends for an ordinary address.
export async function ownerSpelling(env, to) {
  const seen = await env.DB.prepare(
    `SELECT player_email AS e FROM characters WHERE lower(player_email) = ? AND deleted_at IS NULL
     UNION ALL SELECT gm_email AS e FROM campaigns WHERE lower(gm_email) = ? AND deleted_at IS NULL LIMIT 1`
  ).bind(to, to).first();
  return seen?.e || to;
}

// The whole of the notes a transferred character arrives with.
export function transferNote(now = new Date()) {
  return `Transferred from the G.M. on ${now.toISOString().slice(0, 10)}.`;
}
