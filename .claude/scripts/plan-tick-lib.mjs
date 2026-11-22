// plan-tick-lib.mjs - the decisions behind plan-tick.mjs, with no file, clock
// or network access, so the smoke suite can drive them with text.
//
// One verdict per armed plan, read from four things: state.md's first line,
// the next row's brief, the plan's driver.lock, and the open pull requests.
// The verdicts, in the order they are tried:
//
//   DONE                  state.md says so
//   BLOCKED <sentence>    state.md says so; a person reads it, nothing drives it
//   LIVE <why>            a driver is working: the lock's heartbeat is fresh, or
//                         the lock exists and a worktree moved or the owner's
//                         transcript was written recently (with no transcript
//                         found, a longer fallback on the heartbeat), or the
//                         row's pull request has a required check pending
//   MERGE-FIRST #<n>      READY names a pull request, or the next row's branch
//                         has an open pull request with every required check passing
//   DRIVE row <id>        the next row has a brief; a red check on its open pull
//                         request is still DRIVE, with the number in the detail
//   STOP <reason>         a missing brief or a first line nothing here can parse
//
// A reading that failed (gh, a file, a lock that does not parse) is never a
// verdict: the script prints UNKNOWN for it and exits 2.

import { parseBrief, parseState } from './plan-board-lib.mjs';

export { parseBrief, parseState };

// The staleness window for the heartbeat, the worktrees and the owner's
// transcript. A dated starting value (2026-11-21, taken on the recommendation
// over 20 or 90 minutes), to be re-measured against real runs.
export const STALE_MS = 30 * 60 * 1000;

// When no transcript is found for the lock's owner, the heartbeat alone keeps
// the lock live for this long (Nate, 2026-11-21: liveness from the owner's
// transcript writes, with a 90-minute fallback; not taken: widening the
// 30-minute window to 90 alone).
export const FALLBACK_MS = 90 * 60 * 1000;

// Only these verdicts can be claimed: a plan that is DONE, BLOCKED, STOP, LIVE
// or UNKNOWN has nothing for a new driver to do.
export const CLAIMABLE = ['DRIVE', 'MERGE-FIRST'];

// main's ruleset 22209348 requires these three.
export const REQUIRED_CHECKS = ['smoke', 'menus', 'regression'];

const PASSING = new Set(['SUCCESS', 'NEUTRAL', 'SKIPPED']);

// The lock is JSON: {"time": ISO string, "owner": id, "session": id or null}.
// `owner` is a random id the claim prints and every later call passes back as
// --owner; `session` is the claiming Claude session, whose transcript writes
// count as the owner being alive. Anything else is null, which the script
// reports as UNKNOWN rather than as no lock. (A pid used to stand where the
// owner is: it was the caller's shell, a new one per call, so it named no one.)
const ID = /^[A-Za-z0-9-]{1,80}$/;
export function parseLock(text) {
  try {
    const lock = JSON.parse(String(text ?? ''));
    const timeMs = Date.parse(lock?.time);
    if (!Number.isFinite(timeMs) || typeof lock.owner !== 'string' || !ID.test(lock.owner)) return null;
    const session = lock.session ?? null;
    if (session !== null && (typeof session !== 'string' || !ID.test(session))) return null;
    return { timeMs, owner: lock.owner, session };
  } catch {
    return null;
  }
}

export function lockText(timeMs, owner, session = null) {
  return `${JSON.stringify({ time: new Date(timeMs).toISOString(), owner, session })}\n`;
}

export const validId = (id) => typeof id === 'string' && ID.test(id);

// The lock-file operations, handed the fs module (or a stand-in) so this file
// still opens nothing itself and the smoke suite can drive them on a temp dir.
// Each returns { ok, why }.
const errCode = (fn) => { try { fn(); return null; } catch (err) { return err.code ?? 'ERROR'; } };

