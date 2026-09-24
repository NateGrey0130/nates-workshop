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
import * as RIFTS from './city-tables-rifts.js';

const TABLES = { 'palladium-fantasy': PF, rifts: RIFTS };
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

// ── themes ──
//
// A theme ("Old West boomtown", "Neo Tokyo arcology") is a PACK of the city's
// tables written for it, saved with the city like the name pool, and layered
// on the setting: the setting still owns the races, the classes, the Codex and
// the rules, and the theme owns the flavour. `city.theme` is { intensity, pack }.
// Each draw from a themed table takes the theme's line with the intensity's
// chance and the setting's otherwise; at Total it takes the theme's always,
// and a theme that runs out says so rather than falling back.
//
// A city with NO theme draws exactly as it did before themes existed - not one
// extra random number - so every kept and ?seed= city is unchanged.
//
// A theme's shop kinds each name the setting's stock rule they sell by
// (`stockAs`), and its NPC roles the class they roll as (`roleOcc`); both are
// checked against the setting's own lists. A race's own lines (RACE_LINES) are
// themed ONLY for a race the G.M. named in the theme - anything else the pack
// says about a race is thrown away.
export const THEME_INTENSITY = { light: 0.3, strong: 0.7, total: 1 };
export const MAP_STYLES = ['organic', 'grid', 'rail', 'canal', 'vertical'];
export const THEME_TABLES = ['GOVERNMENTS', 'TRADES', 'WALLS', 'FACTIONS', 'DISTRICT_KINDS', 'MOODS', 'PLACES',
  'NPC_ROLES', 'LOOKS', 'PERSONALITIES', 'WANTS', 'SECRETS', 'CITY_QUIRKS', 'RUMOURS', 'ENCOUNTERS', 'SHOP_ADJECTIVES'];
export const THEME_MIN_LINES = 10;
export const RUMOUR_SLOTS = ['npc', 'district', 'place', 'shop', 'faction', 'city', 'race'];
const MAX_LINE = 300;
const tableLabel = (key) => key.toLowerCase().replace(/_/g, ' ');

// One line from table `key`.
function draw(ctx, r, key) {
  if (!ctx.theme) return pick(r, ctx.T[key]);
  const own = ctx.theme.pack.tables[key];
  return ctx.w >= 1 || r() < ctx.w ? pick(r, own) : pick(r, ctx.T[key]);
}
// n distinct lines from table `key`. At Total, fewer when the theme runs out.
function drawMany(ctx, r, key, n) {
  if (!ctx.theme) return sample(r, ctx.T[key], n);
  let k = 0;
  for (let i = 0; i < n; i++) if (ctx.w >= 1 || r() < ctx.w) k++;
  const own = sample(r, ctx.theme.pack.tables[key], k);
  if (ctx.w >= 1) {
    if (own.length < n) ctx.warnings.add(`The theme ran out of ${tableLabel(key)}`);
    return own;
  }
  const rest = sample(r, ctx.T[key].filter((x) => !own.includes(x)), n - own.length);
  return sample(r, [...own, ...rest], own.length + rest.length);
}
// One line from table `key` that is not in `taken`, or null when none is left.
function drawFree(ctx, r, key, taken) {
  const free = (list) => list.filter((x) => !taken.has(x));
  if (!ctx.theme) { const f = free(ctx.T[key]); return f.length ? pick(r, f) : null; }
  const own = free(ctx.theme.pack.tables[key]);
  if (ctx.w >= 1) return own.length ? pick(r, own) : null;
  const base = free(ctx.T[key]);
  if (own.length && (!base.length || r() < ctx.w)) return pick(r, own);
  return base.length ? pick(r, base) : null;
}
// A race's own lines: the theme's when the G.M. named that race, else the setting's.
function raceLines(ctx, raceId) {
  const own = ctx.theme?.pack.raceLines?.[raceId];
  return own ? { ...ctx.T.RACE_LINES[raceId], ...own } : ctx.T.RACE_LINES[raceId];
}

// Did the G.M. name this race - in the theme, or in the race's own naming box?
export function raceNamed(race, text) {
  // The name, its id as words, and a dwarf's or an elf's plural (dwarves, elves).
  const words = [race.name, String(race.id).replace(/[-_]+/g, ' ')].filter(Boolean).map((w) => w.trim())
    .flatMap((w) => (/f$/i.test(w) ? [w, w.replace(/f$/i, 'ves')] : [w]))
    .map((w) => w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/\s+/g, '[\\s-]+'));
  const re = new RegExp(`(^|[^a-z])(${words.join('|')})(s|es)?($|[^a-z])`, 'i');
  return re.test(String(text || '')) || re.test(String(race.theme || ''));
}

const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
function lineList(v, what, min) {
  if (!Array.isArray(v)) throw new Error(`The theme has no ${what}`);
  const out = [...new Set(v.filter((x) => typeof x === 'string').map((x) => x.trim()).filter(Boolean))];
  if (out.some((x) => x.length > MAX_LINE)) throw new Error(`A line of ${what} is longer than ${MAX_LINE} characters`);
  if (out.length < min) throw new Error(`The theme has ${out.length} ${what}; it needs ${min}`);
  return out;
}
function shopKinds(v, T, taken, what) {
  if (!Array.isArray(v)) throw new Error(`The theme has no ${what}`);
  return v.map((k) => {
    const label = typeof k?.label === 'string' ? k.label.trim() : '';
    if (!label) throw new Error(`A shop kind in ${what} has no name`);
    if (taken.has(label.toLowerCase())) throw new Error(`The shop kind "${label}" is named twice, or is already one of the setting's`);
    taken.add(label.toLowerCase());
    if (!T.SHOP_STOCK[k.stockAs]) {
      throw new Error(`The shop kind "${label}" sells as "${k.stockAs}", which is not one of the setting's stock rules`);
    }
    return { type: `theme-${slug(label)}`, label, stockAs: k.stockAs,
      names: lineList(k.names, `name words for "${label}"`, 3), specialties: lineList(k.specialties, `specialties for "${label}"`, 3) };
  });
}

