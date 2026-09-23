// /api/marvel-heroes/power-text?code=MG10 - the full text of one power, or of
// one section's introduction (?code=MG), from msh_power_text.
//
// GET only: this route reads a table that nothing on the site writes. Pages
// answers any other method with a 405 because onRequestGet is the only handler.
//
// The table is EMPTY on any database built from the repo - its rows come from
// a gitignored extraction of the book (migration 081) - so a missing row is a
// normal answer, not an error: 404 with `missing: true`, and the app shows the
// committed summary instead.
//
// Signed-in users only. The site is behind Access; this is the second check,
// because the text is TSR's and the endpoint is the only way to read it.

import { getAccessEmail } from '../_lib/access.js';

// A power code as the roll tables write it (D1, DT22, MCo6), or a bare class code.
export const CODE = /^(D|DT|EC|EE|F|I|L|MG|MC|MCo|MCr|M|P|PC|S|T)([1-9]\d?)?$/;

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'private, max-age=3600' },
  });
}

export async function onRequestGet({ request, env }) {
  const url = new URL(request.url);
  const local = url.hostname === 'localhost' || url.hostname === '127.0.0.1';
  if (!getAccessEmail(request) && !local) return json({ error: 'not signed in' }, 401);

  const code = url.searchParams.get('code') || '';
  if (!CODE.test(code)) return json({ error: 'not a power code' }, 400);

  const row = await env.DB.prepare('SELECT code, name, page, body FROM msh_power_text WHERE code = ?')
    .bind(code).first();
  if (!row) return json({ code, missing: true }, 404);
  return json(row);
}
