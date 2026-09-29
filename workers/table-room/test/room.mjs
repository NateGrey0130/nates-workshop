// The Table's room, run for real in Node against stand-ins for the three
// things only workerd provides: the socket, the object's storage and its
// hibernation bookkeeping. The class under test is the one that deploys -
// workers/table-room/src/room.js, imported, not copied.
//
// Run from anywhere:  node workers/table-room/test/room.mjs
//
// The check that matters most is the one the design names as its mitigation
// for "a secret roll leaks": seat a player, have the GM roll GM-only, and
// assert that nothing about that roll ever arrives on the player's socket or
// the TV's. It reads every byte each stand-in socket was sent, not just the
// `roll` messages, so a leak through `state`, `people` or an error counts too.

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { section, check, summary, repoRoot } from '../../../shared/test/harness.mjs';
import { TableRoom, IDLE_CLOSE_MS, FEED_ON_CONNECT } from '../src/room.js';
import { canSee, visibilityFor, rollView, filterFeed } from '../src/visibility.js';
import { parseExpression, rollExpression, rollFeat } from '../src/dice.js';
import { feat } from '../src/marvel.js';
import { validCode, ALPHABET } from '../../../functions/api/_lib/table-room.js';

// ── Stand-ins ────────────────────────────────────────────────────────────────

class FakeStorage {
  constructor() { this.map = new Map(); this.alarm = null; }
  async get(k) { const v = this.map.get(k); return v === undefined ? undefined : structuredClone(v); }
  async put(k, v) {
    if (typeof k === 'object') for (const [kk, vv] of Object.entries(k)) this.map.set(kk, structuredClone(vv));
    else this.map.set(k, structuredClone(v));
  }
  async delete(k) { return this.map.delete(k); }
  async list({ prefix = '' } = {}) {
    const keys = [...this.map.keys()].filter((k) => k.startsWith(prefix)).sort();
    return new Map(keys.map((k) => [k, structuredClone(this.map.get(k))]));
  }
  async deleteAll() { this.map.clear(); }
  async setAlarm(t) { this.alarm = t; }
  async deleteAlarm() { this.alarm = null; }
  async getAlarm() { return this.alarm; }
}

class FakeSocket {
  constructor(label) { this.label = label; this.readyState = 1; this.raw = []; this.att = null; }
  send(s) { if (this.readyState !== 1) throw new Error('closed'); this.raw.push(s); }
  close() { this.readyState = 3; }
  serializeAttachment(a) { this.att = structuredClone(a); }
  deserializeAttachment() { return this.att === null ? null : structuredClone(this.att); }
  get messages() { return this.raw.map((s) => JSON.parse(s)); }
  clear() { this.raw = []; }
}

function makeRoom() {
  const storage = new FakeStorage();
  const sockets = [];
  const ctx = {
    storage,
    acceptWebSocket: (ws) => sockets.push(ws),
    getWebSockets: () => sockets.slice(),
  };
  const room = new TableRoom(ctx, {});
  // A fixed sequence, so every roll below is known in advance.
  let i = 0;
  const seq = [0.95, 0.10, 0.50, 0.33, 0.72, 0.05, 0.61, 0.88];
  room.random = () => seq[i++ % seq.length];
  return { room, storage, sockets };
}

const post = (room, path, body) => room.fetch(new Request(`https://table${path}`, {
  method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body ?? {}),
}));
const get = (room, path) => room.fetch(new Request(`https://table${path}`));
const say = (room, ws, msg) => room.webSocketMessage(ws, JSON.stringify(msg));

const GM = 'gm@example.com';
const ANN = 'ann@example.com';
const BEN = 'ben@example.com';

async function openTable() {
  const t = makeRoom();
  const r = await post(t.room, '/init', { code: 'QK4T', game: 'palladium', campaignId: 7, campaignName: 'Chi-Town', gmEmail: GM });
  t.initStatus = r.status;
  t.gm = new FakeSocket('gm');
  // The TV, signed in as the GM: it must still see public rolls only.
  t.tv = new FakeSocket('tv');
  t.ann = new FakeSocket('ann');
  t.ben = new FakeSocket('ben');
  await t.room.connect(t.gm, { role: 'gm', email: GM, name: 'GM', characters: [] });
  await t.room.connect(t.tv, { role: 'display', email: GM, name: 'Display', characters: [] });
  await t.room.connect(t.ann, { role: 'player', email: ANN, name: '', characters: [{ id: '11', name: 'Vex' }, { id: '12', name: 'Sparrow' }] });
  await t.room.connect(t.ben, { role: 'player', email: BEN, name: '', characters: [{ id: '21', name: 'Dog Boy Rusty' }] });
  for (const s of [t.gm, t.tv, t.ann, t.ben]) await say(t.room, s, { type: 'hello' });
  return t;
}

