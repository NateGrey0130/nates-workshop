// GET  /api/character-creator/import/sessions?catalog=spells        — open sessions
// GET  /api/character-creator/import/sessions?id=3                  — one session + its staged rows
// POST /api/character-creator/import/sessions                       — start one
//        { catalog, name, source_book? }
// POST /api/character-creator/import/sessions?id=3&close=1          — close one
//
// Admin only. A session is the container for a long import: submit page ranges
// one at a time, review what accumulates, confirm in batches.

import { requireAdmin, json, readJson } from '../_lib/auth.js';
import { getImportSpec } from '../_lib/import-engine.js';
import { createSession, listSessions, getSession, getStaged, closeSession } from '../_lib/import-sessions.js';

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const params = new URL(request.url).searchParams;
  const id = parseInt(params.get('id'), 10);

  if (Number.isFinite(id)) {
    const session = await getSession(env, id);
    if (!session) return json({ error: 'No session with that id' }, 404);
    return json({ session, staged: await getStaged(env, id, { pendingOnly: false }) });
  }

  const catalog = params.get('catalog');
  if (!getImportSpec(catalog)) return json({ error: 'Unknown catalog' }, 400);
  return json({ sessions: await listSessions(env, { catalog, includeClosed: params.get('all') === '1' }) });
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const params = new URL(request.url).searchParams;
  const id = parseInt(params.get('id'), 10);

  if (Number.isFinite(id) && params.get('close') === '1') {
    const closed = await closeSession(env, id);
    if (!closed) return json({ error: 'No open session with that id' }, 404);
    return json({ ok: true, id, closed: true });
  }

  const b = await readJson(request);
  if (!b) return json({ error: 'Body must be JSON' }, 400);
  if (!getImportSpec(b.catalog)) return json({ error: 'Unknown catalog' }, 400);

  const name = typeof b.name === 'string' && b.name.trim() ? b.name.trim() : null;
  if (!name) return json({ error: 'A session name is required' }, 400);

  const sessionId = await createSession(env, {
    catalog: b.catalog,
    name,
    sourceBook: typeof b.source_book === 'string' && b.source_book.trim() ? b.source_book.trim() : null,
    // Validated in createSession — anything that is not a real system, including
    // 'both', stores NULL and therefore restricts nothing.
    system: typeof b.system === 'string' ? b.system.trim() : null,
    email: guard.email,
  });
  return json({ ok: true, id: sessionId }, 201);
}
