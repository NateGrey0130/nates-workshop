// Everything that asks about the CATALOG and the RULES it encodes: the core
// pools every character gets, the Hand to Hand and Weapon Proficiency level
// schedules, the spell descriptions, the gear rows that were the wrong shape,
// and where web-sourced values came from.
//
// Split out of environment.mjs, whose own header promised "everything that asks
// about the ENVIRONMENT rather than about the rules" and had stopped being true:
// six sections of book data had grown inside a file about D1, migrations and
// documentation. Nothing crossed between the two halves, which is why the cut
// is clean — the rules half referenced no variable the environment half
// declared.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { statements } from '../../../../scripts/sql-statements.mjs';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';
import { composeClass, CORE_SDC_BY_CLASS } from '../../js/compose.js';
import { bonusesFromSkills, levelGrants, skillLevelNotes, skillConditionalBonuses } from '../../js/parser.js';
import { rollPoolFormula } from '../../js/dice.js';

// Declared once for the same skip-the-module contract as environment.mjs —
// see the note there for why drift in either direction fails loud.
const SECTIONS = ['Core pools (p.18)', 'Hand to Hand level schedules (p.347-349)',
  'Weapon Proficiencies (p.326-329)', 'Spell descriptions',
  'Structural gear rows', 'Provenance of web-sourced rows'];

