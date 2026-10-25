// POST /api/marvel-heroes/campaigns/:id/npc-sheets/transfer - the GM hands one
// of this campaign's NPC sheets to a player, as a hero of theirs.
//
// Body: { npc_id, to_email }. GM only, and the recipient must be on the list
// (_lib/transfer.js). In ONE db.batch, each statement guarded in its own SQL:
//   1. an msh_heroes row owned by the recipient, from the sheet's build,
//      snapshot and sheet, with its notes cleared and a fresh uuid for an id
//      (as heroes.js makes one);
//   2. an msh_campaign_heroes link to this campaign, so the hero is played
//      here. The hero is new, so the one-open-campaign index cannot refuse it;
//   3. the msh_npc_sheets row deleted. A People dossier backed by it keeps its
//      page and loses the link (ON DELETE SET NULL): the dossier is the GM's.
// If the sheet is gone or the recipient's list is full, statement 1 writes
// nothing and the other two, which require its row, write nothing either.
// -> { ok, hero: { id, name }, to_email }.

import { requireCampaign, json, readJson } from '../../../_lib/campaigns.js';
import { MAX_HEROES } from '../../../_lib/heroes.js';
import { transferRecipient, clearedSheetSql } from '../../../_lib/transfer.js';

const ROW_ID = /^[1-9]\d{0,11}$/;

export async function onRequestPost({ request, env, params }) {
  const g = await requireCampaign(request, env, params.id, { gm: true });
  if (g.res) return g.res;
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const npcId = String(body?.npc_id ?? '');
  if (!ROW_ID.test(npcId)) return json({ error: 'not an NPC id' }, 400);
  const to = transferRecipient(env, g.email, body.to_email);
  if (to.error) return json({ error: to.error }, to.status);
  const db = env.DB_MARVEL;
  const npc = await db.prepare('SELECT id, name FROM msh_npc_sheets WHERE id = ? AND campaign_id = ?').bind(Number(npcId), g.campaign.id).first();
  if (!npc) return json({ error: 'no such NPC' }, 404);
  const { n } = await db.prepare('SELECT COUNT(*) AS n FROM msh_heroes WHERE owner_email = ?').bind(to.email).first();
  if (n >= MAX_HEROES) return json({ error: `${to.email} has ${MAX_HEROES} heroes saved, which is the most there is room for` }, 409);

  const heroId = crypto.randomUUID();
  const made = 'EXISTS (SELECT 1 FROM msh_heroes WHERE id = ?)';
  const results = await db.batch([
    db.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot, sheet)
      SELECT ?, ?, s.name, s.build, s.snapshot, ${clearedSheetSql('s.sheet')} FROM msh_npc_sheets s JOIN msh_campaigns c ON c.id = s.campaign_id
      WHERE s.id = ? AND c.id = ? AND c.gm_email = ? AND (SELECT COUNT(*) FROM msh_heroes WHERE owner_email = ?) < ?`)
      .bind(heroId, to.email, Number(npcId), g.campaign.id, g.email, to.email, MAX_HEROES),
    db.prepare(`INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by)
      SELECT id, ?, open, ? FROM msh_campaigns WHERE id = ? AND ${made}`)
      .bind(heroId, g.email, g.campaign.id, heroId),
    db.prepare(`DELETE FROM msh_npc_sheets WHERE id = ? AND campaign_id = ? AND ${made}`)
      .bind(Number(npcId), g.campaign.id, heroId),
  ]);
  if (!results[0].meta?.changes) return json({ error: 'The NPC or the campaign changed; nothing was moved' }, 409);
  return json({ ok: true, hero: { id: heroId, name: npc.name }, to_email: to.email });
}
