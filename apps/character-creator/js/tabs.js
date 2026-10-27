// One tabs helper: the ARIA tabs pattern wired onto a tablist a page already
// drew, so no page keeps its own copy of the roles, the ids and the keys.
//
// The page draws its buttons and its panels; this adds what a screen reader
// and a keyboard need on top of them:
//   - role="tablist" on the list, role="tab" and aria-selected on each tab;
//   - an id on each tab, and aria-controls naming its panel;
//   - role="tabpanel", an id and aria-labelledby on each panel, plus
//     tabindex="0" so a panel that opens on plain text is still a Tab stop;
//   - ROVING tabindex: the selected tab is the one Tab stop (0), the rest -1,
//     so Tab moves into the panel rather than along the strip;
//   - ArrowLeft / ArrowRight (wrapping), Home and End, which select the tab
//     they land on and move focus to it (automatic activation).
//
// unwire() takes all of it off again, for a strip that is sometimes a nav and
// not a tablist - the character sheet on a wide screen with a mouse, where the
// buttons scroll to sections and claiming role="tab" would promise a panel
// swap that never comes. The arrow keys do nothing while unwired: the handler
// asks the list for its role on every press.
//
// Classic script, one global, same shape as sticky.js and undo-toast.js.
// wire() is safe to call on every render: the key handler is added once per
// list element, and reads the options from the latest call.
//
// The options:
//   prefix    - makes the ids unique on the page ('sheet' -> sheet-tab-gear)
//   tabs      - the tab elements, in order
//   key(el)   - a tab's key (the sheet uses data-tab)
//   panel(k)  - the panel element for a key, an array of them, or null
//   selected(k) - is this key the selected one
//   select(k) - make it selected; the page owns what that means
(function (global) {
  'use strict';

  const current = new WeakMap();   // list -> the options of the latest wire()
  const listening = new WeakSet(); // lists that already have the key handler

  const tabId = (o, k) => `${o.prefix}-tab-${k}`;
  const panelId = (o, k) => `${o.prefix}-panel-${k}`;

  function wire(list, o) {
    if (!list) return;
    current.set(list, o);
    list.setAttribute('role', 'tablist');
    const keys = o.tabs.map((el) => o.key(el));
    // One Tab stop always: if nothing is selected, the first tab holds it.
    const sel = keys.findIndex((k) => o.selected(k));
    o.tabs.forEach((el, i) => {
      const k = keys[i];
      const on = i === (sel < 0 ? 0 : sel);
      el.setAttribute('role', 'tab');
      el.setAttribute('id', tabId(o, k));
      el.setAttribute('aria-selected', String(sel >= 0 && on));
      el.setAttribute('tabindex', on ? '0' : '-1');
      const ps = panelsOf(o, k);
      ps.forEach((p, j) => {
        p.setAttribute('role', 'tabpanel');
        p.setAttribute('id', panelId(o, k) + (j ? '-' + (j + 1) : ''));
        p.setAttribute('aria-labelledby', tabId(o, k));
        p.setAttribute('tabindex', '0');
      });
      if (ps.length) el.setAttribute('aria-controls', ps.map((p) => p.id).join(' '));
      else el.removeAttribute('aria-controls');
    });
    if (!listening.has(list)) {
      listening.add(list);
      list.addEventListener('keydown', (ev) => onKey(list, ev));
    }
  }

  function unwire(list, o) {
    if (!list) return;
    current.set(list, o);
    list.removeAttribute('role');
    for (const el of o.tabs) {
      for (const a of ['role', 'aria-selected', 'aria-controls', 'tabindex']) el.removeAttribute(a);
      for (const p of panelsOf(o, o.key(el))) {
        for (const a of ['role', 'aria-labelledby', 'tabindex']) p.removeAttribute(a);
      }
    }
  }

  // panel(k) may hand back one element, several, or nothing. Several is the
  // sheet: its column stacker can split one panel into slices in two columns,
  // and each slice is part of the panel, so each is a tabpanel and the tab's
  // aria-controls names them all.
  function panelsOf(o, k) {
    const p = o.panel(k);
    if (!p) return [];
    return (Array.isArray(p) ? p : [p]).filter(Boolean);
  }

  // The index a key press moves to from `i` among `n` tabs, or -1 for a key
  // this does not handle. Exposed so the arithmetic can be tested alone.
  function step(key, i, n) {
    if (n < 1) return -1;
    if (key === 'ArrowRight') return (i + 1) % n;
    if (key === 'ArrowLeft') return (i - 1 + n) % n;
    if (key === 'Home') return 0;
    if (key === 'End') return n - 1;
    return -1;
  }

  function onKey(list, ev) {
    if (list.getAttribute('role') !== 'tablist') return;
    if (ev.ctrlKey || ev.metaKey || ev.altKey) return;
    const o = current.get(list);
    if (!o) return;
    const i = o.tabs.findIndex((el) => el === ev.target || (el.contains && el.contains(ev.target)));
    if (i < 0) return;
    const to = step(ev.key, i, o.tabs.length);
    if (to < 0) return;
    ev.preventDefault();
    const k = o.key(o.tabs[to]);
    o.select(k);
    // The page may have redrawn on select; wire again from the latest options
    // and focus whatever element now carries that key.
    const now = current.get(list) || o;
    wire(list, now);
    const target = now.tabs.find((el) => now.key(el) === k);
    if (target && target.focus) target.focus();
  }

  global.tabs = { wire, unwire, step };
})(globalThis);
