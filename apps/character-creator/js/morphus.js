// THE MORPHUS GENERATOR: Nightbane's "Creating the Nightbane" tables (printed
// 91-106) as a procedure, over the `morphus_characteristics` catalog rows
// (migration 068). Nightbane survey D5, PR 3 of 4.
//
// PURE. No DOM, no fetch, no Math.random unless nothing else is handed in: the
// wizard calls it, the smoke suite drives it with an injected RNG against the
// real catalog rows, and the regression suite builds a character with it.
//
// ─── the book's procedure ───
//
// Start at the Appearance Table. Every entry either carries effects, ROUTES to
// one or more other tables ("roll on the Stigmata Table"), or is a COMBINATION
// that rolls its own table again two or three times. Every table says "Roll or
// select", so each step is resolved either way (printed 85, 91: all rolled, all
// picked, or mixed) and the routes are followed either way.
//
// ─── what is stored, and why a list of DECISIONS ───
//
// The generator's state is the list of decisions the player made, in order:
//
//   { key, how: 'roll' | 'pick', roll, rerolls: [{ roll, key, why }],
//     sub_choice, rolls, combine? }     or     { skip: true }
//
// and everything else - what is resolved, what is still pending, which table
// comes next - is REPLAYED from that list (`replayMorphus`). So undoing the last
// step is dropping the last decision, a draft stores the list and nothing
// derived, and there is no second copy of "what is pending" to drift. Every die
// a result carries is rolled ONCE when it is decided (`rollTraitResult`, the
// same call #1139's validator checks against) and kept in `rolls`.
//
// The pending tables are resolved DEPTH FIRST: an entry's routes go to the front
// of the queue, in the order the entry prints them. "Monstrous Lycanthrope" is
// Animal Form, then that animal's own table, then Stigmata, then Characteristics.
//
// ─── what reaches the character ───
//
// `morphusResults` turns the decisions into `characters.second_form.results`:
// EVERY resolved entry - routes and combinations as well as effects - with its
// sub-choice and its rolls. Routes are kept because the path is part of the
// Morphus: four Elite Talents gate on the table a result came from (printed
// 107, 112-115), and Stigmata's Biomechanical route carries its own +1 Horror
// Factor in the row's `horror_factor`, which only counts if the row is stored.
//
// ─── the rules are a MAP, not prose parsed at runtime ───
//
// `route_rule` on a catalog row is the book's sentence, for people. What the
// generator enforces is MORPHUS_RULES below, keyed by the entry whose rule it
// is, each with its printed page - and `rulesDisagreeWithRows` checks the map
// against the rows, so a catalog edit that moves a band or rewords a sub-choice
// a rule matches on fails the smoke suite instead of quietly switching a rule
// off.

import { rollTraitResult, bonusPaths } from './second-form.js';

export const MORPHUS_START = 'Appearance';

const isObj = (v) => !!v && typeof v === 'object' && !Array.isArray(v);
const parseJson = (v) => {
  if (typeof v !== 'string') return v ?? null;
  try { return JSON.parse(v); } catch { return null; }
};

