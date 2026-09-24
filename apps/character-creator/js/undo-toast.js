// "Removed. Undo" in place of "Are you sure?", for the deletes a person makes
// one row at a time.
//
// A classic script, like api.js, because the sheet, the campaign page and GM
// Tools are all plain scripts. Exposes one function, `undoable`.
//
// WHY NOT confirm(). A confirm is asked BEFORE the mistake, when the person is
// sure - which is why they clicked - so it gets clicked through, and it is
// modal, which at a table on a phone means a dialog over the sheet mid-fight.
// The mistake is noticed AFTER, when the row is gone. So the row goes at once,
// and the request that makes it permanent waits a few seconds behind an Undo.
//
// THE SERVER NEVER SEES AN UNDONE DELETE. Undo cancels a request that has not
// been sent; it does not reverse one that has. That is the whole reason this
// needs no new route: soft-deleted rows, hard-deleted rows and a picture in R2
// are all handled the same way, by not asking yet.
//
// ONE PENDING AT A TIME. A second removal while one is waiting commits the
// first straight away, so Undo always means the thing the toast names - never
// a queue of removals the person has to count backwards through.
//
// LEAVING THE PAGE COMMITS. On pagehide the pending request is sent with
// `keepalive`, which lets it outlive the page; closing the tab inside the
// window must not quietly keep something the person removed.
//
// What each caller supplies:
//   label    - what was removed, as the toast should say it ("Laser pistol")
//   hide()   - take it off the screen NOW. At state level, not DOM level: the
//              pages re-render, and a row hidden only in the DOM comes back
//              on the next paint.
//   restore()- put it back exactly where it was. Called on Undo, and when the
//              request fails, so a failure never leaves a row that looks
//              deleted and is not.
//   commit(keepalive) - send the request. Receives true when the page is
//              going away, to pass through as fetch's `keepalive`.
//
// NOT for a whole character, a bulk action, or anything the person should
// stop and read about first - those keep their confirm(). See the callers.

(function (global) {
  const WINDOW_MS = 6000;
  let pending = null;   // { label, restore, commit, timer }
  let box = null;

  function toastEl() {
    if (box && document.body.contains(box)) return box;
    box = document.createElement('div');
    box.className = 'undo-toast noprint';
    box.setAttribute('role', 'status');
    box.setAttribute('aria-live', 'polite');
    box.hidden = true;
    document.body.appendChild(box);
    return box;
  }

  function show(html) {
    const el = toastEl();
    el.innerHTML = html;
    el.hidden = false;
  }

  function hideToast() { if (box) box.hidden = true; }

  function esc(s) {
    return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }

  async function send(p, keepalive) {
    clearTimeout(p.timer);
    if (pending === p) { pending = null; hideToast(); }
    try {
      await p.commit(!!keepalive);
    } catch (err) {
      // Put it back and say so. A row that vanished and then failed to delete
      // is the worst outcome available, because nothing on screen shows it.
      try { p.restore(); } catch { /* the message still stands */ }
      show(`<span class="err">Could not remove ${esc(p.label)}: ${esc(err?.message || 'request failed')}. It is back.</span>`
        + '<button type="button" class="btn btn-sm btn-ghost" data-undo-dismiss>OK</button>');
    }
  }

  function undoable({ label, hide, restore, commit }) {
    if (pending) send(pending, false);
    hide();
    const p = { label, restore, commit, timer: null };
    pending = p;
    p.timer = setTimeout(() => send(p, false), WINDOW_MS);
    show(`<span>Removed ${esc(label)}.</span>`
      + '<button type="button" class="btn btn-sm" data-undo-now>Undo</button>');
  }

  document.addEventListener('click', (e) => {
    if (e.target.closest('[data-undo-dismiss]')) { hideToast(); return; }
    if (!e.target.closest('[data-undo-now]') || !pending) return;
    const p = pending;
    pending = null;
    clearTimeout(p.timer);
    hideToast();
    p.restore();
  });

  // The page is going: send what is waiting, and let it outlive the page.
  global.addEventListener('pagehide', () => { if (pending) send(pending, true); });

  global.undoable = undoable;
})(globalThis);
