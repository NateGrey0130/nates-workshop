// Returns the Zero Trust identity of the caller — the identity every later
// phase uses for character ownership and GM checks.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  return json({ email });
}