// ─── the encoded rules ───
//
// `children` excludes entries from the tables THIS entry sends the roll to:
//   kinds  entries of these kinds          from  entries whose band starts here or later
// An excluded entry is REROLLED when the dice land on it and is NOT OFFERED when
// the player picks - the one reading of "ignore and reroll" that works in both
// modes.
//
// `routesOnlyWith` / `extraRoll.when` match the sub-choice that decides whether
// an entry's further rolls happen. Matched by pattern rather than by index or
// exact text, and held to exactly one of the row's sub-choices by the check.
export const MORPHUS_RULES = {
  // Almost human is human but for one trait (the catalog's route_rule: "only a
  // single characteristic is allowed"), so the Characteristics roll it asks for
  // may not itself ask for more than one.
  'Appearance: Almost human': {
    page: '92', children: { kinds: ['combination'] },
    says: 'Almost human allows one characteristic: a result asking for more is ignored and rerolled',
  },
  // "Ignore any result of 61% or higher" - AS PRINTED. That also shuts out
  // 61-80% Unnatural Limbs from a multi-roll, which is probably an erratum for
  // 81%; the data script records the reading and so does this. The book's
  // alternative ("roll 1D6x10%") lands on the same three tables and is not
  // offered separately.
  'Nightbane Characteristics: Two characteristics': {
    page: '92', children: { from: 61 },
    says: 'several characteristics: a result of 61% or higher is ignored, as printed',
  },
  'Nightbane Characteristics: Three characteristics': {
    page: '92', children: { from: 61 },
    says: 'several characteristics: a result of 61% or higher is ignored, as printed',
  },
  'Nightbane Characteristics: Four Characteristics': {
    page: '92', children: { from: 61 },
    says: 'several characteristics: a result of 61% or higher is ignored, as printed',
  },
  // Every combination rerolls its own combination bands.
  'Unearthly Beauty: Combination of Two': {
    page: '93', children: { from: 91 },
    says: 'a combination ignores and rerolls 91% or higher',
  },
  // "Other": invent one with the G.M. (nothing further to roll), OR roll three
  // times as 91-95%. Only the second sub-choice queues the rolls.
  'Unearthly Beauty: Other': {
    page: '93', children: { from: 91 }, routesOnlyWith: /roll three times/i,
    says: 'a combination ignores and rerolls 91% or higher',
  },
  // 1D6 per attribute decides which animal's bonus applies (1-3 the first, 4-6
  // the second; of three, 1-2 / 3-4 / 5-6), so the bonuses are NOT added together. `animalBonuses` is how many
  // animals; see `withCombinationRolls` and `morphusResults`.
  'Animal Form: Combination of Two': {
    page: '93', children: { from: 96 }, animalBonuses: 2,
    says: 'a combination ignores and rerolls 96% or higher',
  },
  'Animal Form: Combination of Three': {
    page: '94', children: { from: 96 }, animalBonuses: 3,
    says: 'a combination ignores and rerolls 96% or higher',
  },
  // A biomechanical part worn as a stigma adds +1 Horror Factor on top of the
  // biomechanical result's own (printed 102). CARRIED BY THE ROW -
  // its `horror_factor` is 1 - so it counts because the route row is stored as
  // a result, and is never added a second time here. `horrorFactor` is what the
  // check holds the row to.
  'Stigmata: Biomechanical': {
    page: '102', horrorFactor: 1,
    says: 'a biomechanical part as a stigma adds +1 Horror Factor on top of its own',
  },
  'Stigmata: Combination of Two': {
    page: '102', children: { from: 97 },
    says: 'a combination ignores and rerolls 97% or higher; the Horror Factors add together',
  },
  // Skull Face 91-00%: "the player may roll again on this table" - OPTIONAL, so
  // the extra Facial Features roll it queues can be skipped.
  'Unusual Facial Features: Skull Face': {
    page: '103', extraRoll: { when: /roll again/i, table: 'Unusual Facial Features' },
    says: 'an unusual skull may roll again on this table, if the player wants to',
  },
  'Unusual Facial Features: Two': {
    page: '103', children: { from: 96 },
    says: 'a combination ignores and rerolls 96% or higher',
  },
  'Unusual Facial Features: Three': {
    page: '103', children: { from: 96 },
    says: 'a combination ignores and rerolls 96% or higher',
  },
  'Alien Shape: Combination of Two': {
    page: '104', children: { from: 96 },
    says: 'a combination ignores and rerolls 96% or higher',
  },
};

// Two rules that are not one entry's.
//
// A ROUTE TO A TABLE THE BOOK NEVER PRINTS - Animal Form 01-07% Bear and 08-14%
// Amphibian - is a reroll when rolled and is not offered when picking. Nate's
// answer, D5 (#1133): nothing is invented.
export const UNPRINTED_TABLE = {
  page: '93',
  says: 'routes to a table the book never prints: rerolled, and not offered',
};
// THE SAME EFFECT ENTRY TWICE - Metal Head through Characteristics and again
// through a Stigmata's biomechanical route, or one Stigmata rolled twice by a
// combination. The book does not print this case; it gives the G.M. a reroll
// for a ridiculous result (printed 91-92), and a Morphus holding one entry's
// bonuses twice is that. The app's reading, not the book's words. Routes are
// exempt: "if the same category comes up twice, roll twice on that table"
// (printed 92).
export const DUPLICATE_ENTRY = {
  page: '91-92',
  says: 'this Morphus already has this entry: rerolled, and not offered (the app\'s reading)',
};

// ─── the catalog, as tables ───

