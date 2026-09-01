// Character creation wizard: system → race → attributes → occupation →
// skills → equipment → powers → details → review/save.
//
// The race comes first and the roll comes before the occupation, because that
// is the order a Palladium character is actually made: you are a dragon, you
// roll to find out what kind, and then you decide what the dragon studied.
// See docs/plans/13-rcc-first-wizard.md.
//
// ES module so it can share js/dice.js with the server-side leveling code
// (functions/api/character-creator/_lib/leveling.js imports the same file).
// /shared/js/ui.js loads first as a classic script, so escHtml() is global;
// inline onclick handlers need their entry points on window — see the
// Object.assign at the bottom.
import { evalDice, rollPoolFormula, rollAttribute, rollQuantity,
         isAbsentAttribute } from './js/dice.js';
import { skillBase } from './js/skill-base.js';
import { isFamilyName, isRepeatableRow, otherRowFor, familySkillName,
         promptFor } from './js/language-skills.js';
import { rollPsionics, psionicShape, withRolledPsionics, PSIONIC_CATEGORIES, PSIONIC_TIER_RULES,
         rollsForPsionics as classRollsForPsionics } from './js/psionics.js';
import { isChoiceGroup, isGearChoice, applyVariant,
         categoryAllows, categoryLabel, categoryBonus, needsOccupation, abilityOccOptions,
         occAllowedForRace, raceAllowedForOcc, relatedFloorStatus,
         bonusesFromSkills, sumBonusGroups } from './js/parser.js';
import { composeClass } from './js/compose.js';
import { buildProposal, xpTableFor, thresholdFor, spellLevelsForGrant, psionicCategoriesForGrant,
         spellNamesForGrant, grantNote,
         skillGrantsFor, spellGrantsFor, psionicGrantsFor, startingGroups,
         startingPicksFor } from './js/leveling.js';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const STEPS = ['System', 'Race', 'Attributes', 'Occupation', 'Skills', 'Equipment', 'Powers',
               'Advancement', 'Details', 'Review'];
// Steps by name. Every transition used to be a bare index — goStep(3) — and
// splitting Class into two meant finding all fourteen of them by eye. Named
// once, so the next step inserted anywhere costs nothing but this list.
const ST = Object.fromEntries(STEPS.map((n, i) => [n.toUpperCase(), i]));

// The printed sheet's identity block. Everything here is optional flavour —
// nothing in the app's rules depends on it.
const BIO_FIELDS = [
  ['race', 'Race'], ['alignment', 'Alignment'], ['true_name', 'True Name'],
  ['occupation', 'Occupation'], ['age', 'Age'], ['sex', 'Sex'],
  ['height', 'Height'], ['weight', 'Weight'],
  ['family_origin', 'Family Origin'], ['environment', 'Environment'],
  ['native_languages', 'Native Language(s)'], ['insanity', 'Insanity (if any)'],
  ['birth_order', 'Birth Order'], ['land_of_origin', 'Land of Origin'],
  ['disposition', 'Disposition'], ['racial_bias', 'Racial Bias'],
  ['money', null],   // label depends on the system — see bioLabel()
];
// Split evenly rather than at a fixed index: the list has grown twice and a
// hard-coded 6 left one column noticeably longer each time.
const BIO_HALF = Math.ceil(BIO_FIELDS.length / 2);

// Gold in Palladium, credits in Rifts. Resolved at render because the system is
// not known when this list is declared.
const bioLabel = ([key, label]) => label ?? (key === 'money' ? rules.currencyLabel(S.system) : key);
// Point-buy (house rule — Palladium has no native point-buy):
// all 8 attributes start at 8; 40-point pool; +1 costs 1 point up to 15,
// 2 points from 16-18 (cap 18, floor 3); lowering below 8 refunds 1/point.
const PB_POOL = 40, PB_BASE = 8, PB_CAP = 18, PB_FLOOR = 3;

const S = {
  step: 0, system: null, classMode: 'browse', quiz: [null, null, null],
  // An unfinished build found on the server, awaiting resume-or-discard.
  draftOffer: null,
  // The updated_at of the draft this tab believes it owns, sent with every
  // save so the server can refuse to overwrite someone else's newer one.
  // null means "there is no draft and I expect to create it".
  draftVersion: null,
  draftConflict: null,
  // Two class fields, and the difference matters. `rcc` is what the player
  // PICKED on the Race step — raw, unresolved, still carrying its variants and
  // its choose-groups, which is what that step's pickers read. `cls` is what
  // the character IS: variant applied, occupation composed in, abilities folded
  // in. Nothing after the Occupation step knows there were ever two.
  //
  // It used to be one field that `confirmClass` overwrote in place, which was
  // fine while both halves were chosen on the same step and is not any more:
  // adding an occupation two steps later has to re-compose from the original.
  classes: [], rcc: null, cls: null,
  // The race half alone, composed. Kept because its dice bonuses are rolled and
  // read on the Attributes step, and choosing an occupation afterwards must not
  // re-roll a number the player has already seen.
  raceCls: null,
  attrMethods: {}, attrs: {}, attrRolls: {},
  related: [], secondary: [], groupPicks: {}, mos: null,
  // Starting-gear choices the class leaves open, and the slugs picked for each,
  // keyed by the entry's index in equipment_starting.
  gearChoices: [], gearPicks: {},
  // Which stage of the class, for classes that come in stages (a Dragon
  // hatchling vs an adult). NULL for every class that has none.
  variant: null,
  // The O.C.C. taken alongside an R.C.C., and its own stage. A racial class
  // grants no related or secondary skills — those come from the occupation —
  // so an R.C.C. character without one is deliberately thin.
  occ: null, occVariant: null,
  equipment: [], equipInit: false,
  charName: '', campaignId: null, newCampaign: '',
  spells: [], psi: [], bio: {},
  // Step 3. psiRoll is {roll, tier} once rolled — null means not yet rolled,
  // and a tier of null is a real result (26-00, no psionics) rather than an
  // absence, so the two must stay distinguishable.
  psiRoll: null, psiShape: null, psiCategory: null, psiTrimmed: 0,
  // The Age table's ×2 for long-lived races, and the percentile each field
  // last rolled — shown so a result can be checked against the book.
  longLived: false, bioRolls: {},
  // A class may state an attribute bonus as dice ("add 2D6 to P.S."). Rolled
  // once here and stored, because it cannot be re-evaluated on every render.
  attrBonuses: {},
  // What a class's DICE combat/save bonuses came up. Rolled once, like
  // attrBonuses, because both are read at render time.
  rolledBonuses: { combat: {}, saves: {} },
  // The occupation's own dice bonuses, rolled when it is chosen and kept apart
  // from the race's — so switching occupation re-rolls its half and leaves the
  // race's alone. rolledAll() is the only thing that sees them summed.
  occAttrBonuses: {}, occRolledBonuses: { combat: {}, saves: {} },
  // A character may start above level 1. Everything the levels earn is resolved
  // on the Advancement step, which exists only while this is above 1.
  level: 1,
  // What the levels above 1 rolled and chose. Held apart from the level-1
  // build rather than folded into it, because the two are answerable to
  // different rules: a skill picked at level 5 starts at its catalog base and
  // is NOT back-dated, while a skill held since level 1 advances per level.
  // levelSpells is keyed by grant index, not a flat list: a spell's allowed
  // LEVEL can depend on which level earned it, so the two gained at level 2 are
  // a different choice from the two gained at level 5 and cannot share a pool.
  // levelPsi stays flat - no book states a per-level cap on psionic powers.
  // levelPsi is keyed by grant index for the same reason levelSpells is: a
  // psionic grant can name its own CATEGORIES, and the Mystic's level-4 power
  // comes from Super while its starting ones came from Sensitive and Healing.
  levelPools: {}, levelSpells: {}, levelPicks: {}, levelPsi: {},
  // The level-1 picks when the class SPLITS them across restrictions - the
  // Delphi Juicer's "3 Physical + 1 Super". Keyed by group index for the same
  // reason levelSpells is, and separate from the flat `spells`/`psi` on
  // purpose: a class with one starting group keeps writing into those, so no
  // draft saved before this existed changes shape.
  spellGroups: {}, psiGroups: {},
  // Attributes re-rolled because a chosen O.C.C. raised a minimum the original
  // roll missed. Kept so the assist is visible as one rather than presented as
  // what the dice said first — posted as play events once the character exists.
  minRerolls: [],
  // Abilities picked from a class's choice group. A LIST, not a set: some are
  // repeatable and the second take means something different.
  abilities: [],
  pools: null, savedId: null, saving: false,
  skillCatalog: [], items: [], campaigns: [], existing: [],
  // Retired gear slugs → the slug they resolve to now. See findItem().
  itemRedirects: {},
  spellCatalog: [], psiCatalog: [], me: null, isAdmin: false,
  // Picker filter text. Transient view state, never persisted in a draft —
  // resuming a build should not resume half a search.
  gearFilter: '', relatedFilter: '', secondaryFilter: '', spellFilter: '', psiFilter: '',
  classFilter: '',
};

const $ = (id) => document.getElementById(id);
const esc = escHtml; // from /shared/js/ui.js

// api() and errorDetails() come from js/api.js, loaded first as a classic script.

// ---------- dice ----------
// The exceptional-roll rule lives in dice.js, so a class that spells out its
// own `3d6` behaves identically to one that says nothing. It used to not:
// stating the dice took a different branch that skipped the bonus die entirely,
// and the same 3d6 produced different characters depending on how the class
// happened to be written.
//
// The roll is kept whole, not flattened to a number, so the step can show how
// an exceptional total was reached.
function rollAttr(attr) {
  return rollAttribute(S.cls?.attribute_dice?.[attr] || '3d6');
}
// An attribute the class states as N/A is one this creature does not have
// (BOOK-INGEST-AUDIT.md F5) — a machine person has no constitution, a pleasurer
// no fixed beauty. It is not rolled, not entered, and not counted as missing;
// it stays null, which is what the sheet renders as a dash and what the server
// treats as a violation if some occupation requires it.
const attrAbsent = (a) => isAbsentAttribute(S.cls?.attribute_dice?.[a]);
function setRoll(a) {
  const r = rollAttr(a);
  // rollAttribute returns null ONLY for an absent attribute. Storing the null
  // is the whole point: a fallback here would put back the rolled ten the book
  // denies.
  if (!r) { S.attrs[a] = null; S.attrRolls[a] = null; return; }
  S.attrs[a] = r.total;
  S.attrRolls[a] = r.exceptional.length ? r : null;
}

// ---------- point-buy ----------
function pbCost(v) {
  let cost = 0;
  for (let t = PB_BASE + 1; t <= v; t++) cost += t <= 15 ? 1 : 2;
  if (v < PB_BASE) cost = -(PB_BASE - v);
  return cost;
}
function pbSpent() {
  return ATTRS.filter((a) => method(a) === 'point').reduce((sum, a) => sum + pbCost(S.attrs[a] ?? PB_BASE), 0);
}
const method = (a) => S.attrMethods[a] || 'roll';

// A class may state an attribute bonus as dice — "add 2D6 to P.S." Rolled once
// and stored, because it cannot be re-evaluated on every render.
//
// Called both when the class is confirmed and from computePools(), so the value
// is present on the Attributes step (where it is shown beside the roll) and is
// re-rolled by Review's Reroll button along with the pools.
// Everything a class's dice bonuses actually rolled, in the grouped shape
// classBonuses reads. One helper so the call sites cannot disagree.
// Two halves summed: the race's rolls and the occupation's, kept apart in state
// so that changing occupation re-rolls only its own. Every read goes through
// here, so no caller has to know there are two.
const sumRolled = (a, b) => {
  const out = { ...(a || {}) };
  for (const [k, v] of Object.entries(b || {})) out[k] = (out[k] || 0) + v;
  return out;
};
const rolledAll = () => ({
  attributes: sumRolled(S.attrBonuses, S.occAttrBonuses),
  combat: sumRolled(S.rolledBonuses?.combat, S.occRolledBonuses?.combat),
  saves: sumRolled(S.rolledBonuses?.saves, S.occRolledBonuses?.saves),
});

// Everything one class states as dice, rolled once. A list arrives when a class
// grants the same attribute twice — a level-1 bonus and an `at_level` one — and
// each rolls, because there is no single expression that means both.
//
// Combat and save bonuses roll here alongside the attribute ones, because both
// are read at render time and a roll re-evaluated per render moves under the
// player.
function rollDiceBonusesOf(cls) {
  const roll = (dice) => {
    const rolls = [dice].flat().map((d) => (typeof d === 'number' ? d : evalDice(d))).filter((v) => v != null);
    return rolls.length ? rolls.reduce((a, b) => a + b, 0) : null;
  };
  const out = { attributes: {}, combat: {}, saves: {} };
  const byGroup = derive.diceBonusesByGroup(cls);
  for (const g of ['combat', 'saves']) {
    for (const [k, dice] of Object.entries(byGroup[g] || {})) {
      const v = roll(dice);
      if (v != null) out[g][k] = v;
    }
  }
  for (const [attr, dice] of Object.entries(derive.diceBonuses(cls))) {
    const v = roll(dice);
    if (v != null) out.attributes[attr] = v;
  }
  return out;
}

function rollAttrBonuses(force = false) {
  // Idempotent unless forced. computePools() is called lazily whenever a later
  // step needs pools, and without this guard simply walking to Details silently
  // re-rolled a bonus the player had already read off the Attributes step.
  if (!force && S.attrBonuses && Object.keys(S.attrBonuses).length) return;

  // The RACE half only. S.cls carries the occupation's dice as well once one is
  // chosen, and rolling from it here would count those twice — once into
  // S.attrBonuses and again into S.occAttrBonuses.
  const r = rollDiceBonusesOf(S.raceCls || S.cls);
  S.attrBonuses = r.attributes;
  S.rolledBonuses = { combat: r.combat, saves: r.saves };
  // Review's Reroll button re-rolls the whole character, occupation included.
  if (force) rollOccBonuses();
}

// The occupation's dice bonuses, rolled from the occupation ALONE rather than
// from the composed class. A race granting +1D4 P.S. and an occupation granting
// +2D6 means both are rolled; rolling them separately is what lets the race's
// result stay put when the player changes their mind about the occupation.
function rollOccBonuses() {
  const occ = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  if (!occ) {
    S.occAttrBonuses = {};
    S.occRolledBonuses = { combat: {}, saves: {} };
    return;
  }
  const r = rollDiceBonusesOf(applyVariant(occ, S.occVariant));
  S.occAttrBonuses = r.attributes;
  S.occRolledBonuses = { combat: r.combat, saves: r.saves };
}

// The pools as saved: the level-1 roll plus every level's growth. Kept apart in
// state — S.pools is what the class rolled, S.levelPools is what the levels
// added — so Review's reroll button can re-roll one, the other, or both without
// either having to be reconstructed by subtraction.
// What the character starts with, from the class's own XP table — the same
// call the server makes, so the number on Review is the number that is stored.
function startingXp() {
  return thresholdFor(xpTableFor(S.cls), S.level) ?? 0;
}

function poolsPayload() {
  const base = S.pools || {};
  const add = {};
  for (const per of Object.values(S.levelPools || {})) {
    for (const [f, v] of Object.entries(per)) add[f] = (add[f] || 0) + v;
  }
  const out = {};
  for (const [key, field] of [['hp', 'hp_max'], ['sdc', 'sdc_max'], ['mdc', 'mdc_max'],
                              ['ppe', 'ppe_max'], ['isp', 'isp_max']]) {
    out[key] = base[key] == null ? base[key] : base[key] + (add[field] || 0);
  }
  return out;
}

// ---------- pools ----------
// `force` distinguishes the lazy first computation from the Reroll button.
// Only the button re-rolls what has already been rolled.
function computePools(force = false) {
  const c = S.cls;
  // I.S.P. may come from a tier the character rolled rather than from the
  // class, so the pool is read off the composed object.
  const pc = psiClass();
  // What the class adds on top of each pool's own formula. Books state these as
  // "plus 4D6" over whatever the occupation gives, so the bonus rides along with
  // the roll and lands in the stored maximum.
  const pb = c.bonuses?.pools || {};
  S.pools = {
    hp: rollPoolFormula(c.hit_points_base, S.attrs, pb.hp),
    sdc: rollPoolFormula(c.sdc_base, S.attrs, pb.sdc),
    mdc: rollPoolFormula(c.mdc_base, S.attrs, pb.mdc),
    ppe: rollPoolFormula(c.ppe_base, S.attrs, pb.ppe),
    isp: pc.psionics ? rollPoolFormula(pc.psionics.isp_base, S.attrs, pb.isp) : null,
  };
  // Step 5 is "Equipment AND Money" (p.22) — every class starts with a sum of
  // coin as well as its kit. Rolled from the same formula parser as the pools,
  // so the Reroll button on Review covers it, and stored in bio because it is a
  // running number the player edits rather than anything the rules derive.
  rollAttrBonuses(force);
  // Review's Reroll button re-rolls the whole character, and a character that
  // starts above level 1 includes the levels it climbed to get there.
  if (force) rollAdvancement(true);

  const money = rollPoolFormula(c.starting_money, S.attrs);
  if (money == null) delete S.bio.money; else S.bio.money = String(money);
}

// ---------- guided quiz ----------
const QUIZ = [
  { q: 'What are you playing?', opts: [['occ', 'A trained human-scale hero'], ['rcc', 'Something inhuman or monstrous'], ['any', 'No preference']] },
  { q: 'How do you want to solve problems?', opts: [['melee', 'Up close — blades and fists'], ['ranged', 'At range — bows or guns'], ['mystic', 'Magic and psychic powers']] },
  { q: 'What flavor of gear and setting?', opts: [['hightech', 'High-tech'], ['lowtech', 'Simple and traditional'], ['arcane', 'Arcane and otherworldly']] },
];
function classTraits(c) {
  const names = (c.skills?.occ_skills || []).map((s) => String(s.name).toLowerCase());
  const techy = names.some((n) => /radio|pilot|computer|laser|sensor/.test(n));
  return {
    cat: c.category,
    melee: names.some((n) => /w\.p\..*(sword|knife|blunt|shield|paired)/.test(n)),
    ranged: names.some((n) => /w\.p\..*(archery|energy|rifle|pistol|gun)/.test(n)),
    mystic: !!(c.magic || c.psionics),
    flavor: c.magic ? 'arcane' : techy ? 'hightech' : 'lowtech',
  };
}
function quizScore(c) {
  const t = classTraits(c);
  let score = 0;
  const [q1, q2, q3] = S.quiz;
  if (q1 && q1 !== 'any' && t.cat === q1) score += 2;
  if (q2 === 'melee' && t.melee) score += 2;
  if (q2 === 'ranged' && t.ranged) score += 2;
  if (q2 === 'mystic' && t.mystic) score += 2;
  if (q3 && t.flavor === q3) score += 2;
  return score;
}

// ---------- draft persistence ----------
// Eight steps, and step 3 ROLLS. A refresh or a closed tab used to lose all of
// it, and a roll is the one thing you cannot honestly redo — you either accept
// different numbers or re-roll until you like them.
//
// An explicit allowlist, not a copy of S: the state also holds the class,
// skill, spell and gear catalogs, which are large, shared, and stale the moment
// they are written down. Everything here is the build itself.
const DRAFT_KEYS = [
  'step', 'system', 'classMode', 'quiz', 'variant', 'occ', 'occVariant', 'attrMethods', 'attrs',
  'related', 'secondary', 'groupPicks', 'gearPicks', 'mos',
  'equipment', 'equipInit', 'charName', 'campaignId', 'newCampaign',
  'spells', 'psi', 'bio', 'pools', 'longLived', 'bioRolls',
  'psiRoll', 'psiShape', 'psiCategory', 'attrBonuses', 'rolledBonuses', 'abilities',
  'occAttrBonuses', 'occRolledBonuses', 'minRerolls',
  'level', 'levelPools', 'levelSpells', 'levelPsi', 'levelPicks',
  'spellGroups', 'psiGroups',
];

// Bumped whenever STEPS changes shape, because a draft stores `step` as an
// INDEX into it.
//
//   1  the original eight steps, with one combined Class step
//   2  Class split into Race and Occupation, Attributes between them
//   3  Advancement inserted after Powers, for characters starting above level 1
const STEPS_VERSION = 3;

// An old draft's step index, mapped onto the current list. A draft stopped on
// the old Class step resumes on Race, which is right: it had not committed to
// an occupation in any way the new step could trust.
//
// Only the steps AFTER an inserted one move, and each version is one insertion,
// so the migrations CHAIN: a version-1 draft runs through both.
//
//   1→2  Occupation inserted at 3; System, Race and Attributes keep 0, 1, 2
//        and Skills onward shift by one.
//   2→3  Advancement inserted at 7; everything up to Powers keeps its index
//        and Details and Review shift by one.
//
// Drafts are unfinished builds a player expects to come back to, so this is a
// mapping rather than a discard — and the resume OFFER reads the migrated index
// too, or it would name the wrong step in the sentence asking you to resume.
const STEP_MIGRATIONS = [
  (i) => (i <= 2 ? i : i + 1),   // from version 1
  (i) => (i <= 6 ? i : i + 1),   // from version 2
];

function migrateDraft(d) {
  if (!d) return d;
  const from = Number(d.state?.steps_version) || 1;
  if (from >= STEPS_VERSION) return d;
  let step = d.step || 0;
  // Index i of the list migrates version i+1 to i+2, so start where the draft is.
  for (let v = from; v < STEPS_VERSION; v++) step = STEP_MIGRATIONS[v - 1](step);
  return { ...d, step, state: { ...(d.state || {}), step, steps_version: STEPS_VERSION } };
}

let draftTimer = null;

// Nothing is worth saving until a class is picked — before that a "draft" is a
// radio button, and offering to resume one would be noise.
function draftWorthSaving() {
  return !!S.rcc && !S.savedId && !S.draftOffer;
}

// The class is stored as an ID and re-resolved on restore, so a draft never
// carries a stale copy of a class definition that has since been edited.
function draftPayload() {
  const state = {};
  for (const k of DRAFT_KEYS) state[k] = S[k];
  state.steps_version = STEPS_VERSION;
  return {
    state,
    step: S.step,
    system: S.system,
    // The class the player PICKED, not the composed one. Composition renames a
    // paired character ("Chiang-Ku Dragon Ley Line Walker") and the resume path
    // has to look the race up by id, so the raw half is what is stored.
    class_id: S.rcc?.id ?? null,
    class_name: S.rcc?.name ?? null,
    char_name: S.charName || null,
  };
}

// Debounced from render(), which already runs after every mutation — one hook
// instead of remembering to call this from thirty handlers.
function queueDraftSave() {
  if (!draftWorthSaving()) return;
  clearTimeout(draftTimer);
  draftTimer = setTimeout(saveDraft, 1500);
}

async function saveDraft() {
  if (!draftWorthSaving() || S.draftConflict) return;
  try {
    const res = await api('draft', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...draftPayload(), expect_updated_at: S.draftVersion }),
    });
    // Carry the new version forward, or the next save claims a stale one and
    // is refused on a build nobody else touched.
    if (res && res.updated_at) S.draftVersion = res.updated_at;
  } catch (err) {
    // A draft is a convenience, and a failed save must never interrupt the
    // build it is trying to protect — with ONE exception. A 409 means another
    // tab, or something driving the wizard, now owns the draft. Retrying would
    // either fail forever or clobber them, so this stops and says so once.
    // err.detail is the response body; errorDetails() flattens it to strings
    // and would drop the flag this needs.
    if (err && err.status === 409 && err.detail && err.detail.conflict) {
      S.draftConflict = err.detail.current || true;
      render();
    }
  }
}

