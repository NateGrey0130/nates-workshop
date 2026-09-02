// Dice evaluator — canonical module copy of the Phase 2 evaluator that lives
// inline in index.html's wizard script. Used server-side by the leveling
// endpoints. Handles "NdM", "NdMxK", "NdM+K", "NdMxK+K" (case/space tolerant).

export const d = (sides) => 1 + Math.floor(Math.random() * sides);

const DICE_EXPR = /^(\d+)\s*d\s*(\d+)(?:\s*x\s*(\d+))?(?:\s*([+-])\s*(\d+))?$/i;

// A FIXED value, which is not a roll at all (BOOK-INGEST-AUDIT.md F8).
//
// The Naruni Repo-Bot's chassis has "a P.S. of 50, P.P. 26" — the same figures
// for every unit ever built — and `attribute_dice` looks like the field for
// them and was not. A bare integer matched no grammar here, so it fell through
// to the human default AND had its notation rewritten: measured before this
// went in, `rollAttribute("50")` returned 9 and reported `"3d6"`. One published
// class was already carrying it — the Holy Terror's `PS: "50"` from Wormwood,
// which had a human's strength from import with every check calling it ready.
//
// Kept as its own constant rather than folded into DICE_EXPR as an alternative,
// which is what F8 sketched: an alternation there shifts every capture-group
// index in three functions, to express a thing that has no dice, no multiplier
// and no modifier. The BEHAVIOUR is exactly what was proposed — accept it,
// return it unchanged, and report the real notation.
const FIXED_EXPR = /^(\d+)$/;

// The number a fixed expression states, or null when it is not one. Internal:
// callers outside this module ask isAttributeExpr instead.
function fixedValue(expr) {
  const m = String(expr ?? '').trim().match(FIXED_EXPR);
  return m ? +m[1] : null;
}

// An attribute the creature DOES NOT HAVE (BOOK-INGEST-AUDIT.md F5).
//
// The Machine People are living machines with no constitution, so their book
// prints "P.E. N/A"; the Pleasurer wears whatever face its client wants, so its
// beauty is "P.B. N/A". `attribute_dice` had no way to say that. Omitting the
// key and writing a number produce the SAME character - `app.js` resolves a
// missing entry as `3d6` - so the sheet showed a constitution and a beauty
// score the books deny.
//
// This is not "zero" and not "unknown". It is the statement that the axis does
// not apply, and the value that carries it is null: the sheet already renders a
// dash for a null attribute, and the server already treats a required attribute
// that is null as a VIOLATION rather than a pass. Both of those were true
// before this went in; the only thing missing was a way to produce the null.
const ABSENT_EXPR = /^N\/A$/i;

// Does this say the attribute does not exist?
export function isAbsentAttribute(expr) {
  return ABSENT_EXPR.test(String(expr ?? '').trim());
}

// Does this parse as ANY of the three grammars? `class-check` asks, because a
// value parsing as none of them is the silent failure F8 is about.
export function isAttributeExpr(expr) {
  const s = String(expr ?? '').trim();
  return DICE_EXPR.test(s) || FIXED_EXPR.test(s) || ABSENT_EXPR.test(s);
}

// One parse path for a roll and for its bounds. `die(sides)` supplies each
// die's value, so the same walk that rolls also answers "what is the least or
// most this expression can come up" — two implementations of the grammar would
// drift, and a bounds check that disagrees with the roll it bounds is worse
// than none.
//
// A fixed value is its own floor and ceiling, so it needs no `die` at all.
function evalDiceWith(expr, die) {
  const fixed = fixedValue(expr);
  if (fixed !== null) return fixed;
  const m = String(expr).trim().match(DICE_EXPR);
  if (!m) return null;
  let total = 0;
  for (let i = 0; i < +m[1]; i++) total += die(+m[2]);
  if (m[3]) total *= +m[3];
  if (m[4]) total += (m[4] === '-' ? -1 : 1) * +m[5];
  return total;
}

const MIN_DIE = () => 1;
const MAX_DIE = (sides) => sides;

export function evalDice(expr) {
  return evalDiceWith(expr, d);
}

