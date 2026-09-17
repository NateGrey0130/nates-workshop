// End-to-end regression: real HTTP against real endpoints, against a D1 built
// from nothing.
//
// smoke.mjs proves the machinery is correct — the parser, the dice, the
// composition rules, the schema. It has never proved that a REQUEST works. Both
// bugs that reached production this week lived in that gap: a fresh database
// missing two columns, and a wizard step whose result rendered off-screen. The
// first would have been caught here on the first run.
//
//   node apps/character-creator/test/regression.mjs
//
// Isolated on purpose. It builds its own D1 under a scratch --persist-to
// directory and deletes it afterwards, so it never sees your dev data and a
// failed run cannot leave debris in it. Nothing here talks to production.
//
// Slow relative to smoke.mjs — it boots wrangler and waits for a port — so it
// is a separate command rather than another section of the smoke test.

import { spawn, spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, rmSync, mkdtempSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { tmpdir } from 'node:os';
import { validateBonuses, occAllowedForRace, raceAllowedForOcc, OCC_GROUPS, RACE_NONE,
  parseClassMarkdown, combineClasses, isChoiceGroup } from '../js/parser.js';
import { composeClass } from '../js/compose.js';
import { referencedGear } from '../../../functions/api/character-creator/_lib/catalog.js';
import { comparePair } from '../../../scripts/same-spell-lib.mjs';
import { choosePort, refuseIfTaken, runMarker, waitForOwnServer } from './dev-server.mjs';

const testDir = dirname(fileURLToPath(import.meta.url));
const appDir = join(testDir, '..');
const repoRoot = join(appDir, '..', '..');
// NOT 8799 ANY MORE. A fixed port let a stale workerd from another worktree's
// run answer for this one, and the suite reported that tree's counts as a
// regression in this one (2026-09-16). The OS picks a free port per run;
// REGRESSION_PORT pins one, and is refused with its owner named if it is taken.
// See dev-server.mjs.
const PORT = await choosePort('REGRESSION_PORT');
const BASE = `http://127.0.0.1:${PORT}/api/character-creator`;
const marker = runMarker();

let failures = 0;
let checks = 0;
function check(label, cond, detail = '') {
  checks++;
  if (cond) {
    console.log('  ok  ' + label);
  } else {
    failures++;
    const why = detail && typeof detail === 'object' ? JSON.stringify(detail) : String(detail ?? '');
    console.log('  FAIL ' + label + (why ? ' — ' + why.slice(0, 260) : ''));
  }
}

// ── the scratch database ────────────────────────────────────────────────────
const state = mkdtempSync(join(tmpdir(), 'cc-regression-'));
let server = null;

function cleanup() {
  if (server && !server.killed) {
    try { process.platform === 'win32' ? spawnSync('taskkill', ['/pid', server.pid, '/T', '/F']) : server.kill('SIGTERM'); }
    catch { /* already gone */ }
  }
  // RETRIES, because on Windows the workerd CHILD still holds handles under
  // this directory for a moment after taskkill returns; rmSync fails EBUSY and
  // the bare catch below turned that into a scratch database left in TEMP on
  // every run. This file has promised "deleted afterwards" since it was
  // written and was not doing it: SIXTEEN cc-regression-* directories, each a
  // whole built database, were sitting in TEMP when it was measured.
  try { rmSync(state, { recursive: true, force: true, maxRetries: 20, retryDelay: 150 }); }
  catch { /* genuinely best effort now, rather than by default */ }
}
process.on('exit', cleanup);
process.on('SIGINT', () => { cleanup(); process.exit(130); });

// 180000 UNTIL 2026-09-14, WHEN THE BOOTSTRAP OUTGREW IT. Step [1/7] builds a
// database from db/schema.sql, db/seed-catalogs.sql and every data script -
// 682 files, 9.97 MB of SQL in one --file - and that call was measured at
// 183.2s on the development machine, three seconds past the limit. It failed
// twice in a row with "cannot build a database" while the SQL was fine.
//
// THE COMMENT BELOW USED TO SAY THIS LIMIT SHOULD NOT MOVE, citing SHIP-PR-AUDIT
// F13. That reason no longer reaches this file. F13 was about a budget spent on
// something other than the work: `npx wrangler` DOWNLOADING inside the timed
// region on a cold runner cache, which is why it recommended warming the cache
// rather than raising the number - so the timeout kept meaning what it said.
// regression.yml now does exactly that ("warm the npx cache", before the timed
// step), so the cause F13 named is already treated here, and what is left is
// 183 seconds of genuine work against a 180-second ceiling. Raising it now is
// the honest reading of the limit, not a way around a real failure.
//
// SIX MINUTES, not three-and-a-bit: the bootstrap grows with every import and a
// ceiling set just above today's measurement would be crossed again by the next
// book. It stays far inside regression.yml's own `timeout-minutes: 20`, and the
// ETIMEDOUT branch below still reports a genuine hang as a timeout rather than a
// SQL fault. CI is not the constraint either way - the runner builds this in a
// fraction of the Windows time.
const WRANGLER_TIMEOUT_MS = 360000;

function wrangler(args) {
  // maxBuffer: the gear-citation sweep at the end pulls every published class's
  // whole markdown back as JSON, which overruns spawnSync's 1 MB default - the
  // output is then truncated mid-JSON and the parse fails with no hint that
  // SIZE was the problem. This setting moved here with that sweep.
  const started = Date.now();
  const r = spawnSync('npx', ['wrangler', ...args], {
    cwd: repoRoot, shell: true, encoding: 'utf8', timeout: WRANGLER_TIMEOUT_MS, maxBuffer: 1e9,
  });
  // A TIMEOUT USED TO READ EXACTLY LIKE A SQL FAULT. spawnSync reports it as
  // error.code ETIMEDOUT with status null, and nothing here read `error`: every
  // call site shows stderr, which by then holds only npm's two "npm notice run"
  // lines. Step [1/7] printed "cannot build a database" with those as its only
  // reason while the bootstrap was fine and merely slow (BOOK-INGEST-AUDIT F58).
  //
  // So say it, in stderr, where all seven call sites already look - the raw tail
  // at step [1/7] and cleanErr() everywhere else, which keeps lines containing
  // "error". FIRST, not last: check() shows only the first 260 characters of a
  // detail, and appending put the line after npm's notices and the bootstrap
  // path, where it was cut off - measured by injecting a 3 s limit. It says
  // "timed out", not "killed": with shell: true the timeout stops the shell, and
  // on Windows wrangler itself keeps running.
  //
  // This message changes no check and no exit code; it only names the cause.
  // THE LIMIT ITSELF DID MOVE, on 2026-09-14, and the reason this paragraph used
  // to give against that - SHIP-PR-AUDIT F13 - is answered where the constant is
  // declared above. Reporting a timeout clearly and setting it correctly are
  // still two separate things, and this half is the first one.
  if (r.error && r.error.code === 'ETIMEDOUT') {
    const secs = Math.round((Date.now() - started) / 1000);
    r.stderr = `error: wrangler timed out after ${secs}s (limit ${WRANGLER_TIMEOUT_MS / 1000}s) - `
      + 'this is a timeout, not a SQL error. On Windows the shell is stopped and wrangler may still be running.\n'
      + (r.stderr || '');
  }
  return r;
}

// wrangler paints its errors with ANSI colour and wraps them in a box; a check
// detail wants the sentence, not the artwork.
function cleanErr(text) {
  const raw = String(text || '');
  const lines = raw.replace(/\u001b\[[0-9;]*m/g, '').split('\n')
    .map((l) => l.replace(/[^\x20-\x7e]/g, '').trim())
    .filter((l) => /error/i.test(l) && l.length > 8);
  return (lines.join(' | ') || raw.trim()).slice(0, 300) || 'no output';
}

// Before the build as well as before the spawn, so a pinned port that is taken
// refuses in a second rather than after minutes of building a database.
async function portGate() {
  try {
    await refuseIfTaken(PORT);
  } catch (e) {
    check('port ' + PORT + ' is free before the app is spawned', false);
    console.log('  ' + e.message);
    console.log('\nREGRESSION FAILED (port ' + PORT + ' is already in use)');
    process.exit(1);
  }
}
await portGate();

console.log('[1/7] Building a database from nothing');

// One concatenated file rather than 60 wrangler invocations: each costs seconds,
// and the point is to prove the SQL composes, not to time the CLI.
const parts = [
  readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
  readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
];
const dataDir = join(appDir, 'db');
for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
  const sql = readFileSync(join(dataDir, f), 'utf8');
  if (/^--\s*local-only\b/m.test(sql)) continue;      // seed-dev: unguarded inserts
  parts.push(sql);
}
parts.push(marker.sql);          // proves at boot that the server reads THIS database
const bootstrap = join(state, 'bootstrap.sql');
writeFileSync(bootstrap, parts.join('\n;\n'), 'utf8');

const applied = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', bootstrap]);
check('schema + catalogs + data scripts apply to an empty database',
  applied.status === 0, (applied.stderr || applied.stdout || '').slice(-400));
if (applied.status !== 0) { console.log('\nREGRESSION FAILED (cannot build a database)'); process.exit(1); }

// AND THE DATABASE IT JUST BUILT KNOWS WHICH MIGRATIONS IT HAS.
//
// db/schema.sql already contains every column the migrations add, so a fresh
// database does not RUN them - it RECORDS them, each row guarded by the schema
// feature its migration adds. A guard placed before its own CREATE therefore
// never fires, and the database comes up understating what it has: run those
// migrations against it later and they fail with `table already exists`. That
// is the opposite lie from an unguarded row, and it is silent in every
// direction.
//
// THIS IS NOT NEW MACHINERY. IT IS AN EXISTING CHECK POINTED SOMEWHERE ELSE.
// `test/checks/environment.mjs` already asserts `every migration on disk is
// recorded as applied` - against the DEVELOPER's local D1, which accumulates,
// so it stays quiet on a machine whose database was migrated by hand over
// time. This file is the only place a database built the DOCUMENTED way
// exists, and that is the database the defect lives in. The build above has
// already happened, so the question costs one query and no second build.
//
// BOOK-INGEST-AUDIT F99, which found 057-super-abilities.sql and
// 061-skill-system-bases.sql both guarded from the seeding block while their
// CREATEs sit ~200 lines below it: a one-pass build recorded 62 of 64.
// Production was never affected - it RAN the migrations - which is exactly why
// nothing noticed for as long as nothing looked.
{
  const migFile = join(state, 'migrations-recorded.sql');
  writeFileSync(migFile, 'SELECT filename FROM schema_migrations ORDER BY filename;', 'utf8');
  const mig = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json', '--file', migFile]);
  let recorded = null;
  try { recorded = JSON.parse(mig.stdout)[0].results.map((x) => x.filename); } catch { /* checked below */ }
  check('the built database can say which migrations it has', Array.isArray(recorded),
    (mig.stdout || mig.stderr || '').slice(-300));
  if (Array.isArray(recorded)) {
    const onDisk = readdirSync(join(repoRoot, 'db', 'migrations'))
      .filter((f) => f.endsWith('.sql')).sort();
    const missing = onDisk.filter((f) => !recorded.includes(f));
    check('and every migration is recorded on a database built from nothing',
      missing.length === 0,
      'not recorded: ' + missing.join(', ')
      + ' - each of these has its seed line BEFORE the CREATE it is guarded on, so the'
      + ' guard never fires; move it to sit after that CREATE, the way 063 and 064 do');
    // The other direction: a row with no file means a migration was renamed or
    // deleted after being seeded here, which breaks their immutability.
    const orphans = recorded.filter((f) => !onDisk.includes(f));
    check('and nothing is recorded that has no file', orphans.length === 0,
      'recorded with no file: ' + orphans.join(', '));
  }
}

// ── boot the worker ─────────────────────────────────────────────────────────
console.log('\n[2/7] Booting the app');
await portGate();              // again: the build above takes minutes
server = spawn('npx', ['wrangler', 'pages', 'dev', '--port', String(PORT),
  '--persist-to', state, '--show-interactive-dev-session', 'false',
  '--binding', 'ADMIN_EMAIL=dev@localhost'],
  { cwd: repoRoot, shell: true, stdio: 'ignore' });

// Answering 200 on /me is not enough - ANY server does that, including another
// run's. The marker draft exists only in the database built above.
const boot = await waitForOwnServer({ base: BASE, child: server, marker, port: PORT });
check('the worker answers on port ' + PORT + ' and serves the database this run built', boot.ok);
if (!boot.ok) {
  console.log('  ' + boot.why);
  console.log('\nREGRESSION FAILED (worker never came up as this run\'s own)');
  process.exit(1);
}

// ── helpers ─────────────────────────────────────────────────────────────────
async function api(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  let payload = null;
  const text = await res.text();
  try { payload = JSON.parse(text); } catch { payload = { raw: text.slice(0, 200) }; }
  return { status: res.status, body: payload };
}

// The same request as somebody else. Local dev has no Access in front of it,
// so the identity header is ours to state — the technique the README already
// documents for testing owner/GM rules by hand. Without it every request is
// dev@localhost, who is the GM of everything this file creates, and a
// permission check exercised only as the GM proves nothing.
async function apiAs(who, method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: {
      ...(body ? { 'Content-Type': 'application/json' } : {}),
      'Cf-Access-Authenticated-User-Email': who,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let payload = null;
  const text = await res.text();
  try { payload = JSON.parse(text); } catch { payload = { raw: text.slice(0, 200) }; }
  return { status: res.status, body: payload };
}

// ── the boot calls ──────────────────────────────────────────────────────────
console.log('\n[3/7] What the wizard loads on start');
const me = await api('GET', '/me');
check('/me identifies the caller', me.status === 200 && !!me.body.email, me.body);

const classes = await api('GET', '/classes');
check('/classes returns published classes', classes.status === 200 && classes.body.classes.length > 0, classes.body);
check('and none of them failed to parse',
  !(classes.body.failures || []).length, JSON.stringify(classes.body.failures || []).slice(0, 200));

// The heaviest response in the app, and between imports it never changes — so
// it carries a validator, and a warm load is an empty 304 rather than ~750KB
// of markdown again. Node's fetch has no HTTP cache, which is exactly what
// makes the round-trip testable: the conditional request is ours to send.
{
  const first = await fetch(`${BASE}/classes`);
  const tag = first.headers.get('ETag');
  check('/classes sends a validator', !!tag, 'no ETag header');
  check('and says to revalidate, never to serve stale',
    /no-cache/.test(first.headers.get('Cache-Control') || ''), first.headers.get('Cache-Control'));
  const again = await fetch(`${BASE}/classes`, { headers: { 'If-None-Match': tag || '' } });
  check('a warm load revalidates to a 304', again.status === 304, again.status);
  check('with no body to re-download', (await again.text()).length === 0);

  // The label projection: id and name straight off the table, no parsing. Its
  // one job is turning a class_id into a display name, so it must cover every
  // class the full list serves.
  const names = await api('GET', '/classes?names=1');
  const fullIds = new Set(classes.body.classes.map((c) => c.id));
  check('the names projection answers for every published class',
    names.status === 200 && [...fullIds].every((id) => names.body.classes.some((c) => c.id === id))
    && names.body.classes.every((c) => c.id && c.name),
    JSON.stringify((names.body.classes || []).slice(0, 3)));
  const namesSize = JSON.stringify(names.body).length;
  const fullSize = JSON.stringify(classes.body).length;
  check('and is a small fraction of the full response — its whole point',
    namesSize * 10 < fullSize, `${namesSize} bytes vs ${fullSize}`);
}

// This is the call a fresh database used to 500 on: it selects ppe_note and
// isp_note, the two columns that never made it into schema.sql.
const catalogs = await api('GET', '/catalogs');
check('/catalogs answers on a database built only from schema.sql',
  catalogs.status === 200, catalogs.body);
check('and carries skills, spells and psionics',
  catalogs.status === 200 && catalogs.body.skills?.length > 0
  && catalogs.body.spells?.length > 0 && catalogs.body.psionics?.length > 0,
  Object.keys(catalogs.body || {}));
// The wizard's totem pick reads these (BOOK-INGEST-AUDIT F56), and a totem
// whose skills or bonuses failed to decode would grant nothing silently.
check('and the forty totems, their JSON decoded',
  catalogs.body.totems?.length === 40
  && catalogs.body.totems.every((t) => Array.isArray(t.skills) && t.skills.length > 0),
  `${catalogs.body.totems?.length} totems`);

// The wizard boots on this and the sheet fetches it again on every load, so it
// carries a validator the way /classes does. Its validator is a hash of the
// body rather than count-and-max-updated_at, because no catalog table has a
// timestamp column — so the check that earns its place is not "an ETag exists"
// but "an edit in place changes it", which is what a count-based validator
// would get wrong. Node's fetch has no HTTP cache, so the conditional request
// is ours to send.
{
  const first = await fetch(`${BASE}/catalogs`);
  const tag = first.headers.get('ETag');
  check('/catalogs sends a validator', !!tag, 'no ETag header');
  check('and says to revalidate, never to serve stale',
    /no-cache/.test(first.headers.get('Cache-Control') || ''), first.headers.get('Cache-Control'));
  const again = await fetch(`${BASE}/catalogs`, { headers: { 'If-None-Match': tag || '' } });
  check('a warm load revalidates to a 304', again.status === 304, again.status);
  check('with no body to re-download', (await again.text()).length === 0);

  // Vessels became an editable catalog by declaring one config entry - no new
  // endpoint, no new UI - which is the property `catalog-fields.js` exists to
  // have. 127 rows that nothing could edit before.
  //
  // AND THE DUPLICATE DETECTOR STAYS OUT OF IT, which is the half worth
  // pinning. `resolveCatalog` requires both the config entry AND a `MERGE_REFS`
  // entry, so declaring a catalog does not enlist it in duplicate review;
  // `enchantments` has been in that position since it landed. Get this wrong
  // and 127 vessels arrive in a review queue nobody asked for. The route must
  // decline by NAME - a 400 - rather than 500 on a missing ref.
  {
    const vessels = await api('GET', '/catalogs/rows?catalog=vehicles');
    check('the editor can list vessels', vessels.status === 200
      && Array.isArray(vessels.body.rows), vessels.status);
    const dupes = await api('GET', '/catalogs/duplicates?counts_only=1&catalog=vehicles');
    check('and duplicate review declines vessels cleanly rather than crashing',
      dupes.status === 400, dupes.status);
    // The precedent, asserted rather than described: enchantments is in exactly
    // the same position, so this is a shape the codebase already has and not a
    // special case built for vessels.
    const ench = await api('GET', '/catalogs/duplicates?counts_only=1&catalog=enchantments');
    check('the same way it already declines enchantments', ench.status === 400, ench.status);

    // `gear.vehicle_slug` - migration 053, BOOK-INGEST-AUDIT F41. A gear row
    // that is really a vessel points at it and STAYS, because class markdown
    // cites gear by slug and catalog_redirects cannot forward a key out of its
    // own catalog.
    //
    // The whole path is exercised rather than the column: set it through the
    // editor, read it back through the codex, and require the vessel's NAME to
    // resolve. A slug alone renders as something that looks like a name and is
    // not.
    const someVessel = (vessels.body.rows || [])[0];
    const gearRows = await api('GET', '/catalogs/rows?catalog=gear');
    const someGear = (gearRows.body.rows || [])[0];
    if (someVessel && someGear) {
      const point = await api('PATCH', `/catalogs/rows?catalog=gear&id=${someGear.id}`,
        { vehicle_slug: someVessel.slug });
      check('a gear row can be pointed at a vessel', point.status === 200, point.body);

      const gearSection = await api('GET', '/codex?section=gear');
      const pointed = (gearSection.body.gear || []).find((g) => g.slug === someGear.slug);
      check('and the codex resolves the pointer to the vessel NAME, not its slug',
        pointed?.vessel_name === someVessel.name,
        `vehicle_slug=${pointed?.vehicle_slug} vessel_name=${pointed?.vessel_name}`);
      // The row is not moved, hidden or re-categorised - the citation target has
      // to keep existing, or the class equipment lists it answers for break.
      check('while the gear row itself stays exactly where it was',
        !!pointed && pointed.name === someGear.name,
        'the pointed row left the gear catalog');

      // NULL is the normal state, and there is no foreign key: a pointer naming
      // a vessel no book session has imported yet must be INERT, not an error.
      // The 24 rows this exists for span five books.
      const dangling = await api('PATCH', `/catalogs/rows?catalog=gear&id=${someGear.id}`,
        { vehicle_slug: 'a-vessel-no-book-has-imported' });
      check('a pointer to a vessel that does not exist is accepted',
        dangling.status === 200, dangling.body);
      const after = await api('GET', '/codex?section=gear');
      const orphan = (after.body.gear || []).find((g) => g.slug === someGear.slug);
      check('and comes back with no vessel name rather than failing the section',
        after.status === 200 && orphan?.vessel_name == null, orphan?.vessel_name);

      await api('PATCH', `/catalogs/rows?catalog=gear&id=${someGear.id}`, { vehicle_slug: null });
    }
  }

  // The Morphus tables (migration 068) arrive the way vessels did: one config
  // entry, no endpoint. What smoke cannot see is the WRITE PATH against a real
  // D1 - that the stored key's CHECK refuses a drifted key as a 422 rather than
  // a 500, that a JSON list is validated on the way in, and that duplicate
  // review stays out, as it does for vessels. The fixture row is deleted again.
  {
    const entry = {
      key: 'Canine: Regression Probe', table_name: 'Canine', name: 'Regression Probe',
      roll_low: 21, roll_high: 45, kind: 'effect', source_book: 'fixture',
      bonuses: '{"attributes":{"PS":"1d6"},"pools":{"sdc":"1d4x10"}}',
      routes: '[{"table":"Bear","count":1}]', sub_choices: '["Wolf","Fox"]', horror_factor: '1d4+1',
    };
    const made = await api('POST', '/catalogs/rows?catalog=morphus', entry);
    check('an admin can create a Morphus table entry', made.status === 201, made.body);
    const listed = await api('GET', '/catalogs/rows?catalog=morphus');
    const back = (listed.body.rows || []).find((r) => r.key === entry.key);
    check('and it reads back with its JSON intact',
      back?.routes === entry.routes && back?.sub_choices === entry.sub_choices
      && back?.bonuses === entry.bonuses && back?.horror_factor === '1d4+1'
      && back?.source === 'manual', back);

    const drifted = await api('PATCH', `/catalogs/rows?catalog=morphus&id=${made.body.id}`,
      { name: 'Renamed Without Its Key' });
    check('a rename that leaves the key behind is refused as a 422, not a 500',
      drifted.status === 422 && /CHECK/.test(drifted.body.error || ''), drifted);
    const badRoute = await api('POST', '/catalogs/rows?catalog=morphus',
      { ...entry, key: 'Canine: Probe Two', name: 'Probe Two', routes: '[{"table":"Bear","count":0}]' });
    check('and a route with no count is refused before it reaches the database',
      badRoute.status === 422 && /Routes/.test(badRoute.body.error || ''), badRoute);
    const dupes = await api('GET', '/catalogs/duplicates?counts_only=1&catalog=morphus');
    check('duplicate review declines the Morphus tables cleanly, as it does vessels',
      dupes.status === 400, dupes.status);

    const removed = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--command',
      `"DELETE FROM morphus_characteristics WHERE source_book = 'fixture'"`]);
    check('the Morphus fixture row is removed again', removed.status === 0, cleanErr(removed.stderr || ''));
  }

  // Change a percentage in place: no row added, no id moved, nothing a count
  // or a max(id) could see. The validator has to move anyway.
  const rows = await api('GET', '/catalogs/rows?catalog=skills');
  const row = (rows.body.rows || []).find((r) => typeof r.base === 'number');
  check('a skills row is available to edit', !!row, rows.status);
  if (row) {
    const bump = await api('PATCH', `/catalogs/rows?catalog=skills&id=${row.id}`, { base: row.base + 1 });
    check('an admin can edit a catalog row in place', bump.status === 200, bump.body);
    const afterEdit = await fetch(`${BASE}/catalogs`, { headers: { 'If-None-Match': tag || '' } });
    check('and an in-place edit invalidates the cached catalog', afterEdit.status === 200,
      `${afterEdit.status} — a count-based validator would have answered 304 here`);
    await api('PATCH', `/catalogs/rows?catalog=skills&id=${row.id}`, { base: row.base });
  }
}

// Fetched before the codex block rather than after it, because the codex's
// gear section is checked against this count — the two routes project the same
// table and a codex missing rows the picker has is the failure worth catching.
const items = await api('GET', '/items');
check('/items returns the gear catalog', items.status === 200 && items.body.items.length > 0, items.body);

// The codex: four catalogs WITH their description text and stat blocks, for
// everything a character does NOT hold. Its own route rather than a wider
// /catalogs, because that payload is paid on every wizard boot and every sheet
// load. See docs/plans/20-power-descriptions.md.
//
// ONE SECTION PER REQUEST since gear and vessels joined it: all four in one
// response is 261 KB gzipped against a 25 KB boot payload, so the page fetches
// a section when its tab is first opened. `section` is required.
{
  const spells = await api('GET', '/codex?section=spells');
  check('/codex answers on a database built only from schema.sql',
    spells.status === 200, spells.body);
  check('and carries the spell catalog whole',
    (spells.body.spells || []).length === catalogs.body.spells.length,
    `${(spells.body.spells || []).length}/${catalogs.body.spells.length} spells`);
  // The whole reason the route exists: the fields /catalogs deliberately omits.
  check('with the description and stat-block fields /catalogs leaves out',
    ['description', 'range', 'duration', 'saving_throw', 'casting_time']
      .every((f) => f in (spells.body.spells?.[0] || {})),
    Object.keys(spells.body.spells?.[0] || {}).join(', '));

  const psionics = await api('GET', '/codex?section=psionics');
  check('the psionics section carries that catalog whole',
    (psionics.body.psionics || []).length === catalogs.body.psionics.length,
    `${(psionics.body.psionics || []).length}/${catalogs.body.psionics.length} psionics`);

  const gear = await api('GET', '/codex?section=gear');
  check('the gear section carries the gear catalog whole',
    gear.status === 200 && (gear.body.gear || []).length === items.body.items.length,
    `${(gear.body.gear || []).length}/${items.body.items.length} gear`);
  check('and the stat block /items deliberately leaves out of the picker',
    ['damage', 'payload', 'rate_of_fire', 'ar', 'sdc', 'mdc', 'description']
      .every((f) => f in (gear.body.gear?.[0] || {})),
    Object.keys(gear.body.gear?.[0] || {}).join(', '));

  // Vessels are THREE tables and arrive nested, which is the shape that makes
  // them renderable at all: M.D.C. by location and a numbered weapon list
  // cannot live in a column, and a client should not have to regroup them.
  const vehicles = await api('GET', '/codex?section=vehicles');
  check('the vessels section answers', vehicles.status === 200, vehicles.body);
  check('and nests locations and weapons inside their vessel',
    (vehicles.body.vehicles || []).every((v) => Array.isArray(v.locations) && Array.isArray(v.weapons)),
    'a vessel came back without its two child arrays');

  const index = await api('GET', '/codex?section=index');
  check('the index section counts all four catalogs',
    index.status === 200
    && index.body.counts?.spells === catalogs.body.spells.length
    && index.body.counts?.gear === items.body.items.length,
    JSON.stringify(index.body.counts));

  // A section is REQUIRED. The bare route used to serve spells and psionics
  // together; serving one of them by default would be a second contract to keep
  // working, and silently serving the wrong catalog is worse than a 400.
  const bare = await api('GET', '/codex');
  check('a request with no section is refused rather than defaulted',
    bare.status === 400, bare.status);
  const bogus = await api('GET', '/codex?section=wands');
  check('and an unknown section is refused by name', bogus.status === 400
    && Array.isArray(bogus.body.sections), JSON.stringify(bogus.body));

  // A player, not an admin. `catalogs/rows` is requireAdmin because it WRITES;
  // this one only reads, and a codex only an admin can open is no codex.
  const asPlayer = await apiAs('stranger@example.com', 'GET', '/codex?section=spells');
  check('any authenticated friend can read it, not just an admin',
    asPlayer.status === 200, asPlayer.status);
  const rowsAsPlayer = await apiAs('stranger@example.com', 'GET', '/catalogs/rows?catalog=spells');
  check('while the editor route it replaces stays admin-only',
    rowsAsPlayer.status === 403, rowsAsPlayer.status);

  const firstHit = await fetch(`${BASE}/codex?section=spells`);
  const tag = firstHit.headers.get('ETag');
  check('/codex sends a validator', !!tag, 'no ETag header');
  const again = await fetch(`${BASE}/codex?section=spells`,
    { headers: { 'If-None-Match': tag || '' } });
  check('and a second visit revalidates to a 304', again.status === 304, again.status);

  // The section is IN the tag. Prove it by making the wrong one fail: a Gear
  // request carrying the Spells tag must serve a body, not a 304. Two sections
  // that serialised identically would otherwise revalidate into each other,
  // which is exactly what two EMPTY catalogs do on a fresh database.
  const crossed = await fetch(`${BASE}/codex?section=gear`,
    { headers: { 'If-None-Match': tag || '' } });
  check("and one section's validator does not satisfy another",
    crossed.status === 200, crossed.status);
}

