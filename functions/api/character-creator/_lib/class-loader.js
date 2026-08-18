// Resolves a character's class or classes into the one thing it is played as.
//
// Classes are stored in D1 rather than shipped as files, so this is a lookup.
// Used by the XP, level-up, picks, variant and create endpoints.

import { parseClassMarkdown, applyVariant, resolveAbilityRefs } from '../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
import { getStored } from './class-store.js';

// `variantId` is the character's class_variant. Resolution happens HERE, in the
// one place a class is turned into the thing a character is played as, so no
// caller has to remember that a Dragon hatchling has different attribute dice
// and M.D.C. from an adult. Passing nothing returns the class as written.
export async function loadClass(env, requestUrl, classId, variantId = null) {
  const row = await getStored(env, classId);
  if (row?.status !== 'published') return null;
  const parsed = parseClassMarkdown(row.markdown);
  if (!parsed.ok) return null;

  // A shared ability list lives in another class, so resolving it costs one
  // more lookup — but only for a class that actually references one. `getStored`
  // deliberately ignores deleted_at, so a list whose class was retired still
  // resolves, exactly as a character's own retired class does.
  const data = await withSharedAbilities(env, parsed.data);
  return applyVariant(data, variantId);
}

async function withSharedAbilities(env, data) {
  const refs = [...new Set((data.special_abilities || [])
    .map((e) => e?.from_class).filter(Boolean))];
  if (!refs.length) return data;

  const byId = new Map();
  for (const id of refs) {
    // One hop: the referenced class's own list is read as written, never
    // resolved again. That is the rule, not an optimisation — it is what makes
    // a cycle impossible rather than something to detect.
    const row = await getStored(env, id);
    if (!row) continue;
    const p = parseClassMarkdown(row.markdown);
    if (p.ok) byId.set(id, p.data);
  }
  return resolveAbilityRefs(data, byId);
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
  // loadClass() already applies the variant, so the pieces handed to
  // composeClass() are pre-resolved and it re-applies nothing.
  const rcc = await loadClass(env, requestUrl, character.class_id, character.class_variant);
  const occ = character.occ_class_id
    ? await loadClass(env, requestUrl, character.occ_class_id, character.occ_class_variant)
    : null;
  return composeClass({ rcc, occ, character: { ...character, class_variant: null, occ_class_variant: null } });
}
