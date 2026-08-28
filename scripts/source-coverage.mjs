#!/usr/bin/env node
// Can what shipped still be traced back to a cached page? And what is stubbed?
//
//   node scripts/source-coverage.mjs            (--remote)
//   node scripts/source-coverage.mjs --local
//   node scripts/source-coverage.mjs --offenders   list every row, not the first few
//
// Two questions in one pass, because both are ledger lines nobody had:
//
//   COVERAGE  every published class and every catalog row carrying a
//             `source_book`, resolved through scripts/books.json, its page
//             range parsed, its window tested against the cache on this
//             machine. Six buckets, counts per book, and the offenders named.
//
//   BACKLOG   the rows the importers create by design and nobody has finished.
//             Small numbers today, which is the point of counting them now
//             rather than after a shelf of books.
//
// WHAT `traceable` MEANS, AND WHAT IT DOES NOT. It means the page a row
// cites is a page this machine holds, so a reader can go and check it. It
// says NOTHING about whether the row is printed there. The Book of Magic is
// the worked case: caching it moved 231 spells from `outside-cache` to
// `traceable` in one command while every one of them still pointed at two
// pages of Earth Warlock spell descriptions, and the data script that put
// them right afterwards moved this ledger by zero. Both numbers were correct.
// A row can only be wrong in a way this notices once it is cheap to notice.
//
// ADVISORY, AND IT ALWAYS EXITS 0. The cache is gitignored, so a clean clone
// has none and a merge gate built on this would fail for everyone but the one
// machine that cached the books. On a machine with no `.cache/books` it says so
// and stops, the same way drift-check's citation section does.
//
// Read-only. Safe to point at production, and pointed there by default,
// because the question is about what SHIPPED.
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { DB, d1Query, repoRoot, targetFromArgv } from './d1-query-lib.mjs';
import { loadBookRegistry, loadNotBooks } from './books-lib.mjs';
import { BUCKETS, summarise } from './source-coverage-lib.mjs';

const target = targetFromArgv();
const showAll = process.argv.includes('--offenders');
const d1 = (sql) => d1Query(sql, { target, db: DB });

// ── the caches on this machine ──────────────────────────────────────────────
const cacheDir = join(repoRoot, '.cache', 'books');
const registry = loadBookRegistry();
const caches = {};
const manifests = {};
if (existsSync(cacheDir)) {
  for (const slug of readdirSync(cacheDir)) {
    const txtDir = join(cacheDir, slug, 'txt');
    if (!existsSync(txtDir)) continue;
    const pages = new Set();
    for (const f of readdirSync(txtDir)) {
      const m = f.match(/^p(\d+)\.txt$/);
      if (m) pages.add(Number(m[1]));
    }
    if (!pages.size) continue;
    caches[slug] = pages;
    const mf = join(cacheDir, slug, 'manifest.json');
    if (existsSync(mf)) {
      try { manifests[slug] = JSON.parse(readFileSync(mf, 'utf8')); } catch { /* a broken manifest still leaves the registry */ }
    }
  }
}
// Counted against the REGISTRY, not against the disk. "8 on this machine" is
// a fact about a directory; "8 of 13 registered books present" is a fact about
// what is missing, and it is the same sentence drift-check prints. Printed
// before the no-cache exit as well, because that exit is the case it is for.
const registeredSlugs = Object.keys(registry);
const presentSlugs = registeredSlugs.filter((s) => caches[s]);
const strays = Object.keys(caches).filter((s) => !registeredSlugs.includes(s));
const cacheStatus = `${presentSlugs.length} of ${registeredSlugs.length} registered books present`
  + (strays.length ? `; ${strays.length} not in the registry: ${strays.join(', ')}` : '');

if (!Object.keys(caches).length) {
  console.log(`caches:       ${cacheStatus}`);
  console.log('no OCR caches under .cache/books — nothing to trace against.');
  console.log('Cache a book with scripts/ocr-book.py; the caches are gitignored.');
  process.exit(0);
}

const opts = { registry, caches, manifests, notBooks: loadNotBooks() };
console.log(`caches:       ${cacheStatus} — `
  + Object.entries(caches).map(([s, p]) => `${s} (${p.size})`).join(', '));
console.log(`target:       ${target}\n`);

// ── coverage ────────────────────────────────────────────────────────────────
// The class's source_book lives in its markdown frontmatter, not in a column,
// so it is sliced out in SQL rather than pulling 109 whole documents back.
const FRONTMATTER = "trim(replace(substr(markdown, instr(markdown, 'source_book:') + 12, "
  + "instr(substr(markdown, instr(markdown, 'source_book:') + 12), char(10)) - 1), char(13), ''))";

const groups = [
  {
    label: 'classes',
    rows: d1(`SELECT class_id AS label, ${FRONTMATTER} AS sb FROM imported_classes `
      + "WHERE deleted_at IS NULL AND status = 'published'"),
  },
  ...['gear', 'skills', 'spells', 'psionic_powers'].map((t) => ({
    label: t,
    rows: d1(`SELECT name AS label, source_book AS sb FROM ${t}`),
  })),
];

