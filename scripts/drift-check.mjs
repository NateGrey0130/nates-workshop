// Does the live database match the repo?
//
//   node scripts/drift-check.mjs --remote
//   node scripts/drift-check.mjs --local
//
// The smoke test proves the repo is internally consistent - schema.sql agrees
// with the migrations, the README agrees with both. The regression test proves
// a database built FROM the repo works. Neither can see the live database, and
// the gap between them is where the expensive mistakes live: a migration
// written and never applied, a data script run locally and forgotten remotely,
// a class that exists only because someone imported it through the UI.
//
// Five comparisons:
//   1. every migration file vs schema_migrations
//   2. every data script vs data_script_runs
//   3. every table in schema.sql vs sqlite_master
//   4. every column in schema.sql vs the live CREATE text
//   5. every published class vs one a data script can recreate
//
// Read-only. It writes nothing, so it is safe to point at production.
//
// TWO THINGS THAT COST AN HOUR THE FIRST TIME:
//   * `--file` over `--remote` returns a SUMMARY row ("Total queries executed")
//     instead of the query results, so every count came back as 1. Use
//     `--command`.
//   * execFileSync with shell:true does not quote the arguments it joins, so
//     the SQL lost its spaces; without a shell Node refuses to spawn npx.cmd on
//     Windows at all. So: one command string, quoting the SQL here. Every query
//     below uses single quotes internally, which keeps the double quotes safe.
//
// sqlite_master and the two tracking tables are authoritative. pragma_table_info
// is not over --remote - it has returned stale replica data mid-migration - so
// columns are read out of sqlite_master's stored CREATE text.
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { DB, d1Query, repoRoot, targetFromArgv } from './d1-query-lib.mjs';
import { join } from 'node:path';
import { cacheCoverage, loadBookRegistry } from './books-lib.mjs';
import { registryBookSlug } from './class-check-lib.mjs';
import { variants } from './catalog-match-lib.mjs';


const target = targetFromArgv();


const d1 = (sql) => d1Query(sql, { target, db: DB });

const problems = [];
const note = (kind, msg) => problems.push(`${kind}: ${msg}`);

// ── 1. migrations ───────────────────────────────────────────────────────────
const migDir = join(repoRoot, 'db', 'migrations');
const migFiles = readdirSync(migDir).filter((f) => f.endsWith('.sql')).sort();
const migRows = new Set(d1('SELECT filename FROM schema_migrations').map((r) => r.filename));
console.log(`migrations:   ${migFiles.length} files, ${migRows.size} recorded`);
for (const f of migFiles) if (!migRows.has(f)) note('MIGRATION NOT APPLIED', f);
for (const f of migRows) if (!migFiles.includes(f)) note('RECORDED BUT NO FILE', f);

// ── 2. data scripts ─────────────────────────────────────────────────────────
const dataDir = join(repoRoot, 'apps', 'character-creator', 'db');
const allFiles = readdirSync(dataDir).filter((f) => f.endsWith('.sql')).sort();
// seed-dev carries the local-only marker and must never run remotely.
const dataFiles = allFiles.filter(
  (f) => !/^--\s*local-only\b/m.test(readFileSync(join(dataDir, f), 'utf8')));
const dataRows = new Set(d1('SELECT filename FROM data_script_runs').map((r) => r.filename));
console.log(`data scripts: ${dataFiles.length} files, ${dataRows.size} recorded`);
for (const f of dataFiles) if (!dataRows.has(f)) note('DATA SCRIPT NOT RUN', f);
for (const f of dataRows) if (!allFiles.includes(f)) note('RUN BUT NO FILE', f);
for (const f of dataRows) {
  if (allFiles.includes(f) && !dataFiles.includes(f)) {
    note('LOCAL-ONLY SCRIPT RECORDED AS RUN', `${f} — it must never run remotely`);
  }
}

// ── 3 & 4. tables and columns ───────────────────────────────────────────────
const schemaSql = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
const declared = new Map();
for (const m of schemaSql.matchAll(/CREATE TABLE (?:IF NOT EXISTS )?([A-Za-z_]\w*)\s*\(([\s\S]*?)\n\);/g)) {
  const cols = m[2].split('\n')
    .map((l) => l.replace(/--.*$/, '').trim())
    .filter((l) => l && !/^(PRIMARY KEY|FOREIGN KEY|UNIQUE|CHECK|CONSTRAINT)\b/i.test(l))
    .map((l) => (l.match(/^([A-Za-z_]\w*)/) || [])[1])
    .filter(Boolean);
  declared.set(m[1], new Set(cols));
}
const live = d1("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf%'");
const liveByName = new Map(live.filter((r) => r.name).map((r) => [r.name, r.sql || '']));
console.log(`tables:       ${declared.size} in schema.sql, ${liveByName.size} live`);

