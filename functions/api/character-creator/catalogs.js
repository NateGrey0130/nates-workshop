// GET /api/character-creator/catalogs — skills, spells, and psionic powers.
//
// These used to be static JSON shipped with the deploy. They live in D1 now so
// the import tool can create missing entries live, the same as items. One
// endpoint rather than three because the wizard needs all of them at boot.

import { getUserEmail, unauthorized } from './_lib/auth.js';

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
    // Enchantments are small - 62 rows carrying about 5KB of description text,
    // production, 2026-09-05 - and the SHEET is what needs them: an item
    // carries slugs, and a slug without its definition renders as a slug.
    // The row count moves with the books; migration 036 added thirty charms to
    // the thirty-two 035 seeded. What decides whether this projection stays
    // honest is the KILOBYTES it adds to every boot, so measure those rather
    // than counting rows - `description` is the column that can grow without
    // the count moving at all.
    // `bonuses` rides along for the same reason skills' does, so whatever shows
    // an enchanted weapon can say what it adds without a second request.
    env.DB.prepare('SELECT slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book FROM enchantments ORDER BY applies_to, name').all(),
  ]);

  const body = JSON.stringify({
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

  // 25KB gzipped, fetched on EVERY wizard boot and EVERY sheet load, and
  // between imports it never changes - so it carries a validator and a warm
  // load revalidates to an empty 304. `classes.js` does the same thing; the
  // browser does the caching and js/api.js needs no change, because fetch
  // handles If-None-Match and 304 transparently. `no-cache` means "store, but
  // revalidate every time", never "serve stale"; private because the site is.
  //
  // The validator is a HASH OF THE BODY, and not the count-and-max-updated_at
  // aggregate classes.js uses, because none of these four tables has a
  // timestamp column - checked on production 2026-09-05, all four return zero
  // for created_at/updated_at in pragma_table_info. A count alone would go
  // stale on exactly the write this catalog exists for: the editor's PATCH
  // changes a percentage in place and moves neither the row count nor the max
  // id, so a cached client would keep the wrong number with no way to notice.
  // A content hash also survives the writes that never touch this Worker at
  // all - every `d1-apply.mjs` data script goes straight to D1, and no
  // app-level version counter would ever hear about them.
  //
  // What it does NOT save is database work: the four SELECTs above have
  // already run by the time there is a body to hash. This trades a little CPU
  // for ~25KB of transfer per warm load, which is the right way round on a
  // phone at a table and the wrong way round if this ever gets expensive to
  // query. Both halves are measured in docs/plans/20-power-descriptions.md.
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"catalogs-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };

  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
