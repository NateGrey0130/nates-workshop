// ─── STATE ───
let library = []; // loaded from D1 via /api/media-vault/items — the only store
let currentFilter = 'all';
let currentView = 'grid';
let _lookupResultsCache = []; // stores book/TMDB results so onclick can reference by index safely
let detailItemId = null;
let csvData = null;
let selectMode = false;
let selectedIds = new Set();
let isbnPasteRows = [];       // one row per pasted line, after it has been looked up
let isbnPasteRunning = false; // doubles as the cancel flag: the loop checks it each pass
let isbnPasteDuplicates = 0;  // repeats dropped from the paste, reported not swallowed
let currentPage = 1;
const ITEMS_PER_PAGE = 20;

// ─── RENDER ───
// THE SELECTION IS ALWAYS A SUBSET OF WHAT THE VIEW SHOWS. Anything the filter
// or the search stops showing drops out of it at that moment.
//
// Before this, nothing cleaned up after a view change: select all 3,544 items
// under "All", switch to Movies, type a search, and ten items are on screen
// while Delete is still aimed at all 3,544. The confirm names the number, which
// is the only reason this was a hazard rather than an accident waiting to
// happen — and reading "3544" while looking at ten rows invites the assumption
// that it is a typo.
//
// Pruning rather than clearing outright is a deliberate softening of that fix.
// Clearing would be safe too, but resetPageAndRender runs on every KEYSTROKE in
// the search box, so it would throw away a careful selection the moment
// somebody typed a letter. Pruning keeps whatever is still on screen and drops
// only what left, which gets the same guarantee — nothing invisible can be
// acted on — without the punishment.
//
// updateBulkBar has to run whether or not anything was dropped: it also
// recomputes the Select All / Deselect All label, which otherwise goes stale.
// A button reading "Deselect All" that ADDS thirty items to the selection is
// the worst version of this bug, and it was reachable.
function pruneSelectionToView() {
  if (!selectMode) return;
  if (selectedIds.size) {
    const visible = new Set(getFilteredIds());
    for (const id of selectedIds) {
      if (!visible.has(id)) selectedIds.delete(id);
    }
  }
  updateBulkBar();
}

function resetPageAndRender() {
  currentPage = 1;
  pruneSelectionToView();
  renderLibrary();
}

function getFilteredLibrary() {
  const query = document.getElementById('searchInput').value.toLowerCase().trim();
  const searchField = document.getElementById('searchField').value;
  return library.filter(item => {
    if (currentFilter !== 'all' && item.type !== currentFilter) return false;
    if (query) {
      let searchable;
      if (searchField === 'all') {
        searchable = [item.title, item.author, item.genre, item.series, item.location, item.notes].join(' ').toLowerCase();
      } else if (searchField === 'author') {
        searchable = (item.author || '').toLowerCase();
      } else {
        searchable = (item[searchField] || '').toLowerCase();
      }
      return searchable.includes(query);
    }
    return true;
  });
}

// The library as the page actually shows it: filtered, sorted, and cut to the
// current page. renderLibrary and updateBulkBar both read it, so the bar's
// count of what is off-screen can never disagree with what is on screen — the
// two used to be able to, because only renderLibrary knew how to paginate.
//
// It clamps currentPage as a side effect, which renderLibrary relied on before
// and both callers want: deleting the last page's contents has to leave you
// somewhere real.
function getPageView() {
  const [sortKey, sortDir] = document.getElementById('sortSelect').value.split('-');
  const filtered = getFilteredLibrary().sort((a, b) => {
    let va, vb;
    if (sortKey === 'added') {
      va = a.addedAt || 0;
      vb = b.addedAt || 0;
    } else {
      va = (a[sortKey] || '').toLowerCase();
      vb = (b[sortKey] || '').toLowerCase();
    }
    if (va < vb) return sortDir === 'asc' ? -1 : 1;
    if (va > vb) return sortDir === 'asc' ? 1 : -1;
    return 0;
  });
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
  if (totalPages > 0 && currentPage > totalPages) currentPage = totalPages;
  const start = (currentPage - 1) * ITEMS_PER_PAGE;
  return { filtered, totalPages, start, items: filtered.slice(start, start + ITEMS_PER_PAGE) };
}

function renderLibrary() {
  const query = document.getElementById('searchInput').value.toLowerCase().trim();
  const searchField = document.getElementById('searchField').value;

  const { filtered, totalPages, start, items: paginated } = getPageView();

  // Every render refreshes the bar, because the bar now reports something
  // PAGE-dependent: how many of the selection are off-screen. Paging used to
  // leave that number behind — select the twenty on page 1, click page 2, and
  // it still read "20 selected" with all twenty now out of sight. Putting it
  // here covers paging, sorting and the grid/list switch at once, rather than
  // adding a call to each and waiting to miss the next one.
  updateBulkBar();

  // Stats (always off full library) — single pass instead of 6 filters
  const stats = { total: library.length, audiobook: 0, movie: 0, series: 0, physical: 0, digital: 0 };
  for (const i of library) {
    if (i.type === 'audiobook') stats.audiobook++;
    else if (i.type === 'movie') stats.movie++;
    else if (i.type === 'series') stats.series++;
    if (i.format === 'physical') stats.physical++;
    else if (i.format === 'digital') stats.digital++;
  }
  document.getElementById('statTotal').textContent = stats.total;
  document.getElementById('statAudiobooks').textContent = stats.audiobook;
  document.getElementById('statMovies').textContent = stats.movie;
  document.getElementById('statSeries').textContent = stats.series;
  document.getElementById('statPhysical').textContent = stats.physical;
  document.getElementById('statDigital').textContent = stats.digital;

  // Empty state
  const showEmpty = filtered.length === 0;
  document.getElementById('emptyState').style.display = showEmpty ? 'flex' : 'none';
  document.getElementById('pagination').style.display = showEmpty ? 'none' : 'flex';

  if (showEmpty) {
    document.getElementById('libraryGrid').style.display = 'none';
    document.getElementById('libraryList').style.display = 'none';
    return;
  }

  document.getElementById('libraryGrid').style.display = currentView === 'grid' ? 'grid' : 'none';
  document.getElementById('libraryList').style.display = currentView === 'list' ? 'flex' : 'none';

  // Pagination controls
  const fieldLabel = document.getElementById('searchField').options[document.getElementById('searchField').selectedIndex].text;
  const filterLabel = query ? ` matching "${query}"${searchField !== 'all' ? ` in ${fieldLabel}` : ''}` : '';
  document.getElementById('paginationInfo').textContent =
    `Showing ${start + 1}–${Math.min(start + ITEMS_PER_PAGE, filtered.length)} of ${filtered.length}${filterLabel}`;
  renderPaginationButtons(totalPages);

  // Grid
  document.getElementById('libraryGrid').innerHTML = paginated.map((item, i) => `
    <div class="media-card${selectedIds.has(item.id) ? ' selected' : ''}" id="card-${item.id}" onclick="handleCardClick(event, '${item.id}')" style="animation-delay: ${i * 0.03}s">
      <input type="checkbox" class="card-checkbox" id="chk-${item.id}" ${selectedIds.has(item.id) ? 'checked' : ''} onclick="event.stopPropagation(); toggleSelect('${item.id}')">
      <div class="media-card-cover">
        ${item.cover ? `<img src="${item.cover}" alt="${esc(item.title)}" onerror="this.parentElement.innerHTML='<div class=\\'no-cover\\'>${item.type === 'movie' ? '🎬' : '📚'}</div>'">` : `<div class="no-cover">${item.type === 'movie' ? '🎬' : '📚'}</div>`}
        <span class="media-card-type type-${item.type}">${item.type}</span>
      </div>
      <div class="media-card-info">
        <div class="media-card-title">${esc(item.title)}</div>
        <div class="media-card-author">${esc(item.author || '')}</div>
        <div class="media-card-meta">
          ${item.genre ? `<span class="meta-tag">${esc(item.genre.split(',')[0].trim())}</span>` : ''}
          <span class="meta-tag ${item.format}">${item.format}</span>
        </div>
      </div>
    </div>
  `).join('');

  // List
  document.getElementById('listRows').innerHTML = paginated.map((item, i) => `
    <div class="list-row${selectedIds.has(item.id) ? ' selected' : ''}" id="row-${item.id}" onclick="handleCardClick(event, '${item.id}')" style="animation-delay: ${i * 0.02}s">
      <div style="display:flex;align-items:center;justify-content:center;">
        <input type="checkbox" class="row-checkbox" ${selectedIds.has(item.id) ? 'checked' : ''} onclick="event.stopPropagation(); toggleSelect('${item.id}')">
        ${!selectMode ? `<div class="list-row-cover" style="display:flex">
          ${item.cover ? `<img src="${item.cover}" alt="" onerror="this.parentElement.innerHTML='<div class=\\'no-cover\\'>${item.type === 'movie' ? '🎬' : '📚'}</div>'">` : `<div class="no-cover">${item.type === 'movie' ? '🎬' : '📚'}</div>`}
        </div>` : ''}
      </div>
      <div>
        <div class="list-row-title">${esc(item.title)}</div>
        ${item.series ? `<div class="list-row-secondary">${esc(item.series)}</div>` : ''}
      </div>
      <div class="list-row-secondary">${esc(item.author || '')}</div>
      <div class="list-row-secondary">${esc(item.genre || '')}</div>
      <div><span class="meta-tag ${item.format}">${item.format}</span></div>
      <div><span class="meta-tag type-${item.type}" style="font-size:10px;padding:2px 6px;border-radius:3px;">${item.type}</span></div>
      <div class="list-row-secondary">${esc(item.location || '')}</div>
      <div class="list-row-actions">
        <button class="list-action-btn" onclick="event.stopPropagation(); editItem('${item.id}')">✏️</button>
        <button class="list-action-btn delete" onclick="event.stopPropagation(); deleteItem('${item.id}')">🗑</button>
      </div>
    </div>
  `).join('');
}

