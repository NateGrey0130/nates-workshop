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
// - Each file's own trailing verification SELECTs are re-run after the apply
//   over --command --json, on BOTH targets, and their ASSERTION rows are
//   ENFORCED: a row shaped `... AS assertion, ... AS got, ... AS want` whose
//   got differs from its want stops the run before the next file and exits
//   non-zero. (--remote --file goes to D1's IMPORT endpoint, which returns
//   aggregate counts and swallows result sets, so the second pass is the only
//   way those rows are seen at all on the target that matters.) Until
//   2026-09-16 the rows were printed and the run carried on - three wrong
//   claims in one import were caught by a person reading the output, and
//   `mystic-russia-survey` records that a fourth was not.
// - And they are enforced BEFORE anything is applied: the data directory is
//   replayed into node's own SQLite (readback-lib.mjs, the rebuild-local.mjs
//   replay, ~20s) and each given data script's assertions are evaluated at
//   its own position in the order. A mismatch there means nothing reaches the
//   target. Files outside apps/character-creator/db - migrations, schema.sql -
//   are not replayed (schema.sql already carries every migration) and get the
//   post-apply enforcement only. `--skip-preflight` exists for the day the
//   replay is wrong about something, and it says so loudly when used.
// - One automatic retry per file on the 10000 auth error, in case the token
//   expires mid-sequence.

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { trailingSelects, stripComments, statements, expressionDepth, D1_MAX_EXPR_DEPTH } from './sql-statements.mjs';
import { assertionMismatches, preflightReadbacks } from './readback-lib.mjs';
import { d1Batch, localD1Args, repoRoot } from './d1-query-lib.mjs';

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const local = args.includes('--local');
const skipPreflight = args.includes('--skip-preflight');
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
  // D1 refuses an expression tree deeper than 100, and refuses it only when
  // the statement reaches it - late, and reading like bad data. Caught here,
  // before any statement in any file has run (see expressionDepth).
  const deep = statements(buf.toString('utf8'))
    .map((s) => [expressionDepth(s), s]).filter(([d]) => d > D1_MAX_EXPR_DEPTH);
  if (deep.length) {
    die(`${f}: a statement nests about ${deep[0][0]} levels deep, and D1 refuses more than `
      + `${D1_MAX_EXPR_DEPTH} ("Expression tree is too large"). A long text written as `
      + "'a' || char(10) || 'b' || ... nests one level per link; write ONE literal with a "
      + "placeholder instead: replace('a~~b~~c', '~~', char(10)). Statement begins: "
      + JSON.stringify(deep[0][1].slice(0, 120)));
  }
}

// ── pre-flight: the read-back assertions, in a scratch replay, before any apply ──
//
// Each given data script's trailing SELECTs are evaluated right after that
// script at its own position in a replay of the data directory. At its own
// position, not at the end: the readbacks assert global counts that later
// files change on purpose (operations.md, the z-tier table), so an end-state
// check would fail scripts that are right. A mismatch here means the file
// does not do what its author read off the page, and nothing has touched the
// target yet - which is the whole point of doing it here rather than after.
if (skipPreflight) {
  console.log('\n!! --skip-preflight: read-back assertions will NOT be checked before applying. !!');
} else {
  process.stdout.write('\npre-flight: replaying the data directory to check read-back assertions... ');
  const t0 = Date.now();
  const pf = preflightReadbacks(files, { repoRoot, log: (m) => console.log(m) });
  console.log(`${((Date.now() - t0) / 1000).toFixed(1)}s`);
  for (const f of pf.skipped) console.log(`  ${f}: not under the data directory - assertions enforced after the apply only`);
  for (const f of pf.checked) console.log(`  ${f}: replayed, read-backs evaluated`);
  if (pf.tolerated) console.log(`  (${pf.tolerated} file(s) not given failed in the replay and were tolerated)`);
  if (pf.failures.length) {
    for (const x of pf.failures) console.error(`  PRE-FLIGHT FAILED ${x.file}: ${x.detail}`);
    die(`${pf.failures.length} read-back ${pf.failures.length === 1 ? 'assertion' : 'assertions'} failed in the scratch replay - NOTHING was applied. `
      + 'Fix the script (or its want) and run again. The replay state at a file is the repo in SORTED order up to that '
      + 'file, so a new file that sorts before scripts production already has is asserting against an older catalog than '
      + 'production holds - name it to sort LAST (operations.md, the z-tier table). --skip-preflight bypasses this check '
      + 'and is the wrong answer unless the replay itself is at fault.');
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
  // localD1Args: `--persist-to $WORKSHOP_LOCAL_D1` on --local when set, nothing otherwise.
  let r = run(['wrangler', 'd1', 'execute', 'DB', target, ...localD1Args(target), '--file', f]);
  if (r.code !== 0 && r.out.includes('code: 10000')) {
    console.log('auth error 10000 — one retry…');
    r = run(['wrangler', 'd1', 'execute', 'DB', target, ...localD1Args(target), '--file', f]);
  }
  // Show the run's output either way: on success it carries the file's own
  // verification SELECTs, on failure the reason.
  console.log(r.out.trim());
  if (r.code !== 0) die(`${f} failed — nothing after it was applied.`);

  // Re-run the file's own trailing SELECTs over the query API and ENFORCE their
  // assertion rows. Remote applies go through the import endpoint, which
  // reports counts and swallows result sets, so on --remote this is the only
  // place the rows are seen at all; on --local the --file output above already
  // showed them, and this is where they are read rather than looked at.
  const checks = trailingSelects(readFileSync(f, 'utf8'));
  if (checks.length) {
    console.log(`\n-- ${f}: verification (${target}) --`);
    // One --command carrying every SELECT, so this is one extra round trip
    // per file rather than one per statement. trailingSelects() returns them
    // single-line: --command truncates at the first newline and calls the
    // remainder `incomplete input`, which reads like bad SQL rather than a
    // mangled argument. Every verification SELECT here spans several lines.
    let blocks;
    try {
      blocks = d1Batch(checks, { target });
    } catch (e) {
      // The rows landed; only the read-back did not run. Rolling back a
      // migration over this would be wrong - but so is exiting 0 when the
      // assertions were never evaluated, so the run stops here and says which.
      die(`${f}: the read-back query failed, so its assertions were NOT evaluated. `
        + `The apply itself succeeded - do not roll it back; re-run the SELECTs by hand.\n${e.message}`);
    }
    const mismatches = [];
    blocks.forEach((b, i) => {
      const rows = b?.results ?? [];
      console.log(`[${i + 1}] ${checks[i]}`);
      console.log(JSON.stringify(rows));
      mismatches.push(...assertionMismatches(rows));
    });
    if (mismatches.length) {
      for (const m of mismatches) {
        console.error(`  ASSERTION FAILED ${JSON.stringify(m.assertion)}: got ${JSON.stringify(m.got)}, want ${JSON.stringify(m.want)}`);
      }
      die(`${f}: ${mismatches.length} read-back ${mismatches.length === 1 ? 'assertion' : 'assertions'} failed on ${target}. `
        + 'The file IS applied; nothing after it was. A one-shot script is not re-run - '
        + 'write a fix- script that sorts after it (operations.md, the z-tier table)'
        + (local ? ', unless the local database has simply drifted from the repo (ship-pr: --local is not a mirror)' : '') + '.');
    }
    console.log(`  read-backs: ${blocks.length} statement(s), every assertion holds`);
  }
}

console.log(`\nd1-apply: ${files.length} file(s) applied to ${remote ? 'REMOTE' : 'local'} in order`
  + (skipped.length ? `, ${skipped.length} skipped as local-only.` : '.'));
