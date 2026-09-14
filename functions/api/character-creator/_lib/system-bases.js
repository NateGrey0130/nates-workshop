// One game's own skill percentages, on the server side.
//
// BOOK-INGEST-AUDIT.md F83. The catalog holds one `base` and one `per_level`
// per skill, which was true enough while every book in it was Palladium's own.
// Heroes Unlimited is a different GAME and prints its own figure for every
// skill: 48 of the 55 names it shares with the catalog disagree.
//
// The substitution itself lives in `js/skill-base.js` and is shared with the
// wizard, deliberately. Two implementations of one rule is the pair that
// drifts, and this one has a precedent: `skills.base_formula` had a client
// resolver and a server path that never called it, so a skill taken at creation
// and the same skill taken at level-up disagreed for weeks (F18). This module
// is only the I/O the wizard does not need.

import { systemBaseMap, applySystemBases } from '../../../../apps/character-creator/js/skill-base.js';

export { applySystemBases };

/**
 * The system a character is played in, from its campaign, or null.
 *
 * Null is a real answer and not a failure: a character whose campaign has gone
 * takes the catalog's own numbers, which is what every character did before
 * this table existed. Refusing to resolve a skill because a campaign row is
 * missing would be a worse trade than showing a Palladium percentage.
 */
export async function systemForCharacter(env, characterId) {
  const row = await env.DB.prepare(
    `SELECT campaigns.system AS system
       FROM characters JOIN campaigns ON campaigns.id = characters.campaign_id
      WHERE characters.id = ?`
  ).bind(characterId).first();
  return row?.system ?? null;
}

/**
 * The override lookup for one system, as `applySystemBases` wants it.
 *
 * An empty map for a null system and for a system with no rows, which are the
 * same thing to every caller: `applySystemBases` returns its input untouched.
 * Today only Heroes Unlimited has any, so every Rifts and Palladium Fantasy
 * request takes the empty path.
 */
export async function loadSystemBases(env, system) {
  if (!system) return new Map();
  const { results } = await env.DB.prepare(
    'SELECT skill_name, base, per_level, source_book FROM skill_system_bases WHERE system = ?'
  ).bind(system).all();
  return systemBaseMap(results);
}
