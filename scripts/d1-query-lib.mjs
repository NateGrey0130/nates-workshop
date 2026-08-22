// One way to ask D1 a question from a script.
//
// `drift-check.mjs` and `catalog-diff.mjs` had grown byte-identical copies of
// this, down to the buffer size and the slice trick. Each line of it is load
// bearing and none of it is obvious, which is exactly the kind of thing that
// should exist once.
import { execSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const DB = 'nates-workshop-media';
export const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

/**
 * Run one SQL statement and return its rows.
 *
 * @param {string} sql   ONE statement, on ONE line. `wrangler d1 execute
 *                       --command` truncates its argument at the first newline
 *                       and reports the rest as `incomplete input:
 *                       SQLITE_ERROR`, which reads like malformed SQL rather
 *                       than a mangled argument. Use a file for anything
 *                       multi-line — see `sql-statements.mjs`.
 * @param {object} opts
 * @param {'--local'|'--remote'} opts.target  defaults to --remote
 */
export function d1Query(sql, { target = '--remote', db = DB } = {}) {
  const out = execSync(
    `npx wrangler d1 execute ${db} ${target} --json --command "${sql}"`,
    // maxBuffer: wrangler prints the whole result set, and the gear catalog
    // alone overruns the 1 MB default.
    // stdio: stderr is swallowed because wrangler writes its banner there on
    // every successful call, and inheriting it buries the script's own output.
    { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e9,
      stdio: ['ignore', 'pipe', 'ignore'] });
  // wrangler prefixes the JSON with a human banner, so the payload starts at
  // the first '['. Parsing `out` directly fails on every call.
  return JSON.parse(out.slice(out.indexOf('['))).flatMap((b) => b.results || []);
}

/** `--remote` unless `--local` was passed. The convention every script here uses. */
export function targetFromArgv(argv = process.argv) {
  return argv.includes('--local') ? '--local' : '--remote';
}
