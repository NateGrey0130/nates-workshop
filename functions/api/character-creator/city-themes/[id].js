// GET    /api/character-creator/city-themes/:id  - one saved theme, its whole pack
// PATCH  /api/character-creator/city-themes/:id  {name?, pack?}
// DELETE /api/character-creator/city-themes/:id
//
// OWNER ONLY, and anyone else gets 404 - not 403, so a stranger probing ids
// cannot tell which are real (the NPC library's rule). A new pack is checked
// again and stays the same game: a pack's shops and roles belong to its game,
// and moving one to another game is adapting it, which makes a new theme.
// Cities made from a theme keep their own copy, so nothing here changes them.

import { getUserEmail, unauthorized, json, readJson } from '../_lib/auth.js';
import { checkSavedTheme, themeSummary, ownTheme } from '../_lib/city-themes.js';

async function own(request, env, id) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const row = await ownTheme(env, id, email);
  if (!row) return { res: json({ error: 'Not found' }, 404) };
  return { email, row };
}

export async function onRequestGet({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  let pack = null;
  try { pack = JSON.parse(g.row.pack); } catch { /* shown as missing */ }
  return json({ theme: { ...themeSummary(g.row), pack } });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('name' in b) {
    const name = typeof b.name === 'string' ? b.name.trim().slice(0, 120) : '';
    if (!name) return json({ error: 'A name cannot be blank' }, 400);
    sets.push('name = ?'); binds.push(name);
  }
  if ('pack' in b) {
    const checked = checkSavedTheme(b.pack);
    if (checked.error) return json({ error: checked.error }, 400);
    if (checked.pack.system !== g.row.system) {
      return json({ error: `This theme is for ${g.row.system}; adapting it to another game makes a new theme` }, 400);
    }
    sets.push('pack = ?', 'prompt = ?'); binds.push(checked.text, checked.pack.prompt);
  }
  if (!sets.length) return json({ error: 'name and pack are the editable fields' }, 400);
  const row = await env.DB.prepare(
    `UPDATE city_themes SET ${sets.join(', ')}, updated_at = datetime('now') WHERE id = ? RETURNING *`
  ).bind(...binds, g.row.id).first();
  return json({ theme: themeSummary(row) });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await own(request, env, params.id);
  if (g.res) return g.res;
  await env.DB.prepare('DELETE FROM city_themes WHERE id = ?').bind(g.row.id).run();
  return json({ ok: true });
}
