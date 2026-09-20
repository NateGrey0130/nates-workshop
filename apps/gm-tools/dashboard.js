// Campaign dashboard — party roster, GM notes, campaign journal feed.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const campaignId = new URLSearchParams(location.search).get('campaign_id');
// Which Setting page to open on arrival, if any. present.html sends the GM
// back here naming the page they were presenting, so leaving the room view
// lands on that page rather than at the top of the roster (P4b).
const openEntryId = new URLSearchParams(location.search).get('entry_id');
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const D = { campaign: null, isGm: false, roster: [], journal: [], classNames: {}, amt: 5,
            // The GM's own pages (migration 078) and the one open in the editor.
            entries: [], entry: null, entryImages: [] };
const $ = (i) => document.getElementById(i);

// api() and errorDetails() come from js/api.js, loaded first as a classic script.

async function load() {
  try {
    const [campRes, rosterRes, journalRes, classesRes] = await Promise.all([
      api('campaigns/' + campaignId),
      api('characters?campaign_id=' + campaignId),
      api('journal?campaign_id=' + campaignId),
      // The names projection: this page only ever turns a class_id into a
      // label, and the full list is ~750KB of parsed markdown. Retired classes
      // are included by the projection itself, so a character on one keeps
      // its label.
      api('classes?names=1'),
    ]);
    D.campaign = campRes.campaign; D.isGm = campRes.is_gm;
    window.appnav?.setContext({ campaignId, campaignName: D.campaign?.name });
    D.roster = partyFirst(rosterRes.characters);
    D.journal = journalRes.entries;
    D.journalTotal = journalRes.total ?? journalRes.entries.length;
    D.classNames = Object.fromEntries(classesRes.classes.map((c) => [c.id, c.name]));
    // After the campaign, because it is GM-only and isGm is what decides
    // whether to ask at all - a player's dashboard makes no request for it.
    await loadEntries();
    render();
    // After that first render, so a page that will not open has somewhere to
    // say so: setMsg writes into markup that does not exist until now. Gated
    // on isGm for the same reason loadEntries is - a player handed this URL
    // makes no request for a page they could not be shown anyway.
    if (D.isGm && openEntryId) await openEntry(openEntryId);
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
  }
}

// THE ACTIVE FORM (Nightbane follow-up 5, 2026-09-17). A roster row whose
// character holds a second body carries `second_form` - its names, which form
// is active, and that form's own S.D.C. and hit points - and while the second
// form is active its pools are the ones shown, stepped and damaged, through
// derive.activePools / playChanges, the pair the sheet routes through. A row
// without one is drawn from `c` exactly as before.
const pools = (c) => derive.activePools(c, c.second_form);
function formTag(c) {
  const f = c.second_form;
  if (!f) return '';
  const name = f.active === 'second' ? f.name : f.first_name;
  return name ? `<span class="tag" title="The form this character is in">${escHtml(name)}</span> ` : '';
}

function poolsCell(c) {
  const p = pools(c);
  const parts = POOLS
    .filter(([k]) => p[k + '_max'] != null || p[k + '_current'] != null)
    .map(([k, label]) => `${label} ${p[k + '_current'] ?? '—'}/${p[k + '_max'] ?? '—'}`);
  return formTag(c) + (parts.join(' · ') || '—');
}

// ---------- the G.M.'s table view (UI-AUDIT F46) ----------
//
// The roster was text, loaded once: a G.M. tracking five characters opened five
// sheets. For the G.M. only, each row now carries its pools with − and + at the
// chosen amount, a Damage that runs the sheet's own cascade
// (derive.damageCascade), and ↶ for that character's last change. EVERY PRESS
// GOES THROUGH THAT CHARACTER'S OWN EVENTS ROUTE, so it lands in their session
// log and their undo exactly as a press on their sheet would, and the note says
// the G.M. made it. Party-wide initiative stays out: docs/campaign-and-play.md
// records it as deliberately unbuilt, and this does not reopen it.
// The G.M.'s statted NPCs (migration 070) ride in the same roster - the server
// sends them to the G.M. alone - so a fight's hit points are tracked here with
// the same controls. Listed AFTER the party and tagged, so "the party" still
// reads as the party.
function partyFirst(list) {
  return [...(list || [])].sort((a, b) => (a.kind === 'npc') - (b.kind === 'npc'));
}