// ── the README's clean-run counts ───────────────────────────────────────────
// The README prints a table of what "a clean run produces", and until now
// nothing checked it: every number in it was stale - 23 classes against 39,
// 366 spells against 542 - three paragraphs below its own warning that prose
// counts drift silently.
//
// This is the only place that can honestly check it. smoke.mjs never builds a
// full database and drift-check talks to an environment somebody has been
// using; here the database was built from schema + seed + every data script,
// minutes ago, from nothing.
// The clean-run table moved to docs/operations.md with the README split; it is
// part of `Production configuration`, which is where a rebuild is described.
const OPERATIONS = readFileSync(join(appDir, 'docs', 'operations.md'), 'utf8');
// Anchor to the clean-run table, not to the whole file: matching
// "spells" anywhere found "| spells missing | 5 | 0 |" in the
// import-tooling section and asserted the catalog held five. Labels are
// escaped because one of them contains parentheses.
const TABLE = (OPERATIONS.split('| After | Rows |')[1] || '').split('\n\n')[0];
const documented = (label) => {
  const lit = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const m = new RegExp('^\\|\\s*' + lit + '[^|]*\\|\\s*(\\d+)\\s*\\|', 'm').exec(TABLE);
  return m ? Number(m[1]) : null;
};
// `vehicles` is counted through the codex index because it is the ONLY route
// that reports it: the table has no picker, no boot-payload SELECT and nothing
// in `catalogs`. That is why this row could not exist until the codex learned
// the section, and it is the reason the pin lands in this PR rather than the
// documentation one — a row in the table with no matching key here is silently
// ignored by the loop below, so both halves or neither.
const codexIndex = await api('GET', '/codex?section=index');
const actual = {
  'classes (published, live)': classes.body.classes.length,
  skills: catalogs.body.skills.length,
  // One game's own percentages (BOOK-INGEST-AUDIT.md F83). Counted through the
  // boot payload like the rest, and it is the only route that reports them -
  // the table has no picker and no codex section. A count here that drifts
  // means a book's figures were added or lost without the record moving.
  'per-system skill bases': (catalogs.body.skillSystemBases || []).length,
  spells: catalogs.body.spells.length,
  'psionic powers': catalogs.body.psionics.length,
  gear: items.body.items.length,
  vehicles: codexIndex.body.counts?.vehicles,
};
for (const [label, got] of Object.entries(actual)) {
  const want = documented(label);
  check(`README clean-run count for ${label}`, want === got,
    want === null ? `no row for "${label}" in the README table`
                  : `README says ${want}, a clean run produced ${got}`);
}


// ── a character, end to end ─────────────────────────────────────────────────
console.log('\n[4/7] Creating a campaign and a character');
const camp = await api('POST', '/campaigns', { name: 'Regression Run', system: 'rifts' });
check('a campaign is created', camp.status === 201 || camp.status === 200, camp.body);
const campaignId = camp.body.id ?? camp.body.campaign?.id;
check('and it has an id', !!campaignId, camp.body);

// Pick a class with no variant, no ability choices and no O.C.C. requirement,
// so the payload stays about the endpoint rather than about class rules.
const cls = classes.body.classes.find((c) => c.id === 'cyber-knight')
  || classes.body.classes.find((c) => !(c.variants || []).length && c.system === 'rifts');
check('a test class is available', !!cls, 'no usable class in /classes');

const attrs = { IQ: 16, ME: 16, MA: 16, PS: 16, PP: 16, PE: 16, PB: 16, Spd: 16 };
const occSkills = (cls.skills?.occ_skills || []).map((s) => ({
  name: typeof s === 'string' ? s : s.name, category: 'Class', type: 'occ', pct: 40, per_level: 5,
})).filter((s) => s.name);

const made = await api('POST', '/characters', {
  campaign_id: campaignId, name: 'Regression Character', class_id: cls.id,
  attributes: attrs, skills: occSkills, abilities: [],
  pools: { hp: 30, sdc: 40, ppe: 20, isp: 0 },
  bio: { alignment: 'Principled' },
});
check('a character is created and passes server validation',
  made.status === 201, JSON.stringify(made.body).slice(0, 300));
const charId = made.body.id;

const sheet = await api('GET', `/characters/${charId}`);
check('its sheet loads', sheet.status === 200 && sheet.body.character?.id === charId, sheet.body);

// A fighting style is a level schedule (RUE p.347), and the only proof that
// matters is the number the sheet actually serves. Every piece has to line up -
// the column exists, the data script ran, the loader selects it, compose passes
// the level, derive treats attacks_base as a floor - and any one of them failing
// looks like a character who simply fights slightly worse.
const h2hChar = await api('POST', '/characters', {
  campaign_id: campaignId, name: 'Trained Fighter', class_id: cls.id, level: 1,
  attributes: attrs, skills: [{ name: 'Hand to Hand: Expert', pct: 0, per_level: 0, type: 'occ' }],
  abilities: [],
});
if (h2hChar.status === 200 || h2hChar.status === 201) {
  const id = h2hChar.body.id;
  const s1 = await api('GET', `/characters/${id}`);
  const notes1 = s1.body.skill_level_notes || [];
  check('a first level Expert is served four attacks per melee',
    s1.body.character?.combat?.attacks === 4 || s1.body.class?.bonuses?.combat?.attacks_base === 4,
    JSON.stringify({ combat: s1.body.character?.combat, bonuses: s1.body.class?.bonuses?.combat }));
  check('and the moves the level grants come back as text',
    notes1.length > 0 && notes1.every((n) => n.level <= 1), JSON.stringify(notes1));

  globalThis.__h2hId = id;
  globalThis.__h2hNotes1 = notes1.length;
} else {
  check('a character can be created with a Hand to Hand skill', false, h2hChar.body);
}
check('and reports write permission for its owner', sheet.body.can_write === true, sheet.body.can_write);

// the guard folded into requireCharacter, on a real request
const missing = await api('GET', '/characters/99999999');
check('a character that does not exist is a 404, not a 403', missing.status === 404, missing.status);

// ── the join gate ───────────────────────────────────────────────────────────
// Joining a campaign IS creating a character in it — membership is "owns a
// character here" — so campaigns.open is the door onto its notes, stash and
// ledger. Closed admits only the GM and the people already in, and who is
// "in" stays campaignAccess's question. Migration 037.
{
  const joinable = (name) => ({
    campaign_id: campaignId, name, class_id: cls.id,
    attributes: attrs, skills: [], abilities: [], bio: { alignment: 'Principled' },
  });

  const listedOpen = await apiAs('stranger@example.com', 'GET', '/campaigns');
  const rowOpen = (listedOpen.body.campaigns || []).find((c) => c.id === campaignId);
  check('an open campaign lists as joinable to a stranger', rowOpen?.can_join === true,
    JSON.stringify(rowOpen));

  const closed = await api('PATCH', `/campaigns/${campaignId}`, { open: false });
  check('the GM can close it to new characters', closed.status === 200, closed.body);
  const barred = await apiAs('stranger@example.com', 'PATCH', `/campaigns/${campaignId}`, { open: true });
  check('and nobody else can reopen it', barred.status === 403, barred.status);

  const crasher = await apiAs('stranger@example.com', 'POST', '/characters', joinable('Gate Crasher'));
  check('a stranger cannot create a character in a closed campaign',
    crasher.status === 403, JSON.stringify(crasher.body).slice(0, 200));
  const listedClosed = await apiAs('stranger@example.com', 'GET', '/campaigns');
  const rowClosed = (listedClosed.body.campaigns || []).find((c) => c.id === campaignId);
  check('and the list says so, per caller', rowClosed?.can_join === false,
    JSON.stringify(rowClosed));

  // dev@localhost is the GM and a member at once, so the member path gets its
  // own person: joined while the door was open, then admitted through it
  // closed. That is the distinction the gate exists to draw — joining is
  // gated, being in is not.
  await api('PATCH', `/campaigns/${campaignId}`, { open: true });
  const joined = await apiAs('player2@example.com', 'POST', '/characters', joinable('Second Chair'));
  check('anyone may join an OPEN campaign by creating a character',
    joined.status === 201, JSON.stringify(joined.body).slice(0, 200));
  await api('PATCH', `/campaigns/${campaignId}`, { open: false });
  const second = await apiAs('player2@example.com', 'POST', '/characters', joinable('Second Chair Again'));
  check('an existing member still may once it closes', second.status === 201,
    JSON.stringify(second.body).slice(0, 200));
  const gmNpc = await api('POST', '/characters', joinable('GM NPC'));
  check('and so may the GM', gmNpc.status === 201, JSON.stringify(gmNpc.body).slice(0, 200));

  // Back to open, so nothing downstream inherits the closed state.
  await api('PATCH', `/campaigns/${campaignId}`, { open: true });
}

// ── inventory ───────────────────────────────────────────────────────────────
console.log('\n[5/7] Inventory, XP, level-up, picks, play');
// By SLUG, not id — the catalog exposes ids but this endpoint keys on the slug,
// because class markdown cites gear that way and one spelling is enough.
const gearRow = items.body.items.find((i) => i.slug) || items.body.items[0];
const added = await api('POST', `/characters/${charId}/items`, { slug: gearRow.slug, qty: 2 });
check('gear is added to the inventory', added.status === 201 || added.status === 200, added.body);
const itemId = added.body.id ?? added.body.item?.id;

const badSlug = await api('POST', `/characters/${charId}/items`, { slug: 'no-such-item-anywhere', qty: 1 });
check('an unknown gear slug is refused', badSlug.status === 400, badSlug.body);
const noRef = await api('POST', `/characters/${charId}/items`, { qty: 1 });
check('an item with neither slug nor custom_name is refused', noRef.status === 400, noRef.body);
const freeform = await api('POST', `/characters/${charId}/items`, { custom_name: 'A thing from play', qty: 1 });
check('a freeform item is accepted', freeform.status === 201, freeform.body);

// ── inventory is keyed on the slug and on nothing else — RETRO-AUDIT R21 ──
//
// `gear_slug` was added beside `item_id` by migration 044 and this block used
// to assert the two never drifted apart. Migration 046 dropped the id, so the
// invariant is stronger and simpler: the slug is the only key there is, and a
// row must come back carrying it and NOT carrying an id.
//
// The id is still what the wizard POSTs - `character_drafts.state` holds raw
// gear ids in its JSON - so the wire format outliving the column is the point,
// not an oversight. The slug is derived inside the insert statement.
{
  const addedRow = added.body.item ?? added.body;
  check('adding gear writes the portable slug',
    addedRow.gear_slug === gearRow.slug,
    `gear_slug ${JSON.stringify(addedRow.gear_slug)} for slug ${gearRow.slug}`);
  check('and the row carries no gear id at all any more',
    !('item_id' in addedRow),
    `item_id is still on the row: ${JSON.stringify(addedRow.item_id)}`);
  check('and the freeform item gets no key',
    (freeform.body.item ?? freeform.body).gear_slug == null,
    JSON.stringify((freeform.body.item ?? freeform.body).gear_slug));

  // The sheet's read joins on the slug and has no id arm left to fall back on,
  // so the item has to come BACK with its catalog row attached - a join that
  // silently matched nothing would leave item_name null and render as a bare
  // custom line.
  const sheet = await api('GET', `/characters/${charId}`);
  // `items` is returned at the TOP level of the sheet payload, not under
  // `character` - the first version of this check looked in the wrong place and
  // reported a join failure that was its own.
  const held = (sheet.body.items || []).find((i) => i.gear_slug === gearRow.slug);
  check('and the slug-joined read still resolves the catalog row',
    !!held && held.item_name === gearRow.name,
    held ? `item_name ${JSON.stringify(held.item_name)}` : 'row not found on the sheet');
}

if (itemId) {
  const patched = await api('PATCH', `/characters/${charId}/items/${itemId}`, { qty: 3, equipped: true });
  check('an inventory row can be updated', patched.status === 200, patched.body);
  const removed = await api('DELETE', `/characters/${charId}/items/${itemId}`);
  check('and soft-removed', removed.status === 200, removed.body);
  const after = await api('GET', `/characters/${charId}`);
  const stillThere = (after.body.items || []).some((i) => i.id === itemId && !i.removed_at);
  check('a removed row leaves the active inventory', !stillThere);
}

// ── owning a vessel ─────────────────────────────────────────────────────────
// Migration 052. Vessels have been a catalog since 048 and readable since the
// codex learned the section, but nothing could OWN one: character_items.gear_slug
// REFERENCES gear(slug), so a robot could not go in an inventory even in
// principle.
{
  const vRows = await api('GET', '/codex?section=vehicles');
  const vessel = (vRows.body.vehicles || []).find((v) => (v.locations || []).length > 1);
  check('a vessel with named locations exists to own', !!vessel,
    `${(vRows.body.vehicles || []).length} vessels, none with locations`);

  if (vessel) {
    const bad = await api('POST', `/characters/${charId}/vehicles`, { slug: 'no-such-vessel-anywhere' });
    check('a slug the catalog does not have is refused', bad.status === 400, bad.status);
    const neither = await api('POST', `/characters/${charId}/vehicles`, { nickname: 'nothing' });
    check('and so is a body with neither slug nor custom_name', neither.status === 400, neither.status);

    const added = await api('POST', `/characters/${charId}/vehicles`, { slug: vessel.slug, nickname: 'Betsy' });
    check('a character can be given a vessel', added.status === 201, added.body);
    const vid = added.body.vehicle?.id;

    const sheet = await api('GET', `/characters/${charId}`);
    const held = (sheet.body.vehicles || []).find((v) => v.id === vid);
    check('and it arrives with the character', !!held, JSON.stringify(sheet.body.vehicles));
    // The nesting is the point: three tables, one object, the same shape the
    // codex returns. A client should not have to regroup 80 rows.
    check('carrying its catalog row, its locations and its weapon systems',
      !!held?.vehicle_name && (held?.locations || []).length === vessel.locations.length,
      `${held?.locations?.length} locations vs ${vessel.locations.length} in the catalog`);
    // NULL decodes to {} and not to null or []. Object.entries() is what a
    // renderer writes, and it throws on null.
    check('an undamaged vessel reports {} rather than null',
      held && typeof held.mdc_current === 'object' && !Array.isArray(held.mdc_current)
      && Object.keys(held.mdc_current).length === 0, JSON.stringify(held?.mdc_current));

    // Damage is checked against THIS vessel's own locations. Stored unchecked,
    // a typo renders as a damaged part that does not exist and no reader can
    // tell that from a book they have not read.
    const loc = vessel.locations[0].location;
    const hit = await api('PATCH', `/characters/${charId}/vehicles/${vid}`,
      { mdc_current: { [loc]: 120 } });
    check('damage can be recorded against a named location', hit.status === 200, hit.body);
    const ghost = await api('PATCH', `/characters/${charId}/vehicles/${vid}`,
      { mdc_current: { 'Tail Fin Of Nowhere': 10 } });
    check('a location this vessel does not have is refused by name',
      ghost.status === 400 && /Tail Fin Of Nowhere/.test(ghost.body?.error || ''), ghost.body);
    const notNumber = await api('PATCH', `/characters/${charId}/vehicles/${vid}`,
      { mdc_current: { [loc]: 'lots' } });
    check('and so is damage that is not a number', notNumber.status === 400, notNumber.body);
    const asArray = await api('PATCH', `/characters/${charId}/vehicles/${vid}`,
      { mdc_current: [1, 2] });
    check('and an array, which parses fine and is the wrong shape',
      asArray.status === 400, asArray.body);

    const back = await api('GET', `/characters/${charId}`);
    check('the recorded damage reads back',
      (back.body.vehicles || []).find((v) => v.id === vid)?.mdc_current?.[loc] === 120,
      JSON.stringify((back.body.vehicles || []).find((v) => v.id === vid)?.mdc_current));

    // A freeform vessel joins to no catalog row, so it has no location list to
    // check against and any key is allowed - the same concession a freeform
    // item gets for enchantments.
    const free = await api('POST', `/characters/${charId}/vehicles`, { custom_name: 'The stolen barge' });
    check('a freeform vessel needs no catalog row', free.status === 201, free.body);
    const freeHit = await api('PATCH', `/characters/${charId}/vehicles/${free.body.vehicle?.id}`,
      { mdc_current: { Hull: 40 } });
    check('and takes damage anywhere, having no locations to check',
      freeHit.status === 200, freeHit.body);

    const gone = await api('DELETE', `/characters/${charId}/vehicles/${vid}`);
    check('a vessel is soft-removed', gone.status === 200, gone.body);
    const afterV = await api('GET', `/characters/${charId}`);
    check('and leaves the active list', !(afterV.body.vehicles || []).some((v) => v.id === vid));
  }
}

// ── xp and levelling ────────────────────────────────────────────────────────
const xp = await api('POST', `/characters/${charId}/xp`, { total: 100000 });
check('XP can be set', xp.status === 200, xp.body);
check('crossing a threshold returns a PROPOSAL rather than applying it',
  !!xp.body.proposal, JSON.stringify(xp.body).slice(0, 200));

// UI-AUDIT F42: a level that is owed is known on LOAD, not only from POST /xp,
// so a sheet opened with enough XP says so before anybody logs any.
const owed = await api('GET', `/characters/${charId}`);
check('the character GET says a level is owed once XP pays for one',
  owed.body.level_up_ready === true && typeof owed.body.next_threshold === 'number',
  JSON.stringify({ ready: owed.body.level_up_ready, next: owed.body.next_threshold }));

if (xp.body.proposal) {
  const target = xp.body.proposal.to_level ?? xp.body.level + 1;
  const confirmed = await api('POST', `/characters/${charId}/level-confirm`, {
    to_level: target, picks: [],
  });
  check('a level-up can be confirmed', confirmed.status === 200, JSON.stringify(confirmed.body).slice(0, 250));
  const levelled = await api('GET', `/characters/${charId}`);
  check('and the character is actually at the new level',
    levelled.body.character.level === target,
    'level is ' + levelled.body.character?.level + ', expected ' + target);
  check('and stops saying a level is owed once it is taken',
    levelled.body.level_up_ready === false, levelled.body.level_up_ready);
}

const picks = await api('GET', `/characters/${charId}/picks`);
check('pending skill picks are listed', picks.status === 200 && Array.isArray(picks.body.pending), picks.body);
// ── Talent purchases are paid for out of the P.P.E. base (BOOK-INGEST-AUDIT F101) ──
//
// Printed 106 lets a Nightbane BUY two Talents at level one and at every level
// after, each for a permanent expenditure of P.P.E. Driven through the three real
// routes that touch it - create banks the level-one allowance, the spend
// endpoint charges it, level-confirm charges it against the RAISED maximum - on
// a fixture class and three fixture Talents that exist only in this scratch
// database and are removed again at the end, so no later sweep of published
// classes or catalog rows sees them.
{
  const fixture = join(state, 'f101-fixture.sql');
  writeFileSync(fixture, [
    "INSERT INTO imported_classes (class_id, name, system, status, markdown, created_by, created_at) VALUES ('f101-probe', 'F101 Probe', 'nightbane', 'published', '---\nid: f101-probe\nname: F101 Probe\nsystem: nightbane\nsource_book: Nightbane RPG p.106\ncategory: rcc\nhit_points_base: \"P.E. + 1D6 per level\"\nsdc_base: \"3D6\"\ntalents:\n  talents_starting: 1\n  talents_purchases_per_level: 2\n  talents_schedule:\n    - { level: 4, count: 1 }\n---\n\n## Lore\n\nA regression fixture.\n', 'regression', datetime('now'))",
    "INSERT INTO talents (name, tier, acquire_ppe, ppe, min_character_level, system, source_book) VALUES ('F101 Probe Small', 'common', 10, 2, NULL, 'nightbane', 'fixture'), ('F101 Probe Mid', 'common', 15, 2, NULL, 'nightbane', 'fixture'), ('F101 Probe Big', 'common', 25, 2, NULL, 'nightbane', 'fixture'), ('F101 Probe Fifth', 'common', 5, 2, 5, 'nightbane', 'fixture')",
  ].join(';\n') + ';\n', 'utf8');
  const seeded = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', fixture]);
  check('the Talent purchase fixture is seeded', seeded.status === 0, cleanErr(seeded.stderr || seeded.stdout || ''));

  const nbCamp = await api('POST', '/campaigns', { name: 'Regression Nightbane', system: 'nightbane' });
  const nbCampId = nbCamp.body.id ?? nbCamp.body.campaign?.id;
  const nb = await api('POST', '/characters', {
    campaign_id: nbCampId, name: 'Talent Buyer', class_id: 'f101-probe',
    attributes: attrs, skills: [], abilities: [], powers: [],
    pools: { hp: 20, sdc: 20, ppe: 30 },
  });
  check('a character whose class may buy Talents is created', nb.status === 201, JSON.stringify(nb.body).slice(0, 300));
  const nbId = nb.body.id;
  const pendingOf = async () => (await api('GET', `/characters/${nbId}/power-picks`)).body.pending || [];
  const bought = (rows) => rows.filter((g) => g.kind === 'talent_purchase');

  const atCreate = bought(await pendingOf());
  check('creation banks the level-one purchase allowance of two',
    atCreate.length === 1 && atCreate[0].granted_at_level === 1 && atCreate[0].count === 2,
    JSON.stringify(atCreate));

  const buy = (picks) => api('POST', `/characters/${nbId}/power-picks`, { picks });
  const P = (name, level = 1) => ({ kind: 'talent_purchase', name, granted_at_level: level, slot: 0 });
  const readChar = async () => (await api('GET', `/characters/${nbId}`)).body.character || {};

  // 25 + 10 is 35, against a base of 30. Each fits alone; together they do not.
  const tooMuch = await buy([P('F101 Probe Big'), P('F101 Probe Small')]);
  check('two purchases the base cannot cover TOGETHER are refused as a whole',
    tooMuch.status === 422 && /35 permanent P\.P\.E\./.test(JSON.stringify(tooMuch.body)),
    JSON.stringify(tooMuch.body).slice(0, 300));
  const untouched = await readChar();
  check('and nothing was charged or learned',
    (untouched.ppe_base_spent ?? 0) === 0 && !(untouched.powers || []).some((p) => /F101 Probe/.test(p.name)),
    JSON.stringify({ spent: untouched.ppe_base_spent, powers: untouched.powers }));

  const early = await buy([P('F101 Probe Fifth')]);
  check('a fifth-level Talent cannot be bought with a level-one allowance', early.status === 422,
    JSON.stringify(early.body).slice(0, 200));

  const free = await api('POST', `/characters/${nbId}/power-picks`,
    { picks: [{ kind: 'talent', name: 'F101 Probe Small', granted_at_level: 1, slot: 0 }] });
  check('and a purchase allowance cannot be spent as a free Talent', free.status >= 400,
    JSON.stringify(free.body).slice(0, 200));

  const small = await buy([P('F101 Probe Small')]);
  check('a purchase the base covers is accepted', small.status === 200 && small.body.ppe_spent === 10,
    JSON.stringify(small.body).slice(0, 300));
  const afterSmall = await readChar();
  check('it is paid out of the base, and current P.P.E. is clamped to what can still be filled',
    afterSmall.ppe_base_spent === 10 && afterSmall.ppe_max === 30 && afterSmall.ppe_current === 20,
    JSON.stringify({ max: afterSmall.ppe_max, spent: afterSmall.ppe_base_spent, current: afterSmall.ppe_current }));
  const smallRow = (afterSmall.powers || []).find((p) => p.name === 'F101 Probe Small');
  check('and the Talent is stored as bought, with its price',
    smallRow?.type === 'talent' && smallRow?.purchased === true && smallRow?.acquire_cost === 10,
    JSON.stringify(smallRow));
  check('one purchase is left in the level-one allowance',
    bought(await pendingOf()).reduce((n, g) => n + g.count, 0) === 1);

  // Level two. The allowance grows by two, and the base a purchase is paid from
  // is the maximum AFTER the level-up less what is already spent: 36 - 10 = 26.
  await api('POST', `/characters/${nbId}/xp`, { total: 2000 });
  const overLevel = await api('POST', `/characters/${nbId}/level-confirm`, {
    to_level: 2, picks: [], pools: { ppe_max: 36 },
    power_picks: [P('F101 Probe Big', 2), P('F101 Probe Mid', 2)],
  });
  check('level-confirm refuses purchases the raised base cannot cover (25 + 15 against 26)',
    overLevel.status === 422, JSON.stringify(overLevel.body).slice(0, 300));
  const stillOne = await readChar();
  check('and the refused level-up did not happen', stillOne.level === 1, 'level ' + stillOne.level);

  const levelled = await api('POST', `/characters/${nbId}/level-confirm`, {
    to_level: 2, picks: [], pools: { ppe_max: 36 },
    power_picks: [P('F101 Probe Big', 2)],
  });
  check('level-confirm accepts a purchase the raised base covers', levelled.status === 200,
    JSON.stringify(levelled.body).slice(0, 300));
  const afterLevel = await readChar();
  // current was 20 and rose with the maximum by 6 to 26; the effective maximum is
  // now 36 - 35 = 1, so it clamps to 1.
  check('it is charged against the new maximum and current is clamped to what is left',
    afterLevel.level === 2 && afterLevel.ppe_max === 36 && afterLevel.ppe_base_spent === 35
    && afterLevel.ppe_current === 1,
    JSON.stringify({ level: afterLevel.level, max: afterLevel.ppe_max, spent: afterLevel.ppe_base_spent,
                     current: afterLevel.ppe_current }));
  const leftAfter = bought(await pendingOf());
  check('and the unspent purchases bank: one from level one, one from level two',
    JSON.stringify(leftAfter.map((g) => [g.granted_at_level, g.count])) === '[[1,1],[2,1]]',
    JSON.stringify(leftAfter.map((g) => [g.granted_at_level, g.count])));

  const cleanup = join(state, 'f101-cleanup.sql');
  writeFileSync(cleanup, "UPDATE imported_classes SET status = 'draft' WHERE class_id = 'f101-probe';\n"
    + "DELETE FROM talents WHERE source_book = 'fixture';\n", 'utf8');
  const cleaned = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', cleanup]);
  check('the Talent purchase fixture is removed again', cleaned.status === 0, cleanErr(cleaned.stderr || ''));
}

