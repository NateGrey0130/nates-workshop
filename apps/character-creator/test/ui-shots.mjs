#!/usr/bin/env node
// Look at the pages. A REPORT, not a gate.
//
//   node apps/character-creator/test/ui-shots.mjs            report, exit 0
//   node apps/character-creator/test/ui-shots.mjs --strict   exit 1 if anything is flagged
//   node apps/character-creator/test/ui-shots.mjs --out <dir>
//
// WHY THIS EXISTS. checks/rendered-ui.mjs is regex over source text and
// play-flow.mjs stubs the DOM: neither loads a page. On 2026-10-01 a pass
// through the apps by hand found a phone play mode with 59px of an 812px
// screen left for the sheet, an 84px empty band stuck to the top of every
// wizard step, and an attributes box scrolling sideways at desktop width - all
// three with every suite green - and the fixes to them introduced a
// ReferenceError that only loading the page showed. This is that pass, as a
// command: it builds a database from nothing, serves the app, drives a real
// headless Chrome at a desktop and a phone size, and for each page records
//
//   - an uncaught exception or a console error
//   - the page scrolling sideways, or a box inside it doing so
//   - how much of the viewport sticky and fixed chrome takes once scrolled
//   - a PNG, to look at
//
// IT DOES NOT GATE A MERGE, and should not be made to without thought: it needs
// Chrome, which CI's runner has and a contributor's machine may not; a layout
// number is a judgement (is 45% chrome too much?) where a gate needs a fact;
// and `.github/workflows/tests.yml` runs nothing here. --strict exists for the
// day one of these flags is wanted as a failure.
//
// THE SERVER IS THE SUITES' OWN (dev-server.mjs): an OS-chosen port and a
// marker row, so the pages photographed are this checkout's and not another
// worktree's. Chrome gets its own --user-data-dir and is killed by the pid this
// script spawned, never by image name (verify-ui, section 4).

