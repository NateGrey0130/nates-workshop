// A data script's read-back assertions, and the two places they are enforced.
//
// A data script ends in SELECTs that read its own work back. The ones shaped
//
//   SELECT 'the six vessels' AS assertion, count(*) AS got, 6 AS want FROM ...
//
// are ASSERTIONS: a row whose `got` differs from its `want` means the script
// did not do what its author read off the page. Until 2026-09-16 d1-apply.mjs
// printed those rows and carried on, so a failed assertion was caught only by
// a person reading the output - three wrong claims in one import were caught
// that way and one was not (`mystic-russia-survey`). Now they are enforced
// twice:
//
//   1. BEFORE anything is applied, by replaying the data directory into
//      node's own SQLite - the same replay `rebuild-local.mjs` does, about
//      twenty seconds - and evaluating each given file's assertions right
//      after that file, at ITS position in the order. Position matters: the
//      readbacks assert global counts that later files change on purpose
//      (`operations.md` -> the z-tier table), so evaluating at the end state
//      would fail scripts that are correct.
//   2. AFTER each real apply, over `--command --json` on the target, where a
//      mismatch stops the run before the next file.
//
// The replay is Node's SQLite, not workerd's. Checked 2026-08-28 row for row
// across the catalog tables: identical except `datetime('now')`. A file that
// is not under the data directory - a migration, `db/schema.sql` - is not
// replayed, because `schema.sql` already carries every migration and applying
// one twice fails on the duplicate column; those files get enforcement 2 only.
import { DatabaseSync } from 'node:sqlite';
import { readdirSync, readFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import { statementsKeepingTriggers, trailingSelects } from './sql-statements.mjs';

/**
 * The assertion rows in a result set whose got differs from want.
 * Column names are matched case-insensitively; a row without all three
 * columns is not an assertion and is ignored. Values are compared as strings
 * because wrangler returns `6` and node:sqlite returns `6` too, but a script
 * may write `want` as '6' or 6 and mean the same thing.
 */
export function assertionMismatches(rows) {
  const out = [];
  for (const row of rows || []) {
    if (!row || typeof row !== 'object') continue;
    const keys = Object.keys(row);
    const k = (name) => keys.find((x) => x.toLowerCase() === name);
    const a = k('assertion'), g = k('got'), w = k('want');
    if (!a || !g || !w) continue;
    if (String(row[g]) !== String(row[w])) {
      out.push({ assertion: String(row[a]), got: row[g], want: row[w] });
    }
  }
  return out;
}

/**
 * Replay the data directory into an in-memory SQLite and evaluate the given
 * files' trailing SELECTs at their own position. Returns
 *   { checked: [path...], skipped: [path...], failures: [{file, kind, detail}] }
 * kind is 'statement' (a given file's own SQL failed in the replay) or
 * 'assertion' (got != want). Failures in files that were NOT given are
 * tolerated and counted, the way rebuild-local.mjs tolerates them, so a broken
 * unrelated file does not block an apply - but the count is reported, because
 * a replay that failed early is a replay whose state you should not trust.
 */
export function preflightReadbacks(files, { repoRoot, log = () => {} }) {
  const dataDir = resolve(join(repoRoot, 'apps', 'character-creator', 'db'));
  const given = new Map();
  const skipped = [];
  for (const f of files) {
    const abs = resolve(f);
    if (resolve(join(abs, '..')) === dataDir) given.set(basename(abs), f);
    else skipped.push(f);
  }
  const result = { checked: [], skipped, failures: [], tolerated: 0 };
  if (!given.size) return result;

  const plan = [join(repoRoot, 'db', 'schema.sql'), join(repoRoot, 'db', 'seed-catalogs.sql')];
  const names = readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort();
  let last = -1;
  names.forEach((n, i) => { if (given.has(n)) last = i; });
  for (const n of names.slice(0, last + 1)) {
    const sql = readFileSync(join(dataDir, n), 'utf8');
    // The same marker d1-apply.mjs and rebuild-local.mjs honour.
    if (/^--\s*local-only\b/m.test(sql)) continue;
    plan.push(join(dataDir, n));
  }

  const db = new DatabaseSync(':memory:');
  try {
    for (const path of plan) {
      const name = basename(path);
      const sql = readFileSync(path, 'utf8');
      const isGiven = given.has(name);
      let i = 0;
      const stmts = statementsKeepingTriggers(sql);
      try {
        for (const s of stmts) { i++; db.exec(s); }
      } catch (e) {
        if (isGiven) {
          result.failures.push({ file: given.get(name), kind: 'statement',
            detail: `statement ${i}/${stmts.length} failed in the replay: ${e.message}` });
          continue;
        }
        result.tolerated++;
        log(`  (replay: ${name} statement ${i}/${stmts.length} failed - tolerated, not a given file)`);
        continue;
      }
      if (!isGiven) continue;
      result.checked.push(given.get(name));
      for (const sel of trailingSelects(sql)) {
        let rows;
        try { rows = db.prepare(sel.replace(/;$/, '')).all(); }
        catch (e) {
          result.failures.push({ file: given.get(name), kind: 'statement',
            detail: `read-back would not run in the replay: ${e.message} -- ${sel.slice(0, 100)}` });
          continue;
        }
        for (const m of assertionMismatches(rows)) {
          result.failures.push({ file: given.get(name), kind: 'assertion',
            detail: `${JSON.stringify(m.assertion)}: got ${JSON.stringify(m.got)}, want ${JSON.stringify(m.want)}` });
        }
      }
    }
  } finally {
    db.close();
  }
  return result;
}
