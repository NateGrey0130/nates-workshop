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
  // The pictures the GM has revealed (migration 078). Captions only: the page
  // behind a handout is the GM's and never comes over the wire.
  handouts: [],
  roster: [], gear: [],
  // The NPC roster, the dossier currently open, and the sweep's proposals.
  // Proposals live in state rather than being written down: a proposal is not
  // a dossier until somebody says so, and a page reload correctly loses them.
  npcs: [], npc: null, proposals: null, sweeping: false, sweepMsg: '',
  // Search is a separate view over the same feed rather than a filter of it:
  // results are ranked and snippetted, and pretending that is the same list
  // would mean the feed sometimes silently reorders itself.
  query: '', results: null, searching: false,
  // The answer to the last question asked, and whether one is in flight. Kept
  // beside the search box because that is where the question was typed.
  answer: null, asking: false,
  tab: 'notes',
  composer: { title: '', body: '', session_date: '' },
  // The G.M.'s NPC roller (migration 070). `classes` loads the first time the
  // form opens - the full list is the heaviest response in the app, and only a
  // G.M. who asks for the form needs it.
  gen: { open: false, classes: null, cls: '', occ: '', level: 1, count: 1, name: '',
         busy: false, msg: '', err: false },
  // Placing a notable NPC from the books (notable_npcs, migration 072): the
  // codex's `notables` section, loaded the first time the form opens.
  book: { open: false, rows: null, slug: '', name: '', busy: false, msg: '', err: false },
  // Rolling creatures from the books (creatures, migration 074): the codex's
  // `creatures` section, loaded the first time the form opens.
  beast: { open: false, rows: null, slug: '', count: 1, name: '', busy: false, msg: '', err: false },
};

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

    // A non-member gets the campaign's name and nothing else. Everything below
    // this line is member-gated server-side too — this only avoids four
    // requests that would each come back 403.
    if (!D.isMember) return render();

    const [entries, items, currency, roster, npcs, handouts] = await Promise.all([
      api(`journal?campaign_id=${campaignId}`),
      api(`campaigns/${campaignId}/items`),
      api(`campaigns/${campaignId}/currency`),
      api(`characters?campaign_id=${campaignId}`),
      api(`campaigns/${campaignId}/npcs`),
      api(`campaigns/${campaignId}/handouts`),
    ]);
    D.entries = entries.entries; D.entriesTotal = entries.total ?? entries.entries.length;
    D.items = items.items;
    D.balances = currency.balances; D.ledger = currency.ledger;
    D.roster = roster.characters;
    D.npcs = npcs.npcs;
    D.handouts = handouts.handouts || [];
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
  // Four panels behind a control shaped like a two-state toggle, while the sheet
  // next door switches six with a real tab bar. This is the sheet's `.tabbar`,
  // reused rather than re-styled: 44px targets, its `.tab-n` count pill, and the
  // tablist/tab/aria-selected roles the toggle never had. It sits OUTSIDE the
  // panel, as the sheet's does, because `.tabbar` is sticky and paints itself in
  // --bg-primary — inside a card it would smear the wrong colour on scroll.
  //
  // `campaign-tabs` keeps it VISIBLE ON A DESKTOP. The sheet's bar is hidden
  // above 820px, where the sheet shows every panel at once (styles.css, since
  // 2026-09-01); these four panels are never all shown, so without the class a
  // desktop saw Notes and no way to reach People, the stash or the ledger. The
  // codex hit the same rule and has `codex-tabs` for the same reason.
  const tabs = [['notes', 'Notes', D.entriesTotal],
                ['people', 'People', D.npcs.length],
                ['stash', 'Party stash', D.items.filter((i) => !i.removed_at).length],
                ['money', 'Currency', 0],
                ['handouts', 'Handouts', D.handouts.length]];
  $('app').innerHTML = `
    <div class="panel">
      <h2>${esc(D.campaign.name)} <span class="muted small">(${esc(D.campaign.system)})</span></h2>
    </div>
    <nav class="tabbar campaign-tabs" role="tablist">${tabs.map(([k, label, n]) =>
      `<button class="tab${D.tab === k ? ' on' : ''}" role="tab" aria-selected="${D.tab === k}"
         onclick="setTab('${k}')">${esc(label)}${
         n ? ` <span class="tab-n">${n}</span>` : ''}</button>`).join('')}</nav>
    ${D.tab === 'notes' ? notesView()
      : D.tab === 'people' ? peopleView()
      : D.tab === 'stash' ? stashView()
      : D.tab === 'handouts' ? handoutsView() : moneyView()}`;
  wireSearch();
}

function setTab(t) { D.tab = t; D.npc = null; render(); }

