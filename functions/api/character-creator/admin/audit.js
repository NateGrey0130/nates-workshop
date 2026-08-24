// GET /api/character-creator/admin/audit — admin only. Read-only.
//
// Validation applies to new writes; characters saved before it existed keep
// loading and saving whatever state they are in. This is how you find out which
// ones break a rule, so you can decide case by case rather than having the
// server decide for you.
//
// Modifies nothing, ever. Safe to run whenever.

import { requireAdmin, json } from '../_lib/auth.js';
import { loadPublished } from '../_lib/class-store.js';
import { composeClass } from '../../../../apps/character-creator/js/compose.js';
import { validateCharacter, loadSkillCategories } from '../_lib/validate-character.js';
import { loadPowerCatalog } from '../_lib/power-picks.js';
import { paging } from '../_lib/paging.js';
import { decodeCharacter } from '../_lib/character-json.js';

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { limit, offset } = paging(request, { defaultLimit: 500, maxLimit: 500 });

  // Retired classes included: a character on one still needs auditing, and
  // excluding them would report every such character as unvalidatable.
  const { classes } = await loadPublished(env, { includeRetired: true });
  const catalog = await loadSkillCategories(env);
  const byId = new Map(classes.map((c) => [c.id, c]));

  const { results } = await env.DB.prepare(
    `SELECT characters.id, characters.name, characters.class_id, characters.class_variant,
            characters.occ_class_id, characters.occ_class_variant, characters.psychic_tier,
            characters.psychic_shape, characters.mos,
            characters.level, characters.xp, characters.attributes, characters.skills,
            characters.abilities, characters.powers,
            characters.hp_max, characters.sdc_max, characters.mdc_max,
            characters.ppe_max, characters.isp_max,
            characters.player_email, characters.campaign_id,
            campaigns.system AS campaign_system
     FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id
     ORDER BY characters.id LIMIT ? OFFSET ?`
  ).bind(limit, offset).all();

  // One catalog load covers every character: rows keep their `system` column
  // and the validator applies each character's own campaign system, so the
  // audit does not pay a lookup per character.
  const powerNames = [...new Set(results.flatMap((r) => {
    try { return (JSON.parse(r.powers || '[]') || []).map((p) => String(p?.name || '').trim()); }
    catch { return []; }
  }).filter(Boolean))];
  const powerCatalog = powerNames.length ? await loadPowerCatalog(env, powerNames, null) : null;

  const offenders = [];
  const unvalidatable = [];

  for (const row of results) {
    // Decoded BEFORE composing: composeClass reads the character's abilities,
    // and an ability's pool bonus (Super-Tough's 3D4x10 M.D.C.) has to fold in
    // or every character holding one reads as out of range. The compose used
    // to run against the raw row, where `abilities` was still a JSON string.
    decodeCharacter(row);
    // Both classes, and the character's variant, or the audit judges a
    // Chiang-Ku Wizard against the dragon alone — reporting every skill its
    // O.C.C. legitimately grants as a violation.
    const cls = composeClass({
      rcc: byId.get(row.class_id) || null,
      occ: row.occ_class_id ? byId.get(row.occ_class_id) || null : null,
      character: row,
    });

    const { skipped, violations, warnings } = validateCharacter({
      // xp as well as level: a character whose XP is behind its level warns,
      // and a validator that is never handed the number can never say so.
      character: { level: row.level, xp: row.xp, psychic_shape: row.psychic_shape,
                   mos: row.mos, occ_class_id: row.occ_class_id },
      cls, skills: row.skills, attributes: row.attributes,
      abilities: row.abilities, catalog,
      // The F2 additions: creation-time powers, pool maxima against the class
      // formulas, attribute ceilings. This endpoint is the read-only first
      // pass the audit proposed - findings land here, and only new WRITES are
      // ever refused.
      powers: row.powers,
      pools: { hp_max: row.hp_max, sdc_max: row.sdc_max, mdc_max: row.mdc_max,
               ppe_max: row.ppe_max, isp_max: row.isp_max },
      system: row.campaign_system ?? null,
      powerCatalog,
    });

    if (skipped) {
      unvalidatable.push({ id: row.id, name: row.name, class_id: row.class_id,
        reason: 'No class definition resolves for that class_id' });
      continue;
    }
    if (violations.length || warnings.length) {
      offenders.push({
        id: row.id, name: row.name, class_id: row.class_id, level: row.level,
        player_email: row.player_email, campaign_id: row.campaign_id,
        violations, warnings,
      });
    }
  }

  const row = await env.DB.prepare('SELECT count(*) AS n FROM characters').first();

  // Just the numbers, for the catalog page's badge — fetched on every load,
  // so the full offender payload would be waste there.
  if (new URL(request.url).searchParams.get('counts_only') === '1') {
    return json({
      checked: results.length,
      blocked: offenders.filter((o) => o.violations.length).length,
      warned: offenders.filter((o) => !o.violations.length).length,
      unvalidatable: unvalidatable.length,
    });
  }

  return json({
    checked: results.length,
    total_characters: row?.n ?? 0,
    // A character with only warnings is not blocked from saving.
    blocked: offenders.filter((o) => o.violations.length).length,
    clean: results.length - offenders.length - unvalidatable.length,
    offenders,
    unvalidatable,
    // By rule, so a systemic problem is obvious at a glance rather than needing
    // the whole list read.
    by_rule: offenders.flatMap((o) => [...o.violations, ...o.warnings]).reduce((acc, v) => {
      acc[v.rule] = (acc[v.rule] || 0) + 1;
      return acc;
    }, {}),
    limit, offset,
  });
}
