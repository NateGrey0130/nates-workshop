// ═══════════════════════════════════════════════════════════════════════════
// Pick 3 Cut 5 — the room Durable Object
//
// One instance per room. The room code IS the DO name, so there is no lookup
// table anywhere: idFromName("QK4T") is the room.
//
// ── MESSAGE CONTRACT ───────────────────────────────────────────────────────
//
// Client → server (JSON, `type` discriminates):
//   { type: 'join',          name: string }
//   { type: 'ready',         ready: boolean }
//   { type: 'start_round',   category: string }            host only
//   { type: 'submit_pick',   choice: 'keep' | 'cut' }
//   { type: 'flag_item' }                            any player, before the flip
//   { type: 'accept' }
//   { type: 'force_advance' }                              host only
//   { type: 'set_timers',    pick: number, accept: number } host only, lobby
//   { type: 'kick',          playerId: string }            host only
//   { type: 'leave' }
//
// Server → client:
//   { type: 'state',         ...snapshot }   every change, always
//   { type: 'item_revealed', index, item }   animation cue
//   { type: 'item_replaced', by, rejected }  someone called an item out
//   { type: 'pick_progress', chosen, total } how many, NEVER what
//   { type: 'flip',          flips: [...] }  animation cue
//   { type: 'summary' }                      animation cue
//   { type: 'final' }                        animation cue
//   { type: 'error',         message }
//
// `state` is a FULL SNAPSHOT on every change rather than a delta. Rooms hold
// at most twelve people and a snapshot is under 2KB, so the bandwidth is free
// and it removes an entire class of desync bug: there is no sequence of missed
// deltas that can leave a client showing a board the server does not have.
// Every other server message is an animation cue carrying no authoritative
// data - drop them all and the game is still correct, just less pretty.
//
// The client holds NO authoritative state. All budget math happens here; the
// client's copy of keeps_left / cuts_left is for display only, and a client
// that lies about it changes nothing.
//
// ── HIDDEN INFORMATION ─────────────────────────────────────────────────────
//
// `game.items` never leaves this file. Snapshots carry items[itemIndex] and
// the items already played - never the tail. This is the single constraint the
// whole game rests on: anyone with devtools open would otherwise read the
// remaining list and know exactly when to spend their last keep.
//
// ── STORAGE ────────────────────────────────────────────────────────────────
//
// State lives in ctx.storage, not in an instance field, because hibernation
// evicts instance memory while leaving the sockets connected - an in-memory
// board would silently reset the first time a room sat idle for a minute.
// This is the DO's own storage, it is not shared with anything, and the alarm
// deleteAll()s it when the room dies. No D1, no KV, no R2.
// ═══════════════════════════════════════════════════════════════════════════

import { DurableObject } from 'cloudflare:workers';
import {
  ITEMS_PER_ROUND, runPipeline, validateCategory, normalize,
  GenerationError, AnthropicError,
} from './generate.js';

const MAX_PLAYERS = 12;
const MAX_ROUNDS = 30;
const MAX_REPLAYS_PER_CATEGORY = 3;

// In-round replacements. Capped because the flag is a correction, not a
// re-roll: without a ceiling a table that dislikes an item can simply keep
// flagging until it gets one it likes, which is a different game.
const MAX_REPLACEMENTS_PER_ROUND = 3;
const GENERATION_COOLDOWN_MS = 20_000;

// MEASURED, not guessed. A taste category ("worst pizza toppings") completes in
// about 3s: classify 0.8s, generate 2.2s, no search, no verification. A fact
// category with a currency constraint ("currently active NBA point guards")
// took 70s: classify 1.1s, generate 31s, verify 38s, both searching the web.
// The classifier gate is the entire difference between those two numbers.
//
// A replay asks for up to 30 candidates instead of 12 and verifies more names,
// so it runs longer again. This ceiling only exists to unstick a room whose
// generation died silently — it is not a target, and setting it near the
// measured time would fire on ordinary rounds.
const GENERATION_TIMEOUT_MS = 240_000;
const REVEAL_BEAT_MS = 1_200;
const DESTRUCT_AFTER_MS = 5 * 60_000;
const DEFAULT_PICK_SECONDS = 60;
const DEFAULT_ACCEPT_SECONDS = 30;