// ---------- handouts ----------
//
// What the GM has shown the party: a picture and its caption, newest first.
// There is no title and no body here because there is none to have - an entry
// is the GM's notebook and only the IMAGE is ever revealed (migration 078).
// A player who has seen nothing gets a sentence saying so rather than an empty
// panel, because "nothing yet" and "this is broken" look identical otherwise.
function handoutsView() {
  if (!D.handouts.length) {
    return `<div class="panel">
      <h3 style="margin-top:0">Handouts</h3>
      <p class="muted">Nothing yet. What the GM shows the party — a map, a portrait, a page
        from a book — turns up here.</p>
    </div>`;
  }
  return `<div class="panel">
    <h3 style="margin-top:0">Handouts <span class="muted small">(newest first)</span></h3>
    <ul class="handouts">
      ${D.handouts.map((h) => `<li class="handout">
        <figure style="margin:0">
          <img src="/api/character-creator/campaigns/${campaignId}/images/${h.id}"
               alt="${esc(h.caption || 'A handout from the GM')}" loading="lazy">
          ${h.caption ? `<figcaption>${esc(h.caption)}</figcaption>` : ''}
        </figure>
      </li>`).join('')}
    </ul>
  </div>`;
}

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

// The note form promises that typing @Name links someone to their dossier, and
// the dossier half was true from the start — the half on screen was not. The
// mentions rendered as plain text, so the reader saw a promise the page did not
// keep.
//
// Linked against D.npcs — the dossiers this campaign actually has — rather than
// by re-running the server's @-pattern here. A second copy of that rule would
// drift from `_lib/mentions.js`, and the failure would be a link to a dossier
// that does not exist. No dossier, no link, by construction.
//
// ONE pass over an alternation sorted longest-first, never one pass per name:
// with an "Osric" and a "Brother Osric" on the roster, a second pass would
// match inside the anchor the first pass just wrote and nest a link in a link.
// The names are HTML-escaped before they are regex-escaped, because the body
// they are matched against has already been through esc().
const reEsc = (v) => v.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

function linkifyMentions(body) {
  const html = esc(body);
  const named = D.npcs.filter((n) => n.name).sort((a, b) => b.name.length - a.name.length);
  if (!named.length) return html;
  const byName = new Map(named.map((n) => [esc(n.name).toLowerCase(), n.id]));
  const re = new RegExp('@(' + named.map((n) => reEsc(esc(n.name))).join('|') + ')(?![\\p{L}])', 'giu');
  return html.replace(re, (m, name) => {
    const id = byName.get(name.toLowerCase());
    return id === undefined ? m
      : `<a href="#" class="mention" onclick="openNpc(${id}); return false">${m}</a>`;
  });
}

