// GET /api/character-creator/codex?section=<name> — one catalog, WITH the text
// and the stat block that say what a thing is.
//
// Four sections: `spells`, `psionics`, `gear`, `vehicles`.
//
// The second half of docs/plans/20-power-descriptions.md, widened to the two
// catalogs that had no reader at all. The first half put a held power's
// description on the sheet; this is for everything a character does NOT hold —
// reading up before a level-up, deciding what to buy, settling what a spell
// does at a table when nobody holds it, and looking at a robot.
//
// A separate endpoint rather than widening `catalogs`, and that IS the design:
// `catalogs` is the boot payload for the wizard and the sheet, 25.1KB gzipped
// on every load of both. Here the same bytes are paid once, by somebody who
// went looking, and the validator below turns the second visit into a 304.
//
// ── WHY THE SECTION PARAMETER EXISTS, AND IS REQUIRED ──
//
// This route used to serve spells and psionics together in one response, which
// was right when those were the only two. Measured on production 2026-09-08,
// serialised exactly as returned and gzipped at level 6:
//
//   gear, full projection                155.2 KB gzip   (740.1 KB raw)
//   vehicles + locations + weapons       106.8 KB gzip   (564.3 KB raw)
//   all four in one response             261.2 KB gzip
//   (the whole boot payload, for scale)   25.1 KB gzip
//
// One response carrying everything is a 261 KB fetch before the page paints, on
// a phone at a table, to show somebody one spell. So a section is fetched when
// its tab is first opened and not before.
//
// `section` is REQUIRED rather than defaulting to the old spells+psionics body.
// A default would be a second contract to keep working, and this site has one
// client. A missing or unknown section is a 400 naming the four, which is a
// better failure than silently serving the wrong catalog.
//
// LIST-THEN-DETAIL WAS CONSIDERED AND REJECTED for `vehicles`: sending the 127
// vessels alone is 37.6 KB and fetching each one's locations and weapons on
// expansion would save 69 KB on a fetch that happens once per page life, at the
// cost of a round trip per expansion. Plan 20 explicitly valued "no round trip
// on a bad connection". Revisit if any one section passes ~250 KB gzipped.
//
// A separate endpoint rather than the catalog editor's routes, too:
// `catalogs/rows` is `requireAdmin` at every method because it WRITES, and
// unlocking it for reading would put an editor's shape — duplicate review,
// redirect lists, an audit panel — in front of a player who wanted to look up
// Fire Bolt. This route only reads, and answers any authenticated friend.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';

