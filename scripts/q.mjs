// One ad-hoc question to D1, from a shell.
//
//   node scripts/q.mjs --local "SELECT name, level FROM spells WHERE level = 9"
//   node scripts/q.mjs "SELECT count(*) FROM imported_classes"   (--remote)
//   node scripts/q.mjs --batch checks.sql                        (--remote)
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
// separate calls at ~11s of wrangler start-up each; a batch pays that cost
// once. Results come back numbered, one block per statement, in order.
import { readFileSync } from 'node:fs';
import { d1Batch, d1Query, targetFromArgv } from './d1-query-lib.mjs';
import { batchStatements } from './sql-statements.mjs';

const args = process.argv.slice(2);
const batchAt = args.indexOf('--batch');

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
  const blocks = d1Batch(stmts, { target: targetFromArgv() });
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
  console.log(JSON.stringify(d1Query(sql, { target: targetFromArgv() }), null, 1));
}