function renderPaginationButtons(totalPages) {
  const container = document.getElementById('paginationPages');
  if (totalPages <= 1) { container.innerHTML = ''; return; }

  const pages = [];
  // Always show first, last, current, and neighbors
  const show = new Set();
  show.add(1);
  show.add(totalPages);
  for (let p = Math.max(1, currentPage - 2); p <= Math.min(totalPages, currentPage + 2); p++) show.add(p);

  const sorted = [...show].sort((a, b) => a - b);
  let html = '';
  let prev = 0;
  for (const p of sorted) {
    if (p - prev > 1) html += `<button class="page-btn ellipsis">…</button>`;
    html += `<button class="page-btn${p === currentPage ? ' active' : ''}" onclick="goToPage(${p})">${p}</button>`;
    prev = p;
  }
  container.innerHTML = html;
}

function goToPage(p) {
  currentPage = p;
  renderLibrary();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function esc(str) {
  const d = document.createElement('div');
  d.textContent = str;
  return d.innerHTML;
}

// ─── FILTER / VIEW / SORT ───
function setFilter(filter, btn) {
  currentFilter = filter;
  currentPage = 1;
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  pruneSelectionToView();
  renderLibrary();
}

function setView(view) {
  currentView = view;
  document.getElementById('viewGrid').classList.toggle('active', view === 'grid');
  document.getElementById('viewList').classList.toggle('active', view === 'list');
  renderLibrary();
}

function setSortFromHeader(key) {
  const sel = document.getElementById('sortSelect');
  const current = sel.value;
  if (current === `${key}-asc`) sel.value = `${key}-desc`;
  else sel.value = `${key}-asc`;
  renderLibrary();
}

// ─── ADD/EDIT MODAL ───
function openAddModal() {
  document.getElementById('editId').value = '';
  document.getElementById('modalTitle').textContent = 'Add to Vault';
  document.getElementById('btnSave').textContent = 'Add to Vault';
  clearForm();
  document.getElementById('addModal').classList.add('active');
}

function closeAddModal() {
  document.getElementById('addModal').classList.remove('active');
  clearLookupResults();
}

function clearForm() {
  ['itemType', 'itemFormat', 'itemTitle', 'itemAuthor', 'itemActors', 'itemProducers', 'itemGenre', 'itemSeries', 'itemLocation', 'itemCoverInput', 'itemNotes', 'lookupInput', 'coverUrl'].forEach(id => {
    const el = document.getElementById(id);
    if (el.tagName === 'SELECT') el.selectedIndex = 0;
    else el.value = '';
  });
  document.getElementById('lookupStatus').textContent = '';
}

function editItem(id) {
  const item = library.find(i => i.id === id);
  if (!item) return;
  document.getElementById('editId').value = id;
  document.getElementById('modalTitle').textContent = 'Edit Item';
  document.getElementById('btnSave').textContent = 'Save Changes';
  document.getElementById('itemType').value = item.type;
  document.getElementById('itemFormat').value = item.format;
  document.getElementById('itemTitle').value = item.title;
  document.getElementById('itemAuthor').value = item.author || '';
  document.getElementById('itemActors').value = item.actors || '';
  document.getElementById('itemProducers').value = item.producers || '';
  document.getElementById('itemGenre').value = item.genre || '';
  document.getElementById('itemSeries').value = item.series || '';
  document.getElementById('itemLocation').value = item.location || '';
  document.getElementById('itemCoverInput').value = item.cover || '';
  document.getElementById('coverUrl').value = item.cover || '';
  document.getElementById('itemNotes').value = item.notes || '';
  document.getElementById('lookupStatus').textContent = '';
  document.getElementById('addModal').classList.add('active');
}

async function saveItem() {
  const title = document.getElementById('itemTitle').value.trim();
  if (!title) { alert('Title is required'); return; }

  const editId = document.getElementById('editId').value;
  const coverFromInput = document.getElementById('itemCoverInput').value.trim();
  const coverFromLookup = document.getElementById('coverUrl').value.trim();

  const item = {
    id: editId || crypto.randomUUID(),
    type: document.getElementById('itemType').value,
    format: document.getElementById('itemFormat').value,
    title: title,
    author: document.getElementById('itemAuthor').value.trim(),
    actors: document.getElementById('itemActors').value.trim(),
    producers: document.getElementById('itemProducers').value.trim(),
    genre: document.getElementById('itemGenre').value.trim(),
    series: document.getElementById('itemSeries').value.trim(),
    location: document.getElementById('itemLocation').value.trim(),
    cover: coverFromInput || coverFromLookup || '',
    notes: document.getElementById('itemNotes').value.trim(),
    addedAt: editId ? (library.find(i => i.id === editId)?.addedAt || Date.now()) : Date.now(),
  };

  const ok = await apiWrite(() => apiFetch('/api/media-vault/items', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(item),
  }));
  if (!ok) return;

  if (editId) {
    const idx = library.findIndex(i => i.id === editId);
    if (idx >= 0) library[idx] = item;
  } else {
    library.push(item);
  }

  closeAddModal();
  closeDetailModal();
  renderLibrary();
}

async function deleteItem(id) {
  if (!confirm('Delete this item?')) return;
  const ok = await apiWrite(() => apiFetch(`/api/media-vault/items?id=${encodeURIComponent(id)}`, { method: 'DELETE' }));
  if (!ok) return;
  library = library.filter(i => i.id !== id);
  renderLibrary();
}