import { spawn, spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync, openSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { repoRoot } from './harness.mjs';
import { bootstrapSql } from '../../../scripts/build-local-d1.mjs';
import { freePort, refuseIfTaken, runMarker, waitForOwnServer } from './dev-server.mjs';

const args = process.argv.slice(2);
const strict = args.includes('--strict');
const outArg = args.indexOf('--out');
const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const outDir = outArg >= 0 && args[outArg + 1]
  ? resolve(args[outArg + 1]) : join(repoRoot, '.cache', 'ui-shots', stamp);

const CHROME = [process.env.CHROME_PATH,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  '/usr/bin/google-chrome', '/usr/bin/chromium-browser', '/usr/bin/chromium',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'].find((p) => p && existsSync(p));
if (!CHROME) {
  console.log('ui-shots: no Chrome found (set CHROME_PATH). Nothing was checked.');
  process.exit(strict ? 1 : 0);
}

// One character with all four pools, so the sheet's strip is at its widest.
const ID = 9101;
const fixture = `
INSERT INTO campaigns (id, name, system, gm_email) VALUES (${ID}, 'UI Shots', 'rifts', 'dev@localhost');
INSERT INTO characters (id, campaign_id, player_email, name, class_id, level, attributes,
  hp_max, hp_current, sdc_max, sdc_current, ppe_max, ppe_current, isp_max, isp_current)
VALUES (${ID}, ${ID}, 'dev@localhost', 'UI Shots', 'cyber-knight', 1,
  '{"IQ":12,"ME":14,"MA":12,"PS":12,"PP":12,"PE":14,"PB":12,"SPD":12}',
  20, 20, 30, 30, 20, 20, 26, 26);
`;

// `act` runs in the page after it has loaded, for a view that is not a URL.
const PAGES = [
  { name: 'creator-home', path: '/apps/character-creator/' },
  { name: 'creator-class-step', path: '/apps/character-creator/',
    act: `(async () => { const w = (ms) => new Promise((r) => setTimeout(r, ms));
      const click = (re) => [...document.querySelectorAll('button')].find((b) => re.test(b.textContent))?.click();
      window.confirm = () => true; click(/New character/); await w(900); click(/Rifts/); await w(1800); })()` },
  { name: 'sheet', path: `/apps/character-sheet/?id=${ID}` },
  { name: 'sheet-play', path: `/apps/character-sheet/?id=${ID}&play=1` },
  { name: 'codex', path: '/apps/codex/' },
  { name: 'gm-tools', path: `/apps/gm-tools/?campaign_id=${ID}` },
  { name: 'campaign', path: `/apps/campaign/?campaign_id=${ID}` },
];
const SIZES = [{ name: 'desktop', width: 1280, height: 800, mobile: false },
  { name: 'phone', width: 375, height: 812, mobile: true }];

// What is measured, in the page. Sticky chrome is measured AFTER a scroll,
// because that is when it costs something; a box counts as scrolling sideways
// only when it is not a strip that is meant to (a tab bar).
const MEASURE = `(async () => {
  const w = (ms) => new Promise((r) => setTimeout(r, ms));
  const doc = document.documentElement;
  const overflowX = doc.scrollWidth - doc.clientWidth;
  const boxes = [...document.querySelectorAll('.box-body, .panel, table')]
    .filter((e) => e.offsetParent && e.scrollWidth > e.clientWidth + 1 && getComputedStyle(e).overflowX !== 'visible')
    .map((e) => (e.className || e.tagName).toString().slice(0, 30) + ' ' + e.scrollWidth + '>' + e.clientWidth);
  window.scrollTo(0, 400); await w(250);
  let chrome = 0;
  for (const e of document.querySelectorAll('body *')) {
    const pos = getComputedStyle(e).position;
    if (pos !== 'sticky' && pos !== 'fixed') continue;
    const r = e.getBoundingClientRect();
    const pinned = pos === 'fixed' || Math.abs(r.top - parseFloat(getComputedStyle(e).top || '0')) < 2
      || Math.abs(r.bottom - innerHeight) < 2;
    if (pinned && r.height > 0 && r.width > innerWidth / 2 && r.bottom > 0 && r.top < innerHeight) chrome += r.height;
  }
  const scrolls = doc.scrollHeight > innerHeight + 400;
  window.scrollTo(0, 0); await w(100);
  return JSON.stringify({ overflowX, boxes, chrome: Math.round(chrome), vh: innerHeight, scrolls,
    height: doc.scrollHeight, text: document.body.innerText.length });
})()`;

const state = mkdtempSync(join(tmpdir(), 'cc-ui-shots-'));
const profile = mkdtempSync(join(tmpdir(), 'cc-ui-chrome-'));
let server = null, chrome = null;
const kill = (child) => {
  if (!child || child.killed || child.exitCode !== null) return;
  try { process.platform === 'win32' ? spawnSync('taskkill', ['/pid', child.pid, '/T', '/F']) : child.kill('SIGTERM'); }
  catch { /* already gone */ }
};
function cleanup() {
  kill(chrome); kill(server);
  for (const d of [state, profile]) {
    try { rmSync(d, { recursive: true, force: true, maxRetries: 20, retryDelay: 150 }); } catch { /* best effort */ }
  }
}
process.on('exit', cleanup);
process.on('SIGINT', () => { cleanup(); process.exit(130); });
const fail = (why) => { console.log('\nui-shots could not run: ' + why); process.exit(strict ? 1 : 0); };

const wrangler = (a) => spawnSync('npx', ['wrangler', ...a],
  { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 360000, maxBuffer: 1e9 });

console.log('[1/3] Building a database from nothing');
const marker = runMarker();
const bootstrap = join(state, 'bootstrap.sql');
writeFileSync(bootstrap, bootstrapSql(repoRoot, { extra: [fixture, marker.sql] }), 'utf8');
const built = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state, '--file', bootstrap]);
if (built.status !== 0) fail('the database did not build:\n' + (built.stderr || built.stdout || '').slice(-600));

console.log('[2/3] Serving the app');
const PORT = await freePort();
try { await refuseIfTaken(PORT); } catch (e) { fail(e.message); }
const logFd = openSync(join(state, 'dev-server.log'), 'a');
server = spawn('npx', ['wrangler', 'pages', 'dev', '--port', String(PORT), '--persist-to', state,
  '--show-interactive-dev-session', 'false', '--binding', 'ADMIN_EMAIL=dev@localhost'],
{ cwd: repoRoot, shell: true, stdio: ['ignore', logFd, logFd] });
const boot = await waitForOwnServer({ base: `http://127.0.0.1:${PORT}/api/character-creator`, child: server, marker, port: PORT });
if (!boot.ok) fail(boot.why);

