#!/usr/bin/env node
// plan-tick.mjs - one verdict per armed plan, and the driver lock.
//
//   node .claude/scripts/plan-tick.mjs                    one line per armed plan: <plan>: <VERDICT> <detail>
//   node .claude/scripts/plan-tick.mjs --claim <plan>     write driver.lock and print its owner id; exit 1 without
//                                                         writing unless the verdict is DRIVE, MERGE-FIRST,
//                                                         ADVANCE or RESUME
//   node .claude/scripts/plan-tick.mjs --heartbeat <plan> --owner <id>   rewrite the lock's time
//   node .claude/scripts/plan-tick.mjs --release <plan> --owner <id>     delete driver.lock
//   node .claude/scripts/plan-tick.mjs --arm <plan>       write the plan's `armed` file
//   node .claude/scripts/plan-tick.mjs --disarm <plan>    delete it
//   node .claude/scripts/plan-tick.mjs --root <dir>       another plans directory
//   --session <id>      with --claim: the Claude session to watch (default $CLAUDE_CODE_SESSION_ID)
//   --transcripts <dir> where session transcripts live (default ~/.claude/projects)
//
// The lock names an owner, a random id the claim prints. --heartbeat and
// --release with another owner's id exit 1 and change nothing. Without
// --owner they still act, for one row of the tick-fix plan (Nate, 2026-11-21)
// while the plan-rows skill learns to pass it.
//
// A plan is armed only while a file named `armed` sits in its folder. Unarmed
// plans are never printed, claimed or driven. The verdicts and their order are
// in plan-tick-lib.mjs beside this file, which opens nothing itself.
//
// What it reads: each armed plan's state.md first line, the brief of the row
// it names next (or the stopped row's, for its `From row <id>: attempt <n>`
// lines), driver.lock, and only when a lock exists the newest write to
// any .git/worktrees/*/index or logs/HEAD and to the lock's session transcript
// (<transcripts>/*/<session>.jsonl and <transcripts>/*/<session>/subagents/*.jsonl),
// and one `gh pr list --state open --json number,headRefName,headRefOid,statusCheckRollup`
// and one `gh pr list --state merged --limit 30 --json number,headRefName,mergedAt`,
// so a row merged by a driver that died before writing state.md is ADVANCE.
//
// One driver across every plan: while any armed plan is LIVE, another plan's
// DRIVE, MERGE-FIRST, ADVANCE or RESUME prints as `WAIT <plan> is live`, and
// --claim on it exits 1. A driver.lock that does not parse is a stale lock,
// named in the detail. An UNKNOWN on the same plan on 4 consecutive bare ticks
// prints STOP, so the driver writes a BLOCKED line: the run is counted in an
// `unknown.count` file beside `armed`, which any verdict deletes. --claim
// neither reads nor writes that count.
//
// Exit 0 is every armed plan given a verdict. Exit 2 is a reading that failed:
// that plan's line says UNKNOWN and why, and no verdict is guessed for it.
// --claim exits 1 when the plan is not armed or its verdict is anything but
// DRIVE, MERGE-FIRST, ADVANCE or RESUME, and 2 on UNKNOWN.
import { execFileSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import * as fs from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { CLAIMABLE, beatLock, claimLock, countUnknown, decide, lockText, oneDriver, parseLock, parseState, releaseLock,
  validId, verdictLine } from './plan-tick-lib.mjs';

const { existsSync, readdirSync, readFileSync, statSync, unlinkSync, writeFileSync } = fs;
const REPO = 'NateGrey0130/nates-workshop';
const DEFAULT_ROOT = join(homedir(), '.claude', 'projects', 'C--Users-natha-Projects-nates-apps', 'memory', 'plans');
const HERE = dirname(fileURLToPath(import.meta.url));

const args = process.argv.slice(2);
const valueOf = (name) => { const i = args.indexOf(name); return i === -1 ? null : args[i + 1] ?? ''; };
const ACTIONS = ['--claim', '--heartbeat', '--release', '--arm', '--disarm'];
const actions = ACTIONS.filter((a) => args.includes(a));
const root = valueOf('--root') ?? DEFAULT_ROOT;
const transcripts = valueOf('--transcripts') ?? join(homedir(), '.claude', 'projects');
const owner = valueOf('--owner');
const known = new Set([...ACTIONS, '--root', '--owner', '--session', '--transcripts']);
const stray = args.filter((a, i) => a.startsWith('--') ? !known.has(a) : !known.has(args[i - 1]));

if (args.includes('--help') || actions.length > 1 || stray.length) {
  console.error('usage: node .claude/scripts/plan-tick.mjs [--claim <plan> [--session <id>] | --heartbeat|--release <plan> --owner <id> | --arm|--disarm <plan>] [--root <dir>] [--transcripts <dir>]');
  process.exit(2);
}
if (owner !== null && !validId(owner)) {
  console.error(`plan-tick: --owner "${owner}" is not an owner id`);
  process.exit(2);
}
if (!existsSync(root)) {
  console.error(`plan-tick: UNKNOWN no plans directory at ${root}`);
  process.exit(2);
}

const planDir = (plan) => join(root, plan);
const lockPath = (plan) => join(planDir(plan), 'driver.lock');
const armedPath = (plan) => join(planDir(plan), 'armed');
const unknownPath = (plan) => join(planDir(plan), 'unknown.count');
const armedPlans = () => readdirSync(root, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(armedPath(d.name)))
  .map((d) => d.name)
  .sort();

class ReadFailure extends Error {}

// The newest worktree index or logs/HEAD write, from the shared git directory.
let gitMoved;
function newestWorktreeWrite() {
  if (gitMoved !== undefined) return gitMoved;
  let common;
  try {
    common = execFileSync('git', ['rev-parse', '--path-format=absolute', '--git-common-dir'],
      { cwd: HERE, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  } catch (err) {
    throw new ReadFailure(`git rev-parse failed: ${String(err.message).split('\n')[0]}`);
  }
  const dir = join(common, 'worktrees');
  let newest = null;
  if (existsSync(dir)) {
    for (const tree of readdirSync(dir)) {
      for (const file of [join(dir, tree, 'index'), join(dir, tree, 'logs', 'HEAD')]) {
        if (existsSync(file)) newest = Math.max(newest ?? 0, statSync(file).mtimeMs);
      }
    }
  }
  gitMoved = newest;
  return newest;
}

// The newest write to the session's transcript, or null when none is found:
// the session's own JSONL in any project folder (a worktree session has a
// folder of its own), or a subagent's JSONL under it, which is where a worker
// the driver is waiting on writes.
function newestTranscriptWrite(session) {
  if (!session || !existsSync(transcripts)) return null;
  let newest = null;
  const consider = (file) => {
    try { newest = Math.max(newest ?? 0, statSync(file).mtimeMs); } catch (err) { if (err.code !== 'ENOENT') throw err; }
  };
  for (const project of readdirSync(transcripts, { withFileTypes: true })) {
    if (!project.isDirectory()) continue;
    consider(join(transcripts, project.name, `${session}.jsonl`));
    const subagents = join(transcripts, project.name, session, 'subagents');
    if (existsSync(subagents)) {
      for (const f of readdirSync(subagents)) if (f.endsWith('.jsonl')) consider(join(subagents, f));
    }
  }
  return newest;
}

// One gh read per state per run, cached; a failure is null and its reason,
// which the plan's line prints as UNKNOWN.
const pullReads = new Map();
function readPulls(state, limit, fields) {
  if (!pullReads.has(state)) {
    let list = null, error = null;
    try {
      list = JSON.parse(execFileSync('gh',
        ['pr', 'list', '--repo', REPO, '--state', state, '--limit', String(limit), '--json', fields],
        { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], maxBuffer: 64 * 1024 * 1024 }));
      if (!Array.isArray(list)) throw new Error('gh pr list did not return a list');
    } catch (err) {
      list = null;
      error = `gh pr list --state ${state} failed: ${String(err.message).split('\n')[0]}`;
    }
    pullReads.set(state, { list, error });
  }
  return pullReads.get(state);
}
const openPulls = () => readPulls('open', 200, 'number,headRefName,headRefOid,statusCheckRollup');
const mergedPulls = () => readPulls('merged', 30, 'number,headRefName,mergedAt');

// One plan's verdict, or UNKNOWN with the reading that failed.
function tick(plan) {
  try {
    const statePath = join(planDir(plan), 'state.md');
    if (!existsSync(statePath)) throw new ReadFailure('no state.md');
    const stateText = readFileSync(statePath, 'utf8');
    const state = parseState(stateText);
    let brief = null;
    // NEXT's row, or a STOPPED row, whose brief carries its attempt lines.
    if (state.nextId !== null && (state.kind === 'NEXT' || state.kind === 'STOPPED')) {
      const path = join(planDir(plan), 'rows', `${state.nextId}.md`);
      brief = existsSync(path) ? { exists: true, text: readFileSync(path, 'utf8') } : { exists: false, text: '' };
    }
    let lock = null;
    let lockRaw = null;
    if (existsSync(lockPath(plan))) {
      // A lock that does not parse names no owner and no time: stale. lockRaw
      // keeps its text, so a claim renames exactly that text aside.
      lockRaw = readFileSync(lockPath(plan), 'utf8');
      lock = parseLock(lockRaw);
    }
    const badLock = lockRaw !== null && !lock;
    const gitMovedMs = lock ? newestWorktreeWrite() : null;
    const transcriptMs = lock ? newestTranscriptWrite(lock.session) : null;
    const live = state.kind === 'READY' || state.kind === 'NEXT';
    const open = live ? openPulls() : null;
    const merged = live ? mergedPulls() : null;
    const result = decide({ stateText, brief, lock, badLock, gitMovedMs, transcriptMs, pulls: open?.list ?? null, merged: merged?.list ?? null, now: Date.now() });
    if (result.verdict === 'UNKNOWN') return { verdict: 'UNKNOWN', detail: open?.error ?? merged?.error ?? result.detail };
    return { ...result, lockRaw };
  } catch (err) {
    return { verdict: 'UNKNOWN', detail: err instanceof ReadFailure ? err.message : `read failed: ${String(err.message).split('\n')[0]}` };
  }
}

const action = actions[0];
if (action) {
  const plan = valueOf(action);
  if (!plan || plan.startsWith('--') || /[\\/]|^\.\.?$/.test(plan) || !existsSync(join(planDir(plan), 'state.md'))) {
    console.error(`plan-tick: no plan "${plan}" with a state.md under ${root}`);
    process.exit(2);
  }
  if (action === '--arm') {
    writeFileSync(armedPath(plan), `armed ${new Date().toISOString()}\n`, 'utf8');
    console.log(`${plan}: armed`);
  } else if (action === '--disarm') {
    if (existsSync(armedPath(plan))) unlinkSync(armedPath(plan));
    console.log(`${plan}: disarmed`);
  } else if (action === '--release' || action === '--heartbeat') {
    const r = action === '--release' ? releaseLock(fs, lockPath(plan), owner) : beatLock(fs, lockPath(plan), owner, Date.now());
    if (!r.ok) {
      console.error(`${plan}: ${r.why}; nothing changed`);
      process.exit(1);
    }
    const legacy = owner === null ? ' (no --owner given: accepted for now, pass the id --claim printed)' : '';
    console.log(`${plan}: ${action === '--release' ? (r.why || 'driver.lock released') : 'heartbeat'}${legacy}`);
  } else {
    if (!existsSync(armedPath(plan))) {
      console.log(`${plan}: not armed; not claimed`);
      process.exit(1);
    }
    const session = valueOf('--session') ?? process.env.CLAUDE_CODE_SESSION_ID ?? null;
    if (session !== null && !validId(session)) {
      console.error(`plan-tick: session "${session}" is not a session id`);
      process.exit(2);
    }
    // The other armed plans are read too: one of them LIVE makes this one WAIT.
    const all = [{ plan, result: tick(plan) }, ...armedPlans().filter((p) => p !== plan).map((p) => ({ plan: p, result: tick(p) }))];
    const { result } = oneDriver(all)[0];
    console.log(verdictLine(plan, result));
    if (result.verdict === 'UNKNOWN') process.exit(2);
    if (!CLAIMABLE.includes(result.verdict)) {
      console.log(`${plan}: not claimed (only ${CLAIMABLE.join(' or ')} is claimed)`);
      process.exit(1);
    }
    const id = randomBytes(8).toString('hex');
    const r = claimLock(fs, lockPath(plan), { seen: result.lockRaw, text: lockText(Date.now(), id, session), owner: id });
    if (!r.ok) {
      console.log(`${plan}: ${r.why}; not claimed`);
      process.exit(1);
    }
    console.log(`${plan}: claimed (owner ${id}${session ? `, session ${session}` : ', no session: liveness falls back to the heartbeat'})`);
    console.log(`${plan}: pass --owner ${id} to --heartbeat and --release`);
  }
  process.exit(0);
}

const armed = armedPlans();
if (!armed.length) console.error('plan-tick: no plan is armed');
const counted = armed.map((plan) => {
  const path = unknownPath(plan);
  const { count, result } = countUnknown(existsSync(path) ? readFileSync(path, 'utf8') : null, tick(plan));
  if (count) writeFileSync(path, `${count}\n`, 'utf8');
  else if (existsSync(path)) unlinkSync(path);
  return { plan, result };
});
let unknown = false;
for (const { plan, result } of oneDriver(counted)) {
  if (result.verdict === 'UNKNOWN') unknown = true;
  console.log(verdictLine(plan, result));
}
process.exit(unknown ? 2 : 0);
