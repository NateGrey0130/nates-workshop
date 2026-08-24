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

export async function onRequest(context) {
  const { request, env, next } = context;
  const domain = (env.ACCESS_TEAM_DOMAIN || '').trim();
  const aud = (env.ACCESS_AUD || '').trim();
  if (!domain || !aud) return next();

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
