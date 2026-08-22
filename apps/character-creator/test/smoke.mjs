// Smoke test: (1) the RCC/OCC markdown files parse correctly, (2) the D1 schema
// migrates cleanly into a local D1 instance, (3) db/schema.sql alone is enough
// to build a current database, and (4) every migration on disk is recorded as
// applied to that database.
//
// (3) and (4) look alike and are not: (4) asks what the local database has had
// done to it, (3) asks what a brand-new environment would get. Only (3) sees a
// migration whose column never made it back into schema.sql.
// Run from anywhere:  node apps/character-creator/test/smoke.mjs

function parseFile(name) {
  return parseClassMarkdown(readFileSync(join(appDir, 'test', 'fixtures', name), 'utf8'));
}

// ---------- 1. Parser ----------
section('Parser');

// Custom languages: three consumers (wizard, sheet, server validator) share
// these, so the rule is asserted here once rather than trusted three times.
check('languageSkillName composes', languageSkillName('Spanish') === 'Language: Spanish');
check('languageSkillName tolerates typed prefix', languageSkillName('language:  Orc') === 'Language: Orc');
check('languageSkillName rejects blank', languageSkillName('   ') === null && languageSkillName('Language:') === null);
check('isLanguageName family', isLanguageName('Language: Elvish') && isLanguageName(LANGUAGE_OTHER) && !isLanguageName('Sign Language'));

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

// Quoted scalars. The two YAML styles escape differently, and stripping the
// outer pair without unescaping left backslashes in the value — reachable from
// book text, which quotes things often enough to matter.
check('a double-quoted string is unescaped', (() => {
  const y = parseYaml('a: "Adult: the \\"big\\" one"\nb: "back\\\\slash"');
  return y.a === 'Adult: the "big" one' && y.b === 'back\\slash';
})());
check('a single-quoted string doubles its quote instead',
  parseYaml("a: 'it''s here'").a === "it's here");
check('an unquoted string is untouched', parseYaml('a: plain value').a === 'plain value');
check('a lone quote character is not treated as quoting', parseYaml('a: "').a === '"');

// Invalid input must be rejected, not silently accepted.
const bad = parseClassMarkdown('---\nname: Nameless\nsystem: gurps\ncategory: occ\n---\nbody');
check('invalid file rejected', !bad.ok && bad.errors.some((e) => e.includes('id')) && bad.errors.some((e) => e.includes('system')));
const noFm = parseClassMarkdown('# just markdown, no frontmatter');
check('missing frontmatter rejected', !noFm.ok);

// ---------- 1a. Every browser script parses ----------
// Cheap, and it would have caught a real one: a prompt string written with real
// newlines inside single quotes shipped a SyntaxError in import.js, which meant
// the whole page — not just that prompt — did nothing. Nothing else here loads
// the page scripts, because they are classic scripts full of DOM calls, so a
// syntax error in one was invisible to the entire suite.
section('Browser scripts parse');
{
  const scripts = [
    ...readdirSync(appDir).filter((f) => f.endsWith('.js')).map((f) => join(appDir, f)),
    ...readdirSync(join(appDir, 'js')).filter((f) => f.endsWith('.js')).map((f) => join(appDir, 'js', f)),
  ];
  check('found the page scripts', scripts.length >= 6, `only ${scripts.length}`);
  for (const path of scripts) {
    const res = spawnSync(process.execPath, ['--check', path], { encoding: 'utf8' });
    const name = path.slice(appDir.length + 1).replace(/\\/g, '/');
    check(`${name} parses`, res.status === 0,
      (res.stderr || '').split('\n').slice(0, 3).join(' ').trim());
  }
}

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
section('Import engine');
const skillSpec = getImportSpec('skills');

import { classesMentioning, findDuplicates, normaliseName, similarity } from '../../../functions/api/character-creator/_lib/catalog-merge.js';
import { collapseStatement, keysOf, redirectStatements, resolveKeys } from '../../../functions/api/character-creator/_lib/catalog-redirects.js';
import { referencedGear, restrictionNames } from '../../../functions/api/character-creator/_lib/catalog.js';
import { CHARACTER_JSON_COLUMNS } from '../../../functions/api/character-creator/_lib/character-json.js';
import { applyDecisions, classifyRows, countRows, getImportSpec, normaliseRows, slugify, stripFences, systemColumnFor } from '../../../functions/api/character-creator/_lib/import-engine.js';
import { stageRows } from '../../../functions/api/character-creator/_lib/import-sessions.js';
import { buildProposal, perLevelDiceOf, skillGrantsFor, spellGrantsFor, psionicGrantsFor,
         xpTableFor, thresholdFor, spellLevelsForGrant,
         psionicCategoriesForGrant, spellNamesForGrant,
         grantNote } from '../../../functions/api/character-creator/_lib/leveling.js';
import { toMatchQuery } from '../../../functions/api/character-creator/campaigns/[id]/search.js';
import { powerGrantsFor, remainingPowerGrants } from '../../../functions/api/character-creator/_lib/power-picks.js';
import { aliasCounts, buildIndex, diffCatalog, loose, match, nearest, normalise,
         stem, variants, vocabularyWarnings } from '../../../scripts/catalog-match-lib.mjs';
import { parseMentions } from '../../../functions/api/character-creator/_lib/mentions.js';
import { paging } from '../../../functions/api/character-creator/_lib/paging.js';
import { dedupeCategories } from '../../../functions/api/character-creator/_lib/skill-picks.js';
import { relatedAllowance, validateCharacter } from '../../../functions/api/character-creator/_lib/validate-character.js';
import { crossCategoryRestrictions, extractClassMarkdown, unmodelledKeys } from '../../../scripts/class-check-lib.mjs';
import { collapseWhitespace, statements, stripComments, trailingSelects } from '../../../scripts/sql-statements.mjs';
import { CATALOGS, coerceField } from '../js/catalog-fields.js';
import { composeClass } from '../js/compose.js';
import { evalDice, rollAttribute, rollPoolFormula, rollQuantity } from '../js/dice.js';
import { validateMos } from '../js/parser.js';
import { chunks, D1_MAX_BINDS, BIND_CHUNK } from '../../../functions/api/character-creator/_lib/sql-chunk.js';
import { LANGUAGE_OTHER, isLanguageName, languageSkillName } from '../js/language-skills.js';
import { ABILITY_GRANTS, POOL_BONUS_KEYS, VARIANT_OVERRIDES, abilityOccOptions, abilityOptions, applyAbilities, applyVariant, bonusesFromSkills, categoryAllows, categoryLabel, combineClasses, isGearChoice, needsOccupation, parseClassMarkdown, parseYaml, validateBonuses } from '../js/parser.js';
import { PSIONIC_TIER_RULES, psionicShape, psionicTierForRoll, rollPsionics, rollsForPsionics, withRolledPsionics } from '../js/psionics.js';
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { appDir, repoRoot, check, section, summary } from './harness.mjs';
import { run as environmentChecks } from './checks/environment.mjs';
import { run as catalogDataChecks } from './checks/catalog-data.mjs';

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

// A NOT NULL 0/1 column must never be handed a null. Getting this wrong made
// every gear insert fail the batch on gear.is_mega_damage.
const gearIns = await (async () => {
  const db = fakeDb([]);
  const res = await applyDecisions({ DB: db }, getImportSpec('gear'),
    [{ action: 'insert', slug: 'zz-probe', name: 'Zz Probe' }], { sourceBook: null });
  return { res, batched: db.batched };
})();
check('a gear insert with no mega-damage stated still builds a statement',
  gearIns.res.counts.inserted === 1 && gearIns.batched[0] === 1, JSON.stringify(gearIns.res));

const insDup = await (async () => {
  const db = fakeDb(['Climbing']);
  return applyDecisions({ DB: db }, skillSpec,
    [{ action: 'insert', name: 'Climbing' }], { sourceBook: null });
})();
check('an insert onto an existing name is still a conflict',
  insDup.counts.inserted === 0 && insDup.conflicts.length === 1, JSON.stringify(insDup));

// Gear: the only catalog that matches on two fields. Its stubs are keyed on a
// slug taken from class markdown, and a missed match means a second row while
// characters keep pointing at the empty one — the worst outcome available here.
const gearSpec = getImportSpec('gear');
check('gear import spec exists', !!gearSpec);
check('gear matches slug first, then name',
  gearSpec.matchFields[0] === 'slug' && gearSpec.matchFields[1] === 'name');
check('slugify mirrors the class importer\'s stub slugs',
  slugify('Air Filter and Gas Mask') === 'air-filter-and-gas-mask'
  && slugify('JA-11 Energy Rifle') === 'ja-11-energy-rifle'
  && slugify('  Spaced  Out  ') === 'spaced-out');
check('gear derives a slug when the book does not print one', (() => {
  const [r] = normaliseRows(gearSpec, [{ name: 'NG-57 Heavy Duty Ion Blaster' }]);
  return r.slug === 'ng-57-heavy-duty-ion-blaster';
})());
check('a book-supplied slug is respected over the derived one', (() => {
  const [r] = normaliseRows(gearSpec, [{ name: 'Odd Name', slug: 'canonical-slug' }]);
  return r.slug === 'canonical-slug';
})());
// A nullable number the book does not state must stay null. "No A.R." and
// "A.R. 0" are different claims, and the sheet renders the second one.
// `real` columns must not be parsed with parseInt. gear.weight_lbs is the only
// one, and a two-ounce item imported as 0 lb — weightless rather than light.
check('a real field keeps its fraction', (() => {
  const [g] = normaliseRows(gearSpec, [{ name: 'Zz Wand', weight_lbs: 0.125 }]);
  return g.weight_lbs === 0.125;
})());
check('an int field still truncates to a whole number', (() => {
  const [g] = normaliseRows(gearSpec, [{ name: 'Zz Gun', cost: '8000', ar: '14' }]);
  return g.cost === 8000 && g.ar === 14;
})());

check('an unstated nullable number stays null, a NOT NULL one falls back', (() => {
  const [g] = normaliseRows(gearSpec, [{ name: 'Back Pack' }]);
  const [s] = normaliseRows(skillSpec, [{ name: 'Boxing' }]);
  return g.ar === null && g.mdc === null && g.cost === null && g.weight_lbs === null
      && s.base === 0 && s.per_level === 0;
})());
check('gear reads mega-damage as a boolean', (() => {
  const rows = normaliseRows(gearSpec, [
    { name: 'A', is_mega_damage: true }, { name: 'B', is_mega_damage: false }, { name: 'C' },
  ]);
  return rows[0].is_mega_damage === 1 && rows[1].is_mega_damage === 0 && rows[2].is_mega_damage === 0;
})());
check('a gear stub is the class importer\'s marker, not an empty row',
  gearSpec.isStub({ description: 'STUB — created by class import, needs stats' }) === true
  && gearSpec.isStub({ description: 'A perfectly ordinary free item' }) === false
  && gearSpec.isStub({ description: null }) === false);

// classifyRows against a fake catalog holding one stub, keyed on slug.
const gearDb = (rows) => ({
  prepare: (sql) => ({
    bind: (...args) => ({
      all: async () => {
        const field = /WHERE (\w+) COLLATE/.exec(sql)?.[1];
        return { results: rows.filter((r) => args.some((a) =>
          String(a).toLowerCase() === String(r[field] ?? '').toLowerCase())) };
      },
    }),
  }),
});
const stubRowInDb = { id: 7, slug: 'air-filter-and-gas-mask', name: 'Air Filter And Gas Mask',
                      description: 'STUB — created by class import, needs stats', cost: null };

const bySlug = await classifyRows({ DB: gearDb([stubRowInDb]) }, gearSpec,
  normaliseRows(gearSpec, [{ name: 'Air Filter and Gas Mask', cost: 500 }]));
check('an extracted item matches its stub on slug and defaults to update',
  bySlug[0].status === 'duplicate' && bySlug[0].is_stub === true
  && bySlug[0].suggested === 'update' && bySlug[0].existing.id === 7, JSON.stringify(bySlug[0]));

// A stub whose slug came from class markdown in a form the book's wording does
// not reproduce — this is the case the name fallback exists for.
const oddStub = { id: 9, slug: 'ns-turbo-cyclone', name: 'NG Turbo Cyclone',
                  description: 'STUB — created by class import, needs stats', cost: null };
const byName = await classifyRows({ DB: gearDb([oddStub]) }, gearSpec,
  normaliseRows(gearSpec, [{ name: 'NG Turbo Cyclone', cost: 1 }]));
check('a stub whose slug differs is still found by name',
  byName[0].status === 'duplicate' && byName[0].existing.id === 9, JSON.stringify(byName[0]));
check('a fallback match is flagged rather than silently accepted',
  byName[0].flags.some((f) => /matched .* on name/i.test(f)), JSON.stringify(byName[0].flags));

const noMatch = await classifyRows({ DB: gearDb([stubRowInDb]) }, gearSpec,
  normaliseRows(gearSpec, [{ name: 'Something Entirely New' }]));
check('an unrelated item is new, not a false match', noMatch[0].status === 'new');

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

// ---------- 1c2. Level-up skill grants ----------
// occ_related_skills.schedule recorded these for a long time and nothing read
// them. The itemisation matters: a grant knows which level earned it.
section('Level-up skill grants');
const juicerish = {
  skills: {
    occ_related_skills: {
      count: 7,
      categories: ['Physical', 'Rogue'],
      schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }],
    },
  },
};
check('a jump collects every threshold it crosses', (() => {
  const g = skillGrantsFor(juicerish, 2, 7);
  return g.length === 2 && g[0].level === 3 && g[0].count === 2 && g[1].level === 6 && g[1].count === 1;
})());
check('thresholds at or below the starting level are not re-granted',
  skillGrantsFor(juicerish, 6, 7).length === 0);
check('the level reached is included, the level left is not', (() => {
  const g = skillGrantsFor(juicerish, 3, 6);
  return g.length === 1 && g[0].level === 6;
})());
check('grants carry the class categories', (() => {
  const [g] = skillGrantsFor(juicerish, 1, 3);
  return Array.isArray(g.categories) && g.categories.includes('Rogue');
})());
check('a class with no schedule grants nothing',
  skillGrantsFor({ skills: { occ_related_skills: { count: 4 } } }, 1, 12).length === 0
  && skillGrantsFor({}, 1, 12).length === 0);
check('a malformed schedule entry does not break the run', (() => {
  const g = skillGrantsFor({ skills: { occ_related_skills: {
    schedule: [{ level: 'x', count: 2 }, { level: 4 }, { level: 5, count: -3 }] } } }, 1, 9);
  // level 4 defaults to 1 pick; level 5's negative count is floored to 1
  return g.length === 2 && g[0].count === 1 && g[1].count === 1;
})());

// ---------- 1c3. Character validation ----------
// The rules the wizard enforces, re-checked server-side. Narrow on purpose:
// what a player CHOOSES, not the class's fixed skill list.
section('Character validation');
const vCls = {
  attribute_requirements: { ME: 12, MA: 'none' },
  skills: {
    occ_skills: [
      { name: 'Radio: Basic', base: 40 },
      { choose: 2, from: ['Pilot: Hovercycle', 'Pilot: Truck'] },
    ],
    occ_related_skills: { count: 2, categories: ['Physical', 'Rogue'],
                          schedule: [{ level: 3, count: 1 }] },
    secondary_skills: { count: 1 },
  },
};
const rel = (name, category, extra = {}) => ({ name, category, type: 'related', ...extra });
const legal = {
  character: { level: 1 }, cls: vCls,
  attributes: { ME: 14 },
  skills: [
    { name: 'Radio: Basic', category: 'Communications', type: 'occ' },
    { name: 'Pilot: Hovercycle', category: 'Pilot', type: 'occ' },
    { name: 'Pilot: Truck', category: 'Pilot', type: 'occ' },
    rel('Climbing', 'Physical'), rel('Prowl', 'Rogue'),
    { name: 'Basic Math', category: 'Science', type: 'secondary' },
  ],
};
const vio = (o) => validateCharacter({ ...legal, ...o }).violations.map((v) => v.rule);

check('a legal character produces no violations', vio({}).length === 0, JSON.stringify(vio({})));
check('no class definition skips validation entirely', (() => {
  const r = validateCharacter({ ...legal, cls: null });
  return r.skipped === true && r.violations.length === 0;
})());
check('an attribute below the minimum is a violation',
  vio({ attributes: { ME: 9 } }).includes('attribute_minimum'));
check('a requirement of "none" imposes nothing',
  !vio({ attributes: { ME: 14 } }).includes('attribute_minimum'));
check('a missing required attribute is caught',
  vio({ attributes: {} }).includes('attribute_missing'));
check('too many related skills is a violation',
  vio({ skills: legal.skills.concat([rel('Swimming', 'Physical')]) }).includes('related_count'));
check('the related allowance grows with scheduled grants', (() => {
  const withExtra = { skills: legal.skills.concat([rel('Swimming', 'Physical')]) };
  // Illegal at level 1, legal at level 3 once the schedule has granted one.
  return vio({ ...withExtra }).includes('related_count')
      && !vio({ ...withExtra, character: { level: 3 } }).includes('related_count');
})());
check('a related skill outside the allowed categories is a violation',
  vio({ skills: legal.skills.map((s) => s.name === 'Prowl' ? rel('Prowl', 'Science') : s) })
    .includes('related_category'));
check('an explicit override makes an out-of-category pick legal',
  !vio({ skills: legal.skills.map((s) => s.name === 'Prowl' ? rel('Prowl', 'Science', { override: true }) : s) })
    .includes('related_category'));
check('secondary skills are not category-restricted',
  !vio({}).includes('related_category'));
check('too many secondary skills is a violation',
  vio({ skills: legal.skills.concat([{ name: 'Astronomy', category: 'Science', type: 'secondary' }]) })
    .includes('secondary_count'));
// Choice groups warn but never block: a character does not record which group
// a skill was taken for, so counting by category is an approximation and must
// not be able to refuse a save.
check('an unsatisfied choice group warns rather than blocking', (() => {
  const r = validateCharacter({ ...legal, skills: legal.skills.filter((s) => s.name !== 'Pilot: Truck') });
  return r.warnings.some((w) => w.rule === 'choice_group')
      && !r.violations.some((v) => v.rule === 'choice_group');
})());

// Stored categories are unreliable — the wizard writes "Class" on every O.C.C.
// skill — so a supplied catalog wins over the stored value.
check('the catalog overrides a stored category', (() => {
  const catalog = new Map([['prowl', 'Science']]);
  const skills = legal.skills.map((s) => s.name === 'Prowl' ? { ...s, category: 'Rogue' } : s);
  const r = validateCharacter({ ...legal, skills, catalog });
  return r.violations.some((v) => v.rule === 'related_category' && v.skill === 'Prowl');
})());
check('a skill absent from the catalog falls back to its stored category', (() => {
  const r = validateCharacter({ ...legal, catalog: new Map() });
  return r.violations.length === 0;
})());
check('a duplicated skill is always a violation',
  vio({ skills: legal.skills.concat([rel('Climbing', 'Physical')]) }).includes('duplicate_skill'));
check('the class fixed skill list is not checked', (() => {
  // Radio: Basic removed — a class change, not the player's doing.
  const without = legal.skills.filter((s) => s.name !== 'Radio: Basic');
  return !vio({ skills: without }).some((r) => r.startsWith('occ_'));
})());
check('relatedAllowance adds base and grants',
  relatedAllowance(vCls, 1) === 2 && relatedAllowance(vCls, 3) === 3 && relatedAllowance(vCls, 9) === 3);

// Every violation must carry a readable `message`. The wizard prints these
// straight to the player, and a violation without one used to surface as
// "This character breaks its class rules" and nothing else — true, and useless
// for working out what to change.
{
  const cases = [
    // attribute_missing and attribute_minimum
    { character: { level: 1 }, cls: vCls, skills: [], attributes: {}, catalog: null },
    { character: { level: 1 }, cls: vCls, skills: [], attributes: { ME: 3 }, catalog: null },
    // related_count and secondary_count
    { character: { level: 1 }, cls: vCls, attributes: { ME: 12 }, catalog: null,
      skills: Array.from({ length: 9 }, (_, i) => ({ name: 'S' + i, type: 'related', category: 'Physical' })) },
    { character: { level: 1 }, cls: vCls, attributes: { ME: 12 }, catalog: null,
      skills: Array.from({ length: 9 }, (_, i) => ({ name: 'T' + i, type: 'secondary' })) },
    // duplicate_skill
    { character: { level: 1 }, cls: vCls, attributes: { ME: 12 }, catalog: null,
      skills: [{ name: 'Climbing', type: 'related', category: 'Physical' },
               { name: 'Climbing', type: 'related', category: 'Physical' }] },
  ];
  const seen = new Set();
  const unreadable = [];
  for (const c of cases) {
    for (const v of validateCharacter(c).violations) {
      seen.add(v.rule);
      if (typeof v.message !== 'string' || !v.message.trim()) unreadable.push(v.rule);
    }
  }
  check('the cases between them produce several distinct rules', seen.size >= 4,
    'only saw: ' + [...seen].join(', '));
  check('every violation carries a readable message', unreadable.length === 0,
    'missing on: ' + unreadable.join(', '));
  // The message has to name the thing, or it cannot be acted on.
  const attrCase = validateCharacter(cases[1]).violations.find((v) => v.rule === 'attribute_minimum');
  check('an attribute violation names the attribute and the minimum',
    !!attrCase && /ME/.test(attrCase.message) && /12/.test(attrCase.message), attrCase?.message);
}

// ---------- 1c4. Psychic tiers ----------
// derive.js is a classic script, so it is loaded by evaluating it against a
// stand-in global rather than imported.
section('Psychic tiers');
const deriveGlobal = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8'))
  .call(deriveGlobal, deriveGlobal);
const D = deriveGlobal.derive;
check('derive exposes the tier helpers', !!D?.meetsTier && Array.isArray(D?.tiers));

check('a higher tier meets a lower requirement',
  D.meetsTier('master', 'major') && D.meetsTier('master', 'minor') && D.meetsTier('major', 'minor'));
check('the same tier meets its own requirement',
  D.meetsTier('minor', 'minor') && D.meetsTier('master', 'master'));
check('a lower tier does not meet a higher requirement',
  !D.meetsTier('minor', 'major') && !D.meetsTier('major', 'master') && !D.meetsTier('minor', 'master'));
// NULL min_tier means "no restriction", never "master only" — the whole
// psionic importer depends on an absent tier gating nothing.
check('no requirement is met by anyone, including a non-psychic',
  D.meetsTier('minor', null) && D.meetsTier(null, null) && D.meetsTier(null, undefined));
check('a non-psychic meets no stated requirement',
  !D.meetsTier(null, 'minor') && !D.meetsTier('', 'master'));
check('tier comparison ignores case', D.meetsTier('Master', 'MAJOR'));
check('an unrecognised requirement gates nothing', D.meetsTier('minor', 'grandmaster'));

check('major and master save vs psionics at 12, everyone else at 15', (() => {
  const t = (tier) => D.saves({ ME: 10 }, null, tier).psionics_target;
  return t('major') === 12 && t('master') === 12
      && t('minor') === 15 && t(null) === 15 && t(undefined) === 15;
})());
check('the psionic save BONUS is still purely M.E.', (() => {
  const strong = D.saves({ ME: 18 }, null, 'master');
  const weak = D.saves({ ME: 18 }, null, null);
  // 2, not 3: the M.E. row gains one per TWO points, not one per point.
  return strong.psionics === weak.psionics && strong.psionics === 2;
})());
check('a stored override still wins over the derived target',
  D.saves({ ME: 10 }, { psionics_target: 8 }, 'minor').psionics_target === 8);

// ---------- 1c5. Duplicate detection ----------
// Every pair below is a REAL clash found importing the Rifts skill chapter:
// the book and the hand-seeded catalog name the same skill differently, and
// exact-name dedupe in the importers cannot see any of them.
section('Duplicate detection');
const REAL_CLASHES = [
  ['Skin and Prepare Animal Hides', 'Skin & Prepare Animal Hides'],
  ['Lore — Demons and Monsters', 'Lore: Demons & Monsters'],
  ['Tracking', 'Tracking (people)'],
  ['Mathematics — Basic', 'Basic Math'],
  ['Mathematics — Advanced', 'Advanced Math'],
  ['Laser', 'Laser Communications'],
  ['Horsemanship', 'Horsemanship: General'],
  ['Language', 'Language: Other'],
  ['Track Animals', 'Track & Trap Animals'],
  ['W.P. Archery and Targeting', 'W.P. Archery'],
];
const missed = REAL_CLASHES.filter(([a, b]) => similarity(a, b) < 0.7);
check('every real clash from the Rifts import is detected', missed.length === 0,
  'missed: ' + missed.map((p) => p.join(' / ')).join('; '));

check('punctuation and ampersands normalise away',
  normaliseName('Lore — Demons and Monsters') === normaliseName('Lore: Demons & Monsters'));
check('bracketed qualifiers are ignored',
  normaliseName('Tracking (people)') === normaliseName('Tracking'));
check('an identical pair scores 1', similarity('Skin & Prepare Animal Hides', 'Skin and Prepare Animal Hides') === 1);
// Found in the real gear catalog. These used to score 0.75 and sit in the
// loosest tier — a genuine duplicate filed where genuine duplicates get
// ignored, and below the threshold the duplicate badge counts.
check('names identical but for spacing score 1',
  similarity('Back Pack', 'Backpack') === 1 && similarity('Vibro Blade', 'Vibro-Blade') === 1);
check('collapsing spaces does not merge genuinely different names',
  similarity('Back Pack', 'Backpacking') < 1);
check('a reordered/inflected pair scores in the likely band', (() => {
  const s = similarity('Mathematics — Basic', 'Basic Math');
  return s >= 0.9 && s < 1;
})());
check('a containment pair scores below the likely band', (() => {
  const s = similarity('Laser', 'Laser Communications');
  return s >= 0.7 && s < 0.9;
})());

// Genuinely different skills that share words. These SHOULD score low enough
// to sit in the loosest group rather than looking confident.
for (const [a, b] of [
  ['Chemistry', 'Chemistry — Analytical'],
  ['Demolitions', 'Demolitions Disposal'],
  ['Hand to Hand: Basic', 'Hand to Hand: Expert'],
]) {
  check(`"${a}" vs "${b}" never reaches the confident bands`, similarity(a, b) < 0.9);
}
check('unrelated names do not match at all', similarity('Swimming', 'Sewing') < 0.7);

// Different categories mean different rows, however alike the names look.
// Found importing the Rifts psionics chapter: `Telekinesis` is Physical at
// 3 I.S.P. and `Telekinesis (Super)` is Super at 10, but normaliseName strips
// "(Super)" the same way it strips "(people)", scoring them a perfect 1. Three
// of eight confident suggestions on that catalog were this.
const catalogDb = (rows) => ({ DB: { prepare: () => ({ all: async () => ({ results: rows }) }) } });

const psiPairs = await findDuplicates(catalogDb([
  { id: 1, name: 'Telekinesis', category: 'Physical', isp: 3 },
  { id: 2, name: 'Telekinesis (Super)', category: 'Super', isp: 10 },
  { id: 3, name: 'Levitation (psionic)', category: 'Physical', isp: 2 },
  { id: 4, name: 'Levitation', category: 'Physical', isp: 2 },
]), 'psionics');
const findPair = (x, y) => psiPairs.find((p) =>
  (p.a.name === x && p.b.name === y) || (p.a.name === y && p.b.name === x));

check('a category clash is demoted out of the confident tiers', (() => {
  const p = findPair('Telekinesis', 'Telekinesis (Super)');
  return p && p.tier === 'contains' && p.category_clash === true;
})());
check('the demoted pair says why', (() => {
  const p = findPair('Telekinesis', 'Telekinesis (Super)');
  return p && /Physical and Super/.test(p.confidence);
})());
check('a real duplicate in one category still reaches certain', (() => {
  const p = findPair('Levitation (psionic)', 'Levitation');
  return p && p.tier === 'certain' && !p.category_clash;
})());
// Demoted, never dropped: the category itself may be the thing that is wrong.
check('a clashing pair is still reported', !!findPair('Telekinesis', 'Telekinesis (Super)'));

check('a missing category on either row is not a clash', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Back Pack', category: null },
    { id: 2, name: 'Backpack', category: 'gear' },
  ]), 'gear');
  return pairs[0]?.tier === 'certain' && !pairs[0].category_clash;
})());

// Class definitions cite skills by display name and gear by SLUG. A gear merge
// that only checked the name reported nothing, so a character built from that
// class afterwards would re-create the very stub the merge removed.
check('class-mention lookup searches every supplied term', await (async () => {
  const asked = [];
  const db = { prepare: (sql) => ({ bind: (...t) => { asked.push({ sql, t }); return { all: async () => ({ results: [] }) }; } }) };
  await classesMentioning({ DB: db }, ['Ja 11 Energy Rifle', 'ja-11-energy-rifle']);
  const { sql, t } = asked[0];
  return (sql.match(/markdown LIKE \?/g) || []).length === 2
      && t.includes('%ja-11-energy-rifle%') && t.includes('%Ja 11 Energy Rifle%');
})());
check('class-mention lookup skips blank terms', await (async () => {
  let called = false;
  const db = { prepare: () => { called = true; return { bind: () => ({ all: async () => ({ results: [] }) }) }; } };
  const out = await classesMentioning({ DB: db }, [null, undefined, '']);
  return out.length === 0 && !called;
})());