// Claim. `seen` is the lock text the verdict was taken on, null when there was
// no lock. With none, the write is exclusive. Over a stale lock, the lock is
// first renamed aside under a name of this claim's own: only one rename of a
// file can succeed, so a racing claim exits not claimed. If what was renamed is
// not what the verdict read, another claim got there first: it is put back and
// this claim stands down.
export function claimLock(fs, path, { seen, text, owner }) {
  const lost = { ok: false, why: 'another claim wrote driver.lock first' };
  if (seen !== null) {
    const aside = `${path}.${owner}.stale`;
    const code = errCode(() => fs.renameSync(path, aside));
    if (code === 'ENOENT') return lost;
    if (code) throw new Error(`renaming the stale driver.lock failed: ${code}`);
    const taken = fs.readFileSync(aside, 'utf8');
    if (taken !== seen) {
      errCode(() => fs.writeFileSync(path, taken, { encoding: 'utf8', flag: 'wx' }));
      fs.unlinkSync(aside);
      return lost;
    }
    fs.unlinkSync(aside);
  }
  const code = errCode(() => fs.writeFileSync(path, text, { encoding: 'utf8', flag: 'wx' }));
  if (code === 'EEXIST') return lost;
  if (code) throw new Error(`writing driver.lock failed: ${code}`);
  return { ok: true, why: '' };
}

// Read the lock and check the caller holds it. `owner` null is the old,
// ownerless call, still accepted for one row of the tick-fix plan (Nate,
// 2026-11-21) while the skill is rewritten to pass --owner.
function held(fs, path, owner) {
  let text;
  const code = errCode(() => { text = fs.readFileSync(path, 'utf8'); });
  if (code === 'ENOENT') return { lock: null, why: 'no driver.lock' };
  if (code) throw new Error(`reading driver.lock failed: ${code}`);
  const lock = parseLock(text);
  if (!lock) return { lock: null, why: 'driver.lock does not parse' };
  if (owner !== null && lock.owner !== owner) return { lock: null, why: `driver.lock is held by owner ${lock.owner}, not ${owner}` };
  return { lock, why: '' };
}

export function beatLock(fs, path, owner, nowMs) {
  const { lock, why } = held(fs, path, owner);
  if (!lock) return { ok: false, why };
  fs.writeFileSync(path, lockText(nowMs, lock.owner, lock.session), 'utf8');
  return { ok: true, why: '' };
}

// Releasing a lock that is already gone succeeds: the plan is free either way.
export function releaseLock(fs, path, owner) {
  const { lock, why } = held(fs, path, owner);
  if (!lock && why === 'no driver.lock') return { ok: true, why: 'no driver.lock to release' };
  if (!lock && !(owner === null && why === 'driver.lock does not parse')) return { ok: false, why };
  fs.unlinkSync(path);
  return { ok: true, why: '' };
}

