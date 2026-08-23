// The one place a character's classes become the thing it is played as.
//
// Four steps, and the order matters:
//
//   1. apply each class's variant   — a Dragon hatchling is not an adult
//   2. compose race with occupation — one class-shaped object
//   3. fold in chosen abilities     — powers the player picked from a list
//   4. fold in rolled psionics      — a tier the character rolled, not the class
//
// Six places used to do this by hand: the class loader, the sheet's endpoint,
// the stage-change endpoint, the admin audit, and the wizard twice. They agreed
// only by luck, and every time a step was added, all six had to learn it.
//
// Adding the O.C.C. step meant touching all of them. Adding the psionics step
// meant touching all of them again — and one was missed, so the sheet showed a
// rolled major psychic a save target of 15 instead of 12 while the level-up
// path had it right. That bug is the reason this file exists.
//
// The callers still differ in how they FETCH a class — some await D1, one reads
// a preloaded map, one tolerates a retired class, the wizard has them in memory.
// That part is genuinely different per site and stays there. What is the same
// everywhere is what to do once you have them, which is all this does.

import { applyVariant, combineClasses, applyAbilities, bonusesFromSkills,
         sumBonusGroups } from './parser.js';
import { withRolledPsionics } from './psionics.js';

// Hit points and S.D.C. are CORE rules (p.18), stated once for every
// character rather than per class, so most O.C.C. pages print neither. A class
// that omits them is not saying the character has none — it is saying the
// universal rule applies, and taking the silence literally is what let two
// Priests of Light reach production with hp_max and sdc_max NULL.
//
// This is the same reading parser.js already applies when a racial class omits
// a pool. A class that STATES a formula always wins; these only fill a gap.
//
// Base hit points are the P.E. attribute plus 1D6, and another 1D6 per level.
const CORE_HIT_POINTS = 'P.E. + 1D6 per level';