// ---------- 1c6. Catalog redirects ----------
// A merge deletes a row that class markdown may still cite by slug or by name.
// The redirect is what keeps that citation resolving, so the cases that matter
// are the ones where it must NOT be written: a key the surviving row already
// answers to would shadow a live key with a forwarding address.
section('Catalog redirects');

const capturingDb = (results = []) => ({
  DB: { prepare: (sql) => ({ bind: (...args) => ({ sql, args, all: async () => ({ results }) }) }) },
});

check('gear answers to both its slug and its name',
  keysOf(CATALOGS.gear, { slug: 'ja-11-energy-rifle', name: 'JA-11 Energy Rifle' }).length === 2);
check('a name-keyed catalog yields one key, not the same one twice',
  keysOf(CATALOGS.skills, { name: 'Track Animals' }).length === 1);

check('one redirect is filed per retired key', (() => {
  const s = redirectStatements(capturingDb(), 'gear', ['ja-11-energy-rifle', 'JA-11 Energy Rifle'], 7, 'merge');
  return s.length === 2
    && s[0].args[0] === 'gear' && s[0].args[1] === 'ja-11-energy-rifle'
    && s[0].args[2] === 7 && s[0].args[3] === 'merge';
})());

// Merging two rows whose names differ only by case would otherwise file a
// redirect that shadows the very key it points at.
check('a key the survivor already answers to is never redirected', (() => {
  const s = redirectStatements(capturingDb(), 'skills', ['Track Animals'], 7, 'merge', ['TRACK ANIMALS']);
  return s.length === 0;
})());
check('blank keys file nothing', redirectStatements(capturingDb(), 'gear', [null, '', undefined], 7, 'merge').length === 0);

check('collapsing points existing redirects at the survivor', (() => {
  const s = collapseStatement(capturingDb(), 'gear', 4, 7);
  return s.args[0] === 7 && s.args[1] === 'gear' && s.args[2] === 4;
})());

check('resolving returns a case-insensitive key map', await (async () => {
  const map = await resolveKeys(capturingDb([{ from_key: 'JA-11-Energy-Rifle', to_id: 7 }]),
    'gear', ['ja-11-energy-rifle']);
  return map.get('ja-11-energy-rifle') === 7;
})());
check('resolving an empty list never touches the database', await (async () => {
  let called = false;
  const db = { DB: { prepare: () => { called = true; return { bind: () => ({ all: async () => ({ results: [] }) }) }; } } };
  const map = await resolveKeys(db, 'gear', []);
  return map.size === 0 && !called;
})());

// ---------- 1c7. Gear choice groups ----------
// Books routinely say "one energy pistol of choice" where equipment_starting
// only held fixed item ids. The workaround was a placeholder catalog row named
// after the category, which no book entry can ever match — so the character
// ended up holding a weapon with no stats.
section('Gear choice groups');

const classWithGear = (yaml) => parseClassMarkdown(
  `---
id: test-class
name: Test Class
system: rifts
source_book: test-book
category: occ
equipment_starting:
${yaml}
---

## Lore

Body.
`);

check('a fixed item and a choice can sit side by side', (() => {
  const p = classWithGear(
    '  - { item_id: "back-pack", qty: 1 }\n'
    + '  - { choose: 1, from: ["ng-33-laser-pistol", "wilks-320-laser-pistol"], label: "energy pistol" }');
  return p.ok && p.data.equipment_starting.length === 2;
})(), 'errors: ' + JSON.stringify(classWithGear('  - { item_id: "back-pack" }').errors));

check('an entry with neither item_id nor choose is rejected',
  !classWithGear('  - { qty: 1 }').ok);
check('a choice asking for more than it offers is rejected',
  !classWithGear('  - { choose: 3, from: ["a-slug", "b-slug"] }').ok);
check('a choice with an empty from list is rejected',
  !classWithGear('  - { choose: 1, from: [] }').ok);
check('a choice with a non-numeric choose is rejected',
  !classWithGear('  - { choose: "one", from: ["a-slug"] }').ok);

// An entry that names an item is a fixed item, whatever else it carries — `qty`
// must not be mistaken for the start of a choice.
check('a fixed entry with a qty is not read as a choice',
  isGearChoice({ item_id: 'back-pack', qty: 2 }) === false);
check('an entry with choose and no item_id is a choice',
  isGearChoice({ choose: 1, from: ['a-slug'] }) === true);

// Every option must exist in the catalog, the same reasoning skill groups use:
// any one of them could be the option actually picked.
check('cross-reference collects fixed items and every option', (() => {
  const slugs = referencedGear({ equipment_starting: [
    { item_id: 'back-pack', qty: 1 },
    { choose: 1, from: ['ng-33-laser-pistol', 'wilks-320-laser-pistol'] },
  ] });
  return slugs.length === 3 && slugs.includes('back-pack') && slugs.includes('wilks-320-laser-pistol');
})());
check('cross-reference on a class with no equipment yields nothing',
  referencedGear({}).length === 0);

// ---------- 1c8. Draft persistence ----------
// The wizard persists the BUILD, never the catalogs it was built against. S
// holds the class, skill, spell and gear catalogs too — large, shared, and
// stale the moment they are written down.
section('Draft persistence');

const DRAFT_KEYS = readFileSync(join(appDir, 'app.js'), 'utf8')
  .match(/const DRAFT_KEYS = \[([\s\S]*?)\];/)?.[1]
  ?.match(/'([^']+)'/g)?.map((s) => s.slice(1, -1)) || [];

check('the persisted key list is found in app.js', DRAFT_KEYS.length > 0);

// ---------- Starting above level 1 ----------
// The engine is the live level-up's, run before the character exists. What is
// new is the per-level spell and psionic rules - and the honest answer for a
// class whose definition does not state them.
section('Per-level spells and psionics');
{
  const none = spellGrantsFor({}, 1, 6);
  check('a class with no magic is not applicable', none.applicable === false && none.unknown === false);
  check('and grants nothing', none.total === 0);

  // The distinction the whole feature turns on. A caster whose class never
  // recorded a per-level rule must not be shown an empty list, which reads as
  // "this class learns no spells" - it is "nobody wrote it down".
  const silent = spellGrantsFor({ magic: { type: 'innate', spells_starting: 6 } }, 1, 6);
  check('a caster stating no per-level rule is UNKNOWN, not empty',
    silent.applicable === true && silent.unknown === true);
  check('and offers nothing rather than guessing', silent.total === 0);

  const flat = spellGrantsFor({ magic: { spells_starting: 6, spells_per_level: 2 } }, 1, 4);
  check('a flat rule grants once per level gained', flat.grants.length === 3, JSON.stringify(flat.grants));
  check('itemised by the level that earned each',
    JSON.stringify(flat.grants.map((g) => g.level)) === '[2,3,4]');
  check('and totals correctly', flat.total === 6);
  check('level 1 to 1 gains nothing', spellGrantsFor({ magic: { spells_per_level: 2 } }, 1, 1).total === 0);

  const sched = spellGrantsFor({ magic: { spells_schedule: [
    { level: 2, count: 2 }, { level: 3, count: 3 }, { level: 9, count: 4 }] } }, 1, 5);
  check('a schedule counts every threshold crossed and no more',
    JSON.stringify(sched.grants.map((g) => [g.level, g.count])) === '[[2,2],[3,3]]',
    JSON.stringify(sched.grants));
  // Every grant carries a slot, because several can share a level.
  check('and each carries a slot', sched.grants.every((g) => Number.isFinite(g.slot)));
  check('a jump starting above 1 skips what it did not cross',
    spellGrantsFor({ magic: { spells_schedule: [{ level: 2, count: 2 }, { level: 5, count: 1 }] } }, 3, 6)
      .total === 1);

  // Two keys that combine is a rule nobody remembers correctly later.
  const both = spellGrantsFor({ magic: { spells_per_level: 9, spells_schedule: [{ level: 2, count: 1 }] } }, 1, 4);
  check('a schedule is the complete statement and the flat rule is ignored', both.total === 1);

  // Psionics reads the same shape from its own keys.
  // WHICH spell levels a per-level grant may draw from - a different question
  // from how many, and one the Ley Line Walker answers with a cap that tracks
  // the character rather than a fixed list.
  const llw = { magic: { spells_starting: 12, spell_levels_allowed: [1, 2, 3, 4],
                         spells_per_level: 2, spells_per_level_levels: 'up_to_character_level' } };
  check('the cap tracks the level that earned the grant',
    JSON.stringify(spellLevelsForGrant(llw, 2)) === '[1,2]');
  check('and widens as the character advances',
    JSON.stringify(spellLevelsForGrant(llw, 6)) === '[1,2,3,4,5,6]');

  // THE POINT. The per-level cap is STRICTER than the starting list at low
  // levels and they disagree on purpose: a fresh walker picks twelve spells
  // from levels 1-4, and the two it gains at level 2 may only be levels 1-2.
  // Falling back to spell_levels_allowed here would let a level-2 walker take a
  // level-4 spell, which is over-permissive in a way nobody would notice.
  check('the per-level cap is not the starting list',
    JSON.stringify(spellLevelsForGrant(llw, 2)) !== JSON.stringify(llw.magic.spell_levels_allowed));

  // A SCHEDULE ENTRY OVERRIDES THE CLASS-WIDE RULE, because some books vary the
  // cap per level rather than by one rule. The Mystic gains four spells at
  // level 2 from spell levels 1-3 and three at level 3 from 1-4 - the
  // character's level PLUS ONE - then two per level from its own level down.
  const mystic = { magic: { spells_starting: 8, spell_levels_allowed: [1, 2],
                            spells_per_level_levels: 'up_to_character_level',
                            spells_schedule: [
                              { level: 2, count: 4, spell_levels: [1, 2, 3] },
                              { level: 3, count: 3, spell_levels: [1, 2, 3, 4] },
                              { level: 4, count: 2 }, { level: 5, count: 2 },
                              { level: 6, count: 2 }] } };
  check("an entry's own cap wins over the class rule",
    JSON.stringify(spellLevelsForGrant(mystic, 2)) === '[1,2,3]',
    JSON.stringify(spellLevelsForGrant(mystic, 2)));
  check('and it is wider than the character level, which no single rule gives',
    spellLevelsForGrant(mystic, 2).length === 3);
  check('an entry without one falls back to the class rule',
    JSON.stringify(spellLevelsForGrant(mystic, 5)) === '[1,2,3,4,5]');
  // The book's own worked examples: "a sixth level Mystic can select two new
  // spells from any of the levels 1-6".
  check("the book's sixth-level example holds",
    JSON.stringify(spellLevelsForGrant(mystic, 6)) === '[1,2,3,4,5,6]');
  const mysticGrants = spellGrantsFor(mystic, 1, 6);
  check('and the counts are the varying ones, not a flat rule',
    JSON.stringify(mysticGrants.grants.map((g) => g.count)) === '[4,3,2,2,2]',
    JSON.stringify(mysticGrants.grants.map((g) => g.count)));
  check('totalling what the book adds up to', mysticGrants.total === 13);

  // An explicit list is honoured, and a class stating neither falls back.
  check('an explicit list wins',
    JSON.stringify(spellLevelsForGrant({ magic: { spells_per_level_levels: [1, 2] } }, 9)) === '[1,2]');
  check('with no per-level rule it falls back to the starting list',
    JSON.stringify(spellLevelsForGrant({ magic: { spell_levels_allowed: [1, 2, 3] } }, 9)) === '[1,2,3]');
  check('and a class restricting nothing is unrestricted',
    spellLevelsForGrant({ magic: { spells_per_level: 2 } }, 4) === null);
  check('no magic block is no answer', spellLevelsForGrant({}, 4) === null);

  // The picker holds each grant separately, because the caps differ per grant.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('level spells are held per grant, not as one list',
    /levelSpells\[gi\]/.test(appSrc));
  // Psionics too, once a book stated a per-level category. The old comment
  // claimed no book says which level a power was learned at; the Mystic does.
  check('and so are level psionic powers',
    /levelPsi\[gi\]/.test(appSrc));
  check('each psionic grant asks for its own categories',
    /psionicCategoriesForGrant\(S\.cls, g\.level, g\.slot\)/.test(appSrc));
  check('the batched-psionics claim is gone',
    !/no book states which level a given psionic power/.test(appSrc));
  check('and each grant asks for its own allowed levels',
    /spellLevelsForGrant\(S\.cls, g\.level, g\.slot\)/.test(appSrc));
  // Enforced, not advised: a spell level is a mechanical rule like a psychic
  // tier, not a table judgement like a skill category.
  check('an out-of-cap spell is not in the list at all',
    /\(!levels \|\| levels\.includes\(sp\.level\)\)/.test(appSrc));

  // A PSIONIC grant may name its own categories, and they REPLACE the class's
  // rather than narrowing them. The Mystic (RUE p.119) is the case: it starts
  // with Sensitive and Healing powers and gains a SUPER one at levels 4 and 8 -
  // a category a major psychic cannot otherwise take, because tier is enforced
  // by category here. Intersecting would throw the book's exception away and
  // leave an empty picker.
  const mysticPsi = { psionics: { type: 'major', powers_starting: 5,
                                  categories_allowed: ['Sensitive', 'Healing'],
                                  powers_schedule: [
                                    { level: 4, count: 1, categories: ['Super'] },
                                    { level: 8, count: 1, categories: ['Super'] }] } };
  check('a grant names its own categories',
    JSON.stringify(psionicCategoriesForGrant(mysticPsi, 4)) === '["Super"]');
  check('and they replace the class list rather than intersecting it',
    !psionicCategoriesForGrant(mysticPsi, 4).includes('Sensitive'));
  check('a level with no grant falls back to the class list',
    JSON.stringify(psionicCategoriesForGrant(mysticPsi, 5)) === '["Sensitive","Healing"]');
  check('a class with no psionics has no answer', psionicCategoriesForGrant({}, 4) === null);
  check('and one restricting nothing is unrestricted',
    psionicCategoriesForGrant({ psionics: { type: 'major' } }, 4) === null);
  const mysticPsiGrants = psionicGrantsFor(mysticPsi, 1, 8);
  check('the schedule grants only at the levels it names',
    JSON.stringify(mysticPsiGrants.grants.map((g) => g.level)) === '[4,8]');
  check('two powers across eight levels', mysticPsiGrants.total === 2);

  const psi = psionicGrantsFor({ psionics: { type: 'major', powers_per_level: 1 } }, 1, 5);
  check('psionic powers use their own keys', psi.total === 4 && psi.unknown === false);
  check('a psychic class stating no rule is unknown too',
    psionicGrantsFor({ psionics: { type: 'major', powers_starting: 3 } }, 1, 5).unknown === true);
  check('a class with no psionics is not applicable',
    psionicGrantsFor({}, 1, 5).applicable === false);

  // The proposal carries both, so one engine answers for the wizard and the
  // API. The sheet's live level-up renders named fields and ignores these.
  const cls = { hit_points_base: 'P.E. + 1d6 per level', magic: { spells_per_level: 2 } };
  const prop = buildProposal({ level: 1, hp_max: 20, skills: [] }, cls, 3);
  check('buildProposal reports the spell picks', prop.spell_picks?.total === 4);
  check('and the psionic ones', prop.psionic_picks?.applicable === false);
}

// ---------- Starting XP ----------
// A level-6 character with 0 XP reads as under-levelled to the XP endpoint, and
// the very next award proposes a level-up it has already had.
section('Starting XP');
{
  const table = xpTableFor({});
  check('the threshold is the level’s own entry', thresholdFor(table, 1) === 0);
  check('and rises with the level', thresholdFor(table, 6) === table[5]);
  check('past the cap is null, not zero', thresholdFor(table, table.length + 1) === null);

  // A class may state its own curve, and the create path must read the same
  // table the level-up path does or the two disagree about what level 6 costs.
  const own = xpTableFor({ xp_table: [0, 100, 200, 300] });
  check('a class curve wins', thresholdFor(own, 3) === 200);
  check('and its length caps the level', thresholdFor(own, 5) === null);

  const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'characters.js'), 'utf8');
  check('the create path clamps the level to the class table', /Math\.min\(/.test(src) && /xpTable\.length/.test(src));
  check('and sets XP from the threshold rather than the client',
    /thresholdFor\(xpTable, level\)/.test(src) && !/b\.xp/.test(src));
  check('and validates at the level being created, not at 1',
    /character: \{ level \},/.test(src));
  check('unspent picks are banked on create', /insertGrantStatements\(env, row\.id, remaining\)/.test(src));
  check('and the allowance is recomputed server-side rather than trusted',
    /skillGrantsFor\(cls, 1, level\)/.test(src));

  // A warning nothing hands the number to is a warning that never fires. The
  // audit is the one caller positioned to notice, so it has to SELECT xp and
  // pass it - which is the shape of failure this repo has been bitten by
  // before, under 'a field the prompt does not mention'.
  const auditSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'admin', 'audit.js'), 'utf8');
  check('the audit selects xp', /level, xp, attributes/.test(auditSrc));
  check('and passes it to the validator', /level: row\.level, xp: row\.xp/.test(auditSrc));
}

// ---------- The wizard's step list ----------
// A draft stores `step` as an INDEX into STEPS, so changing the list silently
// re-points every draft in flight. The list, its version, and the mapping that
// carries an old index forward are pinned together here because they are only
// correct with respect to each other.
section('Wizard steps');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  const steps = src.match(/const STEPS = \[([^\]]*)\]/)?.[1]
    ?.match(/'([^']+)'/g)?.map((x) => x.slice(1, -1)) || [];

  check('STEPS is found in app.js', steps.length > 0);
  check('ten steps', steps.length === 10, String(steps.length));
  // The whole point of PR 13: the race is chosen, then the dice are rolled,
  // then the occupation is chosen against a stat block that already exists.
  check('Race comes before Attributes',
    steps.indexOf('Race') >= 0 && steps.indexOf('Race') < steps.indexOf('Attributes'));
  check('Occupation comes after Attributes',
    steps.indexOf('Occupation') > steps.indexOf('Attributes'));
  check('Occupation comes before Skills',
    steps.indexOf('Occupation') < steps.indexOf('Skills'));
  check('the combined Class step is gone', !steps.includes('Class'));

  // Advancement sits after the level-1 character is COMPLETE, because that is
  // the input buildProposal takes. Before Powers it would run against a
  // character whose psionic tier an ability could still change.
  check('Advancement comes after Powers',
    steps.indexOf('Advancement') > steps.indexOf('Powers'));
  check('and before Details',
    steps.indexOf('Advancement') < steps.indexOf('Details'));

  // Steps are addressed by name now. A bare goStep(4) in a nav button is how
  // inserting a step used to break three others silently.
  check('no step transition is a bare index',
    !/goStep\(\s*\d+\s*\)/.test(src.replace(/^\s*\/\/.*$/gm, '')));

  const version = Number(src.match(/const STEPS_VERSION = (\d+);/)?.[1]);
  check('the step list carries a version', version === 3, String(version));

  // Each version is ONE insertion and the migrations chain, so a version-1
  // draft runs through both. Off by one here resumes every in-flight draft
  // onto the wrong screen, which is the whole reason this is pinned.
  const migrations = eval(src.match(/const STEP_MIGRATIONS = (\[[\s\S]*?\n\];)/)?.[1]
    ?.replace(/\/\/[^\n]*/g, '').replace(/;$/, '') || 'null');
  check('the migration chain is found',
    Array.isArray(migrations) && migrations.length === version - 1);

  // Same walk migrateDraft does: start at the draft's version, apply each
  // migration from there.
  const migrate = (i, from) => {
    let step = i;
    for (let v = from; v < version; v++) step = migrations[v - 1](step);
    return step;
  };

  // From version 1 - the original eight-step list.
  check('System stays put', migrate(0, 1) === 0);
  check('the old Class step resumes on Race', migrate(1, 1) === steps.indexOf('Race'));
  check('Attributes does not move', migrate(2, 1) === steps.indexOf('Attributes'));
  check('the old Skills step shifts by one', migrate(3, 1) === steps.indexOf('Skills'));
  check('and the old Review lands on Review', migrate(7, 1) === steps.indexOf('Review'));

  // From version 2 - the nine-step list, before Advancement existed.
  check('a v2 Powers step does not move', migrate(6, 2) === steps.indexOf('Powers'));
  check('a v2 Details step shifts by one', migrate(7, 2) === steps.indexOf('Details'));
  check('a v2 Review step shifts too', migrate(8, 2) === steps.indexOf('Review'));

  // A migrated draft must not land on a step that did not exist when it was
  // saved: there is nothing on it the draft could have filled in, and
  // stepApplies would walk straight off it for most characters.
  //
  // A version-2 draft stopped ON the Occupation step is the exception and stays
  // there, because that step already existed for it. Only Advancement is new.
  const occupation = steps.indexOf('Occupation');
  const advancement = steps.indexOf('Advancement');
  check('no version-1 index lands on a step version 1 never had',
    ![0, 1, 2, 3, 4, 5, 6, 7].some((i) => [occupation, advancement].includes(migrate(i, 1))));
  check('no version-2 index lands on Advancement',
    ![0, 1, 2, 3, 4, 5, 6, 7, 8].some((i) => migrate(i, 2) === advancement));
  check('but a version-2 Occupation step stays where it is',
    migrate(occupation, 2) === occupation);

  // A missed minimum warns and offers a re-roll; it never refuses. Same rule
  // the occupation warning already follows, and the reason the Attributes step
  // can no longer be the only gate.
  const occBlocker = src.match(/function occBlocker\(\)[\s\S]*?\n}/)?.[0] || '';
  check('occBlocker is found', occBlocker.length > 0);
  check('only an ability blocks the Occupation step', /abilityOccOptions/.test(occBlocker));
  check('a missed minimum does not', !/minimumShortfall|attribute_requirements/.test(occBlocker));

  // One attribute, with its own dice. Not the whole block, and never raised to
  // the minimum without dice - see docs/plans/13-rcc-first-wizard.md.
  const reroll = src.match(/function rerollForMinimum\(attr\)[\s\S]*?\n}/)?.[0] || '';
  check('rerollForMinimum is found', reroll.length > 0);
  check('it re-rolls the one attribute', /setRoll\(attr\)/.test(reroll));
  check('it records the assist', /S\.minRerolls\.push/.test(reroll));
  check('and it never assigns the minimum instead', !/S\.attrs\[attr\]\s*=/.test(reroll));
}
for (const k of ['step', 'attrs', 'attrMethods', 'groupPicks', 'gearPicks', 'equipment', 'bio', 'pools']) {
  check(`draft persists \`${k}\``, DRAFT_KEYS.includes(k));
}
// A draft carrying a copy of the catalogs would be large, and would restore a
// snapshot of content that has since been edited or re-imported.
for (const k of ['items', 'classes', 'skillCatalog', 'spellCatalog', 'psiCatalog', 'campaigns', 'existing', 'itemRedirects']) {
  check(`draft does NOT persist \`${k}\``, !DRAFT_KEYS.includes(k));
}
// The class is stored as an id and re-resolved on restore, so an edited class
// definition takes effect rather than being shadowed by the draft.
check('draft does NOT persist the resolved class object', !DRAFT_KEYS.includes('cls'));
// Derived from the class and catalog on every render; persisting it would
// restore options that no longer match the class.
check('draft does NOT persist derived gear choices', !DRAFT_KEYS.includes('gearChoices'));

// ---------- 1c11. Class bonuses ----------
// What a class GRANTS mechanically. `natural_abilities` and
// `level_progression.grants` are the book's wording and display-only, so a
// Dragon's "+2 to P.S." and "+1 attack at level 5" were prose nothing could act
// on. These are numbers the sheet adds up.
section('Class bonuses');

const withBonuses = (yaml) => parseClassMarkdown(
  `---
id: test-class
name: Test Class
system: rifts
source_book: test-book
category: occ
${yaml}
---

## Lore

Body.
`);

check('a full bonuses block parses', (() => {
  const p = withBonuses(`bonuses:
  attributes: { PS: 2 }
  combat: { attacks: 1, strike: 2 }
  saves: { spell_magic: 2 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }`);
  return p.ok && p.data.bonuses.attributes.PS === 2 && p.data.bonuses.at_level.length === 1;
})(), JSON.stringify(withBonuses('bonuses:\n  attributes: { PS: 2 }').errors));

// A bonus filed under a key nothing reads would silently do nothing, which is
// the whole failure this validation exists to prevent.
check('an unknown attribute is rejected', !withBonuses('bonuses:\n  attributes: { STR: 2 }').ok);
check('a non-numeric bonus is rejected', !withBonuses('bonuses:\n  attributes: { PS: "two" }').ok);
check('an at_level entry without a level is rejected',
  !withBonuses('bonuses:\n  at_level:\n    - { combat: { attacks: 1 } }').ok);
check('a zero bonus warns rather than fails', (() => {
  const p = withBonuses('bonuses:\n  combat: { strike: 0 }');
  return p.ok && p.warnings.some((x) => /will do nothing/.test(x));
})());
check('an unrecognised group warns rather than fails', (() => {
  const p = withBonuses('bonuses:\n  skills: { Climbing: 10 }');
  return p.ok && p.warnings.some((x) => /not a recognised group/.test(x));
})());

// derive.js is a classic script, loaded the way the browser loads it.
const deriveWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(deriveWindow, deriveWindow);
const D2 = deriveWindow.derive;
const derive = D2;

const dragon = { bonuses: { attributes: { PS: 2 }, combat: { attacks: 1 },
                            at_level: [{ level: 5, combat: { attacks: 1 } }] } };

check('at_level bonuses only count once their level is reached',
  D2.classBonuses(dragon, 1).combat.attacks === 1 && D2.classBonuses(dragon, 5).combat.attacks === 2);
check('a class with no bonuses yields empty groups',
  Object.keys(D2.classBonuses({}, 9).combat).length === 0);

// The attribute bonus is NOT stored on the character — it is added on the way
// past, so everything derived has to read through effective().
check('effective() adds the class bonus without touching the input', (() => {
  const raw = { PS: 24 };
  const eff = D2.effective(raw, D2.classBonuses(dragon, 1));
  return eff.PS === 26 && raw.PS === 24;
})());
check('a bonus to an attribute the character lacks is ignored',
  D2.effective({}, { attributes: { PS: 2 } }).PS === undefined);

// P.S. 24 gives a damage bonus of 9; the class's +2 must carry through to 11,
// or the bonus is decorative.
check('an attribute bonus reaches the derived numbers',
  D2.combat({ PS: 24 }, null, D2.classBonuses(dragon, 1)).damage_bonus === 11);
check('a direct combat bonus is added on top',
  D2.combat({ PS: 10 }, null, D2.classBonuses(dragon, 1)).attacks === 3);
check('a human override still wins over both',
  D2.combat({ PS: 10 }, { attacks: 7 }, D2.classBonuses(dragon, 1)).attacks === 7);
// Asserted as an equivalence rather than a literal: the point is that the two
// call shapes agree, and pinning the number here just duplicates [1c17].
check('omitting bonuses behaves exactly as passing none',
  D2.combat({ PP: 18 }).strike === D2.combat({ PP: 18 }, null, null).strike
  && D2.combat({ PP: 18 }).strike === 2);

// The sheet shows one number; the hover has to be able to say why.
check('parts() separates the attribute half from the class half', (() => {
  const p = D2.parts('combat', { PS: 24 }, D2.classBonuses(dragon, 1));
  return p.damage_bonus.attrs === 9 && p.damage_bonus.from_class === 2
      && p.attacks.attrs === 2 && p.attacks.from_class === 1;
})());

// ---------- 1c13. Class template ----------
// A starting point for writing a class by hand. The one thing that must hold is
// that it PARSES on arrival — a template that fails validation the moment it is
// created teaches you nothing about which of your own edits broke it.
section('Class template');

const tplWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'class-template.js'), 'utf8')).call(tplWindow, tplWindow);
const classTemplate = tplWindow.classTemplate;

for (const kind of ['occ', 'rcc']) {
  const md = classTemplate(kind, {
    id: 'test-' + kind, name: 'Test Name', system: 'rifts', sourceBook: 'Rifts Ultimate Edition',
  });
  const p = parseClassMarkdown(md);
  check(`the ${kind} template parses clean`, p.ok && !p.warnings.length,
    JSON.stringify([...p.errors, ...p.warnings]));
  check(`the ${kind} template carries the values it was given`,
    p.data.id === 'test-' + kind && p.data.name === 'Test Name'
    && p.data.system === 'rifts' && p.data.source_book === 'Rifts Ultimate Edition');
  check(`the ${kind} template is the right category`, p.data.category === kind);
}

// The two shapes genuinely differ — a race rolls its attributes, a character
// class has minimums — which is why there are two templates rather than one
// with half of it commented out.
const occTpl = classTemplate('occ', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' });
const rccTpl = classTemplate('rcc', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' });
check('the OCC template has requirements and hit points, not racial dice', (() => {
  const d = parseClassMarkdown(occTpl).data;
  return d.attribute_requirements && d.hit_points_base && !d.attribute_dice;
})());
check('the RCC template has racial dice and M.D.C., not hit points', (() => {
  const d = parseClassMarkdown(rccTpl).data;
  return d.attribute_dice?.PS && d.mdc_base && !d.hit_points_base;
})());

// The fiddly blocks are the reason hand-authoring is worth supporting, so the
// template has to show their shape even while commented out.
for (const [what, re] of [['variants', /# variants:/], ['bonuses', /^bonuses:/m],
                          ['a gear choice', /choose: 1, label:/], ['a skill choice-group', /choose: 2, from:/]]) {
  check(`the RCC template shows how to write ${what}`, re.test(rccTpl));
}
check('an unknown kind falls back to the OCC shape',
  parseClassMarkdown(classTemplate('nonsense', { id: 'a', name: 'A', system: 'rifts', sourceBook: 'B' })).data.category === 'occ');

// ---------- 1c14. Frontmatter block editing ----------
// The structured editors rewrite ONE top-level block and leave every byte
// outside it alone. Regenerating the whole frontmatter would have been simpler
// and would have destroyed the template's comments, which are most of what
// makes a hand-written class approachable.
section('Frontmatter block editing');

const blkWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'class-blocks.js'), 'utf8')).call(blkWindow, blkWindow);
const B = blkWindow.classBlocks;

