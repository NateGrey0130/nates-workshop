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
// well for months, so the mark there carries no information. The check-runs on
// the commit that LANDED ON MAIN are the signal.
//
// WHY --first-parent AND NOT --merges. This walked `--merges` until 2026-09-03,
// so it saw merge commits and nothing else - and this repo has 117 SQUASH
// merges on main, spanning 2026-08-16 to 2026-08-31, which `--merges` returns
// none of. Three were checked directly: all carry a real `Cloudflare Pages`
// check-run and this script read none of them. A squash-merged deploy failure
// was invisible here - the four-day outage's failure mode reached by another
// route (REPO-AUDIT.md G5).
//
// `--first-parent` is the fix rather than adding squash detection, because the
// question is not "how did this land" but "was this a state main was in".
// Every first-parent commit is one, whatever produced it - a merge commit, a
// squash, or a direct push - and each triggered a build that either succeeded
// or did not. The squash BUTTON stays enabled: that is a separate decision, and
// disabling it would not have fixed the 117 already on main.
//
// Report only. This never moves the exit code, for the same reason
// repo-vs-live.mjs does not: a failed deploy needs a person to look at it, and
// a script that exits non-zero on a four-day-old failure would fail every run
// until someone fixed history. It prints, you read.
//
// A deploy takes up to a minute or so to finish. A merge made seconds ago
// reports `in_progress` with no conclusion yet - that is reported as PENDING,
// which is not a failure and not a pass. Run it again.
//
// AND A CHECK-RUN THAT NEVER CONCLUDES IS A THIRD THING. Cloudflare skips a
// production deployment that a later one overtakes, and the skipped build's
// check-run says "Building" for good. Running it again does not help; ageing
// it says only that it is old. This script called four of those stuck at 498
// minutes and told a reader to delete a deployment to release a queue that did
// not exist. The classifier for that sits above the STALLED report below, and
// it is the one place here that reasons about a commit's NEIGHBOURS rather
// than about the commit.
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

const logArgs = ['log', '--first-parent', '--format=%H%x09%ad%x09%s', '--date=short'];
if (!all) logArgs.push(`-${limit}`);
logArgs.push('origin/main');

const commits = run('git', logArgs).trim().split('\n').filter(Boolean).map((line) => {
  const [sha, date, subject] = line.split('\t');
  return { sha, date, subject };
});

if (commits.length === 0) {
  console.log('No commits on origin/main.');
  process.exit(0);
}

const bad = [];
const pending = [];
// Which commits DEPLOYED, keyed by index into `commits` - which is
// `--first-parent` order, newest first. The supersession test below is the only
// reader, and an index is all it needs: a smaller index is a later build.
const deployed = new Set();
let ok = 0;