function entryCard(e) {
  return `<div class="panel-inset" style="margin-top:10px">
    <div class="rowline" style="justify-content:space-between">
      <b>${esc(e.title || '(untitled)')}</b>
      <span class="muted small">${esc(e.author_email)} · ${esc(when(e))}${
        e.character_id ? ' · character note' : ''}</span>
    </div>
    <p class="small" style="white-space:pre-wrap; margin-top:6px">${linkifyMentions(e.body)}</p>
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
      <span class="muted small">Everyone in the campaign can read and add notes.
        Type <b>@Name</b> to link someone to their dossier — a new name gets one.</span>
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
const HIGHLIGHT_START = '';
const HIGHLIGHT_END = '';
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

// ---------- people ----------
//
// Two ways in, and the roster shows both. `@Kevik` in a note creates and links
// a dossier for free; the sweep proposes the people nobody tagged. A proposal
// is NOT a dossier — accepting one is a second, explicit click.
function peopleView() {
  if (D.npc) return dossierView();
  const byStatus = { alive: [], unknown: [], dead: [], 'never-met': [] };
  for (const n of D.npcs) (byStatus[n.status] || byStatus.unknown).push(n);

  return `
  <div class="panel">
    <h3>People <span class="muted small">— everyone the campaign has met</span></h3>
    ${D.npcs.length ? Object.entries(byStatus).filter(([, list]) => list.length).map(([status, list]) =>
      `<p class="small" style="margin-top:12px"><b>${esc(statusLabel(status))}</b>
        <span class="muted">${list.length}</span></p>` +
      list.map(npcRow).join('')).join('')
      : `<p class="muted">Nobody yet. Type <b>@Name</b> in a note, or sweep the notes below.</p>`}
    <h4 style="margin-top:16px">Add someone by hand</h4>
    <div class="rowline">
      <input type="text" id="npc-name" class="picker-input" placeholder="Name">
      <button class="btn btn-sm" onclick="addNpc()">Add</button>
    </div>
    <p id="npc-msg" class="small"></p>
  </div>
  ${D.isGm ? npcSheetsPanel() : ''}
  ${sweepPanel()}`;
}

// ---------- statted NPCs (G.M. only) ----------
//
// A dossier is what the table knows about someone; a statted NPC is what the
// G.M. rolls for them - a characters row with kind = 'npc' that the server shows
// to nobody else. The list comes from the roster request the page already
// makes: the server includes NPC rows only for the G.M., so a player's copy of
// this page never holds one to hide.
const npcSheets = () => (D.roster || []).filter((c) => c.kind === 'npc');

function npcSheetsPanel() {
  const sheets = npcSheets();
  return `<div class="panel">
    <h3>Statted NPCs <span class="muted small">— only you can see these</span></h3>
    ${D.gen.open ? genForm() : D.book.open ? bookForm() : D.beast.open ? beastForm()
      : `<div class="rowline" style="margin-top:6px;flex-wrap:wrap">
          <button class="btn btn-sm" onclick="openGen()">🎲 Roll NPCs from a class</button>
          <button class="btn btn-sm" onclick="openBook()">📖 Place a notable NPC from the books</button>
          <button class="btn btn-sm" onclick="openBeast()">🐾 Roll creatures from the books</button></div>`}
    <div style="margin-top:10px">${sheets.length ? sheets.map(npcSheetRow).join('')
      : '<p class="muted small">None yet. Roll some, then link one to a dossier from its page.</p>'}</div>
  </div>`;
}

function npcSheetRow(c) {
  return `<div class="chkrow">
    <span><a href="/apps/character-sheet/?id=${c.id}"><b>${esc(c.name)}</b></a>
      <span class="muted small"> — ${esc(className(c.class_id))}${
        c.occ_class_id ? ' ' + esc(className(c.occ_class_id)) : ''}, level ${c.level}</span></span>
    <span class="rowline">
      <a class="btn btn-sm btn-ghost" href="/apps/character-sheet/?id=${c.id}&amp;play=1">▶ Play</a>
      <button class="btn btn-sm btn-ghost" onclick="deleteNpcSheet(${c.id})">delete</button>
    </span>
  </div>`;
}

// A book NPC's class id is `notable:<slug>` (from-notable) - it names where the
// sheet came from, not a class, so it reads as that.
// A creature's is `creature:<slug>` (from-creature), for the same reason.
const className = (id) => (String(id).startsWith('notable:') ? 'from the books'
  : String(id).startsWith('creature:') ? 'a creature from the books'
  : D.classNames?.[id] || id);

// A race whose entry grants no related or secondary skills takes an occupation,
// and the server refuses one without it - so the form asks rather than letting
// the refusal be the first the G.M. hears of it. The same test js/parser.js
// needsOccupation() applies.
const takesOccupation = (c) => c?.category === 'rcc'
  && !(c.skills?.occ_related_skills?.count) && !(c.skills?.secondary_skills?.count);

function genForm() {
  const g = D.gen;
  if (!g.classes) return '<p class="muted small" style="margin-top:10px">Loading classes…</p>';
  const option = (c, sel) => `<option value="${esc(c.id)}"${c.id === sel ? ' selected' : ''}>${esc(c.name)}</option>`;
  const races = g.classes.filter((c) => c.category === 'rcc');
  const jobs = g.classes.filter((c) => c.category !== 'rcc');
  const chosen = g.classes.find((c) => c.id === g.cls);
  const needsJob = takesOccupation(chosen);
  return `<div class="panel-inset" style="margin-top:10px">
    <div class="rowline" style="flex-wrap:wrap">
      <label class="small">Class
        <select onchange="genSet('cls', this.value, true)">
          <option value="">— choose —</option>
          <optgroup label="Races (R.C.C.)">${races.map((c) => option(c, g.cls)).join('')}</optgroup>
          <optgroup label="Occupations (O.C.C.)">${jobs.map((c) => option(c, g.cls)).join('')}</optgroup>
        </select></label>
      ${chosen?.category === 'rcc' ? `<label class="small">Occupation${needsJob ? '' : ' <span class="muted">(optional)</span>'}
        <select onchange="genSet('occ', this.value, true)">
          <option value="">${needsJob ? '— choose one —' : '— none —'}</option>
          ${jobs.map((c) => option(c, g.occ)).join('')}
        </select></label>` : ''}
    </div>
    <div class="rowline" style="flex-wrap:wrap;margin-top:8px">
      <label class="small">Level <input type="number" min="1" max="20" value="${g.level}" style="width:4.5em"
        onchange="genSet('level', this.value)"></label>
      <label class="small">How many <input type="number" min="1" max="10" value="${g.count}" style="width:4.5em"
        onchange="genSet('count', this.value)"></label>
      <input type="text" class="picker-input" placeholder="Name (optional)" value="${esc(g.name)}"
        onchange="genSet('name', this.value)">
    </div>
    <div class="rowline" style="margin-top:8px">
      <button class="btn btn-sm btn-primary" onclick="rollNpcs()"
        ${g.busy || !g.cls || (needsJob && !g.occ) ? 'disabled' : ''}>${g.busy ? 'Rolling…' : 'Roll'}</button>
      <button class="btn btn-sm btn-ghost" onclick="closeGen()">close</button>
    </div>
    <p class="small muted">Every choice is made at random and checked against the class like a
      player's character. Spells and psionic powers the class lets them <em>choose</em> are banked on
      the sheet for you to pick. A class the roller cannot build legally is refused, with the reason.</p>
    ${g.msg ? `<p class="small${g.err ? ' err' : ''}">${esc(g.msg)}</p>` : ''}
  </div>`;
}

async function openGen() {
  D.gen.open = true;
  render();
  if (D.gen.classes) return;
  try {
    const res = await api(`classes?system=${encodeURIComponent(D.campaign.system)}`);
    D.gen.classes = [...res.classes].sort((a, b) => String(a.name).localeCompare(String(b.name)));
  } catch (err) { D.gen.msg = 'Could not load classes: ' + err.message; D.gen.err = true; D.gen.classes = []; }
  render();
}
function closeGen() { D.gen.open = false; D.gen.msg = ''; render(); }

// ---------- a notable NPC from the books ----------
//
// The named people the books stat (the codex's Notable NPCs). Placing one COPIES
// the book's numbers into this campaign as a statted NPC - one-way, so a fight
// changes this table's copy and never the book. Offered from this campaign's
// game, plus any a book marks as belonging to every game.
function bookForm() {
  const b = D.book;
  if (!b.rows) return '<p class="muted small" style="margin-top:10px">Loading the books…</p>';
  const rows = b.rows.filter((r) => !r.system || r.system === 'both' || r.system === D.campaign.system);
  if (!rows.length) {
    return `<div class="panel-inset" style="margin-top:10px">
      <p class="muted small">No notable NPCs from ${esc(D.campaign.system)} books have been imported yet.</p>
      <button class="btn btn-sm btn-ghost" onclick="closeBook()">close</button></div>`;
  }
  return `<div class="panel-inset" style="margin-top:10px">
    <div class="rowline" style="flex-wrap:wrap">
      ${/* An option carries name, title and citation, so a select sized to its
           longest option overran the panel on desktop; it takes the row instead. */ ''}
      <label class="small" style="flex:1 1 100%;min-width:0">From the books
        <select style="width:100%" onchange="bookSet('slug', this.value, true)">
          <option value="">— choose —</option>
          ${rows.map((r) => `<option value="${esc(r.slug)}"${r.slug === b.slug ? ' selected' : ''}>${
            esc(r.name)}${r.title ? ` — ${esc(r.title)}` : ''} (${esc(r.source_book || '')})</option>`).join('')}
        </select></label>
      <input type="text" class="picker-input" placeholder="Name in this campaign (optional)" value="${esc(b.name)}"
        onchange="bookSet('name', this.value)">
    </div>
    <div class="rowline" style="margin-top:8px">
      <button class="btn btn-sm btn-primary" onclick="placeNotable()" ${b.busy || !b.slug ? 'disabled' : ''}>
        ${b.busy ? 'Placing…' : 'Place in this campaign'}</button>
      <button class="btn btn-sm btn-ghost" onclick="closeBook()">close</button>
    </div>
    <p class="small muted">The book's own numbers for this person, copied. Its attacks, powers and gear go in the
      sheet's notes. Changes to the copy never touch the book.</p>
    ${b.msg ? `<p class="small${b.err ? ' err' : ''}">${esc(b.msg)}</p>` : ''}
  </div>`;
}

async function openBook() {
  D.book.open = true;
  render();
  if (D.book.rows) return;
  try {
    D.book.rows = (await api('codex?section=notables')).notables || [];
  } catch (err) { D.book.msg = 'Could not load them: ' + err.message; D.book.err = true; D.book.rows = []; }
  render();
}
function closeBook() { D.book.open = false; D.book.msg = ''; render(); }
function bookSet(key, value, rerender = false) {
  D.book[key] = value;
  if (key === 'slug') { D.book.msg = ''; D.book.err = false; }
  if (rerender) render();
}

async function placeNotable() {
  const b = D.book;
  b.busy = true; b.msg = ''; b.err = false;
  render();
  try {
    const res = await api(`campaigns/${campaignId}/npcs/from-notable`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ slug: b.slug, name: b.name.trim() || null }),
    });
    D.roster = (await api(`characters?campaign_id=${campaignId}`)).characters;
    b.msg = `Placed ${res.name}.`;
    b.name = '';
  } catch (err) { b.msg = err.message; b.err = true; }
  b.busy = false;
  render();
}

// ---------- creatures from the books ----------
//
// The species the books stat (the codex's Creatures). Each individual is ROLLED
// from the book's dice, separately - six wolves are six rolls. A formula the
// server cannot roll is refused with its name, and nothing is placed.
function beastForm() {
  const b = D.beast;
  if (!b.rows) return '<p class="muted small" style="margin-top:10px">Loading the books…</p>';
  const rows = b.rows.filter((r) => !r.system || r.system === 'both' || r.system === D.campaign.system);
  if (!rows.length) {
    return `<div class="panel-inset" style="margin-top:10px">
      <p class="muted small">No creatures from ${esc(D.campaign.system)} books have been imported yet.</p>
      <button class="btn btn-sm btn-ghost" onclick="closeBeast()">close</button></div>`;
  }
  return `<div class="panel-inset" style="margin-top:10px">
    <div class="rowline" style="flex-wrap:wrap">
      ${/* Sized to the row, not its longest option - the notable form's fix. */ ''}
      <label class="small" style="flex:1 1 100%;min-width:0">From the books
        <select style="width:100%" onchange="beastSet('slug', this.value, true)">
          <option value="">— choose —</option>
          ${rows.map((r) => `<option value="${esc(r.slug)}"${r.slug === b.slug ? ' selected' : ''}>${
            esc(r.name)}${r.category ? ` — ${esc(r.category)}` : ''} (${esc(r.source_book || '')})</option>`).join('')}
        </select></label>
      <label class="small">How many
        <input type="number" min="1" max="12" value="${b.count}" style="width:5em"
          onchange="beastSet('count', this.value)"></label>
      <input type="text" class="picker-input" placeholder="Name in this campaign (optional)" value="${esc(b.name)}"
        onchange="beastSet('name', this.value)">
    </div>
    <div class="rowline" style="margin-top:8px">
      <button class="btn btn-sm btn-primary" onclick="placeCreatures()" ${b.busy || !b.slug ? 'disabled' : ''}>
        ${b.busy ? 'Rolling…' : 'Roll into this campaign'}</button>
      <button class="btn btn-sm btn-ghost" onclick="closeBeast()">close</button>
    </div>
    <p class="small muted">Each one is rolled from the book's dice. Its attacks and abilities go in the sheet's
      notes. Changes to a creature never touch the book.</p>
    ${b.msg ? `<p class="small${b.err ? ' err' : ''}">${esc(b.msg)}</p>` : ''}
  </div>`;
}

async function openBeast() {
  D.beast.open = true;
  render();
  if (D.beast.rows) return;
  try {
    D.beast.rows = (await api('codex?section=creatures')).creatures || [];
  } catch (err) { D.beast.msg = 'Could not load them: ' + err.message; D.beast.err = true; D.beast.rows = []; }
  render();
}
function closeBeast() { D.beast.open = false; D.beast.msg = ''; render(); }
function beastSet(key, value, rerender = false) {
  const b = D.beast;
  if (key === 'count') b.count = Math.max(1, Math.min(12, Math.trunc(Number(value) || 1)));
  else b[key] = value;
  if (key === 'slug') { b.msg = ''; b.err = false; }
  if (rerender) render();
}

async function placeCreatures() {
  const b = D.beast;
  b.busy = true; b.msg = ''; b.err = false;
  render();
  try {
    const res = await api(`campaigns/${campaignId}/npcs/from-creature`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ slug: b.slug, count: b.count, name: b.name.trim() || null }),
    });
    D.roster = (await api(`characters?campaign_id=${campaignId}`)).characters;
    const made = res.characters || [];
    b.msg = made.length === 1 ? `Rolled ${made[0].name}.` : `Rolled ${made.length}: ${made.map((c) => c.name).join(', ')}.`;
    b.name = '';
  } catch (err) { b.msg = err.message; b.err = true; }
  b.busy = false;
  render();
}

// Selects re-render (the occupation control appears with a race, and the Roll
// button waits for one); typed inputs only store, so a keystroke never rebuilds
// the field being typed in.
function genSet(key, value, rerender = false) {
  const g = D.gen;
  if (key === 'level') g.level = Math.max(1, Math.trunc(Number(value) || 1));
  else if (key === 'count') g.count = Math.max(1, Math.min(10, Math.trunc(Number(value) || 1)));
  else g[key] = value;
  if (key === 'cls') { g.occ = ''; g.msg = ''; g.err = false; }
  if (rerender) render();
}

async function rollNpcs() {
  const g = D.gen;
  g.busy = true; g.msg = ''; g.err = false;
  render();
  try {
    const res = await api(`campaigns/${campaignId}/npcs/generate`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ class_id: g.cls, occ_class_id: g.occ || null,
                             level: g.level, count: g.count, name: g.name.trim() || null }),
    });
    D.roster = (await api(`characters?campaign_id=${campaignId}`)).characters;
    const banked = res.npcs.reduce((n, x) => n + (x.powers_banked || 0) + (x.picks_pending || 0), 0);
    g.msg = `Rolled ${res.npcs.length}: ${res.npcs.map((x) => x.name).join(', ')}.`
      + (banked ? ` ${banked} pick${banked === 1 ? '' : 's'} banked on their sheets for you to choose.` : '')
      + (res.refused ? ` Stopped there: ${res.refused.error}` : '');
    g.err = !!res.refused;
  } catch (err) {
    g.msg = err.message; g.err = true;
  }
  g.busy = false;
  render();
}

async function deleteNpcSheet(id) {
  if (!confirm('Delete this statted NPC? A dossier linked to it keeps everything but the link.')) return;
  try {
    await api(`characters/${id}`, { method: 'DELETE' });
    D.roster = (await api(`characters?campaign_id=${campaignId}`)).characters;
    render();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function linkSheet(npcId, value) {
  try {
    const res = await api(`campaigns/${campaignId}/npcs/${npcId}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ character_id: value ? Number(value) : null }),
    });
    D.npc.npc = res.npc;
    render();
  } catch (err) { alert('Failed: ' + err.message); }
}

