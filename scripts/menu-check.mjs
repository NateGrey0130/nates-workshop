// Does every claim this menu makes about ANOTHER FILE say where it read it?
//
//   node scripts/menu-check.mjs                 lines added vs origin/main (what CI runs)
//   node scripts/menu-check.mjs --all           every audit menu, whole file
//   node scripts/menu-check.mjs FILE [FILE...]  named files, whole file
//
// WHAT THIS IS FOR, and it is a narrow thing. `SHIP-PR-AUDIT` filed fourteen
// findings on 2026-09-03. Four rested on a false premise and ALL FOUR were the
// same shape: a claim about what some other file said.
//
//   REPO-AUDIT G7  "that shape exists only inside the ship-pr skill"  - it was in no file
//   SHIP-PR F12    asked audit-menu to say a thing it already said in the paragraph above
//   SHIP-PR F14    "beside the existing exit-code material" in windows-shell - there is none
//
// Those four were caught, every one, when the finding was taken. Nothing wrong
// shipped. The cost was rework and a menu Nate could not read and believe.
//
// THE RULES TO CATCH THEM ALREADY EXISTED AND DID NOT FIRE. `audit-menu` has
// said "an absence claim needs a fresh read, not a grep" since 2026-08-28, and
// META-AUDIT A10's hand-over pass - re-run every command the menu quotes -
// landed on main at 17:16 on 2026-09-03. The menu was filed at 20:48, three and
// a half hours later, by someone who had just read both. A10's own text names
// the gap it leaves: "a finding with no command to re-run is not verified by
// it." A sentence like "the convention exists only inside ship-pr" quotes no
// command, so the pass walks straight past it.
//
// So this is not a sixth rule. It is the fifth rule given something that runs.
//
// WHAT IT CANNOT DO: it cannot tell whether a claim is TRUE. Truth needs the
// file open. What it can do is refuse to let the sentence stay invisible - every
// external claim has to name a file, a command or a date, and naming one is what
// makes an author go and look. That is the whole mechanism.
//
// WHY ADDED LINES ONLY, by default. Ten menus and 159 findings predate this and
// retrofitting them would be a large edit to files that are RECORDS. CI diffs
// against origin/main and judges only what a PR adds, so the convention starts
// where it can be met and no existing measurement is rewritten.

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';

// The phrasings an external claim actually takes. Every one of these was read
// off a real false premise or its correction; none is a guess about what
// someone might write. Keep this list SHORT - a matcher that fires on ordinary
// prose gets suppressed wholesale, and then it catches nothing at all.
const CLAIM_PATTERNS = [
  [/\bappears? nowhere\b/i,                'appears nowhere'],
  [/\bexists? nowhere\b/i,                 'exists nowhere'],
  [/\bnowhere in\b/i,                      'nowhere in'],
  [/\b(exists?|lives?|is|are) only (in|inside)\b/i, 'exists only in'],
  [/\bdoes not (mention|say|carry|name)\b/i, 'does not mention'],
  [/\bnever (mentions?|says?|names?)\b/i,   'never mentions'],
  [/\bno mention of\b/i,                    'no mention of'],
  [/\bsays? nothing about\b/i,              'says nothing about'],
  [/\balready (says?|said|states?|carries|contains?)\b/i, 'already says'],
  [/\bnames? none\b/i,                      'names none'],
  [/\bthere is no such\b/i,                 'there is no such'],
  [/\b(is|are) not (in|anywhere in)\b/i,    'is not in'],
  // "beside the existing exit-code material" asserts nothing outright, and it
  // was the hardest of the four to see. It PRESUPPOSES the material exists,
  // which is exactly why nobody went and checked. There was none.
  [/\bthe existing\b/i,                     'the existing <thing>'],
];

