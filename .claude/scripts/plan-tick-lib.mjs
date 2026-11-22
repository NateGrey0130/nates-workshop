// plan-tick-lib.mjs - the decisions behind plan-tick.mjs, with no file, clock
// or network access, so the smoke suite can drive them with text.
//
// One verdict per armed plan, read from five things: state.md's first line,
// the next row's brief, the plan's driver.lock, the open pull requests and the
// recently merged ones. The verdicts, in the order they are tried:
//
//   DONE                  state.md says so
//   BLOCKED <sentence>    state.md says so (only a driver writes BLOCKED:), or a
//                         worker's STOPPED row that a resume would not help:
//                         stopped a second time, or with no recommendation.
//                         A person reads it, nothing drives it
//   LIVE <why>            a driver is working: the lock's heartbeat is fresh, or
//                         the lock exists and a worktree moved or the owner's
//                         transcript was written recently (with no transcript
//                         found, a longer fallback on the heartbeat), or the
//                         row's pull request has a required check pending
//   ADVANCE ...           the pull request the plan is waiting on has already
//                         merged: a driver died between the merge and the
//                         state.md write. `ADVANCE row <id> merged #<n> (next row
//                         <m>|next DONE)` for a NEXT row, from its brief's
//                         `Next row:`; `ADVANCE #<n> merged (READY; next ...)`
//                         for READY, from state.md's own NEXT line. The driver
//                         writes that state.md; it never merges or drives again
//   RESUME row <id> (<branch> <commit>, <cause>) as attempt <n>
//                         a worker stopped: state.md begins `STOPPED: <cause>`,
//                         names the row on a NEXT line and the commit on an
//                         optional `Resume: <branch> <commit>` line ("nothing
//                         pushed" without one). Attempts are counted from
//                         `From row <id>: attempt <n>` lines on the row's brief,
//                         never on state.md, which a worker replaces whole
//   MERGE-FIRST #<n>      READY names a pull request, or the next row's branch
//                         has an open pull request with every required check passing
//   DRIVE row <id>        the next row has a brief; a red check on its open pull
//                         request is still DRIVE, with the number and its head
//                         commit in the detail, so the worker resumes that commit
//   STOP <reason>         a missing brief, a merged row whose brief names no
//                         `Next row:`, a STOPPED naming no row, or a first line
//                         nothing here can parse
//
// Two more are taken across ticks and plans, by the script, after the above:
//
//   WAIT <plan> is live   another armed plan is LIVE, so this plan's DRIVE,
//                         MERGE-FIRST, ADVANCE or RESUME waits: one driver at a
//                         time across every plan (oneDriver)
//   STOP UNKNOWN on <n> consecutive ticks
//                         the same plan was UNKNOWN on UNKNOWN_TICKS ticks in a
//                         row, counted in its unknown.count (countUnknown)
//
// A reading that failed (gh, a file) is never a verdict: the script prints
// UNKNOWN for it and exits 2. A driver.lock that does not parse is not a failed
// reading: it names no owner and no time, so it is a stale lock, named in the
// detail, and a claim takes it over.

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
// or UNKNOWN has nothing for a new driver to do. ADVANCE is claimed because its
// driver writes state.md, and two drivers must not both write it.
export const CLAIMABLE = ['DRIVE', 'MERGE-FIRST', 'ADVANCE', 'RESUME'];

// A stopped row is resumed once. Its second stop, or a stop whose cause says
// no option can be recommended (pr-worker's breaking stop), is BLOCKED.
export const MAX_ATTEMPTS = 2;
const NO_RECOMMENDATION = /\bno (?:option can be recommended|recommendation)\b/i;

// The highest `From row <id>: attempt <n>` on the row's brief, or 0 for none.
export function attemptsOf(id, briefText) {
  if (!/^\d+[a-z]*$/.test(String(id ?? ''))) return 0;
  const line = new RegExp(`^\\s*From row ${id}:\\s*attempt\\s+(\\d+)\\b`, 'gim');
  let most = 0;
  for (const m of String(briefText ?? '').matchAll(line)) most = Math.max(most, Number(m[1]));
  return most;
}

