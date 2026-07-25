// Character sheet — stats, skills, powers, inventory, journal, level-up.
// Owner/GM see edit controls; the server enforces the same rules regardless.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const POOL_LABELS = { hp_max: 'H.P. max', sdc_max: 'S.D.C. max', mdc_max: 'M.D.C. max', ppe_max: 'P.P.E. max', isp_max: 'I.S.P. max' };
const id = new URLSearchParams(location.search).get('id');

const C = { data: null, items: [], journal: [], catalog: [], canWrite: false, isGm: false,
            proposal: null, nextThreshold: null };
const $ = (i) => document.getElementById(i);

async function api(path, opts) {
  const res = await fetch('/api/character-creator/' + path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || ('API ' + res.status));
  return data;
}
const jsonReq = (method, body) => ({ method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

async function load() {
  try {
    const res = await api('characters/' + id);
    C.data = res.character; C.items = res.items; C.canWrite = res.can_write; C.isGm = res.is_gm;
    const [journal, catalog] = await Promise.all([
      api('journal?campaign_id=' + C.data.campaign_id),
      api('items?system=' + encodeURIComponent(C.data.campaign_system)),
    ]);
    C.journal = journal.entries; C.catalog = catalog.items;
    render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
  }
}

function flash(text, isError) {
  const el = $('msg');
  if (el) { el.textContent = text; el.className = isError ? 'err small' : 'muted small'; }
}

function render() {
  const c = C.data, w = C.canWrite;
  const skills = Array.isArray(c.skills) ? c.skills : [];
  const powers = Array.isArray(c.powers) ? c.powers : [];
  const byType = (t) => skills.filter((s) => s.type === t);
  const skillLine = (list) => list.map((s) =>
    escHtml(s.name) + (s.pct ? ` ${s.pct}%` + (s.per_level ? ` <span class="muted">(+${s.per_level}/lvl)</span>` : '') : '')
  ).join(' · ') || '—';

  const poolCells = POOLS.map(([key, label]) => {
    const max = c[key + '_max'], cur = c[key + '_current'];
    if (max == null && cur == null) return '';
    const curHtml = w
      ? `<input type="number" id="stat-${key}" value="${cur ?? ''}" style="width:64px"><b class="print-only">${cur ?? '—'}</b>`
      : `<b>${cur ?? '—'}</b>`;
    return `<div class="pool"><div class="lbl">${label}</div><div class="val">${curHtml} / ${max ?? '—'}</div></div>`;
  }).join('');

  const invRows = C.items.map((it) => {
    const name = escHtml(it.item_name || it.custom_name);
    const kind = it.item_id ? '<span class="tag">catalog</span>' : '<span class="tag">custom</span>';
    const qty = w
      ? `<input type="number" min="1" value="${it.qty}" onchange="patchItem(${it.id}, {qty: this.value})"><span class="print-only">×${it.qty}</span>`
      : `×${it.qty}`;
    const eq = w
      ? `<input type="checkbox" ${it.equipped ? 'checked' : ''} onchange="patchItem(${it.id}, {equipped: this.checked})"><span class="print-only">${it.equipped ? '✔' : '—'}</span>`
      : (it.equipped ? '✔' : '');
    const rm = w ? `<td><button class="btn btn-sm btn-ghost" onclick="removeItem(${it.id})">✕</button></td>` : '<td></td>';
    return `<tr><td>${name} ${kind}</td><td>${qty}</td><td>${eq}</td>
      <td class="muted small">${escHtml(it.notes || '')}</td>${rm}</tr>`;
  }).join('');

  const journalHtml = C.journal.map((e) => {
    const isCampaign = e.character_id == null;
    const mine = e.character_id == c.id;
    if (!isCampaign && !mine) return ''; // other party members' entries stay off this sheet
    return `<div class="entry ${isCampaign ? 'campaign' : ''}">
      <span class="tag ${isCampaign ? 'gm' : ''}">${isCampaign ? 'campaign' : 'character'}</span>
      <b>${escHtml(e.title || 'Untitled')}</b>
      <span class="muted small"> — ${escHtml(e.author_email)}${e.session_date ? ' · session ' + escHtml(e.session_date) : ''} · ${escHtml(e.created_at)}</span>
      <div class="body">${escHtml(e.body)}</div>
    </div>`;
  }).join('') || '<p class="muted small">No journal entries yet.</p>';

  const catalogOpts = C.catalog.map((it) => `<option value="${escHtml(it.slug)}">${escHtml(it.name)}</option>`).join('');

  $('app').innerHTML = `
  <div class="panel">
    <h2>${escHtml(c.name)}
      ${w ? '' : '<span class="tag ro">read-only</span>'}${C.isGm ? '<span class="tag gm">GM</span>' : ''}</h2>
    <p class="muted">${escHtml(c.class_id)} · Level ${c.level} · ${c.xp} XP · Campaign: ${escHtml(c.campaign_name)} (${escHtml(c.campaign_system)}) · Player: ${escHtml(c.player_email)}</p>

    <h3>Attributes</h3>
    <div>${ATTRS.map((a) => `<span class="statline">${a}: <b>${(c.attributes || {})[a] ?? '—'}</b></span>`).join('')}</div>

    <h3>Pools <span class="muted small">(current / max)</span></h3>
    <div class="pools">${poolCells}</div>
    ${powers.length ? `<h3>Spells &amp; Psionics</h3>${powers.map((p, i) => {
      const pool = p.type === 'spell' ? 'ppe' : 'isp';
      const cost = typeof p.cost === 'number' ? p.cost : null;
      const meta = [p.type === 'spell' ? (p.level != null ? 'spell L' + p.level : 'spell') : (p.category ? 'psionic · ' + p.category : 'psionic'),
                    cost != null ? cost + ' ' + (pool === 'ppe' ? 'P.P.E.' : 'I.S.P.') : null].filter(Boolean).join(' · ');
      const useBtn = w && cost != null && c[pool + '_current'] != null
        ? ` <button class="btn btn-sm btn-ghost" onclick="usePower(${i})">⚡ use</button>` : '';
      return `<div class="rowline" style="margin:2px 0"><span class="small">${escHtml(p.name)}
        <span class="muted">(${escHtml(meta)})</span></span>${useBtn}</div>`;
    }).join('')}` : ''}

    <h3>Experience</h3>
    <div class="rowline">
      <span class="small">XP: <b>${c.xp}</b> · Level <b>${c.level}</b>${C.nextThreshold != null ? ` <span class="muted">(next level at ${C.nextThreshold} XP)</span>` : ''}</span>
      ${w ? `<input type="number" id="xp-delta" placeholder="+XP" style="width:84px">
             <button class="btn btn-sm" onclick="logXp()">Log XP</button>` : ''}
    </div>
    ${w && C.proposal ? levelUpPanel() : ''}

    <h3>Notes</h3>
    ${w ? `<textarea id="stat-notes">${escHtml(c.notes || '')}</textarea>
           <p class="print-only small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>` : `<p class="small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`}
    ${w ? `<div class="rowline noprint"><button class="btn btn-primary" onclick="saveStats()">💾 Save stats &amp; notes</button><span id="msg"></span></div>` : ''}

    <h3>Skills</h3>
    <p class="small"><b>Class:</b> ${skillLine(byType('occ'))}</p>
    <p class="small"><b>Related:</b> ${skillLine(byType('related'))}</p>
    <p class="small"><b>Secondary:</b> ${skillLine(byType('secondary'))}</p>

  </div>

  <div class="panel">
    <h3 style="margin-top:0">Inventory</h3>
    <table><tr><th>Item</th><th>Qty</th><th>Equipped</th><th>Notes</th><th></th></tr>${invRows || '<tr><td class="muted" colspan="5">Empty.</td></tr>'}</table>
    ${w ? `<div class="noprint">
    <h3>Add item</h3>
    <div class="rowline">
      ${C.catalog.length ? `<select id="add-slug"><option value="">— catalog —</option>${catalogOpts}</select> <span class="muted small">or</span>` : ''}
      <input type="text" id="add-name" placeholder="Custom item name">
      <input type="number" id="add-qty" value="1" min="1">
      <input type="text" id="add-notes" placeholder="Notes (optional)" style="width:150px">
    </div>
    <div class="rowline">
      <label class="small"><input type="checkbox" id="add-log"> also log to journal</label>
      <button class="btn btn-sm" onclick="addItem()">Add to inventory</button>
    </div></div>` : ''}
  </div>

  <div class="panel">
    <h3 style="margin-top:0">Journal <span class="muted small">(newest first — campaign-level entries shown alongside this character's)</span></h3>
    ${w ? `<div class="noprint">
    <div class="rowline">
      <input type="text" id="j-title" placeholder="Title">
      <input type="text" id="j-date" placeholder="Session date (optional)" style="width:150px">
      ${C.isGm ? `<label class="small"><input type="checkbox" id="j-campaign"> campaign-level (GM)</label>` : ''}
    </div>
    <textarea id="j-body" placeholder="What happened this session…"></textarea>
    <div class="rowline"><button class="btn btn-sm" onclick="addJournal()">Add entry</button></div></div>` : ''}
    <div id="journal-list">${journalHtml}</div>
  </div>`;
}

function levelUpPanel() {
  const p = C.proposal;
  const poolRows = Object.entries(p.pools).map(([field, v]) =>
    `<tr><td>${POOL_LABELS[field]}</td><td>${v.from}</td>
     <td>→ <input type="number" id="lu-${field}" value="${v.to}"></td></tr>`).join('');
  const skillRows = p.skills.map((s, i) =>
    `<tr><td>${escHtml(s.name)} <span class="muted small">(${escHtml(s.type)})</span></td><td>${s.from}%</td>
     <td>→ <input type="number" id="lu-skill-${i}" value="${s.to}">%</td></tr>`).join('');
  const grants = p.grants.map((g) =>
    `<li class="small">Level ${g.level}: ${g.grants.map(escHtml).join('; ')}</li>`).join('');
  return `
  <div class="levelup noprint">
    <h3 style="margin-top:0">⬆ Level up! ${p.from_level} → ${p.to_level}
      <span class="muted small">— review, tweak if your GM says so, then confirm</span></h3>
    <table>${poolRows}${skillRows}</table>
    ${grants ? `<h3>New abilities</h3><ul style="margin-left:18px">${grants}</ul>` : ''}
    <div class="rowline" style="margin-top:10px">
      <button class="btn btn-primary" onclick="confirmLevelUp()">✅ Confirm level-up</button>
      <button class="btn btn-sm btn-ghost" onclick="C.proposal=null; render()">Not now</button>
      <span class="muted small">Nothing is applied until you confirm.</span>
    </div>
  </div>`;
}

async function logXp() {
  const delta = parseInt($('xp-delta').value, 10);
  if (!Number.isFinite(delta)) { alert('Enter an XP amount (0 re-checks for a pending level-up).'); return; }
  try {
    const res = await api(`characters/${id}/xp`, jsonReq('POST', { delta }));
    C.data.xp = res.xp;
    C.nextThreshold = res.next_threshold;
    C.proposal = res.proposal;
    render();
  } catch (err) { alert('XP update failed: ' + err.message); }
}

async function confirmLevelUp() {
  const p = C.proposal;
  const pools = {};
  for (const field of Object.keys(p.pools)) {
    const v = parseInt($('lu-' + field).value, 10);
    if (Number.isFinite(v)) pools[field] = v;
  }
  const skills = p.skills.map((s, i) => {
    const v = parseInt($('lu-skill-' + i).value, 10);
    return { name: s.name, pct: Number.isFinite(v) ? v : s.to };
  });
  try {
    await api(`characters/${id}/level-confirm`, jsonReq('POST', {
      to_level: p.to_level, pools, skills, grants: p.grants,
    }));
    C.proposal = null;
    await load();
  } catch (err) { alert('Level-up failed: ' + err.message); }
}

// Spend PPE/ISP on a power — client-side arithmetic + the existing PATCH
// endpoint (server still enforces owner/GM on the PATCH itself).
async function usePower(index) {
  const p = (C.data.powers || [])[index];
  if (!p || typeof p.cost !== 'number') return;
  const pool = p.type === 'spell' ? 'ppe' : 'isp';
  const cur = C.data[pool + '_current'];
  if (cur == null) return;
  if (cur < p.cost) { alert(`Not enough ${pool === 'ppe' ? 'P.P.E.' : 'I.S.P.'} (${cur} left, ${p.name} costs ${p.cost}).`); return; }
  try {
    await api('characters/' + id, jsonReq('PATCH', { [pool + '_current']: cur - p.cost }));
    await load();
  } catch (err) { alert('Failed: ' + err.message); }
}

async function saveStats() {
  const body = { notes: $('stat-notes').value };
  for (const [key] of POOLS) {
    const el = $('stat-' + key);
    if (el) body[key + '_current'] = el.value === '' ? null : +el.value;
  }
  try {
    await api('characters/' + id, jsonReq('PATCH', body));
    flash('Saved.');
    await load();
  } catch (err) { flash('Save failed: ' + err.message, true); }
}

async function patchItem(rowId, fields) {
  try { await api(`characters/${id}/items/${rowId}`, jsonReq('PATCH', fields)); await load(); }
  catch (err) { alert('Update failed: ' + err.message); }
}

async function removeItem(rowId) {
  if (!confirm('Remove this item from inventory? (History is kept.)')) return;
  try { await api(`characters/${id}/items/${rowId}`, { method: 'DELETE' }); await load(); }
  catch (err) { alert('Remove failed: ' + err.message); }
}

async function addItem() {
  const slug = $('add-slug')?.value || null;
  const name = $('add-name').value.trim();
  const qty = Math.max(1, +$('add-qty').value || 1);
  const notes = $('add-notes').value.trim() || null;
  if (!slug && !name) { alert('Pick a catalog item or enter a name.'); return; }
  try {
    let journalId = null;
    if ($('add-log').checked) {
      const label = slug ? C.catalog.find((i) => i.slug === slug)?.name : name;
      const entry = await api('journal', jsonReq('POST', {
        character_id: +id, title: 'Inventory: ' + label,
        body: `Acquired ${label}${qty > 1 ? ' ×' + qty : ''}${notes ? ' — ' + notes : ''}`,
      }));
      journalId = entry.entry.id;
    }
    await api(`characters/${id}/items`, jsonReq('POST', {
      slug, custom_name: slug ? null : name, qty, notes, journal_entry_id: journalId,
    }));
    await load();
  } catch (err) { alert('Add failed: ' + err.message); }
}

async function addJournal() {
  const body = $('j-body').value.trim();
  if (!body) { alert('Write something first.'); return; }
  const campaignLevel = $('j-campaign')?.checked;
  try {
    await api('journal', jsonReq('POST', {
      character_id: campaignLevel ? null : +id,
      campaign_id: C.data.campaign_id,
      title: $('j-title').value.trim() || null,
      session_date: $('j-date').value.trim() || null,
      body,
    }));
    await load();
  } catch (err) { alert('Journal failed: ' + err.message); }
}

if (!id) {
  $('app').innerHTML = '<div class="panel"><p class="err">No character id — open a sheet from the character list.</p></div>';
} else {
  load();
}
