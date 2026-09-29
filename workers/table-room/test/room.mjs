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
import { imageRef, mayView, mayFetch, sameImage } from '../src/showing.js';
import { parseExpression, rollExpression, rollFeat } from '../src/dice.js';
import { feat } from '../src/marvel.js';
import { initView, emptyInit, HIDDEN_NAME } from '../src/initiative.js';
import { orderRolled as orderPalladium } from '../src/palladium.js';
import { rollInitiative as marvelR25 } from '../../../apps/marvel-heroes/js/initiative.js';
import { rng } from '../../../apps/marvel-heroes/js/dice.js';
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

// ── Pictures: who may look, and who may fetch ────────────────────────────────

section('the table: who may look at the picture on the table');
{
  const pic = imageRef('image', '42');
  const gm = { role: 'gm', email: GM };
  const tv = { role: 'display', email: GM };
  const seated = { role: 'player', email: ANN, seat: { id: '11', name: 'Vex' } };
  const choosing = { role: 'player', email: BEN, seat: null };
  check('a ref is a known kind and a row id, or nothing',
    JSON.stringify(pic) === '{"kind":"image","id":"42"}' && imageRef('city', 7)?.id === '7'
    && !imageRef('portrait', 1) && !imageRef('image', '0') && !imageRef('image', '1 OR 1=1') && !imageRef('image', ''));
  check('the GM, the TV and a seated player are shown it; a player still choosing is not',
    mayView(gm) && mayView(tv) && mayView(seated) && !mayView(choosing) && !mayView(null));
  check('a seated player may fetch the picture that is on the table', mayFetch([seated], pic, ANN, pic));
  check('not before anything is shown', !mayFetch([seated], null, ANN, pic));
  check('not a different picture', !mayFetch([seated], pic, ANN, imageRef('image', '43')) && !mayFetch([seated], pic, ANN, imageRef('city', '42')));
  check('not someone who is not at this table', !mayFetch([seated, gm], pic, BEN, pic));
  check('not a player who has not sat down', !mayFetch([choosing], pic, BEN, pic));
  check('and not with no email at all', !mayFetch([{ ...seated, email: undefined }], pic, undefined, pic));
  check('two refs name one picture when kind and id agree', sameImage({ kind: 'image', id: 42 }, pic) && !sameImage(pic, null));
}

