// Smoke test: (1) the RCC/OCC markdown files parse correctly, (2) the D1 schema
// migrates cleanly into a local D1 instance, (3) db/schema.sql alone is enough
// to build a current database, and (4) every migration on disk is recorded as
// applied to that database.
//
// (3) and (4) look alike and are not: (4) asks what the local database has had
// done to it, (3) asks what a brand-new environment would get. Only (3) sees a
// migration whose column never made it back into schema.sql.
// Run from anywhere:  node apps/character-creator/test/smoke.mjs
//
// Between edits: `--section <name>` runs only the sections whose names contain
// <name> (case-insensitive; repeatable, or comma-separated) and skips the
// wrangler-backed environment half, which is nearly all of the wall clock.
// The merge gate is the FLAGLESS run — a partial run says PARTIAL in its
// summary line so its output cannot be quoted as the gate's.

function parseFile(name) {
  return parseClassMarkdown(readFileSync(join(appDir, 'test', 'fixtures', name), 'utf8'));
}

// ---------- 1. Parser ----------
section('Parser');

// Custom languages: three consumers (wizard, sheet, server validator) share
// these, so the rule is asserted here once rather than trusted three times.
check('familySkillName composes', familySkillName(LANGUAGE_OTHER, 'Spanish') === 'Language: Spanish');
check('familySkillName tolerates typed prefix',
  familySkillName(LANGUAGE_OTHER, 'language:  Orc') === 'Language: Orc');
check('familySkillName rejects blank', familySkillName(LANGUAGE_OTHER, '   ') === null
  && familySkillName(LANGUAGE_OTHER, 'Language:') === null);
check('isFamilyName covers the Language family',
  isFamilyName('Language: Elvish') && isFamilyName(LANGUAGE_OTHER) && !isFamilyName('Sign Language'));

// LITERACY is the second family, and it had no rule at all until now: the same
// row, for reading rather than speaking, treated as one ordinary skill.
check('and the Literacy family', isFamilyName('Literacy: Elven') && isFamilyName(LITERACY_OTHER));
check('but not the bare Literacy row', !isFamilyName('Literacy'));
check('familySkillName composes a written language',
  familySkillName(LITERACY_OTHER, 'Gobblely') === 'Literacy: Gobblely');
check('and tolerates the typed prefix there too',
  familySkillName(LITERACY_OTHER, 'literacy: Elven') === 'Literacy: Elven');
check('the Other rows are repeatable and their members are not',
  isRepeatableRow(LANGUAGE_OTHER) && isRepeatableRow(LITERACY_OTHER)
  && !isRepeatableRow('Language: Elven') && !isRepeatableRow('Literacy: Elven'));
// A member takes its numbers from ITS OWN family's row. Crossing them would
// price a written language off the spoken row, which is a different percentage.
check('each family resolves to its own Other row',
  otherRowFor('Language: Elven') === LANGUAGE_OTHER
  && otherRowFor('Literacy: Elven') === LITERACY_OTHER
  && otherRowFor('Boxing') === null);

// A FOURTH consumer: an occ_skills choice group. Seven classes say "two
// languages of choice" and were written as the whole Technical category,
// because the repeatable-row rule only ever reached the related/secondary
// picker. In a group the same row was a plain checkbox, so ticking it gave the
// character a skill named, literally, "Language: Other" - which two Priests of
// Light in production are carrying.
{
  const group = (line) => parseClassMarkdown([
    '---', 'id: t', 'name: T', 'system: rifts', 'source_book: b', 'category: occ',
    'skills:', '  occ_skills:', '    ' + line,
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));

  // The count check has to KNOW the row is repeatable, or "three languages of
  // choice" cannot be written at all.
  check('a group may ask for more languages than the from list is long',
    group('- { choose: 3, from: ["Language: Other"], bonus: 30 }').errors.length === 0);
  check('and the same exemption does not loosen an ordinary from list',
    group('- { choose: 3, from: ["Boxing", "Prowl"] }').errors.length === 1);
  check('a mixed list carrying the repeatable row is exempt too',
    group('- { choose: 3, from: ["Language: Other", "Language: Dragonese"] }').errors.length === 0);

  // Both wizard controls have to apply the rule, and they are separate
  // functions: toggleSkill for related/secondary, toggleGroupPick for a group.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const fn = (name) => {
    const at = appSrc.indexOf(`function ${name}(`);
    return at < 0 ? '' : appSrc.slice(at, appSrc.indexOf('\n}\n', at));
  };
  check('toggleSkill prompts for the language', fn('toggleSkill').includes('isRepeatableRow'));
  check('and toggleGroupPick does too', fn('toggleGroupPick').includes('isRepeatableRow'));
  // The pick is stored under the language's OWN name, which has no catalog row
  // by design - so the resolver has to fall back, or it saves at 0% +0/lvl.
  check('resolveSkill falls back to the Other row for a named language',
    fn('resolveSkill').includes('isFamilyName') && fn('resolveSkill').includes('otherRowFor'));
  // Neither control may hardcode ONE family's row: the same rule covers spoken
  // languages and written ones, and hardcoding is how literacy was left out.
  for (const name of ['toggleSkill', 'toggleGroupPick', 'resolveSkill']) {
    check(`${name} names no single family's row`, !fn(name).includes('LANGUAGE_OTHER'),
      'use isRepeatableRow / otherRowFor');
  }

  // And no class may go back to offering a whole category for languages.
  const dbDir = join(appDir, 'db');
  const offending = readdirSync(dbDir).filter((f) => f.endsWith('.sql'))
    .filter((f) => readFileSync(join(dbDir, f), 'utf8').includes('no individual language rows'))
    .filter((f) => f > 'fix-language-picks.sql');
  check('no data script after the fix reintroduces the category offer',
    offending.length === 0, offending.join(', '));
}

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

