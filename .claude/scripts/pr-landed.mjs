#!/usr/bin/env node
// pr-landed.mjs - has this pull request merged, and did its merge deploy?
//
//   node .claude/scripts/pr-landed.mjs <pr>          read once
//   node .claude/scripts/pr-landed.mjs <pr> --wait   poll the Pages run, up to two minutes
//
// Prints two lines at most and exits 0 only for MERGED with the merge commit's
// `Cloudflare Pages` check-run at completed/success. Exit 1 is "not yet" (the
// pull request is open, or the build has not concluded); exit 2 is "could not
// read", which is not a pass.
//
// WHY IT EXISTS. `ship-pr` steps 8 and 9 answer this with two `gh` calls and a
// `--jq` filter. A `pr-worker` agent cannot run that shape: its `gh` calls are
// refused when they carry `--jq`, `$(...)`, a pipe or `;`, so every row of the
// 2026-10-12 trial wrote its own throwaway node filter for the same question.
//
// FILTERED TO THE PAGES RUN, for the reason `scripts/deploy-sweep.mjs` gives
// above its own query: another workflow posts check-runs to main too.
//
// `--wait` DOES NOT WAIT FOR CI. It waits only for the Pages build of a commit
// that has already merged, which takes 20-35 seconds. A build that a later
// merge overtook stays pending for good (`ship-pr` -> "The deploy is not
// guaranteed"); two minutes of pending is reported as pending, and
// `node scripts/deploy-sweep.mjs` is the tool that tells skipped from wedged.
import { execFileSync } from 'node:child_process';

const REPO = 'NateGrey0130/nates-workshop';

const args = process.argv.slice(2);
const wait = args.includes('--wait');
const pr = args.find((a) => /^\d+$/.test(a));
if (!pr) {
  console.error('usage: node .claude/scripts/pr-landed.mjs <pr-number> [--wait]');
  process.exit(2);
}

const gh = (ghArgs) => JSON.parse(
  execFileSync('gh', ghArgs, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }));

const sleep = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);

let view;
try {
  view = gh(['pr', 'view', pr, '--repo', REPO, '--json', 'state,mergeCommit,statusCheckRollup']);
} catch (err) {
  console.error(`PR ${pr}: unreadable - ${String(err.message).split('\n')[0]}`);
  process.exit(2);
}

if (view.state !== 'MERGED') {
  const checks = (view.statusCheckRollup || [])
    .map((c) => `${c.name || c.context}=${c.conclusion || c.state || c.status || 'pending'}`)
    .join(' ');
  console.log(`PR ${pr}: ${view.state}`);
  console.log(`checks: ${checks || 'none reported'}`);
  process.exit(1);
}

const sha = view.mergeCommit.oid;
const pagesState = () => {
  const runs = gh(['api', `repos/${REPO}/commits/${sha}/check-runs`]).check_runs
    .filter((r) => r.name === 'Cloudflare Pages');
  return runs.length === 0 ? 'NO RUN' : `${runs[0].status}/${runs[0].conclusion ?? 'pending'}`;
};

let pages;
const deadline = Date.now() + 120000;
for (;;) {
  try {
    pages = pagesState();
  } catch (err) {
    console.error(`PR ${pr}: MERGED ${sha.slice(0, 8)}, check-runs unreadable - ${String(err.message).split('\n')[0]}`);
    process.exit(2);
  }
  if (pages === 'completed/success' || !wait || Date.now() > deadline) break;
  // A conclusion other than success will not change by waiting for it.
  if (pages.startsWith('completed/')) break;
  sleep(10000);
}

console.log(`PR ${pr}: MERGED ${sha.slice(0, 8)}`);
console.log(`Pages: ${pages}`);
process.exit(pages === 'completed/success' ? 0 : 1);
