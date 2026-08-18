#!/usr/bin/env node
// Apply migrations and data scripts to a D1 database, in order, with the
// guards our deploy routine kept re-learning by hand:
//
//   node scripts/d1-apply.mjs --remote db/migrations/021-x.sql apps/character-creator/db/backfill-y.sql
//   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-z.sql
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
// - Every file is checked before anything runs: it must exist, be pure ASCII
//   (em-dashes through `wrangler d1 execute` on Windows have produced mojibake
//   in production), and carry no CR (a CRLF checkout once changed the bytes
//   that reached production — see .gitattributes and PR #93).
// - Files apply IN THE ORDER GIVEN and the run stops at the first failure,
//   so a migration always lands before the backfill that needs it and a
//   failure can't half-apply the tail.
// - Each file's own trailing verification SELECTs are printed — the scripts
//   read their results back rather than trusting exit codes, and this is
//   where those results surface.
// - One automatic retry per file on the 10000 auth error, in case the token
//   expires mid-sequence.

import { readFileSync, existsSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

const args = process.argv.slice(2);
const remote = args.includes('--remote');
const local = args.includes('--local');
const files = args.filter((a) => !a.startsWith('--'));

function die(msg) {
  console.error('\nd1-apply: ' + msg);
  process.exit(1);
}

if (remote === local) die('say which database: --remote or --local (exactly one)');
if (!files.length) die('no .sql files given');

// ── pre-flight: every file checked before anything runs ──
for (const f of files) {
  if (!existsSync(f)) die(`${f}: no such file`);
  const buf = readFileSync(f);
  if (buf.includes(0x0d)) {
    die(`${f}: contains CR — a CRLF checkout changes the bytes that reach the `
      + 'database. Re-checkout (the .gitattributes *.sql rule pins LF) or normalise the file.');
  }
  for (const b of buf) {
    if (b > 0x7f) {
      die(`${f}: contains non-ASCII bytes — wrangler on Windows has mangled these `
        + 'into mojibake in production before. Normalise (char(8212) for a stored em-dash).');
    }
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
}

console.log(`\nd1-apply: ${files.length} file(s) applied to ${remote ? 'REMOTE' : 'local'} in order.`);
