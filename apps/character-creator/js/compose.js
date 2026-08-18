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

import { applyVariant, combineClasses, applyAbilities } from './parser.js';
import { withRolledPsionics } from './psionics.js';

// `rcc` and `occ` are raw parsed classes, before any variant is applied.
// `character` supplies class_variant, occ_class_variant, and the rolled psychic
// tier; a plain object works, which is what the wizard passes mid-build.
//
// Returns null only when there is no race and no occupation. A missing O.C.C.
// is not fatal: the race alone is still a usable character, and refusing to
// resolve because one of two classes was retired would be worse than showing
// the half that works.
export function composeClass({ rcc, occ = null, character = {} } = {}) {
  if (!rcc && !occ) return null;

  const race = applyVariant(rcc, character.class_variant);
  const job = occ ? applyVariant(occ, character.occ_class_variant) : null;
  const composed = job ? combineClasses(race, job) : race;

  // Abilities are chosen FOR the character rather than contributed by either
  // half, so they land after the two classes are one — and before any rolled
  // psionic tier, so an ability that makes you a master psychic is what a rolled
  // tier has to beat rather than the other way round.
  const withAbilities = applyAbilities(composed, character.abilities);

  return withRolledPsionics(withAbilities, character);
}
