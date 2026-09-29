// The Table — one page, three screens: the TV (Display), a player's phone, and
// the GM's. Which one this is, and what it may see, is decided by the server:
// the game's join route reads D1 and tells the room the role, and the room
// sends each socket only the rolls it may see (workers/table-room/). This page
// asks for a role; it never decides what it is shown.
//
// Flow: a code (typed, or ?code=) -> /api/table/lookup says which game ->
// that game's table/access says which roles this person may take -> they pick
// one (or ?as= picked it, for a TV bookmark) -> a WebSocket to table/join.
//
// escHtml() is from /shared/js/ui.js. Every string from the server is escaped
// on the way into markup; a roll's text is a player's label and a sheet note.
//
// PICTURES (phase 2). When the GM presses Show to table in Present mode, the
// room sends `show` with the picture's kind and id, and this page loads it from
// the game's table/image route - which answers only while that picture is on
// the table and this person is at it, so the address is worth nothing before
// Show or after Clear. The TV fits it to the screen on black; a phone shows it
// under the roll feed, and a tap opens it full screen to pinch and pan.
'use strict';

const $ = (id) => document.getElementById(id);
const esc = escHtml;

const GAMES = {
  palladium: { base: '/api/character-creator', campaign: (id) => `/apps/campaign/?campaign_id=${id}` },
  marvel: { base: '/api/marvel-heroes', campaign: (id) => `/apps/marvel-heroes/campaign/?c=${id}` },
};
const ROLE_TEXT = {
  gm: ['Run the table', 'Every roll, secret ones included. You can roll GM-only and close the table.'],
  player: ['Sit at the table', 'Roll from the dice box, to everyone or to the GM alone. Your sheet\'s rolls come here too.'],
  display: ['Show it on this screen', 'For the TV: public rolls in large type, no controls. Nothing private ever reaches it.'],
};
const QUICK = ['d20', '2d6', 'd100', 'd6', '3d6'];
const FEED_KEEP = 200;
const TV_ROLLS = 6;

const S = {
  code: '', game: null, access: null, role: null,
  ws: null, you: null, room: null, people: [], feed: [], shown: null,
  closed: false, retry: 0, vis: 'all', ranks: null, rank: 'typical', wake: null,
};

async function getJson(url, opts) {
  const res = await fetch(url, opts);
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(body.error || `Request failed (${res.status})`);
    err.status = res.status;
    throw err;
  }
  return body;
}

function say(text, bad = false) {
  const el = $('status');
  if (!el) return;
  el.textContent = text || '';
  el.classList.toggle('err', !!bad);
}

// ---------- entry: the code ----------

function renderEntry(error = '') {
  document.body.classList.remove('table-tv');
  $('app').innerHTML = `
    <div class="panel table-entry">
      <h2>Join a table</h2>
      <p class="muted">The GM opens the table from the campaign page and reads out its four-letter code.</p>
      <form id="code-form" class="table-code-form">
        <label for="code">Table code</label>
        <input id="code" name="code" type="text" required maxlength="4" minlength="4"
          autocomplete="off" autocapitalize="characters" spellcheck="false" enterkeyhint="go"
          pattern="[A-HJ-NP-Za-hj-np-z2-9]{4}" aria-describedby="code-help" value="${esc(S.code)}">
        <span id="code-help" class="muted small">Four characters. There is no O, 0, I or 1.</span>
        <button type="submit" class="btn btn-primary">Join</button>
      </form>
      <p id="status" class="${error ? 'err' : ''}" role="status" aria-live="polite">${esc(error)}</p>
    </div>`;
  $('code-form').addEventListener('submit', (e) => {
    e.preventDefault();
    start($('code').value);
  });
  $('code').focus();
}

async function start(raw) {
  S.code = String(raw || '').trim().toUpperCase();
  try {
    const found = await getJson(`/api/table/lookup?code=${encodeURIComponent(S.code)}`);
    S.game = found.game;
    S.access = await getJson(`${GAMES[S.game].base}/table/access?code=${encodeURIComponent(S.code)}`);
  } catch (err) {
    return renderEntry(err.message);
  }
  const url = new URL(location.href);
  url.searchParams.set('code', S.code);
  history.replaceState(null, '', url);
  $('sub').textContent = S.access.campaign.name;

  const asked = new URLSearchParams(location.search).get('as');
  if (asked && S.access.roles.includes(asked)) return connect(asked);
  renderChoose();
}

