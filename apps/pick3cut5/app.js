// Pick 3 Cut 5 — client.
//
// The client is a RENDERER. It holds no authoritative state: every screen is
// drawn from the last snapshot the server sent, and the only thing it ever
// decides for itself is which pixels to move. Budget arithmetic, forced picks,
// timers and phase transitions all happen server-side, so a player editing
// numbers in devtools changes what their own screen says and nothing else.
//
// Solo mode reuses the same renderer by building a snapshot of the same shape
// locally. That is the whole reason solo was cheap: one set of screens, one
// render path, two sources of truth for it.

const $ = (id) => document.getElementById(id);

const API = '/api/pick3cut5';
const KEEPS = 3;
const CUTS = 5;
const ITEMS = 8;
const SOLO_BEAT_MS = 1200;

let mode = null;           // 'party' | 'solo'
let socket = null;
let snapshot = null;
let myName = '';
let myCode = '';
let reconnectTries = 0;
let timerHandle = null;
let armHandle = null;

// ─── Screens ───────────────────────────────────────────────────────────────

const SCREENS = ['home', 'lobby', 'generating', 'play', 'final'];

function show(screen) {
  for (const s of SCREENS) $(`screen-${s}`).hidden = s !== screen;
}

function banner(message) {
  const el = $('banner');
  if (!message) { el.hidden = true; return; }
  el.textContent = message;
  el.hidden = false;
}

function announce(text) { $('live').textContent = text; }

// ─── Party: socket ─────────────────────────────────────────────────────────

function connect(code, name) {
  myCode = code.toUpperCase();
  myName = name;
  mode = 'party';

  const scheme = location.protocol === 'https:' ? 'wss' : 'ws';
  socket = new WebSocket(`${scheme}://${location.host}${API}/room?code=${encodeURIComponent(myCode)}`);

  socket.addEventListener('open', () => {
    reconnectTries = 0;
    banner('');
    send({ type: 'join', name: myName });
  });

  socket.addEventListener('message', (event) => {
    let msg;
    try { msg = JSON.parse(event.data); } catch { return; }
    handle(msg);
  });

  socket.addEventListener('close', (event) => {
    if (event.code === 4404 || event.code === 4403 || event.code === 4409) return; // told to go away
    if (mode !== 'party') return;
    // Their seat and their board are held server-side, so reconnecting under
    // the same name resumes exactly where they were. Worth trying hard.
    if (reconnectTries < 4) {
      reconnectTries += 1;
      banner(`Connection dropped. Reconnecting (${reconnectTries}/4)…`);
      setTimeout(() => connect(myCode, myName), 1200 * reconnectTries);
    } else {
      banner('Lost the room. Refresh to rejoin with the same name.');
    }
  });
}

function send(payload) {
  if (socket?.readyState === WebSocket.OPEN) socket.send(JSON.stringify(payload));
}

function handle(msg) {
  switch (msg.type) {
    case 'state':
      render(msg);
      break;
    case 'item_revealed':
      $('itemCard').classList.remove('landing');
      void $('itemCard').offsetWidth;          // restart the animation
      $('itemCard').classList.add('landing');
      announce(`Item ${msg.index + 1}: ${msg.item}`);
      break;
    case 'flip':
      announce('Choices revealed.');
      break;
    case 'final':
      announce('Final boards.');
      break;
    case 'error':
      banner(msg.message);
      if (msg.fatal) { mode = null; show('home'); }
      break;
    default:
      break; // pick_progress and summary are already carried by the snapshot
  }
}

// ─── Render ────────────────────────────────────────────────────────────────

function render(s) {
  snapshot = s;
  if (s.error) banner(s.error); else banner('');

  $('roomBadge').hidden = !s.code;
  if (s.code) $('roomBadge').textContent = s.code;

  document.querySelectorAll('.host-only').forEach((el) => { el.hidden = !s.isHost; });
  document.querySelectorAll('.guest-only').forEach((el) => { el.hidden = Boolean(s.isHost); });

  switch (s.phase) {
    case 'lobby':      renderLobby(s); show('lobby'); break;
    case 'generating': renderGenerating(s); show('generating'); break;
    case 'final':      renderFinal(s); show('final'); break;
    default:           renderPlay(s); show('play'); break;
  }
}

