// GET /api/character-creator/classes — all published RCC/OCC definitions.
// Optional filters: ?system=rifts|palladium-fantasy  ?category=rcc|occ
//
// ?include_retired=1 also returns classes that have been retired, flagged with
// `_retired: true`. Exclusion is the default so a caller that forgets the
// parameter shows a clean list rather than offering a retired class; the sheet
// and the GM dashboard opt in because they must still resolve the class of a
// character that already exists.
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

  const { classes: all, failures } = await loadPublished(env, { includeRetired });
  const classes = all.filter((c) =>
    (!systemFilter || c.system === systemFilter) &&
    (!categoryFilter || c.category === categoryFilter));

  return json({ classes, failures });
}
