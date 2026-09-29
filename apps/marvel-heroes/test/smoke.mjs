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
    // The Hunt's table (books.json adventure_tables), transcribed by eye: a d10
    // roll 1-10, a villain the book stats, and a hero it stats as the target.
    const hunt = load('adventures.json').adventures.flatMap((a) => a.sections).find((s) => s.id === 'secret-wars-mhsp1-the-hunt');
    const named = (side) => new Set(data.npcs.characters.filter((c) => c.book === 'mhsp1' && c.side === side).map((c) => c.name));
    const [villains, heroes] = [named('Secret Wars Villains'), named('Secret Wars Heroes')];
    const alias = { 'Doc Octopus': 'Doctor Octopus', 'Mr. Fantastic': 'Mister Fantastic' };
    const who = (n) => alias[n.replace(/\*$/, '')] || n.replace(/\*$/, '');
    check('MHSP1: The Hunt carries its table: rolls 1-10, each a villain against a hero the book stats',
      hunt?.table?.rows.length === 10 && hunt.table.rows.every(([roll, v, t], i) => roll === i + 1 && villains.has(who(v)) && heroes.has(who(t)))
      && hunt.table.rows.filter((r) => r[2].endsWith('*')).length === 2, JSON.stringify(hunt?.table?.rows?.slice(0, 3)));
    check('MHSP1: the sheet cites the booklet with the page, and a Summary-only character the booklet alone',
      tagline(bookNpc({ character: 'colossus-mhsp1' }).snapshot).startsWith('MHSP1 Secret Wars, Roster p.2;')
      && tagline(bookNpc({ character: 'spider-man-mhsp1' }).snapshot).startsWith('MHSP1 Secret Wars, Reference Summary;'),
      tagline(bookNpc({ character: 'spider-man-mhsp1' }).snapshot));
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
    check(`${page} loads no other app's script`, srcs.every((s) => s.startsWith('/shared/js/campaign/') || !s.startsWith('/')), srcs.join(' '));
  }
  const pageScripts = ['campaign/campaign.js', 'gm/gm.js', 'gm/present.js'].map((f) => readFileSync(join(appDir, f), 'utf8'));
  // GM tools is where a Marvel GM runs a session, so The Table's panel is drawn
  // there as well as on the Campaigns page, not merely loaded.
  check('GM tools loads and draws The Table\'s panel',
    /MC\.table\.load\(\)/.test(pageScripts[1]) && /MC\.table\.html\(\)/.test(pageScripts[1]));
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
    // Nor are the books' own names: a run of section, team and character names
    // in the Contents' order ("X-Factor, New Mutants, Hellfire Club ...", the
    // teams list npcs.json carries) is a list, not prose.
    const registry = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'msh', 'books.json'), 'utf8')).books;
    const NAMES = new Set(Object.values(registry).flatMap((b) => [
      ...(b.sections || []).flatMap(([s, sub]) => [s, sub || '']), ...(b.index || []).map(([n]) => n),
      ...['heroes', 'villains'].flatMap((k) => ((b.reference_summary || {})[k] || []).map(([n]) => n)),
    ]).flatMap(words));
    const prose = (run) => run.filter((x) => /^[a-z]{3,}$/.test(x) && !RANK_ABBR.has(x) && !NAMES.has(x)).length >= 6;
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
      for (const e of JSON.parse(readFileSync(f, 'utf8')).entries) {
        // Not the identity lines: a name and a status line are what npcs.json is
        // meant to carry, and the Notable NPCs section holds them to two lines.
        [...Object.values(e.sections), e.prose, ...e.powers.map((p) => p.text), ...e.members.map((m) => m.text)]
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
      if (b.item_pages) add(b.item_part, b.item_pages);
      if (b.adventure) add(b.adventure.part, b.adventure.pages);
      if (b.running) add(b.running.part, b.running.pages);
      return out;
    };
    const unparsed = [];
    for (const [slug, b] of Object.entries(registry)) {
      const dir = join(booksDir, slug, 'txt');
      if (!existsSync(dir)) continue;
      const skip = existsSync(join(booksDir, slug, 'roster.json')) ? covered(b) : new Set();
      for (const f of readdirSync(dir)) {
        if (skip.has(Number(f.slice(1, 4)))) continue;
        unparsed.push(`${slug} ${f.slice(0, 4)}`);
        addText(readFileSync(join(dir, f), 'utf8').replace(/-\r?\n/g, ''));
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
  const want = ['powers', 'talents', 'contacts', 'weaknesses', 'gear', 'npcs', 'items', 'adventures'];
  check('its sections are Powers, Talents, Contacts, Weaknesses, Gear, Notable NPCs, Items and locations, and Adventures, in that order',
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
    adventures: data.adventures.adventures.reduce((n, a) => n + a.sections.length, 0),
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
    const nc = npcs.byKey.get('nightcrawler');
    check('Notable NPCs: Nightcrawler reads as the book prints him (p.7)',
      nc && npcs.summary(nc) === 'Kurt Wagner. Mutant hero'
      && npcs.stats(nc)[0][1] === 'F 20 Ex | A 50 Am | S 6 Ty | E 30 Rm | R 10 Gd | I 20 Ex | P 20 Ex'
      && npcs.stats(nc)[1][1] === '106 / 50', nc ? JSON.stringify(npcs.stats(nc).slice(0, 2)) : 'no nightcrawler');
    const linked = npcs.rows.flatMap((r) => npcs.related(r)).flatMap(([, items]) => items).filter((x) => x.code);
    const links = linked.filter((x) => x.section === 'powers');
    check(`Notable NPCs: every linked Power (${links.length}) is a Powers card, in the Powers section`,
      links.length > 0 && links.every((x) => codex.byId.powers.byKey.has(x.code)),
      links.filter((x) => !codex.byId.powers.byKey.has(x.code)).map((x) => x.code).join());
    const cards = linked.filter((x) => x.section !== 'powers');
    check(`Notable NPCs: every other link (${cards.length}, team to member and back) opens a Notable NPCs card`,
      cards.every((x) => x.section === 'npcs' && npcs.byKey.has(x.code)), cards.filter((x) => !npcs.byKey.has(x.code)).map((x) => x.code).join());
    check('Notable NPCs: every card asks for its own entries\' text, one per version and cross-reference',
      npcs.rows.every((r) => npcs.bookText(r).length === r.versions.length + r.appearances.length
        && npcs.bookText(r).every((b) => b.book === r.book)));
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
  const shape = blocks.filter(({ b }) => b.abilities.map((a) => a[0]).join('') !== 'FASERIP'
    || b.abilities.some((a) => !Number.isInteger(a[1]) || !(a[2] in RANK)));
  check('every block is F, A, S, E, R, I, P in order, each a whole number and a rank code the ladder knows',
    shape.length === 0, shape.slice(0, 3).map(({ c, b }) => `${c.id}: ${JSON.stringify(b.abilities)}`).join(' | '));
  const known = (b, field) => b.kind === 'table' || (b.override && b.override.field === field);
  const num = (s) => (/^-?\d+$/.test(String(s ?? '').trim()) ? Number(s) : null);
  const sum = (b, from, to) => b.abilities.slice(from, to).reduce((t, a) => t + a[1], 0);
  const health = blocks.filter(({ b }) => num(b.health) !== null && num(b.health) !== sum(b, 0, 4) && !known(b, 'health'));
  check('Health = F+A+S+E on every block, or its override says the page misprints it',
    health.length === 0, health.map(({ c, b }) => `${c.id} ${b.health}`).join(', '));
  const karma = blocks.filter(({ b }) => num(b.karma) !== null && num(b.karma) !== sum(b, 4, 7) && !known(b, 'karma'));
  check('Karma = R+I+P on every block, or its override records it as printed',
    karma.length === 0, karma.map(({ c, b }) => `${c.id} ${b.karma}`).join(', '));
  const codes = blocks.filter(({ b }) => b.abilities.some((a, i) => RANK[a[2]] !== a[1] && !known(b, 'FASERIP'[i])));
  check('every number agrees with its rank code, or its override names the misprint',
    codes.length === 0, codes.map(({ c }) => c.id).join(', '));
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
  const files = { npcs: load('npcs.json'), items: load('items.json'), adventures: load('adventures.json') };
  const rows = { npcs: files.npcs.characters, items: files.items.items, adventures: files.adventures.adventures };
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
  check('and so does an adventure\'s run-in and a location\'s part',
    renderParts([{ part: 'section', name: 'Karma', body: 'k' }, { part: 'part', name: 'Traps', body: 't' }])
      === '<p><strong>Karma:</strong> k</p><p><strong>Traps:</strong> t</p>');

  // An item's or an adventure section's rows are all numbered in print order,
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

section('Items, locations and the adventure: facts only, one id each, every id one the endpoint takes');

{
  const items = load('items.json');
  const adv = load('adventures.json');
  const { ENTRY, BOOK } = await import(new URL('../../../functions/api/marvel-heroes/book-text.js', import.meta.url));
  const ids = [...items.items.map((i) => i.id), ...adv.adventures.flatMap((a) => a.sections.map((s) => s.id))];
  check(`there are items and adventure sections (${items.items.length}, ${ids.length - items.items.length})`,
    items.items.length > 0 && adv.adventures.every((a) => a.sections.length > 0));
  check('every id is unique and one the book-text endpoint takes', new Set(ids).size === ids.length
    && ids.every((id) => ENTRY.test(id)) && [...items.books, ...adv.books].every((b) => BOOK.test(b.slug)), ids.filter((id) => !ENTRY.test(id)).join());
  check('an item\'s kind is item, vehicle or location, and only a vehicle has Control, Speed and Body',
    items.items.every((i) => ['item', 'vehicle', 'location'].includes(i.kind)
      && (i.kind === 'vehicle') === !!i.vehicle && (!i.vehicle || Object.keys(i.vehicle).join() === 'Control,Speed,Body')));
  check('every numbered encounter is in order from 1, with a title of its own',
    adv.adventures.every((a) => a.sections.filter((s) => s.number).every((s, i) => s.number === i + 1 && /^Encounter \d+: \S/.test(s.title))),
    adv.adventures.flatMap((a) => a.sections.map((s) => s.title)).join(' | '));
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

process.exit(summary() === 0 ? 0 : 1);
