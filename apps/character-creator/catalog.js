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
  // Which existing characters break their class rules. Not catalog-scoped, so it
  // sits above the tabs rather than in the per-catalog toolbar — it is about
  // characters and the classes they were built from, and switching tabs must not
  // look like it re-scoped the answer.
  audit: null,
  auditBusy: false,
  // Offender counts, fetched once on load so a broken character surfaces
  // without anyone thinking to press the button — the duplicate badge's
  // reasoning, applied to characters.
  auditCounts: null,
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
  // The column count follows the catalogue count; hardcoding 4 dropped gear
  // onto a row of its own the day a fifth catalogue was added.
  return `<div class="imp-tabs cols-${CATALOG_KEYS.length}">${CATALOG_KEYS.map((k) => `
    <button class="imp-tab${k === S.catalog ? ' on' : ''}" data-catalog="${k}">
      <span class="imp-tab-label">${escHtml(CATALOGS[k].label)}</span>
      <span class="imp-tab-sub">${S.catalog === k ? `${S.rows.length} rows` : 'edit'}</span>
    </button>`).join('')}</div>`;
}

// The audit bar, above the tabs because the audit is not catalog-scoped.
function auditBar() {
  return `<div class="audit-bar">
    <button class="btn btn-sm btn-ghost" data-audit ${S.auditBusy ? 'disabled' : ''}>
      ${S.audit ? 'Hide character audit' : 'Audit characters'}${auditBadge()}</button>
    <span class="muted small">Which saved characters break the rules of the class they were built from.</span>
  </div>
  ${S.audit ? auditPanel() : ''}`;
}

// Violations block a save; warnings do not. They are kept apart here for the
// same reason the endpoint keeps them apart — a character carrying only warnings
// is legal, and listing the two together would read as a queue of things to fix.
function auditPanel() {
  const a = S.audit;
  const byRule = Object.entries(a.by_rule || {}).sort((x, y) => y[1] - x[1]);

  if (!a.offenders.length && !a.unvalidatable.length) {
    return `<div class="dupe-panel"><p class="muted small">
      All ${a.checked} character${a.checked === 1 ? '' : 's'} match their class rules.</p></div>`;
  }

  const issues = (o) => `
    <ul class="err-list">
      ${o.violations.map((v) => `<li>${escHtml(v.message || v.rule)}</li>`).join('')}
      ${o.warnings.map((v) => `<li class="warn-item">${escHtml(v.message || v.rule)}</li>`).join('')}
    </ul>`;

  // The sheet is where a violation gets resolved, so every offender links to it
  // rather than being reported as an id you then have to go and find.
  const offender = (o) => `
    <div class="audit-row${o.violations.length ? '' : ' warn-only'}">
      <div class="audit-head">
        <a class="dupe-name" href="sheet.html?id=${o.id}">${escHtml(o.name || '(unnamed)')}</a>
        <span class="muted small">${escHtml(o.class_id || '—')} · L${o.level}</span>
        <span class="tag${o.violations.length ? ' ro' : ''}">${
          o.violations.length ? `${o.violations.length} blocking` : `${o.warnings.length} warning${o.warnings.length === 1 ? '' : 's'}`}</span>
      </div>
      ${issues(o)}
    </div>`;

  // A character whose class no longer resolves is not an offender — class
  // soft-delete exists precisely so it keeps working, and the validator skips it.
  const unvalidatable = a.unvalidatable.length ? `
    <h4 class="dupe-head">Not checked <span class="muted small">— ${a.unvalidatable.length}</span></h4>
    <p class="muted small" style="margin:0 0 6px">No class definition resolves for these, so no rule can be
      applied. They load and save normally; this is what retiring a class is supposed to do.</p>
    ${a.unvalidatable.map((u) => `<div class="audit-row">
      <div class="audit-head">
        <a class="dupe-name" href="sheet.html?id=${u.id}">${escHtml(u.name || '(unnamed)')}</a>
        <span class="muted small">${escHtml(u.class_id || '—')}</span>
      </div></div>`).join('')}` : '';

  // Split on the same line the server draws. Everything with a violation OR a
  // warning arrives in one `offenders` list, but only the violations refuse a
  // save — filing a warning-only character under "breaks a rule" would send you
  // to fix something that is already legal.
  const blocked = a.offenders.filter((o) => o.violations.length);
  const warned = a.offenders.filter((o) => !o.violations.length);

  return `
  <div class="dupe-panel">
    <p class="muted small">Read-only. Nothing here is changed or proposed —
      ${a.blocked} of ${a.checked} checked character${a.checked === 1 ? '' : 's'} would be refused on save today,
      ${a.clean} match their class exactly${a.checked < a.total_characters
        ? `, and ${a.total_characters - a.checked} were not reached by this page` : ''}.</p>
    ${byRule.length ? `<p class="small" style="margin:0 0 8px">${byRule.map(([rule, n]) =>
      `<span class="tag">${escHtml(rule)} ×${n}</span>`).join(' ')}</p>` : ''}
    ${blocked.length ? `
      <h4 class="dupe-head">Would be refused on save <span class="muted small">— ${blocked.length}</span></h4>
      <p class="muted small" style="margin:0 0 6px">A rule the class states outright. These load and save
        as they are today; the refusal happens on the next edit that touches skills.</p>
      ${blocked.map(offender).join('')}` : ''}
    ${warned.length ? `
      <h4 class="dupe-head">Worth a look <span class="muted small">— ${warned.length}</span></h4>
      <p class="muted small" style="margin:0 0 6px">Warnings only, so these are legal and save normally.
        A character does not record which choice-group a skill was taken for, so counting by category
        both over- and under-counts — that is why these warn rather than block.</p>
      ${warned.map(offender).join('')}` : ''}
    ${unvalidatable}
  </div>`;
}

