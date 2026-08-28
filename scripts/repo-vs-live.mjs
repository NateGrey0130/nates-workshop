// Can the repo rebuild the live catalog, row for row?
//
//   node scripts/repo-vs-live.mjs                 # all catalogs
//   node scripts/repo-vs-live.mjs --table gear    # just one
//   node scripts/repo-vs-live.mjs --offenders     # every differing row, not the first few
//
// drift-check asks whether the repo and the live database agree about
// BOOKKEEPING - which migrations and data scripts have run - and every script
// can be recorded in both places while the rows differ. It also demands that
// every published CLASS be creatable from the repo, and nothing made the same
// demand of catalog rows.
//
// That gap has now cost three times:
//
//   * 2 classes and 169 catalog rows once existed only in production, because
//     the catalog editor and the importer's confirm step write straight to D1.
//     The `restore-*.sql` scripts came out of finding that by hand.
//
//   * Six psionic merges done through the editor left the repo creating both
//     halves of every pair, so a rebuilt database came up with six duplicates
//     and four gear rows missing. Found only because a README count was pinned
//     and happened to disagree.
//
//   * Names matched and the VALUES did not. On 2026-08-28 this script printed
//     "The repo rebuilds the live catalog exactly" while 413 field values
//     across these five tables disagreed with production: 24 weapons that are
//     mega-damage live came out S.D.C., 21 psionic powers came out with no
//     description at all, 37 rows came out with no `source_book`. Every name
//     matched, every count matched, and `drift-check --remote` printed NO DRIFT
//     the same day - correctly, because it was answering a different question.
//
// So this asks the question in two halves: build from the repo into a scratch
// database, then diff against live - the NAMES, and then every COLUMN of the
// rows whose names already match. Counts were not enough (gear was off by one
// row and that one row hid seven disagreements going both ways), and names were
// not enough either. Each level of this check was added after the previous one
// missed something.
//
// THE EXIT CODE STILL MEANS THE FIRST HALF. A missing or extra row fails this
// script. A wrong VALUE is reported and exits 0. That is deliberate: the
// content comparison starts life with 413 findings, and a gate that fails on
// the day it lands gets switched off rather than fixed. Read the number, and
// watch it go down. See apps/character-creator/REBUILD-AUDIT.md, F3.
//
// Slow (it builds a database), read-only, and it never touches production
// beyond SELECTs.
import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, readdirSync, mkdtempSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { repoRoot, d1Query } from './d1-query-lib.mjs';

const only = (() => {
  const i = process.argv.indexOf('--table');
  return i === -1 ? null : process.argv[i + 1];
})();
// Same flag name and same job as source-coverage.mjs's: the capped list is for
// reading, the full list is for working through.
const showAll = process.argv.includes('--offenders');
const ROWS_SHOWN = 8;

// [table, the column whose SET is compared, the column that IDENTIFIES a row].
// The two are not always the same, and assuming they were cost a re-run: this
// script's first version joined the value comparison on `name` too, which pairs
// an armor enchantment with a weapon one. `enchantments` prints Color, Continual
// Glow and Impervious to Fire once per `applies_to`, and gear has two Sleeping
// Bags - 24 differences reported that were not differences at all. Found by
// running it against production, not by reading it.
const TABLES = [
  ['skills', 'name', 'name'],
  ['spells', 'name', 'name'],
  ['psionic_powers', 'name', 'name'],
  ['gear', 'name', 'slug'],
  ['enchantments', 'name', 'slug'],
  // The class definitions: the largest and most consequential thing the repo
  // rebuilds, and until now outside every content comparison. drift-check
  // demands only that a published class be CREATABLE from the repo; nothing
  // asked whether the class it creates is the same class. Two findings shipped
  // through that gap - a rebuild citing ten gear slugs no database holds, and
  // duplicated skill restrictions in mystic and burster.
  ['imported_classes', 'class_id', 'class_id'],
];

// Columns that cannot be compared between two independently built databases.
// `id` is an insertion-order artefact - two CORRECT databases built in a
// different order disagree about it by construction. `*_at` is the build clock;
// a comparison that reports 126 timestamp differences teaches nobody anything.
//
// `created_by` records HOW a row got there - 'import' for the two classes that
// predate the data-script convention, 'data-script' for the file that recreates
// them. A rebuild saying 'data-script' is telling the truth about itself, and
// reporting it as a difference would be reporting the mechanism as a defect.
// The same argument is open for `skills.source` under F14.
const uncomparable = (c) => c === 'id' || c === 'created_by' || c.endsWith('_at');

