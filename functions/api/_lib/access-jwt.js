// Verifying the Cloudflare Access JWT — the audit's F4.
//
// The whole site's identity story rests on the Cf-Access-Authenticated-User-
// Email header, read in exactly one place (access.js) and trusted because
// Access injects it. That guarantee is entirely Access's: if the application
// is ever disabled, mis-scoped after a domain change, or a route exempted,
// every endpoint would be trusting a client-suppliable header with no second
// check. Cloudflare's own defence-in-depth recommendation is validating the
// Cf-Access-Jwt-Assertion token against the team's public keys, and that is
// what this does — used by functions/api/_middleware.js, and OPT-IN: with no
// ACCESS_TEAM_DOMAIN / ACCESS_AUD configured, nothing here runs.
//
// The verification itself is deliberately a pure function of (token, keys,
// options), so the smoke test can sign tokens with WebCrypto and prove every
// refusal path without a network or a real Access team.

const b64uToBytes = (s) => {
  const norm = String(s).replace(/-/g, '+').replace(/_/g, '/');
  const pad = norm.length % 4 ? '='.repeat(4 - (norm.length % 4)) : '';
  const bin = atob(norm + pad);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
};
const b64uToJson = (s) => JSON.parse(new TextDecoder().decode(b64uToBytes(s)));

/**
 * Verify one Access JWT against the team's published keys.
 * Returns { ok: true, email, payload } or { ok: false, reason } — the reason
 * is a sentence, because a 403 that cannot say why teaches nobody anything.
 *
 * Checks, in order: shape, algorithm (RS256 is what Access signs with — an
 * `alg: none` token must die here), a known signing key, the signature
 * itself, the audience (the Access application's AUD tag), expiry with 60s of
 * clock leeway, and that the token carries the email identity the rest of the
 * site runs on.
 */
export async function verifyAccessJwt(token, keys, { aud, now = Math.floor(Date.now() / 1000) } = {}) {
  const parts = String(token || '').split('.');
  if (parts.length !== 3) return { ok: false, reason: 'malformed token' };

  let header, payload;
  try {
    header = b64uToJson(parts[0]);
    payload = b64uToJson(parts[1]);
  } catch {
    return { ok: false, reason: 'undecodable token' };
  }

  if (header.alg !== 'RS256') return { ok: false, reason: `unsupported algorithm ${header.alg}` };

  const jwk = (keys || []).find((k) => k.kid === header.kid);
  if (!jwk) return { ok: false, reason: 'no published signing key matches the token' };

  let key;
  try {
    key = await crypto.subtle.importKey('jwk', jwk,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']);
  } catch {
    return { ok: false, reason: 'unusable signing key' };
  }

  let good = false;
  try {
    good = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key,
      b64uToBytes(parts[2]), new TextEncoder().encode(parts[0] + '.' + parts[1]));
  } catch {
    good = false;
  }
  if (!good) return { ok: false, reason: 'signature does not verify' };

  const auds = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
  if (!aud || !auds.includes(aud)) return { ok: false, reason: 'audience mismatch' };

  if (!Number.isFinite(payload.exp) || payload.exp + 60 < now) return { ok: false, reason: 'token expired' };
  if (Number.isFinite(payload.nbf) && payload.nbf - 60 > now) return { ok: false, reason: 'token not yet valid' };

  const email = typeof payload.email === 'string' && payload.email.trim() ? payload.email.trim() : null;
  if (!email) return { ok: false, reason: 'no email claim' };

  return { ok: true, email, payload };
}

// The team's signing keys, cached per isolate. Access rotates keys rarely, so
// stale-on-failure is the right posture: a JWKS fetch hiccup must not brick
// every API call, and only a cache that has never been filled lets the error
// propagate (the middleware turns that into a 503 that says what to check).
let cache = { domain: null, keys: null, at: 0 };
const KEY_TTL_MS = 6 * 60 * 60 * 1000;

export async function fetchAccessKeys(teamDomain) {
  const domain = String(teamDomain).replace(/^https?:\/\//, '').replace(/\/.*$/, '');
  if (cache.domain === domain && cache.keys && Date.now() - cache.at < KEY_TTL_MS) {
    return cache.keys;
  }
  try {
    const res = await fetch(`https://${domain}/cdn-cgi/access/certs`);
    if (!res.ok) throw new Error(`certs endpoint answered ${res.status}`);
    const body = await res.json();
    const keys = Array.isArray(body?.keys) ? body.keys : [];
    if (!keys.length) throw new Error('certs endpoint returned no keys');
    cache = { domain, keys, at: Date.now() };
    return keys;
  } catch (err) {
    if (cache.domain === domain && cache.keys) return cache.keys;
    throw err;
  }
}
