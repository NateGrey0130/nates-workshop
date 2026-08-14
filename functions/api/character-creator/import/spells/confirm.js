// POST /api/character-creator/import/spells/confirm — admin only.
// Body: { session_id, overrides?: [{ id, action, resolved_name? }] }
//
// Applies the session's pending staged rows to the spells catalog as one batch.
// Each staged row already carries a suggested action from classification;
// `overrides` carries whatever the reviewer changed, keyed on staged row id, so
// the UI sends its decisions once rather than writing one per click.
//
// The session stays open afterwards, so more page ranges can follow.

import { requireAdmin, json, readJson } from '../../_lib/auth.js';
import { getImportSpec, applyDecisions, MAX_DECISIONS } from '../../_lib/import-engine.js';
import { getSession, getStaged, markConfirmed } from '../../_lib/import-sessions.js';

const ACTIONS = ['insert', 'update', 'ignore'];

export async function onRequestPost({ request, env }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Body must be JSON' }, 400);

  const sessionId = parseInt(b.session_id, 10);
  if (!Number.isFinite(sessionId)) return json({ error: 'session_id is required' }, 400);
  const session = await getSession(env, sessionId);
  if (!session) return json({ error: 'No session with that id' }, 404);
  if (session.catalog !== 'spells') return json({ error: 'That session is not a spell import' }, 400);

  const pending = await getStaged(env, sessionId, { pendingOnly: true });
  if (!pending.length) return json({ error: 'Nothing pending in that session' }, 400);
  if (pending.length > MAX_DECISIONS) {
    return json({ error: `Too many staged rows to confirm at once (max ${MAX_DECISIONS}). Confirm in smaller batches.` }, 400);
  }

  const overrides = new Map();
  for (const o of Array.isArray(b.overrides) ? b.overrides : []) {
    const id = parseInt(o?.id, 10);
    if (!Number.isFinite(id)) continue;
    if (o.action && !ACTIONS.includes(o.action)) {
      return json({ error: `Unknown action: ${o.action}` }, 400);
    }
    overrides.set(id, o);
  }

  const decisions = pending.map((row) => {
    const o = overrides.get(row.id) || {};
    const action = o.action || row.action;
    const asName = o.resolved_name ?? row.resolved_name ?? null;
    // "Keep both" is an insert under a distinguishing name; the key column is
    // UNIQUE, so without one it would simply collide.
    const { id, page_range, match_name, is_stub, differs, confirmed_at, status, resolved_name, action: _a, ...payload } = row;
    return { ...payload, action, ...(action === 'insert' && asName ? { as_name: asName } : {}) };
  });

  const result = await applyDecisions(env, getImportSpec('spells'), decisions, {
    sourceBook: session.source_book,
  });
  if (result.error) return json({ error: result.error }, result.status);

  // Only rows that actually landed are marked done. A row reported as a
  // conflict stays pending so it can be renamed and retried rather than being
  // silently lost.
  const conflicted = new Set(result.conflicts.map((c) => String(c.name).toLowerCase()));
  const done = pending
    .filter((row) => {
      const o = overrides.get(row.id) || {};
      const target = String(o.resolved_name ?? row.resolved_name ?? row.name ?? '').toLowerCase();
      return !conflicted.has(target);
    })
    .map((row) => row.id);
  await markConfirmed(env, done);

  return json({
    ...result,
    session_id: sessionId,
    confirmed: done.length,
    still_pending: (await getStaged(env, sessionId)).length,
  });
}
