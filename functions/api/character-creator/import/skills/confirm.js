// POST /api/character-creator/import/skills/confirm — admin only.
// Body: { source_book?, page_range?, decisions: [{ action, name, category, base, per_level, note, as_name? }] }
//
// action is one of:
//   insert  — add as a new catalog row (also used for "keep both", where the
//             caller supplies a distinguished as_name, since name is UNIQUE)
//   update  — overwrite the existing row's numbers
//   ignore  — do nothing
//
// Everything is applied in one batch so a partial import can't happen. The
// batching lives in _lib/import-engine.js.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';
import { getImportSpec, applyDecisions, MAX_DECISIONS } from '../../_lib/import-engine.js';
import { composeSourceBook } from '../../_lib/source-book.js';

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  if (!Array.isArray(b.decisions)) return json({ error: 'decisions must be an array' }, 400);
  if (b.decisions.length > MAX_DECISIONS) {
    return json({ error: `Too many decisions in one import (max ${MAX_DECISIONS})` }, 400);
  }

  // Composed once for the whole batch, not per row. Unlike the session
  // importers this one has no staging table to hang a per-range value on, and
  // a skill chapter is uploaded a few pages at a time anyway — so the batch IS
  // the range.
  //
  // Same composer the session importers use: the book resolves through
  // scripts/books.json and the page label is normalised, so a chapter typed as
  // `pp. 26-34` lands as `Rifts Ultimate Edition p.26-34` rather than as
  // something `parseSourcePages` cannot read.
  //
  // This importer never collected a page range at all until now, which is the
  // whole reason 105 of 333 skills carry a book and no page.
  const sourceBook = composeSourceBook(b.source_book, b.page_range ?? null);

  const result = await applyDecisions(env, getImportSpec('skills'), b.decisions, { sourceBook });
  if (result.error) return json({ error: result.error }, result.status);

  return json(result);
}
