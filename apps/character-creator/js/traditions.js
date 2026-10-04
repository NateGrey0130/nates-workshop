// Spell traditions, folded away from the general invocations.
//
// A classic script rather than a module, for the reason js/picker.js is one:
// the wizard is an ES module and the codex is a plain script, and both need
// this. It exposes one global, `SpellTraditions`.
//
// WHY. 697 of the catalog's 1,118 spells (production, 2026-09-26) belong to one
// tradition - Warlock elemental, Ocean, Bone, Tattoo and fifteen more - and are
// open only to the classes that practise it. Listed by level beside the general
// invocations, a reader looking for a Level 1 spell waded through Air, Earth,
// Ocean, Spoiling and Living Fire rows first, and "Thunderclap" sat next to
// "Air: Thunderclap". So the general spells keep the main list and each
// tradition gets a heading of its own that folds.
//
// THE KEY IS `spells.tradition`, NEVER THE NAME PREFIX. 20 prefixed spells are
// general invocations (`Ritual:`, `Curse:`, `Teleport:`, `Metamorphosis:`...)
// and 30 shaman spells carry no prefix at all. The prefix is used for one thing
// only: splitting a tradition whose EVERY spell carries one, in two or more
// families, into those families - Warlock into Air, Earth, Fire and Water, Cloud
// Magic into its seven "Clouds of ..." families.

(function () {
  // A tradition missing here still works: its slug is title-cased. These are the
  // ones whose slug is not the name a player knows it by.
  const LABELS = {
    warlock: 'Warlock Elemental',
    cloud: 'Cloud Magic',
    bone: 'Bone Magic',
    ocean: 'Ocean Magic',
    tattoo: 'Magic Tattoos',
    nature: 'Nature Magic',
    nazca: 'Nazca Line Magic',
    'african-ceremonial': 'African Ceremonial',
    'african-witch': 'Bad Medicine',
    spoiling: 'Spoiling Magic',
    nightbane: 'Nightbane Magic',
    dolphin: 'Dolphin Magic',
    // Palladium Fantasy's Diabolist "cannot learn spell magic": what it holds
    // are symbols (BOOK-INGEST-AUDIT F123).
    ward: 'Ward Symbols',
  };

  const slugOf = (sp) => (sp && sp.tradition ? String(sp.tradition).trim().toLowerCase() : '');

  function label(slug) {
    const s = String(slug || '').toLowerCase();
    return LABELS[s] || s.split('-').map((w) => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
  }

  function prefixOf(name) {
    const i = String(name).indexOf(': ');
    return i > 0 ? String(name).slice(0, i) : '';
  }

  // Rows keep the order they arrive in, inside each part - the caller has
  // already filtered and sorted them. Traditions come out alphabetical by label,
  // which is how a reader looks one up; families in the order first met.
  function partition(rows) {
    const general = [];
    const by = new Map();
    for (const r of rows || []) {
      const t = slugOf(r);
      if (!t) { general.push(r); continue; }
      if (!by.has(t)) by.set(t, []);
      by.get(t).push(r);
    }
    const traditions = [...by.entries()].map(([id, list]) => {
      const prefixes = list.map((r) => prefixOf(r.name));
      const families = [...new Set(prefixes)];
      const split = !prefixes.includes('') && families.length > 1;
      return {
        id,
        label: label(id),
        rows: list,
        families: split
          ? families.map((f) => ({ id: f.toLowerCase(), label: f, rows: list.filter((r) => prefixOf(r.name) === f) }))
          : null,
      };
    }).sort((a, b) => a.label.localeCompare(b.label));
    return { general, traditions };
  }

  // THE HEADING A HELD SPELL SITS UNDER ON THE SHEET (BOOK-INGEST-AUDIT F123).
  //
  // The sheet headed every held spell "Spells — Level N", whatever it was. A
  // Diabolist's ward symbols, a Tattooed Man's tattoos and a Summoner's circles
  // are not spells anybody casts, and their rows are stored at level 0, so they
  // read "Spells — Level 0". A spell that belongs to a tradition is headed by
  // the tradition's label instead, with the level only where it has one.
  //
  // General invocations keep the heading they always had, level 0 included.
  function heldGroup(level, slug) {
    const s = String(slug || '').toLowerCase();
    const has = level !== null && level !== undefined && level !== '';
    if (!s) return has ? `Spells — Level ${level}` : 'Spells — Unleveled';
    return has && Number(level) > 0 ? `${label(s)} — Level ${level}` : label(s);
  }

  // General spells first, then each tradition by its label - so every heading's
  // rows stay together, which is what lets the sheet print a heading once.
  function heldOrder(slugA, slugB) {
    const a = String(slugA || '').toLowerCase();
    const b = String(slugB || '').toLowerCase();
    if (a === b) return 0;
    if (!a || !b) return a ? 1 : -1;
    return label(a).localeCompare(label(b)) || a.localeCompare(b);
  }

  window.SpellTraditions = { label, partition, slugOf, heldGroup, heldOrder };
})();
