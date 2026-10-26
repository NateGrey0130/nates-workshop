// The single place that talks to the Anthropic API, with the request guardrails.
//
// Two callers share this: functions/api/claude.js exposes it over HTTP for
// browser code, and server-side callers (the class import) invoke it directly.
// Server-side code must NOT reach the HTTP route by fetching the site's own
// URL — in production Cloudflare Access fronts the whole site, so a Function
// calling its own /api/claude gets redirected to the Access login page and
// receives HTML instead of JSON.

import { isAdminEmail } from './access.js';

export const ALLOWED_MODELS = [
  'claude-haiku-4-5-20251001',
  'claude-sonnet-5',
  'claude-opus-5',
];

const MAX_TOKENS_CEILING = 16000;
const MAX_DOC_CHARS = 20000000; // ~15MB of base64

function checkBlocks(blocks) {
  if (blocks.length === 0 || blocks.length > 20) return 'content array must have 1-20 blocks';
  for (const b of blocks) {
    if (!b || typeof b !== 'object') return 'Each content block must be an object';
    if (b.type === 'text') {
      if (typeof b.text !== 'string' || !b.text || b.text.length > 100000) {
        return 'Text block needs a non-empty string under 100k chars';
      }
    } else if (b.type === 'document') {
      const src = b.source;
      if (!src || src.type !== 'base64') return 'Document block needs a base64 source';
      if (src.media_type !== 'application/pdf') return 'Only application/pdf documents are supported';
      if (typeof src.data !== 'string' || !src.data || src.data.length > MAX_DOC_CHARS) {
        return 'Document data must be base64 under ~15MB';
      }
    } else {
      return `Unsupported content block type: ${b.type}`;
    }
  }
  return null;
}

// Returns an error string, or null when the request is acceptable.
// Message content is either a plain string or an array of content blocks
// (what document/PDF attachments require).
export function validateClaudeRequest(body) {
  if (!body || typeof body !== 'object') return 'Body must be a JSON object';
  if (!ALLOWED_MODELS.includes(body.model)) return 'Model not allowed';
  if (!Array.isArray(body.messages) || body.messages.length === 0 || body.messages.length > 50) {
    return 'messages must be a non-empty array (max 50)';
  }
  for (const m of body.messages) {
    if (!m || typeof m !== 'object') return 'Each message must be an object';
    if (m.role !== 'user' && m.role !== 'assistant') return 'Message role must be user or assistant';
    if (typeof m.content === 'string') {
      if (!m.content || m.content.length > 100000) {
        return 'Message content must be a non-empty string under 100k chars';
      }
    } else if (Array.isArray(m.content)) {
      const err = checkBlocks(m.content);
      if (err) return err;
    } else {
      return 'Message content must be a string or an array of content blocks';
    }
  }
  if (body.system !== undefined && (typeof body.system !== 'string' || body.system.length > 50000)) {
    return 'system must be a string under 50k chars';
  }
  return null;
}

// What browser code may send through the HTTP route, and nothing else. The
// route forwards a payload built from these keys only, so a field nobody
// checked (`tools`, `thinking`, `metadata`, ...) never reaches Anthropic on the
// shared key. Server callers do not pass through here: they build their own
// request and may send `thinking` deliberately.
const PROXY_FIELDS =['model', 'max_tokens', 'system', 'messages', 'output_config'];
const OUTPUT_EFFORTS = ['low', 'medium', 'high'];

const isPlainObject = (v) => !!v && typeof v === 'object' && !Array.isArray(v);

function checkOutputConfig(oc) {
  if (!isPlainObject(oc)) return 'output_config must be an object';
  for (const k of Object.keys(oc)) {
    if (k !== 'effort' && k !== 'format') return `output_config.${k} is not allowed`;
  }
  if (oc.effort !== undefined && !OUTPUT_EFFORTS.includes(oc.effort)) {
    return 'output_config.effort must be low, medium or high';
  }
  if (oc.format !== undefined) {
    const f = oc.format;
    if (!isPlainObject(f) || f.type !== 'json_schema' || !isPlainObject(f.schema)
      || Object.keys(f).some((k) => k !== 'type' && k !== 'schema')) {
      return 'output_config.format must be { type: "json_schema", schema: <object> }';
    }
  }
  return null;
}

// validateClaudeRequest plus the browser route's own limits: every top-level
// key must be one of PROXY_FIELDS, and output_config must have the one shape
// the city creator sends. Returns an error string naming the field, or null.
export function validateProxyRequest(body) {
  if (!isPlainObject(body)) return 'Body must be a JSON object';
  const extra = Object.keys(body).filter((k) => !PROXY_FIELDS.includes(k));
  if (extra.length) return `Field not allowed: ${extra.join(', ')}`;
  if (body.max_tokens !== undefined && (!Number.isInteger(body.max_tokens) || body.max_tokens < 1)) {
    return 'max_tokens must be a positive integer';
  }
  if (body.output_config !== undefined) {
    const err = checkOutputConfig(body.output_config);
    if (err) return err;
  }
  return validateClaudeRequest(body);
}

// The payload the HTTP route forwards: the allowed fields that are present.
export function proxyPayload(body) {
  const out = {};
  for (const k of PROXY_FIELDS) if (body[k] !== undefined) out[k] = body[k];
  return out;
}

/**
 * Calls the Anthropic Messages API. Assumes the body already passed
 * validateClaudeRequest(). Returns { status, text } — the raw upstream status
 * and body, so the HTTP route can pass them through untouched.
 */
export async function callAnthropic(body, env) {
  const payload = { ...body, max_tokens: Math.min(body.max_tokens || 2000, MAX_TOKENS_CEILING) };
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': env.ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify(payload),
  });
  return { status: res.status, text: await res.text() };
}

