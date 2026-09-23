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
      return '<p class="muted small">No campaigns yet. Create one below to run it, or create a character to join one.</p>'
        + this.createHtml();
    }
    return this.rowsHtml(list, shortDate) + this.createHtml();
  },

  // "Create a campaign", with no character. Until this the only way to make one
  // was the wizard's "New campaign name" box, so every campaign was born with a
  // character in it and a G.M. who only wanted to run a table had to roll one
  // first. The G.M. is campaigns.gm_email, not a characters row, so nothing
  // below needs a character: pick() keeps a campaign the caller runs, and
  // campaignAccess() counts the G.M. as a member.
  //
  // A <details> rather than a modal: it opens in place, needs no state, and
  // works the same on both pages that show this list.
  createHtml() {
    const systems = [['palladium-fantasy', 'Palladium Fantasy'], ['rifts', 'Rifts'],
      ['nightbane', 'Nightbane'], ['heroes-unlimited', 'Heroes Unlimited']];
    return `<details class="camp-create" style="margin-top:12px">
      <summary class="btn btn-sm btn-primary">+ Create a campaign</summary>
      <form class="panel-inset" style="margin-top:10px" onsubmit="return campaignList.create(this)">
        <div class="rowline" style="flex-wrap:wrap">
          <label class="small">Name <input type="text" name="name" class="picker-input" required maxlength="120"></label>
          <label class="small">Game <select name="system">${systems.map(([v, l]) =>
            `<option value="${v}">${l}</option>`).join('')}</select></label>
        </div>
        <label class="small" style="display:block;margin-top:8px">Description <span class="muted">(optional)</span>
          <textarea name="description" rows="2" style="width:100%"></textarea></label>
        <label class="small" style="display:block;margin-top:8px"><input type="checkbox" name="open" checked>
          Open to anyone — anyone on the site may join by creating a character in it</label>
        <div class="rowline" style="margin-top:8px">
          <button type="submit" class="btn btn-sm btn-primary">Create</button>
          <span class="small camp-create-msg"></span>
        </div>
      </form>
    </details>`;
  },

  // Creates it and goes straight to its page - the G.M.'s next move is there.
  // Returns false so the form never submits the ordinary way.
  create(form) {
    const msg = form.querySelector('.camp-create-msg');
    const btn = form.querySelector('button[type=submit]');
    const body = {
      name: form.elements.name.value.trim(),
      system: form.elements.system.value,
      description: form.elements.description.value.trim(),
      open: form.elements.open.checked,
    };
    if (!body.name) { msg.className = 'small err camp-create-msg'; msg.textContent = 'A name is required.'; return false; }
    btn.disabled = true;
    msg.className = 'small muted camp-create-msg'; msg.textContent = 'Creating…';
    api('campaigns', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
      .then((res) => { location.href = `/apps/campaign/?campaign_id=${res.campaign.id}`; })
      .catch((err) => {
        btn.disabled = false;
        msg.className = 'small err camp-create-msg'; msg.textContent = 'Could not create it: ' + err.message;
      });
    return false;
  },

  rowsHtml(list, shortDate) {
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
          <a href="/apps/gm-tools/?campaign_id=${c.id}"><b>🗺 ${escHtml(c.name)}</b></a>
          <span class="muted small">${escHtml(c.system)} · ${escHtml(bits.join(' · '))}</span>
        </span>
        <span class="home-acts"><a class="btn btn-sm" href="/apps/campaign/?campaign_id=${c.id}">Notes</a></span>
      </li>`;
    }).join('')}</ul>`;
  },
};
