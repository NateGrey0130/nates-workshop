// Smoke test: (1) the RCC/OCC markdown files parse correctly, (2) the D1 schema
// migrates cleanly into a local D1 instance, (3) every migration on disk is
// recorded as applied to that database.
// Run from anywhere:  node apps/character-creator/test/smoke.mjs

import { readFileSync, readdirSync, writeFileSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseClassMarkdown } from '../js/parser.js';
import { CATALOGS, coerceField } from '../js/catalog-fields.js';
import {
  getImportSpec, stripFences, normaliseRows, countRows, applyDecisions,
} from '../../../functions/api/character-creator/_lib/import-engine.js';
import { stageRows } from '../../../functions/api/character-creator/_lib/import-sessions.js';

const appDir = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoRoot = join(appDir, '..', '..');
let failures = 0;

function check(label, cond, detail) {
  if (cond) {
    console.log('  ok  ' + label);
  } else {
    failures++;
    console.error('  FAIL ' + label + (detail ? ' — ' + detail : ''));
  }
}

function parseFile(name) {
  return parseClassMarkdown(readFileSync(join(appDir, 'test', 'fixtures', name), 'utf8'));
}

// ---------- 1. Parser ----------
console.log('\n[1/3] Parser');

const ck = parseFile('cyber-knight.md');
check('cyber-knight parses', ck.ok, JSON.stringify(ck.errors));
check('cyber-knight core fields', ck.data.id === 'cyber-knight' && ck.data.system === 'rifts' && ck.data.category === 'occ');
check('attribute_requirements map', ck.data.attribute_requirements?.ME === 12 && ck.data.attribute_requirements?.MA === 12);
check('occ_skills inline objects', ck.data.skills?.occ_skills?.length === 7 && ck.data.skills.occ_skills[0].name === 'Radio: Basic' && ck.data.skills.occ_skills[0].base === 40);
check('occ_related_skills count/categories', ck.data.skills?.occ_related_skills?.count === 6 && ck.data.skills.occ_related_skills.categories.includes('Espionage'));
check('equipment_starting', ck.data.equipment_starting?.length === 3 && ck.data.equipment_starting[0].item_id === 'ns-turbo-cyclone');
check('psionics block', ck.data.psionics?.type === 'major' && ck.data.psionics?.isp_base === '1d4x10+20');
check('special_abilities block-form list', ck.data.special_abilities?.length === 2 && ck.data.special_abilities[0].name === 'Psi-Sword');
check('level_progression', ck.data.level_progression?.length === 3 && ck.data.level_progression[2].grants.length === 2);
check('lore + gm_notes sections', !!ck.data.lore?.includes('Cyber-Knights') && !!ck.data.gm_notes?.includes('Code of Chivalry'));

const lb = parseFile('long-bowman.md');
check('long-bowman parses', lb.ok, JSON.stringify(lb.errors));
check('palladium-fantasy system', lb.data.system === 'palladium-fantasy' && lb.data.category === 'occ');
check('secondary_skills count', lb.data.skills?.secondary_skills?.count === 4);

const dh = parseFile('dragon-hatchling.md');
check('dragon-hatchling parses', dh.ok, JSON.stringify(dh.errors));
check('rcc category', dh.data.category === 'rcc');
check('attribute_dice map', dh.data.attribute_dice?.PS === '4d6+12');
check('mdc_base + magic block', dh.data.mdc_base === '1d4x100' && dh.data.magic?.spell_levels_allowed?.length === 2);
check('natural_abilities', dh.data.natural_abilities?.length === 4);
check('restrictions scalar list', dh.data.restrictions?.length === 2);

// Invalid input must be rejected, not silently accepted.
const bad = parseClassMarkdown('---\nname: Nameless\nsystem: gurps\ncategory: occ\n---\nbody');
check('invalid file rejected', !bad.ok && bad.errors.some((e) => e.includes('id')) && bad.errors.some((e) => e.includes('system')));
const noFm = parseClassMarkdown('# just markdown, no frontmatter');
check('missing frontmatter rejected', !noFm.ok);

// ---------- 1b. Catalog field config ----------
// The editor, the write endpoints and the importers all generate themselves
// from this, so an inconsistent entry breaks three things at once.
console.log('\n[1b] Catalog field config');
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
  }
}
check('catalog configs are internally consistent', catalogProblems.length === 0, catalogProblems.join('; '));

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
// systems: neither system picked and both picked both mean "applies to both".
const sysField = CATALOGS.skills.fields.find((f) => f.name === 'systems');
check('systems: empty and all-selected both store NULL',
  coerceField(sysField, []).value === null && coerceField(sysField, ['rifts', 'palladium-fantasy']).value === null);
check('systems: one system stores a JSON array',
  coerceField(sysField, ['rifts']).value === '["rifts"]');

