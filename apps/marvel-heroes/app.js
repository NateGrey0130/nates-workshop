// Marvel Heroes - page entry point.
//
// An ES module. Everything with rules in it lives under js/ as plain functions
// with no DOM access, so apps/marvel-heroes/test/smoke.mjs can import and run
// it in Node. This file is the only one that touches the page.

import { rng, newSeed, d100 } from './js/dice.js';
import { makeFeat } from './js/feat.js';
import { makeBrowser } from './js/browser.js';
import { makeGenerator, newSeeds, STEPS, PRIMARY } from './js/generator.js';
import { snapshot, renderSheet, tagline } from './js/sheet.js';
import { makeGear } from './js/gear.js';

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
    document.dispatchEvent(new CustomEvent('mh-tab', { detail: id }));
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
  // A link can name its tab (#gen, #powers, #feat); otherwise the last one used.
  let saved = location.hash.slice(1) || null;
  if (!tabs.some((t) => t.dataset.tab === saved)) {
    try { saved = localStorage.getItem('mh-tab'); } catch { /* ignore */ }
  }
  // Shown once the rest of the page is wired, so a panel that loads when it is
  // shown (My heroes) hears the first one too.
  return { show, start: () => show(tabs.some((t) => t.dataset.tab === saved) ? saved : tabs[0].dataset.tab) };
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
    // A Slam, Stun or Kill hands the next roll to the target.
    const next2 = feat.followUp(r.result);
    const follow = next2 ? `<p class="follow">The target now makes an Endurance FEAT on the ${esc(next2.name.replace(/\?$/, ''))} column:
        ${feat.ORDER.map((c) => `${c} <strong>${esc(next2.results[c])}</strong>`).join(', ')}.
        <button type="button" class="btn secondary small" data-follow="${next2.id}">Set up that roll</button></p>` : '';
    result.innerHTML = `
      <div class="feat-roll">${String(r.d100).padStart(2, '0')}</div>
      <div>
        <span class="feat ${r.colour}">${r.colour}</span>
        <span class="verdict ${r.success ? 'ok' : 'no'}">${r.success ? 'Success' : 'Failure'}</span>
        ${r.result ? `<span class="effect">${esc(r.result)}</span>` : ''}
        <p class="muted">${esc(nameOf(r.rank))}${shifted}; needed ${esc(r.need)}.</p>
        ${follow}
      </div>`;
    const li = document.createElement('li');
    li.innerHTML = `<span class="feat small ${r.colour}">${r.colour}</span> ${String(r.d100).padStart(2, '0')} on ${esc(nameOf(r.column))}${r.result ? ` - ${esc(r.result)}` : ''}`;
    log.prepend(li);
    while (log.children.length > 10) log.lastElementChild.remove();
  });
  // "Set up that roll": the Effects column chosen, shifts cleared, and the rank
  // left for the TARGET's Endurance, which this page cannot know.
  result.addEventListener('click', (e) => {
    const b = e.target.closest('[data-follow]');
    if (!b) return;
    actionSel.value = b.dataset.follow;
    needSel.value = 'white';
    cs = 0;
    drawCs();
    numIn.value = '';
    rankSel.focus();
    result.insertAdjacentHTML('beforeend', '<p class="muted">Now pick the target\'s Endurance rank and roll; the colour decides the effect.</p>');
    b.disabled = true;
  });
  drawCs();
}

// ---------------------------------------------------------------- gear

