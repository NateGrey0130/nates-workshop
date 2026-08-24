#!/usr/bin/env node
// Refresh FilamentForge's snapshot of the Open Filament Database.
//
//   node scripts/ofd-refresh.mjs --local
//   node scripts/ofd-refresh.mjs --remote
//
// Fetches OFD's brands and filaments CSVs, rewrites ff_brands/ff_filaments
// from them, and reads the counts back. The app itself never talks to OFD —
// /api/filament-forge/catalog serves this snapshot — so this script is the
// only place the third-party dependency lives, and an OFD outage costs a
// stale catalog rather than a broken app.
//
// - The target is EXPLICIT, like d1-apply.mjs: no default, because an
//   accidental --remote is the costly direction.
// - The fetched data is refused if it is implausibly small (an OFD outage or
//   format change must not replace a good snapshot with an empty one).
// - The generated SQL is pure-ASCII: brand names carry accents, and non-ASCII
//   through wrangler on Windows has produced mojibake in production (see
//   d1-apply.mjs), so every non-ASCII character is spliced in as char(N).
// - DELETE and INSERT run in one --file apply. Statements in a file are not
//   one transaction, so a failure mid-apply can leave the catalog partial —
//   acceptable here because re-running the script is the repair, and the app
//   says "catalog empty" rather than breaking.

import { spawnSync } from 'node:child_process';
import { writeFileSync, mkdtempSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { DB, d1Query } from './d1-query-lib.mjs';

const OFD = 'https://api.openfilamentdatabase.org/csv';
const MIN_BRANDS = 10;      // below these, assume OFD is broken and keep the
const MIN_FILAMENTS = 100;  // snapshot we already have
const ROWS_PER_INSERT = 100;

const FILAMENT_COLUMNS = [
  'id', 'brand_id', 'name', 'material', 'density', 'diameter_tolerance',
  'min_print_temperature', 'max_print_temperature', 'min_bed_temperature',
  'max_bed_temperature', 'max_dry_temperature', 'slicer_settings',
];

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const local = args.includes('--local');
if (remote === local) {
  console.error('Pass exactly one of --local or --remote.');
  process.exit(1);
}
const target = remote ? '--remote' : '--local';

// ── CSV parsing — the parser the app used when it fetched OFD itself ──

function parseCSVLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] === '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c === ',' && !inQuotes) {
      result.push(current);
      current = '';
    } else {
      current += c;
    }
  }
  result.push(current);
  return result;
}

function parseCSV(text) {
  const lines = text.replace(/\r/g, '').split('\n').filter((l) => l.trim());
  if (lines.length < 2) return [];
  const headers = parseCSVLine(lines[0]);
  const results = [];
  for (let i = 1; i < lines.length; i++) {
    const vals = parseCSVLine(lines[i]);
    if (vals.length < headers.length - 2) continue; // skip garbage lines
    const obj = {};
    headers.forEach((h, idx) => { obj[h] = vals[idx] || ''; });
    results.push(obj);
  }
  return results;
}

// ── SQL literals, ASCII-only ──

function sqlLit(value) {
  const s = String(value ?? '');
  let out = "'";
  for (const ch of s) {
    const code = ch.codePointAt(0);
    if (code < 32) continue;               // control chars have no business in a name
    if (ch === "'") out += "''";
    else if (code > 126) out += "'||char(" + code + ")||'";
    else out += ch;
  }
  return out + "'";
}

function insertChunks(table, columns, rows) {
  const statements = [];
  for (let i = 0; i < rows.length; i += ROWS_PER_INSERT) {
    const chunk = rows.slice(i, i + ROWS_PER_INSERT);
    const values = chunk.map((r) => '(' + columns.map((c) => sqlLit(r[c])).join(', ') + ')');
    statements.push(`INSERT INTO ${table} (${columns.join(', ')}) VALUES\n${values.join(',\n')};`);
  }
  return statements;
}

// ── the same npx resolution d1-apply.mjs uses (Windows .cmd spawning) ──
const npxCli = path.join(path.dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
function run(cliArgs) {
  const r = existsSync(npxCli)
    ? spawnSync(process.execPath, [npxCli, ...cliArgs], { encoding: 'utf8', maxBuffer: 1e9 })
    : spawnSync('npx', cliArgs, { encoding: 'utf8', shell: true, maxBuffer: 1e9 });
  return { code: r.status ?? 1, out: (r.stdout || '') + (r.stderr || '') };
}

// ── fetch, refuse garbage, generate, apply, verify ──

console.log('fetching OFD CSVs…');
const [brandsRes, filamentsRes] = await Promise.all([
  fetch(`${OFD}/brands.csv`),
  fetch(`${OFD}/filaments.csv`),
]);
if (!brandsRes.ok || !filamentsRes.ok) {
  console.error(`OFD fetch failed: brands ${brandsRes.status}, filaments ${filamentsRes.status}`);
  process.exit(1);
}

// Dedupe by id: the tables key on it, and a duplicate CSV line must not fail
// the whole apply.
const brands = [...new Map(parseCSV(await brandsRes.text())
  .filter((b) => b.id).map((b) => [b.id, b])).values()];
const filaments = [...new Map(parseCSV(await filamentsRes.text())
  .filter((f) => f.id).map((f) => [f.id, f])).values()];

console.log(`fetched ${brands.length} brands, ${filaments.length} filaments`);
if (brands.length < MIN_BRANDS || filaments.length < MIN_FILAMENTS) {
  console.error(`Implausibly small (need >= ${MIN_BRANDS} brands and >= ${MIN_FILAMENTS} filaments) — refusing to replace the snapshot.`);
  process.exit(1);
}

const fetchedAt = new Date().toISOString();
for (const b of brands) b.fetched_at = fetchedAt;
for (const f of filaments) f.fetched_at = fetchedAt;

const sql = [
  '-- Generated by scripts/ofd-refresh.mjs — do not commit.',
  'DELETE FROM ff_filaments;',
  'DELETE FROM ff_brands;',
  ...insertChunks('ff_brands', ['id', 'name', 'fetched_at'], brands),
  ...insertChunks('ff_filaments', [...FILAMENT_COLUMNS, 'fetched_at'], filaments),
].join('\n') + '\n';

const file = path.join(mkdtempSync(path.join(tmpdir(), 'ofd-refresh-')), 'snapshot.sql');
writeFileSync(file, sql);

console.log(`applying to ${target}…`);
const r = run(['wrangler', 'd1', 'execute', DB, target, '--file', file]);
if (r.code !== 0) {
  console.error('wrangler exited non-zero — verifying anyway, exit codes here are advisory:');
  console.error(r.out.slice(-2000));
}

// Exit codes are advisory in this repo; the counts are the truth.
const [check] = d1Query(
  'SELECT (SELECT COUNT(*) FROM ff_brands) AS brands, (SELECT COUNT(*) FROM ff_filaments) AS filaments, (SELECT MAX(fetched_at) FROM ff_filaments) AS fetched_at',
  { target });
console.log(`${target} now holds ${check.brands} brands, ${check.filaments} filaments (fetched_at ${check.fetched_at})`);
if (check.brands !== brands.length || check.filaments !== filaments.length) {
  console.error('MISMATCH between what was fetched and what the database holds — re-run this script.');
  process.exit(1);
}
console.log('ok');
