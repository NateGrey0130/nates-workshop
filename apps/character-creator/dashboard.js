// Campaign dashboard — party roster, GM notes, campaign journal feed.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const campaignId = new URLSearchParams(location.search).get('campaign_id');
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const D = { campaign: null, isGm: false, roster: [], journal: [], classNames: {}, amt: 5 };
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
function rosterRowHtml(c) {
  return `<tr id="roster-${c.id}">
      <td><a href="sheet.html?id=${c.id}">${escHtml(c.name)}</a></td>
      <td>${escHtml(D.classNames[c.class_id] || c.class_id)}${c.occ_class_id ? ' ' + escHtml(D.classNames[c.occ_class_id] || c.occ_class_id) : ''}</td>
      <td>${c.level} <span class="muted small">(${c.xp} XP)</span></td>
      <td class="muted small">${escHtml(c.player_email)}</td>
      <td class="pools-cell">${D.isGm ? gmPoolsCell(c) : poolsCell(c)}</td>
    </tr>`;
}

function gmPoolsCell(c) {
  const pools = POOLS.filter(([k]) => c[k + '_max'] != null || c[k + '_current'] != null);
  if (!pools.length) return '—';
  return `<div class="gm-pools">${pools.map(([k, label]) => `<span class="gm-pool">
        <span class="muted small">${label}</span> <b>${c[k + '_current'] ?? '—'}</b><span class="muted small">/${c[k + '_max'] ?? '—'}</span>
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

async function gmStep(id, key, sign) {
  const c = D.roster.find((x) => x.id === id);
  if (!c || c[key + '_current'] == null) return;
  const from = c[key + '_current'];
  const to = from + sign * D.amt;
  try {
    await postJson(`characters/${id}/events`, {
      kind: 'pool', note: `G.M.: ${key.toUpperCase()} ${sign > 0 ? '+' : '−'}${D.amt}`,
      changes: { character: { [key + '_current']: { from, to } } },
    });
    c[key + '_current'] = to;
    repaintRow(c);
  } catch (err) { gmMsg(`${c.name}: ${err.message}`, true); }
}

async function gmDamage(id) {
  const c = D.roster.find((x) => x.id === id);
  if (!c) return;
  const patch = derive.damageCascade(c, D.amt);
  const fields = Object.fromEntries(Object.entries(patch).map(([k, to]) => [k, { from: c[k] ?? 0, to }]));
  if (!Object.keys(fields).length) return;
  try {
    await postJson(`characters/${id}/events`, { kind: 'damage', note: `G.M.: took ${D.amt}`, changes: { character: fields } });
    Object.assign(c, patch);
    repaintRow(c);
    gmMsg(`${c.name} took ${D.amt}.`);
  } catch (err) { gmMsg(`${c.name}: ${err.message}`, true); }
}

async function gmUndo(id) {
  const c = D.roster.find((x) => x.id === id);
  if (!c) return;
  try {
    const res = await postJson(`characters/${id}/events/undo`, {});
    Object.assign(c, res.restored?.character || {});
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
  if (!confirm(`Award ${delta} XP to each of the ${D.roster.length} characters in this campaign?`)) return;
  const ready = [], failed = [];
  for (const c of D.roster) {
    try {
      const res = await postJson(`characters/${c.id}/xp`, { delta });
      c.xp = res.xp;
      if (res.proposal) ready.push(c.name);
      repaintRow(c);
    } catch (err) { failed.push(`${c.name} (${err.message})`); }
  }
  const f = $('gm-xp'); if (f) f.value = '';
  gmMsg(`Awarded ${delta} XP to ${D.roster.length - failed.length} of ${D.roster.length}.`
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
    D.roster = res.characters;
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
