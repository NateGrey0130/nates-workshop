// One way to ask D1 a question from a script.
//
// `drift-check.mjs` and `catalog-diff.mjs` had grown byte-identical copies of
// this, down to the buffer size and the slice trick. Each line of it is load
// bearing and none of it is obvious, which is exactly the kind of thing that
// should exist once.
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const DB = 'nates-workshop-media';
export const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

// ONE D1 PER GROUP OF APPS (groups.json), by wrangler.jsonc binding. Palladium
// keeps `DB`, the database this repo has always had; Marvel and the tools get
// their own. A script that takes `--db <group>` resolves it here, and without
// the flag it means palladium, so every command typed before the split still
// reaches the database it always did. The map is each group's d1_binding in
// groups.json, which groups.mjs --check holds against wrangler.jsonc.
const DATABASES = Object.fromEntries(
  Object.entries(JSON.parse(readFileSync(join(repoRoot, 'groups.json'), 'utf8')).groups)
    .filter(([, g]) => g.d1_binding).map(([id, g]) => [id, g.d1_binding]));

/**
 * Every group database the repo can build, with the files that define it:
 * Palladium's is db/schema.sql and db/migrations/*.sql, as it always was; any
 * other group's exists once its tables have moved, as db/schema-<group>.sql
 * and db/migrations/<group>/*.sql. So a group is listed from the day its
 * schema file lands, and a builder or checker that walks this list picks it up
 * without being told.
 */
export function groupDatabases(root = repoRoot) {
  const out = [{ group: 'palladium', binding: DATABASES.palladium, schema: join('db', 'schema.sql'), migrations: join('db', 'migrations') }];
  for (const group of Object.keys(DATABASES)) {
    if (group === 'palladium' || !existsSync(join(root, 'db', `schema-${group}.sql`))) continue;
    out.push({ group, binding: DATABASES[group], schema: join('db', `schema-${group}.sql`), migrations: join('db', 'migrations', group) });
  }
  return out;
}

/**
 * `--db <group>` out of an argv: `{ group, binding, rest }`, where `rest` is
 * the argv without the flag and its value, so a caller that reads its
 * positional arguments (files, SQL) cannot mistake the group for one. Exits
 * with a message on an unknown group, and on a group whose binding is not in
 * wrangler.jsonc yet - wrangler's own error for that names neither.
 */
export function dbFromArgv(argv) {
  const i = argv.indexOf('--db');
  if (i === -1) return { group: 'palladium', binding: DATABASES.palladium, rest: argv };
  const group = argv[i + 1];
  const rest = [...argv.slice(0, i), ...argv.slice(i + 2)];
  if (!Object.hasOwn(DATABASES, group ?? '')) {
    console.error(`--db takes one of: ${Object.keys(DATABASES).join(', ')} (got ${group ?? 'nothing'})`);
    process.exit(2);
  }
  const binding = DATABASES[group];
  const config = readFileSync(join(repoRoot, 'wrangler.jsonc'), 'utf8');
  if (!new RegExp(`"binding"\\s*:\\s*"${binding}"`).test(config)) {
    console.error(`--db ${group}: wrangler.jsonc binds no D1 as ${binding} yet, so there is no ${group} database to reach`);
    process.exit(2);
  }
  return { group, binding, rest };
}

/**
 * The extra wrangler arguments that point a `--local` call at the local D1
 * named by `$WORKSHOP_LOCAL_D1` - `['--persist-to', <dir>]` - and nothing at
 * all for `--remote` or when the variable is unset. wrangler's default is
 * `.wrangler/state` under the cwd, which is this repo's root for every caller
 * here, so a session in the main checkout needs no variable. A git worktree
 * gets its own empty `.wrangler/state`, which is why the smoke suite's D1
 * sections failed there (`fresh-worktree-fails-two-checks`); pointing the
 * variable at the main checkout's `.wrangler\state` makes a worktree read the
 * same local database. The tests that build their own scratch database under
 * a temp `--persist-to` (regression.mjs, play-flow.mjs) do not use this and
 * must not: their isolation is the point.
 */
