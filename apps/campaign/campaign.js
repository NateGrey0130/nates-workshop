// Campaign notes — the note feed, the search box, the people, the handouts,
// the party stash and the currency ledger. escHtml() comes from
// /shared/js/ui.js.
//
// The campaign's own page, which did not exist: the journal was reachable only
// from a character sheet, and nothing showed what the party held collectively.
//
// THE NOTES, PEOPLE, HANDOUTS AND LEDGER ARE SHARED with every game's campaign
// page: /shared/js/campaign/ holds their markup and behaviour, and this app's
// stylesheet styles their `mc-` classes. What stays here is this game's: the
// tabs, the party stash and its gear catalog, the statted NPCs, the name
// generator, and the City Creator's maps.
'use strict';

const campaignId = new URLSearchParams(location.search).get('campaign_id');
const $ = (i) => document.getElementById(i);
const esc = escHtml;
const C = mcCampaign;

const D = {
  campaign: null, isGm: false, isMember: false,
  items: [],
  roster: [], gear: [],
  tab: 'notes',
  // The statted-NPC forms keep their own state in js/npc-sheets.js.
};

// The shared views reach this page through one adapter, so none of them
// imports ui.js or knows how this app asks a question or reports a failure.
// alert() and confirm() are what this page has always used for both.
C.init({
  base: '/api/character-creator', campaignId,
  ui: {
    esc: escHtml, escJs, undoable,
    modal: (text) => Promise.resolve(confirm(text)),
    toast: (text) => alert(text),
  },
  render: () => render(),
  reload: () => load(),
  showPeople: () => { D.tab = 'people'; },
});

