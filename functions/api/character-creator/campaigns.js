// GET  /api/character-creator/campaigns            — list campaigns (optionally ?system=)
//      ?limit= and ?offset= page (default 200, max 500)
// POST /api/character-creator/campaigns {name, system, description?, open?} — create one, GM = caller.
//      No character is needed: the GM is campaigns.gm_email, not a characters row.

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
  // PLAYER characters only: this list goes to everyone signed in, and a count
  // that included the G.M.'s NPCs (migration 070) would tell a player how many
  // the G.M. had prepared - the one thing isHiddenNpc exists to keep private.
  //
  // Read-only, and it does not touch the create-before-validate ordering that
  // produces the duplicate - that is a server question and F9 puts it out of
  // scope on purpose.
  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM campaigns${where}`,
    countBinds: binds,
    rowsSql: `SELECT c.id, c.name, c.system, c.gm_email, c.open, c.created_at,
        (SELECT count(*) FROM characters WHERE campaign_id = c.id AND kind = 'pc') AS character_count
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
  // THE LIST IS HERE AS WELL AS IN THE SCHEMA, and that is the point of this
  // line rather than an accident: the CHECK refuses a bad value with a 500, and
  // this refuses it with a 400 that says what was wrong. Both have to move
  // together - BOOK-INGEST-AUDIT F73's premise audit found this gate AFTER the
  // finding had been written, because the grep behind it was scoped to
  // `apps/character-creator/` and this lives under `functions/`. Widening the
  // schema alone would have shipped a database that accepts a Heroes Unlimited
  // campaign and an API that still refuses to create one.
  //
  // `VALID_SYSTEMS` in js/parser.js is the same four values for classes. Kept as
  // a literal rather than imported: this is a Worker route and that is a browser
  // module, and the import would drag the whole parser into every request.
  const name = typeof body.name === 'string' ? body.name.trim() : '';
  if (!name
      || !['rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited'].includes(body.system)) {
    return json({ error: 'name and a valid system are required' }, 400);
  }
  // description and open are optional, and exist here because a campaign can
  // now be made on its own - the list's "Create a campaign" form - rather than
  // only as a side effect of the wizard saving a character, which sends
  // neither. Omitted, they are the schema's own defaults: no description, and
  // open (1), so the wizard's path creates exactly what it always did.
  if (body.description != null && typeof body.description !== 'string') {
    return json({ error: 'description must be text' }, 400);
  }
  const description = (body.description || '').trim() || null;
  const open = 'open' in body ? (body.open ? 1 : 0) : 1;
  const row = await env.DB.prepare(
    `INSERT INTO campaigns (name, system, gm_email, description, open) VALUES (?, ?, ?, ?, ?)
     RETURNING id, name, system, gm_email, description, open`
  ).bind(name, body.system, email, description, open).first();
  return json({ campaign: row }, 201);
}
