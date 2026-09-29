// Marvel Heroes - the Campaigns page.
//
// A GM creates a campaign; a player adds one of their saved heroes to it or
// takes it out. The GM reads every linked hero's sheet here, read-only - the
// four play numbers are changed on the GM page, which logs each change - and a
// player reads their own. Nothing here writes to a hero.
//
// Notes, People and Handouts are the shared campaign views
// (shared/js/campaign/), loaded as classic scripts before this module and
// drawn in this app's look: they write mc- classes and no styles, and
// styles.css styles every one. They reach only this group's API, because the
// base passed to them is /api/marvel-heroes. Members only - the GM, or someone
// with a hero here - so a visitor to an open campaign sees the Heroes tab.
//
// ?c=<id> opens a campaign, so a GM can hand the link round the table.

import { api, errorOf } from '../js/api.js';
import { renderSheet, tagline, esc } from '../js/sheet.js';
import { campaignUi } from '../js/campaign-ui.js';

const $ = (sel, root = document) => root.querySelector(sel);
const S = { campaigns: [], myHeroes: null, current: null, detail: null, view: 'heroes', member: false };
const MC = globalThis.mcCampaign;

// ---------------------------------------------------------------- the shared views

function drawView() {
  // The Table's panel is not a tab: it sits above them for every member.
  $('#cd-table').innerHTML = S.member ? MC.table.html() : '';
  const tabs = [...document.querySelectorAll('#cd-tabs [role="tab"]')];
  for (const t of tabs) t.setAttribute('aria-selected', String(t.dataset.view === S.view));
  $('#cd-panel-heroes').hidden = S.view !== 'heroes';
  const box = $('#cd-view');
  box.hidden = S.view === 'heroes';
  if (S.view === 'heroes') return;
  box.setAttribute('aria-labelledby', `cd-tab-${S.view}`);
  box.innerHTML = S.view === 'notes' ? MC.notes.html() : S.view === 'people' ? MC.people.html() : MC.handouts.html();
  if (S.view === 'notes') MC.notes.afterRender();
}

async function loadViews() {
  try {
    await Promise.all([MC.notes.load(), MC.people.load(), MC.handouts.load(), MC.table.load()]);
  } catch (e) { $('#cd-status').textContent = e.message; }
  drawView();
}

function initViews(campaignId) {
  MC.init({
    base: '/api/marvel-heroes', campaignId,
    ui: campaignUi((text) => { $('#cd-status').textContent = text; }),
    render: drawView,
    reload: loadViews,
    showPeople: () => { S.view = 'people'; },
  });
  MC.people.state.npc = null;
  MC.notes.state.results = null;
  MC.notes.state.query = '';
  MC.notes.state.answer = null;
}

function setParam(id) {
  const u = new URL(location.href);
  if (id) u.searchParams.set('c', id); else u.searchParams.delete('c');
  history.replaceState(null, '', u);
}

async function loadList() {
  const r = await api('campaigns');
  if (!r.ok) { $('#load-error').hidden = false; $('#load-error').textContent = errorOf(r); return; }
  S.campaigns = r.data.campaigns;
  drawList();
}

function drawList() {
  const list = $('#camp-list');
  $('#camp-status').textContent = S.campaigns.length ? '' : 'No campaigns yet. Run one below.';
  list.innerHTML = S.campaigns.map((c) => `<li><button type="button" class="hero-item${S.current === c.id ? ' on' : ''}" data-c="${c.id}"
      aria-current="${S.current === c.id ? 'true' : 'false'}">
      <strong>${esc(c.name)}</strong>
      <span class="muted">${c.is_gm ? 'You run it' : `GM ${esc(c.gm_email)}`}; ${c.hero_count} hero${c.hero_count === 1 ? '' : 'es'}${c.open ? '' : '; closed'}${
        c.my_heroes.length ? `; yours: ${c.my_heroes.map((h) => esc(h.name)).join(', ')}` : ''}</span>
    </button></li>`).join('');
}

async function myHeroes() {
  if (S.myHeroes) return S.myHeroes;
  const r = await api('heroes');
  S.myHeroes = r.ok ? r.data.heroes : [];
  return S.myHeroes;
}

