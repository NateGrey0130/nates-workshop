// What the machine's own `~/.claude/CLAUDE.md` may say about this repo.
//
// That file loads into EVERY session on this machine regardless of working
// directory, which gives it the widest reach of any instruction file here - and
// until this check it had the least enforcement of any of them: none. Nothing
// in this tree reads it, no grep reaches it, and it is checked in nowhere.
// SETUP.md's *The answer is a pointer at the user level* paragraph has the
// argument for why it exists and why it stays a pointer.
//
// ── what goes wrong, three times now ─────────────────────────────────────────
//
// Every failure has been the same shape: a sentence in that file restating a
// fact this repo owns, true when written, false later, with nothing walking
// from the change to the sentence.
//
//   2026-09-02  it named the previous working directory and undercounted the
//               skills by three            (MACHINE-AUDIT.md M12)
//   2026-09-03  it enumerated what the working directory holds and went short
//               the same day it was written  (MACHINE-AUDIT.md M19, PR #612)
//   2026-09-20  it said "ten skills" and called `book-reconcile` THE subagent,
//               by then one of five under .claude/agents/
//
// Each was found by a person reading the file, and each was fixed by deleting
// the claim rather than syncing it. M19's remedy is the one this check
// generalises: where the file wanted to enumerate, it now says "List it if you
// need to know what is in it" and names no contents at all.
//
// ── why this cannot be a CI gate, and is not a defect that it is not ─────────
//
// The file is outside the repo and does not exist on a GitHub runner, so a
// required check could only ever skip there. This runs in the local smoke suite
// instead - which ship-pr step 4 puts before every PR, so it fires at the point
// the file would be edited. Off this machine it asserts nothing and says so,
// the same way instruction-paths.mjs declines to resolve Windows paths on Linux.
//
// checks/instruction-paths.mjs is the near neighbour and deliberately does NOT
// cover this: its ROOTS are the four repo-relative paths of the instruction
// layer, read 2026-09-21, and a path outside the repo is not among them.
//
// ── what it asserts, and why only these two things ───────────────────────────
//
// Names are matched ONLY inside backticks, which is how this repo writes them
// and how both 2026-09-20 drifts appeared. A bare substring match is not an
// option: `take` is a skill directory AND an ordinary English word, and
// "take the finding" would fail a file that had done nothing wrong.
//
// Counts are matched as a number word or digit directly before skills/agents.
// The repo's own CLAUDE.md is REQUIRED to carry that count - documented-counts.mjs
// asserts it at 'and says how many there are' - which is the whole point: a
// count belongs where a check pins it, and nowhere else. Pinning the number in
// two files would make the unpinned copy exactly the liability it already was.
//
// WHAT IT CANNOT DO. It does not detect a prose enumeration that names no
// backticked entity, which is the shape M19 took - "the sourcebook PDFs, the
// loose briefs" names nothing this tree can enumerate back. Nor does it judge
// whether a path or a pointer is still true; instruction-paths.mjs answers the
// first of those for the repo's own files and nothing answers the second. This
// is a narrow gate on the two shapes that have actually recurred, not a
// staleness detector.

import { readFileSync, existsSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { homedir } from 'node:os';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Machine instruction file'];

const MACHINE_FILE = join(homedir(), '.claude', 'CLAUDE.md');

// The number words this repo writes counts in, plus digits. Bounded at twenty:
// past that a count is written as a numeral here anyway, and \d+ covers it.
const COUNT = /\b(?:\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty)\s+(?:skills?|agents?|subagents?)\b/gi;

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Machine instruction file');

  if (!existsSync(MACHINE_FILE)) {
    check('the machine instruction file is not on this host', true,
      `${MACHINE_FILE} absent - this section is local-only and asserts nothing here`);
    return;
  }

  const text = readFileSync(MACHINE_FILE, 'utf8');

  const skills = readdirSync(join(repoRoot, '.claude', 'skills'), { withFileTypes: true })
    .filter((e) => e.isDirectory()).map((e) => e.name);
  const agents = readdirSync(join(repoRoot, '.claude', 'agents'), { withFileTypes: true })
    .filter((e) => e.isFile() && e.name.endsWith('.md'))
    .map((e) => e.name.replace(/\.md$/, ''));

  const named = [...skills, ...agents].filter((n) => text.includes('`' + n + '`'));
  check('it names no individual skill or agent of this repo',
    named.length === 0,
    `${named.join(', ')} - the repo's own CLAUDE.md carries that list and documented-counts.mjs pins it there`);

  const counts = [...text.matchAll(COUNT)].map((m) => m[0].replace(/\s+/g, ' '));
  check('and states no count of them',
    counts.length === 0,
    `${counts.join('; ')} - a count here is pinned by nothing and has gone stale twice`);
}
