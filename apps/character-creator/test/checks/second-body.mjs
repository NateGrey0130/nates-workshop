// The Nightbane second body: the Facade a character wears, the Morphus it
// becomes, and the generator that rolls one. Four sections, lifted out of
// smoke.mjs whole.
//
// WHY THESE FOUR AND NOT SOME OTHER FOUR. They were already contiguous, they
// are one subject, and they were the only group in that file whose imports
// were entirely its own: twenty-six bindings - all of `js/second-form.js`,
// nineteen of `js/morphus.js`, and `secondFormHitPointDice` /
// `rollSecondFormHitPoints` from `_lib/leveling.js` - are used here and
// nowhere else in the suite. Nothing had to be shared out or duplicated to
// make the cut, which is the same test `environment.mjs` passed when it was
// split out ("it needed four bindings from it, all of them harness").
//
// `effectParts` and `horrorPart` came out of that morphus import too and are
// NOT re-imported here: they were unused in smoke.mjs and are unused here.
// They are two of a larger set of imported-but-unused bindings still in
// smoke.mjs; the rest were left alone rather than swept in on the way past.
//
// The split is mechanical. Not one line of the four sections changed - the
// range moved verbatim and the check count is the proof: 2737 before, 2737
// after, in the same 164 sections.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { DatabaseSync } from 'node:sqlite';
import { buildProposal, secondFormHitPointDice, rollSecondFormHitPoints }
  from '../../../../functions/api/character-creator/_lib/leveling.js';
import { CHARACTER_JSON_COLUMNS } from '../../../../functions/api/character-creator/_lib/character-json.js';
import { validateCharacter } from '../../../../functions/api/character-creator/_lib/validate-character.js';
import { variants } from '../../../../scripts/catalog-match-lib.mjs';
import { dice } from '../../../../scripts/ocr-fields-lib.mjs';
import { applyVariant, combineClasses, parseClassMarkdown, validateBonuses } from '../../js/parser.js';
import { composeClass } from '../../js/compose.js';
import { secondFormView, secondFormViolations, rollSecondForm, rollTraitResult, bonusPaths }
  from '../../js/second-form.js';
import { morphusTables, replayMorphus, entriesFor, rollOn, decide, rollNext, pickNext, skipNext, undoLast,
         rollUntilBlocked, chooseSub, morphusResults, animalCombinations, animalForDie, rulesDisagreeWithRows,
         MORPHUS_RULES, MORPHUS_START, UNPRINTED_TABLE, DUPLICATE_ENTRY }
  from '../../js/morphus.js';
import { appDir, appPath, repoRoot, check, section, wantSection } from '../harness.mjs';

// Declared by hand, and smoke.mjs's 'The checks modules declare the sections
// they run' check reads both directions out of this file: an announcement
// missing from this list, and a name here that nothing announces.
//
// This comment used to carry a warning not to write section( in prose here,
// because that check counted the occurrences textually and read a mention in a
// comment as a fifth call it could not parse a literal out of. It cost a red
// run on the day this module was created. The check is anchored to statement
// position now and no longer cares, so the warning is gone rather than left
// standing as a rule about a bug that was fixed.
const SECTIONS = ['A Horror Factor the character PROJECTS (F75)',
  'A second body: the Facade and the Morphus (BOOK-INGEST-AUDIT F74)',
  'Damage, healing and rest on the active form (Nightbane follow-up 5)',
  'The Morphus generator (survey D5, PR 3 of 4)'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  // `js/derive.js` is a CLASSIC script, not a module, so it is loaded by
  // evaluating it against a stand-in global rather than imported - the same
  // four lines smoke.mjs uses for its 'Psychic tiers' section, which is where
  // these sections used to read `D` from.
  //
  // This is the one binding the move did not get for free, and it is worth
  // saying why: the import analysis that found the other twenty-six only knew
  // about IMPORTED names, and `D` is a local. Node found it in a second, as a
  // ReferenceError on the first run - which is the whole reason the split was
  // done by moving code and running it rather than by reasoning about scope.
  //
  // Loaded after the section gate, so a --section run that skips this module
  // does not pay for it.
  const deriveGlobal = {};
  new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8'))
    .call(deriveGlobal, deriveGlobal);
  const D = deriveGlobal.derive;

section('A Horror Factor the character PROJECTS (F75)');
{
  // BOOK-INGEST-AUDIT F75. `horror_factor` at the top level is the one a
  // character IMPOSES on others. The save of the same name is a
  // `bonuses.saves` key and means the opposite - a bonus to resist someone
  // ELSE's - and nothing connects them.
  const mk = (fm) => parseClassMarkdown(`---\nid: t\nname: T\nsystem: rifts\n`
    + `source_book: B\ncategory: occ\n${fm}\n---\n\n## Lore\n\nx\n`);

  check('a numeric horror factor parses clean',
    mk('horror_factor: 14').ok === true);

  // THE LIVE DATA IS OVERWHELMINGLY NOT A SCALAR, which is why this is a
  // string-or-number field and not an integer one. Every string below is the
  // shape of a real class in apps/character-creator/db/.
  for (const v of ['"10+1D4"', '"none if pretending to be human"',
                   '"8 on foot and 15 on a flying mount"',
                   '"10, but only when in sand form"', '"NONE"']) {
    check(`and the printed phrase ${v} parses clean`,
      mk(`horror_factor: ${v}`).ok === true);
  }

  // A WARNING AND NEVER AN ERROR: class-store.js DROPS a class that fails to
  // parse, so an error on a display-only field would make a class vanish from
  // every picker and from its own saved characters.
  check('a nonsense value warns rather than failing the class', (() => {
    const r = mk('horror_factor: []');
    return r.ok === true
      && (r.warnings || []).some((m) => m.includes('horror_factor'));
  })());

  // IT IS NOT THE SAVE. Two keys, two meanings, and setting one must not
  // touch the other.
  check('the projected factor and the save do not collide', (() => {
    const r = mk('horror_factor: 12\nbonuses:\n  saves: { horror_factor: 3 }');
    return r.ok === true && r.data.horror_factor === 12
      && r.data.bonuses.saves.horror_factor === 3;
  })());

  // ---- composition, which the finding never asks about ----
  const cls = (cat, fm) => parseClassMarkdown(`---\nid: t-${cat}\nname: T\n`
    + `system: rifts\nsource_book: B\ncategory: ${cat}\n${fm}\n---\n\n## Lore\n\nx\n`).data;

  check('an OCCUPATION that projects one is not dropped when the race states none',
    combineClasses(cls('rcc', 'name: R'), cls('occ', 'horror_factor: 9'))
      .horror_factor === 9);

  // A Horror Factor is a property of the BODY, so the race outranks the job.
  check('and when both state one, the RACE wins',
    combineClasses(cls('rcc', 'horror_factor: 14'), cls('occ', 'horror_factor: 9'))
      .horror_factor === 14);

  // THE SUPERSEDING CASE HAD A LIVE INSTANCE: cosmo-knight is the only carrier
  // of supersedes_race and its own prose already states a projected factor.
  check('but a superseding occupation replaces it',
    combineClasses(cls('rcc', 'horror_factor: 14'),
                   cls('occ', 'supersedes_race: true\nhorror_factor: 9'))
      .horror_factor === 9);

  // A VARIANT MAY SET IT. The finding argued this from the Nightbane's two
  // forms, which are `second_form` now (F74); the variant override stays for
  // "none normally, N if revealed".
  check('a variant may override it', (() => {
    const c = parseClassMarkdown('---\nid: t\nname: T\nsystem: rifts\nsource_book: B\n'
      + 'category: rcc\nhorror_factor: 6\nvariants:\n  - id: morphus\n'
      + '    name: "Morphus"\n    horror_factor: 18\n---\n\n## Lore\n\nx\n');
    return c.ok === true
      && applyVariant(c.data, 'morphus').horror_factor === 18;
  })());

  // THE SHEET DRAWS IT, and not as a pool: it has no current/max pair, no
  // stepper and no recovery rate, and POOLS is read by five other sites.
  const sheetSrcHf = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet renders the projected factor',
    /C\.cls\?\.horror_factor/.test(sheetSrcHf));
  check('and it is NOT a member of POOLS',
    !/POOLS\s*=\s*\[[^\]]*horror_factor/.test(sheetSrcHf));

  // class-check must know the key, or every class using it reports UNMODELLED
  // and test/checks/class-check-tool.mjs fails the suite.
  check('class-check knows the key',
    readFileSync(join(repoRoot, 'scripts', 'class-check-lib.mjs'), 'utf8')
      .includes("'horror_factor'"));
}

