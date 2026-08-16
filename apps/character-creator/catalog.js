// Catalog editor — admin only.
//
// Only the importers used to write catalog rows, so a single wrong percentage
// meant a re-import or raw SQL. This is the hand-editing path.
//
// The table and the row form are generated from js/catalog-fields.js, the same
// config the write endpoints validate against and the importers build their
// prompts from. A new column appears here without touching this file.
//
// An ES module (it imports the config), so handlers are wired with addEventListener
// rather than inline onclick — nothing here is on `window`.

import { CATALOGS, CATALOG_KEYS } from './js/catalog-fields.js';

const S = {
  isAdmin: false,
  catalog: CATALOG_KEYS[0],
  rows: [],
  filter: '',
  category: '',
  openId: null,      // row being edited; 'new' for the create form
  draft: null,       // in-progress values for the open row
  msg: null,
  loading: true,
  // Duplicate review. The importers dedupe on an exact name; these are the
  // pairs that only match after normalising punctuation and word order.
  dupes: null,
  dupeBusy: false,
  // Tier counts for the open catalog, fetched on load so a duplicate pair
  // surfaces without anyone thinking to go looking for it.
  dupeCounts: null,
  // Forwarding addresses left by merges and hand renames. Listed because they
  // accumulate silently and a hasty merge is otherwise only undoable in SQL.
  redirects: null,
};

const $ = (id) => document.getElementById(id);
const cat = () => CATALOGS[S.catalog];

// api() and errorDetails() come from js/api.js, loaded first as a classic script.

// ─── data ───

async function loadRows() {
  S.loading = true;
  render();
  try {
    S.rows = (await api('catalogs/rows?catalog=' + encodeURIComponent(S.catalog))).rows || [];
  } catch (err) {
    S.rows = [];
    S.msg = { text: err.message, error: true };
  }
  S.loading = false;
  render();
  loadDupeCounts();   // after the rows are on screen; the badge can arrive late
}

// Counts only — the badge needs three numbers, not both rows of every pair.
// Failure is silent: a badge that could not be computed is a missing hint, not
// something worth an error message over the catalog you came here to edit.
async function loadDupeCounts() {
  const forCatalog = S.catalog;
  try {
    const res = await api('catalogs/duplicates?counts_only=1&catalog=' + encodeURIComponent(forCatalog));
    // Tabs can be switched while this is in flight; a stale answer would badge
    // the wrong catalog.
    if (S.catalog !== forCatalog) return;
    S.dupeCounts = res.tiers;
    render();
  } catch { /* no badge, no complaint */ }
}

function visibleRows() {
  const q = S.filter.trim().toLowerCase();
  return S.rows.filter((r) => {
    if (S.category && (r.category || '') !== S.category) return false;
    if (!q) return true;
    // Search the display name plus source book, which is how you actually hunt
    // for "the Climbing from Ultimate Edition".
    return String(r[cat().displayField] || '').toLowerCase().includes(q)
        || String(r.source_book || '').toLowerCase().includes(q);
  });
}

function categoryOptions() {
  if (!cat().fields.some((f) => f.name === 'category')) return [];
  return [...new Set(S.rows.map((r) => r.category).filter(Boolean))].sort();
}

// ─── field inputs ───

