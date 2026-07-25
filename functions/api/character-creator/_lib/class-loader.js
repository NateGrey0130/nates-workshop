// Loads and parses one RCC/OCC class definition from the markdown assets.
// Fast path: files are named <id>.md; falls back to scanning the manifest.

import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

const DATA_PATH = '/apps/character-creator/data/classes/';

export async function loadClass(env, requestUrl, classId) {
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
