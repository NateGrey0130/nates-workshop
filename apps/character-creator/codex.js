// The codex — every spell and psionic power, and what it does.
//
// Read-only by construction: this file makes exactly one request, a GET, and
// has no write path to leave out. That is the point of it being its own page
// rather than the catalog editor unlocked — see functions/.../codex.js and
// docs/plans/20-power-descriptions.md.
//
// A classic script, like sheet.js and js/api.js: it imports nothing, and a
// module would only cost the inline-handler ergonomics for no gain.
//
// Handlers are DELEGATED rather than inline. A row's key is its name, and a
// name with an apostrophe in it — "Ba'al's Blessing" — is exactly the case
// where an inline onclick built by string concatenation breaks: escHtml makes
// it look right in the markup and hands the handler a syntax error. The list
// listens once and reads a data attribute instead.

const S = {
  tab: 'spells',
  filter: '',
  system: '',
  open: new Set(),      // "<tab>:<name>" of the entries showing their text
  spells: [],
  psionics: [],
  loading: true,
  error: null,
};

const $ = (id) => document.getElementById(id);
const rowsFor = (tab) => (tab === 'psionics' ? S.psionics : S.spells);
const keyOf = (r) => S.tab + ':' + String(r.name).toLowerCase();

async function load() {
  try {
    const res = await api('codex');
    S.spells = res.spells || [];
    S.psionics = res.psionics || [];
  } catch (err) {
    S.error = err.message;
  }
  S.loading = false;
  render();
}

// Name and source book, all terms required, order irrelevant — the same rule
// js/picker.js applies in the wizard, so "fire rifts" narrows rather than
// widens. The DESCRIPTION is deliberately not searched: a hit whose reason is
// invisible until you expand the row reads as a bug, and picker.js's comment
// says so about the fields it leaves out.
function visible() {
  const terms = S.filter.trim().toLowerCase().split(/\s+/).filter(Boolean);
  return rowsFor(S.tab).filter((r) => {
    // A NULL system is unrestricted, which is how every picker already reads it.
    if (S.system && r.system && r.system !== 'both' && r.system !== S.system) return false;
    if (!terms.length) return true;
    const hay = `${r.name} ${r.source_book || ''} ${r.category || ''}`.toLowerCase();
    return terms.every((t) => hay.includes(t));
  });
}

// The printed stat block, in the book's own order. Only the fields this row
// actually has: a spell with no area of effect should not print an em dash
// next to one, which is how the sheet's own field rows already behave.
function statBlock(r) {
  const pairs = S.tab === 'spells'
    ? [['Range', r.range], ['Duration', r.duration], ['Damage', r.damage],
       ['Saving throw', r.saving_throw], ['Area of effect', r.area_of_effect],
       ['Casting time', r.casting_time]]
    : [['Range', r.range], ['Duration', r.duration], ['Saving throw', r.saving_throw]];
  const have = pairs.filter(([, v]) => v != null && String(v).trim() !== '');
  if (!have.length) return '';
  return `<dl class="codex-stats">${have
    .map(([k, v]) => `<dt>${escHtml(k)}</dt><dd>${escHtml(v)}</dd>`).join('')}</dl>`;
}

function costOf(r) {
  if (S.tab === 'spells') {
    return r.ppe != null ? `${r.ppe}${r.ppe_note ? '+' : ''} P.P.E.` : '—';
  }
  return r.isp != null ? `${r.isp}${r.isp_note ? '+' : ''} I.S.P.` : '—';
}

function metaOf(r) {
  return S.tab === 'spells'
    ? (r.level != null ? `Level ${r.level}` : 'Unleveled')
    : (r.category || 'Uncategorised');
}

