// The catalog rows behind the skills a character holds, for the bonuses they
// carry.
//
// Physical skills are not only percentile: Boxing is "+1 attack per melee, +2
// parry & dodge, +1 roll, +2 P.S." Those live on the catalog row rather than on
// the character, so a correction to the catalog reaches everyone who already
// holds the skill — the same reason `crossReference` resolves names against the
// catalog instead of trusting what a class file says.
//
// Read here and not in compose.js because composeClass() takes no `env` and
// must stay usable from the wizard, which has no database at all.

import { resolveKeys } from './catalog-redirects.js';
import { selectInChunks } from './sql-chunk.js';

const LOOKUP_BATCH = 50;

/**
 * Returns the rows carrying a flat `bonuses` or a `level_bonuses` schedule,
 * ready for bonusesFromSkills(). A Hand to Hand skill has only the schedule -
 * fetching on `bonuses` alone left every fighting style behind.
 *
 * Returns [] — not null — when the character holds nothing that grants a bonus.
 * composeClass() treats null as "the caller does not know this character's
 * skills" and leaves the class untouched, which is a different statement.
 */
export async function loadSkillBonuses(env, character) {
  const names = [...new Set((character?.skills || [])
    .map((s) => (typeof s === 'string' ? s : s?.name))
    .filter(Boolean)
    .map(String))];
  if (!names.length) return [];

  const rows = [];
  for (let i = 0; i < names.length; i += LOOKUP_BATCH) {
    const batch = names.slice(i, i + LOOKUP_BATCH);
    const { results } = await env.DB
      .prepare(`SELECT name, bonuses, level_bonuses FROM skills
                 WHERE (bonuses IS NOT NULL OR level_bonuses IS NOT NULL)
                   AND name IN (${batch.map(() => '?').join(',')})`)
      .bind(...batch).all();
    rows.push(...results);
  }

  // A skill renamed or merged since the character took it still resolves, the
  // same way class markdown does. Without this, merging two catalog rows would
  // quietly strip the survivor's bonuses from every character holding the old
  // name — the merge coming undone, exactly what catalog_redirects exists for.
  const found = new Set(rows.map((r) => String(r.name).trim().toLowerCase()));
  const missing = names.filter((n) => !found.has(n.trim().toLowerCase()));
  if (missing.length) {
    const redirects = await resolveKeys(env, 'skills', missing);
    const ids = [...new Set([...redirects.values()])].filter((v) => v != null);
    if (ids.length) {
      const results = await selectInChunks(ids, (batch) => env.DB
        .prepare(`SELECT name, bonuses, level_bonuses FROM skills
                   WHERE (bonuses IS NOT NULL OR level_bonuses IS NOT NULL)
                     AND id IN (${batch.map(() => '?').join(',')})`)
        .bind(...batch));
      rows.push(...results);
    }
  }
  return rows;
}
