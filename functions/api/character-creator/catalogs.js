// GET /api/character-creator/catalogs — skills, spells, psionic powers and
// super abilities.
//
// These used to be static JSON shipped with the deploy. They live in D1 now so
// the import tool can create missing entries live, the same as items. One
// endpoint rather than three because the wizard needs all of them at boot.

import { getUserEmail, unauthorized } from './_lib/auth.js';
import { applySystemBases, systemBaseMap } from '../../../apps/character-creator/js/skill-base.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  // `?system=` substitutes THAT GAME's own skill percentages into the rows
  // before they are sent (BOOK-INGEST-AUDIT.md F83). Two callers, two needs:
  //
  //   the SHEET passes one - it knows the character's campaign, and it is a
  //     classic script that cannot import the helper to do it itself;
  //   the WIZARD passes none - it boots before the player has picked a game,
  //     so it takes the raw rows plus `skillSystemBases` and derives whenever
  //     the system becomes known.
  //
  // One implementation either way: both sides call `applySystemBases`. The
  // ETag is a hash of the BODY, so the two answers cache apart on their own.
  const system = new URL(request.url).searchParams.get('system') || null;

  const [skills, spells, psionics, supers, talents, enchantments, totems, systemBases] = await Promise.all([
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
    // system client-side, the same way it already does skills. `tradition` for
    // the same reason: a level-gated pick filters on it (BOOK-INGEST-AUDIT F57).
    env.DB.prepare('SELECT name, level, ppe, ppe_note, system, source_book, tradition FROM spells ORDER BY level, name').all(),
    // min_tier is in the boot projection because the powers picker filters on
    // it client-side; without it there is nothing to gate against.
    env.DB.prepare('SELECT name, category, isp, isp_note, min_tier, system, source_book FROM psionic_powers ORDER BY category, name').all(),
    // Heroes Unlimited's fifth power kind, picked in the same wizard step as
    // spells and psionics, so it boots with them.
    //
    // THE PROJECTION IS THE POINT HERE, more than for any other table on this
    // list. 364 rows carry 994KB of `description` in production (2026-09-13) -
    // forty times the whole rest of this payload - and the picker needs a name,
    // a tier and the stat line, never the prose. The columns below are 24KB
    // raw, and `range`, `duration` and `damage` are 2.5KB of that because only
    // 41, 30 and 22 rows respectively have one: a super ability is usually a
    // permanent trait with nothing to print in a stat block.
    //
    // `tier` is what the picker GATES on, the way min_tier gates psionics - a
    // category granting "one major and one minor" filters this list twice.
    env.DB.prepare('SELECT name, tier, system, source_book, range, duration, damage FROM super_abilities ORDER BY tier, name').all(),
    // Talents, the ninth catalog (migration 063, BOOK-INGEST-AUDIT F76). BOTH
    // costs ride along because both are what the picker has to show: a player
    // choosing a Talent is spending permanent P.P.E. to acquire it and will
    // spend more every time it is used, and a picker showing one number would
    // be showing the wrong one.
    //
    // `min_character_level` GATES the picker the way `tier` gates a super
    // ability, and `prerequisite` and `form_required` are shown rather than
    // enforced - neither is checkable here, and a Morphus is not modelled at
    // all. NO `description`, for the reason the three catalogs above give: the
    // picker needs a name, the costs and the gates, and descriptions travel
    // with the character through loadPowerDescriptions.
    env.DB.prepare(
      `SELECT name, tier, acquire_ppe, ppe, ppe_note, min_character_level,
              form_required, prerequisite, system, source_book, range, duration
         FROM talents ORDER BY tier, name`
    ).all(),
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
    // The animals a class with `totem:` picks from (BOOK-INGEST-AUDIT.md F56).
    // The WIZARD needs them: the pick is made mid-build, and it shows what each
    // grants and folds the chosen row into the composed class. The sheet does
    // not - the server composes the character it shows.
    env.DB.prepare('SELECT slug, name, skills, bonuses, bonus_note, powers, description, source_book FROM totems ORDER BY name').all(),
    // A skill's percentage where one GAME prints a different one
    // (BOOK-INGEST-AUDIT.md F83). EVERY system's rows ship, not one system's,
    // because this endpoint is called ONCE at boot and the wizard does not yet
    // know which game the player is about to build in - the same reason
    // `skills.systems` is filtered client-side rather than in the query.
    // Small, and all of them Heroes Unlimited's today. The row count lives in
    // `docs/operations.md`'s clean-run table, which a test pins; this comment
    // carried its own copy and was wrong about it.
    env.DB.prepare('SELECT skill_name, system, base, per_level, note, source_book FROM skill_system_bases ORDER BY system, skill_name').all(),
  ]);

  const body = JSON.stringify({
    // `systems` is stored as a JSON array; NULL means the skill applies to both.
    skills: applySystemBases(skills.results, systemBaseMap(
      system ? systemBases.results.filter((b) => b.system === system) : [],
    )).map((s) => ({
      ...s,
      systems: s.systems ? JSON.parse(s.systems) : undefined,
    })),
    // Ordered by system, so a reader building one system's map walks a run.
    skillSystemBases: systemBases.results,
    spells: spells.results,
    psionics: psionics.results,
    superAbilities: supers.results,
    talents: talents.results,
    // `bonuses` is stored as a JSON string, decoded here so every caller does
    // not have to remember to - the same courtesy `systems` gets above.
    enchantments: enchantments.results.map((e) => ({
      ...e,
      bonuses: e.bonuses ? JSON.parse(e.bonuses) : undefined,
    })),
    totems: totems.results.map((t) => ({
      ...t,
      skills: t.skills ? JSON.parse(t.skills) : [],
      bonuses: t.bonuses ? JSON.parse(t.bonuses) : undefined,
    })),
  });

  // 30KB gzipped, fetched on EVERY wizard boot and EVERY sheet load, and
  // between imports it never changes - so it carries a validator and a warm
  // load revalidates to an empty 304. `classes.js` does the same thing; the
  // browser does the caching and js/api.js needs no change, because fetch
  // handles If-None-Match and 304 transparently. `no-cache` means "store, but
  // revalidate every time", never "serve stale"; private because the site is.
  //
  // The validator is a HASH OF THE BODY, and not the count-and-max-updated_at
  // aggregate classes.js uses, because none of these tables has a timestamp
  // column - checked on production 2026-09-05 for the first four, and
  // `super_abilities` was created without one too (migration 057). A count alone would go
  // stale on exactly the write this catalog exists for: the editor's PATCH
  // changes a percentage in place and moves neither the row count nor the max
  // id, so a cached client would keep the wrong number with no way to notice.
  // A content hash also survives the writes that never touch this Worker at
  // all - every `d1-apply.mjs` data script goes straight to D1, and no
  // app-level version counter would ever hear about them.
  //
  // What it does NOT save is database work: the six SELECTs above have
  // already run by the time there is a body to hash. This trades a little CPU
  // for ~30KB of transfer per warm load, which is the right way round on a
  // phone at a table and the wrong way round if this ever gets expensive to
  // query. Both halves are measured in docs/plans/20-power-descriptions.md. The
  // figure moved from 25KB when super abilities joined the payload: 364 rows
  // are 60KB raw and 5.4KB gzipped, measured against production 2026-09-13,
  // most of the raw size being `source_book` repeated 364 times and most of
  // that compressing away.
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"catalogs-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };

  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