function inputFor(f, value) {
  const id = 'f-' + f.name;
  const v = value ?? '';
  switch (f.type) {
    case 'longtext':
      return `<textarea id="${id}" rows="3">${escHtml(v)}</textarea>`;
    case 'int':
    case 'real':
      return `<input type="number" id="${id}" value="${escHtml(v)}"${f.type === 'real' ? ' step="0.1"' : ''}>`;
    case 'bool':
      // rowForm already renders the field's label above it, so this is bare.
      return `<label class="inline-check">
        <input type="checkbox" id="${id}"${value ? ' checked' : ''}> yes</label>`;
    case 'select': {
      // allowOther keeps a stored value that is not in the list selectable,
      // instead of silently snapping it to something else on save.
      const opts = [...(f.options || [])];
      if (f.allowOther && v && !opts.includes(v)) opts.push(v);
      return `<select id="${id}">
        <option value=""${v ? '' : ' selected'}>—</option>
        ${opts.map((o) => `<option value="${escHtml(o)}"${o === v ? ' selected' : ''}>${escHtml(o)}</option>`).join('')}
      </select>`;
    }
    case 'systems': {
      const picked = Array.isArray(value) ? value : [];
      const box = (sys, label) => `<label class="inline-check">
        <input type="checkbox" data-systems="${sys}"${picked.includes(sys) ? ' checked' : ''}> ${label}</label>`;
      return `<div class="sys-picker">
        ${box('rifts', 'Rifts')}${box('palladium-fantasy', 'Palladium Fantasy')}
        <span class="muted small">neither ticked = both systems</span>
      </div>`;
    }
    case 'kv': {
      const obj = value && typeof value === 'object' ? value : {};
      const entries = Object.entries(obj);
      const row = (k, val) => `<div class="kv-row">
        <input type="text" class="kv-key" placeholder="key" value="${escHtml(k)}">
        <input type="text" class="kv-val" placeholder="value" value="${escHtml(val ?? '')}">
        <button type="button" class="btn btn-sm btn-ghost" data-kv-remove>×</button>
      </div>`;
      return `<div class="kv-editor" id="${id}">
        ${entries.map(([k, val]) => row(k, val)).join('')}
        <button type="button" class="btn btn-sm" data-kv-add>+ add</button>
      </div>`;
    }
    default:
      return `<input type="text" id="${id}" value="${escHtml(v)}">`;
  }
}

// Read the form back out. Mirrors inputFor case for case.
function collectDraft() {
  const out = {};
  for (const f of cat().fields) {
    const el = $('f-' + f.name);
    if (f.type === 'systems') {
      out[f.name] = [...document.querySelectorAll('[data-systems]')]
        .filter((c) => c.checked).map((c) => c.dataset.systems);
    } else if (f.type === 'kv') {
      const obj = {};
      for (const r of document.querySelectorAll('.kv-row')) {
        const k = r.querySelector('.kv-key').value.trim();
        if (k) obj[k] = r.querySelector('.kv-val').value;
      }
      out[f.name] = obj;
    } else if (f.type === 'bool') {
      out[f.name] = !!el?.checked;
    } else if (el) {
      out[f.name] = el.value;
    }
  }
  return out;
}

// ─── render ───

function tabs() {
  return `<div class="imp-tabs cols-4">${CATALOG_KEYS.map((k) => `
    <button class="imp-tab${k === S.catalog ? ' on' : ''}" data-catalog="${k}">
      <span class="imp-tab-label">${escHtml(CATALOGS[k].label)}</span>
      <span class="imp-tab-sub">${S.catalog === k ? `${S.rows.length} rows` : 'edit'}</span>
    </button>`).join('')}</div>`;
}

function rowForm(row) {
  const c = cat();
  const isNew = !row;
  return `<div class="cat-form">
    ${c.fields.map((f) => `
      <div class="cat-field">
        <label for="f-${f.name}">${escHtml(f.label)}${f.required ? ' *' : ''}</label>
        ${inputFor(f, row ? row[f.name] : undefined)}
        ${f.help ? `<span class="muted small">${escHtml(f.help)}</span>` : ''}
      </div>`).join('')}
    <div class="cat-form-actions">
      <button class="btn" data-save="${isNew ? 'new' : row.id}">${isNew ? 'Create' : 'Save'}</button>
      <button class="btn btn-ghost" data-cancel>Cancel</button>
      ${!isNew && c.hasSource ? `<span class="muted small">source: ${escHtml(row.source || '—')}</span>` : ''}
    </div>
  </div>`;
}

