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
//
// `timeoutMs` is optional and only the isbn branch passes one. A hung upstream
// used to surface as whatever the runtime threw — an opaque 502 reading
// `fetch failed`, or nothing at all until the platform gave up — which reads to
// the user as "the book is not there". A bounded call can say which it was.
async function fetchJson(url, timeoutMs) {
  let res;
  try {
    res = await fetch(url, timeoutMs ? { signal: AbortSignal.timeout(timeoutMs) } : undefined);
  } catch (err) {
    if (timeoutMs && (err.name === 'TimeoutError' || err.name === 'AbortError')) {
      const who = url.startsWith(OL_BASE) ? 'OpenLibrary' : 'The metadata service';
      throw new Error(`${who} didn’t answer within ${Math.round(timeoutMs / 1000)} seconds. That is their end being slow, not the book being missing — try again in a moment.`);
    }
    throw err;
  }
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

// OpenLibrary's `jscmd=data` view returns covers per EDITION, and print-on-
// demand and reissue editions routinely carry none even when the WORK has
// several — so a lookup that found the right book still saved it coverless.
// This is the second-chance query, and it fires only on that path: the common
// case stays one request.
//
// search.json is a poor way to FIND a book — it returned 24 results for an
// invented ISBN — but that is not what it does here. The edition is already
// resolved; this only asks OpenLibrary for a cover id belonging to it, and a
// wrong answer costs a wrong thumbnail rather than a wrong book.
//
// THE TIMEOUT IS THE POINT, and it was not optional. Written without one, this
// took OpenLibrary 21 SECONDS to answer for the first ISBN it was tried on and
// took the whole lookup down with it — a request that used to return a book in
// under a second returned a 502 instead. search.json is a query, not a key
// lookup, and it is minutes-to-milliseconds unpredictable. So it gets two and a
// half seconds and not a moment more: the book has already been found by the
// time this runs, and no cover is worth losing it over. Every failure returns
// an empty string rather than throwing, for the same reason.
const COVER_FALLBACK_MS = 2500;

async function olWorkCover(isbn) {
  try {
    const res = await fetch(`${OL_BASE}/search.json?isbn=${isbn}&limit=1&fields=cover_i`,
      { signal: AbortSignal.timeout(COVER_FALLBACK_MS) });
    if (!res.ok) return '';
    const data = await res.json();
    const id = data.docs && data.docs[0] && data.docs[0].cover_i;
    return olCover(id, 'L');
  } catch {
    return '';
  }
}

// ─── The second opinion ───
// `/api/books` answers 200 with an empty body while it is struggling, and an
// empty body is byte-for-byte what it returns for an ISBN nobody has catalogued.
// So the one thing this endpoint most needs to tell apart — "we don't have that
// book" from "we couldn't answer just now" — it could not tell apart at all,
// and the user got "No results found for that ISBN" either way. That sentence,
// for a book that plainly exists, is the symptom this whole audit started from.
//
// Measured 2026-08-26 against `043935806X`, a book OpenLibrary certainly holds:
// of 12 sequential direct requests, 2 hard-failed and one took 8.5s; through
// the proxy, one of 14 came back 502 after 21 SECONDS. And during a paste-add
// run the same ISBN returned a clean `found: false` — seconds after, and
// seconds before, resolving perfectly.
//
// One retry, and not two. The budgets below are the reason: the primary call
// gets ten seconds because a real answer was measured at 8.5, the retry gets
// five because by the time it runs we already hold a usable answer and are only
// hoping to improve it. Worst case is 10 + 0.4 + 5 ≈ 15.4s, which is under the
// 21s this endpoint was already capable of taking before any of this. A second
// retry would put it back over.
//
// Every failure here returns null, which lands on exactly the `found: false`
// the code returned before. A retry may only turn a "no" into a "yes"; it must
// never turn a good answer into an error.
const ISBN_LOOKUP_MS = 10000;
const ISBN_RETRY_DELAY_MS = 400;
const ISBN_RETRY_MS = 5000;

async function olSecondOpinion(url, bibkey) {
  try {
    await new Promise((resolve) => setTimeout(resolve, ISBN_RETRY_DELAY_MS));
    const res = await fetch(url, { signal: AbortSignal.timeout(ISBN_RETRY_MS) });
    if (!res.ok) return null;
    const data = await res.json();
    return data[bibkey] || null;
  } catch {
    return null;
  }
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
        const bibkey = `ISBN:${isbn}`;
        const url = `${OL_BASE}/api/books?bibkeys=${bibkey}&format=json&jscmd=data`;
        const data = await fetchJson(url, ISBN_LOOKUP_MS);
        // An empty answer is asked once more before it is believed — see
        // olSecondOpinion above for why, and for why only once.
        const book = data[bibkey] || await olSecondOpinion(url, bibkey);
        if (!book) return json({ found: false });
        const editionCover = book.cover
          ? (book.cover.large || book.cover.medium || book.cover.small || '')
          : '';
        return json({
          found: true,
          book: {
            title: book.title || '',
            authors: (book.authors || []).map((a) => a.name).join(', '),
            genre: (book.subjects || []).slice(0, 3).map((s) => s.name).join(', '),
            cover: editionCover || await olWorkCover(isbn),
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
