// Rolling a species from the books (the `creatures` catalog, migration 074)
// into one individual.
//
// A creature row stores FORMULAS where a notable NPC stores numbers: "I.Q.
// 2D6", "Hit Points: PE+20", "S.D.C.: PEx10". Placing one rolls them, and this
// is the one reader of that grammar - the endpoint rolls with it, the
// regression suite checks every live row parses with it.
//
// WHY NOT dice.js's rollPoolFormula. That reader is built for class formulas
// and is forgiving on purpose: an unreadable attribute falls back to 3D6, and a
// constant after an attribute is dropped ("P.E. + 20" rolls as P.E.). For a
// class both are recoveries. For a species copied into a fight they would be
// padding - a number the book never gave - and the plan is to refuse and name
// the gap instead (decided 2026-09-17). So this grammar is small and STRICT:
// anything it cannot read is a named refusal, and the data script normalises
// the book's wording into it before a row is written.
//
// THE GRAMMAR. A formula is terms joined by + or -. A term is
//   dice       2D6   1D4x10   (x multiplies the dice)
//   a number   20    5x10
//   attribute  PE    PEx10    (IQ ME MA PS PP PE PB Spd, stops allowed: P.E.)
// Case and spaces do not matter. "N/A" is an attribute the species does not
// have (dice.js's rule, BOOK-INGEST-AUDIT.md F5) and rolls to null.

import { d } from './dice.js';

const ATTR_KEYS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const ATTR_BY_UPPER = Object.fromEntries(ATTR_KEYS.map((k) => [k.toUpperCase(), k]));
const TERM = /^(?:(\d+)D(\d+)|(\d+)|(IQ|ME|MA|PS|PP|PE|PB|SPD))(?:X(\d+))?$/;

// The formula's terms, or null when any part of it is not the grammar.
function parseCreatureFormula(formula) {
  if (typeof formula === 'number') return Number.isInteger(formula) ? [{ sign: 1, n: formula, mult: 1 }] : null;
  if (typeof formula !== 'string') return null;
  // "P.E. x 10" and "pe*10" are "PEX10". Stops only ever sit inside an
  // attribute's name here; the grammar has no decimals.
  const s = formula.toUpperCase().replace(/[\s.]+/g, '').replace(/×|\*/g, 'X');
  if (!s || !/^[+-]?[0-9A-Z]/.test(s)) return null;
  const terms = [];
  const re = /([+-]?)([^+-]+)/g;
  let m, consumed = 0;
  while ((m = re.exec(s))) {
    consumed += m[0].length;
    const t = m[2].match(TERM);
    if (!t) return null;
    const sign = m[1] === '-' ? -1 : 1;
    const mult = t[5] ? +t[5] : 1;
    if (t[1]) terms.push({ sign, dice: +t[1], sides: +t[2], mult });
    else if (t[3]) terms.push({ sign, n: +t[3], mult });
    else terms.push({ sign, attr: ATTR_BY_UPPER[t[4]], mult });
  }
  return consumed === s.length && terms.length ? terms : null;
}

// Does the formula parse? `attrOk` false refuses attribute terms, which is what
// an ATTRIBUTE's own formula must do - I.Q. cannot be "P.E. + 2".
function isCreatureFormula(formula, { attrOk = true } = {}) {
  if (isAbsent(formula)) return true;
  const terms = parseCreatureFormula(formula);
  return !!terms && (attrOk || terms.every((t) => !t.attr));
}

const isAbsent = (v) => typeof v === 'string' && /^N\/A$/i.test(v.trim());

// One roll of a formula. `attrs` supplies the rolled attributes it may name;
// `die(sides)` supplies each die, so tests can pin it. Throws a CreatureGap
// naming the formula when it cannot be read or names an attribute not rolled.
function rollCreatureFormula(formula, attrs = {}, die = d, field = 'formula') {
  const terms = parseCreatureFormula(formula);
  if (!terms) throw new CreatureGap(field, `"${formula}" is not a formula this can roll`);
  let total = 0;
  for (const t of terms) {
    let v;
    if (t.dice != null) { v = 0; for (let i = 0; i < t.dice; i++) v += die(t.sides); }
    else if (t.n != null) v = t.n;
    else {
      v = attrs[t.attr];
      if (typeof v !== 'number') throw new CreatureGap(field, `"${formula}" needs ${t.attr}, which this creature has no number for`);
    }
    total += t.sign * v * t.mult;
  }
  return total;
}

export class CreatureGap extends Error {
  constructor(field, detail) {
    super(`${field}: ${detail}`);
    this.name = 'CreatureGap';
    this.field = field;
  }
}

const POOLS = ['hp', 'sdc', 'mdc', 'ppe', 'isp'];

// One individual of a species: its eight attributes rolled first (a key the
// book does not print stays absent; "N/A" is null), then each pool, which may
// name an attribute just rolled. Returns { attributes, pools }. Throws a
// CreatureGap on the first formula it cannot roll - never a substitute number.
export function rollCreature(row, die = d) {
  const specs = typeof row.attributes === 'string' ? JSON.parse(row.attributes || '{}') : (row.attributes || {});
  const attributes = {};
  for (const key of ATTR_KEYS) {
    if (!(key in specs)) continue;
    const spec = specs[key];
    if (isAbsent(spec)) { attributes[key] = null; continue; }
    if (!isCreatureFormula(spec, { attrOk: false })) {
      throw new CreatureGap(`attributes.${key}`, `"${spec}" is not a formula this can roll`);
    }
    attributes[key] = rollCreatureFormula(spec, {}, die, `attributes.${key}`);
  }
  const pools = {};
  for (const key of POOLS) {
    const spec = row[key];
    pools[key] = spec == null || spec === '' ? null : rollCreatureFormula(spec, attributes, die, key);
  }
  return { attributes, pools };
}

// Every formula a row carries that this cannot roll, as [{ field, formula }].
// Empty is the contract a data script must meet before a row is written.
export function creatureFormulaGaps(row) {
  const gaps = [];
  let specs;
  try {
    specs = typeof row.attributes === 'string' ? JSON.parse(row.attributes || '{}') : (row.attributes || {});
  } catch { return [{ field: 'attributes', formula: String(row.attributes) }]; }
  for (const [key, spec] of Object.entries(specs || {})) {
    if (!ATTR_KEYS.includes(key)) gaps.push({ field: `attributes.${key}`, formula: 'not a sheet attribute' });
    else if (!isCreatureFormula(spec, { attrOk: false })) gaps.push({ field: `attributes.${key}`, formula: spec });
  }
  for (const key of POOLS) {
    const spec = row[key];
    if (spec == null || spec === '') continue;
    const terms = parseCreatureFormula(spec);
    if (!terms) { gaps.push({ field: key, formula: spec }); continue; }
    for (const t of terms) {
      if (t.attr && !(t.attr in (specs || {}))) gaps.push({ field: key, formula: `${spec} (names ${t.attr}, which the row does not roll)` });
    }
  }
  return gaps;
}
