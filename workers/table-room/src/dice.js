// The Table — the dice box, rolled on the server. Pure: every function takes
// the random source as an argument, so workers/table-room/test/room.mjs can
// replay a roll exactly.
//
// `random` is a function returning a float in [0, 1), like Math.random. The
// room passes one built on crypto.getRandomValues.

// Bounds that keep an expression a roll rather than a load test: a hundred
// dice, a thousand sides, and a modifier no table has ever needed more than.
export const MAX_DICE = 100;
export const MAX_SIDES = 1000;
export const MAX_MODIFIER = 1000;
export const MAX_TERMS = 10;

const die = (random, sides) => 1 + Math.floor(random() * sides);

// "d20", "2d6+3", "3d6 + 1d4 - 2", "d%", "D100". -> { terms, text } or { error }.
// A term is { sign, count, sides } or { sign, value }. `text` is the expression
// written back out the one way, so the feed reads the same whoever typed it.
export function parseExpression(src) {
  if (typeof src !== 'string') return { error: 'Type a roll, like d20 or 2d6+3' };
  const s = src.replace(/\s+/g, '').toLowerCase().replace(/d%/g, 'd100');
  if (!s) return { error: 'Type a roll, like d20 or 2d6+3' };
  if (s.length > 60) return { error: 'That roll is too long' };
  if (!/^[+-]?(\d*d\d+|\d+)([+-](\d*d\d+|\d+))*$/.test(s)) {
    return { error: `Not a roll: ${src.slice(0, 40)}. Try d20, 2d6+3 or d100.` };
  }
  const terms = [];
  let dice = 0;
  for (const m of s.matchAll(/([+-]?)(\d*d\d+|\d+)/g)) {
    const sign = m[1] === '-' ? -1 : 1;
    const body = m[2];
    if (body.includes('d')) {
      const [c, sides] = body.split('d');
      const count = c === '' ? 1 : Number(c);
      if (count < 1) return { error: 'Roll at least one die' };
      if (Number(sides) < 2 || Number(sides) > MAX_SIDES) return { error: `Dice have 2 to ${MAX_SIDES} sides` };
      dice += count;
      terms.push({ sign, count, sides: Number(sides) });
    } else {
      const value = Number(body);
      if (value > MAX_MODIFIER) return { error: `Modifiers stop at ${MAX_MODIFIER}` };
      terms.push({ sign, value });
    }
  }
  if (!terms.some((t) => t.sides)) return { error: 'A roll needs at least one die' };
  if (dice > MAX_DICE) return { error: `At most ${MAX_DICE} dice in one roll` };
  if (terms.length > MAX_TERMS) return { error: `At most ${MAX_TERMS} parts in one roll` };
  const text = terms.map((t, i) => {
    const sign = t.sign < 0 ? '-' : i ? '+' : '';
    return sign + (t.sides ? `${t.count === 1 ? '' : t.count}d${t.sides}` : String(t.value));
  }).join('');
  return { terms, text };
}

// A parsed expression, rolled. -> { total, parts, text } where `text` is the
// line the feed shows: "2d6+3: 4, 2 +3 = 9".
export function rollExpression(parsed, random) {
  let total = 0;
  const parts = parsed.terms.map((t) => {
    if (!t.sides) { total += t.sign * t.value; return { sign: t.sign, value: t.value }; }
    const rolls = Array.from({ length: t.count }, () => die(random, t.sides));
    total += t.sign * rolls.reduce((a, b) => a + b, 0);
    return { sign: t.sign, sides: t.sides, rolls };
  });
  const shown = parts.map((p, i) => {
    const sign = p.sign < 0 ? '- ' : i ? '+ ' : '';
    return sign + (p.sides ? p.rolls.join(', ') : String(p.value));
  }).join(' ');
  // One die and nothing added reads "d20: 15", not "d20: 15 = 15".
  const lone = parts.length === 1 && parts[0].sides && parts[0].rolls.length === 1 && parts[0].sign > 0;
  return { total, parts, text: lone ? `${parsed.text}: ${total}` : `${parsed.text}: ${shown} = ${total}` };
}

// A Marvel FEAT on the Universal Table. `feat` is makeFeat(ranks, universal)
// from apps/marvel-heroes/js/feat.js - the app's own roller, so the table and
// the Marvel sheet cannot read one d100 two ways. -> { d100, colour, column,
// text } or { error }.
export function rollFeat(feat, { rank, cs = 0 }, random) {
  const known = feat.ladder.find((r) => r.id === rank);
  if (!known) return { error: 'Pick a rank for the FEAT' };
  const shift = Number(cs) || 0;
  if (!Number.isInteger(shift) || Math.abs(shift) > 5) return { error: 'A column shift is a whole number from -5 to +5' };
  const d100 = die(random, 100);
  const r = feat.roll({ rank, cs: shift, d100 });
  const used = feat.ladder.find((x) => x.id === r.column);
  const cols = shift ? ` ${shift > 0 ? '+' : ''}${shift} CS to ${used.name}` : '';
  return {
    d100, colour: r.colour, column: r.column,
    text: `FEAT on ${known.name}${cols}: ${d100} — ${r.colour}`,
  };
}