console.log('[3/3] Looking at the pages');
const CDP = await freePort();
chrome = spawn(CHROME, ['--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
  `--remote-debugging-port=${CDP}`, `--user-data-dir=${profile}`, '--force-device-scale-factor=1', 'about:blank'],
{ stdio: 'ignore' });

async function debuggerUrl() {
  for (let i = 0; i < 60; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${CDP}/json/new?about:blank`, { method: 'PUT' });
      if (r.ok) return (await r.json()).webSocketDebuggerUrl;
    } catch { /* not up yet */ }
    await new Promise((r) => setTimeout(r, 250));
  }
  return null;
}
const wsUrl = await debuggerUrl();
if (!wsUrl) fail('Chrome did not open a debugging port');

const ws = new WebSocket(wsUrl);
await new Promise((res, rej) => { ws.addEventListener('open', res); ws.addEventListener('error', rej); });
let seq = 0;
const waiting = new Map();
let errors = [];
ws.addEventListener('message', (ev) => {
  const m = JSON.parse(ev.data);
  if (m.id && waiting.has(m.id)) { waiting.get(m.id)(m); waiting.delete(m.id); return; }
  if (m.method === 'Runtime.exceptionThrown') {
    const d = m.params.exceptionDetails;
    errors.push('exception: ' + (d.exception?.description || d.text || '').split('\n')[0].slice(0, 200));
  }
  if (m.method === 'Runtime.consoleAPICalled' && m.params.type === 'error') {
    errors.push('console.error: ' + m.params.args.map((a) => a.value ?? a.description ?? '').join(' ').slice(0, 200));
  }
});
const send = (method, params = {}) => new Promise((res) => {
  const id = ++seq; waiting.set(id, res); ws.send(JSON.stringify({ id, method, params }));
});
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
await send('Page.enable'); await send('Runtime.enable');

mkdirSync(outDir, { recursive: true });
const rows = [];
for (const size of SIZES) {
  await send('Emulation.setDeviceMetricsOverride',
    { width: size.width, height: size.height, deviceScaleFactor: 1, mobile: size.mobile });
  for (const page of PAGES) {
    errors = [];
    await send('Page.navigate', { url: `http://127.0.0.1:${PORT}${page.path}` });
    await sleep(2600);
    if (page.act) { await send('Runtime.evaluate', { expression: page.act, awaitPromise: true }); await sleep(400); }
    const m = await send('Runtime.evaluate', { expression: MEASURE, awaitPromise: true, returnByValue: true });
    let v = null;
    try { v = JSON.parse(m.result.result.value); } catch { errors.push('the page could not be measured'); }
    const shot = await send('Page.captureScreenshot', { format: 'png' });
    const file = `${page.name}--${size.name}.png`;
    if (shot.result?.data) writeFileSync(join(outDir, file), Buffer.from(shot.result.data, 'base64'));
    const flags = [];
    if (errors.length) flags.push(...errors);
    if (v) {
      if (v.text < 40) flags.push('the page is nearly empty');
      if (v.overflowX > 1) flags.push(`the page scrolls sideways by ${v.overflowX}px`);
      for (const b of v.boxes) flags.push(`a box scrolls sideways: ${b}`);
      // Only where there is something to scroll: on a short page a sticky bar
      // costs nothing. Half the screen is the line; it is a judgement, which is
      // one reason this is a report.
      if (v.scrolls && v.chrome / v.vh > 0.5) {
        flags.push(`sticky chrome is ${v.chrome}px of ${v.vh}px (${Math.round(100 * v.chrome / v.vh)}%) once scrolled`);
      }
    }
    rows.push({ page: page.name, size: size.name, v, flags, file });
    console.log(`  ${flags.length ? 'FLAG' : 'ok  '} ${page.name} @ ${size.name}`
      + (v ? `  chrome ${v.chrome}/${v.vh}px, height ${v.height}px` : ''));
    for (const f of flags) console.log(`         ${f}`);
  }
}
ws.close();

const flagged = rows.filter((r) => r.flags.length);
writeFileSync(join(outDir, 'report.json'), JSON.stringify(rows, null, 2), 'utf8');
console.log(`\n${rows.length} views, ${flagged.length} flagged. Screenshots and report.json: ${outDir}`);
console.log(flagged.length ? 'UI SHOTS: FLAGS RAISED (a report, not a gate)' : 'UI SHOTS: NOTHING FLAGGED');
process.exitCode = strict && flagged.length ? 1 : 0;
cleanup();
