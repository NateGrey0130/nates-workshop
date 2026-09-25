#!/usr/bin/env node
// Which of two conflicting catalog inserts won, and does it matter?
//
//   node scripts/insert-conflicts.mjs --build <file.sqlite>           against a clean build
//   node scripts/insert-conflicts.mjs --build <file.sqlite> --remote  and production
//
// Build the file first with `node scripts/rebuild-local.mjs <file.sqlite>`
// (about a minute). Read-only: it reads the data scripts, that file and, with
// --remote, production.
//
// smoke's "Catalog rows inserted by two scripts" (checks/catalog-data.mjs)
// fails on a NEW key two data scripts insert with different values, and carries
// a baseline of the keys that already did. This says what each baselined key
// cost. For every conflicting key it replays the inserts in filename order
// (plain and OR IGNORE keep the first row; OR REPLACE takes the new one), then
// compares the winner's values on the columns the inserts disagree about with
// the row a clean build ends with and, with --remote, with production.
//
//   resolved   a later statement changed those columns after the insert, so
//              the losing insert's values never mattered
//   harmless   the winner stands and is a real row, and the loser differed only
//              in ways a later reader would not miss (usually its citation)
//   wrong      the winner is a STUB and a losing insert carried a full row
//   drift      the clean build and production disagree on those columns
//
// `harmless` is the one label that is a judgement, not a measurement: it is
// what is left when the other three do not apply. Read the losing values it
// prints before agreeing with it.

import { DatabaseSync } from 'node:sqlite';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { CATALOG_KEYS, catalogInserts, conflictingInserts } from './catalog-inserts-lib.mjs';
import { d1Query, repoRoot } from './d1-query-lib.mjs';

const args = process.argv.slice(2);
const bi = args.indexOf('--build');
if (bi === -1 || !args[bi + 1]) {
  console.error('usage: node scripts/insert-conflicts.mjs --build <file.sqlite> [--remote]');
  process.exit(1);
}
const db = new DatabaseSync(args[bi + 1], { readOnly: true });
const remote = args.includes('--remote');

const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
const files = readdirSync(dataDir).filter((f) => f.endsWith('.sql')).sort()
  .map((name) => ({ name, sql: readFileSync(join(dataDir, name), 'utf8') }));
const inserts = catalogInserts(files);
const conflicts = conflictingInserts(inserts);

// Text as the insert parser returns it: strings unquoted, NULL as the word.
const asText = (v) => (v === null || v === undefined ? 'NULL' : String(v));
const isStub = (row) => /^STUB\b/.test(asText(row?.description));

function rowFrom(source, table, keyCols, keyVals) {
  const where = keyCols.map((c, i) => `${c} = '${keyVals[i].replace(/'/g, "''")}'`).join(' AND ');
  const sql = `SELECT * FROM ${table} WHERE ${where}`;
  return source === 'build' ? db.prepare(sql).get() : d1Query(sql, { target: '--remote' })[0];
}

const out = [];
for (const c of conflicts) {
  const [table, ...keyVals] = c.key.split('|');
  const keyCols = CATALOG_KEYS[table];
  // Replay in filename order.
  let winner = null;
  const losers = [];
  for (const ins of inserts[c.key]) {
    if (!winner) { winner = ins; continue; }
    if (ins.mode === 'replace') { losers.push(winner); winner = ins; } else losers.push(ins);
  }
  const built = rowFrom('build', table, keyCols, keyVals);
  const prod = remote ? rowFrom('remote', table, keyCols, keyVals) : null;
  const changedLater = c.columns.some((col) => built && asText(built[col]) !== winner.values[col]);
  const drift = remote && c.columns.some((col) => asText(built?.[col]) !== asText(prod?.[col]));
  const stubWon = isStub(winner.values) && losers.some((l) => l.values.description && !isStub(l.values));
  const label = drift ? 'drift' : changedLater ? 'resolved' : stubWon ? 'wrong' : 'harmless';
  out.push({ key: c.key, label, columns: c.columns, winner, losers });
}

for (const label of ['wrong', 'drift', 'resolved', 'harmless']) {
  const group = out.filter((o) => o.label === label);
  if (!group.length) continue;
  console.log(`\n${label.toUpperCase()} (${group.length})`);
  for (const o of group) {
    console.log(`  ${o.key}   differs in: ${o.columns.join(', ')}`);
    console.log(`    kept   ${o.winner.file} (${o.winner.mode})`);
    for (const l of o.losers) {
      const diff = o.columns.filter((col) => col in l.values && l.values[col] !== o.winner.values[col])
        .map((col) => `${col}=${JSON.stringify(l.values[col]).slice(0, 70)}`).join('; ');
      console.log(`    lost   ${l.file} (${l.mode})${diff ? '  ' + diff : ''}`);
    }
  }
}
console.log(`\n${out.length} conflicting keys: `
  + ['wrong', 'drift', 'resolved', 'harmless'].map((l) => `${out.filter((o) => o.label === l).length} ${l}`).join(', ')
  + (remote ? '' : '  (drift not checked: add --remote)'));
