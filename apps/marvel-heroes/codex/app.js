// Marvel Codex - page entry point, and the only code here that touches the
// page. What the sections are and how a row reads lives in ../js/codex.js as
// a descriptor per section; this file walks that list and draws it.
//
// The address carries the view (?section=&q=&group=&entry=), so a filtered
// list or one open card is a link. It is replaced, not pushed: typing a search
// should not fill the Back button.

import { makeCodex, dataFiles, readState, writeState } from '../js/codex.js';
import { makePowerText, missingNote, paragraphs } from '../js/power-text.js';
import { makeBookText, bookMissingNote, renderParts } from '../js/book-text.js';

const $ = (sel, root = document) => root.querySelector(sel);
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function loadData(names) {
  const out = {};
  await Promise.all(names.map(async (n) => {
    const res = await fetch(`../data/${n}.json`);
    if (!res.ok) throw new Error(`data/${n}.json: ${res.status}`);
    out[n] = await res.json();
  }));
  return out;
}

const fullText = makePowerText();
const bookText = makeBookText();

function init(codex) {
  const tabsEl = $('#codex-tabs');
  const panel = $('#codex-panel');
  const q = $('#codex-query');
  const grp = $('#codex-group');
  const list = $('#codex-list');
  const count = $('#codex-count');
  const intro = $('#codex-intro');

  let state = readState(location.search, codex);
  const open = new Set(state.entry ? [state.entry] : []);
  const sec = () => codex.byId[state.section];

  tabsEl.innerHTML = codex.sections.map((s) => `<button type="button" role="tab" id="tab-${s.id}" data-tab="${s.id}"
      aria-controls="codex-panel">${esc(s.label)}</button>`).join('');
  const tabs = [...tabsEl.querySelectorAll('[role="tab"]')];

  const sync = () => history.replaceState(null, '', location.pathname + writeState(state) + location.hash);

  function drawControls() {
    const s = sec();
    for (const t of tabs) {
      const on = t.dataset.tab === s.id;
      t.setAttribute('aria-selected', String(on));
      t.tabIndex = on ? 0 : -1;
    }
    panel.setAttribute('aria-labelledby', `tab-${s.id}`);
    $('#codex-source').textContent = s.source;
    $('#codex-heading').textContent = s.label;
    $('#codex-group-label').textContent = s.groupLabel;
    grp.innerHTML = `<option value="">Every ${esc(s.groupLabel.toLowerCase())}</option>`
      + s.groups.map((g) => `<option value="${esc(g.id)}">${esc(g.name)}</option>`).join('');
    grp.value = state.group;
    q.value = state.q;
    document.title = `${s.label} - Marvel Codex - Nate's Workshop`;
  }

  const statBlock = (s, r) => {
    const rows = (s.stats ? s.stats(r) : []).filter((x) => x && x[1] !== null && x[1] !== undefined && x[1] !== '');
    return rows.length ? `<dl class="codex-stats">${rows.map(([k, v]) => `<dt>${esc(k)}</dt><dd>${esc(v)}</dd>`).join('')}</dl>` : '';
  };
  const relatedBlock = (s, r) => (s.related ? s.related(r) : []).map(([label, items]) => `<p><strong>${esc(label)}:</strong> ${
    items.map((x) => (x.code
      ? `<button type="button" class="linklike" data-goto="${esc(x.code)}"${x.section ? ` data-goto-section="${esc(x.section)}"` : ''}${
        x.title ? ` title="${esc(x.title)}"` : ''}>${esc(x.name)}${x.plain ? '' : ` (${esc(x.code)})`}</button>`
      : esc(x.name))).join(', ')}</p>`).join('');

  function card(s, r) {
    const key = String(s.key(r));
    const on = open.has(key);
    const tags = (s.tags ? s.tags(r) : []).filter(Boolean);
    const id = `c-${s.id}-${key}`.replace(/[^A-Za-z0-9_-]/g, '_');
    return `<article class="panel codex-card${on ? ' open' : ''}" data-key="${esc(key)}">
      <h2 class="codex-head"><button type="button" aria-expanded="${on}" aria-controls="${id}" data-toggle="${esc(key)}">
        ${s.badge ? `<span class="code">${esc(s.badge(r))}</span> ` : ''}<span class="codex-title">${esc(s.title(r))}</span>
        ${tags.map((t) => `<span class="tag">${esc(t)}</span>`).join(' ')}
      </button></h2>
      <p class="codex-meta muted">${esc(s.meta(r) || '')}</p>
      ${s.summary(r) ? `<p class="codex-sum">${esc(s.summary(r))}</p>` : ''}
      <div class="codex-body" id="${id}" ${on ? '' : 'hidden'}>
        ${statBlock(s, r)}${relatedBlock(s, r)}
        ${s.fullText || s.bookText ? '<div class="codex-text pw-text"><p class="muted">Loading the full text...</p></div>' : ''}
        <p><button type="button" class="btn secondary small" data-link="${esc(key)}">Copy a link to this</button></p>
      </div>
    </article>`;
  }

  // The full text lands after the card is drawn; a card redrawn or closed in
  // the meantime is simply not written to.
  async function fillText(s, r) {
    const key = String(s.key(r));
    if (s.bookText) return fillBookText(s, r, key);
    const res = await fullText(s.fullText(r));
    const el = list.querySelector(`.codex-card[data-key="${CSS.escape(key)}"] .codex-text`);
    if (!el) return;
    el.innerHTML = res.ok ? `<h3>The book's text</h3>${paragraphs(res.body.body)}` : `<p class="muted">${esc(missingNote(res))}</p>`;
  }

  // A sourcebook entry's text: one fetch per version and cross-reference, each
  // under its own heading when there is more than one. A version with no rows
  // says so once; the statistics are already on the card.
  async function fillBookText(s, r, key) {
    const want = s.bookText(r);
    const got = await Promise.all(want.map((w) => bookText(w.book, w.entry)));
    const el = list.querySelector(`.codex-card[data-key="${CSS.escape(key)}"] .codex-text`);
    if (!el) return;
    // nothing to fetch: the book prints no text for it (a chart-only hero, or a
    // Wrecking Crew member whose text is on the team's card)
    if (!want.length) { el.remove(); return; }
    if (!got.some((g) => g.ok)) { el.innerHTML = `<p class="muted">${esc(bookMissingNote(got[0]))}</p>`; return; }
    el.innerHTML = `<h3>The book's text</h3>${want.map((w, i) => (got[i].ok
      ? `${w.label ? `<h4>${esc(w.label)}</h4>` : ''}${renderParts(got[i].body.parts)}`
      : '')).join('')}`;
  }

  async function drawIntro() {
    const s = sec();
    intro.hidden = true;
    if (!s.groupText || !state.group) return;
    const want = `${s.id}:${state.group}`;
    const r = await fullText(s.groupText(state.group));
    if (`${sec().id}:${state.group}` !== want || !r.ok) return;
    intro.innerHTML = `<h2>${esc(r.body.name)}</h2>${paragraphs(r.body.body)}<p class="muted">UPB p.${esc(r.body.page)}</p>`;
    intro.hidden = false;
  }

  function draw() {
    const s = sec();
    const hits = codex.search(s.id, { query: state.q, group: state.group });
    // An entry the filter now hides is not what the address should promise.
    if (state.entry && !hits.some((r) => String(s.key(r)) === state.entry)) state.entry = '';
    count.textContent = `${hits.length} of ${s.rows.length}${state.q.trim() ? ` matching "${state.q.trim()}"` : ''}.`;
    list.innerHTML = hits.map((r) => card(s, r)).join('') || '<p class="panel muted">Nothing matches.</p>';
    if (s.fullText || s.bookText) for (const r of hits) if (open.has(String(s.key(r)))) fillText(s, r);
    drawIntro();
    sync();
  }

  function showSection(id) {
    if (id === state.section) return;
    state = { section: id, q: '', group: '', entry: '' };
    open.clear();
    drawControls();
    draw();
  }

  function toggle(key) {
    const s = sec();
    const r = s.byKey.get(key);
    const el = list.querySelector(`.codex-card[data-key="${CSS.escape(key)}"]`);
    if (!r || !el) return;
    const on = !open.has(key);
    if (on) open.add(key); else open.delete(key);
    el.classList.toggle('open', on);
    $('[data-toggle]', el).setAttribute('aria-expanded', String(on));
    $('.codex-body', el).hidden = !on;
    state.entry = on ? key : (state.entry === key ? '' : state.entry);
    if (on && (s.fullText || s.bookText)) fillText(s, r);
    sync();
  }

  // Open one card with nothing hiding it: a link to an entry clears the filter.
  function goTo(key) {
    state = { ...state, q: '', group: '', entry: key };
    open.add(key);
    drawControls();
    draw();
    const el = list.querySelector(`.codex-card[data-key="${CSS.escape(key)}"]`);
    if (el) { el.scrollIntoView({ block: 'start' }); $('[data-toggle]', el).focus({ preventScroll: true }); }
  }

  tabs.forEach((t, i) => {
    t.addEventListener('click', () => showSection(t.dataset.tab));
    t.addEventListener('keydown', (e) => {
      const d = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
      if (!d) return;
      const next = tabs[(i + d + tabs.length) % tabs.length];
      next.focus();
      showSection(next.dataset.tab);
    });
  });
  q.addEventListener('input', () => { state.q = q.value; draw(); });
  grp.addEventListener('change', () => { state.group = grp.value; draw(); });
  list.addEventListener('click', async (e) => {
    const t = e.target.closest('[data-toggle]');
    if (t) return toggle(t.dataset.toggle);
    const g = e.target.closest('[data-goto]');
    // A link into another section (an NPC's Power, to its UPB card) switches
    // tab first; goTo then opens the card with nothing hiding it.
    if (g) {
      if (g.dataset.gotoSection && codex.byId[g.dataset.gotoSection]) showSection(g.dataset.gotoSection);
      return goTo(g.dataset.goto);
    }
    const l = e.target.closest('[data-link]');
    if (l) {
      const url = new URL(location.href);
      url.search = writeState({ section: state.section, q: '', group: '', entry: l.dataset.link });
      try { await navigator.clipboard.writeText(url.href); l.textContent = 'Link copied'; } catch { l.textContent = 'Copy failed'; }
    }
  });

  drawControls();
  if (state.entry) goTo(state.entry); else draw();
}

loadData(dataFiles())
  .then((data) => init(makeCodex(data)))
  .catch((err) => {
    const box = $('#load-error');
    box.textContent = `The codex could not load its data: ${err.message}`;
    box.hidden = false;
  });
