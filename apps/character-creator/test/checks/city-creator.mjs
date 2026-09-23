// The City Creator's engine: apps/city-creator/js/city-engine.js and its
// Palladium Fantasy tables.
//
// The engine is pure and seeded, so everything it promises is provable here
// without a browser: the same seed gives the same city, population drives the
// size and NPC count does not, a race at 20% gets a quarter, "one of every
// race" holds, owners are named NPCs, locks survive a reroll, a single reroll
// touches one entry, the tables are as big as the plan asked, and a name pool
// that is not the shape asked for is refused rather than half-used.
//
// SEEN TO FAIL, 2026-09-23, each fault injected alone, upstream in the engine
// or its tables: locks ignored by a reroll; the quarter threshold dropped to
// 10%; "one of every race" skipped; an entry reroll that also changed the
// overview; owners invented instead of drawn from the NPCs; the rumour table
// cut to 38; and the name pool padded when it ran out. The last one PASSED the
// first version of the pool check - see the comment there.
// The map (Phase 2), the same way: a cell not clipped against the centre
// district, every pin put in the wrong district, a wall on every city, and
// pins placed without spacing. The wrong-district fault PASSED the first
// version of the pin check, which read the pin's own record of its district.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';
import { generateCity, rerollCity, rerollEntry, toggleLock, settingsProblems, restAreHuman, sizeFor,
  parsePool, tablesFor, exportJson } from '../../../city-creator/js/city-engine.js';
import { layoutMap, inside, area } from '../../../city-creator/js/city-map.js';

const SECTIONS = ['City Creator engine', 'City Creator map'];

const base = () => ({
  system: 'palladium-fantasy', population: 12000, npcCount: 14, everyRace: true,
  races: [{ id: 'human', name: 'Human', pct: 55 }, { id: 'dwarf', name: 'Dwarf', pct: 25 },
          { id: 'wolfen', name: 'Wolfen', pct: 10 }, { id: 'elf', name: 'Elf', pct: 10 }],
});

