// GET /api/media-vault/duplicates → the caller's library, sorted into groups
// that share a title and a type.
//
// READ-ONLY, ON PURPOSE. This endpoint finds and explains; it never writes.
// Accepting a group is the client sending the merged survivor to items/bulk and
// the losing ids to items/bulk-delete — the two endpoints that already exist,
// already batch as transactions, and already feed the undo buffer. A scanner
// that could also delete would be a second path to deleting rows in bulk, and
// this app was rebuilt specifically to have one of those rather than two.
//
// The decision half is planDedupe, kept pure in _lib/dedupe.js so the smoke
// test can prove what a scan would say without a database.

import { getUserEmail, json, rowToItem } from './_lib/common.js';
import { planDedupe } from './_lib/dedupe.js';

export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  try {
    // Same ORDER BY as items.js, so a group's members are listed in the order
    // the library shows them and the survivor is not merely the first row the
    // database felt like returning. dupSurvivor sorts explicitly regardless.
    const { results } = await context.env.DB
      .prepare('SELECT * FROM media_items WHERE user_email = ? ORDER BY added_at')
      .bind(email)
      .all();
    return json(planDedupe(results.map(rowToItem)));
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