check('bonuses flatten to (level, group, key, value) rows', (() => {
  const rows = B.bonusesToRows({ attributes: { PS: 4 }, at_level: [{ level: 5, combat: { attacks: 1 } }] });
  return rows.length === 2
    && rows[0].level === null && rows[0].group === 'attributes' && rows[0].key === 'PS' && rows[0].value === 4
    && rows[1].level === 5 && rows[1].group === 'combat';
})());
check('rows fold back into a bonuses block', (() => {
  const b = B.rowsToBonuses([
    { level: null, group: 'attributes', key: 'PS', value: 4 },
    { level: 5, group: 'combat', key: 'attacks', value: 1 },
    { level: 5, group: 'saves', key: 'psionics', value: 2 },
  ]);
  return b.attributes.PS === 4 && b.at_level.length === 1
    && b.at_level[0].combat.attacks === 1 && b.at_level[0].saves.psionics === 2;
})());
check('an incomplete row is dropped rather than written as junk',
  Object.keys(B.rowsToBonuses([{ level: null, group: 'combat', key: '', value: 1 },
                               { level: null, group: 'combat', key: 'attacks', value: NaN }])).length === 0);
check('rows survive a round trip', (() => {
  const original = { attributes: { PS: 4 }, combat: { attacks: 2 }, at_level: [{ level: 5, combat: { attacks: 1 } }] };
  const back = B.rowsToBonuses(B.bonusesToRows(original));
  return JSON.stringify(back) === JSON.stringify(original);
})());

const tpl = classTemplate('rcc', { id: 'w', name: 'Wyrm', system: 'rifts', sourceBook: 'RUE' });

check('writing a block leaves the file parseable', (() => {
  const md = B.write(tpl, 'bonuses', { attributes: { PS: 4 }, at_level: [{ level: 5, combat: { attacks: 1 } }] });
  const p = parseClassMarkdown(md);
  return p.ok && p.data.bonuses.attributes.PS === 4 && p.data.bonuses.at_level[0].level === 5;
})());

// The whole point: everything outside the edited block is untouched.
check('comments and sibling keys outside the block survive', (() => {
  const md = B.write(tpl, 'bonuses', { combat: { attacks: 1 } });
  const p = parseClassMarkdown(md);
  return /# A choice-group instead of a name/.test(md)
      && /# When the book says/.test(md)
      && /## Lore/.test(md)
      && p.data.mdc_base === '1d4x100'
      && p.data.skills.secondary_skills.count === 2;
})());

// Fields the form does not show must survive, or editing a variant's name would
// silently drop its attribute dice.
check('unedited keys inside a rebuilt block survive', (() => {
  const withVariants = B.write(tpl, 'variants', [
    { id: 'adult', name: 'Adult Wyrm', attribute_dice: { PS: '4d6+30' }, bonuses: { attributes: { PS: 4 } } },
  ]);
  const parsed = parseClassMarkdown(withVariants).data.variants;
  const renamed = B.write(withVariants, 'variants', parsed.map((v) => ({ ...v, name: 'Renamed' })));
  const after = parseClassMarkdown(renamed).data.variants[0];
  return after.name === 'Renamed' && after.attribute_dice.PS === '4d6+30' && after.bonuses.attributes.PS === 4;
})());

// The template ships these commented as worked examples; appending a real block
// would leave the file appearing to define the same key twice.
check('a commented-out example is replaced, not duplicated', (() => {
  const md = B.write(tpl, 'variants', [{ id: 'a', name: 'A' }]);
  return !/# variants:/.test(md) && /^variants:/m.test(md)
      && /# Stages of the same creature/.test(md);   // the explanation above it stays
})());

check('an empty value removes the block', (() => {
  const md = B.write(B.write(tpl, 'bonuses', { combat: { attacks: 1 } }), 'bonuses', {});
  return !/^bonuses:/m.test(md) && parseClassMarkdown(md).ok;
})());
check('reading a block back returns its text',
  /attacks: 1/.test(B.read(B.write(tpl, 'bonuses', { combat: { attacks: 1 } }), 'bonuses') || ''));
check('reading an absent block returns null', B.read(tpl, 'nonexistent') === null);
check('markdown with no frontmatter is returned unchanged',
  B.write('just prose', 'bonuses', { combat: { attacks: 1 } }) === 'just prose');

// A value that would change meaning unquoted has to come back as it went in.
check('awkward strings survive quoting', (() => {
  const md = B.write(tpl, 'variants', [{ id: 'a', name: 'Adult: the "big" one', mdc_base: '1d6x1000' }]);
  const v = parseClassMarkdown(md).data.variants[0];
  return v.name === 'Adult: the "big" one' && v.mdc_base === '1d6x1000';
})());

// ---------- 1c11b. The class prompt covers the schema ----------
// A field the schema supports and the prompt never mentions is a field that
// never gets extracted. `variants` shipped without being added here, so the
// first real two-stage class came back with BOTH stat blocks dropped — the
// numbers the entry exists for.
section('Class prompt covers the schema');
{
  const prompt = readFileSync(
    join(repoRoot, 'functions', 'api', 'character-creator', '_lib', 'extraction-prompt.js'), 'utf8');
  for (const key of ['variants', 'bonuses', 'attribute_dice', 'equipment_starting',
                     'level_progression', 'psionics', 'magic', 'special_abilities']) {
    check(`the prompt documents \`${key}\``, prompt.includes(key));
  }
  // The two rules a variant is easy to get wrong on.
  check('the prompt says what a variant may override', /may override ONLY/.test(prompt));
  check('the prompt says shared material stays at the top level', /stays at the top level/.test(prompt));

  // A bonus filed under a key derive.js does not produce is stored and never
  // read. The first real class came back with four of them — roll_with_punch,
  // pull_punch, magic, illusionary_magic — all silently inert.
  const deriveWin = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(deriveWin, deriveWin);
  const realKeys = [
    ...Object.keys(deriveWin.derive.combat({})),
    ...Object.keys(deriveWin.derive.saves({})),
  ];
  for (const key of ['attacks', 'strike', 'parry', 'dodge', 'roll', 'spell_magic', 'ritual_magic', 'horror_factor']) {
    check(`the prompt lists the real bonus key \`${key}\``, prompt.includes(key) && realKeys.includes(key));
  }

  // The pool group, which is the only one taking dice, and the only one whose
  // omission from the prompt would send a "plus 4D6" into ppe_base — where it
  // parses to NULL and the character gets no P.P.E. at all.
  check('the prompt documents the pools bonus group', /pools:\s+hp, sdc, mdc, ppe, isp/.test(prompt));
  check('the prompt tells the model each class states its own power list',
    /copy the options INTO this class/.test(prompt));
  check('the prompt documents a fragment carrying bonuses', /repeatable: true/.test(prompt));
  check('and says a pool grant is a bonus, never a base',
    /never a pool base/.test(prompt));
  check('and warns against putting a pool bonus in at_level',
    /do not put a pool bonus in at_level/i.test(prompt));
  check('the prompt warns that an unknown bonus key does nothing',
    /silently does nothing/.test(prompt));
}

// ---------- 1c12. Class variants ----------
// Several RCCs come in stages: a Dragon is a hatchling, then an adult, sharing
// lore, skills and abilities while differing in attribute dice, M.D.C. and what
// the class grants. Four unrelated class files means maintaining the shared 90%
// four times.
section('Class variants');

const dragonMd = `---
id: dragon
name: Dragon
system: rifts
source_book: test-book
category: rcc
mdc_base: "1d4x100"
ppe_base: "2d4x10+40"
attribute_dice: { PS: "4d6+12" }
bonuses:
  combat: { attacks: 1 }
variants:
  - id: hatchling
    name: "Dragon Hatchling"
  - id: adult
    name: "Adult Dragon"
    attribute_dice: { PS: "4d6+30" }
    mdc_base: "1d6x1000"
    bonuses:
      attributes: { PS: 4 }
      combat: { attacks: 3 }
---

## Lore

Shared by every stage.
`;
const dragonParsed = parseClassMarkdown(dragonMd);
check('a class with variants parses', dragonParsed.ok, JSON.stringify(dragonParsed.errors));

const asAdult = applyVariant(dragonParsed.data, 'adult');
const asHatchling = applyVariant(dragonParsed.data, 'hatchling');

check('a variant overrides only what it states', (() => (
  asAdult.attribute_dice.PS === '4d6+30' && asAdult.mdc_base === '1d6x1000'
  // Not stated by the adult, so it comes from the class.
  && asAdult.ppe_base === '2d4x10+40'
))());

// attribute_dice and attribute_requirements MERGE per key; everything else
// replaces. A variant naming one attribute says nothing about the other seven,
// and replacing the map wholesale left an adult that overrode only P.S. rolling
// a plain 3d6 for I.Q.
check('attribute_dice merges per attribute rather than replacing', (() => {
  const md = dragonMd.replace('attribute_dice: { PS: "4d6+12" }',
                              'attribute_dice: { PS: "4d6+12", IQ: "3d6+6" }');
  const adult = applyVariant(parseClassMarkdown(md).data, 'adult');
  // The adult states only PS.
  return adult.attribute_dice.PS === '4d6+30' && adult.attribute_dice.IQ === '3d6+6';
})());
check('a scalar override still replaces', asAdult.mdc_base === '1d6x1000');
check('a variant that states nothing inherits everything',
  asHatchling.mdc_base === '1d4x100' && asHatchling.attribute_dice.PS === '4d6+12');
check('the variant name replaces the class name for display',
  asAdult.name === 'Adult Dragon' && asHatchling.name === 'Dragon Hatchling');
check('the shared half is untouched',
  asAdult.id === 'dragon' && asAdult.sections !== undefined);

// Replacement, not merging — the same rule mdc_base follows. A variant's
// bonuses ARE its bonuses, so there is no question of which half won.
check('variant bonuses replace the class’s rather than merging', (() => {
  const b = derive.classBonuses(asAdult, 1);
  return b.combat.attacks === 3 && b.attributes.PS === 4;
})());
check('a variant with no bonuses keeps the class’s',
  derive.classBonuses(asHatchling, 1).combat.attacks === 1);

// Every caller applies this unconditionally, so the no-variant paths matter as
// much as the variant ones.
check('no variant id returns the class unchanged',
  applyVariant(dragonParsed.data, null).name === 'Dragon');
check('an unknown variant id returns the class unchanged',
  applyVariant(dragonParsed.data, 'wyrmling').name === 'Dragon');
check('a class with no variants is unaffected',
  applyVariant({ name: 'Juicer' }, 'adult').name === 'Juicer');

const variantErr = (yaml) => parseClassMarkdown(dragonMd.replace(/variants:[\s\S]*?---/, yaml + '\n---'));
check('a variant without an id is rejected',
  !variantErr('variants:\n  - { name: "Nameless" }').ok);
check('two variants with the same id are rejected',
  !variantErr('variants:\n  - { id: a, name: A }\n  - { id: a, name: B }').ok);
// A field a variant cannot override would silently do nothing.
check('a variant overriding something it may not warns', (() => {
  const p = variantErr('variants:\n  - { id: a, name: A, skills: { secondary_skills: { count: 9 } } }');
  return p.ok && p.warnings.some((w) => /cannot override/.test(w));
})());

// ---------- 1c10. Import session system ----------
// Which game system a book is for is chosen once per import session and stamped
// on every row it inserts. Three shapes across four catalogs: skills keep a JSON
// array, the rest a single string, and NULL means unrestricted everywhere.
section('Import session system');

check('skills get a JSON array', (() => {
  const s = systemColumnFor(CATALOGS.skills, 'rifts');
  return s.col === 'systems' && s.value === '["rifts"]';
})());
for (const key of ['spells', 'psionics', 'gear']) {
  check(`${key} gets a single string`, (() => {
    const s = systemColumnFor(CATALOGS[key], 'rifts');
    return s.col === 'system' && s.value === 'rifts';
  })());
}

// NULL means unrestricted, so neither of these should write anything — a book
// covering both systems restricts nothing, and nor does not knowing.
check('"both" stamps nothing', systemColumnFor(CATALOGS.gear, 'both') === null);
check('an unset system stamps nothing',
  systemColumnFor(CATALOGS.gear, null) === null && systemColumnFor(CATALOGS.gear, '') === null);

// Every catalog can now record a system; before this only gear and skills could,
// so a Palladium Fantasy spell chapter had nowhere to say so.
for (const key of ['skills', 'spells', 'psionics', 'gear']) {
  check(`${key} has somewhere to record a system`, systemColumnFor(CATALOGS[key], 'rifts') !== null);
}

// ---------- 1c9. Picker filtering ----------
// js/picker.js is a classic script, because the wizard is a module and the
// sheet is a plain script and both need it. So it is loaded the way a browser
// would: evaluated against a stand-in window, then the global it defines is
// taken off that.
section('Picker filtering');

const pickerWindow = {};
new Function('window', readFileSync(join(appDir, 'js', 'picker.js'), 'utf8'))(pickerWindow);
const Picker = pickerWindow.Picker;

const skill = { name: 'Wilderness Survival', category: 'Wilderness', source_book: 'rifts-main' };

check('matches on a name fragment', Picker.match(skill, 'wilder'));
check('matches on category', Picker.match(skill, 'wilderness'));
check('matches on source book', Picker.match(skill, 'rifts'));
check('is case-insensitive', Picker.match(skill, 'WILDERNESS SURVIVAL'));
check('an empty query matches everything', Picker.match(skill, '') && Picker.match(skill, '   '));

// Multi-term is AND, not OR: typing more must narrow. A picker that widened as
// you typed would be worse than no filter at all.
check('every term must match', Picker.match(skill, 'survival rifts'));
check('one non-matching term excludes the row', !Picker.match(skill, 'survival palladium'));
check('term order does not matter', Picker.match(skill, 'rifts survival'));

// Fields the row does not display are deliberately not searched — a hit whose
// reason is invisible reads as a bug.
check('undisplayed fields are not searched',
  !Picker.match({ name: 'Backpack', description: 'holds a laser' }, 'laser'));

check('filter narrows a list', Picker.filter([skill, { name: 'Swimming', category: 'Physical' }], 'wilder').length === 1);
check('filter returns everything for a blank query', Picker.filter([skill, { name: 'Swimming' }], '').length === 2);
check('filter tolerates missing fields and empty input',
  Picker.filter([{ name: 'Nameless' }, {}], 'nameless').length === 1 && Picker.filter(undefined, 'x').length === 0);

// The count is what tells you whether an empty list means "no match" or
// "nothing in the catalog".
const html = Picker.inputHtml({ id: 'x-filter', value: 'a "quoted" value', shown: 3, total: 99 });
check('the input renders its count', html.includes('3 of 99'));
check('the input escapes quotes in its value', html.includes('&quot;quoted&quot;') && !html.includes('"quoted"'));
check('the count is omitted when there is no total', !Picker.inputHtml({ id: 'y' }).includes('pick-count'));

// ---------- 1c15. Pool formulas ----------
// Every one of these is a real formula from a sourcebook. Three of the five
// returned NULL before, which meant a character imported from that class was
// created with no hit points, no P.P.E. and no I.S.P. at all.
section('Pool formulas');
{
  const attrs = { PE: 10, ME: 20 };
  const r = (f) => rollPoolFormula(f, attrs);
  const between = (v, lo, hi) => typeof v === 'number' && v >= lo && v <= hi;

  check('plain dice', between(r('4D6x100'), 400, 2400));
  check('a plain number is taken as-is', r('20') === 20);
  check('attribute then dice', between(r('P.E. + 1d6 per level'), 11, 16));
  // The order books actually use as often as the other, and the one that used
  // to fall through to null.
  check('dice then attribute', between(r('2D4x100+200 plus P.E. attribute number'), 410, 1010));
  check('dice then a different attribute', between(r('3D4x10 + M.E. attribute number'), 50, 140));
  // Books qualify these heavily; the leading figure is the one they lead with.
  check('dice leading a qualified sentence',
    between(r('3D4x100+1000 when in natural serpent form (only 3D4x100 when in humanoid form)'), 1300, 2200));

  check('no numbers at all stays null', r('varies by GM ruling') === null);
  check('null and undefined stay null', r(null) === null && r(undefined) === null);
  // A number the formula cannot supply must not be invented from a missing
  // attribute — the bonus is skipped, not treated as zero silently.
  check('an attribute the character lacks falls back to the dice alone',
    between(rollPoolFormula('2D4x10 plus P.E. attribute number', {}), 20, 80));

  // An attribute the book MULTIPLIES. Supernatural and mega-damage races state
  // their pools this way as a matter of course, and the Godling R.C.C. is
  // written entirely in it. Both failure modes were live: a formula that is
  // only a multiplied attribute returned null, and one with dice as well
  // silently DROPPED the multiplier — "P.E. x 3 plus 2D6" rolled P.E. + 2D6,
  // a third of the right number and completely plausible-looking.
  check('a multiplied attribute alone', r('P.E. x 10') === 100);
  check('spelled with the word "number"', r('P.E. number x 10') === 100);
  check('spelled with a multiplication sign', r('P.E. × 10') === 100);
  check('a multiplied attribute plus dice', between(r('P.E. x 3 plus 2D6 per level'), 32, 42));
  check('and the multiplier is not dropped', r('P.E. x 3 plus 2D6 per level') > 30);
  check('base and per-level growth together', between(r('P.E. x 10, plus 1D4x10 per level'), 110, 140));

  // The other half of the same rule: an `x N` that belongs to the DICE must not
  // be read as multiplying the attribute. M.E. is 20 here, so mistaking the x10
  // for the attribute's would put these an order of magnitude out.
  check('a dice multiplier stays with the dice',
    between(r('M.E. number plus 1D6x10'), 30, 80));
  check('even when the dice lead', between(r('4D6x10 plus the M.E. number'), 60, 260));
}

// ---------- 1c16. An R.C.C. and an O.C.C. together ----------
// Palladium characters routinely have both, and the two contribute different
// halves: the race sets the body, the occupation sets what was learned. They
// are composed into ONE class-shaped object so nothing downstream has to know.
section('R.C.C. + O.C.C.');
{
  const mk = (id, cat, extra) => parseClassMarkdown(
    `---
id: ${id}
name: ${id}
system: palladium-fantasy
source_book: B
category: ${cat}
${extra}
---

## Lore

x
`).data;

  const dragon = mk('dragon', 'rcc', [
    "attribute_dice: { PS: '3d6+12' }",
    'attribute_requirements: { PE: 12 }',
    "mdc_base: '1d4x100'",
    'psionics: { type: major, isp_base: "3d4x10" }',
    'bonuses:',
    '  combat: { parry: 2 }',
    'skills:',
    '  occ_skills:',
    '    - { name: "Wilderness Survival", base: 30 }',
    '    - { choose: 3, categories: ["Science"] }',
  ].join('\n'));

  const wizard = mk('wizard', 'occ', [
    'attribute_requirements: { IQ: 10, PE: 14 }',
    'hit_points_base: "P.E. + 1d6 per level"',
    'psionics: { type: minor, isp_base: "2d6" }',
    'magic: { type: wizardry, spells_starting: 8 }',
    'bonuses:',
    '  combat: { parry: 1, strike: 1 }',
    'skills:',
    '  occ_skills:',
    '    - { name: "Wilderness Survival", base: 45 }',
    '    - { name: "Lore: Magic", base: 40 }',
    '    - { choose: 3, categories: ["Technical"] }',
    '  occ_related_skills: { count: 6, categories: ["Science"] }',
    '  secondary_skills: { count: 4 }',
  ].join('\n'));

  const both = combineClasses(dragon, wizard);

  // Physiology is the race's. An M.D.C. creature must not pick up the O.C.C.'s
  // hit points, or a dragon wizard out-lives the book's dragon.
  check('the race sets the dice and pools', both.attribute_dice.PS === '3d6+12' && both.mdc_base === '1d4x100');
  check('an M.D.C. race does not take the O.C.C. hit points', both.hit_points_base === undefined);
  // But a race that simply omits a pool is not making a statement about it.
  const elf = mk('elf', 'rcc', "attribute_dice: { PS: '3d6' }");
  check('a race with no pools inherits the occupation\'s',
    combineClasses(elf, wizard).hit_points_base === 'P.E. + 1d6 per level');

  check('both sets of minimums apply, the stricter winning',
    both.attribute_requirements.PE === 14 && both.attribute_requirements.IQ === 10);

  // The whole reason this exists: a racial class grants no related or secondary
  // skills, so without an O.C.C. a character has none at all.
  check('related and secondary allowances come from the occupation',
    both.skills.occ_related_skills.count === 6 && both.skills.secondary_skills.count === 4);
  check('an R.C.C. alone still grants none', combineClasses(dragon, null).skills.occ_related_skills === undefined);

  // Two classes commonly overlap; holding the same skill twice fails validation.
  const named = both.skills.occ_skills.filter((x) => x.name).map((x) => x.name);
  check('a skill both classes grant is held once', named.filter((n) => n === 'Wilderness Survival').length === 1);
  check('the higher base wins when they overlap',
    both.skills.occ_skills.find((x) => x.name === 'Wilderness Survival').base === 45);
  // A choice-group has no identity to match on, so two groups stay two.
  check('choice groups are not collapsed',
    both.skills.occ_skills.filter((x) => !x.name).length === 2);

  check('bonuses from both classes sum', both.bonuses.combat.parry === 3 && both.bonuses.combat.strike === 1);
  check('the stronger psychic tier wins', both.psionics.type === 'major');
  check('magic comes from the occupation', both.magic.type === 'wizardry');
  check('the identity stays the race', both.id === 'dragon' && both.occ_id === 'wizard');

  // Every caller composes unconditionally, so the no-O.C.C. paths matter most.
  check('no occupation returns the race unchanged', combineClasses(dragon, null) === dragon);
  check('no race returns the occupation', combineClasses(null, wizard) === wizard);
  check('neither returns null', combineClasses(null, null) === null);
}

