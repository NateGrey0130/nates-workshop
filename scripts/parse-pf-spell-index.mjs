// Parse the Palladium Fantasy main book's TWO spell authority tables and write
// them out as JSON for scripts/catalog-diff.mjs.
//
//   python scripts/read-columns.py "<book>.pdf" 189 190 > index.txt
//   node scripts/parse-pf-spell-index.mjs index.txt out.json
//
// The book ships two: an alphabetical list BY LEVEL (printed 187) which is the
// only place a spell's level is stated, and an alphabetical list BY PAGE NUMBER
// (printed 188) which repeats the cost. Two independent readings of every cost,
// which is the check the book-survey skill asks for and the reason both are
// parsed here rather than only the one that carries the level.
//
// Be generous about what an entry looks like. Strictness is what quietly
// dropped every "Summon & Control ..." and every non-numeric cost on earlier
// passes: a name is whatever precedes the LAST parenthetical, and a cost is
// anything carrying a digit or the words Special/Varies.
import { readFileSync, writeFileSync } from 'node:fs';

const WORDS = { One: 1, Two: 2, Three: 3, Four: 4, Five: 5, Six: 6, Seven: 7, Eight: 8,
  Nine: 9, Ten: 10, Eleven: 11, Twelve: 12, Thirteen: 13, Fourteen: 14, Fifteen: 15 };

// Spells of Legend are not a numbered level. The catalog stores level as an
// integer, so they are flagged and left for the caller to decide rather than
// given a made-up number here.
const LEGEND = 'legend';

const text = readFileSync(process.argv[2], 'utf8');
const lines = text.split('\n').map((l) => l.replace(/\r$/, ''));

// The two tables are separated by their own headings.
const byLevelStart = lines.findIndex((l) => /Spell List by Level/i.test(l));
const byPageStart = lines.findIndex((l) => /Spell List by Page/i.test(l));
if (byLevelStart < 0 || byPageStart < 0) {
  console.error('could not find both headings; got', byLevelStart, byPageStart);
  process.exit(1);
}

// A cost is the LAST parenthetical on the line, and the name is what precedes
// it. "Circle of Concealment (15 or 100)" and "Wink-Out (20+)" are both costs.
const ENTRY = /^\.?\s*(.+?)\s*\(([^()]*)\)\s*$/;
const looksLikeCost = (s) => /\d/.test(s) || /special|varies/i.test(s)
  // A ONE-CHARACTER parenthetical is a mis-set digit, not a different kind of
  // entry: the by-level table renders Eyes of Thoth as "EyesofThoth(S)" where
  // the by-page table plainly says "(8)". Accepting it here and letting the
  // other table supply the number is the difference between reconciling a
  // typesetting artifact and silently dropping a spell.
  || s.trim().length === 1;
const hasNumber = (s) => /\d/.test(s) || /special|varies/i.test(s);

// The text layer welds a few entries: "EyesofThoth(S)", "Fly(15)". Split the
// cost off first, then repair the name.
const unweld = (s) => s
  .replace(/([a-z])([A-Z])/g, '$1 $2')
  .replace(/\s+/g, ' ')
  .trim();

function parseByLevel(from, to) {
  const out = [];
  let level = null;
  for (const raw of lines.slice(from + 1, to)) {
    const line = raw.trim();
    if (!line) continue;
    const lvl = /^Level\s+(\w+)\s*$/i.exec(line);
    if (lvl && WORDS[lvl[1][0].toUpperCase() + lvl[1].slice(1).toLowerCase()]) {
      level = WORDS[lvl[1][0].toUpperCase() + lvl[1].slice(1).toLowerCase()];
      continue;
    }
    if (/^Spells of Legend\s*$/i.test(line)) { level = LEGEND; continue; }
    if (/^\d+$/.test(line)) continue;                 // a page number
    const m = ENTRY.exec(line);
    if (!m || !looksLikeCost(m[2])) continue;
    out.push({ name: unweld(m[1]), ppe: m[2].trim(), level });
  }
  return out;
}

