// Marvel Heroes campaigns: who the caller is, what they may do in a campaign,
// and the checks every write goes through. The parsing half is pure so
// apps/marvel-heroes/test/smoke.mjs can run it; the rest takes the D1 binding.
//
// Three people can touch a campaign, and each gets a different answer:
//   - its GM (msh_campaigns.gm_email) reads every linked hero's sheet and
//     changes the four play numbers on them;
//   - a player whose hero is linked reads their own hero and the names of
//     the others;
//   - anyone else signed in sees the campaign exists, so they can join it.
// A hero is never copied into a campaign (migration 086), so the GM's writes
// land on msh_heroes itself - through the PATCH, and nowhere else.

import { getAccessEmail } from '../../_lib/access.js';
import { SHEET_NUMBERS, ID as HERO_ID } from './heroes.js';

export { HERO_ID };
const CAMPAIGN_ID = /^[1-9]\d{0,11}$/;
const PLAY_FIELDS = SHEET_NUMBERS;          // health, karma, karma_pool, advancement
export const NUMBER_MAX = 1000000;                 // the same bound the owner's own save keeps
const NAME_MAX = 80;
const TEXT_MAX = 8000;

export function owner(request) {
  const email = getAccessEmail(request);
  if (email) return email;
  const host = new URL(request.url).hostname;
  return host === 'localhost' || host === '127.0.0.1' ? 'dev@localhost' : null;
}

export function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  });
}

export async function readJson(request) {
  try { return await request.json(); } catch { return undefined; }
}

const plainObject = (x) => !!x && typeof x === 'object' && !Array.isArray(x);

// A new campaign, or a GM's edit to one. -> { fields } or { error }. `partial`
// is an edit: only the keys sent are returned, and none is required.
export function parseCampaign(body, { partial = false } = {}) {
  if (!plainObject(body)) return { error: 'A campaign is a JSON object' };
  const out = {};
  if ('name' in body || !partial) {
    const name = typeof body.name === 'string' ? body.name.trim().slice(0, NAME_MAX) : '';
    if (!name) return { error: 'A campaign needs a name' };
    out.name = name;
  }
  for (const k of ['description', 'gm_notes']) {
    if (!(k in body)) continue;
    if (body[k] !== null && typeof body[k] !== 'string') return { error: `${k} must be text` };
    out[k] = (body[k] || '').slice(0, TEXT_MAX).trim() || null;
  }
  if ('open' in body) out.open = body.open ? 1 : 0;
  if (partial) {
    const unknown = Object.keys(body).filter((k) => !['name', 'description', 'gm_notes', 'open'].includes(k));
    if (unknown.length) return { error: `Not a campaign field: ${unknown.join(', ')}` };
    if (!Object.keys(out).length) return { error: 'name, description, gm_notes and open are the editable fields' };
  }
  return { fields: out };
}

// The GM's change to a hero: { field: delta } for the four play numbers, and
// nothing else. A delta rather than a value, so two quick clicks - or a player
// saving their sheet between them - cannot lose one. -> { changes: [[f, d]] }
// or { error }, and ANY other key is an error, not something silently dropped:
// the GM is writing to someone else's hero.
export function parsePlayPatch(body) {
  if (!plainObject(body)) return { error: 'A change is a JSON object of field: amount' };
  const keys = Object.keys(body);
  const other = keys.filter((k) => !PLAY_FIELDS.includes(k));
  if (other.length) return { error: `Only ${PLAY_FIELDS.join(', ')} can be changed here, not ${other.join(', ')}` };
  if (!keys.length) return { error: `Send one of ${PLAY_FIELDS.join(', ')}` };
  const changes = [];
  for (const k of keys) {
    const d = body[k];
    if (!Number.isInteger(d) || d === 0 || Math.abs(d) > NUMBER_MAX) return { error: `${k} must be a whole, non-zero amount` };
    changes.push([k, d]);
  }
  return { changes };
}