function render() {
  if (!S.isAdmin) {
    $('app').innerHTML = `<div class="panel"><p class="muted">Admin only.</p></div>`;
    return;
  }
  const c = cat();
  const rows = visibleRows();
  const cats = categoryOptions();

  const list = S.loading
    ? '<p class="muted">Loading…</p>'
    : rows.length
      ? rows.map((r) => S.openId === r.id
        ? `<div class="cat-row open">${rowForm(r)}</div>`
        : `<div class="cat-row" data-edit="${r.id}">
             <span class="slug">${escHtml(r[c.displayField] || '(unnamed)')}</span>
             ${c.uniqueField !== c.displayField
               ? `<code class="cat-key">${escHtml(r[c.uniqueField] || '')}</code>` : ''}
             ${summaryFor(c, r)}
           </div>`).join('')
      : `<p class="muted small">Nothing matches.</p>`;

  $('app').innerHTML = `
  ${tabs()}
  <div class="panel">
    <div class="cat-toolbar">
      <input type="search" id="cat-filter" placeholder="Filter by name or source book…" value="${escHtml(S.filter)}">
      ${cats.length ? `<select id="cat-category">
        <option value="">All categories</option>
        ${cats.map((k) => `<option value="${escHtml(k)}"${k === S.category ? ' selected' : ''}>${escHtml(k)}</option>`).join('')}
      </select>` : ''}
      <span class="muted small">${rows.length} of ${S.rows.length}</span>
      <span style="margin-left:auto; display:flex; gap:6px">
        <button class="btn btn-sm btn-ghost" data-dupes>${S.dupes ? 'Hide duplicates' : 'Find duplicates'}${dupeBadge()}</button>
        <button class="btn btn-sm btn-ghost" data-redirects>${S.redirects ? 'Hide redirects' : 'Redirects'}</button>
        <button class="btn btn-sm" data-new>+ New ${escHtml(c.label.replace(/s$/, ''))}</button>
      </span>
    </div>
    ${S.dupes ? dupePanel() : ''}
    ${S.redirects ? redirectPanel() : ''}
    ${S.msg ? `<p class="${S.msg.error ? 'err' : 'muted'} small">${escHtml(S.msg.text)}</p>` : ''}
    ${S.openId === 'new' ? `<div class="cat-row open">${rowForm(null)}</div>` : ''}
    ${list}
  </div>`;

  wire();
}

// Only the two trustworthy tiers are counted. Measured against the real 138-row
// catalog, `certain` and `likely` produced no false positives while `contains`
// was right about 40% of the time — a badge including it would never reach zero,
// and a badge that never reaches zero teaches you to ignore it.
function dupeBadge() {
  const t = S.dupeCounts;
  if (!t) return '';
  const n = t.certain + t.likely;
  if (!n) return '';
  return ` <span class="dupe-badge" title="${n} likely duplicate pair${n === 1 ? '' : 's'}`
    + `${t.contains ? ` — plus ${t.contains} looser suggestion${t.contains === 1 ? '' : 's'}` : ''}">${n}</span>`;
}

