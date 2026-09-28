// A sourcebook entry's own text, from /api/marvel-heroes/book-text, for the
// codex's Notable NPCs (codex/app.js). The same contract as power-text.js:
// every answer is { ok, body } or { ok: false, missing, status }, never a
// throw, and the committed facts are already on the card either way.
//
// The text may not be there: a database built from the repo has
// msh_book_text empty (migration 087), and the endpoint says so with a 404
// carrying `missing`. fetchImpl is a parameter so the smoke suite can stub it.

export async function fetchBookText(book, entry, fetchImpl = globalThis.fetch) {
  try {
    const res = await fetchImpl(`/api/marvel-heroes/book-text?book=${encodeURIComponent(book)}&entry=${encodeURIComponent(entry)}`,
      { credentials: 'same-origin' });
    const body = await res.json().catch(() => ({}));
    return res.ok ? { ok: true, body } : { ok: false, missing: !!body.missing, status: res.status };
  } catch {
    return { ok: false, missing: false, status: 0 };
  }
}

// One cache per page: an entry's text does not change while it is open.
export function makeBookText(fetchImpl) {
  const cache = new Map();
  return (book, entry) => {
    const k = `${book}:${entry}`;
    if (!cache.has(k)) cache.set(k, fetchBookText(book, entry, fetchImpl));
    return cache.get(k);
  };
}

export function bookMissingNote(r) {
  return r.missing
    ? "The book's text is not loaded on this server; the statistics above are what the app ships."
    : "The book's text could not be fetched just now.";
}

const escHtml = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// How each part reads on the card. A power keeps its printed name as a run-in
// head, as the book sets it.
const PART_HEAD = { talents: 'Talents', contacts: 'Contacts', background: 'Background', notes: 'Notes', running: 'Running the character' };

export function renderParts(parts) {
  return parts.map((p) => {
    if (p.part === 'power' || p.part === 'member') {
      return `<p><strong>${escHtml(p.name || '')}:</strong> ${escHtml(p.body)}</p>`;
    }
    const head = PART_HEAD[p.part];
    return head ? `<p><strong>${head}:</strong> ${escHtml(p.body)}</p>` : `<p>${escHtml(p.body)}</p>`;
  }).join('');
}
