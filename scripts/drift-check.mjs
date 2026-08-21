// Does the live database match the repo?
//
//   node scripts/drift-check.mjs --remote
//   node scripts/drift-check.mjs --local
//
// The smoke test proves the repo is internally consistent - schema.sql agrees
// with the migrations, the README agrees with both. The regression test proves
// a database built FROM the repo works. Neither can see the live database, and
// the gap between them is where the expensive mistakes live: a migration
// written and never applied, a data script run locally and forgotten remotely,
// a class that exists only because someone imported it through the UI.
//
// Five comparisons:
//   1. every migration file vs schema_migrations
//   2. every data script vs data_script_runs
//   3. every table in schema.sql vs sqlite_master
//   4. every column in schema.sql vs the live CREATE text
//   5. every published class vs one a data script can recreate
//
// Read-only. It writes nothing, so it is safe to point at production.
//
// TWO THINGS THAT COST AN HOUR THE FIRST TIME:
//   * `--file` over `--remote` returns a SUMMARY row ("Total queries executed")
//     instead of the query results, so every count came back as 1. Use
//     `--command`.
//   * execFileSync with shell:true does not quote the arguments it joins, so
//     the SQL lost its spaces; without a shell Node refuses to spawn npx.cmd on
//     Windows at all. So: one command string, quoting the SQL here. Every query
//     below uses single quotes internally, which keeps the double quotes safe.
//
// sqlite_master and the two tracking tables are authoritative. pragma_table_info
// is not over --remote - it has returned stale replica data mid-migration - so
// columns are read out of sqlite_master's stored CREATE text.
import { execSync } from 'node:child_process';
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const target = process.argv.includes('--local') ? '--local' : '--remote';
const DB = 'nates-workshop-media';

function d1(sql) {
  const out = execSync(
    `npx wrangler d1 execute ${DB} ${target} --json --command "${sql}"`,
    { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e9, stdio: ['ignore', 'pipe', 'ignore'] });
  return JSON.parse(out.slice(out.indexOf('['))).flatMap((b) => b.results || []);
}

const problems = [];
const note = (kind, msg) => problems.push(`${kind}: ${msg}`);

// ── 1. migrations ───────────────────────────────────────────────────────────
const migDir = join(repoRoot, 'db', 'migrations');
const migFiles = readdirSync(migDir).filter((f) => f.endsWith('.sql')).sort();
const migRows = new Set(d1('SELECT filename FROM schema_migrations').map((r) => r.filename));
console.log(`migrations:   ${migFiles.length} files, ${migRows.size} recorded`);
for (const f of migFiles) if (!migRows.has(f)) note('MIGRATION NOT APPLIED', f);
for (const f of migRows) if (!migFiles.includes(f)) note('RECORDED BUT NO FILE', f);

// ── 2. data scripts ─────────────────────────────────────────────────────────
const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
const allFiles = readdirSync(dataDir).filter((f) => f.endsWith('.sql')).sort();
// seed-dev carries the local-only marker and must never run remotely.
const dataFiles = allFiles.filter(
  (f) => !/^--\s*local-only\b/m.test(readFileSync(join(dataDir, f), 'utf8')));
const dataRows = new Set(d1('SELECT filename FROM data_script_runs').map((r) => r.filename));
console.log(`data scripts: ${dataFiles.length} files, ${dataRows.size} recorded`);
for (const f of dataFiles) if (!dataRows.has(f)) note('DATA SCRIPT NOT RUN', f);
for (const f of dataRows) if (!allFiles.includes(f)) note('RUN BUT NO FILE', f);
for (const f of dataRows) {
  if (allFiles.includes(f) && !dataFiles.includes(f)) {
    note('LOCAL-ONLY SCRIPT RECORDED AS RUN', `${f} — it must never run remotely`);
  }
}

// ── 3 & 4. tables and columns ───────────────────────────────────────────────
const schemaSql = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
const declared = new Map();
for (const m of schemaSql.matchAll(/CREATE TABLE (?:IF NOT EXISTS )?([A-Za-z_]\w*)\s*\(([\s\S]*?)\n\);/g)) {
  const cols = m[2].split('\n')
    .map((l) => l.replace(/--.*$/, '').trim())
    .filter((l) => l && !/^(PRIMARY KEY|FOREIGN KEY|UNIQUE|CHECK|CONSTRAINT)\b/i.test(l))
    .map((l) => (l.match(/^([A-Za-z_]\w*)/) || [])[1])
    .filter(Boolean);
  declared.set(m[1], new Set(cols));
}
const live = d1("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf%'");
const liveByName = new Map(live.filter((r) => r.name).map((r) => [r.name, r.sql || '']));
console.log(`tables:       ${declared.size} in schema.sql, ${liveByName.size} live`);

for (const [name, cols] of declared) {
  const sql = liveByName.get(name);
  if (sql === undefined) { note('TABLE MISSING LIVE', name); continue; }
  for (const c of cols) {
    if (!new RegExp(`[(,\\s]${c}\\s`, 'i').test(sql)) note('COLUMN MISSING LIVE', `${name}.${c}`);
  }
}
// FTS5 shadow tables are created by the virtual table, not declared in full.
const shadow = /_fts$|_fts_(data|idx|content|docsize|config)$/;
for (const name of liveByName.keys()) {
  if (!declared.has(name) && !shadow.test(name)
      && !['schema_migrations', 'data_script_runs'].includes(name)) {
    note('LIVE TABLE NOT IN schema.sql', name);
  }
}

// ── 5. class provenance ─────────────────────────────────────────────────────
// A published class no data script creates is one a fresh environment comes up
// WITHOUT, and one that exists in exactly one place. chiang-ku-dragon and juicer
// were both in that state until a drift check found them.
const published = d1("SELECT class_id FROM imported_classes WHERE deleted_at IS NULL AND status = 'published'")
  .map((r) => r.class_id).filter(Boolean);
const creators = new Set();
// Three INSERT shapes and two directories, all of them in use:
//   INSERT INTO ... VALUES ('id',            - the older class scripts
//   INSERT OR IGNORE INTO ... VALUES ('id',  - add-godling-class.sql
//   INSERT INTO ... SELECT 'id', ...         - the newer guarded form
// and the three oldest classes are seeded from db/seed-catalogs.sql rather than
// from apps/character-creator/db at all. Matching one shape in one directory
// reported eighteen false positives; matching two reported four.
const CREATE_RE = /INSERT (?:OR IGNORE )?INTO imported_classes[\s\S]{0,400}?(?:VALUES\s*\(|SELECT\s+)'([a-z0-9-]+)'/g;
const sources = [
  ...allFiles.map((f) => join(dataDir, f)),
  join(repoRoot, 'db', 'seed-catalogs.sql'),
];
for (const path of sources) {
  const sql = readFileSync(path, 'utf8');
  for (const m of sql.matchAll(CREATE_RE)) creators.add(m[1]);
}
console.log(`classes:      ${published.length} published live, ${creators.size} creatable from the repo`);
for (const c of published) {
  if (!creators.has(c)) note('CLASS NOT REPRODUCIBLE', `${c} — no data script creates it`);
}

// ── verdict ─────────────────────────────────────────────────────────────────
console.log('');
if (!problems.length) {
  console.log(`NO DRIFT (${target})`);
  process.exit(0);
}
console.log(`DRIFT FOUND (${target}): ${problems.length}`);
for (const p of problems) console.log('  ' + p);
process.exit(1);
