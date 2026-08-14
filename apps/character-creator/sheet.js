// Character sheet — stats, skills, powers, inventory, journal, level-up.
// Owner/GM see edit controls; the server enforces the same rules regardless.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
const POOLS = [['hp', 'H.P.'], ['sdc', 'S.D.C.'], ['mdc', 'M.D.C.'], ['ppe', 'P.P.E.'], ['isp', 'I.S.P.']];
const POOL_LABELS = { hp_max: 'H.P. max', sdc_max: 'S.D.C. max', mdc_max: 'M.D.C. max', ppe_max: 'P.P.E. max', isp_max: 'I.S.P. max' };
const id = new URLSearchParams(location.search).get('id');

const C = { data: null, items: [], journal: [], catalog: [], cls: null, canWrite: false, isGm: false,
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
    const [journal, catalog, classes] = await Promise.all([
      api(`journal?campaign_id=${C.data.campaign_id}&character_id=${id}&include_campaign=1`),
      api('items?system=' + encodeURIComponent(C.data.campaign_system)),
      api('classes').catch(() => ({ classes: [] })),
    ]);
    C.journal = journal.entries; C.catalog = catalog.items;
    // The class supplies its display name plus the advisory text the sheet
    // shows (side_effects, restrictions) — none of which is stored per character.
    C.cls = (classes.classes || []).find((x) => x.id === C.data.class_id) || null;
    render();
  } catch (err) {
    $('app').innerHTML = `<div class="panel"><p class="err">Failed to load: ${escHtml(err.message)}</p></div>`;
  }
}

function flash(text, isError) {
  const el = $('msg');
  if (el) { el.textContent = text; el.className = isError ? 'err small' : 'muted small'; }
}

// ─── small builders for the sheet's boxed idiom ───
const box = (title, body, extra = '') =>
  `<div class="box"><div class="box-title"><span>${title}</span>${extra}</div><div class="box-body">${body}</div></div>`;

const field = (label, value, dim) =>
  `<div class="field"><span class="lbl">${label}</span><span class="dots"></span>` +
  `<span class="val${dim ? ' dim' : ''}">${value}</span></div>`;

// side_effects / restrictions come off the class as free text or a list.
const advisory = (label, value) => {
  if (!value || (Array.isArray(value) && !value.length)) return '';
  const text = Array.isArray(value) ? value.map((v) => `• ${v}`).join('\n') : String(value);
  return `<div class="advisory"><b>${label}:</b> ${escHtml(text)}</div>`;
};