// READY: #2317 is open and green.  /  READY: https://github.com/o/r/pull/9 (row 4)
export function readyNumber(first) {
  const m = /^READY:\s*(?:#(\d+)\b|\S*\/pull\/(\d+)\b)/.exec(String(first ?? ''));
  return m ? Number(m[1] ?? m[2]) : null;
}

// statusCheckRollup holds CheckRuns (name, status, conclusion) and
// StatusContexts (context, state). The newest entry per required name counts;
// a required name with no entry yet is pending, since CI has not listed it.
export function requiredChecks(rollup) {
  const newest = new Map();
  (rollup ?? []).forEach((entry, index) => {
    const name = entry?.name ?? entry?.context;
    if (!REQUIRED_CHECKS.includes(name)) return;
    const at = Date.parse(entry.startedAt ?? entry.createdAt ?? '') || 0;
    const held = newest.get(name);
    if (!held || at > held.at || (at === held.at && index > held.index)) newest.set(name, { entry, at, index });
  });
  const pending = [], failing = [], passing = [];
  for (const name of REQUIRED_CHECKS) {
    const entry = newest.get(name)?.entry;
    let outcome;
    if (!entry) outcome = 'pending';
    else if (entry.__typename === 'StatusContext' || ('state' in entry && !('status' in entry))) {
      outcome = entry.state === 'SUCCESS' ? 'pass' : (entry.state === 'PENDING' || entry.state === 'EXPECTED') ? 'pending' : 'fail';
    } else if (entry.status !== 'COMPLETED') outcome = 'pending';
    else outcome = PASSING.has(entry.conclusion) ? 'pass' : 'fail';
    ({ pass: passing, pending, fail: failing })[outcome].push(name);
  }
  return { passing, pending, failing, green: passing.length === REQUIRED_CHECKS.length };
}

const ago = (ms) => `${Math.max(0, Math.floor(ms / 60000))}m`;

// input:
//   stateText     state.md as read
//   brief         { exists, text } for the row state.md names next, or null when it names none
//   lock          null (no driver.lock) or parseLock's answer
//   gitMovedMs    the newest worktree index or logs/HEAD write, in ms, or null
//   transcriptMs  the newest write to the lock owner's session transcript (its
//                 JSONL or a subagent's under it), in ms, or null when none was
//                 found, which falls back to FALLBACK_MS on the heartbeat
//   pulls         the open pull requests from gh, or null when gh was not needed
//   now           ms
// Returns { verdict, detail, state }. UNKNOWN only when the answer turned on
// pull requests that were not given; a fresh lock answers LIVE without them.
export function decide({ stateText, brief = null, lock = null, gitMovedMs = null, transcriptMs = null, pulls = null, now }) {
  const state = parseState(stateText);
  const first = state.first;
  const out = (verdict, detail = '') => ({ verdict, detail, state });

  if (state.kind === 'DONE') return out('DONE');
  if (state.kind === 'BLOCKED') return out('BLOCKED', first.replace(/^BLOCKED:\s*/, ''));

  // The lock answers LIVE on its own, with no pull request read. A driver
  // waiting on a long foreground worker beats no heartbeat and may move no
  // worktree index, but its session's transcript (the worker's included) is
  // still being written.
  if (lock) {
    const lockAge = now - lock.timeMs;
    const beat = `driver.lock heartbeat ${ago(lockAge)} old`;
    if (lockAge < STALE_MS) return out('LIVE', `${beat} (owner ${lock.owner})`);
    if (gitMovedMs !== null && now - gitMovedMs < STALE_MS) {
      return out('LIVE', `${beat}, but a worktree moved ${ago(now - gitMovedMs)} ago`);
    }
    if (transcriptMs !== null && now - transcriptMs < STALE_MS) {
      return out('LIVE', `${beat}, but the owner's transcript was written ${ago(now - transcriptMs)} ago`);
    }
    if (transcriptMs === null && lockAge < FALLBACK_MS) {
      return out('LIVE', `${beat}, no transcript found for the owner, inside the ${ago(FALLBACK_MS)} fallback`);
    }
  }

  // The pull request the plan is waiting on: READY's, or the next row's branch's.
  const briefInfo = brief?.exists ? parseBrief(state.nextId, brief.text) : null;
  const wantedNumber = state.kind === 'READY' ? readyNumber(first) : null;
  const wantedBranch = state.kind === 'NEXT' ? briefInfo?.branch ?? null : null;
  const needsPulls = wantedNumber !== null || wantedBranch !== null;
  if (needsPulls && pulls === null) return out('UNKNOWN', 'pull requests not read');
  const pr = !needsPulls ? null : (pulls.find((p) => (wantedNumber !== null ? p.number === wantedNumber : p.headRefName === wantedBranch)) ?? null);
  const checks = pr ? requiredChecks(pr.statusCheckRollup) : null;

  if (checks?.pending.length) return out('LIVE', `#${pr.number} has ${checks.pending.join(', ')} pending`);
  const staleLock = lock ? `; driver.lock is stale (${ago(now - lock.timeMs)}, owner ${lock.owner})` : '';

  if (state.kind === 'READY') {
    if (wantedNumber === null) {
      return out('STOP', `state.md says READY but names no pull request: "${first}"; nothing else on disk names one`);
    }
    return out('MERGE-FIRST', `#${wantedNumber}${pr ? '' : ' (not among the open pull requests)'}${staleLock}`);
  }

  if (state.kind === 'NEXT') {
    if (!brief?.exists) {
      return out('STOP', `state.md names row ${state.nextId} next, and rows/${state.nextId}.md does not exist`);
    }
    if (checks?.green) return out('MERGE-FIRST', `#${pr.number} (row ${state.nextId}, ${pr.headRefName}, every required check passing)${staleLock}`);
    let detail = briefInfo.branch ? `branch ${briefInfo.branch}` : 'its brief names no branch';
    if (pr) detail += `, #${pr.number} open with ${checks.failing.join(', ')} failing`;
    return out('DRIVE', `row ${state.nextId} (${detail}${staleLock})`);
  }

  return out('STOP', `state.md begins "${first || '(nothing)'}", which is none of DONE, BLOCKED:, READY: or NEXT: row <id>; plan-board reads it as UNKNOWN too`);
}

// The printed line: `<plan>: <VERDICT> <detail>`.
export function verdictLine(plan, result) {
  return `${plan}: ${result.verdict}${result.detail ? ` ${result.detail}` : ''}`;
}