// The number a play field holds now, as SQL over a msh_heroes row. Health and
// Karma start at what the hero was built with (the snapshot); the pool and the
// fund start at nothing. `f` has been checked against PLAY_FIELDS by the caller,
// which is what makes naming it in the SQL safe.
export function currentSql(f, alias = '') {
  const a = alias ? `${alias}.` : '';
  const start = f === 'health' || f === 'karma' ? `json_extract(${a}snapshot, '$.${f}')` : '0';
  // CAST, because a bound JS number can arrive as REAL and would be stored as
  // 70.0 - still whole, but not the integer the owner's own save writes.
  return `CAST(COALESCE(json_extract(${a}sheet, '$.${f}'), ${start}, 0) AS INTEGER)`;
}

// The guard every GM write repeats IN ITS OWN SQL, so the check before the
// batch and the batch itself cannot disagree: the caller is this campaign's
// GM, it is open, and the hero is linked to it.
const GM_GUARD = `EXISTS (SELECT 1 FROM msh_campaign_heroes ch JOIN msh_campaigns c ON c.id = ch.campaign_id
  WHERE ch.hero_id = msh_heroes.id AND c.id = ? AND c.gm_email = ? AND c.open = 1)`;

// The statements for one change: the event first (it reads the number before
// the update moves it), then the update. Both in one db.batch.
export function playStatements(db, { campaignId, heroId, email, field, delta, undoes = null }) {
  const cur = currentSql(field);
  return [
    db.prepare(`INSERT INTO msh_hero_events (hero_id, campaign_id, actor_email, field, delta, before, after, undoes)
      SELECT id, ?, ?, ?, CAST(? AS INTEGER), ${cur}, ${cur} + CAST(? AS INTEGER), ? FROM msh_heroes WHERE id = ? AND ${GM_GUARD}`)
      .bind(campaignId, email, field, delta, delta, undoes, heroId, campaignId, email),
    db.prepare(`UPDATE msh_heroes SET sheet = json_set(sheet, '$.${field}', ${cur} + CAST(? AS INTEGER))
      WHERE id = ? AND ${GM_GUARD}`)
      .bind(delta, heroId, campaignId, email),
  ];
}

async function loadCampaign(db, id) {
  if (!CAMPAIGN_ID.test(String(id))) return null;
  return db.prepare('SELECT * FROM msh_campaigns WHERE id = ?').bind(Number(id)).first();
}

// -> { email, campaign, isGm } or { res } holding the refusal to return.
export async function requireCampaign(request, env, id, { gm = false } = {}) {
  const email = owner(request);
  if (!email) return { res: json({ error: 'not signed in' }, 401) };
  const campaign = await loadCampaign(env.DB_MARVEL, id);
  if (!campaign) return { res: json({ error: 'no such campaign' }, 404) };
  const isGm = campaign.gm_email === email;
  if (gm && !isGm) return { res: json({ error: 'only the GM of this campaign can do that' }, 403) };
  return { email, campaign, isGm };
}

export const isUniqueViolation = (e) => /UNIQUE constraint failed/i.test(String(e?.message || e));

const parse = (s, dflt) => { try { return JSON.parse(s); } catch { return dflt; } };

// A linked hero as its reader may see it: the GM and the hero's owner get the
// sheet, everyone else the name.
export function heroView(row, { full }) {
  const base = { id: row.id, name: row.name, owner_email: row.owner_email, added_at: row.added_at };
  return full ? { ...base, snapshot: parse(row.snapshot, {}), sheet: parse(row.sheet, {}), updated_at: row.updated_at } : base;
}

