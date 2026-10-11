// A race and an occupation composed into one class: which half sets what,
// when a race demands an occupation, an occupation that supersedes its
// race, and the keys either side may hand to the other.
//
// Six sections lifted out of smoke.mjs whole on 2026-10-10. They were three
// runs there, thousands of lines apart, and are together here because they
// are one subject: `combineClasses`. They now run at the position the first
// of them held. No section reads state another one leaves.
//
// `needsOccupation` is used here and nowhere else in the suite.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { validateCharacter } from '../../../../functions/api/character-creator/_lib/validate-character.js';
import { money } from '../../../../scripts/ocr-fields-lib.mjs';
import { combineClasses, needsOccupation, parseClassMarkdown } from '../../js/parser.js';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['R.C.C. + O.C.C.', 'Race and occupation', 'A class that supersedes its race',
  'An occupation may take its P.P.E. or money over the race (BOOK-INGEST-AUDIT F111)',
  'A race may yield its P.P.E. or money to an occupation (BOOK-INGEST-AUDIT F111)',
  'A race may name the few skills a pairing keeps (BOOK-INGEST-AUDIT F114)'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

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

  // F32. The direction is the point: for a CEILING the stricter number is the
  // lower one, and the occupation's must survive a merge whose first line is
  // `out = { ...rcc }` - the half that is dropped for free if nobody writes it.
  const capRace = mk('capped-race', 'rcc', 'attribute_maximums: { PB: 14, PS: 20 }');
  const capOcc = mk('capped-occ', 'occ', 'attribute_maximums: { PB: 12, IQ: 15 }');
  const capped = combineClasses(capRace, capOcc);
  check('both sets of maximums apply, the LOWER winning',
    capped.attribute_maximums.PB === 12);
  check('and a cap only the occupation states is not dropped',
    capped.attribute_maximums.IQ === 15 && capped.attribute_maximums.PS === 20);
  check('a class with no maximums composes without gaining an empty one',
    combineClasses(mk('plain-race', 'rcc', "attribute_dice: { PS: '3d6' }"), wizard)
      .attribute_maximums === undefined);

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

  // Neither key is physiology, and until 2026-10-10 neither was named in the
  // merge at all: the race's spread answered for both, so an occupation's were
  // dropped whenever a race was chosen. Built as objects because the merge is
  // what is under test, not the parser.
  {
    const chi = { name: 'Chi', max: 10 };
    const rage = { name: 'Rage', max: 3 };
    const tracker = { id: 'monk', name: 'Monk', category: 'occ', trackable_resources: [chi], side_effects: 'Hunted.' };
    const bare = { id: 'elf', name: 'Elf', category: 'rcc' };
    const empty = { ...bare, trackable_resources: [], side_effects: '' };
    const own = { ...bare, trackable_resources: [rage, { name: 'Chi', max: 99 }], side_effects: 'Long-lived.' };
    const names = (c) => (c.trackable_resources || []).map((r) => `${r.name}:${r.max}`).join();
    check('an occupation\'s tracked resources survive a race that states none',
      names(combineClasses(bare, tracker)) === 'Chi:10' && names(combineClasses(empty, tracker)) === 'Chi:10');
    check('a race\'s own resources come first, and its row wins on a shared name',
      names(combineClasses(own, tracker)) === 'Rage:3,Chi:99');
    check('an occupation\'s side effects survive a race that states none',
      combineClasses(bare, tracker).side_effects === 'Hunted.' && combineClasses(empty, tracker).side_effects === 'Hunted.');
    check('both sides\' side effects are kept, the race\'s first',
      JSON.stringify(combineClasses(own, tracker).side_effects) === '["Long-lived.","Hunted."]');
    // EVERY KEY DECIDES (2026-10-10). Those two keys were dropped because
    // combineClasses starts from a copy of the race and nobody had to say what
    // the occupation's meant. CLASS_MERGE in js/class-keys.js is where each key
    // says, and the plain rules are run here against the merge itself - so a
    // key added without a rule fails, and so does a rule the merge does not
    // implement.
    {
      const { CLASS_KEYS, PRODUCED_KEYS, CLASS_MERGE, keysMergedBy } = await import('../../js/class-keys.js');
      const all = [...CLASS_KEYS, ...PRODUCED_KEYS];
      const RULES = ['race', 'race-first', 'occupation-first', 'concat', 'flag', 'custom'];
      const unruled = all.filter((k) => !(k in CLASS_MERGE));
      check('every class key states how a race and an occupation merge it', unruled.length === 0, unruled.join(', '));
      const strays = Object.keys(CLASS_MERGE).filter((k) => !all.includes(k));
      check('and no rule is stated for a key that is not a class key', strays.length === 0, strays.join(', '));
      const odd = Object.entries(CLASS_MERGE).filter(([, r]) => !RULES.includes(r)).map(([k, r]) => `${k}: ${r}`);
      check('every rule is one of the six', odd.length === 0, odd.join(', '));

      const race = (extra) => ({ id: 'r', name: 'R', category: 'rcc', ...extra });
      const occn = (extra) => ({ id: 'o', name: 'O', category: 'occ', ...extra });
      const merged = (r, o) => combineClasses(race(r), occn(o));
      const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
      const wrong = (rule, holds) => keysMergedBy(rule).filter((k) => {
        try { return !holds(k); } catch (e) { return true; }
      });

      // `id` and `category` are in both stubs, so they are tested as stated.
      const raceOnly = wrong('race', (k) => {
        const mine = k === 'id' ? 'r' : k === 'category' ? 'rcc' : 'the race';
        const said = merged({ [k]: mine }, { [k]: 'the occupation' })[k];
        const silent = k === 'id' || k === 'category' ? mine : merged({}, { [k]: 'the occupation' })[k];
        return same(said, mine) && (silent === undefined || silent === mine);
      });
      check('a `race` key is the race\'s, and an occupation\'s alone is not carried', raceOnly.length === 0, raceOnly.join(', '));
      const raceFirst = wrong('race-first', (k) => same(merged({ [k]: 'the race' }, { [k]: 'the occupation' })[k], 'the race')
        && same(merged({}, { [k]: 'the occupation' })[k], 'the occupation'));
      check('a `race-first` key is the race\'s where it states one, else the occupation\'s', raceFirst.length === 0, raceFirst.join(', '));
      const occFirst = wrong('occupation-first', (k) => same(merged({ [k]: 'the race' }, { [k]: 'the occupation' })[k], 'the occupation')
        && same(merged({ [k]: 'the race' }, {})[k], 'the race'));
      check('an `occupation-first` key is the occupation\'s where it states one, else the race\'s', occFirst.length === 0, occFirst.join(', '));
      const both = wrong('concat', (k) => same(merged({ [k]: ['a'] }, { [k]: ['b'] })[k], ['a', 'b'])
        && same(merged({}, { [k]: ['b'] })[k], ['b']) && same(merged({ [k]: ['a'] }, {})[k], ['a']));
      check('a `concat` key holds both lists, the race\'s first', both.length === 0, both.join(', '));
      const flags = wrong('flag', (k) => merged({}, { [k]: true })[k] === true && merged({ [k]: true }, {})[k] === true
        && merged({}, {})[k] === undefined);
      check('a `flag` key is true when either side says so', flags.length === 0, flags.join(', '));
      check('each plain rule has keys to run, so none of the five passes on nothing',
        ['race', 'race-first', 'occupation-first', 'concat', 'flag'].every((r) => keysMergedBy(r).length > 0));
      check('class-check reads the same race-first list the merge loops over',
        /const LOST_TO_RACE = keysMergedBy\('race-first'\);/.test(readFileSync(join(repoRoot, 'scripts/class-check.mjs'), 'utf8')));
    }

    check('an occupation with neither leaves the race\'s as written',
      names(combineClasses(own, { id: 'x', name: 'X', category: 'occ' })) === 'Rage:3,Chi:99'
      && combineClasses(own, { id: 'x', name: 'X', category: 'occ' }).side_effects === 'Long-lived.');
  }

  // Every caller composes unconditionally, so the no-O.C.C. paths matter most.
  check('no occupation returns the race unchanged', combineClasses(dragon, null) === dragon);
  check('no race returns the occupation', combineClasses(null, wizard) === wizard);
  check('neither returns null', combineClasses(null, null) === null);
}

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