function renderChoose() {
  const a = S.access;
  $('app').innerHTML = `
    <div class="panel">
      <h2>${esc(a.campaign.name)} <span class="table-code-chip">${esc(S.code)}</span></h2>
      <p class="muted">How are you at the table?</p>
      <div class="table-roles">
        ${a.roles.map((r) => `
          <button type="button" class="btn ${r === a.roles[0] ? 'btn-primary' : ''} table-role" data-role="${r}">
            <strong>${esc(ROLE_TEXT[r][0])}</strong>
            <span class="small">${esc(ROLE_TEXT[r][1])}</span>
          </button>`).join('')}
      </div>
    </div>`;
  for (const b of document.querySelectorAll('.table-role')) {
    b.addEventListener('click', () => connect(b.dataset.role));
  }
}

// ---------- the socket ----------

function connect(role) {
  S.role = role;
  S.closed = false;
  if (role === 'display') {
    // A TV bookmark rejoins as the TV without asking again.
    const url = new URL(location.href);
    url.searchParams.set('as', 'display');
    history.replaceState(null, '', url);
  }
  const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
  const url = `${proto}//${location.host}${GAMES[S.game].base}/table/join?code=${encodeURIComponent(S.code)}&as=${role}`;
  const ws = new WebSocket(url);
  S.ws = ws;
  ws.addEventListener('open', () => {
    S.retry = 0;
    ws.send(JSON.stringify({ type: 'hello' }));
    keepAwake();
  });
  ws.addEventListener('message', (e) => {
    let msg;
    try { msg = JSON.parse(e.data); } catch { return; }
    onMessage(msg);
  });
  ws.addEventListener('close', () => {
    if (S.ws !== ws || S.closed) return;
    // A phone that slept, a flaky connection, a Worker redeploy: rejoin with
    // the same code, and the room resends everything on hello.
    S.retry += 1;
    const wait = Math.min(15000, 1000 * 2 ** Math.min(S.retry - 1, 4));
    say(`Connection lost. Rejoining in ${Math.round(wait / 1000)}s…`, true);
    setTimeout(() => { if (!S.closed && S.ws === ws) reconnect(); }, wait);
  });
  if (!$('status')) $('app').innerHTML = '<p id="status" class="muted" role="status" aria-live="polite">Joining…</p>';
}

// Before rejoining, ask again who this person is: the table may have closed,
// or their access may have changed, and a dead code should say so.
async function reconnect() {
  try {
    S.access = await getJson(`${GAMES[S.game].base}/table/access?code=${encodeURIComponent(S.code)}`);
  } catch (err) {
    if (err.status === 404 || err.status === 410) return renderClosed();
    return say(`Still offline: ${err.message}`, true);
  }
  connect(S.role);
}

function send(msg) {
  if (S.ws?.readyState === WebSocket.OPEN) S.ws.send(JSON.stringify(msg));
  else say('Not connected yet. Try again in a moment.', true);
}

function onMessage(msg) {
  if (msg.type === 'state') {
    S.you = msg.you;
    S.room = msg.room;
    S.people = msg.people;
    S.feed = msg.feed;
    S.shown = msg.shown ?? null;
    render();
  } else if (msg.type === 'show') {
    S.shown = msg.shown;
    paintPicture();
  } else if (msg.type === 'clear') {
    S.shown = null;
    paintPicture();
  } else if (msg.type === 'roll') {
    S.feed.push(msg.roll);
    if (S.feed.length > FEED_KEEP) S.feed.shift();
    renderFeed(msg.roll.id);
  } else if (msg.type === 'people') {
    S.people = msg.people;
    renderPeople();
  } else if (msg.type === 'closed') {
    // The GM's own Close already drew the saved count; the room's notice
    // arriving after it must not draw over it.
    if (!S.closed) renderClosed();
    S.closed = true;
  } else if (msg.type === 'error') {
    say(msg.message, true);
  }
}

