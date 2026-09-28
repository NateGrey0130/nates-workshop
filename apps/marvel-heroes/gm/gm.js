// Marvel Heroes - GM tools.
//
// Four panels for the GM of one campaign:
//   - the ROSTER: each linked hero's Health, Karma and Karma pool, with - and +.
//     Every press is a PATCH that writes the hero's own row and logs the change
//     (migration 086); Recent changes lists the log and undoes one;
//   - INITIATIVE, by house rule R25 (js/initiative.js): heroes, NPCs and quick
//     entries, a "Talent applies" tick per combatant per round, the roll and the
//     tie-breaker that placed each row, next turn and re-roll all. It lives in
//     this browser (localStorage, one list per campaign) and the room view
//     reads it from there, so the screen turned to the table follows along;
//   - a FEAT roller on the Universal Table (js/feat.js, data/universal.json);
//   - the GM's own notes (msh_campaigns.gm_notes);
//   - the setting: the GM's own pages and their pictures, the shared view
//     (shared/js/campaign/setting.js). A picture revealed there is a handout
//     on the Campaigns page, and Present opens it in present.html;
//   - an NPC roller: the hero generator run on the server with a body type,
//     origin, number of Powers and highest rank, writing a hidden NPC sheet
//     that can join the initiative list.
//
// ?c=<id> opens a campaign.

import { api, errorOf } from '../js/api.js';
import { rng, newSeed, d100 } from '../js/dice.js';
import { makeFeat } from '../js/feat.js';
import { esc, renderSheet, tagline } from '../js/sheet.js';
import { rollInitiative, initiativeTalents } from '../js/initiative.js';
import { campaignUi } from '../js/campaign-ui.js';

const $ = (sel, root = document) => root.querySelector(sel);
const FIELDS = [['health', 'Health'], ['karma', 'Karma'], ['karma_pool', 'Karma pool']];
const G = { campaigns: [], id: null, detail: null, events: [], npcs: [], initTalents: new Set(), init: null };

async function loadData(...names) {
  const out = {};
  await Promise.all(names.map(async (n) => {
    const res = await fetch(`../data/${n}.json`);
    if (!res.ok) throw new Error(`data/${n}.json: ${res.status}`);
    out[n] = await res.json();
  }));
  return out;
}

const fail = (text) => { $('#load-error').hidden = false; $('#load-error').textContent = text; };
const status = (text) => { $('#gm-status').textContent = text; };

// ---------------------------------------------------------------- roster

// The number a hero's sheet holds now: what was written on it, else what the
// hero was built with for Health and Karma, else nothing. The server reads it
// the same way (_lib/campaigns.js currentSql).
function current(h, f) {
  if (Number.isInteger(h.sheet?.[f])) return h.sheet[f];
  if ((f === 'health' || f === 'karma') && Number.isInteger(h.snapshot?.[f])) return h.snapshot[f];
  return 0;
}

function drawRoster() {
  const heroes = G.detail.heroes;
  $('#gm-roster').innerHTML = heroes.length ? heroes.map((h) => `
    <article class="roster-row" aria-label="${esc(h.name)}">
      <div class="roster-who"><strong>${esc(h.name)}</strong><span class="muted">${esc(h.owner_email)}</span></div>
      ${FIELDS.map(([f, label]) => `<div class="roster-num">
        <span class="sh-label">${label}${f === 'health' && Number.isInteger(h.snapshot?.health) ? ` <span class="muted">of ${h.snapshot.health}</span>` : ''}</span>
        <div class="stepper">
          <button type="button" class="btn secondary small" data-hero="${esc(h.id)}" data-f="${f}" data-sign="-1" aria-label="${label} down for ${esc(h.name)}">-</button>
          <output>${current(h, f)}</output>
          <button type="button" class="btn secondary small" data-hero="${esc(h.id)}" data-f="${f}" data-sign="1" aria-label="${label} up for ${esc(h.name)}">+</button>
        </div></div>`).join('')}
    </article>`).join('') : '<p class="muted">No heroes in this campaign yet. Players add them on the Campaigns page.</p>';
}

