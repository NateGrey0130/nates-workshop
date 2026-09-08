// GET  /api/character-creator/catalogs/duplicates?catalog=skills — suggested pairs
// POST /api/character-creator/catalogs/duplicates?catalog=skills — merge two rows
//        { keep_id, remove_id }
//
// POST …?catalog=skills&dismiss=1  — these two are NOT the same row
//        { key_a, key_b, note }
// POST …?catalog=skills&restore=1  — undo a dismissal
//        { key_a, key_b }
//
// Admin only. The importers dedupe on an exact name; this finds the pairs that
// match only after normalising punctuation and word order, which is where the
// real duplicates hide. Suggestions are never applied automatically.
//
// The POSTs are the two answers, and only one of them stores anything. YES is
// executed: `mergeRows` repoints, redirects and deletes the losing row, so the
// pair stops existing and there is nothing to remember. NO had nowhere to go
// until BOOK-INGEST-AUDIT F33 - every reader re-judged the same pairs from
// scratch, and on gear that is 589 of 591 suggestions in the loosest tier.
//
// The verb split follows `campaigns/[id]/npcs/sweep.js`, which had this shape
// first: one POST route, the action in a query flag, and a dismissals table
// consulted BEFORE anything is proposed.

import { requireAdmin, json, readJson } from '../_lib/auth.js';
import { findDuplicates, mergeRows, dismissPair, restorePair, resolveCatalog }
  from '../_lib/catalog-merge.js';

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, err } = resolveCatalog(request);
  if (err) return err;

  const pairs = await findDuplicates(env, key);
  const byTier = (t) => pairs.filter((p) => p.tier === t);

  // The catalog page asks for counts on every load so duplicates surface
  // without anyone going looking. It only needs the numbers, and the full
  // response carries both rows of every pair — 27 of them on a real catalog.
  if (new URL(request.url).searchParams.get('counts_only') === '1') {
    return json({
      catalog: key,
      count: pairs.length,
      tiers: { certain: byTier('certain').length, likely: byTier('likely').length, contains: byTier('contains').length },
    });
  }

  return json({
    catalog: key,
    pairs,
    count: pairs.length,
    // Grouped, because the tiers are not equally trustworthy: measured against
    // a real 138-row catalog, `certain` and `likely` had no false positives
    // while `contains` was right roughly 40% of the time.
    tiers: {
      certain: byTier('certain'),
      likely: byTier('likely'),
      contains: byTier('contains'),
    },
  });
}

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, err } = resolveCatalog(request);
  if (err) return err;

  const flags = new URL(request.url).searchParams;
  if (flags.get('dismiss') === '1') {
    const b = await readJson(request);
    const r = await dismissPair(env, key, b?.key_a, b?.key_b, b?.note, guard.email);
    return r.error ? json({ error: r.error }, r.status) : json(r);
  }
  if (flags.get('restore') === '1') {
    const b = await readJson(request);
    const r = await restorePair(env, key, b?.key_a, b?.key_b);
    return r.error ? json({ error: r.error }, r.status) : json(r);
  }

  const b = await readJson(request);
  const keepId = parseInt(b?.keep_id, 10);
  const removeId = parseInt(b?.remove_id, 10);
  if (!Number.isFinite(keepId) || !Number.isFinite(removeId)) {
    return json({ error: 'keep_id and remove_id are required' }, 400);
  }

  const result = await mergeRows(env, key, keepId, removeId);
  if (result.error) return json({ error: result.error }, result.status);
  return json(result);
}