export function run() {
if (!SECTIONS.some(wantSection)) return;

// ---------- 1. core pools ----------
section('Core pools (p.18)');

// p.18 states hit points and S.D.C. once, for every character, rather than per
// class, so most class pages print neither and compose.js supplies them.
//
// The S.D.C. half has to know whether the class is a man of arms, and nothing
// in the class data records that, so the grouping lives in CORE_SDC_BY_CLASS.
// A class that states no formula and is missing from that table gets no S.D.C.
// at all — which is silent, looks exactly like the two Priests of Light that
// reached production with hp_max NULL, and nothing else would catch it.
const classFiles = readdirSync(join(appDir, 'db'))
  .filter((f) => /^add-.*-class\.sql$/.test(f)).sort();
check('class definition scripts found', classFiles.length > 0, 'no add-*-class.sql in db/');

// Read off the embedded markdown rather than the parsed class: the point is
// what the BOOK page states, and a key is stated only if the frontmatter has
// it. Anchored so prose mentioning a key by name is not mistaken for one — the
// Priest of Light's extraction note names both keys in a sentence.
const states = (sql, key) => new RegExp('^\\s*' + key + ':', 'm').test(sql);
const classes = classFiles.map((f) => {
  const sql = readFileSync(join(appDir, 'db', f), 'utf8');
  const id = sql.match(/^id: ([a-z0-9-]+)/m)?.[1] ?? null;
  return { f, id, hp: states(sql, 'hit_points_base'), sdc: states(sql, 'sdc_base'), mdc: states(sql, 'mdc_base') };
});
check('every class script declares an id', classes.every((c) => c.id), 
  classes.filter((c) => !c.id).map((c) => c.f).join(', '));

// An M.D.C. being tracks M.D.C. instead, so its silence is a statement.
const needsSdc = classes.filter((c) => c.id && !c.sdc && !c.mdc);
const unclassified = needsSdc.filter((c) => !CORE_SDC_BY_CLASS[c.id]);
check('every class without an S.D.C. formula is classified as men-of-arms or not',
  unclassified.length === 0,
  'missing from CORE_SDC_BY_CLASS: ' + unclassified.map((c) => c.id).join(', ')
    + ' — these characters would be saved with sdc_max NULL');

// The reverse: an entry for a class that states its own formula is dead, and
// an entry for a class that does not exist is a typo that silently does nothing.
const byId = new Map(classes.filter((c) => c.id).map((c) => [c.id, c]));
const stale = Object.keys(CORE_SDC_BY_CLASS).filter((id) => byId.get(id)?.sdc);
const unknown = Object.keys(CORE_SDC_BY_CLASS).filter((id) => !byId.has(id));
check('no S.D.C. grouping overrides a class that states its own', stale.length === 0,
  stale.join(', ') + ' — the class page prints a formula, so the entry never applies');
check('every S.D.C. grouping names a class that exists', unknown.length === 0,
  unknown.join(', ') + ' — no add-*-class.sql defines this id');

// p.18 gives exactly two values. Anything else is a per-class formula wearing
// the core rule's clothes and belongs in the class markdown instead.
const badDice = Object.entries(CORE_SDC_BY_CLASS).filter(([, d]) => d !== '3D6' && d !== '1D6');
check('every S.D.C. grouping rolls 3D6 or 1D6', badDice.length === 0,
  badDice.map(([id, d]) => id + '=' + d).join(', '));

// The defaults have to survive composition, not merely exist as constants.
//
// Only over the classes that state nothing. The synthetic class carries no
// formulas, so a class whose own page prints one would look like a gap here
// when it is exactly the case the default is meant to stay out of.
const mk = (id, extra = {}) => ({ id, name: id, system: 'rifts', category: 'occ', ...extra });
const composedFor = (list) => list.map((c) => composeClass({ rcc: mk(c.id) }));
const noHp = composedFor(classes.filter((c) => c.id && !c.hp && !c.mdc));
check('every class stating no hit points composes with the core formula',
  noHp.length > 0 && noHp.every((c) => c.hit_points_base),
  noHp.filter((c) => !c.hit_points_base).map((c) => c.id).join(', '));
const noSdc = composedFor(needsSdc);
check('every class stating no S.D.C. composes with a core formula',
  noSdc.length > 0 && noSdc.every((c) => c.sdc_base),
  noSdc.filter((c) => !c.sdc_base).map((c) => c.id).join(', '));

// An M.D.C. being must not pick up hit points it does not have.
const mdcComposed = composeClass({ rcc: mk('dragon-hatchling', { mdc_base: '1D6x10' }) });
check('an M.D.C. class is left alone', !mdcComposed.hit_points_base && !mdcComposed.sdc_base,
  'hp=' + mdcComposed.hit_points_base + ' sdc=' + mdcComposed.sdc_base);

// A class that states its own keeps it — the default fills gaps, never overrides.
const ownFormula = composeClass({ rcc: mk('burster', { hit_points_base: 'P.E. x 2 plus 2D6 per level of experience' }) });
check('a stated hit point formula is never overridden',
  ownFormula.hit_points_base === 'P.E. x 2 plus 2D6 per level of experience', ownFormula.hit_points_base);

// What makes a character a man of arms is the job, not the race.
const dragonMerc = composeClass({ rcc: mk('chiang-ku-dragon'), occ: mk('merc-soldier') });
check('S.D.C. follows the occupation, not the race', dragonMerc.sdc_base === '3D6', dragonMerc.sdc_base);

// ---------- 1b. A racial S.D.C. is a BONUS, never sdc_base ----------
//
// Printed 18: "Some non-human races and O.C.C.s also get special S.D.C.
// bonuses. All S.D.C. points/bonuses are cumulative." Ten of the fourteen
// Palladium Fantasy player races state a number, and every page states it the
// same way - "40 plus those gained from O.C.C.s and physical skills".
//
// Written as sdc_base it is SILENTLY WRONG, because combineClasses gives the
// race's pool precedence: a Troll Knight would carry 40 instead of 40 + 3D6,
// and nothing on the sheet would look unusual. This check exists so that
// "fixing" a race to state its S.D.C. the obvious way fails loudly.
const PF_RACES = ['human', 'elf', 'dwarf', 'gnome', 'troglodyte', 'kobold', 'goblin',
  'hob-goblin', 'orc', 'ogre', 'troll', 'changeling', 'wolfen', 'coyle'];
{
  const present = PF_RACES.filter((id) => byId.has(id));
  check('the fourteen Palladium player races are all defined by a data script',
    present.length === PF_RACES.length,
    'missing: ' + PF_RACES.filter((id) => !byId.has(id)).join(', '));

  const statesSdc = present.filter((id) => byId.get(id).sdc);
  check('no Palladium race states sdc_base', statesSdc.length === 0,
    statesSdc.join(', ') + ' - a racial S.D.C. is a pool BONUS; sdc_base would '
      + 'replace the occupation roll instead of adding to it');

  // The racial numbers as printed. Read off the pages, not off the files.
  const RACIAL_SDC = { human: undefined, elf: 10, dwarf: 15, gnome: undefined,
    troglodyte: 10, kobold: 5, goblin: 5, 'hob-goblin': undefined, orc: 10,
    ogre: 20, troll: 40, changeling: undefined, wolfen: 20, coyle: 10 };
  const sqlFor = (id) => readFileSync(join(appDir, 'db', `add-${id}-class.sql`), 'utf8');
  const wrong = present.filter((id) => {
    const want = RACIAL_SDC[id];
    const got = /pools: \{ sdc: (\d+) \}/.exec(sqlFor(id));
    return want === undefined ? got !== null : Number(got?.[1]) !== want;
  });
  check('each race carries the S.D.C. bonus its page prints', wrong.length === 0,
    wrong.join(', '));

  // And it survives composition with a man of arms, which is the whole point.
  const troll = composeClass({
    rcc: mk('troll', { bonuses: { pools: { sdc: 40 } } }),
    occ: mk('knight'),
  });
  check('a Troll Knight rolls the Knight 3D6 and keeps the troll +40',
    troll.sdc_base === '3D6' && troll.bonuses?.pools?.sdc === 40,
    'sdc_base=' + troll.sdc_base + ' bonus=' + troll.bonuses?.pools?.sdc);

  // Played alone - which the books do not do and the app allows - the race
  // still gets a core roll rather than a NULL pool.
  const alone = composeClass({ rcc: mk('troll', { bonuses: { pools: { sdc: 40 } } }) });
  check('and a troll with no occupation still gets a core S.D.C. roll',
    alone.sdc_base === '1D6', alone.sdc_base);
}

// The formulas are only worth having if the roller understands them.
const attrs = { IQ: 10, ME: 10, MA: 10, PS: 10, PP: 10, PE: 14, PB: 10, Spd: 10 };
const hpRoll = rollPoolFormula('P.E. + 1D6 per level', attrs);
check('the core hit point formula parses and rolls', hpRoll >= 15 && hpRoll <= 20, hpRoll);
for (const dice of ['3D6', '1D6']) {
  const max = Number(dice[0]) * 6;
  const r = rollPoolFormula(dice, attrs);
  check('the core ' + dice + ' S.D.C. formula parses and rolls', r >= Number(dice[0]) && r <= max, r);
}

// ---------- 2. Hand to Hand level schedules ----------
section('Hand to Hand level schedules (p.347-349)');

// The five fighting styles are the reason `level_bonuses` exists. Their whole
// mechanical payload is a level-by-level table, so a regression here does not
// look like a broken number — it looks like a fighting style that does nothing,
// which is exactly the state these rows were found in.
const h2hSql = readFileSync(join(appDir, 'db', 'add-hand-to-hand-level-bonuses.sql'), 'utf8');
const h2h = [...h2hSql.matchAll(/UPDATE skills SET level_bonuses = '(\[.*?\])'\s*\n\s*WHERE name = '([^']+)';/g)]
  .map((m) => ({ name: m[2], level_bonuses: m[1].replace(/''/g, "'") }));
check('all five Hand to Hand tables are in the data script', h2h.length === 5, h2h.length);

// The book prints fifteen levels for each. A table that stops early is the
// kind of thing that reads fine and quietly caps a character's progression.
const parsed = h2h.map((r) => ({ name: r.name, entries: JSON.parse(r.level_bonuses) }));
check('each covers levels 1 to 15',
  parsed.every((t) => t.entries.length === 15
    && t.entries.every((e, i) => e.level === i + 1)),
  parsed.map((t) => t.name + '=' + t.entries.length).join(', '));
check('every entry grants something',
  parsed.every((t) => t.entries.every((e) => e.combat || e.saves || e.attributes || e.note)),
  'an entry with no bonuses and no note is a level that does nothing');

// p.347: the number of attacks a style starts with. The Assassin's three is
// the one that differs, and is the reason this is data rather than a constant.
const startsWith = Object.fromEntries(parsed.map((t) =>
  [t.name.replace('Hand to Hand: ', ''), t.entries[0].combat?.attacks_base]));
check('each states the attacks it starts with',
  Object.values(startsWith).every((v) => typeof v === 'number'), JSON.stringify(startsWith));
check('the Assassin starts with three and the rest with four',
  startsWith.Assassin === 3 && ['Basic', 'Expert', 'Martial Arts', 'Commando']
    .every((k) => startsWith[k] === 4), JSON.stringify(startsWith));
check('attacks_base appears at level 1 only',
  parsed.every((t) => t.entries.slice(1).every((e) => e.combat?.attacks_base === undefined)),
  'a later attacks_base would silently reset the count');

// "ALL bonuses are accumulative" (p.347).
const expert = h2h.find((r) => r.name.endsWith('Expert'));
check('a schedule accumulates rather than replacing',
  levelGrants(expert.level_bonuses, 5).length === 5
  && levelGrants(expert.level_bonuses, 15).length === 15,
  levelGrants(expert.level_bonuses, 5).length);
check('and grants nothing above the character level',
  levelGrants(expert.level_bonuses, 3).every((e) => e.level <= 3));

// A caller that cannot say the level must not be handed level 1 for free.
check('an unknown level grants nothing at all',
  levelGrants(expert.level_bonuses, null).length === 0
  && bonusesFromSkills([expert]) === undefined,
  JSON.stringify(bonusesFromSkills([expert])));

// The Expert's totals, counted off the book by hand: four attacks at level 1
// and one more at each of 4, 9 and 14; parry +3 at 2 and +2 at 12.
const at = (row, lvl) => bonusesFromSkills([row], lvl).combat;
check('an Expert fights at four attacks at level 1', at(expert, 1).attacks_base === 4
  && (at(expert, 1).attacks ?? 0) === 0, JSON.stringify(at(expert, 1)));
check('and at seven by level 15', (at(expert, 15).attacks ?? 0) + at(expert, 15).attacks_base === 7,
  JSON.stringify(at(expert, 15)));
check('and carries +5 parry by level 15', at(expert, 15).parry === 5, at(expert, 15).parry);
check('and only +3 parry at level 11', at(expert, 11).parry === 3, at(expert, 11).parry);

// Two styles must not stack into eight attacks.
const two = bonusesFromSkills([expert, h2h.find((r) => r.name.endsWith('Assassin'))], 1);
check('two fighting styles take the better start, not the sum',
  two.combat.attacks_base === 4, two.combat.attacks_base);

// The notes are the bulk of what the tables say.
const notes = skillLevelNotes([expert], 7);
check('the plain-text half is returned in level order',
  notes.length > 0 && notes.every((n, i) => i === 0 || n.level >= notes[i - 1].level),
  notes.length);
check('and stops at the character level', notes.every((n) => n.level <= 7));
check('and names the skill it came from', notes.every((n) => n.skill === expert.name));

// A conditional bonus must never become an unconditional number — the Assassin's
// gun and thrown-weapon bonuses are the ones that would go wrong.
const assassin = parsed.find((t) => t.name.endsWith('Assassin'));
const conditional = assassin.entries.filter((e) => /with guns|thrown weapon/i.test(e.note || ''));
check('the Assassin\'s weapon-specific bonuses stay in the note',
  conditional.length >= 3, conditional.length);

// derive.js has to know the keys, or a bonus is computed and never shown.
const sheetSrc = readFileSync(join(appDir, 'sheet.js'), 'utf8');
const usedKeys = new Set();
for (const t of parsed) {
  for (const e of t.entries) for (const k of Object.keys(e.combat || {})) usedKeys.add(k);
}
usedKeys.delete('attacks_base');
const unshown = [...usedKeys].filter((k) => !sheetSrc.includes("'" + k + "'"));
check('every combat key a schedule grants has a field on the sheet',
  unshown.length === 0, unshown.join(', ') + ' — computed but never displayed');

// ---------- 3. Weapon Proficiencies ----------
section('Weapon Proficiencies (p.326-329)');

// A W.P. grants its bonuses only "whenever that particular type of weapon is
// used" (p.326). That single sentence is the whole reason `applies_when`
// exists, and the failure it prevents is silent: a character with five W.P.s
// swinging their bare fists at +5 to strike looks like a good roll, not a bug.
const wpSql = readFileSync(join(appDir, 'db', 'add-wp-level-bonuses.sql'), 'utf8');
const wp = [...wpSql.matchAll(/UPDATE skills SET level_bonuses = '(\[.*?\])'\s*\n\s*WHERE name = '([^']+)';/g)]
  .map((m) => ({ name: m[2], level_bonuses: m[1].replace(/''/g, "'") }));
check('the W.P. data script covers 25 proficiencies', wp.length === 25, wp.length);
check('and every one of them is a W.P.', wp.every((r) => r.name.startsWith('W.P. ')),
  wp.filter((r) => !r.name.startsWith('W.P. ')).map((r) => r.name).join(', '));

// THE check. Every entry that carries numbers must also carry a condition.
const leaks = [];
for (const r of wp) {
  for (const e of JSON.parse(r.level_bonuses)) {
    const numeric = e.combat || e.saves || e.attributes;
    if (numeric && !e.applies_when) leaks.push(r.name + ' L' + e.level);
  }
}
check('no W.P. grants a bonus that applies with bare hands', leaks.length === 0,
  leaks.join(', ') + ' — an entry with numbers and no applies_when');

// The same statement from the other end: whatever the totals are, none of
// them may reach the block derive.js adds to a character's combat numbers.
check('all 25 together contribute nothing unconditional',
  bonusesFromSkills(wp, 15) === undefined, JSON.stringify(bonusesFromSkills(wp, 15)));

// ...and are not simply lost instead.
const wpConditional = skillConditionalBonuses(wp, 15);
check('but do come back as weapon bonuses', wpConditional.length >= 25, wpConditional.length);
check('each naming the weapon it needs',
  wpConditional.every((c) => c.applies_when && c.skill),
  'a bonus with no condition cannot be shown honestly');

// Counted off the page by hand: W.P. Sword is +1 to strike at levels 1, 3, 6,
// 9, 12 and 15, and +1 to parry at 2, 4, 7, 10 and 13.
const sword = wp.find((r) => r.name === 'W.P. Sword');
const swordAt = (lvl) => skillConditionalBonuses([sword], lvl)
  .find((c) => c.applies_when === 'with a sword')?.combat || {};
check('a 15th level swordsman is +6 to strike and +5 to parry with a sword',
  swordAt(15).strike === 6 && swordAt(15).parry === 5, JSON.stringify(swordAt(15)));
check('and only +2 / +2 at level 5',
  swordAt(5).strike === 2 && swordAt(5).parry === 2, JSON.stringify(swordAt(5)));

// A sword swung and a sword thrown are different bonuses, and the book lists
// them apart. Collapsing them would quietly add a throwing bonus to melee.
const swordConds = skillConditionalBonuses([sword], 15).map((c) => c.applies_when);
check('one skill can carry more than one condition',
  new Set(swordConds).size === 2, swordConds.join(' / '));

// The modern W.P.s are flat strike ladders; W.P. Handguns is +1 at 2, 4, 6,
// 8, 10, 12 and 14, so a 14th level shooter is +7.
const guns = wp.find((r) => r.name === 'W.P. Handguns');
check('a 14th level shooter is +7 to strike with a handgun',
  skillConditionalBonuses([guns], 14)[0]?.combat?.strike === 7,
  JSON.stringify(skillConditionalBonuses([guns], 14)));

// Every label the sheet needs, or a bonus is totalled and shown as a raw key.
const wpKeys = new Set();
for (const c of wpConditional) for (const k of Object.keys(c.combat)) wpKeys.add(k);
const unlabelled = [...wpKeys].filter((k) => !sheetSrc.includes(k + ':'));
check('every weapon bonus key has a short label on the sheet',
  unlabelled.length === 0, unlabelled.join(', ') + ' — missing from WP_LABELS');

// An energy weapon's aimed and burst bonuses are level-INDEPENDENT and stack
// with its level ladder, so they are separate conditions. Folded into one, an
// aimed shot would lose the +3 or a burst would gain it.
const ep = wp.find((r) => r.name === 'W.P. Energy Rifle');
const epConds = skillConditionalBonuses([ep], 13);
check('an energy weapon separates aimed, burst and plain fire',
  epConds.length === 3, epConds.map((c) => c.applies_when).join(' / '));
check('an aimed shot is +3 from level 1',
  epConds.find((c) => c.applies_when === 'taking an aimed shot')?.combat.strike === 3,
  JSON.stringify(epConds));
check('and the level ladder reaches +4 by level 13',
  epConds.find((c) => c.applies_when === 'with an energy rifle')?.combat.strike === 4,
  JSON.stringify(epConds));
check('with nothing at level 3, before the ladder starts',
  !skillConditionalBonuses([ep], 3).some((c) => c.applies_when === 'with an energy rifle'),
  JSON.stringify(skillConditionalBonuses([ep], 3)));

// The four W.P.s that were nearly merged away as older-edition duplicates.
// They are not duplicates: each carries its own bonuses, and the Revolver's
// aimed shot is +4 where every other modern handgun proficiency gives +3.
// Merging would have deleted that difference from every character holding it,
// silently and with nothing left to recover it from — so it is pinned here.
const restSql = readFileSync(join(appDir, 'db', 'backfill-blank-skills.sql'), 'utf8');
const rest = [...restSql.matchAll(/UPDATE skills SET level_bonuses = '(\[.*?\])'(?:,\s*\n\s*source_book = '[^']*')?\s*\n\s*WHERE name = '([^']+)';/g)]
  .map((m) => ({ name: m[2], level_bonuses: m[1].replace(/''/g, "'") }));
check('the remaining four W.P.s are filled in', rest.length === 4, rest.map((r) => r.name).join(', '));

const aimed = (name) => skillConditionalBonuses([rest.find((r) => r.name === name)], 1)
  .find((c) => c.applies_when === 'taking an aimed shot')?.combat.strike;
check('the Revolver keeps its +4 aimed shot', aimed('W.P. Revolver') === 4, aimed('W.P. Revolver'));
check('and the other two stay at +3',
  aimed('W.P. Automatic Pistol') === 3
  && aimed('W.P. Automatic and Semi-automatic Rifles') === 3,
  aimed('W.P. Automatic Pistol') + ' / ' + aimed('W.P. Automatic and Semi-automatic Rifles'));
check('so the Revolver is NOT interchangeable with the others',
  aimed('W.P. Revolver') !== aimed('W.P. Automatic Pistol'),
  'if these ever match, the merge that was called off has happened by accident');

check('these four leak nothing unconditional either',
  bonusesFromSkills(rest, 15) === undefined, JSON.stringify(bonusesFromSkills(rest, 15)));

// W.P. Rope's entangle and disarm are flat rather than a ladder, and it comes
// from New West — the bulk RUE import had stamped its own page range on it.
const rope = skillConditionalBonuses([rest.find((r) => r.name === 'W.P. Rope')], 15)[0];
check('W.P. Rope is +5 strike by level 15, with flat entangle and disarm',
  rope?.combat.strike === 5 && rope?.combat.entangle === 1 && rope?.combat.disarm === 1,
  JSON.stringify(rope));
check('and is credited to Rifts New West rather than the core book',
  restSql.includes("source_book = 'Rifts New West'"),
  'the RUE bulk import stamped a page range on a skill from another book');

// The two language rows are percentile, not schedules, so they are checked as
// text in the script rather than through the bonus path.
check('Literacy: Dragonese/Elven is set to 30% +5%',
  restSql.includes('SET base = 30, per_level = 5'));
check('Language: All (magical) records that it is not a purchasable skill',
  restSql.includes('base = 98') && restSql.includes('NOT a purchasable skill'),
  'a 0/0 row reads as unfilled; this one is an ability line');

// The two skills whose entry is prose only — Paired Weapons and Quick Draw,
// whose bonus scales with P.P. rather than level — must still say something.
for (const name of ['W.P. Paired Weapons', 'W.P. Quick Draw']) {
  const row = wp.find((r) => r.name === name);
  check(name + ' carries its rules as a note',
    skillLevelNotes([row], 1).length === 1, JSON.stringify(row?.level_bonuses)?.slice(0, 80));
}

// ---------- 4. Spell descriptions ----------
section('Spell descriptions');

// 23 spells carried a name, a level and a P.P.E. cost but no text, because
// they came in with the seed rather than through the PDF importers. They are
// not obscure — seventeen are levels 1-3, and Armor of Ithan and Energy Bolt
// are cast constantly.
const spellSql = readFileSync(join(appDir, 'db', 'backfill-spell-descriptions.sql'), 'utf8');
const spellUpdates = spellSql.match(/UPDATE spells SET /g) || [];
check('the spell backfill covers 23 spells', spellUpdates.length === 23, spellUpdates.length);

// The costs were verified against the stored ones BEFORE this was written and
// all 23 matched, so the script has no business touching them. A backfill that
// quietly rewrote a P.P.E. cost would be far worse than the missing text it
// set out to fix, and would look like nothing at all.
check('and changes no P.P.E. cost', !/\bppe\s*=/.test(spellSql),
  'this script may only write description, damage and duration');

// Guarded on the description still being empty, so a re-run cannot overwrite
// anything edited by hand afterwards.
const guards = spellSql.split('UPDATE spells SET ').slice(1)
  .filter((chunk) => chunk.includes("description IS NULL OR description = ''"));
check('every spell update refuses to overwrite existing text',
  guards.length === 23, guards.length + ' of 23 are guarded');

// Only the two the source states outright.
check('damage and duration are set only where the source gives them',
  (spellSql.match(/damage = /g) || []).length === 1
  && (spellSql.match(/duration = /g) || []).length === 1,
  'Energy Bolt and Breathe Without Air are the only two');

// ---------- 5. Structural gear rows ----------
section('Structural gear rows');

// Twelve of the gear stubs were not unfilled items but the wrong SHAPE: seven
// choices ("Air Filter Or Gas Mask") and five bundles ("Wooden Stake And
// Mallet"). The importer made one catalog row out of a book line naming two
// things, so the character held a single object that does not exist instead of
// two that do. No amount of book-reading fixes that.
const gearFix = readFileSync(join(appDir, 'db', 'fix-structural-gear-rows.sql'), 'utf8');
const structural = ['air-filter-and-gas-mask', 'air-filter-or-gas-mask', 'camouflage-fatigues-and-armor', 'flint-and-charcoal', 'military-fatigues-and-dress-uniform', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'traveling-robe-or-cloak-with-hood', 'wooden-stake-and-mallet'];
const unhandled = structural.filter((slug) => !gearFix.includes(slug));
check('every structural gear row is handled', unhandled.length === 0, unhandled.join(', '));

// The one that nearly went wrong. The five classes granting stakes say
// "qty: 6" - six stakes and ONE mallet - so an even split would have handed
// out five mallets nobody has. The first draft hard-coded qty 1 on both sides,
// matched nothing, and was caught only because the script reports what it left
// behind.
check('the stake and mallet bundle splits 6 and 1, not 6 and 6',
  gearFix.includes('"wooden-stake", qty: 6')
  && gearFix.includes('"small-mallet", qty: 1')
  && !gearFix.includes('"small-mallet", qty: 6'),
  'six mallets is not what the book grants');

// A rewrite pointing at slugs that do not exist is strictly worse than the row
// it replaced, so every one is conditional on its own options being present.
const rewrites = gearFix.split('UPDATE imported_classes').slice(1);
const blindRewrites = rewrites.filter((r) =>
  !r.includes('FROM gear WHERE slug IN') && !r.includes('EXISTS (SELECT 1 FROM gear'));
check('every class rewrite is guarded on its options existing',
  rewrites.length > 0 && blindRewrites.length === 0,
  blindRewrites.length + ' of ' + rewrites.length + ' rewrites would fire blind');

// A row is only dropped once nothing points at it any more, so an environment
// where the rewrites could not run keeps its references intact.
check('the rows are dropped only once nothing cites them',
  gearFix.includes('DELETE FROM gear')
  && /DELETE FROM gear[\s\S]*NOT EXISTS \(SELECT 1 FROM imported_classes/.test(gearFix)
  && /DELETE FROM gear[\s\S]*NOT EXISTS \(SELECT 1 FROM character_items/.test(gearFix),
  'a drop that ignored live references would break the classes citing them');

// The duplicate pair has to land on ONE choice, or the eleven classes citing
// one name and the single class citing the other end up with different gear.
const goggleChoices = [...gearFix.matchAll(/label: "(?:sunglasses or tinted goggles|tinted goggles or sunglasses)", qty: 1, from: \[([^\]]*)\]/g)]
  .map((m) => m[1]);
check('the two goggle rows retire into the same pair of options',
  goggleChoices.length === 2 && goggleChoices[0] === goggleChoices[1],
  goggleChoices.join(' vs '));

// ---------- 6. Provenance ----------
section('Provenance of web-sourced rows');

// Forty gear rows say their source was the web rather than naming a book and
// page. That value is load-bearing: it is how a reader tells a checked row
// from an unchecked one, and how a later book correction knows what it is
// overwriting. The near miss that produced the rule was a Glitter Boy stat
// block giving 820 M.D.C. and a 40 million credit price, which was only
// obviously wrong because that page declared itself homebrew.
const MARKER = 'Web reference (not book-verified)';
const dataDir = join(appDir, 'db');
// Scripts that ASSIGN the marker, not merely mention it. The estimate script
// names the web tier in a comment explaining where its own tier sits below
// it, and was failing the header check for describing a neighbour.
const assigns = (text, marker) => text.includes("source_book = '" + marker + "'");
const scriptsUsingMarker = readdirSync(dataDir)
  .filter((f) => f.endsWith('.sql'))
  .filter((f) => assigns(readFileSync(join(dataDir, f), 'utf8'), MARKER));
check('some data script writes the web-source marker',
  scriptsUsingMarker.length > 0,
  'if this stops being true the README section is describing nothing');

// The marker in the row is only half of it — the script that wrote it has to
// say so too, or the provenance lives in the database and nowhere in the repo.
const silent = scriptsUsingMarker.filter((f) => {
  const head = readFileSync(join(dataDir, f), 'utf8').split('UPDATE')[0]
    .split('INSERT')[0].toUpperCase();
  return !head.includes('WEB, NOT THE BOOK') && !head.includes('FROM WEB REFERENCES')
    && !head.includes('WEB SEARCH');
});
check('every script writing it says so in its header', silent.length === 0,
  silent.join(', ') + ' — provenance would live only in the database');

// The README quotes the exact string. If one drifts from the other the
// documentation is describing a value that no longer exists.
const readmeText = readFileSync(join(appDir, 'README.md'), 'utf8');
check('the README quotes the marker exactly', readmeText.includes(MARKER),
  'README and scripts disagree on the marker string');
// The wizard computes combat bonuses CLIENT-SIDE from the rows /catalogs
// sends, so any column bonusesFromSkills() reads has to be in that
// projection. `level_bonuses` was not, and nothing failed: the sheet was
// right because its own endpoint selects the column, and only the wizard
// quietly showed a Hand to Hand skill granting nothing at all.
//
// Checked against the source rather than a running server, so it holds in a
// checkout with no database.
const catalogsSrc = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator',
  'catalogs.js'), 'utf8');
const skillsSelect = catalogsSrc.split('FROM skills')[0].split('SELECT').pop();
for (const col of ['bonuses', 'level_bonuses']) {
  check('/catalogs sends skills.' + col + ' to the wizard',
    new RegExp('\\b' + col + '\\b').test(skillsSelect),
    'the wizard reads it in skillBonusClass() and would see nothing');
}

// The third provenance tier: values nothing published stands behind. The
// decision that made them acceptable was that they cannot change a roll, so
// THAT is what has to hold. A guessed price is a shopping inconvenience; a
// guessed damage die decides fights and looks identical to a real one.
const ESTIMATE = 'Estimate - no published price found';
const estimateScripts = readdirSync(join(appDir, 'db'))
  .filter((f) => f.endsWith('.sql'))
  .filter((f) => assigns(readFileSync(join(appDir, 'db', f), 'utf8'), ESTIMATE));
check('the estimate marker is written by some data script',
  estimateScripts.length > 0,
  'if this stops being true the README section describes nothing');

// Read off the scripts rather than the database, so this holds in a checkout
// where nothing has been applied yet.
const estimateSql = estimateScripts
  .map((f) => readFileSync(join(appDir, 'db', f), 'utf8')).join('\n');
// Split on semicolons that are NOT inside a string literal. This used to slice
// each chunk at the first `;` it saw, which is fine until a description
// contains one \u2014 and then the statement is cut off before `source_book`, the
// row stops looking like an estimate, and it skips both checks below. Twelve
// rows sat in that blind spot the day it was noticed, three of them armour.
// The rule is only worth having if a prose semicolon cannot step around it.
const estimateStatements = statements(estimateSql)
  .filter((s) => s.startsWith('UPDATE gear SET') && s.includes(ESTIMATE));
check('every estimate statement is an estimate of something',
  estimateStatements.length > 0, 'no UPDATE carries the marker');

// Only the SET clause. A WHERE that matches on a description is not the row
// claiming a number, and the guards on these scripts do exactly that.
const setClause = (s) => s.slice(0, s.search(/\bWHERE\b/) === -1 ? s.length : s.search(/\bWHERE\b/));
const combatKeys = ['mdc =', 'damage =', 'ar =', 'is_mega_damage = 1'];
const armed = estimateStatements.filter((s) =>
  combatKeys.some((k) => setClause(s).includes(k)));
check('NO estimated row carries a combat number', armed.length === 0,
  armed.length + ' estimate statement(s) set M.D.C., damage or A.R. '
  + '\u2014 the one thing estimating was allowed on condition of not doing');

// Weight is invention with nothing to anchor it, unlike cost.
const weighed = estimateStatements.filter((s) => setClause(s).includes('weight_lbs'));
check('and none invents a weight', weighed.length === 0,
  weighed.length + ' estimate statement(s) set weight_lbs');

check('the README documents the estimate tier',
  readmeText.includes(ESTIMATE)
  && readmeText.includes('A third tier, for what nothing publishes'),
  'the section explaining the third tier is missing or its marker drifted');

  check('and documents what it means',
  readmeText.includes('A row can say where it came from'),
  'the section explaining the convention is missing');

}
