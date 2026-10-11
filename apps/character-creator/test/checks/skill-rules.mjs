// What a skill is worth and whether a class may take it: `per_level` on an
// entry, restrictions on a group, a base derived from an attribute, the
// per-game bases and schedules, a pick spent on a skill, a banked pick sent
// twice, and the category bonuses.
//
// Eight sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. Twelve bindings are used here and nowhere else in the suite -
// all of `js/skill-base.js` and `js/psionic-costs.js`, `categoryBonus`,
// `skillConditionalBonuses`, `resolvePicks`, `nearest`, and the two
// `js/leveling.js` functions smoke.mjs imported under an `LV_` alias.
//
// One thing was not theirs: a single call to `derive.classBonuses`, on the
// object smoke.mjs builds in `Class bonuses`. It is built again below, the
// way `second-body.mjs` builds its own.

import { readFileSync, readdirSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';
import { resolvePicks } from '../../../../functions/api/character-creator/_lib/skill-picks.js';
import { skillBase, isBaseFormula, applySystemBases, systemBaseMap } from '../../js/skill-base.js';
import { applyPsionicCosts, psionicCostMap } from '../../js/psionic-costs.js';
import { skillConditionalBonuses, parseClassMarkdown, categoryAllows, categoryBonus, categoryLabel,
         sumBonusGroups, validateBonuses }
  from '../../js/parser.js';
import { classSkillNumbers as LV_classSkillNumbers, newPickPercent as LV_newPickPercent } from '../../js/leveling.js';
import { appDir, repoRoot, check, section, appPath, wantSection } from '../harness.mjs';

const SECTIONS = ['per_level on a skill entry', 'Group-level skill restrictions',
  'Attribute-derived skill base', 'Per-system skill bases', 'Per-system W.P. schedules and psionic costs',
  'A pick spent on an attribute-derived skill', 'A banked pick sent twice', 'Category skill bonuses'];

// derive.js is a classic script, so it is loaded by evaluating it against a
// stand-in global rather than imported. smoke.mjs builds its own the same
// way; these sections used that one until they moved here.
const deriveWindow = {};
new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(deriveWindow, deriveWindow);
const derive = deriveWindow.derive;

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- 1c25a0. `per_level` is READ on a choice group ----------
// BOOK-INGEST-AUDIT.md F80, which also settles the question F25's outcome note
// left open: "which side is right turns on what `per_level` means on a CHOICE
// group as opposed to a named skill, and that was not established".
//
// It is established here. `resolveSkill` takes `explicit.per_level ??
// cat.per_level ?? 0`, so a number on the GROUP overrides the catalog row's own
// figure for every pick in it. That is how a class says "these skills do not
// advance" over rows that otherwise would - the six Mystic Russia creatures
// rely on it - and it was the one key in this validator nothing checked, on
// either the choice-group or the named branch.
section('per_level on a skill entry');
{
  const entry = (e) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: rcc\nskills:\n`
    + `  occ_skills:\n    - ${e}\n---\n\n## Lore\n\nx\n`);

  check('a non-numeric per_level on a CHOICE GROUP is rejected',
    !entry('{ choose: 2, categories: ["Rogue"], per_level: "five" }').ok);
  check('and the message names the key, or an author cannot find it',
    entry('{ choose: 2, categories: ["Rogue"], per_level: "five" }')
      .errors.join(' ').includes('per_level'));
  check('a non-numeric per_level on a NAMED skill is rejected too',
    !entry('{ name: "Prowl", base: 70, per_level: "none" }').ok);

  // The legal shapes, because a type check that also refuses valid data is
  // worse than no type check. `per_level: 0` is the whole point of the key.
  check('per_level: 0 still parses', entry('{ choose: 2, categories: ["Rogue"], per_level: 0 }').ok);
  check('and survives into the parsed data', (() => {
    const g = entry('{ choose: 2, categories: ["Rogue"], per_level: 0 }').data.skills.occ_skills[0];
    return g.per_level === 0;
  })());
  check('a positive per_level still parses',
    entry('{ choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5 }').ok);
  check('and omitting it is still legal - it falls through to the catalog row',
    entry('{ choose: 2, categories: ["Rogue"] }').ok);

  // THE PIN. A validator outlives the behaviour it protects unless something
  // says the behaviour is still there. If resolveSkill stops reading the
  // group's own figure, `per_level: 0` silently starts meaning nothing.
  check('resolveSkill still prefers the entry\'s per_level over the catalog row\'s', (() => {
    // Run, since 2026-10-10: the wizard's resolveSkill hands the entry to
    // classSkillNumbers in js/leveling.js, and a stated 0 must beat the row's 5.
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return /classSkillNumbers\(cat, explicit, S\.attrs\)/.test(src)
      && LV_classSkillNumbers({ base: 40, per_level: 5 }, { per_level: 0 }, {}).per_level === 0
      && LV_classSkillNumbers({ base: 40, per_level: 5 }, {}, {}).per_level === 5;
  })());
  // Pins the CODE rather than the comment beside it: a comment can be reworded
  // without changing anything, which would fail this for no reason. The group's
  // entry is what `resolveSkill` is handed, and its per_level is what the pick
  // carries onto the character.
  check('and a choice-group pick carries the resolved per_level onto the character', (() => {
    const src = readFileSync(join(appDir, 'app.js'), 'utf8');
    return /const r = resolveSkill\(name, s\);[\s\S]{0,200}?per_level: r\.per_level/.test(src);
  })());
}

// ---------- 1c25a0b. A restriction on the GROUP instead of the category ----------
// BOOK-INGEST-AUDIT.md F84, parser half.
//
// `only`, `except`, `only_prefix` and `except_prefix` are read ONLY off a
// CATEGORY ENTRY. `categoryAllows` finds the entry matching the skill's own
// category and reads them off that object, returning true outright for a bare
// string. Written one level out, on the choice group, they parsed, validated,
// stored and did nothing - and it fails OPEN both ways, so the class simply
// over-grants and nobody is told. The Night Witch offered all 87 Technical
// skills for "Lore: two of choice" and `class-check` called it `ready`.
section('Group-level skill restrictions');
{
  const entry = (e) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: occ\nskills:\n`
    + `  occ_skills:\n    - ${e}\n---\n\n## Lore\n\nx\n`);
  const groupErrors = (e) =>
    (entry(e).errors || []).filter((m) => m.includes('on the GROUP'));

  // All four, one at a time. Listed rather than looped so a key dropped from
  // the parser's list fails BY NAME here instead of quietly reducing a count.
  check('only_prefix on the group is refused',
    groupErrors('{ choose: 3, categories: ["Technical"], only_prefix: ["Language:"] }').length === 1);
  check('except_prefix on the group is refused',
    groupErrors('{ choose: 3, categories: ["Technical"], except_prefix: ["Language:"] }').length === 1);
  check('only on the group is refused',
    groupErrors('{ choose: 2, categories: ["Technical"], only: ["Lore: Demons"] }').length === 1);
  check('except on the group is refused',
    groupErrors('{ choose: 2, categories: ["Technical"], except: ["Lore: Demons"] }').length === 1);

  // REFUSED, not warned: the shape is unambiguously a mistake, and a warning on
  // a silent over-grant is the same class of thing as the key itself.
  check('and it is an ERROR, so the class does not parse',
    entry('{ choose: 3, categories: ["Technical"], only_prefix: ["Language:"] }').ok === false);

  // The message has to say where the key BELONGS, or an author reads "nothing
  // reads it" and deletes the restriction rather than moving it.
  // `?? ''` rather than `[0].includes(...)`: with the refusal removed this
  // threw instead of failing, which aborts the run and hides the checks after
  // it. Measured by removing the refusal and watching the section stop at five
  // failures instead of six.
  check('the message names the category form',
    (groupErrors('{ choose: 3, categories: ["Technical"], only_prefix: ["Language:"] }')[0] ?? '')
      .includes('categories: [{ name: "..."'));

  // A group-level key on a `from` list is just as dead as on a `categories`
  // one, and the first draft of this section covered only the second.
  check('a from-list group carrying one is refused too',
    groupErrors('{ choose: 2, from: ["Swimming", "Climbing"], except: ["Swimming"] }').length === 1);

  // THE OTHER HALF, and what makes this a scope rule rather than a ban: the
  // correct form must still pass, or the refusal has removed the feature.
  check('the CATEGORY-entry form still parses',
    entry('{ choose: 3, categories: [{ name: "Technical", only_prefix: ["Language:"] }] }').ok);
  check('and a plain group with no restriction still parses',
    entry('{ choose: 3, categories: ["Technical"] }').ok);

  // THE PIN. A validator outlives the behaviour it protects unless something
  // says the behaviour is still there. If `categoryAllows` ever started reading
  // the group, this refusal would become WRONG rather than merely redundant.
  // Since BOOK-INGEST-AUDIT F109 categoryAllows ranks every same-named entry
  // through realCategoryEntry, and the per-entry reading lives in entryAdmits,
  // so the pin follows it there and also asks that categoryAllows still routes
  // through it.
  check('categoryAllows still reads the four keys off the category ENTRY', (() => {
    const src = readFileSync(join(appDir, 'js', 'parser.js'), 'utf8');
    const bodyOf = (fnName) => {
      const fn = src.slice(src.indexOf(`function ${fnName}(`));
      return fn.slice(0, fn.indexOf('\n}\n'));
    };
    return ['only', 'except', 'only_prefix', 'except_prefix']
      .every((k) => new RegExp(`entry\\.${k}\\b`).test(bodyOf('entryAdmits')))
      && /realCategoryEntry\(/.test(bodyOf('categoryAllows'))
      && /entryAdmits\(/.test(bodyOf('realCategoryEntry'));
  })());

  // ── and the entry the refusal insists on is itself validated (F88) ──
  // F84 moved authors off a form that was silently DEAD and onto one that was
  // silently UNVALIDATED. These four probes each produced ok=true and zero
  // errors before the fourth validateCategories caller was added, while the
  // IDENTICAL entry on occ_related_skills errored - the rule existed, fired,
  // and was never reached from a choice group.
  const catErrors = (e) => (entry(e).errors || [])
    .filter((m) => m.includes('choice-group') && !m.includes('on the GROUP'));

  check('a group category entry setting both only and except is refused',
    catErrors('{ choose: 1, categories: [{ name: "Technical", only: ["A"], except: ["B"] }] }')
      .length === 1);
  check('a prefix list written as a bare string is refused',
    catErrors('{ choose: 1, categories: [{ name: "Technical", only_prefix: "Language:" }] }')
      .length === 1);
  check('a group category entry with no name is refused',
    catErrors('{ choose: 1, categories: [{ only: ["A"] }] }').length === 1);
  check('and a bonus that is a string rather than a number',
    catErrors('{ choose: 1, categories: [{ name: "Technical", bonus: "10%" }] }').length === 1);

  // THE OTHER DIRECTION, which is what stops this becoming a rule nobody can
  // satisfy: the correct form the F84 message tells authors to write must pass.
  check('while the well-formed entry F84 asks for still parses clean',
    entry('{ choose: 1, categories: [{ name: "Technical", except_prefix: ["Language:"] }] }')
      .ok === true);

  // A bare string category is the commonest form in the catalog and carries no
  // keys to check; it must not be dragged in by the new caller.
  check('and a bare string category is still accepted',
    catErrors('{ choose: 3, categories: ["Technical", "Physical"] }').length === 0);
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

  // ── ONE GAME'S OWN PERCENTAGES (BOOK-INGEST-AUDIT.md F83) ───────────────
  //
  // The catalog holds one `base` per skill, which was true enough while every
  // book in it was Palladium's own. Heroes Unlimited is a different game and
  // prints its own figure for every skill: 48 of the 55 names it shares with
  // the catalog disagree.
  section('Per-system skill bases');
  {
    const cat = [
      { name: 'Computer Operation', category: 'Technical', base: 40, per_level: 5 },
      { name: 'Prowl', category: 'Physical', base: 25, per_level: 5 },
      { name: 'Locksmith', category: 'Mechanical', base: 25, per_level: 5 },
    ];
    const hu = systemBaseMap([
      { skill_name: 'Computer Operation', base: 60, per_level: 5, source_book: 'HU p.31' },
      { skill_name: 'Prowl', base: 46, per_level: 8, source_book: 'HU p.35' },
      // per_level ONLY: a book that changes the gain and not the base says so,
      // and the row's own base has to survive.
      { skill_name: 'Swimming', base: null, per_level: 8 },
    ]);
    const out = applySystemBases(cat, hu);
    const by = (n) => out.find((r) => r.name === n);
    check('a base is substituted', by('Computer Operation').base === 60);
    check('and so is a per_level', by('Prowl').per_level === 8 && by('Prowl').base === 46);
    check('a skill with no row is untouched',
      by('Locksmith').base === 25 && by('Locksmith').per_level === 5);
    check('the source book rides along, so a sheet can explain the number',
      by('Computer Operation').system_base_source === 'HU p.31');

    // THE INPUT IS NOT MUTATED. The wizard holds ONE catalog for a whole
    // session and derives per system; mutating would leave one game's numbers
    // under another the moment a player switched.
    check('the raw catalog is left alone',
      cat[0].base === 40 && cat[1].per_level === 5
        && cat[0].system_base_source === undefined);

    // A null override column means "no opinion", the same reading
    // `base_formula` already has.
    const onlyPer = applySystemBases(
      [{ name: 'Swimming', base: 50, per_level: 5 }], hu)[0];
    check('a null base leaves the catalog base standing',
      onlyPer.base === 50 && onlyPer.per_level === 8);

    check('no overrides returns the rows unchanged',
      applySystemBases(cat, new Map()) === cat && applySystemBases(cat, null) === cat);
    check('systemBaseMap reads skill_name or name, case-insensitively',
      systemBaseMap([{ name: 'Prowl', base: 1 }]).get('prowl').base === 1
        && systemBaseMap([{ skill_name: 'PROWL', base: 2 }]).get('prowl').base === 2);

    // ── AND EVERY PATH THAT RESOLVES A PERCENTAGE USES IT ─────────────────
    //
    // This is the check that matters. F18 is the precedent and the warning:
    // `skills.base_formula` had a client resolver documented as "the ONLY place
    // the two are chosen between", and one server path never called it - so a
    // skill taken at creation and the SAME skill taken at level-up disagreed,
    // silently, for weeks. Three paths resolve a skill's numbers, and a fourth
    // would have to learn this too.
    const fnDir = join(repoRoot, 'functions', 'api', 'character-creator');
    const paths = {
      'catalogs.js (the wizard at boot)': ['catalogs.js', /skill_system_bases/],
      '_lib/grants.js (a G.M. grant)': ['_lib/grants.js', /applySystemBases\(results \|\| \[\], systemBases\)/],
      '_lib/skill-picks.js (a spent pick)': ['_lib/skill-picks.js', /applySystemBases\(results, systemBases\)/],
    };
    for (const [label, [file, re]] of Object.entries(paths)) {
      check(`${label} applies the per-system base`,
        re.test(readFileSync(join(fnDir, file), 'utf8')), file);
    }
    // And the endpoints actually hand one over - a defaulted parameter nobody
    // passes is the same silence `skills.mos.choose` sat in for a year.
    for (const f of ['characters/[id]/grants.js', 'characters/[id]/picks.js',
                     'characters/[id]/level-confirm.js']) {
      check(`${f} loads the character's system`,
        /loadSystemBases\(env, await systemForCharacter\(env, params\.id\)\)/
          .test(readFileSync(join(fnDir, f), 'utf8')), f);
    }
    // The wizard derives from the RAW catalog, and on every route that sets a
    // system - picking one, and resuming a draft, which assigns it directly.
    const wizSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
    check('the wizard keeps the raw catalog and derives from it',
      /S\.skillCatalogRaw = catalogsRes\.skills;/.test(wizSrc)
        && /S\.skillCatalog = applySystemBases\(raw, systemBaseMap\(mine\)\)/.test(wizSrc));
    check('and re-derives on every route that sets the system',
      (wizSrc.match(/applySkillSystem\(\);/g) || []).length >= 3, 'boot, pickSystem, resumeDraft');

    // THE SHEET IS THE FOURTH READER and it was missed on the first pass -
    // found by a premise audit, not by any check here. Its two pick dropdowns
    // print `${s.base}%` straight off the `/catalogs` payload, so without this
    // it offered the catalog's percentage while `resolvePicks` stored the
    // book's: one number disagreeing with itself on the same screen.
    //
    // It asks the ENDPOINT to substitute rather than doing it itself, because
    // sheet.js is a classic script and cannot import the helper - and a hand
    // copy of the rule is the pair that drifts.
    const sheetF83 = readFileSync(appPath('sheet.js'), 'utf8');
    const catSrc = readFileSync(join(fnDir, 'catalogs.js'), 'utf8');
    check('the sheet asks /catalogs for its own system',
      /api\('catalogs\?system=' \+ encodeURIComponent\(C\.data\.campaign_system/.test(sheetF83),
      'sheet.js');
    check('and the endpoint honours it',
      /const system = new URL\(request\.url\)\.searchParams\.get\('system'\)/.test(catSrc)
        && /skills: applySystemBases\(skills\.results, systemBaseMap\(/.test(catSrc));
  }

  // ── ONE GAME'S OWN W.P. SCHEDULE AND PSIONIC PRICE (BOOK-INGEST-AUDIT.md F102)
  //
  // F83's table held a percentage and nothing else, and a W.P. is carried
  // wholly by `level_bonuses`; `psionic_powers` held one `isp`. So Heroes
  // Unlimited's W.P. Targeting and its 2-I.S.P. Hypnotic Suggestion both
  // arrived at another game's numbers without a word.
  section('Per-system W.P. schedules and psionic costs');
  {
    const pf = '[{"level":1,"applies_when":"thrown","combat":{"strike":1}},{"level":3,"applies_when":"thrown","combat":{"strike":1}}]';
    const hu = '[{"level":2,"applies_when":"thrown or bow","combat":{"strike":1}}]';
    const cat = [{ name: 'W.P. Targeting', base: 0, per_level: 0, level_bonuses: pf },
                 { name: 'W.P. Sword', base: 0, per_level: 0, level_bonuses: '[]' }];
    const out = applySystemBases(cat, systemBaseMap([
      { skill_name: 'W.P. Targeting', base: null, per_level: null, level_bonuses: hu }]));
    // REPLACED, never merged: merged, a level-3 character would hold both
    // games' strike bonuses, which is neither book.
    check('a schedule replaces the row\'s schedule outright',
      out[0].level_bonuses === hu);
    check('while base and per_level, stated null, keep the row\'s',
      out[0].base === 0 && out[0].per_level === 0);
    check('a W.P. with no override keeps its own schedule',
      out[1].level_bonuses === '[]');
    check('and the raw catalog row is left alone', cat[0].level_bonuses === pf);
    // The server's sheet path reads the schedule through bonusesFromSkills, so
    // the level-2 strike has to come out of the SUBSTITUTED row.
    check('the substituted schedule is what the bonus reader sees',
      skillConditionalBonuses([out[0]], 3).length === 1
        && skillConditionalBonuses([out[0]], 3)[0].combat.strike === 1
        && skillConditionalBonuses([cat[0]], 3)[0].combat.strike === 2);

    const psi = [{ name: 'Hypnotic Suggestion', category: 'Super', isp: 6, isp_note: null },
                 { name: 'Death Trance', category: 'Physical', isp: 1, isp_note: null },
                 { name: 'Mind Block', category: 'Sensitive', isp: 4, isp_note: null }];
    const nb = psionicCostMap([
      { power_name: 'Hypnotic Suggestion', isp: 2, isp_note: '4 as a Healer power', source_book: 'NB p.77' },
      { power_name: 'Death Trance', isp: null, isp_note: '2 as a Sensitive power' }]);
    const po = applyPsionicCosts(psi, nb);
    check('a game\'s price is substituted, with its note',
      po[0].isp === 2 && po[0].isp_note === '4 as a Healer power' && po[0].system_cost_source === 'NB p.77');
    check('a null isp keeps the catalog\'s minimum and takes the note',
      po[1].isp === 1 && po[1].isp_note === '2 as a Sensitive power');
    check('a power with no row is untouched', po[2] === psi[2]);
    check('the raw psionic rows are left alone', psi[0].isp === 6 && psi[0].isp_note === null);
    check('no costs returns the rows unchanged',
      applyPsionicCosts(psi, new Map()) === psi && applyPsionicCosts(psi, null) === psi);
    check('psionicCostMap reads power_name or name, case-insensitively',
      psionicCostMap([{ name: 'Mind Block', isp: 1 }]).get('mind block').isp === 1
        && psionicCostMap([{ power_name: 'MIND BLOCK', isp: 2 }]).get('mind block').isp === 2);

    // Every path that turns a catalog row into a character's numbers, named -
    // F83's own section says why: F18 was a resolver one server path never called.
    const fnDir = join(repoRoot, 'functions', 'api', 'character-creator');
    const src = (f) => readFileSync(join(fnDir, f), 'utf8');
    check('the sheet\'s bonus loader applies the game\'s schedule',
      /applySystemBases\(rows, overrides\)/.test(src('_lib/skill-bonuses.js')), '_lib/skill-bonuses.js');
    check('the server loads level_bonuses with the other override columns',
      /SELECT skill_name, base, per_level, level_bonuses, source_book FROM skill_system_bases/
        .test(src('_lib/system-bases.js')), '_lib/system-bases.js');
    check('every server power pick is priced in the character\'s game',
      /applyPsionicCosts\(psionics\.filter\(keep\), costs\)/.test(src('_lib/power-picks.js')), '_lib/power-picks.js');
    const catSrc102 = src('catalogs.js');
    check('/catalogs ships every game\'s prices, and substitutes the one asked for',
      /FROM psionic_system_costs/.test(catSrc102)
        && /psionics: applyPsionicCosts\(psionics\.results, psionicCostMap\(/.test(catSrc102)
        && /level_bonuses, note, source_book FROM skill_system_bases/.test(catSrc102));
    const wiz102 = readFileSync(join(appDir, 'app.js'), 'utf8');
    check('the wizard derives its psionic prices from the raw rows',
      /S\.psiCatalogRaw = catalogsRes\.psionics;/.test(wiz102)
        && /S\.psiCatalog = applyPsionicCosts\(S\.psiCatalogRaw \|\| \[\], psionicCostMap\(costs\)\)/.test(wiz102));
  }

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

  // The wizard's Advancement step makes the same pick before the character
  // exists, and until 2026-10-10 it wrote the stored `base` alone: this skill
  // at 0%, and any related pick without its class bonus. Both now ask one
  // function, held here directly and then as the two call sites.
  const { newPickPercent } = await import('../../js/leveling.js');
  const physical = [{ name: 'Physical', bonus: 5 }];
  check('one rule: a formula base plus the class bonus on a related pick',
    newPickPercent(ZERO_G, { PP: 12 }, physical) === 65);
  check('no class bonus on a secondary pick',
    newPickPercent(ZERO_G, { PP: 12 }, physical, { secondary: true }) === 60);
  check('none where the grant names no categories', newPickPercent(ZERO_G, { PP: 12 }, null) === 60);
  check('and nothing at all for a skill with no percentage',
    newPickPercent({ name: 'W.P. Sword', category: 'Physical', base: 0 }, { PP: 12 }, physical) === 0);
  const pickSrc = readFileSync(join(repoRoot, 'functions/api/character-creator/_lib/skill-picks.js'), 'utf8');
  check('the server\'s pick path asks it',
    /pct: newPickPercent\(row, attributes, allowed, \{ secondary: asSecondary \}\)/.test(pickSrc));
  const wizardRows = readFileSync(join(appDir, 'app.js'), 'utf8').match(/function levelPickRows\(\) \{[\s\S]*?\n\}/)?.[0] || '';
  check('and so does the wizard\'s, with the grant\'s own categories and kind',
    /pct: newPickPercent\(\{ \.\.\.r, name \}, S\.attrs, g\.categories, \{ secondary: g\.kind === 'secondary' \}\)/.test(wizardRows)
    && !/r\.base/.test(wizardRows));

  // The columns that rule reads, selected by five server queries. A row
  // fetched without `base_formula` resolves this very skill to 0% with no
  // error, so the list is stated beside its reader and nobody types it.
  const { SKILL_BASE_COLUMNS, skillBase: baseOf } = await import('../../js/skill-base.js');
  const cols = SKILL_BASE_COLUMNS.split(',').map((c) => c.trim());
  check('the skill column list carries what the base and the advance are read from',
    ['name', 'category', 'base', 'base_formula', 'per_level'].every((c) => cols.includes(c)), SKILL_BASE_COLUMNS);
  check('a row holding exactly those columns resolves',
    baseOf(Object.fromEntries(cols.map((c) => [c, ZERO_G[c]])), { PP: 12 }) === 60);
  const fnFiles = (dir) => readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    (e.isDirectory() ? fnFiles(join(dir, e.name)) : e.name.endsWith('.js') ? [join(dir, e.name)] : []));
  const fnDir17 = join(repoRoot, 'functions/api/character-creator');
  const typed = fnFiles(fnDir17).filter((f) => /base,\s*base_formula,\s*per_level/.test(readFileSync(f, 'utf8')))
    .map((f) => f.slice(fnDir17.length + 1));
  check('no server query types the list out', typed.length === 0, typed.join(', '));
  const readers = fnFiles(fnDir17).filter((f) => /\$\{SKILL_BASE_COLUMNS\}/.test(readFileSync(f, 'utf8'))).length;
  check('five queries select it by name', readers === 5, `${readers}`);
}

// ---------- A banked pick sent twice ----------
// The pick routes read the character and its unspent grants, then write both
// in one batch. The batch was atomic and unconditional: two requests that read
// the same grants both wrote, so the second replaced the first one's picks on
// the character and took the allowance down again. Run here against a real
// SQLite through the D1 shape the routes use, because the guard is SQL and a
// regex over it would prove nothing.
section('A banked pick sent twice');
{
  const { pendingGuard, claimStatement, batchApplied, pendingToken } =
    await import('../../../../functions/api/character-creator/_lib/pending-claim.js');
  const { claimPlan } = await import('../../../../functions/api/character-creator/_lib/skill-picks.js');

  const db = new DatabaseSync(':memory:');
  db.exec(`CREATE TABLE characters (id INTEGER PRIMARY KEY, skills TEXT);
    CREATE TABLE pending_skill_picks (id INTEGER PRIMARY KEY AUTOINCREMENT, character_id INTEGER,
      count INTEGER NOT NULL, claimed_at TEXT);
    INSERT INTO characters VALUES (1, '[]');
    INSERT INTO pending_skill_picks (character_id, count) VALUES (1, 1), (1, 2), (2, 5);`);
  const env = { DB: {
    prepare: (sql) => ({ bind: (...b) => ({ sql, b }) }),
    // One transaction, as D1's batch is.
    batch: (stmts) => {
      db.exec('BEGIN');
      const out = stmts.map((s) => ({ meta: { changes: Number(db.prepare(s.sql).run(...s.b).changes) } }));
      db.exec('COMMIT');
      return out;
    },
  } };
  const unspent = () => db.prepare(
    'SELECT id, count FROM pending_skill_picks WHERE character_id = 1 AND claimed_at IS NULL ORDER BY id').all();
  // The route's own batch: the character, then the claim, both guarded.
  const spend = (pending, skills, spent) => {
    const unchanged = pendingGuard('pending_skill_picks', '1', pending);
    return env.DB.batch([
      env.DB.prepare(`UPDATE characters SET skills = ? WHERE id = ? AND ${unchanged.sql}`).bind(skills, '1', ...unchanged.binds),
      claimStatement(env, 'pending_skill_picks', unchanged, claimPlan(pending, spent)),
    ].filter(Boolean));
  };
  const skillsNow = () => db.prepare('SELECT skills FROM characters WHERE id = 1').get().skills;
  const left = () => unspent().reduce((n, g) => n + g.count, 0);

  check('the plan claims the oldest grant whole and takes the rest from the next',
    JSON.stringify(claimPlan([{ id: 7, count: 1 }, { id: 9, count: 2 }], 2))
      === '[{"id":7,"left":1,"claim":true},{"id":9,"left":1,"claim":false}]');
  check('the token reads the rows, their ids and their counts', pendingToken(unspent()) === '2:3:3');

  const read = unspent();           // both requests read the same two grants
  const first = spend(read, '["Climbing"]', 1);
  check('the first request writes', batchApplied(first) && skillsNow() === '["Climbing"]' && left() === 2);
  const second = spend(read, '["Climbing"]', 1);
  check('the same request again writes NOTHING', !batchApplied(second) && second.every((r) => r.meta.changes === 0));
  check('so one pick is kept and one is paid for', skillsNow() === '["Climbing"]' && left() === 2);

  // The case separate claim statements would get half-right: a stale request
  // that spends MORE reaches a grant the first one never touched.
  const greedy = spend(read, '["Prowl","Swimming"]', 2);
  check('a stale request that reaches an untouched grant leaves that one alone too',
    !batchApplied(greedy) && skillsNow() === '["Climbing"]' && left() === 2);

  check('a request that read the grants as they now stand goes through',
    batchApplied(spend(unspent(), '["Climbing","Prowl"]', 1)) && left() === 1 && unspent()[0].count === 1);
  check('and another character\'s grants are neither read nor written',
    db.prepare('SELECT count FROM pending_skill_picks WHERE character_id = 2').get().count === 5);
  // The two pieces the skill and power stacks still each wrote out: how a set
  // of skill grants pools into one allowance, and the level guard on banking.
  {
    const { pooledSkillAllowance } = await import('../../../../functions/api/character-creator/_lib/skill-picks.js');
    const tech = { name: 'Technical', bonus: 10 };
    const pooled = pooledSkillAllowance([
      { count: 2, categories: ['Physical', tech] }, { count: 1, categories: [tech, 'Rogue'] },
      { count: 3, kind: 'secondary' },
    ]);
    check('grants pool into one allowance, with the secondary picks counted apart',
      pooled.allowance === 6 && pooled.secondaryAllowance === 3);
    check('the related grants\' categories are merged without a repeat',
      JSON.stringify(pooled.categories) === JSON.stringify(['Physical', tech, 'Rogue']), JSON.stringify(pooled.categories));
    check('a secondary grant does not unrestrict the related picks',
      Array.isArray(pooled.categories) && pooled.categories.length === 3);
    check('one unrestricted related grant does',
      pooledSkillAllowance([{ count: 1, categories: ['Physical'] }, { count: 1 }]).categories === null);
    check('nothing banked is an allowance of nothing', pooledSkillAllowance([]).allowance === 0);

    const fnRoot = join(repoRoot, 'functions/api/character-creator');
    const text = (rel) => readFileSync(join(fnRoot, rel), 'utf8');
    for (const route of ['characters/[id]/picks.js', 'characters/[id]/level-confirm.js']) {
      check(`${route} pools through the one function`,
        /= pooledSkillAllowance\((?:pending|grants)\);/.test(text(route)) && !/kind !== 'secondary'/.test(text(route)));
    }
    const guardText = 'WHERE EXISTS (SELECT 1 FROM characters WHERE id = ? AND level = ?)';
    const holders = ['_lib/pending-claim.js', '_lib/skill-picks.js', '_lib/power-picks.js', 'characters/[id]/level-confirm.js']
      .filter((rel) => text(rel).includes(guardText));
    check('the level guard is written once, in pending-claim.js', holders.join() === '_lib/pending-claim.js', holders.join());
    check('and both tables\' inserts read it',
      /\$\{ifLevel == null \? '' : LEVEL_GUARD\}/.test(text('_lib/skill-picks.js'))
      && /const guard = ifLevel == null \? '' : LEVEL_GUARD;/.test(text('_lib/power-picks.js')));
  }

  check('a guard for a table that is not a pending table is refused',
    (() => { try { pendingGuard('characters', 1, []); return false; } catch { return true; } })());

  // Both routes, read: every write in the batch carries the guard, and a batch
  // that wrote nothing is a 409 rather than a success.
  const routeDir = join(repoRoot, 'functions/api/character-creator/characters/[id]');
  for (const [file, table] of [['picks.js', 'pending_skill_picks'], ['power-picks.js', 'pending_power_picks']]) {
    const text = readFileSync(join(routeDir, file), 'utf8');
    const post = text.slice(text.indexOf('export async function onRequestPost'));
    const writes = post.match(/UPDATE characters SET[\s\S]*?WHERE id = \?[^`"']*/g) || [];
    check(`${file}: every character write is guarded`,
      writes.length > 0 && writes.every((w) => /AND \$\{unchanged\.sql\}/.test(w)), `${writes.length} writes`);
    check(`${file}: the guard is on its own pending table, and the claim is the one guarded statement`,
      post.includes(`pendingGuard('${table}', params.id, pending)`)
      && post.includes(`claimStatement(env, '${table}', unchanged,`) && !/UPDATE pending_/.test(post));
    check(`${file}: a batch that wrote nothing answers 409`,
      /if \(!batchApplied\(written\)\) return json\(\{ error: STALE_PICKS \}, 409\);/.test(post));
  }
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

  // ── a bonus scoped to PART of a category (BOOK-INGEST-AUDIT F109) ───────
  // "Pilot: Any, +10% to water vehicles only" is the category twice: an `only`
  // entry carrying the bonus and an `except` entry for the rest. Both functions
  // used to take the FIRST same-named entry, so with the `only` half first every
  // other Pilot skill was REFUSED, and with the `except` half first the water
  // skills got nothing. Both orders are checked, because the bug was the order.
  {
    const water = ['Boat: Motor', 'Boat: Sail'];
    const onlyFirst = [{ name: 'Pilot', only: water, bonus: 10 }, { name: 'Pilot', except: water }];
    const exceptFirst = [...onlyFirst].reverse();
    for (const [label, cats] of [['only entry first', onlyFirst], ['except entry first', exceptFirst]]) {
      check(`scoped bonus, ${label}: the named skill is admitted and pays`,
        categoryAllows(cats, { name: 'Boat: Sail', category: 'Pilot' })
        && categoryBonus(cats, { name: 'Boat: Sail', category: 'Pilot' }) === 10);
      check(`scoped bonus, ${label}: the rest of the category is admitted at the other figure`,
        categoryAllows(cats, { name: 'Airplane', category: 'Pilot' })
        && categoryBonus(cats, { name: 'Airplane', category: 'Pilot' }) === 0);
    }

    // The Fly Boy: +15% to aircraft, "otherwise +10%" - the other figure rides
    // on the `except` entry.
    const flyBoy = [{ name: 'Pilot', except: ['Airplane'], bonus: 10 },
      { name: 'Pilot', only: ['Airplane'], bonus: 15 }];
    check('scoped bonus: the except entry pays its own figure outside the named skills',
      categoryBonus(flyBoy, { name: 'Airplane', category: 'Pilot' }) === 15
      && categoryBonus(flyBoy, { name: 'Hovercraft', category: 'Pilot' }) === 10);

    // A plain entry plus an `only` entry: "Domestic: +5%, and +10% to Fishing".
    // The `only` entry outranks the plain one for the skill it names, and the
    // plain one still speaks for everything else.
    const domestic = [{ name: 'Domestic', bonus: 5 }, { name: 'Domestic', only: ['Fishing'], bonus: 10 }];
    check('scoped bonus: an only entry outranks a plain entry for the skill it names',
      categoryBonus(domestic, { name: 'Fishing', category: 'Domestic' }) === 10
      && categoryBonus(domestic, { name: 'Cook', category: 'Domestic' }) === 5
      && categoryAllows(domestic, { name: 'Cook', category: 'Domestic' }));

    // The prefix forms rank with their exact-name siblings.
    const tech = [{ name: 'Technical', bonus: 10 }, { name: 'Technical', only_prefix: ['Language:'], bonus: 20 }];
    check('scoped bonus: an only_prefix entry ranks as an only entry',
      categoryBonus(tech, { name: 'Language: Other', category: 'Technical' }) === 20
      && categoryBonus(tech, { name: 'Computer Operation', category: 'Technical' }) === 10);

    // What ranking must NOT do: admit a skill that no entry admits. Two entries
    // that both exclude it still refuse it, and the bonus falls back to the
    // first entry exactly as the single-entry lookup always did.
    const neither = [{ name: 'Pilot', only: ['Boat: Sail'], bonus: 10 },
      { name: 'Pilot', except: ['Airplane'] }];
    check('scoped bonus: a skill neither entry admits is still refused',
      !categoryAllows(neither, { name: 'Airplane', category: 'Pilot' }));
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
    // Through newPickPercent since 2026-10-10, as the level-up pick is.
    return src.includes('pct: newPickPercent({ ...row, name: n }, S.attrs, relatedCats())');
  })());
  check('the server applies it to a level-up pick', (() => {
    const src = readFileSync(join(appDir, '..', '..', 'functions', 'api', 'character-creator',
      '_lib', 'skill-picks.js'), 'utf8');
    // Through newPickPercent since 2026-10-10, which the wizard's Advancement
    // step calls too; 'A pick spent on an attribute-derived skill' runs it.
    return src.includes('newPickPercent(row, attributes, allowed, { secondary: asSecondary })');
  })());
  // A W.P. and a hand to hand sit at 0 because they are not percentile skills.
  // Adding ten to that would invent a roll that does not exist.
  check('both places guard the bonus on a real base', (() => {
    const wiz = readFileSync(join(appDir, 'app.js'), 'utf8');
    // Both halves are the shared function now, so it is run, not read - and
    // neither file may write the rule out again beside it.
    const noPercent = { name: 'W.P. Sword', category: 'Technical', base: 0 };
    return !/base \? base \+ (?:categoryBonus|catBonus|bonus)/.test(wiz)
      && LV_newPickPercent(noPercent, {}, [{ name: 'Technical', bonus: 10 }]) === 0;
  })());

  // THREE COPIES OF ONE ARITHMETIC (2026-10-10). The wizard, the NPC generator
  // and the level-up proposal each wrote out the cap, the class-skill resolver,
  // the I.Q. bonus and the per-level advance. They are js/leveling.js's now.
  {
    const LV = await import('../../js/leveling.js');
    check('the cap is 98, stated once', LV.SKILL_PCT_CAP === 98);
    const row = { name: 'Zero-G', base: 0, base_formula: 'PP*5', per_level: 4 };
    check('a class skill takes the catalog numbers when the class states none',
      JSON.stringify(LV.classSkillNumbers(row, {}, { PP: 12 })) === '{"base":60,"per_level":4}');
    check('a stated base replaces the catalog\'s, and a stated step replaces its step',
      JSON.stringify(LV.classSkillNumbers(row, { base: 30, per_level: 5 }, { PP: 12 })) === '{"base":30,"per_level":5}');
    check('a stated bonus adds to a real percentage',
      LV.classSkillNumbers(row, { bonus: 15 }, { PP: 12 }).base === 75);
    check('and to nothing where the skill has no percentage',
      !LV.classSkillNumbers({ name: 'W.P. Sword', base: 0 }, { bonus: 15 }, {}).base);
    check('a skill the catalog does not hold resolves to no numbers rather than throwing',
      JSON.stringify(LV.classSkillNumbers(null, {}, {})) === '{"per_level":0}'
      || LV.classSkillNumbers(null, {}, {}).per_level === 0);
    check('the I.Q. bonus is added and recorded',
      JSON.stringify(LV.withIqBonus({ name: 'x', pct: 40 }, 5)) === '{"name":"x","pct":45,"iq_bonus":5}');
    check('held at the cap', LV.withIqBonus({ pct: 96 }, 5).pct === 98);
    check('and a skill with no percentage gets none', JSON.stringify(LV.withIqBonus({ pct: 0 }, 5)) === '{"pct":0,"iq_bonus":0}');
    check('a percentage advances by its step per level, to the cap',
      LV.advancedPercent(40, 5, 3) === 55 && LV.advancedPercent(90, 5, 3) === 98);

    const wizardSrc = readFileSync(join(appDir, 'app.js'), 'utf8');
    const npcSrc = readFileSync(join(appDir, 'js', 'npc-generate.js'), 'utf8');
    const levelSrc = readFileSync(join(appDir, 'js', 'leveling.js'), 'utf8');
    for (const [name, text] of [['the wizard', wizardSrc], ['the NPC generator', npcSrc]]) {
      check(`${name} states no cap of its own`, !/const SKILL_PCT_CAP/.test(text));
      check(`${name} writes out no advance, I.Q. bonus or class-skill resolver of its own`,
        !/Math\.min\(SKILL_PCT_CAP/.test(text) && !/explicit\.base \?\?/.test(text));
      check(`${name} asks the shared functions`,
        /withIqBonus\(row, iq\)/.test(text) && /classSkillNumbers\(cat, explicit, /.test(text) && /newPickPercent\(/.test(text));
    }
    // NO I.Q. BONUS ON A SKILL GAINED AT A LEVEL-UP (Nate's ruling, 2026-10-10).
    // The wizard and the server's pick path never added it; the NPC generator
    // did, so the same pick came out higher on an NPC. Run, with an I.Q. high
    // enough that the bonus is not zero.
    {
      const { generateNpc } = await import('../../js/npc-generate.js');
      const world = {};
      new Function('globalThis', readFileSync(join(appDir, 'js', 'derive.js'), 'utf8')).call(world, world);
      const catalog = ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo', 'Foxtrot'].map((n, i) =>
        ({ name: n, category: 'Technical', base: 30 + i, per_level: 5 }));
      const cls = { id: 'npc-test', name: 'Test', category: 'occ', system: 'rifts',
        attribute_dice: { IQ: '3d6+14' },
        skills: { occ_skills: [], secondary_skills: { count: 0 },
          occ_related_skills: { count: 2, categories: [{ name: 'Technical', bonus: 10 }],
            schedule: [{ level: 3, count: 2 }] } } };
      const npc = generateNpc({ cls, level: 4, catalog, derive: world.derive, system: 'rifts' });
      const iq = world.derive.bio(npc.attributes, null, world.derive.classBonuses(cls, 1, {})).iq_skill_bonus_pct;
      const started = npc.skills.filter((s) => s.gained_at_level == null);
      const gained = npc.skills.filter((s) => s.gained_at_level != null);
      const base = (s) => catalog.find((r) => r.name === s.name).base;
      check('the generated NPC has an I.Q. bonus, two starting picks and two gained at level 3',
        iq > 0 && started.length === 2 && gained.length === 2 && gained.every((s) => s.gained_at_level === 3),
        JSON.stringify({ iq, started: started.length, gained: gained.length }));
      check('a skill held since level one carries the I.Q. bonus',
        started.every((s) => s.iq_bonus === iq), JSON.stringify(started));
      check('a skill gained at a level-up starts at its base and the class bonus, with no I.Q. bonus',
        gained.every((s) => s.pct === base(s) + 10 && !('iq_bonus' in s)), JSON.stringify(gained));
    }

    check('and the level-up proposal advances through the same function',
      /to: advancedPercent\(s\.pct, s\.per_level, gained\)/.test(levelSrc)
      && (levelSrc.match(/Math\.min\(SKILL_PCT_CAP/g) || []).length === 2);
  }
}

}