// Rows from the catalog endpoint or straight from D1 (JSON columns as strings
// or already decoded) -> { entries: table -> rows by band, byKey, intro }.
export function morphusTables(rows) {
  const entries = new Map();
  const byKey = new Map();
  const intro = new Map();
  for (const raw of rows || []) {
    if (!raw || typeof raw.key !== 'string') continue;
    const page = String(raw.source_book || '').match(/p\.\s*([\d-]+)/)?.[1] ?? null;
    const row = {
      ...raw,
      roll_low: Number(raw.roll_low), roll_high: Number(raw.roll_high),
      routes: parseJson(raw.routes), bonuses: parseJson(raw.bonuses), sub_choices: parseJson(raw.sub_choices),
      page,
    };
    if (row.kind === 'intro') { intro.set(row.table_name, row); continue; }
    byKey.set(row.key, row);
    if (!entries.has(row.table_name)) entries.set(row.table_name, []);
    entries.get(row.table_name).push(row);
  }
  for (const list of entries.values()) list.sort((a, b) => a.roll_low - b.roll_low);
  return { entries, byKey, intro };
}

const printed = (tables, table) => (tables.entries.get(table) || []).length > 0;
const hasChoices = (row) => Array.isArray(row?.sub_choices) && row.sub_choices.length > 0;
const matches = (re, value) => typeof value === 'string' && re.test(value);

// ─── replay ───

// The items an entry puts on the queue once it is decided. `origin` is the index
// of the decision that queued it, `slot` which of its rolls this is.
function childrenOf(row, decision, index) {
  const rule = MORPHUS_RULES[row.key];
  const out = [];
  if (Array.isArray(row.routes) && (!rule?.routesOnlyWith || matches(rule.routesOnlyWith, decision.sub_choice))) {
    for (const r of row.routes) {
      for (let s = 0; s < (Number(r?.count) || 0); s++) {
        out.push({ table: r.table, origin: index, slot: s, optional: false });
      }
    }
  }
  if (rule?.extraRoll && matches(rule.extraRoll.when, decision.sub_choice)) {
    out.push({ table: rule.extraRoll.table, origin: index, slot: 0, optional: true });
  }
  return out;
}

// What the player may take for a pending item, and what is ruled out and why.
// The ONE place a rule excludes anything: `rollOn` rerolls exactly what this
// excludes, and the picker offers exactly what this offers.
export function entriesFor(tables, steps, item) {
  const offered = [];
  const excluded = [];
  if (!item) return { offered, excluded };
  const origin = item.origin != null ? steps[item.origin]?.row : null;
  const rule = origin ? MORPHUS_RULES[origin.key] : null;
  const held = new Set(steps.filter((s) => s.row?.kind === 'effect').map((s) => s.row.key));
  for (const row of tables.entries.get(item.table) || []) {
    let why = null;
    if (rule?.children?.kinds?.includes(row.kind)
        || (rule?.children?.from != null && row.roll_low >= rule.children.from)) {
      why = { says: rule.says, page: rule.page, rule: origin.key };
    } else if (row.kind !== 'effect' && Array.isArray(row.routes)
        && row.routes.some((r) => !printed(tables, r?.table))) {
      why = { ...UNPRINTED_TABLE, rule: 'unprinted-table' };
    } else if (row.kind === 'effect' && held.has(row.key)) {
      why = { ...DUPLICATE_ENTRY, rule: 'duplicate-entry' };
    }
    if (why) excluded.push({ row, ...why });
    else offered.push(row);
  }
  return { offered, excluded };
}

export function replayMorphus(tables, decisions = []) {
  const steps = [];
  const queue = [{ table: MORPHUS_START, origin: null, slot: 0, optional: false }];
  const problems = [];
  for (const [index, d] of (decisions || []).entries()) {
    const item = queue.shift();
    if (!item) { problems.push(`decision ${index + 1} has no table left to resolve`); break; }
    if (d?.skip) {
      if (!item.optional) { problems.push(`decision ${index + 1} skips the ${item.table} Table, which is not optional`); break; }
      steps.push({ index, item, row: null, decision: d, skipped: true });
      continue;
    }
    const row = tables.byKey.get(d?.key);
    const { offered, excluded } = entriesFor(tables, steps, item);
    if (!row || !offered.includes(row)) {
      const ex = excluded.find((e) => e.row === row);
      problems.push(`decision ${index + 1}: ${d?.key ?? '(no key)'} `
        + (ex ? `is ruled out (${ex.says})` : `is not an entry of the ${item.table} Table`));
      break;
    }
    steps.push({ index, item, row, decision: d, skipped: false });
    queue.unshift(...childrenOf(row, d, index));
  }
  // A sub-choice blocks the next step: two of them decide whether more rolls
  // follow, and a linear "answer, then continue" is one rule rather than two.
  const awaiting = steps.find((s) => hasChoices(s.row) && s.decision.sub_choice == null)?.index ?? null;
  const next = problems.length || awaiting != null ? null : queue[0] || null;
  return {
    steps, queue, next, awaiting, problems,
    done: !problems.length && awaiting == null && queue.length === 0,
  };
}