// S.D.C. splits on the book's own O.C.C. grouping: men of arms roll 3D6,
// practitioners of magic, scholars and everyone else roll 1D6. Nothing in the
// class data records that grouping — `category` only separates O.C.C. from
// R.C.C. — so it is listed here, read off the section headings in the book.
//
// A class belongs here ONLY if its own page prints no S.D.C. formula; one that
// prints its own needs no entry. A class that prints none and is missing from
// this table fails the smoke test rather than defaulting, because defaulting to
// 1D6 would quietly under-roll every new man of arms.
export const CORE_SDC_BY_CLASS = {
  // Men of arms — 3D6.
  'glitter-boy': '3D6',
  'headhunter-techno-warrior': '3D6',
  'merc-soldier': '3D6',
  'robot-pilot': '3D6',
  // Psychics by the book's grouping, but hunters by trade and armed as such.
  'psi-stalker': '3D6',
  'wild-psi-stalker': '3D6',
  // Rifts Ultimate Edition, printed 45-85 - the men of arms section.
  'crazy': '3D6',
  // Coalition Military O.C.C.s, printed 231-237. Soldiers by definition.
  'coalition-grunt': '3D6',
  'coalition-samas-pilot': '3D6',
  'coalition-technical-officer': '3D6',
  // Palladium Fantasy main book, the Men of Arms section, printed 78-95 (the
  // contents page puts the heading at 78 and Optional O.C.C.s at 96). Not one
  // of these pages prints an S.D.C. formula, so the core rule applies to every
  // one of them — and the book's own section heading is the whole of what this
  // table records, which is why they are listed together rather than argued for
  // one at a time.
  'knight': '3D6',
  'soldier': '3D6',
  'palladin': '3D6',
  'ranger': '3D6',
  'mercenary-fighter': '3D6',
  // The SQUIRE is the exception to that sentence, and it is worth being honest
  // about rather than leaving it sitting in a list it does not belong to. It is
  // printed at 98, inside Optional O.C.C.s, not in the Men of Arms section —
  // this entry used to claim the range ran to 104, which no part of the book
  // supports. It stays at 3D6 anyway, because printed 18 keys the roll on "a
  // background as men of arms" rather than on where the entry was typeset, and
  // the squire's background is knightly military training: it is "familiar with
  // the rudimentaries of combat, horsemanship and weapons", its page carries
  // the same Squires & Armor rules the knight's does, and the book calls them
  // "lesser knights".
  'squire': '3D6',
  // The Thief and the Assassin are here on the book's own say-so, not on a
  // reading of what they do: "Thieves (and assassins) are the rogues and
  // cutthroats of the men of arms O.C.C.s" (printed 91). Worth the sentence,
  // because neither looks like a man of arms from its skill list.
  'thief': '3D6',
  'assassin': '3D6',

  // Practitioners of magic, psychics and scholars — 1D6.
  'burster': '1D6',
  'elemental-fusionist-earth-air': '1D6',
  'elemental-fusionist-fire-water': '1D6',
  'ley-line-rifter': '1D6',
  'ley-line-walker': '1D6',
  'mind-melter': '1D6',
  'mystic': '1D6',
  'priest-of-light': '1D6',
  'shifter': '1D6',
  'stone-master': '1D6',
  'techno-wizard': '1D6',
  'warlock': '1D6',
  // Rifts Ultimate Edition, printed 86-99 - the Adventurers & Scholars
  // section, which is where the book itself files all eight of these.
  'body-fixer': '1D6',
  'city-rat': '1D6',
  'operator': '1D6',
  'cyber-doc': '1D6',
  'rogue-scholar': '1D6',
  'rogue-scientist': '1D6',
  'vagabond': '1D6',
  'wilderness-scout': '1D6',
  // Palladium Fantasy main book, the Optional O.C.C.s, printed 96-98. The
  // first Palladium classes on this side of the table: the previous nine are
  // all men of arms, and these three are the book's own answer to a player who
  // does not want to be one. None of their pages prints an S.D.C. formula
  // either, so the same core rule reaches the other way.
  'merchant': '1D6',
  'noble': '1D6',
  'scholar': '1D6',
  // The fifth Optional O.C.C., printed 99, and the last one in that section.
  // It asks for no attributes, grants no bonuses and prints no S.D.C., so the
  // core rule reaches it the same way.
  'vagabond-peasant': '1D6',
  // Palladium Fantasy main book, the practitioners of magic, printed 104-137.
  // The book's other half of the same core rule, and the plainest reading of
  // it: these three are what "practitioners of magic" names.
  'wizard': '1D6',
  'summoner': '1D6',
  'diabolist': '1D6',
  // Palladium Fantasy main book, the clergy, printed 63-78. The Warrior Monk
  // is the awkward one and still belongs here: it fights better than most men
  // of arms, but the book files it with the priests and prints no S.D.C.
  // formula, so the core rule reads 1D6. Its own +20 S.D.C. bonus is a pool
  // bonus in the class and lands on top of this.
  'priest-of-darkness': '1D6',
  'warrior-monk': '1D6',
  'druid': '1D6',
  // The Witch is filed with the practitioners of magic and prints no S.D.C.
  // formula. Its Gift of Power and Gift of Union both add large amounts on top
  // - 200 and 3D4x10 - but those are gifts, not the class's own roll.
  'witch': '1D6',
  // Palladium Fantasy main book, the psychic P.C.C.s, printed 156-162. None
  // prints an S.D.C. formula and none is a man of arms, so the core rule reads
  // 1D6 for all four - which is the whole of what this table decides.
  'psychic-sensitive': '1D6',
  'psi-healer': '1D6',
  'psi-mystic': '1D6',
  'mind-mage': '1D6',

  // The fourteen Palladium Fantasy player races, printed 288-312.
  //
  // A RACE IS NEVER A MAN OF ARMS. What makes a character one is the job, and
  // withCorePools looks the OCCUPATION up first, so every one of these entries
  // fires only for a race played with no occupation at all - which the books do
  // not do and the app allows. There, printed 18's own third bucket applies:
  // "practitioners of magic, scholars and all others roll 1D6". A race with no
  // occupation is "all others".
  //
  // Ten of the fourteen also state a racial S.D.C. of their own, and NONE of
  // them states it here. Those are pool BONUSES on the class - "10 plus those
  // gained from O.C.C.s and physical skills" - because printed 18 says all
  // S.D.C. bonuses are cumulative. Written as sdc_base they would replace the
  // occupation's roll rather than add to it, so a Troll Knight would have 40
  // S.D.C. instead of 40 + 3D6.
  'human': '1D6',
  'elf': '1D6',
  'dwarf': '1D6',
  'gnome': '1D6',
  'troglodyte': '1D6',
  'kobold': '1D6',
  'goblin': '1D6',
  'hob-goblin': '1D6',
  'orc': '1D6',
  'ogre': '1D6',
  'troll': '1D6',
  'changeling': '1D6',
  'wolfen': '1D6',
  'coyle': '1D6',
};

// An M.D.C. being tracks M.D.C. INSTEAD of hit points and S.D.C., so silence
// there is a statement and nothing is filled in.
//
// `occId` is the occupation's id when there is one: what makes a character a
// man of arms is the job, not the race, so a dragon that took a Merc Soldier
// rolls the soldier's 3D6.
function withCorePools(cls, occId) {
  if (!cls || cls.mdc_base != null) return cls;
  const out = { ...cls };
  if (out.hit_points_base == null) out.hit_points_base = CORE_HIT_POINTS;
  if (out.sdc_base == null) {
    // Falls back to the race's own id so an R.C.C. played without an
    // occupation is still classified.
    const sdc = CORE_SDC_BY_CLASS[occId] ?? CORE_SDC_BY_CLASS[cls.id];
    if (sdc) out.sdc_base = sdc;
  }
  return out;
}

