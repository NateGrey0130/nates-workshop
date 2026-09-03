// Matching a book's names against the catalog's names.
//
// This is where essentially every wrong answer in the sourcebook imports has
// come from, so the rules are written down once here instead of being
// re-derived — differently, and wrongly — per import.
//
// The scoreboard that produced this file:
//
//   psionics: 21 "missing"        -> 16 real     (5 present under another name)
//   psionics: 23 "wrong category" ->  0 real     (one word of vocabulary)
//   spells:    5 "missing"        ->  0 real
//   gear:    "136 additive"       -> 27 collided
//   skills:  a clean-looking rename broke 69 restriction citations
//
// Two failure modes, opposite directions, both expensive:
//
//   TOO STRICT invents gaps. "Commune with Spirits" and "Commune with Spirit"
//   are one power. Import the "gap" and the catalog gets a duplicate.
//
//   TOO LOOSE invents corrections. RUE prints Bio-Regenerate (self) AND
//   Bio-Regeneration (Super); Telekinesis AND Telekinesis (Super). Strip the
//   parenthetical and each pair collapses onto one catalog row, generating
//   confident "fixes" to rows that were already right.
//
// The rule that survives both: EXACT FIRST. A relaxed match is accepted only
// when it is unambiguous on BOTH sides — one candidate in the book and one in
// the catalog. Anything else is reported for a human, never auto-applied.

// ── normalisation ───────────────────────────────────────────────────────────

/** Lowercase, `&` to `and`, everything else non-alphanumeric to a single space. */
export function normalise(s) {
  return String(s ?? '')
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

/**
 * The same, with parentheticals removed.
 *
 * Needed in both directions: RUE lists plain `Object Read` where the catalog
 * holds `Object Read (Psychometry)`. Dangerous on its own, which is why every
 * use of it below is guarded by an ambiguity check.
 */
export function stem(s) {
  return normalise(String(s ?? '').replace(/\([^)]*\)/g, ' '));
}

/**
 * The stem with connective words dropped.
 *
 * Books punctuate a compound name however they like: RUE writes
 * `Control/Enslave Entity` and `Animate/Control Dead` where the catalog holds
 * `Control & Enslave Entity` and `Animate and Control Dead`. Once `&` becomes
 * `and`, the only remaining difference is a word carrying no meaning.
 *
 * Strictly weaker than `stem`, so like `stem` it is only ever consulted behind
 * an ambiguity check.
 */
export function loose(s) {
  return stem(s).split(' ').filter((w) => w !== 'and' && w !== 'or').join(' ');
}

/**
 * Spellings that mean the same name.
 *
 * Deliberately small. Every entry here is a difference actually observed
 * between a Palladium book and this catalog — a general-purpose fuzzy
 * expansion is how you get Telekinetic Push matched to Telekinetic Punch.
 */
export function variants(s) {
  const base = stem(s);
  const out = new Set([normalise(s), base]);
  // Singular/plural on the last word: "Commune with Spirits" / "…Spirit",
  // "Power Weapons" / "Power Weapon", "Summon & Control Canines" / "…Canine".
  if (base.endsWith('s')) out.add(base.slice(0, -1));
  else out.add(`${base}s`);
  // A slash names two things: "Impervious to Poison/Toxin" should meet
  // "Impervious to Poison". Only SUBSTANTIAL halves - taking every half would
  // register "toxin" as an alias of that power, which is the kind of one-word
  // key that collides with something unrelated later.
  if (String(s ?? '').includes('/')) {
    for (const half of String(s).split('/')) {
      const h = stem(half);
      if (h && h.length * 2 >= base.length) out.add(h);
    }
  }
  // The catalog's CATEGORY PREFIX, dropped: "Air: Tornado" also reads as
  // "Tornado", "W.P. Rope" as "Rope". BOOK-INGEST-AUDIT.md F21.
  //
  // The prefix is a convention of THIS catalog and no book prints it, so a
  // prefixed row was indexed with no bare form and a book printing the bare name
  // could not reach it. Measured over the 374 prefixed rows: 0 found by their
  // own printed name before, 269 after, and 0 rows regressed - `match` consults
  // the exact index first, keyed on `normalise`, where an added alias cannot
  // reach.
  //
  // TWO shapes, because "W.P." carries no colon. Lazy `+?` so a name with two
  // colons loses only the first. ADDED, never substituted: `normalise(s)` and
  // `base` stay in the set, so a row whose full prefixed name IS printed still
  // matches on it.
  //
  // This is the one entry here that is not a difference observed between a book
  // and this catalog. It is a difference the catalog imposes on itself, which is
  // why it is safe where a general fuzzy expansion would not be: anchored at the
  // start, bounded to two shapes, and worth exactly one extra reading.
  const bare = String(s ?? '').replace(/^(?:[A-Za-z .]+?:|W\.P\.)\s*/, '');
  if (bare !== String(s ?? '')) {
    const b = stem(bare);
    if (b) { out.add(b); out.add(loose(bare)); }
  }
  out.add(loose(s));
  return [...out].filter(Boolean);
}

