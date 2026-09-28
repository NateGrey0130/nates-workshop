// The setting: the GM's own pages, and the pictures shown from them. GM only -
// a page never asks for these on a player's behalf, and the server refuses if
// it does. Needs core.js and downscale.js.
//
// An ENTRY is the GM's notebook and is never revealed. An IMAGE is revealed one
// at a time, and its CAPTION is the only text a player reads (migration 078;
// handouts.js is the players' side). So the editor below puts the reveal switch
// on the picture, never on the page, and the caption field sits beside it
// rather than under the body.
//
// PRESENT MODE IS A PAGE OF ITS OWN (present.js), black and chromeless, one
// picture fitted to the screen. It is a LINK rather than a button so a GM with
// a second screen can open it there. Presenting a picture does NOT reveal it:
// the switch below is still the only thing here that does.
//
//   mcCampaign.setting.load()        fetch the GM's pages (GM only)
//   mcCampaign.setting.html(opts)    the panel; opts.presentHref is the page
//                                    present mode lives at ('present.html')
//   mcCampaign.setting.open(id)      open a page in the editor
//   mcCampaign.setting.state         entries, the open entry and its images
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const $ = (i) => document.getElementById(i);
  const esc = (v) => M.ctx.ui.esc(v);
  const api = (path, opts) => M.ctx.api(path, opts);
  const cid = () => M.ctx.campaignId;
  const render = () => M.ctx.render();

  const S = { entries: [], entry: null, entryImages: [], presentHref: 'present.html' };

  const KINDS = ['place', 'faction', 'lore', 'handout', 'prep'];
  const KIND_LABEL = { place: 'Place', faction: 'Faction', lore: 'Lore', handout: 'Handout', prep: 'Session prep' };

  const presentUrl = (imageId) =>
    `${S.presentHref}?campaign_id=${encodeURIComponent(cid())}&entry_id=${S.entry.id}`
    + (imageId ? `&image_id=${imageId}` : '');

  const imageSrc = (id) => `${M.ctx.base}/campaigns/${cid()}/images/${id}`;

  async function load() {
    try {
      S.entries = (await api(`campaigns/${cid()}/entries`)).entries || [];
    } catch { S.entries = []; }
  }

  function html(opts = {}) {
    if (opts.presentHref) S.presentHref = opts.presentHref;
    const rows = S.entries.map((e) => `<li class="mc-page${S.entry?.id === e.id ? ' mc-on' : ''}">
      <span class="mc-page-what">
        <a href="#" onclick="mcCampaign.setting.open(${e.id}); return false;"><b>${esc(e.title)}</b></a>
        <span class="mc-muted mc-small">${esc(KIND_LABEL[e.kind] || e.kind)}
          ${e.image_count ? ` · ${e.image_count} picture${e.image_count === 1 ? '' : 's'}` : ''}
          ${e.revealed_count ? ` · ${e.revealed_count} shown` : ''}</span>
      </span>
    </li>`).join('');

    return `<div class="mc-panel">
    <h3 class="mc-head">Setting <span class="mc-muted mc-small">(your pages — players never see these, only pictures you reveal)</span></h3>
    <div class="mc-row">
      <input id="entry-title" class="mc-mini mc-wide" placeholder="A place, a faction, next session…" maxlength="200">
      <select id="entry-kind" class="mc-mini">
        ${KINDS.map((k) => `<option value="${k}">${esc(KIND_LABEL[k])}</option>`).join('')}
      </select>
      <button class="mc-btn mc-btn-primary" onclick="mcCampaign.setting.create()">+ New page</button>
      <span id="entry-msg" class="mc-muted mc-small"></span>
    </div>
    ${rows ? `<ul class="mc-pages">${rows}</ul>`
      : '<p class="mc-muted mc-small">No pages yet. A page holds your notes and the pictures you show from them.</p>'}
    ${S.entry ? editorHtml() : ''}
  </div>`;
  }

  function editorHtml() {
    const e = S.entry;
    const pics = S.entryImages.map((i) => `<li class="mc-pic">
      <img src="${imageSrc(i.id)}" alt="${esc(i.caption || 'Picture')}" loading="lazy">
      <div class="mc-pic-meta">
        <input class="mc-mini mc-wide" value="${esc(i.caption || '')}" placeholder="Caption — the one thing players read"
               onchange="mcCampaign.setting.saveCaption(${i.id}, this.value)">
        <div class="mc-row">
          <a class="mc-btn mc-btn-sm" href="${presentUrl(i.id)}" title="Show this on a screen at the table. It does not reveal it.">▶ Present</a>
          <button class="mc-btn mc-btn-sm ${i.revealed_at ? '' : 'mc-btn-primary'}" onclick="mcCampaign.setting.toggleReveal(${i.id}, ${i.revealed_at ? 'false' : 'true'})">
            ${i.revealed_at ? '🙈 Hide from players' : '👁 Reveal to players'}</button>
          <span class="mc-muted mc-small">${i.revealed_at ? 'shown ' + esc(i.revealed_at) : 'only you can see this'}</span>
          <button class="mc-btn mc-btn-sm mc-btn-danger" onclick="mcCampaign.setting.deletePicture(${i.id})">Delete</button>
        </div>
      </div>
    </li>`).join('');

    return `<div class="mc-editor">
    <div class="mc-row">
      <input id="edit-title" class="mc-mini mc-wide" value="${esc(e.title)}" maxlength="200">
      <select id="edit-kind" class="mc-mini">
        ${KINDS.map((k) => `<option value="${k}" ${k === e.kind ? 'selected' : ''}>${esc(KIND_LABEL[k])}</option>`).join('')}
      </select>
      <button class="mc-btn mc-btn-primary" onclick="mcCampaign.setting.save()">💾 Save</button>
      ${S.entryImages.length ? `<a class="mc-btn" href="${presentUrl()}">▶ Present page</a>` : ''}
      <button class="mc-btn mc-btn-sm" onclick="mcCampaign.setting.close()">Close</button>
      <button class="mc-btn mc-btn-sm mc-btn-danger" onclick="mcCampaign.setting.remove()">Delete page</button>
      <span id="edit-msg" class="mc-muted mc-small"></span>
    </div>
    <textarea id="edit-body" placeholder="Your notes. Never revealed.">${esc(e.body || '')}</textarea>
    <div class="mc-row">
      <label class="mc-btn mc-btn-sm mc-upload">📷 Add a picture
        <input type="file" accept="image/jpeg,image/png,image/webp,image/gif"
               onchange="mcCampaign.setting.uploadPicture(this)"></label>
      ${/* This used to lead with the server's byte cap, which stopped being the
            thing a GM runs into: a big photo is shrunk to 2048px on its longest
            edge before it is sent (UI-AUDIT F57), so that cap is now reached by
            very few pictures rather than by every phone photo. An animated gif
            is sent as it is, because re-encoding one flattens it. */''}
      <span class="mc-muted mc-small">jpg/png/webp/gif. Big pictures are shrunk to
        ${downscale.MAX_EDGE}px before they upload; a gif is sent as it is.
        A picture arrives hidden.
        <b>Present</b> shows it on a screen at the table and changes nothing;
        <b>Reveal</b> puts it in the players' Handouts to keep.</span>
      <span id="upload-msg" class="mc-muted mc-small"></span>
    </div>
    ${pics ? `<ul class="mc-pics">${pics}</ul>` : ''}
  </div>`;
  }

  function setMsg(id, text, isErr) {
    const el = $(id);
    if (!el) return;
    el.textContent = text;
    el.className = isErr ? 'mc-err mc-small' : 'mc-muted mc-small';
  }

  async function create() {
    const title = $('entry-title').value.trim();
    if (!title) { setMsg('entry-msg', 'A page needs a title.', true); return; }
    try {
      const res = await api(`campaigns/${cid()}/entries`, M.json('POST', { title, kind: $('entry-kind').value }));
      await load();
      await open(res.entry.id);
    } catch (err) { setMsg('entry-msg', err.message, true); }
  }

  async function open(id) {
    try {
      const res = await api(`campaigns/${cid()}/entries/${id}`);
      S.entry = res.entry; S.entryImages = res.images || [];
      render();
    } catch (err) { setMsg('entry-msg', err.message, true); }
  }

  function close() { S.entry = null; S.entryImages = []; render(); }

  async function save() {
    try {
      const res = await api(`campaigns/${cid()}/entries/${S.entry.id}`, M.json('PATCH',
        { title: $('edit-title').value.trim(), kind: $('edit-kind').value, body: $('edit-body').value }));
      S.entry = res.entry;
      await load();
      render();
      setMsg('edit-msg', 'Saved.');
    } catch (err) { setMsg('edit-msg', err.message, true); }
  }

  // The question says what goes with it, as the character delete does: the
  // pictures are deleted from storage too, and that cannot be undone. A whole
  // page is asked about first; one picture goes with an Undo (below).
  async function remove() {
    const n = S.entryImages.length;
    if (!(await M.ctx.ui.modal(`Delete "${S.entry.title}"?\n\n${n ? `Its ${n} picture${n === 1 ? '' : 's'} ` : 'Nothing else '}`
      + `goes with it, including any the party has already been shown. This cannot be undone.`))) return;
    try {
      await api(`campaigns/${cid()}/entries/${S.entry.id}`, { method: 'DELETE' });
      S.entry = null; S.entryImages = [];
      await load();
      render();
    } catch (err) { setMsg('edit-msg', err.message, true); }
  }

  // The upload is the raw file as the body, which is what the endpoint takes -
  // no multipart, no form. The Content-Type IS the type check on the server.
  async function uploadPicture(input) {
    const file = input.files?.[0];
    if (!file) return;
    input.value = '';
    setMsg('upload-msg', `Uploading ${file.name}…`);
    try {
      // UI-AUDIT F57 option A: shrink it here, because nothing downstream can.
      // THE HEADER COMES FROM WHAT IS SENT, not from the File - the server reads
      // this one header to pick the R2 key's extension, the stored content_type
      // AND the Content-Type it serves back later, so describing a re-encoded
      // blob with the original file's type would be wrong in three places.
      // `toUpload` hands the original back untouched whenever it cannot do
      // better, so this is the same request it always was in that case.
      const body = await downscale.toUpload(file);
      const res = await api(`campaigns/${cid()}/entries/${S.entry.id}/images`, {
        method: 'POST', headers: { 'Content-Type': body.type }, body,
      });
      S.entryImages.push(res.image);
      await load();
      render();
      setMsg('upload-msg', 'Added, hidden from players.');
    } catch (err) { setMsg('upload-msg', err.message, true); }
  }

  async function patchImage(id, body, msgId) {
    try {
      const res = await api(`campaigns/${cid()}/images/${id}`, M.json('PATCH', body));
      const at = S.entryImages.findIndex((i) => i.id === id);
      if (at >= 0) S.entryImages[at] = res.image;
      await load();
      render();
    } catch (err) { setMsg(msgId, err.message, true); }
  }

  const toggleReveal = (id, on) => patchImage(id, { revealed: on }, 'edit-msg');
  const saveCaption = (id, caption) => patchImage(id, { caption }, 'edit-msg');

  // One picture goes with an Undo (the page's undoable): nothing is removed
  // from storage until the window closes, so Undo loses nothing.
  function deletePicture(id) {
    const at = S.entryImages.findIndex((i) => i.id === id);
    if (at < 0) return;
    const img = S.entryImages[at];
    M.ctx.ui.undoable({
      label: img.caption ? `“${img.caption}”` : 'the picture',
      hide: () => { S.entryImages = S.entryImages.filter((i) => i.id !== id); render(); },
      restore: () => { S.entryImages.splice(Math.min(at, S.entryImages.length), 0, img); render(); },
      commit: async (keepalive) => {
        await api(`campaigns/${cid()}/images/${id}`, { method: 'DELETE', keepalive });
        if (!keepalive) { await load(); render(); }
      },
    });
  }

  M.setting = {
    state: S, load, html, open, close, create, save, remove,
    uploadPicture, toggleReveal, saveCaption, deletePicture,
  };
})(globalThis);
