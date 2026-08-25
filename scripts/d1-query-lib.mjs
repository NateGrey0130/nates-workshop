// One way to ask D1 a question from a script.
//
// `drift-check.mjs` and `catalog-diff.mjs` had grown byte-identical copies of
// this, down to the buffer size and the slice trick. Each line of it is load
// bearing and none of it is obvious, which is exactly the kind of thing that
// should exist once.
import { execSync, spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
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

/**
 * Several statements, ONE wrangler invocation. Takes statements already
 * single-line and semicolon-terminated (sql-statements.mjs `batchStatements()`
 * produces exactly that) and returns wrangler's result blocks — one per
 * statement, in order. Not d1Query(), which flattens the blocks together; a
 * batch exists to keep them apart.
 *
 * NOT --file, though a file is the obvious container for many statements: over
 * --remote, --file goes to D1's IMPORT endpoint, which returns aggregate
 * counts and swallows every result set (see d1-apply.mjs, which replays
 * trailing SELECTs for exactly this reason). --command returns rows on both
 * targets.
 *
 * Runs WITHOUT a shell — npm's own npx-cli.js under this Node, the same form
 * d1-apply.mjs uses and for the same two reasons: Windows npx is a .cmd that
 * Node refuses to spawn unshelled, and a shell string cannot carry an embedded
 * double quote. That last one matters here: class markdown cites gear as
 * `item_id: "slug"`, so the verification queries most worth batching are the
 * ones a shelled --command breaks on. A real argv array makes them legal.
 */
export function d1Batch(stmts, { target = '--remote', db = DB } = {}) {
  const args = ['wrangler', 'd1', 'execute', db, target, '--json', '--command', stmts.join(' ')];
  const npxCli = join(dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
  const r = existsSync(npxCli)
    ? spawnSync(process.execPath, [npxCli, ...args],
        { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e9 })
    : spawnSync('npx', args, { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e9, shell: true });
  if (r.status !== 0) {
    throw new Error('wrangler d1 execute failed:\n'
      + ((r.stderr || '') + (r.stdout || '')).slice(-2000));
  }
  // Same banner-skip as d1Query: the JSON payload starts at the first '['.
  const out = r.stdout || '';
  return JSON.parse(out.slice(out.indexOf('[')));
}

/** `--remote` unless `--local` was passed. The convention every script here uses. */
export function targetFromArgv(argv = process.argv) {
  return argv.includes('--local') ? '--local' : '--remote';
}