for (const [name, cols] of declared) {
  const sql = liveByName.get(name);
  if (sql === undefined) { note('TABLE MISSING LIVE', name); continue; }
  for (const c of cols) {
    if (!new RegExp(`[(,\\s]${c}\\s`, 'i').test(sql)) note('COLUMN MISSING LIVE', `${name}.${c}`);
  }
}
// FTS5 shadow tables are created by the virtual table, not declared in full.
const shadow = /_fts$|_fts_(data|idx|content|docsize|config)$/;
for (const name of liveByName.keys()) {
  if (!declared.has(name) && !shadow.test(name)
      && !['schema_migrations', 'data_script_runs'].includes(name)) {
    note('LIVE TABLE NOT IN schema.sql', name);
  }
}

// ── 5. class provenance ─────────────────────────────────────────────────────
// A published class no data script creates is one a fresh environment comes up
// WITHOUT, and one that exists in exactly one place. chiang-ku-dragon and juicer
// were both in that state until a drift check found them.
const published = d1("SELECT class_id FROM imported_classes WHERE deleted_at IS NULL AND status = 'published'")
  .map((r) => r.class_id).filter(Boolean);
const creators = new Set();
// Three INSERT shapes and two directories, all of them in use:
//   INSERT INTO ... VALUES ('id',            - the older class scripts
//   INSERT OR IGNORE INTO ... VALUES ('id',  - add-godling-class.sql
//   INSERT INTO ... SELECT 'id', ...         - the newer guarded form
// and the three oldest classes are seeded from db/seed-catalogs.sql rather than
// from apps/character-creator/db at all. Matching one shape in one directory
// reported eighteen false positives; matching two reported four.
const CREATE_RE = /INSERT (?:OR IGNORE )?INTO imported_classes[\s\S]{0,400}?(?:VALUES\s*\(|SELECT\s+)'([a-z0-9-]+)'/g;
const sources = [
  ...allFiles.map((f) => join(dataDir, f)),
  join(repoRoot, 'db', 'seed-catalogs.sql'),
];
for (const path of sources) {
  const sql = readFileSync(path, 'utf8');
  for (const m of sql.matchAll(CREATE_RE)) creators.add(m[1]);
}
console.log(`classes:      ${published.length} published live, ${creators.size} creatable from the repo`);
for (const c of published) {
  if (!creators.has(c)) note('CLASS NOT REPRODUCIBLE', `${c} — no data script creates it`);
}

// ── 6. citations ────────────────────────────────────────────────────────────
// Does a row's stated source actually contain it?
//
// Every psionic power in the catalog claimed `source_book = 'Rifts Ultimate
// Edition'`. Twelve of them appear nowhere in that book - they came from an
// extraction that invented them, and nothing noticed for months, because
// nothing had ever asked. drift-check asks whether the repo can rebuild the
// database; this asks whether the database is telling the truth about where it
// came from.
//
// Runs only for books whose OCR cache is present (see scripts/ocr-book.py).
// The cache is gitignored, so on a machine without it this silently does
// nothing rather than failing - a missing cache is not drift.
//
// WHICH books is scripts/books.json intersected with the caches actually on
// this machine. It used to be one hard-coded pair, `Rifts Ultimate Edition` ->
// `rue`, which could not grow with the shelf: seven other books were cached and
// none of them was ever asked the question.
//
// The rows are read WHOLE and bucketed here rather than selected per book. Two
// reasons, and the second is not optional: a `source_book = ... OR ... LIKE` list
// over a five-spelling vocabulary is exactly the query D1 rejects outright with
// "LIKE or GLOB pattern too complex"; and bucketing with registryBookSlug means
// the citation check and `class-check --field-sources` decide which book a row
// belongs to by running the same function, rather than by two spellings of the
// same intention that drift apart.
const cacheDir = join(repoRoot, '.cache', 'books');
const bookRegistry = loadBookRegistry();

// The cache status, printed ALWAYS - including when there is no cache at all.
// Every guard downstream of here treats a missing cache as a non-event, which
// is right for a clean clone and means total LOSS of the cache reads exactly
// the same: two of the three checks go quiet and keep exiting 0. This is the
// one line that tells the two apart. It is a status line, NOT a gate - the
// exit code must not move, because a clean clone is legitimate. Recovering a
// cache is one ocr-book.py run from source_pdf + source_pdf_dir in the
// registry; recovering a PDF that was never kept is not possible at all.
const cachedSlugs = existsSync(cacheDir)
  ? readdirSync(cacheDir).filter((s) => existsSync(join(cacheDir, s, 'txt')))
  : [];
const registeredSlugs = Object.keys(bookRegistry);
const presentSlugs = registeredSlugs.filter((s) => cachedSlugs.includes(s));
const strays = cachedSlugs.filter((s) => !registeredSlugs.includes(s));
console.log(`caches:       ${presentSlugs.length} of ${registeredSlugs.length} registered books present`
  + (presentSlugs.length ? ` — ${presentSlugs.join(', ')}` : '')
  + (strays.length ? `; ${strays.length} not in the registry: ${strays.join(', ')}` : ''));

// Three queries, not three per book. ~1,000 rows.
const CITATION_TABLES = ['spells', 'psionic_powers', 'skills'];
const citationRows = new Map();   // slug -> [{ table, name }]
for (const table of CITATION_TABLES) {
  for (const r of d1(`SELECT name, source_book FROM ${table} WHERE source_book IS NOT NULL`)) {
    const slug = registryBookSlug(r.source_book, bookRegistry);
    if (!slug) continue;
    if (!citationRows.has(slug)) citationRows.set(slug, []);
    citationRows.get(slug).push({ table, name: r.name });
  }
}

let citationChecked = 0;
let citationSkipped = false;
const citationSuspects = [];
for (const slug of Object.keys(bookRegistry)) {
  const txtDir = join(cacheDir, slug, 'txt');
  if (!existsSync(txtDir)) continue;
  const book = bookRegistry[slug].title;
  const rows = citationRows.get(slug) ?? [];
  const files = readdirSync(txtDir).filter((f) => f.endsWith('.txt') && !f.endsWith('.raw.txt'));
  // A PARTIAL cache must not be consulted. "At least N pages" is not the same
  // as complete: run against 81 of 382 pages this accused four gear rows whose
  // page simply had not been OCR'd yet.
  //
  // The gate used to compare the file count against `manifest.pages`, which is
  // the SOURCE PDF's page count. `fom` was a 73-page cache of a 161-page book,
  // built from a truncated PDF, and its manifest said `"pages": 73` — so it
  // passed, and half a book read as all of it. cacheCoverage compares against
  // the book's own last printed folio instead, taken from scripts/books.json in
  // preference to the manifest for the reason spelled out there.
  const manifestPath = join(cacheDir, slug, 'manifest.json');
  if (!existsSync(manifestPath)) {
    // `pf` was the live case, and it is the most-cited book in the database.
    // Say so: a silent `continue` here reads exactly like a book with nothing
    // to check.
    console.log(`citations:    ${slug} cache has no manifest.json — skipped`);
    citationSkipped = true;
    continue;
  }
  const cover = cacheCoverage({
    cachedPages: files.length,
    manifest: JSON.parse(readFileSync(manifestPath, 'utf8')),
    registryEntry: bookRegistry[slug],
  });
  // SKIP, not fail. An incomplete cache silences the check exactly as before;
  // all that changes is that the reason is printed, and that `fom` would now
  // be caught. A missing cache is not drift, and neither is a short one.
  if (!cover.complete) {
    console.log(`citations:    ${slug} cache incomplete `
      + `(${cover.cached} of ${cover.needed ?? '?'} pages, ${cover.basis}`
      + `${cover.printedFrom ? `, from ${cover.printedFrom}` : ''}) — skipped`);
    citationSkipped = true;
    continue;
  }
  const text = ' ' + files.map((f) => readFileSync(join(txtDir, f), 'utf8')).join('\n')
    .toLowerCase().replace(/[^a-z0-9]+/g, ' ') + ' ';

  // Whole name, parenthetical dropped, singular/plural tolerant. Anything
  // looser condemns rows that are really there, and anything stricter
  // condemns "Commune with Spirit" because the book prints the plural.
  // The book text was flattened by deleting every non-alphanumeric, so "&"
  // VANISHES there. Expanding it to "and" on this side only made 18 skills
  // look absent - "Motorcycles & Snowmobiles" became "motorcycles and
  // snowmobiles" while the book held "motorcycles snowmobiles". Try both
  // readings, and both numbers.
  // F20. The name spellings come from `catalog-match-lib.mjs`, which is the
  // repo's name matcher: `catalog-diff.mjs` uses it and
  // `test/checks/catalog-matching.mjs` pins it. What stood here was a SECOND,
  // hand-rolled matcher solving the same problem worse - every variant F19
  // added to it (an `and`/`or` elision, singular/plural, parenthetical dropped)
  // already existed there as `loose`, `variants` and `stem`, and the library
  // also has a slash-half rule this had nothing for.
  //
  // F19 declined this consolidation on the reading that `variants` runs through
  // `normalise`, which expands "&" to "and" where the old flattener DELETED it -
  // and the comment that used to sit here recorded 18 skills that went missing
  // when that expansion was applied alone. Measured before switching: 27 catalog
  // rows carry an "&" and all 27 are found either way. `loose` is why, since it
  // strips the "and" that `normalise` introduces. The 18-skill failure was real
  // against `normalise` ALONE and was never an argument against `variants`.
  //
  // THE PREFIX STRIP STAYS LOCAL. The catalog's category prefix - "Air: ",
  // "W.P. " - is part of the stored name and no book prints it, so a book saying
  // "Tornado" under a heading "Air" must still meet `Air: Tornado`. Two shapes,
  // because "W.P." carries no colon; lazy `+?` so a name with two colons loses
  // only the first.
  //
  // `variants` has no notion of a prefix, and giving it one is a SEPARATE
  // decision rather than a side effect of this one: measured, it would move
  // `catalog-diff` from 0 to 269 matched rows on the 374 prefixed names, which
  // is far outside "one fewer advisory line" - the acceptance test F20 sets for
  // this change. The measurement is under F20's outcome note in
  // BOOK-INGEST-AUDIT.md, unfiled and waiting on a number.
  const dePrefix = (n) => String(n).replace(/^(?:[A-Za-z .]+?:|W\.P\.)\s*/, '');
  const found = (n) => {
    // An empty name cannot be searched for; treat it as present rather than
    // accusing the row. `variants('')` is empty, so this guard is load-bearing.
    if (!variants(n).length) return true;
    const forms = new Set([...variants(n), ...variants(dePrefix(n))]);
    return [...forms].some((f) => f && text.includes(` ${f} `));
  };

  // NOT gear. A gear name in this catalog is reworded prose, not a heading the
  // book prints: the catalog says `"Dead Boy" Body Armor CA-2 (Light)` where
  // RUE says "CA-2 Light Body Armor", and `Light Mdc Body Armor` where the
  // book says "light M.D.C. body armor". 35 of 40 findings were that, and a
  // check that cries wolf 35 times is worse than no check.
  //
  // The other three tables have canonical name lists in the book - a checklist,
  // an index, a skill list - so a name absent from the text means something.
  citationChecked += rows.length;
  for (const r of rows.filter((x) => !found(x.name))) {
    citationSuspects.push(`${r.table}.${r.name} claims "${book}" — name absent from its text`);
  }
}
if (citationChecked) {
  console.log(`citations:    ${citationChecked} row(s) checked, `
    + `${citationSuspects.length} worth a look`);
  // ADVISORY, deliberately not drift. Whether a citation is right is a
  // different question from whether the repo can rebuild the database, and
  // wiring it into the exit code would fail every run over a name the book
  // spells differently - which is how a useful check gets ignored.
  for (const c of citationSuspects) console.log(`              ? ${c}`);
  if (citationSuspects.length) {
    console.log('              (advisory: a name the book writes differently reads the');
    console.log('               same as one it never had. Check before acting.)');
  }
} else if (!citationSkipped) {
  console.log('citations:    no OCR cache — skipped (see scripts/ocr-book.py)');
}

// ── verdict ─────────────────────────────────────────────────────────────────
console.log('');
if (!problems.length) {
  console.log(`NO DRIFT (${target})`);
  process.exit(0);
}
console.log(`DRIFT FOUND (${target}): ${problems.length}`);
for (const p of problems) console.log('  ' + p);
process.exit(1);
