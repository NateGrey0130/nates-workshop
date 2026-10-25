// "Transfer to player...": the one dialog the My heroes tab and the GM page
// share. The picker is filled only from GET /api/marvel-heroes/transfer - the
// Access allowlist's mirror, minus the caller - so there is no free-text box to
// type an address nobody can sign in with. `send(email)` makes the move and
// answers as api() does; the promise resolves with that answer on success and
// null when the dialog is dismissed.

import { api, errorOf } from './api.js';
import { esc } from './sheet.js';

export function transferDialog({ name, send }) {
  const dlg = document.createElement('dialog');
  dlg.className = 'transfer-dialog';
  dlg.innerHTML = `<form method="dialog" class="transfer-form">
      <h2>Transfer ${esc(name)}</h2>
      <label class="transfer-field">To player
        <select name="to" required disabled><option value="">Loading...</option></select></label>
      <p class="transfer-warn">Notes will be cleared and the character will leave your list.</p>
      <p class="muted transfer-status" aria-live="polite"></p>
      <div class="row">
        <button type="submit" class="btn" value="confirm" disabled>Confirm</button>
        <button type="submit" class="btn secondary" value="cancel" formnovalidate>Cancel</button>
      </div>
    </form>`;
  document.body.append(dlg);
  const form = dlg.querySelector('form');
  const pick = dlg.querySelector('select');
  const ok = dlg.querySelector('button[value="confirm"]');
  const say = (t) => { dlg.querySelector('.transfer-status').textContent = t; };

  return new Promise((resolve) => {
    // Every way out goes through finish(), rather than through the dialog's
    // close event: the desktop app's Browser pane never fires that event.
    let done = false;
    const finish = (value) => {
      if (done) return;
      done = true;
      if (dlg.open) dlg.close();
      dlg.remove();
      resolve(value);
    };
    dlg.addEventListener('cancel', (e) => { e.preventDefault(); finish(null); });   // Escape
    dlg.addEventListener('close', () => finish(null));
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      if (e.submitter?.value !== 'confirm') { finish(null); return; }
      if (!pick.value) return;
      ok.disabled = true;
      say('Moving...');
      const r = await send(pick.value);
      if (!r.ok) { say(errorOf(r)); ok.disabled = false; return; }
      finish(r);
    });
    dlg.showModal();
    api('transfer').then((r) => {
      const list = r.ok ? r.data.candidates : [];
      if (!r.ok) { say(errorOf(r)); pick.innerHTML = '<option value="">Nobody</option>'; return; }
      if (!list.length) { say('There is nobody to hand it to: the list of people who can sign in is empty.'); pick.innerHTML = '<option value="">Nobody</option>'; return; }
      pick.innerHTML = '<option value="">Pick a player</option>' + list.map((e) => `<option value="${esc(e)}">${esc(e)}</option>`).join('');
      pick.disabled = false;
      ok.disabled = false;
    });
  });
}
