// POST /api/character-creator/characters/:id/items — add an inventory row
// (owner/GM). Catalog-linked via item slug, or freeform via custom_name.
// Optional journal_entry_id ties the addition to a session log entry.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { access } = guard;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
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

    // gear_slug is derived FROM item_id inside the same statement, rather than
    // looked up in JS and bound separately. That is what makes the two keys
    // unable to disagree: there is no window, no second round trip, and no
    // caller that can pass one without the other. RETRO-AUDIT R21.
  const row = await env.DB.prepare(
    `INSERT INTO character_items (character_id, item_id, gear_slug, custom_name, qty, equipped, notes, journal_entry_id)
     VALUES (?, ?, (SELECT slug FROM gear WHERE id = ?), ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, itemId, itemId, itemId ? null : b.custom_name, Math.max(1, parseInt(b.qty, 10) || 1),
         b.equipped ? 1 : 0, b.notes ?? null, journalId).first();
  return json({ item: row }, 201);
}
