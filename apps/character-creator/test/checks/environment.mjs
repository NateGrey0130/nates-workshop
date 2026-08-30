// Everything that asks about the ENVIRONMENT rather than about the rules: the
// D1 schema, whether schema.sql alone builds a current database, the data-script
// conventions, the SQL splitter, the documentation claims, whether the .claude
// skills still describe the repo, and the migration record.
//
// The catalog and rules checks that had grown in here live in catalog-data.mjs.
// This header used to promise a separation the file had stopped keeping.
//
// Split out of smoke.mjs, which had grown past 4,000 lines. This half barely
// touched the other: it needed four bindings from it, all of them harness.

import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { batchStatements, trailingSelects, collapseWhitespace, statements, stripComments } from '../../../../scripts/sql-statements.mjs';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';

// The sections this file announces, declared once so a `--section` run can
// skip the whole module — this is the file that shells out to wrangler, which
// is nearly all of the suite's wall clock. Drift in either direction fails
// loud at use: a section added below but not here makes its filter match
// nothing, and a name listed here but renamed below runs the module and still
// matches nothing. Both end in "no section matched", which is a failure.
const SECTIONS = ['D1 schema (local, shared DB)', 'schema.sql self-sufficiency',
  'Data script conventions', 'SQL statement splitting', 'Documentation claims',
  'Skills stay true', 'Book surveys', 'Migration state',
  'What Pages will compile'];