const everything = (ws) => ws.raw.join('\n');
const rollsOn = (ws) => ws.messages.filter((m) => m.type === 'roll').map((m) => m.roll);

// ── The visibility rule itself ───────────────────────────────────────────────

section('the table: who may see a roll');
{
  const roll = (visibility, email = ANN) => ({ visibility, by: { email } });
  const gm = { role: 'gm', email: GM };
  const tv = { role: 'display', email: GM };
  const ann = { role: 'player', email: ANN };
  const ben = { role: 'player', email: BEN };
  check('a public roll reaches every role', [gm, tv, ann, ben].every((c) => canSee(c, roll('all'))));
  check('a To GM roll reaches its roller and the GM only',
    canSee(gm, roll('gm')) && canSee(ann, roll('gm')) && !canSee(ben, roll('gm')) && !canSee(tv, roll('gm')));
  check('a GM-only roll reaches the GM only',
    canSee(gm, roll('secret', GM)) && !canSee(tv, roll('secret', GM)) && !canSee(ann, roll('secret', GM)) && !canSee(ben, roll('secret', GM)));
  check('a TV signed in as the roller still does not see a To GM roll',
    !canSee({ role: 'display', email: ANN }, roll('gm', ANN)));
  check('an unknown visibility reaches the GM only', !canSee(ann, roll('everyone', ANN)) && canSee(gm, roll('everyone')));
  check('a player can ask for Everyone or To GM, and anything else is To GM',
    visibilityFor('player', 'all') === 'all' && visibilityFor('player', 'gm') === 'gm'
    && visibilityFor('player', 'secret') === 'gm' && visibilityFor('player', 'Everyone') === 'gm'
    && visibilityFor('player', undefined) === 'all');
  check('the GM can ask for Everyone or GM only, and anything else is GM only',
    visibilityFor('gm', 'all') === 'all' && visibilityFor('gm', 'secret') === 'secret' && visibilityFor('gm', 'gm') === 'secret');
  check('the display cannot roll', visibilityFor('display', 'all') === null);
}

// ── A seated player never receives a GM-only roll ────────────────────────────

