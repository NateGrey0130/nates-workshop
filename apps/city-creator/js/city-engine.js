// The City Creator's engine: settings and a seed in, a whole city out.
//
// A PURE module, like js/npc-generate.js and shared/js/namegen.js: no DOM, no
// fetch, and every random draw comes from a seeded generator. So the same seed
// and the same settings always give the same city, and a test can call it
// directly. The page (city.js) holds the settings, the locks and the saved
// city, and asks this module for new ones.
//
// ── Sections are seeded separately ──
// Each section (overview, districts, places, shops, NPCs, quirks, rumours)
// draws from its own generator, seeded from the city seed and the section's
// name. Asking for two more NPCs therefore changes the NPCs and nothing else,
// and a reroll of one entry reseeds that entry alone.
//
// ── Lock and reroll ──
// A city's entries each carry an id. rerollCity() keeps every locked entry
// exactly as it was and rebuilds the rest from a new seed; rerollEntry()
// rebuilds one. Names already on a kept entry are never handed out again.
//
// ── Refuse, never pad ──
// The rule every generator here keeps. A table line whose {slot} the city
// cannot fill is skipped, not filled with a stand-in; a name theme that runs
// out leaves the entry unnamed and says so in `warnings`, rather than
// repeating a name.

import { generateNames } from '../../../shared/js/namegen.js';
import * as PF from './city-tables-pf.js';

const TABLES = { 'palladium-fantasy': PF };
export const SUPPORTED_SYSTEMS = Object.keys(TABLES);

// ── the seeded generator ──

