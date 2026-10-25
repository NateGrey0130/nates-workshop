// /api/marvel-heroes/transfer - hand one of your own heroes to another player.
//
//   GET                         -> { candidates }: who a character can go to, the
//                                  Access allowlist's mirror minus the caller. An
//                                  unset list answers an empty one.
//   POST { hero_id, to_email }  -> move the hero: the recipient owns it from now
//                                  on, its sheet's notes are cleared, and its
//                                  campaign links stay, so it is still played
//                                  where it was. Instant; nobody is asked.
//
// Only the hero's owner can move it, and only to someone on the list
// (_lib/transfer.js). A hero someone else owns answers as missing, as it does in
// heroes.js. An NPC sheet moves through campaigns/[id]/npc-sheets/transfer.js.

import { owner, json, readJson } from './_lib/campaigns.js';
import { ID, MAX_HEROES } from './_lib/heroes.js';
import { transferCandidates, transferRecipient, clearedSheetSql } from './_lib/transfer.js';

export async function onRequestGet({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  return json({ candidates: transferCandidates(env, email) });
}

export async function onRequestPost({ request, env }) {
  const email = owner(request);
  if (!email) return json({ error: 'not signed in' }, 401);
  const body = await readJson(request);
  if (body === undefined) return json({ error: 'Invalid JSON body' }, 400);
  const heroId = body?.hero_id;
  if (typeof heroId !== 'string' || !ID.test(heroId)) return json({ error: 'not a hero id' }, 400);
  const to = transferRecipient(env, email, body.to_email);
  if (to.error) return json({ error: to.error }, to.status);
  const db = env.DB_MARVEL;
  const hero = await db.prepare('SELECT id, name FROM msh_heroes WHERE id = ? AND owner_email = ?').bind(heroId, email).first();
  if (!hero) return json({ error: 'no such hero' }, 404);
  // The owner and the recipient's room are guarded in the UPDATE itself, so a
  // second request racing this one cannot move the hero twice or overfill a list.
  const res = await db.prepare(`UPDATE msh_heroes SET owner_email = ?, sheet = ${clearedSheetSql('sheet')}, updated_at = datetime('now')
    WHERE id = ? AND owner_email = ? AND (SELECT COUNT(*) FROM msh_heroes WHERE owner_email = ?) < ?`)
    .bind(to.email, heroId, email, to.email, MAX_HEROES).run();
  if (!res.meta?.changes) {
    const still = await db.prepare('SELECT 1 FROM msh_heroes WHERE id = ? AND owner_email = ?').bind(heroId, email).first();
    return still ? json({ error: `${to.email} has ${MAX_HEROES} heroes saved, which is the most there is room for` }, 409)
      : json({ error: 'no such hero' }, 404);
  }
  return json({ ok: true, hero: { id: hero.id, name: hero.name }, to_email: to.email });
}