function rosterRowHtml(c) {
  return `<tr id="roster-${c.id}">
      <td><a href="/apps/character-sheet/?id=${c.id}">${escHtml(c.name)}</a>${
        c.kind === 'npc' ? ' <span class="tag">NPC</span>' : ''}</td>
      <td>${escHtml(String(c.class_id).startsWith('notable:') ? 'From the books'
        : String(c.class_id).startsWith('creature:') ? 'A creature from the books'
        : D.classNames[c.class_id] || c.class_id)}${c.occ_class_id ? ' ' + escHtml(D.classNames[c.occ_class_id] || c.occ_class_id) : ''}</td>
      <td>${c.level} <span class="muted small">(${c.xp} XP)</span></td>
      <td class="muted small">${escHtml(c.player_email)}</td>
      <td class="pools-cell">${D.isGm ? gmPoolsCell(c) : poolsCell(c)}</td>
    </tr>`;
}

function gmPoolsCell(c) {
  const p = pools(c);
  const shown = POOLS.filter(([k]) => p[k + '_max'] != null || p[k + '_current'] != null);
  if (!shown.length) return '—';
  return `<div class="gm-pools">${formTag(c)}${shown.map(([k, label]) => `<span class="gm-pool">
        <span class="muted small">${label}</span> <b>${p[k + '_current'] ?? '—'}</b><span class="muted small">/${p[k + '_max'] ?? '—'}</span>
        <button type="button" class="gm-step" aria-label="${escHtml(c.name)} ${label} down" onclick="gmStep(${c.id}, '${k}', -1)">−</button>
        <button type="button" class="gm-step" aria-label="${escHtml(c.name)} ${label} up" onclick="gmStep(${c.id}, '${k}', 1)">+</button>
      </span>`).join('')}
      <span class="gm-acts">
        <button type="button" class="btn btn-sm" onclick="gmDamage(${c.id})">💥 Damage</button>
        <button type="button" class="btn btn-sm btn-ghost" aria-label="Undo ${escHtml(c.name)}'s last change"
          title="Undo the last change" onclick="gmUndo(${c.id})">↶</button>
      </span></div>`;
}

function gmToolbarHtml() {
  const chips = [1, 5, 10].map((n) =>
    `<button type="button" class="gm-amt${D.amt === n ? ' on' : ''}" data-amt="${n}" onclick="gmAmt(${n})">${n}</button>`).join('');
  return `<div class="gm-toolbar noprint">
      <span class="muted small">Amount</span>${chips}
      <input type="number" id="gm-amt-custom" class="gm-amt-custom" min="1" placeholder="#"
        aria-label="Any other amount" value="${[1, 5, 10].includes(D.amt) ? '' : D.amt}">
      <span class="gm-xp">
        <input type="number" id="gm-xp" placeholder="XP" aria-label="XP to award each character">
        <button type="button" class="btn btn-sm" onclick="awardPartyXp()">Award XP to party</button>
      </span>
      <span id="gm-msg" class="muted small" role="status" aria-live="polite"></span>
    </div>`;
}

function gmAmt(n, fromField) {
  D.amt = n;
  document.querySelectorAll('.gm-amt').forEach((b) => b.classList.toggle('on', Number(b.dataset.amt) === n));
  if (!fromField) { const f = $('gm-amt-custom'); if (f) f.value = ''; }
}
document.addEventListener('input', (ev) => {
  if (ev.target?.id !== 'gm-amt-custom') return;
  const n = Math.trunc(Number(ev.target.value));
  if (n > 0) gmAmt(n, true);
});

function gmMsg(text, isErr) {
  const el = $('gm-msg');
  if (el) { el.textContent = text; el.className = (isErr ? 'err' : 'muted') + ' small'; }
}

function repaintRow(c) {
  const tr = $('roster-' + c.id);
  if (tr) tr.outerHTML = rosterRowHtml(c);
}

const postJson = (path, body) => api(path, {
  method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
});

