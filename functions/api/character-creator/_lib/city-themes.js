// A G.M.'s saved City Creator themes (migration 084), and the one check every
// write passes: the engine's own validateSavedTheme, the same rules a theme
// meets when it is written on the page. The server stores what that returns -
// the fields the engine reads and nothing else - never the body as sent.

import { validateSavedTheme } from '../../../../apps/city-creator/js/city-engine.js';

// A written pack is ~45 KB (measured 2026-09-24); this is room for a long one.
const MAX_THEME_BYTES = 200000;

export function checkSavedTheme(v) {
  if (!v || typeof v !== 'object' || Array.isArray(v)) return { error: 'pack must be a theme' };
  let pack;
  try { pack = validateSavedTheme(v); } catch (err) { return { error: err.message }; }
  const text = JSON.stringify(pack);
  if (text.length > MAX_THEME_BYTES) return { error: 'That theme is too large to save' };
  return { pack, text };
}

// What a list shows: never the pack.
export const themeSummary = (r) => ({
  id: r.id, name: r.name, system: r.system, prompt: r.prompt, adapted_from: r.adapted_from ?? null,
  created_at: r.created_at, updated_at: r.updated_at,
});

// The caller's own theme, or null - a theme that is someone else's does not
// exist for them.
export async function ownTheme(env, id, email) {
  const row = await env.DB.prepare('SELECT * FROM city_themes WHERE id = ?').bind(id).first();
  return row && row.owner_email === email ? row : null;
}
