// ═══════════════════════════════════════════════════════════════════════════
// The Table — the room Durable Object
//
// One instance per live game session. The room code IS the object's name, so
// idFromName("QK4T") is the room and there is no lookup table.
//
// ── WHO IS WHO ─────────────────────────────────────────────────────────────
//
// The room never reads a database. The Pages route that hands it a socket has
// already checked Cloudflare Access and that game's D1, and it tells the room
// the answer in four headers on the upgrade (X-Table-Role, -Email, -Name,
// -Characters). The room believes them because nothing else can reach it:
// this Worker has no public hostname (workers_dev is off) and the Pages
// project's binding is the only way in. See functions/api/_lib/table-room.js.
//
// ── MESSAGE CONTRACT ───────────────────────────────────────────────────────
//
// Client -> room (JSON, `type` discriminates):
//   { type: 'hello' }                                     after the socket opens
//   { type: 'seat', characterId }                         a player picks who they are
//   { type: 'roll', kind: 'dice', expr, label?, visibility? }
//   { type: 'roll', kind: 'feat', rank, cs?, label?, visibility? }   Marvel
//   Initiative (phase 3; initiative.js has the state and the rule):
//   { type: 'init.roll' }                     a seated player, Palladium: d20 + their bonus
//   { type: 'init.roll', id | all: true }     GM. Palladium: one row, or every NPC
//                                             not yet rolled. Marvel: all = Roll the round
//   { type: 'init.add' }                      a seated player: their own character
//   { type: 'init.add', kind, ref?, name, hidden?, bonus?, attacks?, agility?, talents? }  GM
//   { type: 'init.remove', id | all: true }   GM any row; a player only their own
//   { type: 'init.move', id, to }             GM: drag a rolled row to position `to`
//   { type: 'init.set', id, hidden?, applies? }   GM: hide an NPC; Marvel's Talent tick
//   { type: 'init.next' }                     GM: start the round, or the next turn
//   { type: 'init.newRound', reroll? }        GM: a new melee (Palladium keeps the
//                                             order unless reroll) or round (Marvel)
//
// Room -> client:
//   { type: 'state', you, room, people, feed, shown, init }   on hello, and after a seat
//   { type: 'init', init }                       the order changed; masked per screen
//   { type: 'up', round, pass }                  this phone's character is up (it vibrates)
//   { type: 'deck' }                             this phone's character acts next
//   { type: 'roll', roll }                       a new roll this screen may see
//   { type: 'show', shown }                      the GM put a picture on the table
//   { type: 'clear' }                            the GM took it down
//   { type: 'people', people }                   someone came, went or sat down
//   { type: 'closed', reason }                   the table is over
//   { type: 'error', message }
//
// `shown` is { kind, id, caption, at } or null. It names the picture; the
// bytes come from the game's table/image route, which asks this room, through
// /may-fetch, whether the person asking may have them NOW (showing.js). The
// GM shows and clears from Present mode, through the show and clear routes,
// not over a socket: Present mode is its own page and holds none.
//
// ── WHAT A SCREEN RECEIVES ─────────────────────────────────────────────────
//
// Every roll goes out through canSee() in visibility.js, per connection. A
// "GM only" roll is never sent to a player's socket or the TV's - not masked,
// not flagged, not counted - so there is nothing on a phone to dig out. The
// design left open whether others should see a "rolled in secret" line; the
// answer here is no line at all, the stricter of the two, until Nate says
// otherwise. workers/table-room/test/room.mjs seats a player and asserts it.
//
// ── STORAGE ────────────────────────────────────────────────────────────────
//
// Everything lives in ctx.storage, because hibernation evicts instance memory
// while leaving the sockets connected - Pick 3 Cut 5 learned that one first.
//   meta         code, game, campaign, GM, status, and the next roll id
//   roll:NNNNNN  one key per roll, so a long session never rewrites its feed
//                and never nears the per-value size limit
//   shown        the picture on the table, or absent. Not saved with the
//                feed and dropped on close: showing leaves no trace.
//   init         the initiative order and whose turn it is (initiative.js).
//                Not saved with the feed either; the initiative ROLLS are
//                rolls, and go into the feed like any other.
//
// ── INITIATIVE ─────────────────────────────────────────────────────────────
//
// One order and one current turn per room; how a round is rolled and how it
// runs out is the game's (palladium.js, marvel.js). A player's own numbers -
// Palladium's initiative bonus and attacks per melee, Marvel's Agility and
// Talents - come in on the join, from D1 through the game's adapter, and ride
// on the seat; a player's message carries no number the room believes. The
// GM's are believed: the GM adds NPCs with their numbers, and could drag any
// row anywhere anyway. Every screen gets the order through initView(), which
// shows a hidden NPC to nobody but the GM. "You're up" goes to the phones
// seated as that character and to no other.
// Who is connected lives on each socket's attachment, which survives
// hibernation with the socket.
//
// ── ENDING ─────────────────────────────────────────────────────────────────
//
// The GM closes it through the close route, which reads the feed out, saves it
// to D1 and then tells the room to forget. A room nobody has been connected to
// for IDLE_CLOSE_MS marks itself closed but KEEPS its feed, and the campaign
// page saves it through the same route on the GM's next visit. So a feed is
// deleted only after D1 has it.
// ═══════════════════════════════════════════════════════════════════════════

