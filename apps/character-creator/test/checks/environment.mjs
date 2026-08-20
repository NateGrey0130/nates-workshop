// Everything that asks about the ENVIRONMENT rather than about the rules: the
// D1 schema, whether schema.sql alone builds a current database, the data-script
// conventions, the SQL splitter, the documentation claims, and the migration
// record.
//
// Split out of smoke.mjs, which had grown past 4,000 lines. This half barely
// touched the other: it needed four bindings from it, all of them harness.

import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { trailingSelects, collapseWhitespace, statements, stripComments } from '../../../../scripts/sql-statements.mjs';
import { appDir, repoRoot, check, section } from '../harness.mjs';

export function run() {
// ---------- 2. D1 schema ----------
// Runs against the shared workshop database (binding DB in the root
// wrangler.jsonc), so this executes from the repo root, not the app dir.
section('D1 schema (local, shared DB)');

function wrangler(args) {
  return spawnSync('npx', ['wrangler', ...args], { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 120000 });
}

const apply = wrangler(['d1', 'execute', 'DB', '--local', '--file', 'db/schema.sql']);
check('schema applies cleanly', apply.status === 0, (apply.stderr || apply.stdout || '').slice(-500));

// SQL goes through a temp file — a quoted --command string doesn't survive the Windows shell.
const checkSql = join(appDir, 'test', '.smoke-check.sql');
writeFileSync(checkSql,
  "SELECT (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('campaigns','characters','journal_entries','level_history','gear','character_items')) AS cc_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'media_items') AS media_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('imported_classes','skills','spells','psionic_powers')) AS catalog_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='catalog_redirects') AS redirect_table, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='character_drafts') AS draft_table, (SELECT count(*) FROM pragma_table_info('spells') WHERE name='system') AS spells_system, (SELECT count(*) FROM pragma_table_info('import_sessions') WHERE name='system') AS session_system, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='items') AS stale_items_table, (SELECT sql FROM sqlite_master WHERE name='character_items') AS ci_ddl;\n");
const query = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', checkSql]);
rmSync(checkSql, { force: true });
let row = null;
try { row = JSON.parse(query.stdout)[0].results[0]; } catch { /* fall through to checks */ }
check('all 6 character-creator tables exist', row?.cc_tables === 6, query.stdout?.slice(-300));
check('media_items still intact alongside them', row?.media_tables === 1);
check('class + catalog tables exist', row?.catalog_tables === 4, query.stdout?.slice(-300));
check('catalog_redirects exists', row?.redirect_table === 1, query.stdout?.slice(-300));
check('character_drafts exists', row?.draft_table === 1, query.stdout?.slice(-300));
check('spells and import_sessions carry a system column',
  row?.spells_system === 1 && row?.session_system === 1, query.stdout?.slice(-300));

// The rename must leave nothing behind. A surviving `items` alongside `gear`
// means schema.sql created an empty gear table on an un-migrated database.
check('no stale `items` table remains', row?.stale_items_table === 0,
  'both items and gear exist — run db/migrations/004-items-to-gear.sql');

// SQLite rewrites REFERENCES in dependent tables on rename, but only with
// legacy_alter_table off. Assert it rather than trusting the default.
// It quotes the new name — the DDL reads REFERENCES "gear"(id) — so the
// identifier may or may not be wrapped.
check('character_items foreign key follows the rename',
  /REFERENCES\s+["'`[]?gear["'`\]]?\s*\(/i.test(row?.ci_ddl || ''),
  'character_items still references items — the foreign key did not follow');

// Re-applying must be a no-op (every statement is IF NOT EXISTS).
const reapply = wrangler(['d1', 'execute', 'DB', '--local', '--file', 'db/schema.sql']);
check('schema is idempotent (re-apply is clean)', reapply.status === 0, (reapply.stderr || '').slice(-300));

// ---------- 3. schema.sql is self-sufficient ----------
// A database built from db/schema.sql ALONE must already be current. Section 4
// cannot show that: it queries the shared local database, which has had the
// migrations applied to it by hand, so it reports "current" no matter what
// schema.sql says. That gap shipped — 020 and 021 added `isp_note`/`ppe_note`
// and neither the column nor its guarded seed line was ever mirrored here, so
// a fresh environment built the documented way came up without them and the
// wizard's very first call (`/catalogs`, which selects both) 500'd.
//
// Text checks, deliberately: they read the files the way a new environment
// would, and they hold even where there is no local D1 to apply them to.
section('schema.sql self-sufficiency');

const schemaSql = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
const migrationFiles = readdirSync(join(repoRoot, 'db', 'migrations'))
  .filter((f) => f.endsWith('.sql'))
  .sort();

// The CREATE body for one table, comments stripped, so a column named only in
// prose does not count as declared.
function createdColumns(table) {
  const m = schemaSql.match(
    new RegExp('CREATE TABLE IF NOT EXISTS ' + table + '\\s*\\(([\\s\\S]*?)\\n\\);')
  );
  if (!m) return null;
  return new Set(
    m[1].replace(/--[^\n]*/g, '')
      .split('\n')
      .flatMap((line) => [...line.matchAll(/(?:^|,)\s*(\w+)\s+(?:TEXT|INTEGER|REAL|BLOB|NUMERIC)/g)])
      .map((mm) => mm[1])
  );
}

const missingColumns = [];
const missingSeeds = [];
for (const file of migrationFiles) {
  const sql = readFileSync(join(repoRoot, 'db', 'migrations', file), 'utf8').replace(/--[^\n]*/g, '');
  for (const m of sql.matchAll(/ALTER TABLE (\w+) ADD COLUMN (\w+)/gi)) {
    const cols = createdColumns(m[1]);
    if (cols && !cols.has(m[2])) missingColumns.push(`${m[1]}.${m[2]} (${file})`);
  }
  if (!schemaSql.includes(`'${file}'`)) missingSeeds.push(file);
}

check('every migrated column is also in a schema.sql CREATE', missingColumns.length === 0,
  'missing from schema.sql: ' + missingColumns.join(', ') +
  ' — a database built from schema.sql alone would not have it');

check('every migration has a guarded seed line in schema.sql', missingSeeds.length === 0,
  'no seed line for: ' + missingSeeds.join(', ') +
  ' — a fresh database would report itself un-migrated');

// The guard has to test the schema feature, never insert unconditionally: on an
// existing database every CREATE above it is skipped, so an unguarded row would
// mark an un-migrated database as migrated. That is the lie the table exists to
// prevent, and it is invisible until someone trusts the record.
const unguarded = migrationFiles.filter((f) => {
  const at = schemaSql.indexOf(`'${f}'`);
  if (at < 0) return false;
  return !/^[\s\S]{0,400}?WHERE EXISTS/.test(schemaSql.slice(at));
});
check('every seed line is guarded by a schema feature', unguarded.length === 0,
  'unguarded seed line for: ' + unguarded.join(', '));

section('Data script conventions');

// Data scripts (apps/character-creator/db/*.sql) are not migrations - they
// change rows, not schema - but they had the same hole migrations used to:
// nothing recorded which had been run where. Migration 024 added the log and
// every script now ends by writing itself into it. These checks keep that
// true, because a footer copy-pasted with the previous file's name records a
// run of the wrong script and looks completely fine.
const dataScriptDir = join(appDir, 'db');
const dataScripts = readdirSync(dataScriptDir).filter((f) => f.endsWith('.sql')).sort();
check('data scripts found on disk', dataScripts.length > 0, 'apps/character-creator/db/ is empty');

const unrecorded = [];
const misnamed = [];
const notAscii = [];
const hasCr = [];
for (const f of dataScripts) {
  const raw = readFileSync(join(dataScriptDir, f));
  // The same pre-flight scripts/d1-apply.mjs enforces. A file that fails it is
  // a file the documented tool refuses to apply, which is worth knowing here
  // rather than at the moment you are trying to ship a correction.
  if (raw.includes(0x0d)) hasCr.push(f);
  if (raw.some((b) => b > 0x7f)) notAscii.push(f);

  const sql = raw.toString('utf8');
  const recorded = [...sql.matchAll(/INSERT INTO data_script_runs \(filename\) VALUES \('([^']+)'\)/g)]
    .map((m) => m[1]);
  if (!recorded.length) unrecorded.push(f);
  else if (!recorded.includes(f)) misnamed.push(`${f} records '${recorded.join(", ")}'`);
}

check('every data script records its own run', unrecorded.length === 0,
  'no data_script_runs footer in: ' + unrecorded.join(', '));
check('no data script records another script\'s name', misnamed.length === 0,
  misnamed.join('; ') + ' — a copy-pasted footer logs the wrong script');
check('every data script is pure ASCII', notAscii.length === 0,
  'non-ASCII in: ' + notAscii.join(', ') + ' — scripts/d1-apply.mjs refuses these, and '
  + 'wrangler on Windows has turned them into mojibake in production');
check('no data script carries a CR', hasCr.length === 0,
  'CRLF in: ' + hasCr.join(', ') + ' — the .gitattributes *.sql rule pins LF');

// The same two rules across EVERY .sql in the repo, not just the data scripts.
// db/seed-catalogs.sql carried six em-dashes inside class markdown and is the
// FIRST file a new environment applies, so a mangled character there would be
// baked into every class it seeds. Nothing was checking it.
//
// Comments are exempt on purpose. Checking whole files made d1-apply refuse 11
// of this repo's own migrations over em-dashes in prose, and a guard that
// rejects the files it is documented to apply does not survive contact.
{
  const roots = [join(repoRoot, 'db'), join(repoRoot, 'db', 'migrations'), join(appDir, 'db')];
  const badAscii = [];
  const badCr = [];
  let seen = 0;
  for (const dir of roots) {
    for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql'))) {
      seen++;
      const buf = readFileSync(join(dir, f));
      if (buf.includes(0x0d)) badCr.push(f);
      const code = stripComments(buf.toString('utf8'));
      if ([...code].some((ch) => ch.codePointAt(0) > 0x7f)) badAscii.push(f);
    }
  }
  check('every .sql file was inspected', seen > 80, 'only ' + seen + ' seen');
  check('no .sql has non-ASCII in executable SQL', badAscii.length === 0,
    badAscii.join(', ') + ' — splice it: \'a \' || char(8212) || \' b\'');
  check('no .sql carries a CR', badCr.length === 0, badCr.join(', '));
}

section('SQL statement splitting');

// scripts/d1-apply.mjs replays a data script's own verification SELECTs after a
// remote apply, because --remote --file goes to D1's import endpoint and returns
// aggregate counts with no result sets. Getting the split wrong is invisible in
// the apply - the rows land either way - and only shows up as a read-back that
// silently never happened.
//
// The first version of this shipped broken: it returned the SELECTs across the
// several lines they are written on, and `--command` TRUNCATES AT THE FIRST
// NEWLINE and reports the remainder as `incomplete input: SQLITE_ERROR`. That
// reads like malformed SQL in the script rather than a mangled argument, so the
// single-line property is the one worth pinning hardest.
check('a replayed SELECT is single-line', (() => {
  const sql = "SELECT a,\n       b\n  FROM t;";
  return trailingSelects(sql).every((x) => !x.includes('\n'));
})());

// Collapsing blindly would rewrite the data a query matches on. Class markdown
// cites gear as `item_id: "slug"`, and these read-backs match on that string.
check('collapsing does not touch string literals',
  collapseWhitespace("SELECT  instr(m, 'item_id:  \"x\"')  FROM t")
    === "SELECT instr(m, 'item_id:  \"x\"') FROM t");

check('a semicolon inside a literal does not split a statement',
  statements("UPDATE t SET x = 'a;b'; SELECT 1;").length === 2);

// SQL escapes a quote by doubling it; a state machine that misses that ends the
// literal early and starts splitting on punctuation inside it.
check('a doubled quote does not end a literal',
  statements("SELECT 'it''s; fine' AS x; SELECT 2;").length === 2);

check('a -- inside a literal is not a comment',
  statements("SELECT 'a--b' AS x;")[0].includes('a--b'));

// A SELECT inside an UPDATE's guard belongs to that UPDATE. Replaying it alone
// would be meaningless, and replaying anything that is not a SELECT would make
// a read-back into a second write.
check('a SELECT inside an UPDATE guard is not replayed',
  trailingSelects('UPDATE g SET a = 1 WHERE (SELECT count(*) FROM h) = 4; SELECT 9 AS r;').length === 1);

check('only SELECTs are ever replayed', (() => {
  const sql = readFileSync(join(appDir, 'db', 'retire-orphan-gear-stubs.sql'), 'utf8');
  return trailingSelects(sql).every((t) => /^select\b/i.test(t));
})());

// Every data script's own read-back must survive the round trip. This is the
// check that would have caught the shipped bug.
{
  const dir = join(appDir, 'db');
  const offenders = [];
  for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql'))) {
    for (const st of trailingSelects(readFileSync(join(dir, f), 'utf8'))) {
      if (st.includes('\n') || !/;$/.test(st)) offenders.push(f);
    }
  }
  check('every data script replays as single-line, terminated SQL',
    offenders.length === 0, offenders.join(', '));
}

section('Documentation claims');

// Three checks for three ways the docs went wrong in one session. All of them
// read the repo rather than the database, so they cost nothing.

// ---- 1. A column claimed for a table that does not have it ----------------
// The README said "All catalogs carry `source`". `gear` never has - it uses a
// STUB marker in its description instead, and _lib/import-engine.js says so.
// A query written from that sentence was rejected by production.
//
// The rule that catches it: inside a data-model row for table X, a backticked
// name that IS a column on some OTHER table but not on X is a misplaced claim.
// Names that are columns nowhere are skipped - those are JSON keys inside JSON
// columns (`iq_bonus`, `gained_at_level`), which the tables document on purpose.
{
  const schemaText = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  const columnsOf = {};
  for (const m of schemaText.matchAll(/CREATE TABLE IF NOT EXISTS (\w+)\s*\(([\s\S]*?)\n\);/g)) {
    const cols = new Set();
    for (const line of m[2].replace(/--[^\n]*/g, '').split('\n')) {
      const c = line.match(/^\s*(\w+)\s+(?:TEXT|INTEGER|REAL|BLOB|NUMERIC)/);
      if (c) cols.add(c[1]);
    }
    columnsOf[m[1]] = cols;
  }
  const everyColumn = new Set(Object.values(columnsOf).flatMap((s2) => [...s2]));
  const readmeText = readFileSync(join(appDir, 'README.md'), 'utf8');

  const misplaced = [];
  for (const row of readmeText.matchAll(/^\| `([a-z_]+)` \|(.*)\|$/gm)) {
    const table = row[1];
    if (!columnsOf[table]) continue;                    // not a table row
    for (const cell of row[2].matchAll(/`([a-z_]{3,})`/g)) {
      const name = cell[1];
      if (columnsOf[table].has(name)) continue;         // correct
      if (columnsOf[name]) continue;                    // naming another table
      if (!everyColumn.has(name)) continue;             // a JSON key, not a column
      misplaced.push(`${table} row claims \`${name}\``);
    }
  }
  check('no data-model row claims a column its table lacks', misplaced.length === 0,
    misplaced.join('; ') + ' — that name is a column on a different table');
}

// ---- 2. Every internal markdown link resolves ----------------------------
// 23 files linking to each other by relative path and to their own headings.
// A renamed section leaves a link that looks fine and goes nowhere.
{
  const slug = (h) => h.trim().toLowerCase().replace(/[`*_]/g, '')
    .replace(/[^\w\s-]/g, '').replace(/\s+/g, '-');
  const docs = [];
  const walkMd = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      if (['.git', '.wrangler', 'node_modules'].includes(e.name)) continue;
      const full = join(dir, e.name);
      if (e.isDirectory()) walkMd(full);
      else if (e.name.endsWith('.md')) docs.push(full);
    }
  };
  walkMd(repoRoot);
  const anchorsOf = (text) =>
    new Set([...text.matchAll(/^#{1,6}\s+(.*)$/gm)].map((m) => slug(m[1])));

  const broken = [];
  for (const doc of docs) {
    const text = readFileSync(doc, 'utf8');
    const own = anchorsOf(text);
    const base = dirname(doc);
    for (const m of text.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) {
      const target = m[1].trim();
      if (/^(https?:|mailto:)/.test(target)) continue;
      const [path, frag] = target.split('#');
      const rel = doc.slice(repoRoot.length + 1).replace(/\\/g, '/');
      if (!path) {
        if (frag && !own.has(frag)) broken.push(`${rel} -> #${frag}`);
        continue;
      }
      const full = join(base, path);
      if (!existsSync(full)) { broken.push(`${rel} -> ${target}`); continue; }
      if (frag && full.endsWith('.md') && !anchorsOf(readFileSync(full, 'utf8')).has(frag)) {
        broken.push(`${rel} -> ${target}`);
      }
    }
  }
  check(`all internal markdown links resolve (${docs.length} files)`,
    broken.length === 0, broken.slice(0, 6).join('; '));
}

