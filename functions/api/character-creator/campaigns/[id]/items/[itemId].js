// PATCH  /api/character-creator/campaigns/:id/items/:itemId — { qty?, notes? }
// DELETE /api/character-creator/campaigns/:id/items/:itemId — take it out of
//        the stash. A soft delete: removed_at and removed_by are set and the
//        row stays, because "what did we used to have" is a question a party
//        asks and a real DELETE cannot answer.
// POST   …/items/:itemId with { claim_for_character_id, qty? } — move it (or
//        `qty` of it) onto a character's sheet. See below: this is the one
//        that has to be atomic. The way back is characters/[id]/items/
//        [itemId]/stash.js.

import { json, readJson, requireCampaign, isHiddenNpc } from '../../../_lib/auth.js';

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
  //
  // An NPC reads as absent to anyone but the G.M. (isHiddenNpc): the 403 below
  // would otherwise confirm that an id a player guessed is one of the G.M.'s.
  const character = await env.DB.prepare(
    'SELECT id, name, player_email, campaign_id, kind FROM characters WHERE id = ? AND campaign_id = ?'
  ).bind(characterId, params.id).first();
  if (!character || isHiddenNpc(character.kind, guard.access.campaign.gm_email, guard.email)) {
    return json({ error: 'That character is not in this campaign' }, 404);
  }
  if (character.player_email !== guard.email && !guard.access.isGm) {
    return json({ error: 'Only that character’s owner or the GM can claim an item for it' }, 403);
  }

  // PART OF A STACK: `qty` below the row's quantity takes that many and leaves
  // the rest in the stash - three of the party's twelve arrows, not all twelve
  // or none. Absent, or the whole quantity, is the whole-row claim below,
  // unchanged.
  const want = b?.qty == null ? row.qty : Math.trunc(Number(b.qty));
  if (!Number.isFinite(want) || want < 1 || want > row.qty) {
    return json({ error: `qty must be between 1 and ${row.qty}` }, 400);
  }
  if (want < row.qty) {
    // Three statements under one guard - still held, still MORE than `want` -
    // so two part-claims racing cannot take more than the stack holds: the
    // loser copies nothing and changes nothing. The third writes a history row
    // for the part that left, already removed and marked claimed, so "No
    // longer held" says who took the three arrows the way it says who took a
    // whole row.
    const guardSql = 'FROM campaign_items WHERE id = ? AND campaign_id = ? AND removed_at IS NULL AND qty > ?';
    const results = await env.DB.batch([
      env.DB.prepare(
        `INSERT INTO character_items (character_id, gear_slug, custom_name, qty, notes, journal_entry_id)
         SELECT ?, gear_slug, custom_name, ?, notes, journal_entry_id ${guardSql}`
      ).bind(characterId, want, row.id, params.id, want),
      env.DB.prepare(
        `INSERT INTO campaign_items (campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id,
                                     added_by, added_at, removed_at, removed_by, claimed_by_character_id)
         SELECT campaign_id, gear_slug, custom_name, ?, notes, journal_entry_id,
                added_by, added_at, datetime('now'), ?, ? ${guardSql}`
      ).bind(want, guard.email, characterId, row.id, params.id, want),
      env.DB.prepare(
        `UPDATE campaign_items SET qty = qty - ? WHERE id = ? AND campaign_id = ? AND removed_at IS NULL AND qty > ?`
      ).bind(want, row.id, params.id, want),
    ]);
    if (!results[0].meta?.changes) {
      return json({ error: 'The stash changed while you were claiming; nothing was taken' }, 409);
    }
    return json({ ok: true, claimed_by: character.name, claimed: want, left: row.qty - want });
  }

  await env.DB.batch([
    env.DB.prepare(
      `UPDATE campaign_items SET removed_at = datetime('now'), removed_by = ?,
              claimed_by_character_id = ? WHERE id = ?`
    ).bind(guard.email, characterId, row.id),
    // The stash row's own slug, carried straight across. Until migration 046
    // this derived the slug from the id, because a row written before 044 had
    // an id and no slug; 045 backfilled every such row and dropped the column,
    // so the slug is now the only thing there is to copy. RETRO-AUDIT R21.
    env.DB.prepare(
      `INSERT INTO character_items (character_id, gear_slug, custom_name, qty, notes, journal_entry_id)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(characterId, row.gear_slug, row.custom_name, row.qty, row.notes, row.journal_entry_id),
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
