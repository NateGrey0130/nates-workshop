// /api/filament-forge/data — everything FilamentForge keeps for one user:
// printer config, generation history, saved presets, custom filaments.
//
// GET returns all four; PUT replaces whichever of the four the body carries
// and leaves the rest alone — MediaVault's whole-library-replace pattern, per
// collection. The client's in-memory arrays are the source of truth and every
// save sends the whole collection, which is also what makes the one-time
// localStorage import free: the first save after migration IS the import.
//
// Rows round-trip in insertion order (ORDER BY rowid), so the client's
// newest-first arrays come back exactly as they were sent.

import { getUserEmail, json } from './_lib/common.js';

// The sanitizers and the cap are exported for the app's smoke test, the way
// the character creator's endpoints export their pure parts.

export const MAX_HISTORY = 50;      // the client has always capped history at 50
const MAX_PRESETS = 200;
const MAX_CUSTOM = 200;
const MAX_FIELD = 300;       // names, brands, intents — short strings
const MAX_BLOB = 20000;      // settings JSON / raw model output

const str = (v, max = MAX_FIELD) => (typeof v === 'string' ? v.slice(0, max) : '');

export function sanitizeEntry(raw) {
  if (!raw || typeof raw !== 'object') return null;
  if (typeof raw.id !== 'string' || !raw.id || raw.id.length > 100) return null;
  const f = raw.filament || {};
  return {
    id: raw.id,
    timestamp: str(raw.timestamp) || new Date().toISOString(),
    brand: str(f.brand),
    name: str(f.name),
    material: str(f.material),
    printer: str(raw.printer),
    nozzle: str(raw.nozzle),
    intent: str(raw.intent),
    settings: JSON.stringify(raw.settings && typeof raw.settings === 'object' ? raw.settings : {}).slice(0, MAX_BLOB),
    rawJSON: str(raw.rawJSON, MAX_BLOB),
  };
}

export function sanitizePreset(raw) {
  const entry = sanitizeEntry(raw);
  if (!entry) return null;
  if (typeof raw.presetName !== 'string' || !raw.presetName.trim()) return null;
  entry.presetName = str(raw.presetName);
  entry.savedAt = str(raw.savedAt) || new Date().toISOString();
  return entry;
}

export function sanitizeCustom(raw) {
  if (!raw || typeof raw !== 'object') return null;
  if (typeof raw.id !== 'string' || !raw.id || raw.id.length > 100) return null;
  if (typeof raw.brand !== 'string' || !raw.brand.trim()) return null;
  if (typeof raw.name !== 'string' || !raw.name.trim()) return null;
  return {
    id: raw.id,
    brand: str(raw.brand),
    name: str(raw.name),
    material: str(raw.material),
    min_print_temp: str(raw.min_print_temp),
    max_print_temp: str(raw.max_print_temp),
    min_bed_temp: str(raw.min_bed_temp),
    max_bed_temp: str(raw.max_bed_temp),
  };
}

export function entryOut(row) {
  let settings = {};
  try { settings = JSON.parse(row.settings); } catch {}
  return {
    id: row.entry_id,
    timestamp: row.created_at,
    filament: { brand: row.brand, name: row.name, material: row.material },
    printer: row.printer,
    nozzle: row.nozzle,
    intent: row.intent,
    settings,
    rawJSON: row.raw_json,
  };
}