// A phone at the table should not go dark between turns. Best effort: an
// older browser without the Screen Wake Lock API just sleeps as it always has.
async function keepAwake() {
  if (!('wakeLock' in navigator) || S.wake) return;
  try {
    S.wake = await navigator.wakeLock.request('screen');
    S.wake.addEventListener('release', () => { S.wake = null; });
  } catch { S.wake = null; }
}
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible' && S.ws && !S.closed) keepAwake();
});

// ---------- rendering ----------

function render() {
  if (S.you.role === 'display') return renderDisplay();
  document.body.classList.remove('table-tv');
  const gm = S.you.role === 'gm';
  const seat = S.you.seat;
  const who = gm ? 'GM' : seat ? seat.name : 'not seated yet';
  $('app').innerHTML = `
    <div class="panel table-top">
      <h2>${esc(S.room.campaignName)} <span class="table-code-chip" title="Table code">${esc(S.room.code)}</span></h2>
      <p class="muted">You are <strong>${esc(who)}</strong>${gm ? '' : ` · <a href="${esc(location.pathname)}?code=${esc(S.room.code)}&as=display">use this screen as the TV</a>`}</p>
      <p id="status" class="muted" role="status" aria-live="polite"></p>
    </div>
    ${!gm && !seat ? seatHtml() : ''}
    ${gm || seat ? diceHtml(gm) : ''}
    <div class="panel">
      <h3>Rolls</h3>
      <ol id="feed" class="table-feed" reversed></ol>
    </div>
    <div class="panel table-picture" id="picture" hidden>
      <h3>On the table</h3>
      <button type="button" class="table-picture-open" id="picture-open" aria-label="Open the picture full screen">
        <img id="picture-img" alt="">
      </button>
      <p class="muted small" id="picture-cap"></p>
      <p class="muted small">Tap the picture to see it full screen and pinch to zoom.</p>
    </div>
    <div class="panel">
      <h3>At the table</h3>
      <ul id="people" class="table-people"></ul>
      ${gm ? `<div class="table-close">
        <button type="button" class="btn btn-danger" id="close-table">Close the table</button>
        <span class="muted small">Saves every roll to the campaign, GM-only ones for you alone, and ends the code.</span>
      </div>` : ''}
    </div>`;
  if (!gm && !seat) {
    for (const b of document.querySelectorAll('.table-seat')) {
      b.addEventListener('click', () => send({ type: 'seat', characterId: b.dataset.id }));
    }
  }
  if (gm || seat) wireDice();
  if (gm) $('close-table').addEventListener('click', closeTable);
  $('picture-open').addEventListener('click', openZoom);
  renderFeed();
  renderPeople();
  paintPicture();
}

function seatHtml() {
  return `<div class="panel">
    <h3>Who are you playing?</h3>
    <div class="table-seats">
      ${S.you.characters.map((c) => `<button type="button" class="btn table-seat" data-id="${esc(c.id)}">${esc(c.name)}</button>`).join('')}
    </div>
  </div>`;
}

function diceHtml(gm) {
  const vis = gm ? [['all', 'Everyone'], ['secret', 'GM only']] : [['all', 'Everyone'], ['gm', 'To the GM']];
  if (!vis.some(([v]) => v === S.vis)) S.vis = 'all';
  const marvel = S.room.game === 'marvel';
  return `<div class="panel">
    <h3>Roll</h3>
    <fieldset class="table-vis">
      <legend>Who sees it</legend>
      ${vis.map(([v, label]) => `<label class="table-vis-opt">
        <input type="radio" name="vis" value="${v}" ${S.vis === v ? 'checked' : ''}> ${esc(label)}</label>`).join('')}
    </fieldset>
    <div class="table-quick" role="group" aria-label="Quick rolls">
      ${QUICK.map((q) => `<button type="button" class="btn table-quick-btn" data-expr="${q}">${q}</button>`).join('')}
    </div>
    <form id="dice-form" class="table-dice-form">
      <div class="table-field">
        <label for="expr">Dice</label>
        <input id="expr" name="expr" type="text" required autocomplete="off" spellcheck="false"
          inputmode="text" enterkeyhint="send" placeholder="2d6+3" aria-describedby="expr-help">
      </div>
      <div class="table-field">
        <label for="label">For</label>
        <input id="label" name="label" type="text" maxlength="60" autocomplete="off" placeholder="optional">
      </div>
      <button type="submit" class="btn btn-primary">Roll</button>
      <span id="expr-help" class="muted small table-help">Dice like d20, 2d6+3 or 3d6-1.</span>
    </form>
    ${marvel ? `<form id="feat-form" class="table-dice-form">
      <div class="table-field">
        <label for="rank">FEAT rank</label>
        <select id="rank" name="rank" required>${rankOptions()}</select>
      </div>
      <div class="table-field">
        <label for="cs">Column shift</label>
        <select id="cs" name="cs">${[-3, -2, -1, 0, 1, 2, 3].map((n) => `<option value="${n}" ${n === 0 ? 'selected' : ''}>${n > 0 ? '+' : ''}${n}</option>`).join('')}</select>
      </div>
      <button type="submit" class="btn btn-primary">Roll FEAT</button>
    </form>` : ''}
  </div>`;
}

