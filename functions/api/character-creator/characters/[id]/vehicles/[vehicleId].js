// PATCH  /api/character-creator/characters/:id/vehicles/:vehicleId — nickname,
//        notes, and M.D.C. by location (owner/GM)
// DELETE /api/character-creator/characters/:id/vehicles/:vehicleId — soft-remove:
//        sets removed_at so the history survives (never hard-deletes).
//
// Mirrors characters/:id/items/:itemId, including the guard shape, because a
// vessel is edited and lost the same way an item is.

import { getUserEmail, unauthorized, json, readJson, forbidden, characterAccess }
  from '../../../_lib/auth.js';

async function guard(env, params, email) {
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return { err: json({ error: 'Character not found' }, 404) };
  if (!access.canWrite) return { err: forbidden() };
  const row = await env.DB.prepare(
    'SELECT * FROM character_vehicles WHERE id = ? AND character_id = ?'
  ).bind(params.vehicleId, params.id).first();
  if (!row) return { err: json({ error: 'Vessel not found on this character' }, 404) };
  return { row };
}

// Damage, checked against the vessel's OWN locations rather than accepted as
// written. A key that names no location on this vessel is refused: stored, it
// would render as a damaged part that does not exist, and the reader has no way
// to tell that from a book they have not read.
//
// A FREEFORM vessel (vehicle_slug NULL) joins to no catalog row and therefore
// has no location list to check against, so any key is allowed for it - the
// same concession `validateEnchantments` makes for a freeform item. A GM who
// writes in "the party's stolen barge" should be able to track its hull.
//
// Values are integers and may go NEGATIVE: Palladium blows straight through
// zero, and clamping here would quietly disagree with the table.
async function validateMdc(env, row, value) {
  if (value === null || value === undefined) return { mdc: {} };
  if (typeof value !== 'object' || Array.isArray(value)) {
    return { error: 'mdc_current must be an object keyed by location name' };
  }

  const out = {};
  for (const [k, v] of Object.entries(value)) {
    const n = Number(v);
    if (!Number.isFinite(n)) return { error: `M.D.C. for "${k}" is not a number` };
    out[k] = Math.trunc(n);
  }
  if (!row.vehicle_slug) return { mdc: out };

  const { results } = await env.DB.prepare(
    'SELECT location FROM vehicle_locations WHERE vehicle_slug = ?'
  ).bind(row.vehicle_slug).all();
  // Nothing to check against is not the same as everything being valid, but a
  // vessel whose catalog row lists no locations is a thin import rather than a
  // bad write, and refusing damage on it would make the sheet useless for it.
  if (!results.length) return { mdc: out };

  const known = new Set(results.map((r) => r.location));
  const unknown = Object.keys(out).filter((k) => !known.has(k));
  if (unknown.length) {
    return { error: `Not a location on this vessel: ${unknown.join(', ')}` };
  }
  return { mdc: out };
}

export async function onRequestPatch({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err, row } = await guard(env, params, email);
  if (err) return err;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);

  const sets = [];
  const binds = [];
  if ('nickname' in b) { sets.push('nickname = ?'); binds.push(b.nickname ?? null); }
  if ('notes' in b) { sets.push('notes = ?'); binds.push(b.notes ?? null); }
  if ('mdc_current' in b) {
    const checked = await validateMdc(env, row, b.mdc_current);
    if (checked.error) return json({ error: checked.error }, 400);
    sets.push('mdc_current = ?'); binds.push(JSON.stringify(checked.mdc));
  }
  if (!sets.length) return json({ error: 'No editable fields in body' }, 400);

  await env.DB.prepare(`UPDATE character_vehicles SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, params.vehicleId).run();
  return json({ ok: true });
}

export async function onRequestDelete({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const { err } = await guard(env, params, email);
  if (err) return err;

  await env.DB.prepare(
    "UPDATE character_vehicles SET removed_at = datetime('now') WHERE id = ? AND removed_at IS NULL"
  ).bind(params.vehicleId).run();
  return json({ ok: true });
}