// ── A second body: the Facade and the Morphus (BOOK-INGEST-AUDIT F74) ──
//
// Nightbane survey D5. A fixture class states a `second_form`; a character is
// created holding two REAL Morphus table results (the catalog's data script is
// in the bootstrap) with every die pre-rolled, so the numbers the sheet
// endpoint folds are known exactly. Each form's current S.D.C. is then written
// on its own, and the sheet endpoint is read back to prove neither touched the
// other. smoke.mjs pins the fold; this proves the routes, the column and the
// catalog join agree with it.
{
  const fixture = join(state, 'f74-fixture.sql');
  const md = '---\nid: f74-probe\nname: F74 Probe\nsystem: nightbane\nsource_book: Nightbane RPG p.87\n'
    + 'category: rcc\nhit_points_base: "P.E. + 1D6 per level"\nsdc_base: 30\nsecond_form:\n'
    + '  name: "Morphus"\n  first_name: "Facade"\n  bonuses:\n'
    + '    attributes: { PS: 10, PE: 10, Spd: 10, PP: 6 }\n    pools: { sdc: "2d6x10" }\n'
    + '    combat: { initiative: 1, strike: 2, parry: 2, dodge: 2, attacks: 1 }\n'
    + '    saves: { psionics: 3, horror_factor: 3 }\n'
    + '  hit_points_base: "P.E. x2 + 2d6 per level"\n  horror_factor: 6\n  horror_factor_max: 18\n'
    + '  traits_from: morphus\n---\n\n## Lore\n\nA regression fixture.\n';
  writeFileSync(fixture, "INSERT INTO imported_classes (class_id, name, system, status, markdown, created_by, created_at) "
    + `VALUES ('f74-probe', 'F74 Probe', 'nightbane', 'published', '${md.replace(/'/g, "''")}', 'regression', datetime('now'));\n`, 'utf8');
  const seeded = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', fixture]);
  check('the second-body fixture class is seeded', seeded.status === 0, cleanErr(seeded.stderr || seeded.stdout || ''));

  const sfCamp = await api('POST', '/campaigns', { name: 'Regression Morphus', system: 'nightbane' });
  const sfCampId = sfCamp.body.id ?? sfCamp.body.campaign?.id;
  const form = {
    active: 'first',
    form_rolls: { pools: { sdc: 70 } },
    hp_rolls: [7],
    results: [
      { key: 'Unearthly Beauty: Physical Perfection', sub_choice: null,
        rolls: { attributes: { PB: 2, PE: 3, PS: 1 }, pools: { sdc: 14 } } },
      { key: 'Stigmata: Missing Skin', sub_choice: 'patches of skin missing',
        rolls: { horror_factor: 4, pools: { sdc: 10 } } },
    ],
    sdc_current: null, hp_current: null,
  };
  const body = (second_form) => ({
    campaign_id: sfCampId, name: 'Two Bodies', class_id: 'f74-probe',
    attributes: attrs, skills: [], abilities: [], powers: [], pools: { hp: 20, sdc: 30, ppe: 20 },
    ...(second_form ? { second_form } : {}),
  });
  const rules = (r) => (r.body?.violations || []).map((v) => v.rule);

  const badKey = await api('POST', '/characters', body({ ...form, results: [{ key: 'Stigmata: Not A Stigma', rolls: {} }] }));
  check('create refuses a result that is no Morphus table entry',
    badKey.status === 422 && rules(badKey).includes('second_form_result_unknown'), JSON.stringify(badKey.body).slice(0, 300));
  const badRoll = await api('POST', '/characters', body({ ...form,
    results: [form.results[0], { ...form.results[1], rolls: { horror_factor: 6, pools: { sdc: 10 } } }] }));
  check('create refuses a roll its dice cannot make (1d4+1 rolling 6)',
    badRoll.status === 422 && rules(badRoll).includes('second_form_roll_out_of_range'), JSON.stringify(badRoll.body).slice(0, 300));
  const badCurrent = await api('POST', '/characters', body({ ...form, sdc_current: 500 }));
  check('create refuses a current S.D.C. above the form\'s maximum',
    badCurrent.status === 422 && rules(badCurrent).includes('second_form_current_above_max'), JSON.stringify(badCurrent.body).slice(0, 300));
  const oneBody = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'One Body', class_id: cls.id, attributes: attrs, skills: occSkills,
    abilities: [], pools: { hp: 30, sdc: 40, ppe: 20, isp: 0 }, second_form: form,
  });
  check('create refuses a second body on a class that states none',
    oneBody.status === 422 && rules(oneBody).includes('second_form_not_allowed'), JSON.stringify(oneBody.body).slice(0, 300));

  const sf = await api('POST', '/characters', body(form));
  check('a character with a second body is created', sf.status === 201, JSON.stringify(sf.body).slice(0, 300));
  const sfId = sf.body.id;
  const read = async () => (await api('GET', `/characters/${sfId}`)).body;

  let r = await read();
  const v = r.second_form;
  // P.E. 16 + 10 + 3 = 29: hit points 29 x 2 + 7. S.D.C. 30 + 70 + 14 + 10.
  // Physical Perfection SETS the Horror Factor to 6, Missing Skin adds its 4.
  check('the sheet endpoint folds the form: hit points on the Morphus P.E. (29 x 2 + 7 = 65)',
    v?.hp_max === 65 && v?.attributes?.PE === 29 && v?.attributes?.PS === 27, JSON.stringify(v).slice(0, 300));
  check('S.D.C. is the Facade\'s 30 plus every rolled bonus (124)', v?.sdc_max === 124 && v?.sdc_current === 124,
    JSON.stringify({ max: v?.sdc_max, cur: v?.sdc_current }));
  check('the Horror Factor is the set 6 plus the rolled 4', v?.horror_factor === 10, JSON.stringify(v?.horror_factor_parts));
  check('both results resolve against the catalog, table and all',
    v?.results?.length === 2 && v.results.every((x) => x.found) && v.results[1].table === 'Stigmata',
    JSON.stringify(v?.results));
  check('the form\'s bonuses reach the sheet', v?.form_bonuses?.combat?.strike === 2 && v?.active === 'first');

  // Each form's damage on its own.
  const facadeHit = await api('PATCH', `/characters/${sfId}`, { sdc_current: 12 });
  check('the Facade\'s S.D.C. is written', facadeHit.status === 200, JSON.stringify(facadeHit.body));
  const morphusHit = await api('PATCH', `/characters/${sfId}`, { second_form: { sdc_current: 100 } });
  check('the Morphus\'s S.D.C. is written on its own', morphusHit.status === 200, JSON.stringify(morphusHit.body));
  r = await read();
  check('and neither touched the other: Facade 12 of 30, Morphus 100 of 124',
    r.character.sdc_current === 12 && r.character.sdc_max === 30
    && r.second_form.sdc_current === 100 && r.second_form.sdc_max === 124,
    JSON.stringify({ facade: r.character.sdc_current, morphus: r.second_form.sdc_current }));
  check('and the stored results survived the field-by-field write',
    r.character.second_form?.results?.length === 2 && r.character.second_form.form_rolls?.pools?.sdc === 70,
    JSON.stringify(r.character.second_form).slice(0, 300));

  await api('PATCH', `/characters/${sfId}`, { sdc_current: 30 });
  r = await read();
  check('healing the Facade leaves the Morphus where it was', r.second_form.sdc_current === 100 && r.character.sdc_current === 30);

  const over = await api('PATCH', `/characters/${sfId}`, { second_form: { sdc_current: 999, hp_current: -4, active: 'second' } });
  r = await read();
  check('a Morphus value above its maximum is clamped, and below zero floored',
    over.status === 200 && r.second_form.sdc_current === 124 && r.second_form.hp_current === 0,
    JSON.stringify({ sdc: r.second_form.sdc_current, hp: r.second_form.hp_current }));
  check('and the form shown is saved', r.second_form.active === 'second' && r.character.second_form.active === 'second');
  const rolls = await api('PATCH', `/characters/${sfId}`, { second_form: { results: [] } });
  check('the PATCH will not rewrite the rolls or results', rolls.status === 400, JSON.stringify(rolls.body));
  const noForm = await api('PATCH', `/characters/${charId}`, { second_form: { sdc_current: 5 } });
  check('nor write a second body onto a character whose class has none', noForm.status === 400, JSON.stringify(noForm.body));

  // Level two: one more 2D6 for the Morphus's hit points.
  await api('PATCH', `/characters/${sfId}`, { second_form: { hp_current: 50 } });
  const xp = await api('POST', `/characters/${sfId}/xp`, { total: 2000 });
  const extra = xp.body?.proposal?.second_form?.hp_rolls;
  check('the level-up proposal rolls the Morphus\'s hit points',
    Array.isArray(extra) && extra.length === 1 && extra[0] >= 2 && extra[0] <= 12, JSON.stringify(xp.body?.proposal?.second_form));
  const badLevel = await api('POST', `/characters/${sfId}/level-confirm`, { to_level: 2, pools: {}, picks: [], second_form_hp_rolls: [13] });
  check('level-confirm refuses a roll 2D6 cannot make', badLevel.status === 400, JSON.stringify(badLevel.body).slice(0, 200));
  const lvl = await api('POST', `/characters/${sfId}/level-confirm`, { to_level: 2, pools: {}, picks: [],
    second_form_hp_rolls: extra });
  r = await read();
  check('level-confirm appends it, raising the maximum and the current value by the roll',
    lvl.status === 200 && r.character.second_form.hp_rolls.length === 2
    && r.second_form.hp_max === 65 + extra[0] && r.second_form.hp_current === 50 + extra[0],
    JSON.stringify({ status: lvl.status, rolls: r.character.second_form?.hp_rolls, max: r.second_form?.hp_max, cur: r.second_form?.hp_current }));

  // ── Damage, healing and rest on the ACTIVE form (Nightbane follow-up 5) ──
  //
  // Nate, 2026-09-17: they apply to whichever form is active, and a Morphus
  // pool goes below zero into hit points like the Facade's. Each press is built
  // the way the sheet builds it - derive.damageCascade over derive.activePools,
  // routed by derive.playChanges - and sent through the real events route; the
  // sheet endpoint is read back after each to see which body moved.
  await import('../js/derive.js');  // a classic script: installs globalThis.derive
  const D = globalThis.derive;
  const press = async (kind, note, patchOf) => {
    const cur = await read();
    const changes = D.playChanges(cur.character, cur.second_form, patchOf(D.activePools(cur.character, cur.second_form)));
    return { res: await api('POST', `/characters/${sfId}/events`, { kind, note, changes }), changes };
  };
  r = await read();
  const facade0 = { sdc: r.character.sdc_current, hp: r.character.hp_current };
  const morph0 = { sdc: r.second_form.sdc_current, hp: r.second_form.hp_current, hpMax: r.second_form.hp_max };
  check('the fixture is in its Morphus, with both bodies holding their own pools',
    r.second_form.active === 'second' && morph0.sdc === 124 && morph0.hp > 0,
    JSON.stringify({ facade0, morph0 }));

  // A hit 7 past everything the Morphus has left: S.D.C. to 0, hit points to -7.
  const bigHit = morph0.sdc + morph0.hp + 7;
  const dmg = await press('damage', `took ${bigHit}`, (p) => D.damageCascade(p, bigHit));
  r = await read();
  check('Damage in the Morphus goes through the events route, as a second-form change',
    dmg.res.status === 200 && !!dmg.changes.second_form && !dmg.changes.character, JSON.stringify(dmg.res.body));
  check('it runs the Morphus\'s S.D.C. to 0 and its hit points below zero (-7)',
    r.second_form.sdc_current === 0 && r.second_form.hp_current === -7
    && r.character.second_form.sdc_current === 0 && r.character.second_form.hp_current === -7,
    JSON.stringify({ sdc: r.second_form.sdc_current, hp: r.second_form.hp_current }));
  check('and only the Morphus: the Facade\'s pools did not move',
    r.character.sdc_current === facade0.sdc && r.character.hp_current === facade0.hp,
    JSON.stringify({ facade0, now: { sdc: r.character.sdc_current, hp: r.character.hp_current } }));
  check('the stored results survived the event write',
    r.character.second_form.results?.length === 2 && r.character.second_form.hp_rolls?.length === 2);

  const log = (await api('GET', `/characters/${sfId}/events?limit=5`)).body?.events || [];
  const last = log[log.length - 1];
  check('the log says which form took it', last?.kind === 'damage' && last.payload?.note === `took ${bigHit} (Morphus)`
    && last.payload?.form === 'Morphus', JSON.stringify(last?.payload));

  // Undo puts the Morphus back, and still not the Facade.
  const und = await api('POST', `/characters/${sfId}/events/undo`);
  r = await read();
  check('undo restores the Morphus\'s pools and reports them as the second form\'s',
    und.status === 200 && r.second_form.sdc_current === morph0.sdc && r.second_form.hp_current === morph0.hp
    && und.body?.restored?.second_form?.hp_current === morph0.hp && r.character.sdc_current === facade0.sdc,
    JSON.stringify(und.body));
  await press('damage', `took ${bigHit}`, (p) => D.damageCascade(p, bigHit));

  // A guarded replay onto a Morphus pool someone else moved is a conflict, on
  // the form's side, and applies nothing.
  const stale = await api('POST', `/characters/${sfId}/events`, { kind: 'damage', note: 'queued', guard: true,
    changes: { second_form: { hp_current: { from: 12, to: 2 } } } });
  r = await read();
  check('a queued Morphus change onto a moved pool is refused as a conflict on the form',
    stale.status === 409 && stale.body?.form_fields?.hp_current?.theirs === -7 && r.second_form.hp_current === -7,
    JSON.stringify(stale.body));
  const fresh = await api('POST', `/characters/${sfId}/events`, { kind: 'pool', note: 'queued', guard: true,
    changes: { second_form: { hp_current: { from: -7, to: -5 } } } });
  r = await read();
  check('and one whose pool did not move replays', fresh.status === 200 && r.second_form.hp_current === -5,
    JSON.stringify(fresh.body));

  // Rest, capped at the Morphus's OWN maximum and climbing back through zero.
  const rest = await press('pool', 'rested 8h', (p) => ({
    hp_current: p.hp_current + D.restGain(p.hp_current, p.hp_max, 20, 8),
    sdc_current: p.sdc_current + D.restGain(p.sdc_current, p.sdc_max, 5, 8),
  }));
  r = await read();
  check('rest in the Morphus recovers its hit points from below zero to its own maximum, and 40 S.D.C.',
    rest.res.status === 200 && r.second_form.hp_current === morph0.hpMax && r.second_form.sdc_current === 40,
    JSON.stringify({ hp: r.second_form.hp_current, max: morph0.hpMax, sdc: r.second_form.sdc_current }));
  check('and the Facade rested nothing', r.character.sdc_current === facade0.sdc && r.character.hp_current === facade0.hp);

  // The G.M. dashboard's roster carries the active form and its pools.
  const roster = (await api('GET', `/characters?campaign_id=${sfCampId}`)).body?.characters || [];
  const row = roster.find((x) => x.id === sfId);
  check('the campaign roster shows the Morphus active, with its own pools',
    row?.second_form?.active === 'second' && row.second_form.name === 'Morphus'
    && row.second_form.hp_current === morph0.hpMax && row.second_form.sdc_current === 40
    && row.sdc_current === facade0.sdc, JSON.stringify(row?.second_form));
  const plainRoster = (await api('GET', `/characters?campaign_id=${campaignId}`)).body?.characters || [];
  check('a one-body character\'s roster row is unchanged: no second_form',
    plainRoster.length > 0 && plainRoster.every((x) => !('second_form' in x)), JSON.stringify(plainRoster[0]).slice(0, 200));
  const refused = await api('POST', `/characters/${charId}/events`, { kind: 'damage', note: 'x',
    changes: { second_form: { sdc_current: { from: 5, to: 1 } } } });
  check('and the events route refuses a second-form change for a class with none', refused.status === 400,
    JSON.stringify(refused.body));

  // Back to the Facade: nothing moves on the switch, and damage lands there.
  await api('PATCH', `/characters/${sfId}`, { second_form: { active: 'first' } });
  r = await read();
  check('switching to the Facade moves no damage between the forms',
    r.second_form.active === 'first' && r.second_form.sdc_current === 40 && r.character.sdc_current === facade0.sdc);
  const facadeHit2 = await press('damage', 'took 5', (p) => D.damageCascade(p, 5));
  r = await read();
  check('and Damage in the Facade lands on the Facade, leaving the Morphus as it was',
    facadeHit2.res.status === 200 && !facadeHit2.changes.second_form
    && r.character.sdc_current === facade0.sdc - 5 && r.second_form.sdc_current === 40
    && r.second_form.hp_current === morph0.hpMax, JSON.stringify({ facade: r.character.sdc_current, morphus: r.second_form }));
  const facadeLog = (await api('GET', `/characters/${sfId}/events?limit=1`)).body?.events?.[0];
  check('and its log note names no form', facadeLog?.payload?.note === 'took 5' && facadeLog.payload.form === undefined,
    JSON.stringify(facadeLog?.payload));

  const cleanup = join(state, 'f74-cleanup.sql');
  writeFileSync(cleanup, "UPDATE imported_classes SET status = 'draft' WHERE class_id = 'f74-probe';\n", 'utf8');
  const cleaned = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', cleanup]);
  check('the second-body fixture is removed again', cleaned.status === 0, cleanErr(cleaned.stderr || ''));
}

// ── The Morphus generator, through create and back (survey D5, PR 3 of 4) ──
//
// The wizard's generator is js/morphus.js over the rows `catalogs/traits` serves.
// Here the same module builds a Morphus from those served rows - an Animal Form
// combination whose 1D6s send bonuses to one animal, a sub-choice, and
// Stigmata's Biomechanical route with its +1 - and the result goes through the
// create endpoint and back out of the sheet endpoint. smoke.mjs pins the rules;
// this proves the endpoint serves what the engine needs, create accepts what the
// engine sends (`omit` included), and the sheet folds it to the numbers the
// wizard's preview computes from the same inputs.
{
  const fixture = join(state, 'gen-fixture.sql');
  const md = '---\nid: gen-probe\nname: Generator Probe\nsystem: nightbane\nsource_book: Nightbane RPG p.87\n'
    + 'category: rcc\nhit_points_base: "P.E. + 1D6 per level"\nsdc_base: 30\nsecond_form:\n'
    + '  name: "Morphus"\n  first_name: "Facade"\n  bonuses:\n'
    + '    attributes: { PS: 10, PE: 10, Spd: 10, PP: 6 }\n    pools: { sdc: "2d6x10" }\n'
    + '  hit_points_base: "P.E. x2 + 2d6 per level"\n  horror_factor: 6\n  horror_factor_max: 18\n'
    + '  traits_from: morphus\n---\n\n## Lore\n\nA regression fixture for the generator.\n';
  writeFileSync(fixture, "INSERT INTO imported_classes (class_id, name, system, status, markdown, created_by, created_at) "
    + `VALUES ('gen-probe', 'Generator Probe', 'nightbane', 'published', '${md.replace(/'/g, "''")}', 'regression', datetime('now'));\n`, 'utf8');
  const seeded = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', fixture]);
  check('the generator fixture class is seeded', seeded.status === 0, cleanErr(seeded.stderr || seeded.stdout || ''));

  const traits = await api('GET', '/catalogs/traits?catalog=morphus');
  check('catalogs/traits serves every Morphus row, JSON decoded',
    traits.status === 200 && traits.body.rows?.length === 173
    && Array.isArray(traits.body.rows.find((r) => r.key === 'Appearance: Bizarre')?.routes),
    JSON.stringify(traits.body).slice(0, 200));
  const traitsRes = await fetch(BASE + '/catalogs/traits?catalog=morphus');
  const etag = traitsRes.headers.get('etag');
  await traitsRes.arrayBuffer();
  const again = etag ? await fetch(BASE + '/catalogs/traits?catalog=morphus', { headers: { 'If-None-Match': etag } }) : null;
  check('and revalidates to a 304 on its ETag', !!etag && again?.status === 304, `etag ${etag}, status ${again?.status}`);
  const notTraits = await api('GET', '/catalogs/traits?catalog=spells');
  check('but serves no catalog a second form cannot draw on', notTraits.status === 400, JSON.stringify(notTraits.body));

  const { morphusTables, pickNext, decide, chooseSub, morphusResults, replayMorphus } = await import('../js/morphus.js');
  const { secondFormView, rollTraitResult } = await import('../js/second-form.js');
  const T = morphusTables(traits.body.rows || []);
  const atMax = (row) => {
    const real = Math.random;
    Math.random = () => 0.999999;
    try { return rollTraitResult(row); } finally { Math.random = real; }
  };
  const opts = { rollResult: atMax };
  let dec = [];
  for (const key of ['Appearance: Monstrous Lycanthrope', 'Animal Form: Combination of Two', 'Animal Form: Canine',
    'Canine: Were-Canine', 'Animal Form: Arachnid']) dec = pickNext(T, dec, key, opts);
  // Eight bonuses between the two, sorted: PE PP PS Spd attacks initiative perception sdc.
  const d6 = [1, 6, 1, 6, 6, 1, 6, 1].map((v) => (v - 0.5) / 6);
  dec = decide(T, dec, { key: 'Arachnid: Were-Arachnid', how: 'pick' }, { ...opts, rng: () => d6.shift() });
  dec = chooseSub(T, dec, dec.length - 1, 'scorpion');
  for (const key of ['Stigmata: Biomechanical', 'Biomechanical: Armorgraft', 'Nightbane Characteristics: Alien Creature',
    'Alien Shape: Thorns']) dec = pickNext(T, dec, key, opts);
  const results = morphusResults(T, dec);
  check('the engine builds a finished Morphus from the served rows, with an animal\'s bonuses omitted',
    replayMorphus(T, dec).done && results.length === 10 && results.some((r) => Array.isArray(r.omit) && r.omit.length),
    JSON.stringify(replayMorphus(T, dec).problems));

  const genCamp = await api('POST', '/campaigns', { name: 'Regression Generator', system: 'nightbane' });
  const genCampId = genCamp.body.id ?? genCamp.body.campaign?.id;
  const second_form = { active: 'first', form_rolls: { pools: { sdc: 70 } }, hp_rolls: [7], results,
    sdc_current: null, hp_current: null };
  const made = await api('POST', '/characters', {
    campaign_id: genCampId, name: 'Generated', class_id: 'gen-probe', attributes: attrs,
    skills: [], abilities: [], powers: [], pools: { hp: 20, sdc: 30 }, second_form,
  });
  check('a character holding the generated Morphus is created', made.status === 201, JSON.stringify(made.body).slice(0, 300));
  const read = await api('GET', `/characters/${made.body.id}`);
  const stored = read.body?.character?.second_form;
  check('and stores the results exactly as sent, `omit` and sub-choice included',
    JSON.stringify(stored?.results) === JSON.stringify(results) && JSON.stringify(stored?.form_rolls) === '{"pools":{"sdc":70}}',
    JSON.stringify(stored).slice(0, 300));
  const view = read.body?.second_form;
  // The preview's own call, on the class and character the sheet endpoint returned.
  const local = secondFormView({ cls: read.body?.class, character: read.body?.character, rows: T.byKey });
  check('the sheet endpoint folds it to the numbers the wizard previews',
    !!view && view.horror_factor === local.horror_factor && view.sdc_max === local.sdc_max && view.hp_max === local.hp_max
    && JSON.stringify(view.attributes) === JSON.stringify(local.attributes) && view.unrolled.length === 0,
    JSON.stringify({ sheet: [view?.horror_factor, view?.sdc_max, view?.hp_max], wizard: [local.horror_factor, local.sdc_max, local.hp_max] }));
  // P.S. 16 + form 10 + ONE animal's bonus: die 1 on P.S. names the Were-Canine's +4, not +4 + +2.
  // Horror Factor 6 + Were-Canine 5 + Were-Arachnid 6 + Stigmata route 1 + Armorgraft 2 + Thorns 4 = 24, capped 18.
  check('one animal\'s bonus per attribute, and the Horror Factor capped at the form\'s 18',
    view?.attributes?.PS === 30 && view?.horror_factor === 18 && view.horror_factor_parts.added === 18,
    JSON.stringify({ attrs: view?.attributes, hf: view?.horror_factor_parts }));
  check('every result resolves against the catalog, the route rows among them',
    view?.results?.length === 10 && view.results.every((r) => r.found)
    && view.results.some((r) => r.key === 'Stigmata: Biomechanical' && r.table === 'Stigmata'));

  const cleanup = join(state, 'gen-cleanup.sql');
  writeFileSync(cleanup, "UPDATE imported_classes SET status = 'draft' WHERE class_id = 'gen-probe';\n", 'utf8');
  const cleaned = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', cleanup]);
  check('the generator fixture is removed again', cleaned.status === 0, cleanErr(cleaned.stderr || ''));
}

// ── A spell burns P.P.E. out of the caster's base (BOOK-INGEST-AUDIT F101, 3 of 3) ──
//
// Six catalog spells carry `ppe_permanent` (migration 067), filled by a data
// script that must sort AFTER the scripts inserting those spells - so the first
// question is whether a database built from nothing has all six. Then the real
// burn route, on a fixture class that grants three spells outright: two that
// burn and one that does not. Removed again at the end.
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json', '--command', `"${sql}"`]);
    const out = r.stdout || '';
    for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
      try { const v = JSON.parse(out.slice(at)); if (Array.isArray(v)) return v.flatMap((x) => x.results || []); }
      catch { /* wrangler's own log line opens with a bracket too */ }
    }
    return [];
  };
  const burners = q("SELECT name, ppe_permanent FROM spells WHERE ppe_permanent IS NOT NULL ORDER BY name");
  check('a database built from nothing carries all six permanent burns',
    JSON.stringify(burners.map((r) => [r.name, r.ppe_permanent])) === JSON.stringify([
      ['Bone: Return from the Grave', '3'], ['Close Rift', '2'], ['Enchant Weapon (Minor)', '2D4'],
      ['Ley Line Restoration', '6D6'], ['Ley Line Resurrection', '2D6'], ['Nature: Sacred Oath', '2D6']]),
    JSON.stringify(burners));

  const fixture = join(state, 'f101-burner.sql');
  writeFileSync(fixture,
    "INSERT INTO imported_classes (class_id, name, system, status, markdown, created_by, created_at) VALUES ('f101-burner', 'F101 Burner', 'rifts', 'published', '---\nid: f101-burner\nname: F101 Burner\nsystem: rifts\nsource_book: Rifts Book of Magic p.150\ncategory: occ\nhit_points_base: \"P.E. + 1D6 per level\"\nsdc_base: \"3D6\"\nmagic:\n  spells: [\"Close Rift\", \"Ley Line Resurrection\", \"Globe of Daylight\"]\n---\n\n## Lore\n\nA regression fixture.\n', 'regression', datetime('now'));\n",
    'utf8');
  const seeded = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', fixture]);
  check('the spell burn fixture is seeded', seeded.status === 0, cleanErr(seeded.stderr || seeded.stdout || ''));

  const mage = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Rift Closer', class_id: 'f101-burner',
    attributes: attrs, skills: [], abilities: [],
    powers: [{ type: 'spell', name: 'Close Rift', level: 14, cost: 200 },
             { type: 'spell', name: 'Ley Line Resurrection', level: 15, cost: 2000 },
             { type: 'spell', name: 'Globe of Daylight', level: 1, cost: 2 }],
    pools: { hp: 20, sdc: 20, ppe: 10 },
  });
  check('a character holding burning spells is created', mage.status === 201, JSON.stringify(mage.body).slice(0, 300));
  const mageId = mage.body.id;
  const burn = (name) => api('POST', `/characters/${mageId}/ppe-burn`, { name });
  const read = async () => (await api('GET', `/characters/${mageId}`)).body.character || {};

  const rift = await burn('Close Rift');
  check('Close Rift burns its 2 out of the base', rift.status === 200 && rift.body.rolled === 2 && rift.body.burned === 2,
    JSON.stringify(rift.body));
  const afterRift = await read();
  check('which lands in ppe_base_spent, with current clamped to the 8 still fillable',
    afterRift.ppe_base_spent === 2 && afterRift.ppe_max === 10 && afterRift.ppe_current === 8,
    JSON.stringify({ spent: afterRift.ppe_base_spent, max: afterRift.ppe_max, current: afterRift.ppe_current }));

  const res = await burn('Ley Line Resurrection');
  check('a dice burn rolls inside its dice and never burns more than the base has left',
    res.status === 200 && res.body.rolled >= 2 && res.body.rolled <= 12
    && res.body.burned === Math.min(res.body.rolled, 8),
    JSON.stringify(res.body));
  const afterRes = await read();
  check('and the base agrees with what the route reported',
    afterRes.ppe_base_spent === 2 + res.body.burned
    && afterRes.ppe_current === Math.min(8, 10 - afterRes.ppe_base_spent),
    JSON.stringify({ spent: afterRes.ppe_base_spent, current: afterRes.ppe_current, burned: res.body.burned }));

  check('a held spell that burns nothing is refused', (await burn('Globe of Daylight')).status === 400);
  check('and a spell the character does not hold is refused', (await burn('Ley Line Restoration')).status === 400);

  const cleanup = join(state, 'f101-burner-cleanup.sql');
  writeFileSync(cleanup, "UPDATE imported_classes SET status = 'draft' WHERE class_id = 'f101-burner';\n", 'utf8');
  const cleaned = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', cleanup]);
  check('the spell burn fixture is removed again', cleaned.status === 0, cleanErr(cleaned.stderr || ''));
}


// The same fighting style, read at a level the character actually reached.
// Creation is always level 1 (by design), so this drives the real xp and
// level-confirm path - which is also the path that would break if compose
// stopped passing the level through.
if (globalThis.__h2hId) {
  const id = globalThis.__h2hId;
  const gain = await api('POST', `/characters/${id}/xp`, { total: 100000 });
  const target = gain.body?.proposal?.to_level ?? null;
  if (target && target >= 4) {
    await api('POST', `/characters/${id}/level-confirm`, { to_level: target, picks: [] });
    const after = await api('GET', `/characters/${id}`);
    const b = after.body.class?.bonuses?.combat || {};
    // The Expert gains its second attack at level 4 and +2 strike at 3, so any
    // level past 4 must show more than the level 1 grant did.
    check('a levelled Expert has accumulated more of the table',
      after.body.character.level === target && (b.attacks ?? 0) >= 1 && (b.strike ?? 0) >= 2,
      'level ' + after.body.character?.level + ' ' + JSON.stringify(b));
    check('and has more moves to read than at level 1',
      (after.body.skill_level_notes || []).length > globalThis.__h2hNotes1,
      (after.body.skill_level_notes || []).length + ' vs ' + globalThis.__h2hNotes1);
  } else {
    check('the Hand to Hand character can be levelled', false, JSON.stringify(gain.body).slice(0, 200));
  }
}


// ── play mode ───────────────────────────────────────────────────────────────
const before = await api('GET', `/characters/${charId}`);
const hpBefore = before.body.character.hp_current;
const ev = await api('POST', `/characters/${charId}/events`, {
  kind: 'damage', note: 'regression hit',
  changes: { character: { hp_current: { from: hpBefore, to: hpBefore - 5 } } },
});
check('a play event applies and records in one call', ev.status === 200 || ev.status === 201, ev.body);
const afterHit = await api('GET', `/characters/${charId}`);
check('the pool actually moved', afterHit.body.character.hp_current === hpBefore - 5,
  'hp is ' + afterHit.body.character.hp_current + ', expected ' + (hpBefore - 5));

