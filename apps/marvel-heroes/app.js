// Marvel Heroes - page entry point.
//
// An ES module. Everything with rules in it lives under js/ as plain functions
// with no DOM access, so apps/marvel-heroes/test/smoke.mjs can import and run
// it in Node. This file is the only one that touches the page.

import { rng, newSeed, d100 } from './js/dice.js';
import { makeFeat } from './js/feat.js';

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

// ---------------------------------------------------------------- boot

async function boot() {
  initTabs();
  try {
    const data = await loadData('ranks', 'universal');
    initFeat(makeFeat(data.ranks, data.universal));
  } catch (err) {
    $('#load-error').hidden = false;
    $('#load-error').textContent = `The app's data did not load: ${err.message}`;
  }
}

if (typeof document !== 'undefined') boot();
