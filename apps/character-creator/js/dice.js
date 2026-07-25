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
