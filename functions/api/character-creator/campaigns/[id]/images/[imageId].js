// GET    …/images/:imageId — the bytes. THE GM ALWAYS; A MEMBER ONLY ONCE REVEALED.
// PATCH  …/images/:imageId — caption, order, and reveal/unreveal. GM only.
// DELETE …/images/:imageId — the row and its R2 object. GM only.
//
// THE GET IS THE WHOLE FEATURE'S RULE IN ONE FUNCTION, so it is written to be
// read: an image that has not been revealed does not exist for a player. Not
// "is hidden in the UI" - the bytes are refused, because the UI is not what
// keeps a secret. `isHiddenNpc` makes the same argument for a GM's statted NPC.
//
// The image is never served from a public bucket URL, for the reason
// npcs/[npcId]/portrait.js gives: the whole site is behind Access and a
// campaign's pictures are as private as its notes.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';

async function found(env, params) {
  return env.DB.prepare(
    'SELECT * FROM campaign_images WHERE id = ? AND campaign_id = ?'
  ).bind(params.imageId, params.id).first();
}

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);

  const image = await found(env, params);
  if (!image) return json({ error: 'Image not found' }, 404);
  // 404 rather than 403 for a player, and deliberately: a refusal that says
  // "you may not see THIS" tells them a picture exists and that the GM is
  // holding it back. Not found is what an unrevealed image is, to them.
  if (!image.revealed_at && !guard.access.isGm) return json({ error: 'Image not found' }, 404);

  const object = await env.MEDIA.get(image.r2_key);
  // The row says there is an image and the store disagrees: reported, not
  // treated as absence, because only one of the two is a bug.
  if (!object) return json({ error: 'Image is recorded but missing from storage' }, 502);

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || image.content_type || 'application/octet-stream',
      // The key carries a uuid and never changes for a given row, so this is
      // immutable - and private, because it sits behind Access and must not
      // land in a shared cache.
      'Cache-Control': 'private, max-age=31536000, immutable',
    },
  });
}

export async function onRequestPatch({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const image = await found(env, params);
  if (!image) return json({ error: 'Image not found' }, 404);

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [];
  const binds = [];
  // Asking for a change the row already has is not an error. Revealing an
  // image that is already revealed writes nothing - the timestamp must not
  // move - and that left `sets` empty, so the request came back 400 saying
  // nothing was editable. A regression run caught it; pressing Reveal twice at
  // a table is the likeliest thing a GM will do.
  const known = ['caption', 'sort', 'revealed'].some((k) => k in b);
  if ('caption' in b) { sets.push('caption = ?'); binds.push(b.caption ?? null); }
  if ('sort' in b) {
    const n = Number(b.sort);
    if (!Number.isFinite(n)) return json({ error: 'sort must be a number' }, 400);
    sets.push('sort = ?'); binds.push(Math.trunc(n));
  }
  // Reveal is a timestamp rather than a flag, so "shown, and when" survives.
  // Revealing twice does NOT re-stamp it: the answer to "when did they first
  // see this" should not move because a button was pressed again.
  if ('revealed' in b) {
    if (b.revealed) {
      if (!image.revealed_at) { sets.push("revealed_at = datetime('now')"); }
    } else {
      sets.push('revealed_at = NULL');
    }
  }
  if (!sets.length) {
    if (!known) return json({ error: 'caption, sort and revealed are the editable fields' }, 400);
    // The row as the other verbs return it: the R2 key is storage, not API.
    const { r2_key: _key, campaign_id: _cid, ...unchanged } = image;
    return json({ image: unchanged });
  }

  const row = await env.DB.prepare(
    `UPDATE campaign_images SET ${sets.join(', ')} WHERE id = ? AND campaign_id = ?
     RETURNING id, entry_id, caption, content_type, byte_size, revealed_at, sort, created_at`
  ).bind(...binds, params.imageId, params.id).first();
  return json({ image: row });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const image = await found(env, params);
  if (!image) return json({ error: 'Image not found' }, 404);

  await env.DB.prepare('DELETE FROM campaign_images WHERE id = ? AND campaign_id = ?')
    .bind(params.imageId, params.id).run();
  // The row goes first: a row pointing at a deleted object is a broken
  // picture, and an object nobody points at is only storage. The bucket delete
  // is tolerated for the same reason it is in npcs/[npcId].js.
  if (env.MEDIA) {
    try { await env.MEDIA.delete(image.r2_key); } catch { /* see above */ }
  }
  return json({ ok: true });
}
