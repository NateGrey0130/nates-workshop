// Campaign dashboard — party roster, GM notes, campaign journal feed.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const campaignId = new URLSearchParams(location.search).get('campaign_id');
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const D = { campaign: null, isGm: false, roster: [], journal: [], classNames: {} };
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
    D.roster = rosterRes.characters;
    D.journal = journalRes.entries;
    D.journalTotal = journalRes.total ?? journalRes.entries.length;
    D.classNames = Object.fromEntries(classesRes.classes.map((c) => [c.id, c.name]));
    render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
  }
}

function poolsCell(c) {
  const parts = POOLS
    .filter(([k]) => c[k + '_max'] != null || c[k + '_current'] != null)
    .map(([k, label]) => `${label} ${c[k + '_current'] ?? '—'}/${c[k + '_max'] ?? '—'}`);
  return parts.join(' · ') || '—';
}

function render() {
  const camp = D.campaign;
  const charName = Object.fromEntries(D.roster.map((c) => [c.id, c.name]));

  const rosterRows = D.roster.map((c) => `
    <tr>
      <td><a href="sheet.html?id=${c.id}">${escHtml(c.name)}</a></td>
      <td>${escHtml(D.classNames[c.class_id] || c.class_id)}${c.occ_class_id ? ' ' + escHtml(D.classNames[c.occ_class_id] || c.occ_class_id) : ''}</td>
      <td>${c.level} <span class="muted small">(${c.xp} XP)</span></td>
      <td class="muted small">${escHtml(c.player_email)}</td>
      <td class="pools-cell">${poolsCell(c)}</td>
    </tr>`).join('');

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
    ${rosterRows
      ? `<table><tr><th>Character</th><th>Class</th><th>Level</th><th>Player</th><th>Pools (cur/max)</th></tr>${rosterRows}</table>`
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
  </div>` : ''}
  </div>

  <div class="panel">
    <h3 style="margin-top:0">Campaign journal <span class="muted small">(newest first)</span></h3>
    ${journalHtml}
    ${journalMore}
    <p class="small"><a href="campaign.html?campaign_id=${campaignId}">🗒 Open campaign notes</a>
      <span class="muted">— search the log, ask a question of it, and track what the party holds</span></p>
  </div>`;
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
  $('app').innerHTML = '<div class="panel"><p class="err">No campaign_id — open a dashboard from the Character Creator landing page.</p></div>';
} else {
  load();
}
