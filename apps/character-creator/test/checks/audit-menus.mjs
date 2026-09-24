// Audit menus: each finding number is used once per menu.
//
// Two book sessions run in parallel, each in its own worktree, and each files
// deferred code findings into the same menu - BOOK-INGEST-AUDIT.md. Both take
// "the next number", so both write F109. Appending at the end of the file
// usually makes git conflict, but resolving that conflict by keeping both
// halves leaves two F109 headings, and nothing read the headings until this.
// A duplicate number breaks `/take <MENU> <ID>` and every citation of it
// (`F41` is cited from class notes, data scripts and other menus).
//
// A menu and its `.closed.md` split are ONE numbering space: a finding moves
// between them when it closes, and the number moves with it.
//
// What counts as a finding is a heading `## F12 — ...` / `### G7 - ...`: a
// letter prefix, a number, then a dash. Follow-up headings such as
// `## F41 is closed, 2026-09-09` name a finding without being one, and the
// dash is what tells them apart. Measured 2026-09-24: 527 findings across 22
// menus, no number used twice.

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Audit menus number each finding once'];

// The finding heading. Exported so the check below can be proved against a
// fixture, and so a future reader of the menus parses the same shape.
export const FINDING_HEADING = /^#{2,4} ([A-Z]{1,3}\d+)[a-z]? (?:—|-) /gm;

// { number: [line, ...] } for one file's text.
export function findingNumbers(text) {
  const out = {};
  for (const m of text.matchAll(FINDING_HEADING)) {
    const line = text.slice(0, m.index).split('\n').length;
    (out[m[1]] ??= []).push(line);
  }
  return out;
}

// Every tracked menu, grouped with its `.closed.md` split.
function menuGroups() {
  const files = execFileSync('git', ['ls-files'], { cwd: repoRoot, encoding: 'utf8' })
    .split('\n')
    .filter((f) => /AUDIT[^/]*\.md$/.test(f) && !f.startsWith('docs/prompts/'));
  const groups = {};
  for (const f of files) (groups[f.replace(/\.closed\.md$/, '.md')] ??= []).push(f);
  return groups;
}

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  section('Audit menus number each finding once');

  // The parser first, against a fixture, so a regex that matched nothing
  // cannot pass the real check below by finding no duplicates.
  {
    const fixture = [
      '### F1 — low — a finding',
      '### F2 - another, hyphen form',
      '## F2 is closed, 2026-09-09',
      '#### F3 — a deeper heading',
      '### F2 — the collision',
    ].join('\n');
    const got = findingNumbers(fixture);
    check('the finding-heading parser reads both dash forms and skips follow-ups',
      JSON.stringify(got) === JSON.stringify({ F1: [1], F2: [2, 5], F3: [4] }), JSON.stringify(got));
  }

  const groups = menuGroups();
  check('there are audit menus to read', Object.keys(groups).length > 0);
  let findings = 0;
  const dups = [];
  for (const [menu, files] of Object.entries(groups)) {
    const seen = {};
    for (const f of files) {
      const nums = findingNumbers(readFileSync(join(repoRoot, f), 'utf8'));
      for (const [id, lines] of Object.entries(nums)) {
        for (const line of lines) (seen[id] ??= []).push(`${f}:${line}`);
        findings += lines.length;
      }
    }
    for (const [id, where] of Object.entries(seen)) {
      if (where.length > 1) dups.push(`${menu} ${id} at ${where.join(' and ')}`);
    }
  }
  check('the menus hold findings', findings > 0, `${findings} finding headings`);
  check('no menu uses a finding number twice (renumber the one your branch added)',
    dups.length === 0, dups.join('; '));
}
