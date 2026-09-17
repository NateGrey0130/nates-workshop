// POST /api/character-creator/characters/:id/level-confirm — owner/GM only.
// Applies a level-up the player confirmed (possibly tweaked from the proposal):
// Body: { to_level, pools: {hp_max: n, ...}, skills: [{name, pct}],
//         picks: [{name, override?}], grants, note }
// Updates the characters row and logs a level_history entry with what was
// ACTUALLY applied. Pool current values rise by the same amount as their max.
//
// Skill picks the class grants for crossing a level are banked in
// pending_skill_picks. `picks` spends some or all of them now; anything left
// unspent waits on the sheet. Levelling up is never blocked on choosing.
//
// `power_picks` does the same for the spells and psionic powers a level earns,
// banked in pending_power_picks. A spell pick names the level that granted it,
// because the spell LEVELS it may draw from belong to that grant rather than to
// the character.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { loadCharacterClass } from '../../_lib/class-loader.js';
import { xpTableFor, thresholdFor, skillGrantsFor, secondFormHitPointDice,
         rollSecondFormHitPoints } from '../../_lib/leveling.js';
import { diceBounds } from '../../../../../apps/character-creator/js/dice.js';
import { insertGrantStatements, remainingGrants, resolvePicks, pickErrors, dedupeCategories } from '../../_lib/skill-picks.js';
import { loadSystemBases, systemForCharacter } from '../../_lib/system-bases.js';
import { powerGrantsFor, resolvePowerPicks, remainingPowerGrants, insertPowerGrantStatements,
         powerPickErrors } from '../../_lib/power-picks.js';
import { validateCharacter, loadSkillCategories } from '../../_lib/validate-character.js';
import { loadCharacter } from '../../_lib/character-json.js';

