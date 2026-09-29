// The Table on a campaign page: open it, see its code, close it, and read the
// sessions it saved. Needs core.js. The table itself is apps/table/.
//
// It asks the page's own group's routes (`${base}/table/...`), so Palladium's
// campaign page reaches Palladium's D1 and Marvel's reaches Marvel's, the rule
// every view here keeps (core.js).
//
// A TABLE THAT CLOSED ITSELF IS SAVED HERE. A room nobody has been connected to
// for twelve hours closes itself but keeps its rolls (workers/table-room/), and
// the first time its G.M. opens the campaign afterwards, load() below asks the
// close route to write them to the campaign. So a forgotten table still ends up
// in the campaign, and only the G.M.'s visit can do it, because only the G.M.
// may close a table.
//
// The saved rolls come back already filtered for the reader, by the rule the
// room used live: GM-only rolls to the G.M. alone, a roll To the GM to the G.M.
// and the player who made it.
//
//   mcCampaign.table.load()    status and saved sessions
//   mcCampaign.table.html()    the panel
//   mcCampaign.table.open()    G.M.: open the table
//   mcCampaign.table.close()   G.M.: close it and save its rolls
//   mcCampaign.table.state     { status, sessions, note, off }
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const esc = (v) => M.ctx.ui.esc(v);
  const cid = () => M.ctx.campaignId;
  const TAG = { gm: 'To GM', secret: 'GM only' };
  const REASON = { gm: 'closed by the GM', idle: 'closed itself after 12 idle hours', lost: 'its room was gone; nothing saved' };

  const S = { status: null, sessions: [], note: '', off: false };

  async function load() {
    S.note = '';
    try {
      S.status = await M.ctx.api(`table/status?campaign_id=${cid()}`);
    } catch (err) {
      // 503: this deployment has no room Worker bound. Say nothing loud about
      // it on a campaign page; the panel just does not offer a table.
      S.off = err.status === 503;
      S.status = null;
    }
    if (S.status?.open && S.status.room !== 'open' && S.status.is_gm) {
      try {
        const saved = await M.ctx.api('table/close', M.json('POST', { campaign_id: Number(cid()) }));
        S.note = `The last table ${saved.reason === 'idle' ? 'closed itself while nobody was at it' : 'had closed'}; its ${saved.roll_count} roll${saved.roll_count === 1 ? '' : 's'} are saved below.`;
        S.status = { open: false, is_gm: true };
      } catch (err) { S.note = 'The last table closed, and saving its rolls failed: ' + err.message; }
    }
    try {
      S.sessions = (await M.ctx.api(`table/sessions?campaign_id=${cid()}`)).sessions || [];
    } catch { S.sessions = []; }
  }

  function rollLine(r) {
    const tag = TAG[r.visibility];
    return `<div class="mc-item">
      <span><b>${esc(r.by?.name || '')}</b> ${esc(r.text)}</span>
      ${tag ? `<span class="mc-tag">${esc(tag)}</span>` : ''}
    </div>`;
  }

  function sessionHtml(s) {
    const when = (s.opened_at || '').slice(0, 16);
    return `<details class="mc-inset">
      <summary>${esc(when)} · ${s.feed.length} roll${s.feed.length === 1 ? '' : 's'}
        <span class="mc-muted mc-small">· ${esc(REASON[s.closed_reason] || '')}</span></summary>
      ${s.feed.length ? s.feed.map(rollLine).join('') : '<p class="mc-muted">No rolls you can see.</p>'}
    </details>`;
  }

  function html() {
    if (S.off) return '';
    const st = S.status;
    const gm = !!st?.is_gm;
    const live = st?.open && st.room === 'open';
    const join = live ? `/apps/table/?code=${encodeURIComponent(st.code)}` : '';
    return `
  <div class="mc-panel">
    <h3>The Table <span class="mc-muted mc-small">— one live room for the session: phones, the GM and the TV</span></h3>
    ${live
      ? `<p>A table is open. Code <b class="mc-table-code">${esc(st.code)}</b>
          <a class="mc-btn mc-btn-sm mc-btn-primary" href="${esc(join)}">Go to the table</a>
          ${gm ? '<button type="button" class="mc-btn mc-btn-sm mc-btn-danger" onclick="mcCampaign.table.close()">Close the table</button>' : ''}</p>
         <p class="mc-muted mc-small">Everyone joins at /apps/table/ with the code. A TV joins as the Display.</p>`
      : gm
        ? `<p><button type="button" class="mc-btn mc-btn-primary" onclick="mcCampaign.table.open()">Open the table</button></p>
           <p class="mc-muted mc-small">Gives a four-letter code. Closing it saves every roll here.</p>`
        : '<p class="mc-muted">No table is open. The GM opens one from this page.</p>'}
    ${S.note ? `<p class="mc-small">${esc(S.note)}</p>` : ''}
    ${S.sessions.length ? `<h4 class="mc-subhead">Saved sessions</h4>${S.sessions.map(sessionHtml).join('')}` : ''}
  </div>`;
  }

  async function open() {
    try {
      const r = await M.ctx.api('table/open', M.json('POST', { campaign_id: Number(cid()) }));
      global.location.href = `/apps/table/?code=${encodeURIComponent(r.code)}&as=gm`;
    } catch (err) { M.ctx.ui.toast('Could not open the table: ' + err.message); }
  }

  async function close() {
    if (!(await M.ctx.ui.modal('Close the table? Every roll is saved here and the code stops working.'))) return;
    try {
      await M.ctx.api('table/close', M.json('POST', { campaign_id: Number(cid()) }));
      await M.ctx.reload();
    } catch (err) { M.ctx.ui.toast('Could not close the table: ' + err.message); }
  }

  M.table = { state: S, load, html, open, close };
})(globalThis);
