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
// A menu and its `.closed.md` split are ONE numbering space: a finding moved
// between them when it closed, and the number moved with it. The splits went
// to git history on 2026-10-22; one that reappears in a tree is still grouped
// with its menu below.
//
// What counts as a finding is a heading `## F12 — ...` / `### G7 - ...`: a
// letter prefix, a number, then a dash. Follow-up headings such as
// `## F41 is closed, 2026-09-09` name a finding without being one, and the
// dash is what tells them apart. One menu, `apps/pick3cut5/AUDIT.md`, writes
// `### F1. Title` instead, and until 2026-09-27 its findings were invisible
// here, so a full stop counts as the separator too.
//
// A closed finding also leaves a one-line pointer stub in its live menu,
// `- **G1** — <title> — <outcome> — full text in <where>`, and the stub
// carries the number too, which is how a closed finding stays in this check
// now that the archives are gone, and how a finding stubbed in place does. A
// stub and a `.closed.md` heading of its number are the SAME finding, one
// that moved. A stub beside a live heading of that number, or a second stub,
// is a duplicate. The `— full text in ` is what makes a bullet a stub:
// `INGESTION-AUDIT.md` opens with a prose list `- **F18** — ...` that
// summarises findings rather than pointing at them.

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Audit menus number each finding once'];

// The finding heading. Exported so the check below can be proved against a
// fixture, and so a future reader of the menus parses the same shape.
export const FINDING_HEADING = /^#{2,4} ([A-Z]{1,3}\d+)[a-z]?(?: (?:—|-) |\. )/gm;

// { number: [line, ...] } for one file's text.
export function findingNumbers(text) {
  const out = {};
  for (const m of text.matchAll(FINDING_HEADING)) {
    const line = text.slice(0, m.index).split('\n').length;
    (out[m[1]] ??= []).push(line);
  }
  return out;
}

// The pointer stub a closed finding leaves in its live menu.
export const FINDING_STUB = /^- \*\*([A-Z]{1,3}\d+)[a-z]?\*\* — .* — full text in /gm;

// { number: [line, ...] } of one file's pointer stubs.
export function findingStubs(text) {
  const out = {};
  for (const m of text.matchAll(FINDING_STUB)) {
    const line = text.slice(0, m.index).split('\n').length;
    (out[m[1]] ??= []).push(line);
  }
  return out;
}

// The duplicates in one menu group, given { file: text }. A stub pairs with
// one `.closed.md` heading of its number; everything left over counts once.
export function duplicateFindings(texts) {
  const seen = {};
  for (const [f, text] of Object.entries(texts)) {
    const kind = f.endsWith('.closed.md') ? 'closed' : 'live';
    for (const [id, lines] of Object.entries(findingNumbers(text)))
      for (const line of lines) ((seen[id] ??= { live: [], closed: [], stub: [] })[kind]).push(`${f}:${line}`);
    for (const [id, lines] of Object.entries(findingStubs(text)))
      for (const line of lines) (seen[id] ??= { live: [], closed: [], stub: [] }).stub.push(`${f}:${line}`);
  }
  const dups = [];
  for (const [id, { live, closed, stub }] of Object.entries(seen)) {
    const moved = Math.min(stub.length, closed.length);
    if (live.length + closed.length + stub.length - moved > 1)
      dups.push(`${id} at ${[...live, ...closed, ...stub].join(' and ')}`);
  }
  return { ids: Object.keys(seen).length, dups };
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
      '### F4. the full-stop form pick3cut5 uses',
      '## F4.5 is not a heading form anyone writes',
    ].join('\n');
    const got = findingNumbers(fixture);
    check('the finding-heading parser reads both dash forms and the full stop, and skips follow-ups',
      JSON.stringify(got) === JSON.stringify({ F1: [1], F2: [2, 5], F3: [4], F4: [6] }), JSON.stringify(got));
  }

  {
    const stubs = [
      '- **G1** — high — moved — Taken — full text in `X.closed.md` under its own `### G1` heading.',
      '- **G2** — a prose summary of a finding, not a pointer',
      '  - **G3** — indented — full text in `X.closed.md`',
      '- **G4a** — lettered — full text in `git show abc:X.closed.md` under its own `## G4a` heading.',
    ].join('\n');
    const got = findingStubs(stubs);
    check('the pointer-stub parser reads a stub, drops the letter suffix, and skips prose bullets',
      JSON.stringify(got) === JSON.stringify({ G1: [1], G4: [4] }), JSON.stringify(got));

    const stub = (id) => `- **${id}** — t — Taken — full text in \`X.closed.md\` under its own \`### ${id}\` heading.`;
    const cases = [
      ['a stub and its .closed.md heading are one finding', { 'X.md': stub('G1'), 'X.closed.md': '### G1 — t' }, []],
      ['a stub with no archive behind it is one finding', { 'X.md': stub('G1') }, []],
      ['a stub beside a live heading is a duplicate', { 'X.md': `${stub('G1')}\n### G1 — t` }, ['G1']],
      ['two stubs are a duplicate', { 'X.md': `${stub('G1')}\n${stub('G1')}`, 'X.closed.md': '### G1 — t' }, ['G1']],
      ['a live and a closed heading are still a duplicate', { 'X.md': '### G1 — t', 'X.closed.md': '### G1 — t' }, ['G1']],
    ];
    for (const [name, texts, want] of cases) {
      const { dups } = duplicateFindings(texts);
      check(`duplicate rule: ${name}`,
        JSON.stringify(dups.map((d) => d.split(' ')[0])) === JSON.stringify(want), dups.join('; '));
    }
  }

  const groups = menuGroups();
  check('there are audit menus to read', Object.keys(groups).length > 0);
  let findings = 0;
  const dups = [];
  for (const [menu, files] of Object.entries(groups)) {
    const texts = Object.fromEntries(files.map((f) => [f, readFileSync(join(repoRoot, f), 'utf8')]));
    const got = duplicateFindings(texts);
    findings += got.ids;
    for (const d of got.dups) dups.push(`${menu} ${d}`);
  }
  check('the menus hold findings', findings > 0, `${findings} finding numbers`);
  check('no menu uses a finding number twice (renumber the one your branch added)',
    dups.length === 0, dups.join('; '));
}
