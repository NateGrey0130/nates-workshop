// GET   /api/character-creator/campaigns/:id — campaign details. gm_notes is
//       the one field NOT open to all authenticated friends: it holds GM
//       spoilers/secrets and is stripped unless the caller is the GM.
//       Also reports `is_member`, which the campaign page uses to decide
//       whether to offer a composer at all.
// PATCH /api/character-creator/campaigns/:id — GM only; gm_notes only.

import { getUserEmail, unauthorized, json, forbidden, campaignAccess, readJson } from '../_lib/auth.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const campaign = await env.DB.prepare('SELECT * FROM campaigns WHERE id = ?').bind(params.id).first();
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
  if (!('gm_notes' in body)) return json({ error: 'gm_notes is the only editable field' }, 400);
  await env.DB.prepare('UPDATE campaigns SET gm_notes = ? WHERE id = ?')
    .bind(body.gm_notes ?? null, params.id).run();
  return json({ ok: true });
}
