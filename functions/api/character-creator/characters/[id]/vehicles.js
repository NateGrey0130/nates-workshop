// POST /api/character-creator/characters/:id/vehicles — give this character a
// vessel (owner/GM). Catalog-linked via `slug`, or freeform via `custom_name`.
// Optional `journal_entry_id` ties the acquisition to a session log entry.
//
// The shape is `characters/:id/items` deliberately, down to the field names: a
// vessel is acquired, named, damaged and lost the same way a suit of armour is,
// and two routes that do the same thing should not need reading twice. What is
// NOT copied is `qty` and `equipped` - the wrong questions about a robot.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { access } = guard;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);

  // The lookup is what refuses a slug the catalog does not have. Without it a
  // typo stores a reference that resolves to nothing, and the sheet renders a
  // vessel with a name and no stat block - which looks like missing data rather
  // than a bad write.
  let vehicleSlug = null;
  if (b.slug) {
    const v = await env.DB.prepare('SELECT slug FROM vehicles WHERE slug = ?').bind(b.slug).first();
    if (!v) return json({ error: `No vessel with slug: ${b.slug}` }, 400);
    vehicleSlug = v.slug;
  } else if (!b.custom_name) {
    return json({ error: 'slug or custom_name is required' }, 400);
  }

  let journalId = null;
  if (b.journal_entry_id) {
    const entry = await env.DB.prepare('SELECT id, campaign_id FROM journal_entries WHERE id = ?')
      .bind(b.journal_entry_id).first();
    if (!entry || entry.campaign_id !== access.character.campaign_id) {
      return json({ error: 'journal_entry_id does not belong to this campaign' }, 400);
    }
    journalId = entry.id;
  }

  // `mdc_current` is NOT settable here. A vessel arrives undamaged, and NULL
  // decodes to `{}` - see _lib/character-json.js. Damage is a PATCH, which is
  // also where it gets validated against the vessel's own locations.
  const row = await env.DB.prepare(
    `INSERT INTO character_vehicles (character_id, vehicle_slug, custom_name, nickname, notes, journal_entry_id)
     VALUES (?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, vehicleSlug, vehicleSlug ? null : b.custom_name,
         b.nickname ?? null, b.notes ?? null, journalId).first();
  return json({ vehicle: row }, 201);
}