// The server names the form in the event's note; the message here says it too,
// so the G.M. sees which body took it without opening the log.
const formLabel = (c) => (c.second_form?.active === 'second' && c.second_form.name ? ` (${c.second_form.name})` : '');

async function gmStep(id, key, sign) {
  const c = D.roster.find((x) => x.id === id);
  const from = c ? pools(c)[key + '_current'] : null;
  if (!c || from == null) return;
  const changes = derive.playChanges(c, c.second_form, { [key + '_current']: from + sign * D.amt });
  try {
    await postJson(`characters/${id}/events`, {
      kind: 'pool', note: `G.M.: ${key.toUpperCase()} ${sign > 0 ? '+' : '−'}${D.amt}`, changes,
    });
    derive.applyPlayChanges(c, c.second_form, changes);
    repaintRow(c);
  } catch (err) { gmMsg(`${c.name}: ${err.message}`, true); }
}

async function gmDamage(id) {
  const c = D.roster.find((x) => x.id === id);
  if (!c) return;
  const patch = derive.damageCascade(pools(c), D.amt);
  if (!Object.keys(patch).length) return;
  const changes = derive.playChanges(c, c.second_form, patch);
  try {
    await postJson(`characters/${id}/events`, { kind: 'damage', note: `G.M.: took ${D.amt}`, changes });
    derive.applyPlayChanges(c, c.second_form, changes);
    repaintRow(c);
    gmMsg(`${c.name}${formLabel(c)} took ${D.amt}.`);
  } catch (err) { gmMsg(`${c.name}: ${err.message}`, true); }
}

async function gmUndo(id) {
  const c = D.roster.find((x) => x.id === id);
  if (!c) return;
  try {
    const res = await postJson(`characters/${id}/events/undo`, {});
    derive.applyPlayChanges(c, c.second_form,
      { character: res.restored?.character, second_form: res.restored?.second_form }, null);
    repaintRow(c);
    gmMsg(`${c.name}: took back ${res.undone?.note || res.undone?.kind || 'the last change'}.`);
  } catch (err) {
    gmMsg(`${c.name}: ${err.message === 'Nothing to undo' ? 'nothing to undo' : err.message}`, true);
  }
}

// One amount to everyone, through each character's own XP route. The route
// raises XP and PROPOSES any level-up rather than applying it, so a crossed
// threshold is reported here and taken on that character's sheet, where the
// banner from UI-AUDIT F42 is waiting. Asked about first: it is a bulk write.
async function awardPartyXp() {
  const delta = parseInt($('gm-xp')?.value, 10);
  if (!Number.isFinite(delta) || !delta) { gmMsg('Enter an amount of XP to award.', true); return; }
  // The PARTY: the G.M.'s statted NPCs share this roster for hit-point
  // tracking, and do not earn the party's experience.
  const party = D.roster.filter((c) => c.kind !== 'npc');
  if (!confirm(`Award ${delta} XP to each of the ${party.length} characters in this campaign?`)) return;
  const ready = [], failed = [];
  for (const c of party) {
    try {
      const res = await postJson(`characters/${c.id}/xp`, { delta });
      c.xp = res.xp;
      if (res.proposal) ready.push(c.name);
      repaintRow(c);
    } catch (err) { failed.push(`${c.name} (${err.message})`); }
  }
  const f = $('gm-xp'); if (f) f.value = '';
  gmMsg(`Awarded ${delta} XP to ${party.length - failed.length} of ${party.length}.`
    + (ready.length ? ` A level-up is waiting on the sheet of ${ready.join(', ')}.` : '')
    + (failed.length ? ` Failed: ${failed.join('; ')}.` : ''), failed.length > 0);
}

// Players take damage on their own sheets while the G.M. is looking elsewhere.
// The roster refreshes whenever this tab comes back into view, and repaints
// only its rows, so a half-typed G.M. note is never rebuilt out from under the
// keyboard.
async function refreshRoster() {
  if (!campaignId || !D.campaign || document.visibilityState === 'hidden') return;
  try {
    const res = await api('characters?campaign_id=' + campaignId);
    D.roster = partyFirst(res.characters);
    const body = $('roster-rows');
    if (body) body.innerHTML = D.roster.map(rosterRowHtml).join('');
  } catch { /* keep what is on screen */ }
}
document.addEventListener('visibilitychange', refreshRoster);
window.addEventListener('focus', refreshRoster);

