// Pick 3 Cut 5 smoke test.
//
// This exists because of one bug, and it is worth naming: the app shipped with
// an Access bypass on /apps/pick3cut5/* and /api/pick3cut5/* and was broken for
// every unauthenticated player for hours. index.html loads /shared/styles.css
// and /shared/js/ui.js, neither of which was bypassed, so a friend with a room
// code got an unstyled page and `escHtml is not defined` froze the game at the
// first flip.
//
// Nothing caught it because the checks that were run - curl the routes, play it
// locally - could not catch it. The routes I ADDED returned 200. Local dev has
// no Access at all. A 200 on the page proves the route, not the page.
//
// So this file derives, from the source, the complete set of paths that must be
// publicly reachable, and asserts three things about it:
//
//   1. SETUP.md documents every one of them, so the dashboard runbook cannot
//      drift from what the app actually loads.
//   2. The API routes the client calls are exempted in _middleware.js, which is
//      the other half of the same bug - a bypass without the code exemption
//      takes a 403 from our own middleware instead.
//   3. With --remote, that production actually serves them WITHOUT credentials,
//      and - just as important - that the bypass did not get too wide.
//
// The derivation is the point. Add a script tag for /shared/js/api.js and this
// fails immediately, naming the file and the dashboard change it needs, instead
// of shipping and breaking for exactly the people the app is for.
//
// It scans the CSS as well as the HTML, and that is not decoration. Self-hosting
// the fonts (R7) added two /shared/fonts/*.woff2 requests that no tag in
// index.html mentions - a stylesheet asked for them with url(). An HTML scan
// cannot see a request a stylesheet makes, so the derived list sat at two while
// the real dependency count was three, and nothing failed. The check simply had
// nothing to say, through the one door it was written to watch.
//
// Run from anywhere:  node apps/pick3cut5/test/smoke.mjs
//              live:  node apps/pick3cut5/test/smoke.mjs --remote
//
// The harness is the character creator's, same as FilamentForge's.

import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { section, check, summary } from '../../character-creator/test/harness.mjs';
import { validateCategory } from '../../../workers/pick3cut5-room/src/generate.js';
import { soloLimitDecision, ipKey } from '../../../workers/pick3cut5-room/src/limits.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');

const html = readFileSync(join(appDir, 'index.html'), 'utf8');
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const middleware = readFileSync(join(repoRoot, 'functions', 'api', '_middleware.js'), 'utf8');
const setup = readFileSync(join(repoRoot, 'SETUP.md'), 'utf8');

const PRODUCTION = 'https://nates-workshop.pages.dev';
const APP_PATH = 'apps/pick3cut5';

// Cloudflare's limit, and all five are now in use: the app path, the api path,
// /shared/styles.css, /shared/js/ui.js and /shared/fonts. There is no slot left
// to absorb a surprise, so the sixth dependency needs a second Access
// application - which is a decision, and this is where it gets made rather than
// discovered by a player with a room code.
const MAX_ACCESS_DESTINATIONS = 5;

// ---------- 1. What the page loads ----------
section('What the page loads');

