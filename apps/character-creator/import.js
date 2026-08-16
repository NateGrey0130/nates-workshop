// OCC/RCC class import — admin only. Upload a focused PDF page range, extract
// via Claude, review/edit the whole markdown file, confirm to create item stubs
// and get catalog snippets. Nothing touches git; the markdown is copied out.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const I = { isAdmin: false, email: null, extracting: false, result: null, confirmed: null, stored: [],
            mode: 'class', skills: null, skillsDone: null, retiredView: false, retiredCount: 0,
            // Spell and psionic imports run over several sittings, so the work
            // lives in a session on the server rather than in this tab.
            sessions: [], session: null, staged: [], sessionMsg: null };
const $ = (id) => document.getElementById(id);

// Catalogs whose imports are session-based. The session UI itself is generic;
// these supply the labels and the one extra field each flow wants.
const SESSION_CATALOGS = {
  spells: {
    label: 'Spells', noun: 'spell', sub: 'A whole chapter, over several sittings',
    extra: { key: 'level', id: 'sess-level', placeholder: 'Level', type: 'number', width: '90px' },
    summary: (r) => `L${r.level ?? 0} · ${r.ppe ?? 0} P.P.E.`,
  },
  psionics: {
    label: 'Psionics', noun: 'psionic power', sub: 'A whole chapter, over several sittings',
    extra: { key: 'category', id: 'sess-category', placeholder: 'Category', type: 'text', width: '150px' },
    summary: (r) => `${escHtml(r.category || 'no category')} · ${r.isp ?? 0} I.S.P.`
      + (r.min_tier ? ` · ${escHtml(r.min_tier)}` : ''),
  },
  gear: {
    label: 'Gear', noun: 'equipment', sub: 'Weapons, armour and kit',
    extra: { key: 'category', id: 'sess-category', placeholder: 'weapon / armor / …', type: 'text', width: '150px' },
    // The slug is worth showing: it is what an existing stub is matched on, and
    // what equipment_starting[].item_id in class markdown points at.
    summary: (r) => `<span class="slug">${escHtml(r.slug || '—')}</span>`
      + ` ${escHtml(r.category || 'uncategorised')}`
      + (r.damage ? ` · ${escHtml(r.damage)}${r.is_mega_damage ? ' (M.D.)' : ''}` : '')
      + (r.ar ? ` · A.R. ${r.ar}` : '') + (r.mdc ? ` · ${r.mdc} M.D.C.` : ''),
  },
};

async function api(path, opts) {
  const res = await fetch('/api/character-creator/' + path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || ('API ' + res.status));
  return data;
}
const jsonReq = (body) => ({ method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

// The PDF goes to the API as base64 and on to Claude as a document attachment.
function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const fr = new FileReader();
    fr.onload = () => resolve(String(fr.result).split(',')[1]);
    fr.onerror = () => reject(new Error('Could not read the file'));
    fr.readAsDataURL(file);
  });
}

async function boot() {
  try {
    const me = await api('me');
    I.isAdmin = !!me.is_admin;
    I.email = me.email;
    if (I.isAdmin) await loadStored();
  } catch { /* falls through to the denied view */ }
  render();
}

async function loadStored() {
  try {
    const res = await api('import/stored' + (I.retiredView ? '?retired=1' : ''));
    I.stored = res.stored || [];
    I.retiredCount = res.retired_count || 0;
  } catch { I.stored = []; I.retiredCount = 0; }
}