function render() {
  const camp = D.campaign;
  const charName = Object.fromEntries(D.roster.map((c) => [c.id, c.name]));

  const rosterRows = D.roster.map(rosterRowHtml).join('');

  const journalHtml = D.journal.slice(0, 20).map((e) => {
    const isCampaign = e.character_id == null;
    const who = isCampaign ? 'campaign' : (charName[e.character_id] || 'character #' + e.character_id);
    return `<div class="entry ${isCampaign ? 'campaign' : ''}">
      <span class="tag ${isCampaign ? 'gm' : ''}">${escHtml(who)}</span>
      <b>${escHtml(e.title || 'Untitled')}</b>
      <span class="muted small"> — ${escHtml(e.author_email)}${e.session_date ? ' · session ' + escHtml(e.session_date) : ''} · ${escHtml(e.created_at)}</span>
      <div class="body">${escHtml(e.body)}</div>
    </div>`;
  }).join('') || '<p class="muted small">No journal entries yet.</p>';

  // The dashboard already showed only the newest 20; now that the fetch itself
  // is bounded, say what the 20 is out of.
  const journalMore = D.journalTotal > Math.min(D.journal.length, 20)
    ? `<p class="muted small">Showing the 20 most recent of ${D.journalTotal} entries.</p>`
    : '';

  // The roster and the GM notes share a row; the journal runs full width
  // under them. The grid class is only set when there is something to put in
  // the rail - the notes panel is GM-only, and a player should get the whole
  // width for the roster rather than a 380px column of nothing beside it.
  $('app').innerHTML = `
  <div class="${D.isGm ? 'dash-grid' : ''}">
  <div class="panel">
    <h2>${escHtml(camp.name)} ${D.isGm ? '<span class="tag gm">you are the GM</span>' : ''}</h2>
    <p class="muted">${escHtml(camp.system)} · GM: ${escHtml(camp.gm_email)}${camp.description ? ' — ' + escHtml(camp.description) : ''}</p>
    <h3>Party roster</h3>
    ${D.isGm && rosterRows ? gmToolbarHtml() : ''}
    ${rosterRows
      ? `<div class="roster-scroll"><table><thead><tr><th>Character</th><th>Class</th><th>Level</th><th>Player</th><th>Pools (cur/max)</th></tr></thead>
          <tbody id="roster-rows">${rosterRows}</tbody></table></div>`
      : '<p class="muted small">No characters in this campaign yet.</p>'}
  </div>

  ${D.isGm ? `
  <div class="panel">
    <h3 style="margin-top:0">GM notes <span class="muted small">(only you can see or edit these)</span></h3>
    <textarea id="gm-notes">${escHtml(camp.gm_notes || '')}</textarea>
    <div class="rowline"><button class="btn btn-primary" onclick="saveNotes()">💾 Save GM notes</button><span id="notes-msg" class="muted small"></span></div>
    <label class="small"><input type="checkbox" id="camp-open" ${camp.open ? 'checked' : ''} onchange="saveOpen(this.checked)">
      Open to new characters
      <span class="muted">— anyone on the site can join this campaign by creating one here; unticked, only you and current players can</span>
      <span id="open-msg" class="muted small"></span></label>
    ${restRatesHtml(camp)}
  </div>` : ''}
  </div>

  ${D.isGm ? settingHtml() : ''}

  <div class="panel">
    <h3 style="margin-top:0">Campaign journal <span class="muted small">(newest first)</span></h3>
    ${journalHtml}
    ${journalMore}
    <p class="small"><a href="/apps/campaign/?campaign_id=${campaignId}">🗒 Open campaign notes</a>
      <span class="muted">— search the log, ask a question of it, and track what the party holds</span></p>
  </div>`;
}