// `deleted_at` is the exception to the rule above, and is compared as PRESENCE
// rather than as a timestamp: a class soft-deleted in one database and live in
// the other is exactly the divergence this script exists to find, while the
// minute it happened is not. Zero rows carry one today, in either database.
const comparable = (row, c) => (c === 'deleted_at' ? row[c] != null : row[c]);

// Compared as text on purpose. D1 hands back a column stored as TEXT '40' and
// one stored as INTEGER 40 differently, and the app renders both as 40 - so a
// difference in storage class is not a difference in the catalog.
const norm = (v) => (v === null || v === undefined ? null : String(v));
const show = (v) => (v === null || v === undefined ? 'NULL'
  : JSON.stringify(String(v)).slice(0, 110));

// A markdown column is tens of kilobytes. Printing two truncated blobs and
// leaving the reader to spot the difference is not a report, so anything
// multi-line is diffed by line. Set-based rather than positional: a class whose
// yaml gained one entry should read as one line, not as every line after it.
function printValue(indent, col, live, repo) {
  const a = String(live ?? ''), b = String(repo ?? '');
  if (!a.includes('\n') && !b.includes('\n')) {
    console.log(`${indent}live ${show(live)}`);
    console.log(`${indent}repo ${show(repo)}`);
    return;
  }
  const A = a.split('\n'), B = b.split('\n');
  const inA = new Set(A), inB = new Set(B);
  const onlyLive = A.filter((l) => !inB.has(l) && l.trim());
  const onlyRepo = B.filter((l) => !inA.has(l) && l.trim());
  const cap = showAll ? Infinity : 3;
  for (const l of onlyLive.slice(0, cap)) console.log(`${indent}live | ${l.trim().slice(0, 150)}`);
  if (onlyLive.length > cap) console.log(`${indent}live | ... ${onlyLive.length - cap} more line(s)`);
  for (const l of onlyRepo.slice(0, cap)) console.log(`${indent}repo | ${l.trim().slice(0, 150)}`);
  if (onlyRepo.length > cap) console.log(`${indent}repo | ... ${onlyRepo.length - cap} more line(s)`);
  if (!onlyLive.length && !onlyRepo.length) {
    console.log(`${indent}(same lines in a different order)`);
  }
}

const appDir = join(repoRoot, 'apps', 'character-creator');
const state = mkdtempSync(join(tmpdir(), 'repo-vs-live-'));
const wrangler = (args) => spawnSync('npx', ['wrangler', ...args],
  { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 300000, maxBuffer: 1e9 });

