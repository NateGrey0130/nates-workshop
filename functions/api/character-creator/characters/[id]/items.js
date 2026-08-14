// POST /api/character-creator/characters/:id/items — add an inventory row
// (owner/GM). Catalog-linked via item slug, or freeform via custom_name.
// Optional journal_entry_id ties the addition to a session log entry.

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const b = await request.json();
  let itemId = null;
  if (b.slug) {
    const item = await env.DB.prepare('SELECT id FROM gear WHERE slug = ?').bind(b.slug).first();
    if (!item) return json({ error: `No catalog item with slug: ${b.slug}` }, 400);
    itemId = item.id;
  } else if (!b.custom_name) {
    return json({ error: 'slug or custom_name is required' }, 400);
  }

  let journalId = null;
  if (b.journal_entry_id) {
    const entry = await env.DB.prepare('SELECT id, campaign_id FROM journal_entries WHERE id = ?').bind(b.journal_entry_id).first();
    if (!entry || entry.campaign_id !== access.character.campaign_id) {
      return json({ error: 'journal_entry_id does not belong to this campaign' }, 400);
    }
    journalId = entry.id;
  }

  const row = await env.DB.prepare(
    `INSERT INTO character_items (character_id, item_id, custom_name, qty, equipped, notes, journal_entry_id)
     VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, itemId, itemId ? null : b.custom_name, Math.max(1, parseInt(b.qty, 10) || 1),
         b.equipped ? 1 : 0, b.notes ?? null, journalId).first();
  return json({ item: row }, 201);
}
