// The Table, Marvel's half: the D1 questions the shared table routes
// (functions/api/_lib/table-room.js) ask, answered from this group's own
// database. The shared file may reach no D1, so everything that names
// `DB_MARVEL` or a Marvel table is here.
//
// A PLAYER is the owner of a hero linked to the campaign. A hero is linked,
// never copied (migration 086), so ownership is msh_heroes.owner_email.

import { owner } from './campaigns.js';

export const game = 'marvel';
export const email = owner;

const id = (v) => (/^[1-9]\d{0,11}$/.test(String(v ?? '')) ? Number(v) : null);

export async function campaign(env, campaignId) {
  const cid = id(campaignId);
  if (!cid) return null;
  const row = await env.DB_MARVEL.prepare('SELECT id, name, gm_email FROM msh_campaigns WHERE id = ?').bind(cid).first();
  return row ? { id: row.id, name: row.name, gmEmail: row.gm_email } : null;
}

export async function characters(env, campaignId, who) {
  const { results } = await env.DB_MARVEL.prepare(
    `SELECT h.id, h.name FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
     WHERE ch.campaign_id = ? AND h.owner_email = ? ORDER BY h.name`
  ).bind(campaignId, who).all();
  return results.map((r) => ({ id: String(r.id), name: r.name }));
}

// Marvel's sheet does not send rolls to the table in phase 1: its FEAT rolls
// are made in the table's own dice box. So no hero is a sheet roller yet.
export async function character() {
  return null;
}

export async function openSession(env, campaignId) {
  return env.DB_MARVEL.prepare(
    'SELECT id, code FROM msh_table_sessions WHERE campaign_id = ? AND closed_at IS NULL'
  ).bind(campaignId).first();
}

export async function startSession(env, campaignId, code, who) {
  await env.DB_MARVEL.prepare(
    'INSERT INTO msh_table_sessions (campaign_id, code, opened_by) VALUES (?, ?, ?)'
  ).bind(campaignId, code, who).run();
}

export async function saveSession(env, sessionId, { feed, reason }) {
  await env.DB_MARVEL.prepare(
    `UPDATE msh_table_sessions SET closed_at = datetime('now'), closed_reason = ?, feed = ?, roll_count = ?
     WHERE id = ? AND closed_at IS NULL`
  ).bind(reason, JSON.stringify(feed), feed.length, sessionId).run();
}

export async function sessions(env, campaignId, limit) {
  const { results } = await env.DB_MARVEL.prepare(
    `SELECT id, code, opened_by, opened_at, closed_at, closed_reason, roll_count, feed
     FROM msh_table_sessions WHERE campaign_id = ? AND closed_at IS NOT NULL ORDER BY id DESC LIMIT ?`
  ).bind(campaignId, limit).all();
  return results;
}