const undone = await api('POST', `/characters/${charId}/events/undo`);
check('the latest event can be undone', undone.status === 200, undone.body);
const restored = await api('GET', `/characters/${charId}`);
check('and the pool is restored', restored.body.character.hp_current === hpBefore,
  'hp is ' + restored.body.character.hp_current + ', expected ' + hpBefore);

// UI-AUDIT F40: a hit that lands on armour, through the same route, and back.
// The armour starts BLANK - undamaged, full - which is the case undo has to
// restore exactly rather than as the number the hit started from.
const armorSet = await api('PATCH', `/characters/${charId}`, {
  armor: [{ name: 'Regression Plate', ar: '', mdc_current: '', mdc_max: '50', weight: '', cost: '', prowl: '' }],
});
check('armour can be set for the hit test', armorSet.status === 200, armorSet.body);
const armorHit = await api('POST', `/characters/${charId}/events`, {
  kind: 'damage', note: 'regression armour hit',
  changes: { armor: { index: 0, mdc_current: { from: 50, to: 30, raw_from: '' } } },
});
check('a hit can land on armour through the events route', armorHit.status === 200, armorHit.body);
const afterArmor = await api('GET', `/characters/${charId}`);
check('and the armour took it', afterArmor.body.character.armor?.[0]?.mdc_current === '30',
  JSON.stringify(afterArmor.body.character.armor));
const armorUndo = await api('POST', `/characters/${charId}/events/undo`);
check('and undo reports what it put back',
  armorUndo.status === 200 && armorUndo.body.restored?.armor?.mdc_current === '', armorUndo.body);
const afterArmorUndo = await api('GET', `/characters/${charId}`);
check('which is exactly what was there - blank, not the 50 the hit started from',
  afterArmorUndo.body.character.armor?.[0]?.mdc_current === '',
  JSON.stringify(afterArmorUndo.body.character.armor));
const noArmor = await api('POST', `/characters/${charId}/events`, {
  kind: 'damage', changes: { armor: { index: 7, mdc_current: { from: 1, to: 0 } } },
});
check('a hit on armour the character does not have is refused', noArmor.status === 404, noArmor.status);

// ...and one that lands on a vessel location. A vessel arrives undamaged - no
// key for the location at all - and undo has to leave it that way, not write
// the maximum back in. The codex nests each vessel's locations; the first with
// a printed maximum is the target.
{
  const codexVessels = await api('GET', '/codex?section=vehicles');
  const targetVessel = (codexVessels.body.vehicles || [])
    .find((v) => (v.locations || []).some((l) => l.mdc != null));
  if (targetVessel) {
    const loc = targetVessel.locations.find((l) => l.mdc != null);
    const added = await api('POST', `/characters/${charId}/vehicles`, { slug: targetVessel.slug });
    check('a vessel can be added for the hit test', added.status === 201, added.body);
    const vid = added.body.vehicle?.id;
    const vHit = await api('POST', `/characters/${charId}/events`, {
      kind: 'damage', note: 'regression vessel hit',
      changes: { vehicle: { id: vid, location: loc.location, mdc: { from: loc.mdc, to: loc.mdc - 10, absent: true } } },
    });
    check('a hit can land on a vessel location', vHit.status === 200, vHit.body);
    const vAfter = (await api('GET', `/characters/${charId}`)).body.vehicles?.find((v) => v.id === vid);
    check('and the location took it', vAfter?.mdc_current?.[loc.location] === loc.mdc - 10,
      JSON.stringify(vAfter?.mdc_current));
    const vUndo = await api('POST', `/characters/${charId}/events/undo`);
    const vBack = (await api('GET', `/characters/${charId}`)).body.vehicles?.find((v) => v.id === vid);
    check('and undo leaves the location untouched again, not written back at its maximum',
      vUndo.status === 200 && !Object.prototype.hasOwnProperty.call(vBack?.mdc_current || {}, loc.location),
      JSON.stringify(vBack?.mdc_current));
    const badLoc = await api('POST', `/characters/${charId}/events`, {
      kind: 'damage', changes: { vehicle: { id: vid, location: 'No Such Part', mdc: { from: 1, to: 0 } } },
    });
    check('a hit on a location the vessel does not have is refused', badLoc.status === 400, badLoc.status);
  } else {
    check('the scratch catalog has a vessel with a numbered location to hit', false,
      'no vessel with a numeric location maximum');
  }
}

// UI-AUDIT F48: the codex reads skills and classes as well. Classes travel as a
// SUMMARY - the check that no row carries its markdown is the one that keeps
// ~750KB of class text out of a page meant for reading.
{
  const cxIndex = await api('GET', '/codex?section=index');
  check('the codex counts skills and classes',
    typeof cxIndex.body.counts?.skills === 'number' && typeof cxIndex.body.counts?.classes === 'number',
    cxIndex.body.counts);
  const cxSkills = await api('GET', '/codex?section=skills');
  check('the codex serves every skill it counts',
    cxSkills.status === 200 && cxSkills.body.skills?.length === cxIndex.body.counts?.skills,
    `${cxSkills.body.skills?.length} vs ${cxIndex.body.counts?.skills}`);
  const cxClasses = await api('GET', '/codex?section=classes');
  const first = cxClasses.body.classes?.[0] || {};
  check('and every published class it counts',
    cxClasses.status === 200 && cxClasses.body.classes?.length === cxIndex.body.counts?.classes,
    `${cxClasses.body.classes?.length} vs ${cxIndex.body.counts?.classes}`);
  check('as a summary - a name and a type on every row, and no markdown',
    (cxClasses.body.classes || []).every((c) => c.name && c.category) && !('markdown' in first),
    JSON.stringify(first).slice(0, 200));
}

const events = await api('GET', `/characters/${charId}/events`);
check('the event log still holds the undone event',
  events.status === 200 && events.body.events.some((e) => e.undone_at), events.body.events?.length);

// ── journal, draft, lists, admin ────────────────────────────────────────────
console.log('\n[6/7] Journal, drafts, lists, admin');
const entry = await api('POST', '/journal', { character_id: charId, title: 'Session 1', body: 'It happened.' });
check('a journal entry is written', entry.status === 201 || entry.status === 200, entry.body);
const journal = await api('GET', `/journal?campaign_id=${campaignId}`);
check('and read back', journal.status === 200 && journal.body.entries.length > 0, journal.body);
check('journal paging reports its shape',
  typeof journal.body.total === 'number' && typeof journal.body.limit === 'number', journal.body);

// A draft is one row per person, so every PUT is a replace. The guard is what
// stops a second tab - or a script driving the wizard - silently discarding a
// build in progress.
const draftPut = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 2, state: { x: 1 }, expect_updated_at: null });
check('a wizard draft is created when none exists', draftPut.status === 200 || draftPut.status === 201, draftPut.body);
check('and the save reports the new version', !!draftPut.body.updated_at, draftPut.body);
const draftGet = await api('GET', '/draft');
check('and it reads back', draftGet.status === 200 && !!draftGet.body.draft, draftGet.body);

// The case that cost a real draft: a caller that does not say which version
// it is replacing must not be allowed to replace anything.
const blind = await api('PUT', '/draft', { system: 'rifts', class_id: cls.id, step: 9, state: { clobbered: true } });
check('a PUT claiming no version is REFUSED when a draft exists', blind.status === 409, blind.status);
check('and the refusal says what is there now',
  blind.status === 409 && !!blind.body.conflict && !!blind.body.current, blind.body);

const stale = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 9, state: { clobbered: true },
  expect_updated_at: '1999-01-01 00:00:00' });
check('a PUT claiming a STALE version is refused', stale.status === 409, stale.status);

const survived = await api('GET', '/draft');
check('and neither refusal changed the stored draft',
  survived.body.draft?.step === 2 && survived.body.draft?.state?.x === 1,
  survived.body.draft);

const correct = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 4, state: { x: 2 },
  expect_updated_at: survived.body.draft.updated_at });
check('a PUT claiming the CURRENT version succeeds', correct.status === 200, correct.body);
const moved = await api('GET', '/draft');
check('and it actually replaced the draft', moved.body.draft?.step === 4, moved.body.draft);

const draftDel = await api('DELETE', '/draft');
check('a draft can be deleted', draftDel.status === 200, draftDel.body);
check('leaving none', (await api('GET', '/draft')).body.draft === null);
const afterDelete = await api('PUT', '/draft', {
  system: 'rifts', class_id: cls.id, step: 1, state: { fresh: true }, expect_updated_at: null });
check('and a fresh build can then create one again', afterDelete.status === 200, afterDelete.body);
await api('DELETE', '/draft');

const list = await api('GET', `/characters?campaign_id=${campaignId}`);
check('the character list is paged', list.status === 200 && typeof list.body.total === 'number', list.body);
const nonsense = await api('GET', '/characters?limit=banana');
check('a nonsense limit falls back rather than 400ing',
  nonsense.status === 200 && nonsense.body.limit === 200, nonsense.body.limit);

// ?mine=1 keeps the caller's own (UI-AUDIT F39) - the home view's list. Every
// other call in this file is the same caller, so the first check alone would
// pass with the filter doing nothing; the second identity is what proves it.
const mineList = await api('GET', '/characters?mine=1');
check('?mine=1 lists only the caller\'s own characters',
  mineList.status === 200 && mineList.body.characters.length > 0
    && mineList.body.characters.every((c) => c.player_email === me.body.email),
  mineList.body.characters?.map((c) => c.player_email));
const asStranger = (path) => fetch(BASE + path, {
  headers: { 'Cf-Access-Authenticated-User-Email': 'nobody-f39@example.com' },
}).then((r) => r.json());
const strangerAll = await asStranger('/characters');
const strangerMine = await asStranger('/characters?mine=1');
check('someone with no characters sees everyone\'s unfiltered',
  strangerAll.total > 0, strangerAll.total);
check('and none of them with ?mine=1',
  Array.isArray(strangerMine.characters) && strangerMine.characters.length === 0
    && strangerMine.total === 0, strangerMine);

// UI-AUDIT F52: the table's rest rates live on the campaign, set by its G.M.
// A zero is dropped, a pool that is not one is refused, and null clears.
{
  const setRates = await api('PATCH', `/campaigns/${campaignId}`, { rest_rates: { hp: 2, ppe: 5, isp: 0 } });
  check('a GM can set the campaign\'s rest rates', setRates.status === 200, setRates.body);
  const camp = await api('GET', `/campaigns/${campaignId}`);
  check('and they are stored without the zero',
    camp.body.campaign?.rest_rates === JSON.stringify({ hp: 2, ppe: 5 }), camp.body.campaign?.rest_rates);
  const inCamp = (await api('GET', `/characters?campaign_id=${campaignId}`)).body.characters?.[0];
  if (inCamp) {
    const sheet = await api('GET', `/characters/${inCamp.id}`);
    check('and a sheet in that campaign receives them, decoded',
      sheet.body.character?.campaign_rest_rates?.hp === 2 && sheet.body.character?.campaign_rest_rates?.ppe === 5,
      JSON.stringify(sheet.body.character?.campaign_rest_rates));
  }
  const badPool = await api('PATCH', `/campaigns/${campaignId}`, { rest_rates: { stamina: 3 } });
  check('a rate for something that is not a pool is refused', badPool.status === 400, badPool.status);
  const cleared = await api('PATCH', `/campaigns/${campaignId}`, { rest_rates: null });
  const after = await api('GET', `/campaigns/${campaignId}`);
  check('and null clears them', cleared.status === 200 && after.body.campaign?.rest_rates === null,
    after.body.campaign?.rest_rates);
}

// ── creation-time validation (the audit's F2) ───────────────────────────────
// The powers a character is created holding get the boundary level-up picks
// always had; pool maxima and attributes get advisory range checks that
// surface in the admin audit rather than blocking anything.
{
  const llw = classes.body.classes.find((c) => c.id === 'ley-line-walker');
  check('the Ley Line Walker is available to craft against', !!llw, 'no ley-line-walker');
  const allowedLevels = new Set(llw?.magic?.spell_levels_allowed || []);
  const auto = new Set((llw?.magic?.spells || []).map((n) => String(n).toLowerCase()));
  const usable = (s) => (!s.system || s.system === 'rifts' || s.system === 'both')
    && !auto.has(String(s.name).toLowerCase());
  // Legal means inside the level cap AND outside every spell tradition: the
  // walker states no spell_traditions_allowed, so a warlock or ocean spell at
  // level 1-4 is refused (BOOK-INGEST-AUDIT F57). Before F57 this pool was
  // levels only, and its first two picks were warlock spells.
  const inCap = catalogs.body.spells.filter((s) => usable(s) && allowedLevels.has(s.level) && !s.tradition);
  const foreign = catalogs.body.spells.find((s) => usable(s) && allowedLevels.has(s.level) && s.tradition);
  const overCap = catalogs.body.spells.find((s) => usable(s) && s.level > Math.max(...allowedLevels));
  const spell = (s) => ({ type: 'spell', name: s.name, level: s.level, cost: s.ppe });
  const base = (extra) => ({
    campaign_id: campaignId, class_id: 'ley-line-walker',
    attributes: attrs, skills: [], abilities: [], bio: { alignment: 'Principled' }, ...extra,
  });

  const starting = Number(llw?.magic?.spells_starting) || 0;
  const over = await api('POST', '/characters',
    base({ name: 'Greedy Caster', powers: inCap.slice(0, starting + 1).map(spell) }));
  check('one spell over the starting allowance is refused',
    over.status === 422 && over.body.violations?.some((v) => v.rule === 'power_count'),
    JSON.stringify(over.body).slice(0, 250));

  const high = await api('POST', '/characters',
    base({ name: 'Overreaching Caster', powers: [spell(overCap)] }));
  check('a spell above the allowed levels is refused',
    high.status === 422 && high.body.violations?.some((v) => v.rule === 'power_level_cap'),
    JSON.stringify(high.body).slice(0, 250));

  const fake = await api('POST', '/characters',
    base({ name: 'Inventive Caster', powers: [{ type: 'spell', name: 'Spell Of My Own Devising' }] }));
  check('a spell the catalog does not hold is refused',
    fake.status === 422 && fake.body.violations?.some((v) => v.rule === 'power_unknown'),
    JSON.stringify(fake.body).slice(0, 250));

  // The server refuses what the picker hides (BOOK-INGEST-AUDIT F57): a
  // warlock spell inside the walker's levels is a tradition it does not allow.
  check('the catalog carries a tagged spell inside the walker\'s levels', !!foreign, 'no tagged spell at levels 1-4');
  const foreignPick = foreign && await api('POST', '/characters',
    base({ name: 'Borrowing Caster', powers: [spell(foreign)] }));
  check('a spell from a tradition the class does not allow is refused',
    foreignPick?.status === 422 && foreignPick.body.violations?.some((v) => v.rule === 'power_tradition'),
    JSON.stringify(foreignPick?.body).slice(0, 250));

  const legit = await api('POST', '/characters',
    base({ name: 'Honest Caster', powers: inCap.slice(0, Math.min(2, starting)).map(spell),
           pools: { hp: 9999, ppe: 20 } }));
  check('a legal pick within the allowance still creates',
    legit.status === 201, JSON.stringify(legit.body).slice(0, 250));

  // The description of a power the character HOLDS rides with the character,
  // so the sheet can open it in place with no second request at a table. The
  // catalog seed carries no description text, so this writes one through the
  // admin route rather than hoping a seeded row has some — which also proves
  // the join is live rather than a snapshot taken when the character was made.
  if (legit.status === 201) {
    const held = inCap.slice(0, Math.min(2, starting))[0];
    const before = await api('GET', `/characters/${legit.body.id}`);
    check('a character carries a power_descriptions map',
      before.status === 200 && before.body.power_descriptions
      && typeof before.body.power_descriptions === 'object',
      Object.keys(before.body || {}).join(', '));

    if (held) {
      const rows = await api('GET', '/catalogs/rows?catalog=spells');
      const row = (rows.body.rows || []).find((r) => r.name === held.name);
      const text = 'A test description, written by the regression suite.';
      const wrote = await api('PATCH', `/catalogs/rows?catalog=spells&id=${row?.id}`, { description: text });
      check('a spell can be given description text', wrote.status === 200, wrote.body);

      const after = await api('GET', `/characters/${legit.body.id}`);
      check('and a character holding that spell is sent the text',
        after.body.power_descriptions?.[held.name.toLowerCase()] === text,
        JSON.stringify(after.body.power_descriptions || {}).slice(0, 200));
      check('keyed by the lowercased name the character holds',
        Object.keys(after.body.power_descriptions || {}).every((k) => k === k.toLowerCase()),
        Object.keys(after.body.power_descriptions || {}).join(', '));
      // A power the catalog has no text for is ABSENT rather than present and
      // empty — the sheet decides whether a row is expandable on that.
      check('and a power with no text is absent rather than empty',
        !Object.values(after.body.power_descriptions || {}).some((v) => !v),
        JSON.stringify(after.body.power_descriptions || {}).slice(0, 200));
    }
  }

  // Out-of-range pools and over-ceiling attributes create fine FOR THE GM —
  // dev@localhost made this campaign, and a GM ruling beats a computed number
  // — and the audit below is where the warnings surface. 'Honest Caster'
  // above (hp 9999, created 201) is the GM half of the pool tolerance.
  const strong = await api('POST', '/characters',
    base({ name: 'Implausibly Strong', attributes: { ...attrs, PS: 45 } }));
  check('an attribute above its dice ceiling still creates',
    strong.status === 201, JSON.stringify(strong.body).slice(0, 250));

  // The pool hard cap (F2 follow-up): the same impossible maximum that the GM
  // may assert refuses anyone else. player2 is already a member (the join-gate
  // section seated them), so the gate is not what refuses here.
  const inflated = await apiAs('player2@example.com', 'POST', '/characters',
    base({ name: 'Inflated Chair', pools: { hp: 9000 } }));
  check('a non-GM creator with an impossible pool maximum is refused',
    inflated.status === 422 && inflated.body.violations?.some((v) => v.rule === 'pool_out_of_range'),
    JSON.stringify(inflated.body).slice(0, 250));
}

const audit = await api('GET', '/admin/audit');
check('the admin audit runs', audit.status === 200, audit.body);
// This used to read `audit.body.characters`, a field the response has never
// had, and so asserted nothing at all. The response's own vocabulary:
// `blocked` counts characters with violations, and warnings surface offenders
// without blocking anyone.
check('and no character in a fresh database would be refused on save',
  audit.status === 200 && audit.body.blocked === 0,
  JSON.stringify(audit.body.offenders || []).slice(0, 300));
check('the audit surfaces the out-of-range pool as a warning',
  (audit.body.by_rule?.pool_out_of_range || 0) >= 1, JSON.stringify(audit.body.by_rule));
check('and the over-ceiling attribute',
  (audit.body.by_rule?.attribute_above_ceiling || 0) >= 1, JSON.stringify(audit.body.by_rule));

