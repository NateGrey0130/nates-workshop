// Solo mode's generation call.
//
// A thin proxy, on purpose. Everything that matters - the rate limiters, the
// category validation, the three-step pipeline, the Anthropic key - lives in
// the pick3cut5-room Worker. Two reasons it is arranged that way:
//
//   1. Pages Functions cannot use the rate limit binding. It is the one
//      guardrail this endpoint actually needs and it is only available on the
//      Worker side.
//   2. The generation pipeline already had to live in the Worker for party
//      mode, because the spec puts party generation inside the Durable Object.
//      Duplicating it here would mean two copies of the prompts drifting apart.
//
// Like room.js, this route sits outside the login wall. That makes it the one
// publicly reachable path in the Workshop that can spend the Anthropic key,
// which is why the Worker behind it limits per-IP AND globally.

const json = (body, status = 200) => Response.json(body, { status });

export async function onRequestPost({ request, env }) {
  if (!env.PICK3CUT5) {
    return json({ error: 'Solo mode is not wired up on this deployment.' }, 503);
  }

  // Forwarded explicitly rather than relied upon. The Worker keys its per-IP
  // bucket off this header, and a limiter that silently degrades to keying
  // every request the same is worse than no limiter, because it looks like it
  // is working.
  const headers = new Headers({ 'Content-Type': 'application/json' });
  const ip = request.headers.get('CF-Connecting-IP');
  if (ip) headers.set('CF-Connecting-IP', ip);

  return env.PICK3CUT5.fetch('https://pick3cut5/solo/generate', {
    method: 'POST',
    headers,
    body: await request.text(),
  });
}