function wireDice() {
  const label = () => $('label').value;
  for (const r of document.querySelectorAll('input[name="vis"]')) {
    r.addEventListener('change', () => { S.vis = r.value; });
  }
  for (const b of document.querySelectorAll('.table-quick-btn')) {
    b.addEventListener('click', () => send({ type: 'roll', kind: 'dice', expr: b.dataset.expr, label: label(), visibility: S.vis }));
  }
  $('dice-form').addEventListener('submit', (e) => {
    e.preventDefault();
    send({ type: 'roll', kind: 'dice', expr: $('expr').value, label: label(), visibility: S.vis });
  });
  if (S.room.game === 'marvel') {
    if (!S.ranks) loadRanks();
    $('rank').addEventListener('change', (e) => { S.rank = e.target.value; });
    $('feat-form').addEventListener('submit', (e) => {
      e.preventDefault();
      send({ type: 'roll', kind: 'feat', rank: $('rank').value, cs: Number($('cs').value), label: label(), visibility: S.vis });
    });
  }
}

// The rank last picked survives a repaint; Typical until one is picked.
function rankOptions() {
  return (S.ranks || []).map((r) => `<option value="${esc(r.id)}"${r.id === S.rank ? ' selected' : ''}>${esc(r.name)}</option>`).join('');
}

// The Marvel rank ladder, for the FEAT picker: the app's own data file.
async function loadRanks() {
  try {
    const data = await getJson('/apps/marvel-heroes/data/ranks.json');
    S.ranks = data.ranks.filter((r) => r.id !== 'shift-0');
    const sel = $('rank');
    if (sel) sel.innerHTML = rankOptions();
  } catch (err) {
    say(`Could not load the rank ladder: ${err.message}`, true);
  }
}

const VIS_TAG = { gm: 'To GM', secret: 'GM only' };
const time = (at) => new Date(at).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });

function rollHtml(r) {
  const tag = VIS_TAG[r.visibility];
  const toMe = S.you.role === 'gm' && r.visibility === 'gm';
  const mine = r.mine && S.you.role !== 'gm';
  return `<li class="table-roll${mine ? ' mine' : ''}${toMe ? ' to-gm' : ''}" data-id="${r.id}">
    <span class="table-roll-who">${esc(r.by.name)}${r.source === 'sheet' ? ' <span class="muted small">(sheet)</span>' : ''}</span>
    <span class="table-roll-text">${esc(r.text)}</span>
    <span class="table-roll-meta muted small">${tag ? `<span class="tag">${esc(tag)}</span> ` : ''}${toMe ? 'rolled to you · ' : ''}${esc(time(r.at))}</span>
  </li>`;
}

function renderFeed(freshId = null) {
  if (S.you?.role === 'display') return paintTvRolls();
  const list = $('feed');
  if (!list) return;
  const rolls = S.feed.slice().reverse();
  list.innerHTML = rolls.length ? rolls.map(rollHtml).join('') : '<li class="muted">No rolls yet.</li>';
  if (freshId != null) {
    list.querySelector(`[data-id="${freshId}"]`)?.classList.add('fresh');
    const r = S.feed.at(-1);
    if (S.you.role === 'gm' && r?.visibility === 'gm') say(`${r.by.name} rolled to you.`);
  }
}

