// GET /api/character-creator/catalogs — skills, spells, and psionic powers.
//
// These used to be static JSON shipped with the deploy. They live in D1 now so
// the import tool can create missing entries live, the same as items. One
// endpoint rather than three because the wizard needs all of them at boot.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const [skills, spells, psionics] = await Promise.all([
    env.DB.prepare('SELECT name, category, base, per_level, systems FROM skills ORDER BY category, name').all(),
    env.DB.prepare('SELECT name, level, ppe FROM spells ORDER BY level, name').all(),
    env.DB.prepare('SELECT name, category, isp FROM psionic_powers ORDER BY category, name').all(),
  ]);

  return json({
    // `systems` is stored as a JSON array; NULL means the skill applies to both.
    skills: skills.results.map((s) => ({
      ...s,
      systems: s.systems ? JSON.parse(s.systems) : undefined,
    })),
    spells: spells.results,
    psionics: psionics.results,
  });
}
