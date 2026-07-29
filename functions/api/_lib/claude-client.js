// The single place that talks to the Anthropic API, with the request guardrails.
//
// Two callers share this: functions/api/claude.js exposes it over HTTP for
// browser code, and server-side callers (the class import) invoke it directly.
// Server-side code must NOT reach the HTTP route by fetching the site's own
// URL — in production Cloudflare Access fronts the whole site, so a Function
// calling its own /api/claude gets redirected to the Access login page and
// receives HTML instead of JSON.

export const ALLOWED_MODELS = [
  'claude-sonnet-4-20250514',
  'claude-haiku-4-5-20251001',
  'claude-sonnet-5',
  'claude-opus-5',
];

export const MAX_TOKENS_CEILING = 16000;
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