const POOL_FIELDS = ['hp_max', 'sdc_max', 'mdc_max', 'ppe_max', 'isp_max'];

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const character = await loadCharacter(env, params.id);
  const toLevel = parseInt(b.to_level, 10);
  if (!Number.isFinite(toLevel) || toLevel <= character.level) {
    return json({ error: `to_level must be greater than current level (${character.level})` }, 400);
  }
  const cls = await loadCharacterClass(env, request.url, character);
  const table = xpTableFor(cls);
  const needed = thresholdFor(table, toLevel);
  if (needed == null) return json({ error: `to_level ${toLevel} is past the level cap (${table.length})` }, 400);
  if (character.xp < needed) return json({ error: `Not enough XP for level ${toLevel} (need ${needed}, have ${character.xp})` }, 400);

  const changes = { pools: {}, skills: [], grants: b.grants ?? [], note: b.note ?? null };
  const sets = ['level = ?'], binds = [toLevel];

  for (const field of POOL_FIELDS) {
    const to = b.pools?.[field];
    if (typeof to !== 'number' || to === character[field] || character[field] == null) continue;
    const delta = to - character[field];
    changes.pools[field] = { from: character[field], to };
    sets.push(`${field} = ?`); binds.push(to);
    const curField = field.replace('_max', '_current');
    if (character[curField] != null) {
      sets.push(`${curField} = ?`); binds.push(character[curField] + delta);
    }
  }

  // A SECOND FORM'S HIT POINTS (BOOK-INGEST-AUDIT F74, survey D5). The proposal
  // rolled one die per level gained on the form's own formula; they arrive as
  // `second_form_hp_rolls` and are appended to what the form holds, the way the
  // first form's maximum above takes the proposal's number. Unlike that number
  // they are CHECKED - there is no "tweak if your G.M. says so" for a roll the
  // sheet never shows as editable - and a request that sends none (a client
  // older than this) has them rolled here, so a level is never confirmed
  // without them. The form's current hit points rise by what was added, as the
  // first form's current value rises with its maximum.
  const form = cls?.second_form;
  const formState = character.second_form && typeof character.second_form === 'object'
    ? character.second_form : null;
  if (form && Array.isArray(formState?.hp_rolls) && formState.hp_rolls.length) {
    const { per } = secondFormHitPointDice(form.hit_points_base);
    if (per) {
      const gained = toLevel - character.level;
      let rolls = b.second_form_hp_rolls;
      if (rolls === undefined || rolls === null) {
        rolls = rollSecondFormHitPoints(form.hit_points_base, character.level, toLevel);
      } else {
        const bounds = diceBounds(per);
        if (!Array.isArray(rolls) || rolls.length !== gained
            || rolls.some((v) => !Number.isInteger(v) || v < bounds.min || v > bounds.max)) {
          return json({ error: `second_form_hp_rolls must be ${gained} roll(s) of ${per} (${bounds.min}-${bounds.max} each)` }, 400);
        }
      }
      const added = rolls.reduce((a, v) => a + v, 0);
      const next = { ...formState, hp_rolls: [...formState.hp_rolls, ...rolls] };
      if (Number.isInteger(formState.hp_current)) next.hp_current = formState.hp_current + added;
      changes.second_form = { name: form.name, hp_rolls: rolls, hp_added: added };
      sets.push('second_form = ?'); binds.push(JSON.stringify(next));
    }
  }

  let skills = character.skills;
  let skillsChanged = false;
  if (Array.isArray(b.skills) && b.skills.length) {
    const byName = new Map(b.skills.filter((s) => s && typeof s.pct === 'number').map((s) => [s.name, s.pct]));
    for (const s of skills) {
      const to = byName.get(s.name);
      if (to == null || to === s.pct) continue;
      changes.skills.push({ name: s.name, from: s.pct, to });
      s.pct = to;
    }
    skillsChanged = true;
  }

  // What this level-up earns. Banked whether or not it is spent right now.
  const grants = skillGrantsFor(cls, character.level, toLevel);
  const allowance = grants.reduce((n, g) => n + g.count, 0);
  // Related and secondary grants are kept apart: a secondary grant is
  // unrestricted, and folding it into the same list would unrestrict the
  // related picks with it.
  const related = grants.filter((g) => g.kind !== 'secondary');
  const secondaryAllowance = grants
    .filter((g) => g.kind === 'secondary')
    .reduce((n, g) => n + g.count, 0);
  const categories = related.some((g) => !g.categories)
    ? null // one unrestricted related grant makes the related picks unrestricted
    : dedupeCategories(related.flatMap((g) => g.categories || []));

  const picked = await resolvePicks(env, {
    // The character's own GAME may print different percentages
    // (BOOK-INGEST-AUDIT.md F83). Loaded here because this is where the
    // character id is known; an empty map for every system that has no
    // rows, which today is all of them but Heroes Unlimited.
    systemBases: await loadSystemBases(env, await systemForCharacter(env, params.id)),
    picks: b.picks,
    existingSkills: skills,
    allowance,
    categories,
    secondaryAllowance,
    level: toLevel,
    // A skill whose base is derived from an attribute needs them to resolve at
    // all — without this it stores 0 and climbs from 0 (F18).
    attributes: character.attributes,
  });
  if (picked.errors?.length) return pickErrors(picked.errors);

  if (picked.skills.length) {
    skills = skills.concat(picked.skills);
    skillsChanged = true;
    changes.picked = picked.skills.map((s) => ({ name: s.name, pct: s.pct, override: !!s.override }));
  }
  if (skillsChanged) { sets.push('skills = ?'); binds.push(JSON.stringify(skills)); }

  // Spells and psionic powers the crossed levels earn. Same shape as the skill
  // grants above and banked the same way, but validated against the cap the
  // granting level carries rather than against a category list.
  const powerGrants = powerGrantsFor(cls, character.level, toLevel);
  // loadCharacter does not join campaigns, so the system has to be fetched.
  // Without it the catalog filter is a silent no-op and a Rifts caster can
  // learn a Palladium-only spell - the kind of permissiveness that looks
  // exactly like a working feature.
  const campaign = powerGrants.length
    ? await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?')
        .bind(character.campaign_id).first()
    : null;
  let pickedPowers = [];
  let pickedSpent = new Map();
  let ppeSpent = 0;
  let powers = character.powers;
  // The P.P.E. maximum AFTER this level-up, which is what a Talent bought at
  // this level is paid from (BOOK-INGEST-AUDIT F101): the pools loop above may
  // have just raised it, under the same condition that loop applies.
  const ppeMaxAfter = typeof b.pools?.ppe_max === 'number' && character.ppe_max != null
    ? b.pools.ppe_max : character.ppe_max;
  const baseSpent = Number(character.ppe_base_spent) || 0;
  if (powerGrants.length && Array.isArray(b.power_picks) && b.power_picks.length) {
    const resolved = await resolvePowerPicks(env, {
      picks: b.power_picks,
      grants: powerGrants,
      existingPowers: powers,
      system: campaign?.system ?? null,
      ppeAvailable: ppeMaxAfter == null ? null : ppeMaxAfter - baseSpent,
    });
    if (resolved.errors?.length) return powerPickErrors(resolved.errors);
    pickedPowers = resolved.powers;
    pickedSpent = resolved.spent;
    ppeSpent = resolved.ppeSpent || 0;
  }
  if (pickedPowers.length) {
    powers = powers.concat(pickedPowers);
    sets.push('powers = ?'); binds.push(JSON.stringify(powers));
    changes.powers = pickedPowers.map((p) => ({ type: p.type, name: p.name, level: p.gained_at_level,
      ...(p.purchased ? { purchased: true, ppe: p.acquire_cost } : {}) }));
  }
  // A purchase lowers the base for good, and current P.P.E. cannot sit above the
  // maximum the character can now fill. CLAMPED rather than reduced by the
  // price: a character at 10 of 40 who buys a 6-point Talent is at 10 of 34.
  //
  // `sets` and `binds` pair one to one up to here - every entry so far has one
  // placeholder - which is what lets a ppe_current the pools loop already set be
  // found and lowered in place rather than written twice.
  if (ppeSpent > 0) {
    sets.push('ppe_base_spent = ?'); binds.push(baseSpent + ppeSpent);
    const cap = ppeMaxAfter - baseSpent - ppeSpent;
    const at = sets.indexOf('ppe_current = ?');
    const current = at >= 0 ? binds[at] : character.ppe_current;
    if (current != null && current > cap) {
      if (at >= 0) binds[at] = cap;
      else { sets.push('ppe_current = ?'); binds.push(cap); }
    }
    changes.ppe_base_spent = { from: baseSpent, to: baseSpent + ppeSpent };
  }

  // Check the result, not the request: the allowance grows with the level being
  // reached, so validate against toLevel rather than the level being left.
  const { violations } = validateCharacter({
    character: { level: toLevel }, cls, skills, attributes: character.attributes,
    abilities: character.abilities,
    catalog: cls ? await loadSkillCategories(env) : null,
  });
  if (violations.length) {
    return json({ error: 'That level-up would break the class rules', violations }, 422);
  }

  sets.push("updated_at = datetime('now')");

  // One batch. A level-up that raised the level but lost its picks, or banked
  // grants against a level-up that did not land, would both be worse than a
  // clean failure.
  const statements = [
    env.DB.prepare(`UPDATE characters SET ${sets.join(', ')} WHERE id = ?`).bind(...binds, params.id),
    env.DB.prepare(
      `INSERT INTO level_history (character_id, from_level, to_level, xp_at_levelup, changes)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(params.id, character.level, toLevel, character.xp, JSON.stringify(changes)),
  ];

  // Bank only what was not spent in this same request. The consume-from-the-
  // earliest rule is shared with the create path, which banks the same way for
  // a character that starts above level 1.
  const unspent = allowance - picked.skills.length;
  if (unspent > 0) {
    statements.push(...insertGrantStatements(env, params.id,
      remainingGrants(grants, picked.skills.length)));
  }

  // The same for powers, counted PER GRANT rather than as one total: a spell
  // grant is identified by the level that earned it, and banking two level-4
  // spells against a level-2 grant would hand them the wrong cap when they are
  // eventually spent.
  // Handed out by resolvePowerPicks, keyed by the kind it actually consumed.
  // Rebuilt here from each power's type, a Talent taken at level-up was keyed
  // `spell`, subtracted from nothing, and its grant banked again in full.
  const spentByKey = new Map(pickedSpent);
  const powerRemaining = remainingPowerGrants(powerGrants, spentByKey);
  if (powerRemaining.length) {
    statements.push(...insertPowerGrantStatements(env, params.id, powerRemaining));
  }

  await env.DB.batch(statements);

  return json({
    ok: true,
    level: toLevel,
    changes,
    picks_granted: allowance,
    picks_spent: picked.skills.length,
    picks_pending: unspent,
    powers_granted: powerGrants.reduce((n, g) => n + g.count, 0),
    powers_spent: pickedPowers.length,
    powers_pending: powerRemaining.reduce((n, g) => n + g.count, 0),
  });
}
