// One HTTP helper for all six pages.
//
// A classic script, like derive.js and picker.js, so the module pages (the
// wizard, the catalog editor) and the plain ones (sheet, dashboard, import) can
// share it. Exposes `api` and `errorDetails`.
//
// There were five copies of this, in three variants. That is a nuisance while
// they agree and a bug when they do not: the wizard and the sheet learned to
// carry a failed response's `violations` through to the reader, and the catalog
// editor and the importer kept throwing that half away — so the same 422 said
// which rule broke on one page and "Request failed (422)" on another.
//
// `jsonReq` is deliberately NOT here. The sheet's takes (method, body) and the
// importer's takes (body) and posts; unifying them would change call sites in
// both for no gain.

(function (global) {
  // A read that has not answered in this long is not going to. Reads only: a
  // write may be a question put to Claude, which takes as long as it takes.
  const GET_TIMEOUT_MS = 30000;

  async function api(path, opts) {
    const o = opts || {};
    const isGet = !o.method || String(o.method).toUpperCase() === 'GET';
    const once = async () => {
      if (!isGet || o.signal || typeof AbortController !== 'function') {
        return fetch('/api/character-creator/' + path, opts);
      }
      const ctl = new AbortController();
      const timer = setTimeout(() => ctl.abort(), GET_TIMEOUT_MS);
      try { return await fetch('/api/character-creator/' + path, { ...o, signal: ctl.signal }); }
      finally { clearTimeout(timer); }
    };
    let res;
    try { res = await once(); }
    catch (err) {
      // One more try for a read: a phone waking up, a dropped packet. Never
      // for a write, which may have landed before the connection went.
      if (!isGet) throw err;
      res = await once();
    }
    // A PAGE WHERE DATA WAS EXPECTED. Pages answers an unrouted path with the
    // site's index.html and a 200, and an expired Access session answers with
    // its sign-in page. Parsed as JSON both became `{}` - a success carrying
    // nothing - and the caller went on to read fields off it. It is thrown
    // WITHOUT a status, the shape of a request that never arrived, so the
    // sheet's queue keeps the change rather than rolling it back.
    const type = res.headers && typeof res.headers.get === 'function' ? (res.headers.get('content-type') || '') : 'json';
    if (res.ok && res.status !== 204 && !/json/i.test(type)) {
      const err = new Error('The server sent a page instead of data. You may need to sign in again: reload the page.');
      err.notData = true;
      throw err;
    }
    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
      // The body carries more than a sentence. `violations` says which class
      // rule broke and why, `errors` which fields failed to parse, `conflicts`
      // which rows an import could not apply. Throwing only the summary meant
      // "This character breaks its class rules" with no way to find out which.
      const err = new Error(data.error || ('API ' + res.status));
      err.status = res.status;
      err.detail = data;
      throw err;
    }
    return data;
  }

  // The readable half of a failed request, as a list. Empty when the failure
  // carried no structured detail, so callers can fall back to the message.
  function errorDetails(err) {
    const d = err?.detail || {};
    return [
      ...(d.violations || []).map((v) => v.message || `${v.rule}: ${JSON.stringify(v)}`),
      ...(d.errors || []),
      ...(d.conflicts || []).map((c) => `${c.name}: ${c.reason}`),
    ].filter(Boolean);
  }

  global.api = api;
  global.errorDetails = errorDetails;
})(globalThis);