// A hero linked to this campaign, with each play number as it stands now
// (cur_health, cur_karma, ...), or null.
export async function linkedHero(db, campaignId, heroId) {
  if (typeof heroId !== 'string' || !HERO_ID.test(heroId)) return null;
  return db.prepare(`SELECT h.id, h.name, h.owner_email, h.snapshot, h.sheet, h.updated_at, ch.added_at,
      ${PLAY_FIELDS.map((f) => `${currentSql(f, 'h')} AS cur_${f}`).join(', ')}
    FROM msh_campaign_heroes ch JOIN msh_heroes h ON h.id = ch.hero_id
    WHERE ch.campaign_id = ? AND ch.hero_id = ?`).bind(campaignId, heroId).first();
}

// What a write answers with: the hero as it now is, and the n events it wrote.
export async function heroAndEvents(db, campaignId, heroId, n) {
  const hero = await linkedHero(db, campaignId, heroId);
  const { results: events } = await db.prepare(`SELECT * FROM msh_hero_events WHERE campaign_id = ? AND hero_id = ?
    ORDER BY id DESC LIMIT ?`).bind(campaignId, heroId, n).all();
  return { hero: hero && heroView(hero, { full: true }), events: events.reverse() };
}

// A member is the campaign's GM, or anyone with a hero linked to it. Notes,
// People and handouts are the table's own record, so they are member-only -
// narrower than "any signed-in friend may see the campaign exists".
// -> { email, campaign, isGm, isMember } or { res }.
export async function requireMember(request, env, id, { gm = false } = {}) {
  const g = await requireCampaign(request, env, id, { gm });
  if (g.res) return g;
  const linked = g.isGm || !!(await env.DB_MARVEL.prepare(`SELECT 1 FROM msh_campaign_heroes ch
    JOIN msh_heroes h ON h.id = ch.hero_id WHERE ch.campaign_id = ? AND h.owner_email = ?`).bind(g.campaign.id, g.email).first());
  if (!linked) return { res: json({ error: 'Only the GM or a player with a hero in this campaign can do that' }, 403) };
  return { ...g, isMember: true };
}

// Pictures (People portraits, the GM's setting pages): the types allowed, the
// cap, and the R2 key. Every key starts msh/, which the tables CHECK (086).
const IMAGE_TYPES = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp', 'image/gif': 'gif' };
const IMAGE_MAX_BYTES = 5 * 1024 * 1024;
export const imageKey = (parts, ext) => `msh/${parts.join('/')}/${crypto.randomUUID()}.${ext}`;

// One upload body, checked: -> { bytes, contentType, ext } or { res }.
export async function readImage(request) {
  const contentType = (request.headers.get('Content-Type') || '').split(';')[0].trim().toLowerCase();
  const ext = IMAGE_TYPES[contentType];
  if (!ext) return { res: json({ error: `Unsupported image type. Send one of: ${Object.keys(IMAGE_TYPES).join(', ')}` }, 415) };
  const bytes = await request.arrayBuffer();
  if (!bytes.byteLength) return { res: json({ error: 'Empty upload' }, 400) };
  if (bytes.byteLength > IMAGE_MAX_BYTES) return { res: json({ error: `An image must be under ${IMAGE_MAX_BYTES / 1024 / 1024}MB` }, 413) };
  return { bytes, contentType, ext };
}

// An object from R2 as a response. Private and immutable: every key carries a
// uuid, and this sits behind Access, so it must not land in a shared cache.
export async function serveImage(env, key, fallbackType) {
  if (!env.MEDIA) return json({ error: 'Image storage is not configured on this environment' }, 501);
  const object = await env.MEDIA.get(key);
  if (!object) return json({ error: 'Image is recorded but missing from storage' }, 502);
  return new Response(object.body, { headers: {
    'Content-Type': object.httpMetadata?.contentType || fallbackType || 'application/octet-stream',
    'Cache-Control': 'private, max-age=31536000, immutable', 'Content-Disposition': 'inline',
  } });
}

// A failed object delete is swallowed: a row that would not delete because R2
// could not be reached is worse than an orphan nobody points at.
export async function dropObject(env, key) {
  if (!key || !env.MEDIA) return;
  try { await env.MEDIA.delete(key); } catch { /* see above */ }
}