async function open(id) {
  S.current = id;
  setParam(id);
  drawList();
  $('#cd-sheet-wrap').hidden = true;
  const r = await api(`campaigns/${id}`);
  if (!r.ok) { $('#camp-detail').hidden = true; $('#camp-status').textContent = errorOf(r); return; }
  S.detail = r.data;
  const { campaign: c, is_gm: gm, heroes } = r.data;
  $('#camp-detail').hidden = false;
  $('#cd-caption').textContent = c.open ? 'Running' : 'Closed';
  $('#cd-name').textContent = c.name;
  $('#cd-description').textContent = c.description || '';
  $('#cd-gm').textContent = gm ? 'You are the GM.' : `GM: ${c.gm_email}`;
  $('#cd-gm-tools').hidden = !gm;
  $('#cd-gm-link').href = `../gm/?c=${c.id}`;
  $('#cd-open').textContent = c.open ? 'Close the campaign' : 'Reopen the campaign';
  $('#cd-status').textContent = '';

  $('#cd-heroes').innerHTML = heroes.length ? heroes.map((h) => `<li class="camp-hero">
      ${h.snapshot ? `<button type="button" class="hero-item" data-hero="${esc(h.id)}"><strong>${esc(h.name)}</strong>
        <span class="muted">${esc(tagline(h.snapshot))}; ${esc(h.owner_email)}</span></button>`
        : `<span class="hero-item"><strong>${esc(h.name)}</strong> <span class="muted">${esc(h.owner_email)}</span></span>`}
      ${gm || h.snapshot ? `<button type="button" class="btn secondary small" data-leave="${esc(h.id)}">Take out</button>` : ''}
    </li>`).join('') : '<li class="muted">Nobody yet.</li>';

  // The join box offers only your heroes not already here; the server is what
  // refuses one already in another open campaign, and says which.
  const mine = await myHeroes();
  const here = new Set(heroes.map((h) => h.id));
  const avail = mine.filter((h) => !here.has(h.id));
  $('#cd-join').hidden = !c.open;
  $('#cd-join-hero').innerHTML = avail.length ? avail.map((h) => `<option value="${esc(h.id)}">${esc(h.name)}</option>`).join('')
    : '<option value="">No hero to add</option>';
  $('#cd-join-btn').disabled = !avail.length;

  // For anyone else the server gives each hero's name only, so a hero arriving
  // with its sheet is one of yours.
  S.member = gm || heroes.some((h) => h.snapshot);
  $('#cd-tabs').hidden = !S.member;
  if (!S.member) S.view = 'heroes';
  if (S.member) { initViews(c.id); await loadViews(); } else drawView();
}

function showSheet(id) {
  const h = S.detail.heroes.find((x) => x.id === id);
  if (!h?.snapshot) return;
  $('#cd-sheet-wrap').hidden = false;
  $('#cd-sheet').innerHTML = renderSheet({ name: h.name, snapshot: h.snapshot, sheet: h.sheet });
  // Read-only here: a player edits on My heroes, a GM changes the play numbers
  // on the GM page, where each change is logged and can be undone.
  for (const el of $('#cd-sheet').querySelectorAll('input, textarea')) el.readOnly = true;
  $('#cd-sheet-note').textContent = S.detail.is_gm
    ? `${h.name}'s sheet, as its player last saved it. Change Health and Karma on the GM page.`
    : `Your sheet, read-only here. Edit it on My heroes.`;
  $('#cd-sheet-wrap').scrollIntoView({ block: 'start' });
}

function wire() {
  $('#cd-tabs').addEventListener('click', (e) => {
    const t = e.target.closest('[data-view]');
    if (!t) return;
    S.view = t.dataset.view;
    drawView();
  });
  $('#camp-list').addEventListener('click', (e) => {
    const b = e.target.closest('[data-c]');
    if (b) open(Number(b.dataset.c));
  });
  $('#cd-heroes').addEventListener('click', async (e) => {
    const s = e.target.closest('[data-hero]');
    if (s) { showSheet(s.dataset.hero); return; }
    const l = e.target.closest('[data-leave]');
    if (!l) return;
    const r = await api(`campaigns/${S.current}/heroes?hero_id=${encodeURIComponent(l.dataset.leave)}`, { method: 'DELETE' });
    $('#cd-status').textContent = r.ok ? 'Taken out.' : errorOf(r);
    await loadList();
    await open(S.current);
  });
  $('#cd-join').addEventListener('submit', async (e) => {
    e.preventDefault();
    const heroId = $('#cd-join-hero').value;
    if (!heroId) return;
    const r = await api(`campaigns/${S.current}/heroes`, { method: 'POST', body: { hero_id: heroId } });
    $('#cd-status').textContent = r.ok ? `${r.data.hero.name} joined.` : errorOf(r);
    await loadList();
    await open(S.current);
    if (!r.ok) $('#cd-status').textContent = errorOf(r);
  });
  $('#cd-open').addEventListener('click', async () => {
    const c = S.detail.campaign;
    const r = await api(`campaigns/${c.id}`, { method: 'PATCH', body: { open: !c.open } });
    await loadList();
    await open(c.id);
    $('#cd-status').textContent = r.ok ? (c.open ? 'Closed. Its heroes are free to join another campaign.' : 'Reopened.') : errorOf(r);
  });
  $('#cd-delete').addEventListener('click', async () => {
    const c = S.detail.campaign;
    if (!confirm(`Delete ${c.name}? Its notes and GM log go with it. The heroes are the players' own and are not touched.`)) return;
    const r = await api(`campaigns/${c.id}`, { method: 'DELETE' });
    if (!r.ok) { $('#cd-status').textContent = errorOf(r); return; }
    S.current = null;
    setParam(null);
    $('#camp-detail').hidden = true;
    await loadList();
  });
  $('#camp-new').addEventListener('submit', async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const r = await api('campaigns', { method: 'POST', body: { name: f.get('name'), description: f.get('description') } });
    $('#camp-new-status').textContent = r.ok ? 'Created.' : errorOf(r);
    if (!r.ok) return;
    e.target.reset();
    await loadList();
    await open(r.data.campaign.id);
  });
}

wire();
await loadList();
const want = Number(new URLSearchParams(location.search).get('c'));
if (want && S.campaigns.some((c) => c.id === want)) await open(want);
