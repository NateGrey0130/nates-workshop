// Moving a character to another player: who it may go to, and what it loses on
// the way. Pure, so apps/marvel-heroes/test/smoke.mjs can run it.
//
// Nate's rulings (2026-10-25): a MOVE, not a copy; instant, with no accept step
// and no notification; only what the caller owns (a hero of their own, or an NPC
// sheet in a campaign they GM); and the notes are cleared, because a GM's notes
// on a character may be the plot. The People dossier is not part of a character
// and stays with the GM.
//
// The recipient must be on the Access allowlist's mirror (_lib/people.js), so a
// character can never go to an address that cannot sign in to see it. An unset
// list is nobody, as it is for MediaVault's sharing.

import { looksLikeEmail, normalizeEmail, shareCandidates } from '../../_lib/people.js';

// The people the caller can hand a character to: everyone on the list but
// themselves.
export function transferCandidates(env, caller) {
  const me = normalizeEmail(caller);
  return shareCandidates(env).filter((e) => e !== me);
}

// -> { email } (normalized) or { error, status }.
export function transferRecipient(env, caller, to) {
  const list = shareCandidates(env);
  if (!list.length) return { status: 503, error: 'Transfers are not set up here: the list of people who can sign in is empty' };
  const email = normalizeEmail(to);
  if (!looksLikeEmail(email)) return { status: 400, error: 'to_email must be an email address' };
  if (email === normalizeEmail(caller)) return { status: 400, error: 'That is you; pick someone else' };
  if (!list.includes(email)) return { status: 403, error: 'That address is not someone who can sign in to the Workshop' };
  return { email };
}

// The sheet fields a transfer clears, as SQL over a JSON column. `notes` is the
// one free-text field written for its owner alone (_lib/heroes.js SHEET_FIELDS);
// background, identity and the rest describe the character to anyone holding it.
const CLEARED_FIELDS = ['notes'];
export const clearedSheetSql = (col) => `json_remove(${col}, ${CLEARED_FIELDS.map((f) => `'$.${f}'`).join(', ')})`;
