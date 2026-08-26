// GET /api/media-vault/lookup — MediaVault's metadata lookups, proxied so the
// browser never talks to a third party and the TMDB key lives in the
// TMDB_API_KEY Pages secret instead of the client JS it used to be hardcoded
// in. Cover/poster IMAGES are still hotlinked by the browser — this proxies
// the metadata queries, which are what carried the key.
//
// Modes (?mode=):
//   isbn          &isbn=...                        (OpenLibrary)
//   book-title    &q=... [&year=...]               (OpenLibrary)
//   book-author   &q=... [&year=...]               (OpenLibrary, author → works)
//   video-title   &q=... &kind=movie|tv [&year=..] (TMDB)
//   video-person  &q=... &kind=movie|tv &role=actor|director (TMDB)
//   video-detail  &id=... &kind=movie|tv           (TMDB, with credits)
//
// Responses carry only what the client renders — raw third-party payloads are
// never relayed. TMDB modes fail with a clear 503 when the secret is missing.

import { getUserEmail, json, normalizeIsbn, isIsbnShape } from './_lib/common.js';

const TMDB_BASE = 'https://api.themoviedb.org/3';
const TMDB_IMG = 'https://image.tmdb.org/t/p/w92';
const TMDB_IMG_LG = 'https://image.tmdb.org/t/p/w500';
const OL_BASE = 'https://openlibrary.org';
const MAX_QUERY_LEN = 300;

// A rejected TMDB key is reported by name rather than as a bare status: the
// first time production rejected a key, all this said was
// "Upstream error 401", which named neither TMDB nor the secret to fix.
async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) {
    if (url.startsWith(TMDB_BASE) && (res.status === 401 || res.status === 403)) {
      throw new Error('TMDB rejected the API key — check the TMDB_API_KEY secret on the Pages project. It must be TMDB’s 32-character v3 API key, not a v4 read access token.');
    }
    throw new Error(`Upstream error ${res.status}`);
  }
  return res.json();
}

function olCover(coverId, size) {
  return coverId ? `https://covers.openlibrary.org/b/id/${coverId}-${size}.jpg` : '';
}

function bookOut(doc) {
  return {
    title: doc.title || 'Unknown Title',
    authors: (doc.author_name || []).join(', ') || 'Unknown Author',
    genre: (doc.subject || []).slice(0, 3).join(', '),
    year: doc.first_publish_year || '',
    cover: olCover(doc.cover_i, 'L'),
    thumb: olCover(doc.cover_i, 'S'),
  };
}

function tmdbSummaryOut(c, kind) {
  return {
    id: c.id,
    title: c.title || c.name || '',
    year: (c.release_date || c.first_air_date || '').slice(0, 4),
    poster: c.poster_path ? TMDB_IMG + c.poster_path : '',
    overview: (c.overview || '').slice(0, 200),
    kind,
  };
}

