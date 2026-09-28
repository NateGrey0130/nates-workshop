// Initiative, as the house rule R25 has it. Pure: give it the combatants and a
// dice generator (js/dice.js) and it answers the order, so the smoke suite can
// run it against fixed seeds.
//
// R25: everyone rolls d100 and the highest goes first. A tie is broken by, in
// order:
//   1. an initiative Talent THAT APPLIES THIS ROUND. The two Talents that give
//      "+1 initiative" (Weapons Specialist with one chosen weapon, Martial Arts
//      E unarmed) are read as tie-breakers, not as +1 on the roll, and both are
//      conditional - so the GM ticks "Talent applies" per combatant per round,
//      and an unticked box breaks nothing;
//   2. the higher Agility NUMBER, not the rank's name: Excellent 22 beats
//      Excellent 20, though both are Excellent;
//   3. still tied, ONLY the tied combatants roll d100 again, as often as it
//      takes.
//
// A combatant is { key, name, agility, talent, applies }: `talent` says it has
// one of the two Talents, `applies` is the GM's tick for this round. Only both
// together count.

import { d100 } from './dice.js';

// The Talents the rule reads, derived from the data rather than listed, so a
// correction to talents.json cannot leave this behind. The suite pins exactly
// weapons-specialist and martial-arts-e.
export function initiativeTalents(talentsData) {
  return talentsData.talents.filter((t) => /\binitiative\b/i.test(t.summary)).map((t) => t.id);
}

export const TAGS = { talent: 'Talent', agility: 'Agility', reroll: 're-roll' };

const counts = (c) => !!(c.talent && c.applies);

// Split a list into runs sharing `key`, highest first.
function runs(rows, key) {
  const by = new Map();
  for (const r of rows) {
    const k = key(r);
    by.set(k, [...(by.get(k) ?? []), r]);
  }
  return [...by.entries()].sort((a, b) => b[0] - a[0]).map(([, g]) => g);
}

const tag = (rows, t) => { for (const r of rows) if (!r.tags.includes(t)) r.tags.push(t); };

const SAFETY = 100;   // re-rolls before giving up; two d100s tie 1 time in 100

// Order one group that tied on the d100, starting at a stage of the rule.
function breakTie(group, next, stage, depth = 0) {
  if (group.length < 2) return group;
  if (stage === 'talent') {
    const [yes, no] = [group.filter(counts), group.filter((r) => !counts(r))];
    if (!yes.length || !no.length) return breakTie(group, next, 'agility', depth);
    tag(group, TAGS.talent);
    return [...breakTie(yes, next, 'agility', depth), ...breakTie(no, next, 'agility', depth)];
  }
  if (stage === 'agility') {
    const byAgility = runs(group, (r) => Number(r.agility) || 0);
    if (byAgility.length === 1) return breakTie(group, next, 'reroll', depth);
    tag(group, TAGS.agility);
    return byAgility.flatMap((g) => breakTie(g, next, 'reroll', depth));
  }
  // Still tied: these, and only these, roll again.
  if (depth >= SAFETY) return group;
  for (const r of group) r.rerolls.push(d100(next));
  tag(group, TAGS.reroll);
  const last = (r) => r.rerolls[r.rerolls.length - 1];
  return runs(group, last).flatMap((g) => breakTie(g, next, 'reroll', depth + 1));
}

// A round: every combatant's d100, and the order it gives. Each row keeps its
// roll, any re-rolls, and `tags` naming what broke a tie it was in - empty when
// its roll alone placed it.
export function rollInitiative(combatants, next) {
  const rows = combatants.map((c) => ({ ...c, roll: d100(next), rerolls: [], tags: [] }));
  return orderRolled(rows, next);
}

// The same, for rows that already hold their `roll` (the suite sets ties up
// this way; the page never needs to).
export function orderRolled(rows, next) {
  const fresh = rows.map((r) => ({ ...r, rerolls: [], tags: [] }));
  return runs(fresh, (r) => r.roll).flatMap((g) => breakTie(g, next, 'talent'));
}