function renderLobby(s) {
  $('lobbyCode').textContent = s.code ?? '----';
  $('lobbyPlayers').innerHTML = s.players.map((p) => `
    <div class="player-row ${p.isYou ? 'is-you' : ''} ${p.connected ? '' : 'is-gone'}">
      <span class="player-name">${escHtml(p.name)}</span>
      ${p.isHost ? '<span class="tag tag-host">host</span>' : ''}
      ${p.connected ? '' : '<span class="tag">away</span>'}
      ${s.isHost && !p.isYou ? `<button class="btn-kick" data-kick="${p.id}" aria-label="Remove ${escHtml(p.name)}">×</button>` : ''}
    </div>`).join('');

  $('pickSecs').value = s.timers.pick;
  $('acceptSecs').value = s.timers.accept;
  $('categoryHint').textContent = s.roundsLeft <= 5
    ? `${s.roundsLeft} round${s.roundsLeft === 1 ? '' : 's'} left in this room.`
    : 'Facts get checked against the web before anyone sees them.';
}

function renderGenerating(s) {
  $('loadingLine').textContent = s.progress || 'Working';
}

function renderPlay(s) {
  const me = s.players.find((p) => p.isYou);
  const armed = s.phase === 'picking' && Date.now() >= (s.armAt ?? 0);

  $('itemIndexLabel').textContent = `item ${s.itemIndex + 1}`;
  $('itemText').textContent = s.item ?? '';
  $('itemCount').textContent = `${s.itemIndex + 1} / ${s.itemCount ?? ITEMS}`;

  renderPips('pipsKeep', me?.keepsLeft ?? 0, KEEPS, 'keep');
  renderPips('pipsCut', me?.cutsLeft ?? 0, CUTS, 'cut');

  // Buttons
  const inPick = s.phase === 'revealing' || s.phase === 'picking';
  $('actions').hidden = !inPick;
  $('actions').classList.toggle('locked', Boolean(s.yourPick));

  const forced = s.yourForced;
  $('forcedNote').hidden = !(inPick && forced);
  if (forced) {
    $('forcedNote').textContent = forced === 'cut'
      ? "Your keeps are gone. This one's an auto-cut."
      : "You have to keep the rest. This one's an auto-keep.";
  }

  for (const [id, kind, left] of [['btnKeep', 'keep', me?.keepsLeft], ['btnCut', 'cut', me?.cutsLeft]]) {
    const btn = $(id);
    btn.disabled = !armed || Boolean(s.yourPick) || Boolean(forced) || (left ?? 0) <= 0;
    btn.classList.toggle('chosen', s.yourPick?.choice === kind);
    $(kind === 'keep' ? 'keepLeft' : 'cutLeft').textContent = `${left ?? 0} left`;
  }

  // How many have chosen, never what.
  const showProgress = s.phase === 'picking' && (s.pickProgress?.total ?? 0) > 1;
  $('pickProgress').hidden = !showProgress;
  if (showProgress) {
    $('pickProgress').textContent = `${s.pickProgress.chosen} of ${s.pickProgress.total} locked in`;
  }

  // Flip
  const flipping = s.phase === 'flipping';
  $('flips').hidden = !flipping;
  if (flipping) $('flips').innerHTML = s.flips.map(flipRow).join('');

  // Summary
  const summarising = s.phase === 'summary';
  $('summary').hidden = !summarising;
  if (summarising) renderSummary(s);

  $('hostControls').hidden = !(s.isHost && mode === 'party' && ['picking', 'flipping', 'summary'].includes(s.phase));

  startTimer(s);
  scheduleArm(s);
}

function flipRow(f, i) {
  const auto = f.reason !== 'manual';
  const label = f.reason === 'forced'
    ? (f.choice === 'keep' ? 'auto-keep' : 'auto-cut')
    : f.choice;
  const why = f.reason === 'forced' ? 'out of budget'
    : f.reason === 'timeout' ? 'timed out'
    : f.reason === 'disconnect' ? 'dropped' : '';
  return `
    <div class="flip-row flip-${f.choice} ${auto ? 'flip-auto' : ''}"
         style="animation-delay:${i * 0.16}s">
      <span class="flip-name">${escHtml(f.name)}</span>
      ${why ? `<span class="flip-why">${why}</span>` : ''}
      <span class="flip-choice">${label}</span>
    </div>`;
}

