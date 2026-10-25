// "Transfer to player…": the one dialog the sheet, the statted-NPC rows and the
// NPC library share (functions/api/character-creator/characters/[id]/transfer.js
// and npc-library/[id]/transfer.js make the move).
//
// The picker is filled ONLY from GET transfer-candidates - the Workshop's list
// of people who can sign in, minus the caller - so there is no free-text box to
// type an address nobody can use. An empty list is a disabled dialog that says
// who can fix it, rather than a picker with nothing in it.
//
// `send(email, campaignId)` makes the move and either returns the server's
// answer or throws api()'s error, whose message is shown here. The promise
// resolves with that answer on success and null when the dialog is dismissed.
// Pass `campaigns` (and `campaignId`, the one to preselect) to ask where it
// lands too: a library entry is in no campaign.
//
// A classic script, like npc-sheets.js: escHtml() from /shared/js/ui.js, api()
// from js/api.js. Every handler is added with addEventListener, so nothing
// here lands in an inline handler and escJs is not needed.
'use strict';

window.transferDialog = (function () {
  const EMPTY = 'Nobody to transfer to. Ask Nate to add them to the share list';
  const WHAT = 'This moves the character to them. Notes, the play log and NPC gear notes are cleared. The bio is not.';

  function open({ name, send, campaigns = null, campaignId = null }) {
    const dlg = document.createElement('dialog');
    dlg.className = 'transfer-dialog';
    const campField = campaigns ? `<label class="small transfer-field">Into campaign
        <select name="campaign" required${campaigns.length ? '' : ' disabled'}>${campaigns.length
          ? campaigns.map((c) => `<option value="${escHtml(c.id)}"${String(c.id) === String(campaignId) ? ' selected' : ''}>${
            escHtml(c.name)}${c.system ? ` (${escHtml(c.system)})` : ''}</option>`).join('')
          : '<option value="">You run no campaign</option>'}</select></label>` : '';
    dlg.innerHTML = `<form method="dialog" class="transfer-form">
        <h3>Transfer ${escHtml(name)} to a player</h3>
        <label class="small transfer-field">To player
          <select name="to" required disabled><option value="">Loading…</option></select></label>
        ${campField}
        <p class="small transfer-warn">${WHAT}</p>
        <p class="small transfer-status" aria-live="polite"></p>
        <div class="rowline transfer-buttons">
          <button type="submit" class="btn btn-sm btn-primary" value="confirm" disabled>Confirm</button>
          <button type="submit" class="btn btn-sm btn-ghost" value="cancel" formnovalidate>Cancel</button>
        </div>
      </form>`;
    document.body.append(dlg);
    const form = dlg.querySelector('form');
    const pick = form.elements.to;
    const camp = form.elements.campaign || null;
    const ok = dlg.querySelector('button[value="confirm"]');
    const status = dlg.querySelector('.transfer-status');
    const say = (text, err = false) => { status.textContent = text; status.classList.toggle('err', err); };

    return new Promise((resolve) => {
      // Every way out goes through finish() rather than the dialog's close
      // event, which the desktop app's Browser pane never fires.
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
        if (!pick.value || (camp && !camp.value)) return;
        ok.disabled = true;
        say('Moving…');
        try {
          finish(await send(pick.value, camp ? Number(camp.value) : null));
        } catch (err) {
          say(err.message || String(err), true);
          ok.disabled = false;
        }
      });
      dlg.showModal();
      api('transfer-candidates').then((res) => {
        const list = res.candidates || [];
        if (!list.length) {
          pick.innerHTML = '<option value="">Nobody</option>';
          say(EMPTY);
          return;
        }
        pick.innerHTML = '<option value="">— pick a player —</option>'
          + list.map((e) => `<option value="${escHtml(e)}">${escHtml(e)}</option>`).join('');
        pick.disabled = false;
        ok.disabled = !!camp && !campaigns.length;
      }, (err) => {
        pick.innerHTML = '<option value="">Nobody</option>';
        say('Could not load the list of players: ' + err.message, true);
      });
    });
  }

  return { open, EMPTY, WHAT };
})();
