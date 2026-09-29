// GET /api/table/lookup?code= -> { game, status }: which game a table code
// belongs to, so the table page knows whether to ask Palladium's routes or
// Marvel's who this person is there.
//
// Behind Access like every other /api/ route. It says only the game; the
// campaign, the people and the rolls are for that game's own routes to hand
// out, after they have checked its D1. Shared, and so it reaches no database.

import { json, roomInfo, validCode } from '../_lib/table-room.js';

export async function onRequestGet({ request, env }) {
  if (!env.TABLE_ROOM) return json({ error: 'The Table is not wired up on this deployment.' }, 503);
  const code = (new URL(request.url).searchParams.get('code') || '').trim().toUpperCase();
  if (!validCode(code)) return json({ error: 'Table codes are four characters, no O, 0, I or 1.' }, 400);
  const info = await roomInfo(env, code);
  if (!info.exists) return json({ error: 'No table with that code.' }, 404);
  if (info.status !== 'open') return json({ error: 'That table has closed.' }, 410);
  return json({ game: info.game, status: info.status });
}