section('A second body: the Facade and the Morphus (BOOK-INGEST-AUDIT F74)');
{
  // Nightbane survey D5. A class states how its second form differs in a
  // `second_form` block; a character stores what it ROLLED for that form in
  // `characters.second_form`; js/second-form.js folds the two with the traits
  // catalog's rows into the numbers the sheet's form toggle draws.
  const FORM = [
    'second_form:',
    '  name: "Morphus"',
    '  first_name: "Facade"',
    '  bonuses:',
    '    attributes: { PS: 10, PE: 10, Spd: 10, PP: 6 }',
    '    pools: { sdc: "2d6x10" }',
    '    combat: { initiative: 1, strike: 2, parry: 2, dodge: 2, attacks: 1 }',
    '    saves: { psionics: 3, horror_factor: 3 }',
    '  hit_points_base: "P.E. x2 + 2d6 per level"',
    '  horror_factor: 6',
    '  horror_factor_max: 18',
    '  traits_from: morphus',
  ].join('\n');
  const mk = (fm, cat = 'rcc', id = 'sf') => parseClassMarkdown(`---\nid: ${id}\nname: SF ${cat}\nsystem: nightbane\n`
    + `source_book: B\ncategory: ${cat}\nhit_points_base: "P.E. + 1D6 per level"\nsdc_base: 30\n${fm}\n---\n\n## Lore\n\nx\n`);

  // ---- the parser ----
  const good = mk('bonuses:\n  attributes: { PS: 2 }\n' + FORM);
  check('a second_form block parses clean', good.ok === true && good.warnings.length === 0,
    JSON.stringify([good.errors, good.warnings]));
  check('and keeps its shape',
    good.data?.second_form?.name === 'Morphus' && good.data.second_form.bonuses.pools.sdc === '2d6x10'
    && good.data.second_form.horror_factor_max === 18);
  const refused = (fm, re) => {
    const r = mk(fm);
    return r.ok === false && r.errors.some((e) => re.test(e));
  };
  check('a form without its names is refused',
    refused('second_form:\n  horror_factor: 6', /second_form\.name is required/)
    && refused('second_form:\n  name: "M"', /second_form\.first_name is required/));
  check('its bonuses go through validateBonuses, re-rooted',
    refused('second_form:\n  name: M\n  first_name: F\n  bonuses:\n    attributes: { STR: 2 }',
      /^second_form\.bonuses\.attributes\.STR is not an attribute/));
  check('a pool other than S.D.C. and hit points is refused',
    refused('second_form:\n  name: M\n  first_name: F\n  bonuses:\n    pools: { ppe: 10 }',
      /pools\.ppe is not a second form's pool/));
  check('a level-gated form bonus is refused rather than ignored',
    refused('second_form:\n  name: M\n  first_name: F\n  bonuses:\n    at_level:\n      - { level: 3, combat: { strike: 1 } }',
      /at_level is not supported/));
  check('an unreadable hit point formula is refused',
    refused('second_form:\n  name: M\n  first_name: F\n  hit_points_base: "lots"', /not a formula/));
  check('a maximum below the base is refused',
    refused('second_form:\n  name: M\n  first_name: F\n  horror_factor: 10\n  horror_factor_max: 8', /below its base/));
  check('traits_from must name a traits catalog',
    refused('second_form:\n  name: M\n  first_name: F\n  traits_from: spells', /traits_from must name/));
  check('a variant cannot carry one, and says so',
    parseClassMarkdown('---\nid: v\nname: V\nsystem: nightbane\nsource_book: B\ncategory: rcc\n'
      + 'variants:\n  - id: a\n    name: A\n    second_form: { name: M }\n---\n\n## Lore\n\nx\n')
      .warnings.some((w) => /sets second_form, which a variant cannot override/.test(w)));
  check('class-check knows the key',
    readFileSync(join(repoRoot, 'scripts', 'class-check-lib.mjs'), 'utf8').includes("'second_form'"));

  // ---- composition ----
  const rcc = good.data;
  const occ = mk('', 'occ', 'job').data;
  const occForm = mk(FORM.replace('"Morphus"', '"Beast"'), 'occ', 'job').data;
  check('an O.C.C. stating none leaves the race\'s form standing',
    combineClasses(rcc, occ).second_form?.name === 'Morphus');
  check('and it survives composeClass, abilities and all',
    composeClass({ rcc, occ, character: {} })?.second_form?.name === 'Morphus');
  check('an O.C.C. that states one is not dropped when the race states none',
    combineClasses(mk('', 'rcc', 'race').data, occForm).second_form?.name === 'Beast');
  check('the race wins when both state one',
    combineClasses(rcc, occForm).second_form?.name === 'Morphus');
  check('and a superseding occupation replaces it',
    combineClasses(rcc, { ...occForm, supersedes_race: true }).second_form?.name === 'Beast');

  // ---- the fold, with every die pre-rolled ----
  const rows = new Map([
    ['Unearthly Beauty: Physical Perfection', { key: 'Unearthly Beauty: Physical Perfection',
      table_name: 'Unearthly Beauty', name: 'Physical Perfection', kind: 'effect',
      bonuses: '{"attributes": {"PB": "1d4", "PE": "1d4", "PS": "1d4"}, "pools": {"sdc": "4d6"}}',
      horror_factor: null, horror_factor_set: 6, sub_choices: null }],
    ['Stigmata: Test Stigma', { key: 'Stigmata: Test Stigma', table_name: 'Stigmata', name: 'Test Stigma',
      kind: 'effect', bonuses: { combat: { initiative: 1 }, pools: { sdc: '1d6x10' } },
      horror_factor: '1d4', horror_factor_set: null, sub_choices: '["left", "right"]' }],
    ['Appearance: Appearance Table', { key: 'Appearance: Appearance Table', table_name: 'Appearance',
      name: 'Appearance Table', kind: 'intro', bonuses: null }],
  ]);
  const state = {
    active: 'second',
    form_rolls: { pools: { sdc: 70 } },
    hp_rolls: [7, 9],
    results: [
      { key: 'Unearthly Beauty: Physical Perfection', sub_choice: null,
        rolls: { attributes: { PB: 2, PE: 3, PS: 1 }, pools: { sdc: 14 } } },
      { key: 'Stigmata: Test Stigma', sub_choice: 'left', rolls: { horror_factor: 3, pools: { sdc: 40 } } },
    ],
    sdc_current: 100, hp_current: null,
  };
  const character = { level: 2, attributes: { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 12, PB: 10, Spd: 10 },
    attribute_bonuses: {}, rolled_bonuses: {}, sdc_max: 30, hp_max: 20, second_form: state };
  const view = secondFormView({ cls: rcc, character, rows });
  // P.S. 10 + class 2 + form 10 + result 1; P.E. 12 + 10 + 3.
  check('attributes are the first form\'s, plus the form, plus its results',
    view.attributes.PS === 23 && view.attributes.PE === 25 && view.attributes.PP === 16
    && view.attributes.Spd === 20 && view.attributes.PB === 12, JSON.stringify(view.attributes));
  check('hit points read the formula against the SECOND form\'s P.E. (25 x 2 + 7 + 9)',
    view.hp_max === 66, `got ${view.hp_max}`);
  check('S.D.C. is the first form\'s maximum plus every rolled bonus (30 + 70 + 14 + 40)',
    view.sdc_max === 154, `got ${view.sdc_max}`);
  check('each form keeps its own current value, and an unset one is full',
    view.sdc_current === 100 && view.hp_current === 66);
  // Physical Perfection SETS 6, the stigma adds its rolled 3.
  check('a set replaces the base and what results add still lands on top',
    view.horror_factor === 9 && view.horror_factor_parts.set === 6, JSON.stringify(view.horror_factor_parts));
  const withSet = (set) => secondFormView({ cls: rcc, rows: new Map([...rows,
    ['Unearthly Beauty: Physical Perfection', { ...rows.get('Unearthly Beauty: Physical Perfection'), horror_factor_set: set }]]),
    character });
  check('a higher set raises it (10 + 3)', withSet(10).horror_factor === 13);
  check('and the form\'s maximum caps it (17 + 3 is 18, not 20)', withSet(17).horror_factor === 18);
  check('with no set, the form\'s base is where it starts (6 + 3)', withSet(null).horror_factor === 9
    && withSet(null).horror_factor_parts.set === null);
  check('the results\' and the form\'s combat bonuses fold, and nothing is unrolled',
    view.form_bonuses.combat.initiative === 2 && view.form_bonuses.combat.strike === 2
    && view.form_bonuses.saves.horror_factor === 3 && view.unrolled.length === 0, JSON.stringify(view));
  check('an unrolled die counts nothing and is reported',
    secondFormView({ cls: rcc, rows, character: { ...character, second_form: { ...state, form_rolls: {} } } })
      .sdc_max === 84 && secondFormView({ cls: rcc, rows, character: { ...character, second_form: { ...state, form_rolls: {} } } })
      .unrolled.some((u) => /pools\.sdc/.test(u)));
  check('a class with no second form folds to null', secondFormView({ cls: occ, character }) === null);

  // derive: the second form's combat is the first form's shown number plus the
  // difference the form makes - so a typed override survives the toggle.
  const firstB = D.classBonuses(rcc, 2, {});
  const combat2 = D.inForm('combat', character.attributes, { strike: '5' }, firstB, view.form_bonuses);
  // P.P. 10 -> 16 is +1 strike on the chart; +2 from the form.
  check('the form adds its difference to a typed override (5 + 1 + 2)', combat2.strike === 8, JSON.stringify(combat2));
  check('and to a derived value (initiative 0 + 2)', combat2.initiative === 2);
  check('run speed reads the second form\'s Spd (20 x 5)', combat2.run_yards_per_melee === 100);
  check('sumBonuses adds two blocks', D.sumBonuses({ combat: { strike: 1 } }, { combat: { strike: 2 } }).combat.strike === 3);

  // ---- the create boundary ----
  const vio = (s, cls = rcc, ch = character) => secondFormViolations({ cls, character: ch, state: s, rows });
  check('the stored form passes', vio(state).length === 0, JSON.stringify(vio(state)));
  check('an empty form passes on any class', vio({}, occ).length === 0 && vio({}).length === 0);
  const rule = (s, r, cls, ch) => vio(s, cls, ch).some((v) => v.rule === r);
  check('a class with no second form cannot carry one', rule(state, 'second_form_not_allowed', occ));
  check('a result naming no catalog entry is refused',
    rule({ ...state, results: [{ key: 'Stigmata: Nothing', rolls: {} }] }, 'second_form_result_unknown'));
  check('and so is a table\'s intro row',
    rule({ ...state, results: [{ key: 'Appearance: Appearance Table', rolls: {} }] }, 'second_form_result_unknown'));
  check('a roll outside its dice is refused (P.E. 5 on 1d4)',
    rule({ ...state, results: [{ ...state.results[0], rolls: { attributes: { PB: 2, PE: 5, PS: 1 }, pools: { sdc: 14 } } }, state.results[1]] },
      'second_form_roll_out_of_range'));
  check('a missing roll is refused',
    rule({ ...state, results: [{ ...state.results[1], rolls: { pools: { sdc: 40 } } }] }, 'second_form_roll_missing'));
  check('a roll with no dice behind it is refused',
    rule({ ...state, form_rolls: { pools: { sdc: 70 }, combat: { strike: 3 } } }, 'second_form_roll_unexpected'));
  check('the form\'s own roll is held to its dice (2d6x10 cannot roll 130)',
    rule({ ...state, form_rolls: { pools: { sdc: 130 } } }, 'second_form_roll_out_of_range'));
  check('a level-2 form holds exactly two hit point rolls',
    rule({ ...state, hp_rolls: [7] }, 'second_form_hp_rolls')
    && rule({ ...state, hp_rolls: [7, 13] }, 'second_form_roll_out_of_range'));
  check('a sub-choice the entry does not offer is refused',
    rule({ ...state, results: [state.results[0], { ...state.results[1], sub_choice: 'middle' }] }, 'second_form_sub_choice'));
  check('a current value above the form\'s maximum is refused',
    rule({ ...state, sdc_current: 155 }, 'second_form_current_above_max')
    && !rule({ ...state, sdc_current: 154 }, 'second_form_current_above_max'));
  check('an unknown key or form name is refused',
    rule({ ...state, total_sdc: 9 }, 'second_form_shape') && rule({ ...state, active: 'morphus' }, 'second_form_shape'));
  check('the server validator carries it',
    validateCharacter({ character: { level: 2, ...character }, cls: occ, skills: [], attributes: character.attributes,
      secondForm: state, traitRows: rows }).violations.some((v) => v.rule === 'second_form_not_allowed'));

  // ---- rolling, and leveling ----
  const made = rollSecondForm(rcc.second_form, 3);
  check('a new form rolls its own dice and one hit point roll per level, and validates',
    made.hp_rolls.length === 3 && made.form_rolls.pools.sdc % 10 === 0 && made.active === 'first'
    && vio(made, rcc, { ...character, level: 3, second_form: made }).length === 0, JSON.stringify(made));
  const rolled = rollTraitResult(rows.get('Stigmata: Test Stigma'), 'right');
  check('a result rolls every die it carries',
    rolled.rolls.horror_factor >= 1 && rolled.rolls.horror_factor <= 4 && rolled.rolls.pools.sdc >= 10
    && rolled.sub_choice === 'right');
  const hpd = secondFormHitPointDice('P.E. x2 + 2d6 per level');
  check('the hit point dice are read off the formula',
    hpd.first === '2d6' && hpd.per === '2d6' && hpd.count(4) === 4
    && secondFormHitPointDice('P.E. x 10').count(4) === 0 && secondFormHitPointDice('3d6x10').count(4) === 1);
  check('a flat formula grows by nothing', rollSecondFormHitPoints('3d6x10', 1, 3).length === 0);
  const prop = buildProposal({ ...character, skills: [] }, rcc, 4);
  check('the level-up proposal rolls the second form\'s hit points for each level gained',
    prop.second_form?.hp_rolls?.length === 2 && prop.second_form.hp_rolls.every((v) => v >= 2 && v <= 12)
    && prop.second_form.name === 'Morphus', JSON.stringify(prop.second_form));
  check('and proposes none for a character whose form was never made',
    buildProposal({ ...character, skills: [], second_form: {} }, rcc, 4).second_form === undefined);

  // ---- storage, the routes and the sheet, read as source ----
  const charJsonSf = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', '_lib', 'character-json.js'), 'utf8');
  check('second_form is a decoded JSON column whose empty value is an object',
    CHARACTER_JSON_COLUMNS.includes('second_form')
    && !/ARRAY_COLUMNS\s*=\s*new Set\(\[[^\]]*'second_form'/.test(charJsonSf));
  const sfRoute = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters', '[id].js'), 'utf8');
  check('the sheet endpoint folds the form for the sheet',
    /const second_form = cls\?\.second_form\s*\?\s*secondFormView\(/.test(sfRoute) && /\n\s*second_form,\n/.test(sfRoute.replace(/\r/g, '')));
  check('the PATCH writes a form field by field and clamps to the folded maximum',
    /second_form = json_set\(/.test(sfRoute) && /Math\.min\(v, max\)/.test(sfRoute));
  const sfCreate = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters.js'), 'utf8');
  check('the create endpoint validates and stores it',
    /secondForm, traitRows,/.test(sfCreate) && /JSON\.stringify\(secondForm\)/.test(sfCreate));
  const sfConfirm = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters', '[id]', 'level-confirm.js'), 'utf8');
  check('level-confirm appends the form\'s hit point rolls, checked against their dice',
    /hp_rolls: \[\.\.\.formState\.hp_rolls, \.\.\.rolls\]/.test(sfConfirm) && /v < bounds\.min \|\| v > bounds\.max/.test(sfConfirm));
  const sfSheet = readFileSync(appPath('sheet.js'), 'utf8');
  check('the sheet draws a toggle only for a class with a second form',
    /const formToggle = !F \? '' :/.test(sfSheet) && /onclick="setForm\('\$\{k\}'\)"/.test(sfSheet));
  check('and paints pools from the form showing',
    /const paintPool = \(key\) => sheetLayout\.paintPool\(key, poolData\(\), C\.conflicts\);/.test(sfSheet));
  check('autosave does not own a second-form pool, so one body\'s damage cannot land on the other',
    /if \(m && formOn\(\) && FORM_POOLS\.includes\(m\[1\]\)\) return null;/.test(sfSheet));
  check('the stepper, Damage and rest read the active form and route each pool back where it came from',
    /const cur = poolData\(\)\[key \+ '_current'\];\s*\n?\s*if \(cur == null\) return;\s*\n?\s*const changes = derive\.playChanges\(C\.data, C\.secondForm,/.test(sfSheet.replace(/\r/g, ''))
    && /const patch = derive\.damageCascade\(poolData\(\), amt\);\s*\n\s*const changes = derive\.playChanges\(C\.data, C\.secondForm, patch\);/.test(sfSheet.replace(/\r/g, ''))
    && /const changes = derive\.playChanges\(C\.data, C\.secondForm, patch\);\s*\n\s*\/\/ A rest recovers/.test(sfSheet.replace(/\r/g, '')));
  check('level-up sends the form\'s rolls to be confirmed', /second_form_hp_rolls: p\.second_form\.hp_rolls/.test(sfSheet));
}

section('Damage, healing and rest on the active form (Nightbane follow-up 5)');
{
  // Nate, 2026-09-17: damage, healing and rest apply to whichever form is
  // active, and a Morphus pool goes below zero into hit points like the
  // Facade's. The sheet and the G.M. dashboard both route through these three
  // pure functions in js/derive.js, so they are driven here for BOTH forms.
  const facade = () => ({ hp_current: 20, hp_max: 20, sdc_current: 30, sdc_max: 30, ppe_current: 10, ppe_max: 20 });
  const morphus = (active = 'second') => ({ name: 'Morphus', first_name: 'Facade', active,
    hp_current: 65, hp_max: 65, sdc_current: 124, sdc_max: 124 });
  // One press through the helpers, exactly as the sheet makes it.
  const hit = (data, form, amt) => {
    const changes = D.playChanges(data, form, D.damageCascade(D.activePools(data, form), amt));
    D.applyPlayChanges(data, form, changes);
    return changes;
  };

  // ---- a one-body character is unchanged ----
  {
    const c = facade();
    check('with no second form the pools are the character itself', D.activePools(c, null) === c
      && D.activePools(c, undefined) === c);
    const ch = hit(c, null, 40);
    check('a one-body hit runs S.D.C. down then hit points, below zero, all under character',
      c.sdc_current === 0 && c.hp_current === 10 && !ch.second_form
      && ch.character.sdc_current.from === 30 && ch.character.sdc_current.to === 0
      && ch.character.hp_current.from === 20 && ch.character.hp_current.to === 10, JSON.stringify(ch));
    hit(c, null, 25);
    check('and it keeps going below zero, as it always did', c.hp_current === -15 && c.sdc_current === 0);
    check('the change is the same one the old sheet sent: from/to per field, nothing else',
      JSON.stringify(D.playChanges(facade(), null, { hp_current: 12 })) === JSON.stringify({ character: { hp_current: { from: 20, to: 12 } } }));
  }

  // ---- the first form active: the second form is not touched ----
  {
    const c = facade(), f = morphus('first');
    check('with the first form active the pools are the character itself', D.activePools(c, f) === c);
    const ch = hit(c, f, 35);
    check('a hit in the Facade lands on the Facade and leaves the Morphus whole',
      c.sdc_current === 0 && c.hp_current === 15 && f.sdc_current === 124 && f.hp_current === 65 && !ch.second_form,
      JSON.stringify({ c, f, ch }));
  }

  // ---- the second form active ----
  {
    const c = facade(), f = morphus();
    const view = D.activePools(c, f);
    check('with the second form active its S.D.C. and hit points stand in, and the shared pools stay',
      view.sdc_current === 124 && view.hp_max === 65 && view.ppe_current === 10 && view !== c);
    let ch = hit(c, f, 130);
    check('a Morphus hit runs ITS S.D.C. down first and the rest reaches ITS hit points',
      f.sdc_current === 0 && f.hp_current === 59 && ch.second_form.sdc_current.from === 124
      && ch.second_form.hp_current.to === 59 && !ch.character, JSON.stringify(ch));
    check('and the Facade\'s pools are untouched', c.sdc_current === 30 && c.hp_current === 20);
    ch = hit(c, f, 70);
    check('a Morphus pool goes below zero into hit points like the Facade\'s', f.hp_current === -11 && f.sdc_current === 0
      && ch.second_form.hp_current.from === 59 && ch.second_form.hp_current.to === -11, JSON.stringify(f));
    // Healing back: a stepper press, and a rest capped at the form's own maximum.
    const heal = D.playChanges(c, f, { hp_current: D.activePools(c, f).hp_current + 5 });
    D.applyPlayChanges(c, f, heal);
    check('a stepper heal on the Morphus lands on the Morphus', f.hp_current === -6 && c.hp_current === 20
      && heal.second_form.hp_current.from === -11);
    const gain = D.restGain(f.hp_current, f.hp_max, 10, 8);
    check('rest climbs back through zero and stops at the form\'s own maximum (-6 + 71 = 65, not 80)', gain === 71,
      `gain ${gain}`);
    const rest = D.playChanges(c, f, { hp_current: f.hp_current + gain, ppe_current: 10 + D.restGain(10, 20, 1, 8) });
    D.applyPlayChanges(c, f, rest);
    check('one rest moves the Morphus\'s hit points and the shared P.P.E., each where it lives',
      f.hp_current === 65 && c.ppe_current === 18 && c.hp_current === 20
      && rest.second_form.hp_current.to === 65 && rest.character.ppe_current.to === 18, JSON.stringify(rest));
    check('rest past full recovers nothing', D.restGain(65, 65, 10, 8) === 0 && D.restGain(20, 20, 5, 1) === 0);
    // Rolled back: `from` goes back into the copy the change names.
    D.applyPlayChanges(c, f, rest, 'from');
    check('a rollback restores each body from its own group', f.hp_current === -6 && c.ppe_current === 10);
    // The undo route's `restored` carries bare values.
    D.applyPlayChanges(c, f, { character: {}, second_form: { sdc_current: 40 } }, null);
    check('an undo\'s restored values land on the form', f.sdc_current === 40 && c.sdc_current === 30);
    // Changing form moves nothing.
    f.active = 'first';
    check('switching back to the Facade moves no damage between the forms',
      D.activePools(c, f).hp_current === 20 && f.hp_current === -6 && f.sdc_current === 40);
    hit(c, f, 5);
    check('and a hit in the Facade now lands there', c.sdc_current === 25 && f.sdc_current === 40);
  }

  // ---- M.D.C. is one pool both forms share ----
  {
    const c = { ...facade(), mdc_current: 50, mdc_max: 50 }, f = morphus();
    const ch = hit(c, f, 10);
    check('an M.D.C. being in its second form takes it on the shared M.D.C.',
      c.mdc_current === 40 && f.sdc_current === 124 && ch.character.mdc_current.to === 40 && !ch.second_form);
  }

  // ---- the routes, read as source ----
  const evSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters', '[id]', 'events.js'), 'utf8');
  check('the events route takes a second form\'s pools and writes them field by field',
    /const FORM_POOL_FIELDS = new Set\(\['sdc_current', 'hp_current'\]\);/.test(evSrc)
    && /second_form = json_set\(/.test(evSrc) && !/Math\.max\(0,/.test(evSrc));
  check('guards them on the stored value, and names the form in the note',
    /json_extract\(second_form, '\$\.\$\{field\}'\) IS \?/.test(evSrc) && /note = `\$\{note \|\| b\.kind\} \(\$\{form\}\)`/.test(evSrc));
  const undoSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters', '[id]', 'events', 'undo.js'), 'utf8');
  check('undo restores them', /restored\.second_form\[field\] = fv\.from;/.test(undoSrc));
  const listSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters.js'), 'utf8');
  check('a campaign roster carries each character\'s active form',
    /if \(campaignId && page\.results\.length\)/.test(listSrc) && /target\.second_form = \{ name: v\.name/.test(listSrc));
  const dashSrc = readFileSync(appPath('dashboard.js'), 'utf8');
  check('the G.M. dashboard damages, steps and undoes the active form through the same helpers',
    /const patch = derive\.damageCascade\(pools\(c\), D\.amt\);/.test(dashSrc)
    && /derive\.playChanges\(c, c\.second_form, \{ \[key \+ '_current'\]/.test(dashSrc)
    && /second_form: res\.restored\?\.second_form/.test(dashSrc));
}

section('The Morphus generator (survey D5, PR 3 of 4)');
{
  // js/morphus.js drives the "Creating the Nightbane" tables (printed 91-106)
  // over the REAL catalog rows: schema.sql and the Morphus data script, built in
  // memory, so a catalog edit that breaks a rule fails here. Every die is
  // injected - the d100s and 1D6s through `rng`, a result's own dice through
  // `rollResult` - so each check states exactly what was rolled.
  const mem = new DatabaseSync(':memory:');
  mem.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'));
  mem.exec(readFileSync(join(appDir, 'db', 'zzzzzzzzzzzzz-nb-morphus-characteristics.sql'), 'utf8'));
  const rawRows = mem.prepare('SELECT * FROM morphus_characteristics').all();
  mem.close();
  const T = morphusTables(rawRows);
  const rowMap = new Map(rawRows.map((r) => [r.key, r]));
  check('the fixture is the real catalog: 173 rows, 154 entries, 19 tables',
    rawRows.length === 173 && T.byKey.size === 154 && T.intro.size === 19 && T.entries.size === 19,
    JSON.stringify({ rows: rawRows.length, entries: T.byKey.size, tables: T.entries.size }));
  const drift = rulesDisagreeWithRows(T);
  check('every encoded rule names a real entry, band, sub-choice and page', drift.length === 0, drift.join('; '));
  check('and a rule that no longer matches its row is reported',
    rulesDisagreeWithRows(morphusTables(rawRows.map((r) => (r.key === 'Stigmata: Biomechanical'
      ? { ...r, horror_factor: null } : r)))).some((m) => /Stigmata: Biomechanical/.test(m)));

  // Dice, injected. A d100 or 1D6 sequence, and a result's own dice at their
  // maximum, so a fold is exact.
  const seq = (sides, ...vals) => {
    const q = [...vals];
    return () => {
      if (!q.length) throw new Error('the injected dice ran out');
      return (q.shift() - 1 + 0.5) / sides;
    };
  };
  const seeded = (seed) => () => { seed = (seed * 16807) % 2147483647; return (seed - 1) / 2147483646; };
  const atMax = (row) => {
    const real = Math.random;
    Math.random = () => 0.999999;
    try { return rollTraitResult(row); } finally { Math.random = real; }
  };
  const opts = { rollResult: atMax };
  const pick = (dec, ...keys) => keys.reduce((d, k) => pickNext(T, d, k, opts), dec);
  const at = (dec) => replayMorphus(T, dec);
  const throws = (fn) => { try { fn(); return false; } catch { return true; } };
  const offeredKeys = (dec) => entriesFor(T, at(dec).steps, at(dec).next).offered.map((r) => r.key);
  const rolled = (dec, ...d100) => rollOn(T, at(dec), at(dec).next, seq(100, ...d100));

  // ---- the procedure ----
  check('every Morphus starts at the Appearance Table',
    MORPHUS_START === 'Appearance' && at([]).next?.table === 'Appearance' && !at([]).done);
  let dec = pick([], 'Appearance: Monstrous Lycanthrope');
  check('an entry\'s routes are queued in the order it prints them',
    JSON.stringify(at(dec).queue.map((q) => q.table)) === JSON.stringify(['Animal Form', 'Stigmata', 'Nightbane Characteristics']),
    JSON.stringify(at(dec).queue.map((q) => q.table)));
  dec = pick(dec, 'Animal Form: Canine');
  check('and followed depth first: the animal\'s own table comes before Stigmata',
    JSON.stringify(at(dec).queue.map((q) => q.table)) === JSON.stringify(['Canine', 'Stigmata', 'Nightbane Characteristics']));
  check('undoing a step puts its table back at the front',
    at(undoLast(dec)).next?.table === 'Animal Form' && undoLast(dec).length === 1);

  dec = pick([], 'Appearance: Inhuman Shape', 'Stigmata: Combination of Two');
  check('a combination rolls its own table again, as many times as it says',
    JSON.stringify(at(dec).queue.map((q) => `${q.table}#${q.slot}`)) === JSON.stringify(['Stigmata#0', 'Stigmata#1', 'Nightbane Characteristics#0']));
  const four = pick([], 'Appearance: Inhuman Shape', 'Stigmata: Bones', 'Nightbane Characteristics: Four Characteristics');
  check('and "Four Characteristics" queues four Characteristics rolls',
    at(four).queue.filter((q) => q.table === 'Nightbane Characteristics').length === 4);

  // ---- each encoded rule ----
  const human = pick([], 'Appearance: Almost human');
  check('Almost human (printed 92): no Characteristics result asking for more than one is offered',
    offeredKeys(human).length === 4 && !offeredKeys(human).some((k) => /characteristics$/i.test(k)), offeredKeys(human).join(', '));
  const humanRoll = rolled(human, 85, 93, 30);
  check('and one rolled is ignored and rerolled (85, 93, then 30)',
    humanRoll?.key === 'Nightbane Characteristics: Biomechanical'
    && JSON.stringify(humanRoll.rerolls.map((r) => r.roll)) === '[85,93]', JSON.stringify(humanRoll));
  check('and cannot be picked', throws(() => pickNext(T, human, 'Nightbane Characteristics: Two characteristics', opts)));
  check('while Inhuman Shape\'s Characteristics roll offers all seven',
    offeredKeys(pick([], 'Appearance: Inhuman Shape', 'Stigmata: Bones')).length === 7);

  const two = pick([], 'Appearance: Inhuman Shape', 'Stigmata: Bones', 'Nightbane Characteristics: Two characteristics');
  // Printed 92 says "ignore 61% or higher"; Nate (2026-09-17) reads it as 81%,
  // so Unnatural Limbs stays reachable and only the multi-characteristic rows go.
  check('several characteristics (printed 92) ignore 81% or higher: Unnatural Limbs IS offered',
    JSON.stringify(offeredKeys(two)) === JSON.stringify(['Nightbane Characteristics: Unusual Facial Features',
      'Nightbane Characteristics: Biomechanical', 'Nightbane Characteristics: Alien Creature',
      'Nightbane Characteristics: Unnatural Limbs']), offeredKeys(two).join(', '));
  const twoRoll = rolled(two, 85, 99, 70);
  check('and an 85 and a 99 are rerolled, landing on a 70 (Unnatural Limbs)',
    twoRoll?.key === 'Nightbane Characteristics: Unnatural Limbs' && twoRoll.rerolls.length === 2, JSON.stringify(twoRoll));

  // Each combination rerolls its own combination bands.
  const combos = [
    { what: 'Stigmata (97+, printed 102)', path: ['Appearance: Inhuman Shape', 'Stigmata: Combination of Two'], dice: [98, 97, 5], key: 'Stigmata: Bloody Ooze' },
    { what: 'Unearthly Beauty (91+, printed 93)', path: ['Appearance: Inhuman but beautiful', 'Unearthly Beauty: Combination of Two'], dice: [96, 91, 1], key: 'Unearthly Beauty: Doll-Like Appearance' },
    { what: 'Animal Form (96+, printed 93)', path: ['Appearance: Lycanthrope', 'Animal Form: Combination of Two'], dice: [97, 99, 75], key: 'Animal Form: Canine' },
    { what: 'Unusual Facial Features (96+, printed 103)', path: ['Appearance: Almost human', 'Nightbane Characteristics: Unusual Facial Features', 'Unusual Facial Features: Two'], dice: [96, 100, 20], key: 'Unusual Facial Features: Cyclops' },
    { what: 'Alien Shape (96+, printed 104)', path: ['Appearance: Almost human', 'Nightbane Characteristics: Alien Creature', 'Alien Shape: Combination of Two'], dice: [96, 50], key: 'Alien Shape: Crystalline' },
  ];
  for (const c of combos) {
    const d = pick([], ...c.path);
    const r = rolled(d, ...c.dice);
    check(`a combination on ${c.what} rerolls its own combination bands`,
      r?.key === c.key && r.rerolls.length === c.dice.length - 1 && !offeredKeys(d).some((k) => /Combination|: Other$|: Two$|: Three$/.test(k)),
      JSON.stringify(r));
  }

  const beast = pick([], 'Appearance: Lycanthrope');
  check('a route to a table the book never prints (printed 93) is not offered when picking',
    !offeredKeys(beast).includes('Animal Form: Bear') && !offeredKeys(beast).includes('Animal Form: Amphibian')
    && offeredKeys(beast).length === 12 && !T.entries.has('Bear') && !T.entries.has('Amphibian'));
  const beastRoll = rolled(beast, 3, 10, 50);
  check('and is rerolled when the dice land on it (03 Bear, 10 Amphibian, then 50)',
    beastRoll?.key === 'Animal Form: Feline' && beastRoll.rerolls.every((r) => r.why === UNPRINTED_TABLE.says), JSON.stringify(beastRoll));
  check('and a pick of it is refused', throws(() => pickNext(T, beast, 'Animal Form: Bear', opts)));

  // Stigmata's Biomechanical route: +1 on top of the biomechanical result.
  const FORM_CLASS = parseClassMarkdown('---\nid: gen\nname: Gen\nsystem: nightbane\nsource_book: B\ncategory: rcc\n'
    + 'hit_points_base: "P.E. + 1D6 per level"\nsdc_base: 30\nsecond_form:\n  name: "Morphus"\n  first_name: "Facade"\n'
    + '  bonuses:\n    attributes: { PS: 10, PE: 10, Spd: 10, PP: 6 }\n    pools: { sdc: "2d6x10" }\n'
    + '  hit_points_base: "P.E. x2 + 2d6 per level"\n  horror_factor: 6\n  horror_factor_max: 18\n  traits_from: morphus\n'
    + '---\n\n## Lore\n\nx\n').data;
  const person = { level: 1, attributes: { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 10, PB: 10, Spd: 10 },
    attribute_bonuses: {}, rolled_bonuses: {}, sdc_max: 30, hp_max: 14 };
  const formState = (results) => ({ active: 'first', form_rolls: { pools: { sdc: 70 } }, hp_rolls: [7], results,
    sdc_current: null, hp_current: null });
  const fold = (results) => secondFormView({ cls: FORM_CLASS, rows: rowMap,
    character: { ...person, second_form: formState(results) } });
  const wound = pick([], 'Appearance: Inhuman Shape', 'Stigmata: Biomechanical', 'Biomechanical: Armorgraft',
    'Nightbane Characteristics: Alien Creature', 'Alien Shape: Thorns');
  const woundResults = morphusResults(T, wound);
  check('the Stigmata Biomechanical route is stored as a result, path and all',
    at(wound).done && woundResults.map((r) => r.key).join('|')
      === 'Appearance: Inhuman Shape|Stigmata: Biomechanical|Biomechanical: Armorgraft|Nightbane Characteristics: Alien Creature|Alien Shape: Thorns');
  check('and is worth exactly +1 Horror Factor on top of the biomechanical result (printed 102)',
    fold(woundResults).horror_factor - fold(woundResults.filter((r) => r.key !== 'Stigmata: Biomechanical')).horror_factor === 1
    && MORPHUS_RULES['Stigmata: Biomechanical'].horrorFactor === 1,
    JSON.stringify([fold(woundResults).horror_factor_parts]));
  check('and the whole path validates against #1139\'s create rules',
    secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(woundResults), rows: rowMap }).length === 0,
    JSON.stringify(secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(woundResults), rows: rowMap })));

  const stitched = pick([], 'Appearance: Inhuman Shape', 'Stigmata: Combination of Two', 'Stigmata: Stitches');
  check('the same effect entry twice is not offered (the app\'s reading of printed 91-92)',
    !offeredKeys(stitched).includes('Stigmata: Stitches')
    && entriesFor(T, at(stitched).steps, at(stitched).next).excluded.some((e) => e.rule === 'duplicate-entry'));
  check('and a roll landing on it is rerolled', rolled(stitched, 12, 33)?.key === 'Stigmata: Broken Glass'
    && rolled(stitched, 12, 33).rerolls[0].why === DUPLICATE_ENTRY.says);
  check('but a ROUTE may come up twice ("roll twice on that table", printed 92)',
    offeredKeys(pick(two, 'Nightbane Characteristics: Biomechanical', 'Biomechanical: Armorgraft'))
      .includes('Nightbane Characteristics: Biomechanical'));

  // ---- sub-choices, including the two that decide what comes next ----
  const other = pick([], 'Appearance: Inhuman but beautiful', 'Unearthly Beauty: Other');
  check('a result with sub-choices waits for one before anything else is decided',
    at(other).awaiting === 1 && at(other).next === null && throws(() => pickNext(T, other, 'Unearthly Beauty: Elfin Features', opts)));
  const invented = chooseSub(T, other, 1, 'GM/player-invented form of beauty');
  check('Unearthly Beauty "Other" invented with the G.M. (printed 93) rolls nothing more',
    at(invented).next?.table === 'Nightbane Characteristics' && at(invented).queue.length === 1);
  const thrice = chooseSub(T, other, 1, 'roll three times and combine, as per 91-95%');
  check('while "roll three times" queues three Unearthly Beauty rolls that ignore 91% or higher',
    at(thrice).queue.filter((q) => q.table === 'Unearthly Beauty').length === 3 && offeredKeys(thrice).length === 5);
  check('a sub-choice the entry does not offer is refused', throws(() => chooseSub(T, other, 1, 'something else')));
  check('and one that steers the rolls cannot change once something follows it',
    throws(() => chooseSub(T, pick(thrice, 'Unearthly Beauty: Elfin Features'), 1, 'GM/player-invented form of beauty')));

  const skull = pick([], 'Appearance: Almost human', 'Nightbane Characteristics: Unusual Facial Features', 'Unusual Facial Features: Skull Face');
  const oddSkull = chooseSub(T, skull, 2, T.byKey.get('Unusual Facial Features: Skull Face').sub_choices[3]);
  check('Skull Face 91-00% (printed 103) offers an OPTIONAL extra Facial Features roll',
    at(oddSkull).next?.table === 'Unusual Facial Features' && at(oddSkull).next.optional === true && !at(oddSkull).done);
  check('which can be skipped, finishing the Morphus', at(skipNext(T, oddSkull, opts)).done
    && morphusResults(T, skipNext(T, oddSkull, opts)).length === 3);
  check('and a required table cannot be skipped', throws(() => skipNext(T, human, opts)));
  check('the other skull looks finish without one',
    at(chooseSub(T, skull, 2, T.byKey.get('Unusual Facial Features: Skull Face').sub_choices[0])).done);
  const skullResults = morphusResults(T, chooseSub(T, skull, 2, T.byKey.get('Unusual Facial Features: Skull Face').sub_choices[1]));
  check('and the sub-choice travels with the result', skullResults[2].sub_choice === T.byKey.get('Unusual Facial Features: Skull Face').sub_choices[1]
    && Number.isInteger(skullResults[2].rolls.horror_factor) && Number.isInteger(skullResults[2].rolls.pools?.sdc));

  // ---- Animal Form combinations: 1D6 per bonus, never summed (printed 93-94) ----
  check('1D6 names the animal: of two 1-3 / 4-6, of three 1-2 / 3-4 / 5-6',
    [1, 2, 3].every((v) => animalForDie(v, 2) === 0) && [4, 5, 6].every((v) => animalForDie(v, 2) === 1)
    && animalForDie(2, 3) === 0 && animalForDie(3, 3) === 1 && animalForDie(4, 3) === 1 && animalForDie(5, 3) === 2);
  const pair = pick([], 'Appearance: Lycanthrope', 'Animal Form: Combination of Two', 'Animal Form: Canine', 'Canine: Full Canine',
    'Animal Form: Equine/Bovine/Deer');
  check('the 1D6s wait until every animal is resolved', animalCombinations(T, pair)[0]?.bonuses === null);
  // Paths sorted: attributes.PE, .PP, .PS, .Spd, combat.initiative, .perception, pools.sdc.
  const horsePick = (d6s) => decide(T, pair, { key: 'Equine/Bovine/Deer: Full Horse/Bovine/Deer Form', how: 'pick' },
    { ...opts, rng: seq(6, ...d6s) });
  const mixed = horsePick([4, 1, 6, 2, 5, 3, 1]);
  const combo = animalCombinations(T, mixed)[0];
  check('then one 1D6 is rolled for each bonus either animal prints, and kept on the decision that finished it',
    combo?.bonuses?.length === 7 && JSON.stringify(combo.bonuses.map((b) => b.path)) === JSON.stringify(
      ['attributes.PE', 'attributes.PP', 'attributes.PS', 'attributes.Spd', 'combat.initiative', 'combat.perception', 'pools.sdc'])
    && !!mixed[mixed.length - 1].combine?.['1'], JSON.stringify(combo?.bonuses));
  const mixedResults = morphusResults(T, mixed);
  const canine = mixedResults.find((r) => r.key === 'Canine: Full Canine');
  const horse = mixedResults.find((r) => r.key === 'Equine/Bovine/Deer: Full Horse/Bovine/Deer Form');
  check('and the animal the die did not name has that bonus in `omit`',
    JSON.stringify(canine?.omit) === JSON.stringify(['attributes.PE', 'attributes.PS', 'combat.initiative'])
    && JSON.stringify(horse?.omit) === JSON.stringify(['attributes.PP', 'attributes.Spd', 'combat.perception', 'pools.sdc']),
    JSON.stringify({ canine: canine?.omit, horse: horse?.omit }));
  // P.S.: die 6 -> the horse's 12, not 5 + 12. P.P.: die 1 -> the canine's 1, not 1 + 3.
  const mixedView = fold(mixedResults);
  check('so the sheet\'s P.S. is ONE animal\'s bonus (10 + 10 + 12), not the two summed',
    mixedView.attributes.PS === 32 && mixedView.attributes.PP === 17 && mixedView.attributes.PE === 26,
    JSON.stringify(mixedView.attributes));
  const allCanine = morphusResults(T, horsePick([1, 1, 1, 1, 1, 1, 1]));
  const allHorse = morphusResults(T, horsePick([6, 6, 6, 6, 6, 6, 6]));
  check('all ones is the canine\'s bonuses alone, all sixes the horse\'s',
    fold(allCanine).attributes.PS === 25 && fold(allHorse).attributes.PS === 32
    && !allCanine.find((r) => r.key === 'Canine: Full Canine').omit
    && fold(allCanine).sdc_max === 30 + 70 + 120 && fold(allHorse).sdc_max === 30 + 70 + 180,
    JSON.stringify([fold(allCanine).sdc_max, fold(allHorse).sdc_max]));
  check('the Horror Factors still add, as every other combination\'s do',
    fold(allCanine).horror_factor === 6 + 2 + 4 && fold(allHorse).horror_factor === 12);
  check('undoing the last animal undoes its 1D6s', !undoLast(mixed).some((d) => d.combine));
  check('and #1139\'s create rules accept `omit`',
    secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(mixedResults), rows: rowMap })
      .filter((v) => v.rule !== 'second_form_hp_rolls').length === 0,
    JSON.stringify(secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(mixedResults), rows: rowMap })));
  const badOmit = mixedResults.map((r) => (r.key === 'Canine: Full Canine' ? { ...r, omit: ['attributes.MA'] } : r));
  check('but refuse an `omit` naming a bonus the entry does not print',
    secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(badOmit), rows: rowMap })
      .some((v) => v.rule === 'second_form_omit'));
  check('bonusPaths reads a row the way the fold does',
    JSON.stringify(bonusPaths(rowMap.get('Canine: Canine Head').bonuses)) === '["combat.initiative","combat.perception"]');

  // ---- all rolled, all picked, mixed; determinism ----
  const generate = (rng, answer = 0) => {
    let d = [];
    for (let n = 0; n < 100; n++) {
      d = rollUntilBlocked(T, d, { rng, rollResult: atMax });
      const s = at(d);
      if (s.done || s.problems.length) break;
      if (s.awaiting != null) {
        const choices = s.steps[s.awaiting].row.sub_choices;
        d = chooseSub(T, d, s.awaiting, choices[Math.min(answer, choices.length - 1)]);
      } else if (s.next?.optional) d = skipNext(T, d, opts);
    }
    return d;
  };
  const once = generate(seeded(20260917));
  check('an all-rolled Morphus finishes, every step a roll',
    at(once).done && once.filter((d) => !d.skip).every((d) => d.how === 'roll' && Number.isInteger(d.roll)), JSON.stringify(at(once).problems));
  check('and the same injected dice build the same Morphus, decision for decision',
    JSON.stringify(generate(seeded(20260917))) === JSON.stringify(once));
  check('while other dice build another', JSON.stringify(generate(seeded(7))) !== JSON.stringify(once));
  let sweepBad = null;
  for (let seed = 1; seed <= 300 && !sweepBad; seed++) {
    const d = generate(seeded(seed * 7919), seed % 3);
    const results = morphusResults(T, d);
    const vio = secondFormViolations({ cls: FORM_CLASS, character: person, state: formState(results), rows: rowMap });
    if (!at(d).done || d.length > 60 || vio.length) sweepBad = { seed, problems: at(d).problems, length: d.length, vio };
  }
  check('three hundred rolled Morphi all finish, and every one passes the create rules', !sweepBad, JSON.stringify(sweepBad));
  const picked = pick([], 'Appearance: Almost human', 'Nightbane Characteristics: Unnatural Limbs', 'Unnatural Limbs: Four Arms');
  check('an all-picked Morphus finishes too', at(picked).done && picked.every((d) => d.how === 'pick'));
  const mix = rollNext(T, pick([], 'Appearance: Almost human', 'Nightbane Characteristics: Unnatural Limbs'),
    { rng: seq(100, 55), rollResult: atMax });
  check('and so does a mixed one: pick two, roll the third (55 is Four Arms)',
    at(mix).done && mix.map((d) => d.how).join(',') === 'pick,pick,roll' && mix[2].key === 'Unnatural Limbs: Four Arms');

  // ---- the wizard and the create path, read as source ----
  const appSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
  check('the Morphus step applies only to a composed class whose second form draws on the morphus tables',
    /const morphusForm = \(\) => \(S\.cls\?\.second_form\?\.traits_from === 'morphus'/.test(appSrc)
    && /if \(i === ST\.MORPHUS\) return !!morphusForm\(\);/.test(appSrc));
  check('the draft keeps the decisions', /'morphus',\r?\n\];/.test(appSrc));
  check('the create request sends the generated form', /second_form: secondFormPayload\(\),/.test(appSrc)
    && /results: S\.traitTables \? morphusResults\(S\.traitTables, S\.morphus\.decisions\) : \[\]/.test(appSrc));
  check('the preview folds through secondFormView, the sheet endpoint\'s fold',
    /secondFormView\(\{ cls: S\.cls, character, rows: S\.traitTables\.byKey \}\)/.test(appSrc));
  const createSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters.js'), 'utf8');
  check('an explicit second_form takes precedence over the one create would roll',
    /const secondForm = !isEmptySecondForm\(b\.second_form\) \? b\.second_form/.test(createSrc));
  const traitsSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'catalogs', 'traits.js'), 'utf8');
  check('the tables are served only for a catalog a second form may draw on',
    /SECOND_FORM_TRAIT_CATALOGS\.includes\(key\)/.test(traitsSrc) && /if \(!getUserEmail\(request\)\) return unauthorized\(\);/.test(traitsSrc));
}

}
