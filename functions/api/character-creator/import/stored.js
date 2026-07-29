// GET    /api/character-creator/import/stored            — list saved imports (admin)
// GET    /api/character-creator/import/stored?class_id=x  — fetch one, with markdown
// DELETE /api/character-creator/import/stored?class_id=x  — remove one
//
// Drafts are autosaved on extraction; published rows are live classes.

import { requireAdmin, json } from '../_lib/auth.js';
import { listStored, getStored, deleteStored } from '../_lib/class-store.js';

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const classId = new URL(request.url).searchParams.get('class_id');
  if (classId) {
    const row = await getStored(env, classId);
    if (!row) return json({ error: 'No stored class with that id' }, 404);
    return json({ stored: row });
  }
  return json({ stored: await listStored(env) });
}

export async function onRequestDelete({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const classId = new URL(request.url).searchParams.get('class_id');
  if (!classId) return json({ error: 'class_id is required' }, 400);
  const removed = await deleteStored(env, classId);
  if (!removed) return json({ error: 'No stored class with that id' }, 404);
  return json({ ok: true, class_id: classId });
}