// mulberry32 over a 32-bit seed, and a string hash to derive section seeds.
export function rng(seed) {
  let s = seed >>> 0;
  return () => {
    s = (s + 0x6d2b79f5) >>> 0;
    let t = s;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
export function hash(...parts) {
  let h = 2166136261 >>> 0;
  for (const ch of parts.join('|')) {
    h ^= ch.charCodeAt(0);
    h = Math.imul(h, 16777619) >>> 0;
  }
  return h >>> 0;
}
export const newSeed = () => (Math.random() * 4294967296) >>> 0;

const pick = (r, list) => list[Math.floor(r() * list.length)];
const between = (r, [lo, hi]) => lo + Math.floor(r() * (hi - lo + 1));
// n distinct items, in a random order; fewer if the list is shorter.
function sample(r, list, n) {
  const a = [...list];
  const out = [];
  for (let i = 0; i < a.length && out.length < n; i++) {
    const j = i + Math.floor(r() * (a.length - i));
    [a[i], a[j]] = [a[j], a[i]];
    out.push(a[i]);
  }
  return out;
}

// ── settings ──

export function sizeFor(population, system = 'palladium-fantasy') {
  const T = TABLES[system];
  return T.SIZES.find((s) => population <= s.max) || T.SIZES[T.SIZES.length - 1];
}
export const suggestions = (system = 'palladium-fantasy') =>
  TABLES[system].SIZES.map((s) => ({ id: s.id, label: s.label, population: s.suggest }));

// What stops Generate: a list of reasons, empty when the settings are usable.
export function settingsProblems(s) {
  const out = [];
  if (!TABLES[s.system]) out.push(`No tables for ${s.system} yet`);
  if (!Number.isFinite(s.population) || s.population < 1) out.push('Population must be at least 1');
  if (!Number.isFinite(s.npcCount) || s.npcCount < 0 || s.npcCount > 200) out.push('Named NPCs must be 0-200');
  const races = s.races || [];
  if (!races.length) out.push('Add at least one race');
  const total = races.reduce((n, x) => n + (Number(x.pct) || 0), 0);
  if (Math.round(total * 100) !== 10000) out.push(`The racial breakdown totals ${total}%, not 100%`);
  if (races.some((x) => !(Number(x.pct) > 0))) out.push('Every race row needs a share above 0%');
  if (new Set(races.map((x) => x.id)).size !== races.length) out.push('A race is listed twice');
  if (s.everyRace && s.npcCount < races.length) {
    out.push(`"At least one NPC of every race" needs ${races.length} named NPCs; there are ${s.npcCount}`);
  }
  return out;
}

// "Rest are human": the rows plus a human row holding what is left.
export function restAreHuman(races, human = { id: 'human', name: 'Human' }) {
  const others = races.filter((x) => x.id !== human.id);
  const used = others.reduce((n, x) => n + (Number(x.pct) || 0), 0);
  const left = Math.round((100 - used) * 100) / 100;
  return left > 0 ? [...others, { ...human, pct: left }] : others;
}

// ── names ──
//
// With a pool (the one AI call), names come from it; without, from the
// setting's name themes. Either way through one function, so a used name is
// never handed out twice in one city.
function namer(ctx) {
  const T = ctx.T;
  return {
    person(r, raceId) {
      const pool = ctx.pool && (ctx.pool.cultures?.[raceId] || ctx.pool.cultures?.default);
      if (pool) {
        const given = [...(pool.given || [])];
        const family = [...(pool.family || [])];
        for (let i = 0; i < 60; i++) {
          const n = family.length ? `${pick(r, given)} ${pick(r, family)}` : pick(r, given);
          if (n && !ctx.used.has(n.toLowerCase())) { ctx.used.add(n.toLowerCase()); return n; }
        }
        ctx.warnings.add(`The name pool ran out of new ${raceId} names`);
        return '';
      }
      const theme = T.RACE_NAME_THEMES[raceId] || T.DEFAULT_PEOPLE_THEME;
      const res = generateNames({ theme, count: 1, exclude: [...ctx.used], random: r });
      if (!res.names.length) { ctx.warnings.add(res.reason); return ''; }
      ctx.used.add(res.names[0].toLowerCase());
      return res.names[0];
    },
    place(r, kind) {
      const poolKey = { tavern: 'shop', shop: 'shop', district: 'district' }[kind];
      const list = ctx.pool?.[poolKey];
      if (list?.length) {
        const free = list.filter((n) => !ctx.used.has(n.toLowerCase()));
        if (free.length) { const n = pick(r, free); ctx.used.add(n.toLowerCase()); return n; }
        ctx.warnings.add(`The name pool ran out of ${poolKey} names`);
        return '';
      }
      const res = generateNames({ theme: T.PLACES_THEME, kind, count: 1, exclude: [...ctx.used], random: r });
      if (!res.names.length) { ctx.warnings.add(res.reason); return ''; }
      ctx.used.add(res.names[0].toLowerCase());
      return res.names[0];
    },
  };
}

// ── templates ──

// Fill {slots} from the city. A slot the city has nothing for makes the line
// unusable (null), and the caller picks another - never a stand-in.
function fill(r, line, city) {
  let ok = true;
  const out = line.replace(/\{(\w+)\}/g, (_, slot) => {
    const src = {
      npc: city.npcs.filter((n) => n.name).map((n) => n.name),
      district: city.districts.map((d) => d.name).filter(Boolean),
      place: city.places.map((p) => p.name),
      shop: city.shops.map((s) => s.name).filter(Boolean),
      faction: (city.overview?.factions || []).map((f) => f.name),
      city: [city.overview?.name].filter(Boolean),
      race: (city.settings?.races || []).map((x) => x.name),
    }[slot] || [];
    if (!src.length) { ok = false; return ''; }
    return pick(r, src);
  });
  return ok ? out : null;
}
function fillFrom(r, table, city, tries = 30) {
  for (let i = 0; i < tries; i++) {
    const got = fill(r, pick(r, table), city);
    if (got) return got;
  }
  return null;
}

// ── the sections ──

function makeOverview(ctx, r, keepName = null) {
  const { T, settings } = ctx;
  const size = sizeFor(settings.population, settings.system);
  const name = keepName || (ctx.pool?.city?.length ? pick(r, ctx.pool.city)
    : `${pick(r, T.CITY_NAME.pre)}${pick(r, T.CITY_NAME.suf)}`);
  const walled = r() < size.walls;
  const factionCount = between(r, size.factions);
  return {
    id: 'overview', name, population: settings.population, size: size.label,
    walls: walled ? pick(r, T.WALLS) : null,
    government: pick(r, T.GOVERNMENTS),
    wealth: pick(r, T.WEALTH).label,
    trade: pick(r, T.TRADES),
    factions: sample(r, T.FACTIONS, factionCount).map((line, i) => {
      const [name, goal] = line.split(/, (?=who )/);
      return { id: `faction-${i}`, name, goal: goal || '' };
    }),
  };
}

// The race quarters first: every race at 20% or more has one.
function quarterRaces(settings) {
  return (settings.races || []).filter((x) => Number(x.pct) >= 20 && x.id !== 'human');
}

function makeDistrict(ctx, r, i, quarter = null) {
  const { T } = ctx;
  const kind = quarter ? `${quarter.name} Quarter` : pick(r, T.DISTRICT_KINDS);
  const own = quarter ? '' : ctx.names.place(r, 'district');
  return {
    id: quarter ? `district-q-${quarter.id}` : `district-${i}`,
    name: quarter ? `${quarter.name} Quarter` : (own || kind),
    kind, race: quarter?.id || null,
    mood: pick(r, T.MOODS),
    encounters: sample(r, T.ENCOUNTERS, 6).map((text, n) => ({ roll: n + 1, text })),
  };
}

// Which shop types this city can have: the setting's own, and any tied to a
// race in its breakdown.
function shopTypes(ctx) {
  const extra = (ctx.settings.races || []).flatMap((x) => ctx.T.RACE_LINES[x.id]?.shops || []);
  return [...ctx.T.SHOP_TYPES, ...extra];
}

function makeShop(ctx, r, i, city) {
  const t = pick(r, shopTypes(ctx));
  const kind = t.type === 'tavern' ? 'tavern' : 'shop';
  const wealth = ctx.T.WEALTH.find((w) => w.label === city.overview.wealth);
  // Prices lean with the city's wealth, then a shop's own habits.
  const lean = Math.max(0, Math.min(ctx.T.PRICE_LEVELS.length - 1,
    Math.floor(r() * ctx.T.PRICE_LEVELS.length) + (wealth.price > 1.2 ? 1 : wealth.price < 0.9 ? -1 : 0)));
  return {
    id: `shop-${i}`, name: ctx.names.place(r, kind), type: t.label,
    specialty: pick(r, t.specialties), price: ctx.T.PRICE_LEVELS[lean],
    quirk: pick(r, ctx.T.PERSONALITIES).replace(/^/, 'the owner '),
    district: pick(r, city.districts)?.name || null, owner: null,
  };
}

// An NPC's race: a draw weighted by the breakdown, unless `race` is fixed.
function drawRace(r, races) {
  const total = races.reduce((n, x) => n + Number(x.pct), 0);
  let at = r() * total;
  for (const x of races) { at -= Number(x.pct); if (at < 0) return x; }
  return races[races.length - 1];
}

function makeNpc(ctx, r, i, race = null, role = null) {
  const { T } = ctx;
  const x = race || drawRace(r, ctx.settings.races);
  return {
    id: `npc-${i}`, name: ctx.names.person(r, x.id), race: x.name, raceId: x.id,
    role: role || pick(r, T.NPC_ROLES), look: pick(r, T.LOOKS), quirk: pick(r, T.PERSONALITIES),
    want: pick(r, T.WANTS), secret: pick(r, T.SECRETS),
  };
}

// The races the NPCs must cover: one each first when asked, then weighted.
function npcRaces(ctx, r) {
  const races = ctx.settings.races;
  const n = ctx.settings.npcCount;
  const first = ctx.settings.everyRace ? sample(r, races, Math.min(n, races.length)) : [];
  const rest = Array.from({ length: n - first.length }, () => drawRace(r, races));
  return [...first, ...rest];
}

// Owners come from the named NPCs, so they count toward the number the G.M.
// set. With fewer NPCs than shops, an NPC owns more than one shop rather than
// an owner being invented.
function assignOwners(city, r) {
  const npcs = city.npcs.filter((n) => n.name);
  if (!npcs.length) return;
  const order = sample(r, npcs, npcs.length);
  city.shops.forEach((s, i) => {
    if (s.owner && npcs.some((n) => n.id === s.owner)) return;
    const who = order[i % order.length];
    s.owner = who.id;
    if (!/owner|keeper|merchant/.test(who.role)) who.role = `owner of ${s.name || 'a ' + s.type.toLowerCase()}`;
  });
}

function makeQuirks(ctx, r, city) {
  const extra = (ctx.settings.races || []).flatMap((x) => ctx.T.RACE_LINES[x.id]?.quirks || []);
  const n = between(r, [3, 5]);
  // A race's own line leads when that race is in the city, then the general ones.
  const chosen = [...sample(r, extra, Math.min(extra.length, 1)), ...sample(r, ctx.T.CITY_QUIRKS, n)].slice(0, n);
  return chosen.map((text, i) => ({ id: `quirk-${i}`, text }));
}

function makeRumours(ctx, r, city) {
  const out = [];
  const seen = new Set();
  for (let tries = 0; out.length < 10 && tries < 200; tries++) {
    const text = fillFrom(r, ctx.T.RUMOURS, city);
    if (!text || seen.has(text)) continue;
    seen.add(text);
    out.push({ id: `rumour-${out.length}`, roll: out.length + 1, text, true: r() < 0.5 });
  }
  return out;
}

// ── the whole city ──

function context(settings, pool, used = []) {
  const T = TABLES[settings.system];
  const ctx = { T, settings, pool, used: new Set(used.map((n) => n.toLowerCase())), warnings: new Set() };
  ctx.names = namer(ctx);
  return ctx;
}
const sectionRng = (seed, section, n = 0) => rng(hash(seed, section, n));

/**
 * A new city.
 *   settings  { system, population, npcCount, races: [{ id, name, pct }], everyRace }
 *   seed      a 32-bit number
 *   pool      the AI name pool, or null for the built-in names
 */
export function generateCity(settings, seed, pool = null) {
  const problems = settingsProblems(settings);
  if (problems.length) throw new Error(problems.join('; '));
  const ctx = context(settings, pool);
  const size = sizeFor(settings.population, settings.system);
  const city = { version: 1, seed, settings: structuredClone(settings), pool: pool || null,
    overview: null, districts: [], places: [], shops: [], npcs: [], quirks: [], rumours: [], warnings: [],
    locks: [], rolls: {} };

  city.overview = makeOverview(ctx, sectionRng(seed, 'overview'));
  const rd = sectionRng(seed, 'districts');
  const quarters = quarterRaces(settings);
  const plain = between(rd, size.districts);
  city.districts = [
    ...quarters.map((q) => makeDistrict(ctx, rd, 0, q)),
    ...Array.from({ length: plain }, (_, i) => makeDistrict(ctx, rd, i)),
  ];
  const rp = sectionRng(seed, 'places');
  city.places = sample(rp, ctx.T.PLACES, between(rp, size.places))
    .map((name, i) => ({ id: `place-${i}`, name, district: pick(rp, city.districts)?.name || null }));
  const rs = sectionRng(seed, 'shops');
  city.shops = Array.from({ length: between(rs, size.shops) }, (_, i) => makeShop(ctx, rs, i, city));
  const rn = sectionRng(seed, 'npcs');
  city.npcs = npcRaces(ctx, rn).map((race, i) => makeNpc(ctx, rn, i, race));
  assignOwners(city, sectionRng(seed, 'owners'));
  city.quirks = makeQuirks(ctx, sectionRng(seed, 'quirks'), city);
  city.rumours = makeRumours(ctx, sectionRng(seed, 'rumours'), city);
  city.warnings = [...ctx.warnings];
  return city;
}

// Every name the city holds, so a reroll never reuses one.
function namesIn(city) {
  return [city.overview?.name, ...city.districts.map((d) => d.name), ...city.shops.map((s) => s.name),
    ...city.npcs.map((n) => n.name)].filter(Boolean);
}

/**
 * The same city with every unlocked entry rebuilt from a new seed. Locked
 * entries (ids in city.locks) are kept exactly, in their places.
 */
export function rerollCity(city, seed) {
  const locked = new Set(city.locks);
  const fresh = generateCity({ ...city.settings }, seed, city.pool);
  const keep = (a, b) => a.map((x, i) => (locked.has(x.id) ? x : (b[i] || null))).filter(Boolean)
    .concat(b.slice(a.length));
  const out = { ...fresh, locks: [...locked], rolls: { ...city.rolls } };
  out.overview = locked.has('overview') ? city.overview : fresh.overview;
  for (const key of ['districts', 'places', 'shops', 'npcs', 'quirks', 'rumours']) {
    out[key] = keep(city[key], fresh[key]);
  }
  // Names on a kept entry may now appear on a fresh one too: rename those.
  dedupeNames(out, locked);
  assignOwners(out, sectionRng(seed, 'owners'));
  out.rumours.forEach((x, i) => { x.roll = i + 1; });
  return out;
}

function dedupeNames(city, locked) {
  const ctx = context(city.settings, city.pool, []);
  for (const list of [city.districts, city.shops, city.npcs]) {
    for (const x of list) if (locked.has(x.id) && x.name) ctx.used.add(x.name.toLowerCase());
  }
  const r = rng(hash(city.seed, 'dedupe'));
  for (const x of city.npcs) {
    if (locked.has(x.id) || !x.name) continue;
    if (ctx.used.has(x.name.toLowerCase())) x.name = ctx.names.person(r, x.raceId);
    else ctx.used.add(x.name.toLowerCase());
  }
  for (const x of city.shops) {
    if (locked.has(x.id) || !x.name) continue;
    if (ctx.used.has(x.name.toLowerCase())) x.name = ctx.names.place(r, x.type === 'Tavern' ? 'tavern' : 'shop');
    else ctx.used.add(x.name.toLowerCase());
  }
}

/**
 * One entry rebuilt. `id` names it; the city's roll counter for that id makes
 * each reroll different and every one of them repeatable.
 */
export function rerollEntry(city, id) {
  const out = structuredClone(city);
  const n = (out.rolls[id] || 0) + 1;
  out.rolls[id] = n;
  const r = rng(hash(out.seed, id, n));
  const ctx = context(out.settings, out.pool, namesIn(out));
  const at = (list) => list.findIndex((x) => x.id === id);
  if (id === 'overview') {
    const o = makeOverview(ctx, r);
    out.overview = { ...o, name: o.name };
  } else if (id.startsWith('district-')) {
    const i = at(out.districts);
    const q = out.districts[i].race ? out.settings.races.find((x) => x.id === out.districts[i].race) : null;
    if (!q) ctx.used.delete((out.districts[i].name || '').toLowerCase());
    out.districts[i] = { ...makeDistrict(ctx, r, i, q), id };
  } else if (id.startsWith('place-')) {
    const i = at(out.places);
    const taken = new Set(out.places.map((p) => p.name));
    const free = ctx.T.PLACES.filter((p) => !taken.has(p));
    out.places[i] = { id, name: free.length ? pick(r, free) : out.places[i].name,
      district: pick(r, out.districts)?.name || null };
  } else if (id.startsWith('shop-')) {
    const i = at(out.shops);
    const owner = out.shops[i].owner;
    out.shops[i] = { ...makeShop(ctx, r, i, out), id, owner };
  } else if (id.startsWith('npc-')) {
    const i = at(out.npcs);
    const old = out.npcs[i];
    // A reroll keeps the race: the breakdown and "one of every race" were
    // satisfied by the city as built, and a reroll must not undo that.
    const race = out.settings.races.find((x) => x.id === old.raceId) || null;
    const fresh = makeNpc(ctx, r, i, race);
    out.npcs[i] = { ...fresh, id };
    for (const s of out.shops) if (s.owner === id && !/owner/.test(fresh.role)) out.npcs[i].role = `owner of ${s.name || 'a shop'}`;
  } else if (id.startsWith('quirk-')) {
    const i = at(out.quirks);
    const taken = new Set(out.quirks.map((q) => q.text));
    const free = ctx.T.CITY_QUIRKS.filter((q) => !taken.has(q));
    if (free.length) out.quirks[i] = { id, text: pick(r, free) };
  } else if (id.startsWith('rumour-')) {
    const i = at(out.rumours);
    const taken = new Set(out.rumours.map((q) => q.text));
    for (let t = 0; t < 50; t++) {
      const text = fillFrom(r, ctx.T.RUMOURS, out);
      if (text && !taken.has(text)) { out.rumours[i] = { id, roll: i + 1, text, true: r() < 0.5 }; break; }
    }
  } else {
    throw new Error(`No entry ${id}`);
  }
  out.warnings = [...new Set([...(out.warnings || []), ...ctx.warnings])];
  return out;
}

export function toggleLock(city, id) {
  const locks = new Set(city.locks);
  if (locks.has(id)) locks.delete(id); else locks.add(id);
  return { ...city, locks: [...locks] };
}

// ── the AI name pool ──
//
// ONE call per city, only when the G.M. gives a naming theme. The prompt asks
// for JSON and nothing else; parsePool() accepts only that shape and refuses
// anything else, so a malformed answer is an error the page shows, not a city
// half-named from nowhere.
export function poolPrompt(settings, theme) {
  const cultures = (settings.races || []).map((x) =>
    `- "${x.id}" (${x.name}): ${x.theme?.trim() || theme}`).join('\n');
  return {
    system: 'You invent names for a tabletop role-playing game city. Answer with one JSON object and nothing else - no prose, no code fence.',
    prompt: `Invent original names (not from any published setting) for a fantasy city.
Overall naming theme: ${theme}
Cultures and their naming theme:
${cultures}

Return exactly this JSON shape:
{
  "city": [5 possible names for the city],
  "district": [20 district or neighbourhood names],
  "street": [20 street names],
  "shop": [30 shop, inn and tavern names],
  "cultures": {
    "<culture id>": { "given": [30 given names, mixed genders], "family": [30 family names] }
  }
}
Use every culture id listed above as a key under "cultures".`,
  };
}

export function parsePool(text, settings) {
  let v;
  const s = String(text || '').trim();
  try { v = JSON.parse(s.slice(s.indexOf('{'), s.lastIndexOf('}') + 1)); } catch { throw new Error('The name pool was not valid JSON'); }
  const list = (x) => Array.isArray(x) ? [...new Set(x.filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim()))] : [];
  const pool = { city: list(v.city), district: list(v.district), street: list(v.street), shop: list(v.shop), cultures: {} };
  for (const race of settings.races || []) {
    const c = v.cultures?.[race.id];
    if (!c) throw new Error(`The name pool has no names for ${race.name}`);
    pool.cultures[race.id] = { given: list(c.given), family: list(c.family) };
    if (pool.cultures[race.id].given.length < 5) throw new Error(`The name pool has too few names for ${race.name}`);
  }
  if (!pool.city.length || !pool.shop.length || !pool.district.length) throw new Error('The name pool is missing city, shop or district names');
  return pool;
}

// ── export ──
export const exportJson = (city) => JSON.stringify(city, null, 2);
export const tablesFor = (system) => TABLES[system] || null;