async function discardDraft() {
  clearTimeout(draftTimer);
  // The row is gone, so the next save must claim no version at all - sending
  // the old one would be refused against a draft that no longer exists.
  S.draftVersion = null;
  S.draftConflict = null;
  try { await api('draft', { method: 'DELETE' }); } catch { /* see above */ }
}

function resumeDraft() {
  const d = S.draftOffer;
  S.draftOffer = null;
  // Adopt the version this build was loaded at, so the first save replaces
  // exactly the row it came from and nothing newer.
  S.draftVersion = d.updated_at ?? null;
  Object.assign(S, d.state);
  // The draft stores the class id and the stage separately, so the class is
  // resolved from scratch here — an edited class definition takes effect, and
  // the variant is re-applied on top of it.
  S.rcc = S.classes.find((c) => c.id === d.class_id) || null;
  recompose();
  S.savedId = null;
  render();
}

// The one destructive action in this file that never asked. sheet.js has three
// confirm() calls, campaign.js two, catalog.js two; this had none, and it sits
// a few hundred pixels from `Resume this build` in the same .nav row. What it
// destroys includes the rolled attributes, which docs/wizard-and-sheet.md names
// as the exact thing the draft feature exists to protect.
//
// The attributes are named only when there ARE some. A draft abandoned on the
// Class step has nothing rolled yet, and a warning about losing rolls that do
// not exist is the kind of sentence that teaches people to click through.
async function dismissDraft() {
  const d = S.draftOffer;
  const what = d?.class_name || d?.class_id || 'unfinished';
  const rolled = Object.values(d?.state?.attrs || {}).some((v) => v != null);
  if (!confirm(`Discard the ${what} build${d?.char_name ? ` for ${d.char_name}` : ''}`
    + `${rolled ? ', including its rolled attributes' : ''}? This cannot be undone.`)) return;
  S.draftOffer = null;
  await discardDraft();
  render();
}

// Shown before the wizard rather than over it: resuming into step 4 of someone
// else's half-finished build with no explanation is worse than the data loss
// this feature exists to prevent.
function renderDraftOffer() {
  const d = S.draftOffer;
  const when = d.updated_at ? d.updated_at.replace('T', ' ').replace('Z', '') : 'earlier';
  $('app').innerHTML = `
  <div class="panel">
    <h2>You have an unfinished character</h2>
    <p>${esc(d.char_name || 'Unnamed')} — <b>${esc(d.class_name || d.class_id || 'unknown class')}</b>,
       stopped at step ${d.step + 1} of ${STEPS.length} (${esc(STEPS[d.step] || '?')}).</p>
    <p class="muted small">Last saved ${esc(when)} UTC.</p>
    <div class="nav">
      <button class="btn btn-primary" onclick="resumeDraft()">Resume this build</button>
      <button class="btn btn-ghost" onclick="dismissDraft()">Discard and start fresh</button>
    </div>
    <p class="muted small">There is one draft at a time, so there is no third option here:
      starting fresh discards this build.</p>
  </div>`;
}

// ---------- rendering ----------
// The step number, in its own element. It was always in the label - the
// steps have read "1. System" since the wizard was written - but as text it
// could not be sized or coloured apart from the name. Padded to two digits
// so the tenth step does not shift its column.
const stepNum = (i) => `<span class="n">${String(i + 1).padStart(2, "0")}</span>`;

const SYSTEM_LABEL = { 'palladium-fantasy': 'Palladium Fantasy', rifts: 'Rifts' };

// What the character is so far, under the rail. Every value is read from S
// at render - nothing is stored for this - and every settled one is a button
// back to the step that set it. A value not yet decided is left out rather
// than shown empty: the strip is what you HAVE answered.
function summaryItems() {
  const out = [];
  const add = (k, v, step) => {
    if (v == null || v === '') return;
    const inner = `<span class="ws-k">${esc(k)}</span><span class="ws-v">${esc(String(v))}</span>`;
    out.push(step != null && step < S.step
      ? `<button type="button" class="ws" onclick="goStep(${step})">${inner}</button>`
      : `<span class="ws">${inner}</span>`);
  };

  add('System', SYSTEM_LABEL[S.system] || S.system, ST.SYSTEM);
  add('Class', S.cls?.name, ST.RACE);

  // Attribute total is derived here, not stored - there is no such field.
  const attrs = S.attrs || {};
  const rolled = ATTRS.filter((a) => typeof attrs[a] === 'number');
  if (rolled.length) add('Attributes', rolled.reduce((n, a) => n + attrs[a], 0), ST.ATTRIBUTES);

  // Guarded on S.cls: skillsAtLevelOne() reads S.cls.skills directly and
  // throws before a class is chosen, which is every render of step 1. The
  // strip is the one thing drawn on EVERY step, so anything it calls has to
  // survive the empty state.
  if (S.cls) {
    const skills = skillsAtLevelOne();
    if (Array.isArray(skills) && skills.length) add('Skills', skills.length, ST.SKILLS);
  }

  // Gold in Palladium, credits in Rifts - the label is the system's.
  if (S.bio && S.bio.money) add(rules.currencyLabel(S.system), S.bio.money, ST.EQUIPMENT);

  return out;
}
function renderStepper() {
  const steps = STEPS.map((name, i) => {
    // A step that does not apply is shown greyed rather than removed: the
    // numbering stays stable between characters, and "there is no occupation
    // step for this one" is information.
    if (!stepApplies(i)) return `<span class="st na" title="Does not apply to this character">${stepNum(i)}${name}</span>`;
    const cls = i === S.step ? 'st cur' : i < S.step ? 'st done' : 'st';
    // Only a completed step is clickable, so only a completed step is a button.
    // The rest stay spans: a focusable control that does nothing when you press
    // it is worse than plain text, and the stepper is a summary, not a menu.
    if (i < S.step) return `<button type="button" class="${cls}" onclick="goStep(${i})">${stepNum(i)}${name}</button>`;
    // Which step you are on is otherwise carried in colour alone — ten pills
    // that read identically to anything not looking at them.
    const cur = i === S.step ? ' aria-current="step"' : '';
    return `<span class="${cls}"${cur}>${stepNum(i)}${name}</span>`;
  }).join('');
  // Why a step is greyed used to live only in a title=, which is a pointer
  // affordance: at phone and tablet width there was no way to find out at all,
  // and no legend anywhere on the page. The title stays for the mouse. The
  // sentence now sits in the summary strip rather than in a paragraph of its
  // own - same words, in the place a reader already looks to see what is
  // settled, and it survives the labels disappearing on a phone.
  const na = STEPS.map((name, i) => [i, name]).filter(([i]) => !stepApplies(i));
  const phrase = (xs) => (xs.length < 2 ? xs[0] : `${xs.slice(0, -1).join(', ')} and ${xs[xs.length - 1]}`);
  const naNote = !na.length ? '' : `<p class="ws-note">
    ${na.length === 1 ? 'Step' : 'Steps'} ${phrase(na.map(([i, name]) => `${i + 1} (${name})`))}
    ${na.length === 1 ? 'does' : 'do'} not apply to this character.</p>`;
  // Rendered here because it is the one element every step draws, and a
  // warning that autosave has stopped must not depend on which step you are
  // on. It rides in the strip for the same reason, which is now sticky - so
  // it stays on screen instead of scrolling away with the rail.
  const c = S.draftConflict;
  const notice = !c ? '' : `<p class="ws-note warn err">
    Autosave stopped: this draft was taken over somewhere else${
      c !== true && c.class_name ? ` (now ${esc(c.class_name)}, step ${c.step + 1})` : ''}.
    Your work here is safe on screen — finish and save, or reload to take theirs.
  </p>`;
  const summary = summaryItems().join('') + naNote + notice;
  $('stepper').innerHTML = `<div class="step-rail">${steps}</div>`
    + (summary ? `<div class="wiz-summary">${summary}</div>` : '');
  // The rail sticks under .header, so it needs the header's measured height.
  // Called on every render because .header wraps at narrow widths and the
  // wizard re-renders on every step; js/sticky.js also re-measures on resize.
  sticky.sizeSticky();
}

function render() {
  if (S.draftOffer) { renderStepper(); return renderDraftOffer(); }
  if (S.savedId) { renderStepper(); return renderSaved(); }
  // Reached by any path that does not go through goStep — a resumed draft, or
  // an ability dropped on a step that made the next one moot.
  if (!stepApplies(S.step)) S.step = seekStep(S.step, 1);
  renderStepper();
  [renderSystem, renderRace, renderAttributes, renderOccupation, renderSkills,
   renderEquipment, renderPowers, renderAdvancement, renderDetails, renderReview][S.step]();
  wirePickers();
  queueDraftSave();
}

// Filter inputs are re-created by every render, so their listeners are re-bound
// here rather than delegated — the input needs its caret restored mid-keystroke,
// which Picker.wire handles and a delegated listener could not.
function wirePickers() {
  const only = (rows) => (rows.length === 1 ? rows[0] : null);

  Picker.wire('cat-filter', {
    onInput: (v) => { S.gearFilter = v; render(); },
    lone: only(Picker.filter(S.items, S.gearFilter)),
    onEnter: (item) => {
      S.equipment.push({ item_id: item.id, name: item.name, qty: 1, source: 'catalog' });
      S.gearFilter = '';
      render();
    },
  });

  for (const [id, key] of [['class-filter', 'classFilter'],
    ['related-filter', 'relatedFilter'], ['secondary-filter', 'secondaryFilter'],
    ['spell-filter', 'spellFilter'], ['psi-filter', 'psiFilter']]) {
    Picker.wire(id, { onInput: (v) => { S[key] = v; render(); } });
  }
}

function goStep(i) { if (stepApplies(i)) { S.step = i; render(); } }

// Not every step applies to every character. The Occupation step is the first
// one that does not: an O.C.C. taken as the primary class IS the occupation,
// and offering to pair it with a second one is a question with no answer.
//
// A predicate rather than a hard-coded skip, because the next conditional step
// (starting above level 1) plugs in here and the navigation stops caring.
function stepApplies(i) {
  // Nothing to advance through for a character that starts where everyone
  // starts, which is the overwhelmingly common case.
  if (i === ST.ADVANCEMENT) return S.level > 1;
  if (i !== ST.OCCUPATION) return true;
  if (!S.rcc) return true;
  // An ability that names practitioners claims the step whatever the category.
  if (abilityOccOptions(S.rcc, S.abilities)) return true;
  return S.rcc.category === 'rcc'
    && S.classes.some((c) => c.system === S.system && c.category === 'occ');
}

// The next or previous step that applies, so a skipped one is never landed on
// from either direction.
function seekStep(from, dir) {
  let i = from + dir;
  while (i > 0 && i < STEPS.length && !stepApplies(i)) i += dir;
  return Math.min(Math.max(i, 0), STEPS.length - 1);
}
function nextStep() { goStep(seekStep(S.step, 1)); }
function prevStep() { goStep(seekStep(S.step, -1)); }

// Step 0 — system
function gmCampaigns() {
  return S.me ? S.campaigns.filter((c) => c.gm_email === S.me) : [];
}

// The same rule characterAccess() applies on the server: a character belongs to
// its owner and to its campaign's G.M. This decides whether the Delete button is
// DRAWN; the endpoint decides whether it works, and is the one that matters.
// Kept in that order deliberately - offering a control that then refuses is the
// thing R1 was about.
function canDeleteCharacter(c) {
  if (!S.me) return false;
  if (c.player_email === S.me) return true;
  return S.campaigns.some((g) => g.id === c.campaign_id && g.gm_email === S.me);
}

// The most destructive thing this page can do, so the confirmation says what
// goes and what stays rather than asking whether you are sure. The journal line
// is there because it is the part people would otherwise assume wrong, and
// wrong in the dangerous direction: the foreign key alone WOULD take a player's
// posts out of the campaign log, and the endpoint detaches them first
// specifically so it does not.
async function deleteCharacter(id) {
  const c = S.existing.find((x) => x.id === id);
  if (!c) return;
  if (!confirm(`Delete ${c.name} (level ${c.level})? This cannot be undone.\n\n`
    + `Their inventory, level history, unspent picks and play log go with them. `
    + `Anything they had claimed from the campaign stash returns to it.\n\n`
    + `Journal entries they wrote stay in the campaign log.`)) return;
  try {
    await api('characters/' + id, { method: 'DELETE' });
  } catch (err) {
    alert('Could not delete ' + c.name + ': ' + err.message);
    return;
  }
  S.existing = S.existing.filter((x) => x.id !== id);
  // The campaign list above prints its own "N characters" and that count came
  // from the server; without this it keeps the old number until a reload, on
  // the same screen as the row that just disappeared.
  const camp = S.campaigns.find((g) => g.id === c.campaign_id);
  if (camp && typeof camp.character_count === 'number') camp.character_count -= 1;
  render();
}

// `2026-08-31 21:17:28` as `31 Aug`, and `31 Aug 2025` once the year has
// turned - a bare day and month is only unambiguous inside one year, and a
// campaign list is exactly the place old rows accumulate. Parsed by hand
// rather than through Date: the column is stored as UTC without a Z, which
// Date reads as local time and can shift by a day.
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
function shortDate(iso) {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(iso || ''));
  if (!m) return null;
  const [, y, mo, d] = m;
  const month = MONTHS[parseInt(mo, 10) - 1];
  if (!month) return null;
  const thisYear = String(new Date().getUTCFullYear());
  return `${parseInt(d, 10)} ${month}${y === thisYear ? '' : ' ' + y}`;
}
function renderSystem() {
  $('app').innerHTML = `
  <div class="panel">
    <h2>Choose a game system</h2>
    <div class="grid">
      <button type="button" class="pick ${S.system === 'palladium-fantasy' ? 'sel' : ''}" onclick="pickSystem('palladium-fantasy')">
        <h4>⚔️ Palladium Fantasy</h4><p class="muted">Swords, sorcery, and the Old Kingdom.</p>
      </button>
      <button type="button" class="pick ${S.system === 'rifts' ? 'sel' : ''}" onclick="pickSystem('rifts')">
        <h4>☢️ Rifts</h4><p class="muted">Mega-damage, magic, and machines on post-apocalyptic Earth.</p>
      </button>
    </div>
    ${S.isAdmin ? `<h3>Admin</h3>
    <p class="small"><a href="catalog.html">✏️ Edit catalogs</a>
      <span class="muted">— fix skills, spells, psionics and gear by hand</span></p>` : ''}
    ${gmCampaigns().length ? `<h3>Your campaigns (GM)</h3>
    ${gmCampaigns().map((c) => {
      // One per line, and each one says how many characters it holds and when
      // it was made. Run together on one line separated by dots, as this used
      // to be, two campaigns of the same name are one string.
      const n = c.character_count;
      const when = shortDate(c.created_at);
      const bits = [
        n === undefined || n === null ? null
          : `${n} character${n === 1 ? '' : 's'}`,
        when,
      ].filter(Boolean);
      return `<p class="small" style="margin:4px 0">
        <a href="dashboard.html?campaign_id=${c.id}">🗺 ${esc(c.name)}</a>
        <span class="muted">(${esc(c.system)})${bits.length ? ' · ' + esc(bits.join(' · ')) : ''}</span>
      </p>`;
    }).join('')}` : ''}
    ${S.existing.length ? `<h3>Existing characters</h3>
    ${S.existing.map((c) =>
      // One per line, for the reason the campaign list above already carries.
      // Run together and separated by dots, as this used to be, the separator
      // is the same middot each entry already uses INSIDE its own parenthesis
      // — so the boundary between two characters looks exactly like the
      // boundary between a level and a campaign name, and a name is only a
      // name if you can see where it starts.
      `<p class="small" style="margin:4px 0">
        <a href="sheet.html?id=${c.id}">${esc(c.name)}</a>
        <span class="muted">(${esc(className(c.class_id))}${c.occ_class_id ? ' ' + esc(className(c.occ_class_id)) : ''} L${c.level} · ${esc(c.campaign_name)})</span>
        ${canDeleteCharacter(c) ? `<button type="button" class="btn btn-sm btn-danger"
          onclick="deleteCharacter(${c.id})"
          aria-label="Delete ${esc(c.name)}">Delete</button>` : ''}
      </p>`
    ).join('')}` : ''}
  </div>`;
}
function pickSystem(sys) {
  if (S.system !== sys) { S.rcc = null; S.quiz = [null, null, null]; resetBuild(); }
  S.system = sys; S.step = ST.RACE; render();
}
function resetBuild() {
  S.attrMethods = {}; S.attrs = {}; S.attrRolls = {}; S.related = []; S.secondary = []; S.groupPicks = {}; S.mos = null;
  S.equipment = []; S.equipInit = false; S.pools = null;
  S.gearChoices = []; S.gearPicks = {};
  S.variant = null;
  S.occ = null; S.occVariant = null;
  S.abilities = [];
  S.spells = []; S.psi = []; S.bio = {}; S.longLived = false; S.bioRolls = {};
  S.psiRoll = null; S.psiShape = null; S.psiCategory = null; S.attrBonuses = {};
  S.rolledBonuses = { combat: {}, saves: {} };
  S.raceCls = null; S.cls = null;
  S.occAttrBonuses = {}; S.occRolledBonuses = { combat: {}, saves: {} };
  S.minRerolls = [];
  S.level = 1; S.levelPools = {}; S.levelSpells = {}; S.levelPsi = {}; S.levelPicks = {};
  S.spellGroups = {}; S.psiGroups = {};
}

// Step 1 — the race (browse | guided)
//
// The R.C.C. comes first and gets the step to itself. The list still holds
// every class for the system, because an O.C.C. taken alone is a human
// character and always was; what changed is that a racial class is now read
// before it is chosen rather than a step after.
function renderRace() {
  const list = S.classes.filter((c) => c.system === S.system);
  const mode = S.classMode;
  let inner;
  if (mode === 'browse') {
    // The longest list in the application was the one picker without a filter:
    // 120 cards for Rifts, and the primary button twelve screens below them at
    // desktop, thirty-one at phone. Same input, same `N of M` count and the same
    // name/category/source-book matching as the Skills step — a class here is a
    // catalog row like any other. The selected card can be filtered out of the
    // grid; classDetail() below still renders it, so the choice is never hidden.
    const matches = Picker.filter(list, S.classFilter);
    inner = Picker.inputHtml({ id: 'class-filter', value: S.classFilter,
      placeholder: 'Filter classes…', shown: matches.length, total: list.length });
    inner += matches.length
      ? classGroups(matches).map(([label, note, rows]) =>
        `<div class="pick-group over-grid">${esc(label)} <span class="muted small">&mdash; ${esc(note)}</span><span class="pick-group-n">${rows.length}</span></div>
       <div class="grid">` + rows.map((c) => classCard(c)).join('') + `</div>`).join('')
      : '<p class="muted small">Nothing matches that filter.</p>';
  } else {
    const answered = S.quiz.every((a) => a);
    inner = QUIZ.map((q, i) => `
      <h3>${i + 1}. ${q.q}</h3>
      <div class="rowline">` + q.opts.map(([val, label]) =>
        `<button class="btn btn-sm ${S.quiz[i] === val ? '' : 'btn-ghost'}" onclick="quizPick(${i},'${val}')">${label}</button>`).join('') + `</div>`).join('');
    if (answered) {
      // A shortlist that held the entire catalogue, a third of it scoring zero,
      // was longer than the browse list it exists to replace. The ranking and
      // the badges are the useful half and are untouched; what changed is that
      // a class matching NONE of the three answers is no longer printed in full
      // beside the ones that match all three. It is still reachable — the
      // guided mode is a suggestion, not a filter, and hiding a class outright
      // would make it one.
      const ranked = list.map((c) => [quizScore(c), c]).sort((x, y) => y[0] - x[0]);
      const hits = ranked.filter(([score]) => score > 0);
      const misses = ranked.filter(([score]) => score === 0);
      inner += `<h3>Your shortlist</h3>`;
      inner += hits.length
        ? `<div class="grid">` + hits.map(([score, c]) => classCard(c, score)).join('') + `</div>`
        : `<p class="muted small">Nothing scored above zero on those three answers — the whole list is below.</p>`;
      if (misses.length) {
        inner += `<details style="margin-top:16px">
          <summary class="muted small" style="cursor:pointer">Show the ${misses.length} that match nothing</summary>
          <div class="grid" style="margin-top:10px">`
          + misses.map(([score, c]) => classCard(c, score)).join('') + `</div></details>`;
      }
    } else {
      inner += `<p class="muted" style="margin-top:12px">Answer all three to see your shortlist.</p>`;
    }
  }
  // Computed once: the sentence and the disabled state come from the same call.
  const blocker = classBlocker();
  $('app').innerHTML = `
  <div class="panel">
    <h2>Pick your class <span class="muted small">(${esc(S.system)})</span></h2>
    <div class="toggle">
      <button class="${mode === 'browse' ? 'on' : ''}" onclick="classMode('browse')">Browse all</button>
      <button class="${mode === 'guided' ? 'on' : ''}" onclick="classMode('guided')">Help me choose</button>
    </div>
    ${inner}
    ${S.rcc ? classDetail(S.rcc) : ''}
    ${variantPicker()}
    ${raceBriefing()}
    ${abilityPicker()}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.SYSTEM)">&larr; Back</button>
  ${S.rcc && blocker ? `<span class="nav-why">${esc(blocker)}</span>` : ''}
  <button class="btn btn-primary" ${blocker ? 'disabled' : ''} onclick="confirmRace()">Confirm and roll &rarr;</button></div>`;
}