// ─── DETAIL MODAL ───
function openDetail(id) {
  const item = library.find(i => i.id === id);
  if (!item) return;
  detailItemId = id;

  document.getElementById('detailContent').innerHTML = `
    ${item.cover ? `<img src="${item.cover}" class="detail-cover" alt="${esc(item.title)}" onerror="this.style.display='none'">` : ''}
    <div class="detail-title">${esc(item.title)}</div>
    <div class="detail-author">${esc(item.author || 'Unknown')}</div>
    <div class="detail-fields">
      <div><div class="detail-field-label">Type</div><div class="detail-field-value">${item.type}</div></div>
      <div><div class="detail-field-label">Format</div><div class="detail-field-value">${item.format}</div></div>
      <div><div class="detail-field-label">Genre</div><div class="detail-field-value">${esc(item.genre || '—')}</div></div>
      <div><div class="detail-field-label">Series</div><div class="detail-field-value">${esc(item.series || '—')}</div></div>
      <div><div class="detail-field-label">Location</div><div class="detail-field-value">${esc(item.location || '—')}</div></div>
      <div><div class="detail-field-label">Added</div><div class="detail-field-value">${new Date(item.addedAt).toLocaleDateString()}</div></div>
    </div>
    ${item.notes ? `<div style="font-size:13px;color:var(--text-secondary);line-height:1.6;padding:12px;background:var(--bg-tertiary);border-radius:var(--radius-sm);">${esc(item.notes)}</div>` : ''}
  `;

  document.getElementById('detailModal').classList.add('active');
}

function closeDetailModal() {
  document.getElementById('detailModal').classList.remove('active');
  detailItemId = null;
}

function editFromDetail() {
  if (detailItemId) {
    closeDetailModal();
    editItem(detailItemId);
  }
}

function deleteFromDetail() {
  if (detailItemId) {
    deleteItem(detailItemId);
    closeDetailModal();
  }
}

// ─── BULK EDIT ───
// Every way into and out of select mode goes through here, so the state, the
// body class, the toggle's own label and the bar can never disagree. They did:
// leaving for the Stats page used to turn nothing off, and hiding the bar alone
// would have left the toggle still reading "✕ Cancel" on the way back.
function setSelectMode(on) {
  selectMode = on;
  selectedIds.clear();
  document.body.classList.toggle('select-mode', selectMode);
  const btn = document.getElementById('btnSelectMode');
  btn.classList.toggle('active', selectMode);
  btn.textContent = selectMode ? '✕ Cancel' : '☑ Select';
  updateBulkBar();
}

function toggleSelectMode() {
  setSelectMode(!selectMode);
  renderLibrary();
}

function handleCardClick(event, id) {
  if (selectMode) {
    toggleSelect(id);
  } else {
    openDetail(id);
  }
}

function toggleSelect(id) {
  if (selectedIds.has(id)) {
    selectedIds.delete(id);
  } else {
    selectedIds.add(id);
  }
  // Update card/row visual without full re-render
  const card = document.getElementById('card-' + id);
  const row = document.getElementById('row-' + id);
  const chk = document.getElementById('chk-' + id);
  if (card) card.classList.toggle('selected', selectedIds.has(id));
  if (row) row.classList.toggle('selected', selectedIds.has(id));
  if (chk) chk.checked = selectedIds.has(id);
  updateBulkBar();
}

function bulkSelectAll() {
  const allVisible = getFilteredIds();
  const allSelected = allVisible.every(id => selectedIds.has(id));
  if (allSelected) {
    allVisible.forEach(id => selectedIds.delete(id));
  } else {
    allVisible.forEach(id => selectedIds.add(id));
  }
  updateBulkBar();
  renderLibrary();
}

function getFilteredIds() {
  return getFilteredLibrary().map(i => i.id);
}

// Select All reaches across the WHOLE filter, not the twenty rows on screen —
// which is what was asked for, and was invisible. One click could put 3,544
// items in a selection while twenty were visible, and the only clue was a
// number in a bar that gave no hint the two differed.
//
// So the bar now says both things: how many are selected, and how many of them
// you cannot see. The button names its target as well, because "Select All"
// next to a page of twenty reads like a page of twenty.
function updateBulkBar() {
  const bar = document.getElementById('bulkBar');
  const count = selectedIds.size;
  const inFilter = getFilteredIds();
  const onPage = getPageView().items.filter((i) => selectedIds.has(i.id)).length;
  const offPage = count - onPage;

  document.getElementById('bulkCount').textContent = offPage > 0
    ? `${count} selected · ${offPage} not on this page`
    : `${count} selected`;

  bar.classList.toggle('visible', selectMode);
  const allSelected = inFilter.length > 0 && inFilter.every((id) => selectedIds.has(id));
  document.getElementById('bulkSelectAllBtn').textContent =
    allSelected ? `Deselect all ${inFilter.length}` : `Select all ${inFilter.length}`;
}

// Retyping a selection and reformatting one are the same operation with a
// different word in them, so they are one function. Generalising it is safe
// because the SERVER decides what is settable: items/bulk-update validates both
// the field name and the value against its SETTABLE whitelist, so a caller
// cannot widen what is bulk-editable by handing this a different object. The
// whitelist has allowed `format` since the endpoint was written — this is the
// UI finally offering it.
//
// `ids` is captured before the write rather than read from selectedIds after
// it: the in-memory update must touch exactly the rows the server was asked
// about, even though nothing clears the selection in between today.
async function bulkSet(set, label) {
  if (selectedIds.size === 0) return;
  if (!confirm(`Change ${selectedIds.size} item(s) to ${label}?`)) return;
  const ids = [...selectedIds];
  const ok = await apiWrite(() => apiFetch('/api/media-vault/items/bulk-update', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ids, set }),
  }));
  if (!ok) return;
  const written = new Set(ids);
  library.forEach(item => {
    if (written.has(item.id)) Object.assign(item, set);
  });
  selectedIds.clear();
  updateBulkBar();
  renderLibrary();
}

async function bulkChangeType(newType) {
  const label = newType === 'audiobook' ? 'Audiobooks' : newType === 'series' ? 'Series' : 'Movies';
  return bulkSet({ type: newType }, label);
}

async function bulkChangeFormat(newFormat) {
  return bulkSet({ format: newFormat }, newFormat === 'physical' ? 'Physical' : 'Digital');
}

// Above this many, OK on a confirm() is too cheap a gesture for something with
// no undo. Typing the number is the smallest possible speed bump that proves
// the person read it.
const TYPE_TO_DELETE_ABOVE = 100;

async function bulkDelete() {
  const count = selectedIds.size;
  if (count === 0) return;
  if (count > TYPE_TO_DELETE_ABOVE) {
    const typed = prompt(
      `This permanently deletes ${count} items and cannot be undone.\n\nType ${count} to confirm.`);
    if (typed === null) return;
    if (typed.trim() !== String(count)) {
      alert(`Nothing was deleted — "${typed}" is not ${count}.`);
      return;
    }
  } else if (!confirm(`Permanently delete ${count} item(s)? This cannot be undone.`)) {
    return;
  }
  const ok = await apiWrite(() => apiFetch('/api/media-vault/items/bulk-delete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ids: [...selectedIds] }),
  }));
  if (!ok) return;
  library = library.filter(item => !selectedIds.has(item.id));
  selectedIds.clear();
  updateBulkBar();
  renderLibrary();
}

// ─── LOOKUPS ───
// The client's copies of the four ISBN rules in
// functions/api/media-vault/_lib/common.js, duplicated rather than imported
// because app.js is a plain script with no module loader. The smoke test pins
// every one of them byte-for-byte against that file: change one and it fails
// until you change the other.
//
// The check digit is checked HERE and nowhere else on purpose. A checksum in
// the proxy would refuse numbers OpenLibrary may hold under a mis-keyed record,
// and the reason to know is to tell somebody "you mistyped it" instead of "no
// results found" — which means saying it before the request goes out at all.
function normalizeIsbn(raw) {
  return String(raw || '').replace(/[^0-9Xx]/g, '').toUpperCase();
}