// How many model calls one person may make in any rolling 24 hours (Nate,
// 2026-10-12). Calls, not tokens; every status counts, because a refused or
// failed upstream call was still an attempt someone made.
export const CALL_LIMIT = 100;
const CALL_WINDOW_MS = 24 * 60 * 60 * 1000;

// `created_at` is SQLite's datetime('now'): 'YYYY-MM-DD HH:MM:SS', in UTC.
const parseUtc = (s) => Date.parse(String(s).replace(' ', 'T') + 'Z');

/**
 * May this person make a model call now? Returns null when they may, and a
 * ready 429 Response when they may not, carrying `{ error }` (the shape
 * shared/js/api.js reads) with the time the next call frees up, and a
 * Retry-After header in seconds. Every caller asks this before callAnthropic.
 *
 * It counts the person's `claude_usage` rows of the last 24 hours, so it is
 * as exact as that table and no more. A row is written after the upstream
 * answers, which means calls still in flight are not counted: a burst of
 * parallel calls can pass the limit by a few. That is accepted - the limit
 * bounds a person's day, not a single second of it.
 *
 * Not limited: the site admin (isAdminEmail, which is Nate), and a call with
 * no email, which is local dev - Access always supplies one in production, and
 * there is no person to count. Fail-OPEN like the write below: a count that
 * throws, or no `DB` binding, lets the call through rather than taking a model
 * feature down with the meter. A refusal writes no row, or refusals would hold
 * the window shut.
 */
export async function refuseOverCallLimit(env, email) {
  if (!email || isAdminEmail(email, env)) return null;
  let n;
  let freesAt;
  try {
    if (!env?.DB) return null;
    const since = `datetime('now', '-24 hours')`;
    const row = await env.DB.prepare(
      `SELECT count(*) AS n FROM claude_usage WHERE email = ? AND created_at > ${since}`
    ).bind(email).first();
    n = Number(row?.n) || 0;
    if (n < CALL_LIMIT) return null;
    // The row whose ageing out brings the count back under the limit: the
    // oldest one when the count is exactly the limit, a later one when a burst
    // went past it.
    const edge = await env.DB.prepare(
      `SELECT created_at FROM claude_usage WHERE email = ? AND created_at > ${since}
       ORDER BY created_at, id LIMIT 1 OFFSET ?`
    ).bind(email, n - CALL_LIMIT).first();
    freesAt = parseUtc(edge?.created_at) + CALL_WINDOW_MS;
    if (!Number.isFinite(freesAt)) return null;
  } catch {
    return null;   // fail-open: see above
  }
  const seconds = Math.max(1, Math.ceil((freesAt - Date.now()) / 1000));
  const at = new Date(freesAt).toISOString().replace('T', ' ').slice(0, 16);
  const wait = seconds >= 3600
    ? `${Math.floor(seconds / 3600)} h ${Math.floor((seconds % 3600) / 60)} min`
    : `${Math.max(1, Math.ceil(seconds / 60))} min`;
  return new Response(JSON.stringify({
    error: `You have made ${n} Claude calls in the last 24 hours, and the limit is ${CALL_LIMIT}. `
      + `Your next call frees up at ${at} UTC, in about ${wait}.`,
  }), {
    status: 429,
    headers: { 'Content-Type': 'application/json', 'Retry-After': String(seconds) },
  });
}

/**
 * One row in `claude_usage` per model call — who spent the key, on what. The
 * proxy is open to every authenticated friend by design, and until this table
 * nothing recorded a single call (the audit's F3). The table is also what
 * refuseOverCallLimit above counts on the request path, so a row that does not
 * land is a call the limit never sees; query patterns live in SETUP.md.
 *
 * Fail-open on purpose, and it must stay that way: metering that can break
 * the call it measures — a missing table on an unmigrated environment, a D1
 * hiccup — would be a new failure mode for FilamentForge and MediaVault, whose
 * behaviour this file must not change.
 *
 * `upstream` is callAnthropic's { status, text }; usage and model are read
 * from the response body when it parses (an error body has neither, and the
 * row still records the attempt).
 */
export async function recordUsage(env, { email, endpoint, model, upstream }) {
  try {
    if (!env?.DB) return;
    let usage = null;
    let servedModel = model ?? null;
    try {
      const payload = JSON.parse(upstream?.text ?? '');
      usage = payload?.usage ?? null;
      servedModel = payload?.model ?? servedModel;
    } catch { /* an upstream error body is still a recorded attempt */ }
    // With a cache breakpoint, `usage.input_tokens` counts only the UNCACHED
    // part; the cached span arrives as a write or a read beside it. The row's
    // `input_tokens` is the total the call processed, as the extractor has
    // recorded it since INGESTION-AUDIT F23, and the split is kept because the
    // two bill differently (F35, migration 077). No caller sends a breakpoint
    // today, so both come back absent and are stored NULL.
    const count = (v) => (Number.isFinite(v) ? v : null);
    const cacheWrite = count(usage?.cache_creation_input_tokens);
    const cacheRead = count(usage?.cache_read_input_tokens);
    const fresh = count(usage?.input_tokens);
    await env.DB.prepare(
      `INSERT INTO claude_usage (email, endpoint, model, input_tokens, output_tokens, status,
                                 cache_write_tokens, cache_read_tokens)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
    ).bind(email ?? null, endpoint, servedModel,
      fresh === null ? null : fresh + (cacheWrite ?? 0) + (cacheRead ?? 0),
      count(usage?.output_tokens),
      upstream?.status ?? null, cacheWrite, cacheRead).run();
  } catch { /* see above — never the caller's problem */ }
}