const pad = (s, n) => String(s).padEnd(n);
console.log(`COVERAGE        ${BUCKETS.map((b) => pad(b, 15)).join('')}`);
const allOffenders = [];
for (const g of groups) {
  const s = summarise(g.rows.map((r) => ({ label: r.label, sourceBook: r.sb })), opts);
  console.log(`  ${pad(g.label, 14)}${BUCKETS.map((b) => pad(s.counts[b], 15)).join('')}`
    + `  of ${s.total}`);
  for (const b of BUCKETS) {
    for (const o of s.offenders[b]) allOffenders.push({ group: g.label, ...o });
  }
}

// Per book, so "which book is the hole in" is one line rather than a grep.
console.log('\nBY BOOK       traceable / other');
const perBook = new Map();
for (const g of groups) {
  const s = summarise(g.rows.map((r) => ({ label: r.label, sourceBook: r.sb })), opts);
  for (const [slug, counts] of s.byBook) {
    const cur = perBook.get(slug) ?? { traceable: 0, other: 0 };
    for (const b of BUCKETS) {
      if (b === 'traceable') cur.traceable += counts[b];
      else cur.other += counts[b];
    }
    perBook.set(slug, cur);
  }
}
for (const [slug, c] of [...perBook].sort((a, b) => (b[1].traceable + b[1].other) - (a[1].traceable + a[1].other))) {
  console.log(`  ${pad(slug, 18)}${String(c.traceable).padStart(4)} / ${c.other}`);
}

// The rows themselves, GROUPED BY BOOK AND REASON. 231 of the 232 untraceable
// rows are one book with one cause, and printing 231 near-identical lines
// buries the one that is different (`stone-master`). One line per cause, three
// examples, and --offenders for the whole list.
const LOUD = ['unknown-book', 'not-cached', 'outside-cache'];
console.log('');
for (const b of BUCKETS) {
  const rows = allOffenders.filter((o) => o.bucket === b);
  if (!rows.length) continue;
  if (!LOUD.includes(b) && !showAll) {
    console.log(`${b} (${rows.length}) — pass --offenders to list them`);
    continue;
  }
  console.log(`${b} (${rows.length})`);
  const causes = new Map();
  for (const o of rows) {
    const key = `${o.slug ?? '(unresolved)'} :: ${o.reason ?? o.group}`;
    if (!causes.has(key)) causes.set(key, []);
    causes.get(key).push(o);
  }
  for (const [key, group] of [...causes].sort((a, b2) => b2[1].length - a[1].length)) {
    const [slug, reason] = key.split(' :: ');
    console.log(`  ${group.length} row(s)  ${slug}${reason ? ` — ${reason}` : ''}`);
    for (const o of showAll ? group : group.slice(0, 3)) {
      console.log(`      ${o.group}.${o.label}`);
    }
    if (!showAll && group.length > 3) console.log(`      ... and ${group.length - 3} more`);
  }
}

// ── backlog ─────────────────────────────────────────────────────────────────
// What the importers create by design and nobody has finished.
//
// THE SIGNATURE MATTERS MORE THAN IT LOOKS. "an imported skill at 0/0" counts
// 21 rows and 20 of them are correct: a W.P., a Hand to Hand, or a physical
// skill whose whole content is bonuses and a long `note` saying why nothing is
// stored (Fencing, Combat Driving, Robot Combat: Basic). A stub is a row the
// importer created and NOBODY TOUCHED SINCE - no note, no bonuses, no book.
// Counting the other 20 would be crying wolf twenty times.
const backlog = [
  ['gear stubs', "SELECT count(*) AS n FROM gear WHERE description LIKE 'STUB%'",
    'description still says STUB — created by class import'],
  ['gear with no price', 'SELECT count(*) AS n FROM gear WHERE cost IS NULL '
    + "AND (cost_note IS NULL OR cost_note = '')",
    'no cost and no cost_note to explain it'],
  ['skill stubs', "SELECT count(*) AS n FROM skills WHERE source = 'import' AND base = 0 "
    + "AND per_level = 0 AND bonuses IS NULL AND (note IS NULL OR note = '') "
    + "AND name NOT LIKE 'W.P.%'",
    'created by an import and never given a base %, a bonus or a note'],
  ['spell stubs', "SELECT count(*) AS n FROM spells WHERE source = 'import' "
    + 'AND level = 0 AND ppe = 0', 'level 0 and 0 P.P.E.'],
  ['psionic stubs', "SELECT count(*) AS n FROM psionic_powers WHERE source = 'import' "
    + 'AND isp = 0', '0 I.S.P.'],
];
console.log('\nBACKLOG       rows an importer created and nobody finished');
for (const [label, sql, why] of backlog) {
  const n = d1(sql)[0]?.n ?? 0;
  console.log(`  ${pad(label, 20)}${String(n).padStart(4)}   ${why}`);
}

console.log('\nAdvisory: this never gates a merge. The caches are gitignored, so a');
console.log('clean clone traces nothing and that is not a defect.');
console.log('\nAnd traceable means CHECKABLE, not correct: the cited page is one this');
console.log('machine holds, never that the row is printed on it. Caching the Book of');
console.log('Magic moved 231 spells here while every one still cited the wrong page,');
console.log('and the repair that fixed them moved this ledger by zero.');
process.exit(0);
