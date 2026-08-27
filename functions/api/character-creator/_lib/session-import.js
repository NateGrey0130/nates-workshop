// The session-based import endpoints, minus the catalog.
//
// Spells and psionic powers do exactly the same thing: take a page range into
// an open session, stage what comes back, then apply the reviewed batch. The
// only differences are which catalog is being written and which prompt is used,
// so both live here and the endpoints under import/<catalog>/ are three lines
// each. Gear will be the third.

import { requireAdmin, json, readJson } from './auth.js';
import {
  getImportSpec, extractRows, normaliseRows, classifyRows, countRows,
  applyDecisions, MAX_DECISIONS, DEFAULT_MODEL, ALLOWED_MODELS,
} from './import-engine.js';
import { CATALOGS } from '../../../../apps/character-creator/js/catalog-fields.js';
import { getSession, stageRows, getStaged, markConfirmed } from './import-sessions.js';
import { composeSourceBook } from './source-book.js';

const ACTIONS = ['insert', 'update', 'ignore'];

// Shared preamble: admin, valid body, and a session that is open and belongs to
// this catalog. Returns { res } to bail, or { b, session }.
async function openSessionFor(request, env, catalogKey, { requirePdf }) {
  const guard = requireAdmin(request, env);
  if (guard.res) return { res: guard.res };

  const b = await readJson(request);
  if (!b) return { res: json({ error: 'Body must be JSON' }, 400) };
  if (requirePdf && !b.pdf_base64) return { res: json({ error: 'pdf_base64 is required' }, 400) };

  const sessionId = parseInt(b.session_id, 10);
  if (!Number.isFinite(sessionId)) return { res: json({ error: 'session_id is required' }, 400) };

  const session = await getSession(env, sessionId);
  if (!session) return { res: json({ error: 'No session with that id' }, 404) };
  if (session.catalog !== catalogKey) {
    return { res: json({ error: `That session is not a ${catalogKey} import` }, 400) };
  }
  // The guard's email travels with the session so the extraction can be
  // metered against whoever spent the key. Both handlers below take it.
  return { b, session, sessionId, email: guard.email };
}

// One page range into a session. Writes to the staging tables, never to the
// catalog itself — nothing lands until it has been reviewed and confirmed.
export async function handleSessionExtract(request, env, catalogKey, prompt, promptArgs = () => ({})) {
  const ctx = await openSessionFor(request, env, catalogKey, { requirePdf: true });
  if (ctx.res) return ctx.res;
  const { b, session, sessionId, email } = ctx;
  if (session.closed_at) return json({ error: 'That session is closed' }, 409);

  const model = ALLOWED_MODELS.includes(b.model) ? b.model : DEFAULT_MODEL;
  const spec = getImportSpec(catalogKey);

  const result = await extractRows(env, spec, {
    pdfBase64: b.pdf_base64,
    model,
    systemPrompt: prompt.SYSTEM_PROMPT,
    userPrompt: prompt.buildUserPrompt({ sourceBook: session.source_book, hints: b.hints, ...promptArgs(b) }),
    email,
  });
  if (result.error) return json({ error: result.error, ...(result.extra || {}) }, result.status);

  const rows = normaliseRows(spec, result.rows);
  if (!rows.length) return json({ error: 'Nothing found on those pages', staged: 0, usage: result.usage });

  const classified = await classifyRows(env, spec, rows);
  // Re-submitting a range you already did is a normal mistake on a long import,
  // so names already staged in this session are skipped rather than duplicated.
  const { staged, skipped, error } = await stageRows(env, sessionId, b.page_range ?? null, classified, catalogKey);
  if (error) return json({ error }, 400);

  return json({
    ok: true,
    staged,
    skipped,
    counts: countRows(classified),
    flagged: classified.filter((r) => r.flags?.length).length,
    pending: (await getStaged(env, sessionId)).length,
    usage: result.usage,
    model,
  });
}

// Apply a session's pending rows as one batch. `overrides` carries whatever the
// reviewer changed, keyed on staged row id, so the UI sends its decisions once
// rather than writing one per click.
export async function handleSessionConfirm(request, env, catalogKey) {
  const ctx = await openSessionFor(request, env, catalogKey, { requirePdf: false });
  if (ctx.res) return ctx.res;
  const { b, session, sessionId } = ctx;

  const pending = await getStaged(env, sessionId, { pendingOnly: true });
  if (!pending.length) return json({ error: 'Nothing pending in that session' }, 400);
  if (pending.length > MAX_DECISIONS) {
    return json({ error: `Too many staged rows to confirm at once (max ${MAX_DECISIONS}). Confirm in smaller batches.` }, 400);
  }

  const overrides = new Map();
  for (const o of Array.isArray(b.overrides) ? b.overrides : []) {
    const id = parseInt(o?.id, 10);
    if (!Number.isFinite(id)) continue;
    if (o.action && !ACTIONS.includes(o.action)) return json({ error: `Unknown action: ${o.action}` }, 400);
    overrides.set(id, o);
  }

  const key = CATALOGS[getImportSpec(catalogKey).catalog].uniqueField;

  const decisions = pending.map((row) => {
    const o = overrides.get(row.id) || {};
    const action = o.action || row.action;
    const asName = o.resolved_name ?? row.resolved_name ?? null;
    // Strip the staging bookkeeping; what is left is the extracted row.
    const { id, page_range, match_name, is_stub, differs, confirmed_at, status,
            resolved_name, flags, action: _a, ...payload } = row;
    // An update has to target the row that was actually matched. Gear can match
    // on name when the slug derived from the book's wording differs from the
    // stub's, and in that case the payload's own key would point at nothing.
    const target = action === 'update' && match_name ? { [key]: match_name } : {};
    // The page range staging has recorded all along, finally attached to the
    // row it describes. PER ROW, not per session: one session covers many
    // ranges, and the range is the only thing that makes a row traceable back
    // to a printed page. No catalog has `source_book` among its extractFields,
    // so this cannot collide with anything the extraction produced.
    const source_book = composeSourceBook(session.source_book, page_range);
    // "Keep both" is an insert under a distinguishing name; the key column is
    // UNIQUE, so without one it would simply collide.
    return { ...payload, ...target, action, source_book,
             ...(action === 'insert' && asName ? { as_name: asName } : {}) };
  });

  const result = await applyDecisions(env, getImportSpec(catalogKey), decisions, {
    // The batch default is the same book with no pages — what a row whose
    // range nobody typed should still carry. Every decision above overrides
    // it with its own.
    sourceBook: composeSourceBook(session.source_book, null),
    // Which game system this book is for, chosen once when the session was
    // opened. Every row confirmed out of it inherits that; NULL stays
    // unrestricted rather than being guessed at.
    system: session.system,
  });
  if (result.error) return json({ error: result.error }, result.status);

  // Only rows that actually landed are marked done. A row reported as a
  // conflict stays pending so it can be renamed and retried rather than being
  // silently lost.
  // Conflicts are reported under the key column, which is `slug` for gear and
  // `name` for the rest — so the comparison has to use the same field the
  // decision did, not the display name.
  const conflicted = new Set(result.conflicts.map((c) => String(c.name).toLowerCase()));
  const done = pending
    .filter((row) => {
      const o = overrides.get(row.id) || {};
      const action = o.action || row.action;
      const target = action === 'update'
        ? (row.match_name ?? row[key])
        : (o.resolved_name ?? row.resolved_name ?? row[key]);
      return !conflicted.has(String(target ?? '').toLowerCase());
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
