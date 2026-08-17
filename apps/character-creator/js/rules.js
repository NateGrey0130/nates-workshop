// Closed lists the book fixes — values that are not catalog content and not a
// house rule, but a finite set printed in the rulebook.
//
// A classic script rather than a module, for the same reason as derive.js and
// picker.js: the sheet is a plain-script page and the wizard is a module, and
// both need these. Duplicating the list in each would be a nuisance while they
// agree and a bug the moment they do not — see the five copies of api() this
// repo already learned that from.

(function (global) {
  // Palladium Fantasy RPG 2nd Ed., p.23. Seven alignments in three groups, and
  // deliberately NO neutral — the book spends a paragraph ruling it out, on the
  // grounds that a true neutral could not make a decision or take any action.
  //
  // Closed on purpose. A free-text escape hatch would mean the field is only
  // conventionally constrained, and "Neutral" is exactly what would get typed
  // into it. If a supplement is ever imported that adds alignments, this is the
  // one place to widen.
  const ALIGNMENT_GROUPS = [
    ['Good', ['Principled', 'Scrupulous']],
    ['Selfish', ['Unprincipled', 'Anarchist']],
    ['Evil', ['Miscreant', 'Aberrant', 'Diabolic']],
  ];

  const ALIGNMENTS = ALIGNMENT_GROUPS.flatMap(([, names]) => names);

  // Which group an alignment belongs to, for display. Unknown values — anything
  // typed before this list existed — return null rather than being coerced into
  // a group they may not belong to.
  function alignmentGroup(name) {
    const found = ALIGNMENT_GROUPS.find(([, names]) => names.includes(name));
    return found ? found[0] : null;
  }

  const isAlignment = (name) => ALIGNMENTS.includes(name);

  // A <select> over the groups. `current` is preselected; a value that is not
  // one of the seven is preserved as its own option rather than silently
  // dropped, so opening a character that predates the list cannot erase what it
  // had by merely rendering the page.
  function alignmentOptions(current) {
    const known = isAlignment(current);
    const legacy = current && !known
      ? `<option value="${escapeAttr(current)}" selected>${escapeAttr(current)} (not a standard alignment)</option>`
      : '';
    return `<option value=""${current ? '' : ' selected'}>— choose —</option>${legacy}`
      + ALIGNMENT_GROUPS.map(([group, names]) =>
        `<optgroup label="${group}">` + names.map((n) =>
          `<option value="${n}"${n === current ? ' selected' : ''}>${n}</option>`).join('') + '</optgroup>').join('');
  }

  // Local rather than imported: this file is loaded before any page's own
  // helpers and must not depend on them.
  function escapeAttr(s) {
    return String(s).replace(/[&<>"']/g, (c) =>
      ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  }

  global.rules = { ALIGNMENT_GROUPS, ALIGNMENTS, alignmentGroup, isAlignment, alignmentOptions };
})(globalThis);
