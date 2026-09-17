// A character's SECOND BODY, as numbers: the Nightbane's Morphus, and any later
// class that states a `second_form` block (BOOK-INGEST-AUDIT F74, Nightbane
// survey D5).
//
// Three halves meet here and nowhere else:
//
//   the class's `second_form` block    how the form differs (js/parser.js)
//   `characters.second_form`           what was ROLLED for it (migration 069)
//   the traits catalog's rows          what each chosen table result grants
//                                      (`morphus_characteristics`, migration 068)
//
// ONE MODULE, READ BY EVERY SIDE. The GET endpoint folds a character's form into
// the numbers the sheet draws; the PATCH endpoint clamps each form's current
// pools to the maximum folded here; the create validator refuses a stored form
// whose rolls could not have come off the dice; and the wizard's generator
// (js/morphus.js) rolls through `rollSecondForm` and `rollTraitResult`. Two
// implementations of "what is this Morphus's S.D.C." is the pair that drifts.
//
// WHAT IS STORED IS WHAT WAS ROLLED, never a total. Every dice value - the
// form's own "2D6x10 S.D.C.", a result's "+1D4 Horror Factor", each level's
// "2D6" hit points - is rolled ONCE and kept, the discipline `rolled_bonuses`
// and `hp_max` already follow. The maxima are FOLDED from those rolls on every
// read, because the second form's hit points are read against its P.E., and
// that P.E. moves when a result is added.
//
// The shape of `characters.second_form` (`{}` for a character with none):
//
//   {
//     "active": "first" | "second",          which form the sheet is showing
//     "form_rolls": { "pools": { "sdc": 70 } },   the form's own dice, rolled
//     "hp_rolls": [7, 9],                     one per level: see leveling.js
//     "results": [ { "key": "Stigmata: Bleeding Eyes", "sub_choice": null,
//                    "rolls": { "horror_factor": 3, "pools": { "sdc": 12 } } } ],
//     "sdc_current": 84,                      this form's own damage; null = full
//     "hp_current": 31
//   }
//
// `rolls` mirrors a `bonuses` block group by group - attributes, combat, saves,
// pools - plus `horror_factor`, so a roll is found where its dice were written.
//
// A result MAY also carry `omit`: bonus paths ("attributes.PS", "pools.sdc")
// its row prints but this character does not get, because a combination rule
// gave that bonus to another result. One rule needs it today - the Animal Form
// Table's Combination of Two/Three (printed 93-94) rolls 1D6 PER ATTRIBUTE to
// decide which animal's bonus applies, so the animals' bonuses are never added
// together. Without it every result's bonuses are summed, which is exactly what
// that rule forbids. The dice behind an omitted bonus are still rolled and
// stored - rolled once, like everything else - and simply not counted.
// js/morphus.js writes it; the fold and the validator below read it.

// derive.js is a classic script that installs `globalThis.derive`. Imported for
// that side effect, so the fold below reads a character's first-form bonuses
// through the SAME classBonuses/effective the sheet reads them through.
import './derive.js';
import { diceBounds, evalDice, fixedFormulaValue, poolFormulaBounds } from './dice.js';
import { isDiceBonus, SECOND_FORM_POOLS } from './parser.js';
import { secondFormHitPointDice } from './leveling.js';

const GROUPS = ['attributes', 'combat', 'saves'];
const SECOND_FORM_STATE_KEYS = ['active', 'form_rolls', 'hp_rolls', 'results', 'sdc_current', 'hp_current'];
const RESULT_KEYS = ['key', 'sub_choice', 'rolls', 'omit'];
export const FORM_NAMES = ['first', 'second'];

const D = () => globalThis.derive;
const isObj = (v) => !!v && typeof v === 'object' && !Array.isArray(v);
const finite = (v) => typeof v === 'number' && Number.isFinite(v);

// A stored form with nothing in it - the column's empty value, and what every
// character of a one-body class holds.
export function isEmptySecondForm(state) {
  return state == null || (isObj(state) && Object.keys(state).length === 0);
}

// A catalog row with its JSON columns decoded. Tolerant of either form, so a
// test can hand in objects and the loader can hand in D1's strings.
function decodeTraitRow(row) {
  if (!row) return row;
  const parse = (v) => {
    if (typeof v !== 'string') return v ?? null;
    try { return JSON.parse(v); } catch { return null; }
  };
  return { ...row, bonuses: parse(row.bonuses), sub_choices: parse(row.sub_choices) };
}

