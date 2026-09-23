// Marvel Heroes - page entry point.
//
// An ES module. Everything with rules in it lives under js/ as plain functions
// with no DOM access, so apps/marvel-heroes/test/smoke.mjs can import and run
// it in Node. This file is the only one that touches the page.

import { rng, newSeed, d100 } from './js/dice.js';
import { makeFeat } from './js/feat.js';
import { makeBrowser } from './js/browser.js';

export const APP = 'marvel-heroes';

const $ = (sel, root = document) => root.querySelector(sel);
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

async function loadData(...names) {
  const out = {};
  await Promise.all(names.map(async (n) => {
    const res = await fetch(`data/${n}.json`);
    if (!res.ok) throw new Error(`data/${n}.json: ${res.status}`);
    out[n] = await res.json();
  }));
  return out;
}

// ---------------------------------------------------------------- tabs

function initTabs() {
  const tabs = [...document.querySelectorAll('[role="tab"]')];
  const show = (id) => {
    for (const t of tabs) {
      const on = t.dataset.tab === id;
      t.setAttribute('aria-selected', String(on));
      t.tabIndex = on ? 0 : -1;
      $(`#${t.getAttribute('aria-controls')}`).hidden = !on;
    }
    try { localStorage.setItem('mh-tab', id); } catch { /* storage may be blocked */ }
  };
  tabs.forEach((t, i) => {
    t.addEventListener('click', () => show(t.dataset.tab));
    t.addEventListener('keydown', (e) => {
      const d = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
      if (!d) return;
      const next = tabs[(i + d + tabs.length) % tabs.length];
      next.focus();
      show(next.dataset.tab);
    });
  });
  let saved = null;
  try { saved = localStorage.getItem('mh-tab'); } catch { /* ignore */ }
  show(tabs.some((t) => t.dataset.tab === saved) ? saved : tabs[0].dataset.tab);
}

// ---------------------------------------------------------------- FEAT roller

function initFeat(feat) {
  const form = $('#feat-form');
  const rankSel = $('#feat-rank');
  const numIn = $('#feat-number');
  const csOut = $('#feat-cs');
  const actionSel = $('#feat-action');
  const needSel = $('#feat-need');
  const result = $('#feat-result');
  const log = $('#feat-log');
  let cs = 0;
  let next = rng(newSeed());

  rankSel.innerHTML = feat.ladder
    .map((r) => `<option value="${r.id}">${esc(r.name)}${r.standard !== null ? ` (${r.standard})` : ''}</option>`)
    .join('');
  rankSel.value = 'typical';
  actionSel.innerHTML = '<option value="">A general FEAT</option>'
    + feat.actions.map((a) => `<option value="${a.id}">${esc(a.name)} (${esc(a.abbr)})</option>`).join('');

  const drawCs = () => { csOut.textContent = cs === 0 ? '0' : (cs > 0 ? `+${cs}` : String(cs)); };
  $('#feat-cs-down').addEventListener('click', () => { cs = Math.max(-6, cs - 1); drawCs(); });
  $('#feat-cs-up').addEventListener('click', () => { cs = Math.min(6, cs + 1); drawCs(); });
  $('#feat-cs-reset').addEventListener('click', () => { cs = 0; drawCs(); });

  // A typed rank NUMBER picks its rank; picking a rank clears the number.
  numIn.addEventListener('input', () => {
    const id = feat.rankForNumber(Number(numIn.value));
    if (numIn.value !== '' && id) rankSel.value = id;
  });
  rankSel.addEventListener('change', () => { numIn.value = ''; });

  const nameOf = (id) => feat.ladder.find((r) => r.id === id).name;

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const r = feat.roll({ rank: rankSel.value, cs, d100: d100(next), need: needSel.value, action: actionSel.value || null });
    const shifted = r.column !== r.rank ? ` shifted to <strong>${esc(nameOf(r.column))}</strong>` : '';
    result.innerHTML = `
      <div class="feat-roll">${String(r.d100).padStart(2, '0')}</div>
      <div>
        <span class="feat ${r.colour}">${r.colour}</span>
        <span class="verdict ${r.success ? 'ok' : 'no'}">${r.success ? 'Success' : 'Failure'}</span>
        ${r.result ? `<span class="effect">${esc(r.result)}</span>` : ''}
        <p class="muted">${esc(nameOf(r.rank))}${shifted}; needed ${esc(r.need)}.</p>
      </div>`;
    const li = document.createElement('li');
    li.innerHTML = `<span class="feat small ${r.colour}">${r.colour}</span> ${String(r.d100).padStart(2, '0')} on ${esc(nameOf(r.column))}${r.result ? ` - ${esc(r.result)}` : ''}`;
    log.prepend(li);
    while (log.children.length > 10) log.lastElementChild.remove();
  });
  drawCs();
}

// ---------------------------------------------------------------- power browser

// The full text comes from D1 and may not be there: a database built from the
// repo has msh_power_text empty, and the endpoint says so with a 404 carrying
// `missing`. Either way the committed summary is already on screen.
const textCache = new Map();
async function fullText(code) {
  if (textCache.has(code)) return textCache.get(code);
  let out;
  try {
    const res = await fetch(`/api/marvel-heroes/power-text?code=${encodeURIComponent(code)}`, { credentials: 'same-origin' });
    const body = await res.json().catch(() => ({}));
    out = res.ok ? { ok: true, body } : { ok: false, missing: !!body.missing, status: res.status };
  } catch {
    out = { ok: false, missing: false, status: 0 };
  }
  textCache.set(code, out);
  return out;
}

