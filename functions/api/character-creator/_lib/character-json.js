// Reading the JSON columns off a character row.
//
// `characters` stores seven sections as JSON text rather than ~40 scalar
// columns. Every endpoint that touches one was doing its own try/catch, with
// slightly different fallbacks — some `[]`, some `{}`, some leaving the raw
// string in place on a parse failure. Fourteen copies of the same three lines
// is how the fallbacks drifted.
//
// The fallback belongs to the column, not to the caller: `skills`, `powers` and
// `armor` default to `[]` in the schema, the rest to `{}`. A corrupt column
// therefore reads as empty rather than as a string, which is what every caller
// already assumed.

const ARRAY_COLUMNS = new Set(['skills', 'powers', 'armor']);

export const CHARACTER_JSON_COLUMNS = ['attributes', 'attribute_bonuses', 'skills', 'powers', 'bio', 'combat', 'saves', 'armor'];

// Parse, or fall back. Never throws — a malformed column should degrade to
// empty, not take down the request.
export function safeParse(text, fallback = null) {
  if (text === null || text === undefined) return fallback;
  if (typeof text === 'object') return text;   // already decoded
  try {
    const v = JSON.parse(text);
    return v === null || v === undefined ? fallback : v;
  } catch {
    return fallback;
  }
}

function emptyFor(column) {
  return ARRAY_COLUMNS.has(column) ? [] : {};
}

// Decode the named JSON columns on a row, in place. Columns the row does not
// carry are skipped rather than invented — a SELECT that asked for three
// columns should not come back with seven.
export function decodeCharacter(row, columns = CHARACTER_JSON_COLUMNS) {
  if (!row) return row;
  for (const col of columns) {
    if (row[col] === undefined) continue;
    row[col] = safeParse(row[col], emptyFor(col));
  }
  return row;
}

// Load a character and decode its JSON columns in one step.
//
// `columns` names the SQL columns to select; the JSON ones among them are
// decoded. Defaults to the whole row.
export async function loadCharacter(env, id, columns = ['*']) {
  const row = await env.DB
    .prepare(`SELECT ${columns.join(', ')} FROM characters WHERE id = ?`)
    .bind(id).first();
  return decodeCharacter(row);
}
