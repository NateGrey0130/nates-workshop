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
import { DB, d1Query, groupDatabases, repoRoot, targetFromArgv } from './d1-query-lib.mjs';
import { join } from 'node:path';
import { cacheCoverage, loadBookRegistry, ocrCacheDir } from './books-lib.mjs';
import { registryBookSlug } from './class-check-lib.mjs';
import { variants } from './catalog-match-lib.mjs';


const target = targetFromArgv();


const d1 = (sql) => d1Query(sql, { target, db: DB });

const problems = [];
const note = (kind, msg) => problems.push(`${kind}: ${msg}`);

// ONE DATABASE PER GROUP (groups.json). Checks 1, 3 and 4 run once per group
// database the repo defines (d1-query-lib.mjs groupDatabases): Palladium's is
// db/schema.sql and db/migrations/, a moved group's is db/schema-<group>.sql
// and db/migrations/<group>/. Checks 2, 5 and 6 are about Palladium's catalog
// and read its database only.
//
// A MOVE LEAVES THINGS BEHIND, ON PURPOSE. When a group's tables move to its
// own database, the originals stay in Palladium's until a migration drops
// them, so a bad move can be undone by switching a binding back. Palladium's
// record also keeps the moved migrations, because it did apply them. Both are
// reported below as LEFT BEHIND, which is information and not drift: it does
// not fail the run. The three moves of 2026-09-25 had their originals dropped
// by 085 the same day, so only the migration records are listed now, as
// history; a future move would list its tables again until its own drop.
const groupDbs = groupDatabases(repoRoot);
const tableOwner = new Map();
for (const [id, g] of Object.entries(JSON.parse(readFileSync(join(repoRoot, 'groups.json'), 'utf8')).groups)) {
  for (const t of g.tables ?? []) tableOwner.set(t, id);
}
const movedGroups = new Set(groupDbs.filter((g) => g.group !== 'palladium').map((g) => g.group));
const movedMigrations = new Set(groupDbs.filter((g) => g.group !== 'palladium')
  .flatMap((g) => readdirSync(join(repoRoot, g.migrations)).filter((f) => f.endsWith('.sql'))));
const leftBehind = [];
const tagOf = (g) => (g.group === 'palladium' ? '' : `[${g.group}] `);
const queryOf = (g) => (sql) => d1Query(sql, { target, db: g.group === 'palladium' ? DB : g.binding });

