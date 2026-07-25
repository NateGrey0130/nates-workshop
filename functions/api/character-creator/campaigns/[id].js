// GET   /api/character-creator/campaigns/:id — campaign details. gm_notes is
//       the one field NOT open to all authenticated friends: it holds GM
//       spoilers/secrets and is stripped unless the caller is the GM.
// PATCH /api/character-creator/campaigns/:id — GM only; gm_notes only.

import { getUserEmail, unauthorized, json, forbidden, campaignAccess } from '../_lib/auth.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const campaign = await env.DB.prepare('SELECT * FROM campaigns WHERE id = ?').bind(params.id).first();
  if (!campaign) return json({ error: 'Campaign not found' }, 404);
  const is_gm = email === campaign.gm_email;
  if (!is_gm) delete campaign.gm_notes;
  return json({ campaign, is_gm });
}

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await campaignAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Campaign not found' }, 404);
  if (!access.canWrite) return forbidden();

  const body = await request.json();
  if (!('gm_notes' in body)) return json({ error: 'gm_notes is the only editable field' }, 400);
  await env.DB.prepare('UPDATE campaigns SET gm_notes = ? WHERE id = ?')
    .bind(body.gm_notes ?? null, params.id).run();
  return json({ ok: true });
}
