// POST /api/character-creator/campaigns/:id/npcs/from-notable — { slug, name? }
// G.M. only. Copies one notable NPC (migration 072) into this campaign as a
// statted NPC sheet, and returns 201 { id, name }.
//
// Phase 2 of the NPC / bestiary work. The generator next door ROLLS an NPC from
// a class; this COPIES one the book already statted - the mayor, the cult
// leader, the Lord Magus - with the numbers the book printed for that person.
//
// WHY THIS DOES NOT GO THROUGH createCharacter(): that path validates a
// character against its CLASS, and a book NPC has none to validate against.
// The book prints one person's totals - attributes, pools, combat numbers with
// every bonus already folded in - and those numbers ARE the ruling. Composing a
// published class over them would count the class's bonuses twice. So the row
// is written directly, with class_id `notable:<slug>`: a namespace no class id
// can collide with (class ids are kebab-case slugs, which have no colon), and
// one that says where the sheet came from. Every server path already treats a
// class it cannot load as "no class rules", and the admin audit reports these
// rows as book NPCs rather than as broken ones.
//
// ONE-WAY: the catalog row is the book, the character is this table's copy.
// A fight, a level-up or a rename changes only the copy.
//
// The prose the book gives - magic, psionics, super powers, gear, the attacks
// its stat block lists - lands in the sheet's notes, where the G.M. reads it at
// the table. Linking those to the catalogs is a later decision (2026-09-17).

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { gm: true });
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const slug = typeof b.slug === 'string' ? b.slug.trim().toLowerCase() : '';
  if (!slug) return json({ error: 'Missing required field: slug' }, 400);

  const row = await env.DB.prepare('SELECT * FROM notable_npcs WHERE slug = ?').bind(slug).first();
  if (!row) return json({ error: `No notable NPC called ${slug}` }, 404);
  const { results: attacks } = await env.DB.prepare(
    `SELECT name, damage, is_mega_damage, range, note FROM stat_attacks
     WHERE owner_kind = 'notable_npc' AND owner_slug = ? ORDER BY sort, id`
  ).bind(slug).all();

  const parse = (v, fallback) => { try { return v ? JSON.parse(v) : fallback; } catch { return fallback; } };
  const attributes = parse(row.attributes, {});
  const combat = parse(row.combat, {});
  // Every held skill at the book's figure, marked as the class's own so the
  // sheet lists it with them. No per-level step: the book gives this person's
  // number, not a curve.
  const skills = parse(row.skills, []).map((s) => ({
    name: s.name, category: 'Class', pct: s.pct, per_level: 0, type: 'occ',
  }));

  const bio = Object.fromEntries(Object.entries({
    real_name: row.real_name, title: row.title, race: row.race, occupation: row.occ,
    alignment: row.alignment, age: row.age, height: row.height, weight: row.weight,
    money: row.money,
  }).filter(([, v]) => v != null && v !== ''));

  const name = typeof b.name === 'string' && b.name.trim() ? b.name.trim() : row.name;
  const character = await env.DB.prepare(
    `INSERT INTO characters (
       campaign_id, player_email, name, class_id, level, xp,
       attributes, attribute_bonuses, rolled_bonuses, skills, powers, abilities,
       hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current,
       ppe_max, ppe_current, isp_max, isp_current,
       bio, combat, saves, armor, notes, second_form, kind
     ) VALUES (?, ?, ?, ?, ?, 0, ?, '{}', '{}', ?, '[]', '[]', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
               ?, ?, '{}', '[]', ?, '{}', 'npc')
     RETURNING id`
  ).bind(
    params.id, guard.email, name, `notable:${row.slug}`, row.level || 1,
    JSON.stringify(attributes), JSON.stringify(skills),
    row.hp, row.hp, row.sdc, row.sdc, row.mdc, row.mdc,
    row.ppe, row.ppe, row.isp, row.isp,
    JSON.stringify(bio), JSON.stringify(combat), notesFor(row, attacks || []),
  ).first();

  return json({ id: character.id, name }, 201);
}

// The book's prose, in the order a G.M. reaches for it at a table: what it
// hits with, then what it can do, then who it is.
function notesFor(row, attacks) {
  const part = (label, text) => (text ? `${label}: ${text}` : null);
  const attackLines = attacks.map((a) => `- ${a.name}: ${[a.damage, a.range && `range ${a.range}`, a.note]
    .filter(Boolean).join(', ')}`);
  return [
    `From ${row.source_book || 'the book'} - the book's numbers, copied. No class rules apply.`,
    attackLines.length ? `Attacks:\n${attackLines.join('\n')}` : null,
    row.horror_factor != null ? `Horror Factor: ${row.horror_factor}` : null,
    row.ar != null ? `A.R.: ${row.ar}` : null,
    part('Other bonuses', row.bonuses_note),
    part('Other skills', row.skills_note),
    part('Natural abilities', row.natural_abilities),
    part('Magic', row.magic),
    part('Psionics', row.psionics),
    part('Super powers', row.super_powers),
    part('Cybernetics', row.cybernetics),
    part('Weapons and equipment', row.weapons_and_equipment),
    part('Disposition', row.disposition),
    part('Allies', row.allies),
    part('Enemies', row.enemies),
  ].filter(Boolean).join('\n\n');
}