// THE SHAPE IS "a claim about ANOTHER FILE", so the sentence has to name one.
// Without this the matcher fires on ordinary argument and gets suppressed.
//
// A kebab-case backticked token is how every skill and menu is named here -
// `ship-pr`, `audit-menu`, `windows-shell`. The hyphen is what keeps it off
// ordinary identifiers, which are snake_case or dotted in this repo.
const NAMES_A_FILE =
  /`[^`]*(?:[/\\][^`]*|\.(?:md|mjs|js|yml|yaml|sql|json|py|html|css|txt))`|`[a-z][a-z0-9]*(?:-[a-z0-9]+)+`/i;

// A reference to the finding or brief IN HAND is not a claim about another file.
// "the proposal does not mention X" is checkable by reading one paragraph up,
// which is where those sentences already are.
// Deliberately NARROW. A first draft also listed paragraph, sentence, section,
// rule and header, and that version suppressed "place the new paragraph beside
// the existing exit-code material" - one of the four this check exists for. A
// suppressor that swallows the case you built the thing for is worse than none.
const SAME_DOCUMENT =
  /\b(this|the|its|that)\s+(finding|proposal|brief)\b/i;

// What counts as saying where you read it.
//
// A BACKTICKED PATH DOES NOT COUNT, and that is the whole correction this list
// went through. "the convention exists only inside the `ship-pr` skill" names
// the file and is still false - naming the file you are making a claim about is
// not evidence that you opened it. Only a command, a date or a line number says
// somebody actually looked.
const CITED = [
  /\b20\d\d-\d\d-\d\d\b/,                      // a date
  /\b(grep|rg|gh|git|node|npx|awk|sed|wc|Read|read on)\b/, // something re-runnable
  /\bline[s]? \d+/i,                           // line 204, lines 100-116
  /<!--\s*claim-ok\b/,                         // deliberate escape hatch
];

const MENU_GLOBS = /(^|[/\\])([A-Z0-9-]*AUDIT[A-Z0-9-]*\.md|AUDIT\.md)$/;

function sh(cmd, args) {
  return execFileSync(cmd, args, { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
}

// A finding's citation can sit on a neighbouring line - prose wraps at 80 here,
// so "the paragraph" is the unit a human reads, not the line. Look at the whole
// paragraph the hit lives in.
function paragraphAround(lines, i) {
  let a = i, b = i;
  while (a > 0 && lines[a - 1].trim() !== '') a--;
  while (b < lines.length - 1 && lines[b + 1].trim() !== '') b++;
  return lines.slice(a, b + 1).join(' ');
}

// The file being claimed about has to be NEAR the claim, not merely somewhere in
// the same paragraph. Judged against the whole paragraph the corpus went from 23
// hits to 81, because any kebab-case token four lines away vouched for a
// sentence it had nothing to do with. One line either side is the wrap window -
// enough for "material in the / `windows-shell` skill", and no more.
function windowAround(lines, i) {
  return lines.slice(Math.max(0, i - 1), i + 2).join(' ');
}

function scanText(file, text) {
  const lines = text.split(/\r?\n/);
  const out = [];
  let inFence = false;
  for (let i = 0; i < lines.length; i++) {
    const L = lines[i];
    if (/^\s*```/.test(L)) { inFence = !inFence; continue; }
    if (inFence) continue;                       // a code block is evidence, not a claim
    for (const [rx, label] of CLAIM_PATTERNS) {
      if (!rx.test(L)) continue;
      if (SAME_DOCUMENT.test(L)) break;
      const para = paragraphAround(lines, i);
      if (!NAMES_A_FILE.test(windowAround(lines, i))) break;
      if (CITED.some((c) => c.test(para))) break;
      out.push({ file, line: i + 1, label, text: L.trim() });
      break;                                     // one report per line
    }
  }
  return out;
}

// The CI mode: only what this branch ADDS to a menu.
function scanDiff(base) {
  const files = sh('git', ['diff', '--name-only', `${base}...HEAD`])
    .split('\n').filter((f) => f && MENU_GLOBS.test(f));
  const out = [];
  for (const f of files) {
    if (!fs.existsSync(f)) continue;             // deleted in this branch
    const diff = sh('git', ['diff', '-U0', `${base}...HEAD`, '--', f]).split(/\r?\n/);
    let lineNo = 0;
    for (const d of diff) {
      const h = d.match(/^@@ -\d+(?:,\d+)? \+(\d+)/);
      if (h) { lineNo = Number(h[1]); continue; }
      if (!d.startsWith('+') || d.startsWith('+++')) continue;
      const body = d.slice(1);
      // Judge the added line against the paragraph as it now stands in the file,
      // so a citation added on the line above still counts.
      const whole = fs.readFileSync(f, 'utf8').split(/\r?\n/);
      const idx = lineNo - 1;
      for (const [rx, label] of CLAIM_PATTERNS) {
        if (!rx.test(body)) continue;
        if (SAME_DOCUMENT.test(body)) break;
        const inFile = idx >= 0 && idx < whole.length;
        const para = inFile ? paragraphAround(whole, idx) : body;
        if (!NAMES_A_FILE.test(inFile ? windowAround(whole, idx) : body)) break;
        if (CITED.some((c) => c.test(para))) break;
        out.push({ file: f, line: lineNo, label, text: body.trim() });
        break;
      }
      lineNo++;
    }
  }
  return { files, findings: out };
}

const argv = process.argv.slice(2);
let files = [];
let findings = [];
let mode;

if (argv.includes('--all')) {
  mode = 'every audit menu, whole file';
  files = sh('git', ['ls-files']).split('\n').filter((f) => f && MENU_GLOBS.test(f));
  for (const f of files) findings.push(...scanText(f, fs.readFileSync(f, 'utf8')));
} else if (argv.length && !argv[0].startsWith('--')) {
  mode = 'named files, whole file';
  files = argv;
  for (const f of files) findings.push(...scanText(f, fs.readFileSync(f, 'utf8')));
} else {
  const base = process.env.MENU_CHECK_BASE || 'origin/main';
  mode = `lines added vs ${base}`;
  const r = scanDiff(base);
  files = r.files;
  findings = r.findings;
}

console.log(`Menu claim check - ${mode}`);
console.log(`  ${files.length} menu file(s) in scope\n`);

if (!files.length) {
  console.log('  No audit menu touched. Nothing to check.');
  process.exit(0);
}

if (!findings.length) {
  console.log('  Every external claim names a file, a command or a date.');
  process.exit(0);
}

console.log(`  ${findings.length} claim(s) about another file with nothing saying where it was read:\n`);
for (const f of findings) {
  console.log(`  ${f.file}:${f.line}  [${f.label}]`);
  console.log(`    ${f.text.length > 100 ? f.text.slice(0, 100) + '...' : f.text}\n`);
}
console.log(`Each of these asserts what some other file does or does not say.`);
console.log(`Open that file, read the section, and put the path, the grep or the date`);
console.log(`in the same paragraph. If the phrasing is not a claim about another`);
console.log(`file, mark the line "<!-- claim-ok: why -->" and it is ignored.`);
console.log(`\naudit-menu -> "A claim about another file is the one that fails"`);
process.exit(1);