// Suggested duplicate pairs. Every merge is confirmed individually — the
// matcher is deliberately generous, so a false suggestion is expected and
// rejecting one should cost nothing but a glance.
function dupePanel() {
  const c = cat();
  const { pairs, tiers } = S.dupes;
  if (!pairs.length) {
    return `<div class="dupe-panel"><p class="muted small">No likely duplicates in ${escHtml(c.label)}.</p></div>`;
  }

  const numeric = c.fields.filter((f) => f.type === 'int' || f.type === 'real');
  const nums = (row) => numeric.map((f) => `${escHtml(f.label)} ${row[f.name] ?? '—'}`).join(' · ');

  const side = (row, other) => `
    <div class="dupe-side">
      <div class="dupe-name">${escHtml(row[c.displayField] || '(unnamed)')}</div>
      <div class="muted small">${nums(row)}${row.source_book ? ` · ${escHtml(row.source_book)}` : ''}</div>
      <button class="btn btn-sm" data-merge="1" data-keep="${row.id}" data-remove="${other.id}">
        Keep this one</button>
    </div>`;

  const pair = (p) => `
    <div class="dupe-pair${p.same_numbers ? ' strong' : ''}">
      <span class="tag">${escHtml(p.confidence)}</span>
      ${side(p.a, p.b)}
      <span class="dupe-vs">vs</span>
      ${side(p.b, p.a)}
    </div>`;

  // Grouped because the tiers are not equally trustworthy, and one flat list
  // buries the reliable matches among the guesses.
  const group = (list, heading, blurb) => list.length ? `
    <h4 class="dupe-head">${heading} <span class="muted small">— ${list.length}</span></h4>
    <p class="muted small" style="margin:0 0 6px">${blurb}</p>
    ${list.map(pair).join('')}` : '';

  return `
  <div class="dupe-panel">
    <p class="muted small">Merging repoints every character holding the losing name, then deletes that row.
      The retired key is left redirecting here, so class definitions citing it keep resolving — they are
      reported, never rewritten.</p>
    ${group(tiers.certain, 'Same name, different punctuation',
      'Identical once <code>&amp;</code>/<code>and</code>, separators and bracketed qualifiers are ignored.')}
    ${group(tiers.likely, 'Same words, reordered or inflected',
      'Such as <em>Basic Math</em> and <em>Mathematics — Basic</em>.')}
    ${group(tiers.contains, 'One name contains the other',
      'The loosest group and the one to read carefully — <em>Chemistry</em> and <em>Chemistry — Analytical</em> look like this too, and are different skills.')}
  </div>`;
}

// Retired keys and where they now resolve. Removing one is offered because a
// redirect is a claim on a key: while it stands, nothing else can take that
// name back.
function redirectPanel() {
  const c = cat();
  const { redirects } = S.redirects;
  if (!redirects.length) {
    return `<div class="dupe-panel"><p class="muted small">No retired ${escHtml(c.label.toLowerCase())} keys.</p></div>`;
  }

  const row = (r) => `
    <div class="redirect-row${r.target_name === null ? ' broken' : ''}">
      <span class="slug">${escHtml(r.from_key)}</span>
      <span class="muted">→</span>
      <span>${r.target_name === null
        ? '<em class="err">target deleted</em>'
        : escHtml(r.target_name)}</span>
      <span class="tag">${escHtml(r.reason)}</span>
      <button class="btn btn-sm btn-ghost" data-unredirect="${r.id}"
        title="Stop forwarding this key">Remove</button>
    </div>`;

  return `
  <div class="dupe-panel">
    <p class="muted small">Keys that used to name a row here and still resolve, so class definitions
      citing them keep working. Removing one frees the key for reuse and breaks any citation still using it.</p>
    ${redirects.map(row).join('')}
  </div>`;
}

// One row's value, or null when it is not worth a column.
//
// `0` is deliberately NOT empty: a skill's base 0 means non-percentile (W.P.s,
// hand to hand), which is a fact about the skill rather than a missing value.
function summaryValue(f, v) {
  // NULL systems means "both", which is true of nearly every row — printing it
  // 128 times says nothing. Show it only when the row is actually restricted.
  if (f.type === 'systems') return Array.isArray(v) && v.length ? v.join(', ') : null;
  if (f.type === 'bool') return v ? 'yes' : null;
  if (v === null || v === undefined || v === '') return null;

  // Books write damage as a sentence — the JA-11's runs to 140 characters and
  // would swallow the row it is meant to summarise. The whole value is in the
  // edit form, one click away.
  const text = String(v);
  return text.length > 48 ? text.slice(0, 47).trimEnd() + '…' : text;
}