section('An occupation may take its P.P.E. or money over the race (BOOK-INGEST-AUDIT F111)');
{
  // F111 was taken as an OPT-IN per occupation, not the global rule it
  // proposed: a census found that rule would move ~9,390 pairings' P.P.E. and
  // ~6,048 pairings' money. So the list is closed, it is read key by key, and
  // an occupation without it composes exactly as it always did.
  const doc = (cat, extra) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\n` + extra + '---\n\n## Lore\n\nx\n');
  const pools = 'ppe_base: "3d6x10"\nstarting_money: "2d6x1000"\nsdc_base: "30"\n';
  const only = 'race_restrictions: { only: ["r"] }\n';
  const both = doc('occ', pools + only + 'overrides_race: [ppe_base, starting_money]\n');
  check('overrides_race parses on an O.C.C. as a list of keys',
    both.ok && JSON.stringify(both.data.overrides_race) === '["ppe_base","starting_money"]'
    && both.warnings.length === 0, both.errors.concat(both.warnings).join('; '));
  check('and refuses any key but ppe_base and starting_money',
    !doc('occ', pools + only + 'overrides_race: [sdc_base]\n').ok
    && !doc('occ', pools + only + 'overrides_race: [ppe_base, mdc_base]\n').ok);
  check('and refuses a bare value, an empty list or a key named twice',
    !doc('occ', pools + only + 'overrides_race: ppe_base\n').ok
    && !doc('occ', pools + only + 'overrides_race: []\n').ok
    && !doc('occ', pools + only + 'overrides_race: [ppe_base, ppe_base]\n').ok);
  check('and warns on a race, where it does nothing', (() => {
    const r = doc('rcc', pools + 'overrides_race: [ppe_base]\n');
    return r.ok && r.warnings.some((w) => /overrides_race is set on something that is not an O\.C\.C\./.test(w));
  })());
  // The census is why: an occupation open to every race replaces every race's
  // figure, the ones whose book ADDS its P.P.E. to a mage's included.
  check('and warns when the occupation is open to every race', (() => {
    const r = doc('occ', pools + 'overrides_race: [ppe_base]\n');
    return r.ok && r.warnings.some((w) => /not limited by race_restrictions\.only/.test(w));
  })());

  const race = { id: 'r', category: 'rcc', ppe_base: '3d6', starting_money: '1d6x1000', sdc_base: '10' };
  const occOf = (list) => doc('occ', pools + only + (list ? `overrides_race: [${list}]\n` : '')).data;
  const none = combineClasses(race, occOf(null));
  check('without the list the race still wins P.P.E., money and S.D.C.',
    none.ppe_base === '3d6' && none.starting_money === '1d6x1000' && none.sdc_base === '10');
  const money = combineClasses(race, occOf('starting_money'));
  check('a listed key takes the occupation\'s value, and only that key',
    money.starting_money === '2d6x1000' && money.ppe_base === '3d6' && money.sdc_base === '10');
  const ppe = combineClasses(race, occOf('ppe_base, starting_money'));
  check('both listed: both are the occupation\'s, the body keys still the race\'s',
    ppe.ppe_base === '3d6x10' && ppe.starting_money === '2d6x1000' && ppe.sdc_base === '10');
  check('and a listed key the occupation does not state leaves the race\'s',
    combineClasses(race, doc('occ', 'sdc_base: "30"\n' + only + 'overrides_race: [ppe_base]\n').data).ppe_base === '3d6');
}

section('A race may yield its P.P.E. or money to an occupation (BOOK-INGEST-AUDIT F111)');
{
  // The Larhold part of F111, taken 2026-09-27 as a RACE-side key on Nate's
  // word: the Larhold Shaman is open to every race, so only a race whose own
  // book prints its P.P.E. as the non-magic figure should give it up.
  const doc = (cat, extra) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\n` + extra + '---\n\n## Lore\n\nx\n');
  const racePools = 'ppe_base: "3d6"\nstarting_money: "1d6x1000"\nsdc_base: "10"\n';
  const ok = doc('rcc', racePools + 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic, men-of-arms] }\n');
  check('yields_to_occupation parses on an R.C.C. as a map of key to occupation groups',
    ok.ok && JSON.stringify(ok.data.yields_to_occupation) === '{"ppe_base":["magic"],"starting_money":["magic","men-of-arms"]}'
    && ok.warnings.length === 0, ok.errors.concat(ok.warnings).join('; '));
  check('and is an error on an occupation, where it would read as the reverse',
    !doc('occ', racePools + 'yields_to_occupation: { ppe_base: [magic] }\n').ok);
  check('and refuses any key but ppe_base and starting_money, and a group outside the five',
    !doc('rcc', racePools + 'yields_to_occupation: { sdc_base: [magic] }\n').ok
    && !doc('rcc', racePools + 'yields_to_occupation: { ppe_base: [wizards] }\n').ok);
  check('and refuses a bare list, an empty map, an empty group list or a group named twice',
    !doc('rcc', racePools + 'yields_to_occupation: [ppe_base]\n').ok
    && !doc('rcc', racePools + 'yields_to_occupation: {}\n').ok
    && !doc('rcc', racePools + 'yields_to_occupation: { ppe_base: [] }\n').ok
    && !doc('rcc', racePools + 'yields_to_occupation: { ppe_base: [magic, magic] }\n').ok);
  check('and warns when the race does not state the key it yields', (() => {
    const r = doc('rcc', 'sdc_base: "10"\nyields_to_occupation: { ppe_base: [magic] }\n');
    return r.ok && r.warnings.some((w) => /nothing to yield/.test(w));
  })());

  const race = doc('rcc', racePools + 'yields_to_occupation: { ppe_base: [magic], starting_money: [magic] }\n').data;
  const plainRace = doc('rcc', racePools).data;
  const occ = (group) => doc('occ', `occ_group: ${group}\nppe_base: "3d6x10"\nstarting_money: "2d6x1000"\nsdc_base: "30"\n`).data;
  const mage = combineClasses(race, occ('magic'));
  check('a magic occupation takes the yielded P.P.E. and money, the body keys still the race\'s',
    mage.ppe_base === '3d6x10' && mage.starting_money === '2d6x1000' && mage.sdc_base === '10');
  const soldier = combineClasses(race, occ('men-of-arms'));
  check('an occupation of a group the race does not name gets the race\'s figures',
    soldier.ppe_base === '3d6' && soldier.starting_money === '1d6x1000');
  const unkeyed = combineClasses(plainRace, occ('magic'));
  check('and a race without the key is race-first exactly as before',
    unkeyed.ppe_base === '3d6' && unkeyed.starting_money === '1d6x1000');
  check('and a named group whose occupation states no figure leaves the race\'s',
    combineClasses(race, doc('occ', 'occ_group: magic\nsdc_base: "30"\n').data).ppe_base === '3d6');
}

