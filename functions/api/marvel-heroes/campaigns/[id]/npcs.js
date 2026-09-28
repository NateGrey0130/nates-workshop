// /api/marvel-heroes/campaigns/:id/npcs - People: everyone the campaign has met.
//
//   GET   -> { npcs }: every dossier, with how many notes mention them, most
//            mentioned first. Members only.
//   POST  { name, aliases?, faction?, disposition?, status?, description? } -> 201
//         { npc }. Any member. A name already in People is a 409 carrying the
//         existing dossier's id.
// Most dossiers are made by @Name in a note (journal.js); this is for writing
// someone up before the party meets them. The NPC roller's dossier is the
// third way in (npcs/generate.js). sheet_id - which statted sheet stands
// behind a person - is the GM's alone and leaves every other response.

import { requireMember, json, readJson } from '../../_lib/campaigns.js';
import { STATUSES, trim, serialiseAliases, dossierFor } from '../../_lib/notes.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const { results } = await env.DB_MARVEL.prepare(`SELECT n.*,
      (SELECT count(*) FROM msh_npc_mentions m WHERE m.npc_id = n.id) AS mention_count
    FROM msh_npcs n WHERE n.campaign_id = ? ORDER BY mention_count DESC, n.name LIMIT 500`).bind(g.campaign.id).all();
  return json({ npcs: results.map((r) => dossierFor(r, g.isGm)), total: results.length });
}

export async function onRequestPost({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const name = typeof b.name === 'string' ? b.name.trim() : '';
  if (!name) return json({ error: 'name is required' }, 400);
  if (name.length > 120) return json({ error: 'name is too long' }, 400);
  const db = env.DB_MARVEL;
  const existing = await db.prepare('SELECT id FROM msh_npcs WHERE campaign_id = ? AND name = ? COLLATE NOCASE')
    .bind(g.campaign.id, name).first();
  if (existing) return json({ error: `${name} already has a dossier in this campaign`, npc_id: existing.id }, 409);
  const row = await db.prepare(`INSERT INTO msh_npcs (campaign_id, name, aliases, faction, disposition, status, description, created_by)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING *`)
    .bind(g.campaign.id, name, serialiseAliases(b.aliases), trim(b.faction), trim(b.disposition),
      STATUSES.includes(b.status) ? b.status : 'unknown', trim(b.description), g.email).first();
  return json({ npc: dossierFor(row, g.isGm) }, 201);
}
