// GET /api/character-creator/items — shared item catalog (optionally ?system=)

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  // Only the fields the pickers actually render — the catalog grows by a stub
  // per referenced item on every class import, and `stats` is a JSON blob.
  const cols = 'id, slug, name, system, category, weight_lbs, cost';
  const stmt = system
    ? env.DB.prepare(`SELECT ${cols} FROM items WHERE system = ? OR system = 'both' ORDER BY name`).bind(system)
    : env.DB.prepare(`SELECT ${cols} FROM items ORDER BY name`);
  const { results } = await stmt.all();
  return json({ items: results });
}
