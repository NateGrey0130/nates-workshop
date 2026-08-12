// Lists all RCC/OCC class definitions, parsed from their markdown files at
// request time (spec section 9 — markdown is the source of truth, not the DB).
// Optional filters: ?system=rifts|palladium-fantasy  ?category=rcc|occ

import { parseClassMarkdown } from '../../../apps/character-creator/js/parser.js';
import { getUserEmail, unauthorized, json } from './_lib/auth.js';
import { loadPublished } from './_lib/class-store.js';

const DATA_PATH = '/apps/character-creator/data/classes/';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const manifestRes = await env.ASSETS.fetch(new URL(DATA_PATH + 'index.json', request.url));
  if (!manifestRes.ok) return json({ error: 'Class manifest not found' }, 500);
  const manifest = await manifestRes.json();

  const url = new URL(request.url);
  const systemFilter = url.searchParams.get('system');
  const categoryFilter = url.searchParams.get('category');

  const classes = [];
  const failures = [];
  for (const file of manifest.classes) {
    const res = await env.ASSETS.fetch(new URL(DATA_PATH + file, request.url));
    if (!res.ok) {
      failures.push({ file, errors: [`Fetch failed: ${res.status}`] });
      continue;
    }
    const parsed = parseClassMarkdown(await res.text());
    if (!parsed.ok) {
      failures.push({ file, errors: parsed.errors });
      continue;
    }
    if (systemFilter && parsed.data.system !== systemFilter) continue;
    if (categoryFilter && parsed.data.category !== categoryFilter) continue;
    classes.push({ ...parsed.data, _source: 'file' });
  }

  // Imported classes go live without a redeploy, but a committed file with the
  // same id always wins — a deliberate commit is never silently shadowed.
  const committed = new Set(classes.map((c) => c.id));
  const imported = await loadPublished(env);
  const shadowed = [];
  for (const c of imported.classes) {
    if (committed.has(c.id)) { shadowed.push(c.id); continue; }
    if (systemFilter && c.system !== systemFilter) continue;
    if (categoryFilter && c.category !== categoryFilter) continue;
    classes.push(c);
  }
  failures.push(...imported.failures);

  return json({ classes, failures, shadowed });
}
