// POST /api/character-creator/characters/:id/variant — owner/GM only.
//
//   { to_variant }                          → a proposal, writes nothing
//   { to_variant, confirm: true, ... }      → applies what was accepted
//
// A hatchling grows into an adult. The stages share lore, skills and abilities
// and differ in attribute dice, pools and what the class grants, so changing
// stage is not a re-roll of the character — it is a change of which definition
// its numbers come from, plus new rolls for the parts the stage actually sets.
//
// Two-step for the same reason levelling up is: the rolls are the point, and a
// roll you did not see happen is a roll you cannot trust. The proposal shows
// old against new and the confirm carries back only what was accepted, so
// keeping a hatchling's I.Q. through adulthood is a decision you can make per
// attribute rather than a thing the endpoint decides for you.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { getStored } from '../../_lib/class-store.js';
import { parseClassMarkdown, applyVariant } from '../../../../../apps/character-creator/js/parser.js';
import { composeClass } from '../../../../../apps/character-creator/js/compose.js';
import { evalDice, rollPoolFormula } from '../../../../../apps/character-creator/js/dice.js';
import { loadCharacter } from '../../_lib/character-json.js';
import { loadClass } from '../../_lib/class-loader.js';
import { validateCharacter, loadSkillCategories } from '../../_lib/validate-character.js';

const ATTRS = ['IQ', 'ME', 'MA', 'PS', 'PP', 'PE', 'PB', 'Spd'];
// name on the class → the character's two columns.
const POOLS = [
  ['hit_points_base', 'hp'],
  ['sdc_base', 'sdc'],
  ['mdc_base', 'mdc'],
  ['ppe_base', 'ppe'],
];

async function loadBoth(env, character) {
  const stored = await getStored(env, character.class_id);
  const parsed = stored ? parseClassMarkdown(stored.markdown) : null;
  if (!parsed?.ok) return null;
  return parsed.data;
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const character = await loadCharacter(env, params.id);
  const base = await loadBoth(env, character);
  if (!base) return json({ error: 'That character\'s class could not be resolved' }, 409);

  const variants = Array.isArray(base.variants) ? base.variants : [];
  if (!variants.length) return json({ error: 'This class has no stages to change between' }, 409);

  const b = await readJson(request) || {};
  const to = typeof b.to_variant === 'string' ? b.to_variant.trim() : '';
  if (!variants.some((v) => v.id === to)) {
    return json({ error: `"${to}" is not a stage of this class`, stages: variants.map((v) => v.id) }, 400);
  }
  if (to === character.class_variant) {
    return json({ error: 'The character is already at that stage' }, 409);
  }

  const from = applyVariant(base, character.class_variant);
  const next = applyVariant(base, to);
  const attrs = character.attributes || {};

  // ─── propose ───
  if (!b.confirm) {
    // Only attributes the new stage actually specifies dice for are re-rolled.
    // A stage that says nothing about I.Q. is not an opinion that I.Q. should
    // change, so it is left out of the proposal entirely.
    const attributes = {};
    for (const a of ATTRS) {
      const dice = next.attribute_dice?.[a];
      if (!dice || dice === from.attribute_dice?.[a]) continue;
      attributes[a] = { from: attrs[a] ?? null, rolled: evalDice(dice), dice };
    }

    // Pools whose formula the stage changes. A pool the character does not have
    // at all is skipped: a stage granting M.D.C. to a creature that has been
    // tracking hit points is a bigger change than this endpoint should invent.
    const pools = {};
    for (const [formulaKey, pool] of POOLS) {
      if (next[formulaKey] == null || next[formulaKey] === from[formulaKey]) continue;
      if (character[`${pool}_max`] == null) continue;
      pools[pool] = {
        from_max: character[`${pool}_max`],
        // The stage's own bonus rides with the roll, exactly as it does at
        // creation — a variant that raises a pool must not lose it here.
        rolled_max: rollPoolFormula(next[formulaKey], attrs, next.bonuses?.pools?.[pool]),
        formula: next[formulaKey],
      };
    }

    return json({
      proposal: {
        from_variant: character.class_variant, from_name: from.name,
        to_variant: to, to_name: next.name,
        attributes, pools,
        // Advisory: bonuses are read from the class at render time, so these
        // change the moment the stage does, with nothing to confirm.
        bonuses_from: from.bonuses ?? null,
        bonuses_to: next.bonuses ?? null,
      },
    });
  }

  // ─── apply ───
  const newAttrs = { ...attrs };
  for (const [a, v] of Object.entries(b.attributes || {})) {
    if (ATTRS.includes(a) && Number.isFinite(v) && v > 0) newAttrs[a] = Math.trunc(v);
  }

  // The class rules are checked against the stage being moved TO — its
  // attribute_requirements may differ, and a character that would not meet them
  // should not arrive there quietly.
  // Validated against the stage being moved TO, composed with the O.C.C. if
  // there is one — otherwise a Chiang-Ku Wizard would fail on skills its
  // occupation grants and the dragon does not.
  const occ = character.occ_class_id
    ? await loadClass(env, request.url, character.occ_class_id, character.occ_class_variant)
    : null;
  // `next` is already the target stage and `occ` already has its own variant
  // applied, so the variants are blanked here rather than applied twice.
  const target = composeClass({ rcc: next, occ, character: { ...character, class_variant: null, occ_class_variant: null } });
  const { violations } = validateCharacter({
    character: { level: character.level },
    cls: target,
    skills: character.skills || [],
    attributes: newAttrs,
    abilities: character.abilities,
    catalog: await loadSkillCategories(env),
  });
  if (violations.length) {
    return json({ error: 'That stage\'s rules would be broken', violations }, 422);
  }

  const sets = ['class_variant = ?', 'attributes = ?', "updated_at = datetime('now')"];
  const vals = [to, JSON.stringify(newAttrs)];
  const applied = { pools: {}, attributes: {} };

  for (const a of ATTRS) {
    if (newAttrs[a] !== attrs[a]) applied.attributes[a] = { from: attrs[a] ?? null, to: newAttrs[a] };
  }

  // Current rises by the same amount as max, exactly as a level-up treats pools:
  // growing up should not quietly heal whatever damage the character was
  // carrying, nor leave it on a hatchling's current with an adult's maximum.
  for (const [, pool] of POOLS) {
    const asked = b.pools?.[pool];
    if (!Number.isFinite(asked) || asked <= 0) continue;
    const oldMax = character[`${pool}_max`];
    if (oldMax == null) continue;
    const delta = Math.trunc(asked) - oldMax;
    sets.push(`${pool}_max = ?`, `${pool}_current = ?`);
    vals.push(Math.trunc(asked), Math.max(0, (character[`${pool}_current`] ?? oldMax) + delta));
    applied.pools[pool] = { from: oldMax, to: Math.trunc(asked) };
  }

  const changes = {
    kind: 'variant',
    from_variant: character.class_variant, from_name: from.name,
    to_variant: to, to_name: next.name,
    ...applied,
  };

  await env.DB.batch([
    env.DB.prepare(`UPDATE characters SET ${sets.join(', ')} WHERE id = ?`).bind(...vals, params.id),
    // Recorded in level_history because that is already the table answering
    // "what actually changed, and when". from_level equals to_level: the
    // character did not gain a level, it became something else.
    env.DB.prepare(
      `INSERT INTO level_history (character_id, from_level, to_level, xp_at_levelup, changes)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(params.id, character.level, character.level, character.xp, JSON.stringify(changes)),
  ]);

  return json({ ok: true, class_variant: to, name: next.name, applied });
}