// A theme is written in five calls (THEME_PARTS), each small enough to finish
// well inside the proxy's time limit, and each part is checked on its own as
// it arrives, so a part that fails is retried alone.
export const THEME_PARTS = {
  people: ['NPC_ROLES', 'LOOKS', 'PERSONALITIES', 'WANTS', 'SECRETS'],
  buildings: ['DISTRICT_KINDS', 'MOODS', 'PLACES', 'SHOP_ADJECTIVES'],
  overview: ['GOVERNMENTS', 'TRADES', 'WALLS', 'FACTIONS'],
  streets: ['CITY_QUIRKS', 'RUMOURS', 'ENCOUNTERS'],
  names: [],
};
const partTables = (pack, keys) => Object.fromEntries(keys.map((k) => [k, lineList(pack.tables?.[k], tableLabel(k), THEME_MIN_LINES)]));
const rollableOccs = (T) => [...new Set([...Object.values(T.ROLE_OCC), T.OWNER_OCC])];
const settingShopLabels = (T) => [...T.SHOP_TYPES, ...Object.values(T.RACE_LINES).flatMap((x) => x.shops || [])].map((t) => t.label);
const namedRaces = (settings, prompt) => (settings.races || []).filter((x) => raceNamed(x, prompt));

function checkPeople(pack, T) {
  const tables = partTables(pack, THEME_PARTS.people);
  const rollable = new Set(rollableOccs(T));
  const roleOcc = {};
  for (const [role, occ] of Object.entries(pack.roleOcc || {})) {
    if (!tables.NPC_ROLES.includes(role)) throw new Error(`The theme maps "${role}", which is not one of its roles`);
    if (!rollable.has(occ)) throw new Error(`The theme's "${role}" rolls as "${occ}", which the setting cannot roll`);
    roleOcc[role] = occ;
  }
  return { tables, roleOcc };
}
function checkBuildings(pack, T, settings, prompt) {
  const tables = partTables(pack, THEME_PARTS.buildings);
  const taken = new Set(settingShopLabels(T).map((l) => l.toLowerCase()));
  const shopTypes = shopKinds(pack.shopTypes, T, taken, 'shop kinds');
  if (shopTypes.length < 3) throw new Error(`The theme has ${shopTypes.length} shop kinds; it needs 3`);
  const mapStyle = pack.mapStyle ?? 'organic';
  if (!MAP_STYLES.includes(mapStyle)) throw new Error(`The map style "${mapStyle}" is not one of ${MAP_STYLES.join(', ')}`);
  const raceLines = {};
  for (const [id, lines] of Object.entries(pack.raceLines || {})) {
    const race = (settings.races || []).find((x) => x.id === id);
    if (!race || !raceNamed(race, prompt)) continue;
    const own = {};
    if (lines?.quirks) own.quirks = lineList(lines.quirks, `${race.name} quirks`, 1);
    // A named race's shops replace its own, so they may keep their names.
    const mine = new Set((T.RACE_LINES[id]?.shops || []).map((t) => t.label.toLowerCase()));
    if (lines?.shops) own.shops = shopKinds(lines.shops, T, new Set([...taken].filter((l) => !mine.has(l))), `${race.name} shops`);
    // The race's name goes with its lines, so a saved theme can be checked
    // again with no city in view (validateSavedTheme).
    if (Object.keys(own).length) raceLines[id] = { name: race.name, ...own };
  }
  return { tables, shopTypes, mapStyle, ...(Object.keys(raceLines).length ? { raceLines } : {}) };
}
function checkOverview(pack) {
  const tables = partTables(pack, THEME_PARTS.overview);
  const overviewExtras = (pack.overviewExtras || []).map((x) => {
    const label = String(x?.label || '').trim();
    if (!label) throw new Error('An overview line in the theme has no label');
    return { key: `theme-${slug(label)}`, label, lines: lineList(x.lines, `lines for "${label}"`, 3) };
  });
  if (overviewExtras.length > 4) throw new Error('The theme has more than four overview lines');
  const title = typeof pack.title === 'string' ? pack.title.trim().slice(0, 80) : '';
  return { tables, overviewExtras, ...(title ? { title } : {}) };
}
function checkStreets(pack) {
  const tables = partTables(pack, THEME_PARTS.streets);
  for (const line of tables.RUMOURS) {
    const bad = [...line.matchAll(/\{(\w+)\}/g)].map((m) => m[1]).filter((s) => !RUMOUR_SLOTS.includes(s));
    if (bad.length) throw new Error(`A rumour uses {${bad[0]}}, which a city cannot fill`);
  }
  return { tables };
}

/**
 * A theme pack checked against the setting it is for, or an Error saying what
 * is wrong. Returns a clean copy: every field the engine reads, and nothing
 * else - except `raceLines` for a race the G.M. did not name, which is dropped.
 */