async function change(heroId, field, delta) {
  const r = await api(`campaigns/${G.id}/heroes/${encodeURIComponent(heroId)}`, { method: 'PATCH', body: { [field]: delta } });
  if (!r.ok) { status(errorOf(r)); return; }
  const i = G.detail.heroes.findIndex((h) => h.id === heroId);
  if (i >= 0) G.detail.heroes[i] = { ...G.detail.heroes[i], ...r.data.hero };
  drawRoster();
  await loadLog();
}

async function loadLog() {
  const r = await api(`campaigns/${G.id}/events`);
  G.events = r.ok ? r.data.events : [];
  const label = Object.fromEntries([...FIELDS, ['advancement', 'Advancement']]);
  $('#gm-log').innerHTML = G.events.length ? G.events.map((e) => `<li class="log-row${e.undone_by ? ' undone' : ''}">
      <span><strong>${esc(e.hero_name)}</strong> ${esc(label[e.field] || e.field)} ${e.delta > 0 ? '+' : ''}${e.delta}
        <span class="muted">${e.before} to ${e.after}${e.undoes ? ', an undo' : ''}${e.undone_by ? ', undone' : ''}</span></span>
      ${!e.undoes && !e.undone_by ? `<button type="button" class="btn secondary small" data-undo="${e.id}">Undo</button>` : ''}
    </li>`).join('') : '<li class="muted">No changes yet.</li>';
}

async function undo(id) {
  const r = await api(`campaigns/${G.id}/events`, { method: 'POST', body: { undo: id } });
  if (!r.ok) { status(errorOf(r)); return; }
  const i = G.detail.heroes.findIndex((h) => h.id === r.data.hero?.id);
  if (i >= 0) G.detail.heroes[i] = { ...G.detail.heroes[i], ...r.data.hero };
  drawRoster();
  await loadLog();
  status('Undone.');
}

// ---------------------------------------------------------------- initiative

const initKey = () => `mh-init-${G.id}`;
const emptyInit = () => ({ round: 1, turn: 0, entries: [], order: null });

function loadInit() {
  try { G.init = JSON.parse(localStorage.getItem(initKey()) || 'null') || emptyInit(); } catch { G.init = emptyInit(); }
}
// Saved on every change, which is also what tells the room view to redraw.
function saveInit() {
  try { localStorage.setItem(initKey(), JSON.stringify(G.init)); } catch { /* storage may be blocked; the list still works */ }
  drawInit();
}

const hasInitTalent = (snapshot) => (snapshot?.talents || []).some((t) => G.initTalents.has(t.id));

function addEntry(e) {
  if (G.init.entries.some((x) => x.key === e.key)) return false;
  G.init.entries.push({ ...e, applies: false });
  G.init.order = null;
  return true;
}

function drawInit() {
  const I = G.init;
  $('#init-round').textContent = `- round ${I.round}`;
  $('#init-roll').textContent = I.order ? 'Re-roll all' : 'Roll the round';
  $('#init-next').disabled = !I.order;
  const rows = I.order ?? I.entries;
  const entry = (key) => I.entries.find((e) => e.key === key);
  $('#init-list').innerHTML = rows.length ? rows.map((r, i) => {
    const e = entry(r.key) || r;
    const on = I.order && i === I.turn;
    const rolled = I.order ? `<span class="init-roll">${String(r.roll).padStart(2, '0')}</span>${r.rerolls.length ? ` <span class="muted">then ${r.rerolls.map((n) => String(n).padStart(2, '0')).join(', ')}</span>` : ''}`
      : '<span class="muted">not rolled</span>';
    return `<li class="init-row${on ? ' on' : ''}"${on ? ' aria-current="true"' : ''}>
      <span class="init-name"><strong>${esc(e.name)}</strong> <span class="muted">Agility ${e.agility}${e.kind === 'npc' ? ', NPC' : ''}</span></span>
      <span class="init-rolled">${rolled} ${(r.tags || []).map((t) => `<span class="tag">${esc(t)}</span>`).join(' ')}</span>
      ${e.talent ? `<label class="check"><input type="checkbox" data-applies="${esc(e.key)}"${e.applies ? ' checked' : ''}> Talent applies</label>`
        : '<span class="muted init-notalent">no initiative Talent</span>'}
      <button type="button" class="btn secondary small" data-drop="${esc(e.key)}" aria-label="Take ${esc(e.name)} out of initiative">Remove</button>
    </li>`;
  }).join('') : '<li class="muted">Nobody yet. Add every hero, an NPC or anyone else below.</li>';
}