section('the table: a GM-only roll never reaches a player or the TV');
{
  const t = await openTable();
  check('the room opens', t.initStatus === 200, `init answered ${t.initStatus}`);
  const annState = t.ann.messages.find((m) => m.type === 'state');
  const benState = t.ben.messages.find((m) => m.type === 'state');
  check('a player with one character is seated on arrival', benState?.you?.seat?.name === 'Dog Boy Rusty');
  check('a player with two characters is not seated until they pick', annState?.you?.seat === null);
  await say(t.room, t.ann, { type: 'seat', characterId: '11' });
  const reseat = t.ann.messages.filter((m) => m.type === 'state').pop();
  check('a player can seat one of their own characters', reseat?.you?.seat?.name === 'Vex');
  await say(t.room, t.ann, { type: 'seat', characterId: '21' });
  check('and not somebody else\'s', t.ann.messages.at(-1)?.type === 'error'
    && t.ann.deserializeAttachment().seat.id === '11');

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  await say(t.room, t.gm, { type: 'roll', kind: 'dice', expr: '1d20+4', label: 'Ambush check', visibility: 'secret' });
  const secret = rollsOn(t.gm)[0];
  check('the GM receives their own GM-only roll', !!secret && secret.visibility === 'secret', JSON.stringify(t.gm.messages));
  check('the seated player receives NOTHING for it', t.ann.raw.length === 0 && t.ben.raw.length === 0,
    `ann got ${everything(t.ann)} / ben got ${everything(t.ben)}`);
  check('the TV receives nothing for it', t.tv.raw.length === 0, everything(t.tv));

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  await say(t.room, t.ann, { type: 'roll', kind: 'dice', expr: 'd20', label: 'Perception', visibility: 'gm' });
  check('a To GM roll reaches the GM', rollsOn(t.gm).length === 1 && rollsOn(t.gm)[0].visibility === 'gm');
  check('and the player who rolled it, marked as theirs', rollsOn(t.ann).length === 1 && rollsOn(t.ann)[0].mine === true);
  check('and not the other player, or the TV', t.ben.raw.length === 0 && t.tv.raw.length === 0);

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  await say(t.room, t.ann, { type: 'roll', kind: 'dice', expr: 'd6', visibility: 'secret' });
  check('a player asking for GM only gets To GM, not a public roll',
    rollsOn(t.gm)[0]?.visibility === 'gm' && t.ben.raw.length === 0 && t.tv.raw.length === 0);

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  const sheet = await (await post(t.room, '/sheet-roll', {
    email: BEN, characterId: 21, text: 'Prowl: 34 vs 55% — pass', visibility: 'all',
  })).json();
  check('a sheet roll from a seated character is carried', sheet.seated === true);
  check('and reaches every screen, TV included, with its note unchanged',
    [t.gm, t.tv, t.ann, t.ben].every((s) => rollsOn(s)[0]?.text === 'Prowl: 34 vs 55% — pass'),
    everything(t.tv));
  check('a sheet roll is marked as coming from the sheet', rollsOn(t.gm)[0]?.source === 'sheet');

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  const unseated = await (await post(t.room, '/sheet-roll', { email: ANN, characterId: 12, text: 'Climb: 12', visibility: 'all' })).json();
  check('a sheet roll from an unseated character is not carried', unseated.seated === false
    && [t.gm, t.tv, t.ann, t.ben].every((s) => s.raw.length === 0));
  const forged = await (await post(t.room, '/sheet-roll', { email: ANN, characterId: 21, text: 'Climb: 12' })).json();
  check('nor one naming somebody else\'s seated character', forged.seated === false);

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  await say(t.room, t.tv, { type: 'roll', kind: 'dice', expr: 'd20', visibility: 'all' });
  check('the display cannot roll', t.tv.messages[0]?.type === 'error' && t.gm.raw.length === 0);

  // Reconnecting is where a full feed is sent, so it is where a leak would be.
  const ann2 = new FakeSocket('ann2');
  const ben2 = new FakeSocket('ben2');
  const tv2 = new FakeSocket('tv2');
  await t.room.connect(ann2, { role: 'player', email: ANN, name: '', characters: [{ id: '11', name: 'Vex' }] });
  await t.room.connect(ben2, { role: 'player', email: BEN, name: '', characters: [{ id: '21', name: 'Dog Boy Rusty' }] });
  await t.room.connect(tv2, { role: 'display', email: GM, name: 'Display', characters: [] });
  for (const s of [ann2, ben2, tv2]) await say(t.room, s, { type: 'hello' });
  const feedOf = (s) => s.messages.find((m) => m.type === 'state')?.feed ?? [];
  check('on reconnect, a player\'s feed carries their own To GM rolls',
    feedOf(ann2).filter((r) => r.visibility === 'gm').length === 2);
  check('and nothing GM-only, anywhere in what was sent',
    !everything(ann2).includes('Ambush check') && !everything(ben2).includes('Ambush check') && !everything(tv2).includes('Ambush check'));
  check('the other player\'s reconnect feed holds public rolls only',
    feedOf(ben2).length > 0 && feedOf(ben2).every((r) => r.visibility === 'all'));
  check('the TV\'s reconnect feed holds public rolls only',
    feedOf(tv2).length > 0 && feedOf(tv2).every((r) => r.visibility === 'all'));
  check('no screen is sent an email address', ![t.gm, t.ann, t.ben, ann2, ben2, tv2].some((s) => /@example\.com/.test(everything(s))));

  // Close: every roll comes out for the route to save, and every screen is told.
  const closed = await (await post(t.room, '/close', { reason: 'gm' })).json();
  check('close hands back the whole feed, hidden rolls included',
    closed.feed.length === 4 && closed.feed.some((r) => r.visibility === 'secret'), `${closed.feed.length} rolls`);
  check('the saved feed keeps who rolled, for the filter to use later', closed.feed.every((r) => r.by?.email));
  check('close tells every screen and closes its socket',
    [t.gm, t.ann, t.ben].every((s) => s.messages.some((m) => m.type === 'closed') && s.readyState === 3));
  check('a closed table accepts no more rolls', (await (await post(t.room, '/sheet-roll', { email: BEN, characterId: 21, text: 'x' })).json()).closed === true);
  const info = await (await get(t.room, '/info')).json();
  check('a closed table still answers what it was until it is forgotten', info.exists && info.status === 'closed');
  await post(t.room, '/forget');
  check('forget empties the room', t.storage.map.size === 0 && !(await (await get(t.room, '/info')).json()).exists);
}

// ── The saved record reads back through the same rule ────────────────────────