// What the race actually grants, in mechanical terms, BEFORE committing to it.
//
// The picker used to hand a player a Chiang-Ku Dragon off a card and a lore
// paragraph: the attribute dice, the pools, the psionics and the fixed skills
// were all first seen a step later, after the choice had been made and the
// dice were already rolling. This is the briefing that was missing.
//
// Reads the variant-resolved class, because a hatchling and an adult are
// different sets of dice and showing the base would be showing neither.
function raceBriefing() {
  if (!S.rcc) return '';
  const c = applyVariant(S.rcc, S.variant);
  const tag = (label, v) => `<span class="tag">${label} ${esc(String(v))}</span>`;

  const dice = ATTRS.filter((a) => c.attribute_dice?.[a]).map((a) => tag(a, c.attribute_dice[a])).join(' ');
  const pools = [['H.P.', c.hit_points_base], ['S.D.C.', c.sdc_base], ['M.D.C.', c.mdc_base],
                 ['P.P.E.', c.ppe_base], ['I.S.P.', c.psionics?.isp_base]]
    .filter(([, v]) => v != null).map(([k, v]) => tag(k, v)).join(' ');

  const b = c.bonuses || {};
  const plus = (v) => (typeof v === 'number' && v > 0 ? '+' : '') + [v].flat().join(' & +');
  // POOLS BELONG HERE TOO, and were the one group missing. A pool bonus is
  // added to whatever the pool's own formula rolls, so it does not appear in
  // the `pools` line above - that line prints the FORMULA, and a race that adds
  // to the occupation's roll rather than replacing it states no formula at all.
  // The Troll's +40 S.D.C. is its single most distinctive number and the
  // briefing showed nothing at all for it. Fifteen of the classes published
  // before the races grant one, so this was never only a race problem.
  const POOL_LABELS_SHORT = { hp: 'H.P.', sdc: 'S.D.C.', mdc: 'M.D.C.', ppe: 'P.P.E.', isp: 'I.S.P.' };
  const bonusBits = [
    ...Object.entries(b.attributes || {}).map(([k, v]) => tag(k, plus(v))),
    ...Object.entries(b.pools || {}).map(([k, v]) => tag(POOL_LABELS_SHORT[k] || k, plus(v))),
    ...Object.entries(b.combat || {}).map(([k, v]) => tag(k.replace(/_/g, ' '), plus(v))),
    ...Object.entries(b.saves || {}).map(([k, v]) => tag('save vs ' + k.replace(/_/g, ' '), plus(v))),
  ].join(' ');

  // Named skills only. A choice-group has no name to print here, and it is
  // resolved on the Skills step where it can actually be chosen.
  const fixed = (c.skills?.occ_skills || []).filter((e) => e?.name);
  const groups = (c.skills?.occ_skills || []).length - fixed.length;

  // psionics_allowed: false is a statement (a troll has no psychic potential),
  // and is worth printing precisely because it looks like an absence.
  const psi = c.psionics_allowed === false ? 'none — this race has no psychic potential'
    : c.psionics?.type ? `${c.psionics.type}${c.psionics.powers_starting ? ` · ${c.psionics.powers_starting} to choose` : ''}`
    : 'none stated';

  return `<div class="panel-inset" id="race-briefing">
    <h3>What ${esc(c.name)} grants</h3>
    ${dice ? `<p class="small"><b>Attribute dice</b> ${dice}</p>`
      : `<p class="small muted">No racial attribute dice — every attribute rolls 3d6.</p>`}
    ${pools ? `<p class="small"><b>Pools</b> ${pools}</p>` : ''}
    ${bonusBits ? `<p class="small"><b>Bonuses</b> ${bonusBits}</p>` : ''}
    <p class="small"><b>Psionics</b> <span class="muted">${esc(psi)}</span>
      ${c.magic?.type ? ` &middot; <b>Magic</b> <span class="muted">${esc(c.magic.type)}</span>` : ''}</p>
    ${fixed.length ? `<p class="small"><b>Skills it already knows</b>
      <span class="muted">${fixed.map((e) => esc(e.name) + (e.base != null ? ` ${e.base}%` : '')).join(' &middot; ')}</span>
      ${groups > 0 ? `<span class="muted"> &middot; and ${groups} to choose on the Skills step</span>` : ''}</p>` : ''}
    ${startingLevelPicker()}
    ${c.category === 'rcc' ? `<p class="small muted">${needsOccupation(c)
      ? 'This race grants nothing to choose on its own — an occupation is normally taken alongside it, on the step after the dice.'
      : 'An occupation may be taken alongside this race on the step after the dice.'}</p>` : ''}
  </div>`;
}
// A class's display name when the catalog is loaded, its id when not — the
// existing-characters list renders before /classes resolves on a cold start.
function className(id) {
  return S.classes.find((c) => c.id === id)?.name || id;
}

// A blurb cut to fit, at a word boundary, saying so only when it was cut.
//
// Three bugs in one line of card markup, and the first hid the other two.
//
// 1. Lore is hard-wrapped prose, so split('\n')[0] took the first WRAPPED
//    LINE, not the first sentence. The Cyber-Knight's 435 characters became
//    77 ending "an order of noble". Take the paragraph and unwrap it.
// 2. slice(0, 110) cut mid-word: "turn to chemical enhancemen".
// 3. The ellipsis was appended unconditionally, so lore that fit got one too
//    — the Headhunter's card ended "best of both worlds."… with nothing
//    withheld.
//
// Fixing 3 alone would have been worse than leaving it: a wrapped line under
// the limit would then read as a complete thought while still stopping
// mid-sentence. The unwrap is what makes the honest ellipsis honest.
//
// Falls back to a hard cut when the last space is too far back to be a word
// boundary worth honouring, which is what a single very long token gives you.
function blurb(text, max) {
  // The first PARAGRAPH, unwrapped: single newlines are typesetting, a blank
  // line is a real break.
  const line = String(text || '').split(/\n\s*\n/)[0].replace(/\s+/g, ' ').trim();
  if (line.length <= max) return line;
  const cut = line.slice(0, max + 1);
  const space = cut.lastIndexOf(' ');
  const kept = space > max * 0.6 ? cut.slice(0, space) : line.slice(0, max);
  // Trailing punctuation before an ellipsis reads as a typo rather than a trim.
  // A full stop is deliberately NOT stripped: it would turn an abbreviation into
  // nonsense - '4D6 M.D.' becomes 'M.D' - and a sentence followed by an ellipsis
  // is only slightly ugly, never wrong.
  return kept.trimEnd().replace(/[,;:—-]+$/, '') + '…';
}

// Where the character starts. On the RACE step rather than the Occupation step
// the plan named, because the Occupation step does not exist for a character
// whose primary class is an O.C.C. — which is most Rifts characters, and
// exactly the ones a player joining an established party would build.
//
// Bounded by the class's own XP table, so a class whose curve stops short
// cannot be asked for a level it has no threshold for. The server clamps to the
// same table; this is the same rule stated where the player can see it.
function startingLevelPicker() {
  // The COMPOSED class, not the race. `S.rcc` is the primary class, which for a
  // Rifts character is the O.C.C. and carries its own table — but for a
  // Palladium one it is the race, which has no experience table and never will.
  // Reading the race there showed every Palladium character the house-rule
  // default. `S.cls` is null only on the first pass through this step, before
  // an occupation exists to compose, and the race is the right answer then.
  const forXp = S.cls || applyVariant(S.rcc, S.variant);
  const cap = xpTableFor(forXp).length;
  const level = Math.min(S.level, cap);
  const opts = Array.from({ length: cap }, (_, i) => i + 1)
    .map((n) => `<option value="${n}"${n === level ? ' selected' : ''}>Level ${n}</option>`).join('');
  return `<div class="panel-inset" id="starting-level">
    <h3>Starting level</h3>
    <p class="muted small">Most characters start at 1. Starting higher is for joining a party
      already under way — every level in between is worked through on its own step, so the
      hit points are rolled and the skills, spells and powers each level earns are chosen
      rather than assumed.</p>
    <div class="rowline">
      <select onchange="setStartingLevel(this.value)">${opts}</select>
      ${level > 1 ? `<span class="muted small">starts with
        ${thresholdFor(xpTableFor(forXp), level)?.toLocaleString() ?? '—'} XP,
        the threshold for level ${level}</span>` : ''}
    </div>
    ${level > 1 ? `<p class="muted small">Starting equipment and money are <b>not</b> scaled up —
      the books do not rule on what a veteran owns, so that stays a table conversation.</p>` : ''}
  </div>`;
}

function setStartingLevel(v) {
  const n = parseInt(v, 10);
  if (!Number.isFinite(n) || n === S.level) return;
  S.level = Math.max(1, n);
  // A different span is a different set of dice and a different set of grants,
  // so nothing rolled or chosen for the old one survives.
  S.levelPools = {}; S.levelSpells = {}; S.levelPsi = {}; S.levelPicks = {};
  render();
}

// The browse list, split into its two kinds and alphabetised inside each.
//
// The catalog has no ORDER BY, so the grid came out in whatever order D1
// happened to return rows — races and occupations interleaved, and neither
// run in any order at all. With the catalog past a hundred classes the only
// way to find one was to read every card, and the only way to tell which kind
// a card was, was the small tag under its name.
//
// R.C.C.s first, because that is the order of the step: the race is what you
// are, and an O.C.C. taken alone is the human character. A category the parser
// does not know about still gets a group rather than vanishing.
const CLASS_GROUPS = [['rcc', 'R.C.C.', 'races'], ['occ', 'O.C.C.', 'occupations']];
function classGroups(list) {
  const seen = new Map(CLASS_GROUPS.map(([k]) => [k, []]));
  for (const c of list) {
    const k = c.category || 'other';
    if (!seen.has(k)) seen.set(k, []);
    seen.get(k).push(c);
  }
  return [...seen]
    .filter(([, rows]) => rows.length)
    .map(([k, rows]) => {
      const known = CLASS_GROUPS.find(([id]) => id === k);
      rows.sort((a, b) => String(a.name || '').localeCompare(String(b.name || '')));
      return [known ? known[1] : k, known ? known[2] : 'other classes', rows];
    });
}
function classCard(c, score) {
  const sel = S.rcc?.id === c.id ? ' sel' : '';
  const badge = score != null ? `<span class="tag score">match ${score}/6</span>` : '';
  return `<button type="button" class="pick${sel}" onclick="pickClass('${c.id}')">
    <h4>${esc(c.name)}</h4>
    <span class="tag">${esc(c.category)}</span><span class="tag">${esc(c.source_book)}</span>${
      needsOccupation(c) ? '<span class="tag">pairs with an O.C.C.</span>' : ''}${badge}
    <p class="muted small">${esc(blurb(c.lore, 110))}</p>
  </button>`;
}
function classDetail(c) {
  const reqs = c.attribute_requirements
    ? Object.entries(c.attribute_requirements).map(([k, v]) => `${k} ${v}+`).join(', ') : 'none';
  const sk = c.skills || {};
  return `<div id="class-detail" style="margin-top:16px; border-top:1px solid var(--border); padding-top:14px">
    <h3>${esc(c.name)}</h3>
    <p class="muted small">Requirements: ${esc(reqs)} &nbsp;·&nbsp; Class skills: ${(sk.occ_skills || []).length}
      &nbsp;·&nbsp; Related picks: ${sk.occ_related_skills?.count ?? 0} &nbsp;·&nbsp; Secondary picks: ${sk.secondary_skills?.count ?? 0}
      ${c.psionics ? ' · Psionics: ' + esc(c.psionics.type) : ''}${c.magic ? ' · Magic: ' + esc(c.magic.type) : ''}</p>
    <p class="small" style="margin-top:8px; line-height:1.55">${esc(c.lore || '')}</p>
    ${naturalAbilityList(c.natural_abilities)}
    ${listOrText('Side effects', c.side_effects)}
    ${listOrText('Restrictions', c.restrictions)}
    ${c.gm_notes ? `<p class="muted small" style="margin-top:8px"><b>GM notes:</b> ${esc(c.gm_notes)}</p>` : ''}
  </div>`;
}
// Powers the class simply grants — as opposed to the choose-groups the ability
// picker covers. Without this the Ley Line Walker's sixteen ley line powers
// appeared nowhere a player deciding on the class could read them.
function naturalAbilityList(list) {
  if (!Array.isArray(list) || !list.length) return '';
  const items = list.map((a) => {
    const name = typeof a === 'string' ? a : a?.name;
    const desc = a && typeof a === 'object' && a.description ? a.description : '';
    return `<li class="small"><b>${esc(name || '')}</b>${desc ? ` <span class="muted">&mdash; ${esc(desc)}</span>` : ''}</li>`;
  }).join('');
  return `<p class="small" style="margin-top:8px"><b>Natural abilities:</b></p>
    <ul style="margin:4px 0 0 18px">${items}</ul>`;
}
// side_effects / restrictions are free text — a string or a list, advisory only.
function listOrText(label, value) {
  if (!value || (Array.isArray(value) && !value.length)) return '';
  const body = Array.isArray(value)
    ? `<ul style="margin:4px 0 0 18px">${value.map((v) => `<li class="small">${esc(v)}</li>`).join('')}</ul>`
    : `<span class="small"> ${esc(value)}</span>`;
  return `<p class="small" style="margin-top:8px"><b>${label}:</b>${body}</p>`;
}

function classMode(m) { S.classMode = m; render(); }
function quizPick(i, val) { S.quiz[i] = val; render(); }
// Picking a class renders the detail, the variant/O.C.C./ability pickers and an
// enabled 'Use this class' button — ALL OF IT BELOW A GRID OF 20+ CARDS. On a
// laptop viewport that put every one of them about 1300px under the fold, and
// the page did not move, so the only on-screen change was a card tinting
// slightly. It read as a dead click, and got reported as one.
//
// So scroll the detail into view. The class list stays right above it, still
// one scroll away, and what to do next is now the thing you are looking at.
function pickClass(id) {
  const c = S.classes.find((x) => x.id === id);
  if (S.rcc?.id !== id) resetBuild();
  S.rcc = c;
  render();
  revealClassDetail();
}

// render() replaces innerHTML, so the node is looked up after it, not before.
//
// Instant, not smooth. Smooth reads better in principle and is wrong here for
// two reasons: the complaint being fixed is that the click looked dead, and a
// half-second animation is half a second of it still looking dead — and
// `behavior: 'smooth'` needs a compositor running, so it silently does nothing
// in an automated browser, which means the fix could not be tested. Instant
// scrolling is verifiable, and it is also the unambiguous answer to 'did that
// do anything'.
function revealClassDetail() {
  // The outstanding choice if there is one, the detail otherwise. Scrolling to
  // the detail alone put a Ley Line Walker's power picker back below the fold,
  // which is the same failure one screen further down.
  const { anchor } = classBlock();
  const el = document.getElementById(anchor || '') || document.getElementById('class-detail');
  if (!el || typeof el.scrollIntoView !== 'function') return;
  el.scrollIntoView({ behavior: 'auto', block: 'start' });
}
// A class with variants is not usable until one is chosen — a Dragon is always
// some particular age, and defaulting to the first stage would pick for you.
// What is still outstanding before this class can be used, as a sentence, or
// '' when nothing is. The button's disabled state is derived from this rather
// than computed alongside it, so the two cannot disagree — a greyed button
// with no reason, or a reason next to a live button, are both worse than
// either problem alone.
//
// This exists because a disabled button IS the whole explanation otherwise.
// Picking a Ley Line Walker greys it out with no visible cause; the answer
// (choose a power) is real, reasonable, and was never stated.
function classBlocker() { return classBlock().why; }

// The blocking requirement AND where on the page to resolve it. One function,
// because the sentence, the disabled button and the scroll target all have to
// describe the same requirement or they send the reader three ways.
function classBlock() {
  if (!S.rcc) return { why: 'Pick a class to continue.', anchor: null };
  if ((S.rcc.variants || []).length && !S.variant) {
    return { why: `Choose which ${S.rcc.name} to continue.`, anchor: 'variant-picker' };
  }
  // Every power the class asks for must be chosen before the rolls that depend
  // on them. Same reasoning as an unresolved gear choice: the book intends the
  // character to have them, so leaving one blank is an oversight rather than a
  // deliberate omission. Unspent SKILL picks are banked instead, because those
  // are earned over time.
  const owed = abilityGroups(S.rcc).reduce((n, g) => n + (+g.choose || 0), 0);
  const short = owed - S.abilities.length;
  if (short > 0) {
    return { why: `Choose ${short} more ${short === 1 ? 'power' : 'powers'} to continue.`,
             anchor: 'ability-picker' };
  }
  // An ability that names occupations (Magic Powers) used to block here too.
  // It is enforced on the Occupation step now, which is where the picker lives
  // — blocking the Race step on a choice two steps away had no way to offer it.
  return { why: '', anchor: null };
}

function canUseClass() { return !classBlocker(); }

// Which stage of the class. Shown only when the class has stages, so every
// other class is unaffected.
function variantPicker() {
  const variants = S.rcc?.variants || [];
  if (!variants.length) return '';
  return `<div class="panel-inset" id="variant-picker">
    <h3>Which ${esc(S.rcc.name)}?</h3>
    <p class="muted small">These share their skills, abilities and lore, and differ in their
      attribute dice, pools and what the class grants.</p>
    ${variants.map((v) => {
      const on = S.variant === v.id;
      const bits = [
        v.mdc_base ? `M.D.C. ${esc(v.mdc_base)}` : '',
        v.hit_points_base ? `H.P. ${esc(v.hit_points_base)}` : '',
        v.ppe_base ? `P.P.E. ${esc(v.ppe_base)}` : '',
      ].filter(Boolean).join(' · ');
      return `<label class="chkrow" style="cursor:pointer">
        <input type="radio" name="class-variant" ${on ? 'checked' : ''}
          onchange="pickVariant('${esc(v.id)}')">
        <span><b>${esc(v.name || v.id)}</b></span>
        <span class="pct">${bits}</span></label>`;
    }).join('')}
  </div>`;
}

function pickVariant(id) { S.variant = id; render(); }

// An O.C.C. alongside a racial class. Offered only for an R.C.C., because that
// is the pairing the books describe: the race is what you are, the occupation
// is what you trained as, and the related and secondary skill allowances come
// entirely from the latter.
function occPicker() {
  // A chosen ability that names occupations claims this picker: the choice
  // stops being optional and the options narrow to what the ability lists.
  const occNeed = abilityOccOptions(S.rcc, S.abilities);
  if (occNeed) {
    const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
    return `<div class="panel-inset" id="occ-picker">
    <h3>${esc(occNeed.name)} <span class="muted small">&mdash; pick the practitioner</span></h3>
    <p class="muted small">Taking <b>${esc(occNeed.name)}</b> means having one of these
      occupations composed into the character &mdash; its magic, its abilities and its
      training program all arrive with it.</p>
    ${!S.occ || !occNeed.options.includes(S.occ) ? `<p class="warn">Choose one to continue.</p>` : ''}
    <div class="rowline">
      <select onchange="pickOcc(this.value)">
        <option value="">&mdash; choose &mdash;</option>
        ${occNeed.options.map((oid) => {
          const c = S.classes.find((x) => x.id === oid);
          return c
            ? `<option value="${esc(oid)}"${S.occ === oid ? ' selected' : ''}>${esc(c.name)}</option>`
            : `<option value="" disabled>${esc(oid)} (not in the catalog yet)</option>`;
        }).join('')}
      </select>
    </div>
    ${chosen ? `<p class="small">Related skills: <b>${chosen.skills?.occ_related_skills?.count ?? 0}</b>
      &middot; Secondary: <b>${chosen.skills?.secondary_skills?.count ?? 0}</b>
      &middot; the occupation allowances replace those of this class.</p>` : ''}
  </div>`;
  }
  if (S.rcc?.category !== 'rcc') return '';
  const all = S.classes.filter((c) => c.system === S.system && c.category === 'occ');
  if (!all.length) return '';
  // A race may bar occupations outright - a dwarf takes no magic O.C.C., a
  // kobold no knight. The barred ones are SHOWN and disabled rather than
  // dropped: a player looking for the Knight should find out that the race
  // forbids it, not that the app has no Knight.
  // Two rules, and they point in opposite directions. A race may bar an
     // occupation (a dwarf takes no magic O.C.C.); an occupation may bar a race
     // (a Juicer is 95% human, so no R.C.C. at all). Both have to pass.
  const pairs = (c) => {
    const a = occAllowedForRace(S.rcc, c);
    return a.allowed ? raceAllowedForOcc(c, S.rcc) : a;
  };
  const options = all.filter((c) => pairs(c).allowed);
  const barred = all.filter((c) => !pairs(c).allowed);
  const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  // The usual structure is a race and then an occupation. Presented as the
  // expected next step rather than an optional extra, because that is what it
  // is — but never blocking, since some races genuinely stand alone.
  const needs = needsOccupation(S.rcc);
  return `<div class="panel-inset">
    <h3>Occupation <span class="muted small">— ${needs ? 'normally required' : 'optional for this race'}</span></h3>
    <p class="muted small">${needs
      ? `<b>${esc(S.rcc.name)}</b> grants no related or secondary skills of its own, so alone it
         gives you nothing to choose. A character is normally a race <em>and</em> an occupation:
         the race sets the body, the O.C.C. sets what was learned.`
      : `<b>${esc(S.rcc.name)}</b> grants its own skills, so it can stand alone — but most
         characters are a race <em>and</em> an occupation, and taking one adds its skills to this.`}</p>
    ${needs && !S.occ ? `<p class="warn">No occupation chosen. You can continue, and this character
      will have no related or secondary skills at all.</p>` : ''}
    <div class="rowline">
      <select onchange="pickOcc(this.value)">
        <option value="">— none (this race stands alone) —</option>
        ${options.map((c) => `<option value="${esc(c.id)}"${S.occ === c.id ? ' selected' : ''}>${esc(c.name)}</option>`).join('')}
        ${barred.length ? `<optgroup label="Not open to a ${esc(S.rcc.name)}">
          ${barred.map((c) => `<option value="${esc(c.id)}" disabled>${esc(c.name)}</option>`).join('')}
        </optgroup>` : ''}
      </select>
    </div>
    ${barred.length ? `<p class="muted small">${barred.length} occupation${barred.length === 1 ? ' is' : 's are'}
      closed to a <b>${esc(S.rcc.name)}</b>${S.rcc.occ_restrictions?.note
    ? ` — ${esc(S.rcc.occ_restrictions.note)}` : '.'}</p>` : ''}
    ${chosen?.variants?.length ? `<div class="rowline">
      <span class="muted small">Which ${esc(chosen.name)}?</span>
      <select onchange="S.occVariant = this.value || null; render()">
        ${chosen.variants.map((v) => `<option value="${esc(v.id)}"${S.occVariant === v.id ? ' selected' : ''}>${esc(v.name || v.id)}</option>`).join('')}
      </select></div>` : ''}
    ${chosen ? `<p class="small">Related skills: <b>${chosen.skills?.occ_related_skills?.count ?? 0}</b>
      · Secondary: <b>${chosen.skills?.secondary_skills?.count ?? 0}</b></p>` : ''}
  </div>`;
}

// Abilities the class asks the player to choose. On the CLASS step and not a
// step of its own, because an ability can add to attributes and pools — the
// Godling's Super-Tough is +1D6 P.E. and +3D4x10 M.D.C. — and both are rolled on
// the two steps after this one. Choosing later would mean re-rolling what the
// player had already read.
function abilityGroups(cls) {
  return (cls?.special_abilities || []).filter((e) => e && e.choose);
}

function abilityPicker() {
  const groups = abilityGroups(S.rcc);
  if (!groups.length) return '';
  const defs = new Map((S.rcc.special_abilities || [])
    .filter((e) => e && typeof e.name === 'string' && !e.choose)
    .map((d) => [d.name.trim().toLowerCase(), d]));

  return groups.map((g, gi) => {
    const limit = +g.choose || 1;
    const picked = S.abilities.length;
    const opts = (g.from || []).map((name) => {
      const def = defs.get(String(name).trim().toLowerCase());
      const times = S.abilities.filter((n) => n === name).length;
      const repeatable = def?.repeatable === true;
      const full = picked >= limit;
      return `<div class="chkrow">
        <button class="btn btn-sm btn-ghost" ${times === 0 ? 'disabled' : ''}
          onclick="dropAbility('${esc(name).replace(/'/g, "&#39;")}')">&minus;</button>
        <button class="btn btn-sm" ${full || (times > 0 && !repeatable) ? 'disabled' : ''}
          onclick="takeAbility('${esc(name).replace(/'/g, "&#39;")}')">+</button>
        <span><b>${esc(name)}</b>${times > 1 ? ` <span class="tag">taken ${times}&times;</span>`
          : times === 1 ? ' <span class="tag">taken</span>' : ''}
          ${repeatable ? '<span class="muted small">&nbsp;may be taken twice</span>' : ''}</span>
        ${def?.description ? `<div class="muted small" style="flex-basis:100%">${esc(def.description)}</div>` : ''}
        ${times > 1 && def?.on_repeat ? `<div class="small" style="flex-basis:100%"><b>Twice:</b> ${esc(def.on_repeat)}</div>` : ''}
      </div>`;
    }).join('');

    return `<div class="panel-inset"${gi === 0 ? ' id="ability-picker"' : ''}>
      <h3>Powers <span class="muted small">&mdash; choose ${limit}</span></h3>
      <p class="muted small">Chosen now rather than later: these can add to attributes and pools,
        and both are rolled on the next two steps.</p>
      <p class="small ${picked === limit ? 'ok' : 'warn'}">${picked} of ${limit} chosen</p>
      ${opts}
    </div>`;
  }).join('');
}

