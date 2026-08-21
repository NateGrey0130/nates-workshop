// GET    …/npcs/:npcId/portrait — stream the image. Members only.
// POST   …/npcs/:npcId/portrait — upload one (raw body, image/*).
// DELETE …/npcs/:npcId/portrait — remove it.
//
// THE IMAGE IS NEVER SERVED FROM A PUBLIC BUCKET URL. The whole site sits
// behind Cloudflare Access, and an unauthenticated image endpoint would be the
// one hole in it — a campaign's portraits are as private as its notes. Every
// read goes through this Function and its membership check.
//
// This is the site's first use of R2. The binding is `MEDIA`, named for the
// site rather than for this app, because MediaVault stores cover art as text
// today and filament-forge already reads file bytes: the second and third users
// exist. See SETUP.md — the bucket must exist before the deploy that binds it.

import { json, requireCampaign } from '../../../../_lib/auth.js';

const MAX_BYTES = 5 * 1024 * 1024;
const TYPES = {
  'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp', 'image/gif': 'gif',
};

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);

  // Two different 404s. The optional chain collapsed them into one, so asking
  // for a portrait of an NPC that does not exist answered "No portrait" - true
  // in the way a sentence can be true and still send the reader the wrong way,
  // since it describes a dossier rather than the absence of one.
  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);
  if (!npc.portrait_key) return json({ error: 'No portrait' }, 404);

  const object = await env.MEDIA.get(npc.portrait_key);
  // The row says there is an image and the store disagrees. Reported rather
  // than treated as "no portrait", because the two mean different things and
  // only one of them is a bug.
  if (!object) return json({ error: 'Portrait is recorded but missing from storage' }, 502);

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType || 'application/octet-stream',
      // The key carries a uuid and changes whenever the image does, so the
      // response for a given key is immutable and can be cached hard. Private,
      // because this is behind Access and must not sit in a shared cache.
      'Cache-Control': 'private, max-age=31536000, immutable',
      'Content-Disposition': 'inline',
    },
  });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);

  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);

  const contentType = (request.headers.get('Content-Type') || '').split(';')[0].trim().toLowerCase();
  const ext = TYPES[contentType];
  // An allowlist, not a blocklist: the type decides what is stored AND what is
  // sent back later, so anything not on this list is something the GET would be
  // handing a browser without knowing what it is.
  if (!ext) {
    return json({ error: `Unsupported image type. Send one of: ${Object.keys(TYPES).join(', ')}` }, 415);
  }

  const bytes = await request.arrayBuffer();
  if (!bytes.byteLength) return json({ error: 'Empty upload' }, 400);
  if (bytes.byteLength > MAX_BYTES) {
    return json({ error: `Portrait must be under ${MAX_BYTES / 1024 / 1024}MB` }, 413);
  }

  // Keyed by campaign and NPC so the store is browsable and a stray object is
  // traceable; the uuid makes every upload a new key, which is what lets the
  // GET set an immutable cache header.
  const key = `npc/${params.id}/${params.npcId}/${crypto.randomUUID()}.${ext}`;
  await env.MEDIA.put(key, bytes, { httpMetadata: { contentType } });

  // Write the row BEFORE deleting the old object. The other order can leave a
  // dossier pointing at an object that no longer exists if the update fails;
  // this order can at worst leave an orphan nobody points at, which costs
  // storage rather than a broken portrait.
  await env.DB.prepare("UPDATE npcs SET portrait_key = ?, updated_at = datetime('now') WHERE id = ?")
    .bind(key, params.npcId).run();
  if (npc.portrait_key && npc.portrait_key !== key) {
    try { await env.MEDIA.delete(npc.portrait_key); } catch { /* see above */ }
  }

  return json({ ok: true, portrait_key: key });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);
  if (!npc.portrait_key) return json({ ok: true });

  await env.DB.prepare("UPDATE npcs SET portrait_key = NULL, updated_at = datetime('now') WHERE id = ?")
    .bind(params.npcId).run();
  if (env.MEDIA) {
    try { await env.MEDIA.delete(npc.portrait_key); } catch { /* see above */ }
  }
  return json({ ok: true });
}

async function found(env, params) {
  return env.DB.prepare('SELECT id, portrait_key FROM npcs WHERE id = ? AND campaign_id = ?')
    .bind(params.npcId, params.id).first();
}
