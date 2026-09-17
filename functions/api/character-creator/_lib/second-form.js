// The database half of a character's second body (BOOK-INGEST-AUDIT F74,
// Nightbane survey D5). The arithmetic is js/second-form.js, which does no I/O
// so the wizard and the smoke suite can call it; this file fetches what it
// needs - the traits catalog's rows for the keys a character holds.

import { getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';
import { resolveKeys } from './catalog-redirects.js';
import { selectInChunks } from './sql-chunk.js';

// The columns the fold and the validator read. Named rather than `*` so a
// catalog row's long description does not ride along on every sheet load.
const TRAIT_COLUMNS = 'id, key, table_name, name, kind, bonuses, horror_factor, horror_factor_set, sub_choices';

// The keys a stored form names, in order, without repeats.
export function traitKeysOf(state) {
  const list = Array.isArray(state?.results) ? state.results : [];
  return [...new Set(list.map((r) => r?.key).filter((k) => typeof k === 'string' && k.trim()))];
}

// A Map of `key` -> row for the keys a form holds, from the catalog the class's
// `second_form.traits_from` names. A key that has been RENAMED in the catalog
// editor since it was stored resolves through `catalog_redirects` and is filed
// under the key the character holds, so a rename does not strip a Morphus of
// its results - the same fall-through skill bonuses take.
export async function loadTraitRows(env, form, keys) {
  const out = new Map();
  const cat = form?.traits_from ? getCatalog(form.traits_from) : null;
  if (!cat || !keys?.length) return out;

  const rows = await selectInChunks(keys, (batch) => env.DB
    .prepare(`SELECT ${TRAIT_COLUMNS} FROM ${cat.table} WHERE key IN (${batch.map(() => '?').join(',')})`)
    .bind(...batch));
  for (const r of rows) out.set(r.key, r);

  const missing = keys.filter((k) => !out.has(k));
  if (missing.length) {
    const redirects = await resolveKeys(env, form.traits_from, missing);
    const ids = [...new Set([...redirects.values()])].filter((v) => v != null);
    if (ids.length) {
      const found = await selectInChunks(ids, (batch) => env.DB
        .prepare(`SELECT ${TRAIT_COLUMNS} FROM ${cat.table} WHERE id IN (${batch.map(() => '?').join(',')})`)
        .bind(...batch));
      const byId = new Map(found.map((r) => [r.id, r]));
      for (const k of missing) {
        const row = byId.get(redirects.get(String(k).trim().toLowerCase()));
        if (row) out.set(k, row);
      }
    }
  }
  return out;
}