// main's ruleset 22209348 requires these three.
export const REQUIRED_CHECKS = ['smoke', 'menus', 'regression'];

const PASSING = new Set(['SUCCESS', 'NEUTRAL', 'SKIPPED']);

// The lock is JSON: {"time": ISO string, "owner": id, "session": id or null}.
// `owner` is a random id the claim prints and every later call passes back as
// --owner; `session` is the claiming Claude session, whose transcript writes
// count as the owner being alive. Anything else is null, which the script
// hands decide() as `badLock`: a stale lock (it was UNKNOWN on every tick
// until 2026-11-21). (A pid used to stand where the owner is: it was the
// caller's shell, a new one per call, so it named no one.)
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
//   brief         { exists, text } for the row state.md names next (NEXT, or the
//                 stopped row under STOPPED), or null when it names none
//   lock          null (no driver.lock, or one that does not parse) or parseLock's answer
//   badLock       true when a driver.lock exists and does not parse: stale, named
//   gitMovedMs    the newest worktree index or logs/HEAD write, in ms, or null
//   transcriptMs  the newest write to the lock owner's session transcript (its
//                 JSONL or a subagent's under it), in ms, or null when none was
//                 found, which falls back to FALLBACK_MS on the heartbeat
//   pulls         the open pull requests from gh, or null when gh was not needed
//   merged        the recently merged pull requests from gh (number,
//                 headRefName, mergedAt), or null when not read
//   now           ms
// Returns { verdict, detail, state }. UNKNOWN only when the answer turned on
// pull requests, open or merged, that were not given; a fresh lock answers
// LIVE without them.
export function decide({ stateText, brief = null, lock = null, badLock = false, gitMovedMs = null, transcriptMs = null, pulls = null, merged = null, now }) {
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

  // A worker's stop. Resumed once from the commit it pushed; a second stop, or
  // one with nothing a driver could take, waits for a person.
  // A lock that got this far is stale; one that does not parse is stale too.
  const staleLock = lock ? `; driver.lock is stale (${ago(now - lock.timeMs)}, owner ${lock.owner})`
    : badLock ? '; driver.lock does not parse, so it is treated as stale' : '';

  if (state.kind === 'STOPPED') {
    const id = state.nextId;
    const lockNote = staleLock;
    if (id === null) return out('STOP', `state.md says STOPPED but names no row to resume: no NEXT: row <id> line under "${first}"`);
    if (!brief?.exists) return out('STOP', `state.md names row ${id} stopped, and rows/${id}.md does not exist`);
    const cause = state.cause || '(no cause given)';
    if (!state.cause || NO_RECOMMENDATION.test(state.cause)) {
      return out('BLOCKED', `row ${id} stopped with no recommendation a driver could take: ${cause}`);
    }
    const attempts = attemptsOf(id, brief.text);
    if (attempts >= MAX_ATTEMPTS) {
      return out('BLOCKED', `row ${id} stopped again after attempt ${attempts} (rows/${id}.md): ${cause}`);
    }
    const from = state.resume ? `${state.resume.branch} ${state.resume.commit}` : 'nothing pushed';
    return out('RESUME', `row ${id} (${from}, ${cause}) as attempt ${Math.max(attempts, 1) + 1}${lockNote}`);
  }

  // The pull request the plan is waiting on: READY's, or the next row's branch's.
  const briefInfo = brief?.exists ? parseBrief(state.nextId, brief.text) : null;
  const wantedNumber = state.kind === 'READY' ? readyNumber(first) : null;
  const wantedBranch = state.kind === 'NEXT' ? briefInfo?.branch ?? null : null;
  const needsPulls = wantedNumber !== null || wantedBranch !== null;
  if (needsPulls && pulls === null) return out('UNKNOWN', 'pull requests not read');
  if (needsPulls && merged === null) return out('UNKNOWN', 'merged pull requests not read');
  const wanted = (p) => (wantedNumber !== null ? p.number === wantedNumber : p.headRefName === wantedBranch);
  const pr = !needsPulls ? null : (pulls.find(wanted) ?? null);
  const checks = pr ? requiredChecks(pr.statusCheckRollup) : null;

  // Merged already: the driver that merged it died before writing state.md.
  // The newest merge on the branch counts. Never a second merge, never a re-drive.
  const done = !needsPulls ? null
    : (merged.filter(wanted).sort((a, b) => (Date.parse(b.mergedAt ?? '') || 0) - (Date.parse(a.mergedAt ?? '') || 0))[0] ?? null);
  if (done && state.kind === 'READY') {
    const then = state.nextId !== null ? `next row ${state.nextId}` : 'next DONE';
    return out('ADVANCE', `#${done.number} merged (READY; ${then})${staleLock}`);
  }
  if (done && state.kind === 'NEXT' && brief?.exists) {
    if (briefInfo.nextRow === null) {
      return out('STOP', `row ${state.nextId} merged #${done.number}, and rows/${state.nextId}.md names no Next row: to advance to`);
    }
    const then = briefInfo.nextRow === 'DONE' ? 'next DONE' : `next row ${briefInfo.nextRow}`;
    return out('ADVANCE', `row ${state.nextId} merged #${done.number} (${then})${staleLock}`);
  }

  if (checks?.pending.length) return out('LIVE', `#${pr.number} has ${checks.pending.join(', ')} pending`);

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
    if (pr) detail += `, #${pr.number} open with ${checks.failing.join(', ')} failing, resume ${pr.headRefOid ?? 'head commit not read'}`;
    return out('DRIVE', `row ${state.nextId} (${detail}${staleLock})`);
  }

  return out('STOP', `state.md begins "${first || '(nothing)'}", which is none of DONE, BLOCKED:, STOPPED:, READY: or NEXT: row <id>; plan-board reads it as UNKNOWN too`);
}

