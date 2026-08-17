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

  // What a character's money is called. Palladium Fantasy counts gold, Rifts
  // counts credits — the same convention the gear catalog's `cost` field
  // already documents. An unknown system gets the neutral word rather than
  // being guessed into one of the two.
  function currencyLabel(system) {
    if (system === 'palladium-fantasy') return 'Gold';
    if (system === 'rifts') return 'Credits';
    return 'Money';
  }


  // ─── Character background (p.32–33) ───
  //
  // Nine percentile tables, and the book opens with "all the following tables
  // are optional" — nothing here is required and nothing derives from it.
  //
  // Each entry is [maxRoll, text], read as "roll <= max, first match wins" —
  // the same shape as the psionics table. Transcribed as printed, including
  // the Birth Order table's jump from Fourth Born to Sixth Born, which is the
  // book's own oddity and not a slip here.
  //
  // Land of Origin is the Palladium world's map. The tables are offered in
  // both systems anyway: a rift opens onto that map, and 97-00 on that very
  // table is "other world, dimension or time".
  const BACKGROUND_TABLES = {
    birth_order: {
      label: 'Birth Order',
      rows: [[25, 'First Born'], [35, 'Second Born'], [45, 'Third Born'],
             [55, 'Fourth Born'], [65, 'Sixth Born'], [75, 'Last Born'],
             [85, 'First Born of Twins'], [100, 'Illegitimate']],
    },
    weight: {
      label: 'Weight',
      rows: [[10, 'Skinny; underweight'], [30, 'Thin'], [55, 'Average'],
             [74, 'Husky'], [89, 'Potbelly'], [100, 'Obese; very overweight']],
    },
    height: {
      label: 'Height',
      // Average for a human male is six feet; five feet seven for a female.
      rows: [[30, 'Short'], [70, 'Average'], [100, 'Tall']],
    },
    age: {
      label: 'Age',
      // Doubled for an elf, dwarf or changeling. Offered as a choice, because
      // race is free text and guessing at it would be wrong as often as right.
      rows: [[10, '17'], [30, '19'], [45, '21'], [60, '24'],
             [75, '26'], [85, '28'], [95, '30'], [100, '32']],
      numeric: true,
      suffix: ' years old',
    },
    disposition: {
      label: 'Disposition',
      rows: [[10, 'Mean or bitter, suspicious and vindictive'],
             [15, 'Shy, timid, tends to be a loner'],
             [23, 'Gung-ho, guts and glory type who sees himself as a hero'],
             [29, 'Worry wart, nervous and cautious'],
             [35, 'Hot-head, quick-tempered, emotional, but basically nice'],
             [43, 'Schemer, gambler who likes to take chances'],
             [48, 'Blabber-mouth, nice guy, but talks too much'],
             [54, 'Wild man, cocky, overconfident, takes unnecessary risks'],
             [61, 'Nice guy, friendly, courteous and hospitable'],
             [67, 'Arrogant, feels superior to others'],
             [75, 'Tough guy, lone wolf; cocky and self-reliant'],
             [81, 'Braggart, likes to brag about his or her abilities'],
             [86, 'Paternal, overprotective, tends to be overbearing'],
             [91, 'Easy going, laid back; trusts almost anyone'],
             [95, 'Complainer; constantly aggravated about something'],
             [100, 'Paranoid, trusts no one']],
    },
    land_of_origin: {
      label: 'Land of Origin',
      rows: [[5, "Ophid's Grasslands (North)"],
             [7, 'Algor or other Northern Mountains'],
             [12, 'Kingdom of Bizantium (North)'],
             [14, 'Phi Island (Eastern Territory)'],
             [17, 'Lopan (Eastern Territory)'], [24, 'Timiro Kingdom'],
             [34, 'Eastern Territory'], [44, 'Old Kingdom (mountains or lowlands)'],
             [55, 'Western Empire'], [66, 'The Great Northern Wilderness'],
             [75, 'The Land of the South Winds'], [84, 'The Yin-Sloth Jungles'],
             [89, 'The Baalgor Wastelands'], [91, 'The Land of the Damned'],
             [94, 'Floenry Isles or other Southern Islands'],
             [96, 'Isle of the Cyclops or the Four Sisters'],
             [100, 'Other world, dimension or time']],
    },
    environment: {
      label: 'Environment',
      rows: [[15, 'Small wilderness town'], [30, 'Large farming community or ranch'],
             [40, 'Little farm community'], [60, 'Small to medium city'],
             [70, 'Town or city where magic, psionics or the supernatural were commonplace'],
             [80, 'Large, bustling city; may have grown up in a slum'],
             [90, 'Small fishing, river or sea community'],
             [95, 'Small to medium tribe or clan'],
             [100, 'Religious community with strong ties to a church, cult or god']],
    },
    family_origin: {
      label: 'Family Origin',
      rows: [[5, 'Sailor/Fisherman'], [15, 'Craftsman'], [25, 'Serf/Peasant Laborer'],
             [35, 'Peasant Farmer'], [45, 'Farmer and Landowner; not rich but well off'],
             [55, 'Men at Arms or Warrior Clan'], [65, 'Scavenger, Thief or Vagabond'],
             [75, 'Merchant or Businessman; not rich but well off'],
             [85, 'Scholarly and educated; could be rich or poor'],
             [92, 'Magic or Religious; could be rich or poor'],
             [100, 'Noble; could be wealthy or poor (fallen from power)']],
    },
    racial_bias: {
      label: 'Racial Bias',
      rows: [[5, 'Ghouls and Bogie men'],
             [10, 'Kobolds (or ratlings in the Western Empire)'],
             [15, 'Trolls and giants'], [20, 'Faerie folk'],
             [30, 'Wolfen and coyles'], [40, 'Orcs, goblins and hob-goblins'],
             [50, 'Changelings'], [55, 'Elves'], [60, 'Dwarves'], [70, 'Ogres'],
             [80, 'Dragons'],
             [90, 'Supernatural; may include gods, spirits and demons'],
             [95, 'Other of choice (lizard men, bearmen, ratlings)'],
             [100, 'Suspicious of everybody, humans and non-humans alike']],
    },
  };

  // The entry a given percentile lands on. Out of range returns null rather
  // than clamping, so a bad roll is visible instead of silently becoming "01".
  function backgroundResult(key, roll) {
    const table = BACKGROUND_TABLES[key];
    const n = Number(roll);
    if (!table || !Number.isFinite(n) || n < 1 || n > 100) return null;
    const row = table.rows.find(([max]) => n <= max);
    return row ? row[1] : null;
  }

  // `double` applies the Age table's note — twice the years for an elf, dwarf
  // or changeling. It only means anything on a numeric table.
  function rollBackground(key, { double = false } = {}) {
    const table = BACKGROUND_TABLES[key];
    if (!table) return null;
    const roll = 1 + Math.floor(Math.random() * 100);
    let text = backgroundResult(key, roll);
    if (text != null && table.numeric) {
      text = (Number(text) * (double ? 2 : 1)) + (table.suffix || '');
    }
    return { roll, text };
  }

  global.rules = {
    ALIGNMENT_GROUPS, ALIGNMENTS, alignmentGroup, isAlignment, alignmentOptions,
    currencyLabel,
    BACKGROUND_TABLES, backgroundResult, rollBackground,
  };
})(globalThis);
