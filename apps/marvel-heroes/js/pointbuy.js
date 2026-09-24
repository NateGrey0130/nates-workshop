// Point Buy: a hero bought with a GM's budget instead of rolled. Pure: no DOM,
// no fetch, so the smoke suite can run it in Node.
//
// R24: this is a house rule, not from any book. The GM gives a point limit
// and the highest rank allowed. Each of the seven abilities costs its exact
// rank number (Excellent 24 costs 24). Choosing a Power costs nothing; its
// rank costs its number, and a Power the book marks * (two slots) pays double.
// Nothing else draws on the budget. The GM's grants - Powers, ability bonuses,
// anything else written down - each carry an "exclude from points" tick, on by
// default, and ignore the cap, because the GM chose to give them. Going over
// the limit warns and still saves.
//
// A build is plain JSON, and is what the saved row keeps:
//   { limit, cap, abilities: { fighting: 20 | null, ... },
//     resources, popularity,                      rank ids, free
//     powers:  [{ code, number, gm, free }],      gm = listed under the grants
//     bonuses: [{ ability, amount, reason, free }],
//     items:   [{ name, notes, points, free }] }

import { PRIMARY, STEPS } from './generator.js';
import { rng } from './dice.js';

export const DEFAULT_CAP = 'unearthly';
const NEW_POWER_UP_TO = 10;          // a new Power starts at the most you can afford, up to Good

export function emptyBuild(setup = {}) {
  return {
    limit: Number.isInteger(setup.limit) && setup.limit >= 0 ? setup.limit : null,
    cap: setup.cap || DEFAULT_CAP,
    abilities: Object.fromEntries(PRIMARY.map((a) => [a, null])),
    resources: 'typical', popularity: 'typical',
    powers: [], bonuses: [], items: [],
  };
}

// A saved or stored build, made whole: anything missing or of the wrong type
// takes its empty value, so an older page's build still opens.
export function normalise(b, pb) {
  const out = emptyBuild();
  if (!b || typeof b !== 'object') return out;
  const whole = (n, lo = 0) => (Number.isInteger(n) && n >= lo ? n : null);
  out.limit = whole(b.limit);
  if (pb.capRanks.some((r) => r.id === b.cap)) out.cap = b.cap;
  for (const a of PRIMARY) out.abilities[a] = whole(b.abilities?.[a], 1);
  for (const k of ['resources', 'popularity']) if (pb.freeRanks.some((r) => r.id === b[k])) out[k] = b[k];
  const list = (x) => (Array.isArray(x) ? x : []);
  out.powers = list(b.powers).filter((p) => pb.powerByCode[p?.code]).map((p) => ({
    code: p.code, number: whole(p.number, 1) ?? 1, gm: !!p.gm, free: p.gm ? p.free !== false : false }));
  out.bonuses = list(b.bonuses).filter((x) => PRIMARY.includes(x?.ability)).map((x) => ({
    ability: x.ability, amount: whole(x.amount) ?? 0, reason: String(x.reason ?? ''), free: x.free !== false }));
  out.items = list(b.items).filter((x) => x && typeof x === 'object').map((x) => ({
    name: String(x.name ?? ''), notes: String(x.notes ?? ''), points: whole(x.points) ?? 0, free: x.free !== false }));
  return out;
}

