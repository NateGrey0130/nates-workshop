// Marvel Heroes smoke test.
//
// Run from anywhere:  node apps/marvel-heroes/test/smoke.mjs
//
// WHY THIS SUITE CARRIES ITS OWN FILE-WIDE CHECKS. The character creator's
// suite sweeps "every page script" through harness.mjs's siblingAppDirs, and
// that is a FIXED list of the five apps split out of the character creator on
// 2026-09-19 - not a readdir of apps/. So nothing in the shared suite opens a
// file in this directory, and this app would get no parse, ASCII or line-ending
// check at all unless this file provides them. It does, below.
//
// The harness is the character creator's, as FilamentForge's and MediaVault's
// suites use it: section/check/summary are app-agnostic.

import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { dirname, join, relative, extname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { section, check, summary } from '../../character-creator/test/harness.mjs';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');
const fnDir = join(repoRoot, 'functions', 'api', 'marvel-heroes');
const rel = (p) => relative(repoRoot, p).split('\\').join('/');

function walk(dir) {
  if (!existsSync(dir)) return [];
  const out = [];
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}

const TEXT = new Set(['.html', '.css', '.js', '.mjs', '.json', '.md', '.svg', '.txt']);
const files = [...walk(appDir), ...walk(fnDir)];
const textFiles = files.filter((f) => TEXT.has(extname(f)));
const scripts = textFiles.filter((f) => ['.js', '.mjs'].includes(extname(f)));
const jsons = textFiles.filter((f) => extname(f) === '.json');
const pages = textFiles.filter((f) => extname(f) === '.html');

// ---------------------------------------------------------------------------
section('Every file in the app is ASCII, LF, and parses');

check('the sweep found the app files it should (index.html, app.js, styles.css, this suite)',
  ['index.html', 'app.js', 'styles.css', join('test', 'smoke.mjs')]
    .every((f) => textFiles.includes(join(appDir, f))),
  textFiles.map(rel).join(', '));
check('nothing in the app is a file type this sweep cannot read',
  files.every((f) => TEXT.has(extname(f))),
  files.filter((f) => !TEXT.has(extname(f))).map(rel).join(', '));

for (const f of textFiles) {
  const buf = readFileSync(f);
  const nonAscii = buf.findIndex((b) => b > 0x7e || (b < 0x20 && b !== 0x0a && b !== 0x09 && b !== 0x0d));
  check(`${rel(f)} is ASCII`, nonAscii === -1, nonAscii === -1 ? '' : `byte ${nonAscii} is 0x${buf[nonAscii].toString(16)}`);
  check(`${rel(f)} has no CR`, !buf.includes(0x0d));
}

// Every script here is an ES module. `node --check` on a .js file assumes
// CommonJS and rejects `import`, so the source goes through stdin with the
// module input type - which checks syntax without running anything.
for (const f of scripts) {
  const r = spawnSync(process.execPath, ['--input-type=module', '--check'],
    { input: readFileSync(f), encoding: 'utf8' });
  check(`${rel(f)} parses`, r.status === 0, (r.stderr || '').split('\n').slice(0, 5).join(' | '));
}
for (const f of jsons) {
  let ok = true, err = '';
  try { JSON.parse(readFileSync(f, 'utf8')); } catch (e) { ok = false; err = e.message; }
  check(`${rel(f)} is valid JSON`, ok, err);
}

// ---------------------------------------------------------------------------
section('Pages load only this app\'s own stylesheet and scripts');

for (const f of pages) {
  const html = readFileSync(f, 'utf8');
  const sheets = [...html.matchAll(/<link\b[^>]*rel=["']stylesheet["'][^>]*>/gi)].map((m) => m[0]);
  check(`${rel(f)} links a stylesheet`, sheets.length > 0);
  check(`${rel(f)} links no shared or other app's stylesheet`,
    sheets.every((s) => /href=["']styles\.css["']/.test(s)), sheets.join(' '));
  const external = [...html.matchAll(/\b(?:src|href)=["'](https?:)?\/\/[^"']+["']/gi)].map((m) => m[0]);
  check(`${rel(f)} makes no third-party request`, external.length === 0, external.join(' '));
  check(`${rel(f)} does not load the RPG app switcher`,
    !/appnav\.js/.test(html) && !/data-appnav/.test(html));
}

// ---------------------------------------------------------------------------
section('The palette meets 4.5:1 contrast, light and dark');

const css = readFileSync(join(appDir, 'styles.css'), 'utf8');

function tokens(block) {
  const out = {};
  for (const m of block.matchAll(/--([a-z0-9-]+)\s*:\s*(#[0-9a-f]{6})\b/gi)) out[m[1]] = m[2].toLowerCase();
  return out;
}
const lightBlock = css.match(/^:root\s*\{([\s\S]*?)^\}/m);
const darkBlock = css.match(/@media\s*\(prefers-color-scheme:\s*dark\)\s*\{\s*:root\s*\{([\s\S]*?)\}/);
check('styles.css has a light :root block', !!lightBlock);
check('and a dark :root block', !!darkBlock);
const light = lightBlock ? tokens(lightBlock[1]) : {};
const dark = { ...light, ...(darkBlock ? tokens(darkBlock[1]) : {}) };

function luminance(hex) {
  const c = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}
function contrast(a, b) {
  const [x, y] = [luminance(a), luminance(b)].sort((p, q) => q - p);
  return (x + 0.05) / (y + 0.05);
}

// [text token, background token] - every pairing the stylesheet actually uses.
const PAIRS = [
  ['ink', 'paper'], ['ink', 'panel'], ['ink', 'panel-alt'],
  ['ink-soft', 'paper'], ['ink-soft', 'panel'], ['ink-soft', 'panel-alt'],
  ['on-red', 'red'], ['on-blue', 'blue'], ['on-yellow', 'yellow'],
  ['on-feat-white', 'feat-white'], ['on-feat-green', 'feat-green'],
  ['on-feat-yellow', 'feat-yellow'], ['on-feat-red', 'feat-red'],
];
for (const [scheme, t] of [['light', light], ['dark', dark]]) {
  for (const [fg, bg] of PAIRS) {
    const ok = t[fg] && t[bg];
    const ratio = ok ? contrast(t[fg], t[bg]) : 0;
    check(`${scheme}: --${fg} on --${bg} is at least 4.5:1`, ok && ratio >= 4.5,
      ok ? ratio.toFixed(2) + ':1' : `token missing: ${[fg, bg].filter((k) => !t[k]).join(', ')}`);
  }
}

// ---------------------------------------------------------------------------
section('The app stays off the hub until it works');

// Nate's decision, 2026-09-23: no manifest entry until the generator works.
// The launch PR flips this check to require a live tile with an <svg icon.
const manifest = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8'));
check('apps/manifest.json has no marvel-heroes entry yet',
  !manifest.apps.some((a) => a.slug === 'marvel-heroes'));

const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
check('the README carries the rulings log', /^## Rulings$/m.test(readme));
check('and states the conflict rule: the Ultimate Powers Book wins',
  /Ultimate Powers Book wins/.test(readme));

// ---------------------------------------------------------------------------
// The data. Every d100 table must cover 01-00 exactly once: that is the check
// that catches a transcription slip AND a misprint in the book, and every
// misprint it has caught is settled by a ruling rather than by editing the
// check. See the README's Rulings.

const dataDir = join(appDir, 'data');
const load = (name) => JSON.parse(readFileSync(join(dataDir, name), 'utf8'));

// Problems with a list of [lo, hi] bands meant to cover 1..100 exactly once.
function coverage(bands) {
  const problems = [];
  const seen = new Array(101).fill(0);
  for (const [lo, hi] of bands) {
    if (!(Number.isInteger(lo) && Number.isInteger(hi) && lo >= 1 && hi <= 100 && lo <= hi)) {
      problems.push(`bad band ${lo}-${hi}`);
      continue;
    }
    for (let n = lo; n <= hi; n++) seen[n]++;
  }
  const gaps = [], overlaps = [];
  for (let n = 1; n <= 100; n++) {
    if (seen[n] === 0) gaps.push(n);
    if (seen[n] > 1) overlaps.push(n);
  }
  if (gaps.length) problems.push('uncovered ' + gaps.join(','));
  if (overlaps.length) problems.push('covered twice ' + overlaps.join(','));
  return problems;
}

section('The rank ladder is one unbroken run of numbers');

const ranks = load('ranks.json').ranks;
const rankIds = ranks.map((r) => r.id);
const rankIndex = Object.fromEntries(rankIds.map((id, i) => [id, i]));
check('rank ids are unique', new Set(rankIds).size === rankIds.length);
check('the ladder runs Shift 0 to Beyond', rankIds[0] === 'shift-0' && rankIds.at(-1) === 'beyond');
const numbered = ranks.filter((r) => r.min !== null);
for (let i = 1; i < numbered.length; i++) {
  const [a, b] = [numbered[i - 1], numbered[i]];
  check(`${b.name} starts where ${a.name} ends`, a.max !== null && b.min === a.max + 1,
    `${a.name} ${a.min}-${a.max}, ${b.name} ${b.min}-${b.max}`);
}
for (const r of numbered) {
  check(`${r.name}'s standard number is inside its range`,
    r.standard >= r.min && (r.max === null || r.standard <= r.max), `${r.standard} in ${r.min}-${r.max}`);
  if ('initial' in r) check(`${r.name}'s initial number is the bottom of its range`, r.initial === r.min);
}

section('The Universal Table is complete and every column runs white, green, yellow, red');

const ut = load('universal.json');
const ORDER = ['white', 'green', 'yellow', 'red'];
check('it has 24 row bands', ut.rows.length === 24, String(ut.rows.length));
check('and they cover 01-00 exactly once', coverage(ut.rows).length === 0, coverage(ut.rows).join('; '));
check('it has a column for all 18 ranks, in ladder order',
  ut.columns.map((c) => c.rank).join() === rankIds.join(), ut.columns.map((c) => c.rank).join());
for (const col of ut.columns) {
  const idx = col.colours.map((c) => ORDER.indexOf(c));
  check(`${col.rank}: a colour for every row`, idx.length === ut.rows.length && idx.every((i) => i >= 0),
    col.colours.join(','));
  check(`${col.rank}: the colours never step back down the column`,
    idx.every((v, i) => i === 0 || v >= idx[i - 1]), col.colours.join(','));
  check(`${col.rank}: 01 is white and 00 is red`, col.colours[0] === 'white' && col.colours.at(-1) === 'red');
}
// A higher rank never does worse: for every row, a column's colour is at least the one to its left.
for (let i = 1; i < ut.columns.length; i++) {
  const [a, b] = [ut.columns[i - 1], ut.columns[i]];
  check(`${b.rank} never does worse than ${a.rank} on the same roll`,
    b.colours.every((c, row) => ORDER.indexOf(c) >= ORDER.indexOf(a.colours[row])));
}
const ABILITIES = ['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche'];
check('the result header has all 18 kinds of FEAT', ut.actions.length === 18, String(ut.actions.length));
for (const a of ut.actions) {
  check(`${a.name}: a result for every colour, and a real ability`,
    ORDER.every((c) => typeof a.results[c] === 'string' && a.results[c].length > 0)
      && ABILITIES.includes(a.ability));
}

section('The Random Ranks Table covers every roll in every column');

const rr = load('random-ranks.json');
check('it has the five columns', Object.keys(rr.columns).join() === '1,2,3,4,5');
for (const [k, bands] of Object.entries(rr.columns)) {
  const cov = coverage(bands.map((b) => [b.lo, b.hi]));
  check(`column ${k} covers 01-00 exactly once`, cov.length === 0, cov.join('; '));
  check(`column ${k} climbs the ladder a rank at a time from Feeble`,
    bands[0].rank === 'feeble' && bands.every((b, i) => i === 0 || rankIndex[b.rank] === rankIndex[bands[i - 1].rank] + 1),
    bands.map((b) => b.rank).join());
  check(`column ${k}: every rank it gives has an initial number`,
    bands.every((b) => 'initial' in ranks[rankIndex[b.rank]]));
}

section('The cover tables have a row for every rank from Feeble to Class 5000');

const tables = load('tables.json');
const LADDER = rankIds.slice(1, -1);
for (const name of ['range', 'area_of_effect', 'movement', 'simultaneous']) {
  const got = tables[name].rows.map((r) => r.rank).join();
  check(`${name}: ${LADDER.length} rows in ladder order`, got === LADDER.join(), got);
}

section('Every ruling in the data is in the README, and every README ruling is in the data');

// Collect every "ruling" value, anywhere in any data file.
function rulingsIn(v, out) {
  if (Array.isArray(v)) v.forEach((x) => rulingsIn(x, out));
  else if (v && typeof v === 'object') {
    for (const [k, x] of Object.entries(v)) {
      if (k === 'ruling') out.add(x);
      else rulingsIn(x, out);
    }
  }
  return out;
}
const dataFiles = existsSync(dataDir) ? readdirSync(dataDir).filter((f) => f.endsWith('.json')) : [];
const inData = new Set();
for (const f of dataFiles) rulingsIn(load(f), inData);
const inReadme = new Set([...readme.matchAll(/^- \*\*(R\d+)\*\*/gm)].map((m) => m[1]));
check('the README lists at least one ruling as "- **Rn**"', inReadme.size > 0);
for (const id of inData) check(`${id}, cited in the data, is in the README`, inReadme.has(id));
for (const id of inReadme) check(`${id}, in the README, is cited by the data`, inData.has(id));

process.exit(summary() === 0 ? 0 : 1);
