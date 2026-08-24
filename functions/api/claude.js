// Cloudflare Pages Function — proxies requests to the Anthropic API for
// browser code. Your API key is stored as a Cloudflare environment secret,
// never exposed to the browser.
//
// The actual call and its guardrails live in _lib/claude-client.js so that
// server-side callers can reuse them without going back out through this HTTP
// route (which Cloudflare Access would intercept).

import { validateClaudeRequest, callAnthropic, recordUsage } from './_lib/claude-client.js';
import { getAccessEmail } from './_lib/access.js';

const json = (body, status) => new Response(JSON.stringify(body), {
  status,
  headers: { 'Content-Type': 'application/json' },
});

export async function onRequestPost(context) {
  const { request, env } = context;

  if (!env.ANTHROPIC_API_KEY) {
    return json({ error: 'API key not configured on server' }, 500);
  }

  try {
    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'Invalid JSON body' }, 400);
    }

    const invalid = validateClaudeRequest(body);
    if (invalid) return json({ error: invalid }, 400);

    const upstream = await callAnthropic(body, env);
    // Who spent the key, recorded fail-open — the response below is what the
    // caller gets whether or not the row lands. See recordUsage.
    await recordUsage(env, {
      email: getAccessEmail(request), endpoint: 'proxy', model: body.model, upstream,
    });
    return new Response(upstream.text, { status: upstream.status, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return json({ error: 'Proxy error: ' + err.message }, 500);
  }
}
