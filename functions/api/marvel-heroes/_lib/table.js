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

// ---------- initiative (phase 3) ----------
//
// R25 reads a combatant's Agility NUMBER and whether it holds one of the two
// initiative Talents. Both come off the sheet's snapshot here; which Talent
// ids count is the room's to decide (workers/table-room/src/marvel.js reads
// the app's talents.json), so this passes the ids as they are.

const numbers = (snapshotText) => {
  let s = null;
  try { s = JSON.parse(snapshotText || 'null'); } catch { s = null; }
  return {
    agility: Number(s?.abilities?.agility?.number) || 0,
    talents: (s?.talents || []).map((t) => (typeof t === 'string' ? t : t?.id)).filter(Boolean),
  };
};

// The heroes a player may seat, each with `init`.
export async function seatStats(env, campaignId, chars) {
  if (!chars.length) return chars;
  const { results } = await env.DB_MARVEL.prepare(
    `SELECT id, snapshot FROM msh_heroes WHERE id IN (${chars.map(() => '?').join(', ')})`
  ).bind(...chars.map((c) => String(c.id))).all();
  const by = new Map(results.map((r) => [String(r.id), numbers(r.snapshot)]));
  return chars.map((c) => ({ ...c, init: by.get(String(c.id)) ?? { agility: 0, talents: [] } }));
}

// Everyone the GM may add to initiative: the campaign's heroes and the NPC
// sheets the GM has rolled for it (the list GM Tools offers today).
export async function roster(env, campaignId) {
  const heroes = (await env.DB_MARVEL.prepare(
    `SELECT h.id, h.name, h.snapshot FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
     WHERE ch.campaign_id = ? ORDER BY h.name`
  ).bind(campaignId).all()).results;
  const npcs = (await env.DB_MARVEL.prepare(
    'SELECT id, name, snapshot FROM msh_npc_sheets WHERE campaign_id = ? ORDER BY name'
  ).bind(campaignId).all()).results;
  return [
    ...heroes.map((h) => ({ kind: 'pc', ref: String(h.id), name: h.name, init: numbers(h.snapshot) })),
    ...npcs.map((n) => ({ kind: 'npc', ref: String(n.id), name: n.name, init: numbers(n.snapshot) })),
  ];
}

// ---------- pictures on the table (phase 2) ----------
//
// A setting page's picture, looked up INSIDE the table's campaign, so a ref
// naming another campaign's picture is not found. Marvel has no city maps.
// Whether the caller may have it at all is the room's question, asked by the
// shared route before this is called.

async function imageRow(env, campaignId, ref) {
  if (ref.kind !== 'image') return null;
  return env.DB_MARVEL.prepare('SELECT id, r2_key, content_type, caption FROM msh_campaign_images WHERE id = ? AND campaign_id = ?')
    .bind(Number(ref.id), campaignId).first();
}

// A picture's own caption and nothing else: the page it sits on is titled for
// the GM, and its title may give a plot away.
export async function describe(env, campaignId, ref) {
  const row = await imageRow(env, campaignId, ref);
  return row ? { caption: row.caption || '' } : null;
}

export async function image(env, campaignId, ref) {
  const row = await imageRow(env, campaignId, ref);
  if (!row) return null;
  if (!env.MEDIA) return { error: 'Image storage is not configured on this environment', status: 501 };
  const object = await env.MEDIA.get(row.r2_key);
  if (!object) return { error: 'Image is recorded but missing from storage', status: 502 };
  return { body: object.body, contentType: object.httpMetadata?.contentType || row.content_type };
}