export function run() {
if (!SECTIONS.some(wantSection)) return;
// ---------- 2. D1 schema ----------
// Runs against the shared workshop database (binding DB in the root
// wrangler.jsonc), so this executes from the repo root, not the app dir.
section('D1 schema (local, shared DB)');

function wrangler(args) {
  // maxBuffer: a result set here can be large - the schema and citation
  // queries pull whole markdown columns back as JSON, which overruns
  // spawnSync's 1 MB default and truncates the output mid-parse.
  return spawnSync('npx', ['wrangler', ...args], { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 120000, maxBuffer: 1e9 });
}

const apply = wrangler(['d1', 'execute', 'DB', '--local', '--file', 'db/schema.sql']);
check('schema applies cleanly', apply.status === 0, (apply.stderr || apply.stdout || '').slice(-500));

// SQL goes through a temp file — a quoted --command string doesn't survive the Windows shell.
const checkSql = join(appDir, 'test', '.smoke-check.sql');
writeFileSync(checkSql,
  "SELECT (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('campaigns','characters','journal_entries','level_history','gear','character_items')) AS cc_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'media_items') AS media_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('imported_classes','skills','spells','psionic_powers')) AS catalog_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='catalog_redirects') AS redirect_table, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='character_drafts') AS draft_table, (SELECT count(*) FROM pragma_table_info('spells') WHERE name='system') AS spells_system, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('import_sessions','import_staged')) AS stale_import_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='items') AS stale_items_table, (SELECT sql FROM sqlite_master WHERE name='character_items') AS ci_ddl;\n");
const query = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', checkSql]);
rmSync(checkSql, { force: true });
let row = null;
try { row = JSON.parse(query.stdout)[0].results[0]; } catch { /* fall through to checks */ }
check('all 6 character-creator tables exist', row?.cc_tables === 6, query.stdout?.slice(-300));
check('media_items still intact alongside them', row?.media_tables === 1);
check('class + catalog tables exist', row?.catalog_tables === 4, query.stdout?.slice(-300));
check('catalog_redirects exists', row?.redirect_table === 1, query.stdout?.slice(-300));
check('character_drafts exists', row?.draft_table === 1, query.stdout?.slice(-300));
check('spells carries a system column',
  row?.spells_system === 1, query.stdout?.slice(-300));

// 041 dropped the in-app importer's two staging tables. Checked the same way
// the `items` rename is checked below: a drop is only done when the old thing
// is GONE, and a schema.sql that still created them would show up right here.
check('the retired importer\'s staging tables are gone',
  row?.stale_import_tables === 0, query.stdout?.slice(-300));

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

// q.mjs --batch runs a whole file's statements as ONE --command, so every
// statement — not just the SELECTs trailingSelects() keeps — must come out
// single-line and terminated, or the join truncates at the first newline and
// every statement after it silently never runs.
check('a batch keeps every statement, single-line and terminated', (() => {
  const b = batchStatements("SELECT a,\n       b\n  FROM t;\nUPDATE t SET x = 'a;b';");
  return b.length === 2 && b.every((x) => !x.includes('\n') && /;$/.test(x))
    && /^UPDATE/.test(b[1]) && b[1].includes("'a;b'");
})());

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
// STUB marker in its description instead; class-check generates the SQL.
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
  // Pruning stale branches is configuration, not a step anyone performs:
  // `remote.origin.prune` makes every fetch do it, and `gh pr merge
  // --delete-branch` removes both copies of the branch. The four-command
  // version was in this skill for months and was re-run by hand every few
  // PRs, which is the tell that it should have been config all along.
  //
  // Only RUNNABLE lines are examined. The skill discusses the old commands in
  // prose to explain why they are gone, and that prose must stay legal.
  // `skills` holds directory names, not paths.
  const shipPr = skills.includes('ship-pr')
    ? join(skillsDir, 'ship-pr', 'SKILL.md') : null;
  if (shipPr && existsSync(shipPr)) {
    const text = readFileSync(shipPr, 'utf8');
    // \r? because this file is CRLF. Without it the match found nothing,
    // `fenced` came back empty, and the NEGATIVE check below passed on an
    // empty string — a green tick proving nothing at all. The length
    // guard is here so that cannot happen quietly again.
    const fenced = [...text.matchAll(/```bash\r?\n([\s\S]*?)```/g)]
      .map((m) => m[1]).join('\n');
    check('the ship-pr skill has runnable commands to examine',
      fenced.length > 0,
      'no bash fences matched, so every check below would pass vacuously');
    check('ship-pr no longer tells anyone to prune by hand',
      !/git fetch --prune/.test(fenced) && !/git push origin --delete/.test(fenced),
      'a runnable line still teaches the manual dance');
    check('and merges with --delete-branch instead',
      /gh pr merge[^\n]*--delete-branch/.test(fenced),
      'without it the branch survives on GitHub and locally');
    check('and records the one-time config a fresh clone needs',
      fenced.includes('git config remote.origin.prune true'),
      'the setting lives per clone, so a checkout without it silently accumulates refs');
  }

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

// ---------- 3a. Book surveys ----------
// INGESTION-AUDIT F21: the survey moved out of the gitignored .cache/ and into
// apps/character-creator/docs/surveys/, so the ledger the skills call durable
// state can survive this machine. Three checks, and the shapes they are NOT.
//
// NOT CHECKED, deliberately: that a cached book HAS a survey. The caches are
// gitignored and a clean clone has none, so such a check could only fail on the
// machines that matter - F10 says this outright, and F21 keeps it. This is a
// relocation, not a new gate.
section('Book surveys');
{
  const surveyDir = join(appDir, 'docs', 'surveys');
  const surveys = existsSync(surveyDir)
    ? readdirSync(surveyDir).filter((f) => f.endsWith('.md')) : [];

  check('surveys are present', surveys.length > 0, 'no docs/surveys/*.md');

  // ---- 1. Every survey names a registered slug -------------------------
  // The filename IS the slug, and scripts/books.json is the registry three
  // other mechanisms resolve against. A survey for a slug that registry does
  // not hold is a file nothing can find its book from.
  {
    const registry = JSON.parse(readFileSync(join(repoRoot, 'scripts', 'books.json'), 'utf8'));
    const slugs = new Set(Object.keys(registry.books));
    const unknown = surveys.map((f) => f.replace(/\.md$/, ''))
      .filter((slug) => !slugs.has(slug));
    check(`every survey names a slug scripts/books.json registers (${surveys.length} files)`,
      unknown.length === 0,
      unknown.join(', ') + ' — no book registry entry, so the file has no book');
  }

  // ---- 2. No survey quotes the book ------------------------------------
  // The rule that lets these files be tracked at all: a survey states FACTS
  // about a book - pages, offsets, counts, names - and quotes no prose from it.
  // EFFICIENCY-AUDIT F1 put the survey in .cache/ to keep commercial text out
  // of the repo, and that reason was real; the file moved because it turned out
  // not to need the quotes.
  //
  // This is a CRUDE PROXY and is documented as one in book-survey §7. Verbatim
  // excerpts are written as blockquotes by convention here, so a blockquote is
  // the mechanical grip. It cannot see an inline quotation in italics, and
  // Wormwood's survey carried two of those as well as the blockquote it was
  // written for. The check is a floor, not the rule.
  {
    const quoting = [];
    for (const f of surveys) {
      const lines = readFileSync(join(surveyDir, f), 'utf8').split('\n');
      const n = lines.findIndex((l) => /^\s{0,3}>/.test(l));
      if (n >= 0) quoting.push(`${f}:${n + 1}`);
    }
    check('no survey contains a markdown blockquote', quoting.length === 0,
      quoting.join(', ') + ' — paraphrase it and cite the page instead');
  }

  // ---- 3. The README file map names the directory ----------------------
  // Pinning the CURRENT claim, not the absence of the old one. A check asserting
  // that the README no longer names the old gitignored location would pass the
  // day someone deleted the row entirely - and spelling that old path here would
  // defeat a grep for it, which is the shape F7 caught.
  {
    const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
    check('the README file map names docs/surveys/',
      readme.includes('docs/surveys/'),
      'a directory no map mentions is a directory nobody opens');
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


// ---------- 9. What Pages will compile ----------
// Cloudflare Pages compiles every file under functions/ - reachable from a
// route or not - AND everything they import, with the wrangler its build image
// ships rather than the one this repo runs. That gap cost two days of
// production: a JSON import written the way Node REQUIRES it
// (`with { type: 'json' }`) parses under a current wrangler and does NOT parse
// under the build image's 3.114.17, so every deploy from 2026-08-27 failed
// while every local check stayed green. Fifty-seven merges landed on main and
// not one of them reached production.
//
// THIS IS DELIBERATELY NOT "run the build and see". Shelling out to `npx
// wrangler pages functions build` uses whatever version resolves here, which
// is newer than the build image and compiles the very syntax that broke
// production - a check that would have passed through the whole outage. That
// was measured, not assumed. So the rule is checked as text, where it cannot
// drift with a version.
//
// The closure is the point. Half of what Pages bundles is NOT under functions/
// at all: the routes share `apps/character-creator/js/` with the browser, on
// purpose, and that is fine because browser modules cannot contain Node-only
// syntax either. Checking the directory would have missed a bad import one
// file deeper.
section('What Pages will compile');
{
  const fnDir = join(repoRoot, 'functions');
  const seeds = [];
  const walkFn = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) walkFn(full);
      else if (/\.(js|mjs|ts)$/.test(e.name)) seeds.push(full);
    }
  };
  walkFn(fnDir);

  // Follow relative imports out from every route. Bare specifiers are runtime
  // builtins and never files here.
  const bundled = new Set();
  const queue = [...seeds];
  const IMPORTS = /^\s*(?:import|export)[^'"]*?from\s*['"](\.[^'"]+)['"]/gm;
  while (queue.length) {
    const f = queue.pop();
    if (bundled.has(f) || !existsSync(f)) continue;
    bundled.add(f);
    const text = readFileSync(f, 'utf8');
    for (const m of text.matchAll(IMPORTS)) queue.push(join(dirname(f), m[1]));
  }
  const relB = (f) => f.slice(repoRoot.length + 1).replace(/\\/g, '/');
  check('the bundle closure resolves past functions/ itself',
    bundled.size > seeds.length, bundled.size + ' files from ' + seeds.length + ' routes');

  // Import attributes, in either spelling. `assert` is the older one and is
  // gone from Node 24, so neither form satisfies both runtimes: a module that
  // needs one cannot be in this bundle at all.
  const attrs = [...bundled].filter((f) =>
    /\b(?:with|assert)\s*\{\s*type\s*:/.test(readFileSync(f, 'utf8')));
  check('nothing Pages bundles uses an import attribute',
    attrs.length === 0,
    attrs.map(relB).join(', ') + " - the build image's esbuild cannot parse one; "
      + 'the module belongs in scripts/, not in the bundle');

  // scripts/ is Node CLIs and their pure halves - fs, process, node: imports.
  // Sharing `apps/character-creator/js/` with the browser is the intended
  // pattern; reaching into scripts/ is how a Node-only import got in.
  const fromScripts = [...bundled].filter((f) => f.startsWith(join(repoRoot, 'scripts')));
  check('and none of it reaches into scripts/', fromScripts.length === 0,
    fromScripts.map(relB).join(', ') + ' - scripts/ is Node-only; move what the '
      + 'routes need into functions/ or apps/character-creator/js/');
}
}
