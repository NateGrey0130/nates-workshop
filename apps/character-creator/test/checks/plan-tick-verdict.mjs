// .claude/scripts/plan-tick.mjs decides whether a plan has a live driver, and a
// scheduled driver acts on the word it prints: a wrong LIVE leaves a plan idle,
// a wrong DRIVE starts a second driver that removes the first one's worktrees
// (Splynn rows 42 and 56, 2026-11-18 to 20). The decisions live in
// .claude/scripts/plan-tick-lib.mjs and are driven here with text shaped like a
// real state.md, a real brief, a driver.lock and `gh pr list` rows.

import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { check, repoRoot, section, wantSection } from '../harness.mjs';
import { CLAIMABLE, FALLBACK_MS, STALE_MS, UNKNOWN_TICKS, attemptsOf, beatLock, claimLock, countUnknown, decide, lockText, oneDriver,
  parseLock, readyNumber, releaseLock, requiredChecks, verdictLine } from '../../../../.claude/scripts/plan-tick-lib.mjs';
import { d1FilesByDb, parseCheck, verdict as d1Verdict } from '../../../../.claude/scripts/pr-d1-lib.mjs';

const SECTIONS = ['plan-tick.mjs: one verdict per plan, never guessed', 'plan-tick.mjs: the driver lock has one owner',
  'plan-tick.mjs: one driver across plans, and an UNKNOWN that repeats stops',
  'pr-d1-applied.mjs: a pull request\'s D1 files are read from production, never assumed'];

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
    // The worker writes that state.md from the shape its agent file teaches, so
    // the shape is read back through decide() here: a worker that writes what
    // pr-worker.md shows is resumed, never parked under BLOCKED.
    const agentPath = join(repoRoot, '.claude', 'agents', 'pr-worker.md');
    const agent = fs.existsSync(agentPath) ? fs.readFileSync(agentPath, 'utf8') : '';
    const fence = /```\r?\n(STOPPED:[^]*?)```/.exec(agent)?.[1] ?? '';
    const taught = fence.replace(/<branch>/g, 'shared/feat/thing').replace(/<commit>/g, 'abc1234').replace(/<your own row>/g, '4');
    const taughtTick = tick({ stateText: taught, brief });
    check('pr-worker.md teaches a stopped state.md that plan-tick resumes from its Resume: line, on its own row',
      taughtTick.verdict === 'RESUME' && /^row 4 \(shared\/feat\/thing abc1234, /.test(taughtTick.detail),
      fence ? `${taughtTick.verdict} ${taughtTick.detail}` : 'no ``` fence opening STOPPED: in .claude/agents/pr-worker.md');
    check('pr-worker.md never has the worker write BLOCKED:, and its report may open PUSHED: <branch> <commit>',
      agent !== '' && !/`BLOCKED: </.test(agent) && !/`READY: …`, `DROPPED: …` or `BLOCKED: …`/.test(agent)
        && /`PUSHED: <branch> <commit>`/.test(agent));
    check('pr-worker.md counts the driver\'s merge in the four steps plan-rows gives it, not three calls',
      /four steps/.test(agent) && !/three calls/.test(agent)
        && /merge it by the four steps/.test(fs.readFileSync(join(repoRoot, '.claude', 'skills', 'plan-rows', 'SKILL.md'), 'utf8')));
    // The driver acts on the word plan-tick prints, and plan-rows is all it
    // reads: a verdict the skill never names is one the driver has no step for
    // (ADVANCE, RESUME and WAIT, 2026-11-21). The words are read off the lib's
    // own out('...') and verdict: '...' calls, so a new verdict fails here.
    const libSrc = fs.readFileSync(join(repoRoot, '.claude', 'scripts', 'plan-tick-lib.mjs'), 'utf8');
    const verdicts = [...new Set([...libSrc.matchAll(/\b(?:out\(|verdict: )'([A-Z-]+)'/g)].map((m) => m[1]))];
    const skill = fs.readFileSync(join(repoRoot, '.claude', 'skills', 'plan-rows', 'SKILL.md'), 'utf8');
    const unnamed = verdicts.filter((v) => !skill.includes(`\`${v}\``) && !skill.includes(`\`${v} `));
    check('plan-rows names every verdict plan-tick-lib can print, and passes --owner to --heartbeat and --release',
      verdicts.length >= 10 && !unnamed.length && /--heartbeat <plan> --owner <id>/.test(skill) && /--release <plan> --owner <id>/.test(skill),
      `${verdicts.length} verdicts read; not named: ${unnamed.join(', ') || 'none'}`);
    check('plan-rows runs the DONE clean-up on a still-armed plan, ending with the plan-driver task disabled',
      /--disarm <plan>/.test(skill) && /disable[sd]? the `plan-driver` task|`plan-driver` task disabled/i.test(skill));
    check('attemptsOf takes the highest attempt line for its row',attemptsOf('4', 'From row 4: attempt 2\nFrom row 4: attempt 3\nFrom row 44: attempt 9') === 3
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
    check('a lock that does not parse is null, which the script hands decide() as badLock',
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

  section('plan-tick.mjs: one driver across plans, and an UNKNOWN that repeats stops');
  {
    const now = Date.parse('2026-11-21T12:00:00Z');
    const brief = { exists: true, text: '# Row 4: x\n\nGroup `shared`, branch `shared/feat/thing`. Skills: `ship-pr`. Next row: 5.\n' };
    const next = 'NEXT: row 4 (brief: rows/4.md).\n';
    const r = (verdict, detail = '') => ({ verdict, detail });

    // Each plan used to be decided alone: A LIVE and B DRIVE both printed.
    const held = oneDriver([{ plan: 'a', result: r('LIVE', 'driver.lock heartbeat 1m old') }, { plan: 'b', result: r('DRIVE', 'row 4') },
      { plan: 'c', result: r('MERGE-FIRST', '#9') }, { plan: 'd', result: r('ADVANCE', '#8 merged') }, { plan: 'e', result: r('RESUME', 'row 2') },
      { plan: 'f', result: r('BLOCKED', 'x') }, { plan: 'g', result: r('UNKNOWN', 'gh failed') }]);
    const lines = held.map(({ plan, result }) => verdictLine(plan, result));
    check('while one plan is LIVE, every other plan\'s DRIVE, MERGE-FIRST, ADVANCE or RESUME is WAIT <plan> is live',
      lines[0] === 'a: LIVE driver.lock heartbeat 1m old' && lines[1] === 'b: WAIT a is live (held back: DRIVE row 4)'
        && ['c', 'd', 'e'].every((p, i) => held[i + 2].result.verdict === 'WAIT' && lines[i + 2].startsWith(`${p}: WAIT a is live (held back: `)),
      lines.join(' | '));
    check('WAIT cannot be claimed', !CLAIMABLE.includes('WAIT'));
    check('BLOCKED and UNKNOWN beside a LIVE plan are left as they are', lines[5] === 'f: BLOCKED x' && lines[6] === 'g: UNKNOWN gh failed');
    check('with no plan LIVE, nothing waits',
      oneDriver([{ plan: 'a', result: r('DRIVE') }, { plan: 'b', result: r('DRIVE') }]).every(({ result }) => result.verdict === 'DRIVE'));
    check('a plan does not wait on its own LIVE',
      oneDriver([{ plan: 'a', result: r('LIVE') }])[0].result.verdict === 'LIVE');

    // A corrupt lock was UNKNOWN on every tick, forever, with nothing written.
    const bad = tick2({ stateText: next, brief, badLock: true });
    check('a lock that does not parse is stale: the row is driven and the lock named in the detail',
      bad.verdict === 'DRIVE' && /driver\.lock does not parse, so it is treated as stale/.test(bad.detail), `${bad.verdict} ${bad.detail}`);
    const badStopped = tick2({ stateText: 'STOPPED: the cap.\nNEXT: row 4 (brief: rows/4.md).', brief, badLock: true });
    check('a STOPPED row under a lock that does not parse is RESUME, the lock named',
      badStopped.verdict === 'RESUME' && /does not parse/.test(badStopped.detail), `${badStopped.verdict} ${badStopped.detail}`);
    function tick2(input) { return decide({ now, pulls: [], merged: [], ...input }); }

    check('four UNKNOWN ticks become STOP (taken 2026-11-21; not two or eight)', UNKNOWN_TICKS === 4);
    let text = null;
    const seen = [];
    for (let i = 0; i < 5; i++) {
      const { count, result } = countUnknown(text, r('UNKNOWN', 'gh pr list failed'));
      seen.push(result.verdict);
      text = `${count}\n`;
    }
    check('an UNKNOWN on four consecutive ticks prints STOP, and stays STOP while it repeats',
      seen.join() === 'UNKNOWN,UNKNOWN,UNKNOWN,STOP,STOP', seen.join());
    const stopped = countUnknown('3\n', r('UNKNOWN', 'gh pr list failed'));
    check('the STOP names the count and the last reading',
      stopped.result.detail === 'UNKNOWN on 4 consecutive ticks, the last: gh pr list failed', stopped.result.detail);
    const cleared = countUnknown('3\n', r('DRIVE', 'row 4'));
    check('any verdict clears the count', cleared.count === 0 && cleared.result.verdict === 'DRIVE');
    check('an unreadable count starts again at one', countUnknown('garbage', r('UNKNOWN')).count === 1);

    // The script end to end, on scratch plans that need no gh reading: a LIVE
    // lock on a, a STOPPED row on b, a corrupt lock on c, no state.md on d.
    const root = fs.mkdtempSync(join(tmpdir(), 'plan-tick-plans-'));
    try {
      const script = join(repoRoot, '.claude', 'scripts', 'plan-tick.mjs');
      const plan = (name, state, lock) => {
        fs.mkdirSync(join(root, name, 'rows'), { recursive: true });
        fs.writeFileSync(join(root, name, 'armed'), 'armed\n');
        if (state !== null) fs.writeFileSync(join(root, name, 'state.md'), state);
        fs.writeFileSync(join(root, name, 'rows', '4.md'), brief.text);
        if (lock !== null) fs.writeFileSync(join(root, name, 'driver.lock'), lock);
      };
      const stop = 'STOPPED: the cap.\nResume: shared/feat/thing abc1234\nNEXT: row 4 (brief: rows/4.md).\n';
      plan('a', stop, lockText(Date.now(), 'aaaa', null));
      plan('b', stop, null);
      plan('c', stop, 'garbage\n');
      plan('d', null, null);
      const runTick = (...extra) => spawnSync(process.execPath, [script, '--root', root, ...extra], { encoding: 'utf8' });
      const ticks = [1, 2, 3, 4].map(() => runTick());
      const out = (t, p) => t.stdout.split('\n').find((l) => l.startsWith(`${p}: `)) ?? '';
      check('the script: a LIVE plan makes another plan\'s RESUME print WAIT',
        /^b: WAIT a is live \(held back: RESUME row 4/.test(out(ticks[0], 'b')), ticks[0].stdout + ticks[0].stderr);
      check('the script: a corrupt lock is stale, named, and the plan waits like any other',
        /^c: WAIT a is live \(held back: RESUME row 4 .*driver\.lock does not parse/.test(out(ticks[0], 'c')), out(ticks[0], 'c'));
      check('the script: UNKNOWN on three ticks exits 2, the fourth prints STOP and exits 0',
        ticks.slice(0, 3).every((t) => t.status === 2 && out(t, 'd') === 'd: UNKNOWN no state.md')
          && ticks[3].status === 0 && out(ticks[3], 'd') === 'd: STOP UNKNOWN on 4 consecutive ticks, the last: no state.md',
        ticks.map((t) => `${t.status} ${out(t, 'd')}`).join(' | '));
      const claim = runTick('--claim', 'b');
      check('the script: --claim on a plan that waits exits 1 and writes no lock',
        claim.status === 1 && !fs.existsSync(join(root, 'b', 'driver.lock')), claim.stdout + claim.stderr);
      fs.writeFileSync(join(root, 'd', 'state.md'), 'DONE\n');
      runTick();
      check('the script: a verdict deletes unknown.count', !fs.existsSync(join(root, 'd', 'unknown.count')));
      fs.unlinkSync(join(root, 'a', 'driver.lock'));
      const take = runTick('--claim', 'c', '--session', 'scratch-1');
      check('the script: --claim takes over a lock that does not parse',
        take.status === 0 && parseLock(fs.readFileSync(join(root, 'c', 'driver.lock'), 'utf8'))?.session === 'scratch-1', take.stdout + take.stderr);
    } finally {
      fs.rmSync(root, { recursive: true, force: true });
    }
  }

  section('pr-d1-applied.mjs: a pull request\'s D1 files are read from production, never assumed');
  {
    // A MERGE-FIRST merged a green pull request with nothing reading whether its
    // migrations were applied (`ship-pr` -> *The ordering rule*). The script asks
    // `d1-apply.mjs --check --remote`; its output here is shaped on a real run of
    // 2026-11-22 (one recorded migration, one scratch file production lacks).
    const byDb = d1FilesByDb(['db/migrations/094-x.sql', 'db/migrations/marvel/095-m.sql', 'db/migrations/tools/096-t.sql',
      'apps/character-creator/db/~400-y.sql', 'db/schema.sql', 'db/schema-marvel.sql', 'db/seed-catalogs.sql',
      '.claude/skills/class-import/reference/data-script.sql', 'apps/character-creator/db/sub/z.sql', 'apps/character-creator/js/a.js',
      'db\\migrations\\097-win.sql', '']);
    check('the D1 files are migrations (palladium, marvel, tools) and data scripts directly in apps/character-creator/db, by database',
      JSON.stringify([...byDb]) === JSON.stringify([['palladium', ['db/migrations/094-x.sql', 'apps/character-creator/db/~400-y.sql', 'db/migrations/097-win.sql']],
        ['marvel', ['db/migrations/marvel/095-m.sql']], ['tools', ['db/migrations/tools/096-t.sql']]]), JSON.stringify([...byDb]));
    check('a diff with no migration or data script has no D1 files',
      d1FilesByDb(['db/schema.sql', 'README.md', '.claude/scripts/plan-tick.mjs']).size === 0);

    const T = 'C:\\Users\\x\\AppData\\Local\\Temp\\pr-d1-9-abc\\db\\migrations\\';
    const files = [`${T}093-gear-slug-check.sql`, `${T}999-nothing-here.sql`];
    const plan = (rows) => '\n!! --skip-preflight: read-back assertions will NOT be checked before applying. !!\n\n'
      + `--check: ${rows.length} file(s) would be applied to --remote (palladium: DB), in this order:\n${rows.map((r) => `  ${r}\n`).join('')}\nNothing was applied.\n`;
    const mixed = parseCheck({ status: 0, stdout: plan([`${files[0]}   <- ALREADY RECORDED on this target`, files[1]]) }, files);
    check('--check output reads as recorded and unrecorded basenames',
      JSON.stringify(mixed) === JSON.stringify({ recorded: ['093-gear-slug-check.sql'], unrecorded: ['999-nothing-here.sql'], localOnly: [] }), JSON.stringify(mixed));
    check('one unrecorded file is D1 NOT APPLIED, exit 1, naming only it',
      JSON.stringify(d1Verdict([{ db: 'palladium', files, parsed: mixed }])) === JSON.stringify({ code: 1, line: 'D1 NOT APPLIED 999-nothing-here.sql' }));
    const all = parseCheck({ status: 0, stdout: plan(files.map((f) => `${f}   <- ALREADY RECORDED on this target`)) }, files);
    check('every file recorded is D1 APPLIED, exit 0',
      JSON.stringify(d1Verdict([{ db: 'palladium', files, parsed: all }])) === JSON.stringify({ code: 0, line: 'D1 APPLIED 093-gear-slug-check.sql 999-nothing-here.sql' }));
    check('another database is named beside its file',
      d1Verdict([{ db: 'palladium', files, parsed: all }, { db: 'marvel', files: ['095-m.sql'], parsed: { recorded: [], unrecorded: ['095-m.sql'], localOnly: [] } }]).line
        === 'D1 NOT APPLIED 095-m.sql (marvel)');
    check('no D1 files is NO D1 FILES, exit 0', JSON.stringify(d1Verdict([])) === JSON.stringify({ code: 0, line: 'NO D1 FILES' }));

    const unread = [
      ['a ledger it could not read', { status: 0, stdout: plan(files) + '  (could not read which files this target has recorded)\n' }],
      ['a non-zero exit', { status: 1, stdout: '', stderr: '\nd1-apply: x.sql: contains CR\n' }],
      ['no plan printed', { status: 0, stdout: 'Nothing was applied.\n' }],
      ['a file the plan does not list', { status: 0, stdout: plan([files[0]]) }],
    ].map(([why, r]) => [why, d1Verdict([{ db: 'palladium', files, parsed: parseCheck(r, files) }])]);
    check('an answer that cannot be read is D1 UNREADABLE, exit 2, never a pass: ' + unread.map(([w]) => w).join(', '),
      unread.every(([, v]) => v.code === 2 && v.line.startsWith('D1 UNREADABLE palladium: ')), unread.map(([w, v]) => `${w}: ${v.code} ${v.line}`).join(' | '));
    check('a non-zero exit carries d1-apply\'s own reason', /contains CR/.test(unread[1][1].line), unread[1][1].line);

    const seed = `${T}seed-dev.sql`;
    const skipped = parseCheck({ status: 0, stdout: `skipping ${seed} \u2014 marked local-only; apply it on its own.\n` + plan([files[1]]) }, [seed, files[1]]);
    check('a local-only file is left out, not called unapplied', JSON.stringify(skipped.unrecorded) === '["999-nothing-here.sql"]' && skipped.localOnly[0] === 'seed-dev.sql', JSON.stringify(skipped));
    const onlySeed = parseCheck({ status: 1, stdout: `skipping ${seed} \u2014 marked local-only; apply it on its own.\n`,
      stderr: '\nd1-apply: nothing left to apply: every file given is local-only\n' }, [seed]);
    check('a diff whose only D1 file is local-only is not a failure',
      d1Verdict([{ db: 'palladium', files: [seed], parsed: onlySeed }]).code === 0, JSON.stringify(onlySeed));

    const usage = spawnSync(process.execPath, [join(repoRoot, '.claude', 'scripts', 'pr-d1-applied.mjs')], { encoding: 'utf8' });
    check('the script with no pull request number exits 2', usage.status === 2, `${usage.status} ${usage.stderr}`);
  }
}