function takeAbility(name) {
  const limit = abilityGroups(S.rcc).reduce((n, g) => n + (+g.choose || 0), 0);
  if (S.abilities.length >= limit) return;
  S.abilities.push(name);
  render();
}

function dropAbility(name) {
  const i = S.abilities.lastIndexOf(name);
  if (i >= 0) S.abilities.splice(i, 1);
  // If the dropped ability was the one claiming the occupation slot and no
  // remaining pick still needs it, release the slot - keeping a practitioner
  // chosen through an ability that is no longer taken would be surprising.
  const still = abilityOccOptions(S.rcc, S.abilities);
  if (!still && S.occ) {
    const def = (S.rcc?.special_abilities || []).find((d) => d?.name === name);
    if (Array.isArray(def?.occ_options) && def.occ_options.includes(S.occ)) {
      S.occ = null; S.occVariant = null;
    }
  }
  render();
}

function pickOcc(id) {
  // The <option> is disabled, which stops a click and nothing else. A draft
  // restored from before the restriction landed, or a select driven by hand,
  // arrives here just the same.
  const want = id ? S.classes.find((c) => c.id === id) : null;
  const byRace = occAllowedForRace(S.rcc, want);
  const verdict = byRace.allowed ? raceAllowedForOcc(want, S.rcc) : byRace;
  if (want && !verdict.allowed) { alert(verdict.reason); return; }
  S.occ = id || null;
  // A different occupation cannot keep the previous one's stage.
  S.occVariant = null;
  const chosen = S.occ ? S.classes.find((c) => c.id === S.occ) : null;
  if (chosen?.variants?.length) S.occVariant = chosen.variants[0].id;
  recompose();
  // Its dice bonuses are its own, and a different occupation is a different
  // bonus — so they re-roll here while the race's stay exactly as rolled.
  rollOccBonuses();
  render();
}

// The two class-shaped objects the rest of the wizard reads, rebuilt from the
// raw halves. Called wherever a half changes: the race is confirmed, an
// occupation is picked or dropped, or a draft is resumed.
//
// Both go through js/compose.js and neither reaches for combineClasses — a
// smoke check fails the build for that, because re-implementing the order is
// exactly the bug compose.js exists to prevent.
function recompose() {
  const character = { class_variant: S.variant, occ_class_variant: S.occVariant,
    abilities: S.abilities, mos: S.mos };
  // The race half alone, kept because its dice bonuses were rolled off it and
  // must not be re-rolled when an occupation arrives.
  S.raceCls = composeClass({ rcc: S.rcc, occ: null, character });
  S.cls = composeClass({
    rcc: S.rcc,
    occ: S.occ ? S.classes.find((c) => c.id === S.occ) || null : null,
    // No psychic tier here: the roll happens on the Powers step, and psiClass()
    // folds it in from there while a build is in progress.
    character,
  });
}

// Choosing again replaces rather than adds: an MOS is one specialty, and the
// skills the previous one granted have to leave with it. recompose() rebuilds
// occ_skills from the class, so nothing has to be unpicked by hand - but a
// group pick made against the OLD specialty would dangle, so they clear too.
function pickMos(id) {
  S.mos = String(S.mos || '').toLowerCase() === String(id).toLowerCase() ? null : id;
  S.groupPicks = {};
  recompose();
  render();
}

function confirmRace() {
  recompose();
  // Rolled here so the Attributes step, which comes next, can show the bonus
  // beside the roll it modifies. computePools() re-rolls it later if asked.
  rollAttrBonuses(true);
  goStep(ST.ATTRIBUTES);
}

// Step 7 — everything the levels above 1 earn.
//
// Placed AFTER Powers rather than woven through the earlier steps, because by
// this point the level-1 character is complete — which is exactly the input
// buildProposal takes. "Start at level 6" is therefore not a second system: it
// is build at 1, then run the engine the live level-up already uses.
//
// Batched by default with a section per level, so a player who wants six levels
// resolved in one click gets that and one who wants to roll each level's hit
// points separately gets that too.
function renderAdvancement() {
  rollAdvancement();
  const cls = S.cls;
  const gained = S.level - 1;
  const skillGrants = skillGrantsFor(cls, 1, S.level);
  const spells = spellGrantsFor(cls, 1, S.level);
  const psionics = psionicGrantsFor(cls, 1, S.level);

  // Totals first: this is the summary the step opens on.
  const poolTotals = {};
  for (const per of Object.values(S.levelPools)) {
    for (const [f, v] of Object.entries(per)) poolTotals[f] = (poolTotals[f] || 0) + v;
  }
  const poolLabel = { hp_max: 'H.P.', sdc_max: 'S.D.C.', mdc_max: 'M.D.C.', ppe_max: 'P.P.E.', isp_max: 'I.S.P.' };
  const poolSummary = Object.entries(poolTotals)
    .map(([f, v]) => `<span class="tag">${poolLabel[f] || f} +${v}</span>`).join(' ');

  // Skills held since level 1 advance; this says by how much without listing
  // forty rows, because the per-skill arithmetic is on the sheet afterwards.
  const advancing = skillsAtLevelOne().filter((sk) => sk.pct && sk.per_level).length;

  $('app').innerHTML = `
  <div class="panel">
    <h2>Advancement <span class="muted small">— levels 2 to ${S.level}</span></h2>
    <p class="muted small">${gained} ${gained === 1 ? 'level' : 'levels'} of growth, itemised by the
      level that earned each part. Open a level to roll its dice on their own.</p>

    <div class="panel-inset">
      <h3>What ${esc(cls.name)} gains</h3>
      <p class="small">${poolSummary || '<span class="muted">No pool grows per level for this class.</span>'}</p>
      <p class="small muted">${advancing} ${advancing === 1 ? 'skill advances' : 'skills advance'}
        by their per-level step. A skill picked at a later level starts at its catalog base
        instead — it is new, not back-dated.</p>
      <button class="btn btn-sm btn-ghost" onclick="rerollAdvancement()">🎲 Re-roll every level</button>
    </div>

    ${levelSections(skillGrants, spells, psionics)}
    ${skillPickBlock(skillGrants)}
    ${advPowerBlock('spell', spells)}
    ${advPowerBlock('psi', psionics)}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.POWERS)">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(ST.DETAILS)">Details &rarr;</button></div>`;
}

// The skill picks the levels granted, one row of slots per grant.
//
// A select per slot rather than the Skills step's filtered checkbox list: a
// grant is typically one or two picks, and a full picker for two choices is
// more machinery than the choice deserves. The filtering rule is identical —
// categoryAllows, the same helper the Skills step and the server validator
// share — so what is offered here is what is legal there.
//
// Leaving a slot blank is allowed. It banks as a pending pick and the sheet
// shows it unspent, exactly as an unspent level-up grant does: creating a
// character is never blocked on choosing a skill.
function skillPickBlock(grants) {
  if (!grants.length) return '';
  const taken = takenNames();
  const spent = picksSpent();
  const total = grants.reduce((n, g) => n + g.count, 0);

  const body = grants.map((g, gi) => {
    const chosen = S.levelPicks[gi] || [];
    const slots = Array.from({ length: g.count }, (_, slot) => {
      const mine = new Set(chosen.filter((_, i) => i !== slot).map((n) => String(n).toLowerCase()));
      const options = S.skillCatalog
        .filter((sk) => inSystem(sk))
        .filter((sk) => !g.categories || categoryAllows(g.categories, sk))
        .filter((sk) => {
          const key = String(sk.name).toLowerCase();
          return (!taken.has(key) && !mine.has(key)) || sk.name === chosen[slot];
        })
        .sort((a, b) => (a.category || '').localeCompare(b.category || '') || a.name.localeCompare(b.name));
      return `<div class="rowline">
        <select onchange="setLevelPick(${gi}, ${slot}, this.value)">
          <option value="">— leave for later —</option>
          ${options.map((sk) => `<option value="${esc(sk.name)}"${
            chosen[slot] === sk.name ? ' selected' : ''}>${esc(sk.name)}${
            sk.category ? ` (${esc(sk.category)})` : ''}</option>`).join('')}
        </select>
      </div>`;
    }).join('');

    const where = g.categories
      ? g.categories.map((c) => categoryLabel(c)).join(', ')
      : 'any skill';
    return `<p class="small" style="margin-top:10px"><b>Level ${g.level}</b> —
      ${g.count} ${g.kind === 'secondary' ? 'secondary' : 'related'} ${g.count === 1 ? 'pick' : 'picks'}
      <span class="muted">from ${esc(where)}</span></p>${slots}`;
  }).join('');

  return `<div class="panel-inset" id="level-skill-picks">
    <h3>Skill picks <span class="muted small">— ${spent} of ${total} chosen</span></h3>
    <p class="muted small">Anything left blank is banked and waits on the character sheet.</p>
    ${body}
  </div>`;
}

function setLevelPick(gi, slot, name) {
  const list = S.levelPicks[gi] || (S.levelPicks[gi] = []);
  list[slot] = name || null;
  render();
}

// New spells and psionic powers the levels earn.
//
// `unknown` is not the same answer as none, and this is the one place a player
// finds out which they have. A class whose definition states no per-level rule
// says so plainly rather than showing an empty list that reads as "this class
// learns nothing" — see js/leveling.js.
function advPowerBlock(kind, grant) {
  if (!grant.applicable) return '';
  const isSpell = kind === 'spell';
  const label = isSpell ? 'Spells' : 'Psionic powers';

  if (grant.unknown) {
    return `<div class="panel-inset">
      <h3>${label} per level</h3>
      <p class="warn">This class's definition does not record how many ${
        isSpell ? 'spells' : 'powers'} it learns at each level, so none are offered here.
        The books do state it for most classes — re-import the class with
        <code>${isSpell ? 'spells_per_level' : 'powers_per_level'}</code>, or add them by hand
        on the sheet afterwards. Nothing is guessed.</p>
    </div>`;
  }
  if (!grant.total) return '';

  return isSpell ? spellGrantBlock(grant) : psiGrantBlock(grant);
}

// Spells, one picker PER GRANT.
//
// Not one batched set, because the spell levels a grant may draw from can
// depend on the level that earned it - a Ley Line Walker's two spells at level
// 2 are capped at spell level 2 even though its starting twelve came from
// levels 1-4. Batching them would quietly let the level-2 pair be filled with
// level-4 spells, which is over-permissive in a way nobody would notice.
//
// The cap is ENFORCED rather than advised: a spell's level is a mechanical rule
// like a psychic tier, not a table judgement like a skill category. Out-of-cap
// spells are not in the list at all.
function spellGrantBlock(grant) {
  const taken = Object.values(S.levelSpells).flat().filter(Boolean);
  const blocks = grant.grants.map((g, gi) => {
    const chosen = S.levelSpells[gi] || [];
    const levels = spellLevelsForGrant(S.cls, g.level, g.slot);
    const names = spellNamesForGrant(S.cls, g.level, g.slot);
    const note = grantNote(S.cls, 'spell', g.level, g.slot);
    // Everything already held: the class's own, the level-1 picks, and every
    // other grant's. A spell is learned once.
    const heldElsewhere = new Set([...S.spells, ...taken.filter((n) => !chosen.includes(n))]
      .map((n) => n.toLowerCase()));
    // A named list is the tightest restriction and replaces the level cap: a
    // grant that names its spells is not also asking about levels.
    const named = names && new Set(names.map((n) => n.toLowerCase()));
    const pool = S.spellCatalog.filter((sp) => inSystem(sp)
      && (named ? named.has(String(sp.name).toLowerCase()) : (!levels || levels.includes(sp.level)))
      && !heldElsewhere.has(String(sp.name).toLowerCase()));
    // A name the catalog does not carry would silently shrink the list, so say
    // so — the same reasoning the psionic named list already uses.
    const unknownNamed = names
      ? names.filter((n) => !S.spellCatalog.some((x) => String(x.name).toLowerCase() === n.toLowerCase()))
      : [];
    const cap = named ? `a list of ${names.length}`
      : levels ? `spell levels ${levels.join(', ')}` : 'any spell level';
    return `<p class="small" style="margin-top:12px"><b>Level ${g.level}</b> — ${g.count}
      ${g.count === 1 ? 'spell' : 'spells'} <span class="muted">from ${esc(cap)}</span></p>
      ${note ? `<p class="attr-note">${esc(note)} — the catalog cannot check this one, so it is
        yours to honour.</p>` : ''}
      ${unknownNamed.length ? `<p class="attr-note">${unknownNamed.length} named
        ${unknownNamed.length === 1 ? 'spell is' : 'spells are'} not in the catalog yet:
        ${esc(unknownNamed.join(', '))}.</p>` : ''}
      ${spellGroupRows(pool, g.count, 'spell-adv', gi)}`;
  }).join('');

  return `<div class="panel-inset">
    <h3>Spells — ${taken.length}/${grant.total}</h3>
    <p class="muted small">Each level's spells are chosen from the levels that level allows.
      A spell already known is not offered again.</p>
    ${blocks}
  </div>`;
}

// Psionic powers, one picker PER GRANT — for the same reason spells are.
//
// This was one batched set, with a comment saying no book states which level a
// given power had to be learned at. The Mystic says otherwise: its starting
// powers come from Sensitive and Healing, and the ones at levels 4 and 8 come
// from SUPER. Batching them would offer Super powers against every slot.
//
// A grant's categories REPLACE the class's rather than narrowing them. Tier is
// enforced by category here, so a grant naming Super is the book granting a
// major psychic an exception to it - intersecting would throw that away.
function psiGrantBlock(grant) {
  const taken = Object.values(S.levelPsi).flat().filter(Boolean);
  const blocks = grant.grants.map((g, gi) => {
    const chosen = S.levelPsi[gi] || [];
    const cats = psionicCategoriesForGrant(S.cls, g.level, g.slot);
    const note = grantNote(S.cls, 'psionic', g.level, g.slot);
    const heldElsewhere = new Set([...S.psi, ...taken.filter((n) => !chosen.includes(n))]
      .map((n) => n.toLowerCase()));
    const pool = advPsiPool(cats).filter((x) => !heldElsewhere.has(String(x.name).toLowerCase()));
    return `<p class="small" style="margin-top:12px"><b>Level ${g.level}</b> — ${g.count}
      ${g.count === 1 ? 'power' : 'powers'}
      <span class="muted">from ${esc(cats ? cats.join(', ') : 'any category')}</span></p>
      ${note ? `<p class="attr-note">${esc(note)} — the catalog cannot check this one.</p>` : ''}
      ${psiGroupRows(pool, g.count, 'psi-adv', gi)}`;
  }).join('');

  return `<div class="panel-inset">
    <h3>Psionic powers — ${taken.length}/${grant.total}</h3>
    <p class="muted small">Each level's powers come from the categories that level allows.
      A power already known is not offered again.</p>
    ${blocks}
  </div>`;
}

// The psionic pool a grant may draw from, minus what the character already
// holds — a power cannot be learned twice.
//
// `cats` overrides the class's own when a grant names its own categories.
function advPsiPool(cats = null) {
  const cls = psiClass();
  const psi = psiConfig(cls);
  if (!psi) return [];
  const tier = cls.psionics.type;
  const allowed = cats || psi.cats;
  // A named list is the class saying exactly which powers its STARTING picks
  // come from; a grant naming its own categories is a later, different rule and
  // is not narrowed by that list.
  const named = !cats && psi.from && new Set(psi.from.map((n) => n.toLowerCase()));
  // categoryAllows rather than a plain includes: a category entry may narrow
  // itself with `only` / `except` since F16, and that is the same grammar and
  // the same function the skill pickers use.
  const inCategory = named
    ? S.psiCatalog.filter((x) => inSystem(x) && named.has(String(x.name).toLowerCase()))
    : S.psiCatalog.filter((x) => inSystem(x) && categoryAllows(allowed, x));
  // The per-power tier gate applies here exactly as it does at level 1. Out-of
  // tier powers stay unselectable rather than becoming an override, which is
  // the deliberate asymmetry with skill categories: those get bent at the
  // table, psychic tiers do not.
  return inCategory.filter((x) => derive.meetsTier(tier, x.min_tier) && !S.psi.includes(x.name));
}

// One collapsed section per level, saying what that level alone contributed.
function levelSections(skillGrants, spells, psionics) {
  const poolLabel = { hp_max: 'H.P.', sdc_max: 'S.D.C.', mdc_max: 'M.D.C.', ppe_max: 'P.P.E.', isp_max: 'I.S.P.' };
  let out = '';
  for (let lvl = 2; lvl <= S.level; lvl++) {
    const pools = S.levelPools[lvl] || {};
    const rolled = Object.entries(pools).map(([f, v]) => `${poolLabel[f] || f} +${v}`).join(' · ');
    const earned = [
      ...skillGrants.filter((g) => g.level === lvl)
        .map((g) => `${g.count} ${g.kind === 'secondary' ? 'secondary' : 'related'} skill ${g.count === 1 ? 'pick' : 'picks'}`),
      ...spells.grants.filter((g) => g.level === lvl).map((g) => `${g.count} new ${g.count === 1 ? 'spell' : 'spells'}`),
      ...psionics.grants.filter((g) => g.level === lvl).map((g) => `${g.count} new psionic ${g.count === 1 ? 'power' : 'powers'}`),
    ];
    out += `<details class="lvl-row">
      <summary><b>Level ${lvl}</b> <span class="muted small">${esc(rolled || 'no pool growth')}${
        earned.length ? ' · ' + esc(earned.join(', ')) : ''}</span></summary>
      <div class="rowline" style="margin-top:8px">
        <button class="btn btn-sm btn-ghost" onclick="rerollAdvancement(${lvl})">🎲 Re-roll level ${lvl} only</button>
        <span class="muted small">Rolling one level leaves every other level exactly as it stands.</span>
      </div>
    </details>`;
  }
  return out;
}

// The dice half, rolled ONCE and kept — everything else this step shows is
// deterministic and is recomputed on every render.
//
// One proposal per level rather than one for the whole span, which is what
// makes a single level re-rollable. Each level's growth is independent of the
// pool's running total (the proposal reports from/to and only the difference is
// kept), so every call starts from the level-1 character.
function rollAdvancement(force = false, onlyLevel = null) {
  if (!S.cls || S.level <= 1) return;
  if (!force && !onlyLevel && Object.keys(S.levelPools).length) return;
  // Pools are computed lazily, and Review used to be the first step that needed
  // them. This one comes earlier: without it every pool is null here, the
  // proposal skips them all, and the step reports that six levels grew nothing.
  if (!S.pools) computePools();
  const base = characterAtLevelOne();
  for (let lvl = 2; lvl <= S.level; lvl++) {
    if (onlyLevel && onlyLevel !== lvl) continue;
    const p = buildProposal({ ...base, level: lvl - 1 }, S.cls, lvl);
    S.levelPools[lvl] = Object.fromEntries(
      Object.entries(p.pools).map(([f, v]) => [f, v.to - v.from]));
  }
}

function rerollAdvancement(level) {
  rollAdvancement(!level, level || null);
  render();
}

// The level-1 character, in the shape buildProposal reads. Its pools must be
// non-null or the proposal skips them — a class whose H.P. the wizard never
// rolled has nothing to grow.
function characterAtLevelOne() {
  const pools = S.pools || {};
  return {
    level: 1,
    hp_max: pools.hp ?? null, sdc_max: pools.sdc ?? null, mdc_max: pools.mdc ?? null,
    ppe_max: pools.ppe ?? null, isp_max: pools.isp ?? null,
    skills: skillsAtLevelOne(),
  };
}

// Step 3 — the occupation, chosen after the dice.
//
// Rolling before the occupation is known admits a state the old order could not
// reach: a stat block that fails the occupation's minimums. Both classes'
// minimums apply and the stricter of each wins, so a shortfall is only knowable
// here — and it is answered with a re-roll of the failing attribute, never with
// a refusal. See docs/plans/13-rcc-first-wizard.md.
function renderOccupation() {
  const blocker = occBlocker();
  const short = minimumShortfalls();
  $('app').innerHTML = `
  <div class="panel">
    <h2>Occupation <span class="muted small">— what ${esc(S.rcc?.name || 'this character')} trained as</span></h2>
    ${occPicker()}
    ${shortfallPanel(short)}
    ${rerollLog()}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.ATTRIBUTES)">&larr; Back</button>
  ${blocker ? `<span class="nav-why">${esc(blocker)}</span>` : ''}
  <button class="btn btn-primary" ${blocker ? 'disabled' : ''} onclick="nextStep()">Skills &rarr;</button></div>`;
}

// The ONLY thing that blocks this step. A missed minimum deliberately does not:
// the app's standing rule for occupations is that a mismatch warns and never
// refuses, and this is the same class of problem.
function occBlocker() {
  const need = abilityOccOptions(S.rcc, S.abilities);
  if (need && (!S.occ || !need.options.includes(S.occ))) {
    return `Choose an occupation for ${need.name} to continue.`;
  }
  return '';
}

// Attributes the composed minimums now ask more of than the dice gave. Compared
// against the ROLLED value rather than the bonused one, which is how the
// Attributes step already reads a class minimum — the two must not disagree.
function minimumShortfalls() {
  const reqs = S.cls?.attribute_requirements || {};
  return ATTRS
    .filter((a) => reqs[a] != null && S.attrs[a] != null && S.attrs[a] < reqs[a])
    .map((a) => ({ attr: a, have: S.attrs[a], need: reqs[a] }));
}

function shortfallPanel(short) {
  if (!S.occ || !short.length) return '';
  const occName = S.classes.find((c) => c.id === S.occ)?.name || 'this occupation';
  return `<div class="panel-inset" id="minimum-shortfall">
    <h3>Below ${esc(occName)}'s minimum</h3>
    <p class="muted small">Your race and your occupation both set minimums and the stricter of
      each applies, so this is the first step that could know. Re-roll the attribute that fell
      short, or go back and choose an occupation this character meets.</p>
    ${short.map(({ attr, have, need }) => `<div class="chkrow">
      <button class="btn btn-sm" onclick="rerollForMinimum('${attr}')">
        🎲 Re-roll ${attr} <span class="muted">(${esc(S.cls?.attribute_dice?.[attr] || '3d6')})</span></button>
      <span><b>${attr} ${have}</b> <span class="muted">— needs ${need}+, short by ${need - have}</span></span>
    </div>`).join('')}
    <p class="warn">This step will let you carry on, but the save at the end will not: a
      character below its class minimum is refused, the GM's own included.</p>
  </div>`;
}

