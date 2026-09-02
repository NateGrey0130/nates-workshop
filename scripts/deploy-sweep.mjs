// Did anything I merged actually ship?
//
//   node scripts/deploy-sweep.mjs              the last 20 merge commits
//   node scripts/deploy-sweep.mjs --last 50    a wider window
//   node scripts/deploy-sweep.mjs --all        every merge commit on main
//
// Merging to `main` starts a deploy. It does not finish one. Cloudflare Pages
// compiles every file under `functions/` - routed or not - plus everything
// they import, using the wrangler its build image ships rather than the one
// this machine resolves. Syntax that image cannot parse fails the whole
// deploy, and nothing on the request path changes: the site keeps serving the
// last build that compiled. SETUP.md -> "When the merge does not deploy" has
// the mechanism.
//
// THE SIGNAL WAS NEVER THE PROBLEM. Every merge commit from d5280fe
// (2026-08-27) to the fix in #399 (2026-08-30) reports
// `Cloudflare Pages=failure` on its own check-runs - 65 consecutive, no
// ambiguity, no flapping - and every merge since reports success. Nobody read
// it, for four days, across 65 merges. That is what this script is for: the
// check was correct and it was a thing to remember once per merge, at a merge
// rate that has twice passed 45 in a day.
//
// `ship-pr` step 9 still asks for the per-merge read and should stay. This is
// the backstop for the merge you did not check, and the one question worth
// asking at the end of a working session.
//
// DO NOT confuse this with `gh pr checks`, which reads the PR's head commit.
// That has shown a red "Cloudflare Pages fail" on PRs that deployed perfectly
// well for months, so the mark there carries no information. The MERGE
// commit's check-runs are the signal.
//
// Report only. This never moves the exit code, for the same reason
// repo-vs-live.mjs does not: a failed deploy needs a person to look at it, and
// a script that exits non-zero on a four-day-old failure would fail every run
// until someone fixed history. It prints, you read.
//
// A deploy takes up to a minute or so to finish. A merge made seconds ago
// reports `in_progress` with no conclusion yet - that is reported as PENDING,
// which is not a failure and not a pass. Run it again.
import { execFileSync } from 'node:child_process';

const REPO = 'NateGrey0130/nates-workshop';

const args = process.argv.slice(2);
const all = args.includes('--all');
const lastFlag = args.indexOf('--last');
const limit = lastFlag !== -1 ? Number(args[lastFlag + 1]) : 20;
if (!all && (!Number.isInteger(limit) || limit < 1)) {
  console.error('usage: node scripts/deploy-sweep.mjs [--last N | --all]');
  process.exit(2);
}

const run = (cmd, cmdArgs) =>
  execFileSync(cmd, cmdArgs, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });

// Read origin/main rather than the local branch: the question is what was
// merged, not what happens to be checked out. Fetch first so the answer is not
// as stale as the last pull.
try {
  run('git', ['fetch', '--quiet', 'origin', 'main']);
} catch {
  console.log('  (could not fetch; reading origin/main as of the last fetch)');
}

const logArgs = ['log', '--merges', '--format=%H%x09%ad%x09%s', '--date=short'];
if (!all) logArgs.push(`-${limit}`);
logArgs.push('origin/main');

const commits = run('git', logArgs).trim().split('\n').filter(Boolean).map((line) => {
  const [sha, date, subject] = line.split('\t');
  return { sha, date, subject };
});

if (commits.length === 0) {
  console.log('No merge commits on origin/main.');
  process.exit(0);
}

const bad = [];
const pending = [];
let ok = 0;

for (const c of commits) {
  let conclusions;
  try {
    const out = run('gh', [
      'api', `repos/${REPO}/commits/${c.sha}/check-runs`,
      '--jq', '[.check_runs[] | .name + "=" + (.conclusion // "pending")] | join(",")',
    ]).trim();
    conclusions = out;
  } catch (err) {
    // A commit GitHub cannot answer for is not a passing commit. Say so rather
    // than counting it as fine.
    bad.push({ ...c, why: `check-runs unreadable: ${String(err.message).split('\n')[0]}` });
    continue;
  }

  if (!conclusions) {
    // No check run at all. Pages registers one per merge, so an empty list
    // means the deploy was never triggered - which looks exactly like a
    // healthy quiet merge and is not one.
    bad.push({ ...c, why: 'no check-runs at all - the deploy never started' });
    continue;
  }
  if (conclusions.includes('=pending')) {
    pending.push({ ...c, why: conclusions });
    continue;
  }
  if (conclusions.includes('=success') && !/=(failure|cancelled|timed_out|action_required)/.test(conclusions)) {
    ok += 1;
    continue;
  }
  bad.push({ ...c, why: conclusions });
}

const short = (c) => `${c.sha.slice(0, 7)}  ${c.date}  ${c.subject.slice(0, 62)}`;

console.log(`\nDeploy sweep - ${commits.length} merge commit(s) on origin/main\n`);

if (bad.length) {
  console.log(`  ${bad.length} DID NOT DEPLOY:\n`);
  for (const c of bad) console.log(`    ${short(c)}\n        ${c.why}`);
  console.log('');
}
if (pending.length) {
  console.log(`  ${pending.length} still building:\n`);
  for (const c of pending) console.log(`    ${short(c)}`);
  console.log('');
}

if (!bad.length) {
  console.log(`  ${ok} deployed${pending.length ? `, ${pending.length} still building` : ''}. NOTHING MISSING.\n`);
} else {
  console.log('  The site is serving the last build that compiled. Find the first bad');
  console.log('  commit above, then look for a file under functions/ - or anything one');
  console.log('  of them imports - using syntax the build image\'s wrangler rejects.');
  console.log('  SETUP.md -> "When the merge does not deploy".\n');
}