function render() {
  const c = C.data, w = C.canWrite;
  const skills = Array.isArray(c.skills) ? c.skills : [];
  const powers = Array.isArray(c.powers) ? c.powers : [];
  const byType = (t) => skills.filter((s) => s.type === t);

  // Skills carry +%/Lvl and % columns, as on the printed sheet.
  const skillBox = (title, list) => box(title, list.length ? `
    <div class="skill-head"><span>Skill</span><span style="text-align:right">+%/Lvl</span><span style="text-align:right">%</span></div>
    ${list.map((s) => `<div class="skill-row">
      <span>${escHtml(s.name)}</span>
      <span class="num">${s.per_level ? '+' + s.per_level : '—'}</span>
      <span class="num pct">${s.pct ? s.pct + '%' : '—'}</span>
      ${s.note ? `<span class="note">↳ ${escHtml(s.note)}</span>` : ''}
    </div>`).join('')}` : '<p class="muted small">None.</p>');

  const vitals = POOLS.map(([key, label]) => {
    const max = c[key + '_max'], cur = c[key + '_current'];
    if (max == null && cur == null) return '';
    const curHtml = w
      ? `<input type="number" id="stat-${key}" value="${cur ?? ''}"><b class="print-only">${cur ?? '—'}</b>`
      : `<b>${cur ?? '—'}</b>`;
    return `<div class="vital"><div class="lbl">${label}</div>
      <div class="val">${curHtml} <span class="max">/ ${max ?? '—'}</span></div></div>`;
  }).join('');

  const powerRows = powers.map((p, i) => {
    const pool = p.type === 'spell' ? 'ppe' : 'isp';
    const cost = typeof p.cost === 'number' ? p.cost : null;
    const kind = p.type === 'spell'
      ? (p.level != null ? `spell · L${p.level}` : 'spell')
      : (p.category ? `psionic · ${p.category}` : 'psionic');
    const useBtn = w && cost != null && c[pool + '_current'] != null
      ? `<button class="btn btn-sm btn-ghost noprint" onclick="usePower(${i})">⚡ use</button>` : '';
    return `<div class="power-row">
      <span>${escHtml(p.name)} <span class="muted small">${escHtml(kind)}</span></span>
      <span class="cost">${cost != null ? cost + (pool === 'ppe' ? ' P.P.E.' : ' I.S.P.') : '—'}</span>
      ${useBtn}
    </div>`;
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

  const attrs = c.attributes || {};
  const cls = C.cls || {};

  $('app').innerHTML = `
  ${box(`${escHtml(c.name)}${w ? '' : ' <span class="tag ro">read-only</span>'}${C.isGm ? ' <span class="tag gm">GM</span>' : ''}`, `
    <div class="sheet-grid cols-2">
      <div>
        ${field('O.C.C.', escHtml(cls.name || c.class_id))}
        ${field('Level', c.level)}
        ${field('Experience', `${c.xp} XP`)}
      </div>
      <div>
        ${field('Campaign', escHtml(c.campaign_name), true)}
        ${field('System', escHtml(c.campaign_system), true)}
        ${field('Player', escHtml(c.player_email), true)}
      </div>
    </div>`)}

  <div class="sheet-grid rail" style="margin-top:12px">
    ${box('Attributes', `<div class="attr-stack">
      ${ATTRS.map((a) => field(a, attrs[a] ?? '—')).join('')}
    </div>`)}

    ${box('Vitals', `<div class="vitals">${vitals || '<span class="muted small">None recorded.</span>'}</div>
      ${w ? `<div class="rowline noprint" style="margin-top:8px">
        <button class="btn btn-sm btn-primary" onclick="saveStats()">Save</button><span id="msg"></span></div>` : ''}`,
      '<span class="muted" style="font-size:9px">CURRENT / MAX</span>')}

    ${box('Experience', `
      ${field('Level', c.level)}
      ${field('Points', c.xp)}
      ${C.nextThreshold != null ? field('Next level at', `${C.nextThreshold} XP`, true) : ''}
      ${w ? `<div class="rowline noprint" style="margin-top:6px">
        <input type="number" id="xp-delta" placeholder="+XP" style="width:78px">
        <button class="btn btn-sm" onclick="logXp()">Log XP</button></div>` : ''}`)}
  </div>

  ${w && C.proposal ? levelUpPanel() : ''}

  <div class="sheet-grid cols-3" style="margin-top:12px">
    ${skillBox('Class Skills', byType('occ'))}
    ${skillBox('Related Skills', byType('related'))}
    ${skillBox('Secondary Skills', byType('secondary'))}
  </div>

  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Psionics &amp; Magic', powers.length
      ? powerRows
      : '<p class="muted small">None.</p>')}

    ${box('Equipment', `
      <table><tr><th>Item</th><th>Qty</th><th>Eq</th><th>Notes</th><th></th></tr>
        ${invRows || '<tr><td class="muted" colspan="5">Empty.</td></tr>'}</table>
      ${w ? `<div class="noprint" style="margin-top:8px">
        <div class="rowline">
          ${C.catalog.length ? `<select id="add-slug"><option value="">— catalog —</option>${catalogOpts}</select>` : ''}
          <input type="text" id="add-name" placeholder="or custom item">
          <input type="number" id="add-qty" value="1" min="1">
        </div>
        <div class="rowline">
          <input type="text" id="add-notes" placeholder="Notes (optional)" style="width:150px">
          <label class="small"><input type="checkbox" id="add-log"> log it</label>
          <button class="btn btn-sm" onclick="addItem()">Add</button>
        </div></div>` : ''}`)}
  </div>

  <div class="sheet-grid cols-2" style="margin-top:12px">
    ${box('Notes', `
      ${w ? `<textarea id="stat-notes" class="noprint">${escHtml(c.notes || '')}</textarea>
             <p class="print-only small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`
          : `<p class="small" style="white-space:pre-wrap">${escHtml(c.notes || '—')}</p>`}
      ${advisory('Side effects', cls.side_effects)}
      ${advisory('Restrictions', cls.restrictions)}`)}

    ${box('Journal', `
      ${w ? `<div class="noprint">
        <div class="rowline">
          <input type="text" id="j-title" placeholder="Title">
          <input type="text" id="j-date" placeholder="Session date" style="width:120px">
          ${C.isGm ? `<label class="small"><input type="checkbox" id="j-campaign"> campaign</label>` : ''}
        </div>
        <textarea id="j-body" placeholder="What happened this session…"></textarea>
        <div class="rowline"><button class="btn btn-sm" onclick="addJournal()">Add entry</button></div>
      </div>` : ''}
      <div id="journal-list">${journalHtml}</div>`,
      '<span class="muted" style="font-size:9px">NEWEST FIRST</span>')}
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
