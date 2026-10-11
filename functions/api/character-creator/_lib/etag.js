// A JSON answer that revalidates: stored by the browser, checked on every
// load, and answered with an empty 304 when nothing has changed.
//
// The validator is a hash of the BODY. The catalog tables carry no reliable
// "last changed" to key on - rows are written by data scripts, by the editor
// and by merges - so the only honest statement of "this is the same answer"
// is that it is the same bytes. `classes.js` is the one route that keys on
// table state instead, because it can answer before building its body, and
// it does not use this.
//
// `label` goes into the tag so two routes whose bodies happen to hash alike
// cannot 304 into each other: an empty catalog on a fresh database is exactly
// that case. Four routes ended in these same eight lines until 2026-10-10,
// and the tags they produce are unchanged, so a browser holding one still
// revalidates against it.
//
// `private`: every answer here sits behind Access and is one user's view.
// `no-cache` means "store, but ask first", not "do not store".
export async function jsonWithEtag(request, body, label) {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(body));
  const hex = [...new Uint8Array(digest, 0, 8)].map((b) => b.toString(16).padStart(2, '0')).join('');
  const etag = `W/"${label}-${hex}"`;
  const headers = { ETag: etag, 'Cache-Control': 'private, no-cache' };
  if (request.headers.get('If-None-Match') === etag) {
    return new Response(null, { status: 304, headers });
  }
  return new Response(body, { headers: { 'Content-Type': 'application/json', ...headers } });
}
