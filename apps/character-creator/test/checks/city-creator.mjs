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
// "Flesh out" (Phase 4d), the same way: flesh written onto every entry, kept
// by an entry reroll, bold left in, the secret left out of an NPC's prompt,
// an empty answer accepted, and a kept city saved without its guard. The
// guard fault first landed in keep(), which carries the same line, and the
// section passed; aimed at flesh() it failed.
// Shop names, the same way: shops named from the places theme again, a kind
// stripped of its words, an AI pool ignored, a clash renamed by the label
// 'Tavern', and the used-name test removed. The last PASSED a 50-city sampled
// check and is read from the source instead - see the comment there.
// Themes, the same way, 2026-09-24: draw() ignoring the intensity, Total
// falling back to the setting's lines when the theme ran out, raceNamed()
// answering yes for every race, stockShop() ignoring stockAs, a rumour's
// unknown {slot} let through, a reroll that dropped the theme, and a
// themed role's class ignored by rollRequest().
// Writing a theme (PR 2), the same way: a part's schema without the setting's
// stock rules, the buildings prompt asking every race for lines, a stray
// role/class pair kept, the flesh-out prompt without the theme, and a themed
// shop named from the AI name pool again.
// Themed rolls (PR 3), the same way: rollBlocker() answering null for a role
// with no class, the Rifts R.C.C.-alone exemption dropped, and rollRequest()
// sending the request without asking.
// Map styles (PR 4), the same way: an organic theme drawing a style's extras,
// grid avenues bent through the square, a canal city without its river, the station put off
// the railway, and present mode not drawing the core.
// Saved themes (PR 5), the same way: a race's name no longer kept with its
// lines, validateSavedTheme accepting a pack with no name pool, a removed role
// keeping its class, and the page's Generate losing the saved theme's id.
// Adapting (PR 6), the same way: the adapt prompt built with the OLD game's
// rules, the old theme's lines left out of it, the old game's stock rules
// carried into it, and the page saving an adaptation without adapted_from.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';
import { generateCity, rerollCity, rerollEntry, toggleLock, settingsProblems, restAreHuman, sizeFor,
  parsePool, tablesFor, exportJson, rollRequest, linkSheet, stockShop, restockShop, fleshPrompt, parseFlesh, withFlesh,
  FLESH_KINDS, validateThemePack, raceNamed, THEME_TABLES, THEME_MIN_LINES, THEME_INTENSITY, MAP_STYLES, RUMOUR_SLOTS,
  THEME_PARTS, themePrompt, parseThemePart, assembleThemePack, rollBlocker, validateSavedTheme, themeParts, editThemeTable, adaptPrompt }
  from '../../../city-creator/js/city-engine.js';
import { W, westPack } from '../fixtures/city-theme-pack.mjs';
import { layoutMap, inside, area } from '../../../city-creator/js/city-map.js';