export function localD1Args(target) {
  const env = process.env.WORKSHOP_LOCAL_D1;
  if (target !== '--local' || !env || !env.trim()) return [];
  return ['--persist-to', resolve(env.trim())];
}

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
//
// WITHOUT A SHELL, for the reason d1Batch below gives. This used to build
// `--command "${sql}"` and hand it to a shell, and an ODD number of double
// quotes in the SQL - `instr(markdown, '"')`, or a class line's `"slug` cut in
// half - closed that quoting early. Whatever followed was shell syntax, so a
// trailing `> 0` became a REDIRECT: wrangler's output went into a file named
// `0` in the repo root and the caller saw "Unexpected end of JSON input". A
// stray `0` holding wrangler's usage text turned up that way on 2026-09-11;
// reproduced the same day with `instr(markdown, '"') > 0`.
export function d1Query(sql, { target = '--remote', db = DB } = {}) {
  const r = runWrangler(['d1', 'execute', db, target, ...localD1Args(target), '--json', '--command', sql]);
  if (r.status !== 0) {
    throw new Error('wrangler d1 execute failed:\n'
      + ((r.stderr || '') + (r.stdout || '')).slice(-2000));
  }
  // wrangler prefixes the JSON with a human banner, so the payload starts at
  // the first '['. Parsing `out` directly fails on every call.
  const out = r.stdout || '';
  return JSON.parse(out.slice(out.indexOf('['))).flatMap((b) => b.results || []);
}

// THE GLOBALLY INSTALLED wrangler.js, or null when there is none. `npx
// wrangler` runs this same file when it exists - measured 2026-10-12: npx
// printed 4.145.0, the global install's version, with 4.149.0 sitting in the
// npx cache - but takes about 3.3 s to find it, on every spawn: 5.1 s for a
// no-op `--version` through npx against 1.7 s for this file under node, and
// the suites pay it once per spawn.
//
// DERIVED, not asked for: `npm root -g` answers the same question and costs
// 1-2 s itself. The two places below are npm's defaults for its global prefix.
// A machine with the prefix moved gets null here, which is the slow path and
// not a wrong one. So does a GitHub runner, which has no global install.
//
// WORKSHOP_WRANGLER=npx forces null, to exercise the fallback on a machine
// that has the install.
let globalWrangler;
export function globalWranglerJs() {
  if (globalWrangler === undefined) {
    const root = process.platform === 'win32'
      ? process.env.APPDATA && join(process.env.APPDATA, 'npm', 'node_modules')
      : join(dirname(process.execPath), '..', 'lib', 'node_modules');
    const js = root && join(root, 'wrangler', 'bin', 'wrangler.js');
    globalWrangler = process.env.WORKSHOP_WRANGLER !== 'npx' && js && existsSync(js) ? js : null;
  }
  return globalWrangler;
}

/**
 * The words that start wrangler, for a caller that spawns with `shell: true`
 * and quotes its own arguments (regression.mjs). Both paths are quoted because
 * node lives under `Program Files`. Without a global install this is the
 * `npx wrangler` those callers always ran.
 */
export function wranglerShellWords() {
  const js = globalWranglerJs();
  return js ? [`"${process.execPath}"`, `"${js}"`] : ['npx', 'wrangler'];
}

// Without a shell wherever that is possible, so the child gets a real argv
// array: a shell string cannot carry an embedded double quote. The global
// wrangler.js under this Node when there is one; otherwise npm's own
// npx-cli.js under this Node, because Windows npx is a .cmd that Node refuses
// to spawn unshelled. maxBuffer because wrangler prints the whole result set,
// and the gear catalog alone overruns the 1 MB default.
export function runWrangler(args, opts = {}) {
  const base = { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e9, ...opts };
  const js = globalWranglerJs();
  if (js) return spawnSync(process.execPath, [js, ...args], base);
  const npxCli = join(dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
  return existsSync(npxCli)
    ? spawnSync(process.execPath, [npxCli, 'wrangler', ...args], base)
    : spawnSync('npx', ['wrangler', ...args], { ...base, shell: true });
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
 * Runs WITHOUT a shell, through runWrangler() above, because a shell string
 * cannot carry an embedded double quote. That matters here: class markdown
 * cites gear as `item_id: "slug"`, so the verification queries most worth
 * batching are the ones a shelled --command breaks on. A real argv array makes
 * them legal.
 */
export function d1Batch(stmts, { target = '--remote', db = DB } = {}) {
  const r = runWrangler(['d1', 'execute', db, target, ...localD1Args(target), '--json', '--command', stmts.join(' ')]);
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