const KEEPS = 3;
const CUTS = 5;

function freshGame(code) {
  return {
    code,
    phase: 'lobby',
    hostId: null,
    players: {},
    timers: { pick: DEFAULT_PICK_SECONDS, accept: DEFAULT_ACCEPT_SECONDS },
    items: [],
    // Spare verified items, held back for in-round replacement. Like `items`,
    // this NEVER reaches a client - a reserve visible in devtools would leak
    // the rest of the category just as surely as the main list would.
    reserve: [],
    replacements: 0,
    flaggedBy: [],
    lastFlag: null,
    itemIndex: -1,
    armAt: 0,
    currentPicks: {},
    accepts: [],
    flips: [],
    category: '',
    normCategory: '',
    used: {},
    verified: {},
    replays: {},
    roundsPlayed: 0,
    lastGenerationAt: 0,
    progress: '',
    error: null,
    deadline: null,
    deadlinePurpose: null,
    destructAt: null,
  };
}

export class Room extends DurableObject {
  constructor(ctx, env) {
    super(ctx, env);
    this.ctx = ctx;
    this.env = env;
    // blockConcurrencyWhile only gates THIS object's startup, and it is the
    // documented way to make sure no message is handled against a half-loaded
    // board after a hibernation wake.
    ctx.blockConcurrencyWhile(async () => {
      this.game = (await ctx.storage.get('game')) ?? null;
    });
  }

  async save() {
    await this.ctx.storage.put('game', this.game);
  }