// ---------- 1c17. The attribute bonus chart ----------
// Transcribed from Palladium Fantasy RPG 2nd Ed. p.16. These assert the PRINTED
// numbers, not a formula — the whole point is that the rows disagree with each
// other, which is what the old single `v - 15` got wrong.
section('Attribute bonus chart');
{
  const combatAt = (attr, v) => D.combat({ [attr]: v }, null);
  const savesAt = (attr, v) => D.saves({ [attr]: v }, null);
  const bioAt = (attr, v) => D.bio({ [attr]: v }, null);

  // Each entry: attribute value -> printed value. Sampled across the row rather
  // than exhaustively, including both ends and the irregular steps in between.
  const rowCheck = (label, read, expected) => {
    const wrong = Object.entries(expected)
      .filter(([v, want]) => read(Number(v)) !== want)
      .map(([v, want]) => `${v}→${read(Number(v))} (book ${want})`);
    check(label, wrong.length === 0, wrong.join(', '));
  };

  rowCheck('P.S. damage matches the book', (v) => combatAt('PS', v).damage_bonus,
    { 15: 0, 16: 1, 18: 3, 24: 9, 30: 15 });
  // The row that was roughly doubled: +1 per TWO points, not per point.
  rowCheck('P.P. strike matches the book', (v) => combatAt('PP', v).strike,
    { 15: 0, 16: 1, 17: 1, 18: 2, 19: 2, 20: 3, 24: 5, 29: 7, 30: 8 });
  rowCheck('P.P. parry matches the book', (v) => combatAt('PP', v).parry,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  rowCheck('P.P. dodge matches the book', (v) => combatAt('PP', v).dodge,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  rowCheck('M.E. save vs psionic attack matches the book', (v) => savesAt('ME', v).psionics,
    { 15: 0, 16: 1, 18: 2, 24: 5, 30: 8 });
  // Insanity is halved only to 19, then gains a point per point — the one row
  // that changes its own step partway along.
  rowCheck('M.E. save vs insanity matches the book', (v) => savesAt('ME', v).insanity,
    { 16: 1, 17: 1, 18: 2, 19: 2, 20: 3, 21: 4, 25: 8, 30: 13 });
  rowCheck('P.E. save vs magic/poison matches the book', (v) => savesAt('PE', v).spell_magic,
    { 16: 1, 18: 2, 24: 5, 30: 8 });
  // The old `pe * 2` was right from 18 up and wrong at both 16 and 17.
  rowCheck('P.E. save vs coma/death matches the book', (v) => savesAt('PE', v).coma_death_pct,
    { 15: 0, 16: 4, 17: 5, 18: 6, 19: 8, 24: 18, 30: 30 });
  rowCheck('M.A. trust/intimidate matches the book', (v) => bioAt('MA', v).invoke_trust_pct,
    { 15: 0, 16: 40, 20: 60, 24: 80, 25: 84, 27: 92, 30: 97 });
  rowCheck('P.B. charm/impress matches the book', (v) => bioAt('PB', v).charm_impress_pct,
    { 15: 0, 16: 30, 20: 50, 26: 80, 27: 83, 29: 90, 30: 92 });
  rowCheck('I.Q. skill bonus matches the book', (v) => bioAt('IQ', v).iq_skill_bonus_pct,
    { 15: 0, 16: 2, 18: 4, 24: 10, 30: 16 });

  // Below the chart nothing is granted at all — 15 is not "one less than 16".
  check('an attribute under 16 grants nothing anywhere', (() => {
    const c = D.combat({ PS: 15, PP: 15, Spd: 0 }, null);
    const s = D.saves({ PE: 3, ME: 3 }, null);
    const b = D.bio({ MA: 15, PB: 15, IQ: 15 }, null);
    return c.strike === 0 && c.parry === 0 && c.damage_bonus === 0
      && s.spell_magic === 0 && s.insanity === 0 && s.coma_death_pct === 0
      && b.invoke_trust_pct === 0 && b.charm_impress_pct === 0 && b.iq_skill_bonus_pct === 0;
  })());

  // Above 30 the book stops and dragons do not: each row continues the step it
  // ends on. House rule, asserted so it cannot drift silently.
  check('rows continue past 30 on the step they end on', (() => {
    const pp = (v) => D.combat({ PP: v }, null).parry;
    const pe = (v) => D.saves({ PE: v }, null).coma_death_pct;
    const ps = (v) => D.combat({ PS: v }, null).damage_bonus;
    // +1 per two points, so 31 is still 8 and 32 steps to 9.
    return pp(31) === 8 && pp(32) === 9 && pp(34) === 10
      && pe(31) === 32 && pe(32) === 34
      && ps(31) === 16 && ps(40) === 25;
  })());

  // The bug that made a P.B. 30 character charm literally everyone.
  check('the percentile rows stop at 98%, never 100', (() => {
    const ma = (v) => D.bio({ MA: v }, null).invoke_trust_pct;
    const pb = (v) => D.bio({ PB: v }, null).charm_impress_pct;
    return ma(30) === 97 && ma(31) === 98 && ma(50) === 98
      && pb(30) === 92 && pb(33) === 98 && pb(99) === 98;
  })());

  // The flat rows are bonuses added to a roll, not percentages, so the 98 cap
  // must not reach them — a P.S. 200 dragon keeps scaling.
  check('the flat bonus rows are not capped', D.combat({ PS: 200 }, null).damage_bonus > 98);

  // Class bonuses and stored overrides are layered on top of the chart, not
  // instead of it, and that plumbing is unchanged by the new tables.
  check('a class attribute bonus is read against the chart, not around it', (() => {
    // P.P. 17 alone is +1; the class's +1 makes it 18, which the book puts at +2.
    const bonuses = { attributes: { PP: 1 }, combat: {}, saves: {} };
    return D.combat({ PP: 17 }, null, bonuses).parry === 2;
  })());
  check('a stored value still wins over the chart',
    D.combat({ PP: 30 }, { parry: 1 }).parry === 1);
  check('parts() splits chart and class contributions', (() => {
    const p = D.parts('combat', { PP: 17 }, { attributes: { PP: 1 }, combat: { parry: 3 } });
    return p.parry.attrs === 1 && p.parry.from_class === 4; // +1 via attribute, +3 direct
  })());
}

// ---------- 1c18. Exceptional attribute rolls ----------
// Palladium Fantasy 2nd Ed. p.14. Randomness is stubbed so these assert the
// rule rather than a distribution — an exceptional roll is rare enough that a
// statistical test would be both slow and flaky.
section('Exceptional attribute rolls');
{
  // d(sides) is 1 + floor(random * sides), so (face - 1) / 6 forces `face` on a
  // six-sided die. Every attribute pool here is d6; nothing else is exercised.
  const withFaces = (faces, fn) => {
    const real = Math.random;
    let i = 0;
    Math.random = () => (faces[i++] - 1) / 6 + 1e-9;
    try { return fn(); } finally { Math.random = real; }
  };
  const roll = (expr, faces) => withFaces(faces, () => rollAttribute(expr));

  check('3d6 under 16 earns no extra die', (() => {
    const r = roll('3d6', [5, 5, 5]);
    return r.total === 15 && r.exceptional.length === 0;
  })());
  check('3d6 at exactly 16 earns one extra die', (() => {
    const r = roll('3d6', [5, 5, 6, 3]);
    return r.base === 16 && r.exceptional.join() === '3' && r.total === 19;
  })());
  check('3d6 at 18 earns one extra die', (() => {
    const r = roll('3d6', [6, 6, 6, 2]);
    return r.base === 18 && r.total === 20;
  })());
  // "If a six is rolled ... roll 1D6 again, and add that number also."
  check('a six on the extra die earns one more', (() => {
    const r = roll('3d6', [6, 6, 6, 6, 4]);
    return r.exceptional.join() === '6,4' && r.total === 28;
  })());
  // "However, even if this last roll is a six, the player does not roll again."
  check('the chain stops at two, even on a second six', (() => {
    const r = roll('3d6', [6, 6, 6, 6, 6, 6]);
    return r.exceptional.join() === '6,6' && r.total === 30;
  })());

  check('2d6 earns its extra die only on a 12', (() => {
    const hit = roll('2d6', [6, 6, 2]);
    const miss = roll('2d6', [6, 5]);
    return hit.base === 12 && hit.total === 14 && miss.total === 11 && miss.exceptional.length === 0;
  })());

  // Named exclusion: "Characters that get to roll four, five or even six,
  // six-sided dice for an attribute do not get any additional dice rolls even
  // if the rolls are exceptional."
  check('4d6 and above never earn an extra die', (() => {
    const four = roll('4d6', [6, 6, 6, 6]);
    const six = roll('6d6', [6, 6, 6, 6, 6, 6]);
    return four.total === 24 && four.exceptional.length === 0
      && six.total === 36 && six.exceptional.length === 0;
  })());

  // The threshold reads the dice, not the total: a flat racial bonus must not
  // buy an exceptional roll that the dice did not earn.
  check('a racial modifier does not trigger the threshold', (() => {
    const r = roll('3d6+6', [3, 3, 4]);
    return r.base === 10 && r.modifier === 6 && r.total === 16 && r.exceptional.length === 0;
  })());
  check('a racial modifier still stacks on a genuine exceptional roll', (() => {
    const r = roll('3d6+6', [5, 5, 6, 2]);
    return r.base === 16 && r.modifier === 6 && r.total === 24;
  })());

  // A multiplied pool is a hit-point formula, not an attribute.
  check('a multiplied pool earns nothing', roll('1d6x10', [6]).exceptional.length === 0);

  // The bug this replaced: stating 3d6 explicitly took a branch that skipped
  // the bonus die, so the same dice produced different characters depending on
  // whether the class bothered to write them down.
  check('an explicit 3d6 behaves exactly like the default', (() => {
    const stated = roll('3d6', [6, 6, 6, 4]);
    const implied = roll('', [6, 6, 6, 4]);
    return stated.total === implied.total && implied.total === 22;
  })());
  check('an unparseable expression falls back to 3d6',
    roll('two handfuls', [4, 4, 4]).total === 12);
}

// ---------- 1c19. Skill percentages ----------
// The I.Q. bonus is a ONE-TIME addition to every skill percentage (p.22), and
// secondary skills advance per level even though they get no O.C.C. bonus.
section('Skill percentages');
{
  // skillsPayload() lives inside the wizard module and depends on wizard state,
  // so the rule it applies is restated here against the same derive call the
  // wizard makes. What is pinned is the arithmetic and the cap.
  const CAP = 98;
  const iqOf = (iq) => D.bio({ IQ: iq }, null).iq_skill_bonus_pct || 0;
  const apply = (pct, iq) => (!pct ? { pct, iq_bonus: 0 }
    : { pct: Math.min(CAP, pct + iqOf(iq)), iq_bonus: iqOf(iq) });

  check('an average I.Q. adds nothing', (() => {
    const r = apply(35, 12);
    return r.pct === 35 && r.iq_bonus === 0;
  })());
  check('I.Q. 16 adds its printed 2%', apply(35, 16).pct === 37);
  check('I.Q. 18 adds its printed 4%', apply(35, 18).pct === 39);
  check('I.Q. 30 adds its printed 16%', apply(35, 30).pct === 51);

  // A W.P. or hand to hand has no percentage to modify; inventing one would
  // imply a roll the skill does not have.
  check('a non-percentile skill stays at zero', (() => {
    const r = apply(0, 30);
    return r.pct === 0 && r.iq_bonus === 0;
  })());

  // The cap matters now in a way it did not before: a high base plus a large
  // I.Q. bonus is the first thing at creation that can exceed 98.
  check('the I.Q. bonus cannot push a skill past 98%', (() => {
    const r = apply(90, 30);           // 90 + 16 = 106
    return r.pct === CAP && r.iq_bonus === 16;
  })());
  check('a skill already at the cap stays there', apply(98, 24).pct === CAP);

  // The bonus is recorded, not just folded in, so 39% is distinguishable from a
  // skill whose base genuinely is 39.
  check('the bonus is recorded alongside the total', apply(35, 18).iq_bonus === 4);

  // Secondary skills carry a real per-level step now, so the level-up flow
  // advances them. Previously the wizard wrote 0 and they were frozen for life.
  check('a secondary skill with a per-level step advances', (() => {
    const cls = { skills: {} };
    const character = { level: 1, skills: [
      { name: 'Fishing', type: 'secondary', pct: 29, per_level: 5 },
      { name: 'W.P. Sword', type: 'occ', pct: 0, per_level: 0 },
    ] };
    const p = buildProposal(character, cls, 3);
    const fishing = p.skills.find((s) => s.name === 'Fishing');
    return fishing && fishing.from === 29 && fishing.to === 39   // two levels × +5
      && !p.skills.some((s) => s.name === 'W.P. Sword');
  })());
  check('level-up still respects the 98% cap', (() => {
    const character = { level: 1, skills: [{ name: 'Prowl', type: 'occ', pct: 95, per_level: 5 }] };
    return buildProposal(character, { skills: {} }, 4).skills[0].to === CAP;
  })());
}

// ---------- 1c20. Alignments ----------
// p.23: seven alignments in three groups, and deliberately no neutral.
section('Alignments');
{
  const rulesGlobal = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'rules.js'), 'utf8'))
    .call(rulesGlobal, rulesGlobal);
  const R = rulesGlobal.rules;

  check('rules.js exposes the alignment helpers',
    !!R && Array.isArray(R.ALIGNMENTS) && typeof R.alignmentOptions === 'function');
  check('there are exactly seven alignments', R.ALIGNMENTS.length === 7, R.ALIGNMENTS.join(', '));
  check('all seven are the book\'s', (() => {
    const want = ['Principled', 'Scrupulous', 'Unprincipled', 'Anarchist',
                  'Miscreant', 'Aberrant', 'Diabolic'];
    return want.every((a) => R.ALIGNMENTS.includes(a)) && R.ALIGNMENTS.length === want.length;
  })());
  check('they fall into Good, Selfish and Evil',
    R.ALIGNMENT_GROUPS.map(([g]) => g).join(',') === 'Good,Selfish,Evil');
  check('each alignment reports its group',
    R.alignmentGroup('Principled') === 'Good' && R.alignmentGroup('Anarchist') === 'Selfish'
    && R.alignmentGroup('Diabolic') === 'Evil');

  // The book rules neutral out by name, in a paragraph explaining why. If it
  // ever appears in this list, something has widened it by accident.
  check('there is no neutral', !R.ALIGNMENTS.some((a) => /neutral/i.test(a))
    && !R.isAlignment('Neutral') && R.alignmentGroup('Neutral') === null);

  check('an unknown value is not an alignment',
    !R.isAlignment('') && !R.isAlignment('Lawful Good') && R.alignmentGroup('Lawful Good') === null);

  // Rendering a character that predates the list must not be a way to erase
  // what it had — the old value survives as its own selected option.
  check('a legacy value is preserved as an option', (() => {
    const html = R.alignmentOptions('Chaotic Neutral');
    return html.includes('Chaotic Neutral') && /Chaotic Neutral[^<]*<\/option>/.test(html)
      && html.includes('not a standard alignment');
  })());
  check('a known value is selected without a legacy option', (() => {
    const html = R.alignmentOptions('Aberrant');
    return html.includes('<option value="Aberrant" selected>') && !html.includes('not a standard alignment');
  })());
  check('an empty value selects the placeholder',
    R.alignmentOptions('').includes('<option value="" selected>'));
  check('options are grouped for the picker', (() => {
    const html = R.alignmentOptions('');
    return (html.match(/<optgroup/g) || []).length === 3;
  })());
  // The legacy value goes through an attribute, so it has to be escaped.
  check('a legacy value is escaped', !R.alignmentOptions('"><script>').includes('<script>'));

  // The sheet reads edited fields out of the DOM by selector. Alignment is the
  // first <select> among them, and matching only inputs would drop it silently.
  check('the sheet collects selects, not just inputs', (() => {
    const src = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    return /querySelectorAll\('input\[data-sec\], select\[data-sec\]'\)/.test(src);
  })());
  // Both pages must actually load the shared list.
  check('both pages load rules.js', ['index.html', 'sheet.html'].every((f) =>
    readFileSync(join(appDir, f), 'utf8').includes('js/rules.js')));

  // ── starting money (p.22) ──
  check('currency is named per system',
    R.currencyLabel('palladium-fantasy') === 'Gold' && R.currencyLabel('rifts') === 'Credits');
  // An unknown system must not be guessed into one of the two.
  check('an unknown system gets the neutral word',
    R.currencyLabel('mystic-china') === 'Money' && R.currencyLabel(null) === 'Money'
    && R.currencyLabel(undefined) === 'Money');

  check('starting money rolls from a formula like a pool', (() => {
    const v = rollPoolFormula('2d6x10', {});
    return typeof v === 'number' && v >= 20 && v <= 120;
  })());
  check('a flat starting sum is taken as written', rollPoolFormula(500, {}) === 500);
  // A class that says nothing about money must not conjure a zero purse.
  check('no starting money stays absent',
    rollPoolFormula(null, {}) === null && rollPoolFormula(undefined, {}) === null);

  // The importer only ever returns fields the prompt names — the reason a whole
  // stat block went missing when `variants` shipped undocumented.
  check('the class import prompt documents starting_money', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'extraction-prompt.js'), 'utf8');
    return src.includes('starting_money');
  })());
  check('the hand-authoring templates show starting_money', (() => {
    const src = readFileSync(join(appDir, 'js', 'class-template.js'), 'utf8');
    return (src.match(/starting_money/g) || []).length >= 2;   // O.C.C. and R.C.C.
  })());
}

// ---------- 1c21. Starting money through the class layers ----------
// It has to survive both composition steps, or a dual-class or staged character
// silently starts penniless.
section('Starting money');
{
  const mk = (id, cat, extra) => parseClassMarkdown(
    `---\nid: ${id}\nname: ${id}\nsystem: palladium-fantasy\nsource_book: B\ncategory: ${cat}\n${extra}\n---\n\n## Lore\n\nx\n`).data;

  const dragon = mk('dragon', 'rcc', 'mdc_base: "1d4x100"');
  const bowman = mk('bowman', 'occ', 'hit_points_base: "P.E. + 1d6 per level"\nstarting_money: "2d6x10"');
  const richRace = mk('noble', 'rcc', 'starting_money: 900');

  // A race that says nothing about money takes the occupation's, exactly as the
  // pools do — otherwise every R.C.C. character starts with an empty purse.
  check('a race with no money takes the occupation\'s',
    combineClasses(dragon, bowman).starting_money === '2d6x10');
  // Where the race DOES state a sum, it is the race's own creature and wins.
  check('a race that states money keeps its own',
    combineClasses(richRace, bowman).starting_money === 900);
  check('an occupation with no money leaves the race\'s intact',
    combineClasses(richRace, mk('monk', 'occ', 'sdc_base: 20')).starting_money === 900);
  check('neither stating money leaves it absent',
    combineClasses(dragon, mk('monk', 'occ', 'sdc_base: 20')).starting_money === undefined);

  // A stage of a creature may be richer than another — a variant can restate it.
  const staged = mk('wyrm', 'rcc', `starting_money: 100
variants:
  - { id: hatchling, name: "Wyrm Hatchling" }
  - { id: adult, name: "Wyrm Adult", starting_money: 5000 }`);
  check('a variant may override starting money',
    applyVariant(staged, 'adult').starting_money === 5000);
  check('a variant that is silent inherits it',
    applyVariant(staged, 'hatchling').starting_money === 100);
}

// ---------- 1c22. Random psionics ----------
// Step 3, p.20-21. The table, the tiers it can reach, and how a rolled tier is
// folded into the class-shaped object everything downstream reads.
section('Random psionics');
{
  check('the table is the book\'s ranges', (() => {
    const t = (n) => psionicTierForRoll(n);
    return t(1) === 'major' && t(9) === 'major'
      && t(10) === 'minor' && t(25) === 'minor'
      && t(26) === null && t(100) === null;
  })());
  // 26-00 is the bulk of the table; a roll landing there is the ordinary result.
  check('most of the table is no psionics',
    Array.from({ length: 100 }, (_, i) => psionicTierForRoll(i + 1)).filter((x) => x === null).length === 75);
  check('a roll outside 1-100 yields nothing rather than guessing',
    psionicTierForRoll(0) === null && psionicTierForRoll(101) === null
    && psionicTierForRoll('x') === null && psionicTierForRoll(null) === null);
  // "A master psionic ... is available only from one of the psychic character
  // classes." Rolling must never reach it.
  check('rolling can never produce a master psionic',
    !Array.from({ length: 100 }, (_, i) => psionicTierForRoll(i + 1)).includes('master'));
  check('rollPsionics stays inside the table', (() => {
    for (let i = 0; i < 200; i++) {
      const r = rollPsionics();
      if (r.roll < 1 || r.roll > 100) return false;
      if (r.tier !== psionicTierForRoll(r.roll)) return false;
    }
    return true;
  })());

  // The shapes the book offers each tier.
  check('a minor psychic takes 2 powers from one category', (() => {
    const s = psionicShape('minor', 'focused');
    return s.count === 2 && s.categories === 1;
  })());
  check('a major psychic can take 8 from one or 6 from any', (() => {
    const f = psionicShape('major', 'focused'), b = psionicShape('major', 'broad');
    return f.count === 8 && f.categories === 1 && b.count === 6 && b.categories === 3;
  })());
  check('an unknown shape falls back to the tier\'s first',
    psionicShape('major', 'nonsense').id === 'focused' && psionicShape('minor', null).id === 'focused');
  check('a tier that cannot be rolled has no shapes', psionicShape('master', 'focused') === null);

  // I.S.P. formulas, including the per-level clause the level-up flow parses.
  check('minor I.S.P. is M.E. + 2d6, growing 1d6 a level', (() => {
    const f = PSIONIC_TIER_RULES.minor.isp_base;
    return /M\.E\./.test(f) && /2d6/.test(f) && perLevelDiceOf(f) === '1d6';
  })());
  // The +1 is the part that used to be dropped: matching only the dice cost a
  // major psychic a point of I.S.P. at every level, for life.
  check('major I.S.P. is M.E. + 4d6, growing 1d6+1 a level', (() => {
    const f = PSIONIC_TIER_RULES.major.isp_base;
    return /4d6/.test(f) && perLevelDiceOf(f) === '1d6+1';
  })());
  check('a per-level modifier survives into the roll', (() => {
    const v = evalDice('1d6+1');
    return v >= 2 && v <= 7;
  })());

  // Folding a rolled tier into the class object.
  const plain = { id: 'bowman', name: 'Bowman' };
  check('a character with no roll is untouched',
    withRolledPsionics(plain, { psychic_tier: null }) === plain);
  check('a rolled tier becomes a psionics block', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'major', psychic_shape: 'broad' });
    return c.psionics.type === 'major' && c.psionics.powers_starting === 6
      && c.psionics.from_roll === true;
  })());
  check('the focused shape grants its larger count', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'major', psychic_shape: 'focused' });
    return c.psionics.powers_starting === 8;
  })());
  // Rolled psychics draw from three categories; Super is master-only.
  check('a rolled psychic cannot reach Super powers', (() => {
    const c = withRolledPsionics(plain, { psychic_tier: 'minor' });
    return !c.psionics.categories_allowed.includes('Super')
      && c.psionics.categories_allowed.length === 3;
  })());
  // A psychic O.C.C. has already answered the question and never rolls.
  check('a class that grants psionics is not overwritten', (() => {
    const mage = { id: 'mind-mage', psionics: { type: 'master', isp_base: '3d6' } };
    const c = withRolledPsionics(mage, { psychic_tier: 'minor' });
    return c === mage && c.psionics.type === 'master';
  })());
  check('an unrecognised tier is ignored',
    withRolledPsionics(plain, { psychic_tier: 'master' }) === plain
    && withRolledPsionics(plain, { psychic_tier: 'wizardly' }) === plain);

  // The create endpoint gained two columns. A miscounted placeholder list is a
  // runtime error on the first save and invisible until then.
  check('the character INSERT binds exactly what it declares', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      'characters.js'), 'utf8');
    const i = src.indexOf('INSERT INTO characters');
    const end = src.indexOf('RETURNING id', i);
    const seg = src.slice(i, end);
    const cols = seg.slice(seg.indexOf('(') + 1, seg.indexOf(')')).split(',').map((s) => s.trim()).filter(Boolean);
    let v = seg.slice(seg.indexOf('VALUES') + 6);
    v = v.slice(v.indexOf('(') + 1, v.lastIndexOf(')'));
    const slots = v.split(',').map((s) => s.trim()).filter(Boolean);
    const placeholders = slots.filter((s) => s === '?').length;
    // Bind arguments, split at depth zero so nested calls do not miscount.
    const bt = src.slice(src.indexOf('.bind(', end) + 6, src.indexOf('.first()', end));
    let depth = 0, cur = '', args = [];
    for (const ch of bt) {
      if ('([{'.includes(ch)) depth++;
      if (')]}'.includes(ch)) depth--;
      if (ch === ',' && depth === 0) { args.push(cur.trim()); cur = ''; } else cur += ch;
    }
    if (cur.trim()) args.push(cur.trim());
    args = args.filter(Boolean);
    return cols.length === slots.length && placeholders === args.length;
  })());
}

// ---------- 1c23. Keys a class can actually grant ----------
// A bonus written for a key derive does not expose is silently inert: it parses,
// it stores, it renders nowhere. Three real class bonuses sat as prose for
// exactly that reason before these keys existed.
section('Bonus keys');
{
  const combat = D.combat({ PS: 10, PP: 10 }, null);
  const saves = D.saves({ PE: 10, ME: 10 }, null);

  check('pull punch is a combat key', 'pull_punch' in combat);
  check('the illusionary magic and mind control saves exist',
    'illusionary_magic' in saves && 'mind_control' in saves);

  // Pull punch is in the Hand to Hand tables, not on the attribute chart: it is
  // trained, not innate, so no attribute moves it.
  check('pull punch derives nothing from attributes', (() => {
    const low = D.combat({ PS: 3, PP: 3 }, null).pull_punch;
    const high = D.combat({ PS: 30, PP: 30 }, null).pull_punch;
    return low === 0 && high === 0;
  })());
  // The two saves borrow the printed row for their own attribute.
  check('illusionary magic follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).illusionary_magic === 0 && s(18).illusionary_magic === s(18).spell_magic
      && s(30).illusionary_magic === 8;
  })());
  check('mind control follows the M.E. psionic row', (() => {
    const s = (me) => D.saves({ ME: me }, null);
    return s(15).mind_control === 0 && s(18).mind_control === s(18).psionics
      && s(30).mind_control === 8;
  })());

  // The point of the exercise: a class bonus for each now reaches the sheet.
  check('a class can grant all three', (() => {
    const bonuses = { attributes: {}, combat: { pull_punch: 2 },
                      saves: { illusionary_magic: 3, mind_control: 6 } };
    const c = D.combat({ PS: 10 }, null, bonuses);
    const s = D.saves({ PE: 10, ME: 10 }, null, null, bonuses);
    return c.pull_punch === 2 && s.illusionary_magic === 3 && s.mind_control === 6;
  })());

  // The sheet has to list them, or the value is computed and never shown.
  check('the sheet prints all three', (() => {
    const src = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    return ['pull_punch', 'illusionary_magic', 'mind_control'].every((k) => src.includes(`'${k}'`));
  })());

  // Guard scripts: `_` is a single-character WILDCARD in a LIKE pattern, so
  // '%mind_control%' also matches the words "mind control". A guard written that
  // way silently matches nothing and the migration does nothing.
  check('no data script guards an underscored key with LIKE', (() => {
    const dir = join(appDir, 'db');
    const bad = [];
    for (const f of readdirSync(dir).filter((x) => x.endsWith('.sql'))) {
      const src = readFileSync(join(dir, f), 'utf8');
      // Any LIKE pattern containing an underscore, including one built by
      // concatenation -- '%item_id: "' || slug || '"%' has the same hazard.
      for (const m of src.matchAll(/LIKE\s+('[^']*_[^']*')/gi)) bad.push(`${f}: ${m[1]}`);
    }
    return bad.length === 0;
  })(), 'use instr() instead: ');
}

// ---------- 1c24. Dice-valued attribute bonuses ----------
// A book states some attribute bonuses as a roll: "add 2D6 to P.S." (Juicer),
// "+1D4 to M.A., M.E., P.S., P.E. and Spd" (Cyber-Knight). The dice belong to
// the class; what they came up belongs to the character, because a roll cannot
// be re-evaluated on every render.
section('Dice attribute bonuses');
{
  const mk = (bonuses) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n${bonuses}\n---\n\n## Lore\n\nx\n`);

  check('a dice attribute bonus is accepted', mk('bonuses:\n  attributes: { PS: "2d6" }').ok);
  check('a multiplied dice bonus is accepted', mk('bonuses:\n  attributes: { Spd: "2d4x10" }').ok);
  check('a flat attribute bonus still works', mk('bonuses:\n  attributes: { PS: 2 }').ok);
  check('nonsense is still rejected', (() => {
    const r = mk('bonuses:\n  attributes: { PS: "a lot" }');
    return !r.ok && r.errors.some((e) => /number or a dice expression/.test(e));
  })());
  // Every group takes dice now. Combat and saves were flat-only on the
  // assumption books always print them that way; the Godling's "+1D4 on
  // initiative" is the counter-example, and it was a hard parse error.
  check('a dice bonus is accepted in combat', mk('bonuses:\n  combat: { initiative: "1d4" }').ok);
  check('and in saves', mk('bonuses:\n  saves: { spell_magic: "1d4" }').ok);
  check('prose is still refused there',
    !mk('bonuses:\n  combat: { strike: "a lot" }').ok);

  // An unrolled dice bonus must contribute nothing rather than guess an average.
  const cls = mk('bonuses:\n  attributes: { PS: "2d6", Spd: "2d4x10" }').data;
  check('an unrolled dice bonus contributes nothing', (() => {
    const b = D.classBonuses(cls, 1);
    return (b.attributes.PS ?? 0) === 0 && (b.attributes.Spd ?? 0) === 0;
  })());
  check('the rolled value is what applies', (() => {
    const b = D.classBonuses(cls, 1, { PS: 7, Spd: 40 });
    const eff = D.effective({ PS: 14, Spd: 12 }, b);
    return b.attributes.PS === 7 && eff.PS === 21 && eff.Spd === 52;
  })());
  check('diceBonuses lists what needs rolling', (() => {
    const d = D.diceBonuses(cls);
    return d.PS === '2d6' && d.Spd === '2d4x10' && Object.keys(d).length === 2;
  })());
  check('a class with no dice bonuses needs no roll',
    Object.keys(D.diceBonuses(mk('bonuses:\n  attributes: { PS: 2 }').data)).length === 0);

  // "Minimum P.S. is 22; if lower, adjust up to P.S. 22."
  const floored = mk('bonuses:\n  attributes: { PS: "2d6" }\n  attribute_minimums: { PS: 22 }').data;
  check('a minimum is accepted and parsed', !!floored.bonuses.attribute_minimums);
  check('the floor lifts a low total', (() => {
    const b = D.classBonuses(floored, 1, { PS: 4 });
    return D.effective({ PS: 11 }, b).PS === 22;   // 11 + 4 = 15, floored to 22
  })());
  check('the floor never lowers a high total', (() => {
    const b = D.classBonuses(floored, 1, { PS: 12 });
    return D.effective({ PS: 18 }, b).PS === 30;   // 18 + 12 = 30, above the floor
  })());
  // A floor must not conjure an attribute the character does not have, any more
  // than a bonus does.
  check('a floor on an absent attribute is ignored', (() => {
    const b = D.classBonuses(floored, 1, { PS: 4 });
    return D.effective({ ME: 10 }, b).PS === undefined;
  })());
  check('a bad minimum is rejected',
    !mk('bonuses:\n  attribute_minimums: { PS: "lots" }').ok
    && !mk('bonuses:\n  attribute_minimums: { Wisdom: 12 }').ok);

  // The sheet has to pass the character's rolled values through, or a Juicer's
  // +2D6 P.S. silently contributes nothing there.
  check('the sheet passes rolled bonuses to classBonuses', (() => {
    const src = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    // Grouped now, so a class's DICE combat and save bonuses count on the sheet
    // as well as its attribute ones.
    return /classBonuses\(cls, c\.level, \{/.test(src)
      && /attributes: c\.attribute_bonuses/.test(src)
      && /combat: c\.rolled_bonuses/.test(src)
      && /saves: c\.rolled_bonuses/.test(src);
  })());
}

// ---------- 1c24c. Dice combat and save bonuses ----------
// "+1D4 on initiative" (Godling R.C.C., Rifts Pantheons p.16). Combat and save
// bonuses were flat-only, so this was a hard parse error. They are rolled ONCE
// and stored for the same reason attribute dice are: both are read at render
// time, and a roll re-evaluated per render moves the number under the player.
section('Dice combat and save bonuses');
{
  const mk = (b) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: rcc',
     'bonuses:', b, '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));

  const ok = mk('  combat: { initiative: "1d4", attacks: 1 }');
  check('a dice combat bonus parses beside a flat one',
    ok.errors.length === 0, ok.errors.join('; '));
  check('and keeps both as written',
    ok.data.bonuses.combat.initiative === '1d4' && ok.data.bonuses.combat.attacks === 1);
  check('a dice save bonus parses', mk('  saves: { spell_magic: "1d4" }').errors.length === 0);
  check('prose is still refused',
    mk('  combat: { strike: "a fair bit" }').errors.some((e) => e.includes('must be a number')));

  // Collected per group, so the wizard knows what to roll and store.
  const byGroup = derive.diceBonusesByGroup(ok.data);
  check('the dice are collected under their group', byGroup.combat.initiative === '1d4');
  check('and a FLAT bonus is not collected for rolling',
    byGroup.combat.attacks === undefined);
  check('attributes still come through the same call',
    derive.diceBonusesByGroup(mk('  attributes: { PS: "2d6" }').data).attributes.PS === '2d6');

  // classBonuses counts the ROLLED value, never the expression.
  const rolled = { attributes: {}, combat: { initiative: 3 }, saves: {} };
  check('a rolled dice combat bonus is counted',
    derive.classBonuses(ok.data, 1, rolled).combat.initiative === 3);
  check('and the flat one beside it still counts',
    derive.classBonuses(ok.data, 1, rolled).combat.attacks === 1);
  check('an unrolled dice bonus contributes nothing rather than guessing',
    (derive.classBonuses(ok.data, 1, { attributes: {}, combat: {}, saves: {} }).combat.initiative ?? 0) === 0);

  // The legacy flat shape is what every character saved before this holds.
  const legacy = mk('  attributes: { PS: "2d6" }').data;
  check('a flat attribute map is still understood',
    derive.classBonuses(legacy, 1, { PS: 7 }).attributes.PS === 7);
  check('and a grouped one is told apart from it',
    derive.classBonuses(legacy, 1, { attributes: { PS: 7 }, combat: {}, saves: {} }).attributes.PS === 7);

  // Two classes composing: the same collect-not-drop rule the other groups use.
  const race = mk('  combat: { initiative: "1d4" }').data;
  const occ = parseClassMarkdown(
    ['---', 'id: o', 'name: O', 'system: rifts', 'source_book: b', 'category: occ',
     'bonuses:', '  combat: { initiative: "1d6" }', '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  check('two dice combat bonuses collect rather than one being dropped',
    JSON.stringify(combineClasses(race, occ).bonuses.combat.initiative) === '["1d4","1d6"]',
    JSON.stringify(combineClasses(race, occ).bonuses.combat.initiative));
  check('and both are offered for rolling',
    JSON.stringify(derive.diceBonusesByGroup(combineClasses(race, occ)).combat.initiative) === '["1d4","1d6"]');

  // The wizard stores what it rolled; the sheet reads it back. Pinned as source
  // checks because both are page scripts the test cannot execute.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard rolls the grouped dice bonuses', /diceBonusesByGroup/.test(appSrc));
  // The race's rolls and the occupation's are held apart in state, so what the
  // save sends is the SUM of the two. Sending S.rolledBonuses alone would drop
  // every dice bonus the occupation granted - the same loss combineClasses had
  // to be taught once already.
  check('stores what they came up, both halves',
    /rolled_bonuses: \{ combat: rolled\.combat, saves: rolled\.saves \}/.test(appSrc));
  check('and the attribute bonuses are the summed ones too',
    /attribute_bonuses: rolled\.attributes/.test(appSrc));
  check('rolledAll sums the race and the occupation',
    /attributes: sumRolled\(S\.attrBonuses, S\.occAttrBonuses\)/.test(appSrc));
  check('and keeps them across a draft',
    /'rolledBonuses'/.test(appSrc) && /'occRolledBonuses'/.test(appSrc));
}

// ---------- 1c25. Per-category skill restrictions ----------
// Every book states what a category allows: "Espionage: Escape Artist only",
// "Physical: any except Acrobatics, Gymnastics and Wrestling". We offered each
// category wholesale, so a Long Bowman could take Pick Pockets as Espionage.
section('Category restrictions');
{
  const cats = ['Domestic',
    { name: 'Espionage', only: ['Escape Artist'] },
    { name: 'Physical', except: ['Acrobatics', 'Gymnastics'] }];
  const allows = (name, category) => categoryAllows(cats, { name, category });

  check('an unrestricted category admits anything in it', allows('Cook', 'Domestic'));
  check('a category not listed at all is refused', !allows('Basic Math', 'Science'));
  check('only-lists admit just what they name',
    allows('Escape Artist', 'Espionage') && !allows('Pick Pockets', 'Espionage'));
  check('except-lists admit everything but what they name',
    allows('Climbing', 'Physical') && !allows('Acrobatics', 'Physical') && !allows('Gymnastics', 'Physical'));
  check('matching ignores case and padding',
    categoryAllows(cats, { name: '  escape artist ', category: 'ESPIONAGE' }));
  // An empty or absent list means "any", which is what most classes state.
  check('no list restricts nothing',
    categoryAllows([], { name: 'X', category: 'Y' }) && categoryAllows(null, { name: 'X', category: 'Y' }));

  check('a label says what the restriction is', (() => {
    const l = cats.map(categoryLabel);
    return l[0] === 'Domestic' && l[1] === 'Espionage (Escape Artist only)'
      && l[2] === 'Physical (except Acrobatics, Gymnastics)';
  })());

  const mk = (catsYaml) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  occ_related_skills:\n    count: 2\n    categories:\n${catsYaml}\n---\n\n## Lore\n\nx\n`);

  check('plain strings still parse', mk('      - "Wilderness"').ok);
  check('an object entry parses', mk('      - { name: "Espionage", only: ["Escape Artist"] }').ok);
  check('an object without a name is rejected', !mk('      - { only: ["X"] }').ok);
  check('a non-list only is rejected', !mk('      - { name: "Espionage", only: "Escape Artist" }').ok);
  // "only these, except some of them" is just a shorter only-list; guessing
  // which was meant is worse than refusing.
  check('setting both only and except is rejected', (() => {
    const r = mk('      - { name: "Espionage", only: ["A"], except: ["B"] }');
    return !r.ok && r.errors.some((e) => /both only and except/.test(e));
  })());

  // The picker and the server-side validator must not disagree about what is
  // legal, which is why they share one helper rather than each having a copy.
  check('the wizard filters through the shared helper', (() => {
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return /categoryAllows\(categories, sk\)/.test(src);
  })());
  check('the validator uses the same helper', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'validate-character.js'), 'utf8');
    return src.includes('categoryAllows(allowed,');
  })());
}