export function validateThemePack(pack, settings) {
  const T = TABLES[settings.system];
  if (!T) throw new Error(`No tables for ${settings.system}`);
  if (!pack || typeof pack !== 'object') throw new Error('The theme is not an object');
  if (pack.system && pack.system !== settings.system) throw new Error(`The theme is for ${pack.system}, not ${settings.system}`);
  const prompt = String(pack.prompt || '').trim();
  if (!prompt) throw new Error('The theme has no description');
  const extra = Object.keys(pack.tables || {}).filter((k) => !THEME_TABLES.includes(k));
  if (extra.length) throw new Error(`The theme has tables the city does not use: ${extra.join(', ')}`);
  const people = checkPeople(pack, T);
  const buildings = checkBuildings(pack, T, settings, prompt);
  const overview = checkOverview(pack);
  const streets = checkStreets(pack);
  const all = { ...people.tables, ...buildings.tables, ...overview.tables, ...streets.tables };
  return { v: 1, system: settings.system, title: overview.title || prompt.slice(0, 80), prompt,
    tables: Object.fromEntries(THEME_TABLES.map((k) => [k, all[k]])),
    shopTypes: buildings.shopTypes, roleOcc: people.roleOcc, mapStyle: buildings.mapStyle,
    overviewExtras: overview.overviewExtras,
    ...(buildings.raceLines ? { raceLines: buildings.raceLines } : {}),
    ...(pack.names ? { names: checkPool(pack.names, []) } : {}) };
}

// ── writing a theme: the five calls ──
//
// Each call carries a JSON schema (structured output), so the answer is always
// JSON of the right shape - a first measurement without one got a line of code
// in the middle of a list. The schema's enums also hold the answer to what it
// must choose from: the setting's stock rules, the classes it can roll, the map
// styles. The check still runs on every answer; the schema cannot count lines
// or see a rumour's {slot}. Examples come from the setting's own tables, so
// the answer matches the lines it is mixed with.
const SETTING_BLURB = { 'palladium-fantasy': 'Palladium Fantasy, a sword-and-sorcery fantasy world',
  rifts: 'Rifts, a post-apocalyptic science-fantasy Earth of mega-damage, magic and the Coalition' };
const THEME_SYSTEM = 'You write tables for a tabletop role-playing game city generator. Write original material only - '
  + 'never quote or retell published books.';
const ex = (T, key) => `e.g. "${T[key][1]}"`;
const S_STR = { type: 'string' };
const S_LIST = { type: 'array', items: S_STR };
const S_OBJ = (props) => ({ type: 'object', properties: props, required: Object.keys(props), additionalProperties: false });
const S_TABLES = (keys) => S_OBJ(Object.fromEntries(keys.map((k) => [k, S_LIST])));
const S_SHOP = (T) => S_OBJ({ label: S_STR, stockAs: { type: 'string', enum: Object.keys(T.SHOP_STOCK) },
  names: S_LIST, specialties: S_LIST });

export function themePrompt(part, settings, text) {
  const T = TABLES[settings.system];
  if (!T) throw new Error(`No tables for ${settings.system}`);
  const intro = `The city's setting is ${SETTING_BLURB[settings.system] || settings.system}. The game master's theme for `
    + `this city: "${text}".
Every line must read as that theme while still belonging in the setting. Keep each line short - a phrase or one sentence - `
    + `and make the lines of a list all different from each other.
The city's peoples: ${(settings.races || []).map((x) => x.name).join(', ')}.
`;
  if (part === 'names') {
    const { system, prompt } = poolPrompt(settings, text);
    const culture = S_OBJ({ given: S_LIST, family: S_LIST });
    return { system, prompt, schema: S_OBJ({ city: S_LIST, district: S_LIST, street: S_LIST, shop: S_LIST,
      cultures: S_OBJ(Object.fromEntries((settings.races || []).map((x) => [x.id, culture]))) }) };
  }
  if (part === 'people') {
    return { system: THEME_SYSTEM, schema: S_OBJ({ tables: S_TABLES(THEME_PARTS.people),
      roleOcc: { type: 'array', items: S_OBJ({ role: S_STR, occ: { type: 'string', enum: rollableOccs(T) } }) } }),
    prompt: `${intro}
Write, in "tables":
- NPC_ROLES: 40 jobs or roles a townsperson has, lower case, one to three words, ${ex(T, 'NPC_ROLES')}
- LOOKS: 40 short descriptions of how someone looks, lower case, ${ex(T, 'LOOKS')}
- PERSONALITIES: 40 habits or manners, lower case, ${ex(T, 'PERSONALITIES')}
- WANTS: 40 things a person wants, lower case, starting "to", ${ex(T, 'WANTS')}
- SECRETS: 40 secrets, lower case, ${ex(T, 'SECRETS')}
And in "roleOcc", for as many of your NPC_ROLES as fit, the role exactly as written there and the class a person in `
      + `that job would be as a game character.` };
  }
  if (part === 'buildings') {
    const named = namedRaces(settings, text);
    const styles = { organic: 'winding old streets', grid: 'a planned grid', rail: 'a railway line through town',
      canal: 'built on canals or a river', vertical: 'a dense, towering core' };
    return { system: THEME_SYSTEM, schema: S_OBJ({ tables: S_TABLES(THEME_PARTS.buildings),
      shopTypes: { type: 'array', items: S_SHOP(T) },
      mapStyle: { type: 'string', enum: MAP_STYLES },
      ...(named.length ? { raceLines: S_OBJ(Object.fromEntries(named.map((x) => [x.id,
        S_OBJ({ quirks: S_LIST, shops: { type: 'array', items: S_SHOP(T) } })]))) } : {}) }),
    prompt: `${intro}
Write, in "tables":
- DISTRICT_KINDS: 40 kinds of district, one to three words, title case, ${ex(T, 'DISTRICT_KINDS')}
- MOODS: 40 moods a district has, ${ex(T, 'MOODS')}
- PLACES: 40 places of interest, each a name with a few words about it, ${ex(T, 'PLACES')}
- SHOP_ADJECTIVES: 40 single words a shop is named with, title case, e.g. "${T.SHOP_ADJECTIVES[0]}"
In "shopTypes", 10 kinds of shop or business: its "label" (e.g. Saloon), the stock rule its goods are closest to `
      + `("stockAs"), 6 single words a business of that kind is named with ("names", e.g. Forge, Anvil), and 8 things one `
      + `business of that kind is known for ("specialties", lower case, e.g. "${T.SHOP_TYPES[1].specialties[0]}"). No shop kind `
      + `may be named any of these, which the setting already has: ${settingShopLabels(T).join(', ')}.
In "mapStyle", the street plan that suits the theme: ${MAP_STYLES.map((m) => `${m} (${styles[m]})`).join(', ')}.${named.length
      ? `\nIn "raceLines", for ${named.map((x) => `${x.name} ("${x.id}")`).join(', ')} as the theme describes them: 3 things `
        + `true of the city because of that people ("quirks"), and 1 or 2 shop kinds of theirs ("shops").` : ''}` };
  }
  if (part === 'overview') {
    const theirs = (T.OVERVIEW_EXTRAS || []).map((x) => x.label);
    return { system: THEME_SYSTEM, schema: S_OBJ({ title: S_STR, tables: S_TABLES(THEME_PARTS.overview),
      overviewExtras: { type: 'array', items: S_OBJ({ label: S_STR, lines: S_LIST }) } }),
    prompt: `${intro}
Write a "title" for this theme, two to four words. Then, in "tables":
- GOVERNMENTS: 40 who rules the city, lower case, ${ex(T, 'GOVERNMENTS')}
- TRADES: 40 what the city lives on, lower case, ${ex(T, 'TRADES')}
- WALLS: 40 what the city's walls or defences are, lower case, ${ex(T, 'WALLS')}
- FACTIONS: 40 factions, each "Name, who want or do something", ${ex(T, 'FACTIONS')}
And in "overviewExtras", up to 3 more things this theme's city has that a game master would want at a glance, `
      + `each a "label" (e.g. Law) and 8 alternatives for it ("lines", lower case).${theirs.length
      ? ` The setting already gives ${theirs.join(', ')}; do not repeat them.` : ''}` };
  }
  if (part === 'streets') {
    return { system: THEME_SYSTEM, schema: S_OBJ({ tables: S_TABLES(THEME_PARTS.streets) }),
      prompt: `${intro}
Write, in "tables":
- CITY_QUIRKS: 40 odd facts about the city, ${ex(T, 'CITY_QUIRKS')}
- RUMOURS: 40 rumours, ${ex(T, 'RUMOURS')}
- ENCOUNTERS: 40 things that happen in the street, ${ex(T, 'ENCOUNTERS')}
A rumour may name something in the city with these slots, which the generator fills: `
      + `${RUMOUR_SLOTS.map((s) => `{${s}}`).join(' ')}. Use no other braces.` };
  }
  throw new Error(`No theme part "${part}"`);
}

