// Resolves a character's class or classes into the one thing it is played as.
//
// Classes are stored in D1 rather than shipped as files, so this is a lookup.
// Used by the XP, level-up, picks, variant and create endpoints.

import { parseClassMarkdown, applyVariant, combineClasses } from '../../../../apps/character-creator/js/parser.js';
import { withRolledPsionics } from '../../../../apps/character-creator/js/psionics.js';
import { getStored } from './class-store.js';

// `variantId` is the character's class_variant. Resolution happens HERE, in the
// one place a class is turned into the thing a character is played as, so no
// caller has to remember that a Dragon hatchling has different attribute dice
// and M.D.C. from an adult. Passing nothing returns the class as written.
export async function loadClass(env, requestUrl, classId, variantId = null) {
  const row = await getStored(env, classId);
  if (row?.status !== 'published') return null;
  const parsed = parseClassMarkdown(row.markdown);
  return parsed.ok ? applyVariant(parsed.data, variantId) : null;
}

// A character's class as it is actually played: the R.C.C. with its variant
// applied, composed with the O.C.C. taken alongside it if there is one.
//
// Everything downstream — the validator, the level-up diff, derive's bonuses —
// reads one class-shaped object, so none of it has to know a character can have
// two. A character with no occ_class_id gets exactly what it got before.
//
// The O.C.C. failing to resolve is not fatal: the R.C.C. half is still a usable
// character, and refusing to load a sheet because one of two classes was
// retired would be worse than showing the half that works.
export async function loadCharacterClass(env, requestUrl, character) {
  const rcc = await loadClass(env, requestUrl, character.class_id, character.class_variant);
  const composed = character.occ_class_id
    ? combineClasses(rcc, await loadClass(env, requestUrl, character.occ_class_id, character.occ_class_variant))
    : rcc;
  return withRolledPsionics(composed, character);
}
