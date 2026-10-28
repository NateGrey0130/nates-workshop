// Reports the page's own uncaught errors to /api/client-error.
//
// Before this, an error thrown in a friend's browser reached nobody: no page
// had a window-level `error` or `unhandledrejection` listener, and there was
// no endpoint to send one to. The server writes each report as one
// console.error line, which `wrangler pages deployment tail` and the Pages
// real-time logs show. Nothing is stored in D1.
//
// A CLASSIC script, loaded before every other script on the page so that it
// is listening before their code runs. It defines no globals except the one
// test hook below.
//
// Three promises, each pinned by smoke (`Client error reporting`):
//   - at most MAX_REPORTS reports per page load, so a throw inside a
//     requestAnimationFrame loop cannot flood the endpoint;
//   - one report per distinct message, for the same reason;
//   - it never throws. A reporter that throws from inside an error handler
//     replaces the error it was reporting, and a fetch that rejects would
//     itself be an unhandled rejection. Every path is caught.
//
// The field caps here are a courtesy to the network. The server caps every
// field again, because a browser is not obliged to run this file.
(function (global) {
  var MAX_REPORTS = 5;
  var CAP = { message: 500, source: 500, stack: 2048, page: 500, ua: 300 };
  var sent = 0;
  var seen = {};

  function cut(value, max) {
    if (value === undefined || value === null) return '';
    var s;
    try { s = String(value); } catch (e) { s = ''; }
    return s.length > max ? s.slice(0, max) : s;
  }

  function whole(value) {
    var n = Number(value);
    return isFinite(n) && n >= 0 ? Math.floor(n) : 0;
  }

  function report(fields) {
    try {
      if (sent >= MAX_REPORTS) return false;
      var message = cut(fields.message, CAP.message) || '(no message)';
      if (Object.prototype.hasOwnProperty.call(seen, message)) return false;
      seen[message] = true;
      sent += 1;
      var body = JSON.stringify({
        message: message,
        source: cut(fields.source, CAP.source),
        line: whole(fields.line),
        col: whole(fields.col),
        stack: cut(fields.stack, CAP.stack),
        page: cut(global.location && global.location.href, CAP.page),
        ua: cut(global.navigator && global.navigator.userAgent, CAP.ua),
      });
      var pending = global.fetch('/api/client-error', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: body,
        keepalive: true,
        credentials: 'same-origin',
      });
      if (pending && typeof pending.catch === 'function') pending.catch(function () {});
      return true;
    } catch (e) {
      return false;
    }
  }

  function onError(event) {
    try {
      var err = event && event.error;
      report({
        message: (event && event.message) || (err && err.message),
        source: event && event.filename,
        line: event && event.lineno,
        col: event && event.colno,
        stack: err && err.stack,
      });
    } catch (e) { /* never throw from a handler */ }
  }

  function onRejection(event) {
    try {
      var reason = event && event.reason;
      var message;
      try {
        message = reason && reason.message ? reason.message : String(reason);
      } catch (e) {
        message = '(unprintable rejection)';
      }
      report({ message: 'Unhandled rejection: ' + message, stack: reason && reason.stack });
    } catch (e) { /* never throw from a handler */ }
  }

  try {
    global.addEventListener('error', onError);
    global.addEventListener('unhandledrejection', onRejection);
  } catch (e) { /* a page without listeners still loads */ }

  // For the smoke check only: what a page load has sent so far.
  global.__clientErrors = { sentCount: function () { return sent; }, MAX_REPORTS: MAX_REPORTS };
})(typeof window !== 'undefined' ? window : globalThis);