// ─── deciding ───

const d100 = (rng) => 1 + Math.floor(rng() * 100);
const d6 = (rng) => 1 + Math.floor(rng() * 6);

// A roll on the pending item's table: d100 until it lands on an entry that is
// offered, keeping every ignored roll and the rule that ignored it.
export function rollOn(tables, state, item = state?.next, rng = Math.random) {
  if (!item) return null;
  const { offered, excluded } = entriesFor(tables, state.steps, item);
  if (!offered.length) return null;
  const rows = tables.entries.get(item.table) || [];
  const rerolls = [];
  for (let n = 0; n < 1000; n++) {
    const roll = d100(rng);
    const row = rows.find((r) => roll >= r.roll_low && roll <= r.roll_high);
    const ex = row ? excluded.find((e) => e.row === row) : null;
    if (row && !ex) return { key: row.key, roll, rerolls };
    rerolls.push({ roll, key: row?.key ?? null, why: ex ? ex.says : 'no entry is printed at this roll' });
  }
  return null;
}

// Is `item` (a step's item or a queued one) below the decision at `ancestor`?
function descendsFrom(steps, item, ancestor) {
  let o = item?.origin;
  while (o != null) {
    if (o === ancestor) return true;
    o = steps[o]?.item?.origin;
  }
  return false;
}

// The steps under each of an Animal Form combination's rolls, by slot.
function animalSlots(steps, comboIndex, n) {
  const slots = Array.from({ length: n }, () => []);
  for (const s of steps) {
    if (!s.row || !descendsFrom(steps, s.item, comboIndex)) continue;
    let top = s;
    while (top.item.origin !== comboIndex) top = steps[top.item.origin];
    slots[top.item.slot]?.push(s);
  }
  return slots;
}

// Which animal a 1D6 names: of two, 1-3 the first and 4-6 the second; of three,
// 1-2, 3-4, 5-6 (printed 93-94).
export const animalForDie = (die, n) => Math.min(n - 1, Math.floor((die - 1) / (6 / n)));

// Once every roll under an Animal Form combination is resolved, 1D6 is rolled
// for each bonus any of its animals prints, and kept on the decision that
// completed it - so undoing that decision undoes the dice too.
function withCombinationRolls(tables, decisions, rng) {
  let out = decisions;
  const state = replayMorphus(tables, out);
  for (const step of state.steps) {
    const n = step.row ? MORPHUS_RULES[step.row.key]?.animalBonuses : null;
    if (!n) continue;
    if (out.some((d) => d?.combine?.[step.index])) continue;
    if (state.queue.some((q) => descendsFrom(state.steps, q, step.index))) continue;
    const slots = animalSlots(state.steps, step.index, n);
    const paths = [...new Set(slots.flat().flatMap((s) => bonusPaths(s.row.bonuses)))].sort();
    const combine = {};
    for (const p of paths) combine[p] = d6(rng);
    const last = out[out.length - 1];
    out = [...out.slice(0, -1), { ...last, combine: { ...(last.combine || {}), [step.index]: combine } }];
  }
  return out;
}

