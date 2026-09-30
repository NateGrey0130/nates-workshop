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

function card(b) {
  const added = b.added.map(([what, count]) => `<li><span class="sb-count">${n(count)}</span> ${esc(what)}</li>`).join('');
  return `<article class="sb-book">
    <h2 class="sb-title">${esc(b.title)}</h2>
    <p class="sb-meta"><span class="sb-code">${esc(b.code)}</span>
      <span class="sb-status sb-${esc(b.status)}" title="${esc(STATUS[b.status] || b.status)}">${esc(b.status)}</span>
      ${b.date ? `<span class="sb-date">status recorded ${esc(b.date)}</span>` : ''}</p>
    ${added ? `<ul class="sb-added" aria-label="What it added">${added}</ul>` : '<p class="sb-none">Nothing counted yet.</p>'}
  </article>`;
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
      <div class="sb-list">${list.books.map(card).join('')}</div>`;
  } catch (e) {
    root.innerHTML = `<p class="sb-error" role="alert">The list could not load: ${esc(e.message)}</p>`;
  }
}

main();