  // ─── HTTP surface (only ever reached through the Worker in index.js) ─────

  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === '/occupied') {
      return Response.json({ occupied: this.game !== null });
    }

    if (url.pathname === '/create') {
      const code = url.searchParams.get('code') ?? '????';
      if (this.game) return Response.json({ error: 'taken' }, { status: 409 });
      this.game = freshGame(code);
      await this.save();
      return Response.json({ ok: true, code });
    }

    if (url.pathname !== '/ws') return new Response('Not found', { status: 404 });
    if (request.headers.get('Upgrade') !== 'websocket') {
      return new Response('Expected WebSocket', { status: 426 });
    }
    if (!this.game) {
      // Closing with a policy code rather than returning an HTTP error: the
      // browser gets a clean "no such room" it can show, instead of a failed
      // upgrade it can only report as a network error.
      const [c, s] = Object.values(new WebSocketPair());
      s.accept();
      s.send(JSON.stringify({ type: 'error', message: 'No room with that code. It may have expired.', fatal: true }));
      s.close(4404, 'no such room');
      return new Response(null, { status: 101, webSocket: c });
    }

    const [client, server] = Object.values(new WebSocketPair());
    // acceptWebSocket, not server.accept() - this is what lets the object
    // hibernate while eight phones sit on the lobby screen.
    this.ctx.acceptWebSocket(server);
    return new Response(null, { status: 101, webSocket: client });
  }

  // ─── WebSocket handlers ─────────────────────────────────────────────────

  async webSocketMessage(ws, raw) {
    let msg;
    try { msg = JSON.parse(raw); } catch { return this.sendError(ws, 'Malformed message'); }
    if (!this.game) return this.sendError(ws, 'This room has closed.', true);

    const att = ws.deserializeAttachment() ?? {};
    const player = att.playerId ? this.game.players[att.playerId] : null;

    try {
      switch (msg.type) {
        case 'join':       await this.onJoin(ws, msg); break;
        case 'ready':      await this.onReady(player, msg); break;
        case 'start_round':await this.onStartRound(player, msg); break;
        case 'submit_pick':await this.onSubmitPick(player, msg); break;
        case 'flag_item':  await this.onFlagItem(player); break;
        case 'accept':     await this.onAccept(player); break;
        case 'force_advance': await this.onForceAdvance(player); break;
        case 'set_timers': await this.onSetTimers(player, msg); break;
        case 'kick':       await this.onKick(player, msg); break;
        case 'leave':      await this.onLeave(ws, player); break;
        default:           this.sendError(ws, `Unknown message: ${msg.type}`);
      }
    } catch (err) {
      this.sendError(ws, err.message || 'Something went wrong');
    }
  }

  async webSocketClose(ws) {
    await this.dropSocket(ws);
  }

  async webSocketError(ws) {
    await this.dropSocket(ws);
  }

  async dropSocket(ws) {
    if (!this.game) return;
    const { playerId } = ws.deserializeAttachment() ?? {};
    const player = playerId ? this.game.players[playerId] : null;

    // Rejoining from a second device closes the first socket on purpose. That
    // close lands here, and without this check it would mark the player
    // disconnected one instant after they reconnected.
    const replaced = this.liveSockets()
      .some((s) => s !== ws && (s.deserializeAttachment() ?? {}).playerId === playerId);

    if (player && !replaced) {
      player.connected = false;
      player.ready = false;

      // Their seat and their board are held so they can rejoin under the same
      // name and pick up exactly where they left off. Only the socket is gone.
      if (this.game.phase === 'picking' && !this.game.currentPicks[player.id]) {
        this.autoPick(player, 'disconnect');
      }
      if (this.game.phase === 'summary' && !this.game.accepts.includes(player.id)) {
        this.game.accepts.push(player.id);
      }
      if (this.game.hostId === player.id) this.promoteHost();
    }

    // The socket being dropped can still report OPEN at this point, so it is
    // excluded explicitly rather than trusted to have changed state.
    if (this.liveSockets().filter((s) => s !== ws).length === 0) {
      this.game.destructAt = Date.now() + DESTRUCT_AFTER_MS;
    }

    await this.settle();

    // Losing the last person who had not picked still completes the phase.
    if (this.game.phase === 'picking' && this.everyoneHasPicked()) await this.flip();
    else if (this.game.phase === 'summary' && this.everyoneHasAccepted()) await this.advance();
  }

  liveSockets() {
    return this.ctx.getWebSockets().filter((s) => s.readyState === WebSocket.OPEN);
  }

  // ─── Handlers ───────────────────────────────────────────────────────────

  async onJoin(ws, msg) {
    const name = String(msg.name ?? '').replace(/\s+/g, ' ').trim().slice(0, 16);
    if (!name) return this.sendError(ws, 'Pick a name first.');

    const key = normalize(name);
    // Seat is held by name, which is what makes rejoin work: same name, same
    // board, same spent budget.
    let player = Object.values(this.game.players).find((p) => normalize(p.name) === key);

    if (player) {
      player.connected = true;
      player.name = name;
    } else {
      if (this.game.phase !== 'lobby') {
        return this.sendError(ws, 'That round is already running. Wait for the next one.');
      }
      if (Object.keys(this.game.players).length >= MAX_PLAYERS) {
        return this.sendError(ws, `This room is full (${MAX_PLAYERS} players).`);
      }
      player = {
        id: crypto.randomUUID(),
        name,
        joinedAt: Date.now(),
        connected: true,
        ready: false,
        keepsLeft: KEEPS,
        cutsLeft: CUTS,
        picks: [],
      };
      this.game.players[player.id] = player;
    }

    if (!this.game.hostId || !this.game.players[this.game.hostId]) this.game.hostId = player.id;

    // Two tabs under one name would otherwise both drive the same seat, and
    // the second one's picks would overwrite the first's. Last socket wins.
    for (const other of this.liveSockets()) {
      if (other !== ws && (other.deserializeAttachment() ?? {}).playerId === player.id) {
        other.close(4409, 'joined from another device');
      }
    }

    ws.serializeAttachment({ playerId: player.id });
    this.game.destructAt = null;
    await this.settle();
  }

  async onReady(player, msg) {
    if (!player || this.game.phase !== 'lobby') return;
    player.ready = msg.ready !== false;
    await this.settle();
  }

  async onStartRound(player, msg) {
    this.assertHost(player);
    if (this.game.phase !== 'lobby' && this.game.phase !== 'final') {
      throw new Error('A round is already running.');
    }

    const { category, error } = validateCategory(msg.category);
    if (error) throw new Error(error);

    const now = Date.now();
    if (now - this.game.lastGenerationAt < GENERATION_COOLDOWN_MS) {
      const wait = Math.ceil((GENERATION_COOLDOWN_MS - (now - this.game.lastGenerationAt)) / 1000);
      throw new Error(`Hold on ${wait}s before generating again.`);
    }
    if (this.game.roundsPlayed >= MAX_ROUNDS) {
      throw new Error(`This room has played its ${MAX_ROUNDS} rounds. Start a new room.`);
    }

    const norm = normalize(category);
    const replays = this.game.replays[norm] ?? 0;
    if (replays >= MAX_REPLAYS_PER_CATEGORY) {
      throw new Error('You have replayed that category enough times - the list gets thin. Pick a new one.');
    }

    const connected = Object.values(this.game.players).filter((p) => p.connected);
    if (!connected.length) throw new Error('Nobody is connected.');

    this.game.lastGenerationAt = now;
    this.game.phase = 'generating';
    this.game.category = category;
    this.game.normCategory = norm;
    this.game.error = null;
    this.game.progress = 'Waking up';
    this.armDeadline('generation', GENERATION_TIMEOUT_MS);
    await this.settle();

    // Deliberately not awaited - the socket handler returns and the room keeps
    // taking messages while this runs. Ten to twenty seconds is a long time to
    // hold a lock over eight phones. The generation timeout alarm armed above
    // is what catches this if it never comes back.
    this.generate(category, norm).catch(() => { /* generate() handles its own errors */ });
  }

  async generate(category, norm) {
    const cache = new Map(Object.entries(this.game.verified[norm] ?? {}));
    const exclude = this.game.used[norm] ?? [];

    try {
      const { items, reserve } = await runPipeline(this.env, category, {
        exclude,
        cache,
        onProgress: (line) => {
          // Fire-and-forget progress. If the room has moved on, this is a
          // no-op; if it has not, it is the difference between a spinner and
          // a loading screen that tells you what it is waiting for.
          if (this.game?.phase === 'generating') {
            this.game.progress = line;
            this.broadcast();
          }
        },
      });

      if (this.game?.phase !== 'generating') return; // host bailed while we worked

      this.game.verified[norm] = Object.fromEntries(cache);
      // Only the eight in play are marked used. Reserve items that are never
      // swapped in were never seen, so burning them here would thin out a
      // replay for no reason; flagItem() adds one the moment it is dealt.
      this.game.used[norm] = [...exclude, ...items];
      this.game.replays[norm] = (this.game.replays[norm] ?? 0) + 1;
      this.game.roundsPlayed += 1;

      this.game.items = items;
      this.game.reserve = reserve;
      this.game.replacements = 0;
      this.game.flaggedBy = [];
      this.game.lastFlag = null;
      this.game.itemIndex = -1;
      this.game.progress = '';

      for (const p of Object.values(this.game.players)) {
        p.keepsLeft = KEEPS;
        p.cutsLeft = CUTS;
        p.picks = [];
        p.ready = false;
      }

      await this.revealNext();
    } catch (err) {
      if (this.game?.phase !== 'generating') return;
      this.game.phase = 'lobby';
      this.game.progress = '';
      this.game.error = err instanceof GenerationError || err instanceof AnthropicError
        ? err.message
        : 'Could not build a list. Try again.';
      // A failed generation still burned the cooldown, deliberately: a broken
      // category retried in a tight loop is the expensive failure mode.
      this.clearDeadline();
      await this.settle();
    }
  }

  async onSubmitPick(player, msg) {
    if (!player) return;
    if (this.game.phase !== 'picking') return;
    if (Date.now() < this.game.armAt) return;          // still in the reveal beat
    if (this.game.currentPicks[player.id]) return;     // no take-backs

    const choice = msg.choice === 'keep' ? 'keep' : msg.choice === 'cut' ? 'cut' : null;
    if (!choice) return;

    // A forced player's button press cannot override the math. The client
    // hides the buttons in that case, but the server is what decides.
    const forced = this.forcedChoice(player);
    if (forced && forced !== choice) return;

    if (choice === 'keep' && player.keepsLeft <= 0) return;
    if (choice === 'cut' && player.cutsLeft <= 0) return;

    this.recordPick(player, choice, forced ? 'forced' : 'manual');
    await this.settle({ cue: this.pickProgressCue() });

    if (this.everyoneHasPicked()) await this.flip();
  }

  async onAccept(player) {
    if (!player || this.game.phase !== 'summary') return;
    if (!this.game.accepts.includes(player.id)) this.game.accepts.push(player.id);
    await this.settle();
    if (this.everyoneHasAccepted()) await this.advance();
  }

  async onForceAdvance(player) {
    this.assertHost(player);
    if (this.game.phase === 'picking') {
      this.autoPickStragglers('timeout');
      await this.flip();
    } else if (this.game.phase === 'flipping') {
      await this.toSummary();
    } else if (this.game.phase === 'summary') {
      await this.advance();
    }
  }

  /**
   * "That one's wrong" — swap the item on screen for a fresh one, mid-round.
   *
   * Verification now only runs for time-sensitive categories, so a plausible
   * invention can reach the table in a way it previously could not. This is the
   * backstop, and it is deliberately a human one: the people playing know their
   * category better than a classifier does, and they are looking right at it.
   *
   * ANY player can flag, not just the host. The person who spots that a film
   * was directed by someone else is whoever happens to know, and routing it
   * through the host turns a two-second correction into a conversation. The
   * caps below are what keep that from becoming a re-roll button.
   *
   * Everything about this item is rewound: picks already recorded for it -
   * including the budget-forced ones taken at reveal - are refunded, because a
   * player who was locked into keeping a wrong answer must not stay locked into
   * it. Then the same index is revealed again with the replacement, so the
   * round neither advances nor repeats an item.
   */
  async onFlagItem(player) {
    if (!player) return;
    if (this.game.phase !== 'revealing' && this.game.phase !== 'picking') {
      throw new Error('You can only call an item out before the flip.');
    }
    if (this.game.flaggedBy.includes(player.id)) {
      throw new Error('You already called this one out.');
    }
    if (this.game.replacements >= MAX_REPLACEMENTS_PER_ROUND) {
      throw new Error(`That's ${MAX_REPLACEMENTS_PER_ROUND} swaps this round - the rest you argue about.`);
    }
    if (!this.game.reserve.length) {
      throw new Error('No spare items left for this category. Playing on.');
    }

    const rejected = this.game.items[this.game.itemIndex];
    const replacement = this.game.reserve.shift();

    this.game.flaggedBy.push(player.id);
    this.game.replacements += 1;
    this.game.items[this.game.itemIndex] = replacement;

    // A called-out item is wrong, not merely unlucky. Keeping it in the used
    // set means a replay of this category will not serve it back up.
    const norm = this.game.normCategory;
    this.game.used[norm] = [...(this.game.used[norm] ?? []), replacement];
    if (this.game.verified[norm]) {
      this.game.verified[norm][normalize(rejected)] = { pass: false, reason: 'called out by a player' };
    }

    // Refund every pick already taken on the old item.
    for (const p of Object.values(this.game.players)) {
      const prior = p.picks[this.game.itemIndex];
      if (!prior) continue;
      if (prior.choice === 'keep') p.keepsLeft += 1; else p.cutsLeft += 1;
      delete p.picks[this.game.itemIndex];
    }

    // Shown on the replacement so the table can see what happened and who
    // called it. Half the point of the feature is the callout itself.
    this.game.lastFlag = { by: player.name, rejected };

    await this.revealCurrent();
  }

  async onSetTimers(player, msg) {
    this.assertHost(player);
    if (this.game.phase !== 'lobby' && this.game.phase !== 'final') {
      throw new Error('Adjust timers between rounds.');
    }
    const clamp = (v, lo, hi, dflt) => (Number.isFinite(v) ? Math.min(hi, Math.max(lo, Math.round(v))) : dflt);
    this.game.timers = {
      pick: clamp(msg.pick, 10, 180, DEFAULT_PICK_SECONDS),
      accept: clamp(msg.accept, 5, 120, DEFAULT_ACCEPT_SECONDS),
    };
    await this.settle();
  }

  async onKick(player, msg) {
    this.assertHost(player);
    const target = this.game.players[msg.playerId];
    if (!target || target.id === player.id) return;

    delete this.game.players[target.id];
    for (const s of this.liveSockets()) {
      if ((s.deserializeAttachment() ?? {}).playerId === target.id) s.close(4403, 'removed by host');
    }
    delete this.game.currentPicks[target.id];
    this.game.accepts = this.game.accepts.filter((id) => id !== target.id);
    await this.settle();

    // Removing the last holdout can complete a phase.
    if (this.game.phase === 'picking' && this.everyoneHasPicked()) await this.flip();
    else if (this.game.phase === 'summary' && this.everyoneHasAccepted()) await this.advance();
  }

  async onLeave(ws, player) {
    if (player) {
      delete this.game.players[player.id];
      if (this.game.hostId === player.id) this.promoteHost();
    }
    ws.close(1000, 'left');
    await this.settle();
  }

  assertHost(player) {
    if (!player || this.game.hostId !== player.id) throw new Error('Only the host can do that.');
  }

  promoteHost() {
    // Longest-connected still-present player.
    const next = Object.values(this.game.players)
      .filter((p) => p.connected)
      .sort((a, b) => a.joinedAt - b.joinedAt)[0];
    this.game.hostId = next ? next.id : null;
  }

  // ─── Budget math (server-side, always) ──────────────────────────────────

  itemsRemaining() {
    return ITEMS_PER_ROUND - this.game.itemIndex; // includes the item on screen
  }

  /**
   * Returns 'keep' | 'cut' when the player's budget leaves them no choice at
   * all, otherwise null. Auto-picks still spend budget, which is what makes
   * the arithmetic land on exactly 3 and 5 every time.
   */
  forcedChoice(player) {
    const remaining = this.itemsRemaining();
    if (player.keepsLeft === 0) return 'cut';
    if (player.cutsLeft === 0) return 'keep';
    if (player.keepsLeft === remaining) return 'keep';
    if (player.cutsLeft === remaining) return 'cut';
    return null;
  }

  recordPick(player, choice, reason) {
    if (choice === 'keep') player.keepsLeft -= 1;
    else player.cutsLeft -= 1;
    const item = this.game.items[this.game.itemIndex];
    player.picks[this.game.itemIndex] = { item, choice, reason };
    this.game.currentPicks[player.id] = { choice, reason };
  }

  /**
   * The default when a player runs out of clock or drops with BOTH resources
   * still available.
   *
   * Cut, and the reason is slack rather than commitment: you hold five cuts
   * against three keeps, so spending a cut leaves more room before a forced
   * cascade starts making the rest of your choices for you. Auto-spending
   * somebody's plentiful resource is the smaller theft.
   */
  autoPick(player, reason) {
    const forced = this.forcedChoice(player);
    if (forced) return this.recordPick(player, forced, 'forced');
    return this.recordPick(player, 'cut', reason);
  }

  autoPickStragglers(reason) {
    for (const p of Object.values(this.game.players)) {
      if (!this.game.currentPicks[p.id]) this.autoPick(p, p.connected ? reason : 'disconnect');
    }
  }

  everyoneHasPicked() {
    const ids = Object.keys(this.game.players);
    return ids.length > 0 && ids.every((id) => this.game.currentPicks[id]);
  }

  everyoneHasAccepted() {
    const ids = Object.keys(this.game.players);
    return ids.length > 0 && ids.every((id) => this.game.accepts.includes(id));
  }

  // ─── Phase transitions ──────────────────────────────────────────────────

  async revealNext() {
    this.game.itemIndex += 1;
    this.game.flaggedBy = [];
    this.game.lastFlag = null;
    return this.revealCurrent();
  }

  // Puts the item at the current index on screen. Split out from revealNext so
  // a replaced item can be re-revealed at the SAME index without advancing the
  // round - see flagItem().
  async revealCurrent() {
    this.game.currentPicks = {};
    this.game.accepts = [];
    this.game.flips = [];
    this.game.phase = 'revealing';
    this.game.armAt = Date.now() + REVEAL_BEAT_MS;
    this.armDeadline('arm', REVEAL_BEAT_MS);

    // Pre-spend every budget-forced pick the moment the item lands. It is
    // still revealed and still flipped like everyone else's - watching someone
    // get locked into keeping something terrible is the best moment in the
    // game, and skipping ahead to the final screen would throw it away.
    for (const p of Object.values(this.game.players)) {
      const forced = this.forcedChoice(p);
      if (forced) this.recordPick(p, forced, 'forced');
    }

    // revealNext clears lastFlag, so a set value here means this reveal IS a
    // replacement and the table should be told whose callout caused it.
    if (this.game.lastFlag) {
      this.broadcastCue({ type: 'item_replaced', ...this.game.lastFlag });
    }

    await this.settle({
      cue: { type: 'item_revealed', index: this.game.itemIndex, item: this.game.items[this.game.itemIndex] },
    });
  }

  async startPicking() {
    this.game.phase = 'picking';
    this.armDeadline('pick', this.game.timers.pick * 1000);
    await this.settle({ cue: this.pickProgressCue() });

    // If every player was forced, nobody has anything to press. Flip on the
    // beat rather than sitting on a dead timer.
    if (this.everyoneHasPicked()) await this.flip();
  }

  async flip() {
    this.game.phase = 'flipping';
    this.clearDeadline();

    const rank = { manual: 0, forced: 1, timeout: 2, disconnect: 2 };
    this.game.flips = Object.values(this.game.players)
      .map((p) => ({
        playerId: p.id,
        name: p.name,
        choice: this.game.currentPicks[p.id]?.choice ?? 'cut',
        reason: this.game.currentPicks[p.id]?.reason ?? 'timeout',
      }))
      // Auto-picks land last in the stagger. A forced keep is the punchline of
      // the reveal and punchlines go at the end.
      .sort((a, b) => (rank[a.reason] ?? 3) - (rank[b.reason] ?? 3) || a.name.localeCompare(b.name));

    // The flip gets a phase of its own rather than being folded into summary.
    // It is the payoff of the whole item, and a summary screen that appears in
    // the same frame as the reveal throws it away. Length scales with the room
    // so twelve people still land inside the window.
    const stagger = Math.min(3400, 700 + this.game.flips.length * 240);
    this.armDeadline('flip', stagger);
    await this.settle({ cue: { type: 'flip', flips: this.game.flips, stagger } });
  }

  async toSummary() {
    this.game.phase = 'summary';
    this.game.accepts = [];
    this.armDeadline('accept', this.game.timers.accept * 1000);
    await this.settle({ cue: { type: 'summary' } });

    // A room where everyone has dropped should not sit on the accept timer.
    if (this.everyoneHasAccepted()) await this.advance();
  }

  async advance() {
    if (this.game.itemIndex >= ITEMS_PER_ROUND - 1) {
      this.game.phase = 'final';
      this.clearDeadline();
      await this.settle({ cue: { type: 'final' } });
      return;
    }
    await this.revealNext();
  }

  // ─── Alarms ─────────────────────────────────────────────────────────────
  //
  // A Durable Object has exactly one alarm, and this room wants four different
  // deadlines. So: one `deadline` for whatever the current phase is waiting on,
  // one `destructAt` for the room's own lifetime, and the alarm is always set
  // to whichever comes first.

  armDeadline(purpose, ms) {
    this.game.deadline = Date.now() + ms;
    this.game.deadlinePurpose = purpose;
  }

  clearDeadline() {
    this.game.deadline = null;
    this.game.deadlinePurpose = null;
  }

  async scheduleAlarm() {
    const times = [this.game.deadline, this.game.destructAt].filter(Boolean);
    if (!times.length) return this.ctx.storage.deleteAlarm();
    return this.ctx.storage.setAlarm(Math.min(...times));
  }

  async alarm() {
    if (!this.game) return;
    const now = Date.now();

    if (this.game.destructAt && now >= this.game.destructAt) {
      if (this.liveSockets().length === 0) {
        // The room dies here, and everything in it dies with it.
        this.game = null;
        await this.ctx.storage.deleteAll();
        return;
      }
      this.game.destructAt = null; // somebody came back
    }

    if (this.game.deadline && now >= this.game.deadline) {
      const purpose = this.game.deadlinePurpose;
      this.clearDeadline();

      if (purpose === 'arm' && this.game.phase === 'revealing') {
        await this.startPicking();
      } else if (purpose === 'flip' && this.game.phase === 'flipping') {
        await this.toSummary();
      } else if (purpose === 'pick' && this.game.phase === 'picking') {
        this.autoPickStragglers('timeout');
        await this.flip();
      } else if (purpose === 'accept' && this.game.phase === 'summary') {
        await this.advance();
      } else if (purpose === 'generation' && this.game.phase === 'generating') {
        this.game.phase = 'lobby';
        this.game.progress = '';
        this.game.error = 'The list took too long to build. Try again.';
        await this.settle();
      }
    }

    await this.save();
    await this.scheduleAlarm();
  }

  // ─── Snapshot + broadcast ───────────────────────────────────────────────

  /**
   * `settle` is the only way state reaches a client: persist, broadcast the
   * full snapshot, then re-arm the alarm. Every handler above ends in one.
   */
  async settle({ cue } = {}) {
    await this.save();
    this.broadcast(cue);
    await this.scheduleAlarm();
  }

  broadcast(cue) {
    for (const ws of this.liveSockets()) {
      const { playerId } = ws.deserializeAttachment() ?? {};
      try {
        ws.send(JSON.stringify({ type: 'state', ...this.snapshotFor(playerId) }));
        if (cue) ws.send(JSON.stringify(cue));
      } catch { /* a socket that died mid-send is handled by webSocketClose */ }
    }
  }

  // A cue on its own, with no snapshot attached. Only for events that need to
  // land before the state they describe - everything else rides with settle().
  broadcastCue(cue) {
    for (const ws of this.liveSockets()) {
      try { ws.send(JSON.stringify(cue)); } catch { /* handled by webSocketClose */ }
    }
  }

  pickProgressCue() {
    // How many, never what. Knowing that four people have locked in is part of
    // the pressure; knowing what they locked in would be the whole game.
    return {
      type: 'pick_progress',
      chosen: Object.keys(this.game.currentPicks).length,
      total: Object.keys(this.game.players).length,
    };
  }

  snapshotFor(playerId) {
    const g = this.game;
    const revealed = g.itemIndex >= 0 && g.phase !== 'lobby' && g.phase !== 'generating';
    const showChoices = g.phase === 'flipping' || g.phase === 'summary' || g.phase === 'final';

    const players = Object.values(g.players)
      .sort((a, b) => a.joinedAt - b.joinedAt)
      .map((p) => ({
        id: p.id,
        name: p.name,
        connected: p.connected,
        ready: p.ready,
        isHost: p.id === g.hostId,
        isYou: p.id === playerId,
        keepsLeft: p.keepsLeft,
        cutsLeft: p.cutsLeft,
        // Only picks on items already flipped. p.picks[itemIndex] exists as
        // soon as the item is revealed for anyone budget-forced, and shipping
        // that would leak a forced player's hand before the flip.
        picks: p.picks.slice(0, showChoices ? g.itemIndex + 1 : g.itemIndex),
        hasPicked: Boolean(g.currentPicks[p.id]),
        hasAccepted: g.accepts.includes(p.id),
      }));

    const me = playerId ? g.players[playerId] : null;

    return {
      code: g.code,
      phase: g.phase,
      category: g.category,
      timers: g.timers,
      players,
      youId: playerId ?? null,
      isHost: Boolean(me && g.hostId === me.id),
      itemIndex: g.itemIndex,
      itemCount: ITEMS_PER_ROUND,
      // The one line that keeps the game honest.
      item: revealed ? g.items[g.itemIndex] : null,
      armAt: g.armAt ?? 0,
      deadline: g.phase === 'picking' || g.phase === 'summary' ? g.deadline : null,
      progress: g.progress,
      error: g.error,
      roundsLeft: MAX_ROUNDS - g.roundsPlayed,
      pickProgress: { chosen: Object.keys(g.currentPicks).length, total: Object.keys(g.players).length },
      yourPick: me ? (g.currentPicks[me.id] ?? null) : null,
      yourForced: me && g.phase === 'picking' ? this.forcedChoice(me) : null,
      flips: showChoices ? g.flips : [],
      // Flagging. `spareItems` is a COUNT, never the reserve itself - the
      // client needs to know whether a swap is possible, not what it would be.
      canFlag: Boolean(
        me
        && (g.phase === 'revealing' || g.phase === 'picking')
        && !g.flaggedBy.includes(me.id)
        && g.replacements < MAX_REPLACEMENTS_PER_ROUND
        && g.reserve.length > 0
      ),
      swapsLeft: MAX_REPLACEMENTS_PER_ROUND - g.replacements,
      spareItems: g.reserve.length,
      lastFlag: g.lastFlag,
    };
  }

  sendError(ws, message, fatal = false) {
    try { ws.send(JSON.stringify({ type: 'error', message, fatal })); } catch { /* gone */ }
  }
}
