// /api/marvel-heroes/journal - a campaign's notes, for the shared notes view
// (shared/js/campaign/notes.js), which calls this path on whichever API base
// its page passes.
//
//   GET  ?campaign_id=<id>  -> { entries, total }, newest first. Members only.
//   POST { campaign_id, body, title?, session_date?, hero_id? } -> 201 { entry, mentioned }.
//        Any member may write; a note about a hero must be about one linked to
//        the campaign. @Name in the body links it to that person's dossier,
//        creating one - and a dossier that could not be written never costs the
//        note, which is the thing being saved.
// A member is the GM, or anyone with a hero in the campaign (_lib/campaigns.js).

import { requireMember, json, readJson, HERO_ID } from './_lib/campaigns.js';
import { parseMentions, resolveMentions } from './_lib/notes.js';

const LIMIT = 200;
const TEXT_MAX = 20000;

export async function onRequestGet({ request, env }) {
  const campaignId = new URL(request.url).searchParams.get('campaign_id');
  const g = await requireMember(request, env, campaignId);
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const { n } = await db.prepare('SELECT count(*) AS n FROM msh_journal_entries WHERE campaign_id = ?').bind(g.campaign.id).first();
  const { results } = await db.prepare(`SELECT * FROM msh_journal_entries WHERE campaign_id = ?
    ORDER BY created_at DESC, id DESC LIMIT ?`).bind(g.campaign.id, LIMIT).all();
  return json({ entries: results, total: n });
}

export async function onRequestPost({ request, env }) {
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const g = await requireMember(request, env, b.campaign_id);
  if (g.res) return g.res;
  const body = typeof b.body === 'string' ? b.body.trim() : '';
  if (!body) return json({ error: 'body is required' }, 400);
  if (body.length > TEXT_MAX) return json({ error: 'That note is too long' }, 400);
  const db = env.DB_MARVEL;
  let heroId = null;
  if (b.hero_id != null) {
    if (typeof b.hero_id !== 'string' || !HERO_ID.test(b.hero_id)
      || !await db.prepare('SELECT 1 FROM msh_campaign_heroes WHERE campaign_id = ? AND hero_id = ?').bind(g.campaign.id, b.hero_id).first()) {
      return json({ error: 'That hero is not in this campaign' }, 400);
    }
    heroId = b.hero_id;
  }
  const text = (v, max) => (typeof v === 'string' && v.trim() ? v.trim().slice(0, max) : null);
  const row = await db.prepare(`INSERT INTO msh_journal_entries (campaign_id, hero_id, author_email, title, body, session_date)
    VALUES (?, ?, ?, ?, ?, ?) RETURNING *`)
    .bind(g.campaign.id, heroId, g.email, text(b.title, 200), body, text(b.session_date, 40)).first();
  let mentioned = [];
  try {
    const names = parseMentions(body);
    if (names.length) {
      mentioned = [...(await resolveMentions(db, { campaignId: g.campaign.id, names, email: g.email })).values()];
      await db.batch(mentioned.map((npcId) => db.prepare(`INSERT OR IGNORE INTO msh_npc_mentions (npc_id, journal_entry_id, source)
        VALUES (?, ?, 'mention')`).bind(npcId, row.id)));
    }
  } catch { /* see the header */ }
  return json({ entry: row, mentioned }, 201);
}
