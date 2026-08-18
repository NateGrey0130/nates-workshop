// Shared machinery for the catalog PDF importers.
//
// Extracted from the skill importer, which was the only one. Spells, psionic
// powers and gear are configurations of this rather than copies of it, so a fix
// here is a fix everywhere instead of the same fix four times.
//
// The pipeline is the same for every catalog:
//   extractRows   send the PDF, parse the reply, reject a truncated one
//   normaliseRows keep only well-formed rows; one bad element must not sink the batch
//   classifyRows  match against the live catalog so review can ask about duplicates
//   applyDecisions write the reviewed decisions as one all-or-nothing batch
//
// What differs per catalog lives in IMPORT_SPECS below. Column names and types
// come from apps/character-creator/js/catalog-fields.js — the same config the
// catalog editor and the write endpoints use.
//
// The PDF goes to the model as a document attachment, never as pre-extracted
// text: layout-preserving extraction splices neighbouring columns together
// mid-line on two-column sourcebook pages. Do not add a text pre-pass.
//
// Server-side callers use claude-client directly. Never fetch the site's own
// /api/claude URL — in production Access intercepts the subrequest and returns
// the login page as HTML.

import { validateClaudeRequest, callAnthropic } from '../../_lib/claude-client.js';
import { CATALOGS } from '../../../../apps/character-creator/js/catalog-fields.js';

export const DEFAULT_MODEL = 'claude-sonnet-5';
export const ALLOWED_MODELS = ['claude-sonnet-5', 'claude-opus-5'];
const LOOKUP_BATCH = 50;
const MAX_NAME_LENGTH = 120;
export const MAX_DECISIONS = 500;

// Per-catalog import behaviour. `catalog` names an entry in CATALOGS, which
// supplies the columns; this supplies what the importer does with them.
const IMPORT_SPECS = {
  skills: {
    catalog: 'skills',
    table: 'skills',
    // Written by the importer. Everything else on the row keeps its default.
    extractFields: ['name', 'category', 'base', 'per_level', 'note'],
    // A duplicate "differs" when one of these disagrees with the book.
    compareFields: ['base', 'per_level'],
    // A stub is a name the class importer created with no numbers — exactly
    // what this importer exists to fill in, so it defaults to update. A row
    // edited by hand has source 'manual' and is therefore never a stub.
    isStub: (row) => row.source === 'import' && row.base === 0 && row.per_level === 0,
  },

  spells: {
    catalog: 'spells',
    table: 'spells',
    extractFields: ['name', 'level', 'ppe', 'range', 'duration', 'damage',
                    'saving_throw', 'area_of_effect', 'casting_time', 'description'],
    // The two numbers. A book disagreeing about PPE or level is worth flagging;
    // differing prose in a description is not.
    compareFields: ['level', 'ppe'],
    // The class importer creates spell stubs as (level 0, ppe 0, source
    // 'import') — a name with nothing behind it, which is what this fills in.
    isStub: (row) => row.source === 'import' && row.ppe === 0,
  },

  psionics: {
    catalog: 'psionics',
    table: 'psionic_powers',
    extractFields: ['name', 'category', 'isp', 'isp_note', 'range', 'duration', 'saving_throw',
                    'description', 'min_tier'],
    compareFields: ['isp'],
    // A note-carrying zero is deliberate (Meditation genuinely costs nothing),
    // not a row waiting for stats.
    isStub: (row) => row.source === 'import' && row.isp === 0 && !row.isp_note,
    // Not a gate. An unrecognised category is surfaced in review so it can be
    // accepted or corrected — a later supplement may add one the core four do
    // not cover, and rejecting it outright would make that book unimportable.
    flag: (row) => {
      const known = ['Healing', 'Physical', 'Sensitive', 'Super'];
      const flags = [];
      if (row.category && !known.some((k) => k.toLowerCase() === row.category.toLowerCase())) {
        flags.push(`Unrecognised category "${row.category}"`);
      }
      if (row.min_tier && !['minor', 'major', 'master'].includes(String(row.min_tier).toLowerCase())) {
        flags.push(`Unrecognised psychic tier "${row.min_tier}"`);
      }
      // A zero with no schedule is either a genuinely free power (rare) or a
      // variable cost the extraction gave up on — either way worth eyes on it.
      if (row.isp === 0 && !row.isp_note) {
        flags.push('I.S.P. 0 with no cost note — free power, or a missed variable cost?');
      }
      return flags;
    },
  },

  gear: {
    catalog: 'gear',
    table: 'gear',
    extractFields: ['name', 'slug', 'category', 'weight_lbs', 'cost', 'damage',
                    'is_mega_damage', 'range', 'payload', 'rate_of_fire', 'ar', 'mdc',
                    'description'],
    // Cost is the number worth arguing about; damage and the rest are prose.
    compareFields: ['cost'],
    // Books do not print slugs. Derive one the same way the class importer's
    // titleize() runs in reverse, so a book's "Air Filter and Gas Mask" lands on
    // the stub already stored as `air-filter-and-gas-mask`.
    derive: (row) => { row.slug = row.slug || slugify(row.name); },
    // Slug first, then the display name. A stub's slug comes from class
    // markdown and does not always match what a book's wording produces; a
    // missed match creates a second row while characters keep pointing at the
    // empty one, which is the worst outcome available here.
    matchFields: ['slug', 'name'],
    // Gear has no `source` column, so the marker the class importer writes is
    // the signal. A row edited by hand no longer carries it and correctly stops
    // counting as a stub.
    isStub: (row) => typeof row.description === 'string' && row.description.startsWith('STUB —'),
  },
};

