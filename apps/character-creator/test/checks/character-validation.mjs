// What the server re-checks about a character: the rules the wizard
// enforces on a saved sheet, and the ones it enforces on a new one.
//
// Two sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. This is the cut smoke.mjs's header named as its next candidate.
// No binding is exclusive to it; the reason is the subject and the size.
//
// `rel`, `legal` and `vio` are declared here and the names turn up in a dozen
// other sections, which is what made this look like a cut that needed a
// shared fixture. Every one of those is a local of the same name. Nothing
// outside these two sections reads the ones declared here.

import { relatedAllowance, validateCharacter }
  from '../../../../functions/api/character-creator/_lib/validate-character.js';
import { evalDice, rollAttribute, poolFormulaBounds, diceBounds, attributeCeiling, isAttributeExpr,
         isAbsentAttribute }
  from '../../js/dice.js';
import { check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Character validation', 'Creation validation'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

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
// BOOK-INGEST-AUDIT.md F24. A psionic band is picked as an ability and may
// state the related-skill count, so the SERVER has to read it too - the wizard
// offering zero while this endpoint still accepted four is exactly the
// client/server disagreement RETRO-AUDIT R18 was filed about.
const bandCls = {
  ...vCls,
  special_abilities: [
    { choose: 1, from: ['Major Gift', 'Master Gift'] },
    { name: 'Major Gift' },
    { name: 'Master Gift', related_skills_count: 0 },
  ],
};
check('an ability stating a related count is enforced server-side',
  vio({ cls: bandCls, abilities: ['Master Gift'] }).includes('related_count'));
check('and a band stating none leaves the class allowance alone',
  !vio({ cls: bandCls, abilities: ['Major Gift'] }).includes('related_count'));
check('a character holding no abilities is unaffected either way',
  !vio({ cls: bandCls }).includes('related_count'));

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
  // BOOK-INGEST-AUDIT F65: the same at level-up. A list on a schedule entry
  // replaces that grant's categories, so a listed Super power fills it under a
  // Sensitive gate - the Healing Shaman's eight, levels 3-12 - and an unlisted
  // Healing power cannot. Nothing in the validator changed: it reads the grants
  // powerGrantsFor builds, which used to drop the list.
  check('a level-up grant\'s named list replaces its category gate, both ways', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 1, categories_allowed: ['Sensitive'],
      powers_schedule: [{ level: 3, count: 1, from: ['Crush'] }] } };
    const at3 = (names) => validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat,
      character: { level: 3 }, powers: names.map(psi) });
    const on = at3(['See', 'Crush']);
    const off = at3(['See', 'Mend']);
    return on.violations.length === 0 && off.violations.some((v) => v.rule === 'power_category');
  })());
  // BOOK-INGEST-AUDIT F69: a category entry may be an OBJECT narrowing what it
  // admits (F16), and the allowed set was built by String()-ing each entry, so
  // an object became the literal "[object object]", no power's category ever
  // matched, and the CREATE endpoint answered 422. Three live classes could not
  // be saved with the starting psionics their own books grant.
  check('an object category gate admits a power in it, and still refuses the one it excepts', (() => {
    const pcat2 = { spell: pcat.spell, psionic: new Map([...pcat.psionic,
      ['sense', { name: 'Sense', category: 'Sensitive', isp: 2, system: null }]]) };
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 1,
      powers_starting_groups: [{ count: 1, categories: [{ name: 'Sensitive', except: ['See'] }] }] } };
    const run = (n) => validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat2, powers: [psi(n)] });
    return run('Sense').violations.length === 0
      && run('See').violations.some((v) => v.rule === 'power_category');
  })());
  check('and a refusal names the category rather than [object Object]', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 1,
      powers_starting_groups: [{ count: 1, categories: [{ name: 'Sensitive', except: ['See'] }] }] } };
    const v = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Mend')] })
      .violations.find((x) => x.rule === 'power_category');
    return !!v && v.message.includes('Sensitive') && !v.message.toLowerCase().includes('[object');
  })());
  // A string gate has to behave exactly as it did - the whole point of using
  // the shared matcher rather than a second rule.
  check('a plain string gate is unchanged by that', (() => {
    const cls2 = { ...vCls, psionics: { type: 'major', powers_starting: 2, categories_allowed: ['Sensitive', 'Healing'] } };
    const ok = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('See'), psi('Mend')] });
    const no = validateCharacter({ ...legal, cls: cls2, powerCatalog: pcat, powers: [psi('Crush')] });
    return ok.violations.length === 0 && no.violations.some((v) => v.rule === 'power_category');
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

  // A CLASS's own cap on an attribute (F32), advisory for the same reason and
  // by the same decision - AUDIT.md F2's follow-up made pools a hard cap for
  // non-GM creators and deliberately left every attribute check a warning.
  // The posture is the half of this worth pinning: the character still saves.
  const capCls = { ...vCls, attribute_maximums: { PB: 12 } };
  check('an attribute above the class maximum warns and never blocks', (() => {
    const r = validateCharacter({ ...legal, cls: capCls, attributes: { ME: 14, PB: 18 } });
    return r.violations.length === 0
        && r.warnings.some((w) => w.rule === 'attribute_above_class_maximum'
             && w.attribute === 'PB' && w.maximum === 12 && w.value === 18);
  })());
  check('a value exactly at the cap is not flagged',
    !validateCharacter({ ...legal, cls: capCls, attributes: { ME: 14, PB: 12 } })
      .warnings.some((w) => w.rule === 'attribute_above_class_maximum'));
  check('an attribute the character does not have cannot break the cap',
    !validateCharacter({ ...legal, cls: capCls, attributes: { ME: 14 } })
      .warnings.some((w) => w.rule === 'attribute_above_class_maximum'));
  check('the cap warning names the attribute and the number',
    /PB/.test(validateCharacter({ ...legal, cls: capCls, attributes: { ME: 14, PB: 18 } })
      .warnings.find((w) => w.rule === 'attribute_above_class_maximum').message));

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

}
