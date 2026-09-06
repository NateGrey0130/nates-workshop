// GET  /api/character-creator/campaigns/:id/items — the party stash. Members
//      only. ?include_removed=1 returns the history as well as what is held.
// POST /api/character-creator/campaigns/:id/items — add to the stash:
//      { item_id | custom_name, qty?, notes?, journal_entry_id? }
//
// The character's inventory, owned by the party instead. Same shape as
// character_items on purpose — real gear catalog rows, freeform items allowed,
// and soft-deleted rather than deleted, because "what did we used to have" is
// a question a party asks and a DELETE cannot answer.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

// The gear row is joined in rather than copied, so a catalog correction reaches
// the stash the same way it reaches a character sheet.
// Joined on the slug since RETRO-AUDIT R21 - same three arms as the character
// sheet's read, and the same reason: a gear id is insertion order.
const SELECT = `SELECT ci.*, g.name AS item_name, g.slug AS item_slug, g.category AS item_category,
                       g.weight_lbs, g.cost, c.name AS claimed_by_name
                FROM campaign_items ci
                LEFT JOIN catalog_redirects cr ON cr.catalog = 'gear' AND cr.from_key = ci.gear_slug
                LEFT JOIN gear g ON g.slug = ci.gear_slug
                                 OR g.id = cr.to_id
                                 OR (ci.gear_slug IS NULL AND g.id = ci.item_id)
                LEFT JOIN characters c ON c.id = ci.claimed_by_character_id`;

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  // Membership gates reading the stash, as it does the notes: the two are the
  // same kind of shared record.
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }

  const url = new URL(request.url);
  const includeRemoved = url.searchParams.get('include_removed') === '1';
  const where = includeRemoved ? 'ci.campaign_id = ?' : 'ci.campaign_id = ? AND ci.removed_at IS NULL';
  const { limit, offset } = paging(request);

  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM campaign_items ci WHERE ${where}`,
    countBinds: [params.id],
    rowsSql: `${SELECT} WHERE ${where} ORDER BY ci.removed_at IS NOT NULL, ci.added_at DESC, ci.id DESC`,
    rowsBinds: [params.id],
    limit, offset,
  });
  return json(pageBody('items', page));
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const itemId = Number.isFinite(Number(b.item_id)) ? Math.trunc(Number(b.item_id)) : null;
  const customName = typeof b.custom_name === 'string' && b.custom_name.trim()
    ? b.custom_name.trim() : null;
  if (!itemId && !customName) {
    return json({ error: 'Needs an item_id from the gear catalog, or a custom_name' }, 400);
  }
  const qty = Number.isFinite(Number(b.qty)) && Number(b.qty) > 0 ? Math.trunc(Number(b.qty)) : 1;

  // The entry has to belong to THIS campaign. A stash row pointing at another
  // table's session note would leak the note's existence through the join.
  const entryId = await entryInCampaign(env, b.journal_entry_id, params.id);

  const row = await env.DB.prepare(
    `INSERT INTO campaign_items (campaign_id, item_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by)
     VALUES (?, ?, (SELECT slug FROM gear WHERE id = ?), ?, ?, ?, ?, ?) RETURNING id`
  ).bind(params.id, itemId, itemId, customName, qty, b.notes ?? null, entryId, guard.email).first();

  const created = await env.DB.prepare(`${SELECT} WHERE ci.id = ?`).bind(row.id).first();
  return json({ item: created }, 201);
}

export async function entryInCampaign(env, rawId, campaignId) {
  if (!Number.isFinite(Number(rawId))) return null;
  const found = await env.DB.prepare(
    'SELECT id FROM journal_entries WHERE id = ? AND campaign_id = ?'
  ).bind(Math.trunc(Number(rawId)), campaignId).first();
  return found ? found.id : null;
}
