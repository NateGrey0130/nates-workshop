// GET  /api/character-creator/characters/:id/events — recent play events,
//      newest last. ?since=<event id> returns only rows after it (the recap
//      uses the last 'recap' marker as its boundary); ?limit= caps (default
//      100, max 300).
// POST /api/character-creator/characters/:id/events — apply a play action and
//      record it, in ONE batch: {kind, note?, changes?}. `changes` carries
//      absolute from/to values — {character: {sdc_current: {from, to}}} and/or
//      {item: {id, ammo_current: {from, to, cap}}} (migration 083; the older
//      {item: {id, notes: {from, to}}} still replays) — applied as given, and
//      composed rather than overwritten on a guarded replay. Since UI-AUDIT F40
//      also {armor: {index, mdc_current: {from, to, raw_from}}} and
//      {vehicle: {id, location, mdc: {from, to, absent}}}. The trust model is
//      the sheet's existing PATCH (client-side arithmetic, owner/GM enforced
//      server-side); what the event adds is atomicity and the undo trail. A
//      roll has no changes and is a pure record.
//
//      And {second_form: {sdc_current: {from, to}, hp_current: {from, to}}}:
//      the ACTIVE second form's own pools (Nightbane follow-up 5, 2026-09-17),
//      applied by the same rules as `character` - as given, unclamped, guarded
//      per field on replay - and written into `characters.second_form` field by
//      field. The note is stamped with the form's name, so the log says which
//      body took it.
//
// Events are commentary, not a ledger: the character row stays the source of
// truth, and nothing replays these to derive state.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { decodeCharacter } from '../../_lib/character-json.js';
import { loadCharacterClass } from '../../_lib/class-loader.js';
import { loadTraitRows, traitKeysOf } from '../../_lib/second-form.js';
import { secondFormView } from '../../../../../apps/character-creator/js/second-form.js';

