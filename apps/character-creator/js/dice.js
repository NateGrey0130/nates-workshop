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
export function rollPoolFormula(expr, attrs = {}) {
  if (expr == null) return null;
  if (typeof expr === 'number') return expr;
  const s = String(expr).trim();

  const dice = evalDice(s);
  if (dice != null) return dice;

  const pe = s.match(/p\.?e\.?\s*\+\s*(\d+\s*d\s*\d+(?:\s*x\s*\d+)?(?:\s*[+-]\s*\d+)?)/i);
  if (pe) return (attrs.PE || 0) + evalDice(pe[1]);

  const n = Number(s);
  return Number.isFinite(n) ? n : null;
}