function renderSummary(s) {
  $('summaryBoard').innerHTML = s.players.map((p) => {
    const keeps = p.picks.filter((x) => x && x.choice === 'keep');
    return `
      <div class="summary-row ${p.isYou ? 'is-you' : ''}">
        <div class="summary-head">
          <span class="summary-name">${escHtml(p.name)}${p.isYou ? ' (you)' : ''}</span>
          <span class="summary-budget">
            ${miniPips(p.keepsLeft, KEEPS, 'keep')}
            ${miniPips(p.cutsLeft, CUTS, 'cut')}
          </span>
        </div>
        <div class="summary-keeps">
          ${keeps.length
            ? keeps.map((k) => `<span class="keep-chip">${escHtml(k.item)}</span>`).join('')
            : '<span class="keep-chip empty">nothing kept yet</span>'}
        </div>
      </div>`;
  }).join('');

  const me = s.players.find((p) => p.isYou);
  const waiting = s.players.filter((p) => !p.hasAccepted).length;
  $('btnAccept').hidden = Boolean(me?.hasAccepted);
  $('acceptWaiting').hidden = !me?.hasAccepted;
  $('acceptWaiting').textContent = `Waiting on ${waiting} more.`;
}

function renderFinal(s) {
  $('finalCategory').textContent = s.category;
  $('finalBoards').innerHTML = s.players.map((p) => {
    const keeps = p.picks.filter((x) => x && x.choice === 'keep');
    return `
      <div class="final-board ${p.isYou ? 'is-you' : ''}">
        <div class="final-owner">${escHtml(p.name)}</div>
        ${keeps.length
          ? keeps.map((k) => `<div class="final-item ${k.reason === 'manual' ? '' : 'auto'}">${escHtml(k.item)}</div>`).join('')
          : '<div class="final-empty">kept nothing</div>'}
      </div>`;
  }).join('');

  $('againHint').textContent = s.roundsLeft > 0
    ? `${s.roundsLeft} round${s.roundsLeft === 1 ? '' : 's'} left in this room.`
    : 'This room is out of rounds. Start a new one.';
  $('btnSoloAgain').hidden = mode !== 'solo';
  $('formAgain').hidden = mode !== 'party' || !s.isHost;
  $('finalWaiting').hidden = mode !== 'party' || s.isHost;
}

function renderPips(elId, left, total, kind) {
  const spent = total - left;
  $(elId).innerHTML = Array.from({ length: total }, (_, i) =>
    `<span class="pip ${i < spent ? 'pip-spent' : `pip-${kind}`}"></span>`).join('');
}

function miniPips(left, total, kind) {
  const spent = total - left;
  return `<span class="mini-pips">${Array.from({ length: total }, (_, i) =>
    `<span class="mini-pip ${i < spent ? 'pip-spent' : `pip-${kind}`}"></span>`).join('')}</span>`;
}

// ─── Timers ────────────────────────────────────────────────────────────────

// Visible but not stressful: a bar that drains, no numbers counting down in
// your face, no sound. It turns red at ten seconds and that is the whole
// escalation.
function startTimer(s) {
  clearInterval(timerHandle);
  const bar = $('timerBar');
  if (!s.deadline) { bar.hidden = true; return; }

  const total = (s.phase === 'picking' ? s.timers.pick : s.timers.accept) * 1000;
  bar.hidden = false;

  const tick = () => {
    const left = Math.max(0, s.deadline - Date.now());
    $('timerFill').style.transform = `scaleX(${Math.max(0, left / total)})`;
    bar.classList.toggle('urgent', left < 10_000);
    if (left <= 0) clearInterval(timerHandle);
  };
  tick();
  timerHandle = setInterval(tick, 1000);
}

// The reveal beat. The server decides when buttons arm; this just re-renders
// once the moment passes so they stop being disabled.
function scheduleArm(s) {
  clearTimeout(armHandle);
  const wait = (s.armAt ?? 0) - Date.now();
  if (s.phase === 'picking' && wait > 0) {
    armHandle = setTimeout(() => { if (snapshot) render(snapshot); }, wait + 30);
  }
}

// ─── Solo ──────────────────────────────────────────────────────────────────
//
// Same blind sequential flow, no room, no socket. The list is fetched once and
// held here — unlike party mode, where an unrevealed item never reaches the
// browser at all. That rule exists so nobody can read the list over another
// player's shoulder; in solo there is nobody else, and the only person a
// devtools window spoils it for is the person who opened it.

const solo = {
  items: [], seen: [], category: '',
  index: -1, keepsLeft: KEEPS, cutsLeft: CUTS, picks: [],
  phase: 'lobby', armAt: 0,
};

