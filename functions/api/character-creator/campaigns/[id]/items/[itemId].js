// PATCH  /api/character-creator/campaigns/:id/items/:itemId — { qty?, notes? }
// DELETE /api/character-creator/campaigns/:id/items/:itemId — take it out of
//        the stash. A soft delete: removed_at and removed_by are set and the
//        row stays, because "what did we used to have" is a question a party
//        asks and a real DELETE cannot answer.
// POST   …/items/:itemId with { claim_for_character_id } — move it onto a
//        character's sheet. See below: this is the one that has to be atomic.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';

export async function onRequestPatch({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const row = await held(env, params);
  if (!row) return json({ error: 'Item not found in this stash' }, 404);

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if (Number.isFinite(Number(b.qty)) && Number(b.qty) > 0) {
    sets.push('qty = ?'); binds.push(Math.trunc(Number(b.qty)));
  }
  if ('notes' in b) { sets.push('notes = ?'); binds.push(b.notes ?? null); }
  if (!sets.length) return json({ error: 'Nothing to update — send qty or notes' }, 400);

  await env.DB.prepare(`UPDATE campaign_items SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, row.id).run();
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const row = await held(env, params);
  if (!row) return json({ error: 'Item not found in this stash' }, 404);

  await env.DB.prepare(
    "UPDATE campaign_items SET removed_at = datetime('now'), removed_by = ? WHERE id = ?"
  ).bind(guard.email, row.id).run();
  return json({ ok: true });
}

// Claiming an item onto a sheet.
//
// ONE BATCH, because the two halves are the same fact stated twice: an item
// that left the stash without arriving on the sheet is destroyed, and one that
// arrived without leaving has been duplicated. Neither is recoverable by
// looking at the result, which is what makes this worth a batch rather than
// two awaits.
export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const row = await held(env, params);
  if (!row) return json({ error: 'Item not found in this stash' }, 404);

  const b = await readJson(request);
  const characterId = Number.isFinite(Number(b?.claim_for_character_id))
    ? Math.trunc(Number(b.claim_for_character_id)) : null;
  if (!characterId) return json({ error: 'claim_for_character_id is required' }, 400);

  // The character must be in THIS campaign, and the claimer must be allowed to
  // write to it — otherwise a member could push party loot onto someone else's
  // sheet, which is a table argument the app should not be able to start.
  const character = await env.DB.prepare(
    'SELECT id, name, player_email, campaign_id FROM characters WHERE id = ? AND campaign_id = ?'
  ).bind(characterId, params.id).first();
  if (!character) return json({ error: 'That character is not in this campaign' }, 404);
  if (character.player_email !== guard.email && !guard.access.isGm) {
    return json({ error: 'Only that character’s owner or the GM can claim an item for it' }, 403);
  }

  await env.DB.batch([
    env.DB.prepare(
      `UPDATE campaign_items SET removed_at = datetime('now'), removed_by = ?,
              claimed_by_character_id = ? WHERE id = ?`
    ).bind(guard.email, characterId, row.id),
    env.DB.prepare(
      `INSERT INTO character_items (character_id, item_id, custom_name, qty, notes, journal_entry_id)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(characterId, row.item_id, row.custom_name, row.qty, row.notes, row.journal_entry_id),
  ]);

  return json({ ok: true, claimed_by: character.name });
}

// The row, only while it is still in the stash. Editing or claiming something
// already taken is a 404 rather than a silent no-op, so two people acting at
// once find out.
async function held(env, params) {
  return env.DB.prepare(
    'SELECT * FROM campaign_items WHERE id = ? AND campaign_id = ? AND removed_at IS NULL'
  ).bind(params.itemId, params.id).first();
}
