// Pick 3 Cut 5 — the room Worker.
//
// WHY THIS IS A SEPARATE WORKER AT ALL: Cloudflare Pages cannot define a
// Durable Object class. It can only bind to one exported from a standalone
// Worker, and the binding additionally requires `script_name`, which is
// optional everywhere else. That is a current, documented limitation, not a
// legacy one - so the choice is either this file or migrating the entire
// Workshop off Pages. See docs/pages-to-workers-migration.md for the second
// option, written up but not taken.
//
// CONSEQUENCE, and it is the one that will bite: this Worker deploys
// SEPARATELY from the Pages site. `git push` does not ship it. It must be
// deployed BEFORE the Pages deploy that binds it, the same discipline the R2
// bucket note in the root wrangler.jsonc describes. SETUP.md has the order.
//
// `workers_dev` is off. Nothing reaches this Worker except through the two
// bindings the Pages project holds, which is what keeps the room API and the
// generation path off the open internet on their own hostname.

import { Room } from './room.js';
import { runPipeline, validateCategory, normalize, GenerationError, AnthropicError } from './generate.js';
import { soloLimitDecision } from './limits.js';

export { Room };

// No O, 0, I, or 1. Four characters read aloud across a living room, and those
// four are the ones that get misheard and mistyped.
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CODE_LENGTH = 4;

const json = (body, status = 200) => Response.json(body, { status });

function newCode() {
  const bytes = crypto.getRandomValues(new Uint8Array(CODE_LENGTH));
  return [...bytes].map((b) => ALPHABET[b % ALPHABET.length]).join('');
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // ── Create a room ──────────────────────────────────────────────────────
    if (url.pathname === '/room' && request.method === 'POST') {
      // The room code IS the DO name, so a collision would drop two groups of
      // friends into the same game. Probe before claiming.
      for (let attempt = 0; attempt < 6; attempt++) {
        const code = newCode();
        const stub = env.ROOM.get(env.ROOM.idFromName(code));
        const probe = await stub.fetch('https://room/occupied');
        const { occupied } = await probe.json();
        if (occupied) continue;

        const created = await stub.fetch(`https://room/create?code=${code}`);
        if (created.ok) return json({ code });
      }
      return json({ error: 'Could not find a free room code. Try again.' }, 503);
    }

    // ── Join a room (WebSocket) ────────────────────────────────────────────
    if (url.pathname === '/ws') {
      const code = (url.searchParams.get('code') ?? '').toUpperCase();
      if (!/^[A-Z0-9]{4}$/.test(code)) return new Response('Bad room code', { status: 400 });
      if ([...code].some((c) => !ALPHABET.includes(c))) return new Response('Bad room code', { status: 400 });

      const stub = env.ROOM.get(env.ROOM.idFromName(code));
      return stub.fetch(new Request('https://room/ws', request));
    }

    // ── Solo generation ────────────────────────────────────────────────────
    //
    // The one publicly reachable generation path in the whole Workshop, and
    // the only reason this Worker needs a rate limiter at all. Party mode
    // generates inside the DO behind a room code and that object's own 20s
    // cooldown and 30-round cap; this has neither, so it gets its own.
    //
    // Per-IP, not Turnstile: Turnstile would mean a script tag from
    // challenges.cloudflare.com in a repo with zero external dependencies,
    // plus a third secret and a siteverify round trip on the hot path. The
    // native binding is config-only and adds nothing to the client. It is also
    // the reason this endpoint lives HERE rather than in a Pages Function -
    // Pages Functions cannot use the rate limit binding at all.
    // VERIFIED IN PRODUCTION 2026-08-24: 24 requests down one connection gave
    // 9 allowed / 15 denied, matching the configured 8-per-minute.
    //
    // Two things that made it look broken first, worth knowing before anyone
    // re-tests this: sequential HTTPS round-trips to production are slow enough
    // that ~16 of them span more than the 60s window, and PARALLEL requests
    // each open their own connection, spread across colos, where the limiter is
    // eventually consistent and a burst leaks well past the nominal number.
    // It caps a sustained rate; it does not hard-stop a burst.
    if (url.pathname === '/solo/generate' && request.method === 'POST') {
      const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';

      // Both buckets, per-IP first, in limits.js so they can be tested without
      // a Worker runtime. Returns null to proceed, or the refusal to return.
      const denied = await soloLimitDecision(env, ip);
      if (denied) return json({ error: denied.error }, denied.status);

      let body;
      try { body = await request.json(); } catch { return json({ error: 'Bad request' }, 400); }

      const { category, error } = validateCategory(body?.category);
      if (error) return json({ error }, 400);

      // Solo replays exclude what the player already saw. The list is client
      // held, so this arrives from the client and is treated as untrusted
      // input: capped, coerced, and only ever used to make results narrower.
      const exclude = Array.isArray(body?.exclude)
        ? body.exclude.filter((s) => typeof s === 'string').slice(0, 40).map((s) => s.slice(0, 80))
        : [];

      try {
        const { items, reserve } = await runPipeline(env, category, {
          exclude, endpoint: 'pick3cut5-solo', forceVerify: body?.verify === true,
        });
        // Solo hands the client all eight at once, unlike party mode. The
        // hidden-information rule exists so nobody can read the list over
        // another player's shoulder; in solo there is no other player, and the
        // spec asks for local state plus one call. The only person devtools
        // spoils it for is the person who opened them.
        //
        // The reserve rides along for the same reason: solo needs to swap a
        // called-out item without a second round trip, and there is nobody to
        // hide it from.
        return json({ items, reserve, category });
      } catch (err) {
        if (err instanceof GenerationError) {
          return json({ error: err.message, exhausted: Boolean(err.exhausted) }, 422);
        }
        // The upstream detail is logged, never returned: an Anthropic error
        // body can carry the request shape and there is no reason to hand that
        // to an unauthenticated caller. `observability` is on in this Worker's
        // config precisely so this line is findable afterwards.
        if (err instanceof AnthropicError) {
          console.error('pick3cut5 solo generation failed:', err.message);
          return json({ error: 'The list service is having a moment. Try again.' }, 502);
        }
        console.error('pick3cut5 solo generation crashed:', err?.stack ?? err);
        return json({ error: 'Could not build a list.' }, 500);
      }
    }

    return new Response('Not found', { status: 404 });
  },
};

export { normalize };
