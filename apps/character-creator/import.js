// OCC/RCC class import — admin only. Upload a focused PDF page range, extract
// via Claude, review/edit the whole markdown file, confirm to create item stubs
// and get catalog snippets. Nothing touches git; the markdown is copied out.
// escHtml() comes from /shared/js/ui.js.
'use strict';

const I = { isAdmin: false, email: null, extracting: false, result: null, confirmed: null };
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
  } catch { /* falls through to the denied view */ }
  render();
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
  </div>`;
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
      Edit anything below — it's the actual file. Nothing is saved until you confirm.</p>
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
    render();
  } catch (err) { $('msg').innerHTML = `<span class="err">${escHtml(err.message)}</span>`; }
}

// ─── Step 3: output ───
function renderConfirmed() {
  const c = I.confirmed;
  const snippetBlocks = Object.entries(c.snippets || {}).map(([file, entries]) => `
    <h3>${escHtml(file)} <span class="muted small">— merge these entries by hand</span></h3>
    <pre class="snippet">${escHtml(JSON.stringify(entries, null, 2))}</pre>
    <div class="rowline"><button class="btn btn-sm" onclick="copyText(${JSON.stringify(file)})">Copy</button></div>`).join('');

  $('app').innerHTML = `
  <div class="panel">
    <h2>✅ Ready to commit</h2>
    <p class="muted">Save this as <span class="mono">apps/character-creator/data/classes/${escHtml(c.class_id)}.md</span>
      and add <span class="mono">"${escHtml(c.class_id)}.md"</span> to <span class="mono">data/classes/index.json</span>.</p>
    <div class="rowline">
      <button class="btn btn-primary" onclick="downloadMd()">⬇ Download ${escHtml(c.class_id)}.md</button>
      <button class="btn btn-sm" onclick="copyMd()">Copy markdown</button>
      <span id="msg" class="muted small"></span>
    </div>
    <pre class="snippet" id="final-md">${escHtml(c.markdown)}</pre>
  </div>

  ${c.inserted_items?.length ? `<div class="panel">
    <h3 style="margin-top:0">Item stubs created <span class="badge-live">live in D1 now</span></h3>
    ${c.inserted_items.map((it) => `<div class="miss-row"><span class="slug">${escHtml(it.slug)}</span>
      <span>${escHtml(it.name)}</span></div>`).join('')}
    <p class="muted small" style="margin-top:8px">Name and slug only — fill in weight, cost, and stats when you get to them.</p>
  </div>` : ''}

  ${snippetBlocks ? `<div class="panel">${snippetBlocks}</div>` : ''}

  <div class="nav"><button class="btn btn-ghost" onclick="startOver()">← Import another</button><span></span></div>`;
}

function copyText(file) {
  const entries = I.confirmed.snippets[file];
  copyWithFeedback(JSON.stringify(entries, null, 2), event.target);
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
function startOver() { I.result = null; I.confirmed = null; render(); }

boot();