export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  const params = new URL(context.request.url).searchParams;
  const mode = params.get('mode') || '';
  const q = (params.get('q') || '').trim().slice(0, MAX_QUERY_LEN);
  const year = (params.get('year') || '').trim().slice(0, 4);
  const kind = params.get('kind') === 'tv' ? 'tv' : 'movie';

  const needsTmdb = mode.startsWith('video-');
  const tmdbKey = context.env.TMDB_API_KEY;
  if (needsTmdb && !tmdbKey) {
    return json({ error: 'Lookup unavailable: the TMDB_API_KEY secret is not configured' }, 503);
  }

  try {
    switch (mode) {
      case 'isbn': {
        const isbn = normalizeIsbn(params.get('isbn'));
        if (!isIsbnShape(isbn)) return json({ error: 'That isn’t a 10- or 13-digit ISBN' }, 400);
        const data = await fetchJson(`${OL_BASE}/api/books?bibkeys=ISBN:${isbn}&format=json&jscmd=data`);
        const book = data[`ISBN:${isbn}`];
        if (!book) return json({ found: false });
        return json({
          found: true,
          book: {
            title: book.title || '',
            authors: (book.authors || []).map((a) => a.name).join(', '),
            genre: (book.subjects || []).slice(0, 3).map((s) => s.name).join(', '),
            cover: book.cover ? (book.cover.large || book.cover.medium || book.cover.small || '') : '',
          },
        });
      }

      case 'book-title': {
        if (!q) return json({ error: 'Missing q' }, 400);
        let url = `${OL_BASE}/search.json?q=${encodeURIComponent(q)}&limit=15`;
        if (year) url += `&first_publish_year=${year}`;
        const data = await fetchJson(url);
        return json({ results: (data.docs || []).map(bookOut) });
      }

      case 'book-author': {
        if (!q) return json({ error: 'Missing q' }, 400);
        const authorData = await fetchJson(`${OL_BASE}/search/authors.json?q=${encodeURIComponent(q)}&limit=1`);
        const author = authorData.docs && authorData.docs[0];
        if (!author) return json({ results: [], authorName: null });
        const authorName = author.name || q;
        let worksUrl = `${OL_BASE}/search.json?author=${encodeURIComponent(authorName)}&limit=20&sort=editions`;
        if (year) worksUrl += `&first_publish_year=${year}`;
        const worksData = await fetchJson(worksUrl);
        return json({ authorName, results: (worksData.docs || []).map(bookOut) });
      }

      case 'video-title': {
        if (!q) return json({ error: 'Missing q' }, 400);
        let url = `${TMDB_BASE}/search/${kind === 'tv' ? 'tv' : 'movie'}?query=${encodeURIComponent(q)}&api_key=${tmdbKey}`;
        if (year) url += `&year=${year}`;
        const data = await fetchJson(url);
        return json({ results: (data.results || []).slice(0, 15).map((c) => tmdbSummaryOut(c, kind)) });
      }

      case 'video-person': {
        if (!q) return json({ error: 'Missing q' }, 400);
        const role = params.get('role') === 'director' ? 'director' : 'actor';
        const personData = await fetchJson(`${TMDB_BASE}/search/person?query=${encodeURIComponent(q)}&api_key=${tmdbKey}`);
        const person = personData.results && personData.results[0];
        if (!person) return json({ results: [], personName: null });
        const credData = await fetchJson(`${TMDB_BASE}/person/${person.id}/${kind}_credits?api_key=${tmdbKey}`);
        let credits = role === 'actor'
          ? credData.cast || []
          : (credData.crew || []).filter((c) => c.job === 'Director');
        const seen = new Set();
        const results = credits
          .filter((c) => { if (seen.has(c.id)) return false; seen.add(c.id); return true; })
          .sort((a, b) => (b.popularity || 0) - (a.popularity || 0))
          .slice(0, 20)
          .map((c) => tmdbSummaryOut(c, kind));
        return json({ personName: person.name, results });
      }

      case 'video-detail': {
        const id = params.get('id');
        if (!/^\d{1,12}$/.test(id || '')) return json({ error: 'Invalid id' }, 400);
        const data = await fetchJson(`${TMDB_BASE}/${kind}/${id}?api_key=${tmdbKey}&append_to_response=credits`);
        const crew = data.credits?.crew || [];
        return json({
          title: data.title || data.name || '',
          year: (data.release_date || data.first_air_date || '').slice(0, 4),
          genres: (data.genres || []).map((g) => g.name).join(', '),
          poster: data.poster_path ? TMDB_IMG_LG + data.poster_path : '',
          directors: crew.filter((c) => c.job === 'Director').map((c) => c.name).join(', '),
          actors: (data.credits?.cast || []).slice(0, 5).map((c) => c.name).join(', '),
          producers: crew.filter((c) => c.job === 'Producer' || c.job === 'Executive Producer').slice(0, 3).map((c) => c.name).join(', '),
          runtime: data.runtime || 0,
          seasons: data.number_of_seasons || 0,
          rating: data.vote_average || 0,
          overview: data.overview || '',
          kind,
        });
      }

      default:
        return json({ error: 'Unknown mode' }, 400);
    }
  } catch (err) {
    // No 'Lookup failed:' prefix here — every caller adds its own, and both
    // prefixes together read as "Lookup failed: Lookup failed: ...".
    return json({ error: err.message }, 502);
  }
}
