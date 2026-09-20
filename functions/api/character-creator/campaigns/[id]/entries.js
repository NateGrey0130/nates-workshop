// GET  /api/character-creator/campaigns/:id/entries — the GM's own pages.
//      ?kind= filters to one of place | faction | lore | handout | prep.
// POST /api/character-creator/campaigns/:id/entries — write one.
//      { title, kind?, body? }
//
// GM ONLY, BOTH VERBS, and that is the point rather than a precaution: an entry
// is the GM's notebook. What a player can ever see from this feature is an
// IMAGE that has been revealed, and its caption - never a title, never a body.
// So there is no `forViewer` shape here as npcs.js has: a non-GM gets 403 and
// no row at all.
//
// Migration 078. The pictures hang off these pages (entries/:entryId/images)
// or off nothing at all, which is the handout dropped in ten minutes before a
// session.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

export const KINDS = ['place', 'faction', 'lore', 'handout', 'prep'];

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false, gm: true });
  if (guard.res) return guard.res;

  const url = new URL(request.url);
  const where = ['e.campaign_id = ?'];
  const binds = [params.id];
  const kind = url.searchParams.get('kind');
  if (kind && KINDS.includes(kind)) { where.push('e.kind = ?'); binds.push(kind); }
  const q = url.searchParams.get('q');
  // LIKE over the two text columns, for npcs.js's reason: a campaign's pages
  // are tens of rows, and an FTS index is machinery for a list that fits on a
  // screen. The journal has one because it grows every session.
  if (q) { where.push('(e.title LIKE ? OR e.body LIKE ?)'); binds.push(`%${q}%`, `%${q}%`); }
  const clause = where.join(' AND ');
  const { limit, offset } = paging(request);

  // The image counts ride along because they are what the list is FOR: a page
  // with three pictures none of which the party has seen reads differently
  // from one you showed them last week.
  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM campaign_entries e WHERE ${clause}`,
    countBinds: binds,
    rowsSql: `SELECT e.*,
                (SELECT count(*) FROM campaign_images i WHERE i.entry_id = e.id) AS image_count,
                (SELECT count(*) FROM campaign_images i WHERE i.entry_id = e.id
                   AND i.revealed_at IS NOT NULL) AS revealed_count
              FROM campaign_entries e WHERE ${clause}
              ORDER BY e.updated_at DESC`,
    rowsBinds: binds,
    limit, offset,
  });
  return json(pageBody('entries', page));
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const title = typeof b.title === 'string' ? b.title.trim() : '';
  if (!title) return json({ error: 'title is required' }, 400);
  if (title.length > 200) return json({ error: 'title is too long' }, 400);
  const kind = b.kind ?? 'lore';
  if (!KINDS.includes(kind)) {
    return json({ error: `kind must be one of ${KINDS.join(', ')}` }, 400);
  }

  const row = await env.DB.prepare(
    `INSERT INTO campaign_entries (campaign_id, kind, title, body, created_by)
     VALUES (?, ?, ?, ?, ?) RETURNING *`
  ).bind(params.id, kind, title, b.body ?? null, guard.email).first();
  return json({ entry: row }, 201);
}
