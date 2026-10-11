// The catalog editor's field config: the one description of each catalog
// table that the editor, the write endpoints and the row generators all build
// themselves from, and the form that takes its widths from a field's type.
//
// Two sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. No binding is exclusive to them - `CATALOGS` and `coerceField`
// are read all over the suite - so the reason for this cut is the subject and
// the size, not the imports. Nothing declared here was read anywhere else, and
// nothing these sections read was declared outside them.
//
// The body moved verbatim. One path changed, because this file sits a
// directory deeper: the `import()` of `js/class-keys.js`.

import { readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';
import { CATALOGS, coerceField } from '../../js/catalog-fields.js';
import { appDir, repoRoot, appPath, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Catalog field config', 'The row form takes its widths from the field type'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- 1b. Catalog field config ----------
// The editor, the write endpoints and the importers all generate themselves
// from this, so an inconsistent entry breaks three things at once.
section('Catalog field config');
const catalogProblems = [];
for (const [key, c] of Object.entries(CATALOGS)) {
  const names = c.fields.map((f) => f.name);
  if (!c.table || !c.displayField || !c.uniqueField) catalogProblems.push(`${key}: missing table/displayField/uniqueField`);
  if (!names.includes(c.displayField)) catalogProblems.push(`${key}: displayField "${c.displayField}" is not a field`);
  if (!names.includes(c.uniqueField)) catalogProblems.push(`${key}: uniqueField "${c.uniqueField}" is not a field`);
  if (new Set(names).size !== names.length) catalogProblems.push(`${key}: duplicate field names`);
  for (const f of c.fields) {
    if (!f.label || !f.type) catalogProblems.push(`${key}.${f.name}: missing label or type`);
    if (f.type === 'select' && !Array.isArray(f.options)) catalogProblems.push(`${key}.${f.name}: select without options`);
    // A json_list with no `of` would validate every entry against nothing.
    if (f.type === 'json_list' && !(f.of === 'string' || (f.of && typeof f.of === 'object'))) {
      catalogProblems.push(`${key}.${f.name}: json_list without an 'of' shape`);
    }
  }
}
check('catalog configs are internally consistent', catalogProblems.length === 0, catalogProblems.join('; '));

// AND EVERY FIELD IS A REAL COLUMN. The check above is internal - it proves the
// config agrees with itself and says nothing about the database. The write
// endpoints build their SQL from these names (`catalogs/rows.js`, search
// `fieldNames(cat)`), so a field naming a column that does not exist is a
// runtime failure on the first save rather than anything a config check sees.
//
// Built from db/schema.sql rather than from a live database, deliberately:
// this asks whether a FRESH environment agrees with the config, which is the
// environment the mistake would otherwise be found in. Added with the ninth
// catalog (`BOOK-INGEST-AUDIT.md` F76), whose entry is 14 fields declared by
// hand against a table created in another PR - exactly the shape this catches.
{
  const schemaText = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  const mem = new DatabaseSync(':memory:');
  mem.exec(schemaText);
  const wrong = [];
  for (const [key, c] of Object.entries(CATALOGS)) {
    const cols = new Set(mem.prepare('SELECT name FROM pragma_table_info(?)').all(c.table).map((r) => r.name));
    if (!cols.size) { wrong.push(`${key}: no table "${c.table}" in schema.sql`); continue; }
    for (const f of c.fields) if (!cols.has(f.name)) wrong.push(`${key}.${f.name} is not a column of ${c.table}`);
    // `hasSource` makes the endpoints read and write a `source` column.
    if (c.hasSource && !cols.has('source')) wrong.push(`${key}: hasSource but ${c.table} has no source column`);
  }
  mem.close();
  check('and every catalog field is a real column in schema.sql', wrong.length === 0, wrong.join('; '));
}

// EVERY CATALOG IS IN EVERY HAND-WRITTEN CATALOG LIST. BOOK-INGEST-AUDIT F100.
//
// CATALOGS above is the DECLARED list. Five other lists name the catalogs by hand,
// and nothing tied them to it: the ninth catalog (`talents`, F76) had to be added
// to each by a person remembering, which had already failed three times - F28,
// then F85 twice over, where 466 cited rows were verified by nothing for want of
// three strings. F85 predicted in its own ongoing-cost line that the ninth would
// be omitted too.
//
// A CHECK RATHER THAN A REFACTOR, on Nate's word (2026-09-16). Deriving these
// lists from CATALOGS was the other option, and it was declined for the reason
// F85 gave: the lists `disagree about scope on purpose`, and a derived base list
// makes a deliberate exclusion easy to lose. So each list stays literal, and this
// asserts it is complete unless an exclusion is NAMED HERE with its reason.
//
// The three scripts are read as TEXT. None of them can be imported: all three do
// their work at module scope - query D1, spawn wrangler, build a scratch database
// - so importing one from the suite would run a whole ledger.
{
  const tables = Object.values(CATALOGS).map((c) => c.table);
  const keys = Object.keys(CATALOGS);
  const readRepo = (f) => readFileSync(join(repoRoot, f), 'utf8');
  const quoted = (s) => [...s.matchAll(/'([a-z_]+)'/g)].map((m) => m[1]);

  // 1 and 2. source-coverage's live-side and build-side group lists. These two
  // must ALSO agree with each other, which is the sharper half: when they
  // differed by one table every run printed a standing negative delta the size
  // of that whole table, and nothing named it (F85: -171, then -220).
  const sc = readRepo('scripts/source-coverage.mjs');
  const spreads = [...sc.matchAll(/\.\.\.(\[[^\]]*\])\.map\(/g)].map((m) => quoted(m[1]));
  check('both source-coverage catalog lists were found', spreads.length === 2, `found ${spreads.length}`);
  for (const [i, s] of spreads.entries()) {
    const missing = tables.filter((t) => !s.includes(t));
    check(`source-coverage list ${i + 1} of 2 names every catalog`, missing.length === 0,
      'missing: ' + missing.join(', '));
  }
  check('and the two source-coverage lists are identical',
    spreads.length === 2 && JSON.stringify([...spreads[0]].sort()) === JSON.stringify([...spreads[1]].sort()),
    spreads.map((s) => s.join(',')).join('  VS  '));

  // A SECOND AUTHORITY FOR source-coverage: THE SCHEMA. BOOK-INGEST-AUDIT F107.
  // CATALOGS is the wrong set for the question that file asks. It asks whether
  // every CITED row traces to a page, and `skill_system_bases` and
  // `psionic_system_costs` cite pages without being catalogs - 95 production
  // rows sat outside the report while every assertion above passed. So every
  // table with a `source_book` column in db/schema.sql, read through node:sqlite
  // rather than parsed as text, must be read by BOTH halves, as a spread entry or
  // as its own `FROM <table>` entry. The spreads alone cannot show this: the two
  // tables have no `name` column and sit outside them, so the identical-lists
  // check above would pass with one landed on one side only.
  //
  // Still a check, not a derived list - F100's decision. A table this report
  // should skip on purpose goes in SOURCE_EXCLUDED with its reason; there is
  // none today.
  const SOURCE_EXCLUDED = [];
  const schemaMem = new DatabaseSync(':memory:');
  schemaMem.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'));
  const cited = schemaMem.prepare("SELECT m.name FROM sqlite_master m WHERE m.type = 'table' "
    + "AND EXISTS (SELECT 1 FROM pragma_table_info(m.name) p WHERE p.name = 'source_book')")
    .all().map((r) => r.name);
  schemaMem.close();
  check('schema.sql names tables that carry a source_book', cited.length > 0);
  const halfOf = (start, end) => {
    const i = sc.indexOf(start);
    return i < 0 ? '' : sc.slice(i, sc.indexOf(end, i));
  };
  const halves = [halfOf('const groups = [', '\n];'), halfOf('const buildGroups = [', '\n      ];')];
  check('both source-coverage halves were found', halves.every((h) => h.length > 0));
  for (const [i, h] of halves.entries()) {
    const spread = quoted((h.match(/\.\.\.(\[[^\]]*\])\.map\(/) || [])[1] || '');
    const missing = cited.filter((t) => !SOURCE_EXCLUDED.includes(t)
      && !spread.includes(t) && !new RegExp(`FROM ${t}\\b`).test(h));
    check(`source-coverage half ${i + 1} of 2 reads every table that cites a page`, missing.length === 0,
      'missing, and not a named exclusion: ' + missing.join(', '));
  }

  // 3. repo-vs-live's TABLES. A SUPERSET: it also compares imported_classes,
  // skill_system_bases and catalog_redirects, which are not catalogs, so extras
  // are expected and only an absence is wrong.
  const rvl = readRepo('scripts/repo-vs-live.mjs');
  const tStart = rvl.indexOf('const TABLES = [');
  const tBlock = rvl.slice(tStart, rvl.indexOf('\n];', tStart));
  const rvlTables = [...tBlock.matchAll(/^\s*\['([a-z_]+)',/gm)].map((m) => m[1]);
  check('repo-vs-live TABLES was found', rvlTables.length > 0);
  const rvlMissing = tables.filter((t) => !rvlTables.includes(t));
  check('repo-vs-live compares every catalog', rvlMissing.length === 0,
    'missing: ' + rvlMissing.join(', '));

  // 4. drift-check's CITATION_TABLES. A deliberate SUBSET, and the exclusions are
  // named here so an OMISSION cannot hide among them. Each is the drift-check
  // file's own written decision, not this check's:
  //   gear, vehicles  - a catalog name is reworded prose, not the page heading
  //   enchantments, totems - named by their own row text, not a printed checklist
  //
  // FOUR, NOT THREE. F100 said `gear`, `vehicles` and `enchantments`; drift-check's
  // comment names `vehicles`, `enchantments` and `totems`, and gear's exclusion is
  // a separate comment further down. A check written from the finding's sentence
  // would have gone red on `totems` the first time it ran.
  const CITATION_EXCLUDED = ['gear', 'vehicles', 'enchantments', 'totems'];
  const dc = readRepo('scripts/drift-check.mjs');
  const citTables = quoted((dc.match(/const CITATION_TABLES = (\[[^\]]*\])/) || [])[1] || '');
  check('drift-check CITATION_TABLES was found', citTables.length > 0);
  const citMissing = tables.filter((t) => !citTables.includes(t) && !CITATION_EXCLUDED.includes(t));
  check('drift-check cites every catalog it does not deliberately exclude', citMissing.length === 0,
    'missing, and not a named exclusion: ' + citMissing.join(', '));
  // An exclusion that has since been ADDED is stale here, and a stale exclusion
  // is how a later omission would go unnoticed.
  const staleExclusion = CITATION_EXCLUDED.filter((t) => citTables.includes(t));
  check('and no named exclusion is actually cited', staleExclusion.length === 0,
    'listed as excluded but present: ' + staleExclusion.join(', '));
  check('and every named exclusion is a real catalog',
    CITATION_EXCLUDED.every((t) => tables.includes(t)), CITATION_EXCLUDED.join(', '));

  // 5. regression.mjs's redirect-check map - the FIFTH list, which F100 did not
  // know existed. Keyed by CATALOGS KEY, because catalog_redirects stores the
  // key; so this compares keys rather than tables, and an extra key is as wrong
  // as a missing one (that is how `super_abilities` sat there instead of
  // `superAbilities`, matching no redirect row).
  const rg = readFileSync(join(appDir, 'test', 'regression.mjs'), 'utf8');
  const cStart = rg.indexOf('const CATALOGS = {', rg.indexOf('catalog key -> [table, unique column]'));
  const cBody = rg.slice(cStart, rg.indexOf('\n  };', cStart));
  const rgKeys = [...cBody.matchAll(/^\s*([A-Za-z_]+):\s*\[/gm)].map((m) => m[1]);
  check('the regression redirect map was found', rgKeys.length > 0);
  const rgMissing = keys.filter((k) => !rgKeys.includes(k));
  const rgExtra = rgKeys.filter((k) => !keys.includes(k));
  check('the regression redirect map knows every CATALOGS key', rgMissing.length === 0,
    'missing: ' + rgMissing.join(', '));
  check('and names none that is not one', rgExtra.length === 0,
    'not a CATALOGS key (catalog_redirects stores the key, not the table): ' + rgExtra.join(', '));
}

// ---------- 1c. The row form takes its widths from the field type ----------
// .cat-form was a grid with no grid-template-columns - one column, one field
// per row, every field the full 1154px whatever it held. Gear measured 1201px
// tall, more than the viewport, with A.R. and Mega-damage each holding two
// characters across the whole width.
//
// The span now comes from the field's own `type`, which this config already
// declares and the write endpoints already validate against. That only stays
// true if every type in the config has a rule: a type with none silently gets
// the default span, which is the failure mode that does not look like one.
section('The row form takes its widths from the field type');
{
  const css = readFileSync(join(appDir, 'styles.css'), 'utf8');
  const cat = readFileSync(appPath('catalog.js'), 'utf8');

  check('the form is a grid of columns, not of one column',
    /\.cat-form \{[\s\S]*?grid-template-columns: repeat\(12, 1fr\);/.test(css),
    '.cat-form is back to a single implicit column');
  check('and its fields do not stretch to the tallest in the row',
    /\.cat-form \{[\s\S]*?align-items: start;/.test(css),
    'a short field stretches down beside a field carrying help text');

  // The form reads the type off the config rather than off a second list.
  check('the field carries its type into the markup',
    /<div class="cat-field" data-field="\$\{f\.name\}" data-type="\$\{f\.type\}"/.test(cat),
    'rowForm no longer emits data-type and every field falls to the default span');
  check('and says when it carries help',
    /\$\{f\.help \? ' data-help' : ''\}/.test(cat),
    'a narrow field with a long help string wraps to eight lines and makes the form taller');

  // EVERY type in the config, not a list written here. A new field type
  // arrives with a width or fails this.
  const types = [...new Set(Object.values(CATALOGS)
    .flatMap((c) => c.fields.map((f) => f.type)))].sort();
  const unsized = types.filter((t) =>
    !new RegExp(`\\.cat-field\\[data-type="${t}"\\]`).test(css));
  check(`every field type in the config has a span (${types.length} types)`,
    unsized.length === 0,
    `no rule for: ${unsized.join(', ')} — they take the default span silently`);

  // Source order is load-bearing: [data-help] and the narrow type rules are
  // the same specificity, so the help override only wins by coming after.
  check('the help override is stated after the type table',
    css.indexOf('.cat-field[data-help]') > css.indexOf('.cat-field[data-type="int"]'),
    'the narrow spans now win and a field with help wraps instead');
  // ...and the full-width types restate themselves a step up so it cannot
  // shrink them back to a third of a row.
  check('and cannot shrink a description to a third of a row',
    /\.cat-field\[data-type="longtext"\]\[data-help\]/.test(css),
    'longtext + help falls back to span 4');

  check('a phone gets the one column this form always had',
    /@media \(max-width: 700px\) \{[\s\S]*?\.cat-form \{ grid-template-columns: 1fr; \}/.test(css),
    'twelve columns survive to 390px');
}

// A blank NOT NULL column must coerce to its default, not NULL, or the insert
// dies on a constraint. This is the bug that made every "create" 500.
const notNullBlanks = [];
for (const [key, c] of Object.entries(CATALOGS)) {
  for (const f of c.fields.filter((x) => x.blankAs !== undefined)) {
    const { value } = coerceField(f, '');
    if (value !== f.blankAs) notNullBlanks.push(`${key}.${f.name} blank -> ${value}, expected ${f.blankAs}`);
  }
}
check('blank NOT NULL fields coerce to their default', notNullBlanks.length === 0, notNullBlanks.join('; '));

// Required fields must be rejected when empty rather than silently nulled.
const req = CATALOGS.skills.fields.find((f) => f.name === 'name');
check('required field rejects blank', !!coerceField(req, '').error);
// systems: nothing picked and everything picked both mean "applies to all".
//
// This pinned TWO systems until Nightbane made it three (BOOK-INGEST-AUDIT
// F73), and the change it forced is a real one rather than a renumbering:
// ['rifts', 'palladium-fantasy'] used to BE all of them and stored NULL, and
// now stores the pair, because it has become a restriction that excludes the
// others. Both halves are pinned below so neither can drift back.
//
// THIS PIN MOVES EVERY TIME A SYSTEM IS ADDED, and that is the point rather
// than a maintenance cost: `coerceField` stores NULL when the picked set is
// the WHOLE allowlist, so all-three stopped meaning "all" the moment Heroes
// Unlimited became the fourth. A pin that did not move would be asserting a
// meaning the code no longer has.
const sysField = CATALOGS.skills.fields.find((f) => f.name === 'systems');
check('systems: empty and all-FOUR-selected both store NULL',
  coerceField(sysField, []).value === null
  && coerceField(sysField, ['rifts', 'palladium-fantasy', 'nightbane',
    'heroes-unlimited']).value === null);
check('systems: all-THREE is now a RESTRICTION, because a fourth system exists',
  coerceField(sysField, ['rifts', 'palladium-fantasy', 'nightbane']).value
    === '["rifts","palladium-fantasy","nightbane"]');
check('systems: the two older systems are now a RESTRICTION, not "all"',
  coerceField(sysField, ['rifts', 'palladium-fantasy']).value === '["rifts","palladium-fantasy"]');
check('systems: one system stores a JSON array',
  coerceField(sysField, ['rifts']).value === '["rifts"]');
check('systems: nightbane is an accepted value and is not filtered out',
  coerceField(sysField, ['nightbane']).value === '["nightbane"]');
check('systems: heroes-unlimited is an accepted value and is not filtered out',
  coerceField(sysField, ['heroes-unlimited']).value === '["heroes-unlimited"]');
// The THREE-of-five split, pinned because it is the thing a later session will
// "tidy" into consistency. `spells.system`, `psionic_powers.system` and
// `enchantments.system` are bare TEXT and take a third value; `gear.system` and
// `vehicles.system` carry a SQLite CHECK naming two, so offering `nightbane`
// there would put a value in the editor that the database refuses.
// BOOK-INGEST-AUDIT F73.
for (const cat of ['spells', 'psionics', 'enchantments', 'superAbilities']) {
  const f = CATALOGS[cat].fields.find((x) => x.name === 'system');
  check(`${cat}: the system dropdown offers nightbane (no CHECK on that column)`,
    !!f && f.options.includes('nightbane'));
  check(`${cat}: and offers heroes-unlimited, for the same reason`,
    !!f && f.options.includes('heroes-unlimited'));
}

// `super_abilities` exists BECAUSE a Heroes Unlimited super ability has neither
// a cost nor a level - it is a permanent trait, and the stat block describes it
// in use rather than pricing it. A spell needs a level and a P.P.E.; a psionic
// power needs an I.S.P. Put either on this catalog and the reason for migration
// 057 is gone, so the absence is pinned rather than left to be tidied away.
{
  const sa = CATALOGS.superAbilities;
  check('superAbilities exists and points at super_abilities',
    !!sa && sa.table === 'super_abilities');
  const names = (sa ? sa.fields : []).map((f) => f.name);
  check('superAbilities has NO cost and NO level field',
    !names.some((n) => /^(isp|ppe|level|cost)$/.test(n)), names.join(','));
  check('and it does carry the stat block spells and psionics use',
    ['range', 'duration', 'damage', 'saving_throw', 'description']
      .every((n) => names.includes(n)));
  check('and `tier` allows an unrecognised stored value',
    !!(sa && sa.fields.find((f) => f.name === 'tier') || {}).allowOther);
}
// THE DROPDOWN AND THE COLUMN HAVE TO AGREE, and this is that invariant read
// off both rather than a list written down twice.
//
// It used to assert the opposite: while `gear.system` and `vehicles.system`
// carried a two-value CHECK, these checks pinned the dropdowns to NOT offer
// nightbane or heroes-unlimited, because offering one would have produced a row
// the database refuses. Migrations 059 and 060 widened both columns, so the pin
// inverts - same invariant, other direction. Written against the schema text
// now, so the next game to arrive moves one place rather than three.
{
  const schemaSrc = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  const checkValues = (table) => {
    // The CREATE for this table, then its `system` column's CHECK list.
    const create = new RegExp('CREATE TABLE IF NOT EXISTS ' + table + '[\\s\\S]*?\\n\\);')
      .exec(schemaSrc);
    if (!create) return null;
    const m = /system\s+TEXT\s+CHECK \(system IN \(([^)]*)\)\)/.exec(create[0]);
    return m ? m[1].split(',').map((s) => s.trim().replace(/^'|'$/g, '')).sort() : null;
  };
  for (const cat of ['gear', 'vehicles']) {
    const f = CATALOGS[cat].fields.find((x) => x.name === 'system');
    const col = checkValues(CATALOGS[cat].table);
    check(`${cat}: the schema's system CHECK was found`, !!col, String(col));
    check(`${cat}: the dropdown offers exactly what the column admits`,
      !!f && !!col && JSON.stringify([...f.options].sort()) === JSON.stringify(col),
      `${f && f.options} vs ${col}`);
    check(`${cat}: and that includes both new games`,
      !!col && col.includes('nightbane') && col.includes('heroes-unlimited'), String(col));
  }
}

// codex.js is a classic script and imports nothing, so it keeps its OWN copy of
// SYSTEM_LABEL. Two copies of three strings is the deliberate trade; this is
// what stops them drifting, and codex.js's comment promises this check exists.
{
  const keysOfLabelMap = (src) => {
    const m = src.match(/const SYSTEM_LABEL = \{([\s\S]*?)\};/);
    return m ? [...m[1].matchAll(/(?:'([a-z-]+)'|\b([a-z-]+))\s*:/g)]
      .map((x) => x[1] || x[2]).sort() : null;
  };
  const appKeys = keysOfLabelMap(readFileSync(join(appDir, 'app.js'), 'utf8'));
  const codexKeys = keysOfLabelMap(readFileSync(appPath('codex.js'), 'utf8'));
  check('both SYSTEM_LABEL maps were found', !!appKeys && !!codexKeys);
  check('app.js and codex.js name the same systems',
    JSON.stringify(appKeys) === JSON.stringify(codexKeys), `${appKeys} vs ${codexKeys}`);
  check('and nightbane is one of them', (appKeys || []).includes('nightbane'));
  check('and heroes-unlimited is too', (appKeys || []).includes('heroes-unlimited'));
}

// The wizard picker is deliberately NOT widened: S.system feeds the campaign
// POST, which allowlists the systems `campaigns.system` admits. A button here
// for a system that endpoint refuses would offer a game no campaign can be
// created in - and the reverse, an endpoint widened without the picker, is the
// half the old one-directional form could not see. Migrations 058-060 moved
// both from two values to four, and this check is what caught the picker.
{
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  // BOUNDED BY THE NEXT FUNCTION, not by a character count. This read
  // `+ 900` and that fitted two buttons; the fourth fell outside the window and
  // the check reported a system the picker does offer as missing. A fixed
  // length is the wrong bound for the one function this check expects to grow.
  const pickerStart = appSrc.indexOf('function renderSystem()');
  const pickerEnd = appSrc.indexOf('\nfunction ', pickerStart + 1);
  const picker = appSrc.slice(pickerStart, pickerEnd > 0 ? pickerEnd : undefined);
  // DERIVED from the endpoint rather than naming systems, so it cannot rot as
  // systems are added. It named `nightbane` when written and needed a second
  // clause one day later for `heroes-unlimited` - two systems, two edits to a
  // check whose whole job is to notice a third. Comparing the two lists needs
  // no edit at all, and it also catches the endpoint being widened without the
  // picker, which the old form could not see.
  const offered = [...picker.matchAll(/pickSystem\('([a-z-]+)'\)/g)].map((m) => m[1]).sort();
  const campaignsApi = readFileSync(join(appDir, '..', '..', 'functions', 'api',
    'character-creator', 'campaigns.js'), 'utf8');
  // The endpoint's allowlist is GAME_SYSTEMS in js/class-keys.js since
  // 2026-10-10, so the list is read from the module and the endpoint is held to
  // asking it, where this used to read a literal out of the endpoint's source.
  const gate = /!GAME_SYSTEMS\.includes\(body\.system\)/.test(campaignsApi);
  const allowed = gate ? [...(await import('../../js/class-keys.js')).GAME_SYSTEMS].sort() : [];
  check('the campaigns endpoint has a readable system allowlist', allowed.length > 0);
  check('renderSystem() offers exactly the systems a campaign can be created in',
    offered.length > 0 && JSON.stringify(offered) === JSON.stringify(allowed),
    `picker [${offered}] vs endpoint [${allowed}]`);
}

}
