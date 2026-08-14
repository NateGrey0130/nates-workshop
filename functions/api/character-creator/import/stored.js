// GET    /api/character-creator/import/stored             — list live saved imports (admin)
// GET    /api/character-creator/import/stored?retired=1    — list retired classes instead
// GET    /api/character-creator/import/stored?class_id=x   — fetch one, with markdown
// DELETE /api/character-creator/import/stored?class_id=x   — retire (published) or remove (draft)
// POST   /api/character-creator/import/stored?class_id=x   — restore a retired class
//
// Drafts are autosaved on extraction; published rows are live classes.
//
// Deleting a published class retires it rather than destroying it, because D1 is
// the only source of class definitions and a hard DELETE was unrecoverable.
// Drafts are still removed outright — they are in-progress extractions, usually
// being cleared on purpose.

import { requireAdmin, json } from '../_lib/auth.js';
import { listStored, getStored, deleteStored, restoreStored, countRetired } from '../_lib/class-store.js';

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const params = new URL(request.url).searchParams;
  const classId = params.get('class_id');
  if (classId) {
    const row = await getStored(env, classId);
    if (!row) return json({ error: 'No stored class with that id' }, 404);
    return json({ stored: row });
  }

  const retired = params.get('retired') === '1';
  return json({
    stored: await listStored(env, { retired }),
    retired,
    // Always reported so the live list can show how many are in the archive
    // without a second request.
    retired_count: await countRetired(env),
  });
}

export async function onRequestDelete({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const classId = new URL(request.url).searchParams.get('class_id');
  if (!classId) return json({ error: 'class_id is required' }, 400);

  const { changes, mode } = await deleteStored(env, classId);
  if (mode === 'none') return json({ error: 'No stored class with that id' }, 404);
  if (mode === 'already_retired') return json({ error: 'That class is already retired' }, 409);
  if (!changes) return json({ error: 'Nothing was changed' }, 409);

  // `mode` tells the UI whether this is undoable, so it can say so accurately.
  return json({ ok: true, class_id: classId, mode });
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const classId = new URL(request.url).searchParams.get('class_id');
  if (!classId) return json({ error: 'class_id is required' }, 400);

  const restored = await restoreStored(env, classId);
  if (!restored) return json({ error: 'No retired class with that id' }, 404);
  return json({ ok: true, class_id: classId, mode: 'restored' });
}
