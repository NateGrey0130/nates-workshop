// A skill whose starting percentage is derived from an attribute.
//
// BOOK-INGEST-AUDIT.md F2. Phase World printed 150 defines Zero Gravity
// Movement & Combat as "the character's P.P. attribute number x5%, plus 4% per
// level". `per_level` holds the 4. `base` is an INTEGER and could not hold the
// rest, so the row shipped at 0 with the formula in its `note` — where a reader
// finds it and no code does.
//
// Storing 0 was worse than lossy, it was AMBIGUOUS: the schema comment on
// `base` reads *0 = non-percentile (W.P.s, hand to hand)*, so a skill a book
// starts near 50% was indistinguishable from a weapon proficiency.
//
// THE GRAMMAR IS DELIBERATELY ONE SHAPE: an attribute token, `*`, an integer.
// That is what F2 proposed and it is all one row needs. A wider expression
// language would be a guess about books this catalog does not hold yet, and F2
// makes the same argument in the other direction — a second occurrence is a
// better trigger for more than this finding is.

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];

// `PP*5`, `PE * 3`, `Spd*2`. Case-insensitive on the attribute, space-tolerant
// around the operator, because a data script is written by hand.
const FORMULA = new RegExp(`^\\s*(${ATTRS.join('|')})\\s*\\*\\s*(\\d+)\\s*$`, 'i');

/** Does this parse as a base formula? Used by the import checker. */
export function isBaseFormula(expr) {
  return FORMULA.test(String(expr ?? ''));
}

/**
 * The percentage a formula yields for these attributes, or null. Internal:
 * callers outside this module want skillBase(), which also knows the fallback.
 *
 * Null when the formula is absent, unreadable, or names an attribute the
 * character does not have — the last being real since F5, where a creature can
 * legitimately have no P.E. at all. A null means "no opinion", and the caller
 * falls back to `base`, which is the same thing every pre-F2 row does.
 */
function skillBaseFrom(formula, attrs = {}) {
  const m = FORMULA.exec(String(formula ?? ''));
  if (!m) return null;
  const attr = ATTRS.find((a) => a.toLowerCase() === m[1].toLowerCase());
  const v = Number(attrs?.[attr]);
  if (!Number.isFinite(v)) return null;
  return Math.round(v * Number(m[2]));
}

/**
 * The starting percentage for a catalog skill row: the formula when it has one
 * and the attributes can satisfy it, otherwise the stored `base`.
 *
 * This is the ONLY place the two are chosen between, so a caller cannot read
 * one and forget the other.
 */
export function skillBase(row, attrs = {}) {
  const derived = skillBaseFrom(row?.base_formula, attrs);
  return derived == null ? (row?.base ?? 0) : derived;
}