// One driver at a time across every armed plan ("one plan at a time"). Each
// plan's verdict is decided alone, so plan A LIVE and plan B DRIVE both used to
// print and two drivers ran. While any plan is LIVE, every other plan whose
// verdict would start a driver (CLAIMABLE) is WAIT, which cannot be claimed.
// results: [{ plan, result }], result as decide() returns it; same shape back.
export function oneDriver(results) {
  const live = results.filter((r) => r.result.verdict === 'LIVE').map((r) => r.plan);
  return results.map(({ plan, result }) => {
    const other = live.find((p) => p !== plan);
    if (other === undefined || !CLAIMABLE.includes(result.verdict)) return { plan, result };
    const held = `${result.verdict}${result.detail ? ` ${result.detail}` : ''}`;
    return { plan, result: { ...result, verdict: 'WAIT', detail: `${other} is live (held back: ${held})` } };
  });
}

// An UNKNOWN that repeats becomes a STOP, so the driver writes a BLOCKED line
// instead of ticking on it forever with nothing written anywhere. Counted per
// plan in an `unknown.count` file beside `armed`; any verdict clears it. Four
// ticks taken on the recommendation, 2026-11-21 (not taken: two or eight).
export const UNKNOWN_TICKS = 4;

// countText: the plan's unknown.count as read, or null. Returns the count to
// write (0: delete the file) and the result to print.
export function countUnknown(countText, result) {
  if (result.verdict !== 'UNKNOWN') return { count: 0, result };
  const prev = /^\s*(\d+)\s*$/.exec(String(countText ?? ''));
  const count = (prev ? Number(prev[1]) : 0) + 1;
  if (count < UNKNOWN_TICKS) return { count, result };
  return { count, result: { ...result, verdict: 'STOP', detail: `UNKNOWN on ${count} consecutive ticks, the last: ${result.detail}` } };
}

// The printed line: `<plan>: <VERDICT> <detail>`.
export function verdictLine(plan, result) {
  return `${plan}: ${result.verdict}${result.detail ? ` ${result.detail}` : ''}`;
}
