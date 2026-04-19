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
    const body = await request.json();

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