// ── 1. migrations ───────────────────────────────────────────────────────────
for (const g of groupDbs) {
  const tag = tagOf(g);
  const migFiles = readdirSync(join(repoRoot, g.migrations)).filter((f) => f.endsWith('.sql')).sort();
  const migRows = new Set(queryOf(g)('SELECT filename FROM schema_migrations').map((r) => r.filename));
  console.log(`${tag}migrations:   ${migFiles.length} files, ${migRows.size} recorded`);
  for (const f of migFiles) if (!migRows.has(f)) note(`${tag}MIGRATION NOT APPLIED`, f);
  for (const f of migRows) {
    if (migFiles.includes(f)) continue;
    if (g.group === 'palladium' && movedMigrations.has(f)) leftBehind.push(`migration record ${f} (moved with its group)`);
    else note(`${tag}RECORDED BUT NO FILE`, f);
  }
}

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
for (const g of groupDbs) {
  const tag = tagOf(g);
  const schemaName = g.schema.split('\\').join('/');
  const schemaSql = readFileSync(join(repoRoot, g.schema), 'utf8');
  const declared = new Map();
  for (const m of schemaSql.matchAll(/CREATE TABLE (?:IF NOT EXISTS )?([A-Za-z_]\w*)\s*\(([\s\S]*?)\n\);/g)) {
    const cols = m[2].split('\n')
      .map((l) => l.replace(/--.*$/, '').trim())
      .filter((l) => l && !/^(PRIMARY KEY|FOREIGN KEY|UNIQUE|CHECK|CONSTRAINT)\b/i.test(l))
      .map((l) => (l.match(/^([A-Za-z_]\w*)/) || [])[1])
      .filter(Boolean);
    declared.set(m[1], new Set(cols));
  }
  const live = queryOf(g)("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_cf%'");
  const liveByName = new Map(live.filter((r) => r.name).map((r) => [r.name, r.sql || '']));
  console.log(`${tag}tables:       ${declared.size} in ${schemaName}, ${liveByName.size} live`);

  for (const [name, cols] of declared) {
    const sql = liveByName.get(name);
    if (sql === undefined) { note(`${tag}TABLE MISSING LIVE`, name); continue; }
    for (const c of cols) {
      if (!new RegExp(`[(,\\s]${c}\\s`, 'i').test(sql)) note(`${tag}COLUMN MISSING LIVE`, `${name}.${c}`);
    }
  }
  // FTS5 shadow tables are created by the virtual table, not declared in full.
  const shadow = /_fts$|_fts_(data|idx|content|docsize|config)$/;
  for (const name of liveByName.keys()) {
    if (!declared.has(name) && !shadow.test(name)
        && !['schema_migrations', 'data_script_runs'].includes(name)) {
      if (g.group === 'palladium' && movedGroups.has(tableOwner.get(name))) leftBehind.push(`table ${name} (${tableOwner.get(name)}'s, now in its own database)`);
      else note(`${tag}LIVE TABLE NOT IN ${schemaName}`, name);
    }
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
// The repo can create MORE than is live, and that is not drift: a retired
// class keeps its script so characters built on it keep working, and the
// published count leaves it out. Named here, so the gap between the two
// numbers never needs investigating to be understood (446 against 448 took a
// session to trace to warlock and elemental-shaman, 2026-09-26).
const retired = new Set(d1("SELECT class_id FROM imported_classes WHERE deleted_at IS NOT NULL")
  .map((r) => r.class_id));
const livePublished = new Set(published);
const notLive = [...creators].filter((c) => !livePublished.has(c)).sort();
const describe = (c) => (retired.has(c) ? `${c} (retired)` : c);
console.log(`classes:      ${published.length} published live, ${creators.size} creatable from the repo`
  + (notLive.length ? ` - ${notLive.length} not live: ${notLive.map(describe).join(', ')}` : ''));
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
const cacheDir = ocrCacheDir();
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

// Four queries, not four per book.
//
// `super_abilities` joins the three on the criterion the NOT-gear comment below
// already states - "canonical name lists in the book". Revised Heroes Unlimited
// printed 163 and 169 are alphabetical lists of every minor and major super
// ability, recorded as one of that book's own authority tables in
// docs/surveys/heroes-unlimited-core.md. A name absent from the text means
// something there, which is exactly what the comment asks of a table.
// BOOK-INGEST-AUDIT F86.
//
// `vehicles`, `enchantments` and `totems` STAY OUT, and this is the decision
// F86 asked to be written down either way rather than left to the next reader:
// all three are the GEAR case rather than the spell case. A vehicle's catalog
// name is reworded prose the same way a gear name is - the row says
// `M-41A3 Walker Bulldog` where the page heading is a stat block - and
// `enchantments` and `totems` are named by their own row text rather than by a
// checklist the book prints. A check that cries wolf is worse than no check,
// which is the whole argument of the comment below.
//
// `morphus_characteristics` IS IN, on the same criterion (migration 068). Its
// names are the book's own entry headings, printed as a list down each of the
// 19 tables on 91-106 ("46-60% Lycanthrope:"), and an intro row is named by
// the table's printed heading ("Canine Table") - so a name absent from the text
// means something. Names repeat ACROSS tables ("Combination of Two"), which
// costs nothing here: a name is looked for in the book, not in a table.
//
// `notable_npcs` IS IN too (migration 072): its `name` is the name the book
// prints over that person's stat block - "Gwen Severson", "Power Master" - so
// a name absent from the cited book's text is a mistranscription worth seeing.
// `creatures` is in for the same reason (migration 074): its `name` is the
// heading the book prints over the species' stat block - "Feathered Death".
const CITATION_TABLES = ['spells', 'psionic_powers', 'skills', 'super_abilities', 'talents',
  'morphus_characteristics', 'notable_npcs', 'creatures'];
const citationRows = new Map();   // slug -> [{ table, name }]
for (const table of CITATION_TABLES) {
  for (const r of d1(`SELECT name, source_book FROM ${table} WHERE source_book IS NOT NULL`)) {
    const slug = registryBookSlug(r.source_book, bookRegistry);
    if (!slug) continue;
    if (!citationRows.has(slug)) citationRows.set(slug, []);
    citationRows.get(slug).push({ table, name: r.name });
  }
}

// ── rows checked against the book BY HAND and found correct ────────────────
// The matcher searches a flattened copy of the book's OCR text for the row's
// name. When it misses, the usual reason is not a wrong citation - it is that
// the book prints the name differently, or the OCR read it differently. This
// list is the rows somebody has already opened the book for, so the next
// reader does not repeat the work.
//
// WHY A LIST AND NOT A LOOSER MATCHER. Every miss below is a different fuzz -
// "or" against a slash, a curly apostrophe, OCR stroke confusions, a word the
// OCR split in two, and a catalog name the book only prints in the plural or
// in pieces - and absorbing them all means treating `/`, `l`, `I` and `1` as
// interchangeable, ignoring spaces inside words and allowing elided
// conjunctions. That silences these and quietly silences the next genuinely
// wrong citation too. The matcher stays strict; the exceptions are named,
// dated, and carry what the book actually prints.
//
// KEYED ON THE BOOK AS WELL AS THE NAME, which is the part that keeps this
// honest: re-cite one of these rows to a DIFFERENT book and it drops out of
// this list and is flagged again. An entry excuses one row's claim on one
// book, not the row forever.
//
// The first four verified 2026-09-21 against the cached page text, the last
// four 2026-09-26 (printed page = cache file minus the book's offset of 1).
const CLEARED_CITATIONS = [
  { table: 'spells', name: 'Water: Summon Sharks/Whales', book: 'Rifts Book of Magic',
    printed: 'Summon Sharks or Whales (50) — p.87. The book writes "or" where the catalog writes "/".' },
  { table: 'creatures', name: "Monster Naut'Yll", book: 'Rifts World Book 7: Underseas',
    printed: 'Monster Naut’YIl — p.45 and p.146. Curly apostrophe, and the OCR reads the second "l" as a capital I.' },
  { table: 'morphus_characteristics', name: 'Full Horse/Bovine/Deer Form', book: 'Nightbane RPG',
    printed: 'Full Horse/BovinelDeer Form — p.98. The OCR read the SECOND slash as an "l"; the first survived.' },
  { table: 'morphus_characteristics', name: 'Half-Man, Half-Animal/Were-Animal/Minotaur', book: 'Nightbane RPG',
    printed: 'Half-Man, Half-Animal/Were-AnimallMinotaur: — the same slash-as-l, in the same book.' },
  { table: 'spells', name: 'Ceremony: Dance to Chase Away Evil Spirits & Witches', book: 'Rifts World Book 4: Africa',
    printed: 'Dance to Chase / A way Evil Spirits & Witches — p.89. The OCR split "Away" into "A way" across the line break.' },
  { table: 'creatures', name: 'Erythrusuchus/Mokele-mbembe', book: 'Rifts World Book 4: Africa',
    printed: 'Monster: Mokele-mbembelErythrusuchus — p.144. The slash read as an "l" again, and the book names the two the other way round.' },
  { table: 'creatures', name: 'Lizard Man of Lagarto', book: 'Rifts World Book 6: South America',
    printed: 'Lizard Men R.C.C. — p.79, "the lizard men inhabitants of Lagarto". The catalog name is singular and joins the heading to the kingdom.' },
  { table: 'creatures', name: 'Grimbor Ape-Man', book: 'Rifts World Book 6: South America',
    printed: 'Grimbor Ape-Men — p.138. The book prints the heading plural.' },
];

let citationChecked = 0;
let citationCleared = 0;
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
  // F21. The category-prefix strip lived here as a local `dePrefix` and now
  // lives in `variants` itself, so this is one matcher in one place rather than
  // a rule with two copies. F20 kept it local deliberately - moving it changes
  // what `catalog-diff` matches, measured at 0 -> 269 rows, which is a decision
  // rather than a side effect - and F21 is where that decision was made.
  const found = (n) => {
    // An empty name cannot be searched for; treat it as present rather than
    // accusing the row. `variants('')` is empty, so this guard is load-bearing.
    const forms = variants(n);
    if (!forms.length) return true;
    return forms.some((f) => f && text.includes(` ${f} `));
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
    const cleared = CLEARED_CITATIONS.find(
      (c) => c.table === r.table && c.name === r.name && c.book === book);
    if (cleared) { citationCleared++; continue; }
    citationSuspects.push(`${r.table}.${r.name} claims "${book}" — name absent from its text`);
  }
}
if (citationChecked) {
  console.log(`citations:    ${citationChecked} row(s) checked, `
    + `${citationSuspects.length} worth a look`
    + (citationCleared ? `, ${citationCleared} cleared by hand (see CLEARED_CITATIONS)` : ''));
  // Said out loud rather than left implicit: a silent allowlist is how a
  // check stops meaning anything. If this number drifts from the length of
  // the list, an entry has stopped matching a row - which is either a rename
  // or a re-citation, and both are worth knowing about.
  if (citationCleared && citationCleared !== CLEARED_CITATIONS.length) {
    console.log(`              ! ${CLEARED_CITATIONS.length - citationCleared} cleared entr`
      + `${CLEARED_CITATIONS.length - citationCleared === 1 ? 'y' : 'ies'} matched nothing this run `
      + '— a row was renamed, re-cited, or is no longer missing. Re-check that entry.');
  }
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
if (leftBehind.length) {
  console.log(`LEFT BEHIND in Palladium's database by a group's move - not drift (${leftBehind.length}):`);
  for (const l of leftBehind) console.log('  ' + l);
}
if (!problems.length) {
  console.log(`NO DRIFT (${target})`);
  process.exit(0);
}
console.log(`DRIFT FOUND (${target}): ${problems.length}`);
for (const p of problems) console.log('  ' + p);
process.exit(1);