import { canSee, visibilityFor, rollView } from './visibility.js';
import { imageRef, mayView, mayFetch } from './showing.js';
import { parseExpression, rollExpression, rollFeat } from './dice.js';
import { feat, hasInitTalent, rollRound, orderMarvel } from './marvel.js';
import * as P from './palladium.js';
import {
  emptyInit, addEntry, rollEntry, rollAll, next as nextTurn, newRound, removeEntry,
  moveEntry, setEntry, initView, onDeck, characterOf,
} from './initiative.js';

// How each game rolls an order and runs a round out (initiative.js).
export const RULES = {
  palladium: {
    perMelee: true,
    rollOne: (e, random) => P.rollOne(e.bonus, random),
    order: P.orderRolled,
  },
  marvel: {
    perMelee: false,
    rollOne: (e, random) => { const roll = 1 + Math.floor(random() * 100); return { roll, total: roll }; },
    order: orderMarvel,
    rollRound,
  },
};

const int = (v, lo, hi, dflt) => {
  const n = Math.trunc(Number(v));
  return Number.isFinite(n) ? Math.max(lo, Math.min(hi, n)) : dflt;
};

// A combatant's own numbers, cleaned: from a seat (D1, through the join) or
// from the GM's init.add.
export function initStats(game, s = {}) {
  if (game === 'marvel') {
    const talents = (Array.isArray(s.talents) ? s.talents : []).slice(0, 20).map((t) => String(t).slice(0, 40));
    return { agility: int(s.agility, 0, 5000, 0), talents };
  }
  return { bonus: int(s.bonus, -50, 50, 0), attacks: int(s.attacks, 0, 30, P.DEFAULT_ATTACKS) };
}

export const IDLE_CLOSE_MS = 12 * 60 * 60 * 1000;
export const FEED_MAX = 4000;          // about 1.2 MB saved: inside one D1 row
export const FEED_ON_CONNECT = 200;    // what a screen gets on (re)connect
export const GAMES = ['palladium', 'marvel'];
const TEXT_MAX = 300;
const LABEL_MAX = 60;
const CAPTION_MAX = 200;
const MESSAGE_MAX = 2000;
const OPEN = 1;                        // WebSocket.OPEN

const pad = (n) => String(n).padStart(6, '0');
const clean = (s, max) => String(s ?? '').replace(/\s+/g, ' ').trim().slice(0, max);

