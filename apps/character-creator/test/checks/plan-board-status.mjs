// .claude/scripts/plan-board.mjs says where a plan stands, and it is read at a
// glance, so a wrong word is believed. The decisions live in
// .claude/scripts/plan-board-lib.mjs and are driven here with text shaped like
// a real state.md, real briefs and `gh pr list` rows.
//
// The cases come from the plans on disk on 2026-11-18: a book plan whose rows
// come in pairs on one branch (an extraction row with no pull request of its
// own, then the row that ships it), a state.md left at READY with no NEXT line
// under it after its pull request merged, and a row split into lettered rows.

import { check, section, wantSection } from '../harness.mjs';
import { compareIds, deriveRows, indexPulls, parseBrief, parseState }
  from '../../../../.claude/scripts/plan-board-lib.mjs';

const SECTIONS = ['plan-board.mjs: a row is called done only on evidence'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('plan-board.mjs: a row is called done only on evidence');
  {
    const next = parseState('NEXT: row 30 (brief: rows/30.md), then row 31.\r\n'
      + 'Last row: 29 PUSHED, pal/data/book-npcs-d at 930219cd, no pull request.\r\nIn flight: nothing.\r\n');
    check('a NEXT line gives the row, the row after it, and the last row',
      next.kind === 'NEXT' && next.nextId === '30' && next.thenId === '31' && next.lastRowId === '29'
        && next.inFlight === 'nothing.', JSON.stringify(next));
    check('DONE is read off the first line', parseState('DONE\nLast row: 61 MERGED, #2255.').kind === 'DONE');
    const ready = parseState('READY: https://github.com/o/r/pull/9 (row 4)\nNEXT: row 5 (brief: rows/5.md), then row 6.');
    check('READY keeps the NEXT line under it', ready.kind === 'READY' && ready.nextId === '5', JSON.stringify(ready));
    check('READY with no NEXT under it is still READY, with no position',
      parseState('READY: https://github.com/o/r/pull/9').kind === 'READY'
        && parseState('READY: https://github.com/o/r/pull/9').nextId === null);
    check('BLOCKED is read, and names no row by itself',
      parseState('BLOCKED: the survey pull request is not merged.').kind === 'BLOCKED');
    check('a first line that is none of the four is UNKNOWN, not guessed at',
      parseState('Row 3 is nearly there').kind === 'UNKNOWN' && parseState('').kind === 'UNKNOWN'
        && parseState('NEXT: see the plan').kind === 'UNKNOWN');

    check('run order is the number, then a split\'s letters',
      ['10', '9b', '2', '9', '9a'].sort(compareIds).join() === '2,9,9a,9b,10');

    const brief = parseBrief('7', '# Row 7: extract the vehicles (printed 113-124)\r\n\r\n'
      + 'Group `palladium`, branch `pal/data/book-arms` (new, from `origin/main`). Skills: `ship-pr`. Next row: 8.\r\n');
    check('a brief gives its title and its branch',
      brief.id === '7' && brief.title === 'extract the vehicles (printed 113-124)' && brief.branch === 'pal/data/book-arms',
      JSON.stringify(brief));
    check('a brief with no branch has none, and still has a title',
      parseBrief('1', '# Row 1: decide the order\n\nNo code changes.').branch === null);

    // Three pairs and a close-out: 1+2 on branch a, 3+4 on b, 5+6 on c, 7 alone.
    const briefs = [
      ['1', 'a'], ['2', 'a'], ['3', 'b'], ['4', 'b'], ['5', 'c'], ['6', 'c'], ['7', 'close'],
    ].map(([id, b]) => ({ id, title: `row ${id}`, branch: `pal/data/${b}` }));
    const pr = (number, branch, state) => ({ number, state, headRefName: `pal/data/${branch}`, url: `u/${number}`, mergedAt: null });
    const statuses = (state, pulls) => deriveRows(parseState(state), briefs, pulls).rows.map((r) => r.status).join();

    const mid = 'NEXT: row 4 (brief: rows/4.md), then row 5.\nLast row: 3 PUSHED.\nIn flight: nothing.';
    check('a merged branch marks both its rows; a pushed extraction row is pushed, not merged',
      statuses(mid, indexPulls([pr(11, 'a', 'MERGED')])) === 'merged,merged,pushed,next,pending,pending,pending',
      statuses(mid, indexPulls([pr(11, 'a', 'MERGED')])));
    const counted = deriveRows(parseState(mid), briefs, indexPulls([pr(11, 'a', 'MERGED')]));
    check('and the count is the rows behind the position', counted.done === 3 && counted.total === 7,
      `${counted.done}/${counted.total}`);
    check('without GitHub the same position reads done and pushed, never merged',
      statuses(mid, null) === 'pushed,done,pushed,next,pending,pending,pending', statuses(mid, null));

    const readyRow = 'READY: u/12\nNEXT: row 5 (brief: rows/5.md), then row 6.';
    const open = deriveRows(parseState(readyRow), briefs, indexPulls([pr(11, 'a', 'MERGED'), pr(12, 'b', 'OPEN')]));
    check('an open pull request is open on the row that ships it, and is not counted done',
      open.rows.map((r) => r.status).join() === 'merged,merged,pushed,open,next,pending,pending' && open.done === 3,
      `${open.rows.map((r) => r.status).join()} ${open.done}`);

    check('a merged pull request beats a position that has not caught up',
      statuses('NEXT: row 2 (brief: rows/2.md), then row 3.', indexPulls([pr(11, 'a', 'MERGED')])).startsWith('merged,merged,pending'));
    check('a closed pull request is not a merge: the position decides',
      statuses(mid, indexPulls([pr(11, 'a', 'CLOSED')])).startsWith('pushed,done,pushed,next'));
    check('a merged pull request wins over a closed one on the same branch, whichever is newer',
      indexPulls([pr(11, 'a', 'MERGED'), pr(15, 'a', 'CLOSED')]).get('pal/data/a').number === 11);

    check('DONE puts every row behind the position', statuses('DONE', null) === 'pushed,done,pushed,done,pushed,done,done');
    check('READY alone, GitHub unread, is unknown for every row and counts none',
      statuses('READY: u/12', null) === Array(7).fill('unknown').join()
        && deriveRows(parseState('READY: u/12'), briefs, null).done === 0);
    check('BLOCKED falls back on the last row it names',
      statuses('BLOCKED: waiting on a ruling.\nLast row: 2 MERGED, #11.', null) === 'pushed,done,pending,pending,pending,pending,pending',
      statuses('BLOCKED: waiting on a ruling.\nLast row: 2 MERGED, #11.', null));

    const split = deriveRows(parseState('NEXT: row 3b (brief: rows/3b.md), then row 4.'),
      [...briefs, { id: '3a', title: 'first half', branch: 'pal/data/b' }, { id: '3b', title: 'second half', branch: 'pal/data/b2' }],
      null);
    const by = Object.fromEntries(split.rows.map((r) => [r.id, r.status]));
    check('a row replaced by lettered rows is split and is not counted',
      by['3'] === 'split' && by['3a'] === 'pushed' && by['3b'] === 'next' && split.total === 8 && split.done === 3,
      `${JSON.stringify(by)} ${split.done}/${split.total}`);
  }
}