// Every dice value in a bonuses block, as { group, key, dice }. Pools count only
// where a form HAS them - hit points and S.D.C.
function diceIn(bonuses) {
  const out = [];
  if (!isObj(bonuses)) return out;
  for (const g of GROUPS) {
    for (const [k, v] of Object.entries(isObj(bonuses[g]) ? bonuses[g] : {})) {
      if (g === 'saves' && k === 'other') continue;
      if (isDiceBonus(v)) out.push({ group: g, key: k, dice: v });
    }
  }
  const pools = isObj(bonuses.pools) ? bonuses.pools : {};
  for (const k of SECOND_FORM_POOLS) {
    if (isDiceBonus(pools[k])) out.push({ group: 'pools', key: k, dice: pools[k] });
  }
  return out;
}

// Every bonus a block ADDS, as "group.key" paths - a number or a dice value, in
// the groups and pools the fold counts. What a result's `omit` may name, and
// what js/morphus.js rolls 1D6 over for an Animal Form combination, so the two
// cannot disagree about what "a bonus" is.
export function bonusPaths(bonuses) {
  const b = decodeTraitRow({ bonuses })?.bonuses;
  const out = [];
  if (!isObj(b)) return out;
  for (const g of GROUPS) {
    for (const [k, v] of Object.entries(isObj(b[g]) ? b[g] : {})) {
      if (g === 'saves' && k === 'other') continue;
      if (finite(v) || isDiceBonus(v)) out.push(`${g}.${k}`);
    }
  }
  const pools = isObj(b.pools) ? b.pools : {};
  for (const k of SECOND_FORM_POOLS) {
    if (finite(pools[k]) || isDiceBonus(pools[k])) out.push(`pools.${k}`);
  }
  return out;
}

function rollBlock(bonuses) {
  const rolls = {};
  for (const { group, key, dice } of diceIn(bonuses)) {
    (rolls[group] ||= {})[key] = evalDice(dice);
  }
  return rolls;
}

// One table result, rolled: every dice value it carries, rolled once. What the
// wizard's generator stores per pick.
export function rollTraitResult(row, subChoice = null) {
  const r = decodeTraitRow(row);
  const rolls = rollBlock(r?.bonuses);
  if (isDiceBonus(r?.horror_factor)) rolls.horror_factor = evalDice(r.horror_factor);
  return { key: r?.key ?? null, sub_choice: subChoice ?? null, rolls };
}

// A newly made form: the form's own dice and its hit point dice for every level
// the character has, no results yet, the first form showing and both pools full.
export function rollSecondForm(form, level = 1) {
  if (!form) return {};
  const hp = secondFormHitPointDice(form.hit_points_base);
  const hpRolls = [];
  for (let i = 0; i < hp.count(level); i++) hpRolls.push(evalDice(i === 0 ? hp.first : hp.per));
  return {
    active: 'first', form_rolls: rollBlock(form.bonuses), hp_rolls: hpRolls, results: [],
    sdc_current: null, hp_current: null,
  };
}

// Add a bonuses block's numbers into `out`: a number counts itself, a dice value
// counts what it rolled, and an unrolled one counts nothing and is REPORTED -
// the rule classBonuses follows, never an average.
// A path in `omit` counts nothing (see the header: a combination rule gave it
// to another result).
function foldBlock(bonuses, rolls, out, unrolled, where, omit = null) {
  if (!isObj(bonuses)) return;
  const skip = (path) => !!omit && omit.includes(path);
  for (const g of GROUPS) {
    for (const [k, v] of Object.entries(isObj(bonuses[g]) ? bonuses[g] : {})) {
      if (g === 'saves' && k === 'other') continue;
      if (skip(`${g}.${k}`)) continue;
      if (finite(v)) out[g][k] = (out[g][k] || 0) + v;
      else if (isDiceBonus(v)) {
        const r = rolls?.[g]?.[k];
        if (finite(r)) out[g][k] = (out[g][k] || 0) + r;
        else unrolled.push(`${where}: ${g}.${k} (${v})`);
      }
    }
  }
  for (const [k, v] of Object.entries(isObj(bonuses.attribute_minimums) ? bonuses.attribute_minimums : {})) {
    if (finite(v)) out.attribute_minimums[k] = Math.max(out.attribute_minimums[k] ?? 0, v);
  }
  const pools = isObj(bonuses.pools) ? bonuses.pools : {};
  for (const k of SECOND_FORM_POOLS) {
    const v = pools[k];
    if (skip(`pools.${k}`)) continue;
    if (finite(v)) out.pools[k] += v;
    else if (isDiceBonus(v)) {
      const r = rolls?.pools?.[k];
      if (finite(r)) out.pools[k] += r;
      else unrolled.push(`${where}: pools.${k} (${v})`);
    }
  }
}

