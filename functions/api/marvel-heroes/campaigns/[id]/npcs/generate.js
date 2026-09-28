// POST /api/marvel-heroes/campaigns/:id/npcs/generate - roll a statted NPC.
//
// Body: { name, body?, origin?, powers?, ceiling?, dossier? }. GM only.
// Runs the hero generator here, on the server (apps/marvel-heroes/js/npc.js):
// `body` and `origin` are picked instead of rolled, `powers` is an exact count
// (refused with a 422 when no roll reaches it, never padded), and `ceiling` is
// a rank no ability or Power goes above.
//
// Writes an msh_npc_sheets row in the hero shape - build, snapshot, sheet - so
// the sheet renderer draws it as it draws a hero, HIDDEN from players until
// the GM shows it. With `dossier: true` it also writes an msh_npcs row in
// People, backed by that sheet; a name already in People is a 409 before
// anything is written.
//
// The app's data files are read through env.ASSETS rather than imported: an
// import attribute is something the Pages build image cannot parse (the smoke
// suite's "What Pages will compile"), and these are the same files the page
// fetches. -> 201 { npc: { id, name, snapshot, hidden }, dossier_id }.

import { requireCampaign, json, readJson } from '../../../_lib/campaigns.js';
import { makeGenerator } from '../../../../../../apps/marvel-heroes/js/generator.js';
import { rollNpc, parseNpcOptions, NPC_DATA } from '../../../../../../apps/marvel-heroes/js/npc.js';

const NAME_MAX = 80;

async function loadData(env, request) {
  const out = {};
  await Promise.all(NPC_DATA.map(async (n) => {
    const res = await env.ASSETS.fetch(new URL(`/apps/marvel-heroes/data/${n}.json`, request.url));
    if (!res.ok) throw new Error(`data/${n}.json: ${res.status}`);
    out[n] = await res.json();
  }));
  return out;
}

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const name = typeof body?.name === 'string' ? body.name.trim().slice(0, NAME_MAX) : '';
  if (!name) return json({ error: 'An NPC needs a name' }, 400);
  const data = await loadData(env, request);
  const { options, error } = parseNpcOptions(body, data);
  if (error) return json({ error }, 400);
  const db = env.DB_MARVEL;
  const dossier = body.dossier === true;
  if (dossier && await db.prepare('SELECT 1 FROM msh_npcs WHERE campaign_id = ? AND name = ? COLLATE NOCASE')
    .bind(g.campaign.id, name).first()) {
    return json({ error: `People already has someone called ${name}` }, 409);
  }

  const rolled = rollNpc(data, makeGenerator(data), options);
  if (rolled.error) return json({ error: rolled.error }, 422);
  const row = await db.prepare(`INSERT INTO msh_npc_sheets (campaign_id, name, build, snapshot, created_by)
    VALUES (?, ?, ?, ?, ?) RETURNING id, name, hidden`)
    .bind(g.campaign.id, name, JSON.stringify(rolled.build), JSON.stringify(rolled.snapshot), g.email).first();
  let dossierId = null;
  if (dossier) {
    const d = await db.prepare(`INSERT INTO msh_npcs (campaign_id, name, sheet_id, status, created_by)
      VALUES (?, ?, ?, 'unknown', ?) RETURNING id`).bind(g.campaign.id, name, row.id, g.email).first();
    dossierId = d.id;
  }
  return json({ npc: { ...row, snapshot: rolled.snapshot }, dossier_id: dossierId }, 201);
}