function parseByPage(from) {
  const out = [];
  for (const raw of lines.slice(from + 1)) {
    const line = raw.trim();
    if (!line) continue;
    if (/^=+/.test(line)) break;
    if (/^\d+$/.test(line)) continue;
    // "Age (50) - pg. 206", with the dash arriving as whatever byte it arrives as.
    const cut = line.replace(/\s*[^\w\s()+,:'&./-]?\s*pg\.?\s*\d+\s*$/i, '');
    const m = ENTRY.exec(cut);
    if (!m || !looksLikeCost(m[2])) continue;
    const page = /pg\.?\s*(\d+)/i.exec(line);
    out.push({ name: unweld(m[1]), ppe: m[2].trim(), page: page ? Number(page[1]) : null });
  }
  return out;
}

const byLevel = parseByLevel(byLevelStart, byPageStart);
const byPage = parseByPage(byPageStart);

// Reconcile: the level comes from the first table, the page from the second,
// and the cost has to agree in both or it is reported.
const norm = (s) => String(s).toLowerCase().replace(/&/g, 'and')
  .replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim();

// The two tables spell three names differently between themselves. These are
// the book disagreeing with the book, not a match to guess at, so they are
// listed rather than resolved by edit distance.
const ALIASES = new Map([
  ['thunder clap', 'thunderclap'],
  ['faerie s dance', 'faeries dance'],
  // The by-level table welds this one into "EyesofThoth", and the unweld splits
  // it at the only case boundary there is - after the f.
  ['eyesof thoth', 'eyes of thoth'],
]);
const key = (s) => { const n = norm(s); return ALIASES.get(n) ?? n; };

const pageBy = new Map(byPage.map((e) => [key(e.name), e]));

const entries = [];
const costDisagreements = [];
const missingFromPage = [];
for (const e of byLevel) {
  const p = pageBy.get(key(e.name));
  if (!p) missingFromPage.push(e.name);
  // Prefer whichever table states a NUMBER. Where both do and they differ, that
  // is the book disagreeing with itself and is reported, not silently resolved.
  const ppe = hasNumber(e.ppe) ? e.ppe : (p && hasNumber(p.ppe) ? p.ppe : e.ppe);
  if (p && hasNumber(e.ppe) && hasNumber(p.ppe) && p.ppe !== e.ppe) {
    costDisagreements.push({ name: e.name, byLevel: e.ppe, byPage: p.ppe });
  }
  const repaired = !hasNumber(e.ppe) && hasNumber(ppe);
  // Where the two tables spell a name differently, the emitted name is the one
  // from the table that is not the welded one. "EyesofThoth" unwelds to
  // "Eyesof Thoth", because f-to-T is the only case boundary in it; the by-page
  // table prints "Eyes of Thoth" and is simply right.
  const name = (p && key(e.name) !== norm(e.name) && norm(p.name) === key(e.name))
    ? p.name : e.name;
  entries.push({ name, level: e.level, ppe, page: p?.page ?? null,
    ...(repaired ? { ppe_from: 'by-page table; the by-level table mis-sets it as (' + e.ppe + ')' } : {}) });
}
const inPageOnly = byPage.filter((e) => !byLevel.some((x) => key(x.name) === key(e.name)))
  .map((e) => e.name);
const noCost = entries.filter((e) => !hasNumber(e.ppe)).map((e) => e.name + ' (' + e.ppe + ')');
if (noCost.length) console.log('NO COST IN EITHER TABLE: ' + noCost.join(', '));

console.log(`by level: ${byLevel.length}   by page: ${byPage.length}`);
console.log(`levels seen: ${[...new Set(byLevel.map((e) => e.level))].join(', ')}`);
if (costDisagreements.length) {
  console.log(`\nthe two tables disagree on ${costDisagreements.length} cost(s):`);
  for (const d of costDisagreements) console.log(`  ${d.name}: by level ${d.byLevel}, by page ${d.byPage}`);
}
if (missingFromPage.length) console.log(`\nin the level table only: ${missingFromPage.join(', ')}`);
if (inPageOnly.length) console.log(`in the page table only: ${inPageOnly.join(', ')}`);

writeFileSync(process.argv[3], JSON.stringify(entries, null, 1));
console.log(`\nwrote ${entries.length} entries to ${process.argv[3]}`);
