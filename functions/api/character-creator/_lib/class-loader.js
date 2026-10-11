// Resolves a character's class or classes into the one thing it is played as.
//
// Classes are stored in D1 rather than shipped as files, so this is a lookup.
// Used by the XP, level-up, picks, variant and create endpoints.

import { parseClassMarkdown, applyVariant } from '../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
import { getStored } from './class-store.js';
import { loadSkillBonuses } from './skill-bonuses.js';
import { once } from './once.js';

// `variantId` is the character's class_variant. Resolution happens HERE, in the
// one place a class is turned into the thing a character is played as, so no
// caller has to remember that a Dragon hatchling has different attribute dice
// and M.D.C. from an adult. Passing nothing returns the class as written.
//
// `loads` is a request's own cache (_lib/once.js). The ROW is what is kept,
// not the parsed class: every caller still parses and applies its own variant,
// so two characters of one class never share an object one of them composed.
export async function loadClass(env, requestUrl, classId, variantId = null, loads = null) {
  const row = await once(loads, 'class:' + classId, () => getStored(env, classId));
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
export async function loadCharacterClass(env, requestUrl, character, { loads = null } = {}) {
  // loadClass() already applies the variant, so the pieces handed to
  // composeClass() are pre-resolved and it re-applies nothing.
  const rcc = await loadClass(env, requestUrl, character.class_id, character.class_variant, loads);
  const occ = character.occ_class_id
    ? await loadClass(env, requestUrl, character.occ_class_id, character.occ_class_variant, loads)
    : null;
  // The character's skills grant bonuses too - Boxing is +1 attack and +2 P.S.
  // Loaded here so the validator and the level-up diff see the same totals the
  // sheet does; they disagreeing is the class of bug composeClass() exists for.
  const skillRows = await loadSkillBonuses(env, character);
  const totem = await loadTotem(env, character.totem, loads);
  return composeClass({ rcc, occ, skillRows, totem,
    character: { ...character, class_variant: null, occ_class_variant: null } });
}

// A character's totem row (BOOK-INGEST-AUDIT.md F56), or null. Looked up here
// because composeClass does no I/O; a slug the catalog no longer has comes back
// null, and the validator reports that as `totem_unknown`.
export async function loadTotem(env, slug, loads = null) {
  if (!slug) return null;
  const key = String(slug).toLowerCase();
  return (await once(loads, 'totem:' + key, () => env.DB.prepare(
    'SELECT slug, name, skills, bonuses, bonus_note, powers FROM totems WHERE slug = ?'
  ).bind(key).first())) ?? null;
}

// Every totem by slug, for a caller composing many characters in one request.
export async function loadTotems(env) {
  const { results } = await env.DB.prepare(
    'SELECT slug, name, skills, bonuses, bonus_note, powers FROM totems'
  ).all();
  return new Map((results || []).map((t) => [String(t.slug).toLowerCase(), t]));
}
