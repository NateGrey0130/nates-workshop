// POST /api/client-error - one browser error, written to the log as one line.
//
// shared/js/client-errors.js sends here. The report goes to console.error and
// nowhere else: Pages Functions' real-time logs (`wrangler pages deployment
// tail`, or the dashboard's Functions log stream) are where it is read. It is
// not written to D1, on purpose - an error log is not data anyone queries
// later, and a table for it would grow with every bug.
//
// Behind the Access wall like every /api/* route, so the email on the line is
// the person who saw the error.
//
// RATE LIMIT: an in-memory map per isolate, not a global count. Cloudflare
// runs many isolates and recycles them, so a determined sender gets
// RATE_LIMIT reports per window from EACH isolate it lands on, and a recycle
// resets the count. That is acceptable for its job, which is to keep one
// looping page from filling the log; the client already stops at five a page
// load. It is not a security boundary, and nothing here costs money per call
// beyond the invocation itself.
//
// Every field is capped here as well as in the client, because a browser is
// not obliged to run the client.

import { getAccessEmail } from './_lib/access.js';

export const RATE_LIMIT = 20;
const RATE_WINDOW_MS = 60_000;
export const MAX_BODY = 8192;
export const CAPS = { message: 500, source: 500, stack: 2048, page: 500, ua: 300, email: 200 };
const MAX_TRACKED = 1000;

const counts = new Map();

// Exported for the smoke check, which needs a fresh window per case.
export function resetRateLimit() {
  counts.clear();
}

function overLimit(who, now) {
  const entry = counts.get(who);
  if (!entry || now - entry.start >= RATE_WINDOW_MS) {
    // Bounded: an isolate that has seen this many people in a window drops
    // them all rather than growing without limit.
    if (counts.size >= MAX_TRACKED) counts.clear();
    counts.set(who, { start: now, n: 1 });
    return false;
  }
  entry.n += 1;
  return entry.n > RATE_LIMIT;
}

const cut = (value, max) => {
  if (value === undefined || value === null) return '';
  const s = typeof value === 'string' ? value : String(value);
  return s.length > max ? s.slice(0, max) : s;
};

const whole = (value) => {
  const n = Number(value);
  return Number.isFinite(n) && n >= 0 ? Math.min(Math.floor(n), 1e9) : 0;
};

const empty = (status) => new Response(null, { status });

export async function onRequestPost({ request }) {
  const email = cut(getAccessEmail(request) || 'unknown', CAPS.email);
  if (overLimit(email, Date.now())) return empty(429);

  let text;
  try {
    text = await request.text();
  } catch {
    return empty(400);
  }
  if (text.length > MAX_BODY) return empty(413);

  let body;
  try {
    body = JSON.parse(text);
  } catch {
    return empty(400);
  }
  if (!body || typeof body !== 'object' || Array.isArray(body)) return empty(400);

  const line = {
    email,
    message: cut(body.message, CAPS.message),
    source: cut(body.source, CAPS.source),
    line: whole(body.line),
    col: whole(body.col),
    page: cut(body.page, CAPS.page),
    ua: cut(body.ua, CAPS.ua),
    stack: cut(body.stack, CAPS.stack),
  };
  // JSON.stringify escapes the stack's newlines, so this is one log line.
  console.error('client-error ' + JSON.stringify(line));
  return empty(204);
}