// ---------- 1a2. Escaping a value into markup ----------
// Two contexts, two escapes, and for a long time one function.
//
// escHtml was textContent -> innerHTML, which does not escape `"`, and 25 call
// sites put its result inside a double-quoted attribute. A gear row named
// "Rolling Thunder" All-Purpose Vehicle rendered its Name input EMPTY; a
// skill's bonuses JSON rendered as value="{" plus the rest of the JSON
// reparsed as attribute names, and saving that row wrote `{` back over the
// bonuses.
//
// The inline handlers had the mirror of it: escHtml(v).replace(/'/g, '&#39;')
// in six places, which is correct for the attribute and wrong for the JS
// inside it - an attribute is entity-decoded BEFORE its contents are parsed as
// JavaScript, so &#39; hands the apostrophe back to the string literal it was
// meant to escape.
//
// These are behavioural rather than textual: the two functions are pure now,
// so the test runs them, decodes the result the way a browser would, and
// requires the value that comes back out to be the value that went in.
section('Escaping a value into markup');
{
  const ui = readFileSync(join(repoRoot, 'shared', 'js', 'ui.js'), 'utf8');
  const start = ui.indexOf('function escHtml');
  const jsStart = ui.indexOf('function escJs', start);
  const end = ui.indexOf('\n}', jsStart) + 2;
  check('shared/js/ui.js exports both escapes',
    start !== -1 && jsStart !== -1, 'escHtml or escJs is gone');
  const { escHtml: eh, escJs: ej } =
    new Function(ui.slice(start, end) + '\nreturn { escHtml, escJs };')();

  // How a browser reads an attribute value back.
  const decode = (s) => s.replace(/&quot;/g, '"').replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>').replace(/&amp;/g, '&');

  const cases = [
    ['"Rolling Thunder" All-Purpose Vehicle', 'a gear name that carries quotes'],
    ['{"attributes":{"PS":1},"combat":{"roll":2}}', "a skill's bonuses JSON"],
    ["Dragon's Claw", 'an apostrophe'],
    ['A & B <tag>', 'an ampersand and a tag'],
    ['back\\slash', 'a backslash'],
  ];
  const attrBad = cases.filter(([v]) => decode(eh(v)) !== v).map(([, w]) => w);
  check('a value survives value="..." and comes back out whole', attrBad.length === 0,
    `broken: ${attrBad.join('; ')}`);

  // eslint-disable-next-line no-eval -- this IS the thing being tested: the
  // string the browser hands to the JS parser after decoding the attribute.
  const jsBad = cases.filter(([v]) => {
    try { return eval("'" + decode(ej(v)) + "'") !== v; } catch { return true; }
  }).map(([, w]) => w);
  check('and survives onclick="fn(\'...\')" as a JS string literal', jsBad.length === 0,
    `broken: ${jsBad.join('; ')}`);

  check('escHtml escapes the quote it used to leave alone',
    eh('"') === '&quot;', 'escHtml is back to a text-node-only escape');
  // Coercion is what 200-odd call sites were written against.
  check('and coerces the way the textContent setter did',
    eh(null) === '' && eh(undefined) === 'undefined' && eh(12) === '12',
    'null/undefined/number no longer stringify as they did');

  // The workarounds this replaces. Each was correct about the attribute and
  // wrong about what the attribute contained, and each carried a comment
  // saying escHtml leaves quotes alone - which is now false.
  // Comments stripped first. Both files that lost a workaround now carry a
  // comment SAYING what the workaround was, which reads to a naive search
  // exactly like the workaround - the same trap the landing-page check names.
  const consumers = ['sheet.js', 'app.js', 'campaign.js', 'catalog.js']
    .map((f) => readFileSync(join(appDir, f), 'utf8'))
    .join('\n')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/^\s*\/\/.*$/gm, '');
  check('no call site still patches the apostrophe by hand',
    !/replace\(\/'\/g, ?['"]&#39;['"]\)/.test(consumers),
    "an escHtml(...).replace(/'/g,'&#39;') is back; it breaks the handler it is meant to fix");
  check('and none still patches the double quote by hand',
    !/replace\(\/"\/g, ?'&quot;'\)/.test(consumers),
    'a second escaping pass is back; escHtml does it now');
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
  const cat = readFileSync(join(appDir, 'catalog.js'), 'utf8');

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
// systems: neither system picked and both picked both mean "applies to both".
const sysField = CATALOGS.skills.fields.find((f) => f.name === 'systems');
check('systems: empty and all-selected both store NULL',
  coerceField(sysField, []).value === null && coerceField(sysField, ['rifts', 'palladium-fantasy']).value === null);
check('systems: one system stores a JSON array',
  coerceField(sysField, ['rifts']).value === '["rifts"]');

import { classesMentioning, findDuplicates, normaliseName, similarity } from '../../../functions/api/character-creator/_lib/catalog-merge.js';
import { collapseStatement, keysOf, redirectStatements, resolveKeys } from '../../../functions/api/character-creator/_lib/catalog-redirects.js';
import { buildStubStatements, referencedGear, restrictionNames } from '../../../functions/api/character-creator/_lib/catalog.js';
import { CHARACTER_JSON_COLUMNS } from '../../../functions/api/character-creator/_lib/character-json.js';
import { composeSourceBook } from '../../../scripts/source-book-lib.mjs';
import { buildProposal, perLevelDiceOf, skillGrantsFor, spellGrantsFor, psionicGrantsFor,
         xpTableFor, thresholdFor, spellLevelsForGrant,
         psionicCategoriesForGrant, spellNamesForGrant,
         grantNote, startingPicksFor } from '../../../functions/api/character-creator/_lib/leveling.js';
import { toMatchQuery } from '../../../functions/api/character-creator/campaigns/[id]/search.js';
import { powerGrantsFor, remainingPowerGrants } from '../../../functions/api/character-creator/_lib/power-picks.js';
import { resolvePicks } from '../../../functions/api/character-creator/_lib/skill-picks.js';
import { aliasCounts, buildIndex, diffCatalog, loose, match, nearest, normalise,
         stem, variants, vocabularyWarnings } from '../../../scripts/catalog-match-lib.mjs';
import { dice, isMegaDamage, isVariableCost, money, weightLbs }
  from '../../../scripts/ocr-fields-lib.mjs';
import { parseMentions } from '../../../functions/api/character-creator/_lib/mentions.js';
import { paging } from '../../../functions/api/character-creator/_lib/paging.js';
import { dedupeCategories } from '../../../functions/api/character-creator/_lib/skill-picks.js';
import { relatedAllowance, validateCharacter } from '../../../functions/api/character-creator/_lib/validate-character.js';
import {
  crossCategoryRestrictions, extractClassMarkdown, unmodelledKeys, unclosedFlowLines,
  parseSourcePages, resolveBookSlug, registryBookSlug, normalizeBookTitle, detectPageOffset,
  detectPageOffsetRegions, offsetForPrintedPage, isNotABook,
  freeTextFields, fieldTokens,
  fieldSourceSpans, bestMatchingPages,
} from '../../../scripts/class-check-lib.mjs';
import { bookSpellings, bookTitles, cacheCoverage, loadBookRegistry, loadNotBooks } from '../../../scripts/books-lib.mjs';
import { bucketFor, summarise, summariseValues, valuePresent, valueSpellings }
  from '../../../scripts/source-coverage-lib.mjs';
import { buildUserPrompt, SYSTEM_PROMPT_CACHE } from '../../../scripts/extraction-prompt.mjs';
import { collapseWhitespace, statements, stripComments, trailingSelects } from '../../../scripts/sql-statements.mjs';
import { CATALOGS, coerceField } from '../js/catalog-fields.js';
import { composeClass } from '../js/compose.js';
import { evalDice, fixedFormulaValue, rollAttribute, rollPoolFormula, rollQuantity,
         poolFormulaBounds, diceBounds, attributeCeiling,
         isAttributeExpr, isAbsentAttribute } from '../js/dice.js';
import { validateMos } from '../js/parser.js';
import { skillBase, isBaseFormula } from '../js/skill-base.js';
import { chunks, D1_MAX_BINDS, BIND_CHUNK } from '../../../functions/api/character-creator/_lib/sql-chunk.js';
import { LANGUAGE_OTHER, LITERACY_OTHER, isFamilyName, isRepeatableRow,
         otherRowFor, familySkillName } from '../js/language-skills.js';
import { ABILITY_GRANTS, POOL_BONUS_KEYS, VARIANT_OVERRIDES, abilityOccOptions, abilityOptions, applyAbilities, applyVariant, bonusesFromSkills, categoryAllows, categoryBonus, categoryLabel, combineClasses, isGearChoice, needsOccupation, parseClassMarkdown, parseYaml, relatedFloorStatus, relatedMinimums, sumBonusGroups, validateBonuses } from '../js/parser.js';
import { PSIONIC_TIER_RULES, psionicShape, psionicTierForRoll, rollPsionics, rollsForPsionics, withRolledPsionics } from '../js/psionics.js';
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { appDir, repoRoot, check, section, summary } from './harness.mjs';
import { run as environmentChecks } from './checks/environment.mjs';
import { run as catalogDataChecks } from './checks/catalog-data.mjs';
import { run as documentedCountsChecks } from './checks/documented-counts.mjs';
import { run as bookRegistryChecks } from './checks/book-registry.mjs';
import { run as renderedUiChecks } from './checks/rendered-ui.mjs';
import { run as classCheckToolChecks } from './checks/class-check-tool.mjs';
import { run as catalogMatchingChecks } from './checks/catalog-matching.mjs';
import { run as instructionPathChecks } from './checks/instruction-paths.mjs';
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

// A per-category FLOOR, refused server-side (F6). Unlike the count and category
// rules above it cannot fire on a half-built character: a floor not yet met may
// still be met by picks not yet spent, so only an UNREACHABLE one is a
// violation. Without that gate every partial save would be refused.
{
  const floorCls = { ...vCls, name: 'Floor Test', skills: { ...vCls.skills,
    occ_related_skills: { count: 2, categories: ['Physical', 'Rogue'],
                          schedule: [{ level: 3, count: 1 }],
                          minimums: [{ count: 1, category: 'Rogue' }] } } };
  const withFloor = (relSkills) => validateCharacter({ ...legal, cls: floorCls,
    skills: legal.skills.filter((x) => x.type !== 'related').concat(relSkills) })
    .violations.map((v) => v.rule);

  check('a floor met is no violation',
    !withFloor([rel('Climbing', 'Physical'), rel('Prowl', 'Rogue')]).includes('related_minimum'));
  check('a floor spent out and unmet is a violation',
    withFloor([rel('Climbing', 'Physical'), rel('Swimming', 'Physical')]).includes('related_minimum'));
  check('a floor with a pick still to spend is NOT a violation',
    !withFloor([rel('Climbing', 'Physical')]).includes('related_minimum'));
  check('a class with no floors is never refused for one',
    !vio({}).includes('related_minimum'));
  // The allowance grows on a schedule, and a floor rides along with it rather
  // than fighting it: level 3 grants one more pick, which is a pick the floor
  // can still be met with.
  check('a scheduled grant reopens a floor that was spent out',
    !validateCharacter({ ...legal, cls: floorCls, character: { level: 3 },
      skills: legal.skills.filter((x) => x.type !== 'related')
        .concat([rel('Climbing', 'Physical'), rel('Swimming', 'Physical')]) })
      .violations.map((v) => v.rule).includes('related_minimum'));
}
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

// ---------- 1c3b. Creation-time powers, pool bounds, attribute ceilings ----
// The audit's F2. The powers a character is CREATED holding get the boundary
// level-up picks always had; pool maxima and attributes get advisory range
// checks. Violations only where no legitimate path exists — the class's
// auto-granted powers are exempt, per-grant attribution is never guessed at
// (a pick passes if ANY applicable pool admits it), and everything a class
// edit or a table ruling could explain warns instead of blocking.
section('Creation validation');
{
  const magicCls = { ...vCls, magic: { spells_starting: 2, spell_levels_allowed: [1, 2] } };
  const pcat = {
    spell: new Map([
      ['zap', { name: 'Zap', level: 1, ppe: 2, system: null }],
      ['big zap', { name: 'Big Zap', level: 5, ppe: 20, system: null }],
      ['gold zap', { name: 'Gold Zap', level: 1, ppe: 2, system: 'palladium-fantasy' }],
    ]),
    psionic: new Map([
      ['see', { name: 'See', category: 'Sensitive', isp: 2, system: null }],
      ['mend', { name: 'Mend', category: 'Healing', isp: 4, system: null }],
      ['crush', { name: 'Crush', category: 'Super', isp: 10, system: null }],
    ]),
  };
  const val = (o) => validateCharacter({ ...legal, cls: magicCls, powerCatalog: pcat, ...o });
  const rules = (o) => val(o).violations.map((v) => v.rule);
  const sp = (n) => ({ type: 'spell', name: n });
  const psi = (n) => ({ type: 'psionic', name: n });

  check('powers within the starting allowance pass',
    rules({ powers: [sp('Zap')] }).length === 0,
    JSON.stringify(val({ powers: [sp('Zap')] }).violations));
  check('a caller that supplies no powers has none checked', rules({}).length === 0);
  check('over the starting count is a violation',
    rules({ powers: [sp('Zap'), sp('Gold Zap'), sp('Big Zap')] }).includes('power_count'));
  check('a spell above the allowed levels is a violation',
    rules({ powers: [sp('Big Zap')] }).includes('power_level_cap'));
  check('a power the catalog lacks is a violation',
    rules({ powers: [sp('Nonsense')] }).includes('power_unknown'));
  check('a wrong-system pick is named as such, not reported missing',
    rules({ system: 'rifts', powers: [sp('Gold Zap')] }).includes('power_system'));
  check('an auto-granted power is exempt from the count and the caps', (() => {
    const cls2 = { ...vCls, magic: { spells_starting: 1, spell_levels_allowed: [1], spells: ['Big Zap'] } };
    return validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      powers: [sp('Big Zap'), sp('Zap')] }).violations.length === 0;
  })());
  check('a duplicated power is a violation',
    rules({ powers: [sp('Zap'), sp('Zap')] }).includes('duplicate_power'));
  check('a psionic outside the allowed categories is a violation', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 2, categories_allowed: ['Sensitive', 'Healing'] } };
    return validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Crush')] })
      .violations.some((v) => v.rule === 'power_category');
  })());
  check('a named list replaces the category gate, both ways', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 2, categories_allowed: ['Sensitive'], powers_from: ['Crush'] } };
    const on = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Crush')] });
    const off = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Mend')] });
    return on.violations.length === 0 && off.violations.some((v) => v.rule === 'power_not_on_list');
  })());
  // The starting pick used to be ONE count and ONE gate, so a spell pick could
  // not be bounded by a name at all and a split pick had to be flattened into
  // its widest gate - which is how the Delphi Juicer came to allow four Super
  // where its book grants one. CLASS-AUDIT.md S1 and S9.
  check('a named list bounds the STARTING spell pick, not just a level cap', (() => {
    const cls2 = { ...vCls, magic: { spells_starting: 1, spell_levels_allowed: [1, 2], spells_from: ['Big Zap'] } };
    // Big Zap is a level 5 spell, so the named list has to REPLACE the cap
    // rather than intersect with it, or the book's own list would be illegal.
    const on = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [sp('Big Zap')] });
    const off = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [sp('Zap')] });
    return on.violations.length === 0 && off.violations.some((v) => v.rule === 'power_not_on_list');
  })());
  check('a split starting pick holds each group to its own categories', (() => {
    const cls2 = { ...vCls, psionics: { type: 'master', powers_starting: 2,
      powers_starting_groups: [{ count: 1, categories: ['Healing'] }, { count: 1, categories: ['Super'] }] } };
    const legalPick = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      powers: [psi('Mend'), psi('Crush')] });
    // Two Super is the loadout the flattened shape allowed and the book forbids.
    const bothSuper = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      powers: [psi('Crush'), psi('See')] });
    return legalPick.violations.length === 0
        && bothSuper.violations.some((v) => v.rule === 'power_category');
  })());
  check('a split pick still counts against the total, not per group', (() => {
    const cls2 = { ...vCls, psionics: { type: 'master', powers_starting: 2,
      powers_starting_groups: [{ count: 1, categories: ['Healing'] }, { count: 1, categories: ['Super'] }] } };
    return validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      powers: [psi('Mend'), psi('Crush'), psi('See')] }).violations.some((v) => v.rule === 'power_count');
  })());
  check('a group inherits the block gate when it names none', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 2, categories_allowed: ['Healing'],
      powers_starting_groups: [{ count: 1 }, { count: 1, categories: ['Sensitive'] }] } };
    const ok = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Mend'), psi('See')] });
    const no = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Crush')] });
    return ok.violations.length === 0 && no.violations.some((v) => v.rule === 'power_category');
  })());
  check('stating only a count is unchanged by any of this', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 2, categories_allowed: ['Sensitive', 'Healing'] } };
    return validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('See'), psi('Mend')] })
      .violations.length === 0;
  })());
  check('a rolled focused psychic must keep to one category', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 8,
      categories_allowed: ['Healing', 'Physical', 'Sensitive'], from_roll: true } };
    return validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      character: { level: 1, psychic_shape: 'focused' }, powers: [psi('See'), psi('Mend')] })
      .violations.some((v) => v.rule === 'psionic_single_category');
  })());
  check('per-level grants raise the allowance for a veteran build', (() => {
    const cls2 = { ...vCls, magic: { spells_starting: 1, spells_per_level: 1 } };
    const three = [sp('Zap'), sp('Big Zap'), sp('Gold Zap')];
    const atOne = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: three });
    const atThree = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: three,
      character: { level: 3 } });
    return atOne.violations.some((v) => v.rule === 'power_count')
        && !atThree.violations.some((v) => v.rule === 'power_count');
  })());
  check('every power violation carries a readable message', (() => {
    const all = val({ system: 'rifts',
      powers: [sp('Zap'), sp('Zap'), sp('Big Zap'), sp('Nonsense'), sp('Gold Zap')] }).violations;
    return all.length >= 4 && all.every((v) => typeof v.message === 'string' && v.message.trim());
  })());

  // Pool maxima: the dice are rolled client-side by design, so the check is
  // what the formula COULD roll, and a warning rather than a violation - a
  // re-imported formula would falsify an honest roll.
  const poolCls = { ...vCls, hit_points_base: 'P.E. + 1d6 per level', sdc_base: '3d6',
    bonuses: { pools: { sdc: 12 } } };
  const pw = (pools, character = { level: 1 }) => validateCharacter({
    ...legal, cls: poolCls, attributes: { ME: 14, PE: 10 }, pools, character });
  check('a pool inside its formula range raises nothing',
    !pw({ hp_max: 12, sdc_max: 20 }).warnings.some((w) => w.rule === 'pool_out_of_range'));
  check('a pool outside it warns rather than blocks', (() => {
    const r = pw({ hp_max: 900 });
    return r.warnings.some((w) => w.rule === 'pool_out_of_range') && r.violations.length === 0;
  })());
  check('a pool bonus widens the range it checks against',
    !pw({ sdc_max: 30 }).warnings.some((w) => w.rule === 'pool_out_of_range')
    && pw({ sdc_max: 31 }).warnings.some((w) => w.rule === 'pool_out_of_range'));
  check('the range grows with the levels climbed',
    pw({ hp_max: 40 }).warnings.some((w) => w.rule === 'pool_out_of_range')
    && !pw({ hp_max: 40 }, { level: 6 }).warnings.some((w) => w.rule === 'pool_out_of_range'));
  check('a pool with no formula is skipped, never guessed at',
    !pw({ mdc_max: 5000 }).warnings.some((w) => w.rule === 'pool_out_of_range'));

  // The hard cap (F2 follow-up): the same finding becomes a violation when the
  // caller enforces — the create endpoint does, for a creator who is not the
  // campaign's GM — and stays the GM's warning otherwise. One finding, one
  // range computation, two homes; it must never appear in both.
  check('enforced, an out-of-range pool is a violation that names the range', (() => {
    const r = validateCharacter({ ...legal, cls: poolCls, attributes: { ME: 14, PE: 10 },
      pools: { hp_max: 900 }, enforcePools: true });
    const v = r.violations.find((x) => x.rule === 'pool_out_of_range');
    return !!v && /11-16/.test(v.message)
      && !r.warnings.some((x) => x.rule === 'pool_out_of_range');
  })());
  check('enforced, a rollable pool still passes',
    validateCharacter({ ...legal, cls: poolCls, attributes: { ME: 14, PE: 10 },
      pools: { hp_max: 12 }, enforcePools: true }).violations.length === 0);
  check('unenforced stays the warning — the GM tolerance and the audit', (() => {
    const r = validateCharacter({ ...legal, cls: poolCls, attributes: { ME: 14, PE: 10 },
      pools: { hp_max: 900 } });
    return r.violations.length === 0 && r.warnings.some((w) => w.rule === 'pool_out_of_range');
  })());

  // Attribute ceilings: advisory, because Manual entry exists for numbers a
  // table decided, and the app must not become the GM.
  check('an attribute above its dice ceiling warns and never blocks', (() => {
    const r = validateCharacter({ ...legal, attributes: { ME: 14, PS: 45 } });
    return r.warnings.some((w) => w.rule === 'attribute_above_ceiling' && w.attribute === 'PS')
        && r.violations.length === 0;
  })());
  check('30 off a plain 3d6 is exceptional dice, not a flag',
    !validateCharacter({ ...legal, attributes: { ME: 14, PS: 30 } })
      .warnings.some((w) => w.rule === 'attribute_above_ceiling'));
  check('racial dice raise the ceiling with them', (() => {
    const cls2 = { ...vCls, attribute_dice: { PS: '4d6+12' } };
    return !validateCharacter({ ...legal, cls: cls2, attributes: { ME: 14, PS: 34 } })
      .warnings.some((w) => w.rule === 'attribute_above_ceiling');
  })());

  // The primitives, pinned directly: one parse path serves the roll and the
  // bounds, so these numbers are the contract.
  check('poolFormulaBounds brackets the Stone Master formula exactly',
    JSON.stringify(poolFormulaBounds('P.E. x2 + 2d6 per level', { PE: 18 }, 30)) === '{"min":68,"max":78}');
  check('diceBounds reads a modifier with the dice',
    JSON.stringify(diceBounds('1d6+1')) === '{"min":2,"max":7}');
  check('attributeCeiling knows the exceptional chain and its limits',
    attributeCeiling('3d6') === 30 && attributeCeiling('2d6') === 24
    && attributeCeiling('4d6') === 24 && attributeCeiling('3d6+6') === 36
    && attributeCeiling('not dice') === null);

  // ── a FIXED attribute value (BOOK-INGEST-AUDIT.md F8) ────────────────────
  // The Naruni Repo-Bot's chassis has "a P.S. of 50, P.P. 26". Before this, a
  // bare integer matched no grammar, so rollAttribute discarded it, rolled 3d6,
  // AND rewrote the notation to match — a class that says the attribute is 50
  // and is not heard.
  {
    const r = rollAttribute('50');
    check('a fixed attribute value is returned unchanged, not rolled',
      r.total === 50 && r.base === 50 && r.modifier === 0);
    check('and it reports its OWN notation rather than 3d6',
      r.notation === '50', `notation was ${r.notation}`);
    check('a fixed value earns no exceptional die - it is not a roll',
      r.exceptional.length === 0);
    check('and it is its own ceiling, so the server-side gate finally covers it',
      attributeCeiling('50') === 50);
    check('a fixed value reads the same through evalDice and diceBounds',
      evalDice('50') === 50 && JSON.stringify(diceBounds('50')) === '{"min":50,"max":50}');
  }

  // The grammar must stay NARROW, or this trades a silent substitution for a
  // silent acceptance. Only a bare integer counts; anything else still falls
  // through to 3d6, and is now an ERROR at import time rather than a surprise.
  check('dice still parse as dice, and the fallback still fires for real junk',
    rollAttribute('3d6+2').notation === '3d6+2'
    && rollAttribute('garbage').notation === '3d6'
    && rollAttribute('50 lbs').notation === '3d6');
  check('isAttributeExpr admits all three grammars and nothing else',
    isAttributeExpr('50') && isAttributeExpr('3d6') && isAttributeExpr('2d4x10+6')
    && isAttributeExpr('N/A')
    && !isAttributeExpr('50 lbs') && !isAttributeExpr('none') && !isAttributeExpr(''));

  // ── an ABSENT attribute (BOOK-INGEST-AUDIT.md F5) ────────────────────────
  // The Machine People have no constitution and the Pleasurer no fixed beauty,
  // and their books say so with "N/A". Omitting the key and writing a number
  // produced the SAME character, because app.js resolved a missing entry as
  // 3d6 — so both sheets showed a score the book denies.
  check('an absent attribute is null, not a roll and not a zero',
    rollAttribute('N/A') === null && rollAttribute('n/a') === null);
  check('and it has no ceiling to exceed',
    attributeCeiling('N/A') === null);
  check('isAbsentAttribute is narrow — only the literal the books print',
    isAbsentAttribute('N/A') && isAbsentAttribute(' n/a ')
    && !isAbsentAttribute('NA') && !isAbsentAttribute('none')
    && !isAbsentAttribute('0') && !isAbsentAttribute('3d6'));
  // null is the ONE thing that must not be confused with a rolled value, so
  // pin the difference from the two neighbours it sits between.
  check('absent, fixed and rolled are three different answers',
    rollAttribute('N/A') === null
    && rollAttribute('0').total === 0
    && rollAttribute('3d6').total >= 3);
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

