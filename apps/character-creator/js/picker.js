// Filtering for the catalog pickers.
//
// A classic script rather than a module, for the same reason js/derive.js is:
// the wizard is an ES module and the sheet is a plain script, and both need
// this. It exposes one global, `Picker`.
//
// WHY THIS EXISTS. Every picker in the app rendered its whole catalog: 74 gear
// rows in two places, 128 skills in a native <select>. Those were the counts
// when this was written and they have since roughly tripled — the catalogs are
// past 400 gear rows and 200 skills, and the spell and psionic chapters that
// had not been imported then have been since. The argument only got stronger,
// and the pickers are pre-filtered by level and tier,
// which hides the problem right up until it doesn't.
//
// The control underneath varies by task and should: "add one item" wants a list
// you click, "pick 6 of these" wants checkboxes, and the level-up block wants N
// independent dropdowns over one shared pool. What is shared is the matching
// and the input, so that is all this owns.

(function () {
  // Fields worth searching. Deliberately not every column: matching on a field
  // the row does not display produces hits whose reason is invisible, which
  // reads as a bug rather than a feature.
  const FIELDS = ['name', 'category', 'source_book'];

  const norm = (s) => String(s ?? '').toLowerCase();

  function haystack(row) {
    return FIELDS.map((f) => norm(row?.[f])).join(' ');
  }

  // Every term must appear, so "wilderness rifts" narrows rather than widens.
  // Order-independent, because nobody remembers whether the book or the skill
  // name comes first.
  function terms(query) {
    return norm(query).split(/\s+/).filter(Boolean);
  }

  function match(row, query) {
    const t = terms(query);
    if (!t.length) return true;
    const hay = haystack(row);
    return t.every((term) => hay.includes(term));
  }

  function filter(rows, query) {
    const t = terms(query);
    if (!t.length) return rows || [];
    return (rows || []).filter((r) => {
      const hay = haystack(r);
      return t.every((term) => hay.includes(term));
    });
  }

  // The count is the point as much as the input is: "12 of 128" tells you
  // whether to keep typing, and whether an empty list means "no match" or
  // "nothing in the catalog".
  function inputHtml({ id, value = '', placeholder = 'Filter…', shown, total }) {
    const count = (total === undefined) ? ''
      : `<span class="muted small pick-count">${shown} of ${total}</span>`;
    return `<div class="pick-filter">
      <input type="search" id="${id}" value="${escapeAttr(value)}" placeholder="${escapeAttr(placeholder)}">
      ${count}
    </div>`;
  }

  function escapeAttr(s) {
    return String(s ?? '').replace(/&/g, '&amp;').replace(/"/g, '&quot;')
      .replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  // Both pages re-render by replacing innerHTML, which destroys the input
  // mid-keystroke and drops the caret to the end. Restoring it was already
  // hand-rolled in the catalog editor; doing it in one place means the next
  // picker cannot forget.
  //
  // onEnter fires only when the filter has narrowed to exactly one row —
  // type until it's alone, press Enter, take it.
  function wire(id, { onInput, onEnter, lone } = {}) {
    const el = document.getElementById(id);
    if (!el) return;

    if (onInput) {
      el.addEventListener('input', () => {
        const pos = el.selectionStart;
        onInput(el.value);
        const again = document.getElementById(id);
        if (again && again !== el) { again.focus(); again.setSelectionRange(pos, pos); }
      });
    }

    el.addEventListener('keydown', (ev) => {
      if (ev.key !== 'Enter') return;
      ev.preventDefault();
      if (onEnter && lone) onEnter(lone);
    });
  }

  window.Picker = { FIELDS, match, filter, inputHtml, wire };
})();
