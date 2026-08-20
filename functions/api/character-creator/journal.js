// GET  /api/character-creator/journal?campaign_id=&character_id= — newest first.
//      character_id omitted = all entries for the campaign (NULL character_id
//      rows are campaign-level).
// POST /api/character-creator/journal — character-level entries need owner/GM
//      of that character; campaign-level entries (no character_id) need the GM.

import { getUserEmail, unauthorized, json, forbidden, characterAccess, campaignAccess, readJson } from './_lib/auth.js';
import { paging, pagedQuery, pageBody } from './_lib/paging.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const url = new URL(request.url);
  const campaignId = url.searchParams.get('campaign_id');
  const characterId = url.searchParams.get('character_id');
  if (!campaignId) return json({ error: 'campaign_id is required' }, 400);

  // A character sheet wants that character's entries plus campaign-level ones,
  // which is a filter only the server can express — it used to fetch the whole
  // campaign's log and discard the rest client-side.
  const includeCampaign = url.searchParams.get('include_campaign') === '1';
  const { limit, offset } = paging(request);

  // The three shapes differ only in their WHERE clause, so build that once and
  // let the shared pager add LIMIT/OFFSET and the count.
  let where, binds;
  if (characterId && includeCampaign) {
    where = 'campaign_id = ? AND (character_id = ? OR character_id IS NULL)';
    binds = [campaignId, characterId];
  } else if (characterId) {
    where = 'campaign_id = ? AND character_id = ?';
    binds = [campaignId, characterId];
  } else {
    where = 'campaign_id = ?';
    binds = [campaignId];
  }

  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM journal_entries WHERE ${where}`,
    countBinds: binds,
    rowsSql: `SELECT * FROM journal_entries WHERE ${where} ORDER BY created_at DESC, id DESC`,
    rowsBinds: binds,
    limit, offset,
  });

  return json(pageBody('entries', page));
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
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