function isIsbnShape(isbn) {
  return /^(?:\d{9}[\dX]|\d{13})$/.test(isbn);
}

function looksLikeIsbn(raw) {
  const body = String(raw || '').replace(/^\s*ISBN[\s:-]*/i, '');
  if (/[A-Za-z]/.test(body.replace(/[Xx]\s*$/, ''))) return false;
  return normalizeIsbn(raw).length >= 9;
}

function isbnCheckDigitValid(isbn) {
  if (/^\d{9}[\dX]$/.test(isbn)) {
    let sum = 0;
    for (let i = 0; i < 9; i++) sum += (10 - i) * Number(isbn[i]);
    sum += isbn[9] === 'X' ? 10 : Number(isbn[9]);
    return sum % 11 === 0;
  }
  if (/^\d{13}$/.test(isbn)) {
    let sum = 0;
    for (let i = 0; i < 13; i++) sum += Number(isbn[i]) * (i % 2 ? 3 : 1);
    return sum % 10 === 0;
  }
  return false;
}

// One ISBN in, one outcome out, with a reason when there isn't a book. Every
// ISBN path goes through here — the ISBN button, Add now, and the pasted list —
// so a mistyped number is described the same way whichever one you used.
async function resolveIsbn(raw) {
  const isbn = normalizeIsbn(raw);
  if (!isbn) return { raw, isbn, ok: false, why: 'empty' };
  if (!isIsbnShape(isbn)) return { raw, isbn, ok: false, why: 'shape' };
  if (!isbnCheckDigitValid(isbn)) return { raw, isbn, ok: false, why: 'checkdigit' };
  const data = await apiFetch(`/api/media-vault/lookup?mode=isbn&isbn=${encodeURIComponent(isbn)}`);
  if (!data.found) return { raw, isbn, ok: false, why: 'notfound' };
  return { raw, isbn, ok: true, book: data.book };
}

// The failures need different sentences, which is the whole point: before this,
// a typo and a book OpenLibrary has never heard of both came back as "No
// results found for that ISBN", and the user had no way to tell which problem
// they had.
//
// The empty-handed case is worded carefully, and the hedge is not padding. It
// was written as "OpenLibrary has no record of it" and that turned out to be a
// claim this code cannot support: OpenLibrary was measured mid-wobble during
// this change returning nothing for `043935806X`, a book it certainly holds,
// while 2 requests in 12 failed outright and one took 8.5 seconds. Asserting
// the catalogue is missing a book when the API merely had a bad second is a
// more confident lie than the vague message it replaced.
function isbnFailureText(r) {
  if (r.why === 'shape') {
    return `That is ${r.isbn.length} character${r.isbn.length === 1 ? '' : 's'} — an ISBN is 10 or 13.`;
  }
  if (r.why === 'checkdigit') {
    return `The check digit in ${r.isbn} doesn’t match — that is almost always a typo. Compare it against the book.`;
  }
  if (r.why === 'error') {
    return `Lookup failed: ${r.error || 'the request did not complete'}. OpenLibrary may be having a moment — try again.`;
  }
  return `${r.isbn} is a well-formed ISBN, but OpenLibrary returned nothing for it. That usually means they do not have it — but their API also does this when it is struggling, so it is worth one retry before you trust it. The 📚 title search is the other way in.`;
}

// A book result as a library item. One definition, so the ISBN box and the
// pasted list cannot drift into storing different things.
function bookToItem(book) {
  return {
    id: crypto.randomUUID(),
    type: 'audiobook',
    format: 'digital',
    title: book.title || '',
    author: book.authors || '',
    actors: '',
    producers: '',
    genre: book.genre || '',
    series: '',
    location: '',
    cover: book.cover || '',
    notes: '',
    addedAt: Date.now(),
  };
}

function clearLookupResults() {
  const r = document.getElementById('lookupResults');
  r.innerHTML = '';
  r.classList.remove('visible');
  _lookupResultsCache = [];
}

// Routing asks "was this an attempt at an ISBN?", not "is this a valid ISBN?" —
// a truncated or mistyped number has to reach the path that can say so rather
// than being searched for as a film. looksLikeIsbn is what keeps
// `Apollo 13 1995 1080p` a film search even though its digits alone would
// normalise to a perfectly good ISBN-10 shape.
function handleLookupEnter() {
  if (looksLikeIsbn(document.getElementById('lookupInput').value)) lookupISBN();
  else lookupMovie();
}

function sortByExactMatch(results, query, titleKey) {
  const q = query.toLowerCase().trim();
  return [...results].sort((a, b) => {
    const at = (a[titleKey] || '').toLowerCase();
    const bt = (b[titleKey] || '').toLowerCase();
    const aExact = at === q;
    const bExact = bt === q;
    const aStarts = at.startsWith(q);
    const bStarts = bt.startsWith(q);
    if (aExact && !bExact) return -1;
    if (!aExact && bExact) return 1;
    if (aStarts && !bStarts) return -1;
    if (!aStarts && bStarts) return 1;
    return 0;
  });
}

// Returns the resolved book so lookupAndAddISBN can save it without looking it
// up a second time; null when there is nothing to add.
async function lookupISBN() {
  const raw = document.getElementById('lookupInput').value;
  if (!normalizeIsbn(raw)) return null;
  const status = document.getElementById('lookupStatus');
  clearLookupResults();
  status.innerHTML = '<span class="spinner"></span> Looking up ISBN...';
  status.className = 'lookup-status';

  try {
    const result = await resolveIsbn(raw);

    if (!result.ok) {
      status.textContent = isbnFailureText(result);
      status.className = 'lookup-status error';
      return null;
    }

    fillBookFields(result.book);
    status.textContent = '✓ Found — check the fields, then Add to Vault.';
    status.className = 'lookup-status success';
    return result;
  } catch (err) {
    status.textContent = 'Lookup failed: ' + err.message;
    status.className = 'lookup-status error';
    return null;
  }
}

// The one-at-a-time front end for the pasted list below: look the ISBN up and,
// on a hit, save it without making the user cross the form to a button. The
// modal stays open with the lookup box focused and empty, because somebody
// cataloguing a shelf has another book in their hand.
async function lookupAndAddISBN() {
  const status = document.getElementById('lookupStatus');
  // In edit mode there is a row already; minting a new id here would quietly
  // duplicate it rather than change it.
  if (document.getElementById('editId').value) {
    await lookupISBN();
    if (status.className.includes('success')) {
      status.textContent = '✓ Found — you are editing an existing item, so press Save Changes.';
    }
    return;
  }

  const result = await lookupISBN();
  if (!result) return;

  const item = bookToItem(result.book);
  const ok = await apiWrite(() => apiFetch('/api/media-vault/items', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(item),
  }));
  if (!ok) return;

  library.push(item);
  renderLibrary();
  clearForm();
  document.getElementById('lookupInput').focus();
  status.textContent = `✓ Added “${item.title}”. Next ISBN?`;
  status.className = 'lookup-status success';
}

