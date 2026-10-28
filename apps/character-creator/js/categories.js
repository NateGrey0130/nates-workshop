// The related-skill category rules: what a category entry admits, the bonus it
// pays, the picker label, the related-skill floors, and the shape checks the
// validator runs on all three.
//
// Moved out of js/parser.js verbatim, and parser.js re-exports every name it
// exported before, so an importer of parser.js is unchanged. The validator in
// parser.js still calls three names from here, imported and not re-exported:
// validateCategories, refusePsionicBonus and validateRelatedMinimums.
//
// This file imports nothing, so unlike js/combine.js it is in no cycle.

// ─── related-skill categories ───
//
// A category is either a plain string ("Wilderness: Any") or an object saying
// what the book allows inside it. Every entry the books print is one of three
// shapes, so those are the three supported:
//
//   { name: "Espionage", only: ["Escape Artist"] }
//   { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
//   { name: "Technical", bonus: 10 }
//
// Strings keep working, so nothing already authored has to change. Shared by
// the wizard's picker and the server-side validator, because two copies of
// "may this character take this skill" is exactly the pair that drifts.
//
// `bonus` is the percentage a class page prints in parentheses beside the
// category — "Technical: Any (+10%)". It exists because until it did, those
// numbers had nowhere to go: `only` and `except` were the whole vocabulary, so
// an import either dropped the bonus silently or wrote a `bonus` key that
// parsed and then did nothing, which is the worse of the two. Pantheons of the
// Megaverse prints twenty-one of them across four classes, and the Godling
// shipped missing all five of its own.
//
// It combines with `only`/`except` rather than replacing them: the Godling's
// Medical line is "Any (except cybernetics; +10%)", one category carrying both.
//
// It applies to RELATED picks only, never secondary ones. That is the book's
// own rule and not a simplification — the secondary skills paragraph on every
// class page says the bonus in parentheses "applies only to O.C.C. related
// skill selections". The I.Q. bonus is separate and still reaches both.

export const normName = (s) => String(s ?? '').trim().toLowerCase();

export const categoryName = (entry) => (typeof entry === 'string' ? entry : entry?.name ?? null);

// A human label for the picker: "Espionage (Escape Artist only)".
export function categoryLabel(entry) {
  const name = categoryName(entry);
  if (typeof entry === 'string' || !entry) return name ?? '';
  // The bonus rides along with whatever restriction the category also states,
  // because the book prints them in one parenthetical and a picker that showed
  // only half of it would be quietly lying about the other half.
  const pct = Number.isFinite(entry.bonus) && entry.bonus !== 0
    ? `${entry.bonus > 0 ? '+' : ''}${entry.bonus}%` : '';
  // The PREFIX forms are shown too. A picker that displayed "Pilot" while
  // silently withholding thirteen Robot Combat rows would be lying by omission
  // in the same way the bonus case above was - which is why they are appended
  // to the same parenthetical rather than given one of their own (F23(b)).
  const parts = [];
  const onlyBits = [
    ...(Array.isArray(entry.only) ? entry.only : []),
    ...(Array.isArray(entry.only_prefix) ? entry.only_prefix.map((p) => `${p}...`) : []),
  ];
  const exceptBits = [
    ...(Array.isArray(entry.except) ? entry.except : []),
    ...(Array.isArray(entry.except_prefix) ? entry.except_prefix.map((p) => `${p}...`) : []),
  ];
  if (onlyBits.length) parts.push(`${onlyBits.join(', ')} only`);
  else if (exceptBits.length) parts.push(`except ${exceptBits.join(', ')}`);
  if (pct) parts.push(pct);
  return parts.length ? `${name} (${parts.join('; ')})` : (name ?? '');
}