console.log('\n' + '[7/7] Checks that only a database can make');
{
  const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
  const WORDS = {
    one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8,
    nine: 9, ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14,
    fifteen: 15, sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19,
    twenty: 20, thirty: 30, forty: 40, fifty: 50, sixty: 60, seventy: 70,
    eighty: 80, ninety: 90,
    // The catalog crossed a hundred classes with the Juicer Uprising import,
    // and this vocabulary stopped at ninety-nine. `hundred` is the only
    // MULTIPLICATIVE word here - everything above sums - so it needs the
    // handling below rather than an entry that would make one-hundred-four
    // read as 105.
    hundred: 100,
  };
  // Hyphenated compounds sum their parts, so "thirty-seven" does not have to be
  // listed and neither does the next count. Listing each compound means the
  // list goes stale exactly when the number changes - which is the moment this
  // check is supposed to fire.
  const word = (w) => {
    // "and" is punctuation in a number word, not a value: one-hundred-and-four.
    const parts = String(w).toLowerCase().split('-').filter((p) => p !== 'and');
    if (!parts.every((p) => p in WORDS)) return undefined;
    let total = 0;
    let run = 0;
    for (const p of parts) {
      if (p === 'hundred') { total += (run || 1) * 100; run = 0; } else { run += WORDS[p]; }
    }
    return total + run;
  };

  const { parseClassMarkdown } = await import(
    pathToFileURL(join(appDir, 'js', 'parser.js')).href);

  const listed = await api('GET', '/classes');
  const classes = (listed.body.classes || []);
  check('the class list is readable for counting', classes.length > 0, listed.body);

  // An M.D.C. being tracks M.D.C. INSTEAD of hit points, so its silence is a
  // statement and the core-rules default deliberately skips it.
  let silent = 0;
  for (const c of classes) {
    if (c.mdc_base != null) continue;
    if (c.hit_points_base == null) silent++;
  }

  const claim = readme.match(/([A-Za-z-]+) of ([A-Za-z-]+) published classes state no hit point/);
  check('the README still states the hit-point-silence count', !!claim,
    'the sentence changed shape');
  if (claim) {
    check('and the number of published classes matches the database',
      word(claim[2]) === classes.length,
      'README says ' + claim[2] + ' (' + word(claim[2]) + '), database has ' + classes.length);
    check('and the count of classes stating no hit point formula matches',
      word(claim[1]) === silent,
      'README says ' + claim[1] + ' (' + word(claim[1]) + '), database has ' + silent);
  }

  // Every named spell list must still resolve, or the README's "all 34 resolve
  // now" becomes the next stale claim.
  //
  // WIDENED FOR RETRO-AUDIT R20, in the PR that renamed eight spells. This loop
  // used to walk TWO class ids - shifter and ley-line-rifter - so the eleven
  // classes carrying 134 elemental spell citations sat outside it entirely, and
  // renaming a Warlock spell could break every Warlock in the catalog without
  // turning this red. It now walks every published class.
  //
  // The per-class fetch went with it. `GET /classes` already returns fully
  // parsed classes - `names=1` is the roster variant - so the extra request per
  // id was re-fetching what was already in hand.
  //
  // THE LIST KEYS ARE NOT GUESSED. `parser.js` deliberately does not enumerate
  // the magic block's keys, so they were measured off the corpus instead: three
  // keys hold names a class DRAWS FROM - spell_lists.<level> (4,850 names),
  // spells_from (182) and spells_per_level_from (71). `magic.spells` also holds
  // names but is a different question - what a class is GIVEN, not what it may
  // draw from - and folding it in here would quietly change what this check
  // asserts.
  const catalogs = await api('GET', '/catalogs');
  const norm = (x) => String(x).toLowerCase().replace(/&/g, 'and')
    .replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();
  const exact = (x) => String(x).toLowerCase();
  const haveSpell = new Set((catalogs.body.spells || []).map((r) => norm(r.name)));
  const haveSpellExact = new Set((catalogs.body.spells || []).map((r) => exact(r.name)));

  let unresolved = [], inexact = [], spellNamesSeen = 0, classesWithLists = 0;
  for (const cls of classes) {
    if (!cls || !cls.magic) continue;
    const lists = { ...(cls.magic.spell_lists || {}) };
    if (cls.magic.spells_per_level_from) lists.spells_per_level_from = cls.magic.spells_per_level_from;
    if (cls.magic.spells_from) lists.spells_from = cls.magic.spells_from;
    if (!Object.keys(lists).length) continue;
    classesWithLists++;
    for (const [listName, list] of Object.entries(lists)) {
      for (const n of (Array.isArray(list) ? list : [])) {
        if (typeof n !== 'string') continue;
        spellNamesSeen++;
        if (!haveSpell.has(norm(n))) unresolved.push(cls.id + '/' + listName + ': ' + n);
        else if (!haveSpellExact.has(exact(n))) inexact.push(cls.id + '/' + listName + ': ' + n);
      }
    }
  }
  check('every named spell list resolves against the catalog',
    unresolved.length === 0, unresolved.slice(0, 6).join('; '));

  // AND ON THE NAME THE APP ACTUALLY COMPARES. norm() folds & to "and" and
  // strips punctuation, which is LOOSER than every path that resolves a spell
  // citation for real: catalogs.js sends plain names, app.js filters a class's
  // named list by exact lowercased name, and loadPowerCatalog matches NOCASE.
  // None of them sees catalog_redirects. So a citation differing from the
  // catalog only in punctuation would pass the check above and still 422 a
  // level-up confirm in both directions. That gap is what R20's premise audit
  // found.
  //
  // BOTH CHECKS WERE PROVED BY MAKING THEM FAIL, one case each, and the first
  // case chosen was wrong in a way worth recording: reverting one citation to
  // "Fire: Heat Object/Boil Water" turned the NORMALISED check red, not this
  // one, because norm() maps & to the WORD "and" rather than deleting it - so
  // "object and boil" and "object boil" do not collide after all. What only
  // this check sees is punctuation norm() strips outright: dropping the colon
  // from "Water: Swim as a Fish: Superior" left the check above green and this
  // one red, across all seven of that class's cumulative level lists.
  check('and resolves on the EXACT name the app compares, not a normalised one',
    inexact.length === 0, inexact.slice(0, 6).join('; '));

  // A check that examined nothing would pass both of the above. These floors are
  // MEASURED: 18 published classes carry a draw-from list and the three keys
  // hold 5,103 names between them. The first version of this line said 25
  // classes, reasoning from the 40 that carry a magic block - and went red on
  // its own first run, which is the whole argument for asserting a floor rather
  // than trusting that the loop found something. Set under the real figures so
  // adding a caster does not turn it red.
  check('and it examined enough of the corpus to mean anything',
    classesWithLists >= 15 && spellNamesSeen >= 4500,
    classesWithLists + ' classes with lists, ' + spellNamesSeen + ' names seen');

  // -- every only/except name must match a real skill row --------------------
  //
  // js/parser.js matches a restriction against the skill name as a raw
  // normalised string, and it runs in the BROWSER, where catalog_redirects is
  // not available - catalogs.js never sends it. So a restriction naming a row
  // that does not exist fails silently, in whichever direction is worse:
  //
  //   except: ["X"]  ->  excludes nothing, the class grants MORE than the book
  //   only:   ["X"]  ->  narrows to nothing, the class grants nothing
  //
  // The Shifter shipped that way: it excluded "Military: Jet Fighters" while
  // the catalog row was "Jet Fighters", so the exclusion excluded nothing and
  // the Shifter could take a skill the book denies it. Nothing reported it.
  const skillNames = new Set((catalogs.body.skills || []).map((r) => norm(r.name)));
  const dead = [];
  for (const c of classes) {
    const groups = [
      ...(c.skills?.occ_skills || []),
      c.skills?.occ_related_skills,
      c.skills?.secondary_skills,
    ].filter(Boolean);
    // Restrictions ride on the CATEGORY entries as well as the group: a
    // category is either a plain string or an object carrying only/except.
    const entries = [];
    for (const g of groups) {
      entries.push(g);
      for (const cat of (Array.isArray(g.categories) ? g.categories : [])) {
        if (cat && typeof cat === 'object') entries.push(cat);
      }
    }
    for (const e of entries) {
      for (const key of ['only', 'except']) {
        for (const n of (Array.isArray(e[key]) ? e[key] : [])) {
          if (!skillNames.has(norm(n))) dead.push(`${c.id} ${key}: "${n}"`);
        }
      }
    }
  }

  // Two are deliberate and documented: the Priest of Light names W.P. Siege and
  // W.P. Large Axes ahead of those rows existing, and says so in its own note.
  // They activate by themselves when the rows arrive. The audit floor is two,
  // not zero - so this pins the NAMES, not just the count, and a third dead
  // restriction fails the run.
  //
  // It was three. W.P. Lance was the third, and add-knight-class.sql created
  // that row - so the placeholder did exactly what the note said it would and
  // stopped being dead. The floor comes down with it: leaving it at three would
  // mean the suite went red for a placeholder resolving, which is the outcome
  // the design was aiming at.
  const ALLOWED = new Set(['W.P. Siege', 'W.P. Large Axes']);
  const unexpected = dead.filter((d) => ![...ALLOWED].some((a) => d.includes(`"${a}"`)));
  check('every skill restriction names a skill that exists',
    unexpected.length === 0, unexpected.slice(0, 8).join('; '));
  check('and the two documented placeholders are still the only exceptions',
    dead.length === unexpected.length + 2,
    `${dead.length} dead, ${unexpected.length} unexpected`);

  // -- who has an MOS, and how many packages ---------------------------------
  //
  // A count in a comment goes stale silently, and both written records of this
  // one were wrong at once: parser.js said the Technical Officer offered five
  // where it offers seven, and the README said the Robot Pilot offered two
  // where it had NONE - it carried its packages as GM prose plus a note saying
  // the schema could not hold them, which it could.
  //
  // This lives here rather than in smoke.mjs because the answer is a property
  // of the COMPOSED class, and the Merc Soldier's and Robot Pilot's arrive by
  // correction rather than at import: no single file has the answer.
  const MOS_PACKAGES = {
    'coalition-technical-officer': 7,
    'merc-soldier': 7,
    'robot-pilot': 2,
    // Both Wormwood, and both arrived by correction the same way the two above
    // did - RETRO-AUDIT R2. The demon-goblin's three R.C.C. skill packages
    // (printed 123-124) and the monk's three Areas of Mastery (printed 60-61)
    // sat in prose under a note saying the app could not grant skills on a
    // choice, which stopped being true when 031-character-mos.sql landed.
    'demon-goblin': 3,
    'monk': 3,
    // Underseas, and the only one of the five that arrived WITH its MOS
    // block rather than by a later correction - the book prints nine Navy
    // specialties as part of the O.C.C. itself, so it needed no fixing up.
    'navy-seaman': 9,
    // ---- Heroes Unlimited's eleven EDUCATIONAL LEVELS, printed 27 ----------
    //
    // The first classes to use an MOS for what the key was always shaped for
    // and could not do: `choose` above one. Every class above states
    // `choose: 1`, which is why BOOK-INGEST-AUDIT.md F82 - `choose` validated
    // and read by nothing - survived the whole of the key's life unnoticed.
    //
    // THE COUNTS ARE THE POINT, and they are not all sixteen. The book prints
    // sixteen skill programs and printed 27's Special Restrictions cut each
    // level's list down: 7) High School may take only six named programs; 1)
    // Espionage only for Military Specialist and Trade School; 6) the Military
    // program only for Military, Military Specialist and Trade School; 5)
    // Pilot Advanced for those three plus Doctorate. Trade School is the only
    // level all three admit, so it alone offers all sixteen. A number here
    // drifting toward 16 means a restriction has been lost.
    'hu-edu-high-school': 6,
    'hu-edu-military': 15,
    'hu-edu-trade-school': 16,
    'hu-edu-one-year-college': 13,
    'hu-edu-two-years-college': 13,
    'hu-edu-three-years-college': 13,
    'hu-edu-four-years-college': 13,
    'hu-edu-military-specialist': 16,
    'hu-edu-bachelors': 13,
    'hu-edu-masters': 13,
    'hu-edu-doctorate': 14,
  };
  // How many programs each level GRANTS, which is the half `choose` holds and
  // the half that did nothing before F82. Pinned separately from the option
  // counts above: a level offering the right list and granting the wrong
  // number is the exact failure F82 describes, and it is invisible in a
  // composed class.
  const MOS_CHOOSE = {
    'hu-edu-high-school': 2, 'hu-edu-military': 2, 'hu-edu-trade-school': 2,
    'hu-edu-one-year-college': 2, 'hu-edu-two-years-college': 2,
    'hu-edu-three-years-college': 3, 'hu-edu-four-years-college': 3,
    // ONE, and it is not a typo. Printed 27 restriction 2 gives the Military
    // Specialist six espionage skills and four W.P.s outright - those are in
    // `occ_skills` - and then ONE whole program on top, which may be Espionage
    // again for twelve espionage skills in total.
    'hu-edu-military-specialist': 1,
    'hu-edu-bachelors': 3, 'hu-edu-masters': 3, 'hu-edu-doctorate': 4,
  };
  for (const [id, want] of Object.entries(MOS_CHOOSE)) {
    const cls = classes.find((c) => c.id === id);
    check(`${id} grants ${want} skill program${want === 1 ? '' : 's'}`,
      cls?.skills?.mos?.choose === want, `found ${cls?.skills?.mos?.choose}`);
  }
  // And it actually COMPOSES that way, which is the thing `choose` could not do
  // before F82 and the reason the counts above are not enough on their own: a
  // class may declare four and grant one, which is exactly what every class
  // with an MOS did until 2026-09-14.
  {
    const doc = classes.find((c) => c.id === 'hu-edu-doctorate');
    const mut = classes.find((c) => c.id === 'hu-mutants');
    if (doc && mut) {
      const nameCount = (c) => (c.skills.occ_skills || []).filter((e) => e.name).length;
      const bare = composeClass({ rcc: mut, occ: doc, character: {} });
      const four = composeClass({ rcc: mut, occ: doc,
        character: { mos: ['communications', 'computer', 'medical', 'science'] } });
      // 8 Communications + 2 Computer + 4 Medical (Medical Doctor included at
      // this level) + 1 Science = 15 on top of the three automatic skills.
      check('a Doctorate composes all FOUR chosen programs, not one',
        nameCount(four) - nameCount(bare) === 15,
        `added ${nameCount(four) - nameCount(bare)} named skills`);
      check('and Medical Doctor is among them - only Masters and Doctorate get it',
        (four.skills.occ_skills || []).some((e) => e.name === 'Medical Doctor'));
      // The percentage is THIS BOOK's, not the catalog's. Computer Operation is
      // 60% in Heroes Unlimited and 40% in the catalog; +35% educational bonus
      // makes 95. A 75 here would mean the catalog's number leaked in.
      const co = (four.skills.occ_skills || []).find((e) => e.name === 'Computer Operation');
      check("and carries the book's own percentage, not the catalog's",
        co?.base === 95, `Computer Operation base ${co?.base}`);
      // The stored form and the pre-F82 form both still read.
      const asText = composeClass({ rcc: mut, occ: doc,
        character: { mos: '["communications","computer","medical","science"]' } });
      check('the JSON-text form characters.mos stores composes identically',
        nameCount(asText) === nameCount(four));
      const one = composeClass({ rcc: mut, occ: doc, character: { mos: 'computer' } });
      check('and a bare pre-F82 string still grants its one package',
        nameCount(one) - nameCount(bare) === 2);
    }
  }
  for (const [id, want] of Object.entries(MOS_PACKAGES)) {
    const cls = classes.find((c) => c.id === id);
    check(`${id} still exists`, !!cls);
    const opts = cls?.skills?.mos?.options;
    check(`and offers ${want} MOS packages`, Array.isArray(opts) && opts.length === want,
      `found ${opts ? opts.length : 'no mos block'}`);
    // Every package has to grant something, or choosing it is a no-op the
    // player cannot tell apart from choosing nothing.
    check('and every one of them grants at least one skill',
      (opts || []).every((o) => Array.isArray(o.skills) && o.skills.length > 0),
      (opts || []).filter((o) => !o.skills?.length).map((o) => o.id).join(', '));
  }
  // Nothing else may claim an MOS the list does not know about.
  const withMos = classes.filter((c) => c.skills?.mos).map((c) => c.id).sort();
  check('and no other class has one',
    withMos.join() === Object.keys(MOS_PACKAGES).sort().join(),
    'classes with an MOS: ' + withMos.join(', '));

  // -- totems (BOOK-INGEST-AUDIT F56) ----------------------------------------
  //
  // The nine Spirit West O.C.C.s that pick a totem carry the key - the Totem
  // Warrior alone with powers - and nothing else claims one. The Elemental
  // Shaman picks an ELEMENT (printed 65) and must not be among them.
  const TOTEM_CLASSES = ['animal-shaman', 'fetish-shaman', 'healing-shaman', 'mask-shaman',
    'mystic-warrior', 'paradox-shaman', 'plant-shaman', 'totem-warrior', 'tribal-warrior'];
  const withTotem = classes.filter((c) => c.totem).map((c) => c.id).sort();
  check('exactly the nine Spirit West classes pick a totem',
    withTotem.join() === TOTEM_CLASSES.join(), 'classes with a totem: ' + withTotem.join(', '));
  check('and only the Totem Warrior sees its powers',
    classes.filter((c) => c.totem?.powers === true).map((c) => c.id).join() === 'totem-warrior');

  // -- mega-damage conversion (BOOK-INGEST-AUDIT F62) -------------------------
  //
  // The Totem Warrior's supernatural P.E. turns its S.D.C. and hit points into
  // one M.D.C. total, permanently. The Psycho-Stalker's conversion is temporary
  // and the Spirit Warrior's rides on two of its realms (F64), so neither may
  // carry the class-wide flag.
  const converting = classes.filter((c) => c.mdc_from_hp_sdc === true).map((c) => c.id).sort();
  check('only the Totem Warrior turns S.D.C. and hit points into M.D.C.',
    converting.join() === 'totem-warrior', 'classes with the flag: ' + converting.join(', '));
  // F64: the Spirit Warrior's rides on its Earth and Plant realms instead, and
  // arrives only when one is chosen. Asked of the real composer.
  {
    const { composeClass: compose } = await import(pathToFileURL(join(appDir, 'js', 'compose.js')).href);
    const { convertsToMdc } = await import(pathToFileURL(join(appDir, 'js', 'leveling.js')).href);
    const sw = classes.find((x) => x.id === 'spirit-warrior');
    const converts = (...realms) => !!sw
      && convertsToMdc(compose({ rcc: sw, character: { abilities: realms.map((r) => `Powers of the ${r} Realm`) } }));
    check('a Spirit Warrior with the Earth or Plant realm converts S.D.C. and hit points into M.D.C.',
      converts('Earth', 'Air', 'Fire') && converts('Plant', 'Water', 'Animal') && converts('Earth', 'Plant', 'Air'));
    check('and one with neither does not',
      !!sw && !converts('Air', 'Fire', 'Water') && !convertsToMdc(compose({ rcc: sw })));
  }

  // -- and changing that choice has to re-roll the pools (F67) ----------------
  //
  // Whether the wizard clears them is pinned in smoke; what this checks is the
  // DATA half - that the shared predicate and the live classes agree about
  // which abilities move a pool. The Spirit Warrior's realms are F64's case,
  // and the Gypsy Gifted's Gifts each state their own I.S.P. formula.
  {
    const { abilityTouchesPool } = await import(pathToFileURL(join(appDir, 'js', 'parser.js')).href);
    const defs = (id) => (classes.find((x) => x.id === id)?.special_abilities || []).filter((d) => d?.name);
    const named = (id, name) => defs(id).find((d) => d.name === name);
    const earth = named('spirit-warrior', 'Powers of the Earth Realm');
    const air = named('spirit-warrior', 'Powers of the Air Realm');
    check('a realm that converts hit points and S.D.C. moves a pool',
      !!earth && abilityTouchesPool(earth) === true);
    check('and a realm that grants no pool does not', !!air && abilityTouchesPool(air) === false);
    const gifts = defs('gypsy-gifted').filter((d) => d.psionics?.isp_base != null);
    check("the Gypsy Gifted's Gifts each state an I.S.P. formula, so swapping one re-rolls it",
      gifts.length > 0 && gifts.every((d) => abilityTouchesPool(d) === true),
      gifts.length + ' gift(s) with an isp_base');
  }

  // -- per-level spell lists (BOOK-INGEST-AUDIT F59) ---------------------------
  //
  // New West printed 135 binds both Lyn-Srial picks to a category set, from
  // level one: the Sky-Knight one spell a level from any category but Clouds
  // of Creation, the Cloudweaver two from any but Clouds of War. The list sat in
  // `spells_from` with no starting count, so it bounded nothing. Asked of the
  // real leveling module, so a shape it cannot read fails here.
  const { startingGroups, spellGrantsFor, spellNamesForGrant } = await import(
    pathToFileURL(join(appDir, 'js', 'leveling.js')).href);
  for (const [id, per, excluded] of [['lyn-srial-sky-knight', 1, 'Clouds of Creation:'],
                                     ['lyn-srial-cloudweaver', 2, 'Clouds of War:']]) {
    const c = classes.find((x) => x.id === id);
    const start = c ? startingGroups(c, 'spell') : [];
    const listed = c ? spellNamesForGrant(c, 2, 0) || [] : [];
    check(`${id} picks ${per} at level one from a list without ${excluded}`,
      start.length === 1 && start[0].count === per && start[0].from?.length > 0
      && !start[0].from.some((n) => n.startsWith(excluded)), JSON.stringify(start.map((g) => g.count)));
    check(`and ${per} a level at 2-15 from the same list`,
      c && spellGrantsFor(c, 1, 15).grants.length === 14
      && spellGrantsFor(c, 1, 15).grants.every((g) => g.count === per)
      && listed.length === start[0]?.from?.length && !listed.some((n) => n.startsWith(excluded)));
  }
  // `true` is read by nothing; the key is an ARRAY paired with `from_list: true`.
  check('no class carries spells_per_level_from: true',
    !classes.some((c) => c.magic?.spells_per_level_from === true),
    classes.filter((c) => c.magic?.spells_per_level_from === true).map((c) => c.id).join(', '));

  // -- a list-bound pick keeps its level cap where the book states one (F61) --
  //
  // Three Spirit West shamans pick later spells from their Shamanistic list,
  // no higher than their own level. Asked of the real cap function, so the
  // data and the rule are checked together.
  const { spellLevelsForGrant } = await import(pathToFileURL(join(appDir, 'js', 'leveling.js')).href);
  const upTo = (lv) => JSON.stringify(Array.from({ length: lv }, (_, i) => i + 1));
  // The Elemental Shaman is four classes since F63, each carrying the cap.
  for (const [id, from, to] of [['plant-shaman', 3, 15], ['animal-shaman', 3, 15],
    ['elemental-shaman-air', 2, 15], ['elemental-shaman-earth', 2, 15],
    ['elemental-shaman-fire', 2, 15], ['elemental-shaman-water', 2, 15]]) {
    const c = classes.find((x) => x.id === id);
    const capped = [];
    for (let lv = from; lv <= to; lv++) if (c && JSON.stringify(spellLevelsForGrant(c, lv, 0)) === upTo(lv)) capped.push(lv);
    check(`${id} caps its list picks at the character's level, levels ${from}-${to}`,
      capped.length === to - from + 1, `capped at: ${capped.join(', ')}`);
  }
  // "Every remaining Shamanistic spell" spans spell levels 1-11 and 1-12; a cap
  // there would make the grant impossible to fill.
  for (const id of ['plant-shaman', 'animal-shaman']) {
    const c = classes.find((x) => x.id === id);
    check(`and ${id}'s level-2 remaining-spells grant stays uncapped`, !!c && spellLevelsForGrant(c, 2, 0) === null);
  }

  // -- the Elemental Shaman is one class per element (F63) --------------------
  //
  // An element CHOICE could neither narrow the three starting spells nor grant
  // the element's 98% skill, so the one class offered all 37 elemental spells
  // and kept the skill in ability text. Split per element as the Warlocks were
  // (RETRO-AUDIT R3); the one-class row is retired, not deleted.
  check('the one-class elemental shaman is no longer offered', !classes.some((c) => c.id === 'elemental-shaman'));
  for (const [el, spells, skill] of [['air', 7, 'Astronomy'], ['earth', 11, 'Holistic Medicine'],
                                     ['fire', 9, null], ['water', 10, 'Swimming']]) {
    const c = classes.find((x) => x.id === `elemental-shaman-${el}`);
    const E = el[0].toUpperCase() + el.slice(1);
    const three = (c ? startingGroups(c, 'spell') : []).find((g) => g.count === 3);
    check(`elemental-shaman-${el} picks three from its ${spells} level-one ${E} spells and no other element's`,
      !!three && three.from.length === spells && three.from.every((n) => n.startsWith(`${E}: `)),
      three ? `${three.from.length} offered` : 'no three-pick group');
    const at98 = (c?.skills?.occ_skills || [])
      .filter((s) => s.name && s.base === 98 && !s.name.startsWith('Language')).map((s) => s.name);
    check(`and ${skill ? `knows ${skill} at 98% as a skill` : 'has no 98% element skill, as printed'}`,
      !!c && JSON.stringify(at98) === JSON.stringify(skill ? [skill] : []), at98.join(', '));
    const abilities = c?.special_abilities || [];
    check('and offers no choice of element',
      abilities.length > 0 && !abilities.some((a) => a.choose)
      && abilities.filter((a) => / Shaman$/.test(a.name || '')).map((a) => a.name).join() === `${E} Shaman`);
  }

  // -- a variant or an occupation moves the pools (F68) -----------------------
  //
  // Whether the wizard clears them is pinned in smoke; this is the half that
  // says the staleness MATTERS. Composed from the live classes: the Mining
  // 'Borg's two chassis differ by 70 M.D.C., and the Chiang-Ku's two stages by
  // their whole hit point formula, so a pool rolled under one is wrong under
  // the other.
  {
    const { composeClass: composeFor } = await import(pathToFileURL(join(appDir, 'js', 'compose.js')).href);
    const sig = (c) => JSON.stringify([c?.hit_points_base ?? null, c?.sdc_base ?? null,
      c?.mdc_base ?? null, c?.ppe_base ?? null, c?.bonuses?.pools ?? null]);
    const borg = classes.find((x) => x.id === 'mining-borg');
    const race = classes.find((x) => x.id === 'space-wolfen');
    const occSigs = (borg?.variants || []).map((v) =>
      sig(composeFor({ rcc: race, occ: borg, character: { occ_class_variant: v.id } })));
    check("the Mining 'Borg's two chassis compose to different pools",
      occSigs.length === 2 && occSigs[0] !== occSigs[1], occSigs.join(' | '));
    const dragon = classes.find((x) => x.id === 'chiang-ku-dragon');
    const raceSigs = (dragon?.variants || []).map((v) =>
      sig(composeFor({ rcc: dragon, character: { class_variant: v.id } })));
    check("and the Chiang-Ku's two stages likewise",
      raceSigs.length === 2 && raceSigs[0] !== raceSigs[1], raceSigs.join(' | '));
  }

  // -- which attributes a variant actually moves (F70) -------------------------
  //
  // F70 asked for "clear the attribute rolls" when a variant restates
  // attribute_dice. These are the two measurements that made it narrower:
  // attribute_dice is in VARIANT_MERGED, so a variant may move a SUBSET; and a
  // variant may restate the block with the parent's own values, moving nothing
  // at all. Clearing on presence would throw away rolls in both cases.
  {
    const { composeClass: composeFor } = await import(pathToFileURL(join(appDir, 'js', 'compose.js')).href);
    const ATTR_KEYS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
    const dice = (c) => c?.attribute_dice || {};
    const movedBetween = (a, b) => ATTR_KEYS.filter((k) =>
      JSON.stringify(dice(a)[k] ?? null) !== JSON.stringify(dice(b)[k] ?? null));

    const daitya = classes.find((x) => x.id === 'daitya');
    const asVariant = (cls, id) => composeFor({ rcc: cls, character: { class_variant: id } });
    const dParent = composeFor({ rcc: daitya, character: {} });
    const dAverage = asVariant(daitya, 'average');
    const dRoyal = asVariant(daitya, 'royal');
    check('the daitya royal moves five of the eight attribute dice and leaves MA, PP and PE',
      movedBetween(dParent, dRoyal).join(',') === 'IQ,ME,PS,PB,Spd',
      movedBetween(dParent, dRoyal).join(',') || '(none)');
    check('and its average restates the block with the parent\'s own values, moving none',
      (daitya?.variants || []).some((v) => v.id === 'average' && v.attribute_dice)
      && movedBetween(dParent, dAverage).length === 0,
      movedBetween(dParent, dAverage).join(',') || '(none)');

    const dragon = classes.find((x) => x.id === 'chiang-ku-dragon');
    const hatch = asVariant(dragon, 'hatchling');
    const adult = asVariant(dragon, 'adult');
    check("and the Chiang-Ku's two stages move all eight, the class stating none itself",
      movedBetween(hatch, adult).length === 8 && Object.keys(dice(dragon)).length === 0,
      movedBetween(hatch, adult).join(','));
  }

  // -- a psionic level-up grant keeps its named list (F65) --------------------
  //
  // The Healing Shaman takes its remaining ten Healing powers at level 2 and
  // one super power from a named eight at levels 3, 6, 9 and 12; the Fetish
  // Shaman gains Psi-Sword at 3 and Psi-Shield at 6 by name. Its gates hold no
  // Super category, so the list has to REPLACE the gate or none could be taken.
  // Asked of the real grant builder, so the data and the carry are checked
  // together.
  {
    const { powerGrantsFor } = await import(pathToFileURL(join(appDir, '..', '..', 'functions',
      'api', 'character-creator', '_lib', 'power-picks.js')).href);
    const psiListed = (id) => {
      const c = classes.find((x) => x.id === id);
      return c ? powerGrantsFor(c, 1, 15).filter((g) => g.kind === 'psionic' && Array.isArray(g.from) && g.from.length) : [];
    };
    const hs = psiListed('healing-shaman');
    check('the Healing Shaman\'s five listed psionic grants carry their lists, with no category gate',
      hs.length === 5 && hs.every((g) => g.categories === null)
      && JSON.stringify(hs.map((g) => [g.level, g.from.length])) === '[[2,10],[3,8],[6,8],[9,8],[12,8]]',
      JSON.stringify(hs.map((g) => [g.level, g.from.length, g.categories])));
    const fsh = psiListed('fetish-shaman');
    check('and the Fetish Shaman\'s two name Psi-Sword and Psi-Shield',
      JSON.stringify(fsh.map((g) => [g.level, g.from])) === '[[3,["Psi-Sword"]],[6,["Psi-Shield"]]]'
      && fsh.every((g) => g.categories === null),
      JSON.stringify(fsh.map((g) => [g.level, g.from, g.categories])));
  }

  // -- languages of choice come from languages ------------------------------
  //
  // Seven classes said "two languages of choice" and offered the whole
  // Technical category - about sixty skills - because the repeatable
  // Language: Other row only behaved repeatably on the related/secondary
  // picker. They now offer that row and nothing else.
  // Stated as an INVARIANT over every class rather than a list of ids, because
  // the list was the thing that was wrong: the defect was reported as seven
  // classes and was thirty-two. Seven offered the whole Technical category,
  // which is merely too wide. Twenty-five offered Communications, which does
  // not contain `Language: Other` at all - it is filed under Technical - so
  // those classes could not grant a single ordinary language.
  const ABOUT_LANGUAGES = /^Language: Other,|languages? of choice|additional [Ll]anguages/;
  // A LITERACY pick reads the same way in prose - "literate in two languages of
  // choice" - and is a different thing: Literacy, Literacy: Other and the rest
  // are real catalog rows, so those groups are enumerated correctly already.
  const isLiteracy = (e) => /^Literate/i.test(e.note || '')
    || (Array.isArray(e.from) && e.from.every((n) => /^Literacy/.test(n)));
  const languageGroups = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e || e.name || !ABOUT_LANGUAGES.test(e.note || '') || isLiteracy(e)) continue;
      languageGroups.push({ id: c.id, e });
    }
  }
  check('the language picks are still there to check', languageGroups.length >= 30,
    `found ${languageGroups.length}`);

  const viaCategory = languageGroups.filter(({ e }) => Array.isArray(e.categories));
  check('no class offers a CATEGORY for a language pick', viaCategory.length === 0,
    viaCategory.map((x) => x.id).join(', '));

  const notFromTheRow = languageGroups.filter(({ e }) =>
    !Array.isArray(e.from) || !e.from.includes('Language: Other'));
  check('and every one of them offers the repeatable language row',
    notFromTheRow.length === 0, notFromTheRow.map((x) => x.id).join(', '));

  // ── the SECOND, INDEPENDENT detector (BOOK-INGEST-AUDIT.md F4) ─────────────
  //
  // Everything above finds the group by READING ITS NOTE, and an invariant
  // stated over every class is then narrowed by a regex over free text - which
  // is the same shape as the bug it guards. The CAF Trooper transcribes its
  // book as "Language: any two", which matches none of the three alternatives,
  // and its identical defect passed the whole suite.
  //
  // So this asks the question from the other side and shares no regex with it:
  // a choice group offered through a CATEGORY whose note mentions a language at
  // all is either the bug or a rare deliberate pick, and there are currently
  // none of either. Measured across all published classes: zero hits whether
  // the categories are restricted to Technical/Communications as F4 proposed or
  // left open, so the wider form is used - it cannot miss and costs nothing.
  //
  // WIDENING `ABOUT_LANGUAGES` INSTEAD WOULD BREAK A GOOD CLASS, which is why
  // this is a second check rather than a bigger regex. Adding `^Language: `
  // would pull in the CAF Trooper's OTHER group - a pick of one specific Trade
  // Tongue from three named rows - which correctly offers no `Language: Other`
  // and would fail the assertion above.
  //
  // F4's PRIMARY proposal was to decide the group by shape alone: `categories`
  // naming Technical or Communications with no `from`. That was tried against
  // the corpus first and it does not work - it finds nine groups and not one is
  // a language pick. They are Lore picks (the catalog files lore under
  // Technical), science-or-technical picks, and general skill choices. Naming
  // them would rebuild the id list this invariant was written to replace.
  const catNameOf = (x) => (typeof x === 'string' ? x : x?.name) || '';
  const categoryLanguagePicks = [];
  const categoryLiteracyPicks = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e || e.name || !Array.isArray(e.categories) || !e.categories.length) continue;
      const note = e.note || '';
      const where = `${c.id} (${e.categories.map(catNameOf).join('/')}): ${note.slice(0, 60)}`;
      if (/\blanguages?\b/i.test(note)) categoryLanguagePicks.push(where);
      if (/\bliterac(y|ies)\b|\bliterate\b/i.test(note)) categoryLiteracyPicks.push(where);
    }
  }
  check('no choice group offers a CATEGORY for a pick whose note mentions a language',
    categoryLanguagePicks.length === 0, categoryLanguagePicks.join('; '));
  // F4 asked whether the literacy family below has the same hole. It does - it
  // reads the same free text with a different regex - so it gets the same
  // independent check, and is also at zero.
  check('and none offers a CATEGORY for a pick whose note mentions literacy',
    categoryLiteracyPicks.length === 0, categoryLiteracyPicks.join('; '));

  // The bonus is what makes the pick worth taking, and losing one in the
  // rewrite would be silent because the row still resolves. Two classes had
  // none to begin with and gained the figure their own note recorded.
  //
  // The test is that a bonus was STATED, not that it is positive. It read
  // `> 0` until the Fallen Cosmo-Knight, whose book grants the Cosmo-Knight's
  // skills - three languages at +20% among them - and then reduces every one
  // of them by 20 points. Zero is that class's correct figure, and the row
  // resolves at the catalog's own 50% +5%/level, which is right. The failure
  // this check was written for is an ABSENT bonus, and `>= 0` still catches
  // every one of those: a bonus lost in a rewrite is undefined, not zero.
  const noBonus = languageGroups.filter(({ e }) => !(typeof e.bonus === 'number' && e.bonus >= 0));
  check('and every one states a bonus, none of them negative', noBonus.length === 0,
    noBonus.map((x) => x.id).join(', '));

  // A language must never be FIXED at a flat percentage: it resolves off the
  // Other row's 50% +5/lvl, and `base` would freeze it. The Cyber-Doc read the
  // printed "+20%" as `base: 20, per_level: 0` - a language stuck at 20% for
  // fifteen levels.
  const frozen = languageGroups.filter(({ e }) => e.base !== undefined || e.per_level === 0);
  check('and none is frozen at a flat percentage', frozen.length === 0,
    frozen.map((x) => `${x.id} base=${x.e.base} per_level=${x.e.per_level}`).join(', '));

  // Spot-check the three shapes end to end.
  for (const [id, want] of Object.entries({ knight: 2, 'chiang-ku-dragon': 3, 'cyber-doc': 1 })) {
    const g = languageGroups.find((x) => x.id === id)?.e;
    check(`${id} asks for ${want} language(s)`, g?.choose === want, `asks for ${g?.choose}`);
  }

  // -- and the same for LITERACY ---------------------------------------------
  //
  // The second family, and the one that had no rule at all: `Literacy: Other`
  // is the same escape hatch for reading rather than speaking, and was treated
  // as one ordinary skill. So a Wizard "literate in two languages of choice"
  // picked twice from four generic rows and ended up literate in "Other".
  const literacyGroups = [];
  const literacyFixed = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e) continue;
      if (e.name === 'Literacy: Other') literacyFixed.push(c.id);
      if (e.name) continue;
      const about = /^Literate/i.test(e.note || '') || /^Literacy: Other,/.test(e.note || '')
        || (Array.isArray(e.from) && e.from.some((n) => /^Literacy/.test(n)));
      if (about) literacyGroups.push({ id: c.id, e });
    }
  }
  check('the literacy picks are still there to check', literacyGroups.length >= 6,
    `found ${literacyGroups.length}`);

  const litViaCategory = literacyGroups.filter(({ e }) => Array.isArray(e.categories));
  check('no class offers a CATEGORY for a literacy pick', litViaCategory.length === 0,
    litViaCategory.map((x) => x.id).join(', '));

  const litNotFromRow = literacyGroups.filter(({ e }) =>
    !Array.isArray(e.from) || !e.from.includes('Literacy: Other'));
  check('and every literacy pick offers the repeatable row',
    litNotFromRow.length === 0, litNotFromRow.map((x) => x.id).join(', '));

  // A grant of the placeholder is a pick that was never offered: the character
  // ends up holding a skill named, literally, "Literacy: Other".
  check('no class GRANTS the placeholder row as a fixed skill',
    literacyFixed.length === 0, literacyFixed.join(', '));

  // The same guard for the LANGUAGE family, which did not have one - so the
  // identical mistake was fatal on literacy and invisible here. F34.
  //
  // NOT `=== 0`, and that is the whole design. A fixed `Language: Other` is
  // legitimate when the book NAMES the tongue and the catalog has no row for
  // it: the demon-hound-rider's Br'talb, the four Promethean classes'
  // Promethean. Asserting zero would go red on those six forever, and the
  // standing temptation would then be to weaken it to a warning.
  //
  // So the rule is the SHAPE, not a list of class ids. A named tongue is a
  // FIXED percentage - `base` set, `per_level: 0` - because the character
  // simply speaks it. A missing selection looks like the catalog row it was
  // copied from: `per_level: 5`, climbing, with a note saying "select one" or
  // "of choice". Nine classes had the second shape. A list of names would need
  // editing the next time a book names a tongue; this does not.
  const languageFixed = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e || e.name !== 'Language: Other') continue;
      const named = typeof e.base === 'number' && e.per_level === 0;
      if (!named) languageFixed.push(`${c.id} (base ${e.base ?? '-'}, per_level ${e.per_level ?? '-'})`);
    }
  }
  check('a fixed Language: Other is a NAMED tongue, not a missing selection',
    languageFixed.length === 0, languageFixed.join('; '));

  // And the other half of the shape: the six that stay fixed must still BE
  // there. A check that only forbids can be satisfied by deleting the thing it
  // was protecting, which would lose six languages the books name.
  const namedTongues = classes.flatMap((c) => (c.skills?.occ_skills || [])
    .filter((e) => e && e.name === 'Language: Other' && e.per_level === 0).map(() => c.id));
  check('and the named tongues survive as fixed skills', namedTongues.length >= 6,
    `found ${namedTongues.length}: ${namedTongues.join(', ')}`);

  // -- every fixed skill a class names must exist -----------------------------
  //
  // The Stone Master cited "Literacy: Dragonese/Elf" - no such row, no redirect
  // - so the skill resolved to nothing, and "Language: American" sat at base 0
  // per_level 0, frozen at 0% for fifteen levels. A name in one of the two
  // families is exempt: those resolve off their family's Other row BY DESIGN
  // and are the whole reason the families exist.
  const catalogNames = new Set((catalogs.body.skills || []).map((r) => r.name));
  // A RENAME deliberately leaves class markdown alone and records a redirect
  // instead, so a name with no row is not automatically dead - the Glitter Boy
  // still cites both pre-rename Robot Combat spellings on purpose. /catalogs
  // never sends redirects, so this asks the scratch database, which the test
  // owns.
  // `wrangler()` spawns with shell: true, so an argument with spaces has to
  // carry its own quotes - every other caller here passes --file, which has
  // none, and an unquoted SQL string arrives as a dozen unknown arguments.
  const redirectRows = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
    '--command', `"SELECT from_key FROM catalog_redirects WHERE catalog = 'skills'"`]);
  let redirected = new Set();
  let redirectErr = '';
  try {
    const out = redirectRows.stdout || '';
    // wrangler prefixes its own log line - "[string] [d1, execute, ...]" - so the
    // first "[" in the output is NOT the JSON. Take the first one that parses.
    let parsed = null;
    for (let at = out.indexOf('['); at >= 0 && !parsed; at = out.indexOf('[', at + 1)) {
      try {
        const v = JSON.parse(out.slice(at));
        if (Array.isArray(v)) parsed = v;
      } catch { /* not the array; keep looking */ }
    }
    if (!parsed) throw new Error(cleanErr(redirectRows.stderr || out));
    redirected = new Set(parsed.flatMap((b) => b.results || []).map((r) => r.from_key));
  } catch (e) { redirectErr = e.message; }
  check('the redirect table is readable', redirected.size > 0,
    redirectErr || 'query ran but returned no skill redirects');

  const isFamily = (n) => /^(Language|Literacy):\s*\S/.test(n);
  const resolves = (n) => catalogNames.has(n) || isFamily(n) || redirected.has(n);
  const deadFixed = [];
  const frozenAtZero = [];
  const bonusOnNothing = [];
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e?.name) continue;
      if (!resolves(e.name)) {
        // A class-specific skill the catalog never got still resolves IF the
        // class states its own numbers; what cannot resolve is a name with
        // neither a row, a redirect, nor a base.
        if (typeof e.base !== 'number') deadFixed.push(`${c.id}: ${e.name}`);
      }
      if (isFamily(e.name) && e.base === 0) frozenAtZero.push(`${c.id}: ${e.name}`);
      // A `bonus` is meaningless without a row to add it to. `resolveSkill`
      // sums it onto the catalog base, so a bonus on a name the catalog does
      // not have does not fall back to the bonus - it falls to ZERO, which is
      // worse than the wrong number it replaced.
      if (e.bonus !== undefined && !resolves(e.name)) {
        bonusOnNothing.push(`${c.id}: ${e.name}`);
      }
    }
  }
  check('no fixed skill puts a bonus on a name the catalog does not have',
    bonusOnNothing.length === 0, bonusOnNothing.join(', '));

  // -- a printed BONUS is never stored as the BASE ----------------------------
  //
  // "Chemistry (+10%)" means ten points on top of Chemistry's own 30%, not a
  // Chemistry of 10%. Storing the second for the first put 48 skills across six
  // classes BELOW the catalog row they are supposed to excel at - the Cyber-Doc
  // diagnosing at Computer Operation 5% where any passer-by has 40%.
  //
  // Written over every class rather than the six, so a new import inherits it.
  // A below-base fixed skill is legitimate when the book prints a flat figure -
  // "Language: Native Tongue at 88%", the Warrior Monk's "Base Skill: 20%" - so
  // the rule is not "never below base"; it is that such a row must SAY SO, in a
  // note or by being one of the two language families. What must never happen
  // again is a bare number sitting under the catalog with nothing to explain it.
  const catalogByName = new Map((catalogs.body.skills || []).map((r) => [r.name, r]));
  const unexplainedBelowBase = [];
  let compared = 0;
  for (const c of classes) {
    for (const e of (c.skills?.occ_skills || [])) {
      if (!e?.name || typeof e.base !== 'number') continue;
      const row = catalogByName.get(e.name);
      if (!row) continue;
      compared += 1;
      if (e.base >= row.base) continue;
      // The family exemption is GONE. It was there because a `Language: X` with
      // no catalog row of its own resolves off the Other row, where comparing
      // to a base is meaningless - but this branch already skipped names the
      // catalog does not have, so all the exemption ever did was hide the
      // twelve `Language: Native Tongue` rows, which DO have a catalog row and
      // really are below it. Eight of them carried no explanation, and every
      // audit re-derived the same answer from the same scans. Now the rule is
      // simply: below the line, say why.
      if (e.note && e.note.trim()) continue;
      unexplainedBelowBase.push(`${c.id}: ${e.name} ${e.base} < ${row.base}`);
    }
  }
  // A rule that silently compares nothing passes forever. This one has hundreds
  // of rows to look at; if a rename or a shape change ever leaves it with none,
  // the failure should be the missing comparison, not the empty result.
  check('the below-base rule actually compared fixed skills against the catalog',
    compared > 200, `compared ${compared}`);
  check('no fixed skill sits under its catalog base without saying why',
    unexplainedBelowBase.length === 0, unexplainedBelowBase.join(', '));
  check('every fixed skill resolves to real numbers',
    deadFixed.length === 0, deadFixed.join(', '));
  check('and no language or literacy skill is pinned to 0%',
    frozenAtZero.length === 0, frozenAtZero.join(', '));

  // -- every Palladium O.C.C. levels on its own chart -------------------------
  //
  // Palladium Fantasy printed 336: 15 tables, 15 levels each. `xp_table` stores
  // the LOWER bound of each band, which is what `levelForXp` compares against.
  //
  // The shape is checked over the whole catalog rather than a list of 25 ids,
  // so a new Palladium O.C.C. arriving without a chart is a failure here rather
  // than a character quietly levelling on the house-rule default.
  const pfOcc = classes.filter((c) => c.system === 'palladium-fantasy' && c.category === 'occ');
  const rccs = classes.filter((c) => c.category === 'rcc');
  check('the Palladium O.C.C.s are still there to check', pfOcc.length >= 25, `${pfOcc.length}`);

  const noTable = pfOcc.filter((c) => !Array.isArray(c.xp_table));
  check('every Palladium O.C.C. has its own experience table',
    noTable.length === 0, noTable.map((c) => c.id).join(', '));

  const misshapen = pfOcc.filter((c) => {
    const t = c.xp_table;
    return !Array.isArray(t) || t.length !== 15 || t[0] !== 0
      || t.some((n, i) => !Number.isInteger(n) || (i > 0 && n <= t[i - 1]));
  });
  check('and each is 15 levels, starting at 0, strictly rising',
    misshapen.length === 0, misshapen.map((c) => c.id).join(', '));

  // -- a race MAY carry a ladder, and an occupation's still wins a pairing ----
  //
  // This block asserted "and no R.C.C. carries one" until 2026-09-17, and #222's
  // composition fix leaned on it: the race won `xp_table` in a pairing, so a
  // race carrying one would have dropped its occupation's chart. Nate's call
  // that day (docs/surveys/nightbane-core.md, "Follow-up decisions after the
  // import"): an R.C.C. carries the ladder its book prints for the race, used
  // when the race is played alone, and an O.C.C.'s ladder wins a pairing.
  // Nightbane printed 233 prints nine such race ladders. So the invariant moved
  // from "none carries one" to "whatever carries one is a real ladder, and
  // never beats an occupation's".
  const rccWithTable = rccs.filter((c) => c.xp_table !== undefined);
  const rccMisshapen = rccWithTable.filter((c) => {
    const t = c.xp_table;
    return !Array.isArray(t) || t.length !== 15 || t[0] !== 0
      || t.some((n, i) => !Number.isInteger(n) || (i > 0 && n <= t[i - 1]));
  });
  check('every R.C.C. that carries a ladder carries 15 levels, starting at 0, strictly rising',
    rccMisshapen.length === 0, rccMisshapen.map((c) => c.id).join(', '));

  // Pinned by name, both ways: the nine races whose ladders moved out of their
  // extraction notes, and the Nightbane R.C.C. that deliberately states none -
  // its package O.C.C.s carry "Nightbane & Guardian", and a Nightbane is never
  // played without one.
  const nbRaceLadders = ['nb-doppleganger', 'nb-hunter', 'nb-ashmedai', 'nb-namtar',
    'nb-snake-bird', 'nb-secondary-vampire', 'nb-wild-vampire', 'nb-wampyr', 'nb-guardian'];
  const nbMissing = nbRaceLadders.filter((id) => !rccWithTable.some((c) => c.id === id));
  check('the nine Nightbane races with a printed ladder carry it',
    nbMissing.length === 0, nbMissing.join(', '));
  check('and the Nightbane R.C.C. itself still carries none',
    classes.some((c) => c.id === 'nb-nightbane')
    && classes.find((c) => c.id === 'nb-nightbane').xp_table === undefined);

  // The composition half, over every race that carries one rather than a
  // fixture: paired with an O.C.C. whose ladder DIFFERS from the race's, the
  // occupation's is the one the character levels on - and alone, the race's.
  const occWithTable = classes.filter((c) => c.category === 'occ' && Array.isArray(c.xp_table));
  const raceWonPairing = [];
  const raceLostAlone = [];
  let paired = 0;
  for (const r of rccWithTable) {
    const job = occWithTable.find((o) => JSON.stringify(o.xp_table) !== JSON.stringify(r.xp_table));
    if (!job) continue;
    paired++;
    if (JSON.stringify(combineClasses(r, job).xp_table) !== JSON.stringify(job.xp_table)) {
      raceWonPairing.push(`${r.id}+${job.id}`);
    }
    if (JSON.stringify(composeClass({ rcc: r, character: {} })?.xp_table) !== JSON.stringify(r.xp_table)) {
      raceLostAlone.push(r.id);
    }
  }
  check('the ladder composition was actually exercised on real races',
    paired >= nbRaceLadders.length, `paired ${paired}`);
  check('paired with an O.C.C. that states a ladder, the occupation’s wins',
    raceWonPairing.length === 0, raceWonPairing.join(', '));
  check('and a race played alone keeps its own',
    raceLostAlone.length === 0, raceLostAlone.join(', '));

  // The pairs the book prints together must stay together - "Knight & Noble" is
  // one chart, and two classes drifting apart means a transcription went wrong.
  // Nightbane printed 233 names a race and an occupation on one chart three
  // times, so the pairing rule reaches across the R.C.C./O.C.C. line there.
  for (const [a, b] of [['knight', 'noble'], ['thief', 'merchant'],
    ['mind-mage', 'wizard'], ['priest-of-light', 'priest-of-darkness'],
    ['nb-ashmedai', 'nb-psychic'], ['nb-ashmedai', 'nb-sorcerer'],
    ['nb-snake-bird', 'nb-mystic'], ['nb-guardian', 'nb-package-basic']]) {
    const ta = classes.find((c) => c.id === a)?.xp_table;
    const tb = classes.find((c) => c.id === b)?.xp_table;
    check(`${a} and ${b} share the chart the book prints for both`,
      JSON.stringify(ta) === JSON.stringify(tb) && Array.isArray(ta));
  }

  // The Warlock's row is the Rifts printing, so its Palladium figures belong in
  // its delta section and NOT in its frontmatter.
  //
  // Checked across ALL TEN per-Force Warlocks rather than the one generic class
  // this used to name: RETRO-AUDIT R3 retired `warlock` and replaced it with one
  // class per Elemental Force and one per pair, so a lookup by that id now finds
  // nothing and the check would pass vacuously on `undefined === undefined`.
  const warlocks = classes.filter((c) => c.id.startsWith('warlock-'));
  check('all ten Warlocks are live to check', warlocks.length === 10, warlocks.length);
  check('the Warlock takes its Palladium experience as a delta, not a table',
    warlocks.length === 10 && warlocks.every((w) => w.xp_table === undefined),
    JSON.stringify(warlocks.filter((w) => w.xp_table !== undefined).map((w) => w.id)));
}

