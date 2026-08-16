// One HTTP helper for all five pages.
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
  async function api(path, opts) {
    const res = await fetch('/api/character-creator/' + path, opts);
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