section('the table: a saved session is filtered the way the room filters');
{
  const feed = [
    { id: 1, visibility: 'all', by: { email: ANN, name: 'Vex' }, text: 'a' },
    { id: 2, visibility: 'gm', by: { email: ANN, name: 'Vex' }, text: 'b' },
    { id: 3, visibility: 'secret', by: { email: GM, name: 'GM' }, text: 'c' },
  ];
  const ids = (xs) => xs.map((r) => r.id).join(',');
  check('the GM reads every roll back', ids(filterFeed(feed, { role: 'gm', email: GM })) === '1,2,3');
  check('the roller reads back public and their own To GM', ids(filterFeed(feed, { role: 'player', email: ANN })) === '1,2');
  check('another player reads back public only', ids(filterFeed(feed, { role: 'player', email: BEN })) === '1');
  check('no email leaves in a read-back', !JSON.stringify(filterFeed(feed, { role: 'gm', email: GM })).includes('@'));
  check('rollView and filterFeed agree on what a roll looks like',
    JSON.stringify(filterFeed([feed[0]], { role: 'player', email: ANN })[0]) === JSON.stringify(rollView(feed[0], { role: 'player', email: ANN })));
}

// ── Idle close keeps the feed ────────────────────────────────────────────────

section('the table: an abandoned room closes itself and keeps its feed');
{
  const t = await openTable();
  await say(t.room, t.ben, { type: 'roll', kind: 'dice', expr: '2d6', visibility: 'all' });
  check('an opened table with people in it has no idle alarm', t.storage.alarm === null);
  for (const s of [t.gm, t.tv, t.ann, t.ben]) { s.close(); await t.room.webSocketClose(s); }
  check('the last person leaving starts the idle clock',
    t.storage.alarm !== null && Math.abs(t.storage.alarm - (Date.now() + IDLE_CLOSE_MS)) < 5000);
  check('the idle time is twelve hours', IDLE_CLOSE_MS === 12 * 60 * 60 * 1000);
  await t.room.alarm();
  const info = await (await get(t.room, '/info')).json();
  check('when it fires the table marks itself closed', info.status === 'closed');
  const kept = await (await get(t.room, '/feed')).json();
  check('and keeps its feed for the campaign page to save', kept.feed.length === 1 && kept.meta.closedReason === 'idle');

  const t2 = await openTable();
  const back = new FakeSocket('back');
  for (const s of [t2.gm, t2.tv, t2.ann]) { s.close(); await t2.room.webSocketClose(s); }
  check('someone still connected keeps the clock stopped', t2.storage.alarm === null);
  await t2.room.connect(back, { role: 'gm', email: GM, name: 'GM', characters: [] });
  t2.ben.close(); await t2.room.webSocketClose(t2.ben);
  await t2.room.alarm();
  check('an alarm with somebody connected closes nothing', (await (await get(t2.room, '/info')).json()).status === 'open');

  const t3 = makeRoom();
  await post(t3.room, '/init', { code: 'ZZZZ', game: 'marvel', campaignId: 1, campaignName: 'X', gmEmail: GM });
  check('a table nobody ever joins starts the idle clock at once', t3.storage.alarm !== null);
  const again = await post(t3.room, '/init', { code: 'ZZZZ', game: 'marvel', campaignId: 2, campaignName: 'Y', gmEmail: ANN });
  check('a code already in use cannot be taken', again.status === 409);
  const bad = await post(makeRoom().room, '/init', { code: 'AAAA', game: 'chess', campaignId: 1, gmEmail: GM });
  check('a room is only ever for Palladium or Marvel', bad.status === 400);
}

// ── The dice box ─────────────────────────────────────────────────────────────

section('the table: the dice box');
{
  const p = parseExpression(' 2d6 + 3 ');
  check('an expression parses and is written back one way', p.text === '2d6+3', JSON.stringify(p));
  check('d% is d100', parseExpression('d%').text === 'd100');
  check('a lone number is not a roll', !!parseExpression('7').error);
  check('garbage is refused', !!parseExpression('2d6; drop table').error && !!parseExpression('d').error);
  check('a thousand dice are refused', !!parseExpression('1000d6').error);
  check('a one-sided die is refused', !!parseExpression('3d1').error);
  const seq = [0.5, 0.0, 0.99];
  let i = 0;
  const r = rollExpression(parseExpression('2d6-1+d20'), () => seq[i++]);
  check('a roll adds its dice and modifiers', r.total === 4 + 1 - 1 + 20, JSON.stringify(r));
  check('and says so in the feed', r.text === '2d6-1+d20: 4, 1 - 1 + 20 = 24', r.text);
  const lone = rollExpression(parseExpression('d20'), () => 0.7);
  check('a lone die says its number once', lone.text === 'd20: 15', lone.text);

  const f = rollFeat(feat, { rank: 'remarkable', cs: 0 }, () => 0.66);
  const direct = feat.roll({ rank: 'remarkable', cs: 0, d100: 67 });
  check('a FEAT rolls d100 on the Marvel app\'s own Universal Table', f.d100 === 67 && f.colour === direct.colour, JSON.stringify(f));
  const shifted = rollFeat(feat, { rank: 'remarkable', cs: 1 }, () => 0.66);
  check('a column shift moves the column', shifted.column === 'incredible' && /\+1 CS to Incredible/.test(shifted.text), shifted.text);
  check('an unknown rank is refused', !!rollFeat(feat, { rank: 'legendary' }, () => 0.5).error);
  check('a wild column shift is refused', !!rollFeat(feat, { rank: 'good', cs: 40 }, () => 0.5).error);
}

