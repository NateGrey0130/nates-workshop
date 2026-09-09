// Play mode's queue, EXECUTED rather than read.
//
//   node apps/character-creator/test/play-flow.mjs
//
// WHY THIS EXISTS. Every other check on the queue reads sheet.js as TEXT -
// smoke.mjs's "Changes that could not be sent" section is fifteen regexes. They
// prove the code is SHAPED right and cannot prove it BEHAVES right, and the
// difference is not academic: the two-pool resolution path shipped in #874 with
// no way to tell a working rebase from a broken one. Six assertions were run by
// hand in a browser against a live dev server to close that, and existed
// nowhere afterwards. This is those assertions, kept.
//
// WHAT IT DOES. Loads the real sheet.js - and the seven classic scripts the
// page loads before it - into a node:vm context, points its fetch at a real
// `wrangler pages dev` over a scratch D1 built from nothing, and drives the
// real functions: quickDamage(), flushQueue(), resolveConflict(), undoLast().
// Assertions are made against the DATABASE through the app's own endpoints, so
// a passing run means rows moved, not that a string matched.
//
// Isolated the way regression.mjs is: its own --persist-to under a temp dir,
// its own port, deleted afterwards. Nothing here touches production or your dev
// data, and a failed run leaves no debris.
//
// THREE HONEST CAVEATS, because a harness that overstates itself is worse than
// none:
//
//   1. THE DOM IS A STUB. Elements are objects that remember what was written
//      to them; they have no layout and no real events. So this proves
//      sequencing and arithmetic, and proves nothing about whether a control is
//      reachable, visible, or on screen. That remains verify-ui's job, and the
//      conflict UI's shape stays pinned by smoke.mjs.
//
//   2. THE QUEUE STORE IS A FAKE. play-queue.js is IndexedDB, which node does
//      not have; this installs an in-memory store honouring the same six-method
//      contract (push/all/remove/count/clear/available). So what is tested is
//      sheet.js's USE of that contract - the ordering, the field map, the
//      conflict sequencing - and NOT play-queue.js's own IndexedDB code, which
//      stays covered by smoke.mjs's text checks and by a browser.
//
//   3. IT BOOTS WRANGLER, so it is slow, and it is a SEPARATE COMMAND rather
//      than another section of the smoke test - the same call regression.mjs
//      made and for the same reason. It is not a merge gate.
//
// What it DOES prove, and nothing else here does: that a dropped Damage
// survives as one entry carrying both pools, that a half-answered clash sends
// nothing, that the resolved write is rebased onto what the server holds, that
// undo takes back the whole hit, and that a refusal still rolls back.