export class TableRoom {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
  }

  // Replaceable, so the tests can replay a roll exactly.
  random() {
    return crypto.getRandomValues(new Uint32Array(1))[0] / 4294967296;
  }

  meta() {
    return this.ctx.storage.get('meta');
  }

  // ─── HTTP surface: reached only through the Pages routes ─────────────────

  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;
    const meta = await this.meta();

    if (path === '/info') {
      if (!meta) return Response.json({ exists: false });
      const { code, game, campaignId, campaignName, status } = meta;
      return Response.json({ exists: true, code, game, campaignId, campaignName, status });
    }

    if (path === '/init' && request.method === 'POST') {
      if (meta) return Response.json({ error: 'taken' }, { status: 409 });
      const b = await request.json().catch(() => ({}));
      if (!GAMES.includes(b.game) || !b.code || b.campaignId == null || !b.gmEmail) {
        return Response.json({ error: 'code, game, campaignId and gmEmail are required' }, { status: 400 });
      }
      await this.ctx.storage.put('meta', {
        code: String(b.code), game: b.game, campaignId: String(b.campaignId),
        campaignName: clean(b.campaignName, 120), gmEmail: b.gmEmail,
        openedAt: Date.now(), status: 'open', closedAt: null, closedReason: null,
        nextId: 1, rolls: 0,
      });
      // Nobody is connected yet, so the idle clock starts now.
      await this.ctx.storage.setAlarm(Date.now() + IDLE_CLOSE_MS);
      return Response.json({ ok: true });
    }

    if (!meta) return Response.json({ error: 'No table with that code' }, { status: 404 });

    if (path === '/ws') {
      if (request.headers.get('Upgrade') !== 'websocket') {
        return new Response('Expected WebSocket', { status: 426 });
      }
      if (meta.status !== 'open') return Response.json({ error: 'This table has closed' }, { status: 410 });
      const att = this.identity(request.headers);
      if (!att) return Response.json({ error: 'No identity on the upgrade' }, { status: 400 });
      const [client, server] = Object.values(new WebSocketPair());
      await this.connect(server, att);
      return new Response(null, { status: 101, webSocket: client });
    }

    if (path === '/sheet-roll' && request.method === 'POST') {
      const b = await request.json().catch(() => ({}));
      return Response.json(await this.sheetRoll(b));
    }

    if (path === '/seat') {
      const email = url.searchParams.get('email');
      const characterId = url.searchParams.get('characterId');
      return Response.json({
        open: meta.status === 'open',
        seated: meta.status === 'open' && !!this.seatedSocket(email, characterId),
      });
    }

    if (path === '/shown') {
      return Response.json({ shown: meta.status === 'open' ? await this.shown() : null });
    }

    // The image route's question. Answered from the sockets connected NOW, so
    // a phone that has left, or a player who never sat down, is refused.
    if (path === '/may-fetch') {
      const ref = imageRef(url.searchParams.get('kind'), url.searchParams.get('id'));
      const shown = meta.status === 'open' ? await this.shown() : null;
      const conns = this.liveSockets().map((s) => s.deserializeAttachment());
      return Response.json({ allowed: !!ref && mayFetch(conns, shown, url.searchParams.get('email'), ref) });
    }

    if (path === '/show' && request.method === 'POST') {
      if (meta.status !== 'open') return Response.json({ error: 'This table has closed' }, { status: 410 });
      const b = await request.json().catch(() => ({}));
      const ref = imageRef(b.kind, b.id);
      if (!ref) return Response.json({ error: 'kind and id name the picture to show' }, { status: 400 });
      const shown = { ...ref, caption: clean(b.caption, CAPTION_MAX), at: Date.now() };
      await this.ctx.storage.put('shown', shown);
      this.broadcast({ type: 'show', shown });
      return Response.json({ shown });
    }

    if (path === '/clear' && request.method === 'POST') {
      if (meta.status !== 'open') return Response.json({ error: 'This table has closed' }, { status: 410 });
      await this.ctx.storage.delete('shown');
      this.broadcast({ type: 'clear' });
      return Response.json({ shown: null });
    }

    if (path === '/feed') return Response.json({ meta, feed: await this.feed() });

    if (path === '/close' && request.method === 'POST') {
      const b = await request.json().catch(() => ({}));
      await this.close(b.reason === 'idle' ? 'idle' : 'gm');
      return Response.json({ meta: await this.meta(), feed: await this.feed() });
    }

    if (path === '/forget' && request.method === 'POST') {
      for (const s of this.ctx.getWebSockets()) {
        try { s.close(4000, 'table closed'); } catch { /* already gone */ }
      }
      await this.ctx.storage.deleteAlarm();
      await this.ctx.storage.deleteAll();
      return Response.json({ ok: true });
    }

    return new Response('Not found', { status: 404 });
  }

  // The identity the join route put on the upgrade. Names are URI-encoded
  // because a header value cannot carry "Æsir" or an em-dash.
  identity(headers) {
    const role = headers.get('X-Table-Role');
    const email = headers.get('X-Table-Email');
    if (!['gm', 'player', 'display'].includes(role) || !email) return null;
    let characters = [];
    try {
      characters = JSON.parse(decodeURIComponent(headers.get('X-Table-Characters') || '[]'));
    } catch { characters = []; }
    if (!Array.isArray(characters)) characters = [];
    // `init` is the character's own initiative numbers, from D1 (the join
    // route's adapter). A join from a Pages build older than phase 3 sends
    // none, and the seat gets none: that player rolls on defaults.
    characters = characters.map((c) => ({
      id: String(c.id), name: clean(c.name, 80),
      ...(c.init && typeof c.init === 'object' ? { init: c.init } : {}),
    }));
    let name = '';
    try { name = decodeURIComponent(headers.get('X-Table-Name') || ''); } catch { name = ''; }
    return { role, email, name: clean(name, 80), characters: role === 'player' ? characters : [] };
  }

  // A socket joins. Split out of fetch so the tests can hand in a stand-in
  // socket; WebSocketPair exists only inside workerd.
  async connect(ws, att) {
    const conn = { ...att, id: crypto.randomUUID(), seat: null };
    // A player with one character in the campaign has nothing to choose.
    if (conn.role === 'player' && conn.characters.length === 1) conn.seat = conn.characters[0];
    // acceptWebSocket, not accept(): the room can hibernate between rolls with
    // every phone still connected.
    this.ctx.acceptWebSocket(ws);
    ws.serializeAttachment(conn);
    // Somebody is here, so the idle clock stops.
    await this.ctx.storage.deleteAlarm();
  }

  // ─── WebSocket handlers ─────────────────────────────────────────────────

  async webSocketMessage(ws, raw) {
    if (typeof raw !== 'string' || raw.length > MESSAGE_MAX) return this.sendError(ws, 'Message too large');
    let msg;
    try { msg = JSON.parse(raw); } catch { return this.sendError(ws, 'Malformed message'); }
    const meta = await this.meta();
    if (!meta || meta.status !== 'open') {
      return this.send(ws, { type: 'closed', reason: meta?.closedReason ?? 'gone' });
    }
    const conn = ws.deserializeAttachment() ?? {};
    try {
      switch (msg.type) {
        case 'hello': await this.sendState(ws, conn, meta); break;
        case 'seat':  await this.onSeat(ws, conn, msg, meta); break;
        case 'roll':  await this.onRoll(ws, conn, msg); break;
        default:
          if (String(msg.type).startsWith('init.')) await this.onInit(ws, conn, msg, meta);
          else this.sendError(ws, `Unknown message: ${String(msg.type).slice(0, 20)}`);
      }
    } catch (err) {
      this.sendError(ws, err.message || 'Something went wrong');
    }
  }

  async webSocketClose(ws) { await this.dropSocket(ws); }
  async webSocketError(ws) { await this.dropSocket(ws); }

  async dropSocket(ws) {
    try { ws.close(1000, 'bye'); } catch { /* already closed */ }
    const meta = await this.meta();
    if (!meta || meta.status !== 'open') return;
    // The socket being dropped can still report OPEN here, so it is excluded
    // explicitly rather than trusted to have changed state.
    const rest = this.liveSockets().filter((s) => s !== ws);
    if (!rest.length) await this.ctx.storage.setAlarm(Date.now() + IDLE_CLOSE_MS);
    this.broadcastPeople(rest);
  }

  async alarm() {
    const meta = await this.meta();
    if (!meta || meta.status !== 'open') return;
    if (this.liveSockets().length) return;       // somebody came back
    await this.close('idle');
  }

  // ─── Handlers ───────────────────────────────────────────────────────────

  async onSeat(ws, conn, msg, meta) {
    if (conn.role !== 'player') return this.sendError(ws, 'Only a player takes a seat');
    const pick = conn.characters.find((c) => c.id === String(msg.characterId));
    if (!pick) return this.sendError(ws, 'That is not one of your characters in this campaign');
    conn.seat = pick;
    ws.serializeAttachment(conn);
    await this.sendState(ws, conn, meta);
    this.broadcastPeople();
  }

  async onRoll(ws, conn, msg) {
    const visibility = visibilityFor(conn.role, msg.visibility);
    if (!visibility) return this.sendError(ws, 'The display cannot roll');
    if (conn.role === 'player' && !conn.seat) return this.sendError(ws, 'Pick your character first');

    let text;
    let detail;
    if (msg.kind === 'feat') {
      const r = rollFeat(feat, { rank: msg.rank, cs: msg.cs }, () => this.random());
      if (r.error) return this.sendError(ws, r.error);
      ({ text } = r);
      detail = { d100: r.d100, colour: r.colour, column: r.column };
    } else {
      const parsed = parseExpression(msg.expr);
      if (parsed.error) return this.sendError(ws, parsed.error);
      const r = rollExpression(parsed, () => this.random());
      ({ text } = r);
      detail = { total: r.total, parts: r.parts };
    }
    const label = clean(msg.label, LABEL_MAX);
    if (label) text = `${label}: ${text}`;

    await this.append({
      by: this.rollerOf(conn),
      source: msg.kind === 'feat' ? 'feat' : 'dice',
      visibility, text, detail,
    }, ws);
  }

  // A roll from the character sheet, through the roll route. The sheet saves
  // it to the character's session log itself; the room only carries it to
  // the screens, and only while that character is seated here.
  async sheetRoll(b) {
    const meta = await this.meta();
    if (meta.status !== 'open') return { seated: false, closed: true };
    const ws = this.seatedSocket(b.email, b.characterId);
    if (!ws) return { seated: false };
    const conn = ws.deserializeAttachment();
    const text = clean(b.text, TEXT_MAX);
    if (!text) return { seated: true, error: 'An empty roll' };
    const roll = await this.append({
      by: this.rollerOf(conn),
      source: 'sheet',
      visibility: visibilityFor('player', b.visibility),
      text,
    });
    return { seated: true, id: roll?.id ?? null };
  }

  // ─── Initiative ─────────────────────────────────────────────────────────

  async init() {
    return (await this.ctx.storage.get('init')) ?? emptyInit();
  }

  // Every init.* message. Refusals answer only the sender; a change is saved,
  // then every screen is sent the order as it may see it.
  async onInit(ws, conn, msg, meta) {
    const rules = RULES[meta.game];
    const init = await this.init();
    const gm = conn.role === 'gm';
    const player = conn.role === 'player' && !!conn.seat;
    if (!gm && !player) {
      return this.sendError(ws, conn.role === 'display' ? 'The display cannot run initiative' : 'Pick your character first');
    }
    const turnBefore = init.turn;
    const passBefore = init.pass;
    const mine = player
      ? init.entries.find((e) => e.kind === 'pc' && String(e.ref) === String(conn.seat.id)) ?? null
      : null;
    const rolls = [];
    let r = {};

    switch (msg.type) {
      case 'init.add': {
        if (gm) r = addEntry(init, this.gmEntry(meta.game, msg), this.newId());
        else r = mine ? { error: `${conn.seat.name} is already in the order` } : addEntry(init, this.seatEntry(meta.game, conn.seat), this.newId());
        break;
      }
      case 'init.roll': {
        if (meta.game === 'marvel') {
          if (!gm) { r = { error: 'The GM rolls the round' }; break; }
          r = msg.all ? rollAll(init, rules, () => this.random()) : rollEntry(init, String(msg.id), rules, () => this.random());
          break;
        }
        if (gm) {
          const ids = msg.all
            ? init.entries.filter((e) => !e.rolled && e.kind !== 'pc').map((e) => e.id)
            : [String(msg.id)];
          if (!ids.length) { r = { error: 'Every NPC has rolled' }; break; }
          for (const id of ids) {
            r = rollEntry(init, id, rules, () => this.random());
            if (r.error) break;
            rolls.push(r.entry);
          }
          break;
        }
        let entry = mine;
        if (!entry) {
          const added = addEntry(init, this.seatEntry(meta.game, conn.seat), this.newId());
          if (added.error) { r = added; break; }
          entry = added.entry;
        }
        if (entry.rolled) { r = { error: 'You have rolled for this melee' }; break; }
        r = rollEntry(init, entry.id, rules, () => this.random());
        if (!r.error) rolls.push(r.entry);
        break;
      }
      case 'init.remove': {
        if (gm && msg.all) { Object.assign(init, emptyInit(), { round: init.round }); break; }
        if (!gm && (!mine || mine.id !== String(msg.id))) { r = { error: 'You can only take your own character out' }; break; }
        r = removeEntry(init, String(msg.id), rules);
        break;
      }
      case 'init.move':    r = gm ? moveEntry(init, String(msg.id), msg.to) : { error: 'Only the GM moves the order' }; break;
      case 'init.set':     r = gm ? setEntry(init, String(msg.id), msg) : { error: 'Only the GM changes a row' }; break;
      case 'init.next':    r = gm ? nextTurn(init, rules) : { error: 'Only the GM moves the turn on' }; break;
      case 'init.newRound': r = gm ? newRound(init, rules, { reroll: msg.reroll === true }) : { error: 'Only the GM starts a round' }; break;
      default: r = { error: `Unknown message: ${String(msg.type).slice(0, 20)}` };
    }
    if (r.error && !rolls.length) return this.sendError(ws, r.error);

    await this.ctx.storage.put('init', init);
    // An initiative roll is a roll: into the feed, under the rule every roll
    // follows. A hidden NPC's goes to the GM alone, so its name reaches no one.
    for (const e of rolls) {
      const text = `Initiative${e.kind === 'pc' && player ? '' : ` for ${e.name}`}: d20 ${e.roll} ${e.bonus < 0 ? '-' : '+'}${Math.abs(e.bonus)} = ${e.total}`;
      await this.append({
        by: this.rollerOf(conn), source: 'initiative',
        visibility: e.hidden ? 'secret' : 'all', text, detail: { roll: e.roll, bonus: e.bonus, total: e.total },
      });
    }
    this.broadcastInit(init, rules, init.turn !== turnBefore || init.pass !== passBefore || msg.type === 'init.next');
    if (r.error) this.sendError(ws, r.error);
  }

  // The GM's own row: a statted NPC or PC from the roster, or a name alone.
  gmEntry(game, msg) {
    const kind = ['pc', 'npc', 'name'].includes(msg.kind) ? msg.kind : 'name';
    const name = clean(msg.name, LABEL_MAX) || 'Someone';
    const stats = initStats(game, msg);
    const e = { kind, ref: kind === 'name' || msg.ref == null ? null : String(msg.ref).slice(0, 40), name, hidden: kind !== 'pc' && msg.hidden === true };
    // Marvel: the Talent from a roster row's Talent ids, or the GM's own tick
    // for someone added by name.
    const talent = msg.talent === true || hasInitTalent(stats.talents);
    return game === 'marvel' ? { ...e, agility: stats.agility, talent } : { ...e, ...stats };
  }

  // A seated player's own character, with the numbers the join brought from D1.
  seatEntry(game, seat) {
    const stats = initStats(game, seat.init);
    const e = { kind: 'pc', ref: String(seat.id), name: seat.name, hidden: false };
    return game === 'marvel' ? { ...e, agility: stats.agility, talent: hasInitTalent(stats.talents) } : { ...e, ...stats };
  }

  newId() {
    return crypto.randomUUID().replace(/-/g, '').slice(0, 12);
  }

  // The order to every screen, masked for each. When the turn moved, "You're
  // up" to the phones seated as that character and "On deck" to the next.
  broadcastInit(init, rules, turned) {
    const up = turned ? characterOf(init, init.turn) : null;
    const deckId = turned ? onDeck(init, rules) : null;
    const deck = deckId && deckId !== init.turn ? characterOf(init, deckId) : null;
    for (const s of this.liveSockets()) {
      const c = s.deserializeAttachment() ?? {};
      this.send(s, { type: 'init', init: initView(init, c, rules) });
      if (c.role !== 'player' || !c.seat) continue;
      if (up && String(c.seat.id) === up) this.send(s, { type: 'up', round: init.round, pass: init.pass });
      else if (deck && String(c.seat.id) === deck) this.send(s, { type: 'deck' });
    }
  }

  rollerOf(conn) {
    if (conn.role === 'gm') return { email: conn.email, name: 'GM', role: 'gm', characterId: null };
    return { email: conn.email, name: conn.seat?.name || conn.name || 'Player', role: 'player', characterId: conn.seat?.id ?? null };
  }

  seatedSocket(email, characterId) {
    if (!email || characterId == null) return null;
    return this.liveSockets().find((s) => {
      const c = s.deserializeAttachment() ?? {};
      return c.role === 'player' && c.email === email && c.seat?.id === String(characterId);
    }) ?? null;
  }

  async append(fields, from = null) {
    const meta = await this.meta();
    if (meta.rolls >= FEED_MAX) {
      if (from) this.sendError(from, 'This table has reached its roll limit; close it and open a new one');
      return null;
    }
    const roll = { id: meta.nextId, at: Date.now(), ...fields };
    meta.nextId += 1;
    meta.rolls += 1;
    // One put, both keys: the counter and the roll land together or not at all.
    await this.ctx.storage.put({ meta, [`roll:${pad(roll.id)}`]: roll });
    for (const s of this.liveSockets()) {
      const c = s.deserializeAttachment() ?? {};
      if (canSee(c, roll)) this.send(s, { type: 'roll', roll: rollView(roll, c) });
    }
    return roll;
  }

  async feed() {
    const rows = await this.ctx.storage.list({ prefix: 'roll:' });
    return [...rows.values()];
  }

  async shown() {
    return (await this.ctx.storage.get('shown')) ?? null;
  }

  async sendState(ws, conn, meta) {
    const all = await this.feed();
    const feed = all.filter((r) => canSee(conn, r)).slice(-FEED_ON_CONNECT).map((r) => rollView(r, conn));
    this.send(ws, {
      type: 'state',
      you: { role: conn.role, name: conn.name, seat: conn.seat, characters: conn.characters },
      room: { code: meta.code, game: meta.game, campaignName: meta.campaignName, status: meta.status },
      people: this.people(),
      feed,
      shown: mayView(conn) ? await this.shown() : null,
      init: initView(await this.init(), conn, RULES[meta.game]),
    });
  }

  // A show or a clear, to the screens that may look (showing.js). A player
  // still choosing a character gets the picture with their state when they sit.
  broadcast(msg) {
    for (const s of this.liveSockets()) {
      if (mayView(s.deserializeAttachment())) this.send(s, msg);
    }
  }

  async close(reason) {
    const meta = await this.meta();
    if (!meta || meta.status !== 'open') return;
    meta.status = 'closed';
    meta.closedAt = Date.now();
    meta.closedReason = reason;
    await this.ctx.storage.put('meta', meta);
    await this.ctx.storage.delete('shown');
    await this.ctx.storage.delete('init');
    await this.ctx.storage.deleteAlarm();
    for (const s of this.liveSockets()) {
      this.send(s, { type: 'closed', reason });
      try { s.close(4000, 'table closed'); } catch { /* already gone */ }
    }
  }

  // ─── Plumbing ───────────────────────────────────────────────────────────

  liveSockets() {
    return this.ctx.getWebSockets().filter((s) => s.readyState === OPEN);
  }

  people(sockets = this.liveSockets()) {
    return sockets.map((s) => {
      const c = s.deserializeAttachment() ?? {};
      const name = c.role === 'gm' ? 'GM' : c.role === 'display' ? 'Display' : (c.seat?.name || 'Choosing a character');
      return { name, role: c.role };
    });
  }

  broadcastPeople(sockets = this.liveSockets()) {
    const people = this.people(sockets);
    for (const s of sockets) this.send(s, { type: 'people', people });
  }

  send(ws, msg) {
    try { ws.send(JSON.stringify(msg)); } catch { /* a dead socket is handled by webSocketClose */ }
  }

  sendError(ws, message) {
    this.send(ws, { type: 'error', message });
  }
}
