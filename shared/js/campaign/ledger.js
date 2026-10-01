// The party's currency: a balance per currency, and the ledger it is the sum
// of. Needs core.js.
//
// Entries are never edited. A mistake is corrected by an opposing entry that
// says so, which is why there is no delete here and none on the server.
// The currency is a free name - credits, gold, dollars - so nothing here knows
// which game it is in.
//
//   mcCampaign.ledger.load()    fetch balances and the ledger
//   mcCampaign.ledger.html()    the view
//   mcCampaign.ledger.state     { balances, ledger }
'use strict';

(function (global) {
  const M = global.mcCampaign;
  const $ = (i) => document.getElementById(i);
  const esc = (v) => M.ctx.ui.esc(v);
  const cid = () => M.ctx.campaignId;

  const S = { balances: [], ledger: [] };

  async function load() {
    const res = await M.ctx.api(`campaigns/${cid()}/currency`);
    S.balances = res.balances; S.ledger = res.ledger;
  }

  function html() {
    return `
  <div class="mc-panel">
    <h3>Party currency <span class="mc-muted mc-small">— the balance is the sum of the ledger</span></h3>
    ${S.balances.length
      ? S.balances.map((b) => `<div class="mc-stat"><span>${esc(b.currency)}</span>
          <b>${Number(b.balance).toLocaleString()}</b></div>`).join('')
      : '<p class="mc-muted">Nothing tracked yet.</p>'}
    <h4 class="mc-subhead">Record income or spending</h4>
    <div class="mc-row">
      <input type="text" id="cur-name" class="mc-input mc-currency-name" placeholder="credits"
        value="${esc(S.balances[0]?.currency || '')}">
      <input type="number" id="cur-delta" class="mc-amount" placeholder="+ or −">
      <input type="text" id="cur-reason" class="mc-input" placeholder="What for?">
      <button class="mc-btn mc-btn-sm" onclick="mcCampaign.ledger.add()">Record</button>
    </div>
    <p class="mc-muted mc-small">Negative to spend. Entries are never edited — a mistake is corrected by
      an opposing entry that says so.</p>
    <p id="cur-msg" class="mc-small"></p>
  </div>
  <div class="mc-panel">
    <h3>Ledger</h3>
    ${S.ledger.length ? S.ledger.map((l, i) => `<div class="mc-item">
      <span><b class="${l.delta < 0 ? 'mc-err' : 'mc-ok'}">${l.delta > 0 ? '+' : ''}${Number(l.delta).toLocaleString()}</b>
        <span class="mc-muted">${esc(l.currency)}</span> ${esc(l.reason || '')}</span>
      <span class="mc-muted mc-small">${esc(l.created_by)} · ${esc((l.created_at || '').slice(0, 16))}
        <button class="mc-btn mc-btn-sm mc-btn-ghost" onclick="mcCampaign.ledger.reverse(${i})"
          aria-label="Record an opposing entry for this one">reverse</button></span>
    </div>`).join('') : '<p class="mc-muted">Nothing recorded yet.</p>'}
  </div>`;
  }

  async function add() {
    const currency = ($('cur-name')?.value || '').trim();
    const typed = String($('cur-delta')?.value ?? '').trim();
    const delta = parseInt(typed, 10);
    if (!currency || !Number.isFinite(delta) || delta === 0) {
      $('cur-msg').textContent = 'Needs a currency and a non-zero amount.';
      return;
    }
    // parseInt reads "12.5" as 12 and says nothing; the ledger holds whole units.
    if (!/^[+-]?\d+$/.test(typed)) {
      $('cur-msg').textContent = 'Whole numbers only.';
      return;
    }
    try {
      await M.ctx.api(`campaigns/${cid()}/currency`, M.json('POST',
        { currency, delta, reason: ($('cur-reason')?.value || '').trim() || null }));
      await M.ctx.reload();
    } catch (err) { $('cur-msg').textContent = 'Failed: ' + err.message; }
  }

  // THE CORRECTION THE LEDGER ASKS FOR, as one press. Entries are never edited
  // or deleted; a mistake is answered by an opposing entry that says so, and
  // that used to mean retyping the currency, the amount and a reason.
  async function reverse(i) {
    const l = S.ledger[i];
    if (!l) return;
    if (!(await M.ctx.ui.modal(`Record ${l.delta > 0 ? '−' : '+'}${Math.abs(l.delta).toLocaleString()} ${l.currency} to reverse this entry?`))) return;
    try {
      await M.ctx.api(`campaigns/${cid()}/currency`, M.json('POST',
        { currency: l.currency, delta: -l.delta, reason: `Reverses: ${l.reason || 'an earlier entry'}`.slice(0, 200) }));
      await M.ctx.reload();
    } catch (err) { $('cur-msg').textContent = 'Failed: ' + err.message; }
  }

  M.ledger = { state: S, load, html, add, reverse };
})(globalThis);