// ─── the setting: the GM's own pages, and the pictures shown from them ───
//
// An ENTRY is the GM's notebook and is never revealed. An IMAGE is revealed one
// at a time, and its CAPTION is the only text a player reads (migration 078).
// So the editor below puts the reveal switch on the picture, never on the page,
// and the caption field sits beside it rather than under the body.
//
// PRESENT MODE (P4b) IS A PAGE OF ITS OWN - present.html, black and
// chromeless, one picture fitted to the screen. It is a LINK rather than a
// button so a GM with a second screen can open it there. Presenting a picture
// does NOT reveal it: the switch below is still the only thing that does, and
// present.html carries its own copy of that switch for the same reason the
// caption field sits beside the picture here.
const KINDS = ['place', 'faction', 'lore', 'handout', 'prep'];
const KIND_LABEL = { place: 'Place', faction: 'Faction', lore: 'Lore', handout: 'Handout', prep: 'Session prep' };

const presentUrl = (imageId) =>
  `present.html?campaign_id=${encodeURIComponent(campaignId)}&entry_id=${D.entry.id}`
  + (imageId ? `&image_id=${imageId}` : '');

function settingHtml() {
  const rows = D.entries.map((e) => `<li class="home-row${D.entry?.id === e.id ? ' on' : ''}">
      <span class="home-what">
        <a href="#" onclick="openEntry(${e.id}); return false;"><b>${escHtml(e.title)}</b></a>
        <span class="muted small">${escHtml(KIND_LABEL[e.kind] || e.kind)}
          ${e.image_count ? ` · ${e.image_count} picture${e.image_count === 1 ? '' : 's'}` : ''}
          ${e.revealed_count ? ` · ${e.revealed_count} shown` : ''}</span>
      </span>
    </li>`).join('');

  return `<div class="panel">
    <h3 style="margin-top:0">Setting <span class="muted small">(your pages — players never see these, only pictures you reveal)</span></h3>
    <div class="rowline">
      <input id="entry-title" class="mini-in wide" placeholder="A place, a faction, next session…" maxlength="200">
      <select id="entry-kind" class="mini-in">
        ${KINDS.map((k) => `<option value="${k}">${escHtml(KIND_LABEL[k])}</option>`).join('')}
      </select>
      <button class="btn btn-primary" onclick="newEntry()">+ New page</button>
      <span id="entry-msg" class="muted small"></span>
    </div>
    ${rows ? `<ul class="home-list">${rows}</ul>`
      : '<p class="muted small">No pages yet. A page holds your notes and the pictures you show from them.</p>'}
    ${D.entry ? entryEditorHtml() : ''}
  </div>`;
}

