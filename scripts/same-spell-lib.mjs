// Comparing a spell to the row it is a RETELLING of.
//
// BOOK-INGEST-AUDIT.md F26. `spells.same_spell_as` links a row to the one
// another book already published it as - `Ocean: Whirlpool` to
// `Water: Whirlpool`. The point of the link is that the pair can be CHECKED,
// because `drift-check` cannot: it compares a row to its cited page, and both
// rows cite pages that agree with them. Only comparing the two rows to EACH
// OTHER finds the drift.
//
// WHAT THE FINDING PROPOSED, AND WHY IT IS NOT WHAT IS BUILT. F26 asked for an
// assertion that two linked rows "keep matching on range, duration,
// saving_throw, area_of_effect and description, and differ only on level, ppe
// and source_book". Taken literally that check fails on day one, and it took
// reading all ten candidate pairs rather than the one the finding sampled to
// see why. Two separate reasons:
//
//   * THE PROSE IS NOT THE SAME PROSE. The two books describe the same spell in
//     their own words - "per level of the Warlock" against "per level of
//     experience", "the caster" against "the spell caster" - and neither
//     spelling is wrong. An exact comparison on `range` rejects every pair.
//   * FOUR OF THE TEN ARE GENUINELY DIFFERENT SPELLS sharing a name. Ocean:
//     Calm Waters covers a mile per level for an hour; Water: Calm Waters
//     covers eighty feet per level for thirty minutes. Those are not a
//     transcription difference and must NOT be linked - which is why six pairs
//     carry the link and four do not.
//
// So the comparison is on the NUMBERS, which is where the mechanics live and
// where the two printings genuinely have to agree.
//
// TWO NORMALISATIONS, each of which a real pair needed:
//
//   * PARENTHESES ARE DROPPED before numbers are read. `Ocean: Whirlpool` gives
//     its radius as 36.5 m and `Water: Whirlpool` as 36.6 m - both converting
//     120 feet, rounded differently - and Water's duration carries a
//     "(4 melee rounds)" gloss Ocean's does not. Metric conversions and
//     parenthetical glosses are not mechanics, and comparing them rejects a
//     pair the finding itself verified line by line off the page.
//   * NUMBER WORDS BECOME DIGITS. One book prints "Ten minutes per level" and
//     the other "10 minutes per level". Same duration, two spellings.
//
// The description is NOT compared exactly, and not ignored either. Two
// paraphrases of two printings are never byte-identical - across the six linked
// pairs the longer description runs 1.12 to 2.03 times the shorter - so an
// exact check fails immediately and no check at all misses the gutting this is
// meant to catch. A floor on shared vocabulary and on the length ratio is the
// honest middle: the six linked pairs share 0.53 to 0.69 of their words, so a
// floor of 0.35 passes all six with room and still catches a description
// replaced, emptied, or overwritten with a different spell's text.

const WORDS = {
  one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9,
  ten: 10, eleven: 11, twelve: 12, fifteen: 15, twenty: 20, thirty: 30, forty: 40,
  fifty: 50, sixty: 60, seventy: 70, eighty: 80, ninety: 90, hundred: 100, thousand: 1000,
};

/** Every number a field states as MECHANICS, sorted, as a comparable string. */
export function mechanicalNumbers(value) {
  if (value === null || value === undefined) return '';
  let t = String(value).toLowerCase().replace(/\([^)]*\)/g, ' ');
  for (const [word, n] of Object.entries(WORDS)) {
    t = t.replace(new RegExp(`\\b${word}\\b`, 'g'), String(n));
  }
  const found = (t.match(/\d+(?:\.\d+)?/g) || []).map(Number);
  return found.sort((a, b) => a - b).join(',');
}

const significantWords = (s) =>
  new Set(String(s ?? '').toLowerCase().match(/[a-z]{4,}/g) || []);

/** Shared vocabulary as a fraction of the SHORTER description, 0 to 1. */
export function descriptionOverlap(a, b) {
  const A = significantWords(a);
  const B = significantWords(b);
  if (!A.size || !B.size) return 0;
  let hit = 0;
  for (const w of A) if (B.has(w)) hit += 1;
  return hit / Math.min(A.size, B.size);
}

// Not exported: nothing outside this file has a use for them, and an export
// nothing imports is a promise to a caller that does not exist.
const COMPARED_FIELDS = ['range', 'duration', 'saving_throw', 'area_of_effect'];
const MIN_DESCRIPTION_OVERLAP = 0.35;   // the six linked pairs score 0.53 to 0.69
const MAX_LENGTH_RATIO = 3;             // and run 1.12 to 2.03 times each other

/**
 * `retelling` against the `established` row it names. Returns the problems
 * found, so an empty array is a pair that agrees.
 */
export function comparePair(retelling, established) {
  const problems = [];
  for (const f of COMPARED_FIELDS) {
    const a = mechanicalNumbers(retelling?.[f]);
    const b = mechanicalNumbers(established?.[f]);
    if (a !== b) problems.push(`${f}: ${a || '(none)'} vs ${b || '(none)'}`);
  }

  const da = String(retelling?.description ?? '');
  const db = String(established?.description ?? '');
  if (!da.length || !db.length) {
    problems.push('description: one side is empty');
  } else {
    const overlap = descriptionOverlap(da, db);
    if (overlap < MIN_DESCRIPTION_OVERLAP) {
      problems.push(`description: only ${overlap.toFixed(2)} shared vocabulary`);
    }
    const ratio = Math.max(da.length, db.length) / Math.min(da.length, db.length);
    if (ratio > MAX_LENGTH_RATIO) {
      problems.push(`description: one is ${ratio.toFixed(1)}x the length of the other`);
    }
  }

  // NOT a problem, and this was nearly written as one. F26 is titled "one
  // spell, two traditions, TWO COSTS", so the first version of this check
  // required a linked pair to differ on level or ppe - and two of the six
  // linked pairs failed it immediately. `Sense Direction Underwater` is level 1
  // for 4 P.P.E. in both books and `Speak Underwater` is level 4 for 10 in
  // both; the finding's own table shows those two matching, so its title
  // generalises from the seven of its nine that do differ. The link asserts
  // THE SAME SPELL. A price difference is the common case, never the
  // requirement, and four of the six linked pairs have one.
  return problems;
}
