// Cloudflare Access identity, shared by every API function.
//
// Access fronts the whole site, so an authenticated request always carries the
// verified email in this header. This is the single place it gets read —
// apps layer their own authorization on top (see
// functions/api/character-creator/_lib/auth.js for owner/GM rules).

export function getAccessEmail(request) {
  return request.headers.get('Cf-Access-Authenticated-User-Email');
}

// Site admin — a single recognized email, set as the ADMIN_EMAIL environment
// variable (Pages dashboard in production, .dev.vars locally). Deliberately
// distinct from the per-campaign owner/GM rules: admin-gated features touch
// global catalogs, which aren't campaign-scoped at all. If ADMIN_EMAIL is
// unset, nobody is admin — it fails closed.
export function isAdminEmail(email, env) {
  const admin = (env?.ADMIN_EMAIL || '').trim().toLowerCase();
  if (!admin || !email) return false;
  return email.trim().toLowerCase() === admin;
}