// Three targets, not two, and both books agree: 15 / 12 / 10. This check used
// to assert `major and master at 12, everyone else at 15`, which pinned two
// wrong answers - a minor psychic at the non-psychic 15, and a master at the
// major's 12. See the table in derive.js.
check('a master psionic saves vs psionics at 10, minor and major at 12, everyone else at 15', (() => {
  const t = (tier) => D.saves({ ME: 10 }, null, tier).psionics_target;
  return t('master') === 10
      && t('major') === 12 && t('minor') === 12
      && t(null) === 15 && t(undefined) === 15;
})());
check('the tier is matched case-insensitively, as meetsTier already was', (() => {
  const t = (tier) => D.saves({ ME: 10 }, null, tier).psionics_target;
  return t('Master') === 10 && t('MINOR') === 12;
})());
check('an unrecognised tier still falls to the non-psychic target',
  D.saves({ ME: 10 }, null, 'grandmaster').psionics_target === 15);
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

// ── the inventory join survives a gear RENAME — RETRO-AUDIT R21 ──
//
// Keying inventory on the slug bought portability and cost something the id
// gave for free: a gear row's slug can be RENAMED by an admin
// (`catalogs/rows.js`, which files a 'rename' redirect), and twenty renames
// have already happened on skills. Held by id, a rename could not reach the
// inventory. Held by slug it would orphan every row - the LEFT JOIN yields
// NULL and the sheet renders a bare custom line - unless the read falls
// through `catalog_redirects`.
//
// Proved on an in-memory database rather than against the real one, so it
// can assert the FAILING direction too: the plain join really does lose the
// row, which is the only reason to believe the redirect arm is doing work.
{
  const mem = new DatabaseSync(':memory:');
  mem.exec(`CREATE TABLE gear (id INTEGER PRIMARY KEY, slug TEXT UNIQUE, name TEXT);
    CREATE TABLE character_items (id INTEGER PRIMARY KEY, item_id INTEGER, gear_slug TEXT);
    CREATE TABLE catalog_redirects (catalog TEXT, from_key TEXT, to_id INTEGER, reason TEXT);
    INSERT INTO gear VALUES (7, 'long-sword', 'Long Sword');
    INSERT INTO character_items VALUES (1, 7, 'long-sword');`);

  const resolved = () => mem.prepare(
    `SELECT g.name AS item_name FROM character_items ci
     LEFT JOIN catalog_redirects cr ON cr.catalog = 'gear' AND cr.from_key = ci.gear_slug
     LEFT JOIN gear g ON g.slug = ci.gear_slug OR g.id = cr.to_id
                      OR (ci.gear_slug IS NULL AND g.id = ci.item_id)
     WHERE ci.id = 1`).get()?.item_name ?? null;
  const plain = () => mem.prepare(
    `SELECT g.name AS item_name FROM character_items ci
     LEFT JOIN gear g ON g.slug = ci.gear_slug WHERE ci.id = 1`).get()?.item_name ?? null;

  check('the inventory join resolves an unrenamed slug', resolved() === 'Long Sword');

  mem.exec(`UPDATE gear SET slug = 'sword-long' WHERE id = 7;
    INSERT INTO catalog_redirects VALUES ('gear', 'long-sword', 7, 'rename');`);
  check('a plain slug join LOSES the row after a rename', plain() === null);
  check('and the redirect arm still resolves it', resolved() === 'Long Sword');

  // The legacy arm: a row written before migration 044 has an id and no
  // slug, and must still resolve.
  mem.exec(`INSERT INTO character_items VALUES (2, 7, NULL);`);
  const legacy = mem.prepare(
    `SELECT g.name AS item_name FROM character_items ci
     LEFT JOIN catalog_redirects cr ON cr.catalog = 'gear' AND cr.from_key = ci.gear_slug
     LEFT JOIN gear g ON g.slug = ci.gear_slug OR g.id = cr.to_id
                      OR (ci.gear_slug IS NULL AND g.id = ci.item_id)
     WHERE ci.id = 2`).get()?.item_name ?? null;
  check('and a pre-044 row with only an id still resolves', legacy === 'Long Sword');
  mem.close();
}


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

// ---------- What an empty STARTING pick means ----------
// The same distinction one level down, and it was missing. `startingGroups`
// returns [] for four different answers, so the Powers step rendered one thing
// for all four: the heading "Spells - 0/0", a filter box, and 543 checkbox rows,
// every one disabled because the allowance was zero. A picker that cannot be
// used says only that something went wrong.
section('Starting picks');
{
  const start = (magic) => startingPicksFor({ magic }, 'spell');

  check('a class with no magic is not applicable', startingPicksFor({}, 'spell').applicable === false);
  // `type: "none"` is not silence - it is a block saying the class is NOT a
  // caster. The Godling's, whose magic comes from the O.C.C. picked beside it.
  check('and neither is a block that says type none', start({ type: 'none' }).applicable === false);

  const silent = start({ type: 'druid' });
  check('a caster stating no starting count is UNKNOWN, not empty',
    silent.applicable === true && silent.unknown === true);
  check('and offers nothing rather than guessing', silent.groups.length === 0 && silent.total === 0);

  // A STATED ZERO IS AN ANSWER, not a gap: five dragon hatchlings carry
  // `spells_starting: 0` because their books say a hatchling "knows NO spells at
  // first level" and learns them by the usual means from second.
  const zero = start({ type: 'spell', spells_starting: 0 });
  check('a stated zero is known, not unknown', zero.applicable === true && zero.unknown === false);
  check('and still offers nothing', zero.total === 0 && zero.groups.length === 0);

  // Nor is a class whose spells are all GRANTED missing a count. The Shifter's
  // twenty and the Techno-Wizard's twenty-five are the whole answer.
  const granted = start({ type: 'spell', spells: ['Zap', '  ', ' Big Zap'] });
  check('an outright list answers the question too', granted.unknown === false);
  check('and is carried, trimmed, blanks dropped',
    JSON.stringify(granted.granted) === '["Zap","Big Zap"]');

  const real = start({ type: 'spell', spells_starting: 12, spell_levels_allowed: [1, 2] });
  check('a real pick comes through as groups', real.groups.length === 1 && real.total === 12);
  check('and is neither unknown nor granted', real.unknown === false && real.granted.length === 0);
  check('a split pick totals across its groups',
    start({ type: 'spell', spells_starting: 3,
            spells_starting_groups: [{ count: 1 }, { count: 2 }] }).total === 3);

  // PICKS STATED WHERE NOTHING READS THEM. Creation asks perLevelGrants from
  // level 1 and it skips every entry at or below fromLevel by design, and this
  // is creation's own reader - so a level-1 schedule entry fires nowhere at all.
  // The Wizard states six spells that way. Counted and reported rather than
  // honoured: honouring them would make a schedule a second way to say a
  // starting pick, and one way is why the *_starting keys exist.
  const misfiledMagic = { type: 'spell', spells: ['Zap'], spells_schedule: [
    { level: 1, count: 2, spell_levels: [1] }, { level: 1, count: 1, spell_levels: [3] },
    { level: 2, count: 1 }] };
  const misfiled = start(misfiledMagic);
  check('level-1 schedule entries are counted as misfiled', misfiled.misfiled === 3);
  check('and are NOT honoured as a starting pick', misfiled.total === 0);
  check('while the per-level side still reads the later ones',
    spellGrantsFor({ magic: misfiledMagic }, 1, 2).total === 1);
  check('a schedule starting at level 2 misfiles nothing',
    start({ type: 'spell', spells_starting: 1,
            spells_schedule: [{ level: 2, count: 2 }] }).misfiled === 0);

  // Psionics reads the same shape from its own keys, as it does one level up.
  check('psionics answers from powers_starting',
    startingPicksFor({ psionics: { type: 'major', powers_starting: 2 } }, 'psionic').total === 2);
  check('and from its own outright list',
    startingPicksFor({ psionics: { type: 'master', powers: ['Mend'] } }, 'psionic')
      .granted.length === 1);
}

