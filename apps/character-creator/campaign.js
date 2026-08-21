// Campaign notes — the note feed, the search box, the party stash and the
// currency ledger. escHtml() comes from /shared/js/ui.js.
//
// The campaign's own page, which did not exist: the journal was reachable only
// from a character sheet, and nothing showed what the party held collectively.
'use strict';

const campaignId = new URLSearchParams(location.search).get('campaign_id');
const $ = (i) => document.getElementById(i);
const esc = escHtml;

const D = {
  campaign: null, isGm: false, isMember: false,
  entries: [], entriesTotal: 0,
  items: [], balances: [], ledger: [],
  roster: [], gear: [],
  // Search is a separate view over the same feed rather than a filter of it:
  // results are ranked and snippetted, and pretending that is the same list
  // would mean the feed sometimes silently reorders itself.
  query: '', results: null, searching: false,
  // The answer to the last question asked, and whether one is in flight. Kept
  // beside the search box because that is where the question was typed.
  answer: null, asking: false,
  tab: 'notes',
  composer: { title: '', body: '', session_date: '' },
};

async function load() {
  if (!campaignId) {
    $('app').innerHTML = `<div class="panel"><p class="err">No campaign_id in the URL.</p></div>`;
    return;
  }
  $('dash-link').href = `/apps/character-creator/dashboard.html?campaign_id=${campaignId}`;
  try {
    const camp = await api('campaigns/' + campaignId);
    D.campaign = camp.campaign; D.isGm = camp.is_gm; D.isMember = camp.is_member;

    // A non-member gets the campaign's name and nothing else. Everything below
    // this line is member-gated server-side too — this only avoids four
    // requests that would each come back 403.
    if (!D.isMember) return render();

    const [entries, items, currency, roster] = await Promise.all([
      api(`journal?campaign_id=${campaignId}`),
      api(`campaigns/${campaignId}/items`),
      api(`campaigns/${campaignId}/currency`),
      api(`characters?campaign_id=${campaignId}`),
    ]);
    D.entries = entries.entries; D.entriesTotal = entries.total ?? entries.entries.length;
    D.items = items.items;
    D.balances = currency.balances; D.ledger = currency.ledger;
    D.roster = roster.characters;
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
  const tabs = [['notes', `Notes (${D.entriesTotal})`],
                ['stash', `Party stash (${D.items.length})`],
                ['money', 'Currency']];
  $('app').innerHTML = `
    <div class="panel">
      <h2>${esc(D.campaign.name)} <span class="muted small">(${esc(D.campaign.system)})</span></h2>
      <div class="toggle">${tabs.map(([k, label]) =>
        `<button class="${D.tab === k ? 'on' : ''}" onclick="setTab('${k}')">${esc(label)}</button>`).join('')}</div>
    </div>
    ${D.tab === 'notes' ? notesView() : D.tab === 'stash' ? stashView() : moneyView()}`;
  wireSearch();
}

function setTab(t) { D.tab = t; render(); }

// ---------- notes ----------
function notesView() {
  return `
  <div class="panel">
    <h3>Search</h3>
    <p class="muted small">Typing searches the notes and costs nothing. <b>Ask</b> sends the best
      matches to Claude for a written answer, and cites the entries it used.</p>
    <div class="rowline">
      <input type="text" id="note-search" class="picker-input" value="${esc(D.query)}"
        placeholder="Search notes — a name, a place, a thing…" autocomplete="off">
      <button class="btn btn-sm" onclick="ask()" ${D.asking || !D.query.trim() ? 'disabled' : ''}>
        ${D.asking ? 'Asking…' : '✨ Ask'}</button>
      ${D.query || D.results ? `<button class="btn btn-sm btn-ghost" onclick="clearSearch()">clear</button>` : ''}
    </div>
    ${answerBlock()}
    ${resultsBlock()}
  </div>
  ${composerBlock()}
  <div class="panel">
    <h3>${D.results ? 'All notes' : 'Notes'} <span class="muted small">newest first</span></h3>
    ${D.entries.length ? D.entries.map(entryCard).join('') : '<p class="muted">No notes yet.</p>'}
  </div>`;
}

function entryCard(e) {
  return `<div class="panel-inset" style="margin-top:10px">
    <div class="rowline" style="justify-content:space-between">
      <b>${esc(e.title || '(untitled)')}</b>
      <span class="muted small">${esc(e.author_email)} · ${esc(when(e))}${
        e.character_id ? ' · character note' : ''}</span>
    </div>
    <p class="small" style="white-space:pre-wrap; margin-top:6px">${esc(e.body)}</p>
    <div class="rowline">
      <button class="btn btn-sm btn-ghost" onclick="removeEntry(${e.id})">delete</button>
    </div>
  </div>`;
}

const when = (e) => e.session_date || (e.created_at || '').replace('T', ' ').replace('Z', '');

function composerBlock() {
  const c = D.composer;
  return `<div class="panel">
    <h3>Add a note</h3>
    <div class="rowline">
      <input type="text" class="picker-input" placeholder="Title (optional)" value="${esc(c.title)}"
        onchange="D.composer.title = this.value">
      <input type="text" class="picker-input" placeholder="Session date (optional)" value="${esc(c.session_date)}"
        onchange="D.composer.session_date = this.value">
    </div>
    <textarea id="note-body" rows="5" placeholder="What happened? Who did you talk to? What did they want?"
      style="width:100%; margin-top:8px" onchange="D.composer.body = this.value">${esc(c.body)}</textarea>
    <div class="nav" style="margin-top:8px">
      <span class="muted small">Everyone in the campaign can read and add notes.</span>
      <button class="btn btn-primary" onclick="postNote()">Post note</button>
    </div>
    <p id="note-msg" class="small"></p>
  </div>`;
}

function resultsBlock() {
  if (!D.results) return '';
  if (!D.results.length) return `<p class="muted" style="margin-top:10px">Nothing matched “${esc(D.query)}”.</p>`;
  return `<p class="small" style="margin-top:12px"><b>${D.results.length}</b> matching
    ${D.results.length === 1 ? 'note' : 'notes'}</p>` +
    D.results.map((r) => `<div class="panel-inset" style="margin-top:8px">
      <div class="rowline" style="justify-content:space-between">
        <b>${esc(r.title || '(untitled)')}</b>
        <span class="muted small">${esc(r.author_email)} · ${esc(when(r))}</span>
      </div>
      <p class="small" style="margin-top:4px">${highlight(r.snippet)}</p>
    </div>`).join('');
}

// A search snippet, escaped and then re-marked.
//
// The ORDER is the whole point: escape the note text first, so nothing in it
// can become markup, and only then turn the two control characters the server
// used into <mark> tags. Doing it the other way round - marking first, escaping
// after - escapes the tags and shows them as text; skipping the escape puts a
// note's contents into the page as HTML.
const HIGHLIGHT_START = '\u0001';
const HIGHLIGHT_END = '\u0002';
function highlight(snippet) {
  return esc(String(snippet || ''))
    .split(HIGHLIGHT_START).join('<mark>')
    .split(HIGHLIGHT_END).join('</mark>');
}

function answerBlock() {
  if (!D.answer) return '';
  const a = D.answer;
  return `<div class="panel-inset" style="margin-top:12px">
    <h4>${esc(a.question)}</h4>
    <p class="small" style="white-space:pre-wrap">${esc(a.answer)}</p>
    ${a.cited?.length ? `<p class="muted small">From: ${a.cited.map((c) =>
      `#${c.id} ${esc(c.title || '(untitled)')}`).join(' · ')}</p>` : ''}
    <p class="muted small">Read ${a.entries_considered} ${a.entries_considered === 1 ? 'note' : 'notes'}.
      Answers come from the notes only — if they do not say, it says so.</p>
  </div>`;
}

// The search input is re-created by every render, so its listener is re-bound
// here rather than delegated: the caret has to survive a re-render mid-word,
// which a delegated listener could not manage.
let searchTimer = null;
function wireSearch() {
  const el = $('note-search');
  if (!el) return;
  el.addEventListener('input', () => {
    D.query = el.value;
    clearTimeout(searchTimer);
    // Debounced, not per-keystroke: FTS5 is fast but a request per character is
    // still a request per character.
    searchTimer = setTimeout(runSearch, 250);
  });
  if (document.activeElement !== el && D.query) { el.focus(); el.setSelectionRange(el.value.length, el.value.length); }
}

async function runSearch() {
  const q = D.query.trim();
  if (!q) { D.results = null; return render(); }
  try {
    const res = await api(`campaigns/${campaignId}/search?q=${encodeURIComponent(q)}`);
    // A slower earlier request must not overwrite a newer one's results.
    if (D.query.trim() !== q) return;
    D.results = res.entries;
    render();
  } catch (err) {
    D.results = [];
    render();
  }
}

function clearSearch() { D.query = ''; D.results = null; D.answer = null; render(); }

async function ask() {
  const question = D.query.trim();
  if (!question || D.asking) return;
  D.asking = true; render();
  try {
    const res = await api(`campaigns/${campaignId}/ask`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question }),
    });
    D.answer = { question, ...res };
  } catch (err) {
    D.answer = { question, answer: 'That failed: ' + err.message, cited: [], entries_considered: 0 };
  } finally {
    D.asking = false; render();
  }
}