// ── matching ────────────────────────────────────────────────────────────────

/**
 * Index a catalog for matching.
 *
 * Counts are kept per key so ambiguity is detectable: a stem shared by two rows
 * can never be matched on, because picking either one is a coin flip.
 */
export function buildIndex(rows, nameOf = (r) => r.name) {
  const exact = new Map();
  const alias = new Map();
  const aliasCount = new Map();
  for (const row of rows) {
    const n = nameOf(row);
    if (!exact.has(normalise(n))) exact.set(normalise(n), row);
    // Every spelling this row could be written as, each counted so a key two
    // rows share can never be matched on.
    for (const key of new Set(variants(n))) {
      aliasCount.set(key, (aliasCount.get(key) ?? 0) + 1);
      if (!alias.has(key)) alias.set(key, row);
    }
  }
  return { rows, nameOf, exact, alias, aliasCount };
}

/**
 * Find `name` in an index.
 *
 * Returns `{ row, how }` where `how` is 'exact' | 'variant' | null. `how` is
 * worth surfacing: a run with many 'variant' matches is a naming drift worth
 * looking at, not just a successful import.
 *
 * `bookStemCount` is how many entries on the BOOK side share this stem. Pass it
 * and a relaxed match needs to be unambiguous on both sides; omit it and only
 * the catalog side is checked, which is weaker.
 */
export function match(name, index, bookAliasCount) {
  const hit = index.exact.get(normalise(name));
  if (hit) return { row: hit, how: 'exact' };

  // Relaxed keys, weakest last. Each is accepted only when exactly one catalog
  // row AND one book entry claim it.
  for (const key of new Set(variants(name))) {
    if (index.aliasCount.get(key) !== 1) continue;
    if (bookAliasCount && (bookAliasCount.get(key) ?? 1) !== 1) continue;
    return { row: index.alias.get(key), how: 'variant' };
  }
  return { row: null, how: null };
}

/** Count of book-side entries per alias key, for the both-sides check. */
export function aliasCounts(entries, nameOf = (e) => e.name) {
  const m = new Map();
  for (const e of entries) {
    for (const key of new Set(variants(nameOf(e)))) m.set(key, (m.get(key) ?? 0) + 1);
  }
  return m;
}

// `looseCounts` and `stemCounts` stood here, written alongside `aliasCounts`
// for the both-sides ambiguity check and never called by anything - not by
// `diffCatalog`, not by the smoke test, not by any import, from the PR that
// introduced this file to the audit that removed them. `aliasCounts` is what
// the check actually uses. Reviving either is six lines.

// ── near misses, for human eyes only ────────────────────────────────────────

function levenshtein(a, b) {
  const prev = Array.from({ length: b.length + 1 }, (_, j) => j);
  for (let i = 1; i <= a.length; i++) {
    let diag = prev[0];
    prev[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const tmp = prev[j];
      prev[j] = Math.min(prev[j] + 1, prev[j - 1] + 1,
                         diag + (a[i - 1] === b[j - 1] ? 0 : 1));
      diag = tmp;
    }
  }
  return prev[b.length];
}

