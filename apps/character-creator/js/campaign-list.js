// The signed-in person's campaigns: the ones they run, and the ones a character
// of theirs is in (UI-AUDIT F39).
//
// Shared by the home view and by the dashboard and campaign pages opened with
// no campaign_id, which used to end on an error. Before this a player was never
// shown their campaigns anywhere - the wizard listed only the ones a G.M. ran -
// so the dashboard, the stash, the ledger and Ask were reachable only by URL.
//
// A classic script so all three pages can load it: app.js is a module, the
// other two are not. escHtml() comes from /shared/js/ui.js, api() from js/api.js.
'use strict';

window.campaignList = {
  // campaigns: rows from GET /campaigns. mine: the caller's own characters.
  // Membership is derived from the characters rather than asked for, because
  // having a character in a campaign is what membership IS here.
  pick(campaigns, mine, email) {
    const held = new Map();
    for (const c of mine || []) held.set(c.campaign_id, (held.get(c.campaign_id) || 0) + 1);
    return (campaigns || [])
      .filter((c) => (email && c.gm_email === email) || held.has(c.id))
      .map((c) => ({ ...c, is_gm: !!email && c.gm_email === email, mine: held.get(c.id) || 0 }));
  },

  async load() {
    const [camps, chars, me] = await Promise.all([
      api('campaigns'),
      api('characters?mine=1'),
      api('me').catch(() => ({})),
    ]);
    return this.pick(camps.campaigns, chars.characters, me.email ?? null);
  },

  // A line per campaign, for the reason UI-AUDIT F9 gave the old list: run
  // together, two campaigns of the same name are one string. shortDate is
  // optional - the home view passes the wizard's, the other pages have none.
  html(list, shortDate) {
    if (!list.length) {
      return '<p class="muted small">No campaigns yet. Creating a character puts you in one.</p>';
    }
    return `<ul class="home-list">${list.map((c) => {
      const role = c.is_gm ? 'you are the GM'
        : `${c.mine} of your character${c.mine === 1 ? '' : 's'}`;
      const n = c.character_count;
      const bits = [
        role,
        n == null ? null : `${n} character${n === 1 ? '' : 's'} in all`,
        shortDate ? shortDate(c.created_at) : null,
      ].filter(Boolean);
      return `<li class="home-row">
        <span class="home-what">
          <a href="dashboard.html?campaign_id=${c.id}"><b>🗺 ${escHtml(c.name)}</b></a>
          <span class="muted small">${escHtml(c.system)} · ${escHtml(bits.join(' · '))}</span>
        </span>
        <span class="home-acts"><a class="btn btn-sm" href="campaign.html?campaign_id=${c.id}">Notes</a></span>
      </li>`;
    }).join('')}</ul>`;
  },
};
