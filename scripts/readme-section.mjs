// One section of the character-creator README, bounded by the NEXT HEADING OF
// ANY DEPTH.
//
//   node scripts/readme-section.mjs                    the heading index
//   node scripts/readme-section.mjs "Data model"       one section
//
// Exists because the README was being used as working memory: the 2026-08-25
// efficiency audit counted ~460 reads across the book sessions, 37 of them the
// whole file, each full read costing ~12K fresh tokens plus re-carry on every
// remaining call of the session. The information wanted was always one
// section; this prints one section.
//
// ANY depth is the load-bearing part of the bound. A search that stops only at
// the next heading of the SAME depth once treated 544 lines - every
// subsection to the end of the chapter - as one section, and an edit built on
// that boundary ate all of them. A leaf-sized chunk is also the honest unit of
// reading: if the subsections are wanted too, ask for them by name.
//
// The section is printed to stdout, its line range to stderr, so piping the
// text somewhere keeps working while the range stays visible for a bounded
// edit.
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot } from './d1-query-lib.mjs';

const README = join(repoRoot, 'apps', 'character-creator', 'README.md');
const lines = readFileSync(README, 'utf8').split(/\r?\n/);

// Headings, fence-aware: the README's bash fences hold `# comment` lines, and
// a boundary that stops at one of those cuts a section mid-code-block.
const headings = [];
let inFence = false;
lines.forEach((line, i) => {
  if (/^\s*```/.test(line)) { inFence = !inFence; return; }
  if (inFence) return;
  const m = line.match(/^(#{1,6})\s+(.*)$/);
  if (m) headings.push({ line: i, depth: m[1].length, text: m[2].trim() });
});

const query = process.argv.slice(2).join(' ').trim();

if (!query) {
  for (const h of headings) {
    console.log(`${String(h.line + 1).padStart(5)}  ${'#'.repeat(h.depth)} ${h.text}`);
  }
  process.exit(0);
}

const q = query.toLowerCase();
const exact = headings.filter((h) => h.text.toLowerCase() === q);
const partial = headings.filter((h) => h.text.toLowerCase().includes(q));
const matches = exact.length === 1 ? exact : partial;

if (matches.length === 0) {
  console.error(`readme-section: no heading matches "${query}" - run with no arguments for the index`);
  process.exit(1);
}
if (matches.length > 1) {
  console.error(`readme-section: "${query}" matches ${matches.length} headings - say which:`);
  for (const h of matches) {
    console.error(`  line ${h.line + 1}: ${'#'.repeat(h.depth)} ${h.text}`);
  }
  process.exit(1);
}

const [hit] = matches;
const at = headings.indexOf(hit);
const end = at + 1 < headings.length ? headings[at + 1].line : lines.length;
console.error(`apps/character-creator/README.md lines ${hit.line + 1}-${end} (${end - hit.line} lines)`);
console.log(lines.slice(hit.line, end).join('\n'));
