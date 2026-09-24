// POST /api/character-creator/characters/:id/items/:itemId/stash — { qty? }
//
// Hand an item from this character's inventory to their campaign's party
// stash: the other half of the stash's "claim", which moves loot the other
// way (campaigns/[id]/items/[itemId].js). Before this, giving something back
// to the party was two edits on two pages - remove it here, type it again
// there - and either half alone left the item in two places or none.
//
// `qty` below the row's quantity SPLITS the row: that many go to the stash and
// the rest stay on the sheet. Absent, or the whole quantity, moves the row.
//
// ONE BATCH, for the reason the claim gives: an item that left the sheet
// without arriving in the stash is destroyed, and one that arrived without
// leaving is duplicated. Both statements carry the same guard - the row still
// held, still holding at least `qty` - so two presses at once cannot move the
// same item twice: the second finds nothing to copy and nothing to change.
//
// Who may: whoever may write this character (its owner or the G.M.). Owning a
// character in a campaign is what membership IS (docs/campaign-and-play.md),
// so no second campaign check is needed - the character's own campaign_id is
// the only stash it can reach.
//
// AN ENCHANTED ITEM IS REFUSED. campaign_items has no enchantments column, so
// the move would silently strip what makes it a Demon Slayer rather than a
// long sword. Say so, rather than lose it.
//
// The character's play log gets a 'stash' event naming what went, so the
// session recap can say it. It carries no changes to reverse, so undo skips
// it (events/undo.js lists the kind) rather than spending a press on nothing.

import { getUserEmail, unauthorized, json, readJson, forbidden, characterAccess } from '../../../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const character = await env.DB.prepare('SELECT id, name, campaign_id FROM characters WHERE id = ?')
    .bind(params.id).first();
  if (!character?.campaign_id) {
    return json({ error: 'This character is not in a campaign, so there is no party stash to give it to' }, 409);
  }

  const row = await env.DB.prepare(
    `SELECT ci.*, g.name AS item_name FROM character_items ci
       LEFT JOIN gear g ON g.slug = ci.gear_slug
      WHERE ci.id = ? AND ci.character_id = ? AND ci.removed_at IS NULL`
  ).bind(params.itemId, params.id).first();
  if (!row) return json({ error: 'Inventory row not found' }, 404);

  let held = [];
  try { held = JSON.parse(row.enchantments || '[]'); } catch { held = []; }
  if (Array.isArray(held) && held.length) {
    return json({ error: 'An enchanted item cannot go to the stash: the stash has nowhere to keep its enchantments' }, 409);
  }

  const b = (await readJson(request)) || {};
  const want = b.qty == null ? row.qty : Math.trunc(Number(b.qty));
  if (!Number.isFinite(want) || want < 1 || want > row.qty) {
    return json({ error: `qty must be between 1 and ${row.qty}` }, 400);
  }
  const whole = want === row.qty;
  const name = row.item_name || row.custom_name || 'an item';

  const results = await env.DB.batch([
    // Copied from the row as it stands at the moment of the write, not from
    // the read above, under the same guard the second statement uses.
    env.DB.prepare(
      `INSERT INTO campaign_items (campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by)
       SELECT ?, gear_slug, custom_name, ?, notes, journal_entry_id, ?
         FROM character_items WHERE id = ? AND character_id = ? AND removed_at IS NULL AND qty >= ?`
    ).bind(character.campaign_id, want, email, row.id, params.id, want),
    whole
      ? env.DB.prepare(
          `UPDATE character_items SET removed_at = datetime('now')
            WHERE id = ? AND character_id = ? AND removed_at IS NULL AND qty >= ?`
        ).bind(row.id, params.id, want)
      : env.DB.prepare(
          `UPDATE character_items SET qty = qty - ?
            WHERE id = ? AND character_id = ? AND removed_at IS NULL AND qty > ?`
        ).bind(want, row.id, params.id, want),
  ]);
  if (!results[0].meta?.changes) {
    return json({ error: 'That item changed while you were moving it; nothing was moved' }, 409);
  }

  const note = `gave ${want > 1 ? `${want} × ` : ''}${name} to the party stash`;
  await env.DB.prepare(
    'INSERT INTO play_events (character_id, actor_email, kind, payload) VALUES (?, ?, ?, ?)'
  ).bind(params.id, email, 'stash', JSON.stringify({ note })).run();

  return json({ ok: true, moved: want, left: row.qty - want, note });
}