// Does this ONE category entry, already known to match the skill's real
// category, admit the skill? `name` is normName(skill.name).
//
// PREFIX FORMS, for a book that excludes a FAMILY rather than a list.
// BOOK-INGEST-AUDIT.md F23(b): Triax printed 170 says "Technical: All, except
// lore" and "Pilot: All, except pilot robots & power armor and robot combat".
// Those are 14 `Lore...` rows and 13 `Robot Combat...` rows, and this book
// alone added NINE of the latter - so an exact-name list would rot on contact
// and under-grant silently, which is the direction nothing reports.
//
// SCOPED TO THIS ENTRY, never applied globally. Two `Lore:` rows are filed
// under Cowboy rather than Technical, and a prefix reaching across categories
// would exclude them from a Cowboy grant that never mentioned lore. Every
// caller hands this an entry already matching the skill's real category, so
// testing it here IS the scoping.
function entryAdmits(entry, name) {
  if (typeof entry === 'string') return true;
  if (!entry || typeof entry !== 'object') return false;
  const hasPrefix = (list) => Array.isArray(list)
    && list.some((p) => normName(p) && name.startsWith(normName(p)));

  if (entryNarrowsByOnly(entry)) {
    return (entry.only || []).some((n) => normName(n) === name)
      || hasPrefix(entry.only_prefix);
  }
  // `except` AND `except_prefix` TOGETHER ARE LEGAL, unlike `only` with
  // `except`. Both point the same way - each REMOVES rows - so "these named
  // ones, and everything starting with that" has exactly one reading, where
  // "only these, except some of them" has none. The Pilot line needs precisely
  // this combination and cannot be written without it: one exact name
  // (`Robots & Power Armor`) and one family (`Robot Combat...`).
  if (entryNarrowsByExcept(entry)) {
    return !(entry.except || []).some((n) => normName(n) === name)
      && !hasPrefix(entry.except_prefix);
  }
  return true;
}

const entryNarrowsByOnly = (entry) => !!entry && typeof entry === 'object'
  && ((Array.isArray(entry.only) && entry.only.length > 0)
    || (Array.isArray(entry.only_prefix) && entry.only_prefix.length > 0));
const entryNarrowsByExcept = (entry) => !!entry && typeof entry === 'object'
  && ((Array.isArray(entry.except) && entry.except.length > 0)
    || (Array.isArray(entry.except_prefix) && entry.except_prefix.length > 0));

// WHICH of the class's entries for the skill's real category speaks for it,
// and whether that entry admits it (BOOK-INGEST-AUDIT.md F109).
//
// A book can print a bonus for PART of a category: Coalition War Campaign's
// Nautical Specialist is "Pilot: Any, +10% to water vehicles only". That is
// written as the category twice - `{ Pilot, only: [the water vehicles],
// bonus: 10 }` and `{ Pilot, except: [the same names] }` - and both
// categoryAllows and categoryBonus used to take the FIRST entry with a matching
// name. With the `only` entry first every other Pilot skill was REFUSED; with
// the `except` entry first none got the +10%.
//
// So the entries are ranked, most specific first:
//   1. an `only` / `only_prefix` entry that names the skill;
//   2. an `except` / `except_prefix` entry that does not exclude it;
//   3. a plain entry, which admits everything in the category.
// The first rank that holds wins, and it is BOTH the admission and the bonus,
// so the two functions cannot disagree about which line of the book applied.
//
// When no entry admits the skill, the first same-named entry is returned with
// `admits: false`. That keeps a list naming the category once - every class
// before F109 - behaving exactly as the old first-hit lookup did, including
// categoryBonus's fallback for a pick admitted cross-category.
//
// A MERGED list can hold two same-named entries too: dedupeCategories
// (functions/api/character-creator/_lib/skill-picks.js) folds several related
// grants' lists into one. Ranking reads that list as "a pick passes if any
// grant admits it, and the most specific grant pays", where first-hit read it
// as whichever grant happened to be listed first.
function realCategoryEntry(categories, skill) {
  const name = normName(skill?.name);
  const cat = normName(skill?.category);
  const same = categories.filter((c) => normName(categoryName(c)) === cat);
  if (!same.length) return { entry: undefined, admits: false };
  const admitting = same.filter((c) => entryAdmits(c, name));
  const best = admitting.find(entryNarrowsByOnly)
    ?? admitting.find(entryNarrowsByExcept)
    ?? admitting[0];
  return best !== undefined ? { entry: best, admits: true } : { entry: same[0], admits: false };
}

