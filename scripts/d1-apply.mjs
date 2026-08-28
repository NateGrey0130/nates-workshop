#!/usr/bin/env node
// Apply migrations and data scripts to a D1 database, in order, with the
// guards our deploy routine kept re-learning by hand:
//
//   node scripts/d1-apply.mjs --remote db/migrations/021-x.sql apps/character-creator/db/backfill-y.sql
//   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-z.sql
//   node scripts/d1-apply.mjs --remote apps/character-creator/db/*.sql
//
// - Globs are expanded by this script, sorted, because PowerShell does not
//   expand them for native commands and the same command should work in both
//   shells. A file whose first-column comment says `-- local-only` is SKIPPED
//   on BOTH targets: a glob cannot sweep seed-dev.sql into production, and it
//   cannot strand the 31 files that sort after it in a --local rebuild either.
//
// - The target is EXPLICIT. No default: an accidental --remote is the costly
//   direction, so the script refuses to guess.
// - Remote runs start with a throwaway `wrangler whoami`. An interactive-login
//   OAuth token expires after idle and wrangler refreshes it as a side effect
//   of the first call — which used to make the first real apply fail with
//   "Authentication error [code: 10000]" and succeed on retry. The warm-up
//   absorbs that. Under a CLOUDFLARE_API_TOKEN the warm-up is SKIPPED: an API
//   token does not go stale, so there is nothing to refresh, and `wrangler
//   whoami` EXITS NON-ZERO under a token scoped to D1 alone (it lists accounts,
//   which that scope cannot read). Running it aborted the whole apply before a
//   single file landed, blaming a missing token that was present and working.
// - Every file is checked before anything runs: it must exist, carry no CR (a
//   CRLF checkout once changed the bytes that reached production — see
//   .gitattributes and PR #93), and hold no non-ASCII IN EXECUTABLE SQL
//   (em-dashes through wrangler on Windows have produced mojibake in
//   production). Comments are exempt from the second rule: a mangled comment
//   harms nothing, and checking them refused 11 of this repo's own migrations.
// - Files apply IN THE ORDER GIVEN and the run stops at the first failure,
//   so a migration always lands before the backfill that needs it and a
//   failure can't half-apply the tail.
// - Each file's own trailing verification SELECTs are printed — the scripts
//   read their results back rather than trusting exit codes, and this is
//   where those results surface. On --remote that needs a second pass:
//   `--remote --file` does not run the SQL over the query API, it uploads the
//   file to D1's IMPORT endpoint, which returns aggregate counts and nothing
//   else. So the trailing SELECTs are re-run afterwards over --command. They
//   are read-only by definition, and without this the promise above was
//   simply false on the target it matters most for.
// - One automatic retry per file on the 10000 auth error, in case the token
//   expires mid-sequence.

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { trailingSelects, stripComments } from './sql-statements.mjs';

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const local = args.includes('--local');
// Globs are expanded HERE, not by the shell. PowerShell does not expand them
// for native commands at all, so `db/*.sql` reaches this script as a literal
// and dies as 'no such file'. Doing it here means one documented command
// works from PowerShell and from bash alike.
function expand(arg) {
  if (!arg.includes('*')) return [arg];
  const slash = arg.lastIndexOf('/');
  const dir = slash === -1 ? '.' : arg.slice(0, slash);
  const pattern = arg.slice(slash + 1);
  if (!existsSync(dir)) return [];
  const rx = new RegExp('^' + pattern.split('*').map((x) =>
    x.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('.*') + '$');
  // Sorted, so an apply order is reproducible rather than filesystem order.
  return readdirSync(dir).filter((f) => rx.test(f)).sort().map((f) => `${dir}/${f}`);
}

let files = args.filter((a) => !a.startsWith('--')).flatMap(expand);

function die(msg) {
  console.error('\nd1-apply: ' + msg);
  process.exit(1);
}

if (remote === local) die('say which database: --remote or --local (exactly one)');
if (!files.length) die('no .sql files given (a glob that matched nothing?)');

// A file marked local-only is skipped on BOTH targets, and the reasons differ.
//
// Under --remote it must never go: seed-dev.sql inserts a test campaign and a
// test character, and sweeping it up in a `db/*.sql` glob would put them in
// front of real players. The marker is a comment in the file rather than a
// filename list here, so a new local-only script is protected the moment it
// says so.
//
// Under --local the point is the opposite - not protecting the database from
// the file, but protecting the RUN from it. seed-dev.sql sorts 264th of 295 and
// its inserts are unguarded, so a `--local db/*.sql` glob reaches it, fails on
// `gear.slug`, and because this script stops at the first failure the 31 files
// that sort AFTER it never run: untag-cross-system, every zz-, every zzz- and
// every zzzz-. The last three tiers of corrections - the ones that exist
// BECAUSE filename order is execution order - were unreachable by the one
// command a person is most likely to type. It fails on the FIRST pass from an
// empty database, not on a second: by the time it runs, the gear row it inserts
// has already been created by an earlier script. See REBUILD-AUDIT.md F1.
//
// SKIPPED, not fatal, and the difference matters: the documented way to seed a
// new environment is a glob over the whole directory, and dying on the one
// file that must not go would make the documented command fail every time.
// A command that always errors gets replaced by a hand-typed list, which is
// where a file gets included by mistake. The skip is printed, so it is never
// silent.
//
// Naming a local-only file EXPLICITLY now skips it too, and that is intended
// rather than incidental: seed-dev.sql's own header and the README both say to
// apply it with plain `wrangler d1 execute --local --file`, never through this
// script.
const skipped = files.filter((f) =>
  existsSync(f) && /^--\s*local-only\b/m.test(readFileSync(f, 'utf8')));
files = files.filter((f) => !skipped.includes(f));
for (const f of skipped) console.log(`skipping ${f} — marked local-only; apply it on its own.`);
if (!files.length) die('nothing left to apply: every file given is local-only');

// ── pre-flight: every file checked before anything runs ──
for (const f of files) {
  if (!existsSync(f)) die(`${f}: no such file`);
  const buf = readFileSync(f);
  if (buf.includes(0x0d)) {
    die(`${f}: contains CR — a CRLF checkout changes the bytes that reach the `
      + 'database. Re-checkout (the .gitattributes *.sql rule pins LF) or normalise the file.');
  }
  // Non-ASCII is checked in EXECUTABLE SQL only, not in comments.
  //
  // The hazard is real but specific: wrangler on Windows has turned literal
  // non-ASCII into mojibake in production, and a mangled VALUE is corruption
  // that outlives the run. A mangled COMMENT is a cosmetic blemish in a file
  // nobody reads from the database.
  //
  // Checking the whole file made this script refuse 11 of the repo's own
  // migrations, every one of them for an em-dash in prose. A guard that
  // rejects the files you are documented to apply with it does not get
  // tightened, it gets bypassed - and then it is guarding nothing.
  const offending = [...stripComments(buf.toString('utf8'))]
    .filter((ch) => ch.codePointAt(0) > 0x7f);
  if (offending.length) {
    die(`${f}: contains non-ASCII in executable SQL (${JSON.stringify(offending.join(''))}) `
      + '— wrangler on Windows has mangled these into mojibake in production before. '
      + 'Splice it instead: \'a \' || char(8212) || \' b\'. Comments are exempt.');
  }
}

// Call npm's own npx-cli.js with this Node, so the child spawns WITHOUT a shell.
// `shell: true` was load-bearing, not incidental: Windows npx is a .cmd, and Node
// refuses to spawn .bat/.cmd unshelled (EINVAL, the CVE-2024-27980 guard). But it
// concatenates argv instead of escaping it (DEP0190), so a .sql path containing a
// space would break the command. This form keeps a real argv array. If npx-cli.js
// is not where we expect (a non-standard install), fall back to the old behaviour.
const npxCli = path.join(path.dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
const npxCliFound = existsSync(npxCli);

function run(cliArgs) {
  const r = npxCliFound
    ? spawnSync(process.execPath, [npxCli, ...cliArgs], { encoding: 'utf8' })
    : spawnSync('npx', cliArgs, { encoding: 'utf8', shell: true });
  return { code: r.status ?? 1, out: (r.stdout || '') + (r.stderr || '') };
}

// ── warm-up: refresh a stale OAuth token before the first real call ──
if (remote && !process.env.CLOUDFLARE_API_TOKEN) {
  process.stdout.write('warming wrangler auth… ');
  const r = run(['wrangler', 'whoami']);
  if (r.code !== 0) die('wrangler whoami failed — not logged in and no CLOUDFLARE_API_TOKEN?\n' + r.out);
  console.log('ok');
} else if (remote) {
  console.log('CLOUDFLARE_API_TOKEN set - skipping auth warm-up.');
}

const target = remote ? '--remote' : '--local';
for (const f of files) {
  console.log(`\n── applying ${f} (${target}) ──`);
  let r = run(['wrangler', 'd1', 'execute', 'DB', target, '--file', f]);
  if (r.code !== 0 && r.out.includes('code: 10000')) {
    console.log('auth error 10000 — one retry…');
    r = run(['wrangler', 'd1', 'execute', 'DB', target, '--file', f]);
  }
  // Show the run's output either way: on success it carries the file's own
  // verification SELECTs, on failure the reason.
  console.log(r.out.trim());
  if (r.code !== 0) die(`${f} failed — nothing after it was applied.`);

  // Remote applies go through the import endpoint, which reports counts and
  // swallows result sets. Replay the file's own trailing SELECTs over the
  // query API so the numbers the script was written to show actually appear.
  if (remote) {
    const checks = trailingSelects(readFileSync(f, 'utf8'));
    if (checks.length) {
      console.log(`\n-- ${f}: verification --`);
      // One --command carrying every SELECT, so this is one extra round trip
      // per file rather than one per statement. trailingSelects() returns them
      // single-line: --command truncates at the first newline and calls the
      // remainder `incomplete input`, which reads like bad SQL rather than a
      // mangled argument. Every verification SELECT here spans several lines.
      const v = run(['wrangler', 'd1', 'execute', 'DB', '--remote', '--command', checks.join(' ')]);
      console.log(v.out.trim());
      // A failed verification is not a failed apply. The rows landed; only the
      // read-back did not, and saying otherwise would send you rolling back a
      // migration that is fine.
      if (v.code !== 0) console.log(`(verification query failed - the apply itself succeeded)`);
    }
  }
}

console.log(`\nd1-apply: ${files.length} file(s) applied to ${remote ? 'REMOTE' : 'local'} in order`
  + (skipped.length ? `, ${skipped.length} skipped as local-only.` : '.'));
