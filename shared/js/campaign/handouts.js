// Handouts: what the GM has shown the party - a picture and its caption,
// newest first. Needs core.js.
//
// There is no title and no body here because there is none to have: a setting
// page is the GM's notebook and only the IMAGE is ever revealed (migration 078,
// and setting.js for the GM's side). A player who has seen nothing gets a
// sentence saying so rather than an empty panel, because "nothing yet" and
// "this is broken" look identical otherwise.
//
//   mcCampaign.handouts.load()        fetch what has been revealed
//   mcCampaign.handouts.html(opts)    the view; opts.extra is the page's own
//                                     HTML after it (a game's city maps)
//   mcCampaign.handouts.state         { handouts }
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const esc = (v) => M.ctx.ui.esc(v);
  const cid = () => M.ctx.campaignId;

  const S = { handouts: [] };

  async function load() {
    S.handouts = (await M.ctx.api(`campaigns/${cid()}/handouts`)).handouts || [];
  }

  function html({ extra = '' } = {}) {
    if (!S.handouts.length && extra) return extra;
    if (!S.handouts.length) {
      return `<div class="mc-panel">
      <h3 class="mc-head">Handouts</h3>
      <p class="mc-muted">Nothing yet. What the GM shows the party — a map, a portrait, a page
        from a book — turns up here.</p>
    </div>`;
    }
    return `<div class="mc-panel">
    <h3 class="mc-head">Handouts <span class="mc-muted mc-small">(newest first)</span></h3>
    <ul class="mc-handouts">
      ${S.handouts.map((h) => `<li class="mc-handout">
        <figure class="mc-handout-figure">
          <img src="${M.ctx.base}/campaigns/${cid()}/images/${h.id}"
               alt="${esc(h.caption || 'A handout from the GM')}" loading="lazy">
          ${h.caption ? `<figcaption>${esc(h.caption)}</figcaption>` : ''}
        </figure>
      </li>`).join('')}
    </ul>
  </div>${extra}`;
  }

  M.handouts = { state: S, load, html };
})(globalThis);
