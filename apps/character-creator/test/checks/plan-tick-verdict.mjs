// .claude/scripts/plan-tick.mjs decides whether a plan has a live driver, and a
// scheduled driver acts on the word it prints: a wrong LIVE leaves a plan idle,
// a wrong DRIVE starts a second driver that removes the first one's worktrees
// (Splynn rows 42 and 56, 2026-11-18 to 20). The decisions live in
// .claude/scripts/plan-tick-lib.mjs and are driven here with text shaped like a
// real state.md, a real brief, a driver.lock and `gh pr list` rows.

import { check, section, wantSection } from '../harness.mjs';
import { STALE_MS, decide, lockText, parseLock, readyNumber, requiredChecks, verdictLine }
  from '../../../../.claude/scripts/plan-tick-lib.mjs';

const SECTIONS = ['plan-tick.mjs: one verdict per plan, never guessed'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('plan-tick.mjs: one verdict per plan, never guessed');
  {
    const now = Date.parse('2026-11-21T12:00:00Z');
    const min = 60 * 1000;
    const brief = { exists: true, text: '# Row 4: do the thing\r\n\r\nGroup `shared`, branch `shared/feat/thing`. Skills: `ship-pr`. Next row: 5.\r\n' };
    const next = 'NEXT: row 4 (brief: rows/4.md), then row 5.\r\nLast row: 3 MERGED, #20.\r\nIn flight: nothing.\r\n';
    const run = (name, status, conclusion = null) => ({ __typename: 'CheckRun', name, status, conclusion, startedAt: '2026-11-21T11:50:00Z' });
    const green = ['smoke', 'menus', 'regression'].map((n) => run(n, 'COMPLETED', 'SUCCESS'));
    const pr = (number, rollup, headRefName = 'shared/feat/thing') => ({ number, headRefName, statusCheckRollup: rollup });
    const tick = (input) => decide({ now, pulls: [], ...input });
    const line = (input) => verdictLine('p', tick(input));

    check('DONE is DONE, whatever else is on disk',
      line({ stateText: 'DONE\nLast row: 9 MERGED.', lock: { timeMs: now, pid: 1 } }) === 'p: DONE');
    check('BLOCKED prints its sentence',
      line({ stateText: 'BLOCKED: the survey is not merged.\nLast row: 2.' }) === 'p: BLOCKED the survey is not merged.');

    const fresh = line({ stateText: next, brief, lock: { timeMs: now - 5 * min, pid: 77 } });
    check('a lock with a heartbeat under 30 minutes is LIVE', fresh === 'p: LIVE driver.lock heartbeat 5m old (pid 77)', fresh);
    const moved = tick({ stateText: next, brief, lock: { timeMs: now - 45 * min, pid: 77 }, gitMovedMs: now - 3 * min });
    check('a stale lock with a worktree moved under 30 minutes ago is LIVE',
      moved.verdict === 'LIVE' && /worktree moved 3m ago/.test(moved.detail), moved.detail);
    const quiet = tick({ stateText: next, brief, lock: { timeMs: now - 45 * min, pid: 77 }, gitMovedMs: now - 40 * min });
    check('a stale lock with nothing moved is not LIVE: the row is driven, and the stale lock named',
      quiet.verdict === 'DRIVE' && /stale \(45m, pid 77\)/.test(quiet.detail), `${quiet.verdict} ${quiet.detail}`);
    check('no lock, and a worktree that moved, is not LIVE: the window needs the lock',
      tick({ stateText: next, brief, gitMovedMs: now - min }).verdict === 'DRIVE');
    check('the window is 30 minutes', STALE_MS === 30 * min
      && tick({ stateText: next, brief, lock: { timeMs: now - 30 * min + 1, pid: 1 } }).verdict === 'LIVE'
      && tick({ stateText: next, brief, lock: { timeMs: now - 30 * min, pid: 1 } }).verdict === 'DRIVE');

    const pending = line({ stateText: next, brief, pulls: [pr(31, [...green.slice(0, 2), run('regression', 'IN_PROGRESS')])] });
    check('the next row\'s pull request with a required check pending is LIVE', pending === 'p: LIVE #31 has regression pending', pending);
    check('a required check not listed yet counts as pending',
      tick({ stateText: next, brief, pulls: [pr(31, green.slice(0, 2))] }).verdict === 'LIVE');
    check('a pending check that is not required does not hold the plan',
      tick({ stateText: next, brief, pulls: [pr(31, [...green, run('play-flow', 'IN_PROGRESS')])] }).verdict === 'MERGE-FIRST');

    check('READY is MERGE-FIRST with its number, in either shape',
      line({ stateText: 'READY: #2317 is open and green.\nNEXT: row 5 (brief: rows/5.md).' }) === 'p: MERGE-FIRST #2317 (not among the open pull requests)'
        && line({ stateText: 'READY: https://github.com/o/r/pull/9 (row 4)', pulls: [pr(9, green)] }) === 'p: MERGE-FIRST #9');
    const mergeFirst = line({ stateText: next, brief, pulls: [pr(30, green, 'other/branch'), pr(31, green)] });
    check('NEXT whose brief\'s branch has an open pull request with all three checks passing is MERGE-FIRST',
      mergeFirst.startsWith('p: MERGE-FIRST #31 '), mergeFirst);
    const drive = line({ stateText: next, brief });
    check('NEXT with a brief and no pull request is DRIVE row <id>',
      drive === 'p: DRIVE row 4 (branch shared/feat/thing)', drive);
    const red = line({ stateText: next, brief, pulls: [pr(31, [green[0], green[1], run('regression', 'COMPLETED', 'FAILURE')])] });
    check('a red required check is still DRIVE, with the number in the detail',
      red === 'p: DRIVE row 4 (branch shared/feat/thing, #31 open with regression failing)', red);

    const missing = tick({ stateText: next, brief: { exists: false, text: '' } });
    check('a missing brief is STOP, with both readings',
      missing.verdict === 'STOP' && /names row 4 next/.test(missing.detail) && /rows\/4\.md does not exist/.test(missing.detail), missing.detail);
    for (const text of ['Row 3 is nearly there', '', 'NEXT: see the plan']) {
      const r = tick({ stateText: text });
      check(`an unparseable first line is STOP, not guessed (${JSON.stringify(text)})`,
        r.verdict === 'STOP' && r.detail.includes(text || '(nothing)'), `${r.verdict} ${r.detail}`);
    }
    check('READY naming no pull request is STOP', tick({ stateText: 'READY: the row is done' }).verdict === 'STOP');

    check('pull requests unread are UNKNOWN, never a verdict',
      decide({ now, stateText: next, brief, pulls: null }).verdict === 'UNKNOWN'
        && decide({ now, stateText: 'READY: #5 is open', pulls: null }).verdict === 'UNKNOWN');
    check('a fresh lock is LIVE with the pull requests unread: it needs no gh reading',
      decide({ now, stateText: next, brief, pulls: null, lock: { timeMs: now - min, pid: 1 } }).verdict === 'LIVE');

    const lock = parseLock(lockText(now, 4242));
    check('a lock written is a lock read', lock?.timeMs === now && lock.pid === 4242, JSON.stringify(lock));
    check('a lock that does not parse is null, which the script reports UNKNOWN',
      parseLock('') === null && parseLock('{"time":"soon","pid":1}') === null && parseLock('{"time":"2026-11-21T00:00:00Z"}') === null);
    check('READY numbers are read off the first line only', readyNumber('READY: #12 is open') === 12 && readyNumber('NEXT: row 1') === null);
    const status = requiredChecks([{ __typename: 'StatusContext', context: 'smoke', state: 'SUCCESS' },
      run('menus', 'COMPLETED', 'FAILURE'), { ...run('menus', 'COMPLETED', 'SUCCESS'), startedAt: '2026-11-21T11:55:00Z' }]);
    check('the newest run of a check counts, and status contexts are read too',
      status.passing.join() === 'smoke,menus' && status.pending.join() === 'regression' && !status.green, JSON.stringify(status));
  }
}
