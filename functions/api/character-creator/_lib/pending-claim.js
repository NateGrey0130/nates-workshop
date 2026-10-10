// Spending banked picks without spending them twice.
//
// A banked-pick request reads the character and its unspent grants, works out
// what the picks cost, and then writes the character and marks grants spent in
// one batch. The batch is atomic, but nothing in it used to say "only if what I
// read is still true" - so two requests that read the same grants both wrote.
// The second overwrote the first one's picks on the character and took the
// allowance down a second time: one pick kept, two paid for. A double-clicked
// button is enough.
//
// level-confirm.js guards the same shape with LEVEL_GUARD, where the token is
// the character's level and its own UPDATE moves it. Here the token is the
// unspent grants themselves, read as three numbers that any spend and any new
// grant changes: how many rows, the sum of their ids, the sum of their counts.
//
// EVERY statement in the batch carries the guard, and the claim goes LAST as
// ONE statement. That ordering is the whole mechanism: nothing before the claim
// touches the pending table, so each earlier statement sees the grants exactly
// as the transaction found them, and the claim itself reads the token once
// before it changes a row. So the batch writes everything or nothing.

const TABLES = new Set(['pending_skill_picks', 'pending_power_picks']);

/** The token for a list of unspent grants, as listPending* returned them. */
export function pendingToken(pending) {
  const rows = pending || [];
  return `${rows.length}:${rows.reduce((n, g) => n + g.id, 0)}:${rows.reduce((n, g) => n + g.count, 0)}`;
}

/**
 * A guard for one batch: `sql` is a boolean expression to AND into a WHERE,
 * and `binds` are its two parameters, to be bound where it sits.
 */
export function pendingGuard(table, characterId, pending) {
  if (!TABLES.has(table)) throw new Error(`pendingGuard: unknown table ${table}`);
  return {
    sql: `(SELECT COUNT(*) || ':' || COALESCE(SUM(id), 0) || ':' || COALESCE(SUM(count), 0)
             FROM ${table} WHERE character_id = ? AND claimed_at IS NULL) = ?`,
    binds: [characterId, pendingToken(pending)],
  };
}

/**
 * The claim, as one guarded statement. `plan` is [{ id, left, claim }]: the count each
 * touched grant is left holding, and `claim` marks it spent. Null when the plan
 * touches nothing, so a caller can spread it.
 */
export function claimStatement(env, table, guard, plan) {
  const rows = (plan || []).filter((p) => Number.isInteger(p?.id) && Number.isInteger(p?.left) && p.left >= 0);
  if (!rows.length) return null;
  const marks = rows.map(() => '?').join(', ');
  const whens = rows.map(() => 'WHEN ? THEN ?').join(' ');
  const spentIds = rows.filter((p) => p.claim).map((p) => p.id);
  // `claimed_at` only for a grant spent to nothing: one partly spent stays
  // pending with its remainder, so two picks earned at one level can be taken
  // one at a time.
  const claimed = spentIds.length
    ? `CASE WHEN id IN (${spentIds.map(() => '?').join(', ')}) THEN datetime('now') ELSE claimed_at END`
    : 'claimed_at';
  return env.DB.prepare(
    `UPDATE ${table}
        SET count = CASE id ${whens} ELSE count END,
            claimed_at = ${claimed}
      WHERE id IN (${marks}) AND ${guard.sql}`
  ).bind(...rows.flatMap((p) => [p.id, p.left]), ...spentIds, ...rows.map((p) => p.id), ...guard.binds);
}

/** Did a guarded batch write? Every statement shares one guard, so any one answers. */
export function batchApplied(results) {
  return (results || []).some((r) => (r?.meta?.changes ?? 0) > 0);
}

export const STALE_PICKS = 'These picks were already spent, or the character changed while you were choosing. Reload and pick again.';
