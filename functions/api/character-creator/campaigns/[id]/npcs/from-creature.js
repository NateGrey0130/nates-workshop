// POST /api/character-creator/campaigns/:id/npcs/from-creature
//   { slug, count?, name? }
// G.M. only. Rolls `count` (1-12, default 1) individuals of one species from
// the books (the `creatures` catalog, migration 074) into this campaign as
// statted NPC sheets, and returns 201 { characters: [{ id, name }] }.
//
// Phase 3 of the NPC / bestiary work. from-notable next door COPIES a named
// person's printed numbers; a species prints DICE, so this ROLLS them - each
// individual separately, so six wolves are six wolves and not one wolf six
// times.
//
// NOT through createCharacter(), for from-notable's reason: there is no class
// to validate against, and the book's formulas are the ruling. The row is
// written directly, with class_id `creature:<slug>` - the namespace
// from-notable's `notable:` established, which no class id can collide with.
//
// REFUSE, NEVER PAD (decided 2026-09-17). A formula js/creature-roll.js cannot
// read is a 422 naming the field and the formula, and nothing is written. The
// data scripts check every row against the same grammar before it lands, so
// this is the backstop, not the plan.
//
// ONE-WAY, as from-notable's copies are: a fight changes the individual, never
// the species.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';
import { rollCreature, CreatureGap } from '../../../../../../apps/character-creator/js/creature-roll.js';
import { moveToLibrary } from '../../../_lib/npc-snapshot.js';

const MAX_COUNT = 12;

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const slug = typeof b.slug === 'string' ? b.slug.trim().toLowerCase() : '';
  if (!slug) return json({ error: 'Missing required field: slug' }, 400);
  const count = b.count == null ? 1 : Number(b.count);
  if (!Number.isInteger(count) || count < 1 || count > MAX_COUNT) {
    return json({ error: `count must be a whole number from 1 to ${MAX_COUNT}` }, 400);
  }

  const row = await env.DB.prepare('SELECT * FROM creatures WHERE slug = ?').bind(slug).first();
  if (!row) return json({ error: `No creature called ${slug}` }, 404);
  const { results: attacks } = await env.DB.prepare(
    `SELECT name, damage, is_mega_damage, range, note FROM stat_attacks
     WHERE owner_kind = 'creature' AND owner_slug = ? ORDER BY sort, id`
  ).bind(slug).all();

  // Roll every individual before writing any: a refusal leaves nothing behind.
  let rolls;
  try {
    rolls = Array.from({ length: count }, () => rollCreature(row));
  } catch (err) {
    if (err instanceof CreatureGap) {
      return json({ error: `The book's ${row.name} cannot be rolled: ${err.message}`, field: err.field }, 422);
    }
    throw err;
  }

  const parse = (v, fallback) => { try { return v ? JSON.parse(v) : fallback; } catch { return fallback; } };
  const combat = parse(row.combat, {});
  const bio = Object.fromEntries(Object.entries({
    race: row.name, alignment: row.alignment, height: row.size, weight: row.weight,
  }).filter(([, v]) => v != null && v !== ''));
  const notes = notesFor(row, attacks || []);
  const base = typeof b.name === 'string' && b.name.trim() ? b.name.trim() : row.name;
  const names = rolls.map((_, i) => (count > 1 ? `${base} ${i + 1}` : base));

  const insert = env.DB.prepare(
    `INSERT INTO characters (
       campaign_id, player_email, name, class_id, level, xp,
       attributes, attribute_bonuses, rolled_bonuses, skills, powers, abilities,
       hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current,
       ppe_max, ppe_current, isp_max, isp_current,
       bio, combat, saves, armor, notes, second_form, kind
     ) VALUES (?, ?, ?, ?, 1, 0, ?, '{}', '{}', '[]', '[]', '[]', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
               ?, ?, '{}', '[]', ?, '{}', 'npc')
     RETURNING id`
  );
  const results = await env.DB.batch(rolls.map(({ attributes, pools }, i) => insert.bind(
    params.id, guard.email, names[i], `creature:${row.slug}`,
    JSON.stringify(attributes),
    pools.hp, pools.hp, pools.sdc, pools.sdc, pools.mdc, pools.mdc,
    pools.ppe, pools.ppe, pools.isp, pools.isp,
    JSON.stringify(bio), JSON.stringify(combat), notes,
  )));

  const made = results.map((r, i) => ({ id: r.results[0].id, name: names[i] }));
  // `to_library`: into the G.M.'s NPC library instead (migration 079) - rolled
  // and written by the path above, then moved, so each roll has one path.
  if (b.to_library) {
    const library = [];
    for (const m of made) library.push(await moveToLibrary(env, m.id, guard.email, 'creature'));
    return json({ library }, 201);
  }
  return json({ characters: made }, 201);
}

// The book's prose, in from-notable's order: what it hits with, what it can
// do, then where it lives and who it runs with.
function notesFor(row, attacks) {
  const part = (label, text) => (text ? `${label}: ${text}` : null);
  const attackLines = attacks.map((a) => `- ${a.name}: ${[a.damage, a.range && `range ${a.range}`, a.note]
    .filter(Boolean).join(', ')}`);
  return [
    `A ${row.name}, rolled from ${row.source_book || 'the book'}. The book's dice, rolled once for this one; no class rules apply.`,
    attackLines.length ? `Attacks:\n${attackLines.join('\n')}` : null,
    row.horror_factor != null ? `Horror Factor: ${row.horror_factor}` : null,
    row.ar != null ? `Natural A.R.: ${row.ar}` : null,
    part('Pools as printed', row.pools_note),
    part('Other bonuses', row.bonuses_note),
    part('Skills', row.skills_note),
    part('Natural abilities', row.natural_abilities),
    part('Magic', row.magic),
    part('Psionics', row.psionics),
    part('Habitat', row.habitat),
    part('Allies', row.allies),
    part('Enemies', row.enemies),
  ].filter(Boolean).join('\n\n');
}
