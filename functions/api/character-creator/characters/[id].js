// GET   /api/character-creator/characters/:id — character + current inventory.
//       Reads are open to any authenticated friend; can_write/is_gm flags tell
//       the client whether to show edit controls (server enforces regardless).
// PATCH /api/character-creator/characters/:id — owner/GM only; current stats + notes.

import { getUserEmail, unauthorized, json, readJson, requireCharacter } from '../_lib/auth.js';
import { listPending } from '../_lib/skill-picks.js';
import { decodeCharacter } from '../_lib/character-json.js';
import { getStored } from '../_lib/class-store.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
import { loadSkillBonuses } from '../_lib/skill-bonuses.js';
import { skillLevelNotes } from '../../../../apps/character-creator/js/parser.js';

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
    // category/damage/payload ride along for play mode's weapon cards -
    // per held item, deliberately NOT added to the /items picker projection.
    `SELECT character_items.*, gear.name AS item_name, gear.slug AS item_slug,
            gear.category AS item_category, gear.damage AS item_damage, gear.payload AS item_payload
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
  // Fetched directly rather than through loadClass(), which returns only
  // published classes: a character whose class was retired after it was built
  // must still resolve, or the sheet loses its name and advisory text. Only the
  // FETCH differs — composeClass() does the rest, the same as everywhere else.
  const stored = await getStored(env, character.class_id);
  const parsed = stored ? parseClassMarkdown(stored.markdown) : null;

  const occRow = character.occ_class_id ? await getStored(env, character.occ_class_id) : null;
  const occParsed = occRow ? parseClassMarkdown(occRow.markdown) : null;



  // The bonuses the character's SKILLS grant, not just its classes. Boxing is
  // +1 attack per melee and +2 P.S.; before this they were shown nowhere.
  const skillRows = await loadSkillBonuses(env, character);

  const composeArgs = {
    rcc: parsed?.ok ? parsed.data : null,
    occ: occParsed?.ok ? occParsed.data : null,
    character,
  };
  let cls = composeClass({ ...composeArgs, skillRows });

  // The class half on its own, so the sheet can say where a bonus came from.
  // `bonuses` above has the skills folded in and there is no way to recover the
  // two halves from the total, so the split is made here rather than guessed
  // there. Composing twice is cheap - both calls are pure and the classes are
  // already parsed - and it beats a second implementation of the fold.
  if (cls) {
    cls = {
      ...cls,
      class_bonuses: composeClass(composeArgs)?.bonuses ?? null,
      _retired: false,
    };
  }
  if (cls) cls._retired = !!stored?.deleted_at || !!occRow?.deleted_at;

  // What a fighting style grants that is not a number — "Karate Kick (2D6
  // damage)", "Death blow on a Natural 20". The bonuses fold into the combat
  // block above and need no help; these do not add up to anything, so without
  // this the sheet could show a 7th level Expert's numbers while saying nothing
  // about the four moves the character earned along the way.
  const skill_level_notes = skillLevelNotes(skillRows, character.level);

  return json({
    character, items, can_write, class: cls, skill_level_notes,
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
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const body = await readJson(request);
  if (!body) return json({ error: 'Invalid JSON body' }, 400);

  // Current values are clamped to their own maximum: the level-up flow raises
  // current and max together, and this is the only route that could otherwise
  // leave them inconsistent (e.g. 9999 / 24 on the sheet).
  const current = await env.DB.prepare(
    'SELECT hp_max, sdc_max, mdc_max, ppe_max, isp_max FROM characters WHERE id = ?'
  ).bind(params.id).first();

  const sets = [], binds = [];
  // G.M.-assigned powers, replacing only the gm-flagged subset of `abilities`.
  // The book calls for this outright — "most demigods will have ONE extra
  // power, similar to that of the godly father or mother" — and a ruling needs
  // somewhere to live. Player picks are never writable here: the create
  // endpoint validates them and the sheet has no business rewriting them, so
  // the stored non-gm entries are carried through untouched.
  //
  // Recorded, not re-rolled: pools were rolled at creation and stay put, and a
  // dice bonus on a G.M.-added power has no rolled value so it contributes
  // nothing — the G.M. adjusts numbers by hand, which is who is driving anyway.
  if ('gm_abilities' in body) {
    if (!Array.isArray(body.gm_abilities)
        || body.gm_abilities.some((n) => typeof n !== 'string' || !n.trim())) {
      return json({ error: 'gm_abilities must be a list of power names' }, 400);
    }
    const row = await env.DB.prepare('SELECT abilities FROM characters WHERE id = ?')
      .bind(params.id).first();
    let stored = [];
    try { stored = JSON.parse(row?.abilities || '[]') || []; } catch { stored = []; }
    const player = stored.filter((e) => typeof e === 'string' || e?.gm !== true);
    const next = [...player, ...body.gm_abilities.map((n) => ({ name: n.trim(), gm: true }))];
    sets.push('abilities = ?');
    binds.push(JSON.stringify(next));
  }

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
