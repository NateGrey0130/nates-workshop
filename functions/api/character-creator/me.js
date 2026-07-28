// Returns the Zero Trust identity of the caller — the identity every later
// phase uses for character ownership and GM checks.

import { getUserEmail, unauthorized, json, isAdmin } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  return json({ email, is_admin: isAdmin(request, env) });
}
