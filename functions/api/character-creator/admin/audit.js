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
import { applyVariant, combineClasses } from '../../../../apps/character-creator/js/parser.js';
import { validateCharacter, loadSkillCategories } from '../_lib/validate-character.js';
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
    `SELECT id, name, class_id, class_variant, occ_class_id, occ_class_variant,
            level, attributes, skills, player_email, campaign_id
     FROM characters ORDER BY id LIMIT ? OFFSET ?`
  ).bind(limit, offset).all();

  const offenders = [];
  const unvalidatable = [];

  for (const row of results) {
    // Both classes, and the character's variant, or the audit judges a
    // Chiang-Ku Wizard against the dragon alone — reporting every skill its
    // O.C.C. legitimately grants as a violation.
    const rcc = applyVariant(byId.get(row.class_id) || null, row.class_variant);
    const cls = row.occ_class_id
      ? combineClasses(rcc, applyVariant(byId.get(row.occ_class_id) || null, row.occ_class_variant))
      : rcc;
    decodeCharacter(row);

    const { skipped, violations, warnings } = validateCharacter({
      character: { level: row.level }, cls, skills: row.skills, attributes: row.attributes, catalog,
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