section('the table: Show and Clear in the room');
{
  const t = await openTable();
  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  const bad = await post(t.room, '/show', { kind: 'portrait', id: 1 });
  check('the room refuses a ref it does not know', bad.status === 400 && [t.gm, t.tv, t.ann, t.ben].every((s) => !s.raw.length));
  const shown = await (await post(t.room, '/show', { kind: 'image', id: 42, caption: 'The bridge at dusk' })).json();
  check('a show is kept', shown.shown?.kind === 'image' && shown.shown?.id === '42' && t.storage.map.get('shown')?.caption === 'The bridge at dusk');
  const shows = (s) => s.messages.filter((m) => m.type === 'show');
  check('it reaches the GM, the TV and a seated player',
    [t.gm, t.tv, t.ben].every((s) => shows(s).length === 1 && shows(s)[0].shown.caption === 'The bridge at dusk'));
  check('and not a player still choosing a character', t.ann.raw.length === 0, everything(t.ann));
  const may = async (email, kind, id) => (await (await get(t.room, `/may-fetch?email=${encodeURIComponent(email)}&kind=${kind}&id=${id}`)).json()).allowed;
  check('the room lets a seated player fetch it', await may(BEN, 'image', 42));
  check('and not the player still choosing, or another picture', !(await may(ANN, 'image', 42)) && !(await may(BEN, 'image', 41)));
  await say(t.room, t.ann, { type: 'seat', characterId: '11' });
  check('sitting down brings the picture with the state', t.ann.messages.filter((m) => m.type === 'state').at(-1)?.shown?.id === '42' && await may(ANN, 'image', 42));
  check('the shown picture comes back on /shown', (await (await get(t.room, '/shown')).json()).shown?.id === '42');

  const ann2 = new FakeSocket('ann2');
  await t.room.connect(ann2, { role: 'player', email: ANN, name: '', characters: [{ id: '11', name: 'Vex' }] });
  await say(t.room, ann2, { type: 'hello' });
  check('a phone that reconnects is told what is on the table', ann2.messages.find((m) => m.type === 'state')?.shown?.id === '42');

  for (const s of [t.gm, t.tv, t.ann, t.ben]) s.clear();
  await post(t.room, '/clear');
  check('Clear reaches every screen that was shown it', [t.gm, t.tv, t.ann, t.ben].every((s) => s.messages.some((m) => m.type === 'clear')));
  check('and after it nobody may fetch the picture', !(await may(BEN, 'image', 42)) && !(await may(GM, 'image', 42)));
  check('and nothing is kept', !t.storage.map.has('shown') && (await (await get(t.room, '/shown')).json()).shown === null);

  await post(t.room, '/show', { kind: 'city', id: 3, caption: 'Tolkeen' });
  t.ben.close(); await t.room.webSocketClose(t.ben);
  check('a player who leaves the table can no longer fetch it', !(await may(BEN, 'city', 3)) && await may(ANN, 'city', 3));
  await post(t.room, '/close', { reason: 'gm' });
  check('closing the table drops the picture', !t.storage.map.has('shown') && !(await may(ANN, 'city', 3)));
  check('and a closed table shows nothing more', (await post(t.room, '/show', { kind: 'image', id: 1 })).status === 410);
  const closedFeed = await (await get(t.room, '/feed')).json();
  check('showing left nothing in the feed the campaign saves', !JSON.stringify(closedFeed).includes('Tolkeen'));
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
  check('a FEAT names its colour as a capitalised word', /— (White|Green|Yellow|Red)$/.test(f.text), f.text);
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
  // imported_classes, because a player's initiative numbers are derived
  // through the class, as the sheet derives them (combat-numbers.js).
  for (const t of ['campaign_entries', 'campaign_images', 'cities', 'imported_classes']) sqlite.exec(createOf(pal, t));
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
  // R2, as far as the image routes use it: get(key) -> { body, httpMetadata }.
  const objects = new Map();
  const MEDIA = {
    objects,
    get: async (key) => (objects.has(key)
      ? { body: objects.get(key).body, httpMetadata: { contentType: objects.get(key).type } } : null),
  };
  const env = { DB: D1, DB_MARVEL: D1, TABLE_ROOM, MEDIA };
  const route = (p) => import(new URL(`../../../functions/api/${p}`, import.meta.url));
  const call = async (mod, method, { who, query = '', body, headers = {}, params = {} } = {}) => {
    const h = { 'Cf-Access-Authenticated-User-Email': who, ...headers };
    if (body !== undefined) h['Content-Type'] = 'application/json';
    const request = new Request(`https://nates-workshop.pages.dev/api/x${query}`,
      { method, headers: h, body: body === undefined ? undefined : JSON.stringify(body) });
    const handler = mod[`onRequest${method[0]}${method.slice(1).toLowerCase()}`];
    const res = await handler({ request, env, params });
    const text = await res.text();
    let json = null;
    try { json = JSON.parse(text); } catch { json = null; }
    return { status: res.status, body: json, text, headers: res.headers };
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

// ── Pictures through the routes: the design's "done when" ────────────────────
//
// A map is previewed, shown, paged past and cleared, and a player's phone
// cannot load it before Show or after Clear. Previewing and paging happen in
// Present mode and send nothing (rendered-ui.mjs holds that); what this runs
// is every request a phone or the TV can make, at each step.

section('the table routes: a picture is fetched only while it is on the table');
{
  const S = await standIn();
  const DAN = 'dan@example.com';
  const CARL = 'carl@example.com';
  S.sqlite.exec(`INSERT INTO campaigns (id, name, system, gm_email) VALUES (1, 'Chi-Town', 'rifts', '${GM}'), (2, 'Elsewhere', 'rifts', '${GM}')`);
  const pc = (id, email, name, camp = 1) => S.sqlite.exec(
    `INSERT INTO characters (id, campaign_id, player_email, name, class_id, kind) VALUES (${id}, ${camp}, '${email}', '${name}', 'x', 'pc')`);
  pc(11, ANN, 'Vex'); pc(21, BEN, 'Dog Boy Rusty'); pc(31, DAN, 'Absent Friend');
  const img = (id, camp, caption) => {
    S.sqlite.exec(`INSERT INTO campaign_images (id, campaign_id, r2_key, content_type, caption, created_by)
      VALUES (${id}, ${camp}, 'campaigns/${camp}/${id}.png', 'image/png', ${caption ? `'${caption}'` : 'NULL'}, '${GM}')`);
    S.env.MEDIA.objects.set(`campaigns/${camp}/${id}.png`, { body: `PNG-BYTES-${id}`, type: 'image/png' });
  };
  img(1, 1, 'The Coalition map'); img(2, 1, 'The next map'); img(9, 2, 'Another campaign');
  const city = {
    overview: { name: 'Tolkeen' },
    map: {
      size: 1000, outline: [[0, 0], [1000, 0], [1000, 1000], [0, 1000]], roads: [], gates: [],
      districts: [{ id: 'd1', name: 'Old Town', polygon: [[0, 0], [500, 0], [500, 500]], label: [200, 200] }],
      pins: [{ id: 'p1', label: 'Wizard Tower', kind: 'place', district: 'd1', at: [100, 100] },
        { id: 'p2', label: 'SECRET-LAIR', kind: 'place', district: 'd1', at: [300, 300] }],
    },
    reveal: { p1: true },
    public: { p1: 'Tall & <crooked>.', d1: 'Cobbled.' },
    npcs: [{ name: 'SECRET-VILLAIN' }],
  };
  S.sqlite.prepare(`INSERT INTO cities (id, campaign_id, name, system, data, show_map, created_by) VALUES (3, 1, 'Tolkeen', 'rifts', ?, 0, ?)`)
    .run(JSON.stringify(city), GM);

  const T = {};
  for (const a of ['open', 'join', 'close', 'status', 'show', 'clear', 'image']) T[a] = await S.route(`character-creator/table/${a}.js`);
  const campaignImage = await S.route('character-creator/campaigns/[id]/images/[imageId].js');
  const up = { Upgrade: 'websocket' };
  const code = (await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } })).body.code;
  for (const [who, as] of [[ANN, 'player'], [BEN, 'player'], [GM, 'gm'], [GM, 'display'], [CARL, 'player']]) {
    await S.call(T.join, 'GET', { who, query: `?code=${code}&as=${as}`, headers: up });
  }
  const fetchAs = (who, kind, id, c = code) => S.call(T.image, 'GET', { who, query: `?code=${c}&kind=${kind}&id=${id}` });
  const show = (who, kind, id) => S.call(T.show, 'POST', { who, body: { campaign_id: 1, kind, id } });
  const socks = S.rooms.get(code).sockets;

  // Before Show.
  check('before Show, a seated player\'s fetch is not found', (await fetchAs(ANN, 'image', 1)).status === 404);
  check('and the TV\'s', (await fetchAs(GM, 'image', 1)).status === 404);
  check('a player cannot show a picture', (await show(ANN, 'image', 1)).status === 403);
  check('the GM cannot show another campaign\'s picture', (await show(GM, 'image', 9)).status === 404);
  check('or one that does not exist', (await show(GM, 'image', 99)).status === 404 && (await show(GM, 'portrait', 1)).status === 404);
  check('and nothing was put on the table by any of that', (await S.call(T.status, 'GET', { who: GM, query: '?campaign_id=1' })).body.shown === null);

  // Show.
  const shown = await show(GM, 'image', 1);
  check('the GM shows a picture, captioned from D1', shown.status === 200 && shown.body.shown?.caption === 'The Coalition map', JSON.stringify(shown.body));
  check('every screen at the table is told', socks.every((s) => s.messages.some((m) => m.type === 'show' && m.shown.id === '1')));
  const got = await fetchAs(ANN, 'image', 1);
  check('a seated player\'s phone loads it', got.status === 200 && got.text === 'PNG-BYTES-1' && got.headers.get('Content-Type') === 'image/png');
  check('and is told not to keep it', got.headers.get('Cache-Control') === 'no-store');
  check('the TV loads it', (await fetchAs(GM, 'image', 1)).status === 200);
  check('a different picture is not found', (await fetchAs(ANN, 'image', 2)).status === 404);
  check('another campaign\'s picture is not found, even by the same id route', (await fetchAs(ANN, 'image', 9)).status === 404);
  check('a player of the campaign who is not at the table cannot load it', (await fetchAs(DAN, 'image', 1)).status === 404);
  check('nor can someone outside the campaign, and they are told not found, not forbidden',
    (await fetchAs(CARL, 'image', 1)).status === 404);
  check('nor through a code that is not this table', (await fetchAs(ANN, 'image', 1, 'ZZZZ')).status === 404);
  check('showing does not reveal: the campaign\'s own image route still hides it from a player',
    (await S.call(campaignImage, 'GET', { who: ANN, params: { id: '1', imageId: '1' } })).status === 404
    && S.sqlite.prepare('SELECT revealed_at FROM campaign_images WHERE id = 1').get().revealed_at === null);
  check('the GM\'s status says what is on the table', (await S.call(T.status, 'GET', { who: GM, query: '?campaign_id=1' })).body.shown?.id === '1');
  check('a player\'s status does not', !('shown' in (await S.call(T.status, 'GET', { who: ANN, query: '?campaign_id=1' })).body));

  // Paged past: the GM shows the next one; the first is gone from the table.
  await show(GM, 'image', 2);
  check('after the next picture is shown, the first is not found', (await fetchAs(ANN, 'image', 1)).status === 404);
  check('and the next one loads', (await fetchAs(ANN, 'image', 2)).status === 200);

  // Clear.
  const cleared = await S.call(T.clear, 'POST', { who: GM, body: { campaign_id: 1 } });
  check('the GM clears the table', cleared.status === 200 && cleared.body.shown === null);
  check('a player cannot', (await S.call(T.clear, 'POST', { who: ANN, body: { campaign_id: 1 } })).status === 403);
  check('after Clear the phone\'s fetch is not found', (await fetchAs(ANN, 'image', 2)).status === 404);
  check('nor the TV\'s', (await fetchAs(GM, 'image', 2)).status === 404);

  // A city, drawn from the players' view only.
  await show(GM, 'city', 3);
  const map = await fetchAs(BEN, 'city', 3);
  check('a city map loads as an SVG', map.status === 200 && /^image\/svg\+xml/.test(map.headers.get('Content-Type')) && map.text.includes('<svg'));
  check('with its revealed pin and the players\' lines, escaped',
    map.text.includes('Wizard Tower') && map.text.includes('Tall &#38; &#60;crooked&#62;.') && map.text.includes('Cobbled.'));
  check('and nothing the players\' view leaves out', !map.text.includes('SECRET-LAIR') && !map.text.includes('SECRET-VILLAIN'));
  check('a city\'s map is served as an image that may run nothing',
    /default-src 'none'/.test(map.headers.get('Content-Security-Policy')) && map.headers.get('X-Content-Type-Options') === 'nosniff');
  check('even though the city\'s map is not shown to players in the campaign', S.sqlite.prepare('SELECT show_map FROM cities WHERE id = 3').get().show_map === 0);

  // Close.
  await S.call(T.close, 'POST', { who: GM, body: { campaign_id: 1 } });
  check('after the table closes the map is not found', (await fetchAs(BEN, 'city', 3)).status === 404);
  check('and there is nothing to clear', (await S.call(T.clear, 'POST', { who: GM, body: { campaign_id: 1 } })).status === 404);
  const saved = S.sqlite.prepare('SELECT feed FROM table_sessions').get().feed;
  check('showing left no trace in the saved session', !saved.includes('Tolkeen') && !saved.includes('Coalition'));

  // Marvel: its own pictures, and no cities.
  S.sqlite.exec(`INSERT INTO msh_campaigns (id, name, gm_email) VALUES (5, 'Avengers', '${GM}')`);
  S.sqlite.exec(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES ('h1', '${BEN}', 'Nightfox', '{}', '{}')`);
  S.sqlite.exec(`INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by) VALUES (5, 'h1', 1, '${BEN}')`);
  S.sqlite.exec(`INSERT INTO msh_campaign_images (id, campaign_id, r2_key, content_type, caption, created_by)
    VALUES (7, 5, 'msh/campaigns/5/7.png', 'image/png', 'Avengers Mansion', '${GM}')`);
  S.env.MEDIA.objects.set('msh/campaigns/5/7.png', { body: 'MSH-PNG', type: 'image/png' });
  const M = {};
  for (const a of ['open', 'join', 'show', 'clear', 'image']) M[a] = await S.route(`marvel-heroes/table/${a}.js`);
  const mcode = (await S.call(M.open, 'POST', { who: GM, body: { campaign_id: 5 } })).body.code;
  await S.call(M.join, 'GET', { who: BEN, query: `?code=${mcode}`, headers: up });
  const mfetch = () => S.call(M.image, 'GET', { who: BEN, query: `?code=${mcode}&kind=image&id=7` });
  check('a Marvel hero\'s owner cannot load a picture before Show', (await mfetch()).status === 404);
  check('a Marvel table shows no city', (await S.call(M.show, 'POST', { who: GM, body: { campaign_id: 5, kind: 'city', id: 3 } })).status === 404);
  await S.call(M.show, 'POST', { who: GM, body: { campaign_id: 5, kind: 'image', id: 7 } });
  const mgot = await mfetch();
  check('and loads it once shown, from Marvel\'s own table', mgot.status === 200 && mgot.text === 'MSH-PNG');
  check('Palladium\'s image route does not answer for a Marvel table',
    (await S.call(T.image, 'GET', { who: BEN, query: `?code=${mcode}&kind=image&id=7` })).status === 404);
  await S.call(M.clear, 'POST', { who: GM, body: { campaign_id: 5 } });
  check('and not after Clear', (await mfetch()).status === 404);
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

// ── The two clients: the character sheet and the campaign page ───────────────

section('the table clients: the sheet sends the log\'s own note, unchanged');
{
  const sheet = readFileSync(join(repoRoot, 'apps', 'character-sheet', 'sheet.js'), 'utf8').replace(/\r\n/g, '\n');
  const body = (name) => {
    const at = sheet.indexOf(`function ${name}(`);
    return at < 0 ? '' : sheet.slice(at, sheet.indexOf('\n}\n', at));
  };
  // endSession counts "— pass" and "— fail" out of the logged notes, so the
  // table must carry that same string, and the log must go on getting it.
  check('a logged roll is persisted as rollNote() wrote it', /persistRoll\(rollNote\(r\)\)/.test(body('recordRoll')));
  check('and persistRoll hands that same note to the table and to the log',
    /sendToTable\(note\)/.test(body('persistRoll')) && /postEvent\('roll', note,/.test(body('persistRoll')));
  check('sendToTable posts the note as given, and nothing else writes it',
    /\{ character_id: Number\(id\), note, visibility: C\.tableVis \}/.test(body('sendToTable')));
  check('a roll To the GM at the table is private in the log',
    /C\.table\?\.seated && C\.tableVis === 'gm'/.test(body('persistRoll')));
  check('rollNote still writes the verdict endSession counts', /— \$\{r\.ok \? 'pass' : 'fail'\}/.test(body('rollNote')));
}

section('the table clients: the campaign page panel');
{
  const calls = [];
  const replies = {};
  const makePage = (reply) => {
    for (const k of Object.keys(replies)) delete replies[k];
    Object.assign(replies, reply);
    calls.length = 0;
    const g = {
      ctx: {
        campaignId: 7,
        api: async (path, opts) => {
          calls.push(`${opts?.method || 'GET'} ${path}`);
          const key = Object.keys(replies).find((k) => path.startsWith(k));
          const r = replies[key];
          if (r instanceof Error) throw r;
          return typeof r === 'function' ? r() : r;
        },
        ui: { esc: (v) => String(v ?? '').replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`), toast: () => {}, modal: async () => true },
        reload: async () => {},
      },
      json: (method, body) => ({ method, body: JSON.stringify(body) }),
    };
    globalThis.mcCampaign = g;
    return g;
  };
  const src = readFileSync(join(repoRoot, 'shared', 'js', 'campaign', 'table.js'), 'utf8');
  const loadModule = () => new Function(src)();
  const feed = [{ id: 1, visibility: 'secret', text: '<img src=x onerror=alert(1)>', by: { name: 'GM' } }];

  let M = makePage({ 'table/status': { open: false, is_gm: true }, 'table/sessions': { sessions: [{ id: 1, opened_at: '2026-09-29 20:00', closed_reason: 'gm', feed }] } });
  loadModule();
  await M.table.load();
  const gmHtml = M.table.html();
  check('the GM is offered Open the table', gmHtml.includes('mcCampaign.table.open()'));
  check('a saved roll is escaped, and tagged by who could see it', gmHtml.includes('&#60;img') && !gmHtml.includes('<img') && gmHtml.includes('GM only'));

  M = makePage({ 'table/status': { open: false, is_gm: false }, 'table/sessions': { sessions: [] } });
  loadModule();
  await M.table.load();
  check('a player is not offered Open the table', !M.table.html().includes('table.open()'));

  M = makePage({ 'table/status': { open: true, code: 'QK4T', room: 'open', is_gm: false }, 'table/sessions': { sessions: [] } });
  loadModule();
  await M.table.load();
  const live = M.table.html();
  check('an open table shows its code and the way in, and a player cannot close it',
    live.includes('QK4T') && live.includes('/apps/table/?code=QK4T') && !live.includes('table.close()'));

  M = makePage({ 'table/status': { open: true, code: 'QK4T', room: 'closed', is_gm: true }, 'table/close': { saved: true, roll_count: 4, reason: 'idle' }, 'table/sessions': { sessions: [] } });
  loadModule();
  await M.table.load();
  check('a table that closed itself is saved on the GM\'s visit', calls.includes('POST table/close') && /4 rolls are saved/.test(M.table.html()), calls.join(' | '));

  M = makePage({ 'table/status': { open: true, code: 'QK4T', room: 'closed', is_gm: false }, 'table/close': { saved: true }, 'table/sessions': { sessions: [] } });
  loadModule();
  await M.table.load();
  check('and never on a player\'s', !calls.some((c) => c.includes('table/close')));

  const off = new Error('not wired'); off.status = 503;
  M = makePage({ 'table/status': off, 'table/sessions': { sessions: [] } });
  loadModule();
  await M.table.load();
  check('a deployment without the room shows no panel at all', M.table.html() === '');
  delete globalThis.mcCampaign;

  const html = readFileSync(join(repoRoot, 'apps', 'table', 'index.html'), 'utf8');
  check('the table page links the RPG suite\'s two stylesheets in order',
    html.indexOf('/shared/styles.css') > -1 && html.indexOf('/shared/styles.css') < html.indexOf('/apps/character-creator/styles.css'));
  const client = readFileSync(join(repoRoot, 'apps', 'table', 'table.js'), 'utf8');
  check('the table page asks for a role and never filters rolls itself',
    /table\/join\?code=/.test(client) && !/canSee|visibility === 'secret'/.test(client));
  check('a phone\'s Roll initiative sends no number: the room adds the bonus from D1',
    /case 'mine-roll': return send\(\{ type: 'init\.roll' \}\);/.test(client));
  check('the page never masks a hidden NPC itself: it draws what the room sent',
    !/HIDDEN_NAME|'\?\?\?'/.test(client));
  // The GM's picture picker on the table page. Drawn for the GM alone, so a
  // player's page never asks the GM-only picture lists; and it shows through
  // the table/show ROUTE, which checks the picture is this campaign's, never by
  // a socket message the room would have to take on trust.
  check('the table page\'s picture picker is the GM\'s alone',
    /\$\{gm \? picsHtml\(\) : ''\}/.test(client) && /if \(gm\) wirePics\(\);/.test(client)
    && (client.match(/picsHtml\(\)/g) || []).length === 2);
  check('and it shows and clears through the table routes, never a socket message',
    /picPost\('show'/.test(client) && /picPost\('clear'/.test(client)
    && /\/table\/\$\{route\}/.test(client) && !/type: '(show|clear)'/.test(client));
  const camps = ['apps/campaign/index.html', 'apps/marvel-heroes/campaign/index.html']
    .map((f) => readFileSync(join(repoRoot, f), 'utf8'));
  check('both games\' campaign pages load the table panel', camps.every((h) => h.includes('/shared/js/campaign/table.js')));
}

// ── Initiative (phase 3) ─────────────────────────────────────────────────────
//
// The design's "done when": a four-character Palladium melee with mixed attack
// counts runs to its end with the right people skipped, and a Marvel round
// matches R25 on a fixed seed. Plus its two leaks that must not happen: a
// hidden NPC's name reaching a player or the TV, and "You're up" reaching the
// wrong phone.

// A room of one game with the GM, the TV and a phone per character, each
// character seated with its initiative numbers as the join would bring them.
async function initTable(game, cast) {
  const t = makeRoom();
  await post(t.room, '/init', { code: 'INIT', game, campaignId: 3, campaignName: 'The Fight', gmEmail: GM });
  t.gm = new FakeSocket('gm');
  t.tv = new FakeSocket('tv');
  await t.room.connect(t.gm, { role: 'gm', email: GM, name: 'GM', characters: [] });
  await t.room.connect(t.tv, { role: 'display', email: GM, name: 'Display', characters: [] });
  t.phones = {};
  for (const c of cast) {
    const ws = new FakeSocket(c.name);
    await t.room.connect(ws, { role: 'player', email: c.email, name: '', characters: [{ id: c.id, name: c.name, init: c.init }] });
    t.phones[c.name] = ws;
  }
  t.all = [t.gm, t.tv, ...Object.values(t.phones)];
  for (const s of t.all) await say(t.room, s, { type: 'hello' });
  // A queue of dice: each value is what random() returns next.
  t.dice = (...q) => { t.room.random = () => (q.length ? q.shift() : 0.5); };
  return t;
}

const lastInit = (ws) => ws.messages.filter((m) => m.type === 'init').at(-1)?.init
  ?? ws.messages.find((m) => m.type === 'state')?.init;
const nameOf = (init, id) => init?.entries.find((e) => e.id === id)?.name ?? null;
const errorsOn = (ws) => ws.messages.filter((m) => m.type === 'error').map((m) => m.message);

section('initiative: a Palladium melee runs out by attacks, once per pass');
{
  // d20 from random r is 1 + floor(r * 20): 0.7 -> 15, 0.65 -> 14, 0.55 -> 12, 0.3 -> 7.
  const cast = [
    { name: 'Vex', id: '11', email: ANN, init: { bonus: 3, attacks: 4 } },
    { name: 'Rusty', id: '21', email: BEN, init: { bonus: 1, attacks: 2 } },
    { name: 'Mox', id: '31', email: 'cal@example.com', init: { bonus: 0, attacks: 3 } },
    { name: 'Lark', id: '41', email: 'dee@example.com', init: { bonus: 2, attacks: 1 } },
  ];
  const t = await initTable('palladium', cast);
  const P = t.phones;
  check('a new table has an empty order in its state', lastInit(t.gm)?.entries.length === 0 && lastInit(P.Vex)?.turn === null);

  // Rolled in a scrambled order; each is slotted by its total as it arrives.
  t.dice(0.3); await say(t.room, P.Lark, { type: 'init.roll' });
  t.dice(0.65); await say(t.room, P.Rusty, { type: 'init.roll', bonus: 99, total: 99 });
  t.dice(0.7); await say(t.room, P.Vex, { type: 'init.roll' });
  t.dice(0.55); await say(t.room, P.Mox, { type: 'init.roll' });
  const order = lastInit(t.tv).entries;
  check('each player rolls d20 plus their own bonus, and the order is highest first',
    order.map((e) => `${e.name} ${e.total}`).join(', ') === 'Vex 18, Rusty 15, Mox 12, Lark 9', JSON.stringify(order));
  check('a bonus or total the phone sends is ignored', order.find((e) => e.name === 'Rusty').total === 15);
  const feedTexts = rollsOn(t.tv).map((r) => r.text);
  check('each initiative roll lands in the feed, for everyone', feedTexts.includes('Initiative: d20 15 +3 = 18') && feedTexts.length === 4, feedTexts.join(' | '));
  t.dice(0.99); await say(t.room, P.Vex, { type: 'init.roll' });
  check('a player rolls once a melee', errorsOn(P.Vex).at(-1) === 'You have rolled for this melee' && lastInit(t.gm).entries[0].total === 18);
  await say(t.room, P.Vex, { type: 'init.next' });
  check('a player cannot move the turn on', errorsOn(P.Vex).at(-1) === 'Only the GM moves the turn on' && lastInit(t.gm).turn === null);

  // Next, until the melee runs out. Record who is lit, and who got "You're up".
  const seen = [];
  let upRight = true;
  let deckRight = true;
  for (let press = 0; press < 11; press++) {
    for (const s of t.all) s.clear();
    await say(t.room, t.gm, { type: 'init.next' });
    const init = lastInit(t.tv);
    const now = nameOf(init, init.turn);
    seen.push(now ? `${now}@${init.pass}` : 'over');
    const upOn = Object.entries(P).filter(([, s]) => s.messages.some((m) => m.type === 'up')).map(([n]) => n);
    if (JSON.stringify(upOn) !== JSON.stringify(now ? [now] : [])) upRight = false;
    const deckOn = Object.entries(P).filter(([, s]) => s.messages.some((m) => m.type === 'deck')).map(([n]) => n);
    const deckName = nameOf(init, init.onDeck);
    if (JSON.stringify(deckOn) !== JSON.stringify(deckName && deckName !== now ? [deckName] : [])) deckRight = false;
    if (t.gm.messages.some((m) => m.type === 'up') || t.tv.messages.some((m) => m.type === 'up')) upRight = false;
  }
  check('the melee runs pass by pass, skipping whoever is out of attacks, to its end',
    seen.join(' ') === 'Vex@1 Rusty@1 Mox@1 Lark@1 Vex@2 Rusty@2 Mox@2 Vex@3 Mox@3 Vex@4 over', seen.join(' '));
  const spent = lastInit(t.gm).entries.map((e) => `${e.name} ${e.spent}/${e.attacks}`).join(', ');
  check('and every attack is spent, none twice', spent === 'Vex 4/4, Rusty 2/2, Mox 3/3, Lark 1/1', spent);
  check('"You\'re up" reached the phone of whoever was lit, and no other screen, every turn', upRight);
  check('"On deck" reached the next one\'s phone only', deckRight);
  check('the TV shows the melee is over', lastInit(t.tv).over === true && lastInit(t.tv).turn === null);
  await say(t.room, t.gm, { type: 'init.next' });
  check('a Next after the end says so', errorsOn(t.gm).at(-1) === 'The melee is over. Start a new one.');

  // A new melee keeps the order; a latecomer is slotted in by the roll.
  await say(t.room, t.gm, { type: 'init.newRound' });
  const m2 = lastInit(t.gm);
  check('New melee keeps the order and gives every attack back',
    m2.round === 2 && m2.entries.every((e) => e.rolled && e.spent === 0) && m2.entries[0].name === 'Vex');
  await say(t.room, t.gm, { type: 'init.add', kind: 'name', name: 'Ogre', bonus: 0, attacks: 2 });
  t.dice(0.8); await say(t.room, t.gm, { type: 'init.roll', all: true });
  await say(t.room, t.gm, { type: 'init.add', kind: 'name', name: 'Brute', bonus: 5, attacks: 1 });
  t.dice(0.45); await say(t.room, t.gm, { type: 'init.roll', all: true });
  const late = lastInit(t.gm).entries.map((e) => `${e.name} ${e.total}`).join(', ');
  check('a latecomer is slotted by their roll, and a tie goes to the higher bonus',
    late === 'Vex 18, Ogre 17, Brute 15, Rusty 15, Mox 12, Lark 9', late);
  check('the tie is tagged with what broke it, on both rows',
    ['Brute', 'Rusty'].every((n) => lastInit(t.gm).entries.find((e) => e.name === n).tags.includes('bonus')));

  // Mid-fight: a drag, a removal of whoever is up.
  const ids = Object.fromEntries(lastInit(t.gm).entries.map((e) => [e.name, e.id]));
  await say(t.room, t.gm, { type: 'init.move', id: ids.Lark, to: 0 });
  check('the GM drags a row', lastInit(t.tv).entries[0].name === 'Lark');
  await say(t.room, P.Rusty, { type: 'init.move', id: ids.Rusty, to: 0 });
  check('a player cannot', errorsOn(P.Rusty).at(-1) === 'Only the GM moves the order' && lastInit(t.tv).entries[0].name === 'Lark');
  await say(t.room, t.gm, { type: 'init.next' });
  for (const s of t.all) s.clear();
  await say(t.room, t.gm, { type: 'init.remove', id: ids.Lark });
  check('removing whoever is up passes the turn on', nameOf(lastInit(t.tv), lastInit(t.tv).turn) === 'Vex'
    && P.Vex.messages.some((m) => m.type === 'up'));
  await say(t.room, P.Vex, { type: 'init.remove', id: ids.Rusty });
  check('a player can take out only their own character', errorsOn(P.Vex).at(-1) === 'You can only take your own character out');
  await say(t.room, P.Rusty, { type: 'init.remove', id: ids.Rusty });
  check('and can take out their own', !lastInit(t.gm).entries.some((e) => e.name === 'Rusty'));
  await say(t.room, t.gm, { type: 'init.newRound', reroll: true });
  check('New melee, roll again, clears every roll', lastInit(t.gm).entries.every((e) => !e.rolled));
  await say(t.room, t.tv, { type: 'init.next' });
  check('the TV cannot run initiative', errorsOn(t.tv).at(-1) === 'The display cannot run initiative');
}

section('initiative: a Palladium tie goes to the bonus, then a re-roll among the tied');
{
  const q = [0.1, 0.9];
  const rows = [
    { id: 'a', total: 15, bonus: 2 }, { id: 'b', total: 15, bonus: 4 },
    { id: 'c', total: 15, bonus: 4 }, { id: 'd', total: 20, bonus: 0 },
  ];
  const out = orderPalladium(rows, () => q.shift());
  check('highest total, then higher bonus, then the tied roll again',
    out.map((r) => r.id).join('') === 'dcba', out.map((r) => `${r.id}:${r.rerolls}`).join(' '));
  check('only the still-tied re-roll', out.find((r) => r.id === 'a').rerolls.length === 0
    && out.find((r) => r.id === 'b').rerolls.join() === '3' && out.find((r) => r.id === 'c').rerolls.join() === '19');
  check('each row says what placed it', out.find((r) => r.id === 'c').tags.join() === 'bonus,re-roll'
    && out.find((r) => r.id === 'a').tags.join() === 'bonus' && out.find((r) => r.id === 'd').tags.length === 0);
}

section('initiative: a Marvel round is R25, from the Marvel app\'s own module');
{
  const t = await initTable('marvel', [{ name: 'Nightfox', id: 'h1', email: BEN, init: { agility: 30, talents: ['martial-arts-e'] } }]);
  await say(t.room, t.phones.Nightfox, { type: 'init.add' });
  const adds = [
    { kind: 'npc', ref: '4', name: 'Doom', agility: 40, talents: [] },
    { kind: 'name', name: 'Guard', agility: 30, talents: [] },
    { kind: 'name', name: 'Thug', agility: 10, talents: ['weapons-specialist'] },
  ];
  for (const a of adds) await say(t.room, t.gm, { type: 'init.add', ...a });
  const talentOf = Object.fromEntries(lastInit(t.gm).entries.map((e) => [e.name, e.talent]));
  check('a hero\'s own Talents, from the join, count; the room reads which ones from the app',
    talentOf.Nightfox === true && talentOf.Thug === true && talentOf.Doom === false, JSON.stringify(talentOf));
  const nf = lastInit(t.gm).entries.find((e) => e.name === 'Nightfox');
  await say(t.room, t.gm, { type: 'init.set', id: nf.id, applies: true });
  await say(t.room, t.phones.Nightfox, { type: 'init.roll', all: true });
  check('a player cannot roll the round', errorsOn(t.phones.Nightfox).at(-1) === 'The GM rolls the round');

  // The same combatants the room holds, handed straight to initiative.js.
  const combatants = () => lastInit(t.gm).entries.map((e) => ({ key: e.name, name: e.name, agility: e.agility, talent: e.talent, applies: e.applies }));
  const direct = (seed) => marvelR25(combatants(), rng(seed)).map((r) => `${r.key} ${r.roll}${r.rerolls.length ? `/${r.rerolls}` : ''} [${r.tags}]`).join(', ');
  const inRoom = () => lastInit(t.gm).entries.map((e) => `${e.name} ${e.roll}${e.rerolls.length ? `/${e.rerolls}` : ''} [${e.tags}]`).join(', ');
  let same = true;
  let last = '';
  for (const seed of [1, 42, 2026, 99991]) {
    const want = direct(seed);
    t.room.random = rng(seed);
    await say(t.room, t.gm, { type: 'init.roll', all: true });
    if (inRoom() !== want) { same = false; last = `seed ${seed}: room ${inRoom()} / R25 ${want}`; }
  }
  check('Roll the round orders exactly as initiative.js does on the same seed, four seeds', same, last);

  // Everyone rolls 51: the tie is R25's to break.
  t.dice(0.5, 0.5, 0.5, 0.5);
  await say(t.room, t.gm, { type: 'init.roll', all: true });
  check('a four-way tie: the applying Talent, then Agility number',
    inRoom() === 'Nightfox 51 [Talent], Doom 51 [Talent,Agility], Guard 51 [Talent,Agility], Thug 51 [Talent,Agility]', inRoom());
  check('the unticked Talent broke nothing', lastInit(t.gm).entries.find((e) => e.name === 'Thug').applies === false);

  const played = [];
  for (let i = 0; i < 4; i++) {
    await say(t.room, t.gm, { type: 'init.next' });
    played.push(nameOf(lastInit(t.gm), lastInit(t.gm).turn));
  }
  check('one pass through the order', played.join(' ') === 'Nightfox Doom Guard Thug', played.join(' '));
  check('"You\'re up" reached the hero\'s phone on the hero\'s turn', t.phones.Nightfox.messages.some((m) => m.type === 'up'));
  await say(t.room, t.gm, { type: 'init.next' });
  const r2 = lastInit(t.gm);
  check('then the round ends: round 2, nobody rolled, every Talent tick cleared',
    r2.round === 2 && r2.turn === null && r2.entries.every((e) => !e.rolled && !e.applies));
}

section('initiative: a hidden NPC\'s name reaches the GM alone');
{
  const t = await initTable('palladium', [
    { name: 'Vex', id: '11', email: ANN, init: { bonus: 3, attacks: 2 } },
    { name: 'Rusty', id: '21', email: BEN, init: { bonus: 1, attacks: 2 } },
  ]);
  const P = t.phones;
  await say(t.room, t.gm, { type: 'init.add', kind: 'npc', ref: '90', name: 'SECRET-OGRE', hidden: true, bonus: 2, attacks: 3 });
  await say(t.room, t.gm, { type: 'init.add', kind: 'npc', ref: '91', name: 'Open Goblin', bonus: 1, attacks: 2 });
  t.dice(0.9, 0.2); await say(t.room, t.gm, { type: 'init.roll', all: true });
  t.dice(0.5); await say(t.room, P.Vex, { type: 'init.roll' });
  const ogre = lastInit(t.gm).entries.find((e) => e.name === 'SECRET-OGRE');
  await say(t.room, t.gm, { type: 'init.move', id: ogre.id, to: 1 });
  await say(t.room, t.gm, { type: 'init.set', id: ogre.id, applies: true });
  for (let i = 0; i < 4; i++) await say(t.room, t.gm, { type: 'init.next' });
  // A phone that reconnects gets the whole order in `state`.
  const again = new FakeSocket('again');
  await t.room.connect(again, { role: 'player', email: BEN, name: '', characters: [{ id: '21', name: 'Rusty' }] });
  await say(t.room, again, { type: 'hello' });
  const tv2 = new FakeSocket('tv2');
  await t.room.connect(tv2, { role: 'display', email: GM, name: 'Display', characters: [] });
  await say(t.room, tv2, { type: 'hello' });

  const leak = [t.tv, P.Vex, P.Rusty, again, tv2].filter((s) => /SECRET-OGRE|"ref":"90"/.test(everything(s)));
  check('in no message, state included, does a player or the TV receive its name or sheet',
    !leak.length, leak.map((s) => s.label).join(', '));
  check('they see it as ??? in its place in the order',
    lastInit(P.Vex).entries[1]?.name === HIDDEN_NAME && lastInit(tv2).entries.some((e) => e.name === HIDDEN_NAME));
  check('with nothing but its place: no roll, no bonus, no attacks',
    JSON.stringify(Object.keys(lastInit(again).entries.find((e) => e.hidden)).sort()) === '["hidden","id","kind","name","rolled"]');
  check('its initiative roll went to the GM alone', rollsOn(t.gm).some((r) => /SECRET-OGRE/.test(r.text))
    && rollsOn(P.Vex).every((r) => !/SECRET-OGRE/.test(r.text)));
  check('its turn lights ??? for the others and the GM sees who', lastInit(t.gm).entries.some((e) => e.name === 'SECRET-OGRE' && e.spent > 0));
  check('a visible NPC is visible to all', /Open Goblin/.test(everything(P.Vex)) && /Open Goblin/.test(everything(t.tv)));
  check('the view masks by role, not by page', initView({ ...emptyInit(), entries: [{ id: 'x', kind: 'npc', ref: '9', name: 'Z', hidden: true, rolled: true, total: 12 }] }, { role: 'display' }).entries[0].name === HIDDEN_NAME);
  await say(t.room, P.Vex, { type: 'init.set', id: ogre.id, hidden: false });
  check('a player cannot unhide it', errorsOn(P.Vex).at(-1) === 'Only the GM changes a row' && !/SECRET-OGRE/.test(everything(P.Vex)));
  await say(t.room, t.gm, { type: 'init.set', id: ogre.id, hidden: false });
  check('when the GM unhides it, everyone sees it (so the check above can see a name)', /SECRET-OGRE/.test(everything(P.Vex)) && /SECRET-OGRE/.test(everything(t.tv)));
  await say(t.room, t.gm, { type: 'init.set', id: lastInit(t.gm).entries.find((e) => e.name === 'Vex').id, hidden: true });
  check('a player\'s character cannot be hidden', errorsOn(t.gm).at(-1) === 'A player\'s character cannot be hidden');
  await post(t.room, '/close', { reason: 'gm' });
  check('closing the table drops the order', !t.storage.map.has('init'));
}

section('initiative routes: a player\'s numbers come from D1, never the page');
{
  const S = await standIn();
  S.sqlite.exec(`INSERT INTO campaigns (id, name, system, gm_email) VALUES (1, 'Chi-Town', 'rifts', '${GM}')`);
  const pc = (id, email, name, kind, combat) => S.sqlite.prepare(
    `INSERT INTO characters (id, campaign_id, player_email, name, class_id, kind, combat) VALUES (?, 1, ?, ?, 'x', ?, ?)`)
    .run(id, email, name, kind, JSON.stringify(combat));
  pc(11, ANN, 'Vex', 'pc', { initiative: 3, attacks: 4 });
  pc(21, BEN, 'Dog Boy Rusty', 'pc', {});
  pc(90, GM, 'The Villain', 'npc', { initiative: 5, attacks: 3 });
  const T = {};
  for (const a of ['open', 'join', 'roster']) T[a] = await S.route(`character-creator/table/${a}.js`);
  const up = { Upgrade: 'websocket' };
  const code = (await S.call(T.open, 'POST', { who: GM, body: { campaign_id: 1 } })).body.code;
  await S.call(T.join, 'GET', { who: ANN, query: `?code=${code}`, headers: { ...up, 'X-Table-Characters': encodeURIComponent('[{"id":"11","name":"Vex","init":{"bonus":40,"attacks":9}}]') } });
  const ann = S.socketOf(code);
  check('a seat carries the sheet\'s initiative bonus and attacks, derived on the server',
    JSON.stringify(ann.deserializeAttachment().seat.init) === '{"bonus":3,"attacks":4}', JSON.stringify(ann.deserializeAttachment().seat));
  await S.call(T.join, 'GET', { who: BEN, query: `?code=${code}`, headers: up });
  const ben = S.socketOf(code);
  check('a character with nothing typed over the sheet gets the base: +0 and two attacks',
    JSON.stringify(ben.deserializeAttachment().seat.init) === '{"bonus":0,"attacks":2}');
  const room = S.rooms.get(code).room;
  room.random = () => 0.5;
  await say(room, ann, { type: 'init.roll', bonus: 40, total: 60 });
  check('so a roll from the phone is d20 plus that bonus, whatever the phone sent',
    lastInit(ann).entries[0]?.total === 14 && lastInit(ann).entries[0]?.bonus === 3, JSON.stringify(lastInit(ann)));
  const roster = await S.call(T.roster, 'GET', { who: GM, query: '?campaign_id=1' });
  const villain = roster.body?.combatants?.find((c) => c.name === 'The Villain');
  check('the GM\'s roster lists the characters and the statted NPCs, with their numbers',
    roster.status === 200 && villain?.kind === 'npc' && villain.init.bonus === 5 && villain.init.attacks === 3
    && roster.body.combatants.filter((c) => c.kind === 'pc').length === 2, JSON.stringify(roster.body));
  check('and nobody else gets it', (await S.call(T.roster, 'GET', { who: ANN, query: '?campaign_id=1' })).status === 403);

  S.sqlite.exec(`INSERT INTO msh_campaigns (id, name, gm_email) VALUES (5, 'Avengers', '${GM}')`);
  const snap = JSON.stringify({ abilities: { agility: { number: 30 } }, talents: [{ id: 'martial-arts-e' }] });
  S.sqlite.prepare(`INSERT INTO msh_heroes (id, owner_email, name, build, snapshot) VALUES ('h1', ?, 'Nightfox', '{}', ?)`).run(BEN, snap);
  S.sqlite.exec(`INSERT INTO msh_campaign_heroes (campaign_id, hero_id, campaign_open, added_by) VALUES (5, 'h1', 1, '${BEN}')`);
  S.sqlite.prepare(`INSERT INTO msh_npc_sheets (campaign_id, name, build, snapshot, created_by) VALUES (5, 'Doom', '{}', ?, ?)`)
    .run(JSON.stringify({ abilities: { agility: { number: 40 } }, talents: [] }), GM);
  const M = {};
  for (const a of ['open', 'join', 'roster']) M[a] = await S.route(`marvel-heroes/table/${a}.js`);
  const mcode = (await S.call(M.open, 'POST', { who: GM, body: { campaign_id: 5 } })).body.code;
  await S.call(M.join, 'GET', { who: BEN, query: `?code=${mcode}`, headers: up });
  check('a Marvel seat carries the hero\'s Agility number and Talents from its sheet',
    JSON.stringify(S.socketOf(mcode).deserializeAttachment().seat.init) === '{"agility":30,"talents":["martial-arts-e"]}');
  const mr = (await S.call(M.roster, 'GET', { who: GM, query: '?campaign_id=5' })).body?.combatants ?? [];
  check('Marvel\'s roster lists the heroes and the GM\'s NPC sheets',
    mr.map((c) => `${c.kind}:${c.name}:${c.init.agility}`).join(',') === 'pc:Nightfox:30,npc:Doom:40', JSON.stringify(mr));
}

section('initiative: the server derives combat numbers the way the sheet does');
{
  const sheet = readFileSync(join(repoRoot, 'apps', 'character-sheet', 'sheet.js'), 'utf8').replace(/\r\n/g, '\n');
  const lib = readFileSync(join(repoRoot, 'functions', 'api', 'character-creator', '_lib', 'combat-numbers.js'), 'utf8').replace(/\r\n/g, '\n');
  const bonusCall = /derive\.classBonuses\(cls(?: \|\| \{\})?, c\.level, \{\n\s*attributes: c\.attribute_bonuses \|\| \{\},\n\s*combat: c\.rolled_bonuses\?\.combat \|\| \{\},\n\s*saves: c\.rolled_bonuses\?\.saves \|\| \{\},\n\s*\}\)/;
  check('the sheet builds its bonuses with classBonuses on those arguments', bonusCall.test(sheet));
  check('and so does the server', bonusCall.test(lib));
  check('the sheet\'s first-form combat block is derive.combat(attrs, c.combat, bonuses)', /: derive\.combat\(attrs, c\.combat, bonuses\);/.test(sheet));
  check('and the server\'s', /derive\.combat\(c\.attributes \|\| \{\}, c\.combat, bonuses\)/.test(lib));
}

// summary() returns the exit code; ignoring it made this suite pass CI on a failure.
process.exit(summary() === 0 ? 0 : 1);