function entryEditorHtml() {
  const e = D.entry;
  const pics = D.entryImages.map((i) => `<li class="setting-pic">
      <img src="/api/character-creator/campaigns/${campaignId}/images/${i.id}" alt="${escHtml(i.caption || 'Picture')}" loading="lazy">
      <div class="setting-pic-meta">
        <input class="mini-in wide" value="${escHtml(i.caption || '')}" placeholder="Caption — the one thing players read"
               onchange="saveCaption(${i.id}, this.value)">
        <div class="rowline">
          <a class="btn btn-sm" href="${presentUrl(i.id)}" title="Show this on a screen at the table. It does not reveal it.">▶ Present</a>
          <button class="btn btn-sm ${i.revealed_at ? '' : 'btn-primary'}" onclick="toggleReveal(${i.id}, ${i.revealed_at ? 'false' : 'true'})">
            ${i.revealed_at ? '🙈 Hide from players' : '👁 Reveal to players'}</button>
          <span class="muted small">${i.revealed_at ? 'shown ' + escHtml(i.revealed_at) : 'only you can see this'}</span>
          <button class="btn btn-sm btn-danger" onclick="deletePicture(${i.id})">Delete</button>
        </div>
      </div>
    </li>`).join('');

  return `<div class="setting-editor">
    <div class="rowline">
      <input id="edit-title" class="mini-in wide" value="${escHtml(e.title)}" maxlength="200">
      <select id="edit-kind" class="mini-in">
        ${KINDS.map((k) => `<option value="${k}" ${k === e.kind ? 'selected' : ''}>${escHtml(KIND_LABEL[k])}</option>`).join('')}
      </select>
      <button class="btn btn-primary" onclick="saveEntry()">💾 Save</button>
      ${D.entryImages.length ? `<a class="btn" href="${presentUrl()}">▶ Present page</a>` : ''}
      <button class="btn btn-sm" onclick="closeEntry()">Close</button>
      <button class="btn btn-sm btn-danger" onclick="deleteEntry()">Delete page</button>
      <span id="edit-msg" class="muted small"></span>
    </div>
    <textarea id="edit-body" placeholder="Your notes. Never revealed.">${escHtml(e.body || '')}</textarea>
    <div class="rowline">
      <label class="btn btn-sm">📷 Add a picture
        <input type="file" accept="image/jpeg,image/png,image/webp,image/gif" style="display:none"
               onchange="uploadPicture(this)"></label>
      ${/* This used to lead with the server's byte cap, which stopped being the
            thing a GM runs into: a big photo is shrunk to 2048px on its longest
            edge before it is sent (UI-AUDIT F57), so that cap is now reached by
            very few pictures rather than by every phone photo. An animated gif
            is sent as it is, because re-encoding one flattens it. */''}
      <span class="muted small">jpg/png/webp/gif. Big pictures are shrunk to
        ${downscale.MAX_EDGE}px before they upload; a gif is sent as it is.
        A picture arrives hidden.
        <b>Present</b> shows it on a screen at the table and changes nothing;
        <b>Reveal</b> puts it in the players' Handouts to keep.</span>
      <span id="upload-msg" class="muted small"></span>
    </div>
    ${pics ? `<ul class="setting-pics">${pics}</ul>` : ''}
  </div>`;
}

async function loadEntries() {
  if (!D.isGm) return;
  try {
    D.entries = (await api(`campaigns/${campaignId}/entries`)).entries || [];
  } catch { D.entries = []; }
}

async function newEntry() {
  const title = $('entry-title').value.trim();
  if (!title) { setMsg('entry-msg', 'A page needs a title.', true); return; }
  try {
    const res = await api(`campaigns/${campaignId}/entries`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title, kind: $('entry-kind').value }),
    });
    await loadEntries();
    await openEntry(res.entry.id);
  } catch (err) { setMsg('entry-msg', err.message, true); }
}

async function openEntry(id) {
  try {
    const res = await api(`campaigns/${campaignId}/entries/${id}`);
    D.entry = res.entry; D.entryImages = res.images || [];
    render();
  } catch (err) { setMsg('entry-msg', err.message, true); }
}

function closeEntry() { D.entry = null; D.entryImages = []; render(); }