export function run() {
  if (!SECTIONS.some(wantSection)) return;
  section('City Creator engine');

  // ── the same seed, the same city ──
  const a = generateCity(base(), 4242);
  check('the same seed and settings give the same city, to the byte',
    exportJson(a) === exportJson(generateCity(base(), 4242)));
  check('and another seed gives another', exportJson(a) !== exportJson(generateCity(base(), 4243)));

  // ── population drives size; the NPC count is its own ──
  const hamlet = generateCity({ ...base(), population: 40 }, 1);
  const metro = generateCity({ ...base(), population: 90000 }, 1);
  check('population drives districts, shops and places',
    hamlet.shops.length < metro.shops.length && hamlet.places.length < metro.places.length
      && hamlet.districts.length < metro.districts.length,
    JSON.stringify({ hamlet: [hamlet.districts.length, hamlet.shops.length], metro: [metro.districts.length, metro.shops.length] }));
  check('and a hamlet has no walls while a metropolis always does',
    hamlet.overview.walls === null && !!metro.overview.walls);
  check('the named-NPC count is exactly what was asked, whatever the population',
    hamlet.npcs.length === 14 && metro.npcs.length === 14);

  // ── the racial breakdown ──
  check('a race at 20% or more gets its own quarter, and one under 20% does not',
    a.districts.some((d) => d.race === 'dwarf') && !a.districts.some((d) => d.race === 'wolfen' || d.race === 'elf'));
  // Rare races and exactly as many NPCs as races, over many seeds: chance alone
  // would miss one of three 1% races nearly every time.
  const rare = { ...base(), npcCount: 4, races: [{ id: 'human', name: 'Human', pct: 97 },
    { id: 'dwarf', name: 'Dwarf', pct: 1 }, { id: 'wolfen', name: 'Wolfen', pct: 1 }, { id: 'elf', name: 'Elf', pct: 1 }] };
  const uncovered = [];
  for (let seed = 0; seed < 25; seed++) {
    const got = new Set(generateCity(rare, seed).npcs.map((n) => n.raceId));
    if (got.size !== 4) uncovered.push(`seed ${seed}: ${[...got].join(', ')}`);
  }
  check('"at least one NPC of every race" holds, even for 1% races and four NPCs', uncovered.length === 0,
    uncovered.slice(0, 3).join('; '));
  let seenMissing = false;
  for (let seed = 0; seed < 40 && !seenMissing; seed++) {
    const c = generateCity({ ...base(), npcCount: 4, everyRace: false,
      races: [{ id: 'human', name: 'Human', pct: 97 }, { id: 'elf', name: 'Elf', pct: 3 }] }, seed);
    seenMissing = !c.npcs.some((n) => n.raceId === 'elf');
  }
  check('and without it a 3% race can be absent - the box is what guarantees it', seenMissing);
  check('a race tied line appears only for a race in the city',
    a.quirks.some((q) => /dwarven|Wolfen|elves/i.test(q.text)) || a.shops.some((s) => /Dwarven|Wolfen|Elven/.test(s.type)));
  const humansOnly = generateCity({ ...base(), races: [{ id: 'human', name: 'Human', pct: 100 }], npcCount: 30 }, 5);
  check('and a humans-only city carries no race-tied shop or quirk',
    !humansOnly.shops.some((s) => /Wolfen|Elven|Dwarven|Orc|Goblin|Gnome/.test(s.type))
      && !humansOnly.quirks.some((q) => /Wolfen|elves|dwarves|orc|ogre|goblin|gnome|troll/i.test(q.text)));

  // ── settings that cannot build a city say so ──
  check('a breakdown not totalling 100% is refused by name',
    settingsProblems({ ...base(), races: [{ id: 'human', name: 'Human', pct: 90 }] }).some((p) => /90%/.test(p)));
  check('as is "one of every race" with fewer NPCs than races',
    settingsProblems({ ...base(), npcCount: 2 }).some((p) => /needs 4 named NPCs/.test(p)));
  const rest = restAreHuman([{ id: 'elf', name: 'Elf', pct: 30 }, { id: 'dwarf', name: 'Dwarf', pct: 15 }]);
  check('"Rest are human" fills the remainder with a human row',
    rest.length === 3 && rest.find((x) => x.id === 'human')?.pct === 55);
  let threw = false;
  try { generateCity({ ...base(), races: [{ id: 'human', name: 'Human', pct: 50 }] }, 1); } catch { threw = true; }
  check('and the engine itself refuses to build from bad settings', threw);

  // ── owners are named NPCs ──
  const ids = new Set(a.npcs.map((n) => n.id));
  check('every shop\'s owner is one of the named NPCs', a.shops.every((s) => ids.has(s.owner)));
  const few = generateCity({ ...base(), npcCount: 4 }, 9);
  check('and with fewer NPCs than shops, an NPC owns more than one rather than an owner being invented',
    few.shops.length > 4 && few.shops.every((s) => few.npcs.some((n) => n.id === s.owner)));

  // ── content ──
  check('3-5 city quirks', a.quirks.length >= 3 && a.quirks.length <= 5, a.quirks.length);
  check('a d10 rumour table, each marked true or false',
    a.rumours.length === 10 && a.rumours.every((x, i) => x.roll === i + 1 && typeof x.true === 'boolean'));
  check('a d6 encounter table in every district',
    a.districts.every((d) => d.encounters.length === 6 && d.encounters.every((e, i) => e.roll === i + 1)));
  check('no {slot} is left unfilled anywhere in the city', !/\{\w+\}/.test(exportJson(a)));
  const names = [a.overview.name, ...a.npcs.map((n) => n.name), ...a.shops.map((s) => s.name)].filter(Boolean);
  check('and no name is used twice', new Set(names.map((n) => n.toLowerCase())).size === names.length);

  // ── lock and reroll ──
  let locked = toggleLock(a, 'npc-2');
  locked = toggleLock(locked, 'shop-1');
  locked = toggleLock(locked, 'overview');
  const re = rerollCity(locked, 777);
  check('a reroll keeps every locked entry exactly',
    JSON.stringify(re.npcs.find((n) => n.id === 'npc-2')) === JSON.stringify(a.npcs.find((n) => n.id === 'npc-2'))
      && re.shops.find((s) => s.id === 'shop-1')?.name === a.shops.find((s) => s.id === 'shop-1')?.name
      && re.overview.name === a.overview.name);
  check('and rebuilds the rest', re.npcs.filter((n) => n.id !== 'npc-2').some((n, i) => n.name !== a.npcs.filter((x) => x.id !== 'npc-2')[i]?.name));
  const reNames = re.npcs.map((n) => n.name).filter(Boolean);
  check('without reusing a kept name', new Set(reNames.map((n) => n.toLowerCase())).size === reNames.length);
  const one = rerollEntry(a, 'npc-5');
  check('a single reroll changes that entry and keeps its race',
    one.npcs[5].name !== a.npcs[5].name && one.npcs[5].raceId === a.npcs[5].raceId);
  check('and nothing else', JSON.stringify({ ...one, npcs: null, rolls: null }) === JSON.stringify({ ...a, npcs: null, rolls: null })
    && one.npcs.every((n, i) => i === 5 || JSON.stringify(n) === JSON.stringify(a.npcs[i])));
  check('each reroll of it is different, and repeatable',
    rerollEntry(one, 'npc-5').npcs[5].name !== one.npcs[5].name
      && rerollEntry(a, 'npc-5').npcs[5].name === one.npcs[5].name);

  // ── the name pool: one call, one shape ──
  const pool = { city: ['Serravalle'], district: ['Canal Ward', 'Salt Row'], street: ['Via Nova'],
    shop: ['The Gilded Oar', 'Bruni & Sons', 'The Salt Lamp'],
    cultures: {
      human: { given: ['Marco', 'Lucia', 'Paolo', 'Chiara', 'Enzo', 'Bianca'], family: ['Venier', 'Contarini', 'Morosini'] },
      dwarf: { given: ['Hrolf', 'Sigga', 'Bjarn', 'Ingrid', 'Toke'], family: ['Stonebreaker'] },
      wolfen: { given: ['Grakk', 'Rasha', 'Vulgar', 'Kesh', 'Tor'], family: [] },
      elf: { given: ['Aelith', 'Caerel', 'Ilmar', 'Sylra', 'Thandor'], family: [] },
    } };
  const pooled = generateCity({ ...base(), npcCount: 6 }, 3, parsePool(JSON.stringify(pool), base()));
  check('with a pool, the city\'s names come from it',
    pooled.overview.name === 'Serravalle'
      && pooled.npcs.every((n) => !n.name || [...Object.values(pool.cultures)].some((c) => c.given.includes(n.name.split(' ')[0]))));
  const again = rerollEntry(pooled, 'npc-0');
  check('and a reroll draws from the same saved pool, with no call to make',
    JSON.stringify(again.pool) === JSON.stringify(pooled.pool)
    && pool.cultures[again.npcs[0].raceId].given.includes(again.npcs[0].name.split(' ')[0]));
  const refuses = (text) => { try { parsePool(text, base()); return false; } catch { return true; } };
  check('a pool that is not JSON, or is missing a race, is refused - never half-used',
    refuses('Here are some names: Marco, Lucia') && refuses(JSON.stringify({ ...pool, cultures: { human: pool.cultures.human } })));
  const exhausted = generateCity({ ...base(), npcCount: 30 }, 3, parsePool(JSON.stringify(pool), base()));
  // Every word of every name from the pool, and none twice. Distinct alone is
  // not enough: a padding fault injected here made "Tor undefined", which is
  // wrong and unique, and passed the first version of this check.
  const poolWords = new Set(Object.values(pool.cultures).flatMap((c) => [...c.given, ...c.family]));
  const named = exhausted.npcs.filter((n) => n.name);
  check('a pool that runs out leaves NPCs unnamed and says so - never a repeat, never a word from outside it',
    exhausted.warnings.some((w) => /ran out of new/.test(w)) && named.length < exhausted.npcs.length
      && new Set(named.map((n) => n.name)).size === named.length
      && named.every((n) => n.name.split(' ').every((w) => poolWords.has(w))),
    named.map((n) => n.name).join(', '));

  // ── the tables are the size the plan asked for ──
  const T = tablesFor('palladium-fantasy');
  const flat = ['GOVERNMENTS', 'TRADES', 'FACTIONS', 'DISTRICT_KINDS', 'MOODS', 'PLACES', 'NPC_ROLES', 'LOOKS',
    'PERSONALITIES', 'WANTS', 'SECRETS', 'CITY_QUIRKS', 'RUMOURS', 'ENCOUNTERS'];
  const small = flat.filter((k) => new Set(T[k]).size < 40).map((k) => `${k} ${new Set(T[k]).size}`);
  check('every table has 40 or more distinct entries', small.length === 0, small.join(', '));
  const specialties = T.SHOP_TYPES.flatMap((t) => t.specialties);
  check('and the shop specialties together are 40 or more', new Set(specialties).size >= 40);
  check('population bands run from hamlet to metropolis with no gap',
    sizeFor(1).id === 'hamlet' && sizeFor(99).id === 'hamlet' && sizeFor(100).id === 'village'
      && sizeFor(25000).id === 'metropolis');

  // ── the page ──
  const page = readFileSync(join(repoRoot, 'apps', 'city-creator', 'city.js'), 'utf8');
  check('the race list asks for this setting\'s R.C.C.s and never for retired ones',
    /classes\?system=\$\{encodeURIComponent\(S\.settings\.system\)\}&category=rcc/.test(page)
      && !/include_retired/.test(page));
  check('the AI is called in one place, only from Generate',
    (page.match(/await claudeRequest\(/g) || []).length === 1
      && page.indexOf('await claudeRequest(') > page.indexOf('async function generate()')
      && page.indexOf('await claudeRequest(') < page.indexOf('window.City ='));

  // ── the map (Phase 2) ──
  // Geometry the eye cannot audit across two hundred cities: every district
  // owns its share of the outline and no more, every pin sits in its own
  // district and clear of the others, and the wall only exists where the
  // city has one.
  section('City Creator map');
  const sizes = [60, 450, 2500, 12000, 60000];
  const withQuarter = { ...base(), races: [{ id: 'human', name: 'Human', pct: 75 }, { id: 'dwarf', name: 'Dwarf', pct: 25 }] };
  const outside = [], untiled = [], crowded = [], wallWrong = [], quarterless = [];
  for (let seed = 0; seed < 120; seed++) {
    const c = generateCity({ ...withQuarter, population: sizes[seed % 5] }, seed);
    const m = layoutMap(c);
    const whole = area(m.outline);
    const sum = m.districts.reduce((n, d) => n + area(d.polygon), 0);
    if (Math.abs(sum - whole) / whole > 0.001 || m.districts.length !== c.districts.length) untiled.push(seed);
    // Against the district the ENTRY names in the city, not the pin's own
    // record of it: a fault that pinned a shop in the wrong district rewrote
    // both halves of the pin and passed the first version of this check.
    const named = Object.fromEntries([...c.places, ...c.shops].map((e) => [e.id, e.district]));
    for (const p of m.pins) {
      const d = m.districts.find((x) => x.name === named[p.id]);
      if (!d || !inside(p.at, d.polygon)) outside.push(`${seed}:${p.id}`);
      if (m.pins.some((o) => o !== p && Math.hypot(o.at[0] - p.at[0], o.at[1] - p.at[1]) < 34)) crowded.push(`${seed}:${p.id}`);
    }
    if (!!m.wall !== !!c.overview.walls) wallWrong.push(seed);
    if (!m.districts.some((d) => d.race === 'dwarf')) quarterless.push(seed);
  }
  check('the districts tile the city outline exactly, one region each (120 cities)', untiled.length === 0, untiled.join(', '));
  check('every pin is inside its own district', outside.length === 0, outside.slice(0, 5).join(', '));
  check('and no two pins touch', crowded.length === 0, crowded.slice(0, 5).join(', '));
  check('the wall is drawn exactly when the city has walls', wallWrong.length === 0, wallWrong.join(', '));
  check('and a race quarter is on the map as a quarter', quarterless.length === 0, quarterless.join(', '));
  const walled = generateCity({ ...withQuarter, population: 60000 }, 3);
  const wm = layoutMap(walled);
  check('gates sit on the wall', wm.gates.length >= 2 && wm.gates.every((g) => wm.wall.some((w) => w[0] === g[0] && w[1] === g[1])));
  check('the same city draws the same map', JSON.stringify(layoutMap(walled)) === JSON.stringify(wm));
  const shopOne = walled.shops[0];
  const moved = layoutMap(rerollEntry(walled, shopOne.id));
  const elsewhere = wm.pins.filter((p) => p.districtId !== wm.pins.find((x) => x.id === shopOne.id).districtId
    && moved.pins.find((x) => x.id === p.id)?.districtId === p.districtId);
  check('rerolling a shop moves no pin in any other district',
    elsewhere.every((p) => JSON.stringify(moved.pins.find((x) => x.id === p.id).at) === JSON.stringify(p.at)));
  check('the view is cropped to the city, inside the sheet',
    wm.view[0] >= 0 && wm.view[1] >= 0 && wm.view[2] < wm.size && wm.view[0] + wm.view[2] <= wm.size);

  // The page keeps the map WITH the city (Phase 3 saves the generated city,
  // and a later layout change must not move a saved city's districts), and
  // every pin is a link to its entry.
  check('the page stores the map with the city on every change, and draws pins as links',
    /S\.city = withMap\(generateCity\(/.test(page) && /S\.city = withMap\(rerollEntry\(/.test(page)
      && /S\.city = withMap\(rerollCity\(/.test(page) && /<a href="#e-\$\{esc\(p\.id\)\}"/.test(page)
      && /id="e-\$\{esc\(id\)\}"/.test(page));
  const css = readFileSync(join(repoRoot, 'apps', 'city-creator', 'city.css'), 'utf8');
  check('and the map has a print rule that keeps it whole', /@media print[\s\S]*\.city-map \{[^}]*break-inside: avoid/.test(css));
}
