// FilamentForge smoke test: the deterministic parts of the OFD refresh (CSV
// in, ASCII SQL out), the data endpoint's sanitizers, and the claims the
// app's README makes — table names, caps, counts, and what the app talks to —
// so the README cannot quietly stop being true.
//
// Run from anywhere:  node apps/filament-forge/test/smoke.mjs
//
// The harness is the character creator's: section/check/summary are app-
// agnostic, and a second copy would drift from the first.

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { section, check, summary } from '../../character-creator/test/harness.mjs';
import {
  MIN_BRANDS, MIN_FILAMENTS, ROWS_PER_INSERT, FILAMENT_COLUMNS,
  parseCSV, parseCSVLine, dedupeById, sqlLit, insertChunks, buildSnapshotSql,
} from '../../../scripts/ofd-refresh-lib.mjs';
import {
  MAX_HISTORY, sanitizeEntry, sanitizePreset, sanitizeCustom, entryOut,
} from '../../../functions/api/filament-forge/data.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');
const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
const schema = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');

const ascii = (s) => [...s].every((ch) => {
  const c = ch.codePointAt(0);
  return c >= 32 && c <= 126 || ch === '\n';
});

// Reverse sqlLit: '...'||char(N)||'...' back to the original string, so the
// splice can be proven lossless rather than merely present.
const evalLit = (expr) => expr.split('||').map((part) => {
  const m = part.match(/^char\((\d+)\)$/);
  return m ? String.fromCodePoint(Number(m[1])) : part.slice(1, -1).replace(/''/g, "'");
}).join('');

// ---------- 1. CSV parsing ----------
section('CSV parsing');

check('a plain line splits on commas',
  JSON.stringify(parseCSVLine('a,b,c')) === '["a","b","c"]');
check('a quoted field keeps its comma',
  JSON.stringify(parseCSVLine('a,"b,c",d')) === '["a","b,c","d"]');
check('a doubled quote is one literal quote',
  JSON.stringify(parseCSVLine('a,"say ""hi""",c')) === '["a","say \\"hi\\"","c"]');

{
  const rows = parseCSV('id,name,material\r\n1,PLA Basic,PLA\r\n2,"Tough, Very",PETG\r\n');
  check('CRLF input parses the same as LF',
    rows.length === 2 && rows[1].name === 'Tough, Very' && rows[1].material === 'PETG');
  check('headers become keys', rows[0].id === '1' && rows[0].name === 'PLA Basic');
}
check('a line far short of the header count is skipped as garbage',
  parseCSV('a,b,c,d\n1,2,3,4\njunk\n').length === 1);
check('a header-only file is no rows', parseCSV('id,name\n').length === 0);

{
  const d = dedupeById([{ id: '1', v: 'first' }, { id: '', v: 'no-id' }, { id: '1', v: 'second' }]);
  check('dedupe drops id-less rows and keeps one per id', d.length === 1);
  // Arbitrary but stated in the lib: the later row wins.
  check('and the later duplicate wins', d[0].v === 'second');
}

// ---------- 2. Snapshot SQL ----------
section('Snapshot SQL');

check('a quote is doubled, and doubles back',
  sqlLit("it's") === "'it''s'" && evalLit(sqlLit("it's")) === "it's");
{
  const tricky = 'Café – 90°C ™';
  check('non-ASCII input yields pure-ASCII SQL', ascii(sqlLit(tricky)));
  check('and splices back to the exact original', evalLit(sqlLit(tricky)) === tricky);
}
check('control characters are dropped, not emitted',
  evalLit(sqlLit('a\tb\nc')) === 'abc');
check('null and undefined are empty strings, not the word',
  sqlLit(null) === "''" && sqlLit(undefined) === "''");