// The percentage this category list adds to a RELATED pick of `skill`, or 0.
//
// Keyed on the skill's REAL catalog category, with ONE exception: an entry that
// admitted this pick through a cross-category `only` AND carries a percentage
// of its own scores it (BOOK-INGEST-AUDIT.md F9).
//
// The default is deliberate and stays. A cross-category `only` entry says "you
// may spend a pick here on this skill"; it does not by itself say the skill
// joins that category for scoring, and reading it that way unconditionally
// would hand the Glitter Boy's Wilderness Survival an Espionage bonus that was
// never printed.
//
// What the default could not tell apart is a cross-category line with NO
// printed percentage, where inheriting one would invent it, from a line WITH
// one, where dropping it loses what the book printed. Two classes print
// "Rogue: Prowl only (+5%)", the catalog files Prowl under Physical, and the
// +5% landed nowhere while the picker still showed the player "Rogue (Prowl
// only; +5%)" - the wizard promising what the sheet did not give.
//
// THE `!== 0` GUARD IS LOAD-BEARING and is why this is not simply "the
// admitting entry wins". Swept across every published class, EIGHTEEN picks are
// admitted by a cross-category `only` and only THREE of them name a percentage.
// Of the other fifteen, three sit on a real category that DOES pay - the
// Glitter Boy's Wilderness at +2%, the Combat Cyborg's Military at +10%, the
// CAF Trooper's Wilderness at +5% - so an unconditional swap would have taken
// those three to zero. The specific statement wins only where the book made one.
export function categoryBonus(categories, skill) {
  if (!Array.isArray(categories) || !categories.length) return 0;
  const name = normName(skill?.name);
  const real = normName(skill?.category);
  // Bounded exactly as categoryAllows bounds the same rule: the class must also
  // list the skill's real category, or the pick was never admitted this way.
  if (name && categories.some((c) => normName(categoryName(c)) === real)) {
    const admitting = categories.find((c) => c && typeof c === 'object'
      && normName(categoryName(c)) !== real
      && Array.isArray(c.only) && c.only.some((n) => normName(n) === name));
    if (admitting && Number.isFinite(admitting.bonus) && admitting.bonus !== 0) {
      return admitting.bonus;
    }
  }
  // Ranked, not first-hit: a category printed with a bonus for part of it is
  // two entries, and the one naming the skill pays (F109, realCategoryEntry).
  const { entry } = realCategoryEntry(categories, skill);
  if (!entry || typeof entry === 'string') return 0;
  return Number.isFinite(entry.bonus) ? entry.bonus : 0;
}

// Does this category list name `skill` in an `only` list? A class that names a
// skill outright is its book's own word that the skill may be taken, so the
// pickers let it past the game filter (`skills.systems`) - for THIS grant only.
// The Chiang-Ku Dragon is a Palladium Fantasy class whose book grants "three
// modern weapon proficiencies", and Palladium Fantasy's own tag holds none.
// Callers still test categoryAllows; this answers only the game question.
export function namedByOnly(categories, skill) {
  if (!Array.isArray(categories)) return false;
  const name = normName(skill?.name);
  return !!name && categories.some((c) => c && typeof c === 'object'
    && Array.isArray(c.only) && c.only.some((n) => normName(n) === name));
}

// Does this category list admit `skill` — an object with `name` and `category`?
// An empty or absent list restricts nothing, which is what "any" means.
export function categoryAllows(categories, skill) {
  if (!Array.isArray(categories) || !categories.length) return true;
  const name = normName(skill?.name);

  // An `only` list names the skill by name, under the category THE BOOK files
  // it in. The catalog files each skill under exactly one category, and the two
  // schemes disagree often enough to matter: the Glitter Boy's "Espionage:
  // Wilderness Survival only" is an ordinary book line, and Wilderness Survival
  // is a Wilderness skill in the catalog.
  //
  // Matching an `only` entry by name is what the book means - you may spend a
  // pick from that category on this skill. Filtering by the catalog's category
  // first made the name match nothing, which cost the two Elemental Fusionists
  // their Writing and Lore: Cattle & Animals outright.
  //
  // BOUNDED by the class also listing the skill's real category. Without that
  // bound, any `only` entry would reach a skill from a category the class never
  // granted at all, which is wider than any book says. Every real case clears
  // it: a class naming a skill under a neighbouring category grants that
  // neighbour too.
  //
  // "Lists the category" is deliberately not "that category's own restriction
  // admits the skill". The Elemental Fusionists grant Technical with an `only`
  // list that does not carry Writing, and Communications names it instead -
  // requiring both would refuse the very skill this exists to reach. The more
  // specific statement, the one naming the skill, wins.
  //
  // Deliberately only `only`. An `except` naming a skill from another category
  // still excludes nothing, because nothing was offered there to exclude.
  if (name && categories.some((c) => normName(categoryName(c)) === normName(skill?.category))
      && categories.some((c) => c && typeof c === 'object'
        && Array.isArray(c.only) && c.only.some((n) => normName(n) === name))) {
    return true;
  }

  // Every entry naming the skill's real category is asked, not only the first:
  // a category can be listed twice to scope a bonus to part of it (F109), and
  // the `only` half must not refuse what the `except` half admits. The entry
  // itself is judged by entryAdmits, which reads `only`, `except`,
  // `only_prefix` and `except_prefix` off the ENTRY.
  return realCategoryEntry(categories, skill).admits;
}

