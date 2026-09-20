// GET    …/entries/:entryId — one page, with its pictures. GM only.
// PATCH  …/entries/:entryId — title, kind or body.
// DELETE …/entries/:entryId — the page, its image rows, and their R2 objects.
//
// GM ONLY throughout, for the reason entries.js gives: the page is the GM's
// notebook and nothing here is ever revealed. The pictures are, one at a time,
// through images/[imageId].js.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';
import { KINDS } from '../entries.js';

async function found(env, params) {
  return env.DB.prepare(
    'SELECT * FROM campaign_entries WHERE id = ? AND campaign_id = ?'
  ).bind(params.entryId, params.id).first();
}

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false, gm: true });
  if (guard.res) return guard.res;
  const entry = await found(env, params);
  if (!entry) return json({ error: 'Page not found' }, 404);

  const { results } = await env.DB.prepare(
    `SELECT id, caption, content_type, byte_size, revealed_at, sort, created_at
       FROM campaign_images WHERE entry_id = ? ORDER BY sort, id`
  ).bind(params.entryId).all();
  return json({ entry, images: results ?? [] });
}

export async function onRequestPatch({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const entry = await found(env, params);
  if (!entry) return json({ error: 'Page not found' }, 404);

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [];
  const binds = [];
  if ('title' in b) {
    const title = typeof b.title === 'string' ? b.title.trim() : '';
    if (!title) return json({ error: 'title cannot be emptied' }, 400);
    sets.push('title = ?'); binds.push(title);
  }
  if ('kind' in b) {
    if (!KINDS.includes(b.kind)) return json({ error: `kind must be one of ${KINDS.join(', ')}` }, 400);
    sets.push('kind = ?'); binds.push(b.kind);
  }
  if ('body' in b) { sets.push('body = ?'); binds.push(b.body ?? null); }
  if (!sets.length) return json({ error: 'title, kind and body are the editable fields' }, 400);

  sets.push("updated_at = datetime('now')");
  const row = await env.DB.prepare(
    `UPDATE campaign_entries SET ${sets.join(', ')} WHERE id = ? AND campaign_id = ? RETURNING *`
  ).bind(...binds, params.entryId, params.id).first();
  return json({ entry: row });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const entry = await found(env, params);
  if (!entry) return json({ error: 'Page not found' }, 404);

  // THE BUCKET FIRST, and by hand. `campaign_images` cascades with the row,
  // and no cascade reaches R2 - an object nobody can name is invisible and
  // billed every month. Same order and same tolerance as npcs/[npcId].js: a
  // failed object delete must not leave the page half-deleted, so it is
  // swallowed and the row goes anyway.
  const { results } = await env.DB.prepare(
    'SELECT r2_key FROM campaign_images WHERE entry_id = ?'
  ).bind(params.entryId).all();
  if (env.MEDIA) {
    for (const row of results ?? []) {
      try { await env.MEDIA.delete(row.r2_key); } catch { /* see above */ }
    }
  }
  await env.DB.prepare('DELETE FROM campaign_entries WHERE id = ? AND campaign_id = ?')
    .bind(params.entryId, params.id).run();
  return json({ ok: true, images_deleted: (results ?? []).length });
}
