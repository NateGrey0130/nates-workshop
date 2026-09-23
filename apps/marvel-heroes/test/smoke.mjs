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
  const env = { DB: { prepare: () => ({ bind: (code) => ({ first: async () => rows[code] || null }) }) } };
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
    for (const e of Object.values(JSON.parse(readFileSync(full, 'utf8')))) {
      const w = words(e.body);
      for (let i = 0; i + N <= w.length; i++) shingles.add(w.slice(i, i + N).join(' '));
    }
    const tracked = spawnSync('git', ['ls-files', '-z', '--', 'apps/marvel-heroes', 'functions/api/marvel-heroes',
      'scripts/msh-extract.py', 'db/migrations/081-msh-power-text.sql'], { cwd: repoRoot, encoding: 'utf8' })
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
    check(`no file shares ${N} words in a row with the book's power text (${shingles.size} runs checked)`,
      leaks.length === 0, leaks.join('; '));
  }
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
const inReadme = new Set([...readme.matchAll(/^- \*\*(R\d+)\*\*/gm)].map((m) => m[1]));
check('the README lists at least one ruling as "- **Rn**"', inReadme.size > 0);
for (const id of inData) check(`${id}, cited in the data, is in the README`, inReadme.has(id));
for (const id of inReadme) check(`${id}, in the README, is cited by the data`, inData.has(id));

process.exit(summary() === 0 ? 0 : 1);