export function validateCategories(where, categories, errors) {
  if (!Array.isArray(categories)) return;
  for (const c of categories) {
    if (typeof c === 'string') continue;
    if (!c || typeof c !== 'object' || Array.isArray(c)) {
      errors.push(`${where} entries must be a category name or an object with a name`);
      continue;
    }
    if (typeof c.name !== 'string' || !c.name.trim()) {
      errors.push(`${where} object entries need a name`);
    }
    for (const key of ['only', 'except', 'only_prefix', 'except_prefix']) {
      if (c[key] === undefined) continue;
      if (!Array.isArray(c[key]) || c[key].some((s) => typeof s !== 'string' || !s.trim())) {
        errors.push(`${where}.${c.name}.${key} must be a list of `
          + (key.endsWith('_prefix') ? 'name prefixes' : 'skill names'));
      }
    }
    // Both at once has no single reading: "only these, except some of them" is
    // just a shorter `only` list, and guessing which the author meant is worse
    // than saying so.
    //
    // THE PREFIX FORMS ARE JUDGED THE SAME WAY, BY DIRECTION. `except` with
    // `except_prefix` is fine - both remove rows, so the reading is one list.
    // Anything mixing an ADMITTING form with an EXCLUDING one is refused, for
    // the reason above (F23(b)).
    const admits = (Array.isArray(c.only) && c.only.length)
      || (Array.isArray(c.only_prefix) && c.only_prefix.length);
    const excludes = (Array.isArray(c.except) && c.except.length)
      || (Array.isArray(c.except_prefix) && c.except_prefix.length);
    if (admits && excludes) {
      // Wording is pinned: test/smoke.mjs matches /both only and except/ on
      // this message, and that check predates the prefix forms. Phrased to keep
      // it true rather than editing the test to suit a new sentence.
      errors.push(`${where}.${c.name} sets both only and except forms; use one direction`);
    }
    // A bonus has to be a real number. The books print these as "+10%", and a
    // string "10%" or "+10" would pass `!== undefined`, fail Number.isFinite at
    // read time and add nothing — the exact silent no-op this key was added to
    // stop, reintroduced one layer down.
    if (c.bonus !== undefined && (typeof c.bonus !== 'number' || !Number.isFinite(c.bonus))) {
      errors.push(`${where}.${c.name}.bonus must be a number of percentage points, not "${c.bonus}"`);
    }
  }
}

// A percentage is a SKILL idea, and a psionic category may not carry one.
// BOOK-INGEST-AUDIT.md F92. This was written inline against `categories_allowed`
// and F91 then added two more lists that reach the same gate, so it is a
// function rather than three copies of one `if`.
//
// THE REASON THE OLD COMMENT GAVE WAS WRONG, and the message it produced is
// kept because the message is not. It said a bonus here "would be stored and
// never read". It is read: `categoryLabel` (this file) renders
// `Number.isFinite(entry.bonus)` into the picker caption, and four call sites
// show it on a psionic category - the starting-group picker (app.js:3708), the
// sheet (sheet.js:2531 via psiCatLabel), the server's rejection text
// (power-picks.js:194) and validate-character.js:505. What NOTHING does is
// APPLY it: `categoryBonus` has two call sites and both are skill-side.
//
// So the defect is worse than the old comment claimed rather than absent. A
// stored bonus is not inert - it prints "Super (+10%)" on a power that has no
// percentage to raise, which is the wizard promising what the sheet cannot
// give. Read 2026-09-15.
export function refusePsionicBonus(where, categories, errors) {
  for (const c of categories || []) {
    if (c && typeof c === 'object' && c.bonus !== undefined) {
      errors.push(`${where}.${c.name} sets a bonus; `
        + 'a psionic power has a cost, not a percentage');
    }
  }
}

