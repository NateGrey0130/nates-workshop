// Shared by FilamentForge's two endpoints: the identity read and the JSON
// response shape. Identity comes from the site-wide Access helper with the
// same dev@localhost fallback the character creator's auth.js uses — local
// dev (wrangler pages dev) has no Access in front of it to inject the header.

import { getAccessEmail } from '../../_lib/access.js';

export function getUserEmail(request) {
  const email = getAccessEmail(request);
  if (email) return email;
  const host = new URL(request.url).hostname;
  if (host === 'localhost' || host === '127.0.0.1') return 'dev@localhost';
  return null;
}

export function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