for (const [idx, c] of commits.entries()) {
  let conclusions;
  let deployId = null;
  try {
    const out = run('gh', [
      'api', `repos/${REPO}/commits/${c.sha}/check-runs`,
      // `started_at` rides along so a pending run can be AGED. Without it a
      // build twenty seconds old and one wedged for half an hour print the
      // same line - which is how a stalled deploy read as healthy here for 32
      // minutes on 2026-09-02 (HEALTH-AUDIT F24).
      //
      // FILTERED TO THE PAGES RUN, and it has to be. This read EVERY check-run
      // on the commit and failed the commit if any of them failed. That was
      // harmless while Pages was the only thing posting one, and stopped being
      // harmless on 2026-09-03 when `deploy-alarm.yml` started posting
      // `check-recent-deploys` to main. Its first run was buggy and red, and
      // this script then reported `1ce6ea9` as DID NOT DEPLOY while the same
      // line showed `Cloudflare Pages=success` - a deploy monitor calling a
      // successful deploy a failure because a different monitor had failed.
      // Two tools feeding each other false alarms is precisely how a check
      // stops being read. The header above already says the Pages run is the
      // signal; now the query agrees with it.
      //
      // `details_url` rides along for its UUID: it is the Pages DEPLOYMENT id,
      // and it is the thing you actually need to ask Cloudflare about one
      // build. Both remedies below used to send you paging the whole
      // deployments list to find by hand what the check-run had all along.
      '--jq', '[.check_runs[] | select(.name=="Cloudflare Pages") | .name + "=" + (.conclusion // "pending") + "@" + (.started_at // "") + "#" + (.details_url // "")] | join(",")',
    ]).trim();
    deployId = out.match(/[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}/)?.[0] ?? null;
    // Strip the URLs back out for matching and display. Every test below is a
    // substring or regex over this string, and a failure line prints it raw.
    conclusions = out.replace(/#[^,]*/g, '');
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
    // A check-run that has not concluded. It is aged here and SORTED LATER -
    // pending has three meanings and the age alone separates only two of them.
    // A build here finishes in 20-35 seconds, so ten minutes is not "slow";
    // but a check-run that never concludes at all is not slow either, and for
    // eight hours this script called that one stuck. See the classifier below.
    const started = conclusions.match(/=pending@([^,]+)/)?.[1];
    const mins = started ? Math.floor((Date.now() - Date.parse(started)) / 60000) : null;
    pending.push({ ...c, idx, why: conclusions, mins, deployId });
    continue;
  }
  if (conclusions.includes('=success') && !/=(failure|cancelled|timed_out|action_required)/.test(conclusions)) {
    deployed.add(idx);
    ok += 1;
    continue;
  }
  bad.push({ ...c, why: conclusions });
}

const short = (c) => `${c.sha.slice(0, 7)}  ${c.date}  ${c.subject.slice(0, 62)}`;

console.log(`\nDeploy sweep - ${commits.length} first-parent commit(s) on origin/main\n`);

if (bad.length) {
  console.log(`  ${bad.length} DID NOT DEPLOY:\n`);
  for (const c of bad) console.log(`    ${short(c)}\n        ${c.why}`);
  console.log('');
}
// Ten minutes. A Pages build on this project takes 20-35 seconds, so this is
// not a tight threshold - it is twenty times the normal run.
const STALLED_MINS = 10;

// ── SUPERSEDED IS NOT STUCK ─────────────────────────────────────────────────
//
// Four production merges landed within 17 seconds of each other on 2026-09-04
// (#714-#717). Cloudflare collapsed the queue and SKIPPED the three it
// overtook plus the first - `latest_stage.name=queued`, `.status=skipped` on
// all four - and a skipped deployment's check-run never concludes. It sits at
// `in_progress` / "Building" forever.
//
// That is bit-for-bit the signature this script called stuck. It reported all
// four as PENDING FOR OVER 10 MINUTES at 498 minutes and printed the wedged-
// preview remedy: delete the blocking deployment to release the queue. There
// was no queue to release, nothing was missing, and deleting is a destructive
// action advised on a false premise.
//
// THE ANSWER WAS ALREADY IN HAND. A Pages build publishes the whole repo root
// at its commit, and `--first-parent` order is newest first. So a pending
// commit that has a NEWER commit reporting `success` HAS SHIPPED - the later
// build published a tree containing it. That holds whether its own deployment
// was skipped or wedged, which is exactly why the conclusion does not need
// Cloudflare's `latest_stage` to reach it. What the sweep loses by not asking
// is the reason; what it keeps is the only fact that decides anything, which
// is whether the content is on the site.
//
// IT CANNOT QUIET A REAL OUTAGE, and that is the property to preserve:
//   - A genuinely wedged build BLOCKS the queue. Nothing behind it succeeds,
//     so nothing behind it is superseded, and it prints below at full volume -
//     32 minutes of exactly that on 2026-09-02 (HEALTH-AUDIT F24).
//   - The four-day August outage never reaches this path at all. Those 65
//     commits CONCLUDED `failure`; they are `bad`, printed first and loudest.
// Supersession can only ever quieten a commit that a later build carried.
//
// WHY THIS DOES NOT ASK CLOUDFLARE: because a script here cannot. The
// `cloudflare-api` MCP plugin reaches Pages and `node` cannot call it, and the
// environment `CLOUDFLARE_API_TOKEN` - the only credential a script in this
// repo has - is refused. Measured 2026-09-05: `/pages/projects`, the
// deployments list, and a single deployment by id all return HTTP 403
// `code: 10000`, matching what CLAUDE.md -> "Three credentials" says of
// `pages project list`. A sweep that silently needed a credential the repo's
// own token does not have would be a worse trap than the one it replaced.
const supersededBy = (c) => {
  // The NEAREST later success, not the newest: that is the build that first
  // carried this commit's content onto the site.
  for (let j = c.idx - 1; j >= 0; j -= 1) if (deployed.has(j)) return commits[j];
  return null;
};
const superseded = [];
const stalled = [];
const building = [];
for (const c of pending) {
  const by = supersededBy(c);
  if (by) superseded.push({ ...c, by });
  else if (c.mins !== null && c.mins >= STALLED_MINS) stalled.push(c);
  else building.push(c);
}

if (building.length) {
  console.log(`  ${building.length} still building:\n`);
  for (const c of building) {
    console.log(`    ${short(c)}${c.mins !== null ? `  (${c.mins}m)` : ''}`);
  }
  console.log('');
}
if (superseded.length) {
  // Reported, not dropped. The content is on the site, so this is not a
  // failure - but a merge whose own deployment never ran is a thing to have
  // seen, and silence here would be indistinguishable from the sweep not
  // having looked.
  console.log(`  ${superseded.length} superseded - never built, and shipped anyway:\n`);
  for (const c of superseded) {
    console.log(`    ${short(c)}  (${c.mins}m)`);
    console.log(`        carried by ${c.by.sha.slice(0, 7)}, which deployed after it`);
  }
  console.log('');
  console.log('  Merges seconds apart share one production queue and Cloudflare skips the');
  console.log('  ones a later build overtakes - latest_stage.name=queued, status=skipped -');
  console.log('  leaving a check-run that says "Building" forever. NOTHING IS MISSING: a');
  console.log('  build publishes the whole repo root, so the later commit carried these');
  console.log('  too. Do not delete anything. To read the stage itself, the cloudflare-api');
  console.log('  MCP plugin can (CLAUDE.md -> "Three credentials"); this script cannot,');
  console.log('  because CLOUDFLARE_API_TOKEN gets 403 from every Pages endpoint:\n');
  for (const c of superseded.filter((x) => x.deployId)) {
    console.log(`    GET /accounts/{id}/pages/projects/nates-workshop/deployments/${c.deployId}`);
  }
  console.log('');
}
if (stalled.length) {
  console.log(`  ${stalled.length} PENDING FOR OVER ${STALLED_MINS} MINUTES - probably stuck:\n`);
  for (const c of stalled) console.log(`    ${short(c)}  (${c.mins}m)`);
  console.log('');
  console.log('  A build here normally takes 20-35 seconds, and nothing newer has deployed');
  console.log('  past these - so unlike a superseded build, this content is NOT on the');
  console.log('  site. Previews and production share one queue, so the usual cause is a');
  console.log('  wedged PREVIEW ahead of this one, often the preview for the same branch,');
  console.log('  queued by the push seconds before the merge. GitHub reports "Building"');
  console.log('  for a deployment Cloudflare has not started; ask Cloudflare for the real');
  console.log('  stage, which the cloudflare-api MCP plugin can do and this script cannot:\n');
  for (const c of stalled.filter((x) => x.deployId)) {
    console.log(`    GET /accounts/{id}/pages/projects/nates-workshop/deployments/${c.deployId}`);
  }
  console.log('    -> latest_stage.name + .status');
  console.log('');
  console.log('  CHECK THAT STAGE BEFORE DELETING ANYTHING. `queued`/`skipped` means');
  console.log('  Cloudflare dropped it and there is no queue to release. A build wedged in');
  console.log('  `queued` or `initialize` with an empty log is the real one, and deleting');
  console.log('  it releases the queue. SETUP.md -> "How deploys work".\n');
}

if (!bad.length) {
  // "Pages:" is load bearing. Unqualified, this line read as a claim about the
  // site while being a claim about one of its two deploy paths.
  // A stalled build is NOT "nothing missing" - the change it carries is not on
  // the site. Saying so is the whole of F24: the old line read identically at
  // twenty seconds and at thirty-two minutes.
  //
  // A SUPERSEDED build is the opposite case and gets counted, not warned
  // about: its content IS on the site. It still gets its own word rather than
  // being folded into `deployed`, because "deployed" would claim a build ran.
  const tail = stalled.length
    ? `, ${stalled.length} STUCK - see above`
    : ', nothing missing.';
  const sup = superseded.length ? `, ${superseded.length} superseded but shipped` : '';
  console.log(`  Pages: ${ok} deployed${sup}${building.length ? `, ${building.length} still building` : ''}${tail}\n`);
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

      // WHICH BUILD IS LIVE, when the deploy recorded it (REPO-AUDIT.md G15).
      //
      // The timestamp comparison below cannot tell whether a change mattered -
      // that is stated at length above and is still true. A sha can: deploy
      // with `--var GIT_SHA:$(git rev-parse HEAD)` and the live Worker carries
      // the commit it was built from, as a plain-text binding readable from the
      // API. Then "is it stale" stops being a guess about clocks and becomes
      // `git log <deployed>..origin/main -- workers/pick3cut5-room`, which is
      // empty or it is not.
      //
      // NO PUBLIC ROUTE, deliberately. The obvious shape was a version endpoint
      // the sweep fetches, but that means a new entry in `PUBLIC_PATHS` and a
      // hole in the site's only wall for a diagnostic. The binding is already
      // readable without one - measured 2026-09-03: the environment token
      // returns HTTP 200 for this settings endpoint, which CLAUDE.md's account
      // of that token does not mention.
      //
      // ABSENT IS NOT AN ERROR. A deploy that omits the var leaves no binding,
      // and this says so and falls through to the timestamp. That is the state
      // the repo is in until the next hand deploy.
      let sinceSha = null;
      let shaNote = null;
      try {
        const acct = process.env.CLOUDFLARE_ACCOUNT_ID;
        const token = process.env.CLOUDFLARE_API_TOKEN;
        if (!acct || !token) {
          shaNote = 'CLOUDFLARE_ACCOUNT_ID / CLOUDFLARE_API_TOKEN not set';
        } else {
          const res = await fetch(
            `https://api.cloudflare.com/client/v4/accounts/${acct}/workers/scripts/pick3cut5-room/settings`,
            { headers: { Authorization: `Bearer ${token}` } },
          );
          if (!res.ok) {
            shaNote = `settings read failed: HTTP ${res.status}`;
          } else {
            const body = await res.json();
            const bind = (body.result?.bindings || []).find((b) => b.name === 'GIT_SHA');
            if (bind && bind.text) sinceSha = bind.text.trim();
            else shaNote = 'the live Worker carries no GIT_SHA binding';
          }
        }
      } catch (err) {
        shaNote = `settings unreadable: ${String(err.message).split('\n')[0]}`;
      }

      if (sinceSha) {
        let behind = '';
        try {
          behind = run('git', ['log', '--oneline', `${sinceSha}..origin/main`, '--', WORKER_DIR]).trim();
        } catch {
          // A sha origin/main has never heard of - a deploy from a branch, or
          // history that moved. Say which rather than reporting "up to date".
          console.log(`    DEPLOYED FROM AN UNKNOWN COMMIT - ${sinceSha.slice(0, 8)} is not on origin/main\n`);
          behind = null;
        }
        if (behind === '') {
          console.log(`    up to date - ${version.slice(0, 8)} deployed from ${sinceSha.slice(0, 8)}`);
          console.log(`    nothing has touched ${WORKER_DIR} since that commit\n`);
        } else if (behind) {
          const lines = behind.split(/\r?\n/);
          console.log(`    STALE - ${lines.length} commit(s) have touched ${WORKER_DIR} since the deploy`);
          console.log(`      deployed from  ${sinceSha.slice(0, 8)}`);
          for (const l of lines.slice(0, 5)) console.log(`      ${l}`);
          if (lines.length > 5) console.log(`      ... and ${lines.length - 5} more`);
          console.log('');
          console.log('    This one is exact - it is not a timestamp guess. Deploy it:');
          console.log(`      npx wrangler deploy --config ${WORKER_DIR}/wrangler.jsonc --var GIT_SHA:$(git rev-parse HEAD)\n`);
        }
      } else if (commitAt > deployAt) {
        console.log(`    (no deployed sha to compare - ${shaNote}; falling back to timestamps)`);
        console.log(`    STALE by ${Math.round((commitAt - deployAt) / 60000)} minute(s) - origin/main has moved since the deploy`);
        console.log(`      newest commit  ${sha}  ${commitAt.toISOString()}  ${subject.slice(0, 52)}`);
        console.log(`      deployed       ${version.slice(0, 8)}  ${deployAt.toISOString()}`);
        console.log('');
        console.log('    A timestamp cannot say whether that change mattered. Read the diff,');
        console.log('    then either deploy it or decide it does not need deploying:');
        console.log(`      git log --oneline ${sha} -1 -- ${WORKER_DIR}`);
        console.log(`      npx wrangler deploy --config ${WORKER_DIR}/wrangler.jsonc --var GIT_SHA:$(git rev-parse HEAD)\n`);
      } else {
        console.log(`    up to date - ${version.slice(0, 8)} deployed ${deployAt.toISOString()}`);
        console.log(`    newest commit ${sha} ${commitAt.toISOString()}`);
        console.log(`    (by timestamp only - ${shaNote}; deploy with --var GIT_SHA:$(git rev-parse HEAD) to make this exact)\n`);
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