async function saveEntry() {
  try {
    const res = await api(`campaigns/${campaignId}/entries/${D.entry.id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: $('edit-title').value.trim(), kind: $('edit-kind').value, body: $('edit-body').value }),
    });
    D.entry = res.entry;
    await loadEntries();
    render();
    setMsg('edit-msg', 'Saved.');
  } catch (err) { setMsg('edit-msg', err.message, true); }
}

// The confirmation says what goes with it, as the character delete does: the
// pictures are deleted from storage too, and that cannot be undone.
async function deleteEntry() {
  const n = D.entryImages.length;
  if (!confirm(`Delete "${D.entry.title}"?\n\n${n ? `Its ${n} picture${n === 1 ? '' : 's'} ` : 'Nothing else '}`
    + `goes with it, including any the party has already been shown. This cannot be undone.`)) return;
  try {
    await api(`campaigns/${campaignId}/entries/${D.entry.id}`, { method: 'DELETE' });
    D.entry = null; D.entryImages = [];
    await loadEntries();
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
    const res = await api(`campaigns/${campaignId}/entries/${D.entry.id}/images`, {
      method: 'POST', headers: { 'Content-Type': body.type }, body,
    });
    D.entryImages.push(res.image);
    await loadEntries();
    render();
    setMsg('upload-msg', 'Added, hidden from players.');
  } catch (err) { setMsg('upload-msg', err.message, true); }
}

async function patchImage(id, body, msgId) {
  try {
    const res = await api(`campaigns/${campaignId}/images/${id}`, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    const at = D.entryImages.findIndex((i) => i.id === id);
    if (at >= 0) D.entryImages[at] = res.image;
    await loadEntries();
    render();
  } catch (err) { setMsg(msgId, err.message, true); }
}

const toggleReveal = (id, on) => patchImage(id, { revealed: on }, 'edit-msg');
const saveCaption = (id, caption) => patchImage(id, { caption }, 'edit-msg');

async function deletePicture(id) {
  if (!confirm('Delete this picture? It goes from storage too, and from anything the party has been shown.')) return;
  try {
    await api(`campaigns/${campaignId}/images/${id}`, { method: 'DELETE' });
    D.entryImages = D.entryImages.filter((i) => i.id !== id);
    await loadEntries();
    render();
  } catch (err) { setMsg('edit-msg', err.message, true); }
}

function setMsg(id, text, isErr) {
  const el = $(id);
  if (!el) return;
  el.textContent = text;
  el.className = isErr ? 'err small' : 'muted small';
}

// The join gate. Joining a campaign IS creating a character in it, so whether
// creation is open to the site is the GM's call — enforced by POST /characters,
// toggled here.
async function saveOpen(open) {
  try {
    await api('campaigns/' + campaignId, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ open }),
    });
    D.campaign.open = open ? 1 : 0;
    $('open-msg').textContent = open ? 'Open.' : 'Closed.';
    $('open-msg').className = 'muted small';
  } catch (err) {
    $('open-msg').textContent = 'Save failed: ' + err.message;
    $('open-msg').className = 'err small';
  }
}

// The table's rest rates, set once here for everyone in the campaign
// (UI-AUDIT F52). They lived in one device's localStorage, so a player on a new
// phone started blank. Blank or 0 means the table has no rate for that pool;
// the app still ships no default.
const REST_POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
function restRatesHtml(camp) {
  let rates = {};
  try { rates = camp.rest_rates ? JSON.parse(camp.rest_rates) : {}; } catch { rates = {}; }
  return `<div class="gm-rest">
      <h4 style="margin:12px 0 4px">Rest rates <span class="muted small">— per hour, for every sheet in this campaign</span></h4>
      <div class="gm-rest-rows">${REST_POOLS.map(([k, label]) => `<label class="small">${label}
        <input type="number" min="0" step="any" id="rest-${k}" value="${rates[k] ?? ''}" placeholder="0" style="width:70px"></label>`).join('')}</div>
      <div class="rowline"><button class="btn btn-sm" onclick="saveRestRates()">Save rest rates</button>
        <span id="rest-msg" class="muted small"></span></div>
    </div>`;
}

async function saveRestRates() {
  const rest_rates = {};
  for (const [k] of REST_POOLS) {
    const v = $('rest-' + k)?.value;
    if (v !== '' && v != null) rest_rates[k] = Number(v);
  }
  try {
    await api('campaigns/' + campaignId, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ rest_rates }),
    });
    D.campaign.rest_rates = Object.values(rest_rates).some((n) => n > 0) ? JSON.stringify(rest_rates) : null;
    $('rest-msg').textContent = 'Saved.';
    $('rest-msg').className = 'muted small';
  } catch (err) {
    $('rest-msg').textContent = 'Save failed: ' + err.message;
    $('rest-msg').className = 'err small';
  }
}

async function saveNotes() {
  try {
    await api('campaigns/' + campaignId, {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ gm_notes: $('gm-notes').value }),
    });
    $('notes-msg').textContent = 'Saved.';
    $('notes-msg').className = 'muted small';
  } catch (err) {
    $('notes-msg').textContent = 'Save failed: ' + err.message;
    $('notes-msg').className = 'err small';
  }
}

if (!campaignId) {
  // Opened with no campaign: list the caller's own instead of ending on an
  // error (UI-AUDIT F39). A player had no other road to this page.
  campaignList.load()
    .then((list) => {
      $('app').innerHTML = `<div class="panel"><h2>Your campaigns</h2>${campaignList.html(list)}</div>`;
    })
    .catch((err) => {
      $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
    });
} else {
  load();
}