function rowForm(row) {
  const c = cat();
  const isNew = !row;
  return `<div class="cat-form">
    ${/* data-type is the width. The config already declares what every field
          is and the write endpoints already validate against it, so the form
          reads its layout off the same word rather than a second list that
          can disagree with it - see .cat-form in styles.css. data-help is
          there because help text is prose in a form of inputs and is what
          actually sets a field's height. */''}
    ${c.fields.map((f) => `
      <div class="cat-field" data-field="${f.name}" data-type="${f.type}"${f.help ? ' data-help' : ''}>
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
        : `<div class="cat-row" role="button" tabindex="0" data-edit="${r.id}">
             <span class="slug">${escHtml(r[c.displayField] || '(unnamed)')}</span>
             ${c.uniqueField !== c.displayField
               ? `<code class="cat-key">${escHtml(r[c.uniqueField] || '')}</code>` : ''}
             ${summaryFor(c, r)}
           </div>`).join('')
      : `<p class="muted small">Nothing matches.</p>`;

  $('app').innerHTML = `
  ${auditBar()}
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
  fitColumns();
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
// A bonuses block, as the reader would say it out loud rather than as it is
// stored. The first row of the skills catalog used to read
// `Bonuses: {"attributes":{"PS":1,"PP":1,"PE":1},"combat":{…` - serialized
// JSON, truncated mid-object, simultaneously unreadable and incomplete, and
// the widest thing in the row.
//
// Same grouping and the same `+` handling as the wizard's race briefing
// (app.js raceBriefing), which is where this shape is already spoken aloud.
// Not shared with it: that one emits `<span class="tag">` chrome for a panel
// and this is plain text for a table cell that summaryValue then truncates.
const POOL_LABELS = { hp: 'H.P.', sdc: 'S.D.C.', mdc: 'M.D.C.', ppe: 'P.P.E.', isp: 'I.S.P.' };

function bonusesSummary(v) {
  let b = v;
  if (typeof b === 'string') { try { b = JSON.parse(b); } catch { return null; } }
  if (!b || typeof b !== 'object') return null;
  const plus = (x) => (typeof x === 'number' && x > 0 ? '+' : '') + [x].flat().join(' & +');
  const bits = [
    ...Object.entries(b.attributes || {}).map(([k, x]) => `${k} ${plus(x)}`),
    ...Object.entries(b.pools || {}).map(([k, x]) => `${POOL_LABELS[k] || k} ${plus(x)}`),
    ...Object.entries(b.combat || {}).map(([k, x]) => `${k.replace(/_/g, ' ')} ${plus(x)}`),
    ...Object.entries(b.saves || {}).map(([k, x]) => `save vs ${k.replace(/_/g, ' ')} ${plus(x)}`),
  ];
  return bits.length ? bits.join(' \u00b7 ') : null;
}

function summaryValue(f, v) {
  // NULL systems means "both", which is true of nearly every row — printing it
  // 128 times says nothing. Show it only when the row is actually restricted.
  if (f.type === 'systems') return Array.isArray(v) && v.length ? v.join(', ') : null;
  if (f.type === 'bool') return v ? 'yes' : null;
  if (f.type === 'bonuses') return bonusesSummary(v);
  if (v === null || v === undefined || v === '') return null;

  // Books write damage as a sentence — the JA-11's runs to 140 characters and
  // would swallow the row it is meant to summarise. The whole value is in the
  // edit form, one click away.
  // Cut at a word boundary, for the same reason the class cards are: a slice
  // mid-word reads as a rendering fault rather than as a summary. Local rather
  // than shared with app.js's copy - this is a table cell at 48 characters and
  // that is a lore paragraph at 110, and the only thing they have in common is
  // three lines of arithmetic.
  const text = String(v).trim();
  if (text.length <= 48) return text;
  const cut = text.slice(0, 48);
  const space = cut.lastIndexOf(' ');
  const kept = space > 28 ? cut.slice(0, space) : text.slice(0, 47);
  return kept.trimEnd().replace(/[,;:—-]+$/, '') + '…';
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

// The collapsed rows line up in columns, and the column widths are MEASURED
// rather than written down. Five catalogs with different fields cannot share
// one set of hand-tuned weights: a template fitted to skills put 99% of its
// rows on one line and only 69% of spells', because `System: palladium-fantasy`
// lands in a track sized for `Base %: 30`.
//
// The 99th percentile, not the maximum. One 300-character outlier would size
// the whole column for the other 606 rows; at p99 the outliers wrap and
// everything else fits. Measured on the rows CURRENTLY RENDERED, so filtering
// to one category re-fits to what is on screen.
//
// Only where the grid applies. Gear and enchantments key on a slug rather than
// a name, and that extra column leaves too little for the rest - fitted, they
// go from 98% single-line to 0% and half again as tall. They keep the flex row
// and the widened container; the CSS excludes them with :not(:has(.cat-key))
// and this returns early on the same test so the two cannot disagree.
const COL_PCT = 0.99;
const COL_GAP = 12;

function fitColumns() {
  const root = document.documentElement;
  const rows = [...document.querySelectorAll('.cat-row:not(.open)')];
  if (!rows.length || rows.some((r) => r.querySelector('.cat-key'))) {
    root.style.removeProperty('--cat-cols');
    return;
  }
  const cv = document.createElement('canvas').getContext('2d');
  const fontOf = (el) => {
    const c = getComputedStyle(el);
    return `${c.fontWeight} ${c.fontSize} ${c.fontFamily}`;
  };
  const pct = (widths) => {
    widths.sort((a, b) => a - b);
    return Math.ceil(widths[Math.min(widths.length - 1, Math.floor(widths.length * COL_PCT))]);
  };
  cv.font = fontOf(rows[0].querySelector('.slug'));
  const name = pct(rows.map((r) => cv.measureText(r.querySelector('.slug').textContent).width));
  const sample = rows.find((r) => r.querySelector('.muted'))?.querySelector('.muted');
  if (!sample) { root.style.removeProperty('--cat-cols'); return; }
  cv.font = fontOf(sample);
  // Four summary slots; the fourth takes the slack, so only three need a width.
  const slots = [0, 1, 2].map((i) => pct(rows.map((r) => {
    const el = r.querySelectorAll('.muted')[i];
    return el ? cv.measureText(el.textContent).width : 0;
  })));
  const cols = [name, ...slots];
  const avail = rows[0].getBoundingClientRect().width - COL_GAP * 4;
  const want = cols.reduce((a, b) => a + b, 0);
  // Leave at least a third of the row for the fourth slot, which is the source
  // book on most rows and the longest thing on any of them.
  const room = avail * 0.66;
  const scale = want > room ? room / want : 1;
  const px = cols.map((w) => Math.max(40, Math.round(w * scale)));
  root.style.setProperty('--cat-cols', `${px.join('px ')}px minmax(0, 1fr)`);
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

  const auditBtn = document.querySelector('[data-audit]');
  if (auditBtn) auditBtn.addEventListener('click', () => {
    if (S.audit) { S.audit = null; render(); return; }
    loadAudit();
  });

  for (const el of document.querySelectorAll('[data-merge]')) {
    el.addEventListener('click', () => mergePair(+el.dataset.keep, +el.dataset.remove));
  }

  for (const el of document.querySelectorAll('[data-unredirect]')) {
    el.addEventListener('click', () => removeRedirect(+el.dataset.unredirect));
  }

  // A catalog row opens into a form IN PLACE, so it cannot be a <button> — the
  // form would end up inside one. It gets the other half instead: role, tab
  // stop, and the two keys a button would have answered to on its own.
  for (const el of document.querySelectorAll('[data-edit]')) {
    const open = () => {
      S.openId = parseInt(el.dataset.edit, 10);
      S.msg = null;
      render();
    };
    el.addEventListener('click', open);
    el.addEventListener('keydown', (ev) => {
      if (ev.key !== 'Enter' && ev.key !== ' ') return;
      ev.preventDefault();     // Space would scroll the list out from under it.
      open();
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

// Validation applies to new writes; characters saved before a rule existed —
// or before a class was corrected against the book — keep loading and saving
// whatever state they are in. Every `fix-*.sql` that rewrites a class can
// retroactively put an existing character out of step with it, and this is the
// only thing that says which. Read-only: it proposes nothing and changes nothing.
// Counts only, once, silently. Failure is a missing hint, not an error worth
// interrupting catalog editing over.
async function loadAuditCounts() {
  try {
    S.auditCounts = await api('admin/audit?counts_only=1');
    render();
  } catch { /* no badge, no complaint */ }
}

function auditBadge() {
  const c = S.auditCounts;
  if (!c) return '';
  const n = c.blocked + c.warned;
  if (!n) return '';
  return ` <span class="dupe-badge" title="${c.blocked} would be refused on save, ${c.warned} worth a look`
    + `${c.unvalidatable ? `, ${c.unvalidatable} unvalidatable` : ''}">${n}</span>`;
}

async function loadAudit() {
  S.auditBusy = true;
  S.msg = { text: 'Auditing characters…' };
  render();
  try {
    S.audit = await api('admin/audit');
    S.msg = null;
  } catch (err) {
    S.msg = { text: err.message, error: true };
  }
  S.auditBusy = false;
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
  loadAuditCounts();
})();