// ---------- 1c. Import engine ----------
// Pins the skill importer's behaviour so the shared engine cannot quietly
// change it. Every expectation here matches what the pre-refactor inline
// implementation produced.
console.log('\n[1c] Import engine');
const skillSpec = getImportSpec('skills');
check('skills import spec exists', !!skillSpec);

check('stripFences unwraps a json fence',
  stripFences('```json\n[{"name":"A"}]\n```') === '[{"name":"A"}]');
check('stripFences unwraps a bare fence',
  stripFences('```\n[1]\n```') === '[1]');
check('stripFences leaves unfenced text alone',
  stripFences('  [{"name":"A"}]  ') === '[{"name":"A"}]');

const normalised = normaliseRows(skillSpec, [
  { name: 'Climbing:', category: 'Physical', base: '40', per_level: '5', note: ' rope work ' },
  { name: '  Prowl  ', category: ' Espionage ', base: 35, per_level: 5 },
  { name: '', category: 'Physical' },                    // no name — dropped
  { name: 'x'.repeat(121) },                             // absurd name — dropped
  { name: 'Boxing', base: -10, per_level: 'abc' },       // bad numbers clamp to 0
  'not an object',
]);
check('normalise strips a trailing colon from the name', normalised[0]?.name === 'Climbing');
check('normalise trims names and categories',
  normalised[1]?.name === 'Prowl' && normalised[1]?.category === 'Espionage');
check('normalise coerces numeric strings', normalised[0]?.base === 40 && normalised[0]?.per_level === 5);
check('normalise trims a note', normalised[0]?.note === 'rope work');
check('normalise nulls an absent note', normalised[1]?.note === null);
check('normalise clamps negative and non-numeric to 0',
  normalised[2]?.base === 0 && normalised[2]?.per_level === 0);
check('normalise drops nameless, over-long and non-object rows', normalised.length === 3,
  'got ' + normalised.length + ': ' + normalised.map((r) => r.name).join(', '));

// Classification defaults, which decide what review pre-selects. A curated row
// must never default to being overwritten by a second book.
const stubRow = { source: 'import', base: 0, per_level: 0 };
const seedRow = { source: 'seed', base: 30, per_level: 5 };
const manualRow = { source: 'manual', base: 0, per_level: 0 };
check('a zeroed imported row is a stub', skillSpec.isStub(stubRow) === true);
check('a seeded row is not a stub', skillSpec.isStub(seedRow) === false);
check('a hand-edited row is never a stub', skillSpec.isStub(manualRow) === false);

// Spells: same engine, different spec. The stat block is text on purpose —
// books write "100 feet per level of experience" as often as a number.
const spellSpec = getImportSpec('spells');
check('spells import spec exists', !!spellSpec);
const spellRows = normaliseRows(spellSpec, [
  { name: 'Fire Bolt:', level: '4', ppe: '7', range: '100 feet per level',
    duration: 'Instant', damage: '5D6', description: '  A bolt of flame.  ' },
  { name: 'Sparse Spell' },
]);
check('spell numbers coerce, prose stays prose',
  spellRows[0]?.level === 4 && spellRows[0]?.ppe === 7 && spellRows[0]?.range === '100 feet per level');
check('spell name loses its trailing colon and description is trimmed',
  spellRows[0]?.name === 'Fire Bolt' && spellRows[0]?.description === 'A bolt of flame.');
check('an unstated spell field is null, not invented',
  spellRows[1]?.range === null && spellRows[1]?.damage === null && spellRows[1]?.ppe === 0);
check('a zeroed imported spell is a stub',
  spellSpec.isStub({ source: 'import', ppe: 0 }) === true
  && spellSpec.isStub({ source: 'seed', ppe: 10 }) === false
  && spellSpec.isStub({ source: 'manual', ppe: 0 }) === false);

// Psionics: same engine again. The interesting part is `flag`, which is
// advisory — an unknown category must be surfaced, never rejected, or a
// supplement that adds one becomes unimportable.
const psiSpec = getImportSpec('psionics');
check('psionics import spec exists', !!psiSpec);
check('a known category and tier raise no flag',
  psiSpec.flag({ category: 'Super', min_tier: 'master' }).length === 0);
check('category matching ignores case', psiSpec.flag({ category: 'healing' }).length === 0);
check('an unknown category is flagged, not rejected',
  psiSpec.flag({ category: 'Temporal' }).some((f) => f.includes('Temporal')));
check('an unknown psychic tier is flagged',
  psiSpec.flag({ min_tier: 'grandmaster' }).some((f) => f.includes('grandmaster')));
check('an absent category or tier raises nothing', psiSpec.flag({}).length === 0);
check('min_tier is left absent rather than inferred', (() => {
  const [r] = normaliseRows(psiSpec, [{ name: 'Mind Block', category: 'Sensitive', isp: 4 }]);
  return r.min_tier === null;
})());
check('a zeroed imported power is a stub',
  psiSpec.isStub({ source: 'import', isp: 0 }) === true
  && psiSpec.isStub({ source: 'seed', isp: 4 }) === false);