const answerJson = (text) => {
  const s = String(text || '').trim();
  try { return JSON.parse(s.slice(s.indexOf('{'), s.lastIndexOf('}') + 1)); } catch { return null; }
};

// One part's answer, checked on its own. Returns what the part owns.
export function parseThemePart(part, text, settings, prompt) {
  if (part === 'names') return parsePool(text, settings);
  const v = answerJson(text);
  if (!v) throw new Error(`The theme's ${part} was not valid JSON`);
  const T = TABLES[settings.system];
  const pack = { ...v, tables: v.tables || {} };
  if (part === 'people') {
    // Asked for as a list of pairs, since a schema cannot key an object by role.
    // A pair for a role the answer did not list could never be drawn: dropped.
    const roles = new Set(Array.isArray(pack.tables.NPC_ROLES) ? pack.tables.NPC_ROLES.map((x) => String(x).trim()) : []);
    const pairs = (Array.isArray(v.roleOcc) ? v.roleOcc : []).filter((x) => roles.has(String(x?.role).trim()));
    return checkPeople({ ...pack, roleOcc: Object.fromEntries(pairs.map((x) => [String(x.role).trim(), x.occ])) }, T);
  }
  if (part === 'buildings') return checkBuildings(pack, T, settings, prompt);
  if (part === 'overview') return checkOverview(pack);
  if (part === 'streets') return checkStreets(pack);
  throw new Error(`No theme part "${part}"`);
}

// The five parts, put together and checked whole.
export function assembleThemePack(prompt, parts, settings) {
  const { people, buildings, overview, streets, names } = parts;
  return validateThemePack({ prompt, title: overview.title,
    tables: { ...people.tables, ...buildings.tables, ...overview.tables, ...streets.tables },
    roleOcc: people.roleOcc, shopTypes: buildings.shopTypes, mapStyle: buildings.mapStyle,
    raceLines: buildings.raceLines, overviewExtras: overview.overviewExtras, names }, settings);
}

// ── saved themes (migration 084) ──
//
// A theme kept in the library is checked with no city in view: the races it
// may hold lines for are the ones its own raceLines name, each carrying the
// race's name, so the rule that a race's lines need the race NAMED in the
// theme still runs. The server checks every write with this, and the page
// every load.
export function validateSavedTheme(pack) {
  const races = Object.entries(pack?.raceLines || {}).map(([id, x]) => ({ id, name: String(x?.name || id) }));
  if (!TABLES[pack?.system]) throw new Error(`A saved theme needs a game the City Creator has tables for, not "${pack?.system}"`);
  const out = validateThemePack(pack, { system: pack.system, races });
  if (!out.names) throw new Error('A saved theme needs its name pool');
  return out;
}

// A pack split back into the five parts it was written in, so a saved theme
// loads onto the page as if it had just been written.
export function themeParts(pack) {
  const pick = (part) => Object.fromEntries(THEME_PARTS[part].map((k) => [k, pack.tables[k]]));
  return {
    people: { tables: pick('people'), roleOcc: { ...pack.roleOcc } },
    buildings: { tables: pick('buildings'), shopTypes: pack.shopTypes, mapStyle: pack.mapStyle,
      ...(pack.raceLines ? { raceLines: pack.raceLines } : {}) },
    overview: { tables: pick('overview'), overviewExtras: pack.overviewExtras, title: pack.title },
    streets: { tables: pick('streets') },
    names: pack.names,
  };
}