function renderPeople() {
  const list = $('people');
  if (!list) return;
  list.innerHTML = S.people.map((p) => `<li>${esc(p.name)}</li>`).join('') || '<li class="muted">Nobody yet.</li>';
}

// The TV. Drawn once, then painted in parts: a roll repaints the feed and
// never the picture, which is fetched again every time its <img> is rebuilt
// (the image route is no-store, so a copy cannot outlive Clear).
function renderDisplay() {
  document.body.classList.add('table-tv');
  $('app').innerHTML = `
    <div class="tv-head">
      <div class="tv-campaign">${esc(S.room.campaignName)}</div>
      <div class="tv-join">Join at <strong>${esc(location.host)}/apps/table/</strong> with code <strong class="tv-code">${esc(S.room.code)}</strong></div>
    </div>
    <figure class="tv-picture" id="picture" hidden>
      <img id="picture-img" alt="">
      <figcaption id="picture-cap"></figcaption>
    </figure>
    <ol class="tv-feed" id="tv-feed" reversed></ol>
    <p id="status" class="tv-status" role="status" aria-live="polite"></p>`;
  paintTvRolls();
  paintPicture();
}

function paintTvRolls() {
  const list = $('tv-feed');
  if (!list) return renderDisplay();
  // With a picture up, the rolls keep to one line under it.
  const rolls = S.feed.filter((r) => r.visibility === 'all').slice(S.shown ? -1 : -TV_ROLLS).reverse();
  list.innerHTML = rolls.map((r, i) => `<li class="tv-roll${i === 0 ? ' newest' : ''}">
      <span class="tv-who">${esc(r.by.name)}</span>
      <span class="tv-text">${esc(r.text)}</span>
    </li>`).join('') || (S.shown ? '' : '<li class="tv-roll tv-empty">Waiting for the first roll…</li>');
}

// ---------- the picture on the table ----------

function pictureSrc(s) {
  const q = new URLSearchParams({ code: S.code, kind: s.kind, id: String(s.id), at: String(s.at ?? '') });
  return `${GAMES[S.game].base}/table/image?${q}`;
}

function paintPicture() {
  const box = $('picture');
  if (!box) return;
  const s = S.shown;
  const tv = S.you?.role === 'display';
  document.body.classList.toggle('tv-showing', tv && !!s);
  box.hidden = !s;
  const img = $('picture-img');
  if (!s) {
    img.removeAttribute('src');
    closeZoom();
    if (tv) paintTvRolls();
    return;
  }
  const src = pictureSrc(s);
  // Only a new picture is fetched: the same one stays put.
  if (img.getAttribute('src') !== src) {
    img.onerror = () => { $('picture-cap').textContent = 'The picture could not be loaded.'; };
    img.src = src;
  }
  img.alt = s.caption || 'The picture on the table';
  $('picture-cap').textContent = s.caption || '';
  if (tv) paintTvRolls();
  else if ($('zoom-img') && !$('zoom').hidden) $('zoom-img').src = src;
}

// ---------- full screen, pinch and pan (phones) ----------
//
// Pointer events rather than the browser's own page zoom: the page is not
// zoomed, only the picture, and one finger pans it once it is bigger than the
// screen. A double tap flips between fitted and 2.5x; ✕ or Escape closes.

const Z = { s: 1, x: 0, y: 0, pts: new Map(), from: null, lastTap: 0 };

