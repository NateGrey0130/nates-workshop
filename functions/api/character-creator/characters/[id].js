// GET   /api/character-creator/characters/:id — character + current inventory.
//       Reads are open to any authenticated friend; can_write/is_gm flags tell
//       the client whether to show edit controls (server enforces regardless).
// PATCH /api/character-creator/characters/:id — owner/GM only; current stats + notes.

import { getUserEmail, unauthorized, json, forbidden, characterAccess, readJson } from '../_lib/auth.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const character = await env.DB.prepare(
    `SELECT characters.*, campaigns.name AS campaign_name, campaigns.system AS campaign_system,
            campaigns.gm_email AS campaign_gm
     FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id
     WHERE characters.id = ?`
  ).bind(params.id).first();
  if (!character) return json({ error: 'Character not found' }, 404);

  const { results: items } = await env.DB.prepare(
    `SELECT character_items.*, items.name AS item_name, items.slug AS item_slug
     FROM character_items LEFT JOIN items ON items.id = character_items.item_id
     WHERE character_items.character_id = ? AND character_items.removed_at IS NULL
     ORDER BY character_items.id`
  ).bind(params.id).all();

  for (const col of ['attributes', 'skills', 'powers', 'bio', 'combat', 'saves', 'armor']) {
    if (character[col] === undefined) continue; // column not migrated yet
    try { character[col] = JSON.parse(character[col]); } catch { /* leave as stored */ }
  }
  const can_write = email === character.player_email || email === character.campaign_gm;
  return json({ character, items, can_write, is_gm: email === character.campaign_gm });
}

const PATCHABLE = ['hp_current', 'sdc_current', 'mdc_current', 'ppe_current', 'isp_current', 'notes'];
// Sheet sections stored as JSON. Sent as objects/arrays and re-serialised here,
// so a malformed section can't corrupt the column.
const JSON_SECTIONS = { bio: 'object', combat: 'object', saves: 'object', armor: 'array' };

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const body = await readJson(request);
  if (!body) return json({ error: 'Invalid JSON body' }, 400);

  // Current values are clamped to their own maximum: the level-up flow raises
  // current and max together, and this is the only route that could otherwise
  // leave them inconsistent (e.g. 9999 / 24 on the sheet).
  const current = await env.DB.prepare(
    'SELECT hp_max, sdc_max, mdc_max, ppe_max, isp_max FROM characters WHERE id = ?'
  ).bind(params.id).first();

  const sets = [], binds = [];
  for (const field of PATCHABLE) {
    if (!(field in body)) continue;
    let v = body[field];
    if (field !== 'notes') {
      v = v === null || v === '' ? null : parseInt(v, 10);
      if (v !== null && !Number.isFinite(v)) return json({ error: `${field} must be a number or null` }, 400);
      if (v !== null) {
        const max = current?.[field.replace('_current', '_max')];
        v = Math.max(0, typeof max === 'number' ? Math.min(v, max) : v);
      }
    }
    sets.push(`${field} = ?`);
    binds.push(v);
  }

  for (const [section, kind] of Object.entries(JSON_SECTIONS)) {
    if (!(section in body)) continue;
    const v = body[section];
    const okShape = kind === 'array' ? Array.isArray(v) : (v && typeof v === 'object' && !Array.isArray(v));
    if (!okShape) return json({ error: `${section} must be ${kind === 'array' ? 'an array' : 'an object'}` }, 400);
    sets.push(`${section} = ?`);
    binds.push(JSON.stringify(v));
  }

  if (!sets.length) return json({ error: 'No editable fields in body' }, 400);

  await env.DB.prepare(
    `UPDATE characters SET ${sets.join(', ')}, updated_at = datetime('now') WHERE id = ?`
  ).bind(...binds, params.id).run();
  return json({ ok: true });
}
