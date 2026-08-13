// Resolves a class_id slug to its parsed frontmatter.
//
// Classes are stored in D1 rather than shipped as files, so this is a single
// lookup. Used by the XP and level-up endpoints.

import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';
import { getStored } from './class-store.js';

export async function loadClass(env, requestUrl, classId) {
  const row = await getStored(env, classId);
  if (row?.status !== 'published') return null;
  const parsed = parseClassMarkdown(row.markdown);
  return parsed.ok ? parsed.data : null;
}