// Take `choice` for the pending item: { key, how, roll, rerolls } or { skip }.
// Returns the NEW decision list; throws, naming why, on anything the rules
// refuse. `rollResult` rolls a result's dice - rollTraitResult unless a test
// hands in its own.
export function decide(tables, decisions, choice, { rng = Math.random, rollResult = rollTraitResult } = {}) {
  const state = replayMorphus(tables, decisions);
  if (state.problems.length) throw new Error(state.problems[0]);
  if (state.awaiting != null) {
    throw new Error(`choose how ${state.steps[state.awaiting].row.key} looks before going on`);
  }
  const item = state.next;
  if (!item) throw new Error('every table is resolved');
  let d;
  if (choice?.skip) {
    if (!item.optional) throw new Error(`the ${item.table} Table cannot be skipped here`);
    d = { skip: true };
  } else {
    const row = tables.byKey.get(choice?.key);
    if (!row || row.table_name !== item.table) {
      throw new Error(`${choice?.key} is not an entry of the ${item.table} Table`);
    }
    const { offered, excluded } = entriesFor(tables, state.steps, item);
    if (!offered.includes(row)) {
      throw new Error(`${row.key} is not offered here: ${excluded.find((e) => e.row === row)?.says}`);
    }
    d = {
      key: row.key, how: choice.how === 'roll' ? 'roll' : 'pick',
      roll: Number.isInteger(choice.roll) ? choice.roll : null,
      rerolls: Array.isArray(choice.rerolls) ? choice.rerolls : [],
      sub_choice: null,
      rolls: rollResult(row, null)?.rolls || {},
    };
  }
  return withCombinationRolls(tables, [...(decisions || []), d], rng);
}

export function rollNext(tables, decisions, opts = {}) {
  const state = replayMorphus(tables, decisions);
  const r = rollOn(tables, state, state.next, opts.rng || Math.random);
  if (!r) throw new Error(state.next ? `nothing on the ${state.next.table} Table can be taken here` : 'nothing to roll');
  return decide(tables, decisions, { ...r, how: 'roll' }, opts);
}

export const pickNext = (tables, decisions, key, opts = {}) => decide(tables, decisions, { key, how: 'pick' }, opts);
export const skipNext = (tables, decisions, opts = {}) => decide(tables, decisions, { skip: true }, opts);
export const undoLast = (decisions) => (decisions || []).slice(0, -1);

// "All rolled": roll until the tables are done or a sub-choice needs the player.
export function rollUntilBlocked(tables, decisions, opts = {}) {
  let out = decisions || [];
  for (let n = 0; n < 200; n++) {
    const state = replayMorphus(tables, out);
    if (!state.next || state.next.optional) break;
    out = rollNext(tables, out, opts);
  }
  return out;
}

// Answer an entry's sub-choice. One that decides whether more rolls follow may
// only change while nothing has been decided after it - undo back to it first.
export function chooseSub(tables, decisions, index, value) {
  const state = replayMorphus(tables, decisions);
  const step = state.steps[index];
  if (!step?.row || !hasChoices(step.row)) throw new Error('that result offers no choice');
  if (!step.row.sub_choices.includes(value)) throw new Error(`"${value}" is not one of ${step.row.key}'s choices`);
  const rule = MORPHUS_RULES[step.row.key];
  const steers = !!(rule?.routesOnlyWith || rule?.extraRoll);
  if (steers && index !== decisions.length - 1 && decisions[index].sub_choice !== value) {
    throw new Error(`${step.row.key}'s choice decides what is rolled next: undo back to it to change it`);
  }
  const out = decisions.slice();
  out[index] = { ...out[index], sub_choice: value };
  return out;
}

// ─── what the character stores ───

// Every Animal Form combination: its animals by slot, and each bonus's 1D6.
export function animalCombinations(tables, decisions) {
  const state = replayMorphus(tables, decisions);
  const out = [];
  for (const step of state.steps) {
    const n = step.row ? MORPHUS_RULES[step.row.key]?.animalBonuses : null;
    if (!n) continue;
    const combine = (decisions || []).map((d) => d?.combine?.[step.index]).find(Boolean) || null;
    const slots = animalSlots(state.steps, step.index, n);
    out.push({
      index: step.index, key: step.row.key, n, slots,
      bonuses: combine ? Object.entries(combine).map(([path, die]) => ({ path, die, slot: animalForDie(die, n) })) : null,
    });
  }
  return out;
}

// `characters.second_form.results`, in the order decided. An Animal Form
// combination's bonus that went to another animal is listed in `omit`.
export function morphusResults(tables, decisions) {
  const state = replayMorphus(tables, decisions);
  const omit = new Map();
  for (const combo of animalCombinations(tables, decisions)) {
    for (const { path, slot } of combo.bonuses || []) {
      combo.slots.forEach((list, s) => {
        if (s === slot) return;
        for (const st of list) {
          if (!bonusPaths(st.row.bonuses).includes(path)) continue;
          if (!omit.has(st.index)) omit.set(st.index, []);
          omit.get(st.index).push(path);
        }
      });
    }
  }
  return state.steps.filter((s) => s.row).map((s) => ({
    key: s.row.key,
    sub_choice: s.decision.sub_choice ?? null,
    rolls: isObj(s.decision.rolls) ? s.decision.rolls : {},
    ...(omit.has(s.index) ? { omit: omit.get(s.index) } : {}),
  }));
}