// ---------- The Attribute Bonus Chart ----------
// Palladium Fantasy printed 16, transcribed column by column. Nothing else in
// the app checks derive.js against the book, and the last time this file was
// wrong it was wrong EVERYWHERE: it applied `v - 15` to every row and called
// that "the standard Palladium tables", which left every parry, dodge, strike
// and save at roughly double the printed value and let M.A. and P.B. climb past
// 100%. A table that is wrong is not a bug anybody reports; it is a character
// sheet that is quietly generous.
//
// The chart runs 16 to 30. Below 16 the book gives nothing, and above 30 the
// app extends each row by its own step, which is a house rule and is checked
// separately below.
section('Attribute Bonus Chart');
{
  //                        16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
  const PRINTED = {
    iq_skills:   [ 2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16],
    me_psionic:  [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    me_insanity: [ 1,  1,  2,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13],
    ma_trust:    [40, 45, 50, 55, 60, 65, 70, 75, 80, 84, 88, 92, 94, 96, 97],
    ps_damage:   [ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15],
    pp_combat:   [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    pe_coma_pct: [ 4,  5,  6,  8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
    pe_magic:    [ 1,  1,  2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  7,  7,  8],
    pb_charm:    [30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 83, 86, 90, 92],
  };

  // Read off the source rather than through a public helper: `chart()` is
  // internal, and what needs pinning is the DATA, one column at a time, so a
  // failure names the attribute value that moved.
  const src = readFileSync(join(appDir, 'js', 'derive.js'), 'utf8');
  for (const [name, want] of Object.entries(PRINTED)) {
    const m = new RegExp(`${name}:\\s*row\\(\\[([^\\]]*)\\]`).exec(src);
    const got = m ? m[1].split(',').map((n) => Number(n.trim())) : null;
    check(`${name} has all fifteen columns`, got && got.length === 15,
      got ? `${got.length}` : 'row not found in derive.js');
    if (!got || got.length !== 15) continue;
    const bad = want.map((v, i) => (got[i] === v ? null : `${16 + i}: ${got[i]} not ${v}`))
      .filter(Boolean);
    check(`and every one matches printed 16`, bad.length === 0, `${name} - ${bad.join(', ')}`);
  }

  // The P.P. row drives strike as well as parry and dodge, which the book gives
  // as two rows of identical numbers. One row in the app, and it must stay
  // equal to the printed pair rather than drifting into a second copy.
  check('strike shares the parry and dodge row, as the book prints it',
    JSON.stringify(PRINTED.pp_combat) === JSON.stringify(PRINTED.pe_magic));

  // Below the chart the book gives nothing, and the app must not invent it.
  check('an attribute of 15 earns nothing', D.bio({ IQ: 15 }).iq_skill_bonus_pct === 0);
  check('and 16 earns the first step', D.bio({ IQ: 16 }).iq_skill_bonus_pct === 2);

  // A column read end to end through the real function, not just off the source.
  check('M.A. 24 invokes trust at the printed 80%', D.bio({ MA: 24 }).invoke_trust_pct === 80);
  check('and P.B. 24 charms at 70%', D.bio({ PB: 24 }).charm_impress_pct === 70);

  // Above 30 is a HOUSE RULE and is labelled as one - the book stops, dragons
  // do not. Each row continues by the step it ends on.
  check('above 30 the row continues by its own step',
    D.bio({ IQ: 32 }).iq_skill_bonus_pct === 18, `${D.bio({ IQ: 32 }).iq_skill_bonus_pct}`);

  // The two percentile rows are capped at the same 98% the skills use, or a
  // high-M.A. dragon would talk its way past certainty.
  const big = D.bio({ MA: 60, PB: 60 });
  check('and the percentile rows stop at 98%',
    big.invoke_trust_pct <= 98 && big.charm_impress_pct <= 98, JSON.stringify(big));
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
    /character: \{ level[,\s]/.test(src));
  check('unspent picks are banked on create', /insertGrantStatements\(env, row\.id, remaining\)/.test(src));
  check('and the allowance is recomputed server-side rather than trusted',
    /skillGrantsFor\(cls, 1, level\)/.test(src));

  // A warning nothing hands the number to is a warning that never fires. The
  // audit is the one caller positioned to notice, so it has to SELECT xp and
  // pass it - which is the shape of failure this repo has been bitten by
  // before, under 'a field the prompt does not mention'.
  const auditSrc = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
    'admin', 'audit.js'), 'utf8');
  check('the audit selects xp', /characters\.xp/.test(auditSrc));
  check('and passes it to the validator', /level: row\.level, xp: row\.xp/.test(auditSrc));

  // -- an occupation's ATTRIBUTE MINIMUMS have to survive it too -------------
  //
  // Same shape as the xp_table bug and found the same way: `sumBonusGroups`
  // merged attributes, combat, saves, pools and at_level, and dropped
  // attribute_minimums on the floor. An occupation's requirement vanished the
  // moment a race was composed with it, and the Attributes step stopped saying
  // a character did not qualify. Only two classes state any - the Juicer's
  // P.S. 22 and the Crazy's P.S. 19 / P.P. 17 - and both lost them.
  {
    const race = { id: 'r', name: 'R', category: 'rcc', system: 'rifts' };
    const occ = { id: 'o', name: 'O', category: 'occ', system: 'rifts',
      bonuses: { attribute_minimums: { PS: 22 } } };
    const composed = composeClass({ rcc: race, occ, character: {} });
    check('an occupation\u2019s attribute minimums survive composition',
      composed?.bonuses?.attribute_minimums?.PS === 22,
      JSON.stringify(composed?.bonuses?.attribute_minimums));

    // A minimum is not a bonus: two of them do not add up. A class wanting
    // P.S. 22 beside one wanting P.S. 19 wants a character with P.S. 22.
    const strictRace = { ...race, bonuses: { attribute_minimums: { PS: 19, PP: 17 } } };
    const both = composeClass({ rcc: strictRace, occ, character: {} });
    check('and the stricter of two wins rather than the sum',
      both?.bonuses?.attribute_minimums?.PS === 22,
      JSON.stringify(both?.bonuses?.attribute_minimums));
    check('while an attribute only one of them names is kept',
      both?.bonuses?.attribute_minimums?.PP === 17,
      JSON.stringify(both?.bonuses?.attribute_minimums));

    // And a pairing that states none must not invent an empty block.
    const none = composeClass({ rcc: race, occ: { ...occ, bonuses: undefined }, character: {} });
    check('and neither stating one leaves nothing behind',
      none?.bonuses?.attribute_minimums === undefined,
      JSON.stringify(none?.bonuses));
  }

  // -- an OCCUPATION's curve has to survive composition ----------------------
  //
  // Palladium names its experience charts by O.C.C. - "Knight & Noble", "Thief
  // & Merchant" - and a RACE has none, because experience comes from what you
  // do. `combineClasses` carries a named list of keys forward from the
  // occupation, and `xp_table` was not on it, so since #210 (race primary,
  // occupation second) a Knight's curve was dropped on EVERY Palladium
  // character and the race's absent table won. Measured here rather than read
  // off the source, because the failure was silent: no error, no warning, just
  // the house-rule default quietly standing in.
  const race = { id: 'r', name: 'R', category: 'rcc', system: 'palladium-fantasy' };
  const occ = { id: 'o', name: 'O', category: 'occ', system: 'palladium-fantasy',
    xp_table: [0, 2100, 4200, 8400] };
  const composed = composeClass({ rcc: race, occ, character: {} });
  check('an occupation’s xp_table survives composition',
    JSON.stringify(composed.xp_table) === JSON.stringify(occ.xp_table),
    JSON.stringify(composed.xp_table));
  check('and it is the table the level thresholds come from',
    thresholdFor(xpTableFor(composed), 2) === 2100);

  // The race still wins where it HAS an opinion - a dragon's curve is the
  // dragon's - and silence on both sides still falls back to the house rule.
  const dragon = composeClass({ rcc: { ...race, xp_table: [0, 1, 2] }, occ, character: {} });
  check('a race that states its own curve still wins',
    JSON.stringify(dragon.xp_table) === '[0,1,2]');
  const neither = composeClass({ rcc: race, occ: { ...occ, xp_table: undefined }, character: {} });
  check('and neither stating one falls back to the default',
    thresholdFor(xpTableFor(neither), 2) === thresholdFor(xpTableFor({}), 2));

  // The wizard's starting-level picker read the RACE, so it sized itself and
  // priced the level off a table Palladium characters never have.
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  const picker = appSrc.slice(appSrc.indexOf('function startingLevelPicker()'),
    appSrc.indexOf('function setStartingLevel'));
  check('the starting-level picker prefers the composed class',
    /S\.cls \|\| applyVariant\(S\.rcc/.test(picker));
  check('and no longer reads the race directly for a threshold',
    !/xpTableFor\(applyVariant\(S\.rcc/.test(picker), 'still calls xpTableFor on the race');

  // `xp_table` is a modelled key. Reported UNMODELLED, the instruction attached
  // is to delete it or change the app, and both would break a working field.
  check('xp_table is a known class key',
    !unmodelledKeys({ id: 'x', name: 'X', xp_table: [0, 1] }).includes('xp_table'));
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

// ---------- 1c11b. The class prompt covers the schema ----------
// A field the schema supports and the prompt never mentions is a field that
// never gets extracted. `variants` shipped without being added here, so the
// first real two-stage class came back with BOTH stat blocks dropped — the
// numbers the entry exists for.
section('Class prompt covers the schema');
{
  const prompt = readFileSync(
    join(repoRoot, 'scripts', 'extraction-prompt.mjs'), 'utf8');
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
    const src = readFileSync(join(appDir, '..', '..', 'scripts', 'extraction-prompt.mjs'), 'utf8');
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

// ---------- 1c25a1. An attribute-derived skill base ----------
// BOOK-INGEST-AUDIT.md F2. Phase World states Zero Gravity Movement & Combat as
// "the P.P. attribute number x5%, plus 4% per level". `per_level` held the 4;
// `base` is an INTEGER and held 0 — which the schema defines as NON-PERCENTILE,
// so a skill starting near 50% read as a weapon proficiency.
section('Attribute-derived skill base');
{
  check('a formula yields the attribute times its multiplier',
    skillBase({ base: 0, base_formula: 'PP*5' }, { PP: 12 }) === 60);
  check('and it is space- and case-tolerant, because a data script is hand-written',
    skillBase({ base_formula: ' pp * 5 ' }, { PP: 10 }) === 50);

  // THE FALLBACK IS THE WHOLE COMPATIBILITY STORY. Every row without a formula
  // must read exactly as it did before the column existed.
  check('no formula means the stored base, untouched',
    skillBase({ base: 40, per_level: 5 }, { PP: 12 }) === 40
    && skillBase({ base: 0 }, { PP: 12 }) === 0
    && skillBase({}, {}) === 0);

  // Null means "no opinion", and the caller falls back — which matters since
  // F5, where a creature can legitimately have no such attribute at all.
  check('an attribute the character does not have falls back to base',
    skillBase({ base: 7, base_formula: 'PE*5' }, { PP: 12 }) === 7);
  check('and so does a formula that does not parse',
    skillBase({ base: 7, base_formula: 'PP times five' }, { PP: 12 }) === 7
    && skillBase({ base: 7, base_formula: 'PP*' }, { PP: 12 }) === 7);

  check('isBaseFormula admits the one shape and nothing else',
    isBaseFormula('PP*5') && isBaseFormula('Spd*2')
    && !isBaseFormula('PP*5+10') && !isBaseFormula('XX*5')
    && !isBaseFormula('5') && !isBaseFormula(''));

  // A formula that does not parse falls back SILENTLY, which is F8's shape: a
  // value stored and never heard. Nothing validates a skills row on the way in,
  // so this is the guard — every formula any data script writes must parse.
  // Read off the SCRIPTS rather than a database: the scripts are what ships,
  // and a local database is whatever the last session left in it.
  {
    const sdir = join(appDir, 'db');
    const written = [];
    for (const f of readdirSync(sdir).filter((n) => n.endsWith('.sql'))) {
      const sql = readFileSync(join(sdir, f), 'utf8');
      for (const m of sql.matchAll(/base_formula\s*=\s*'([^']*)'/g)) written.push({ f, v: m[1] });
    }
    const bad = written.filter((w) => !isBaseFormula(w.v));
    check('every base_formula a data script writes actually parses',
      bad.length === 0, bad.map((w) => `${w.f}: ${w.v}`).join(', '));
    check('and the sweep found the one row this finding exists for',
      written.some((w) => w.v.toUpperCase() === 'PP*5'), `found ${written.length}`);
  }
}

// ---------- 1c25a1b. Spending a PICK on an attribute-derived skill ----------
// BOOK-INGEST-AUDIT F18. skillBase() is documented as the ONLY place `base` and
// `base_formula` are chosen between — and `resolvePicks`, a WRITE path, did not
// call it. A pick spent on Zero Gravity Movement & Combat stored 0, and
// js/leveling.js advances from the STORED pct, so it climbed from 0 forever.
// Creation was right and every level-up after it was wrong.
//
// F2 asked where the evaluation belongs and answered "the wizard" — correct for
// both sites it looked at, and both were DISPLAY. This is the WRITE site. No
// fixture had ever spent a pick on a formula-carrying row, which is exactly why
// the suite could not see it.
section('A pick spent on an attribute-derived skill');
{
  const ZERO_G = {
    name: 'Space: Zero Gravity Movement & Combat', category: 'Physical',
    base: 0, base_formula: 'PP*5', per_level: 4,
  };
  const picksDb = (rows) => ({
    DB: { prepare: () => ({ bind: () => ({ all: async () => ({ results: rows }) }) }) },
  });
  const spend = (row, opts) => resolvePicks(picksDb([row]), {
    picks: [{ name: row.name }], existingSkills: [], allowance: 1,
    categories: null, level: 4, ...opts,
  });

  const derived = await spend(ZERO_G, { attributes: { PP: 12 } });
  check('the formula resolves on the server write path, not only at creation',
    derived.skills[0]?.pct === 60, `got ${derived.skills[0]?.pct}`);

  // The fallback still holds: a caller with no attributes gets the stored base
  // rather than an invented number.
  const noAttrs = await spend(ZERO_G, {});
  check('and with no attributes it falls back rather than inventing a number',
    noAttrs.skills[0]?.pct === 0);

  // THE JUDGEMENT F18 NAMES. The guard exists so a W.P. has no percentage for a
  // percentage bonus to modify. A formula-derived base IS a real percentage and
  // must take the class bonus — guarding on `row.base`, which is 0 here, would
  // have traded a visible 0% for a percentage quietly missing its bonus.
  const withBonus = await spend(ZERO_G, {
    attributes: { PP: 12 }, categories: [{ name: 'Physical', bonus: 5 }],
  });
  check('a formula-derived base takes the class category bonus',
    withBonus.skills[0]?.pct === 65, `got ${withBonus.skills[0]?.pct}`);

  // And the case the guard was written for is untouched.
  const wp = await spend(
    { name: 'W.P. Sword', category: 'Weapon Proficiencies', base: 0, per_level: 0 },
    { attributes: { PP: 12 }, categories: [{ name: 'Weapon Proficiencies', bonus: 5 }] });
  check('while a non-percentile skill still takes no bonus at all',
    wp.skills[0]?.pct === 0, `got ${wp.skills[0]?.pct}`);
}

// ---------- 1c25a2. The percentage printed beside a category ----------
// "Technical: Any (+10%)". Before `bonus` existed those numbers had nowhere to
// go, so an import either dropped them silently or wrote a key that parsed and
// then did nothing. The Godling shipped missing all five of its own, and
// Pantheons of the Megaverse prints twenty-one across four classes.
section('Category skill bonuses');
{
  const cats = ['Domestic',
    { name: 'Technical', bonus: 10 },
    { name: 'Medical', except: ['M.D. in Cybernetics'], bonus: 10 },
    { name: 'Wilderness', bonus: 5 }];

  check('a category with no bonus adds nothing',
    categoryBonus(cats, { name: 'Cook', category: 'Domestic' }) === 0);
  check('a bonus is found by the skill\'s real category',
    categoryBonus(cats, { name: 'Computer Operation', category: 'Technical' }) === 10);
  check('a bonus rides alongside an except-list',
    categoryBonus(cats, { name: 'Paramedic', category: 'Medical' }) === 10);
  check('a category the class never granted adds nothing',
    categoryBonus(cats, { name: 'Basic Math', category: 'Science' }) === 0);
  check('no list adds nothing',
    categoryBonus([], { name: 'X', category: 'Technical' }) === 0
    && categoryBonus(null, { name: 'X', category: 'Technical' }) === 0);

  // ── a cross-category `only` that carries a percentage (F9) ───────────────
  // "Rogue: Prowl only (+5%)" - the catalog files Prowl under Physical, so the
  // +5% used to land nowhere while the picker still showed it to the player.
  {
    const wasp = [{ name: 'Rogue', only: ['Prowl'], bonus: 5 }, 'Physical'];
    check('a cross-category only pick is scored by the entry that admitted it',
      categoryBonus(wasp, { name: 'Prowl', category: 'Physical' }) === 5);
    check('and it is still admitted, which was never the broken half',
      categoryAllows(wasp, { name: 'Prowl', category: 'Physical' }) === true);

    // THE GUARD THAT MAKES THIS SAFE. An admitting entry with NO percentage
    // must not zero out a real-category bonus that does exist: the Glitter Boy
    // names Wilderness Survival under Espionage with no figure, and its
    // Wilderness entry pays +2%. Swept across every published class, 18 picks
    // are admitted this way and only 3 name a percentage - so an unconditional
    // swap would have taken three classes to zero.
    const gb = [{ name: 'Espionage', only: ['Wilderness Survival'] }, { name: 'Wilderness', bonus: 2 }];
    check('an admitting entry with no percentage leaves the real category alone',
      categoryBonus(gb, { name: 'Wilderness Survival', category: 'Wilderness' }) === 2);

    // Bounded exactly as categoryAllows bounds it: without the real category
    // listed the pick was never admitted, so there is no bonus to award.
    const unbounded = [{ name: 'Rogue', only: ['Prowl'], bonus: 5 }];
    check('an unadmitted cross-category pick scores nothing',
      categoryBonus(unbounded, { name: 'Prowl', category: 'Physical' }) === 0
      && categoryAllows(unbounded, { name: 'Prowl', category: 'Physical' }) === false);
  }

  // ── a save the sixteen fields do not name (F7) ────────────────────────────
  // The Spacer's whole mechanical grant is "+2 to any saves against explosive
  // decompression or other space dangers". Writing it as an invented key
  // (`space_hazards: 2`) parsed and rendered nowhere; writing it as the nearest
  // real one (`toxins_poisons: 2`) granted a resistance to venom the book never
  // gave. `saves.other` is the third answer: labelled in the book's own words.
  {
    const ok1 = { saves: { horror_factor: 2, other: [{ label: 'vs vacuum', bonus: 2 }] } };
    const e1 = [], w1 = [];
    validateBonuses(ok1, e1, w1);
    check('a labelled save validates alongside the keyed ones',
      e1.length === 0 && w1.length === 0, [...e1, ...w1].join('; '));

    // A LABEL IS THE WHOLE DESIGN. Without one this is the unrendered key it
    // replaces, so an entry missing it is an error rather than a warning.
    for (const [why, block] of [
      ['a map instead of a list', { saves: { other: { label: 'x', bonus: 1 } } }],
      ['an entry with no label', { saves: { other: [{ bonus: 2 }] } }],
      ['an entry with a blank label', { saves: { other: [{ label: '  ', bonus: 2 }] } }],
      ['an entry with no bonus', { saves: { other: [{ label: 'vs vacuum' }] } }],
    ]) {
      const e = [];
      validateBonuses(block, e, []);
      check(`saves.other rejects ${why}`, e.length > 0);
    }

    // Composed side by side, not summed: a race granting +3 vs radiation and an
    // occupation granting +2 vs vacuum grant BOTH. The keyed saves still sum.
    const merged = sumBonusGroups(
      { saves: { horror_factor: 1, other: [{ label: 'vs radiation', bonus: 3 }] } },
      { saves: { horror_factor: 2, other: [{ label: 'vs vacuum', bonus: 2 }] } });
    check('two classes keep both labelled saves and still sum the keyed one',
      merged.saves.horror_factor === 3 && merged.saves.other.length === 2
      && merged.saves.other.map((e) => e.label).join('|') === 'vs radiation|vs vacuum');

    // It must not leak into the derived save numbers - `other` is a list, and a
    // list added to a chart value is how this would go wrong quietly.
    const d = derive.classBonuses({ bonuses: ok1 }, 1, null);
    check('a labelled save contributes nothing to the numeric save map',
      d.saves.other === undefined && d.saves.horror_factor === 2);
  }

  // The restriction and the percentage arrive in one parenthetical on the page,
  // so a picker showing half of it would be lying about the other half.
  check('the label shows the bonus, with or without a restriction', (() => {
    const l = cats.map(categoryLabel);
    return l[0] === 'Domestic' && l[1] === 'Technical (+10%)'
      && l[2] === 'Medical (except M.D. in Cybernetics; +10%)' && l[3] === 'Wilderness (+5%)';
  })());

  const mk = (catsYaml, key = 'occ_related_skills') => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  ${key}:\n    count: 2\n    categories:\n${catsYaml}\n---\n\n## Lore\n\nx\n`);

  check('a numeric bonus parses', mk('      - { name: "Technical", bonus: 10 }').ok);
  // The exact silent no-op this key exists to stop, reintroduced one layer
  // down: "10%" passes `!== undefined`, fails Number.isFinite and adds nothing.
  check('a non-numeric bonus is rejected', (() => {
    const r = mk('      - { name: "Technical", bonus: "10%" }');
    return !r.ok && r.errors.some((e) => /bonus must be a number/.test(e));
  })());
  // The books give the parenthetical percentage to related picks only, and say
  // so in the same breath. A bonus filed under secondary would never be read.
  check('a bonus on the secondary list is rejected', (() => {
    const r = mk('      - { name: "Technical", bonus: 10 }', 'secondary_skills');
    return !r.ok && r.errors.some((e) => /applies to related selections only/.test(e));
  })());

  // Both places a related pick gets a percentage — at creation in the wizard,
  // and at level-up through the server. Two copies of one rule is the pair that
  // drifts, so each is pinned to the call rather than to the arithmetic.
  check('the wizard applies it at creation', (() => {
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return src.includes('categoryBonus(relatedCats(), row)');
  })());
  check('the server applies it to a level-up pick', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'skill-picks.js'), 'utf8');
    return src.includes('categoryBonus(allowed,') && src.includes('!asSecondary && allowed');
  })());
  // A W.P. and a hand to hand sit at 0 because they are not percentile skills.
  // Adding ten to that would invent a roll that does not exist.
  check('both places guard the bonus on a real base', (() => {
    const wiz = readFileSync(join(appDir, 'app.js'), 'utf8');
    const srv = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'skill-picks.js'), 'utf8');
    return wiz.includes('base ? base + categoryBonus') && srv.includes('base ? base + catBonus : 0');
  })());
}

