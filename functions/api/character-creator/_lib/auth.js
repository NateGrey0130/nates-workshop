// Auth via the existing Zero Trust setup: Cloudflare Access sits in front of the
// whole site and injects the verified identity as a request header. No new auth here.

import { getAccessEmail } from '../../_lib/access.js';

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

export function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
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

export async function campaignAccess(env, campaignId, email) {
  const row = await env.DB.prepare('SELECT id, gm_email FROM campaigns WHERE id = ?').bind(campaignId).first();
  if (!row) return { found: false, canWrite: false };
  return { found: true, canWrite: email === row.gm_email, campaign: row };
}