// ---------- 1c25b. Restrictions that name nothing ----------
// A category restriction names skills by hand, and `categoryAllows` compares
// literal names. So a name no catalog row has does not fail — an `except`
// excludes NOTHING and the class silently offers a skill the book forbids.
// Found importing the Godling R.C.C.: it bars robots, power armor and
// cybernetics, and the catalog spells those "Robots and Power Armor",
// "Robot Combat: Basic" and "M.D. in Cybernetics", so all three did nothing.
section('Unresolved category restrictions');
{
  const cls = parseClassMarkdown(`---
id: t
name: T
system: rifts
source_book: b
category: rcc
skills:
  occ_related_skills:
    count: 8
    categories:
      - "Physical"
      - { name: "Medical", except: ["Cybernetics"] }
      - { name: "Pilot", except: ["Robot Combat", "Power Armor Combat"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Mechanical", only: ["Locksmith"] }
  secondary_skills:
    count: 5
    categories:
      - { name: "Science", only: ["Astrophysics"] }
---

## Lore

x
`).data;

  const named = restrictionNames(cls);
  check('every named skill in every restriction is collected', named.length === 6,
    `got ${named.length}: ${named.map((n) => n.name).join(', ')}`);
  check('a bare category name contributes nothing',
    !named.some((n) => n.category === 'Physical'));
  check('secondary restrictions are collected too',
    named.some((n) => n.category === 'Science' && n.kind === 'only'));
  check('each carries its category and which kind it is',
    named.every((n) => n.category && (n.kind === 'only' || n.kind === 'except') && n.name));

  // The filter the endpoint applies, with a stand-in catalog.
  const catalogHas = new Set(['computer hacking', 'locksmith', 'astrophysics']);
  const unresolved = named.filter((n) => !catalogHas.has(n.name.toLowerCase()));
  check('the three the catalog spells differently are reported',
    unresolved.length === 3
    && unresolved.every((n) => ['Cybernetics', 'Robot Combat', 'Power Armor Combat'].includes(n.name)),
    unresolved.map((n) => n.name).join(', '));
  check('and the ones that do resolve are not',
    !unresolved.some((n) => ['Computer Hacking', 'Locksmith', 'Astrophysics'].includes(n.name)));

  // The point of reporting it: this is what the unmatched `except` actually does.
  check('an unmatched except really does fail open',
    categoryAllows(cls.skills.occ_related_skills.categories,
      { name: 'M.D. in Cybernetics', category: 'Medical' }) === true);
  // While `only` fails closed, which is why the two are labelled differently.
  check('while an unmatched only fails closed',
    categoryAllows(cls.skills.secondary_skills.categories,
      { name: 'Astronomy', category: 'Science' }) === false);

  check('a class with no restrictions collects nothing',
    restrictionNames({ skills: { occ_related_skills: { categories: ['Physical'] } } }).length === 0);
  check('and nothing at all does not throw', restrictionNames(undefined).length === 0);
}

// ---------- 1c24b. Composing dice attribute bonuses ----------
// `sumBonusGroups` copied the second class's values only when they were numbers,
// so a dice-valued bonus arriving from the OCCUPATION was silently dropped: an
// R.C.C. composed with the Cyber-Knight lost all five of its +1D4s and nothing
// said so. Two dice cannot be summed into one expression, so they collect.
section('Composing dice attribute bonuses');
{
  const mk = (cat, b) => parseClassMarkdown(
    `---
id: ${cat}
name: ${cat}
system: rifts
source_book: b
category: ${cat}
bonuses:
${b}
---

## Lore

x
`).data;
  const merged = (a, b, attr) => combineClasses(mk('rcc', a), mk('occ', b)).bonuses.attributes[attr];

  check('a dice bonus from the OCCUPATION survives',
    merged('  combat: { attacks: 1 }', '  attributes: { PS: "1d4" }', 'PS') === '1d4');
  check('a dice bonus from the RACE still survives',
    merged('  attributes: { PS: "1d4" }', '  combat: { attacks: 1 }', 'PS') === '1d4');
  check('two dice for one attribute collect rather than overwrite',
    JSON.stringify(merged('  attributes: { PS: "1d4" }', '  attributes: { PS: "2d6" }', 'PS')) === '["1d4","2d6"]');
  check('two flat bonuses still add',
    merged('  attributes: { PS: 2 }', '  attributes: { PS: 3 }', 'PS') === 5);
  check('a flat and a dice bonus keep both',
    JSON.stringify(merged('  attributes: { PS: 2 }', '  attributes: { PS: "1d4" }', 'PS')) === '[2,"1d4"]');

  // The real case, from published classes: five attributes, all dice, all from
  // the occupation half.
  const ck = mk('occ', '  attributes: { MA: "1d4", ME: "1d4", PS: "1d4", PE: "1d4", Spd: "1d4" }');
  const withRace = combineClasses(mk('rcc', '  combat: { initiative: 2 }'), ck);
  check('all five Cyber-Knight-shaped dice bonuses survive composition',
    ['MA', 'ME', 'PS', 'PE', 'Spd'].every((k) => withRace.bonuses.attributes[k] === '1d4'),
    JSON.stringify(withRace.bonuses.attributes));

  // And through the rolling path, which is where a list has to be understood.
  const roll = (cls, attr, N = 20000) => {
    let total = 0;
    for (let i = 0; i < N; i++) {
      const rolled = {};
      for (const [k, d] of Object.entries(derive.diceBonuses(cls))) {
        const rolls = [d].flat().map((x) => (typeof x === 'number' ? x : evalDice(x))).filter((v) => v != null);
        if (rolls.length) rolled[k] = rolls.reduce((a, b) => a + b, 0);
      }
      total += derive.classBonuses(cls, 1, rolled).attributes[attr] || 0;
    }
    return total / N;
  };
  const near = (v, w) => Math.abs(v - w) < 0.35;
  const compose2 = (a, b) => combineClasses(mk('rcc', a), mk('occ', b));

  check('two composed dice both roll',
    near(roll(compose2('  attributes: { PS: "1d4" }', '  attributes: { PS: "2d6" }'), 'PS'), 9.5));
  check('a mixed flat-and-dice list keeps the flat part',
    near(roll(compose2('  attributes: { PS: 2 }', '  attributes: { PS: "1d4" }'), 'PS'), 4.5));
  check('a lone flat bonus is not double counted',
    near(roll(compose2('  attributes: { PS: 2 }', '  combat: { attacks: 1 }'), 'PS'), 2));
  check('a lone dice bonus is not double counted',
    near(roll(compose2('  attributes: { PS: "1d4" }', '  combat: { attacks: 1 }'), 'PS'), 2.5));

  // The same collect-not-overwrite rule inside one class: a bonus at level 1 and
  // another at_level for the same attribute both count once the level is reached.
  const twice = mk('rcc', ['  attributes: { PS: "1d4" }',
                          '  at_level:',
                          '    - { level: 5, attributes: { PS: "1d6" } }'].join(String.fromCharCode(10)));
  check('a level-1 and an at_level dice bonus for one attribute both survive',
    JSON.stringify(derive.diceBonuses(twice).PS) === '["1d4","1d6"]',
    JSON.stringify(derive.diceBonuses(twice).PS));
}

// ---------- 1c25c. Pool bonuses ----------
// "P.P.E.: As per the appropriate O.C.C., plus 4D6" (Demigod R.C.C., Rifts
// Pantheons p.17). Fallthrough PLUS a modifier, which had no shape at all:
// stating it as a formula gave NULL P.P.E., and omitting it lost the +4D6. The
// faithful transcription was strictly worse than saying nothing.
section('Pool bonuses');
{
  const mk = (extra) => parseClassMarkdown(`---
id: t
name: T
system: rifts
source_book: b
category: rcc
${extra}
---

## Lore

x
`);

  const ok = mk(`bonuses:
  pools: { ppe: "4d6", isp: 5 }`);
  check('a dice pool bonus and a flat one both parse',
    ok.errors.length === 0 && ok.warnings.length === 0, ok.errors.concat(ok.warnings).join('; '));
  check('and survive parsing',
    ok.data.bonuses.pools.ppe === '4d6' && ok.data.bonuses.pools.isp === 5);

  const bad = mk(`bonuses:
  pools: { ppe: "lots" }`);
  check('prose is refused rather than ignored', bad.errors.length === 1, bad.errors.join('; '));
  const wrongKey = mk(`bonuses:
  pools: { stamina: 4 }`);
  check('a pool that does not exist is refused',
    wrongKey.errors.some((e) => e.includes('is not a pool')), wrongKey.errors.join('; '));
  const zero = mk(`bonuses:
  pools: { ppe: 0 }`);
  check('a zero bonus warns rather than passing silently',
    zero.warnings.some((w) => w.includes('will do nothing')));

  // Nothing applies a level-gated pool bonus, so it must not pass quietly.
  const atLevel = mk(`bonuses:
  at_level:
    - { level: 5, pools: { ppe: 10 } }`);
  check('a pool bonus at_level warns that nothing applies it',
    atLevel.warnings.some((w) => w.includes('is not applied')), atLevel.warnings.join('; '));

  check('the documented pool keys are the five the character has',
    POOL_BONUS_KEYS.join(',') === 'hp,sdc,mdc,ppe,isp');

  // Rolling. Means rather than ranges: hitting both extremes at once is rare
  // enough that a range check would pass on a bonus applied twice.
  const mean = (f, bonus) => { let s = 0; const N = 40000;
    for (let i = 0; i < N; i++) s += rollPoolFormula(f, { PE: 16 }, bonus); return s / N; };
  const near = (v, want, tol = 0.4) => Math.abs(v - want) < tol;

  check('a dice bonus is applied exactly once', near(mean('2d6', '4d6') - mean('2d6', null), 14));
  check('a flat bonus is applied exactly once', near(mean('2d6', 5) - mean('2d6', null), 5));
  check('a list of bonuses is summed', near(mean('2d6', ['4d6', '2d6']) - mean('2d6', null), 21));
  check('no bonus changes nothing', near(mean('2d6', null) - mean('2d6', undefined), 0));

  // The rule that keeps an M.D.C. race from acquiring hit points.
  check('a bonus cannot conjure a pool the class does not have',
    rollPoolFormula(null, { PE: 16 }, '4d6') === null
    && rollPoolFormula(undefined, { PE: 16 }, 10) === null);

  // Composition. The dice-dropping filter used by the other groups would lose
  // the occupation's bonus entirely, which is a live bug for attributes.
  const race = mk(`bonuses:
  pools: { ppe: "4d6" }`).data;
  const occ = parseClassMarkdown(`---
id: o
name: O
system: rifts
source_book: b
category: occ
ppe_base: "2d6"
bonuses:
  pools: { ppe: "2d6", mdc: 5 }
---

## Lore

x
`).data;
  const both = combineClasses(race, occ);
  check('two classes granting the same pool keep both bonuses',
    JSON.stringify(both.bonuses.pools.ppe) === '["4d6","2d6"]',
    JSON.stringify(both.bonuses.pools.ppe));
  check('a bonus only one side states still survives', both.bonuses.pools.mdc === 5);
  check('and a dice bonus from the OCCUPATION is not dropped',
    JSON.stringify(both.bonuses.pools.ppe).includes('2d6'));
  check('two flat bonuses for one pool are summed',
    combineClasses(mk(`bonuses:
  pools: { ppe: 3 }`).data,
                   mk(`bonuses:
  pools: { ppe: 4 }`).data).bonuses.pools.ppe === 7);
}

// ---------- 1c25e. Chosen ability fragments ----------
// A power the player picks, carrying what it grants. Chosen on the CLASS step,
// before attributes and pools are rolled, because the Godling's Super-Tough is
// +1D6 P.E. AND +3D4x10 M.D.C. - choosing later would re-roll what was read.
section('Chosen ability fragments');
{
  const lines = (...a) => a.join(String.fromCharCode(10));
  const src = lines(
    '---', 'id: godling', 'name: Godling', 'system: rifts', 'source_book: b', 'category: rcc',
    'mdc_base: "P.E. x 10"',
    'special_abilities:',
    '  - name: "Super-Tough"',
    '    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."',
    '    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }',
    '  - name: "Super-Psionic Powers"',
    '    description: "Two lesser categories."',
    '    psionics: { type: "master" }',
    '  - name: "Shape Shifter"',
    '    description: "One animal."',
    '    repeatable: true',
    '    on_repeat: "ANY normal animal."',
    '  - name: "Fly"',
    '    description: "Mystic flight."',
    '  - { choose: 3, from: ["Super-Tough", "Super-Psionic Powers", "Shape Shifter", "Fly"] }',
    '---', '', '## Lore', '', 'x', '');
  const parsed = parseClassMarkdown(src);
  check('a class with fragments parses cleanly', parsed.errors.length === 0, parsed.errors.join('; '));
  const cls = parsed.data;

  check('the grant keys are the three an ability may carry',
    ABILITY_GRANTS.join(',') === 'bonuses,psionics,magic');

  // occ_options: an ability that names occupations (the Godling's Magic
  // Powers) turns its pick into a required occupation choice.
  const occCls = { special_abilities: [
    { name: 'Magic Powers', occ_options: ['ley-line-walker', 'mystic'] },
    { name: 'Fly' },
    { choose: 1, from: ['Magic Powers', 'Fly'] },
  ] };
  check('a chosen ability with occ_options demands an occupation',
    abilityOccOptions(occCls, ['Magic Powers'])?.options.join(',') === 'ley-line-walker,mystic');
  check('an unchosen one demands nothing', abilityOccOptions(occCls, ['Fly']) === null);
  check('and the check is case- and shape-tolerant',
    abilityOccOptions(occCls, [{ name: 'magic powers', gm: true }]) !== null);

  check('no picks leaves the class untouched', applyAbilities(cls, []) === cls);
  check('and undefined picks are the same', applyAbilities(cls, undefined) === cls);

  const one = applyAbilities(cls, ['Super-Tough']);
  check('a fragment contributes its attribute bonus', one.bonuses?.attributes?.PE === '1d6');
  check('and its pool bonus', one.bonuses?.pools?.mdc === '3d4x10');
  check('the class keeps its own pool formula', one.mdc_base === 'P.E. x 10');
  check('what was taken is recorded for the sheet',
    one.abilities_taken?.length === 1 && one.abilities_taken[0].granted === true);

  // Duplicates are the point: the books give a second take a different meaning.
  const twice = applyAbilities(cls, ['Shape Shifter', 'Shape Shifter']);
  check('a repeated pick is counted, not collapsed',
    (twice.abilities_taken || []).map((a) => a.times).join(',') === '1,2');
  check('on_repeat surfaces only on the second take',
    twice.abilities_taken[0].on_repeat === undefined
    && twice.abilities_taken[1].on_repeat === 'ANY normal animal.');

  const doubled = applyAbilities(cls, ['Super-Tough', 'Super-Tough']);
  check('a repeated fragment applies its bonuses again',
    JSON.stringify(doubled.bonuses?.pools?.mdc) === '["3d4x10","3d4x10"]',
    JSON.stringify(doubled.bonuses?.pools?.mdc));

  // The stronger-tier rule composing a race with an occupation uses, so an
  // ability can never make a psychic weaker.
  check('an ability can raise the psychic tier',
    applyAbilities(cls, ['Super-Psionic Powers']).psionics?.type === 'master');
  const alreadyMaster = { ...cls, psionics: { type: 'master', isp_base: '4d6x10' } };
  check('and does not overwrite a stronger one it already had',
    applyAbilities(alreadyMaster, ['Super-Psionic Powers']).psionics?.isp_base === '4d6x10');

  // Recorded even when nothing defines it, or the sheet would disagree with
  // what the player actually chose.
  const unknown = applyAbilities(cls, ['Something The Book Only Describes']);
  check('an undefined pick is recorded but grants nothing',
    unknown.abilities_taken?.[0]?.granted === false && unknown.bonuses === cls.bonuses);


  // Shape errors that would otherwise be stored and ignored.
  const badGrant = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - name: "X"', '    bonuses: { combat: { strike: "quite a bit" } }',
    '---', '', '## Lore', '', 'x', ''));
  check('a fragment bonus is validated like any other',
    badGrant.errors.some((e) => e.includes('must be a number')), badGrant.errors.join('; '));
  const orphanRepeat = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - name: "X"', '    on_repeat: "twice"',
    '---', '', '## Lore', '', 'x', ''));
  check('on_repeat without repeatable warns that it is unreachable',
    orphanRepeat.warnings.some((w) => w.includes('can never be reached')));
  const undefOption = parseClassMarkdown(lines(
    '---', 'id: b', 'name: b', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:', '  - { choose: 1, from: ["Nothing Defines Me"] }',
    '---', '', '## Lore', '', 'x', ''));
  check('an option nothing defines warns rather than failing the class',
    undefOption.errors.length === 0
    && undefOption.warnings.some((w) => w.includes('grants nothing')));
}

// ---------- 1c25f. A race and an occupation, as the normal structure ----------
// A player picks a race and then an occupation. Both halves stay optional in the
// data because the exceptions are real - a human takes an O.C.C. and has no race
// at all, a Godling grants its own skills and stands alone - but the pairing is
// the normal case, and a racial class with nothing to CHOOSE is not a playable
// character by itself.
section('Race and occupation');
{
  const mk = (cat, skills) => parseClassMarkdown(
    ['---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: ' + cat]
      .concat(skills ? ['skills:'].concat(skills) : [])
      .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10))).data;

  const bare = mk('rcc', null);
  const bodyOnly = mk('rcc', ['  occ_skills:', '    - { name: "Swim", base: 50, per_level: 5 }']);
  const withRelated = mk('rcc', ['  occ_related_skills:', '    count: 8', '    categories: ["Physical"]']);
  const withSecondary = mk('rcc', ['  secondary_skills:', '    count: 5']);
  const occ = mk('occ', ['  occ_related_skills:', '    count: 6', '    categories: ["Science"]']);

  check('a race granting nothing needs an occupation', needsOccupation(bare) === true);
  check('fixed skills alone do not make it self-sufficient',
    needsOccupation(bodyOnly) === true);
  check('related skills of its own do', needsOccupation(withRelated) === false);
  check('so do secondary skills of its own', needsOccupation(withSecondary) === false);
  check('an occupation never needs one', needsOccupation(occ) === false);
  check('and nothing at all does not throw', needsOccupation(null) === false);

  // The validator warns, and must never refuse: a race that stands alone is
  // legitimate, and a character part-way through being built must still save.
  const cat = new Map();
  const alone = validateCharacter({ character: { level: 1 }, cls: bare, skills: [], attributes: {}, catalog: cat });
  check('validating a bare race warns',
    alone.warnings.some((w) => w.rule === 'no_occupation'), JSON.stringify(alone.warnings));
  check('and never blocks the save', alone.violations.length === 0);
  check('the warning carries a readable message',
    alone.warnings.find((w) => w.rule === 'no_occupation').message.length > 20);

  // Composed with an occupation, the reason to warn is gone - and the composed
  // class advertises `occ_id`, which is how the check knows.
  const composed = combineClasses(bare, occ);
  check('the composed class records which occupation', composed.occ_id === 't');
  const paired = validateCharacter({ character: { level: 1 }, cls: composed, skills: [], attributes: {}, catalog: cat });
  check('a paired character does not warn',
    !paired.warnings.some((w) => w.rule === 'no_occupation'));

  // A self-sufficient race alone is fine and says nothing.
  const standalone = validateCharacter({ character: { level: 1 }, cls: withRelated, skills: [], attributes: {}, catalog: cat });
  check('a race that grants its own skills is not nagged',
    !standalone.warnings.some((w) => w.rule === 'no_occupation'));

  // The wizard says which of the two it is rather than claiming one for all.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  // S.rcc, not S.cls: the picker reads the class the player PICKED, while
  // S.cls is the composed result and would answer for both halves at once.
  check('the wizard asks the class rather than assuming', /needsOccupation\(S\.rcc\)/.test(appSrc));
  check('and no longer claims every race grants no related skills',
    !/A racial class grants no related or secondary skills/.test(appSrc));
}

// ---------- 1c25g. Server-side ability validation ----------
// The wizard enforces the pick count, the offered list and repeatability; until
// now NOTHING re-checked them, so a direct API call could save a Godling with
// five powers. Same posture as skills: chosen things get a boundary, and what a
// class edit could have caused warns instead of blocking.
// ---------- An ability's bonuses only reach a character who took it ----------
// The Stone Master's Marks of Heritage were written as a plain ability carrying
// +12 P.P.E. and +20 S.D.C. Every Stone Master has them, none of them ever got
// them: applyAbilities folds in bonuses for abilities that were CHOSEN, and
// nothing chooses an ability no choice group offers. It parsed clean, read as
// mechanical, and granted nothing.
section('Bonuses on an ability nobody picks');
{
  const parse = (lines) => parseClassMarkdown(['---', 'id: g', 'name: G', 'system: rifts',
    'source_book: b', 'category: occ', 'special_abilities:'].concat(lines)
    .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10)));

  const inert = parse([
    '  - name: "Marks of Heritage"', '    description: "x"',
    '    bonuses: { pools: { ppe: 12 } }']);
  const warned = (r) => r.warnings.filter((w) => /not offered/.test(w));

  check('a bonus on an ability no choice group offers warns', warned(inert).length === 1);
  check('the warning names the ability', /Marks of Heritage/.test(warned(inert)[0]));
  check('and says where the bonus belongs instead', /class \(or its variant\)/.test(warned(inert)[0]));
  check('it is a warning, not an error - a G.M. can still assign it by name',
    inert.errors.length === 0);

  // The same block on an ability a choice group offers is exactly how the
  // Godling's powers work, and must stay silent.
  check('an ability the class offers as a choice does not warn', warned(parse([
    '  - name: "Marks of Heritage"', '    description: "x"',
    '    bonuses: { pools: { ppe: 12 } }',
    '  - { choose: 1, from: ["Marks of Heritage"] }'])).length === 0);

  // And an ability with no bonuses at all is prose, which is the common case.
  check('a description-only ability does not warn', warned(parse([
    '  - name: "Marks of Heritage"', '    description: "x"'])).length === 0);
}

// ---------- D1 binds 100 parameters per statement, and no more ----------
// Measured against the real binding, not assumed:
//   binds 100 -> ok, binds 101 -> D1_ERROR: too many SQL variables
//
// So any query building `IN (?,?,...)` from a list that grows with user data
// has to chunk. Four files already did, privately; the ones that did not are
// where it broke - `markConfirmed` runs AFTER the catalog write, so exceeding
// the limit there left 108 spells inserted, none marked confirmed, and a 500
// that read as though nothing had happened.
section('SQL bind chunking');
{
  const big = Array.from({ length: 313 }, (_, i) => i);

  check('the ceiling is recorded as the measured 100', D1_MAX_BINDS === 100);
  check('and the chunk size leaves room for a query\'s own binds',
    BIND_CHUNK < D1_MAX_BINDS);

  const parts = chunks(big);
  check('a long list is split', parts.length === Math.ceil(313 / BIND_CHUNK));
  check('no chunk can exceed the ceiling',
    parts.every((p) => p.length <= D1_MAX_BINDS));
  check('nothing is lost or duplicated',
    parts.flat().length === 313 && new Set(parts.flat()).size === 313);
  check('and order is preserved', parts.flat().every((v, i) => v === i));

  check('an empty list yields no chunks at all', chunks([]).length === 0);
  check('a short list yields exactly one', chunks([1, 2, 3]).length === 1);
  // A caller passing something silly must not produce a chunk over the ceiling.
  check('an oversized chunk size is clamped to the ceiling',
    chunks(big, 5000).every((p) => p.length <= D1_MAX_BINDS));
  check('a zero chunk size still makes progress rather than looping forever',
    chunks([1, 2, 3], 0).flat().length === 3);
}

// Every place that builds placeholders from a list must chunk. A new one added
// without chunking is the same bug again, and it only shows up once someone's
// data gets big - a level-fifteen caster, a long session note, a full import.
section('No query binds an unbounded list');
{
  const files = [
    '_lib/import-sessions.js', '_lib/power-picks.js', '_lib/skill-picks.js',
    '_lib/mentions.js', '_lib/skill-bonuses.js', 'campaigns/[id]/npcs/sweep.js',
  ];
  for (const f of files) {
    const src = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', f), 'utf8');
    const usesHelper = /sql-chunk\.js/.test(src);
    check(f + ' imports the chunking helper', usesHelper);
    // The giveaway shape: placeholders built straight from the caller's list
    // rather than from a chunk of it.
    const unbounded = /(?:names|ids)\.map\(\(\) => '\?'\)/.test(src);
    check(f + ' builds no placeholder list from an unchunked array', !unbounded,
      unbounded ? 'found names.map / ids.map building placeholders' : '');
  }
}

// ---------- Perception is a roll RUE grants and the sheet had nowhere to put ----------
// RUE gives Perception its own section (printed p367): D20 plus whatever the
// O.C.C./R.C.C. grants, against 4 / 8 / 14 / 17 by difficulty. The book hands
// out fifty such bonuses, and twelve catalog classes already mentioned one - as
// prose, because no key existed. The Dog Boy's own file said it outright:
// "+5 Perception, +2 disarm and +2 vs disease have no bonus key".
section('Perception');
{
  const win = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);

  const plain = win.derive.combat({ PP: 16, PS: 16, Spd: 12 });
  check('a character with no class bonus has Perception 0', plain.perception === 0);
  check('and Perception is present rather than undefined, so a bonus has a base',
    'perception' in plain);

  const boosted = win.derive.combat({ PP: 16, PS: 16, Spd: 12 }, undefined,
    { combat: { perception: 5 } });
  check('a class bonus lands on it', boosted.perception === 5);
  check('and does not disturb the attribute-derived rows',
    boosted.strike === plain.strike && boosted.parry === plain.parry);

  // No attribute feeds Perception - RUE gives the bonus to the class, not to a
  // score - so P.P. must not leak into it the way it does for strike/parry.
  const highPP = win.derive.combat({ PP: 24, PS: 16, Spd: 12 });
  check('no attribute feeds Perception', highPP.perception === 0);
  check('even though the same call derives a higher strike from P.P.',
    highPP.strike > plain.strike);
}

