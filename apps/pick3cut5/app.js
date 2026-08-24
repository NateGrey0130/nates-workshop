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
    case 'item_replaced':
      announce(`${msg.by} called out ${msg.rejected}. Swapping it.`);
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

  // Flagging. Quiet by default — it only matters to someone who already knows
  // the item is wrong, so it must never pull attention from Keep and Cut.
  const flagVisible = s.phase === 'revealing' || s.phase === 'picking';
  $('btnFlag').hidden = !flagVisible;
  if (flagVisible) {
    $('btnFlag').disabled = !s.canFlag;
    $('btnFlag').textContent = s.spareItems === 0
      ? 'no spare items left'
      : s.canFlag
        ? `🚩 That's wrong — swap it (${s.swapsLeft} left)`
        : "🚩 you've called this one";
  }

  $('calloutNote').hidden = !(flagVisible && s.lastFlag);
  if (s.lastFlag) {
    $('calloutNote').innerHTML =
      `${escHtml(s.lastFlag.by)} called out <span class="callout-item">${escHtml(s.lastFlag.rejected)}</span> — swapped`;
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

  renderPrefetchStatus(
    mode === 'solo' ? $('soloPrefetchStatus') : $('prefetchStatus'),
    s.prefetch,
    (mode === 'solo' ? $('soloAgainCategory') : $('againCategory')).value,
    mode === 'solo' || s.isHost
  );

  const swaps = s.swapLog ?? [];
  $('swapLog').hidden = swaps.length === 0;
  if (swaps.length) {
    $('swapLog').innerHTML = swaps
      .map((x) => `<b>${escHtml(x.by)}</b> called out <s>${escHtml(x.rejected)}</s> at item ${x.item}`)
      .join('<br>');
  }

  $('againHint').textContent = s.roundsLeft > 0
    ? `${s.roundsLeft} round${s.roundsLeft === 1 ? '' : 's'} left in this room.`
    : 'This room is out of rounds. Start a new one.';
  $('formSoloAgain').hidden = mode !== 'solo';
  $('formAgain').hidden = mode !== 'party' || !s.isHost;
  $('finalWaiting').hidden = mode !== 'party' || s.isHost;
}

/**
 * Shared by both final screens. Only shown when what the prefetch holds is
 * what the player has actually typed — a status line about some category they
 * have since replaced would be worse than no status line.
 */
