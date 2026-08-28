#!/usr/bin/env node
// Can what shipped still be traced back to a cached page? And what is stubbed?
//
//   node scripts/source-coverage.mjs            (--remote)
//   node scripts/source-coverage.mjs --local
//   node scripts/source-coverage.mjs --offenders   list every row, not the first few
//   node scripts/source-coverage.mjs --vs-build    the same table for a database
//                                                  built from the repo, side by side
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
import { existsSync, readFileSync, readdirSync, writeFileSync, mkdtempSync, rmSync }
  from 'node:fs';
import { spawnSync } from 'node:child_process';
import { tmpdir } from 'node:os';
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

// ── the same ledger, for a database built from the repo ─────────────────────
// `--vs-build` exists because the 148-citation regression was measured as ONE
// bucket - "rows carrying a bare book title" - and a row that lost its
// source_book ENTIRELY leaves that bucket. So losing a citation outright made
// the number go DOWN, and 37 rows that ended a rebuild citing nothing at all
// were never in view. One bucket cannot show that. The whole table, for both
// datasets, can. See REBUILD-AUDIT.md F4.
//
// Slow - it builds a database, the same way repo-vs-live.mjs and
// test/regression.mjs do, into a scratch --persist-to directory that is deleted
// afterwards. Read-only against production, and advisory like the rest of this
// script: it never moves the exit code.
if (process.argv.includes('--vs-build')) {
  const state = mkdtempSync(join(tmpdir(), 'coverage-build-'));
  try {
    const parts = [
      readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
      readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
    ];
    const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
    for (const f of readdirSync(dataDir).filter((x) => x.endsWith('.sql')).sort()) {
      const sql = readFileSync(join(dataDir, f), 'utf8');
      if (/^--\s*local-only\b/m.test(sql)) continue;
      parts.push(sql);
    }
    writeFileSync(join(state, 'bootstrap.sql'), parts.join('\n;\n'), 'utf8');

    process.stdout.write('\nbuilding a database from the repo... ');
    const wr = (args) => spawnSync('npx', ['wrangler', ...args],
      { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 900000, maxBuffer: 1e9 });
    const applied = wr(['d1', 'execute', 'DB', '--local', '--persist-to', state,
      '--file', join(state, 'bootstrap.sql')]);
    if (applied.status !== 0) {
      console.log('FAILED');
      console.error((applied.stderr || applied.stdout || '').slice(-800));
    } else {
      console.log('ok');

      const fromBuild = (sql) => {
        const r = wr(['d1', 'execute', 'DB', '--local', '--persist-to', state,
          '--json', '--command', `"${sql}"`]);
        const out = r.stdout || '';
        // wrangler prefixes a log line that ALSO starts with '[', so the first
        // '[' is not the JSON. Take the first slice that parses - the same
        // trick repo-vs-live.mjs uses, and for the same reason.
        for (let at = out.indexOf('['); at >= 0; at = out.indexOf('[', at + 1)) {
          try {
            const v = JSON.parse(out.slice(at));
            if (Array.isArray(v)) return v.flatMap((b) => b.results || []);
          } catch { /* not the JSON yet */ }
        }
        return [];
      };

      const buildGroups = [
        {
          label: 'classes',
          rows: fromBuild(`SELECT class_id AS label, ${FRONTMATTER} AS sb FROM imported_classes `
            + "WHERE deleted_at IS NULL AND status = 'published'"),
        },
        ...['gear', 'skills', 'spells', 'psionic_powers'].map((t) => ({
          label: t,
          rows: fromBuild(`SELECT name AS label, source_book AS sb FROM ${t}`),
        })),
      ];

      const totals = (gs) => {
        const c = Object.fromEntries(BUCKETS.map((b) => [b, 0]));
        let n = 0;
        for (const g of gs) {
          const s = summarise(g.rows.map((r) => ({ label: r.label, sourceBook: r.sb })), opts);
          for (const b of BUCKETS) c[b] += s.counts[b];
          n += s.total;
        }
        return { c, n };
      };
      const live = totals(groups);
      const built = totals(buildGroups);

      console.log(`\nCITATION COVERAGE  ${target.replace('--', '')} vs a build from the repo`);
      console.log(`  ${pad('bucket', 18)}${pad(target.replace('--', ''), 10)}${pad('build', 10)}delta`);
      for (const b of BUCKETS) {
        const d = built.c[b] - live.c[b];
        console.log(`  ${pad(b, 18)}${pad(live.c[b], 10)}${pad(built.c[b], 10)}`
          + (d === 0 ? '-' : (d > 0 ? '+' : '') + d));
      }
      console.log(`  ${pad('rows', 18)}${pad(live.n, 10)}${pad(built.n, 10)}`
        + (built.n === live.n ? '-' : built.n - live.n));

      console.log('\nRead the WHOLE table, never one row of it. `no-page-range` and');
      console.log('`no-source-book` move against each other: a row that loses its citation');
      console.log('ENTIRELY leaves the first bucket and lands in the second, so a rebuild');
      console.log('that got worse can report a smaller bare-title count than production.');
      console.log('That is exactly how 148 lost citations were once read as an improvement.');
    }
  } finally {
    rmSync(state, { recursive: true, force: true });
  }
}

console.log('\nAdvisory: this never gates a merge. The caches are gitignored, so a');
console.log('clean clone traces nothing and that is not a defect.');
console.log('\nAnd traceable means CHECKABLE, not correct: the cited page is one this');
console.log('machine holds, never that the row is printed on it. Caching the Book of');
console.log('Magic moved 231 spells here while every one still cited the wrong page,');
console.log('and the repair that fixed them moved this ledger by zero.');
process.exit(0);