async function lookupBook() {
  const query = document.getElementById('lookupInput').value.trim();
  const year = document.getElementById('lookupYear').value.trim();
  const searchBy = document.getElementById('tmdbSearchBy').value;
  if (!query) return;

  const status = document.getElementById('lookupStatus');
  clearLookupResults();

  try {
    let docs = [];

    if (searchBy === 'author') {
      status.innerHTML = '<span class="spinner"></span> Searching for author...';
      status.className = 'lookup-status';

      const data = await apiFetch(`/api/media-vault/lookup?mode=book-author&q=${encodeURIComponent(query)}${year ? `&year=${year}` : ''}`);

      if (!data.authorName) {
        status.textContent = `No author found named "${query}".`;
        status.className = 'lookup-status error';
        return;
      }
      if (data.results.length === 0) {
        status.textContent = `No books found for ${data.authorName}.`;
        status.className = 'lookup-status error';
        return;
      }

      docs = data.results;
      status.textContent = `${docs.length} book${docs.length !== 1 ? 's' : ''} by ${data.authorName}${year ? ` (${year})` : ''} — pick one:`;

    } else {
      // Title search
      status.innerHTML = '<span class="spinner"></span> Searching Open Library...';
      status.className = 'lookup-status';

      const data = await apiFetch(`/api/media-vault/lookup?mode=book-title&q=${encodeURIComponent(query)}${year ? `&year=${year}` : ''}`);

      if (data.results.length === 0) {
        status.textContent = year ? `No results for "${query}" around ${year}. Try without a year.` : 'No results found.';
        status.className = 'lookup-status error';
        return;
      }

      docs = sortByExactMatch(data.results, query, 'title');
      status.textContent = `${docs.length} result${docs.length !== 1 ? 's' : ''}${year ? ` (${year})` : ''} — pick one:`;
    }

    status.className = 'lookup-status';

    // Cache results so onclick can safely reference by index
    _lookupResultsCache = docs;

    const container = document.getElementById('lookupResults');
    container.innerHTML = docs.map((book, idx) => `<div class="lookup-result-item" onclick="selectBookResult(${idx})">
        ${book.thumb
          ? `<img class="lookup-result-thumb" src="${book.thumb}" onerror="this.outerHTML='<div class=\\'lookup-result-thumb-placeholder\\'>📚</div>'">`
          : `<div class="lookup-result-thumb-placeholder">📚</div>`}
        <div class="lookup-result-info">
          <div class="lookup-result-title">${esc(book.title)}</div>
          <div class="lookup-result-meta">${esc(book.authors)}${book.year ? ' · ' + book.year : ''}</div>
        </div>
      </div>`).join('');
    container.classList.add('visible');

  } catch (err) {
    status.textContent = 'Lookup failed: ' + err.message;
    status.className = 'lookup-status error';
  }
}

function selectBookResult(idx) {
  const book = _lookupResultsCache[idx];
  if (!book) return;
  fillBookFields(book);
  clearLookupResults();
  document.getElementById('lookupStatus').textContent = `✓ Selected: "${book.title}"`;
  document.getElementById('lookupStatus').className = 'lookup-status success';
}

// Every field this fills is set unconditionally, INCLUDING an absent cover.
// Writing the cover only `if (book.cover)` meant a second lookup in the same
// modal kept the first book's jacket: look up The Great Gatsby, then look up a
// print-on-demand edition whose OpenLibrary record has no cover of its own, and
// the form said "Pride and Prejudice" over Gatsby's artwork — reported as
// "✓ Found! Fields auto-filled.", and saved that way.
//
// actors and producers go the same way: a book result can never fill them, so
// leaving them alone carried a film's cast onto a book. series, location and
// notes are deliberately left alone — those are the user's, not the lookup's.
function fillBookFields(book) {
  const cover = book.cover || '';
  document.getElementById('itemTitle').value = book.title || '';
  document.getElementById('itemAuthor').value = book.authors || '';
  document.getElementById('itemGenre').value = book.genre || '';
  document.getElementById('itemActors').value = '';
  document.getElementById('itemProducers').value = '';
  document.getElementById('itemType').value = 'audiobook';
  document.getElementById('coverUrl').value = cover;
  document.getElementById('itemCoverInput').value = cover;
}

async function lookupMovie() {
  await lookupTMDB('movie');
}

async function lookupSeries() {
  await lookupTMDB('tv');
}

async function lookupTMDB(mediaType) {
  const query = document.getElementById('lookupInput').value.trim();
  const year = document.getElementById('lookupYear').value.trim();
  const searchBy = document.getElementById('tmdbSearchBy').value;
  if (!query) return;

  const status = document.getElementById('lookupStatus');
  clearLookupResults();
  const label = mediaType === 'tv' ? 'series' : 'movies';
  status.innerHTML = `<span class="spinner"></span> Searching TMDB for ${label}...`;
  status.className = 'lookup-status';

  try {
    let results = [];

    if (searchBy === 'actor' || searchBy === 'director') {
      const data = await apiFetch(`/api/media-vault/lookup?mode=video-person&q=${encodeURIComponent(query)}&kind=${mediaType}&role=${searchBy}`);

      if (!data.personName) {
        status.textContent = `No person found named "${query}".`;
        status.className = 'lookup-status error';
        return;
      }
      if (data.results.length === 0) {
        status.textContent = `No ${label} found for ${data.personName} as ${searchBy}.`;
        status.className = 'lookup-status error';
        return;
      }

      results = data.results;
      status.textContent = `${results.length} ${label} by ${data.personName} as ${searchBy} — pick one:`;

    } else {
      // Title search
      const data = await apiFetch(`/api/media-vault/lookup?mode=video-title&q=${encodeURIComponent(query)}&kind=${mediaType}${year ? `&year=${year}` : ''}`);

      if (data.results.length === 0) {
        status.textContent = `No ${label} found for "${query}"${year ? ` in ${year}` : ''}. ${year ? 'Try without a year.' : ''}`;
        status.className = 'lookup-status error';
        return;
      }

      results = sortByExactMatch(data.results, query, 'title').slice(0, 15);
      status.textContent = `${results.length} result${results.length !== 1 ? 's' : ''}${year ? ` (${year})` : ''} — pick one:`;
    }

    status.className = 'lookup-status';
    const container = document.getElementById('lookupResults');
    container.innerHTML = results.map(item => `
      <div class="lookup-result-item" onclick="selectTMDBResult(${item.id}, '${item.kind}')">
        ${item.poster
          ? `<img class="lookup-result-thumb" src="${item.poster}" onerror="this.outerHTML='<div class=\\'lookup-result-thumb-placeholder\\'>${item.kind === 'tv' ? '📺' : '🎬'}</div>'">`
          : `<div class="lookup-result-thumb-placeholder">${item.kind === 'tv' ? '📺' : '🎬'}</div>`}
        <div class="lookup-result-info">
          <div class="lookup-result-title">${esc(item.title)}</div>
          <div class="lookup-result-meta">${item.year ? item.year + ' · ' : ''}${item.kind === 'tv' ? 'Series' : 'Movie'}${item.overview ? ' · ' + esc(item.overview.slice(0, 60)) + '…' : ''}</div>
        </div>
      </div>`).join('');
    container.classList.add('visible');

  } catch (err) {
    status.textContent = 'Lookup failed: ' + err.message;
    status.className = 'lookup-status error';
  }
}

async function selectTMDBResult(tmdbId, mediaType) {
  clearLookupResults();
  const status = document.getElementById('lookupStatus');
  status.innerHTML = '<span class="spinner"></span> Fetching details...';
  status.className = 'lookup-status';

  try {
    const data = await apiFetch(`/api/media-vault/lookup?mode=video-detail&id=${tmdbId}&kind=${mediaType}`);

    document.getElementById('itemTitle').value = data.title;
    document.getElementById('itemAuthor').value = data.directors;
    document.getElementById('itemActors').value = data.actors;
    document.getElementById('itemProducers').value = data.producers;
    document.getElementById('itemGenre').value = data.genres;
    document.getElementById('itemType').value = mediaType === 'tv' ? 'series' : 'movie';

    if (data.poster) {
      document.getElementById('coverUrl').value = data.poster;
      document.getElementById('itemCoverInput').value = data.poster;
    }

    const extra = [];
    if (data.year) extra.push(`Year: ${data.year}`);
    if (data.runtime) extra.push(`Runtime: ${data.runtime} min`);
    if (data.seasons) extra.push(`Seasons: ${data.seasons}`);
    if (data.rating) extra.push(`TMDB: ${data.rating.toFixed(1)}/10`);
    if (data.overview) extra.push(`\n${data.overview}`);
    document.getElementById('itemNotes').value = extra.join(' · ');

    status.textContent = `✓ Selected: "${data.title}"${data.year ? ` (${data.year})` : ''}`;
    status.className = 'lookup-status success';
  } catch (err) {
    status.textContent = 'Failed to fetch details: ' + err.message;
    status.className = 'lookup-status error';
  }
}

