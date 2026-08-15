// Resumable catalog imports.
//
// A skill chapter finishes in one sitting. A spell chapter is hundreds of
// entries across many pages and does not, so extracted rows are staged in the
// database rather than held in a browser tab: submit a page range, come back
// next week, carry on.
//
// The extraction is the expensive part, so it is what gets persisted — the
// instant a range parses, it is saved with a suggested action per row. Review
// clicks are sent with the confirm rather than written one at a time.
//
// Catalog-agnostic: psionics and gear reuse this untouched.

import { CATALOGS } from '../../../../apps/character-creator/js/catalog-fields.js';
import { safeParse } from './character-json.js';

// A page range that produces more rows than this is almost certainly a range
// that is too wide to have been read reliably, so it is refused rather than
// staged. Keeps the single staging batch a sane size too.
const MAX_ROWS_PER_RANGE = 300;

export async function createSession(env, { catalog, name, sourceBook, email }) {
  const res = await env.DB.prepare(
    `INSERT INTO import_sessions (catalog, name, source_book, created_by) VALUES (?, ?, ?, ?)`
  ).bind(catalog, name, sourceBook ?? null, email).run();
  return res.meta?.last_row_id ?? null;
}

// Open sessions plus, for each, how much is staged and how much is already
// applied — enough for the list to be useful without a second request per row.
export async function listSessions(env, { catalog, includeClosed = false }) {
  const { results } = await env.DB.prepare(
    `SELECT s.*,
            (SELECT count(*) FROM import_staged t WHERE t.session_id = s.id) AS staged_count,
            (SELECT count(*) FROM import_staged t WHERE t.session_id = s.id AND t.confirmed_at IS NOT NULL) AS confirmed_count
     FROM import_sessions s
     WHERE s.catalog = ?${includeClosed ? '' : ' AND s.closed_at IS NULL'}
     ORDER BY s.created_at DESC`
  ).bind(catalog).all();
  return results;
}

export async function getSession(env, id) {
  return env.DB.prepare('SELECT * FROM import_sessions WHERE id = ?').bind(id).first();
}

export async function closeSession(env, id) {
  const res = await env.DB.prepare(
    `UPDATE import_sessions SET closed_at = datetime('now') WHERE id = ? AND closed_at IS NULL`
  ).bind(id).run();
  return res.meta?.changes ?? 0;
}

// Persist a freshly extracted and classified page range.
//
// Rows already staged in this session under the same name are skipped rather
// than duplicated — re-submitting a page range you already did is a normal
// mistake on a long import, and it should not silently double every entry.
export async function stageRows(env, sessionId, pageRange, classified, catalogKey) {
  const key = CATALOGS[catalogKey].uniqueField;
  if (classified.length > MAX_ROWS_PER_RANGE) {
    return { error: `That range produced ${classified.length} rows, more than the ${MAX_ROWS_PER_RANGE} allowed in one go. Narrow the page range.` };
  }

  const { results: already } = await env.DB.prepare(
    'SELECT payload FROM import_staged WHERE session_id = ?'
  ).bind(sessionId).all();
  const seen = new Set(already.map((r) => {
    return String(safeParse(r.payload, {})[key] ?? '').toLowerCase();
  }));

  const fresh = [];
  for (const row of classified) {
    const name = String(row[key] ?? '').toLowerCase();
    if (!name || seen.has(name)) continue;
    seen.add(name);
    fresh.push(row);
  }

  const statements = fresh.map((row) => {
    const { status, existing, differs, is_stub, suggested, ...payload } = row;
    return env.DB.prepare(
      `INSERT INTO import_staged (session_id, page_range, payload, match_name, is_stub, differs, action, resolved_name)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
    ).bind(
      sessionId, pageRange ?? null, JSON.stringify(payload),
      existing ? String(existing[key]) : null,
      is_stub ? 1 : 0,
      differs ? 1 : 0,
      status === 'new' ? 'insert' : (suggested || 'ignore'),
      null,
    );
  });

  // One batch, so staging a page range is all-or-nothing like confirming one.
  // This used to be chunked, which meant a failure partway left the earlier
  // chunks written while the endpoint reported the extraction as failed —
  // the caller would then re-submit and get a confusing partial count back.
  if (statements.length) await env.DB.batch(statements);
  return { staged: fresh.length, skipped: classified.length - fresh.length };
}

export async function getStaged(env, sessionId, { pendingOnly = true } = {}) {
  const { results } = await env.DB.prepare(
    `SELECT * FROM import_staged
     WHERE session_id = ?${pendingOnly ? ' AND confirmed_at IS NULL' : ''}
     ORDER BY id`
  ).bind(sessionId).all();
  return results.map((r) => {
    // A corrupt row shows as empty rather than breaking the whole review.
    const payload = safeParse(r.payload, {});
    return {
      id: r.id,
      page_range: r.page_range,
      match_name: r.match_name,
      is_stub: !!r.is_stub,
      differs: !!r.differs,
      action: r.action,
      resolved_name: r.resolved_name,
      confirmed_at: r.confirmed_at,
      status: r.match_name ? 'duplicate' : 'new',
      ...payload,
    };
  });
}

export async function markConfirmed(env, ids) {
  if (!ids.length) return 0;
  const res = await env.DB.prepare(
    `UPDATE import_staged SET confirmed_at = datetime('now')
     WHERE id IN (${ids.map(() => '?').join(',')})`
  ).bind(...ids).run();
  return res.meta?.changes ?? 0;
}
