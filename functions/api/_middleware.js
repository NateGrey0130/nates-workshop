// Defence-in-depth on every /api/* route — the audit's F4.
//
// The identity the whole site runs on is a header Access injects, and the
// guarantee that nobody else can inject it is entirely Access's. This
// middleware adds the second check Cloudflare recommends: verify the
// Cf-Access-Jwt-Assertion token against the team's published signing keys,
// and require its email claim to match the header everything downstream
// reads.
//
// OPT-IN, and pass-through until both variables are set. With no
// ACCESS_TEAM_DOMAIN / ACCESS_AUD configured this returns next() immediately
// — the original posture, byte for byte — which is what makes it safe to
// deploy ahead of the dashboard configuration, and what keeps local dev
// (which has no Access and no JWT) exactly as it was.
//
// Sits at functions/api/ rather than functions/ on purpose: the API is where
// the data is. Static pages carry none, and a site-wide middleware would bill
// a function invocation for every asset request.

import { verifyAccessJwt, fetchAccessKeys } from './_lib/access-jwt.js';

const refuse = (status, error) => new Response(JSON.stringify({ error }), {
  status, headers: { 'Content-Type': 'application/json' },
});

// Routes that sit outside the login wall ON PURPOSE, and the only ones.
//
// Pick 3 Cut 5 is a party game played by whoever is in the room. Requiring an
// Access account to join would end the party, so its two routes are paired
// with an Access BYPASS policy configured on the dashboard.
//
// The bypass policy alone is not enough, and that is the entire reason this
// list exists: a bypass lets the request through WITHOUT minting a JWT, so
// every such request would reach the check below and take a hard 403. The
// dashboard policy and this array have to agree, or the app is broken in
// exactly one direction and the error says nothing about why.
//
// EXACT paths, not a prefix, and that changed on 2026-09-02. It used to be
// `['/api/pick3cut5/']` matched with startsWith, which let through every path
// beneath it — including the ones no function claims. Pages answers an unrouted
// path with the site's landing page at 200, so
// `GET /api/pick3cut5/anything-at-all` served `index.html` — 7,255 bytes of a
// page that 302s to the login wall at its own URL — to anyone who asked.
//
// Nothing was leaked that matters: the landing page renders app names and
// descriptions out of apps/manifest.json, no data and no API. But it was the
// one place the site's only wall was bypassed by a static fallback rather than
// by a decision, and it would have served whatever that page grew into next.
//
// This list is literal because a Worker cannot read the filesystem to derive
// it. `apps/pick3cut5/test/smoke.mjs` derives it instead — from the function
// files under functions/api/pick3cut5/ — and fails if the two disagree, the
// same shape as the Access-destination check that already lives there. So a new
// route added to that directory fails the suite until it is named here, which
// is the point: adding an entry opens a hole in the site's only wall, and it
// should cost a deliberate line.
const PUBLIC_PATHS = ['/api/pick3cut5/room', '/api/pick3cut5/solo'];

export async function onRequest(context) {
  const { request, env, next } = context;
  const domain = (env.ACCESS_TEAM_DOMAIN || '').trim();
  const aud = (env.ACCESS_AUD || '').trim();
  if (!domain || !aud) return next();

  const { pathname } = new URL(request.url);
  // Exact match. A query string is not part of pathname, so the WebSocket
  // upgrade at /api/pick3cut5/room?code=ABCD still matches.
  if (PUBLIC_PATHS.includes(pathname)) return next();

  // The arming variables live in wrangler.jsonc, so `wrangler pages dev`
  // reads them too — and local dev has no Access in front of it to mint a
  // token. The same reality auth.js's dev@localhost fallback answers, answered
  // the same way; a production request can never arrive with this hostname,
  // because Cloudflare routes by Host.
  const host = new URL(request.url).hostname;
  if (host === 'localhost' || host === '127.0.0.1') return next();

  const token = request.headers.get('Cf-Access-Jwt-Assertion');
  if (!token) return refuse(403, 'No Access token on the request');

  let keys;
  try {
    keys = await fetchAccessKeys(domain);
  } catch {
    // Configured but unverifiable is a hard stop with a message naming the
    // fix, not a silent fall-back to trusting the header — falling back would
    // make the verification decorative exactly when it matters.
    return refuse(503, 'Access verification is configured but the signing keys could not be '
      + `fetched from ${domain} - check ACCESS_TEAM_DOMAIN`);
  }

  const v = await verifyAccessJwt(token, keys, { aud });
  if (!v.ok) return refuse(403, 'Access token rejected: ' + v.reason);

  // The token and the header must agree about who this is: the header is what
  // every endpoint reads, so a mismatch means the identity story is broken
  // somewhere and nothing should proceed on it.
  const header = request.headers.get('Cf-Access-Authenticated-User-Email');
  if (header && header.trim().toLowerCase() !== v.email.toLowerCase()) {
    return refuse(403, 'Access token identity does not match the identity header');
  }

  return next();
}
