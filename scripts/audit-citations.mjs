// Which published classes cite which audit finding?
//
//   node scripts/audit-citations.mjs --remote
//   node scripts/audit-citations.mjs --remote F10
//   node scripts/audit-citations.mjs --local
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
// citing a still-open finding, which is the correct and useless answer.

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
const only = process.argv.slice(2).find((a) => /^F\d+$/i.test(a))?.toUpperCase() ?? null;

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
  + (only ? ` (filtered to ${only})` : '') + `, from ${target}\n`);

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
