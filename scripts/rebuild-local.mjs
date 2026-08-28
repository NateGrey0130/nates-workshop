// Build a database from the repo in seconds, one file at a time.
//
//   node scripts/rebuild-local.mjs out.sqlite
//   node scripts/rebuild-local.mjs out.sqlite --include-local-only
//   node scripts/rebuild-local.mjs out.sqlite --stop-at-first-failure
//   node scripts/rebuild-local.mjs out.sqlite --stop-before zzzz-cite-rue-rows.sql
//
// A DEVELOPMENT TOOL. `repo-vs-live.mjs` is the authority on whether the repo
// rebuilds the catalog, and `test/regression.mjs` is the authority on whether
// a rebuilt database serves requests. Nothing should start depending on this:
// no test imports it, and it is not part of any gate.
//
// WHY IT EXISTS. `d1-apply.mjs --local db/*.sql` spawns one wrangler per file
// and there are 295 of them - well over an hour. The alternative everything
// else here uses is to concatenate the lot into one bootstrap and hand it to
// wrangler once, which is minutes but gives up the thing that makes a rebuild
// legible: WHICH FILE did that. This keeps both. It replays the same files in
// the same order into node's own SQLite, in-process, and it takes about twenty
// seconds.
//
// That speed is not a nicety. An hour per rebuild is why the zzzz- rename
// shipped unverified and why three occurrences of the filename-ordering bug
// were found by accident rather than by looking.
//
// TWO HONEST CAVEATS.
//
//   1. This is Node's SQLite, not workerd's. It is not the same engine D1 runs.
//      Checked rather than assumed on 2026-08-28: a build from this and a build
//      from `wrangler d1 execute --file` over the same file list were compared
//      row for row across all seven catalog tables and differed in NOTHING but
//      `datetime('now')` timestamps. Re-check it if a finding rests on the
//      difference.
//
//   2. `sql-statements.mjs` splits on every top-level semicolon, which is right
//      for the data scripts and wrong for `schema.sql`: a CREATE TRIGGER body
//      holds its own semicolons between BEGIN and END. They are re-joined
//      below. `wrangler --file` does not have this problem, which is the other
//      reason it stays the authority.
//
// It never touches `.wrangler/state`. The output is a plain .sqlite file
// wherever you point it, so the WAL-restore hazard that comes with backing up
// the dev database does not arise.
import { DatabaseSync } from 'node:sqlite';
import { readdirSync, readFileSync, rmSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { statements } from './sql-statements.mjs';

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');
const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');

const args = process.argv.slice(2);
const out = args.find((a) => !a.startsWith('--'));
const includeLocalOnly = args.includes('--include-local-only');
const stopAtFirst = args.includes('--stop-at-first-failure');
const stopBefore = (() => {
  const i = args.indexOf('--stop-before');
  return i === -1 ? null : args[i + 1];
})();

if (!out) {
  console.error('usage: node scripts/rebuild-local.mjs <out.sqlite> [flags]');
  process.exit(1);
}
// The -wal and -shm siblings too: a stale WAL next to a fresh .sqlite replays
// the PREVIOUS build's writes over it, which is the exact way a dev database
// was lost once.
for (const suffix of ['', '-wal', '-shm']) {
  if (existsSync(out + suffix)) rmSync(out + suffix);
}

// See caveat 2. A trigger's body is re-joined onto its CREATE.
function splitSql(sql) {
  const parts = [];
  let pending = null;
  for (const stmt of statements(sql)) {
    pending = pending === null ? stmt : pending + ';\n' + stmt;
    if (!/\bcreate\s+trigger\b/i.test(pending) || /\bend\s*$/i.test(pending)) {
      parts.push(pending);
      pending = null;
    }
  }
  if (pending !== null) parts.push(pending);
  return parts;
}

const plan = [join(repoRoot, 'db', 'schema.sql'), join(repoRoot, 'db', 'seed-catalogs.sql')];
for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
  if (stopBefore && f === stopBefore) break;
  const sql = readFileSync(join(dataDir, f), 'utf8');
  // The same marker d1-apply.mjs honours, and for the same second reason:
  // seed-dev.sql's unguarded inserts fail on the FIRST pass from empty, and
  // stopping there would strand every zz-, zzz- and zzzz- correction.
  if (!includeLocalOnly && /^--\s*local-only\b/m.test(sql)) {
    console.log(`skip ${f} - marked local-only`);
    continue;
  }
  plan.push(join(dataDir, f));
}

const db = new DatabaseSync(out);
const failures = [];
let applied = 0;
let stmtCount = 0;

for (const path of plan) {
  const name = path.slice(Math.max(path.lastIndexOf('/'), path.lastIndexOf('\\')) + 1);
  const stmts = splitSql(readFileSync(path, 'utf8'));
  let i = 0;
  try {
    for (const s of stmts) { i++; db.exec(s); stmtCount++; }
    applied++;
  } catch (e) {
    failures.push({ name, at: i, of: stmts.length, error: e.message });
    console.log(`FAIL ${name} - statement ${i}/${stmts.length}: ${e.message}`);
    if (stopAtFirst) {
      const left = plan.length - plan.indexOf(path) - 1;
      console.log(`\nstopped at the first failure. ${left} file(s) after it never ran.`);
      break;
    }
  }
}
db.close();

console.log(`\n${out}: ${applied} file(s) applied, ${stmtCount} statement(s), `
  + `${failures.length} file(s) with a failure`);
for (const f of failures) console.log(`  ${f.name}  [${f.at}/${f.of}]  ${f.error}`);
// Advisory, like source-coverage.mjs: a development tool does not gate anything.
process.exit(0);
