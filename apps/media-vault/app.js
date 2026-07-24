// ─── SUPABASE CONFIG ───
// 🔧 REPLACE THESE with your actual Supabase project values
const SUPABASE_URL = 'https://ahnjzgtdscrcvfmcvsuc.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_-bqxBWpfWP3wsYL6mV-UJA_ynaOcgxp';

const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ─── STATE ───
let library = (() => {
  try {
    return JSON.parse(localStorage.getItem('mv_library') || '[]');
  } catch (err) {
    console.error('Corrupted mv_library in localStorage, resetting:', err);
    return [];
  }
})();
let currentFilter = 'all';
let currentView = 'grid';
let _lookupResultsCache = []; // stores book/TMDB results so onclick can reference by index safely
let detailItemId = null;
let csvData = null;
let selectMode = false;
let selectedIds = new Set();
let currentPage = 1;
const ITEMS_PER_PAGE = 20;

const TMDB_KEY = '99927f44afc159f2ebe2d1194cd777e7';
const TMDB_BASE = 'https://api.themoviedb.org/3';
const TMDB_IMG = 'https://image.tmdb.org/t/p/w92'; // thumbnail
const TMDB_IMG_LG = 'https://image.tmdb.org/t/p/w500'; // full poster

// ─── RENDER ───
function resetPageAndRender() {
  currentPage = 1;
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

function renderLibrary() {
  const query = document.getElementById('searchInput').value.toLowerCase().trim();
  const sortVal = document.getElementById('sortSelect').value;
  const searchField = document.getElementById('searchField').value;

  let filtered = getFilteredLibrary();

  // Sort
  const [sortKey, sortDir] = sortVal.split('-');
  filtered.sort((a, b) => {
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

  // Pagination
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
  if (currentPage > totalPages) currentPage = totalPages;
  const start = (currentPage - 1) * ITEMS_PER_PAGE;
  const paginated = filtered.slice(start, start + ITEMS_PER_PAGE);

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

function saveItem() {
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

  if (editId) {
    const idx = library.findIndex(i => i.id === editId);
    if (idx >= 0) library[idx] = item;
  } else {
    library.push(item);
  }

  saveLibrary();
  closeAddModal();
  closeDetailModal();
  renderLibrary();
}

function deleteItem(id) {
  if (!confirm('Delete this item?')) return;
  library = library.filter(i => i.id !== id);
  saveLibrary();
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
function toggleSelectMode() {
  selectMode = !selectMode;
  selectedIds.clear();
  document.body.classList.toggle('select-mode', selectMode);
  const btn = document.getElementById('btnSelectMode');
  btn.classList.toggle('active', selectMode);
  btn.textContent = selectMode ? '✕ Cancel' : '☑ Select';
  updateBulkBar();
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

function updateBulkBar() {
  const bar = document.getElementById('bulkBar');
  const count = selectedIds.size;
  document.getElementById('bulkCount').textContent = `${count} selected`;
  bar.classList.toggle('visible', selectMode);
  const allVisible = getFilteredIds();
  const allSelected = allVisible.length > 0 && allVisible.every(id => selectedIds.has(id));
  document.getElementById('bulkSelectAllBtn').textContent = allSelected ? 'Deselect All' : 'Select All';
}

function bulkChangeType(newType) {
  if (selectedIds.size === 0) return;
  const label = newType === 'audiobook' ? 'Audiobooks' : 'Movies';
  if (!confirm(`Change ${selectedIds.size} item(s) to ${label}?`)) return;
  library.forEach(item => {
    if (selectedIds.has(item.id)) item.type = newType;
  });
  saveLibrary();
  selectedIds.clear();
  updateBulkBar();
  renderLibrary();
}

function bulkDelete() {
  if (selectedIds.size === 0) return;
  if (!confirm(`Permanently delete ${selectedIds.size} item(s)? This cannot be undone.`)) return;
  library = library.filter(item => !selectedIds.has(item.id));
  saveLibrary();
  selectedIds.clear();
  updateBulkBar();
  renderLibrary();
}

// ─── LOOKUPS ───
function clearLookupResults() {
  const r = document.getElementById('lookupResults');
  r.innerHTML = '';
  r.classList.remove('visible');
  _lookupResultsCache = [];
}

function handleLookupEnter() {
  const val = document.getElementById('lookupInput').value.trim();
  if (/^\d{10,13}$/.test(val.replace(/[-\s]/g, ''))) lookupISBN();
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

async function lookupISBN() {
  const isbn = document.getElementById('lookupInput').value.trim().replace(/[-\s]/g, '');
  if (!isbn) return;
  const status = document.getElementById('lookupStatus');
  clearLookupResults();
  status.innerHTML = '<span class="spinner"></span> Looking up ISBN...';
  status.className = 'lookup-status';

  try {
    const res = await fetch(`https://openlibrary.org/api/books?bibkeys=ISBN:${isbn}&format=json&jscmd=data`);
    const data = await res.json();
    const book = data[`ISBN:${isbn}`];

    if (!book) {
      status.textContent = 'No results found for that ISBN.';
      status.className = 'lookup-status error';
      return;
    }

    fillBookFields({
      title: book.title,
      authors: (book.authors || []).map(a => a.name).join(', '),
      genre: (book.subjects || []).slice(0, 3).map(s => s.name).join(', '),
      cover: book.cover ? (book.cover.large || book.cover.medium || book.cover.small || '') : ''
    });
    status.textContent = '✓ Found! Fields auto-filled.';
    status.className = 'lookup-status success';
  } catch (err) {
    status.textContent = 'Lookup failed: ' + err.message;
    status.className = 'lookup-status error';
  }
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
      // Step 1: find the author
      status.innerHTML = '<span class="spinner"></span> Searching for author...';
      status.className = 'lookup-status';

      const authorRes = await fetch(`https://openlibrary.org/search/authors.json?q=${encodeURIComponent(query)}&limit=1`);
      const authorData = await authorRes.json();

      if (!authorData.docs || authorData.docs.length === 0) {
        status.textContent = `No author found named "${query}".`;
        status.className = 'lookup-status error';
        return;
      }

      const author = authorData.docs[0];
      const authorName = author.name || query;
      status.innerHTML = `<span class="spinner"></span> Found ${esc(authorName)} — loading their books...`;

      // Step 2: get their works
      let worksUrl = `https://openlibrary.org/search.json?author=${encodeURIComponent(authorName)}&limit=20&sort=editions`;
      if (year) worksUrl += `&first_publish_year=${year}`;

      const worksRes = await fetch(worksUrl);
      const worksData = await worksRes.json();

      if (!worksData.docs || worksData.docs.length === 0) {
        status.textContent = `No books found for ${authorName}.`;
        status.className = 'lookup-status error';
        return;
      }

      docs = worksData.docs;
      status.textContent = `${docs.length} book${docs.length !== 1 ? 's' : ''} by ${authorName}${year ? ` (${year})` : ''} — pick one:`;

    } else {
      // Title search
      status.innerHTML = '<span class="spinner"></span> Searching Open Library...';
      status.className = 'lookup-status';

      let url = `https://openlibrary.org/search.json?q=${encodeURIComponent(query)}&limit=15`;
      if (year) url += `&first_publish_year=${year}`;

      const res = await fetch(url);
      const data = await res.json();

      if (!data.docs || data.docs.length === 0) {
        status.textContent = year ? `No results for "${query}" around ${year}. Try without a year.` : 'No results found.';
        status.className = 'lookup-status error';
        return;
      }

      docs = sortByExactMatch(data.docs, query, 'title');
      status.textContent = `${docs.length} result${docs.length !== 1 ? 's' : ''}${year ? ` (${year})` : ''} — pick one:`;
    }

    status.className = 'lookup-status';

    // Cache results so onclick can safely reference by index
    _lookupResultsCache = docs.map(book => {
      const title = book.title || 'Unknown Title';
      const author = (book.author_name || []).join(', ') || 'Unknown Author';
      const coverId = book.cover_i;
      const genre = (book.subject || []).slice(0, 3).join(', ');
      const largeUrl = coverId ? `https://covers.openlibrary.org/b/id/${coverId}-L.jpg` : '';
      return { title, authors: author, genre, cover: largeUrl };
    });

    const container = document.getElementById('lookupResults');
    container.innerHTML = _lookupResultsCache.map((book, idx) => {
      const coverId = docs[idx]?.cover_i;
      const thumbUrl = coverId ? `https://covers.openlibrary.org/b/id/${coverId}-S.jpg` : null;
      const bookYear = docs[idx]?.first_publish_year || '';

      return `<div class="lookup-result-item" onclick="selectBookResult(${idx})">
        ${thumbUrl
          ? `<img class="lookup-result-thumb" src="${thumbUrl}" onerror="this.outerHTML='<div class=\\'lookup-result-thumb-placeholder\\'>📚</div>'">`
          : `<div class="lookup-result-thumb-placeholder">📚</div>`}
        <div class="lookup-result-info">
          <div class="lookup-result-title">${esc(book.title)}</div>
          <div class="lookup-result-meta">${esc(book.authors)}${bookYear ? ' · ' + bookYear : ''}</div>
        </div>
      </div>`;
    }).join('');
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

function fillBookFields(book) {
  document.getElementById('itemTitle').value = book.title || '';
  document.getElementById('itemAuthor').value = book.authors || '';
  document.getElementById('itemGenre').value = book.genre || '';
  document.getElementById('itemType').value = 'audiobook';
  if (book.cover) {
    document.getElementById('coverUrl').value = book.cover;
    document.getElementById('itemCoverInput').value = book.cover;
  }
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
      // Step 1: find the person
      const personRes = await fetch(`${TMDB_BASE}/search/person?query=${encodeURIComponent(query)}&api_key=${TMDB_KEY}`);
      const personData = await personRes.json();

      if (!personData.results || personData.results.length === 0) {
        status.textContent = `No person found named "${query}".`;
        status.className = 'lookup-status error';
        return;
      }

      // Pick best person match
      const person = personData.results[0];
      status.innerHTML = `<span class="spinner"></span> Found ${esc(person.name)} — loading their ${label}...`;

      // Step 2: get their credits
      const credType = mediaType === 'tv' ? 'tv' : 'movie';
      const credRes = await fetch(`${TMDB_BASE}/person/${person.id}/${credType}_credits?api_key=${TMDB_KEY}`);
      const credData = await credRes.json();

      let credits = [];
      if (searchBy === 'actor') {
        credits = credData.cast || [];
      } else {
        credits = (credData.crew || []).filter(c => c.job === 'Director');
      }

      // Dedupe by id, sort by popularity
      const seen = new Set();
      results = credits
        .filter(c => { if (seen.has(c.id)) return false; seen.add(c.id); return true; })
        .sort((a, b) => (b.popularity || 0) - (a.popularity || 0))
        .slice(0, 20)
        .map(c => ({
          id: c.id,
          title: c.title || c.name || '',
          year: (c.release_date || c.first_air_date || '').slice(0, 4),
          poster: c.poster_path ? TMDB_IMG + c.poster_path : null,
          posterLg: c.poster_path ? TMDB_IMG_LG + c.poster_path : null,
          mediaType: credType,
          overview: c.overview || '',
        }));

      if (results.length === 0) {
        status.textContent = `No ${label} found for ${person.name} as ${searchBy}.`;
        status.className = 'lookup-status error';
        return;
      }
      status.textContent = `${results.length} ${label} by ${person.name} as ${searchBy} — pick one:`;

    } else {
      // Title search
      const endpoint = mediaType === 'tv' ? 'search/tv' : 'search/movie';
      let url = `${TMDB_BASE}/${endpoint}?query=${encodeURIComponent(query)}&api_key=${TMDB_KEY}`;
      if (year) url += `&year=${year}`;

      const res = await fetch(url);
      const data = await res.json();

      if (!data.results || data.results.length === 0) {
        status.textContent = `No ${label} found for "${query}"${year ? ` in ${year}` : ''}. ${year ? 'Try without a year.' : ''}`;
        status.className = 'lookup-status error';
        return;
      }

      const sorted = sortByExactMatch(data.results, query, mediaType === 'tv' ? 'name' : 'title');
      results = sorted.slice(0, 15).map(c => ({
        id: c.id,
        title: c.title || c.name || '',
        year: (c.release_date || c.first_air_date || '').slice(0, 4),
        poster: c.poster_path ? TMDB_IMG + c.poster_path : null,
        posterLg: c.poster_path ? TMDB_IMG_LG + c.poster_path : null,
        mediaType,
        overview: c.overview || '',
      }));

      status.textContent = `${results.length} result${results.length !== 1 ? 's' : ''}${year ? ` (${year})` : ''} — pick one:`;
    }

    status.className = 'lookup-status';
    const container = document.getElementById('lookupResults');
    container.innerHTML = results.map(item => `
      <div class="lookup-result-item" onclick="selectTMDBResult(${item.id}, '${item.mediaType}')">
        ${item.poster
          ? `<img class="lookup-result-thumb" src="${item.poster}" onerror="this.outerHTML='<div class=\\'lookup-result-thumb-placeholder\\'>${item.mediaType === 'tv' ? '📺' : '🎬'}</div>'">`
          : `<div class="lookup-result-thumb-placeholder">${item.mediaType === 'tv' ? '📺' : '🎬'}</div>`}
        <div class="lookup-result-info">
          <div class="lookup-result-title">${esc(item.title)}</div>
          <div class="lookup-result-meta">${item.year ? item.year + ' · ' : ''}${item.mediaType === 'tv' ? 'Series' : 'Movie'}${item.overview ? ' · ' + item.overview.slice(0, 60) + '…' : ''}</div>
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
    const endpoint = mediaType === 'tv' ? 'tv' : 'movie';
    const res = await fetch(`${TMDB_BASE}/${endpoint}/${tmdbId}?api_key=${TMDB_KEY}&append_to_response=credits`);
    const data = await res.json();

    const title = data.title || data.name || '';
    const year = (data.release_date || data.first_air_date || '').slice(0, 4);
    const genres = (data.genres || []).map(g => g.name).join(', ');
    const posterUrl = data.poster_path ? TMDB_IMG_LG + data.poster_path : '';

    // Director(s)
    const directors = (data.credits?.crew || [])
      .filter(c => c.job === 'Director')
      .map(c => c.name).join(', ');

    // Top billed cast (first 5)
    const actors = (data.credits?.cast || [])
      .slice(0, 5)
      .map(c => c.name).join(', ');

    // Producers
    const producers = (data.credits?.crew || [])
      .filter(c => c.job === 'Producer' || c.job === 'Executive Producer')
      .slice(0, 3)
      .map(c => c.name).join(', ');

    document.getElementById('itemTitle').value = title;
    document.getElementById('itemAuthor').value = directors;
    document.getElementById('itemActors').value = actors;
    document.getElementById('itemProducers').value = producers;
    document.getElementById('itemGenre').value = genres;
    document.getElementById('itemType').value = mediaType === 'tv' ? 'series' : 'movie';

    if (posterUrl) {
      document.getElementById('coverUrl').value = posterUrl;
      document.getElementById('itemCoverInput').value = posterUrl;
    }

    const extra = [];
    if (year) extra.push(`Year: ${year}`);
    if (data.runtime) extra.push(`Runtime: ${data.runtime} min`);
    if (data.number_of_seasons) extra.push(`Seasons: ${data.number_of_seasons}`);
    if (data.vote_average) extra.push(`TMDB: ${data.vote_average.toFixed(1)}/10`);
    if (data.overview) extra.push(`\n${data.overview}`);
    document.getElementById('itemNotes').value = extra.join(' · ');

    status.textContent = `✓ Selected: "${title}"${year ? ` (${year})` : ''}`;
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
}

function closeImportModal() {
  document.getElementById('importModal').classList.remove('active');
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

function importCSV() {
  if (!csvData) return;
  const { headers, rows } = csvData;
  let count = 0;

  rows.forEach(cols => {
    const obj = {};
    headers.forEach((h, i) => { obj[h] = cols[i] || ''; });
    
    if (!obj.title) return;

    library.push({
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
    count++;
  });

  saveLibrary();
  closeImportModal();
  renderLibrary();
  alert(`Imported ${count} items.`);
}

// ─── PERSISTENCE ───
function saveLibrary() {
  localStorage.setItem('mv_library', JSON.stringify(library));
  syncToCloud();
}

// ─── AUTH UI ───
let authMode = 'signin';

function switchAuthTab(mode) {
  authMode = mode;
  document.getElementById('tabSignIn').classList.toggle('active', mode === 'signin');
  document.getElementById('tabSignUp').classList.toggle('active', mode === 'signup');
  document.getElementById('confirmGroup').style.display = mode === 'signup' ? 'block' : 'none';
  document.getElementById('authSubmitBtn').textContent = mode === 'signin' ? 'Sign In' : 'Create Account';
  document.getElementById('authError').classList.remove('visible');
  document.getElementById('authSuccess').classList.remove('visible');
}

async function submitAuth() {
  const email = document.getElementById('authEmail').value.trim();
  const password = document.getElementById('authPassword').value;
  const confirm = document.getElementById('authConfirm').value;
  const errEl = document.getElementById('authError');
  const successEl = document.getElementById('authSuccess');
  const btn = document.getElementById('authSubmitBtn');

  errEl.classList.remove('visible');
  successEl.classList.remove('visible');

  if (!email || !password) { showAuthError('Email and password are required.'); return; }
  if (authMode === 'signup' && password !== confirm) { showAuthError('Passwords do not match.'); return; }
  if (authMode === 'signup' && password.length < 6) { showAuthError('Password must be at least 6 characters.'); return; }

  btn.disabled = true;
  btn.textContent = authMode === 'signin' ? 'Signing in...' : 'Creating account...';

  try {
    let result;
    if (authMode === 'signin') {
      result = await sb.auth.signInWithPassword({ email, password });
    } else {
      result = await sb.auth.signUp({ email, password });
    }

    if (result.error) {
      showAuthError(result.error.message);
      btn.disabled = false;
      btn.textContent = authMode === 'signin' ? 'Sign In' : 'Create Account';
    } else if (authMode === 'signup' && !result.data.session) {
      // Email confirmation required
      successEl.textContent = '✓ Check your email to confirm your account, then sign in.';
      successEl.classList.add('visible');
      btn.disabled = false;
      btn.textContent = 'Create Account';
    }
    // If signin succeeded, onAuthStateChange will handle the rest
  } catch (err) {
    showAuthError('Unexpected error: ' + err.message);
    btn.disabled = false;
    btn.textContent = authMode === 'signin' ? 'Sign In' : 'Create Account';
  }
}

function showAuthError(msg) {
  const el = document.getElementById('authError');
  el.textContent = msg;
  el.classList.add('visible');
}

async function signOut() {
  await sb.auth.signOut();
  document.getElementById('authScreen').classList.remove('hidden');
  document.getElementById('userPill').style.display = 'none';
  library = [];
  renderLibrary();
}

// ─── SYNC ───
let currentUser = null;
let syncTimeout = null;

function setSyncStatus(status) {
  const dot = document.getElementById('syncDot');
  dot.className = 'sync-dot ' + status;
}

async function loadFromCloud() {
  if (!currentUser) return;
  setSyncStatus('syncing');
  try {
    const { data, error } = await sb
      .from('media_library')
      .select('*')
      .eq('user_id', currentUser.id);
    if (error) throw error;
    setSyncStatus('synced');
    return (data || []).map(row => ({
      id: row.item_id,
      type: row.type,
      format: row.format,
      title: row.title,
      author: row.author || '',
      actors: row.actors || '',
      producers: row.producers || '',
      genre: row.genre || '',
      series: row.series || '',
      location: row.location || '',
      cover: row.cover || '',
      notes: row.notes || '',
      addedAt: row.added_at ? new Date(row.added_at).getTime() : Date.now(),
    }));
  } catch (err) {
    console.error('Load error:', err);
    setSyncStatus('error');
    return null;
  }
}

async function pushAllToCloud(items) {
  if (!currentUser) return;
  setSyncStatus('syncing');
  try {
    // Delete all existing rows for user, then re-insert
    await sb.from('media_library').delete().eq('user_id', currentUser.id);
    if (items.length > 0) {
      const rows = items.map(item => ({
        user_id: currentUser.id,
        item_id: item.id,
        type: item.type,
        format: item.format,
        title: item.title,
        author: item.author || '',
        actors: item.actors || '',
        producers: item.producers || '',
        genre: item.genre || '',
        series: item.series || '',
        location: item.location || '',
        cover: item.cover || '',
        notes: item.notes || '',
        added_at: new Date(item.addedAt || Date.now()).toISOString(),
      }));
      const { error } = await sb.from('media_library').insert(rows);
      if (error) throw error;
    }
    setSyncStatus('synced');
  } catch (err) {
    console.error('Sync error:', err);
    setSyncStatus('error');
  }
}

function syncToCloud() {
  if (!currentUser) return;
  // Debounce — wait 1.5s after last change before pushing
  clearTimeout(syncTimeout);
  setSyncStatus('syncing');
  syncTimeout = setTimeout(() => pushAllToCloud(library), 1500);
}

// ─── MERGE MODAL ───
let _mergeCloudItems = [];
let _mergeLocalItems = [];

function openMergeModal(localItems, cloudItems) {
  _mergeLocalItems = localItems;
  _mergeCloudItems = cloudItems;
  const localCount = localItems.length;
  const cloudCount = cloudItems.length;
  document.getElementById('mergeDesc').textContent =
    `You have ${localCount} item${localCount !== 1 ? 's' : ''} saved locally and ${cloudCount} item${cloudCount !== 1 ? 's' : ''} in the cloud. How would you like to proceed?`;
  document.getElementById('mergeModal').classList.add('active');
}

async function handleMerge(choice) {
  document.getElementById('mergeModal').classList.remove('active');

  if (choice === 'merge') {
    // Merge: add local items not already in cloud (match by title+type)
    const cloudTitles = new Set(_mergeCloudItems.map(i => i.title.toLowerCase() + '|' + i.type));
    const newItems = _mergeLocalItems.filter(i => !cloudTitles.has(i.title.toLowerCase() + '|' + i.type));
    library = [..._mergeCloudItems, ...newItems];
  } else if (choice === 'local') {
    library = [..._mergeLocalItems];
  } else {
    library = [..._mergeCloudItems];
  }

  localStorage.setItem('mv_library', JSON.stringify(library));
  await pushAllToCloud(library);
  renderLibrary();
}

// ─── AUTH STATE LISTENER ───
sb.auth.onAuthStateChange(async (event, session) => {
  if (session && session.user) {
    currentUser = session.user;
    document.getElementById('authScreen').classList.add('hidden');
    document.getElementById('userPill').style.display = 'flex';
    document.getElementById('userEmail').textContent = session.user.email;

    const localItems = JSON.parse(localStorage.getItem('mv_library') || '[]');
    const cloudItems = await loadFromCloud();

    if (cloudItems === null) {
      // Cloud load failed — just use local
      library = localItems;
      renderLibrary();
      return;
    }

    if (localItems.length > 0 && cloudItems.length > 0) {
      // Both have data — ask user
      library = cloudItems; // show cloud while they decide
      renderLibrary();
      openMergeModal(localItems, cloudItems);
    } else if (localItems.length > 0 && cloudItems.length === 0) {
      // Local only — push to cloud automatically
      library = localItems;
      await pushAllToCloud(library);
      renderLibrary();
    } else {
      // Cloud only or both empty — use cloud
      library = cloudItems;
      localStorage.setItem('mv_library', JSON.stringify(library));
      renderLibrary();
    }
  } else {
    currentUser = null;
  }
});

// ─── VIEW SWITCHING ───
let currentMainView = 'library';

function switchView(view) {
  currentMainView = view;
  const isLibrary = view === 'library';

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
['addModal', 'detailModal', 'importModal', 'mergeModal'].forEach(id => {
  document.getElementById(id).addEventListener('click', function(e) {
    if (e.target === this && id !== 'mergeModal') {
      this.classList.remove('active');
    }
  });
});

// ─── INIT ───
renderLibrary(); // render from localStorage while auth loads