// Every assisted roll, shown as one. A number that came from a second attempt
// should not sit on the sheet looking like what the dice said first.
function rerollLog() {
  if (!S.minRerolls?.length) return '';
  return `<p class="small muted" style="margin-top:10px"><b>Re-rolled for a minimum:</b>
    ${S.minRerolls.map((r) => `${r.attr} ${r.from} → ${r.to}`).join(' &middot; ')}
    <br>Recorded on the character once it is saved.</p>`;
}

// Re-rolls ONE attribute, with the race's dice for it, and the result stands.
// Rejected on purpose: re-rolling the whole block (throws away good rolls to
// fix one bad one) and quietly raising the attribute to the minimum (several
// books instruct exactly that, and it would leave a number on the sheet that no
// dice produced).
function rerollForMinimum(attr) {
  const from = S.attrs[attr];
  S.attrMethods[attr] = 'roll';
  setRoll(attr);
  S.minRerolls.push({
    attr, from, to: S.attrs[attr],
    need: (S.cls?.attribute_requirements || {})[attr] ?? null,
    occ: S.classes.find((c) => c.id === S.occ)?.name || null,
  });
  render();
}

// Step 2 — attributes
function renderAttributes() {
  const classBonus = derive.classBonuses(skillBonusClass(), 1, rolledAll());
  // Split out so the label can say where a bonus came from. Once skills fold
  // into the same block, "+2 from Glitter Boy" is a lie whenever the +2 is
  // Boxing's - and an attribute bonus the player cannot trace is worse than
  // one shown a step later, which is what this change set out to fix.
  const classOnlyBonus = derive.classBonuses(S.cls, 1, rolledAll());
  const reqs = S.cls.attribute_requirements || {};
  const spent = pbSpent();
  const rows = ATTRS.map((a) => {
    const m = method(a);
    const v = S.attrs[a];
    const dice = S.cls.attribute_dice?.[a];
    let control;
    if (attrAbsent(a)) {
      // No method select and no control at all: there is nothing to roll, buy
      // or type. Offering a disabled input would still read as "a value goes
      // here", which is the impression this exists to remove.
      return `<tr><td><b>${a}</b></td><td colspan="2"><span class="muted">—</span></td>
        <td><span class="attr-note">${esc(S.cls.name)} has no ${a}</span></td></tr>`;
    }
    if (m === 'roll') {
      // An exceptional roll is rare enough that an unexplained 24 off a 3d6
      // reads as a bug, and the second die — earned only by rolling a six on
      // the first — reads as one even when it is correct. So show the working.
      const r = S.attrRolls[a];
      const why = r
        ? ` <span class="attr-note ok">${esc(r.notation)} ${r.base}${r.modifier ? (r.modifier > 0 ? '+' : '') + r.modifier : ''}
            · exceptional +${r.exceptional.join(', +')}</span>` : '';
      control = `<button class="btn btn-sm" onclick="doRoll('${a}')">Roll ${esc(dice || '3d6')}</button> <b>${v ?? '—'}</b>${why}`;
    } else if (m === 'point') {
      control = `<button class="btn btn-sm btn-ghost" onclick="pbAdj('${a}',-1)">−</button> <b>${v ?? PB_BASE}</b>
                 <button class="btn btn-sm btn-ghost" onclick="pbAdj('${a}',1)">+</button>`;
    } else {
      control = `<input type="number" min="1" max="40" value="${v ?? ''}" onchange="manualSet('${a}', this.value)">`;
    }
    const req = reqs[a] ? `<span class="attr-note ${v != null && v < reqs[a] ? 'err' : 'ok'}">need ${reqs[a]}+</span>` : '';
    // "racial dice" stopped being true for a class that SUPERSEDES its race
    // (F11): the Cosmo-Knight's transformation takes whichever of the two is
    // higher per attribute, so the expression beside P.S. is usually the
    // occupation's and the one beside M.E. may still be the race's. Calling
    // both racial would be a small lie in the one place a player checks the
    // number against the book.
    const diceLabel = S.occ && S.cls?.supersedes_race ? 'transformed dice' : 'racial dice';
    // A class bonus is shown here but never rolled into the stored value — what
    // gets saved is what was rolled, and the bonus is added wherever the number
    // is actually used.
    const add = classBonus.attributes[a];
    const floor = classBonus.attribute_minimums?.[a];
    // A dice bonus reads the same as a flat one here; what differs is that the
    // number was rolled, which the class name beside it already implies.
    const raised = v != null && floor != null && (v + (add || 0)) < floor;
    // Where it came from: the class, the skills taken so far, or both.
    const fromClass = classOnlyBonus.attributes[a] || 0;
    const fromSkills = (add || 0) - fromClass;
    const source = !fromSkills ? esc(S.cls.name)
      : (!fromClass ? 'skills taken' : `${esc(S.cls.name)} + skills taken`);
    const boost = add && v != null
      ? ` <span class="attr-note ok">${add > 0 ? '+' : ''}${add} from ${source} = ${v + add}</span>` : '';
    const floorNote = raised
      ? ` <span class="attr-note ok">minimum ${floor} for ${esc(S.cls.name)}</span>` : '';
    return `<tr><td><b>${a}</b></td>
      <td><select onchange="setMethod('${a}', this.value)">
        <option value="roll" ${m === 'roll' ? 'selected' : ''}>Random roll</option>
        <option value="point" ${m === 'point' ? 'selected' : ''}>Point-buy</option>
        <option value="manual" ${m === 'manual' ? 'selected' : ''}>Manual entry</option>
      </select></td>
      <td>${control}</td><td>${req}${boost}${floorNote}${dice ? ` <span class="attr-note">${diceLabel}: ${esc(dice)}</span>` : ''}</td></tr>`;
  }).join('');

  // An absent attribute is not "still to roll" — it is never going to have a
  // value, and counting it here would leave the step permanently unable to
  // continue. It stays in `unmet` when an occupation requires it, which is the
  // fail-closed half: a machine person cannot take a class that needs a P.E.
  const unmet = Object.entries(reqs).filter(([k, min]) => (S.attrs[k] ?? -1) < min);
  const missing = ATTRS.filter((a) => !attrAbsent(a) && S.attrs[a] == null);
  const usesPB = ATTRS.some((a) => method(a) === 'point');
  const over = spent > PB_POOL;
  const canNext = missing.length === 0 && unmet.length === 0 && !over;
  // The panel already warns about missing values and unmet minimums, and this
  // repeats them beside the button on purpose: the button is where you look
  // when you are stuck, and a warning further up the page is not an answer to
  // "why can't I continue". Overspending point-buy had NO warning at all —
  // only a number turning red — so that case is new information.
  const attrWhy = missing.length ? `Still to roll or enter: ${missing.join(', ')}.`
    : unmet.length ? `Class minimum not met: ${unmet.map(([k, v]) => `${k} ${v}+`).join(', ')}.`
    : over ? 'Point-buy pool overspent — free up points to continue.'
    : '';

  $('app').innerHTML = `
  <div class="panel">
    <h2>Attributes <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <div class="rowline">
      <span class="muted small">Set all to:</span>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('roll')">Random</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('point')">Point-buy</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllMethod('manual')">Manual</button>
      <button class="btn btn-sm" onclick="rollAll()">🎲 Roll all random</button>
    </div>
    ${usesPB ? `<p class="small">Point-buy pool: <b class="${over ? 'err' : ''}">${PB_POOL - spent}</b> / ${PB_POOL} left
      <span class="muted">(start 8 · +1 costs 1 pt to 15, 2 pts to 18 · floor 3 · house rule)</span></p>` : ''}
    <table><tr><th>Attr</th><th>Method</th><th>Value</th><th></th></tr>${rows}</table>
    ${missing.length ? `<p class="warn">Still needed: ${missing.join(', ')}</p>` : ''}
    ${unmet.length ? `<p class="warn err">Class minimum not met: ${unmet.map(([k, v]) => `${k} ${v}+`).join(', ')}</p>` : ''}
    ${S.cls.attribute_dice && usesPB ? `<p class="muted small">Note: point-buy/manual ignore racial attribute dice — the class minimums are still enforced.</p>` : ''}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.RACE)">&larr; Back</button>
  ${attrWhy ? `<span class="nav-why">${esc(attrWhy)}</span>` : ''}
  <button class="btn btn-primary" ${canNext ? '' : 'disabled'} onclick="nextStep()">${
    stepApplies(ST.OCCUPATION) ? 'Occupation' : 'Skills'} &rarr;</button></div>`;
}
// A roll's breakdown is cleared whenever the value stops being that roll —
// otherwise "exceptional +4" hangs beside a number the player typed by hand.
function setMethod(a, m) { S.attrMethods[a] = m; if (m !== 'roll') S.attrRolls[a] = null; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; render(); }
// The bulk buttons skip an absent attribute, or "Point-buy" would hand a
// machine person the PB_BASE constitution its book denies it, and "Roll all"
// would leave it holding a value from a method it has no row for.
function setAllMethod(m) { ATTRS.filter((a) => !attrAbsent(a)).forEach((a) => { S.attrMethods[a] = m; if (m !== 'roll') S.attrRolls[a] = null; if (m === 'point') S.attrs[a] = S.attrs[a] ?? PB_BASE; }); render(); }
function doRoll(a) { setRoll(a); render(); }
function rollAll() { ATTRS.filter((a) => !attrAbsent(a)).forEach((a) => { S.attrMethods[a] = 'roll'; setRoll(a); }); render(); }
function manualSet(a, v) { const n = parseInt(v, 10); S.attrs[a] = Number.isFinite(n) && n > 0 ? n : null; S.attrRolls[a] = null; render(); }
function pbAdj(a, delta) {
  const cur = S.attrs[a] ?? PB_BASE;
  const next = cur + delta;
  if (next < PB_FLOOR || next > PB_CAP) return;
  S.attrs[a] = next;
  S.attrRolls[a] = null;
  if (pbSpent() > PB_POOL && delta > 0) { S.attrs[a] = cur; return; }
  render();
}

// Step 3 — skills
// A catalog row belongs to this build's system, or to no system at all.
// NULL/blank means unrestricted, which is how skills.systems has always read and
// is now how spells, psionics and gear read too. A Palladium Fantasy spell
// chapter must not offer its spells to a Rifts mage.
function inSystem(row) {
  const sys = row?.system;
  return !sys || sys === 'both' || sys === S.system;
}

// A forbidden skill is never offered rather than offered and rejected: the
// books state these limits per category, so a player should not be able to
// build most of a character before being told a pick was never legal.
function catalogFor(categories) {
  return S.skillCatalog.filter((sk) =>
    categoryAllows(categories, sk) &&
    (!sk.systems || sk.systems.includes(S.system)));
}
// Single definition, shared with the server-side validator — the two copies
// drifted once already.
const isGroup = isChoiceGroup;

// Name -> catalog entry, built once per catalog load. The skills step performs
// one lookup per rendered skill and re-renders on every toggle, so a linear
// scan here is the difference between constant and quadratic work.
let _skillIndex = null;
function skillByName() {
  if (!_skillIndex) _skillIndex = new Map(S.skillCatalog.map((sk) => [sk.name, sk]));
  return _skillIndex;
}

// How each of a class's related-skill FLOORS is doing, given the picks made so
// far. BOOK-INGEST-AUDIT.md F6: eight classes say "select N other skills, but
// at least two must be selected from espionage", and until `minimums` existed
// the picker offered every pick freely and left the rule in a note.
//
// The server refuses a set that can no longer reach a floor; this is the
// DISPLAY, so the player learns it at the moment of the pick rather than at the
// moment of the save. It counts and reports and blocks nothing - one rule, one
// enforcement point, which is the pair this file has been burnt by splitting
// before.
//
// Categories come from the CATALOG row, not from the class's own list: the
// class names a category it allows, and whether a given skill belongs to it is
// the catalog's answer. The same rule the server validator follows.
function relatedFloors(cls) {
  const index = skillByName();
  return relatedFloorStatus(cls, S.related.map((n) => index.get(n)?.category),
    cls?.skills?.occ_related_skills?.count);
}

// "at least 2 Espionage (1) and 2 Rogue (0)" - the running total per floor,
// beside the running total for the whole list.
function floorsHtml(cls) {
  const { floors } = relatedFloors(cls);
  if (!floors.length) return '';
  const one = (f) => `<span class="${f.met ? 'muted' : 'warn'}">${f.have}/${f.count} `
    + `${esc(f.categories.join(' or '))}</span>`;
  return `<p class="attr-note">The book sets a floor per category: ${floors.map(one).join(', ')}.
    These come OUT OF the picks above, not on top of them, and a character that
    cannot still reach them is refused on save.</p>`;
}

// Class files may omit base/per_level for a required skill — sourcebook class
// pages usually state only the bonus, with the base living in the skill table.
// Fall back to the catalog so imported classes still show real percentages.
// `base` states the percentage outright; `bonus` adds to whatever the skill's
// own base is. A choice group needs the second: "three languages of choice at
// +30%" cannot be one number, because the members of a category start at
// different percentages. Writing 80 there gave every pick 80 regardless.
//
// A non-percentile skill (a W.P., hand to hand) stays at zero: a percentage
// bonus has nothing to modify, exactly as the I.Q. bonus already works.
function resolveSkill(name, explicit = {}) {
  // Exact catalog hit first, and only a MISS in the `Language:` family falls
  // back to the Other row's numbers — the same resolution rule the related and
  // secondary picker applies through `find()` in skillsAtLevelOne(). It is here
  // too because a choice group can now produce `Language: Elven`, which is a
  // real skill on the character and has no catalog row of its own by design. It
  // resolved to `{}` and saved at 0% +0/lvl: a language the class granted, on
  // the sheet, worth nothing and never advancing.
  const cat = skillByName().get(name)
    || (isFamilyName(name) ? (skillByName().get(otherRowFor(name)) || {}) : {});
  // A base a book states as an attribute times a multiplier — "P.P. number x5%"
  // (BOOK-INGEST-AUDIT.md F2). skillBase() falls back to the stored `base`
  // whenever there is no formula, so every row without one is unaffected.
  const catBase = skillBase(cat, S.attrs);
  const base = explicit.base ?? (explicit.bonus && catBase ? catBase + explicit.bonus : catBase);
  return {
    base,
    per_level: explicit.per_level ?? cat.per_level ?? 0,
    category: cat.category || 'Class',
  };
}

// Names already spoken for: fixed class skills, every choice-group pick made so
// far, and anything chosen as related/secondary.
function takenNames() {
  const occ = (S.cls.skills?.occ_skills || [])
    .filter((s) => !isGroup(s)).map((s) => String(s.name).toLowerCase());
  const groups = Object.values(S.groupPicks).flat().map((n) => String(n).toLowerCase());
  return new Set([...occ, ...groups, ...S.related.map((n) => n.toLowerCase()), ...S.secondary.map((n) => n.toLowerCase())]);
}
// The class with the bonuses its SKILLS grant folded in.
//
// Boxing is "+1 attack per melee, +2 parry & dodge, +1 roll, +2 P.S." The sheet
// has applied those since the bonuses column landed, but the wizard did not:
// composeClass() runs on the Class step, before a single skill is chosen, so
// there is nothing to fold in at that point. The numbers appeared only after
// saving, which is the same values arriving late and reads as a bug.
//
// Deliberately a separate helper from psiClass() rather than an extension of
// it. They answer different questions — psiClass() resolves what the class IS
// once a rolled tier is known, this resolves what the character's own choices
// have added — and they are needed on different steps.
//
// takenNames() is the single source for "which skills does this character
// hold", already used by the pickers, so a skill counted here is exactly one
// the wizard shows as taken.
function skillBonusClass() {
  if (!S.cls) return S.cls;
  const held = takenNames();
  const rows = (S.skillCatalog || []).filter((sk) => held.has(String(sk.name).toLowerCase()));
  // The wizard only ever builds a level 1 character, so that is what the
  // Hand to Hand schedule is read at. Levelling up goes through the sheet,
  // which composes with the character's real level.
  const extra = bonusesFromSkills(rows, 1);
  if (!extra) return S.cls;
  return { ...S.cls, bonuses: sumBonusGroups(S.cls.bonuses, extra) };
}

