// GET    /api/character-creator/catalogs/redirects?catalog=gear       — list
// DELETE /api/character-creator/catalogs/redirects?catalog=gear&id=3  — remove one
//
// Admin only. Redirects are written by merges and by hand-renaming a key, never
// directly — there is no POST here, because a forwarding address with no
// retired key behind it is just a second name for a row.
//
// They are listed rather than left as invisible plumbing for two reasons: they
// accumulate silently, and a merge confirmed in haste is otherwise only
// unpickable in SQL.

import { requireAdmin, json } from '../_lib/auth.js';
import { getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';
import { MERGE_REFS } from '../_lib/catalog-merge.js';
import { listRedirects, deleteRedirect } from '../_lib/catalog-redirects.js';

function resolve(request) {
  const params = new URL(request.url).searchParams;
  const key = params.get('catalog');
  if (!getCatalog(key) || !MERGE_REFS[key]) return { err: json({ error: 'Unknown catalog' }, 400) };
  return { key, params };
}

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, err } = resolve(request);
  if (err) return err;

  const redirects = await listRedirects(env, key);
  return json({
    catalog: key,
    redirects,
    count: redirects.length,
    // A redirect whose target has since been deleted resolves to nothing. It
    // cannot happen through a merge — those move the pointer onto the survivor
    // — but the list should still be able to show one rather than hide it.
    broken: redirects.filter((r) => r.target_name === null).length,
  });
}

export async function onRequestDelete({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, params, err } = resolve(request);
  if (err) return err;

  const id = parseInt(params.get('id'), 10);
  if (!Number.isFinite(id)) return json({ error: 'A numeric id is required' }, 400);

  const gone = await deleteRedirect(env, key, id);
  if (!gone) return json({ error: 'No redirect with that id' }, 404);
  return json({ ok: true, id });
}