// ─── CSV IMPORT/EXPORT ───
function exportCSV() {
  if (library.length === 0) { alert('Nothing to export.'); return; }
  const headers = ['type', 'title', 'author', 'actors', 'producers', 'genre', 'series', 'format', 'location', 'cover', 'notes'];
  const csvRows = [headers.join(',')];
  
  library.forEach(item => {
    csvRows.push(headers.map(h => {
      let val = item[h] || '';
      if (val.includes(',') || val.includes('"') || val.includes('\n')) {
        val = '"' + val.replace(/"/g, '""') + '"';
      }
      return val;
    }).join(','));
  });

  const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `mediavault-export-${new Date().toISOString().slice(0,10)}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

function openImportModal() {
  document.getElementById('importModal').classList.add('active');
  document.getElementById('csvPreview').style.display = 'none';
  document.getElementById('btnImport').disabled = true;
  document.getElementById('csvFileInput').value = '';
  csvData = null;
  setImportMode('csv');
  resetIsbnPaste();
}

function closeImportModal() {
  // A run in flight is abandoned rather than left ticking behind a closed
  // modal; nothing has been written yet at that point, so there is nothing to
  // undo.
  isbnPasteRunning = false;
  document.getElementById('importModal').classList.remove('active');
}

function setImportMode(mode) {
  const isCsv = mode === 'csv';
  document.getElementById('importTabCsv').classList.toggle('active', isCsv);
  document.getElementById('importTabIsbn').classList.toggle('active', !isCsv);
  document.getElementById('importCsvPane').style.display = isCsv ? '' : 'none';
  document.getElementById('importIsbnPane').style.display = isCsv ? 'none' : '';
  document.getElementById('btnImport').style.display = isCsv ? '' : 'none';
  document.getElementById('btnIsbnLookup').style.display = isCsv ? 'none' : '';
  document.getElementById('btnIsbnAdd').style.display = isCsv ? 'none' : '';
}

function previewCSV(input) {
  const file = input.files[0];
  if (!file) return;
  
  const reader = new FileReader();
  reader.onload = function(e) {
    const text = e.target.result;
    const lines = text.trim().split('\n');
    
    if (lines.length < 2) {
      document.getElementById('csvPreview').textContent = 'CSV appears empty or has no data rows.';
      document.getElementById('csvPreview').style.display = 'block';
      return;
    }

    const headers = parseCSVRow(lines[0]).map(h => h.toLowerCase().trim());
    const requiredHeaders = ['title'];
    const missing = requiredHeaders.filter(h => !headers.includes(h));
    
    if (missing.length) {
      document.getElementById('csvPreview').textContent = `Missing required headers: ${missing.join(', ')}`;
      document.getElementById('csvPreview').style.display = 'block';
      return;
    }

    csvData = { headers, rows: lines.slice(1).map(l => parseCSVRow(l)) };
    document.getElementById('csvPreview').textContent = `Found ${csvData.rows.length} items\nHeaders: ${headers.join(', ')}`;
    document.getElementById('csvPreview').style.display = 'block';
    document.getElementById('btnImport').disabled = false;
  };
  reader.readAsText(file);
}

function parseCSVRow(row) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < row.length; i++) {
    const ch = row[i];
    if (inQuotes) {
      if (ch === '"' && row[i+1] === '"') { current += '"'; i++; }
      else if (ch === '"') { inQuotes = false; }
      else { current += ch; }
    } else {
      if (ch === '"') { inQuotes = true; }
      else if (ch === ',') { result.push(current.trim()); current = ''; }
      else { current += ch; }
    }
  }
  result.push(current.trim());
  return result;
}

async function importCSV() {
  if (!csvData) return;
  const { headers, rows } = csvData;
  const newItems = [];

  rows.forEach(cols => {
    const obj = {};
    headers.forEach((h, i) => { obj[h] = cols[i] || ''; });

    if (!obj.title) return;

    newItems.push({
      id: crypto.randomUUID(),
      type: (obj.type || 'audiobook').toLowerCase(),
      format: (obj.format || 'digital').toLowerCase(),
      title: obj.title,
      author: obj.author || obj.authors || obj.director || '',
      actors: obj.actors || '',
      producers: obj.producers || '',
      genre: obj.genre || '',
      series: obj.series || obj['series names'] || obj['series name'] || '',
      location: obj.location || '',
      cover: obj.cover || '',
      notes: obj.notes || '',
      addedAt: Date.now(),
    });
  });

  const ok = await apiWrite(() => apiFetch('/api/media-vault/items/bulk', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ items: newItems }),
  }));
  if (!ok) return;

  library.push(...newItems);
  closeImportModal();
  renderLibrary();
  alert(`Imported ${newItems.length} items.`);
}

// ─── PASTE-ADD A LIST OF ISBNs ───
// Paste a shelf, get a library. The loop runs HERE, in the browser, one ISBN at
// a time, rather than in a Pages Function — which sidesteps every Worker
// execution limit, lets the run be cancelled halfway, and lets the user watch
// it happen. It calls the lookup endpoint that already exists; there is no new
// endpoint and no new lookup mode, and the smoke test would fail if there were.
//
// Nothing is written until the user presses Add. The looking-up pass is
// entirely read-only, so cancelling it, closing the modal or losing the tab
// costs nothing but the time already spent.
const ISBN_PASTE_MAX = 100;    // ~1 minute of wall clock at OpenLibrary's measured ~540ms/lookup
const ISBN_PASTE_DELAY_MS = 120;

function parseIsbnPaste() {
  return document.getElementById('isbnPasteInput').value
    .split('\n').map(l => l.trim()).filter(Boolean);
}

function resetIsbnPaste() {
  isbnPasteRows = [];
  isbnPasteRunning = false;
  isbnPasteDuplicates = 0;
  document.getElementById('isbnPasteInput').value = '';
  document.getElementById('isbnPastePreview').style.display = 'none';
  document.getElementById('isbnPasteResults').style.display = 'none';
  document.getElementById('isbnPasteResults').innerHTML = '';
  document.getElementById('btnIsbnLookup').disabled = true;
  document.getElementById('btnIsbnLookup').textContent = 'Look up';
  document.getElementById('btnIsbnAdd').disabled = true;
}

function previewIsbnPaste() {
  const lines = parseIsbnPaste();
  const preview = document.getElementById('isbnPastePreview');
  document.getElementById('btnIsbnLookup').disabled = lines.length === 0;
  if (lines.length === 0) { preview.style.display = 'none'; return; }

  // A silent cap reads as "it covered everything". Say what will be left out.
  const over = lines.length - ISBN_PASTE_MAX;
  const seconds = Math.max(1, Math.round(Math.min(lines.length, ISBN_PASTE_MAX) * 0.7));
  preview.textContent = over > 0
    ? `${lines.length} lines — only the first ${ISBN_PASTE_MAX} will be looked up, leaving ${over} out. Roughly ${seconds}s.`
    : `${lines.length} ISBN${lines.length === 1 ? '' : 's'} — roughly ${seconds}s to look up.`;
  preview.style.display = 'block';
}

async function runIsbnPaste() {
  const lookupBtn = document.getElementById('btnIsbnLookup');
  // While a run is in flight this button stops it, and it is labelled 'Stop'
  // rather than 'Cancel' because the modal's own Cancel sits right beside it:
  // two adjacent buttons reading 'Cancel' that do different things — abandon
  // the lookups, versus close the whole modal — is a coin toss for the user.
  if (isbnPasteRunning) { isbnPasteRunning = false; return; }

  // The same ISBN written two ways — `978-0-06-112008-4` and
  // `978–0–06–112008–4` — is one book, and normalizeIsbn is what proves it.
  // Dropping the repeat saves an upstream call and, more to the point, stops
  // the run offering to add the same book twice. The count is reported below
  // rather than swallowed.
  const seen = new Set();
  const lines = [];
  let duplicates = 0;
  for (const line of parseIsbnPaste()) {
    const key = normalizeIsbn(line);
    if (key && seen.has(key)) { duplicates++; continue; }
    if (key) seen.add(key);
    lines.push(line);
    if (lines.length === ISBN_PASTE_MAX) break;
  }
  if (lines.length === 0) return;

  isbnPasteRunning = true;
  isbnPasteDuplicates = duplicates;
  isbnPasteRows = [];
  lookupBtn.textContent = 'Stop';
  document.getElementById('btnIsbnAdd').disabled = true;
  document.getElementById('isbnPasteResults').style.display = 'block';

  for (let i = 0; i < lines.length; i++) {
    if (!isbnPasteRunning) break;
    let row;
    try {
      row = await resolveIsbn(lines[i]);
    } catch (err) {
      // One line failing upstream must not end the run — record it and go on.
      row = { raw: lines[i], isbn: normalizeIsbn(lines[i]), ok: false, why: 'error', error: err.message };
    }
    row.include = row.ok;
    isbnPasteRows.push(row);
    renderIsbnPasteResults(i + 1, lines.length);
    if (i < lines.length - 1 && isbnPasteRunning) {
      await new Promise(r => setTimeout(r, ISBN_PASTE_DELAY_MS));
    }
  }

  const cancelled = !isbnPasteRunning;
  isbnPasteRunning = false;
  lookupBtn.textContent = 'Look up';
  renderIsbnPasteResults(isbnPasteRows.length, lines.length, cancelled);
  document.getElementById('btnIsbnAdd').disabled = isbnPasteRows.every(r => !r.include);
}

// Unticking a row changes the count in the head line, so the head is rewritten
// here rather than only on the next full render — otherwise it reads "5
// selected to add" while the Add button is about to write four, which is the
// one number in this panel the user is relying on.
function toggleIsbnPasteRow(idx) {
  const row = isbnPasteRows[idx];
  if (!row || !row.ok) return;
  row.include = !row.include;
  document.getElementById('btnIsbnAdd').disabled = isbnPasteRows.every(r => !r.include);
  const el = document.getElementById('isbnRow-' + idx);
  if (el) el.classList.toggle('excluded', !row.include);
  const head = document.querySelector('.isbn-paste-head');
  if (head) head.innerHTML = isbnPasteHead(isbnPasteRows.length, isbnPasteRows.length, false);
}

function isbnPasteHead(done, total, cancelled) {
  const found = isbnPasteRows.filter(r => r.ok).length;
  const chosen = isbnPasteRows.filter(r => r.include).length;
  if (done < total && !cancelled) return `<span class="spinner"></span> Looking up ${done} of ${total}…`;
  return `${done} of ${total} looked up${cancelled ? ' (cancelled)' : ''} · ${found} found · ${chosen} selected to add`
    + (isbnPasteDuplicates ? ` · ${isbnPasteDuplicates} duplicate line${isbnPasteDuplicates === 1 ? '' : 's'} skipped` : '');
}

function renderIsbnPasteResults(done, total, cancelled) {
  document.getElementById('isbnPasteResults').innerHTML =
    `<div class="isbn-paste-head">${isbnPasteHead(done, total, cancelled)}</div>` +
    isbnPasteRows.map((r, i) => {
      const label = r.ok
        ? `${esc(r.book.title || '(untitled)')}${r.book.authors ? ' — ' + esc(r.book.authors) : ''}`
        : esc(isbnFailureText(r));   // it knows every `why`, including 'error'
      return `<div class="isbn-paste-row${r.ok ? '' : ' failed'}${r.ok && !r.include ? ' excluded' : ''}" id="isbnRow-${i}">
        <input type="checkbox" ${r.ok ? '' : 'disabled'} ${r.include ? 'checked' : ''} onclick="toggleIsbnPasteRow(${i})">
        <code>${esc(r.raw)}</code>
        <span>${r.ok ? '✓ ' : '✕ '}${label}</span>
      </div>`;
    }).join('');
}

async function commitIsbnPaste() {
  const chosen = isbnPasteRows.filter(r => r.include);
  if (chosen.length === 0) return;
  const newItems = chosen.map(r => bookToItem(r.book));

  // One write for the whole run: db.batch() is a transaction, so this either
  // all lands or none of it does. The cap error from items/bulk is surfaced
  // verbatim by apiWrite rather than swallowed — it names the number.
  const ok = await apiWrite(() => apiFetch('/api/media-vault/items/bulk', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ items: newItems }),
  }));
  if (!ok) return;

  library.push(...newItems);
  closeImportModal();
  renderLibrary();
  alert(`Added ${newItems.length} item${newItems.length === 1 ? '' : 's'} from ${isbnPasteRows.length} ISBN${isbnPasteRows.length === 1 ? '' : 's'}.`);
}

// ─── PERSISTENCE (D1 via /api/media-vault, identity from Cloudflare Access) ───
// D1 is the only store. localStorage is never read or written for library
// data — the one exception is migrateLocalIfNeeded below, which retires the
// old mv_library cache. Every write goes straight to the API; there is no
// debounce, no whole-library replace, and no merge modal any more.
let currentUser = null;

function setSaveStatus(status) {
  document.getElementById('syncDot').className = 'sync-dot ' + status;
}

async function apiFetch(url, opts) {
  const res = await fetch(url, opts);
  let body = null;
  try { body = await res.json(); } catch {}
  if (!res.ok) throw new Error((body && body.error) || `API error ${res.status}`);
  return body;
}

// Wraps a write: drives the status dot, and on failure alerts loudly and
// re-fetches the library so the UI never drifts from what the server holds —
// silent divergence was the failure mode of the old localStorage sync design.
async function apiWrite(fn) {
  setSaveStatus('syncing');
  try {
    await fn();
    setSaveStatus('synced');
    return true;
  } catch (err) {
    setSaveStatus('error');
    alert('Save failed: ' + err.message + '\n\nYour change was not stored. The library will reload from the server.');
    try {
      const data = await apiFetch('/api/media-vault/items');
      library = data.items;
      renderLibrary();
    } catch { /* the dot stays red; the next action retries */ }
    return false;
  }
}

// ─── ONE-TIME MIGRATION of the old localStorage cache ───
// The server merges: items whose title+type already exist in the caller's
// cloud rows are skipped (cloud wins), the rest are inserted. Only a
// confirmed 2xx deletes the local copy — on failure it stays put and the
// migration retries on the next load.
async function migrateLocalIfNeeded() {
  let localItems = [];
  try {
    localItems = JSON.parse(localStorage.getItem('mv_library') || '[]');
  } catch {
    localItems = [];
  }
  if (!Array.isArray(localItems) || localItems.length === 0) {
    localStorage.removeItem('mv_library');
    return;
  }
  await apiFetch('/api/media-vault/migrate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ items: localItems }),
  });
  localStorage.removeItem('mv_library');
}

// ─── STARTUP ───
// Cloudflare Access authenticates every visitor before they reach the app,
// so there is no in-app login: load the caller's library from D1, full stop.
// If the API is unreachable the app shows an error with a retry — never an
// empty library, and never stale local data.
async function initApp() {
  document.getElementById('loadError').style.display = 'none';
  setSaveStatus('syncing');
  try {
    try {
      await migrateLocalIfNeeded();
    } catch (err) {
      console.error('localStorage migration failed (will retry next load):', err);
    }
    const data = await apiFetch('/api/media-vault/items');
    currentUser = data.email;
    library = data.items;
    document.getElementById('userPill').style.display = 'flex';
    document.getElementById('userEmail').textContent = currentUser;
    setSaveStatus('synced');
    renderLibrary();
  } catch (err) {
    console.error('Load error:', err);
    setSaveStatus('error');
    document.getElementById('loadErrorMsg').textContent = err.message;
    document.getElementById('loadError').style.display = 'flex';
  }
}

// ─── VIEW SWITCHING ───
let currentMainView = 'library';

function switchView(view) {
  currentMainView = view;
  const isLibrary = view === 'library';

  // Leaving the library ends select mode. The bulk bar is fixed-position, so it
  // used to follow the user onto the Stats page — "6 selected", a live Delete,
  // and not a checkbox in sight — while the ☑ Select toggle that would cancel
  // it is hidden a few lines below. Only the bar's own Cancel and the Escape
  // key got you out.
  //
  // Hiding the bar and keeping the selection would be the wrong fix: coming
  // back to the library would restore a bar the user believed they had left
  // behind, still aimed at rows chosen before they went to look at a chart.
  if (!isLibrary && selectMode) setSelectMode(false);

  document.getElementById('navLibrary').classList.toggle('active', isLibrary);
  document.getElementById('navStats').classList.toggle('active', !isLibrary);

  // Show/hide library elements
  document.getElementById('toolbar').style.display = isLibrary ? '' : 'none';
  document.querySelector('.stats-bar').style.display = isLibrary ? '' : 'none';
  document.getElementById('libraryGrid').style.display = isLibrary && currentView === 'grid' ? 'grid' : 'none';
  document.getElementById('libraryList').style.display = isLibrary && currentView === 'list' ? 'flex' : 'none';
  document.getElementById('emptyState').style.display = 'none';
  document.getElementById('pagination').style.display = isLibrary ? '' : 'none';

  // Header action buttons — hide select/import/export on stats page
  document.getElementById('btnSelectMode').style.display = isLibrary ? '' : 'none';
  document.getElementById('btnImportHeader').style.display = isLibrary ? '' : 'none';
  document.getElementById('btnExportHeader').style.display = isLibrary ? '' : 'none';

  // Stats page
  document.getElementById('statsPage').classList.toggle('active', !isLibrary);

  if (!isLibrary) {
    renderStats();
  } else {
    renderLibrary();
  }
}

// ─── STATS ───
function buildRankedList(items, field, splitByComma) {
  const counts = {};
  items.forEach(item => {
    const raw = item[field] || '';
    if (!raw.trim()) return;
    const entries = splitByComma
      ? raw.split(',').map(s => s.trim()).filter(Boolean)
      : [raw.trim()];
    entries.forEach(e => {
      if (e && e !== 'N/A') counts[e] = (counts[e] || 0) + 1;
    });
  });
  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 50); // cap at 50
}

function renderRankedList(containerId, countId, items, field, splitByComma, filterField, filterType) {
  const ranked = buildRankedList(items, field, splitByComma);
  const countEl = document.getElementById(countId);
  const listEl = document.getElementById(containerId);

  if (countEl) countEl.textContent = `${ranked.length} unique`;

  if (ranked.length === 0) {
    listEl.innerHTML = `<div class="stats-empty">No data yet</div>`;
    return;
  }

  const max = ranked[0][1];
  listEl.innerHTML = ranked.map(([name, count], i) => {
    const pct = Math.round((count / max) * 100);
    const encodedName = encodeURIComponent(name);
    return `
      <div class="stats-list-item" onclick="jumpToSearch('${encodedName}', '${filterField}', '${filterType}')">
        <div class="stats-list-rank">#${i + 1}</div>
        <div class="stats-list-bar-wrap">
          <div class="stats-list-name">${esc(name)}</div>
          <div class="stats-list-bar" style="width:${pct}%"></div>
        </div>
        <div class="stats-list-count">${count}</div>
      </div>`;
  }).join('');
}

function jumpToSearch(encodedName, field, typeFilter) {
  // Switch to library, set search field and query, apply type filter
  switchView('library');
  document.getElementById('searchInput').value = decodeURIComponent(encodedName);
  document.getElementById('searchField').value = field;

  // Set the type filter button
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  const targetBtn = [...document.querySelectorAll('.filter-btn')].find(b => b.dataset.filter === typeFilter);
  if (targetBtn) {
    targetBtn.classList.add('active');
    currentFilter = typeFilter;
  } else {
    document.querySelector('.filter-btn[data-filter="all"]').classList.add('active');
    currentFilter = 'all';
  }
  currentPage = 1;
  renderLibrary();
}

function renderStats() {
  const audiobooks = library.filter(i => i.type === 'audiobook');
  const video = library.filter(i => i.type === 'movie' || i.type === 'series');
  const movies = library.filter(i => i.type === 'movie');
  const series = library.filter(i => i.type === 'series');

  // Subtitle
  document.getElementById('statsSubtitle').textContent =
    `${library.length} items · ${audiobooks.length} audiobooks · ${movies.length} movies · ${series.length} series`;

  // Overview cards
  document.getElementById('statsOverview').innerHTML = [
    { val: library.length, lbl: 'Total Items' },
    { val: audiobooks.length, lbl: 'Audiobooks' },
    { val: movies.length, lbl: 'Movies' },
    { val: series.length, lbl: 'Series' },
    { val: library.filter(i => i.format === 'physical').length, lbl: 'Physical' },
    { val: library.filter(i => i.format === 'digital').length, lbl: 'Digital' },
  ].map(c => `
    <div class="stats-overview-card">
      <div class="val">${c.val}</div>
      <div class="lbl">${c.lbl}</div>
    </div>`).join('');

  // Audiobook sections — search by author field, no type filter needed since audiobooks only
  renderRankedList('listAuthors', 'countAuthors', audiobooks, 'author', false, 'author', 'audiobook');
  renderRankedList('listAudiobookGenres', 'countAudiobookGenres', audiobooks, 'genre', true, 'genre', 'audiobook');

  // Show/hide audiobook section
  document.getElementById('statsAudiobookSections').style.display = audiobooks.length ? '' : 'none';

  // Video sections
  renderRankedList('listDirectors', 'countDirectors', video, 'author', false, 'author', 'all');
  renderRankedList('listActors', 'countActors', video, 'actors', true, 'all', 'all');
  renderRankedList('listProducers', 'countProducers', video, 'producers', true, 'all', 'all');
  renderRankedList('listVideoGenres', 'countVideoGenres', video, 'genre', true, 'genre', 'all');

  document.getElementById('statsVideoSections').style.display = video.length ? '' : 'none';
}

// ─── KEYBOARD ───
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') {
    if (selectMode) { toggleSelectMode(); return; }
    closeAddModal();
    closeDetailModal();
    closeImportModal();
  }
  if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
    e.preventDefault();
    openAddModal();
  }
});

// Close modals on overlay click
['addModal', 'detailModal', 'importModal'].forEach(id => {
  document.getElementById(id).addEventListener('click', function(e) {
    if (e.target === this) {
      this.classList.remove('active');
    }
  });
});

// ─── INIT ───
initApp();
