// GET  /api/character-creator/campaigns/:id/npcs — the roster. Members only.
//      ?status= and ?faction= filter; ?q= narrows by name or alias.
// POST /api/character-creator/campaigns/:id/npcs — create a dossier by hand.
//      { name, aliases?, faction?, disposition?, status?, description? }
//
// Most dossiers are not created here: typing `@Kevik` in a note creates one as
// a side effect, which is the path that actually gets used. This is for the NPC
// somebody wants to write up before the party has met them.

import { json, readJson, requireCampaign, requireMember, tooLong, TEXT_MAX } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

export const STATUSES = ['alive', 'dead', 'unknown', 'never-met'];

// `character_id` (migration 071) is the G.M.'s statted sheet behind a dossier,
// and a dossier is read by every player in the campaign. The sheet itself is
// already invisible to them (isHiddenNpc), but its id would still say that the
// G.M. has statted this person - which is the thing being kept. So it leaves
// every dossier response for anyone but the G.M.
//
// A sheet deleted since is only marked (migration 091), so the stored id still
// names it and the G.M.'s link would open a 404. While the mark stands the
// response says null; the row keeps the id, so a restore by SQL (Nate,
// 2026-10-12) brings the link back. Every read that hands a dossier to
// forViewer selects SHEET_LIVE beside it (alias `n` for npcs), and a row
// without it gets no link: forgetting the column hides a link rather than
// showing a dead one.
export const SHEET_LIVE = `EXISTS (SELECT 1 FROM characters c
                                   WHERE c.id = n.character_id AND c.deleted_at IS NULL) AS sheet_live`;

export function forViewer(row, isGm) {
  if (!row) return row;
  if (!row.sheet_live) row.character_id = null;
  delete row.sheet_live;
  if (!isGm) delete row.character_id;
  return row;
}

export async function onRequestGet({ request, env, params }) {
  const guard = await requireMember(request, env, params.id);
  if (guard.res) return guard.res;

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
    rowsSql: `SELECT n.*, ${SHEET_LIVE},
                     (SELECT count(*) FROM npc_mentions m WHERE m.npc_id = n.id) AS mention_count
              FROM npcs n WHERE ${clause}
              ORDER BY mention_count DESC, n.name`,
    rowsBinds: binds,
    limit, offset,
  });
  for (const row of page.results) {
    row.aliases = parseAliases(row.aliases);
    forViewer(row, guard.access.isGm);
  }
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
  // The rest at the sizes the PATCH uses (npcs/[npcId].js), before any read
  // or write (auth.js TEXT_MAX).
  const over = tooLong([['The aliases', b.aliases, TEXT_MAX.line], ['The faction', b.faction, TEXT_MAX.line],
    ['The disposition', b.disposition, TEXT_MAX.line], ['The description', b.description, TEXT_MAX.note]]);
  if (over) return over;

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