// ---------- gear.sdc ----------
// The book calls A.R. and S.D.C. the TWO attributes of armour (printed 270),
// and the rules spend the second: damage subtracts from it, at half S.D.C. the
// A.R. drops two points. It lived in free-text `description` until migration
// 034, where no arithmetic could reach it.
//
// `/items` projects only the fields the pickers render, so this asks the
// scratch database - the same way the redirect check does.
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
      '--command', `"${sql}"`]);
    const out = r.stdout || '';
    for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
      try { const v = JSON.parse(out.slice(at)); if (Array.isArray(v)) return v.flatMap((b) => b.results || []); }
      catch { /* wrangler's own log line opens with a bracket too */ }
    }
    throw new Error(cleanErr(r.stderr || out));
  };

  let rows = [];
  let err = '';
  try { rows = q('SELECT slug, category, system, ar, sdc, mdc, damage FROM gear'); }
  catch (e) { err = e.message; }
  check('gear is readable and has an sdc column', rows.length > 0, err || 'no rows');

  // The Types of Armor table, printed 270, plus the shield from printed 60.
  const BOOK = { 'soft-leather': 20, 'hard-leather': 30, 'studded-leather': 38,
    'chain-mail': 44, 'scale-mail': 75, 'small-shield': 30 };
  const wrong = Object.entries(BOOK)
    .map(([slug, want]) => [slug, want, rows.find((r) => r.slug === slug)?.sdc])
    .filter(([, want, got]) => got !== want);
  check('every Palladium armour row carries the S.D.C. its book prints',
    wrong.length === 0, wrong.map(([s, w, g]) => `${s} want ${w} got ${g}`).join(', '));

  const pfArmourEmpty = rows.filter((r) => r.category === 'armor'
    && r.system === 'palladium-fantasy' && r.sdc == null);
  check('and none of them is still empty', pfArmourEmpty.length === 0,
    pfArmourEmpty.map((r) => r.slug).join(', '));

  // A suit has one scale or the other. (A row that CONFLATES two products can
  // legitimately carry both - polarized goggles are 15 S.D.C. ordinary and
  // 1 M.D.C. high-impact - which is why this is scoped to armour.)
  const bothScales = rows.filter((r) => r.category === 'armor' && r.sdc != null && r.mdc != null);
  check('no armour row carries both an S.D.C. and an M.D.C.',
    bothScales.length === 0, bothScales.map((r) => r.slug).join(', '));

  // The trap this column invites. "Does 1D6 S.D.C." on a knife is DAMAGE, and a
  // regex over descriptions would file it as durability - a knife that can
  // absorb six points of punishment because it deals six.
  //
  // NAMED EXCEPTIONS, because a THROWN object legitimately has both: its own
  // structure, and what it does when it goes off. BOOK-INGEST-AUDIT.md F54.
  // Scoped the way the armour check above is scoped rather than relaxed - an
  // unlisted row still fails, so the knife case is untouched. Listed by SLUG
  // and not by category, because `weapon` is where the knife lives too; the
  // Palladium armour map twenty lines up is the same shape for the same reason.
  const SELF_SDC = new Set([
    // Rifts New West printed 209 gives both Wilk's grenades S.D.C. 20 and
    // A.R. 10 - the casing - but only the BEEHIVE also does dice damage. The
    // Blinder's damage reads "None; it blinds rather than injures", so it never
    // tripped the check and is deliberately NOT listed here. The narrowness
    // check below is what found that, on the first run after this list was
    // written.
    'wilk-s-beehive-laser-grenade',
  ]);
  const damageAsSdc = rows.filter((r) => r.sdc != null && /\dD\d/.test(r.damage || '')
    && !SELF_SDC.has(r.slug));
  check('and no weapon was given its own damage as durability',
    damageAsSdc.length === 0, damageAsSdc.map((r) => `${r.slug} sdc=${r.sdc} damage=${r.damage}`).join(', '));

  // The allowance must stay NARROW, so it is checked in both directions: every
  // slug in it has to exist and has to actually carry both columns. A stale
  // name here would silently widen the check it is exempting.
  const staleExempt = [...SELF_SDC].filter((slug) => {
    const row = rows.find((r) => r.slug === slug);
    return !row || row.sdc == null || !/\dD\d/.test(row.damage || '');
  });
  check('and every named exception still needs to be one',
    staleExempt.length === 0, `no longer carries both: ${staleExempt.join(', ')}`);

  // The check that used to sit here asked whether the gear IMPORTER could write
  // this column. That importer is gone - gear rows are written by data script -
  // so the question it protected against is now answered by the rows themselves,
  // which the three checks above already read straight out of the database.
}

// ---------- the finished magic items ----------
// The other half of printed 249-267. The enchantments are what an alchemist
// puts INTO an object; these are the objects he sells finished.
//
// Written against the scratch database rather than /items, which projects only
// the fields the pickers render - cost_note, ar and sdc are not among them.
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
      '--command', `"${sql}"`]);
    const out = r.stdout || '';
    for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
      try { const v = JSON.parse(out.slice(at)); if (Array.isArray(v)) return v.flatMap((b) => b.results || []); }
      catch { /* wrangler's own log line opens with a bracket too */ }
    }
    throw new Error(cleanErr(r.stderr || out));
  };
  const BOOK = 'Palladium Fantasy RPG p.249-267';
  let rows = [];
  let err = '';
  try {
    rows = q(`SELECT slug, name, category, cost, cost_note, ar, sdc, description FROM gear WHERE source_book = '${BOOK}'`);
  } catch (e) { err = e.message; }

  check('the magic items are in the gear catalog', rows.length === 175, err || `${rows.length} rows`);

  // The three finished suits are ARMOUR and carry the numbers the page prints.
  // Everything else is 'magic'.
  const suits = rows.filter((r) => r.category === 'armor');
  check('the three magic suits went in as armour', suits.length === 3,
    suits.map((r) => r.slug).join(', '));
  const SUIT = { 'cloak-of-armor': [14, 50], 'cloak-of-protection': [12, 50],
    'leather-of-iron': [15, 60] };
  const wrongSuit = Object.entries(SUIT).filter(([slug, [ar, sdc]]) => {
    const r = rows.find((x) => x.slug === slug);
    return !r || r.ar !== ar || r.sdc !== sdc;
  });
  check('and each with the A.R. and S.D.C. its page prints',
    wrongSuit.length === 0, wrongSuit.map(([s]) => s).join(', '));

  // A 'magic' row claiming armour numbers would be a row in the wrong category.
  const pretender = rows.filter((r) => r.category === 'magic' && (r.ar != null || r.sdc != null));
  check('and no magic row claims an armour rating', pretender.length === 0,
    pretender.map((r) => r.slug).join(', '));

  // Exactly one item in the book has no price: the Crystal Ball is "considered
  // priceless and sells for millions", and a number there would be invented.
  const unpriced = rows.filter((r) => r.cost == null);
  check('one item is priceless, and only one', unpriced.length === 1,
    unpriced.map((r) => r.slug).join(', '));
  check('and it is the crystal ball', unpriced[0]?.slug === 'crystal-ball',
    unpriced[0]?.slug);

  // The wrapped-range bug: "20,000-\n30,000" rejoins as 2,000,030,000 if the
  // de-hyphenation that fixes a broken WORD is let near a number. Both of the
  // rows it hit are pinned at the figure the page actually prints.
  const wrapped = { 'fright-wig': 20000, chasers: 2000 };
  const wrongWrap = Object.entries(wrapped)
    .filter(([slug, cost]) => rows.find((r) => r.slug === slug)?.cost !== cost);
  check('a price wrapped across a line kept its range',
    wrongWrap.length === 0, wrongWrap.map(([s]) => s).join(', '));
  const absurd = rows.filter((r) => r.cost > 10000000);
  check('and nothing costs more than ten million gold', absurd.length === 0,
    absurd.map((r) => `${r.slug}=${r.cost}`).join(', '));

  // A price the integer cannot hold keeps its wording. The book prices in
  // ranges far more often than in figures.
  const noted = rows.filter((r) => r.cost_note);
  check('most of them carry the wording a single integer cannot hold',
    noted.length > 60, `${noted.length} of ${rows.length}`);

  // Faerie foods are priced by BAND, which their own preamble states, and are
  // prefixed because the catalog already sells an ordinary goose.
  // `faerie-wings` is a magic COMPONENT at 20,000 gold, not a food, and it is
  // the reason this is not simply a prefix match.
  const faerie = rows.filter((r) => r.slug.startsWith('faerie-') && r.slug !== 'faerie-wings');
  check('the faerie foods are all prefixed', faerie.length === 28, `${faerie.length}`);
  const bands = new Set(faerie.map((r) => r.cost));
  check('and priced in the two bands the book gives, plus one override',
    bands.size === 3 && bands.has(500) && bands.has(2000) && bands.has(5000),
    [...bands].join(', '));

  // Nothing here may collide with gear that was already in the catalog.
  const all = q('SELECT slug, count(*) AS n FROM gear GROUP BY slug HAVING n > 1');
  check('no gear slug is duplicated', all.length === 0,
    all.map((r) => r.slug).join(', '));
}

// ---------- the armour table, and the duplicates ----------
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
      '--command', `"${sql}"`]);
    const out = r.stdout || '';
    for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
      try { const v = JSON.parse(out.slice(at)); if (Array.isArray(v)) return v.flatMap((b) => b.results || []); }
      catch { /* wrangler's own log line opens with a bracket too */ }
    }
    throw new Error(cleanErr(r.stderr || out));
  };

  // Printed 270 has SIXTEEN rows and the catalog held five, so a Palladium
  // character could buy leather, chain or scale and nothing else - no cloth,
  // no plate, and not one half suit.
  const pf = q("SELECT slug, name, ar, sdc, cost, weight_lbs FROM gear "
    + "WHERE system = 'palladium-fantasy' AND category = 'armor'");
  check('the Palladium armour catalog covers the whole table', pf.length >= 27,
    `${pf.length} rows`);

  // The five that were already there come from the same table as the fourteen
  // that arrived, so they are a check on the reading rather than just data.
  const TABLE = {
    'cloth-armor': [5, 6, 20], 'padded-armor': [8, 15, 50],
    'soft-leather': [10, 20, 75], 'hard-leather': [11, 30, 150],
    'studded-leather': [13, 38, 200], 'chain-mail': [14, 44, 280],
    'chain-mail-half': [9, 20, 170], 'double-mail': [15, 55, 340],
    'double-mail-half': [10, 28, 200], 'scale-mail': [15, 75, 650],
    'scale-mail-half': [11, 35, 300], 'splint-armor': [16, 82, 700],
    'splint-armor-half': [12, 40, 400], 'plate-and-chain': [15, 100, 800],
    'plate-armor': [17, 160, 1000], 'plate-armor-half': [14, 60, 450],
  };
  const wrong = Object.entries(TABLE).filter(([slug, [ar, sdc, cost]]) => {
    const r = pf.find((x) => x.slug === slug);
    return !r || r.ar !== ar || r.sdc !== sdc || r.cost !== cost;
  });
  check('and every row matches the A.R., S.D.C. and price the table prints',
    wrong.length === 0, wrong.map(([s2]) => s2).join(', '));

  // The three leather half suits are given in prose with no price, and a
  // number there would be invented.
  const halves = ['soft-leather-half', 'hard-leather-half', 'studded-leather-half']
    .map((sl) => pf.find((x) => x.slug === sl));
  check('the three leather half suits exist', halves.every(Boolean));
  check('and none of them invents a price the book withholds',
    halves.every((h) => h && h.cost == null),
    halves.map((h) => `${h?.slug}=${h?.cost}`).join(', '));

  const shields = q("SELECT slug, sdc, cost FROM gear WHERE slug LIKE '%shield%'");
  check('all five shields are in the catalog', shields.length === 5,
    shields.map((r) => r.slug).join(', '));

  // -- the duplicates ------------------------------------------------------
  const RETIRED = ['crusader-body-armor', 'gladiator-body-armor',
    'plastic-man-body-armor', 'urban-warrior-body-armor',
    'dead-boy-armor-ca-1-heavy', 'dead-boy-armor-ca-2-light',
    'dead-boy-armor-black-market'];
  const left = q(`SELECT slug FROM gear WHERE slug IN (${RETIRED.map((r) => `'${r}'`).join(', ')})`);
  check('the duplicated armour rows are gone', left.length === 0,
    left.map((r) => r.slug).join(', '));

  // Retired keys keep resolving. That is the whole contract of the table.
  const redir = q(`SELECT from_key FROM catalog_redirects WHERE catalog = 'gear' `
    + `AND from_key IN (${RETIRED.map((r) => `'${r}'`).join(', ')})`);
  check('and every one of them still resolves through a redirect',
    redir.length === RETIRED.length, `${redir.length} of ${RETIRED.length}`);

  // 'dead-boy-body-armor' pointed at a row that was retired here. A redirect
  // to a row that no longer exists is the one failure this table exists to
  // prevent, so it is checked over the WHOLE catalog and not just these seven.
  const dangling = q("SELECT r.from_key FROM catalog_redirects r WHERE r.catalog = 'gear' "
    + 'AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id)');
  check('no gear redirect points at a row that no longer exists',
    dangling.length === 0, dangling.map((r) => r.from_key).join(', '));

  // The black market price was a ROW; printed 261 puts it under "Features
  // Common to All Dead Boy Armor", so it belongs to both suits.
  const deadBoy = q("SELECT slug, cost_note FROM gear WHERE slug IN "
    + "('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')");
  check('both Dead Boy suits carry the black market price as a note',
    deadBoy.length === 2 && deadBoy.every((r) => /Black market/.test(r.cost_note || '')),
    JSON.stringify(deadBoy.map((r) => r.cost_note)));

  // Checked and found distinct - a rating in common is not a duplicate.
  const kept = q("SELECT slug FROM gear WHERE slug IN ('bushman-trooper', "
    + "'bushman-full-composite-environmental-body-armor', 'cyber-armor', "
    + "'huntsman-plate-padded-armor-non-environmental', "
    + "'juicer-assassin-plate-armor-non-environmental')");
  check('and the five that only look like duplicates are still there',
    kept.length === 5, kept.map((r) => r.slug).join(', '));
}