function soloSnapshot() {
  return {
    code: null,
    phase: solo.phase,
    category: solo.category,
    timers: { pick: 0, accept: 0 },
    players: [{
      id: 'you', name: 'You', isYou: true, isHost: true, connected: true, ready: true,
      keepsLeft: solo.keepsLeft, cutsLeft: solo.cutsLeft,
      picks: solo.picks.slice(0, solo.phase === 'picking' || solo.phase === 'revealing'
        ? solo.index : solo.index + 1),
      hasPicked: Boolean(solo.picks[solo.index]),
      hasAccepted: false,
    }],
    youId: 'you',
    isHost: true,
    itemIndex: solo.index,
    itemCount: ITEMS,
    item: solo.index >= 0 ? solo.items[solo.index] : null,
    armAt: solo.armAt,
    deadline: null,
    progress: solo.progress ?? '',
    error: null,
    roundsLeft: 99,
    pickProgress: { chosen: solo.picks[solo.index] ? 1 : 0, total: 1 },
    yourPick: solo.picks[solo.index] ?? null,
    yourForced: solo.phase === 'picking' ? soloForced() : null,
    flips: solo.phase === 'flipping' || solo.phase === 'summary'
      ? [{ playerId: 'you', name: 'You', ...pickOf(solo.picks[solo.index]) }] : [],
  };
}

function pickOf(p) {
  return { choice: p?.choice ?? 'cut', reason: p?.reason ?? 'manual' };
}

// Same four rules as the server. Duplicated here because solo has no server to
// ask — if these ever diverge, the server's copy in room.js is the real one.
function soloForced() {
  const remaining = ITEMS - solo.index;
  if (solo.keepsLeft === 0) return 'cut';
  if (solo.cutsLeft === 0) return 'keep';
  if (solo.keepsLeft === remaining) return 'keep';
  if (solo.cutsLeft === remaining) return 'cut';
  return null;
}

async function soloStart(category) {
  mode = 'solo';
  solo.phase = 'generating';
  solo.progress = 'Sizing up the category';
  solo.category = category;
  render(soloSnapshot());

  // Party mode gets real progress lines pushed from the Durable Object. Solo
  // is a single fetch and cannot see inside it, so the beats are approximated
  // from the measured pipeline: classify lands around 1s, generation runs to
  // roughly 30s on a category that needs searching, verification to about 70s.
  // A taste category finishes in ~3s and never reaches the later beats at all.
  const beats = [
    [1500, 'Building the list'],
    [33000, 'Checking these are current'],
    [75000, 'Still checking — this one is stubborn'],
  ];
  const timers = beats.map(([at, line]) => setTimeout(() => {
    if (solo.phase !== 'generating') return;
    solo.progress = line;
    render(soloSnapshot());
  }, at));

  try {
    const res = await fetch(`${API}/solo`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ category, exclude: solo.seen }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Could not build a list.');

    solo.items = data.items;
    solo.seen = [...solo.seen, ...data.items];
    solo.index = -1;
    solo.keepsLeft = KEEPS;
    solo.cutsLeft = CUTS;
    solo.picks = [];
    soloReveal();
  } catch (err) {
    solo.phase = 'lobby';
    mode = null;
    show('home');
    banner(err.message);
  } finally {
    timers.forEach(clearTimeout);
  }
}

function soloReveal() {
  solo.index += 1;
  solo.phase = 'picking';
  solo.armAt = Date.now() + SOLO_BEAT_MS;

  // Budget-forced picks are spent the instant the item lands, exactly as the
  // server does it, so the reveal still happens and you still watch yourself
  // get locked into it.
  const forced = soloForced();
  if (forced) soloRecord(forced, 'forced');

  render(soloSnapshot());
  $('itemCard').classList.remove('landing');
  void $('itemCard').offsetWidth;
  $('itemCard').classList.add('landing');
  announce(`Item ${solo.index + 1}: ${solo.items[solo.index]}`);

  if (forced) setTimeout(soloFlip, SOLO_BEAT_MS + 400);
}

function soloRecord(choice, reason) {
  if (choice === 'keep') solo.keepsLeft -= 1; else solo.cutsLeft -= 1;
  solo.picks[solo.index] = { item: solo.items[solo.index], choice, reason };
}

function soloPick(choice) {
  if (solo.phase !== 'picking' || solo.picks[solo.index]) return;
  if (Date.now() < solo.armAt) return;
  if (soloForced()) return;
  soloRecord(choice, 'manual');
  soloFlip();
}

