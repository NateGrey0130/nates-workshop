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
// - DELETE and INSERT run in one --file apply. Statements in a file are not
//   one transaction, so a failure mid-apply can leave the catalog partial —
//   acceptable here because re-running the script is the repair, and the app
//   says "catalog empty" rather than breaking.
//
// The deterministic parts — CSV parsing, the ASCII-only SQL, the chunking —
// live in ofd-refresh-lib.mjs so the FilamentForge smoke test can run them.

import { spawnSync } from 'node:child_process';
import { writeFileSync, mkdtempSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { DB, d1Query } from './d1-query-lib.mjs';
import { MIN_BRANDS, MIN_FILAMENTS, parseCSV, dedupeById, buildSnapshotSql } from './ofd-refresh-lib.mjs';

const OFD = 'https://api.openfilamentdatabase.org/csv';

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const local = args.includes('--local');
if (remote === local) {
  console.error('Pass exactly one of --local or --remote.');
  process.exit(1);
}
const target = remote ? '--remote' : '--local';

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

const brands = dedupeById(parseCSV(await brandsRes.text()));
const filaments = dedupeById(parseCSV(await filamentsRes.text()));

console.log(`fetched ${brands.length} brands, ${filaments.length} filaments`);
if (brands.length < MIN_BRANDS || filaments.length < MIN_FILAMENTS) {
  console.error(`Implausibly small (need >= ${MIN_BRANDS} brands and >= ${MIN_FILAMENTS} filaments) — refusing to replace the snapshot.`);
  process.exit(1);
}

const sql = buildSnapshotSql(brands, filaments, new Date().toISOString());
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
