// Admin CRUD-minus-delete over the content catalogs.
//
// GET    /api/character-creator/catalogs/rows?catalog=skills        — full rows
// POST   /api/character-creator/catalogs/rows?catalog=skills        — create one
// PATCH  /api/character-creator/catalogs/rows?catalog=skills&id=12  — update one
//
// Separate from /catalogs, which the wizard boots on and which deliberately
// returns a trimmed projection with no ids. Editing needs whole rows, and only
// an admin should get them.
//
// Catalogs are global: one edit here changes every character that uses the row.
// That is why this is admin-gated and why there is no delete — a wrong row gets
// corrected, not removed.
//
// SQL is built from apps/character-creator/js/catalog-fields.js and nothing
// else. A caller names a catalog key, never a table or a column.

import { requireAdmin, readJson, json } from '../_lib/auth.js';
import { getCatalog, fieldNames, coerceField, decodeRow } from '../../../../apps/character-creator/js/catalog-fields.js';
import { redirectTarget, redirectStatements } from '../_lib/catalog-redirects.js';

// A key that redirects belongs to a row that was merged away or renamed, and
// class markdown may still cite it. Letting a new row claim it would shadow the
// forwarding address — the citation would silently start resolving somewhere
// else, which is the exact ambiguity redirects exist to remove. So: refuse, and
// say what the key currently points at.
async function keyClash(env, catalogKey, cat, value) {
  if (!value) return null;
  const hit = await redirectTarget(env, catalogKey, value);
  if (!hit) return null;
  return json({
    error: `"${value}" redirects to "${hit.target_name}". Remove that redirect first if you mean to reuse the ${cat.uniqueField}.`,
    redirects_to: { id: hit.to_id, name: hit.target_name },
  }, 409);
}

function resolve(request) {
  const params = new URL(request.url).searchParams;
  const key = params.get('catalog');
  const cat = getCatalog(key);
  if (!cat) return { err: json({ error: 'Unknown catalog' }, 400) };
  return { key, cat, params };
}

// Coerce a whole payload against the config. `partial` skips fields the caller
// did not mention, so a PATCH does not blank out everything it omitted.
function buildValues(cat, body, { partial }) {
  const values = {};
  const errors = [];
  for (const f of cat.fields) {
    if (partial && !Object.prototype.hasOwnProperty.call(body, f.name)) continue;
    const { value, error } = coerceField(f, body[f.name]);
    if (error) errors.push(error);
    else values[f.name] = value;
  }
  return { values, errors };
}

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { cat, err } = resolve(request);
  if (err) return err;

  const cols = ['id', ...fieldNames(cat), ...(cat.hasSource ? ['source'] : [])].join(', ');
  const { results } = await env.DB.prepare(
    `SELECT ${cols} FROM ${cat.table} ORDER BY ${cat.displayField}`
  ).all();

  return json({ rows: results.map((r) => decodeRow(cat, r)) });
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, cat, err } = resolve(request);
  if (err) return err;

  const body = await readJson(request);
  if (!body) return json({ error: 'Body must be JSON' }, 400);

  const { values, errors } = buildValues(cat, body, { partial: false });
  if (errors.length) return json({ error: errors.join('; '), errors }, 422);

  const clash = await keyClash(env, key, cat, values[cat.uniqueField]);
  if (clash) return clash;

  // Hand-made rows are marked so a later import can tell curated data from
  // extracted data — the importers default a curated row to "ignore".
  if (cat.hasSource) values.source = 'manual';

  const cols = Object.keys(values);
  const sql = `INSERT INTO ${cat.table} (${cols.join(', ')}) VALUES (${cols.map(() => '?').join(', ')})`;

  try {
    const res = await env.DB.prepare(sql).bind(...cols.map((c) => values[c])).run();
    return json({ ok: true, id: res.meta?.last_row_id }, 201);
  } catch (e) {
    // The unique constraint is the expected failure here; surface it as a
    // conflict rather than a 500 the UI cannot explain.
    if (/UNIQUE/i.test(e.message || '')) {
      return json({ error: `A row with that ${cat.uniqueField} already exists` }, 409);
    }
    throw e;
  }
}

export async function onRequestPatch({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, cat, params, err } = resolve(request);
  if (err) return err;

  const id = parseInt(params.get('id'), 10);
  if (!Number.isFinite(id)) return json({ error: 'A numeric id is required' }, 400);

  const body = await readJson(request);
  if (!body) return json({ error: 'Body must be JSON' }, 400);

  const { values, errors } = buildValues(cat, body, { partial: true });
  if (errors.length) return json({ error: errors.join('; '), errors }, 422);
  if (!Object.keys(values).length) return json({ error: 'Nothing to update' }, 400);

  // Read before writing, for two reasons: it distinguishes "no such row" from
  // "nothing changed", and a renamed key needs to know what it used to be.
  const before = await env.DB.prepare(
    `SELECT id, ${cat.uniqueField}, ${cat.displayField} FROM ${cat.table} WHERE id = ?`
  ).bind(id).first();
  if (!before) return json({ error: 'No row with that id' }, 404);

  const clash = await keyClash(env, key, cat, values[cat.uniqueField]);
  if (clash) return clash;

  // An edited row is curated from here on, whatever produced it originally.
  if (cat.hasSource) values.source = 'manual';

  const cols = Object.keys(values);
  const sql = `UPDATE ${cat.table} SET ${cols.map((c) => `${c} = ?`).join(', ')} WHERE id = ?`;
  const statements = [env.DB.prepare(sql).bind(...cols.map((c) => values[c]), id)];

  // Renaming a key by hand breaks the same class citations a merge does — the
  // field help has always warned that changing a slug breaks the link. It no
  // longer does: the old key keeps resolving to this row.
  const renamed = [cat.uniqueField, cat.displayField]
    .filter((f, i, arr) => arr.indexOf(f) === i)
    .filter((f) => Object.prototype.hasOwnProperty.call(values, f) && values[f] !== before[f])
    .map((f) => before[f]);
  statements.push(...redirectStatements(env, key, renamed, id, 'rename',
    [values[cat.uniqueField] ?? before[cat.uniqueField], values[cat.displayField] ?? before[cat.displayField]]));

  try {
    await env.DB.batch(statements);
    return json({ ok: true, id, redirected: renamed });
  } catch (e) {
    if (/UNIQUE/i.test(e.message || '')) {
      return json({ error: `A row with that ${cat.uniqueField} already exists` }, 409);
    }
    throw e;
  }
}