// The least and most a dice expression can produce, or null when it is not
// one. Exact, not sampled: every die shows 1, or every die shows its sides.
export function diceBounds(expr) {
  const min = evalDiceWith(expr, MIN_DIE);
  return min == null ? null : { min, max: evalDiceWith(expr, MAX_DIE) };
}

// A book quantity is usually a number, occasionally a roll — the Priest of
// Light starts with 1D6 vials of holy water. Rolled ONCE at character creation
// and stored as the rolled number, the same discipline as pools and attribute
// bonuses: re-rolling on every render would change the character's gear each
// time the page painted. Anything unreadable is one item rather than zero,
// because the class named the item on purpose.
export function rollQuantity(qty) {
  if (typeof qty === 'number' && Number.isFinite(qty)) return Math.max(1, Math.floor(qty));
  if (typeof qty === 'string') {
    const rolled = evalDice(qty);
    if (rolled != null) return Math.max(1, rolled);
  }
  return 1;
}

// ─── exceptional attribute rolls ───
//
// Palladium Fantasy RPG 2nd Ed., p.14. An attribute rolled on 3D6 that comes up
// 16, 17 or 18 earns one extra 1D6. If that die is a six it earns ONE more, and
// the chain stops there however the second lands — "even if this last roll is a
// six, the player does not roll again". An attribute rolled on 2D6 earns its
// extra die on a 12.
//
// Nothing else qualifies. 4D6, 5D6 and 6D6 are excluded by name, however high
// they roll, and the book says nothing about other pools — so they get nothing
// rather than an invented threshold.
const EXCEPTIONAL_AT = { 2: 12, 3: 16 };

// The threshold is read on the DICE, before any flat racial bonus. A race
// written as 3D6+6 is exceptional when its dice show 16, not when the total
// reaches 16 — otherwise a below-average roll of 10 would earn the reward the
// rule reserves for the top of the range.
//
// Returns the parts rather than a bare number so the wizard can show its work:
// an unexplained 24 from a 3d6 looks like a bug, and the chained second die
// looks like one even when it is right.
export function rollAttribute(expr) {
  const s = String(expr ?? '').trim() || '3d6';
  // An attribute the creature does not have is NULL, and this is the one input
  // for which falling back to 3d6 is wrong rather than merely unhelpful (F5).
  // Callers must handle it: `app.js` is the only one in the app, and it stores
  // the null rather than a rolled ten.
  if (isAbsentAttribute(s)) return null;
  // A FIXED value is not rolled and earns no exceptional die: a chassis with a
  // P.S. of 50 has a P.S. of 50. The notation reported is the value itself,
  // which is the half of F8 that made the old behaviour silent — the wizard's
  // re-roll button used to read `(3d6)` beside a number the class never stated.
  const fixed = fixedValue(s);
  if (fixed !== null) {
    return { notation: s, base: fixed, modifier: 0, exceptional: [], total: fixed };
  }
  const m = s.match(DICE_EXPR);
  // An unparseable expression is not a reason to leave the attribute empty;
  // fall back to the human default rather than returning null.
  if (!m) return rollAttribute('3d6');

  const count = +m[1], sides = +m[2];
  const multiplier = m[3] ? +m[3] : 1;
  const modifier = m[4] ? (m[4] === '-' ? -1 : 1) * +m[5] : 0;

  let base = 0;
  for (let i = 0; i < count; i++) base += d(sides);
  base *= multiplier;

  // Only the two six-sided pools the book names, and only when nothing has been
  // multiplied in — a multiplied pool is a hit-point formula, not an attribute.
  const threshold = sides === 6 && multiplier === 1 ? EXCEPTIONAL_AT[count] : undefined;
  const exceptional = [];
  if (threshold !== undefined && base >= threshold) {
    exceptional.push(d(6));
    if (exceptional[0] === 6) exceptional.push(d(6));
  }

  return {
    notation: s,
    base,
    modifier,
    exceptional,
    total: base + modifier + exceptional.reduce((a, b) => a + b, 0),
  };
}

