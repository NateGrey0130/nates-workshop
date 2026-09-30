// The Sourcebooks page, one per system: apps/sourcebooks/palladium/ and
// apps/sourcebooks/marvel/. Each page is only its own look (its system's
// stylesheet) and a <main data-sourcebooks>; this script fills it from the
// books.json beside the page, which scripts/sourcebooks.mjs builds from the
// surveys and registries. Nothing on the page is typed by hand.

const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const n = (x) => Number(x).toLocaleString('en-US');
const STATUS = {
  imported: 'Imported',
  backfilled: 'Backfilled: its rows arrived before surveys existed, and were given their pages later',
};

// One row per book: the summary line is the title, its status and its total,
// and a click opens the book to show what it added. <details> does the
// opening, so the list works from the keyboard with no script of its own.
function card(b, unit) {
  const added = b.added.map(([what, count]) => `<tr><th scope="row">${esc(what)}</th><td class="sb-count">${n(count)}</td></tr>`).join('');
  return `<details class="sb-book">
    <summary class="sb-row">
      <span class="sb-title">${esc(b.title)}</span>
      <span class="sb-status sb-${esc(b.status)}" title="${esc(STATUS[b.status] || b.status)}">${esc(b.status)}</span>
      <span class="sb-total"><span class="sb-count">${n(b.total)}</span> ${esc(unit)}</span>
    </summary>
    <div class="sb-body">
      <p class="sb-meta"><span class="sb-code">${esc(b.code)}</span>
        ${b.date ? `<span class="sb-date">status recorded ${esc(b.date)}</span>` : ''}</p>
      <p class="sb-status-note">${esc(STATUS[b.status] || b.status)}</p>
      ${added ? `<table class="sb-added"><caption>What it added</caption><tbody>${added}</tbody></table>` : '<p class="sb-none">Nothing counted yet.</p>'}
    </div>
  </details>`;
}

async function main() {
  const root = document.querySelector('[data-sourcebooks]');
  try {
    const res = await fetch('books.json', { credentials: 'same-origin' });
    if (!res.ok) throw new Error(`books.json answered ${res.status}`);
    const list = await res.json();
    const total = list.books.reduce((s, b) => s + b.total, 0);
    root.innerHTML = `<p class="sb-summary">${esc(list.about)}</p>
      <p class="sb-count-line"><strong>${list.books.length}</strong> books, <strong>${n(total)}</strong> ${esc(list.unit)} in all.</p>
      <div class="sb-list">${list.books.map((b) => card(b, list.unit)).join('')}</div>`;
  } catch (e) {
    root.innerHTML = `<p class="sb-error" role="alert">The list could not load: ${esc(e.message)}</p>`;
  }
}

main();
