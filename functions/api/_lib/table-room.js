// The Table — what every game's table routes share: finding a room, opening
// one, handing a socket to it, and saving its feed when it closes.
//
// SHARED CODE REACHES NO DATABASE (groups.json). So nothing here names a D1
// binding or a table. Each game passes in an ADAPTER - Palladium's in
// functions/api/character-creator/_lib/table.js, Marvel's in
// functions/api/marvel-heroes/_lib/table.js - that answers the D1 questions
// against its own binding: who is this campaign's GM, which of its characters
// belong to this person, and where a table session is kept. That is why the
// routes live under each game's own directory rather than one /api/table/.
//
// THE ROOM TRUSTS WHAT THIS FILE TELLS IT. The join route decides the role
// from D1 and passes it to the room as headers on the upgrade; the room has no
// other way to know who anyone is and never checks. It is safe because the
// room Worker has no public hostname: env.TABLE_ROOM, behind Access, is the
// only way in. Any X-Table-* header a browser sent is stripped first.
//
// An ADAPTER is:
//   game                                'palladium' | 'marvel'
//   email(request)                      the Access identity, or null
//   campaign(env, id)                   { id, name, gmEmail } | null
//   characters(env, campaignId, email)  [{ id, name }] this person plays there
//   character(env, id)                  { id, name, campaignId, email } | null  (sheet rolls)
//   openSession(env, campaignId)        { id, code } | null - the open table
//   startSession(env, campaignId, code, email)   throws if one is already open
//   saveSession(env, id, { feed, reason })       writes the feed, closes the row
//   sessions(env, campaignId, limit)    closed sessions, newest first, feed as JSON text
//   describe(env, campaignId, ref)      { caption } for a picture the GM may show, or null
//   image(env, campaignId, ref)         { body, contentType } | { error, status } | null
//
// PICTURES (phase 2). A `ref` is { kind, id } (showing.js). The GM shows one
// from Present mode through `show`; every screen at the table is told; and a
// phone or the TV loads it through `image`, which serves it ONLY while the room
// says it is on the table and the caller is at the table (showing.js mayFetch).
// Every refusal is a 404, whatever the reason - no table, no seat, another
// picture, before Show, after Clear - because "you may not see this" tells a
// player the GM is holding something back. The campaign's own image routes are
// untouched: an unrevealed picture is still not found there, and Reveal is
// still the only thing that changes that.

import { filterFeed } from '../../../workers/table-room/src/visibility.js';
import { imageRef } from '../../../workers/table-room/src/showing.js';

// No O, 0, I or 1 - read aloud across a room, those are the ones misheard.
// The same alphabet as Pick 3 Cut 5's codes.
export const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CODE_LENGTH = 4;
const SESSIONS_MAX = 20;

export const validCode = (code) => typeof code === 'string' && code.length === CODE_LENGTH
  && [...code].every((c) => ALPHABET.includes(c));

function newCode() {
  const bytes = crypto.getRandomValues(new Uint8Array(CODE_LENGTH));
  return [...bytes].map((b) => ALPHABET[b % ALPHABET.length]).join('');
}

export function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  });
}

const notWired = () => json({ error: 'The Table is not wired up on this deployment.' }, 503);
const notFound = () => json({ error: 'Image not found' }, 404);
const stub = (env, code) => env.TABLE_ROOM.get(env.TABLE_ROOM.idFromName(code));

async function call(env, code, path, body) {
  const init = body === undefined ? {} : {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
  };
  const res = await stub(env, code).fetch(`https://table${path}`, init);
  return { status: res.status, body: await res.json().catch(() => ({})) };
}

export async function roomInfo(env, code) {
  return (await call(env, code, '/info')).body;
}

async function readBody(request) {
  try { return await request.json(); } catch { return null; }
}

// Closes the room if it is still open, saves its feed to the open session row,
// and only then tells the room to forget. The order is the point: a feed is
// deleted only once D1 holds it, so a failed write leaves it in the room for
// the next try.
async function closeAndSave(env, adapter, campaignId, row) {
  const info = await roomInfo(env, row.code);
  const ours = info.exists && info.game === adapter.game && info.campaignId === String(campaignId);
  let feed = [];
  let reason = 'lost';
  if (ours) {
    const closed = (await call(env, row.code, '/close', { reason: 'gm' })).body;
    feed = closed.feed || [];
    reason = closed.meta?.closedReason || 'gm';
  }
  await adapter.saveSession(env, row.id, { feed, reason });
  if (ours) await call(env, row.code, '/forget', {});
  return { session_id: row.id, roll_count: feed.length, reason };
}

