// GET /api/character-creator/codex — every spell and psionic power, WITH the
// text that says what it does.
//
// The second half of docs/plans/20-power-descriptions.md. The first half put a
// held power's description on the sheet; this is for the 691 a character does
// NOT hold — reading up before a level-up, deciding what to learn, settling
// what a spell does at a table when nobody holds it.
//
// A separate endpoint rather than widening `catalogs`, and that IS the design:
// `catalogs` is the boot payload for the wizard and the sheet, 25.1KB gzipped
// on every load of both. Adding descriptions there costs +72.4KB gzipped on
// every one of those loads to serve a page most sessions never open. Here the
// same bytes are paid once, by somebody who went looking, and the validator
// below turns the second visit into a 304.
//
// A separate endpoint rather than the catalog editor's routes, too:
// `catalogs/rows` is `requireAdmin` at every method because it WRITES, and
// unlocking it for reading would put an editor's shape — duplicate review,
// redirect lists, an audit panel — in front of a player who wanted to look up
// Fire Bolt. This route only reads, and answers any authenticated friend.

import { getUserEmail, unauthorized } from './_lib/auth.js';

export async function onRequestGet({ request, env }) {
  if (!getUserEmail(request)) return unauthorized();

  const [spells, psionics] = await Promise.all([
    // The whole printed entry, not the trimmed projection `catalogs` sends: a
    // codex that omitted range or duration would send you back to the book,
    // which is the errand it exists to save. `variant_note` rides along
    // because an older book's number is kept rather than discarded, and a
    // reader comparing against their own copy needs to see which one this is.
    env.DB.prepare(
      `SELECT name, level, ppe, ppe_note, variant_note, range, duration, damage,
              saving_throw, area_of_effect, casting_time, description, system, source_book
       FROM spells ORDER BY level, name`
    ).all(),
    env.DB.prepare(
      `SELECT name, category, isp, isp_note, variant_note, min_tier, range, duration,
              saving_throw, description, system, source_book
       FROM psionic_powers ORDER BY category, name`
    ).all(),
  ]);

  const body = JSON.stringify({ spells: spells.results, psionics: psionics.results });

  // Same validator as /catalogs, and for the same reason: a hash of the body,
  // because no catalog table has a timestamp column and the editor's PATCH
  // changes a description in place without moving a count or a max id. See
  // catalogs.js, which carries the long version of this argument.
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"codex-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };

  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
