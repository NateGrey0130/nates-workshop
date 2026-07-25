// GET  /api/character-creator/campaigns            — list campaigns (optionally ?system=)
// POST /api/character-creator/campaigns {name, system} — create one, GM = caller

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  const stmt = system
    ? env.DB.prepare('SELECT id, name, system, gm_email FROM campaigns WHERE system = ? ORDER BY name').bind(system)
    : env.DB.prepare('SELECT id, name, system, gm_email FROM campaigns ORDER BY name');
  const { results } = await stmt.all();
  return json({ campaigns: results });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const body = await request.json();
  if (!body.name || !['rifts', 'palladium-fantasy'].includes(body.system)) {
    return json({ error: 'name and a valid system are required' }, 400);
  }
  const row = await env.DB.prepare(
    'INSERT INTO campaigns (name, system, gm_email) VALUES (?, ?, ?) RETURNING id, name, system, gm_email'
  ).bind(body.name, body.system, email).first();
  return json({ campaign: row }, 201);
}
