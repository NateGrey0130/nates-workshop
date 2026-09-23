// GET  /api/character-creator/npc-library        - the caller's library, as summaries
// POST /api/character-creator/npc-library {character_id}
//      - save a copy of a statted NPC from a campaign the caller runs
//
// The G.M.'s own statted NPCs, belonging to no campaign (migration 079).
// Everything here is the OWNER's: the list is the caller's entries and nobody
// else's, and there is no way to ask for another person's. Creating one
// straight from a roller is the rollers' own `to_library` flag, so each roll
// still runs through exactly one path.

import { getUserEmail, unauthorized, json, readJson } from './_lib/auth.js';
import { characterAccess } from './_lib/auth.js';
import { summary, saveToLibrary } from './_lib/npc-snapshot.js';

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { results } = await env.DB.prepare(
    'SELECT * FROM npc_library WHERE owner_email = ? ORDER BY name COLLATE NOCASE, id'
  ).bind(email).all();
  return json({ entries: (results || []).map(summary) });
}

export async function onRequestPost({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const id = Number(b.character_id);
  if (!Number.isInteger(id) || id < 1) return json({ error: 'character_id is required' }, 400);
  // Only the campaign's G.M. can see a statted NPC at all (isHiddenNpc), so a
  // sheet this caller cannot reach is "not found", whatever the reason.
  const access = await characterAccess(env, id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.isGm) return json({ error: 'Only the campaign\'s G.M. can keep its NPCs' }, 403);
  if (access.character.kind !== 'npc') {
    return json({ error: 'Only a statted NPC can go in the library - not a player\'s character' }, 400);
  }
  const saved = await saveToLibrary(env, id, email, 'campaign');
  return json({ entry: saved }, 201);
}
