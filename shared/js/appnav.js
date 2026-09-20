// The app switcher and the context chip, shared by every page of the RPG suite.
//
// The character creator grew into five jobs - building a character, playing
// one, reading the codex, keeping campaign notes, and running a table - and
// every page navigated with its own ad-hoc list of `home-link` anchors. What
// they named was whatever the page that owned them happened to need: the sheet
// offered "codex" and "your characters", the dashboard offered neither, and
// nothing anywhere said the five existed. This is one header for all of them.
//
// P1 OF THE SPLIT, AND DELIBERATELY NO URLS MOVE. The five entries point at
// today's pages. When each app gets its own folder, the hrefs below change and
// nothing else does - which is the point of doing navigation first: the
// boundaries get judged before anything is paid for.
//
// A CLASSIC SCRIPT, not a module, because `app.js` and `codex.js` are modules
// and the other four pages are not. `js/campaign-list.js` is shared the same
// way and for the same reason. escHtml() comes from /shared/js/ui.js, which
// every page already loads first.
'use strict';

(function () {
  // The character and campaign a page is about. The URL is the truth - a link
  // sent to a player must open on THAT character - and storage only remembers
  // where you were, so the codex opened from the hub still knows your table.
  const STORE = 'workshop.rpg.context';

  function readStore() {
    try {
      const v = JSON.parse(localStorage.getItem(STORE) || '{}');
      return v && typeof v === 'object' ? v : {};
    } catch { return {}; }
  }

  function writeStore(ctx) {
    try { localStorage.setItem(STORE, JSON.stringify(ctx)); } catch { /* private mode */ }
  }

  const params = new URLSearchParams(location.search);
  const ctx = readStore();
  // `id` is what sheet.html calls a character and `campaign_id` what the other
  // three call a campaign. A URL that names one overrides what was stored, and
  // a URL that names neither leaves the stored pair standing.
  const urlChar = params.get('id');
  const urlCamp = params.get('campaign_id');
  if (urlChar) { ctx.characterId = urlChar; if (ctx.characterId !== readStore().characterId) ctx.characterName = null; }
  if (urlCamp) { ctx.campaignId = urlCamp; if (ctx.campaignId !== readStore().campaignId) ctx.campaignName = null; }
  if (urlChar || urlCamp) writeStore(ctx);

  const base = '/apps/character-creator/';
  const withCamp = (page) => base + page + (ctx.campaignId ? '?campaign_id=' + encodeURIComponent(ctx.campaignId) : '');

  // The five, in the order the work happens: make a character, play it, look
  // something up, write the table down, run the table.
  function apps() {
    return [
      { id: 'creator', label: 'Creator', href: base,
        hint: 'Build a character' },
      // With no character in hand this opens the roster rather than nothing:
      // the sheet lists your characters when asked for none (sheet.js). It was
      // a disabled entry for one day, which was honest while Play had no
      // landing of its own and is now just a dead end nobody needs.
      { id: 'play', label: 'Play',
        href: ctx.characterId ? base + 'sheet.html?id=' + encodeURIComponent(ctx.characterId)
          : base + 'sheet.html',
        hint: ctx.characterId ? 'Your character sheet' : 'Your characters' },
      { id: 'codex', label: 'Codex', href: base + 'codex.html',
        hint: 'Skills, spells, gear and the rest' },
      { id: 'campaign', label: 'Campaign', href: withCamp('campaign.html'),
        hint: 'Notes, stash and the ledger' },
      { id: 'gm', label: 'GM Tools', href: withCamp('dashboard.html'),
        hint: 'Roster, pools and rolling NPCs' },
    ];
  }

  // A drawn chevron rather than a typographic one. The suite's icons are SVG
  // at one stroke weight, and a glyph in a menu button never matches them.
  const CHEVRON = '<svg class="appnav-chev" viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">'
    + '<path d="M4 6.5 8 10.5 12 6.5" fill="none" stroke="currentColor" stroke-width="1.5"'
    + ' stroke-linecap="round" stroke-linejoin="round"/></svg>';

  function chipText() {
    const who = ctx.characterName || (ctx.characterId ? 'Character ' + ctx.characterId : null);
    const where = ctx.campaignName || null;
    if (who && where) return escHtml(who) + '<span class="appnav-chip-sep"> · </span>' + escHtml(where);
    if (who) return escHtml(who);
    if (where) return escHtml(where);
    return 'No character yet';
  }

  function render(host) {
    const current = host.getAttribute('data-app') || '';
    const list = apps();
    const here = list.find((a) => a.id === current);
    host.innerHTML = `
      <div class="appnav-switch">
        <button type="button" class="appnav-btn" aria-expanded="false" aria-haspopup="true"
                aria-controls="appnav-menu" id="appnav-btn">Switch app${CHEVRON}</button>
        <ul class="appnav-menu" id="appnav-menu" role="menu" aria-labelledby="appnav-btn" hidden>
          ${list.map((a) => {
            const on = a.id === current;
            // A destination that cannot work yet is DISABLED, not missing: a
            // menu that changes shape per page teaches nobody what exists.
            const inner = `<span class="appnav-label">${escHtml(a.label)}</span>`
              + `<span class="appnav-hint">${escHtml(a.hint)}</span>`;
            return `<li role="none">${a.href
              ? `<a role="menuitem" class="appnav-item${on ? ' on' : ''}" href="${a.href}"${on ? ' aria-current="page"' : ''}>${inner}</a>`
              : `<span role="menuitem" class="appnav-item is-disabled" aria-disabled="true">${inner}</span>`}</li>`;
          }).join('')}
        </ul>
      </div>
      <a class="appnav-chip" href="${base}" title="Change character or campaign">${chipText()}</a>
      <a class="home-link appnav-out" href="/">← workshop</a>`;
    if (here) host.setAttribute('data-current', here.id);

    const btn = host.querySelector('#appnav-btn');
    const menu = host.querySelector('#appnav-menu');
    const close = () => { menu.hidden = true; btn.setAttribute('aria-expanded', 'false'); };
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      const open = menu.hidden;
      menu.hidden = !open;
      btn.setAttribute('aria-expanded', String(open));
      if (open) menu.querySelector('.appnav-item:not(.is-disabled)')?.focus();
    });
    // Escape closes from anywhere inside, and a click outside closes too -
    // both are what a menu button owes a keyboard and a thumb.
    host.addEventListener('keydown', (e) => { if (e.key === 'Escape') { close(); btn.focus(); } });
    document.addEventListener('click', (e) => { if (!host.contains(e.target)) close(); });
  }

  // What a page calls once it knows what it is showing. The ids come from the
  // URL above; the NAMES only exist after the page has loaded its row, so the
  // chip renders with what it has and improves when the data lands.
  window.appnav = {
    setContext(next) {
      if (!next) return;
      const hadChar = ctx.characterId;
      const hadCamp = ctx.campaignId;
      if (next.characterId != null) ctx.characterId = String(next.characterId);
      if (next.campaignId != null) ctx.campaignId = String(next.campaignId);
      if (next.characterName) ctx.characterName = String(next.characterName);
      if (next.campaignName) ctx.campaignName = String(next.campaignName);
      writeStore(ctx);
      const host = document.querySelector('[data-appnav]');
      if (!host) return;
      // An ID arriving late is the common case, not the exception: the sheet is
      // opened with ?id= alone and only learns its CAMPAIGN once the character
      // has loaded. Re-render when either id moves, or Campaign and GM Tools
      // keep the hrefs they were built with - which is how they lost the
      // campaign they were standing in.
      if (hadChar !== ctx.characterId || hadCamp !== ctx.campaignId) { render(host); return; }
      const chip = host.querySelector('.appnav-chip');
      if (chip) chip.innerHTML = chipText();
    },
    // Leaving a character or a campaign behind should not leave its name in the
    // chip on the next page. Callers: none yet; the sheet's delete path is the
    // first that will want it.
    clear(what) {
      if (what === 'character' || !what) { ctx.characterId = null; ctx.characterName = null; }
      if (what === 'campaign' || !what) { ctx.campaignId = null; ctx.campaignName = null; }
      writeStore(ctx);
      const host = document.querySelector('[data-appnav]');
      if (host) render(host);
    },
    context: () => ({ ...ctx }),
  };

  const host = document.querySelector('[data-appnav]');
  if (host) render(host);
})();