function wireInit() {
  $('#init-roll').addEventListener('click', () => {
    if (!G.init.entries.length) return;
    G.init.order = rollInitiative(G.init.entries, rng(newSeed()));
    G.init.turn = 0;
    saveInit();
  });
  // Past the last combatant the round ends: the order goes, and so does every
  // tick, because a Talent applies to one round's circumstances.
  $('#init-next').addEventListener('click', () => {
    if (!G.init.order) return;
    if (G.init.turn + 1 < G.init.order.length) G.init.turn += 1;
    else {
      G.init.round += 1;
      G.init.turn = 0;
      G.init.order = null;
      for (const e of G.init.entries) e.applies = false;
    }
    saveInit();
  });
  $('#init-heroes').addEventListener('click', () => {
    for (const h of G.detail.heroes) {
      addEntry({ key: `hero:${h.id}`, kind: 'hero', name: h.name,
        agility: h.snapshot?.abilities?.agility?.number ?? 0, talent: hasInitTalent(h.snapshot) });
    }
    saveInit();
  });
  $('#init-clear').addEventListener('click', () => {
    if (G.init.entries.length && !confirm('Clear the initiative list?')) return;
    G.init = emptyInit();
    saveInit();
  });
  $('#init-add').addEventListener('submit', (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const name = String(f.get('name') || '').trim();
    if (!name) return;
    addEntry({ key: `quick:${Date.now().toString(36)}:${name}`, kind: 'quick', name,
      agility: Math.max(0, Math.floor(Number(f.get('agility')) || 0)), talent: f.get('talent') === 'on' });
    e.target.reset();
    saveInit();
  });
  $('#init-npc').addEventListener('submit', (e) => {
    e.preventDefault();
    const n = G.npcs.find((x) => String(x.id) === $('#init-npc-pick').value);
    if (!n) return;
    addEntry({ key: `npc:${n.id}`, kind: 'npc', name: n.name,
      agility: n.snapshot?.abilities?.agility?.number ?? 0, talent: hasInitTalent(n.snapshot) });
    saveInit();
  });
  $('#init-list').addEventListener('change', (e) => {
    const box = e.target.closest('[data-applies]');
    if (!box) return;
    const entry = G.init.entries.find((x) => x.key === box.dataset.applies);
    if (entry) entry.applies = box.checked;
    saveInit();
  });
  $('#init-list').addEventListener('click', (e) => {
    const b = e.target.closest('[data-drop]');
    if (!b) return;
    G.init.entries = G.init.entries.filter((x) => x.key !== b.dataset.drop);
    if (G.init.order) {
      const at = G.init.order.findIndex((x) => x.key === b.dataset.drop);
      G.init.order.splice(at, 1);
      if (at < G.init.turn) G.init.turn -= 1;
      if (!G.init.order.length) G.init.order = null;
      else G.init.turn = Math.min(G.init.turn, G.init.order.length - 1);
    }
    saveInit();
  });
}

// ---------------------------------------------------------------- NPCs

// NPC sheets the GM has rolled for this campaign (msh_npc_sheets): listed under
// the roller with show/hide, and offered to the initiative list.
async function loadNpcs() {
  const r = await api(`campaigns/${G.id}/npc-sheets`);
  G.npcs = r.ok ? r.data.npcs : [];
  $('#init-npc').hidden = !G.npcs.length;
  $('#init-npc-pick').innerHTML = G.npcs.map((n) => `<option value="${n.id}">${esc(n.name)}</option>`).join('');
  $('#npc-list').innerHTML = G.npcs.map((n) => `<li class="log-row">
      <span><button type="button" class="linklike" data-npc-show="${n.id}">${esc(n.name)}</button>
        <span class="muted">${esc(tagline(n.snapshot))}; ${n.hidden ? 'hidden' : 'shown to players'}</span></span>
      <span class="row"><button type="button" class="btn secondary small" data-npc-hide="${n.id}" data-hidden="${n.hidden}">${n.hidden ? 'Show' : 'Hide'}</button>
        <button type="button" class="btn secondary small" data-npc-drop="${n.id}" aria-label="Delete ${esc(n.name)}">Delete</button></span>
    </li>`).join('');
}