// ---------- 1c25b. Restrictions that name nothing ----------
// A category restriction names skills by hand, and `categoryAllows` compares
// literal names. So a name no catalog row has does not fail — an `except`
// excludes NOTHING and the class silently offers a skill the book forbids.
// Found importing the Godling R.C.C.: it bars robots, power armor and
// cybernetics, and the catalog spells those "Robots & Power Armor",
// "Robot Combat: Basic" and "M.D. in Cybernetics", so all three did nothing.
// The Godling then outlived the fix. Its import corrected two of the three and
// left "Robots and Power Armor"; the catalog LATER renamed that row to the
// ampersand spelling and kept the old one as a redirect, which restrictions do
// not consult, so the exclusion went on doing nothing for months while every
// catalog check passed. A rename can break a restriction that was right when it
// was written, and only this cross-reference will say so.
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
    '_lib/power-picks.js', '_lib/skill-picks.js',
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

renderedUiChecks();

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

  // Which classes have one, and how many packages each offers. Pinned because
  // BOTH written records of it were wrong at once: parser.js said the Technical
  // Officer offered five where it offers seven, and the README said the Robot
  // Pilot offered two where it had none at all - it carried its packages as GM
  // prose and a note claiming the schema could not hold them, which it could.
  // A count in a comment is exactly the kind of claim that goes stale silently.
  {
    const dbDir = join(appDir, 'db');
    const files = readdirSync(dbDir).filter((f) => f.endsWith('.sql')).sort();
    const read = (f) => readFileSync(join(dbDir, f), 'utf8');

    // Three classes have an MOS, and the two newest got theirs by correction
    // rather than at import. That some script gives each one an MOS is all a
    // FILE can honestly answer; how many packages each ends up with is a
    // question about the composed class, and lives in regression.mjs, which
    // has a database to ask.
    for (const id of ['coalition-technical-officer', 'merc-soldier', 'robot-pilot']) {
      const owning = files.filter((f) => read(f).includes(`'${id}'`) && / {2}mos:/.test(read(f)));
      check(`${id} gets its MOS from a data script`, owning.length > 0, id);
    }

    // The stale notes are STILL in add-merc-soldier-class.sql and
    // add-robot-pilot-class.sql, and must be: an applied one-shot script is
    // never edited. What has to be true is that a LATER-sorting script removes
    // them, which is the same shape every other correction here takes.
    for (const stale of ['schema cannot express (see', 'not modeled; add them by hand']) {
      const carriers = files.filter((f) => read(f).includes(stale) && !read(f).includes(`replace(markdown,`));
      const fixers = files.filter((f) => read(f).includes(stale) && read(f).includes('replace(markdown,'));
      check(`the note "${stale.slice(0, 24)}..." is undone by a later script`,
        fixers.length > 0 && carriers.every((c) => fixers.some((f) => f > c)),
        `carried by ${carriers.join(', ')}; fixed by ${fixers.join(', ') || 'NOTHING'}`);
    }

    const srcParser = readFileSync(join(appDir, 'js', 'parser.js'), 'utf8');
    // The MOS chapter moved to docs/race-and-occupation.md with the README split.
    const mosDoc = readFileSync(join(appDir, 'docs', 'race-and-occupation.md'), 'utf8');
    check('docs/race-and-occupation.md states who has an MOS and how many packages',
      /Technical Officer\s+offers seven, the Merc Soldier seven and the\s+Robot Pilot two/
        .test(mosDoc.replace(/\r/g, '')));
    check('and parser.js agrees with it',
      /Technical Officer offers seven, the Merc Soldier seven and the/.test(srcParser.replace(/\r/g, '')));

    // ── NO DATA SCRIPT MAY KEY ON A LITERAL CATALOG id ──
    //
    // Catalog ids are `INTEGER PRIMARY KEY AUTOINCREMENT`, so they are
    // INSERTION ORDER, and insertion order differs between environments.
    // Measured against a database rebuilt from this repo on 2026-09-05:
    //
    //   gear             0 of 1025 ids matched production
    //   skills           1 of 345
    //   spells          56 of 607
    //   psionic_powers  20 of 116
    //
    // So `WHERE id = 283` picks Fire: Fire Gout in production and Earth: Track
    // in a local or rebuilt database. A script written that way puts the right
    // data on the wrong rows ANYWHERE but the database it was generated
    // against, and it does it silently - there is no error, just wrong rows.
    // That happened here while writing the Book of Magic backfill; the readback
    // caught it only because it counted the whole corpus rather than the rows
    // the script itself had touched.
    //
    // THE NATURAL KEY ALREADY EXISTS AND IS ALREADY UNIQUE - `name` on skills,
    // spells and psionic_powers, `slug` on gear - so keying on it costs
    // nothing.
    //
    // A JOIN ON AN id IS FINE and must stay fine: `gear.id =
    // character_items.item_id` is a relation inside one database and says
    // nothing about which database. Eight scripts do that and all eight are
    // correct. Only a literal NUMBER is refused.
    //
    // Asserted over the WHOLE corpus rather than over the lines a branch adds,
    // because the corpus is at zero and an invariant that is already true is
    // the cheap kind to keep.
    const CATALOG = 'spells|skills|psionic_powers|gear|enchantments';
    const LITERAL_ID = new RegExp(
      `(?:UPDATE|DELETE\\s+FROM)\\s+(?:${CATALOG})\\b[\\s\\S]{0,400}?`
      + `WHERE[\\s\\S]{0,120}?\\bid\\s*(?:=|IN\\s*\\()\\s*\\d`, 'i');
    const idKeyed = files.filter((f) => LITERAL_ID.test(read(f)));
    check('no data script keys a catalog write on a literal id',
      idKeyed.length === 0,
      `${idKeyed.join(', ')} - ids are insertion order and differ per environment; `
      + 'key on name (or slug, for gear)');

    // And the check is not vacuous: the pattern it looks for really does match
    // the shape it forbids. Without this, a regex that never matched anything
    // would pass forever and prove nothing - the failure R16 was filed for.
    check('and the guard matches the shape it forbids',
      LITERAL_ID.test("UPDATE spells SET description = 'x' WHERE id = 283;")
      && LITERAL_ID.test('DELETE FROM gear WHERE id IN (1, 2);'));
    check('while leaving an id JOIN alone',
      !LITERAL_ID.test('UPDATE character_items SET custom_name = '
        + '(SELECT name FROM gear WHERE gear.id = character_items.item_id);'));
  }

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

// ---------- 1c25j2. One list of saves, and the two the races needed ----------
// The sheet and play mode each held their own copy of the save label list, and
// they had drifted: the sheet printed thirteen rows and play mode offered eight
// buttons, so the Juicer's +6 vs mind control and the Ley Line Walker's +3 vs
// curses were visible on the sheet and unrollable at the table. There is now one
// list and play mode filters the percentile row out of it.
//
// Faerie magic and disease were added because four Palladium Fantasy player
// races grant bonuses to them; fatigue is the newest, for the Operator's
// "+2 to save vs fatigue and disease" (RUE printed 92).
console.log(String.fromCharCode(10) + '[1c25j2] the save list');
{
  const src = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  const saves = D.saves({ PE: 10, ME: 10 }, null);

  // Every save derive produces has a label, or it is computed and never shown.
  const listed = [...src.matchAll(/\['([a-z_]+)', 'vs [^']+'\]/g)].map((m) => m[1]);
  const missing = Object.keys(saves)
    .filter((k) => k !== 'psionics_target' && !listed.includes(k));
  check('every save derive produces is listed on the sheet', missing.length === 0,
    'not printed anywhere: ' + missing.join(', '));

  // And the reverse: a label for a key derive does not produce prints nothing.
  const dead = listed.filter((k) => !(k in saves));
  check('and every listed save is one derive produces', dead.length === 0,
    dead.join(', '));

  // One declaration. A second array literal of save labels is the drift.
  check('the save labels are declared exactly once',
    (src.match(/'vs Spell Magic'/g) || []).length === 1,
    'sheet.js declares the save list more than once');
  check('play mode rolls the list rather than restating it',
    /SAVE_ROLLS\s*=\s*SAVE_FIELDS\.filter/.test(src));
  check('and drops the percentile row, which is not a d20 save',
    !src.includes("SAVE_ROLLS") || /_pct/.test(src.match(/SAVE_ROLLS[^;]*/)[0]));

  // The two new keys borrow the P.E. rows, like the magic and poison saves.
  check('faerie magic follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).faerie_magic === 0 && s(18).faerie_magic === s(18).spell_magic
      && s(30).faerie_magic === 8;
  })());
  check('disease follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).disease === 0 && s(18).disease === s(18).toxins_poisons
      && s(30).disease === 8;
  })());
  check('fatigue follows the P.E. magic row', (() => {
    const s = (pe) => D.saves({ PE: pe }, null);
    return s(15).fatigue === 0 && s(18).fatigue === s(18).toxins_poisons
      && s(30).fatigue === 8;
  })());
  check('a race can grant both', (() => {
    const b = { attributes: {}, combat: {}, saves: { faerie_magic: 1, disease: 2 } };
    const s = D.saves({ PE: 10, ME: 10 }, null, null, b);
    return s.faerie_magic === 1 && s.disease === 2;
  })());
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

  // The import spec that used to be pinned here went with the in-app
  // importer. The FIELD is what matters to the app and it is still pinned
  // above and rendered below; nothing writes a psionic power through an
  // extraction any more.

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

