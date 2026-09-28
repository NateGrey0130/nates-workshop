// GET /api/marvel-heroes/campaigns/:id/search?q= - full-text search over the
// campaign's notes (msh_journal_fts), ranked, with a snippet. Members only.
// Free and instant: this runs as someone types; ask.js is the paid button.
//
// The snippet marks a match with U+0001 and U+0002 rather than <mark>, because
// the text around it is a note someone typed: the view escapes it first and
// only then turns those two characters into tags (shared/js/campaign/notes.js).

import { requireMember, json } from '../../_lib/campaigns.js';
import { toMatchQuery } from '../../_lib/notes.js';

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const match = toMatchQuery(new URL(request.url).searchParams.get('q'));
  if (!match) return json({ entries: [], total: 0, query: null });
  const { results } = await env.DB_MARVEL.prepare(`
    SELECT j.id, j.title, j.author_email, j.session_date, j.created_at, j.hero_id,
      snippet(msh_journal_fts, 1, char(1), char(2), '...', 24) AS snippet
    FROM msh_journal_fts JOIN msh_journal_entries j ON j.id = msh_journal_fts.rowid
    WHERE j.campaign_id = ? AND msh_journal_fts MATCH ?
    ORDER BY bm25(msh_journal_fts), j.created_at DESC LIMIT 50`).bind(g.campaign.id, match).all();
  return json({ entries: results, total: results.length, query: match });
}
