// GET  /api/character-creator/campaigns            — list campaigns (optionally ?system=)
//      ?limit= and ?offset= page (default 200, max 500)
// POST /api/character-creator/campaigns {name, system} — create one, GM = caller

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { paging, pagedQuery } from './_lib/paging.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  const { limit, offset } = paging(request);
  const where = system ? ' WHERE system = ?' : '';
  const binds = system ? [system] : [];

  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM campaigns${where}`,
    countBinds: binds,
    rowsSql: `SELECT id, name, system, gm_email FROM campaigns${where} ORDER BY name`,
    rowsBinds: binds,
    limit, offset,
  });

  return json({ campaigns: page.results, total: page.total, limit: page.limit, offset: page.offset });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const body = await readJson(request);
  if (!body) return json({ error: 'Invalid JSON body' }, 400);
  if (!body.name || !['rifts', 'palladium-fantasy'].includes(body.system)) {
    return json({ error: 'name and a valid system are required' }, 400);
  }
  const row = await env.DB.prepare(
    'INSERT INTO campaigns (name, system, gm_email) VALUES (?, ?, ?) RETURNING id, name, system, gm_email'
  ).bind(body.name, body.system, email).first();
  return json({ campaign: row }, 201);
}