// ── What the room is reachable by ────────────────────────────────────────────

section('the table: the room Worker has no door of its own');
{
  const cfg = readFileSync(join(repoRoot, 'workers', 'table-room', 'wrangler.jsonc'), 'utf8');
  check('workers_dev is off', /"workers_dev"\s*:\s*false/.test(cfg));
  check('the room Worker binds no database', !/d1_databases|kv_namespaces|r2_buckets/.test(cfg.replace(/\/\/.*$/gm, '')));
  const index = (await import('../src/index.js')).default;
  check('its own fetch handler answers 404', (await index.fetch(new Request('https://x/ws'))).status === 404);
  const root = readFileSync(join(repoRoot, 'wrangler.jsonc'), 'utf8');
  check('the Pages project binds the room by script_name',
    /"name"\s*:\s*"TABLE_ROOM"\s*,\s*"class_name"\s*:\s*"TableRoom"\s*,\s*"script_name"\s*:\s*"table-room"/.test(root));
  check('room codes use the four-character, no-lookalike alphabet',
    ALPHABET === 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789' && validCode('QK4T') && !validCode('QK0T') && !validCode('QK4') && !validCode('qk4t!'));
  check('the feed a screen gets on connect is capped', FEED_ON_CONNECT === 200);
}

// ── The routes, against a real room and a D1 built from the migrations ───────
//
// The Pages handlers run as Pages would run them, with the caller's Access
// email; D1 is node:sqlite loaded from the CREATEs a database has (campaigns
// and characters from schema.sql, then migrations 088 and 089 themselves); and
// env.TABLE_ROOM is a stand-in namespace whose objects are real TableRooms.
// Its one liberty is the upgrade: workerd's WebSocketPair does not exist here,
// so a /ws request hands the room a stand-in socket built from the SAME
// headers the route set - which is the thing under test.

function createOf(schema, table) {
  const m = schema.match(new RegExp(`CREATE TABLE IF NOT EXISTS ${table} \\([\\s\\S]*?\\n\\);`));
  if (!m) throw new Error(`no CREATE for ${table}`);
  return m[0];
}

async function standIn() {
  const { DatabaseSync } = await import('node:sqlite');
  const sqlite = new DatabaseSync(':memory:');
  sqlite.exec('PRAGMA foreign_keys = ON');
  sqlite.exec('CREATE TABLE schema_migrations (filename TEXT PRIMARY KEY, applied_at TEXT)');
  const pal = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  sqlite.exec(createOf(pal, 'campaigns'));
  sqlite.exec(createOf(pal, 'characters'));
  sqlite.exec(readFileSync(join(repoRoot, 'db', 'migrations', '088-table-sessions.sql'), 'utf8'));
  for (const f of ['082-msh-heroes.sql', '086-msh-campaigns.sql', '089-msh-table-sessions.sql']) {
    sqlite.exec(readFileSync(join(repoRoot, 'db', 'migrations', 'marvel', f), 'utf8'));
  }
  const statement = (sql, args) => {
    const st = sqlite.prepare(sql);
    return {
      first: async () => st.get(...args) ?? null,
      all: async () => ({ results: st.all(...args) }),
      run: async () => ({ meta: { changes: Number(st.run(...args).changes) } }),
    };
  };
  const D1 = { prepare: (sql) => ({ bind: (...args) => statement(sql, args), ...statement(sql, []) }) };

  const rooms = new Map();
  const TABLE_ROOM = {
    rooms,
    idFromName: (name) => name,
    get: (name) => {
      if (!rooms.has(name)) rooms.set(name, { ...makeRoom(), sockets: [] });
      const t = rooms.get(name);
      return {
        fetch: async (input, init) => {
          const req = input instanceof Request ? input : new Request(input, init);
          if (new URL(req.url).pathname !== '/ws') return t.room.fetch(req);
          const info = await (await t.room.fetch(new Request('https://table/info'))).json();
          if (!info.exists || info.status !== 'open') return new Response('closed', { status: 410 });
          const att = t.room.identity(req.headers);
          if (!att) return new Response('no identity', { status: 400 });
          const ws = new FakeSocket(att.email);
          await t.room.connect(ws, att);
          await say(t.room, ws, { type: 'hello' });
          t.sockets.push(ws);
          return new Response(null, { status: 200 });
        },
      };
    },
  };
  const env = { DB: D1, DB_MARVEL: D1, TABLE_ROOM };
  const route = (p) => import(new URL(`../../../functions/api/${p}`, import.meta.url));
  const call = async (mod, method, { who, query = '', body, headers = {} } = {}) => {
    const h = { 'Cf-Access-Authenticated-User-Email': who, ...headers };
    if (body !== undefined) h['Content-Type'] = 'application/json';
    const request = new Request(`https://nates-workshop.pages.dev/api/x${query}`,
      { method, headers: h, body: body === undefined ? undefined : JSON.stringify(body) });
    const handler = mod[`onRequest${method[0]}${method.slice(1).toLowerCase()}`];
    const res = await handler({ request, env, params: {} });
    const text = await res.text();
    let json = null;
    try { json = JSON.parse(text); } catch { json = null; }
    return { status: res.status, body: json };
  };
  const socketOf = (code) => rooms.get(code)?.sockets.at(-1);
  return { sqlite, env, rooms, route, call, socketOf };
}

section('the table routes: the role at the table comes from D1');
{
  const S = await standIn();
  S.sqlite.exec(`INSERT INTO campaigns (id, name, system, gm_email) VALUES (1, 'Chi-Town', 'rifts', '${GM}')`);
  const pc = (id, email, name, kind = 'pc') => S.sqlite.exec(
    `INSERT INTO characters (id, campaign_id, player_email, name, class_id, kind) VALUES (${id}, 1, '${email}', '${name}', 'x', '${kind}')`);
  pc(11, ANN, 'Vex'); pc(12, ANN, 'Sparrow'); pc(21, BEN, 'Dog Boy Rusty'); pc(90, GM, 'The Villain', 'npc');
  const CARL = 'carl@example.com';
  const T = {};
  for (const a of ['open', 'access', 'join', 'close', 'status', 'sessions', 'roll', 'seat']) T[a] = await S.route(`character-creator/table/${a}.js`);
  const lookup = await S.route('table/lookup.js');
  const up = { Upgrade: 'websocket' };

  check('a player cannot open the table', (await S.call(T.open, 'POST', { who: ANN, body: { campaign_id: 1 } })).status === 403);
  const opened = await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } });
  const code = opened.body?.code;
  check('the GM opens it and gets a code', opened.status === 200 && validCode(code), JSON.stringify(opened.body));
  const again = await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } });
  check('opening it again hands back the same table', again.body?.code === code && again.body?.already_open === true);
  check('the campaign records the open table',
    S.sqlite.prepare('SELECT count(*) AS n FROM table_sessions WHERE closed_at IS NULL').get().n === 1);
  check('the lookup names the game and nothing else',
    JSON.stringify((await S.call(lookup, 'GET', { who: CARL, query: `?code=${code}` })).body) === '{"game":"palladium","status":"open"}');

  const annAccess = await S.call(T.access, 'GET', { who: ANN, query: `?code=${code}` });
  check('a player may sit as a player or be the display',
    JSON.stringify(annAccess.body?.roles) === '["player","display"]' && annAccess.body?.characters.length === 2, JSON.stringify(annAccess.body));
  check('the GM\'s statted NPC seats nobody', !JSON.stringify(annAccess.body).includes('Villain')
    && (await S.call(T.access, 'GET', { who: GM, query: `?code=${code}` })).body?.characters.length === 0);
  check('the GM may be the GM or the display',
    JSON.stringify((await S.call(T.access, 'GET', { who: GM, query: `?code=${code}` })).body?.roles) === '["gm","display"]');
  check('someone with no character in the campaign is refused', (await S.call(T.access, 'GET', { who: CARL, query: `?code=${code}` })).status === 403);
  check('a code nobody opened is not found', (await S.call(T.access, 'GET', { who: ANN, query: '?code=ZZZZ' })).status === 404);
  check('a malformed code is refused before any room is asked', (await S.call(T.access, 'GET', { who: ANN, query: '?code=Q0O1' })).status === 400);

  check('join is a WebSocket or nothing', (await S.call(T.join, 'GET', { who: ANN, query: `?code=${code}` })).status === 426);
  check('a player cannot join as the GM', (await S.call(T.join, 'GET', { who: ANN, query: `?code=${code}&as=gm`, headers: up })).status === 403);
  check('someone with no character cannot join at all', (await S.call(T.join, 'GET', { who: CARL, query: `?code=${code}&as=display`, headers: up })).status === 403);

  const joined = await S.call(T.join, 'GET', { who: ANN, query: `?code=${code}`, headers: { ...up, 'X-Table-Role': 'gm', 'X-Table-Characters': '[{"id":"21","name":"Rusty"}]' } });
  const ann = S.socketOf(code);
  check('a player joins as a player', joined.status === 200 && ann?.deserializeAttachment()?.role === 'player');
  check('with their own characters, from D1', JSON.stringify(ann.deserializeAttachment().characters.map((c) => c.id).sort()) === '["11","12"]');
  check('and a role or character list the browser sent is thrown away', ann.deserializeAttachment().role === 'player'
    && !ann.deserializeAttachment().characters.some((c) => c.id === '21'));
  await S.call(T.join, 'GET', { who: BEN, query: `?code=${code}`, headers: up });
  const ben = S.socketOf(code);
  await S.call(T.join, 'GET', { who: GM, query: `?code=${code}&as=gm`, headers: up });
  const gm = S.socketOf(code);
  await S.call(T.join, 'GET', { who: GM, query: `?code=${code}&as=display`, headers: up });
  const tv = S.socketOf(code);
  check('the GM joins as the GM, and the TV under the GM\'s login as the display',
    gm.deserializeAttachment().role === 'gm' && tv.deserializeAttachment().role === 'display');

  const rollAs = (who, id, note, visibility) => S.call(T.roll, 'POST', { who, body: { character_id: id, note, visibility } });
  check('a sheet roll from an unseated character is not carried', (await rollAs(ANN, 11, 'Climb: 40 vs 60% — pass')).body?.seated === false);
  check('the sheet can ask whether it is seated',
    (await S.call(T.seat, 'GET', { who: BEN, query: '?character_id=21' })).body?.seated === true
    && (await S.call(T.seat, 'GET', { who: ANN, query: '?character_id=11' })).body?.seated === false);
  await say(S.rooms.get(code).room, ann, { type: 'seat', characterId: '11' });
  check('nobody can send a roll for somebody else\'s character', (await rollAs(BEN, 11, 'x')).status === 404);
  check('nor for the GM\'s NPC', (await rollAs(GM, 90, 'x')).status === 404);

  for (const s of [gm, tv, ann, ben]) s.clear();
  const sheet = await rollAs(ANN, 11, 'Strike: d20 14+3 = 17', 'gm');
  check('a seated sheet roll To GM is carried', sheet.body?.seated === true);
  check('to the GM and its roller only', rollsOn(gm).length === 1 && rollsOn(ann).length === 1 && !ben.raw.length && !tv.raw.length);
  for (const s of [gm, tv, ann, ben]) s.clear();
  await say(S.rooms.get(code).room, gm, { type: 'roll', kind: 'dice', expr: 'd100', label: 'Wandering monster', visibility: 'secret' });
  check('a GM-only roll through the routes reaches the GM alone',
    rollsOn(gm).length === 1 && !ann.raw.length && !ben.raw.length && !tv.raw.length);
  await rollAs(BEN, 21, 'Prowl: 30 vs 45% — pass', 'all');

  check('a player cannot close the table', (await S.call(T.close, 'POST', { who: ANN, body: { campaign_id: 1 } })).status === 403);
  const closed = await S.call(T.close, 'POST', { who: GM, body: { campaign_id: 1 } });
  check('the GM closes it and the feed is saved', closed.body?.saved === true && closed.body?.roll_count === 3, JSON.stringify(closed.body));
  const row = S.sqlite.prepare('SELECT * FROM table_sessions').get();
  check('the campaign\'s row holds the whole feed, GM-only included',
    row.closed_at && row.closed_reason === 'gm' && JSON.parse(row.feed).some((r) => r.visibility === 'secret') && row.roll_count === 3);
  check('the room is emptied only after', S.rooms.get(code).storage.map.size === 0);
  check('every screen was told', [gm, tv, ann, ben].every((s) => s.messages.some((m) => m.type === 'closed')));
  check('the campaign no longer has a table open', (await S.call(T.status, 'GET', { who: ANN, query: '?campaign_id=1' })).body?.open === false);
  check('and the old code joins nothing', (await S.call(T.access, 'GET', { who: ANN, query: `?code=${code}` })).status === 404);

  const read = async (who) => (await S.call(T.sessions, 'GET', { who, query: '?campaign_id=1' })).body?.sessions?.[0]?.feed ?? [];
  const texts = (feed) => feed.map((r) => r.text).join(' | ');
  check('after Close the GM reads the whole feed back in the campaign', (await read(GM)).length === 3, texts(await read(GM)));
  check('its roller reads back their To GM roll and the public one',
    (await read(ANN)).length === 2 && !texts(await read(ANN)).includes('Wandering monster'));
  check('another player reads back the public roll only', (await read(BEN)).length === 1 && texts(await read(BEN)).includes('Prowl'));
  check('someone outside the campaign reads nothing', (await S.call(T.sessions, 'GET', { who: CARL, query: '?campaign_id=1' })).status === 403);
  check('no email is in a read-back', !JSON.stringify(await read(GM)).includes('@'));

  // Abandoned: the room closes itself, the campaign page saves it.
  const second = (await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } })).body.code;
  await rollAs(BEN, 21, 'never seated', 'all');
  await S.rooms.get(second).room.alarm();
  const st = await S.call(T.status, 'GET', { who: GM, query: '?campaign_id=1' });
  check('a table that closed itself shows as open-but-closed to the campaign page', st.body?.open === true && st.body?.room === 'closed', JSON.stringify(st.body));
  const third = await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } });
  check('opening a new table first saves the abandoned one', third.body?.code && third.body.code !== second
    && S.sqlite.prepare("SELECT count(*) AS n FROM table_sessions WHERE closed_reason = 'idle'").get().n === 1);
  check('one campaign never has two open tables',
    S.sqlite.prepare('SELECT count(*) AS n FROM table_sessions WHERE closed_at IS NULL').get().n === 1);
  let refused = false;
  try { S.sqlite.exec(`INSERT INTO table_sessions (campaign_id, code, opened_by) VALUES (1, 'ABCD', '${GM}')`); } catch { refused = true; }
  check('the partial unique index refuses a second open table', refused);

  // A Marvel code is not Palladium's to answer.
  S.sqlite.exec(`INSERT INTO msh_campaigns (id, name, gm_email) VALUES (5, 'Avengers', '${GM}')`);
  S.sqlite.exec(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES ('h1', '${BEN}', 'Nightfox', '{}', '{}')`);
  S.sqlite.exec(`INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by) VALUES (5, 'h1', 1, '${BEN}')`);
  const M = {};
  for (const a of ['open', 'access', 'close', 'sessions']) M[a] = await S.route(`marvel-heroes/table/${a}.js`);
  const mcode = (await S.call(M.open, 'POST', { who: GM, body: { campaign_id: 5 } })).body?.code;
  check('a Marvel GM opens a Marvel table', validCode(mcode));
  check('Palladium\'s routes do not answer for a Marvel code', (await S.call(T.access, 'GET', { who: BEN, query: `?code=${mcode}` })).status === 404);
  check('the lookup sends the page to Marvel', (await S.call(lookup, 'GET', { who: BEN, query: `?code=${mcode}` })).body?.game === 'marvel');
  const mAccess = await S.call(M.access, 'GET', { who: BEN, query: `?code=${mcode}` });
  check('a hero\'s owner sits at the Marvel table with that hero', mAccess.body?.characters?.[0]?.name === 'Nightfox', JSON.stringify(mAccess.body));
  check('Marvel\'s close saves to its own table',
    (await S.call(M.close, 'POST', { who: GM, body: { campaign_id: 5 } })).body?.saved === true
    && S.sqlite.prepare('SELECT count(*) AS n FROM msh_table_sessions WHERE closed_at IS NOT NULL').get().n === 1);
}

section('the table routes: the schema files agree with the migrations');
{
  const pal = readFileSync(join(repoRoot, 'db', 'schema.sql'), 'utf8');
  const msh = readFileSync(join(repoRoot, 'db', 'schema-marvel.sql'), 'utf8');
  const mig = readFileSync(join(repoRoot, 'db', 'migrations', '088-table-sessions.sql'), 'utf8');
  const mmig = readFileSync(join(repoRoot, 'db', 'migrations', 'marvel', '089-msh-table-sessions.sql'), 'utf8');
  const cols = (sql) => sql.split('\n').map((l) => l.replace(/--.*$/, '').trim()).filter(Boolean).join(' ');
  check('schema.sql creates table_sessions as migration 088 does',
    cols(createOf(pal, 'table_sessions')) === cols(createOf(mig, 'table_sessions')));
  check('schema-marvel.sql creates msh_table_sessions as migration 089 does',
    cols(createOf(msh, 'msh_table_sessions')) === cols(createOf(mmig, 'msh_table_sessions')));
  check('each schema file creates the one-open-table index',
    pal.includes('idx_table_sessions_one_open') && msh.includes('idx_msh_table_sessions_one_open'));
}

summary();
