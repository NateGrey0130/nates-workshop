// The NPC roller: the generator (js/generator.js), run with a GM's constraints,
// ending in the same snapshot a saved hero has (js/sheet.js), so the sheet
// renderer draws an NPC exactly as it draws a hero. Pure: the endpoint
// (functions/api/marvel-heroes/campaigns/[id]/npcs/generate.js) loads the data
// and writes the row, and the suite runs this with fixed seeds.
//
// The options, all optional:
//   body     a body type id to use instead of rolling one
//   origin   an origin id, likewise
//   powers   exactly this many Powers. The generator's own dice decide the
//            count, so this rolls whole heroes until one has it, buying extra
//            Powers with Resources as the book allows (UPB p.14) when the dice
//            fall short. A count no build reaches is refused, never padded.
//   ceiling  a rank id: no ability and no Power above it. A rank over the
//            ceiling is set TO the ceiling, and Health and Karma follow the
//            numbers they are sums of.

import { newSeeds, PRIMARY } from './generator.js';
import { snapshot } from './sheet.js';

const MAX_POWERS = 18;     // the counts table's highest maximum
const TRIES = 600;

// -> { options } or { error }, checked against the data so a body type, origin
// or rank the app does not have is refused by name.
export function parseNpcOptions(body, data) {
  const b = body && typeof body === 'object' && !Array.isArray(body) ? body : {};
  const out = {};
  const pickFrom = (key, list, what) => {
    if (b[key] === undefined || b[key] === null || b[key] === '') return null;
    if (!list.some((x) => x.id === b[key])) return `Not a ${what}: ${String(b[key]).slice(0, 40)}`;
    out[key] = b[key];
    return null;
  };
  const err = pickFrom('body', data['body-types'].types, 'body type')
    || pickFrom('origin', data.origins.origins, 'origin')
    || pickFrom('ceiling', data.ranks.ranks.filter((r) => !['shift-0', 'beyond'].includes(r.id)), 'rank');
  if (err) return { error: err };
  if (b.powers !== undefined && b.powers !== null && b.powers !== '') {
    if (!Number.isInteger(b.powers) || b.powers < 1 || b.powers > MAX_POWERS) return { error: `powers must be a whole number from 1 to ${MAX_POWERS}` };
    out.powers = b.powers;
  }
  return { options: out };
}

// A built hero with every rank above `ceiling` lowered to it. Health and Karma
// are sums of ability numbers (UPB p.11), so they are summed again; a body
// type's Health multiplier is kept.
function applyCeiling(h, gen, ceiling) {
  if (!ceiling) return h;
  const idx = Object.fromEntries(gen.ladder.map((r, i) => [r.id, i]));
  const cap = (id) => (idx[id] > idx[ceiling] ? ceiling : id);
  const capSet = (ab) => {
    for (const k of Object.keys(ab)) {
      const r = cap(ab[k].rank);
      if (r !== ab[k].rank) ab[k] = { ...ab[k], rank: r, number: gen.numberOf(r), capped: true };
    }
  };
  const sum = (ab, keys) => keys.reduce((s, k) => s + ab[k].number, 0);
  const physical = PRIMARY.slice(0, 4), mental = PRIMARY.slice(4);
  const out = structuredClone(h);
  const mult = (ab, health) => { const s = sum(ab, physical); return s ? health / s : 1; };
  const m = mult(out.abilities, out.health);
  capSet(out.abilities);
  out.health = Math.round(sum(out.abilities, physical) * m);
  out.karma = sum(out.abilities, mental);
  if (out.forms) {
    for (const f of out.forms) {
      const fm = mult(f.abilities, f.health);
      capSet(f.abilities);
      f.health = Math.round(sum(f.abilities, physical) * fm);
      f.karma = sum(f.abilities, mental);
    }
  }
  out.powers = out.powers.map((p) => ({ ...p, rank: cap(p.rank) }));
  return out;
}

// -> { build, snapshot } or { error }. `seedsFn` makes a fresh set of step
// seeds (newSeeds by default; the suite passes a counter).
export function rollNpc(data, gen, options = {}, seedsFn = newSeeds) {
  const picks = {};
  if (options.body) picks.body = options.body;
  if (options.origin) picks.origin = options.origin;
  const want = options.powers ?? null;
  for (let i = 0; i < (want ? TRIES : 1); i++) {
    const seeds = seedsFn();
    let use = { ...picks };
    let h = gen.build({ seeds, picks: use });
    if (want && h.powers.length !== want) {
      // Short by a few: buy them, if the book's maximum for this roll allows.
      const short = want - h.powers.length;
      if (short < 1 || h.counts.powers.initial + short > h.counts.powers.max) continue;
      use = { ...picks, bought: { powers: short } };
      h = gen.build({ seeds, picks: use });
      if (h.powers.length !== want) continue;
    }
    const capped = applyCeiling(h, gen, options.ceiling);
    return { build: { seeds, picks: use }, snapshot: { ...snapshot(capped, gen, data, []), npc: { ceiling: options.ceiling ?? null } } };
  }
  return { error: `No roll gave exactly ${want} Powers${options.body ? ' for that body type' : ''} in ${TRIES} tries. Ask for a different number.` };
}

// The data files the generator and the snapshot read.
export const NPC_DATA = ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts'];
