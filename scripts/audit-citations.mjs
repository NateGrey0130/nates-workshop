// Which published classes cite which audit finding?
//
//   node scripts/audit-citations.mjs --remote
//   node scripts/audit-citations.mjs --remote F10
//   node scripts/audit-citations.mjs --remote BOOK-INGEST-AUDIT F10
//   node scripts/audit-citations.mjs --local
//
// IT ANSWERS FOR BOOK-INGEST-AUDIT AND NOTHING ELSE, and it now says so instead
// of guessing. SKILL-AUDIT F30: the argument used to be selected with
// /^F\d+$/i, so `--remote G8` matched nothing, fell through to null, and printed
// the WHOLE unfiltered list as though no argument had been given - a confident
// answer to a question that was never asked. `audit-menu` establishes at least
// eleven finding prefixes across the menus, and its step 5 tells a taker to run
// this with the number they were given.
//
// The F-numbers are the subtler half and are covered too. PATTERNS below only
// ever match a BOOK-INGEST citation, so `--remote F30` returned "0 of 160
// (filtered to F30)" - true of BOOK-INGEST F30 and read as "no class cites
// SKILL-AUDIT F30", which is a different finding that this script cannot see. A
// zero now says which question it answered.
//
// BOOK-INGEST-AUDIT.md F12. A class's `extraction_notes` entry does two jobs in
// one paragraph. One is permanent - what the book prints and what was stored.
// The other is perishable - what the app could do on the day of the import. The
// perishable half rots inside a record that otherwise stays true, and nothing
// marked the seam.
//
// Taking a finding is supposed to correct every class note that cites it. That
// step was skipped once and the false claim reached production and stayed for
// three PRs; it was found by counting citations by hand, not by any check. This
// turns "who mentions F8" from a memory into a command.
//
// IT DELIBERATELY PARSES NO OUTCOME NOTES AND HAS NO OPINION ABOUT WHETHER A
// FINDING IS STILL TRUE. The `audit-menu` skill forbids a mechanical reader of
// those notes, because one has been wrong five times: they are prose - Taken,
// Adjusted, Closed, Moot, a bare date - sometimes under the heading, sometimes
// in a retirement section three hundred lines away, and INGESTION-AUDIT F14
// carries the note's own shape inside backticks as an example, so every grep
// reports it taken when it is open. This answers only who cites what. Whether
// the citation is stale is a judgement, and it stays with the person taking the
// finding.
//
// Read-only, and NO EXIT CODE OF ITS OWN - a gate here would fire on every class
// citing a still-open finding, which is the correct and useless answer. That
// holds for the refusal below as well: it prints and falls through, it does not
// exit. `test/smoke.mjs` pins the absence of an exit on this file's executable
// lines, and F30's own proposal said "say so and exit" without knowing that.

import { d1Query, targetFromArgv } from './d1-query-lib.mjs';

// The two shapes the corpus actually uses, measured rather than assumed:
// the full path, and the Galactic Tracer's "Filed as F6 in the Empire batch".
const PATTERNS = [
  /BOOK-INGEST-AUDIT\.md\s+(F\d+)/gi,
  /\bFiled as\s+(F\d+)\b/gi,
];

// A word in the sentence AROUND a citation that describes a LIMIT. These are
// the passages that go stale when a finding is taken - "cannot", "is not
// enforced", "no way to". Advisory: a limit that is still real reads exactly
// the same, which is why this flags rather than fails.
const LIMIT_WORDS = /\b(cannot|can not|no way to|not enforced|unstorable|has no shape|is discarded|are discarded|are dropped|is dropped|not stored|does not compare|will not)\b/i;

const target = targetFromArgv();
const argv = process.argv.slice(2).filter((a) => !a.startsWith('--'));

// ANY prefix, not just F - the point is to recognise a number this script cannot
// answer for, which means matching it first.
const asked = argv.find((a) => /^[A-Za-z]\d+$/.test(a))?.toUpperCase() ?? null;
// An explicit menu name, so `BOOK-INGEST-AUDIT F10` disambiguates a bare F10.
const menu = argv.find((a) => /audit/i.test(a) || /^book-ingest$/i.test(a)) ?? null;