function renderSkills() {
  // The COMPOSED class: a rolled major psionic has half the related-skill
  // allowance, and the Skills step has to show the number that actually applies.
  // Held rather than re-derived, because the per-category floors below have to
  // read the same object the count came from.
  const effective = psiClass();
  const sk = effective.skills || {};

  // A Military Occupational Specialty decides which skills the rest of this
  // step lists, so it is asked first. Unchosen, the class's own O.C.C. skills
  // are all there is - which is the honest state, not a broken one.
  const mosCfg = sk.mos;
  const mosHtml = !mosCfg ? '' : `
    <div class="block">
      <h3>Military Occupational Specialty</h3>
      <div class="attr-note">${esc(mosCfg.note || 'Select one area of specialty. '
        + 'Every skill under it is granted on top of the O.C.C. skills.')}</div>
      <div class="pickgrid">
        ${(mosCfg.options || []).map((o) => {
          const id = o.id || o.name;
          const on = String(S.mos || '').toLowerCase() === String(id).toLowerCase();
          const grants = (o.skills || []).map((x) => x.name
            || `${x.choose} from ${(x.categories || x.from || []).join(', ')}`).join(', ');
          return `<button class="pick${on ? ' on' : ''}" onclick="pickMos('${esc(String(id))}')">
            <b>${esc(o.name)}</b><span class="attr-note">${esc(grants)}</span></button>`;
        }).join('')}
      </div>
    </div>`;
  const relatedCfg = sk.occ_related_skills || { count: 0, categories: [] };
  const secondaryCfg = sk.secondary_skills || { count: 0 };
  const taken = takenNames();

  // Fixed skills auto-populate; choice-groups ("pick N of these") get an inline
  // pick control. Either kind may carry an advisory `note`.
  const occRows = (sk.occ_skills || []).map((s, gi) => {
    const noteHtml = s.note ? `<div class="attr-note" style="margin:0 0 4px 18px">↳ ${esc(s.note)}</div>` : '';
    if (!isGroup(s)) {
      const r = resolveSkill(s.name, s);
      // A named skill with `choose` is taken that many times.
      return `<div class="chkrow">✔ <span>${esc(s.name)}${s.choose > 1 ? ` ×${s.choose}` : ''}</span>
        <span class="pct">${r.base ? r.base + '%' + (r.per_level ? ' +' + r.per_level + '/lvl' : '') : '—'}</span></div>${noteHtml}`;
    }
    const picked = S.groupPicks[gi] || [];
    // Either an enumerated `from` list, or `categories` — "two piloting skills
    // of choice" resolves against the catalog.
    const listed = (s.from || []).length
      ? (s.from || []).map((raw) => (typeof raw === 'string' ? raw : raw?.name))
      : catalogFor(s.categories).map((sk) => sk.name);
    // A language picked through the Other row is stored under its own name, so
    // it is not in `listed` and would render nowhere — leaving the player no
    // way to un-pick it. Same synthesis the related/secondary picker does.
    const optionNames = listed.concat(
      picked.filter((n) => isFamilyName(n) && !isRepeatableRow(n) && !listed.includes(n)));

    // A category group offers the whole category, which includes skills this
    // very class already grants outright — the Chiang-Ku grants Advanced Math
    // and Art as fixed skills and then offers Science and Technical. Picking
    // one listed the skill twice and the save was refused with a duplicate.
    //
    // Anything already held is dropped from the options rather than shown
    // disabled: it is not a choice you might make, it is one you already have.
    // Everything the character already has by any route: the class's fixed
    // skills, picks made in OTHER choice groups, and the related and secondary
    // skills chosen on this same step. takenNames() is exactly that set, minus
    // this group's own picks — which must stay selectable so they can be
    // unticked.
    const mine = new Set((S.groupPicks[gi] || []).map((n) => String(n).toLowerCase()));
    const alreadyHeld = new Set([...takenNames()].filter((n) => !mine.has(n)));
    const opts = optionNames.filter((name) => name && !alreadyHeld.has(String(name).toLowerCase())).map((name) => {
      // The Other row is taken once PER LANGUAGE and never reads as already
      // picked, exactly as it does on the related/secondary picker. Without
      // this it is a plain checkbox, and "two languages of choice" produces a
      // character holding one skill literally called "Language: Other" — which
      // is what two Priests of Light in production are carrying.
      const repeatable = isRepeatableRow(name);
      const on = !repeatable && picked.includes(name);
      const blocked = !on && picked.length >= s.choose;
      const hint = repeatable
        ? ' <span class="muted small">— once per language; you will be asked which</span>' : '';
      return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}; margin-left:18px">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="group" data-group="${gi}" data-limit="${s.choose}" data-name="${esc(name)}">
        <span>${esc(name)}${hint}</span>
        <span class="pct">${s.base ? s.base + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—'}</span></label>`;
    }).join('');
    return `<div class="chkrow"><b>Pick ${s.choose}</b>
      <span class="pct">${esc((s.categories || []).map(categoryLabel).join(', '))} ${picked.length}/${s.choose} chosen</span></div>${noteHtml}${opts}`;
  }).join('');

  const schedule = relatedCfg.schedule || [];

  // The category gate already narrows these, which is why 128 skills has been
  // survivable — but "Any category" on the secondary list is the whole catalog,
  // and a checkbox list you have to scroll to search is not a search.
  // A ticked skill always stays visible, or filtering would appear to un-pick it.
  const pickList = (catalog, chosen, kind, limit, query) => {
    // Custom languages exist on the character but not in the catalog, so the
    // concat below would never surface them — synthesize their rows from the
    // Other entry's numbers or a pick could not be seen or un-picked.
    const custom = chosen
      .filter((n) => isFamilyName(n) && !catalog.some((s) => s.name === n))
      .map((n) => ({ ...(skillByName().get(otherRowFor(n)) || {}), name: n }));
    const shown = Picker.filter(catalog, query)
      .concat(catalog.filter((s) => chosen.includes(s.name) && !Picker.match(s, query)))
      .concat(custom);
    if (!shown.length) return '<p class="muted small">Nothing matches that filter.</p>';
    // Grouped by category. "Any category" on the secondary list is the whole
    // catalog, and a flat run of 200+ checkboxes gives no sense of where you are
    // in it. Sorted by category then name so the headings come out in a stable
    // order rather than the catalog's.
    const ordered = [...shown].sort((a, b) =>
      (a.category || '￿').localeCompare(b.category || '￿')
      || (a.name || '').localeCompare(b.name || ''));
    const sizes = ordered.reduce((m, x) => { const g = x.category || 'Uncategorized';
      return m.set(g, (m.get(g) || 0) + 1); }, new Map());
    let lastCat = null;
    return ordered.map((s) => {
      const cat = s.category || 'Uncategorized';
      const head = cat !== lastCat
        ? `<div class="pick-group">${esc(cat)}<span class="pick-group-n">${sizes.get(cat)}</span></div>`
        : '';
      lastCat = cat;
      const on = chosen.includes(s.name);
      // Two reasons a row is blocked, and they used to render identically. The
      // cap explains itself: the counter above the list reads N/M chosen and
      // EVERY unpicked row dims at the same moment. Already-taken is the one
      // that looks arbitrary, because it dims a single row for a reason living
      // on a different list - takenNames() spans the O.C.C. skills, the group
      // picks and both pick lists. Only that branch earns a reason on the row.
      const held = !on && taken.has(s.name.toLowerCase());
      const blocked = held || (!on && chosen.length >= limit);
      const hint = isRepeatableRow(s.name)
        ? ' <span class="muted small">— once per language; you will be asked which</span>'
        : held ? ' <span class="muted small">— already on this character</span>' : '';
      // The category is the heading now, so the row carries only its numbers.
      return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="skill" data-kind="${kind}" data-name="${esc(s.name)}">
        <span>${esc(s.name)}${hint}</span>
        <span class="pct">${(() => {
          // F2: a formula row's percentage comes from the character's
          // attributes, not from the stored `base` — which is 0 on those rows
          // and would render as an em dash, telling the player that a skill
          // they can take and which the sheet will score has no percentage.
          const b = skillBase(s, S.attrs);
          return b ? b + '%' + (s.per_level ? ' +' + s.per_level + '/lvl' : '') : '—';
        })()}</span>
      </label>`;
    }).join('');
  };

  const relatedPool = catalogFor(relatedCfg.categories);
  const secondaryPool = catalogFor(null);

  $('app').innerHTML = `
  <div class="panel">
    <h2>Skills <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    ${mosHtml}
    <h3>Class skills <span class="muted small">(automatic)</span></h3>
    ${occRows || '<p class="muted small">None listed.</p>'}
    <div class="cols" style="margin-top:14px">
      <div>
        <h3>Related skills — ${S.related.length}/${relatedCfg.count}</h3>
        <p class="muted small">Allowed: ${esc((relatedCfg.categories || []).map(categoryLabel).join(', ') || '—')}</p>
        ${floorsHtml(effective)}
        ${schedule.length ? `<p class="attr-note">Also grants ${schedule.map((s) => `+${s.count} at level ${s.level}`).join(', ')}
          — recorded on the class, not yet prompted at level-up.</p>` : ''}
        ${Picker.inputHtml({ id: 'related-filter', value: S.relatedFilter,
          placeholder: 'Filter…', shown: Picker.filter(relatedPool, S.relatedFilter).length,
          total: relatedPool.length })}
        ${pickList(relatedPool, S.related, 'related', relatedCfg.count, S.relatedFilter)}
      </div>
      <div>
        <h3>Secondary skills — ${S.secondary.length}/${secondaryCfg.count}</h3>
        <p class="muted small">Any category, base % only.</p>
        ${Picker.inputHtml({ id: 'secondary-filter', value: S.secondaryFilter,
          placeholder: 'Filter…', shown: Picker.filter(secondaryPool, S.secondaryFilter).length,
          total: secondaryPool.length })}
        ${pickList(secondaryPool, S.secondary, 'secondary', secondaryCfg.count, S.secondaryFilter)}
      </div>
    </div>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="prevStep()">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(ST.EQUIPMENT)">Equipment &rarr;</button></div>`;
}
function toggleGroupPick(groupIndex, name, limit) {
  const list = S.groupPicks[groupIndex] || (S.groupPicks[groupIndex] = []);
  // Language: Other prompts instead of toggling, and the pick is stored under
  // the language's own name — the same rule toggleSkill() applies on the
  // related and secondary lists. It lives in both places because the two
  // pickers are genuinely different controls; what must not differ is what the
  // row MEANS, and for a long time it did: the same row was a repeatable
  // prompt on one step and a plain checkbox on another.
  if (isRepeatableRow(name)) {
    if (list.length >= limit) return;
    const typed = window.prompt(promptFor(name));
    if (typed === null) return;
    const full = familySkillName(name, typed);
    if (!full) return;
    if (takenNames().has(full.toLowerCase())) { alert(full + ' is already on this character.'); return; }
    list.push(full);
    render();
    return;
  }
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1);
  else if (list.length < limit) list.push(name);
  render();
}

function toggleSkill(kind, name) {
  const list = kind === 'related' ? S.related : S.secondary;
  // Language: Other is taken once per language, each a separate skill named
  // for it — so the row prompts instead of toggling, and never reads as
  // "already picked". Un-picking happens on the named row it created.
  if (isRepeatableRow(name)) {
    // No limit check here: the row's checkbox is disabled at the limit by the
    // same blocked logic every other row gets.
    const typed = window.prompt(promptFor(name));
    if (typed === null) return;
    const full = familySkillName(name, typed);
    if (!full) return;
    if (takenNames().has(full.toLowerCase())) { alert(full + ' is already on this character.'); return; }
    list.push(full);
    render();
    return;
  }
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1); else list.push(name);
  render();
}

// Step 4 — equipment

// Class markdown cites gear by slug, and a slug can be retired by a catalog
// merge or a rename without the markdown ever being touched. Falling through to
// the redirect is what keeps that class's starting gear resolving to a real
// item instead of degrading to a bare text line with no stats.
function findItem(slug) {
  if (!slug) return null;
  const direct = S.items.find((it) => it.slug === slug);
  if (direct) return direct;
  const to = S.itemRedirects[String(slug).toLowerCase()];
  return to ? S.items.find((it) => it.slug === to) : null;
}

// A class's starting gear is a mix of fixed items and "one energy pistol of
// choice" groups. Fixed entries land in the inventory immediately; the choices
// are held aside until the player resolves them, because picking for them would
// be inventing a decision the book left open.
function initEquipment() {
  const starting = S.cls.equipment_starting || [];

  // The choices are re-derived every time, not guarded by equipInit. A restored
  // draft brings back which options were TICKED but not what the options were,
  // so deriving them once and skipping thereafter would leave the picks with
  // nothing to render against.
  S.gearChoices = starting.flatMap((eq, gi) => !isGearChoice(eq) ? [] : [{
    gi,
    choose: eq.choose,
    qty: eq.qty || 1,
    label: eq.label || '',
    options: (eq.from || []).map((slug) => ({ slug, item: findItem(slug) })),
  }]);

  // The inventory itself is guarded, because it is editable — re-deriving it
  // would undo every hand-added or removed row. The guard also makes a dice
  // quantity (the Priest of Light's 1D6 vials of holy water) roll ONCE: the
  // rolled number lands in S.equipment, which the draft persists.
  if (S.equipInit) return;
  S.equipment = starting.flatMap((eq) => {
    if (isGearChoice(eq)) return [];
    const item = findItem(eq.item_id);
    const qty = rollQuantity(eq.qty ?? 1);
    return [item
      ? { item_id: item.id, name: item.name, qty, source: 'starting' }
      : { custom_name: eq.item_id.replace(/-/g, ' '), qty, source: 'starting', notes: 'starting gear (not in item catalog yet)' }];
  });
  S.equipInit = true;
}

// Every choice resolved? Starting gear is finite and the book intends the
// character to have it, so an unresolved choice is an oversight rather than a
// deliberate omission — the step will not advance until they are all made.
function gearChoicesOutstanding() {
  return S.gearChoices.filter((c) => (S.gearPicks[c.gi] || []).length < c.choose);
}

// What actually gets saved: the fixed starting gear and anything added by hand,
// plus the choices the player resolved. Kept as a function rather than pushed
// into S.equipment so a pick stays reversible — unticking a box must take the
// item back out, and a copy in the inventory list would survive it.
function equipmentPayload() {
  return [...S.equipment, ...pickedGear()];
}

// Resolved picks, folded into the inventory shape the save endpoint expects.
function pickedGear() {
  const out = [];
  for (const c of S.gearChoices) {
    for (const slug of S.gearPicks[c.gi] || []) {
      const item = findItem(slug);
      out.push(item
        ? { item_id: item.id, name: item.name, qty: c.qty, source: 'starting' }
        : { custom_name: slug.replace(/-/g, ' '), qty: c.qty, source: 'starting', notes: 'chosen starting gear (not in item catalog yet)' });
    }
  }
  return out;
}

function toggleGearPick(gi, slug, limit) {
  const picked = S.gearPicks[gi] || (S.gearPicks[gi] = []);
  const at = picked.indexOf(slug);
  if (at >= 0) picked.splice(at, 1);
  else if (picked.length < limit) picked.push(slug);
  render();
}
function renderEquipment() {
  initEquipment();
  const rows = S.equipment.map((e, i) => {
    // The remove button's entire accessible name was the glyph, so a reader met
    // twenty-one identical "✕" with nothing to say which row each belonged to.
    // escHtml() does not escape quotes and this goes inside an attribute, so a
    // custom item name gets one more pass before it lands there.
    const label = `Remove ${esc(e.name || e.custom_name)}`.replace(/"/g, '&quot;');
    return `<tr><td>${esc(e.name || e.custom_name)}</td><td>×${e.qty}</td>
     <td><span class="tag">${e.source}</span></td><td class="muted small">${esc(e.notes || '')}</td>
     <td><button class="btn btn-sm btn-ghost" aria-label="${label}" title="${label}"
       onclick="rmEquip(${i})">✕</button></td></tr>`;
  }).join('');
  // Filtered rather than dumped: the gear catalog is 74 rows and grows with
  // every book imported, and picking one item out of a native dropdown that
  // long means scrolling past everything you did not want.
  const gearMatches = Picker.filter(S.items, S.gearFilter);
  const catalogOpts = gearMatches.map((it) => `<option value="${it.id}">${esc(it.name)}</option>`).join('');

  // "One energy pistol of choice" — the book leaves it open, so the player
  // closes it here. Same shape as the skill choice-groups on step 3.
  const choiceBlocks = S.gearChoices.map((c) => {
    const picked = S.gearPicks[c.gi] || [];
    const opts = c.options.map((o) => {
      const on = picked.includes(o.slug);
      const blocked = !on && picked.length >= c.choose;
      const detail = o.item
        ? [o.item.category, o.item.weight_lbs ? `${o.item.weight_lbs} lb` : '', o.item.cost ? `${o.item.cost}` : '']
          .filter(Boolean).join(' · ')
        : 'not in the catalog yet';
      return `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}; margin-left:18px">
        <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
          data-act="gear" data-group="${c.gi}" data-limit="${c.choose}" data-slug="${esc(o.slug)}">
        <span>${esc(o.item ? o.item.name : o.slug.replace(/-/g, ' '))}</span>
        <span class="pct">${esc(detail)}</span></label>`;
    }).join('');
    return `<div class="chkrow"><b>Pick ${c.choose}${c.label ? ` — ${esc(c.label)}` : ''}</b>
      <span class="pct">${picked.length}/${c.choose} chosen</span></div>${opts}`;
  }).join('');

  // Names what is outstanding rather than counting it. `Still to choose:
  // energy pistol, vibro-blade` tells you where to look; `2 gear choices`
  // makes you go and find them. Falls back to a count only when a class left
  // a choice group unlabelled.
  const outstandingGroups = gearChoicesOutstanding();
  const outstanding = outstandingGroups.length;
  const gearLabels = outstandingGroups.map((c) => c.label).filter(Boolean);
  const gearWhy = !outstanding ? ''
    : gearLabels.length === outstanding
      ? `Still to choose: ${gearLabels.join(', ')}.`
      : `${outstanding} gear choice${outstanding === 1 ? '' : 's'} still to make.`;

  $('app').innerHTML = `
  <div class="panel">
    <h2>Equipment <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <table>${rows || '<tr><td class="muted">Nothing yet.</td></tr>'}</table>
    ${choiceBlocks ? `<h3>Choose your starting gear</h3>
      <p class="muted small">Your class leaves these open.</p>${choiceBlocks}` : ''}
    <h3>Add from item catalog</h3>
    ${S.items.length ? `
      ${Picker.inputHtml({ id: 'cat-filter', value: S.gearFilter,
        placeholder: 'Filter gear by name, category or book…',
        shown: gearMatches.length, total: S.items.length })}
      <div class="rowline">
        <select id="cat-item" size="1">${catalogOpts || '<option value="">— no match —</option>'}</select>
        <input type="number" id="cat-qty" value="1" min="1">
        <button class="btn btn-sm" ${gearMatches.length ? '' : 'disabled'} onclick="addCatalog()">Add</button>
      </div>` : '<p class="muted small">Catalog is empty for this system.</p>'}
    <h3>Add custom item</h3>
    <div class="rowline">
      <input type="text" id="cust-name" placeholder="Name">
      <input type="text" id="cust-notes" placeholder="Notes (optional)" style="width:190px">
      <input type="number" id="cust-qty" value="1" min="1">
      <button class="btn btn-sm" onclick="addCustom()">Add</button>
    </div>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.SKILLS)">&larr; Back</button>
  ${gearWhy ? `<span class="nav-why">${esc(gearWhy)}</span>` : ''}
  <button class="btn btn-primary" ${outstanding ? 'disabled' : ''} onclick="goStep(ST.POWERS)">Powers &rarr;</button></div>`;
}
function rmEquip(i) { S.equipment.splice(i, 1); render(); }
function addCatalog() {
  const item = S.items.find((it) => it.id === +$('cat-item').value);
  if (item) S.equipment.push({ item_id: item.id, name: item.name, qty: Math.max(1, +$('cat-qty').value || 1), source: 'catalog' });
  render();
}
function addCustom() {
  const name = $('cust-name').value.trim();
  if (!name) return;
  S.equipment.push({ custom_name: name, notes: $('cust-notes').value.trim() || undefined, qty: Math.max(1, +$('cust-qty').value || 1), source: 'custom' });
  render();
}

// Step 5 — powers (magic / psionics guided picker)
// Psionic starting-count house rule (class frontmatter can override with
// psionics.powers_starting / psionics.categories_allowed — no schema change):
// minor = 2 powers, major = 6, master = 8; Super category is master-only.
const PSI_DEFAULT_COUNTS = { minor: 2, major: 6, master: 8 };
function psiConfig(cls) {
  const p = cls.psionics;
  if (!p) return null;
  return {
    count: p.powers_starting ?? PSI_DEFAULT_COUNTS[p.type] ?? 2,
    cats: p.categories_allowed ??
      (p.type === 'master' ? ['Healing', 'Physical', 'Sensitive', 'Super'] : ['Healing', 'Physical', 'Sensitive']),
    // A class may name the exact powers its picks come from - the Burster's
    // "select three minor psionic powers from the following list". A named
    // list is MORE specific than a category gate, so it replaces it rather
    // than narrowing within it, exactly as a skill choice-group's `from`
    // list does.
    from: Array.isArray(p.powers_from) && p.powers_from.length ? p.powers_from.map(String) : null,
  };
}

// The class as this character actually plays it, once a rolled tier is folded
// in. Everything on this step reads THIS rather than S.cls, so a rolled psychic
// and a born one go down exactly the same path — the alternative was a second
// parallel set of branches for "psionics, but from the table".
function psiClass() {
  return withRolledPsionics(S.cls, { psychic_tier: S.psiRoll?.tier, psychic_shape: S.psiShape });
}

// Only a class that grants no psionics of its own rolls, and only if its race
// has psychic potential at all. The book offers the table and the psychic
// O.C.C.s as alternatives, not as things that stack.
const canRollPsionics = () => classRollsForPsionics(S.cls);

// Rolling a major psionic halves the related-skill allowance (p.21), and this
// wizard asks for skills BEFORE powers — the book asks in the other order. So a
// roll can invalidate picks already made. Trim the excess and say so, rather
// than letting the character reach Review holding more than the class allows.
//
// Trims from the end, so the picks made first survive.
function trimRelatedToAllowance() {
  const limit = psiClass().skills?.occ_related_skills?.count ?? 0;
  if (S.related.length <= limit) { S.psiTrimmed = 0; return; }
  S.psiTrimmed = S.related.length - limit;
  S.related = S.related.slice(0, limit);
}

function doPsiRoll() {
  S.psiRoll = rollPsionics();
  trimRelatedToAllowance();
  // A new roll invalidates whatever the previous one allowed.
  S.psiShape = S.psiRoll.tier ? PSIONIC_TIER_RULES[S.psiRoll.tier].shapes[0].id : null;
  S.psiCategory = null;
  S.psi = [];
  render();
}
// "A player may skip step three entirely if he or she does not want a character
// with psionics." Recorded as a deliberate no rather than an unrolled blank.
function skipPsiRoll() {
  S.psiRoll = { roll: null, tier: null, skipped: true };
  trimRelatedToAllowance();
  S.psiShape = null; S.psiCategory = null; S.psi = [];
  render();
}
function setPsiShape(id) {
  S.psiShape = id; S.psiCategory = null; S.psi = []; render();
}
function setPsiCategory(cat) {
  S.psiCategory = cat || null;
  // Powers already chosen from another category are no longer legal.
  S.psi = S.psi.filter((n) => S.psiCatalog.find((p) => p.name === n)?.category === S.psiCategory);
  render();
}
// Step 3 as the book runs it: one percentile roll, and most characters get
// nothing. The odds are shown because a 74% chance of "no psionics" looks like
// a broken button otherwise.
function psiRollHtml() {
  const r = S.psiRoll;
  const odds = `<p class="muted small">01-09 major &nbsp;·&nbsp; 10-25 minor &nbsp;·&nbsp; 26-00 none.
    Most characters get nothing, and that is the common result rather than a failure.</p>`;

  if (!r) {
    return `<h3>Psionics</h3>
      <p class="muted">This class grants no psychic powers of its own, so the character rolls for them.</p>
      ${odds}
      <p><button class="btn btn-primary" onclick="doPsiRoll()">🎲 Roll for psionics</button>
        <button class="btn btn-ghost" onclick="skipPsiRoll()">Skip — no psionics</button></p>`;
  }

  const outcome = r.skipped
    ? `<b>Skipped</b> — this character has no psychic powers.`
    : `Rolled <b>${r.roll}</b> — ${r.tier ? `<b>${esc(r.tier)} psionic</b>` : '<b>no psionics</b>'}.`;

  // The major psionic's price, and what it cost this character in particular.
  const penalty = r.tier === 'major'
    ? `<p class="attr-note">A major psionic's related-skill allowance is halved
       (now ${psiClass().skills?.occ_related_skills?.count ?? 0}).
       ${S.psiTrimmed ? `<b>${S.psiTrimmed} already-chosen ${S.psiTrimmed === 1 ? 'skill was' : 'skills were'} removed.</b>` : ''}</p>` : '';

  // A tier the roll produced brings a choice of allowance with it, where the
  // book gives one. A minor psychic has only the single shape, so no radio
  // group is drawn for it.
  const spec = r.tier ? PSIONIC_TIER_RULES[r.tier] : null;
  const shapes = spec && spec.shapes.length > 1
    ? `<p class="small" style="margin-top:8px">How the powers are taken:</p>` + spec.shapes.map((s) =>
        `<label class="chkrow" style="cursor:pointer"><input type="radio" name="psi-shape"
          ${S.psiShape === s.id ? 'checked' : ''} onchange="setPsiShape('${s.id}')">
          <span>${esc(s.label)}</span></label>`).join('')
    : '';

  const shape = r.tier ? psionicShape(r.tier, S.psiShape) : null;
  const cats = shape && shape.categories === 1
    ? `<div class="rowline" style="margin-top:8px">
        <label class="small" style="min-width:132px">Category</label>
        <select onchange="setPsiCategory(this.value)" style="flex:1">
          <option value=""${S.psiCategory ? '' : ' selected'}>— choose —</option>
          ${PSIONIC_CATEGORIES.map((c) => `<option value="${c}"${c === S.psiCategory ? ' selected' : ''}>${c}</option>`).join('')}
        </select></div>`
    : '';

  return `<h3>Psionics</h3>
    <p>${outcome}</p>
    ${r.tier ? `<p class="muted small">I.S.P. ${esc(spec.isp_base)} — rolled on Review.</p>` : odds}
    ${penalty}
    ${shapes}${cats}
    <p style="margin-top:8px"><button class="btn btn-sm btn-ghost" onclick="doPsiRoll()">↻ reroll</button>
      ${r.tier ? `<button class="btn btn-sm btn-ghost" onclick="skipPsiRoll()">Take none</button>` : ''}</p>`;
}

// Group headers for the two picker lists, same idiom as the sheet's
// Psionics & Magic box (.power-group). The list arrives as filter matches
// plus chosen-but-unmatched entries appended so a pick never vanishes —
// sorting the combined list files those into their proper groups instead of
// leaving them dangling at the end. With a header per group, the per-row
// "L3 ·" / "Healing ·" prefix is redundant and gone.
function spellGroupRows(list, count, kind = 'spell', gi = null) {
  const sorted = [...list].sort((a, b) =>
    ((a.level ?? Infinity) - (b.level ?? Infinity)) || (a.name || '').localeCompare(b.name || ''));
  const sizes = sorted.reduce((m, x) => { const g = x.level != null ? `Level ${x.level}` : 'Unleveled';
    return m.set(g, (m.get(g) || 0) + 1); }, new Map());
  let last = null;
  return sorted.map((sp) => {
    const group = sp.level != null ? `Level ${sp.level}` : 'Unleveled';
    const head = group !== last
      ? `<div class="pick-group">${esc(group)}<span class="pick-group-n">${sizes.get(group)}</span></div>`
      : '';
    last = group;
    const sel = powerList(kind, gi);
    const on = sel.includes(sp.name);
    const blocked = !on && sel.length >= count;
    return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
      <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
        data-act="power" data-kind="${kind}" data-name="${esc(sp.name)}"${
        gi == null ? '' : ` data-gi="${gi}"`}>
      <span>${esc(sp.name)}${sp.ppe_note ? ` <span class="muted small">&mdash; ${esc(sp.ppe_note)}</span>` : ''}</span>
      <span class="pct">${sp.ppe}${sp.ppe_note && sp.ppe > 0 ? '+' : ''} P.P.E.</span></label>`;
  }).join('');
}

function psiGroupRows(list, count, kind = 'psi', gi = null) {
  const sorted = [...list].sort((a, b) =>
    (a.category || '￿').localeCompare(b.category || '￿') || (a.name || '').localeCompare(b.name || ''));
  const sizes = sorted.reduce((m, x) => { const g = x.category || 'Uncategorized';
    return m.set(g, (m.get(g) || 0) + 1); }, new Map());
  let last = null;
  return sorted.map((p) => {
    const group = p.category || 'Uncategorized';
    const head = group !== last
      ? `<div class="pick-group">${esc(group)}<span class="pick-group-n">${sizes.get(group)}</span></div>`
      : '';
    last = group;
    const sel = powerList(kind, gi);
    const on = sel.includes(p.name);
    const blocked = !on && sel.length >= count;
    return head + `<label class="chkrow" style="${blocked ? 'opacity:0.45' : 'cursor:pointer'}">
      <input type="checkbox" ${on ? 'checked' : ''} ${blocked ? 'disabled' : ''}
        data-act="power" data-kind="${kind}" data-name="${esc(p.name)}"${
        gi == null ? '' : ` data-gi="${gi}"`}>
      <span>${esc(p.name)}${p.isp_note ? ` <span class="muted small">&mdash; ${esc(p.isp_note)}</span>` : ''}</span>
      <span class="pct">${p.isp}${p.isp_note && p.isp > 0 ? '+' : ''} I.S.P.</span></label>`;
  }).join('');
}

// Spells a class knows OUTRIGHT, listed rather than picked.
//
// The Shifter's twenty and the Techno-Wizard's twenty-five have reached the
// character since powersPayload started folding them in, and the step where a
// player looks for their spells showed none of them. Read-only rows rather than
// ticked checkboxes: a disabled checkbox beside a spell the character HAS reads
// as one it may not take.
function grantedSpellHtml(names) {
  if (!names.length) return '';
  const entries = names.map((n) => {
    const sp = S.spellCatalog.find((x) => x.name === n);
    // A granted name the catalog does not carry still reaches the character,
    // with no level and no cost - the same silence the two pickers already call
    // out on a `from` list, said here for the same reason.
    return `<li>${esc(n)} <span class="muted small">&mdash; ${sp
      ? `level ${sp.level}, ${sp.ppe}${sp.ppe_note && sp.ppe > 0 ? '+' : ''} P.P.E.`
      : 'not in the catalog yet'}</span></li>`;
  });
  const columns = [];
  for (let i = 0; i < entries.length; i += REVIEW_COLUMN) columns.push(entries.slice(i, i + REVIEW_COLUMN));
  return `<div class="review-cols">${columns
    .map((col) => `<ul class="review-col">${col.join('')}</ul>`).join('')}</div>`;
}

// Picks a class states as a LEVEL-1 SCHEDULE ENTRY, where nothing reads them.
// Said out loud rather than honoured — see startingPicksFor.
function misfiledSpellNote(n) {
  return n ? `<p class="attr-note">${n} more ${n === 1 ? 'spell is' : 'spells are'} stated in this
    class's per-level schedule at level 1, which creation does not read — a starting pick belongs in
    <code>spells_starting</code>. They are not offered here and nothing is guessed.</p>` : '';
}

// The level-1 spell picks, one block per starting group.
//
// One group is the overwhelming case and keeps writing into the flat `S.spells`
// it always has, so nothing about a saved draft changes. A class that SPLITS
// its starting pick - or bounds it with a named list, which is the Elemental
// Fusionist's eighteen - gets a block per group, keyed exactly as the
// Advancement step keys its per-grant pickers. They are the same problem.
//
// A class with NO starting pick gets a sentence saying which of the several
// nothings it is, and no picker at all. It used to get "Spells — 0/0" over a
// filter box and 543 disabled rows, which said only that something had gone
// wrong. `startingPicksFor` draws the distinctions; this states them.
function startingSpellHtml() {
  const magic = S.cls.magic;
  const start = startingPicksFor(S.cls, 'spell');
  if (!start.applicable) return '';
  const groups = start.groups;
  const granted = grantedSpellHtml(start.granted);
  const misfiled = misfiledSpellNote(start.misfiled);

  if (!groups.length) {
    const head = (tail) => `<h3>Spells${tail}
      <span class="muted small">(${esc(magic.type)} magic)</span></h3>`;
    if (start.granted.length) {
      return `<h3>Spells &mdash; ${start.granted.length} known
        <span class="muted small">(${esc(magic.type)} magic &middot; granted by the class)</span></h3>
        <p class="muted small">The book names this class's spells outright, so there is nothing to
          choose here. All ${start.granted.length} are already on the character.</p>`
        + granted + misfiled;
    }
    if (start.unknown) {
      // Word for word the posture advPowerBlock takes one level up, because it
      // is the same posture: a class that never recorded a number gets said so
      // rather than shown an empty list, which reads as "this class starts with
      // no spells".
      return head('') + `<p class="warn">This class's definition does not record how many spells it
        starts with, so none are offered here. That is not the same as none — the books do state it
        for most casters. Re-import the class with <code>spells_starting</code>, or add them by hand
        on the sheet afterwards. Nothing is guessed.</p>` + misfiled;
    }
    return head(' &mdash; none at level 1') + `<p class="muted small">Its definition states a
      starting count of zero, which is an answer and not a gap — a dragon hatchling knows no spells
      until second level. Anything learned later is on the Advancement step.</p>` + misfiled;
  }

  const many = groups.length > 1;
  const kind = many ? 'spell-start' : 'spell';
  const total = start.total;
  const takenAll = () => groups.flatMap((g, i) => powerList(kind, many ? i : null));

  const blocks = groups.map((g, gi) => {
    const idx = many ? gi : null;
    const chosen = powerList(kind, idx);
    // A named list is the tightest restriction and REPLACES the level cap - a
    // group that names its spells is not also asking about levels. The same
    // rule spellGrantBlock applies to a level-up grant.
    const named = g.from && new Set(g.from.map((n) => n.toLowerCase()));
    // A spell is learned once, so the other groups' picks are out of this one.
    const elsewhere = new Set(takenAll().filter((n) => !chosen.includes(n))
      .map((n) => String(n).toLowerCase()));
    const pool = S.spellCatalog.filter((sp) => inSystem(sp)
      && (named ? named.has(String(sp.name).toLowerCase())
                : (!g.spell_levels || g.spell_levels.includes(sp.level)))
      && !elsewhere.has(String(sp.name).toLowerCase()));
    // A chosen spell stays visible whatever the filter says, or narrowing the
    // list would look like it had un-picked something.
    const list = Picker.filter(pool, S.spellFilter)
      .concat(pool.filter((sp) => chosen.includes(sp.name) && !Picker.match(sp, S.spellFilter)));
    // A name the catalog does not carry would silently shrink the list, so say
    // so - the same reasoning the psionic named list already uses.
    const unknownNamed = g.from
      ? g.from.filter((n) => !S.spellCatalog.some((x) => String(x.name).toLowerCase() === n.toLowerCase()))
      : [];
    const gate = named ? `a list of ${g.from.length}`
      : g.spell_levels ? `levels ${g.spell_levels.join(', ')}` : 'any spell level';
    return (many ? `<p class="small" style="margin-top:12px"><b>${g.count}
        ${g.count === 1 ? 'spell' : 'spells'}</b> <span class="muted">from ${esc(gate)}</span>
        <span class="muted">— ${chosen.length}/${g.count}</span></p>` : '')
      + (g.note ? `<p class="attr-note">${esc(g.note)} — the catalog cannot check this one, so it
        is yours to honour.</p>` : '')
      + (unknownNamed.length ? `<p class="attr-note">${unknownNamed.length} named
        ${unknownNamed.length === 1 ? 'spell is' : 'spells are'} not in the catalog yet:
        ${esc(unknownNamed.join(', '))}.</p>` : '')
      + Picker.inputHtml({ id: many ? `spell-filter-${gi}` : 'spell-filter', value: S.spellFilter,
          placeholder: 'Filter spells…',
          shown: Picker.filter(pool, S.spellFilter).length, total: pool.length })
      + spellGroupRows(list, g.count, kind, idx);
  }).join('');

  const one = groups[0];
  const caption = many ? 'in groups the book keeps apart'
    : one.from ? `from the class list of ${one.from.length}`
    : one.spell_levels ? `levels ${one.spell_levels.join(', ')}` : null;
  // Granted spells first: they are what the character already has, and the
  // picker below is what it still owes a decision on.
  return (start.granted.length ? `<h3>Spells &mdash; ${start.granted.length} granted by the class
      <span class="muted small">(already on the character)</span></h3>` + granted : '')
    + `<h3>Spells — ${takenAll().length}/${total}
    <span class="muted small">(${esc(magic.type)} magic${caption ? ' · ' + esc(caption) : ''})</span></h3>`
    + blocks + misfiled;
}

// The level-1 psionic picks when the book SPLITS them across categories - the
// Delphi Juicer's "3 Physical + 1 Super", the Mind Mage's three from each of
// four. Stored as one open count over every category they touch, both let a
// player take every power from the widest one (CLASS-AUDIT.md S9).
//
// No rolled tier reaches here: rolling happens only for a class that declares
// no psionics block at all, and a split is declared on one. So this needs
// neither the from_roll shape nor the single-category prompt.
function startingPsiHtml(cls, groups) {
  const tier = cls.psionics.type;
  const total = groups.reduce((n, g) => n + g.count, 0);
  const takenAll = () => groups.flatMap((g, i) => powerList('psi-start', i));

  const blocks = groups.map((g, gi) => {
    const chosen = powerList('psi-start', gi);
    const named = g.from && new Set(g.from.map((n) => n.toLowerCase()));
    const elsewhere = new Set(takenAll().filter((n) => !chosen.includes(n))
      .map((n) => String(n).toLowerCase()));
    const inCategory = S.psiCatalog.filter((p) => inSystem(p)
      && (named ? named.has(String(p.name).toLowerCase())
                : (!g.categories || g.categories.includes(p.category)))
      && !elsewhere.has(String(p.name).toLowerCase()));
    // The per-power tier gate, exactly as the single-group picker applies it:
    // a book can say an individual power needs a higher tier than its category.
    const pool = inCategory.filter((p) => derive.meetsTier(tier, p.min_tier));
    const gated = inCategory.length - pool.length;
    const list = Picker.filter(pool, S.psiFilter)
      .concat(pool.filter((p) => chosen.includes(p.name) && !Picker.match(p, S.psiFilter)));
    const gate = named ? `a list of ${g.from.length}`
      : g.categories ? g.categories.join(', ') : 'any category';
    return `<p class="small" style="margin-top:12px"><b>${g.count}
      ${g.count === 1 ? 'power' : 'powers'}</b> <span class="muted">from ${esc(gate)}</span>
      <span class="muted">— ${chosen.length}/${g.count}</span></p>`
      + (g.note ? `<p class="attr-note">${esc(g.note)} — the catalog cannot check this one.</p>` : '')
      + (gated ? `<p class="attr-note">${gated} more ${gated === 1 ? 'power needs' : 'powers need'}
        a higher psychic tier than ${esc(tier)}.</p>` : '')
      + Picker.inputHtml({ id: `psi-filter-${gi}`, value: S.psiFilter, placeholder: 'Filter powers…',
          shown: Picker.filter(pool, S.psiFilter).length, total: pool.length })
      + psiGroupRows(list, g.count, 'psi-start', gi);
  }).join('');

  return `<h3>Psionic powers — ${takenAll().length}/${total}
    <span class="muted small">(${esc(tier)} psychic · in groups the book keeps apart)</span></h3>
    <p class="muted small">Each group has its own categories and its own budget. A power already
      chosen is not offered again.</p>` + blocks;
}

function renderPowers() {
  const cls = psiClass();
  const psi = psiConfig(cls);
  const rolling = canRollPsionics();
  // Asked of the builder rather than of `S.cls.magic` being truthy: the Godling
  // carries `magic: { type: "none" }`, which is a block saying the class is NOT
  // a caster, and testing the block put a Spells heading over a class the step
  // should have called empty.
  const spells = startingSpellHtml();
  let inner = '';
  if (!spells && !psi && !rolling) {
    inner = `<p class="muted">This class has no spellcasting or psionics — carry on.</p>`;
  }
  if (rolling) inner += psiRollHtml();
  inner += spells;
  const psiSplit = psi ? startingGroups(cls, 'psionic') : [];
  if (psi && psiSplit.length > 1) {
    inner += startingPsiHtml(cls, psiSplit);
  } else if (psi) {
    const tier = cls.psionics.type;
    // A shape that allows a single category narrows the pool to the one chosen.
    // Until it IS chosen the list stays empty rather than showing everything —
    // offering powers the character cannot legally take reads as a bug.
    const shape = cls.psionics.from_roll ? psionicShape(tier, S.psiShape) : null;
    const single = shape && shape.categories === 1;
    const allowed = single ? (S.psiCategory ? [S.psiCategory] : []) : psi.cats;
    // A named list replaces the category gate; the book has already said
    // exactly which powers this class may take.
    const named = psi.from && new Set(psi.from.map((n) => n.toLowerCase()));
    const inCategory = named
      ? S.psiCatalog.filter((p) => inSystem(p) && named.has(String(p.name).toLowerCase()))
      : S.psiCatalog.filter((p) => inSystem(p) && categoryAllows(allowed, p));
    // A name the catalog does not carry would silently shrink the list, so
    // say so - the same reasoning the skill cross-reference uses.
    const unknownNamed = named
      ? psi.from.filter((n) => !S.psiCatalog.some((x) => String(x.name).toLowerCase() === n.toLowerCase()))
      : [];
    // Two gates, and they are not the same. The category gate has always been
    // here (Super is master-only). This is the per-power one: a book can state
    // that an individual power needs a higher tier than its category implies.
    const pool = inCategory.filter((p) => derive.meetsTier(tier, p.min_tier));
    const gated = inCategory.length - pool.length;
    const list = Picker.filter(pool, S.psiFilter)
      .concat(pool.filter((p) => S.psi.includes(p.name) && !Picker.match(p, S.psiFilter)));

    inner += `<h3>Psionic powers — ${S.psi.length}/${psi.count}
      <span class="muted small">(${esc(tier)} psychic · ${psi.from ? 'from the class list'
        : (single && S.psiCategory ? [S.psiCategory] : psi.cats).map(categoryLabel).join(', ')})</span></h3>`
      + (single && !S.psiCategory
        ? `<p class="attr-note">Choose a category above — all ${psi.count} powers come from the same one.</p>` : '') +
      // Say that something is being withheld, so a short list reads as a rule
      // rather than as a gap in the catalog. Counted against the tier-gated
      // pool, not the filtered view — the filter is yours, the gate is not.
      (gated ? `<p class="attr-note">${gated} more ${gated === 1 ? 'power needs' : 'powers need'} a higher psychic tier than ${esc(tier)}.</p>` : '') +
      (unknownNamed.length ? `<p class="attr-note">${unknownNamed.length} named ${unknownNamed.length === 1 ? 'power is' : 'powers are'} not in the catalog yet: ${esc(unknownNamed.join(', '))}.</p>` : '') +
      Picker.inputHtml({ id: 'psi-filter', value: S.psiFilter, placeholder: 'Filter powers…',
        shown: Picker.filter(pool, S.psiFilter).length, total: pool.length }) +
      psiGroupRows(list, psi.count);
  }
  $('app').innerHTML = `
  <div class="panel">
    <h2>Magic &amp; Psionics <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    ${inner}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.EQUIPMENT)">&larr; Back</button>
  <button class="btn btn-primary" onclick="nextStep()">${
    stepApplies(ST.ADVANCEMENT) ? 'Advancement' : 'Details'} &rarr;</button></div>`;
}

// Step 6 — bio details. Optional; the derived percentages come straight from
// the attribute tables and are shown so the numbers are not a surprise later.
function renderDetails() {
  // Money is rolled with the pools, and this step is the first place it is
  // shown — without this the field sits empty here and mysteriously fills in on
  // Review. Lazy and idempotent, so arriving via Review does not re-roll.
  if (!S.pools) computePools();
  const d = derive.bio(S.attrs, null, derive.classBonuses(skillBonusClass(), 1, rolledAll()));
  $('app').innerHTML = `
  <div class="panel">
    <h2>Details <span class="muted small">— ${esc(S.cls.name)}</span></h2>
    <p class="muted">The identity block from the printed sheet. <b>Alignment is required</b> — the book
      calls it the one mandatory part of this step, and there is deliberately no neutral. Everything
      else is optional and can be filled in later on the character sheet.</p>
    <p><button class="btn btn-sm" onclick="rollBioAll()">🎲 Roll the background tables</button>
      <span class="muted small">Fills only what is still blank. Every 🎲 rolls its own table (p.32-33);
      all of it is optional.</span></p>
    <div class="cols" style="margin-top:12px">
      <div>${BIO_FIELDS.slice(0, BIO_HALF).map(bioInput).join('')}</div>
      <div>${BIO_FIELDS.slice(BIO_HALF).map(bioInput).join('')}</div>
    </div>
    <h3>Derived from attributes</h3>
    <p class="small">Invoke Trust/Intimidate <b>${d.invoke_trust_pct}%</b> (M.A. ${S.attrs.MA ?? '—'})
      &nbsp;·&nbsp; Charm/Impress <b>${d.charm_impress_pct}%</b> (P.B. ${S.attrs.PB ?? '—'})</p>
    <p class="muted small">Combat bonuses and saving throws are derived the same way and appear on the
      sheet, where any of them can be overridden.</p>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="prevStep()">&larr; Back</button>
  <button class="btn btn-primary" onclick="goStep(ST.REVIEW)">Review &rarr;</button></div>`;
}

function bioInput([key, label]) {
  // The label is a SIBLING of the control, so without a for= it names nothing:
  // the whole step read back as twenty anonymous textboxes. The id is derived
  // from the field key, which is a fixed slug from BIO_FIELDS, so two rows
  // cannot collide and nothing has to be tracked by hand.
  const id = `bio-${key}`;
  // Alignment is the one field on this step the book calls mandatory, and the
  // only one with a closed set of answers. Everything else here is free text
  // flavour that can stay blank forever.
  const control = key === 'alignment'
    ? `<select id="${id}" onchange="setBio('alignment', this.value)" style="flex:1">${rules.alignmentOptions(S.bio.alignment)}</select>`
    : `<input type="text" id="${id}" value="${esc(S.bio[key] ?? '')}" onchange="setBio('${key}', this.value)" style="flex:1">`;
  // Every field the book prints a table for gets a die beside it. The rest are
  // free text: there is no table for a character's name.
  const rollable = !!rules.BACKGROUND_TABLES[key];
  const die = rollable ? ` <button class="btn btn-sm btn-ghost" title="Roll on the ${esc(rules.BACKGROUND_TABLES[key].label)} table"
    onclick="rollBio('${key}')">🎲</button>` : '';
  // The Age table's own note: double the years for an elf, dwarf or changeling.
  const ageOpt = key === 'age'
    ? ` <label class="small" title="Multiply the rolled age by two, per the table's note">
        <input type="checkbox" ${S.longLived ? 'checked' : ''} onchange="setLongLived(this.checked)"> long-lived race (×2)</label>` : '';
  return `<div class="rowline">
    <label class="small" for="${id}" style="min-width:132px">${esc(bioLabel([key, label]))}${key === 'alignment' ? ' <span class="req">*</span>' : ''}</label>
    ${control}${die}${ageOpt}
  </div>`;
}
// The book's tables are optional and nothing derives from them, so a roll just
// fills the field — no confirmation, and typing over it is always allowed.
function rollBio(key) {
  const r = rules.rollBackground(key, { double: key === 'age' && S.longLived });
  if (!r || r.text == null) return;
  S.bio[key] = r.text;
  S.bioRolls[key] = r.roll;
  render();
}

// Fills only what is still blank, so a name and age already decided survive.
function rollBioAll() {
  for (const key of Object.keys(rules.BACKGROUND_TABLES)) {
    if (S.bio[key]) continue;
    rollBio(key);
  }
  render();
}

// Re-rolls the age when the multiplier changes, since the old value was rolled
// under the other assumption and leaving it would be quietly wrong.
function setLongLived(on) {
  S.longLived = !!on;
  if (S.bio.age) rollBio('age'); else render();
}

function setBio(key, value) {
  const v = String(value).trim();
  if (v) S.bio[key] = v; else delete S.bio[key];
}
// Four lists, not two: what the class grants at level 1, and what the levels
// above it earned. Kept apart so each picker counts against its own budget —
// folding the level-6 spells into S.spells would put the Powers step over its
// starting allowance and read as a bug.
function powerList(kind, gi = null) {
  switch (kind) {
    case 'spell': return S.spells;
    case 'psi': return S.psi;
    // Per grant, because each level's spells are capped by that level.
    case 'spell-adv': return S.levelSpells[gi] || (S.levelSpells[gi] = []);
    // The -start pair is to the flat `spells`/`psi` what -adv is to them: the
    // same level, a different rule, so each group keeps its own budget. Only a
    // class that SPLITS its level-1 pick uses them.
    case 'spell-start': return S.spellGroups[gi] || (S.spellGroups[gi] = []);
    case 'psi-start': return S.psiGroups[gi] || (S.psiGroups[gi] = []);
    default: return S.levelPsi[gi] || (S.levelPsi[gi] = []);
  }
}

function togglePower(kind, name, gi = null) {
  const list = powerList(kind, gi);
  const i = list.indexOf(name);
  if (i >= 0) list.splice(i, 1); else list.push(name);
  render();
}
function powersPayload() {
  // Powers and spells the CLASS grants outright, as opposed to the ones the
  // player picked. They used to reach the character as nothing at all: the
  // wizard saved only S.spells and S.psi, so a Mind Melter's four automatic
  // powers and a Shifter's twenty known spells were listed by the class and
  // held by nobody. Granted ones come first and a pick that duplicates one
  // is dropped, so the list stays a set.
  const cls = psiClass();
  const auto = (list) => (list || []).filter((n) => typeof n === 'string' && n.trim()).map((n) => n.trim());
  const autoSpells = auto(cls?.magic?.spells);
  const autoPsi = auto(cls?.psionics?.powers);
  const held = (a, b) => {
    const seen = new Set(a.map((n) => n.toLowerCase()));
    return [...a, ...b.filter((n) => !seen.has(String(n).toLowerCase()))];
  };
  // Four sources, in order of how the character came by them: granted by the
  // class, chosen at level 1, then learned on the way up. `held` keeps the list
  // a set, so a spell learned later that the class already granted is dropped
  // rather than listed twice.
  //
  // The level-1 picks arrive from two places, and exactly one of them is ever
  // non-empty: the flat list when the class has a single starting group, the
  // per-group lists when it splits them. Concatenating both means neither the
  // reader nor the writer has to know which shape this class used.
  const flat = (byGroup) => Object.values(byGroup).flat().filter(Boolean);
  const startSpells = [...S.spells, ...flat(S.spellGroups)];
  const startPsi = [...S.psi, ...flat(S.psiGroups)];
  const spellNames = held(held(autoSpells, startSpells), flat(S.levelSpells));
  const psiNames = held(held(autoPsi, startPsi), flat(S.levelPsi));
  return [
    ...spellNames.map((n) => {
      const sp = S.spellCatalog.find((x) => x.name === n);
      return { type: 'spell', name: n, level: sp?.level, cost: sp?.ppe,
               ...(sp?.ppe_note ? { cost_note: sp.ppe_note } : {}) };
    }),
    ...psiNames.map((n) => {
      const p = S.psiCatalog.find((x) => x.name === n);
      // cost_note marks a variable cost: `cost` is the minimum, and the sheet's
      // use button deducts it while the note says how the real spend grows.
      return { type: 'psionic', name: n, category: p?.category, cost: p?.isp,
               ...(p?.isp_note ? { cost_note: p.isp_note } : {}) };
    }),
  ];
}

// Step 6 — review & save
//
// A character's I.Q. adds a ONE-TIME bonus to every skill percentage (p.22).
// One-time is the operative word: it lands in the starting number and never
// again, which is why it is added here at creation rather than anywhere that
// runs per level.
//
// It reaches secondary skills too. The book's "no skill bonuses are applicable"
// is about the bonus printed in parentheses on the O.C.C. page — it says so in
// the same breath, "the bonus indicated in parentheses applies only to O.C.C.
// related skill selections". The I.Q. bonus is a separate paragraph about the
// character rather than the occupation, and withholding it would make a
// genius's hobby skills identical to a dullard's.
//
// A skill with no percentage at all — W.P.s, hand to hand — stays at zero. It
// is not a percentile skill, so there is nothing for a percentage bonus to
// modify, and giving it a number would invent a roll that does not exist.
const SKILL_PCT_CAP = 98;   // p.22: "there is always a margin for error"

// The character's skills as they stand at level 1 — the class's own, the
// choice-group picks, and the related and secondary skills chosen on the
// Skills step. Split out from skillsPayload because the Advancement step needs
// exactly this: the input a level-up proposal is computed against.
function skillsAtLevelOne() {
  const find = (n) => skillByName().get(n)
    || (isFamilyName(n) ? { ...(skillByName().get(otherRowFor(n)) || {}), name: n } : {});
  const occ = S.cls.skills?.occ_skills || [];
  const iq = derive.bio(S.attrs, null, derive.classBonuses(skillBonusClass(), 1, rolledAll())).iq_skill_bonus_pct || 0;

  // pct stays the true current percentage, because level-up increments it and
  // the sheet prints it. iq_bonus records how much of it came from I.Q. so the
  // number can explain itself rather than being unexplained arithmetic.
  const withIq = (row) => {
    if (!row.pct) return { ...row, iq_bonus: 0 };
    return { ...row, pct: Math.min(SKILL_PCT_CAP, row.pct + iq), iq_bonus: iq };
  };

  // Read off the COMPOSED class, the same source renderSkills() builds its
  // picker from. A rolled major psionic halves the related allowance without
  // touching the category list, so the two agree either way — but they are one
  // question ("what may this character take, and at what percentage") and
  // reading it from two places is how the picker and the saved sheet drift.
  const relatedCats = () => psiClass().skills?.occ_related_skills?.categories || [];

  // Choice-group picks are stored exactly like fixed class skills, inheriting
  // the group's base/per_level.
  const groupPicks = occ.flatMap((s, gi) => !isGroup(s) ? [] :
    (S.groupPicks[gi] || []).map((name) => {
      const r = resolveSkill(name, s);
      return { name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
    }));
  return [
    ...occ.filter((s) => !isGroup(s)).map((s) => {
      const r = resolveSkill(s.name, s);
      return { name: s.name, category: 'Class', pct: r.base, per_level: r.per_level, type: 'occ' };
    }),
    ...groupPicks,
    // The class's own per-category bonus — "Technical: Any (+10%)" — added to
    // the catalog base. Only to a skill that HAS a base: a W.P. or a hand to
    // hand sits at 0 because it is not percentile, and adding ten to it would
    // invent a roll that does not exist. Same guard resolveSkill() uses for a
    // choice group's `bonus`, for the same reason.
    ...S.related.map((n) => {
      const row = find(n);
      // F2: a formula-derived base, falling back to the stored one.
      const base = skillBase(row, S.attrs) || 0;
      return { name: n, category: row.category, pct: base ? base + categoryBonus(relatedCats(), row) : 0,
               per_level: row.per_level || 0, type: 'related' };
    }),
    // Secondary skills get no O.C.C. bonus, but they are not frozen: "all
    // skills increase as the character grows in experience". Storing 0 here
    // stopped them advancing forever, so a level 10 character's hobby skills
    // sat at their level 1 values.
    ...S.secondary.map((n) => ({ name: n, category: find(n).category, pct: skillBase(find(n), S.attrs) || 0, per_level: find(n).per_level || 0, type: 'secondary' })),
  ].map(withIq);
}

// What actually gets saved: the level-1 skills advanced to the starting level,
// plus anything picked with the grants those levels earned.
//
// The two halves follow OPPOSITE rules and that is the whole reason they are
// computed separately. A skill held since level 1 advances by its per-level
// step for every level gained. A skill picked at level 5 is NEW and starts at
// its catalog base — it does not arrive back-dated with five levels of bonus.
function skillsPayload() {
  const rows = skillsAtLevelOne();
  if (S.level <= 1) return rows;
  const gained = S.level - 1;
  const advanced = rows.map((sk) => (sk.pct && sk.per_level
    ? { ...sk, pct: Math.min(SKILL_PCT_CAP, sk.pct + sk.per_level * gained) }
    : sk));
  return [...advanced, ...levelPickRows()];
}

// Skills chosen with the picks the levels granted. `gained_at_level` records
// which level earned each, the same provenance a live level-up writes.
// Which slot each level-gained power filled, so the server can check it
// against the right grant. The wizard's grant index IS the order
// spellGrantsFor returned, so the slot rides along from there.
function levelPowerPicks(kind) {
  const grants = (kind === 'spell' ? spellGrantsFor : psionicGrantsFor)(S.cls, 1, S.level);
  const chosenBy = kind === 'spell' ? S.levelSpells : S.levelPsi;
  const out = [];
  (grants.grants || []).forEach((g, gi) => {
    for (const name of (chosenBy[gi] || []).filter(Boolean)) {
      out.push({ kind, name, granted_at_level: g.level, slot: g.slot ?? 0 });
    }
  });
  return out;
}

function levelPickRows() {
  const find = (n) => skillByName().get(n)
    || (isFamilyName(n) ? { ...(skillByName().get(otherRowFor(n)) || {}), name: n } : {});
  const out = [];
  skillGrantsFor(S.cls, 1, S.level).forEach((g, gi) => {
    for (const name of (S.levelPicks[gi] || []).filter(Boolean)) {
      const r = find(name);
      out.push({
        name, category: r.category, pct: r.base || 0, per_level: r.per_level || 0,
        type: g.kind === 'secondary' ? 'secondary' : 'related',
        gained_at_level: g.level,
      });
    }
  });
  return out;
}

// How many of the granted picks were actually spent. The server recomputes the
// allowance from the class and banks whatever this leaves over, so a wrong
// number here cannot grant a character more picks than its class allows.
function picksSpent() {
  return Object.values(S.levelPicks).flat().filter(Boolean).length;
}
// ---------- review layout ----------
// The review used to run everything together as one dot-separated paragraph.
// A Chiang-Ku Hatchling arrives with 31 skills, which as prose is unreadable
// and — more to the point — hides the duplicates that make a save fail.

const REVIEW_COLUMN = 15;   // entries per column before a new one starts

function poolRow(label, v) {
  return v == null ? '' : `<div class="stat-row"><span>${label}</span><b>${v}</b></div>`;
}

// A section laid out in columns of REVIEW_COLUMN, so a long list reads down
// rather than wrapping across. Omitted entirely when there is nothing in it —
// a class with no spells should not show an empty Spells heading.
function listSection(title, entries) {
  if (!entries.length) return '';
  const columns = [];
  for (let i = 0; i < entries.length; i += REVIEW_COLUMN) {
    columns.push(entries.slice(i, i + REVIEW_COLUMN));
  }
  return `<h3>${title} <span class="muted small">(${entries.length})</span></h3>
    <div class="review-cols">
      ${columns.map((col) => `<ul class="review-col">${col.map((e) => `<li>${e}</li>`).join('')}</ul>`).join('')}
    </div>`;
}

// Choice groups the player has not finished — "Pick 2" with one ticked.
//
// Read from S.groupPicks, which is what the Skills step's own pickers write,
// so these are the SAME numbers the player watched count up there. The server
// audit reports the same gap and hedges it as `approximate`, because it works
// backwards from a saved skill list where a group pick is indistinguishable
// from a skill the class granted by name. Here nothing has been flattened yet
// and the count is exact, so the hedge would be false and is not repeated.
function shortGroups() {
  const occ = psiClass().skills?.occ_skills || [];
  return occ.flatMap((g, gi) => {
    if (!isGroup(g)) return [];
    const want = parseInt(g.choose, 10);
    if (!Number.isFinite(want) || want <= 0) return [];
    const have = (S.groupPicks[gi] || []).length;
    if (have >= want) return [];
    const from = (g.from || []).map((r) => (typeof r === 'string' ? r : r?.name)).filter(Boolean);
    const label = from.length ? from.join(' / ')
      : (g.categories || []).map(categoryLabel).join(' / ') || 'the listed options';
    return [{ want, have, label }];
  });
}

function renderReview() {
  if (!S.pools) computePools();
  if (S.level > 1) rollAdvancement();
  const p = poolsPayload();
  const campaigns = S.campaigns.filter((c) => c.system === S.system);
  const stat = (label, v) => v != null ? `<span class="statline">${label}: <b>${v}</b></span>` : '';
  $('app').innerHTML = `
  <div class="panel">
    <h2>Review &amp; save</h2>
    <div class="rowline"><label class="small">Character name:</label>
      <input type="text" id="char-name" value="${esc(S.charName)}" placeholder="e.g. Sir Roderick" onchange="S.charName=this.value.trim()"></div>
    <div class="rowline"><label class="small">Campaign:</label>
      <select id="campaign-sel" onchange="S.campaignId=+this.value||null">
        <option value="">— pick —</option>
        ${campaigns.map((c) => {
          // Disabled rather than hidden, the barred-occupation pattern: a
          // player looking for their table should learn it is closed, not
          // that it does not exist. The server refuses regardless.
          const joinable = c.can_join !== false;
          return `<option value="${c.id}" ${S.campaignId === c.id ? 'selected' : ''}${joinable ? '' : ' disabled'}>${esc(c.name)} (GM: ${esc(c.gm_email)})${joinable ? '' : ' — closed to new characters'}</option>`;
        }).join('')}
      </select>
      <span class="muted small">or new:</span>
      <input type="text" id="new-campaign" value="${esc(S.newCampaign)}" placeholder="New campaign name" onchange="S.newCampaign=this.value.trim()">
    </div>

    <h3>${esc(S.cls.name)} <span class="muted small">(${esc(S.system)} · ${esc(S.cls.category)})</span>
      — Level ${S.level}, ${(startingXp()).toLocaleString()} XP</h3>
    ${S.level > 1 ? `<p class="small muted">Starting above level 1: the pools below include
      every level's growth, and ${picksSpent()} of
      ${skillGrantsFor(S.cls, 1, S.level).reduce((n, g) => n + g.count, 0)} granted skill picks
      are chosen — the rest are banked and wait on the sheet.</p>` : ''}
    <p class="small">Alignment: ${S.bio.alignment
      ? `<b>${esc(S.bio.alignment)}</b>${rules.alignmentGroup(S.bio.alignment) ? ` <span class="muted">(${rules.alignmentGroup(S.bio.alignment)})</span>` : ''}`
      : '<span class="warn">not chosen — required, see Details</span>'}</p>
    ${(() => {
      // A per-category floor the picks no longer reach (F6). The server refuses
      // this set, so saying so here turns an opaque failure at the last button
      // into a sentence naming the step to go back to.
      // Only an UNREACHABLE floor, which is exactly what the server refuses. A
      // floor merely unmet is a player who has picks left to spend, and telling
      // them the save will fail would be false.
      const { short, unreachable } = relatedFloors(psiClass());
      return unreachable ? `<p class="small warn">This class requires at least
        ${short.map((f) => `${f.count} ${esc(f.categories.join(' or '))}`).join(' and ')}
        among its related skills, and the picks left cannot reach it — go back to
        Skills, or the save will be refused.</p>` : '';
    })()}
    ${(() => {
      // WARN, DO NOT BLOCK. The save succeeds either way and the primary button
      // stays live — docs/wizard-and-sheet.md argues against gating on these and
      // that reasoning stands. What it did not argue for was saying nothing at
      // all: until now the only surface in the app that mentioned an unfinished
      // choice group was the admin-only character audit, AFTER the save.
      const short = shortGroups();
      if (!short.length) return '';
      const one = (g) => `${g.have}/${g.want} from ${esc(g.label)}`;
      return `<div class="advisory"><b>Still to pick on the Skills step:</b> ${short.map(one).join('; ')}. You can save without them — the class simply grants fewer skills than it offers.</div>`;
    })()}

    <div class="review-stats">
      <div class="stat-col">
        <h4>Attributes</h4>
        ${ATTRS.map((a) => `<div class="stat-row"><span>${a}</span><b>${S.attrs[a] ?? '—'}</b></div>`).join('')}
      </div>
      <div class="stat-col">
        <h4>Pools <button class="btn btn-sm btn-ghost" onclick="computePools(true); render()">↻ reroll</button></h4>
        ${poolRow('H.P.', p.hp)}${poolRow('S.D.C.', p.sdc)}${poolRow('M.D.C.', p.mdc)}
        ${poolRow('P.P.E.', p.ppe)}${poolRow('I.S.P.', p.isp)}
        ${S.bio.money ? poolRow(rules.currencyLabel(S.system), S.bio.money) : ''}
        <p class="muted small" style="margin-top:6px">Rolled from the class formulas${
          S.level > 1 ? ', levels included' : ''}. Reroll if your GM lets you.</p>
      </div>
    </div>

    ${listSection('Skills', skillsPayload().map((s) => esc(s.name)
      + (s.pct ? ` <span class="muted">${s.pct}%</span>` : '')
      + (s.iq_bonus ? ` <span class="muted small">+${s.iq_bonus} I.Q.</span>` : '')))}
    ${listSection('Equipment', equipmentPayload().map((e) => esc(e.name || e.custom_name) + (e.qty > 1 ? ` <span class="muted">×${e.qty}</span>` : '')))}
    ${listSection('Spells', powersPayload().filter((x) => x.type === 'spell')
      .map((x) => esc(x.name) + ` <span class="muted">L${x.level} · ${x.cost} P.P.E.</span>`))}
    ${listSection('Psionic powers', powersPayload().filter((x) => x.type === 'psionic')
      .map((x) => esc(x.name) + ` <span class="muted">${esc(x.category)} · ${x.cost} I.S.P.</span>`))}
    <p class="warn" id="save-msg"></p>
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="goStep(ST.DETAILS)">&larr; Back</button>
  <button class="btn btn-primary" ${S.saving ? 'disabled' : ''} onclick="save()">💾 Save character</button></div>`;
}
async function save() {
  S.charName = $('char-name').value.trim();
  S.newCampaign = $('new-campaign').value.trim();
  const msg = $('save-msg');
  if (!S.charName) { msg.textContent = 'Give your character a name.'; return; }
  if (!S.campaignId && !S.newCampaign) { msg.textContent = 'Pick a campaign or name a new one.'; return; }
  // "ALL players must choose an alignment for their character" (p.23). Caught
  // here rather than server-side so it cannot retroactively lock the editing of
  // characters created before the field existed.
  if (!S.bio.alignment) {
    msg.textContent = 'Choose an alignment on the Details step — the book requires one, and there is no neutral.';
    return;
  }
  S.saving = true; msg.textContent = 'Saving…';
  try {
    let campaignId = S.campaignId;
    if (!campaignId) {
      const created = await api('campaigns', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ name: S.newCampaign, system: S.system }) });
      campaignId = created.campaign.id;
    }
    const rolled = rolledAll();
    const body = {
      // The RACE's id, not the composed object's. They agree today — compose
      // spreads the race — but the payload means "the class the player picked"
      // and reading it off the merged object is a coincidence, not a statement.
      campaign_id: campaignId, name: S.charName, class_id: S.rcc.id,
      class_variant: S.variant || undefined,
      occ_class_id: S.occ || undefined,
      occ_class_variant: S.occVariant || undefined,
      mos: S.mos || undefined,
      psychic_tier: S.psiRoll?.tier || undefined,
      psychic_shape: S.psiRoll?.tier ? (S.psiShape || undefined) : undefined,
      // Both halves summed. Sending S.attrBonuses alone would drop every dice
      // bonus the occupation granted — the same loss the composition rules
      // already had to be taught once.
      // The level the character STARTS at. XP is not sent: the server sets it
      // to the level's own threshold, so the two cannot disagree.
      level: S.level,
      // How many granted picks were spent. The server recomputes the allowance
      // and banks the remainder, so this cannot over-grant.
      picks_spent: picksSpent(),
      attributes: S.attrs, attribute_bonuses: rolled.attributes,
      rolled_bonuses: { combat: rolled.combat, saves: rolled.saves }, abilities: S.abilities,
      skills: skillsPayload(), powers: powersPayload(), pools: poolsPayload(),
      bio: S.bio,
      items: equipmentPayload().map((e) => ({ item_id: e.item_id, custom_name: e.custom_name, qty: e.qty, notes: e.notes })),
    };
    const res = await api('characters', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    S.savedId = res.id;
    await recordMinRerolls(res.id);
    // The build is a real character now; the draft has nothing left to protect.
    await discardDraft();
    render();
  } catch (err) {
    // Say WHICH rule broke. The class rules are enforced server-side, so this
    // is the only place a player finds out what to change.
    const details = errorDetails(err);
    msg.innerHTML = details.length
      ? `Save failed: ${esc(err.message)}<ul class="err-list">`
        + details.map((d) => `<li>${esc(d)}</li>`).join('') + '</ul>'
      : `Save failed: ${esc(err.message)}`;
  } finally {
    S.saving = false;
  }
}

// Saved confirmation view — the full editable sheet lives in sheet.html
async function renderSaved() {
  $('app').innerHTML = '<p class="muted">Loading saved character…</p>';
  try {
    const { character: c, items } = await api('characters/' + S.savedId);
    const attrs = c.attributes || {};
    const stat = (label, v) => v != null ? `<span class="statline">${label}: <b>${v}</b></span>` : '';
    const byType = (t) => (c.skills || []).filter((s) => s.type === t);
    const skillLine = (list) => list.map((s) => esc(s.name) + (s.pct ? ` ${s.pct}%` : '')).join(' · ') || '—';
    $('app').innerHTML = `
    <div class="panel">
      <h2>✅ ${esc(c.name)} <span class="muted small">saved — #${c.id}</span></h2>
      <p class="muted">${esc(c.class_id)} · Level ${c.level} · ${c.xp} XP · Campaign: ${esc(c.campaign_name)} (${esc(c.campaign_system)}) · Player: ${esc(c.player_email)}</p>
      <h3>Attributes</h3>
      <div>${ATTRS.map((a) => stat(a, attrs[a])).join('')}</div>
      <h3>Pools</h3>
      <div>${stat('H.P.', c.hp_current)}${stat('S.D.C.', c.sdc_current)}${stat('M.D.C.', c.mdc_current)}${stat('P.P.E.', c.ppe_current)}${stat('I.S.P.', c.isp_current)}</div>
      <h3>Skills</h3>
      <p class="small"><b>Class:</b> ${skillLine(byType('occ'))}</p>
      <p class="small"><b>Related:</b> ${skillLine(byType('related'))}</p>
      <p class="small"><b>Secondary:</b> ${skillLine(byType('secondary'))}</p>
      ${(c.powers || []).length ? `<h3>Powers</h3><p class="small">${c.powers.map((p) => esc(p.name) + ' <span class="muted">(' + esc(p.type) + ')</span>').join(' · ')}</p>` : ''}
      <h3>Inventory</h3>
      <p class="small">${items.map((it) => esc(it.item_name || it.custom_name) + (it.qty > 1 ? ` ×${it.qty}` : '')).join(' · ') || '—'}</p>
    </div>
    <div class="nav">
      <a class="btn btn-primary" href="sheet.html?id=${c.id}">📜 Open full sheet</a>
      <button class="btn" onclick="startOver()">+ Create another character</button>
    </div>`;
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${esc(err.message)}</p></div>`;
  }
}
// A minimum re-roll happens before the character exists, so it cannot be an
// event at the time it is made. It becomes one here, as a `roll` — the kind the
// events API already defines as a pure record with no state change.
//
// Best-effort, deliberately: a character that saved correctly must not report
// failure because its history note did not land.
async function recordMinRerolls(id) {
  for (const r of S.minRerolls || []) {
    try {
      await api(`characters/${id}/events`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          kind: 'roll',
          note: `${r.attr} re-rolled ${r.from} → ${r.to}${
            r.need != null ? ` to meet the ${r.need} minimum` : ''}${r.occ ? ` for ${r.occ}` : ''}`,
        }),
      });
    } catch { /* see above */ }
  }
  S.minRerolls = [];
}