// The four columns worth seeing at a glance — chosen per ROW, not per catalog.
//
// It used to take the first four fields in config order and drop the empties
// among them, which for gear meant slug, system, category and weight: every row
// read "System: rifts" and the numbers you actually scan for — cost, damage,
// A.R., M.D.C. — never appeared at all. Gear is the reason: a rifle, a suit of
// armour and a backpack have almost disjoint useful columns, so no fixed set of
// four can serve them. Taking the first four fields the row actually FILLS
// gives each item its own.
// The unique key is excluded here and rendered separately. On gear it is the
// slug, which is identity rather than a statistic — letting it take one of the
// four slots cost every weapon its damage column.
function summaryFor(c, r) {
  return c.fields
    .filter((f) => f.name !== c.displayField && f.name !== c.uniqueField
                && f.type !== 'longtext' && f.type !== 'kv')
    .map((f) => ({ f, text: summaryValue(f, r[f.name]) }))
    .filter((x) => x.text !== null)
    .slice(0, 4)
    .map(({ f, text }) => `<span class="muted small">${escHtml(f.label)}: ${escHtml(text)}</span>`)
    .join('');
}

function wire() {
  for (const el of document.querySelectorAll('[data-catalog]')) {
    el.addEventListener('click', () => {
      S.catalog = el.dataset.catalog;
      S.filter = ''; S.category = ''; S.openId = null; S.msg = null;
      S.dupes = null;   // suggestions belong to the catalog that produced them
      S.dupeCounts = null;
      S.redirects = null;
      loadRows();
    });
  }

  const filter = $('cat-filter');
  if (filter) filter.addEventListener('input', () => {
    S.filter = filter.value;
    const pos = filter.selectionStart;
    render();
    // Re-rendering replaces the input, so put the caret back or typing jumps.
    const again = $('cat-filter');
    if (again) { again.focus(); again.setSelectionRange(pos, pos); }
  });

  const catSel = $('cat-category');
  if (catSel) catSel.addEventListener('change', () => { S.category = catSel.value; render(); });

  const newBtn = document.querySelector('[data-new]');
  if (newBtn) newBtn.addEventListener('click', () => { S.openId = 'new'; S.msg = null; render(); });

  const dupeBtn = document.querySelector('[data-dupes]');
  if (dupeBtn) dupeBtn.addEventListener('click', () => {
    if (S.dupes) { S.dupes = null; render(); return; }
    loadDuplicates();
  });

  const redirBtn = document.querySelector('[data-redirects]');
  if (redirBtn) redirBtn.addEventListener('click', () => {
    if (S.redirects) { S.redirects = null; render(); return; }
    loadRedirects();
  });

  for (const el of document.querySelectorAll('[data-merge]')) {
    el.addEventListener('click', () => mergePair(+el.dataset.keep, +el.dataset.remove));
  }

  for (const el of document.querySelectorAll('[data-unredirect]')) {
    el.addEventListener('click', () => removeRedirect(+el.dataset.unredirect));
  }

  for (const el of document.querySelectorAll('[data-edit]')) {
    el.addEventListener('click', () => {
      S.openId = parseInt(el.dataset.edit, 10);
      S.msg = null;
      render();
    });
  }

  const cancel = document.querySelector('[data-cancel]');
  if (cancel) cancel.addEventListener('click', () => { S.openId = null; S.msg = null; render(); });

  const save = document.querySelector('[data-save]');
  if (save) save.addEventListener('click', () => saveRow(save.dataset.save));

  const kvAdd = document.querySelector('[data-kv-add]');
  if (kvAdd) kvAdd.addEventListener('click', () => {
    const holder = kvAdd.parentElement;
    const div = document.createElement('div');
    div.className = 'kv-row';
    div.innerHTML = `<input type="text" class="kv-key" placeholder="key">
      <input type="text" class="kv-val" placeholder="value">
      <button type="button" class="btn btn-sm btn-ghost" data-kv-remove>×</button>`;
    holder.insertBefore(div, kvAdd);
    div.querySelector('[data-kv-remove]').addEventListener('click', () => div.remove());
  });
  for (const el of document.querySelectorAll('[data-kv-remove]')) {
    el.addEventListener('click', () => el.closest('.kv-row').remove());
  }
}

