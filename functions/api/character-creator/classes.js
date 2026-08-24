// GET /api/character-creator/classes — all published RCC/OCC definitions.
// Optional filters: ?system=rifts|palladium-fantasy  ?category=rcc|occ
//
// ?include_retired=1 also returns classes that have been retired, flagged with
// `_retired: true`. Exclusion is the default so a caller that forgets the
// parameter shows a clean list rather than offering a retired class; the sheet
// and the GM dashboard opt in because they must still resolve the class of a
// character that already exists.
//
// ?names=1 is the label projection — { id, name } per published class, read
// straight off the table with no parsing. Deliberately unfiltered and retired
// included: its one job is turning a class_id into a display name, and a
// character on a retired class must keep its label. The GM dashboard is the
// caller; it used to download every parsed class to label a five-row roster.
//
// Classes live in D1 (imported_classes) and are edited through the import tool,
// so adding or fixing one needs no commit and no redeploy. The markdown format
// is unchanged — it is the same file content, just stored rather than shipped.

import { getUserEmail, unauthorized, json } from './_lib/auth.js';
import { loadPublished } from './_lib/class-store.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const url = new URL(request.url);
  const systemFilter = url.searchParams.get('system');
  const categoryFilter = url.searchParams.get('category');

  const includeRetired = url.searchParams.get('include_retired') === '1';

  // This is the app's heaviest response — ~750KB of parsed class markdown,
  // fetched by three pages on load — and between imports it never changes. The
  // validator is one aggregate: publish, edit, retire and restore all stamp
  // updated_at (and the count catches anything that would not), so a warm boot
  // revalidates to an empty 304 instead of re-downloading the catalog. The
  // browser does the caching; api() needs no change, because fetch handles
  // If-None-Match/304 transparently. One validator serves every filter variant
  // of this URL — a change anywhere conservatively refreshes them all, and
  // each URL's cache entry keeps its own body. `no-cache` means "store, but
  // revalidate every time", never "serve stale"; private because the whole
  // site is.
  const state = await env.DB.prepare(
    "SELECT count(*) AS n, max(updated_at) AS ts FROM imported_classes WHERE status = 'published'"
  ).first().catch(() => null);
  const etag = state ? `W/"classes-${state.n}-${String(state.ts || '').replace(/[^0-9]/g, '')}"` : null;
  const headers = etag ? { ETag: etag, 'Cache-Control': 'private, no-cache' } : {};
  if (etag && request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }

  if (url.searchParams.get('names') === '1') {
    const { results } = await env.DB.prepare(
      "SELECT class_id AS id, name FROM imported_classes WHERE status = 'published' ORDER BY name"
    ).all();
    return json({ classes: results }, 200, headers);
  }

  const { classes: all, failures } = await loadPublished(env, { includeRetired });
  const classes = all.filter((c) =>
    (!systemFilter || c.system === systemFilter) &&
    (!categoryFilter || c.category === categoryFilter));

  return json({ classes, failures }, 200, headers);
}
