// Dice evaluator — canonical module copy of the Phase 2 evaluator that lives
// inline in index.html's wizard script. Used server-side by the leveling
// endpoints. Handles "NdM", "NdMxK", "NdM+K", "NdMxK+K" (case/space tolerant).

export const d = (sides) => 1 + Math.floor(Math.random() * sides);

export function evalDice(expr) {
  const m = String(expr).trim().match(/^(\d+)\s*d\s*(\d+)(?:\s*x\s*(\d+))?(?:\s*([+-])\s*(\d+))?$/i);
  if (!m) return null;
  let total = 0;
  for (let i = 0; i < +m[1]; i++) total += d(+m[2]);
  if (m[3]) total *= +m[3];
  if (m[4]) total += (m[4] === '-' ? -1 : 1) * +m[5];
  return total;
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

function attrIn(text, attrs) {
  const m = ATTR_RE.exec(text);
  if (!m) return null;
  const key = (m[1] || (m[2] + m[3])).replace(/\./g, '').toUpperCase();
  const canon = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'SPD']
    .find((k) => k === (key === 'SPD' ? 'SPD' : key));
  if (!canon) return null;
  const v = attrs[canon === 'SPD' ? 'Spd' : canon];
  return typeof v === 'number' ? v : null;
}

export function rollPoolFormula(expr, attrs = {}) {
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
  if (dice) {
    const rolled = evalDice(dice[0]);
    if (rolled != null) {
      const bonus = attrIn(s, attrs);
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
