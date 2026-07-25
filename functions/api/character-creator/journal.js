// GET  /api/character-creator/journal?campaign_id=&character_id= — newest first.
//      character_id omitted = all entries for the campaign (NULL character_id
//      rows are campaign-level).
// POST /api/character-creator/journal — character-level entries need owner/GM
//      of that character; campaign-level entries (no character_id) need the GM.

import { getUserEmail, unauthorized, json, forbidden, characterAccess, campaignAccess } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const url = new URL(request.url);
  const campaignId = url.searchParams.get('campaign_id');
  const characterId = url.searchParams.get('character_id');
  if (!campaignId) return json({ error: 'campaign_id is required' }, 400);

  const stmt = characterId
    ? env.DB.prepare(
        'SELECT * FROM journal_entries WHERE campaign_id = ? AND character_id = ? ORDER BY created_at DESC, id DESC'
      ).bind(campaignId, characterId)
    : env.DB.prepare(
        'SELECT * FROM journal_entries WHERE campaign_id = ? ORDER BY created_at DESC, id DESC'
      ).bind(campaignId);
  const { results } = await stmt.all();
  return json({ entries: results });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await request.json();
  if (!b.body || typeof b.body !== 'string') return json({ error: 'body is required' }, 400);

  let campaignId;
  if (b.character_id) {
    const access = await characterAccess(env, b.character_id, email);
    if (!access.found) return json({ error: 'Character not found' }, 404);
    if (!access.canWrite) return forbidden();
    campaignId = access.character.campaign_id; // derived, not trusted from the client
  } else {
    if (!b.campaign_id) return json({ error: 'campaign_id or character_id is required' }, 400);
    const access = await campaignAccess(env, b.campaign_id, email);
    if (!access.found) return json({ error: 'Campaign not found' }, 404);
    if (!access.canWrite) return forbidden();
    campaignId = b.campaign_id;
  }

  const row = await env.DB.prepare(
    `INSERT INTO journal_entries (campaign_id, character_id, author_email, title, body, session_date)
     VALUES (?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(campaignId, b.character_id ?? null, email, b.title ?? null, b.body, b.session_date ?? null).first();
  return json({ entry: row }, 201);
}
