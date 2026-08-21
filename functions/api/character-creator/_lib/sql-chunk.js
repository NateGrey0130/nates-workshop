// D1 accepts exactly 100 bound parameters per statement. Not 999, not 32766 -
// one hundred, measured against the real binding:
//
//   binds  100  ok
//   binds  101  FAIL: D1_ERROR: too many SQL variables at offset 221
//
// A query building `IN (?,?,...)` from a list therefore has a hard ceiling on
// how long that list may be, and a list that grows with user data will cross it
// eventually. Four files already carried a private `LOOKUP_BATCH = 50` for this
// reason; the ones that did not are where it broke.
//
// The failure is nastier than a plain error. `markConfirmed` runs AFTER the
// catalog write has already succeeded, so blowing the limit there left 108
// spells inserted, none of them marked confirmed, and a 500 that read as though
// nothing had happened at all. The write and the bookkeeping disagreed, and the
// bookkeeping is what the next run reads.
export const D1_MAX_BINDS = 100;

// Room for a statement to bind a few values of its own alongside the list -
// a campaign id, a system, a sentinel row - without approaching the ceiling.
export const BIND_CHUNK = 50;

/**
 * Splits `items` into arrays of at most `size`. Always returns at least one
 * chunk for a non-empty input, and none for an empty one, so a caller can
 * `for (const chunk of chunks(...))` without a length check first.
 */
export function chunks(items, size = BIND_CHUNK) {
  const list = Array.isArray(items) ? items : [...items];
  if (!list.length) return [];
  const n = Math.max(1, Math.min(size, D1_MAX_BINDS));
  const out = [];
  for (let i = 0; i < list.length; i += n) out.push(list.slice(i, i + n));
  return out;
}

/**
 * Runs one `IN (...)` query per chunk and concatenates the rows.
 *
 * `build(chunk)` returns a prepared, bound statement. Chunks run in sequence
 * rather than through `DB.batch`, because a read split across chunks has no
 * atomicity to preserve and sequential keeps the failure mode simple.
 */
export async function selectInChunks(items, build, size = BIND_CHUNK) {
  const out = [];
  for (const chunk of chunks(items, size)) {
    const { results } = await build(chunk).all();
    if (results?.length) out.push(...results);
  }
  return out;
}