// The character columns a play event may touch. Anything else is the sheet
// lens's business and goes through PATCH, where the field list lives.
const POOL_FIELDS = new Set(['hp_current', 'sdc_current', 'mdc_current', 'ppe_current', 'isp_current']);
// The pools a second form tracks on its own. P.P.E., I.S.P. and M.D.C. are one
// pool both forms share, and stay under `character`.
const FORM_POOL_FIELDS = new Set(['sdc_current', 'hp_current']);
const KINDS = new Set(['damage', 'pool', 'power', 'ammo', 'roll', 'recap']);

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id, { write: false });
  if (guard.res) return guard.res;

  const url = new URL(request.url);
  const since = parseInt(url.searchParams.get('since') || '0', 10) || 0;
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '100', 10) || 100, 300);
  const { results } = await env.DB.prepare(
    `SELECT id, actor_email, kind, payload, undone_at, created_at FROM play_events
     WHERE character_id = ? AND id > ? ORDER BY id DESC LIMIT ?`
  ).bind(params.id, since, limit).all();
  results.reverse();
  for (const r of results) { try { r.payload = JSON.parse(r.payload); } catch { r.payload = {}; } }
  return json({ events: results });
}

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;
  const { email } = guard;

  const b = await readJson(request);
  if (!b || !KINDS.has(b.kind)) return json({ error: 'kind must be one of damage/pool/power/ammo/roll/recap' }, 400);

  const changes = b.changes || {};
  const statements = [];

  const charFields = changes.character || {};
  const sets = [], binds = [];
  for (const [field, fv] of Object.entries(charFields)) {
    if (!POOL_FIELDS.has(field)) return json({ error: `${field} is not a play-adjustable field` }, 400);
    if (typeof fv?.to !== 'number' || typeof fv?.from !== 'number') {
      return json({ error: `${field} needs numeric from and to` }, 400);
    }
    sets.push(`${field} = ?`); binds.push(fv.to);
  }

  // THE ACTIVE SECOND FORM'S OWN POOLS (Nightbane follow-up 5). Validated like
  // the first form's, and written with json_set one field at a time INSIDE the
  // same UPDATE - the PATCH's reason: a read-modify-write of the whole column
  // could erase a result another request had stored. Not clamped, because the
  // first form's play writes are not: a Morphus runs below zero into hit points
  // on exactly the Facade's rule.
  //
  // The class is loaded, as the PATCH loads it, to refuse a second body on a
  // character whose class has none, to name the form in the log, and - on a
  // guarded replay - to read a never-stored current value as the full pool it
  // means.
  const formFields = changes.second_form || {};
  let formView = null, formRow = null;
  if (Object.keys(formFields).length) {
    for (const [field, fv] of Object.entries(formFields)) {
      if (!FORM_POOL_FIELDS.has(field)) return json({ error: `second_form.${field} is not a play-adjustable field` }, 400);
      if (typeof fv?.to !== 'number' || typeof fv?.from !== 'number') {
        return json({ error: `second_form.${field} needs numeric from and to` }, 400);
      }
    }
    formRow = decodeCharacter(await env.DB.prepare('SELECT * FROM characters WHERE id = ?').bind(params.id).first());
    const cls = formRow ? await loadCharacterClass(env, request.url, formRow) : null;
    if (!cls?.second_form) return json({ error: "This character's class has no second form" }, 400);
    formView = secondFormView({ cls, character: formRow,
      rows: await loadTraitRows(env, cls.second_form, traitKeysOf(formRow.second_form)) });
    const paths = [];
    for (const [field, fv] of Object.entries(formFields)) {
      paths.push(`'$.${field}', ?`); binds.push(Math.trunc(fv.to));
    }
    sets.push(`second_form = json_set(CASE WHEN json_valid(second_form) THEN second_form ELSE '{}' END, ${paths.join(', ')})`);
  }
  // GUARDED REPLAY. `from` has always been sent and validated and never used:
  // it is the client's belief about where the pool was, kept for undo. A queued
  // event replayed after a spell offline may be replaying onto a pool someone
  // else has moved, and applying `to` blindly would silently discard their
  // change - which is the whole failure the queue exists to avoid making
  // worse.
  //
  // Guarded PER FIELD rather than on the row, because two people touching
  // different pools are not in conflict. A row-level check would call that a
  // clash and a per-field one does not.
  //
  // Opt-in via `guard`, so every existing caller keeps the behaviour it has.
  //
  // A second form's field is guarded on the value STORED in the JSON, which
  // may be null - never written, meaning full - so the comparison below reads
  // it through the fold, and the WHERE binds the stored value itself.
  if (sets.length) {
    const guards = [], guardBinds = [];
    if (b.guard) {
      for (const [field, fv] of Object.entries(charFields)) {
        guards.push(`${field} IS ?`);
        guardBinds.push(fv.from);
      }
      for (const field of Object.keys(formFields)) {
        guards.push(`json_extract(second_form, '$.${field}') IS ?`);
        guardBinds.push(formRow?.second_form?.[field] ?? null);
      }
    }
    statements.push(env.DB.prepare(
      `UPDATE characters SET ${sets.join(', ')}, updated_at = datetime('now')`
      + ` WHERE id = ?${guards.length ? ' AND ' + guards.join(' AND ') : ''}`
    ).bind(...binds, params.id, ...guardBinds));
  }

  // Checked BEFORE the batch, because a batch that applies nothing still
  // inserts the event and would leave a log entry for a change that never
  // happened.
  if (b.guard && sets.length) {
    const cols = Object.keys(charFields);
    const current = cols.length ? await env.DB.prepare(
      `SELECT ${cols.join(', ')} FROM characters WHERE id = ?`
    ).bind(params.id).first() : {};
    if (!current) return json({ error: 'Character not found' }, 404);
    const moved = cols.filter((f) => current[f] !== charFields[f].from);
    const formMoved = Object.keys(formFields).filter((f) => formView?.[f] !== formFields[f].from);
    if (moved.length || formMoved.length) {
      return json({
        error: 'These pools changed somewhere else since this was queued',
        conflict: true,
        // Both sides, so the client can offer a real choice rather than
        // picking one on the player's behalf.
        fields: Object.fromEntries(moved.map((f) => [f, {
          mine: charFields[f].to, theirs: current[f], base: charFields[f].from,
        }])),
        // The second form's, apart: the same two field names mean the other body.
        form_fields: Object.fromEntries(formMoved.map((f) => [f, {
          mine: formFields[f].to, theirs: formView[f], base: formFields[f].from,
        }])),
      }, 409);
    }
  }

  // AN ITEM CHANGE IS AMMO, in one of two shapes.
  //
  // {ammo_current: {from, to, cap}} since migration 083 - the count in a
  // column of its own. A shot writes that column and nothing else, so it can
  // no longer overwrite the row's notes.
  //
  // {notes: {from, to}} is the shape before it, when the count lived in the
  // notes as "ammo 7/10". Still accepted, because a phone that queued a shot
  // offline before 083 shipped holds that shape in IndexedDB and will replay
  // it; refusing it would lose the shot. Nothing writes it any more.
  //
  // GUARDED REPLAY COMPOSES rather than refuses. A queued shot is "one fewer
  // than there were", so when the count moved elsewhere in the meantime the
  // shot is applied to what is there now - the move kept, the shot kept -
  // clamped to 0 and to the magazine (`cap`, which the client sends because the
  // server does not parse payloads). Refusing would drop a shot the player
  // actually fired, and a 409 naming no pool is dropped by the queue.
  if (changes.item) {
    const { id: itemId, notes, ammo_current: ammo } = changes.item;
    const isCount = (v) => Number.isInteger(v) && v >= 0;
    const hasAmmo = ammo && isCount(ammo.to) && isCount(ammo.from);
    const hasNotes = typeof notes?.to === 'string';
    if (!hasAmmo && !hasNotes) {
      return json({ error: 'item change needs ammo_current {from, to} as whole numbers, or notes.to' }, 400);
    }
    const row = await env.DB.prepare(
      'SELECT id, ammo_current FROM character_items WHERE id = ? AND character_id = ?'
    ).bind(itemId, params.id).first();
    if (!row) return json({ error: 'No such inventory item' }, 404);
    if (hasNotes) {
      statements.push(env.DB.prepare(
        'UPDATE character_items SET notes = ? WHERE id = ?'
      ).bind(notes.to, itemId));
    }
    if (hasAmmo) {
      const cap = isCount(ammo.cap) ? ammo.cap : null;
      let to = ammo.to;
      const now = row.ammo_current ?? cap;
      if (b.guard && now != null && now !== ammo.from) {
        // Clamped, unlike every pool in this file: a pool runs below zero on
        // the book's own rules, a magazine cannot hold fewer than none. Not
        // written as a max(0, ...) call, because second-body.mjs forbids that
        // shape here precisely so that no POOL gets clamped by accident.
        to = now + (ammo.to - ammo.from);
        if (to < 0) to = 0;
        if (cap != null && to > cap) to = cap;
      }
      statements.push(env.DB.prepare(
        'UPDATE character_items SET ammo_current = ? WHERE id = ?'
      ).bind(to, itemId));
    }
  }

  // WHERE A HIT LANDED (UI-AUDIT F40): an armour entry, or one location of a
  // vessel. Each carries the value it replaced - `raw_from` for armour, whose
  // M.D.C. is stored as typed text and may have been blank; `absent` for a
  // location that had taken no damage yet - so undo can put back exactly what
  // was there. Not guarded on replay, the standing an item change already has:
  // the guard above is per pool.
  if (changes.armor) {
    const { index, mdc_current: m } = changes.armor;
    if (!Number.isInteger(index) || typeof m?.to !== 'number' || typeof m?.from !== 'number') {
      return json({ error: 'armor change needs an integer index and numeric from and to' }, 400);
    }
    const row = await env.DB.prepare('SELECT armor FROM characters WHERE id = ?').bind(params.id).first();
    let armor;
    try { armor = JSON.parse(row?.armor || '[]'); } catch { armor = []; }
    if (!Array.isArray(armor) || !armor[index]) return json({ error: 'No such armour on this character' }, 404);
    armor[index] = { ...armor[index], mdc_current: String(Math.trunc(m.to)) };
    statements.push(env.DB.prepare(
      "UPDATE characters SET armor = ?, updated_at = datetime('now') WHERE id = ?"
    ).bind(JSON.stringify(armor), params.id));
  }
  if (changes.vehicle) {
    const { id: vid, location, mdc: m } = changes.vehicle;
    if (typeof location !== 'string' || !location || typeof m?.to !== 'number' || typeof m?.from !== 'number') {
      return json({ error: 'vehicle change needs a location and numeric from and to' }, 400);
    }
    const v = await env.DB.prepare(
      'SELECT id, vehicle_slug, mdc_current FROM character_vehicles WHERE id = ? AND character_id = ? AND removed_at IS NULL'
    ).bind(vid, params.id).first();
    if (!v) return json({ error: 'No such vessel on this character' }, 404);
    // The same check the vessel route makes: a location this vessel does not
    // have would render as a damaged part that does not exist.
    if (v.vehicle_slug) {
      const known = await env.DB.prepare(
        'SELECT 1 AS ok FROM vehicle_locations WHERE vehicle_slug = ? AND location = ?'
      ).bind(v.vehicle_slug, location).first();
      if (!known) return json({ error: `Not a location on this vessel: ${location}` }, 400);
    }
    let cur;
    try { cur = JSON.parse(v.mdc_current || '{}') || {}; } catch { cur = {}; }
    cur[location] = Math.trunc(m.to);
    statements.push(env.DB.prepare('UPDATE character_vehicles SET mdc_current = ? WHERE id = ?')
      .bind(JSON.stringify(cur), v.id));
  }

  // WHICH BODY TOOK IT. A change to a second form's pools says so in the note
  // the log, the undo and the G.M. read, and in `form` for anything that reads
  // the payload rather than the sentence. A first-form event is untouched.
  let note = typeof b.note === 'string' ? b.note.slice(0, 300) : undefined;
  const form = formView?.name || undefined;
  if (form) note = `${note || b.kind} (${form})`;
  const payload = JSON.stringify({ note, form, changes });
  statements.push(env.DB.prepare(
    'INSERT INTO play_events (character_id, actor_email, kind, payload) VALUES (?, ?, ?, ?)'
  ).bind(params.id, email, b.kind, payload));

  await env.DB.batch(statements);
  const row = await env.DB.prepare(
    'SELECT id, created_at FROM play_events WHERE character_id = ? ORDER BY id DESC LIMIT 1'
  ).bind(params.id).first();
  return json({ ok: true, event_id: row.id, created_at: row.created_at });
}
