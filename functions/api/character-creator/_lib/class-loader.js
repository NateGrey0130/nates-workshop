// Loads and parses one RCC/OCC class definition from the markdown assets.
// Fast path: files are named <id>.md; falls back to scanning the manifest.

import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';
import { getStored } from './class-store.js';

const DATA_PATH = '/apps/character-creator/data/classes/';

export async function loadClass(env, requestUrl, classId) {
  const fromFile = await loadClassFromFiles(env, requestUrl, classId);
  if (fromFile) return fromFile;

  // Fall back to a published import, so leveling and XP work for classes that
  // only exist in the database.
  try {
    const row = await getStored(env, classId);
    if (row?.status === 'published') {
      const parsed = parseClassMarkdown(row.markdown);
      if (parsed.ok) return parsed.data;
    }
  } catch { /* table not migrated yet */ }
  return null;
}

async function loadClassFromFiles(env, requestUrl, classId) {
  const direct = await env.ASSETS.fetch(new URL(DATA_PATH + classId + '.md', requestUrl));
  if (direct.ok) {
    const parsed = parseClassMarkdown(await direct.text());
    if (parsed.ok && parsed.data.id === classId) return parsed.data;
  }
  const manifestRes = await env.ASSETS.fetch(new URL(DATA_PATH + 'index.json', requestUrl));
  if (!manifestRes.ok) return null;
  const manifest = await manifestRes.json();
  for (const file of manifest.classes) {
    const res = await env.ASSETS.fetch(new URL(DATA_PATH + file, requestUrl));
    if (!res.ok) continue;
    const parsed = parseClassMarkdown(await res.text());
    if (parsed.ok && parsed.data.id === classId) return parsed.data;
  }
  return null;
}
