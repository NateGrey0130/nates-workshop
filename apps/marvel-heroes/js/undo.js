// "Removed. Undo" instead of "Are you sure?", for the deletes the shared
// campaign views make one row at a time (a note, a dossier, a picture). The
// same contract as the Palladium pages' apps/character-creator/js/undo-toast.js,
// which the shared views are written against; Marvel keeps its own copy
// because a page here loads no other group's script.
//
// The row goes from the screen at once and the request waits six seconds
// behind an Undo, so an undone delete is one the server never saw. One
// pending at a time: a second removal sends the first. Leaving the page sends
// what is waiting, with keepalive, so closing the tab never quietly keeps
// something the person removed.
//
//   undoable({ label, hide, restore, commit })
//     hide()             take it off the screen now (in state; the page re-renders)
//     restore()          put it back - on Undo, and when the request fails
//     commit(keepalive)  send the request

const WINDOW_MS = 6000;
let pending = null;
let box = null;

const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function toast(html) {
  if (!box || !document.body.contains(box)) {
    box = document.createElement('div');
    box.className = 'undo-toast';
    box.setAttribute('role', 'status');
    box.setAttribute('aria-live', 'polite');
    document.body.appendChild(box);
  }
  box.innerHTML = html;
  box.hidden = false;
}
const hideToast = () => { if (box) box.hidden = true; };

async function send(p, keepalive) {
  clearTimeout(p.timer);
  if (pending === p) { pending = null; hideToast(); }
  try {
    await p.commit(!!keepalive);
  } catch (err) {
    try { p.restore(); } catch { /* the message still stands */ }
    toast(`<span class="err">Could not remove ${esc(p.label)}: ${esc(err?.message || 'request failed')}. It is back.</span>`
      + '<button type="button" class="btn small" data-undo-dismiss>OK</button>');
  }
}

export function undoable({ label, hide, restore, commit }) {
  if (pending) send(pending, false);
  hide();
  const p = { label, restore, commit, timer: null };
  pending = p;
  p.timer = setTimeout(() => send(p, false), WINDOW_MS);
  toast(`<span>Removed ${esc(label)}.</span><button type="button" class="btn small" data-undo-now>Undo</button>`);
}

// Only on a page: the suite imports js/campaign-ui.js, which imports this, in Node.
if (typeof document !== 'undefined') {
  document.addEventListener('click', (e) => {
    if (e.target.closest('[data-undo-dismiss]')) { hideToast(); return; }
    if (!e.target.closest('[data-undo-now]') || !pending) return;
    const p = pending;
    pending = null;
    clearTimeout(p.timer);
    hideToast();
    p.restore();
  });
  addEventListener('pagehide', () => { if (pending) send(pending, true); });
}