// ---- 3. SETUP.md's endpoint count ----------------------------------------
// It said ~20 where there were 35. The same drift the README's table count
// check exists for, one file over.
{
  const setup = readFileSync(join(repoRoot, 'SETUP.md'), 'utf8');
  const countEndpoints = (dir) => readdirSync(dir, { withFileTypes: true })
    .reduce((n, e) => e.isDirectory()
      ? n + (e.name === '_lib' ? 0 : countEndpoints(join(dir, e.name)))
      : n + (e.name.endsWith('.js') ? 1 : 0), 0);
  const actual = countEndpoints(join(repoRoot, 'functions', 'api', 'character-creator'));
  const stated = setup.match(/(~?\d+) endpoints \+ _lib/);
  check('SETUP.md states the endpoint count', !!stated);
  check('and it matches the routing tree',
    !!stated && parseInt(stated[1].replace('~', ''), 10) === actual,
    stated ? `SETUP says ${stated[1]}, there are ${actual}` : '');
}

section('Skills stay true');

// Skills are instructions with no runtime, so they rot silently. Migration 024
// added the data_script_runs footer and made the smoke test require it; the
// class-import skill's template kept teaching the old shape for hours, and
// anyone following it produced a script that failed the build immediately.
//
// These checks tie the skills to the things they describe.
{
  const skillsDir = join(repoRoot, '.claude', 'skills');
  const skills = existsSync(skillsDir)
    ? readdirSync(skillsDir, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name)
    : [];
  check('skills are present', skills.length > 0, 'no .claude/skills/*');

  const badPaths = [];
  const badChecks = [];
  const noFrontmatter = [];
  // EVERY check file, not just smoke.mjs. The checks used to all live in one
  // file; splitting them moved half out from under this scan, and this check
  // failed the moment they did - correctly, since a skill quoting a check name
  // it can no longer find is exactly what it exists to catch.
  const checkFiles = [join(appDir, 'test', 'smoke.mjs'),
    ...readdirSync(join(appDir, 'test', 'checks'))
      .filter((f) => f.endsWith('.mjs'))
      .map((f) => join(appDir, 'test', 'checks', f))];
  const smokeSelf = checkFiles.map((f) => readFileSync(f, 'utf8')).join('\n');

  for (const name of skills) {
    const dir = join(skillsDir, name);
    const files = [];
    const walkSkill = (d) => {
      for (const e of readdirSync(d, { withFileTypes: true })) {
        const full = join(d, e.name);
        if (e.isDirectory()) walkSkill(full);
        else files.push(full);
      }
    };
    walkSkill(dir);

    const main = join(dir, 'SKILL.md');
    if (!existsSync(main)) { noFrontmatter.push(name + ' (no SKILL.md)'); continue; }
    const md = readFileSync(main, 'utf8');
    if (!/^---[\s\S]*?\nname:\s*\S+[\s\S]*?\ndescription:\s*\S+[\s\S]*?\n---/.test(md)) {
      noFrontmatter.push(name);
    }

    for (const f of files) {
      const text = readFileSync(f, 'utf8');
      const rel = f.slice(repoRoot.length + 1).replace(/\\/g, '/');

      // A repo path a skill tells you to open must exist.
      for (const m of text.matchAll(/`((?:db|scripts|apps|functions|shared)\/[A-Za-z0-9_./-]+\.(?:js|mjs|sql|md|json|css|html))`/g)) {
        // Skip placeholders and elisions: NNN-kebab.sql, <id>.sql, api/.../x.js
        if (/\.\.\.|NNN|<|>|\*/.test(m[1])) continue;
        if (!existsSync(join(repoRoot, m[1]))) badPaths.push(`${rel} -> ${m[1]}`);
      }

      // A smoke-check name a skill quotes must still be one.
      for (const m of text.matchAll(/`(every [a-z][^`]{12,})`/g)) {
        if (!smokeSelf.includes(m[1])) badChecks.push(`${rel} -> "${m[1]}"`);
      }
    }
  }

  check('every SKILL.md has name/description frontmatter', noFrontmatter.length === 0,
    noFrontmatter.join(', '));
  check('every repo path a skill names exists', badPaths.length === 0,
    badPaths.slice(0, 6).join('; '));
  check('every smoke check a skill quotes still exists', badChecks.length === 0,
    badChecks.slice(0, 6).join('; ') + ' — a renamed check leaves the skill lying');

  // The data-script template must satisfy the conventions the smoke test
  // enforces on the scripts it produces, or it teaches a failing shape.
  const tpl = join(skillsDir, 'class-import', 'reference', 'data-script.sql');
  if (existsSync(tpl)) {
    const t = readFileSync(tpl, 'utf8');
    check('the data-script template records a run',
      /INSERT INTO data_script_runs \(filename\) VALUES/.test(t),
      'reference/data-script.sql would produce a script the smoke test rejects');
  }
}

// ---------- 4. Migration state ----------
// Every file in db/migrations/ should have a schema_migrations row. A missing
// one means this database never had that migration applied — the question that
// used to be answered by guessing at pragma_table_info output.
section('Migration state');

const onDisk = readdirSync(join(repoRoot, 'db', 'migrations'))
  .filter((f) => f.endsWith('.sql'))
  .sort();
check('migration files found on disk', onDisk.length > 0, 'db/migrations/ is empty');

const migSql = join(appDir, 'test', '.smoke-migrations.sql');
writeFileSync(migSql, 'SELECT filename FROM schema_migrations ORDER BY filename;\n');
const migQuery = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', migSql]);
rmSync(migSql, { force: true });

let recorded = null;
try { recorded = JSON.parse(migQuery.stdout)[0].results.map((r) => r.filename); } catch { /* checked below */ }
check('schema_migrations is queryable', Array.isArray(recorded), migQuery.stdout?.slice(-300));

if (Array.isArray(recorded)) {
  const missing = onDisk.filter((f) => !recorded.includes(f));
  check('every migration on disk is recorded as applied', missing.length === 0,
    'not recorded: ' + missing.join(', ') + ' — apply it, or re-run db/schema.sql if the schema is already current');

  // A row with no matching file means a migration was renamed or deleted after
  // being applied somewhere, which breaks the convention that they are immutable.
  const orphans = recorded.filter((f) => !onDisk.includes(f));
  check('no recorded migration is missing its file', orphans.length === 0,
    'recorded but not on disk: ' + orphans.join(', '));
}


}