function soloFlip() {
  solo.phase = 'flipping';
  render(soloSnapshot());
  setTimeout(() => {
    solo.phase = 'summary';
    render(soloSnapshot());
  }, 900);
}

function soloAdvance() {
  if (solo.index >= ITEMS - 1) {
    solo.phase = 'final';
    render(soloSnapshot());
    return;
  }
  soloReveal();
}

// ─── Wiring ────────────────────────────────────────────────────────────────

function togglePanel(panel, tile) {
  const opening = panel.hidden;
  for (const p of ['formJoin', 'formHost', 'formSolo']) $(p).hidden = true;
  for (const t of ['btnHost', 'btnJoinToggle', 'btnSoloToggle']) $(t).setAttribute('aria-expanded', 'false');
  panel.hidden = !opening;
  tile.setAttribute('aria-expanded', String(opening));
  if (opening) panel.querySelector('input')?.focus();
}

$('btnHost').addEventListener('click', () => togglePanel($('formHost'), $('btnHost')));
$('btnJoinToggle').addEventListener('click', () => togglePanel($('formJoin'), $('btnJoinToggle')));
$('btnSoloToggle').addEventListener('click', () => togglePanel($('formSolo'), $('btnSoloToggle')));

$('formHost').addEventListener('submit', async (e) => {
  e.preventDefault();
  const name = $('hostName').value.trim();
  if (!name) return banner('Pick a name first.');

  const btn = $('formHost').querySelector('button');
  btn.disabled = true;
  try {
    const res = await fetch(`${API}/room`, { method: 'POST' });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Could not make a room.');
    connect(data.code, name);
  } catch (err) {
    banner(err.message);
  } finally {
    btn.disabled = false;
  }
});

$('formJoin').addEventListener('submit', (e) => {
  e.preventDefault();
  const code = $('joinCode').value.trim().toUpperCase();
  const name = $('joinName').value.trim();
  if (code.length !== 4) return banner('Room codes are four characters.');
  if (!name) return banner('Pick a name first.');
  connect(code, name);
});

$('formSolo').addEventListener('submit', (e) => {
  e.preventDefault();
  const category = $('soloCategory').value.trim();
  if (!category) return banner('Type a category first.');
  soloStart(category);
});

$('formCategory').addEventListener('submit', (e) => {
  e.preventDefault();
  send({ type: 'set_timers', pick: Number($('pickSecs').value), accept: Number($('acceptSecs').value) });
  send({ type: 'start_round', category: $('category').value.trim() });
});

$('formAgain').addEventListener('submit', (e) => {
  e.preventDefault();
  send({ type: 'start_round', category: $('againCategory').value.trim() });
});

$('btnKeep').addEventListener('click', () => (mode === 'solo' ? soloPick('keep') : send({ type: 'submit_pick', choice: 'keep' })));
$('btnCut').addEventListener('click', () => (mode === 'solo' ? soloPick('cut') : send({ type: 'submit_pick', choice: 'cut' })));
$('btnAccept').addEventListener('click', () => (mode === 'solo' ? soloAdvance() : send({ type: 'accept' })));
$('btnForce').addEventListener('click', () => send({ type: 'force_advance' }));

$('btnSoloAgain').addEventListener('click', () => {
  mode = null;
  show('home');
  togglePanel($('formSolo'), $('btnSoloToggle'));
  $('soloCategory').value = '';
});

$('lobbyPlayers').addEventListener('click', (e) => {
  const id = e.target.closest('[data-kick]')?.dataset.kick;
  if (id) send({ type: 'kick', playerId: id });
});

$('btnCopyCode').addEventListener('click', (e) => {
  const link = `${location.origin}${location.pathname}?room=${snapshot?.code ?? ''}`;
  copyWithFeedback(link, e.currentTarget, '✅ copied');
});

// Uppercase as you type — the code is uppercase everywhere else and a lowercase
// echo in the one box you type it into reads like it is being rejected.
$('joinCode').addEventListener('input', (e) => {
  e.target.value = e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '');
});

window.addEventListener('beforeunload', () => { mode = null; });

// A shared join link drops straight into the code box.
const fromLink = new URLSearchParams(location.search).get('room');
if (fromLink) {
  $('joinCode').value = fromLink.toUpperCase().slice(0, 4);
  togglePanel($('formJoin'), $('btnJoinToggle'));
  $('joinName').focus();
}

show('home');