const statusLabel = (s) => ({ alive: 'Alive', dead: 'Dead', unknown: 'Status unknown',
                              'never-met': 'Not met yet' })[s] || s;

// The portrait URL is STABLE (…/npcs/12/portrait) while the object behind it is
// not, and the response carries an immutable cache header — so without a
// changing query the browser would keep showing the portrait it first fetched
// forever, including after a replacement.
//
// The buster is the object KEY, which is a uuid and changes on every upload.
// `updated_at` was the obvious choice and is wrong twice: it contains a space,
// which does not belong in a URL unencoded, and it also changes when somebody
// edits the faction field, which re-fetches an image that did not change.
function portraitSrc(n) {
  return `/api/character-creator/campaigns/${campaignId}/npcs/${n.id}/portrait`
    + `?v=${encodeURIComponent(n.portrait_key || '')}`;
}

function npcRow(n) {
  return `<button type="button" class="chkrow" style="cursor:pointer" onclick="openNpc(${n.id})">
    ${n.portrait_key ? `<img src="${portraitSrc(n)}"
      alt="" style="width:34px;height:34px;border-radius:50%;object-fit:cover">` : ''}
    <span><b>${esc(n.name)}</b>
      ${n.faction ? `<span class="tag">${esc(n.faction)}</span>` : ''}
      ${n.disposition ? `<span class="muted small"> — ${esc(n.disposition)}</span>` : ''}</span>
    <span class="pct">${n.mention_count} ${n.mention_count === 1 ? 'mention' : 'mentions'}</span>
  </button>`;
}

