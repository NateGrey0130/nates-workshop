// Party mode's entry point: create a room, or join one over a WebSocket.
//
// This route is DELIBERATELY OUTSIDE the site's login wall - see the bypass
// list in functions/api/_middleware.js. Pick 3 Cut 5 is played by whoever is
// in the room, and making friends hold a Cloudflare Access account to join a
// party game would end the party. The room code is the only barrier, which is
// the trade this app is making on purpose.
//
// Two different bindings reach the same Worker, for two different reasons:
//
//   P3C5_ROOM  a Durable Object binding (requires `script_name` on Pages) used
//              for the WebSocket, because handing the upgrade straight to the
//              object's stub is the documented path and keeps a hop out of it.
//   PICK3CUT5  a service binding, used for room creation, because the
//              collision-probe loop lives in the Worker next to the code
//              alphabet rather than being duplicated here.

const json = (body, status = 200) => Response.json(body, { status });

const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

// Create a room. Returns { code }.
export async function onRequestPost({ env }) {
  if (!env.PICK3CUT5) {
    return json({ error: 'Party mode is not wired up on this deployment.' }, 503);
  }
  return env.PICK3CUT5.fetch('https://pick3cut5/room', { method: 'POST' });
}

// Join a room. This is a WebSocket upgrade, not a normal GET.
export async function onRequestGet({ request, env }) {
  if (request.headers.get('Upgrade') !== 'websocket') {
    return json({ error: 'This endpoint expects a WebSocket upgrade.' }, 426);
  }
  if (!env.P3C5_ROOM) {
    return json({ error: 'Party mode is not wired up on this deployment.' }, 503);
  }

  const code = (new URL(request.url).searchParams.get('code') ?? '').toUpperCase();
  // Validated here as well as in the Worker. The room code is the DO name, and
  // a name is created by being asked for - an unvalidated code would let anyone
  // spin up unlimited empty objects by typing garbage.
  if (code.length !== 4 || [...code].some((c) => !ALPHABET.includes(c))) {
    return json({ error: 'Room codes are four characters, no O, 0, I or 1.' }, 400);
  }

  const stub = env.P3C5_ROOM.get(env.P3C5_ROOM.idFromName(code));
  return stub.fetch(new Request('https://room/ws', request));
}
