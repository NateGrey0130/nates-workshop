// GET  /api/character-creator/campaigns/:id/npcs — the roster. Members only.
//      ?status= and ?faction= filter; ?q= narrows by name or alias.
// POST /api/character-creator/campaigns/:id/npcs — create a dossier by hand.
//      { name, aliases?, faction?, disposition?, status?, description? }
//
// Most dossiers are not created here: typing `@Kevik` in a note creates one as
// a side effect, which is the path that actually gets used. This is for the NPC
// somebody wants to write up before the party has met them.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

export const STATUSES = ['alive', 'dead', 'unknown', 'never-met'];

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }

  const url = new URL(request.url);
  const where = ['n.campaign_id = ?'];
  const binds = [params.id];
  const status = url.searchParams.get('status');
  if (status && STATUSES.includes(status)) { where.push('n.status = ?'); binds.push(status); }
  const faction = url.searchParams.get('faction');
  if (faction) { where.push('n.faction = ?'); binds.push(faction); }
  const q = url.searchParams.get('q');
  // LIKE over two columns rather than FTS5: a roster is tens of rows, the
  // aliases live in a JSON array, and a second index would be machinery for a
  // list that fits on a screen.
  if (q) {
    where.push('(n.name LIKE ? OR n.aliases LIKE ?)');
    binds.push(`%${q}%`, `%${q}%`);
  }
  const clause = where.join(' AND ');
  const { limit, offset } = paging(request);

  // The mention count is what makes the roster useful — an NPC named once in
  // passing and one the party has dealt with nine times read differently.
  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM npcs n WHERE ${clause}`,
    countBinds: binds,
    rowsSql: `SELECT n.*, (SELECT count(*) FROM npc_mentions m WHERE m.npc_id = n.id) AS mention_count
              FROM npcs n WHERE ${clause}
              ORDER BY mention_count DESC, n.name`,
    rowsBinds: binds,
    limit, offset,
  });
  for (const row of page.results) row.aliases = parseAliases(row.aliases);
  return json(pageBody('npcs', page));
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const name = typeof b.name === 'string' ? b.name.trim() : '';
  if (!name) return json({ error: 'name is required' }, 400);
  if (name.length > 120) return json({ error: 'name is too long' }, 400);

  const existing = await env.DB.prepare(
    'SELECT id FROM npcs WHERE campaign_id = ? AND name COLLATE NOCASE = ?'
  ).bind(params.id, name).first();
  // A conflict is reported with the id, so the caller can go to the dossier
  // that already exists rather than being told no and left to find it.
  if (existing) {
    return json({ error: `${name} already has a dossier in this campaign`, npc_id: existing.id }, 409);
  }

  const row = await env.DB.prepare(
    `INSERT INTO npcs (campaign_id, name, aliases, faction, disposition, status, description, created_by)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, name, serialiseAliases(b.aliases), trim(b.faction), trim(b.disposition),
         STATUSES.includes(b.status) ? b.status : 'unknown', trim(b.description), guard.email).first();
  row.aliases = parseAliases(row.aliases);
  return json({ npc: row }, 201);
}

export const trim = (v) => (typeof v === 'string' && v.trim() ? v.trim() : null);

// Stored as a JSON array; anything else becomes null rather than a string that
// later reads back as one alias called "["Kev","The Fixer"]".
export function serialiseAliases(v) {
  const list = (Array.isArray(v) ? v : String(v ?? '').split(','))
    .map((x) => String(x).trim()).filter(Boolean).slice(0, 20);
  return list.length ? JSON.stringify(list) : null;
}

export function parseAliases(v) {
  if (!v) return [];
  try { const p = JSON.parse(v); return Array.isArray(p) ? p : []; } catch { return []; }
}
