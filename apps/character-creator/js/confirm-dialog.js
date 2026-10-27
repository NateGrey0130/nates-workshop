// A question, or a notice, in a modal <dialog> instead of the browser's own
// confirm() and alert() boxes, which halt every script on the page, cannot be
// styled, and on some browsers carry the site's address as their title.
//
//   await confirmDialog(text, { okLabel, cancelLabel, danger })  -> true | false
//   await noticeDialog(text, { okLabel })                         -> undefined
//
// - The text is set with textContent, so a class or skill name read from a
//   sourcebook cannot become markup and nothing needs escaping first.
// - Focus goes to Cancel when `danger` is set (a stray Enter keeps the build)
//   and to OK otherwise, stays inside the dialog on Tab and Shift+Tab, and goes
//   back to whatever held it before the dialog opened.
// - Escape is No. So is anything else that closes the dialog without OK.
//
// Every way out goes through finish(), never the dialog's close event alone,
// which the desktop app's Browser pane never fires (js/transfer-dialog.js).
//
// A classic script that publishes onto globalThis, so app.js (a module) and
// any classic page script can call it, and the smoke suite can run it against
// a stand-in document.
'use strict';

(function (g) {
  function open(text, { okLabel = 'OK', cancelLabel = 'Cancel', danger = false, notice = false } = {}) {
    const doc = g.document;
    const back = doc.activeElement;
    const dlg = doc.createElement('dialog');
    dlg.className = 'confirm-dialog';
    dlg.setAttribute('role', notice ? 'alertdialog' : 'dialog');
    const p = doc.createElement('p');
    p.className = 'confirm-text';
    p.id = 'confirm-dialog-text';
    p.textContent = text;
    dlg.setAttribute('aria-describedby', p.id);
    const row = doc.createElement('div');
    row.className = 'rowline confirm-buttons';
    const button = (label, cls) => {
      const b = doc.createElement('button');
      b.type = 'button';
      b.className = cls;
      b.textContent = label;
      row.append(b);
      return b;
    };
    const ok = button(okLabel, `btn btn-sm ${danger ? 'btn-danger' : 'btn-primary'}`);
    const cancel = notice ? null : button(cancelLabel, 'btn btn-sm btn-ghost');
    dlg.append(p, row);
    doc.body.append(dlg);
    const buttons = cancel ? [ok, cancel] : [ok];

    return new Promise((resolve) => {
      let done = false;
      const finish = (value) => {
        if (done) return;
        done = true;
        if (dlg.open) dlg.close();
        dlg.remove();
        if (back && back.isConnected !== false && typeof back.focus === 'function') back.focus({ preventScroll: true });
        resolve(notice ? undefined : value);
      };
      ok.addEventListener('click', () => finish(true));
      if (cancel) cancel.addEventListener('click', () => finish(false));
      // Escape: the dialog's own cancel event, and the key itself for a
      // browser that does not send one.
      dlg.addEventListener('cancel', (e) => { e.preventDefault(); finish(false); });
      dlg.addEventListener('close', () => finish(false));
      dlg.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') { e.preventDefault(); finish(false); return; }
        if (e.key !== 'Tab') return;
        // showModal() already makes the page behind inert; this keeps Tab from
        // leaving the dialog for the browser's own toolbar as well.
        const at = buttons.indexOf(doc.activeElement);
        const next = e.shiftKey ? (at <= 0 ? buttons.length - 1 : at - 1) : (at + 1) % buttons.length;
        e.preventDefault();
        buttons[next].focus();
      });
      dlg.showModal();
      (danger && cancel ? cancel : ok).focus();
    });
  }

  g.confirmDialog = (text, opts = {}) => open(text, { ...opts, notice: false });
  g.noticeDialog = (text, opts = {}) => open(text, { ...opts, notice: true });
})(globalThis);
