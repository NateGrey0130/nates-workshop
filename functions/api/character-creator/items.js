// GET /api/character-creator/items — shared item catalog (optionally ?system=)

import { getUserEmail, unauthorized } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const system = new URL(request.url).searchParams.get('system');
  // Only the fields the pickers actually render — the catalog grows by a stub
  // per referenced item on every class import, and `stats` is a JSON blob.
  // source_book is in the projection so the pickers can filter on it — typing
  // "rifts main" should narrow the list the same way a name does.
  const cols = 'id, slug, name, system, category, weight_lbs, cost, source_book';
  // A NULL system means "not stated", which is unrestricted — the same reading
  // `skills.systems` already gets. The gear importer does not ask which system a
  // book is for, so every one of the 34 items from the first real import landed
  // NULL and was invisible here, while the wizard (which passes no system at
  // all) showed them. Same catalog, two different answers.
  const stmt = system
    ? env.DB.prepare(`SELECT ${cols} FROM gear WHERE system IS NULL OR system = ? OR system = 'both' ORDER BY name`).bind(system)
    : env.DB.prepare(`SELECT ${cols} FROM gear ORDER BY name`);
  const { results } = await stmt.all();

  // Retired slugs, so the wizard can still resolve a class whose
  // equipment_starting cites gear that has since been merged or renamed.
  // Unfiltered by system on purpose: the redirect says where a slug went, and
  // whether the target is in this system's list is the caller's business.
  const { results: redirects } = await env.DB.prepare(
    `SELECT r.from_key, g.slug AS to_slug
     FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
     WHERE r.catalog = 'gear'`
  ).all();

  // Revalidated by content hash, as catalogs.js does and for its reason: the
  // wizard and every sheet load ask for this, and it changes only when a data
  // script runs.
  const body = JSON.stringify({
    items: results,
    redirects: Object.fromEntries(redirects.map((r) => [String(r.from_key).toLowerCase(), r.to_slug])),
  });
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"items-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };
  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
