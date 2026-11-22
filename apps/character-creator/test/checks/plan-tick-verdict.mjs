// .claude/scripts/plan-tick.mjs decides whether a plan has a live driver, and a
// scheduled driver acts on the word it prints: a wrong LIVE leaves a plan idle,
// a wrong DRIVE starts a second driver that removes the first one's worktrees
// (Splynn rows 42 and 56, 2026-11-18 to 20). The decisions live in
// .claude/scripts/plan-tick-lib.mjs and are driven here with text shaped like a
// real state.md, a real brief, a driver.lock and `gh pr list` rows.

import * as fs from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { check, section, wantSection } from '../harness.mjs';
import { CLAIMABLE, FALLBACK_MS, STALE_MS, attemptsOf, beatLock, claimLock, decide, lockText, parseLock, readyNumber, releaseLock,
  requiredChecks, verdictLine } from '../../../../.claude/scripts/plan-tick-lib.mjs';

const SECTIONS = ['plan-tick.mjs: one verdict per plan, never guessed', 'plan-tick.mjs: the driver lock has one owner'];

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
    const pr = (number, rollup, headRefName = 'shared/feat/thing') => ({ number, headRefName, headRefOid: `${number}`.repeat(4) + 'c0ffee', statusCheckRollup: rollup });
    const tick = (input) => decide({ now, pulls: [], merged: [], ...input });
    const line = (input) => verdictLine('p', tick(input));

    const L = (ageMin, owner = 'a77') => ({ timeMs: now - ageMin * min, owner, session: 's1' });
    // A transcript found and quiet, so the 90-minute fallback is not in play.
    const tquiet = now - 40 * min;
    check('DONE is DONE, whatever else is on disk',
      line({ stateText: 'DONE\nLast row: 9 MERGED.', lock: L(0) }) === 'p: DONE');
    check('BLOCKED prints its sentence',
      line({ stateText: 'BLOCKED: the survey is not merged.\nLast row: 2.' }) === 'p: BLOCKED the survey is not merged.');

    const fresh = line({ stateText: next, brief, lock: L(5) });
    check('a lock with a heartbeat under 30 minutes is LIVE', fresh === 'p: LIVE driver.lock heartbeat 5m old (owner a77)', fresh);
    const moved = tick({ stateText: next, brief, lock: L(45), gitMovedMs: now - 3 * min, transcriptMs: tquiet });
    check('a stale lock with a worktree moved under 30 minutes ago is LIVE',
      moved.verdict === 'LIVE' && /worktree moved 3m ago/.test(moved.detail), moved.detail);
    const quiet = tick({ stateText: next, brief, lock: L(45), gitMovedMs: now - 40 * min, transcriptMs: tquiet });
    check('a stale lock with nothing moved and the transcript quiet is not LIVE: the row is driven, and the stale lock named',
      quiet.verdict === 'DRIVE' && /stale \(45m, owner a77\)/.test(quiet.detail), `${quiet.verdict} ${quiet.detail}`);
    check('no lock, and a worktree that moved, is not LIVE: the window needs the lock',
      tick({ stateText: next, brief, gitMovedMs: now - min, transcriptMs: now - min }).verdict === 'DRIVE');
    check('the window is 30 minutes', STALE_MS === 30 * min
      && tick({ stateText: next, brief, lock: L(30 - 1 / 60000), transcriptMs: tquiet }).verdict === 'LIVE'
      && tick({ stateText: next, brief, lock: L(30), transcriptMs: tquiet }).verdict === 'DRIVE');

    // A driver waiting on a long foreground worker: heartbeat and worktrees
    // 31 minutes quiet, which DROVE a second driver before the transcript counted.
    const working = tick({ stateText: next, brief, lock: L(31), gitMovedMs: now - 31 * min, transcriptMs: now - 2 * min });
    check('a stale lock whose owner\'s transcript was written under 30 minutes ago is LIVE',
      working.verdict === 'LIVE' && /owner's transcript was written 2m ago/.test(working.detail), `${working.verdict} ${working.detail}`);
    check('the transcript window is 30 minutes too',
      tick({ stateText: next, brief, lock: L(45), transcriptMs: now - 30 * min + 1 }).verdict === 'LIVE'
        && tick({ stateText: next, brief, lock: L(45), transcriptMs: now - 30 * min }).verdict === 'DRIVE');
    const fallback = tick({ stateText: next, brief, lock: L(31), gitMovedMs: now - 31 * min, transcriptMs: null });
    check('no transcript found: the heartbeat holds the lock for the 90-minute fallback',
      FALLBACK_MS === 90 * min && fallback.verdict === 'LIVE' && /no transcript found for the owner, inside the 90m fallback/.test(fallback.detail)
        && tick({ stateText: next, brief, lock: L(90 - 1 / 60000) }).verdict === 'LIVE'
        && tick({ stateText: next, brief, lock: L(90) }).verdict === 'DRIVE', `${fallback.verdict} ${fallback.detail}`);
    check('a transcript found but quiet does not get the fallback',
      tick({ stateText: next, brief, lock: L(31), transcriptMs: now - 31 * min }).verdict === 'DRIVE');

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
    check('a red required check is still DRIVE, with the number and the head commit to resume in the detail',
      red === 'p: DRIVE row 4 (branch shared/feat/thing, #31 open with regression failing, resume 31313131c0ffee)', red);

    // A driver that died between `gh pr merge` and the state.md write leaves
    // NEXT (or READY) naming a row that has merged. Re-driving it, or merging
    // it again, is the wrong answer; the plan advances.
    const mergedPr = (number, headRefName = 'shared/feat/thing', mergedAt = '2026-11-21T11:00:00Z') => ({ number, headRefName, mergedAt });
    const advance = line({ stateText: next, brief, merged: [mergedPr(29, 'other/branch'), mergedPr(31)] });
    check('NEXT whose brief\'s branch has a merged pull request is ADVANCE, to the brief\'s Next row:, never DRIVE',
      advance === 'p: ADVANCE row 4 merged #31 (next row 5)', advance);
    const lastBrief = { exists: true, text: brief.text.replace('Next row: 5.', 'Next row: none (the last row).') };
    check('a merged last row advances to DONE',
      line({ stateText: next, brief: lastBrief, merged: [mergedPr(31)] }) === 'p: ADVANCE row 4 merged #31 (next DONE)');
    const noNext = tick({ stateText: next, brief: { exists: true, text: brief.text.replace(' Next row: 5.', '') }, merged: [mergedPr(31)] });
    check('a merged row whose brief names no Next row: is STOP, not a guessed next row',
      noNext.verdict === 'STOP' && /merged #31/.test(noNext.detail) && /names no Next row:/.test(noNext.detail), `${noNext.verdict} ${noNext.detail}`);
    check('a merged row beats an open pull request on the same branch, and the newest merge is named',
      line({ stateText: next, brief, pulls: [pr(33, green)], merged: [mergedPr(30, undefined, '2026-11-20T10:00:00Z'), mergedPr(31)] })
        === 'p: ADVANCE row 4 merged #31 (next row 5)');
    const readyMerged = line({ stateText: 'READY: #31 is open and green.\nNEXT: row 5 (brief: rows/5.md).', merged: [mergedPr(31)] });
    check('READY whose number has merged is ADVANCE to state.md\'s own NEXT line, never a second merge',
      readyMerged === 'p: ADVANCE #31 merged (READY; next row 5)', readyMerged);
    check('READY merged with no NEXT line under it advances to DONE',
      line({ stateText: 'READY: #31 is open and green.', merged: [mergedPr(31)] }) === 'p: ADVANCE #31 merged (READY; next DONE)');
    const staleAdvance = tick({ stateText: next, brief, lock: L(45), transcriptMs: tquiet, merged: [mergedPr(31)] });
    check('a stale lock over a merged row is ADVANCE with the stale lock named',
      staleAdvance.verdict === 'ADVANCE' && /stale \(45m, owner a77\)/.test(staleAdvance.detail), `${staleAdvance.verdict} ${staleAdvance.detail}`);
    check('a fresh lock over a merged row is still LIVE: its driver is writing state.md',
      tick({ stateText: next, brief, lock: L(5), merged: [mergedPr(31)] }).verdict === 'LIVE');

    // A worker's stop is STOPPED, which a later tick resumes once; BLOCKED is the
    // driver's. Before this, a worker wrote BLOCKED: and the plan parked for good.
    const capped = 'BLOCKED: stopped at the 200k cap with work pushed on shared/feat/thing at abc1234.\nNEXT: row 4 (brief: rows/4.md).';
    check('a BLOCKED: line is still BLOCKED, on every tick: only the driver writes it',
      [0, 1, 2].every((i) => tick({ stateText: capped, brief, now: now + i * 10 * min }).verdict === 'BLOCKED'));
    const stopped = 'STOPPED: stopped at the 200k cap with work pushed.\r\nResume: shared/feat/thing abc1234\r\nNEXT: row 4 (brief: rows/4.md).\r\n';
    const resumed = line({ stateText: stopped, brief });
    check('STOPPED with a Resume: line is RESUME row <id> (<branch> <commit>, <cause>) as attempt 2',
      resumed === 'p: RESUME row 4 (shared/feat/thing abc1234, stopped at the 200k cap with work pushed.) as attempt 2', resumed);
    const bare = line({ stateText: 'STOPPED: the row is larger than the brief.\nNEXT: row 4 (brief: rows/4.md).', brief });
    check('STOPPED with no Resume: line resumes from nothing pushed',
      bare === 'p: RESUME row 4 (nothing pushed, the row is larger than the brief.) as attempt 2', bare);
    const once = { exists: true, text: `${brief.text}From row 4: attempt 2\r\n` };
    const again = tick({ stateText: stopped, brief: once });
    check('a row stopped again with attempt 2 already on its brief is BLOCKED, never a third run',
      again.verdict === 'BLOCKED' && /stopped again after attempt 2/.test(again.detail), `${again.verdict} ${again.detail}`);
    check('attempts are read off the brief, never state.md: an attempt line in state.md does not count',
      tick({ stateText: `${stopped}From row 4: attempt 2\n`, brief }).verdict === 'RESUME');
    check('another row\'s attempt line on the brief does not count',
      tick({ stateText: stopped, brief: { exists: true, text: `${brief.text}From row 3: attempt 2\n` } }).verdict === 'RESUME');
    const noRec = tick({ stateText: 'STOPPED: two options; no option can be recommended, because both lose data.\nNEXT: row 4 (brief: rows/4.md).', brief });
    check('a STOPPED cause that carries no recommendation is BLOCKED',
      noRec.verdict === 'BLOCKED' && /no recommendation/.test(noRec.detail), `${noRec.verdict} ${noRec.detail}`);
    check('a STOPPED with no cause is BLOCKED',
      tick({ stateText: 'STOPPED:\nNEXT: row 4 (brief: rows/4.md).', brief }).verdict === 'BLOCKED');
    const nowhere = tick({ stateText: 'STOPPED: the cap.\nResume: shared/feat/thing abc1234', brief: null });
    check('a STOPPED naming no row is STOP, not a guessed row',
      nowhere.verdict === 'STOP' && /names no row to resume/.test(nowhere.detail), `${nowhere.verdict} ${nowhere.detail}`);
    check('a STOPPED row whose brief is missing is STOP',
      tick({ stateText: stopped, brief: { exists: false, text: '' } }).verdict === 'STOP');
    check('a fresh lock over a STOPPED row is LIVE: a driver is acting on it',
      tick({ stateText: stopped, brief, lock: L(5) }).verdict === 'LIVE');
    check('a STOPPED row needs no gh reading',
      decide({ now, stateText: stopped, brief, pulls: null, merged: null }).verdict === 'RESUME');
    check('attemptsOf takes the highest attempt line for its row', attemptsOf('4', 'From row 4: attempt 2\nFrom row 4: attempt 3\nFrom row 44: attempt 9') === 3
      && attemptsOf('4', '') === 0);

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
      decide({ now, stateText: next, brief, pulls: null, merged: [] }).verdict === 'UNKNOWN'
        && decide({ now, stateText: 'READY: #5 is open', pulls: null, merged: [] }).verdict === 'UNKNOWN');
    const mergedUnread = [decide({ now, stateText: next, brief, pulls: [], merged: null }),
      decide({ now, stateText: 'READY: #5 is open', pulls: [], merged: null })];
    check('merged pull requests unread are UNKNOWN too, never DRIVE or MERGE-FIRST',
      mergedUnread.every((r) => r.verdict === 'UNKNOWN' && /merged pull requests not read/.test(r.detail)), JSON.stringify(mergedUnread.map((r) => r.verdict)));
    check('a fresh lock is LIVE with the pull requests unread: it needs no gh reading',
      decide({ now, stateText: next, brief, pulls: null, lock: L(1) }).verdict === 'LIVE');

    const lock = parseLock(lockText(now, '4242abcd', 'b34ff7ce-ddea'));
    check('a lock written is a lock read', lock?.timeMs === now && lock.owner === '4242abcd' && lock.session === 'b34ff7ce-ddea', JSON.stringify(lock));
    check('a lock with no session reads as session null', parseLock(lockText(now, 'ab12'))?.session === null);
    check('a lock that does not parse is null, which the script reports UNKNOWN',
      parseLock('') === null && parseLock('{"time":"soon","owner":"ab"}') === null && parseLock('{"time":"2026-11-21T00:00:00Z"}') === null
        && parseLock('{"time":"2026-11-21T00:00:00Z","owner":"ab","session":"../x"}') === null);
    check('the old pid-only lock does not parse: a pid named the caller\'s shell, a new one per call',
      parseLock('{"time":"2026-11-21T00:00:00Z","pid":35344}') === null);
    check('READY numbers are read off the first line only', readyNumber('READY: #12 is open') === 12 && readyNumber('NEXT: row 1') === null);
    const status = requiredChecks([{ __typename: 'StatusContext', context: 'smoke', state: 'SUCCESS' },
      run('menus', 'COMPLETED', 'FAILURE'), { ...run('menus', 'COMPLETED', 'SUCCESS'), startedAt: '2026-11-21T11:55:00Z' }]);
    check('the newest run of a check counts, and status contexts are read too',
      status.passing.join() === 'smoke,menus' && status.pending.join() === 'regression' && !status.green, JSON.stringify(status));
  }

  section('plan-tick.mjs: the driver lock has one owner');
  {
    // The lock-file operations on a real file in a temp dir, through node:fs,
    // the way plan-tick.mjs calls them.
    const dir = fs.mkdtempSync(join(tmpdir(), 'plan-tick-lock-'));
    try {
      const path = join(dir, 'driver.lock');
      const read = () => (fs.existsSync(path) ? fs.readFileSync(path, 'utf8') : null);
      const t0 = Date.parse('2026-11-21T12:00:00Z');

      check('only DRIVE, MERGE-FIRST, ADVANCE and RESUME can be claimed; DONE, BLOCKED, STOP, LIVE and UNKNOWN cannot',
        CLAIMABLE.join() === 'DRIVE,MERGE-FIRST,ADVANCE,RESUME');

      const a = lockText(t0, 'aaaa', 's1');
      const first = claimLock(fs, path, { seen: null, text: a, owner: 'aaaa' });
      check('a claim on a free plan writes the lock', first.ok && read() === a, JSON.stringify(first));
      const second = claimLock(fs, path, { seen: null, text: lockText(t0, 'bbbb'), owner: 'bbbb' });
      check('a second claim that also saw no lock is refused, and the first lock stands',
        !second.ok && read() === a, JSON.stringify(second));

      const before = read();
      const beatOther = beatLock(fs, path, 'bbbb', t0 + 60000);
      check('a heartbeat with another owner\'s id is refused and changes nothing',
        !beatOther.ok && /held by owner aaaa, not bbbb/.test(beatOther.why) && read() === before, beatOther.why);
      const relOther = releaseLock(fs, path, 'bbbb');
      check('a release with another owner\'s id is refused and changes nothing', !relOther.ok && read() === before, relOther.why);
      const beat = beatLock(fs, path, 'aaaa', t0 + 60000);
      const beaten = parseLock(read());
      check('a heartbeat with the owner\'s id moves the time and keeps owner and session',
        beat.ok && beaten.timeMs === t0 + 60000 && beaten.owner === 'aaaa' && beaten.session === 's1', read());

      // Two claims judged the same lock stale. The first takes it over; the
      // second, still holding the stale text it read, must not take it again.
      const stale = read();
      const c = lockText(t0 + 120000, 'cccc', 's2');
      const takeover = claimLock(fs, path, { seen: stale, text: c, owner: 'cccc' });
      check('a claim over the stale lock it read takes the lock', takeover.ok && read() === c, JSON.stringify(takeover));
      const racer = claimLock(fs, path, { seen: stale, text: lockText(t0 + 120001, 'dddd'), owner: 'dddd' });
      check('a racing claim over the same stale lock is refused, and the winner\'s lock is put back as it was',
        !racer.ok && read() === c, `${JSON.stringify(racer)} ${read()}`);
      check('no renamed-aside lock is left behind', fs.readdirSync(dir).join() === 'driver.lock', fs.readdirSync(dir).join());
      fs.unlinkSync(path);
      const gone = claimLock(fs, path, { seen: stale, text: lockText(t0, 'eeee'), owner: 'eeee' });
      check('a claim over a stale lock that has since gone is refused rather than guessed', !gone.ok && read() === null);

      fs.writeFileSync(path, c);
      const rel = releaseLock(fs, path, 'cccc');
      check('a release with the owner\'s id deletes the lock', rel.ok && read() === null);
      check('a release with no lock on disk succeeds: the plan is free either way', releaseLock(fs, path, 'cccc').ok);
      check('a heartbeat with no lock on disk is refused', !beatLock(fs, path, 'cccc', t0).ok && read() === null);

      // For one row the ownerless calls still act (Nate, 2026-11-21).
      fs.writeFileSync(path, c);
      check('an ownerless heartbeat still beats, for now', beatLock(fs, path, null, t0 + 1).ok && parseLock(read()).timeMs === t0 + 1);
      check('an ownerless release still releases, for now', releaseLock(fs, path, null).ok && read() === null);
      fs.writeFileSync(path, '{"time":"2026-11-21T00:00:00Z","pid":35344}\n');
      check('an old pid-only lock is refused to an owner, and an ownerless release clears it',
        !releaseLock(fs, path, 'cccc').ok && read() !== null && releaseLock(fs, path, null).ok && read() === null);
    } finally {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  }
}