async function load() {
  if (!campaignId) {
    // The caller's campaigns rather than an error (UI-AUDIT F39).
    try {
      const list = await campaignList.load();
      $('app').innerHTML = `<div class="panel"><h2>Your campaigns</h2>${campaignList.html(list)}</div>`;
    } catch (err) {
      $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${esc(err.message)}</p></div>`;
    }
    return;
  }
  window.appnav?.setContext({ campaignId });
  try {
    const camp = await api('campaigns/' + campaignId);
    D.campaign = camp.campaign; D.isGm = camp.is_gm; D.isMember = camp.is_member;
    window.appnav?.setContext({ campaignId, campaignName: D.campaign?.name });
    if (D.isGm) namePanel.init({ campaignId, system: D.campaign.system });

    // A non-member gets the campaign's name and nothing else. Everything below
    // this line is member-gated server-side too — this only avoids the
    // requests that would each come back 403.
    if (!D.isMember) return render();

    const [, items, , roster] = await Promise.all([
      C.notes.load(),
      api(`campaigns/${campaignId}/items`),
      C.ledger.load(),
      api(`characters?campaign_id=${campaignId}`),
      C.people.load(),
      C.handouts.load(),
      // The Table: whether one is open, and the sessions it saved. It also
      // saves a table that closed itself, when the G.M. is the one here.
      C.table.load(),
    ]);
    D.items = items.items;
    D.roster = roster.characters;
    // The City Creator's shown maps (Phase 4c), beside the handouts. A failure
    // costs only the list; the rest of the page does not wait on it.
    try { D.cities = (await api(`campaigns/${campaignId}/cities`)).cities || []; } catch { D.cities = []; }
    // Labels for the G.M.'s statted-NPC list: the id-and-name projection, not
    // the full class list, which only loads if the roller is opened.
    if (D.isGm && !D.classNames) {
      try {
        D.classNames = Object.fromEntries((await api('classes?names=1')).classes.map((c) => [c.id, c.name]));
      } catch { D.classNames = {}; }
    }
    render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${esc(err.message)}</p></div>`;
  }
}

// ---------- render ----------
function render() {
  if (!D.isMember) {
    $('app').innerHTML = `<div class="panel">
      <h2>${esc(D.campaign?.name || 'Campaign')}</h2>
      <p class="warn">You are not in this campaign. Notes, the party stash and the ledger are
        readable by its GM and by players who have a character in it.</p>
    </div>`;
    return;
  }
  // Five panels behind the sheet's own `.tabbar`, reused rather than
  // re-styled: 44px targets, its `.tab-n` count pill, and the
  // tablist/tab/aria-selected roles. It sits OUTSIDE the panel, as the sheet's
  // does, because `.tabbar` is sticky and paints itself in --bg-primary —
  // inside a card it would smear the wrong colour on scroll.
  //
  // `campaign-tabs` keeps it VISIBLE ON A DESKTOP. The sheet's bar is hidden
  // above 820px, where the sheet shows every panel at once (styles.css, since
  // 2026-09-01); these panels are never all shown, so without the class a
  // desktop saw Notes and no way to reach the rest. The codex hit the same
  // rule and has `codex-tabs` for the same reason.
  const tabs = [['notes', 'Notes', C.notes.state.total],
                ['people', 'People', C.people.state.npcs.length],
                ['stash', 'Party stash', D.items.filter((i) => !i.removed_at).length],
                ['money', 'Currency', 0],
                ['handouts', 'Handouts', C.handouts.state.handouts.length + (D.cities?.length || 0)]];
  $('app').innerHTML = `
    <div class="panel">
      <h2>${esc(D.campaign.name)} <span class="muted small">(${esc(D.campaign.system)})</span></h2>
    </div>
    ${C.table.html()}
    <nav class="tabbar campaign-tabs" role="tablist">${tabs.map(([k, label, n]) =>
      `<button class="tab${D.tab === k ? ' on' : ''}" role="tab" aria-selected="${D.tab === k}"
         onclick="setTab('${k}')">${esc(label)}${
         n ? ` <span class="tab-n">${n}</span>` : ''}</button>`).join('')}</nav>
    ${D.tab === 'notes' ? C.notes.html()
      : D.tab === 'people' ? peopleView()
      : D.tab === 'stash' ? stashView()
      : D.tab === 'handouts' ? C.handouts.html({ extra: cityMapsHtml() }) : C.ledger.html()}`;
  C.notes.afterRender();
}

function setTab(t) { D.tab = t; C.people.state.npc = null; render(); }

// The City Creator's maps the GM has shown (Phase 4c): a link each to the
// players' view in present mode. The list request sends a player only the
// cities whose map is shown, and only their names.
function cityMapsHtml() {
  if (!D.cities?.length) return '';
  return `<div class="panel">
    <h3 style="margin-top:0">City maps</h3>
    <ul>${D.cities.map((c) => `<li><a href="/apps/gm-tools/present.html?city_id=${c.id}">🗺 ${esc(c.name)}</a>${
      D.isGm && !c.show_map ? ' <span class="muted small">(not shown to the players)</span>' : ''}</li>`).join('')}</ul>
  </div>`;
}

// ---------- people ----------
//
// The roster and the dossiers are the shared view's. This game adds three
// things to it, all the G.M.'s: the 🎲 name generator beside the Name box, the
// statted-NPC panel under the roster, and a dossier's link to its statted
// sheet.
function peopleView() {
  return C.people.html({
    // The 🎲 is the G.M.'s: names come from a G.M.-only request, because the
    // list leaves out the campaign's statted NPCs, which only the G.M. may
    // know exist. A dossier can be a place or a gang, so every kind is offered.
    nameButton: D.isGm ? namePanel.button('npc-name', { kinds: 'all' }) : '',
    nameSlot: D.isGm ? namePanel.slot('npc-name') : '',
    after: D.isGm ? npcSheetsMount() : '',
    dossierExtra: D.isGm ? dossierSheetHtml : null,
  });
}

// ---------- statted NPCs (G.M. only) ----------
//
// The panel - the list, and rolling from a class, placing a notable NPC and
// rolling creatures - is js/npc-sheets.js, shared with GM Tools so there is one
// copy of it. This page mounts it on the People tab and keeps D.roster and
// the dossier list in step with what it changes.
function npcSheetsMount() {
  return npcSheets.mount({
    campaignId, system: D.campaign.system, containerId: 'npc-sheets', classNames: D.classNames,
    roster: D.roster, dossiers: C.people.state.npcs,
    onRoster: (list) => { D.roster = list; },
    onDossiers: (list) => { C.people.state.npcs = list; },
  });
}

// A dossier's statted sheet: only the G.M. sees which NPC sheet stands behind
// a person, or that there is one.
function dossierSheetHtml(n) {
  return `<div class="rowline" style="margin-top:8px">
      <label class="small">Statted sheet <span class="muted">(only you see this)</span>
        <select onchange="linkSheet(${n.id}, this.value)">
          <option value="">— none —</option>
          ${(D.roster || []).filter((c) => c.kind === 'npc').map((c) => `<option value="${c.id}"${n.character_id === c.id ? ' selected' : ''}>${
            esc(c.name)} (level ${c.level})</option>`).join('')}
        </select></label>
      ${n.character_id ? `<a class="btn btn-sm btn-ghost" href="/apps/character-sheet/?id=${n.character_id}">open sheet</a>` : ''}
    </div>`;
}

async function linkSheet(npcId, value) {
  const P = C.people.state;
  try {
    const res = await api(`campaigns/${campaignId}/npcs/${npcId}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ character_id: value ? Number(value) : null }),
    });
    P.npc.npc = res.npc;
    P.npcs = P.npcs.map((x) => (x.id === res.npc.id ? { ...x, character_id: res.npc.character_id } : x));
    render();
  } catch (err) { alert('Failed: ' + err.message); }
}

// ---------- party stash ----------
function stashView() {
  const held = D.items.filter((i) => !i.removed_at);
  const gone = D.items.filter((i) => i.removed_at);
  return `
  <div class="panel">
    <h3>Party stash <span class="muted small">— what the group holds together</span></h3>
    ${held.length ? held.map(stashRow).join('') : '<p class="muted">Nothing in the stash.</p>'}
    <h4 style="margin-top:16px">Add something</h4>
    ${stashGearHtml()}
    <div class="rowline">
      <input type="text" id="stash-name" class="picker-input" placeholder="${D.gear.length ? 'or a custom item' : 'Item name'}">
      <input type="number" id="stash-qty" value="1" min="1" style="width:80px">
      <button class="btn btn-sm" onclick="addStash()">Add</button>
    </div>
    <p class="muted small">Pick from the catalog and a claimed weapon arrives on the sheet as a
      weapon card, with its damage and payload; a custom item arrives as a name. Claiming moves it
      onto a character's sheet and records that it left the stash — the row stays either way. A
      stack can be claimed in part: set how many beside it. To hand something back, use
      <b>to stash</b> on the item's row on the sheet.</p>
    <p id="stash-msg" class="small"></p>
  </div>
  ${gone.length ? `<div class="panel">
    <h3>No longer held <span class="muted small">— kept as history</span></h3>
    ${gone.map((i) => `<p class="small muted">${esc(i.item_name || i.custom_name)}${
      i.qty > 1 ? ` ×${i.qty}` : ''} — ${i.claimed_by_name
        ? `claimed by ${esc(i.claimed_by_name)}` : 'removed'} ${esc((i.removed_at || '').slice(0, 10))}</p>`).join('')}
  </div>` : ''}`;
}

function stashRow(i) {
  const options = D.roster.map((c) => `<option value="${c.id}">${esc(c.name)}</option>`).join('');
  return `<div class="chkrow">
    <span><b>${esc(i.item_name || i.custom_name)}</b>${i.qty > 1 ? ` <span class="tag">×${i.qty}</span>` : ''}
      ${i.notes ? `<span class="muted small"> — ${esc(i.notes)}</span>` : ''}
      <span class="muted small"> added by ${esc(i.added_by)}</span></span>
    <span class="rowline">
      ${i.qty > 1 ? `<input type="number" id="claim-qty-${i.id}" class="claim-qty" min="1" max="${i.qty}"
        value="${i.qty}" aria-label="How many of the ${i.qty} to claim" title="How many to claim">` : ''}
      <select id="claim-${i.id}"><option value="">— claim for —</option>${options}</select>
      <button class="btn btn-sm btn-ghost" onclick="claim(${i.id})">claim</button>
      <button class="btn btn-sm btn-ghost" onclick="dropItem(${i.id})">remove</button>
    </span>
  </div>`;
}

// ---------- the stash's catalog picker (UI-AUDIT F47) ----------
// The stash took free text only, though its endpoint has always accepted a
// gear-catalog id. Free text stays text: a weapon claimed from the stash could
// never become a weapon card, because a card needs the catalog row's damage and
// payload. So the catalog is offered first, and a custom name stays the fallback
// for loot no book lists.
//
// Loaded the first time the stash tab is drawn, for this campaign's system, into
// D.gear - declared on this page from the start and never filled until now. The
// filter rebuilds the select's options in place rather than re-rendering, so the
// caret stays where it was.
const STASH_GEAR_CAP = 300;

function stashGearOptions(q) {
  const hits = Picker.filter(D.gear, q);
  const shown = hits.slice(0, STASH_GEAR_CAP);
  return {
    total: hits.length,
    html: `<option value="">— from the catalog —</option>${shown.map((g) =>
      `<option value="${g.id}">${esc(g.name)}${g.category ? ` (${esc(g.category)})` : ''}</option>`).join('')}`,
  };
}

function stashGearHtml() {
  if (!D.gearLoaded) {
    if (!D.gearLoading && D.campaign) {
      D.gearLoading = true;
      api('items?system=' + encodeURIComponent(D.campaign.system))
        .then((res) => { D.gear = res.items || []; })
        .catch(() => { D.gear = []; })
        .finally(() => { D.gearLoaded = true; D.gearLoading = false; if (D.tab === 'stash') render(); });
    }
    return '<p class="muted small">Loading the gear catalog…</p>';
  }
  if (!D.gear.length) return '';
  const { total, html } = stashGearOptions(D.stashFilter || '');
  return `${Picker.inputHtml({ id: 'stash-filter', value: D.stashFilter || '',
      placeholder: 'Filter the gear catalog by name, category or book…', shown: Math.min(total, STASH_GEAR_CAP), total })}
    <div class="rowline"><select id="stash-gear" style="max-width:100%">${html}</select></div>`;
}

function filterStashGear(q) {
  D.stashFilter = q;
  const { total, html } = stashGearOptions(q);
  const sel = $('stash-gear');
  if (sel) sel.innerHTML = html;
  const count = $('stash-filter')?.parentElement?.querySelector('.pick-count');
  if (count) count.textContent = `${Math.min(total, STASH_GEAR_CAP)} of ${total}`;
}

document.addEventListener('input', (ev) => {
  if (ev.target?.id === 'stash-filter') filterStashGear(ev.target.value);
});

async function addStash() {
  const itemId = parseInt($('stash-gear')?.value, 10) || null;
  const name = ($('stash-name')?.value || '').trim();
  const qty = parseInt($('stash-qty')?.value, 10) || 1;
  if (!itemId && !name) {
    $('stash-msg').textContent = D.gear.length ? 'Pick something from the catalog, or give it a name.' : 'Give it a name.';
    return;
  }
  try {
    await api(`campaigns/${campaignId}/items`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(itemId ? { item_id: itemId, qty } : { custom_name: name, qty }),
    });
    D.stashFilter = '';
    await load();
  } catch (err) { $('stash-msg').textContent = 'Failed: ' + err.message; }
}

async function claim(itemId) {
  const characterId = $('claim-' + itemId)?.value;
  if (!characterId) { alert('Choose which character is taking it.'); return; }
  // A stack offers a count (stashRow); a single item has no box and moves whole.
  const qtyBox = $('claim-qty-' + itemId);
  const qty = qtyBox ? Math.trunc(Number(qtyBox.value)) : null;
  try {
    await api(`campaigns/${campaignId}/items/${itemId}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ claim_for_character_id: Number(characterId), ...(qty ? { qty } : {}) }),
    });
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

// It asked nothing before, and one mis-tap took the party's loot off the list.
// Now it goes with an Undo (js/undo-toast.js); the row is soft-deleted on the
// server either way, and lands under "No longer held" once the window closes.
function dropItem(itemId) {
  const at = D.items.findIndex((i) => i.id === itemId);
  if (at < 0) return;
  const it = D.items[at];
  undoable({
    label: it.item_name || it.custom_name || 'the item',
    hide: () => { D.items = D.items.filter((i) => i.id !== itemId); render(); },
    restore: () => { D.items.splice(Math.min(at, D.items.length), 0, it); render(); },
    commit: async (keepalive) => {
      await api(`campaigns/${campaignId}/items/${itemId}`, { method: 'DELETE', keepalive });
      if (!keepalive) await load();
    },
  });
}

load();
