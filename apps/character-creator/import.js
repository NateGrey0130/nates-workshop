// OCC/RCC class import — admin only. Upload a focused PDF page range, extract
// via Claude, review/edit the whole markdown file, confirm to create item stubs
// and get catalog snippets. Nothing touches git; the markdown is copied out.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const I = { isAdmin: false, email: null, extracting: false, result: null, confirmed: null, stored: [] };
const $ = (id) => document.getElementById(id);

async function api(path, opts) {
  const res = await fetch('/api/character-creator/' + path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || ('API ' + res.status));
  return data;
}
const jsonReq = (body) => ({ method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

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
  try { I.stored = (await api('import/stored')).stored || []; }
  catch { I.stored = []; }
}

function render() {
  if (!I.isAdmin) {
    $('app').innerHTML = `<div class="panel">
      <h2>Admin only</h2>
      <p class="muted">This tool edits the global class catalog, so it's limited to the site admin${I.email ? ` — you're signed in as ${escHtml(I.email)}` : ''}.</p>
    </div>`;
    return;
  }
  if (I.confirmed) return renderConfirmed();
  if (I.result) return renderReview();
  renderUpload();
}

// ─── Step 1: upload ───
function renderUpload() {
  $('app').innerHTML = `
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
function storedPanel() {
  if (!I.stored.length) return '';
  const rows = I.stored.map((s) => `
    <div class="miss-row">
      <span class="slug">${escHtml(s.class_id)}</span>
      <span>${escHtml(s.name || '')}</span>
      <span class="tag ${s.status === 'published' ? 'gm' : ''}">${escHtml(s.status)}</span>
      <span class="muted small">${escHtml(s.system || '')} · ${escHtml(s.updated_at)}</span>
      <span style="margin-left:auto; display:flex; gap:6px">
        <button class="btn btn-sm" onclick="reopenStored('${escHtml(s.class_id)}')">Open</button>
        <button class="btn btn-sm btn-ghost" onclick="removeStored('${escHtml(s.class_id)}')">Delete</button>
      </span>
    </div>`).join('');
  return `
  <div class="panel">
    <h3 style="margin-top:0">Saved imports <span class="muted small">(drafts autosave on extraction; published classes are live in the app)</span></h3>
    ${rows}
  </div>`;
}

async function reopenStored(classId) {
  try {
    const { stored } = await api('import/stored?class_id=' + encodeURIComponent(classId));
    const check = await api('import/recheck', jsonReq({ markdown: stored.markdown }));
    I.result = { ...check, markdown: stored.markdown, model: 'saved draft', usage: null };
    render();
  } catch (err) { alert('Could not open: ' + err.message); }
}

async function removeStored(classId) {
  if (!confirm(`Delete the saved import "${classId}"? If it is published, the class stops appearing in the app.`)) return;
  try {
    await api('import/stored?class_id=' + encodeURIComponent(classId), { method: 'DELETE' });
    await loadStored();
    render();
  } catch (err) { alert('Delete failed: ' + err.message); }
}

async function runExtract() {
  const file = $('pdf').files[0];
  if (!file) { $('msg').textContent = 'Pick a PDF first.'; return; }
  if (I.extracting) return;
  I.extracting = true;
  $('go').disabled = true;
  $('msg').textContent = `Reading ${file.name}…`;
  try {
    const b64 = await new Promise((resolve, reject) => {
      const fr = new FileReader();
      fr.onload = () => resolve(String(fr.result).split(',')[1]);
      fr.onerror = () => reject(new Error('Could not read the file'));
      fr.readAsDataURL(file);
    });
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

boot();
