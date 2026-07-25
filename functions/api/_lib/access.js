// Cloudflare Access identity, shared by every API function.
//
// Access fronts the whole site, so an authenticated request always carries the
// verified email in this header. This is the single place it gets read —
// apps layer their own authorization on top (see
// functions/api/character-creator/_lib/auth.js for owner/GM rules).

export function getAccessEmail(request) {
  return request.headers.get('Cf-Access-Authenticated-User-Email');
}
