// Reading class definitions out of D1.
//
// D1 is the only source of class definitions. (An earlier design kept committed
// markdown under apps/character-creator/data/classes and let it win on an id
// collision; that is gone, and this comment used to still describe it.) A row
// goes live without a redeploy, and an extraction is saved as a draft the moment
// it parses so a closed browser tab never loses the work.
//
// Retirement is a soft delete: `deleted_at` NULL means live. A retired class
// disappears from the pickers but characters built on it keep working, which is
// why getStored() — the path the sheet and the level-up endpoints resolve
// through — deliberately does not filter on it.

import { parseClassMarkdown } from '../../../../apps/character-creator/js/parser.js';

// Deliberately unfiltered on deleted_at. This is how a character's class is
// resolved for the sheet and for level-ups, and retiring a class must not break
// a character someone is in the middle of playing.
export async function getStored(env, classId) {
  return env.DB.prepare('SELECT * FROM imported_classes WHERE class_id = ?').bind(classId).first();
}

// Parsing is deterministic for a given markdown, so results are memoised per
// isolate and keyed on updated_at. Three pages request the class list on load;
// without this, each request re-parses every class in the catalog.
const parseCache = new Map(); // class_id -> { updated_at, parsed }

// Published rows, parsed. Anything that no longer parses is skipped and
// reported rather than breaking the class list for everyone.
//
// Retired classes are excluded by default so every caller is safe without
// remembering to filter. `includeRetired` is for the two callers that need to
// resolve a name for a character that already exists — the sheet and the GM
// dashboard — and those rows carry `_retired: true`.
//
// Note the cache needs no invalidation on retirement: it is only consulted for
// rows this query returned, so an excluded row can never be served from it.
export async function loadPublished(env, { includeRetired = false } = {}) {
  const classes = [];
  const failures = [];
  let results = [];
  try {
    ({ results } = await env.DB.prepare(
      `SELECT class_id, markdown, updated_at, deleted_at FROM imported_classes
       WHERE status = 'published'${includeRetired ? '' : ' AND deleted_at IS NULL'}`
    ).all());
  } catch {
    return { classes, failures }; // table not migrated yet — behave as before
  }
  for (const row of results) {
    const hit = parseCache.get(row.class_id);
    let parsed = hit && hit.updated_at === row.updated_at ? hit.parsed : null;
    if (!parsed) {
      parsed = parseClassMarkdown(row.markdown);
      parseCache.set(row.class_id, { updated_at: row.updated_at, parsed });
    }
    if (parsed.ok) classes.push({ ...parsed.data, _source: 'imported', _retired: !!row.deleted_at });
    else failures.push({ file: `${row.class_id} (imported)`, errors: parsed.errors });
  }

  return { classes, failures };
}


