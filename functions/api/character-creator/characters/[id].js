// GET   /api/character-creator/characters/:id — character + current inventory.
//       Reads are open to any authenticated friend; can_write/is_gm flags tell
//       the client whether to show edit controls (server enforces regardless).
// PATCH /api/character-creator/characters/:id — owner/GM only; current stats + notes.

import { getUserEmail, unauthorized, json, forbidden, characterAccess, readJson } from '../_lib/auth.js';
import { listPending } from '../_lib/skill-picks.js';
import { decodeCharacter } from '../_lib/character-json.js';
import { getStored } from '../_lib/class-store.js';
import { parseClassMarkdown, applyVariant, combineClasses } from '../../../../apps/character-creator/js/parser.js';
import { withRolledPsionics } from '../../../../apps/character-creator/js/psionics.js';

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
    `SELECT character_items.*, gear.name AS item_name, gear.slug AS item_slug
     FROM character_items LEFT JOIN gear ON gear.id = character_items.item_id
     WHERE character_items.character_id = ? AND character_items.removed_at IS NULL
     ORDER BY character_items.id`
  ).bind(params.id).all();

  decodeCharacter(character);
  const can_write = email === character.player_email || email === character.campaign_gm;
  // So the sheet can badge unspent skill picks without a second request.
  const pending_picks = await listPending(env, params.id);

  // The class as this character plays it, variant already applied.
  //
  // Resolved here rather than by the sheet, because applyVariant lives in
  // parser.js — a module — and sheet.js is a classic script that cannot import
  // one. Doing it server-side keeps a single implementation instead of a second
  // copy that drifts.
  //
  // Loaded directly rather than through loadClass(), which only returns
  // published classes: a character whose class was retired after it was built
  // must still resolve, or the sheet loses its name and advisory text.
  const stored = await getStored(env, character.class_id);
  const parsed = stored ? parseClassMarkdown(stored.markdown) : null;
  let cls = parsed?.ok
    ? { ...applyVariant(parsed.data, character.class_variant), _retired: !!stored.deleted_at }
    : null;

  // The O.C.C. taken alongside, composed in. Loaded the same way — directly
  // rather than through loadClass — so a retired O.C.C. still resolves.
  if (cls && character.occ_class_id) {
    const occRow = await getStored(env, character.occ_class_id);
    const occParsed = occRow ? parseClassMarkdown(occRow.markdown) : null;
    if (occParsed?.ok) {
      const retired = cls._retired || !!occRow.deleted_at;
      cls = { ...combineClasses(cls, applyVariant(occParsed.data, character.occ_class_variant)), _retired: retired };
    }
  }

  // Psionics the character rolled for itself, folded in last. This endpoint
  // composes by hand rather than through loadCharacterClass() so that a retired
  // class still resolves — which means it has to remember this step too, or the
  // sheet shows a rolled psychic with no powers and the wrong save target.
  cls = withRolledPsionics(cls, character);

  return json({
    character, items, can_write, class: cls,
    is_gm: email === character.campaign_gm,
    pending_picks,
    pending_picks_total: pending_picks.reduce((n, g) => n + g.count, 0),
  });
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