// ---------- Variable spell costs (ppe_note) ----------
// Migration 021 mirrors 020 for spells: ppe is live (the use button deducts
// it), so Manipulate Objects - priced by a schedule, imported as 0 - could
// only read as free while matching the stub heuristic. Same convention, same
// surfaces: ppe keeps the minimum, ppe_note says the schedule.
//
// This was the last bare hand-numbered console.log — the style the harness
// replaced because the numbers stopped matching execution order. As a bare
// log its checks counted against the PREVIOUS section, and it printed into
// every --section run regardless of the filter.
section('Variable spell costs');
{
  const spFields = CATALOGS.spells.fields.map((f) => f.name);
  check('the catalog editor offers the note field', spFields.includes('ppe_note'));
  check('placed beside the cost it qualifies',
    spFields.indexOf('ppe_note') === spFields.indexOf('ppe') + 1);

  // Same as 1c25k: the import spec pinned here left with the importer, and
  // the field it qualified did not.

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
section('Draft apostrophe escaping');
{
  // BOOK-INGEST-AUDIT.md F13. Ten Phase World classes shipped with doubled
  // apostrophes in their STORED markdown, because the drafts had been escaped
  // for SQL before `--emit-script` escaped them again. It renders to the reader
  // exactly as stored, so a class detail page showed two where one was written.
  //
  // The generator was never the cause, and this pins that: `literal()` doubles
  // each apostrophe exactly ONCE. All 157 add-*-class.sql files went through it
  // and exactly ten came out over-escaped, which is the arithmetic that
  // acquitted it - a broken generator would have done it to all 157.
  const cc = readFileSync(join(repoRoot, 'scripts', 'class-check.mjs'), 'utf8');
  const doublings = [...cc.matchAll(/replace\(\/'\/g, ?"''"\)/g)];
  check('class-check doubles an apostrophe in exactly two places',
    doublings.length === 2,
    `${doublings.length} - one for column values, one for spliced markdown`);

  // The advisory that catches the next pre-escaped draft. A WARNING, because a
  // doubled apostrophe is legal prose if the author meant it, and F13's posture
  // is explicit that a gate on it would be wrong.
  check('and warns when a draft arrives already escaped',
    cc.includes('doubled apostrophe(s) in the draft'));
  check('and that warning moves no exit code', (() => {
    const at = cc.indexOf('doubled apostrophe(s) in the draft');
    const block = cc.slice(cc.lastIndexOf('const doubled', at), at + 200);
    return block.includes('warnings.push') && !block.includes('errors.push');
  })());

  // The sweep is scoped to the ten ids rather than the whole table, so a class
  // that legitimately wants a doubled apostrophe later is untouched.
  const sweep = readFileSync(join(repoRoot, 'apps', 'character-creator', 'db',
    'fix-doubled-apostrophes.sql'), 'utf8');
  check('the sweep is scoped to named classes, not the whole table',
    sweep.includes('WHERE class_id IN ('));
  check('and it names every class it touches in its header',
    (sweep.match(/^--   [a-z-]+ +\d+$/gm) || []).length === 10);
}

section('Audit citation sweep');
{
  // BOOK-INGEST-AUDIT.md F12. A class's extraction note records both what the
  // BOOK prints - permanent - and what the APP could do that day - perishable -
  // in the same paragraph, and nothing swept the citers when a finding was
  // taken. `scripts/audit-citations.mjs` turns "who mentions F8" into a command.
  //
  // WHAT IS PINNED HERE IS ITS POSTURE, not its output: the output depends on a
  // live database and belongs to the person taking a finding.
  const cites = readFileSync(join(repoRoot, 'scripts', 'audit-citations.mjs'), 'utf8');

  // Executable lines only. The file EXPLAINS in prose why it does not read an
  // outcome note, quoting the words those notes use - so a check that scanned
  // the whole file would fail on the comment that exists to prevent the thing
  // it is checking for. That is not hypothetical: INGESTION-AUDIT F14, the
  // finding that DESCRIBES the outcome-note format, carries the note's own
  // shape inside backticks and every grep reports it taken when it is open.
  const code = cites.split('\n')
    .filter((l) => !/^\s*(\/\/|\*|\/\*)/.test(l))
    .join('\n');

  check('the citation sweep reads no outcome note', (() => {
    // The words an outcome note is written in. Any of them in EXECUTABLE code
    // would mean it had started deciding whether a finding was taken.
    return !/\b(Taken|Adjusted|Moot|Closed without)\b/.test(code);
  })(), 'it must answer who cites what, never whether the finding still stands');

  check('and sets no exit code of its own',
    !/process\.exit|process\.exitCode|exitCode\s*=/.test(code),
    'a gate here fires on every class citing a still-open finding');

  // It has to know BOTH shapes the corpus uses. The Galactic Tracer writes
  // "Filed as F6 in the Empire batch" and everything else writes the path;
  // matching only the path missed a real citer.
  check('and knows both citation shapes the corpus uses',
    cites.includes('BOOK-INGEST-AUDIT') && cites.includes('Filed as'));

  // The protocol half. Taking a finding already required an outcome note in the
  // same PR; the step that was skipped is correcting the classes that cite it.
  const menu = readFileSync(join(repoRoot, '.claude', 'skills', 'audit-menu', 'SKILL.md'), 'utf8');
  check('the audit-menu skill requires citing classes to be corrected',
    /Correct every class note that cites the finding/.test(menu));
  check('and points at the command that lists them',
    /audit-citations\.mjs/.test(menu));

  // The convention half - where a note should draw the line in the first place.
  const importSkill = readFileSync(join(repoRoot, '.claude', 'skills', 'class-import', 'SKILL.md'), 'utf8');
  check('the class-import skill separates the permanent half from the perishable',
    /extraction_notes/.test(importSkill) && /perishable/i.test(importSkill));
}

section('A class that supersedes its race');
{
  // BOOK-INGEST-AUDIT.md F11. The Cosmo-Knight is a transformation, not a
  // trade: the Cosmic Forge rebuilds the body, the entry prints its own dice,
  // M.D.C. and P.P.E., and its skills line says the skills of his past life are
  // lost and the character is reborn (Phase World printed 100 and 102).
  //
  // combineClasses was race-primary with no way to say otherwise, so the class
  // arrived wrong in 56 of its 57 possible pairings.
  const mk = (cat, body) => parseClassMarkdown(
    `---\nid: t-${cat}\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\n${body}\n---\n\n## Lore\n\nx\n`).data;

  const race = mk('rcc', `attribute_dice: { IQ: "3d6", ME: "3d6", PS: "3d6+10", PB: "6d6" }
mdc_base: "2d6x10+20"
ppe_base: "3d6+6"
skills:
  occ_skills:
    - { name: "Climbing", base: 50 }
    - { name: "Prowl", base: 40 }`);

  const body = `attribute_dice: { IQ: "3d6+2", ME: "4d6+4", PS: "3d6+32", PB: "3d6" }
mdc_base: "4d6x10+60"
ppe_base: "1d6x100"
skills:
  occ_skills:
    - { name: "Navigation: Space", base: 60 }
  occ_related_skills: { count: 4, categories: ["Physical"] }`;
  const plain = mk('occ', body);
  const reborn = mk('occ', 'supersedes_race: true\n' + body);

  check('supersedes_race parses on an O.C.C.', reborn.supersedes_race === true);
  check('and is rejected unless it is exactly true', (() => {
    const bad = parseClassMarkdown(
      '---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nsupersedes_race: false\n---\n\n## Lore\n\nx\n');
    return !bad.ok;
  })());
  check('and warns on something that is not an O.C.C.', (() => {
    const r = parseClassMarkdown(
      '---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\nsupersedes_race: true\n---\n\n## Lore\n\nx\n');
    return r.ok && r.warnings.some((w) => /supersedes_race/.test(w));
  })());

  // THE POSTURE IS OPT-IN. Every class in the catalog wants the race-primary
  // policy - a dragon that studies an O.C.C. is still a dragon - so an
  // occupation WITHOUT the flag must compose exactly as it always did.
  const before = combineClasses(race, plain);
  check('without the flag the race still wins the pools', before.mdc_base === '2d6x10+20'
    && before.ppe_base === '3d6+6');
  check('and the race still wins the dice', before.attribute_dice.PS === '3d6+10');
  check('and the skills are still unioned', before.skills.occ_skills.length === 3);

  const after = combineClasses(race, reborn);
  check('with the flag the class keeps its own M.D.C. and P.P.E.',
    after.mdc_base === '4d6x10+60' && after.ppe_base === '1d6x100');

  // "the skills of his past life are lost and the character is reborn"
  check('and the past life\'s skills are gone', after.skills.occ_skills.length === 1
    && after.skills.occ_skills[0].name === 'Navigation: Space');
  check('and the occupation still sets the related allowance',
    after.skills.occ_related_skills.count === 4);

  // THE ATTRIBUTES ARE THE ONE CARVE-OUT: "use these die rolls, or the
  // attributes of the character's original race, WHICHEVER ARE HIGHER" - per
  // attribute, so a race with a better P.B. keeps its P.B. and nothing else.
  check('the class wins an attribute it prints higher', after.attribute_dice.PS === '3d6+32');
  check('and the race keeps one IT prints higher', after.attribute_dice.PB === '6d6');
  check('and neither side invents a third expression',
    ['IQ', 'ME', 'PS', 'PB'].every((a) => after.attribute_dice[a] === reborn.attribute_dice[a]
      || after.attribute_dice[a] === race.attribute_dice[a]));

  // The comparison is the MEAN, not the ceiling. attributeCeiling was the
  // obvious reuse and is wrong here: it adds the exceptional-dice chain, which
  // only a plain 2d6 or 3d6 earns, so a bare 3d6 scored 18+12 against 4d6+4's
  // 28 and the WEAKER dice won. 41 of the 57 races beat this class's printed
  // M.E. that way before the comparator was changed.
  check('4d6+4 beats a plain 3d6, which a ceiling comparison got backwards',
    after.attribute_dice.ME === '4d6+4');

  // An absent attribute (F5) has nothing to compare and must not win.
  check('an absent racial attribute never displaces a real one', (() => {
    const noPe = mk('rcc', 'attribute_dice: { PE: "N/A", PS: "3d6" }');
    return combineClasses(noPe, reborn).attribute_dice.PS === '3d6+32';
  })());
}

section('Psionic category narrowing');
{
  // BOOK-INGEST-AUDIT.md F16. A skill category has taken `only` / `except`
  // since the beginning; a psionic category could not. The Crazy's book allows
  // two categories "excluding Astral Projection, Ectoplasm, Object Read and
  // Telekinesis", and the only way to say that was `powers_from`, which
  // REPLACES the category gate rather than narrowing it - so it would have
  // meant enumerating the other forty-seven and re-enumerating them whenever a
  // Sensitive power was added.
  const mk = (block) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\npsionics:\n${block}\n---\n\n## Lore\n\nx\n`);

  const narrowed = mk(`  type: "minor"
  powers_starting: 3
  categories_allowed:
    - { name: "Sensitive", except: ["Object Read (Psychometry)"] }
    - "Physical"`);
  check('a psionic category takes an except', narrowed.ok, JSON.stringify(narrowed.errors));

  // The SAME function the skill pickers use, so the two cannot disagree about
  // what a category entry means.
  const cats = narrowed.data.psionics.categories_allowed;
  check('and the excluded power is refused',
    !categoryAllows(cats, { name: 'Object Read (Psychometry)', category: 'Sensitive' }));
  check('while the rest of its category is allowed',
    categoryAllows(cats, { name: 'Sixth Sense', category: 'Sensitive' }));
  check('and an unnarrowed category is untouched',
    categoryAllows(cats, { name: 'Levitation', category: 'Physical' }));
  check('and a category the class never named is still refused',
    !categoryAllows(cats, { name: 'Bio-Regeneration', category: 'Healing' }));

  check('an only list narrows the other way', (() => {
    const only = mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", only: ["Levitation"] }');
    const c = only.data.psionics.categories_allowed;
    return categoryAllows(c, { name: 'Levitation', category: 'Physical' })
      && !categoryAllows(c, { name: 'Ectoplasm', category: 'Physical' });
  })());

  // A plain string still means the whole category - every other class in the
  // catalog writes one, and none of them may change meaning.
  check('a plain string still opens the whole category', (() => {
    const plain = mk('  type: "minor"\n  categories_allowed: ["Physical"]');
    return categoryAllows(plain.data.psionics.categories_allowed,
      { name: 'Ectoplasm', category: 'Physical' });
  })());

  // A percentage is a SKILL idea: a psionic power has an I.S.P. cost and no
  // percentage to raise, so a bonus here would be stored and never read.
  check('a bonus on a psionic category is a parse error',
    !mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", bonus: 10 }').ok);
  check('and both narrowings at once is still an error',
    !mk('  type: "minor"\n  categories_allowed:\n    - { name: "Physical", only: ["Levitation"], except: ["Ectoplasm"] }').ok);

  // An ability that GRANTS psionics carries the same block and reaches the same
  // gate, so it is validated too.
  check('an ability\'s psionics block is validated as well', (() => {
    const bad = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n'
      + 'special_abilities:\n  - name: "Awakening"\n    description: "d"\n    psionics: { type: master, categories_allowed: [{ name: "Super", bonus: 5 }] }\n'
      + '---\n\n## Lore\n\nx\n');
    return !bad.ok;
  })());

  // The server refuses what the picker will not offer - one function, three
  // call sites, the wizard twice and the grant checker once.
  const picks = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
    '_lib', 'power-picks.js'), 'utf8');
  check('the server gates psionic grants through the same function',
    picks.includes('categoryAllows(cats, row)'));
  const appSrc = readFileSync(join(repoRoot, 'apps', 'character-creator', 'app.js'), 'utf8');
  check('and neither wizard picker still tests membership by hand',
    !/allowed\.includes\(\w+\.category\)/.test(appSrc));
}

section('Magic composition');
{
  // BOOK-INGEST-AUDIT.md F14. F10 excluded magic saying no race/O.C.C. pair
  // states both. Thirteen races and eighteen occupations do - 234 pairs - and
  // the line was worse than the psionics bug beside it: psionics at least gave
  // the RACE the tie, magic handed the occupation the win with no comparison.
  const mk = (cat, magic) => parseClassMarkdown(
    `---\nid: t-${cat}\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\nmagic:\n${magic}\n---\n\n## Lore\n\nx\n`).data;

  const race = mk('rcc', `  type: "spell"
  spells: ["Globe of Daylight", "Cloud of Smoke"]
  spells_starting: 10
  spell_levels_allowed: [1, 2, 3, 4]`);
  const occ = mk('occ', `  type: "elemental"
  spells: ["Cloud of Smoke", "Fire Bolt"]
  spells_starting: 3
  spell_levels_allowed: [1]`);
  const both = combineClasses(race, occ).magic;

  check('a race and an occupation both stating magic keep both', (both.spells || []).length === 3);
  check('and a spell both grant is held once',
    both.spells.filter((n) => n === 'Cloud of Smoke').length === 1);

  // THE TYPE IS A KIND, NOT A DEGREE - the one real difference from psionics.
  // `spell`, `elemental`, `druid`, `intuitive` are how a character casts, so
  // there is no stronger to compute and the occupation's statement wins.
  check('the type is the occupation\'s, because it is a kind and not a degree',
    both.type === 'elemental');

  // A count takes the higher, the reading F10 arrived at: taking the
  // occupation's is LOWER in 35 of the 108 live pairs that state both.
  check('a count takes the higher of the two', both.spells_starting === 10);

  // The level set is WIDENED. Taking the occupation's drops a level the race
  // allows in 19 of the 28 pairs stating both - an entrancer who becomes a
  // Warlock would lose levels 2, 3 and 4 from its own page.
  check('the allowed spell levels are unioned and sorted',
    JSON.stringify(both.spell_levels_allowed) === JSON.stringify([1, 2, 3, 4]));

  check('one side alone is untouched', (() => {
    const bare = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(race, bare).magic.spells_starting === 10
      && combineClasses(parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\n---\n\n## Lore\n\nx\n').data, occ).magic.spells_starting === 3;
  })());

  check('an unenumerated key survives the merge', (() => {
    const withLists = mk('occ', '  type: "spell"\n  spell_lists: ["Ley Line"]');
    return combineClasses(race, withLists).magic.spell_lists[0] === 'Ley Line';
  })());

  // A superseding class does not inherit the race's magic either - the same
  // exception it makes everywhere else (F11). Unexercised today, because the
  // only class carrying the flag states no magic, and coherent for when one does.
  check('a superseding class takes its own magic outright', (() => {
    const reborn = parseClassMarkdown(
      '---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nsupersedes_race: true\nmagic:\n  type: "druid"\n  spells_starting: 2\n---\n\n## Lore\n\nx\n').data;
    const c = combineClasses(race, reborn).magic;
    return c.type === 'druid' && c.spells_starting === 2 && !c.spells;
  })());

  // Both merges share one union helper, because they ask the same question of
  // different columns and the pair written twice is the pair that drifts.
  const src = readFileSync(join(repoRoot, 'apps', 'character-creator', 'js', 'parser.js'), 'utf8');
  check('the psionics and magic merges share one union helper',
    (src.match(/unionByName\(/g) || []).length >= 4 && (src.match(/function unionByName/g) || []).length === 1);
}

section('Psionics composition');
{
  // BOOK-INGEST-AUDIT.md F10. `combineClasses` used to CHOOSE between a race's
  // psionics block and an occupation's, and the comparison was strictly
  // greater, so a TIE handed the whole thing to the race and the occupation's
  // powers, picks, schedule, categories and I.S.P. formula were all discarded.
  //
  // A race says what a member of that race is born with; an occupation says
  // what training adds. They are two sentences, not rival answers to one
  // question.
  const mk = (cat, psi) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\npsionics:\n${psi}\n---\n\n## Lore\n\nx\n`).data;

  const race = mk('rcc', `  type: major
  isp_base: "1d4x10"
  powers: ["Sixth Sense", "Mind Block"]
  powers_starting: 8
  categories_allowed: ["Healing", "Physical", "Sensitive"]
  powers_schedule:
    - { level: 3, count: 1 }`);
  const occ = mk('occ', `  type: major
  isp_base: "3d6x10"
  powers: ["Mind Block", "Telekinesis"]
  powers_starting: 2
  categories_allowed: ["Sensitive", "Super"]
  powers_schedule:
    - { level: 2, count: 1 }
    - { level: 4, count: 2 }`);
  const both = combineClasses(race, occ).psionics;

  // THE TIE IS THE WHOLE BUG. Before F10 this returned the race's block entire.
  check('a tie no longer discards the occupation', both.powers_schedule.length === 2);

  // Inventories add up.
  check('granted powers are unioned', both.powers.length === 3
    && ['Sixth Sense', 'Mind Block', 'Telekinesis'].every((n) => both.powers.includes(n)));
  check('and a power both sides grant is held once',
    both.powers.filter((n) => n === 'Mind Block').length === 1);
  check('allowed categories are unioned', both.categories_allowed.length === 4
    && both.categories_allowed.includes('Super') && both.categories_allowed.includes('Healing'));

  // Counts take the HIGHER, which is not what F10 asked for: preferring the
  // occupation's figure is LOWER in 89 of the 165 live pairs that state both,
  // so a psychic dragon hatchling would have dropped from eight starting
  // powers to one for studying as a Dog Boy - the exact loss F10 exists to stop.
  check('a count takes the higher of the two', both.powers_starting === 8);

  // A ladder is not a count and cannot be maxed. Running both would fire both
  // sets of grants at every threshold.
  check('a schedule takes the occupation\'s', both.powers_schedule[0].level === 2);
  check('and falls back to the race\'s when the occupation states none', (() => {
    const plain = mk('occ', '  type: major\n  isp_base: "2d6"');
    return combineClasses(race, plain).psionics.powers_schedule[0].level === 3;
  })());

  // The tier is the one thing the old code was right about, and the I.S.P.
  // formula travels with it. A tie goes to the occupation.
  check('the tier is the stronger of the two', (() => {
    const minor = mk('occ', '  type: minor\n  isp_base: "2d6"');
    return combineClasses(race, minor).psionics.type === 'major';
  })());
  check('and a stronger occupation raises it', (() => {
    const master = mk('occ', '  type: master\n  isp_base: "2d6"');
    return combineClasses(race, master).psionics.type === 'master';
  })());
  check('the I.S.P. formula follows the tier', (() => {
    const minor = mk('occ', '  type: minor\n  isp_base: "2d6"');
    return combineClasses(race, minor).psionics.isp_base === '1d4x10';
  })());
  check('and a tie gives it to the occupation', both.isp_base === '3d6x10');
  check('a winner stating no formula falls back rather than blanking it', (() => {
    const master = mk('occ', '  type: master');
    return combineClasses(race, master).psionics.isp_base === '1d4x10';
  })());

  // One side only is unchanged behaviour, and must stay that way.
  check('a race alone keeps its block', (() => {
    const plain = mk('occ', '  type: minor').psionics;
    void plain;
    const noPsi = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(race, noPsi).psionics.powers_starting === 8;
  })());
  check('an occupation alone keeps its block', (() => {
    const noPsi = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\n---\n\n## Lore\n\nx\n').data;
    return combineClasses(noPsi, occ).psionics.powers_starting === 2;
  })());

  // A key neither F10 nor this function knows about must survive rather than be
  // silently dropped. `powers_from` is in the corpus exactly once, which is the
  // argument for spreading rather than enumerating.
  check('an unenumerated key survives the merge', (() => {
    const withFrom = mk('occ', '  type: major\n  isp_base: "2d6"\n  powers_from: ["Bio-Manipulation"]');
    return combineClasses(race, withFrom).psionics.powers_from[0] === 'Bio-Manipulation';
  })());

  // The SECOND site, which F10 does not mention. `applyAbilities` folded an
  // ability's psionics block with the same strict-greater rule, and its comment
  // claims it is the same rule composition uses - which F10 would have made
  // false. The Godling is the live case: a minor psychic whose "Super-Psionic
  // Powers" ability grants `{ type: master }` and nothing else, so choosing the
  // ability's block outright replaced its I.S.P. formula with none at all.
  check('an ability raises the tier without erasing the class block', (() => {
    const cls = parseClassMarkdown(`---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\npsionics:\n  type: minor\n  isp_base: "M.E. number plus 1D6x10"\nspecial_abilities:\n  - name: "Super-Psionic Powers"\n    description: "d"\n    psionics: { type: master }\n---\n\n## Lore\n\nx\n`).data;
    const after = applyAbilities(cls, [{ name: 'Super-Psionic Powers' }]).psionics;
    return after.type === 'master' && after.isp_base === 'M.E. number plus 1D6x10';
  })());
}

section('Related-skill floors');
{
  // BOOK-INGEST-AUDIT.md F6. `occ_related_skills` says how many picks and which
  // categories are legal, and narrows a category with only/except. All three
  // are ceilings. `minimums` is the floor: "select 8 other skills, but at least
  // two must be selected from espionage and two from rogue skills".
  const mk = (rel) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n  occ_related_skills:\n${rel}\n---\n\n## Lore\n\nx\n`);

  const two = mk(`    count: 8
    categories: ["Espionage", "Rogue", "Physical"]
    minimums:
      - { count: 2, category: "Espionage" }
      - { count: 2, category: "Rogue" }`);
  check('a per-category floor parses', two.ok, JSON.stringify(two.errors));
  check('and normalises to a list of categories',
    JSON.stringify(relatedMinimums(two.data))
      === JSON.stringify([{ count: 2, categories: ['Espionage'] },
                          { count: 2, categories: ['Rogue'] }]));

  // The City Rat's floor is a UNION - "at least three must be selected from
  // Physical or Rogue skills" - satisfied by three of either or any mix.
  const union = mk(`    count: 10
    categories: ["Physical", "Rogue"]
    minimums:
      - { count: 3, categories: ["Physical", "Rogue"] }`);
  check('a union floor parses', union.ok, JSON.stringify(union.errors));
  check('and keeps both categories in one floor',
    relatedMinimums(union.data).length === 1
      && relatedMinimums(union.data)[0].categories.length === 2);
  check('a class with no floors reports none', relatedMinimums(mk('    count: 4').data).length === 0);

  // Every one of these is an ERROR rather than a warning: a floor is enforced
  // server-side the moment it parses, so a floor that is wrong refuses every
  // character of its class, and one silently dropped puts the class back where
  // F6 found it.
  check('a floor outside the granted categories is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2, category: "Espionage" }').ok);
  check('a floor bigger than the whole allowance is rejected',
    !mk('    count: 3\n    categories: ["Physical"]\n    minimums:\n      - { count: 4, category: "Physical" }').ok);
  check('floors summing past the allowance are rejected',
    !mk('    count: 3\n    categories: ["Physical", "Rogue"]\n    minimums:\n      - { count: 2, category: "Physical" }\n      - { count: 2, category: "Rogue" }').ok);
  check('a floor with no category is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2 }').ok);
  check('a floor of zero is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 0, category: "Physical" }').ok);
  check('a floor setting both spellings is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums:\n      - { count: 2, category: "Physical", categories: ["Physical"] }').ok);
  check('minimums that is not a list is rejected',
    !mk('    count: 8\n    categories: ["Physical"]\n    minimums: 2').ok);

  // A FLOOR IS NOT A CEILING. The count and category rules are broken the
  // instant they are broken; a floor merely unmet may still be met by picks not
  // yet spent, so only an UNREACHABLE one is a violation. Without this every
  // half-built character would be refused a save.
  const cls = two.data;
  const st = (cats, allow = 8) => relatedFloorStatus(cls, cats, allow);
  check('no picks yet is not a violation', st([]).unreachable === false);
  check('floors met is not a violation',
    st(['Espionage', 'Espionage', 'Rogue', 'Rogue']).unreachable === false);
  check('spent out with no floor met is a violation',
    st(['Physical', 'Physical', 'Physical', 'Physical',
        'Physical', 'Physical', 'Physical', 'Physical']).unreachable === true);

  // The shortfalls are summed rather than tested one at a time. Six of eight
  // spent holding one espionage and no rogue leaves each floor individually
  // reachable and the two together needing three picks where two remain.
  check('shortfalls are summed against what is left',
    st(['Espionage', 'Physical', 'Physical', 'Physical', 'Physical', 'Physical']).unreachable === true);
  check('and are not tested one at a time',
    st(['Espionage', 'Rogue', 'Physical', 'Physical', 'Physical']).unreachable === false);

  // A union floor counts a pick from EITHER category and does not demand both.
  const uSt = (cats) => relatedFloorStatus(union.data, cats, 10);
  check('a union floor takes either category',
    uSt(['Physical', 'Physical', 'Physical']).floors[0].met === true);
  check('and a mix across the two',
    uSt(['Rogue', 'Physical', 'Rogue']).floors[0].met === true);

  // The allowance grows on a schedule, and the floor rides along with it: the
  // book says "at least two of the EIGHT", but a stored skill row records no
  // level, so the first eight cannot be told from the two granted at level
  // three. Counting over every related pick is the weaker reading, and the
  // weaker reading never refuses a character the book allows.
  check('a bigger allowance leaves more room, never less',
    st(['Physical', 'Physical', 'Physical', 'Physical', 'Physical', 'Physical'], 12).unreachable === false);

  // ── the wizard and the server must not disagree — RETRO-AUDIT R18 ──
  //
  // `relatedFloorStatus` takes an allowance and a list of the categories held,
  // and the wizard and the validator have to pass the SAME pair. They did not:
  // the wizard passed `occ_related_skills.count` and only the level-one picks,
  // while the server passes `relatedAllowance(cls, level)` and every
  // related-typed row, level-granted ones included.
  //
  // NOTHING EXERCISES THE WIZARD ITSELF - `app.js` is read here as source text
  // and never executed - so this pins the arithmetic the wizard is now supposed
  // to do, and the case that made a half-fix worse than the bug.
  const lvlCls = parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n`
    + `  occ_related_skills:\n    count: 7\n`
    + `    minimums:\n      - { count: 2, category: "Science" }\n`
    + `    categories: ["Science", "Physical"]\n`
    + `    schedule: [{ level: 3, count: 2 }]\n---\n\n## Lore\n\nx\n`).data;

  check('the allowance a level-3 character gets is the count plus the grant',
    relatedAllowance(lvlCls, 1) === 7 && relatedAllowance(lvlCls, 3) === 9);

  // Seven off-floor picks at level 1: no room left, so the floor is out of
  // reach and the save is refused. Both sides agree, and always did.
  const seven = Array.from({ length: 7 }, () => 'Physical');
  check('spent out at level one is unreachable',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 1)).unreachable === true);

  // THE CASE THE OLD WIZARD GOT RIGHT BY ACCIDENT. At level 3 the same seven
  // picks leave two banked, so the floor is still reachable and the server
  // accepts. Passing `count` here says unreachable - a false alarm.
  check('and reachable at level three, because the schedule banked two',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 3)).unreachable === false);
  check('where the old count-only allowance would have cried wolf',
    relatedFloorStatus(lvlCls, seven,
      lvlCls.skills.occ_related_skills.count).unreachable === true);

  // THE CASE A HALF-FIX WOULD HAVE MISSED, which is the one that matters. Spend
  // the two banked picks off-floor as well and the character really is illegal.
  // The server counts all nine because level-granted picks are stored
  // `type: 'related'`; a wizard that raised the allowance to 9 but still counted
  // only the first seven would compute two picks remaining and say NOTHING.
  const nine = Array.from({ length: 9 }, () => 'Physical');
  check('nine off-floor picks at level three are unreachable',
    relatedFloorStatus(lvlCls, nine, relatedAllowance(lvlCls, 3)).unreachable === true);
  check('and counting only the level-one picks would have gone silent on it',
    relatedFloorStatus(lvlCls, seven, relatedAllowance(lvlCls, 3)).unreachable === false);
}

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