function entry(r) {
  const key = keyOf(r);
  const open = S.open.has(key);
  const text = r.description && String(r.description).trim();
  // A row with no text still lists — its cost and stat block are worth having,
  // and hiding it would make the codex quietly disagree with the pickers about
  // what exists. It says so instead, which is also the visible edge of the 177
  // Book of Magic spells still to be filled in.
  return `<div class="codex-entry${open ? ' open' : ''}">
    <button type="button" class="codex-head" data-key="${escHtml(key)}" aria-expanded="${open}">
      <span class="codex-name">${escHtml(r.name)}</span>
      <span class="codex-meta">${escHtml(metaOf(r))}</span>
      <span class="codex-cost">${escHtml(costOf(r))}</span>
    </button>
    ${open ? `<div class="codex-body">
      ${statBlock(r)}
      ${text ? `<p class="codex-text">${escHtml(r.description)}</p>`
             : '<p class="codex-text muted">No description imported yet.</p>'}
      ${r.ppe_note || r.isp_note ? `<p class="note small">Cost varies — ${escHtml(r.ppe_note || r.isp_note)}</p>` : ''}
      ${r.variant_note ? `<p class="note small">An earlier book prints: ${escHtml(r.variant_note)}</p>` : ''}
      ${r.min_tier ? `<p class="note small">Requires a ${escHtml(r.min_tier)} psychic.</p>` : ''}
      <p class="muted small">${escHtml(r.source_book || 'source not recorded')}</p>
    </div>` : ''}
  </div>`;
}

function render() {
  if (S.loading) { $('app').innerHTML = '<p class="muted">Loading the codex…</p>'; return; }
  if (S.error) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(S.error)}</p></div>`;
    return;
  }

  const shown = visible();
  const total = rowsFor(S.tab).length;
  const withText = shown.filter((r) => r.description && String(r.description).trim()).length;

  $('app').innerHTML = `
    <div class="tabbar codex-tabs">
      <button type="button" class="tab${S.tab === 'spells' ? ' on' : ''}" data-tab="spells">
        Spells <span class="tab-n">${S.spells.length}</span></button>
      <button type="button" class="tab${S.tab === 'psionics' ? ' on' : ''}" data-tab="psionics">
        Psionics <span class="tab-n">${S.psionics.length}</span></button>
    </div>

    <div class="codex-toolbar">
      <input type="search" id="codex-filter" class="pick-filter" placeholder="Filter by name or book…"
        value="${escHtml(S.filter)}" autocomplete="off">
      <select id="codex-system">
        <option value=""${S.system ? '' : ' selected'}>Both systems</option>
        <option value="rifts"${S.system === 'rifts' ? ' selected' : ''}>Rifts</option>
        <option value="palladium-fantasy"${S.system === 'palladium-fantasy' ? ' selected' : ''}>Palladium Fantasy</option>
      </select>
      <span class="muted small">${shown.length} of ${total}${
        shown.length ? ` · ${withText} with text` : ''}</span>
    </div>

    <div class="panel codex-list" id="codex-list">
      ${shown.length ? shown.map(entry).join('')
        : '<p class="muted small">Nothing matches that.</p>'}
    </div>`;

  const box = $('codex-filter');
  // Same caret restoration Picker.wire() does, and for the same reason: this
  // page rebuilds by replacing innerHTML, so an input loses focus and drops the
  // caret to the end mid-keystroke.
  if (S.filterFocused) { box.focus(); box.setSelectionRange(box.value.length, box.value.length); }
}

// ─── one listener for the page, rather than a handler per row ───
document.addEventListener('click', (e) => {
  const tab = e.target.closest('[data-tab]');
  if (tab) { S.tab = tab.dataset.tab; S.filterFocused = false; render(); return; }

  const head = e.target.closest('.codex-head');
  if (head) {
    const key = head.dataset.key;
    if (S.open.has(key)) S.open.delete(key); else S.open.add(key);
    S.filterFocused = false;
    render();
  }
});

document.addEventListener('input', (e) => {
  if (e.target.id === 'codex-filter') { S.filter = e.target.value; S.filterFocused = true; render(); }
});

document.addEventListener('change', (e) => {
  if (e.target.id === 'codex-system') { S.system = e.target.value; S.filterFocused = false; render(); }
});

// A link may arrive pointed at the psionics half.
if (location.hash === '#psionics') S.tab = 'psionics';

load();