// Who is asking, about which table. The code picks the room; the room says
// which campaign it is; that game's D1 says who this person is there.
async function resolve(request, env, adapter) {
  const email = adapter.email(request);
  if (!email) return { res: json({ error: 'Not signed in' }, 401) };
  const code = (new URL(request.url).searchParams.get('code') || '').trim().toUpperCase();
  if (!validCode(code)) return { res: json({ error: 'Table codes are four characters, no O, 0, I or 1.' }, 400) };
  const info = await roomInfo(env, code);
  if (!info.exists || info.game !== adapter.game) return { res: json({ error: 'No table with that code.' }, 404) };
  if (info.status !== 'open') return { res: json({ error: 'That table has closed.' }, 410) };
  const camp = await adapter.campaign(env, info.campaignId);
  const row = camp && await adapter.openSession(env, camp.id);
  // D1 has the last word: a room its campaign does not record as open is not
  // one anybody may join, whatever the room itself says.
  if (!camp || !row || row.code !== code) return { res: json({ error: 'No table with that code.' }, 404) };
  const isGm = email === camp.gmEmail;
  const characters = await adapter.characters(env, camp.id, email);
  if (!isGm && !characters.length) {
    return { res: json({ error: `You have no character in ${camp.name}. Ask the GM to add you to the campaign.` }, 403) };
  }
  const roles = [...(isGm ? ['gm'] : []), ...(characters.length ? ['player'] : []), 'display'];
  return { email, code, camp, isGm, characters, roles };
}

async function campaignReader(request, env, adapter, campaignId) {
  const email = adapter.email(request);
  if (!email) return { res: json({ error: 'Not signed in' }, 401) };
  const camp = await adapter.campaign(env, campaignId);
  if (!camp) return { res: json({ error: 'Campaign not found' }, 404) };
  const isGm = email === camp.gmEmail;
  if (!isGm && !(await adapter.characters(env, camp.id, email)).length) {
    return { res: json({ error: 'Only the GM and the campaign\'s players can see its table' }, 403) };
  }
  return { email, camp, isGm };
}

// The GM, and the campaign's open table, for show and clear.
async function gmTable(request, env, adapter) {
  const email = adapter.email(request);
  if (!email) return { res: json({ error: 'Not signed in' }, 401) };
  const b = await readBody(request);
  const camp = b && await adapter.campaign(env, b.campaign_id);
  if (!camp) return { res: json({ error: 'Campaign not found' }, 404) };
  if (email !== camp.gmEmail) return { res: json({ error: 'Only the GM can show pictures to the table' }, 403) };
  const row = await adapter.openSession(env, camp.id);
  if (!row) return { res: json({ error: 'No table is open for this campaign' }, 404) };
  return { b, camp, row };
}

// What the room answered, as this route's answer: a closed room is a 410.
function relay(r) {
  if (r.status === 410) return json({ error: 'That table has closed.' }, 410);
  if (r.status !== 200) return json({ error: r.body.error || 'The table did not answer' }, 502);
  return json({ shown: r.body.shown ?? null });
}

