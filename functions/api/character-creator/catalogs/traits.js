// GET /api/character-creator/catalogs/traits?catalog=morphus - every row of a
// catalog a class's `second_form.traits_from` names, for the wizard's generator
// (Nightbane survey D5, PR 3 of 4; js/morphus.js).
//
// NOT PART OF THE BOOT PAYLOAD, on purpose. This response is 173 rows, 109KB
// raw and 22KB gzipped with the descriptions (measured off a local build of the
// data script, 2026-09-17) - and the generator needs the descriptions, because a
// picked entry's bite, senses and restrictions exist only in the prose.
// `catalogs` is paid on EVERY wizard boot and EVERY sheet load, and its own
// comment puts it near 30KB gzipped; these rows would add most of that again
// for the handful of classes that state a second form. So the wizard
// fetches them the first time its Morphus step renders, the way `codex`
// sections are fetched by whoever opens that tab.
//
// Any authenticated reader: it only reads. Only the catalogs a second form may
// draw from (js/parser.js SECOND_FORM_TRAIT_CATALOGS) - this is not a second
// door into every catalog's whole rows, which `catalogs/rows` keeps for admins.
// Body-hash ETag, for the reason catalogs.js gives: nothing here has a
// timestamp, and a data script moves the rows without touching this Worker.

import { getUserEmail, unauthorized, json } from '../_lib/auth.js';
import { getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';
import { SECOND_FORM_TRAIT_CATALOGS } from '../../../../apps/character-creator/js/parser.js';

const COLUMNS = `key, table_name, roll_low, roll_high, name, kind, routes, route_rule, bonuses,
  horror_factor, horror_factor_set, sub_choices, description, note, source_book, system`;
const JSON_COLUMNS = ['routes', 'bonuses', 'sub_choices'];

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();
  const key = new URL(request.url).searchParams.get('catalog');
  const cat = SECOND_FORM_TRAIT_CATALOGS.includes(key) ? getCatalog(key) : null;
  if (!cat) {
    return json({ error: `catalog must be one a second form's traits come from: ${SECOND_FORM_TRAIT_CATALOGS.join(', ')}` }, 400);
  }

  const { results } = await env.DB
    .prepare(`SELECT ${COLUMNS} FROM ${cat.table} ORDER BY table_name, roll_low, name`).all();
  const rows = results.map((r) => {
    const out = { ...r };
    for (const c of JSON_COLUMNS) {
      if (typeof out[c] === 'string') {
        try { out[c] = JSON.parse(out[c]); } catch { out[c] = null; }
      }
    }
    return out;
  });

  const body = JSON.stringify({ catalog: key, rows });
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"traits-${key}-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };
  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
