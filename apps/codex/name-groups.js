// One codex entry per gear NAME, holding every book that prints it.
//
// The gear table has a row per printing: "2-handed Espandon" is three rows, one
// each from the Palladium RPG, Heroes Unlimited and Nightbane, and each has its
// own slug, price and often its own damage and wording. Listed row by row the
// Gear tab showed 780 more lines than it has things (production, 2026-10-02:
// 3,608 rows, 2,828 names). So the PAGE folds them; the table is left alone,
// because class markdown, inventory and the sheet's links all cite a printing
// by its slug and a merged row would strand every one of them.
//
// Grouped on the name ALONE - lower-cased and trimmed, which is how the three
// Espandon rows differ - and not on category: four names are `gear` in one
// book and `weapon` in another, and they are still one thing.
//
// A classic script with no DOM in it, like js/traditions.js, so the test suite
// can run it: the page reads `window.NameGroups`.
(() => {
  const nameKey = (name) => String(name == null ? '' : name).trim().toLowerCase();
  const slugKey = (p) => String(p.slug).toLowerCase();
  const bookOf = (p) => String(p.source_book || '');

  // `key` is the entry's own - the first printing's slug - and is passed in
  // when a narrowed copy is made, so an entry keeps its key, its open state and
  // its link whichever of its books a system filter is hiding.
  function make(printings, key) {
    const withText = printings.find((p) => p.description && String(p.description).trim());
    return {
      key: key || slugKey(printings[0]),
      name: printings[0].name,
      printings,
      slugs: printings.map(slugKey),
      // What the page's generic code reads off any row: the book it sorts by
      // and whether there is text to show.
      source_book: printings[0].source_book,
      description: withText ? withText.description : null,
    };
  }

  // In the order the names first arrive, which is the catalog's own. Inside an
  // entry the books are in book order, so the entry's key does not depend on
  // the order the database happened to return two rows of one name in.
  function fold(rows) {
    const by = new Map();
    for (const r of rows || []) {
      const k = nameKey(r.name);
      if (!by.has(k)) by.set(k, []);
      by.get(k).push(r);
    }
    return [...by.values()].map((list) => make(
      [...list].sort((a, b) => bookOf(a).localeCompare(bookOf(b), undefined, { numeric: true })
        || slugKey(a).localeCompare(slugKey(b)))));
  }

  // One game's printings of an entry, or null when it has none. A NULL system
  // and `both` are unrestricted, as every picker reads them.
  function narrow(g, system) {
    if (!system) return g;
    const keep = g.printings.filter((p) => !p.system || p.system === 'both' || p.system === system);
    if (!keep.length) return null;
    return keep.length === g.printings.length ? g : make(keep, g.key);
  }

  // The key of the entry holding this slug. Every printing's slug answers, not
  // only the first: the sheet links an item by the slug the character holds.
  function resolve(groups, slug) {
    const want = String(slug).toLowerCase();
    const g = (groups || []).find((x) => x.slugs.includes(want));
    return g ? g.key : null;
  }

  const api = { fold, narrow, resolve, nameKey };
  if (typeof window !== 'undefined') window.NameGroups = api;
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
})();