async function loadDuplicates() {
  S.dupeBusy = true;
  S.msg = { text: 'Looking for duplicates…' };
  render();
  try {
    S.dupes = await api('catalogs/duplicates?catalog=' + encodeURIComponent(S.catalog));
    S.msg = null;
  } catch (err) {
    S.msg = { text: err.message, error: true };
  }
  S.dupeBusy = false;
  render();
}

async function loadRedirects() {
  S.msg = { text: 'Loading redirects…' };
  render();
  try {
    S.redirects = await api('catalogs/redirects?catalog=' + encodeURIComponent(S.catalog));
    S.msg = null;
  } catch (err) {
    S.msg = { text: err.message, error: true };
  }
  render();
}

async function removeRedirect(id) {
  const r = S.redirects?.redirects.find((x) => x.id === id);
  if (!confirm(`Stop forwarding "${r?.from_key}"?\n\n`
    + `Any class definition still citing it will go back to naming nothing, `
    + `and the key becomes available for a new row.`)) return;

  try {
    await api(`catalogs/redirects?catalog=${encodeURIComponent(S.catalog)}&id=${id}`, { method: 'DELETE' });
    S.msg = { text: `Removed the redirect for "${r?.from_key}".` };
    await loadRedirects();
  } catch (err) {
    S.msg = { text: err.message, error: true };
    render();
  }
}

async function mergePair(keepId, removeId) {
  const keep = S.rows.find((r) => r.id === keepId);
  const remove = S.rows.find((r) => r.id === removeId);
  const label = cat().displayField;
  if (!confirm(`Merge "${remove?.[label]}" into "${keep?.[label]}"?\n\n`
    + `Characters holding "${remove?.[label]}" will be repointed, and that row is deleted. This cannot be undone.`)) return;

  try {
    const res = await api('catalogs/duplicates?catalog=' + encodeURIComponent(S.catalog), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ keep_id: keepId, remove_id: removeId }),
    });
    const bits = [`Merged into "${res.kept.name}".`];
    if (res.repointed.length) bits.push(`${res.repointed.length} character${res.repointed.length === 1 ? '' : 's'} repointed.`);
    if (res.redirected?.length) bits.push(`${res.redirected.map((k) => `"${k}"`).join(' and ')} now redirects here.`);
    // Class markdown is prose plus frontmatter, so it is still never rewritten
    // — but it no longer breaks, because the redirect resolves it. Worth
    // saying, not worth flagging.
    if (res.classes_mentioning.length) {
      bits.push(`Still names the old key: ${res.classes_mentioning.map((c) => c.class_id).join(', ')} (resolves via the redirect).`);
    }
    S.msg = { text: bits.join(' ') };
    await loadRows();          // also refreshes the badge
    await loadDuplicates();
    if (S.redirects) await loadRedirects();
  } catch (err) {
    S.msg = { text: 'Merge failed: ' + err.message, error: true };
    render();
  }
}

async function saveRow(which) {
  const body = collectDraft();
  const isNew = which === 'new';
  const q = 'catalogs/rows?catalog=' + encodeURIComponent(S.catalog) + (isNew ? '' : '&id=' + encodeURIComponent(which));
  try {
    await api(q, {
      method: isNew ? 'POST' : 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    S.openId = null;
    S.msg = { text: isNew ? 'Created.' : 'Saved.' };
    await loadRows();
  } catch (err) {
    S.msg = { text: err.message, error: true };
    render();
  }
}

// ─── boot ───

(async () => {
  try {
    const me = await api('me');
    S.isAdmin = !!me.is_admin;
  } catch { S.isAdmin = false; }
  if (!S.isAdmin) { render(); return; }
  await loadRows();
})();
