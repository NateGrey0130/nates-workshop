// A Power's full text, from /api/marvel-heroes/power-text. Shared by the Powers
// tab (app.js) and the codex (codex/app.js), so both read a missing row the
// same way.
//
// The text may not be there: a database built from the repo has
// msh_power_text empty, and the endpoint says so with a 404 carrying
// `missing`. Every answer is { ok, body } or { ok: false, missing, status },
// never a throw, and the committed summary is already on screen either way.
// fetchImpl is a parameter so the smoke suite can hand it a stub.

export async function fetchPowerText(code, fetchImpl = globalThis.fetch) {
  try {
    const res = await fetchImpl(`/api/marvel-heroes/power-text?code=${encodeURIComponent(code)}`, { credentials: 'same-origin' });
    const body = await res.json().catch(() => ({}));
    return res.ok ? { ok: true, body } : { ok: false, missing: !!body.missing, status: res.status };
  } catch {
    return { ok: false, missing: false, status: 0 };
  }
}

// One cache per page: a Power's text does not change while it is open.
export function makePowerText(fetchImpl) {
  const cache = new Map();
  return (code) => {
    if (!cache.has(code)) cache.set(code, fetchPowerText(code, fetchImpl));
    return cache.get(code);
  };
}

// What to say when there is no text to show. The summary is the fallback in
// both cases; only the reason differs.
export function missingNote(r) {
  return r.missing
    ? 'The full text is not loaded on this server; the summary above is what the app ships.'
    : 'The full text could not be fetched just now.';
}

const escHtml = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// Book prose arrives as one run of text; break it into paragraphs at the
// sentence boundaries the listings use for their own sub-heads.
export const paragraphs = (s) => escHtml(s).split(/(?<=\.)\s+(?=(?:Power Stunts?|Optional Powers?|Bonus Powers?|The Nemesis|Nemesis|Example|Note)\b)/)
  .map((p) => `<p>${p}</p>`).join('');
