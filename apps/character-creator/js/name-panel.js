// The 🎲 beside a Name box: a panel of generated names to click into it.
//
// Phase 4 of the NPC / bestiary work (PR 4b, and 4c for the character
// wizard). The names come from the server - GET campaigns/:id/names, which
// leaves out every name the campaign already uses, or GET names on a page with
// no campaign, which leaves out only the chips on screen - so this file holds
// no word lists and makes no names. It holds what
// the G.M. is looking at: the theme, the kind, the gender and shape, the chips
// on screen and which of them are pinned. Nothing is saved; a reload forgets
// the pins, by Nate's decision.
//
// ONE PANEL PER NAME BOX, keyed by the box's id, and at most one open at a
// time. A page draws it with namePanel.slot(id) inside its own render, so the
// panel survives the page repainting itself - the campaign page rebuilds a
// whole tab on most clicks, and state kept in the DOM would be lost each time.
// The panel repaints itself in place, so a click on a chip or a pin does not
// rebuild the page around it.
//
// Refuse, never pad: an exhausted theme shows the server's reason, and the
// chips it did have. Nothing here tops a short list up.
//
// A classic script: escHtml()/escJs() from /shared/js/ui.js, api() from
// js/api.js.
'use strict';

window.namePanel = (function () {
  const LIST = 8;
  const S = {
    host: null,        // { campaignId, system } - campaignId null on the wizard
    meta: null,        // the themes request, once loaded
    loading: false,
    open: null,        // the id of the Name box whose panel is open
    // Per box: its settings and chips. Kept after closing, so reopening a box
    // shows what it showed.
    boxes: {},
  };
  const esc = (s) => escHtml(s == null ? '' : String(s));

  // Called again when the page's game changes (the wizard's system is picked
  // mid-flow): the themes are per game, so a new game reloads them and moves
  // every box back to its default theme.
  function init(host) {
    const was = S.host?.system;
    S.host = host;
    if (was !== undefined && was !== host.system) {
      S.meta = null;
      for (const b of Object.values(S.boxes)) { b.theme = ''; b.shape = ''; b.chips = []; b.pinned = new Set(); }
    }
  }

  async function themes() {
    if (S.meta || S.loading) return S.meta;
    S.loading = true;
    try {
      S.meta = await api(`names/themes?system=${encodeURIComponent(S.host.system || '')}`);
    } finally { S.loading = false; }
    return S.meta;
  }

  // The theme a box starts on: its class's own (a Wolfen gets Wolfen names), or
  // the game's; for a place, the game's places theme.
  function defaultTheme(kind, classes = {}) {
    const m = S.meta;
    if (!m) return '';
    if (kind !== 'person') return m.place_themes[S.host.system] || '';
    return m.class_themes[classes.occ] || m.class_themes[classes.cls]
      || m.system_themes[S.host.system] || m.themes.find((t) => t.kinds.includes('person'))?.id || '';
  }

  // opts: { kinds: ['person'] | 'all', classes: () => ({ cls, occ }) }
  function box(id, opts = {}) {
    if (!S.boxes[id]) {
      S.boxes[id] = { opts, theme: '', kind: 'person', gender: 'any', shape: '', filter: '',
        chips: [], pinned: new Set(), busy: false, reason: '', err: '' };
    }
    S.boxes[id].opts = opts;
    return S.boxes[id];
  }

  const kindsFor = (b) => (b.opts.kinds === 'all' ? S.meta.kinds.map((k) => k.id) : ['person']);
  const themeRow = (id) => S.meta?.themes.find((t) => t.id === id);

  // The 🎲 itself, for the page to put beside its input.
  function button(id, opts = {}) {
    box(id, opts);
    return `<button type="button" class="btn btn-sm btn-ghost namegen-die" title="Suggest names"
      aria-label="Suggest names" aria-expanded="${S.open === id}" onclick="namePanel.toggle('${escJs(id)}')">🎲</button>`;
  }

  // The panel, or nothing, for the page to put under its input's row.
  function slot(id) {
    return `<div id="namepanel-${esc(id)}">${S.open === id ? panelHtml(id) : ''}</div>`;
  }

  function repaint(id) {
    const el = document.getElementById(`namepanel-${id}`);
    if (el) el.innerHTML = S.open === id ? panelHtml(id) : '';
    const die = el?.parentElement?.querySelector(`.namegen-die[onclick*="'${CSS.escape(id)}'"]`);
    if (die) die.setAttribute('aria-expanded', String(S.open === id));
  }

  async function toggle(id) {
    const was = S.open;
    S.open = was === id ? null : id;
    if (was && was !== id) repaint(was);
    repaint(id);
    if (S.open !== id) return;
    const b = box(id, S.boxes[id]?.opts);
    try { await themes(); } catch (err) { b.err = 'Could not load the name themes: ' + err.message; repaint(id); return; }
    if (!b.theme) b.theme = defaultTheme(b.kind, b.opts.classes?.() || {});
    if (!b.chips.length) await generate(id);
    else repaint(id);
  }

  function panelHtml(id) {
    const b = S.boxes[id];
    if (b.err && !S.meta) return `<p class="small err">${esc(b.err)}</p>`;
    if (!S.meta) return '<p class="muted small">Loading name themes…</p>';
    const t = themeRow(b.theme);
    const f = b.filter.trim().toLowerCase();
    const choices = S.meta.themes.filter((x) => x.kinds.includes(b.kind)
      && (!f || x.label.toLowerCase().includes(f) || x.games.some((g) => g.includes(f))
        || x.cultures.some((c) => c.includes(f))));
    const kinds = kindsFor(b);
    const shapes = t?.shapes || [];
    const sid = escJs(id);
    return `<div class="panel-inset namegen-panel" style="margin-top:8px">
      <div class="rowline" style="flex-wrap:wrap">
        ${kinds.length > 1 ? `<label class="small">Kind <select onchange="namePanel.set('${sid}', 'kind', this.value)">
          ${kinds.map((k) => `<option value="${k}"${k === b.kind ? ' selected' : ''}>${
            esc(S.meta.kinds.find((x) => x.id === k)?.label || k)}</option>`).join('')}</select></label>` : ''}
        <label class="small">Theme <select onchange="namePanel.set('${sid}', 'theme', this.value)">
          ${choices.length ? '' : '<option value="">— no theme matches —</option>'}
          ${choices.map((x) => `<option value="${esc(x.id)}"${x.id === b.theme ? ' selected' : ''}>${esc(x.label)}</option>`).join('')}
        </select></label>
        <input type="search" class="picker-input" style="max-width:12em" placeholder="filter: game or culture"
          aria-label="Filter themes by game or culture" value="${esc(b.filter)}"
          onchange="namePanel.set('${sid}', 'filter', this.value)">
      </div>
      ${b.kind === 'person' ? `<div class="rowline" style="flex-wrap:wrap;margin-top:6px">
        <label class="small">Gender <select onchange="namePanel.set('${sid}', 'gender', this.value)">
          ${S.meta.genders.map((g) => `<option value="${g}"${g === b.gender ? ' selected' : ''}>${g}</option>`).join('')}
        </select></label>
        ${shapes.length > 1 ? `<label class="small">Style <select onchange="namePanel.set('${sid}', 'shape', this.value)">
          ${shapes.map((s) => `<option value="${s}"${s === (b.shape || t.default_shape) ? ' selected' : ''}>${
            esc(S.meta.shapes.find((x) => x.id === s)?.label || s)}</option>`).join('')}
        </select></label>` : ''}
      </div>` : ''}
      ${t?.blurb ? `<p class="muted small" style="margin:6px 0 0">${esc(t.blurb)}</p>` : ''}
      <div class="namegen-chips" style="display:flex;flex-wrap:wrap;gap:6px;margin-top:8px">
        ${b.chips.map((n) => chipHtml(id, n)).join('')}
      </div>
      ${b.reason ? `<p class="small warn" style="margin:6px 0 0">${esc(b.reason)}</p>` : ''}
      ${b.err ? `<p class="small err" style="margin:6px 0 0">${esc(b.err)}</p>` : ''}
      <div class="rowline" style="margin-top:8px">
        <button type="button" class="btn btn-sm" onclick="namePanel.generate('${sid}')" ${b.busy || !b.theme ? 'disabled' : ''}>
          ${b.busy ? 'Thinking…' : 'Generate new list'}</button>
        <span class="muted small">${b.pinned.size ? `${b.pinned.size} pinned — kept` : 'pin a name to keep it'}</span>
        <button type="button" class="btn btn-sm btn-ghost" onclick="namePanel.toggle('${sid}')">close</button>
      </div>
    </div>`;
  }

  function chipHtml(id, name) {
    const b = S.boxes[id];
    const on = b.pinned.has(name);
    const sid = escJs(id);
    const sn = escJs(name);
    return `<span class="namegen-chip${on ? ' pinned' : ''}" style="display:inline-flex;align-items:center;gap:2px">
      <button type="button" class="btn btn-sm" title="Use this name" onclick="namePanel.use('${sid}', '${sn}')">${esc(name)}</button>
      <button type="button" class="btn btn-sm btn-ghost" aria-pressed="${on}" title="${on ? 'Unpin' : 'Pin'}"
        aria-label="${on ? 'Unpin' : 'Pin'} ${esc(name)}" onclick="namePanel.pin('${sid}', '${sn}')">${on ? '📌' : '📍'}</button>
    </span>`;
  }

  function set(id, key, value) {
    const b = S.boxes[id];
    b[key] = value;
    // A new kind is a new list: a pinned person has no place among ships. A new
    // theme of the same kind keeps its pins, so two themes can be compared.
    if (key === 'kind') {
      b.theme = defaultTheme(value, b.opts.classes?.() || {}); b.shape = '';
      b.chips = []; b.pinned = new Set();
    }
    if (key === 'theme') b.shape = '';
    if (key === 'filter') {
      const f = value.trim().toLowerCase();
      const first = S.meta.themes.find((x) => x.kinds.includes(b.kind)
        && (!f || x.label.toLowerCase().includes(f) || x.games.some((g) => g.includes(f)) || x.cultures.some((c) => c.includes(f))));
      if (first && !themeRow(b.theme)?.label.toLowerCase().includes(f)) b.theme = first.id;
    }
    // A change of what is being named makes the unpinned chips stale.
    if (key !== 'filter' || b.theme) generate(id);
    else repaint(id);
  }

  // A new list: the pinned chips stay, the rest are sent as `avoid` so the
  // server does not offer them again, and the list is topped back up to eight
  // FROM THE SERVER - never from anywhere else.
  async function generate(id) {
    const b = S.boxes[id];
    if (!b.theme) { repaint(id); return; }
    b.busy = true; b.err = ''; b.reason = '';
    repaint(id);
    const keep = b.chips.filter((n) => b.pinned.has(n));
    const want = Math.max(1, LIST - keep.length);
    const qs = new URLSearchParams({ theme: b.theme, kind: b.kind, count: String(want) });
    if (b.kind === 'person') {
      qs.set('gender', b.gender);
      if (b.shape) qs.set('shape', b.shape);
    }
    for (const n of b.chips) qs.append('avoid', n);
    try {
      // A campaign's list leaves out the names that campaign uses; with no
      // campaign (the wizard) only the chips on screen are left out.
      const res = await api(S.host.campaignId ? `campaigns/${S.host.campaignId}/names?${qs}` : `names?${qs}`);
      b.chips = [...keep, ...res.names];
      b.reason = res.exhausted ? res.reason : '';
    } catch (err) { b.err = err.message; }
    b.busy = false;
    repaint(id);
  }

  function pin(id, name) {
    const b = S.boxes[id];
    if (b.pinned.has(name)) b.pinned.delete(name); else b.pinned.add(name);
    repaint(id);
  }

  // Fill the Name box and tell the page it changed, the way typing would: the
  // forms store a typed name from their own change handlers.
  function use(id, name) {
    const input = document.getElementById(id);
    if (!input) return;
    input.value = name;
    input.dispatchEvent(new Event('change', { bubbles: true }));
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.focus();
  }

  // What the roller sends for "a different name for each": this box's theme,
  // gender and shape, or the class's default theme if the panel was never
  // opened.
  async function batchOptions(id, classes = {}) {
    await themes();
    const b = S.boxes[id];
    const kindOk = !b || b.kind === 'person';
    return {
      name_theme: (kindOk && b?.theme) || defaultTheme('person', classes),
      name_gender: (kindOk && b?.gender) || 'any',
      name_shape: (kindOk && b?.shape) || null,
    };
  }

  // A page's class picker changed: move an untouched box to the new default.
  function classChanged(id, classes) {
    const b = S.boxes[id];
    if (!b || !S.meta || b.kind !== 'person') return;
    const next = defaultTheme('person', classes);
    if (next && next !== b.theme) { b.theme = next; b.shape = ''; b.chips = b.chips.filter((n) => b.pinned.has(n)); }
  }

  return { init, button, slot, toggle, set, generate, pin, use, batchOptions, classChanged, themes };
})();
