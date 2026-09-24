// GET  /api/character-creator/city-themes[?system=]  - the caller's saved themes, as summaries
// POST /api/character-creator/city-themes {pack, name?, adapted_from?}  - save one
//
// A G.M.'s own saved City Creator themes (migration 084). Everything here is
// the OWNER's: the list is the caller's themes and nobody else's, and there is
// no way to ask for another person's. A pack is checked by the engine before
// it is stored (_lib/city-themes.js), and a 400 says what is wrong with it.

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { checkSavedTheme, themeSummary, ownTheme } from './_lib/city-themes.js';

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  const { results } = await (system
    ? env.DB.prepare('SELECT * FROM city_themes WHERE owner_email = ? AND system = ? ORDER BY name COLLATE NOCASE, id').bind(email, system)
    : env.DB.prepare('SELECT * FROM city_themes WHERE owner_email = ? ORDER BY name COLLATE NOCASE, id').bind(email)).all();
  return json({ themes: (results || []).map(themeSummary) });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const checked = checkSavedTheme(b.pack);
  if (checked.error) return json({ error: checked.error }, 400);
  const name = (typeof b.name === 'string' && b.name.trim().slice(0, 120)) || checked.pack.title;
  let adaptedFrom = null;
  if (b.adapted_from != null) {
    // Only from one of the caller's own themes: a pointer to anyone else's
    // would say that theme exists.
    const from = await ownTheme(env, Number(b.adapted_from), email);
    if (!from) return json({ error: 'adapted_from must be one of your own themes' }, 400);
    adaptedFrom = from.id;
  }
  const row = await env.DB.prepare(
    `INSERT INTO city_themes (owner_email, name, system, prompt, pack, adapted_from) VALUES (?, ?, ?, ?, ?, ?)
     RETURNING *`
  ).bind(email, name, checked.pack.system, checked.pack.prompt, checked.text, adaptedFrom).first();
  return json({ theme: themeSummary(row) }, 201);
}