{
  const rows = Array.from({ length: 250 }, (_, i) => ({ id: String(i), name: 'n' + i }));
  const stmts = insertChunks('t', ['id', 'name'], rows);
  check(`inserts chunk at ${ROWS_PER_INSERT} rows`, stmts.length === 3);
  check('and no statement exceeds the chunk',
    stmts.every((s) => (s.match(/\n\(/g) || []).length <= ROWS_PER_INSERT));
  check('every chunk is a complete INSERT',
    stmts.every((s) => s.startsWith('INSERT INTO t (id, name) VALUES') && s.endsWith(';')));
}

{
  const sql = buildSnapshotSql(
    [{ id: 'b1', name: 'Café Brand' }],
    [{ id: 'f1', brand_id: 'b1', name: 'PLA™' }],
    '2026-01-01T00:00:00.000Z');
  check('the whole artifact is pure ASCII whatever the catalog holds', ascii(sql));
  check('filaments are deleted before brands',
    sql.indexOf('DELETE FROM ff_filaments;') < sql.indexOf('DELETE FROM ff_brands;'));
  check('and both come before any insert',
    sql.indexOf('DELETE FROM ff_brands;') < sql.indexOf('INSERT INTO'));
  check('every filament column the table has is in the insert',
    FILAMENT_COLUMNS.every((c) => sql.includes(c)));
  check('the fetched_at stamp rides on both tables',
    (sql.match(/2026-01-01T00:00:00\.000Z/g) || []).length === 2);
  check('the header says the file is generated and uncommittable',
    sql.startsWith('--') && sql.includes('do not commit'));
}
check('the plausibility floors exist and are not trivial',
  MIN_BRANDS >= 10 && MIN_FILAMENTS >= 100);

// ---------- 3. The data endpoint's sanitizers ----------
section('Data sanitizers');

check('an entry without a string id is refused',
  sanitizeEntry(null) === null && sanitizeEntry({}) === null
  && sanitizeEntry({ id: 7 }) === null && sanitizeEntry({ id: 'x'.repeat(101) }) === null);
{
  const e = sanitizeEntry({ id: 'a1' });
  check('a bare id gets safe defaults',
    e.id === 'a1' && e.brand === '' && e.settings === '{}' && e.timestamp.length > 0);
}
{
  const e = sanitizeEntry({ id: 'a1', filament: { brand: 'B'.repeat(400) }, rawJSON: 'r'.repeat(30000) });
  check('short fields cap at 300 and blobs at 20000',
    e.brand.length === 300 && e.rawJSON.length === 20000);
}
check('a preset must carry a non-blank name',
  sanitizePreset({ id: 'p1' }) === null && sanitizePreset({ id: 'p1', presetName: '  ' }) === null
  && sanitizePreset({ id: 'p1', presetName: 'Mine' }).presetName === 'Mine');
check('a custom filament must carry brand and name',
  sanitizeCustom({ id: 'c1', brand: 'B' }) === null
  && sanitizeCustom({ id: 'c1', brand: ' ', name: 'N' }) === null
  && sanitizeCustom({ id: 'c1', brand: 'B', name: 'N' }).material === '');

{
  // The full round trip: client entry → sanitized → the row the INSERT would
  // write → what the GET would hand back. What goes in is what comes out.
  const original = {
    id: 'rt1', timestamp: '2026-08-01T12:00:00.000Z',
    filament: { brand: 'Polymaker', name: 'PolyLite PLA', material: 'PLA' },
    printer: 'Bambu Lab X1C', nozzle: '0.6', intent: 'quality',
    settings: { temperature: { nozzle: '215°C' } }, rawJSON: '{"x":1}',
  };
  const e = sanitizeEntry(original);
  const row = { entry_id: e.id, created_at: e.timestamp, brand: e.brand, name: e.name,
    material: e.material, printer: e.printer, nozzle: e.nozzle, intent: e.intent,
    settings: e.settings, raw_json: e.rawJSON };
  check('an entry survives the row round-trip',
    JSON.stringify(entryOut(row)) === JSON.stringify(original));
  check('and unparseable stored settings degrade to {} rather than a throw',
    JSON.stringify(entryOut({ ...row, settings: '{broken' }).settings) === '{}');
}

// ---------- 4. What the app talks to ----------
section('What the app talks to');

check('openfilamentdatabase.org appears nowhere in the app',
  !appSrc.includes('openfilamentdatabase'));
{
  const external = [...new Set([...appSrc.matchAll(/https?:\/\/([^/'"`]+)/g)].map((m) => m[1]))];
  check('no external origin appears in the app at all',
    external.length === 0, external.join(', '));
}
{
  // JSZip is vendored, not fetched: the file must exist, the app must load
  // that path, and the version this README claims must be the version the
  // file's own header announces.
  const vendored = join(appDir, 'vendor', 'jszip.min.js');
  check('the vendored JSZip exists and the app loads it',
    existsSync(vendored) && appSrc.includes("'vendor/jszip.min.js'"));
  const header = readFileSync(vendored, 'utf8').slice(0, 300);
  const fileVersion = (header.match(/JSZip v(\d+\.\d+\.\d+)/) || [])[1];
  const readmeVersion = (readme.match(/JSZip v(\d+\.\d+\.\d+)/) || [])[1];
  check('the README and the file agree on the JSZip version',
    fileVersion && fileVersion === readmeVersion,
    `file: ${fileVersion} readme: ${readmeVersion}`);
  check('the vendor directory is exempt from line-ending normalization',
    readFileSync(join(repoRoot, '.gitattributes'), 'utf8')
      .includes('apps/filament-forge/vendor/* -text'));
}
{
  const writes = [...new Set([...appSrc.matchAll(/localStorage\.setItem\(\s*'([^']+)'/g)].map((m) => m[1]))];
  check('localStorage is written only for onboarding',
    writes.length === 1 && writes[0] === 'ff_onboarding_done');
  const reads = [...new Set([...appSrc.matchAll(/localStorage\.getItem\(\s*(?:'([^']+)'|k)/g)].map((m) => m[1]))];
  const legacy = ['ff_config', 'ff_history', 'ff_presets', 'ff_custom_filaments'];
  check('the import path names exactly the four legacy keys',
    legacy.every((k) => appSrc.includes(`'${k}'`)));
  check('and the README lists all five keys it discusses',
    [...legacy, 'ff_onboarding_done'].every((k) => readme.includes('`' + k + '`')));
  check('reads beyond onboarding go through the parse helper',
    reads.filter(Boolean).every((k) => k === 'ff_onboarding_done'));
}

// ---------- 5. The README's claims ----------
section('The README’s claims');

const schemaTables = [...schema.matchAll(/CREATE TABLE IF NOT EXISTS (ff_[a-z_]+)/g)].map((m) => m[1]);
const readmeTables = [...readme.matchAll(/^\| `(ff_[a-z_]+)` \|/gm)].map((m) => m[1]);
check('the data-model table lists every ff_ table in schema.sql',
  schemaTables.length === 6
  && JSON.stringify([...schemaTables].sort()) === JSON.stringify([...readmeTables].sort()),
  `schema: ${schemaTables.join(',')} readme: ${readmeTables.join(',')}`);

check('the migration the README names exists',
  readme.includes('039-filament-forge.sql')
  && existsSync(join(repoRoot, 'db', 'migrations', '039-filament-forge.sql')));

{
  const endpoints = readdirSync(join(repoRoot, 'functions', 'api', 'filament-forge'))
    .filter((f) => f.endsWith('.js'));
  check('the API surface is exactly the two documented files',
    JSON.stringify(endpoints.sort()) === '["catalog.js","data.js"]');
  check('and both are named in the README',
    endpoints.every((f) => readme.includes(f)));
}

{
  const words = { fifty: 50, six: 6, seven: 7 };
  const cap = readme.match(/capped at (\w+) per user/);
  check('the README states the history cap', !!cap);
  check('and it matches the endpoint’s constant',
    cap && words[cap[1]] === MAX_HISTORY,
    cap ? `README says ${cap[1]}, endpoint says ${MAX_HISTORY}` : '');

  const printers = readme.match(/(\w+) Bambu Lab models are hardcoded/);
  const specCount = (appSrc.match(/^  '[a-z0-9-]+': \{ name: 'Bambu Lab /gm) || []).length;
  check('the README states the printer count', !!printers);
  check('and it matches PRINTER_SPECS',
    printers && words[printers[1].toLowerCase()] === specCount,
    printers ? `README says ${printers[1]}, app.js has ${specCount}` : '');
}

check('the refresh procedure is documented with its real command',
  readme.includes('node scripts/ofd-refresh.mjs --remote')
  && existsSync(join(repoRoot, 'scripts', 'ofd-refresh.mjs'))
  && existsSync(join(repoRoot, 'scripts', 'ofd-refresh-lib.mjs')));
check('the README says how to run this test',
  readme.includes('node apps/filament-forge/test/smoke.mjs'));

// ---------- 6. The two copies of the schema agree ----------
// The migration brings an existing database forward; the schema.sql CREATE is
// what a brand-new one gets. Both, every time — and nothing fails at the
// moment they diverge, so they are compared here.
section('Schema copies agree');

{
  const migration = readFileSync(join(repoRoot, 'db', 'migrations', '039-filament-forge.sql'), 'utf8');
  const tableBody = (src, name) => {
    const m = src.match(new RegExp('CREATE TABLE IF NOT EXISTS ' + name + ' \\(([\\s\\S]*?)\\n\\);'));
    if (!m) return null;
    // Column names only: first word of each line that starts one.
    return m[1].split('\n')
      .map((l) => (l.trim().match(/^([a-z_]+)/) || [])[1])
      .filter((w) => w && w !== 'PRIMARY');
  };
  for (const t of schemaTables) {
    const a = tableBody(schema, t);
    const b = tableBody(migration, t);
    check(`${t} has the same columns in schema.sql and the migration`,
      a && b && JSON.stringify(a) === JSON.stringify(b),
      `schema: ${a ? a.join(',') : 'MISSING'} migration: ${b ? b.join(',') : 'MISSING'}`);
  }
  check('the filament brand index exists in both',
    schema.includes('idx_ff_filaments_brand') && migration.includes('idx_ff_filaments_brand'));
}

process.exit(summary() === 0 ? 0 : 1);
