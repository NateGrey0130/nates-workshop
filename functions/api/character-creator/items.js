// GET /api/character-creator/items — shared item catalog (optionally ?system=)

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  const stmt = system
    ? env.DB.prepare("SELECT * FROM items WHERE system = ? OR system = 'both' ORDER BY name").bind(system)
    : env.DB.prepare('SELECT * FROM items ORDER BY name');
  const { results } = await stmt.all();
  return json({ items: results });
}