function zoomEl() {
  let el = $('zoom');
  if (el) return el;
  el = document.createElement('div');
  el.id = 'zoom';
  el.className = 'table-zoom';
  el.hidden = true;
  el.setAttribute('role', 'dialog');
  el.setAttribute('aria-modal', 'true');
  el.setAttribute('aria-label', 'The picture on the table');
  el.innerHTML = '<img id="zoom-img" alt="" draggable="false"><button type="button" class="btn table-zoom-close" id="zoom-close">✕ Close</button>';
  document.body.append(el);
  $('zoom-close').addEventListener('click', closeZoom);
  const img = $('zoom-img');
  img.addEventListener('pointerdown', (e) => {
    img.setPointerCapture(e.pointerId);
    Z.pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
    Z.from = null;
    const now = Date.now();
    if (Z.pts.size === 1 && now - Z.lastTap < 300) zoomTo(Z.s > 1 ? 1 : 2.5, e.clientX, e.clientY);
    Z.lastTap = now;
  });
  img.addEventListener('pointermove', (e) => {
    const was = Z.pts.get(e.pointerId);
    if (!was) return;
    const now = { x: e.clientX, y: e.clientY };
    Z.pts.set(e.pointerId, now);
    if (Z.pts.size >= 2) {
      const [a, b] = [...Z.pts.values()];
      const d = Math.hypot(a.x - b.x, a.y - b.y);
      const m = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
      if (!Z.from) Z.from = { s: Z.s, x: Z.x, y: Z.y, d, m };
      pinch(Z.from, Z.from.s * (d / Z.from.d), m);
    } else if (Z.s > 1) {
      Z.x += now.x - was.x;
      Z.y += now.y - was.y;
      paintZoom();
    }
  });
  const up = (e) => { Z.pts.delete(e.pointerId); Z.from = null; };
  img.addEventListener('pointerup', up);
  img.addEventListener('pointercancel', up);
  el.addEventListener('wheel', (e) => {
    e.preventDefault();
    zoomTo(Z.s * (e.deltaY < 0 ? 1.2 : 1 / 1.2), e.clientX, e.clientY);
  }, { passive: false });
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape' && !el.hidden) closeZoom(); });
  return el;
}

// Scale about a point on screen, so what is under the fingers stays there.
function pinch(from, s, m) {
  const next = Math.min(6, Math.max(1, s));
  const cx = innerWidth / 2;
  const cy = innerHeight / 2;
  const px = (from.m.x - cx - from.x) / from.s;
  const py = (from.m.y - cy - from.y) / from.s;
  Z.s = next;
  Z.x = next === 1 ? 0 : m.x - cx - px * next;
  Z.y = next === 1 ? 0 : m.y - cy - py * next;
  paintZoom();
}

function zoomTo(s, x, y) {
  pinch({ s: Z.s, x: Z.x, y: Z.y, m: { x, y } }, s, { x, y });
}

function paintZoom() {
  $('zoom-img').style.transform = `translate(${Z.x}px, ${Z.y}px) scale(${Z.s})`;
}

function openZoom() {
  if (!S.shown) return;
  const el = zoomEl();
  Object.assign(Z, { s: 1, x: 0, y: 0, from: null });
  Z.pts.clear();
  $('zoom-img').src = pictureSrc(S.shown);
  $('zoom-img').alt = S.shown.caption || 'The picture on the table';
  paintZoom();
  el.hidden = false;
  $('zoom-close').focus();
}

function closeZoom() {
  const el = $('zoom');
  if (!el || el.hidden) return;
  el.hidden = true;
  $('zoom-img').removeAttribute('src');
  $('picture-open')?.focus();
}

async function closeTable() {
  if (!confirm('Close the table? Every roll is saved to the campaign and the code stops working.')) return;
  const btn = $('close-table');
  btn.disabled = true;
  try {
    const r = await getJson(`${GAMES[S.game].base}/table/close`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ campaign_id: S.access.campaign.id }),
    });
    S.closed = true;
    renderClosed(r.roll_count);
  } catch (err) {
    btn.disabled = false;
    say(`Could not close the table: ${err.message}`, true);
  }
}

function renderClosed(saved = null) {
  document.body.classList.remove('table-tv', 'tv-showing');
  S.closed = true;
  S.shown = null;
  closeZoom();
  try { S.ws?.close(); } catch { /* already closed */ }
  S.wake?.release().catch(() => {});
  const back = S.access && S.game ? GAMES[S.game].campaign(S.access.campaign.id) : null;
  $('app').innerHTML = `
    <div class="panel">
      <h2>The table is closed</h2>
      <p>${saved != null ? `${saved} roll${saved === 1 ? '' : 's'} saved to the campaign.` : 'Its rolls are saved to the campaign.'}</p>
      ${back ? `<p><a href="${esc(back)}">Open the campaign</a></p>` : ''}
      <p><a href="/apps/table/">Join another table</a></p>
    </div>`;
}

// ---------- boot ----------

const initial = new URLSearchParams(location.search).get('code');
if (initial) start(initial); else renderEntry();