// A pool's starting value from its class formula.
//
// Books write these three ways: a dice expression ("1d4x100"), a plain number
// (20), or an attribute plus dice ("P.E. + 1d6 per level"). The last is why
// this takes `attrs` — hit points start from P.E., and nothing else in here
// knows that.
//
// Lives beside evalDice rather than in the wizard because the server rolls the
// same formulas when a character changes to another variant of its class, and
// two implementations of "what does this class start with" would drift.
// One dice expression: 3d6, 2D4x10, 4d6x100+200.
const DICE_RE = /\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?/i;
// The attribute a formula can add in. Books write both orders, and spell the
// attribute with or without full stops.
const ATTR_RE = /\b(IQ|ME|MA|PS|PP|PE|PB|Spd)\b|\b([IMPS])\.\s*([QEASPB])\./i;

// A multiplier the book attaches to the attribute itself — "M.D.C.: P.E. x 10",
// "S.D.C.: P.E. x 12", "Hit Points: P.E. x 3 plus 2D6 per level". Supernatural
// and mega-damage races state their pools this way as a matter of course, and
// without this the multiplier was silently dropped: a Godling written
// "P.E. x 3 plus 2D6 per level" rolled P.E. + 2D6, a third of the right number
// and entirely plausible-looking.
//
// Anchored to the text IMMEDIATELY after the attribute, because an `x N`
// anywhere else belongs to the dice: in "M.E. number plus 1D6x10" the x10
// multiplies the die. Only "number" and "attribute" may sit between, since
// books write "P.E. number x 10" as readily as "P.E. x 10".
const ATTR_MULT_RE = /^\s*(?:number|attribute)?\s*[x×*]\s*(\d+)/i;

// The attribute term of a formula: the attribute's value, times whatever the
// book multiplies it by. Null when the formula names no attribute, or names one
// the character does not have a number for.
function attrIn(text, attrs) {
  const m = ATTR_RE.exec(text);
  if (!m) return null;
  const key = (m[1] || (m[2] + m[3])).replace(/\./g, '').toUpperCase();
  const canon = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'SPD']
    .find((k) => k === (key === 'SPD' ? 'SPD' : key));
  if (!canon) return null;
  const v = attrs[canon === 'SPD' ? 'Spd' : canon];
  if (typeof v !== 'number') return null;
  const mult = ATTR_MULT_RE.exec(text.slice(m.index + m[0].length));
  return mult ? v * +mult[1] : v;
}

// `bonus` is what the CLASS adds on top — `bonuses.pools.ppe`, a number, a dice
// expression, or a list of either once two classes have been composed. It is
// rolled here rather than at render time because the result is stored as the
// character's `*_max`; re-evaluating it every render would move their maximum.
//
// A null base stays null even with a bonus. "A pool the race does not mention
// falls through to the occupation", and if neither states one the character
// simply does not have that pool — a bonus must not conjure it into existence.
// That is the same rule that keeps an M.D.C. race from acquiring hit points.
function bonusWith(bonus, die) {
  if (bonus == null) return 0;
  if (Array.isArray(bonus)) return bonus.reduce((sum, b) => sum + bonusWith(b, die), 0);
  if (typeof bonus === 'number') return Number.isFinite(bonus) ? bonus : 0;
  const rolled = evalDiceWith(bonus, die);
  return rolled == null ? 0 : rolled;
}

export function rollPoolFormula(expr, attrs = {}, bonus = null) {
  const base = poolBaseWith(expr, attrs, d);
  return base == null ? null : base + bonusWith(bonus, d);
}