// ---------- a live catalog row on a RETIRED key ----------
// BOOK-INGEST-AUDIT.md F90. A key a redirect has retired is ABSENT FROM THE
// CATALOG AND STILL SPOKEN FOR, and every collision check in the ingest path
// reads only the table - an `INSERT OR IGNORE` sees the table's UNIQUE
// constraint and nothing else. So a new row can land on a retired key, and two
// things follow, neither of which announces itself:
//
//   * the redirect stops firing, because _lib/catalog.js consults redirects
//     only for keys it does NOT find - which silently defeats whatever the
//     redirect was filed to do;
//   * on a clean rebuild the file that retired the key usually sorts LATER, so
//     the new row is created and then deleted again, every build. That is how
//     `back-pack` reached production and left a rebuilt database one gear row
//     short, with only a pinned TOTAL to say so and no row named.
//
// The block above is the hand-maintained version of this, over seven slugs it
// lists by name. This is the same rule over every catalog.
//
// INNER JOIN ON THE TARGET, mirroring `redirectTarget`. _lib/catalog-redirects.js
// says it in so many words - "a dead redirect must not block anyone from
// reusing the key" - so a redirect whose target has itself been deleted must
// NOT make this fail. Every redirect in production has a live target today, so
// the join changes nothing now and keeps the check honest when it does not.
{
  const q = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
      '--command', `"${sql}"`]);
    const out = r.stdout || '';
    const i = out.indexOf('[');
    if (i < 0) return [];
    try { return (JSON.parse(out.slice(i))[0] || {}).results || []; } catch { return []; }
  };

  // catalog key -> [table, unique column], mirroring js/catalog-fields.js.
  //
  // KEYED BY THE CATALOGS KEY, NOT THE TABLE NAME, and that is load-bearing:
  // `redirectStatements` is called with the CATALOGS key, so
  // `catalog_redirects.catalog` stores `superAbilities`, never
  // `super_abilities`. This map carried `super_abilities` until
  // BOOK-INGEST-AUDIT F100, which meant the first super-ability rename or merge
  // would have tripped the guard below - and, worse, the retired-key JOIN would
  // have matched no row and skipped super abilities in silence. It was latent
  // only because no super-ability redirect exists yet (production, 2026-09-16:
  // gear 25, psionics 6, skills 27, spells 8).
  //
  // `talents` was missing too - the ninth catalog, added to four other hand
  // lists in F76 and not to this one, which nothing knew was a fifth. The smoke
  // check `every catalog is in every hand-written catalog list` now reads this
  // map as text and fails if a CATALOGS key is absent.
  const CATALOGS = {
    gear: ['gear', 'slug'],
    skills: ['skills', 'name'],
    spells: ['spells', 'name'],
    psionics: ['psionic_powers', 'name'],
    enchantments: ['enchantments', 'slug'],
    vehicles: ['vehicles', 'slug'],
    totems: ['totems', 'slug'],
    superAbilities: ['super_abilities', 'name'],
    talents: ['talents', 'name'],
    // Keyed on `key`, not `name`: a Morphus entry's name repeats across tables
    // (migration 068), so a retired name would match rows in other tables.
    morphus: ['morphus_characteristics', 'key'],
  };

  // A catalog the redirect table uses that this map does not know would be
  // skipped IN SILENCE, and a check that can stop covering something without
  // saying so is the shape regression.yml's own header refuses. Fail loudly.
  const used = q('SELECT DISTINCT catalog FROM catalog_redirects').map((r) => r.catalog);
  const unmapped = used.filter((c) => !CATALOGS[c]);
  check('every catalog the redirect table uses is one this check knows',
    unmapped.length === 0, unmapped.join(', '));

  const onRetired = [];
  for (const [cat, [table, key]] of Object.entries(CATALOGS)) {
    const rows = q(`SELECT t.${key} AS k FROM ${table} t `
      + `JOIN catalog_redirects r ON r.catalog = '${cat}' AND r.from_key = t.${key} `
      + `JOIN ${table} live ON live.id = r.to_id`);
    for (const row of rows) onRetired.push(`${cat}: ${row.k}`);
  }
  check('no live catalog row sits on a key a redirect has retired',
    onRetired.length === 0, onRetired.join(', '));
}

// ---------- a class that supersedes its race ----------
// BOOK-INGEST-AUDIT.md F11. The Cosmo-Knight is a transformation: the entry
// prints its own dice, M.D.C. and P.P.E., and its skills line says the skills
// of the past life are lost. Composed race-first it arrived wrong in 56 of its
// 57 possible pairings.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const races = classes.filter((c) => c.category === 'rcc');
  const flagged = classes.filter((c) => c.supersedes_race === true);

  // The flag is opt-in and only an O.C.C. can act on it.
  const misplaced = flagged.filter((c) => c.category !== 'occ');
  check('every class declaring supersedes_race is an O.C.C.',
    misplaced.length === 0, misplaced.map((c) => c.id).join(', '));

  // The mean of an attribute expression, computed here rather than imported, so
  // this checks the parser's answer instead of restating it.
  const reach = (e) => {
    const m = String(e ?? '').trim().match(/^(\d+)d(\d+)(?:x(\d+))?(?:([+-])(\d+))?$/i);
    if (!m) return null;
    const mult = m[3] ? +m[3] : 1;
    return ((+m[1] + (+m[1] * +m[2])) * mult) / 2 + (m[4] ? (m[4] === '-' ? -1 : 1) * +m[5] : 0);
  };

  const lostPool = [], carried = [], weaker = [], invented = [];
  let pairs = 0;
  for (const occ of flagged) {
    const own = new Set((occ.skills?.occ_skills || []).filter((e) => e?.name).map((e) => e.name));
    for (const r of races) {
      pairs++;
      const c = combineClasses(r, occ);

      // The transformed body is the class's, not the race's.
      for (const k of ['hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base', 'starting_money']) {
        if (occ[k] != null && c[k] !== occ[k]) lostPool.push(`${r.id}+${occ.id}: ${k}`);
      }
      // "the skills of his past life are lost and the character is reborn"
      const through = (c.skills?.occ_skills || []).filter((e) => e?.name && !own.has(e.name));
      if (through.length) carried.push(`${r.id}+${occ.id}: ${through.length}`);

      // Attributes are the carve-out: whichever reaches higher, per attribute,
      // and never below what the class prints on its own.
      for (const a of ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd']) {
        const got = c.attribute_dice?.[a];
        if (got == null) continue;
        if (got !== occ.attribute_dice?.[a] && got !== r.attribute_dice?.[a]) {
          invented.push(`${r.id}+${occ.id}: ${a}`);
        }
        const mine = reach(occ.attribute_dice?.[a]), now = reach(got);
        if (mine != null && now != null && now < mine) weaker.push(`${r.id}+${occ.id}: ${a} ${got} < ${occ.attribute_dice[a]}`);
      }
    }
  }
  check('a superseding class composes against every race',
    flagged.length === 0 || pairs === flagged.length * races.length,
    `${flagged.length} flagged x ${races.length} races = ${pairs}`);
  check('and keeps its own pools rather than the race\'s',
    lostPool.length === 0, lostPool.slice(0, 5).join('; '));
  check('and no past-life skill survives the transformation',
    carried.length === 0, carried.slice(0, 5).join('; '));
  check('and no attribute comes out below what the class prints alone',
    weaker.length === 0, weaker.slice(0, 5).join('; '));
  check('and every attribute expression is one of the two, never invented',
    invented.length === 0, invented.slice(0, 5).join('; '));

  // THE POSTURE. Every class WITHOUT the flag must compose exactly as it did
  // before F11 - race-primary, pools from the race wherever it states them.
  const plain = classes.filter((c) => c.category === 'occ' && c.supersedes_race !== true);
  const drifted = [];
  for (const occ of plain.slice(0, 25)) {
    for (const r of races.slice(0, 12)) {
      const c = combineClasses(r, occ);
      for (const k of ['mdc_base', 'ppe_base', 'sdc_base']) {
        if (r[k] != null && c[k] !== r[k]) drifted.push(`${r.id}+${occ.id}: ${k}`);
      }
    }
  }
  check('and an occupation without the flag still loses its pools to the race',
    drifted.length === 0, drifted.slice(0, 5).join('; '));
}

// ---------- a pool formula copied from its neighbour ----------
// BOOK-INGEST-AUDIT.md F17. The Crazy's `isp_base` was "6d6" where its book
// prints "6D6 plus the M.E. attribute number, +1D6 per level" - and two lines
// below on the same page sits "P.P.E. Base: 6D6 P.P.E.", which the class stores
// correctly. Two adjacent figures, identical at a glance, only one carrying the
// extra terms.
//
// An INVARIANT rather than a fix: a class whose I.S.P. and P.P.E. formulas are
// the identical string is not proof of anything, but it is the shape this error
// takes and it costs one comparison to ask. Zero across the corpus after F17.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const twins = classes.filter((c) => {
    const isp = c.psionics?.isp_base, ppe = c.ppe_base;
    return isp && ppe && String(isp).trim().toLowerCase() === String(ppe).trim().toLowerCase();
  });
  check('no class states the same formula for its I.S.P. and its P.P.E.',
    twins.length === 0,
    twins.map((c) => `${c.id}: ${c.ppe_base}`).join('; ')
      + ' - check the page; the two sit next to each other in a stat block');
}

// ---------- psionic category vocabulary ----------
// BOOK-INGEST-AUDIT.md F15. `categories_allowed` gates the psionic picker by
// EXACT category name, and the Crazy asked for "Psychic Sensitive" and
// "Physical Psychic" - the words its own book prints, and not the words the
// catalog files powers under. Three starting picks from a pool of nothing, and
// nothing said so.
//
// This is the psionic twin of the restriction failure class-import documents:
// six classes naming `Robots and Power Armor` after the catalog renamed that
// row. An unmatched name fails silently. It fails CLOSED here, which is the
// safer direction and the reason it went unnoticed.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const cats = new Set(((await api('GET', '/catalogs')).body.psionics || [])
    .map((p) => String(p.category ?? '').trim().toLowerCase()).filter(Boolean));

  const powerNames = new Set(((await api('GET', '/catalogs')).body.psionics || [])
    .map((p) => String(p.name ?? '').trim().toLowerCase()).filter(Boolean));
  const orphans = [];
  const deadNames = [];
  let entries = 0;
  for (const c of classes) {
    const blocks = [c.psionics, ...((c.special_abilities || [])
      .filter((d) => d && typeof d === 'object' && d.psionics).map((d) => d.psionics))];
    for (const p of blocks) {
      for (const entry of (p?.categories_allowed || [])) {
        entries++;
        // An entry is a plain string or an object narrowing itself with
        // only/except since F16, so the NAME is what has to resolve.
        const name = typeof entry === 'string' ? entry : entry?.name;
        if (!cats.has(String(name).trim().toLowerCase())) orphans.push(`${c.id}: ${name}`);
        // And a narrowing that names a power the catalog does not carry
        // excludes nothing, silently - the Robots and Power Armor failure,
        // on the psionic side. "Object Read" is that trap here: the row is
        // "Object Read (Psychometry)".
        for (const key of ['only', 'except']) {
          for (const n of (entry && typeof entry === 'object' && entry[key]) || []) {
            if (!powerNames.has(String(n).trim().toLowerCase())) {
              deadNames.push(`${c.id}: ${key} "${n}"`);
            }
          }
        }
      }
    }
  }
  check('the psionic catalog reports categories at all', cats.size >= 4, [...cats].join(', '));
  check('every categories_allowed entry names a category the catalog has',
    entries > 0 && orphans.length === 0,
    `${orphans.length} of ${entries} resolve to nothing: ${orphans.slice(0, 6).join('; ')}`);
  check('and every only/except inside one names a power it has',
    deadNames.length === 0,
    `${deadNames.length} exclude or admit nothing: ${deadNames.slice(0, 6).join('; ')}`);
}

// ---------- magic composition ----------
// BOOK-INGEST-AUDIT.md F14, the magic half of F10. Thirteen races and eighteen
// occupations state `magic`; before the merge the occupation won all 234 pairs
// outright, with no comparison at all.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const races = classes.filter((c) => c.category === 'rcc' && c.magic);
  const occs = classes.filter((c) => c.category === 'occ' && c.magic);
  const norm = (x) => String((typeof x === 'string' ? x : x?.name) ?? '').trim().toLowerCase();

  const lostSpells = [], lostLevels = [], weakened = [], wrongType = [];
  let pairs = 0;
  for (const r of races) {
    for (const o of occs) {
      pairs++;
      const c = combineClasses(r, o).magic || {};
      const held = new Set((c.spells || []).map(norm));
      for (const x of [...(r.magic.spells || []), ...(o.magic.spells || [])]) {
        if (!held.has(norm(x))) lostSpells.push(`${r.id}+${o.id}: ${norm(x)}`);
      }
      const levels = new Set(c.spell_levels_allowed || []);
      for (const L of [...(r.magic.spell_levels_allowed || []), ...(o.magic.spell_levels_allowed || [])]) {
        if (!levels.has(L)) lostLevels.push(`${r.id}+${o.id}: level ${L}`);
      }
      for (const k of ['spells_starting', 'spells_per_level']) {
        const floor = Math.max(Number.isFinite(r.magic[k]) ? r.magic[k] : -Infinity,
                               Number.isFinite(o.magic[k]) ? o.magic[k] : -Infinity);
        if (floor > -Infinity && !(c[k] >= floor)) weakened.push(`${r.id}+${o.id}: ${k} ${c[k]} < ${floor}`);
      }
      // The type is a KIND, not a degree - the occupation's statement about how
      // it casts must not be overwritten by a race's generic "spell".
      if (o.magic.type !== undefined && c.type !== o.magic.type) {
        wrongType.push(`${r.id}+${o.id}: ${c.type} not ${o.magic.type}`);
      }
    }
  }
  check('every magic race composes with every magic occupation',
    pairs === races.length * occs.length && pairs > 0,
    `${races.length} races x ${occs.length} occupations = ${pairs}`);
  check('and no granted spell is lost to composition',
    lostSpells.length === 0, lostSpells.slice(0, 5).join('; '));
  check('and no allowed spell level is lost',
    lostLevels.length === 0, lostLevels.slice(0, 5).join('; '));
  check('and no starting count comes out below what either side states alone',
    weakened.length === 0, weakened.slice(0, 5).join('; '));
  check('and the magic TYPE is the occupation\'s wherever it states one',
    wrongType.length === 0, wrongType.slice(0, 5).join('; '));
}

// ---------- psionics composition ----------
// BOOK-INGEST-AUDIT.md F10. Composing a psychic race with a psychic occupation
// used to keep ONE of the two blocks and throw the other away entire. Measured
// on the live catalog the day it was fixed: 19 races and 19 occupations state
// psionics, and 113 of their 361 pairings discarded a block with content in it.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const races = classes.filter((c) => c.category === 'rcc' && c.psionics);
  const occs = classes.filter((c) => c.category === 'occ' && c.psionics);
  const norm = (x) => String((typeof x === 'string' ? x : x?.name) ?? '').trim().toLowerCase();

  const lostPowers = [];
  const lostCats = [];
  const weakened = [];
  const droppedTier = [];
  const noIsp = [];
  let pairs = 0;
  for (const r of races) {
    for (const o of occs) {
      pairs++;
      const c = combineClasses(r, o).psionics || {};
      const R = r.psionics, O = o.psionics;

      // Nothing either side grants outright may vanish. This is the finding.
      const held = new Set((c.powers || []).map(norm));
      for (const x of [...(R.powers || []), ...(O.powers || [])]) {
        if (!held.has(norm(x))) lostPowers.push(`${r.id}+${o.id}: ${norm(x)}`);
      }
      const cats = new Set((c.categories_allowed || []).map(norm));
      for (const x of [...(R.categories_allowed || []), ...(O.categories_allowed || [])]) {
        if (!cats.has(norm(x))) lostCats.push(`${r.id}+${o.id}: ${norm(x)}`);
      }

      // A count may never come out below what either side states ALONE. Written
      // as an inequality rather than a rule, because the rule is what is being
      // tested: preferring the occupation's figure - which is what F10 asked
      // for - is lower in the majority of these pairs.
      for (const k of ['powers_starting', 'powers_per_level']) {
        const floor = Math.max(Number.isFinite(R[k]) ? R[k] : -Infinity,
                               Number.isFinite(O[k]) ? O[k] : -Infinity);
        if (floor > -Infinity && !(c[k] >= floor)) weakened.push(`${r.id}+${o.id}: ${k} ${c[k]} < ${floor}`);
      }

      // The tier is the one thing the pre-F10 comment was right about.
      const rank = (t) => ['minor', 'major', 'master'].indexOf(norm(t));
      if (rank(c.type) < Math.max(rank(R.type), rank(O.type))) droppedTier.push(`${r.id}+${o.id}`);

      // An I.S.P. formula is always one of the two, never invented and never
      // blanked - the Godling lost its formula this way to an ability grant.
      if ((R.isp_base || O.isp_base) && !c.isp_base) noIsp.push(`${r.id}+${o.id}: blanked`);
      if (c.isp_base && c.isp_base !== R.isp_base && c.isp_base !== O.isp_base) noIsp.push(`${r.id}+${o.id}: invented`);
    }
  }
  check('every psychic race composes with every psychic occupation',
    pairs > 0 && races.length > 0 && occs.length > 0, `${races.length} races x ${occs.length} occupations`);
  check('and no granted psionic power is lost to composition',
    lostPowers.length === 0, lostPowers.slice(0, 5).join('; '));
  check('and no allowed category is lost',
    lostCats.length === 0, lostCats.slice(0, 5).join('; '));
  check('and no starting count comes out below what either side states alone',
    weakened.length === 0, weakened.slice(0, 5).join('; '));
  check('and the tier is never below the stronger half',
    droppedTier.length === 0, droppedTier.slice(0, 5).join('; '));
  check('and the I.S.P. formula is always one of the two',
    noIsp.length === 0, noIsp.slice(0, 5).join('; '));
}

// ---------- per-category skill floors ----------
// BOOK-INGEST-AUDIT.md F6. Published classes print "select N other skills, but
// at least two must be selected from espionage" or its like, and every one of
// them offered all its picks freely until `minimums` existed.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];

  // Asserted as an INVARIANT rather than a list of ids. A count would pass
  // forever while the next book imported the next one as prose - which is
  // exactly how the first ten sat for months. The question asked here is "does
  // any class STATE a floor it does not HOLD".
  //
  // WIDENED BY RETRO-AUDIT R16, because this comment used to claim it "catches
  // the next one" and then did not - twice in two days. R14 gave five classes a
  // floor and R15 two more, and it saw NONE of the seven:
  //
  //   1. it read the BLOCK note only, and all five of R14's state their floor
  //      in a per-CATEGORY note;
  //   2. it matched "at least" / "no fewer than" only, and R15's two say
  //      "must be from".
  //
  // So it now reads both places and five verbs. Derived over the live corpus
  // before being written here: 29 classes match and all 29 hold a floor, up
  // from 11 - the 18 new ones being R14's five, R15's two, the ten Warlocks and
  // the assassin.
  //
  // TWO THINGS TO KNOW BEFORE TOUCHING THE PATTERN.
  //
  // The numeral must stay ADJACENT to the phrase. `naruni-repo-bot` says "this
  // book does it in at least a dozen entries and five is the most any of them
  // bars" - not a floor, and it holds none. It misses only because "a dozen" is
  // not a numeral; loosen that branch, or match a number anywhere in the same
  // sentence, and that class goes red.
  //
  // `techno-wizard` prints a SIXTH phrasing this still does not catch - "TWO of
  // the seven must be Electrical or Mechanical skills", with no "from". It
  // holds its floor, so the check is silent rather than wrong, and it is left
  // as the standing example of what a hand-maintained phrase list costs. The
  // fix for that is to read the SHAPE - a floor sentence beside no `minimums` -
  // which is a bigger change than R16 asked for.
  const NUM = '(?:one|two|three|four|five|six|seven|eight|nine|ten|\\d+)';
  const FLOOR_PHRASE = new RegExp([
    `(?:at least|no fewer than)\\s+${NUM}\\b`,
    `\\b${NUM}\\b[^.]{0,80}?must\\s+(?:be|come)\\s+(?:from|selected\\s+from)`,
  ].join('|'), 'i');

  // A floor can be written in the block note or in any category note, so both
  // are searched. A `categories` entry is a bare STRING or an object - 716 and
  // 900 of them respectively across the live corpus - so reading `e.note`
  // without the typeof guard is a TypeError on nearly half the entries.
  const floorText = (rel) => {
    if (!rel) return '';
    const cats = Array.isArray(rel.categories) ? rel.categories : [];
    return [rel.note || '', ...cats.map((e) => (typeof e === 'string' ? '' : (e?.note || '')))]
      .filter(Boolean).join(' ');
  };

  const statesFloor = classes.filter((c) => FLOOR_PHRASE.test(floorText(c.skills?.occ_related_skills)));
  const unheld = statesFloor.filter((c) => !(c.skills.occ_related_skills.minimums || []).length);
  check('every class whose note states a per-category floor also holds one',
    statesFloor.length > 0 && unheld.length === 0,
    `${unheld.length} of ${statesFloor.length} state a floor and hold none: ${unheld.map((c) => c.id).join(', ')}`);

  // A floor naming a category the class does not grant would refuse EVERY
  // character of that class - the worst failure this key can have, and one the
  // parser rejects at load. Re-checked against live data because a CATEGORY
  // RENAME breaks it later, the same way a rename broke six classes' `except`
  // restrictions and nothing routine said so.
  const norm = (x) => String((typeof x === 'string' ? x : x?.name) ?? '').trim().toLowerCase();
  const orphaned = [];
  const oversized = [];
  for (const c of classes) {
    const rel = c.skills?.occ_related_skills;
    const mins = rel?.minimums || [];
    if (!mins.length) continue;
    const granted = new Set((rel.categories || []).map(norm));
    for (const m of mins) {
      const cats = Array.isArray(m.categories) ? m.categories : [m.category];
      for (const cat of cats) {
        if (!granted.has(norm(cat))) orphaned.push(`${c.id}: ${cat}`);
      }
    }
    const sum = mins.reduce((n, m) => n + (m.count || 0), 0);
    if (sum > rel.count) oversized.push(`${c.id}: ${sum} > ${rel.count}`);
  }
  check('every floor names a category its class actually grants',
    orphaned.length === 0, orphaned.join('; '));
  check('and no class floors more picks than it grants',
    oversized.length === 0, oversized.join('; '));
}

// ---------- race and O.C.C. restrictions ----------
// Printed 21: not all O.C.C.s are open to every race. Eight of the fourteen
// Palladium races print a real limit, and until `occ_restrictions` landed the
// prose was display-only - the player was told and nothing stopped them.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const byId = Object.fromEntries(classes.map((c) => [c.id, c]));

  // Asserted as an INVARIANT rather than a count. This used to read
  // `grouped.length === 25` and passed happily for months while all 34 Rifts
  // O.C.C.s carried no group at all - so a `group:` token matched nothing on
  // the Rifts side, and a race written with one would have failed CLOSED as an
  // `only` or, far worse, OPEN as an `except`. A hardcoded number cannot see
  // that; "every occupation has a group" can, and it catches the next O.C.C.
  // imported without one instead of waiting for a race to trip over it.
  const occs = classes.filter((c) => c.category === 'occ');
  const ungrouped = occs.filter((c) => !c.occ_group);
  check('every O.C.C. carries the group its book section gives it',
    occs.length > 0 && ungrouped.length === 0,
    `${ungrouped.length} of ${occs.length} ungrouped: ${ungrouped.map((c) => c.id).join(', ')}`);

  const grouped = classes.filter((c) => c.occ_group);
  const badGroup = grouped.filter((c) => !OCC_GROUPS.includes(c.occ_group));
  check('and every group is one of the five the book prints',
    badGroup.length === 0, badGroup.map((c) => `${c.id}=${c.occ_group}`).join(', '));
  const wrongSide = classes.filter((c) => (c.occ_group && c.category !== 'occ')
    || (c.occ_restrictions && c.category !== 'rcc'));
  check('a group is on an O.C.C. and a restriction on a race, never the other way',
    wrongSide.length === 0, wrongSide.map((c) => c.id).join(', '));

  // The eight Palladium races the rule was written for are NAMED rather than
  // counted, so importing a race that carries a restriction of its own - the
  // Norse Giant and the Warriors of Valhalla were the first - adds to this list
  // instead of breaking it, while a Palladium race silently LOSING its
  // restriction still fails. A bare count could not tell those two apart.
  const restricted = classes.filter((c) => c.occ_restrictions);
  const PALLADIUM_RESTRICTED = ['dwarf', 'gnome', 'goblin', 'hob-goblin', 'kobold',
    'orc', 'troglodyte', 'troll'];
  const lost = PALLADIUM_RESTRICTED.filter((id) => !restricted.some((r) => r.id === id));
  check('the eight Palladium races still carry their restrictions',
    lost.length === 0, 'missing: ' + lost.join(', '));

  // THE HAZARD. A name with no class silently ALLOWS what it meant to forbid,
  // and nothing else in the app would ever say so.
  const dangling = [];
  for (const r of restricted) {
    for (const n of (r.occ_restrictions.only || r.occ_restrictions.except || [])) {
      if (String(n).startsWith('group:')) continue;
      if (!byId[n] || byId[n].category !== 'occ') dangling.push(`${r.id} -> ${n}`);
    }
  }
  check('and every occupation they name is a real O.C.C.',
    dangling.length === 0, dangling.join(', '));

  // A closed list or an open one, never both, and never empty.
  const shape = restricted.filter((r) => {
    const o = Array.isArray(r.occ_restrictions.only);
    const e = Array.isArray(r.occ_restrictions.except);
    return (o && e) || (!o && !e)
      || (o && !r.occ_restrictions.only.length) || (e && !r.occ_restrictions.except.length);
  });
  check('each states only or except, never both and never empty',
    shape.length === 0, shape.map((r) => r.id).join(', '));

  // ── A RESTRICTION ON THE CHOICE GROUP INSTEAD OF ON THE CATEGORY ─────────
  //
  // BOOK-INGEST-AUDIT.md F84. `categoryAllows` reads only/except/only_prefix/
  // except_prefix off the CATEGORY ENTRY matching the skill's own category, and
  // returns true outright for a bare string entry. The same four keys written
  // one level out - beside `choose`, `categories` and `bonus`, where they read
  // as if they belong - are stored and never looked at.
  //
  // IT FAILS OPEN IN BOTH DIRECTIONS. An ignored `only` or `only_prefix` means
  // the whole category; an ignored `except`/`except_prefix` means nothing is
  // excluded. Both grant MORE than the book allows, so a player sees a longer
  // list and nothing anywhere complains. `class-check` reports such a class
  // `ready`: every NAME is real, and the names were never the problem.
  //
  // The Night Witch shipped this way and offered all 87 Technical skills where
  // printed 116 gives it a choice of four lores - measured by calling
  // categoryAllows over the live catalog, 87 against 4. It is the only hit this
  // sweep has ever had, out of 803 choice groups, and it is fixed in
  // zzzzzzz-fix-night-witch-lore-scope.sql. This pins the sweep so it cannot
  // come back while the parser still accepts the shape.
  const GROUP_LEVEL_KEYS = ['only', 'except', 'only_prefix', 'except_prefix'];
  const misScoped = [];
  const walkGroups = (id, where, entries) => {
    for (const e of entries || []) {
      if (!isChoiceGroup(e)) continue;
      const bad = GROUP_LEVEL_KEYS.filter((k) => e[k] !== undefined);
      if (bad.length) misScoped.push(`${id} ${where}: ${bad.join('/')}`);
    }
  };
  for (const c of classes) {
    const s = c.skills || {};
    walkGroups(c.id, 'occ_skills', s.occ_skills);
    walkGroups(c.id, 'related', s.occ_related_skills?.entries);
    walkGroups(c.id, 'secondary', s.occ_secondary_skills?.entries);
    for (const o of s.mos?.options || []) walkGroups(c.id, `mos:${o.id || o.name}`, o.skills);
  }
  check('no choice group restricts on the GROUP instead of on the category',
    misScoped.length === 0, misScoped.join(', '));

  // The rules themselves, through the resolver a player hits.
  const CASES = [
    ['dwarf', 'wizard', false], ['dwarf', 'knight', true], ['dwarf', 'psi-healer', true],
    ['kobold', 'knight', false], ['kobold', 'thief', true],
    ['troll', 'mind-mage', false], ['troll', 'witch', true],
    ['troglodyte', 'warrior-monk', true], ['troglodyte', 'wizard', false],
    ['gnome', 'wizard', true], ['gnome', 'knight', false],
    ['orc', 'priest-of-darkness', true], ['orc', 'priest-of-light', false],
    // The goblin may take the occasional psychic and the hob-goblin may not,
    // which is the pair that proves this is reading the data and not a habit.
    ['goblin', 'psi-healer', true], ['hob-goblin', 'psi-healer', false],
    ['human', 'wizard', true],
    // ---- Heroes Unlimited, printed 27 and printed 56 ----------------------
    //
    // Every Power Category rolls its schooling on the Educational Level table
    // on printed 27 - except the ALIEN, which rolls there and is then sent to
    // a five-outcome table of its own on printed 56 that REPLACES it. So the
    // Alien takes one of its own five and none of the eleven, and the other
    // eight Power Categories take any of the eleven and none of the Alien's.
    //
    // BOTH DIRECTIONS ARE PINNED because a restriction that fails OPEN is the
    // failure mode: `except` naming nothing removes nothing, and an `only`
    // silently dropped admits everything. Each pair below would pass with the
    // restriction deleted if only its own direction were checked.
    ['hu-aliens', 'hu-alien-edu-engineer', true],
    ['hu-aliens', 'hu-edu-doctorate', false],
    ['hu-aliens', 'hu-edu-high-school', false],
    ['hu-mutants', 'hu-edu-doctorate', true],
    ['hu-mutants', 'hu-alien-edu-engineer', false],
    ['hu-hardware', 'hu-edu-trade-school', true],
    ['hu-hardware', 'hu-alien-edu-combat-specialist', false],
    ['hu-physical-training', 'hu-alien-edu-general-studies', false],
  ];
  const wrongCase = CASES.filter(([race, occ, want]) =>
    occAllowedForRace(byId[race], byId[occ]).allowed !== want);
  check('every race and occupation pair resolves the way the book reads',
    wrongCase.length === 0, wrongCase.map(([r, o]) => `${r}+${o}`).join(', '));

  // -- and the server refuses one ------------------------------------------
  // The wizard disables the option; a disabled <option> is a hint, not a rule.
  const refused = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Dwarf Wizard', class_id: 'dwarf', occ_class_id: 'wizard',
    attributes: attrs, abilities: [],
  });
  check('the server refuses a dwarf wizard', refused.status === 400, refused.body);
  check('and says why, in words a player can read',
    /dwarf/i.test(JSON.stringify(refused.body)) && /wizard/i.test(JSON.stringify(refused.body)),
    JSON.stringify(refused.body));

  const allowed = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Dwarf Knight', class_id: 'dwarf', occ_class_id: 'knight',
    attributes: attrs, abilities: [],
  });
  check('and allows a dwarf knight', [200, 201].includes(allowed.status), allowed.body);

  // A race with no restriction must not be caught by the check at all.
  const human = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Human Wizard', class_id: 'human', occ_class_id: 'wizard',
    attributes: attrs, abilities: [],
  });
  check('a race that restricts nothing is unaffected',
    [200, 201].includes(human.status), human.body);
}