// Only <script src> and <link href> — things the BROWSER fetches on its own.
// An <a href="/"> is a navigation the player chooses, and the workshop home
// page is supposed to stay behind the login wall; counting it as a dependency
// would demand a bypass that must never exist.
const refs = [...html.matchAll(/<(?:script|link)\b[^>]*?(?:src|href)="([^"]+)"/g)].map((m) => m[1]);
const external = refs.filter((r) => /^https?:\/\//.test(r));
const absolute = refs.filter((r) => r.startsWith('/'));
const relative = refs.filter((r) => !r.startsWith('/') && !/^https?:\/\//.test(r) && r !== '#');

check('index.html references at least one absolute same-origin asset',
  absolute.length > 0, 'if this is 0 the regex stopped matching, not the risk');

// Relative paths resolve under the app directory, which the app's own Access
// destination already covers. Absolute ones do not - each needs its own.
check('every relative asset stays inside the app directory',
  relative.every((r) => !r.startsWith('..')),
  relative.filter((r) => r.startsWith('..')).join(', '));

// This page fetches NOTHING from a third party, and that is the assertion -
// not "external assets are fonts only", which allowed a font CDN and then went
// quiet when the fonts were self-hosted into shared/fonts/. An empty list
// satisfies .every() no matter what the predicate says, so that check passed
// without comparing anything from the day the CDN link came out. F11.
//
// A third-party request here is a request the Access wall never sees and the
// bypass list cannot cover: this is the one page outside the wall, so an
// unauthenticated player makes it. That is what a non-zero count means.
//
// HTML ONLY. A url() inside a stylesheet has no tag here and does not appear
// in `external` - see the CSS half below, and F12.
check('index.html fetches nothing from a third party',
  external.length === 0,
  external.length
    ? `${external.join(', ')} - an unauthenticated request from the one page outside Access`
    : '');

// ---------- 1b. What the CSS then loads ----------
//
// Follow the stylesheets the HTML scan already found. A url() inside one of
// them is a request the browser makes without any tag in index.html naming it,
// and that is the gap R7 walked through.
//
// Absolute targets only, for the same reason the HTML scan takes only absolute
// ones: a relative url() resolves beside its own stylesheet, under a directory
// that stylesheet's destination already covers.
const stylesheets = absolute.filter((r) => /\.css(\?|$)/.test(r));
const cssAssets = [];
let cssRead = 0;
for (const href of stylesheets) {
  const text = readFileSync(join(repoRoot, href.replace(/^\//, '').split('?')[0]), 'utf8');
  cssRead += 1;
  for (const m of text.matchAll(/url\(\s*['"]?(\/[^'")\s]+)['"]?\s*\)/g)) {
    cssAssets.push(m[1].split('?')[0]);
  }
}

// Not "did we find any assets" - a stylesheet is allowed to reference nothing.
// What must not silently become zero is the READING. If the filter above stops
// recognising a stylesheet, this half of the derivation goes quiet and looks
// exactly like a page that loads no fonts.
check('every absolute stylesheet the page loads was read for url() assets',
  cssRead === stylesheets.length && stylesheets.length > 0,
  `read ${cssRead} of ${stylesheets.length} - the CSS half of the derivation is blind`);

// THE DERIVED LIST. Not maintained by hand - this is what the page actually
// asks the browser to fetch from outside its own directory.
//
// A CSS asset is folded in by its DIRECTORY, not its own path. An Access
// destination is a path prefix and there are five of them; two font files
// would spend the last two slots on one typeface, and the next weight would
// have nowhere to go.
const assetDirs = cssAssets.map((p) => p.slice(0, p.lastIndexOf('/')));
const requiredPublic = [...new Set([...absolute, ...assetDirs])].sort();
console.log('  ->  needs its own Access destination: ' + requiredPublic.join(', '));

// The concrete files behind that list. The destinations are what the dashboard
// needs; these are what the browser actually asks for, and they are what gets
// fetched in section 5 - a directory has no page of its own to fetch.
const fetched = [...new Set([...absolute, ...cssAssets])].sort();
console.log('  ->  the browser fetches: ' + fetched.join(', '));

// ---------- 2. SETUP.md documents them ----------
section('SETUP.md documents every public path');

// Access policy is dashboard-only; there is no policy-as-code in this repo, so
// SETUP.md IS the runbook. Pinning it here is the only way a new dependency
// cannot silently outrun the instructions for making it reachable.
for (const path of requiredPublic) {
  const bare = path.replace(/^\//, '');
  check(`SETUP.md names ${bare} as an Access destination`,
    setup.includes(bare),
    'add it to the bypass list in SETUP.md, and to the Access application');
}

check(`the app's own path is documented too`,
  setup.includes(APP_PATH));

const destinations = requiredPublic.length + 1 + 1; // assets + app path + api path
check(`the app fits in ${MAX_ACCESS_DESTINATIONS} Access destinations`,
  destinations <= MAX_ACCESS_DESTINATIONS,
  `needs ${destinations}; a sixth requires a second Access application`);

// ---------- 3. The middleware exemption ----------
section('The middleware exemption matches the client');

// Scoped to the array literal, NOT the whole file. Matching '/api/...' anywhere
// in _middleware.js read the explanatory comment above the array as though it
// were the array: emptying the list entirely still "passed", because the
// comment still mentioned the path it no longer contained.
const arrayLiteral = middleware.match(/const PUBLIC_PATHS\s*=\s*\[([^\]]*)\]/);
check('_middleware.js declares a PUBLIC_PATHS array', Boolean(arrayLiteral));

const publicPaths = arrayLiteral
  ? [...arrayLiteral[1].matchAll(/'([^']+)'/g)].map((m) => m[1])
  : [];
check('_middleware.js declares at least one public path',
  publicPaths.length > 0, 'PUBLIC_PATHS is how a bypassed route avoids our own 403');

// EXACT paths, not prefixes, since 2026-09-02. A prefix let every unrouted path
// beneath it through, and Pages answers an unrouted path with the landing page
// at 200 — so `/api/pick3cut5/anything` served index.html to anyone, at a URL
// that 302s to the login wall on its own. Assert the shape, because reverting
// to a prefix would look like a harmless one-character edit.
check('and they are exact paths, not prefixes',
  publicPaths.every((p) => !p.endsWith('/')),
  `${publicPaths.filter((p) => p.endsWith('/')).join(', ')} — a trailing slash reads as a prefix`);
check('and the middleware matches them exactly',
  /PUBLIC_PATHS\.includes\(pathname\)/.test(middleware),
  'startsWith here reopens the landing-page hole');

// DERIVED, so the list cannot drift from the routes. One file under
// functions/api/pick3cut5/ is one route; anything there without an entry takes
// a hard 403 from us despite the dashboard bypass, and anything here without a
// file is a hole guarding nothing.
const routeFiles = readdirSync(join(repoRoot, 'functions', 'api', 'pick3cut5'))
  .filter((f) => f.endsWith('.js'))
  .map((f) => `/api/pick3cut5/${f.replace(/\.js$/, '')}`);
const unexempt = routeFiles.filter((r) => !publicPaths.includes(r));
check(`every pick3cut5 route is exempted (${routeFiles.length} found)`,
  unexempt.length === 0,
  `${unexempt.join(', ')} — add it to PUBLIC_PATHS or it 403s behind the bypass`);
const stale = publicPaths.filter((p) => !routeFiles.includes(p));
check('and no exemption names a route that does not exist',
  stale.length === 0, `${stale.join(', ')} — a hole guarding nothing`);

const apiConst = appSrc.match(/const API = '([^']+)'/);
check('app.js declares its API base as a constant', Boolean(apiConst));

if (apiConst) {
  const base = apiConst[1];
  check(`the client's API base (${base}) has exempted routes beneath it`,
    publicPaths.some((p) => p.startsWith(`${base}/`)),
    `PUBLIC_PATHS has ${publicPaths.join(', ')}`);
}

// Any OTHER absolute /api/ string in the client would be a route the exemption
// does not cover, which is the same bug wearing a different hat. Template
// literals build `${API}/room`, so compare the resolved paths.
const strayApi = [...appSrc.matchAll(/['"`](\/api\/[^'"`$]*)/g)]
  .map((m) => m[1])
  .filter((p) => !publicPaths.includes(p) && !publicPaths.some((e) => e.startsWith(`${p}/`)));
check('the client calls no /api/ path outside the exempted set',
  strayApi.length === 0, strayApi.join(', '));

// ---------- 4. Hidden information ----------
section('Hidden information');

// Cheap structural guards on the rule the whole game rests on. The real proof
// is a live round, but these catch the careless version.
const room = readFileSync(join(repoRoot, 'workers', 'pick3cut5-room', 'src', 'room.js'), 'utf8');

// Anchored on the DEFINITION and the next method, not on the first mention of
// either name. The first cut sliced from a call site to an earlier call site
// and produced an empty string, which made all three "never sends" checks pass
// against nothing — a test that cannot fail is worse than no test, so the
// bounds are asserted before anything is read from them.
const snapStart = room.indexOf('snapshotFor(playerId) {');
const snapEnd = room.indexOf('\n  sendError(', snapStart);
check('the snapshot function can be located in room.js',
  snapStart !== -1 && snapEnd > snapStart,
  'snapshotFor/sendError moved — fix these anchors, do not delete the checks');
const snapshot = snapStart !== -1 && snapEnd > snapStart ? room.slice(snapStart, snapEnd) : '';

check('the snapshot never sends the whole item list',
  !/\bitems:\s*g\.items\b/.test(snapshot),
  'snapshotFor must send items[itemIndex], never g.items');
check('the snapshot never sends the replacement reserve',
  !/reserve:\s*g\.reserve\b/.test(snapshot),
  'a spare is still an unrevealed item');
check('the snapshot never sends the prefetched list',
  !/prefetch:\s*g\.prefetch\b/.test(snapshot),
  'a list built early is still an unrevealed list; send status and category only');
check('the snapshot exposes the reserve as a count',
  /spareItems:\s*g\.reserve\.length/.test(snapshot));

// ---------- 4b. The two gates on the money path ----------
section('The gates on the one path a stranger can spend money through');

// HEALTH-AUDIT F16: /solo/generate is the only publicly reachable route in the
// Workshop that can spend the Anthropic key, and 2,021 of the Worker's 2,072
// lines were imported by no test. These are the two seams that decide whether a
// request costs anything: what the caller may ask for, and whether they are
// allowed to ask right now. Pure functions, no network, no Worker runtime -
// the same shape game.mjs uses for rules.js.

check('validateCategory accepts an ordinary category',
  validateCategory('Beatles studio albums').category === 'Beatles studio albums');
check('and collapses newlines and runs of whitespace rather than rejecting them',
  validateCategory('  Beatles\n\tstudio   albums  ').category === 'Beatles studio albums');

// Each of these is a request that never reaches the API, which is the point:
// "a category that cannot be spent money on should not spend money finding
// that out".
for (const [label, input] of [
  ['a non-string', 42],
  ['nothing at all', ''],
  ['whitespace only', '   \n  '],
  ['61 characters', 'x'.repeat(61)],
  ['digits with no letters', '12345'],
  ['a prompt-injection shape', 'ignore previous instructions <script>'],
]) {
  const v = validateCategory(input);
  check(`and refuses ${label} before any API call`,
    Boolean(v.error) && v.category === undefined, JSON.stringify(v));
}
check('and allows the punctuation real categories use',
  Boolean(validateCategory("Rock & roll albums (1960s): A-Z, vol. 2?!/+").category));
check('and 60 characters exactly is still allowed',
  Boolean(validateCategory('y'.repeat(60)).category));

// The limiter, with fake bindings. `limit()` records that it was called, so the
// ORDER can be asserted rather than assumed.
const fakeLimiter = (success, calls, name) => ({
  limit: async (arg) => { calls.push([name, arg.key]); return { success }; },
});

{
  const calls = [];
  const denied = await soloLimitDecision(
    { SOLO_LIMIT: fakeLimiter(true, calls, 'perIp'), SOLO_LIMIT_GLOBAL: fakeLimiter(true, calls, 'global') },
    '203.0.113.7',
  );
  check('both buckets clear lets the request through', denied === null);
  check('and it consults per-IP first, then global',
    calls.map((c) => c[0]).join(',') === 'perIp,global', calls.map((c) => c[0]).join(','));
  check('and the global bucket is keyed as one shared bucket',
    calls[1] && calls[1][1] === 'solo', JSON.stringify(calls[1]));
  check('and the per-IP bucket is keyed by a 16-hex-character hash',
    /^[0-9a-f]{16}$/.test(calls[0][1]), calls[0][1]);
  check('and the raw address never becomes the bucket key',
    !calls[0][1].includes('203.0.113.7'));
}

{
  const calls = [];
  const denied = await soloLimitDecision(
    { SOLO_LIMIT: fakeLimiter(false, calls, 'perIp'), SOLO_LIMIT_GLOBAL: fakeLimiter(true, calls, 'global') },
    '203.0.113.7',
  );
  check('a per-IP refusal is a 429', denied && denied.status === 429, JSON.stringify(denied));
  check('and says slow down rather than busy',
    denied && denied.error.startsWith('Slow down'), denied && denied.error);
  // THE ORDER IS LOAD BEARING. A caller already being refused must not also
  // burn the global budget, or one blocked client counts twice.
  check('and does NOT consult the global bucket',
    calls.map((c) => c[0]).join(',') === 'perIp', calls.map((c) => c[0]).join(','));
}

{
  const calls = [];
  const denied = await soloLimitDecision(
    { SOLO_LIMIT: fakeLimiter(true, calls, 'perIp'), SOLO_LIMIT_GLOBAL: fakeLimiter(false, calls, 'global') },
    '203.0.113.7',
  );
  check('a global refusal is a 429 too', denied && denied.status === 429, JSON.stringify(denied));
  check('and says busy rather than slow down',
    denied && denied.error.startsWith('Solo mode is busy'), denied && denied.error);
}

check('the same address always keys the same bucket',
  (await ipKey('198.51.100.4')) === (await ipKey('198.51.100.4')));
check('and two addresses do not share one',
  (await ipKey('198.51.100.4')) !== (await ipKey('198.51.100.5')));

// The Worker's entry point must actually USE the extracted decision. Extracting
// a guardrail and leaving the caller on its own copy is the failure this whole
// finding is about, one level up.
const workerIndex = readFileSync(join(repoRoot, 'workers', 'pick3cut5-room', 'src', 'index.js'), 'utf8');
check('and index.js routes /solo/generate through it',
  /soloLimitDecision\(env, ip\)/.test(workerIndex),
  'the extracted decision is not what the Worker runs');
check('and keeps no second copy of the limiter calls',
  !/env\.SOLO_LIMIT(_GLOBAL)?\.limit\(/.test(workerIndex),
  'index.js still calls a limiter binding directly - two copies to keep in step');

// ---------- 5. Live, unauthenticated ----------
if (process.argv.includes('--remote')) {
  section('Production, with no Access session');

  const get = async (path) => {
    try {
      const res = await fetch(PRODUCTION + path, { redirect: 'manual' });
      return { code: res.status, type: res.headers.get('content-type') || '' };
    } catch (err) {
      return { code: 'ERR ' + err.message, type: '' };
    }
  };
  const status = async (path) => (await get(path)).code;

  // The FILES, not the destinations. /shared/fonts is a directory: asking for
  // it proves nothing, because Pages answers a path it does not have with the
  // workshop landing page, at 200, and a 200 is what this loop is looking for.
  for (const path of fetched) {
    const { code, type } = await get(path);
    check(`${path} is reachable without logging in`, code === 200,
      'add its directory to the Pick 3 Cut 5 (public) Access application');
    // Same trap from the other side. A font that was renamed or never deployed
    // still answers 200 with the landing page's HTML, and the player still gets
    // Times New Roman. Nothing here is an HTML document.
    check(`${path} is served as an asset, not the landing page`,
      code === 200 && !/^text\/html/.test(type),
      `content-type ${type || '(none)'} - a 200 on a path Pages does not have`);
  }

  check(`/${APP_PATH}/ is reachable without logging in`,
    (await status(`/${APP_PATH}/`)) === 200,
    'add it to the Pick 3 Cut 5 (public) Access application');

  // The other direction, and the one nobody thinks to check: the bypass must
  // not have taken the rest of the site with it.
  //
  // Anything the app genuinely needs is filtered out first. Without that, a
  // newly added dependency gets reported twice in opposite directions - "must
  // be reachable" and "must be gated" - and the contradiction reads as a
  // broken test rather than a missing Access destination.
  //
  // Matched as a PREFIX now that the list can hold directories. An equality
  // test would call /shared/fonts/saira-variable.woff2 a path that ought to be
  // gated while the loop above insists it must be public.
  const gated = ['/', '/shared/js/api.js', '/apps/character-creator/']
    .filter((p) => !requiredPublic.some((r) => p === r || p.startsWith(r + '/')));
  for (const path of gated) {
    const code = await status(path);
    check(`${path} is still behind the login wall`, code !== 200,
      `got ${code} — the bypass is too wide`);
  }
} else {
  section('Production, with no Access session');
  console.log('  --  skipped (pass --remote to check the live Access bypass)');
}

process.exit(summary() === 0 ? 0 : 1);