// A per-category FLOOR on the related-skill picks: "Select 8 other skills, but
// at least two must be selected from espionage and two from rogue skills"
// (Phase World printed 83). BOOK-INGEST-AUDIT.md F6.
//
// `occ_related_skills` already says HOW MANY picks and WHICH categories are
// legal, and narrows a category with `only` / `except`. All three are ceilings.
// A floor is the opposite shape and could not be written at all, so classes
// across several books carried the rule as prose in a `note` and offered every
// pick freely - including the one thing each of their books forbids.
//
// TWO SPELLINGS, and the second is not decoration. The Freedom Fighter's floor
// names one category:
//
//   minimums:
//     - { count: 2, category: "Espionage" }
//     - { count: 2, category: "Rogue" }
//
// The City Rat's names a UNION - "at least three must be selected from Physical
// or Rogue skills" (Rifts Ultimate Edition printed 88). Three Physical, three
// Rogue, or any mix of three across the two; written as two separate floors it
// would demand six picks the book never asks for:
//
//   minimums:
//     - { count: 3, categories: ["Physical", "Rogue"] }
//
// So an entry carries a LIST of categories and is satisfied by picks from any
// of them. `category:` is the one-element sugar, because most floors are one
// category and a list of one reads badly beside a book that says "Technical".
const minimumCategories = (m) => (Array.isArray(m?.categories)
  ? m.categories
  : (m?.category === undefined ? [] : [m.category]));

/**
 * The related-skill floors of a class, normalised to `{ count, categories }`
 * with the sugar expanded. Empty when the class has none, which is most of
 * them.
 *
 * The wizard, the server validator and this file's own checks all read the
 * floors through here, so the two spellings are resolved in exactly one place.
 */
export function relatedMinimums(cls) {
  const mins = cls?.skills?.occ_related_skills?.minimums;
  if (!Array.isArray(mins)) return [];
  return mins
    .filter((m) => m && typeof m === 'object' && Number.isFinite(m.count))
    .map((m) => ({ count: m.count, categories: minimumCategories(m).map(String) }));
}

/**
 * How the floors stand against the picks made, and whether they can still be
 * met. `categories` is the catalog category of each related pick the character
 * holds; `allowance` is how many related picks it may hold in total.
 *
 * A FLOOR IS NOT A CEILING, AND THE DIFFERENCE DECIDES WHEN IT CAN FIRE. The
 * count and category rules are broken the instant they are broken; a floor that
 * is merely unmet may still be met by the picks not yet spent. `unreachable` is
 * therefore the only honest trigger for refusing a save, and for telling a
 * player their build is illegal - "0/2 Espionage" on a half-built character is
 * a running total, not a fault.
 *
 * The shortfalls are summed against what remains rather than tested one at a
 * time. Six of eight spent on an Imperial Security Agent holding one espionage
 * and no rogue leaves each floor individually reachable - one more espionage,
 * or two more rogue - and the two together needing three picks where two
 * remain.
 *
 * THE SERVER VALIDATOR AND THE WIZARD BOTH COME THROUGH HERE. They arrive with
 * different things in hand - stored skill rows on one side, picked names and a
 * catalog index on the other - and they must not disagree about whether a
 * character is legal. Only the mapping to categories is theirs; the arithmetic
 * is this function's.
 *
 * AN ALLOWANCE BELOW THE FLOORS' OWN TOTAL (BOOK-INGEST-AUDIT F129). A class's
 * file cannot state one - validateRelatedMinimums refuses it - but a race's
 * `pairing_counts` trims the composed count, and three picks cannot hold two
 * Espionage and two Military. Tested the old way every such build is
 * unreachable, the one with every pick on a floor included. Nate's ruling,
 * 2026-10-13: the count stays what the book prints, and every pick goes to a
 * required category until the picks run out. So below the total a build is
 * legal exactly when no pick is WASTED, a wasted pick being one that brought
 * the floors no nearer: one outside every floor, or one more in a floor
 * already full. `trimmed` says which of the two tests was applied.
 *
 * At or above the total the old test runs, untouched. For floors that share no
 * category the two are one test - `wasted > allowance - total` is `owed >
 * remaining` rearranged - so the split changes nothing there; it exists so
 * that no build judged before this was written is judged differently now.
 */