function renderPrefetchStatus(el, pf, typedValue, allowed) {
  const typed = typedValue.trim().toLowerCase();
  const matches = pf && pf.category && pf.category.toLowerCase() === typed;
  el.className = 'prefetch-status';

  if (!allowed || !matches || pf.status === 'idle') { el.hidden = true; return; }
  el.hidden = false;

  if (pf.status === 'running') {
    el.classList.add('working');
    el.innerHTML = '<span class="dot"></span>building this list now';
  } else if (pf.status === 'ready') {
    el.classList.add('ready');
    el.innerHTML = '<span class="dot"></span>list ready — starts instantly';
  } else {
    el.innerHTML = '<span class="dot"></span>could not build it early; Go again will retry';
  }
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

const MAX_SWAPS = 3;

// Speculative generations per solo session. Lower than the party room's five
// because solo goes through the PUBLIC endpoint, which is rate limited to 8
// per minute per IP — and a household on one wifi shares that budget. Burning
// it on lists nobody asked for would make the button the player did press
// fail, which is a worse trade than a wait.
const MAX_SOLO_PREFETCH = 3;

const solo = {
  items: [], reserve: [], seen: [], category: '',
  index: -1, keepsLeft: KEEPS, cutsLeft: CUTS, picks: [],
  phase: 'lobby', armAt: 0,
  replacements: 0, flaggedThisItem: false, lastFlag: null, swapLog: [],
  prefetch: { key: '', category: '', status: 'idle', items: [], reserve: [] },
  prefetchCount: 0,
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
    canFlag: (solo.phase === 'picking' || solo.phase === 'revealing')
      && !solo.flaggedThisItem && solo.replacements < MAX_SWAPS && solo.reserve.length > 0,
    swapsLeft: MAX_SWAPS - solo.replacements,
    spareItems: solo.reserve.length,
    lastFlag: solo.lastFlag,
    swapLog: solo.swapLog,
    // Status and category only, matching the shape the server sends. The items
    // genuinely are here in solo — there is nobody to hide them from — but the
    // renderer is shared, so the shape has to be.
    prefetch: { status: solo.prefetch.status, category: solo.prefetch.category },
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

// One call, so the list is either fetched or prefetched — this is the half
// that runs either way. The mirror of beginRound() on the server.
function soloBeginRound(category, items, reserve) {
  mode = 'solo';
  solo.category = category;
  solo.items = items;
  solo.reserve = reserve ?? [];
  // Only the eight in play count as seen. A spare that never gets swapped in
  // was never shown, so excluding it from a replay would thin the category
  // for nothing — soloFlag() adds one the moment it is dealt.
  solo.seen = [...solo.seen, ...items];
  solo.index = -1;
  solo.keepsLeft = KEEPS;
  solo.cutsLeft = CUTS;
  solo.picks = [];
  solo.replacements = 0;
  solo.progress = '';
  solo.prefetch = { key: '', category: '', status: 'idle', items: [], reserve: [] };
  solo.swapLog = [];
  soloReveal();
}

/**
 * Build the next solo list while the final board is still up.
 *
 * Same idea as the party prefetch and deliberately tighter, because this goes
 * through the public endpoint rather than a room's Durable Object. Every path
 * fails silently: a prefetch nobody uses should never surface an error, and
 * pressing Go again always works, just at full speed.
 */
async function soloPrefetch(category, verify) {
  const key = category.toLowerCase() + (verify ? '|checked' : '');
  if (solo.prefetch.status === 'running') return;              // one at a time
  if (solo.prefetch.key === key && solo.prefetch.status !== 'idle') return;
  if (solo.prefetchCount >= MAX_SOLO_PREFETCH) return;

  solo.prefetchCount += 1;
  solo.prefetch = { key, category, status: 'running', items: [], reserve: [], verify };
  if (solo.phase === 'final') render(soloSnapshot());

  try {
    const res = await fetch(`${API}/solo`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ category, exclude: solo.seen, verify }),
    });
    const data = await res.json();
    // The player may have retyped, or started a round, while this was in
    // flight. Landing a stale list would be worse than landing nothing.
    if (solo.prefetch.key !== key) return;
    if (!res.ok) throw new Error(data.error || '');
    solo.prefetch = { key, category, status: 'ready', items: data.items, reserve: data.reserve ?? [], verify };
  } catch {
    if (solo.prefetch.key !== key) return;
    solo.prefetch = { key, category, status: 'failed', items: [], reserve: [], verify };
  }
  if (solo.phase === 'final') render(soloSnapshot());
}

async function soloStart(category, verify = false) {
  // Already built while the final board was up. Straight in, no second call.
  // The key carries the toggle, so a list built WITHOUT the check can never
  // satisfy a request that asked for it.
  const key = category.toLowerCase() + (verify ? '|checked' : '');
  if (solo.prefetch.status === 'ready' && solo.prefetch.key === key) {
    soloBeginRound(solo.prefetch.category, solo.prefetch.items, solo.prefetch.reserve);
    return;
  }

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
      body: JSON.stringify({ category, exclude: solo.seen, verify }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Could not build a list.');

    soloBeginRound(category, data.items, data.reserve);
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
  solo.flaggedThisItem = false;
  solo.lastFlag = null;
  soloShow();
}

/**
 * Puts the current item on screen. Split from soloReveal so a swapped item can
 * be shown again at the SAME index — the mirror of revealCurrent() on the
 * server, and it has to stay a mirror.
 */
function soloShow() {
  clearTimeout(solo.summaryTimer);
  // Cancel any auto-flip left over from a previous showing of this index.
  //
  // A budget-forced item schedules its own flip on the beat. Swapping that item
  // used to leave the old timer running, so the replacement was flipped about
  // a tenth of a second after it appeared — correct budget, stolen reveal. The
  // server never had this bug because its single alarm is re-armed rather than
  // stacked, which is exactly the divergence this function exists to prevent.
  clearTimeout(solo.flipTimer);

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

  if (forced) solo.flipTimer = setTimeout(soloFlip, SOLO_BEAT_MS + 400);
}

function soloRecord(choice, reason) {
  if (choice === 'keep') solo.keepsLeft -= 1; else solo.cutsLeft -= 1;
  solo.picks[solo.index] = { item: solo.items[solo.index], choice, reason };
}

/**
 * Solo's "that one's wrong". Same rewind as the server: refund whatever was
 * already recorded against this item — including a budget-forced pick taken at
 * reveal — swap in a spare, and show the same index again.
 */
function soloFlag() {
  if (solo.phase !== 'picking' && solo.phase !== 'revealing') return;
  if (solo.flaggedThisItem) return;
  if (solo.replacements >= MAX_SWAPS) return banner(`That's ${MAX_SWAPS} swaps — play the rest as dealt.`);
  if (!solo.reserve.length) return banner('No spare items left for this category.');

  const rejected = solo.items[solo.index];
  const prior = solo.picks[solo.index];
  if (prior) {
    if (prior.choice === 'keep') solo.keepsLeft += 1; else solo.cutsLeft += 1;
    delete solo.picks[solo.index];
  }

  solo.items[solo.index] = solo.reserve.shift();
  solo.seen.push(solo.items[solo.index]);
  solo.replacements += 1;
  solo.flaggedThisItem = true;
  solo.lastFlag = { by: 'You', rejected };
  solo.swapLog.push({ by: 'You', rejected, item: solo.index + 1 });
  soloShow();
}

function soloPick(choice) {
  if (solo.phase !== 'picking' || solo.picks[solo.index]) return;
  if (Date.now() < solo.armAt) return;
  if (soloForced()) return;
  soloRecord(choice, 'manual');
  soloFlip();
}

function soloFlip() {
  clearTimeout(solo.flipTimer);
  clearTimeout(solo.summaryTimer);
  solo.phase = 'flipping';
  render(soloSnapshot());
  solo.summaryTimer = setTimeout(() => {
    if (solo.phase !== 'flipping') return;
    solo.phase = 'summary';
    render(soloSnapshot());
  }, 900);
}

function soloAdvance() {
  // Only from the summary screen.
  //
  // Without this guard an advance from any other phase raced the pending flip
  // timers: pressing Next during item eight's flip set the phase to 'final',
  // and the still-scheduled timer then dragged it BACK to 'flipping', leaving
  // the round stuck one screen short of the board it had just finished
  // earning. Both timers are cleared here as well as guarded, because a
  // correct phase with a live timer behind it is the same bug waiting.
  if (solo.phase !== 'summary') return;
  clearTimeout(solo.flipTimer);
  clearTimeout(solo.summaryTimer);

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
  soloStart(category, $('verifySolo').checked);
});

