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
import { loadSystemBases, applySystemBases } from './system-bases.js';

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
  return applyGameSchedules(env, character, names, rows);
}

// This game's own W.P. schedule where its book prints one (BOOK-INGEST-AUDIT.md
// F102). A W.P.'s bonuses live in `level_bonuses`, so this loader is the one
// server path that reads a skill's schedule off the catalog, and the one that
// has to substitute - the wizard and the NPC generator already go through
// `applySystemBases` on the whole catalog.
//
// The character's game is read off the row where the caller already joined it
// (the sheet selects `campaign_system`), and looked up by campaign otherwise.
// No game, or a game with no schedules, and the rows come back untouched.
async function applyGameSchedules(env, character, names, rows) {
  let system = character?.campaign_system ?? null;
  if (!system && character?.campaign_id != null) {
    system = (await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?')
      .bind(character.campaign_id).first())?.system ?? null;
  }
  const overrides = await loadSystemBases(env, system);
  if (!overrides.size) return rows;
  // A held skill whose catalog row carries no schedule of its own, but whose
  // game prints one, was filtered out by the query above - bring it back so the
  // override has a row to land on.
  const have = new Set(rows.map((r) => String(r.name).trim().toLowerCase()));
  for (const n of names) {
    const key = n.trim().toLowerCase();
    const o = overrides.get(key);
    if (o?.level_bonuses != null && !have.has(key)) {
      rows.push({ name: o.skill_name ?? n, bonuses: null, level_bonuses: null });
      have.add(key);
    }
  }
  return applySystemBases(rows, overrides);
}
