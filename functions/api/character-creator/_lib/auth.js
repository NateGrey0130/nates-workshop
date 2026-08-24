// Auth via the existing Zero Trust setup: Cloudflare Access sits in front of the
// whole site and injects the verified identity as a request header. No new auth here.

import { getAccessEmail, isAdminEmail } from '../../_lib/access.js';

export function getUserEmail(request) {
  const email = getAccessEmail(request);
  if (email) return email;
  // Local dev (wrangler pages dev) has no Access in front of it.
  const host = new URL(request.url).hostname;
  if (host === 'localhost' || host === '127.0.0.1') return 'dev@localhost';
  return null;
}

export function unauthorized() {
  return new Response(JSON.stringify({ error: 'Not authenticated via Cloudflare Access' }), {
    status: 401,
    headers: { 'Content-Type': 'application/json' },
  });
}

export function json(data, status = 200, headers = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...headers },
  });
}

export function isAdmin(request, env) {
  return isAdminEmail(getUserEmail(request), env);
}

// Guard for admin-only endpoints: returns { email } when allowed, or { res }
// holding the response to return. Admin is global, not campaign-scoped.
export function requireAdmin(request, env) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  if (!isAdminEmail(email, env)) {
    return { res: json({ error: 'Admin only' }, 403) };
  }
  return { email };
}

// Parses a JSON body without throwing. A malformed body should be a 400 from
// the handler, not an opaque 500 from an unhandled rejection.
export async function readJson(request) {
  try {
    return await request.json();
  } catch {
    return null;
  }
}

export function forbidden() {
  return json({ error: 'Not allowed — only the character owner or campaign GM can do that' }, 403);
}

// Write-permission model (reads stay open to any authenticated friend):
// a character is writable by its owner (player_email) or its campaign's GM;
// campaign-level actions are GM-only.

export async function characterAccess(env, characterId, email) {
  const row = await env.DB.prepare(
    `SELECT characters.id, characters.player_email, characters.campaign_id, campaigns.gm_email
     FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id
     WHERE characters.id = ?`
  ).bind(characterId).first();
  if (!row) return { found: false, canWrite: false, isGm: false };
  return {
    found: true,
    canWrite: email === row.player_email || email === row.gm_email,
    isGm: email === row.gm_email,
    character: row,
  };
}

// Guard for a character endpoint, in the shape requireAdmin() already uses:
// { res } means stop and return it, otherwise { email, access }. Every handler
// under characters/[id] opened with the same five lines - identity, then found,
// then writable - and five lines repeated nine times is five lines that can be
// four somewhere by mistake. The ordering matters and is easy to get subtly
// wrong: 404 before 403, so a stranger probing ids cannot tell an existing
// character from a missing one by which refusal comes back.
//
// `id` is explicit rather than read from params, because journal.js authorises a
// character named in the request BODY, and a helper that could only reach
// params.id would quietly not apply there.
//
// write: false is the read guard - reads stay open to any authenticated user, so
// it stops after the existence check.
export async function requireCharacter(request, env, id, { write = true } = {}) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const access = await characterAccess(env, id, email);
  if (!access.found) return { res: json({ error: 'Character not found' }, 404) };
  if (write && !access.canWrite) return { res: forbidden() };
  return { email, access };
}

// Who is IN a campaign, and what that lets them do.
//
// There is no campaign_members table, deliberately. A person is a member if
// they are the G.M. or they own a character assigned to the campaign - which
// the characters row already says, because owning a character in a campaign is
// what being a player IS. An invite list would be a second, weaker statement of
// the same fact, kept in sync by hand.
//
// The cost is real and accepted: a spectator, or a player between characters,
// cannot post. When that bites, an invite list can be added HERE and nothing
// else has to learn about it - this function is the only thing that knows.
//
// `canWrite` is membership. `isGm` is the narrower right, and the two are
// returned separately because a few actions stay G.M.-only: editing the
// campaign's gm_notes, and deleting an entry somebody else wrote.
export async function campaignAccess(env, campaignId, email) {
  const row = await env.DB.prepare('SELECT id, gm_email FROM campaigns WHERE id = ?').bind(campaignId).first();
  if (!row) return { found: false, canWrite: false, isGm: false, isMember: false };
  const isGm = email === row.gm_email;
  let isMember = isGm;
  if (!isMember) {
    const own = await env.DB.prepare(
      'SELECT 1 AS n FROM characters WHERE campaign_id = ? AND player_email = ? LIMIT 1'
    ).bind(campaignId, email).first();
    isMember = !!own;
  }
  return { found: true, canWrite: isMember, isGm, isMember, campaign: row };
}

// Guard for a campaign endpoint, in the shape requireCharacter() already uses:
// { res } means stop and return it, otherwise { email, access }.
//
// 404 before 403, so someone probing ids cannot tell an existing campaign from
// a missing one by which refusal comes back.
export async function requireCampaign(request, env, id, { write = true, gm = false } = {}) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const access = await campaignAccess(env, id, email);
  if (!access.found) return { res: json({ error: 'Campaign not found' }, 404) };
  if (gm && !access.isGm) {
    return { res: json({ error: 'Only the campaign GM can do that' }, 403) };
  }
  if (write && !access.canWrite) {
    return { res: json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403) };
  }
  return { email, access };
}
