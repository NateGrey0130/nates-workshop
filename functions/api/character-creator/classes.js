// GET /api/character-creator/classes — all published RCC/OCC definitions.
// Optional filters: ?system=rifts|palladium-fantasy  ?category=rcc|occ
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

  const { classes: all, failures } = await loadPublished(env);
  const classes = all.filter((c) =>
    (!systemFilter || c.system === systemFilter) &&
    (!categoryFilter || c.category === categoryFilter));

  return json({ classes, failures });
}
