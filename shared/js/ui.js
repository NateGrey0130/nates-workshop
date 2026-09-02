// Shared UI helpers for all workshop apps

function openModal(id) {
  document.getElementById(id).classList.add('active');
}

function closeModal(id) {
  document.getElementById(id).classList.remove('active');
}

// ESCAPING, AND THE TWO PLACES A VALUE LANDS.
//
// escHtml was `textContent` into `innerHTML`, which is the right escape for
// element CONTENT and the wrong one for an attribute: that path escapes &, <
// and > and leaves `"` alone. Twenty-five call sites put the result inside
// value="...", title="..." or aria-label="...".
//
// What that did, measured rather than imagined. A gear row named
// "Rolling Thunder" All-Purpose Vehicle rendered its Name input EMPTY,
// because value=""Rolling Thunder"... closes at the second quote. A skill's
// bonuses did worse, because every key in the JSON is quoted:
//
//   <input id="f-bonuses" value="{" attributes":{"ps":1,...},"combat":...}"="">
//
// - the value is `{`, and the rest of the JSON was reparsed as attribute
// names. The lowercased "ps" is the parser telling you it read them as markup.
// Open that row in the catalog editor, press Save, and `{` is written back
// over the skill's bonuses. 23 rows in the catalogs carried JSON in an
// attribute, and 11 gear names carried a quote.
//
// It is a plain string walk now rather than a DOM round trip, so it can be
// tested outside a browser and does not build an element per call - the
// catalog renders a thousand rows. Coercion is unchanged on purpose: null
// still becomes '' and undefined still becomes 'undefined', because that is
// what the textContent setter did and call sites were written against it.
function escHtml(str) {
  return (str === null ? '' : String(str))
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// A value going inside an inline handler - onclick="fn('HERE')" - which is a
// JS string literal inside an HTML attribute, and needs BOTH layers.
//
// THE OBVIOUS FIX IS THE WRONG ONE, and it was in the tree six times:
// `escHtml(v).replace(/'/g, '&#39;')`, with a comment saying it stops the
// quote ending the attribute. It does stop that. But an attribute value is
// entity-decoded BEFORE its contents are parsed as JavaScript, so &#39; puts
// the apostrophe straight back into the string literal it was meant to escape
// and the handler is a SyntaxError. A weapon called Dragon's Claw had a dead
// Strike button, and twenty gear names carry an apostrophe.
//
// A backslash survives the HTML decode, so backslash-escaping is what works.
// Backslashes first, or the ones this adds get escaped again.
function escJs(str) {
  return escHtml(str)
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'")
    .replace(/\r?\n/g, '\\n');
}

function copyWithFeedback(text, btn, doneLabel = '✅ Copied!', delay = 1500) {
  return navigator.clipboard.writeText(text).then(() => {
    if (!btn) return;
    const orig = btn.textContent;
    btn.textContent = doneLabel;
    setTimeout(() => { btn.textContent = orig; }, delay);
  });
}