export function makePointBuy(data, gen) {
  const ladder = data.ranks.ranks;
  const numbered = ladder.filter((r) => r.standard);           // Feeble to Class 5000
  const rankById = Object.fromEntries(ladder.map((r) => [r.id, r]));
  const powerByCode = Object.fromEntries(data.powers.powers.map((p) => [p.code, p]));
  // Resources and Popularity: the ranks the generator can give them.
  const freeRanks = ladder.filter((r) => r.initial !== undefined);

  const rankFor = (n) => (Number.isFinite(n) && n >= 1
    ? numbered.find((r) => n >= r.min && (r.max === null || n <= r.max)) ?? null : null);
  const capMax = (cap) => rankById[cap]?.max ?? Infinity;
  const multiplier = (code) => (powerByCode[code]?.double ? 2 : 1);

  // ------------------------------------------------------------ the ledger
  function ledger(b) {
    const max = capMax(b.cap);
    const lines = [];
    for (const a of PRIMARY) {
      const n = b.abilities[a];
      lines.push({ kind: 'ability', key: a, number: n, cost: n ?? 0, overCap: n !== null && n > max });
    }
    b.powers.forEach((p, i) => {
      const x = multiplier(p.code);
      lines.push({ kind: 'power', key: i, code: p.code, number: p.number, multiplier: x, gm: p.gm,
        cost: p.gm && p.free ? 0 : p.number * x,
        // A grant ignores the cap: the GM chose it.
        overCap: !p.gm && p.number > max });
    });
    b.bonuses.forEach((x, i) => lines.push({ kind: 'bonus', key: i, cost: x.free ? 0 : x.amount, overCap: false }));
    b.items.forEach((x, i) => lines.push({ kind: 'item', key: i, cost: x.free ? 0 : x.points, overCap: false }));
    const sum = (f) => lines.filter(f).reduce((s, l) => s + l.cost, 0);
    const spent = sum(() => true);
    return {
      lines, spent,
      abilities: sum((l) => l.kind === 'ability'),
      powers: sum((l) => l.kind === 'power' && !l.gm),
      grants: sum((l) => l.kind !== 'ability' && !(l.kind === 'power' && !l.gm)),
      remaining: b.limit === null ? null : b.limit - spent,
      overCap: lines.filter((l) => l.overCap),
      empty: PRIMARY.filter((a) => b.abilities[a] === null),
    };
  }

  // The highest number one line could take and stay inside both the limit and
  // the cap, everything else held where it is; null when nothing fits. With no
  // limit set, only the cap bounds it.
  function maxAffordable(b, kind, key) {
    const l = ledger(b);
    const line = l.lines.find((x) => x.kind === kind && x.key === key);
    const x = kind === 'power' ? line.multiplier : 1;
    const others = l.spent - line.cost;
    const cap = kind === 'power' && b.powers[key].gm ? Infinity : capMax(b.cap);
    const byPoints = b.limit === null ? Infinity : Math.floor((b.limit - others) / x);
    const n = Math.min(cap, byPoints);
    return n >= 1 && Number.isFinite(n) ? n : null;
  }

  // The up and down buttons: to the next rank's standard number above, or the one
  // below. So 24 goes up to Remarkable 30 and down to Excellent 20, and 20 goes
  // down to Good 10. Up stops at the cap.
  function step(n, dir, cap = null) {
    const max = cap ? capMax(cap) : Infinity;
    if (dir > 0) {
      const next = numbered.find((r) => r.standard > (n ?? 0));
      return next && next.standard <= max ? next.standard : null;
    }
    if (n === null) return null;
    const prev = [...numbered].reverse().find((r) => r.standard < n);
    return prev ? prev.standard : null;
  }

  // A Power just added: the most the budget allows, up to Good, never below 1.
  function startingNumber(b, code, gm = false) {
    const x = multiplier(code);
    const left = b.limit === null ? Infinity : b.limit - ledger(b).spent;
    const cap = gm ? Infinity : capMax(b.cap);
    return Math.max(1, Math.min(NEW_POWER_UP_TO, cap, Math.floor(left / x)));
  }

  // ------------------------------------------------------------ the hero
  // Totals include the GM's bonuses; Health and Karma are the book's sums.
  function hero(b) {
    const total = Object.fromEntries(PRIMARY.map((a) => [a,
      b.abilities[a] === null ? null
        : b.abilities[a] + b.bonuses.filter((x) => x.ability === a).reduce((s, x) => s + x.amount, 0)]));
    const n = (a) => total[a] ?? 0;
    return {
      total,
      health: n('fighting') + n('agility') + n('strength') + n('endurance'),
      karma: n('reason') + n('intuition') + n('psyche'),
    };
  }

  // The saved snapshot, in the generator's shape so the sheet reads both: a
  // Point Buy hero has no body, origin, weakness, Talents or Contacts.
  function snapshot(b) {
    const h = hero(b);
    const l = ledger(b);
    const ability = (n) => {
      const r = rankFor(n);
      return r ? { rank: r.id, name: r.name, number: n } : { rank: 'shift-0', name: '-', number: 0 };
    };
    const free = (id) => ({ rank: id, name: rankById[id].name, number: gen.numberOf(id) });
    return {
      v: 1,
      mode: 'pointbuy',
      body: null, origin: null, forms: null, weakness: null, talents: [], contacts: [],
      abilities: { ...Object.fromEntries(PRIMARY.map((a) => [a, ability(h.total[a])])),
        resources: free(b.resources), popularity: free(b.popularity) },
      health: h.health, karma: h.karma,
      powers: b.powers.map((p) => {
        const r = rankFor(p.number);
        return { code: p.code, name: powerByCode[p.code].name, rank: r.id, rankName: r.name, number: p.number,
          slots: multiplier(p.code), source: p.gm ? 'granted' : 'bought' };
      }),
      grants: {
        bonuses: b.bonuses.map((x) => ({ ability: x.ability, amount: x.amount, reason: x.reason, free: x.free })),
        items: b.items.filter((x) => x.name.trim()).map((x) => ({ name: x.name, notes: x.notes, points: x.points, free: x.free })),
      },
      pointbuy: { limit: b.limit, spent: l.spent, cap: rankById[b.cap].name },
    };
  }

  // ------------------------------------------------------------ calibration
  // What a rolled hero would cost at these prices: its seven abilities, and its
  // Powers at their numbers, doubled for a two-slot Power. Resources and
  // Popularity are free here, so they are left out. A Changeling is priced by
  // its first form. The seed is fixed, so the answer is the same every time.
  function rolledCosts(count = 400, seed = 24) {
    const next = rng(seed);
    const costs = [];
    for (let i = 0; i < count; i++) {
      const seeds = Object.fromEntries(STEPS.map((s) => [s, Math.floor(next() * 2 ** 32)]));
      const h = gen.build({ seeds, picks: {} });
      costs.push(PRIMARY.reduce((s, a) => s + h.abilities[a].number, 0)
        + h.powers.reduce((s, p) => s + gen.numberOf(p.rank) * p.slots, 0));
    }
    costs.sort((a, b) => a - b);
    const at = (q) => costs[Math.min(costs.length - 1, Math.floor(q * costs.length))];
    return { count, median: at(0.5), low: at(0.25), high: at(0.75) };
  }

  return {
    ledger, maxAffordable, step, startingNumber, hero, snapshot, rolledCosts, rankFor, multiplier,
    capRanks: numbered, freeRanks, powerByCode, capMax,
  };
}