export function tableRoutes(adapter) {
  return {
    // POST { campaign_id } -> { code }. GM only. Opening a campaign that
    // already has a live table hands back that table's code; one left behind
    // by an abandoned room is saved first and a new one opened.
    async open({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const email = adapter.email(request);
      if (!email) return json({ error: 'Not signed in' }, 401);
      const b = await readBody(request);
      const camp = b && await adapter.campaign(env, b.campaign_id);
      if (!camp) return json({ error: 'Campaign not found' }, 404);
      if (email !== camp.gmEmail) return json({ error: 'Only the GM can open the table' }, 403);

      const existing = await adapter.openSession(env, camp.id);
      if (existing) {
        const info = await roomInfo(env, existing.code);
        if (info.exists && info.status === 'open' && info.campaignId === String(camp.id)) {
          return json({ code: existing.code, already_open: true });
        }
        await closeAndSave(env, adapter, camp.id, existing);
      }

      for (let attempt = 0; attempt < 8; attempt++) {
        const code = newCode();
        const made = await call(env, code, '/init', {
          code, game: adapter.game, campaignId: camp.id, campaignName: camp.name, gmEmail: camp.gmEmail,
        });
        if (made.status === 409) continue;
        if (made.status !== 200) return json({ error: made.body.error || 'The room would not open' }, 502);
        try {
          await adapter.startSession(env, camp.id, code, email);
        } catch {
          // Another tab opened one a moment ago. Keep that one.
          await call(env, code, '/forget', {});
          const won = await adapter.openSession(env, camp.id);
          if (won) return json({ code: won.code, already_open: true });
          return json({ error: 'Could not open the table. Try again.' }, 409);
        }
        return json({ code });
      }
      return json({ error: 'Could not find a free table code. Try again.' }, 503);
    },

    // GET ?code= -> what this person may be at this table, before connecting.
    async access({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const r = await resolve(request, env, adapter);
      if (r.res) return r.res;
      return json({
        game: adapter.game, code: r.code,
        campaign: { id: r.camp.id, name: r.camp.name },
        is_gm: r.isGm, roles: r.roles, characters: r.characters,
      });
    },

    // GET ?code=&as=gm|player|display, as a WebSocket upgrade.
    async join({ request, env }) {
      if (request.headers.get('Upgrade') !== 'websocket') {
        return json({ error: 'This endpoint expects a WebSocket upgrade.' }, 426);
      }
      if (!env.TABLE_ROOM) return notWired();
      const r = await resolve(request, env, adapter);
      if (r.res) return r.res;
      const asked = new URL(request.url).searchParams.get('as');
      const role = asked || r.roles[0];
      if (!r.roles.includes(role)) return json({ error: `You cannot join this table as ${role}` }, 403);

      const headers = new Headers(request.headers);
      for (const k of [...headers.keys()]) if (k.toLowerCase().startsWith('x-table-')) headers.delete(k);
      headers.set('X-Table-Role', role);
      headers.set('X-Table-Email', r.email);
      headers.set('X-Table-Name', encodeURIComponent(role === 'gm' ? 'GM' : role === 'display' ? 'Display' : ''));
      headers.set('X-Table-Characters', encodeURIComponent(JSON.stringify(role === 'player' ? r.characters : [])));
      return stub(env, r.code).fetch(new Request('https://table/ws', { method: 'GET', headers }));
    },

    // POST { campaign_id } -> { saved, session_id, roll_count }. GM only. Also
    // how the campaign page saves a table that closed itself while idle.
    async close({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const email = adapter.email(request);
      if (!email) return json({ error: 'Not signed in' }, 401);
      const b = await readBody(request);
      const camp = b && await adapter.campaign(env, b.campaign_id);
      if (!camp) return json({ error: 'Campaign not found' }, 404);
      if (email !== camp.gmEmail) return json({ error: 'Only the GM can close the table' }, 403);
      const row = await adapter.openSession(env, camp.id);
      if (!row) return json({ saved: false, error: 'No table is open for this campaign' }, 404);
      return json({ saved: true, ...(await closeAndSave(env, adapter, camp.id, row)) });
    },

    // GET ?campaign_id= -> { open, code, room }. The campaign page's question:
    // is there a table, and did it close itself while nobody was looking?
    async status({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const id = new URL(request.url).searchParams.get('campaign_id');
      const r = await campaignReader(request, env, adapter, id);
      if (r.res) return r.res;
      const row = await adapter.openSession(env, r.camp.id);
      if (!row) return json({ open: false, is_gm: r.isGm });
      const info = await roomInfo(env, row.code);
      const out = { open: true, code: row.code, room: info.exists ? info.status : 'missing', is_gm: r.isGm };
      // What is on the table, for Present mode's "on the table now". The GM's
      // alone: a player learns what is shown by being at the table.
      if (r.isGm && info.exists) out.shown = (await call(env, row.code, '/shown')).body.shown ?? null;
      return json(out);
    },

    // POST { campaign_id, kind, id } -> { shown }. GM only. Puts one of this
    // campaign's pictures on the table. The caption is the server's, from D1,
    // and a picture the campaign does not have is not found.
    async show({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const g = await gmTable(request, env, adapter);
      if (g.res) return g.res;
      const ref = imageRef(g.b.kind, g.b.id);
      const about = ref && await adapter.describe(env, g.camp.id, ref);
      if (!about) return notFound();
      return relay(await call(env, g.row.code, '/show', { ...ref, caption: about.caption }));
    },

    // POST { campaign_id } -> { shown: null }. GM only. Takes it down, and from
    // then on the image route answers not found to every player again.
    async clear({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const g = await gmTable(request, env, adapter);
      if (g.res) return g.res;
      return relay(await call(env, g.row.code, '/clear', {}));
    },

    // GET ?code=&kind=&id= -> the picture's bytes, while it is on the table
    // and the caller is at it. no-store, unlike the campaign image route's
    // year-long cache: a copy kept by the browser would outlive Clear.
    async image({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const r = await resolve(request, env, adapter);
      if (r.res) return r.res.status === 401 ? r.res : notFound();
      const url = new URL(request.url);
      const ref = imageRef(url.searchParams.get('kind'), url.searchParams.get('id'));
      if (!ref) return notFound();
      const q = `/may-fetch?email=${encodeURIComponent(r.email)}&kind=${ref.kind}&id=${ref.id}`;
      if (!(await call(env, r.code, q)).body.allowed) return notFound();
      const pic = await adapter.image(env, r.camp.id, ref);
      if (!pic) return notFound();
      if (pic.error) return json({ error: pic.error }, pic.status || 502);
      return new Response(pic.body, {
        headers: {
          'Content-Type': pic.contentType || 'application/octet-stream',
          'Cache-Control': 'no-store',
          'Content-Disposition': 'inline',
          'X-Content-Type-Options': 'nosniff',
          // A city map is SVG. Opened as a page rather than an <img>, it may
          // style itself and nothing else.
          'Content-Security-Policy': "default-src 'none'; style-src 'unsafe-inline'",
        },
      });
    },

    // GET ?campaign_id= -> the campaign's saved table sessions, each feed
    // filtered for the reader by the rule the room used live.
    async sessions({ request, env }) {
      const id = new URL(request.url).searchParams.get('campaign_id');
      const r = await campaignReader(request, env, adapter, id);
      if (r.res) return r.res;
      const conn = { role: r.isGm ? 'gm' : 'player', email: r.email };
      const rows = await adapter.sessions(env, r.camp.id, SESSIONS_MAX);
      return json({
        sessions: rows.map((s) => {
          let feed = [];
          try { feed = JSON.parse(s.feed || '[]'); } catch { feed = []; }
          const { feed: _raw, ...rest } = s;
          return { ...rest, feed: filterFeed(feed, conn) };
        }),
      });
    },

    // POST { character_id, note, visibility } from the character sheet. The
    // sheet has already saved the roll to the session log; this only carries it
    // to the table, and only while that character is seated there.
    async roll({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const email = adapter.email(request);
      if (!email) return json({ error: 'Not signed in' }, 401);
      const b = await readBody(request);
      const ch = b && await adapter.character(env, b.character_id);
      if (!ch || ch.email !== email) return json({ error: 'Character not found' }, 404);
      const row = await adapter.openSession(env, ch.campaignId);
      if (!row) return json({ open: false, seated: false });
      const res = (await call(env, row.code, '/sheet-roll', {
        email, characterId: String(ch.id), text: typeof b.note === 'string' ? b.note : '', visibility: b.visibility,
      })).body;
      return json({ open: !res.closed, code: row.code, seated: !!res.seated });
    },

    // GET ?character_id= -> { open, code, seated }: does the sheet send rolls?
    async seat({ request, env }) {
      if (!env.TABLE_ROOM) return notWired();
      const email = adapter.email(request);
      if (!email) return json({ error: 'Not signed in' }, 401);
      const id = new URL(request.url).searchParams.get('character_id');
      const ch = await adapter.character(env, id);
      if (!ch || ch.email !== email) return json({ error: 'Character not found' }, 404);
      const row = await adapter.openSession(env, ch.campaignId);
      if (!row) return json({ open: false, seated: false });
      const q = `/seat?email=${encodeURIComponent(email)}&characterId=${encodeURIComponent(String(ch.id))}`;
      const res = (await call(env, row.code, q)).body;
      return json({ open: !!res.open, code: row.code, seated: !!res.seated });
    },
  };
}
