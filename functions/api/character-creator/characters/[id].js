// GET   /api/character-creator/characters/:id — character + current inventory.
//       Reads are open to any authenticated friend; can_write/is_gm flags tell
//       the client whether to show edit controls (server enforces regardless).
// PATCH /api/character-creator/characters/:id — owner/GM only; current stats + notes.

import { getUserEmail, unauthorized, json, readJson, requireCharacter } from '../_lib/auth.js';
import { listPending } from '../_lib/skill-picks.js';
import { listPendingPowers, loadPowerDescriptions } from '../_lib/power-picks.js';
import { listGrants } from '../_lib/grants.js';
import { decodeCharacter, decodeItemEnchantments, decodeVehicleMdc } from '../_lib/character-json.js';
import { getStored } from '../_lib/class-store.js';
import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
import { loadSkillBonuses } from '../_lib/skill-bonuses.js';
import { skillLevelNotes, skillConditionalBonuses } from '../../../../apps/character-creator/js/parser.js';
import { xpTableFor, levelForXp, thresholdFor } from '../_lib/leveling.js';

export async function onRequestGet({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const character = await env.DB.prepare(
    `SELECT characters.*, campaigns.name AS campaign_name, campaigns.system AS campaign_system,
            campaigns.gm_email AS campaign_gm, campaigns.rest_rates AS campaign_rest_rates
     FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id
     WHERE characters.id = ?`
  ).bind(params.id).first();
  if (!character) return json({ error: 'Character not found' }, 404);

  const { results: items } = await env.DB.prepare(
    // THE WHOLE STAT BLOCK rides along, per held item, and is deliberately NOT
    // added to the /items picker projection. The two are sized completely
    // differently: /items is the catalog, 1,253 rows and 32.4 KB gzipped on
    // every wizard boot and every sheet load, where this is only what THIS
    // character holds - 116 rows across every character on production, all of
    // them catalog-linked. The same argument plan 20 made for power
    // descriptions, and the same conclusion.
    //
    // Powers needed a separate loader (`loadPowerDescriptions`) because they
    // live in a JSON column with nothing to join to. Items already come through
    // this join, so the columns just ride on the row and there is nothing to
    // build.
    // JOINED ON THE SLUG since RETRO-AUDIT R21, because a gear id is insertion
    // order and means nothing outside the database that assigned it. Two arms:
    //   1. the slug as stored;
    //   2. a slug that has since been RENAMED or merged away, resolved through
    //      catalog_redirects - which the id used to insulate this from, and
    //      which is now the thing that would orphan a row silently.
    // A third arm read the legacy id for rows written before 044. Migration 046
    // dropped that column after backfilling every row from it, so there is no
    // longer a row it could match.
    // `item_slug` remains the ALIAS of gear.slug, not the stored column - the
    // stored one is `gear_slug` precisely so these two cannot collide.
    `SELECT character_items.*, gear.name AS item_name, gear.slug AS item_slug,
            gear.category AS item_category, gear.damage AS item_damage, gear.payload AS item_payload,
            gear.is_mega_damage AS item_is_mega_damage, gear.range AS item_range,
            gear.rate_of_fire AS item_rate_of_fire, gear.ar AS item_ar,
            gear.sdc AS item_sdc, gear.mdc AS item_mdc,
            gear.weight_lbs AS item_weight_lbs, gear.cost AS item_cost,
            gear.cost_note AS item_cost_note, gear.system AS item_system,
            gear.description AS item_description, gear.source_book AS item_source_book
     FROM character_items
     LEFT JOIN catalog_redirects cr
            ON cr.catalog = 'gear' AND cr.from_key = character_items.gear_slug
     LEFT JOIN gear
            ON gear.slug = character_items.gear_slug
            OR gear.id = cr.to_id
     WHERE character_items.character_id = ? AND character_items.removed_at IS NULL
     ORDER BY character_items.id`
  ).bind(params.id).all();

  // The vessels this character owns, each with its catalog row, its M.D.C. by
  // location and its numbered weapon systems.
  //
  // THREE QUERIES RATHER THAN ONE JOIN, because a vessel's children multiply:
  // one vessel with ten locations and eight weapons is eighty rows out of a
  // single join, and the client would have to un-multiply them. They are nested
  // below, the same shape the codex's vessels section returns - a vessel read on
  // the sheet and a vessel read in the codex should not be two different
  // objects.
  //
  // NO catalog_redirects arm, unlike the inventory join above. `catalog_redirects`
  // is per-catalog by construction (`to_id` is "row in that catalog's table")
  // and nothing files vessel redirects, because `vehicles` has no MERGE_REFS
  // entry and so cannot be merged through the editor. If that changes, this
  // join needs the second arm inventory already has.
  const { results: vehicles } = await env.DB.prepare(
    `SELECT character_vehicles.*, vehicles.name AS vehicle_name,
            vehicles.vehicle_class, vehicles.system AS vehicle_system,
            vehicles.crew, vehicles.passengers, vehicles.speed_ground,
            vehicles.speed_air, vehicles.speed_water, vehicles.dimensions,
            vehicles.weight_tons, vehicles.mdc_main_body, vehicles.cost AS vehicle_cost,
            vehicles.cost_note AS vehicle_cost_note,
            vehicles.description AS vehicle_description,
            vehicles.source_book AS vehicle_source_book
     FROM character_vehicles
     LEFT JOIN vehicles ON vehicles.slug = character_vehicles.vehicle_slug
     WHERE character_vehicles.character_id = ? AND character_vehicles.removed_at IS NULL
     ORDER BY character_vehicles.id`
  ).bind(params.id).all();

  if (vehicles.length) {
    const slugs = [...new Set(vehicles.map((v) => v.vehicle_slug).filter(Boolean))];
    if (slugs.length) {
      const qs = slugs.map(() => '?').join(', ');
      const [locs, weps] = await Promise.all([
        env.DB.prepare(
          `SELECT vehicle_slug, location, mdc, mdc_note FROM vehicle_locations
           WHERE vehicle_slug IN (${qs}) ORDER BY vehicle_slug, ordinal`
        ).bind(...slugs).all(),
        env.DB.prepare(
          `SELECT vehicle_slug, ordinal, name, damage, is_mega_damage, range,
                  rate_of_fire, payload, bonus, note FROM vehicle_weapons
           WHERE vehicle_slug IN (${qs}) ORDER BY vehicle_slug, ordinal`
        ).bind(...slugs).all(),
      ]);
      const byslug = (rows) => {
        const m = new Map();
        for (const r of rows) {
          const { vehicle_slug, ...rest } = r;
          if (!m.has(vehicle_slug)) m.set(vehicle_slug, []);
          m.get(vehicle_slug).push(rest);
        }
        return m;
      };
      const L = byslug(locs.results), W = byslug(weps.results);
      for (const v of vehicles) {
        v.locations = L.get(v.vehicle_slug) || [];
        v.weapons = W.get(v.vehicle_slug) || [];
      }
    }
    // A freeform vessel joins to no catalog row, so it gets the empty arrays
    // too rather than `undefined` - the renderer should not have to guard.
    for (const v of vehicles) {
      v.locations ||= [];
      v.weapons ||= [];
    }
  }

  decodeCharacter(character);
  // The campaign's rest rates ride along, decoded, so the rest panel can prefer
  // them without a second request (UI-AUDIT F52). NULL stays NULL.
  try {
    character.campaign_rest_rates = character.campaign_rest_rates ? JSON.parse(character.campaign_rest_rates) : null;
  } catch { character.campaign_rest_rates = null; }
  decodeItemEnchantments(items);
  decodeVehicleMdc(vehicles);
  const can_write = email === character.player_email || email === character.campaign_gm;
  // So the sheet can badge unspent skill picks without a second request.
  const pending_picks = await listPending(env, params.id);
  const pending_powers = await listPendingPowers(env, params.id);
  // What a table handed this character outside its class schedule. Rides
  // along for the same reason the pending picks do: the sheet needs it on
  // first paint, and the granted skills are already IN `character.skills`, so
  // without this it can show them and not say where they came from.
  const grants = await listGrants(env, params.id);

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

  // Where the next level is, and whether the XP already pays for it (UI-AUDIT
  // F42). The sheet learned both only from POST /xp, so a character holding
  // enough XP opened with no sign of it, and "Not now" lost the offer until
  // somebody logged XP again. The same three helpers xp.js uses, on the same
  // composed class, so the two cannot disagree about a threshold.
  let next_threshold = null, level_up_ready = false;
  if (cls) {
    const table = xpTableFor(cls);
    next_threshold = thresholdFor(table, character.level + 1);
    level_up_ready = levelForXp(table, character.xp) > character.level;
  }
  // A W.P.'s bonuses apply only while that weapon is in hand, so they are
  // deliberately kept OUT of the combat block above. They are still real and
  // still accumulate by level, so they come back separately — a player who
  // cannot see them cannot use them.
  const weapon_bonuses = skillConditionalBonuses(skillRows, character.level);

  // What each held power DOES, so the sheet can open it in place. Only the
  // powers this character holds, keyed by the name it holds them under - the
  // catalogs' whole description corpus is sixteen times bigger and belongs
  // nowhere near a boot payload. See docs/plans/20-power-descriptions.md.
  const power_descriptions = await loadPowerDescriptions(env, character.powers);

  return json({
    character, items, vehicles, can_write, class: cls, skill_level_notes, weapon_bonuses,
    is_gm: email === character.campaign_gm,
    pending_picks,
    pending_picks_total: pending_picks.reduce((n, g) => n + g.count, 0),
    pending_powers,
    pending_powers_total: pending_powers.reduce((n, g) => n + g.count, 0),
    grants,
    power_descriptions,
    next_threshold,
    level_up_ready,
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

  // WHICH VERSION THE CALLER BELIEVES IT IS CHANGING. Optional, and honoured
  // when sent: two people on one character - a player and a G.M. at the same
  // table, or the same person in two tabs - previously overwrote each other
  // silently, last write winning with nothing said. The same guard the draft
  // has carried since it had the same problem.
  //
  // Guarded IN THE WHERE, one statement. Reading the row first and then
  // writing leaves exactly the gap this exists to close.
  //
  // Optional rather than required because every existing caller predates it
  // and a required field would break them all at once. A caller that sends
  // nothing gets the old last-write-wins behaviour, which is no worse than
  // what it had.
  const expected = typeof body.expect_updated_at === 'string' && body.expect_updated_at
    ? body.expect_updated_at : null;

  const res = await env.DB.prepare(
    `UPDATE characters SET ${sets.join(', ')}, updated_at = datetime('now')`
    + ` WHERE id = ?${expected ? ' AND updated_at = ?' : ''}`
  ).bind(...binds, params.id, ...(expected ? [expected] : [])).run();

  if (expected && !(res.meta?.changes ?? 0)) {
    // Say what is there now, so the client can offer a real choice rather
    // than reporting that something went wrong. A missing row is a 404 and
    // not a conflict - the character was deleted, not edited.
    const current = await env.DB.prepare(
      'SELECT updated_at FROM characters WHERE id = ?'
    ).bind(params.id).first();
    if (!current) return json({ error: 'Character not found' }, 404);
    return json({
      error: 'This character was changed somewhere else since you loaded it',
      conflict: true,
      current_updated_at: current.updated_at,
    }, 409);
  }

  // The new version, so a caller can keep making guarded writes without
  // re-reading the whole character between them.
  const after = await env.DB.prepare(
    'SELECT updated_at FROM characters WHERE id = ?'
  ).bind(params.id).first();
  return json({ ok: true, updated_at: after?.updated_at ?? null });
}

// DELETE /api/character-creator/characters/:id — owner or G.M. removes the
// character. Their journal entries are KEPT.
//
// Everything that is only meaningful as part of this character goes with it,
// by foreign key: inventory, level history, unspent skill and power picks, the
// play log, and the grants a table handed out (migration 043). A campaign item they had claimed returns to the stash rather
// than vanishing — campaign_items.claimed_by_character_id is ON DELETE SET NULL
// — which is the right answer for an object the party still owns.
//
// The journal is the exception, and it is deliberate. journal_entries.character_id
// is ON DELETE CASCADE, so the plain delete would take a player's posts out of a
// log the G.M. and everyone else reads. Nobody's account of a session should
// disappear because its author retired a character. The column already models
// the alternative — its own comment says "NULL = campaign-level entry" — so the
// posts are detached first and stay in the campaign log under the email that
// wrote them.
//
// Batched, so the detach and the delete land together or not at all. Run apart,
// a failed DELETE leaves a live character whose journal has silently become
// campaign-level: nothing reports it and nobody would think to look.
export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const [detached] = await env.DB.batch([
    env.DB.prepare('UPDATE journal_entries SET character_id = NULL WHERE character_id = ?').bind(params.id),
    env.DB.prepare('DELETE FROM characters WHERE id = ?').bind(params.id),
  ]);

  // Returned so the client can say what survived rather than guess.
  return json({ ok: true, journal_entries_kept: detached?.meta?.changes ?? 0 });
}
