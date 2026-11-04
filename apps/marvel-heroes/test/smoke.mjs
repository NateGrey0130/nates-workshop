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
// The harness is shared/test/harness.mjs, as every app suite's is:
// section/check/summary are app-agnostic.

import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { dirname, join, relative, extname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { section, check, summary } from '../../../shared/test/harness.mjs';

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
  // codex/ links it as ../styles.css; what matters is that every href lands on
  // THIS app's one stylesheet, resolved from the page that links it.
  const own = sheets.every((s) => {
    const href = s.match(/href=["']([^"']+)["']/)?.[1] || '';
    return !href.startsWith('/') && !/^[a-z]+:/i.test(href) && join(dirname(f), href) === join(appDir, 'styles.css');
  });
  check(`${rel(f)} links no shared or other app's stylesheet`, own, sheets.join(' '));
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
section('The sheet\'s four boxes hold every rank name at every sheet width');

// Until 2026-11-03 the boxes went to two columns only below a 440px sheet, so
// the GM page's 440px sheet at 1280x900 gave each box 83px of content and
// "Amazing" (99px) ran 16px out of the Resources box. A rank name cannot be
// measured here, so its width is pinned: every word of every name in
// data/ranks.json at 700 24px Saira, read off getBoundingClientRect in Chrome
// on 2026-11-03. A width scales with the font size (17px and 18px measured
// within 0.02px of the ratio). A rank this table lacks fails below: measure it
// and add it. What is checked is the stylesheet's own arithmetic, every
// integer sheet width from 200px to 1200px: the columns and the font the
// @container sheet rules leave, against the widest word.
{
  const WORD_PX_24 = {
    Shift: 55.73, 0: 15.92, X: 16.5, Y: 15.3, Z: 14.75, Feeble: 74.31, Poor: 52.78, Typical: 80.27,
    Good: 57.56, Excellent: 102.61, Remarkable: 135.42, Incredible: 111.17, Amazing: 98.75,
    Monstrous: 120.84, Unearthly: 112.55, Class: 58.14, 1000: 57.22, 3000: 62.33, 5000: 62.75, Beyond: 85.61,
  };
  const rankNames = JSON.parse(readFileSync(join(appDir, 'data', 'ranks.json'), 'utf8')).ranks.map((r) => r.name);
  const words = [...new Set(rankNames.flatMap((n) => n.split(/\s+/)))];
  const unmeasured = words.filter((w) => !(w in WORD_PX_24));
  check(`every word of the ${rankNames.length} rank names has a measured width`, rankNames.length > 15 && unmeasured.length === 0,
    `measure: ${unmeasured.join(', ')}`);
  const widest = Math.max(...words.map((w) => WORD_PX_24[w] ?? Infinity));

  const px = (re) => { const m = css.match(re); return m ? Number(m[1]) : NaN; };
  const gap = px(/^\.sh-boxes\s*\{[^}]*\bgap:\s*(\d+)px/m);
  const pad = px(/^\.sh-box\s*\{[^}]*\bpadding:\s*(\d+)px/m);
  const border = px(/^\.sh-box\s*\{[^}]*\bborder:\s*(\d+)px/m);
  const baseCols = px(/^\.sh-boxes\s*\{[^}]*grid-template-columns:\s*repeat\((\d+)/m);
  const baseFont = px(/^\.sh-box strong\s*\{[^}]*font-size:\s*(\d+)px/m);
  check('the box rules read back (gap, padding, border, columns, font)',
    [gap, pad, border, baseCols, baseFont].every(Number.isFinite), JSON.stringify({ gap, pad, border, baseCols, baseFont }));

  // Every `@container sheet (width < Npx) { ... }`, in source order, and what
  // it sets on the boxes. A brace scan, because the block holds rules.
  const rules = [];
  for (const m of css.matchAll(/@container\s+sheet\s*\(\s*width\s*<\s*(\d+)px\s*\)\s*\{/g)) {
    let depth = 1; let i = m.index + m[0].length;
    for (; i < css.length && depth; i++) depth += css[i] === '{' ? 1 : css[i] === '}' ? -1 : 0;
    const body = css.slice(m.index + m[0].length, i - 1);
    const cols = body.match(/\.sh-boxes\s*\{[^}]*grid-template-columns:\s*([^;}]+)/);
    const font = body.match(/\.sh-box strong\s*\{[^}]*font-size:\s*(\d+)px/);
    rules.push({ below: Number(m[1]),
      cols: cols ? (/repeat\((\d+)/.exec(cols[1])?.[1] ?? cols[1].trim().split(/\s+(?![^(]*\))/).length) : null,
      font: font ? Number(font[1]) : null });
  }
  check('the sheet has @container rules for its boxes', rules.some((r) => r.cols !== null), JSON.stringify(rules));
  const tight = [];
  for (let w = 200; w <= 1200; w++) {
    let cols = baseCols; let font = baseFont;
    for (const r of rules) if (w < r.below) { if (r.cols !== null) cols = Number(r.cols); if (r.font !== null) font = r.font; }
    const content = (w - (cols - 1) * gap) / cols - 2 * pad - 2 * border;
    const need = widest * font / 24;
    if (content < need) tight.push(`${w}px: ${cols} across at ${font}px leaves ${content.toFixed(1)}px for ${need.toFixed(1)}px`);
  }
  const widestWord = words.find((w) => WORD_PX_24[w] === widest);
  check(`at every sheet width from 200px to 1200px each box holds "${widestWord}" (${widest}px at 24px)`,
    Number.isFinite(widest) && tight.length === 0, `${tight.length} widths too tight, first ${tight[0]}, last ${tight.at(-1)}`);
}

// ---------------------------------------------------------------------------
section('The app is on the hub');

// Nate's decision, 2026-09-23: no manifest entry until the generator worked.
// It works, and the launch PR added the tile. A slug with status "live" is what
// makes the hub card a link; the icon is inline SVG and never an emoji, which
// the character creator's rendered-ui checks hold every tile to as well.
const manifest = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8'));
const tile = manifest.apps.find((a) => a.slug === 'marvel-heroes');
check('apps/manifest.json has a live marvel-heroes tile', tile?.status === 'live', JSON.stringify(tile?.status));
check('with an inline <svg icon and a name and description', /^<svg\b/.test(tile?.icon || '')
  && tile.name === 'Marvel Heroes' && (tile.description || '').length > 20);

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
const dataFiles = existsSync(dataDir) ? readdirSync(dataDir).filter((f) => f.endsWith('.json')) : [];

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

section('The Physical Form table covers every roll, and every body type can be built');

const bodies = load('body-types.json');
const powerTables = load('power-tables.json');
const allCodes = new Set(Object.values(powerTables.tables).flat().map((p) => p.code));
const classCodes = new Set(powerTables.classes.map((c) => c.code));
const SHIFTABLE = [...ABILITIES, 'resources', 'popularity'];
{
  const cov = coverage(bodies.types.map((t) => t.roll));
  check('the body types cover 01-00 exactly once', cov.length === 0, cov.join('; '));
  check('body type ids are unique', new Set(bodies.types.map((t) => t.id)).size === bodies.types.length);
  for (const [name, table] of [['Compound', bodies.compound_aspects], ['Changeling', bodies.changeling_aspects]]) {
    const c = coverage(table.map((a) => [a.lo, a.hi]));
    check(`the ${name} aspect table covers 01-00 exactly once`, c.length === 0, c.join('; '));
  }
  const problems = [];
  for (const t of bodies.types) {
    const parts = [t, ...(t.variants || [])];
    const column = (v) => v.column ?? t.column;
    if (t.special !== 'compound') {
      for (const v of t.variants || [t]) {
        if (![1, 2, 3, 4, 5].includes(column(v))) problems.push(`${t.id}/${v.id}: no Random Ranks column`);
      }
    } else if (!t.column_ruling) problems.push(`${t.id}: a compound needs its column ruling`);
    for (const p of parts) {
      if (p.choose_shift && !['primary', 'any'].includes(p.choose_shift.from)) {
        problems.push(`${p.id}: choose_shift must say whether it draws from primary or any abilities`);
      }
      for (const k of Object.keys(p.shift || {})) if (!SHIFTABLE.includes(k)) problems.push(`${p.id}: shift ${k}`);
      for (const [k, v] of Object.entries(p.set || {})) {
        if (!SHIFTABLE.includes(k)) problems.push(`${p.id}: set ${k}`);
        if (!(v in rankIndex)) problems.push(`${p.id}: set ${k} to unknown rank ${v}`);
      }
      for (const b of p.bonus_powers || []) {
        if (b.code && !allCodes.has(b.code)) problems.push(`${p.id}: bonus power ${b.code} is not in the power tables`);
        if (b.class && !classCodes.has(b.class)) problems.push(`${p.id}: bonus class ${b.class}`);
        if (b.rank && !(b.rank in rankIndex)) problems.push(`${p.id}: bonus rank ${b.rank}`);
      }
    }
  }
  check('every body type has a Random Ranks column, and every modifier names a real ability, rank and Power',
    problems.length === 0, problems.join('; '));
}

section('Origin, Weakness and the counts table cover every roll');

{
  const origins = load('origins.json').origins;
  check('the origins cover 01-00 exactly once', coverage(origins.map((o) => o.roll)).length === 0,
    coverage(origins.map((o) => o.roll)).join('; '));
  const weakness = load('weakness.json');
  for (const part of ['stimulus', 'effect', 'duration']) {
    const c = coverage(weakness[part].map((w) => w.roll));
    check(`the weakness ${part} table covers 01-00 exactly once`, c.length === 0, c.join('; '));
  }
  const counts = load('counts.json').rows;
  const c = coverage(counts.map((r) => r.roll));
  check('the counts table covers 01-00 exactly once', c.length === 0, c.join('; '));
  for (const kind of ['powers', 'talents', 'contacts']) {
    check(`${kind}: the initial number never exceeds the maximum`,
      counts.every((r) => r[kind].initial <= r[kind].max));
  }
  // The one column the book builds as a staircase. A misprint in it (the printed
  // 2/8 at 67-75) is exactly the value that breaks the climb.
  check('the initial number of Powers climbs with the roll',
    counts.every((r, i) => i === 0 || r.powers.initial > counts[i - 1].powers.initial),
    counts.map((r) => r.powers.initial).join(','));
}

section('The power roll tables cover every roll, and every code is numbered in order');

{
  const c = coverage(powerTables.classes.map((x) => x.roll));
  check('the sixteen power classes cover 01-00 exactly once', powerTables.classes.length === 16 && c.length === 0,
    c.join('; '));
  check('every class has a table, and every table a class',
    [...classCodes].sort().join() === Object.keys(powerTables.tables).sort().join());
  for (const [k, rows] of Object.entries(powerTables.tables)) {
    const cov = coverage(rows.map((r) => r.roll));
    check(`${k}: covers 01-00 exactly once`, cov.length === 0, cov.join('; '));
    check(`${k}: codes run ${k}1 to ${k}${rows.length} in order`,
      rows.every((r, i) => r.code === `${k}${i + 1}`), rows.map((r) => r.code).join(','));
  }
  check('every power code is unique', allCodes.size === Object.values(powerTables.tables).flat().length);
}

section('Talents and Contacts');

{
  const tal = load('talents.json');
  const cg = coverage(tal.groups.map((g) => g.roll));
  check('the Talent categories cover 01-00 exactly once', cg.length === 0, cg.join('; '));
  check('Talent ids are unique', new Set(tal.talents.map((t) => t.id)).size === tal.talents.length);
  for (const g of tal.groups) {
    // Talents sharing one d10 result share one band, so cover 1-10 with the
    // distinct bands.
    const bands = [...new Map(tal.talents.filter((t) => t.group === g.id)
      .map((t) => [t.roll.join('-'), t.roll])).values()];
    const seen = new Array(11).fill(0);
    for (const [lo, hi] of bands) for (let n = lo; n <= hi; n++) seen[n]++;
    check(`${g.name}: the d10 covers 1-10 exactly once`, seen.slice(1).every((n) => n === 1), seen.slice(1).join(','));
  }
  const con = load('contacts.json');
  const groups = new Set(con.groups.map((g) => g.id));
  check('Contact ids are unique', new Set(con.contacts.map((c) => c.id)).size === con.contacts.length);
  check('every Contact is in a listed group', con.contacts.every((c) => groups.has(c.group)));
}

section('Summaries are short, so no book prose rides in on them');

{
  // The repo is public; the data holds mechanics and summaries written for the
  // app. A summary or note longer than this is a sign of text copied from a
  // book rather than summarised. It is a floor, not the rule.
  const MAX = 140;
  const long = [];
  const walk = (v, path) => {
    if (Array.isArray(v)) v.forEach((x, i) => walk(x, `${path}[${i}]`));
    else if (v && typeof v === 'object') for (const [k, x] of Object.entries(v)) walk(x, `${path}.${k}`);
    else if (typeof v === 'string' && /\.(summary|notes\[\d+\])$/.test(path) && v.length > MAX) {
      long.push(`${path} (${v.length})`);
    }
  };
  for (const f of dataFiles) walk(load(f), f);
  check(`no summary or note is longer than ${MAX} characters`, long.length === 0, long.join('; '));
}

section('The power catalog matches the roll tables, Power for Power');

const catalog = load('powers.json');
{
  const byCode = Object.fromEntries(catalog.powers.map((p) => [p.code, p]));
  const rolled = Object.entries(powerTables.tables).flatMap(([k, rows]) => rows.map((r) => ({ ...r, cls: k })));
  check('the catalog has every rolled Power and nothing else',
    catalog.powers.length === rolled.length && rolled.every((r) => byCode[r.code]),
    `${catalog.powers.length} in the catalog, ${rolled.length} in the tables`);
  const drift = rolled.filter((r) => {
    const p = byCode[r.code];
    return !p || p.name !== r.name || p.class !== r.cls || p.double !== r.double || !!p.addenda !== !!r.addenda;
  });
  check('and agrees with them on name, class, double and addenda', drift.length === 0,
    drift.map((r) => r.code).join(', '));
  const bad = [];
  for (const p of catalog.powers) {
    if (!(p.range === null || ['A', 'B', 'C', 'D', 'E'].includes(p.range))) bad.push(`${p.code} range ${p.range}`);
    if (!Number.isInteger(p.page) || p.page < 18 || p.page > 100) bad.push(`${p.code} page ${p.page}`);
    if (typeof p.summary !== 'string' || p.summary.length < 20) bad.push(`${p.code} summary`);
    for (const kind of ['bonus', 'optional', 'nemesis']) {
      for (const x of p[kind] || []) {
        if (typeof x === 'string' ? !byCode[x] : !(x && typeof x.name === 'string')) bad.push(`${p.code} ${kind} ${JSON.stringify(x)}`);
      }
    }
  }
  check('every Power has a page in the listings, a summary, a real range column and real related Powers',
    bad.length === 0, bad.join('; '));
  check('every section introduction belongs to a class',
    Object.keys(catalog.class_intros).every((c) => classCodes.has(c)));
}

section('The power-text endpoint reads one row, GET only, and answers a missing row with the summary\'s cue');

{
  const mod = await import(new URL('../../../functions/api/marvel-heroes/power-text.js', import.meta.url));
  const handlers = Object.keys(mod).filter((k) => k.startsWith('onRequest'));
  check('its only handler is onRequestGet, so every other method is a 405',
    handlers.join() === 'onRequestGet', handlers.join());
  check('its code pattern takes every catalog code and every class code',
    catalog.powers.every((p) => mod.CODE.test(p.code)) && [...classCodes].every((c) => mod.CODE.test(c)));
  check('and refuses anything else', !['D0', 'X1', 'MG1;', "D1' OR 1=1", '', 'd1', 'MCo66x'].some((c) => mod.CODE.test(c)));
  const rows = { MG10: { code: 'MG10', name: 'Reality Alteration', page: 47, body: 'text' } };
  const env = { DB_MARVEL: { prepare: () => ({ bind: (code) => ({ first: async () => rows[code] || null }) }) } };
  const call = async (code, headers = { 'Cf-Access-Authenticated-User-Email': 'a@b.c' }, host = 'example.com') => {
    const res = await mod.onRequestGet({ request: new Request(`https://${host}/api/marvel-heroes/power-text?code=${encodeURIComponent(code)}`, { headers }), env });
    return { status: res.status, body: await res.json() };
  };
  const hit = await call('MG10');
  check('a stored row comes back whole', hit.status === 200 && hit.body.body === 'text', JSON.stringify(hit));
  const miss = await call('D1');
  check('a row the database does not have is a 404 that says missing', miss.status === 404 && miss.body.missing === true);
  check('a bad code is a 400', (await call('X9')).status === 400);
  check('and nobody signed in is a 401', (await call('MG10', {})).status === 401);
}

section('Saved heroes: every read and write is the owner\'s own, against the real migration');

{
  // A D1 stand-in over node:sqlite, built from migration 082 itself, so the
  // SQL the endpoint sends is the SQL that runs.
  const { DatabaseSync } = await import('node:sqlite');
  const sqlite = new DatabaseSync(':memory:');
  sqlite.exec('CREATE TABLE schema_migrations (filename TEXT PRIMARY KEY, applied_at TEXT)');
  sqlite.exec(readFileSync(join(repoRoot, 'db', 'migrations', 'marvel', '082-msh-heroes.sql'), 'utf8'));
  const DB = {
    prepare: (sql) => {
      const st = sqlite.prepare(sql);
      const bound = (args) => ({
        first: async () => st.get(...args) ?? null,
        all: async () => ({ results: st.all(...args) }),
        run: async () => ({ meta: { changes: Number(st.run(...args).changes) } }),
      });
      return { bind: (...args) => bound(args), ...bound([]) };
    },
  };
  const mod = await import(new URL('../../../functions/api/marvel-heroes/heroes.js', import.meta.url));
  const lib = await import(new URL('../../../functions/api/marvel-heroes/_lib/heroes.js', import.meta.url));
  const call = async (method, { who = 'ann@x.org', query = '', body, host = 'example.com' } = {}) => {
    const headers = who ? { 'Cf-Access-Authenticated-User-Email': who } : {};
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    const request = new Request(`https://${host}/api/marvel-heroes/heroes${query}`,
      { method, headers, body: body === undefined ? undefined : (typeof body === 'string' ? body : JSON.stringify(body)) });
    const handler = { GET: mod.onRequestGet, POST: mod.onRequestPost, DELETE: mod.onRequestDelete }[method];
    const res = await handler({ request, env: { DB_MARVEL: DB } });
    return { status: res.status, body: await res.json() };
  };

  // A real hero out of the generator, snapshotted the way the page does it.
  const { makeGenerator, PRIMARY: PRIMARY_ABILITIES } = await import(new URL('../js/generator.js', import.meta.url));
  const sheetMod = await import(new URL('../js/sheet.js', import.meta.url));
  const data = {};
  for (const n of ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts']) data[n] = load(`${n}.json`);
  const gen = makeGenerator(data);
  const seeds = { body: 11, origin: 2, abilities: 3, weakness: 4, counts: 5, powers: 6, talents: 7 };
  const built = gen.build({ seeds, picks: {} });
  const snap = sheetMod.snapshot(built, gen, data, []);
  const hero = { name: 'Test Hero', build: { seeds, picks: {} }, snapshot: snap };

  const made = await call('POST', { body: hero });
  const id = made.body.id;
  check('a new hero is saved and given an id by the server', made.status === 201 && lib.ID.test(id || ''), JSON.stringify(made));
  const forged = await call('POST', { body: { ...hero, id: 'aaaaaaaa-0000-0000-0000-000000000000' } });
  check('an id the owner does not have is a 404, not a new row under a chosen id', forged.status === 404);
  const list = await call('GET');
  check('the owner\'s list has it, with its snapshot', list.status === 200 && list.body.heroes.length === 1
    && list.body.heroes[0].snapshot.abilities.fighting.name === snap.abilities.fighting.name);
  check('another person\'s list does not', (await call('GET', { who: 'bob@x.org' })).body.heroes.length === 0);
  check('another person cannot read it', (await call('GET', { who: 'bob@x.org', query: `?id=${id}` })).status === 404);
  check('or overwrite it', (await call('POST', { who: 'bob@x.org', body: { ...hero, id, name: 'Stolen' } })).status === 404
    && (await call('GET', { query: `?id=${id}` })).body.hero.name === 'Test Hero');
  check('or delete it', (await call('DELETE', { who: 'bob@x.org', query: `?id=${id}` })).status === 404
    && (await call('GET', { query: `?id=${id}` })).status === 200);
  check('nobody signed in is a 401 for every method', (await Promise.all([
    call('GET', { who: null }), call('POST', { who: null, body: hero }), call('DELETE', { who: null, query: `?id=${id}` }),
  ])).every((r) => r.status === 401));
  check('local dev, with no Access in front of it, is dev@localhost',
    (await call('GET', { who: null, host: 'localhost' })).status === 200);

  // The sheet: written fields are kept to the known ones and their lengths,
  // and a save from the generator (no sheet) leaves them alone.
  const sheet = { identity: 'Secret', base: 'x'.repeat(500), evil: 'dropped', health: 42, karma: 1.5, notes: '' };
  await call('POST', { body: { ...hero, id, sheet } });
  let got = (await call('GET', { query: `?id=${id}` })).body.hero;
  check('the sheet keeps its known fields, cut to length', got.sheet.identity === 'Secret'
    && got.sheet.base.length === lib.SHEET_FIELDS.base && !('evil' in got.sheet) && !('notes' in got.sheet), JSON.stringify(got.sheet).slice(0, 200));
  check('and whole numbers only', got.sheet.health === 42 && !('karma' in got.sheet));
  await call('POST', { body: { ...hero, id, name: 'Renamed' } });
  got = (await call('GET', { query: `?id=${id}` })).body.hero;
  check('a save with no sheet renames the hero and keeps what was written on it',
    got.name === 'Renamed' && got.sheet.identity === 'Secret');
  check('the build comes back as the generator\'s own state, and rebuilds the same hero',
    JSON.stringify(gen.build(got.build).abilities) === JSON.stringify(built.abilities));

  // A Point Buy hero (R24) has no seeds. Its build must come back with its
  // mode, or it would reopen in the generator as an empty roll.
  const { makePointBuy, emptyBuild, normalise } = await import(new URL('../js/pointbuy.js', import.meta.url));
  const pbk = makePointBuy(data, gen);
  const pbBuild = { ...emptyBuild({ limit: 300, cap: 'amazing' }), abilities: { fighting: 20, agility: 24, strength: 50, endurance: 30, reason: 6, intuition: 10, psyche: 10 },
    powers: [{ code: data.powers.powers.find((p) => p.double).code, number: 30, gm: false, free: false }],
    bonuses: [{ ability: 'strength', amount: 10, reason: 'the serum', free: true }], items: [{ name: 'Jet pack', notes: '', points: 0, free: true }] };
  const pbHero = { name: 'Bought', build: { mode: 'pointbuy', pb: pbBuild }, snapshot: pbk.snapshot(pbBuild) };
  const pbMade = await call('POST', { body: pbHero });
  const pbGot = (await call('GET', { query: `?id=${pbMade.body.id}` })).body.hero || { snapshot: pbHero.snapshot };
  check('a Point Buy hero saves with no seeds, and its build comes back with its mode and purchases',
    pbMade.status === 201 && pbGot?.build?.mode === 'pointbuy' && JSON.stringify(normalise(pbGot.build.pb, pbk)) === JSON.stringify(pbBuild),
    String(JSON.stringify(pbGot?.build)).slice(0, 160));
  check('and nothing else rides along in its build', JSON.stringify(Object.keys(pbGot?.build || {})) === '["mode","pb"]');
  check('a generator build still comes back as exactly its seeds and picks',
    JSON.stringify(Object.keys(got.build)) === '["seeds","picks"]');
  const pbHtml = sheetMod.renderSheet({ name: 'Bought', snapshot: pbGot.snapshot });
  check('a Point Buy sheet draws with no body, origin or weakness, and shows the grants and a GM tag',
    pbHtml.includes('GM grants') && pbHtml.includes('Strength +10') && pbHtml.includes('Jet pack')
      && !pbHtml.includes('<h3>Weakness</h3>') && !pbHtml.includes('<h3>Contacts</h3>'));
  check('its ability shows the bought number plus the grant', pbHtml.includes('>Amazing</td><td class="num">60<'));
  check('and its line on My heroes says what it cost', sheetMod.tagline(pbGot.snapshot) === `Point Buy, ${(20 + 24 + 50 + 30 + 6 + 10 + 10) + 30 * 2}/300 pts; 1 Power`,
    sheetMod.tagline(pbGot.snapshot));

  for (const [label, body] of [
    ['a hero with no name', { ...hero, name: '  ' }],
    ['a Point Buy hero with no purchases', { ...pbHero, build: { mode: 'pointbuy' } }],
    ['one with no generator state', { ...hero, build: null }],
    ['one with no snapshot', { ...hero, snapshot: {} }],
    ['one with a malformed id', { ...hero, id: "x' OR 1=1" }],
    ['one too large', { ...hero, snapshot: { ...snap, pad: 'x'.repeat(lib.MAX_JSON) } }],
    ['a body that is not JSON', '{nope'],
  ]) check(`${label} is refused with a 400`, (await call('POST', { body })).status === 400);

  sqlite.prepare("UPDATE msh_heroes SET owner_email = 'full@x.org'").run();
  for (let i = 1; i < lib.MAX_HEROES; i++) {
    sqlite.prepare("INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES (?, 'full@x.org', 'n', '{}', '{}')").run(`filler-${String(i).padStart(4, '0')}`);
  }
  check(`an owner with ${lib.MAX_HEROES} heroes cannot save another`, (await call('POST', { who: 'full@x.org', body: hero })).status === 400);
  check('the owner can delete one', (await call('DELETE', { who: 'full@x.org', query: `?id=${id}` })).status === 200
    && (await call('GET', { who: 'full@x.org', query: `?id=${id}` })).status === 404);

  // The sheet itself.
  check('a snapshot is plain JSON: it survives the round trip unchanged', JSON.stringify(JSON.parse(JSON.stringify(snap))) === JSON.stringify(snap));
  const html = sheetMod.renderSheet({ name: '<img src=x onerror=alert(1)>', snapshot: snap, sheet: { identity: '"><script>x</script>' } });
  check('the sheet escapes the hero\'s name and everything written on it',
    !/<img|<script/.test(html) && html.includes('&lt;img') && html.includes('&quot;&gt;&lt;script'));
  check('it shows all seven abilities with rank and points',
    PRIMARY_ABILITIES.every((k) => html.includes(`>${snap.abilities[k].name}</td><td class="num">${snap.abilities[k].number}<`)));
  check('and every identity line of the Judge\'s Book sheet, each one a key the endpoint keeps',
    sheetMod.IDENTITY.every(([k]) => html.includes(`data-field="${k}"`) && k in lib.SHEET_FIELDS));
  check('every number the sheet tracks is one the endpoint keeps',
    [...html.matchAll(/data-number="([a-z_]+)"/g)].map((m) => m[1]).sort().join() === [...lib.SHEET_NUMBERS].sort().join());
  const kit = gen.build({ seeds, picks: { body: 'changeling', aspects: [{ id: 'robot-humanshape' }, { id: 'vegetable' }] } });
  const kitHtml = sheetMod.renderSheet({ name: 'Kit', snapshot: sheetMod.snapshot(kit, gen, data, []) });
  check('a Changeling\'s sheet has a table for its 2nd form instead of the blank line',
    kitHtml.includes('2nd form: Vegetable') && !kitHtml.includes('data-field="second_form"'));
}

// A D1 stand-in over node:sqlite for the campaign endpoints: built from the
// migrations a database has by now (082, 086), with foreign keys on as D1 has
// them, and a batch that is one transaction as D1's is. `media` is an R2
// stand-in that remembers every key written, and `call` runs a route's
// handler the way Pages would, with the caller's Access email.
async function marvelStandIn() {
  const { DatabaseSync } = await import('node:sqlite');
  const sqlite = new DatabaseSync(':memory:');
  sqlite.exec('PRAGMA foreign_keys = ON');
  sqlite.exec('CREATE TABLE schema_migrations (filename TEXT PRIMARY KEY, applied_at TEXT)');
  for (const f of ['082-msh-heroes.sql', '086-msh-campaigns.sql']) {
    sqlite.exec(readFileSync(join(repoRoot, 'db', 'migrations', 'marvel', f), 'utf8'));
  }
  const statement = (sql, args) => {
    const st = sqlite.prepare(sql);
    const run = () => ({ meta: { changes: Number(st.run(...args).changes) } });
    return { first: async () => st.get(...args) ?? null, all: async () => ({ results: st.all(...args) }), run: async () => run(), runNow: run };
  };
  const DB = {
    prepare: (sql) => ({ bind: (...args) => statement(sql, args), ...statement(sql, []) }),
    batch: async (list) => {
      sqlite.exec('BEGIN');
      try { const out = list.map((s) => s.runNow()); sqlite.exec('COMMIT'); return out; } catch (e) { sqlite.exec('ROLLBACK'); throw e; }
    },
  };
  const objects = new Map();
  const media = {
    objects,
    put: async (key, bytes, opts) => { objects.set(key, { bytes: new Uint8Array(bytes), contentType: opts?.httpMetadata?.contentType }); },
    get: async (key) => (objects.has(key) ? { body: objects.get(key).bytes, httpMetadata: { contentType: objects.get(key).contentType } } : null),
    delete: async (key) => { objects.delete(key); },
  };
  const env = { DB_MARVEL: DB, MEDIA: media,
    ASSETS: { fetch: async (url) => new Response(readFileSync(join(repoRoot, new URL(url).pathname.slice(1)))) } };
  const route = async (p) => import(new URL(`../../../functions/api/marvel-heroes/${p}`, import.meta.url));
  const call = async (mod, method, { who = 'gm@x.org', params = {}, query = '', body, raw, type } = {}) => {
    const headers = { 'Cf-Access-Authenticated-User-Email': who };
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    if (type) headers['Content-Type'] = type;
    const request = new Request(`https://example.com/api/marvel-heroes/x${query}`,
      { method, headers, body: raw ?? (body === undefined ? undefined : JSON.stringify(body)) });
    const handler = mod[`onRequest${method[0]}${method.slice(1).toLowerCase()}`] || mod.onRequest;
    const res = await handler({ request, env, params });
    const isJson = (res.headers.get('Content-Type') || '').includes('json');
    return { status: res.status, body: isJson ? await res.json() : new Uint8Array(await res.arrayBuffer()) };
  };
  return { sqlite, DB, env, media, route, call };
}

section('Campaigns: the GM changes only the play numbers, and a hero plays in one open campaign');

{
  const { sqlite, env, route, call } = await marvelStandIn();
  const R = {
    list: await route('campaigns.js'),
    one: await route('campaigns/[id].js'),
    link: await route('campaigns/[id]/heroes.js'),
    hero: await route('campaigns/[id]/heroes/[heroId].js'),
    events: await route('campaigns/[id]/events.js'),
    generate: await route('campaigns/[id]/npcs/generate.js'),
    npcs: await route('campaigns/[id]/npc-sheets.js'),
    heroes: await route('heroes.js'),
  };
  const { SNAPSHOT_VERSION: sheetModV } = await import(new URL('../js/sheet.js', import.meta.url));
  const heroRow = (id) => sqlite.prepare('SELECT name, owner_email, build, snapshot, sheet FROM msh_heroes WHERE id = ?').get(id);
  const addHero = (id, owner, snap) => sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot, sheet)
    VALUES (?, ?, ?, '{"seeds":{}}', ?, '{"notes":"mine"}')`).run(id, owner, `Hero ${id}`, JSON.stringify(snap));
  addHero('hero-ann-0001', 'ann@x.org', { health: 80, karma: 30 });
  addHero('hero-bob-0002', 'bob@x.org', { health: 50, karma: 20 });

  const one = (await call(R.list, 'POST', { body: { name: 'Tuesday' } })).body.campaign;
  const two = (await call(R.list, 'POST', { who: 'gm2@x.org', body: { name: 'Friday' } })).body.campaign;
  const p1 = { id: String(one.id) }, p2 = { id: String(two.id) };
  check('a GM creates a campaign and is its GM', one?.gm_email === 'gm@x.org' && one.open === 1);
  check('a player links their own hero to it',
    (await call(R.link, 'POST', { who: 'ann@x.org', params: p1, body: { hero_id: 'hero-ann-0001' } })).status === 201);
  check('but not someone else\'s', (await call(R.link, 'POST', { who: 'bob@x.org', params: p1, body: { hero_id: 'hero-ann-0001' } })).status === 404);

  // One open campaign at a time: the index, not the endpoint, is what refuses.
  const second = await call(R.link, 'POST', { who: 'ann@x.org', params: p2, body: { hero_id: 'hero-ann-0001' } });
  check('a second open campaign for a hero is refused with a 409 that names the first',
    second.status === 409 && /Tuesday/.test(second.body.error || ''), JSON.stringify(second));
  let threw = false;
  try { sqlite.prepare("INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by) VALUES (?, 'hero-ann-0001', 1, 'x')").run(two.id); } catch { threw = true; }
  check('and the database itself refuses it, whatever the endpoint does', threw);
  check('closing the first frees the hero to join another',
    (await call(R.one, 'PATCH', { params: p1, body: { open: false } })).status === 200
    && (await call(R.link, 'POST', { who: 'ann@x.org', params: p2, body: { hero_id: 'hero-ann-0001' } })).status === 201);
  check('and reopening the first is then refused, because the hero is in an open one',
    (await call(R.one, 'PATCH', { params: p1, body: { open: true } })).status === 409);
  await call(R.link, 'DELETE', { who: 'ann@x.org', params: p2, query: '?hero_id=hero-ann-0001' });
  check('once the hero leaves the second, the first reopens',
    (await call(R.one, 'PATCH', { params: p1, body: { open: true } })).status === 200);
  await call(R.link, 'POST', { who: 'bob@x.org', params: p2, body: { hero_id: 'hero-bob-0002' } });

  // The GM's PATCH: the four play numbers, on heroes in this campaign, and nothing else.
  const before = heroRow('hero-ann-0001');
  const hp = { id: p1.id, heroId: 'hero-ann-0001' };
  for (const [label, body] of [
    ['a name', { name: 'Renamed' }], ['a sheet field', { notes: 'the GM wrote this' }], ['the snapshot', { snapshot: {} }],
    ['the owner', { owner_email: 'gm@x.org' }], ['an ability, though it is a whole number', { strength: 5 }],
    ['a play number alongside another field', { health: -1, name: 'x' }],
    ['a play number that is not a whole amount', { karma: 1.5 }], ['an empty change', {}],
  ]) check(`the GM's PATCH refuses ${label} with a 400`, (await call(R.hero, 'PATCH', { params: hp, body })).status === 400);
  check('and none of those wrote anything', JSON.stringify(heroRow('hero-ann-0001')) === JSON.stringify(before));
  const outside = await call(R.hero, 'PATCH', { params: { id: p1.id, heroId: 'hero-bob-0002' }, body: { health: -5 } });
  check('a hero outside the campaign is a 404, and is not written', outside.status === 404
    && JSON.parse(heroRow('hero-bob-0002').sheet).health === undefined);
  check('the other campaign\'s GM cannot reach this campaign\'s hero', (await call(R.hero, 'PATCH', { who: 'gm2@x.org', params: { id: p2.id, heroId: 'hero-ann-0001' }, body: { health: -5 } })).status === 404);
  check('a player cannot use it, even on their own hero', (await call(R.hero, 'PATCH', { who: 'ann@x.org', params: hp, body: { health: 5 } })).status === 403);

  const hit = await call(R.hero, 'PATCH', { params: hp, body: { health: -10, karma_pool: 7 } });
  const after = JSON.parse(heroRow('hero-ann-0001').sheet);
  check('the GM\'s change lands on the hero\'s own row, starting from the snapshot', hit.status === 200
    && after.health === 70 && after.karma_pool === 7 && after.notes === 'mine', JSON.stringify(after));
  const logged = sqlite.prepare('SELECT field, delta, before, after, actor_email FROM msh_hero_events ORDER BY id').all();
  check('and each field is one msh_hero_events row with its before and after', logged.length === 2
    && logged[0].field === 'health' && logged[0].before === 80 && logged[0].after === 70 && logged[1].after === 7
    && logged.every((e) => e.actor_email === 'gm@x.org'), JSON.stringify(logged));
  check('the numbers are stored as integers, as the owner\'s own save writes them',
    sqlite.prepare("SELECT typeof(json_extract(sheet, '$.health')) AS t FROM msh_heroes WHERE id = 'hero-ann-0001'").get().t === 'integer');

  const ev = (await call(R.events, 'GET', { params: p1 })).body.events;
  const hpEvent = ev.find((e) => e.field === 'health');
  const undone = await call(R.events, 'POST', { params: p1, body: { undo: hpEvent.id } });
  check('undo writes the reverse as a new event and puts the number back',
    undone.status === 200 && JSON.parse(heroRow('hero-ann-0001').sheet).health === 80 && undone.body.events[0].undoes === hpEvent.id);
  check('and an event is undone once', (await call(R.events, 'POST', { params: p1, body: { undo: hpEvent.id } })).status === 409);
  check('the change log is the GM\'s alone', (await call(R.events, 'GET', { who: 'ann@x.org', params: p1 })).status === 403);

  // What each reader sees.
  const gmView = (await call(R.one, 'GET', { params: p1 })).body;
  const annView = (await call(R.one, 'GET', { who: 'ann@x.org', params: p1 })).body;
  await call(R.one, 'PATCH', { params: p1, body: { gm_notes: 'The villain is her uncle' } });
  check('the GM reads the linked hero\'s sheet through the campaign', gmView.is_gm && gmView.heroes[0].sheet?.karma_pool === 7);
  check('a player never gets gm_notes', !('gm_notes' in (await call(R.one, 'GET', { who: 'ann@x.org', params: p1 })).body.campaign)
    && (await call(R.one, 'GET', { params: p1 })).body.campaign.gm_notes === 'The villain is her uncle');
  check('and heroes.js stays owner-only: the GM cannot open the hero there',
    annView.heroes[0].sheet && (await call(R.heroes, 'GET', { query: '?id=hero-ann-0001' })).status === 404);

  // The NPC roller: hidden until shown, and only the GM rolls.
  const npc = await call(R.generate, 'POST', { params: p1, body: { name: 'Thug', powers: 3, ceiling: 'good', body: 'normal-human', dossier: true } });
  const ns = npc.body.npc?.snapshot;
  const LADDER = load('ranks.json').ranks.map((r) => r.id);
  const above = (id) => LADDER.indexOf(id) > LADDER.indexOf('good');
  check('the NPC roller writes a hero-shaped sheet with exactly the Powers asked for, none above the ceiling',
    npc.status === 201 && ns.v === sheetModV && ns.powers.length === 3 && ns.body.id === 'normal-human'
      && !ns.powers.some((p) => above(p.rank)) && !Object.values(ns.abilities).some((a) => above(a.rank)), JSON.stringify(npc.body).slice(0, 200));
  // The endpoint rolls fresh seeds, so a low roll could pass the check above
  // with no ceiling at all. With fixed seeds, the same NPC is built twice: the
  // ceiling has to be what brought every rank down.
  {
    const { rollNpc } = await import(new URL('../js/npc.js', import.meta.url));
    const { makeGenerator } = await import(new URL('../js/generator.js', import.meta.url));
    const d = {};
    for (const n of ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts']) d[n] = load(`${n}.json`);
    const g = makeGenerator(d);
    const seedsFrom = () => { let i = 0; return () => { i += 1; return Object.fromEntries(['body', 'origin', 'abilities', 'weakness', 'counts', 'powers', 'talents'].map((s, k) => [s, 1000 * i + k])); }; };
    const ranksOf = (s) => [...Object.values(s.abilities).map((x) => x.rank), ...s.powers.map((p) => p.rank)];
    const free = rollNpc(d, g, { powers: 4 }, seedsFrom()).snapshot;
    const capped = rollNpc(d, g, { powers: 4, ceiling: 'poor' }, seedsFrom()).snapshot;
    const over = (id) => LADDER.indexOf(id) > LADDER.indexOf('poor');
    check('the rank ceiling is what holds an NPC down: the same seeds with no ceiling go above Poor, with it nothing does',
      ranksOf(free).some(over) && !ranksOf(capped).some(over) && capped.powers.length === 4, JSON.stringify(ranksOf(capped)));
  }
  check('its Health is the sum of the capped numbers', ns && ns.health === ['fighting', 'agility', 'strength', 'endurance'].reduce((s, k) => s + ns.abilities[k].number, 0));
  check('and a People dossier backed by it, when asked', sqlite.prepare('SELECT sheet_id FROM msh_npcs WHERE id = ?').get(npc.body.dossier_id)?.sheet_id === npc.body.npc.id);
  check('a rolled NPC is hidden from players until the GM shows it',
    (await call(R.npcs, 'GET', { who: 'ann@x.org', params: p1 })).body.npcs.length === 0
    && (await call(R.npcs, 'GET', { params: p1 })).body.npcs.length === 1);
  check('a player cannot roll one', (await call(R.generate, 'POST', { who: 'ann@x.org', params: p1, body: { name: 'X' } })).status === 403);
  check('a count past the table\'s highest maximum is refused', (await call(R.generate, 'POST', { params: p1, body: { name: 'X', powers: 19 } })).status === 400);
  check('deleting the campaign leaves every hero where it was',
    (await call(R.one, 'DELETE', { params: p1 })).status === 200 && sqlite.prepare('SELECT count(*) AS n FROM msh_heroes').get().n === 2
      && sqlite.prepare('SELECT count(*) AS n FROM msh_hero_events').get().n === 0);
}

section('Transfer to a player: only the owner or the GM, only to someone who can sign in, and the notes stay behind');

{
  const { sqlite, env, route, call } = await marvelStandIn();
  const R = {
    transfer: await route('transfer.js'),
    npcTransfer: await route('campaigns/[id]/npc-sheets/transfer.js'),
    list: await route('campaigns.js'),
    link: await route('campaigns/[id]/heroes.js'),
    heroes: await route('heroes.js'),
  };
  const LIST = 'ann@x.org, Bob@x.org; gm@x.org';
  env.MV_SHARE_CANDIDATES = LIST;
  const heroRow = (id) => sqlite.prepare('SELECT owner_email, build, sheet, updated_at FROM msh_heroes WHERE id = ?').get(id);
  sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot, sheet, updated_at)
    VALUES ('hero-ann-0001', 'ann@x.org', 'Hero A', '{"seeds":{}}', '{"abilities":{}}', ?, '2020-01-01 00:00:00')`)
    .run(JSON.stringify({ notes: 'mine', background: 'from Queens', karma: 12 }));
  const camp = (await call(R.list, 'POST', { body: { name: 'Tuesday' } })).body.campaign;
  const p = { id: String(camp.id) };
  await call(R.link, 'POST', { who: 'ann@x.org', params: p, body: { hero_id: 'hero-ann-0001' } });
  const give = (who, to, id = 'hero-ann-0001') => call(R.transfer, 'POST', { who, body: { hero_id: id, to_email: to } });

  const cands = (await call(R.transfer, 'GET')).body.candidates;
  check('the candidates are the list, lowercased, minus the caller', JSON.stringify(cands) === '["ann@x.org","bob@x.org"]', JSON.stringify(cands));

  const before = JSON.stringify(heroRow('hero-ann-0001'));
  const notMine = await give('bob@x.org', 'gm@x.org');
  check('a hero the caller does not own is refused as missing', notMine.status === 404, JSON.stringify(notMine));
  const offList = await give('ann@x.org', 'eve@x.org');
  check('an address not on the list is refused', offList.status === 403, JSON.stringify(offList));
  check('and so is the caller themselves', (await give('ann@x.org', 'ANN@x.org')).status === 400);
  delete env.MV_SHARE_CANDIDATES;
  const unset = await give('ann@x.org', 'bob@x.org');
  check('with the list unset, every transfer is refused and nobody is a candidate',
    unset.status === 503 && (await call(R.transfer, 'GET', { who: 'ann@x.org' })).body.candidates.length === 0, JSON.stringify(unset));
  env.MV_SHARE_CANDIDATES = LIST;
  check('and none of those refusals wrote anything', JSON.stringify(heroRow('hero-ann-0001')) === before);

  const moved = await give('ann@x.org', ' Bob@X.org ');
  const after = heroRow('hero-ann-0001');
  const sheet = JSON.parse(after.sheet);
  check('the owner moves their hero: the recipient owns it now', moved.status === 200 && after.owner_email === 'bob@x.org', JSON.stringify(moved));
  check('its notes are cleared and the rest of its sheet is kept',
    sheet.notes === undefined && sheet.background === 'from Queens' && sheet.karma === 12, after.sheet);
  check('and updated_at moves', after.updated_at > '2020-01-01 00:00:00', after.updated_at);
  check('its campaign link stays', !!sqlite.prepare('SELECT 1 FROM msh_campaign_heroes WHERE hero_id = ? AND campaign_id = ?').get('hero-ann-0001', camp.id));
  check('it leaves the giver\'s list and is in the recipient\'s',
    (await call(R.heroes, 'GET', { who: 'ann@x.org' })).body.heroes.length === 0
    && (await call(R.heroes, 'GET', { who: 'bob@x.org' })).body.heroes[0]?.id === 'hero-ann-0001');
  check('and the old owner cannot move it again', (await give('ann@x.org', 'gm@x.org')).status === 404);

  // A full list is refused, in the UPDATE's own guard.
  const fill = sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES (?, 'gm@x.org', 'Filler', '{}', '{}')`);
  for (let i = 0; i < 200; i++) fill.run(`filler-${String(i).padStart(4, '0')}`);
  check('a recipient with no room left is refused, and the hero stays put',
    (await give('bob@x.org', 'gm@x.org')).status === 409 && heroRow('hero-ann-0001').owner_email === 'bob@x.org');
  sqlite.exec("DELETE FROM msh_heroes WHERE id LIKE 'filler-%'");

  // An NPC sheet: the GM's only, and it becomes a hero linked here.
  const book = JSON.stringify({ mode: 'book', book: 'ma1', character: 'x', version: 'v1', block: null });
  const npcId = Number(sqlite.prepare(`INSERT INTO msh_npc_sheets (campaign_id, name, build, snapshot, sheet, created_by)
    VALUES (?, 'Thug', ?, '{"abilities":{"fighting":{"rank":"good"}}}', ?, 'gm@x.org') RETURNING id`)
    .get(camp.id, book, JSON.stringify({ notes: 'the plot', identity: 'Joe' })).id);
  const dossier = Number(sqlite.prepare(`INSERT INTO msh_npcs (campaign_id, name, sheet_id, created_by) VALUES (?, 'Thug', ?, 'gm@x.org') RETURNING id`).get(camp.id, npcId).id);
  const giveNpc = (who, to, id = npcId) => call(R.npcTransfer, 'POST', { who, params: p, body: { npc_id: id, to_email: to } });
  const npcThere = () => !!sqlite.prepare('SELECT 1 FROM msh_npc_sheets WHERE id = ?').get(npcId);
  const heroCount = () => sqlite.prepare('SELECT count(*) AS n FROM msh_heroes').get().n;
  const n0 = heroCount();
  check('a player who is not the GM cannot transfer an NPC sheet', (await giveNpc('ann@x.org', 'bob@x.org')).status === 403);
  check('nor can the GM send one to an address not on the list', (await giveNpc('gm@x.org', 'eve@x.org')).status === 403);
  delete env.MV_SHARE_CANDIDATES;
  check('nor to anyone while the list is unset', (await giveNpc('gm@x.org', 'ann@x.org')).status === 503);
  env.MV_SHARE_CANDIDATES = LIST;
  check('and none of those wrote anything', npcThere() && heroCount() === n0);

  const made = await giveNpc('gm@x.org', 'ann@x.org');
  const newId = made.body.hero?.id ?? '';
  const h = newId && heroRow(newId);
  check('the GM\'s transfer makes a hero the recipient owns, from the sheet\'s build', made.status === 200
    && h?.owner_email === 'ann@x.org' && h.build === book && heroCount() === n0 + 1, JSON.stringify(made));
  check('with the sheet\'s notes cleared and the rest kept', !!h && JSON.parse(h.sheet).notes === undefined && JSON.parse(h.sheet).identity === 'Joe', h?.sheet);
  check('linked to this campaign', !!sqlite.prepare('SELECT 1 FROM msh_campaign_heroes WHERE hero_id = ? AND campaign_id = ? AND campaign_open = 1').get(newId, camp.id));
  check('and the NPC sheet row is gone', !npcThere());
  check('while its People dossier stays with the GM, unlinked',
    sqlite.prepare('SELECT sheet_id FROM msh_npcs WHERE id = ?').get(dossier)?.sheet_id === null);
  check('a second transfer of the same sheet finds nothing', (await giveNpc('gm@x.org', 'bob@x.org')).status === 404);
  const saved = await call(R.heroes, 'POST', { who: 'ann@x.org', body: { id: newId, name: 'Thug', build: JSON.parse(book),
    snapshot: { abilities: { fighting: { rank: 'good' } } }, sheet: { notes: 'mine now' } } });
  check('the new owner can save the sheet of a hero that came from the book', saved.status === 200
    && JSON.parse(heroRow(newId).build).mode === 'book' && JSON.parse(heroRow(newId).sheet).notes === 'mine now', JSON.stringify(saved));
}

section('An NPC from the book: the printed numbers, misprints corrected, as a hidden sheet the GM adds');

{
  const { makeBookNpc, bookChoices, isForms, NPC_BOOK_DATA } = await import(new URL('../js/npc-book.js', import.meta.url));
  const { renderSheet, tagline, SNAPSHOT_VERSION } = await import(new URL('../js/sheet.js', import.meta.url));
  const data = Object.fromEntries(NPC_BOOK_DATA.map((n) => [n, load(`${n}.json`)]));
  const bookNpc = makeBookNpc(data);
  const LADDER = new Set(data.ranks.ranks.map((r) => r.id));
  const abil = (s) => ['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche'].map((k) => s.abilities[k]);

  const nc = bookNpc({ character: 'nightcrawler' });
  check('Nightcrawler comes out as MA1 p.7 prints him: F20 A50 S6 E30 R10 I20 P20, Health 106, Karma 50',
    !nc.error && abil(nc.snapshot).map((a) => a.number).join() === '20,50,6,30,10,20,20'
    && abil(nc.snapshot).map((a) => a.rank).join() === 'excellent,amazing,typical,remarkable,good,excellent,excellent'
    && nc.snapshot.health === 106 && nc.snapshot.karma === 50 && nc.snapshot.mode === 'book' && nc.snapshot.v === SNAPSHOT_VERSION,
    JSON.stringify(nc.snapshot?.abilities));
  check('a Power the UPB has carries its code, and no Power carries a rank the book gives only in prose',
    nc.snapshot.powers.find((p) => p.name === 'Teleportation')?.code === 'T16' && nc.snapshot.powers.every((p) => p.number === null));
  check('Northstar\'s misprinted Health (printed 70) is played as the corrected 90',
    bookNpc({ character: 'northstar' }).snapshot.health === 90);
  check('a misprinted rank code cannot move a number: Poltergeist\'s "S 4 Ty" is Poor',
    bookNpc({ character: 'poltergeist' }).snapshot.abilities.strength.rank === 'poor');
  const ph = bookNpc({ character: 'phoenix' });
  check('a character with two versions asks which, and each version builds', /versions/.test(ph.error || '')
    && bookNpc({ character: 'phoenix', version: 'phoenix-current' }).snapshot?.health === 70);
  check('a version whose blocks are tiers asks which', /stat blocks/.test(bookNpc({ character: 'brood' }).error || '')
    && bookNpc({ character: 'brood', block: 2 }).name === 'Brood - Brood Queen');
  const ursa = bookNpc({ character: 'ursa-major' });
  check('a version whose blocks are forms is one NPC with forms, as a Changeling hero is',
    ursa.snapshot?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Human Form 70,Bear Form 130', JSON.stringify(ursa.snapshot?.forms));
  const choices = bookChoices(data.npcs);
  const broken = choices.filter((c) => { const r = bookNpc(c); return r.error || abil(r.snapshot).some((a) => !LADDER.has(a.rank)); });
  check(`every choice the GM is offered builds, with every ability on the ladder (${choices.length})`,
    choices.length > data.npcs.characters.length && broken.length === 0, broken.slice(0, 3).map((c) => c.label).join(' | '));
  check('and the forms test reads only labels that say so', data.npcs.characters.flatMap((c) => c.versions).filter(isForms).length > 0);
  // MA4 (scripts/msh/codegrids.py): a second grid for a human form, a partial
  // grid, and N/A ranks, each as the book prints them (survey: ma4.md)
  const thing = bookNpc({ character: 'thing-ma4' });
  check('MA4\'s Thing is one NPC with forms: his rocky grid and his Human Form (p.5)',
    thing.snapshot?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Thing 200,Human Form 50', JSON.stringify(thing.snapshot?.forms));
  check('MA4\'s Guardsman plays his corrected Health, 130 (printed 90, p.20)', bookNpc({ character: 'guardsman-ma4' }).snapshot?.health === 130);
  const destroyer = bookNpc({ character: 'destroyer-ma4' }).snapshot;
  check('MA4\'s Destroyer plays its N/A Reason and Intuition as Shift 0, which its printed Karma 100 agrees with (p.47)',
    destroyer?.karma === 100 && destroyer.abilities.reason.number === 0 && destroyer.abilities.intuition.number === 0);
  check('MA4\'s New Men are a card but not a GM choice: they print no physical ranks (p.90)',
    data.npcs.characters.some((c) => c.id === 'new-men-ma4') && !choices.some((c) => c.character === 'new-men-ma4'));
  // MA4's text verdicts: three quote marks, 17 bullets read as a letter e
  // (#2075), and 18 compounds the page breaks at a line end after the hyphen
  // (marvel-11 leftovers row 10a, Nate 2026-11-03). The text is
  // msh_book_text's: read the generated .sql in the cache, by keys and by the
  // overrides' own fragments, never a word of the book in this file.
  const ovA = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'ma4-overrides.json'), 'utf8')).overrides;
  const textA = ovA.filter((o) => o.verdict === 'text');
  const hyphA = textA.filter((o) => /[a-z]- [A-Za-z]/.test(o.read));
  check('MA4: 48 overrides: seven misprints, three rows verdicts and 38 text verdicts, 18 of them a line-end compound hyphen whose printed fragment keeps the hyphen and drops the space',
    ovA.length === 48 && ovA.filter((o) => o.verdict === 'misprint').length === 7 && ovA.filter((o) => o.verdict === 'rows').length === 3
    && textA.length === 38 && hyphA.length === 18 && hyphA.every((o) => o.printed === o.read.replace(/([a-z])- ([A-Za-z])/, '$1-$2')),
    JSON.stringify(ovA.map((o) => o.verdict)));
  const sqlA = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'ma4', 'book-text.sql');
  if (!existsSync(sqlA)) {
    check(`MA4: skipped the text checks: no ${rel(sqlA) || sqlA}`, true);
  } else {
    const rowsA = [...readFileSync(sqlA, 'utf8').matchAll(/VALUES \('([^']+)', 'ma4', '[^']+', '[^']+', (?:NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
      .map(([, key, body]) => ({ key, body: body.replace(/''/g, '\'') }));
    const countA = (row, s) => (rowsA.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
    const verdictsA = textA.map((o) => `${o.match.row} ${countA(o.match.row, o.printed)}/${countA(o.match.row, o.read)}`);
    check('MA4 text: each of the 38 text verdicts is applied, its printed fragment once in its row and the misread gone',
      rowsA.length > 900 && verdictsA.length === 38 && verdictsA.every((v) => v.endsWith(' 1/0')), verdictsA.filter((v) => !v.endsWith(' 1/0')).join(' | '));
    // Kept on purpose (read on the page, 2026-11-03): a suspended hyphen
    // (Human Torch II, the Thing, Doom II's first), or a hyphen the page
    // prints mid-line with the space (Air-Walker's two, the Skrulls', the
    // Skrull-X's, Doom II's second).
    const shapeA = rowsA.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => `${r.key.slice(4)}(${r.body.match(/[a-z]- [A-Za-z]/g).length})`).sort();
    check('MA4 text: no row reads a letter, a hyphen and a space before a word except the eight kept as the page prints them',
      shapeA.join() === ['air-walker-ma4:background(1)', 'air-walker-ma4:talents(1)', 'human-torch-ii-ma4:power:2(1)', 'skrull-ma4:member:6(1)',
        'skrull-x-ma4:background(1)', 'thing-ma4:talents(1)', 'victor-von-doom-ii-ma4:running(2)'].join(), shapeA.join(' '));
  }

  const html = renderSheet({ name: nc.name, snapshot: nc.snapshot, sheet: {} });
  check('the sheet draws a book NPC: its tagline, its Powers without a rank, and a link to its Codex card',
    tagline(nc.snapshot).startsWith('MA1 Children of the Atom, p.7') && html.includes('../codex/?section=npcs&amp;entry=nightcrawler')
    && !/undefined|\(null\)|NaN/.test(html) && !html.includes('sh-side'), tagline(nc.snapshot));
  check('the forms render as forms', renderSheet({ name: 'U', snapshot: ursa.snapshot }).includes('2nd form: Bear Form'));

  // MHSP1 prints ranks only, cites two booklets numbered alike, and has a
  // character with a "?" rank (scripts/msh/booklet.py, mhsp1-overrides.json).
  if (data.npcs.characters.some((c) => c.book === 'mhsp1')) {
    const lh = bookNpc({ character: 'lockheed-mhsp1' });
    check('MHSP1: Lockheed\'s printed "?" Reason plays as Shift 0, as his printed Karma 40 counts it',
      lh.snapshot?.abilities.reason.rank === 'shift-0' && lh.snapshot.abilities.reason.number === 0 && lh.snapshot.karma === 40,
      JSON.stringify(lh.snapshot?.abilities.reason));
    const sh = bookNpc({ character: 'she-hulk-mhsp1' });
    check('MHSP1: an alter ego\'s one-line block is a form, so She-Hulk is one NPC with forms',
      sh.snapshot?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'She-Hulk 150,Jennifer Walters 26', JSON.stringify(sh.snapshot?.forms));
    check('MHSP1: Klaw\'s sound creatures are a block of their own to choose, not a form',
      /stat blocks/.test(bookNpc({ character: 'klaw-mhsp1' }).error || '') && bookNpc({ character: 'klaw-mhsp1', block: 1 }).snapshot?.health === 72);
    const gal = bookNpc({ character: 'galactus-mhsp1' });
    check('MHSP1: a printed "2,150 (Varies)" is Health 2150, and a rank word is a Resources rank (CLASS 1000)',
      gal.snapshot?.health === 2150 && gal.snapshot.abilities.resources.rank === 'class-1000', `${gal.snapshot?.health} ${JSON.stringify(gal.snapshot?.abilities.resources)}`);
    // The bases' room table, transcribed by eye (books.json locations[].rooms):
    // sectors A-Z whose d100 ranges tile 01-00 with no gap and no overlap, and
    // a room for every base in every row, so a typo in a range cannot pass.
    const bases = load('items.json').items.find((i) => i.id === 'item-the-battleplanet-bases-mhsp1');
    const rooms = bases?.rooms;
    const tiled = rooms && rooms.rows.map(([, r]) => r.split('-').map((n) => (n === '00' ? 100 : Number(n))))
      .every(([lo, hi], i, all) => lo === (i ? all[i - 1][1] + 1 : 1) && hi >= lo && (i < all.length - 1 || hi === 100));
    check('MHSP1: the bases\' room table is 26 sectors, A to Z, whose d100 ranges tile 01-00, a room for each of 4 bases',
      rooms?.columns.length === 4 && rooms.rows.length === 26 && rooms.rows.map((r) => r[0]).join('') === 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      && tiled && rooms.rows.every((r) => r.length === 6 && r.slice(2).every(Boolean)), JSON.stringify(rooms?.rows?.slice(0, 2)));
    check('MHSP1: the sheet cites the booklet with the page, and a Summary-only character the booklet alone',
      tagline(bookNpc({ character: 'colossus-mhsp1' }).snapshot).startsWith('MHSP1 Secret Wars, Roster p.2;')
      && tagline(bookNpc({ character: 'spider-man-mhsp1' }).snapshot).startsWith('MHSP1 Secret Wars, Reference Summary;'),
      tagline(bookNpc({ character: 'spider-man-mhsp1' }).snapshot));
    // MHSP1's text verdicts: two compounds the page breaks at a line end after
    // the hyphen (marvel-11 leftovers row 10k, Nate 2026-11-03). The text is
    // msh_book_text's: read the generated .sql in the cache, by keys and by the
    // overrides' own fragments, never a word of the book in this file.
    const ovP = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mhsp1-overrides.json'), 'utf8')).overrides;
    const textP = ovP.filter((o) => o.verdict === 'text');
    check('MHSP1: ten overrides: one as printed, three labels, three chart misprints, one chart blank and two text verdicts (She-Hulk\'s background and Spider-Woman\'s Psychic Web), each a line-end compound hyphen whose printed fragment keeps the hyphen and drops the space',
      ovP.length === 10 && ovP.filter((o) => o.verdict === 'as_printed').length === 1 && ovP.filter((o) => o.verdict === 'label').length === 3
      && ovP.filter((o) => o.verdict === 'summary_misprint').length === 3 && ovP.filter((o) => o.verdict === 'summary_blank').length === 1
      && textP.map((o) => o.match.row).join() === 'mhsp1:she-hulk-mhsp1:background,mhsp1:spider-woman-mhsp1:power:2'
      && textP.every((o) => o.printed === o.read.replace(/([a-z])- ([A-Za-z])/, '$1-$2')),
      JSON.stringify(ovP.map((o) => [o.verdict, o.match])));
    const sqlP = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mhsp1', 'book-text.sql');
    if (!existsSync(sqlP)) {
      check(`MHSP1: skipped the text checks: no ${rel(sqlP) || sqlP}`, true);
    } else {
      const rowsP = [...readFileSync(sqlP, 'utf8').matchAll(/VALUES \('([^']+)', 'mhsp1', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, , body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const countP = (row, s) => (rowsP.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsP = textP.map((o) => `${o.match.row} ${countP(o.match.row, o.printed)}/${countP(o.match.row, o.read)}`);
      check('MHSP1 text: each of the two text verdicts is applied, its printed fragment once in its row and the misread gone',
        rowsP.length > 0 && textP.length === 2 && verdictsP.every((v) => v.endsWith(' 1/0')), `${rowsP.length} rows; ${verdictsP.join(' | ')}`);
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>": MHSP1's two are closed up by the
      // text verdicts above. The one left is the Lizard's Alter Ego, which the
      // page prints mid-line with its space ("alter- ego"), so it stays as read.
      const shapeP = rowsP.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.slice(6))).sort();
      check('MHSP1 text: no row reads a letter, a hyphen and a space before a word but the one kept on purpose (the Lizard\'s Alter Ego, printed so mid-line)',
        rowsP.length > 0 && shapeP.join() === 'lizard-mhsp1:power:6', shapeP.join(' '));
    }
  }

  // ME1 prints MA1's numbered grids in two booklets numbered alike, with a
  // chart of its pregenerated heroes (scripts/msh/gridbooks.py, me1-overrides.json).
  if (data.npcs.characters.some((c) => c.book === 'me1')) {
    const me1 = data.npcs.characters.filter((c) => c.book === 'me1');
    check('ME1: 37 characters, 4 of them on the Pregenerated Heroes Summary alone',
      me1.length === 37 && me1.filter((c) => c.summary_only).map((c) => c.name).sort().join() === 'Doc Strange,Nova,Silver Surfer,Thor',
      `${me1.length} ${me1.filter((c) => c.summary_only).map((c) => c.name)}`);
    const oo = bookNpc({ character: 'typical-oolafat-me1' }).snapshot;
    check('ME1: the Oolafat\'s Reason, Intuition and Psyche, printed as one line linking them to Ego, play as Shift 0, as its Karma 0 counts them',
      ['reason', 'intuition', 'psyche'].every((k) => oo?.abilities[k].rank === 'shift-0' && oo.abilities[k].number === 0) && oo.health === 50 && oo.karma === 0,
      JSON.stringify(oo?.abilities.reason));
    const sk = bookNpc({ character: 'superkree-me1' }).snapshot;
    check('ME1: the Superkree\'s Fighting 275 is Shift Y by its range, and his Health 575 counts the 275',
      sk?.abilities.fighting.rank === 'shift-y' && sk.abilities.fighting.number === 275 && sk.health === 575, JSON.stringify(sk?.abilities.fighting));
    const gc = bookNpc({ character: 'ghoul-captain-me1' }).snapshot;
    check('ME1: the Ghoul Captain\'s misprinted "50 Mn" Agility plays as Amazing', gc?.abilities.agility.rank === 'amazing', JSON.stringify(gc?.abilities.agility));
    const ego = bookNpc({ character: 'ego-me1' }).snapshot;
    check('ME1: Ego\'s Class ranks read as Class ranks, and his Health 6502 is theirs',
      ego?.abilities.fighting.rank === 'class-1000' && ego.abilities.endurance.rank === 'class-5000' && ego.health === 6502,
      `${ego?.abilities.fighting.rank} ${ego?.abilities.endurance.rank} ${ego?.health}`);
    const novaFlight = bookNpc({ character: 'nova-me1' }).snapshot?.powers.find((p) => p.name === 'Flight');
    check('ME1: a chart power printed with its rank ("Flight-Cl 3000") is the UPB\'s Flight at Class 3000',
      novaFlight?.code === 'T21' && novaFlight.rank === 'class-3000', JSON.stringify(novaFlight));
    check('ME1: a Popularity printed with a minus is a number below zero (Maximus, -20)',
      bookNpc({ character: 'maximus-me1' }).snapshot?.abilities.popularity.number === -20);
    check('ME1: the sheet cites the booklet with the page, and a chart-only hero the chart alone',
      tagline(bookNpc({ character: 'mantis-me1' }).snapshot).startsWith('ME1 Cosmos Cubed, Adventure p.3;')
      && tagline(bookNpc({ character: 'nova-me1' }).snapshot).startsWith('ME1 Cosmos Cubed, Pregenerated Heroes Summary;'),
      tagline(bookNpc({ character: 'nova-me1' }).snapshot));
    // ME1's text verdicts: five bullets read as a letter e (#2076), and one
    // compound the page breaks at a line end after the hyphen (marvel-11
    // leftovers row 10b, Nate 2026-11-03). The text is msh_book_text's: read
    // the generated .sql in the cache, by keys and by the overrides' own
    // fragments, never a word of the book in this file.
    const ovE = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'me1-overrides.json'), 'utf8')).overrides;
    const textE = ovE.filter((o) => o.verdict === 'text');
    const hyphE = textE.filter((o) => /[a-z]- [A-Za-z]/.test(o.read));
    check('ME1: ten overrides: one rows, one misprint, one as printed, one chart misprint and six text verdicts, one of them a line-end compound hyphen whose printed fragment keeps the hyphen and drops the space',
      ovE.length === 10 && ['rows', 'misprint', 'as_printed', 'summary_misprint'].every((v) => ovE.filter((o) => o.verdict === v).length === 1)
      && textE.length === 6 && hyphE.length === 1 && hyphE.every((o) => o.printed === o.read.replace(/([a-z])- ([A-Za-z])/, '$1-$2')),
      JSON.stringify(ovE.map((o) => o.verdict)));
    const sqlE = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'me1', 'book-text.sql');
    if (!existsSync(sqlE)) {
      check(`ME1: skipped the text checks: no ${rel(sqlE) || sqlE}`, true);
    } else {
      const rowsE = [...readFileSync(sqlE, 'utf8').matchAll(/VALUES \('([^']+)', 'me1', '[^']+', '[^']+', (?:NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const countE = (row, s) => (rowsE.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsE = textE.map((o) => `${o.match.row} ${countE(o.match.row, o.printed)}/${countE(o.match.row, o.read)}`);
      check('ME1 text: each of the six text verdicts is applied, its printed fragment once in its row and the misread gone',
        rowsE.length === 198 && verdictsE.length === 6 && verdictsE.every((v) => v.endsWith(' 1/0')), verdictsE.filter((v) => !v.endsWith(' 1/0')).join(' | ') || `${rowsE.length} rows`);
      const shapeE = rowsE.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('ME1 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        shapeE.length === 0, shapeE.join(' '));
    }
  }

  // MHSP2 is MHSP1's kind of module set another way, its Roster Book in team
  // banners (scripts/msh/rosterbook.py, mhsp2-overrides.json, survey mhsp2.md).
  if (data.npcs.characters.some((c) => c.book === 'mhsp2')) {
    const m2 = data.npcs.characters.filter((c) => c.book === 'mhsp2');
    const team = (t) => m2.filter((c) => c.team === t).length;
    check('MHSP2: 93 characters; the banners lose their "The" and join the groups other books file under, The Bad Guys are Secret Wars II Villains, and the four under no banner file under the book',
      m2.length === 93 && team('X-Men') === 9 && team('New Mutants') === 9 && team('Fantastic Four') === 4 && team('Avengers') === 7
      && team('Secret Wars II Villains') === 23 && m2.filter((c) => c.team === 'MHSP2 Secret Wars II').map((c) => c.name).sort().join() === 'Beyonder,Death,Eternity,Mephisto'
      && !m2.some((c) => /^The /.test(c.team)), `${m2.length} ${[...new Set(m2.map((c) => c.team))]}`);
    check('MHSP2: Heroes and Others (p.19) and And of Course (p.32) file as Secret Wars II Heroes, as The Bad Guys file as Secret Wars II Villains',
      team('Secret Wars II Heroes') === 17 && team('Heroes and Others') === 0 && team('And of Course') === 0
      && !data.npcs.teams.some((t) => t === 'Heroes and Others' || t === 'And of Course'),
      `${team('Secret Wars II Heroes')} ${team('Heroes and Others')} ${team('And of Course')}`);
    const by = bookNpc({ character: 'beyonder-mhsp2', block: 0 }).snapshot;
    check('MHSP2: the Beyonder\'s Original State, printed BEYOND with no number, plays as Beyond',
      abil(by || { abilities: {} }).every((a) => a?.rank === 'beyond' && a.number === null), JSON.stringify(by?.abilities.fighting));
    const wb = bookNpc({ character: 'wolfsbane-mhsp2' }).snapshot;
    check('MHSP2: an alter ego\'s or a form\'s one-line block is a form, so Wolfsbane is one NPC with three forms',
      wb?.forms?.map((f) => f.name).join() === 'Wolfsbane,Wolf form,Wolfoid form', JSON.stringify(wb?.forms?.map((f) => f.name)));
    // The Puma prints both forms in one block, a slash in each rank and in
    // his Health (Roster 23: TYPICAL/REMARKABLE, 36/150) and one Karma, 60.
    const puma = bookNpc({ character: 'puma-mhsp2' }).snapshot;
    const pumaBlocks = m2.find((c) => c.id === 'puma-mhsp2')?.versions[0].blocks || [];
    check('MHSP2: the Puma\'s slashed block is two forms on his card, Thomas Fireheart (36) and Puma (150), each Karma 60 as printed, one NPC to add',
      puma?.forms?.map((f) => `${f.name} ${f.health} ${f.karma}`).join() === 'Thomas Fireheart 36 60,Puma 150 60'
      && pumaBlocks.every((b) => b.abilities.every((a) => a.length === 3))
      && choices.filter((c) => c.character === 'puma-mhsp2').length === 1,
      JSON.stringify(puma?.forms?.map((f) => [f.name, f.health, f.karma])));
    check('MHSP2: a one-line block printing four codes is a card but not a GM choice (Psycho-Man\'s suits, Valkyrie\'s Aragorn)',
      choices.filter((c) => c.character === 'psycho-man-mhsp2').length === 1 && choices.filter((c) => c.character === 'valkyrie-mhsp2').length === 1
      && /stat blocks/.test(bookNpc({ character: 'thundersword-mhsp2' }).error || ''));
    check('MHSP2: an entry of tiers alone opens with prose, not an identity (Kingpin\'s Organization)',
      m2.find((c) => c.id === 'kingpin-s-organization-mhsp2')?.versions[0].identity.length === 0);
    // MHSP2's text verdicts: Mephisto's doubled quote mark, then six line-end
    // hyphen breaks (marvel-11 leftovers row 10l, Nate 2026-11-03). The text is
    // msh_book_text's: read the generated .sql in the cache, by keys and by the
    // overrides' own fragments, never a word of the book in this file.
    const ovS2 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mhsp2-overrides.json'), 'utf8')).overrides;
    const textS2 = ovS2.filter((o) => o.verdict === 'text');
    const hyphS2 = textS2.slice(1);
    check('MHSP2: 33 overrides: ten misprints, two as printed, nine labels, one chart misprint, three rows, one powers intro and seven text verdicts (Mephisto\'s doubled quote mark, She-Hulk\'s running note closing up one word broken at a line end, and five line-end compound hyphens, Air-Walker once and Hate-Monger four times, whose printed fragment keeps the hyphen and drops the space)',
      ovS2.length === 33 && ovS2.filter((o) => o.verdict === 'misprint').length === 10 && ovS2.filter((o) => o.verdict === 'as_printed').length === 2
      && ovS2.filter((o) => o.verdict === 'label').length === 9 && ovS2.filter((o) => o.verdict === 'summary_misprint').length === 1
      && ovS2.filter((o) => o.verdict === 'rows').length === 3 && ovS2.filter((o) => o.verdict === 'powers_intro').length === 1
      && textS2.map((o) => o.match.row.slice(6)).join() === 'mephisto-mhsp2:power:3,she-hulk-mhsp2:running,firelord-mhsp2:running,hate-monger-mhsp2:power:1,hate-monger-mhsp2:power:2,hate-monger-mhsp2:power:2,psycho-man-mhsp2:power:2'
      && hyphS2[0].printed === hyphS2[0].read.replace(/([a-z])- [A-Z]([a-z])/, (s, a, b) => a + s[3].toLowerCase() + b)
      && hyphS2.slice(1).every((o) => o.printed === o.read.replace(/([a-z])- ([A-Za-z])/, '$1-$2')),
      JSON.stringify(ovS2.map((o) => [o.verdict, o.match])));
    const sqlS2 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mhsp2', 'book-text.sql');
    if (!existsSync(sqlS2)) {
      check(`MHSP2: skipped the text checks: no ${rel(sqlS2) || sqlS2}`, true);
    } else {
      const rowsS2 = [...readFileSync(sqlS2, 'utf8').matchAll(/VALUES \('([^']+)', 'mhsp2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, , body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const countS2 = (row, s) => (rowsS2.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsS2 = hyphS2.map((o) => `${o.match.row} ${countS2(o.match.row, o.printed)}/${countS2(o.match.row, o.read)}`);
      check('MHSP2 text: each of the six line-end hyphen verdicts is applied, its printed fragment once in its row and the misread gone',
        rowsS2.length > 0 && hyphS2.length === 6 && verdictsS2.every((v) => v.endsWith(' 1/0')), `${rowsS2.length} rows; ${verdictsS2.join(' | ')}`);
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>": MHSP2's six are closed up by the
      // text verdicts above, and none is kept on purpose.
      const shapeS2 = rowsS2.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.slice(6))).sort();
      check('MHSP2 text: no row reads a letter, a hyphen and a space before a word',
        rowsS2.length > 0 && shapeS2.length === 0, shapeS2.join(' '));
    }
  }

  // MH1 prints MHSP1's rank words on two loose cover panels and in one-line
  // grids inside its chapters (scripts/msh/coverpanels.py, mh1-overrides.json).
  if (data.npcs.characters.some((c) => c.book === 'mh1')) {
    const mh1 = data.npcs.characters.filter((c) => c.book === 'mh1');
    const xmen = mh1.filter((c) => c.team === 'X-Men').map((c) => c.name).sort().join();
    check('MH1: 25 characters, the eight X-Men filed with MA1\'s X-Men and the rest under the book\'s title',
      mh1.length === 25 && xmen === 'Ariel (Kitty Pryde),Colossus,Lockheed the Dragon,Nightcrawler,Professor X,Rogue,Storm,Wolverine'
      && mh1.every((c) => c.team === 'X-Men' || c.team === 'MH1 The Breeder Bombs'), `${mh1.length} ${xmen}`);
    // two different people who print one name (registry card_names, Nate
    // 2026-10-21): each card says which, the parenthesis part of the name
    const ariels = data.npcs.characters.filter((c) => /^Ariel\b/.test(c.name))
      .map((c) => [c.book, c.id, c.name, c.versions.map((v) => `${v.id}/${v.label}`).join()].join(' ')).sort().join(' | ');
    check('MA1\'s and MH1\'s Ariels are two cards named for who each is, the parenthesis in the name and no version label',
      ariels === 'ma1 ariel-fallen-angel Ariel (Fallen Angel) ariel-fallen-angel/null | mh1 ariel-kitty-pryde-mh1 Ariel (Kitty Pryde) ariel-kitty-pryde-mh1/null', ariels);
    const block = (id) => mh1.find((c) => c.id === id)?.versions[0].blocks[0];
    const derived = ['fluffy-mh1', 'augie-hickman-mh1'].map((id) => [block(id), bookNpc({ character: id }).snapshot]);
    check('MH1: Fluffy and Augie Hickman print no Health, so theirs is derived from their ranks (80, 26) and flagged so',
      derived.map(([, s]) => s?.health).join() === '80,26' && derived.every(([b]) => b?.health_derived === true && b.rank_only === true)
      && mh1.filter((c) => c.versions.some((v) => v.blocks.some((b) => b.health_derived))).length === 2,
      derived.map(([b, s]) => `${s?.health} ${b?.health_derived}`).join(' | '));
    const claws = block('robot-wolverine-mh1')?.override;
    check('MH1: the Robot Wolverine\'s claws, printed "Remarkable (20 points)", are corrected to 30 and keep the printed 20',
      claws?.verdict === 'misprint' && claws.printed === 20 && claws.corrected === 30, JSON.stringify(claws));
    const dashed = ['false-blob-mh1', 'false-quicksilver-mh1', 'false-scarlet-witch-mh1', 'false-toad-mh1'].map((id) => bookNpc({ character: id }).snapshot);
    const fm = bookNpc({ character: 'false-magneto-mh1' }).snapshot;
    check('MH1: four False robots\' dashed Intuition and Psyche play as Shift 0 with Karma unset; False Magneto, who prints both, does not',
      dashed.every((s) => ['intuition', 'psyche'].every((k) => s?.abilities[k].rank === 'shift-0' && s.abilities[k].number === 0) && s.karma === null)
      && fm?.abilities.intuition.rank === 'good' && fm.abilities.psyche.rank === 'poor',
      dashed.map((s) => `${s?.abilities.intuition.rank} ${s?.karma}`).join(' | '));
    const lock = bookNpc({ character: 'lockheed-the-dragon-mh1' }).snapshot;
    check('MH1: Lockheed\'s printed "?" Reason plays as Shift 0, and with no printed Karma his stays unset',
      lock?.abilities.reason.rank === 'shift-0' && lock.abilities.reason.number === 0 && lock.karma === null, JSON.stringify(lock?.abilities.reason));
    check('MH1: a cover-panel card cites its panel with no page, and a chapter opponent its Adventure page',
      tagline(bookNpc({ character: 'colossus-mh1' }).snapshot).startsWith('MH1 The Breeder Bombs, Inside front cover;')
      && tagline(bookNpc({ character: 'storm-mh1' }).snapshot).startsWith('MH1 The Breeder Bombs, Inside back cover;')
      && tagline(bookNpc({ character: 'fixer-mh1' }).snapshot).startsWith('MH1 The Breeder Bombs, Adventure p.3;'),
      tagline(bookNpc({ character: 'colossus-mh1' }).snapshot));
  }

  // MH2 is laid out as MH1 is (scripts/msh/coverpanels.py, mh2-overrides.json),
  // with Nate's six rulings of 2026-10-21 (survey mh2.md decisions 1-6).
  if (data.npcs.characters.some((c) => c.book === 'mh2')) {
    const mh2 = data.npcs.characters.filter((c) => c.book === 'mh2');
    const avengers = mh2.filter((c) => c.team === 'Avengers').map((c) => c.name).sort().join();
    check('MH2: 20 characters, the six on the cover panels filed as Avengers and the rest, Skrulls included, under the book\'s title',
      mh2.length === 20 && avengers === 'Captain America,Captain Marvel,Scarlet Witch,Starfox,Vision,Wasp'
      && mh2.every((c) => c.team === 'Avengers' || c.team === 'MH2 Time Trap'), `${mh2.length} ${avengers}`);
    const blk = (id) => mh2.find((c) => c.id === id)?.versions[0].blocks[0];
    const minions = bookNpc({ character: 'kang-s-minions-mh2' }).snapshot;
    check('MH2: Kang\'s Minions print no Karma, so theirs is derived as R+I+P (10) and flagged so, with MH3\'s two, MT3\'s Snakes and Scorpions, MLA1\'s Alligator, Rat, pack of 10 and Mosquito Swarm, MLBA1\'s three animals and MLA3\'s Bertha the Gorilla and Alligators the only ones in any book',
      minions?.karma === 10 && blk('kang-s-minions-mh2')?.karma_derived === true
      && data.npcs.characters.filter((c) => c.versions.some((v) => v.blocks.some((b) => b.karma_derived))).map((c) => c.id).sort().join()
        === 'alligator-mla1,alligators-mla3,bertha-the-gorilla-mla3,chicken-mlba1,chimpanzee-mlba1,giant-dalmatian-mlba1,kang-s-minions-mh2,miss-locke-mh3,mosquito-swarm-mla1,mr-chambers-mh3,rat-pack-of-10-mla1,scorpions-mt3,snakes-mt3',
      `${minions?.karma} ${blk('kang-s-minions-mh2')?.karma_derived}`);
    const mimic = bookNpc({ character: 'mimic-mh2' }).snapshot;
    check('MH2: the Mimic\'s absorbed form is a second block on his card, so he is one NPC with two forms (24 and 170)',
      mimic?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Mimic 24,Absorbed Form 170'
      && choices.filter((c) => c.character === 'mimic-mh2').length === 1, JSON.stringify(mimic?.forms?.map((f) => [f.name, f.health])));
    const spiders = blk('energy-spiders-mh2');
    check('MH2: the Energy Spiders\' Health, printed 46, plays as their ranks\' 44 and keeps the printed 46',
      spiders?.health === '46' && spiders.override?.verdict === 'misprint' && spiders.override.corrected === 44
      && bookNpc({ character: 'energy-spiders-mh2' }).snapshot?.health === 44, JSON.stringify(spiders?.override));
    const zero = ['spirits-mh2', 'omegatrons-mh2', 'centipedes-mh2', 'energy-spiders-mh2'];
    check('MH2: the four machine and spirit grids keep their printed Karma 0',
      zero.every((id) => bookNpc({ character: id }).snapshot?.karma === 0), zero.map((id) => bookNpc({ character: id }).snapshot?.karma).join());
    const ov2 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh2-overrides.json'), 'utf8')).overrides;
    const text2 = ov2.filter((o) => o.verdict === 'text');
    check('MH2: six overrides: the three as-printed Karma 0 grids, the Energy Spiders\' misprint, and two text verdicts (Super-Skrull\'s Shape-Shifting and Generate and Control Fire), each a line-end hyphen break whose printed fragment no longer reads the shape',
      ov2.length === 6 && ov2.filter((o) => o.verdict === 'as_printed').length === 3 && ov2.filter((o) => o.verdict === 'misprint').length === 1
      && text2.map((o) => o.match.row).join() === ['super-skrull-mh2:power:1', 'super-skrull-mh2:power:4'].map((k) => `mh2:${k}`).join()
      && text2.every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed)),
      JSON.stringify(ov2.map((o) => [o.verdict, o.match])));
    // read the generated .sql in the cache, by keys and by the overrides' own
    // fragments, never a sentence of the book in this file.
    const sql2 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh2', 'book-text.sql');
    if (!existsSync(sql2)) {
      check(`MH2: skipped the text checks: no ${rel(sql2) || sql2}`, true);
    } else {
      const rows2 = [...readFileSync(sql2, 'utf8').matchAll(/VALUES \('([^']+)', 'mh2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, , body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const count2 = (row, s) => (rows2.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts2 = text2.map((o) => `${o.match.row} ${count2(o.match.row, o.printed)}/${count2(o.match.row, o.read)}`);
      check('MH2 text: each of the two text verdicts is applied, its printed fragment once in its row and the misread gone',
        rows2.length > 0 && text2.length === 2 && verdicts2.every((v) => v.endsWith(' 1/0')), `${rows2.length} rows; ${verdicts2.join(' | ')}`);
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10e, Nate
      // 2026-11-03): MH2's two are closed up by the text verdicts above
      const shape2 = rows2.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('MH2 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        rows2.length > 0 && shape2.length === 0, shape2.join(' '));
    }
  }

  // MH3 is laid out as MH1 and MH2 are (scripts/msh/coverpanels.py,
  // mh3-overrides.json), with Nate's seven rulings of 2026-10-21 (survey
  // mh3.md decisions 1-7) and his ruling that a leading The is dropped.
  if (data.npcs.characters.some((c) => c.book === 'mh3')) {
    const mh3 = data.npcs.characters.filter((c) => c.book === 'mh3');
    const team = (t) => mh3.filter((c) => c.team === t).map((c) => c.name).sort().join();
    check('MH3: 20 characters, the five heroes as the Fantastic Four, Franklin and Alicia as Friends of the FF, three Skrulls, the rest under the book\'s title, and no name starting The',
      mh3.length === 20 && team('Fantastic Four') === 'Human Torch,Invisible Girl,Mr. Fantastic,She-Hulk,Thing'
      && team('Friends of the FF') === 'Alicia Masters,Franklin Richards' && team('Skrulls') === 'Captain Sk\'yll,Sally Flack,Skrull Soldiers'
      && mh3.filter((c) => c.team === 'MH3 Murderworld!').length === 10 && !mh3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh3.length} ${[...new Set(mh3.map((c) => c.team))]}`);
    const forms = (id) => bookNpc({ character: id }).snapshot?.forms?.map((f) => `${f.name} ${f.health}`).join();
    check('MH3: the Super-Adaptoid\'s current form and the She-Hulk\'s and the Thing\'s human forms are second blocks on their cards, one NPC each',
      forms('super-adaptoid-mh3') === 'Super-Adaptoid 150,Current Form 150' && forms('she-hulk-mh3') === 'She-Hulk 150,Jennifer Walters 26'
      && forms('thing-mh3') === 'Thing 200,Ben Grimm 50'
      && ['super-adaptoid-mh3', 'she-hulk-mh3', 'thing-mh3'].every((id) => choices.filter((c) => c.character === id).length === 1),
      [forms('super-adaptoid-mh3'), forms('she-hulk-mh3'), forms('thing-mh3')].join(' | '));
    const blk = (id) => mh3.find((c) => c.id === id)?.versions[0].blocks[0];
    check('MH3: Miss Locke\'s and Mr. Chambers\' printed Karma none is derived as R+I+P (30, 32) and flagged; the Super-Adaptoid\'s varies is kept and not derived',
      bookNpc({ character: 'miss-locke-mh3' }).snapshot?.karma === 30 && bookNpc({ character: 'mr-chambers-mh3' }).snapshot?.karma === 32
      && blk('miss-locke-mh3')?.karma_derived === true && blk('mr-chambers-mh3')?.karma_derived === true
      && blk('super-adaptoid-mh3')?.karma === 'varies' && !blk('super-adaptoid-mh3')?.karma_derived,
      `${bookNpc({ character: 'miss-locke-mh3' }).snapshot?.karma} ${bookNpc({ character: 'mr-chambers-mh3' }).snapshot?.karma} ${blk('super-adaptoid-mh3')?.karma}`);
  }

  // MH4 is laid out as MH1-MH3 are (scripts/msh/coverpanels.py,
  // mh4-overrides.json), with the survey's nine decisions applied as it
  // recommends (mh4.md; #1954 and #1955 merged without a ruling on them) and
  // Nate's ruling that a leading The is dropped.
  if (data.npcs.characters.some((c) => c.book === 'mh4')) {
    const mh4 = data.npcs.characters.filter((c) => c.book === 'mh4');
    check('MH4: 18 characters, every one under the book\'s title (no teams), each id ending -mh4, the Kingpin as Kingpin and no name starting The',
      mh4.length === 18 && mh4.every((c) => c.team === 'MH4 Lone Wolves' && c.id.endsWith('-mh4'))
      && mh4.some((c) => c.id === 'kingpin-mh4' && c.name === 'Kingpin') && !mh4.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh4.length} ${[...new Set(mh4.map((c) => c.team))]}`);
    const blk = (id) => mh4.find((c) => c.id === id)?.versions[0].blocks[0];
    const modok = blk('modok-mh4');
    const fisk = blk('kingpin-mh4');
    check('MH4: Modok\'s Health, printed 30, plays as his ranks\' 28 and keeps the printed 30; the Kingpin\'s Karma, printed 120, plays as 40 and keeps 120',
      modok?.health === '30' && modok.override?.verdict === 'misprint' && modok.override.printed === 30 && modok.override.corrected === 28
      && bookNpc({ character: 'modok-mh4' }).snapshot?.health === 28
      && fisk?.karma === '120' && fisk.override?.verdict === 'misprint' && fisk.override.printed === 120 && fisk.override.corrected === 40
      && bookNpc({ character: 'kingpin-mh4' }).snapshot?.karma === 40,
      `${JSON.stringify(modok?.override)} ${bookNpc({ character: 'modok-mh4' }).snapshot?.health} ${JSON.stringify(fisk?.override)} ${bookNpc({ character: 'kingpin-mh4' }).snapshot?.karma}`);
    const ver = (id) => mh4.find((c) => c.id === id)?.versions[0];
    const gear = ['Guns', 'Grenades', 'Knife', 'Van'];
    check('MH4: the Punisher\'s Equipment run-ins are not powers (no powers, no Powers none. row) and his and the Taskmaster\'s Equipment is text',
      ver('punisher-mh4')?.powers.length === 0 && ver('punisher-mh4').text.join() === 'background,equipment,talents'
      && ver('taskmaster-mh4')?.text.includes('equipment')
      && !mh4.some((c) => c.versions.some((v) => v.powers.some((p) => gear.includes(p.name)))),
      `${JSON.stringify(ver('punisher-mh4')?.powers)} ${ver('punisher-mh4')?.text}`);
    check('MH4: the five cards that print Important People carry it as text',
      mh4.filter((c) => c.versions[0].text.includes('important-people')).map((c) => c.id).sort().join()
        === 'black-widow-mh4,daredevil-mh4,iron-fist-mh4,kingpin-mh4,power-man-mh4',
      mh4.filter((c) => c.versions[0].text.includes('important-people')).map((c) => c.id).join());
    const grids = ['reggie-mh4', 'white-tiger-mh4', 'panthers-mh4', 'leopard-mh4', 'flying-tigers-mh4', 'modok-s-minions-mh4', 'cyber-sergeants-mh4'];
    check('MH4: of the seven one-line grids only Reggie prints a Karma (14); the other six stay unset and none is derived',
      bookNpc({ character: 'reggie-mh4' }).snapshot?.karma === 14 && blk('reggie-mh4')?.karma === '14'
      && grids.slice(1).every((id) => blk(id)?.karma === null && bookNpc({ character: id }).snapshot?.karma === null)
      && grids.every((id) => blk(id)?.kind === 'line' && !blk(id).karma_derived),
      grids.map((id) => `${id} ${blk(id)?.karma}`).join(' | '));
    check('MH4: the three cats and the Flying Tigers keep their one Special power, with no text row for its empty body',
      ['white-tiger-mh4', 'panthers-mh4', 'leopard-mh4', 'flying-tigers-mh4'].map((id) => `${ver(id)?.powers.map((p) => p.name).join()} ${ver(id)?.text.includes('power')}`).join()
        === 'Claws false,Claws false,Claws false,Martial Arts false');
    check('MH4: a cover-panel card cites its panel with no page, and the Kingpin his Adventure page',
      tagline(bookNpc({ character: 'daredevil-mh4' }).snapshot).startsWith('MH4 Lone Wolves, Inside front cover;')
      && tagline(bookNpc({ character: 'iron-fist-mh4' }).snapshot).startsWith('MH4 Lone Wolves, Inside back cover;')
      && tagline(bookNpc({ character: 'kingpin-mh4' }).snapshot).startsWith('MH4 Lone Wolves, Adventure p.5;'),
      tagline(bookNpc({ character: 'kingpin-mh4' }).snapshot));
  }

  // MH5 is laid out as MH1-MH4 are (scripts/msh/coverpanels.py,
  // mh5-overrides.json), with the survey's eleven decisions applied as it
  // recommends (mh5.md; merged without a ruling on them) and Nate's ruling
  // that a leading The is dropped.
  if (data.npcs.characters.some((c) => c.book === 'mh5')) {
    const mh5 = data.npcs.characters.filter((c) => c.book === 'mh5');
    const team = (t) => mh5.filter((c) => c.team === t).map((c) => c.name).sort().join();
    check('MH5: 23 characters, eight as Alpha Flight and the rest (Gary Cody too) under the book\'s title, each id ending -mh5, the Leader as Leader and no name starting The',
      mh5.length === 23 && mh5.every((c) => c.id.endsWith('-mh5'))
      && team('Alpha Flight') === 'Aurora,Heather,Marrina,Northstar,Puck,Sasquatch,Shaman,Snowbird'
      && mh5.filter((c) => c.team === 'MH5 Cat\'s Paw').length === 15 && mh5.find((c) => c.id === 'gary-cody-mh5')?.team === 'MH5 Cat\'s Paw'
      && mh5.some((c) => c.id === 'leader-mh5' && c.name === 'Leader') && !mh5.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh5.length} ${[...new Set(mh5.map((c) => c.team))]}`);
    const blk = (id, i = 0) => mh5.find((c) => c.id === id)?.versions[0].blocks[i];
    const ver = (id) => mh5.find((c) => c.id === id)?.versions[0];
    const played = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    const fixes = ['leader-mh5', 'constrictor-mh5', 'justin-hammer-mh5', 'marrina-mh5', 'northstar-mh5'].map((id) => {
      const o = blk(id)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${o?.printed}>${o?.corrected}${(o?.also || []).map((x) => ` +${x.verdict} ${x.field} ${x.printed}>${x.corrected}`).join('')} plays ${played(id)}`;
    });
    check('MH5: the five misprints keep the printed value and play the ranks\' (the Leader\'s Karma 125 as 120, the Constrictor\'s 26 as 24, Justin Hammer\'s Health 28 as 30 and Karma 26 as 36, Marrina\'s Health 80 as 90, Northstar\'s 90 as 70)',
      fixes.join(' | ') === [
        'leader-mh5 misprint karma 125>120 plays 56/120',
        'constrictor-mh5 misprint karma 26>24 plays 50/24',
        'justin-hammer-mh5 misprint health 28>30 +misprint karma 26>36 plays 30/36',
        'marrina-mh5 misprint health 80>90 plays 90/26',
        'northstar-mh5 misprint health 90>70 plays 70/22',
      ].join(' | ')
      && mh5.filter((c) => c.versions.some((v) => v.blocks.some((b) => b.override))).length === 5,
      fixes.join(' | '));
    check('MH5: Northstar\'s Resources, printed under a second Reason: label, keeps that label, and no other MH5 block carries one',
      JSON.stringify(blk('northstar-mh5')?.printed_labels) === '{"resources":"Reason"}' && blk('northstar-mh5')?.resources
      && mh5.filter((c) => c.versions.some((v) => v.blocks.some((b) => b.printed_labels))).map((c) => c.id).join() === 'northstar-mh5',
      JSON.stringify(blk('northstar-mh5')?.printed_labels));
    const lines = [['synthetic-hulk-mh5', 0], ['hammer-s-mercenaries-mh5', 0], ['improved-synthetic-hulks-mh5', 0], ['humanoids-mh5', 0], ['kimara-the-cloudstalker-mh5', 1]];
    check('MH5: of the five one-line grids only Hammer\'s Mercenaries print a Karma (14); the other four stay unset and none is derived',
      bookNpc({ character: 'hammer-s-mercenaries-mh5' }).snapshot?.karma === 14 && blk('hammer-s-mercenaries-mh5')?.karma === '14'
      && lines.filter((_, n) => n !== 1).every(([id, i]) => blk(id, i)?.karma === null && (i > 0 || bookNpc({ character: id }).snapshot?.karma === null))
      && lines.every(([id, i]) => blk(id, i)?.kind === 'line' && !blk(id, i).karma_derived),
      lines.map(([id, i]) => `${id} ${blk(id, i)?.kind} ${blk(id, i)?.karma}`).join(' | '));
    const kim = bookNpc({ character: 'kimara-the-cloudstalker-mh5' }).snapshot;
    check('MH5: Kimara\'s fully powered grid is a second form on her card (350 and 1300), and she and Hammer\'s Mercenaries write no prose row',
      kim?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Kimara, the Cloudstalker 350,Fully Powered 1300'
      && choices.filter((c) => c.character === 'kimara-the-cloudstalker-mh5').length === 1
      && ver('kimara-the-cloudstalker-mh5')?.text.join() === 'power' && ver('hammer-s-mercenaries-mh5')?.text.length === 0,
      `${JSON.stringify(kim?.forms?.map((f) => [f.name, f.health]))} ${ver('kimara-the-cloudstalker-mh5')?.text} ${ver('hammer-s-mercenaries-mh5')?.text}`);
    check('MH5: the Melter\'s settings are inside his one power, Melting Device, not powers of their own',
      ver('melter-mh5')?.powers.map((p) => p.name).join() === 'Melting Device', JSON.stringify(ver('melter-mh5')?.powers.map((p) => p.name)));
    check('MH5: a cover-panel card cites its panel with no page, and the Leader his Adventure page',
      tagline(bookNpc({ character: 'sasquatch-mh5' }).snapshot).startsWith('MH5 Cat\'s Paw, Inside front cover;')
      && tagline(bookNpc({ character: 'gary-cody-mh5' }).snapshot).startsWith('MH5 Cat\'s Paw, Inside back cover;')
      && tagline(bookNpc({ character: 'leader-mh5' }).snapshot).startsWith('MH5 Cat\'s Paw, Adventure p.12;'),
      tagline(bookNpc({ character: 'leader-mh5' }).snapshot));
    const ov5 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh5-overrides.json'), 'utf8')).overrides;
    const text5 = ov5.filter((o) => o.verdict === 'text');
    const breaks5 = ['leader-mh5:power:3', 'justin-hammer-mh5:powers-intro'].map((k) => `mh5:${k}`);
    check('MH5: nine overrides: the five misprints and four text verdicts (the improved synthetic Hulks\' margin pencil, Northstar\'s speck, and two line-end hyphen breaks, the Leader\'s Drain-Cannon and Justin Hammer\'s Man-Killer, whose printed fragment no longer reads the shape)',
      ov5.length === 9 && ov5.filter((o) => o.verdict === 'misprint').length === 5 && text5.length === 4
      && text5.slice(2).map((o) => o.match.row).join() === breaks5.join()
      && text5.slice(2).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed)),
      JSON.stringify(ov5.map((o) => [o.verdict, o.match])));
    // read the generated .sql in the cache, by keys and by the overrides' own
    // fragments, never a sentence of the book in this file.
    const sql5 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh5', 'book-text.sql');
    if (!existsSync(sql5)) {
      check(`MH5: skipped the text checks: no ${rel(sql5) || sql5}`, true);
    } else {
      const rows5 = [...readFileSync(sql5, 'utf8').matchAll(/VALUES \('([^']+)', 'mh5', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, , body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const count5 = (row, s) => (rows5.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts5 = text5.map((o) => `${o.match.row} ${count5(o.match.row, o.printed)}/${count5(o.match.row, o.read)}`);
      check('MH5 text: each of the four text verdicts is applied, its printed fragment once in its row and the misread gone',
        rows5.length > 0 && text5.length === 4 && verdicts5.every((v) => v.endsWith(' 1/0')), `${rows5.length} rows; ${verdicts5.join(' | ')}`);
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10f, Nate
      // 2026-11-03): MH5's two are closed up by the text verdicts above
      const shape5 = rows5.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('MH5 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        rows5.length > 0 && shape5.length === 0, shape5.join(' '));
    }
  }

  // MH6 is laid out as MH1-MH5 are (scripts/msh/coverpanels.py,
  // mh6-overrides.json), but its seven card panels cite alike (Inside cover),
  // its Adventure Book prints only one-line grids, most on a red pattern the
  // OCR cannot read (carried in the registry), and it prints no misprint.
  if (data.npcs.characters.some((c) => c.book === 'mh6')) {
    const mh6 = data.npcs.characters.filter((c) => c.book === 'mh6');
    const blocks6 = mh6.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blk6 = (id) => mh6.find((c) => c.id === id)?.versions[0].blocks[0];
    const panelIds = mh6.filter((c) => c.versions[0].part === 'Inside cover').map((c) => c.id);
    check('MH6: 30 characters under the book\'s title, each id ending -mh6, one block each: seven card panels and 23 Adventure Book opponents',
      mh6.length === 30 && mh6.every((c) => c.id.endsWith('-mh6') && c.team === 'MH6 Thunder Over Jotunheim' && c.versions.length === 1)
      && blocks6.length === 30 && panelIds.join() === 'thor-mh6,geirrodur-mh6,loki-mh6,rock-troll-mh6,executioner-mh6,storm-giant-mh6,ulik-mh6'
      && mh6.filter((c) => c.versions[0].part === 'Adventure').length === 23,
      `${mh6.length} ${panelIds}`);
    check('MH6: Thor (Inside cover 1) sorts before the Adventure Book and the other six panels after it',
      mh6[0].id === 'thor-mh6' && mh6[1].id === 'crystal-lion-mh6' && mh6.slice(24).map((c) => c.id).join() === panelIds.slice(1).join(),
      mh6.map((c) => c.id).join());
    const ov6 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh6-overrides.json'), 'utf8')).overrides;
    check('MH6: no block carries a misprint override, and the two overrides are text verdicts (the Executioner\'s Magical Axe speck, and Loki\'s line-end break of All-Father, whose printed fragment no longer reads the shape)',
      blocks6.every(({ b }) => !b.override) && ov6.length === 2 && ov6.every((o) => o.verdict === 'text')
      && ov6.map((o) => o.match.row).join() === 'mh6:executioner-mh6:power:4,mh6:loki-mh6:background'
      && /[a-z]- [A-Za-z]/.test(ov6[1].read) && !/[a-z]- [A-Za-z]/.test(ov6[1].printed),
      JSON.stringify(ov6.map((o) => [o.verdict, o.match])));
    // read the generated .sql in the cache, by keys and by the overrides' own
    // fragments, never a sentence of the book in this file.
    const sql6 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh6', 'book-text.sql');
    if (!existsSync(sql6)) {
      check(`MH6: skipped the text checks: no ${rel(sql6) || sql6}`, true);
    } else {
      const rows6 = [...readFileSync(sql6, 'utf8').matchAll(/VALUES \('([^']+)', 'mh6', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, , body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const count6 = (row, s) => (rows6.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts6 = ov6.map((o) => `${o.match.row} ${count6(o.match.row, o.printed)}/${count6(o.match.row, o.read)}`);
      check('MH6 text: each of the two text verdicts is applied, its printed fragment once in its row and the misread gone',
        rows6.length > 0 && ov6.length === 2 && verdicts6.every((v) => v.endsWith(' 1/0')), `${rows6.length} rows; ${verdicts6.join(' | ')}`);
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10g, Nate
      // 2026-11-03): MH6's one is closed up by Loki's text verdict above
      const shape6 = rows6.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('MH6 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        rows6.length > 0 && shape6.length === 0, shape6.join(' '));
    }
    const carried = blocks6.filter(({ b }) => b.carried);
    check('MH6: 22 of the 23 one-line grids are carried in the registry, Flame Wing\'s read off the page, and no panel is carried',
      carried.length === 22 && carried.every(({ b }) => b.kind === 'line')
      && blocks6.filter(({ b }) => b.kind === 'line').length === 23 && !blk6('flame-wing-mh6')?.carried
      && !carried.some(({ id }) => panelIds.includes(id)),
      `${carried.length} ${blocks6.filter(({ b }) => b.kind === 'line' && !b.carried).map(({ id }) => id)}`);
    check('MH6: Ulik\'s Popularity (20) is the one value read off the image, and plays',
      JSON.stringify(blk6('ulik-mh6')?.read_off_image) === '["popularity"]' && blk6('ulik-mh6')?.popularity === '20'
      && bookNpc({ character: 'ulik-mh6' }).snapshot?.abilities.popularity.number === 20
      && blocks6.filter(({ b }) => b.read_off_image).length === 1,
      JSON.stringify(blocks6.filter(({ b }) => b.read_off_image).map(({ id, b }) => [id, b.read_off_image])));
    const book6 = data.npcs.books.find((b) => b.slug === 'mh6');
    check('MH6: the book reads Adventure 3-15 and Inside cover once, a panel card cites the panel with no page and an opponent its page',
      JSON.stringify([book6?.part, book6?.pages, book6?.panels]) === '["Adventure",[3,15],["Inside cover"]]'
      && tagline(bookNpc({ character: 'thor-mh6' }).snapshot).startsWith('MH6 Thunder Over Jotunheim, Inside cover;')
      && tagline(bookNpc({ character: 'crystal-lion-mh6' }).snapshot).startsWith('MH6 Thunder Over Jotunheim, Adventure p.3;')
      && tagline(bookNpc({ character: 'granite-guardian-mh6' }).snapshot).startsWith('MH6 Thunder Over Jotunheim, Adventure p.15;'),
      `${JSON.stringify(book6)} ${tagline(bookNpc({ character: 'thor-mh6' }).snapshot)}`);
    check('MH6: the four panels with a full grid play their printed Health and Karma (Thor 320/76, Loki 150/115, the Executioner 245/36, Ulik 285/50)',
      ['thor-mh6', 'loki-mh6', 'executioner-mh6', 'ulik-mh6'].map((id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; }).join()
        === '320/76,150/115,245/36,285/50');
  }

  // MH7 is laid out as MH1-MH6 are (scripts/msh/coverpanels.py,
  // mh7-overrides.json), with the survey's decisions applied as it recommends
  // (mh7.md; Nate 2026-10-29). Its registry entry carries eight fixes the
  // reader does not stop without (runin_heads, faint_rules, drop_corner and
  // speck_lines: roster.py exits 0 with each turned off, and different data),
  // so each is pinned here by what it changes.
  if (data.npcs.characters.some((c) => c.book === 'mh7')) {
    const mh7 = data.npcs.characters.filter((c) => c.book === 'mh7');
    const blocks7 = mh7.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blk7 = (id) => mh7.find((c) => c.id === id)?.versions[0].blocks[0];
    const ver7 = (id) => mh7.find((c) => c.id === id)?.versions[0];
    const powers7 = (id) => ver7(id)?.powers.map((p) => p.name).join();
    const team7 = (t) => mh7.filter((c) => c.team === t).map((c) => c.name).sort().join();
    check('MH7: 14 characters, each id ending -mh7 with one block, five as West Coast Avengers and the rest (Rick Jones too) under the book\'s title, and no name starting The',
      mh7.length === 14 && mh7.every((c) => c.id.endsWith('-mh7') && c.versions.length === 1) && blocks7.length === 14
      && team7('West Coast Avengers') === 'Hawkeye,Iron Man,Mockingbird,Tigra,Wonder Man'
      && mh7.filter((c) => c.team === 'MH7 The Last Resort').length === 9 && mh7.find((c) => c.id === 'rick-jones-mh7')?.team === 'MH7 The Last Resort'
      && !mh7.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh7.length} ${[...new Set(mh7.map((c) => c.team))]}`);
    check('MH7: the inside front cover\'s two cards sort first, then the Adventure Book by page, then the inside back cover\'s two',
      mh7.map((c) => c.id).join() === ['hawkeye', 'tigra', 'blizzard', 'mesmerized-scouts', 'rick-jones', 'fire-creatures', 'plantman', 'pyro',
        'radioactive-man', 'whirlwind', 'mandarin', 'iron-man', 'mockingbird', 'wonder-man'].map((id) => `${id}-mh7`).join(),
      mh7.map((c) => c.id).join());
    const ov7 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh7-overrides.json'), 'utf8')).overrides;
    const fire = blk7('fire-creatures-mh7');
    check('MH7: no misprint; the two overrides are the Fire Creatures\' rows (a dash under R, I and P), theirs the only block that carries one, and Rick Jones\' line-end break of Mar-Vell, a text verdict whose printed fragment no longer reads the shape',
      ov7.length === 2 && ov7[0].verdict === 'rows' && !ov7.some((o) => o.verdict === 'misprint')
      && ov7[1].verdict === 'text' && ov7[1].match.row === 'mh7:rick-jones-mh7:background'
      && /[a-z]- [A-Za-z]/.test(ov7[1].read) && !/[a-z]- [A-Za-z]/.test(ov7[1].printed)
      && fire?.override?.verdict === 'rows' && fire.override.field === 'RIP'
      && blocks7.filter(({ b }) => b.override).map(({ id }) => id).join() === 'fire-creatures-mh7',
      JSON.stringify(ov7.map((o) => [o.verdict, o.match])));
    check('MH7: the Fire Creatures are a partial grid on a card of their own (p.13), R, I and P unset, Health 160 on four In, prose only, and not offered to the GM',
      fire?.kind === 'partial' && fire.abilities.map((a) => a.slice(1).join(' ')).join() === '40 In,40 In,40 In,40 In, , , '
      && fire.health === '160' && fire.karma === null && ver7('fire-creatures-mh7').pages.join() === '13'
      && ver7('fire-creatures-mh7').text.join() === 'prose' && !choices.some((c) => c.character === 'fire-creatures-mh7'),
      `${fire?.kind} ${JSON.stringify(fire?.abilities)} ${fire?.health} ${ver7('fire-creatures-mh7')?.text}`);
    check('MH7: Pyro\'s card keeps its three powers with the Fire Creatures\' grid cut out of it (cut_grids)',
      powers7('pyro-mh7') === 'Fire Control,Fire Resistance,Fire Generation', powers7('pyro-mh7'));
    check('MH7: Hawkeye\'s MARKSMAN, BOW is a power of its own (runin_heads), not the end of Poor Hearing',
      powers7('hawkeye-mh7') === 'Extraordinary Vision,Poor Hearing,Marksman, Bow', powers7('hawkeye-mh7'));
    check('MH7: the Mandarin\'s four powers, and no Amplification: the Mento Intensifier\'s column is not his (drop_corner)',
      powers7('mandarin-mh7') === 'Hard Hitting,Force Field,Holo-Belt,Makluan Rings', powers7('mandarin-mh7'));
    const gear7 = ['Arrows', 'Talisman', 'Plant Psi-Field Projector', 'Protective Suit', 'Battle Stave', 'Avengers Transceiver'];
    check('MH7: the five cards that print Equipment/Possessions carry it as text, and none of their seven gear rows is a power (Wonder Man\'s Flight among them)',
      mh7.filter((c) => c.versions[0].text.includes('equipment')).map((c) => c.id).sort().join()
        === 'hawkeye-mh7,mockingbird-mh7,plantman-mh7,tigra-mh7,wonder-man-mh7'
      && !mh7.some((c) => c.versions[0].powers.some((p) => gear7.includes(p.name)))
      && powers7('wonder-man-mh7') === 'Body Armor,Environmental Independence',
      mh7.filter((c) => c.versions[0].text.includes('equipment')).map((c) => c.id).join());
    const marks = mh7.flatMap((c) => [c.name, ...c.versions[0].powers.map((p) => p.name)]).filter((s) => !/^[A-Za-z][A-Za-z ,-]*$/.test(s));
    check('MH7: every name and power name is letters, spaces, commas and hyphens: no speck read as a mark (Iron Man\'s header, speck_lines)',
      marks.length === 0 && mh7.find((c) => c.id === 'iron-man-mh7')?.name === 'Iron Man', JSON.stringify(marks));
    check('MH7: 48 powers, 11 of them linked to the UPB',
      mh7.flatMap((c) => c.versions[0].powers).length === 48 && mh7.flatMap((c) => c.versions[0].powers).filter((p) => p.upb).length === 11);
    const book7 = data.npcs.books.find((b) => b.slug === 'mh7');
    check('MH7: the book reads Adventure 12-16 and both inside covers, a panel card cites its panel with no page and an Adventure card its page',
      JSON.stringify([book7?.part, book7?.pages, book7?.panels]) === '["Adventure",[12,16],["Inside front cover","Inside back cover"]]'
      && tagline(bookNpc({ character: 'hawkeye-mh7' }).snapshot).startsWith('MH7 The Last Resort, Inside front cover;')
      && tagline(bookNpc({ character: 'mockingbird-mh7' }).snapshot).startsWith('MH7 The Last Resort, Inside back cover;')
      && tagline(bookNpc({ character: 'rick-jones-mh7' }).snapshot).startsWith('MH7 The Last Resort, Adventure p.12;')
      && tagline(bookNpc({ character: 'iron-man-mh7' }).snapshot).startsWith('MH7 The Last Resort, Adventure p.16;'),
      `${JSON.stringify(book7)} ${tagline(bookNpc({ character: 'iron-man-mh7' }).snapshot)}`);
    check('MH7: cards play their printed Health and Karma (Hawkeye 70/22, Tigra 130/56, Iron Man 155/36, Wonder Man 215/18), and Pyro his Popularity -10',
      ['hawkeye-mh7', 'tigra-mh7', 'iron-man-mh7', 'wonder-man-mh7'].map((id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; }).join()
        === '70/22,130/56,155/36,215/18' && bookNpc({ character: 'pyro-mh7' }).snapshot?.abilities.popularity.number === -10);
    // The rest of the eight fixes move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys, lengths
    // and marks, never a word of it.
    const sql7 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh7', 'book-text.sql');
    if (!existsSync(sql7)) {
      check(`MH7: skipped the text checks: no ${rel(sql7) || sql7}`, true);
    } else {
      const rows7 = [...readFileSync(sql7, 'utf8').matchAll(/VALUES \('([^']+)', 'mh7', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const len7 = (key) => rows7.find((r) => r.key === key)?.body.length || 0;
      check('MH7 text: 73 rows over 14 entries, the Fire Creatures\' one, and no Amplification row',
        rows7.length === 73 && new Set(rows7.map((r) => r.key.split(':')[1])).size === 14
        && rows7.some((r) => r.key === 'mh7:fire-creatures-mh7:prose') && !rows7.some((r) => /amplification/i.test(r.name)),
        `${rows7.length} ${new Set(rows7.map((r) => r.key.split(':')[1])).size}`);
      check('MH7 text: Rick Jones\' background is longer than the Mesmerized Scouts\' (faint_rules: without it the end of his lands in theirs)',
        len7('mh7:rick-jones-mh7:background') > len7('mh7:mesmerized-scouts-mh7:background') && len7('mh7:mesmerized-scouts-mh7:background') > 0,
        `${len7('mh7:rick-jones-mh7:background')} ${len7('mh7:mesmerized-scouts-mh7:background')}`);
      const specks = rows7.filter((r) => /['"]/.test(r.name) || /_|\.\s+\.|[a-z]- [a-z]/.test(r.body)).map((r) => r.key);
      check('MH7 text: no speck read as a mark (speck_lines): no underscore, no doubled full stop, no word split at a hyphen, no quote in a power or gear name',
        specks.length === 0, specks.join());
      const count7 = (row, s) => (rows7.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts7 = ov7.filter((o) => o.verdict === 'text').map((o) => `${o.match.row} ${count7(o.match.row, o.printed)}/${count7(o.match.row, o.read)}`);
      check('MH7 text: the one text verdict is applied, its printed fragment once in its row and the misread gone',
        verdicts7.length === 1 && verdicts7.every((v) => v.endsWith(' 1/0')), verdicts7.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10h, Nate
      // 2026-11-03): MH7's one is closed up by Rick Jones' text verdict above
      const shape7 = rows7.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('MH7 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        rows7.length > 0 && shape7.length === 0, shape7.join(' '));
    }
  }

  // MH8 is laid out as MH1-MH7 are (scripts/msh/coverpanels.py,
  // mh8-overrides.json), with the survey's decisions applied as it recommends
  // (mh8.md; Nate 2026-10-29). Every card is in the Adventure Book (printed
  // 12-16) and none on a cover panel. The registry's runin_heads,
  // identity_to_block and card_names each change what is built, so each is
  // pinned here by what it changes.
  if (data.npcs.characters.some((c) => c.book === 'mh8')) {
    const mh8 = data.npcs.characters.filter((c) => c.book === 'mh8');
    const blocks8 = mh8.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blk8 = (id) => mh8.find((c) => c.id === id)?.versions[0].blocks[0];
    const ver8 = (id) => mh8.find((c) => c.id === id)?.versions[0];
    const powers8 = (id) => ver8(id)?.powers.map((p) => p.name).join();
    const team8 = (t) => mh8.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const played8 = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MH8: 16 characters, each id ending -mh8 with one block, three as Avengers and the rest (Spider-Man too) under the book\'s title, and no name starting The',
      mh8.length === 16 && mh8.every((c) => c.id.endsWith('-mh8') && c.versions.length === 1) && blocks8.length === 16
      && team8('Avengers') === 'Black Knight,Captain America,Wasp'
      && mh8.filter((c) => c.team === 'MH8 Fault Line').length === 13 && mh8.find((c) => c.id === 'spider-man-mh8')?.team === 'MH8 Fault Line'
      && !mh8.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh8.length} ${[...new Set(mh8.map((c) => c.team))]}`);
    check('MH8: the cards sort by Adventure page, 12 to 16, the Crooks\' two cards on p.14',
      mh8.map((c) => c.id).join() === ['grim-reaper', 'mastermind', 'thunderball', 'juggernaut', 'living-laser', 'swordsman', 'frankie-the-snitch',
        'hoods', 'joseph-merrir', 'punks', 'black-knight', 'captain-america', 'spider-man', 'police', 'swat-team-member', 'wasp'].map((id) => `${id}-mh8`).join(),
      mh8.map((c) => c.id).join());
    const fixes8 = ['living-laser-mh8', 'juggernaut-mh8', 'punks-mh8', 'hoods-mh8'].map((id) => {
      const o = blk8(id)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${o?.printed}>${o?.corrected} block ${blk8(id)?.karma} plays ${played8(id)}`;
    });
    check('MH8: the four misprints keep the printed Karma and play the ranks\' (the Living Laser 32 as 18, the Juggernaut 30 as 20, the Crooks\' welded 1216 as the Punks\' 12 and the Hoods\' 16), and no other block carries an override',
      fixes8.join(' | ') === [
        'living-laser-mh8 misprint karma 32>18 block 32 plays 50/18',
        'juggernaut-mh8 misprint karma 30>20 block 30 plays 234/20',
        'punks-mh8 misprint karma 1216>12 block 1216 plays 28/12',
        'hoods-mh8 misprint karma 1216>16 block null plays 50/16',
      ].join(' | ')
      && blocks8.filter(({ b }) => b.override).length === 4,
      fixes8.join(' | '));
    const ov8 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh8-overrides.json'), 'utf8')).overrides;
    const text8 = ov8.filter((o) => o.verdict === 'text');
    check('MH8: six text verdicts, the Juggernaut\'s notes one, the Wasp\'s Flight two and the SWAT Team Member\'s notes three, and no other verdict but the four misprints',
      text8.map((o) => o.match.row).join() === ['juggernaut-mh8:notes', 'wasp-mh8:power:2', 'wasp-mh8:power:2',
        'swat-team-member-mh8:notes', 'swat-team-member-mh8:notes', 'swat-team-member-mh8:notes'].map((k) => `mh8:${k}`).join()
      && ov8.length === 10 && ov8.filter((o) => o.verdict === 'misprint').length === 4,
      JSON.stringify(ov8.map((o) => [o.verdict, o.match])));
    check('MH8: the Police and the SWAT Team Member print no Karma and play none, and the Hoods\' Popularity, printed as a rank word, plays no number',
      played8('police-mh8') === '36/null' && played8('swat-team-member-mh8') === '50/null'
      && blk8('police-mh8')?.karma === null && blk8('swat-team-member-mh8')?.karma === null
      && blk8('hoods-mh8')?.popularity === 'TYPICAL' && bookNpc({ character: 'hoods-mh8' }).snapshot?.abilities.popularity.number === null,
      `${played8('police-mh8')} ${played8('swat-team-member-mh8')} ${blk8('hoods-mh8')?.popularity}`);
    check('MH8: Spider-Man\'s SPIDER-SENSE is a power of its own (runin_heads), not the end of Wall-Crawling',
      powers8('spider-man-mh8') === 'Wall-Crawling,Spider-Sense,Web-Shooters,Spider Tracers,Spider Beacon', powers8('spider-man-mh8'));
    check('MH8: Mastermind\'s and the Wasp\'s identities are two lines each, joined where the page wraps them (identity_to_block), and neither card has a prose row',
      ver8('mastermind-mh8')?.identity.length === 2 && ver8('wasp-mh8')?.identity.length === 2
      && ver8('mastermind-mh8').identity[0] === 'Jason Wyngarde'
      && !ver8('mastermind-mh8').text.includes('prose') && !ver8('wasp-mh8').text.includes('prose'),
      `${JSON.stringify(ver8('mastermind-mh8')?.identity)} ${JSON.stringify(ver8('wasp-mh8')?.identity)} ${ver8('mastermind-mh8')?.text} ${ver8('wasp-mh8')?.text}`);
    check('MH8: the SWAT Team Member is named with SWAT in capitals, as printed (card_names)',
      mh8.find((c) => c.id === 'swat-team-member-mh8')?.name === 'SWAT Team Member', mh8.find((c) => c.id === 'swat-team-member-mh8')?.name);
    check('MH8: 28 powers, 9 of them linked to the UPB',
      mh8.flatMap((c) => c.versions[0].powers).length === 28 && mh8.flatMap((c) => c.versions[0].powers).filter((p) => p.upb).length === 9);
    const book8 = data.npcs.books.find((b) => b.slug === 'mh8');
    check('MH8: the book reads Adventure 12-16 and no cover panel, and a card cites its Adventure page',
      JSON.stringify([book8?.part, book8?.pages, book8?.panels]) === '["Adventure",[12,16],[]]'
      && tagline(bookNpc({ character: 'grim-reaper-mh8' }).snapshot).startsWith('MH8 Fault Line, Adventure p.12;')
      && tagline(bookNpc({ character: 'wasp-mh8' }).snapshot).startsWith('MH8 Fault Line, Adventure p.16;')
      && mh8.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(book8)} ${tagline(bookNpc({ character: 'wasp-mh8' }).snapshot)}`);
    check('MH8: cards play their printed Health and Karma (the Grim Reaper 36/18, Mastermind 44/120, Captain America 140/60, Spider-Man 160/110), and the Juggernaut his Popularity -30',
      ['grim-reaper-mh8', 'mastermind-mh8', 'captain-america-mh8', 'spider-man-mh8'].map(played8).join() === '36/18,44/120,140/60,160/110'
      && bookNpc({ character: 'juggernaut-mh8' }).snapshot?.abilities.popularity.number === -30);
    // The text verdicts move only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by the overrides'
    // own fragments, never a word of the book in this file.
    const sql8 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh8', 'book-text.sql');
    if (!existsSync(sql8)) {
      check(`MH8: skipped the text checks: no ${rel(sql8) || sql8}`, true);
    } else {
      const rows8 = [...readFileSync(sql8, 'utf8').matchAll(/VALUES \('([^']+)', 'mh8', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      check('MH8 text: 58 rows over 16 entries, Spider-Sense\'s among them, and no row with an odd count of double quotes',
        rows8.length === 58 && new Set(rows8.map((r) => r.key.split(':')[1])).size === 16
        && rows8.find((r) => r.key === 'mh8:spider-man-mh8:power:2')?.name === 'Spider-Sense'
        && !rows8.some((r) => (r.body.match(/"/g) || []).length % 2),
        `${rows8.length} ${new Set(rows8.map((r) => r.key.split(':')[1])).size}`);
      const count8 = (row, s) => (rows8.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts8 = text8.map((o) => `${o.match.row} ${count8(o.match.row, o.printed)}/${count8(o.match.row, o.read)}`);
      check('MH8 text: each of the six text verdicts is applied, its printed fragment once in its row and the misread gone',
        text8.length === 6 && verdicts8.every((v) => v.endsWith(' 1/0')), verdicts8.join(' | '));
    }
  }

  // MH9 is laid out as MH1-MH8 are (scripts/msh/coverpanels.py,
  // mh9-overrides.json), with the survey's decisions applied as it recommends
  // (mh9.md; Nate 2026-10-29). Every card is in the Adventure Book (printed
  // 4-40) and none on a cover panel. The registry's prefer_text and
  // speck_lines each change what is built, so each is pinned here by what it
  // changes.
  if (data.npcs.characters.some((c) => c.book === 'mh9')) {
    const mh9 = data.npcs.characters.filter((c) => c.book === 'mh9');
    const blocks9 = mh9.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blk9 = (id) => data.npcs.characters.find((c) => c.id === id)?.versions[0].blocks[0];
    const ver9 = (id) => mh9.find((c) => c.id === id)?.versions[0];
    const team9 = (t) => mh9.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const played9 = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MH9: 45 characters, each id ending -mh9 with one block, five as Fantastic Four, three as Avengers and the rest (Spider-Man too) under the book\'s title, and no name starting The',
      mh9.length === 45 && mh9.every((c) => c.id.endsWith('-mh9') && c.versions.length === 1) && blocks9.length === 45
      && team9('Fantastic Four') === 'Human Torch (Johnny Storm),Invisible Woman,Mister Fantastic,She-Hulk,Thing'
      && team9('Avengers') === 'Captain America (Steve Rogers),Sub-Mariner,Wasp (Janet Van Dyne)'
      && mh9.filter((c) => c.team === 'MH9 Gates of What If').length === 37 && mh9.find((c) => c.id === 'spider-man-mh9')?.team === 'MH9 Gates of What If'
      && !mh9.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mh9.length} ${[...new Set(mh9.map((c) => c.team))]}`);
    check('MH9: the cards sort by the Adventure page each starts on, 4 to 39, and each name the book prints more than once (three Captain Americas, two Human Torches, two Things, two Wasps) a card of its own',
      mh9.map((c) => c.id).join() === ['a-i-m-soldiers', 'golden-robots', 'demons', 'a-i-m-gunmen', 'guardsmen-robots', 'a-i-m-scientists',
        'a-i-m-technicians', 'geoff-krubb', 'super-adaptoid', 'swordsman', 'attuma', 'klaw', 'sound-objects', 'wasp-janet-pym',
        'captain-america-jeffrey-mace', 'skrulls', 'super-skrull', 'henry-pym', 'nick-fury', 'captain-america-jack-monroe', 'hercules',
        'hulk', 'mad-thinker', 'mad-thinker-s-androids', 'scarlet-witch', 'victor', 'mephisto', 'valor', 'thing-divergent-earth', 'crystal',
        'daredevil', 'human-torch-jim-hammond', 'hawkeye', 'quicksilver', 'flare', 'nomad', 'invisible-woman', 'mister-fantastic',
        'she-hulk', 'human-torch-johnny-storm', 'thing', 'wasp-janet-van-dyne', 'captain-america-steve-rogers', 'spider-man',
        'sub-mariner'].map((id) => `${id}-mh9`).join(),
      mh9.map((c) => c.id).join());
    check('MH9: ten one-line grids (the A.I.M. Soldiers\' printed twice is one card), one partial grid and 34 full blocks',
      blocks9.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === ['a-i-m-soldiers', 'golden-robots', 'demons', 'a-i-m-gunmen',
        'guardsmen-robots', 'a-i-m-technicians', 'geoff-krubb', 'sound-objects', 'skrulls', 'mad-thinker-s-androids'].map((id) => `${id}-mh9`).join()
      && blocks9.filter(({ b }) => b.kind === 'partial').map(({ id }) => id).join() === 'a-i-m-scientists-mh9'
      && blocks9.filter(({ b }) => !b.kind).length === 34,
      blocks9.map(({ id, b }) => `${id}:${b.kind}`).join());
    const fixes9 = ['captain-america-jeffrey-mace-mh9', 'henry-pym-mh9', 'valor-mh9', 'super-adaptoid-mh9'].map((id) => {
      const o = blk9(id)?.override;
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${a.printed}>${a.corrected}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${o?.printed}${o?.corrected === undefined ? '' : `>${o.corrected}`}${also} block ${blk9(id)?.health}/${blk9(id)?.karma} plays ${played9(id)}`;
    });
    check('MH9: the three misprints keep the printed value and play the ranks\' (Captain America (Jeffrey Mace) Karma 36 as 26, Henry Pym Health 70 as 28 and Karma 36 as 46, Valor Karma 32 as 22), and the Super-Adaptoid\'s Health 150 is kept as printed and plays',
      fixes9.join(' | ') === [
        'captain-america-jeffrey-mace-mh9 misprint karma 36>26 block 36/36 plays 36/26',
        'henry-pym-mh9 misprint health 70>28 also misprint karma 36>46 block 70/36 plays 28/46',
        'valor-mh9 misprint karma 32>22 block 100/32 plays 100/22',
        'super-adaptoid-mh9 as_printed health 150 block 150 (see below)/18 plays 150/18',
      ].join(' | '),
      fixes9.join(' | '));
    const ov9 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mh9-overrides.json'), 'utf8')).overrides;
    const text9 = ov9.filter((o) => o.verdict === 'text');
    check('MH9: twenty-six overrides: three misprints, one as printed, the A.I.M. Scientists\' rows and twenty-one text verdicts (the A.I.M. Technicians\' prose one, Captain America (Jeffrey Mace)\'s background two, the Thing (Divergent Earth)\'s background one, Hawkeye\'s equipment one, Flare\'s four Sound/light Conversion bullets, and twelve line-end hyphen breaks: the Super-Adaptoid\'s Adaptation two and background three, Attuma\'s, Henry Pym\'s, Daredevil\'s Heightened Senses, the Human Torch (Jim Hammond)\'s, Nomad\'s two and She-Hulk\'s), and only those five blocks carry one',
      ov9.length === 26 && ov9.filter((o) => o.verdict === 'misprint').length === 3 && ov9.filter((o) => o.verdict === 'as_printed').length === 1
      && ov9.filter((o) => o.verdict === 'rows').length === 1
      && text9.map((o) => o.match.row).join() === ['a-i-m-technicians-mh9:prose', 'captain-america-jeffrey-mace-mh9:background',
        'captain-america-jeffrey-mace-mh9:background', 'thing-divergent-earth-mh9:background', 'hawkeye-mh9:equipment',
        'flare-mh9:power:1', 'flare-mh9:power:1', 'flare-mh9:power:1', 'flare-mh9:power:1',
        'super-adaptoid-mh9:power:1', 'super-adaptoid-mh9:power:1', 'super-adaptoid-mh9:background', 'super-adaptoid-mh9:background',
        'super-adaptoid-mh9:background', 'attuma-mh9:background', 'henry-pym-mh9:background', 'daredevil-mh9:power:1',
        'human-torch-jim-hammond-mh9:background', 'nomad-mh9:background', 'nomad-mh9:background', 'she-hulk-mh9:background'].map((k) => `mh9:${k}`).join()
      && text9.slice(9).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && blocks9.filter(({ b }) => b.override).map(({ id }) => id).sort().join()
        === 'a-i-m-scientists-mh9,captain-america-jeffrey-mace-mh9,henry-pym-mh9,super-adaptoid-mh9,valor-mh9',
      JSON.stringify(ov9.map((o) => [o.verdict, o.match])));
    const sci = blk9('a-i-m-scientists-mh9');
    check('MH9: the A.I.M. Scientists are a partial grid (Var under Reason and Intuition), R and I unset, Health 24 on four Ty, Karma Variable, and not offered to the GM',
      sci?.kind === 'partial' && sci.override?.verdict === 'rows' && sci.override.field === 'RI'
      && sci.abilities.map((a) => a.slice(1).join(' ')).join() === '6 Ty,6 Ty,6 Ty,6 Ty, , ,6 Ty'
      && sci.health === '24' && sci.karma === 'Variable' && !choices.some((c) => c.character === 'a-i-m-scientists-mh9'),
      `${sci?.kind} ${JSON.stringify(sci?.abilities)} ${sci?.health} ${sci?.karma}`);
    check('MH9: the Golden Robots and the Guardsmen Robots print Karma None and play none',
      blk9('golden-robots-mh9')?.karma === 'None' && blk9('guardsmen-robots-mh9')?.karma === 'None'
      && played9('golden-robots-mh9') === '155/null' && played9('guardsmen-robots-mh9') === '120/null'
      && blocks9.filter(({ b }) => b.karma === 'None').length === 2,
      `${played9('golden-robots-mh9')} ${played9('guardsmen-robots-mh9')}`);
    const read9 = ['swordsman-mh9', 'klaw-mh9'].map((id) => `${id} ${blk9(id)?.resources} / ${blk9(id)?.popularity}`).join(' | ');
    check('MH9: the Swordsman\'s Popularity -5 and both lines of his Resources, and Klaw\'s Popularity -2, as printed and not as their blocks\' crops read them (registry prefer_text)',
      blk9('swordsman-mh9')?.popularity === '-5' && blk9('swordsman-mh9')?.resources === 'Amazing (backed by A.I.M. and Mephisto)'
      && blk9('klaw-mh9')?.popularity === '-2', read9);
    check('MH9: the Super-Adaptoid\'s, Nick Fury\'s and the Mad Thinker\'s first identity lines as printed, no bar or digit for an I and no portrait speck (speck_lines)',
      ver9('super-adaptoid-mh9')?.identity[0] === 'A.I.M. criminal android'
      && ver9('nick-fury-mh9')?.identity[0] === 'Executive director of S.H.I.E.L.D.'
      && ver9('mad-thinker-mh9')?.identity[0] === 'Real name unknown',
      ['super-adaptoid-mh9', 'nick-fury-mh9', 'mad-thinker-mh9'].map((id) => ver9(id)?.identity[0]).join(' | '));
    check('MH9: 94 powers, 26 of them linked to the UPB',
      mh9.flatMap((c) => c.versions[0].powers).length === 94 && mh9.flatMap((c) => c.versions[0].powers).filter((p) => p.upb).length === 26);
    const book9 = data.npcs.books.find((b) => b.slug === 'mh9');
    check('MH9: the book reads Adventure 4-40 and no cover panel, and a card cites its Adventure page',
      JSON.stringify([book9?.part, book9?.pages, book9?.panels]) === '["Adventure",[4,40],[]]'
      && tagline(bookNpc({ character: 'a-i-m-soldiers-mh9' }).snapshot).startsWith('MH9 Gates of What If, Adventure p.4;')
      && tagline(bookNpc({ character: 'sub-mariner-mh9' }).snapshot).startsWith('MH9 Gates of What If, Adventure p.39;')
      && mh9.filter((c) => c.id !== 'a-i-m-scientists-mh9').every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(book9)} ${tagline(bookNpc({ character: 'sub-mariner-mh9' }).snapshot)}`);
    check('MH9: cards play their printed Health and Karma (Mephisto 1225/250, Victor 120/140, Captain America (Steve Rogers) 140/60, Spider-Man 160/110), and Mephisto his Popularity -100',
      ['mephisto-mh9', 'victor-mh9', 'captain-america-steve-rogers-mh9', 'spider-man-mh9'].map(played9).join() === '1225/250,120/140,140/60,160/110'
      && bookNpc({ character: 'mephisto-mh9' }).snapshot?.abilities.popularity.number === -100);
    // The text verdicts move only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by the overrides'
    // own fragments, never a word of the book in this file.
    const sql9 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mh9', 'book-text.sql');
    if (!existsSync(sql9)) {
      check(`MH9: skipped the text checks: no ${rel(sql9) || sql9}`, true);
    } else {
      const rows9 = [...readFileSync(sql9, 'utf8').matchAll(/VALUES \('([^']+)', 'mh9', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const odd9 = rows9.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key);
      check('MH9 text: 190 rows over 43 entries (the Sound Objects and the Mad Thinker\'s Androids print none), and the only rows with an odd count of double quotes are the five whose one mark is an inch mark after a figure',
        rows9.length === 190 && new Set(rows9.map((r) => r.key.split(':')[1])).size === 43
        && odd9.join() === ['wasp-janet-pym-mh9:power:1', 'henry-pym-mh9:power:1', 'hawkeye-mh9:equipment',
          'wasp-janet-van-dyne-mh9:power:1', 'wasp-janet-van-dyne-mh9:power:2'].map((k) => `mh9:${k}`).join()
        && odd9.every((k) => /^[^"]*\d" [^"]*$/.test(rows9.find((r) => r.key === k).body)),
        `${rows9.length} ${new Set(rows9.map((r) => r.key.split(':')[1])).size} ${odd9.join()}`);
      const count9 = (row, s) => (rows9.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts9 = text9.map((o) => `${o.match.row} ${count9(o.match.row, o.printed)}/${count9(o.match.row, o.read)}`);
      check('MH9 text: each of the twenty-one text verdicts is applied, its printed fragment once in its row and the misread gone',
        text9.length === 21 && verdicts9.every((v) => v.endsWith(' 1/0')), verdicts9.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10j, Nate
      // 2026-11-03): MH9's twelve are closed up by the text verdicts above.
      // The one left is Daredevil's Heightened Senses, a suspended hyphen the
      // page prints mid-line with its space ("hearing- and scent-related").
      const shape9 = rows9.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.slice(4))).sort();
      check('MH9 text: no row reads a letter, a hyphen and a space before a word but the one kept on purpose (Daredevil\'s suspended hyphen)',
        rows9.length > 0 && shape9.join() === 'daredevil-mh9:power:1', shape9.join(' '));
    }
  }

  // MX1 is read by scripts/msh/gridbooks.py (mx1-overrides.json), with the
  // survey's decisions applied as it recommends (mx1.md; Nate 2026-10-30).
  // Every card is in the Adventure Book (printed 9-14, 24-25 and 28), filed
  // under the book's title. The registry's card_names, speck_lines and
  // talents_end each change what is built, so each is pinned here by what it
  // changes.
  if (data.npcs.characters.some((c) => c.book === 'mx1')) {
    const mx1 = data.npcs.characters.filter((c) => c.book === 'mx1');
    const blocksX = mx1.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blkX = (id) => mx1.find((c) => c.id === id)?.versions[0].blocks[0];
    const playedX = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MX1: 17 characters, each id ending -mx1 with one version and one block, all filed under the book\'s title, and no name starting The',
      mx1.length === 17 && mx1.every((c) => c.id.endsWith('-mx1') && c.versions.length === 1 && c.versions[0].blocks.length === 1)
      && mx1.every((c) => c.team === 'MX1 Nightmares of Futures Past') && !mx1.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mx1.length} ${[...new Set(mx1.map((c) => c.team))]}`);
    check('MX1: the cards sort by the Adventure page each starts on, 9 to 28, the six sentinels first',
      mx1.map((c) => c.id).join() === ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'alpha-sentinel', 'nimrod', 'omega-sentinel',
        'blue', 'mantinels', 'swat-am', 'typical-policeman', 'gerald-gage', 'timbre-morava', 'arthur-faber', 'bernard-carns', 'big-foot',
        'oliver-pierce', 'typical-rogue'].map((id) => `${id}-mx1`).join(),
      mx1.map((c) => c.id).join());
    check('MX1: four one-line grids (the Mantinels, SWAT:AM, the Typical Policeman and the Typical Rogue), ranks only, and 13 full blocks',
      blocksX.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === ['mantinels', 'swat-am', 'typical-policeman', 'typical-rogue'].map((id) => `${id}-mx1`).join()
      && blocksX.filter(({ b }) => b.kind === 'line').every(({ b }) => b.rank_only) && blocksX.filter(({ b }) => !b.kind).length === 13,
      blocksX.map(({ id, b }) => `${id}:${b.kind}`).join());
    const fixesX = ['nimrod-mx1', 'timbre-morava-mx1', 'big-foot-mx1', 'typical-rogue-mx1'].map((id) => {
      const o = blkX(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}>${v(a.corrected)}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedX(id)}`;
    });
    check('MX1: the four misprints keep the printed value and play the corrected one (Nimrod R 30 Ex, I 30 Gd and P 10 Gy as Rm, Rm and Gd; Timbre Morava S 4, R 6 and I 8 as 6, 20 and 6; Big Foot S Ty and I Ty as Pr and Gd; the Typical Rogue Karma 16 as 14)',
      fixesX.join(' | ') === [
        'nimrod-mx1 misprint R 30 Ex>30 Rm also misprint I 30 Gd>30 Rm also misprint P 10 Gy>10 Gd plays 300/70',
        'timbre-morava-mx1 misprint S 4 Ty>6 Ty also misprint R 6 Ex>20 Ex also misprint I 8 Ty>6 Ty plays 22/32',
        'big-foot-mx1 misprint S 4 Ty>4 Pr also misprint I 8 Ty>8 Gd plays 44/18',
        'typical-rogue-mx1 misprint karma 16>14 plays 28/14',
      ].join(' | '),
      fixesX.join(' | '));
    const robotsX = ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'alpha-sentinel', 'omega-sentinel'].map((id) => `${id}-mx1`);
    check('MX1: the five sentinel robots print Karma 0 against R, I and P printed, kept as printed (as_printed karma) and played as 0',
      robotsX.every((id) => blkX(id)?.override?.verdict === 'as_printed' && blkX(id).override.field === 'karma' && blkX(id).karma === '0')
      && robotsX.map(playedX).join() === '165/0,190/0,250/0,290/0,290/0',
      robotsX.map(playedX).join());
    const ovX = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mx1-overrides.json'), 'utf8')).overrides;
    const textX = ovX.filter((o) => o.verdict === 'text');
    check('MX1: sixteen overrides: four misprints, five as printed and seven text verdicts (the Mark VI\'s Gas Jets and Customization, the Mark V\'s Cold Beams, the Mantinels\' Automatic Escape, Nimrod\'s three repair bullets), and only the nine overridden blocks carry one',
      ovX.length === 16 && ovX.filter((o) => o.verdict === 'misprint').length === 4 && ovX.filter((o) => o.verdict === 'as_printed').length === 5
      && textX.map((o) => o.match.row).join() === ['mark-vi-sentinel-mx1:power:6', 'mark-vi-sentinel-mx1:power:7', 'mark-v-sentinel-mx1:power:7',
        'mantinels-mx1:power:5', 'nimrod-mx1:power:5', 'nimrod-mx1:power:5', 'nimrod-mx1:power:5'].map((k) => `mx1:${k}`).join()
      && blocksX.filter(({ b }) => b.override).map(({ id }) => id).sort().join() === [...robotsX, 'nimrod-mx1', 'timbre-morava-mx1', 'big-foot-mx1', 'typical-rogue-mx1'].sort().join(),
      JSON.stringify(ovX.map((o) => [o.verdict, o.match])));
    check('MX1: SWAT:AM keeps its printed capitals (card_names) and Blue\'s identity line reads Blumal, not the OCR\'s Biumal (speck_lines)',
      mx1.find((c) => c.id === 'swat-am-mx1')?.name === 'SWAT:AM' && mx1.find((c) => c.id === 'blue-mx1')?.versions[0].identity.join() === 'Hugh Blumal, mutant hound',
      `${mx1.find((c) => c.id === 'swat-am-mx1')?.name} | ${mx1.find((c) => c.id === 'blue-mx1')?.versions[0].identity}`);
    check('MX1: 65 powers, 17 of them linked to the UPB',
      mx1.flatMap((c) => c.versions[0].powers).length === 65 && mx1.flatMap((c) => c.versions[0].powers).filter((p) => p.upb).length === 17,
      `${mx1.flatMap((c) => c.versions[0].powers).length} ${mx1.flatMap((c) => c.versions[0].powers).filter((p) => p.upb).length}`);
    const bookX = data.npcs.books.find((b) => b.slug === 'mx1');
    check('MX1: the book reads Adventure 9-14, 24-25 and 28, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookX?.ranges) === '[{"part":"Adventure","pages":[[9,14],[24,25],[28,28]]}]'
      && tagline(bookNpc({ character: 'mark-iv-sentinel-mx1' }).snapshot).startsWith('MX1 Nightmares of Futures Past, Adventure p.9;')
      && tagline(bookNpc({ character: 'typical-rogue-mx1' }).snapshot).startsWith('MX1 Nightmares of Futures Past, Adventure p.28;')
      && mx1.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(bookX)} ${tagline(bookNpc({ character: 'typical-rogue-mx1' }).snapshot)}`);
    check('MX1: cards play their printed Health and Karma (Blue 64/109, Gerald Gage 20/22, Oliver Pierce 16/16, the Mantinels 70/18)',
      ['blue-mx1', 'gerald-gage-mx1', 'oliver-pierce-mx1', 'mantinels-mx1'].map(playedX).join() === '64/109,20/22,16/16,70/18',
      ['blue-mx1', 'gerald-gage-mx1', 'oliver-pierce-mx1', 'mantinels-mx1'].map(playedX).join());
    // The text verdicts and talents_end move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys and by
    // the overrides' own fragments, never a sentence of the book in this file.
    const sqlX = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mx1', 'book-text.sql');
    if (!existsSync(sqlX)) {
      check(`MX1: skipped the text checks: no ${rel(sqlX) || sqlX}`, true);
    } else {
      const rowsX = [...readFileSync(sqlX, 'utf8').matchAll(/VALUES \('([^']+)', 'mx1', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      check('MX1 text: 95 rows over 16 entries (the Typical Rogue prints none), and no row with an odd count of double quotes',
        rowsX.length === 95 && new Set(rowsX.map((r) => r.key.split(':')[1])).size === 16
        && !rowsX.some((r) => r.key.startsWith('mx1:typical-rogue-mx1:'))
        && !rowsX.some((r) => (r.body.match(/"/g) || []).length % 2),
        `${rowsX.length} ${new Set(rowsX.map((r) => r.key.split(':')[1])).size}`);
      const countX = (row, s) => (rowsX.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsX = textX.map((o) => `${o.match.row} ${countX(o.match.row, o.printed)}/${countX(o.match.row, o.read)}`);
      check('MX1 text: each of the seven text verdicts is applied, its printed fragment once in its row and the misread gone',
        textX.length === 7 && verdictsX.every((v) => v.endsWith(' 1/0')), verdictsX.join(' | '));
      const talentsX = ['typical-policeman-mx1', 'swat-am-mx1'].map((id) => rowsX.find((r) => r.key === `mx1:${id}:talents`)?.body);
      check('MX1 text: the Typical Policeman\'s and SWAT:AM\'s talents rows are their TALENT: lines alone, what follows them is prose (talents_end)',
        talentsX.join(' | ') === 'Law Enforcement | Law Enforcement, Marksmanship'
        && ['typical-policeman-mx1', 'swat-am-mx1'].every((id) => rowsX.some((r) => r.key === `mx1:${id}:prose`)),
        talentsX.join(' | '));
    }
  }

  // MT2 is read by scripts/msh/gridbooks.py (mt2-overrides.json), with the
  // survey's decisions applied as it recommends (mt2.md; Nate 2026-10-30).
  // Every card is in the Adventure Book (printed 3-8, 12-36 and 52-64). The
  // registry fields whose absence roster.py would not stop on (card_names,
  // count_headers, not_labels, bracket_tail, subhead_labels, stop_labels,
  // indented_power_heads, speck_lines, rank_ranges) are each pinned here by
  // what they change.
  if (data.npcs.characters.some((c) => c.book === 'mt2')) {
    const mt2 = data.npcs.characters.filter((c) => c.book === 'mt2');
    const blocksT = mt2.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkT = (id, i = 0) => mt2.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamT = (t) => mt2.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedT = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MT2: 30 characters, each id ending -mt2 with one version, the three Player Characters as Weird, Weird West Heroes, the eight Western Heroes and Lobo as Western Heroes, 18 under the book\'s title, and no name starting The',
      mt2.length === 30 && mt2.every((c) => c.id.endsWith('-mt2') && c.versions.length === 1)
      && teamT('Weird, Weird West Heroes') === 'Moon Knight,Scarlet Witch,Vision'
      && teamT('Western Heroes') === 'Ghost Rider I & II,Ghost Rider IV,Kid Colt,Lobo,Rawhide Kid,Red Wolf,Shooting Star,Texas Twister,Two-Gun Kid'
      && mt2.filter((c) => c.team === 'MT2 The Weird, Weird West').length === 18
      && !mt2.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mt2.length} ${[...new Set(mt2.map((c) => c.team))]}`);
    check('MT2: the cards sort by the Adventure page each starts on, 3 to 63',
      mt2.map((c) => c.id).join() === ['vision', 'moon-knight', 'albert-einstein', 'scarlet-witch', 'alexander-the-great', 'doctor-doom',
        'genghis-khan', 'napoleon-bonaparte', 'mysterio', 'sandman', 'black-knight-nathan-garrett', 'krozzar', 'scorpion', 'tyrannosaur',
        'hoplites', 'cavemen', 'faro-john-hobart', 'average-mounted-desperado', 'average-rifleman', 'khan-s-champion', 'twain-android',
        'ghost-rider-i-ii', 'ghost-rider-iv', 'kid-colt', 'rawhide-kid', 'lobo', 'red-wolf', 'shooting-star', 'texas-twister',
        'two-gun-kid'].map((id) => `${id}-mt2`).join(),
      mt2.map((c) => c.id).join());
    check('MT2: the Black Knight is Nathan Garrett (card_names), and "Faro" John Hobart and Ghost Rider I & II read as printed (speck_lines)',
      mt2.find((c) => c.id === 'black-knight-nathan-garrett-mt2')?.name === 'Black Knight (Nathan Garrett)'
      && mt2.find((c) => c.id === 'faro-john-hobart-mt2')?.name === '"Faro" John Hobart'
      && mt2.find((c) => c.id === 'ghost-rider-i-ii-mt2')?.name === 'Ghost Rider I & II',
      ['black-knight-nathan-garrett-mt2', 'faro-john-hobart-mt2', 'ghost-rider-i-ii-mt2'].map((id) => mt2.find((c) => c.id === id)?.name).join(' | '));
    check('MT2: 32 blocks: Moon Knight\'s Normal and Moonlight, Ghost Rider IV\'s own and Hamilton Slade\'s one-line grid, five more one-line grids (Lobo\'s ranks only), and no other block labelled (count_headers, not_labels)',
      blocksT.length === 32
      && blocksT.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'moon-knight-mt2:Normal,moon-knight-mt2:Moonlight,ghost-rider-iv-mt2:Ghost Rider IV,ghost-rider-iv-mt2:Hamilton Slade'
      && blocksT.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === ['tyrannosaur', 'hoplites', 'cavemen', 'khan-s-champion',
        'ghost-rider-iv', 'lobo'].map((id) => `${id}-mt2`).join()
      && blocksT.filter(({ b }) => b.rank_only).map(({ id }) => id).join() === 'lobo-mt2' && blocksT.filter(({ b }) => !b.kind).length === 26,
      blocksT.map(({ id, b }) => `${id}:${b.kind}:${b.label}`).join());
    const fixesT = ['genghis-khan-mt2', 'khan-s-champion-mt2'].map((id) => {
      const o = blkT(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}>${v(a.corrected)}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedT(id)}`;
    });
    check('MT2: the two misprints keep the printed value and play the corrected one (Genghis Khan A and S 6 Gd as 6 Ty, Khan\'s Champion Karma 10 as 14)',
      fixesT.join(' | ') === [
        'genghis-khan-mt2 misprint A 6 Gd>6 Ty also misprint S 6 Gd>6 Ty plays 52/40',
        'khan-s-champion-mt2 misprint karma 10>14 plays 50/14',
      ].join(' | '),
      fixesT.join(' | '));
    const ovT = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mt2-overrides.json'), 'utf8')).overrides;
    const textT = ovT.filter((o) => o.verdict === 'text');
    check('MT2: eleven overrides: two misprints and nine text verdicts (the Scarlet Witch\'s first power, the Black Knight\'s second, Ghost Rider IV\'s notes, and six line-end hyphen breaks: Kid Colt\'s contacts, Krozzar\'s background, Two-Gun Kid\'s first power, talents and two in his notes) whose printed fragment no longer reads the shape, and only the two misprinted blocks carry one',
      ovT.length === 11 && ovT.filter((o) => o.verdict === 'misprint').length === 2
      && textT.map((o) => o.match.row).join() === ['scarlet-witch-mt2:power:1', 'black-knight-nathan-garrett-mt2:power:2', 'ghost-rider-iv-mt2:notes',
        'kid-colt-mt2:contacts', 'krozzar-mt2:background', 'two-gun-kid-mt2:power:1', 'two-gun-kid-mt2:talents', 'two-gun-kid-mt2:notes', 'two-gun-kid-mt2:notes'].map((k) => `mt2:${k}`).join()
      && textT.slice(3).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && blocksT.filter(({ b }) => b.override).map(({ id }) => id).join() === 'genghis-khan-mt2,khan-s-champion-mt2',
      JSON.stringify(ovT.map((o) => [o.verdict, o.match])));
    const offStd = (id) => blkT(id)?.abilities.filter(([, n, code]) => {
      const r = ranks.find((x) => x.abbr === code);
      return r && r.standard !== n && n >= r.min && n <= (r.max ?? Infinity);
    }).length;
    const gangT = ['faro-john-hobart-mt2', 'average-mounted-desperado-mt2', 'average-rifleman-mt2'];
    check('MT2: the Hobart Gang\'s three blocks print numbers inside their ranks but off the standards, and pass with no override (rank_ranges)',
      gangT.every((id) => offStd(id) > 0 && !blkT(id)?.override)
      && gangT.map((id) => playedT(id)).join() === '32/40,29/13,26/13',
      gangT.map((id) => `${id} off ${offStd(id)} plays ${playedT(id)}`).join(' | '));
    check('MT2: Two-Gun Kid\'s Resources the code GD with no number, Kid Colt\'s Popularity 20 with its clause kept, and the Twain Android\'s Resources FE (2) with nothing after it (bracket_tail)',
      blkT('two-gun-kid-mt2')?.resources === 'GD' && blkT('kid-colt-mt2')?.popularity === '20 (-30 with authorities)'
      && bookNpc({ character: 'kid-colt-mt2' }).snapshot?.abilities.popularity.number === 20 && blkT('twain-android-mt2')?.resources === 'FE (2)',
      `${blkT('two-gun-kid-mt2')?.resources} | ${blkT('kid-colt-mt2')?.popularity} | ${bookNpc({ character: 'kid-colt-mt2' }).snapshot?.abilities.popularity.number} | ${blkT('twain-android-mt2')?.resources}`);
    const powT = mt2.flatMap((c) => c.versions[0].powers);
    check('MT2: 51 powers across 19 cards, 9 of them linked to the UPB, the Twain Android\'s two among them (subhead_labels, indented_power_heads, speck_lines)',
      powT.length === 51 && powT.filter((p) => p.upb).length === 9 && mt2.filter((c) => c.versions[0].powers.length).length === 19
      && mt2.find((c) => c.id === 'twain-android-mt2')?.versions[0].powers.map((p) => p.name).join() === 'Body Armor,Radio Communication',
      `${powT.length} ${powT.filter((p) => p.upb).length} ${mt2.filter((c) => c.versions[0].powers.length).length}`);
    const bookT = data.npcs.books.find((b) => b.slug === 'mt2');
    const choicesT = mt2.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MT2: the book reads Adventure 3-8, 12-36 and 52-64, a card cites its Adventure page, and every card is one GM choice but Moon Knight, whose Normal and Moonlight are two',
      JSON.stringify(bookT?.ranges) === '[{"part":"Adventure","pages":[[3,8],[12,36],[52,64]]}]'
      && tagline(bookNpc({ character: 'vision-mt2' }).snapshot).startsWith('MT2 The Weird, Weird West, Adventure p.3;')
      && tagline(bookNpc({ character: 'two-gun-kid-mt2' }).snapshot).startsWith('MT2 The Weird, Weird West, Adventure p.63;')
      && mt2.every((c, i) => choicesT[i] === (c.id === 'moon-knight-mt2' ? 2 : 1)),
      `${JSON.stringify(bookT?.ranges)} ${tagline(bookNpc({ character: 'vision-mt2' }).snapshot)} ${mt2.map((c, i) => `${c.id}:${choicesT[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const slade = bookNpc({ character: 'ghost-rider-iv-mt2' }).snapshot;
    check('MT2: Hamilton Slade is a form on Ghost Rider IV\'s card (86 and 46), not a GM choice of its own, as ME3\'s Beta Ray Bill\'s humanoid form',
      slade?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Ghost Rider IV 86,Hamilton Slade 46',
      JSON.stringify(slade?.forms?.map((f) => [f.name, f.health])));
    const playsT = [['vision-mt2'], ['doctor-doom-mt2'], ['sandman-mt2'], ['moon-knight-mt2', 0], ['moon-knight-mt2', 1], ['ghost-rider-iv-mt2'], ['lobo-mt2']].map(([id, b]) => playedT(id, b)).join();
    check('MT2: cards play their printed Health and Karma (Vision 140/60, Doctor Doom 120/140, Sandman 175/46, Moon Knight 90/60 and in Moonlight 150/60, Ghost Rider IV 86/60, Lobo 50/10)',
      playsT === '140/60,120/140,175/46,90/60,150/60,86/60,50/10', playsT);
    // The text verdicts and stop_labels move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys and by
    // the overrides' own fragments, never a sentence of the book in this file.
    const sqlT = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mt2', 'book-text.sql');
    if (!existsSync(sqlT)) {
      check(`MT2: skipped the text checks: no ${rel(sqlT) || sqlT}`, true);
    } else {
      const rowsT = [...readFileSync(sqlT, 'utf8').matchAll(/VALUES \('([^']+)', 'mt2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entT = new Set(rowsT.map((r) => r.key.split(':')[1]));
      check('MT2 text: 127 rows over 27 entries (the Hoplites, the Cavemen and Khan\'s Champion print none), no row with an odd count of double quotes and none with a vertical bar',
        rowsT.length === 127 && entT.size === 27
        && mt2.filter((c) => !entT.has(c.id)).map((c) => c.id).join() === 'hoplites-mt2,cavemen-mt2,khan-s-champion-mt2'
        && !rowsT.some((r) => (r.body.match(/"/g) || []).length % 2) && !rowsT.some((r) => r.body.includes('|')),
        `${rowsT.length} ${entT.size} ${rowsT.filter((r) => (r.body.match(/"/g) || []).length % 2 || r.body.includes('|')).map((r) => r.key)}`);
      const countT = (row, s) => (rowsT.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsT = textT.map((o) => `${o.match.row} ${countT(o.match.row, o.printed)}/${countT(o.match.row, o.read)}`);
      check('MT2 text: each of the nine text verdicts is applied, its printed fragment once in its row and the misread gone',
        textT.length === 9 && verdictsT.every((v) => v.endsWith(' 1/0')), verdictsT.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10r, Nate
      // 2026-11-03): MT2's six are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeT = rowsT.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mt2:/, ''))).sort();
      check('MT2 text: no row reads a letter, a hyphen and a space before a word',
        rowsT.length > 0 && shapeT.length === 0, shapeT.join(' '));
      const twainT = rowsT.filter((r) => r.key.startsWith('mt2:twain-android-mt2:')).map((r) => r.key.split(':')[2]).sort().join();
      check('MT2 text: the Twain Android\'s Talents. and Contacts. open sections of their own beside its two powers (stop_labels)',
        twainT === 'contacts,power,power,talents', twainT);
    }
  }

  // MT3 is read by scripts/msh/gridbooks.py (mt3-overrides.json), with the
  // survey's decisions applied as it recommends (mt3.md; Nate 2026-10-30).
  // Every card is in the Adventure Book (printed 4-16 and 21-63). The registry
  // fields whose absence roster.py would not stop on (speck_lines,
  // derived_totals, class_i_digit, two_ranks) are each pinned here by what
  // they change.
  if (data.npcs.characters.some((c) => c.book === 'mt3')) {
    const mt3 = data.npcs.characters.filter((c) => c.book === 'mt3');
    const blocksK = mt3.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkK = (id, i = 0) => mt3.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamK = (t) => mt3.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedK = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MT3: 43 characters, each id ending -mt3 with one version, the three Player Characters as Revenge of Kang Heroes, six X-Men, four Fantastic Four, 30 under the book\'s title, and no name starting The',
      mt3.length === 43 && mt3.every((c) => c.id.endsWith('-mt3') && c.versions.length === 1)
      && teamK('Revenge of Kang Heroes') === 'Moon Knight,Scarlet Witch,Vision'
      && teamK('X-Men') === 'Angel,Beast,Cyclops,Iceman,Marvel Girl,Professor X'
      && teamK('Fantastic Four') === 'Human Torch,Invisible Girl,Mister Fantastic,Thing'
      && mt3.filter((c) => c.team === 'MT3 The Revenge of Kang').length === 30
      && !mt3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mt3.length} ${[...new Set(mt3.map((c) => c.team))]}`);
    check('MT3: the cards sort by the Adventure page each starts on, 4 to 63',
      mt3.map((c) => c.id).join() === ['vision', 'moon-knight', 'scarlet-witch', 'beast', 'cyclops', 'angel', 'iceman', 'marvel-girl',
        'professor-x', 'invisible-girl', 'mister-fantastic', 'human-torch', 'thing', 'daredevil', 'spider-man', 'iron-man', 'marty-jenkins',
        'kang', 'ko-kri', 'executioner', 'mad-thinker', 'mad-thinker-s-android', 'super-skrull', 'black-knight-nathan-garrett', 'mandarin',
        'melter', 'unicorn', 'attuma', 'attuma-s-minions', 'beetle', 'electro', 'fish', 'giant-insect', 'alligator-creatures', 'snakes',
        'scorpions', 'kang-duplicate-s-battle-robots', 'thugs', 'mike-franklin', 'tom-tyler', 'security-robots',
        'supreme-kang-s-battle-robots', 'o-malley'].map((id) => `${id}-mt3`).join(),
      mt3.map((c) => c.id).join());
    check('MT3: 48 blocks: five cards of two labelled forms (Moon Knight, the Thing, Daredevil, Spider-Man, Iron Man), 14 one-line grids (the Mad Thinker\'s Android\'s and Attuma\'s Minions\' ranks only), and 34 full blocks',
      blocksK.length === 48
      && blocksK.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === ['moon-knight-mt3:Normal', 'moon-knight-mt3:Moonlight',
        'thing-mt3:Thing', 'thing-mt3:Ben (human form)', 'daredevil-mt3:Daredevil', 'daredevil-mt3:Matt Murdock (pre-accident)',
        'spider-man-mt3:Spider-Man', 'spider-man-mt3:Peter Parker (Non-Powered Form)', 'iron-man-mt3:Iron Man', 'iron-man-mt3:Tony Stark (without armor)'].join()
      && blocksK.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === ['mad-thinker-s-android', 'attuma-s-minions', 'fish',
        'giant-insect', 'alligator-creatures', 'snakes', 'scorpions', 'kang-duplicate-s-battle-robots', 'thugs', 'mike-franklin', 'tom-tyler',
        'security-robots', 'supreme-kang-s-battle-robots', 'o-malley'].map((id) => `${id}-mt3`).join()
      && blocksK.filter(({ b }) => b.rank_only).map(({ id }) => id).join() === 'mad-thinker-s-android-mt3,attuma-s-minions-mt3'
      && blocksK.filter(({ b }) => !b.kind).length === 34,
      blocksK.map(({ id, b }) => `${id}:${b.kind}:${b.label}`).join());
    const fixesK = [['moon-knight-mt3', 0], ['mandarin-mt3'], ['kang-duplicate-s-battle-robots-mt3'], ['mike-franklin-mt3'], ['tom-tyler-mt3']].map(([id, i]) => {
      const o = blkK(id, i)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)} plays ${playedK(id, i)}`;
    });
    check('MT3: the five misprints keep the printed value and carry the corrected one (Moon Knight\'s Normal P 30 Ex as 30 Rm, the Mandarin\'s Resources AM(30) as AM(50), Kang Duplicate\'s Battle Robots Health 90 as 110, Mike Franklin Karma 18 as 14, Tom Tyler Karma 22 as 18)',
      fixesK.join(' | ') === [
        'moon-knight-mt3 misprint P 30 Ex>30 Rm plays 90/60',
        'mandarin-mt3 misprint resources AM(30)>AM(50) plays 90/60',
        'kang-duplicate-s-battle-robots-mt3 misprint health 90>110 plays 110/18',
        'mike-franklin-mt3 misprint karma 18>14 plays 120/14',
        'tom-tyler-mt3 misprint karma 22>18 plays 100/18',
      ].join(' | ')
      && bookNpc({ character: 'moon-knight-mt3', block: 0 }).snapshot?.abilities.psyche.rank === 'remarkable',
      fixesK.join(' | '));
    const resK = bookNpc({ character: 'mandarin-mt3' }).snapshot?.abilities.resources;
    check('MT3: the Mandarin\'s Resources misprint plays as corrected (printed AM(30) is Remarkable 30, corrected AM(50) plays Amazing 50), and only a block with a resources override changes (the Mandarin of MH7, printing the word Amazing, plays the same)',
      resK?.rank === 'amazing' && resK.number === 50
      && blkK('mandarin-mt3')?.resources === 'AM(30)'
      && bookNpc({ character: 'mandarin-mh7' }).snapshot?.abilities.resources.rank === 'amazing',
      JSON.stringify(resK));
    check('MT3: Kang\'s Karma Varies is kept as printed and plays none, his R, I and P each two ranks, the first played (two_ranks)',
      blkK('kang-mt3')?.override?.verdict === 'as_printed' && blkK('kang-mt3')?.karma === 'Varies' && playedK('kang-mt3') === '86/null'
      && blkK('kang-mt3')?.abilities.slice(4).map((a) => a.slice(1).join(' ')).join() === '40 In 50,Am,6 Ty 30,Rm,10 Gd 40,In'
      && bookNpc({ character: 'kang-mt3' }).snapshot?.abilities.reason.number === 40,
      `${blkK('kang-mt3')?.karma} ${playedK('kang-mt3')} ${blkK('kang-mt3')?.abilities.slice(4).map((a) => a.slice(1).join(' ')).join()}`);
    const ovK = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mt3-overrides.json'), 'utf8')).overrides;
    const textK = ovK.filter((o) => o.verdict === 'text');
    check('MT3: 22 overrides: five misprints, one as printed and 16 text verdicts (Kang\'s background quote, 11 capital I misread as a bar or an l, the Thugs\' last word, and three line-end hyphen breaks: Daredevil\'s and Spider-Man\'s backgrounds, the Super-Skrull\'s second power) whose printed fragment no longer reads the shape, and only those six blocks carry one',
      ovK.length === 22 && ovK.filter((o) => o.verdict === 'misprint').length === 5 && ovK.filter((o) => o.verdict === 'as_printed').length === 1
      && textK.map((o) => o.match.row.replace(/^mt3:/, '')).join() === ['kang-mt3:background', 'scarlet-witch-mt3:power:1', 'iceman-mt3:power:1',
        'iceman-mt3:power:2', 'professor-x-mt3:notes', 'human-torch-mt3:background', 'daredevil-mt3:power:2', 'iron-man-mt3:power:1',
        'iron-man-mt3:power:4', 'o-malley-mt3:prose', 'kang-mt3:background', 'kang-mt3:background', 'thugs-mt3:prose',
        'daredevil-mt3:background', 'spider-man-mt3:background', 'super-skrull-mt3:power:2'].join()
      && textK.slice(13).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && blocksK.filter(({ b }) => b.override).map(({ id }) => id).join()
        === 'moon-knight-mt3,kang-mt3,mandarin-mt3,kang-duplicate-s-battle-robots-mt3,mike-franklin-mt3,tom-tyler-mt3',
      JSON.stringify(ovK.map((o) => [o.verdict, o.match])));
    check('MT3: the Snakes print no Karma and the Scorpions neither total, so theirs are derived from their rows (28/10, 40/18) and flagged so, and no other MT3 block is (derived_totals)',
      blkK('snakes-mt3')?.karma_derived === true && !blkK('snakes-mt3')?.health_derived
      && blkK('scorpions-mt3')?.karma_derived === true && blkK('scorpions-mt3')?.health_derived === true
      && playedK('snakes-mt3') === '28/10' && playedK('scorpions-mt3') === '40/18'
      && blocksK.filter(({ b }) => b.karma_derived || b.health_derived).length === 2,
      `${playedK('snakes-mt3')} ${playedK('scorpions-mt3')} ${blocksK.filter(({ b }) => b.karma_derived || b.health_derived).map(({ id }) => id)}`);
    check('MT3: the Fish\'s Endurance reads Class 1000, not Cli000, and plays 1060/6 (class_i_digit)',
      blkK('fish-mt3')?.abilities[3].slice(1).join(' ') === '1000 C-1000'
      && bookNpc({ character: 'fish-mt3' }).snapshot?.abilities.endurance.rank === 'class-1000' && playedK('fish-mt3') === '1060/6',
      `${blkK('fish-mt3')?.abilities[3]} ${playedK('fish-mt3')}`);
    const powK = mt3.flatMap((c) => c.versions[0].powers);
    check('MT3: 85 powers across 28 cards, 31 of them linked to the UPB, Kang\'s five among them, and the Angel\'s identity line Warren Worthington III (speck_lines)',
      powK.length === 85 && powK.filter((p) => p.upb).length === 31 && mt3.filter((c) => c.versions[0].powers.length).length === 28
      && mt3.find((c) => c.id === 'kang-mt3')?.versions[0].powers.length === 5
      && mt3.find((c) => c.id === 'angel-mt3')?.versions[0].identity[0] === 'Warren Worthington III',
      `${powK.length} ${powK.filter((p) => p.upb).length} ${mt3.filter((c) => c.versions[0].powers.length).length} ${mt3.find((c) => c.id === 'angel-mt3')?.versions[0].identity[0]}`);
    const bookK = data.npcs.books.find((b) => b.slug === 'mt3');
    const twoK = ['moon-knight-mt3', 'thing-mt3', 'daredevil-mt3', 'spider-man-mt3', 'iron-man-mt3'];
    const choicesK = mt3.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MT3: the book reads Adventure 4-16 and 21-63, a card cites its Adventure page, and every card is one GM choice but the five two-block cards, two each',
      JSON.stringify(bookK?.ranges) === '[{"part":"Adventure","pages":[[4,16],[21,63]]}]'
      && tagline(bookNpc({ character: 'vision-mt3' }).snapshot).startsWith('MT3 The Revenge of Kang, Adventure p.4;')
      && tagline(bookNpc({ character: 'o-malley-mt3' }).snapshot).startsWith('MT3 The Revenge of Kang, Adventure p.63;')
      && mt3.every((c, i) => choicesK[i] === (twoK.includes(c.id) ? 2 : 1)),
      `${JSON.stringify(bookK?.ranges)} ${tagline(bookNpc({ character: 'vision-mt3' }).snapshot)} ${mt3.map((c, i) => `${c.id}:${choicesK[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsK = [['vision-mt3'], ['professor-x-mt3'], ['executioner-mt3'], ['thing-mt3', 0], ['thing-mt3', 1], ['iron-man-mt3', 0], ['iron-man-mt3', 1],
      ['mad-thinker-s-android-mt3'], ['attuma-s-minions-mt3'], ['o-malley-mt3']].map(([id, b]) => playedK(id, b)).join();
    check('MT3: cards play their printed Health and Karma (Vision 140/60, Professor X 50/165, the Executioner 245/36, the Thing 200/50 and as Ben 50/50, Iron Man 84/66 and as Tony Stark 22/66, the Mad Thinker\'s Android 100/6, Attuma\'s Minions 100/18, O\'Malley 160/18)',
      playsK === '140/60,50/165,245/36,200/50,50/50,84/66,22/66,100/6,100/18,160/18', playsK);
    // The text verdict moves only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by the override's own
    // fragments, never a sentence of the book in this file.
    const sqlK = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mt3', 'book-text.sql');
    if (!existsSync(sqlK)) {
      check(`MT3: skipped the text checks: no ${rel(sqlK) || sqlK}`, true);
    } else {
      const rowsK = [...readFileSync(sqlK, 'utf8').matchAll(/VALUES \('([^']+)', 'mt3', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entK = new Set(rowsK.map((r) => r.key.split(':')[1]));
      check('MT3 text: 172 rows over 42 entries (Attuma\'s Minions print none) and no row with an odd count of double quotes',
        rowsK.length === 172 && entK.size === 42
        && mt3.filter((c) => !entK.has(c.id)).map((c) => c.id).join() === 'attuma-s-minions-mt3'
        && !rowsK.some((r) => (r.body.match(/"/g) || []).length % 2),
        `${rowsK.length} ${entK.size} ${rowsK.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)}`);
      // A vertical bar is the OCR's reading of a capital I. Ten rows carried
      // one (nine now read right by a text verdict, the tenth, Attuma's, was
      // inside a sidebar the entry no longer takes), each read on the page; a
      // new one moves this list. So does "Il" for "II": Kang's two read right.
      const barsK = rowsK.filter((r) => r.body.includes('|') || /\bIl\b/.test(r.body)).map((r) => r.key.replace(/^mt3:/, ''));
      check('MT3 text: no row carries a vertical bar or a Part Il',
        barsK.length === 0, barsK.join());
      const countK = (row, s) => (rowsK.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsK = textK.map((o) => `${o.match.row} ${countK(o.match.row, o.printed)}/${countK(o.match.row, o.read)}`);
      check('MT3 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        // the Thugs' verdict only adds a word, so its read fragment stays inside its printed one
        textK.length === 16 && textK.every((o) => countK(o.match.row, o.printed) >= 1 && (o.printed.includes(o.read) || countK(o.match.row, o.read) === 0)),
        verdictsK.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10s, Nate
      // 2026-11-03): MT3's three are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeK = rowsK.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mt3:/, ''))).sort();
      check('MT3 text: no row reads a letter, a hyphen and a space before a word',
        rowsK.length > 0 && shapeK.length === 0, shapeK.join(' '));
      // Where an entry's text ends, each read on the page (survey mt3.md): the
      // Scarlet Witch's background runs on into printed 6, Attuma's and the
      // alligators' stop before the sidebar and the box that share their
      // column, and the Thugs' ends on its page's last word.
      const bodyK = (row) => rowsK.find((r) => r.key === row)?.body || '';
      check('MT3 text: the Scarlet Witch\'s background runs onto printed 6, Attuma\'s ends before the KANG\'S SCRIPT sidebar, the alligators\' before the SPIRE box, and the Thugs\' on "long."',
        !/re-$/.test(bodyK('mt3:scarlet-witch-mt3:background')) && /life\.$/.test(bodyK('mt3:scarlet-witch-mt3:background'))
        && /wedding\.$/.test(bodyK('mt3:attuma-mt3:background')) && !/SCRIPT/.test(bodyK('mt3:attuma-mt3:background'))
        && /foliage\.$/.test(bodyK('mt3:alligator-creatures-mt3:prose')) && !/SPIRE/.test(bodyK('mt3:alligator-creatures-mt3:prose'))
        && /areas long\.$/.test(bodyK('mt3:thugs-mt3:prose')),
        ['scarlet-witch-mt3:background', 'attuma-mt3:background', 'alligator-creatures-mt3:prose', 'thugs-mt3:prose'].map((k) => `${k} ...${bodyK('mt3:' + k).slice(-12)}`).join(' | '));
    }
  }

  // MX2 is read by scripts/msh/gridbooks.py (mx2-overrides.json), with the
  // survey's decisions applied as it recommends (mx2.md; Nate 2026-10-31).
  // Every card is in the Adventure Book (printed 10-17), filed under the
  // book's title. The registry fields only this book sets (subhead_exact_case,
  // code_rows_resources_below, line_grid_resources, table_grids, a grid's
  // karma and subhead_page, line_identity) and the ones it shares whose
  // absence roster.py would not stop on (card_names, speck_lines, power_heads,
  // rank_ranges) are each pinned here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'mx2')) {
    const mx2 = data.npcs.characters.filter((c) => c.book === 'mx2');
    const blocksZ = mx2.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blkZ = (id) => mx2.find((c) => c.id === id)?.versions[0].blocks[0];
    const cardZ = (id) => mx2.find((c) => c.id === id)?.versions[0];
    const playedZ = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    const committeeZ = ['chuck', 'martha', 'bob', 'phil', 'jenny'].map((id) => `${id}-mx2`);
    check('MX2: 24 characters, each id ending -mx2 with one version and one block, all filed under the book\'s title, and no name starting The',
      mx2.length === 24 && mx2.every((c) => c.id.endsWith('-mx2') && c.versions.length === 1 && c.versions[0].blocks.length === 1)
      && mx2.every((c) => c.team === 'MX2 The X-Potential') && !mx2.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mx2.length} ${[...new Set(mx2.map((c) => c.team))]}`);
    check('MX2: the cards sort by the Adventure page each starts on, 10 to 16, McGrafton first and the six sentinels next',
      mx2.map((c) => c.id).join() === ['senator-joseph-mcgrafton', 'alpha-sentinel', 'mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel',
        'omega-sentinel', 'nimrod', 'swat-am', 'typical-policeman', 'knights-of-genetic-purity', 'secret-service-anti-mutant-teams',
        'soldiers-and-camp-guards', 'vincent-scarlesi', 'bob', 'chuck', 'general-william-b-braddock', 'jenny', 'lorelei', 'martha', 'phil',
        'dr-paolo-hernandez', 'dr-yagami-fuchido', 'jay-atkinson', 'william-shiver'].map((id) => `${id}-mx2`).join(),
      mx2.map((c) => c.id).join());
    check('MX2: sixteen one-line grids, ranks only (eleven codes-only grids and the Mutant Affairs Committee\'s five rows, table_grids), and eight full blocks',
      blocksZ.filter(({ b }) => b.kind === 'line').map(({ id }) => id).sort().join() === ['swat-am', 'typical-policeman', 'knights-of-genetic-purity',
        'secret-service-anti-mutant-teams', 'soldiers-and-camp-guards', 'vincent-scarlesi', 'general-william-b-braddock', 'dr-paolo-hernandez',
        'dr-yagami-fuchido', 'jay-atkinson', 'william-shiver', 'chuck', 'martha', 'bob', 'phil', 'jenny'].map((id) => `${id}-mx2`).sort().join()
      && blocksZ.filter(({ b }) => b.kind === 'line').every(({ b }) => b.rank_only) && blocksZ.filter(({ b }) => !b.kind).length === 8,
      blocksZ.map(({ id, b }) => `${id}:${b.kind}`).join());
    const fixesZ = ['nimrod', 'knights-of-genetic-purity', 'vincent-scarlesi', 'general-william-b-braddock', 'dr-paolo-hernandez', 'jay-atkinson',
      ...committeeZ.map((id) => id.replace(/-mx2$/, ''))].map((s) => {
      const id = `${s}-mx2`;
      const o = blkZ(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}>${v(a.corrected)}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedZ(id)}`;
    });
    check('MX2: the eleven misprints keep the printed value and play the corrected one (Nimrod R 30 Ex as 30 Rm; five codes-only grids\' totals and the committee\'s one Health 20 and Karma 10 as each member\'s codes add up)',
      fixesZ.join(' | ') === [
        'nimrod-mx2 misprint R 30 Ex>30 Rm plays 300/70',
        'knights-of-genetic-purity-mx2 misprint health 32>40 also misprint karma 14>12 plays 40/12',
        'vincent-scarlesi-mx2 misprint health 20>24 also misprint karma 30>40 plays 24/40',
        'general-william-b-braddock-mx2 misprint health 29>36 also misprint karma 37>46 plays 36/46',
        'dr-paolo-hernandez-mx2 misprint karma 56>66 plays 20/66',
        'jay-atkinson-mx2 misprint karma 32>26 plays 22/26',
        'chuck-mx2 misprint health 20>18 also misprint karma 10>22 plays 18/22',
        'martha-mx2 misprint health 20>28 also misprint karma 10>36 plays 28/36',
        'bob-mx2 misprint health 20>50 also misprint karma 10>18 plays 50/18',
        'phil-mx2 misprint health 20>34 also misprint karma 10>44 plays 34/44',
        'jenny-mx2 misprint health 20>40 also misprint karma 10>32 plays 40/32',
      ].join(' | ')
      && bookNpc({ character: 'nimrod-mx2' }).snapshot?.abilities.reason.rank === 'remarkable',
      fixesZ.join(' | '));
    const robotsZ = ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'alpha-sentinel', 'omega-sentinel'].map((id) => `${id}-mx2`);
    check('MX2: the five sentinel robots print Karma 0 against R, I and P printed, kept as printed (as_printed karma) and played as 0',
      robotsZ.every((id) => blkZ(id)?.override?.verdict === 'as_printed' && blkZ(id).override.field === 'karma' && blkZ(id).karma === '0')
      && robotsZ.map(playedZ).join() === '165/0,190/0,250/0,290/0,290/0',
      robotsZ.map(playedZ).join());
    const ovZ = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mx2-overrides.json'), 'utf8')).overrides;
    const textZ = ovZ.filter((o) => o.verdict === 'text');
    check('MX2: 24 overrides: eleven misprints, five as printed and eight text verdicts (the Mark IV\'s Customization, the alpha\'s and omega\'s Body Armor, two in William Shiver\'s background, one line-end hyphen break in McGrafton\'s background whose printed fragment no longer reads the shape, and two proofread misreads, Nimrod\'s Teleportation and SWAT:AM\'s notes), and only the sixteen overridden blocks carry one',
      ovZ.length === 24 && ovZ.filter((o) => o.verdict === 'misprint').length === 11 && ovZ.filter((o) => o.verdict === 'as_printed').length === 5
      && textZ.map((o) => o.match.row).join() === ['mark-iv-sentinel-mx2:power:8', 'alpha-sentinel-mx2:power:4', 'omega-sentinel-mx2:power:4',
        'william-shiver-mx2:background', 'william-shiver-mx2:background', 'senator-joseph-mcgrafton-mx2:background',
        'nimrod-mx2:power:9', 'swat-am-mx2:notes'].map((k) => `mx2:${k}`).join()
      && textZ.slice(5, 6).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && blocksZ.filter(({ b }) => b.override).map(({ id }) => id).sort().join() === [...robotsZ, ...fixesZ.map((f) => f.split(' ')[0])].sort().join(),
      JSON.stringify(ovZ.map((o) => [o.verdict, o.match])));
    check('MX2: cards play their printed Health and Karma (McGrafton 57/128, Lorelei 94/70, SWAT:AM 46/22, the Typical Policeman 36/18, the Soldiers 46/16, the Secret Service teams 50/30, Fuchido 20/46, Shiver 28/50)',
      ['senator-joseph-mcgrafton', 'lorelei', 'swat-am', 'typical-policeman', 'soldiers-and-camp-guards', 'secret-service-anti-mutant-teams',
        'dr-yagami-fuchido', 'william-shiver'].map((id) => playedZ(`${id}-mx2`)).join() === '57/128,94/70,46/22,36/18,46/16,50/30,20/46,28/50',
      ['senator-joseph-mcgrafton', 'lorelei', 'swat-am', 'typical-policeman', 'soldiers-and-camp-guards', 'secret-service-anti-mutant-teams',
        'dr-yagami-fuchido', 'william-shiver'].map((id) => playedZ(`${id}-mx2`)).join());
    check('MX2: Nimrod\'s Resources is the IN (40) set under its label and his I reads 30 Rm, not IN 40 (code_rows_resources_below); Scarlesi\'s Resources IN and Popularity 20 are in his block (line_grid_resources)',
      blkZ('nimrod-mx2')?.resources === 'IN (40)' && blkZ('nimrod-mx2')?.abilities[5].slice(1).join(' ') === '30 Rm'
      && blkZ('vincent-scarlesi-mx2')?.resources === 'IN' && blkZ('vincent-scarlesi-mx2')?.popularity === '20',
      `${blkZ('nimrod-mx2')?.resources} ${blkZ('nimrod-mx2')?.abilities[5]} ${blkZ('vincent-scarlesi-mx2')?.resources} ${blkZ('vincent-scarlesi-mx2')?.popularity}`);
    check('MX2: SWAT:AM keeps its printed capitals (card_names) and is found from its subhead on printed 13 (subhead_page); the Secret Service teams\' grid is found (subhead_exact_case) and so is Fuchido\'s (speck_lines)',
      cardZ('swat-am-mx2') && mx2.find((c) => c.id === 'swat-am-mx2').name === 'SWAT:AM' && JSON.stringify(cardZ('swat-am-mx2').pages) === '[13,14]'
      && blkZ('secret-service-anti-mutant-teams-mx2')?.kind === 'line'
      && blkZ('dr-yagami-fuchido-mx2')?.abilities.map((a) => a[0]).join('') === 'FASERIP',
      `${mx2.find((c) => c.id === 'swat-am-mx2')?.name} ${JSON.stringify(cardZ('swat-am-mx2')?.pages)}`);
    // Listed in id order, not the page's: the page's order of these names is
    // ten words of the book, which the leak check below refuses.
    const identZ = ['dr-paolo-hernandez', 'dr-yagami-fuchido', 'general-william-b-braddock', 'jay-atkinson', 'knights-of-genetic-purity',
      'lorelei', 'vincent-scarlesi', 'william-shiver'].map((id) => cardZ(`${id}-mx2`)?.identity.length).join();
    check('MX2: the seven codes-only grids\' identity lines are their cards\' identities, as printed (line_identity), Braddock\'s two U.S. Army over his post, and Lorelei\'s is her real name; no other card has one',
      identZ === '2,2,2,2,1,1,1,1' && cardZ('general-william-b-braddock-mx2')?.identity[0] === 'U.S. Army'
      && cardZ('lorelei-mx2')?.identity.join() === 'Laura Lee Masters'
      && mx2.filter((c) => c.versions[0].identity.length).length === 8,
      `${identZ} ${cardZ('general-william-b-braddock-mx2')?.identity}`);
    const powZ = mx2.flatMap((c) => c.versions[0].powers);
    check('MX2: 61 powers across 8 cards, 18 of them linked to the UPB, Nimrod\'s 13 among them, and Lorelei\'s four, Flight, Pheromones, Blending and Phasing (power_heads)',
      powZ.length === 61 && powZ.filter((p) => p.upb).length === 18 && mx2.filter((c) => c.versions[0].powers.length).length === 8
      && cardZ('nimrod-mx2')?.powers.length === 13
      && cardZ('lorelei-mx2')?.powers.map((p) => p.name).join() === 'Flight,Pheromones,Blending,Phasing',
      `${powZ.length} ${powZ.filter((p) => p.upb).length} ${mx2.filter((c) => c.versions[0].powers.length).length} ${cardZ('lorelei-mx2')?.powers.map((p) => p.name)}`);
    const bookZ = data.npcs.books.find((b) => b.slug === 'mx2');
    check('MX2: the book reads Adventure 10-17, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookZ?.ranges) === '[{"part":"Adventure","pages":[[10,17]]}]'
      && tagline(bookNpc({ character: 'senator-joseph-mcgrafton-mx2' }).snapshot).startsWith('MX2 The X-Potential, Adventure p.10;')
      && tagline(bookNpc({ character: 'william-shiver-mx2' }).snapshot).startsWith('MX2 The X-Potential, Adventure p.16;')
      && mx2.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(bookZ)} ${tagline(bookNpc({ character: 'william-shiver-mx2' }).snapshot)}`);
    // The text verdicts and line_identity move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys and by
    // the overrides' own fragments, never a sentence of the book in this file.
    const sqlZ = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mx2', 'book-text.sql');
    if (!existsSync(sqlZ)) {
      check(`MX2: skipped the text checks: no ${rel(sqlZ) || sqlZ}`, true);
    } else {
      const rowsZ = [...readFileSync(sqlZ, 'utf8').matchAll(/VALUES \('([^']+)', 'mx2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      check('MX2 text: 103 rows over 24 entries, and no row with an odd count of double quotes',
        rowsZ.length === 103 && new Set(rowsZ.map((r) => r.key.split(':')[1])).size === 24
        && !rowsZ.some((r) => (r.body.match(/"/g) || []).length % 2),
        `${rowsZ.length} ${new Set(rowsZ.map((r) => r.key.split(':')[1])).size} ${rowsZ.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)}`);
      const barsZ = rowsZ.filter((r) => r.body.includes('|')).map((r) => r.key.replace(/^mx2:/, ''));
      check('MX2 text: no row carries a vertical bar (three were specks, each read right by a text verdict)', barsZ.length === 0, barsZ.join());
      const countZ = (row, s) => (rowsZ.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsZ = textZ.map((o) => `${o.match.row} ${countZ(o.match.row, o.printed)}/${countZ(o.match.row, o.read)}`);
      check('MX2 text: each of the eight text verdicts is applied, its printed fragment in its row and the misread gone',
        textZ.length === 8 && textZ.every((o) => countZ(o.match.row, o.printed) >= 1 && (o.printed.includes(o.read) || countZ(o.match.row, o.read) === 0)),
        verdictsZ.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10t, Nate
      // 2026-11-03): MX2's one is closed up by the text verdict above, and
      // none is kept on purpose.
      const shapeZ = rowsZ.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mx2:/, ''))).sort();
      check('MX2 text: no row reads a letter, a hyphen and a space before a word',
        rowsZ.length > 0 && shapeZ.length === 0, shapeZ.join(' '));
      // the proofread scan's two misreads (marvel-11 leftovers row 11a, read
      // on the page 2026-11-03): an l for the I of If, and 10-man joined at a
      // line-end break with its hyphen lost. Neither shape is left in any row.
      const proofZ = rowsZ.flatMap((r) => [...r.body.matchAll(/\blf\b|\b10man\b/g)].map((m) => `${r.key.replace(/^mx2:/, '')} ${m[0]}`));
      check('MX2 text: no row reads the proofread misreads, an l for I in lf or 10man joined, and Nimrod\'s and SWAT:AM\'s rows read the page\'s If and 10-man',
        rowsZ.length > 0 && proofZ.length === 0
        && countZ('mx2:nimrod-mx2:power:9', ' If ') === 1 && countZ('mx2:swat-am-mx2:notes', ' 10-man ') === 1,
        `${proofZ.join(' | ')} ${countZ('mx2:nimrod-mx2:power:9', ' If ')} ${countZ('mx2:swat-am-mx2:notes', ' 10-man ')}`);
      // line_identity takes a codes-only grid's identity lines out of its
      // prose: those seven cards have no prose row of their own, and the
      // committee's five each have one, their run-in paragraphs.
      const proseZ = mx2.filter((c) => rowsZ.some((r) => r.key === `mx2:${c.id}:prose`)).map((c) => c.id.replace(/-mx2$/, '')).sort().join();
      check('MX2 text: the prose rows are the committee\'s five run-ins and three grids\' (SWAT:AM, the Soldiers, the Secret Service teams), none of the seven line_identity cards',
        proseZ === ['bob', 'chuck', 'jenny', 'martha', 'phil', 'swat-am', 'secret-service-anti-mutant-teams', 'soldiers-and-camp-guards'].sort().join(),
        proseZ);
    }
  }

  // MX3 is read by scripts/msh/gridbooks.py (mx3-overrides.json), with the
  // survey's decisions applied as it recommends (mx3.md; Nate 2026-10-31).
  // Five cards are chapter opponents (printed 6-27) and six are in the roster
  // section (31-32), all filed under the book's title. The registry fields
  // whose absence roster.py would not stop on (card_names, rank_ranges,
  // code_rows_resources_below, label_line_powers, opponent_indented_paragraphs,
  // extra_titles) are each pinned here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'mx3')) {
    const mx3 = data.npcs.characters.filter((c) => c.book === 'mx3');
    const blocksW = mx3.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blkW = (id) => mx3.find((c) => c.id === id)?.versions[0].blocks[0];
    const cardW = (id) => mx3.find((c) => c.id === id)?.versions[0];
    const playedW = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MX3: 11 characters, each id ending -mx3 with one version and one block, all filed under the book\'s title, and no name starting The',
      mx3.length === 11 && mx3.every((c) => c.id.endsWith('-mx3') && c.versions.length === 1 && c.versions[0].blocks.length === 1)
      && mx3.every((c) => c.team === 'MX3 Reap the Whirlwind') && !mx3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mx3.length} ${[...new Set(mx3.map((c) => c.team))]}`);
    check('MX3: the cards sort by the Adventure page each starts on, 6 to 32, and one page\'s cards by name (npcs.py), so the alpha comes before the Mark VI on printed 32',
      mx3.map((c) => c.id).join() === ['gilda-ginsel', 'bill-gregson', 'marco-pene', 'sebastian-shaw', 'maintenance-robots', 'mark-iv-sentinel',
        'mark-v-sentinel', 'alpha-sentinel', 'mark-vi-sentinel', 'omega-sentinel', 'swat-am'].map((id) => `${id}-mx3`).join(),
      mx3.map((c) => c.id).join());
    check('MX3: ten full blocks and one one-line grid, SWAT:AM\'s, ranks only; no block has a label',
      blocksW.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === 'swat-am-mx3'
      && blkW('swat-am-mx3')?.rank_only === true && blocksW.filter(({ b }) => !b.kind).length === 10
      && !blocksW.some(({ b }) => b.label),
      blocksW.map(({ id, b }) => `${id}:${b.kind}:${b.label}`).join());
    const fixesW = ['gilda-ginsel', 'bill-gregson', 'marco-pene', 'maintenance-robots'].map((s) => {
      const id = `${s}-mx3`;
      const o = blkW(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}${a.corrected ? `>${v(a.corrected)}` : ''}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedW(id)}`;
    });
    check('MX3: the four failing chapter grids keep the printed values and play the sums of their printed numbers (Gilda Ginsel\'s P M(30) as RM, Health 50 as 22, Karma 35 as 55; Bill Gregson 40/20 as 27/25; Marco Pene 55/10 as 61/46; the Maintenance Robots\' Health 35 as 130, their Karma 0 as printed)',
      fixesW.join(' | ') === [
        'gilda-ginsel-mx3 misprint P 30 M>30 Rm also misprint health 50>22 also misprint karma 35>55 plays 22/55',
        'bill-gregson-mx3 misprint health 40>27 also misprint karma 20>25 plays 27/25',
        'marco-pene-mx3 misprint health 55>61 also misprint karma 10>46 plays 61/46',
        'maintenance-robots-mx3 misprint health 35>130 also as_printed karma 0 plays 130/0',
      ].join(' | ')
      && bookNpc({ character: 'gilda-ginsel-mx3' }).snapshot?.abilities.psyche.rank === 'remarkable',
      fixesW.join(' | '));
    check('MX3: Gilda Ginsel\'s P is the one row in the book whose code is unread, so its code is derived from its 30 (unread_codes) and flagged so',
      JSON.stringify(blkW('gilda-ginsel-mx3')?.derived) === '["P"]' && blkW('gilda-ginsel-mx3')?.abilities[6].slice(1).join(' ') === '30 Rm'
      && blocksW.filter(({ b }) => b.derived).length === 1,
      `${JSON.stringify(blkW('gilda-ginsel-mx3')?.derived)} ${blocksW.filter(({ b }) => b.derived).map(({ id }) => id)}`);
    const robotsW = ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'alpha-sentinel', 'omega-sentinel'].map((id) => `${id}-mx3`);
    check('MX3: the five sentinels print Karma 0 against R, I and P printed, kept as printed (as_printed karma) and played as 0',
      robotsW.every((id) => blkW(id)?.override?.verdict === 'as_printed' && blkW(id).override.field === 'karma' && blkW(id).karma === '0')
      && robotsW.map(playedW).join() === '165/0,190/0,250/0,290/0,290/0',
      robotsW.map(playedW).join());
    const ovW = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mx3-overrides.json'), 'utf8')).overrides;
    const textW = ovW.filter((o) => o.verdict === 'text');
    check('MX3: ten overrides: four misprints, five as printed and one text verdict (the alpha\'s Body Armor), and only the nine overridden blocks carry one',
      ovW.length === 10 && ovW.filter((o) => o.verdict === 'misprint').length === 4 && ovW.filter((o) => o.verdict === 'as_printed').length === 5
      && textW.map((o) => o.match.row).join() === 'mx3:alpha-sentinel-mx3:power:4'
      && blocksW.filter(({ b }) => b.override).map(({ id }) => id).sort().join()
        === [...robotsW, ...fixesW.map((f) => f.split(' ')[0])].sort().join(),
      JSON.stringify(ovW.map((o) => [o.verdict, o.match])));
    check('MX3: Sebastian Shaw and SWAT:AM play their printed Health and Karma (100/70, 46/22); Shaw\'s Resources is the IN(40) set under its label, his Popularity 15, and his I reads 20 Ex (code_rows_resources_below)',
      ['sebastian-shaw-mx3', 'swat-am-mx3'].map(playedW).join() === '100/70,46/22'
      && blkW('sebastian-shaw-mx3')?.resources === 'IN(40)' && blkW('sebastian-shaw-mx3')?.popularity === '15'
      && blkW('sebastian-shaw-mx3')?.abilities[5].slice(1).join(' ') === '20 Ex',
      `${['sebastian-shaw-mx3', 'swat-am-mx3'].map(playedW)} ${blkW('sebastian-shaw-mx3')?.resources} ${blkW('sebastian-shaw-mx3')?.abilities[5]}`);
    // rank_ranges: twelve numbers inside their rank's range and off its
    // standard, kept and played as printed (survey decision 5)
    const offW = [['gilda-ginsel', 'strength', 'endurance', 'intuition'], ['bill-gregson', 'fighting', 'agility', 'strength', 'endurance', 'psyche'],
      ['marco-pene', 'fighting', 'endurance', 'intuition'], ['maintenance-robots', 'fighting']]
      .map(([s, ...ab]) => `${s}:${ab.map((a) => bookNpc({ character: `${s}-mx3` }).snapshot?.abilities[a]?.number).join(' ')}`).join();
    check('MX3: the twelve numbers inside a rank\'s range and off its standard play as printed (Gilda Ginsel S 5, E 7, I 15; Bill Gregson F 7, A 5, S 8, E 7, P 5; Marco Pene F 16, E 15, I 16; the Maintenance Robots F 15) (rank_ranges)',
      offW === 'gilda-ginsel:5 7 15,bill-gregson:7 5 8 7 5,marco-pene:16 15 16,maintenance-robots:15', offW);
    check('MX3: SWAT:AM keeps its printed capitals (card_names) on printed 32, and the Alpha Sentinel is named as printed, not as read (speck_lines)',
      mx3.find((c) => c.id === 'swat-am-mx3')?.name === 'SWAT:AM' && JSON.stringify(cardW('swat-am-mx3')?.pages) === '[32]'
      && mx3.find((c) => c.id === 'alpha-sentinel-mx3')?.name === 'Alpha Sentinel',
      `${mx3.find((c) => c.id === 'swat-am-mx3')?.name} ${JSON.stringify(cardW('swat-am-mx3')?.pages)}`);
    const powW = mx3.flatMap((c) => c.versions[0].powers);
    check('MX3: 51 powers across 10 cards, 11 of them linked to the UPB, the Omega\'s nine, the Maintenance Robots\' four opening on Body Armor (label_line_powers), and no card with an identity line',
      powW.length === 51 && powW.filter((p) => p.upb).length === 11 && mx3.filter((c) => c.versions[0].powers.length).length === 10
      && cardW('omega-sentinel-mx3')?.powers.length === 9
      && cardW('maintenance-robots-mx3')?.powers.map((p) => p.name).join() === 'Body Armor,Extra Arms,Corrosive Touch,Energy Touch'
      && !mx3.some((c) => c.versions[0].identity.length),
      `${powW.length} ${powW.filter((p) => p.upb).length} ${mx3.filter((c) => c.versions[0].powers.length).length} ${cardW('maintenance-robots-mx3')?.powers.map((p) => p.name)}`);
    const bookW = data.npcs.books.find((b) => b.slug === 'mx3');
    check('MX3: the book reads Adventure 6-27 and 31-32, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookW?.ranges) === '[{"part":"Adventure","pages":[[6,27],[31,32]]}]'
      && tagline(bookNpc({ character: 'gilda-ginsel-mx3' }).snapshot).startsWith('MX3 Reap the Whirlwind, Adventure p.6;')
      && tagline(bookNpc({ character: 'swat-am-mx3' }).snapshot).startsWith('MX3 Reap the Whirlwind, Adventure p.32;')
      && mx3.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(bookW)} ${tagline(bookNpc({ character: 'gilda-ginsel-mx3' }).snapshot)}`);
    // The text verdict, opponent_indented_paragraphs and extra_titles move
    // only the book's text, which is msh_book_text's: read the generated .sql
    // in the cache, by keys and by the override's own fragments, never a
    // sentence of the book in this file.
    const sqlW = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mx3', 'book-text.sql');
    if (!existsSync(sqlW)) {
      check(`MX3: skipped the text checks: no ${rel(sqlW) || sqlW}`, true);
    } else {
      const rowsW = [...readFileSync(sqlW, 'utf8').matchAll(/VALUES \('([^']+)', 'mx3', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const markedW = rowsW.filter((r) => /["']/.test(r.body));
      const nW = (re) => rowsW.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MX3 text: 67 rows over 11 entries, no row with an odd count of double quotes, and the marks row 6b read on the page: 13 rows hold one, four double-quoted pairs and 27 apostrophes',
        rowsW.length === 67 && new Set(rowsW.map((r) => r.key.split(':')[1])).size === 11
        && !rowsW.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedW.length === 13 && nW(/"/g) === 8 && nW(/'/g) === 27,
        `${rowsW.length} ${new Set(rowsW.map((r) => r.key.split(':')[1])).size} ${markedW.length} ${nW(/"/g)} ${nW(/'/g)}`);
      const barsW = rowsW.filter((r) => /[|\\]/.test(r.body)).map((r) => r.key.replace(/^mx3:/, ''));
      check('MX3 text: no row carries a vertical bar or a backslash (the alpha\'s Body Armor read one, set right by its text verdict)', barsW.length === 0, barsW.join());
      const countW = (row, s) => (rowsW.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MX3 text: the one text verdict is applied, its printed fragment once in its row and the misread gone',
        textW.length === 1 && textW.every((o) => countW(o.match.row, o.printed) === 1 && countW(o.match.row, o.read) === 0),
        textW.map((o) => `${o.match.row} ${countW(o.match.row, o.printed)}/${countW(o.match.row, o.read)}`).join());
      // Where an entry's text ends, each read on the page (survey mx3.md): an
      // extra_titles subhead ends Gilda Ginsel's, Marco Pene's, Sebastian
      // Shaw's and the Maintenance Robots' text, and Marco's and Shaw's own
      // indented paragraphs do not (opponent_indented_paragraphs).
      const bodyW = (row) => rowsW.find((r) => r.key === row)?.body || '';
      const partsW = (s) => rowsW.filter((r) => r.key.startsWith(`mx3:${s}-mx3:`)).map((r) => r.key.split(':').slice(2).join(':')).sort().join();
      check('MX3 text: the Maintenance Robots\' Energy Touch ends on "level." before The Assembly-line, no row runs into a chapter subhead, and Marco Pene and Sebastian Shaw keep their Talents, Contacts and Background',
        /level\.$/.test(bodyW('mx3:maintenance-robots-mx3:power:4')) && bodyW('mx3:maintenance-robots-mx3:power:4').length === 61
        && !rowsW.some((r) => /Assembly-line|Away We Go|Under Attack|Summer Camp/.test(r.body))
        && /prey\.$/.test(bodyW('mx3:marco-pene-mx3:background')) && /factory\.$/.test(bodyW('mx3:sebastian-shaw-mx3:background'))
        && partsW('marco-pene') === 'background,contacts,power:1,power:2,talents'
        && partsW('sebastian-shaw') === 'background,contacts,power:1,talents',
        `${bodyW('mx3:maintenance-robots-mx3:power:4').length} ${partsW('marco-pene')} | ${partsW('sebastian-shaw')}`);
      check('MX3 text: Gilda Ginsel\'s Background keeps its run-in as printed, which points back to the chapter\'s prose (decision 6), and only SWAT:AM has a prose row',
        bodyW('mx3:gilda-ginsel-mx3:background') === 'See above.'
        && rowsW.filter((r) => r.key.endsWith(':prose')).map((r) => r.key).join() === 'mx3:swat-am-mx3:prose',
        `${bodyW('mx3:gilda-ginsel-mx3:background')} ${rowsW.filter((r) => r.key.endsWith(':prose')).map((r) => r.key)}`);
    }
  }

  // MX4 is read by scripts/msh/gridbooks.py (mx4-overrides.json), with the
  // survey's decisions applied as it recommends (mx4.md; Nate 2026-10-31).
  // Its two appendices hold every card: the six sentinels (printed 25-26) and
  // seven NPCs (27-31), all filed under the book's title. The registry fields
  // whose absence roster.py would not stop on (rank_ranges, speck_lines,
  // extra_titles, identity_lines, wrapped_alternates, override_values) are
  // each pinned here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'mx4')) {
    const mx4 = data.npcs.characters.filter((c) => c.book === 'mx4');
    const blocksQ = mx4.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ id: c.id, b }))));
    const blkQ = (id) => mx4.find((c) => c.id === id)?.versions[0].blocks[0];
    const cardQ = (id) => mx4.find((c) => c.id === id)?.versions[0];
    const playedQ = (id) => { const s = bookNpc({ character: id }).snapshot; return `${s?.health}/${s?.karma}`; };
    const sentinelsQ = ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'alpha-sentinel', 'omega-sentinel', 'nimrod'].map((s) => `${s}-mx4`);
    check('MX4: 13 characters, each id ending -mx4 with one version and one block, all filed under the book\'s title, and no name starting The',
      mx4.length === 13 && mx4.every((c) => c.id.endsWith('-mx4') && c.versions.length === 1 && c.versions[0].blocks.length === 1)
      && mx4.every((c) => c.team === 'MX4 Flames of Doom') && !mx4.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mx4.length} ${[...new Set(mx4.map((c) => c.team))]}`);
    check('MX4: the cards sort by the Adventure page each starts on, 25 to 30, and one page\'s cards by name (npcs.py), so the Alpha comes before the Mark IV on printed 25',
      mx4.map((c) => c.id).join() === ['alpha-sentinel', 'mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'nimrod', 'omega-sentinel',
        'cannonball', 'lila-cheney', 'magma', 'mirage', 'mystique', 'marco-pene', 'sunspot'].map((id) => `${id}-mx4`).join(),
      mx4.map((c) => c.id).join());
    check('MX4: 13 full blocks, none a one-line grid, none ranks only and none with a label',
      blocksQ.length === 13 && blocksQ.every(({ b }) => !b.kind && !b.rank_only && !b.label),
      blocksQ.map(({ id, b }) => `${id}:${b.kind}:${b.rank_only}:${b.label}`).join());
    const fixesQ = ['alpha-sentinel', 'nimrod', 'cannonball', 'lila-cheney', 'magma', 'mirage', 'marco-pene', 'sunspot'].map((s) => {
      const id = `${s}-mx4`;
      const o = blkQ(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}${a.corrected ? `>${v(a.corrected)}` : ''}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedQ(id)}`;
    });
    check('MX4: the eight misprinted blocks keep the printed values and play the sums of their printed numbers (the Alpha\'s Health 250 as 290; Nimrod\'s R 30 Ex, I 30 Gd and P 10 Ty as Rm, Rm and Gd; Karma 10 as 40 for Cannonball, 20 as 40 for Lila Cheney; Magma 100/60 as 86/70; Mirage 80/20 as 90/70; Marco Pene 35/60 as 61/46; Sunspot\'s Karma 30 as 46)',
      fixesQ.join(' | ') === [
        'alpha-sentinel-mx4 misprint health 250>290 also as_printed karma 0 plays 290/0',
        'nimrod-mx4 misprint R 30 Ex>30 Rm also misprint I 30 Gd>30 Rm also misprint P 10 Ty>10 Gd plays 300/70',
        'cannonball-mx4 misprint karma 10>40 plays 90/40',
        'lila-cheney-mx4 misprint karma 20>40 plays 66/40',
        'magma-mx4 misprint health 100>86 also misprint karma 60>70 plays 86/70',
        'mirage-mx4 misprint health 80>90 also misprint karma 20>70 plays 90/70',
        'marco-pene-mx4 misprint health 35>61 also misprint karma 60>46 plays 61/46',
        'sunspot-mx4 misprint karma 30>46 plays 76/46',
      ].join(' | ')
      && ['reason', 'intuition', 'psyche'].map((a) => bookNpc({ character: 'nimrod-mx4' }).snapshot?.abilities[a]?.rank).join() === 'remarkable,remarkable,good',
      `${fixesQ.join(' | ')} ${['reason', 'intuition', 'psyche'].map((a) => bookNpc({ character: 'nimrod-mx4' }).snapshot?.abilities[a]?.rank)}`);
    const robotsQ = ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel', 'omega-sentinel'].map((id) => `${id}-mx4`);
    check('MX4: the four other sentinels print Karma 0 against R, I and P printed, kept as printed (as_printed karma) and played as 0, and Nimrod prints his',
      robotsQ.every((id) => blkQ(id)?.override?.verdict === 'as_printed' && blkQ(id).override.field === 'karma' && blkQ(id).karma === '0')
      && robotsQ.map(playedQ).join() === '165/0,190/0,250/0,290/0' && blkQ('nimrod-mx4')?.karma === '70',
      robotsQ.map(playedQ).join());
    check('MX4: Mystique\'s Karma prints 150* against R, I and P of 90, kept as printed (as_printed karma), and she plays 90/150',
      blkQ('mystique-mx4')?.karma === '150*' && blkQ('mystique-mx4')?.override?.verdict === 'as_printed'
      && blkQ('mystique-mx4').override.field === 'karma' && playedQ('mystique-mx4') === '90/150',
      `${blkQ('mystique-mx4')?.karma} ${playedQ('mystique-mx4')}`);
    const ovQ = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mx4-overrides.json'), 'utf8')).overrides;
    check('MX4: seventeen overrides, eight misprints, five as printed and four text verdicts (two on Magma\'s fourth power, its two minuses read on PDF 29, and two proofread misreads, Mirage\'s first power and Marco Pene\'s background), and every block carries one',
      ovQ.length === 17 && ovQ.filter((o) => o.verdict === 'misprint').length === 8 && ovQ.filter((o) => o.verdict === 'as_printed').length === 5
      && ovQ.filter((o) => o.verdict === 'text').map((o) => o.match.row).join()
        === ['magma-mx4:power:4', 'magma-mx4:power:4', 'mirage-mx4:power:1', 'marco-pene-mx4:background'].map((k) => `mx4:${k}`).join()
      && blocksQ.every(({ b }) => b.override),
      JSON.stringify(ovQ.map((o) => [o.verdict, o.match])));
    // rank_ranges: five numbers inside their rank's range and off its
    // standard, kept and played as printed (survey decision 6)
    const offQ = [['magma', 'fighting'], ['marco-pene', 'fighting', 'endurance', 'intuition'], ['sunspot', 'reason']]
      .map(([s, ...ab]) => `${s}:${ab.map((a) => bookNpc({ character: `${s}-mx4` }).snapshot?.abilities[a]?.number).join(' ')}`).join();
    check('MX4: the five numbers inside a rank\'s range and off its standard play as printed (Magma F 16; Marco Pene F 16, E 15, I 16; Sunspot R 16) (rank_ranges)',
      offQ === 'magma:16,marco-pene:16 15 16,sunspot:16', offQ);
    check('MX4: Cannonball\'s and Sunspot\'s Strength keep their bracketed alternates (10 Gd (30 Rm), 6 Ty (40 In)) on the S row, Cannonball\'s joined back from the line below (wrapped_alternates)',
      blkQ('cannonball-mx4')?.abilities[2].join(' ') === 'S 10 Gd 30,Rm' && blkQ('sunspot-mx4')?.abilities[2].join(' ') === 'S 6 Ty 40,In'
      && blkQ('cannonball-mx4')?.abilities[3].join(' ') === 'E 40 In',
      `${blkQ('cannonball-mx4')?.abilities.map((a) => a.join(' '))} | ${blkQ('sunspot-mx4')?.abilities[2]}`);
    check('MX4: Nimrod\'s Resources reads In (40) across its wrap, Cannonball\'s Pr (Ex) and Lila Cheney\'s Pr (In); Cannonball and Mirage print Popularity -10',
      blkQ('nimrod-mx4')?.resources === 'In (40)' && blkQ('cannonball-mx4')?.resources === 'Pr (Ex)' && blkQ('lila-cheney-mx4')?.resources === 'Pr (In)'
      && blkQ('cannonball-mx4')?.popularity === '-10' && blkQ('mirage-mx4')?.popularity === '-10',
      ['nimrod', 'cannonball', 'lila-cheney', 'mirage'].map((s) => `${s} ${blkQ(`${s}-mx4`)?.resources} ${blkQ(`${s}-mx4`)?.popularity}`).join());
    check('MX4: the Mark IV, V and VI are named as printed, not as read (speck_lines), and the six sentinels print no identity line',
      ['mark-iv-sentinel', 'mark-v-sentinel', 'mark-vi-sentinel'].map((s) => mx4.find((c) => c.id === `${s}-mx4`)?.name).join() === 'Mark IV Sentinel,Mark V Sentinel,Mark VI Sentinel'
      && sentinelsQ.every((id) => !cardQ(id)?.identity.length),
      `${mx4.map((c) => c.name)} ${sentinelsQ.map((id) => cardQ(id)?.identity.length)}`);
    const idQ = (s) => cardQ(`${s}-mx4`)?.identity || [];
    check('MX4: each NPC keeps its identity run whole as one line, Mystique\'s of four printed lines and Sunspot\'s of three among them (identity_lines)',
      ['cannonball', 'lila-cheney', 'magma', 'mirage', 'mystique', 'marco-pene', 'sunspot'].every((s) => idQ(s).length === 1 && /, Mutant$/.test(idQ(s)[0]))
      && idQ('mystique')[0].startsWith('Raven Darkholme, Member of Project Wideawake and DARPA') && idQ('sunspot')[0].startsWith('Roberto Da Costa, ex-New Mutant, Leader'),
      ['cannonball', 'lila-cheney', 'magma', 'mirage', 'mystique', 'marco-pene', 'sunspot'].map((s) => JSON.stringify(idQ(s))).join(' '));
    const powQ = mx4.flatMap((c) => c.versions[0].powers);
    check('MX4: 70 powers across 13 cards, 17 of them linked to the UPB, Nimrod\'s 15, and Mystique\'s Weapons among her powers (decision 5)',
      powQ.length === 70 && powQ.filter((p) => p.upb).length === 17 && mx4.every((c) => c.versions[0].powers.length)
      && cardQ('nimrod-mx4')?.powers.length === 15 && cardQ('mystique-mx4')?.powers.some((p) => p.name === 'Weapons'),
      `${powQ.length} ${powQ.filter((p) => p.upb).length} ${cardQ('nimrod-mx4')?.powers.length} ${cardQ('mystique-mx4')?.powers.map((p) => p.name)}`);
    const bookQ = data.npcs.books.find((b) => b.slug === 'mx4');
    check('MX4: the book reads Adventure 25-31, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookQ?.ranges) === '[{"part":"Adventure","pages":[[25,31]]}]'
      && tagline(bookNpc({ character: 'alpha-sentinel-mx4' }).snapshot).startsWith('MX4 Flames of Doom, Adventure p.25;')
      && tagline(bookNpc({ character: 'sunspot-mx4' }).snapshot).startsWith('MX4 Flames of Doom, Adventure p.30;')
      && mx4.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(bookQ)} ${tagline(bookNpc({ character: 'sunspot-mx4' }).snapshot)}`);
    // The quote marks, extra_titles and the section labels move only the
    // book's text, which is msh_book_text's: read the generated .sql in the
    // cache, by keys and counts, never a sentence of the book in this file.
    const sqlQ = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mx4', 'book-text.sql');
    if (!existsSync(sqlQ)) {
      check(`MX4: skipped the text checks: no ${rel(sqlQ) || sqlQ}`, true);
    } else {
      const rowsQ = [...readFileSync(sqlQ, 'utf8').matchAll(/VALUES \('([^']+)', 'mx4', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const markedQ = rowsQ.filter((r) => /["']/.test(r.body));
      const nQ = (re) => rowsQ.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MX4 text: 91 rows over 13 entries, no row with an odd count of double quotes, and the marks row 9b read on the page: 14 rows hold 26, three double-quoted pairs and 20 singles (19 apostrophes and one elision)',
        rowsQ.length === 91 && new Set(rowsQ.map((r) => r.key.split(':')[1])).size === 13
        && !rowsQ.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedQ.length === 14 && nQ(/"/g) === 6 && nQ(/'/g) === 20,
        `${rowsQ.length} ${new Set(rowsQ.map((r) => r.key.split(':')[1])).size} ${markedQ.length} ${nQ(/"/g)} ${nQ(/'/g)}`);
      const barsQ = rowsQ.filter((r) => /[|\\]/.test(r.body)).map((r) => r.key.replace(/^mx4:/, ''));
      check('MX4 text: no row carries a vertical bar or a backslash', barsQ.length === 0, barsQ.join());
      // Magma's fourth power prints two minuses set against their digits
      // (printed 28, PDF 29); the OCR left each a double space and a spaced
      // dash, and two text verdicts close them up.
      const magmaQ = rowsQ.find((r) => r.key === 'mx4:magma-mx4:power:4')?.body || '';
      check('MX4 text: Magma\'s fourth power holds no double space, and its two minuses sit against their digits (-1 CS, -3 CS)',
        magmaQ !== '' && !magmaQ.includes('  ') && (magmaQ.match(/ -[13] CS/g) || []).join() === ' -1 CS, -3 CS',
        `${magmaQ.indexOf('  ')} ${(magmaQ.match(/ -?\s*-?\s*[13] CS/g) || []).join('|')}`);
      // the proofread scan's two misreads (marvel-11 leftovers row 11b, read
      // on the page 2026-11-03): vision-enhancing joined at a line-end break
      // with its hyphen lost, and SWAT:AM broken after its A and kept as a
      // hyphen and a space. Neither shape is left in any row.
      const countQ = (row, s) => (rowsQ.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const proofQ = rowsQ.flatMap((r) => [...r.body.matchAll(/visionenhancing|SWA- T:AM/g)].map((m) => `${r.key.replace(/^mx4:/, '')} ${m[0]}`));
      check('MX4 text: no row reads the proofread misreads, visionenhancing joined or SWA- T:AM broken, and Mirage\'s and Marco Pene\'s rows read the page\'s vision-enhancing and SWAT:AM',
        rowsQ.length > 0 && proofQ.length === 0
        && countQ('mx4:mirage-mx4:power:1', 'vision-enhancing') === 1 && countQ('mx4:marco-pene-mx4:background', 'SWAT:AM') === 1,
        `${proofQ.join(' | ')} ${countQ('mx4:mirage-mx4:power:1', 'vision-enhancing')} ${countQ('mx4:marco-pene-mx4:background', 'SWAT:AM')}`);
      // Where an entry's text ends, each read on the page (survey mx4.md):
      // The Hardware of Hell (extra_titles) ends Sunspot's on printed 31, the
      // sentinels print Known Powers only, Mirage's Equipment is her notes and
      // Mystique's footnote her prose; Marco Pene prints no Contacts and
      // Mystique no Background.
      const partsQ = (s) => rowsQ.filter((r) => r.key.startsWith(`mx4:${s}-mx4:`)).map((r) => r.key.split(':').slice(2).join(':')).filter((k) => !k.startsWith('power:')).join();
      const nPowQ = (s) => rowsQ.filter((r) => r.key.startsWith(`mx4:${s}-mx4:power:`)).length;
      check('MX4 text: Sunspot\'s text ends before The Hardware of Hell, no row runs into an appendix title, and each entry\'s sections are the ones it prints',
        !rowsQ.some((r) => /Hardware of Hell|Arm of the State|Non-Player Characters/.test(r.body))
        && sentinelsQ.every((id) => partsQ(id.replace(/-mx4$/, '')) === '')
        && ['cannonball', 'lila-cheney', 'magma', 'mirage', 'mystique', 'marco-pene', 'sunspot'].map(partsQ).join(' | ')
          === 'talents,contacts,background | talents,contacts,background | talents,contacts,background | talents,contacts,background,notes | talents,contacts,prose | talents,background | talents,contacts,background'
        && mx4.every((c) => nPowQ(c.id.replace(/-mx4$/, '')) === c.versions[0].powers.length),
        `${['cannonball', 'lila-cheney', 'magma', 'mirage', 'mystique', 'marco-pene', 'sunspot'].map(partsQ).join(' | ')} ${mx4.map((c) => `${c.id}:${nPowQ(c.id.replace(/-mx4$/, ''))}/${c.versions[0].powers.length}`).join()}`);
    }
  }

  // MLA1 is read by scripts/msh/gridbooks.py (mla1-overrides.json), with the
  // survey's decisions applied as it recommends (mla1.md; Nate 2026-10-31).
  // Its cards are in the Adventure Book: the six Player Characters and five
  // faction grids (printed 4-8), the chapters' seven grids (18-42) and the
  // roster (51-63). The registry fields whose absence roster.py would not
  // stop on (teams, inner_grids, label_powers, speck_lines, identity_lines,
  // card_names, derived_totals, opponent_section_labels, extra_titles) are
  // each pinned here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'mla1')) {
    const mla1 = data.npcs.characters.filter((c) => c.book === 'mla1');
    const blocksL = mla1.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkL = (id, i = 0) => mla1.find((c) => c.id === id)?.versions[0].blocks[i];
    const cardL = (id) => mla1.find((c) => c.id === id)?.versions[0];
    const teamL = (t) => mla1.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedL = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MLA1: 47 characters, each id ending -mla1 with one version, the six Player Characters as After Midnight Heroes and 41 under the book\'s title, and no name starting The (teams)',
      mla1.length === 47 && mla1.every((c) => c.id.endsWith('-mla1') && c.versions.length === 1)
      && teamL('After Midnight Heroes') === 'Black Widow,Daredevil,Iron Fist,Moon Knight,Power Man,Spider-Man'
      && mla1.filter((c) => c.team === 'MLA1 After Midnight').length === 41
      && !mla1.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mla1.length} ${[...new Set(mla1.map((c) => c.team))]}`);
    check('MLA1: the cards sort by the Adventure page each starts on, 4 to 63, the chapters\' grids between the factions and the roster',
      mla1.map((c) => c.id).join() === ['black-widow', 'daredevil', 'iron-fist', 'moon-knight', 'power-man', 'spider-man', 'typical-batboy',
        'typical-crimson-smile', 'typical-maggia-thug', 'typical-buzz-cut', 'typical-flashing-blade', 'jack-the-bartender', 'swf-operatives',
        'security-officers', 'bartholomew-jacobs', 'alligator', 'mosquito-swarm', 'rat-pack-of-10', 'arclight', 'bifrost-felicia', 'bifrost-johnny',
        'black-panther', 'black-talon', 'black-talon-s-skeleton', 'black-talon-s-zombie', 'blacklash', 'boomerang', 'brothers-grimm', 'callisto', 'eel',
        'fixer', 'frankenstein-s-monster', 'gypsy-moth', 'hammerhead', 'harpoon', 'mentallo', 'mister-fear', 'pride-mr-maximilian', 'scarecrow',
        'scorpion', 'sentinels-mark-iv', 'shroud', 'skids', 'tatterdemalion', 'vertigo', 'werewolf', 'whirlwind'].map((id) => `${id}-mla1`).join(),
      mla1.map((c) => c.id).join());
    check('MLA1: 48 blocks: the Werewolf\'s two forms labelled (Werewolf, Jack Russell), Bartholomew Jacobs\'s R, I and P only, and no one-line grid and no ranks-only block',
      blocksL.length === 48
      && blocksL.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'werewolf-mla1:Werewolf,werewolf-mla1:Jack Russell'
      && blocksL.filter(({ b }) => b.kind).map(({ id, b }) => `${id}:${b.kind}`).join() === 'bartholomew-jacobs-mla1:partial'
      && !blocksL.some(({ b }) => b.rank_only),
      blocksL.filter(({ b }) => b.kind || b.label || b.rank_only).map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}`).join());
    const fixesL = ['typical-buzz-cut', 'typical-flashing-blade', 'black-talon-s-zombie', 'eel', 'sentinels-mark-iv', 'tatterdemalion'].map((s) => {
      const id = `${s}-mla1`;
      const o = blkL(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` also ${a.verdict} ${a.field} ${v(a.printed)}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}${o?.corrected !== undefined ? `>${v(o.corrected)}` : ''}${also} plays ${playedL(id)}`;
    });
    check('MLA1: the three misprints keep the printed Karma and play the sum of R, I and P (the Typical Buzz Cut 11 as 12, Eel 22 as 32, Tatterdemalion 8 as 12), and the three as printed play as the page gives them (the Flashing Blade\'s A 12 and E 7, the zombie\'s Health 80, the Sentinels\' Karma NA)',
      fixesL.join(' | ') === [
        'typical-buzz-cut-mla1 misprint karma 11>12 plays 28/12',
        'typical-flashing-blade-mla1 as_printed A 12 Gd also as_printed E 7 Ty plays 31/16',
        'black-talon-s-zombie-mla1 as_printed health 80 plays 80/0',
        'eel-mla1 misprint karma 22>32 plays 76/32',
        'sentinels-mark-iv-mla1 as_printed karma NA plays 165/null',
        'tatterdemalion-mla1 misprint karma 8>12 plays 70/12',
      ].join(' | '),
      fixesL.join(' | '));
    const ovL = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mla1-overrides.json'), 'utf8')).overrides;
    const textL = ovL.filter((o) => o.verdict === 'text');
    check('MLA1: 35 overrides: three misprints, three as printed, the Werewolf\'s human label, Bartholomew Jacobs\'s rows and 27 text verdicts (the Flashing Blade\'s Talents, twelve letter misreads read on the page, two line-end compound hyphens, Spider-Sense and Shift-Zero, whose printed fragment keeps the hyphen and drops the space, and twelve proofread misreads: seven line-end compounds joined with the hyphen lost, and five glyph or space misreads), and only seven blocks carry one',
      ovL.length === 35 && ovL.filter((o) => o.verdict === 'misprint').length === 3 && ovL.filter((o) => o.verdict === 'as_printed').length === 3
      && ovL.filter((o) => o.verdict === 'label').length === 1 && ovL.filter((o) => o.verdict === 'rows').length === 1
      && textL.map((o) => o.match.row.replace(/^mla1:/, '')).join() === ['typical-flashing-blade-mla1:talents', 'iron-fist-mla1:power:1',
        'iron-fist-mla1:background', 'power-man-mla1:power:1', 'power-man-mla1:background', 'power-man-mla1:background',
        'bifrost-felicia-mla1:power:1', 'blacklash-mla1:power:2', 'blacklash-mla1:background', 'sentinels-mark-iv-mla1:power:1',
        'werewolf-mla1:power:7', 'werewolf-mla1:power:7', 'whirlwind-mla1:power:2', 'spider-man-mla1:power:4', 'black-talon-mla1:power:1',
        'black-widow-mla1:powers-intro', 'blacklash-mla1:background', 'callisto-mla1:talents', 'tatterdemalion-mla1:background',
        'tatterdemalion-mla1:talents', 'bifrost-johnny-mla1:power:1', 'iron-fist-mla1:background', 'tatterdemalion-mla1:power:2',
        'vertigo-mla1:power:1', 'werewolf-mla1:power:6', 'moon-knight-mla1:power:3', 'iron-fist-mla1:power:1'].join()
      && textL.slice(13, 15).every((o) => o.printed === o.read.replace(/([a-z])- ([A-Z])/, '$1-$2'))
      && blocksL.filter(({ b }) => b.override).map(({ id }) => id).join()
        === ['typical-buzz-cut', 'typical-flashing-blade', 'bartholomew-jacobs', 'black-talon-s-zombie', 'eel', 'sentinels-mark-iv', 'tatterdemalion'].map((s) => `${s}-mla1`).join(),
      `${JSON.stringify(ovL.map((o) => [o.verdict, o.match]))} ${blocksL.filter(({ b }) => b.override).map(({ id }) => id)}`);
    check('MLA1: Bartholomew Jacobs prints R 30, I 10, P 75 and Karma 115 only, so F, A, S and E and his Health are left to the GM (rows)',
      blkL('bartholomew-jacobs-mla1')?.abilities.map((a) => a.slice(1).filter((x) => x !== null).join(' ')).join() === ',,,,30 Rm,10 Gd,75 Mn'
      && blkL('bartholomew-jacobs-mla1')?.karma === '115' && blkL('bartholomew-jacobs-mla1')?.health === null
      && playedL('bartholomew-jacobs-mla1') === 'null/115',
      `${blkL('bartholomew-jacobs-mla1')?.abilities.map((a) => a.join(' '))} ${playedL('bartholomew-jacobs-mla1')}`);
    check('MLA1: the Alligator, the Rat, pack of 10 and the Mosquito Swarm print no Karma, so theirs is derived from their rows (6) and flagged so, and no other MLA1 block is (derived_totals)',
      blocksL.filter(({ b }) => b.karma_derived || b.health_derived).map(({ id }) => id).join() === 'alligator-mla1,mosquito-swarm-mla1,rat-pack-of-10-mla1'
      && ['alligator', 'mosquito-swarm', 'rat-pack-of-10'].every((s) => blkL(`${s}-mla1`)?.karma_derived === true && !blkL(`${s}-mla1`)?.health_derived)
      && ['alligator', 'mosquito-swarm', 'rat-pack-of-10'].map((s) => playedL(`${s}-mla1`)).join() === '64/6,44/6,48/6',
      `${blocksL.filter(({ b }) => b.karma_derived || b.health_derived).map(({ id }) => id)} ${['alligator', 'mosquito-swarm', 'rat-pack-of-10'].map((s) => playedL(`${s}-mla1`))}`);
    check('MLA1: the Black Talon\'s zombie and skeleton are cards of their own, R, I and P each Sh-0 (Shift 0), Resources NA, and the text stays his (grid_cards, dash_shift_codes)',
      ['zombie', 'skeleton'].every((s) => blkL(`black-talon-s-${s}-mla1`)?.abilities.slice(4).map((a) => a.slice(1).join(' ')).join() === '0 Sh0,0 Sh0,0 Sh0'
        && blkL(`black-talon-s-${s}-mla1`)?.resources === 'NA')
      && bookNpc({ character: 'black-talon-s-skeleton-mla1' }).snapshot?.abilities.reason.rank === 'shift-0'
      && playedL('black-talon-s-skeleton-mla1') === '40/0',
      `${blkL('black-talon-s-zombie-mla1')?.abilities.map((a) => a.join(' '))} ${playedL('black-talon-s-skeleton-mla1')}`);
    check('MLA1: Spider-Man\'s Popularity prints 30/6, Frankenstein\'s Monster\'s Resources None, Johnny Bifrost\'s P reads Ty past its speck (code_row_specks), Mister Fear\'s Karma 40 past its mark (trailing_marks) and the Fixer\'s Health 32 past its dash (dash_marks)',
      blkL('spider-man-mla1')?.popularity === '30/6' && blkL('frankenstein-s-monster-mla1')?.resources === 'None'
      && blkL('bifrost-johnny-mla1')?.abilities[6].slice(1).join(' ') === '6 Ty'
      && blkL('mister-fear-mla1')?.karma === '40' && String(blkL('fixer-mla1')?.health) === '32',
      `${blkL('spider-man-mla1')?.popularity} ${blkL('frankenstein-s-monster-mla1')?.resources} ${blkL('bifrost-johnny-mla1')?.abilities[6]} ${blkL('mister-fear-mla1')?.karma} ${blkL('fixer-mla1')?.health}`);
    check('MLA1: the cards play their printed Health and Karma (Black Widow 100/70, Daredevil 110/91, Spider-Man 160/70, Jack the Bartender 40/14, Security Officers 36/18, Black Panther 140/60, the Werewolf 120/91 and as Jack Russell 28/26, Whirlwind 90/18)',
      [['black-widow-mla1'], ['daredevil-mla1'], ['spider-man-mla1'], ['jack-the-bartender-mla1'], ['security-officers-mla1'], ['black-panther-mla1'],
        ['werewolf-mla1', 0], ['werewolf-mla1', 1], ['whirlwind-mla1']].map(([id, b]) => playedL(id, b)).join()
        === '100/70,110/91,160/70,40/14,36/18,140/60,120/91,28/26,90/18',
      [['black-widow-mla1'], ['daredevil-mla1'], ['spider-man-mla1'], ['jack-the-bartender-mla1'], ['security-officers-mla1'], ['black-panther-mla1'],
        ['werewolf-mla1', 0], ['werewolf-mla1', 1], ['whirlwind-mla1']].map(([id, b]) => playedL(id, b)).join());
    const powL = mla1.flatMap((c) => c.versions[0].powers);
    check('MLA1: 103 powers across 32 cards, 19 of them linked to the UPB, the Werewolf\'s seven past his human grid (inner_grids) and the Whirlwind\'s Weaponry among his two (label_powers)',
      powL.length === 103 && powL.filter((p) => p.upb).length === 19 && mla1.filter((c) => c.versions[0].powers.length).length === 32
      && cardL('werewolf-mla1')?.powers.length === 7
      && cardL('whirlwind-mla1')?.powers.map((p) => p.name).join() === 'Spinning,Weaponry',
      `${powL.length} ${powL.filter((p) => p.upb).length} ${mla1.filter((c) => c.versions[0].powers.length).length} ${cardL('werewolf-mla1')?.powers.length} ${cardL('whirlwind-mla1')?.powers.map((p) => p.name)}`);
    const idL = (s) => JSON.stringify(cardL(`${s}-mla1`)?.identity || []);
    check('MLA1: names and identity lines as printed: Iron Fist (speck_lines), SWF Operatives and Frankenstein\'s Monster (card_names), Black Widow\'s and the Brothers Grimm\'s wrapped lines joined (identity_lines), and Blacklash\'s and the Monster\'s without the OCR\'s stop and lone quote (speck_lines)',
      ['iron-fist', 'swf-operatives', 'frankenstein-s-monster'].map((s) => mla1.find((c) => c.id === `${s}-mla1`)?.name).join() === 'Iron Fist,SWF Operatives,Frankenstein\'s Monster'
      && idL('black-widow') === '["Real Name: Natalia Alianova Romanova"]' && idL('brothers-grimm') === '["Real Names: Percy and Barton Grimes"]'
      && idL('blacklash') === '["Real Name: Mark Scarlotti"]' && idL('frankenstein-s-monster') === '["Real Name: \\"Adam\\""]'
      && !idL('bifrost-johnny').includes('Name'),
      `${['iron-fist', 'swf-operatives', 'frankenstein-s-monster'].map((s) => mla1.find((c) => c.id === `${s}-mla1`)?.name)} ${['black-widow', 'brothers-grimm', 'blacklash', 'frankenstein-s-monster'].map(idL).join(' ')}`);
    const bookL = data.npcs.books.find((b) => b.slug === 'mla1');
    check('MLA1: the book reads Adventure 4-8, 18-42 and 51-63, a card cites its Adventure page, and every card is one GM choice but the Werewolf\'s two and Bartholomew Jacobs\'s none (a partial grid is on the Codex card only)',
      JSON.stringify(bookL?.ranges) === '[{"part":"Adventure","pages":[[4,8],[18,42],[51,63]]}]'
      && tagline(bookNpc({ character: 'black-widow-mla1' }).snapshot).startsWith('MLA1 After Midnight, Adventure p.4;')
      && tagline(bookNpc({ character: 'jack-the-bartender-mla1' }).snapshot).startsWith('MLA1 After Midnight, Adventure p.18;')
      && tagline(bookNpc({ character: 'whirlwind-mla1' }).snapshot).startsWith('MLA1 After Midnight, Adventure p.63;')
      && mla1.every((c) => choices.filter((x) => x.character === c.id).length === ({ 'werewolf-mla1': 2, 'bartholomew-jacobs-mla1': 0 }[c.id] ?? 1)),
      `${JSON.stringify(bookL?.ranges)} ${tagline(bookNpc({ character: 'jack-the-bartender-mla1' }).snapshot)} ${mla1.map((c) => `${c.id}:${choices.filter((x) => x.character === c.id).length}`).filter((s) => !s.endsWith(':1'))}`);
    // The text verdict, the quote marks and the section labels move only the
    // book's text, which is msh_book_text's: read the generated .sql in the
    // cache, by keys and counts, never a sentence of the book in this file.
    const sqlL = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mla1', 'book-text.sql');
    if (!existsSync(sqlL)) {
      check(`MLA1: skipped the text checks: no ${rel(sqlL) || sqlL}`, true);
    } else {
      const rowsL = [...readFileSync(sqlL, 'utf8').matchAll(/VALUES \('([^']+)', 'mla1', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entL = new Set(rowsL.map((r) => r.key.split(':')[1]));
      const nL = (re) => rowsL.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MLA1 text: 189 rows over 43 entries (Bartholomew Jacobs and the Alligator print none, the zombie\'s and skeleton\'s is the Black Talon\'s), no row with an odd count of double quotes, and the marks row 12b read on the page: 50 rows hold 115, twelve double-quoted pairs and 91 apostrophes',
        rowsL.length === 189 && entL.size === 43
        && mla1.filter((c) => !entL.has(c.id)).map((c) => c.id).join() === 'bartholomew-jacobs-mla1,alligator-mla1,black-talon-s-skeleton-mla1,black-talon-s-zombie-mla1'
        && !rowsL.some((r) => (r.body.match(/"/g) || []).length % 2)
        && rowsL.filter((r) => /["']/.test(r.body)).length === 50 && nL(/"/g) === 24 && nL(/'/g) === 91,
        `${rowsL.length} ${entL.size} ${rowsL.filter((r) => /["']/.test(r.body)).length} ${nL(/"/g)} ${nL(/'/g)} ${rowsL.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)}`);
      const countL = (row, s) => (rowsL.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MLA1 text: the 27 text verdicts are applied, each printed fragment in its row and the misread gone',
        textL.length === 27 && textL.every((o) => countL(o.match.row, o.printed) >= 1 && countL(o.match.row, o.read) === 0),
        textL.map((o) => `${o.match.row} ${countL(o.match.row, o.printed)}/${countL(o.match.row, o.read)}`).join());
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10m, Nate
      // 2026-11-03): MLA1's two are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeL = rowsL.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mla1:/, ''))).sort();
      check('MLA1 text: no row reads a letter, a hyphen and a space before a word',
        rowsL.length > 0 && shapeL.length === 0, shapeL.join(' '));
      // the proofread scan's misreads (marvel-11 leftovers row 11c, read on
      // the page 2026-11-03): seven line-end compounds the reader joined with
      // the hyphen lost, and five glyph or space misreads. None is left in any
      // row. The Fixer's fieid is the page's own misprint and stays.
      const proofL = rowsL.flatMap((r) => [...r.body.matchAll(/gasfilled|steelfiber|knifefighting|husband-andwife|tapdancer|\b1area|quasimystical|Keviar|\bto3\b|weepons|\blvory|\+1CS\.A/g)]
        .map((m) => `${r.key.replace(/^mla1:/, '')} ${m[0]}`));
      check('MLA1 text: no row reads the proofread misreads (gasfilled, steelfiber, knifefighting, husband-andwife, tapdancer, 1area, quasimystical, Keviar, to3, weepons, lvory, +1CS.A), and the Fixer\'s seventh power keeps the page\'s fieid',
        rowsL.length > 0 && proofL.length === 0 && countL('mla1:fixer-mla1:power:7', 'gravity fieid') === 1,
        `${proofL.join(' | ')} ${countL('mla1:fixer-mla1:power:7', 'gravity fieid')}`);
      // OCR noise row 12b saw on the page (a bar or a backslash for a capital
      // I, a stray tilde, lron for Iron, a capital Kill the page prints lower
      // case), each now a text verdict read on the page. None is left, and
      // the three Kills that remain are printed capital (printed 42 and 53).
      const noiseL = rowsL.filter((r) => /[|\\~]/.test(r.body)).map((r) => r.key.replace(/^mla1:/, ''));
      const lronL = rowsL.filter((r) => /\blron\b/.test(r.body)).map((r) => r.key.replace(/^mla1:/, ''));
      const killL = rowsL.filter((r) => /Kill/.test(r.body)).map((r) => r.key.replace(/^mla1:/, ''));
      check('MLA1 text: no bar, backslash, tilde or lron is left in any row, and Kill only where the page prints it capital',
        !noiseL.length && !lronL.length
        && killL.join() === 'black-talon-mla1:power:1,rat-pack-of-10-mla1:prose,mosquito-swarm-mla1:prose',
        `${noiseL.join()} | ${lronL.join()} | ${killL.join()}`);
      // Printed 42 (plan marvel-11-leftovers row 4, read on a render): the
      // chapter's numbered encounter 2 resumes straight under the Alligator's
      // grid, so the Alligator has no text of its own, and with no entry_ends
      // the encounter's first paragraph was its prose (138 characters). The
      // rats' and the Mosquito Swarm's own prose rows stay.
      const encL = rowsL.filter((r) => /^\d+\. [A-Z]/.test(r.body)).map((r) => r.key.replace(/^mla1:/, ''));
      check('MLA1 text: the Alligator has no prose row and no row opens with a chapter\'s numbered encounter (entry_ends, printed 42), while the Rat, pack of 10 and the Mosquito Swarm keep theirs',
        !rowsL.some((r) => r.key.startsWith('mla1:alligator-mla1:')) && !encL.length
        && ['rat-pack-of-10', 'mosquito-swarm'].every((s) => rowsL.some((r) => r.key === `mla1:${s}-mla1:prose`)),
        `${rowsL.filter((r) => r.key.startsWith('mla1:alligator-mla1:')).map((r) => r.key)} | ${encL.join()}`);
      // Where an entry's sections are, each read on the page (survey mla1.md):
      // Abilities: and Weaponry: open a chapter opponent's notes, the faction
      // subheads end each Typical grid's notes, and each card's power rows are
      // its powers.
      const partsL = (s) => rowsL.filter((r) => r.key.startsWith(`mla1:${s}-mla1:`)).map((r) => r.key.split(':').slice(2).join(':')).filter((k) => !k.startsWith('power:')).join();
      const nPowL = (s) => rowsL.filter((r) => r.key.startsWith(`mla1:${s}-mla1:power:`)).length;
      const wordsL = (row) => (rowsL.find((r) => r.key === row)?.body.split(/\s+/).length || 0);
      check('MLA1 text: Jack the Bartender\'s, the SWF Operatives\' and the Security Officers\' notes are their own (opponent_section_labels), the Typical Batboy\'s notes stop at the next faction (extra_titles), and every card\'s power rows match its powers',
        ['jack-the-bartender', 'swf-operatives', 'security-officers'].map(partsL).join(' | ') === 'notes | talents,notes | notes'
        && ['typical-batboy', 'typical-maggia-thug', 'typical-crimson-smile', 'typical-flashing-blade', 'typical-buzz-cut'].every((s) => partsL(s) === 'talents,notes')
        && wordsL('mla1:typical-batboy-mla1:notes') === 72
        && partsL('mentallo') === 'talents,background,notes' && partsL('pride-mr-maximilian') === 'talents,background'
        && mla1.every((c) => nPowL(c.id.replace(/-mla1$/, '')) === c.versions[0].powers.length),
        `${['jack-the-bartender', 'swf-operatives', 'security-officers'].map(partsL).join(' | ')} ${wordsL('mla1:typical-batboy-mla1:notes')} ${mla1.map((c) => `${c.id}:${nPowL(c.id.replace(/-mla1$/, ''))}/${c.versions[0].powers.length}`).filter((s) => { const [a, b] = s.split(':')[1].split('/'); return a !== b; })}`);
    }
  }

  // MLBA1 is read by scripts/msh/gridbooks.py (mlba1-overrides.json), with the
  // survey's decisions applied as it recommends (mlba1.md; Nate 2026-10-31).
  // Every card is in the Adventure Book (printed 3-31, and the six cards of
  // printed 32). The registry fields only this book sets (bracket_identity,
  // power_heads' fourth field, powers_open, page_bottoms, banner_bands) and
  // the ones it shares whose absence roster.py would not stop on (speck_lines,
  // art_boxes, entry_ends) are each pinned here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'mlba1')) {
    const mlba1 = data.npcs.characters.filter((c) => c.book === 'mlba1');
    const blocksB = mlba1.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkB = (id, i = 0) => mlba1.find((c) => c.id === id)?.versions[0].blocks[i];
    const cardB = (id) => mlba1.find((c) => c.id === `${id}-mlba1`)?.versions[0];
    const teamB = (t) => mlba1.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedB = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MLBA1: 23 characters, each id ending -mlba1 with one version, the six cards of printed 32 as Mutating Mutants Heroes and 17 under the book\'s title, and no name starting The (the Black King)',
      mlba1.length === 23 && mlba1.every((c) => c.id.endsWith('-mlba1') && c.versions.length === 1)
      && teamB('Mutating Mutants Heroes') === 'Boom-Boom,Cannonball,Richtor,Rusty Collins,Sunspot,Wolverine'
      && mlba1.filter((c) => c.team === 'MLBA1 Mutating Mutants').length === 17
      && !mlba1.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id))
      && mlba1.find((c) => c.id === 'black-king-mlba1')?.name === 'Black King',
      `${mlba1.length} ${[...new Set(mlba1.map((c) => c.team))]}`);
    check('MLBA1: the cards sort by the Adventure page each starts on, 3 to 32',
      mlba1.map((c) => c.id).join() === ['black-king', 'ee-ha', 'generic-punk', 'rocco', 'schiz', 'generic-goon', 'beetle', 'mauler', 'mad-dog',
        'sabretooth', 'sentinel-mark-iv', 'armadillo', 'goliath', 'ramhorn', 'chicken', 'chimpanzee', 'giant-dalmatian', 'boom-boom', 'cannonball',
        'richtor', 'rusty-collins', 'sunspot', 'wolverine'].map((id) => `${id}-mlba1`).join(),
      mlba1.map((c) => c.id).join());
    check('MLBA1: 23 blocks, none labelled: the three animals\' one-line grids, ranks only, and 20 full blocks',
      blocksB.length === 23 && !blocksB.some(({ b }) => b.label)
      && blocksB.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === 'chicken-mlba1,chimpanzee-mlba1,giant-dalmatian-mlba1'
      && blocksB.filter(({ b }) => b.rank_only).map(({ id }) => id).join() === 'chicken-mlba1,chimpanzee-mlba1,giant-dalmatian-mlba1'
      && blocksB.filter(({ b }) => !b.kind).length === 20,
      blocksB.filter(({ b }) => b.kind || b.label || b.rank_only).map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}`).join());
    const vB = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
    const fixesB = ['ee-ha', 'generic-punk', 'rocco', 'schiz', 'generic-goon', 'cannonball'].map((s) => {
      const id = `${s}-mlba1`;
      const o = blkB(id)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${vB(o?.printed)}>${vB(o?.corrected)} [${(o?.also || []).map((a) => `${a.field} ${vB(a.printed)}>${vB(a.corrected)}`)}] plays ${playedB(id)}`;
    });
    check('MLBA1: the six misprint blocks keep the printed values and carry the corrected ones (the five p.4-6 thugs\' Karma as 14, Ee-ha\'s and Schiz\'s R 6 Pr as 4, Schiz\'s I 4 Ty as 6, Cannonball\'s A 6 Ty as 4 Pr)',
      fixesB.join(' | ') === [
        'ee-ha-mlba1 misprint R 6 Pr>4 Pr [karma 6>14] plays 46/14',
        'generic-punk-mlba1 misprint karma 4>14 [] plays 32/14',
        'rocco-mlba1 misprint karma 4>14 [] plays 44/14',
        'schiz-mlba1 misprint R 6 Pr>4 Pr [I 4 Ty>6 Ty,karma 6>14] plays 36/14',
        'generic-goon-mlba1 misprint karma 10>14 [] plays 32/14',
        'cannonball-mlba1 misprint A 6 Ty>4 Pr [] plays 54/22',
      ].join(' | ')
      && bookNpc({ character: 'schiz-mlba1' }).snapshot?.abilities.reason.number === 4
      && bookNpc({ character: 'schiz-mlba1' }).snapshot?.abilities.intuition.number === 6
      && bookNpc({ character: 'cannonball-mlba1' }).snapshot?.abilities.agility.rank === 'poor',
      fixesB.join(' | '));
    check('MLBA1: the Sentinel\'s Karma NA and Sunspot\'s Health 52(76) are kept as printed (survey decisions 4 and 6), the Sentinel playing no Karma and Sunspot his 52',
      blkB('sentinel-mark-iv-mlba1')?.override?.verdict === 'as_printed' && blkB('sentinel-mark-iv-mlba1')?.karma === 'NA'
      && blkB('sunspot-mlba1')?.override?.verdict === 'as_printed' && blkB('sunspot-mlba1')?.health === '52(76)'
      && playedB('sentinel-mark-iv-mlba1') === '165/null' && playedB('sunspot-mlba1') === '52/20',
      `${playedB('sentinel-mark-iv-mlba1')} ${playedB('sunspot-mlba1')}`);
    const ovB = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mlba1-overrides.json'), 'utf8')).overrides;
    const textB = ovB.filter((o) => o.verdict === 'text');
    check('MLBA1: fifteen overrides: six misprints, two as printed and seven text verdicts (five capital I misread, a speck, Armadillo\'s Claws colon), and only those eight blocks carry one',
      ovB.length === 15 && ovB.filter((o) => o.verdict === 'misprint').length === 6 && ovB.filter((o) => o.verdict === 'as_printed').length === 2
      && textB.map((o) => o.match.row.replace(/^mlba1:/, '')).join() === ['black-king-mlba1:power:1', 'beetle-mlba1:background', 'beetle-mlba1:power:5',
        'chicken-mlba1:power:3', 'richtor-mlba1:power:3', 'sunspot-mlba1:notes', 'armadillo-mlba1:power:1'].join()
      && blocksB.filter(({ b }) => b.override).map(({ id }) => id).join()
        === 'ee-ha-mlba1,generic-punk-mlba1,rocco-mlba1,schiz-mlba1,generic-goon-mlba1,sentinel-mark-iv-mlba1,cannonball-mlba1,sunspot-mlba1',
      JSON.stringify(ovB.map((o) => [o.verdict, o.match])));
    check('MLBA1: the three animals print no Karma, so theirs is derived from their ranks (the Chicken 38/6, the Chimpanzee 72/12, the Giant Dalmatian 46/14) and flagged so, and no other MLBA1 block is',
      ['chicken-mlba1', 'chimpanzee-mlba1', 'giant-dalmatian-mlba1'].every((id) => blkB(id)?.karma_derived === true && !blkB(id)?.health_derived)
      && ['chicken-mlba1', 'chimpanzee-mlba1', 'giant-dalmatian-mlba1'].map((id) => playedB(id)).join() === '38/6,72/12,46/14'
      && blocksB.filter(({ b }) => b.karma_derived || b.health_derived).length === 3,
      `${['chicken-mlba1', 'chimpanzee-mlba1', 'giant-dalmatian-mlba1'].map((id) => playedB(id))} ${blocksB.filter(({ b }) => b.karma_derived || b.health_derived).map(({ id }) => id)}`);
    check('MLBA1: Rusty Collins\'s header Rusty (Russell) Collins gives him no version label and Russell Collins as his identity, the five other cards of printed 32 keeping the line each prints (bracket_identity)',
      mlba1.find((c) => c.id === 'rusty-collins-mlba1')?.name === 'Rusty Collins' && cardB('rusty-collins')?.label === null
      && cardB('rusty-collins')?.identity.join() === 'Russell Collins'
      && ['boom-boom', 'cannonball', 'richtor', 'sunspot', 'wolverine'].every((s) => cardB(s)?.identity.length === 1)
      && !mlba1.some((c) => c.versions[0].label),
      `${cardB('rusty-collins')?.label} ${cardB('rusty-collins')?.identity} ${mlba1.filter((c) => c.versions[0].label).map((c) => c.id)}`);
    const powB = mlba1.flatMap((c) => c.versions[0].powers);
    const namesB = (s) => cardB(s)?.powers.map((p) => p.name).join(' / ');
    check('MLBA1: 65 powers across 18 cards, 20 of them linked to the UPB; Wolverine six and Richtor three (power_heads), the animals 1, 3 and 3 (powers_open), Goliath three (banner_bands) and the Beetle\'s second Wall-Crawling (speck_lines)',
      powB.length === 65 && powB.filter((p) => p.upb).length === 20 && mlba1.filter((c) => c.versions[0].powers.length).length === 18
      && namesB('wolverine') === 'Regeneration / Resistance / Claws / Adamantium Skeleton / Tracking / Invisibility'
      && namesB('richtor') === 'Vibration touch / Vibration Ray / Earth Tremors'
      && namesB('chimpanzee') === 'Light manipulation' && namesB('giant-dalmatian') === 'Resistant to Fire / Six Legs / Claws and Teeth'
      && namesB('chicken') === 'Flight / Beak and Tail / Body Armor'
      && namesB('goliath') === 'Growth / Body Armor / Invulnerability'
      && cardB('beetle')?.powers[1]?.name === 'Wall-Crawling',
      `${powB.length} ${powB.filter((p) => p.upb).length} ${mlba1.filter((c) => c.versions[0].powers.length).length} | ${['wolverine', 'richtor', 'chimpanzee', 'giant-dalmatian', 'chicken', 'goliath', 'beetle'].map(namesB).join(' | ')}`);
    const bookB = data.npcs.books.find((b) => b.slug === 'mlba1');
    check('MLBA1: the book reads Adventure 3-31 and 32, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookB?.ranges) === '[{"part":"Adventure","pages":[[3,31],[32,32]]}]'
      && tagline(bookNpc({ character: 'black-king-mlba1' }).snapshot).startsWith('MLBA1 Mutating Mutants, Adventure p.3;')
      && tagline(bookNpc({ character: 'chicken-mlba1' }).snapshot).startsWith('MLBA1 Mutating Mutants, Adventure p.31;')
      && tagline(bookNpc({ character: 'wolverine-mlba1' }).snapshot).startsWith('MLBA1 Mutating Mutants, Adventure p.32;')
      && mlba1.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(bookB?.ranges)} ${tagline(bookNpc({ character: 'black-king-mlba1' }).snapshot)} ${mlba1.map((c) => `${c.id}:${choices.filter((x) => x.character === c.id).length}`).filter((s) => !s.endsWith(':1'))}`);
    const playsB = ['black-king', 'beetle', 'mauler', 'sentinel-mark-iv', 'goliath', 'boom-boom', 'rusty-collins', 'wolverine'].map((s) => playedB(`${s}-mlba1`)).join();
    check('MLBA1: cards play their printed Health and Karma (the Black King 100/70, the Beetle 70/56, Mauler 140/36, the Sentinel 165 and none, Goliath 145/14, Boom-Boom 34/16, Rusty Collins 28/22, Wolverine 110/121)',
      playsB === '100/70,70/56,140/36,165/null,145/14,34/16,28/22,110/121', playsB);
    // The text verdicts, the quote marks and where an entry ends move only the
    // book's text, which is msh_book_text's: read the generated .sql in the
    // cache, by keys, counts and the overrides' own fragments, never a
    // sentence of the book in this file.
    const sqlB = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mlba1', 'book-text.sql');
    if (!existsSync(sqlB)) {
      check(`MLBA1: skipped the text checks: no ${rel(sqlB) || sqlB}`, true);
    } else {
      const rowsB = [...readFileSync(sqlB, 'utf8').matchAll(/VALUES \('([^']+)', 'mlba1', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entB = new Set(rowsB.map((r) => r.key.split(':')[1]));
      const nB = (re) => rowsB.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      const oddB = rowsB.filter((r) => (r.body.match(/"/g) || []).length % 2);
      // Rocco's height prints as feet and inches, so his prose holds the one
      // double mark that pairs with nothing; every other mark row 15b read on a
      // 300 dpi crop: three double-quoted pairs and the apostrophes.
      check('MLBA1 text: 90 rows over all 23 entries, the one row with an odd count of double quotes Rocco\'s prose (his 6\'4" height), and the marks row 15b read on the page: 16 rows hold 24, seven double and 17 single',
        rowsB.length === 90 && entB.size === 23 && mlba1.every((c) => entB.has(c.id))
        && oddB.map((r) => r.key).join() === 'mlba1:rocco-mlba1:prose' && (oddB[0]?.body.match(/"/g) || []).length === 1 && oddB[0]?.body.includes('6\'4"')
        && rowsB.filter((r) => /["']/.test(r.body)).length === 16 && nB(/"/g) === 7 && nB(/'/g) === 17,
        `${rowsB.length} ${entB.size} ${oddB.map((r) => r.key)} ${rowsB.filter((r) => /["']/.test(r.body)).length} ${nB(/"/g)} ${nB(/'/g)}`);
      const countB = (row, s) => (rowsB.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MLBA1 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textB.length === 7 && textB.every((o) => countB(o.match.row, o.printed) === 1 && countB(o.match.row, o.read) === 0),
        textB.map((o) => `${o.match.row} ${countB(o.match.row, o.printed)}/${countB(o.match.row, o.read)}`).join(' | '));
      // A bar, a backslash or an l for a capital I, and the scan's underscore
      // speck: each one the OCR left was read on the page and is a text
      // verdict now, so a new one moves this list.
      const noiseB = rowsB.filter((r) => /[|\\~_]/.test(r.body) || /\b(lf|ln|lt|tll)\b/.test(r.body)).map((r) => r.key.replace(/^mlba1:/, ''));
      check('MLBA1 text: no row carries a bar, a backslash, a tilde, an underscore or an l for a capital I',
        noiseB.length === 0, noiseB.join());
      // Where an entry's text ends, each measured with its registry field off
      // (books.json mlba1 notes): the lengths the field gives, so a reader
      // change that moves one moves this check.
      const lenB = (prefix) => rowsB.filter((r) => r.key === `mlba1:${prefix}` || r.key.startsWith(`mlba1:${prefix}:`)).reduce((n, r) => n + r.body.length, 0);
      const flightB = rowsB.find((r) => r.key === 'mlba1:mauler-mlba1:power:4');
      const lensB = ['rocco-mlba1:prose', 'black-king-mlba1:power:1', 'sabretooth-mlba1:talents', 'ramhorn-mlba1:power', 'cannonball-mlba1:talents',
        'boom-boom-mlba1:talents', 'rusty-collins-mlba1:power', 'wolverine-mlba1:talents', 'richtor-mlba1:power'].map((p) => `${p}=${lenB(p)}`).join();
      check('MLBA1 text: each entry ends where its page does (entry_ends, art_boxes, page_bottoms, banner_bands), and Mauler\'s Flight is named Flight and holds none of the map\'s lettering (art_boxes)',
        lensB === 'rocco-mlba1:prose=99,black-king-mlba1:power:1=1092,sabretooth-mlba1:talents=41,ramhorn-mlba1:power=567,cannonball-mlba1:talents=6,'
          + 'boom-boom-mlba1:talents=43,rusty-collins-mlba1:power=456,wolverine-mlba1:talents=148,richtor-mlba1:power=711'
        && flightB?.name === 'Flight' && !/[=[\]]/.test(flightB?.body || '='),
        `${lensB} ${flightB?.name} ${flightB?.body.length}`);
      check('MLBA1 text: every card\'s power rows match its powers',
        mlba1.every((c) => rowsB.filter((r) => r.key.startsWith(`mlba1:${c.id}:power:`)).length === c.versions[0].powers.length),
        mlba1.map((c) => `${c.id}:${rowsB.filter((r) => r.key.startsWith(`mlba1:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).filter((s) => { const [a, b] = s.split(':')[1].split('/'); return a !== b; }).join());
    }
  }

  // MLA2 is read by scripts/msh/gridbooks.py (mla2-overrides.json), with the
  // survey's decisions applied as it recommends (mla2.md; Nate 2026-10-31).
  // Its cards are in the Adventure Book: the seven Player Characters and six
  // faction grids (printed 3-8), the chapters' grids (23-49) and the roster
  // (54-64), laid out as MLA1 is.
  if (data.npcs.characters.some((c) => c.book === 'mla2')) {
    const mla2 = data.npcs.characters.filter((c) => c.book === 'mla2');
    const blocksN = mla2.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkN = (id, i = 0) => mla2.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamN = (t) => mla2.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedN = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MLA2: 47 characters, each id ending -mla2 with one version, the seven Player Characters as Night Moves Heroes and 40 under the book\'s title, and no name starting The (teams)',
      mla2.length === 47 && mla2.every((c) => c.id.endsWith('-mla2') && c.versions.length === 1)
      && teamN('Night Moves Heroes') === 'Cloak,Dagger,Daredevil,Iron Fist,Moon Knight,Power Man,Spider-Man'
      && mla2.filter((c) => c.team === 'MLA2 Night Moves').length === 40
      && !mla2.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mla2.length} ${[...new Set(mla2.map((c) => c.team))]}`);
    check('MLA2: the cards sort by the Adventure page each starts on, 3 to 63, the chapters\' grids between the factions and the roster',
      mla2.map((c) => c.id).join() === ['cloak', 'dagger', 'daredevil', 'iron-fist', 'moon-knight', 'power-man', 'spider-man', 'typical-batboy',
        'typical-dragonlord', 'typical-maggia-technician', 'typical-maggia-thug', 'typical-si-fan-assassin', 'typical-tiger-s-claw', 'old-man', 'tak',
        'guardsmen', 'mechanical-monster', 'werewolf-robot', 'clown-robot', 'robot-children', 'vampire-robot', 'mechanical-mummy', 'mechanical-skeletons',
        'dragon-robots', 'dragons-control-device', 'skeletal-ghosts', 'beetle', 'blizzard', 'captain-america', 'chemist', 'constrictor',
        'deathlok-simulacrum', 'dreadnoughts', 'fixer', 'hammerhead', 'iron-man', 'killer-shrike', 'manchu-fu', 'mentallo', 'min-lee', 'sersi',
        'shang-chi', 'silver-samurai', 'starfox', 'thor', 'vision', 'white-dragon'].map((id) => `${id}-mla2`).join(),
      mla2.map((c) => c.id).join());
    check('MLA2: 49 blocks: Iron Man\'s and Thor\'s second grids labelled (Tony Stark, Eric Masterson; survey decision 4), two version labels (Captain America Original, Iron Man Mark VIII Armor), and no one-line, partial, ranks-only or derived block',
      blocksN.length === 49
      && blocksN.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'iron-man-mla2:Iron Man,iron-man-mla2:Tony Stark,thor-mla2:Thor,thor-mla2:Eric Masterson'
      && mla2.filter((c) => c.versions[0].label).map((c) => `${c.id}:${c.versions[0].label}`).join() === 'captain-america-mla2:Original,iron-man-mla2:Mark VIII Armor'
      && !blocksN.some(({ b }) => b.kind || b.rank_only || b.karma_derived || b.health_derived),
      blocksN.filter(({ b }) => b.kind || b.label || b.rank_only || b.karma_derived || b.health_derived).map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}`).join());
    const vN = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
    const fixesN = [['iron-fist-mla2'], ['guardsmen-mla2'], ['clown-robot-mla2'], ['thor-mla2', 0]].map(([id, i]) => {
      const o = blkN(id, i)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${vN(o?.printed)}>${vN(o?.corrected)} [${(o?.also || []).map((a) => `${a.verdict} ${a.field} ${vN(a.printed)}`)}] plays ${playedN(id, i)}`;
    });
    check('MLA2: the four misprints keep the printed value and carry the corrected one (Iron Fist\'s P 75 Am as 75 Mn, the Guardsmen\'s Health 70 as 100, the Clown Robot\'s E 30 Ex as 30 Rm, Thor\'s Health 200 as 270; survey decision 5)',
      fixesN.join(' | ') === [
        'iron-fist-mla2 misprint P 75 Am>75 Mn [] plays 100/125',
        'guardsmen-mla2 misprint health 70>100 [] plays 100/18',
        'clown-robot-mla2 misprint E 30 Ex>30 Rm [as_printed karma 0] plays 80/0',
        'thor-mla2 misprint health 200>270 [] plays 270/50',
      ].join(' | ')
      && bookNpc({ character: 'iron-fist-mla2' }).snapshot?.abilities.psyche.rank === 'monstrous'
      && bookNpc({ character: 'clown-robot-mla2' }).snapshot?.abilities.endurance.rank === 'remarkable',
      fixesN.join(' | '));
    const robotsN = ['mechanical-monster', 'werewolf-robot', 'robot-children', 'vampire-robot', 'mechanical-mummy', 'mechanical-skeletons', 'dragon-robots',
      'dragons-control-device', 'skeletal-ghosts'].map((s) => `${s}-mla2`);
    check('MLA2: the robots\' and the ghosts\' printed Karma 0 and the Dreadnoughts\' None are kept as printed (survey decision 6), playing 0 and none',
      robotsN.every((id) => blkN(id)?.override?.verdict === 'as_printed' && blkN(id)?.override?.field === 'karma' && blkN(id)?.karma === '0' && playedN(id).endsWith('/0'))
      && blkN('dreadnoughts-mla2')?.override?.verdict === 'as_printed' && blkN('dreadnoughts-mla2')?.karma === 'None'
      && playedN('dreadnoughts-mla2') === '165/null',
      `${robotsN.map((id) => `${id}:${blkN(id)?.override?.verdict}:${blkN(id)?.karma}:${playedN(id)}`).join()} ${playedN('dreadnoughts-mla2')}`);
    const ovN = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mla2-overrides.json'), 'utf8')).overrides;
    const textN = ovN.filter((o) => o.verdict === 'text');
    check('MLA2: 27 overrides: four misprints, two labels, ten as printed and 11 text verdicts (the Si-Fan Assassin\'s lost last line, seven word misreads: the Beetle\'s R I P, Iron Man\'s name, Min Lee\'s born, and four capital I, and three line-end compound hyphens, Shang-Chi twice and Shift-X, whose printed fragment keeps the hyphen and drops the space), and only those 14 blocks carry a misprint or as-printed one',
      ovN.length === 27 && ovN.filter((o) => o.verdict === 'misprint').length === 4 && ovN.filter((o) => o.verdict === 'label').length === 2
      && ovN.filter((o) => o.verdict === 'as_printed').length === 10
      && textN.map((o) => o.match.row.replace(/^mla2:/, '')).join() === ['typical-si-fan-assassin-mla2:talents', 'beetle-mla2:power:1', 'iron-man-mla2:power:4',
        'min-lee-mla2:background', 'spider-man-mla2:power:2', 'guardsmen-mla2:power:2', 'dragons-control-device-mla2:power:1', 'thor-mla2:power:6',
        'shang-chi-mla2:background', 'shang-chi-mla2:background', 'starfox-mla2:power:2'].join()
      && textN.slice(8).every((o) => o.printed === o.read.replace(/([a-z])- ([A-Z])/, '$1-$2'))
      && blocksN.filter(({ b }) => b.override).map(({ id }) => id).join() === ['iron-fist', 'guardsmen', 'mechanical-monster', 'werewolf-robot', 'clown-robot',
        'robot-children', 'vampire-robot', 'mechanical-mummy', 'mechanical-skeletons', 'dragon-robots', 'dragons-control-device', 'skeletal-ghosts',
        'dreadnoughts', 'thor'].map((s) => `${s}-mla2`).join(),
      `${ovN.length} ${JSON.stringify(ovN.map((o) => [o.verdict, o.match.row || o.match.header]))}`);
    const powN = mla2.flatMap((c) => c.versions[0].powers);
    check('MLA2: 140 powers across 39 cards, 41 of them linked to the UPB',
      powN.length === 140 && powN.filter((p) => p.upb).length === 41 && mla2.filter((c) => c.versions[0].powers.length).length === 39,
      `${powN.length} ${powN.filter((p) => p.upb).length} ${mla2.filter((c) => c.versions[0].powers.length).length}`);
    const bookN = data.npcs.books.find((b) => b.slug === 'mla2');
    const twoN = ['iron-man-mla2', 'thor-mla2'];
    const choicesN = mla2.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MLA2: the book reads Adventure 3-8, 23-49 and 54-64, a card cites its Adventure page, and every card is one GM choice but Iron Man\'s and Thor\'s, two each',
      JSON.stringify(bookN?.ranges) === '[{"part":"Adventure","pages":[[3,8],[23,49],[54,64]]}]'
      && tagline(bookNpc({ character: 'cloak-mla2' }).snapshot).startsWith('MLA2 Night Moves, Adventure p.3;')
      && tagline(bookNpc({ character: 'white-dragon-mla2' }).snapshot).startsWith('MLA2 Night Moves, Adventure p.63;')
      && mla2.every((c, i) => choicesN[i] === (twoN.includes(c.id) ? 2 : 1)),
      `${JSON.stringify(bookN?.ranges)} ${tagline(bookNpc({ character: 'cloak-mla2' }).snapshot)} ${tagline(bookNpc({ character: 'white-dragon-mla2' }).snapshot)} ${mla2.map((c, i) => `${c.id}:${choicesN[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsN = [['cloak-mla2'], ['daredevil-mla2'], ['typical-si-fan-assassin-mla2'], ['old-man-mla2'], ['captain-america-mla2'], ['iron-man-mla2', 0],
      ['iron-man-mla2', 1], ['thor-mla2', 1], ['manchu-fu-mla2'], ['white-dragon-mla2']].map(([id, b]) => playedN(id, b)).join();
    check('MLA2: cards play their printed Health and Karma (Cloak 76/36, Daredevil 110/91, the Si-Fan Assassin 60/32, the Old Man 22/22, Captain America 150/90, Iron Man 165/66 and as Tony Stark 22/66, Thor as Eric Masterson 28/46, Manchu Fu 46/140, the White Dragon 70/30)',
      playsN === '76/36,110/91,60/32,22/22,150/90,165/66,22/66,28/46,46/140,70/30', playsN);
    // The text verdicts and the quote marks move only the book's text, which
    // is msh_book_text's: read the generated .sql in the cache, by keys,
    // counts and the overrides' own fragments, never a sentence of the book
    // in this file.
    const sqlN = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mla2', 'book-text.sql');
    if (!existsSync(sqlN)) {
      check(`MLA2: skipped the text checks: no ${rel(sqlN) || sqlN}`, true);
    } else {
      const rowsN = [...readFileSync(sqlN, 'utf8').matchAll(/VALUES \('([^']+)', 'mla2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entN = new Set(rowsN.map((r) => r.key.split(':')[1]));
      const oddN = rowsN.filter((r) => (r.body.match(/"/g) || []).length % 2);
      // Row 18b read every mark on the page: a row holding a double quote or a
      // single that is not inside a word. Each was printed as read.
      const markedN = rowsN.filter((r) => /"/.test(r.body) || [...r.body.matchAll(/'/g)].some((x) => !(/[A-Za-z]/.test(r.body[x.index - 1] || '') && /[A-Za-z]/.test(r.body[x.index + 1] || ''))));
      check('MLA2 text: 215 rows over 45 entries (the Old Man and Tak print none), no row with an odd count of double quotes, and the 24 rows holding a mark that row 18b read on the page',
        rowsN.length === 215 && entN.size === 45
        && mla2.filter((c) => !entN.has(c.id)).map((c) => c.id).join() === 'old-man-mla2,tak-mla2'
        && oddN.length === 0 && markedN.length === 24,
        `${rowsN.length} ${entN.size} ${mla2.filter((c) => !entN.has(c.id)).map((c) => c.id)} ${oddN.map((r) => r.key)} ${markedN.length}`);
      const countN = (row, s) => (rowsN.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      // The Si-Fan Assassin's read is the start of what is printed; every other
      // read is gone from its row.
      check('MLA2 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textN.length === 11 && textN.every((o) => countN(o.match.row, o.printed) >= 1
          && countN(o.match.row, o.read) === (o.printed.includes(o.read) ? countN(o.match.row, o.printed) : 0)),
        textN.map((o) => `${o.match.row} ${countN(o.match.row, o.printed)}/${countN(o.match.row, o.read)}`).join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10n, Nate
      // 2026-11-03): MLA2's three are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeN = rowsN.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mla2:/, ''))).sort();
      check('MLA2 text: no row reads a letter, a hyphen and a space before a word',
        rowsN.length > 0 && shapeN.length === 0, shapeN.join(' '));
      const noiseN = rowsN.filter((r) => /[|\\~_]/.test(r.body) || /\b(lf|ln|lt|tll)\b/.test(r.body)).map((r) => r.key.replace(/^mla2:/, ''));
      check('MLA2 text: no row carries a bar, a backslash, a tilde, an underscore or an l for a capital I',
        noiseN.length === 0, noiseN.join());
      check('MLA2 text: every card\'s power rows match its powers',
        mla2.every((c) => rowsN.filter((r) => r.key.startsWith(`mla2:${c.id}:power:`)).length === c.versions[0].powers.length),
        mla2.map((c) => `${c.id}:${rowsN.filter((r) => r.key.startsWith(`mla2:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).filter((s) => { const [a, b] = s.split(':')[1].split('/'); return a !== b; }).join());
    }
  }

  // MLA3 is read by scripts/msh/gridbooks.py (mla3-overrides.json), with the
  // survey's decisions applied as it recommends (mla3.md; Nate 2026-10-31).
  // Its cards are in the Adventure Book: the six Player Characters and five
  // faction grids (printed 3-8), the chapters' grids (13-44) and the roster
  // (50-63), laid out as MLA2 is.
  if (data.npcs.characters.some((c) => c.book === 'mla3')) {
    const mla3 = data.npcs.characters.filter((c) => c.book === 'mla3');
    const blocksL = mla3.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkL = (id, i = 0) => mla3.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamL = (t) => mla3.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const playedL = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MLA3: 45 characters, each id ending -mla3 with one version, the six Player Characters as Night Life Heroes and 39 under the book\'s title, and no name starting The (teams)',
      mla3.length === 45 && mla3.every((c) => c.id.endsWith('-mla3') && c.versions.length === 1)
      && teamL('Night Life Heroes') === 'Daredevil,Hawkeye,Mockingbird,Moon Knight,Shang-Chi,Spider-Man'
      && mla3.filter((c) => c.team === 'MLA3 Night Life').length === 39
      && !mla3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${mla3.length} ${[...new Set(mla3.map((c) => c.team))]}`);
    check('MLA3: the cards sort by the Adventure page each starts on, 3 to 63, the chapters\' grids between the factions and the roster',
      mla3.map((c) => c.id).join() === ['daredevil', 'hawkeye', 'mockingbird', 'moon-knight', 'shang-chi', 'spider-man', 'typical-batboy',
        'typical-maggia-thug', 'typical-si-fan-assassin', 'typical-wildboy', 'typical-policeman', 'hammerhead-robot', 'security-robots',
        'cameron-s-machine', 'bertha-the-gorilla', 'alligators', 'hound-dog', 'creature-from-the-void', 'security-guards', 'ammo', 'captain-america',
        'colossal-deathlok', 'fixer', 'fly', 'gator', 'goliath', 'guardsmen', 'hammerhead', 'iron-man', 'kingpin', 'mad-dog', 'manchu-fu', 'mandroid',
        'mentallo', 'mongoose', 'persuader', 'phantom-tong', 'rhino', 'seaver-cameron', 'sersi', 'starfox', 'thor', 'typhoid-mary', 'vision',
        'vortex'].map((id) => `${id}-mla3`).join(),
      mla3.map((c) => c.id).join());
    check('MLA3: 49 blocks: four cards\' second grids labelled (Iron Man\'s Tony Stark, the Mandroid\'s Rocko, Thor\'s Eric Masterson, Typhoid Mary\'s Mary; survey decision 4), two version labels (Captain America Original, Iron Man Mark VIII Armor), Bertha the Gorilla\'s and the Alligators\' Karma derived, and no one-line, partial or ranks-only block',
      blocksL.length === 49
      && blocksL.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'iron-man-mla3:Iron Man,iron-man-mla3:Tony Stark,mandroid-mla3:Mandroid,mandroid-mla3:Rocko,thor-mla3:Thor,thor-mla3:Eric Masterson,typhoid-mary-mla3:Typhoid Mary,typhoid-mary-mla3:Mary'
      && mla3.filter((c) => c.versions[0].label).map((c) => `${c.id}:${c.versions[0].label}`).join() === 'captain-america-mla3:Original,iron-man-mla3:Mark VIII Armor'
      && blocksL.filter(({ b }) => b.karma_derived).map(({ id }) => id).join() === 'bertha-the-gorilla-mla3,alligators-mla3'
      && !blocksL.some(({ b }) => b.kind || b.rank_only || b.health_derived),
      blocksL.filter(({ b }) => b.kind || b.label || b.rank_only || b.karma_derived || b.health_derived).map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}`).join());
    const fixesL = [['guardsmen-mla3'], ['thor-mla3', 0]].map(([id, i]) => {
      const o = blkL(id, i)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${o?.printed}>${o?.corrected} [${(o?.also || []).map((a) => `${a.verdict} ${a.field} ${a.printed}`)}] plays ${playedL(id, i)}`;
    });
    check('MLA3: the two misprints keep the printed value and carry the corrected one (the Guardsmen\'s Health 70 as 100, Thor\'s Health 200 as 270, as MLA2\'s; survey decision 5)',
      fixesL.join(' | ') === [
        'guardsmen-mla3 misprint health 70>100 [] plays 100/18',
        'thor-mla3 misprint health 200>270 [] plays 270/50',
      ].join(' | '),
      fixesL.join(' | '));
    const zeroL = ['hammerhead-robot', 'security-robots', 'cameron-s-machine'].map((s) => `${s}-mla3`);
    check('MLA3: the Hammerhead Robot\'s, the Security Robots\' and Cameron\'s Machine\'s printed Karma 0 are kept as printed (survey decision 6), playing 0',
      zeroL.every((id) => blkL(id)?.override?.verdict === 'as_printed' && blkL(id)?.override?.field === 'karma' && blkL(id)?.karma === '0' && playedL(id).endsWith('/0')),
      zeroL.map((id) => `${id}:${blkL(id)?.override?.verdict}:${blkL(id)?.karma}:${playedL(id)}`).join());
    check('MLA3: Bertha the Gorilla\'s and the Alligators\' grids print no Karma, so theirs is derived as R+I+P (12 and 6) and flagged so (survey decision 7)',
      blkL('bertha-the-gorilla-mla3')?.karma_derived === true && blkL('alligators-mla3')?.karma_derived === true
      && playedL('bertha-the-gorilla-mla3').endsWith('/12') && playedL('alligators-mla3').endsWith('/6'),
      `${playedL('bertha-the-gorilla-mla3')} ${playedL('alligators-mla3')}`);
    check('MLA3: Colossal Deathlok\'s identity is the name his Real Name: line gives, Luther Manning, not the sentence (short_identity; survey decision 12)',
      mla3.find((c) => c.id === 'colossal-deathlok-mla3')?.versions[0].identity.join('|') === 'Luther Manning',
      JSON.stringify(mla3.find((c) => c.id === 'colossal-deathlok-mla3')?.versions[0].identity));
    const ovL = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'mla3-overrides.json'), 'utf8')).overrides;
    const textL = ovL.filter((o) => o.verdict === 'text');
    check('MLA3: 23 overrides: two misprints, four labels, three as printed and 14 text verdicts (Daredevil\'s Foggy in doubles, eight bars, backslashes or an underscore for a capital I or nothing, and five line-end hyphens: three compounds, Shang-Chi, Mad-Dog and Kree-Skrull, whose printed fragment keeps the hyphen and drops the space, and two broken words closed up whole), and only those five blocks carry a misprint or as-printed one',
      ovL.length === 23 && ovL.filter((o) => o.verdict === 'misprint').length === 2 && ovL.filter((o) => o.verdict === 'label').length === 4
      && ovL.filter((o) => o.verdict === 'as_printed').length === 3
      && textL.map((o) => o.match.row.replace(/^mla3:/, '')).join() === ['daredevil-mla3:background', 'hawkeye-mla3:power:3', 'hawkeye-mla3:power:5',
        'hawkeye-mla3:power:5', 'spider-man-mla3:background', 'guardsmen-mla3:power:2', 'iron-man-mla3:power:4', 'iron-man-mla3:power:14',
        'mandroid-mla3:power:2', 'shang-chi-mla3:background', 'captain-america-mla3:talents', 'mad-dog-mla3:power:3', 'mandroid-mla3:background',
        'rhino-mla3:background'].join()
      && textL.slice(9).map((o) => (o.printed === o.read.replace(/([a-z])- ([A-Z])/, '$1-$2') ? 'compound'
        : o.printed === o.read.replace(/([a-z])- ([A-Z])/, (m, a, b) => a + b.toLowerCase()) ? 'closed' : 'other')).join()
        === 'compound,closed,compound,compound,closed'
      && blocksL.filter(({ b }) => b.override).map(({ id }) => id).join() === ['hammerhead-robot', 'security-robots', 'cameron-s-machine', 'guardsmen',
        'thor'].map((s) => `${s}-mla3`).join(),
      `${ovL.length} ${JSON.stringify(ovL.map((o) => [o.verdict, o.match.row || o.match.header]))}`);
    const powL = mla3.flatMap((c) => c.versions[0].powers);
    check('MLA3: 133 powers across 34 cards, 33 of them linked to the UPB',
      powL.length === 133 && powL.filter((p) => p.upb).length === 33 && mla3.filter((c) => c.versions[0].powers.length).length === 34,
      `${powL.length} ${powL.filter((p) => p.upb).length} ${mla3.filter((c) => c.versions[0].powers.length).length}`);
    const bookL = data.npcs.books.find((b) => b.slug === 'mla3');
    const twoL = ['iron-man-mla3', 'mandroid-mla3', 'thor-mla3', 'typhoid-mary-mla3'];
    const choicesL = mla3.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MLA3: the book reads Adventure 3-8, 13-44 and 50-63, a card cites its Adventure page, and every card is one GM choice but the four two-grid cards, two each',
      JSON.stringify(bookL?.ranges) === '[{"part":"Adventure","pages":[[3,8],[13,44],[50,63]]}]'
      && tagline(bookNpc({ character: 'daredevil-mla3' }).snapshot).startsWith('MLA3 Night Life, Adventure p.3;')
      && tagline(bookNpc({ character: 'vortex-mla3' }).snapshot).startsWith('MLA3 Night Life, Adventure p.63;')
      && mla3.every((c, i) => choicesL[i] === (twoL.includes(c.id) ? 2 : 1)),
      `${JSON.stringify(bookL?.ranges)} ${tagline(bookNpc({ character: 'daredevil-mla3' }).snapshot)} ${tagline(bookNpc({ character: 'vortex-mla3' }).snapshot)} ${mla3.map((c, i) => `${c.id}:${choicesL[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsL = [['daredevil-mla3'], ['hawkeye-mla3'], ['typical-wildboy-mla3'], ['colossal-deathlok-mla3'], ['iron-man-mla3', 0], ['iron-man-mla3', 1],
      ['mandroid-mla3', 0], ['mandroid-mla3', 1], ['thor-mla3', 1], ['typhoid-mary-mla3', 0], ['typhoid-mary-mla3', 1], ['vortex-mla3']].map(([id, b]) => playedL(id, b)).join();
    check('MLA3: cards play their printed Health and Karma (Daredevil 110/91, Hawkeye 70/22, the Typical Wildboy 36/18, Colossal Deathlok 215/14, Iron Man 165/66 and as Tony Stark 22/66, the Mandroid 120/18 and as Rocko 50/18, Thor as Eric Masterson 28/46, Typhoid Mary 120/20 and as Mary 20/20, Vortex 205/58)',
      playsL === '110/91,70/22,36/18,215/14,165/66,22/66,120/18,50/18,28/46,120/20,20/20,205/58', playsL);
    // The text verdicts and the quote marks move only the book's text, which
    // is msh_book_text's: read the generated .sql in the cache, by keys,
    // counts and the overrides' own fragments, never a sentence of the book
    // in this file.
    const sqlL = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'mla3', 'book-text.sql');
    if (!existsSync(sqlL)) {
      check(`MLA3: skipped the text checks: no ${rel(sqlL) || sqlL}`, true);
    } else {
      const rowsL = [...readFileSync(sqlL, 'utf8').matchAll(/VALUES \('([^']+)', 'mla3', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entL = new Set(rowsL.map((r) => r.key.split(':')[1]));
      const oddL = rowsL.filter((r) => (r.body.match(/"/g) || []).length % 2);
      // Row 21b read every double quote on the page: 17 rows, 38 marks, each
      // printed as read once Daredevil's Foggy was restored.
      const quotedL = rowsL.filter((r) => /"/.test(r.body));
      check('MLA3 text: 213 rows over 41 entries (Cameron\'s Machine, Bertha the Gorilla, the Alligators and Hound Dog print none), no row with an odd count of double quotes, and the 17 rows holding 38 double quotes that row 21b read on the page',
        rowsL.length === 213 && entL.size === 41
        && mla3.filter((c) => !entL.has(c.id)).map((c) => c.id).join() === 'cameron-s-machine-mla3,bertha-the-gorilla-mla3,alligators-mla3,hound-dog-mla3'
        && oddL.length === 0 && quotedL.length === 17 && quotedL.reduce((n, r) => n + r.body.split('"').length - 1, 0) === 38,
        `${rowsL.length} ${entL.size} ${mla3.filter((c) => !entL.has(c.id)).map((c) => c.id)} ${oddL.map((r) => r.key)} ${quotedL.length}`);
      const countL = (row, s) => (rowsL.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MLA3 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textL.length === 14 && textL.every((o) => countL(o.match.row, o.printed) >= 1
          && countL(o.match.row, o.read) === (o.printed.includes(o.read) ? countL(o.match.row, o.printed) : 0)),
        textL.map((o) => `${o.match.row} ${countL(o.match.row, o.printed)}/${countL(o.match.row, o.read)}`).join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10o, Nate
      // 2026-11-03): MLA3's five are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeL = rowsL.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^mla3:/, ''))).sort();
      check('MLA3 text: no row reads a letter, a hyphen and a space before a word',
        rowsL.length > 0 && shapeL.length === 0, shapeL.join(' '));
      const noiseL = rowsL.filter((r) => /[|\\~_]/.test(r.body) || /\b(lf|ln|lt|tll)\b/.test(r.body)).map((r) => r.key.replace(/^mla3:/, ''));
      check('MLA3 text: no row carries a bar, a backslash, a tilde, an underscore or an l for a capital I',
        noiseL.length === 0, noiseL.join());
      check('MLA3 text: every card\'s power rows match its powers',
        mla3.every((c) => rowsL.filter((r) => r.key.startsWith(`mla3:${c.id}:power:`)).length === c.versions[0].powers.length),
        mla3.map((c) => `${c.id}:${rowsL.filter((r) => r.key.startsWith(`mla3:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).filter((s) => { const [a, b] = s.split(':')[1].split('/'); return a !== b; }).join());
    }
  }

  // MSL1 is read by scripts/msh/gridbooks.py (msl1-overrides.json), with the
  // survey's decisions applied as it recommends (msl1.md; Nate 2026-10-31).
  // Every card is in the Adventure Book: four opponents inside the chapters
  // (printed 4, 9 and 12) and the roster's fifteen (printed 26-32). The
  // registry fields whose absence roster.py would not stop on
  // (opponent_indented_paragraphs, art_boxes, speck_lines) are each pinned
  // here by what they change.
  if (data.npcs.characters.some((c) => c.book === 'msl1')) {
    const msl1 = data.npcs.characters.filter((c) => c.book === 'msl1');
    const blocksS = msl1.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkS = (id, i = 0) => msl1.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamS = (t) => msl1.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const powersS = (id) => msl1.find((c) => c.id === id)?.versions[0].powers.map((p) => p.name).join() || '';
    const playedS = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MSL1: 19 characters, each id ending -msl1 with one version and one block, the five X-Factor heroes as X-Factor, 14 under the book\'s title, and no name starting The',
      msl1.length === 19 && msl1.every((c) => c.id.endsWith('-msl1') && c.versions.length === 1 && c.versions[0].blocks.length === 1)
      && teamS('X-Factor') === 'Archangel,Beast,Cyclops,Iceman,Marvel Girl'
      && msl1.filter((c) => c.team === 'MSL1 X-Terminate').length === 14
      && !msl1.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${msl1.length} ${[...new Set(msl1.map((c) => c.team))]}`);
    check('MSL1: the cards sort by the Adventure page each starts on, the four chapter opponents (4 to 12) before the roster (26 to 32)',
      msl1.map((c) => c.id).join() === ['pestilence', 'war', 'caliban', 'sunstroke', 'angel-clone', 'beast-clone', 'cyclops-clone', 'iceman-clone',
        'marvel-girl-clone', 'professor-x-clone', 'apocalypse', 'mister-sinister', 'dominus', 'x-terminator-robots', 'archangel', 'beast',
        'cyclops', 'iceman', 'marvel-girl'].map((id) => `${id}-msl1`).join()
      && msl1.map((c) => c.versions[0].blocks[0].page).join() === '4,4,9,12,26,26,27,27,27,28,29,29,30,30,31,31,31,32,32',
      msl1.map((c) => `${c.id}:${c.versions[0].blocks[0].page}`).join());
    check('MSL1: 19 one-line grids, none labelled, none ranks only and none with a derived total',
      blocksS.length === 19 && blocksS.every(({ b }) => b.kind === 'line' && !b.label && !b.rank_only && !b.karma_derived && !b.health_derived),
      blocksS.map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}`).join());
    const fixesS = ['cyclops-clone-msl1', 'iceman-clone-msl1', 'x-terminator-robots-msl1'].map((id) => {
      const o = blkS(id)?.override;
      const v = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
      const also = (o?.also || []).map((a) => ` ${a.field} ${v(a.printed)}>${v(a.corrected)}`).join('');
      return `${id} ${o?.verdict} ${o?.field} ${v(o?.printed)}>${v(o?.corrected)}${also} plays ${playedS(id)}`;
    });
    check('MSL1: the three misprints keep the printed value and carry the corrected one (Cyclops (Clone)\'s F 6 Ex as 6 Ty, Iceman (Clone)\'s Health 56 and Karma 20 as 42 and 16, the X-Terminator Robots\' F 50 In as 50 Am)',
      fixesS.join(' | ') === [
        'cyclops-clone-msl1 misprint F 6 Ex>6 Ty plays 42/50',
        'iceman-clone-msl1 misprint health 56>42 karma 20>16 plays 42/16',
        'x-terminator-robots-msl1 misprint F 50 In>50 Am plays 255/60',
      ].join(' | ')
      && bookNpc({ character: 'cyclops-clone-msl1' }).snapshot?.abilities.fighting.rank === 'typical'
      && bookNpc({ character: 'x-terminator-robots-msl1' }).snapshot?.abilities.fighting.rank === 'amazing'
      && playedS('iceman-msl1') === '56/20',
      `${fixesS.join(' | ')} iceman-msl1 ${playedS('iceman-msl1')}`);
    const domS = bookNpc({ character: 'dominus-msl1' }).snapshot;
    check('MSL1: Dominus\'s S N/A is kept as printed and plays Shift 0, which his printed Health 1020 bears out, his E Class 1000 and R Shift X',
      blkS('dominus-msl1')?.override?.verdict === 'as_printed' && blkS('dominus-msl1')?.override?.printed === 'N/A'
      && blkS('dominus-msl1')?.abilities[2].slice(1).join(' ') === '0 '
      && domS?.abilities.strength.rank === 'shift-0' && domS?.abilities.endurance.rank === 'class-1000' && domS?.abilities.reason.rank === 'shift-x'
      && playedS('dominus-msl1') === '1020/255',
      `${blkS('dominus-msl1')?.abilities[2]} ${JSON.stringify(domS?.abilities.strength)} ${playedS('dominus-msl1')}`);
    const ovS = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'msl1-overrides.json'), 'utf8')).overrides;
    const textS = ovS.filter((o) => o.verdict === 'text');
    check('MSL1: 22 overrides: three misprints, one as printed and 18 text verdicts (the clones\' Slim and Bobby quotes, then 16 printed bullets read as a letter e over eight power rows), and only those four blocks carry one',
      ovS.length === 22 && ovS.filter((o) => o.verdict === 'misprint').length === 3 && ovS.filter((o) => o.verdict === 'as_printed').length === 1
      && textS.map((o) => o.match.row.replace(/^msl1:/, '')).join() === ['cyclops-clone-msl1:background', 'iceman-clone-msl1:background',
        'apocalypse-msl1:power:1', 'cyclops-msl1:power:1', 'cyclops-msl1:power:1', 'cyclops-msl1:power:1',
        'iceman-clone-msl1:power:1', 'iceman-clone-msl1:power:1', 'iceman-msl1:power:1', 'iceman-msl1:power:1', 'iceman-msl1:power:1',
        'marvel-girl-clone-msl1:power:1', 'marvel-girl-msl1:power:1',
        'mister-sinister-msl1:power:1', 'mister-sinister-msl1:power:1', 'mister-sinister-msl1:power:1', 'mister-sinister-msl1:power:1',
        'sunstroke-msl1:power:1'].join()
      && blocksS.filter(({ b }) => b.override).map(({ id }) => id).join() === 'cyclops-clone-msl1,iceman-clone-msl1,dominus-msl1,x-terminator-robots-msl1',
      JSON.stringify(ovS.map((o) => [o.verdict, o.match])));
    const powS = msl1.flatMap((c) => c.versions[0].powers);
    check('MSL1: 54 powers across all 19 cards, 19 of them linked to the UPB; Sunstroke has two (opponent_indented_paragraphs), Archangel\'s Winged Missiles is a power of its own and Cyclops (Clone)\'s Partial Invulnerability is spelt right (speck_lines)',
      powS.length === 54 && powS.filter((p) => p.upb).length === 19 && msl1.every((c) => c.versions[0].powers.length)
      && powersS('sunstroke-msl1') === 'Energy Conversion,Costume'
      && powersS('archangel-msl1') === 'Flight,Winged Missiles,Body Armor'
      && powersS('cyclops-clone-msl1') === 'Optic Blast,Partial Invulnerability',
      `${powS.length} ${powS.filter((p) => p.upb).length} ${powersS('sunstroke-msl1')} | ${powersS('archangel-msl1')} | ${powersS('cyclops-clone-msl1')}`);
    const bookS = data.npcs.books.find((b) => b.slug === 'msl1');
    const choicesS = msl1.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MSL1: the book reads Adventure 4-12 and 26-32, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookS?.ranges) === '[{"part":"Adventure","pages":[[4,12],[26,32]]}]'
      && tagline(bookNpc({ character: 'pestilence-msl1' }).snapshot).startsWith('MSL1 X-Terminate, Adventure p.4;')
      && tagline(bookNpc({ character: 'marvel-girl-msl1' }).snapshot).startsWith('MSL1 X-Terminate, Adventure p.32;')
      && choicesS.every((n) => n === 1),
      `${JSON.stringify(bookS?.ranges)} ${tagline(bookNpc({ character: 'pestilence-msl1' }).snapshot)} ${msl1.map((c, i) => `${c.id}:${choicesS[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsS = ['pestilence-msl1', 'caliban-msl1', 'sunstroke-msl1', 'professor-x-clone-msl1', 'apocalypse-msl1', 'mister-sinister-msl1',
      'archangel-msl1', 'beast-msl1', 'cyclops-msl1', 'marvel-girl-msl1'].map((id) => playedS(id)).join();
    check('MSL1: cards play their printed Health and Karma (Pestilence 48/20, Caliban 100/76, Sunstroke 70/26, Professor X (Clone) 50/165, Apocalypse 160/50, Mister Sinister 150/170, Archangel 120/26, Beast 130/50, Cyclops 76/70, Marvel Girl 56/80)',
      playsS === '48/20,100/76,70/26,50/165,160/50,150/170,120/26,130/50,76/70,56/80', playsS);
    // The text verdicts and speck lines move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys and by a
    // few words, never a sentence of the book in this file.
    const sqlS = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'msl1', 'book-text.sql');
    if (!existsSync(sqlS)) {
      check(`MSL1: skipped the text checks: no ${rel(sqlS) || sqlS}`, true);
    } else {
      const rowsS = [...readFileSync(sqlS, 'utf8').matchAll(/VALUES \('([^']+)', 'msl1', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entS = new Set(rowsS.map((r) => r.key.split(':')[1]));
      const bodyS = (row) => rowsS.find((r) => r.key === row)?.body || '';
      // Row 24b read every quote mark on the page: 17 rows, 31 marks (18
      // double, 13 single), each printed as read once the two clone verdicts
      // were applied. Beast's feet mark (printed 31) stays a single.
      const markedS = rowsS.filter((r) => /["']/.test(r.body));
      const marksS = (re) => markedS.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MSL1 text: 100 rows over all 19 entries, no row with an odd count of double quotes, and the 17 rows holding 31 quote marks (18 double, 13 single) that row 24b read on the page',
        rowsS.length === 100 && entS.size === 19 && msl1.every((c) => entS.has(c.id))
        && !rowsS.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedS.length === 17 && marksS(/"/g) === 18 && marksS(/'/g) === 13
        && bodyS('msl1:beast-msl1:power:5').includes('30\''),
        `${rowsS.length} ${entS.size} ${rowsS.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)} ${markedS.length} ${marksS(/"/g)} ${marksS(/'/g)}`);
      const countS = (row, s) => (rowsS.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MSL1 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textS.length === 18 && textS.every((o) => countS(o.match.row, o.printed) === 1 && countS(o.match.row, o.read) === 0),
        textS.map((o) => `${o.match.row} ${countS(o.match.row, o.printed)}/${countS(o.match.row, o.read)}`).join(' | '));
      const noiseS = rowsS.filter((r) => /[|\\~_\u2019]/.test(r.body) || /\b(Il|Ill|lf|ln|lt)\b/.test(r.body)).map((r) => r.key.replace(/^msl1:/, ''));
      check('MSL1 text: no row carries a bar, a backslash, a tilde, an underscore, a curly mark or an l for a capital I',
        noiseS.length === 0, noiseS.join());
      check('MSL1 text: every card\'s power rows match its powers, and the four chapter opponents carry no background',
        msl1.every((c) => rowsS.filter((r) => r.key.startsWith(`msl1:${c.id}:power:`)).length === c.versions[0].powers.length)
        && msl1.filter((c) => !entS.has(c.id) || !rowsS.some((r) => r.key === `msl1:${c.id}:background`)).map((c) => c.id).join() === 'pestilence-msl1,war-msl1,caliban-msl1,sunstroke-msl1',
        msl1.map((c) => `${c.id}:${rowsS.filter((r) => r.key.startsWith(`msl1:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).join());
      // What each registry fix changes in the text, read on the page (row 24a):
      // Sunstroke's indented bullets stay in his Energy Conversion, Chapter 1's
      // INTERLUDE banner no longer ends Pestilence's Disease, the clones' and
      // Archangel's Real Names end in III, and Marvel Girl's Telekinesis opens
      // on IN.
      check('MSL1 text: Sunstroke\'s Energy Conversion keeps Light and Gliding, Pestilence\'s Disease carries no INTERLUDE banner, both Worthingtons read III, and Marvel Girl\'s Telekinesis opens on IN',
        /\bLight\b/.test(bodyS('msl1:sunstroke-msl1:power:1')) && /\bGliding\b/.test(bodyS('msl1:sunstroke-msl1:power:1'))
        && !/INTERLUDE/i.test(bodyS('msl1:pestilence-msl1:power:1'))
        && ['angel-clone-msl1', 'archangel-msl1'].every((id) => countS(`msl1:${id}:background`, 'Worthington III') === 1)
        && bodyS('msl1:marvel-girl-msl1:power:1').startsWith('IN '),
        ['sunstroke-msl1:power:1', 'pestilence-msl1:power:1', 'angel-clone-msl1:background', 'archangel-msl1:background', 'marvel-girl-msl1:power:1']
          .map((k) => `${k} ${bodyS('msl1:' + k).length}`).join(' | '));
    }
  }

  // MSL2 is read by scripts/msh/gridbooks.py (msl2-overrides.json), with the
  // survey's decisions applied as it recommends (msl2.md; Nate 2026-10-31).
  // Every card is in the Adventure Book: the two Player Characters (printed 4
  // and 5), the Debris Creature inside Chapter 4 (19) and the roster's five
  // (28-32). The registry fields whose absence roster.py would not stop on
  // (codes_over_numbers, line_grid_resources, title_case_labels,
  // indented_power_heads, entry_ends, line_identity) are each pinned here by
  // what they change.
  if (data.npcs.characters.some((c) => c.book === 'msl2')) {
    const msl2 = data.npcs.characters.filter((c) => c.book === 'msl2');
    const blocksW = msl2.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkW = (id, i = 0) => msl2.find((c) => c.id === id)?.versions[0].blocks[i];
    const teamW = (t) => msl2.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const powersW = (id) => msl2.find((c) => c.id === id)?.versions[0].powers.map((p) => p.name).join() || '';
    const playedW = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MSL2: 8 characters, each id ending -msl2 with one version, Power Man and She-Hulk as Fantastic Four, six under the book\'s title, and no name starting The',
      msl2.length === 8 && msl2.every((c) => c.id.endsWith('-msl2') && c.versions.length === 1)
      && teamW('Fantastic Four') === 'Power Man,She-Hulk'
      && msl2.filter((c) => c.team === 'MSL2 Warlord of Baluur').length === 6
      && !msl2.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${msl2.length} ${[...new Set(msl2.map((c) => c.team))]}`);
    check('MSL2: the cards sort by the Adventure page each starts on, the two Player Characters (4, 5) and the Debris Creature (19) before the roster (28 to 32), with Nick Fury and Typical SHIELD Operative named as decision 5 gives',
      msl2.map((c) => c.id).join() === ['power-man', 'she-hulk', 'debris-creature', 'blastaar', 'nick-fury', 'negalisk', 'stygorr',
        'typical-shield-operative'].map((id) => `${id}-msl2`).join()
      && msl2.map((c) => c.versions[0].blocks[0].page).join() === '4,5,19,28,29,30,31,32'
      && msl2.find((c) => c.id === 'nick-fury-msl2')?.name === 'Nick Fury'
      && msl2.find((c) => c.id === 'typical-shield-operative-msl2')?.name === 'Typical SHIELD Operative',
      msl2.map((c) => `${c.id}:${c.name}:${c.versions[0].blocks[0].page}`).join());
    check('MSL2: 9 one-line grids, Stygorr\'s two labelled (Stygorr, Lew Shiner), none ranks only (codes_over_numbers) and none with a derived total',
      blocksW.length === 9 && blocksW.every(({ b }) => b.kind === 'line' && !b.rank_only && !b.karma_derived && !b.health_derived)
      && blocksW.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'stygorr-msl2:Stygorr,stygorr-msl2:Lew Shiner',
      blocksW.map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}`).join());
    check('MSL2: each grid keeps its own Resources and Popularity (line_grid_resources), Lew Shiner\'s his own (form_resources)',
      blocksW.map(({ b }) => `${b.resources}/${b.popularity}`).join() === 'PR (4)/18,EX (20)/30,0/0,EX(20)/2,AM (50)/50,0/0,AM (50)/0,AM (50)/0,EX (20)/10',
      blocksW.map(({ b }) => `${b.resources}/${b.popularity}`).join());
    const styW = blkW('stygorr-msl2')?.override;
    const vW = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
    const fixW = `${styW?.verdict} ${styW?.field} ${vW(styW?.printed)}>${vW(styW?.corrected)}${(styW?.also || []).map((a) => ` ${a.field} ${vW(a.printed)}>${vW(a.corrected)}`).join('')} plays ${playedW('stygorr-msl2')}`;
    const styFormsW = (bookNpc({ character: 'stygorr-msl2' }).snapshot?.forms || []).map((f) => `${f.name} ${f.health}/${f.karma}`).join();
    check('MSL2: Stygorr\'s misprint keeps the printed row (six numbers under seven codes, P blank) and carries the corrected E 20, R 40 and P 30, so he plays 110/100, one NPC whose second form, Lew Shiner, plays 28/100',
      fixW === 'misprint P null Rm>30 Rm E 40 Ex>20 Ex R 30 In>40 In plays 110/100'
      && bookNpc({ character: 'stygorr-msl2' }).snapshot?.abilities.endurance.number === 20
      && bookNpc({ character: 'stygorr-msl2' }).snapshot?.abilities.reason.rank === 'incredible'
      && styFormsW === 'Stygorr 110/100,Lew Shiner 28/100',
      `${fixW} | ${styFormsW}`);
    const ovW = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'msl2-overrides.json'), 'utf8')).overrides;
    const textW = ovW.filter((o) => o.verdict === 'text');
    check('MSL2: nine overrides: one misprint and eight text verdicts (row 26a\'s Howling Commandos quote and row 27a\'s seven), and only Stygorr\'s block carries one',
      ovW.length === 9 && ovW.filter((o) => o.verdict === 'misprint').length === 1
      && textW.map((o) => o.match.row.replace(/^msl2:/, '')).join() === ['nick-fury-msl2:notes', 'nick-fury-msl2:power:3', 'stygorr-msl2:power:5',
        'stygorr-msl2:power:5', 'typical-shield-operative-msl2:power:2', 'typical-shield-operative-msl2:power:2', 'typical-shield-operative-msl2:power:2',
        'typical-shield-operative-msl2:power:2'].join()
      && blocksW.filter(({ b }) => b.override).map(({ id, i }) => `${id}:${i}`).join() === 'stygorr-msl2:0',
      JSON.stringify(ovW.map((o) => [o.verdict, o.match])));
    const powW = msl2.flatMap((c) => c.versions[0].powers);
    check('MSL2: 27 powers across all 8 cards, 15 of them linked to the UPB; She-Hulk\'s labels are not powers (title_case_labels), the Debris Creature keeps Tentacles (indented_power_heads) and the four KNOWN POWERS lines open on their first power (subhead_line_powers)',
      powW.length === 27 && powW.filter((p) => p.upb).length === 15 && msl2.every((c) => c.versions[0].powers.length)
      && powersW('she-hulk-msl2') === 'Body Armor,Leaping,Resistances'
      && powersW('debris-creature-msl2') === 'Body Armor,Tentacles'
      && powersW('nick-fury-msl2') === 'Body Armor,Weapons,Reduced Aging'
      && powersW('stygorr-msl2') === 'Alter Ego,Body Armor,Cosmic Control Rod,Flight,Matter Fluctuation'
      && powersW('typical-shield-operative-msl2') === 'Body Armor,Weapons',
      `${powW.length} ${powW.filter((p) => p.upb).length} ${['she-hulk', 'debris-creature', 'nick-fury', 'stygorr', 'typical-shield-operative'].map((id) => powersW(`${id}-msl2`)).join(' | ')}`);
    const idW = msl2.map((c) => c.versions[0].identity.join('/')).join();
    check('MSL2: the six real-name lines are identities (line_identity), and the Debris Creature and the operative print none',
      idW === 'Luke Cage,Jennifer Walters,,Blastaar of Baluur,Nicholas Joseph Fury,Crotakeetok,Stygorr/Lew Shiner,', idW);
    const bookW = data.npcs.books.find((b) => b.slug === 'msl2');
    const choicesW = msl2.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MSL2: the book reads Adventure 4-5, 19 and 28-32, a card cites its Adventure page, and every card is one GM choice, Stygorr\'s two forms included',
      JSON.stringify(bookW?.ranges) === '[{"part":"Adventure","pages":[[4,5],[19,19],[28,32]]}]'
      && tagline(bookNpc({ character: 'power-man-msl2' }).snapshot).startsWith('MSL2 Warlord of Baluur, Adventure p.4;')
      && tagline(bookNpc({ character: 'typical-shield-operative-msl2' }).snapshot).startsWith('MSL2 Warlord of Baluur, Adventure p.32;')
      && choicesW.every((n) => n === 1),
      `${JSON.stringify(bookW?.ranges)} ${tagline(bookNpc({ character: 'power-man-msl2' }).snapshot)} ${msl2.map((c, i) => `${c.id}:${choicesW[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsW = ['power-man-msl2', 'she-hulk-msl2', 'debris-creature-msl2', 'blastaar-msl2', 'nick-fury-msl2', 'negalisk-msl2',
      'typical-shield-operative-msl2'].map((id) => playedW(id)).join();
    check('MSL2: cards play their printed Health and Karma (Power Man 130/36, She-Hulk 175/36, Debris Creature 80/10, Blastaar 180/40, Nick Fury 100/50, Negalisk 220/14, Typical SHIELD Operative 46/22)',
      playsW === '130/36,175/36,80/10,180/40,100/50,220/14,46/22', playsW);
    // The text verdicts and entry_ends move only the book's text, which is
    // msh_book_text's: read the generated .sql in the cache, by keys and by a
    // few words, never a sentence of the book in this file.
    const sqlW = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'msl2', 'book-text.sql');
    if (!existsSync(sqlW)) {
      check(`MSL2: skipped the text checks: no ${rel(sqlW) || sqlW}`, true);
    } else {
      const rowsW = [...readFileSync(sqlW, 'utf8').matchAll(/VALUES \('([^']+)', 'msl2', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entW = new Set(rowsW.map((r) => r.key.split(':')[1]));
      const bodyW = (row) => rowsW.find((r) => r.key === row)?.body || '';
      // Row 27b read every quote mark on the page and found none wrong; the
      // doubles are five pairs, each printed and built as a pair.
      const markedW = rowsW.filter((r) => /["']/.test(r.body));
      const marksW = (re) => markedW.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MSL2 text: 41 rows over all 8 entries, no row with an odd count of double quotes, and the 16 rows holding 27 quote marks (10 double, 17 single)',
        rowsW.length === 41 && entW.size === 8 && msl2.every((c) => entW.has(c.id))
        && !rowsW.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedW.length === 16 && marksW(/"/g) === 10 && marksW(/'/g) === 17,
        `${rowsW.length} ${entW.size} ${rowsW.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)} ${markedW.length} ${marksW(/"/g)} ${marksW(/'/g)}`);
      const countW = (row, s) => (rowsW.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MSL2 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textW.length === 8 && textW.every((o) => countW(o.match.row, o.printed) === 1 && countW(o.match.row, o.read) === 0),
        textW.map((o) => `${o.match.row} ${countW(o.match.row, o.printed)}/${countW(o.match.row, o.read)}`).join(' | '));
      const noiseW = rowsW.filter((r) => /[|\\~_\u2019]/.test(r.body) || /\b(Il|Ill|lf|ln|lt)\b/.test(r.body)).map((r) => r.key.replace(/^msl2:/, ''));
      check('MSL2 text: no row carries a bar, a backslash, a tilde, an underscore, a curly mark or an l for a capital I',
        noiseW.length === 0, noiseW.join());
      check('MSL2 text: every card\'s power rows match its powers, and only the Debris Creature carries no notes',
        msl2.every((c) => rowsW.filter((r) => r.key.startsWith(`msl2:${c.id}:power:`)).length === c.versions[0].powers.length)
        && msl2.filter((c) => !rowsW.some((r) => r.key === `msl2:${c.id}:notes`)).map((c) => c.id).join() === 'debris-creature-msl2',
        msl2.map((c) => `${c.id}:${rowsW.filter((r) => r.key.startsWith(`msl2:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).join());
      // What each registry fix changes in the text, read on the page (rows
      // 26a and 26b): Tentacles ends before Chapter 4's An Alien's Wrath
      // (entry_ends), no grid's Resources or Popularity line is left in a
      // row (line_grid_resources), and Nick Fury's Body Armor reads right
      // (speck_lines).
      check('MSL2 text: Tentacles ends before An Alien\'s Wrath, no Resources or Popularity line is left in the text, and no row reads Booy',
        bodyW('msl2:debris-creature-msl2:power:2').length > 0 && !/Alien|Wrath/.test(bodyW('msl2:debris-creature-msl2:power:2'))
        && !rowsW.some((r) => /Popularity|Resources\s*:/i.test(r.body)) && !rowsW.some((r) => /Booy/.test(r.body)),
        `Tentacles ${bodyW('msl2:debris-creature-msl2:power:2').length} ${rowsW.filter((r) => /Popularity|Resources\s*:|Booy/i.test(r.body)).map((r) => r.key)}`);
    }
  }

  // MSL3 is read by scripts/msh/gridbooks.py (msl3-overrides.json), with the
  // survey's decisions applied as it recommends (msl3.md; Nate 2026-10-31).
  // Every card is a creature or bystander inside the Adventure Book's
  // chapters (printed 5 to 30), one one-line grid each, filed under the
  // book's title. Decision 8: the two machines print no Karma line and none
  // is derived, so no MSL3 block joins MH2's karma_derived list.
  if (data.npcs.characters.some((c) => c.book === 'msl3')) {
    const msl3 = data.npcs.characters.filter((c) => c.book === 'msl3');
    const blocksA = msl3.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blkA = (id, i = 0) => msl3.find((c) => c.id === id)?.versions[0].blocks[i];
    const powersA = (id) => msl3.find((c) => c.id === id)?.versions[0].powers.map((p) => p.name).join() || '';
    const playedA = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MSL3: 8 characters, each id ending -msl3 with one version, all under the book\'s title, and no name starting The',
      msl3.length === 8 && msl3.every((c) => c.id.endsWith('-msl3') && c.versions.length === 1)
      && msl3.every((c) => c.team === 'MSL3 Spore of Arthros')
      && !msl3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${msl3.length} ${[...new Set(msl3.map((c) => c.team))]}`);
    check('MSL3: the cards sort by the Adventure page each starts on, 5 to 30, and the Flying Stallion is named Ashta',
      msl3.map((c) => c.id).join() === ['nop-yaan-peasant', 'flying-robotic-snake', 'ice-bat', 'torr', 'vapor-wasp', 'bubble-beast', 'ashta',
        'robotic-dragon'].map((id) => `${id}-msl3`).join()
      && msl3.map((c) => c.versions[0].blocks[0].page).join() === '5,6,13,18,18,21,22,30'
      && msl3.find((c) => c.id === 'ashta-msl3')?.versions[0].identity.join() === 'Flying Stallion',
      msl3.map((c) => `${c.id}:${c.name}:${c.versions[0].blocks[0].page}`).join());
    check('MSL3: 8 one-line grids, none labelled, none ranks only, none with a derived total, and none printing Resources or Popularity',
      blocksA.length === 8 && blocksA.every(({ b }) => b.kind === 'line' && !b.label && !b.rank_only && !b.karma_derived && !b.health_derived
        && b.resources === null && b.popularity === null),
      blocksA.map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}:${b.resources}/${b.popularity}`).join());
    const vA = (x) => (x && typeof x === 'object' ? `${x.number} ${x.code}` : x);
    const fixA = blocksA.filter(({ b }) => b.override).map(({ id, b: { override: o } }) => `${id} ${o.verdict} ${o.field} ${vA(o.printed)}>${vA(o.corrected)}`
      + (o.also || []).map((a) => ` ${a.verdict} ${a.field} ${vA(a.printed)}`).join('')).join(' | ');
    check('MSL3: Ashta\'s misprint keeps the printed A 10 Ex and plays the corrected 20 Ex; the Flying Robotic Snake\'s Karma and the Robotic Dragon\'s Health (See text) and Karma are kept as printed (decision 8)',
      fixA === 'flying-robotic-snake-msl3 as_printed karma null>undefined | ashta-msl3 misprint A 10 Ex>20 Ex | robotic-dragon-msl3 as_printed health See text>undefined as_printed karma null'
      && bookNpc({ character: 'ashta-msl3' }).snapshot?.abilities.agility.number === 20
      && bookNpc({ character: 'ashta-msl3' }).snapshot?.abilities.agility.rank === 'excellent'
      && blkA('flying-robotic-snake-msl3')?.karma === null && blkA('robotic-dragon-msl3')?.health === 'See text',
      `${fixA} | ${JSON.stringify(bookNpc({ character: 'ashta-msl3' }).snapshot?.abilities.agility)}`);
    const ovA = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'msl3-overrides.json'), 'utf8')).overrides;
    const textA = ovA.filter((o) => o.verdict === 'text');
    check('MSL3: seven overrides: one misprint, two as printed and four text verdicts (the Ice Bat\'s two, the Snake\'s If, Torr\'s one prose bullet), and only those three blocks carry one',
      ovA.length === 7 && ovA.filter((o) => o.verdict === 'misprint').length === 1 && ovA.filter((o) => o.verdict === 'as_printed').length === 2
      && textA.map((o) => o.match.row.replace(/^msl3:/, '')).join() === 'ice-bat-msl3:power:2,ice-bat-msl3:power:3,flying-robotic-snake-msl3:prose,torr-msl3:prose'
      && blocksA.filter(({ b }) => b.override).map(({ id, i }) => `${id}:${i}`).join() === 'flying-robotic-snake-msl3:0,ashta-msl3:0,robotic-dragon-msl3:0',
      JSON.stringify(ovA.map((o) => [o.verdict, o.match])));
    const powA = msl3.flatMap((c) => c.versions[0].powers);
    check('MSL3: 13 powers across four cards, 8 of them linked to the UPB (each one\'s Body Armor and Flight)',
      powA.length === 13 && powA.filter((p) => p.upb).length === 8 && msl3.filter((c) => c.versions[0].powers.length).length === 4
      && powersA('ice-bat-msl3') === 'Body Armor,Flight,Ice Entrapment,Ice Missiles'
      && powersA('vapor-wasp-msl3') === 'Body Armor,Flight,Sting,Vapor Form'
      && powersA('bubble-beast-msl3') === 'Body Armor,Flight,Sphere Projection'
      && powersA('ashta-msl3') === 'Body Armor,Flight'
      && powA.filter((p) => p.upb).map((p) => p.name).every((n) => n === 'Body Armor' || n === 'Flight'),
      `${powA.length} ${powA.filter((p) => p.upb).length} ${['ice-bat', 'vapor-wasp', 'bubble-beast', 'ashta'].map((id) => powersA(`${id}-msl3`)).join(' | ')}`);
    const idA = msl3.map((c) => c.versions[0].identity.join('/')).join();
    check('MSL3: two identity lines, Torr\'s and Ashta\'s, and the rest print none',
      idA === ',,,Alien Trader,,,Flying Stallion,', idA);
    const bookA = data.npcs.books.find((b) => b.slug === 'msl3');
    const choicesA = msl3.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MSL3: the book reads Adventure 5-30, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookA?.ranges) === '[{"part":"Adventure","pages":[[5,30]]}]'
      && tagline(bookNpc({ character: 'nop-yaan-peasant-msl3' }).snapshot).startsWith('MSL3 Spore of Arthros, Adventure p.5;')
      && tagline(bookNpc({ character: 'robotic-dragon-msl3' }).snapshot).startsWith('MSL3 Spore of Arthros, Adventure p.30;')
      && choicesA.every((n) => n === 1),
      `${JSON.stringify(bookA?.ranges)} ${tagline(bookNpc({ character: 'nop-yaan-peasant-msl3' }).snapshot)} ${msl3.map((c, i) => `${c.id}:${choicesA[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsA = msl3.map((c) => playedA(c.id)).join();
    check('MSL3: cards play their printed Health and Karma (Nop Yaan Peasant 22/10, the Snake 80 and no Karma, Ice Bat 90/12, Torr 46/42, Vapor Wasp 60/8, Bubble Beast 70/16, Ashta 90/10 on the corrected A, the Dragon neither)',
      playsA === '22/10,80/null,90/12,46/42,60/8,70/16,90/10,null/null', playsA);
    // The text verdicts move only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by a few words, never
    // a sentence of the book in this file.
    const sqlA = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'msl3', 'book-text.sql');
    if (!existsSync(sqlA)) {
      check(`MSL3: skipped the text checks: no ${rel(sqlA) || sqlA}`, true);
    } else {
      const rowsA = [...readFileSync(sqlA, 'utf8').matchAll(/VALUES \('([^']+)', 'msl3', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entA = new Set(rowsA.map((r) => r.key.split(':')[1]));
      // Row 30b read every quote mark on the page and found none wrong; the
      // doubles are Torr's four quotations, each printed and built as a pair.
      const markedA = rowsA.filter((r) => /["']/.test(r.body));
      const marksA = (re) => markedA.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MSL3 text: 21 rows over all 8 entries, no row with an odd count of double quotes, and the 8 rows holding 37 quote marks (8 double, 29 single)',
        rowsA.length === 21 && entA.size === 8 && msl3.every((c) => entA.has(c.id))
        && !rowsA.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedA.length === 8 && marksA(/"/g) === 8 && marksA(/'/g) === 29,
        `${rowsA.length} ${entA.size} ${rowsA.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)} ${markedA.length} ${marksA(/"/g)} ${marksA(/'/g)}`);
      const countA = (row, s) => (rowsA.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MSL3 text: each text verdict is applied, its printed fragment in its row and the misread gone',
        textA.length === 4 && textA.every((o) => countA(o.match.row, o.printed) === 1 && countA(o.match.row, o.read) === 0),
        textA.map((o) => `${o.match.row} ${countA(o.match.row, o.printed)}/${countA(o.match.row, o.read)}`).join(' | '));
      const noiseA = rowsA.filter((r) => /[|\\~_\u2019]/.test(r.body) || /\b(Il|Ill|lf|ln|lt)\b/.test(r.body)).map((r) => r.key.replace(/^msl3:/, ''));
      check('MSL3 text: no row carries a bar, a backslash, a tilde, an underscore, a curly mark or an l for a capital I',
        noiseA.length === 0, noiseA.join());
      check('MSL3 text: every card\'s power rows match its powers, each card carries one prose row, and none a notes row',
        msl3.every((c) => rowsA.filter((r) => r.key.startsWith(`msl3:${c.id}:power:`)).length === c.versions[0].powers.length)
        && msl3.every((c) => rowsA.filter((r) => r.key === `msl3:${c.id}:prose`).length === 1)
        && !rowsA.some((r) => r.key.endsWith(':notes')),
        msl3.map((c) => `${c.id}:${rowsA.filter((r) => r.key.startsWith(`msl3:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).join());
    }
  }

  // MSL4 is read by scripts/msh/gridbooks.py (msl4-overrides.json), with the
  // survey's decisions applied as it recommends (msl4.md; Nate 2026-10-31).
  // Every card is in the Adventure Book: the three chapter robots (printed 14
  // and 17) and the roster's seven (27-31), one one-line grid each and
  // Stygorr's human form a second, all filed under the book's title. The two
  // reader fields MSL4 taught (repeated_power_heads in gridbooks.py,
  // role_brackets in npcs.py) and the registry fields roster.py would not stop
  // on are each pinned here by what they change. No grid prints a derived
  // Karma, so no MSL4 block joins MH2's karma_derived list.
  if (data.npcs.characters.some((c) => c.book === 'msl4')) {
    const msl4 = data.npcs.characters.filter((c) => c.book === 'msl4');
    const blocksB = msl4.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const powersB = (id) => msl4.find((c) => c.id === id)?.versions[0].powers.map((p) => p.name).join() || '';
    const playedB = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('MSL4: 10 characters, each id ending -msl4 with one unlabelled version, all under the book\'s title, and no name starting The',
      msl4.length === 10 && msl4.every((c) => c.id.endsWith('-msl4') && c.versions.length === 1 && !c.versions[0].label)
      && msl4.every((c) => c.team === 'MSL4 Stygian Knight')
      && !msl4.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${msl4.length} ${[...new Set(msl4.map((c) => c.team))]} ${msl4.filter((c) => c.versions[0].label).map((c) => `${c.id}:${c.versions[0].label}`)}`);
    check('MSL4: the cards sort by the Adventure page each starts on, 14 to 31, named as decision 6 gives, each bracket dropped (role_brackets)',
      msl4.map((c) => c.id).join() === ['spy-eye', 'phase-bot', 'spray-bots', 'annihilus', 'mark-i-cyborg', 'mark-ii-cyborg', 'fiona-dunbar',
        'mark-iii-cyborg', 'rigger', 'stygorr'].map((id) => `${id}-msl4`).join()
      && msl4.map((c) => c.versions[0].blocks[0].page).join() === '14,17,17,27,28,28,29,29,30,31'
      && msl4.map((c) => c.name).join() === 'Spy-Eye,Phase-Bot,Spray-Bots,Annihilus,Mark I Cyborg,Mark II Cyborg,Fiona Dunbar,Mark III Cyborg,Rigger,Stygorr',
      msl4.map((c) => `${c.id}:${c.name}:${c.versions[0].blocks[0].page}`).join());
    check('MSL4: 11 one-line grids, Stygorr\'s two labelled (Stygorr, Lew Shiner), none ranks only (codes_over_numbers) and none with a derived total',
      blocksB.length === 11 && blocksB.every(({ b }) => b.kind === 'line' && !b.rank_only && !b.karma_derived && !b.health_derived)
      && blocksB.filter(({ b }) => b.label).map(({ id, b }) => `${id}:${b.label}`).join() === 'stygorr-msl4:Stygorr,stygorr-msl4:Lew Shiner',
      blocksB.map(({ id, b }) => `${id}:${b.kind}:${b.label}:${b.rank_only}:${b.karma_derived}:${b.health_derived}`).join());
    check('MSL4: the three chapter robots print no Resources or Popularity; each roster grid keeps its own (line_grid_resources), Annihilus\'s Popularity -30 (line_popularity_minus) and Lew Shiner\'s his own (form_resources)',
      blocksB.map(({ b }) => `${b.resources}/${b.popularity}`).join()
        === 'null/null,null/null,null/null,MN (75)/-30,FB (2)/0,FB (2)/0,FB (2)/0,FB (2)/0,FB (2)/0,AM (50)/0,AM (50)/0',
      blocksB.map(({ b }) => `${b.resources}/${b.popularity}`).join());
    const ovB = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'msl4-overrides.json'), 'utf8')).overrides;
    const textB = ovB.filter((o) => o.verdict === 'text');
    check('MSL4: ten text verdicts, the Phase-Bot\'s Flight, Stygorr\'s two Matter Fluctuation bullets, Annihilus\'s three Cosmic Control Rod bullets, Rigger\'s Cybernetic Implants one, and three line-end hyphen breaks (Annihilus\'s Cosmic Control Rod, the Phase-Bot\'s two in Image Generation) whose printed fragment no longer reads the shape, and no block carries one (decision 7: every grid adds up)',
      ovB.length === 10 && textB.map((o) => o.match.row).join() === ['phase-bot-msl4:power:3', 'stygorr-msl4:power:4', 'stygorr-msl4:power:4',
        'annihilus-msl4:power:3', 'annihilus-msl4:power:3', 'annihilus-msl4:power:3', 'rigger-msl4:power:1',
        'annihilus-msl4:power:3', 'phase-bot-msl4:power:4', 'phase-bot-msl4:power:4'].map((k) => `msl4:${k}`).join()
      && textB.slice(7).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && !blocksB.some(({ b }) => b.override),
      `${JSON.stringify(ovB.map((o) => [o.verdict, o.match]))} ${blocksB.filter(({ b }) => b.override).map(({ id, i }) => `${id}:${i}`)}`);
    const powB = msl4.flatMap((c) => c.versions[0].powers);
    check('MSL4: 40 powers across nine cards, 13 linked to the UPB; Force Field, Personal on all three Marks (power_heads, repeated_power_heads), the robots\' powers past their indented paragraphs and the next page (opponent_indented_paragraphs, continues), and Fiona Dunbar\'s Equipment not powers (title_case_labels)',
      powB.length === 40 && powB.filter((p) => p.upb).length === 13 && msl4.filter((c) => c.versions[0].powers.length).length === 9
      && powersB('mark-i-cyborg-msl4') === 'Cybernetic Body,ECMs,Flight,Force Field, Personal,Plasma Beam,Sensors,Stun Beam,Targeting System'
      && powersB('mark-ii-cyborg-msl4') === 'Cybernetic Body,ECMs,Flight,Force Field, Personal,Sensors,Stun Beam,Tractor Beams'
      && powersB('mark-iii-cyborg-msl4') === 'Cybernetic Body,ECMs,Flight,Force Field, Personal,Growth,Plasma Beam,Sensors,Stun Beam,Targeting System'
      && powersB('phase-bot-msl4') === 'Elongation (Tentacles),Enhanced Senses (Hearing, Smell),Flight,Image Generation,Phasing'
      && powersB('spray-bots-msl4') === 'Extinguisher Spray,Flight'
      && powersB('stygorr-msl4') === 'Alter Ego,Body Armor,Flight,Matter Fluctuation'
      && powersB('fiona-dunbar-msl4') === '',
      `${powB.length} ${powB.filter((p) => p.upb).length} ${msl4.map((c) => `${c.id}:${powersB(c.id)}`).join(' | ')}`);
    const idB = msl4.map((c) => c.versions[0].identity.map((l) => l.replace(/^Real Name: /, '')).join('/')).join();
    const mark3B = msl4.find((c) => c.id === 'mark-iii-cyborg-msl4')?.versions[0].identity || [];
    check('MSL4: seven identities, each the card\'s Real Name: line (line_identity), the Marks I and II Irrelevant as printed (decision 8) and the Mark III\'s two people on two lines (decision 5); the robots print none',
      msl4.filter((c) => c.versions[0].identity.length).length === 7
      && msl4.every((c) => c.versions[0].identity.every((l, i) => i > 0 || l.startsWith('Real Name: ')))
      && idB.startsWith(',,,Annihilus,Irrelevant,Irrelevant,Fiona Dunbar,') && idB.endsWith(',Ramone Webber,Stygorr/Lew Shiner')
      && mark3B.length === 2 && mark3B[1].includes('"Big Ben"'),
      idB);
    const bookB = data.npcs.books.find((b) => b.slug === 'msl4');
    const choicesB = msl4.map((c) => choices.filter((x) => x.character === c.id).length);
    check('MSL4: the book reads Adventure 14-17 and 27-31, a card cites its Adventure page, and every card is one GM choice',
      JSON.stringify(bookB?.ranges) === '[{"part":"Adventure","pages":[[14,17],[27,31]]}]'
      && tagline(bookNpc({ character: 'spy-eye-msl4' }).snapshot).startsWith('MSL4 Stygian Knight, Adventure p.14;')
      && tagline(bookNpc({ character: 'stygorr-msl4' }).snapshot).startsWith('MSL4 Stygian Knight, Adventure p.31;')
      && choicesB.every((n) => n === 1),
      `${JSON.stringify(bookB?.ranges)} ${tagline(bookNpc({ character: 'spy-eye-msl4' }).snapshot)} ${msl4.map((c, i) => `${c.id}:${choicesB[i]}`).filter((s) => !s.endsWith(':1'))}`);
    const playsB = msl4.map((c) => playedB(c.id)).join();
    const styFormsB = (bookNpc({ character: 'stygorr-msl4' }).snapshot?.forms || []).map((f) => `${f.name} ${f.health}/${f.karma}`).join();
    check('MSL4: cards play their printed Health and Karma, and Stygorr is one NPC whose second form, Lew Shiner, plays 28/100 (decision 4)',
      playsB === '48/18,80/10,58/10,205/70,110/18,90/18,36/18,130/18,14/52,110/100'
      && styFormsB === 'Stygorr 110/100,Lew Shiner 28/100',
      `${playsB} | ${styFormsB}`);
    // The text verdict moves only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by a few words, never
    // a sentence of the book in this file.
    const sqlB = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'msl4', 'book-text.sql');
    if (!existsSync(sqlB)) {
      check(`MSL4: skipped the text checks: no ${rel(sqlB) || sqlB}`, true);
    } else {
      const rowsB = [...readFileSync(sqlB, 'utf8').matchAll(/VALUES \('([^']+)', 'msl4', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const entB = new Set(rowsB.map((r) => r.key.split(':')[1]));
      // Row 33b read every quote mark on the page images and found none
      // wrong: 27 apostrophes, the three feet marks after 10 and four pairs
      // of doubles, Stygorr's closing double among them.
      const markedB = rowsB.filter((r) => /["']/.test(r.body));
      const marksB = (re) => markedB.reduce((n, r) => n + (r.body.match(re) || []).length, 0);
      check('MSL4 text: 55 rows over all 10 entries, no row with an odd count of double quotes, and the 21 rows holding 38 quote marks (8 double, 30 single, 3 of them feet marks after a digit)',
        rowsB.length === 55 && entB.size === 10 && msl4.every((c) => entB.has(c.id))
        && !rowsB.some((r) => (r.body.match(/"/g) || []).length % 2)
        && markedB.length === 21 && marksB(/"/g) === 8 && marksB(/'/g) === 30 && marksB(/\d'/g) === 3,
        `${rowsB.length} ${entB.size} ${rowsB.filter((r) => (r.body.match(/"/g) || []).length % 2).map((r) => r.key)} ${markedB.length} ${marksB(/"/g)} ${marksB(/'/g)} ${marksB(/\d'/g)}`);
      const countB = (row, s) => (rowsB.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      check('MSL4 text: the ten text verdicts are applied, each printed fragment in its row and the misread gone',
        textB.length === 10 && textB.every((o) => countB(o.match.row, o.printed) === 1 && countB(o.match.row, o.read) === 0),
        textB.map((o) => `${o.match.row} ${countB(o.match.row, o.printed)}/${countB(o.match.row, o.read)}`).join(' | '));
      const noiseB = rowsB.filter((r) => /[|\\~_\u2019]/.test(r.body) || /\b(Il|Ill|IIl|lf|ln|lt)\b/.test(r.body)).map((r) => r.key.replace(/^msl4:/, ''));
      check('MSL4 text: no row carries a bar, a backslash, a tilde, an underscore, a curly mark or an l for a capital I (speck_lines mends the seven Marks)',
        noiseB.length === 0, noiseB.join());
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10q, Nate
      // 2026-11-03): MSL4's three are closed up by the text verdicts above, and
      // none is kept on purpose.
      const shapeB = rowsB.flatMap((r) => [...r.body.matchAll(/[a-z]- [A-Za-z]/g)].map(() => r.key.replace(/^msl4:/, ''))).sort();
      check('MSL4 text: no row reads a letter, a hyphen and a space before a word',
        rowsB.length > 0 && shapeB.length === 0, shapeB.join(' '));
      const roster = msl4.filter((c) => c.versions[0].blocks[0].page >= 27);
      check('MSL4 text: every card\'s power rows match its powers, the seven roster cards each a talents and a notes row, Fiona Dunbar\'s None a powers-intro row, and no prose row',
        msl4.every((c) => rowsB.filter((r) => r.key.startsWith(`msl4:${c.id}:power:`)).length === c.versions[0].powers.length)
        && roster.length === 7
        && roster.every((c) => ['talents', 'notes'].every((k) => rowsB.filter((r) => r.key === `msl4:${c.id}:${k}`).length === 1))
        && rowsB.filter((r) => r.key.endsWith(':talents') || r.key.endsWith(':notes')).length === 14
        && rowsB.filter((r) => r.key.endsWith(':powers-intro')).map((r) => r.key).join() === 'msl4:fiona-dunbar-msl4:powers-intro'
        && !rowsB.some((r) => r.key.endsWith(':prose')),
        msl4.map((c) => `${c.id}:${rowsB.filter((r) => r.key.startsWith(`msl4:${c.id}:power:`)).length}/${c.versions[0].powers.length}`).join());
    }
  }

  // ME2 is laid out as ME1 is (scripts/msh/gridbooks.py, me2-overrides.json),
  // with one-line grids in its chapters and Nate's rulings of 2026-10-21
  // (survey me2.md decisions 1 and 5).
  if (data.npcs.characters.some((c) => c.book === 'me2')) {
    const me2 = data.npcs.characters.filter((c) => c.book === 'me2');
    const team = (t) => me2.filter((c) => c.team === t).map((c) => c.name).sort().join();
    check('ME2: 40 characters filed under the Resource Book\'s banners, the eight heroes, and Charon and Modgud under the book\'s title; Actus is an Entity',
      me2.length === 40 && me2.filter((c) => c.summary_only).length === 4
      && team('Entities') === 'Ac,Actus,Death,Gaea,Gal,Galactus,Tus' && team('ME2 Ragnarok and Roll') === 'Charon,Modgud'
      && me2.filter((c) => c.team === 'Ragnarok and Roll Heroes').length === 8 && me2.filter((c) => c.team === 'Olympians').length === 9
      && me2.filter((c) => c.team === 'Asgardians').length === 12 && team('Heliopolitans') === 'Isis,Osiris',
      `${me2.length} ${[...new Set(me2.map((c) => c.team))]}`);
    const zeus = bookNpc({ character: 'zeus-me2', block: 1 });
    check('ME2: the chapter\'s powerless Zeus is a second block on his Resource Book card, a GM choice of its own citing Adventure p.18, not a form',
      choices.filter((c) => c.character === 'zeus-me2').length === 2 && zeus.snapshot?.health === 151 && zeus.name === 'Zeus - Zeus\' Powers'
      && tagline(zeus.snapshot).startsWith('ME2 Ragnarok and Roll, Adventure p.18;') && bookNpc({ character: 'titans-me2', block: 1 }).snapshot?.health === 350
      && bookNpc({ character: 'titans-me2', block: 1 }).name === 'Titans - Hades'
      && !me2.some((c) => c.id === 'zeus-me2' && c.versions.length > 1), `${zeus.name} ${zeus.snapshot && tagline(zeus.snapshot)}`);
    const bill = bookNpc({ character: 'beta-ray-bill-me2' }).snapshot;
    check('ME2: Beta Ray Bill\'s humanoid form, a grid of codes only, is a form on his card (330 and 80)',
      bill?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Beta Ray Bill 330,Humanoid form 80', JSON.stringify(bill?.forms?.map((f) => [f.name, f.health])));
    const chim = bookNpc({ character: 'chimaera-me2' }).snapshot;
    check('ME2: the Chimaera\'s Agility and Endurance, printed 100 Shift X, play as Unearthly',
      chim?.abilities.agility.rank === 'unearthly' && chim.abilities.endurance.rank === 'unearthly' && chim.health === 950, JSON.stringify(chim?.abilities.agility));
    const death = bookNpc({ character: 'death-me2' }).snapshot;
    check('ME2: Death\'s "Health: 20,000" is 20000, his "Karma: Unlimited" is unset, and the Fenris Wolf\'s Popularity, read as a hyphen and a dash, is -5',
      death?.health === 20000 && death.karma === null && bookNpc({ character: 'fenris-wolf-me2' }).snapshot?.abilities.popularity.number === -5,
      `${death?.health} ${death?.karma}`);
    // ME2's text verdicts: one word the page breaks at a line end after its
    // hyphen (marvel-11 leftovers row 10c, Nate 2026-11-03). The text is
    // msh_book_text's: read the generated .sql in the cache, by keys and by the
    // overrides' own fragments, never a word of the book in this file.
    const ovM = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'me2-overrides.json'), 'utf8')).overrides;
    const textM = ovM.filter((o) => o.verdict === 'text');
    check('ME2: four overrides: one as printed, one misprint, one chart misprint and one text verdict, a line-end hyphen break whose printed fragment no longer reads the shape',
      ovM.length === 4 && ['as_printed', 'misprint', 'summary_misprint', 'text'].every((v) => ovM.filter((o) => o.verdict === v).length === 1)
      && textM.every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed)),
      JSON.stringify(ovM.map((o) => o.verdict)));
    const sqlM = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'me2', 'book-text.sql');
    if (!existsSync(sqlM)) {
      check(`ME2: skipped the text checks: no ${rel(sqlM) || sqlM}`, true);
    } else {
      const rowsM = [...readFileSync(sqlM, 'utf8').matchAll(/VALUES \('([^']+)', 'me2', '[^']+', '[^']+', (?:NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, body]) => ({ key, body: body.replace(/''/g, '\'') }));
      const countM = (row, s) => (rowsM.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdictsM = textM.map((o) => `${o.match.row} ${countM(o.match.row, o.printed)}/${countM(o.match.row, o.read)}`);
      check('ME2 text: the text verdict is applied, its printed fragment once in its row and the misread gone',
        rowsM.length === 273 && verdictsM.length === 1 && verdictsM.every((v) => v.endsWith(' 1/0')), verdictsM.filter((v) => !v.endsWith(' 1/0')).join(' | ') || `${rowsM.length} rows`);
      const shapeM = rowsM.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('ME2 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        shapeM.length === 0, shapeM.join(' '));
    }
  }

  // ME3 is laid out as ME1 and ME2 are (scripts/msh/gridbooks.py,
  // me3-overrides.json), with the survey's decisions applied as it recommends
  // (me3.md; Nate 2026-10-30). The registry's card_names, speck_lines,
  // power_heads and header_blocks each change what is built, so each is
  // pinned here by what it changes.
  if (data.npcs.characters.some((c) => c.book === 'me3')) {
    const me3 = data.npcs.characters.filter((c) => c.book === 'me3');
    const blocks3 = me3.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b, i) => ({ id: c.id, i, b }))));
    const blk3 = (id, i = 0) => me3.find((c) => c.id === id)?.versions[0].blocks[i];
    const ver3 = (id) => me3.find((c) => c.id === id)?.versions[0];
    const team3 = (t) => me3.filter((c) => c.team === t).map((c) => c.name).sort().join();
    const played3 = (id, block) => { const s = bookNpc({ character: id, block }).snapshot; return `${s?.health}/${s?.karma}`; };
    check('ME3: 32 characters, each id ending -me3 with one version, filed under the Resource Book\'s banners without The (Entities, Death Gods), the eight heroes as Left Hand of Eternity Heroes (four on the Summary alone) and the rest under the book\'s title, and no name starting The',
      me3.length === 32 && me3.every((c) => c.id.endsWith('-me3') && c.versions.length === 1)
      && team3('Entities') === 'Death,Eternity,Galactus'
      && team3('Death Gods') === 'Hela,Mephisto,Mephisto\'s Demonic Thralls,Mephisto\'s Footsoldiers,Pluto,Pluto\'s Footsoldiers,Seth'
      && team3('Left Hand of Eternity Heroes') === 'Beta Ray Bill,Doc Strange,Firelord,Gladiator,Mantis,Nova,Silver Surfer,Thor'
      && me3.filter((c) => c.summary_only).map((c) => c.name).sort().join() === 'Doc Strange,Nova,Silver Surfer,Thor'
      && me3.filter((c) => c.team === 'ME3 The Left Hand of Eternity').length === 14
      && !me3.some((c) => /^the /i.test(c.name) || /^the-/.test(c.id)),
      `${me3.length} ${[...new Set(me3.map((c) => c.team))]}`);
    check('ME3: the cards sort as the book prints them, the Adventure Book\'s from p.3 to p.28, then the Resource Book\'s from p.2 to p.16, then the Summary\'s four',
      me3.map((c) => c.id).join() === ['gladiator', 'mantis', 'firelord', 'beta-ray-bill', 'nine-headed-serpent', 'vulture-flock', 'keeper', 'charon',
        'dimensional-shambler', 'death', 'eternity', 'galactus', 'mephisto', 'mephisto-s-demonic-thralls', 'mephisto-s-footsoldiers', 'pluto',
        'hela', 'pluto-s-footsoldiers', 'seth', 'uatu', 'voyd', 'dormammu', 'clea', 'dark-dimension-inhabitant-typical', 'mindless-ones',
        'captain-marvel-mar-vell', 'thanos', 'purple-man', 'doc-strange', 'nova', 'silver-surfer', 'thor'].map((id) => `${id}-me3`).join(),
      me3.map((c) => c.id).join());
    check('ME3: 35 blocks: five one-line grids of ranks only (Beta Ray Bill\'s humanoid form, the Nine-Headed Serpent, the Vulture Flock, the Keeper, the Dimensional Shambler), four Summary rows and 26 full blocks',
      blocks3.length === 35
      && blocks3.filter(({ b }) => b.kind === 'line').map(({ id }) => id).join() === ['beta-ray-bill', 'nine-headed-serpent', 'vulture-flock', 'keeper',
        'dimensional-shambler'].map((id) => `${id}-me3`).join()
      && blocks3.filter(({ b }) => b.kind === 'line').every(({ b }) => b.rank_only)
      && blocks3.filter(({ b }) => b.kind === 'summary').map(({ id }) => id).join() === ['doc-strange', 'nova', 'silver-surfer', 'thor'].map((id) => `${id}-me3`).join()
      && blocks3.filter(({ b }) => !b.kind).length === 26,
      blocks3.map(({ id, b }) => `${id}:${b.kind}`).join());
    const bill3 = bookNpc({ character: 'beta-ray-bill-me3' }).snapshot;
    check('ME3: Mephisto\'s grid headed MEPHISTO (w/Galactus) is a second block on his card (header_blocks) and Dormammu\'s unheaded second grid one labelled DORMAMMU (w/Galactus) (a label override), each a GM choice of its own; Beta Ray Bill\'s humanoid form is a form on his card (330 and 80), as on ME2\'s',
      me3.filter((c) => c.versions[0].blocks.length > 1).map((c) => `${c.id} ${c.versions[0].blocks.map((b) => b.label).join('+')}`).join(' | ')
        === 'beta-ray-bill-me3 Beta Ray Bill+Humanoid form | mephisto-me3 Mephisto+MEPHISTO (w/Galactus) | dormammu-me3 Dormammu+DORMAMMU (w/Galactus)'
      && ['mephisto-me3', 'dormammu-me3'].every((id) => choices.filter((c) => c.character === id).length === 2)
      && ['mephisto-me3', 'dormammu-me3'].map((id) => `${played3(id, 0)} ${played3(id, 1)}`).join() === '3225/250 4200/1175,1275/250 1350/300'
      && choices.filter((c) => c.character === 'beta-ray-bill-me3').length === 1
      && bill3?.forms?.map((f) => `${f.name} ${f.health}`).join() === 'Beta Ray Bill 330,Humanoid form 80',
      me3.filter((c) => c.versions[0].blocks.length > 1).map((c) => `${c.id} ${c.versions[0].blocks.map((b) => b.label).join('+')}`).join(' | ')
        + ` ${['mephisto-me3', 'dormammu-me3'].map((id) => `${played3(id, 0)} ${played3(id, 1)}`)} ${JSON.stringify(bill3?.forms?.map((f) => [f.name, f.health]))}`);
    const fixes3 = ['death-me3', 'eternity-me3', 'dormammu-me3'].map((id) => {
      const o = blk3(id)?.override;
      return `${id} ${o?.verdict} ${o?.field} ${o?.printed} block ${blk3(id)?.health}/${blk3(id)?.karma} plays ${played3(id, id === 'dormammu-me3' ? 0 : undefined)}`;
    });
    check('ME3: three blocks kept as printed: Death\'s Karma Unlim. and Eternity\'s Unlimited, played as unset beside their Health 20,000, and Dormammu\'s Health 1275*, the asterisk keying the note under his grid',
      fixes3.join(' | ') === [
        'death-me3 as_printed karma Unlim. block 20,000/Unlim. plays 20000/null',
        'eternity-me3 as_printed karma Unlimited block 20,000/Unlimited plays 20000/null',
        'dormammu-me3 as_printed health 1275* block 1275*/250 plays 1275/250',
      ].join(' | '),
      fixes3.join(' | '));
    const ov3 = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'me3-overrides.json'), 'utf8')).overrides;
    const text3 = ov3.filter((o) => o.verdict === 'text');
    check('ME3: ten overrides: three as printed, Dormammu\'s second grid\'s label, the Summary\'s Firelord Karma 90 as 110, and five text verdicts (Captain Marvel\'s Nega-Bands twice, Galactus\'s Serial Immortality, the end of Seth\'s background, Beta Ray Bill\'s sensor), the last two line-end hyphen breaks whose printed fragment no longer reads the shape, and only the three as-printed blocks carry one',
      ov3.length === 10 && ov3.filter((o) => o.verdict === 'as_printed').length === 3 && ov3.filter((o) => o.verdict === 'label').length === 1
      && JSON.stringify(ov3.filter((o) => o.verdict === 'summary_misprint').map((o) => [o.match.summary, o.field, o.printed, o.corrected])) === '[["Firelord","karma",90,110]]'
      && text3.map((o) => o.match.row).join() === ['captain-marvel-mar-vell-me3:power:1', 'galactus-me3:power:9', 'seth-me3:background',
        'beta-ray-bill-me3:power:6', 'captain-marvel-mar-vell-me3:power:1'].map((k) => `me3:${k}`).join()
      && text3.slice(3).every((o) => /[a-z]- [A-Za-z]/.test(o.read) && !/[a-z]- [A-Za-z]/.test(o.printed))
      && blocks3.filter(({ b }) => b.override).map(({ id }) => id).sort().join() === 'death-me3,dormammu-me3,eternity-me3',
      JSON.stringify(ov3.map((o) => [o.verdict, o.match])));
    check('ME3: Firelord plays his block\'s Karma 110, not the Summary\'s misprinted 90, and Pluto\'s Endurance 250, inside Shift Y\'s range, plays as printed (rank_ranges)',
      played3('firelord-me3') === '325/110'
      && bookNpc({ character: 'pluto-me3' }).snapshot?.abilities.endurance.rank === 'shift-y' && bookNpc({ character: 'pluto-me3' }).snapshot.abilities.endurance.number === 250,
      `${played3('firelord-me3')} ${JSON.stringify(bookNpc({ character: 'pluto-me3' }).snapshot?.abilities.endurance)}`);
    check('ME3: this book\'s Captain Marvel is named for Mar-Vell (card_names), and the three earlier books\' Captain Marvel cards keep their names',
      me3.some((c) => c.id === 'captain-marvel-mar-vell-me3' && c.name === 'Captain Marvel (Mar-Vell)')
      && data.npcs.characters.filter((c) => c.book !== 'me3' && /^Captain Marvel/.test(c.name)).map((c) => `${c.id} ${c.name}`).join()
        === 'captain-marvel-mhsp1 Captain Marvel,captain-marvel-mh2 Captain Marvel,captain-marvel-mhsp2 Captain Marvel',
      data.npcs.characters.filter((c) => /^Captain Marvel/.test(c.name)).map((c) => c.id).join());
    check('ME3: the three possessive card names in ASCII, not as the headers\' curly apostrophes read (speck_lines), Mephisto\'s first identity line whole (a hyphen-split word joined), and Hela\'s Illusion-Casting spelled as printed',
      ['mephisto-s-demonic-thralls-me3', 'mephisto-s-footsoldiers-me3', 'pluto-s-footsoldiers-me3'].map((id) => me3.find((c) => c.id === id)?.name).join()
        === 'Mephisto\'s Demonic Thralls,Mephisto\'s Footsoldiers,Pluto\'s Footsoldiers'
      && ver3('mephisto-me3')?.identity[0] === 'aka Satan, Mephistopheles, Lucifer, and "The Devil"'
      && ver3('hela-me3')?.powers.some((p) => p.name === 'Illusion-Casting'),
      `${ver3('mephisto-me3')?.identity[0]} | ${ver3('hela-me3')?.powers.map((p) => p.name)}`);
    const heads3 = [['firelord-me3', 'Energy Sheath'], ['mephisto-me3', 'Enlargement'], ['mephisto-me3', 'Power Control'], ['pluto-me3', 'Mystical Flame']];
    check('ME3: the four run-in powers whose line above ends no sentence are powers of their own (power_heads): Firelord\'s Energy Sheath, Mephisto\'s Enlargement and Power Control, Pluto\'s Mystical Flame',
      heads3.every(([id, n]) => ver3(id)?.powers.filter((p) => p.name === n).length === 1),
      heads3.map(([id, n]) => `${id} ${n} ${ver3(id)?.powers.filter((p) => p.name === n).length}`).join(' | '));
    const pw3 = me3.flatMap((c) => c.versions[0].powers);
    check('ME3: 173 powers, 82 of them linked to the UPB', pw3.length === 173 && pw3.filter((p) => p.upb).length === 82,
      `${pw3.length} ${pw3.filter((p) => p.upb).length}`);
    const book3 = data.npcs.books.find((b) => b.slug === 'me3');
    const one3 = me3.filter((c) => !['mephisto-me3', 'dormammu-me3'].includes(c.id));
    check('ME3: the book reads Adventure 3-5 and 11-28 and Resource 2-16, a card cites its booklet and page and a Summary-only hero the Summary, and every other card is one GM choice',
      JSON.stringify(book3?.ranges) === '[{"part":"Adventure","pages":[[3,5],[11,28]]},{"part":"Resource","pages":[[2,16]]}]'
      && tagline(bookNpc({ character: 'gladiator-me3' }).snapshot).startsWith('ME3 The Left Hand of Eternity, Adventure p.3;')
      && tagline(bookNpc({ character: 'purple-man-me3' }).snapshot).startsWith('ME3 The Left Hand of Eternity, Resource p.16;')
      && tagline(bookNpc({ character: 'nova-me3' }).snapshot).startsWith('ME3 The Left Hand of Eternity, Pregenerated Heroes Summary;')
      && one3.length === 30 && one3.every((c) => choices.filter((x) => x.character === c.id).length === 1),
      `${JSON.stringify(book3)} ${tagline(bookNpc({ character: 'purple-man-me3' }).snapshot)} ${tagline(bookNpc({ character: 'nova-me3' }).snapshot)}`);
    check('ME3: cards play their printed Health and Karma (Galactus 4150/3000, Hela 1200/170, Uatu 250/300, Thanos 305/120, the Keeper 260/450)',
      ['galactus-me3', 'hela-me3', 'uatu-me3', 'thanos-me3', 'keeper-me3'].map((id) => played3(id)).join() === '4150/3000,1200/170,250/300,305/120,260/450',
      ['galactus-me3', 'hela-me3', 'uatu-me3', 'thanos-me3', 'keeper-me3'].map((id) => played3(id)).join());
    // The text verdicts move only the book's text, which is msh_book_text's:
    // read the generated .sql in the cache, by keys and by the overrides' own
    // fragments, never a sentence of the book in this file.
    const sql3 = join(process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh'), 'books', 'me3', 'book-text.sql');
    if (!existsSync(sql3)) {
      check(`ME3: skipped the text checks: no ${rel(sql3) || sql3}`, true);
    } else {
      const rows3 = [...readFileSync(sql3, 'utf8').matchAll(/VALUES \('([^']+)', 'me3', '[^']+', '[^']+', (NULL|'(?:[^']|'')*'), (?:NULL|\d+), '((?:[^']|'')*)'\);/g)]
        .map(([, key, name, body]) => ({ key, name: name === 'NULL' ? '' : name.slice(1, -1).replace(/''/g, '\''), body: body.replace(/''/g, '\'') }));
      const ents3 = new Set(rows3.map((r) => r.key.split(':')[1]));
      check('ME3 text: 195 rows over 25 entries (the Nine-Headed Serpent, the Vulture Flock, the Keeper and the Summary\'s four print none), and no row with an odd count of double quotes',
        rows3.length === 195 && ents3.size === 25
        && me3.filter((c) => !ents3.has(c.id)).map((c) => c.id).join() === ['nine-headed-serpent', 'vulture-flock', 'keeper', 'doc-strange', 'nova',
          'silver-surfer', 'thor'].map((id) => `${id}-me3`).join()
        && !rows3.some((r) => (r.body.match(/"/g) || []).length % 2),
        `${rows3.length} ${ents3.size} ${me3.filter((c) => !ents3.has(c.id)).map((c) => c.id)}`);
      const count3 = (row, s) => (rows3.find((r) => r.key === row)?.body.split(s).length || 1) - 1;
      const verdicts3 = text3.map((o) => `${o.match.row} ${count3(o.match.row, o.printed)}/${count3(o.match.row, o.read)}`);
      check('ME3 text: each of the five text verdicts is applied, its printed fragment once in its row and the misread gone',
        text3.length === 5 && verdicts3.every((v) => v.endsWith(' 1/0')), verdicts3.join(' | '));
      // a word the page breaks at a line end after its hyphen, kept by the
      // reader as "<letters>- <letters>" (marvel-11 leftovers row 10d, Nate
      // 2026-11-03): ME3's two are closed up by the text verdicts above
      const shape3 = rows3.filter((r) => /[a-z]- [A-Za-z]/.test(r.body)).map((r) => r.key.slice(4)).sort();
      check('ME3 text: no row reads a letter, a hyphen and a space before a word (none is kept on purpose)',
        shape3.length === 0, shape3.join(' '));
    }
  }

  const { sqlite, env, route, call } = await marvelStandIn();
  const R = { list: await route('campaigns.js'), book: await route('campaigns/[id]/npcs/from-book.js'),
    npcs: await route('campaigns/[id]/npc-sheets.js'), link: await route('campaigns/[id]/heroes.js') };
  const camp = (await call(R.list, 'POST', { body: { name: 'Mutant Menace' } })).body.campaign;
  const p = { id: String(camp.id) };
  sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot, sheet) VALUES ('hero-cy-0001', 'cy@x.org', 'Cy', '{}', '{"health":1}', '{}')`).run();
  await call(R.link, 'POST', { who: 'cy@x.org', params: p, body: { hero_id: 'hero-cy-0001' } });
  const added = await call(R.book, 'POST', { params: p, body: { character: 'nightcrawler', dossier: true } });
  check('the GM adds Nightcrawler: a 201, the book\'s name, and the snapshot the builder makes',
    added.status === 201 && added.body.npc.name === 'Nightcrawler' && added.body.npc.snapshot.health === 106, JSON.stringify(added.body).slice(0, 160));
  check('with a People dossier backed by it, when asked',
    sqlite.prepare('SELECT sheet_id FROM msh_npcs WHERE id = ?').get(added.body.dossier_id)?.sheet_id === added.body.npc.id);
  check('hidden from the players until the GM shows it',
    (await call(R.npcs, 'GET', { who: 'cy@x.org', params: p })).body.npcs.length === 0 && (await call(R.npcs, 'GET', { params: p })).body.npcs.length === 1);
  const renamed = await call(R.book, 'POST', { params: p, body: { character: 'brood', block: 1, name: 'Hunter #2' } });
  check('a tier and a name of the GM\'s own', renamed.status === 201 && renamed.body.npc.name === 'Hunter #2' && renamed.body.npc.snapshot.health === 70);
  check('a player cannot add one', (await call(R.book, 'POST', { who: 'cy@x.org', params: p, body: { character: 'nightcrawler' } })).status === 403);
  const refusals = await Promise.all([
    call(R.book, 'POST', { params: p, body: { character: 'nobody-at-all' } }),
    call(R.book, 'POST', { params: p, body: { character: 'phoenix' } }),
    call(R.book, 'POST', { params: p, body: { character: "x' OR 1=1" } }),
    call(R.book, 'POST', { params: p, body: { character: 'brood', block: 'queen' } }),
  ]);
  check('an unknown character, a missing version, a malformed id and a block that is not a number are each a 400',
    refusals.every((r) => r.status === 400) && /versions/.test(refusals[1].body.error), refusals.map((r) => r.status).join());
  check('and People refuses a second dossier of one name before anything is written',
    (await call(R.book, 'POST', { params: p, body: { character: 'nightcrawler', dossier: true } })).status === 409
    && sqlite.prepare('SELECT count(*) AS n FROM msh_npc_sheets').get().n === 2);
}

section('Notes, People and handouts: the shared views on Marvel\'s own tables, members only');

{
  const { sqlite, env, media, route, call } = await marvelStandIn();
  const R = {
    list: await route('campaigns.js'),
    link: await route('campaigns/[id]/heroes.js'),
    journal: await route('journal.js'),
    entry: await route('journal/[entryId].js'),
    search: await route('campaigns/[id]/search.js'),
    ask: await route('campaigns/[id]/ask.js'),
    people: await route('campaigns/[id]/npcs.js'),
    person: await route('campaigns/[id]/npcs/[npcId].js'),
    portrait: await route('campaigns/[id]/npcs/[npcId]/portrait.js'),
    sweep: await route('campaigns/[id]/npcs/sweep.js'),
    handouts: await route('campaigns/[id]/handouts.js'),
    pages: await route('campaigns/[id]/entries.js'),
    page: await route('campaigns/[id]/entries/[entryId].js'),
    upload: await route('campaigns/[id]/entries/[entryId]/images.js'),
    image: await route('campaigns/[id]/images/[imageId].js'),
  };
  // gm@ runs it; ann@ has a hero in it; eve@ is signed in and has none.
  sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES ('hero-ann-0001', 'ann@x.org', 'Ann', '{}', '{}')`).run();
  const c = (await call(R.list, 'POST', { body: { name: 'Tuesday' } })).body.campaign;
  const p = { id: String(c.id) };
  await call(R.link, 'POST', { who: 'ann@x.org', params: p, body: { hero_id: 'hero-ann-0001' } });

  const outsider = await Promise.all([
    call(R.journal, 'GET', { who: 'eve@x.org', query: `?campaign_id=${c.id}` }),
    call(R.journal, 'POST', { who: 'eve@x.org', body: { campaign_id: c.id, body: 'hi' } }),
    call(R.search, 'GET', { who: 'eve@x.org', params: p, query: '?q=x' }),
    call(R.people, 'GET', { who: 'eve@x.org', params: p }),
    call(R.handouts, 'GET', { who: 'eve@x.org', params: p }),
    call(R.ask, 'POST', { who: 'eve@x.org', params: p, body: { question: 'who?' } }),
  ]);
  check('someone with no hero in the campaign reads and writes none of it (403 on all six)',
    outsider.every((r) => r.status === 403), outsider.map((r) => r.status).join());

  // @mentions: a dossier on first mention, a possessive resolving to the same
  // person, an apostrophe inside a name kept.
  const n1 = await call(R.journal, 'POST', { who: 'ann@x.org', body: { campaign_id: c.id, title: 'Docks', body: 'We cornered @Kingpin at the docks with @O\'Brien.' } });
  const n2 = await call(R.journal, 'POST', { body: { campaign_id: c.id, body: '@Kingpin\'s men took the crate.' } });
  const names = sqlite.prepare('SELECT name FROM msh_npcs ORDER BY name').all().map((r) => r.name);
  check('a player\'s note is saved, and @Name makes a dossier on first mention',
    n1.status === 201 && n2.status === 201 && names.join() === 'Kingpin,O\'Brien', names.join());
  const king = sqlite.prepare("SELECT id FROM msh_npcs WHERE name = 'Kingpin'").get().id;
  check('"@Kingpin\'s" is the Kingpin: both notes list under one dossier',
    (await call(R.person, 'GET', { who: 'ann@x.org', params: { ...p, npcId: String(king) } })).body.mentions.length === 2);
  await call(R.entry, 'PATCH', { who: 'ann@x.org', params: { entryId: String(n1.body.entry.id) }, body: { body: 'We cornered @O\'Brien alone.' } });
  check('an edit that takes a name out stops listing the note under them',
    (await call(R.person, 'GET', { params: { ...p, npcId: String(king) } })).body.mentions.length === 1);
  check('a note is changed only by its author or the GM',
    (await call(R.entry, 'DELETE', { who: 'ann@x.org', params: { entryId: String(n2.body.entry.id) } })).status === 403
      && (await call(R.entry, 'DELETE', { params: { entryId: String(n2.body.entry.id) } })).status === 200);
  const hit = await call(R.search, 'GET', { who: 'ann@x.org', params: p, query: '?q=' + encodeURIComponent('o\'bri') });
  check('search takes an apostrophe as a word break, and marks the match with \\u0001 and \\u0002, never markup',
    hit.status === 200 && hit.body.entries.length === 1 && hit.body.entries[0].snippet.includes('\u0001') && !hit.body.entries[0].snippet.includes('<mark>'),
    JSON.stringify(hit.body).slice(0, 160));

  // A dossier's link to a statted sheet is the GM's to set and to see.
  sqlite.prepare("INSERT INTO msh_npc_sheets (campaign_id, name, build, snapshot, created_by) VALUES (?, 'Kingpin', '{}', '{}', 'gm@x.org')").run(c.id);
  const kp = { ...p, npcId: String(king) };
  check('only the GM links a dossier to a statted NPC sheet',
    (await call(R.person, 'PATCH', { who: 'ann@x.org', params: kp, body: { sheet_id: 1 } })).status === 403
      && (await call(R.person, 'PATCH', { params: kp, body: { sheet_id: 1 } })).status === 200);
  check('and a player never sees which sheet stands behind a dossier',
    !('sheet_id' in (await call(R.person, 'GET', { who: 'ann@x.org', params: kp })).body.npc)
      && !(await call(R.people, 'GET', { who: 'ann@x.org', params: p })).body.npcs.some((n) => 'sheet_id' in n)
      && (await call(R.person, 'GET', { params: kp })).body.npc.sheet_id === 1);

  // Pictures: every key under msh/, a portrait read back through the Function.
  const png = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3]);
  check('a portrait is stored under msh/ and read back through the Function',
    (await call(R.portrait, 'POST', { who: 'ann@x.org', params: kp, type: 'image/png', raw: png })).status === 200
      && [...media.objects.keys()].every((k) => k.startsWith(`msh/npc/${c.id}/${king}/`))
      && (await call(R.portrait, 'GET', { who: 'ann@x.org', params: kp })).body.length === png.length);
  check('a file that is not an image is refused', (await call(R.portrait, 'POST', { params: kp, type: 'text/html', raw: '<b>' })).status === 415);
  let refused = false;
  try { sqlite.prepare("UPDATE msh_npcs SET portrait_key = 'npc/1/x.png' WHERE id = ?").run(king); } catch { refused = true; }
  check('and the table itself refuses a key outside msh/', refused);

  // The GM's pages stay the GM's; a picture from one is a handout once revealed.
  check('a player cannot list the GM\'s pages', (await call(R.pages, 'GET', { who: 'ann@x.org', params: p })).status === 403);
  const pg = (await call(R.pages, 'POST', { params: p, body: { title: 'The docks', kind: 'place', body: 'GM only' } })).body.entry;
  const img = (await call(R.upload, 'POST', { params: { ...p, entryId: String(pg.id) }, query: '?caption=Map', type: 'image/png', raw: png })).body.image;
  const ip = { ...p, imageId: String(img.id) };
  check('an unrevealed picture is not a handout, and a player asking for it gets a 404',
    (await call(R.handouts, 'GET', { who: 'ann@x.org', params: p })).body.handouts.length === 0
      && (await call(R.image, 'GET', { who: 'ann@x.org', params: ip })).status === 404
      && (await call(R.image, 'GET', { params: ip })).status === 200);
  check('only the GM reveals one', (await call(R.image, 'PATCH', { who: 'ann@x.org', params: ip, body: { revealed: true } })).status === 403
    && (await call(R.image, 'PATCH', { params: ip, body: { revealed: true } })).status === 200);
  const shown = (await call(R.handouts, 'GET', { who: 'ann@x.org', params: p })).body.handouts;
  check('once revealed it is a handout: its id and caption, and nothing of the page behind it',
    shown.length === 1 && shown[0].caption === 'Map' && !('entry_id' in shown[0]) && !('title' in shown[0])
      && (await call(R.image, 'GET', { who: 'ann@x.org', params: ip })).status === 200, JSON.stringify(shown));
  check('deleting the page deletes its pictures from R2', (await call(R.page, 'DELETE', { params: { ...p, entryId: String(pg.id) } })).status === 200
    && ![...media.objects.keys()].some((k) => k.startsWith('msh/campaign/')));

  // Nate, 2026-09-28: Ask yes, the sweep no.
  check('the sweep answers 501 and says so', (await call(R.sweep, 'POST', { params: p })).status === 501);
  check('Ask checks the question before anything that costs money',
    (await call(R.ask, 'POST', { who: 'ann@x.org', params: p, body: {} })).status === 400
      && (await call(R.ask, 'POST', { who: 'ann@x.org', params: p, body: { question: 'x'.repeat(1001) } })).status === 400);

  // 100 Claude calls per person in any 24 hours, counted by the shared client
  // in the Palladium DB's claude_usage, where every caller's rows are. Ann has
  // made 100: her Ask is a 429 that says when, with Retry-After, before any
  // request leaves for the model, and the refusal writes no row.
  const { DatabaseSync } = await import('node:sqlite');
  const usage = new DatabaseSync(':memory:');
  usage.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8')
    .match(/CREATE TABLE IF NOT EXISTS claude_usage \([\s\S]*?\n\);/)[0]);
  const ins = usage.prepare(`INSERT INTO claude_usage (email, endpoint, status, created_at)
    VALUES ('ann@x.org', 'msh-campaign-ask', 200, datetime('now', ?))`);
  for (let i = 1; i <= 100; i++) ins.run(`-${i} minutes`);
  env.DB = { prepare: (sql) => {
    const st = usage.prepare(sql);
    return { bind: (...args) => ({ first: async () => st.get(...args) ?? null, run: async () => st.run(...args) }) };
  } };
  env.ANTHROPIC_API_KEY = 'not-a-key';
  const realFetch = globalThis.fetch;
  let upstreamCalls = 0;
  // An upstream failure, so a call the limit let through reads as the 502 it
  // would be, rather than as a crash.
  globalThis.fetch = async () => {
    upstreamCalls++;
    return new Response(JSON.stringify({ error: { message: 'the limit let a call through' } }), { status: 529 });
  };
  let limited;
  try {
    const request = new Request('https://example.com/api/marvel-heroes/x', { method: 'POST',
      headers: { 'Cf-Access-Authenticated-User-Email': 'ann@x.org', 'Content-Type': 'application/json' },
      // Words Ann's surviving note holds, so without the limit this WOULD call.
      body: JSON.stringify({ question: 'Who was cornered alone?' }) });
    const res = await R.ask.onRequestPost({ request, env, params: p });
    limited = { status: res.status, retry: Number(res.headers.get('Retry-After')), body: await res.json() };
  } finally {
    globalThis.fetch = realFetch;
    delete env.DB;
    delete env.ANTHROPIC_API_KEY;
  }
  check('a player with 100 Claude calls in the last day is refused Ask with a 429, not a 502',
    limited.status === 429, JSON.stringify(limited));
  check('saying when the next call frees up, with Retry-After in seconds',
    /frees up at \d{4}-\d\d-\d\d \d\d:\d\d UTC/.test(limited.body.error || '') && limited.retry > 0 && limited.retry <= 86400,
    JSON.stringify(limited));
  check('and nothing reaches the model, and the refusal writes no usage row',
    upstreamCalls === 0 && usage.prepare('SELECT count(*) AS n FROM claude_usage').get().n === 100);

  // Under the limit, the request that leaves is the shared default model, and
  // never disabled thinking: Sonnet 5.5 answers that with a 400 (measured
  // 2026-10-27, PR #1982), so a caller still sending it fails on every press.
  const { DEFAULT_MODEL } = await import('../../../functions/api/_lib/claude-client.js');
  usage.exec('DELETE FROM claude_usage');
  env.DB = { prepare: (sql) => {
    const st = usage.prepare(sql);
    return { bind: (...args) => ({ first: async () => st.get(...args) ?? null, run: async () => st.run(...args) }) };
  } };
  env.ANTHROPIC_API_KEY = 'not-a-key';
  let sent = null;
  globalThis.fetch = async (url, init) => {
    sent = JSON.parse(init.body);
    return new Response(JSON.stringify({ content: [{ type: 'text', text: 'O\'Brien.' }], usage: { input_tokens: 1, output_tokens: 1 } }), { status: 200 });
  };
  let answered;
  try {
    const request = new Request('https://example.com/api/marvel-heroes/x', { method: 'POST',
      headers: { 'Cf-Access-Authenticated-User-Email': 'ann@x.org', 'Content-Type': 'application/json' },
      body: JSON.stringify({ question: 'Who was cornered alone?' }) });
    const res = await R.ask.onRequestPost({ request, env, params: p });
    answered = { status: res.status, body: await res.json() };
  } finally {
    globalThis.fetch = realFetch;
    delete env.DB;
    delete env.ANTHROPIC_API_KEY;
  }
  check('Ask sends the shared DEFAULT_MODEL', answered.status === 200 && sent?.model === DEFAULT_MODEL,
    `${answered.status} ${sent?.model}`);
  check('and no thinking: { type: \'disabled\' }', sent !== null && sent.thinking?.type !== 'disabled',
    JSON.stringify(sent?.thinking));
  const row = usage.prepare('SELECT model FROM claude_usage').get();
  check('and its usage row records that model', row?.model === DEFAULT_MODEL, String(row?.model));
}

section('The shared campaign views are loaded in order, reach only this app\'s API, and are styled here');

{
  const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
  const MODULES = { 'campaign/index.html': ['notes', 'people', 'handouts'], 'gm/index.html': ['setting', 'table'], 'gm/present.html': ['present'] };
  for (const [page, mods] of Object.entries(MODULES)) {
    const html = readFileSync(join(appDir, page), 'utf8');
    const srcs = [...html.matchAll(/<script\b[^>]*src="([^"]+)"/g)].map((m) => m[1]);
    const at = (name) => srcs.indexOf(`/shared/js/campaign/${name}.js`);
    check(`${page} loads core.js, then ${mods.join(', ')}, before its own module`,
      at('core') >= 0 && mods.every((m) => at(m) > at('core')) && srcs.findIndex((s) => !s.startsWith('/shared/')) > Math.max(...mods.map(at)),
      srcs.join(' '));
    // The one other shared script allowed is the site-wide error reporter.
    check(`${page} loads no other app's script`, srcs.every((s) => s.startsWith('/shared/js/campaign/')
      || s === '/shared/js/client-errors.js' || !s.startsWith('/')), srcs.join(' '));
  }
  const pageScripts = ['campaign/campaign.js', 'gm/gm.js', 'gm/present.js'].map((f) => readFileSync(join(appDir, f), 'utf8'));
  // GM tools is where a Marvel GM runs a session, so The Table's panel is drawn
  // there as well as on the Campaigns page, not merely loaded.
  check('GM tools loads and draws The Table\'s panel',
    /MC\.table\.load\(\)/.test(pageScripts[1]) && /MC\.table\.html\(\)/.test(pageScripts[1]));
  // A double click on Roll the NPC sent two generate requests and saved two
  // NPCs: the handler returns while a roll is in flight, disables the button
  // before the request, and re-enables it in a finally, so an error frees it.
  {
    const h = (pageScripts[1].split("$('#npc-form').addEventListener('submit'")[1] || '').split("$('#npc-list')")[0];
    const call = h.indexOf('npcs/generate');
    const guard = h.search(/if \((\w+)\) return;/);
    const flag = (h.match(/if \((\w+)\) return;/) || [])[1];
    const fin = h.slice(h.indexOf('finally'));
    check('GM tools: Roll the NPC sends one request at a time and is re-enabled when it settles',
      call > 0 && guard >= 0 && guard < call
        && new RegExp(`${flag} = true;[\\s\\S]*\\.disabled = true;`).test(h.slice(0, call))
        && h.indexOf('finally') > call && new RegExp(`${flag} = false;`).test(fin) && /\.disabled = false;/.test(fin),
      h.slice(0, 200));
  }
  // The page code names only this app's API (the suite itself is left out: it
  // names the other one in these very lines), and no endpoint imports another
  // group's code - a comment naming the Palladium file it mirrors is fine.
  check('every page hands the shared views /api/marvel-heroes, no page names another group\'s API, and no endpoint imports its code',
    pageScripts.every((s) => s.includes("base: '/api/marvel-heroes'"))
      && !textFiles.filter((f) => f.startsWith(appDir) && !f.startsWith(join(appDir, 'test')))
        .some((f) => readFileSync(f, 'utf8').includes('/api/character-creator'))
      && !scripts.filter((f) => f.startsWith(fnDir))
        .some((f) => /\bfrom\s+'[^']*character-creator/.test(readFileSync(f, 'utf8'))));

  // Every mc- class the four views Marvel draws can emit has a rule here, so a
  // class added there without one here fails instead of rendering unstyled.
  const emitted = new Set();
  for (const m of ['notes', 'people', 'handouts', 'setting']) {
    const src = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', `${m}.js`), 'utf8');
    for (const cls of src.matchAll(/class="([^"$]*)/g)) for (const c of cls[1].split(/\s+/)) if (/^mc-[a-z-]+$/.test(c)) emitted.add(c);
    for (const lit of src.matchAll(/'(mc-[a-z-]+(?: mc-[a-z-]+)*)'/g)) for (const c of lit[1].split(' ')) emitted.add(c);
  }
  const unstyled = [...emitted].filter((c) => !new RegExp(`\\.${c}(?![a-z-])`).test(css));
  check(`every one of the ${emitted.size} mc- classes those views emit is styled in styles.css`, emitted.size > 30 && unstyled.length === 0, unstyled.join(', '));
  check('the People sweep panel is hidden, by the button it carries', /\.mc-panel:has\(button\[onclick\^="mcCampaign\.people\.sweep"\]\)\s*\{\s*display:\s*none/.test(css));

  // Present mode writes no markup: the page must carry every id it fills.
  const present = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'present.js'), 'utf8');
  const ids = [...new Set([...present.matchAll(/\$\('([a-z]+)'\)/g)].map((m) => m[1]))];
  const skeleton = readFileSync(join(appDir, 'gm', 'present.html'), 'utf8');
  const lacking = ids.filter((id) => !skeleton.includes(`id="${id}"`));
  check(`gm/present.html carries all ${ids.length} ids present.js fills`, ids.length >= 10 && lacking.length === 0, lacking.join(', '));
  check('and a hidden frame or state stays hidden against its own display rule',
    /\.present-frame\[hidden\],\s*\.present-state\[hidden\]\s*\{\s*display:\s*none/.test(css));

  // escJs: the O'Brien bug - a name through the attribute decode and the JS parse, whole.
  const { escJs } = await import(new URL('../js/campaign-ui.js', import.meta.url));
  const name = 'O\'Brien "the" <b> \\ x';
  const decoded = escJs(name).replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
  let back = null;
  try { back = new Function(`return '${decoded}';`)(); } catch { /* reported below */ }
  check('escJs carries a name with an apostrophe, a quote, a tag and a backslash through an inline handler unchanged', back === name, String(back));
}

section('Initiative (R25): d100, then a Talent that applies, then Agility, then the tied re-roll');

{
  const { orderRolled, rollInitiative, initiativeTalents, TAGS } = await import(new URL('../js/initiative.js', import.meta.url));
  const { rng } = await import(new URL('../js/dice.js', import.meta.url));
  check('the Talents it reads are exactly the two that give +1 initiative (talents.json:155, :210)',
    JSON.stringify(initiativeTalents(load('talents.json')).sort()) === '["martial-arts-e","weapons-specialist"]');
  const who = (o) => o.map((r) => r.key).join('');
  const c = (key, roll, agility, talent = false, applies = false) => ({ key, name: key, roll, agility, talent, applies });

  const t = orderRolled([c('A', 50, 40), c('B', 50, 10, true, true), c('C', 90, 1)], rng(1));
  check('a tie broken by a Talent that applies: the lower Agility goes first, tagged Talent',
    who(t) === 'CBA' && t[1].tags.includes(TAGS.talent) && t[2].tags.includes(TAGS.talent) && t[0].tags.length === 0, JSON.stringify(t.map((r) => [r.key, r.tags])));
  const a = orderRolled([c('A', 50, 20), c('B', 50, 22)], rng(1));
  check('a tie broken by the Agility NUMBER: 22 beats 20, both Excellent, tagged Agility',
    who(a) === 'BA' && a.every((r) => r.tags.join() === TAGS.agility && r.rerolls.length === 0));
  const r = orderRolled([c('A', 50, 20), c('B', 50, 20), c('C', 10, 20)], rng(7));
  const byKey = Object.fromEntries(r.map((x) => [x.key, x]));
  check('a tie still standing is broken by a re-roll of the tied combatants only',
    byKey.A.rerolls.length > 0 && byKey.B.rerolls.length > 0 && byKey.C.rerolls.length === 0
      && byKey.A.tags.includes(TAGS.reroll) && r[2].key === 'C'
      && byKey[r[0].key].rerolls.at(-1) > byKey[r[1].key].rerolls.at(-1), JSON.stringify(r));
  const u = orderRolled([c('A', 50, 30), c('B', 50, 10, true, false)], rng(1));
  check('an unticked Talent box breaks nothing: Agility decides, and no row is tagged Talent',
    who(u) === 'AB' && !u.some((x) => x.tags.includes(TAGS.talent)));
  const tickedNoTalent = orderRolled([c('A', 50, 30), c('B', 50, 10, false, true)], rng(1));
  check('nor does a tick on someone with no initiative Talent', who(tickedNoTalent) === 'AB' && !tickedNoTalent.some((x) => x.tags.includes(TAGS.talent)));
  const both = orderRolled([c('A', 50, 10, true, true), c('B', 50, 30, true, true)], rng(1));
  check('two whose Talents both apply go on to Agility', who(both) === 'BA' && both.every((x) => x.tags.join() === TAGS.agility));
  const round = rollInitiative([c('A', 0, 5), c('B', 0, 6), c('C', 0, 7), c('D', 0, 8)], rng(12345));
  check('a rolled round is highest first, every roll a d100',
    round.every((x, i) => x.roll >= 1 && x.roll <= 100 && (i === 0 || round[i - 1].roll >= x.roll)), JSON.stringify(round.map((x) => x.roll)));
}

section('No book text is in any tracked file (local only: needs the extraction)');

{
  // The one check that compares against the real text. The extraction lives in
  // the gitignored .cache/msh/ on the machine that has the PDF, so CI has
  // nothing to compare with and this section says so rather than passing
  // silently. WORKSHOP_MSH_CACHE points a worktree at the main checkout's.
  const cacheDir = process.env.WORKSHOP_MSH_CACHE || join(repoRoot, '.cache', 'msh');
  const full = join(cacheDir, 'powers-full.json');
  if (!existsSync(full)) {
    check(`skipped: no extraction at ${rel(full) || full}`, true);
  } else {
    const N = 10;
    const words = (s) => s.toLowerCase().match(/[a-z0-9]+/g) || [];
    const shingles = new Set();
    // A run counts only if it reads as prose: six or more real words in it. The
    // tables' own runs - "10 11 15 16 ...", "fe pr ty gd ex ..." - are mechanics,
    // which the app is meant to carry, and would otherwise match. MHSP1's
    // Reference Summary abbreviates ranks to four letters ("mons amaz typi"),
    // which look like words to the test and are not.
    const RANK_ABBR = new Set(['feeb', 'typi', 'exce', 'rema', 'incr', 'amaz', 'mons', 'unea']);
    // Nor are the game's own stat names: a table headed with all eleven in
    // order (MH3's Skrull soldiers) is the FASERIP grid, which roster.py and
    // booklet.py name in the same order.
    const STAT_WORDS = new Set(['fighting', 'agility', 'strength', 'endurance', 'reason', 'intuition', 'psyche',
      'health', 'karma', 'resources', 'popularity']);
    // Nor are the books' own names: a run of section, team and character names
    // in the Contents' order ("X-Factor, New Mutants, Hellfire Club ...", the
    // teams list npcs.json carries) is a list, not prose.
    const registry = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'books.json'), 'utf8')).books;
    const NAMES = new Set(Object.values(registry).flatMap((b) => [
      ...(b.sections || []).flatMap(([s, sub]) => [s, sub || '']), ...(b.index || []).map(([n]) => n),
      ...['heroes', 'villains'].flatMap((k) => ((b.reference_summary || {})[k] || []).map(([n]) => n)),
    ]).flatMap(words));
    const prose = (run) => run.filter((x) => /^[a-z]{3,}$/.test(x) && !RANK_ABBR.has(x) && !STAT_WORDS.has(x) && !NAMES.has(x)).length >= 6;
    const addText = (text) => {
      const w = words(text);
      for (let i = 0; i + N <= w.length; i++) if (prose(w.slice(i, i + N))) shingles.add(w.slice(i, i + N).join(' '));
    };
    for (const e of Object.values(JSON.parse(readFileSync(full, 'utf8')))) addText(e.body);
    // The Players' Book too, page by page, when its text layer has been dumped
    // there: the Gear tab's column keys were written from its pages.
    const pb = join(cacheDir, 'players-pages.json');
    check(`the Players' Book text is there to compare against too (${rel(pb) || pb})`, existsSync(pb));
    if (existsSync(pb)) for (const page of Object.values(JSON.parse(readFileSync(pb, 'utf8')))) addText(page);
    // And every sourcebook the Notable NPCs come from: the prose that
    // scripts/msh/roster.py parsed, which is msh_book_text's and never a file's
    // here. data/npcs.json is the file most at risk, so it is named below.
    const booksDir = join(cacheDir, 'books');
    const rosters = existsSync(booksDir) ? readdirSync(booksDir).map((b) => join(booksDir, b, 'roster.json')).filter(existsSync) : [];
    check(`the sourcebooks' parsed text is there to compare against too (${rosters.length} book${rosters.length === 1 ? '' : 's'})`,
      rosters.length > 0);
    for (const f of rosters) {
      // A registry line_identity entry (MX2's, MSL4's) is a card whose Real
      // Name: lines gridbooks.py hands over as the entry's prose, and npcs.py
      // stops unless that prose is those words and nothing more: so a prose
      // equal to one of them is the identity lines too, carried by books.json
      // and npcs.json like any other (MSL4's Mark III's two people, printed 29,
      // are ten words). Any other prose of the entry still counts.
      const book = registry[relative(booksDir, dirname(f))] || {};
      const lineIdentity = new Set((book.line_identity || []).map((x) => words(x.lines.join(' ')).join(' ')));
      for (const e of JSON.parse(readFileSync(f, 'utf8')).entries) {
        // Not the identity lines: a name and a status line are what npcs.json is
        // meant to carry, and the Notable NPCs section holds them to two lines.
        const body = lineIdentity.has(words(e.prose || '').join(' ')) ? '' : e.prose;
        [...Object.values(e.sections), body,...e.powers.map((p) => p.text), ...e.members.map((m) => m.text)]
          .forEach((t) => addText(t || ''));
      }
    }
    // And the rest of each book: its items, locations and adventure
    // (scripts/msh/extras.py), whose text is msh_book_text's too.
    const extras = existsSync(booksDir) ? readdirSync(booksDir).map((b) => join(booksDir, b, 'extras.json')).filter(existsSync) : [];
    for (const f of extras) {
      const x = JSON.parse(readFileSync(f, 'utf8'));
      for (const piece of [...x.items, ...x.adventure.sections].flatMap((i) => i.text)) addText(piece[2].join(' '));
    }
    const withExtras = rosters.filter((f) => Object.entries(registry)
      .some(([slug, b]) => f.startsWith(join(booksDir, slug)) && (b.item_pages || b.adventure)));
    check(`and each parsed book's items and adventure too (${extras.length})`, extras.length === withExtras.length);
    // And every page no parser covers, as Tesseract read it
    // (scripts/msh/ocr-book.py): a contents page, an introduction, a booklet no
    // parser reads yet, a whole book still being surveyed. The parsed text
    // above covers only what a parser has taken apart, so these were compared
    // with nothing (the MHSP1 survey was checked by hand for that reason). A
    // page a parser does cover is left to the parsed text, which leaves out
    // the identity lines npcs.json is meant to carry.
    const covered = (b) => {
      const pdf = (part, printed) => printed + (part ? b.parts.find((p) => p.name === part).offset : b.offset);
      const out = new Set();
      const add = (part, [first, last]) => { for (let p = first; p <= last; p++) out.add(pdf(part, p)); };
      if (b.character_pages) add(b.character_part, b.character_pages);
      // a grid-booklets book (ME1): its character ranges. Not its opponents'
      // chapter pages: they are mostly the adventure's prose, which stays
      // compared whole, and an opponent has no identity line to excuse.
      for (const r of b.character_ranges || []) add(r.part, r.pages);
      if (b.item_pages) add(b.item_part, b.item_pages);
      if (b.adventure) add(b.adventure.part, b.adventure.pages);
      if (b.running) add(b.running.part, b.running.pages);
      return out;
    };
    const unparsed = [];
    for (const [slug, b] of Object.entries(registry)) {
      const dir = join(booksDir, slug, 'txt');
      if (!existsSync(dir)) continue;
      const cards = covered(b);
      const skip = existsSync(join(booksDir, slug, 'roster.json')) ? cards : new Set();
      for (const f of readdirSync(dir)) {
        if (skip.has(Number(f.slice(1, 4)))) continue;
        unparsed.push(`${slug} ${f.slice(0, 4)}`);
        let text = readFileSync(join(dir, f), 'utf8');
        // A card page no parser has read yet (a book being surveyed) is
        // compared whole but for its Real Name: lines, which the parsed text
        // leaves out too: npcs.json carries them. A book that reprints a card
        // another book has already built prints the line npcs.json holds
        // (MLA3's Thor, printed 60: MLA2's ten-word identity line).
        if (cards.has(Number(f.slice(1, 4)))) text = text.replace(/^[^\S\n]*Real Name:.*$/gim, '');
        addText(text.replace(/-\r?\n/g, ''));
      }
    }
    check(`and every page no parser covers, from its OCR (${unparsed.length} pages)`, unparsed.length > 0);
    const tracked = spawnSync('git', ['ls-files', '-z', '--', 'apps/marvel-heroes', 'functions/api/marvel-heroes',
      'scripts/msh-extract.py', 'scripts/msh', 'db/migrations/marvel'], { cwd: repoRoot, encoding: 'utf8' })
      .stdout.split('\0').filter(Boolean);
    // Files not yet committed count too: the check has to fire before the commit.
    const untracked = spawnSync('git', ['ls-files', '-z', '--others', '--exclude-standard', '--', 'apps/marvel-heroes',
      'functions/api/marvel-heroes', 'scripts'], { cwd: repoRoot, encoding: 'utf8' }).stdout.split('\0').filter(Boolean);
    const leaks = [];
    for (const f of new Set([...tracked, ...untracked])) {
      if (!TEXT.has(extname(f)) && extname(f) !== '.py' && extname(f) !== '.sql') continue;
      const w = words(readFileSync(join(repoRoot, f), 'utf8'));
      for (let i = 0; i + N <= w.length; i++) {
        if (shingles.has(w.slice(i, i + N).join(' '))) { leaks.push(`${f}: "${w.slice(i, i + N).join(' ')}"`); break; }
      }
    }
    check(`no file shares ${N} words in a row with the books' text (${shingles.size} runs checked)`,
      leaks.length === 0, leaks.join('; '));
  }
}

section('Gear: the Players\' Book tables are whole, and every rank cell is a rank');

{
  const eq = load('equipment.json');
  const ranks = load('ranks.json');
  const universal = load('universal.json');
  const { makeGear } = await import(new URL('../js/gear.js', import.meta.url));
  const gear = makeGear(eq, ranks);
  // Row counts as printed, read off the two blind transcriptions (which agreed).
  const PRINTED = { shooting: 37, melee: 11, ammunition: 35, missiles: 3, other: 34, vehicles: 81 };
  for (const t of gear.tables) {
    check(`${t.name}: ${PRINTED[t.id]} rows, as printed`, t.rows.length === PRINTED[t.id], String(t.rows.length));
    check(`${t.name}: every row has a name`, t.rows.every((r) => typeof r[t.columns[0]] === 'string' && r[t.columns[0]].trim()));
  }
  check('the vehicle damage list has its 11 lines', eq.vehicle_damage.rows.length === 11);
  // Which columns hold ranks: a cell there is a ladder abbreviation, a
  // number, "*", or one of the few printed forms named here.
  const RANK_COLS = { shooting: ['range', 'material'], melee: ['price', 'strength'], ammunition: ['cost'],
    missiles: ['body', 'control', 'speed'], other: ['cost'], vehicles: ['cost', 'control', 'speed', 'body', 'protection'] };
  const ASIS = new Set(['*', 'Ty/Gd']);
  const bad = [];
  for (const t of gear.tables) {
    for (const r of t.rows) {
      for (const c of RANK_COLS[t.id]) {
        const v = r[c];
        if (v === undefined || typeof v === 'number' || ASIS.has(v)) continue;
        if (!gear.rankOf(v)) bad.push(`${t.id}/${r.name}/${c}=${v}`);
      }
    }
  }
  check('every rank cell reads back onto the ladder (R21 took the one that did not)', bad.length === 0, bad.join(', '));
  check('and something that is not a rank reads as none', gear.rankOf('Re') === null && gear.rankOf('Road') === null && gear.rankOf(6) === null);
  check('vehicle types are the book\'s eight, less R20\'s misprint',
    [...new Set(eq.vehicles[0].rows.map((r) => r.type.replace('*', '')))].sort().join()
      === ['Air', 'GEV', 'Off-Road', 'Railed', 'Road', 'Space', 'Sub', 'Water'].sort().join());
  const find = (q, g) => gear.search({ query: q, group: g }).flatMap((t) => t.rows.map((r) => r.name));
  check('search finds by name, by note and by any cell, every word required',
    find('sniper').join() === 'Sniper Rifle,AP Shot' && find('power pack pistol').includes('Laser Pistol')
      && find('Space').includes('Lunar Shuttle') && !find('power pack pistol').includes('Laser Rifle'));
  check('and the group narrows it', find('', 'vehicles').length === 81 && !find('', 'weapons').includes('Jeep'));
  check('every column key is short and written for the app (15 words at most)',
    [...eq.keys.weapons, ...eq.keys.vehicles].every((k) => k.meaning.split(/\s+/).length <= 15));

  // The FEAT roller's follow-up: a Slam, Stun or Kill result hands the target
  // an Endurance FEAT on that result's own Effects column, and nothing else does.
  const { makeFeat } = await import(new URL('../js/feat.js', import.meta.url));
  const feat = makeFeat(ranks, universal);
  const results = new Set(universal.actions.flatMap((a) => Object.values(a.results)));
  for (const res of ['Slam', 'Stun', 'Kill']) {
    const f = feat.followUp(res);
    check(`a ${res} result leads to the ${res}? column, rolled on Endurance`,
      f?.name === `${res}?` && f.ability === 'endurance' && feat.ORDER.every((c) => typeof f.results[c] === 'string'));
  }
  check('no other result leads anywhere', [...results].filter((x) => !['Slam', 'Stun', 'Kill'].includes(x)).every((x) => feat.followUp(x) === null)
    && feat.followUp(null) === null);
}

section('The dice are seedable and fair enough');

{
  const dice = await import(new URL('../js/dice.js', import.meta.url));
  const a = dice.rng(12345), b = dice.rng(12345);
  const seqA = Array.from({ length: 20 }, () => dice.d100(a));
  const seqB = Array.from({ length: 20 }, () => dice.d100(b));
  check('the same seed rolls the same dice', seqA.join() === seqB.join(), seqA.join());
  // Pinned, so a generator that quietly mixes in the clock or Math.random fails
  // here rather than only across two runs. A hero rebuilt from its seed depends
  // on this sequence; changing the generator is a deliberate re-pin.
  check('and seed 12345 opens 98, 31, 49, 82, 51, 35, 8, 77', seqA.slice(0, 8).join() === '98,31,49,82,51,35,8,77',
    seqA.slice(0, 8).join());
  check('a different seed rolls different dice',
    seqA.join() !== Array.from({ length: 20 }, ((n) => () => dice.d100(n))(dice.rng(54321))).join());
  const next = dice.rng(7);
  const seen = new Array(101).fill(0);
  for (let i = 0; i < 20000; i++) seen[dice.d100(next)]++;
  check('d100 gives every value 1-100 and nothing else',
    seen[0] === 0 && seen.slice(1).every((n) => n > 0), `min ${Math.min(...seen.slice(1))}`);
  check('and no value is wildly over- or under-rolled (20,000 rolls, 200 expected each)',
    seen.slice(1).every((n) => n > 120 && n < 290), `${Math.min(...seen.slice(1))}-${Math.max(...seen.slice(1))}`);
  check('pick finds the band that holds a roll',
    dice.pick([{ roll: [1, 50], v: 'a' }, { roll: [51, 100], v: 'b' }], 51).v === 'b'
      && dice.pick([{ lo: 1, hi: 5, v: 'x' }], 5).v === 'x' && dice.pick([{ roll: [1, 5] }], 6) === null);
}

section('A FEAT reads the Universal Table the way the book prints it');

{
  const { makeFeat } = await import(new URL('../js/feat.js', import.meta.url));
  const feat = makeFeat(load('ranks.json'), load('universal.json'));
  // A call that throws reports as its check's failure rather than ending the run.
  const safe = (fn) => { try { return fn(); } catch (e) { return 'threw: ' + e.message; } };
  const rn = [[0, 'shift-0'], [1, 'feeble'], [2, 'feeble'], [7, 'typical'], [15, 'good'], [35, 'remarkable'],
    [36, 'incredible'], [87, 'monstrous'], [88, 'unearthly'], [351, 'shift-z'], [999, 'shift-z'],
    [1000, 'class-1000'], [3000, 'class-3000'], [99999, 'class-5000']];
  const wrong = rn.filter(([n, id]) => safe(() => feat.rankForNumber(n)) !== id);
  check('rank numbers find their rank, R2 included (35 Remarkable, 36 Incredible)', wrong.length === 0,
    wrong.map(([n, id]) => `${n}: ${feat.rankForNumber(n)} not ${id}`).join('; '));
  check('a negative or missing number finds no rank', feat.rankForNumber(-1) === null && feat.rankForNumber(NaN) === null);
  check('a column shift moves along the ladder', safe(() => feat.shift('typical', 2)) === 'excellent' && safe(() => feat.shift('good', -1)) === 'typical');
  check('and stops at both ends', safe(() => feat.shift('feeble', -5)) === 'shift-0' && safe(() => feat.shift('class-5000', 4)) === 'beyond');
  // PB back cover, Typical: white 01-50, green 51-80, yellow 81-97, red 98-00.
  const ty = [[1, 'white'], [50, 'white'], [51, 'green'], [80, 'green'], [81, 'yellow'], [97, 'yellow'], [98, 'red'], [100, 'red']];
  const tyWrong = ty.filter(([r, c]) => safe(() => feat.colour('typical', r)) !== c);
  check('Typical is white to 50, green to 80, yellow to 97, red above', tyWrong.length === 0,
    tyWrong.map(([r, c]) => `${r}: ${safe(() => feat.colour('typical', r))} not ${c}`).join('; '));
  // Shift 0 and Class 1000 bracket the table: 94 is green on Shift 0, 02 green on Class 1000.
  check('the table\'s two extremes read right', feat.colour('shift-0', 94) === 'green' && feat.colour('shift-0', 95) === 'yellow'
    && feat.colour('class-1000', 1) === 'white' && feat.colour('class-1000', 2) === 'green');
  const r = safe(() => feat.roll({ rank: 'typical', cs: 1, d100: 98, need: 'yellow', action: 'blunt-attacks' }));
  check('a whole FEAT: Typical +1CS is Good, 98 there is red, red beats yellow, and a red blunt attack Stuns',
    r.column === 'good' && r.colour === 'red' && r.success === true && r.result === 'Stun', JSON.stringify(r));
  const miss = safe(() => feat.roll({ rank: 'typical', d100: 60, need: 'yellow' }));
  check('and green does not meet a yellow FEAT', miss.colour === 'green' && miss.success === false && miss.result === null);
}

section('Every element the page script looks up is on the page');

for (const dir of ['', 'codex']) {
  const html = readFileSync(join(appDir, dir, 'index.html'), 'utf8');
  const js = readFileSync(join(appDir, dir, 'app.js'), 'utf8');
  const at = dir ? `${dir}/` : '';
  const ids = [...new Set([...js.matchAll(/\$\('#([a-z0-9-]+)'\)/g)].map((m) => m[1]))];
  const missing = ids.filter((id) => !new RegExp(`id="${id}"`).test(html));
  check(`${at}app.js looks up ${ids.length} ids and ${at}index.html has them all`, ids.length > 0 && missing.length === 0, missing.join(', '));
  // The codex draws its tabs from SECTIONS, so its page carries none to read.
  if (dir) continue;
  const tabs = [...html.matchAll(/role="tab"[^>]*aria-controls="([^"]+)"/g)].map((m) => m[1]);
  check('every tab controls a panel that exists', tabs.length > 0 && tabs.every((p) => html.includes(`id="${p}"`)), tabs.join());
  // The Campaigns page, the GM page and the room view, each against its own
  // page. room.js looks ids up without the '#', by getElementById.
  for (const [page, script, re] of [
    ['campaign/index.html', 'campaign/campaign.js', /\$\('#([a-z0-9-]+)'\)/g],
    ['gm/index.html', 'gm/gm.js', /\$\('#([a-z0-9-]+)'\)/g],
    ['gm/room.html', 'gm/room.js', /\$\('([a-z0-9-]+)'\)/g],
  ]) {
    const pHtml = readFileSync(join(appDir, page), 'utf8');
    const pIds = [...new Set([...readFileSync(join(appDir, script), 'utf8').matchAll(re)].map((m) => m[1]))];
    const pMissing = pIds.filter((id) => !new RegExp(`id="${id}"`).test(pHtml));
    check(`${script} looks up ${pIds.length} ids and ${page} has them all`, pIds.length > 0 && pMissing.length === 0, pMissing.join(', '));
  }
  check('the main page links the Campaigns and GM pages', /href="campaign\/"/.test(html) && /href="gm\/"/.test(html));
  check('the tab bar links to the codex', /<a\b[^>]*href="codex\/"/.test(html));
}

section('The power browser finds Powers by code, name, word and class');

{
  const { makeBrowser } = await import(new URL('../js/browser.js', import.meta.url));
  const b = makeBrowser(load('powers.json'), load('power-tables.json'));
  const codes = (r) => r.map((p) => p.code);
  check('an empty search lists all 263', b.search().length === 263, String(b.search().length));
  check('a code finds exactly that Power, in any case', codes(b.search({ query: 'MG10' })).join() === 'MG10'
    && codes(b.search({ query: 'mco3' })).join() === 'MCo3');
  const flight = codes(b.search({ query: 'flight' }));
  check('a word finds Powers whose name has it before those whose summary has it',
    flight[0] === 'T21' && flight.length > 1, flight.slice(0, 5).join());
  check('every word must match', b.search({ query: 'force field vampirism' }).every((p) => /force field/i.test(p.name + p.summary)));
  check('a class narrows to that class', b.search({ cls: 'D' }).length === 17 && b.search({ cls: 'D' }).every((p) => p.class === 'D'));
  check('and a code outside the chosen class finds nothing', b.search({ query: 'MG10', cls: 'D' }).every((p) => p.class === 'D'));
  check('the two-slot filter keeps only doubles', b.search({ doubleOnly: true }).length > 0
    && b.search({ doubleOnly: true }).every((p) => p.double));
  const rel = b.related(b.byCode.L2, 'bonus');
  check('related Powers resolve a code to its name', rel.length === 1 && rel[0].code === 'L10' && rel[0].name === 'Mind Control');
  const named = load('powers.json').powers.find((p) => (p.optional || []).some((x) => typeof x === 'object'));
  check('and keep a name that is not a Power as a name', !!named
    && b.related(named, 'optional').some((x) => x.code === null && x.name));
}

section('The codex: every section loads, searches, filters and keeps its address');

{
  const { SECTIONS, makeCodex, dataFiles, readState, writeState } = await import(new URL('../js/codex.js', import.meta.url));
  const names = dataFiles();
  check('every data file the codex asks for exists',
    names.length > 0 && names.every((n) => existsSync(join(dataDir, `${n}.json`))), names.join());
  const data = Object.fromEntries(names.map((n) => [n, load(`${n}.json`)]));
  // A throw is reported as the check's detail rather than ending the suite.
  let err = '';
  const attempt = (fn) => { try { return fn(); } catch (e) { err = e.message; return null; } };
  const codex = attempt(() => makeCodex(data));
  check('the codex builds from the shipped data', !!codex, err);
  const want = ['powers', 'talents', 'contacts', 'weaknesses', 'gear', 'npcs', 'items'];
  check('its sections are Powers, Talents, Contacts, Weaknesses, Gear, Notable NPCs, and Items and locations, in that order',
    SECTIONS.map((s) => s.id).join() === want.join(), SECTIONS.map((s) => s.id).join());
  // Each count read from the data file that owns it, not typed here.
  const expected = {
    powers: data.powers.powers.length,
    talents: data.talents.talents.length,
    contacts: data.contacts.contacts.length,
    weaknesses: ['stimulus', 'effect', 'duration'].reduce((n, k) => n + data.weakness[k].length, 0),
    gear: [...data.equipment.weapons, ...data.equipment.vehicles].reduce((n, t) => n + t.rows.length, 0),
    npcs: data.npcs.characters.length,
    items: data.items.items.length,
  };
  for (const s of codex?.sections || []) {
    const all = codex.search(s.id);
    check(`${s.id}: every row is listed (${expected[s.id]})`, s.rows.length === expected[s.id] && all.length === s.rows.length,
      `${s.rows.length} rows, ${all.length} listed`);
    check(`${s.id}: every key is unique, so ?entry= names one card`, s.byKey.size === s.rows.length,
      `${s.byKey.size} keys for ${s.rows.length} rows`);
    const bad = s.rows.filter((r) => !s.title(r) || !s.meta(r) || !s.summary(r) || !s.groups.some((g) => g.id === r.group));
    check(`${s.id}: every row has a title, a meta line, a summary and a group its filter offers`, bad.length === 0,
      bad.slice(0, 3).map((r) => JSON.stringify(r).slice(0, 80)).join(' | '));
    const statsOk = s.rows.every((r) => !s.stats || s.stats(r).every((x) => !x || (Array.isArray(x) && typeof x[0] === 'string')));
    check(`${s.id}: every stat line is a [label, value] pair`, statsOk);
    const g = s.groups[0].id;
    const inG = codex.search(s.id, { group: g });
    check(`${s.id}: a group narrows to that group`, inG.length > 0 && inG.length < s.rows.length && inG.every((r) => r.group === g),
      `${inG.length} of ${s.rows.length}`);
    // A word from the first row's title finds that row, and no row lacking it.
    const word = String(s.title(s.rows[0])).toLowerCase().split(/[^a-z0-9]+/).find((w) => w.length > 3) || '';
    const hits = codex.search(s.id, { query: word });
    check(`${s.id}: a search for "${word}" finds its row`, word && hits.includes(s.rows[0]), `${hits.length} hits`);
    check(`${s.id}: and a search nothing contains finds nothing`, codex.search(s.id, { query: 'zzqxv' }).length === 0);
  }
  if (codex) {
    check('the Powers section finds by exact code, as the Powers tab does',
      codex.search('powers', { query: 'mg10' }).map((r) => r.code).join() === 'MG10');
    check('and every Power card fetches its own code\'s text',
      codex.byId.powers.rows.every((r) => codex.byId.powers.fullText(r) === r.code));
    const gear = codex.byId.gear;
    const ranked = gear.rows.flatMap((r) => gear.stats(r)).filter(([, v]) => /\(.+\)$/.test(v || ''));
    check('gear rank cells read back onto the ladder by name', ranked.length > 0, String(ranked.length));

    const st = readState('?section=talents&q=guns&group=weapon&entry=guns', codex);
    check('the address reads back a section, search, group and open entry',
      st.section === 'talents' && st.q === 'guns' && st.group === 'weapon' && st.entry === 'guns', JSON.stringify(st));
    check('and writes the same view back out', readState(writeState(st), codex).entry === 'guns'
      && writeState(st) === '?section=talents&q=guns&group=weapon&entry=guns', writeState(st));
    const junk = readState('?section=nope&group=D&entry=<b>', codex);
    check('a section, group or entry the page does not offer is dropped, not trusted',
      junk.section === 'powers' && junk.group === 'D' && junk.entry === ''
      && readState('?section=contacts&group=D', codex).group === '', JSON.stringify(junk));
  }

  if (codex) {
    const npcs = codex.byId.npcs;
    const byName = (a, b) => a.localeCompare(b, 'en', { sensitivity: 'base', numeric: true });
    const sorted = (names) => names.every((n, i) => !i || byName(names[i - 1], n) <= 0);
    const listed = codex.search('npcs').map((r) => r.name);
    const team = codex.search('npcs', { group: npcs.groups[0].id }).map((r) => r.name);
    check(`Notable NPCs: the tab lists its ${listed.length} characters by name, and a team filter keeps that order`,
      listed.length === npcs.rows.length && sorted(listed) && team.length > 1 && sorted(team),
      listed.filter((n, i) => i && byName(listed[i - 1], n) > 0).slice(0, 3).join(', '));
    const nc = npcs.byKey.get('nightcrawler');
    check('Notable NPCs: Nightcrawler reads as the book prints him (p.7)',
      nc && npcs.summary(nc) === 'Kurt Wagner. Mutant hero'
      && npcs.stats(nc)[0][1].join(' | ') === 'F 20 Ex | A 50 Am | S 6 Ty | E 30 Rm | R 10 Gd | I 20 Ex | P 20 Ex'
      && npcs.stats(nc)[1][1] === '106 / 50', nc ? JSON.stringify(npcs.stats(nc).slice(0, 2)) : 'no nightcrawler');
    const linked = npcs.rows.flatMap((r) => npcs.related(r)).flatMap(([, items]) => items).filter((x) => x.code);
    const links = linked.filter((x) => x.section === 'powers');
    check(`Notable NPCs: every linked Power (${links.length}) is a Powers card, in the Powers section`,
      links.length > 0 && links.every((x) => codex.byId.powers.byKey.has(x.code)),
      links.filter((x) => !codex.byId.powers.byKey.has(x.code)).map((x) => x.code).join());
    const cards = linked.filter((x) => x.section !== 'powers');
    check(`Notable NPCs: every other link (${cards.length}, team to member and back) opens a Notable NPCs card`,
      cards.every((x) => x.section === 'npcs' && npcs.byKey.has(x.code)), cards.filter((x) => !npcs.byKey.has(x.code)).map((x) => x.code).join());
    // a version with no text rows (a chart-only hero) asks for none
    check('Notable NPCs: every card asks for its own entries\' text, one per version that has any and per cross-reference',
      npcs.rows.every((r) => npcs.bookText(r).length === r.versions.filter((v) => v.text.length).length + r.appearances.length
        && npcs.bookText(r).every((b) => b.book === r.book)));
    const minions = npcs.byKey.get('kang-s-minions-mh2');
    if (minions) {
      check('Notable NPCs: a derived Karma says it was not printed (MH2\'s Kang\'s Minions)',
        npcs.stats(minions).some(([k, v]) => k === 'Karma' && /^Not printed; R\+I\+P/.test(v)), JSON.stringify(npcs.stats(minions)));
    }
    // ME2's overrides carry a further rank in `also` as a number and a code;
    // its in-range S 250 Shift Y needs no override (registry rank_ranges)
    const chim = npcs.byKey.get('chimaera-me2');
    if (chim) {
      const lines = npcs.stats(chim).filter(([k]) => k === 'Misprint' || k === 'As printed').map(([k, v]) => `${k}: ${v}`);
      check('Notable NPCs: a block\'s further misprint reads as the first does, and an in-range number is no note (ME2\'s Chimaera)',
        lines.length === 2 && lines.filter((l) => /^Misprint: .* is printed 100 ShX; the book's own ranks give 100 Un$/.test(l)).length === 2,
        JSON.stringify(lines));
    }
    // MH5's Justin Hammer: a further misprint printed as a plain number
    const hammer = npcs.byKey.get('justin-hammer-mh5');
    if (hammer) {
      const lines = npcs.stats(hammer).filter(([k]) => k === 'Misprint' || k === 'As printed').map(([k, v]) => `${k}: ${v}`);
      check('Notable NPCs: a further misprint printed as a number reads as a misprint too (MH5\'s Justin Hammer, Health 28 and Karma 26)',
        lines.join(' | ') === 'Misprint: Health is printed 28; the book\'s own ranks give 30 | Misprint: Karma is printed 26; the book\'s own ranks give 36',
        JSON.stringify(lines));
    }
    // MSL3's machines print no Karma line, kept so with nothing derived: an
    // override whose printed is null, first or in `also`, says so
    const snake = npcs.byKey.get('flying-robotic-snake-msl3');
    const dragon = npcs.byKey.get('robotic-dragon-msl3');
    if (snake && dragon) {
      const notes = (r) => npcs.stats(r).filter(([k]) => k === 'Misprint' || k === 'As printed').map(([k, v]) => `${k}: ${v}`).join(' | ');
      check('Notable NPCs: a Karma the book does not print, and no ruling derives, says so (MSL3\'s Flying Robotic Snake, and the Robotic Dragon\'s in its also)',
        notes(snake) === 'As printed: Karma is not printed, and none is derived'
        && notes(dragon).endsWith(' | As printed: Karma is not printed, and none is derived')
        && npcs.stats(dragon).some(([k, v]) => k === 'Health / Karma' && v === 'See text / -'),
        `${notes(snake)} || ${notes(dragon)}`);
    }
    // A string or number kept as printed names the sum by its field: F+A+S+E
    // for Health, R+I+P for Karma, none for an ability (Nate, 2026-11-03); a
    // printed rank with no number reads as its code alone
    const notesOf = (id) => {
      const r = npcs.byKey.get(id);
      return r && npcs.stats(r).filter(([k]) => k === 'Misprint' || k === 'As printed').map(([k, v]) => `${k}: ${v}`).join(' | ');
    };
    const wording = {
      'dominus-msl1': 'As printed: Strength is printed N/A; read as 0',
      'super-adaptoid-mh9': 'As printed: Health is printed 150, which F+A+S+E does not give',
      'black-talon-s-zombie-mla1': 'As printed: Health is printed 80, which F+A+S+E does not give',
      'sunspot-mlba1': 'As printed: Health is printed 52(76), which F+A+S+E does not give',
      'dormammu-me3': 'As printed: Health is printed 1275*, which F+A+S+E does not give',
      'mark-iv-sentinel-mx1': 'As printed: Karma is printed 0, which R+I+P does not give',
      'stygorr-msl2': 'Misprint: Psyche is printed Rm; the book\'s own ranks give 30 Rm | Misprint: Endurance is printed 40 Ex; the book\'s own ranks give 20 Ex | Misprint: Reason is printed 30 In; the book\'s own ranks give 40 In',
    };
    const off = Object.entries(wording).filter(([id, want]) => npcs.byKey.has(id) && notesOf(id) !== want);
    check('Notable NPCs: an As printed line names the sum by its field and a numberless printed rank is its code (MSL1\'s Dominus, MSL2\'s Stygorr, MH9\'s Super-Adaptoid, MX1\'s Sentinel)',
      off.length === 0, off.map(([id]) => `${id}: ${notesOf(id)}`).join(' || '));
    const wrong = [...npcs.byKey.keys()].map((id) => [id, notesOf(id)])
      .filter(([, n]) => /Health is printed [^|]*R\+I\+P|Karma is printed [^|]*F\+A\+S\+E|printed null|(Fighting|Agility|Strength|Endurance|Reason|Intuition|Psyche) is printed [^|;]*, which/.test(n || ''));
    check('Notable NPCs: no card names the wrong sum for its field, or prints null for a rank\'s number',
      wrong.length === 0, wrong.map(([id, n]) => `${id}: ${n}`).join(' || '));
  }

  // A new section is one entry: a descriptor added to the list is a section,
  // with nothing else touched.
  const extra = { id: 'extra', label: 'Extra', source: 'test', files: [], groupLabel: 'Team',
    build: () => ({ rows: [{ id: 'a', name: 'Alpha', group: 't' }], groups: [{ id: 't', name: 'Team' }] }),
    key: (r) => r.id, title: (r) => r.name, meta: () => 'Team', summary: () => '', hay: (r) => r.name };
  const plus = attempt(() => makeCodex(data, [...SECTIONS, extra]));
  check('a new section is one descriptor: it builds and searches with nothing else changed',
    plus?.search('extra', { query: 'alpha' }).length === 1 && readState('?section=extra', plus).section === 'extra');
}

section('Notable NPCs: every block adds up or is a misprint read off the page, and the file carries no prose');

{
  const n = load('npcs.json');
  const RANK = { Sh0: 0, Fe: 2, Fb: 2, Pr: 4, Po: 4, Ty: 6, Gd: 10, Go: 10, Ex: 20, Rm: 30, Re: 30, In: 40, Am: 50,
    Mn: 75, Un: 100, ShX: 150, ShY: 200, ShZ: 500, 'C-1000': 1000, 'C-3000': 3000, 'C-5000': 5000 };
  const blocks = n.characters.flatMap((c) => c.versions.flatMap((v) => v.blocks.map((b) => ({ c, v, b }))));
  check(`there are characters, versions and blocks (${n.characters.length}, ${blocks.length} blocks)`,
    n.characters.length > 100 && blocks.length >= n.characters.length);
  // The sources line prints a one-page span as its page and two spans that
  // touch as one (npcs.py span_text): MLBA1 once read "3-31, 32-32" and MX1
  // "28-28". Read per part (between semicolons), number spans only.
  const badSpans = n.sources.filter((s) => s.pages.split(';').some((part) => {
    const spans = [...part.matchAll(/(\d+)(?:-(\d+))?/g)].map((m) => [Number(m[1]), Number(m[2] ?? m[1])]);
    return [...part.matchAll(/(\d+)-(\d+)/g)].some((m) => m[1] === m[2])
      || spans.some((x, i) => i > 0 && x[0] <= spans[i - 1][1] + 1);
  }));
  check(`no book's sources line prints an N-N span or two spans that touch (${n.sources.length} books)`,
    n.sources.length > 0 && badSpans.length === 0, badSpans.map((s) => `${s.book}: ${s.pages}`).join(' | '));
  // A partial grid prints no rank at all for the rows its override names
  // (MA4's New Men: their physical ranks are the animal's, p.90). Those rows
  // are null, and no other row anywhere may be.
  const unprinted = (b, a) => b.kind === 'partial' && a[1] === null && a[2] === null
    && b.override?.verdict === 'rows' && (b.override.field || '').includes(a[0]);
  // Beyond is the one rank with no number (ranks.json): MHSP2's Beyonder
  // prints it in every row of his Original State, rank_only, so no number.
  const beyond = (b, a) => b.rank_only && a[1] === null && a[2] === 'B';
  // N/A over a dash, kept as printed: no code over 0, which the block's
  // printed Health bears out, and no rank derived (MSL1's Dominus, S, printed
  // 30; survey msl1.md decision 7). Only a row its as_printed override names.
  const notApplicable = (b, a) => a[1] === 0 && a[2] === null && b.override?.verdict === 'as_printed'
    && b.override.printed === 'N/A' && (b.override.field || '').includes(a[0]);
  const shape = blocks.filter(({ b }) => b.abilities.map((a) => a[0]).join('') !== 'FASERIP'
    || b.abilities.some((a) => !unprinted(b, a) && !beyond(b, a) && !notApplicable(b, a) && (!Number.isInteger(a[1]) || !(a[2] in RANK))));
  check('every block is F, A, S, E, R, I, P in order, each a whole number and a rank code the ladder knows',
    shape.length === 0, shape.slice(0, 3).map(({ c, b }) => `${c.id}: ${JSON.stringify(b.abilities)}`).join(' | '));
  const known = (b, field) => b.kind === 'table' || (b.override && (b.override.field === field
    || (b.override.also || []).some((x) => x.field === field)));
  const num = (s) => (/^-?\d+$/.test(String(s ?? '').trim()) ? Number(s) : null);
  // A misprinted ability NUMBER (MX1's Timbre Morava, printed 24: S 4, R 6
  // and I 8 for Ty, Ex and Ty) is summed as corrected, since Health and
  // Karma hold on the corrected numbers and the override says so; a corrected
  // code alone changes no number.
  const fixedNumber = (b, a) => [b.override, ...(b.override?.also || [])]
    .find((o) => o?.verdict === 'misprint' && o.field === a[0] && Number.isInteger(o.corrected?.number))?.corrected.number ?? a[1];
  const sum = (b, from, to) => b.abilities.slice(from, to).reduce((t, a) => t + fixedNumber(b, a), 0);
  const health = blocks.filter(({ b }) => num(b.health) !== null && num(b.health) !== sum(b, 0, 4) && !known(b, 'health'));
  check('Health = F+A+S+E on every block, or its override says the page misprints it',
    health.length === 0, health.map(({ c, b }) => `${c.id} ${b.health}`).join(', '));
  const karma = blocks.filter(({ b }) => num(b.karma) !== null && num(b.karma) !== sum(b, 4, 7) && !known(b, 'karma'));
  check('Karma = R+I+P on every block, or its override records it as printed',
    karma.length === 0, karma.map(({ c, b }) => `${c.id} ${b.karma}`).join(', '));
  // A book whose registry sets rank_ranges (ME2, Nate 2026-10-21; ME3, its
  // survey's decision 3, 2026-10-30; MT2, its survey's decision 8,
  // 2026-10-30; MX2, its survey's decision 5, 2026-10-31; MX3, its
  // survey's decision 5, 2026-11-01) means a
  // number anywhere inside its rank's range (ranks.json min and max), as
  // scripts/msh/roster.py's check takes it; every other book, the standard.
  const ranged = new Set(Object.entries(JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'books.json'), 'utf8')).books)
    .filter(([, bk]) => bk.rank_ranges).map(([slug]) => slug));
  const span = Object.fromEntries(Object.entries(RANK).map(([code, std]) => {
    const r = ranks.find((x) => x.standard === std);
    return [code, [r.min, r.max ?? Infinity]];
  }));
  const agrees = (c, a) => RANK[a[2]] === a[1] || (ranged.has(c.book) && a[1] >= span[a[2]][0] && a[1] <= span[a[2]][1]);
  const codes = blocks.filter(({ c, b }) => b.abilities.some((a, i) => !agrees(c, a) && !known(b, 'FASERIP'[i]) && !unprinted(b, a) && !beyond(b, a)));
  check('every number agrees with its rank code (inside its range, for a book whose registry sets rank_ranges), or its override names the misprint',
    codes.length === 0, codes.map(({ c }) => c.id).join(', '));
  check(`only ME2's, ME3's, MT2's, MX2's, MX3's and MX4's registry entries set rank_ranges (${[...ranged]})`, [...ranged].join() === 'me2,me3,mt2,mx2,mx3,mx4', [...ranged].join());
  const misprints = blocks.filter(({ b }) => b.override && b.override.verdict === 'misprint');
  check('each misprint keeps both the printed value and the corrected one',
    misprints.length > 0 && misprints.every(({ b }) => 'printed' in b.override && 'corrected' in b.override), String(misprints.length));
  const ids = n.characters.flatMap((c) => [c.id, ...c.versions.map((v) => v.id), ...c.appearances.map((a) => a.id)]);
  check('character, version and cross-reference ids are unique across the book, so each names one set of text rows',
    new Set(n.characters.map((c) => c.id)).size === n.characters.length
    && new Set(n.characters.flatMap((c) => [...c.versions.map((v) => v.id), ...c.appearances.map((a) => a.id)])).size
      === ids.length - n.characters.length);
  check('every team a character names is in the teams list its filter offers',
    n.characters.every((c) => n.teams.includes(c.team)));
  // An identity is a name and a status line. Three lines is a paragraph, and a
  // paragraph is the book's prose, which belongs in msh_book_text only.
  const long = n.characters.flatMap((c) => c.versions).filter((v) => v.identity.length > 2);
  check('no identity is longer than two lines, so no paragraph of the book rides in on one',
    long.length === 0, long.map((v) => v.id).join());
  // A run-in that heads an entry's account of its powers is not a power: the
  // Beyonder's ABILITY SCORES and POWERS (MHSP2 Roster 2) are its powers intro
  // (a powers_intro verdict in scripts/msh/mhsp2-overrides.json).
  const heading = /^(known )?powers?$|^ability scores$|^talents?$|^contacts?$/i;
  const headed = n.characters.flatMap((c) => c.versions)
    .flatMap((v) => (v.powers || []).filter((p) => heading.test(p.name)).map((p) => `${v.id}: ${p.name}`));
  check('no power is named for a heading (Powers, Known Powers, Ability Scores, Talents, Contacts)',
    headed.length === 0, headed.join(', '));

  // Team members given their team's stats (scripts/msh/<slug>-members.json):
  // the tier block with only the ranks their text states, and wherever the
  // text prints a Health, the build reproduces it.
  const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  const built = blocks.filter(({ b }) => b.built_from);
  const byId = Object.fromEntries(n.characters.map((c) => [c.id, c]));
  check(`every member built from a team's block names its team and a tier that team has (${built.length})`,
    built.length > 0 && built.every(({ c, b }) => byId[slug(c.member_of)]?.versions.some((v) => v.blocks.some((t) => t.label === b.built_from.tier))),
    built.filter(({ c }) => !byId[slug(c.member_of)]).map(({ c }) => c.id).join());
  const drift = built.filter(({ c, b }) => {
    const tier = byId[slug(c.member_of)].versions.flatMap((v) => v.blocks).find((t) => t.label === b.built_from.tier);
    return b.abilities.some((a, i) => (a[0] in b.built_from.changes ? RANK[b.built_from.changes[a[0]]] !== a[1] : a[1] !== tier.abilities[i][1]));
  });
  check('and differs from that tier only in the abilities its text names', drift.length === 0, drift.map(({ c }) => c.id).join());
  const printed = built.filter(({ b }) => b.built_from.printed_health !== undefined);
  check(`where the text prints a Health, the build gives that Health (${printed.map(({ c, b }) => `${c.name} ${b.health}`).join(', ')})`,
    printed.length >= 2 && printed.every(({ b }) => Number(b.health) === b.built_from.printed_health));
  const links = n.characters.flatMap((c) => c.versions.flatMap((v) => v.members)).filter((m) => m.id);
  check('every member a team lists with an id opens a card that exists', links.length > 0 && links.every((m) => byId[m.id]),
    links.filter((m) => !byId[m.id]).map((m) => m.id).join());
}

section('Every book in one file: each row names a book the registry has, and only the first book keeps plain ids');

{
  // scripts/msh/npcs.py and extras.py merge by book: rebuilding one replaces
  // only its own rows. Books never collide, because every book after the
  // registry's first ends its ids in -<slug> (two books' Magnetos are two
  // cards, Nate 2026-09-28).
  const order = Object.keys(JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'books.json'), 'utf8')).books);
  const files = { npcs: load('npcs.json'), items: load('items.json') };
  const rows = { npcs: files.npcs.characters, items: files.items.items };
  for (const [name, list] of Object.entries(rows)) {
    const listed = files[name].books.map((b) => b.slug);
    check(`${name}: every row names its book, and that book is listed in the file and in the registry`,
      list.every((r) => listed.includes(r.book) && order.includes(r.book)) && listed.every((b) => order.includes(b)),
      list.filter((r) => !listed.includes(r.book)).map((r) => r.id).join());
    check(`${name}: the file lists its books in registry order, and only books it has rows for`,
      listed.join() === order.filter((b) => list.some((r) => r.book === b)).join(), listed.join());
    const bad = list.filter((r) => (r.book === order[0]) === r.id.endsWith(`-${r.book}`));
    check(`${name}: only the registry's first book keeps plain ids; every later book's end in -<book>`,
      bad.length === 0, bad.map((r) => r.id).join());
  }
  // npcs.py drops a leading The from a character's name in every book, so the
  // card sorts by the next word (Nate, 2026-10-21: Thing, Beyonder, Watcher,
  // Chosen, Fenris Wolf). A team's name is not a card's and keeps its The.
  const leadingThe = rows.npcs.filter((c) => /^the\s/i.test(c.name) || /^the-/.test(c.id));
  check('npcs: no character\'s name or id starts with The', leadingThe.length === 0, leadingThe.map((c) => c.id).join());

  // Each book's checks further down run only while npcs.json has its rows
  // (`if (data.npcs.characters.some((c) => c.book === ...))`), so a book whose
  // rows vanished would skip them and pass. Whether a book is imported is
  // recorded apart from the data: its survey's Rows line, which the survey PR
  // writes as 0 and the data PR sets to the rows read back from production. A
  // book that counts rows there must have characters here. No book is items
  // only today; one that is would fail this, and this is the rule to change.
  const surveys = join(appDir, 'docs', 'surveys');
  const imported = [];
  const noRowsLine = [];
  for (const slug of order) {
    const survey = join(surveys, `${slug}.md`);
    if (!existsSync(survey)) continue;
    const m = /^\*\*Rows citing this book:\*\* (\d[\d,]*) `msh_book_text` rows/m.exec(readFileSync(survey, 'utf8'));
    if (!m) noRowsLine.push(slug);
    else if (Number(m[1].replace(/,/g, '')) > 0) imported.push(slug);
  }
  check('every Marvel survey carries a Rows line with a count', noRowsLine.length === 0, noRowsLine.join());
  const vanished = imported.filter((slug) => !rows.npcs.some((c) => c.book === slug));
  check(`npcs: every book whose survey counts rows in production has characters (${imported.length})`,
    imported.length > 0 && vanished.length === 0, vanished.join());

  // What a second book does to the code that reads these files, before one
  // exists: a copy of MA1's Nightcrawler as another book's.
  const { makeCodex, dataFiles } = await import(new URL('../js/codex.js', import.meta.url));
  const { makeBookNpc, bookChoices } = await import(new URL('../js/npc-book.js', import.meta.url));
  const data = Object.fromEntries(dataFiles().map((n) => [n, load(`${n}.json`)]));
  const two = structuredClone(data.npcs);
  const nc = two.characters.find((c) => c.id === 'nightcrawler');
  const copy = { ...structuredClone(nc), id: 'nightcrawler-zz1', book: 'zz1',
    versions: nc.versions.map((v) => ({ ...structuredClone(v), id: `${v.id}-zz1` })) };
  two.characters.push(copy);
  two.books.push({ slug: 'zz1', short: 'ZZ1', title: 'ZZ1 A Second Book', pages: [1, 9] });
  const codex = makeCodex({ ...data, npcs: two });
  const sec = codex.byId.npcs;
  const [a, b] = [sec.byKey.get('nightcrawler'), sec.byKey.get('nightcrawler-zz1')];
  check('with two books, a name in both is two cards, each citing its own book',
    a && b && sec.meta(a).includes('MA1') && sec.meta(b).includes('ZZ1') && sec.tags(b).includes('ZZ1')
    && sec.bookText(b).every((x) => x.book === 'zz1') && sec.source.includes('ZZ1 A Second Book'), sec.meta(b));
  const labels = bookChoices(two).filter((c) => c.label.startsWith('Nightcrawler')).map((c) => c.label);
  // one choice per book that has him: MA1, MHSP1 since it was imported, and the copy
  const nightcrawlers = two.characters.filter((c) => c.name === 'Nightcrawler').length;
  check(`and the GM's choices tell them apart by book (${nightcrawlers})`,
    nightcrawlers >= 2 && labels.length === nightcrawlers && new Set(labels).size === nightcrawlers
    && labels.every((l) => / \[[A-Z0-9]+\]$/.test(l)), labels.join(' | '));
  const built = makeBookNpc({ npcs: two, ranks: load('ranks.json') })({ character: 'nightcrawler-zz1' });
  check('and a sheet from the second book is that book\'s', built.snapshot?.book.slug === 'zz1'
    && built.snapshot.book.source === 'ZZ1 A Second Book' && built.build.book === 'zz1', JSON.stringify(built.snapshot?.book));
}

section('The book-text endpoint reads one entry\'s rows, GET only, in the book\'s order, and answers none with missing');

{
  const mod = await import(new URL('../../../functions/api/marvel-heroes/book-text.js', import.meta.url));
  const handlers = Object.keys(mod).filter((k) => k.startsWith('onRequest'));
  check('its only handler is onRequestGet, so every other method is a 405',
    handlers.join() === 'onRequestGet', handlers.join());
  const npcs = load('npcs.json');
  const ids = npcs.characters.flatMap((c) => [...c.versions.map((v) => v.id), ...c.appearances.map((a) => a.id)]);
  check(`its patterns take every entry id npcs.json writes (${ids.length}) and its book`,
    npcs.books.every((b) => mod.BOOK.test(b.slug)) && ids.every((id) => mod.ENTRY.test(id)), ids.filter((id) => !mod.ENTRY.test(id)).join());
  check('and refuse anything else', !['', 'MA1', "x' OR 1=1", 'a b', '-x', 'x-', '../x'].some((e) => mod.ENTRY.test(e) && mod.BOOK.test(e)));
  const stored = [
    { key: 'ma1:nightcrawler:running', part: 'running', name: null, page: 7, body: 'r' },
    { key: 'ma1:nightcrawler:power:2', part: 'power', name: 'Prehensile Tail', page: 7, body: 'b' },
    { key: 'ma1:nightcrawler:talents', part: 'talents', name: null, page: 7, body: 't' },
    { key: 'ma1:nightcrawler:power:1', part: 'power', name: 'Teleportation', page: 7, body: 'a' },
  ];
  const env = { DB_MARVEL: { prepare: () => ({ bind: (book, entry) => ({
    all: async () => ({ results: book === 'ma1' && entry === 'nightcrawler' ? stored : [] }) }) }) } };
  const call = async (qs, headers = { 'Cf-Access-Authenticated-User-Email': 'a@b.c' }) => {
    const res = await mod.onRequestGet({ request: new Request(`https://example.com/api/marvel-heroes/book-text?${qs}`, { headers }), env });
    return { status: res.status, body: await res.json() };
  };
  const hit = await call('book=ma1&entry=nightcrawler');
  check('an entry\'s rows come back in the book\'s order: powers as numbered, then talents, then the running notes',
    hit.status === 200 && hit.body.parts.map((p) => p.key.split(':').slice(2).join(':')).join() === 'power:1,power:2,talents,running',
    JSON.stringify(hit.body.parts?.map((p) => p.key)));
  const miss = await call('book=ma1&entry=magneto');
  check('an entry with no rows is a 404 that says missing', miss.status === 404 && miss.body.missing === true);
  check('a bad book or entry is a 400', (await call('book=ma1&entry=a%20b')).status === 400 && (await call('entry=x')).status === 400);
  check('and nobody signed in is a 401', (await call('book=ma1&entry=nightcrawler', {})).status === 401);

  const { fetchBookText, bookMissingNote, renderParts } = await import(new URL('../js/book-text.js', import.meta.url));
  const reply = (status, body) => async () => new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
  const gone = await fetchBookText('ma1', 'x', reply(404, { missing: true }));
  const down = await fetchBookText('ma1', 'x', async () => { throw new Error('offline'); });
  check('the page reads a missing entry and a failed fetch apart, and never throws',
    !gone.ok && gone.missing && !down.ok && !down.missing && bookMissingNote(gone) !== bookMissingNote(down));
  check('a power keeps its printed name as a run-in head, escaped',
    renderParts([{ part: 'power', name: 'A<b>', body: 'x & y' }]) === '<p><strong>A&lt;b&gt;:</strong> x &amp; y</p>');
  check('and so does a section\'s run-in and a location\'s part',
    renderParts([{ part: 'section', name: 'Karma', body: 'k' }, { part: 'part', name: 'Traps', body: 't' }])
      === '<p><strong>Karma:</strong> k</p><p><strong>Traps:</strong> t</p>');
  check('MH4\'s Equipment: a paragraph under the heading, or named run-ins under it once',
    renderParts([{ part: 'equipment', name: null, body: 'e' }]) === '<p><strong>Equipment:</strong> e</p>'
    && renderParts([{ part: 'equipment', name: 'Guns', body: 'g' }, { part: 'equipment', name: 'Van', body: 'v' }])
      === '<p><strong>Equipment:</strong></p><p><strong>Guns:</strong> g</p><p><strong>Van:</strong> v</p>');
  check('a line break in a body is a <br>, set after escaping (MH4\'s GUNS., a gun a line)',
    renderParts([{ part: 'equipment', name: 'Guns', body: 'guns:\nM16 <x>: 10\nPistol & 6' }])
      === '<p><strong>Equipment:</strong></p><p><strong>Guns:</strong> guns:<br>M16 &lt;x&gt;: 10<br>Pistol &amp; 6</p>');

  // Every part npcs.py writes for a character has a place in the endpoint's
  // order, and every section it writes by name (its `for part in (...)` lists)
  // has a heading on the card. A part missing from the order sorts first; one
  // missing a heading prints as bare prose. MH1's `special` was both.
  const { PART_HEAD } = await import(new URL('../js/book-text.js', import.meta.url));
  const npcsPy = readFileSync(new URL('../../../scripts/msh/npcs.py', import.meta.url), 'utf8');
  const written = [...npcsPy.matchAll(/text_row\(\s*\w+,\s*'([a-z-]+)'/g)].map((m) => m[1]);
  const sections = [...npcsPy.matchAll(/for part in (\([^:]*\)):/g)]
    .flatMap((m) => [...m[1].matchAll(/'([a-z-]+)'/g)].map((x) => x[1]));
  check(`every part npcs.py writes (${new Set([...written, ...sections]).size}) has a place in the endpoint's order`,
    written.length > 0 && sections.length > 0 && [...written, ...sections].every((p) => mod.PART_ORDER.includes(p)),
    [...written, ...sections].filter((p) => !mod.PART_ORDER.includes(p)).join());
  check(`and every section it writes by name (${new Set(sections).size}) has a heading on the card`,
    sections.every((p) => PART_HEAD[p]), sections.filter((p) => !PART_HEAD[p]).join());

  // An item's rows (and the adventure section a vehicle reads) are all numbered in print order,
  // and that number is the order, whatever the parts are called.
  const numbered = [
    { key: 'ma1:dreamchild-encounter-1:section:3', part: 'section', name: 'Encounter', page: 87, body: 'c' },
    { key: 'ma1:dreamchild-encounter-1:prose:1', part: 'prose', name: null, page: 87, body: 'a' },
    { key: 'ma1:dreamchild-encounter-1:section:2', part: 'section', name: 'Summary', page: 87, body: 'b' },
    { key: 'ma1:dreamchild-encounter-1:notes:4', part: 'notes', name: null, page: 87, body: 'd' },
  ];
  const envN = { DB_MARVEL: { prepare: () => ({ bind: () => ({ all: async () => ({ results: numbered }) }) }) } };
  const resN = await mod.onRequestGet({ request: new Request('https://example.com/api/marvel-heroes/book-text?book=ma1&entry=dreamchild-encounter-1',
    { headers: { 'Cf-Access-Authenticated-User-Email': 'a@b.c' } }), env: envN });
  check('rows numbered in print order come back in that order',
    (await resN.json()).parts.map((p) => p.body).join('') === 'abcd');
}

section('Items and locations: facts only, one id each, every id one the endpoint takes');

{
  const items = load('items.json');
  const { ENTRY, BOOK } = await import(new URL('../../../functions/api/marvel-heroes/book-text.js', import.meta.url));
  const { dataFiles } = await import(new URL('../js/codex.js', import.meta.url));
  // A vehicle stated inside an adventure section reads that section's text
  // (`section`): the one kind of adventure row msh_book_text keeps.
  const ids = items.items.map((i) => i.id);
  const sections = items.items.filter((i) => i.section).map((i) => i.section);
  check(`there are items (${items.items.length})`, items.items.length > 0);
  check('every id is unique and one the book-text endpoint takes, and so is every section a vehicle reads', new Set(ids).size === ids.length
    && [...ids, ...sections].every((id) => ENTRY.test(id)) && items.books.every((b) => BOOK.test(b.slug)),
    [...ids, ...sections].filter((id) => !ENTRY.test(id)).join());
  check('the app ships no adventures: the data file is gone and no codex section reads one',
    !existsSync(join(dataDir, 'adventures.json')) && !dataFiles().includes('adventures'));
  // MA4 prints no Control, Speed or Body line: its vehicles' speeds are in
  // their text (survey: ma4.md), so there a vehicle has none
  const NO_VEHICLE_LINES = new Set(['ma4']);
  check('an item\'s kind is item, vehicle or location, and only a vehicle has Control, Speed and Body',
    items.items.every((i) => ['item', 'vehicle', 'location'].includes(i.kind)
      && (i.vehicle ? i.kind === 'vehicle' : i.kind !== 'vehicle' || NO_VEHICLE_LINES.has(i.book))
      && (!i.vehicle || Object.keys(i.vehicle).join() === 'Control,Speed,Body')));
}

section('A missing power text degrades to the summary, never an error');

{
  const { fetchPowerText, makePowerText, missingNote } = await import(new URL('../js/power-text.js', import.meta.url));
  const reply = (status, body) => async () => new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });
  const hit = await fetchPowerText('MG10', reply(200, { code: 'MG10', name: 'Reality Alteration', page: 47, body: 'text' }));
  check('a stored text comes back as ok with its body', hit.ok && hit.body.body === 'text', JSON.stringify(hit));
  const miss = await fetchPowerText('D1', reply(404, { code: 'D1', missing: true }));
  check('the endpoint\'s 404 missing:true is read as missing, not thrown',
    miss.ok === false && miss.missing === true && miss.status === 404, JSON.stringify(miss));
  check('and says the summary is what ships', /summary above is what the app ships/.test(missingNote(miss)));
  const down = await fetchPowerText('D1', async () => { throw new TypeError('network'); });
  check('a network failure is an answer too, not an exception', down.ok === false && down.missing === false && down.status === 0);
  check('and says it could not be fetched, not that it is missing', /could not be fetched/.test(missingNote(down)));
  const junk = await fetchPowerText('D1', async () => new Response('<html>Access</html>', { status: 302 }));
  check('a body that is not JSON (the Access wall) is not missing either', junk.ok === false && junk.missing === false);
  let calls = 0;
  const cached = makePowerText(async () => { calls += 1; return new Response('{"missing":true}', { status: 404 }); });
  await cached('D1'); await cached('D1');
  check('each page asks for one code once', calls === 1, String(calls));
  // Against the real endpoint, with the empty table a repo-built database has.
  const mod = await import(new URL('../../../functions/api/marvel-heroes/power-text.js', import.meta.url));
  const env = { DB_MARVEL: { prepare: () => ({ bind: () => ({ first: async () => null }) }) } };
  const real = await fetchPowerText('D1', (url) => mod.onRequestGet({
    request: new Request(`https://example.com${url}`, { headers: { 'Cf-Access-Authenticated-User-Email': 'a@b.c' } }), env }));
  check('the real endpoint on an empty table degrades the same way', real.ok === false && real.missing === true, JSON.stringify(real));
}

section('The generator builds a legal hero, and the same seeds always build the same one');

{
  const { makeGenerator, newSeeds, PRIMARY } = await import(new URL('../js/generator.js', import.meta.url));
  const data = {};
  for (const n of ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts']) data[n] = load(`${n}.json`);
  const gen = makeGenerator(data);
  const R = Object.fromEntries(data.ranks.ranks.map((r, i) => [r.id, i]));
  const seeds = { body: 1, origin: 2, abilities: 3, weakness: 4, counts: 5, powers: 6, talents: 7 };
  const safe = (fn) => { try { return fn(); } catch (e) { return { threw: e.message }; } };

  const a = safe(() => gen.build({ seeds })), b = safe(() => gen.build({ seeds }));
  check('the same seeds build the same hero', !a.threw && JSON.stringify(a) === JSON.stringify(b), a.threw);
  // Pinned: seeds 1-7 make this Lupinoid. A hero can be rebuilt from its seeds
  // only while this holds; a change to the generator is a deliberate re-pin.
  const pin = a.threw ? a.threw : [a.body.id, a.origin.id, ...PRIMARY.map((k) => a.abilities[k].rank), a.health, a.karma,
    ...a.powers.map((p) => `${p.code}:${p.rank}`), ...a.talents.map((t) => t.id)].join(',');
  check('and seeds 1-7 are pinned', pin === 'lupinoid,biological-exposure,incredible,feeble,excellent,poor,incredible,excellent,excellent,56,68,'
    + 'MCo1:remarkable,EE8:poor,D15:amazing,EE14:good,D1:excellent,P11:excellent,guns,geology,pilot', pin);

  // Two thousand random heroes against the rules.
  const problems = new Set();
  let specials = 0;
  for (let i = 0; i < 2000; i++) {
    const h = safe(() => gen.build({ seeds: newSeeds() }));
    if (h.threw) { problems.add('threw: ' + h.threw); continue; }
    const t = gen.typeById[h.body.id];
    if (t.special) specials++;
    const used = h.powers.filter((p) => p.source !== 'body').reduce((s, p) => s + p.slots, 0);
    if (used !== h.slots.powers) problems.add(`power slots ${used} of ${h.slots.powers}`);
    if (new Set(h.powers.map((p) => p.code)).size !== h.powers.length) problems.add('a Power twice');
    if (h.powers.some((p) => !gen.powerByCode[p.code] || !(p.rank in R))) problems.add('an unknown Power or rank');
    if (h.talents.reduce((s, x) => s + x.slots, 0) !== h.slots.talents) problems.add('talent slots');
    if (new Set(h.talents.map((x) => x.id)).size !== h.talents.length) problems.add('a Talent twice');
    for (const k of PRIMARY) {
      const r = h.abilities[k];
      if (!r.set && (R[r.rank] < R.feeble || R[r.rank] > R.monstrous)) problems.add(`${k} ${r.rank} outside Feeble-Monstrous`);
    }
    const sum = (ks) => ks.reduce((s, k) => s + h.abilities[k].number, 0);
    if (h.karma !== sum(['reason', 'intuition', 'psyche'])) problems.add('Karma');
    if (!t.special) {
      if (h.health !== sum(['fighting', 'agility', 'strength', 'endurance']) * (t.health_multiplier || 1)) problems.add('Health');
      const bodyPowers = gen.merged(t, h.body.variant).bonus_powers.length;
      if (h.powers.filter((p) => p.source === 'body').length !== bodyPowers) problems.add(`${t.id}: body Powers`);
    } else {
      const ids = h.body.aspects.map((x) => x.id);
      if (ids.length < 2 || ids.length > 5 || new Set(ids).size !== ids.length || ids.some((x) => gen.typeById[x].special)) problems.add(`${t.id}: aspects ${ids}`);
      if (t.special === 'compound' && h.body.column !== Math.min(5, ids.length)) problems.add('compound column (R14)');
      if (t.special === 'changeling' && (h.body.column !== 5 || h.forms.length !== ids.length)) problems.add('changeling forms');
    }
  }
  check('2,000 random heroes: slots filled exactly, nothing twice, ranks in bounds, Health and Karma summed, body Powers granted',
    problems.size === 0, [...problems].slice(0, 6).join('; '));
  check('and the dice do reach Compound and Changeling (2 rolls in 100, so about 40 in 2,000)', specials >= 15 && specials <= 75, String(specials));

  const as = (body, extra = {}) => safe(() => gen.build({ seeds, picks: { body, ...extra } }));
  const d = as('deity');
  const plain = safe(() => gen.build({ seeds, picks: { body: 'deity', ranks: {} } }));
  check('a Deity: every Primary Ability +2CS, stopping at Monstrous (R18)', PRIMARY.every((k) => {
    const x = d.abilities[k];
    return R[x.rank] === Math.min(R[x.rolled] + 2, R.monstrous);
  }), PRIMARY.map((k) => `${d.abilities[k].rolled}->${d.abilities[k].rank}`).join(' '));
  check('and two more Powers, and a Travel Power from the body that takes no slot (R17)',
    d.slots.powers === d.counts.powers.initial + 2 && d.powers.some((p) => p.source === 'body' && p.code.startsWith('T') && p.slots === 0));
  const veg = as('vegetable');
  check('a Vegetable: Resources zero, Fighting -2CS, Endurance +2CS, Absorption at Good',
    veg.abilities.resources.rank === 'shift-0' && veg.abilities.resources.number === 0
      && veg.abilities.fighting.cs === -2 && veg.abilities.endurance.cs === 2
      && veg.powers.some((p) => p.code === 'EC1' && p.rank === 'good' && p.source === 'body'));
  const eth = as('ethereal');
  check('an Ethereal\'s Fighting is set to Shift 0', eth.abilities.fighting.rank === 'shift-0' && eth.abilities.fighting.number === 0);
  const nh = as('normal-human');
  const col2 = data['random-ranks'].columns['2'];
  check('a Normal Human rolls on column 2', PRIMARY.every((k) => col2.some((bd) => bd.rank === nh.abilities[k].rolled
    && nh.abilities[k].roll >= bd.lo && nh.abilities[k].roll <= bd.hi)));
  // A reroll of the body is a new BODY seed; the ability dice must not move.
  const reBody = safe(() => gen.build({ seeds: { ...seeds, body: 99 } }));
  check('the same ability dice are read again when the body is rerolled or picked',
    PRIMARY.every((k) => nh.abilities[k].roll === d.abilities[k].roll && reBody.abilities[k].roll === a.abilities[k].roll)
      && reBody.body.id !== a.body.id, `${a.body.id} -> ${reBody.body.id}`);
  const ind = as('mutant-induced', { choose: ['psyche'] });
  check('a picked free +1CS goes where the player put it', ind.chosen.join() === 'psyche' && ind.abilities.psyche.cs === 1);
  const indRes = as('mutant-induced', { choose: ['resources'] });
  check('and an Induced Mutant\'s cannot go to Resources, which is not a Primary Ability',
    !indRes.chosen.includes('resources') && PRIMARY.includes(indRes.chosen[0]));
  const bought = as('normal-human', { bought: { powers: 1 } });
  const room = nh.counts.powers.max - nh.counts.powers.initial;
  check('buying a Power adds a slot and costs -2CS Resources',
    room < 1 || (bought.slots.powers === nh.slots.powers + 1 && R[bought.abilities.resources.rank] === Math.max(R.feeble, R[nh.abilities.resources.rank] - 2)));
  const greedy = as('normal-human', { bought: { powers: 99 } });
  check('and buying stops at the table\'s maximum', greedy.slots.powers === nh.counts.powers.max);
  const picked = as('normal-human', { powers: ['T21'] });
  check('a picked Power is kept and the dice fill the rest', picked.powers[0].code === 'T21' && picked.powers[0].source === 'picked'
    && picked.powers.reduce((s, p) => s + p.slots, 0) === picked.slots.powers);
  const v = as('avian', { variant: 'harpy' });
  check('a picked variant is used: a Harpy rolls on column 2 with Fighting +1CS (R15)',
    v.body.variant === 'harpy' && v.body.column === 2 && v.abilities.fighting.cs === 1);
}

section('Compound and Changeling, built the way the book\'s own examples describe');

{
  const { makeGenerator, newSeeds, PRIMARY } = await import(new URL('../js/generator.js', import.meta.url));
  const data = {};
  for (const n of ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts']) data[n] = load(`${n}.json`);
  const gen = makeGenerator(data);
  const R = Object.fromEntries(data.ranks.ranks.map((r, i) => [r.id, i]));
  const safe = (fn) => { try { return fn(); } catch (e) { return { threw: e.message }; } };
  const seeds = { body: 11, origin: 2, abilities: 3, weakness: 4, counts: 5, powers: 6, talents: 7 };

  // UPB p.10's Compound: three aspects - Normal Human, Chiropteran, Other
  // Demihuman - at 33%. The book cites them by roll, and its rolls do not
  // match its own table, so they are given here by body type (README).
  const freak = [{ id: 'normal-human' }, { id: 'chiropteran' }, { id: 'demihuman-other' }];
  const c = safe(() => gen.build({ seeds, picks: { body: 'compound', aspects: freak } }));
  check('the book\'s Compound: three types at 33%, rolling on column 3 (R14)',
    !c.threw && c.body.aspects.map((x) => x.id).join() === 'normal-human,chiropteran,demihuman-other'
      && c.body.retain === 33 && c.body.column === 3, c.threw || `${c.body.retain} ${c.body.column}`);
  check('and its own -1CS Popularity comes on top of whatever it keeps',
    !c.threw && c.abilities.popularity.cs <= -1 + (c.body.aspects[0].kept.includes('shift:popularity') ? 0 : 0));
  // Over many seeds, a two-type Compound keeps close to half its traits, and a
  // kept body Power arrives while an unkept one does not.
  let kept = 0, total = 0, powerRight = 0, powerCases = 0;
  for (let i = 0; i < 1500; i++) {
    const h = gen.build({ seeds: newSeeds(), picks: { body: 'compound', aspects: [{ id: 'chiropteran' }, { id: 'vegetable' }] } });
    for (const x of h.body.aspects) {
      const all = x.id === 'chiropteran' ? 2 : 5;       // Chiropteran: set:popularity, bonus:0. Vegetable: 2 shifts, set, bonus, contacts
      kept += x.kept.length; total += all;
    }
    const veg = h.body.aspects.find((x) => x.id === 'vegetable');
    powerCases++;
    if (veg.kept.includes('bonus:0') === h.powers.some((p) => p.code === 'EC1' && p.source === 'body')) powerRight++;
  }
  check('a two-type Compound keeps about half of its traits (50% each)', Math.abs(kept / total - 0.5) < 0.04,
    (kept / total).toFixed(3));
  check('and a body Power arrives exactly when its trait was kept', powerRight === powerCases, `${powerRight}/${powerCases}`);
  const cy = gen.build({ seeds, picks: { body: 'compound', aspects: [{ id: 'normal-human' }, { id: 'robot-usuform' }] } });
  const flesh = gen.build({ seeds, picks: { body: 'compound', aspects: [{ id: 'normal-human' }, { id: 'felinoid' }] } });
  const cyborgNote = (h) => h.body.notes.some((n) => /is also a Cyborg/.test(n));
  check('a Compound with an artificial type is also a Cyborg, and one without is not', cyborgNote(cy) && !cyborgNote(flesh));

  // UPB p.10's Changeling: a Humanshape Robot that turns into a Vegetable.
  const kit = safe(() => gen.build({ seeds, picks: { body: 'changeling', aspects: [{ id: 'robot-humanshape' }, { id: 'vegetable' }] } }));
  check('the book\'s Changeling: two forms, rolling once on column 5',
    !kit.threw && kit.body.column === 5 && kit.forms.map((f) => f.id).join() === 'robot-humanshape,vegetable', kit.threw);
  const [robot, plant] = kit.threw ? [{}, {}] : kit.forms;
  check('each form applies its own traits to the SAME dice: the robot has no Popularity, the plant no Resources',
    !kit.threw && PRIMARY.every((k) => robot.abilities[k].roll === plant.abilities[k].roll)
      && robot.abilities.popularity.rank === 'shift-0' && plant.abilities.resources.rank === 'shift-0'
      && R[plant.abilities.fighting.rank] === Math.max(R.feeble, R[plant.abilities.fighting.rolled] - 2));
  check('the plant\'s Absorption belongs to the plant form', !kit.threw && kit.powers.some((p) => p.code === 'EC1' && p.form === 1));
  let unique = true, noAlterEgo = true, slotsOk = true;
  for (let i = 0; i < 1500; i++) {
    const h = gen.build({ seeds: newSeeds(), picks: { body: 'changeling' } });
    const n = h.forms.length;
    for (let f = 0; f < n; f++) if (!h.powers.some((p) => p.form === f && p.source !== 'body')) unique = false;
    if (h.powers.some((p) => p.code === 'S2')) noAlterEgo = false;
    if (h.slots.powers < n) slotsOk = false;
  }
  check('every Changeling form has a Power of its own, with at least one slot per form (R19)', unique && slotsOk);
  check('and a Changeling never keeps Alter Ego', noAlterEgo);
}

section('Point Buy (R24): the costs, the cap, the steps, and what a rolled hero costs');

{
  const { makeGenerator } = await import(new URL('../js/generator.js', import.meta.url));
  const { makePointBuy, emptyBuild, normalise, DEFAULT_CAP } = await import(new URL('../js/pointbuy.js', import.meta.url));
  const data = {};
  for (const n of ['ranks', 'random-ranks', 'body-types', 'origins', 'weakness', 'counts', 'power-tables', 'powers', 'talents', 'contacts']) data[n] = load(`${n}.json`);
  const gen = makeGenerator(data);
  const pb = makePointBuy(data, gen);
  const single = data.powers.powers.find((p) => !p.double).code;
  const double = data.powers.powers.find((p) => p.double).code;
  const b = emptyBuild({ limit: 200 });
  const line = (l, kind, key) => l.lines.find((x) => x.kind === kind && x.key === key);

  check('a fresh build has no numbers, the default cap, and the limit it was given',
    Object.values(b.abilities).every((n) => n === null) && b.cap === DEFAULT_CAP && b.limit === 200);
  b.abilities.fighting = 24;
  check('an ability costs its exact number: Excellent 24 costs 24', line(pb.ledger(b), 'ability', 'fighting').cost === 24);
  b.powers.push({ code: single, number: 30, gm: false, free: false }, { code: double, number: 30, gm: false, free: false });
  let l = pb.ledger(b);
  check('a Power costs its rank number, and a two-slot Power pays double', line(l, 'power', 0).cost === 30 && line(l, 'power', 1).cost === 60);
  check('and choosing one costs nothing more', l.spent === 24 + 30 + 60);
  b.powers.push({ code: data.powers.powers.find((p) => p.double && p.code !== double).code, number: 40, gm: true, free: true });
  l = pb.ledger(b);
  check('a GM-granted Power costs nothing while it is excluded', line(l, 'power', 2).cost === 0 && l.spent === 114);
  b.powers[2].free = false;
  check('and is charged, double, when the tick is taken off', pb.ledger(b).spent === 114 + 80);
  b.powers[2].free = true;
  b.bonuses.push({ ability: 'fighting', amount: 10, reason: '', free: true });
  check('an excluded bonus costs nothing and still raises the ability', pb.ledger(b).spent === 114 && pb.hero(b).total.fighting === 34);
  b.bonuses[0].free = false;
  check('an included one is charged its amount', pb.ledger(b).spent === 124);
  b.items.push({ name: 'Jet pack', notes: '', points: 15, free: true });
  check('another grant costs nothing while excluded, and its points when not',
    pb.ledger(b).spent === 124 && (b.items[0].free = false, pb.ledger(b).spent === 139));
  b.limit = 100;
  check('going over the limit gives a negative remainder, it does not refuse', pb.ledger(b).remaining === -39);
  b.limit = 200;
  check('Health is F+A+S+E and Karma R+I+P, with the grants in them',
    (b.abilities.agility = 10, pb.hero(b).health === 34 + 10) && (b.abilities.psyche = 6, pb.hero(b).karma === 6));

  b.cap = 'excellent';
  l = pb.ledger(b);
  check('the cap flags a bought ability above it', l.overCap.some((x) => x.kind === 'power' && x.key === 0) && !l.overCap.some((x) => x.key === 'fighting'));
  b.abilities.strength = 26;
  check('Remarkable 26 is above an Excellent cap; Excellent 25 is not',
    pb.ledger(b).overCap.some((x) => x.key === 'strength') && (b.abilities.strength = 25, !pb.ledger(b).overCap.some((x) => x.key === 'strength')));
  check('a granted Power ignores the cap', !pb.ledger(b).overCap.some((x) => x.kind === 'power' && x.key === 2));

  check('up from 24 is Remarkable 30, down is Excellent 20, and 20 down is Good 10',
    pb.step(24, 1) === 30 && pb.step(24, -1) === 20 && pb.step(20, -1) === 10);
  check('up from nothing is Feeble 2, and nothing goes below Feeble', pb.step(null, 1) === 2 && pb.step(2, -1) === null && pb.step(1, -1) === null);
  check('up stops at the cap', pb.step(20, 1, 'excellent') === null && pb.step(20, 1, 'remarkable') === 30);
  check('the steps run the whole ladder to Class 5000', pb.step(3000, 1) === 5000 && pb.step(5000, 1) === null);

  const m = emptyBuild({ limit: 100, cap: 'unearthly' });
  m.abilities.fighting = 30;
  m.abilities.agility = 20;
  check('most affordable: what is left, within the cap', pb.maxAffordable(m, 'ability', 'fighting') === 80
    && (m.cap = 'good', pb.maxAffordable(m, 'ability', 'fighting') === 15));
  m.cap = 'unearthly';
  m.powers.push({ code: double, number: 10, gm: false, free: false });
  check('a two-slot Power affords half of what is left', pb.maxAffordable(m, 'power', 0) === Math.floor((100 - 50) / 2));
  m.limit = 50;
  check('and nothing when nothing is left', pb.maxAffordable(m, 'power', 0) === null);
  m.limit = null;
  check('with no limit set, only the cap bounds it', pb.maxAffordable(m, 'ability', 'fighting') === 125);

  const s = emptyBuild({ limit: 60 });
  s.abilities.fighting = 40;
  check('a new Power starts at Good when there is room', pb.startingNumber(s, single) === 10);
  check('at what is left when there is less, halved for two slots', (s.abilities.fighting = 54, pb.startingNumber(s, single) === 6 && pb.startingNumber(s, double) === 3));
  check('and never below 1', (s.abilities.fighting = 60, pb.startingNumber(s, single) === 1));

  const snap = pb.snapshot(b);
  check('the snapshot names each ability\'s rank from its total, and marks a granted Power',
    snap.abilities.fighting.name === 'Remarkable' && snap.abilities.fighting.number === 34 && snap.powers[2].source === 'granted');
  check('an ability with no number is a dash on the sheet, not an error', snap.abilities.endurance.name === '-');
  check('normalising a saved build gives it back unchanged', JSON.stringify(normalise(JSON.parse(JSON.stringify(b)), pb)) === JSON.stringify(b));
  check('and makes anything malformed empty rather than throwing',
    JSON.stringify(normalise({ limit: -3, cap: 'nope', abilities: { fighting: 'x' }, powers: [{ code: 'ZZ9' }], bonuses: 'no' }, pb)) === JSON.stringify(emptyBuild()));

  const a = pb.rolledCosts();
  check('what a rolled hero costs is the same every time', JSON.stringify(a) === JSON.stringify(pb.rolledCosts()));
  check(`and is a sensible spread (median ${a.median}, half between ${a.low} and ${a.high})`,
    a.low > 0 && a.low <= a.median && a.median <= a.high && a.high < 2000);
}

section('Every ruling in the data is in the README, and every README ruling is in the data');

// Collect every "ruling" value, anywhere in any data file.
function rulingsIn(v, out) {
  if (Array.isArray(v)) v.forEach((x) => rulingsIn(x, out));
  else if (v && typeof v === 'object') {
    for (const [k, x] of Object.entries(v)) {
      // `ruling`, and the `column_ruling` / `variant_ruling` a body type uses
      // when the ruling is about one field rather than the whole entry.
      if (/(^|_)ruling$/.test(k)) out.add(x);
      else rulingsIn(x, out);
    }
  }
  return out;
}
const inData = new Set();
for (const f of dataFiles) rulingsIn(load(f), inData);
// A ruling the generator applies lives in its code, cited as "R17:" in a comment.
for (const f of walk(join(appDir, 'js')).filter((p) => p.endsWith('.js'))) {
  for (const m of readFileSync(f, 'utf8').matchAll(/\/\/.*?\b(R\d+):/g)) inData.add(m[1]);
}
const inReadme = new Set([...readme.matchAll(/^- \*\*(R\d+)\*\*/gm)].map((m) => m[1]));
check('the README lists at least one ruling as "- **Rn**"', inReadme.size > 0);
for (const id of inData) check(`${id}, cited in the data, is in the README`, inReadme.has(id));
for (const id of inReadme) check(`${id}, in the README, is cited by the data`, inData.has(id));

section('Sourcebooks: the Marvel list is the data\'s own');

{
  // The Marvel Sourcebooks page reads apps/sourcebooks/marvel/books.json, which
  // scripts/sourcebooks.mjs builds from the registry, data/*.json and each
  // survey's Rows line. A book PR that forgets to rebuild it fails here.
  const { buildMarvel, stale } = await import(new URL('../../../scripts/sourcebooks.mjs', import.meta.url));
  const list = buildMarvel();
  const npcs = load('npcs.json');
  const withChars = [...new Set(npcs.characters.map((c) => c.book))];
  check('the list is every book with characters in the Codex, each counting its own',
    list.books.map((b) => b.slug).join() === withChars.join()
      && list.books.every((b) => b.total === npcs.characters.filter((c) => c.book === b.slug).length && b.code && b.date),
    list.books.map((b) => `${b.slug} ${b.total} ${b.date}`).join('; '));
  const why = stale('marvel');
  check('apps/sourcebooks/marvel/books.json is a fresh build (run node scripts/sourcebooks.mjs after a book PR)', why === null, why || '');
  const tile = JSON.parse(readFileSync(join(repoRoot, 'apps', 'manifest.json'), 'utf8')).apps.find((a) => a.slug === 'sourcebooks/marvel');
  check('the hub has a live Sourcebooks tile in the Marvel section',
    tile?.status === 'live' && tile.group === 'marvel' && /^<svg /.test(tile.icon || ''), JSON.stringify(tile?.group));
}

process.exit(summary() === 0 ? 0 : 1);