export function getImportSpec(key) {
  return Object.prototype.hasOwnProperty.call(IMPORT_SPECS, key) ? IMPORT_SPECS[key] : null;
}

// A model sometimes wraps JSON in a code fence despite being told not to.
export function stripFences(text) {
  const t = text.trim();
  const fenced = t.match(/^```(?:json)?\s*\n([\s\S]*?)\n```$/);
  return (fenced ? fenced[1] : t).trim();
}

// A number the book states, or what the config says an unstated one means.
//
// `blankAs` mirrors a NOT NULL DEFAULT in the schema: skills.base and friends
// must fall back to 0 because the column cannot hold NULL. Columns that CAN
// hold NULL — gear's ar, mdc, cost, weight_lbs — must stay null instead, since
// "this item has no A.R." and "this item has A.R. 0" are different claims and
// the sheet renders the second one.
function num(field, v) {
  const blank = v === undefined || v === null || v === '';
  if (blank) return field?.blankAs ?? null;
  // parseInt for int columns, parseFloat for real ones. Using parseInt for both
  // silently truncated every fractional value: gear's weight_lbs is `real`, and
  // a two-ounce laser wand imported as 0 lb — "weightless" rather than "light".
  const n = field?.type === 'real' ? parseFloat(v) : parseInt(v, 10);
  if (!Number.isFinite(n) || n < 0) return field?.blankAs ?? null;
  return n;
}

function fieldDef(spec, name) {
  return CATALOGS[spec.catalog]?.fields.find((f) => f.name === name) ?? null;
}

function fieldType(spec, name) {
  return fieldDef(spec, name)?.type ?? 'text';
}

// Keeps only well-formed rows. A malformed element is dropped rather than
// failing the batch — one unreadable entry on a dense page should not cost you
// the other thirty.
export function normaliseRows(spec, raw) {
  const rows = [];
  for (const r of Array.isArray(raw) ? raw : []) {
    // Book headings carry a trailing colon; the catalog name never does.
    const name = typeof r?.name === 'string' ? r.name.trim().replace(/:$/, '') : '';
    if (!name || name.length > MAX_NAME_LENGTH) continue;

    const row = { name };
    for (const f of spec.extractFields) {
      if (f === 'name') continue;
      const v = r[f];
      const def = fieldDef(spec, f);
      const type = def?.type ?? 'text';
      if (type === 'int' || type === 'real') {
        row[f] = num(def, v);
      } else if (type === 'bool') {
        // The model answers with a real boolean; a book might say "M.D." in
        // prose and leave this out entirely, which reads as false.
        row[f] = v === true || String(v).trim().toLowerCase() === 'true' ? 1 : 0;
      } else {
        row[f] = typeof v === 'string' && v.trim() ? v.trim() : null;
      }
    }
    // A catalog keyed on something the book does not print — gear's slug —
    // derives it rather than asking the model to invent one.
    if (spec.derive) spec.derive(row);
    rows.push(row);
  }
  return rows;
}