$('formCategory').addEventListener('submit', (e) => {
  e.preventDefault();
  send({ type: 'set_timers', pick: Number($('pickSecs').value), accept: Number($('acceptSecs').value) });
  send({ type: 'start_round', category: $('category').value.trim(), verify: $('verifyLobby').checked });
});

$('formAgain').addEventListener('submit', (e) => {
  e.preventDefault();
  send({ type: 'start_round', category: $('againCategory').value.trim(), verify: $('verifyAgain').checked });
});

// Ask the server to build the next list while the final screen is still up.
//
// Debounced on a long-ish pause rather than fired per keystroke: each of these
// is a real three-call generation, and "current NBA point guards" typed at
// speed would otherwise kick off several. The server caps this independently —
// this delay is politeness, not the guardrail.
let prefetchTimer = null;
let lastPrefetched = '';

function armPrefetch(inputId, fire) {
  $(inputId).addEventListener('input', () => {
    clearTimeout(prefetchTimer);
    const category = $(inputId).value.trim();
    if (category.length < 4 || category === lastPrefetched) return;
    prefetchTimer = setTimeout(() => {
      lastPrefetched = category;
      fire(category);
    }, 1500);
  });
}

armPrefetch('againCategory', (category) => {
  if (mode === 'party') send({ type: 'prefetch', category, verify: $('verifyAgain').checked });
});
armPrefetch('soloAgainCategory', (category) => {
  if (mode === 'solo') soloPrefetch(category, $('verifySoloAgain').checked);
});

$('btnKeep').addEventListener('click', () => (mode === 'solo' ? soloPick('keep') : send({ type: 'submit_pick', choice: 'keep' })));
$('btnCut').addEventListener('click', () => (mode === 'solo' ? soloPick('cut') : send({ type: 'submit_pick', choice: 'cut' })));
$('btnAccept').addEventListener('click', () => (mode === 'solo' ? soloAdvance() : send({ type: 'accept' })));
$('btnForce').addEventListener('click', () => send({ type: 'force_advance' }));
$('btnFlag').addEventListener('click', () => (mode === 'solo' ? soloFlag() : send({ type: 'flag_item' })));

$('formSoloAgain').addEventListener('submit', (e) => {
  e.preventDefault();
  const category = $('soloAgainCategory').value.trim();
  if (!category) return banner('Type a category first.');
  soloStart(category, $('verifySoloAgain').checked);
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