// ─── words, for the wizard ───

const LABEL = {
  IQ: 'I.Q.', ME: 'M.E.', MA: 'M.A.', PS: 'P.S.', PP: 'P.P.', PE: 'P.E.', PB: 'P.B.', Spd: 'Spd',
  sdc: 'S.D.C.', hp: 'H.P.',
};
const signed = (v) => (typeof v === 'number' ? (v < 0 ? String(v) : `+${v}`) : `+${String(v).toUpperCase()}`);

// What an entry adds, one phrase per bonus, with the roll beside any dice and a
// bonus another animal got marked as such.
export function effectParts(row, rolls = {}, omit = []) {
  const b = row?.bonuses;
  if (!isObj(b)) return [];
  return bonusPaths(b).map((path) => {
    const [g, k] = path.split('.');
    const v = (g === 'pools' ? b.pools : b[g])?.[k];
    const r = rolls?.[g]?.[k];
    const label = LABEL[k] || k.replace(/_/g, ' ');
    return {
      path,
      text: `${label} ${signed(v)}${typeof v === 'string' && Number.isFinite(r) ? ` (rolled ${r})` : ''}`,
      omitted: (omit || []).includes(path),
    };
  }).concat(Object.entries(isObj(b.attribute_minimums) ? b.attribute_minimums : {})
    .map(([k, v]) => ({ path: `attribute_minimums.${k}`, text: `${LABEL[k] || k} at least ${v}`, omitted: false })));
}

// The Horror Factor an entry contributes, in words, or null.
export function horrorPart(row, rolls = {}) {
  if (Number.isInteger(row?.horror_factor_set)) return `sets Horror Factor ${row.horror_factor_set}`;
  const hf = row?.horror_factor;
  if (hf == null || String(hf).trim() === '') return null;
  if (/^\s*\d+\s*$/.test(String(hf))) return `Horror Factor +${Number(hf)}`;
  return `Horror Factor +${String(hf).toUpperCase()}${Number.isFinite(rolls?.horror_factor) ? ` (rolled ${rolls.horror_factor})` : ''}`;
}

// ─── the map, held to the rows ───

// Every way MORPHUS_RULES could have drifted from the catalog: a rule naming no
// entry, a band boundary no entry starts at, a sub-choice pattern matching
// other than exactly one choice, a +1 the row no longer carries, and a route
// to a table that is neither printed nor one of the two the book is known to
// omit. Empty when they agree.
const KNOWN_UNPRINTED = ['Bear', 'Amphibian'];
export function rulesDisagreeWithRows(tables) {
  const out = [];
  for (const [key, rule] of Object.entries(MORPHUS_RULES)) {
    const row = tables.byKey.get(key);
    if (!row) { out.push(`${key}: no such entry`); continue; }
    if (rule.children?.from != null) {
      const targets = [...new Set((row.routes || []).map((r) => r.table))];
      for (const t of targets) {
        if (!(tables.entries.get(t) || []).some((e) => e.roll_low === rule.children.from)) {
          out.push(`${key}: no entry of the ${t} Table starts at ${rule.children.from}%`);
        }
      }
    }
    for (const re of [rule.routesOnlyWith, rule.extraRoll?.when].filter(Boolean)) {
      const hits = (row.sub_choices || []).filter((c) => re.test(c)).length;
      if (hits !== 1) out.push(`${key}: ${re} matches ${hits} of its sub-choices, not one`);
    }
    if (rule.horrorFactor != null && String(row.horror_factor ?? '').trim() !== String(rule.horrorFactor)) {
      out.push(`${key}: the row's horror_factor is ${row.horror_factor}, the rule says +${rule.horrorFactor}`);
    }
    if (rule.page && row.page && !String(row.page).split('-').includes(String(rule.page))) {
      out.push(`${key}: the rule cites printed ${rule.page}, the row ${row.page}`);
    }
  }
  for (const row of tables.byKey.values()) {
    for (const r of row.routes || []) {
      if (!printed(tables, r.table) && !KNOWN_UNPRINTED.includes(r.table)) {
        out.push(`${row.key}: routes to ${r.table}, which has no entries`);
      }
    }
  }
  return out;
}
