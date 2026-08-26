// One section of the character-creator documentation, bounded by the NEXT
// HEADING OF ANY DEPTH.
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
// It searches README.md AND every docs/*.md, because the README was split and
// a tool that indexed only the spine would have made 4,890 lines invisible to
// the one command written to stop people reading whole files. Every hit names
// its file, so the range printed to stderr is still a bounded-edit coordinate.
//
// The section is printed to stdout, its line range to stderr, so piping the
// text somewhere keeps working while the range stays visible for a bounded
// edit.
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot } from './d1-query-lib.mjs';

const APP = join(repoRoot, 'apps', 'character-creator');
const rel = ['README.md', ...readdirSync(join(APP, 'docs'))
  .filter((f) => f.endsWith('.md')).sort().map((f) => 'docs/' + f)];

// Headings, fence-aware: the docs' bash fences hold `# comment` lines and the
// class-markdown example holds `## Lore` and `## GM Notes`, so a boundary that
// stops at one of those cuts a section mid-code-block.
const source = new Map();   // file -> lines
const headings = [];
for (const file of rel) {
  const lines = readFileSync(join(APP, file), 'utf8').split(/\r?\n/);
  source.set(file, lines);
  let inFence = false;
  lines.forEach((line, i) => {
    if (/^\s*```/.test(line)) { inFence = !inFence; return; }
    if (inFence) return;
    const m = line.match(/^(#{1,6})\s+(.*)$/);
    if (m) headings.push({ file, line: i, depth: m[1].length, text: m[2].trim() });
  });
}

const query = process.argv.slice(2).join(' ').trim();

if (!query) {
  let current = null;
  for (const h of headings) {
    if (h.file !== current) {
      current = h.file;
      console.log(`\napps/character-creator/${current}`);
    }
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
    console.error(`  ${h.file} line ${h.line + 1}: ${'#'.repeat(h.depth)} ${h.text}`);
  }
  process.exit(1);
}

const [hit] = matches;
const lines = source.get(hit.file);
// The next heading IN THE SAME FILE. A file boundary ends a section as surely
// as a heading does.
const next = headings.find((h) => h.file === hit.file && h.line > hit.line);
const end = next ? next.line : lines.length;
console.error(`apps/character-creator/${hit.file} lines ${hit.line + 1}-${end} (${end - hit.line} lines)`);
console.log(lines.slice(hit.line, end).join('\n'));
