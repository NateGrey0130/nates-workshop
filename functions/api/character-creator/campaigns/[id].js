// GET   /api/character-creator/campaigns/:id — campaign details. gm_notes is
//       the one field NOT open to all authenticated friends: it holds GM
//       spoilers/secrets and is stripped unless the caller is the GM.
//       Also reports `is_member`, which the campaign page uses to decide
//       whether to offer a composer at all.
// PATCH /api/character-creator/campaigns/:id — GM only; gm_notes, open and
//       rest_rates (UI-AUDIT F52: the table's per-hour recovery, by pool).
//       `open` is the join gate: joining a campaign IS creating a character in
//       it, so whether creation is open to the site is the GM's call and
//       nobody else's. See POST /characters for where it is enforced.
// DELETE /api/character-creator/campaigns/:id — the GM who created it, and
//       only while no one else has a character in it. It marks the campaign
//       deleted (migration 092) and removes nothing: the row, everything that
//       hangs off it and its pictures in R2 all stay, and every read skips it
//       and the characters in it. Restoring is clearing `deleted_at` by SQL.

import { getUserEmail, unauthorized, json, forbidden, campaignAccess, readJson, requireCampaign, tooLong, TEXT_MAX } from '../_lib/auth.js';
import { POOL_KEYS as REST_POOLS } from '../../../../apps/character-creator/js/dice.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  // A deleted campaign (migration 092) answers as a missing one does.
  const campaign = await env.DB.prepare('SELECT * FROM campaigns WHERE id = ? AND deleted_at IS NULL')
    .bind(params.id).first();
  if (!campaign) return json({ error: 'Campaign not found' }, 404);
  const is_gm = email === campaign.gm_email;
  if (!is_gm) delete campaign.gm_notes;
  const access = await campaignAccess(env, params.id, email);
  return json({ campaign, is_gm, is_member: access.isMember });
}

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await campaignAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Campaign not found' }, 404);
  // isGm, not canWrite: canWrite is now membership, and gm_notes is the one
  // field on a campaign that members deliberately cannot touch.
  if (!access.isGm) return forbidden();

  const body = await readJson(request);
  if (!body) return json({ error: 'Invalid JSON body' }, 400);
  const over = tooLong([['The G.M. notes', body.gm_notes, TEXT_MAX.section]]);
  if (over) return over;
  const sets = [], binds = [];
  if ('gm_notes' in body) { sets.push('gm_notes = ?'); binds.push(body.gm_notes ?? null); }
  if ('open' in body) { sets.push('open = ?'); binds.push(body.open ? 1 : 0); }
  // The table's rest rates (UI-AUDIT F52). Only the five pools, only numbers of
  // zero or more; a zero is dropped rather than stored, and an object with
  // nothing left - or null - clears the column. Still no default: NULL means
  // the table has not said, and the sheet falls back to the device's own.
  if ('rest_rates' in body) {
    const v = body.rest_rates;
    if (v !== null && (typeof v !== 'object' || Array.isArray(v))) {
      return json({ error: 'rest_rates must be an object of per-hour rates, or null' }, 400);
    }
    const out = {};
    for (const [k, r] of Object.entries(v || {})) {
      if (!REST_POOLS.includes(k)) return json({ error: `Not a pool: ${k}` }, 400);
      const n = Number(r);
      if (!Number.isFinite(n) || n < 0) return json({ error: `The ${k} rate must be a number of 0 or more` }, 400);
      if (n > 0) out[k] = n;
    }
    sets.push('rest_rates = ?');
    binds.push(Object.keys(out).length ? JSON.stringify(out) : null);
  }
  if (!sets.length) return json({ error: 'gm_notes, open and rest_rates are the editable fields' }, 400);
  await env.DB.prepare(`UPDATE campaigns SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, params.id).run();
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  // gm_email IS the creator: POST /campaigns sets it to the caller and nothing
  // changes it afterwards.
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;
  const gmEmail = guard.access.campaign.gm_email;

  // OTHER PLAYERS' CHARACTERS ARE NOT THE GM'S TO DELETE. Deleting the
  // campaign hides every character in it, so it would take every player's
  // sheet out of reach. Refuse, and name what is in the way, so the table can
  // sort it out - each player deletes their own character, and then the GM
  // can go ahead. The GM's own characters and statted NPCs are theirs, and
  // are hidden with the campaign.
  // A character its player has deleted (migration 091) is in nobody's way: it
  // is already deleted, and it is not named.
  const { results: others } = await env.DB.prepare(
    'SELECT name, player_email FROM characters WHERE campaign_id = ? AND player_email <> ? AND deleted_at IS NULL ORDER BY name'
  ).bind(params.id, gmEmail).all();
  if (others?.length) {
    return json({
      error: `Other players still have ${others.length} character${others.length === 1 ? '' : 's'} in this campaign`,
      characters: others,
    }, 409);
  }

  // MARKED, NOT REMOVED (migration 092). The row stays, and so does
  // everything that cascaded from it - characters, pages, notes, stash,
  // dossiers - and this route deletes nothing from the bucket: a deleted
  // campaign keeps its pictures, and a restore by SQL brings it back whole
  // (Nate, 2026-10-12). Nothing purges it later either.
  await env.DB.prepare(
    "UPDATE campaigns SET deleted_at = datetime('now') WHERE id = ? AND gm_email = ? AND deleted_at IS NULL"
  ).bind(params.id, gmEmail).run();
  return json({ ok: true });
}
