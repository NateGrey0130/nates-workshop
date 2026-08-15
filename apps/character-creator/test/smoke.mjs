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
  classifyRows, slugify,
} from '../../../functions/api/character-creator/_lib/import-engine.js';
import { stageRows } from '../../../functions/api/character-creator/_lib/import-sessions.js';
import { paging } from '../../../functions/api/character-creator/_lib/paging.js';
import { skillGrantsFor } from '../../../functions/api/character-creator/_lib/leveling.js';
import { similarity, normaliseName, classesMentioning } from '../../../functions/api/character-creator/_lib/catalog-merge.js';
import {
  keysOf, redirectStatements, collapseStatement, resolveKeys,
} from '../../../functions/api/character-creator/_lib/catalog-redirects.js';
import { validateCharacter, relatedAllowance } from '../../../functions/api/character-creator/_lib/validate-character.js';

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
console.log('\n[1c2] Level-up skill grants');
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
console.log('\n[1c3] Character validation');
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

// ---------- 1c4. Psychic tiers ----------
// derive.js is a classic script, so it is loaded by evaluating it against a
// stand-in global rather than imported.
console.log('\n[1c4] Psychic tiers');
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
  return strong.psionics === weak.psionics && strong.psionics === 3;
})());
check('a stored override still wins over the derived target',
  D.saves({ ME: 10 }, { psionics_target: 8 }, 'minor').psionics_target === 8);

// ---------- 1c5. Duplicate detection ----------
// Every pair below is a REAL clash found importing the Rifts skill chapter:
// the book and the hand-seeded catalog name the same skill differently, and
// exact-name dedupe in the importers cannot see any of them.
console.log('\n[1c5] Duplicate detection');
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
console.log('\n[1c6] Catalog redirects');

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

// ---------- 1d. Paging ----------
// A stray query string must not turn a list endpoint into a 400, so anything
// nonsensical falls back to the default rather than erroring.
console.log('\n[1d] Paging');
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
  "SELECT (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('campaigns','characters','journal_entries','level_history','gear','character_items')) AS cc_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'media_items') AS media_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN ('imported_classes','skills','spells','psionic_powers')) AS catalog_tables, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='catalog_redirects') AS redirect_table, (SELECT count(*) FROM sqlite_master WHERE type='table' AND name='items') AS stale_items_table, (SELECT sql FROM sqlite_master WHERE name='character_items') AS ci_ddl;\n");
const query = wrangler(['d1', 'execute', 'DB', '--local', '--json', '--file', checkSql]);
rmSync(checkSql, { force: true });
let row = null;
try { row = JSON.parse(query.stdout)[0].results[0]; } catch { /* fall through to checks */ }
check('all 6 character-creator tables exist', row?.cc_tables === 6, query.stdout?.slice(-300));
check('media_items still intact alongside them', row?.media_tables === 1);
check('class + catalog tables exist', row?.catalog_tables === 4, query.stdout?.slice(-300));
check('catalog_redirects exists', row?.redirect_table === 1, query.stdout?.slice(-300));

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