// Every row derive.combat() produces needs somewhere to appear, or a class can
// grant a bonus that lands in the data and never reaches the player. That is
// exactly how Perception went missing.
section('The sheet shows every derived combat row');
{
  const win = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(win, win);
  const derived = Object.keys(win.derive.combat({ PP: 12, PS: 12, Spd: 12 }));
  const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  const block2 = sheet.slice(sheet.indexOf('const COMBAT_FIELDS'),
    sheet.indexOf('];', sheet.indexOf('const COMBAT_FIELDS')));
  const shown = [...block2.matchAll(/\['([a-z_]+)',/g)].map((m) => m[1]);
  const missing = derived.filter((k) => !shown.includes(k));
  check('every derived combat row has a labelled field on the sheet',
    missing.length === 0, missing.join(', '));
}

// ---------- Military Occupational Specialty ----------
// RUE gives several classes an MOS: "select one area of specialty, gain all
// skills under that MOS" (Coalition Technical Officer p236, Robot Pilot p84).
//
// It is NOT a variant, and that is the whole reason it needed modelling. A
// variant REPLACES what the class says, and VARIANT_OVERRIDES excludes the
// skills block on purpose - `skill_overrides` restating a number is a much
// smaller power than swapping a skill list. An MOS ADDS a package on top of the
// O.C.C. skills every member of the class already has: the book says "plus the
// MOS skills chosen previously".
section('MOS');
{
  const mk = (extra = '') => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'skills:',
    '  occ_skills:',
    '    - { name: "Basic Math", base: 60, per_level: 5 }',
    '  mos:',
    '    choose: 1',
    '    options:',
    '      - id: "comms"',
    '        name: "Communications MOS"',
    '        skills:',
    '          - { name: "Radio: Basic", base: 70, per_level: 5 }',
    '      - id: "medic"',
    '        name: "Medic MOS"',
    '        skills:',
    '          - { name: "Paramedic", base: 55, per_level: 5 }',
    extra,
    '---', '', '## Lore', '', 'x', ''].filter((l) => l !== '').join(String.fromCharCode(10)));

  const parsed = mk();
  check('a class can declare an MOS', parsed.errors.length === 0, parsed.errors.join('; '));
  check('and its options parse', parsed.data.skills.mos.options.length === 2);

  const names = (c) => (c.skills.occ_skills || []).map((x) => x.name).filter(Boolean);
  const cls = parsed.data;

  check('with none chosen the class grants only its own skills',
    names(composeClass({ rcc: cls, character: {} })).join() === 'Basic Math');

  const comms = composeClass({ rcc: cls, character: { mos: 'comms' } });
  check('choosing one ADDS its skills rather than replacing',
    names(comms).join() === 'Basic Math,Radio: Basic', names(comms).join());
  check('and the choice is recorded for the sheet',
    comms.mos_chosen && comms.mos_chosen.name === 'Communications MOS');

  const medic = composeClass({ rcc: cls, character: { mos: 'medic' } });
  check('a different specialty grants different skills',
    names(medic).join() === 'Basic Math,Paramedic');

  // A character who picked an option a later edit removed is still a character.
  const gone = composeClass({ rcc: cls, character: { mos: 'no-such-mos' } });
  check('an unknown id leaves the class untouched rather than throwing',
    names(gone).join() === 'Basic Math' && !gone.mos_chosen);

  // The class may sit in EITHER slot: a character with no racial class carries
  // their O.C.C. in the rcc slot, which is where the first version only worked.
  const asOcc = composeClass({
    rcc: { id: 'r', name: 'R', system: 'rifts', category: 'rcc' },
    occ: cls, character: { mos: 'comms' } });
  check('an MOS survives being merged with a racial class',
    names(asOcc).includes('Radio: Basic'), names(asOcc).join());

  // Shape errors, each of which would otherwise fail silently.
  const noOpts = parseClassMarkdown(['---', 'id: t', 'name: T', 'system: rifts',
    'source_book: b', 'category: occ', 'skills:', '  mos:', '    choose: 1',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('an MOS with no options is rejected',
    noOpts.errors.some((e) => /needs a non-empty options list/.test(e)));

  const over = mk().data;
  over.skills.mos.choose = 5;
  const errs = [];
  validateMos(over.skills.mos, errs, []);
  check('asking for more specialties than exist is rejected',
    errs.some((e) => /asks for 5 of only 2/.test(e)), errs.join('; '));

  const dupe = { choose: 1, options: [
    { id: 'a', name: 'A', skills: [{ name: 'X', base: 1 }] },
    { id: 'a', name: 'A again', skills: [{ name: 'Y', base: 1 }] }] };
  const dErrs = [];
  validateMos(dupe, dErrs, []);
  check('two options with the same id are rejected',
    dErrs.some((e) => /two options called/.test(e)), dErrs.join('; '));

  const empty = { choose: 1, options: [{ id: 'a', name: 'A', skills: [] }] };
  const eErrs = [];
  validateMos(empty, eErrs, []);
  check('an option granting no skills is rejected',
    eErrs.some((e) => /grants no skills/.test(e)), eErrs.join('; '));

  // The shared validator is the point: an MOS option's entries are the same
  // shape as occ_skills, so a bad choice group has to fail the same way.
  const badGroup = { choose: 1, options: [{ id: 'a', name: 'A',
    skills: [{ choose: 3, from: ['One', 'Two'] }] }] };
  const gErrs = [];
  validateMos(badGroup, gErrs, []);
  check('an over-asking choice group inside an MOS fails like one in occ_skills',
    gErrs.some((e) => /asks for 3 of only 2/.test(e)), gErrs.join('; '));
}

section('Ability validation');
{
  const cls = parseClassMarkdown([
    '---', 'id: g', 'name: G', 'system: rifts', 'source_book: b', 'category: rcc',
    'special_abilities:',
    '  - name: "Fly"', '    description: "x"',
    '  - name: "Shape Shifter"', '    description: "x"', '    repeatable: true',
    '  - name: "Super-Tough"', '    description: "x"',
    '    bonuses: { pools: { mdc: "3d4x10" } }',
    '  - { choose: 2, from: ["Fly", "Shape Shifter", "Super-Tough"] }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  const v = (abilities) => validateCharacter({
    character: { level: 1 }, cls, skills: [], attributes: {}, abilities, catalog: new Map() });
  // The fixture race grants nothing, so 1c25f's no_occupation warning fires on
  // every call - by design. Scope these assertions to the ability rules, and
  // pin that the only other emission really is that one.
  const rules = (r) => r.violations.map((x) => x.rule).concat(r.warnings.map((x) => '~' + x.rule))
    .filter((x) => x.includes('ability'));
  check('the only non-ability emission is the expected no_occupation warning', (() => {
    const r = validateCharacter({ character: { level: 1 }, cls, skills: [], attributes: {}, abilities: [], catalog: new Map() });
    const rest = r.violations.map((x) => x.rule).concat(r.warnings.map((x) => x.rule))
      .filter((x) => !x.includes('ability'));
    return rest.join(',') === 'no_occupation';
  })());

  check('the allowed count is enforced',
    rules(v(['Fly', 'Super-Tough', 'Shape Shifter'])).includes('ability_count'));
  check('and the message says both numbers',
    /3 chosen powers, but this class allows 2/.test(
      v(['Fly', 'Super-Tough', 'Shape Shifter']).violations[0].message));
  check('an exact pick is clean', rules(v(['Fly', 'Super-Tough'])).length === 0);
  check('no abilities at all is clean (every pre-#81 character)',
    rules(v(undefined)).length === 0 && rules(v([])).length === 0);

  check('a non-repeatable power taken twice is refused',
    rules(v(['Fly', 'Fly'])).includes('ability_repeat'));
  check('a repeatable one taken twice is fine',
    rules(v(['Shape Shifter', 'Shape Shifter'])).length === 0);
  check('a repeatable one taken a third time warns rather than blocks', (() => {
    const r = v(['Shape Shifter', 'Shape Shifter', 'Shape Shifter']);
    return r.violations.some((x) => x.rule === 'ability_count')   // 3 > 2, separately
      && !r.violations.some((x) => x.rule === 'ability_repeat')
      && r.warnings.some((x) => x.rule === 'ability_repeat');
  })());

  check('a power the class does not offer warns, never blocks', (() => {
    const r = v(['Fly', 'Parental Gift']);
    return r.violations.length === 0 && r.warnings.some((x) => x.rule === 'ability_unknown');
  })());

  // A { name, gm: true } entry is a ruling, not a pick - the Demigod's "most
  // have ONE extra power, similar to the godly parent's" is assigned by hand.
  check('a G.M.-assigned power does not spend the allowance',
    rules(v(['Fly', 'Super-Tough', { name: 'Shape Shifter', gm: true }])).length === 0);
  check('nor is it checked against the offered list',
    rules(v([{ name: 'Wrath of the Father', gm: true }])).length === 0);
  check('but holding a non-repeatable power twice is twice, whoever granted it',
    rules(v(['Fly', { name: 'Fly', gm: true }])).includes('ability_repeat'));

  // And the composer honours the ruling: a G.M.-assigned power still grants.
  const granted = applyAbilities(cls, [{ name: 'Super-Tough', gm: true }]);
  check('a G.M.-assigned power still grants its bonuses',
    granted.bonuses?.pools?.mdc === '3d4x10');
  check('and the sheet can see whose it was',
    granted.abilities_taken[0].gm === true && granted.abilities_taken[0].granted === true);
  check('a plain pick carries no gm flag',
    applyAbilities(cls, ['Super-Tough']).abilities_taken[0].gm === undefined);
}

// ---------- 1c25i. Dice-valued equipment quantities ----------
// The Priest of Light starts with 1D6 vials of holy water. qty used to flow to
// the sheet untouched, so a dice string rendered as "x1d6" and broke the
// sheet's number input; the class shipped with a fixed 3 as a workaround.
// Now a fixed entry's qty may be a dice expression, rolled ONCE at creation
// behind the wizard's equipInit guard. A choice's qty stays a plain number -
// it is re-derived every render, so a die there would re-roll each paint.
console.log(String.fromCharCode(10) + '[1c25i] Dice equipment quantities');
{
  check('a plain number passes through', rollQuantity(4) === 4);
  check('a missing qty is one item, not zero', rollQuantity(undefined) === 1);
  const rolls = new Set();
  for (let i = 0; i < 200; i++) rolls.add(rollQuantity('1d6'));
  check('a dice qty rolls in range', [...rolls].every((n) => n >= 1 && n <= 6));
  check('and actually varies', rolls.size > 1);
  check('an unreadable string is one item', rollQuantity('a few') === 1);
  check('zero and negatives clamp to one', rollQuantity(0) === 1 && rollQuantity(-2) === 1);

  const mkq = (lines) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'equipment_starting:'].concat(lines)
    .concat(['---', '', '## Lore', '', 'x', '']).join(String.fromCharCode(10)));

  check('a dice qty on a fixed entry parses clean',
    mkq(['  - { item_id: "vial", qty: "1d6" }']).errors.length === 0);
  check('garbage qty on a fixed entry is refused',
    mkq(['  - { item_id: "vial", qty: "lots" }']).errors
      .some((e) => e.includes('qty must be a number')));
  check('a dice qty on a CHOICE is refused - it would re-roll every render',
    mkq(['  - { choose: 1, qty: "1d6", from: ["a", "b"] }']).errors
      .some((e) => e.includes('choice qty must be a plain number')));
  check('a numeric choice qty is fine',
    mkq(['  - { choose: 1, qty: 2, from: ["a", "b"] }']).errors.length === 0);

  // The wizard rolls inside the equipInit-guarded block, so the number is
  // stored (and draft-persisted) rather than re-rolled. Source pin, same
  // idiom as 1c25h.
  const appSrcQ = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard rolls the quantity once at init',
    appSrcQ.includes('rollQuantity(eq.qty'));
}

// ---------- 1c25h. Natural abilities reach the player ----------
// What a class simply HAS, as opposed to what is chosen. Four classes carry
// these (Demigod, Ley Line Walker, Glitter Boy, Priest of Light) and until
// now they appeared nowhere - not on the sheet, not in the wizard's class
// detail. Composition already concatenated both halves; only display was
// missing.
section('Natural abilities rendering');
{
  const mk = (extra) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b']
    .concat(extra)
    .concat(['---', '', '## Lore', '', 'x', '']).join('\n')).data;

  const race = mk(['category: rcc', 'natural_abilities:',
    '  - { name: "Regeneration", description: "Heals fast." }']);
  const occ = mk(['category: occ', 'natural_abilities:',
    '  - { name: "Sense Ley Line", description: "Feels the line." }']);

  const both = combineClasses(race, occ);
  check('composition concatenates natural abilities from both halves',
    both.natural_abilities?.length === 2
      && both.natural_abilities[0].name === 'Regeneration'
      && both.natural_abilities[1].name === 'Sense Ley Line');
  check('a half with none contributes none',
    combineClasses(mk(['category: rcc']), occ).natural_abilities?.length === 1);

  // The sheet lists them beside the chosen powers, and the wizard's class
  // detail shows them to a player still deciding. Source pins, same idiom as
  // 1c25f: the render path is browser-only, so the test reads the source.
  const sheetSrc = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  check('the sheet renders natural abilities',
    /function naturalAbilities\(cls\)/.test(sheetSrc)
      && /\$\{naturalAbilities\(cls\)\}/.test(sheetSrc));
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the wizard class detail renders them too',
    /function naturalAbilityList\(list\)/.test(appSrc)
      && /naturalAbilityList\(c\.natural_abilities\)/.test(appSrc));
  check('both tolerate a bare-string entry',
    /typeof a === 'string' \? a : a\?\.name/.test(sheetSrc)
      && /typeof a === 'string' \? a : a\?\.name/.test(appSrc));
}

// ---------- 1c25j. Level-scheduled save bonuses, and the curses key ----------
// bonuses.at_level had parser validation and derive support already; what the
// Ley Line Walker's "+3 vs curses at levels 3, 9, 11 and 14" lacked was a
// `curses` save key for the number to land on. It borrows the P.E. magic row,
// because a curse is magic - the same reasoning that gave illusionary magic
// its key.
console.log(String.fromCharCode(10) + '[1c25j] at_level curses');
{
  const cursed = parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'bonuses:',
    '  saves: { mind_control: 2 }',
    '  at_level:',
    '    - { level: 3, saves: { curses: 3 } }',
    '    - { level: 9, saves: { curses: 3 } }',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('an at_level curses entry parses clean', cursed.errors.length === 0,
    cursed.errors.join('; '));

  const cb = (lvl) => D.classBonuses(cursed.data, lvl, null);
  check('below the first step there is nothing', (cb(1).saves.curses || 0) === 0);
  check('each reached step accumulates',
    cb(3).saves.curses === 3 && cb(9).saves.curses === 6);
  check('the flat mind_control half rides along at every level',
    cb(1).saves.mind_control === 2 && cb(9).saves.mind_control === 2);

  // The key exists all the way to the rendered save: derive's table carries a
  // curses row (P.E. magic chart), and the class bonus folds onto it.
  const merged = D.saves({ PE: 16, ME: 10 }, {}, null, cb(9));
  check('the sheet-level save has a curses row and folds the bonus in',
    merged.curses === 7);  // +1 from P.E. 16 on the magic chart, +6 from class
  const plain = D.saves({ PE: 10, ME: 10 }, {}, null, { saves: {} });
  check('a class granting nothing still shows the row, at the table value',
    plain.curses === 0);

  const sheetSrcJ = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  check('the sheet lists vs Curses', sheetSrcJ.includes("['curses', 'vs Curses']"));
}

// ---------- 1c25k. Variable psionic costs (isp_note) ----------
// The isp column is live - the sheet's use button deducts it - so a power
// whose cost is not one number (Mind Bolt costs more for more damage) could
// only be stored wrong: a flat number spends the wrong amount, a zero reads
// as free and matches the stub heuristic. Migration 020's isp_note carries
// the schedule; isp keeps the minimum, which is what the use button deducts.
console.log(String.fromCharCode(10) + '[1c25k] Variable psionic costs');
{
  const psiFields = CATALOGS.psionics.fields.map((f) => f.name);
  check('the catalog editor offers the note field', psiFields.includes('isp_note'));
  check('placed beside the cost it qualifies',
    psiFields.indexOf('isp_note') === psiFields.indexOf('isp') + 1);

  // The import engine is a server module but takes no env until called, so
  // its spec is testable directly.
  const spec = getImportSpec('psionics');
  check('the importer extracts the note', spec.extractFields.includes('isp_note'));
  check('a zero with no note is flagged for review',
    spec.flag({ isp: 0 }).some((f) => f.includes('cost note')));
  check('a zero WITH a note is not', !spec.flag({ isp: 0, isp_note: 'costs nothing' })
    .some((f) => f.includes('cost note')));
  check('a noted zero is not a stub',
    spec.isStub({ source: 'import', isp: 0 }) === true
      && spec.isStub({ source: 'import', isp: 0, isp_note: 'costs nothing' }) === false);

  // The two render sites: the wizard's picker marks the minimum with a plus
  // and shows the note; the sheet carries it through the character's stored
  // power row (cost_note) beside the use button. Source pins, same idiom as
  // 1c25h.
  const appSrcK = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the picker shows the note and marks the minimum',
    appSrcK.includes("p.isp_note && p.isp > 0 ? '+' : ''") && appSrcK.includes('esc(p.isp_note)'));
  check('the wizard stores cost_note on the character',
    appSrcK.includes('cost_note: p.isp_note'));
  const sheetSrcK = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  check('the sheet shows the note beside the use button',
    sheetSrcK.includes('escHtml(p.cost_note)') && sheetSrcK.includes("p.cost_note && cost > 0 ? '+' : ''"));
}

// ---------- 1c25l. Variable spell costs (ppe_note) ----------
// Migration 021 mirrors 020 for spells: ppe is live (the use button deducts
// it), so Manipulate Objects - priced by a schedule, imported as 0 - could
// only read as free while matching the stub heuristic. Same convention, same
// surfaces: ppe keeps the minimum, ppe_note says the schedule.
console.log(String.fromCharCode(10) + '[1c25l] Variable spell costs');
{
  const spFields = CATALOGS.spells.fields.map((f) => f.name);
  check('the catalog editor offers the note field', spFields.includes('ppe_note'));
  check('placed beside the cost it qualifies',
    spFields.indexOf('ppe_note') === spFields.indexOf('ppe') + 1);

  const spec = getImportSpec('spells');
  check('the importer extracts the note', spec.extractFields.includes('ppe_note'));
  check('a zero with no note is flagged for review',
    spec.flag({ ppe: 0 }).some((f) => f.includes('cost note')));
  check('a zero WITH a note is not',
    !spec.flag({ ppe: 0, ppe_note: 'costs nothing' }).some((f) => f.includes('cost note')));
  check('a noted zero is not a stub',
    spec.isStub({ source: 'import', ppe: 0 }) === true
      && spec.isStub({ source: 'import', ppe: 0, ppe_note: 'x' }) === false);

  // The spell picker and payload, pinned like the psionic ones in 1c25k. The
  // sheet needs no pin of its own: powerRows reads cost_note for spells and
  // psionics through the same path.
  const appSrcL = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the picker shows the note and marks the minimum',
    appSrcL.includes("sp.ppe_note && sp.ppe > 0 ? '+' : ''") && appSrcL.includes('esc(sp.ppe_note)'));
  check('the wizard stores cost_note on the character',
    appSrcL.includes('cost_note: sp.ppe_note'));
}

// ---------- 1c26. Secondary schedules and group bonuses ----------
section('Secondary schedules & group bonuses');
{
  const mk = (skills) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n${skills}\n---\n\n## Lore\n\nx\n`);

  // ── secondary_skills.schedule ──
  const sched = mk(`  occ_related_skills:
    count: 8
    categories: ["Wilderness"]
    schedule:
      - { level: 3, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 1 }
      - { level: 7, count: 1 }`);
  check('a secondary schedule parses', sched.ok, JSON.stringify(sched.errors));
  check('a malformed secondary schedule is rejected',
    !mk('  secondary_skills:\n    count: 4\n    schedule:\n      - { level: "four", count: 1 }').ok);

  check('both kinds of grant are returned, tagged', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    const rel = g.filter((x) => x.kind === 'related');
    const sec = g.filter((x) => x.kind === 'secondary');
    return rel.length === 1 && rel[0].count === 2 && sec.length === 2;
  })());
  // Related picks carry the class's categories; secondary picks are unbounded,
  // which is why they cannot share one list.
  check('only related grants carry categories', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    return g.filter((x) => x.kind === 'related').every((x) => Array.isArray(x.categories))
      && g.filter((x) => x.kind === 'secondary').every((x) => x.categories === null);
  })());
  check('a class with no secondary schedule grants none', (() => {
    const g = skillGrantsFor(mk('  secondary_skills:\n    count: 4').data, 1, 15);
    return g.every((x) => x.kind !== 'secondary');
  })());

  // Merging the two would let an unrestricted secondary grant unrestrict the
  // related picks with it, which is the bug this separation exists to prevent.
  check('a secondary grant does not unrestrict related picks', (() => {
    const g = skillGrantsFor(sched.data, 1, 10);
    const related = g.filter((x) => x.kind !== 'secondary');
    return related.length > 0 && related.every((x) => x.categories !== null);
  })());

  // ── dedupeCategories ──
  check('object categories dedupe by value, not identity', (() => {
    const a = { name: 'Espionage', only: ['Escape Artist'] };
    const b = { name: 'Espionage', only: ['Escape Artist'] };
    return dedupeCategories([a, b, 'Wilderness', 'wilderness']).length === 2;
  })());

  // ── `bonus` on a choice group ──
  check('a group bonus parses', mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], bonus: 30 }').ok);
  check('base and bonus together are rejected', (() => {
    const r = mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], base: 80, bonus: 30 }');
    return !r.ok && r.errors.some((e) => /both base and bonus/.test(e));
  })());
  check('a non-numeric bonus is rejected',
    !mk('  occ_skills:\n    - { choose: 2, categories: ["Technical"], bonus: "lots" }').ok);

  // The arithmetic the wizard performs. A flat base gave every pick in a group
  // the same percentage regardless of what the skill itself starts at.
  const resolve = (catBase, explicit) => {
    const base = explicit.base ?? (explicit.bonus && catBase ? catBase + explicit.bonus : catBase);
    return base;
  };
  check('a bonus adds to each skill\'s own base', (() => (
    resolve(50, { bonus: 30 }) === 80 && resolve(30, { bonus: 30 }) === 60
  ))());
  check('a flat base still overrides everything', resolve(50, { base: 80 }) === 80);
  // A W.P. has no percentage for a percentage bonus to modify.
  check('a bonus leaves a non-percentile skill at zero', resolve(0, { bonus: 30 }) === 0);
  check('no base and no bonus falls back to the catalog', resolve(45, {}) === 45);
}

// ---------- 1c27. Variant skill overrides & the major-psionic penalty ----------
section('Variant skills & psionic penalty');
{
  const mk = (variantBody) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: palladium-fantasy\nsource_book: B\ncategory: rcc\nskills:\n  occ_skills:\n    - { name: "Basic Math", base: 96, per_level: 0 }\n    - { name: "Advanced Math", base: 96, per_level: 0 }\n  occ_related_skills:\n    count: 8\n    categories: ["Wilderness"]\n  secondary_skills:\n    count: 4\nvariants:\n  - id: hatchling\n    name: "T Hatchling"\n${variantBody}\n  - id: adult\n    name: "T Adult"\n---\n\n## Lore\n\nx\n`);

  const ok = mk('    skill_overrides:\n      - { name: "Advanced Math", base: 45, per_level: 5 }');
  check('a skill override parses', ok.ok, JSON.stringify(ok.errors));
  check('the override applies to its own stage only', (() => {
    const get = (c, n) => c.skills.occ_skills.find((s) => s.name === n)?.base;
    return get(applyVariant(ok.data, 'hatchling'), 'Advanced Math') === 45
      && get(applyVariant(ok.data, 'adult'), 'Advanced Math') === 96;
  })());
  check('skills the override does not name are untouched', (() => {
    const c = applyVariant(ok.data, 'hatchling');
    return c.skills.occ_skills.find((s) => s.name === 'Basic Math').base === 96;
  })());
  check('per_level can be overridden too', (() => {
    const c = applyVariant(ok.data, 'hatchling');
    return c.skills.occ_skills.find((s) => s.name === 'Advanced Math').per_level === 5;
  })());
  // The base class must not be mutated: applyVariant is called repeatedly on
  // the same parsed object, and a stage bleeding into the next would be silent.
  check('applying a variant does not mutate the class', (() => {
    applyVariant(ok.data, 'hatchling');
    return ok.data.skills.occ_skills.find((s) => s.name === 'Advanced Math').base === 96;
  })());
  check('skill_overrides does not leak onto the resolved class',
    !('skill_overrides' in applyVariant(ok.data, 'hatchling')));

  // An override restates a number; it is not a way to add a skill.
  check('naming a skill the class does not grant is an error', (() => {
    const r = mk('    skill_overrides:\n      - { name: "Prowl", base: 30 }');
    return !r.ok && r.errors.some((e) => /does not grant/.test(e));
  })());
  check('an override that changes nothing is an error',
    !mk('    skill_overrides:\n      - { name: "Basic Math" }').ok);
  check('a non-numeric override is an error',
    !mk('    skill_overrides:\n      - { name: "Basic Math", base: "lots" }').ok);
  check('skill_overrides must be a list',
    !mk('    skill_overrides: "Basic Math"').ok);

  // ── the major psionic's price (p.21) ──
  const cls = mk('').data;
  const rolled = (tier) => withRolledPsionics(cls, { psychic_tier: tier, psychic_shape: 'broad' });

  check('a rolled major halves the related-skill count',
    rolled('major').skills.occ_related_skills.count === 4);
  check('a rolled minor pays nothing',
    rolled('minor').skills.occ_related_skills.count === 8);
  check('halving rounds down', (() => {
    const odd = mk('').data;
    odd.skills.occ_related_skills = { ...odd.skills.occ_related_skills, count: 7 };
    return withRolledPsionics(odd, { psychic_tier: 'major' }).skills.occ_related_skills.count === 3;
  })());
  // "Secondary skills are not affected."
  check('secondary skills are untouched',
    rolled('major').skills.secondary_skills.count === 4);
  check('the class is not mutated by the penalty',
    cls.skills.occ_related_skills.count === 8);
  // A psychic O.C.C. never rolls, so it never pays this price.
  check('a class-granted major psionic pays nothing', (() => {
    const mage = { skills: { occ_related_skills: { count: 8 } }, psionics: { type: 'major' } };
    return withRolledPsionics(mage, { psychic_tier: 'major' }).skills.occ_related_skills.count === 8;
  })());

  // ── races with no psychic potential (p.21: troll, orc) ──
  check('a class may declare no psionics at all', (() => (
    rollsForPsionics({ psionics_allowed: false }) === false
  ))());
  check('an ordinary class still rolls', rollsForPsionics({}) === true);
  check('a class with its own psionics does not roll',
    rollsForPsionics({ psionics: { type: 'major' } }) === false);
}

// ---------- 1c28. Character background tables ----------
// p.32-33. Nine percentile tables, all optional, nothing derived from them.
section('Background tables');
{
  // rules.js is a classic script, loaded by evaluating it against a stand-in
  // global — the same way [1c20] does, since that one is block-scoped.
  const bgGlobal = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'rules.js'), 'utf8'))
    .call(bgGlobal, bgGlobal);
  const R = bgGlobal.rules;
  const keys = Object.keys(R.BACKGROUND_TABLES);
  check('all nine tables are present', keys.length === 9, keys.join(', '));

  // A gap or an overlap means some roll silently returns nothing, or two
  // entries claim the same number. Both are transcription errors.
  check('every table covers 01-00 exactly', (() => {
    const bad = [];
    for (const k of keys) {
      const rows = R.BACKGROUND_TABLES[k].rows;
      if (rows[rows.length - 1][0] !== 100) bad.push(`${k} ends at ${rows[rows.length - 1][0]}`);
      if (!rows.every((r, i) => i === 0 || r[0] > rows[i - 1][0])) bad.push(`${k} not ascending`);
      for (let n = 1; n <= 100; n++) if (R.backgroundResult(k, n) == null) { bad.push(`${k} has no entry for ${n}`); break; }
    }
    return bad.length === 0;
  })());

  // Spot-checks against the printed ranges.
  check('birth order reads as printed',
    R.backgroundResult('birth_order', 1) === 'First Born'
    && R.backgroundResult('birth_order', 25) === 'First Born'
    && R.backgroundResult('birth_order', 26) === 'Second Born'
    && R.backgroundResult('birth_order', 100) === 'Illegitimate');
  check('weight reads as printed',
    R.backgroundResult('weight', 31) === 'Average' && R.backgroundResult('weight', 90) === 'Obese; very overweight');
  check('height reads as printed',
    R.backgroundResult('height', 30) === 'Short' && R.backgroundResult('height', 71) === 'Tall');
  check('land of origin reads as printed',
    R.backgroundResult('land_of_origin', 43) === 'Old Kingdom (mountains or lowlands)'
    && R.backgroundResult('land_of_origin', 100) === 'Other world, dimension or time');
  // The book's own oddity: Fourth Born is followed by Sixth Born.
  check('the birth order table keeps the book\'s missing fifth',
    R.backgroundResult('birth_order', 60) === 'Sixth Born');

  check('a roll outside 01-00 returns nothing', (() => (
    R.backgroundResult('age', 0) === null && R.backgroundResult('age', 101) === null
    && R.backgroundResult('age', 'x') === null
  ))());
  check('an unknown table returns nothing',
    R.backgroundResult('favourite_colour', 50) === null && R.rollBackground('favourite_colour') === null);

  // Age is the only numeric table, and the only one the ×2 note touches.
  check('age carries its unit', /years old$/.test(R.rollBackground('age').text));
  check('the long-lived multiplier doubles the years', (() => {
    const real = Math.random;
    Math.random = () => 0.495;            // -> roll 50 -> the 46-60 band -> 24
    try {
      return R.rollBackground('age').text === '24 years old'
        && R.rollBackground('age', { double: true }).text === '48 years old';
    } finally { Math.random = real; }
  })());
  // Doubling a text table would be meaningless, so it must not apply.
  check('the multiplier does nothing to a text table', (() => {
    const real = Math.random;
    Math.random = () => 0.495;
    try {
      return R.rollBackground('disposition', { double: true }).text
        === R.rollBackground('disposition').text;
    } finally { Math.random = real; }
  })());

  check('a roll always lands inside its own table', (() => {
    for (let i = 0; i < 200; i++) {
      for (const k of keys) {
        const r = R.rollBackground(k);
        if (r.roll < 1 || r.roll > 100 || r.text == null) return false;
      }
    }
    return true;
  })());

  // Both pages must offer the four fields the tables added, or a rolled
  // disposition has nowhere to show.
  check('the wizard and the sheet both carry the new fields', (() => {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    return ['birth_order', 'land_of_origin', 'disposition', 'racial_bias']
      .every((k) => app.includes(`'${k}'`) && sheet.includes(`'${k}'`));
  })());
  // The identity block is split into two columns; a fixed split point left one
  // side longer every time the list grew.
  check('the bio columns split evenly on both pages', (() => {
    const app = readFileSync(join(appDir, 'app.js'), 'utf8');
    const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
    return /BIO_FIELDS\.length \/ 2/.test(app) && /BIO_FIELDS\.length \/ 2/.test(sheet);
  })());
}

