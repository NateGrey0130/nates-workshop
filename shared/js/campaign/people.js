// People: everyone the campaign has met, each with a dossier - a portrait,
// what is known, and every note that mentions them. Needs core.js, and
// downscale.js for portraits.
//
// Two ways in, and the roster shows both. `@Kevik` in a note creates and links
// a dossier for free (the server's _lib/mentions.js); the sweep proposes the
// people nobody tagged. A proposal is NOT a dossier - accepting one is a
// second, explicit click.
//
//   mcCampaign.people.load()       fetch the roster
//   mcCampaign.people.html(opts)   the roster, or the open dossier
//   mcCampaign.people.linkify(t)   a note body with its @mentions linked
//   mcCampaign.people.state        npcs, the open dossier, the sweep's state
//
// What a game adds, through html(opts), all optional:
//   nameButton  - HTML beside the "Add someone" box (a name generator's button)
//   nameSlot    - HTML under that row (the generator's panel)
//   after       - HTML between the roster and the sweep (e.g. statted NPCs)
//   dossierExtra(npc) - HTML inside a dossier, above its delete row
// The box those name tools fill is `npc-name`.
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const $ = (i) => document.getElementById(i);
  const esc = (v) => M.ctx.ui.esc(v);
  const api = (path, opts) => M.ctx.api(path, opts);
  const cid = () => M.ctx.campaignId;
  const render = () => M.ctx.render();
  const toast = (text) => M.ctx.ui.toast(text);

  const S = {
    // The roster, the dossier currently open, and the sweep's proposals.
    // Proposals live in state rather than being written down: a proposal is not
    // a dossier until somebody says so, and a page reload correctly loses them.
    npcs: [], npc: null, proposals: null, sweeping: false, sweepMsg: '',
  };

  async function load() {
    S.npcs = (await api(`campaigns/${cid()}/npcs`)).npcs;
  }

  // The note form promises that typing @Name links someone to their dossier.
  //
  // Linked against S.npcs - the dossiers this campaign actually has - rather
  // than by re-running the server's @-pattern here. A second copy of that rule
  // would drift from `_lib/mentions.js`, and the failure would be a link to a
  // dossier that does not exist. No dossier, no link, by construction.
  //
  // ONE pass over an alternation sorted longest-first, never one pass per name:
  // with an "Osric" and a "Brother Osric" on the roster, a second pass would
  // match inside the anchor the first pass just wrote and nest a link in a link.
  // The names are HTML-escaped before they are regex-escaped, because the body
  // they are matched against has already been through esc().
  const reEsc = (v) => v.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

  function linkify(body) {
    const html = esc(body);
    const named = S.npcs.filter((n) => n.name).sort((a, b) => b.name.length - a.name.length);
    if (!named.length) return html;
    const byName = new Map(named.map((n) => [esc(n.name).toLowerCase(), n.id]));
    const re = new RegExp('@(' + named.map((n) => reEsc(esc(n.name))).join('|') + ')(?![\\p{L}])', 'giu');
    return html.replace(re, (m, name) => {
      const id = byName.get(name.toLowerCase());
      return id === undefined ? m
        : `<a href="#" class="mc-mention" onclick="mcCampaign.people.open(${id}); return false">${m}</a>`;
    });
  }

  const statusLabel = (s) => ({ alive: 'Alive', dead: 'Dead', unknown: 'Status unknown',
                                'never-met': 'Not met yet' })[s] || s;

  function html(opts = {}) {
    if (S.npc) return dossierView(opts);
    const byStatus = { alive: [], unknown: [], dead: [], 'never-met': [] };
    for (const n of S.npcs) (byStatus[n.status] || byStatus.unknown).push(n);

    return `
  <div class="mc-panel">
    <h3>People <span class="mc-muted mc-small">— everyone the campaign has met</span></h3>
    ${S.npcs.length ? Object.entries(byStatus).filter(([, list]) => list.length).map(([status, list]) =>
      `<p class="mc-small mc-group-head"><b>${esc(statusLabel(status))}</b>
        <span class="mc-muted">${list.length}</span></p>` +
      list.map(npcRow).join('')).join('')
      : `<p class="mc-muted">Nobody yet. Type <b>@Name</b> in a note, or sweep the notes below.</p>`}
    <h4 class="mc-subhead">Add someone by hand</h4>
    <div class="mc-row">
      <input type="text" id="npc-name" class="mc-input" placeholder="Name">
      ${opts.nameButton || ''}
      <button class="mc-btn mc-btn-sm" onclick="mcCampaign.people.add()">Add</button>
    </div>
    ${opts.nameSlot || ''}
    <p id="npc-msg" class="mc-small"></p>
  </div>
  ${opts.after || ''}
  ${sweepPanel()}`;
  }

  // The portrait URL is STABLE (…/npcs/12/portrait) while the object behind it is
  // not, and the response carries an immutable cache header - so without a
  // changing query the browser would keep showing the portrait it first fetched
  // forever, including after a replacement.
  //
  // The buster is the object KEY, which is a uuid and changes on every upload.
  // `updated_at` was the obvious choice and is wrong twice: it contains a space,
  // which does not belong in a URL unencoded, and it also changes when somebody
  // edits the faction field, which re-fetches an image that did not change.
  function portraitSrc(n) {
    return `${M.ctx.base}/campaigns/${cid()}/npcs/${n.id}/portrait`
      + `?v=${encodeURIComponent(n.portrait_key || '')}`;
  }

  function npcRow(n) {
    return `<button type="button" class="mc-item mc-person" onclick="mcCampaign.people.open(${n.id})">
    ${n.portrait_key ? `<img src="${portraitSrc(n)}"
      alt="" class="mc-thumb">` : ''}
    <span><b>${esc(n.name)}</b>
      ${n.faction ? `<span class="mc-tag">${esc(n.faction)}</span>` : ''}
      ${n.disposition ? `<span class="mc-muted mc-small"> — ${esc(n.disposition)}</span>` : ''}</span>
    <span class="mc-count">${n.mention_count} ${n.mention_count === 1 ? 'mention' : 'mentions'}</span>
  </button>`;
  }

  // A name goes into an inline onclick, so it needs escaping for the attribute
  // AND for the JS string inside it - the adapter's escJs, never
  // `esc(v).replace(/'/g, '&#39;')`: the attribute is entity-decoded before the
  // JS is parsed, so an NPC called O'Brien produced a SyntaxError rather than a
  // dismiss button.
  const escAttr = (v) => M.ctx.ui.escJs(v);

  function sweepPanel() {
    return `<div class="mc-panel">
    <h3>Find people nobody tagged</h3>
    <p class="mc-muted mc-small">Reads the notes that have not been swept and proposes the named people in
      them. A proposal is not a dossier — accept the ones that are real, dismiss the ones that are
      not, and a dismissed name is not offered again.</p>
    <div class="mc-row">
      <button class="mc-btn mc-btn-sm" onclick="mcCampaign.people.sweep()" ${S.sweeping ? 'disabled' : ''}>
        ${S.sweeping ? 'Reading…' : '✨ Sweep the notes'}</button>
      <span class="mc-muted mc-small">${esc(S.sweepMsg)}</span>
    </div>
    ${S.proposals ? (S.proposals.length
      ? S.proposals.map((p) => `<div class="mc-item">
          <span><b>${esc(p.name)}</b>
            ${p.description ? `<span class="mc-muted mc-small"> — ${esc(p.description)}</span>` : ''}
            <span class="mc-muted mc-small"> (${p.entry_ids.length}
              ${p.entry_ids.length === 1 ? 'note' : 'notes'})</span></span>
          <span class="mc-row">
            <button class="mc-btn mc-btn-sm" onclick="mcCampaign.people.accept('${escAttr(p.name)}')">accept</button>
            <button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.people.dismiss('${escAttr(p.name)}')">not a person</button>
          </span>
        </div>`).join('')
      : '<p class="mc-muted mc-small">Nobody new in those notes.</p>') : ''}
  </div>`;
  }

  function dossierView(opts) {
    const n = S.npc.npc;
    const mentions = S.npc.mentions;
    return `
  <div class="mc-panel">
    <div class="mc-row"><button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.people.close()">← everyone</button></div>
    <div class="mc-row mc-dossier-head">
      ${n.portrait_key
        ? `<img src="${portraitSrc(n)}"
             alt="${esc(n.name)}" class="mc-portrait">`
        : `<div class="mc-portrait mc-portrait-empty mc-muted mc-small">no portrait</div>`}
      <div class="mc-dossier-id">
        <h2 class="mc-dossier-name">${esc(n.name)}</h2>
        ${n.aliases?.length ? `<p class="mc-muted mc-small">also known as ${esc(n.aliases.join(', '))}</p>` : ''}
        <div class="mc-row mc-portrait-tools">
          <input type="file" id="npc-portrait" accept="image/png,image/jpeg,image/webp,image/gif">
          <button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.people.uploadPortrait(${n.id})">upload portrait</button>
          ${n.portrait_key ? `<button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.people.removePortrait(${n.id})">remove</button>` : ''}
        </div>
        <p id="portrait-msg" class="mc-small"></p>
      </div>
    </div>

    <div class="mc-row mc-dossier-fields">
      <select onchange="mcCampaign.people.edit(${n.id}, 'status', this.value)">
        ${['alive', 'dead', 'unknown', 'never-met'].map((s) =>
          `<option value="${s}"${n.status === s ? ' selected' : ''}>${esc(statusLabel(s))}</option>`).join('')}
      </select>
      <input type="text" class="mc-input" placeholder="Faction" value="${esc(n.faction || '')}"
        onchange="mcCampaign.people.edit(${n.id}, 'faction', this.value)">
      <input type="text" class="mc-input" placeholder="Disposition to the party"
        value="${esc(n.disposition || '')}" onchange="mcCampaign.people.edit(${n.id}, 'disposition', this.value)">
    </div>
    <input type="text" class="mc-input mc-full" placeholder="Also known as (comma separated)"
      value="${esc((n.aliases || []).join(', '))}" onchange="mcCampaign.people.edit(${n.id}, 'aliases', this.value)">
    <textarea rows="3" class="mc-full" placeholder="What do we know?"
      onchange="mcCampaign.people.edit(${n.id}, 'description', this.value)">${esc(n.description || '')}</textarea>
    ${opts.dossierExtra ? opts.dossierExtra(n) : ''}
    <div class="mc-row mc-dossier-foot">
      <button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.people.remove(${n.id})">delete dossier</button>
      <span class="mc-muted mc-small">Deleting the dossier leaves the notes alone — the @ in the text is just text.</span>
    </div>
  </div>

  <div class="mc-panel">
    <h3>Every mention <span class="mc-muted mc-small">— oldest first, which is the story</span></h3>
    ${mentions.length ? mentions.map((m) => `<div class="mc-inset mc-result">
      <div class="mc-row mc-spread">
        <b>${esc(m.title || '(untitled)')}</b>
        <span class="mc-muted mc-small">${esc(m.author_email)} · ${esc(M.when(m))}${
          m.source === 'ai' ? ' · <span class="mc-tag">found by sweep</span>' : ''}</span>
      </div>
      <p class="mc-small mc-note-body">${linkify(m.body)}</p>
    </div>`).join('') : '<p class="mc-muted">No notes mention them yet.</p>'}
  </div>`;
  }

  async function open(id) {
    try {
      S.npc = await api(`campaigns/${cid()}/npcs/${id}`);
      // Reachable from a mention inside a note, not just from the people view,
      // so the page is asked to bring that view forward - without this the
      // dossier loads and nothing on screen changes.
      M.ctx.showPeople();
      render();
    } catch (err) { toast('Failed: ' + err.message); }
  }
  function close() { S.npc = null; render(); }

  async function add() {
    const name = ($('npc-name')?.value || '').trim();
    if (!name) { $('npc-msg').textContent = 'Give them a name.'; return; }
    try {
      await api(`campaigns/${cid()}/npcs`, M.json('POST', { name }));
      await M.ctx.reload();
    } catch (err) { $('npc-msg').textContent = 'Failed: ' + err.message; }
  }

  async function edit(id, field, value) {
    try {
      await api(`campaigns/${cid()}/npcs/${id}`, M.json('PATCH', { [field]: value }));
      S.npc = await api(`campaigns/${cid()}/npcs/${id}`);
      const list = await api(`campaigns/${cid()}/npcs`);
      S.npcs = list.npcs;
      // A field saves on blur, and the blur is usually a Tab INTO the next
      // field. Re-rendering then replaced the field being typed in. The state
      // above is current either way; the redraw waits for the next one.
      const typing = document.activeElement
        && /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName);
      if (!typing) render();
    } catch (err) { toast('Failed: ' + err.message); }
  }

  // Undo rather than confirm (the page's undoable). Undo reopens the dossier
  // it was deleted from, since that is where the person was standing.
  function remove(id) {
    const at = S.npcs.findIndex((n) => n.id === id);
    const n = at >= 0 ? S.npcs[at] : null;
    const opened = S.npc;
    M.ctx.ui.undoable({
      label: n?.name || opened?.name || 'the dossier',
      hide: () => { S.npc = null; S.npcs = S.npcs.filter((x) => x.id !== id); render(); },
      restore: () => {
        if (n) S.npcs.splice(Math.min(at, S.npcs.length), 0, n);
        S.npc = opened;
        render();
      },
      commit: async (keepalive) => {
        await api(`campaigns/${cid()}/npcs/${id}`, { method: 'DELETE', keepalive });
        if (!keepalive) await M.ctx.reload();
      },
    });
  }

  // A PORTRAIT IS THE SMALLEST PICTURE IN THIS WHOLE REPO, so it gets its own
  // cap rather than the 2048 `downscale.js` defaults to (UI-AUDIT F59). There
  // are exactly two views of one - the roster thumbnail in `npcRow` and the
  // square in the dossier, both cropped to fill - and no full-screen view
  // exists the way present mode does for a campaign picture. 512 covers a
  // 120px square at a device pixel ratio of 4, and leaves room for a dossier
  // portrait that doubles in size before anyone has to think about this again.
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
      // UI-AUDIT F59: shrink it here, because nothing downstream can - Pages has
      // no image resizing. THE HEADER COMES FROM WHAT IS SENT, not from the
      // File: the server reads this one header to pick the R2 key's extension,
      // the stored content_type and the Content-Type it serves back later, so
      // describing a re-encoded blob with the original file's type would be
      // wrong in three places. `toUpload` hands the original back untouched
      // whenever it cannot do better - a gif, a picture already under the cap,
      // a canvas that will not decode.
      const body = await downscale.toUpload(file, PORTRAIT_MAX_EDGE);
      await api(`campaigns/${cid()}/npcs/${id}/portrait`, {
        method: 'POST', headers: { 'Content-Type': body.type }, body,
      });
      S.npc = await api(`campaigns/${cid()}/npcs/${id}`);
      const list = await api(`campaigns/${cid()}/npcs`);
      S.npcs = list.npcs;
      render();
    } catch (err) { $('portrait-msg').textContent = 'Failed: ' + err.message; }
  }

  async function removePortrait(id) {
    try {
      await api(`campaigns/${cid()}/npcs/${id}/portrait`, { method: 'DELETE' });
      S.npc = await api(`campaigns/${cid()}/npcs/${id}`);
      await M.ctx.reload();
    } catch (err) { toast('Failed: ' + err.message); }
  }

  async function sweep() {
    if (S.sweeping) return;
    S.sweeping = true; S.sweepMsg = ''; render();
    try {
      const res = await api(`campaigns/${cid()}/npcs/sweep`, { method: 'POST' });
      S.proposals = res.proposals;
      S.sweepMsg = res.message || `Read ${res.swept} ${res.swept === 1 ? 'note' : 'notes'}${
        res.remaining ? `, ${res.remaining} still to read` : ''}.`;
    } catch (err) {
      S.sweepMsg = 'Failed: ' + err.message;
    } finally {
      S.sweeping = false; render();
    }
  }

  async function accept(name) {
    const p = S.proposals?.find((x) => x.name === name);
    if (!p) return;
    try {
      await api(`campaigns/${cid()}/npcs/sweep?accept=1`, M.json('POST', p));
      S.proposals = S.proposals.filter((x) => x.name !== name);
      await M.ctx.reload();
    } catch (err) { toast('Failed: ' + err.message); }
  }

  async function dismiss(name) {
    try {
      await api(`campaigns/${cid()}/npcs/sweep?dismiss=1`, M.json('POST', { name }));
      S.proposals = S.proposals.filter((x) => x.name !== name);
      render();
    } catch (err) { toast('Failed: ' + err.message); }
  }

  M.people = {
    state: S, load, html, linkify, portraitSrc, statusLabel,
    open, close, add, edit, remove, uploadPortrait, removePortrait, sweep, accept, dismiss,
  };
})(globalThis);