// A Military Occupational Specialty, folded into the class that offers it.
//
// An MOS is NOT a variant, and the difference is the whole reason this exists.
// A variant REPLACES what the class says - and VARIANT_OVERRIDES deliberately
// excludes the skills block, because `skill_overrides` restating a number is a
// much smaller power than swapping a skill list. An MOS ADDS: the book says
// "select one area of specialty, gain all skills under that MOS", on top of the
// O.C.C. skills every member of the class already has.
//
// So the option's entries are appended to occ_skills rather than replacing
// them, and they are the same shape - fixed skills and choice groups - which is
// why the parser validates both through validateSkillEntries.
//
// An unknown id returns the class untouched rather than throwing: a character
// who picked an MOS that a later edit removed is still a character, and the
// validator reports the dangling choice as a violation where a human sees it.
// NOT exported, deliberately. `composeClass` is the ONE place that knows the
// order these steps run in, and a smoke check already fails any file calling
// `combineClasses(` directly for that reason. Exporting this one invited the
// same mistake by a different door: nothing outside this file ever imported it,
// and now nothing can.
function applyMos(cls, mosId) {
  const options = cls?.skills?.mos?.options;
  if (!cls || !mosId || !Array.isArray(options)) return cls;
  const pick = options.find((o) => String(o.id || o.name).toLowerCase() === String(mosId).toLowerCase());
  if (!pick || !Array.isArray(pick.skills)) return cls;
  return {
    ...cls,
    skills: {
      ...cls.skills,
      occ_skills: [...(cls.skills.occ_skills || []), ...pick.skills],
    },
    // What was chosen, for the sheet and for anything asking after the fact.
    mos_chosen: { id: pick.id || pick.name, name: pick.name },
  };
}

// `rcc` and `occ` are raw parsed classes, before any variant is applied.
// `character` supplies class_variant, occ_class_variant, and the rolled psychic
// tier; a plain object works, which is what the wizard passes mid-build.
//
// Returns null only when there is no race and no occupation. A missing O.C.C.
// is not fatal: the race alone is still a usable character, and refusing to
// resolve because one of two classes was retired would be worse than showing
// the half that works.
export function composeClass({ rcc, occ = null, character = {}, skillRows = null } = {}) {
  if (!rcc && !occ) return null;

  const race = applyVariant(rcc, character.class_variant);
  const job = occ ? applyVariant(occ, character.occ_class_variant) : null;
  // Core p.18 pools land here, on the two classes already resolved into one,
  // so combineClasses still sees exactly what each class actually stated and
  // its own race-omits-a-pool fallback is not pre-empted by a default.
  // MOS lands on the COMPOSED class, not on the occupation slot. A character
  // with no racial class carries their O.C.C. in the `rcc` slot, so attaching
  // it to `occ` fired for a D-Bee Technical Officer and not for a human one.
  const composed = applyMos(
    withCorePools(job ? combineClasses(race, job) : race, job?.id ?? race?.id),
    character.mos);

  // Abilities are chosen FOR the character rather than contributed by either
  // half, so they land after the two classes are one — and before any rolled
  // psionic tier, so an ability that makes you a master psychic is what a rolled
  // tier has to beat rather than the other way round.
  const withAbilities = applyAbilities(composed, character.abilities);

  const withPsionics = withRolledPsionics(withAbilities, character);

  // Skills land LAST, and only when the caller supplied the catalog rows.
  // A skill's bonus is neither class's, so it must not be visible to
  // combineClasses (which resolves conflicts between the two halves) nor to
  // applyAbilities (an ability may grant bonuses of its own and should not be
  // able to read a skill's). Merged through sumBonusGroups, the same function
  // that merges the two classes, so a class and a skill both granting +2 P.S.
  // give +4 rather than one silently winning.
  //
  // `skillRows` null means "this caller does not know the character's skills",
  // which is different from "the character has none" - the first must leave the
  // composed class untouched.
  if (!skillRows) return withPsionics;
  // Level matters now: a Hand to Hand skill grants a different set at each
  // level, and everything up to the character's is summed (p.347).
  const fromSkills = bonusesFromSkills(skillRows, character.level ?? null);
  if (!fromSkills) return withPsionics;
  return { ...withPsionics, bonuses: sumBonusGroups(withPsionics.bonuses, fromSkills) };
}