// ---------- 1c29. One place composes a class ----------
// Three steps in a fixed order: variant, then race+occupation, then any rolled
// psionics. Six sites used to do this by hand and agreed only by luck; adding
// the psionics step missed one, and the sheet showed a rolled major psychic the
// wrong save target while level-up had it right.
section('Class composition');
{
  const mk = (id, cat, extra) => parseClassMarkdown(
    `---\nid: ${id}\nname: ${id}\nsystem: palladium-fantasy\nsource_book: B\ncategory: ${cat}\n${extra}\n---\n\n## Lore\n\nx\n`).data;

  const dragon = mk('dragon', 'rcc', `mdc_base: "1d4x100"
skills:
  occ_related_skills:
    count: 8
    categories: ["Wilderness"]
variants:
  - { id: hatchling, name: "Dragon Hatchling", mdc_base: "1d4x10" }`);
  const bowman = mk('bowman', 'occ', 'hit_points_base: "P.E. + 1d6 per level"');

  check('nothing in, nothing out', composeClass() === null && composeClass({}) === null);
  check('a race alone composes to itself', (() => {
    const c = composeClass({ rcc: dragon });
    return c.id === 'dragon' && !c.occ_id;
  })());
  check('an occupation alone still resolves',
    composeClass({ occ: bowman })?.id === 'bowman');

  check('the variant is applied', (() => {
    const c = composeClass({ rcc: dragon, character: { class_variant: 'hatchling' } });
    return c.mdc_base === '1d4x10' && c.name === 'Dragon Hatchling';
  })());
  check('race and occupation compose', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman });
    return c.occ_id === 'bowman' && /dragon/i.test(c.name) && /bowman/i.test(c.name);
  })());

  // The step that was missed when it was added.
  check('a rolled psychic tier is folded in', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman, character: { psychic_tier: 'minor' } });
    return c.psionics?.type === 'minor' && c.psionics.from_roll === true;
  })());
  check('no roll leaves psionics alone',
    composeClass({ rcc: dragon, occ: bowman }).psionics === undefined);

  // Order matters: the variant must land before the composition, or a
  // hatchling's M.D.C. would be overwritten by the base class's.
  check('the variant is applied before composing', (() => {
    const c = composeClass({ rcc: dragon, occ: bowman, character: { class_variant: 'hatchling' } });
    return c.mdc_base === '1d4x10';
  })());
  // And the psionics fold must come last, after the O.C.C. has contributed its
  // related-skill count, or a major psychic's halving would hit the wrong number.
  check('psionics fold after composition', (() => {
    const withOcc = mk('scholar', 'occ', 'skills:\n  occ_related_skills:\n    count: 6\n    categories: ["Science"]');
    const c = composeClass({ rcc: dragon, occ: withOcc, character: { psychic_tier: 'major' } });
    // The OCCUPATION supplies related allowances, so composing gives its 6, and
    // the major psionic halves that to 3. Folding psionics first would have
    // halved the dragon's 8 instead and landed on 4.
    return c.skills.occ_related_skills.count === 3;
  })());

  // The whole point: no caller re-implements the sequence. Every page script and
  // every function is in scope — a page that does not compose a class today is
  // exactly the one that will grow the need tomorrow. Only the two files the
  // sequence is BUILT from are exempt: parser.js declares combineClasses and
  // compose.js is the one legitimate caller.
  check('no source file composes a class by hand', (() => {
    const walk = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
      e.isDirectory() ? walk(join(dir, e.name)) : (e.name.endsWith('.js') ? [join(dir, e.name)] : []));
    const exempt = new Set([join(appDir, 'js', 'parser.js'), join(appDir, 'js', 'compose.js')]);
    const files = [
      ...readdirSync(appDir, { withFileTypes: true })
        .filter((e) => e.isFile() && e.name.endsWith('.js'))
        .map((e) => join(appDir, e.name)),
      ...walk(join(appDir, 'js')),
      ...walk(join(appDir, '..', '..', 'functions', 'api', 'character-creator')),
    ].filter((f) => !exempt.has(f));
    const bad = files.filter((f) => readFileSync(f, 'utf8').includes('combineClasses('));
    if (bad.length) console.log('    composing by hand:', bad.join(', '));
    return bad.length === 0;
  })(), 'use composeClass() instead');
}

// ---------- 1c30. The README's counted claims ----------
// Counts written into prose rot silently: nothing breaks, the sentence just
// stops being true. Both of these had already drifted — the JSON-column count
// missed `attribute_bonuses` from migration 016, and a set of page-script line
// counts was out by 20%. Pin the ones that are cheap to pin.
// ---------- Campaign notes ----------
// A human's query is not an FTS5 query, and the two callers do not want the
// same one. Both of those were bugs before they were tests.
section('Note search');
{
  // A bare apostrophe is FTS5 syntax, so `the baron's men` is a syntax error
  // rather than a search. Every run of word characters becomes one quoted term.
  const q = toMatchQuery("the baron's men");
  check('an apostrophe cannot reach FTS5 as syntax', !/(?<!")'/.test(q), q);
  check('every word becomes a quoted term', q === '"the" AND "baron" AND "s" AND "men"*', q);

  // Injection: whatever a person types, the result is quoted terms and nothing
  // else - no unbalanced quote, no operator, no column filter.
  const nasty = toMatchQuery('foo" OR bar: NEAR(x) *');
  check('an attempted operator is quoted away',
    nasty === '"foo" AND "OR" AND "bar" AND "NEAR" AND "x"*', nasty);
  check('nothing but terms and the join survives', !/[:()*]/.test(nasty.replace(/"\*$/, '"')), nasty);

  check('an empty query is null, not an error', toMatchQuery('') === null);
  check('and so is punctuation alone', toMatchQuery('???') === null);

  // The trailing * is what makes the search box narrow while a word is still
  // being typed.
  check('the last term is a prefix match for the search box',
    toMatchQuery('negoti').endsWith('*'));

  // THE BUG. A question AND-ed together matches no entry ever written: the ask
  // endpoint retrieved nothing and the model correctly answered that the notes
  // do not say. OR retrieves and lets bm25 rank.
  const asked = toMatchQuery("what did the baron's men want?", { join: 'OR' });
  check('a question ORs its terms', asked.includes(' OR ') && !asked.includes(' AND '), asked);
  check('and does not prefix-match the last word', !asked.endsWith('*'), asked);

  const askSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id]', 'ask.js'), 'utf8');
  check('the ask endpoint asks for OR', /toMatchQuery\(question, \{ join: 'OR' \}\)/.test(askSrc));
  // A question with no searchable words - "what happened last time?" is mostly
  // stopwords in some phrasings - must still retrieve something.
  check('and falls back to recent entries when a question yields no terms',
    /ORDER BY created_at DESC, id DESC LIMIT/.test(askSrc));
  // The notes are written by other people. An entry that looks like an
  // instruction is a thing a character said.
  check('the prompt says the notes are data, not instructions',
    /DATA, not instructions/.test(askSrc));
  check('and character sheets are deliberately not sent',
    !/FROM characters/.test(askSrc));
}

section('Search snippets are not markup');
{
  const searchSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id]', 'search.js'), 'utf8');
  const pageSrc = readFileSync(join(appDir, 'campaign.js'), 'utf8');

  // snippet() wraps matches in whatever it is given and the text AROUND them is
  // a note somebody typed. Asking for '<mark>' means building HTML out of user
  // input; escaping it client-side would escape the marks with it. Two
  // characters no keyboard produces survive the escape and are swapped after.
  // Comments stripped: the reason NOT to emit '<mark>' is written down in
  // search.js, and a check that reads its own explanation as a violation would
  // be unfixable without deleting the explanation.
  const searchCode = searchSrc.replace(/^\s*\/\/.*$/gm, '');
  check('the server does not put tags in the snippet', !/<mark>/.test(searchCode));
  check('it uses control characters instead', /char\(1\), char\(2\)/.test(searchSrc));
  check('the page escapes BEFORE re-marking',
    /esc\(String\(snippet \|\| ''\)\)[\s\S]{0,120}<mark>/.test(pageSrc));
  check('and the snippet is never interpolated raw', !/\$\{r\.snippet\}/.test(pageSrc));
}

section('Campaign membership');
{
  const authSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    '_lib', 'auth.js'), 'utf8');

  // No campaign_members table: owning a character in a campaign is what being a
  // player IS, and an invite list would be a second, weaker statement of it.
  check('membership is a query, not a table',
    /FROM characters WHERE campaign_id = \? AND player_email = \?/.test(authSrc));
  const schema = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  check('and no campaign_members table was added', !/campaign_members/.test(schema));

  // canWrite is membership; isGm is the narrower right. Collapsing the two lets
  // any player edit the campaign's GM notes.
  check('membership and GM are separate answers',
    /canWrite: isMember, isGm/.test(authSrc));
  const campSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'campaigns', '[id].js'), 'utf8');
  check('gm_notes stays GM-only after canWrite widened',
    /if \(!access\.isGm\) return forbidden\(\)/.test(campSrc));

  // One chokepoint. If a second place learned the rule, changing it later means
  // finding both.
  const files = ['journal.js', 'campaigns/[id]/search.js', 'campaigns/[id]/ask.js',
                 'campaigns/[id]/items.js', 'campaigns/[id]/currency.js'];
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  for (const f of files) {
    const src = readFileSync(join(apiDir, ...f.split('/')), 'utf8');
    check(`${f} asks auth.js rather than querying characters itself`,
      !/FROM characters WHERE campaign_id/.test(src));
  }
}

// ---------- NPC dossiers ----------
// `@Name` is the deterministic path into a dossier, so what it does and does
// not match is the whole contract. The sweep is the safety net beside it.
section('Mentions');
{
  check('a plain mention is one name', JSON.stringify(parseMentions('@Kevik met us')) === '["Kevik"]');

  // Two words, because "@Lord Coake" is one person and stopping at the space
  // would link to a Lord nobody has met. Not three - at that point the pattern
  // starts swallowing sentences.
  check('two capitalised words are one person',
    JSON.stringify(parseMentions('@Lord Coake was there')) === '["Lord Coake"]');
  check('but a following capital is not dragged in',
    JSON.stringify(parseMentions('@Lord Coake And Then We Left')) === '["Lord Coake"]');
  check('a lowercase word after a name is not part of it',
    JSON.stringify(parseMentions('@Kevik met us')) === '["Kevik"]');

  // Trailing punctuation is how people actually type.
  check('trailing punctuation is trimmed',
    JSON.stringify(parseMentions('@Kevik, @Aldric. @Brannoc!')) === '["Kevik","Aldric","Brannoc"]');

  // Deduped case-insensitively, keeping the first spelling: one @ four times is
  // one person, and one dossier.
  const dupes = parseMentions('@Kevik and @kevik and @KEVIK');
  check('repeats are one person', dupes.length === 1 && dupes[0] === 'Kevik', JSON.stringify(dupes));

  // The things that are NOT people. A description is not a name, and an email
  // address in a note is not somebody to open a dossier for.
  check('an uncapitalised word is not a name', parseMentions('@guard said nothing').length === 0);
  check('a bare @ is nothing', parseMentions('email me @ the usual place').length === 0);
  check('an empty body is no names', parseMentions('').length === 0 && parseMentions(null).length === 0);

  check('an absurdly long name is refused',
    parseMentions('@' + 'A'.repeat(200)).length === 0);

  // Apostrophes and hyphens belong INSIDE names.
  check('a hyphenated name survives',
    JSON.stringify(parseMentions('@Jean-Luc waited')) === '["Jean-Luc"]');
  check("and an apostrophe does too",
    JSON.stringify(parseMentions("@O'Dell waited")) === '["O\'Dell"]');
}

section('The sweep proposes, it does not create');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const sweepSrc = readFileSync(join(apiDir, 'campaigns', '[id]', 'npcs', 'sweep.js'), 'utf8');

  // A proposal is not a dossier. An automatic scan on save would confidently
  // turn "the guard" into a person until somebody stopped it.
  check('a sweep with no accept flag writes no npc row',
    !/INSERT INTO npcs/.test(sweepSrc.split("async function accept")[0]));
  check('accepting is a separate, explicit call',
    /searchParams\.get\('accept'\) === '1'/.test(sweepSrc));
  check('and dismissing is recorded so the name is not offered again',
    /npc_proposals_dismissed/.test(sweepSrc));

  // Marked swept only AFTER a successful response: an entry marked by a call
  // that never returned is one nobody will ever look at again.
  const afterUpstream = sweepSrc.slice(sweepSrc.indexOf('callAnthropic'));
  check('entries are marked swept only after the call returns',
    /INSERT OR IGNORE INTO npc_sweeps/.test(afterUpstream));

  // Ids come back through a model and then a client. Trusting them would let a
  // mention point at another campaign's note.
  check('entry ids are filtered against what was sent', /sentIds\.has\(id\)/.test(sweepSrc));
  check('and re-checked against the campaign when accepted',
    /WHERE campaign_id = \? AND id IN/.test(sweepSrc));
  check('a link the model made is marked as such', /'ai'\)/.test(sweepSrc));
  check('the prompt says the notes are data, not instructions',
    /DATA, not instructions/.test(sweepSrc));
}

section('Portraits are never public');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const src = readFileSync(join(apiDir, 'campaigns', '[id]', 'npcs', '[npcId]', 'portrait.js'), 'utf8');

  // The whole site is behind Access. An unauthenticated image endpoint would be
  // the one hole in it, so every read goes through the membership check.
  check('the portrait GET checks membership', /isMember/.test(src));

  // A missing NPC and an NPC with no portrait are different answers. `!npc?.x`
  // is the tidier-looking form and collapses them, which is why this is pinned
  // rather than left to whoever next reads the file.
  check('a missing NPC is distinguished from a missing portrait',
    /if \(!npc\) return json\(\{ error: 'NPC not found' \}, 404\);/.test(src));
  check('and the two are not collapsed into one check',
    !/!npc\?\.portrait_key/.test(src));
  check('an allowlist decides the type, not a blocklist', /const TYPES = \{/.test(src));
  check('and an unknown type is refused', /415/.test(src));
  check('uploads are size-bounded', /MAX_BYTES/.test(src) && /413/.test(src));

  // Write the row BEFORE deleting the old object: the other order can leave a
  // dossier pointing at nothing, this one can at worst orphan an object.
  const post = src.slice(src.indexOf('onRequestPost'));
  const updateAt = post.indexOf('UPDATE npcs SET portrait_key');
  const deleteAt = post.indexOf('MEDIA.delete');
  check('the row is updated before the old object is deleted',
    updateAt > 0 && deleteAt > updateAt, `update@${updateAt} delete@${deleteAt}`);

  // A stable URL with an immutable cache header needs the query to change, or
  // a replaced portrait is never seen again.
  const pageSrc = readFileSync(join(appDir, 'campaign.js'), 'utf8');
  check('the page busts the cache with the object key', /portrait_key \|\| ''\)/.test(pageSrc));
  check('and encodes it', /encodeURIComponent/.test(pageSrc));
  check('no img src interpolates a raw timestamp', !/portrait\?v=\$\{esc\(n\.updated_at\)\}/.test(pageSrc));

  // The binding is named for the site, not the app that needed it first.
  const wrangler = readFileSync(join(appDir, '..', '..', 'wrangler.jsonc'), 'utf8');
  check('the R2 binding exists', /"binding":\s*"MEDIA"/.test(wrangler));
}

// ---------- The live level-up grants powers ----------
// buildProposal reported spell and psionic grants and only the wizard acted on
// them. The sheet applies them now, which means banking, a cap that belongs to
// the granting level, and server-side enforcement of both.
section('Several grants at one level');
{
  // The Shifter gains THREE spells a level from two different places, so the
  // level alone stops identifying a grant. Modelled as two entries: two from
  // its named list, one of any kind capped at its own level.
  const shifter = { magic: {
    spells_per_level_from: ['Banishment', 'Charm', 'Teleport: Lesser'],
    spells_per_level_levels: 'up_to_character_level',
    spells_schedule: [
      { level: 2, count: 2, from_list: true, note: 'One must be Protection or Summoning' },
      { level: 2, count: 1, note: 'Not dimension-related or control-based' },
      { level: 3, count: 2, from_list: true },
      { level: 3, count: 1 },
    ] } };

  const g = spellGrantsFor(shifter, 1, 3);
  check('entries sharing a level become separate grants', g.grants.length === 4);
  check('and are told apart by slot',
    JSON.stringify(g.grants.map((x) => [x.level, x.slot])) === '[[2,0],[2,1],[3,0],[3,1]]',
    JSON.stringify(g.grants.map((x) => [x.level, x.slot])));
  check('three spells a level', g.total === 6);

  // `from_list` points at the class list, declared once. Repeating a
  // thirty-four name list on every entry would make one correction fourteen
  // edits.
  check('a from_list slot draws on the class list',
    JSON.stringify(spellNamesForGrant(shifter, 2, 0)) === '["Banishment","Charm","Teleport: Lesser"]');
  check('a slot without it draws on no list', spellNamesForGrant(shifter, 2, 1) === null);

  // A class can have SEVERAL lists. The Ley Line Rifter learns one spell from
  // List A and one from List B at every level, so `from_list` names which.
  const rifter = { magic: { spell_lists: {
      A: ['Dimensional Portal', 'Ley Line Transmission'],
      B: ['Calling', 'Time Slip', 'Locate'] },
    spells_schedule: [
      { level: 2, count: 1, from_list: 'A' },
      { level: 2, count: 1, from_list: 'B' },
    ] } };
  check('a named list is resolved by name',
    JSON.stringify(spellNamesForGrant(rifter, 2, 0)) === '["Dimensional Portal","Ley Line Transmission"]');
  check('and its sibling draws on the other one',
    JSON.stringify(spellNamesForGrant(rifter, 2, 1)) === '["Calling","Time Slip","Locate"]');
  check('a name matching no list restricts nothing rather than everything',
    spellNamesForGrant({ magic: { spell_lists: { A: ['x'] },
      spells_schedule: [{ level: 2, count: 1, from_list: 'Z' }] } }, 2, 0) === null);
  // Both forms coexist: `true` for a class with one list, a name for several.
  check('the single-list form still works',
    JSON.stringify(spellNamesForGrant(shifter, 3, 0)) === '["Banishment","Charm","Teleport: Lesser"]');
  check('a list-bounded slot is not also level-capped',
    spellLevelsForGrant(rifter, 2, 0) === null);

  // A slot bounded by a NAMED LIST is not also bounded by a spell level - the
  // list is the restriction. Only the free slot is capped.
  check('a list slot has no level cap', spellLevelsForGrant(shifter, 2, 0) === null);
  check('the free slot is capped at the character level',
    JSON.stringify(spellLevelsForGrant(shifter, 2, 1)) === '[1,2]');
  check('and the cap widens with the level',
    JSON.stringify(spellLevelsForGrant(shifter, 3, 1)) === '[1,2,3]');

  // A restriction nothing can check is STATED rather than dropped or guessed
  // at. Spells carry no tag, so "Protection or Summoning" has nothing to
  // filter on.
  check('a note rides with the slot that needs it',
    grantNote(shifter, 'spell', 2, 0) === 'One must be Protection or Summoning');
  check('and the other slot has its own',
    grantNote(shifter, 'spell', 2, 1) === 'Not dimension-related or control-based');
  check('a slot with nothing to say says nothing', grantNote(shifter, 'spell', 3, 0) === null);

  // The named list is enforced server-side; the note is not, and cannot be.
  const lib = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    '_lib', 'power-picks.js'), 'utf8');
  check('the server refuses a spell off the list',
    /is not on the list the level \$\{level\} grant draws from/.test(lib));
  check('and keys every grant by slot as well as level',
    /\$\{kind\}:\$\{level\}:\$\{slot \?\? 0\}/.test(lib));
}

section('Power grants');
{
  const llw = { magic: { spells_starting: 12, spell_levels_allowed: [1, 2, 3, 4],
                         spells_per_level: 2, spells_per_level_levels: 'up_to_character_level' } };

  // THE POINT of carrying the cap on the grant. Crossing two levels at once
  // caps each pair by ITS level, not by where the character ended up.
  const twoLevels = powerGrantsFor(llw, 3, 5);
  check('a multi-level jump yields one grant per level', twoLevels.length === 2);
  check('and each carries the cap of the level that earned it',
    JSON.stringify(twoLevels.map((g) => g.spell_levels)) === '[[1,2,3,4],[1,2,3,4,5]]',
    JSON.stringify(twoLevels.map((g) => g.spell_levels)));
  check('every grant says which kind it is', twoLevels.every((g) => g.kind === 'spell'));

  // A class that records no per-level rule grants nothing rather than an
  // unrestricted everything.
  check('an unknown per-level rule grants nothing',
    powerGrantsFor({ magic: { spells_starting: 6 } }, 1, 5).length === 0);
  check('and no magic at all likewise', powerGrantsFor({}, 1, 5).length === 0);

  const psi = powerGrantsFor({ psionics: { type: 'major', powers_per_level: 1 } }, 1, 3);
  check('psionic grants carry no spell cap',
    psi.length === 2 && psi.every((g) => g.kind === 'psionic' && g.spell_levels === null));

  // Banking consumes per grant, not from one pool. Spending both level-4 spells
  // must not leave the level-5 grant looking half spent.
  const grants = [
    { level: 4, slot: 0, count: 2, kind: 'spell', spell_levels: [1, 2, 3, 4] },
    { level: 5, slot: 0, count: 2, kind: 'spell', spell_levels: [1, 2, 3, 4, 5] },
  ];
  // Keyed by kind, level AND slot — several grants can share a level.
  const left = remainingPowerGrants(grants, new Map([['spell:4:0', 2]]));
  check('a fully spent grant is gone and the other is untouched',
    left.length === 1 && left[0].level === 5 && left[0].count === 2, JSON.stringify(left));
  const partly = remainingPowerGrants(grants, new Map([['spell:4:0', 1], ['spell:5:0', 2]]));
  check('a partly spent grant keeps its remainder',
    partly.length === 1 && partly[0].level === 4 && partly[0].count === 1, JSON.stringify(partly));
  check('and the remainder keeps its cap',
    JSON.stringify(partly[0].spell_levels) === '[1,2,3,4]');
  check('spending nothing banks everything',
    remainingPowerGrants(grants, new Map()).length === 2);
}