// What a result adds to the Horror Factor: a whole number, or its roll.
function horrorAdded(row, rolls, unrolled) {
  const hf = row?.horror_factor;
  if (hf == null || String(hf).trim() === '') return 0;
  if (/^\s*\d+\s*$/.test(String(hf))) return Number(hf);
  if (isDiceBonus(hf)) {
    if (finite(rolls?.horror_factor)) return rolls.horror_factor;
    unrolled.push(`${row.key}: horror_factor (${hf})`);
  }
  return 0;
}

// The second form's HIT POINT MAXIMUM, read against its attributes.
//
// The formula's attribute term plus every stored roll, plus any hit points the
// form or a result adds. The attribute term is the formula's floor less its
// first dice's floor, which is poolFormulaBounds' own reading of the formula -
// so "P.E. x2 + 2D6 per level" is P.E. x 2 by exactly the walk the first form's
// pools take, not by a second parse of it.
//
// A form that states no formula keeps the FIRST form's hit point maximum, and
// still tracks its own damage against it.
function secondFormHitPoints(form, state, attrs, firstHpMax, added = 0) {
  const formula = form?.hit_points_base;
  if (formula == null) return firstHpMax == null && !added ? null : (firstHpMax ?? 0) + added;
  const dice = secondFormHitPointDice(formula);
  let term;
  if (!dice.first) term = fixedFormulaValue(formula, attrs || {});
  else {
    const b = poolFormulaBounds(formula, attrs || {});
    const db = diceBounds(dice.first);
    term = b && db ? b.min - db.min : null;
  }
  if (term == null) return null;
  const rolls = Array.isArray(state?.hp_rolls) ? state.hp_rolls.filter(finite) : [];
  return term + rolls.reduce((a, b) => a + b, 0) + added;
}

// THE FOLD. Everything the sheet draws for the second form, from the composed
// class, the character row (JSON columns decoded) and a Map of the traits
// catalog's rows by `key`.
//
// Null for a class with no second form. `form_bonuses` is the form's own delta
// plus every result's, WITHOUT the class's - the sheet adds it to the first
// form's block itself, through derive.sumBonuses, so the first form's numbers
// are computed once and in one place.
export function secondFormView({ cls, character, rows = null }) {
  const form = cls?.second_form;
  if (!form) return null;
  const c = character || {};
  const state = isObj(c.second_form) ? c.second_form : {};
  const level = Number.isInteger(c.level) ? c.level : 1;
  const bonus = { attributes: {}, combat: {}, saves: {}, attribute_minimums: {}, pools: { sdc: 0, hp: 0 } };
  const unrolled = [];

  foldBlock(form.bonuses, state.form_rolls, bonus, unrolled, form.name || 'second form');

  let hfAdded = 0;
  const sets = [];
  const results = [];
  for (const r of Array.isArray(state.results) ? state.results : []) {
    if (!isObj(r)) continue;
    const row = rows?.get?.(r.key) ? decodeTraitRow(rows.get(r.key)) : null;
    results.push({
      key: r.key ?? null, table: row?.table_name ?? null, name: row?.name ?? r.key ?? null,
      sub_choice: r.sub_choice ?? null, found: !!row,
    });
    if (!row) continue;
    foldBlock(row.bonuses, r.rolls, bonus, unrolled, row.key, Array.isArray(r.omit) ? r.omit : null);
    hfAdded += horrorAdded(row, r.rolls, unrolled);
    if (Number.isInteger(row.horror_factor_set)) sets.push(row.horror_factor_set);
  }

  const derive = D();
  const first = derive.classBonuses(cls, level, {
    attributes: c.attribute_bonuses || {},
    combat: c.rolled_bonuses?.combat || {},
    saves: c.rolled_bonuses?.saves || {},
  });
  const formBonuses = {
    attributes: bonus.attributes, combat: bonus.combat, saves: bonus.saves,
    attribute_minimums: bonus.attribute_minimums,
  };
  const attrs = derive.effective(c.attributes || {}, derive.sumBonuses(first, formBonuses));

  const hpMax = secondFormHitPoints(form, state, attrs, finite(c.hp_max) ? c.hp_max : null, bonus.pools.hp);
  const sdcMax = !finite(c.sdc_max) && !bonus.pools.sdc ? null : (finite(c.sdc_max) ? c.sdc_max : 0) + bonus.pools.sdc;

  // HORROR FACTOR: the form's base, raised by what results add, capped at the
  // form's maximum. A result that SETS it (three Morphus entries print one)
  // replaces the BASE - the highest set wins when two do - and what other
  // results add still lands on top, so a beauty that sets 10 and a stigmata
  // that adds 1D4 are not one of them silently discarded.
  const base = Number.isInteger(form.horror_factor) ? form.horror_factor : null;
  const setTo = sets.length ? Math.max(...sets) : null;
  const start = setTo ?? base;
  const max = Number.isInteger(form.horror_factor_max) ? form.horror_factor_max : null;
  let hf = start == null && !hfAdded ? null : (start ?? 0) + hfAdded;
  if (hf != null && max != null) hf = Math.min(hf, max);

  // A current value never stored means the pool is full - the same reading a
  // brand-new character's columns get, where current starts equal to max.
  const current = (v, m) => (finite(v) ? v : m);

  return {
    name: form.name ?? null,
    first_name: form.first_name ?? null,
    traits_from: form.traits_from ?? null,
    active: state.active === 'second' ? 'second' : 'first',
    form_bonuses: formBonuses,
    attributes: attrs,
    sdc_max: sdcMax,
    hp_max: hpMax,
    sdc_current: current(state.sdc_current, sdcMax),
    hp_current: current(state.hp_current, hpMax),
    horror_factor: hf,
    horror_factor_parts: { base, set: setTo, added: hfAdded, max },
    results,
    unrolled,
  };
}

