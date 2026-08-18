// Dice evaluator — canonical module copy of the Phase 2 evaluator that lives
// inline in index.html's wizard script. Used server-side by the leveling
// endpoints. Handles "NdM", "NdMxK", "NdM+K", "NdMxK+K" (case/space tolerant).

export const d = (sides) => 1 + Math.floor(Math.random() * sides);

const DICE_EXPR = /^(\d+)\s*d\s*(\d+)(?:\s*x\s*(\d+))?(?:\s*([+-])\s*(\d+))?$/i;

export function evalDice(expr) {
  const m = String(expr).trim().match(DICE_EXPR);
  if (!m) return null;
  let total = 0;
  for (let i = 0; i < +m[1]; i++) total += d(+m[2]);
  if (m[3]) total *= +m[3];
  if (m[4]) total += (m[4] === '-' ? -1 : 1) * +m[5];
  return total;
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
function rollBonus(bonus) {
  if (bonus == null) return 0;
  if (Array.isArray(bonus)) return bonus.reduce((sum, b) => sum + rollBonus(b), 0);
  if (typeof bonus === 'number') return Number.isFinite(bonus) ? bonus : 0;
  const rolled = evalDice(bonus);
  return rolled == null ? 0 : rolled;
}

export function rollPoolFormula(expr, attrs = {}, bonus = null) {
  const base = rollPoolBase(expr, attrs);
  return base == null ? null : base + rollBonus(bonus);
}

function rollPoolBase(expr, attrs) {
  if (expr == null) return null;
  if (typeof expr === 'number') return expr;
  const s = String(expr).trim();

  // A clean expression on its own.
  const whole = evalDice(s);
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
    const rolled = evalDice(dice[0]);
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