section('A race may name the few skills a pairing keeps (BOOK-INGEST-AUDIT F114)');
{
  // South America 2 printed 186: "in addition to the specific O.C.C. skills,
  // all Larhold will have Riding: War Bison ... and W.P.: Archery and
  // Targeting." The union F11 chose stays the default; this is the race-side
  // opt-in for a book that keeps a few and drops the rest.
  const doc = (cat, extra) => parseClassMarkdown(
    `---\nid: t\nname: T\nsystem: rifts\nsource_book: B\ncategory: ${cat}\n` + extra + '---\n\n## Lore\n\nx\n');
  const raceSkills = 'skills:\n  occ_skills:\n'
    + '    - { name: "Riding: War Bison", base: 70, per_level: 4, note: "+20%" }\n'
    + '    - { name: "W.P. Archery", base: 0, per_level: 0 }\n'
    + '    - { name: "Detect Ambush", base: 40, per_level: 5 }\n'
    + '    - { name: "Wilderness Survival", base: 45, per_level: 5 }\n'
    + '    - { choose: 1, categories: ["Weapon Proficiencies"] }\n';
  const key = 'pairing_skills: [{ name: "Riding: War Bison", base: 50, note: "Paired." }, { name: "w.p. archery" }]\n';
  const ok = doc('rcc', key + raceSkills);
  check('pairing_skills parses on an R.C.C. as a list of the race\'s own named skills',
    ok.ok && ok.data.pairing_skills.length === 2 && ok.warnings.length === 0, ok.errors.concat(ok.warnings).join('; '));
  check('and is an error on an occupation', !doc('occ', key + raceSkills).ok);
  check('and refuses a name the race\'s own occ_skills does not hold',
    !doc('rcc', 'pairing_skills: [{ name: "Horsemanship: General" }]\n' + raceSkills).ok);
  check('and refuses an empty or bare list, a bare string, a name twice, a stray key or a non-number base',
    !doc('rcc', 'pairing_skills: []\n' + raceSkills).ok
    && !doc('rcc', 'pairing_skills: W.P. Archery\n' + raceSkills).ok
    && !doc('rcc', 'pairing_skills: ["W.P. Archery"]\n' + raceSkills).ok
    && !doc('rcc', 'pairing_skills: [{ name: "W.P. Archery" }, { name: "W.P. Archery" }]\n' + raceSkills).ok
    && !doc('rcc', 'pairing_skills: [{ name: "W.P. Archery", per_level: 3 }]\n' + raceSkills).ok
    && !doc('rcc', 'pairing_skills: [{ name: "W.P. Archery", base: "50" }]\n' + raceSkills).ok);

  const occ = doc('occ', 'skills:\n  occ_skills:\n'
    + '    - { name: "Wilderness Survival", base: 35, per_level: 5 }\n'
    + '    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5 }\n'
    + '    - { choose: 1, from: ["Language: Other"] }\n').data;
  const keyed = combineClasses(ok.data, occ).skills.occ_skills;
  const named = (list) => list.filter((s) => s.name).map((s) => `${s.name}=${s.base}`).sort().join(', ');
  check('paired, only the listed skills carry over, at the base the key gives',
    named(keyed) === 'Lore: Demons & Monsters=40, Riding: War Bison=50, W.P. Archery=0, Wilderness Survival=35',
    named(keyed));
  check('and the race\'s choice groups do not; the occupation\'s still do',
    keyed.filter((s) => !s.name).length === 1 && keyed.find((s) => !s.name).from?.[0] === 'Language: Other');
  check('and the key\'s note replaces the race\'s, its per_level stays the race\'s',
    keyed.find((s) => s.name === 'Riding: War Bison')?.note === 'Paired.'
    && keyed.find((s) => s.name === 'Riding: War Bison')?.per_level === 4);
  const plain = combineClasses(doc('rcc', raceSkills).data, occ).skills.occ_skills;
  check('and a race without the key unions its whole list exactly as before (F11)',
    named(plain) === 'Detect Ambush=40, Lore: Demons & Monsters=40, Riding: War Bison=70, W.P. Archery=0, Wilderness Survival=45'
    && plain.filter((s) => !s.name).length === 2, named(plain));
  const higher = doc('occ', 'skills:\n  occ_skills:\n    - { name: "Riding: War Bison", base: 60, per_level: 4 }\n').data;
  check('and the higher base still wins when the occupation grants the same skill',
    combineClasses(ok.data, higher).skills.occ_skills.find((s) => s.name === 'Riding: War Bison')?.base === 60);
  check('and a superseding occupation still keeps none of them',
    combineClasses(ok.data, doc('occ', 'supersedes_race: true\nsdc_base: "30"\n').data)
      .skills.occ_skills.every((s) => s.name !== 'W.P. Archery'));
}

}
