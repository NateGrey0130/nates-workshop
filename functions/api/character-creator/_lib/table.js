// The Table, Palladium's half: the D1 questions the shared table routes
// (functions/api/_lib/table-room.js) ask, answered from this group's own
// database. The shared file may reach no D1, so everything that names `DB` or a
// Palladium table is here.
//
// A PLAYER is someone with a player character in the campaign - `kind = 'pc'`,
// so a GM's statted NPC (migration 070) never seats anyone.

import { getUserEmail } from './auth.js';
import { playerView } from './city-view.js';
import { citySvg } from './city-svg.js';

export const game = 'palladium';
export const email = getUserEmail;

const id = (v) => (/^[1-9]\d{0,11}$/.test(String(v ?? '')) ? Number(v) : null);

export async function campaign(env, campaignId) {
  const cid = id(campaignId);
  if (!cid) return null;
  const row = await env.DB.prepare('SELECT id, name, gm_email FROM campaigns WHERE id = ?').bind(cid).first();
  return row ? { id: row.id, name: row.name, gmEmail: row.gm_email } : null;
}

export async function characters(env, campaignId, who) {
  const { results } = await env.DB.prepare(
    `SELECT id, name FROM characters WHERE campaign_id = ? AND player_email = ? AND kind = 'pc' ORDER BY name`
  ).bind(campaignId, who).all();
  return results.map((r) => ({ id: String(r.id), name: r.name }));
}

export async function character(env, characterId) {
  const cid = id(characterId);
  if (!cid) return null;
  const row = await env.DB.prepare(
    `SELECT id, name, campaign_id, player_email FROM characters WHERE id = ? AND kind = 'pc'`
  ).bind(cid).first();
  return row ? { id: row.id, name: row.name, campaignId: row.campaign_id, email: row.player_email } : null;
}

export async function openSession(env, campaignId) {
  return env.DB.prepare(
    'SELECT id, code FROM table_sessions WHERE campaign_id = ? AND closed_at IS NULL'
  ).bind(campaignId).first();
}

// The partial unique index on (campaign_id) WHERE closed_at IS NULL is what
// makes a second open table for one campaign fail here rather than exist.
export async function startSession(env, campaignId, code, who) {
  await env.DB.prepare(
    'INSERT INTO table_sessions (campaign_id, code, opened_by) VALUES (?, ?, ?)'
  ).bind(campaignId, code, who).run();
}

export async function saveSession(env, sessionId, { feed, reason }) {
  await env.DB.prepare(
    `UPDATE table_sessions SET closed_at = datetime('now'), closed_reason = ?, feed = ?, roll_count = ?
     WHERE id = ? AND closed_at IS NULL`
  ).bind(reason, JSON.stringify(feed), feed.length, sessionId).run();
}

export async function sessions(env, campaignId, limit) {
  const { results } = await env.DB.prepare(
    `SELECT id, code, opened_by, opened_at, closed_at, closed_reason, roll_count, feed
     FROM table_sessions WHERE campaign_id = ? AND closed_at IS NOT NULL ORDER BY id DESC LIMIT ?`
  ).bind(campaignId, limit).all();
  return results;
}

// ---------- pictures on the table (phase 2) ----------
//
// Two kinds on this side: a setting page's picture, and a City Creator city's
// map. Each is looked up INSIDE the campaign the table is for, so a ref naming
// another campaign's picture is not found. Whether the caller may have it at
// all is the room's question, asked by the shared route before this is called.

async function imageRow(env, campaignId, ref) {
  return env.DB.prepare('SELECT id, r2_key, content_type, caption FROM campaign_images WHERE id = ? AND campaign_id = ?')
    .bind(Number(ref.id), campaignId).first();
}

async function cityRow(env, campaignId, ref) {
  return env.DB.prepare('SELECT id, campaign_id, name, data FROM cities WHERE id = ? AND campaign_id = ?')
    .bind(Number(ref.id), campaignId).first();
}

// The caption the table shows. A picture's own caption and nothing else - the
// page it sits on is titled for the GM, and its title may give a plot away. A
// city by the name its players' view carries.
export async function describe(env, campaignId, ref) {
  if (ref.kind === 'image') {
    const row = await imageRow(env, campaignId, ref);
    return row ? { caption: row.caption || '' } : null;
  }
  if (ref.kind === 'city') {
    const row = await cityRow(env, campaignId, ref);
    if (!row) return null;
    try { return { caption: playerView(row, JSON.parse(row.data)).name }; } catch { return null; }
  }
  return null;
}

export async function image(env, campaignId, ref) {
  if (ref.kind === 'image') {
    const row = await imageRow(env, campaignId, ref);
    if (!row) return null;
    if (!env.MEDIA) return { error: 'Image storage is not configured on this environment', status: 501 };
    const object = await env.MEDIA.get(row.r2_key);
    if (!object) return { error: 'Image is recorded but missing from storage', status: 502 };
    return { body: object.body, contentType: object.httpMetadata?.contentType || row.content_type };
  }
  if (ref.kind === 'city') {
    const row = await cityRow(env, campaignId, ref);
    if (!row) return null;
    let city;
    try { city = JSON.parse(row.data); } catch { return { error: 'This city cannot be read', status: 500 }; }
    return { body: citySvg(playerView(row, city)), contentType: 'image/svg+xml; charset=utf-8' };
  }
  return null;
}