function startOver() {
  S.savedId = null; S.step = ST.SYSTEM; S.rcc = null; S.charName = ''; S.campaignId = null; S.newCampaign = '';
  S.draftOffer = null;
  resetBuild(); boot(false); render();
}

// ---------- boot ----------
async function boot(first = true) {
  try {
    // Everything comes from the database now — classes, catalogs, and items —
    // so content changes take effect without a redeploy.
    const [classesRes, catalogsRes, itemsRes, campaignsRes, charsRes, meRes] = await Promise.all([
      api('classes'),
      api('catalogs'),
      api('items'),
      api('campaigns'),
      api('characters'),
      api('me').catch(() => ({})),
    ]);
    S.classes = classesRes.classes;
    S.skillCatalog = catalogsRes.skills;
    _skillIndex = null;
    S.spellCatalog = catalogsRes.spells;
    S.psiCatalog = catalogsRes.psionics;
    S.items = itemsRes.items;
    S.itemRedirects = itemsRes.redirects || {};
    S.campaigns = campaignsRes.campaigns;
    S.existing = charsRes.characters;
    S.me = meRes.email ?? null;
    S.isAdmin = !!meRes.is_admin;
    if (classesRes.failures?.length) console.error('Class parse failures:', classesRes.failures);

    // Only offered on a genuine first load. startOver() calls boot(false) after
    // deliberately clearing the build, and re-offering the draft it just
    // finished would be the opposite of helpful.
    if (first) {
      const { draft } = await api('draft').catch(() => ({ draft: null }));
      // A draft naming a class that no longer resolves — retired, renamed,
      // re-imported under a different id — cannot be restored into anything
      // coherent, so it is dropped rather than half-applied.
      if (draft && S.classes.some((c) => c.id === draft.class_id)) S.draftOffer = migrateDraft(draft);
      else if (draft) await discardDraft();
    }
    if (first) render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load app data: ${esc(err.message)}</p></div>`;
  }
}

// Checkbox toggles carry their value in data- attributes and are dispatched
// here rather than interpolated into an inline handler. Catalog names come from
// sourcebook PDFs and routinely contain apostrophes and quotes, which would
// terminate a JS string literal inside an HTML attribute.
$('app').addEventListener('change', (ev) => {
  const el = ev.target;
  switch (el.dataset?.act) {
    case 'skill': return toggleSkill(el.dataset.kind, el.dataset.name);
    case 'group': return toggleGroupPick(+el.dataset.group, el.dataset.name, +el.dataset.limit);
    case 'gear': return toggleGearPick(+el.dataset.group, el.dataset.slug, +el.dataset.limit);
    case 'power': return togglePower(el.dataset.kind, el.dataset.name,
      el.dataset.gi == null ? null : +el.dataset.gi);
  }
});

// The draft save is debounced, so the last second or two of work may not have
// reached the server yet. Warn only once attributes are rolled: a roll is the
// first thing that cannot be reproduced, and before that the "loss" is picking
// a system and a class again.
window.addEventListener('beforeunload', (ev) => {
  if (S.savedId || !S.rcc || S.draftOffer) return;
  if (!Object.keys(S.attrs || {}).length) return;
  ev.preventDefault();
  ev.returnValue = '';
});

// Inline onclick handlers live in the global scope; this module does not, so
// every entry point the generated markup references is exposed explicitly.
//
// Anything reached through the delegated `change` listener above does NOT belong
// here — it is called from inside this module and needs no global. The four
// toggles used to be inline and three of them kept their entry after the move;
// `toggleGearPick`, written after it, never had one, which is the shape to copy.
Object.assign(window, {
  // ST as well as the functions: the nav buttons are inline onclick handlers,
  // so `goStep(ST.SKILLS)` is evaluated in the global scope and a module-scoped
  // ST would be a ReferenceError on every Back button.
  S, ST, render, computePools, goStep, nextStep, prevStep, pickSystem, classMode, quizPick, pickClass,
  confirmRace, rerollForMinimum, setMethod, setAllMethod, doRoll, rollAll, manualSet, pbAdj,
  setStartingLevel, rerollAdvancement, setLevelPick, pickMos,
  doPsiRoll, skipPsiRoll, setPsiShape, setPsiCategory,
  rollBio, rollBioAll, setLongLived,
  rmEquip, addCatalog, addCustom, setBio, save, startOver,
  resumeDraft, dismissDraft, pickVariant, pickOcc, takeAbility, dropAbility,
  deleteCharacter,
});

boot();
