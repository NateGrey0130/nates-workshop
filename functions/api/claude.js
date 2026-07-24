// Cloudflare Pages Function — proxies requests to Anthropic API
// Your API key is stored as a Cloudflare environment secret, never exposed to the browser.

export async function onRequestPost(context) {
  const { request, env } = context;
  const ANTHROPIC_API_KEY = env.ANTHROPIC_API_KEY;

  if (!ANTHROPIC_API_KEY) {
    return new Response(JSON.stringify({ error: 'API key not configured on server' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  try {
    let body;
    try {
      body = await request.json();
    } catch {
      return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Basic guardrails — only allow specific models & cap tokens
    const allowedModels = [
      'claude-sonnet-4-20250514',
      'claude-haiku-4-5-20251001',
    ];

    if (!allowedModels.includes(body.model)) {
      return new Response(JSON.stringify({ error: 'Model not allowed' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Request-shape validation: messages must be a non-empty array of
    // { role, content } with sane sizes; system, if present, a string.
    const badRequest = (msg) => new Response(JSON.stringify({ error: msg }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });

    if (!Array.isArray(body.messages) || body.messages.length === 0 || body.messages.length > 50) {
      return badRequest('messages must be a non-empty array (max 50)');
    }
    for (const m of body.messages) {
      if (!m || typeof m !== 'object') return badRequest('Each message must be an object');
      if (m.role !== 'user' && m.role !== 'assistant') return badRequest('Message role must be user or assistant');
      if (typeof m.content !== 'string' || !m.content || m.content.length > 100000) {
        return badRequest('Message content must be a non-empty string under 100k chars');
      }
    }
    if (body.system !== undefined && (typeof body.system !== 'string' || body.system.length > 50000)) {
      return badRequest('system must be a string under 50k chars');
    }

    body.max_tokens = Math.min(body.max_tokens || 2000, 4000);

    const anthropicRes = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
    });

    const data = await anthropicRes.text();

    return new Response(data, {
      status: anthropicRes.status,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: 'Proxy error: ' + err.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
