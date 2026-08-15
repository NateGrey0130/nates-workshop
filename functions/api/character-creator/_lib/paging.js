// Limit/offset paging for the lists that grow with play.
//
// Deliberately not applied to the catalog loads. The wizard boots by fetching
// classes, catalogs and items in full and renders a picker from each, so a
// truncated response there would silently hide valid choices rather than
// showing fewer rows — a worse failure than an unbounded response. Those
// catalogs are bounded by book content; characters and campaigns are not.
//
// Responses keep their existing top-level key and gain the metadata alongside
// it, so no caller has to change to keep working.

const DEFAULT_LIMIT = 200;
const MAX_LIMIT = 500;

export function paging(request, { defaultLimit = DEFAULT_LIMIT, maxLimit = MAX_LIMIT } = {}) {
  const p = new URL(request.url).searchParams;
  const rawLimit = parseInt(p.get('limit'), 10);
  const rawOffset = parseInt(p.get('offset'), 10);
  // A nonsensical value falls back to the default rather than erroring — a
  // list endpoint returning 400 because of a stray query string is worse than
  // it returning the first page.
  const limit = Number.isFinite(rawLimit) && rawLimit > 0 ? Math.min(rawLimit, maxLimit) : defaultLimit;
  const offset = Number.isFinite(rawOffset) && rawOffset > 0 ? rawOffset : 0;
  return { limit, offset };
}

// Runs the count and the page as one round trip. `countSql` must select a
// single column named `n`.
export async function pagedQuery(env, { countSql, countBinds = [], rowsSql, rowsBinds = [], limit, offset }) {
  const [countRes, rowsRes] = await env.DB.batch([
    env.DB.prepare(countSql).bind(...countBinds),
    env.DB.prepare(`${rowsSql} LIMIT ? OFFSET ?`).bind(...rowsBinds, limit, offset),
  ]);
  return {
    results: rowsRes.results ?? [],
    total: countRes.results?.[0]?.n ?? 0,
    limit,
    offset,
  };
}