// Mirrors the titleize() the class importer uses when it turns an
// equipment_starting item_id into a stub name, so a book's "Air Filter and Gas
// Mask" lands on the stub already stored as `air-filter-and-gas-mask`.
export function slugify(name) {
  return String(name || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

// Match extracted rows against the catalog. Lookups are batched because a spell
// chapter can be hundreds of names and one query per name would be absurd.
export async function classifyRows(env, spec, rows) {
  const cat = CATALOGS[spec.catalog];
  const key = cat.uniqueField;
  // Most catalogs match on their unique column alone. Gear also falls back to
  // the display name, because its stubs are keyed on a slug taken from class
  // markdown, which does not always match the slug a book's wording produces —
  // and a missed match means a second row while characters keep pointing at the
  // empty one.
  const matchFields = spec.matchFields?.length ? spec.matchFields : [key];
  const cols = ['id', ...new Set([key, ...matchFields, ...spec.extractFields, ...spec.compareFields])];
  if (cat.hasSource) cols.push('source');
  cols.push('source_book');

  // One index per match field, filled from a single batched read per field.
  const byField = new Map(matchFields.map((f) => [f, new Map()]));
  for (const field of matchFields) {
    const values = [...new Set(rows.map((r) => r[field]).filter(Boolean))];
    for (let i = 0; i < values.length; i += LOOKUP_BATCH) {
      const batch = values.slice(i, i + LOOKUP_BATCH);
      const { results } = await env.DB
        .prepare(`SELECT ${[...new Set(cols)].join(', ')} FROM ${spec.table}
                  WHERE ${field} COLLATE NOCASE IN (${batch.map(() => '?').join(',')})`)
        .bind(...batch).all();
      for (const r of results) {
        if (r[field] != null) byField.get(field).set(String(r[field]).toLowerCase(), r);
      }
    }
  }

  return rows.map((r) => {
    // Advisory only — a flagged row still imports, it just says why it deserves
    // a second look before you confirm it.
    const flags = spec.flag ? spec.flag(r) : [];
    // First match wins, in the order the spec lists them.
    let match = null;
    let matchedOn = null;
    for (const field of matchFields) {
      const v = r[field];
      if (!v) continue;
      const hit = byField.get(field).get(String(v).toLowerCase());
      if (hit) { match = hit; matchedOn = field; break; }
    }
    if (!match) return { ...r, status: 'new', existing: null, differs: false, flags };
    // Surfaced in review so a fallback match is visible rather than assumed.
    if (matchedOn !== key) flags.push(`Matched an existing row on ${matchedOn}, not ${key}`);
    const differs = spec.compareFields.some((f) => match[f] !== r[f]);
    const isStub = spec.isStub ? spec.isStub(match) : false;
    return {
      ...r,
      status: 'duplicate',
      existing: match,
      differs,
      is_stub: isStub,
      flags,
      // Anything already curated defaults to ignore, so hand-corrected numbers
      // are never silently overwritten by a second book.
      suggested: isStub ? 'update' : 'ignore',
    };
  });
}

export function countRows(classified) {
  return {
    total: classified.length,
    new: classified.filter((r) => r.status === 'new').length,
    duplicates: classified.filter((r) => r.status === 'duplicate').length,
    stubs: classified.filter((r) => r.is_stub).length,
  };
}

// Send the PDF and give back the model's rows, or an error shaped for the API.
// Returns { rows } or { error, status, extra }.
export async function extractRows(env, spec, { pdfBase64, model, systemPrompt, userPrompt }) {
  if (!env.ANTHROPIC_API_KEY) return { error: 'API key not configured on server', status: 500 };

  const claudeRequest = {
    model,
    max_tokens: 16000,
    // Same posture as import/extract.js: Sonnet 5 thinks by default and the
    // thinking spend comes out of max_tokens, which can starve the actual rows.
    thinking: { type: 'disabled' },
    system: systemPrompt,
    messages: [{
      role: 'user',
      content: [
        { type: 'document', source: { type: 'base64', media_type: 'application/pdf', data: pdfBase64 } },
        { type: 'text', text: userPrompt },
      ],
    }],
  };
  const invalid = validateClaudeRequest(claudeRequest);
  if (invalid) return { error: 'Built an invalid extraction request: ' + invalid, status: 400 };

  const upstream = await callAnthropic(claudeRequest, env);
  let payload;
  try { payload = JSON.parse(upstream.text); }
  catch {
    return { error: `Anthropic returned a non-JSON response (status ${upstream.status})`, status: 502,
             extra: { body_preview: upstream.text.slice(0, 300) } };
  }
  if (upstream.status !== 200) {
    return { error: 'Extraction call failed: ' + (payload.error?.message || `status ${upstream.status}`), status: 502 };
  }

  const blocks = Array.isArray(payload.content) ? payload.content : [];
  const text = blocks.filter((c) => c.type === 'text').map((c) => c.text).join('\n').trim();
  if (!text) {
    return { error: 'Extraction produced no usable text', status: 502,
             extra: { diagnostics: { stop_reason: payload.stop_reason ?? null,
                                     block_types: blocks.map((c) => c.type),
                                     usage: payload.usage ?? null } } };
  }

  // A truncated reply must not be treated as a complete one. Staging half a
  // page as though it were the whole page is worse than failing: you would
  // confirm it without ever knowing the tail was missing.
  if (payload.stop_reason === 'max_tokens') {
    return { error: 'The reply hit the output limit, so those pages were only partly read. Narrow the page range and try again.',
             status: 502, extra: { stop_reason: payload.stop_reason, usage: payload.usage ?? null } };
  }

  let parsed;
  try { parsed = JSON.parse(stripFences(text)); }
  catch {
    return { error: 'Model did not return valid JSON', status: 502, extra: { body_preview: text.slice(0, 400) } };
  }

  return { rows: parsed, usage: payload.usage ?? null };
}

// Apply reviewed decisions as one all-or-nothing batch.
//
//   insert  add a new row. Also carries "keep both", where the caller supplies
//           a distinguished as_name because the key column is UNIQUE.
//   update  overwrite the existing row from the book
//   ignore  do nothing
export async function applyDecisions(env, spec, decisions, { sourceBook, system } = {}) {
  const cat = CATALOGS[spec.catalog];
  const key = cat.uniqueField;
  const writable = spec.extractFields.filter((f) => f !== key);

  const statements = [];
  const applied = { inserted: [], updated: [], ignored: [] };
  const conflicts = [];

  const inserts = [];
  const updates = [];
  for (const d of decisions) {
    const action = d?.action;
    if (action === 'ignore' || !action) { if (d?.[key]) applied.ignored.push(d[key]); continue; }
    if (action !== 'insert' && action !== 'update') {
      return { error: `Unknown action: ${action}`, status: 400 };
    }
    const name = typeof d[key] === 'string' ? d[key].trim() : '';
    if (!name) return { error: `Every decision needs a ${key}`, status: 400 };
    if (action === 'insert') {
      const target = typeof d.as_name === 'string' && d.as_name.trim() ? d.as_name.trim() : name;
      inserts.push({ d, target });
    } else {
      updates.push({ d, name });
    }
  }

  // One batched lookup covering both proposed inserts and proposed updates,
  // rather than a query per row.
  //
  // Updates have to be checked as carefully as inserts. An UPDATE that matches
  // nothing succeeds silently — it is indistinguishable from one that worked —
  // so without this a row could be reported as updated, and marked confirmed by
  // the session flow, while the extracted values were quietly thrown away. That
  // happens for real: stage a duplicate, rename the catalog row it matched, then
  // confirm.
  const present = new Set();
  const lookups = [...new Set([...inserts.map((i) => i.target), ...updates.map((u) => u.name)])];
  for (let i = 0; i < lookups.length; i += LOOKUP_BATCH) {
    const batch = lookups.slice(i, i + LOOKUP_BATCH);
    const { results } = await env.DB
      .prepare(`SELECT ${key} FROM ${spec.table} WHERE ${key} COLLATE NOCASE IN (${batch.map(() => '?').join(',')})`)
      .bind(...batch).all();
    for (const r of results) present.add(String(r[key]).toLowerCase());
  }
  const taken = present;

  // An update with nothing to update is reported as a conflict rather than a
  // success, which also leaves the staged row pending so it can be retried as
  // an insert instead of vanishing.
  for (const { d, name } of updates) {
    if (!present.has(name.toLowerCase())) {
      conflicts.push({ name, reason: `No row with that ${key} to update — it may have been renamed since this was extracted` });
      continue;
    }
    applied.updated.push(name);
    statements.push(buildUpdate(env, spec, cat, writable, d, name, sourceBook));
  }

  // Names claimed twice inside THIS batch. Checking only the database would miss
  // them, and the UNIQUE constraint would fail the whole import with an opaque
  // error instead of naming the offender.
  const queued = new Set();
  for (const { d, target } of inserts) {
    const lower = target.toLowerCase();
    if (queued.has(lower)) { conflicts.push({ name: target, reason: 'Named twice in this same import' }); continue; }
    if (taken.has(lower)) { conflicts.push({ name: target, reason: `A row with that ${key} already exists` }); continue; }
    queued.add(lower);
    statements.push(buildInsert(env, spec, cat, writable, d, target, sourceBook, system));
    applied.inserted.push(target);
  }

  try {
    if (statements.length) await env.DB.batch(statements);
  } catch (err) {
    // All-or-nothing: nothing was written, so say so rather than leaving the
    // caller to guess which half landed.
    return { error: 'Nothing was imported — the database rejected the batch: ' + err.message, status: 409 };
  }

  return {
    ok: true,
    counts: { inserted: applied.inserted.length, updated: applied.updated.length, ignored: applied.ignored.length },
    applied,
    conflicts,
  };
}

function valueFor(spec, field, d) {
  const def = fieldDef(spec, field);
  const type = def?.type ?? 'text';
  if (type === 'int' || type === 'real') return num(def, d[field]);
  // Booleans are stored 0/1 in a NOT NULL column, so an absent one is false,
  // never null.
  if (type === 'bool') return d[field] === true || d[field] === 1 ? 1 : 0;
  return typeof d[field] === 'string' && d[field].trim() ? d[field].trim() : null;
}

// Fields written outright rather than through COALESCE. A number or a flag the
// book states is the correction you asked for; absent prose must not blank a
// description the catalog already has.
function isScalar(type) {
  return type === 'int' || type === 'real' || type === 'bool';
}

// Where a catalog records which game system a row belongs to, and how.
//
// Three shapes across four catalogs, all read off the field config rather than
// hardcoded: skills keep a JSON ARRAY (`systems`), the rest a single string
// (`system`), and a catalog without either gets nothing stamped.
//
// NULL means unrestricted everywhere, so a session that does not name a system
// — or names "both" — writes nothing rather than inventing a restriction.
export function systemColumnFor(cat, system) {
  if (!system || system === 'both') return null;
  const arrayField = cat.fields.find((f) => f.type === 'systems');
  if (arrayField) return { col: arrayField.name, value: JSON.stringify([system]) };
  const scalarField = cat.fields.find((f) => f.name === 'system');
  if (scalarField) return { col: scalarField.name, value: system };
  return null;
}

// Stamped on INSERT only. An update is a correction to a row's numbers from a
// book; silently reclassifying which system an existing row belongs to is a
// different and much larger claim, and not one the operator asked for.
function buildInsert(env, spec, cat, writable, d, target, sourceBook, system) {
  const cols = [cat.uniqueField, ...writable, 'source_book'];
  const vals = [target, ...writable.map((f) => valueFor(spec, f, d)), sourceBook];
  if (cat.hasSource) { cols.push('source'); vals.push('import'); }

  const sys = systemColumnFor(cat, system);
  // Skipped when the extraction already produced the column itself — gear's
  // prompt can emit `system`, and what the book actually said wins over the
  // session default.
  if (sys && !cols.includes(sys.col)) { cols.push(sys.col); vals.push(sys.value); }
  return env.DB.prepare(
    `INSERT INTO ${spec.table} (${cols.join(', ')}) VALUES (${cols.map(() => '?').join(', ')})`
  ).bind(...vals);
}

function buildUpdate(env, spec, cat, writable, d, name, sourceBook) {
  // COALESCE on the nullable descriptive fields: a book that is silent about a
  // category or a note must not blank one the catalog already has. Numbers are
  // set outright, because that is the correction you asked for.
  const sets = [];
  const vals = [];
  for (const f of writable) {
    if (isScalar(fieldType(spec, f))) sets.push(`${f} = ?`);
    else sets.push(`${f} = COALESCE(?, ${f})`);
    vals.push(valueFor(spec, f, d));
  }
  sets.push('source_book = COALESCE(?, source_book)');
  vals.push(sourceBook);
  return env.DB.prepare(
    `UPDATE ${spec.table} SET ${sets.join(', ')} WHERE ${cat.uniqueField} COLLATE NOCASE = ?`
  ).bind(...vals, name);
}
