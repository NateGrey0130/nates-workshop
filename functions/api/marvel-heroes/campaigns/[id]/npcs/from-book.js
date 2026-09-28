// POST /api/marvel-heroes/campaigns/:id/npcs/from-book - add a Notable NPC
// from a sourcebook (the codex's Notable NPCs, data/npcs.json) to a campaign.
//
// Body: { character, version?, block?, name?, dossier? }. GM only. `version`
// is required when the character has more than one (Phoenix), and `block` when
// a version's stat blocks are tiers rather than forms (the Brood's member,
// hunter and queen); js/npc-book.js says which, and a missing one is a 400
// naming what to choose. `name` defaults to the book's.
//
// Writes an msh_npc_sheets row in the hero shape with mode 'book', HIDDEN from
// players until the GM shows it, exactly as the NPC roller does
// (npcs/generate.js), so the roster, initiative and FEATs take it unchanged.
// With `dossier: true` it also writes an msh_npcs row in People, backed by that
// sheet; a name already in People is a 409 before anything is written.
//
// The data files are read through env.ASSETS, for the reason generate.js
// gives. -> 201 { npc: { id, name, snapshot, hidden }, dossier_id }.

import { requireCampaign, json, readJson } from '../../../_lib/campaigns.js';
import { makeBookNpc, NPC_BOOK_DATA } from '../../../../../../apps/marvel-heroes/js/npc-book.js';

const NAME_MAX = 80;
const ID = /^[a-z0-9]+(?:-[a-z0-9]+){0,12}$/;

async function loadData(env, request) {
  const out = {};
  await Promise.all(NPC_BOOK_DATA.map(async (n) => {
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
  const character = typeof body?.character === 'string' ? body.character : '';
  const version = body?.version === undefined || body?.version === null ? undefined : body.version;
  if (!ID.test(character) || (version !== undefined && (typeof version !== 'string' || !ID.test(version)))) {
    return json({ error: 'Name a character from the book' }, 400);
  }
  const block = body?.block === undefined || body?.block === null ? undefined : body.block;
  if (block !== undefined && !(Number.isInteger(block) && block >= 0 && block < 20)) return json({ error: 'Not a stat block' }, 400);

  const data = await loadData(env, request);
  const made = makeBookNpc(data)({ character, version, block });
  if (made.error) return json({ error: made.error }, 400);
  const name = (typeof body.name === 'string' && body.name.trim() ? body.name.trim() : made.name).slice(0, NAME_MAX);

  const db = env.DB_MARVEL;
  const dossier = body.dossier === true;
  if (dossier && await db.prepare('SELECT 1 FROM msh_npcs WHERE campaign_id = ? AND name = ? COLLATE NOCASE')
    .bind(g.campaign.id, name).first()) {
    return json({ error: `People already has someone called ${name}` }, 409);
  }
  const row = await db.prepare(`INSERT INTO msh_npc_sheets (campaign_id, name, build, snapshot, created_by)
    VALUES (?, ?, ?, ?, ?) RETURNING id, name, hidden`)
    .bind(g.campaign.id, name, JSON.stringify(made.build), JSON.stringify(made.snapshot), g.email).first();
  let dossierId = null;
  if (dossier) {
    const d = await db.prepare(`INSERT INTO msh_npcs (campaign_id, name, sheet_id, status, created_by)
      VALUES (?, ?, ?, 'unknown', ?) RETURNING id`).bind(g.campaign.id, name, row.id, g.email).first();
    dossierId = d.id;
  }
  return json({ npc: { ...row, snapshot: made.snapshot }, dossier_id: dossierId }, 201);
}
