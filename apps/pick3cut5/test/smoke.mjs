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
// Run from anywhere:  node apps/pick3cut5/test/smoke.mjs
//              live:  node apps/pick3cut5/test/smoke.mjs --remote
//
// The harness is the character creator's, same as FilamentForge's.

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { section, check, summary } from '../../character-creator/test/harness.mjs';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');

const html = readFileSync(join(appDir, 'index.html'), 'utf8');
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const middleware = readFileSync(join(repoRoot, 'functions', 'api', '_middleware.js'), 'utf8');
const setup = readFileSync(join(repoRoot, 'SETUP.md'), 'utf8');

const PRODUCTION = 'https://nates-workshop.pages.dev';
const APP_PATH = 'apps/pick3cut5';

// Cloudflare's limit. Four are in use; a fifth dependency is the last one that
// fits, and the sixth needs a second application rather than a surprise.
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

check('external assets are fonts only',
  external.every((r) => r.startsWith('https://fonts.googleapis.com/')),
  external.filter((r) => !r.startsWith('https://fonts.googleapis.com/')).join(', '));

// THE DERIVED LIST. Not maintained by hand - this is what the page actually
// asks the browser to fetch from outside its own directory.
const requiredPublic = [...new Set(absolute)].sort();
console.log('  ->  needs its own Access destination: ' + requiredPublic.join(', '));

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
// were the array: emptying PUBLIC_PREFIXES entirely still "passed", because the
// comment still mentioned the prefix it no longer contained.
const arrayLiteral = middleware.match(/const PUBLIC_PREFIXES\s*=\s*\[([^\]]*)\]/);
check('_middleware.js declares a PUBLIC_PREFIXES array', Boolean(arrayLiteral));

const prefixes = arrayLiteral
  ? [...arrayLiteral[1].matchAll(/'([^']+)'/g)].map((m) => m[1])
  : [];
check('_middleware.js declares at least one public prefix',
  prefixes.length > 0, 'PUBLIC_PREFIXES is how a bypassed route avoids our own 403');

const apiConst = appSrc.match(/const API = '([^']+)'/);
check('app.js declares its API base as a constant', Boolean(apiConst));

if (apiConst) {
  const base = apiConst[1];
  check(`the client's API base (${base}) is exempted in _middleware.js`,
    prefixes.some((p) => (base + '/').startsWith(p)),
    `PUBLIC_PREFIXES has ${prefixes.join(', ')} — a bypassed route without this takes a 403 from us`);
}

// Any OTHER absolute /api/ string in the client would be a route the exemption
// does not cover, which is the same bug wearing a different hat.
const strayApi = [...appSrc.matchAll(/['"`](\/api\/[^'"`$]*)/g)]
  .map((m) => m[1])
  .filter((p) => !prefixes.some((pre) => (p + '/').startsWith(pre)));
check('the client calls no /api/ path outside the exempted prefix',
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

// ---------- 5. Live, unauthenticated ----------
if (process.argv.includes('--remote')) {
  section('Production, with no Access session');

  const status = async (path) => {
    try {
      const res = await fetch(PRODUCTION + path, { redirect: 'manual' });
      return res.status;
    } catch (err) {
      return 'ERR ' + err.message;
    }
  };

  for (const path of [...requiredPublic, `/${APP_PATH}/`]) {
    check(`${path} is reachable without logging in`,
      (await status(path)) === 200,
      'add it to the Pick 3 Cut 5 (public) Access application');
  }

  // The other direction, and the one nobody thinks to check: the bypass must
  // not have taken the rest of the site with it.
  //
  // Anything the app genuinely needs is filtered out first. Without that, a
  // newly added dependency gets reported twice in opposite directions - "must
  // be reachable" and "must be gated" - and the contradiction reads as a
  // broken test rather than a missing Access destination.
  const gated = ['/', '/shared/js/api.js', '/apps/character-creator/']
    .filter((p) => !requiredPublic.includes(p));
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