const SECTIONS = ['City Creator engine', 'City Creator map', 'City Creator roll stats', 'City Creator shop stock',
  'City Creator flesh out', 'City Creator Rifts', 'City Creator shop names', 'City Creator themes',
  'City Creator theme writing', 'City Creator themed rolls', 'City Creator map styles',
  'City Creator saved themes', 'City Creator adapting'];

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
  // Every call is a press of a button: Generate (the name pool, or a theme's
  // five parts), Adapt on a saved theme, and, since Phase 4d, Flesh out on one
  // entry. A theme's parts go through askForPart, which only writeTheme (only
  // Generate calls it) and adaptTheme call. Nothing on load, never from ?seed=.
  const aiAt = [...page.matchAll(/await claudeRequest\(/g)].map((m) => m.index);
  const inFn = (at, start, end) => at > page.indexOf(start) && at < page.indexOf(end, page.indexOf(start));
  const callsOf = (name) => [...page.matchAll(new RegExp(`\\b${name}\\(`, 'g'))].map((m) => m.index)
    .filter((at) => at !== page.indexOf(`async function ${name}(`) + 'async function '.length);
  const themeCalls = callsOf('writeTheme');
  const partCalls = callsOf('askForPart');
  check('the AI is called in three places, each behind a button: a theme and the name pool on Generate, and Flesh out',
    aiAt.length === 3 && inFn(aiAt[0], 'async function askForPart(', 'async function writeTheme(')
      && themeCalls.length === 1 && inFn(themeCalls[0], 'async function generate()', 'function hashSeed(')
      && partCalls.length === 2 && inFn(partCalls[0], 'async function writeTheme(', '// ── saved themes')
      && inFn(partCalls[1], 'async adaptTheme(', 'applyEdit() {')
      && inFn(aiAt[1], 'async function generate()', 'function hashSeed(')
      && inFn(aiAt[2], 'async flesh(id)', 'forget() {'));

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

  // ── keeping (Phase 3) ──
  // What the players were shown is the G.M.'s decision, not the dice's: a
  // whole-city reroll must carry it, or the next reroll silently re-hides
  // everything the table has already seen.
  const shownCity = { ...toggleLock(a, 'place-0'), reveal: { 'place-0': true, 'shop-1': true },
    public: { 'place-0': 'The tower on the hill.' } };
  const reshown = rerollCity(shownCity, 99);
  check('a whole-city reroll keeps which pins are revealed and what the players read',
    reshown.reveal?.['place-0'] === true && reshown.reveal?.['shop-1'] === true && reshown.public?.['place-0'] === 'The tower on the hill.');
  check('and so does a one-entry reroll', rerollEntry(shownCity, 'npc-0').reveal?.['place-0'] === true);
  check('the kept city\'s controls are left off the printed page',
    /@media print[\s\S]*\.city-keep[\s\S]*\.city-reveal/.test(css) && /\.city-public:placeholder-shown \{ display: none; \}/.test(css));
  // A NEW city - from Generate or from ?seed= - is not the saved one. Left
  // pointing at the saved row, "Save changes" would overwrite that city with
  // this one; a reload of ?seed= did exactly that on screen before this line.
  const seedBlock = page.slice(page.indexOf("const urlSeed ="), page.indexOf('render();', page.indexOf("const urlSeed =")));
  const genBlock = page.slice(page.indexOf('async function generate()'), page.indexOf('function hashSeed('));
  check('a new city, generated or opened from ?seed=, is never the saved one',
    /S\.saved = null; S\.dirty = false;/.test(seedBlock) && /S\.saved = null; S\.dirty = false;/.test(genBlock));
  check('reveal and players\' text are saved as they are flipped, not held for "Save changes"',
    /async reveal\(id\) \{[\s\S]*?post\(`cities\/\$\{S\.saved\.id\}`, 'PATCH', \{ reveal:/.test(page)
      && /async publicText\(id, text\) \{[\s\S]*?post\(`cities\/\$\{S\.saved\.id\}`, 'PATCH', \{ public:/.test(page));

  // ── "Roll stats" (Phase 4a) ──
  // A city NPC goes to the NPC roller as their race's R.C.C. with the job
  // their role maps to. Every Palladium Fantasy race takes an occupation, so
  // a role with no job would be refused before anything is rolled.
  section('City Creator roll stats');
  const unmapped = T.NPC_ROLES.filter((role) => !T.ROLE_OCC[role]);
  check('every NPC role maps to a job O.C.C.', unmapped.length === 0, unmapped.join(', '));
  const owner = a.npcs.find((n) => /^owner of /.test(n.role));
  const other = a.npcs.find((n) => !/^owner of /.test(n.role));
  const ownerReq = rollRequest(a, owner.id);
  check('an NPC goes to the roller as their race with their role\'s job, under their own name',
    ownerReq.class_id === owner.raceId && ownerReq.occ_class_id === T.OWNER_OCC && ownerReq.name === owner.name
      && ownerReq.count === 1, JSON.stringify(ownerReq));
  check('and a shop owner as the owner\'s job, the rest by their role',
    !other || rollRequest(a, other.id).occ_class_id === T.ROLE_OCC[other.role]);
  const linked = linkSheet(a, owner.id, 4242);
  check('the sheet it makes is linked from that entry and no other',
    linked.npcs.find((n) => n.id === owner.id).sheet_id === 4242 && linked.npcs.filter((n) => n.sheet_id).length === 1);
  check('rerolling the entry makes a new person, and drops the link',
    !rerollEntry(linked, owner.id).npcs.find((n) => n.id === owner.id).sheet_id);
  // The roller REFUSES rather than guesses, and the page shows that refusal
  // as it comes: the error is the roller's, and nothing is rolled in its place.
  const roll = page.slice(page.indexOf('async rollStats(id)'), page.indexOf('forget() {'));
  check('the page sends the roller exactly that request, and shows its refusal as it comes',
    /const body = rollRequest\(S\.city, id\);/.test(roll) && /npcs\/generate`, 'POST', body\)/.test(roll)
      && /S\.rolls\[id\] = \{ msg: err\.message, err: true \};/.test(roll)
      && (roll.match(/npcs\/generate/g) || []).length === 1);
  check('and only for a kept city, whose campaign the sheet can belong to',
    /function statsTools\(n\) \{\s*if \(!S\.saved\) return '';/.test(page));

  // ── shop inventories (Phase 4b) ──
  // 6-10 real Codex rows per shop, by the shop type's rule, at book price x
  // the city's wealth, copied into the city. A fixture catalog here, so each
  // property is pinned against rows whose answer is known; regression proves
  // the real catalog can stock every shop type.
  section('City Creator shop stock');
  const gearRow = (slug, name, category, cost, system = 'palladium-fantasy') => ({ slug, name, category, cost, system });
  // More wrong rows (18) than right ones (14), so a rule that stopped filtering would
  // put one on the shelf within a few draws; the check below takes ten.
  const armour = Array.from({ length: 14 }, (_, i) => gearRow(`plate-${i}`, `Plate Armor ${i}`, 'armor', 100 + i));
  const wrong = Array.from({ length: 6 }, (_, i) => [
    gearRow(`cloak-${i}`, `Cloak of Armor ${i}`, 'armor', 900),          // the Armourer's rule leaves cloaks out
    gearRow(`free-${i}`, `Plate Armor Free ${i}`, 'armor', 0),           // no price, no sale
    gearRow(`mdc-${i}`, `Plate Armor MDC ${i}`, 'armor', 5000, 'rifts'), // another game's
  ]).flat();
  const fixture = [...armour, ...wrong,
    gearRow('bread-1', 'Bread, 4 loaves', 'gear', 1), gearRow('buns-1', 'Buns/rolls 2 dozen', 'gear', 1)];
  // A Rich city, so the price multiplier is not 1 and a price left at book shows.
  const oneShop = (type) => ({ ...a, overview: { ...a.overview, wealth: 'Rich' }, shops: [{ ...a.shops[0], id: 'shop-0', type }] });
  const armoury = stockShop(oneShop('Armourer'), 'shop-0', fixture);
  const stock = armoury.shops[0].inventory;
  const mult = T.WEALTH.find((x) => x.label === 'Rich').price;
  let shelf = armoury;
  const strays = new Set();
  for (let k = 0; k < 10; k++) {
    for (const i of shelf.shops[0].inventory) if (!/^plate-\d+$/.test(i.slug)) strays.add(i.slug);
    shelf = restockShop(shelf, 'shop-0', fixture);
  }
  check('a shop is stocked with 6-10 distinct real rows its rule allows - in its game, priced, and none it excludes',
    stock.length >= 6 && stock.length <= 10 && new Set(stock.map((i) => i.slug)).size === stock.length
      && strays.size === 0, `${stock.length} rows; strays over ten restocks: ${[...strays].join(', ')}`);
  check('priced at book price times the city\'s wealth, with the book price kept beside it',
    stock.every((i) => i.price === Math.max(1, Math.round(i.book * mult))), `x${mult}`);
  check('the same city stocks the same shelf, and a restock draws another',
    JSON.stringify(stockShop(oneShop('Armourer'), 'shop-0', fixture).shops[0].inventory) === JSON.stringify(stock)
      && JSON.stringify(restockShop(armoury, 'shop-0', fixture).shops[0].inventory) !== JSON.stringify(stock));
  const bakery = stockShop(oneShop('Bakery'), 'shop-0', fixture).shops[0];
  check('a rule the Codex can only partly fill stocks what exists and says so - never padded',
    bakery.inventory.length === 2 && /has 2 items/.test(bakery.stock_note || ''), JSON.stringify(bakery));
  const allTypes = [...T.SHOP_TYPES.map((x) => x.label), ...Object.values(T.RACE_LINES).flatMap((r) => r.shops.map((x) => x.label))];
  const ruleless = allTypes.filter((label) => !T.SHOP_STOCK[label]);
  check('every kind of shop the city can make has a stock rule', ruleless.length === 0, ruleless.join(', '));
  check('the page stocks through the engine with the Codex\'s own gear, and marks a kept city changed',
    /S\.city = stockShop\(S\.city, id, await loadGear\(\)\); S\.stockMsg = ''; changed\(\);/.test(page)
      && /api\('codex\?section=gear'\)/.test(page));

  // ── "Flesh out" (Phase 4d) ──
  // One AI call for one entry, saved into that entry. What can be proved
  // without the model: the prompt names the entry and its city, the answer is
  // tidied and an empty one refused, the text lands on that entry alone, and
  // a reroll or a lock treats it as part of the entry.
  section('City Creator flesh out');
  const firstOf = { district: a.districts[0], place: a.places[0], shop: a.shops[0], npc: a.npcs[0] };
  const prompts = Object.fromEntries(FLESH_KINDS.map((k) => [k, fleshPrompt(a, firstOf[k].id).prompt]));
  const unnamed = FLESH_KINDS.filter((k) => !prompts[k].includes(a.overview.name) || !prompts[k].includes(firstOf[k].name));
  check('a flesh-out prompt names its entry and its city, for each of the four kinds',
    FLESH_KINDS.join() === 'district,place,shop,npc' && unnamed.length === 0, unnamed.join(', '));
  check('and carries what the entry already says, so the answer can fit it',
    prompts.npc.includes(a.npcs[0].secret) && prompts.shop.includes(a.shops[0].specialty)
      && prompts.district.includes(a.districts[0].mood));
  const refused = (fn) => { try { fn(); return false; } catch { return true; } };
  check('a quirk, a rumour or an unknown id is refused, not guessed at',
    refused(() => fleshPrompt(a, a.quirks[0].id)) && refused(() => fleshPrompt(a, a.rumours[0].id))
      && refused(() => fleshPrompt(a, 'npc-999')) && refused(() => withFlesh(a, 'npc-999', 'x')));
  const fence = '```';
  check('an answer is tidied to plain prose - no fence, heading, bullet or bold',
    parseFlesh(`${fence}\n## The Mill\n**Loud** and wet.\n\n- A hook.\n${fence}`) === 'The Mill\nLoud and wet.\n\nA hook.');
  check('an empty answer is an error and saves nothing', refused(() => parseFlesh(` \n${fence}${fence} `)));
  const long = parseFlesh('word '.repeat(2000));
  check('a runaway answer is capped at a word boundary', long.length <= 2401 && long.endsWith('word…'), long.length);
  const npcId = a.npcs[0].id;
  const fleshed = withFlesh(a, npcId, 'A NOTE');
  check('the text lands on that entry and no other',
    fleshed.npcs[0].flesh === 'A NOTE' && JSON.stringify(fleshed).split('A NOTE').length === 2 && !a.npcs[0].flesh);
  check('a reroll of the entry makes a new one, and drops its flesh', !rerollEntry(fleshed, npcId).npcs[0].flesh);
  check('a lock keeps it through a reroll of the city, and an unlocked entry loses it',
    rerollCity(toggleLock(fleshed, npcId), 99).npcs[0].flesh === 'A NOTE' && !rerollCity(fleshed, 99).npcs[0].flesh);
  const fl = page.slice(page.indexOf('async flesh(id)'), page.indexOf('forget() {'));
  check('the page asks once through /api/claude, keeps the answer in the entry, and saves a kept city at once',
    (fl.match(/claudeRequest\(/g) || []).length === 1 && /S\.city = withFlesh\(S\.city, id, parseFlesh\(/.test(fl)
      && /if \(S\.saved\) \{\s*const \{ reveal: _r, public: _p, \.\.\.summary \} = await post\(`cities\/\$\{S\.saved\.id\}`, 'PATCH', \{ city: S\.city \}\);/.test(fl));
  check('every district, place, shop and NPC card has the button',
    ['fleshHtml(d)', 'fleshHtml(p)', 'fleshHtml(s)', 'fleshHtml(n)'].every((x) => page.includes(x)));

  // ── the Rifts tables (Phase 5) ──
  // A second table file in the Palladium Fantasy file's shape, plus what
  // Rifts adds: tech level, Coalition presence, ley lines, M.D.C. walls.
  section('City Creator Rifts');
  const RT = tablesFor('rifts');
  const riftsFlat = [...flat, 'TECH_LEVELS', 'COALITION', 'LEY_LINES'];
  const riftsSmall = riftsFlat.filter((k) => new Set(RT[k] || []).size < 40).map((k) => `${k} ${new Set(RT[k] || []).size}`);
  check('every Rifts table has 40 or more distinct entries, the three Rifts-only ones too',
    riftsSmall.length === 0, riftsSmall.join(', '));
  check('and its shop specialties together are 40 or more', new Set(RT.SHOP_TYPES.flatMap((t) => t.specialties)).size >= 40);
  // Job names (NPC_ROLES) are shared words, not written lines: a farmer is a farmer.
  const riftsCopied = riftsFlat.filter((k) => k !== 'NPC_ROLES').filter((k) => RT[k].some((line) => (T[k] || []).includes(line)));
  check('no Rifts line is a Palladium Fantasy line carried over', riftsCopied.length === 0, riftsCopied.join(', '));
  check('every Rifts wall is an M.D.C. wall', RT.WALLS.every((w) => /M\.D\.C\.|mega-damage/i.test(w)),
    RT.WALLS.filter((w) => !/M\.D\.C\.|mega-damage/i.test(w)).join(' | '));
  const riftsSettings = () => ({ system: 'rifts', population: 12000, npcCount: 12, everyRace: true,
    races: [{ id: 'human', name: 'Human', pct: 70 }, { id: 'noro', name: 'Noro', pct: 20, takesOcc: true },
      { id: 'dragon-hatchling', name: 'Dragon Hatchling', pct: 10, takesOcc: false }] });
  const rc = generateCity(riftsSettings(), 777);
  check('a Rifts city is the same city from the same seed', exportJson(rc) === exportJson(generateCity(riftsSettings(), 777)));
  check('its overview carries a tech level, the Coalition\'s presence and the ley lines, each from its table',
    JSON.stringify((rc.overview.extras || []).map((x) => x.key)) === '["tech","coalition","ley"]'
      && RT.TECH_LEVELS.includes(rc.overview.extras[0].text) && RT.COALITION.includes(rc.overview.extras[1].text)
      && RT.LEY_LINES.includes(rc.overview.extras[2].text), JSON.stringify(rc.overview.extras));
  check('a Palladium Fantasy city draws none of them, so it is built exactly as before', !('extras' in a.overview));
  check('its lines come from the Rifts tables, not the Palladium Fantasy ones',
    RT.GOVERNMENTS.includes(rc.overview.government) && rc.districts.every((d) => RT.MOODS.includes(d.mood))
      && rc.npcs.every((n) => RT.SECRETS.includes(n.secret)) && !/\{\w+\}/.test(exportJson(rc)));
  check('and its NPCs are named from the Rifts themes, with nobody left unnamed',
    rc.npcs.every((n) => n.name) && rc.warnings.length === 0, rc.warnings.join('; '));
  check('every Rifts role maps to an O.C.C., and every Rifts shop kind has a stock rule',
    RT.NPC_ROLES.every((role) => RT.ROLE_OCC[role]) && RT.SHOP_TYPES.every((t) => RT.SHOP_STOCK[t.label]));
  const human = rc.npcs.find((n) => n.raceId === 'human');
  const noro = rc.npcs.find((n) => n.raceId === 'noro');
  const dragon = rc.npcs.find((n) => n.raceId === 'dragon-hatchling');
  const jobOf = (n) => (/^owner of /.test(n.role) ? RT.OWNER_OCC : RT.ROLE_OCC[n.role]);
  const [humanReq, noroReq, dragonReq] = [human, noro, dragon].map((n) => rollRequest(rc, n.id));
  check('a Rifts human rolls as their job\'s O.C.C. alone, a race that takes an O.C.C. with it, and any other as its R.C.C. alone',
    humanReq.class_id === jobOf(human) && !('occ_class_id' in humanReq)
      && noroReq.class_id === 'noro' && noroReq.occ_class_id === jobOf(noro)
      && dragonReq.class_id === 'dragon-hatchling' && !('occ_class_id' in dragonReq),
    JSON.stringify([humanReq, noroReq, dragonReq]));
  check('and the page marks which races take one by the roller\'s own rule',
    /import \{ needsOccupation \} from '\/apps\/character-creator\/js\/parser\.js';/.test(page)
      && /takesOcc: needsOccupation\(c\)/.test(page));
  check('the page offers Rifts, adds the Human row the R.C.C. list lacks, and prices in the setting\'s money',
    !/Rifts \(coming\)/.test(page) && /const human = tablesFor\(S\.settings\.system\)\?\.HUMAN;/.test(page)
      && page.includes('S.rccs.unshift({ ...human })')
      && /<td>\$\{i\.price\} \$\{currency\(S\.city\)\}<\/td>/.test(page) && RT.CURRENCY === 'cr');

  // ── shop names say what the shop sells ──
  // Until 2026-09-23 a shop took a generic name from the places theme, so
  // "Fitch's Energy Weapons" could be a body-chop-shop. Now a shop is named
  // from its own kind's words; a tavern, and a city with an AI pool, keep the
  // old way.
  section('City Creator shop names');
  const kindsOf = (TT) => [...TT.SHOP_TYPES, ...Object.values(TT.RACE_LINES).flatMap((x) => x.shops)];
  const unworded = [['palladium-fantasy', T], ['rifts', RT]].flatMap(([sys, TT]) => kindsOf(TT)
    .filter((k) => (k.type === 'tavern') === (k.names?.length >= 5)).map((k) => `${sys} ${k.label}`));
  check('every shop kind but the tavern has five or more words of its own, and the tavern has none',
    unworded.length === 0 && T.SHOP_ADJECTIVES.length >= 20 && RT.SHOP_ADJECTIVES.length >= 20, unworded.join(', '));
  const mismatched = [];
  const allNames = [];
  for (let seed = 0; seed < 25; seed++) {
    for (const c of [generateCity({ ...base(), population: 60000 }, seed),
      generateCity({ system: 'rifts', population: 60000, npcCount: 8, everyRace: true,
        races: [{ id: 'human', name: 'Human', pct: 100 }] }, seed)]) {
      const TT = tablesFor(c.settings.system);
      for (const s of c.shops) {
        const kind = kindsOf(TT).find((k) => k.label === s.type);
        allNames.push(`${c.settings.system}:${seed}:${s.name}`);
        if (kind?.names && !kind.names.some((w) => s.name.endsWith(' ' + w))) mismatched.push(`${s.name} [${s.type}]`);
      }
    }
  }
  check('over 50 metropolises of both settings, every shop is named by its own kind',
    allNames.length > 500 && mismatched.length === 0, `${allNames.length} shops; ${mismatched.slice(0, 5).join(', ')}`);
  // Read, not sampled: with the used-name test removed, 12 of 800 metropolises
  // repeated a shop name (measured 2026-09-23) - so a sample this size passes
  // a broken namer about half the time, and 800 cities take over a minute.
  const shopNamer = readFileSync(join(repoRoot, 'apps', 'city-creator', 'js', 'city-engine.js'), 'utf8')
    .split('shop(r, t) {')[1]?.split('\n    },')[0] || '';
  check('and the shop namer never hands out a name the city already uses',
    /if \(!ctx\.used\.has\(n\.toLowerCase\(\)\)\) \{ ctx\.used\.add\(n\.toLowerCase\(\)\); return n; \}/.test(shopNamer));
  check('a city with an AI name pool still names its shops from the pool',
    pooled.shops.every((s) => !s.name || pool.shop.includes(s.name)), pooled.shops.map((s) => s.name).join(', '));
  const engineSrc = readFileSync(join(repoRoot, 'apps', 'city-creator', 'js', 'city-engine.js'), 'utf8');
  check('and a shop renamed after a clash is renamed by its kind, not by the label "Tavern"',
    /x\.name = ctx\.names\.shop\(r, shopTypeFor\(ctx, x\.type\)\)/.test(engineSrc) && !/x\.type === 'Tavern'/.test(engineSrc));

  section('City Creator themes');

  // The test pack (fixtures/city-theme-pack.mjs): every line carries [W].
  const westOk = validateThemePack(westPack(), base());
  const themed = (intensity, over = {}) => ({ intensity, pack: westOk, ...over });
  const themeRefuses = (edit, settings = base()) => {
    const pk = westPack(); edit(pk);
    try { validateThemePack(pk, settings); return false; } catch { return true; }
  };

  check('a whole test pack is accepted, and keeps only what the engine reads',
    westOk.tables.LOOKS.length === 12 && westOk.shopTypes.length === 3 && westOk.mapStyle === 'rail'
      && westOk.system === 'palladium-fantasy' && westOk.roleOcc['[W] npc_roles 1'] === 'soldier');
  check('a pack missing a table, or short of lines, or with a table the city does not use, is refused',
    themeRefuses((pk) => { delete pk.tables.MOODS; })
      && themeRefuses((pk) => { pk.tables.MOODS = W('mood', THEME_MIN_LINES - 1); })
      && themeRefuses((pk) => { pk.tables.STREETS = W('street'); }));
  check('a rumour with a {slot} the city cannot fill is refused, and one with every slot it can fill is not',
    themeRefuses((pk) => { pk.tables.RUMOURS[0] += ' {sheriff}'; })
      && !themeRefuses((pk) => { pk.tables.RUMOURS[0] += RUMOUR_SLOTS.map((x) => ` {${x}}`).join(''); }));
  check('a shop kind that sells by no stock rule of the setting, or reuses a setting kind\'s name, is refused',
    themeRefuses((pk) => { pk.shopTypes[0].stockAs = 'Gun shop'; })
      && themeRefuses((pk) => { pk.shopTypes[0].label = 'Smithy'; }));
  check('a role mapped to a class the setting cannot roll, or a role the theme does not have, is refused',
    themeRefuses((pk) => { pk.roleOcc['[W] npc_roles 1'] = 'gunslinger'; })
      && themeRefuses((pk) => { pk.roleOcc.sheriff = 'soldier'; }));
  check('a map style the map does not draw is refused, and a pack for another setting is refused',
    !MAP_STYLES.includes('hex') && themeRefuses((pk) => { pk.mapStyle = 'hex'; })
      && MAP_STYLES.every((m) => !themeRefuses((pk) => { pk.mapStyle = m; })) && themeRefuses((pk) => { pk.system = 'rifts'; }));

  // ── a race's own lines only for a race the G.M. named ──
  check('the named race keeps its themed lines and the unnamed one\'s are thrown away',
    !!westOk.raceLines?.wolfen && !westOk.raceLines?.dwarf);
  check('a race counts as named in its own naming box, and by its plural, but not inside another word',
    raceNamed({ id: 'dwarf', name: 'Dwarf', theme: 'dwarves are the town\'s miners' }, 'Old West')
      && raceNamed({ id: 'elf', name: 'Elf' }, 'the Elfs of the valley')
      && !raceNamed({ id: 'elf', name: 'Elf' }, 'a self-made town of shelf-builders'));
  const quirkSeen = { wolfenBase: 0, wolfenTheme: 0, dwarfBase: 0 };
  const PT = tablesFor('palladium-fantasy');
  for (let seed = 0; seed < 40; seed++) {
    for (const q of generateCity(base(), seed, null, themed('light')).quirks) {
      if (PT.RACE_LINES.wolfen.quirks.includes(q.text)) quirkSeen.wolfenBase++;
      if (q.text.startsWith('[W] wolfen quirk')) quirkSeen.wolfenTheme++;
      if (PT.RACE_LINES.dwarf.quirks.includes(q.text)) quirkSeen.dwarfBase++;
    }
  }
  check('so over 40 cities the Wolfen quirks are all the theme\'s, and the dwarves keep the setting\'s',
    quirkSeen.wolfenBase === 0 && quirkSeen.wolfenTheme > 0 && quirkSeen.dwarfBase > 0, JSON.stringify(quirkSeen));

  // ── intensity ──
  const share = (intensity) => {
    let own = 0, all = 0;
    for (let seed = 0; seed < 60; seed++) {
      const c = generateCity(base(), seed, null, themed(intensity));
      for (const n of c.npcs) for (const f of ['look', 'want', 'secret']) { all++; if (n[f].startsWith('[W]')) own++; }
    }
    return own / all;
  };
  const shares = Object.fromEntries(Object.keys(THEME_INTENSITY).map((k) => [k, share(k)]));
  check('Light draws about 30% of lines from the theme, Strong about 70%, Total all of them',
    Object.keys(shares).join() === 'light,strong,total' && shares.light > 0.22 && shares.light < 0.38
      && shares.strong > 0.62 && shares.strong < 0.78 && shares.total === 1,
    JSON.stringify(shares));
  const totalCity = generateCity({ ...base(), population: 90000 }, 7, null, themed('total'));
  const raceKinds = Object.values(PT.RACE_LINES).flatMap((x) => x.shops || []).map((k) => k.label);
  check('at Total every shop is one of the theme\'s kinds or a race\'s own, and every themed shop names its stock rule',
    totalCity.shops.every((s) => raceKinds.includes(s.type) || westOk.shopTypes.some((k) => k.label === s.type && s.stockAs === k.stockAs)),
    totalCity.shops.map((s) => s.type).join(', '));
  check('and the theme\'s own overview line is added after the setting\'s',
    totalCity.overview.extras?.at(-1)?.label === 'Law' && totalCity.overview.extras.at(-1).text.startsWith('[W] law'));
  const shortPack = validateThemePack({ ...westPack(), tables: { ...westPack().tables, PLACES: W('place', THEME_MIN_LINES) } }, base());
  const ranOut = generateCity({ ...base(), population: 90000 }, 7, null, { intensity: 'total', pack: shortPack });
  check('a Total theme that runs out of places stops at what it has and says so - no setting lines fill in',
    ranOut.places.length === THEME_MIN_LINES && ranOut.places.every((p) => p.name.startsWith('[W]'))
      && ranOut.warnings.some((w) => /ran out of places/.test(w)), `${ranOut.places.length} places; ${ranOut.warnings.join('; ')}`);
  // And a one-entry reroll with nothing left says so too, rather than keeping
  // the old place in silence (a claim audit found it silent, 2026-09-24).
  const rerolledOut = rerollEntry({ ...ranOut, warnings: [] }, 'place-0');
  check('and so does a reroll of one place when the theme has none left - it keeps the old one and says why',
    rerolledOut.places[0].name === ranOut.places[0].name && rerolledOut.warnings.some((w) => /ran out of places/.test(w)),
    rerolledOut.warnings.join('; '));

  // ── the theme is kept with the city, through rerolls ──
  check('a themed city keeps its theme, and a city with none has no theme key at all',
    totalCity.theme?.pack?.title === 'Old West boomtown' && !('theme' in generateCity(base(), 7)));
  const rerolled = rerollCity(toggleLock(totalCity, 'npc-0'), 99);
  const quirkRe = rerollEntry(totalCity, 'quirk-0');
  const placeRe = rerollEntry(totalCity, 'place-0');
  check('a reroll of the city or of one entry still draws from the theme',
    rerolled.theme?.intensity === 'total' && rerolled.npcs.every((n) => n.look.startsWith('[W]'))
      && quirkRe.quirks[0].text.startsWith('[W]') && placeRe.places[0].name.startsWith('[W]'),
    `${quirkRe.quirks[0].text} / ${placeRe.places[0].name}`);

  // ── the theme's roles roll, and its shops stock ──
  let roleCity = totalCity;
  const mapped = roleCity.npcs.find((n) => n.role === '[W] npc_roles 1')
    || (roleCity = { ...totalCity, npcs: totalCity.npcs.map((n, i) => (i ? n : { ...n, role: '[W] npc_roles 1' })) }).npcs[0];
  check('an NPC in a themed role rolls as the class the theme mapped it to',
    rollRequest(roleCity, mapped.id).occ_class_id === 'soldier');
  const saloon = { ...totalCity, shops: [{ id: 'shop-0', name: 'The Dusty Saloon', type: 'Saloon', stockAs: 'Tavern', owner: null }] };
  const drinks = Array.from({ length: 8 }, (_, i) => ({ slug: `ale-${i}`, name: `Ale, keg ${i}`, category: 'gear', cost: 5 + i }));
  check('and a themed shop stocks by the setting rule it names',
    stockShop(saloon, 'shop-0', drinks).shops[0].inventory.length >= 6);
  check('a theme with an unknown intensity is refused before a city is made',
    (() => { try { generateCity(base(), 1, null, { intensity: 'wild', pack: westOk }); return false; } catch { return true; } })());

  section('City Creator theme writing');

  // The five calls: every table in exactly one part, and each schema holding
  // the choices the check will enforce.
  const partKeys = Object.values(THEME_PARTS).flat();
  check('the five parts between them ask for every table, and no table twice',
    partKeys.length === THEME_TABLES.length && THEME_TABLES.every((k) => partKeys.includes(k)), partKeys.join(', '));
  const PFT = tablesFor('palladium-fantasy');
  const people = themePrompt('people', base(), westPack().prompt);
  const buildings = themePrompt('buildings', base(), westPack().prompt);
  const streets = themePrompt('streets', base(), westPack().prompt);
  const occEnum = people.schema.properties.roleOcc.items.properties.occ.enum;
  const stockEnum = buildings.schema.properties.shopTypes.items.properties.stockAs.enum;
  check('the people part may answer only a class the setting can roll, and every one of them',
    JSON.stringify([...occEnum].sort()) === JSON.stringify([...new Set([...Object.values(PFT.ROLE_OCC), PFT.OWNER_OCC])].sort()));
  check('the buildings part may answer only the setting\'s stock rules and the map styles the map knows',
    JSON.stringify(stockEnum) === JSON.stringify(Object.keys(PFT.SHOP_STOCK))
      && JSON.stringify(buildings.schema.properties.mapStyle.enum) === JSON.stringify(MAP_STYLES));
  check('and it asks for a race\'s own lines only for the race the theme names',
    JSON.stringify(Object.keys(buildings.schema.properties.raceLines?.properties || {})) === '["wolfen"]'
      && !('raceLines' in themePrompt('buildings', base(), 'Neo Tokyo arcology').schema.properties));
  check('the streets part names every slot a rumour may use',
    RUMOUR_SLOTS.every((x) => streets.prompt.includes(`{${x}}`)));
  check('every part\'s schema is strict: each object lists all its fields as required and allows no others',
    Object.keys(THEME_PARTS).every((part) => {
      const walk = (x) => !x || typeof x !== 'object' || (x.type !== 'object'
        || (x.additionalProperties === false && JSON.stringify(Object.keys(x.properties).sort()) === JSON.stringify([...x.required].sort())))
        && Object.values(x.properties || {}).every(walk) && walk(x.items);
      return walk(themePrompt(part, base(), westPack().prompt).schema);
    }));

  // Five answers, as the calls return them, put back together.
  const wp = westPack();
  const tablesOf = (part) => Object.fromEntries(THEME_PARTS[part].map((k) => [k, wp.tables[k]]));
  const answers = {
    people: { tables: tablesOf('people'),
      roleOcc: [...Object.entries(wp.roleOcc).map(([role, occ]) => ({ role, occ })), { role: 'a role it never listed', occ: 'soldier' }] },
    buildings: { tables: tablesOf('buildings'), shopTypes: wp.shopTypes, mapStyle: wp.mapStyle, raceLines: wp.raceLines },
    overview: { title: wp.title, tables: tablesOf('overview'), overviewExtras: wp.overviewExtras },
    streets: { tables: tablesOf('streets') },
    names: { city: ['Dust Creek'], district: ['Railside'], street: ['Main'], shop: ['The Last Chance'],
      cultures: Object.fromEntries(base().races.map((x) => [x.id, { given: W('given', 6), family: W('family', 6) }])) },
  };
  const parts = Object.fromEntries(Object.entries(answers).map(([part, v]) =>
    [part, parseThemePart(part, JSON.stringify(v), base(), wp.prompt)]));
  const assembled = assembleThemePack(wp.prompt, parts, base());
  const { names: _n, ...assembledRest } = assembled;
  check('five answers put together make the same pack as the whole one, with the names alongside',
    JSON.stringify(assembledRest) === JSON.stringify(validateThemePack(wp, base())) && assembled.names?.city[0] === 'Dust Creek');
  check('a role/class pair for a role the answer never listed is dropped, not refused',
    !('a role it never listed' in parts.people.roleOcc) && parts.people.roleOcc['[W] npc_roles 1'] === 'soldier');
  check('an answer that is not JSON, or is missing a table, is refused with the part named',
    (() => { try { parseThemePart('streets', 'Sure! Here are some rumours', base(), wp.prompt); return false; } catch (e) { return /streets/.test(e.message); } })()
      && (() => { try { parseThemePart('overview', JSON.stringify({ tables: {} }), base(), wp.prompt); return false; } catch { return true; } })());

  // The theme reaches the rest of the city.
  const withTheme = generateCity(base(), 11, assembled.names, { intensity: 'total', pack: assembledRest });
  check('a themed shop is named by its own kind\'s words, not from the AI name pool',
    withTheme.shops.filter((s) => s.stockAs).every((s) => !s.name
      || wp.shopTypes.find((k) => k.label === s.type).names.some((w) => s.name.endsWith(' ' + w))),
    withTheme.shops.map((s) => `${s.name} [${s.type}]`).join('; '));
  check('the flesh-out prompt tells the AI the city\'s theme, and a plain city\'s prompt has none',
    fleshPrompt(withTheme, withTheme.npcs[0].id).prompt.includes(wp.prompt)
      && !/theme/i.test(fleshPrompt(generateCity(base(), 11), 'npc-0').prompt));

  // The page: five parts, low effort and a schema each, and the theme handed to the engine.
  check('the page writes a theme through the five parts, each at low effort with its schema, and builds the city with it',
    /output_config: \{ effort: 'low', format: \{ type: 'json_schema', schema \} \}/.test(page)
      && /Object\.keys\(THEME_PARTS\)/.test(page) && /generateCity\(S\.settings, seed, pool, theme\)/.test(page));
  check('and a naming theme kept from before themes becomes the city theme',
    /else if \(typeof v\?\.nameTheme === 'string'\) S\.themeText = v\.nameTheme;/.test(page) && !/S\.nameTheme/.test(page));

  section('City Creator themed rolls');

  // A themed role the theme gave no class has nothing to roll as. The page
  // shows why instead of the button, and rollRequest refuses rather than send
  // a null class the roller would have to guess around.
  const rollCity = generateCity(base(), 5, null, { intensity: 'total', pack: validateThemePack(westPack(), base()) });
  const asRole = (c, role, raceId = 'human') => ({ ...c, npcs: c.npcs.map((n, i) => (i ? n : { ...n, role, raceId })) });
  const mappedNpc = asRole(rollCity, '[W] npc_roles 1');
  const noClass = asRole(rollCity, '[W] npc_roles 7');
  check('a themed role the theme mapped rolls as its class, and nothing blocks it',
    rollBlocker(mappedNpc, 'npc-0') === null && rollRequest(mappedNpc, 'npc-0').occ_class_id === 'soldier');
  check('a themed role with no class is blocked, with the role named, and rollRequest refuses it',
    /\[W\] npc_roles 7/.test(rollBlocker(noClass, 'npc-0') || '')
      && (() => { try { rollRequest(noClass, 'npc-0'); return false; } catch (e) { return /no class/.test(e.message); } })());
  check('an owner is never blocked, whatever the theme called their job',
    rollBlocker(asRole(rollCity, 'owner of The Dusty Saloon'), 'npc-0') === null);
  // Rifts: a race that is its R.C.C. alone needs no job, so a role with no
  // class does not stop it - but a human, whose O.C.C. IS the job, is stopped.
  const RR = tablesFor('rifts');
  const themedRiftsSettings = { system: 'rifts', population: 12000, npcCount: 4, everyRace: false,
    races: [{ id: 'human', name: 'Human', pct: 50 }, { id: 'dog-boy', name: 'Dog Boy', pct: 50 }] };
  const riftsPack = validateThemePack({ ...westPack(), raceLines: {},
    shopTypes: westPack().shopTypes.map((k, i) => ({ ...k, stockAs: Object.keys(RR.SHOP_STOCK)[i] })),
    roleOcc: { '[W] npc_roles 1': 'merc-soldier' } }, themedRiftsSettings);
  const riftsThemed = generateCity(themedRiftsSettings, 5, null, { intensity: 'total', pack: riftsPack });
  check('in Rifts a race that is its R.C.C. alone rolls without a job, and a human without one is blocked',
    rollBlocker(asRole(riftsThemed, '[W] npc_roles 7', 'dog-boy'), 'npc-0') === null
      && rollRequest(asRole(riftsThemed, '[W] npc_roles 7', 'dog-boy'), 'npc-0').class_id === 'dog-boy'
      && !!rollBlocker(asRole(riftsThemed, '[W] npc_roles 7', 'human'), 'npc-0'));
  check('a city with no theme is never blocked: every one of its NPCs has a job',
    [generateCity(base(), 5), generateCity({ ...themedRiftsSettings, npcCount: 12 }, 5)].every((c) => c.npcs.every((n) => rollBlocker(c, n.id) === null)));
  check('the page shows the reason in place of the button',
    /const blocked = !n\.sheet_id && rollBlocker\(S\.city, n\.id\);/.test(page));

  section('City Creator map styles');

  // A theme's street plan. Every style keeps the map's own promises - the
  // districts tile the outline, every pin is in its own district, no two pins
  // touch, a race quarter is a quarter - and adds its own shapes.
  const styleSettings = { ...base(), everyRace: false, npcCount: 6,
    races: [{ id: 'human', name: 'Human', pct: 75 }, { id: 'dwarf', name: 'Dwarf', pct: 25 }] };
  const styled = (style, seed, population = 12000) => {
    const c = generateCity({ ...styleSettings, population }, seed, null,
      { intensity: 'light', pack: validateThemePack({ ...westPack(), mapStyle: style }, styleSettings) });
    return { c, m: layoutMap(c) };
  };
  const broken = [];
  for (const style of MAP_STYLES) {
    for (let seed = 0; seed < 40; seed++) {
      const { c, m } = styled(style, seed, [60, 450, 2500, 12000, 60000][seed % 5]);
      const whole = area(m.outline);
      if (Math.abs(m.districts.reduce((n, d) => n + area(d.polygon), 0) - whole) / whole > 0.001) broken.push(`${style} ${seed} untiled`);
      const named = Object.fromEntries([...c.places, ...c.shops].map((e) => [e.id, e.district]));
      for (const p of m.pins) {
        const d = m.districts.find((x) => x.name === named[p.id]);
        if (!d || !inside(p.at, d.polygon)) broken.push(`${style} ${seed} ${p.id} outside`);
        if (m.pins.some((o) => o !== p && Math.hypot(o.at[0] - p.at[0], o.at[1] - p.at[1]) < 34)) broken.push(`${style} ${seed} ${p.id} crowded`);
      }
      if (!m.districts.some((d) => d.race === 'dwarf')) broken.push(`${style} ${seed} no quarter`);
    }
  }
  check('every street plan keeps the map\'s promises: tiled, pins in their districts and apart, the quarter drawn (200 cities)',
    broken.length === 0, broken.slice(0, 5).join(', '));

  const plainKeys = Object.keys(layoutMap(generateCity(styleSettings, 3))).sort().join();
  const organic = styled('organic', 3).m;
  check('an organic theme draws the map a city with no theme draws: no style, and nothing added',
    Object.keys(organic).sort().join() === plainKeys && !('style' in organic));
  const grids = [1, 2, 3, 4].map((seed) => styled('grid', seed).m);
  // A street runs edge to edge: its middle inside the city, each end on the outline.
  const toEdge = (poly, q) => Math.min(...poly.map((a, i) => {
    const b = poly[(i + 1) % poly.length];
    const t = Math.max(0, Math.min(1, ((q[0] - a[0]) * (b[0] - a[0]) + (q[1] - a[1]) * (b[1] - a[1])) / ((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2)));
    return Math.hypot(a[0] + t * (b[0] - a[0]) - q[0], a[1] + t * (b[1] - a[1]) - q[1]);
  }));
  const edgeToEdge = (m, [p, q]) => inside([(p[0] + q[0]) / 2, (p[1] + q[1]) / 2], m.outline)
    && toEdge(m.outline, p) < 1 && toEdge(m.outline, q) < 1;
  check('a grid city has two straight avenues crossing it gate to gate, and streets that stay inside the city',
    grids.every((m) => m.style === 'grid' && m.gates.length === 4 && m.roads.length === 2 && m.roads.every((r) => r.length === 2)
      && m.roads.every(([p, q]) => m.gates.some((g) => g + '' === p + '') && m.gates.some((g) => g + '' === q + ''))
      && m.streets.length >= 6 && m.streets.every((l) => edgeToEdge(m, l))));
  const railMaps = [1, 2, 3, 4].map((seed) => styled('rail', seed).m);
  const offLine = ([a, b], q) => Math.abs((b[0] - a[0]) * (a[1] - q[1]) - (a[0] - q[0]) * (b[1] - a[1])) / Math.hypot(b[0] - a[0], b[1] - a[1]);
  check('a railway crosses a rail city, its station on the line and near the square',
    railMaps.every((m) => m.rail.length === 2 && offLine(m.rail, m.station) < 1
      && Math.hypot(m.station[0] - m.square[0], m.station[1] - m.square[1]) < 120));
  const canalMaps = Array.from({ length: 12 }, (_, seed) => styled('canal', seed).m);
  check('a canal city always has its river, and two to four canals',
    canalMaps.every((m) => !!m.river && m.canals.length >= 2 && m.canals.length <= 4));
  const towers = [1, 2, 3].map((seed) => styled('vertical', seed).m);
  check('a vertical city\'s core rings the square, inside the city',
    towers.every((m) => inside(m.square, m.core) && m.core.every((q) => inside(q, m.outline))));
  check('the same themed city draws the same map', JSON.stringify(styled('rail', 7).m) === JSON.stringify(styled('rail', 7).m));

  // Drawn on the G.M.'s page and in present mode, and passed to the players.
  const presentJs = readFileSync(join(repoRoot, 'apps', 'gm-tools', 'present.js'), 'utf8');
  const viewJs = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'cities', '[id]', 'view.js'), 'utf8');
  const mapCss = readFileSync(join(repoRoot, 'apps', 'city-creator', 'city.css'), 'utf8');
  const shapes = ['canal', 'core', 'street', 'rail', 'station'];
  check('the G.M.\'s page and present mode both draw every street-plan shape, and the stylesheet styles each',
    shapes.every((k) => page.includes(`class="map-${k}"`) && presentJs.includes(`class: 'map-${k}'`)
      && new RegExp(`\\.map-${k} \\{`).test(mapCss)));
  // District fills are opaque: a shape drawn before them is hidden inside the
  // city, which is how the first draw of the canals showed only their ends -
  // and how every city's river had shown only its ends since Phase 2.
  check('and both draw the river, the canals and the core over the districts, not under them',
    page.includes('${districts}${river}${canals}${core}')
      && ['map-river', 'map-canal', 'map-core'].every((k) =>
        presentJs.indexOf(`class: '${k}'`) > presentJs.indexOf('map-cell ')));
  check('and the players\' view passes the shapes on',
    ['canals', 'streets', 'rail', 'station', 'core'].every((k) => new RegExp(`^\\s+${k}: `, 'm').test(viewJs)));

  section('City Creator saved themes');

  // A theme in the library is checked with no city in view. Its named races'
  // lines carry the race's name, so the rule that a race must be named still
  // runs - and a pack with lines for a race it never named is still refused.
  const wholePack = { ...validateThemePack(westPack(), base()),
    names: { city: ['Dust Creek'], district: ['Railside'], street: ['Main'], shop: ['The Last Chance'], cultures: {} } };
  const savedBack = validateSavedTheme(JSON.parse(JSON.stringify(wholePack)));
  check('a named race\'s lines keep the race\'s name, and a saved theme keeps them through the check',
    wholePack.raceLines?.wolfen?.name === 'Wolfen' && savedBack.raceLines?.wolfen?.quirks?.length === 2);
  check('a saved theme with lines for a race its words never name loses them',
    !('dwarf' in (validateSavedTheme({ ...wholePack, raceLines: { ...wholePack.raceLines,
      dwarf: { name: 'Dwarf', quirks: ['[W] a dwarf line'] } } }).raceLines || {})));
  const savedRefuses = (edit) => { try { validateSavedTheme(edit(JSON.parse(JSON.stringify(wholePack)))); return false; } catch { return true; } };
  check('a saved theme without its name pool, or for a game the City Creator has no tables for, is refused',
    savedRefuses((pk) => { delete pk.names; return pk; }) && savedRefuses((pk) => ({ ...pk, system: 'nightbane' })));
  check('and one that breaks a rule a written theme meets is refused the same way',
    savedRefuses((pk) => { pk.shopTypes[0].stockAs = 'Gun shop'; return pk; }));

  // A saved theme loads back as the five parts it was written in.
  const split = themeParts(savedBack);
  const rejoined = assembleThemePack(savedBack.prompt, split, base());
  check('a saved theme splits back into its five parts, and those parts make the same theme',
    Object.keys(split).join() === Object.keys(THEME_PARTS).join()
      && JSON.stringify(rejoined) === JSON.stringify(validateThemePack(savedBack, base())));

  // Editing one table: checked by the rules of its part.
  const [lookPart, looks] = editThemeTable(split, 'LOOKS', W('new look', 12), base(), savedBack.prompt);
  check('editing a table replaces its lines, in its own part', lookPart === 'people' && looks.tables.LOOKS[0] === '[W] new look 1');
  const editRefused = (key, lines) => { try { editThemeTable(split, key, lines, base(), savedBack.prompt); return false; } catch { return true; } };
  check('too few lines, or a rumour with a slot the city cannot fill, is refused',
    editRefused('MOODS', W('mood', THEME_MIN_LINES - 1))
      && editRefused('RUMOURS', [...W('rumour', 11), 'a rumour about {sheriff}']));
  const [, fewerRoles] = editThemeTable(split, 'NPC_ROLES', W('npc_roles', 12).slice(1), base(), savedBack.prompt);
  check('a role taken out of the roles takes its class with it, rather than being refused',
    !('[W] npc_roles 1' in fewerRoles.roleOcc) && fewerRoles.roleOcc['[W] npc_roles 2'] === 'merchant');

  // The page: the library's own endpoints, a part asked for again alone, and
  // a city made from a saved theme keeps which one.
  check('the page saves, lists, uses, renames and deletes themes through its own endpoints',
    /post\('city-themes', 'POST', \{ pack \}\)/.test(page) && /city-themes\?system=/.test(page)
      && /api\(`city-themes\/\$\{id\}`\)/.test(page) && /'PATCH', \{ name: name\.trim\(\) \}/.test(page)
      && /city-themes\/\$\{id\}`, \{ method: 'DELETE' \}/.test(page));
  check('a saved theme is checked on the way in, and a city made from it keeps which one',
    /const pack = validateSavedTheme\(theme\.pack\);/.test(page)
      && /theme = \{ intensity: S\.intensity, pack, \.\.\.\(S\.themeId \? \{ library_id: S\.themeId \} : \{\}\) \};/.test(page));
  check('a written part can be asked for again alone', /onclick="City\.rewritePart\('\$\{p\}'\)"/.test(page));

  section('City Creator adapting');

  // Adapting a theme writes its five parts again under the NEW game's rules,
  // with the old theme's lines for each part as a reference - and nothing of
  // the old game's stock rules or classes carried over.
  const pfSaved = validateSavedTheme({ ...validateThemePack(westPack(), base()),
    names: { city: ['Dust Creek'], district: ['Railside'], street: ['Main'], shop: ['The Last Chance'], cultures: {} } });
  const toRifts = { system: 'rifts', population: 12000, npcCount: 4, everyRace: false, races: [{ id: 'human', name: 'Human', pct: 100 }] };
  const RA = tablesFor('rifts');
  const adapted = Object.fromEntries(Object.keys(THEME_PARTS).map((part) => [part, adaptPrompt(part, toRifts, pfSaved)]));
  check('each adapted part is asked for under the new game\'s rules: its stock rules and its classes',
    JSON.stringify(adapted.buildings.schema.properties.shopTypes.items.properties.stockAs.enum) === JSON.stringify(Object.keys(RA.SHOP_STOCK))
      && JSON.stringify([...adapted.people.schema.properties.roleOcc.items.properties.occ.enum].sort())
        === JSON.stringify([...new Set([...Object.values(RA.ROLE_OCC), RA.OWNER_OCC])].sort()));
  check('and carries the old theme\'s own lines for that part, naming both games',
    adapted.people.prompt.includes(pfSaved.tables.LOOKS[0]) && adapted.streets.prompt.includes(pfSaved.tables.RUMOURS[0])
      && adapted.overview.prompt.includes(pfSaved.tables.GOVERNMENTS[0]) && adapted.buildings.prompt.includes(pfSaved.shopTypes[0].label)
      && /first written for Palladium Fantasy, and is being adapted to Rifts/.test(adapted.people.prompt));
  const pfOnlyRules = Object.keys(tablesFor('palladium-fantasy').SHOP_STOCK).filter((k) => !RA.SHOP_STOCK[k]);
  const adaptedBuilding = adapted.buildings.prompt.split('This theme was first written')[1] || '';
  check('but none of the old game\'s stock rules, and none of its role classes',
    !pfSaved.shopTypes.some((k) => adaptedBuilding.includes(`"stockAs":"${k.stockAs}"`))
      && !Object.values(pfSaved.roleOcc).some((occ) => (adapted.people.prompt.split('This theme was first written')[1] || '').includes(`"${occ}"`))
      && pfOnlyRules.length > 0);
  check('the names are written fresh for the new game\'s peoples',
    JSON.stringify(adapted.names) === JSON.stringify(themePrompt('names', toRifts, pfSaved.prompt)));
  check('and an answer that keeps an old game\'s stock rule is refused, as any theme\'s would be',
    (() => { try { parseThemePart('buildings', JSON.stringify({ tables: tablesOfPack(pfSaved, 'buildings'), shopTypes: pfSaved.shopTypes,
      mapStyle: 'rail' }), toRifts, pfSaved.prompt); return false; } catch (e) { return /stock rules/.test(e.message); } })());
  check('the page adapts through askForPart and saves a NEW theme that says which it came from',
    /askForPart\(adaptPrompt\(part, settings, source\)\)/.test(page)
      && /post\('city-themes', 'POST', \{ pack, name: `\$\{theme\.name\} \(\$\{label\}\)`, adapted_from: id \}\)/.test(page));
}

// A saved pack's tables for one part, as the answer to that part carries them.
function tablesOfPack(pack, part) {
  return Object.fromEntries(THEME_PARTS[part].map((k) => [k, pack.tables[k]]));
}