// ─── what the create boundary refuses ───
//
// Pure, so the smoke suite can drive it without a database: `rows` is the Map
// the loader builds. Returns violations in the validator's own shape.
//
// Refused: a form on a class that has none; a result naming no catalog entry
// (or an intro row, which is a table's preamble rather than a result); a
// sub-choice the entry does not offer; an `omit` naming a bonus the entry does
// not print; any roll missing, outside its dice, or
// with no dice behind it; the wrong number of hit point rolls for the level;
// and a current value above the form's maximum.
export function secondFormViolations({ cls, character, state, rows = null }) {
  const out = [];
  const push = (rule, message, extra = {}) => out.push({ rule, message, ...extra });
  if (isEmptySecondForm(state)) return out;
  if (!isObj(state)) {
    push('second_form_shape', 'second_form must be an object');
    return out;
  }
  const form = cls?.second_form;
  if (!form) {
    push('second_form_not_allowed',
      `${cls?.name || 'This class'} states no second form, so its character cannot carry one`);
    return out;
  }
  const label = form.name || 'the second form';
  for (const k of Object.keys(state)) {
    if (!SECOND_FORM_STATE_KEYS.includes(k)) {
      push('second_form_shape', `second_form.${k} is not stored (${SECOND_FORM_STATE_KEYS.join(', ')})`);
    }
  }
  if (state.active !== undefined && !FORM_NAMES.includes(state.active)) {
    push('second_form_shape', `second_form.active must be "first" or "second", got ${JSON.stringify(state.active)}`);
  }

  const checkRolls = (bonuses, rolls, where, horror = null) => {
    if (rolls !== undefined && rolls !== null && !isObj(rolls)) {
      push('second_form_shape', `${where}: rolls must be an object`);
      return;
    }
    const expected = diceIn(bonuses);
    if (isDiceBonus(horror)) expected.push({ group: null, key: 'horror_factor', dice: horror });
    const seen = new Set();
    for (const { group, key, dice } of expected) {
      const path = group ? `${group}.${key}` : key;
      seen.add(path);
      const v = group ? rolls?.[group]?.[key] : rolls?.[key];
      const b = diceBounds(dice);
      if (!Number.isInteger(v)) {
        push('second_form_roll_missing', `${where}: ${path} is ${dice} and has no roll stored`, { key: where, path });
      } else if (b && (v < b.min || v > b.max)) {
        push('second_form_roll_out_of_range', `${where}: ${path} rolled ${v}, but ${dice} rolls ${b.min}-${b.max}`,
          { key: where, path, value: v, min: b.min, max: b.max });
      }
    }
    for (const [g, v] of Object.entries(isObj(rolls) ? rolls : {})) {
      const paths = isObj(v) ? Object.keys(v).map((k) => `${g}.${k}`) : [g];
      for (const p of paths) {
        if (!seen.has(p)) {
          push('second_form_roll_unexpected', `${where}: ${p} has a roll but no dice to have rolled it`,
            { key: where, path: p });
        }
      }
    }
  };

  checkRolls(form.bonuses, state.form_rolls, label);

  const hp = secondFormHitPointDice(form.hit_points_base);
  const level = Number.isInteger(character?.level) ? character.level : 1;
  const want = hp.count(level);
  if (state.hp_rolls !== undefined || want > 0) {
    const rolls = state.hp_rolls;
    if (!Array.isArray(rolls) || rolls.length !== want) {
      push('second_form_hp_rolls',
        `${label}'s hit points (${form.hit_points_base}) hold ${want} roll${want === 1 ? '' : 's'} at level ${level}; `
          + `got ${Array.isArray(rolls) ? rolls.length : 'none'}`);
    } else {
      rolls.forEach((v, i) => {
        const dice = i === 0 ? hp.first : hp.per;
        const b = diceBounds(dice);
        if (!Number.isInteger(v) || (b && (v < b.min || v > b.max))) {
          push('second_form_roll_out_of_range',
            `${label}'s hit point roll ${i + 1} is ${JSON.stringify(v)}, but ${dice} rolls ${b?.min}-${b?.max}`,
            { path: `hp_rolls.${i}`, value: v, min: b?.min, max: b?.max });
        }
      });
    }
  }

  if (state.results !== undefined && !Array.isArray(state.results)) {
    push('second_form_shape', 'second_form.results must be a list');
  }
  for (const [i, r] of (Array.isArray(state.results) ? state.results : []).entries()) {
    if (!isObj(r) || typeof r.key !== 'string' || !r.key.trim()) {
      push('second_form_shape', `second_form.results[${i}] needs a catalog key`);
      continue;
    }
    for (const k of Object.keys(r)) {
      if (!RESULT_KEYS.includes(k)) push('second_form_shape', `second_form.results[${i}].${k} is not stored`);
    }
    const raw = rows?.get?.(r.key);
    const row = raw ? decodeTraitRow(raw) : null;
    if (!row || row.kind === 'intro') {
      push('second_form_result_unknown',
        `"${r.key}" is not an entry of the ${form.traits_from || 'traits'} tables`, { key: r.key });
      continue;
    }
    const offered = Array.isArray(row.sub_choices) ? row.sub_choices : [];
    if (r.sub_choice != null && !offered.includes(r.sub_choice)) {
      push('second_form_sub_choice', offered.length
        ? `"${r.sub_choice}" is not one of ${r.key}'s choices (${offered.join('; ')})`
        : `${r.key} offers no choice, so it cannot carry "${r.sub_choice}"`, { key: r.key });
    }
    // `omit` names bonuses the row prints, once each - a path the row does not
    // carry would be a claim about a bonus nobody could have had.
    if (r.omit !== undefined && r.omit !== null) {
      const carried = bonusPaths(row.bonuses);
      if (!Array.isArray(r.omit) || r.omit.some((p) => typeof p !== 'string')) {
        push('second_form_shape', `second_form.results[${i}].omit must be a list of bonus paths`, { key: r.key });
      } else {
        const bad = r.omit.filter((p, j) => !carried.includes(p) || r.omit.indexOf(p) !== j);
        if (bad.length) {
          push('second_form_omit', `${r.key} cannot omit ${bad.join(', ')}: `
            + (carried.length ? `it adds only ${carried.join(', ')}, each once` : 'it adds no bonus'), { key: r.key });
        }
      }
    }
    checkRolls(row.bonuses, r.rolls, r.key, row.horror_factor);
  }

  // Current values against the maxima the rolls above fold to.
  const view = secondFormView({ cls, character: { ...(character || {}), second_form: state }, rows });
  for (const pool of ['sdc', 'hp']) {
    const v = state[pool + '_current'];
    if (v === undefined || v === null) continue;
    const max = view?.[pool + '_max'];
    if (!Number.isInteger(v)) {
      push('second_form_shape', `second_form.${pool}_current must be a whole number or null`);
    } else if (finite(max) && v > max) {
      push('second_form_current_above_max', `${label}'s current ${pool === 'sdc' ? 'S.D.C.' : 'hit points'} `
        + `is ${v}, above its maximum of ${max}`, { pool, value: v, max });
    }
  }
  return out;
}