function showNpc(n) {
  const box = $('#npc-sheet');
  box.hidden = false;
  box.innerHTML = renderSheet({ name: n.name, snapshot: n.snapshot, sheet: n.sheet || {} });
  for (const el of box.querySelectorAll('input, textarea')) el.readOnly = true;
}

function initNpcForm(data) {
  const opt = (list) => '<option value="">Roll it</option>' + list.map((x) => `<option value="${x.id}">${esc(x.name)}</option>`).join('');
  $('#npc-body').innerHTML = opt(data['body-types'].types);
  $('#npc-origin').innerHTML = opt(data.origins.origins);
  $('#npc-ceiling').innerHTML = '<option value="">No limit</option>'
    + data.ranks.ranks.filter((r) => !['shift-0', 'beyond'].includes(r.id)).map((r) => `<option value="${r.id}">${esc(r.name)}</option>`).join('');
  $('#npc-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const f = new FormData(e.target);
    const body = { name: f.get('name'), dossier: f.get('dossier') === 'on' };
    for (const k of ['body', 'origin', 'ceiling']) if (f.get(k)) body[k] = f.get(k);
    if (f.get('powers')) body.powers = Number(f.get('powers'));
    $('#npc-status').textContent = 'Rolling...';
    const r = await api(`campaigns/${G.id}/npcs/generate`, { method: 'POST', body });
    $('#npc-status').textContent = r.ok ? `${r.data.npc.name} rolled${r.data.dossier_id ? ' and added to People' : ''}.` : errorOf(r);
    if (!r.ok) return;
    showNpc({ ...r.data.npc, sheet: {} });
    await loadNpcs();
  });
  $('#npc-list').addEventListener('click', async (e) => {
    const show = e.target.closest('[data-npc-show]');
    if (show) { showNpc(G.npcs.find((n) => String(n.id) === show.dataset.npcShow)); return; }
    const hide = e.target.closest('[data-npc-hide]');
    const drop = e.target.closest('[data-npc-drop]');
    if (!hide && !drop) return;
    const id = (hide || drop).dataset.npcHide || (hide || drop).dataset.npcDrop;
    if (drop && !confirm('Delete this NPC? A People page for it stays, without the stats.')) return;
    const r = hide
      ? await api(`campaigns/${G.id}/npc-sheets?id=${id}`, { method: 'PATCH', body: { hidden: hide.dataset.hidden !== '1' } })
      : await api(`campaigns/${G.id}/npc-sheets?id=${id}`, { method: 'DELETE' });
    $('#npc-status').textContent = r.ok ? '' : errorOf(r);
    await loadNpcs();
  });
}

// ---------------------------------------------------------------- setting

const MC = globalThis.mcCampaign;
const drawSetting = () => { $('#gm-setting').innerHTML = MC.setting.html({ presentHref: 'present.html' }); };
async function loadSetting() { await MC.setting.load(); drawSetting(); }

function initSetting(campaignId) {
  MC.init({
    base: '/api/marvel-heroes', campaignId,
    ui: campaignUi(status),
    render: drawSetting,
    reload: loadSetting,
  });
  MC.setting.state.entry = null;
  MC.setting.state.entryImages = [];
  // Present mode sends the GM back here naming the page it showed.
  const back = Number(new URLSearchParams(location.search).get('entry_id'));
  if (back) MC.setting.open(back);
}

// ---------------------------------------------------------------- FEAT

