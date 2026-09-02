// A copy of the live database, on disk, that survives losing the Cloudflare
// account.
//
//   node scripts/d1-backup.mjs backups/2026-09-02
//   node scripts/d1-backup.mjs /tmp/scratch --local
//
// D1 Time Travel is the recovery mechanism for this database and it is a
// ROLLING 30 days, held by Cloudflare, in the same account as the data it
// protects. See operations.md -> Recovery. This script is the other half: the
// copy you hold yourself.
//
// IT EXISTS BECAUSE `wrangler d1 export` DOES NOT RUN HERE. The obvious command
// fails outright on this database:
//
//   D1 Export error: cannot export databases with Virtual Tables (fts5)
//
// `journal_fts` is that virtual table - campaign-note search, from
// 026-campaign-notes.sql. ONE fts5 table makes the WHOLE database
// un-exportable by that path and no flag skips it. Do not try to work around
// that by dropping and recreating journal_fts: a production mutation inside a
// recovery tool is the wrong shape entirely. Per-table SELECTs work, so this
// loops them.
//
// WHAT IT SKIPS, AND WHY IT DERIVES THE LIST RATHER THAN NAMING IT:
//
//   * virtual tables      - `CREATE VIRTUAL TABLE`. journal_fts is an INDEX of
//                           journal_entries, not a source of truth; the
//                           triggers in 026 rebuild it from that table.
//   * their shadow tables - journal_fts_data / _idx / _docsize / _config.
//                           Found by prefix off the virtual table's own name,
//                           so a second FTS table added later is covered
//                           without editing this file.
//   * _cf_* - Cloudflare's own bookkeeping, not ours to restore.
//
// Report-only in the sense the other checks here are: it gates nothing and
// schedules nothing. It DOES exit non-zero when a table fails to dump, which
// is not the same thing - a backup tool that reports success after writing
// half a database is a defect, not a posture.
//
// Manual on purpose. A scheduled export that quietly stops is worse than a
// documented one somebody runs, because the first kind is believed.
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { d1Query, targetFromArgv, DB } from './d1-query-lib.mjs';

const argv = process.argv.slice(2);
const outDir = argv.find((a) => !a.startsWith('--'));
if (!outDir) {
  console.error('usage: node scripts/d1-backup.mjs <out-dir> [--local|--remote]');
  process.exit(2);
}
const target = targetFromArgv(process.argv);

mkdirSync(outDir, { recursive: true });

// One statement, one line - d1Query's contract. Table names here are plain
// identifiers, so they need no quoting, which matters: wrangler is invoked
// through a shell string that cannot carry an embedded double quote.
const tables = d1Query(
  "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
  { target },
);

const virtual = tables
  .filter((t) => /^\s*CREATE\s+VIRTUAL\s+TABLE/i.test(t.sql || ''))
  .map((t) => t.name);

const skipped = [];
const wanted = [];
for (const { name } of tables) {
  if (name.startsWith('_cf_')) { skipped.push([name, 'Cloudflare internal']); continue; }
  if (virtual.includes(name)) { skipped.push([name, 'virtual table, rebuilt by triggers']); continue; }
  const parent = virtual.find((v) => name.startsWith(`${v}_`));
  if (parent) { skipped.push([name, `shadow table of ${parent}`]); continue; }
  wanted.push(name);
}

console.log(`\n${DB} ${target} -> ${outDir}\n`);

let total = 0;
const failed = [];
for (const name of wanted) {
  try {
    const rows = d1Query(`SELECT * FROM ${name}`, { target });
    const file = join(outDir, `${name}.json`);
    const text = JSON.stringify(rows, null, 2);
    writeFileSync(file, text, 'utf8');
    total += rows.length;
    // Row count AND bytes: an empty table and a table whose dump silently
    // truncated both look like a small number on their own.
    console.log(`  ${String(rows.length).padStart(6)} rows  ${String(text.length).padStart(9)} bytes  ${name}`);
  } catch (err) {
    failed.push(name);
    console.log(`  ${'FAILED'.padStart(6)}       ${'-'.padStart(9)}         ${name}`);
    console.log(`         ${String(err.message).split('\n')[0].slice(0, 140)}`);
  }
}

if (skipped.length) {
  console.log('\n  skipped, by derivation rather than by a list:');
  for (const [name, why] of skipped) console.log(`    ${name} - ${why}`);
}

console.log(`\n  ${wanted.length - failed.length} of ${wanted.length} tables, ${total} rows.`);

if (failed.length) {
  console.log(`  ${failed.length} FAILED: ${failed.join(', ')}`);
  console.log('  This backup is incomplete. Do not file it as one.\n');
  process.exit(1);
}
console.log('  Complete.\n');