// GET → { email, config, history, presets, customFilaments }
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);
  const db = context.env.DB;
  try {
    const [config, history, presets, custom] = await Promise.all([
      db.prepare('SELECT printer, nozzle, ams FROM ff_config WHERE email = ?').bind(email).all(),
      db.prepare('SELECT * FROM ff_history WHERE email = ? ORDER BY rowid').bind(email).all(),
      db.prepare('SELECT * FROM ff_presets WHERE email = ? ORDER BY rowid').bind(email).all(),
      db.prepare('SELECT * FROM ff_custom_filaments WHERE email = ? ORDER BY rowid').bind(email).all(),
    ]);
    return json({
      email,
      config: config.results[0] || null,
      history: history.results.map(entryOut),
      presets: presets.results.map((r) => ({ ...entryOut(r), presetName: r.preset_name, savedAt: r.saved_at })),
      customFilaments: custom.results.map((r) => ({
        id: r.filament_id, source: 'custom', brand: r.brand, name: r.name, material: r.material,
        min_print_temp: r.min_print_temp, max_print_temp: r.max_print_temp,
        min_bed_temp: r.min_bed_temp, max_bed_temp: r.max_bed_temp,
      })),
    });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// PUT { config?, history?, presets?, customFilaments? } — replaces what it carries
export async function onRequestPut(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }
  if (!body || typeof body !== 'object') return json({ error: 'Body must be an object' }, 400);

  const db = context.env.DB;
  const statements = [];

  if ('config' in body) {
    const c = body.config || {};
    statements.push(db.prepare(
      `INSERT INTO ff_config (email, printer, nozzle, ams, updated_at)
       VALUES (?, ?, ?, ?, datetime('now'))
       ON CONFLICT (email) DO UPDATE SET printer = excluded.printer,
         nozzle = excluded.nozzle, ams = excluded.ams, updated_at = excluded.updated_at`
    ).bind(email, str(c.printer), str(c.nozzle), str(c.ams)));
  }

  if ('history' in body) {
    if (!Array.isArray(body.history)) return json({ error: 'history must be an array' }, 400);
    const entries = body.history.slice(0, MAX_HISTORY).map(sanitizeEntry);
    if (entries.some((e) => !e)) return json({ error: 'Every history entry needs a string id' }, 400);
    statements.push(db.prepare('DELETE FROM ff_history WHERE email = ?').bind(email));
    const ins = db.prepare(
      `INSERT INTO ff_history (email, entry_id, created_at, brand, name, material, printer, nozzle, intent, settings, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const e of entries) {
      statements.push(ins.bind(email, e.id, e.timestamp, e.brand, e.name, e.material,
        e.printer, e.nozzle, e.intent, e.settings, e.rawJSON));
    }
  }

  if ('presets' in body) {
    if (!Array.isArray(body.presets)) return json({ error: 'presets must be an array' }, 400);
    if (body.presets.length > MAX_PRESETS) return json({ error: `Too many presets (max ${MAX_PRESETS})` }, 400);
    const entries = body.presets.map(sanitizePreset);
    if (entries.some((e) => !e)) return json({ error: 'Every preset needs a string id and a name' }, 400);
    statements.push(db.prepare('DELETE FROM ff_presets WHERE email = ?').bind(email));
    const ins = db.prepare(
      `INSERT INTO ff_presets (email, entry_id, preset_name, saved_at, created_at, brand, name, material, printer, nozzle, intent, settings, raw_json)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const e of entries) {
      statements.push(ins.bind(email, e.id, e.presetName, e.savedAt, e.timestamp, e.brand, e.name,
        e.material, e.printer, e.nozzle, e.intent, e.settings, e.rawJSON));
    }
  }

  if ('customFilaments' in body) {
    if (!Array.isArray(body.customFilaments)) return json({ error: 'customFilaments must be an array' }, 400);
    if (body.customFilaments.length > MAX_CUSTOM) return json({ error: `Too many custom filaments (max ${MAX_CUSTOM})` }, 400);
    const entries = body.customFilaments.map(sanitizeCustom);
    if (entries.some((e) => !e)) return json({ error: 'Every custom filament needs a string id, brand and name' }, 400);
    statements.push(db.prepare('DELETE FROM ff_custom_filaments WHERE email = ?').bind(email));
    const ins = db.prepare(
      `INSERT INTO ff_custom_filaments (email, filament_id, brand, name, material, min_print_temp, max_print_temp, min_bed_temp, max_bed_temp)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
    );
    for (const e of entries) {
      statements.push(ins.bind(email, e.id, e.brand, e.name, e.material,
        e.min_print_temp, e.max_print_temp, e.min_bed_temp, e.max_bed_temp));
    }
  }

  if (statements.length === 0) {
    return json({ error: 'Body carried none of config, history, presets, customFilaments' }, 400);
  }

  try {
    await db.batch(statements);
    return json({ ok: true });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