async function postNote() {
  const body = ($('note-body')?.value || D.composer.body || '').trim();
  if (!body) { $('note-msg').textContent = 'A note needs something in it.'; return; }
  $('note-msg').textContent = 'Posting…';
  try {
    await api('journal', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        campaign_id: Number(campaignId), body,
        title: D.composer.title || null,
        session_date: D.composer.session_date || null,
      }),
    });
    D.composer = { title: '', body: '', session_date: '' };
    await load();
  } catch (err) {
    $('note-msg').textContent = 'Failed: ' + err.message;
  }
}

async function removeEntry(id) {
  if (!confirm('Delete this note? It is not recoverable.')) return;
  try {
    await api('journal/' + id, { method: 'DELETE' });
    await load();
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
    <div class="rowline">
      <input type="text" id="stash-name" class="picker-input" placeholder="Item name">
      <input type="number" id="stash-qty" value="1" min="1" style="width:80px">
      <button class="btn btn-sm" onclick="addStash()">Add</button>
    </div>
    <p class="muted small">Added as a freeform item. Claiming one moves it onto a character's sheet
      and records that it left the stash — the row stays either way.</p>
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
      <select id="claim-${i.id}"><option value="">— claim for —</option>${options}</select>
      <button class="btn btn-sm btn-ghost" onclick="claim(${i.id})">claim</button>
      <button class="btn btn-sm btn-ghost" onclick="dropItem(${i.id})">remove</button>
    </span>
  </div>`;
}

async function addStash() {
  const name = ($('stash-name')?.value || '').trim();
  const qty = parseInt($('stash-qty')?.value, 10) || 1;
  if (!name) { $('stash-msg').textContent = 'Give it a name.'; return; }
  try {
    await api(`campaigns/${campaignId}/items`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ custom_name: name, qty }),
    });
    await load();
  } catch (err) { $('stash-msg').textContent = 'Failed: ' + err.message; }
}

async function claim(itemId) {
  const characterId = $('claim-' + itemId)?.value;
  if (!characterId) { alert('Choose which character is taking it.'); return; }
  try {
    await api(`campaigns/${campaignId}/items/${itemId}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ claim_for_character_id: Number(characterId) }),
    });
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function dropItem(itemId) {
  try {
    await api(`campaigns/${campaignId}/items/${itemId}`, { method: 'DELETE' });
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

// ---------- currency ----------
function moneyView() {
  return `
  <div class="panel">
    <h3>Party currency <span class="muted small">— the balance is the sum of the ledger</span></h3>
    ${D.balances.length
      ? D.balances.map((b) => `<div class="stat-row"><span>${esc(b.currency)}</span>
          <b>${Number(b.balance).toLocaleString()}</b></div>`).join('')
      : '<p class="muted">Nothing tracked yet.</p>'}
    <h4 style="margin-top:16px">Record income or spending</h4>
    <div class="rowline">
      <input type="text" id="cur-name" class="picker-input" placeholder="credits"
        value="${esc(D.balances[0]?.currency || '')}" style="max-width:140px">
      <input type="number" id="cur-delta" placeholder="+ or −" style="width:120px">
      <input type="text" id="cur-reason" class="picker-input" placeholder="What for?">
      <button class="btn btn-sm" onclick="addMoney()">Record</button>
    </div>
    <p class="muted small">Negative to spend. Entries are never edited — a mistake is corrected by
      an opposing entry that says so.</p>
    <p id="cur-msg" class="small"></p>
  </div>
  <div class="panel">
    <h3>Ledger</h3>
    ${D.ledger.length ? D.ledger.map((l) => `<div class="chkrow">
      <span><b class="${l.delta < 0 ? 'err' : 'ok'}">${l.delta > 0 ? '+' : ''}${Number(l.delta).toLocaleString()}</b>
        <span class="muted">${esc(l.currency)}</span> ${esc(l.reason || '')}</span>
      <span class="muted small">${esc(l.created_by)} · ${esc((l.created_at || '').slice(0, 16))}</span>
    </div>`).join('') : '<p class="muted">Nothing recorded yet.</p>'}
  </div>`;
}

async function addMoney() {
  const currency = ($('cur-name')?.value || '').trim();
  const delta = parseInt($('cur-delta')?.value, 10);
  if (!currency || !Number.isFinite(delta) || delta === 0) {
    $('cur-msg').textContent = 'Needs a currency and a non-zero amount.';
    return;
  }
  try {
    await api(`campaigns/${campaignId}/currency`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ currency, delta, reason: ($('cur-reason')?.value || '').trim() || null }),
    });
    await load();
  } catch (err) { $('cur-msg').textContent = 'Failed: ' + err.message; }
}

load();
