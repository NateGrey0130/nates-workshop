// GET /api/character-creator/catalogs — skills, spells, and psionic powers.
//
// These used to be static JSON shipped with the deploy. They live in D1 now so
// the import tool can create missing entries live, the same as items. One
// endpoint rather than three because the wizard needs all of them at boot.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const [skills, spells, psionics, enchantments] = await Promise.all([
    // source_book rides along in all three so the pickers can filter on it —
    // typing "rifts main" should narrow a list the same way a name does.
    // `bonuses` travels with the row so the wizard can apply what a skill grants
    // while the character is still being built. Without it the wizard shows
    // nothing until the character is saved and the sheet recomputes, which is
    // the same numbers arriving late and reads as a bug.
    // `level_bonuses` rides along with `bonuses` because the WIZARD computes
    // combat bonuses client-side from these very rows — see skillBonusClass()
    // in app.js. Leaving it out of the projection did not fail loudly: the
    // sheet was right, because its endpoint selects the column itself, and
    // only the wizard silently showed a fighting style granting nothing.
    // Roughly 28KB across the 36 rows that have one.
    env.DB.prepare('SELECT name, category, base, base_formula, per_level, systems, source_book, bonuses, level_bonuses FROM skills ORDER BY category, name').all(),
    // `system` likewise: the wizard filters spells and powers by the campaign's
    // system client-side, the same way it already does skills.
    env.DB.prepare('SELECT name, level, ppe, ppe_note, system, source_book FROM spells ORDER BY level, name').all(),
    // min_tier is in the boot projection because the powers picker filters on
    // it client-side; without it there is nothing to gate against.
    env.DB.prepare('SELECT name, category, isp, isp_note, min_tier, system, source_book FROM psionic_powers ORDER BY category, name').all(),
    // Enchantments are small - 32 rows - and the SHEET is what needs them: an
    // item carries slugs, and a slug without its definition renders as a slug.
    // `bonuses` rides along for the same reason skills' does, so whatever shows
    // an enchanted weapon can say what it adds without a second request.
    env.DB.prepare('SELECT slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book FROM enchantments ORDER BY applies_to, name').all(),
  ]);

  return json({
    // `systems` is stored as a JSON array; NULL means the skill applies to both.
    skills: skills.results.map((s) => ({
      ...s,
      systems: s.systems ? JSON.parse(s.systems) : undefined,
    })),
    spells: spells.results,
    psionics: psionics.results,
    // `bonuses` is stored as a JSON string, decoded here so every caller does
    // not have to remember to - the same courtesy `systems` gets above.
    enchantments: enchantments.results.map((e) => ({
      ...e,
      bonuses: e.bonuses ? JSON.parse(e.bonuses) : undefined,
    })),
  });
}
