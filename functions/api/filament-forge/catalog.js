// GET /api/filament-forge/catalog — the Open Filament Database snapshot.
//
// The app used to fetch OFD's CSVs from the browser on every page load, which
// made a third-party site a runtime dependency. Now scripts/ofd-refresh.mjs
// snapshots those CSVs into ff_brands/ff_filaments and this is the only thing
// the browser talks to. Rows keep the CSV's column names (brand_id,
// min_print_temperature, …) so the client's field handling did not change.
//
// Read whole, like the character creator's catalogs: the client filters and
// groups in memory, and the whole table is a few thousand small rows.

import { getUserEmail, json } from './_lib/common.js';

export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);
  try {
    const db = context.env.DB;
    const [brands, filaments, meta] = await Promise.all([
      db.prepare('SELECT id, name FROM ff_brands ORDER BY name').all(),
      db.prepare('SELECT * FROM ff_filaments').all(),
      db.prepare('SELECT MAX(fetched_at) AS fetched_at FROM ff_filaments').all(),
    ]);
    return json({
      fetchedAt: meta.results[0]?.fetched_at || null,
      brands: brands.results,
      filaments: filaments.results,
    });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