function render() {
  if (!I.isAdmin) {
    $('app').innerHTML = `<div class="panel">
      <h2>Admin only</h2>
      <p class="muted">This tool edits the global class catalog, so it's limited to the site admin${I.email ? ` — you're signed in as ${escHtml(I.email)}` : ''}.</p>
    </div>`;
    return;
  }
  if (I.mode === 'skills') {
    if (I.skillsDone) return renderSkillsDone();
    if (I.skills) return renderSkillsReview();
    return renderSkillsUpload();
  }
  if (SESSION_CATALOGS[I.mode]) {
    return I.session ? renderSession() : renderSessions();
  }
  if (I.confirmed) return renderConfirmed();
  if (I.result) return renderReview();
  renderUpload();
}

// Full-width tabs rather than a muted pill toggle — the page does two distinct
// jobs and the second one was easy to miss entirely.
function modeTabs() {
  const tab = (mode, label, sub) => `
    <button class="imp-tab ${I.mode === mode ? 'on' : ''}" onclick="setMode('${mode}')">
      <span class="imp-tab-label">${label}</span>
      <span class="imp-tab-sub">${sub}</span>
    </button>`;
  const count = 2 + Object.keys(SESSION_CATALOGS).length;
  return `<div class="imp-tabs cols-${count} noprint">
    ${tab('class', 'Classes', 'One O.C.C./R.C.C. per upload')}
    ${tab('skills', 'Skills', 'A skill chapter — many at once')}
    ${Object.entries(SESSION_CATALOGS).map(([k, c]) => tab(k, c.label, c.sub)).join('')}
  </div>`;
}
function setMode(m) {
  I.mode = m;
  if (SESSION_CATALOGS[m]) { loadSessions(); return; }
  render();
}

// ─── Skills: upload ───
function renderSkillsUpload() {
  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <h2>Import skills from a book</h2>
    <p class="muted">Upload the page range covering a skill chapter or category. Many skills come back at
      once; anything already in the catalog is flagged so you can decide per skill.</p>
    <div class="rowline" style="margin-top:14px"><input type="file" id="pdf" accept="application/pdf"></div>
    <div class="rowline">
      <input type="text" id="source-book" placeholder="Source book (e.g. rifts-core)" style="width:210px">
      <input type="text" id="category" placeholder="Category, if the pages are all one (e.g. Physical)" style="width:290px">
    </div>
    <h3>Hints <span class="muted small">(optional)</span></h3>
    <textarea id="hints" placeholder="e.g. &quot;ignore the sidebar on page 2&quot;"></textarea>
    <div class="rowline" style="margin-top:10px">
      <label class="small">Model:</label>
      <select id="model">
        <option value="claude-sonnet-5">claude-sonnet-5 (default)</option>
        <option value="claude-opus-5">claude-opus-5 (slower, pricier)</option>
      </select>
      <button class="btn btn-primary" id="go" onclick="runSkillExtract()">Extract skills</button>
      <span id="msg" class="muted small"></span>
    </div>
  </div>`;
}

async function runSkillExtract() {
  const file = $('pdf').files[0];
  if (!file) { $('msg').textContent = 'Pick a PDF first.'; return; }
  if (I.extracting) return;
  I.extracting = true; $('go').disabled = true;
  $('msg').textContent = `Reading ${file.name}…`;
  try {
    const b64 = await fileToBase64(file);
    $('msg').textContent = 'Extracting — a dense skill chapter takes a while…';
    const res = await api('import/skills/extract', jsonReq({
      pdf_base64: b64,
      source_book: $('source-book').value.trim() || undefined,
      category: $('category').value.trim() || undefined,
      hints: $('hints').value.trim() || undefined,
      model: $('model').value,
    }));
    // Each row starts on its suggested action; stubs default to update.
    res.rows.forEach((r) => {
      r.action = r.status === 'new' ? 'insert' : (r.suggested || 'ignore');
      r.as_name = `${r.name} (${res.source_book || 'imported'})`;
    });
    I.skills = res;
    render();
  } catch (err) {
    $('msg').innerHTML = `<span class="err">${escHtml(err.message)}</span>`;
  } finally {
    I.extracting = false;
    if ($('go')) $('go').disabled = false;
  }
}

// ─── Skills: review, with the three-way duplicate decision ───
function renderSkillsReview() {
  const s = I.skills;
  const rowHtml = (r, i) => {
    const ex = r.existing;
    const pct = (b, p) => `${b || 0}%${p ? ` +${p}/lvl` : ''}`;
    const choice = (val, label, title) => `<label class="small" title="${title}">
      <input type="radio" name="act-${i}" value="${val}" ${r.action === val ? 'checked' : ''}
        onchange="setSkillAction(${i}, '${val}')"> ${label}</label>`;
    return `<div class="imp-row ${r.status}">
      <div class="imp-main">
        <span class="imp-name">${escHtml(r.name)}</span>
        <span class="muted small">${escHtml(r.category || 'no category')} · ${pct(r.base, r.per_level)}</span>
        ${r.note ? `<span class="muted small">↳ ${escHtml(r.note)}</span>` : ''}
      </div>
      <div class="imp-status">
        ${r.status === 'new'
          ? '<span class="badge-live">new</span>'
          : `<span class="${r.is_stub ? 'badge-file' : 'err'}">${r.is_stub ? 'fills a stub' : 'already exists'}</span>
             <span class="muted small">catalog: ${pct(ex.base, ex.per_level)}${ex.source_book ? ' · ' + escHtml(ex.source_book) : ''}</span>`}
      </div>
      <div class="imp-actions">
        ${r.status === 'new'
          ? choice('insert', 'Add', 'Add this skill to the catalog') + choice('ignore', 'Skip', 'Do not import')
          : choice('update', 'Update', 'Overwrite the existing percentages') +
            choice('insert', 'Keep both', 'Add as a separate entry under a distinguished name') +
            choice('ignore', 'Ignore', 'Leave the catalog untouched')}
        ${r.status === 'duplicate' && r.action === 'insert'
          ? `<input type="text" class="mini-in wide" value="${escHtml(r.as_name)}"
               onchange="setSkillName(${i}, this.value)" title="Name for the new entry — must be unique">` : ''}
      </div>
    </div>`;
  };

  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <h2>Review — ${s.counts.total} skill${s.counts.total === 1 ? '' : 's'}</h2>
    <p class="muted">${s.counts.new} new · ${s.counts.duplicates} already in the catalog${s.counts.stubs ? ` · ${s.counts.stubs} of those are empty stubs, defaulted to update` : ''}
      ${s.usage ? ` · ${s.usage.input_tokens} in / ${s.usage.output_tokens} out` : ''}</p>
    <div class="rowline noprint">
      <button class="btn btn-sm btn-ghost" onclick="setAllSkills('insert')">All: add/keep both</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllSkills('update')">All duplicates: update</button>
      <button class="btn btn-sm btn-ghost" onclick="setAllSkills('ignore')">All duplicates: ignore</button>
    </div>
    <div style="margin-top:10px">${s.rows.map(rowHtml).join('')}</div>
  </div>
  <div class="nav">
    <button class="btn btn-ghost" onclick="I.skills=null; render()">← Start over</button>
    <button class="btn btn-primary" onclick="confirmSkills()">Apply to catalog</button>
  </div>`;
}

function setSkillAction(i, action) { I.skills.rows[i].action = action; render(); }
function setSkillName(i, name) { I.skills.rows[i].as_name = name; }
function setAllSkills(action) {
  for (const r of I.skills.rows) {
    if (action === 'insert') r.action = 'insert';
    else if (r.status === 'duplicate') r.action = action;
  }
  render();
}

async function confirmSkills() {
  try {
    const res = await api('import/skills/confirm', jsonReq({
      source_book: I.skills.source_book,
      decisions: I.skills.rows.map((r) => ({
        action: r.action, name: r.name, category: r.category,
        base: r.base, per_level: r.per_level, note: r.note,
        as_name: r.status === 'duplicate' && r.action === 'insert' ? r.as_name : undefined,
      })),
    }));
    I.skillsDone = res;
    render();
  } catch (err) { alert('Import failed: ' + err.message); }
}

function renderSkillsDone() {
  const d = I.skillsDone;
  const list = (label, names, cls) => names.length
    ? `<h3>${label} — ${names.length}</h3><p class="small ${cls}">${names.map(escHtml).join(' · ')}</p>` : '';
  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <h2>✅ Catalog updated</h2>
    <p class="muted">${d.counts.inserted} added · ${d.counts.updated} updated · ${d.counts.ignored} ignored.
      Changes are live — no redeploy needed.</p>
    ${list('Added', d.applied.inserted, '')}
    ${list('Updated', d.applied.updated, '')}
    ${d.conflicts.length ? `<h3 class="err">Skipped — name already taken</h3>
      <p class="small err">${d.conflicts.map((c) => escHtml(c.name)).join(' · ')}</p>
      <p class="muted small">Re-run those with a different "keep both" name.</p>` : ''}
  </div>
  <div class="nav"><button class="btn btn-ghost" onclick="I.skills=null; I.skillsDone=null; render()">← Import more</button><span></span></div>`;
}

// ─── Step 1: upload ───
function renderUpload() {
  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <h2>Import a class from a PDF</h2>
    <p class="muted">Upload a focused page range covering exactly one O.C.C./R.C.C. The PDF is sent
      to Claude as a document so it reads the two-column layout directly — don't pre-extract text.</p>
    <div class="rowline" style="margin-top:14px">
      <input type="file" id="pdf" accept="application/pdf">
    </div>
    <h3>Hints <span class="muted small">(optional — e.g. "the class starts mid-page 2, ignore the sidebar")</span></h3>
    <textarea id="hints" placeholder="Anything that would help the extraction…"></textarea>
    <div class="rowline" style="margin-top:10px">
      <label class="small">Model:</label>
      <select id="model">
        <option value="claude-sonnet-5">claude-sonnet-5 (default)</option>
        <option value="claude-opus-5">claude-opus-5 (slower, pricier)</option>
      </select>
      <button class="btn btn-primary" id="go" onclick="runExtract()">Extract class</button>
      <span id="msg" class="muted small"></span>
    </div>
  </div>
  ${storedPanel()}`;
}

// Saved imports. Drafts are autosaved the moment an extraction succeeds, so a
// closed tab never loses one; published rows are live classes in the app.
//
// Retiring a published class hides it from the app without destroying it. The
// retired list is behind a toggle here rather than on its own page, so the
// undo sits next to the action that needs undoing.
function storedPanel() {
  const viewingRetired = I.retiredView;
  // Still render while viewing the retired list even when it is empty —
  // restoring the last retired class would otherwise remove the panel, and the
  // way back out with it.
  if (!I.stored.length && !I.retiredCount && !viewingRetired) return '';

  const rows = I.stored.map((s) => `
    <div class="miss-row">
      <span class="slug">${escHtml(s.class_id)}</span>
      <span>${escHtml(s.name || '')}</span>
      <span class="tag ${s.status === 'published' ? 'gm' : ''}">${escHtml(s.status)}</span>
      <span class="muted small">${escHtml(s.system || '')} · ${escHtml(s.updated_at)}</span>
      <span style="margin-left:auto; display:flex; gap:6px">
        ${viewingRetired
          ? `<button class="btn btn-sm" onclick="restoreStored('${escHtml(s.class_id)}')">Restore</button>`
          : `<button class="btn btn-sm" onclick="reopenStored('${escHtml(s.class_id)}')">Open</button>
             <button class="btn btn-sm btn-ghost" onclick="removeStored('${escHtml(s.class_id)}')">${s.status === 'published' ? 'Retire' : 'Delete'}</button>`}
      </span>
    </div>`).join('');

  const empty = viewingRetired
    ? '<p class="muted small">Nothing retired.</p>'
    : '<p class="muted small">No saved imports.</p>';

  const toggle = I.retiredCount || viewingRetired
    ? `<button class="btn btn-sm btn-ghost" onclick="toggleRetiredView()">
         ${viewingRetired ? '← Back to saved imports' : `Retired (${I.retiredCount})`}
       </button>`
    : '';

  return `
  <div class="panel">
    <div style="display:flex; align-items:center; gap:12px; margin-bottom:8px">
      <h3 style="margin:0">${viewingRetired ? 'Retired classes' : 'Saved imports'}
        <span class="muted small">${viewingRetired
          ? '(hidden from the app; characters built on them still work)'
          : '(drafts autosave on extraction; published classes are live in the app)'}</span></h3>
      <span style="margin-left:auto; display:flex; gap:6px">
        ${viewingRetired ? '' : '<button class="btn btn-sm" onclick="newClass()">+ Write one by hand</button>'}
        ${toggle}
      </span>
    </div>
    ${rows || empty}
  </div>`;
}

// Start a class from a template instead of a PDF.
//
// Not every class comes out of a book cleanly — an RCC with several age stages
// is quicker to write than to extract — and there was no way in without an
// extraction to edit. Everything the parser requires is asked for up front so
// the draft validates the moment it exists; the rest is commented in the
// template.
async function newClass() {
  const name = prompt('Class name (e.g. "Dragon (Great Horned)")');
  if (!name) return;

  const kindRaw = (prompt([
    'Is this a character class or a race?',
    '',
    '  o — O.C.C., a character class',
    '  r — R.C.C., a racial class',
  ].join('\n')) || '').trim().toLowerCase();
  if (!kindRaw) return;
  const kind = kindRaw.startsWith('r') ? 'rcc' : 'occ';

  const sysRaw = (prompt([
    'Which system?',
    '',
    '  r — Rifts',
    '  p — Palladium Fantasy',
  ].join('\n')) || '').trim().toLowerCase();
  if (!sysRaw) return;
  const system = sysRaw.startsWith('p') ? 'palladium-fantasy' : 'rifts';

  const sourceBook = prompt('Source book (required)') || '';
  if (!sourceBook.trim()) return;

  // The same slug rule the gear importer uses, so a hand-written id looks like
  // an extracted one.
  const id = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
  if (I.stored.some((x) => x.class_id === id)) {
    alert(`A class with the id "${id}" already exists. Open it instead, or choose a different name.`);
    return;
  }

  const markdown = classTemplate(kind, { id, name, system, sourceBook: sourceBook.trim() });
  try {
    // Saved as a draft straight away, so a closed tab cannot lose it.
    await api('import/stored', { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ markdown }) });
    await loadStored();
    const check = await api('import/recheck', jsonReq({ markdown }));
    I.result = { ...check, markdown, model: 'new from template', usage: null };
    render();
  } catch (err) { alert('Could not create: ' + err.message); }
}

async function toggleRetiredView() {
  I.retiredView = !I.retiredView;
  await loadStored();
  render();
}

async function restoreStored(classId) {
  try {
    await api('import/stored?class_id=' + encodeURIComponent(classId), { method: 'POST' });
    await loadStored();
    render();
  } catch (err) { alert('Restore failed: ' + err.message); }
}

async function reopenStored(classId) {
  try {
    const { stored } = await api('import/stored?class_id=' + encodeURIComponent(classId));
    const check = await api('import/recheck', jsonReq({ markdown: stored.markdown }));
    I.result = { ...check, markdown: stored.markdown, model: 'saved draft', usage: null };
    render();
  } catch (err) { alert('Could not open: ' + err.message); }
}

// The wording differs by status because the consequences genuinely differ:
// retiring a published class is undoable, deleting a draft is not.
async function removeStored(classId) {
  const row = I.stored.find((s) => s.class_id === classId);
  const published = row?.status === 'published';
  const prompt = published
    ? `Retire "${classId}"? It stops appearing in the app and can't be chosen for new characters. Existing characters keep working, and you can restore it from the retired list.`
    : `Delete the draft "${classId}"? Drafts are not recoverable.`;
  if (!confirm(prompt)) return;
  try {
    await api('import/stored?class_id=' + encodeURIComponent(classId), { method: 'DELETE' });
    await loadStored();
    render();
  } catch (err) { alert((published ? 'Retire' : 'Delete') + ' failed: ' + err.message); }
}

async function runExtract() {
  const file = $('pdf').files[0];
  if (!file) { $('msg').textContent = 'Pick a PDF first.'; return; }
  if (I.extracting) return;
  I.extracting = true;
  $('go').disabled = true;
  $('msg').textContent = `Reading ${file.name}…`;
  try {
    const b64 = await fileToBase64(file);
    $('msg').textContent = 'Extracting — this takes a while for a dense page…';
    I.result = await api('import/extract', jsonReq({
      pdf_base64: b64,
      filename: file.name,
      model: $('model').value,
      hints: $('hints').value.trim() || undefined,
    }));
    render();
  } catch (err) {
    $('msg').innerHTML = `<span class="err">${escHtml(err.message)}</span>`;
  } finally {
    I.extracting = false;
    if ($('go')) $('go').disabled = false;
  }
}

// ─── Step 2: review ───
function missingBlock() {
  const m = I.result.missing;
  const total = m.items.length + m.skills.length + m.spells.length + m.psionics.length;
  if (!total) return '<p class="muted small">Everything this class references already exists in the catalogs.</p>';

  const group = (label, list, live) => list.length ? `
    <h3>${label} — ${list.length} missing
      <span class="${live ? 'badge-live' : 'badge-file'}">${live ? 'stub row inserted into D1 on confirm' : 'JSON snippet to merge by hand'}</span></h3>
    ${list.map((n) => `<div class="miss-row"><span class="slug">${escHtml(n)}</span></div>`).join('')}` : '';

  return group('Items', m.items, true) + group('Skills', m.skills, false) +
         group('Spells', m.spells, false) + group('Psionic powers', m.psionics, false);
}

function renderReview() {
  const r = I.result;
  const notes = r.extraction_notes;
  $('app').innerHTML = `
  ${notes ? `<div class="notes-banner">
    <h3>⚠ Extraction notes — read these</h3>
    <div class="body">${escHtml(notes)}</div>
  </div>` : ''}

  <div class="panel">
    <h2>Review${r.class_id ? ` — <span class="mono">${escHtml(r.class_id)}.md</span>` : ''}</h2>
    <p class="muted">Extracted with ${escHtml(r.model)}${r.usage ? ` · ${r.usage.input_tokens} in / ${r.usage.output_tokens} out` : ''}.
      Edit anything below — it's the actual file.
      ${r.autosaved ? '<span class="badge-live">Saved as a draft, so closing this tab won\'t lose it.</span>' : ''}
      Confirming publishes it and creates any missing item stubs.</p>
    ${r.errors?.length ? `<p class="warn err">Parse errors: ${escHtml(r.errors.join('; '))}</p>` : ''}
    ${r.warnings?.length ? `<p class="warn">${escHtml(r.warnings.join('; '))}</p>` : ''}
    ${blockEditors()}
    <textarea id="md" class="mono" spellcheck="false">${escHtml(r.markdown)}</textarea>
    <div class="rowline">
      <button class="btn btn-sm" onclick="reparse()">↻ Re-check</button>
      <span id="msg" class="muted small"></span>
    </div>
  </div>

  <div class="panel">
    <h3 style="margin-top:0">Catalog references</h3>
    ${missingBlock()}
  </div>

  <div class="nav">
    <button class="btn btn-ghost" onclick="startOver()">← Start over</button>
    <button class="btn btn-primary" onclick="confirmImport()">Confirm — create item stubs &amp; get output</button>
  </div>`;
}

// Re-runs parse + cross-reference on the edited text without another API call.
async function reparse() {
  try {
    $('msg').textContent = 'Checking…';
    const res = await api('import/recheck', jsonReq({ markdown: $('md').value }));
    I.result = { ...I.result, ...res, markdown: $('md').value };
    render();
  } catch (err) { $('msg').innerHTML = `<span class="err">${escHtml(err.message)}</span>`; }
}

async function confirmImport() {
  const markdown = $('md').value;
  try {
    $('msg').textContent = 'Confirming…';
    const res = await api('import/confirm', jsonReq({ markdown }));
    I.confirmed = { ...res, markdown };
    await loadStored();
    render();
  } catch (err) { $('msg').innerHTML = `<span class="err">${escHtml(err.message)}</span>`; }
}

// ─── Step 3: output ───
function renderConfirmed() {
  const c = I.confirmed;
  const cr = c.created || {};
  const group = (label, rows, fmt) => rows?.length ? `
    <h3>${label} <span class="badge-live">created — live now</span></h3>
    ${rows.map((r) => `<div class="miss-row">${fmt(r)}</div>`).join('')}` : '';
  const createdBlocks =
    group('Items', cr.items, (r) => `<span class="slug">${escHtml(r.slug)}</span><span>${escHtml(r.name)}</span>`) +
    group('Skills', cr.skills, (r) => `<span class="slug">${escHtml(r.name)}</span><span class="muted small">${escHtml(r.category || 'category not inferred')}</span>`) +
    group('Spells', cr.spells, (r) => `<span class="slug">${escHtml(r.name)}</span>`) +
    group('Psionic powers', cr.psionics, (r) => `<span class="slug">${escHtml(r.name)}</span><span class="muted small">${escHtml(r.category || 'category not inferred')}</span>`);

  $('app').innerHTML = `
  <div class="panel">
    <h2>✅ ${escHtml(c.class_id)} is live</h2>
    <p class="muted">Published — it already appears in the character creator, no commit and no redeploy.
      A copy of the file is below if you want one for your own records.</p>
    <div class="rowline">
      <button class="btn btn-primary" onclick="downloadMd()">⬇ Download ${escHtml(c.class_id)}.md</button>
      <button class="btn btn-sm" onclick="copyMd()">Copy markdown</button>
      <span id="msg" class="muted small"></span>
    </div>
    <pre class="snippet" id="final-md">${escHtml(c.markdown)}</pre>
  </div>

  ${createdBlocks ? `<div class="panel">
    ${createdBlocks}
    <p class="muted small" style="margin-top:8px">Stubs carry a name and an inferred category only — fill in
      percentages, costs, and stats when you get to them. Nothing here needs a redeploy.</p>
  </div>` : '<div class="panel"><p class="muted small">Everything this class references already existed — no stubs needed.</p></div>'}

  <div class="nav"><button class="btn btn-ghost" onclick="startOver()">← Import another</button><span></span></div>`;
}
function copyMd() { copyWithFeedback(I.confirmed.markdown, event.target); }
function downloadMd() {
  const blob = new Blob([I.confirmed.markdown], { type: 'text/markdown' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `${I.confirmed.class_id}.md`;
  a.click();
  URL.revokeObjectURL(a.href);
}
async function startOver() { I.result = null; I.confirmed = null; await loadStored(); render(); }

// ─── Spell import sessions ──────────────────────────────────────────────
// A spell chapter is hundreds of entries over many pages, so it does not fit
// one sitting. Extractions are staged server-side the moment they parse; this
// tab is just a window onto that.

async function loadSessions() {
  try {
    I.sessions = (await api('import/sessions?catalog=' + I.mode)).sessions || [];
  } catch (err) { I.sessions = []; I.sessionMsg = { text: err.message, error: true }; }
  I.session = null; I.staged = [];
  render();
}

async function openSession(id) {
  try {
    const res = await api('import/sessions?id=' + encodeURIComponent(id));
    I.session = res.session;
    I.staged = res.staged || [];
    I.sessionMsg = null;
  } catch (err) { I.sessionMsg = { text: err.message, error: true }; }
  render();
}

// Which system the book is for, asked once per import rather than per page.
// Anything unrecognised — including an empty answer — means unrestricted, which
// is the honest result when the operator does not know or the book covers both.
// Kept to prompts to match the rest of this flow; the answer matters far more
// than the widget.
function askSystem() {
  const raw = (prompt([
    'Which game system is this book for?',
    '',
    '  r  — Rifts',
    '  p  — Palladium Fantasy',
    '  (blank) — both / unsure, imports unrestricted',
  ].join('\n')
  ) || '').trim().toLowerCase();
  if (raw.startsWith('r')) return 'rifts';
  if (raw.startsWith('p')) return 'palladium-fantasy';
  return null;
}

async function newSession() {
  const name = prompt('Name this import (e.g. "Rifts Core — spell chapter")');
  if (!name) return;
  const book = prompt('Source book label (optional)') || null;
  const system = askSystem();
  try {
    const res = await api('import/sessions', jsonReq({ catalog: I.mode, name, source_book: book, system }));
    await openSession(res.id);
  } catch (err) { I.sessionMsg = { text: err.message, error: true }; render(); }
}

async function closeSession(id) {
  if (!confirm('Close this import? Anything still pending stays unimported.')) return;
  try {
    await api(`import/sessions?id=${encodeURIComponent(id)}&close=1`, { method: 'POST' });
    await loadSessions();
  } catch (err) { I.sessionMsg = { text: err.message, error: true }; render(); }
}

function renderSessions() {
  const rows = I.sessions.map((s) => `
    <div class="miss-row">
      <span class="slug">#${s.id}</span>
      <span><b>${escHtml(s.name)}</b></span>
      <span class="muted small">${escHtml(s.source_book || 'no book label')}</span>
      <span class="tag">${escHtml(s.system || 'both systems')}</span>
      <span class="muted small">${s.confirmed_count}/${s.staged_count} imported</span>
      <span style="margin-left:auto; display:flex; gap:6px">
        <button class="btn btn-sm" onclick="openSession(${s.id})">Open</button>
        <button class="btn btn-sm btn-ghost" onclick="closeSession(${s.id})">Close</button>
      </span>
    </div>`).join('');

  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <h2 style="margin-top:0">${escHtml(SESSION_CATALOGS[I.mode].label)} imports</h2>
    <p class="muted small">A ${escHtml(SESSION_CATALOGS[I.mode].noun)} chapter is far more than one
      upload's worth. Start an import, feed it a page range at a time, and confirm in batches —
      it keeps its place between visits.</p>
    ${I.sessionMsg ? `<p class="${I.sessionMsg.error ? 'err' : 'muted'} small">${escHtml(I.sessionMsg.text)}</p>` : ''}
    ${rows || '<p class="muted small">No imports open.</p>'}
    <div class="imp-actions" style="margin-top:12px">
      <button class="btn" onclick="newSession()">+ Start an import</button>
    </div>
  </div>`;
}

function renderSession() {
  const s = I.session;
  const pending = I.staged.filter((r) => !r.confirmed_at);
  const done = I.staged.length - pending.length;

  const row = (r) => {
    const opts = ['insert', 'update', 'ignore']
      .filter((a) => a !== 'update' || r.status === 'duplicate')
      .map((a) => `<option value="${a}"${r.action === a ? ' selected' : ''}>${a}</option>`).join('');
    return `
    <div class="miss-row">
      <span><b>${escHtml(r.name || '(unnamed)')}</b></span>
      <span class="muted small">${SESSION_CATALOGS[I.mode].summary(r)}</span>
      ${r.status === 'duplicate'
        ? `<span class="tag">${r.is_stub ? 'stub' : 'in catalog'}${r.differs ? ' · differs' : ''}</span>`
        : '<span class="badge-live">new</span>'}
      ${(r.flags || []).length
        ? `<span class="badge-file" title="${escHtml(r.flags.join('; '))}">⚠ ${escHtml(r.flags.join('; '))}</span>`
        : ''}
      <span class="muted small">${escHtml(r.page_range || '')}</span>
      <span style="margin-left:auto; display:flex; gap:6px; align-items:center">
        <select data-staged="${r.id}" onchange="setStagedAction(${r.id}, this.value)">${opts}</select>
        <input type="text" placeholder="keep both as…" value="${escHtml(r.resolved_name || '')}"
               style="width:180px" oninput="setStagedName(${r.id}, this.value)">
      </span>
    </div>`;
  };

  $('app').innerHTML = `
  ${modeTabs()}
  <div class="panel">
    <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap">
      <h2 style="margin:0">${escHtml(s.name)}</h2>
      <span class="muted small">${escHtml(s.source_book || 'no book label')} · ${escHtml(s.system || 'both systems')} · ${done} imported, ${pending.length} pending</span>
      <span style="margin-left:auto"><button class="btn btn-sm btn-ghost" onclick="loadSessions()">← all imports</button></span>
    </div>
  </div>

  <div class="panel">
    <h3 style="margin-top:0">Add a page range</h3>
    <p class="muted small">Keep it small — ${escHtml(SESSION_CATALOGS[I.mode].noun)} entries are long,
      and a reply that overruns the output limit is rejected rather than half-saved.</p>
    <input type="file" id="sess-pdf" accept="application/pdf">
    <div class="rowline" style="margin-top:8px">
      <input type="text" id="sess-pages" placeholder="Page range label, e.g. pp. 180-181" style="flex:1">
      ${(() => { const e = SESSION_CATALOGS[I.mode].extra; return `<input type="${e.type}" id="${e.id}"
        placeholder="${escHtml(e.placeholder)}" style="width:${e.width}">`; })()}
    </div>
    <textarea id="sess-hints" rows="2" placeholder="Anything that would help the extraction…"></textarea>
    <div class="imp-actions" style="margin-top:8px">
      <button class="btn" id="sess-go" onclick="runSessionExtract()"${I.extracting ? ' disabled' : ''}>
        ${I.extracting ? 'Extracting…' : 'Extract this range'}</button>
      <span id="sess-msg" class="${I.sessionMsg?.error ? 'err' : 'muted'} small">${escHtml(I.sessionMsg?.text || '')}</span>
    </div>
  </div>

  ${pending.length ? `<div class="panel">
    <div style="display:flex; align-items:center; gap:12px; flex-wrap:wrap; margin-bottom:8px">
      <h3 style="margin:0">Pending — ${pending.length}</h3>
      <span style="margin-left:auto; display:flex; gap:6px">
        <button class="btn btn-sm btn-ghost" onclick="setAllStaged('ignore')">All ignore</button>
        <button class="btn btn-sm btn-ghost" onclick="setAllStaged('insert')">All insert</button>
        <button class="btn" onclick="confirmSession()">Import these</button>
      </span>
    </div>
    ${pending.map(row).join('')}
  </div>` : '<div class="panel"><p class="muted small">Nothing pending. Add a page range above.</p></div>'}`;
}

function setStagedAction(id, action) {
  const r = I.staged.find((x) => x.id === id);
  if (r) r.action = action;
}
function setStagedName(id, name) {
  const r = I.staged.find((x) => x.id === id);
  if (r) r.resolved_name = name.trim() || null;
}
function setAllStaged(action) {
  for (const r of I.staged) if (!r.confirmed_at) r.action = action;
  render();
}

async function runSessionExtract() {
  const file = $('sess-pdf')?.files?.[0];
  if (!file) { I.sessionMsg = { text: 'Choose a PDF first.', error: true }; render(); return; }
  I.extracting = true; I.sessionMsg = { text: 'Reading those pages…' }; render();
  try {
    const pdf = await fileToBase64(file);
    const extra = SESSION_CATALOGS[I.mode].extra;
    const res = await api(`import/${I.mode}/extract`, jsonReq({
      session_id: I.session.id,
      pdf_base64: pdf,
      page_range: $('sess-pages')?.value || null,
      [extra.key]: $(extra.id)?.value || null,
      hints: $('sess-hints')?.value || null,
    }));
    I.extracting = false;
    I.sessionMsg = { text: `Staged ${res.staged}`
      + (res.skipped ? `, skipped ${res.skipped} already in this import` : '')
      + (res.flagged ? `. ${res.flagged} need a look — see the ⚠ rows.` : '.') };
    await openSession(I.session.id);
  } catch (err) {
    I.extracting = false;
    I.sessionMsg = { text: err.message, error: true };
    render();
  }
}

async function confirmSession() {
  const overrides = I.staged.filter((r) => !r.confirmed_at)
    .map((r) => ({ id: r.id, action: r.action, resolved_name: r.resolved_name }));
  try {
    const res = await api(`import/${I.mode}/confirm`, jsonReq({ session_id: I.session.id, overrides }));
    const c = res.counts;
    I.sessionMsg = {
      text: `Imported ${c.inserted} new, updated ${c.updated}, ignored ${c.ignored}.`
        + (res.conflicts.length ? ` ${res.conflicts.length} left pending — give them a distinguishing name.` : ''),
      error: res.conflicts.length > 0,
    };
    await openSession(I.session.id);
  } catch (err) { I.sessionMsg = { text: err.message, error: true }; render(); }
}

boot();

// ─── structured editors for the two blocks nobody remembers the shape of ───
//
// Above the markdown, not instead of it. The file stays visible and stays the
// source of truth: editing a block rewrites exactly that block in place, so you
// can watch what changed and every comment outside it survives.
//
// Only `bonuses` and `variants` get one. The rest of the frontmatter is either
// obvious (a name, a source book) or prose, and a form over the whole file
// would have to regenerate the frontmatter — losing the template's comments,
// which are most of what makes a hand-written class approachable.

const BONUS_GROUPS = ['attributes', 'combat', 'saves'];
const BONUS_ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];

// The frontmatter as the server last parsed it. Re-check refreshes it, and
// every block edit ends in a re-check, so it always describes what is on screen.
function currentData() {
  return { md: $('md')?.value ?? I.result?.markdown ?? '', data: I.result?.data || {} };
}

// Rewrite one block and put the result back in the textarea, then re-check.
async function applyBlock(key, value) {
  const { md } = currentData();
  const next = classBlocks.write(md, key, value);
  $('md').value = next;
  I.result = { ...I.result, markdown: next };
  await reparse();
}

function blockEditors() {
  if (!I.result?.markdown) return '';
  const { data } = currentData();
  return `<details class="block-editors" ${I.blocksOpen ? 'open' : ''}>
    <summary onclick="I.blocksOpen = !I.blocksOpen">Bonuses &amp; variants — structured editors</summary>
    <p class="muted small">These rewrite just their own block in the file below. Comments inside an
      edited block are replaced; everything outside it is untouched.</p>
    ${bonusesEditor(data)}
    ${variantsEditor(data)}
  </details>`;
}

// A bonuses block is really a list of (level, group, key, value) tuples —
// at_level is the same thing with a level attached — so one table covers both
// instead of a nested editor per group and another inside every at_level entry.
function bonusesEditor(data) {
  const rows = classBlocks.bonusesToRows(data.bonuses);
  const opts = (list, sel) => list.map((o) =>
    `<option value="${escHtml(o)}"${o === sel ? ' selected' : ''}>${escHtml(o)}</option>`).join('');

  const row = (r, i) => `<tr>
    <td><input type="number" min="2" style="width:64px" value="${r.level ?? ''}"
      placeholder="start" data-bonus="${i}" data-field="level"></td>
    <td><select data-bonus="${i}" data-field="group">${opts(BONUS_GROUPS, r.group)}</select></td>
    <td>${r.group === 'attributes'
      ? `<select data-bonus="${i}" data-field="key">${opts(BONUS_ATTRS, r.key)}</select>`
      : `<input type="text" style="width:130px" value="${escHtml(r.key)}" data-bonus="${i}" data-field="key">`}</td>
    <td><input type="number" style="width:64px" value="${r.value}" data-bonus="${i}" data-field="value"></td>
    <td><button class="btn btn-sm btn-ghost" onclick="removeBonusRow(${i})">✕</button></td>
  </tr>`;

  return `<h4>Bonuses <span class="muted small">— numbers the sheet adds up</span></h4>
  <p class="muted small">Leave the level blank for a bonus the class has from the start.
    A conditional bonus ("+2 to strike when flying") belongs in prose, not here — this block is applied unconditionally.</p>
  <table class="block-table">
    <tr><th>Level</th><th>Group</th><th>Key</th><th>Value</th><th></th></tr>
    ${rows.map(row).join('') || '<tr><td colspan="5" class="muted small">No bonuses.</td></tr>'}
  </table>
  <div class="rowline">
    <button class="btn btn-sm" onclick="addBonusRow()">+ Add a bonus</button>
    <button class="btn btn-sm btn-ghost" onclick="saveBonuses()">Write to the file</button>
  </div>`;
}

function readBonusRows() {
  const rows = [];
  for (const el of document.querySelectorAll('[data-bonus]')) {
    const i = +el.dataset.bonus;
    (rows[i] ||= { level: null, group: 'combat', key: '', value: 0 });
    const v = el.value;
    if (el.dataset.field === 'level') rows[i].level = v === '' ? null : parseInt(v, 10);
    else if (el.dataset.field === 'value') rows[i].value = v === '' ? NaN : Number(v);
    else rows[i][el.dataset.field] = v;
  }
  return rows.filter(Boolean);
}

function addBonusRow() {
  I.bonusDraft = [...readBonusRows(), { level: null, group: 'combat', key: 'attacks', value: 1 }];
  applyBlock('bonuses', classBlocks.rowsToBonuses(I.bonusDraft));
}
function removeBonusRow(i) {
  const rows = readBonusRows().filter((_, n) => n !== i);
  applyBlock('bonuses', classBlocks.rowsToBonuses(rows));
}
function saveBonuses() { applyBlock('bonuses', classBlocks.rowsToBonuses(readBonusRows())); }

// Variants are rebuilt from the PARSED objects, so attribute_dice, pool bases
// and per-variant bonuses survive a save even though only id and name are
// editable here. Editing those in the markdown stays the way to change them.
function variantsEditor(data) {
  const variants = Array.isArray(data.variants) ? data.variants : [];
  const row = (v, i) => {
    const extras = Object.keys(v).filter((k) => k !== 'id' && k !== 'name');
    return `<tr>
      <td><input type="text" style="width:120px" value="${escHtml(v.id || '')}" data-variant="${i}" data-field="id"></td>
      <td><input type="text" style="width:220px" value="${escHtml(v.name || '')}" data-variant="${i}" data-field="name"></td>
      <td class="muted small">${extras.length ? escHtml(extras.join(', ')) + ' — edit below' : 'inherits everything'}</td>
      <td><button class="btn btn-sm btn-ghost" onclick="removeVariant(${i})">✕</button></td>
    </tr>`;
  };
  return `<h4>Variants <span class="muted small">— stages of the same class</span></h4>
  <p class="muted small">A variant may override attribute dice, attribute requirements, the pool bases
    and bonuses; skills, abilities and lore stay shared. Those overrides are edited in the file below —
    they are preserved when you save here.</p>
  <table class="block-table">
    <tr><th>Id</th><th>Name</th><th>Overrides</th><th></th></tr>
    ${variants.map(row).join('') || '<tr><td colspan="4" class="muted small">No variants — the class has one form.</td></tr>'}
  </table>
  <div class="rowline">
    <button class="btn btn-sm" onclick="addVariant()">+ Add a variant</button>
    <button class="btn btn-sm btn-ghost" onclick="saveVariants()">Write to the file</button>
  </div>`;
}

function readVariants() {
  const { data } = currentData();
  const parsed = Array.isArray(data.variants) ? data.variants : [];
  const out = [];
  for (const el of document.querySelectorAll('[data-variant]')) {
    const i = +el.dataset.variant;
    // Start from the parsed variant so its overrides survive the rebuild.
    (out[i] ||= { ...(parsed[i] || {}) });
    out[i][el.dataset.field] = el.value;
  }
  return out.filter(Boolean);
}

function addVariant() {
  applyBlock('variants', [...readVariants(), { id: 'new-stage', name: 'New stage' }]);
}
function removeVariant(i) {
  applyBlock('variants', readVariants().filter((_, n) => n !== i));
}
function saveVariants() { applyBlock('variants', readVariants()); }
