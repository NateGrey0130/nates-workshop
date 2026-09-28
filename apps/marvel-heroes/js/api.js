// The one fetch wrapper the Campaign and GM pages share. Every call answers
// { ok, status, data } and never throws on an HTTP error, so a page can show
// the server's own refusal ("already in an open campaign") instead of a
// generic one. A network failure answers status 0.

export const API = '/api/marvel-heroes';

export async function api(path, { method = 'GET', body } = {}) {
  const init = { method, headers: {} };
  if (body !== undefined) {
    init.headers['Content-Type'] = 'application/json';
    init.body = JSON.stringify(body);
  }
  let res;
  try { res = await fetch(`${API}/${path}`, init); } catch (e) {
    return { ok: false, status: 0, data: { error: `Could not reach the server: ${e.message}` } };
  }
  let data = {};
  try { data = await res.json(); } catch { /* an empty or non-JSON answer */ }
  return { ok: res.ok, status: res.status, data };
}

export const errorOf = (r) => r.data?.error || `The server answered ${r.status}`;