// ---------- the mirror: which races may take an occupation ----------
// A Juicer's abilities add to an existing person, and the book is specific
// about which person: "Racial Requirement: 95% human" (RUE p.81). Rifts prints
// no Human R.C.C. - its contents list exactly one Racial Character Class, the
// Dragon Hatchling - because human is the default and the unstated. So the
// human case is the ABSENCE of a race, which is what the reserved `none` says.
{
  const classes = (await api('GET', '/classes?limit=200')).body.classes || [];
  const byId = Object.fromEntries(classes.map((c) => [c.id, c]));

  const restricted = classes.filter((c) => c.race_restrictions);
  // NAMED, not counted. This read `restricted.length === 7` until the Juicer
  // Uprising import took it to twelve in one go, and it would have had to be
  // bumped again with every batch while proving less each time - the same
  // lesson the FOUNDING list below already records. What matters is that the
  // seven the rule was written against still carry their bar.
  const RACE_BARRED = ['juicer', 'psi-stalker', 'wild-psi-stalker', 'coalition-grunt',
    'coalition-samas-pilot', 'coalition-technical-officer', 'dog-boy'];
  const lostBar = RACE_BARRED.filter((id) => !restricted.some((c) => c.id === id));
  check('every O.C.C. the race bar was written against still carries it',
    lostBar.length === 0, `no longer restricted: ${lostBar.join(', ')}`);
  const onOcc = restricted.every((c) => c.category === 'occ');
  check('and every one of them is an O.C.C.', onOcc);

  // Every entry must resolve, the same hazard the other direction carries.
  const dangling = [];
  for (const c of restricted) {
    for (const n of (c.race_restrictions.only || c.race_restrictions.except || [])) {
      if (n === RACE_NONE) continue;
      if (!byId[n] || byId[n].category !== 'rcc') dangling.push(`${c.id} -> ${n}`);
    }
  }
  check('and names only real races, or the reserved "none"',
    dangling.length === 0, dangling.join(', '));

  // The reserved word is the whole mechanism: without it "human only" has no
  // race to name, because Rifts prints none.
  const humanOnly = restricted.filter((c) => (c.race_restrictions.only || []).includes(RACE_NONE));
  // Every bar in the catalog admits the human case, and a new one that forgets
  // to is a real bug rather than a moving number - so this compares the two
  // populations instead of counting either.
  //
  // EXCEPT the O.C.C.s that are one race's OWN training, which the book offers
  // to nobody else. The Nightbane's four skill packages and the Nightbane
  // Sorcerer and Mystic (Nightbane RPG printed 88-90, 118-120) exist only as a
  // Nightbane's half of a pairing - survey D2, DECIDED in #1124, restricts them
  // both ways - and a human cannot be one, so admitting RACE_NONE would offer a
  // human character a Nightbane package. NAMED, so a new bar that forgets the
  // human case still fails here; an exemption has to be argued into this list.
  const RACE_OWN_TRAINING = ['nb-package-basic', 'nb-package-resistance', 'nb-package-nocturne',
    'nb-package-warlord', 'nb-nightbane-sorcerer', 'nb-nightbane-mystic'];
  const barsHumans = restricted.filter((c) => !RACE_OWN_TRAINING.includes(c.id));
  check(`and every restricted O.C.C. keeps the reserved "${RACE_NONE}" for the human case`,
    humanOnly.length === barsHumans.length && humanOnly.every((c) => barsHumans.includes(c)),
    `${humanOnly.length} of ${barsHumans.length}`);
  const ownTrainingShipped = restricted.filter((c) => RACE_OWN_TRAINING.includes(c.id));
  check('and the race-own-training O.C.C.s refuse a character with no race',
    ownTrainingShipped.length === RACE_OWN_TRAINING.length
      && ownTrainingShipped.every((c) => !raceAllowedForOcc(c, null).allowed),
    ownTrainingShipped.map((c) => c.id).join(', '));

  // The rule itself. A Juicer with no race is a human Juicer and is fine; a
  // Juicer paired with any of the three Rifts races is not.
  const juicer = byId.juicer;
  check('a Juicer with no race is the human case, and allowed',
    raceAllowedForOcc(juicer, null).allowed);
  // Named rather than counted, for the same reason as the restricted races
  // above: the Norse block added five more Rifts races and every one of them
  // must be refused too, so a count of three would have had to grow with each
  // import while proving less each time. What matters is that the three the
  // rule was written against are still present AND that the check below sees
  // every Rifts race there is.
  const rifts = classes.filter((c) => c.category === 'rcc' && c.system === 'rifts');
  const FOUNDING = ['dragon-hatchling', 'godling', 'demigod'];
  const goneMissing = FOUNDING.filter((id) => !rifts.some((r) => r.id === id));
  check('the Rifts races are still there to be refused',
    goneMissing.length === 0 && rifts.length >= FOUNDING.length,
    `${rifts.length} races, missing: ${goneMissing.join(', ')}`);
  const wronglyAllowed = rifts.filter((r) => raceAllowedForOcc(juicer, r).allowed);
  check('and every one of them is closed to a Juicer',
    wronglyAllowed.length === 0, wronglyAllowed.map((r) => r.id).join(', '));

  // An O.C.C. with no race_restrictions must be unaffected in both directions.
  check('an occupation that bars nothing takes any race',
    raceAllowedForOcc(byId['ley-line-walker'], byId['dragon-hatchling']).allowed);

  // -- and the server refuses the pairing -----------------------------------
  const refused = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Dragon Juicer', class_id: 'dragon-hatchling',
    occ_class_id: 'juicer', attributes: attrs, abilities: [],
  });
  check('the server refuses a Dragon Hatchling Juicer', refused.status === 400, refused.body);
  check('and names the occupation and the race',
    /juicer/i.test(JSON.stringify(refused.body)) && /dragon/i.test(JSON.stringify(refused.body)),
    JSON.stringify(refused.body));

  // The same race with an occupation that does not bar it still works, so the
  // refusal is the rule and not the pairing.
  const ok = await api('POST', '/characters', {
    campaign_id: campaignId, name: 'Dragon Walker', class_id: 'dragon-hatchling',
    occ_class_id: 'ley-line-walker', attributes: attrs, abilities: [],
  });
  check('while a Dragon Hatchling Ley Line Walker is allowed',
    [200, 201].includes(ok.status), ok.body);

  // -- every gear id a class cites must resolve -----------------------------
  //
  // A class grants equipment by slug. A slug with no row and no redirect is a
  // character starting play holding something that does not exist, and nothing
  // else in the app notices - the wizard renders the name it was given.
  //
  // Three ids were retired from the README's outstanding list by correcting
  // the classes that cited them rather than by leaving a redirect behind, so
  // the thing worth asserting is not a list of names in prose but that the
  // citations still land.
  // /items returns redirects as an OBJECT keyed by the lowercased retired slug,
  // not an array, so both sides are compared lowercased.
  const gearSlugs = new Set((items.body.items || []).map((i) => String(i.slug).toLowerCase()));
  for (const k of Object.keys(items.body.redirects || {})) gearSlugs.add(k.toLowerCase());
  const cited = new Map();
  for (const c of classes) {
    for (const m of JSON.stringify(c).matchAll(/"item_id":"([^"]+)"/g)) {
      if (!cited.has(m[1])) cited.set(m[1], c.id);
    }
  }
  const unresolved = [...cited].filter(([slug]) => !gearSlugs.has(slug.toLowerCase()));
  check('every gear id a class cites resolves to a row or a redirect',
    unresolved.length === 0, unresolved.map(([s2, c]) => `${s2} (${c})`).join(', '));
  check('and the check actually looked at some', cited.size > 50, `${cited.size} cited ids`);
}

// ---------- enchantments ----------
// What an alchemist puts INTO a sword, as opposed to a sword. Printed 249-250
// sells three finished suits and then 32 PROPERTIES that go into ordinary gear,
// four to a suit and three to a weapon, cumulatively.
{
  const ench = catalogs.body.enchantments || [];
  check('/catalogs serves the enchantments catalog', ench.length === 62, `${ench.length} rows`);

  // Three families, and the book draws every one the same way: a property with
  // a price and a cap, instilled into ordinary gear.
  const armour = ench.filter((e) => e.applies_to === 'armor');
  const weapon = ench.filter((e) => e.applies_to === 'weapon');
  const charm = ench.filter((e) => e.applies_to === 'charm');
  check('eleven armour features, twenty-one weapon properties, thirty charm powers',
    armour.length === 11 && weapon.length === 21 && charm.length === 30,
    `${armour.length} / ${weapon.length} / ${charm.length}`);
  check('and nothing sits outside the three families',
    armour.length + weapon.length + charm.length === ench.length);

  // The book's caps, carried on the row so a picker enforces them from data.
  // Four to a suit; three to a weapon, and three to a ring.
  const wrongCap = ench.filter((e) => e.max_per_item !== (e.applies_to === 'armor' ? 4 : 3));
  check('and each carries the cap its family is given', wrongCap.length === 0,
    wrongCap.map((e) => `${e.slug}=${e.max_per_item}`).join(', '));

  // Color and Continual Glow are printed on BOTH sides at different prices, so
  // they are separate rows. A single row would have to pick one price and lie
  // about the other.
  for (const [a, b] of [['armor-color', 'weapon-color'],
    ['armor-continual-glow', 'weapon-continual-glow']]) {
    const x = ench.find((e) => e.slug === a);
    const y = ench.find((e) => e.slug === b);
    check(`${a} and ${b} are separate rows`, x && y && x.applies_to !== y.applies_to);
  }
  const colours = ench.filter((e) => e.name === 'Color');
  check('and the two Color rows keep their own prices',
    colours.length === 2 && new Set(colours.map((c) => c.cost)).size === 2,
    colours.map((c) => `${c.slug}=${c.cost}`).join(', '));

  // The whole affordability argument: bonuses reuse the block classes and
  // skills already use, so derive.js needs no new cases. If these stopped
  // validating, that claim would be false and nothing else would say so.
  const withBonuses = ench.filter((e) => e.bonuses);
  check('seven enchantments carry mechanical bonuses', withBonuses.length === 7,
    withBonuses.map((e) => e.slug).join(', '));

  // A bonus on a save the sheet does not render is stored, ignored, and
  // indistinguishable from one that works. Protection from Circles and from
  // Witches are real book bonuses with no save to land on, and are prose for
  // exactly that reason - so nothing here may name a key the sheet lacks.
  const SHEET_SAVES = new Set(['horror_factor', 'psionics', 'ritual_magic', 'spell_magic', 'wards']);
  const unrendered = withBonuses.flatMap((e) => Object.keys(e.bonuses.saves || {})
    .filter((k) => !SHEET_SAVES.has(k)).map((k) => `${e.slug}.${k}`));
  check('and no save bonus names a category the sheet cannot show',
    unrendered.length === 0, unrendered.join(', '));
  for (const slug of ['charm-protection-from-circles', 'charm-protection-from-witches']) {
    const row = ench.find((e) => e.slug === slug);
    check(`${slug} stays prose, having no save to land on`, row && !row.bonuses);
  }
  const badBonus = [];
  for (const e of withBonuses) {
    const errors = [], warnings = [];
    validateBonuses(e.bonuses, errors, warnings);
    if (errors.length) badBonus.push(`${e.slug}: ${errors.join('; ')}`);
  }
  check('and every one validates as a class or skill bonus block',
    badBonus.length === 0, badBonus.join(' | '));

  // Dice where the book prints dice. The Thunder Hammer's extra 2D6 is not a 2.
  const hammer = ench.find((e) => e.slug === 'thunder-hammer');
  check('the Thunder Hammer keeps its 2D6 as dice, not as a number',
    hammer?.bonuses?.combat?.damage === '2d6', JSON.stringify(hammer?.bonuses));
  const sharp = ench.find((e) => e.slug === 'eternally-sharp-blade');
  check('and the Eternally Sharp Blade keeps its flat +3',
    sharp?.bonuses?.combat?.damage === 3, JSON.stringify(sharp?.bonuses));

  // A price that is really a formula keeps the formula. Magic S.D.C. is the
  // most-used armour feature and the one gear.sdc exists to make possible.
  const magicSdc = ench.find((e) => e.slug === 'magic-sdc');
  check('Magic S.D.C. keeps its per-unit rate and its caps',
    magicSdc && magicSdc.cost === 2000 && /20 S\.D\.C\..*200.*100/.test(magicSdc.cost_note || ''),
    JSON.stringify(magicSdc?.cost_note));

  // The instance column, decoded. An item nobody has enchanted must read as an
  // empty array, not as null - a sheet mapping over it would throw.
  const held = await api('GET', `/characters/${charId}`);
  const anyItem = (held.body.items || [])[0];
  check('an unenchanted inventory row decodes to an empty array',
    anyItem && Array.isArray(anyItem.enchantments) && anyItem.enchantments.length === 0,
    JSON.stringify(anyItem?.enchantments));

  // -- instilling one, and everything the server must refuse ----------------
  //
  // The rules are the book's, and the server is where they live: the sheet is
  // not the only caller, and a stored slug that resolves to nothing renders as
  // a slug forever.
  // /items projects `category`, which is what says armour from weapon.
  const gearRows = (items.body.items || []).filter((g) => ['armor', 'weapon'].includes(g.category));
  const armourRow = gearRows.find((g) => g.category === 'armor');
  const weaponRow = gearRows.find((g) => g.category === 'weapon');
  check('the gear catalog has an armour and a weapon to enchant',
    !!armourRow && !!weaponRow, `${armourRow?.slug} / ${weaponRow?.slug}`);

  const addArm = await api('POST', `/characters/${charId}/items`, { slug: armourRow.slug, qty: 1 });
  const addWep = await api('POST', `/characters/${charId}/items`, { slug: weaponRow.slug, qty: 1 });
  check('both are added to the inventory',
    [200, 201].includes(addArm.status) && [200, 201].includes(addWep.status),
    `${addArm.status} / ${addWep.status}`);

  const after = await api('GET', `/characters/${charId}`);
  const armId = (after.body.items || []).find((i) => i.item_slug === armourRow.slug)?.id;
  const wepId = (after.body.items || []).find((i) => i.item_slug === weaponRow.slug)?.id;

  const ok1 = await api('PATCH', `/characters/${charId}/items/${armId}`,
    { enchantments: ['noiseless-armor', 'magic-sdc'] });
  check('two armour features go into a suit of armour', ok1.status === 200, ok1.body);

  const readBack = await api('GET', `/characters/${charId}`);
  const armAfter = (readBack.body.items || []).find((i) => i.id === armId);
  check('and come back as an array of slugs, not a string',
    Array.isArray(armAfter?.enchantments)
      && armAfter.enchantments.join(',') === 'noiseless-armor,magic-sdc',
    JSON.stringify(armAfter?.enchantments));

  // The instance, not the catalog: the weapon beside it is untouched.
  const wepAfter = (readBack.body.items || []).find((i) => i.id === wepId);
  check('the other item is not enchanted by association',
    Array.isArray(wepAfter?.enchantments) && wepAfter.enchantments.length === 0,
    JSON.stringify(wepAfter?.enchantments));

  const wrongFamily = await api('PATCH', `/characters/${charId}/items/${wepId}`,
    { enchantments: ['noiseless-armor'] });
  check('an armour feature is refused on a weapon', wrongFamily.status === 400, wrongFamily.body);

  const inWeapon = await api('PATCH', `/characters/${charId}/items/${wepId}`,
    { enchantments: ['charm-chameleon'] });
  check('and a charm power is refused on a weapon, as the book says',
    inWeapon.status === 400, inWeapon.body);

  const mixed = await api('PATCH', `/characters/${charId}/items/${armId}`,
    { enchantments: ['noiseless-armor', 'demon-slayer'] });
  check('one item cannot mix two families', mixed.status === 400, mixed.body);

  const overCap = await api('PATCH', `/characters/${charId}/items/${armId}`,
    { enchantments: ['noiseless-armor', 'magic-sdc', 'buoyancy', 'lightweight-armor',
      'weightless-armor'] });
  check('and five features will not fit in a suit that takes four',
    overCap.status === 400, overCap.body);

  const unknown = await api('PATCH', `/characters/${charId}/items/${armId}`,
    { enchantments: ['ring-of-not-a-thing'] });
  check('a slug the catalog does not have is refused', unknown.status === 400, unknown.body);

  // The cap is read off the row rather than hardcoded, so four must still fit.
  const four = await api('PATCH', `/characters/${charId}/items/${armId}`,
    { enchantments: ['noiseless-armor', 'magic-sdc', 'buoyancy', 'lightweight-armor'] });
  check('four features do fit, which is the cap the book prints', four.status === 200, four.body);

  const cleared = await api('PATCH', `/characters/${charId}/items/${armId}`, { enchantments: [] });
  check('and the list can be emptied again', cleared.status === 200, cleared.body);
}

// ---- the gear-citation sweep, against THIS database ----------------------
// Moved here from smoke.mjs (REBUILD-AUDIT.md F11). It used to run against the
// SHARED local database, so its answer depended on what that machine's
// .wrangler/state happened to hold - and that is not a property a merge gate
// should have. On a machine synced from production it passed while a database
// built from the repo cited ten gear slugs that exist in neither database,
// across five classes, because retire-gear-placeholders.sql deletes the
// placeholder rows with a guard that only sees fixed `item_id:` entries and
// never a choice group's `from:` list. Same blind spot class audit F2 found in
// retire-orphan-gear-stubs.sql.
//
// Here the database was built from nothing, minutes ago, so the question it
// answers is the one worth asking: can a REBUILD serve these classes?
{
  const sweepSql = join(state, 'gear-citations.sql');
  writeFileSync(sweepSql,
    "SELECT class_id, markdown FROM imported_classes WHERE status = 'published' AND deleted_at IS NULL;\n"
    + 'SELECT slug FROM gear;\n'
    + "SELECT from_key FROM catalog_redirects WHERE catalog = 'gear';\n");
  const sweep = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state,
    '--json', '--file', sweepSql]);

  // wrangler prefixes its own log line - "[string] [d1, execute, ...]" - so the
  // first "[" in the output is NOT the JSON. Take the first one that parses.
  let blocks = null;
  const sweepOut = sweep.stdout || '';
  for (let at = sweepOut.indexOf('['); at >= 0 && !blocks; at = sweepOut.indexOf('[', at + 1)) {
    try {
      const v = JSON.parse(sweepOut.slice(at));
      if (Array.isArray(v)) blocks = v;
    } catch { /* not the JSON yet */ }
  }
  check('the gear-citation sweep is queryable', Array.isArray(blocks) && blocks.length === 3,
    cleanErr(sweep.stderr || sweep.stdout));

  if (Array.isArray(blocks) && blocks.length === 3) {
    const sweepClasses = blocks[0].results || [];
    const known = new Set((blocks[1].results || []).map((r) => String(r.slug).toLowerCase()));
    for (const r of blocks[2].results || []) known.add(String(r.from_key).toLowerCase());

    const unparsed = [];
    const unresolved = [];
    const danglingWith = [];
    let cited = 0;
    let withLists = 0;
    for (const c of sweepClasses) {
      const p = parseClassMarkdown(c.markdown);
      if (!p.ok) { unparsed.push(c.class_id); continue; }
      for (const slug of referencedGear(p.data)) {
        cited++;
        if (!known.has(String(slug).toLowerCase())) unresolved.push(`${c.class_id} -> ${slug}`);
      }
      // A `with` list names OTHER skills this class grants - the Gunfighter
      // takes W.P. Sharpshooting once per weapon, and the weapons are grants of
      // its own. Naming one it does not grant would put a weapon on the sheet
      // the character never had. BOOK-INGEST-AUDIT.md F49.
      const occSkills = p.data.skills?.occ_skills || [];
      const grantedNames = new Set(occSkills
        .filter((e) => e && typeof e.name === 'string')
        .map((e) => e.name.trim().toLowerCase()));
      for (const e of occSkills) {
        if (!Array.isArray(e?.with)) continue;
        withLists++;
        for (const n of e.with) {
          if (!grantedNames.has(String(n).trim().toLowerCase())) {
            danglingWith.push(`${c.class_id}: ${e.name} is paired with ${n}, which the class does not grant`);
          }
        }
      }
    }
    check('every published class in a rebuilt database parses',
      unparsed.length === 0, unparsed.join(', '));
    check('every gear slug a rebuilt class references resolves, choice lists included',
      unresolved.length === 0, unresolved.slice(0, 10).join('; '));
    check('and the sweep actually looked at some',
      sweepClasses.length > 100 && cited > 500,
      `${sweepClasses.length} classes, ${cited} citations`);
    // The pairing must reference grants the class actually has, or the sheet
    // shows a weapon the character never took. Both directions are checked:
    // no dangling name, AND the sweep found some lists to check.
    check('every paired-skill `with` names a skill the class grants',
      danglingWith.length === 0, danglingWith.slice(0, 6).join('; '));
    check('and the pairing sweep found some to check',
      withLists >= 3, `${withLists} with-list(s) seen`);

    // -- a declared COPY pair must still match ------------------------------
    // BOOK-INGEST-AUDIT.md F25. Some books define a class AS another class and
    // state nothing of their own: Triax printed 175 says of the Euro-Juicer
    // "create the character as usual", and RUE printed 118 says "Ley Line
    // Rifter Stats. Same as the Ley Line Walker." Nothing here composes one
    // class from another, so those are stored as full copies - and nothing
    // recorded that the two must stay identical, or compared them.
    //
    // What that cost, before this check existed: fix-pre-rue-class-audit.sql
    // applied seven related-skill category bonuses to the Ley Line Walker and
    // not to the Rifter, which had none at all; the Rifter was missing two
    // equipment entries the book grants it; and the Walker's small sacks were
    // a fixed 4 against the book's 1D4, where the Rifter was right. Three
    // divergences in one declared pair, none of them visible to anything that
    // ran. F25's own Confidence line said this had never happened.
    //
    // `except` lists the keys that legitimately differ, rather than an
    // allowlist of what to compare, so a block added to one row later and not
    // the other fails by DEFAULT. An allowlist would silently not cover it.
    const NEVER_COMPARED = new Set([
      'id', 'name', 'source_book', 'extraction_notes', 'copy_of',
      'lore', 'gm_notes', 'sections',
    ]);
    const parsedById = new Map();
    for (const c of sweepClasses) {
      const p = parseClassMarkdown(c.markdown);
      if (p.ok) parsedById.set(c.class_id, p.data);
    }
    const copyProblems = [];
    let copyPairs = 0;
    let copyKeys = 0;
    for (const [id, data] of parsedById) {
      const decl = data.copy_of;
      if (!decl) continue;
      copyPairs++;
      const baseId = (decl && typeof decl === 'object') ? decl.class : decl;
      const except = new Set((decl && typeof decl === 'object' && Array.isArray(decl.except))
        ? decl.except : []);
      const base = parsedById.get(baseId);
      if (!base) {
        copyProblems.push(`${id}: copy_of names "${baseId}", which is not a published class here`);
        continue;
      }
      const keys = [...new Set([...Object.keys(data), ...Object.keys(base)])]
        .filter((k) => !NEVER_COMPARED.has(k) && !except.has(k)).sort();
      for (const k of keys) {
        copyKeys++;
        if (JSON.stringify(data[k]) !== JSON.stringify(base[k])) {
          copyProblems.push(`${id} vs ${baseId}: ${k} differs`);
        }
      }
      // A stale `except` is its own defect: it names a key the two now agree
      // on, so it hides nothing today and will go on hiding nothing after
      // someone makes them disagree. That is exactly how the Rifter's category
      // bonuses would have been re-hidden.
      for (const k of except) {
        if (NEVER_COMPARED.has(k)) {
          copyProblems.push(`${id} vs ${baseId}: except lists "${k}", which is never compared anyway`);
        } else if (JSON.stringify(data[k]) === JSON.stringify(base[k])) {
          copyProblems.push(`${id} vs ${baseId}: except lists "${k}", but the two agree on it`);
        }
      }
    }
    check('every declared copy pair still matches outside its except list',
      copyProblems.length === 0, copyProblems.slice(0, 8).join('; '));
    // A floor, not a count: the invariant passing because it found no pairs is
    // the failure mode this whole check exists to avoid.
    check('and the copy sweep examined the pairs it should',
      copyPairs >= 11 && copyKeys >= 80,
      `${copyPairs} pairs, ${copyKeys} keys compared`);
  }
}

// ---------- a spell against the row it retells ----------
// BOOK-INGEST-AUDIT F26. smoke.mjs pins the COMPARISON against fixtures; this
// runs it over the rows a clean rebuild actually produces, which is the half
// that catches a real edit. `drift-check` cannot do it - it compares a row to
// its cited page, and both rows of a retelling cite pages that agree with them.
{
  const spellRows = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--json',
    '--command', `"SELECT name, level, ppe, range, duration, saving_throw, area_of_effect, description, same_spell_as FROM spells WHERE same_spell_as IS NOT NULL OR name IN (SELECT same_spell_as FROM spells WHERE same_spell_as IS NOT NULL)"`]);
  let rows = null;
  let err = '';
  try {
    const out = spellRows.stdout || '';
    for (let at = out.indexOf('['); at >= 0 && !rows; at = out.indexOf('[', at + 1)) {
      try {
        const v = JSON.parse(out.slice(at));
        if (Array.isArray(v)) rows = v.flatMap((b) => b.results || []);
      } catch { /* not the array; keep looking */ }
    }
    if (!rows) throw new Error(cleanErr(spellRows.stderr || out));
  } catch (e) { err = e.message; }

  const byName = new Map((rows || []).map((r) => [r.name, r]));
  const links = (rows || []).filter((r) => r.same_spell_as);
  // A floor, not a count. The invariant passing because it found no pairs is
  // the failure this check exists to avoid, and it is exactly what a rebuild
  // that silently dropped the data script would look like.
  check('the retelling links survive a clean rebuild', links.length >= 6,
    err || `${links.length} linked rows`);

  const problems = [];
  for (const r of links) {
    const target = byName.get(r.same_spell_as);
    if (!target) { problems.push(`${r.name} -> ${r.same_spell_as}: target missing`); continue; }
    for (const p of comparePair(r, target)) problems.push(`${r.name} -> ${r.same_spell_as}: ${p}`);
  }
  check('and every linked pair still agrees with the row it retells',
    problems.length === 0, problems.slice(0, 6).join('; '));

  // The same-named pairs that are DIFFERENT spells must stay unlinked. Linking
  // one would make the check above start failing, which is the point - this
  // list is the belt to that braces, naming the pairs somebody has already
  // looked at and ruled on, so a later session does not re-litigate them from
  // the name alone. No count is quoted here: it grows every time a book lands.
  //
  // The Living Fire six were added 2026-09-12, and they are the case the list
  // is for. That batch was first written with its links chosen BY NAME and this
  // check refused the merge; the judgement belongs to
  // scripts/same-spell-lib.mjs, which rejects six of the fourteen candidates on
  // mechanics - a range that covers one more person, a per-level bonus the
  // established row does not have, a saving throw on one side only.
  const mustNotLink = ['Ocean: Calm Waters', 'Ocean: Ride the Waves',
    'Ocean: Float on Water', 'Ocean: Water Seal', 'Dolphin: Sonic Blast',
    'Living Fire: Cloud of Smoke', 'Living Fire: Extinguish Fire',
    'Living Fire: Impervious to Fire', 'Living Fire: Fire Ball',
    'Living Fire: Ballistic Fire', 'Living Fire: Fire Gout'];
  const wronglyLinked = links.filter((r) => mustNotLink.includes(r.name)).map((r) => r.name);
  check('and the pairs that only share a NAME are not linked',
    wronglyLinked.length === 0, wronglyLinked.join(', '));
}


console.log('\n' + (failures === 0
  ? `REGRESSION PASSED (${checks} checks)`
  : `REGRESSION FAILED (${failures} of ${checks} checks)`));
cleanup();
process.exit(failures === 0 ? 0 : 1);
