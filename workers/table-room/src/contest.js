// The Table - an opposed FEAT the GM calls for, on a Marvel table. Pure: every
// function takes `feat` (makeFeat(ranks, universal), the Marvel app's own
// roller) and plain values, so workers/table-room/test/room.mjs can replay a
// contest exactly. room.js holds the pending calls and the sockets.
//
// THIS IS A HOUSE RULE (Nate, 2026-11-09). The book resolves a dodge as a
// column shift on the attacker; this table rolls head to head instead.
//
// THE RULE
//   Each side rolls d100 on its own rank's column and the LEVELS are compared:
//     natural 13 < white < green < yellow < red < natural 69
//   The attacker wins only on a strictly higher level; every tie, 13 v 13 and
//   69 v 69 included, is the defender's. A winning attack reads the attacker's
//   own colour on the action's column (a 69 reads as Red, marked Extra crit;
//   a natural 13 is marked Extra fail wherever it falls).
//
// KARMA is called BEFORE the roll and is only ever SHOWN; nothing here or in
// the room writes it anywhere.
//   called, and won anyway      10
//   called, and lost            the points that take the d100 to the lowest
//                               roll of the colour needed: the attacker needs
//                               the level ABOVE the defender's, the defender
//                               only needs to MATCH the attacker's
//   lost on a natural 13        a flat 100 buys the lowest winning colour
//   the winner rolled a 69      no Karma beats it
//   both sides called           the loser's buy costs 50 more
// Readings, not rulings (named in the PR that added this file): the flat 100,
// the 50 added to it as well, a buy never costing less than the 10 a call
// costs, the 10 still owed when the result stands, and that an attacker facing
// a Red cannot buy, because only a natural 69 ranks above Red.

export const ABILITIES = ['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche'];

// Columns the GM cannot call a contest on: the three follow-up columns, and
// the defence columns whose results are column shifts under the book's rule.
const NOT_CALLED = new Set(['stun', 'slam', 'kill', 'dodging', 'evading', 'blocking', 'catching']);
export const callable = (feat) => feat.actions.filter((a) => !NOT_CALLED.has(a.id));

export const KARMA_CALL = 10;
export const KARMA_13 = 100;
export const KARMA_BOTH = 50;

const cap = (s) => s[0].toUpperCase() + s.slice(1);
const rankName = (feat, id) => feat.ladder.find((r) => r.id === id)?.name ?? id;

// 0 for a natural 13, 1-4 for white to red off the PRINTED table, 5 for a 69.
export function level(feat, rank, d100) {
  if (d100 === 13) return 0;
  if (d100 === 69) return 5;
  return 1 + feat.ORDER.indexOf(feat.printed(rank, d100));
}

// The colour a level reads as on an action's column.
const colourAt = (feat, lv) => feat.ORDER[Math.max(1, Math.min(4, lv)) - 1];

// What a side that called on Karma would pay. `me` and `other` are
// { rank, d100, karma }; -> { owes } when it won, or when it lost
// { owes: 10, buy: { cost, colour } | null, why? }.
export function karma(feat, me, other, { attacker, won, both }) {
  if (won) return { owes: KARMA_CALL };
  const mine = level(feat, me.rank, me.d100);
  const theirs = level(feat, other.rank, other.d100);
  if (theirs === 5) return { owes: KARMA_CALL, buy: null, why: 'no Karma beats a natural 69' };
  const need = attacker ? theirs + 1 : theirs;
  if (need > 4) return { owes: KARMA_CALL, buy: null, why: 'only a natural 69 beats a Red' };
  const colour = colourAt(feat, need);
  let cost;
  if (mine === 0) cost = KARMA_13;
  else {
    const lowest = feat.lowest(me.rank, colour);
    if (lowest === null) return { owes: KARMA_CALL, buy: null, why: `the ${rankName(feat, me.rank)} column has no ${cap(colour)}` };
    cost = Math.max(KARMA_CALL, lowest - me.d100);
  }
  return { owes: KARMA_CALL, buy: { cost: cost + (both ? KARMA_BOTH : 0), colour } };
}

// Both rolls in -> who won and what it means. A side is
// { name, ability, rank, d100, karma }. `action` is a universal.json action.
export function resolve(feat, action, attacker, defender) {
  const a = level(feat, attacker.rank, attacker.d100);
  const d = level(feat, defender.rank, defender.d100);
  const attackerWins = a > d;
  const colour = colourAt(feat, a);
  const both = !!attacker.karma && !!defender.karma;
  const side = (s, lv, isAttacker) => ({
    level: lv,
    colour: lv === 0 ? 'white' : colourAt(feat, lv),
    natural: s.d100 === 13 || s.d100 === 69 ? s.d100 : null,
    karma: s.karma
      ? karma(feat, s, isAttacker ? defender : attacker, { attacker: isAttacker, won: isAttacker === attackerWins, both })
      : null,
  });
  return {
    winner: attackerWins ? 'attacker' : 'defender',
    result: attackerWins ? action.results[colour] : null,
    crit: (attackerWins ? attacker : defender).d100 === 69,
    attacker: side(attacker, a, true),
    defender: side(defender, d, false),
  };
}

// ── The line the feed shows ──────────────────────────────────────────────────
//
// `mask` names the side ('attacker' | 'defender') whose ability, rank and roll
// the GM hid; that side is written as its name alone (which room.js has
// already made ??? for a hidden NPC) and its Karma line is left out, because
// the points it would need give its roll away.

const rolled = (feat, s, r) => {
  const nat = r.natural === 13 ? ', Extra fail' : r.natural === 69 ? ', Extra crit' : '';
  return `${s.name} ${cap(s.ability)} ${rankName(feat, s.rank)} ${s.d100} ${cap(r.colour)}${nat}`;
};

function karmaLine(feat, action, s, k, isAttacker) {
  if (!k) return '';
  if (!('buy' in k)) return ` ${s.name} called on Karma: ${k.owes}.`;
  if (!k.buy) return ` ${s.name} called on Karma: ${k.why}; ${k.owes}.`;
  const what = isAttacker ? ` (${cap(k.buy.colour)}: ${action.results[k.buy.colour]})` : '';
  return ` ${s.name} called on Karma: ${k.buy.cost} would win it${what}; ${k.owes} if it stands.`;
}

export function resultText(feat, action, label, attacker, defender, r, mask = null) {
  const show = (which, s, rr) => (mask === which ? s.name : rolled(feat, s, rr));
  const head = `${label || action.name}: ${show('attacker', attacker, r.attacker)} v ${show('defender', defender, r.defender)}`;
  const outcome = r.winner === 'attacker'
    ? `${attacker.name} wins: ${r.result}`
    : `${defender.name} wins`;
  const k = (mask === 'attacker' ? '' : karmaLine(feat, action, attacker, r.attacker.karma, true))
    + (mask === 'defender' ? '' : karmaLine(feat, action, defender, r.defender.karma, false));
  return `${head}. ${outcome}.${k}`;
}
