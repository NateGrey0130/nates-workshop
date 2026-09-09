#!/usr/bin/env node
// Deploy workers/pick3cut5-room, always recording which commit it was built
// from.
//
//   node scripts/deploy-room.mjs
//   node scripts/deploy-room.mjs --dry-run      # build, print bindings, deploy nothing
//   node scripts/deploy-room.mjs --allow-dirty  # see below; you almost never want this
//
// WHY THIS EXISTS AND IS NOT ONE MORE SENTENCE IN THE SKILL. The `pick3cut5`
// skill already said, in bold, that `--var GIT_SHA:$(git rev-parse HEAD)` is
// "not optional decoration". The 2026-09-02 hand deploy omitted it anyway, and
// for six days `deploy-sweep.mjs` could only compare timestamps and said so on
// every run. A flag you retype from prose is a flag you forget; a command that
// cannot omit it is not. This is the same move `ocr-book.py` made for the book
// caches, and the disposition `INGESTION-AUDIT` F15 reached about skill prose
// that is really a procedure.
//
// WHAT THE SHA BUYS. `deploy-sweep.mjs` reads the binding back off the live
// Worker and answers "is it stale" with `git log <deployed>..origin/main --
// workers/pick3cut5-room`, which is empty or it is not. Without it the sweep
// falls back to comparing a commit timestamp against a deploy timestamp, which
// cannot tell whether the change mattered. `REPO-AUDIT.md` G15.
//
// WHY A DIRTY TREE IS REFUSED. The sha is a claim about what is running. Deploy
// with uncommitted changes under the worker directory and the binding names a
// commit whose content is NOT what shipped - and the sweep then reports "up to
// date, nothing has touched it since that commit", confidently and wrongly.
// That is worse than the absent binding this script exists to prevent: an
// absent one makes the sweep say it is guessing. `--allow-dirty` records
// `<sha>-dirty`, which is not a commit, so the sweep's own unknown-commit
// branch fires and says the live build cannot be placed. It never reports
// "up to date" off a dirty deploy.
//
// It does NOT verify the binding afterwards. `node scripts/deploy-sweep.mjs`
// already reads it back from the API, and a check that lives in one place is
// the one that stays true.

import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const WORKER_DIR = 'workers/pick3cut5-room';
const CONFIG = `${WORKER_DIR}/wrangler.jsonc`;

const argv = process.argv.slice(2);
const allowDirty = argv.includes('--allow-dirty');
const dryRun = argv.includes('--dry-run');
const unknown = argv.filter((a) => !['--allow-dirty', '--dry-run'].includes(a));
if (unknown.length) {
  console.error(`deploy-room: unrecognised argument(s): ${unknown.join(' ')}`);
  console.error('usage: node scripts/deploy-room.mjs [--dry-run] [--allow-dirty]');
  process.exit(2);
}

function git(args) {
  const r = spawnSync('git', args, { cwd: ROOT, encoding: 'utf8' });
  if (r.status !== 0) {
    console.error(`deploy-room: git ${args.join(' ')} failed`);
    console.error((r.stderr || '').trim());
    process.exit(1);
  }
  return (r.stdout || '').trim();
}

const head = git(['rev-parse', 'HEAD']);
const dirty = git(['status', '--porcelain', '--', WORKER_DIR]);

if (dirty && !allowDirty) {
  console.error(`deploy-room: ${WORKER_DIR} has uncommitted changes, so the sha would lie.\n`);
  for (const line of dirty.split(/\r?\n/)) console.error(`  ${line}`);
  console.error('\n  The GIT_SHA binding is a claim about what is running. Deploying now would');
  console.error(`  record ${head.slice(0, 8)} while shipping something else, and deploy-sweep would`);
  console.error('  then report "up to date" off a build nobody can reconstruct.\n');
  console.error('  Commit the change and deploy that, or deploy it deliberately unplaceable:');
  console.error('    node scripts/deploy-room.mjs --allow-dirty\n');
  process.exit(1);
}

const sha = dirty ? `${head}-dirty` : head;

if (dirty) {
  console.log(`deploy-room: WARNING - ${WORKER_DIR} is dirty. Recording ${sha.slice(0, 8)}-dirty,`);
  console.log('  which is not a commit, so deploy-sweep will report the live build as');
  console.log('  unplaceable rather than up to date. That is the intended outcome.\n');
}

console.log(`deploy-room: ${dryRun ? 'dry run for' : 'deploying'} ${WORKER_DIR} at ${sha.slice(0, 8)}`);
if (!dryRun) {
  console.log('  a deploy restarts the Durable Objects, so any room in progress will drop.');
}
console.log('');

const args = ['wrangler', 'deploy', '--config', CONFIG, '--var', `GIT_SHA:${sha}`];
if (dryRun) args.push('--dry-run', '--outdir', resolve(ROOT, '.wrangler', 'deploy-room-dryrun'));

// A SHELL IS NOT OPTIONAL ON THIS MACHINE, and the obvious way to avoid one
// fails silently. Measured 2026-09-08 under Node 24: `npx.cmd` spawns EINVAL
// (Node refuses .cmd without a shell), bare `npx` spawns ENOENT (it is an
// extensionless shell script Windows cannot exec), and only `shell: true`
// runs. So the command is built as ONE quoted string rather than an args
// array - an array through a shell is concatenated unescaped, which is what
// Node's DEP0190 warns about and what would break on a path with a space.
const quote = (s) => (/[\s"^&|<>()]/.test(s) ? `"${String(s).replace(/"/g, '\\"')}"` : s);
const command = ['npx', ...args].map(quote).join(' ');
const r = spawnSync(command, { cwd: ROOT, stdio: 'inherit', shell: true });
if (r.status !== 0) process.exit(r.status === null ? 1 : r.status);

if (!dryRun) {
  console.log('\ndeploy-room: deployed. Confirm what the sweep now sees:');
  console.log('  node scripts/deploy-sweep.mjs');
}
