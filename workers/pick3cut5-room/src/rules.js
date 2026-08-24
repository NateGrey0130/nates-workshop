// The budget rules, as pure functions over numbers.
//
// Extracted from room.js so they can be tested without a Durable Object, a
// Worker runtime, or a socket. Everything here is arithmetic: no `this`, no
// game object, no I/O. `apps/pick3cut5/test/game.mjs` exercises every reachable
// state exhaustively, which is only possible because this file imports nothing.
//
// THE CLIENT HAS ITS OWN COPY. `soloForced()` in apps/pick3cut5/app.js
// reimplements `forcedChoice` because solo mode has no server to ask and the
// page loads classic scripts rather than modules. That duplication is the
// single most dangerous thing about this app's design — a divergence would be
// invisible until a solo player's budget failed to add up. The test extracts
// the client's function and proves the two agree across every reachable state,
// so the duplication is checked rather than merely commented on.

export const KEEPS = 3;
export const CUTS = 5;
export const ITEMS_PER_ROUND = 8;

/**
 * The choice a player has no say in, or null when they still have one.
 *
 * `remaining` INCLUDES the item currently on screen.
 *
 * The four rules exist so the arithmetic always lands on exactly 3 and 5:
 * running out of either resource forces the other, and holding exactly as many
 * of one as there are items left forces that one for the rest of the round.
 */
export function forcedChoice(keepsLeft, cutsLeft, remaining) {
  if (keepsLeft === 0) return 'cut';
  if (cutsLeft === 0) return 'keep';
  if (keepsLeft === remaining) return 'keep';
  if (cutsLeft === remaining) return 'cut';
  return null;
}

/** Items still to play, including the one on screen. */
export function itemsRemaining(itemIndex) {
  return ITEMS_PER_ROUND - itemIndex;
}

/**
 * Whether a budget pair can still be spent exactly across the items left.
 *
 * Not used on the request path — it is the invariant the test asserts after
 * every simulated pick, and the reason a swap must refund rather than simply
 * clear a pick. A state that fails this can never land on 3 and 5.
 */
export function budgetIsSpendable(keepsLeft, cutsLeft, remaining) {
  return keepsLeft >= 0 && cutsLeft >= 0 && keepsLeft + cutsLeft === remaining;
}
