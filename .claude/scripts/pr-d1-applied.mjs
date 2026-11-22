#!/usr/bin/env node
// pr-d1-applied.mjs - are this pull request's migrations and data scripts
// already applied to production?
//
//   node .claude/scripts/pr-d1-applied.mjs <pr>
//
// Prints one line:
//   NO D1 FILES               exit 0  the diff carries no migration or data script
//   D1 APPLIED <files>        exit 0  production records every one of them
//   D1 NOT APPLIED <files>    exit 1  these are not recorded: apply before the merge
//   D1 UNREADABLE <why>       exit 2  could not read; not a pass
//
// WHY IT EXISTS. `ship-pr` -> *The ordering rule* applies D1 before the merge,
// because the merge deploys. A plan driver merging a `MERGE-FIRST` row had no
// command that read it: `plan-tick.mjs` reads CI and the state file, not
// production, so a green pull request carrying an unapplied migration read the
// same as one whose migration had landed.
//
// IT REUSES `scripts/d1-apply.mjs --check --remote`, which asks production's
// schema_migrations and data_script_runs. Nothing about the ledger is decided
// here. The pull request's own copy of each file is written to a scratch
// directory from its head commit (the checkout running this may be `main`,
// which does not have them yet) and the check is pointed at those copies, one
// run per database. Two of d1-apply's guards are switched off for this read,
// because neither answers "is it recorded": `--skip-preflight` (the read-back
// replay, which reads only files under the data directory anyway) and
// `--allow-number` (another branch holding the same number is `ship-pr`'s
// question at apply time). Its other guards still run, so a file with a CR or
// non-ASCII SQL is reported UNREADABLE with d1-apply's own reason.
//
// A file the pull request DELETES is listed by `gh pr diff --name-only` too;
// it has no copy at the head commit and is left out, since nothing applies it.
// The pure part (which paths, how --check answered, the line) is
// `pr-d1-lib.mjs`, driven by apps/character-creator/test/checks/plan-tick-verdict.mjs.
import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { d1FilesByDb, parseCheck, verdict } from './pr-d1-lib.mjs';

const REPO = 'NateGrey0130/nates-workshop';
const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..', '..');

const pr = process.argv.slice(2).find((a) => /^\d+$/.test(a));
if (!pr) {
  console.error('usage: node .claude/scripts/pr-d1-applied.mjs <pr-number>');
  process.exit(2);
}

function unreadable(why) {
  console.log(`D1 UNREADABLE ${why}`);
  process.exit(2);
}

const run = (cmd, args, opts = {}) => spawnSync(cmd, args, { cwd: repoRoot, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, ...opts });
const firstLine = (r) => String(r.error?.message || r.stderr || r.stdout || '').trim().split('\n')[0];

const diff = run('gh', ['pr', 'diff', pr, '--name-only', '--repo', REPO]);
if (diff.status !== 0) unreadable(`gh pr diff ${pr}: ${firstLine(diff)}`);
const byDb = d1FilesByDb(diff.stdout.split('\n'));
if (!byDb.size) {
  console.log(verdict([]).line);
  process.exit(0);
}

const view = run('gh', ['pr', 'view', pr, '--json', 'headRefOid', '--repo', REPO]);
if (view.status !== 0) unreadable(`gh pr view ${pr}: ${firstLine(view)}`);
let head;
try { head = JSON.parse(view.stdout).headRefOid; } catch { /* below */ }
if (!/^[0-9a-f]{40}$/.test(head || '')) unreadable(`gh pr view ${pr}: no head commit`);

// The head commit may not be in this clone yet. pull/<n>/head reaches it for
// an open, merged or closed pull request alike.
if (run('git', ['cat-file', '-e', `${head}^{commit}`]).status !== 0) {
  const fetched = run('git', ['fetch', '--quiet', 'origin', `refs/pull/${pr}/head`]);
  if (fetched.status !== 0) unreadable(`git fetch pull/${pr}/head: ${firstLine(fetched)}`);
}

const scratch = mkdtempSync(join(tmpdir(), `pr-d1-${pr}-`));
let results;
let failed = null;
try {
  results = [];
  for (const [db, paths] of byDb) {
    const files = [];
    for (const p of paths) {
      const show = run('git', ['show', `${head}:${p}`], { encoding: 'buffer' });
      if (show.status !== 0) {
        const err = String(show.stderr);
        if (/does not exist in|exists on disk, but not in/.test(err)) continue; // deleted by the pull request
        // Not exiting here: process.exit would skip the finally that removes the scratch copies.
        throw new Error(`git show ${head.slice(0, 8)}:${p}: ${err.trim().split('\n')[0]}`);
      }
      const out = join(scratch, ...p.split('/'));
      mkdirSync(dirname(out), { recursive: true });
      writeFileSync(out, show.stdout);
      files.push(out);
    }
    if (!files.length) continue;
    const args = [join(repoRoot, 'scripts', 'd1-apply.mjs'), '--check', '--remote', '--skip-preflight', '--allow-number'];
    if (db !== 'palladium') args.push('--db', db);
    const check = run(process.execPath, [...args, ...files]);
    results.push({ db, files, parsed: parseCheck({ status: check.status, stdout: check.stdout, stderr: check.stderr }, files) });
  }
} catch (err) {
  failed = err.message;
} finally {
  rmSync(scratch, { recursive: true, force: true });
}
if (failed) unreadable(failed);

const v = verdict(results);
console.log(v.line);
process.exit(v.code);
