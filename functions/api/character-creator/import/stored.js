// GET    /api/character-creator/import/stored             — list live saved imports (admin)
// GET    /api/character-creator/import/stored?retired=1    — list retired classes instead
// GET    /api/character-creator/import/stored?class_id=x   — fetch one, with markdown
// DELETE /api/character-creator/import/stored?class_id=x   — retire (published) or remove (draft)
// POST   /api/character-creator/import/stored?class_id=x   — restore a retired class
// PUT    /api/character-creator/import/stored               — save { markdown } as a draft
//
// Drafts are autosaved on extraction; published rows are live classes.
//
// Deleting a published class retires it rather than destroying it, because D1 is
// the only source of class definitions and a hard DELETE was unrecoverable.
// Drafts are still removed outright — they are in-progress extractions, usually
// being cleared on purpose.

import { requireAdmin, json, readJson } from '../_lib/auth.js';
import { listStored, getStored, deleteStored, restoreStored, countRetired, saveDraft } from '../_lib/class-store.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

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

// Save hand-written markdown as a draft, without publishing it.
//
// Extraction has always autosaved a draft the moment it parses; a class written
// by hand had no equivalent, so a closed tab lost it. This is that path, and it
// is what "new class from template" writes.
//
// Deliberately more permissive than confirm: a draft only has to PARSE, not
// validate. Half-written is the normal state of a draft, and refusing to save
// one until it is correct would mean losing exactly the work most worth keeping.
export async function onRequestPut({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b?.markdown) return json({ error: 'markdown is required' }, 400);

  const parsed = parseClassMarkdown(b.markdown);
  if (!parsed.data?.id) {
    return json({ error: 'Could not read an id from the frontmatter: ' + parsed.errors.join('; ') }, 400);
  }

  // Never overwrite a PUBLISHED class from here — that is what confirm is for,
  // and it runs the cross-reference and the full validation this skips.
  const existing = await getStored(env, parsed.data.id);
  if (existing?.status === 'published') {
    return json({ error: `"${parsed.data.id}" is already published — open it and use Confirm to change it` }, 409);
  }

  await saveDraft(env, {
    classId: parsed.data.id,
    name: parsed.data.name,
    system: parsed.data.system,
    markdown: b.markdown,
    email: guard.email,
  });
  return json({ ok: true, class_id: parsed.data.id, ok_to_publish: parsed.ok, errors: parsed.errors });
}
