// Talents: holding one, what it brings to the sheet, buying one with
// P.P.E., the spell that burns P.P.E. the same way, the Nightbane's own
// list, and a spent power consuming the grant it was spent against.
//
// Six sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. `talentGrantsFor`, `talentPurchaseGrantsFor` and
// `loadPowerDescriptions` are used here and nowhere else in the suite.

import { readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';
import { buildProposal, startingPicksFor, talentGrantsFor, talentPurchaseGrantsFor }
  from '../../../../functions/api/character-creator/_lib/leveling.js';
import { powerGrantsFor, remainingPowerGrants, resolvePowerPicks, loadPowerDescriptions }
  from '../../../../functions/api/character-creator/_lib/power-picks.js';
import { validateCharacter } from '../../../../functions/api/character-creator/_lib/validate-character.js';
import { CATALOGS } from '../../js/catalog-fields.js';
import { evalDice, diceBounds } from '../../js/dice.js';
import { combineClasses, parseClassMarkdown } from '../../js/parser.js';
import { appDir, repoRoot, check, section, appPath, wantSection } from '../harness.mjs';

const SECTIONS = ['A character holding a Talent can be validated',
  'A held Talent brings its description to the sheet', 'Talent purchases (BOOK-INGEST-AUDIT F101)',
  'A spell can burn P.P.E. out of the caster\'s base (BOOK-INGEST-AUDIT F101)',
  'Nightbane Talents (BOOK-INGEST-AUDIT F76)', 'A spent power consumes the grant it was spent against'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

section('A character holding a Talent can be validated');
{
  // The validator's per-kind list sets were a literal of THREE -
  // { spell, psionic, super } - when BOOK-INGEST-AUDIT F76 added 'talent' to the
  // kinds it loops over. So `listNames.talent.has` read off undefined and THREW
  // for any character holding a chosen Talent once a power catalog was loaded,
  // which the create route always loads when the character names a power: a
  // Nightbane with a Talent could not be saved, and the route answered 500.
  //
  // It also meant F76's Talent level gate below it had never once run.
  const cls = { talents: { talents_starting: 1, talents_schedule: [{ level: 4, count: 1 }] } };
  const row = (name, min) => ({ name, tier: 'common', acquire_ppe: 6, ppe: 4,
    system: 'nightbane', min_character_level: min });
  const powerCatalog = { spell: new Map(), psionic: new Map(), super: new Map(),
    talent: new Map([['soul shield', row('Soul Shield', null)], ['anti-arcane', row('Anti-Arcane', 5)]]) };
  const run = (powers, level = 1) => {
    try {
      return validateCharacter({ character: { level }, cls, skills: [], abilities: [], attributes: {},
        catalog: null, powers, pools: {}, system: 'nightbane', powerCatalog }).violations.map((v) => v.rule);
    } catch (e) { return 'THREW: ' + e.message; }
  };
  const ok = run([{ type: 'talent', name: 'Soul Shield' }]);
  check('a character holding a Talent validates without throwing', Array.isArray(ok), String(ok));
  check('and a legal one raises nothing', Array.isArray(ok) && ok.length === 0, JSON.stringify(ok));
  const early = run([{ type: 'talent', name: 'Anti-Arcane' }]);
  check('a fifth-level Talent at level one is refused by its level gate',
    Array.isArray(early) && early.includes('power_min_level'), JSON.stringify(early));
  check('and is allowed at level five', JSON.stringify(run([{ type: 'talent', name: 'Anti-Arcane' }], 5)) === '[]',
    JSON.stringify(run([{ type: 'talent', name: 'Anti-Arcane' }], 5)));
}

section('A held Talent brings its description to the sheet');
{
  // loadPowerDescriptions maps a power's type to its catalog, and the map named
  // spell, psionic and super. A Talent fell through to `spells`, matched nothing,
  // and the sheet showed no description - the same missing-kind shape as the
  // validator's list sets above. Run against schema.sql in memory.
  const mem = new DatabaseSync(':memory:');
  mem.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'));
  mem.prepare('INSERT INTO talents (name, tier, acquire_ppe, ppe, system, description) VALUES (?,?,?,?,?,?)')
    .run('Soul Shield', 'common', 6, 4, 'nightbane', 'A shield of dark energy.');
  mem.prepare('INSERT INTO spells (name, level, ppe, description) VALUES (?,?,?,?)')
    .run('Blinding Flash', 1, 1, 'A flash of light.');
  const env = { DB: { prepare: (sql) => ({
    bind: (...b) => ({ all: async () => ({ results: mem.prepare(sql).all(...b) }) }),
    all: async () => ({ results: mem.prepare(sql).all() }),
  }) } };
  const out = await loadPowerDescriptions(env, [
    { type: 'talent', name: 'Soul Shield' }, { type: 'spell', name: 'Blinding Flash' }]);
  mem.close();
  check('a Talent held on the sheet gets its description', out['soul shield'] === 'A shield of dark energy.',
    JSON.stringify(out));
  check('and a spell still gets its own', out['blinding flash'] === 'A flash of light.', JSON.stringify(out));
}

section('Talent purchases (BOOK-INGEST-AUDIT F101)');
{
  // Printed 106: a Nightbane may BUY two Talents at level one and at every level
  // after, each for a permanent expenditure of P.P.E. The allowance banks as its
  // own grant kind, and a purchase is charged against ppe_max - ppe_base_spent.
  const md = (...extra) => parseClassMarkdown(['---', 'id: nb', 'name: Nightbane',
    'system: nightbane', 'source_book: Nightbane RPG p.106', 'category: rcc',
    'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"',
    'talents:', ...extra, '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  const nb = md('  talents_starting: 1', '  talents_purchases_per_level: 2');
  check('talents_purchases_per_level parses', nb.ok && nb.warnings.length === 0, [...nb.errors, ...nb.warnings].join('; '));
  check('and must be a whole number', !md('  talents_purchases_per_level: -1').ok);
  check('and alone is a block that grants something', md('  talents_purchases_per_level: 2').warnings.length === 0,
    md('  talents_purchases_per_level: 2').warnings.join('; '));

  const at = (from, to) => JSON.stringify(talentPurchaseGrantsFor(nb.data, from, to).grants.map((g) => [g.level, g.count]));
  check('creation, asked from 0, includes level one', at(0, 1) === '[[1,2]]', at(0, 1));
  check('a level-up collects two per level crossed and not the level left', at(3, 5) === '[[4,2],[5,2]]', at(3, 5));
  check('a class stating no purchases buys nothing, and is not unknown',
    JSON.stringify(talentPurchaseGrantsFor({ talents: { talents_starting: 1 } }, 0, 5)) === '{"applicable":false,"unknown":false,"grants":[],"total":0}');
  check('powerGrantsFor banks them as their own kind, beside the free Talent at level four',
    JSON.stringify(powerGrantsFor({ talents: { talents_purchases_per_level: 2, talents_schedule: [{ level: 4, count: 1 }] } }, 3, 4)
      .map((g) => [g.kind, g.level, g.count])) === '[["talent",4,1],["talent_purchase",4,2]]');
  check('the level-up proposal carries the purchases',
    buildProposal({ level: 3, hp_max: null, skills: [] }, nb.data, 4).talent_purchase_picks?.total === 2);

  // The charge, through the real resolver on schema.sql in memory.
  const mem = new DatabaseSync(':memory:');
  mem.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'));
  const ins = mem.prepare('INSERT INTO talents (name, tier, acquire_ppe, ppe, min_character_level, system) VALUES (?,?,?,?,?,?)');
  ins.run('Small', 'common', 10, 2, null, 'nightbane');
  ins.run('Big', 'common', 25, 2, null, 'nightbane');
  const env = { DB: { prepare: (sql) => ({
    bind: (...b) => ({ all: async () => ({ results: mem.prepare(sql).all(...b) }) }),
    all: async () => ({ results: mem.prepare(sql).all() }),
  }), batch: async (s) => Promise.all(s.map((x) => x.all())) } };
  const grants = [{ kind: 'talent_purchase', level: 1, slot: 0, count: 2 }, { kind: 'talent', level: 1, slot: 0, count: 1 }];
  const buy = (names, ppeAvailable, kind = 'talent_purchase') => resolvePowerPicks(env, {
    picks: names.map((name) => ({ kind, name, granted_at_level: 1 })),
    grants, existingPowers: [], system: 'nightbane', ppeAvailable });
  const one = await buy(['Small'], 30);
  check('a purchase the base covers resolves and reports its price',
    one.errors.length === 0 && one.ppeSpent === 10 && one.spent.get('talent_purchase:1:0') === 1, JSON.stringify(one.errors));
  check('and yields a Talent marked as bought, with its price',
    one.powers[0]?.type === 'talent' && one.powers[0]?.purchased === true && one.powers[0]?.acquire_cost === 10,
    JSON.stringify(one.powers[0]));
  const both = await buy(['Small', 'Big'], 30);
  check('two purchases that each fit and together do not are refused',
    both.errors.some((e) => /35 permanent P\.P\.E\..*30 left/.test(e)), both.errors.join('; '));
  const none = await buy(['Small'], null);
  check('a character with no P.P.E. can buy nothing', none.errors.length === 1, none.errors.join('; '));
  const asFree = await buy(['Small'], 30, 'talent');
  check('a free Talent costs nothing and is not marked bought',
    asFree.errors.length === 0 && asFree.ppeSpent === 0 && !asFree.powers[0]?.purchased, JSON.stringify(asFree));
  mem.close();

  // The validator counts bought Talents apart from free ones.
  const row = (name, min) => ({ name, tier: 'common', acquire_ppe: 6, ppe: 4, system: 'nightbane', min_character_level: min });
  const powerCatalog = { spell: new Map(), psionic: new Map(), super: new Map(),
    talent: new Map(['A', 'B', 'C', 'D'].map((n) => [n.toLowerCase(), row(n, null)]).concat([['e', row('E', 5)]])) };
  const T = (name, purchased) => ({ type: 'talent', name, ...(purchased ? { purchased: true } : {}) });
  const rules = (powers, level = 1, cls = nb.data) => validateCharacter({ character: { level }, cls, skills: [],
    abilities: [], attributes: {}, catalog: null, powers, pools: {}, system: 'nightbane', powerCatalog })
    .violations.map((v) => v.rule + ':' + (v.kind || ''));
  check('one free and two bought Talents at level one is legal',
    JSON.stringify(rules([T('A'), T('B', 1), T('C', 1)])) === '[]', JSON.stringify(rules([T('A'), T('B', 1), T('C', 1)])));
  check('a third bought Talent at level one is over the purchase allowance',
    rules([T('A'), T('B', 1), T('C', 1), T('D', 1)]).includes('power_count:talent_purchase'));
  check('and bought ones do not use up the free pick', !rules([T('A'), T('B', 1)]).includes('power_count:talent'));
  check('a bought Talent still passes its level gate', rules([T('E', 1)]).includes('power_min_level:talent_purchase'));
  check('a class with no purchase allowance may hold no bought Talent',
    rules([T('B', 1)], 1, { talents: { talents_starting: 1 } }).includes('power_count:talent_purchase'));
}

section('A spell can burn P.P.E. out of the caster\'s base (BOOK-INGEST-AUDIT F101)');
{
  // Migration 067 gives `spells` a `ppe_permanent` dice expression; a data script
  // fills six; a route rolls it into ppe_base_spent; the sheet offers a burn
  // button beside a spell that has one. The NUMBER is automated and the
  // condition is not - Nate's answer, 2026-09-16.
  const spellCfg = CATALOGS.spells.fields.find((f) => f.name === 'ppe_permanent');
  check('the spell catalog declares ppe_permanent, so the editor can set it', !!spellCfg);
  const catalogsSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'catalogs.js'), 'utf8');
  check('and the boot catalog selects it, so the sheet can read it',
    /SELECT [^']*ppe_permanent[^']* FROM spells/.test(catalogsSrc));

  // Every value the data script writes is a dice expression the roller reads. A
  // value that is not would be refused by the route, never silently rolled as 0.
  const script = readFileSync(join(appDir, 'db', 'zzzzzzzzzzzzz-f101-spell-ppe-permanent.sql'), 'utf8');
  const written = [...script.matchAll(/SET ppe_permanent = '([^']+)'\s+WHERE name = '([^']+)'/g)]
    .map((m) => [m[2], m[1]]);
  check('the data script writes six burns', written.length === 6, JSON.stringify(written));
  check('and every one is dice the roller can read', written.every(([, v]) => diceBounds(v)),
    JSON.stringify(written.filter(([, v]) => !diceBounds(v))));

  // THE SERVER ROLLS. ppe_base_spent is not player-editable (065), so the route
  // must take only a spell's NAME - an amount from the client would be a way to
  // set the base to anything.
  const route = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', 'characters',
    '[id]', 'ppe-burn.js'), 'utf8').replace(/\/\/.*$/gm, '');
  check('the burn route rolls the catalog dice itself', /evalDice\(row\.ppe_permanent\)/.test(route));
  check('and reads nothing from the request but the spell name',
    (route.match(/\bb\??\.(\w+)/g) || []).every((m) => /name$/.test(m)), (route.match(/\bb\??\.(\w+)/g) || []).join(', '));
  check('and only for a spell the character holds', /type === 'spell'/.test(route) && /not a spell this character knows/.test(route));

  const sheetSrc = readFileSync(appPath('sheet.js'), 'utf8');
  const burnFn = sheetSrc.slice(sheetSrc.indexOf('async function burnPpe('), sheetSrc.indexOf('async function usePower('));
  check('the sheet posts only the spell name to the burn route', /jsonReq\('POST', \{ name: p\.name \}\)/.test(burnFn), burnFn.slice(0, 200));
  check('and asks before burning, it being permanent', /confirm\(/.test(burnFn));
  const useFn = sheetSrc.slice(sheetSrc.indexOf('async function usePower('), sheetSrc.indexOf('async function usePower(') + 3000);
  check('and the use button never burns - the two are separate presses', !/ppe-burn|burnPpe/.test(useFn));
  // The power row is a three-column grid, so a FOURTH child wrapped onto its own line and
  // stretched across the name column - measured at 467px on a desktop sheet before this.
  // The two buttons share the last cell instead.
  check('a row with a burn keeps both buttons in one grid cell',
    /burnBtn \? `<span class="power-btns">\$\{useBtn\}\$\{burnBtn\}<\/span>` : useBtn/.test(sheetSrc)
    && /\.power-row \.power-btns \{[^}]*display: inline-flex/.test(readFileSync(join(appDir, 'styles.css'), 'utf8')));
}

section('Nightbane Talents (BOOK-INGEST-AUDIT F76)');
{
  // The book's own rule, printed 106 under "Acquiring Talents": one Talent free
  // at first level, and one more at levels four, seven, ten and twelve. That is
  // a LEVEL SCHEDULE, which is what separates this from super abilities - the
  // Revised core grants every super ability at creation and js/leveling.js
  // refuses a per-level one because a banked grant would need a TIER column.
  const md = (...extra) => parseClassMarkdown(['---', 'id: nb', 'name: Nightbane',
    'system: nightbane', 'source_book: Nightbane RPG p.106', 'category: rcc',
    'hit_points_base: "P.E. + 1D6 per level"', 'sdc_base: "3D6"',
    'talents:', ...extra, '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));

  const nb = md('  talents_starting: 1', '  tiers_allowed: ["common"]',
    '  talents_schedule:', '    - { level: 4, count: 1 }', '    - { level: 7, count: 1 }',
    '    - { level: 10, count: 1 }', '    - { level: 12, count: 1 }');
  check('a talents block parses with a schedule', nb.ok, nb.errors.join('; '));
  check('and warns about nothing', nb.warnings.length === 0, nb.warnings.join('; '));

  const start = startingPicksFor(nb.data, 'talent');
  check('one free Talent at creation, gated to the common tier',
    start.total === 1 && start.groups.length === 1
    && String(start.groups[0].tiers) === 'common', JSON.stringify(start));

  const at = (from, to) => talentGrantsFor(nb.data, from, to).grants.map((g) => g.level).join(',');
  check('the free Talents arrive at 4, 7, 10 and 12', at(1, 12) === '4,7,10,12', at(1, 12));
  check('and a climb collects only the thresholds it passed', at(1, 5) === '4'
    && at(4, 10) === '7,10' && at(12, 15) === '', `${at(1, 5)} / ${at(4, 10)} / ${at(12, 15)}`);

  // The grant carries NO restriction, which is the whole reason the CHECK could
  // be widened without a new column. A talent grant that came back with
  // categories or a spell cap would be one this table cannot store.
  const banked = powerGrantsFor(nb.data, 1, 7).filter((g) => g.kind === 'talent');
  check('two talent grants bank between levels 1 and 7', banked.length === 2);
  check('and every restriction column on them is null',
    banked.every((g) => g.spell_levels === null && g.categories === null
      && g.traditions === null && g.from === null), JSON.stringify(banked));

  // A per-level grant is REFUSED for super abilities and ALLOWED here, and the
  // asymmetry is deliberate - storage, not taste. Pinned so that refusal cannot
  // quietly be copied onto talents by someone tidying.
  const superPerLevel = parseClassMarkdown(['---', 'id: s', 'name: S', 'system: heroes-unlimited',
    'source_book: b', 'category: rcc', 'hit_points_base: "P.E. + 1D6 per level"',
    'sdc_base: "3D6"', 'super_abilities:', '  abilities_per_level: 1',
    '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10)));
  check('a super ability still refuses a per-level grant',
    superPerLevel.errors.some((e) => /abilities_per_level is not supported/.test(e)),
    superPerLevel.errors.join('; '));

  // Validation of the block itself.
  const bad = md('  talents_starting: 1', '  tiers_allowed: ["major"]');
  check('a tier the book does not print is refused',
    bad.errors.some((e) => /tiers_allowed must be common or elite/.test(e)), bad.errors.join('; '));
  const badSched = md('  talents_schedule:', '    - { level: 0, count: 1 }');
  check('a schedule entry below level 1 is refused',
    badSched.errors.some((e) => /talents_schedule entries need a whole level/.test(e)));
  const empty = md('  tiers_allowed: ["common"]');
  check('a block that grants nothing warns rather than storing silently',
    empty.warnings.some((w) => /grants no talents/.test(w)), empty.warnings.join('; '));

  // combineClasses: a race and an occupation that BOTH state talents ADD, the
  // way super abilities do - F14's lesson, which cost the catalog a whole magic
  // block when the fold was `occ.magic || rcc.magic`.
  const rcc = md('  talents_starting: 1', '  talents_schedule:', '    - { level: 4, count: 1 }').data;
  const occ = parseClassMarkdown(['---', 'id: o', 'name: O', 'system: nightbane',
    'source_book: b', 'category: occ', 'hit_points_base: "P.E. + 1D6 per level"',
    'sdc_base: "3D6"', 'talents:', '  talents_starting: 2', '  talents_schedule:',
    '    - { level: 4, count: 1 }', '---', '', '## Lore', '', 'x', ''].join(String.fromCharCode(10))).data;
  const both = combineClasses(rcc, occ);
  check('two talent blocks ADD their starting picks', both.talents.talents_starting === 3,
    JSON.stringify(both.talents));
  check('and their schedules CONCATENATE rather than dedupe, so level 4 grants two',
    talentGrantsFor(both, 1, 4).grants.reduce((n, g) => n + g.count, 0) === 2,
    JSON.stringify(talentGrantsFor(both, 1, 4).grants));

  // An explicit talents_per_level: 0 is "none after the first" (the Nightbane
  // Sorcerer, printed 118), not a class that forgot to say - and it must stay
  // that way through a pairing with a race whose block states no schedule.
  const none = md('  talents_starting: 1', '  talents_per_level: 0').data;
  const noneGrant = talentGrantsFor(none, 1, 5);
  check('an explicit talents_per_level: 0 is known and empty, not unknown',
    noneGrant.applicable && !noneGrant.unknown && noneGrant.total === 0, JSON.stringify(noneGrant));
  const silent = md('  talents_starting: 1').data;
  check('while a block stating no per-level rule at all is still unknown',
    talentGrantsFor(silent, 1, 5).unknown === true, JSON.stringify(talentGrantsFor(silent, 1, 5)));
  const racePurchases = md('  talents_purchases_per_level: 2').data;
  const paired = combineClasses(racePurchases, none);
  check('and the explicit 0 survives a pairing with a race that states none',
    talentGrantsFor(paired, 1, 5).unknown === false, JSON.stringify(paired.talents));
}

section('A spent power consumes the grant it was spent against');
{
  // resolvePowerPicks RETURNS the key of what it consumed, and the two routes that
  // bank and spend picks use it instead of rebuilding one.
  //
  // They used to rebuild it, as `${p.type === 'psionic' ? 'psionic' : 'spell'}` -
  // a two-way guess at a three-way answer. A spent TALENT was keyed `spell` and
  // matched no `talent` row. At level-up the Talent was taken AND its grant
  // banked again in full; in the spend endpoint a banked Talent row was never
  // consumed and could be spent over and over. Reproduced through the real
  // remainingPowerGrants before the fix. Found while starting
  // BOOK-INGEST-AUDIT F101's Talent purchases, which would have built on it.
  const mem = new DatabaseSync(':memory:');
  mem.exec(readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8'));
  mem.prepare('INSERT INTO talents (name, tier, acquire_ppe, ppe, system) VALUES (?,?,?,?,?)')
    .run('Soul Shield', 'common', 6, 4, 'nightbane');
  mem.prepare('INSERT INTO spells (name, level, ppe, system) VALUES (?,?,?,?)').run('Blinding Flash', 1, 1, null);
  mem.prepare('INSERT INTO psionic_powers (name, category, isp, system) VALUES (?,?,?,?)')
    .run('Sixth Sense', 'Sensitive', 2, null);
  const wrap = (sql) => ({
    bind: (...b) => ({ all: async () => ({ results: mem.prepare(sql).all(...b) }) }),
    all: async () => ({ results: mem.prepare(sql).all() }),
  });
  const env = { DB: { prepare: wrap, batch: async (s) => Promise.all(s.map((x) => x.all())) } };
  const grants = [
    { kind: 'talent', level: 4, slot: 0, count: 1 },
    { kind: 'spell', level: 4, slot: 0, count: 1, spell_levels: null },
    { kind: 'psionic', level: 4, slot: 0, count: 1, categories: null },
  ];
  const r = await resolvePowerPicks(env, {
    picks: [
      { kind: 'talent', name: 'Soul Shield', granted_at_level: 4 },
      { kind: 'spell', name: 'Blinding Flash', granted_at_level: 4 },
      { kind: 'psionic', name: 'Sixth Sense', granted_at_level: 4 },
    ],
    grants, existingPowers: [], system: null,
  });
  mem.close();
  check('one pick of each kind resolves', r.errors.length === 0 && r.powers.length === 3, r.errors.join('; '));
  check('and the key of what was consumed comes back with it', r.spent instanceof Map);
  check('a Talent is consumed from the TALENT grant, not a spell one',
    // Were the Talent keyed `spell`, spell:4:0 would read 2 and talent:4:0 nothing.
    r.spent?.get('talent:4:0') === 1 && r.spent?.get('spell:4:0') === 1,
    JSON.stringify([...(r.spent || [])]));
  const left = remainingPowerGrants(grants, r.spent || new Map());
  check('so nothing is left to bank after one pick of each kind - no double grant',
    left.reduce((n, g) => n + g.count, 0) === 0, JSON.stringify(left));
  check('and nothing about the consumption leaks onto the stored powers',
    r.powers.every((p) => !('spent' in p)));

  // Neither route may go back to rebuilding the key from the power's type.
  const route = (f) => readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
    'characters', '[id]', f), 'utf8').replace(/\/\/.*$/gm, '');
  for (const f of ['power-picks.js', 'level-confirm.js']) {
    check(`${f} does not rebuild a spent key from the power's type`,
      !/'psionic'\s*\?\s*'psionic'\s*:\s*'spell'/.test(route(f)));
    check(`and uses the one resolvePowerPicks returns`, /resolved\.spent|pickedSpent/.test(route(f)));
  }
}

}
