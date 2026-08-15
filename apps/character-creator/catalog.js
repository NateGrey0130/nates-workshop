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
};

const $ = (id) => document.getElementById(id);
const cat = () => CATALOGS[S.catalog];

async function api(path, opts) {
  const res = await fetch('/api/character-creator/' + path, opts);
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(body.error || `Request failed (${res.status})`);
  return body;
}

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
      <span style="margin-left:auto"><button class="btn btn-sm" data-new>+ New ${escHtml(c.label.replace(/s$/, ''))}</button></span>
    </div>
    ${S.msg ? `<p class="${S.msg.error ? 'err' : 'muted'} small">${escHtml(S.msg.text)}</p>` : ''}
    ${S.openId === 'new' ? `<div class="cat-row open">${rowForm(null)}</div>` : ''}
    ${list}
  </div>`;

  wire();
}

// The columns worth seeing at a glance differ per catalog, so they come from
// the config rather than being hardcoded four times.
function summaryFor(c, r) {
  return c.fields
    .filter((f) => f.name !== c.displayField && f.type !== 'longtext' && f.type !== 'kv')
    .slice(0, 4)
    .map((f) => {
      let v = r[f.name];
      if (f.type === 'systems') v = Array.isArray(v) && v.length ? v.join(', ') : 'both';
      return v === null || v === undefined || v === '' ? '' : `<span class="muted small">${escHtml(f.label)}: ${escHtml(v)}</span>`;
    })
    .filter(Boolean).join('');
}

function wire() {
  for (const el of document.querySelectorAll('[data-catalog]')) {
    el.addEventListener('click', () => {
      S.catalog = el.dataset.catalog;
      S.filter = ''; S.category = ''; S.openId = null; S.msg = null;
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