try {
  // Built exactly the way test/regression.mjs builds it: schema, seed, then
  // every data script in sorted order, skipping the local-only ones. One
  // concatenated file rather than 120 CLI invocations.
  const parts = [
    readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'),
    readFileSync(join(repoRoot, 'db', 'seed-catalogs.sql'), 'utf8'),
  ];
  for (const f of readdirSync(join(appDir, 'db')).filter((x) => x.endsWith('.sql')).sort()) {
    const sql = readFileSync(join(appDir, 'db', f), 'utf8');
    if (/^--\s*local-only\b/m.test(sql)) continue;
    parts.push(sql);
  }
  const bootstrap = join(state, 'bootstrap.sql');
  writeFileSync(bootstrap, parts.join('\n;\n'), 'utf8');

  process.stdout.write('building a database from the repo... ');
  const applied = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state,
    '--file', bootstrap]);
  if (applied.status !== 0) {
    console.log('FAILED');
    console.error((applied.stderr || applied.stdout || '').slice(-800));
    process.exit(1);
  }
  console.log('ok\n');

  const fromBuild = (sql) => {
    const r = wrangler(['d1', 'execute', 'DB', '--local', '--persist-to', state,
      '--json', '--command', `"${sql}"`]);
    const out = r.stdout || '';
    return JSON.parse(out.slice(out.indexOf('['))).flatMap((b) => b.results || []);
  };

  let problems = 0;          // rows missing or extra. THIS is what the exit code means.
  let contentFields = 0;     // columns holding a different value. Reported, never fatal.
  let contentRows = 0;

  for (const [table, col, key] of TABLES.filter(([t]) => !only || t === only)) {
    // SELECT * rather than one column: the second half needs every value, and
    // asking twice would build nothing and cost a second round trip per table.
    const repoRows = fromBuild(`SELECT * FROM ${table}`);
    const liveRows = d1Query(`SELECT * FROM ${table}`);
    const repo = repoRows.map((r) => r[col]);
    const live = liveRows.map((r) => r[col]);
    const liveSet = new Set(live), repoSet = new Set(repo);
    const onlyRepo = [...new Set(repo.filter((n) => !liveSet.has(n)))];
    const onlyLive = [...new Set(live.filter((n) => !repoSet.has(n)))];
    problems += onlyRepo.length + onlyLive.length;

    const verdict = onlyRepo.length + onlyLive.length ? 'names DIFFER' : 'names match';
    console.log(`${table.padEnd(16)} repo ${String(repo.length).padStart(4)}  `
      + `live ${String(live.length).padStart(4)}   ${verdict}`);
    for (const n of onlyLive) {
      console.log(`   ONLY LIVE  ${n}`);
    }
    for (const n of onlyRepo) {
      console.log(`   ONLY REPO  ${n}`);
    }

    // ── the same row, column by column ──
    // Only over rows present on both sides: a row missing from one of them is
    // a name problem, already counted above, and listing every column of it
    // again would report one absence as twenty differences.
    const cols = [...new Set([
      ...Object.keys(liveRows[0] || {}), ...Object.keys(repoRows[0] || {}),
    ])].filter((c) => !uncomparable(c));
    const repoBy = new Map(repoRows.map((r) => [r[key], r]));
    const differing = new Map();
    // A key that is not unique pairs the wrong rows and INVENTS differences,
    // which is what `name` did here before the key was split out. Refuse rather
    // than report a number built on a collision.
    if (repoBy.size !== repoRows.length) {
      console.log(`   CANNOT COMPARE VALUES: ${key} is not unique in ${table} `
        + `(${repoRows.length} rows, ${repoBy.size} distinct). Fix the key in TABLES.`);
    } else {
      for (const l of liveRows) {
        const r = repoBy.get(l[key]);
        if (!r) continue;
        for (const c of cols) {
          if (norm(comparable(l, c)) === norm(comparable(r, c))) continue;
          if (!differing.has(l[key])) differing.set(l[key], []);
          differing.get(l[key]).push({ column: c, live: l[c], repo: r[c] });
        }
      }
    }

    if (differing.size) {
      const fields = [...differing.values()].reduce((a, v) => a + v.length, 0);
      contentFields += fields;
      contentRows += differing.size;
      const byCol = {};
      for (const v of differing.values()) {
        for (const d of v) byCol[d.column] = (byCol[d.column] || 0) + 1;
      }
      console.log(`   SAME NAME, DIFFERENT VALUE: ${fields} field(s) `
        + `across ${differing.size} row(s)`);
      console.log('     ' + Object.entries(byCol).sort((a, b) => b[1] - a[1])
        .map(([c, n]) => `${c} ${n}`).join(', '));
      const shown = showAll ? [...differing] : [...differing].slice(0, ROWS_SHOWN);
      for (const [key, ds] of shown) {
        for (const d of ds) {
          console.log(`     ${key} [${d.column}]`);
          printValue('        ', d.column, d.live, d.repo);
        }
      }
      if (!showAll && differing.size > ROWS_SHOWN) {
        console.log(`     ... and ${differing.size - ROWS_SHOWN} more row(s) `
          + `- run with --offenders for all`);
      }
    }
  }

  console.log('');
  if (problems) {
    console.log(`${problems} row(s) differ.`);
    console.log('  ONLY LIVE  = added through the app and never written back.');
    console.log('               Export it into a data script, as restore-*.sql did.');
    console.log('  ONLY REPO  = merged or renamed away in the app, and the repo');
    console.log('               still creates the old row. See');
    console.log('               zz-merge-psionic-duplicates.sql for the shape:');
    console.log('               move redirects, add a forwarding one, then delete.');
  } else if (!contentFields) {
    console.log('The repo rebuilds the live catalog exactly.');
  } else {
    console.log('The repo creates the right ROWS. Some of them hold the wrong VALUES.');
  }

  if (contentFields) {
    console.log(`\n${contentFields} field(s) across ${contentRows} row(s) differ in value.`);
    console.log('  A row the repo creates but cannot reproduce. Two known causes:');
    console.log('    - the export that created it carried only SOME of its columns.');
    console.log("      restore-gear-missing-from-repo.sql carries 6 of gear's 18,");
    console.log('      which is why 24 weapons rebuild as S.D.C. rather than M.D.');
    console.log('    - the value was written through the catalog editor or the');
    console.log('      importer, both of which write straight to D1 and leave');
    console.log('      nothing in git. restore-*.sql recovers a row that was');
    console.log('      ABSENT, never one that was present and got ENRICHED.');
    console.log('  Reported, not enforced: this does not move the exit code.');
    console.log('  See apps/character-creator/REBUILD-AUDIT.md, F3 and F5.');
  }

  process.exit(problems ? 1 : 0);
} finally {
  rmSync(state, { recursive: true, force: true });
}
