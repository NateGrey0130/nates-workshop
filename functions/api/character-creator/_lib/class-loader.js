// Resolves a class_id slug to its parsed frontmatter.
//
// Classes are stored in D1 rather than shipped as files, so this is a single
// lookup. Used by the XP and level-up endpoints.

import { parseClassMarkdown, applyVariant } from '../../../../apps/character-creator/js/parser.js';
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
