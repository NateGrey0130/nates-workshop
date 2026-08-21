// GET /api/character-creator/campaigns/:id/search?q=… — full-text search over
//     the campaign's journal, newest-first within relevance. Members only.
//     ?author= and ?since= narrow it further; ?limit= and ?offset= page.
//
// Free and instant, which is the point: this is what runs as you type, and the
// paid `ask` endpoint beside it is what runs when someone presses a button.

import { json, requireCampaign } from '../../_lib/auth.js';
import { paging, pagedQuery, pageBody } from '../../_lib/paging.js';

// FTS5 treats a bare apostrophe, hyphen or quote as syntax, so a query typed by
// a human at the table — `the baron's men` — is a syntax error rather than a
// search. Every run of word characters becomes one quoted term instead, which
// is both injection-proof and what a person means by typing words in a box.
//
// A trailing * on the last term makes it a prefix match, so results narrow
// while someone is still typing the word.
//
// `join` is the difference between the two callers, and getting it wrong makes
// one of them silently useless:
//
//   AND — the search box. Every word must appear, so the list narrows as you
//         type, which is what a search box is for.
//   OR  — the ask endpoint. A QUESTION is not a set of required terms: "what
//         did the baron's men want, and do we still have the rune sword?"
//         AND-ed together matches no entry ever written, and the model is then
//         handed nothing and correctly answers that the notes do not say. OR
//         retrieves anything relevant and lets bm25 rank it, which is what the
//         LIMIT then takes the top of.
export function toMatchQuery(raw, { join = 'AND' } = {}) {
  const terms = String(raw || '').match(/[\p{L}\p{N}]+/gu);
  if (!terms || !terms.length) return null;
  return terms
    .map((t, i) => (join === 'AND' && i === terms.length - 1 ? `"${t}"*` : `"${t}"`))
    .join(` ${join} `);
}

export async function onRequestGet({ request, env, params }) {
  // Reads are member-gated here, unlike the rest of the app where reads are
  // open to any authenticated friend. A search box that returns another
  // table's session notes is a different thing from a character sheet being
  // readable.
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;

  const url = new URL(request.url);
  const match = toMatchQuery(url.searchParams.get('q'));
  if (!match) return json({ entries: [], total: 0, limit: 0, offset: 0, query: null });

  const author = url.searchParams.get('author');
  const since = url.searchParams.get('since');
  const { limit, offset } = paging(request, { defaultLimit: 25, maxLimit: 100 });

  const where = ['j.campaign_id = ?', 'journal_fts MATCH ?'];
  const binds = [params.id, match];
  if (author) { where.push('j.author_email = ?'); binds.push(author); }
  if (since) { where.push('j.created_at >= ?'); binds.push(since); }
  const clause = where.join(' AND ');

  // snippet() marks the matched words so the result list can show WHY a row
  // matched. bm25 ranks; the created_at tiebreak keeps two equally-relevant
  // entries in a stable, meaningful order rather than an arbitrary one.
  //
  // The delimiters are U+0001 and U+0002, not '<mark>'. The text around a match
  // is a note a person typed, so returning HTML here would mean building markup
  // out of user input - and a client that escaped the result would escape the
  // marks along with it. Two characters no keyboard produces survive escaping
  // and are swapped for tags after it. See HIGHLIGHT_START/END in campaign.js.
  const page = await pagedQuery(env, {
    countSql: `SELECT count(*) AS n FROM journal_fts
               JOIN journal_entries j ON j.id = journal_fts.rowid
               WHERE ${clause}`,
    countBinds: binds,
    rowsSql: `SELECT j.id, j.title, j.author_email, j.session_date, j.created_at, j.character_id,
                     snippet(journal_fts, 1, char(1), char(2), '…', 24) AS snippet
              FROM journal_fts
              JOIN journal_entries j ON j.id = journal_fts.rowid
              WHERE ${clause}
              ORDER BY bm25(journal_fts), j.created_at DESC`,
    rowsBinds: binds,
    limit, offset,
  });

  return json({ ...pageBody('entries', page), query: match });
}
