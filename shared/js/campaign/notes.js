// Campaign notes: the feed, the search box, Ask, and the form a note is
// written in. Also the read-only journal panel the GM dashboard shows.
// Needs core.js first; links @mentions through people.js when the page has it.
//
//   mcCampaign.notes.load()          fetch the feed (a page's load awaits it)
//   mcCampaign.notes.html()          the whole notes view
//   mcCampaign.notes.afterRender()   call after the view is in the DOM
//   mcCampaign.notes.feedHtml(opts)  the dashboard's journal panel
//   mcCampaign.notes.state           entries, total, and the search's state
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const $ = (i) => document.getElementById(i);
  const esc = (v) => M.ctx.ui.esc(v);
  const api = (path, opts) => M.ctx.api(path, opts);
  const cid = () => M.ctx.campaignId;
  const render = () => M.ctx.render();
  const when = M.when;

  const S = {
    entries: [], total: 0,
    // Search is a separate view over the same feed rather than a filter of it:
    // results are ranked and snippetted, and pretending that is the same list
    // would mean the feed sometimes silently reorders itself.
    query: '', results: null,
    // The answer to the last question asked, and whether one is in flight. Kept
    // beside the search box because that is where the question was typed.
    answer: null, asking: false,
    composer: { title: '', body: '', session_date: '' },
  };

  async function load() {
    const res = await api(`journal?campaign_id=${cid()}`);
    S.entries = res.entries;
    S.total = res.total ?? res.entries.length;
  }

  // A mention becomes a link to its dossier only when the page has the people
  // view to open it in; the dashboard's feed has none, and shows the text.
  const body = (text) => (M.people ? M.people.linkify(text) : esc(text));

  function html() {
    return `
  <div class="mc-panel">
    <h3>Search</h3>
    <p class="mc-muted mc-small">Typing searches the notes and costs nothing. <b>Ask</b> sends the best
      matches to Claude for a written answer, and cites the entries it used.</p>
    <div class="mc-row">
      <input type="text" id="note-search" class="mc-input" value="${esc(S.query)}"
        placeholder="Search notes — a name, a place, a thing…" autocomplete="off">
      <button class="mc-btn mc-btn-sm" onclick="mcCampaign.notes.ask()" ${S.asking || !S.query.trim() ? 'disabled' : ''}>
        ${S.asking ? 'Asking…' : '✨ Ask'}</button>
      ${S.query || S.results ? `<button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.notes.clearSearch()">clear</button>` : ''}
    </div>
    ${answerBlock()}
    ${resultsBlock()}
  </div>
  ${composerBlock()}
  <div class="mc-panel">
    <h3>${S.results ? 'All notes' : 'Notes'} <span class="mc-muted mc-small">newest first</span></h3>
    ${S.entries.length ? S.entries.map(entryCard).join('') : '<p class="mc-muted">No notes yet.</p>'}
  </div>`;
  }

  function entryCard(e) {
    return `<div class="mc-inset mc-note">
    <div class="mc-row mc-spread">
      <b>${esc(e.title || '(untitled)')}</b>
      <span class="mc-muted mc-small">${esc(e.author_email)} · ${esc(when(e))}${
        e.character_id ? ' · character note' : ''}</span>
    </div>
    <p class="mc-small mc-note-body">${body(e.body)}</p>
    <div class="mc-row">
      <button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.notes.removeEntry(${e.id})">delete</button>
    </div>
  </div>`;
  }

  function composerBlock() {
    const c = S.composer;
    return `<div class="mc-panel">
    <h3>Add a note</h3>
    <div class="mc-row">
      <input type="text" class="mc-input" placeholder="Title (optional)" value="${esc(c.title)}"
        onchange="mcCampaign.notes.state.composer.title = this.value">
      <input type="text" class="mc-input" placeholder="Session date (optional)" value="${esc(c.session_date)}"
        onchange="mcCampaign.notes.state.composer.session_date = this.value">
    </div>
    <textarea id="note-body" class="mc-note-input" rows="5" placeholder="What happened? Who did you talk to? What did they want?"
      onchange="mcCampaign.notes.state.composer.body = this.value">${esc(c.body)}</textarea>
    <div class="mc-bar mc-compose-bar">
      <span class="mc-muted mc-small">Everyone in the campaign can read and add notes.
        Type <b>@Name</b> to link someone to their dossier — a new name gets one.</span>
      <button class="mc-btn mc-btn-primary" onclick="mcCampaign.notes.postNote()">Post note</button>
    </div>
    <p id="note-msg" class="mc-small"></p>
  </div>`;
  }

  function resultsBlock() {
    if (!S.results) return '';
    if (!S.results.length) return `<p class="mc-muted mc-no-match">Nothing matched “${esc(S.query)}”.</p>`;
    return `<p class="mc-small mc-result-count"><b>${S.results.length}</b> matching
    ${S.results.length === 1 ? 'note' : 'notes'}</p>` +
      S.results.map((r) => `<div class="mc-inset mc-result">
      <div class="mc-row mc-spread">
        <b>${esc(r.title || '(untitled)')}</b>
        <span class="mc-muted mc-small">${esc(r.author_email)} · ${esc(when(r))}</span>
      </div>
      <p class="mc-small mc-snippet">${highlight(r.snippet)}</p>
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
    if (!S.answer) return '';
    const a = S.answer;
    return `<div class="mc-inset mc-answer">
    <h4>${esc(a.question)}</h4>
    <p class="mc-small mc-answer-text">${esc(a.answer)}</p>
    ${a.cited?.length ? `<p class="mc-muted mc-small">From: ${a.cited.map((c) =>
      `#${c.id} ${esc(c.title || '(untitled)')}`).join(' · ')}</p>` : ''}
    <p class="mc-muted mc-small">Read ${a.entries_considered} ${a.entries_considered === 1 ? 'note' : 'notes'}.
      Answers come from the notes only — if they do not say, it says so.</p>
  </div>`;
  }

  // The search input is re-created by every render, so its listener is re-bound
  // here rather than delegated: the caret has to survive a re-render mid-word,
  // which a delegated listener could not manage.
  let searchTimer = null;
  function afterRender() {
    const el = $('note-search');
    if (!el) return;
    el.addEventListener('input', () => {
      S.query = el.value;
      clearTimeout(searchTimer);
      // Debounced, not per-keystroke: FTS5 is fast but a request per character is
      // still a request per character.
      searchTimer = setTimeout(runSearch, 250);
    });
    if (document.activeElement !== el && S.query) { el.focus(); el.setSelectionRange(el.value.length, el.value.length); }
  }

  async function runSearch() {
    const q = S.query.trim();
    if (!q) { S.results = null; return render(); }
    try {
      const res = await api(`campaigns/${cid()}/search?q=${encodeURIComponent(q)}`);
      // A slower earlier request must not overwrite a newer one's results.
      if (S.query.trim() !== q) return;
      S.results = res.entries;
      render();
    } catch (err) {
      S.results = [];
      render();
    }
  }

  function clearSearch() { S.query = ''; S.results = null; S.answer = null; render(); }

  async function ask() {
    const question = S.query.trim();
    if (!question || S.asking) return;
    S.asking = true; render();
    try {
      const res = await api(`campaigns/${cid()}/ask`, M.json('POST', { question }));
      S.answer = { question, ...res };
    } catch (err) {
      S.answer = { question, answer: 'That failed: ' + err.message, cited: [], entries_considered: 0 };
    } finally {
      S.asking = false; render();
    }
  }

  async function postNote() {
    const text = ($('note-body')?.value || S.composer.body || '').trim();
    if (!text) { $('note-msg').textContent = 'A note needs something in it.'; return; }
    $('note-msg').textContent = 'Posting…';
    try {
      await api('journal', M.json('POST', {
        campaign_id: Number(cid()), body: text,
        title: S.composer.title || null,
        session_date: S.composer.session_date || null,
      }));
      S.composer = { title: '', body: '', session_date: '' };
      await M.ctx.reload();
    } catch (err) {
      $('note-msg').textContent = 'Failed: ' + err.message;
    }
  }

  // A note is not recoverable once deleted, which is the argument FOR an undo
  // window rather than a confirm: the mistake is seen after the click, not
  // before it. Nothing is sent until the window closes (the page's undoable).
  function removeEntry(id) {
    const at = S.entries.findIndex((e) => e.id === id);
    if (at < 0) return;
    const e = S.entries[at];
    M.ctx.ui.undoable({
      label: e.title ? `“${e.title}”` : 'the note',
      hide: () => { S.entries = S.entries.filter((x) => x.id !== id); S.total -= 1; render(); },
      restore: () => { S.entries.splice(Math.min(at, S.entries.length), 0, e); S.total += 1; render(); },
      commit: async (keepalive) => {
        await api('journal/' + id, { method: 'DELETE', keepalive });
        if (!keepalive) await M.ctx.reload();
      },
    });
  }

  // The GM dashboard's journal: the newest twenty, each tagged with whose it
  // is - the campaign's, or a character's by name (`names`, id to name). Read
  // only; the notes view is where a note is written, searched or deleted, and
  // `footer` is the page's way there.
  const FEED_LIMIT = 20;
  function feedHtml({ names = {}, footer = '' } = {}) {
    const rows = S.entries.slice(0, FEED_LIMIT).map((e) => {
      const isCampaign = e.character_id == null;
      const who = isCampaign ? 'campaign' : (names[e.character_id] || 'character #' + e.character_id);
      return `<div class="mc-journal-entry ${isCampaign ? 'mc-campaign' : ''}">
      <span class="mc-tag ${isCampaign ? 'mc-gm' : ''}">${esc(who)}</span>
      <b>${esc(e.title || 'Untitled')}</b>
      <span class="mc-muted mc-small"> — ${esc(e.author_email)}${e.session_date ? ' · session ' + esc(e.session_date) : ''} · ${esc(e.created_at)}</span>
      <div class="mc-body">${esc(e.body)}</div>
    </div>`;
    }).join('') || '<p class="mc-muted mc-small">No journal entries yet.</p>';

    // The fetch is bounded, so say what the twenty is out of.
    const more = S.total > Math.min(S.entries.length, FEED_LIMIT)
      ? `<p class="mc-muted mc-small">Showing the ${FEED_LIMIT} most recent of ${S.total} entries.</p>`
      : '';

    return `<div class="mc-panel">
    <h3 class="mc-head">Campaign journal <span class="mc-muted mc-small">(newest first)</span></h3>
    ${rows}
    ${more}
    ${footer}
  </div>`;
  }

  M.notes = { state: S, load, html, afterRender, feedHtml, ask, clearSearch, postNote, removeEntry };
})(globalThis);