// One table's lines replaced by the G.M.'s own, checked by the same rules as
// the part it belongs to. Returns [part, the part's new value]. A role that is
// gone takes its class mapping with it rather than being refused.
export function editThemeTable(parts, key, lines, settings, prompt) {
  const part = Object.keys(THEME_PARTS).find((p) => THEME_PARTS[p].includes(key));
  if (!part) throw new Error(`No theme table ${key}`);
  const T = TABLES[settings.system];
  const value = { ...parts[part], tables: { ...parts[part].tables, [key]: lines } };
  if (part === 'people') {
    const roles = new Set((Array.isArray(value.tables.NPC_ROLES) ? value.tables.NPC_ROLES : []).map((x) => String(x).trim()));
    const roleOcc = Object.fromEntries(Object.entries(value.roleOcc || {}).filter(([r]) => roles.has(r)));
    return [part, checkPeople({ ...value, roleOcc }, T)];
  }
  if (part === 'buildings') return [part, checkBuildings(value, T, settings, prompt)];
  if (part === 'overview') return [part, checkOverview(value)];
  return [part, checkStreets(value)];
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
    // A shop's name says what it sells: "Haskett's Cybernetics", "The Iron
    // Anvil", from the kind's own words (`names` on the shop type) and the
    // setting's SHOP_ADJECTIVES. The places theme's shop names are generic, so
    // "Fitch's Energy Weapons" could be a clinic. A tavern, a kind with no
    // words, or a city with an AI name pool keeps the old way: the pool was
    // the G.M.'s own choice. A kind whose words run out says so and goes
    // unnamed, like every other name here.
    shop(r, t) {
      const kind = t?.type === 'tavern' ? 'tavern' : 'shop';
      // With a theme, the pool's shop names are only for the setting's taverns: a
      // themed kind has words of its own, and a pooled name fits no kind in particular.
      if (kind === 'tavern' || !t?.names?.length || (ctx.pool?.shop?.length && !ctx.theme)) return this.place(r, kind);
      for (let i = 0; i < 40; i++) {
        const word = pick(r, t.names);
        const form = Math.floor(r() * 3);
        let n;
        if (form === 0) {
          const person = generateNames({ theme: T.DEFAULT_PEOPLE_THEME, shape: 'given+family', count: 1, random: r }).names[0];
          const surname = person?.split(' ').slice(1).join(' ');
          if (!surname) continue;
          n = `${surname}${/s$/i.test(surname) ? "'" : "'s"} ${word}`;
        } else {
          n = `${form === 1 ? 'The ' : ''}${draw(ctx, r, 'SHOP_ADJECTIVES')} ${word}`;
        }
        if (!ctx.used.has(n.toLowerCase())) { ctx.used.add(n.toLowerCase()); return n; }
      }
      ctx.warnings.add(`No new name was left for a ${t.label.toLowerCase()}`);
      return '';
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
function fillFrom(ctx, r, key, city, tries = 30) {
  for (let i = 0; i < tries; i++) {
    const got = fill(r, draw(ctx, r, key), city);
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
  const o = {
    id: 'overview', name, population: settings.population, size: size.label,
    walls: walled ? draw(ctx, r, 'WALLS') : null,
    government: draw(ctx, r, 'GOVERNMENTS'),
    wealth: pick(r, T.WEALTH).label,
    trade: draw(ctx, r, 'TRADES'),
    factions: drawMany(ctx, r, 'FACTIONS', factionCount).map((line, i) => {
      const [name, goal] = line.split(/, (?=who )/);
      return { id: `faction-${i}`, name, goal: goal || '' };
    }),
    // A setting's own overview lines (Rifts: tech level, the Coalition, ley
    // lines). Drawn last, so a setting without them draws exactly as before.
    ...(T.OVERVIEW_EXTRAS ? { extras: T.OVERVIEW_EXTRAS.map((x) => ({ key: x.key, label: x.label, text: pick(r, x.lines) })) } : {}),
  };
  // A theme's own overview lines ("Law: a marshal and two deputies") come
  // after the setting's, which a theme never replaces.
  const own = ctx.theme?.pack.overviewExtras || [];
  if (own.length) o.extras = [...(o.extras || []), ...own.map((x) => ({ key: x.key, label: x.label, text: pick(r, x.lines) }))];
  return o;
}

// The race quarters first: every race at 20% or more has one.
function quarterRaces(settings) {
  return (settings.races || []).filter((x) => Number(x.pct) >= 20 && x.id !== 'human');
}

function makeDistrict(ctx, r, i, quarter = null) {
  const { T } = ctx;
  const kind = quarter ? `${quarter.name} Quarter` : draw(ctx, r, 'DISTRICT_KINDS');
  const own = quarter ? '' : ctx.names.place(r, 'district');
  return {
    id: quarter ? `district-q-${quarter.id}` : `district-${i}`,
    name: quarter ? `${quarter.name} Quarter` : (own || kind),
    kind, race: quarter?.id || null,
    mood: draw(ctx, r, 'MOODS'),
    encounters: drawMany(ctx, r, 'ENCOUNTERS', 6).map((text, n) => ({ roll: n + 1, text })),
  };
}

// Which shop types this city can have: the setting's own (or the theme's),
// and any tied to a race in its breakdown.
const raceShops = (ctx) => (ctx.settings.races || []).flatMap((x) => raceLines(ctx, x.id)?.shops || []);
function shopTypes(ctx) {
  return [...ctx.T.SHOP_TYPES, ...(ctx.theme?.pack.shopTypes || []), ...raceShops(ctx)];
}
function drawShopType(ctx, r) {
  const kinds = ctx.theme && (ctx.w >= 1 || r() < ctx.w) ? ctx.theme.pack.shopTypes : ctx.T.SHOP_TYPES;
  return pick(r, [...kinds, ...raceShops(ctx)]);
}

// The kind a stored shop is, from its label - the city stores the label.
const shopTypeFor = (ctx, label) => shopTypes(ctx).find((t) => t.label === label) || null;

function makeShop(ctx, r, i, city) {
  const t = drawShopType(ctx, r);
  const wealth = ctx.T.WEALTH.find((w) => w.label === city.overview.wealth);
  // Prices lean with the city's wealth, then a shop's own habits.
  const lean = Math.max(0, Math.min(ctx.T.PRICE_LEVELS.length - 1,
    Math.floor(r() * ctx.T.PRICE_LEVELS.length) + (wealth.price > 1.2 ? 1 : wealth.price < 0.9 ? -1 : 0)));
  return {
    id: `shop-${i}`, name: ctx.names.shop(r, t), type: t.label,
    specialty: pick(r, t.specialties), price: ctx.T.PRICE_LEVELS[lean],
    quirk: draw(ctx, r, 'PERSONALITIES').replace(/^/, 'the owner '),
    district: pick(r, city.districts)?.name || null, owner: null,
    // A theme's kind sells by one of the setting's stock rules.
    ...(t.stockAs ? { stockAs: t.stockAs } : {}),
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
    role: role || draw(ctx, r, 'NPC_ROLES'), look: draw(ctx, r, 'LOOKS'), quirk: draw(ctx, r, 'PERSONALITIES'),
    want: draw(ctx, r, 'WANTS'), secret: draw(ctx, r, 'SECRETS'),
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
  const extra = (ctx.settings.races || []).flatMap((x) => raceLines(ctx, x.id)?.quirks || []);
  const n = between(r, [3, 5]);
  // A race's own line leads when that race is in the city, then the general ones.
  const chosen = [...sample(r, extra, Math.min(extra.length, 1)), ...drawMany(ctx, r, 'CITY_QUIRKS', n)].slice(0, n);
  return chosen.map((text, i) => ({ id: `quirk-${i}`, text }));
}

function makeRumours(ctx, r, city) {
  const out = [];
  const seen = new Set();
  for (let tries = 0; out.length < 10 && tries < 200; tries++) {
    const text = fillFrom(ctx, r, 'RUMOURS', city);
    if (!text || seen.has(text)) continue;
    seen.add(text);
    out.push({ id: `rumour-${out.length}`, roll: out.length + 1, text, true: r() < 0.5 });
  }
  return out;
}

// ── the whole city ──

function context(settings, pool, used = [], theme = null) {
  const T = TABLES[settings.system];
  const ctx = { T, settings, pool, theme: theme || null, w: theme ? THEME_INTENSITY[theme.intensity] : 0,
    used: new Set(used.map((n) => n.toLowerCase())), warnings: new Set() };
  ctx.names = namer(ctx);
  return ctx;
}
const sectionRng = (seed, section, n = 0) => rng(hash(seed, section, n));

/**
 * A new city.
 *   settings  { system, population, npcCount, races: [{ id, name, pct }], everyRace }
 *   seed      a 32-bit number
 *   pool      the AI name pool, or null for the built-in names
 *   theme     { intensity, pack } from validateThemePack, or null for none
 */
export function generateCity(settings, seed, pool = null, theme = null) {
  const problems = settingsProblems(settings);
  if (theme && !THEME_INTENSITY[theme.intensity]) problems.push(`No theme intensity "${theme.intensity}"`);
  if (problems.length) throw new Error(problems.join('; '));
  const ctx = context(settings, pool, [], theme);
  const size = sizeFor(settings.population, settings.system);
  const city = { version: 1, seed, settings: structuredClone(settings), pool: pool || null,
    ...(theme ? { theme: structuredClone(theme) } : {}),
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
  city.places = drawMany(ctx, rp, 'PLACES', between(rp, size.places))
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
  const fresh = generateCity({ ...city.settings }, seed, city.pool, city.theme || null);
  const keep = (a, b) => a.map((x, i) => (locked.has(x.id) ? x : (b[i] || null))).filter(Boolean)
    .concat(b.slice(a.length));
  // What the players were shown of the city (Phase 3) is the G.M.'s decision,
  // not the dice's: it survives a reroll, keyed by the entry ids that stay.
  const out = { ...fresh, locks: [...locked], rolls: { ...city.rolls },
    ...(city.reveal ? { reveal: { ...city.reveal } } : {}), ...(city.public ? { public: { ...city.public } } : {}) };
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
  const ctx = context(city.settings, city.pool, [], city.theme || null);
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
    // By its kind, as makeShop names one: a clash renamed a Rifts Bar with a
    // shop's name until 2026-09-23, because this tested the label 'Tavern'.
    if (ctx.used.has(x.name.toLowerCase())) x.name = ctx.names.shop(r, shopTypeFor(ctx, x.type));
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
  const ctx = context(out.settings, out.pool, namesIn(out), out.theme || null);
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
    const got = drawFree(ctx, r, 'PLACES', new Set(out.places.map((p) => p.name)));
    out.places[i] = { id, name: got ?? out.places[i].name,
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
    const got = drawFree(ctx, r, 'CITY_QUIRKS', new Set(out.quirks.map((q) => q.text)));
    if (got !== null) out.quirks[i] = { id, text: got };
  } else if (id.startsWith('rumour-')) {
    const i = at(out.rumours);
    const taken = new Set(out.rumours.map((q) => q.text));
    for (let t = 0; t < 50; t++) {
      const text = fillFrom(ctx, r, 'RUMOURS', out);
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
    prompt: `Invent original names (not from any published setting) for a ${settings.system === 'rifts'
      ? 'post-apocalyptic science-fantasy (Rifts)' : 'fantasy'} city.
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
  const v = answerJson(text);
  if (!v) throw new Error('The name pool was not valid JSON');
  return checkPool(v, settings.races || []);
}
// A pool's shape. With races, names for each of them and only them; with none
// (a pool kept in a theme), every culture it has.
function checkPool(v, races) {
  if (!v || typeof v !== 'object') throw new Error('The name pool is not an object');
  const list = (x) => Array.isArray(x) ? [...new Set(x.filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim()))] : [];
  const pool = { city: list(v.city), district: list(v.district), street: list(v.street), shop: list(v.shop), cultures: {} };
  for (const race of races) {
    const c = v.cultures?.[race.id];
    if (!c) throw new Error(`The name pool has no names for ${race.name}`);
    pool.cultures[race.id] = { given: list(c.given), family: list(c.family) };
    if (pool.cultures[race.id].given.length < 5) throw new Error(`The name pool has too few names for ${race.name}`);
  }
  if (!races.length) {
    for (const [id, c] of Object.entries(v.cultures || {})) pool.cultures[id] = { given: list(c?.given), family: list(c?.family) };
  }
  if (!pool.city.length || !pool.shop.length || !pool.district.length) throw new Error('The name pool is missing city, shop or district names');
  return pool;
}

// ── export ──
export const exportJson = (city) => JSON.stringify(city, null, 2);

// ── "Roll stats" (Phase 4a) ──
//
// A city NPC becomes a statted NPC in the city's campaign through the NPC
// roller (campaigns/:id/npcs/generate, js/npc-generate.js): their race's
// R.C.C. with the job O.C.C. their role maps to. The roller REFUSES rather
// than guesses - a pairing the race's page bars, a class it cannot build - and
// the page shows that refusal as it comes; nothing here pads around it.
// Why an NPC cannot be rolled, or null when they can. A theme's role that the
// theme gave no class has no job to roll as, and a class guessed here would be
// padding - so the page shows this instead of the button. Only where the
// roller needs a job: a Rifts race that is its R.C.C. alone rolls without one.
export function rollBlocker(city, npcId) {
  const T = TABLES[city.settings.system];
  const n = city.npcs.find((x) => x.id === npcId);
  if (!n) return `No NPC ${npcId}`;
  if (/^owner of /.test(n.role) || city.theme?.pack.roleOcc?.[n.role] || T.ROLE_OCC[n.role]) return null;
  if (T.RACE_TAKES_OCC === false && n.raceId !== T.HUMAN.id
    && !(city.settings.races || []).find((x) => x.id === n.raceId)?.takesOcc) return null;
  return `The theme gave "${n.role}" no class to roll as, so there is nothing to roll`;
}

export function rollRequest(city, npcId) {
  const T = TABLES[city.settings.system];
  const n = city.npcs.find((x) => x.id === npcId);
  if (!n) throw new Error(`No NPC ${npcId}`);
  const blocked = rollBlocker(city, npcId);
  if (blocked) throw new Error(blocked);
  // A theme's role rolls as the class the theme mapped it to (checked against
  // the setting's own list when the theme was made); a role it did not map, as
  // the setting's own role does - or, above, not at all.
  const occ = /^owner of /.test(n.role) ? T.OWNER_OCC
    : city.theme?.pack.roleOcc?.[n.role] || T.ROLE_OCC[n.role] || null;
  const named = n.name ? { name: n.name } : {};
  // Rifts: a human is their job's O.C.C. alone. Another race is their R.C.C.
  // alone, unless that R.C.C. takes an occupation - the race row's `takesOcc`,
  // which the page copies from the roller's own rule (needsOccupation in
  // js/parser.js) when the race is chosen.
  if (T.RACE_TAKES_OCC === false) {
    if (n.raceId === T.HUMAN.id) return { class_id: occ, level: 1, count: 1, ...named };
    const race = (city.settings.races || []).find((x) => x.id === n.raceId);
    return race?.takesOcc
      ? { class_id: n.raceId, occ_class_id: occ, level: 1, count: 1, ...named }
      : { class_id: n.raceId, level: 1, count: 1, ...named };
  }
  return { class_id: n.raceId, occ_class_id: occ, level: 1, count: 1, ...named };
}

// The link from the city's entry to the sheet the roller made: the sheet's id
// on the entry. A reroll of the entry makes a new person and drops the link;
// the sheet stays in the campaign, as any statted NPC does.
export function linkSheet(city, npcId, sheetId) {
  return { ...city, npcs: city.npcs.map((n) => (n.id === npcId ? { ...n, sheet_id: sheetId } : n)) };
}
export const tablesFor = (system) => TABLES[system] || null;

// ── shop inventories (Phase 4b) ──
//
// 6-10 real gear rows from the Codex for one shop, chosen by the shop's rule
// (SHOP_STOCK), seeded by the city, the shop and that shop's restock count, and
// priced at the book's price times the city's wealth. The rows are copied INTO
// the city - slug, name, book price and this city's price - so a kept city
// keeps its stock when the Codex changes. A rule the Codex can only partly
// fill stocks what there is and says so; nothing is invented to fill a shelf.
export function stockShop(city, shopId, gear) {
  const T = TABLES[city.settings.system];
  const shop = city.shops.find((s) => s.id === shopId);
  if (!shop) throw new Error(`No shop ${shopId}`);
  // A theme's kind of shop sells by the setting rule it named (`stockAs`).
  const rules = T.SHOP_STOCK[shop.stockAs || shop.type];
  if (!rules) return withStock(city, shopId, [], `No stock rule for a ${shop.type.toLowerCase()} yet`);
  const sys = city.settings.system;
  const fits = (g) => rules.some((rule) => g.category === rule.category
    && (!rule.name || new RegExp(`\\b(${rule.name})`, 'i').test(g.name))
    && (!rule.not || !new RegExp(`\\b(${rule.not})`, 'i').test(g.name)));
  const pool = [...new Map(gear
    .filter((g) => (g.system === sys || g.system === 'both' || !g.system) && Number(g.cost) > 0 && fits(g))
    .map((g) => [g.slug, g])).values()].sort((a, b) => a.slug.localeCompare(b.slug));
  const key = `stock:${shopId}`;
  const r = rng(hash(city.seed, key, city.rolls?.[key] || 0));
  const want = between(r, [6, 10]);
  const wealth = T.WEALTH.find((w) => w.label === city.overview.wealth) || { price: 1 };
  const items = sample(r, pool, want).map((g) => ({
    slug: g.slug, name: g.name, category: g.category,
    book: Number(g.cost), price: Math.max(1, Math.round(Number(g.cost) * wealth.price)),
  })).sort((a, b) => a.name.localeCompare(b.name));
  const note = pool.length < want
    ? `The Codex has ${pool.length} ${pool.length === 1 ? 'item' : 'items'} a ${shop.type.toLowerCase()} sells - all of them are here`
    : null;
  return withStock(city, shopId, items, note);
}
function withStock(city, shopId, items, note) {
  return { ...city, shops: city.shops.map((s) => (s.id === shopId ? { ...s, inventory: items, stock_note: note } : s)) };
}
// Restock: the next draw for that shop, by bumping its restock count.
export function restockShop(city, shopId, gear) {
  const key = `stock:${shopId}`;
  return stockShop({ ...city, rolls: { ...city.rolls, [key]: (city.rolls?.[key] || 0) + 1 } }, shopId, gear);
}

// ── "Flesh out" (Phase 4d) ──
//
// One AI call per press, for one district, place, shop or NPC: a few short
// paragraphs for the G.M., saved INTO that entry as `flesh`. The prompt
// carries the entry and just enough of the city to fit it in; the answer is
// plain prose, tidied and capped, and an empty one is an error the page
// shows, never a blank saved over the entry. A reroll of the entry makes a
// new one and drops its flesh with it; a lock keeps both. The players' view
// never reads the field (cities/[id]/view.js builds its response from an
// allowlist), so it is the G.M.'s alone like the rest of the entry.
export const FLESH_KINDS = ['district', 'place', 'shop', 'npc'];
const MAX_FLESH = 2400;
const SETTING_NAMES = { 'palladium-fantasy': 'Palladium Fantasy', rifts: 'Rifts', nightbane: 'Nightbane',
  'heroes-unlimited': 'Heroes Unlimited' };

function fleshEntry(city, id) {
  const kind = String(id).split('-')[0];
  const list = { district: city.districts, place: city.places, shop: city.shops, npc: city.npcs }[kind];
  const entry = list?.find((x) => x.id === id);
  if (!entry) throw new Error(`No district, place, shop or NPC ${id}`);
  return { kind, entry };
}

export function fleshPrompt(city, id) {
  const { kind, entry: e } = fleshEntry(city, id);
  const o = city.overview;
  const npcName = (nid) => city.npcs.find((n) => n.id === nid)?.name || null;
  const about = {
    district: () => `the district "${e.name}" (${e.kind}). Its mood: ${e.mood}.`,
    place: () => `the place of interest "${e.name}"${e.district ? `, in the ${e.district} district` : ''}.`,
    shop: () => `the ${e.type.toLowerCase()} "${e.name || 'with no name yet'}"${e.district ? `, in the ${e.district} district` : ''}. `
      + `Known for ${e.specialty}; prices ${e.price}; ${e.quirk}. Owner: ${npcName(e.owner) || 'not yet named'}.`,
    npc: () => `the ${e.race} ${e.role} ${e.name || '(no name yet)'}: ${e.look}; ${e.quirk}. Wants ${e.want}. `
      + `Secret: ${e.secret}.`,
  }[kind]();
  return {
    system: 'You help a game master prepare a tabletop role-playing game city. Write original material only - never '
      + 'quote or retell published books. Answer in plain prose: no headings, no lists, no markdown.',
    prompt: `The city of ${o.name} (${SETTING_NAMES[city.settings.system] || city.settings.system}): ${o.size} of `
      + `${Number(o.population).toLocaleString('en-US')}, ruled by ${o.government}, ${o.wealth}, living on ${o.trade}.${
        (o.extras || []).map((x) => ` ${x.label}: ${x.text}.`).join('')}${
        city.theme ? ` The city's theme: ${city.theme.pack.title} - ${city.theme.pack.prompt}.` : ''}

Flesh out ${about}

Write two or three short paragraphs, 150 words at most, for the game master's eyes: what the players notice first, `
      + `one detail that makes it memorable, and one hook the game master can use in play. Keep to what is given above `
      + `and do not contradict it.`,
  };
}

export function parseFlesh(text) {
  const s = String(text || '').trim()
    .replace(/^```[a-z]*\s*|\s*```$/gi, '')
    .split(/\r?\n/).map((l) => l.replace(/^\s*(#+\s*|[-*]\s+)/, '').replace(/\*\*(.+?)\*\*/g, '$1').trim())
    .join('\n').replace(/\n{3,}/g, '\n\n').trim();
  if (!s) throw new Error('The answer was empty - nothing was saved');
  return s.length > MAX_FLESH ? s.slice(0, s.lastIndexOf(' ', MAX_FLESH)) + '…' : s;
}

export function withFlesh(city, id, text) {
  const { kind } = fleshEntry(city, id);
  const key = { district: 'districts', place: 'places', shop: 'shops', npc: 'npcs' }[kind];
  return { ...city, [key]: city[key].map((x) => (x.id === id ? { ...x, flesh: text } : x)) };
}
