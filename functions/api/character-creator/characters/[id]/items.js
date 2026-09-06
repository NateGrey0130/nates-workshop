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
  let gearSlug = null;
  if (b.slug) {
    const item = await env.DB.prepare('SELECT slug FROM gear WHERE slug = ?').bind(b.slug).first();
    if (!item) return json({ error: `No catalog item with slug: ${b.slug}` }, 400);
    gearSlug = item.slug;
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

  // This route always spoke SLUGS - its body field is `slug`, not `item_id` -
  // so since migration 046 dropped the stored id there is nothing to translate:
  // the slug the caller sent is the slug that is stored. The lookup above stays
  // because it is what refuses a slug the catalog does not have.
  // RETRO-AUDIT R21.
  const row = await env.DB.prepare(
    `INSERT INTO character_items (character_id, gear_slug, custom_name, qty, equipped, notes, journal_entry_id)
     VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, gearSlug, gearSlug ? null : b.custom_name, Math.max(1, parseInt(b.qty, 10) || 1),
         b.equipped ? 1 : 0, b.notes ?? null, journalId).first();
  return json({ item: row }, 201);
}