section('Power picks are enforced server-side');
{
  const apiDir = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const lib = readFileSync(join(apiDir, '_lib', 'power-picks.js'), 'utf8');

  // The picker filters, but a request does not have to come from the picker.
  // Every one of these is a rejection a client could otherwise walk past.
  for (const [what, pattern] of [
    ['a grant that does not exist', /has no \$\{kind\} grant from level/],
    ['a grant with no room', /is already full/],
    ['a power already known', /already known/],
    ['a name not in the catalog', /is not in the \$\{kind\} catalog/],
    ['a spell above the grant cap', /is a level \$\{row\.level\} spell/],
    ['a power outside the grant categories', /power; the level \$\{level\} grant allows/],
  ]) {
    check(`the server refuses ${what}`, pattern.test(lib), what);
  }

  // The cap comes from the GRANT, not from recomputing against the class: a
  // re-import between banking and spending must not change what a character was
  // granted at level 4.
  const claim = readFileSync(join(apiDir, 'characters', '[id]', 'power-picks.js'), 'utf8');
  check('the claim path spends against the banked grants',
    /spell_levels: g\.spell_levels/.test(claim));
  check('including the banked categories',
    /categories: g\.categories/.test(claim));
  check('and does not recompute them from the class',
    !/spellLevelsForGrant/.test(claim));
  check('the power write and the grant consume are one batch',
    /DB\.batch\(statements\)/.test(claim));

  // loadCharacter does not join campaigns. Reading character.campaign_system
  // yields undefined, the system filter becomes a no-op, and a Rifts caster can
  // learn a Palladium-only spell.
  const confirm = readFileSync(join(apiDir, 'characters', '[id]', 'level-confirm.js'), 'utf8');
  check('the level-up fetches the campaign system rather than assuming the character carries it',
    /SELECT system FROM campaigns WHERE id = \?/.test(confirm));
  check('and no path reads a campaign_system that loadCharacter never selected',
    !/character\.campaign_system/.test(confirm));

  // An empty list is what a swallowed error looks like.
  check('listPendingPowers does not swallow query failures',
    !/\.all\(\)\.catch\(/.test(lib));

  const sheet = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  check('the sheet sends the power picks with the level-up', /power_picks,/.test(sheet));
  check('and offers the banked ones afterwards', /claimPowers/.test(sheet));
}

section('Documented counts');
{
  const readme = readFileSync(join(appDir, 'README.md'), 'utf8');
  const WORDS = { one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8,
    nine: 9, ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15,
    sixteen: 16, seventeen: 17, eighteen: 18, nineteen: 19, twenty: 20, thirty: 30,
    forty: 40, fifty: 50 };
  // Hyphenated compounds sum their parts, so 'twenty-one' does not have to be
  // listed and neither does the count after it. Before this, the capture group
  // stopped at the hyphen and 'Twenty-one tables' read as one table - which the
  // check then reported as a documentation drift rather than as its own bug.
  const num = (word) => {
    const parts = String(word).toLowerCase().split('-');
    if (parts.every((p) => p in WORDS)) return parts.reduce((n, p) => n + WORDS[p], 0);
    return Number(word);
  };

  const cols = readme.match(/`characters` stores (\w+) JSON columns/);
  check('README states the character JSON column count',
    !!cols, 'the sentence itself has changed shape');
  check('and it matches CHARACTER_JSON_COLUMNS',
    cols && num(cols[1]) === CHARACTER_JSON_COLUMNS.length,
    cols ? `README says ${cols[1]} (${num(cols[1])}), code has ${CHARACTER_JSON_COLUMNS.length}` : '');

  // Every JSON column needs a row in the data-model table, or a reader learns
  // the count is 8 and then finds 7 described.
  const missing = CHARACTER_JSON_COLUMNS.filter((c) => !readme.includes('| `' + c + '` |'));
  check('every JSON column has a row in the data-model table',
    missing.length === 0, missing.join(', '));

  // The variant override list is a closed set the README spells out. It had
  // already gained `starting_money` and `skill_overrides` without the prose
  // noticing, so the README claimed a variant could do less than it can.
  const unlisted = VARIANT_OVERRIDES.filter((k) => !readme.includes('`' + k + '`'));
  check('the README names every VARIANT_OVERRIDES key',
    unlisted.length === 0, unlisted.join(', '));

  // The migration table had listed 001-009 while 017 was on disk — and the same
  // page discussed 011 and 012 further down, so it was provably stale in place.
  const migDir = join(appDir, '..', '..', 'db', 'migrations');
  const undocumented = readdirSync(migDir)
    .filter((f) => f.endsWith('.sql'))
    .filter((f) => !readme.includes('`' + f + '`'));
  check('every migration has a row in the README table',
    undocumented.length === 0, undocumented.join(', '));

  // Every endpoint must appear in the API surface table, or it is undiscoverable
  // to anyone reading the docs rather than the routing tree.
  const walkFns = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? (e.name === '_lib' ? [] : walkFns(join(dir, e.name))) : (e.name.endsWith('.js') ? [join(dir, e.name)] : []));
  const fnRoot = join(appDir, '..', '..', 'functions', 'api', 'character-creator');
  const surface = readme.slice(readme.indexOf('## API surface'));
  const surfaceTable = surface.slice(0, surface.indexOf('\n## ', 10));
  const unlistedRoutes = walkFns(fnRoot)
    .map((f) => f.slice(fnRoot.length + 1).replace(/\\/g, '/').replace(/\.js$/, ''))
    .filter((r) => !surfaceTable.includes('`' + r + '`'));
  check('every endpoint appears in the API surface table',
    unlistedRoutes.length === 0, unlistedRoutes.join(', '));

  // Documented and routed is not the same as reachable. `admin/audit` shipped
  // complete and had no caller in any page script for as long as it existed —
  // curl-only by accident rather than by decision, and so exercised by nothing.
  // The routes built dynamically (`import/${mode}/extract`) are why this names
  // one endpoint rather than sweeping them all.
  const pageScripts = readdirSync(appDir)
    .filter((f) => f.endsWith('.js'))
    .map((f) => readFileSync(join(appDir, f), 'utf8'))
    .join('\n');
  check('the character audit is reachable from the UI',
    pageScripts.includes("'admin/audit'"),
    'no page script calls it — it is an endpoint nobody can run');

  // The class-format example is the reference anyone writing a class by hand
  // copies from. If it stops parsing, the docs teach a shape the parser rejects.
  const lf = readme.replace(/\r\n/g, '\n');
  const example = lf.match(/```yaml\n(---\nid: cyber-knight[\s\S]*?)```/);
  check('the README class-format example is still there', !!example);
  if (example) {
    const parsed = parseClassMarkdown(example[1]);
    check('and it parses with no errors',
      (parsed.errors || []).length === 0, (parsed.errors || []).join('; '));
    // Keys the example must actually demonstrate, because each was documented
    // only in prose until it was added here.
    check('and it demonstrates the newer class keys', !!(
      parsed.data?.starting_money
      && parsed.data?.bonuses?.attribute_minimums
      && parsed.data?.skills?.secondary_skills?.schedule
      && (parsed.data?.skills?.occ_related_skills?.categories || []).some((c) => c && typeof c === 'object')
    ));
  }

  // The set of modules both runtimes load grew twice without the sentence
  // noticing ("three" survived compose.js and psionics.js joining). Recompute it
  // from the actual imports - direct from functions/**, plus one transitive hop
  // through those modules' own relative imports - and require each to be named.
  const fnFiles = walkFns(fnRoot).concat(walkFns(join(fnRoot, '..', '_lib')));
  const directShared = new Set();
  for (const f of fnFiles) {
    for (const m of readFileSync(f, 'utf8').matchAll(/apps\/character-creator\/js\/([a-z-]+\.js)/g)) {
      directShared.add(m[1]);
    }
  }
  for (const mod of [...directShared]) {
    const src = readFileSync(join(appDir, 'js', mod), 'utf8');
    for (const m of src.matchAll(/from '\.\/([a-z-]+\.js)'/g)) directShared.add(m[1]);
  }
  const bothSentence = readme.slice(readme.indexOf('modules are imported by both'), readme.indexOf('modules are imported by both') + 400);
  const unnamed = [...directShared].filter((m) => !bothSentence.includes('`js/' + m + '`'));
  check('every module both runtimes load is named in the README',
    unnamed.length === 0, 'not in the sentence: ' + unnamed.join(', '));

  // The composition sequence is written down twice - the README's numbered list
  // and compose.js's header comment - and the README's copy sat at three steps
  // after the code grew a fourth. They must agree.
  const compSection = readme.slice(readme.indexOf('## One place composes a class'));
  const readmeSteps = [...compSection.slice(0, compSection.indexOf('Six places'))
    .matchAll(/^\d+\. \*\*/gm)].length;
  const composeSrc = readFileSync(join(appDir, 'js', 'compose.js'), 'utf8');
  const codeSteps = [...composeSrc.matchAll(/^\/\/ {3}\d+\. /gm)].length;
  check('the README and compose.js agree on the number of composition steps',
    readmeSteps === codeSteps && readmeSteps >= 4,
    `README lists ${readmeSteps}, compose.js lists ${codeSteps}`);

  const schema = readFileSync(join(appDir, '..', '..', 'db', 'schema.sql'), 'utf8');
  const tables = (schema.match(/CREATE TABLE IF NOT EXISTS/g) || []).length;
  const stated = readme.match(/([\w-]+) tables in one shared D1 database/);
  check('README states the table count', !!stated);
  check('and it matches schema.sql',
    stated && num(stated[1]) === tables,
    stated ? `README says ${stated[1]} (${num(stated[1])}), schema has ${tables}` : '');

  // A correct count over an incomplete description is the worse failure of the
  // two, because the number reassures you the list is whole. The README said
  // seventeen and described fifteen — `import_sessions` and `import_staged` had
  // a migration row and an API section but no data-model row anywhere.
  const named = new Set([...readme.matchAll(/^\| `([a-z_]+)` \|/gm)].map((m) => m[1]));
  // The two the section explicitly disclaims: not this app's tables.
  const notOurs = ['media_items', 'schema_migrations'];
  const undescribed = [...schema.matchAll(/CREATE TABLE IF NOT EXISTS ([a-z_]+)/g)]
    .map((m) => m[1])
    .filter((t) => !named.has(t) && !notOurs.includes(t));
  check('every table has a row in a data-model table',
    undescribed.length === 0, undescribed.join(', '));
  check('and the two it disclaims are still disclaimed',
    notOurs.every((t) => readme.includes('`' + t + '`')));

  // The data scripts grow with the audit — five landed in two days — and nothing
  // else records that one exists. A script nobody knows to run is a correction
  // that silently did not happen.
  const dataScripts = readdirSync(join(appDir, 'db')).filter((f) => f.endsWith('.sql'));
  const ds = readme.slice(readme.indexOf('### Data scripts'));
  const dsSection = ds.slice(0, ds.indexOf('\n## ', 10));
  const patterns = [...dsSection.matchAll(/`([a-z0-9*-]+\.sql)`/g)].map((m) =>
    new RegExp('^' + m[1].replace(/[.]/g, '\\.').replace(/\*/g, '.*') + '$'));
  const uncovered = dataScripts.filter((f) => !patterns.some((p) => p.test(f)));
  check('every data script is covered by the Data scripts table',
    uncovered.length === 0, uncovered.join(', '));
}

// ---------- 1d. Paging ----------
// A stray query string must not turn a list endpoint into a 400, so anything
// nonsensical falls back to the default rather than erroring.
section('Paging');
const pageOf = (qs) => paging(new Request('https://x/list' + qs));
check('defaults with no parameters', (() => {
  const p = pageOf('');
  return p.limit === 200 && p.offset === 0;
})());
check('honours a sensible limit and offset', (() => {
  const p = pageOf('?limit=50&offset=100');
  return p.limit === 50 && p.offset === 100;
})());
check('clamps an oversized limit to the maximum', pageOf('?limit=99999').limit === 500);
check('a negative or zero limit falls back to the default',
  pageOf('?limit=-1').limit === 200 && pageOf('?limit=0').limit === 200);
check('a non-numeric limit falls back to the default', pageOf('?limit=abc').limit === 200);
check('a negative offset floors at zero', pageOf('?offset=-5').offset === 0);

// ---------- 1e. class-check ----------
// The CLI validator reads a class back out of its data script. If that
// extraction drifts from the shape the scripts actually use, the checker
// silently checks nothing — which is worse than not having it, because a clean
// run would then be read as a verified class.
section('class-check');

const sqlWrap = (md, insert = 'INSERT INTO imported_classes') =>
  `${insert} (class_id, name, system, markdown, status, created_by)\n`
  + `SELECT 'x', 'X', 'rifts', '${md.replace(/'/g, "''")}', 'published', 'data-script'\n`
  + "WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'x');";

const tinyClass = '---\nid: x\nname: X\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nA class.\n';

check('reads the markdown back out of a data script',
  extractClassMarkdown(sqlWrap(tinyClass)) === tinyClass);

// Both spellings ship. Matching only the plain one skipped add-godling-class.sql
// entirely, and the checker reported "no class found" rather than checking it.
check('handles INSERT OR IGNORE as well as plain INSERT',
  extractClassMarkdown(sqlWrap(tinyClass, 'INSERT OR IGNORE INTO imported_classes')) === tinyClass);

check('unescapes a doubled quote back to one',
  extractClassMarkdown(sqlWrap("---\nid: x\n---\nthe Mystic's power")).includes("the Mystic's power"));

// A non-ASCII character reaches D1 spliced in with char(N), because the file
// itself must stay ASCII. Reassembling it is what lets the parser see the real
// text rather than a broken literal.
check('reassembles a char(N) splice',
  extractClassMarkdown(
    "INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)\n"
    + "SELECT 'x', 'X', 'rifts', '---' || char(10) || 'id: x' || char(8212) || 'y', 'published', 'd';")
    === '---\nid: x—y');

check('gear stubs alone are not mistaken for a class',
  extractClassMarkdown("INSERT OR IGNORE INTO gear (slug) VALUES ('x');") === null);

check('a malformed markdown expression throws rather than returning junk', (() => {
  try {
    extractClassMarkdown('INSERT INTO imported_classes (class_id) SELECT 1;');
    return false;
  } catch { return true; }
})());

// The signal that a class wants something the app cannot express yet.
check('an unmodelled top-level key is reported',
  unmodelledKeys({ id: 'x', name: 'X', elemental_affinity: {} }).join() === 'elemental_affinity');

// Every shipped class must come back clean. If one does not, KNOWN_KEYS has
// gone stale and every future run cries wolf.
const unmodelledOffenders = (() => {
  const dbDir = join(appDir, 'db');
  const out = [];
  for (const f of readdirSync(dbDir).filter((n) => /^add-.*-class[.]sql$/.test(n))) {
    const md = extractClassMarkdown(readFileSync(join(dbDir, f), 'utf8'));
    if (!md) { out.push(f + ' (no class found)'); continue; }
    const keys = unmodelledKeys(parseClassMarkdown(md).data);
    if (keys.length) out.push(`${f}: ${keys.join(', ')}`);
  }
  return out;
})();
check('no shipped class reports an unmodelled key', unmodelledOffenders.length === 0,
  unmodelledOffenders.join(' | ') + ' — KNOWN_KEYS in scripts/class-check-lib.mjs is out of date');

// ---------- 1f. Skill bonuses ----------
// A skill is not only a percentage: Boxing is +1 attack per melee and +2 P.S.
// The column stores them in a class's `bonuses:` shape and shares its
// validator, so a skill cannot express a bonus a class could not.
section('Skill bonuses');

const boxing = { name: 'Boxing', bonuses: { attributes: { PS: 2 }, combat: { attacks: 1, parry: 2, dodge: 2, roll: 1 } } };
const bodyBuilding = { name: 'Body Building', bonuses: { attributes: { PS: 2 } } };

check('a skill with no bonuses contributes nothing',
  bonusesFromSkills([{ name: 'Prowl' }, { name: 'Climbing', bonuses: null }]) === undefined);

check('bonuses arrive as stored JSON or as an object', (() => {
  const a = bonusesFromSkills([boxing]);
  const b = bonusesFromSkills([{ name: 'Boxing', bonuses: JSON.stringify(boxing.bonuses) }]);
  return a.attributes.PS === 2 && b.attributes.PS === 2 && b.combat.attacks === 1;
})());

// Two skills granting the same attribute add up. They used to be unable to
// grant anything at all, so "one silently wins" would be a new bug, not a
// preserved one.
check('two skills granting the same attribute add up',
  bonusesFromSkills([boxing, bodyBuilding]).attributes.PS === 4);

check('unparseable stored JSON is skipped, not thrown',
  bonusesFromSkills([{ name: 'Boxing', bonuses: '{not json' }, bodyBuilding]).attributes.PS === 2);

// `combat` is an open set by design, so `roll` needs no schema change.
check('an open-set combat key survives the round trip',
  bonusesFromSkills([boxing]).combat.roll === 1);

// --- validation: a skill goes through the class validator, in flat-only mode
const vErr = (b, opts) => { const e = []; validateBonuses(b, e, [], opts); return e; };

check('a flat skill bonus validates',
  vErr({ attributes: { PS: 2 }, combat: { attacks: 1 } }, { flatOnly: true }).length === 0);

// A class may roll dice for a bonus because it rolls once at creation and
// stores the result. A skill has no such moment, so accepting dice would store
// Boxing's +3D6 S.D.C. and never apply it.
check('a dice bonus is refused for a skill but allowed for a class',
  vErr({ attributes: { PS: '2d6' } }, { flatOnly: true }).length === 1
  && vErr({ attributes: { PS: '2d6' } }, {}).length === 0);

check('pools are refused for a skill',
  vErr({ pools: { sdc: 10 } }, { flatOnly: true }).length === 1);

check('at_level is refused for a skill', vErr({ at_level: [{ level: 2 }] }, { flatOnly: true }).length === 1);

check('a skill still cannot invent an attribute',
  vErr({ attributes: { LUCK: 2 } }, { flatOnly: true }).some((e) => e.includes('is not an attribute')));

// --- the catalog field coerces through that same validator
const coerceBonus = (raw) => coerceField(
  CATALOGS.skills.fields.find((f) => f.name === 'bonuses'), raw);

check('the catalog field stores valid bonuses as JSON',
  coerceBonus({ attributes: { PS: 2 } }).value === '{"attributes":{"PS":2}}');
check('the catalog field rejects a dice bonus',
  !!coerceBonus({ attributes: { PS: '2d6' } }).error);
check('blank bonuses store NULL, not an empty object',
  coerceBonus('').value === null && coerceBonus(null).value === null);
check('malformed JSON is an error, not a silent null',
  !!coerceBonus('{nope').error);

// --- composeClass folds them in, and only when told about them
const plainOcc = parseClassMarkdown(classTemplate('occ',
  { id: 'boxer', name: 'Boxer', system: 'rifts', sourceBook: 'B' })).data;

check('null skillRows leaves the composed class untouched', (() => {
  const c = composeClass({ rcc: plainOcc });
  return c.bonuses === undefined || c.bonuses?.attributes?.PS === undefined;
})());

check('skill bonuses reach the composed class', (() => {
  const c = composeClass({ rcc: plainOcc, skillRows: [boxing] });
  return c.bonuses.attributes.PS === 2 && c.bonuses.combat.attacks === 1;
})());

// The reason to merge with sumBonusGroups rather than assign: a class and a
// skill both granting +2 P.S. is +4.
check('a class bonus and a skill bonus add rather than replace', (() => {
  const withPs = { ...plainOcc, bonuses: { attributes: { PS: 2 } } };
  return composeClass({ rcc: withPs, skillRows: [boxing] }).bonuses.attributes.PS === 4;
})());

// derive.js needs no new cases: the folded block is an ordinary class bonuses
// block, so classBonuses() reads it exactly as it reads a class's own.
check('derive reads a skill bonus as an ordinary class bonus', (() => {
  const c = composeClass({ rcc: plainOcc, skillRows: [boxing] });
  const b = D.classBonuses(c, 1, null);
  return b.attributes.PS === 2 && b.combat.attacks === 1 && b.combat.roll === 1;
})());

// ---------- 1g. Cross-category restrictions ----------
// The catalog files a skill under exactly one category; the books file it under
// whichever category a class spends its pick from. "Espionage: Wilderness
// Survival only" is an ordinary book line about a Wilderness skill, and
// filtering by the catalog's category first made that name match nothing.
section('Cross-category restrictions');

const ccCats = [
  { name: 'Espionage', only: ['Detect Ambush', 'Wilderness Survival'] },
  { name: 'Physical', except: ['Acrobatics'] },
  { name: 'Communications', except: ['Read Sensory Equipment'] },
  // Wilderness is granted but RESTRICTED, and its own list does not carry
  // Wilderness Survival. So the cross-category rule is what admits the skill,
  // not this entry - which is the Elemental Fusionist's exact shape.
  { name: 'Wilderness', only: ['Hunting'] },
  'Technical',
];
const allows = (name, category) => categoryAllows(ccCats, { name, category });

// The whole point: named in an `only` list, filed elsewhere by the catalog.
check('an only-list grants a skill from another category',
  allows('Wilderness Survival', 'Wilderness'));

// Everything that worked before must still work exactly as it did.
check('an only-list still grants a skill from its own category',
  allows('Detect Ambush', 'Espionage'));
check('an only-list still refuses a skill it does not name',
  !allows('Tracking', 'Espionage'));
check('an except-list still refuses what it excludes',
  !allows('Acrobatics', 'Physical'));
check('an except-list still admits what it does not exclude',
  allows('Prowl', 'Physical'));
check('a bare category string still admits everything in it',
  allows('Art', 'Technical'));
check('a category the class does not grant is still refused',
  !allows('Brewing', 'Medical'));

// An `except` naming a skill from another category stays a no-op. There is
// nothing to exclude: the skill was never offered in that category. Making it
// grant would be the opposite of what an except list is for.
check('an except-list does NOT grant a skill from another category',
  !allows('Read Sensory Equipment', 'Pilot Related'));

// An empty or absent list restricts nothing, unchanged.
check('no categories at all still allows anything',
  categoryAllows([], { name: 'X', category: 'Y' }) && categoryAllows(null, { name: 'X', category: 'Y' }));

// The bound: the class must also LIST the skill's real category. Without it an
// only-list would reach a skill from a category the class never granted, which
// is wider than any book says.
check('a cross-category grant needs the real category to be listed too',
  !categoryAllows([{ name: 'Espionage', only: ['Wilderness Survival'] }],
    { name: 'Wilderness Survival', category: 'Wilderness' }));

// "Lists it" is NOT "that category's own restriction admits it". Both Elemental
// Fusionists grant Technical with an only-list that does not carry Writing, and
// name Writing under Communications instead; requiring both would refuse the
// very skill this exists to reach.
check('the real category may itself be restricted', categoryAllows(
  [{ name: 'Communications', only: ['Writing'] }, { name: 'Technical', only: ['Art'] }],
  { name: 'Writing', category: 'Technical' }));

// --- the reporting half, which is what makes this visible in class-check
// It walks the class data itself so the bound is checked against the SAME
// skill group the restriction came from.
const ccMap = new Map([
  ['wilderness survival', 'Wilderness'],
  ['detect ambush', 'Espionage'],
  ['read sensory equipment', 'Pilot Related'],
  ['writing', 'Technical'],
]);
const ccData = (categories) => ({ skills: { occ_related_skills: { categories } } });

// Granted: the class lists Wilderness too, so categoryAllows admits it.
const ccGranted = crossCategoryRestrictions(ccData([
  { name: 'Espionage', only: ['Wilderness Survival', 'Detect Ambush'] },
  { name: 'Wilderness', only: ['Hunting'] },
]), ccMap);
check('a cross-category only whose real category is listed reports as granted',
  ccGranted.granted.length === 1 && ccGranted.granted[0].name === 'Wilderness Survival'
  && ccGranted.unreachable.length === 0);
check('a name in its own category is not reported',
  !ccGranted.granted.some((g) => g.name === 'Detect Ambush'));

// The defect the checker used to call a success: the class grants a skill
// nobody can take, because categoryAllows is bounded by the real category.
const ccLost = crossCategoryRestrictions(ccData([
  { name: 'Espionage', only: ['Wilderness Survival'] },
]), ccMap);
check('a cross-category only with no real category reports as unreachable',
  ccLost.unreachable.length === 1 && ccLost.granted.length === 0);

// The bound is per skill group: a category granted only to secondary skills
// does not make an occ_related_skills restriction reachable.
check('the bound is checked within the same skill group', crossCategoryRestrictions({
  skills: {
    occ_related_skills: { categories: [{ name: 'Espionage', only: ['Wilderness Survival'] }] },
    secondary_skills: { categories: ['Wilderness'] },
  },
}, ccMap).unreachable.length === 1);

check('a cross-category except is reported as a no-op', crossCategoryRestrictions(ccData([
  { name: 'Communications', except: ['Read Sensory Equipment'] },
]), ccMap).noop.length === 1);

// A name with no row at all belongs to the missing-row check, not this one.
check('a name with no catalog row is left to the missing-row check',
  (() => {
    const r = crossCategoryRestrictions(ccData([{ name: 'Rogue', except: ['Nothing At All'] }]), ccMap);
    return r.granted.length === 0 && r.unreachable.length === 0 && r.noop.length === 0;
  })());

// ---------- 1h. Bonus attribution ----------
// Once skills fold into the same bonuses block, "+1 attack from the class" is
// wrong whenever the attack is Boxing's. derive.parts splits the two so the
// sheet can name the real source.
section('Bonus attribution');

const baStats = { IQ: 12, ME: 12, MA: 12, PS: 12, PP: 12, PE: 12, PB: 12, Spd: 12 };
const baClass = { attributes: {}, combat: { attacks: 1 }, saves: {} };
const baBoth  = { attributes: {}, combat: { attacks: 3 }, saves: {} };

// Omitting the class-only block keeps the old behaviour exactly: every caller
// before skills could grant anything passed four arguments.
check('without a class-only block everything is from_class', (() => {
  const p = D.parts('combat', baStats, baBoth);
  return p.attacks.from_class === 3 && p.attacks.from_skills === 0;
})());

check('with one, the class and skill halves are separated', (() => {
  const p = D.parts('combat', baStats, baBoth, undefined, baClass);
  return p.attacks.from_class === 1 && p.attacks.from_skills === 2;
})());

check('a bonus entirely from skills reports no class half', (() => {
  const p = D.parts('combat', baStats, baBoth, undefined,
    { attributes: {}, combat: {}, saves: {} });
  return p.attacks.from_class === 0 && p.attacks.from_skills === 3;
})());

// An attribute bonus reaches combat through the tables, not directly, so the
// split has to survive that route too.
check('an attribute-driven bonus is attributed correctly', (() => {
  const cls = { attributes: { PP: 6 }, combat: {}, saves: {} };
  const both = { attributes: { PP: 12 }, combat: {}, saves: {} };
  const p = D.parts('combat', baStats, both, undefined, cls);
  return p.parry.from_class > 0 && p.parry.from_skills > 0
    && p.parry.from_class + p.parry.from_skills
       === D.parts('combat', baStats, both).parry.from_class;
})());

check('saves split the same way', (() => {
  const p = D.parts('saves', baStats,
    { attributes: {}, combat: {}, saves: { spell_magic: 4 } }, null,
    { attributes: {}, combat: {}, saves: { spell_magic: 1 } });
  return p.spell_magic.from_class === 1 && p.spell_magic.from_skills === 3;
})());


// ---------- Catalog name matching ----------
section('Catalog matching');

// Every case below is a mistake that shipped or nearly shipped during the RUE
// import. The matcher exists because the same class of error kept producing
// confident, wrong answers, so these are pinned rather than remembered.

check('normalise folds & to and', normalise('Control & Enslave Entity') === 'control and enslave entity');
check('stem drops a parenthetical', stem('Object Read (Psychometry)') === 'object read');
check('loose drops connectives', loose('Animate and Control Dead') === 'animate control dead');

// A catalog shaped like the real one: the pairs that broke things are here.
const MATCH_ROWS = [
  { name: 'Bio-Regeneration' },              // RUE prints "Bio-Regenerate (self)"
  { name: 'Bio-Regeneration (Super)' },
  { name: 'Telekinesis' },
  { name: 'Telekinesis (Super)' },
  { name: 'Telekinetic Punch' },
  { name: 'Telekinetic Leap' },
  { name: 'Commune with Spirit' },           // RUE prints the plural
  { name: 'Impervious to Poison/Toxin' },    // RUE prints "Impervious to Poison"
  { name: 'Object Read (Psychometry)' },     // RUE prints "Object Read"
  { name: 'Control & Enslave Entity' },      // RUE prints "Control/Enslave Entity"
  { name: 'Animate and Control Dead' },      // RUE prints "Animate/Control Dead"
  { name: 'Power Weapon' },                  // RUE prints the plural
  { name: 'Swim as a Fish (lesser)' },       // three candidates - unresolvable
  { name: 'Swim as a Fish (Superior)' },
  { name: 'Water: Swim as a Fish: Superior' },
];
const MATCH_IDX = buildIndex(MATCH_ROWS);
const hit = (n, book = []) =>
  match(n, MATCH_IDX, aliasCounts(book.map((x) => ({ name: x }))))?.row?.name ?? null;

// --- must match: the same thing spelled differently ---
check('plural on the last word', hit('Commune with Spirits') === 'Commune with Spirit');
check('plural, other direction', hit('Power Weapons') === 'Power Weapon');
check('slash half meets the whole', hit('Impervious to Poison') === 'Impervious to Poison/Toxin');
check('book omits a parenthetical', hit('Object Read') === 'Object Read (Psychometry)');
check('slash vs ampersand', hit('Control/Enslave Entity') === 'Control & Enslave Entity');
check('slash vs the word and', hit('Animate/Control Dead') === 'Animate and Control Dead');

// --- must NOT match: different things that look alike ---
// These are the expensive direction. Collapsing either pair produced confident
// "corrections" to rows that were already right.
const BIO_BOOK = ['Bio-Regenerate (self)', 'Bio-Regeneration (Super)'];
check('Bio-Regeneration pair stays split',
  hit('Bio-Regeneration (Super)', BIO_BOOK) === 'Bio-Regeneration (Super)');
const TK_BOOK = ['Telekinesis', 'Telekinesis (Super)'];
check('Telekinesis exact still wins over its Super sibling',
  hit('Telekinesis', TK_BOOK) === 'Telekinesis');
check('Telekinesis (Super) does not collapse onto Telekinesis',
  hit('Telekinesis (Super)', TK_BOOK) === 'Telekinesis (Super)');
check('Push is not Punch', hit('Telekinetic Push') === null);
check('Lift is not Leap', hit('Telekinetic Lift') === null);

// Ambiguity on the CATALOG side must refuse too: "Swim as a Fish" has three
// candidates and picking one is a coin flip.
check('ambiguous catalog stem refuses to match', hit('Swim as a Fish') === null);

// nearest() is reporting only, and this is exactly why: the closer pair is the
// one that must not be merged.
check('nearest is advisory, not a verdict', (() => {
  const push = nearest('Telekinetic Push', MATCH_IDX);
  const animate = nearest('Animate/Control Dead', MATCH_IDX);
  // Push/Punch is nearer than Animate/Control Dead vs Animate and Control Dead,
  // yet Push must not merge and Animate must.
  return push.distance < animate.distance
      && hit('Telekinetic Push') === null
      && hit('Animate/Control Dead') === 'Animate and Control Dead';
})());

check('variants stay small', variants('Commune with Spirits').length <= 4);

// --- the diff, end to end ---
check('diffCatalog separates corrections from gaps', (() => {
  const entries = [
    { name: 'Commune with Spirits', isp: 6 },   // present, cost disagrees
    { name: 'Telekinetic Punch', isp: 6 },      // present, agrees
    { name: 'Telekinetic Push', isp: 4 },       // genuinely missing
  ];
  const rows = [
    { name: 'Commune with Spirit', isp: 8 },
    { name: 'Telekinetic Punch', isp: 6 },
  ];
  const d = diffCatalog({
    entries, rows,
    fields: { isp: { book: (e) => e.isp, row: (r) => r.isp } },
  });
  return d.disagree.length === 1 && d.disagree[0].diffs[0].catalog === 8
      && d.matched.length === 1
      && d.missing.length === 1 && d.missing[0].entry.name === 'Telekinetic Push'
      && d.missing[0].nearest.row.name === 'Telekinetic Punch';
})());

// A field where nearly every disagreement is the SAME substitution is one
// vocabulary difference, not N corrections. 22 of 23 reported category errors
// were the book writing "Super-Psionics" where the catalog says "Super";
// applying them would have broken every picker that filters on category.
check('vocabulary difference is flagged, not applied', (() => {
  const rows = [], entries = [];
  for (let i = 0; i < 12; i++) {
    rows.push({ name: `Power ${i}`, category: 'Super' });
    entries.push({ name: `Power ${i}`, category: 'Super-Psionics' });
  }
  const d = diffCatalog({ entries, rows,
    fields: { category: { book: (e) => e.category, row: (r) => r.category } } });
  const w = vocabularyWarnings(d);
  return d.disagree.length === 12 && w.length === 1
      && w[0].from === 'Super-Psionics' && w[0].to === 'Super';
})());

// And it must stay quiet for real corrections, which spread across values.
// The six RUE spell levels were 7->6 three times and 9->8 three times: no
// single substitution dominates, and every one of them was a genuine fix.
check('genuine corrections raise no vocabulary warning', (() => {
  const entries = [
    { name: 'Teleport: Lesser', level: 6 }, { name: 'Tongues', level: 6 },
    { name: 'Words of Truth', level: 6 }, { name: 'Sickness', level: 8 },
    { name: 'Spoil', level: 8 }, { name: 'Wisps of Confusion', level: 8 },
  ];
  const rows = entries.map((e) => ({ name: e.name, level: e.level + 1 }));
  const d = diffCatalog({ entries, rows,
    fields: { level: { book: (e) => e.level, row: (r) => r.level } } });
  return d.disagree.length === 6 && vocabularyWarnings(d).length === 0;
})());

check('diffCatalog reports catalog rows the book never mentions', (() => {
  const d = diffCatalog({
    entries: [{ name: 'Telekinetic Punch' }],
    rows: [{ name: 'Telekinetic Punch' }, { name: 'Attack Disease' }],
  });
  return d.extra.length === 1 && d.extra[0].name === 'Attack Disease';
})());


// The environment half lives in its own file; it runs last because it is the
// slow one - it shells out to wrangler.
environmentChecks();
catalogDataChecks();

process.exit(summary() === 0 ? 0 : 1);