function sweepPanel() {
  return `<div class="panel">
    <h3>Find people nobody tagged</h3>
    <p class="muted small">Reads the notes that have not been swept and proposes the named people in
      them. A proposal is not a dossier — accept the ones that are real, dismiss the ones that are
      not, and a dismissed name is not offered again.</p>
    <div class="rowline">
      <button class="btn btn-sm" onclick="sweep()" ${D.sweeping ? 'disabled' : ''}>
        ${D.sweeping ? 'Reading…' : '✨ Sweep the notes'}</button>
      <span class="muted small">${esc(D.sweepMsg)}</span>
    </div>
    ${D.proposals ? (D.proposals.length
      ? D.proposals.map((p) => `<div class="chkrow">
          <span><b>${esc(p.name)}</b>
            ${p.description ? `<span class="muted small"> — ${esc(p.description)}</span>` : ''}
            <span class="muted small"> (${p.entry_ids.length}
              ${p.entry_ids.length === 1 ? 'note' : 'notes'})</span></span>
          <span class="rowline">
            <button class="btn btn-sm" onclick="acceptProposal('${escAttr(p.name)}')">accept</button>
            <button class="btn btn-sm btn-ghost" onclick="dismissProposal('${escAttr(p.name)}')">not a person</button>
          </span>
        </div>`).join('')
      : '<p class="muted small">Nobody new in those notes.</p>') : ''}
  </div>`;
}

