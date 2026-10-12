// PATCH  /api/character-creator/characters/:id/vehicles/:vehicleId — nickname,
//        notes, and the M.D.C. of ONE location, as {location, mdc: {from, to,
//        absent}}: refused with 409 when the location no longer holds `from`
//        (owner/GM)
// DELETE /api/character-creator/characters/:id/vehicles/:vehicleId — soft-remove:
//        sets removed_at so the history survives (never hard-deletes).
//
// Mirrors characters/:id/items/:itemId, including the guard shape, because a
// vessel is edited and lost the same way an item is.

import { json, readJson, requireCharacter }
  from '../../../_lib/auth.js';

// requireCharacter's three answers - signed out, no such character, not yours
// to change - and then this route's own: the row has to be on THIS character.
async function guard(request, env, params) {
  const auth = await requireCharacter(request, env, params.id);
  if (auth.res) return { err: auth.res };
  const row = await env.DB.prepare(
    'SELECT * FROM character_vehicles WHERE id = ? AND character_id = ?'
  ).bind(params.vehicleId, params.id).first();
  if (!row) return { err: json({ error: 'Vessel not found on this character' }, 404) };
  return { row };
}

// ONE LOCATION, AND ONLY IF IT STILL HOLDS WHAT THE SENDER SAW. This route
// used to take the whole `mdc_current` object and store it as sent, so a
// player and the G.M. with one vessel open in two browsers each sent the
// object as THEIR page had read it: the second to arrive put every other
// location back to what it had been, and both answers were 200.
//
// The change is the shape a hit already has on the events route -
// {location, mdc: {from, to, absent}} - and here `from` is checked. Two people
// on DIFFERENT locations are not in conflict and both land; two on the SAME
// one are, and the second is told what is stored instead of replacing it.
//
// `absent` says the location had taken no damage when the sender read it, so
// nothing was stored for it (`from` is then not read). `to` is the new number,
// or null to put the location back to undamaged, which is what blanking the
// input on the sheet means.
//
// The location is checked against the vessel's OWN locations rather than
// accepted as written: stored, a name the vessel does not have would render
// as a damaged part that does not exist, and the reader has no way to tell
// that from a book they have not read. A FREEFORM vessel (vehicle_slug NULL)
// joins to no catalog row and has no list to check against, so any name is
// allowed for it - the same concession `validateEnchantments` makes for a
// freeform item. So is a vessel whose catalog row lists no locations: that is
// a thin import rather than a bad write.
//
// Values are integers and may go NEGATIVE: Palladium blows straight through
// zero, and clamping here would quietly disagree with the table.
async function readChange(env, row, b) {
  const { location, mdc: m } = b;
  if (typeof location !== 'string' || !location) {
    return { error: 'An M.D.C. change needs the location it is for' };
  }
  if (!m || typeof m !== 'object' || Array.isArray(m)) {
    return { error: 'An M.D.C. change needs mdc: {from, to} for its location' };
  }
  const absent = m.absent === true;
  if (!absent && !Number.isFinite(m.from)) {
    return { error: `M.D.C. for "${location}" needs the number it replaces (from), or absent` };
  }
  if (m.to !== null && !Number.isFinite(m.to)) {
    return { error: `M.D.C. for "${location}" is not a number` };
  }
  if (row.vehicle_slug) {
    const { results } = await env.DB.prepare(
      'SELECT location FROM vehicle_locations WHERE vehicle_slug = ?'
    ).bind(row.vehicle_slug).all();
    if (results.length && !results.some((r) => r.location === location)) {
      return { error: `Not a location on this vessel: ${location}` };
    }
  }
  return {
    location, absent,
    from: absent ? null : Math.trunc(m.from),
    to: m.to === null ? null : Math.trunc(m.to),
  };
}

const parseMdc = (text) => {
  try {
    const o = JSON.parse(text || '{}');
    return o && typeof o === 'object' && !Array.isArray(o) ? o : {};
  } catch { return {}; }
};
const has = (o, k) => Object.prototype.hasOwnProperty.call(o, k);

export async function onRequestPatch({ request, env, params }) {
  const { err, row } = await guard(request, env, params);
  if (err) return err;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);

  // The object as a whole is no longer a thing a request can send: accepted
  // beside the guarded shape it would be the same overwrite by another door.
  if ('mdc_current' in b) {
    return json({ error: 'Send one location at a time: {location, mdc: {from, to, absent}}' }, 400);
  }

  const sets = [];
  const binds = [];
  if ('nickname' in b) { sets.push('nickname = ?'); binds.push(b.nickname ?? null); }
  if ('notes' in b) { sets.push('notes = ?'); binds.push(b.notes ?? null); }

  if (!('mdc' in b) && !('location' in b)) {
    if (!sets.length) return json({ error: 'No editable fields in body' }, 400);
    await env.DB.prepare(`UPDATE character_vehicles SET ${sets.join(', ')} WHERE id = ?`)
      .bind(...binds, params.vehicleId).run();
    return json({ ok: true });
  }

  const change = await readChange(env, row, b);
  if (change.error) return json({ error: change.error }, 400);
  const { location, absent, from, to } = change;

  // The column is one JSON object, so the write is the object as read with one
  // key changed, and it lands only if the column is still the text that was
  // read. When it is not, somebody wrote in between: read again and judge the
  // location afresh, because a write to ANOTHER location is no reason to
  // refuse this one. Three turns is two more than two people need.
  let stored = row.mdc_current;
  for (let turn = 0; turn < 3; turn++) {
    const cur = parseMdc(stored);
    const held = has(cur, location);
    const wanted = to === null ? !held : held && cur[location] === to;
    const asSeen = absent ? !held : held && cur[location] === from;
    // Already what was asked for - the same number typed on both sides, or a
    // request sent again after its answer was lost - is not a clash.
    if (!asSeen && !wanted) {
      return json({
        error: `${location} was changed somewhere else since this was read`,
        conflict: true,
        // Both sides, as the events route answers a moved pool. `theirs` is
        // null when nothing is stored: the location is undamaged.
        location, mine: to, theirs: held ? cur[location] : null, base: from,
      }, 409);
    }
    if (to === null) delete cur[location]; else cur[location] = to;
    const res = await env.DB.prepare(
      `UPDATE character_vehicles SET ${[...sets, 'mdc_current = ?'].join(', ')}
        WHERE id = ? AND mdc_current IS ?`
    ).bind(...binds, JSON.stringify(cur), params.vehicleId, stored).run();
    if (res.meta?.changes) return json({ ok: true });
    const again = await env.DB.prepare(
      'SELECT mdc_current FROM character_vehicles WHERE id = ? AND character_id = ?'
    ).bind(params.vehicleId, params.id).first();
    if (!again) return json({ error: 'Vessel not found on this character' }, 404);
    stored = again.mdc_current;
  }
  return json({
    error: 'This vessel kept changing while the edit was being stored. Try it again.',
    conflict: true, location, mine: to,
  }, 409);
}

export async function onRequestDelete({ request, env, params }) {
  const { err } = await guard(request, env, params);
  if (err) return err;

  await env.DB.prepare(
    "UPDATE character_vehicles SET removed_at = datetime('now') WHERE id = ? AND removed_at IS NULL"
  ).bind(params.vehicleId).run();
  return json({ ok: true });
}
