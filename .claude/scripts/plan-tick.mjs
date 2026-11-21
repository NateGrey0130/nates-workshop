#!/usr/bin/env node
// plan-tick.mjs - one verdict per armed plan, and the driver lock.
//
//   node .claude/scripts/plan-tick.mjs                    one line per armed plan: <plan>: <VERDICT> <detail>
//   node .claude/scripts/plan-tick.mjs --claim <plan>     write driver.lock (time, the caller's pid); exit 1 without writing on LIVE
//   node .claude/scripts/plan-tick.mjs --heartbeat <plan> rewrite the lock's time
//   node .claude/scripts/plan-tick.mjs --release <plan>   delete driver.lock
//   node .claude/scripts/plan-tick.mjs --arm <plan>       write the plan's `armed` file
//   node .claude/scripts/plan-tick.mjs --disarm <plan>    delete it
//   node .claude/scripts/plan-tick.mjs --root <dir>       another plans directory
//
// A plan is armed only while a file named `armed` sits in its folder. Unarmed
// plans are never printed, claimed or driven. The verdicts and their order are
// in plan-tick-lib.mjs beside this file, which reads nothing itself.
//
// What it reads: each armed plan's state.md first line, the brief of the row
// it names next, driver.lock, the newest write to any .git/worktrees/*/index
// or logs/HEAD (only when a lock exists), and one
// `gh pr list --state open --json number,headRefName,statusCheckRollup`.
//
// Exit 0 is every armed plan given a verdict. Exit 2 is a reading that failed:
// that plan's line says UNKNOWN and why, and no verdict is guessed for it.
// --claim exits 1 when the plan is LIVE or not armed, and 2 on UNKNOWN.
import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync, unlinkSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { decide, lockText, parseLock, parseState, verdictLine } from './plan-tick-lib.mjs';

const REPO = 'NateGrey0130/nates-workshop';
const DEFAULT_ROOT = join(homedir(), '.claude', 'projects', 'C--Users-natha-Projects-nates-apps', 'memory', 'plans');
const HERE = dirname(fileURLToPath(import.meta.url));

const args = process.argv.slice(2);
const valueOf = (name) => { const i = args.indexOf(name); return i === -1 ? null : args[i + 1] ?? ''; };
const ACTIONS = ['--claim', '--heartbeat', '--release', '--arm', '--disarm'];
const actions = ACTIONS.filter((a) => args.includes(a));
const root = valueOf('--root') ?? DEFAULT_ROOT;
const known = new Set([...ACTIONS, '--root']);
const stray = args.filter((a, i) => a.startsWith('--') ? !known.has(a) : !known.has(args[i - 1]));

if (args.includes('--help') || actions.length > 1 || stray.length) {
  console.error('usage: node .claude/scripts/plan-tick.mjs [--claim|--heartbeat|--release|--arm|--disarm <plan>] [--root <dir>]');
  process.exit(2);
}
if (!existsSync(root)) {
  console.error(`plan-tick: UNKNOWN no plans directory at ${root}`);
  process.exit(2);
}

const planDir = (plan) => join(root, plan);
const lockPath = (plan) => join(planDir(plan), 'driver.lock');
const armedPath = (plan) => join(planDir(plan), 'armed');

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

let pulls;
let pullsError = null;
function openPulls() {
  if (pulls !== undefined) return pulls;
  try {
    pulls = JSON.parse(execFileSync('gh',
      ['pr', 'list', '--repo', REPO, '--state', 'open', '--limit', '200', '--json', 'number,headRefName,statusCheckRollup'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], maxBuffer: 64 * 1024 * 1024 }));
    if (!Array.isArray(pulls)) throw new Error('gh pr list did not return a list');
  } catch (err) {
    pulls = null;
    pullsError = `gh pr list failed: ${String(err.message).split('\n')[0]}`;
  }
  return pulls;
}

// One plan's verdict, or UNKNOWN with the reading that failed.
function tick(plan) {
  try {
    const statePath = join(planDir(plan), 'state.md');
    if (!existsSync(statePath)) throw new ReadFailure('no state.md');
    const stateText = readFileSync(statePath, 'utf8');
    const state = parseState(stateText);
    let brief = null;
    if (state.nextId !== null && state.kind === 'NEXT') {
      const path = join(planDir(plan), 'rows', `${state.nextId}.md`);
      brief = existsSync(path) ? { exists: true, text: readFileSync(path, 'utf8') } : { exists: false, text: '' };
    }
    let lock = null;
    if (existsSync(lockPath(plan))) {
      lock = parseLock(readFileSync(lockPath(plan), 'utf8'));
      if (!lock) throw new ReadFailure('driver.lock does not parse as {"time", "pid"}');
    }
    const gitMovedMs = lock ? newestWorktreeWrite() : null;
    const live = state.kind === 'READY' || state.kind === 'NEXT';
    const result = decide({ stateText, brief, lock, gitMovedMs, pulls: live ? openPulls() : null, now: Date.now() });
    if (result.verdict === 'UNKNOWN') return { verdict: 'UNKNOWN', detail: pullsError ?? result.detail };
    return result;
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
  } else if (action === '--release') {
    if (existsSync(lockPath(plan))) unlinkSync(lockPath(plan));
    console.log(`${plan}: driver.lock released`);
  } else if (action === '--heartbeat') {
    const lock = existsSync(lockPath(plan)) ? parseLock(readFileSync(lockPath(plan), 'utf8')) : null;
    if (!lock) {
      console.error(`${plan}: no driver.lock to beat (claim it first)`);
      process.exit(1);
    }
    writeFileSync(lockPath(plan), lockText(Date.now(), lock.pid), 'utf8');
    console.log(`${plan}: heartbeat`);
  } else {
    if (!existsSync(armedPath(plan))) {
      console.log(`${plan}: not armed; not claimed`);
      process.exit(1);
    }
    const result = tick(plan);
    console.log(verdictLine(plan, result));
    if (result.verdict === 'UNKNOWN') process.exit(2);
    if (result.verdict === 'LIVE') {
      console.log(`${plan}: not claimed`);
      process.exit(1);
    }
    // The pid is the caller's (the driver's shell), since this process ends now.
    // With no lock on disk the write is exclusive, so two ticks racing on a
    // free plan cannot both claim it; a stale lock is overwritten.
    const hadLock = existsSync(lockPath(plan));
    try {
      writeFileSync(lockPath(plan), lockText(Date.now(), process.ppid), { encoding: 'utf8', flag: hadLock ? 'w' : 'wx' });
    } catch (err) {
      if (err.code !== 'EEXIST') throw err;
      console.log(`${plan}: another claim wrote driver.lock first; not claimed`);
      process.exit(1);
    }
    console.log(`${plan}: claimed (pid ${process.ppid})`);
  }
  process.exit(0);
}

const armed = readdirSync(root, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(armedPath(d.name)))
  .map((d) => d.name)
  .sort();
if (!armed.length) console.error('plan-tick: no plan is armed');
let unknown = false;
for (const plan of armed) {
  const result = tick(plan);
  if (result.verdict === 'UNKNOWN') unknown = true;
  console.log(verdictLine(plan, result));
}
process.exit(unknown ? 2 : 0);