// A name goes into an inline onclick, so it needs escaping for the attribute
// AND for the JS string inside it. This was `esc(v).replace(/'/g, '&#39;')`,
// which reads right and is not: the attribute is entity-decoded before the JS
// is parsed, so an NPC called O'Brien produced a SyntaxError rather than a
// dismiss button. escJs in /shared/js/ui.js does both layers.
const escAttr = escJs;

function dossierView() {
  const n = D.npc.npc;
  const mentions = D.npc.mentions;
  return `
  <div class="panel">
    <div class="rowline"><button class="btn btn-sm btn-ghost" onclick="closeNpc()">← everyone</button></div>
    <div class="rowline" style="align-items:flex-start; gap:14px; margin-top:10px">
      ${n.portrait_key
        ? `<img src="${portraitSrc(n)}"
             alt="${esc(n.name)}" style="width:120px;height:120px;border-radius:8px;object-fit:cover">`
        : `<div style="width:120px;height:120px;border-radius:8px;background:var(--bg-secondary);
             display:flex;align-items:center;justify-content:center" class="muted small">no portrait</div>`}
      <div style="flex:1;min-width:220px">
        <h2 style="margin:0">${esc(n.name)}</h2>
        ${n.aliases?.length ? `<p class="muted small">also known as ${esc(n.aliases.join(', '))}</p>` : ''}
        <div class="rowline" style="margin-top:8px">
          <input type="file" id="npc-portrait" accept="image/png,image/jpeg,image/webp,image/gif">
          <button class="btn btn-sm btn-ghost" onclick="uploadPortrait(${n.id})">upload portrait</button>
          ${n.portrait_key ? `<button class="btn btn-sm btn-ghost" onclick="removePortrait(${n.id})">remove</button>` : ''}
        </div>
        <p id="portrait-msg" class="small"></p>
      </div>
    </div>

    <div class="rowline" style="margin-top:14px">
      <select onchange="editNpc(${n.id}, 'status', this.value)">
        ${['alive', 'dead', 'unknown', 'never-met'].map((s) =>
          `<option value="${s}"${n.status === s ? ' selected' : ''}>${esc(statusLabel(s))}</option>`).join('')}
      </select>
      <input type="text" class="picker-input" placeholder="Faction" value="${esc(n.faction || '')}"
        onchange="editNpc(${n.id}, 'faction', this.value)">
      <input type="text" class="picker-input" placeholder="Disposition to the party"
        value="${esc(n.disposition || '')}" onchange="editNpc(${n.id}, 'disposition', this.value)">
    </div>
    <input type="text" class="picker-input" style="width:100%;margin-top:8px" placeholder="Also known as (comma separated)"
      value="${esc((n.aliases || []).join(', '))}" onchange="editNpc(${n.id}, 'aliases', this.value)">
    <textarea rows="3" style="width:100%;margin-top:8px" placeholder="What do we know?"
      onchange="editNpc(${n.id}, 'description', this.value)">${esc(n.description || '')}</textarea>
    ${D.isGm ? `<div class="rowline" style="margin-top:8px">
      <label class="small">Statted sheet <span class="muted">(only you see this)</span>
        <select onchange="linkSheet(${n.id}, this.value)">
          <option value="">— none —</option>
          ${npcSheets().map((c) => `<option value="${c.id}"${n.character_id === c.id ? ' selected' : ''}>${
            esc(c.name)} (level ${c.level})</option>`).join('')}
        </select></label>
      ${n.character_id ? `<a class="btn btn-sm btn-ghost" href="/apps/character-sheet/?id=${n.character_id}">open sheet</a>` : ''}
    </div>` : ''}
    <div class="rowline" style="margin-top:8px">
      <button class="btn btn-sm btn-ghost" onclick="deleteNpc(${n.id})">delete dossier</button>
      <span class="muted small">Deleting the dossier leaves the notes alone — the @ in the text is just text.</span>
    </div>
  </div>

  <div class="panel">
    <h3>Every mention <span class="muted small">— oldest first, which is the story</span></h3>
    ${mentions.length ? mentions.map((m) => `<div class="panel-inset" style="margin-top:8px">
      <div class="rowline" style="justify-content:space-between">
        <b>${esc(m.title || '(untitled)')}</b>
        <span class="muted small">${esc(m.author_email)} · ${esc(when(m))}${
          m.source === 'ai' ? ' · <span class="tag">found by sweep</span>' : ''}</span>
      </div>
      <p class="small" style="white-space:pre-wrap; margin-top:6px">${linkifyMentions(m.body)}</p>
    </div>`).join('') : '<p class="muted">No notes mention them yet.</p>'}
  </div>`;
}

async function openNpc(id) {
  try {
    D.npc = await api(`campaigns/${campaignId}/npcs/${id}`);
    // Reachable from a mention inside a note now, not just from the People tab,
    // and render() picks the view from D.tab — without this the dossier loads
    // and nothing on screen changes.
    D.tab = 'people';
    render();
  } catch (err) { alert('Failed: ' + err.message); }
}
function closeNpc() { D.npc = null; render(); }

async function addNpc() {
  const name = ($('npc-name')?.value || '').trim();
  if (!name) { $('npc-msg').textContent = 'Give them a name.'; return; }
  try {
    await api(`campaigns/${campaignId}/npcs`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name }),
    });
    await load();
  } catch (err) { $('npc-msg').textContent = 'Failed: ' + err.message; }
}

async function editNpc(id, field, value) {
  try {
    await api(`campaigns/${campaignId}/npcs/${id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ [field]: value }),
    });
    D.npc = await api(`campaigns/${campaignId}/npcs/${id}`);
    const list = await api(`campaigns/${campaignId}/npcs`);
    D.npcs = list.npcs;
    render();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function deleteNpc(id) {
  if (!confirm('Delete this dossier? The notes that mention them are not touched.')) return;
  try {
    await api(`campaigns/${campaignId}/npcs/${id}`, { method: 'DELETE' });
    D.npc = null;
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

// A PORTRAIT IS THE SMALLEST PICTURE IN THIS WHOLE REPO, so it gets its own
// cap rather than the 2048 `downscale.js` defaults to (UI-AUDIT F59). There
// are exactly two views of one - the 34px roster thumbnail in `npcRow` and the
// 120px square in the dossier, both `object-fit: cover` - and no full-screen
// view exists the way present mode does for a campaign picture. 512 covers the
// 120px square at a device pixel ratio of 4, and leaves room for a dossier
// portrait that doubles in size before anyone has to think about this again.
// Larger than that is detail no view in this app can render, which is the
// argument `downscale.js` makes for 2048 one app over.
//
// THIS IS DESTRUCTIVE IN THE ONE WAY THAT MATTERS: the object in R2 is the
// downscaled one, so a cap chosen too small cannot be undone by changing a
// stylesheet later. That is the reason it is 512 and not 256.
const PORTRAIT_MAX_EDGE = 512;

// The raw file as the body, with its own Content-Type. Not multipart: there is
// exactly one file and no fields beside it, so a FormData boundary would be
// packaging for nothing.
async function uploadPortrait(id) {
  const file = $('npc-portrait')?.files?.[0];
  if (!file) { $('portrait-msg').textContent = 'Choose an image first.'; return; }
  $('portrait-msg').textContent = 'Uploading…';
  try {
    // UI-AUDIT F59: shrink it here, because nothing downstream can - this
    // platform has no image resizing on Pages. THE HEADER COMES FROM WHAT IS
    // SENT, not from the File: the server reads this one header to pick the R2
    // key's extension, the stored content_type and the Content-Type it serves
    // back later, so describing a re-encoded blob with the original file's
    // type would be wrong in three places. `toUpload` hands the original back
    // untouched whenever it cannot do better - a gif, a picture already under
    // the cap, a canvas that will not decode - so this is the same request it
    // always was in every one of those cases.
    const body = await downscale.toUpload(file, PORTRAIT_MAX_EDGE);
    await api(`campaigns/${campaignId}/npcs/${id}/portrait`, {
      method: 'POST', headers: { 'Content-Type': body.type }, body,
    });
    D.npc = await api(`campaigns/${campaignId}/npcs/${id}`);
    const list = await api(`campaigns/${campaignId}/npcs`);
    D.npcs = list.npcs;
    render();
  } catch (err) { $('portrait-msg').textContent = 'Failed: ' + err.message; }
}

async function removePortrait(id) {
  try {
    await api(`campaigns/${campaignId}/npcs/${id}/portrait`, { method: 'DELETE' });
    D.npc = await api(`campaigns/${campaignId}/npcs/${id}`);
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function sweep() {
  if (D.sweeping) return;
  D.sweeping = true; D.sweepMsg = ''; render();
  try {
    const res = await api(`campaigns/${campaignId}/npcs/sweep`, { method: 'POST' });
    D.proposals = res.proposals;
    D.sweepMsg = res.message || `Read ${res.swept} ${res.swept === 1 ? 'note' : 'notes'}${
      res.remaining ? `, ${res.remaining} still to read` : ''}.`;
  } catch (err) {
    D.sweepMsg = 'Failed: ' + err.message;
  } finally {
    D.sweeping = false; render();
  }
}

async function acceptProposal(name) {
  const p = D.proposals?.find((x) => x.name === name);
  if (!p) return;
  try {
    await api(`campaigns/${campaignId}/npcs/sweep?accept=1`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(p),
    });
    D.proposals = D.proposals.filter((x) => x.name !== name);
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function dismissProposal(name) {
  try {
    await api(`campaigns/${campaignId}/npcs/sweep?dismiss=1`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name }),
    });
    D.proposals = D.proposals.filter((x) => x.name !== name);
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
      onto a character's sheet and records that it left the stash — the row stays either way.</p>
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