// The whole printed entry, not the trimmed projection `catalogs` sends: a codex
// that omitted range or duration would send you back to the book, which is the
// errand it exists to save. `variant_note` rides along because an older book's
// number is kept rather than discarded, and a reader comparing against their own
// copy needs to see which one this is.
const SECTIONS = {
  // How big each catalog is, and nothing else. ~120 bytes.
  //
  // It exists because lazy sections cost the tab bar its counts: the page used
  // to hold both catalogs, so it could label the tabs from what it had. Now it
  // holds none until you click one, and a tab bar that fills its numbers in as
  // you visit tabs reads like a page still loading. One tiny fetch on open
  // keeps the labels honest and complete from the first paint, and it is four
  // COUNT(*)s rather than a fifth catalog.
  index: async (env) => ({
    counts: (await env.DB.prepare(
      `SELECT (SELECT count(*) FROM spells)         AS spells,
              (SELECT count(*) FROM psionic_powers) AS psionics,
              (SELECT count(*) FROM gear)           AS gear,
              (SELECT count(*) FROM vehicles)       AS vehicles`
    ).first()),
  }),

  // Every vessel's name and class, and nothing else. ~10 KB against the 106.8 KB
  // the full `vehicles` section costs.
  //
  // This is what a PICKER needs, and it is the same split `/items` already makes
  // for gear: the catalog's names for choosing from, the stat block only where
  // something renders one. The sheet's "add a vessel" control fetches this; it
  // has no use for 1,238 location rows and 635 weapon systems to put 127 names
  // in a dropdown, and on a phone at a table that difference is the feature.
  'vehicles-index': async (env) => ({
    'vehicles-index': (await env.DB.prepare(
      `SELECT slug, name, vehicle_class, system, source_book
       FROM vehicles ORDER BY name`
    ).all()).results,
  }),

  spells: async (env) => ({
    spells: (await env.DB.prepare(
      `SELECT name, level, ppe, ppe_note, variant_note, range, duration, damage,
              saving_throw, area_of_effect, casting_time, description, system, source_book
       FROM spells ORDER BY level, name`
    ).all()).results,
  }),

  psionics: async (env) => ({
    psionics: (await env.DB.prepare(
      `SELECT name, category, isp, isp_note, variant_note, min_tier, range, duration,
              saving_throw, description, system, source_book
       FROM psionic_powers ORDER BY category, name`
    ).all()).results,
  }),

  // `slug` rather than `id` is the key here for the same reason inventory holds
  // one: an id is insertion order and means nothing in another database.
  // `is_mega_damage` travels structured rather than being read back out of the
  // damage string, which is the distinction that matters most in Rifts.
  // `vehicle_slug` and the vessel's NAME both travel, because a slug is not a
  // name: a row rendering "ng-jk1-juicer-killer-power-armor" is worse than one
  // rendering nothing, since it looks like a name and is not - the same
  // argument sheet.js's enchantBySlug makes about an unresolved slug. The join
  // is a LEFT one and `vessel_name` comes back NULL for a pointer whose vessel
  // a later book session has not imported yet, which is a state migration 053
  // deliberately allows, so the renderer must handle it.
  gear: async (env) => ({
    gear: (await env.DB.prepare(
      `SELECT gear.slug, gear.name, gear.category, gear.system, gear.weight_lbs,
              gear.cost, gear.cost_note, gear.damage, gear.is_mega_damage,
              gear.range, gear.payload, gear.rate_of_fire, gear.ar, gear.sdc,
              gear.mdc, gear.description, gear.source_book, gear.vehicle_slug,
              vehicles.name AS vessel_name
       FROM gear LEFT JOIN vehicles ON vehicles.slug = gear.vehicle_slug
       ORDER BY gear.category, gear.name`
    ).all()).results,
  }),

  // THREE tables, because a vessel is not a row: M.D.C. arrives BY LOCATION and
  // weapon systems arrive as a numbered list. They are NESTED into their vessel
  // here rather than sent as three flat arrays — it is smaller (1,873 repeated
  // `vehicle_slug` values do not travel) and it is the shape a renderer wants,
  // so no client has to re-implement the grouping.
  vehicles: async (env) => {
    const [vehicles, locations, weapons] = await Promise.all([
      env.DB.prepare(
        `SELECT slug, name, system, vehicle_class, crew, passengers, speed_ground,
                speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
                cost, cost_note, description, source_book
         FROM vehicles ORDER BY name`
      ).all(),
      env.DB.prepare(
        `SELECT vehicle_slug, location, mdc, mdc_note
         FROM vehicle_locations ORDER BY vehicle_slug, ordinal`
      ).all(),
      env.DB.prepare(
        `SELECT vehicle_slug, ordinal, name, damage, is_mega_damage, range,
                rate_of_fire, payload, bonus, note
         FROM vehicle_weapons ORDER BY vehicle_slug, ordinal`
      ).all(),
    ]);

    // `ordinal` is dropped from locations on the way out because the ORDER BY
    // above has already spent it — the array order IS the printed order, which
    // is the whole reason that column exists. Weapons keep theirs: it is the
    // book's own numbering and gets rendered ("1. Rail Gun").
    //
    // A child row whose `vehicle_slug` matches no vessel is DROPPED rather than
    // collected into an orphan bucket. The foreign key makes that impossible in
    // a healthy database and the vessel scripts assert it after every import;
    // the `?.` is here so a broken one degrades to a missing location instead of
    // a 500 on every codex load.
    const byVessel = new Map(vehicles.results.map((v) => [v.slug, { ...v, locations: [], weapons: [] }]));
    for (const l of locations.results) {
      byVessel.get(l.vehicle_slug)?.locations.push({ location: l.location, mdc: l.mdc, mdc_note: l.mdc_note });
    }
    for (const w of weapons.results) {
      const { vehicle_slug, ...rest } = w;
      byVessel.get(vehicle_slug)?.weapons.push(rest);
    }
    return { vehicles: [...byVessel.values()] };
  },
};

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const section = new URL(request.url).searchParams.get('section');
  if (!section || !Object.hasOwn(SECTIONS, section)) {
    return json({ error: 'Unknown codex section', sections: Object.keys(SECTIONS) }, 400);
  }

  const body = JSON.stringify(await SECTIONS[section](env));

  // Same validator as /catalogs, and for the same reason: a hash of the body,
  // because no catalog table has a timestamp column and the editor's PATCH
  // changes a description in place without moving a count or a max id. See
  // catalogs.js, which carries the long version of this argument.
  //
  // THE SECTION IS IN THE TAG. Without it, two sections that serialised
  // identically would falsely 304 into each other — and an empty catalog on a
  // fresh database is exactly that case, `{"gear":[]}` differing from
  // `{"spells":[]}` only by luck of the key name.
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"codex-${section}-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };

  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
