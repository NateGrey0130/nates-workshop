// The campaign UI every game shares: the notes feed with search and Ask, the
// people and their dossiers, the handouts, the GM's setting pages, the party's
// currency ledger, and present mode. This file is the part the others stand
// on; each of them adds itself to `mcCampaign`.
//
// WHAT IS SHARED AND WHAT IS NOT. These files are MARKUP AND BEHAVIOUR. They
// write no styles - no inline style attribute, no stylesheet - and depend on
// no app's stylesheet. Every class they emit starts `mc-`, and each app styles
// those classes in its own CSS: the Palladium pages in
// apps/character-creator/styles.css (and shared/styles.css, where the button
// rules already lived), the Marvel app in its own standalone sheet. What a
// game does that the other does not - its pools, its XP, its NPC roller, its
// gear catalog, its cities - stays in that game's page, and reaches these
// views through the hooks each view takes.
//
// THE SERVER STAYS PER GROUP. Nothing here names an endpoint's host. A page
// passes its own API base ('/api/character-creator', '/api/marvel-heroes'),
// and every request and every image URL is built from it, so a page can only
// ever reach its own group's database (groups.mjs --check).
//
// A classic script, like the rest of the pages' helpers. Load order:
//   core.js, then any of notes.js, people.js, handouts.js, ledger.js,
//   setting.js (and downscale.js before people.js or setting.js).
// present.js needs core.js alone.
//
// mcCampaign.init({ base, campaignId, ui, render, reload, showPeople }):
//   base       - the group's API base, no trailing slash needed
//   campaignId - the campaign on this page
//   ui         - the page's adapter, so no module imports shared/js/ui.js:
//                  esc(v)         escape for element content and attributes
//                  escJs(v)       escape for a JS string inside an inline handler
//                  modal(text)    ask yes/no; returns a promise of a boolean
//                  toast(text)    tell the person something went wrong
//                  undoable(opts) the page's "Removed. Undo" (label, hide,
//                                 restore, commit) - see
//                                 apps/character-creator/js/undo-toast.js
//   render()   - repaint the page; the views return HTML and the page places it
//   reload()   - fetch everything again and repaint (after a write)
//   showPeople() - optional: make the people view the one on screen, for a
//                  mention clicked inside a note on another tab
'use strict';

(function (global) {
  // A request bound to one group's API. The same contract as the Palladium
  // pages' api() (apps/character-creator/js/api.js): the parsed body on
  // success, and on failure an Error carrying `status` and the whole body as
  // `detail`, so a caller can read a 409's code or a 422's violations. The
  // smoke suite holds the two to that same shape.
  function client(base) {
    const root = String(base).replace(/\/+$/, '') + '/';
    return async function api(path, opts) {
      const res = await fetch(root + path, opts);
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        const err = new Error(data.error || ('API ' + res.status));
        err.status = res.status;
        err.detail = data;
        throw err;
      }
      return data;
    };
  }

  const ctx = {
    base: '', campaignId: null, api: null, ui: null,
    render: () => {}, reload: () => {}, showPeople: () => {},
  };

  function init(opts) {
    ctx.base = String(opts.base).replace(/\/+$/, '');
    ctx.campaignId = opts.campaignId;
    ctx.api = client(ctx.base);
    ctx.ui = opts.ui;
    ctx.render = opts.render;
    ctx.reload = opts.reload;
    ctx.showPeople = opts.showPeople || (() => {});
    return ctx;
  }

  // When a note or a mention happened: the session date the author gave, or
  // when it was written.
  const when = (e) => e.session_date || (e.created_at || '').replace('T', ' ').replace('Z', '');

  const json = (method, body) => ({
    method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
  });

  global.mcCampaign = Object.assign(global.mcCampaign || {}, { client, init, ctx, when, json });
})(globalThis);