const wrongMenu = menu !== null && !/^book-ingest(-audit)?(\.md)?$/i.test(menu);
const wrongPrefix = asked !== null && !asked.startsWith('F');
const only = wrongPrefix ? null : asked;

if (wrongMenu || wrongPrefix) {
  const subject = wrongMenu ? menu : asked;
  console.log(`This script cannot answer for ${subject}.`);
  console.log('');
  console.log('It reads class `extraction_notes` for citations of BOOK-INGEST-AUDIT');
  console.log('findings, and matches only two shapes: "BOOK-INGEST-AUDIT.md F<n>" and');
  console.log('"Filed as F<n>". No other menu is reachable from here, and a class note is');
  console.log('one of four kinds of file that cite a finding - see `audit-menu`.');
  console.log('');
  console.log('Refusing rather than printing the unfiltered list, which is what this did');
  console.log('before SKILL-AUDIT F30 and which reads as an answer. Grep the tree for the');
  console.log('number instead, and check ~/.claude/.../memory/ too - no grep of this repo');
  console.log('reaches it.');
} else {

const rows = d1Query('SELECT class_id, markdown FROM imported_classes ORDER BY class_id', { target });

const byFinding = new Map();
const passages = [];
for (const r of rows) {
  const md = String(r.markdown || '');
  const seen = new Set();
  for (const rx of PATTERNS) {
    for (const m of md.matchAll(rx)) seen.add(m[1].toUpperCase());
  }
  for (const f of seen) {
    if (only && f !== only) continue;
    byFinding.set(f, (byFinding.get(f) || []).concat(r.class_id));

    // The sentence the citation sits in, plus the one before it - a note
    // usually states the limit first and cites second.
    for (const rx of PATTERNS) {
      for (const m of md.matchAll(rx)) {
        if (m[1].toUpperCase() !== f) continue;
        const around = md.slice(Math.max(0, m.index - 300), m.index + 120).replace(/\s+/g, ' ');
        if (LIMIT_WORDS.test(around)) {
          passages.push({ id: r.class_id, finding: f, text: around.trim() });
        }
      }
    }
  }
}

const findings = [...byFinding.keys()].sort((a, b) => Number(a.slice(1)) - Number(b.slice(1)));
const cited = new Set([...byFinding.values()].flat());

console.log(`${cited.size} of ${rows.length} published classes cite a finding`
  + (only ? ` (filtered to BOOK-INGEST-AUDIT ${only})` : '') + `, from ${target}\n`);

// A zero used to read as "nothing cites this finding". It only ever meant
// "nothing cites the BOOK-INGEST one", and every prefix here is shared across
// menus - `audit-menu` -> "a bare number defeats it". SKILL-AUDIT F30.
if (only && cited.size === 0) {
  console.log(`No class cites BOOK-INGEST-AUDIT ${only}.`);
  console.log(`If you meant ${only} on another menu, this script never saw it: grep the`);
  console.log('tree for the number, and check ~/.claude/.../memory/ separately.\n');
}

for (const f of findings) {
  const ids = [...new Set(byFinding.get(f))];
  console.log(`${f.padEnd(5)} ${String(ids.length).padStart(2)}  ${ids.join(', ')}`);
}

if (passages.length) {
  console.log(`\n${passages.length} passage(s) describing a LIMIT beside a citation.`);
  console.log('These are the ones to re-read when the finding is taken - a limit that is');
  console.log('still real reads exactly the same, so this is a list to check, not a verdict.\n');
  const seen = new Set();
  for (const p of passages) {
    const key = `${p.id}:${p.finding}`;
    if (seen.has(key)) continue;
    seen.add(key);
    console.log(`  ${p.id} [${p.finding}]`);
    console.log(`    ...${p.text.slice(-210)}\n`);
  }
}

console.log('This command has no opinion about whether any finding was taken.');
console.log('Read the lines under its heading in BOOK-INGEST-AUDIT.md.');

}
