// The Table — Palladium and Rifts initiative. Pure: every function takes the
// random source as an argument, so workers/table-room/test/room.mjs can replay
// a melee exactly. Imports nothing.
//
// THE ROLL. d20 plus the character's initiative bonus. A player's bonus is the
// sheet's own number, derived on the server from D1 when they join
// (functions/api/character-creator/_lib/combat-numbers.js), never sent by the
// page. The GM's NPCs carry the numbers the GM added them with.
//
// THE ORDER. Highest total first. A tie goes to the higher initiative bonus;
// equal bonuses too, and ONLY the tied combatants roll a d20 again, as often
// as it takes. Nate's ruling, 2026-09-29 (the design doc's open question).
//
// A MELEE. Each combatant acts once per pass through the order, spending one
// attack. Passes repeat until every combatant's attacks per melee (the sheet's
// # of Attacks) are spent; a combatant out of attacks is skipped. Nate's
// ruling, 2026-09-29: once per pass, not a character's attacks back to back.

export const DIE = 20;
export const DEFAULT_ATTACKS = 2;       // every character's base before training
const SAFETY = 100;                     // re-rolls before giving up

const die = (random, sides) => 1 + Math.floor(random() * sides);

// Split rows into runs sharing `key`, highest first.
function runs(rows, key) {
  const by = new Map();
  for (const r of rows) {
    const k = key(r);
    by.set(k, [...(by.get(k) ?? []), r]);
  }
  return [...by.entries()].sort((a, b) => b[0] - a[0]).map(([, g]) => g);
}

const tag = (rows, t) => { for (const r of rows) if (!r.tags.includes(t)) r.tags.push(t); };

// A group that tied on its total, in order: bonus, then re-rolls.
function breakTie(group, random, stage, depth = 0) {
  if (group.length < 2) return group;
  if (stage === 'bonus') {
    const byBonus = runs(group, (r) => Number(r.bonus) || 0);
    if (byBonus.length === 1) return breakTie(group, random, 'reroll', depth);
    tag(group, 'bonus');
    return byBonus.flatMap((g) => breakTie(g, random, 'reroll', depth));
  }
  if (depth >= SAFETY) return group;
  for (const r of group) r.rerolls.push(die(random, DIE));
  tag(group, 're-roll');
  const last = (r) => r.rerolls[r.rerolls.length - 1];
  return runs(group, last).flatMap((g) => breakTie(g, random, 'reroll', depth + 1));
}

// One combatant's roll: { roll, total }.
export function rollOne(bonus, random) {
  const roll = die(random, DIE);
  return { roll, total: roll + (Number(bonus) || 0) };
}

// Rows that already hold their `total`, in initiative order. Each comes back
// a fresh copy with `rerolls` and `tags` saying what broke any tie it was in.
export function orderRolled(rows, random) {
  const fresh = rows.map((r) => ({ ...r, rerolls: [], tags: [] }));
  return runs(fresh, (r) => r.total).flatMap((g) => breakTie(g, random, 'bonus'));
}

// The number a row is placed by, for slotting a latecomer in.
export const primary = (r) => r.total;