// applyDecisions against a fake DB. An UPDATE that matches nothing succeeds
// silently in SQL, so the engine has to check first — otherwise a row is
// reported as updated, and marked confirmed, while its values are discarded.
const fakeDb = (existingNames) => {
  const batched = [];
  return {
    batched,
    // Every prepare(...).bind(...) returns the same shape: .all() answers the
    // existence lookup, .run() is never reached because writes go through batch.
    prepare: () => ({
      bind: (...args) => ({
        all: async () => ({
          results: args
            .filter((a) => existingNames.some((n) => n.toLowerCase() === String(a).toLowerCase()))
            .map((a) => ({ name: a })),
        }),
        run: async () => ({ meta: { changes: 1 } }),
      }),
    }),
    batch: async (statements) => { batched.push(statements.length); },
  };
};

const upd = await (async () => {
  const db = fakeDb(['Climbing']);
  return applyDecisions({ DB: db }, skillSpec,
    [{ action: 'update', name: 'Nope Not Here', base: 99 }], { sourceBook: null });
})();
check('an update that matches nothing is a conflict, not a success',
  upd.counts.updated === 0 && upd.conflicts.length === 1
  && /to update/i.test(upd.conflicts[0].reason),
  JSON.stringify(upd));

const updOk = await (async () => {
  const db = fakeDb(['Climbing']);
  return applyDecisions({ DB: db }, skillSpec,
    [{ action: 'update', name: 'Climbing', base: 44 }], { sourceBook: null });
})();
check('an update that matches a real row still applies',
  updOk.counts.updated === 1 && updOk.conflicts.length === 0, JSON.stringify(updOk));

const insDup = await (async () => {
  const db = fakeDb(['Climbing']);
  return applyDecisions({ DB: db }, skillSpec,
    [{ action: 'insert', name: 'Climbing' }], { sourceBook: null });
})();
check('an insert onto an existing name is still a conflict',
  insDup.counts.inserted === 0 && insDup.conflicts.length === 1, JSON.stringify(insDup));

// Staging is one batch, so it is all-or-nothing. The cap keeps that batch a
// sane size and refuses a range too wide to have been read reliably.
const overCap = await stageRows(null, 1, 'pp. 1', new Array(301).fill({ name: 'x' }), 'spells');
check('a range over the row cap is refused before touching the database',
  !!overCap.error && /narrow the page range/i.test(overCap.error), JSON.stringify(overCap));

check('countRows tallies new, duplicates and stubs', (() => {
  const c = countRows([
    { status: 'new' }, { status: 'new' },
    { status: 'duplicate', is_stub: true }, { status: 'duplicate', is_stub: false },
  ]);
  return c.total === 4 && c.new === 2 && c.duplicates === 2 && c.stubs === 1;
})());

// ---------- 2. D1 schema ----------
// Runs against the shared workshop database (binding DB in the root
// wrangler.jsonc), so this executes from the repo root, not the app dir.
console.log('\n[2/3] D1 schema (local, shared DB)');

function wrangler(args) {
  return spawnSync('npx', ['wrangler', ...args], { cwd: repoRoot, shell: true, encoding: 'utf8', timeout: 120000 });
}

const apply = wrangler(['d1', 'execute', 'DB', '--local', '--file', 'db/schema.sql']);
check('schema applies cleanly', apply.status === 0, (apply.stderr || apply.stdout || '').slice(-500));

// SQL goes through a temp file — a quoted --command string doesn't survive the Windows shell.
const checkSql = join(appDir, 'test', '.smoke-check.sql');
writeFileSync(checkSql,
  "SELECT (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('campaigns','characters','journal_entries','level_history','gear','character_items')) AS cc_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'media_items') AS media_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('imported_classes','skills','spells','psionic_powers')) AS catalog_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='items') AS stale_items_table, (SELECT sql FROM sqlite_master WHERE name='character_items') AS ci_ddl;\n");
const query = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', checkSql]);
rmSync(checkSql, { force: true });
let row = null;
try { row = JSON.parse(query.stdout)[0].results[0]; } catch { /* fall through to checks */ }
check('all 6 character-creator tables exist', row?.cc_tables === 6, query.stdout?.slice(-300));
check('media_items still intact alongside them', row?.media_tables === 1);
check('class + catalog tables exist', row?.catalog_tables === 4, query.stdout?.slice(-300));

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

// ---------- 3. Migration state ----------
// Every file in db/migrations/ should have a schema_migrations row. A missing
// one means this database never had that migration applied — the question that
// used to be answered by guessing at pragma_table_info output.
console.log('\n[3/3] Migration state');

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

console.log(failures === 0 ? '\nSMOKE TEST PASSED' : `\nSMOKE TEST FAILED (${failures} failure(s))`);
process.exit(failures === 0 ? 0 : 1);