// The Player's Book weapon and vehicle tables. A rank cell shows the book's
// abbreviation with the rank's name beside it for anyone who has not learned
// them; anything else shows as printed.
function initGear(gear, equipment) {
  const q = $('#gear-query');
  const grp = $('#gear-group');
  const out = $('#gear-tables');
  const count = $('#gear-count');
  const HEAD = { special_damage: 'Special damage' };
  const head = (c) => HEAD[c] || c.charAt(0).toUpperCase() + c.slice(1);
  const cell = (v) => {
    const r = gear.rankOf(v);
    return r ? `${esc(v)} <span class="muted">${esc(r.name)}</span>` : esc(v ?? '');
  };
  function draw() {
    const hits = gear.search({ query: q.value, group: grp.value });
    const rows = hits.reduce((n, t) => n + t.rows.length, 0);
    count.textContent = `${rows} ${rows === 1 ? 'row' : 'rows'}${q.value.trim() ? ` matching "${q.value.trim()}"` : ''}.`;
    out.innerHTML = hits.map((t) => `
      <section class="panel gear-table">
        <h2>${esc(t.name)} <span class="muted">PB p.${t.page}</span></h2>
        <div class="table-wrap"><table class="abilities gear">
          <thead><tr>${t.columns.map((c) => `<th scope="col">${esc(head(c))}</th>`).join('')}</tr></thead>
          <tbody>${t.rows.map((r) => `<tr>${t.columns.map((c, i) => (i === 0
            ? `<th scope="row">${esc(r[c] ?? '')}${r.notes ? `<span class="gear-note">${esc(r.notes)}</span>` : ''}${r.includes ? `<span class="gear-note">Includes ${esc(r.includes)}</span>` : ''}</th>`
            : `<td>${cell(r[c])}</td>`)).join('')}</tr>`).join('')}</tbody>
        </table></div>
      </section>`).join('') || '<p class="panel muted">Nothing matches.</p>';
  }
  const d = equipment.vehicle_damage;
  $('#gear-damage').innerHTML = `<table class="abilities">
      <thead><tr><th scope="col">Damage against Body</th><th scope="col">Colour</th><th scope="col">Effect</th></tr></thead>
      <tbody>${d.rows.map((r) => `<tr><td>${esc(r.damage)}</td><td>${esc(r.colour)}</td><td>${esc(r.effect)}</td></tr>`).join('')}</tbody></table>
    <p class="muted">PB p.${d.page}.</p>`;
  const keyList = (list) => `<dl class="gear-keys">${list.map((k) => `<dt>${esc(k.key)}</dt><dd>${esc(k.meaning)}</dd>`).join('')}</dl>`;
  $('#gear-keys').innerHTML = `<h3>Weapons</h3>${keyList(equipment.keys.weapons)}<h3>Vehicles</h3>${keyList(equipment.keys.vehicles)}`;
  q.addEventListener('input', draw);
  grp.addEventListener('change', draw);
  draw();
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

// 'shift-x' -> 'Shift X', 'class-1000' -> 'Class 1000': the tables name ranks by id.
const rankLabel = (id) => id.replace(/-/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

// Book prose arrives as one run of text; break it into paragraphs at the
// sentence boundaries the listings use for their own sub-heads.
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

// ---------------------------------------------------------------- saved heroes

// /api/marvel-heroes/heroes. Every call answers { ok, status, body }, so a
// failure is a sentence on the page rather than an exception.
const heroesApi = {
  async call(method, query = '', payload) {
    try {
      const res = await fetch(`/api/marvel-heroes/heroes${query}`, {
        method, credentials: 'same-origin',
        headers: payload ? { 'Content-Type': 'application/json' } : {},
        body: payload ? JSON.stringify(payload) : undefined,
      });
      const body = await res.json().catch(() => ({}));
      return { ok: res.ok, status: res.status, body };
    } catch {
      return { ok: false, status: 0, body: { error: 'The server could not be reached.' } };
    }
  },
  list() { return this.call('GET'); },
  get(id) { return this.call('GET', `?id=${encodeURIComponent(id)}`); },
  save(hero) { return this.call('POST', '', hero); },
  remove(id) { return this.call('DELETE', `?id=${encodeURIComponent(id)}`); },
};
const failure = (r) => r.body?.error || (r.status ? `The server answered ${r.status}.` : 'The server could not be reached.');

// ---------------------------------------------------------------- generator

// Which picks belong to which step: rerolling a step forgets its picks too,
// unless the step is locked.
const STEP_PICKS = {
  body: ['body', 'variant', 'choose', 'aspects'],
  origin: ['origin'],
  abilities: ['ranks', 'choose'],
  weakness: ['weakness'],
  counts: ['bought'],
  powers: ['powers'],
  talents: ['talents'],
};
const LABEL = { fighting: 'Fighting', agility: 'Agility', strength: 'Strength', endurance: 'Endurance',
  reason: 'Reason', intuition: 'Intuition', psyche: 'Psyche', resources: 'Resources', popularity: 'Popularity' };

function initGenerator(gen, data, tabs) {
  const root = $('#gen');
  const rankName = (id) => gen.ladder.find((r) => r.id === id)?.name ?? id;
  const byId = (list, id) => list.find((x) => x.id === id);
  let state = null;

  function fresh() { return { seeds: newSeeds(), picks: {}, locks: {} }; }
  try {
    const saved = JSON.parse(localStorage.getItem('mh-hero') || 'null');
    if (saved?.seeds && STEPS.every((s) => Number.isFinite(saved.seeds[s]))) state = { locks: {}, picks: {}, ...saved };
  } catch { /* a blocked or stale store just means a fresh hero */ }
  if (!state) state = fresh();
  const save = () => { try { localStorage.setItem('mh-hero', JSON.stringify(state)); } catch { /* ignore */ } };
  let built = null;   // what draw() last built, which is what Save saves

  function reroll(step) {
    state.seeds[step] = newSeed();
    for (const k of STEP_PICKS[step]) delete state.picks[k];
    draw();
  }
  function rollAll() {
    for (const s of STEPS) if (!state.locks[s]) {
      state.seeds[s] = newSeed();
      for (const k of STEP_PICKS[s]) delete state.picks[k];
    }
    draw();
  }
  const setPick = (k, v) => {
    if (v === '' || v === null || v === undefined || (Array.isArray(v) && !v.length)) delete state.picks[k];
    else state.picks[k] = v;
    draw();
  };

  const card = (step, title, body, extra = '') => `
    <section class="panel step" data-step="${step}">
      <header class="step-head">
        <h2>${title}</h2>
        <div class="step-tools">
          ${extra}
          <label class="check"><input type="checkbox" data-lock="${step}" ${state.locks[step] ? 'checked' : ''}> Lock</label>
          <button type="button" class="btn secondary small" data-reroll="${step}" ${state.locks[step] ? 'disabled' : ''}>Reroll</button>
        </div>
      </header>
      ${body}
    </section>`;
  const rollNote = (roll) => (roll === null || roll === undefined ? '<span class="tag">picked</span>' : `<span class="muted">rolled ${String(roll).padStart(2, '0')}</span>`);
  const options = (list, sel, label = (x) => x.name, val = (x) => x.id) =>
    list.map((x) => `<option value="${esc(val(x))}" ${val(x) === sel ? 'selected' : ''}>${esc(label(x))}</option>`).join('');

  function draw() {
    const h = gen.build(state);
    built = h;
    save();
    drawSaved();
    const t = gen.typeById[h.body.id];
    const bodyTypes = gen.types;
    // What a trait key means, for a Compound's list of kept traits.
    const traitLabel = (m, k) => {
      const [kind, key] = k.split(':');
      if (kind === 'shift') return `${LABEL[key]} ${m.shift[key] > 0 ? '+' : ''}${m.shift[key]}CS`;
      if (kind === 'set') return `${LABEL[key]} ${rankName(m.set[key])}`;
      if (kind === 'bonus') {
        const bp = m.bonus_powers[Number(key)];
        return bp.code ? `${gen.powerByCode[bp.code].name} (${bp.code})` : `a ${bp.class} Power`;
      }
      if (kind === 'powers') return `${m.powers > 0 ? '+' : ''}${m.powers} Power`;
      if (kind === 'choose') return 'a free +1CS';
      if (kind === 'health') return `Health x${m.health_multiplier}`;
      if (kind === 'contacts') return 'its Contact rule';
      return k;
    };
    const aspectPicker = (i, x) => `<label>${h.body.special === 'compound' ? 'Type' : 'Form'} ${i + 1}
      <select data-aspect="${i}">${options(gen.types.filter((y) => !y.special), x.id)}</select></label>`;
    let aspects = '';
    if (h.body.special) {
      const list = h.body.aspects.map((x, i) => {
        const m = gen.merged(gen.typeById[x.id], x.variant);
        const name = `${esc(m.type.name)}${m.variant ? ` - ${esc(m.variant.name)}` : ''}`;
        if (h.body.special === 'changeling') return `<li><strong>${name}</strong> ${rollNote(x.roll)}</li>`;
        return `<li><strong>${name}</strong> ${rollNote(x.roll)}<br>
          <span class="muted">keeps:</span> ${x.kept.length ? x.kept.map((k) => esc(traitLabel(m, k))).join(', ') : 'nothing'}</li>`;
      }).join('');
      aspects = `
        <p>${h.body.aspects.length} ${h.body.special === 'compound' ? 'body types' : 'forms'}${h.body.countRoll ? ` (rolled ${String(h.body.countRoll).padStart(2, '0')})` : ''}${h.body.special === 'compound' ? `, each trait kept on ${h.body.retain}% or less` : ''}:</p>
        <ol class="notes">${list}</ol>
        <div class="fields">${h.body.aspects.map((x, i) => aspectPicker(i, x)).join('')}</div>`;
    }

    // 1. Physical form
    const variantSel = t.variants
      ? `<label>Kind <select data-pick="variant">${options(t.variants, h.body.variant)}</select></label>` : '';
    const s1 = card('body', '1. Physical form', `
      <div class="fields">
        <label>Body type <select data-pick="body"><option value="">Roll it</option>${options(bodyTypes, state.picks.body)}</select></label>
        ${variantSel}
      </div>
      <p class="big">${esc(h.body.name)}${h.body.variantName ? ` - ${esc(h.body.variantName)}` : ''} ${rollNote(h.body.roll)}</p>
      ${aspects}
      <p class="muted">Rolls abilities on Random Ranks column ${h.body.column}${h.body.special === 'compound' ? ', one per body type (R14)' : h.body.special === 'changeling' ? ', whatever its forms would use' : ''}.</p>
      ${h.body.notes.length ? `<ul class="notes">${h.body.notes.map((n) => `<li>${esc(n)}</li>`).join('')}</ul>` : ''}`);

    // 2. Origin
    const org = byId(data.origins.origins, h.origin.id);
    const s2 = card('origin', '2. Origin of Power', `
      <div class="fields"><label>Origin <select data-pick="origin"><option value="">Roll it</option>${options(data.origins.origins, state.picks.origin)}</select></label></div>
      <p class="big">${esc(org.name)} ${rollNote(h.origin.roll)}</p><p>${esc(org.summary)}</p>`);

    // 3 & 4. Abilities
    const rankOpts = (sel) => `<option value="">Roll</option>${gen.ladder.filter((r) => r.initial !== undefined)
      .map((r) => `<option value="${r.id}" ${r.id === sel ? 'selected' : ''}>${esc(r.name)}</option>`).join('')}`;
    const choose = h.choose;
    const rows = Object.entries(h.abilities).map(([a, v]) => `
      <tr${PRIMARY.includes(a) ? '' : ' class="secondary"'}>
        <th scope="row">${LABEL[a]}</th>
        <td>${v.roll === null ? '<span class="tag">picked</span>' : String(v.roll).padStart(2, '0')}</td>
        <td>${esc(rankName(v.rolled))}</td>
        <td>${v.set ? 'set' : ''}${v.cs ? `${v.cs > 0 ? '+' : ''}${v.cs}CS` : ''}</td>
        <td><strong>${esc(rankName(v.rank))}</strong></td>
        <td class="num">${v.number}</td>
        <td><select data-rank="${a}" aria-label="Pick ${LABEL[a]}">${rankOpts(state.picks.ranks?.[a])}</select></td>
        ${choose ? `<td><input type="checkbox" data-choose="${a}" aria-label="Give ${LABEL[a]} the free +1CS" ${h.chosen.includes(a) ? 'checked' : ''} ${choose.from === 'primary' && !PRIMARY.includes(a) ? 'disabled' : ''}></td>` : ''}
      </tr>`).join('');
    const s3 = card('abilities', '3. Abilities', `
      ${choose ? `<p>${esc(h.body.name)} raises any ${choose.count} ${choose.from === 'primary' ? 'Primary Ability' : 'ability'} +${choose.amount}CS: tick it below.</p>` : ''}
      <div class="table-wrap"><table class="abilities">
        <thead><tr><th>Ability</th><th>Roll</th><th>Rolled</th><th>Body</th><th>Rank</th><th class="num">No.</th><th>Pick</th>${choose ? '<th>+1CS</th>' : ''}</tr></thead>
        <tbody>${rows}</tbody>
      </table></div>
      <p class="secondaries"><span><strong>Health</strong> ${h.health}</span> <span><strong>Karma</strong> ${h.karma}</span></p>
      ${h.forms ? `<h3>Form by form</h3><p class="muted">The table above is the first form. Each form applies its own traits to the same dice.</p>
        <div class="table-wrap"><table class="abilities"><thead><tr><th>Form</th>${PRIMARY.map((k) => `<th>${LABEL[k].slice(0, 3)}</th>`).join('')}<th>Res.</th><th>Pop.</th><th class="num">Health</th><th class="num">Karma</th></tr></thead>
        <tbody>${h.forms.map((f) => `<tr><th scope="row">${esc(f.name)}${f.variantName ? ` (${esc(f.variantName)})` : ''}</th>${[...PRIMARY, 'resources', 'popularity'].map((k) => `<td>${esc(rankName(f.abilities[k].rank))}</td>`).join('')}<td class="num">${f.health}</td><td class="num">${f.karma}</td></tr>`).join('')}</tbody></table></div>` : ''}
      ${h.resourcesBefore !== h.abilities.resources.rank ? `<p class="muted">Resources were ${esc(rankName(h.resourcesBefore))} before buying extras.</p>` : ''}`);

    // 5. Weakness
    const w = data.weakness;
    const wPart = (part, label) => {
      const e = byId(w[part], h.weakness[part].id);
      return `<label>${label} <select data-weak="${part}"><option value="">Roll it</option>${options(w[part], state.picks.weakness?.[part])}</select></label>
        <p><strong>${esc(e.name)}</strong> ${rollNote(h.weakness[part].roll)}<br><span class="muted">${esc(e.summary)}</span></p>`;
    };
    const s5 = card('weakness', '4. Weakness', `
      <div class="fields weak"><div>${wPart('stimulus', 'Stimulus')}</div><div>${wPart('effect', 'Effect')}</div><div>${wPart('duration', 'Duration')}</div></div>
      ${h.fatalMayConvert ? '<p class="note">Every Power is Remarkable or lower, so this Fatal Weakness may be taken as Incapacitation instead.</p>' : ''}`);

    // 6. Powers
    const buy = (kind, cost, label) => {
      const n = h.bought[kind];
      const room = h.slots.max[kind] - h.counts[kind].initial;
      return `<span class="buy">${label}: ${n}
        <button type="button" class="btn secondary small" data-buy="${kind}" data-d="-1" ${n <= 0 ? 'disabled' : ''} aria-label="Buy one fewer ${kind}">-</button>
        <button type="button" class="btn secondary small" data-buy="${kind}" data-d="1" ${n >= room ? 'disabled' : ''} aria-label="Buy one more ${kind}, ${cost}CS Resources">+</button></span>`;
    };
    const pRows = h.powers.map((p) => {
      const d = gen.powerByCode[p.code];
      const src = { body: 'from the body', bonus: `bonus with ${p.of}`, picked: 'picked', rolled: '' }[p.source];
      return `<li>
        <span class="code">${p.code}</span> <strong>${esc(d.name)}</strong>
        - ${esc(rankName(p.rank))} (${gen.numberOf(p.rank)})${p.slots === 2 ? ' <span class="tag">x2</span>' : ''}${src ? ` <span class="muted">${esc(src)}</span>` : ''}
        ${p.source === 'picked' ? `<button type="button" class="linklike" data-unpick="${p.code}">remove</button>` : ''}
        <span class="pw-sum">${esc(d.summary)}</span></li>`;
    }).join('');
    const s6 = card('powers', '5. Powers', `
      <p>Rolled ${h.counts.powers.initial} of a possible ${h.slots.max.powers} (counts roll ${String(h.counts.powers.roll).padStart(2, '0')})${gen.merged(t, h.body.variant).powers ? `, ${gen.merged(t, h.body.variant).powers > 0 ? '+' : ''}${gen.merged(t, h.body.variant).powers} for the body` : ''}: <strong>${h.slots.powers} slots</strong>.</p>
      <p class="buys">${buy('powers', -2, 'Extra Powers')} ${buy('talents', -1, 'Extra Talents')} ${buy('contacts', -1, 'Extra Contacts')}
        <span class="muted">Each extra Power costs -2CS Resources; a Talent or Contact -1CS.</span></p>
      <ol class="powers">${pRows || '<li class="muted">No Powers.</li>'}</ol>
      <form class="add-power" data-add-power><label>Add a Power by code <input name="code" type="text" placeholder="e.g. T21" size="8" autocomplete="off"></label>
        <button type="submit" class="btn secondary small">Add</button></form>`,
      `<label class="check"><input type="checkbox" data-lock="counts" ${state.locks.counts ? 'checked' : ''}> Lock counts</label>
       <button type="button" class="btn secondary small" data-reroll="counts" ${state.locks.counts ? 'disabled' : ''}>Reroll counts</button>`);

    // 7. Talents and Contacts
    const tRows = h.talents.map((x) => {
      const d = byId(data.talents.talents, x.id);
      const g = byId(data.talents.groups, d.group);
      return `<li><strong>${esc(d.name)}</strong> <span class="muted">${esc(g.name)}</span>${x.slots === 2 ? ' <span class="tag">x2</span>' : ''}
        ${x.source === 'picked' ? `<button type="button" class="linklike" data-untalent="${x.id}">remove</button>` : ''}<span class="pw-sum">${esc(d.summary)}</span></li>`;
    }).join('');
    const chosenContacts = state.picks.contacts || [];
    const cSlots = Array.from({ length: h.contacts.slots }, (_, i) => `
      <label>Contact ${i + 1} <select data-contact="${i}"><option value="">Choose later</option>
        ${data.contacts.groups.map((g) => `<optgroup label="${esc(g.name)}">${options(data.contacts.contacts.filter((c) => c.group === g.id), chosenContacts[i])}</optgroup>`).join('')}
      </select></label>`).join('');
    const s7 = card('talents', '6. Talents and Contacts', `
      <p><strong>${h.slots.talents} Talent slots.</strong></p>
      <ol class="powers">${tRows || '<li class="muted">No Talents.</li>'}</ol>
      <div class="fields"><label>Add a Talent <select data-add-talent><option value="">Choose one</option>
        ${data.talents.groups.map((g) => `<optgroup label="${esc(g.name)}">${options(data.talents.talents.filter((x) => x.group === g.id), null)}</optgroup>`).join('')}
      </select></label></div>
      <p><strong>${h.contacts.slots} Contacts</strong> - chosen, not rolled.${h.contacts.rule ? ` <span class="muted">${esc(Object.entries(h.contacts.rule).map(([k, v]) => `${k} ${v}`).join(', '))} for this body type.</span>` : ''}</p>
      <div class="fields">${cSlots}</div>`);

    // The summary, which is also what prints.
    const ab = h.abilities;
    const sum = `
      <section class="panel alt hero-card" aria-label="The hero">
        <span class="caption">Your hero</span>
        <h2>${esc(h.body.name)}${h.body.variantName ? ` (${esc(h.body.variantName)})` : ''} - ${esc(org.name)}</h2>
        <p class="stats">${PRIMARY.map((a) => `<span><b>${LABEL[a][0]}</b> ${esc(rankName(ab[a].rank))} (${ab[a].number})</span>`).join(' ')}</p>
        <p class="stats"><span><b>Health</b> ${h.health}</span> <span><b>Karma</b> ${h.karma}</span>
          <span><b>Resources</b> ${esc(rankName(ab.resources.rank))}</span> <span><b>Popularity</b> ${esc(rankName(ab.popularity.rank))} (${ab.popularity.number})</span></p>
        ${h.body.special ? `<p><b>${h.body.special === 'compound' ? 'Combines' : 'Forms'}:</b> ${h.body.aspects.map((x) => esc(gen.typeById[x.id].name)).join('; ')}</p>` : ''}
        <p><b>Powers:</b> ${h.powers.map((p) => `${esc(gen.powerByCode[p.code].name)} ${esc(rankName(p.rank))}${p.form !== undefined && h.forms ? ` [${esc(h.forms[p.form].name)}]` : ''}`).join('; ') || 'none'}</p>
        <p><b>Talents:</b> ${h.talents.map((x) => esc(byId(data.talents.talents, x.id).name)).join('; ') || 'none'}</p>
        <p><b>Contacts:</b> ${Array.from({ length: h.contacts.slots }, (_, i) => esc(byId(data.contacts.contacts, chosenContacts[i])?.name || 'to choose')).join('; ') || 'none'}</p>
        <p><b>Weakness:</b> ${esc(byId(w.stimulus, h.weakness.stimulus.id).name)}, ${esc(byId(w.effect, h.weakness.effect.id).name)}, ${esc(byId(w.duration, h.weakness.duration.id).name)}</p>
        <p class="muted seeds">Seeds ${STEPS.map((s) => h.seeds[s]).join('-')}</p>
      </section>`;

    // Every change redraws the panel, which would drop keyboard focus to the
    // top of the page (WCAG 2.4.3). Find the control that had focus by its
    // data-* attribute and put focus back on its replacement.
    const had = document.activeElement;
    let again = null;
    if (had && root.contains(had)) {
      const attr = [...had.attributes].find((x) => x.name.startsWith('data-'));
      again = attr ? `[${attr.name}="${CSS.escape(attr.value)}"]` : (had.name ? `[name="${CSS.escape(had.name)}"]` : null);
    }
    // The hero first: at the table the summary is what gets read, and the
    // steps below it are the workshop that made it.
    root.innerHTML = sum + s1 + s2 + s3 + s5 + s6 + s7;
    if (again) root.querySelector(again)?.focus();
    const status = $('#gen-status');
    if (status) status.textContent = `${h.body.name}, ${org.name}: ${h.powers.length} Powers, Health ${h.health}, Karma ${h.karma}.`;
  }

  root.addEventListener('click', (e) => {
    const r = e.target.closest('[data-reroll]');
    if (r) return reroll(r.dataset.reroll);
    const b = e.target.closest('[data-buy]');
    if (b) {
      const bought = { powers: 0, talents: 0, contacts: 0, ...(state.picks.bought || {}) };
      bought[b.dataset.buy] = Math.max(0, bought[b.dataset.buy] + Number(b.dataset.d));
      return setPick('bought', bought);
    }
    const u = e.target.closest('[data-unpick]');
    if (u) return setPick('powers', (state.picks.powers || []).filter((c) => c !== u.dataset.unpick));
    const ut = e.target.closest('[data-untalent]');
    if (ut) return setPick('talents', (state.picks.talents || []).filter((c) => c !== ut.dataset.untalent));
  });
  root.addEventListener('change', (e) => {
    const el = e.target;
    if (el.dataset.lock) { state.locks[el.dataset.lock] = el.checked; return draw(); }
    if (el.dataset.aspect !== undefined) {
      const cur = gen.build(state).body.aspects.map((x) => ({ id: x.id, variant: x.variant }));
      cur[Number(el.dataset.aspect)] = { id: el.value };
      return setPick('aspects', cur);
    }
    if (el.dataset.pick) {
      if (el.dataset.pick === 'body') { delete state.picks.variant; delete state.picks.choose; delete state.picks.aspects; }
      return setPick(el.dataset.pick, el.value);
    }
    if (el.dataset.rank) return setPick('ranks', { ...(state.picks.ranks || {}), [el.dataset.rank]: el.value || undefined });
    if (el.dataset.choose) {
      // The newest tick goes FIRST: the generator keeps the first N it is
      // given, so ticking a second box when only one is allowed moves the +1CS.
      const others = gen.build(state).chosen.filter((a) => a !== el.dataset.choose);
      return setPick('choose', el.checked ? [el.dataset.choose, ...others] : others);
    }
    if (el.dataset.weak) return setPick('weakness', { ...(state.picks.weakness || {}), [el.dataset.weak]: el.value || undefined });
    if (el.dataset.contact !== undefined) {
      const c = [...(state.picks.contacts || [])];
      c[Number(el.dataset.contact)] = el.value || null;
      return setPick('contacts', c);
    }
    if (el.matches('[data-add-talent]') && el.value) return setPick('talents', [...new Set([...(state.picks.talents || []), el.value])]);
  });
  root.addEventListener('submit', (e) => {
    if (!e.target.matches('[data-add-power]')) return;
    e.preventDefault();
    const code = String(new FormData(e.target).get('code') || '').trim();
    const hit = Object.keys(gen.powerByCode).find((c) => c.toLowerCase() === code.toLowerCase());
    if (hit) setPick('powers', [...new Set([...(state.picks.powers || []), hit])]);
  });
  $('#gen-roll').addEventListener('click', rollAll);
  $('#gen-new').addEventListener('click', () => { state = fresh(); saveStatus.textContent = ''; draw(); });

  // Saving. state.saved is the hero this build was opened from or last saved
  // as; Save updates that hero and "Save as a new hero" makes another.
  const saveForm = $('#gen-save');
  const saveStatus = $('#gen-save-status');
  function drawSaved() {
    const s = state.saved;
    $('#gen-save-btn').textContent = s ? 'Save changes' : 'Save hero';
    $('#gen-save-new').hidden = !s;
    if (s && document.activeElement !== saveForm.elements.name) saveForm.elements.name.value = s.name;
  }
  async function saveHero(asNew) {
    const name = saveForm.elements.name.value.trim();
    if (!name) { saveStatus.textContent = 'Give the hero a name first.'; saveForm.elements.name.focus(); return; }
    saveStatus.textContent = 'Saving...';
    const r = await heroesApi.save({
      ...(state.saved && !asNew ? { id: state.saved.id } : {}),
      name,
      build: { seeds: state.seeds, picks: state.picks },
      snapshot: snapshot(built, gen, data, state.picks.contacts || []),
    });
    if (!r.ok) { saveStatus.textContent = `Not saved: ${failure(r)}`; return; }
    state.saved = { id: r.body.id, name };
    save();
    drawSaved();
    saveStatus.textContent = `Saved ${name}. It is on the My heroes tab.`;
  }
  saveForm.addEventListener('submit', (e) => { e.preventDefault(); saveHero(false); });
  $('#gen-save-new').addEventListener('click', () => saveHero(true));
  $('#gen-print').addEventListener('click', () => window.print());
  draw();

  // A saved hero, reopened: its dice and picks, and the hero it saves back to.
  return {
    open(hero) {
      state = { seeds: { ...hero.build.seeds }, picks: { ...hero.build.picks }, locks: {}, saved: { id: hero.id, name: hero.name } };
      draw();
      saveStatus.textContent = `Editing ${hero.name}. Save changes updates it and keeps its sheet.`;
      tabs.show('gen');
    },
    forget(id) {
      if (state.saved?.id !== id) return;
      delete state.saved;
      save();
      drawSaved();
      saveStatus.textContent = '';
    },
  };
}

// ---------------------------------------------------------------- my heroes

function initHeroes(generator) {
  const list = $('#heroes-list');
  const status = $('#heroes-status');
  const wrap = $('#sheet-wrap');
  const sheetEl = $('#sheet');
  const sheetStatus = $('#sheet-status');
  let open = null;       // the hero on the sheet
  let dirty = false;

  async function load() {
    status.textContent = 'Loading...';
    const r = await heroesApi.list();
    if (!r.ok) { status.textContent = `Your heroes could not be loaded: ${failure(r)}`; return; }
    const heroes = r.body.heroes;
    status.textContent = heroes.length ? `${heroes.length} saved.` : 'No heroes saved yet.';
    list.innerHTML = heroes.map((h) => `<li><button type="button" class="hero-item${open?.id === h.id ? ' on' : ''}" data-hero="${esc(h.id)}">
      <strong>${esc(h.name)}</strong> <span class="muted">${esc(tagline(h.snapshot))}</span></button></li>`).join('');
  }

  async function show(id) {
    if (dirty && open && open.id !== id && !confirm(`Leave ${open.name}'s sheet without saving it?`)) return;
    sheetStatus.textContent = 'Loading...';
    const r = await heroesApi.get(id);
    if (!r.ok) { sheetStatus.textContent = failure(r); return; }
    open = r.body.hero;
    dirty = false;
    sheetEl.innerHTML = renderSheet(open);
    wrap.hidden = false;
    sheetStatus.textContent = '';
    for (const b of list.querySelectorAll('.hero-item')) b.classList.toggle('on', b.dataset.hero === id);
    if (matchMedia('(max-width: 760px)').matches) wrap.scrollIntoView({ block: 'start' });
  }

  // What is written on the sheet now, in the shape the endpoint stores.
  function readSheet() {
    const out = {};
    for (const el of sheetEl.querySelectorAll('[data-field]')) if (el.value.trim()) out[el.dataset.field] = el.value;
    for (const el of sheetEl.querySelectorAll('[data-number]')) {
      if (el.value !== '' && Number.isInteger(Number(el.value))) out[el.dataset.number] = Number(el.value);
    }
    return out;
  }

  list.addEventListener('click', (e) => { const b = e.target.closest('[data-hero]'); if (b) show(b.dataset.hero); });
  sheetEl.addEventListener('input', () => { dirty = true; sheetStatus.textContent = 'Changes not saved yet.'; });
  $('#sheet-save').addEventListener('click', async () => {
    if (!open) return;
    sheetStatus.textContent = 'Saving...';
    const sheet = readSheet();
    const r = await heroesApi.save({ id: open.id, name: open.name, build: open.build, snapshot: open.snapshot, sheet });
    if (!r.ok) { sheetStatus.textContent = `Not saved: ${failure(r)}`; return; }
    open.sheet = sheet;
    dirty = false;
    sheetStatus.textContent = 'Saved.';
    load();
  });
  $('#sheet-open-gen').addEventListener('click', () => {
    if (!open) return;
    if (dirty && !confirm('The sheet has changes that are not saved. Open the generator anyway?')) return;
    dirty = false;
    generator.open(open);
  });
  $('#sheet-print').addEventListener('click', () => window.print());
  $('#sheet-delete').addEventListener('click', async () => {
    if (!open || !confirm(`Delete ${open.name}? This cannot be undone.`)) return;
    const r = await heroesApi.remove(open.id);
    if (!r.ok) { sheetStatus.textContent = `Not deleted: ${failure(r)}`; return; }
    const gone = open.name;
    generator.forget(open.id);
    open = null;
    dirty = false;
    wrap.hidden = true;
    await load();
    status.textContent = `Deleted ${gone}. ${status.textContent}`;
  });
  document.addEventListener('mh-tab', (e) => { if (e.detail === 'heroes') load(); });
}

// ---------------------------------------------------------------- boot

async function boot() {
  const tabs = initTabs();
  try {
    const data = await loadData('ranks', 'universal', 'powers', 'power-tables', 'tables', 'random-ranks',
      'body-types', 'origins', 'weakness', 'counts', 'talents', 'contacts', 'equipment');
    initFeat(makeFeat(data.ranks, data.universal));
    initBrowser(makeBrowser(data.powers, data['power-tables']), data.tables);
    initHeroes(initGenerator(makeGenerator(data), data, tabs));
    initGear(makeGear(data.equipment, data.ranks), data.equipment);
  } catch (err) {
    $('#load-error').hidden = false;
    $('#load-error').textContent = `The app's data did not load: ${err.message}`;
  }
  tabs.start();
}

if (typeof document !== 'undefined') boot();
