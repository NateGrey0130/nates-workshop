// GET  /api/character-creator/catalogs/duplicates?catalog=skills — suggested pairs
// POST /api/character-creator/catalogs/duplicates?catalog=skills — merge two rows
//        { keep_id, remove_id }
//
// Admin only. The importers dedupe on an exact name; this finds the pairs that
// match only after normalising punctuation and word order, which is where the
// real duplicates hide. Suggestions are never applied automatically.

import { requireAdmin, json, readJson } from '../_lib/auth.js';
import { getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';
import { findDuplicates, mergeRows, MERGE_REFS } from '../_lib/catalog-merge.js';

function resolve(request) {
  const key = new URL(request.url).searchParams.get('catalog');
  if (!getCatalog(key) || !MERGE_REFS[key]) return { err: json({ error: 'Unknown catalog' }, 400) };
  return { key };
}

export async function onRequestGet({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const { key, err } = resolve(request);
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

  const { key, err } = resolve(request);
  if (err) return err;

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
