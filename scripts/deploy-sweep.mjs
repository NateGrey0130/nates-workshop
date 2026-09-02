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
// TWO HALVES, because this site deploys two ways. Everything above is Pages.
// `workers/pick3cut5-room` is a standalone Worker deployed by hand, produces no
// check-run at all, and was invisible to the first version of this script -
// which printed NOTHING MISSING while saying nothing about it (HEALTH-AUDIT
// F23). The second section below compares timestamps instead.
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
import { execFileSync, spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = 'NateGrey0130/nates-workshop';

const args = process.argv.slice(2);
const all = args.includes('--all');
const lastFlag = args.indexOf('--last');
const limit = lastFlag !== -1 ? Number(args[lastFlag + 1]) : 20;
if (!all && (!Number.isInteger(limit) || limit < 1)) {
  console.error('usage: node scripts/deploy-sweep.mjs [--last N | --all]');
  process.exit(2);
}

const run = (cmd, cmdArgs, opts = {}) =>
  execFileSync(cmd, cmdArgs, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], ...opts });

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
  // "Pages:" is load bearing. Unqualified, this line read as a claim about the
  // site while being a claim about one of its two deploy paths.
  console.log(`  Pages: ${ok} deployed${pending.length ? `, ${pending.length} still building` : ''}, nothing missing.\n`);
} else {
  console.log('  The site is serving the last build that compiled. Find the first bad');
  console.log('  commit above, then look for a file under functions/ - or anything one');
  console.log('  of them imports - using syntax the build image\'s wrangler rejects.');
  console.log('  SETUP.md -> "When the merge does not deploy".\n');
}

// ── The half a merge does not deploy ────────────────────────────────────────
//
// Everything above reads PAGES check-runs. workers/pick3cut5-room has none: it
// is a standalone Worker deployed by hand with `wrangler deploy --config`, so
// no merge produces one and the section above is silent about it by
// construction rather than by accident.
//
// A timestamp is the whole check. If the newest commit touching that directory
// on origin/main is newer than the active deployment, main has moved since the
// deploy and party mode may be running something else.
//
// IT CANNOT TELL WHETHER THE CHANGE MATTERED, and that is the accepted cost. A
// `$schema` line fires it exactly as loudly as a rewrite of room.js - the first
// time this comparison was ever run, that is precisely what it caught. A noisy
// true statement was judged better than a silent gap. If that stops being the
// right trade, DELETE this section rather than softening it into something that
// reports less than it knows.
//
// The whole directory, not src/: wrangler.jsonc carries the bindings, the vars
// and the rate-limit numbers, so a config-only change is deploy-relevant too.
const WORKER_DIR = 'workers/pick3cut5-room';
const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..');

console.log(`  ${WORKER_DIR} - deployed by hand, so no check-run exists for it\n`);

try {
  const line = run('git', ['log', '-1', '--format=%h%x09%cI%x09%s', 'origin/main', '--', WORKER_DIR]).trim();
  if (!line) {
    console.log('    no commit has ever touched it on origin/main\n');
  } else {
    const [sha, iso, subject] = line.split('\t');
    // Windows npx is a .cmd that Node refuses to spawn unshelled, and passing
    // args THROUGH a shell is both deprecated (DEP0190) and unescaped. So run
    // npm's own npx-cli.js under this Node with a real argv - the same trick
    // d1-query-lib and d1-apply already use here, for the same reason.
    const wargs = ['wrangler', 'deployments', 'list',
      '--config', `${WORKER_DIR}/wrangler.jsonc`, '--json'];
    const npxCli = join(dirname(process.execPath), 'node_modules', 'npm', 'bin', 'npx-cli.js');
    const r = existsSync(npxCli)
      ? spawnSync(process.execPath, [npxCli, ...wargs], { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e8 })
      : spawnSync('npx', wargs, { cwd: repoRoot, encoding: 'utf8', maxBuffer: 1e8, shell: true });
    if (r.status !== 0) {
      // Prefer the line wrangler marked as the error. Its last lines are a
      // log-file path, so slicing the tail names the log and not the fault.
      const said = ((r.stderr || '') + '\n' + (r.stdout || ''))
        .split(/\r?\n/)
        .map((l) => l.replace(/\u001b\[[0-9;]*m/g, '').trim())
      .filter((l) => l && !/logs were written to|^npm notice/i.test(l));
      const err = said.find((l) => /error|✘|X \[/i.test(l)) || said[0] || 'wrangler failed with no output';
      throw new Error(err);
    }
    const out = r.stdout || '';
    // The npm/wrangler banner precedes the payload, same as d1-query-lib.
    const deployments = JSON.parse(out.slice(out.indexOf('[')));
    const active = deployments[deployments.length - 1];
    if (!active) {
      console.log('    NEVER DEPLOYED - the bindings that reference it resolve to nothing\n');
    } else {
      const commitAt = new Date(iso);
      const deployAt = new Date(active.created_on);
      const version = (active.versions && active.versions[0] && active.versions[0].version_id) || '????????';
      if (commitAt > deployAt) {
        console.log(`    STALE by ${Math.round((commitAt - deployAt) / 60000)} minute(s) - origin/main has moved since the deploy`);
        console.log(`      newest commit  ${sha}  ${commitAt.toISOString()}  ${subject.slice(0, 52)}`);
        console.log(`      deployed       ${version.slice(0, 8)}  ${deployAt.toISOString()}`);
        console.log('');
        console.log('    A timestamp cannot say whether that change mattered. Read the diff,');
        console.log('    then either deploy it or decide it does not need deploying:');
        console.log(`      git log --oneline ${sha} -1 -- ${WORKER_DIR}`);
        console.log(`      npx wrangler deploy --config ${WORKER_DIR}/wrangler.jsonc\n`);
      } else {
        console.log(`    up to date - ${version.slice(0, 8)} deployed ${deployAt.toISOString()}`);
        console.log(`    newest commit ${sha} ${commitAt.toISOString()}\n`);
      }
    }
  }
} catch (err) {
  // Unreadable is not "fine". Say so rather than printing nothing, which is the
  // failure mode this whole section exists to end.
  console.log(`    COULD NOT CHECK: ${String(err.message).split('\n')[0].slice(0, 130)}`);
  console.log('    The Worker half of this sweep answered nothing. Do not read the');
  console.log('    Pages result above as covering it.\n');
}