import { spawn, spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, rmSync, mkdtempSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';
import vm from 'node:vm';

const testDir = dirname(fileURLToPath(import.meta.url));
const appDir = join(testDir, '..');
const repoRoot = join(appDir, '..', '..');
// Not 8788 (a dev server may be up), not 8799 (regression.mjs and the
// pick3cut5-room entry in launch.json both take it).
const PORT = 8797;
const ORIGIN = `http://127.0.0.1:${PORT}`;
const BASE = `${ORIGIN}/api/character-creator`;
const CHAR = 901;

let failures = 0;
let checks = 0;
function check(label, cond, why = '') {
  checks++;
  if (cond) console.log('  ok  ' + label);
  else { failures++; console.log('  FAIL ' + label + (why ? ' — ' + String(why).slice(0, 260) : '')); }
}
function section(name) { console.log('\n' + name); }

// ── the scratch database ────────────────────────────────────────────────────
const PREFIX = 'cc-play-flow-';

// SWEEP AT STARTUP, because teardown cannot be trusted to win. Deleting the
// scratch directory on the way out is a race against miniflare's sqlite handles
// and it does not always win - measured at two runs in three even with a retry
// budget and a pause. At startup there is no race: anything still here belongs
// to a run that is over, and its handles are gone with it. Between the two, the
// invariant is "at most one of these exists", which is what actually matters -
// the harm was never one directory, it was sixteen.
try {
  for (const d of readdirSync(tmpdir()).filter((x) => x.startsWith(PREFIX))) {
    try { rmSync(join(tmpdir(), d), { recursive: true, force: true, maxRetries: 5, retryDelay: 100 }); }
    catch { /* a concurrent run owns it - leave it alone */ }
  }
} catch { /* no temp dir listing; not worth failing a test run over */ }

const state = mkdtempSync(join(tmpdir(), PREFIX));
let server = null;

function killServer() {
  if (server && !server.killed) {
    // taskkill /T because the listening process is a workerd CHILD; killing the
    // pid alone leaves it holding the port.
    try { process.platform === 'win32' ? spawnSync('taskkill', ['/pid', server.pid, '/T', '/F']) : server.kill('SIGTERM'); }
    catch { /* already gone */ }
    server = null;
  }
}

// RETRIES because the sqlite files under this directory are still open for a
// moment after the processes holding them are killed - miniflare's D1 keeps a
// -wal and a -shm beside the database - and rmSync then fails EBUSY. A bare
// `catch {}` turns that into a whole scratch database left in TEMP on EVERY
// run: sixteen cc-regression-* directories had piled up from the suite this
// teardown was copied from, which makes the same promise this file does.
function removeState() {
  try { rmSync(state, { recursive: true, force: true, maxRetries: 30, retryDelay: 200 }); }
  catch { /* genuinely best effort now, rather than by default */ }
}

// The ORDERLY teardown, called on the way out while awaiting is still possible.
// This suite runs `wrangler d1 execute` against the same --persist-to WHILE the
// server is up (the second writer below), so more handles are in flight here
// than in regression.mjs, and the retry budget alone did not always win the
// race. A beat between the kill and the delete does.
async function shutdown() {
  killServer();
  await new Promise((r) => setTimeout(r, 750));
  removeState();
}
// The backstop, for a crash or a Ctrl-C that never reaches shutdown(). An exit
// handler cannot await, so this is the retry budget on its own.
process.on('exit', () => { killServer(); removeState(); });
process.on('SIGINT', () => { killServer(); removeState(); process.exit(130); });

function wrangler(args) {
  return spawnSync('npx', ['wrangler', ...args], {
    cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 180000, maxBuffer: 1e9,
  });
}

console.log('[1/4] Building a database from nothing');

// schema + catalogs only. The data scripts are 500-odd files that add classes
// and gear this harness never reads; seed-catalogs carries the one published
// class the sheet GET needs to resolve.
//
// The fixture is shaped for the case under test: no mdc_max, so damage
// cascades, and sdc_current BELOW the amount, so one press spills into H.P. and
// moves TWO pools. A character with M.D.C. would move one and prove nothing.
const fixture = `
INSERT INTO campaigns (id, name, system, gm_email) VALUES (${CHAR}, 'Play Flow', 'rifts', 'dev@localhost');
INSERT INTO characters (id, campaign_id, player_email, name, class_id, level, attributes,
  hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current, ppe_max, ppe_current)
VALUES (${CHAR}, ${CHAR}, 'dev@localhost', 'Play Flow', 'cyber-knight', 1,
  '{"IQ":12,"ME":12,"MA":12,"PS":12,"PP":12,"PE":12,"PB":12,"SPD":12}',
  20, 20, 30, 5, NULL, NULL, 20, 20);
`;
const bootstrap = join(state, 'bootstrap.sql');
writeFileSync(bootstrap, [
  readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
  readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
  fixture,
].join('\n;\n'), 'utf8');

const applied = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', bootstrap]);
check('schema + catalogs + fixture apply to an empty database', applied.status === 0,
  (applied.stderr || applied.stdout || '').slice(-400));
if (applied.status !== 0) { console.log('\nPLAY FLOW FAILED (cannot build a database)'); process.exit(1); }

// ── boot the worker ─────────────────────────────────────────────────────────
console.log('\n[2/4] Booting the app');
server = spawn('npx', ['wrangler', 'pages', 'dev', '--port', String(PORT),
  '--persist-to', state, '--show-interactive-dev-session', 'false',
  '--binding', 'ADMIN_EMAIL=dev@localhost'],
  { cwd: repoRoot, shell: true, stdio: 'ignore' });

async function waitForBoot(ms = 90000) {
  const started = Date.now();
  while (Date.now() - started < ms) {
    try { if ((await fetch(`${BASE}/me`)).ok) return true; } catch { /* not up yet */ }
    await new Promise((r) => setTimeout(r, 700));
  }
  return false;
}
if (!await waitForBoot()) {
  check('the worker answers on port ' + PORT, false, 'timed out waiting for /me');
  console.log('\nPLAY FLOW FAILED (worker never came up)'); process.exit(1);
}
check('the worker answers on port ' + PORT, true);

// ── reading the database back ───────────────────────────────────────────────
// Through the app's own endpoints, so an assertion exercises the read path too.
const pools = async () => {
  const r = await (await fetch(`${BASE}/characters/${CHAR}`)).json();
  return { hp: r.character.hp_current, sdc: r.character.sdc_current };
};
const events = async () => {
  const r = await (await fetch(`${BASE}/characters/${CHAR}/events?limit=50`)).json();
  return r.events || [];
};
// The second writer: somebody else moving the same pools while we were away.
//
// VIA A FILE, NEVER --command. spawnSync runs with shell:true, which joins the
// argv into one command line, so a --command containing spaces arrives at
// wrangler as several arguments and the UPDATE never runs. It fails quietly:
// the flush then replays onto values nobody moved, succeeds, and every
// conflict assertion below fails as though the CODE were wrong. That is how
// this harness read on its first run. regression.mjs uses --file for the same
// reason.
//
// And the exit status is CHECKED, because a fixture step that fails silently
// turns this whole file into a machine for producing confident wrong answers.
let sqlSeq = 0;
function sql(statement) {
  const f = join(state, `stmt-${++sqlSeq}.sql`);
  writeFileSync(f, statement + '\n', 'utf8');
  const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', f]);
  if (r.status !== 0) {
    console.log('\nPLAY FLOW FAILED (fixture write did not apply)\n  ' + statement
      + '\n  ' + (r.stderr || r.stdout || '').slice(-300));
    process.exit(1);
  }
  return r;
}
const movePoolsBehindOurBack = (hp, sdc) =>
  sql(`UPDATE characters SET hp_current=${hp}, sdc_current=${sdc} WHERE id=${CHAR};`);
const resetPools = movePoolsBehindOurBack;

// ── the page, in a vm ───────────────────────────────────────────────────────
console.log('\n[3/4] Loading the sheet');

// An element that remembers what was written to it. Enough for the painters to
// run; not enough to claim anything about layout. `closest` returning null is
// what makes paintPool stop before it needs a real card.
function makeEl(id) {
  const set = new Set();
  return {
    id, textContent: '', innerHTML: '', className: '', value: '', hidden: false,
    style: {}, dataset: {},
    classList: {
      add: (c) => set.add(c), remove: (c) => set.delete(c), contains: (c) => set.has(c),
      toggle: (c, on) => { const want = on === undefined ? !set.has(c) : !!on; want ? set.add(c) : set.delete(c); },
    },
    closest: () => null, querySelector: () => null, querySelectorAll: () => [],
    appendChild: (x) => x, removeChild: (x) => x, remove: () => {},
    setAttribute: () => {}, getAttribute: () => null,
    removeAttribute: () => {}, hasAttribute: () => false,
    addEventListener: () => {}, removeEventListener: () => {},
    focus: () => {}, click: () => {}, insertAdjacentHTML: () => {},
    getBoundingClientRect: () => ({ top: 0, left: 0, width: 0, height: 0, bottom: 0, right: 0 }),
  };
}
const els = new Map();
const byId = (i) => { if (!els.has(i)) els.set(i, makeEl(i)); return els.get(i); };

// The transport switch. 'live' reaches the worker; 'drop' rejects the way a
// dead connection does, which is the ONLY way to produce an error with no
// .status; 'refuse' answers with a real HTTP error, which must NOT queue.
let mode = 'live';
let dropped = 0;
async function sandboxFetch(input, init) {
  const path = typeof input === 'string' ? input : (input && input.url) || '';
  const isEvents = path.includes('/events');
  if (isEvents && mode === 'drop') { dropped++; throw new TypeError('Failed to fetch'); }
  if (isEvents && mode === 'refuse') {
    return new Response(JSON.stringify({ error: 'refused on merit' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } });
  }
  return fetch(path.startsWith('http') ? path : ORIGIN + path, init);
}

// The in-memory stand-in for play-queue.js. Same six methods, and an
// autoIncrement seq, because ORDER IS THE CONTRACT and a store that returned
// entries in any other order would make the flush look correct when it is not.
let seq = 0;
const rows = [];
const fakeQueue = {
  async push(entry) { rows.push({ ...entry, seq: ++seq, queued_at: Date.now() }); return seq; },
  async all(characterId) { return rows.filter((r) => characterId == null || r.characterId === characterId); },
  async remove(s) { const i = rows.findIndex((r) => r.seq === s); if (i >= 0) rows.splice(i, 1); },
  async count(characterId) { return (await fakeQueue.all(characterId)).length; },
  async clear(characterId) { for (const e of await fakeQueue.all(characterId)) await fakeQueue.remove(e.seq); },
  async available() { return true; },
};

const listeners = new Map();
const ctx = {
  console,
  document: {
    getElementById: byId, querySelector: () => null, querySelectorAll: () => [],
    createElement: () => makeEl('new'), createTextNode: (t) => ({ textContent: t }),
    addEventListener: () => {}, body: makeEl('body'), documentElement: makeEl('html'),
    head: makeEl('head'), readyState: 'complete', title: '',
  },
  location: new URL(`${ORIGIN}/apps/character-creator/sheet.html?id=${CHAR}&play=1`),
  history: { replaceState: () => {}, pushState: () => {} },
  navigator: { onLine: true, userAgent: 'node' },
  localStorage: { getItem: () => null, setItem: () => {}, removeItem: () => {} },
  sessionStorage: { getItem: () => null, setItem: () => {} },
  fetch: sandboxFetch,
  alert: (m) => { ctx.__alert = m; },
  confirm: () => true,
  setTimeout, clearTimeout, setInterval, clearInterval, queueMicrotask,
  URL, URLSearchParams, Response, Request, Headers, AbortController,
  Event: class { constructor(t) { this.type = t; } },
  CustomEvent: class { constructor(t, o) { this.type = t; this.detail = o?.detail; } },
  addEventListener: (e, f) => { if (!listeners.has(e)) listeners.set(e, []); listeners.get(e).push(f); },
  removeEventListener: () => {},
  dispatchEvent: (ev) => { for (const f of listeners.get(ev.type) || []) f(ev); return true; },
  matchMedia: () => ({ matches: false, addEventListener: () => {}, addListener: () => {} }),
  requestAnimationFrame: (f) => setTimeout(f, 0),
  crypto: globalThis.crypto,
  JSON, Math, Date, Object, Array, String, Number, Boolean, Promise, Map, Set, WeakMap,
  RegExp, Error, TypeError, Symbol, Intl, isNaN, parseInt, parseFloat,
  encodeURIComponent, decodeURIComponent, structuredClone,
};
ctx.window = ctx; ctx.globalThis = ctx; ctx.self = ctx;
const sandbox = vm.createContext(ctx);

for (const f of [
  join(repoRoot, 'shared', 'js', 'ui.js'),
  join(appDir, 'js', 'play-queue.js'),
  join(appDir, 'js', 'sticky.js'),
  join(appDir, 'js', 'sheet-layout.js'),
  join(appDir, 'js', 'derive.js'),
  join(appDir, 'js', 'rules.js'),
  join(appDir, 'js', 'picker.js'),
  join(appDir, 'js', 'api.js'),
  join(appDir, 'sheet.js'),
]) {
  try { vm.runInContext(readFileSync(f, 'utf8'), sandbox, { filename: f }); }
  catch (e) {
    check('every script the sheet page loads runs in the harness', false, f + ': ' + e.message);
    console.log('\nPLAY FLOW FAILED (the page did not load)'); process.exit(1);
  }
}
check('every script the sheet page loads runs in the harness', true);

// The IndexedDB store is replaced AFTER play-queue.js has installed the real
// one - see caveat 2 in the header.
ctx.playQueue = fakeQueue;

// `C` is a top-level const in sheet.js, so it is a lexical binding rather than
// a property of the global object - exactly as in the browser, where a later
// script can still see it. Reaching it means evaluating in the same context.
const evalIn = (expr) => vm.runInContext(expr, sandbox);
const run = async (expr) => await evalIn(`(async () => { ${expr} })()`);

await run('await load();');
check('the sheet loaded the fixture character',
  evalIn('C.data && C.data.hp_current') === 20 && evalIn('C.data && C.data.sdc_current') === 5,
  'C.data = ' + JSON.stringify(evalIn('C.data && {hp: C.data.hp_current, sdc: C.data.sdc_current}')));
check('and it is writable, so the queue is in play', evalIn('C.canWrite') === true,
  'canWrite=' + evalIn('C.canWrite'));
evalIn('C.playAmt = 10');

console.log('\n[4/4] Driving the queue');

// ── a refusal is not a silence ──────────────────────────────────────────────
section('A refusal rolls back and does not queue');
{
  mode = 'refuse';
  await run('await quickDamage();');
  const after = evalIn('({hp: C.data.hp_current, sdc: C.data.sdc_current})');
  check('the pools go back where they were', after.hp === 20 && after.sdc === 5, JSON.stringify(after));
  check('nothing is queued', (await fakeQueue.count(CHAR)) === 0);
  check('and the player is told', /refused on merit/.test(String(ctx.__alert)), ctx.__alert);
  check('the database never moved', JSON.stringify(await pools()) === JSON.stringify({ hp: 20, sdc: 5 }));
}

// ── a drop queues, and keeps the press whole ────────────────────────────────
section('A dropped Damage queues as ONE entry carrying BOTH pools');
{
  mode = 'drop';
  await run('await quickDamage();');
  const after = evalIn('({hp: C.data.hp_current, sdc: C.data.sdc_current})');
  check('the hit stands on screen', after.hp === 15 && after.sdc === 0, JSON.stringify(after));
  const q = await fakeQueue.all(CHAR);
  check('exactly one entry', q.length === 1, q.length + ' entries');
  check('carrying BOTH pools, not one', q[0] && q[0].fields
    && q[0].fields.hp_current && q[0].fields.sdc_current, JSON.stringify(q[0] && q[0].fields));
  check('with the from/to the press made', q[0] && q[0].fields.sdc_current.from === 5
    && q[0].fields.sdc_current.to === 0 && q[0].fields.hp_current.from === 20
    && q[0].fields.hp_current.to === 15, JSON.stringify(q[0] && q[0].fields));
  check("and the press's own kind", q[0] && q[0].kind === 'damage', q[0] && q[0].kind);
  check('the database has not moved', JSON.stringify(await pools()) === JSON.stringify({ hp: 20, sdc: 5 }));
  check('the counter says so', /1 change waiting for the network/.test(byId('queue-state').textContent),
    byId('queue-state').textContent);
}

// ── the clash ───────────────────────────────────────────────────────────────
section('Two pools moved behind our back is TWO choices on ONE press');
{
  movePoolsBehindOurBack(18, 3);
  mode = 'live';
  await run('await flushQueue();');
  const c = evalIn('JSON.parse(JSON.stringify(C.conflicts))');
  check('both pools raise a conflict', Object.keys(c).sort().join(',') === 'hp,sdc', Object.keys(c).join(','));
  check('both carry the same queue entry', c.hp && c.sdc && c.hp.seq === c.sdc.seq,
    JSON.stringify([c.hp && c.hp.seq, c.sdc && c.sdc.seq]));
  check('each knows both sides', c.sdc && c.sdc.mine === 0 && c.sdc.theirs === 3
    && c.hp.mine === 15 && c.hp.theirs === 18, JSON.stringify(c));
  check('the entry is still queued', (await fakeQueue.count(CHAR)) === 1);
  check('nothing was written', (await events()).length === 0, (await events()).length + ' events');
  check('and the counter is plural', /highlighted pools/.test(byId('queue-state').textContent),
    byId('queue-state').textContent);
}

section('Answering ONE pool sends nothing');
{
  await run("await resolveConflict('sdc', 'mine');");
  check('that pool stops offering the choice',
    evalIn("Object.keys(C.conflicts).join(',')") === 'hp', evalIn("Object.keys(C.conflicts).join(',')"));
  check('the answer is held against its press', evalIn('Object.keys(C.resolved).length') === 1);
  check('THE DATABASE IS UNTOUCHED', (await events()).length === 0, (await events()).length + ' events');
  check('and the entry is still queued', (await fakeQueue.count(CHAR)) === 1);
  check('the counter is singular again', /highlighted pool(?!s)/.test(byId('queue-state').textContent),
    byId('queue-state').textContent);
}

section('Answering the LAST pool sends the press whole, rebased');
{
  await run("await resolveConflict('hp', 'mine');");
  const ev = await events();
  check('exactly one event', ev.length === 1, ev.length + ' events');
  const e = ev[0] || {};
  const payload = typeof e.payload === 'string' ? JSON.parse(e.payload) : (e.payload || {});
  const ch = (payload.changes || {}).character || {};
  check("it kept the press's kind", e.kind === 'damage', e.kind);
  check('it carries BOTH pools', !!ch.hp_current && !!ch.sdc_current, JSON.stringify(ch));
  check('REBASED on what the server holds, not what was queued',
    ch.sdc_current && ch.sdc_current.from === 3 && ch.hp_current.from === 18,
    JSON.stringify(ch));
  check('and lands on the values the player chose',
    ch.sdc_current && ch.sdc_current.to === 0 && ch.hp_current.to === 15, JSON.stringify(ch));
  check('the character row agrees',
    JSON.stringify(await pools()) === JSON.stringify({ hp: 15, sdc: 0 }), JSON.stringify(await pools()));
  check('the queue is empty', (await fakeQueue.count(CHAR)) === 0);
  check('and no conflict is left', evalIn('Object.keys(C.conflicts).length') === 0);
}

// ── the reason it had to stay one event ─────────────────────────────────────
section('Undo takes back the WHOLE hit, because it stayed one event');
{
  await run('await undoLast();');
  check('both pools reverse together',
    JSON.stringify(await pools()) === JSON.stringify({ hp: 18, sdc: 3 }), JSON.stringify(await pools()));
}

// ── choosing theirs ─────────────────────────────────────────────────────────
section('Choosing theirs for every pool writes nothing at all');
{
  resetPools(20, 5);
  await run('await load();');
  const before = (await events()).length;
  mode = 'drop';
  await run('await quickDamage();');
  movePoolsBehindOurBack(18, 3);
  mode = 'live';
  await run('await flushQueue();');
  check('both pools clash again', evalIn('Object.keys(C.conflicts).length') === 2);
  await run("await resolveConflict('sdc', 'theirs');");
  await run("await resolveConflict('hp', 'theirs');");
  check('NO new event was written', (await events()).length === before,
    `${(await events()).length} vs ${before}`);
  check('the pools stay where the other writer left them',
    JSON.stringify(await pools()) === JSON.stringify({ hp: 18, sdc: 3 }), JSON.stringify(await pools()));
  check('and the queue is empty', (await fakeQueue.count(CHAR)) === 0);
}

// ── order, and the shape that predates the field map ────────────────────────
section('Order is the contract');
{
  resetPools(20, 30);
  await run('await load();');
  const before = (await events()).length;
  mode = 'drop';
  await run('C.playAmt = 1; await adjustPool("hp", -3); await adjustPool("hp", -4);');
  check('two entries waiting', (await fakeQueue.count(CHAR)) === 2, await fakeQueue.count(CHAR));
  mode = 'live';
  await run('await flushQueue();');
  check('both applied, oldest first, and they COMPOSE',
    (await pools()).hp === 13, JSON.stringify(await pools()));
  check('as two events', (await events()).length === before + 2, (await events()).length);
  check('and the queue drained', (await fakeQueue.count(CHAR)) === 0);
}

section('An entry queued before the field map still replays');
{
  resetPools(20, 30);
  await run('await load();');
  const before = (await events()).length;
  // The shape queueChange wrote before #874: one field, no `kind`. IndexedDB
  // outlives a deploy, so this is a real row in a real browser somewhere.
  rows.push({ characterId: CHAR, key: 'hp', from: 20, to: 16, note: 'HP -4', seq: ++seq });
  mode = 'live';
  await run('await flushQueue();');
  check('it applied rather than being dropped', (await pools()).hp === 16, JSON.stringify(await pools()));
  check('as a pool event', (await events()).length === before + 1, (await events()).length);
  check('and it left the queue', (await fakeQueue.count(CHAR)) === 0);
}

// ── done ────────────────────────────────────────────────────────────────────
await shutdown();
console.log('\n' + (failures
  ? `PLAY FLOW FAILED (${failures} of ${checks} checks)`
  : `PLAY FLOW PASSED (${checks} checks)`));
process.exit(failures ? 1 : 0);