export function relatedFloorStatus(cls, categories, allowance) {
  const floors = relatedMinimums(cls);
  const held = (Array.isArray(categories) ? categories : []).map(normName);
  const allowed = Number.isFinite(allowance) ? allowance : held.length;
  const remaining = Math.max(0, allowed - held.length);
  const status = floors.map((f) => {
    const wanted = new Set(f.categories.map(normName));
    const have = held.filter((c) => wanted.has(c)).length;
    return { ...f, have, met: have >= f.count, missing: Math.max(0, f.count - have) };
  });
  const short = status.filter((f) => !f.met);
  const owed = short.reduce((n, f) => n + f.missing, 0);
  const floorTotal = floors.reduce((n, f) => n + f.count, 0);
  if (allowed >= floorTotal) {
    return { floors: status, short, remaining, owed, trimmed: false, wasted: 0, unreachable: owed > remaining };
  }
  // The fewest picks that would meet every floor, from nothing and from here.
  // A pick counts toward EVERY floor naming its category (that is what `have`
  // counts above), so floors sharing a category need fewer picks than their
  // counts add up to, and the sum cannot stand in for this.
  const sets = floors.map((f) => new Set(f.categories.map(normName)));
  const fewest = floorPicksNeeded(sets, floors.map((f) => f.count));
  const needed = floorPicksNeeded(sets, status.map((f) => f.missing));
  const wasted = held.length - (fewest - needed);
  return { floors: status, short, remaining, owed, trimmed: true, wasted,
           unreachable: wasted > Math.max(0, allowed - fewest) };
}

// The fewest picks that bring every deficit to zero, when one pick lowers the
// deficit of each floor whose categories include it. Floors are few and small,
// so this walks every choice, remembering the deficits it has already solved.
function floorPicksNeeded(sets, deficits, memo = new Map()) {
  if (deficits.every((d) => d <= 0)) return 0;
  const key = deficits.join(',');
  if (memo.has(key)) return memo.get(key);
  const open = new Set();
  sets.forEach((set, i) => { if (deficits[i] > 0) for (const c of set) open.add(c); });
  let best = Infinity;
  for (const c of open) {
    const next = deficits.map((d, i) => (sets[i].has(c) ? Math.max(0, d - 1) : d));
    best = Math.min(best, 1 + floorPicksNeeded(sets, next, memo));
  }
  memo.set(key, best);
  return best;
}

/**
 * Shape checks on `occ_related_skills.minimums`.
 *
 * Every one of these is an ERROR rather than a warning, because a floor is
 * enforced server-side the moment it parses: a floor naming a category the
 * class does not grant would refuse every character of that class, and a floor
 * that is silently dropped puts the class back where F6 found it. Both failure
 * modes are worse than refusing to load the file.
 */
export function validateRelatedMinimums(related, errors) {
  const mins = related?.minimums;
  if (mins === undefined) return;
  if (!Array.isArray(mins)) {
    errors.push('skills.occ_related_skills.minimums must be a list of { count, category } entries');
    return;
  }
  // The categories the class actually offers, by their normalised names. A
  // floor outside this set is unsatisfiable by construction.
  const granted = new Set((related.categories || [])
    .map((c) => normName(categoryName(c))).filter(Boolean));
  let floorTotal = 0;
  for (const m of mins) {
    if (!m || typeof m !== 'object' || Array.isArray(m)) {
      errors.push('skills.occ_related_skills.minimums entries must be objects');
      continue;
    }
    if (m.category !== undefined && m.categories !== undefined) {
      errors.push('skills.occ_related_skills.minimums entries set category or categories, not both');
    }
    if (!Number.isFinite(m.count) || m.count <= 0 || !Number.isInteger(m.count)) {
      errors.push(`skills.occ_related_skills.minimums.count must be a whole number above zero, not "${m.count}"`);
    } else {
      floorTotal += m.count;
    }
    const cats = minimumCategories(m);
    if (!cats.length) {
      errors.push('skills.occ_related_skills.minimums entries need a category or a categories list');
      continue;
    }
    for (const c of cats) {
      if (typeof c !== 'string' || !c.trim()) {
        errors.push('skills.occ_related_skills.minimums categories must be category names');
        continue;
      }
      if (granted.size && !granted.has(normName(c))) {
        errors.push(`skills.occ_related_skills.minimums names ${c}, `
          + 'which is not one of the categories this class allows as a related skill');
      }
    }
  }
  // The floors are spent OUT OF the same count, not on top of it. Two floors of
  // two over eight picks leave four free; two floors of five would leave less
  // than nothing, and the class could not be built at all.
  if (Number.isFinite(related.count) && floorTotal > related.count) {
    errors.push(`skills.occ_related_skills.minimums require ${floorTotal} picks `
      + `but the class grants only ${related.count}`);
  }
}