// Book prose arrives as one run of text; break it into paragraphs at the
// sentence boundaries the listings use for their own sub-heads.
// 'shift-x' -> 'Shift X', 'class-1000' -> 'Class 1000': the tables name ranks by id.
const rankLabel = (id) => id.replace(/-/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

const paragraphs = (s) => esc(s).split(/(?<=\.)\s+(?=(?:Power Stunts?|Optional Powers?|Bonus Powers?|The Nemesis|Nemesis|Example|Note)\b)/)
  .map((p) => `<p>${p}</p>`).join('');

function initBrowser(browser, tables) {
  const q = $('#pw-query');
  const cls = $('#pw-class');
  const dbl = $('#pw-double');
  const list = $('#pw-list');
  const count = $('#pw-count');
  const detail = $('#pw-detail');
  const intro = $('#pw-intro');
  const rangeRank = $('#pw-range-rank');

  cls.innerHTML = '<option value="">Every class</option>'
    + browser.classes.map((c) => `<option value="${c.code}">${esc(c.name)} (${c.code})</option>`).join('');
  rangeRank.innerHTML = tables.range.rows
    .map((r) => `<option value="${r.rank}">${esc(rankLabel(r.rank))}</option>`).join('');
  rangeRank.value = 'good';

  let selected = null;

  function draw() {
    const hits = browser.search({ query: q.value, cls: cls.value, doubleOnly: dbl.checked });
    count.textContent = `${hits.length} of ${browser.byCode ? Object.keys(browser.byCode).length : 0} Powers`;
    list.innerHTML = hits.map((p) => `
      <li><button type="button" class="pw-item${p.code === selected ? ' on' : ''}" data-code="${p.code}">
        <span class="code">${p.code}</span> <span class="pw-name">${esc(p.name)}</span>${p.double ? ' <span class="tag" title="Takes two Power slots">x2</span>' : ''}
        <span class="pw-sum">${esc(p.summary)}</span>
      </button></li>`).join('');
    drawIntro();
  }

  async function drawIntro() {
    const c = cls.value;
    intro.hidden = true;
    if (!c) return;
    const r = await fullText(c);
    if (cls.value !== c) return;
    if (r.ok) {
      intro.innerHTML = `<h3>${esc(r.body.name)}</h3>${paragraphs(r.body.body)}<p class="muted">UPB p.${r.body.page}</p>`;
      intro.hidden = false;
    }
  }

  function rangeLine(p) {
    if (!p.range) return '<p class="muted">The listing names no Range Table column.</p>';
    const row = tables.range.rows.find((r) => r.rank === rangeRank.value);
    return `<p>Range column <strong>${p.range}</strong>: at ${esc(rankLabel(rangeRank.value))} rank, <strong>${esc(row[p.range])}</strong>.</p>`;
  }

  async function show(code) {
    selected = code;
    const p = browser.byCode[code];
    for (const b of list.querySelectorAll('.pw-item')) b.classList.toggle('on', b.dataset.code === code);
    const rel = (kind, label) => {
      const items = browser.related(p, kind);
      if (!items.length) return '';
      return `<p><strong>${label}:</strong> ${items.map((x) => (x.code
        ? `<button type="button" class="linklike" data-code="${x.code}">${esc(x.name)} (${x.code})</button>`
        : esc(x.name))).join(', ')}</p>`;
    };
    detail.innerHTML = `
      <span class="caption">${esc(browser.className[p.class])}</span>
      <h2><span class="code">${p.code}</span> ${esc(p.name)}</h2>
      <p class="lead">${esc(p.summary)}</p>
      <p class="muted">UPB p.${p.page}${p.double ? ' &middot; takes two Power slots' : ''}${p.addenda ? ' &middot; rewritten by the <i>Dragon</i> #122 addenda' : ''}</p>
      ${rangeLine(p)}
      ${rel('bonus', 'Bonus')}${rel('optional', 'Optional')}${rel('nemesis', 'Nemesis')}
      <div class="pw-text"><p class="muted">Loading the full text...</p></div>`;
    detail.hidden = false;
    // One column on a phone: the detail sits under the whole list, out of sight.
    if (matchMedia('(max-width: 760px)').matches) detail.scrollIntoView({ block: 'start' });
    const r = await fullText(code);
    if (selected !== code) return;
    const box = $('.pw-text', detail);
    box.innerHTML = r.ok
      ? `<h3>The book's text</h3>${paragraphs(r.body.body)}`
      : `<p class="muted">${r.missing ? 'The full text is not loaded on this server; the summary above is what the app ships.' : 'The full text could not be fetched just now.'}</p>`;
  }

  list.addEventListener('click', (e) => { const b = e.target.closest('[data-code]'); if (b) show(b.dataset.code); });
  detail.addEventListener('click', (e) => { const b = e.target.closest('[data-code]'); if (b) { q.value = ''; cls.value = ''; draw(); show(b.dataset.code); } });
  rangeRank.addEventListener('change', () => { if (selected) show(selected); });
  for (const el of [q, cls, dbl]) el.addEventListener('input', draw);
  draw();
}

// ---------------------------------------------------------------- boot

async function boot() {
  initTabs();
  try {
    const data = await loadData('ranks', 'universal', 'powers', 'power-tables', 'tables');
    initFeat(makeFeat(data.ranks, data.universal));
    initBrowser(makeBrowser(data.powers, data['power-tables']), data.tables);
  } catch (err) {
    $('#load-error').hidden = false;
    $('#load-error').textContent = `The app's data did not load: ${err.message}`;
  }
}

if (typeof document !== 'undefined') boot();
