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
         sumBonusGroups, mosList } from './parser.js';
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
// practitioners of magic, scholars and everyone else roll 1D6. A class that
// prints no S.D.C. formula says which it is in its own frontmatter,
// `men_of_arms: true` or `false`, read off the book's section headings.
//
// Until 2026-09-25 that grouping was a map here, CORE_SDC_BY_CLASS, which every
// class import appended to, so two book sessions in parallel conflicted on it.
// Its 207 entries, and the comment giving each one's book, pages and reason,
// moved into the classes' markdown with
// db/~001-men-of-arms-frontmatter.sql. A class that prints no
// formula and states neither fails regression rather than defaulting, because
// defaulting to 1D6 would quietly under-roll every new man of arms.
const CORE_SDC = { true: '3D6', false: '1D6' };

// An M.D.C. being tracks M.D.C. INSTEAD of hit points and S.D.C., so silence
// there is a statement and nothing is filled in.
//
// `occ` is the occupation when there is one: what makes a character a man of
// arms is the job, not the race, so a dragon that took a Merc Soldier rolls the
// soldier's 3D6.
function withCorePools(cls, occ, race) {
  if (!cls || cls.mdc_base != null) return cls;
  const out = { ...cls };
  if (out.hit_points_base == null) out.hit_points_base = CORE_HIT_POINTS;
  if (out.sdc_base == null) {
    // The occupation decides, and the race answers when there is none, so an
    // R.C.C. played without an occupation is still classified.
    const sdc = CORE_SDC[occ?.men_of_arms ?? race?.men_of_arms];
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
// An unknown id is SKIPPED rather than throwing: a character who picked an MOS
// that a later edit removed is still a character, and the validator reports the
// dangling choice where a human sees it. Skipping one of several still grants
// the rest, which is the same reasoning one step along - a removed option must
// not cost a character the specialties that are still real.
//
// SEVERAL, since BOOK-INGEST-AUDIT.md F82. `skills.mos.choose` has always been
// validated and was honoured nowhere: this took one id and granted one option.
// It now takes whatever `characters.mos` or a draft is carrying - a list, a
// JSON list as text, or one bare id - because `mosList` reads all three and
// every character written before F82 holds the third.
//
// NOT exported, deliberately. `composeClass` is the ONE place that knows the
// order these steps run in, and a smoke check already fails any file calling
// `combineClasses(` directly for that reason. Exporting this one invited the
// same mistake by a different door: nothing outside this file ever imported it,
// and now nothing can.
function applyMos(cls, mos) {
  const options = cls?.skills?.mos?.options;
  if (!cls || !Array.isArray(options)) return cls;
  const picks = [];
  for (const id of mosList(mos)) {
    const pick = options.find((o) => String(o.id || o.name).toLowerCase() === id.toLowerCase());
    if (pick && Array.isArray(pick.skills) && !picks.includes(pick)) picks.push(pick);
  }
  // No recognised pick leaves the class exactly as it was, which is what an
  // unchosen MOS and an entirely dangling one both have to look like.
  if (!picks.length) return cls;
  return {
    ...cls,
    skills: {
      ...cls.skills,
      occ_skills: [...(cls.skills.occ_skills || []), ...picks.flatMap((p) => p.skills)],
    },
    // What was chosen, for the sheet and for anything asking after the fact.
    // ALWAYS an array, including for the one-pick classes that are all this
    // key had until F82 - a reader that has to test the shape before using it
    // is how the single-value assumption would grow back.
    mos_chosen: picks.map((p) => ({ id: p.id || p.name, name: p.name })),
  };
}

// A totem animal, folded into a class that picks one (BOOK-INGEST-AUDIT.md
// F56). Spirit West printed 96 says what one grants: skills "in addition to
// O.C.C. skills", with "a special bonus of +10%" where the O.C.C. already has
// the skill; bonuses "cumulative with all bonuses from O.C.C., attributes, and
// physical skills"; and powers that only the Totem Warrior can use, in giant
// animal form.
//
// The ROW comes from the `totems` catalog and is handed in, because this module
// does no I/O. Like applyMos it fires only on a class that declares the choice,
// so a class without `totem:` is untouched whatever the character holds.
//
// The +10% lands on a NAMED O.C.C. skill only. A choice group has no single
// skill to raise, and a related or secondary pick is not an O.C.C. skill. It
// REPLACES the totem's own bonus for that skill rather than adding to it: the
// sentence gives the +10% as what the character gets when the skill is
// already held, and nothing grants the skill twice.
function applyTotem(cls, row) {
  if (!cls?.totem || !row) return cls;
  const parse = (v) => {
    if (typeof v !== 'string') return v ?? null;
    try { return JSON.parse(v); } catch { return null; }
  };
  const skills = Array.isArray(parse(row.skills)) ? parse(row.skills) : [];
  const bonuses = parse(row.bonuses);
  const occ = [...(cls.skills?.occ_skills || [])];
  const at = new Map();
  occ.forEach((s, i) => { if (s?.name) at.set(String(s.name).trim().toLowerCase(), i); });
  const added = [];
  const raised = [];
  for (const s of skills) {
    if (!s?.name) continue;
    const key = String(s.name).trim().toLowerCase();
    const i = at.get(key);
    if (i === undefined) {
      occ.push({ ...s });
      at.set(key, occ.length - 1);
      added.push(s.name);
      continue;
    }
    const have = occ[i];
    occ[i] = typeof have.base === 'number'
      ? { ...have, base: have.base + 10 }
      : { ...have, bonus: (have.bonus || 0) + 10 };
    raised.push(have.name);
  }
  return {
    ...cls,
    skills: { ...(cls.skills || {}), occ_skills: occ },
    bonuses: bonuses && typeof bonuses === 'object' ? sumBonusGroups(cls.bonuses, bonuses) : cls.bonuses,
    // What was chosen, for the sheet. Powers only for the class that can USE
    // them - printed 96 says only the Totem Warrior can, and only as a giant
    // animal - so every other class's sheet never shows them.
    totem_chosen: {
      slug: row.slug, name: row.name, skills_added: added, skills_raised: raised,
      bonus_note: row.bonus_note || null,
      powers: cls.totem.powers === true ? (row.powers || null) : null,
    },
  };
}

// `rcc` and `occ` are raw parsed classes, before any variant is applied.
// `character` supplies class_variant, occ_class_variant, and the rolled psychic
// tier; a plain object works, which is what the wizard passes mid-build.
// `totem` is the character's `totems` row, resolved by the caller. Omitted, the
// totem simply does not apply - the same contract `skillRows` has.
//
// Returns null only when there is no race and no occupation. A missing O.C.C.
// is not fatal: the race alone is still a usable character, and refusing to
// resolve because one of two classes was retired would be worse than showing
// the half that works.
export function composeClass({ rcc, occ = null, character = {}, skillRows = null, totem = null } = {}) {
  if (!rcc && !occ) return null;

  const race = applyVariant(rcc, character.class_variant);
  const job = occ ? applyVariant(occ, character.occ_class_variant) : null;
  // Core p.18 pools land here, on the two classes already resolved into one,
  // so combineClasses still sees exactly what each class actually stated and
  // its own race-omits-a-pool fallback is not pre-empted by a default.
  // MOS lands on the COMPOSED class, not on the occupation slot. A character
  // with no racial class carries their O.C.C. in the `rcc` slot, so attaching
  // it to `occ` fired for a D-Bee Technical Officer and not for a human one.
  // The totem lands straight after, on the composed class for the same reason,
  // and after the MOS so printed 96's +10% sees an MOS skill as the O.C.C. skill
  // it is. The row counts only when it is the one the character holds: a row for
  // any other slug leaves the class untouched.
  const totemRow = totem && character.totem
    && String(totem.slug).toLowerCase() === String(character.totem).toLowerCase() ? totem : null;
  const composed = applyTotem(applyMos(
    withCorePools(job ? combineClasses(race, job) : race, job, race),
    character.mos), totemRow);

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
  // level, and everything up to the character's is summed (p.347). The class
  // goes with it for `ignores_style_attacks`.
  const fromSkills = bonusesFromSkills(skillRows, character.level ?? null, withPsionics);
  if (!fromSkills) return withPsionics;
  return { ...withPsionics, bonuses: sumBonusGroups(withPsionics.bonuses, fromSkills) };
}
