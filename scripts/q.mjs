// One ad-hoc question to D1, from a shell.
//
//   node scripts/q.mjs --local "SELECT name, level FROM spells WHERE level = 9"
//   node scripts/q.mjs "SELECT count(*) FROM imported_classes"   (--remote)
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
import { d1Query, targetFromArgv } from './d1-query-lib.mjs';

const sql = process.argv.slice(2).filter((a) => !a.startsWith('--')).join(' ');
if (!sql) {
  console.error('usage: node scripts/q.mjs [--local|--remote] "<one SQL statement>"');
  process.exit(2);
}
console.log(JSON.stringify(d1Query(sql, { target: targetFromArgv() }), null, 1));