documentedCountsChecks();

// ---------- 1c5. Access JWT verification and Claude spend logging ----------
// The audit's F4 and F3. The verifier is a pure function of (token, keys,
// options), which is what lets this section sign real tokens with WebCrypto
// and prove every refusal path — no network, no Access team. The wiring is
// pinned as source, because the load-bearing properties (pass-through when
// unconfigured; metering that cannot break the call it measures) are exactly
// the kind that vanish silently in a refactor.
section('Access JWT verification');
{
  const { verifyAccessJwt } = await import('../../../functions/api/_lib/access-jwt.js');
  const b64u = (buf) => Buffer.from(buf).toString('base64url');
  const enc = (obj) => b64u(JSON.stringify(obj));
  const { publicKey, privateKey } = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256', modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]) },
    true, ['sign', 'verify']);
  const jwk = { ...(await crypto.subtle.exportKey('jwk', publicKey)), kid: 'test-key', use: 'sig' };
  const now = Math.floor(Date.now() / 1000);
  const sign = async (payload, header = { alg: 'RS256', kid: 'test-key' }) => {
    const input = enc(header) + '.' + enc(payload);
    const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', privateKey,
      new TextEncoder().encode(input));
    return input + '.' + b64u(sig);
  };
  const claims = { aud: ['site-aud'], email: 'nate@example.com', exp: now + 300, iat: now };
  const good = await sign(claims);

  const ok = await verifyAccessJwt(good, [jwk], { aud: 'site-aud' });
  check('a valid token verifies and yields its email',
    ok.ok === true && ok.email === 'nate@example.com', JSON.stringify(ok));
  check('an expired token is refused',
    !(await verifyAccessJwt(await sign({ ...claims, exp: now - 3600 }), [jwk], { aud: 'site-aud' })).ok);
  check('the wrong audience is refused',
    !(await verifyAccessJwt(good, [jwk], { aud: 'some-other-app' })).ok);
  check('a tampered payload fails the signature, not the parse', (await verifyAccessJwt(
    good.replace(/\.[^.]+\./, '.' + enc({ ...claims, email: 'gm@example.com' }) + '.'),
    [jwk], { aud: 'site-aud' })).reason === 'signature does not verify');
  check('alg none dies before any key is consulted', (await verifyAccessJwt(
    enc({ alg: 'none', kid: 'test-key' }) + '.' + enc(claims) + '.',
    [jwk], { aud: 'site-aud' })).reason.startsWith('unsupported algorithm'));
  check('a token signed by a rotated-away key is refused',
    !(await verifyAccessJwt(await sign(claims, { alg: 'RS256', kid: 'rotated-away' }), [jwk], { aud: 'site-aud' })).ok);
  check('a token with no email claim is refused',
    (await verifyAccessJwt(await sign({ ...claims, email: undefined }), [jwk], { aud: 'site-aud' })).reason === 'no email claim');
  check('every refusal carries a readable reason', await (async () => {
    const bad = [
      await verifyAccessJwt('not-a-jwt', [jwk], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [], { aud: 'site-aud' }),
      await verifyAccessJwt(good, [jwk], { aud: 'other' }),
    ];
    return bad.every((r) => r.ok === false && typeof r.reason === 'string' && r.reason.trim());
  })());

  const fnDir = join(appDir, '..', '..', 'functions', 'api');
  const mw = readFileSync(join(fnDir, '_middleware.js'), 'utf8');
  check('the middleware passes through when unconfigured — the original posture',
    /if \(!domain \|\| !aud\) return next\(\)/.test(mw));
  check('and requires the token identity to match the header everything reads',
    /Cf-Access-Authenticated-User-Email/.test(mw));
  // The arming vars live in wrangler.jsonc, so pages dev reads them too — and
  // local dev has no Access to mint a token. Without the exemption, arming
  // production bricks every local run, including this suite's sibling.
  check('and exempts localhost, where no Access exists to mint a token',
    /localhost/.test(mw) && /127\.0\.0\.1/.test(mw));
  // Armed is a statement the repo makes, so pin it: both vars present in
  // wrangler.jsonc, or the middleware silently returns to header-trust and
  // nothing says so.
  const wranglerCfg = readFileSync(join(appDir, '..', '..', 'wrangler.jsonc'), 'utf8');
  check('wrangler.jsonc arms the middleware with both variables',
    /"ACCESS_TEAM_DOMAIN":\s*"[^"]+\.cloudflareaccess\.com"/.test(wranglerCfg)
    && /"ACCESS_AUD":\s*"[0-9a-f]{64}"/.test(wranglerCfg));

  const client = readFileSync(join(fnDir, '_lib', 'claude-client.js'), 'utf8');
  check('usage recording is fail-open, so metering cannot break the call',
    /export async function recordUsage/.test(client)
    && /never the caller's problem/.test(client));
  const proxy = readFileSync(join(fnDir, 'claude.js'), 'utf8');
  check('the proxy records who spent the key',
    /recordUsage\(/.test(proxy) && /getAccessEmail\(request\)/.test(proxy));
  const askSrc = readFileSync(join(fnDir, 'character-creator', 'campaigns', '[id]', 'ask.js'), 'utf8');
  check('and so does the campaign Ask', /recordUsage\(/.test(askSrc));

  // Every remaining Claude call. Extraction sends a whole PDF page and is the
  // most expensive call in the repo; it was also the only one with no number
  // attached, which made "what did this book cost" unanswerable while the
  // table to answer it had existed since migration 038.
  //
  // Pinned by counting callAnthropic against recordUsage across functions/,
  // rather than by naming today's files: a new endpoint that calls the model
  // and forgets to meter it is exactly the regression this is for, and a list
  // of filenames would not see it.
  const claudeCalls = [];
  const walkFns = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) { walkFns(full); continue; }
      if (!e.name.endsWith('.js')) continue;
      const src = readFileSync(full, 'utf8');
      if (/\bawait callAnthropic\(/.test(src)) {
        claudeCalls.push({ file: full.slice(fnDir.length + 1), metered: /\brecordUsage\(/.test(src) });
      }
    }
  };
  walkFns(fnDir);
  // The floor was five while the importer contributed its own routes. Those
  // are gone and extraction runs from scripts/ now, so functions/ holds three
  // callers: the proxy, campaign-ask and the NPC sweep. The floor is a guard
  // against the sweep silently matching NOTHING, not a target - if it ever
  // reads zero the check has stopped checking.
  check('every file in functions/ that calls the model also meters it',
    claudeCalls.length >= 3 && claudeCalls.every((c) => c.metered),
    claudeCalls.filter((c) => !c.metered).map((c) => c.file).join(', ') || `${claudeCalls.length} found`);

  // The labels are the whole point of the table - an endpoint column full of
  // `import` tells you nothing about what the tokens went to.
  //
  // EXTRACTION LEFT functions/ WITH THE IN-APP IMPORTER. It runs from
  // scripts/extract-class.mjs now, so these checks FOLLOW it rather than
  // being deleted with the routes: what F7 shipped is that extraction is
  // metered and says what it extracted, and that is still worth pinning.
  const extractor = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');
  check('the class extractor labels its spend',
    /'cc-extract-class'/.test(extractor));

  // Metered BEFORE the reply is parsed. A truncated or refused extraction has
  // already spent the input tokens for a whole page, and a run that cost money
  // and produced nothing is the run most worth having a number for.
  const meterBeforeParse = (src) => {
    const at = src.indexOf('recordUsage(');
    const parseAt = src.indexOf('JSON.parse(upstream.text)');
    return at !== -1 && parseAt !== -1 && at < parseAt;
  };
  check('a failed extraction is still recorded, because the tokens were still spent',
    extractor.indexOf('claude_usage') < extractor.indexOf('if (!payload) die('));

  // Both places used to say the admin importers were deliberately unlogged,
  // and both now explain that they no longer are. So this pins the CURRENT
  // claim rather than the absence of the old one — a check that greps for the
  // stale phrase fails on the correction that quotes it, which is a trap this
  // repo has walked into before.
  const setupSrc = readFileSync(join(appDir, '..', '..', 'SETUP.md'), 'utf8');
  check('SETUP.md states that every Claude call in functions/ is metered',
    /Every Claude call in `functions\/` writes one row to\s*\r?\n?`claude_usage`/.test(setupSrc));
  check('and names the endpoints it can be read by',
    /cc-extract-class/.test(setupSrc) && /cc-npc-sweep/.test(setupSrc));
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

classCheckToolChecks();

bookRegistryChecks();

// ---------- 1e-ter. The backend class extractor ----------
//
// scripts/extract-class.mjs replaces the in-app importer's extraction half.
// These pin the things about it that are load-bearing and would break
// silently: the art-page threshold, the cached-text prompt, the metering, and
// the fact that it drafts rather than publishes.
section('Backend class extractor');
{
  const src = readFileSync(join(repoRoot, 'scripts', 'extract-class.mjs'), 'utf8');

  // THE THRESHOLD IS THE WHOLE POINT OF THE GUARD. Wormwood p056 is 14 bytes
  // trimmed and p058 is 8; the smallest page in that book that is REAL text is
  // p074 at 744, the Hospitaller's code of chivalry set in one sparse column. A
  // threshold at or above 744 refuses a real page; one at or below 14 waves the
  // art through, which is how the Apok loses a third of itself.
  const m = src.match(/const ART_PAGE_BYTES = (\d+);/);
  check('the extractor states an art-page threshold', !!m);
  const artBytes = m ? Number(m[1]) : null;
  check('and it sits between the largest art page and the smallest real one',
    artBytes !== null && artBytes > 14 && artBytes < 744, String(artBytes));

  // The guard has to REFUSE by default. A version that warned and carried on
  // would read the same in a diff and catch nothing.
  check('a short page stops the run rather than warning',
    src.includes('REFUSING') && src.includes('process.exit(1)'));
  check('and there is an explicit escape hatch for the rare real case',
    src.includes('--allow-short'));

  // execFileSync with shell:true does not quote the arguments it joins - the
  // SQL loses its spaces and wrangler reports twenty unknown arguments. This
  // script hit that on its first run; d1Query is the one that gets it right.
  // Checked on the IMPORT rather than the word, because the header explains
  // the trap by name and a substring test would match the explanation.
  check('the extractor queries D1 through the repo helper, not its own spawn',
    src.includes('d1Query') && !/from 'node:child_process'/.test(src));

  // A truncated reply that parses is worse than an error, because it gets
  // reviewed as though it were a whole class.
  check('a max_tokens stop is treated as a failure, not a result',
    src.includes('max_tokens') && src.includes('only partly read'));

  // F7 shipped metering so the cost of a book is a query rather than an
  // estimate. Moving extraction off the metered route would quietly undo it.
  check('the extractor meters its call to claude_usage',
    src.includes('claude_usage') && src.includes('cc-extract-class'));

  // It drafts. It must not be able to publish.
  check('the extractor writes no catalog row and no class row',
    !/INSERT\s+(OR\s+\w+\s+)?INTO\s+(imported_classes|gear|skills|spells|psionic_powers)/i.test(src));

  // The cached-text prompt must not tell the model to un-splice columns that
  // read-columns.py already resolved, and must not claim a PDF is attached.
  // There is ONE prompt now. The PDF one went with the routes that sent PDFs,
  // and the "no export is named nowhere else" check is what noticed.
  const cachePrompt = buildUserPrompt([{ name: 'X', text: 'md' }], null);
  check('the prompt does not claim an attached PDF',
    !cachePrompt.includes('attached PDF'));
  check('the cached-text system prompt says the columns are already resolved',
    SYSTEM_PROMPT_CACHE.includes('already extracted')
    && SYSTEM_PROMPT_CACHE.includes('DO NOT try to re-order'));
  check('and warns that a stat block continues across a page break',
    SYSTEM_PROMPT_CACHE.includes('CONTINUES at the top of the next'));
}

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


// ---------- The Race briefing names every bonus group ----------
// The briefing exists so a player sees what a class grants BEFORE committing to
// it, and it listed attributes, combat and saves but not POOLS. A pool bonus
// does not show in the briefing's `Pools` line either, because that line prints
// the FORMULA and a class that adds to another's roll states no formula - so
// the Troll's +40 S.D.C., its single most distinctive number, appeared nowhere.
// Fifteen classes published before the races grant one, so it was never only a
// race problem.
section('Race briefing');
{
  const src = readFileSync(join(appDir, 'app.js'), 'utf8');
  const fn = src.slice(src.indexOf('function raceBriefing()'));
  const body = fn.slice(0, fn.indexOf('\n}\n'));
  for (const group of ['attributes', 'pools', 'combat', 'saves']) {
    check(`the briefing reads bonuses.${group}`,
      new RegExp(`b\\.${group} \\|\\| \\{\\}`).test(body),
      `bonuses.${group} is granted by real classes and the briefing never prints it`);
  }
  // Every group derive.js can act on, so adding one to the parser without
  // adding it here fails rather than showing the player nothing.
  check('and that is every group a class bonus can name',
    /BONUS_GROUPS/.test(readFileSync(join(appDir, 'js', 'parser.js'), 'utf8')));
  check('pool keys are labelled, not printed raw',
    /POOL_LABELS_SHORT/.test(body), 'a bonus would read "sdc +40" rather than "S.D.C. +40"');
}


catalogMatchingChecks();

// The environment half lives in its own file; it runs last because it is the
section('A class cannot write a bonus the sheet will not draw');
{
  // `bonuses.combat` and `bonuses.saves` are open at the VALIDATOR - group
  // names are checked, the keys inside them are not, and derive.js's addBonus
  // adds any finite number under any key. They are CLOSED at the sheet, which
  // draws SAVE_FIELDS and COMBAT_FIELDS as literal lists. So an invented or
  // misspelled key parses, validates, composes, and renders NOWHERE.
  //
  // The two checks above start from derive*() output, so neither can see a key
  // a CLASS writes - a class-authored key is never in the derived set.
  // vacuum-wasp's own extraction_notes is the only place this was written
  // down: "combat: { dogfighting: 2 } would parse, validate and render
  // NOWHERE". SKILL-AUDIT F23.
  //
  // Parsed through the REAL parser, not a regex over the SQL. A naive inline
  // `{ }` match reads that very note's prose as data and reports a key that
  // is not there - which is what happened while F1 was being taken, and is
  // CLASS-AUDIT F17's shape.
  const sheetSrc = readFileSync(join(appDir, 'sheet.js'), 'utf8');
  const listKeys = (name) => {
    const b = sheetSrc.slice(sheetSrc.indexOf(`const ${name}`),
      sheetSrc.indexOf('];', sheetSrc.indexOf(`const ${name}`)));
    return [...b.matchAll(/\['([a-z_]+)',/g)].map((m) => m[1]);
  };
  const drawable = {
    combat: new Set([
      ...listKeys('COMBAT_FIELDS'),
      // States a starting number rather than adding to one. parser.js folds it
      // and derive.js strips it before the combat map reaches the sheet, so it
      // is correctly absent from COMBAT_FIELDS.
      'attacks_base',
    ]),
    saves: new Set([
      ...listKeys('SAVE_FIELDS'),
      // Rendered above the sixteen as its own editField.
      'psionics_target',
      // A LIST of { label, bonus }, not a keyed number - the escape hatch for a
      // save the sixteen do not name (BOOK-INGEST-AUDIT F7).
      'other',
    ]),
  };

  const offenders = [];
  let parsed = 0;
  for (const f of readdirSync(join(appDir, 'db')).filter((n) => /^add-.*-class\.sql$/.test(n))) {
    let md = null;
    try { md = extractClassMarkdown(readFileSync(join(appDir, 'db', f), 'utf8')); } catch { md = null; }
    if (!md) continue;
    const res = parseClassMarkdown(md);
    if (!res?.ok || !res.data) continue;
    parsed++;
    const groups = [res.data.bonuses, ...(res.data.bonuses?.at_level || []),
      ...(res.data.variants || []).map((v) => v.bonuses)].filter(Boolean);
    for (const g of groups) {
      for (const kind of ['combat', 'saves']) {
        for (const key of Object.keys(g[kind] || {})) {
          if (!drawable[kind].has(key)) offenders.push(`${f}: bonuses.${kind}.${key}`);
        }
      }
    }
  }

  check('every add-*-class.sql was parsed', parsed > 100, `only ${parsed}`);
  check('no class writes a combat or save key the sheet cannot draw',
    offenders.length === 0,
    `${offenders.join('; ')} - add it to COMBAT_FIELDS/SAVE_FIELDS in sheet.js, or use saves.other / a special_ability`);
}

instructionPathChecks();

// slow one - it shells out to wrangler.
environmentChecks();
catalogDataChecks();

process.exit(summary() === 0 ? 0 : 1);
