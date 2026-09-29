// Deploy one of this repo's standalone Workers, always recording which commit
// it was built from. Shared by the two scripts that are its only callers:
//
//   node scripts/deploy-room.mjs         workers/pick3cut5-room
//   node scripts/deploy-table-room.mjs   workers/table-room
//
// Each takes --dry-run (build, print bindings, deploy nothing) and
// --allow-dirty (see below; you almost never want it).
//
// ONE SCRIPT PER WORKER, NOT A --worker FLAG. A flag retyped from prose is the
// failure this whole file exists to end (deploy-room.mjs's header has the
// 2026-09-02 incident), and a forgotten --worker would deploy the OTHER Worker,
// successfully, with nothing looking wrong.
//
// WHAT THE SHA BUYS. `deploy-sweep.mjs` reads the GIT_SHA binding back off the
// live Worker and answers "is it stale" with `git log <deployed>..origin/main
// -- <worker dir>`, which is empty or it is not (`REPO-AUDIT.md` G15).
//
// WHY A DIRTY TREE IS REFUSED. The sha is a claim about what is running. Deploy
// with uncommitted changes under the worker directory and the binding names a
// commit whose content is NOT what shipped, and the sweep then reports "up to
// date" confidently and wrongly. `--allow-dirty` records `<sha>-dirty`, which
// is not a commit, so the sweep says the live build cannot be placed.

import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');

export function deployWorker({ workerDir, script }) {
  const config = `${workerDir}/wrangler.jsonc`;
  const name = script.replace(/\.mjs$/, '');

  const argv = process.argv.slice(2);
  const allowDirty = argv.includes('--allow-dirty');
  const dryRun = argv.includes('--dry-run');
  const unknown = argv.filter((a) => !['--allow-dirty', '--dry-run'].includes(a));
  if (unknown.length) {
    console.error(`${name}: unrecognised argument(s): ${unknown.join(' ')}`);
    console.error(`usage: node scripts/${script} [--dry-run] [--allow-dirty]`);
    process.exit(2);
  }

  function git(args) {
    const r = spawnSync('git', args, { cwd: ROOT, encoding: 'utf8' });
    if (r.status !== 0) {
      console.error(`${name}: git ${args.join(' ')} failed`);
      console.error((r.stderr || '').trim());
      process.exit(1);
    }
    return (r.stdout || '').trim();
  }

  const head = git(['rev-parse', 'HEAD']);
  const dirty = git(['status', '--porcelain', '--', workerDir]);

  if (dirty && !allowDirty) {
    console.error(`${name}: ${workerDir} has uncommitted changes, so the sha would lie.\n`);
    for (const line of dirty.split(/\r?\n/)) console.error(`  ${line}`);
    console.error('\n  The GIT_SHA binding is a claim about what is running. Deploying now would');
    console.error(`  record ${head.slice(0, 8)} while shipping something else, and deploy-sweep would`);
    console.error('  then report "up to date" off a build nobody can reconstruct.\n');
    console.error('  Commit the change and deploy that, or deploy it deliberately unplaceable:');
    console.error(`    node scripts/${script} --allow-dirty\n`);
    process.exit(1);
  }

  const sha = dirty ? `${head}-dirty` : head;

  if (dirty) {
    console.log(`${name}: WARNING - ${workerDir} is dirty. Recording ${sha.slice(0, 8)}-dirty,`);
    console.log('  which is not a commit, so deploy-sweep will report the live build as');
    console.log('  unplaceable rather than up to date. That is the intended outcome.\n');
  }

  console.log(`${name}: ${dryRun ? 'dry run for' : 'deploying'} ${workerDir} at ${sha.slice(0, 8)}`);
  if (!dryRun) {
    console.log('  a deploy restarts the Durable Objects, so any room in progress will drop.');
  }
  console.log('');

  const args = ['wrangler', 'deploy', '--config', config, '--var', `GIT_SHA:${sha}`];
  if (dryRun) args.push('--dry-run', '--outdir', resolve(ROOT, '.wrangler', `${name}-dryrun`));

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
    console.log(`\n${name}: deployed. Confirm what the sweep now sees:`);
    console.log('  node scripts/deploy-sweep.mjs');
  }
}
