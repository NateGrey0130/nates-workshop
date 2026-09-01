// GET  /api/character-creator/campaigns            — list campaigns (optionally ?system=)
//      ?limit= and ?offset= page (default 200, max 500)
// POST /api/character-creator/campaigns {name, system} — create one, GM = caller

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { paging, pagedQuery } from './_lib/paging.js';

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  const { limit, offset } = paging(request);
  const where = system ? ' WHERE system = ?' : '';
  const binds = system ? [system] : [];

  // created_at and the character count are here so the wizard's step 1 can
  // tell two campaigns of the same name apart. It could not: a save refused
  // after the campaign row was already created leaves an empty duplicate, and
  // the list rendered nothing but the name and the system, so both rows read
  // identically and neither said which one held the character. UI-AUDIT F9.
  //
  // Read-only, and it does not touch the create-before-validate ordering that
  // produces the duplicate - that is a server question and F9 puts it out of
  // scope on purpose.
  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM campaigns${where}`,
    countBinds: binds,
    rowsSql: `SELECT c.id, c.name, c.system, c.gm_email, c.open, c.created_at,
        (SELECT count(*) FROM characters WHERE campaign_id = c.id) AS character_count
      FROM campaigns c${where ? ' WHERE c.system = ?' : ''} ORDER BY c.name`,
    rowsBinds: binds,
    limit, offset,
  });

  // Whether THIS caller may create a character in each row — open, their own
  // campaign, or one they already have a character in. Computed here rather
  // than in the wizard because the wizard would need the whole character list
  // to answer it, and the server is the boundary anyway; the picker only uses
  // this to disable an option instead of offering a refusal.
  const { results: mine } = await env.DB.prepare(
    'SELECT DISTINCT campaign_id FROM characters WHERE player_email = ?'
  ).bind(email).all();
  const memberOf = new Set((mine || []).map((r) => r.campaign_id));
  for (const c of page.results) {
    c.can_join = !!c.open || c.gm_email === email || memberOf.has(c.id);
  }

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