/**
 * The closest catalog name, with its edit distance.
 *
 * REPORTING ONLY. Never auto-accept this: `Telekinetic Push` and `Telekinetic
 * Punch` are distance 2 and are different powers, while `Animate/Control Dead`
 * and `Animate and Control Dead` are distance 4 and are the same spell. The
 * number tells you where to look, not what to do.
 */
export function nearest(name, index) {
  const target = stem(name);
  let best = null;
  for (const row of index.rows) {
    const d = levenshtein(target, stem(index.nameOf(row)));
    if (!best || d < best.distance) best = { row, distance: d };
  }
  return best;
}

// ── the diff ────────────────────────────────────────────────────────────────

/**
 * Compare a book's entries against a catalog table.
 *
 * `fields` maps a label to `{ book, row, compare? }` accessors, so the caller
 * decides what "disagrees" means. The default comparison is loose equality
 * after String(), because a catalog integer and a parsed string should not
 * count as a disagreement.
 *
 * Returns four buckets:
 *   matched    — found, and every compared field agrees
 *   disagree   — found, but a field differs. These are the corrections.
 *   missing    — not found, with `nearest` filled in for the false-gap check
 *   extra      — catalog rows the book never mentioned
 */
export function diffCatalog({ entries, rows, nameOfEntry = (e) => e.name,
                              nameOfRow = (r) => r.name, fields = {} }) {
  const index = buildIndex(rows, nameOfRow);
  const bookAliases = aliasCounts(entries, nameOfEntry);

  const matched = [], disagree = [], missing = [], seen = new Set();
  for (const entry of entries) {
    const { row, how } = match(nameOfEntry(entry), index, bookAliases);
    if (!row) {
      missing.push({ entry, nearest: nearest(nameOfEntry(entry), index) });
      continue;
    }
    seen.add(row);
    const diffs = [];
    for (const [label, spec] of Object.entries(fields)) {
      const a = spec.book(entry);
      const b = spec.row(row);
      if (a === undefined || a === null || a === '') continue;
      const same = spec.compare ? spec.compare(a, b) : String(a) === String(b);
      if (!same) diffs.push({ field: label, book: a, catalog: b });
    }
    (diffs.length ? disagree : matched).push({ entry, row, how, diffs });
  }
  return { matched, disagree, missing, extra: rows.filter((r) => !seen.has(r)), index };
}

/**
 * Is a "field disagrees everywhere" result really a vocabulary difference?
 *
 * 22 of 23 reported category errors were one word: the book's heading reads
 * "Super-Psionics" where the catalog's vocabulary is "Super". Applied, they
 * would have moved 22 rows to a value nothing else in the app uses and broken
 * every picker that filters on it.
 *
 * The signature is specific and worth detecting rather than remembering: for
 * one field, a large share of matched rows disagree, and the book's values map
 * ONTO the catalog's values many-to-one without crossing. That is a rename, not
 * N corrections.
 *
 * Returns a warning per suspicious field. Advisory - the caller still decides.
 */
export function vocabularyWarnings({ matched, disagree }, { dominance = 0.6, minRows = 5 } = {}) {
  const out = [];
  const total = matched.length + disagree.length;
  if (!total) return out;

  const fields = new Set(disagree.flatMap((d) => d.diffs.map((x) => x.field)));
  for (const field of fields) {
    const hits = disagree.flatMap((d) => d.diffs.filter((x) => x.field === field));
    // Group by the exact substitution. A vocabulary difference shows up as ONE
    // pair accounting for nearly all of a field's disagreements; genuine
    // corrections spread across several.
    const pairs = new Map();
    for (const h of hits) {
      const k = `${h.book} -> ${h.catalog}`;
      pairs.set(k, (pairs.get(k) ?? 0) + 1);
    }
    const [top, count] = [...pairs].sort((a, b) => b[1] - a[1])[0] ?? [];
    if (!top || count < minRows || count / hits.length < dominance) continue;
    const [from, to] = top.split(' -> ');
    out.push({
      field, from, to, count, of: hits.length,
      message: `"${field}": ${count} of ${hits.length} disagreements are the same `
        + `substitution, ${from} -> ${to}. That is one vocabulary difference, not `
        + `${count} corrections — check whether the catalog simply spells this value `
        + `differently before applying any of them.`,
    });
  }
  return out;
}
