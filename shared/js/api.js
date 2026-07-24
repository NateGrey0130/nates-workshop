// Shared API helpers for all workshop apps

// Calls the server-side Claude proxy (functions/api/claude.js).
// payload: { model, max_tokens, system, messages } per Anthropic Messages API.
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