function initFeat(feat) {
  const rankSel = $('#feat-rank');
  const actionSel = $('#feat-action');
  let cs = 0;
  const next = rng(newSeed());
  rankSel.innerHTML = feat.ladder.map((r) => `<option value="${r.id}">${esc(r.name)}${r.standard !== null ? ` (${r.standard})` : ''}</option>`).join('');
  rankSel.value = 'typical';
  actionSel.innerHTML = '<option value="">A general FEAT</option>'
    + feat.actions.map((a) => `<option value="${a.id}">${esc(a.name)} (${esc(a.abbr)})</option>`).join('');
  const drawCs = () => { $('#feat-cs').textContent = cs === 0 ? '0' : (cs > 0 ? `+${cs}` : String(cs)); };
  $('#feat-cs-down').addEventListener('click', () => { cs = Math.max(-6, cs - 1); drawCs(); });
  $('#feat-cs-up').addEventListener('click', () => { cs = Math.min(6, cs + 1); drawCs(); });
  const nameOf = (id) => feat.ladder.find((r) => r.id === id).name;
  $('#gm-feat').addEventListener('submit', (e) => {
    e.preventDefault();
    const r = feat.roll({ rank: rankSel.value, cs, d100: d100(next), need: $('#feat-need').value, action: actionSel.value || null });
    $('#feat-result').innerHTML = `<div class="feat-roll">${String(r.d100).padStart(2, '0')}</div>
      <div><span class="feat ${r.colour}">${r.colour}</span>
        <span class="verdict ${r.success ? 'ok' : 'no'}">${r.success ? 'Success' : 'Failure'}</span>
        ${r.result ? `<span class="effect">${esc(r.result)}</span>` : ''}
        <p class="muted">${esc(nameOf(r.rank))}${r.column !== r.rank ? ` shifted to ${esc(nameOf(r.column))}` : ''}; needed ${esc(r.need)}.</p></div>`;
  });
  drawCs();
}

// ---------------------------------------------------------------- campaign

async function open(id) {
  G.id = id;
  const u = new URL(location.href);
  u.searchParams.set('c', id);
  history.replaceState(null, '', u);
  $('#gm-room-link').href = `room.html?c=${id}`;
  const r = await api(`campaigns/${id}`);
  if (!r.ok || !r.data.is_gm) { $('#gm-body').hidden = true; status(r.ok ? 'Only the GM of a campaign can open its GM tools.' : errorOf(r)); return; }
  G.detail = r.data;
  $('#gm-body').hidden = false;
  status(r.data.campaign.open ? '' : 'This campaign is closed: reopen it on the Campaigns page to change anyone.');
  $('#gm-notes-text').value = r.data.campaign.gm_notes || '';
  drawRoster();
  loadInit();
  drawInit();
  initSetting(id);
  await Promise.all([loadLog(), loadNpcs(), loadSetting()]);
}

function wire() {
  $('#gm-campaign').addEventListener('change', (e) => open(Number(e.target.value)));
  $('#gm-roster').addEventListener('click', (e) => {
    const b = e.target.closest('[data-hero]');
    if (!b) return;
    const step = Math.max(1, Math.floor(Number($('#gm-step').value) || 1));
    change(b.dataset.hero, b.dataset.f, step * Number(b.dataset.sign));
  });
  $('#gm-log').addEventListener('click', (e) => {
    const b = e.target.closest('[data-undo]');
    if (b) undo(Number(b.dataset.undo));
  });
  $('#gm-notes').addEventListener('submit', async (e) => {
    e.preventDefault();
    const r = await api(`campaigns/${G.id}`, { method: 'PATCH', body: { gm_notes: $('#gm-notes-text').value } });
    $('#gm-notes-status').textContent = r.ok ? 'Saved.' : errorOf(r);
  });
  wireInit();
}

try {
  const data = await loadData('ranks', 'universal', 'talents', 'body-types', 'origins');
  initFeat(makeFeat(data.ranks, data.universal));
  G.initTalents = new Set(initiativeTalents(data.talents));
  initNpcForm(data);
} catch (e) { fail(`The app's tables did not load: ${e.message}`); }
wire();
const list = await api('campaigns');
if (!list.ok) fail(errorOf(list));
G.campaigns = (list.data.campaigns || []).filter((c) => c.is_gm);
$('#gm-none').hidden = G.campaigns.length > 0;
$('#gm-campaign').innerHTML = G.campaigns.map((c) => `<option value="${c.id}">${esc(c.name)}${c.open ? '' : ' (closed)'}</option>`).join('');
const want = Number(new URLSearchParams(location.search).get('c'));
const first = G.campaigns.find((c) => c.id === want) || G.campaigns[0];
if (first) { $('#gm-campaign').value = String(first.id); await open(first.id); }
