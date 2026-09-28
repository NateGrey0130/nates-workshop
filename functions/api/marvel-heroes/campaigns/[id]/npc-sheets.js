// /api/marvel-heroes/campaigns/:id/npc-sheets - the campaign's statted NPCs.
//
//   GET                -> { npcs }: the GM gets every one; anyone else only those
//                         the GM has shown (hidden = 0). Each has its snapshot and
//                         sheet, so the page draws it with js/sheet.js.
//   PATCH ?id=<id>     -> GM only: { hidden?, name? }.
//   DELETE ?id=<id>    -> GM only. A People dossier backed by it keeps its page
//                         and loses the link (ON DELETE SET NULL).
// Rolled by POST npcs/generate.

import { requireCampaign, json, readJson } from '../../_lib/campaigns.js';

const ROW_ID = /^[1-9]\d{0,11}$/;
const parse = (s) => { try { return JSON.parse(s); } catch { return {}; } };

export async function onRequestGet({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id);
  if (g.res) return g.res;
  const { results } = await env.DB_MARVEL.prepare(`SELECT id, name, snapshot, sheet, hidden, created_at FROM msh_npc_sheets
    WHERE campaign_id = ? AND (? = 1 OR hidden = 0) ORDER BY name`).bind(g.campaign.id, g.isGm ? 1 : 0).all();
  return json({ npcs: results.map((r) => ({ ...r, snapshot: parse(r.snapshot), sheet: parse(r.sheet) })) });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const id = new URL(request.url).searchParams.get('id');
  if (!id || !ROW_ID.test(id)) return json({ error: 'not an NPC id' }, 400);
  const body = await readJson(request);
  const sets = [], binds = [];
  if (body && 'hidden' in body) { sets.push('hidden = ?'); binds.push(body.hidden ? 1 : 0); }
  if (body && typeof body.name === 'string' && body.name.trim()) { sets.push('name = ?'); binds.push(body.name.trim().slice(0, 80)); }
  if (!sets.length) return json({ error: 'hidden and name are the editable fields' }, 400);
  const res = await env.DB_MARVEL.prepare(`UPDATE msh_npc_sheets SET ${sets.join(', ')}, updated_at = datetime('now')
    WHERE id = ? AND campaign_id = ?`).bind(...binds, Number(id), g.campaign.id).run();
  return res.meta?.changes ? json({ ok: true }) : json({ error: 'no such NPC' }, 404);
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const id = new URL(request.url).searchParams.get('id');
  if (!id || !ROW_ID.test(id)) return json({ error: 'not an NPC id' }, 400);
  const res = await env.DB_MARVEL.prepare('DELETE FROM msh_npc_sheets WHERE id = ? AND campaign_id = ?')
    .bind(Number(id), g.campaign.id).run();
  return res.meta?.changes ? json({ ok: true }) : json({ error: 'no such NPC' }, 404);
}
