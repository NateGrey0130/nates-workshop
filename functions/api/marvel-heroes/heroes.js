// /api/marvel-heroes/heroes - the heroes a person has saved in Marvel Heroes.
//
//   GET              -> { heroes: [{ id, name, snapshot, updated_at }] }, newest first
//   GET ?id=<id>     -> { hero } with its build, snapshot and sheet
//   POST { hero }    -> save: a new hero without an id, an update with one;
//                       an update with no `sheet` keeps the one already saved
//   DELETE ?id=<id>  -> delete one
//
// Every query is scoped to the caller's Access email, as MediaVault's are:
// a hero someone else owns answers exactly like one that does not exist.
// Local dev has no Access in front of it, so localhost is dev@localhost.

import { getAccessEmail } from '../_lib/access.js';
import { sanitizeHero, rowToHero, MAX_HEROES, ID } from './_lib/heroes.js';

function owner(request) {
  const email = getAccessEmail(request);
  if (email) return email;
  const host = new URL(request.url).hostname;
  return host === 'localhost' || host === '127.0.0.1' ? 'dev@localhost' : null;
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  });
}

export async function onRequestGet({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  const id = new URL(request.url).searchParams.get('id');
  if (id !== null) {
    if (!ID.test(id)) return json({ error: 'not a hero id' }, 400);
    const row = await env.DB.prepare('SELECT * FROM msh_heroes WHERE id = ? AND owner_email = ?').bind(id, email).first();
    return row ? json({ hero: rowToHero(row) }) : json({ error: 'no such hero' }, 404);
  }
  const { results } = await env.DB
    .prepare('SELECT id, name, snapshot, updated_at FROM msh_heroes WHERE owner_email = ? ORDER BY updated_at DESC, name')
    .bind(email).all();
  return json({ heroes: results.map((r) => { const h = rowToHero({ ...r, build: '{}', sheet: '{}' }); return { id: h.id, name: h.name, snapshot: h.snapshot, updated_at: h.updated_at }; }) });
}

export async function onRequestPost({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  let body;
  try { body = await request.json(); } catch { return json({ error: 'Invalid JSON body' }, 400); }
  const { hero, error } = sanitizeHero(body);
  if (error) return json({ error }, 400);
  const db = env.DB;

  if (hero.id) {
    // An update touches only a row this owner already has; anything else is a 404,
    // so a guessed id cannot overwrite someone else's hero or plant one under theirs.
    const res = await db.prepare(`UPDATE msh_heroes SET name = ?, build = ?, snapshot = ?, sheet = COALESCE(?, sheet), updated_at = datetime('now')
      WHERE id = ? AND owner_email = ?`).bind(hero.name, hero.build, hero.snapshot, hero.sheet, hero.id, email).run();
    if (!res.meta?.changes) return json({ error: 'no such hero' }, 404);
    return json({ ok: true, id: hero.id });
  }

  const { n } = await db.prepare('SELECT COUNT(*) AS n FROM msh_heroes WHERE owner_email = ?').bind(email).first();
  if (n >= MAX_HEROES) return json({ error: `You have ${MAX_HEROES} heroes saved, which is the most there is room for` }, 400);
  const id = crypto.randomUUID();
  await db.prepare('INSERT INTO msh_heroes (id, owner_email, name, build, snapshot, sheet) VALUES (?, ?, ?, ?, ?, ?)')
    .bind(id, email, hero.name, hero.build, hero.snapshot, hero.sheet ?? '{}').run();
  return json({ ok: true, id }, 201);
}

export async function onRequestDelete({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  const id = new URL(request.url).searchParams.get('id');
  if (!id || !ID.test(id)) return json({ error: 'not a hero id' }, 400);
  const res = await env.DB.prepare('DELETE FROM msh_heroes WHERE id = ? AND owner_email = ?').bind(id, email).run();
  return res.meta?.changes ? json({ ok: true }) : json({ error: 'no such hero' }, 404);
}
