// Shared API helpers for all workshop apps

// The model to send when a caller has no reason to pick another. The server's
// copy is DEFAULT_MODEL in functions/api/_lib/claude-client.js, which browser
// code cannot import; smoke fails when the two disagree.
const CLAUDE_DEFAULT_MODEL = 'claude-sonnet-5-5';

// Calls the server-side Claude proxy (functions/api/claude.js).
// payload: { model, max_tokens, system, messages, output_config } only; any other key is a 400.
async function claudeRequest(payload) {
  const res = await fetch('/api/claude', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    const msg = err.error?.message || (typeof err.error === 'string' ? err.error : '') || `API error ${res.status}`;
    throw new Error(msg);
  }
  return res.json();
}
