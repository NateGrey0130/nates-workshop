// One ad-hoc question to D1, from a shell.
//
//   node scripts/q.mjs --local  "SELECT name, level FROM spells WHERE level = 9"
//   node scripts/q.mjs --remote "SELECT count(*) FROM imported_classes"
//   node scripts/q.mjs --remote --batch checks.sql
//
// THE TARGET IS EXPLICIT. Until 2026-09-16 a missing flag meant --remote, the
// convention every other script here still follows through targetFromArgv() -
// and a "local readback" typed without --local read PRODUCTION and reported a
// freshly applied local change as missing (2026-09-11). Now a missing flag is
// a usage error, exit 2, before wrangler is spawned.
//
// Exists because the alternative kept being a throwaway `node -e` with a
// dynamic import in it, and those get the quoting wrong on Windows in a
// different way each time. Read-only by convention, not by enforcement - it
// runs whatever it is given, so do not point it at an UPDATE you have not
// thought about.
//
// ONE STATEMENT, ONE LINE. `wrangler d1 execute --command` truncates its
// argument at the first newline and reports the rest as `incomplete input`,
// which reads like malformed SQL rather than a mangled argument.
//
// --batch <file> is the exception that keeps the rule: the file may hold many
// statements across many lines, because batchStatements() splits and collapses
// each one to a single line before they are joined into ONE wrangler
// invocation. The verify-after-import volley of 5-10 SELECTs used to be 5-10
// separate calls, each paying wrangler's start-up; a batch pays that cost
// once. No figure here on purpose: it has moved with every wrangler release
// (MACHINE-AUDIT M26). Results come back numbered, one block per statement,
// in order.
import { readFileSync } from 'node:fs';
import { d1Batch, d1Query, dbFromArgv } from './d1-query-lib.mjs';
import { batchStatements } from './sql-statements.mjs';

const USAGE = 'usage: node scripts/q.mjs (--local|--remote) "<one SQL statement>"\n'
  + '       node scripts/q.mjs (--local|--remote) --batch <file.sql>\n'
  + '       the target is required: there is no default database.\n'
  + '       --db <palladium|marvel|tools> picks that group\'s database (default palladium).';

// --db <palladium|marvel|tools>, default palladium (d1-query-lib.mjs).
const { binding: db, rest: args } = dbFromArgv(process.argv.slice(2));
const batchAt = args.indexOf('--batch');
const target = args.includes('--local') ? '--local' : args.includes('--remote') ? '--remote' : null;
if (!target) {
  console.error(USAGE);
  process.exit(2);
}

if (batchAt !== -1) {
  const file = args[batchAt + 1];
  if (!file || file.startsWith('--')) {
    console.error('usage: node scripts/q.mjs [--local|--remote] --batch <file.sql>');
    process.exit(2);
  }
  const stmts = batchStatements(readFileSync(file, 'utf8'));
  if (!stmts.length) {
    console.error(`q.mjs --batch: no statements in ${file}`);
    process.exit(2);
  }
  const blocks = d1Batch(stmts, { target, db });
  if (blocks.length !== stmts.length) {
    // Should not happen — wrangler returns one block per statement — but if it
    // ever does, pairing silently by index would caption results with the
    // wrong SQL, which is worse than a mismatch notice.
    console.error(`q.mjs --batch: ${stmts.length} statements but ${blocks.length} result blocks; pairing by order as far as it goes`);
  }
  stmts.forEach((s, i) => {
    console.log(`-- [${i + 1}] ${s}`);
    console.log(JSON.stringify(blocks[i]?.results ?? null, null, 1));
  });
} else {
  const sql = args.filter((a) => !a.startsWith('--')).join(' ');
  if (!sql) {
    console.error('usage: node scripts/q.mjs [--local|--remote] "<one SQL statement>"\n'
      + '       node scripts/q.mjs [--local|--remote] --batch <file.sql>');
    process.exit(2);
  }
  console.log(JSON.stringify(d1Query(sql, { target, db }), null, 1));
}
