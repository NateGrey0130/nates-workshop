// Solo mode's rate-limit decision, as a function over an env.
//
// Extracted from index.js on 2026-09-02 so it can be tested without a Worker
// runtime, a socket or a real limiter binding - the same move rules.js made out
// of room.js, and for the same reason. This is the guardrail on the one
// publicly reachable path in the Workshop that can spend the Anthropic key, and
// it was the largest piece of untested consequence in this repo
// (HEALTH-AUDIT.md F16).
//
// Nothing here talks to the network. `env.SOLO_LIMIT` and
// `env.SOLO_LIMIT_GLOBAL` are Cloudflare rate-limit bindings, which a test
// supplies as objects with a `limit()` returning `{ success }`.
//
// THE ORDER IS LOAD BEARING. Per-IP is checked first and returns before the
// global bucket is consulted, so a single abusive caller cannot also burn down
// the global budget it is already being refused by. Swapping these would make
// one blocked client count twice.

// The rate limiter key. Hashed so a raw address never becomes a string this
// Worker is holding onto; truncated because collision resistance past 16 hex
// characters buys nothing for a bucket key.
export async function ipKey(ip) {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(`p3c5:${ip}`));
  return [...new Uint8Array(digest)].slice(0, 8).map((b) => b.toString(16).padStart(2, '0')).join('');
}

/**
 * May this solo generation proceed?
 *
 * @returns {null} when it may, or `{ error, status }` when it may not. Null for
 *   the allowed case rather than `{ ok: true }` because the caller's job is to
 *   return early on a refusal, and `if (denied)` reads as what it means.
 */
export async function soloLimitDecision(env, ip) {
  const perIp = await env.SOLO_LIMIT.limit({ key: await ipKey(ip) });
  if (!perIp.success) {
    return { error: 'Slow down a moment, then try again.', status: 429 };
  }

  // A per-IP limit is one botnet away from meaningless, and the failure mode
  // here is money rather than downtime. This is the blast radius cap.
  const global = await env.SOLO_LIMIT_GLOBAL.limit({ key: 'solo' });
  if (!global.success) {
    return { error: 'Solo mode is busy right now. Try again shortly.', status: 429 };
  }

  return null;
}