// The range a pool formula can legitimately produce — { min, max }, or null
// when the formula cannot be read (an unreadable formula is a note, not a
// bound). The same walk rollPoolFormula takes, with every die pinned to its
// floor or its ceiling, so the bounds and the roll cannot disagree about what
// the formula means.
export function poolFormulaBounds(expr, attrs = {}, bonus = null) {
  const min = poolBaseWith(expr, attrs, MIN_DIE);
  if (min == null) return null;
  return {
    min: min + bonusWith(bonus, MIN_DIE),
    max: poolBaseWith(expr, attrs, MAX_DIE) + bonusWith(bonus, MAX_DIE),
  };
}
// A formula's value when - and ONLY when - it cannot vary.
//
// Everything else that reads a formula here rolls it ONCE and stores the
// result, because re-evaluating on every render moves the number: pools store
// `*_max`, gear stores its rolled quantity, and both carry a comment saying so.
// A trackable resource has nowhere to store a roll - there is no column for it
// and deliberately so - which makes rolling its max at render time the one
// thing this must not do. A Juicer would open the sheet with three doses and
// reload with five.
//
// So resolve only what has no dice in it. poolFormulaBounds already walks the
// grammar twice, pinning every die to its floor and then to its ceiling, so
// `min === max` IS the statement 'there are no dice here' - an attribute
// expression like `PE`, `P.E. x 10`, or a plain number. It is not a second
// reading of the grammar that could disagree with the first.
//
// Null for anything with a die in it, and for anything unreadable. Both are
// shown as written, which is what the sheet did with all of them before.
export function fixedFormulaValue(expr, attrs = {}) {
  const b = poolFormulaBounds(expr, attrs);
  return b && b.min === b.max ? b.min : null;
}

function poolBaseWith(expr, attrs, die) {
  if (expr == null) return null;
  if (typeof expr === 'number') return expr;
  const s = String(expr).trim();

  // A clean expression on its own.
  const whole = evalDiceWith(s, die);
  if (whole != null) return whole;

  // Dice plus an attribute, in either order — "P.E. + 1d6 per level" and
  // "2D4x100+200 plus P.E. attribute number" are the same statement, and books
  // use both. Without the second, every class written that way rolled NULL and
  // the character was created with no pool at all.
  const dice = DICE_RE.exec(s);
  const bonus = attrIn(s, attrs);

  // An attribute alone is a whole formula, not a fragment of one: "M.D.C.:
  // P.E. x 10" states the pool completely and has no dice to find.
  if (!dice) {
    if (bonus != null) return bonus;
    const only = Number(s);
    return Number.isFinite(only) ? only : null;
  }

  {
    const rolled = evalDiceWith(dice[0], die);
    if (rolled != null) {
      if (bonus != null) return rolled + bonus;
      // Dice buried in prose: books qualify these heavily ("3D4x100+1000 when in
      // serpent form, only 3D4x100 in humanoid form"). Take the leading figure,
      // which is the one the entry leads with, and leave the qualification to
      // the prose that carries it.
      if (s.search(DICE_RE) === 0) return rolled;
    }
  }

  const n = Number(s);
  return Number.isFinite(n) ? n : null;
}

// The most an attribute roll can legitimately come up, exceptional dice
// included — the ceiling the audit warns above, never a value anything blocks
// on. Null when the dice cannot be read, because a ceiling that was guessed
// would flag numbers a table approved.
//
// Mirrors rollAttribute's own rules: only a plain 2d6 or 3d6 earns the
// exceptional chain, and the chain is at most two extra six-sided dice.
export function attributeCeiling(expr) {
  const s = String(expr ?? '').trim() || '3d6';
  // An attribute that does not exist has no ceiling to exceed. Null here means
  // "no opinion", which is what the caller already does nothing with.
  if (isAbsentAttribute(s)) return null;
  // A fixed value is its own ceiling, and this is a real gain rather than
  // bookkeeping: `"50"` used to return null, so the server-side
  // attribute_above_ceiling check skipped the one class already carrying a
  // fixed attribute entirely. It now has a ceiling like every other class.
  const fixed = fixedValue(s);
  if (fixed !== null) return fixed;
  const m = s.match(DICE_EXPR);
  if (!m) return null;
  const count = +m[1], sides = +m[2];
  const multiplier = m[3] ? +m[3] : 1;
  const modifier = m[4] ? (m[4] === '-' ? -1 : 1) * +m[5] : 0;
  const exceptional = sides === 6 && multiplier === 1 && EXCEPTIONAL_AT[count] !== undefined ? 12 : 0;
  return count * sides * multiplier + modifier + exceptional;
}


// The sheet is a plain-script page and cannot import a module; its play-mode
// weapon cards read this mirror, installed by the <script type="module"> tag
// sheet.html loads - the language-skills.js precedent. Harmless server-side.
globalThis.diceRoll = { d, evalDice, fixedFormulaValue };