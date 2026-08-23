// The two pure pieces of class-check, split out so the smoke test can call them
// without running the CLI. Everything else in class-check.mjs either talks to
// wrangler or prints, and neither is worth testing.

// ── every top-level frontmatter key the app actually reads ──
// Anything outside this set parses fine and is then ignored by everything: the
// parser stores whatever YAML it finds and only ever looks these up.
//
// Kept as a literal list rather than derived from the parser, because the
// question is not "does the parser touch it" but "does anything downstream act
// on it" — and that answer is spread across parser.js, compose.js, derive.js,
// app.js and sheet.js. A list that has to be updated by hand when a key is
// modelled is the honest shape for that.
export const KNOWN_KEYS = new Set([
  'id', 'name', 'system', 'source_book', 'category',
  'attribute_requirements', 'attribute_dice',
  'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
  'starting_money', 'skills', 'equipment_starting', 'level_progression',
  'psionics', 'magic', 'bonuses', 'special_abilities', 'natural_abilities',
  'restrictions', 'side_effects', 'variants', 'extraction_notes',
  // A race with NO psychic potential. Fully modelled and always has been -
  // `rollsForPsionics()` in js/psionics.js skips the Random Psionics Table on
  // it, the wizard's Race briefing prints "no psychic potential", and the smoke
  // test pins both. It was missing from this list only because no published
  // class had used it: the first six that do are Palladium Fantasy races, and
  // they arrived reported as UNMODELLED. A false alarm here is worse than a
  // missing one, because the instruction attached to it is to delete the key or
  // change the app, and both would break a working field.
  'psionics_allowed',
  // A class's own experience chart, overriding the house-rule default.
  // `xpTableFor()` has honoured it since leveling.js was written, across six
  // call sites, and the smoke test pins the override - it was missing here only
  // because no published class had used one yet. Same false alarm
  // `psionics_allowed` gave, and worse than a missing entry for the same
  // reason: the instruction attached to UNMODELLED is to delete the key or
  // change the app, and both would break a working field.
  'xp_table',
  // Produced by the parser from the body, never written by hand.
  'lore', 'gm_notes', 'sections',
]);

/**
 * Top-level keys nothing in the app reads.
 *
 * This is the signal that a class wants something the app cannot yet express.
 * The Godling's occupation-demanding ability and the Magic Powers block both
 * looked exactly like this first: valid YAML, clean parse, stored fine, and
 * then nothing anywhere acted on them.
 */
export function unmodelledKeys(data) {
  if (!data || typeof data !== 'object') return [];
  return Object.keys(data).filter((k) => !KNOWN_KEYS.has(k));
}

/**
 * Read the class markdown back out of a data script.
 *
 * A class arrives one of two ways: as loose markdown while it is being written,
 * or already wrapped in the INSERT that will ship it. Checking only the first
 * would leave the artifact you actually commit unverified, and the wrapping is
 * exactly where an escaping mistake hides.
 *
 * The stored value is a SQL string expression: single-quoted literals with ''
 * for an embedded quote, optionally concatenated with char(N) calls — which is
 * how a non-ASCII character reaches the database without putting a non-ASCII
 * byte in the file (see d1-apply.mjs's pre-flight).
 *
 * Returns null when the file inserts no class at all; throws when it inserts
 * one this cannot read, because that is a malformed script rather than a
 * different kind of script.
 */
export function extractClassMarkdown(sql) {
  // Both spellings are in use — plain INSERT ... WHERE NOT EXISTS, and
  // INSERT OR IGNORE. Matching only the first silently skipped a real file.
  const m = sql.match(/INSERT\s+(?:OR\s+IGNORE\s+)?INTO\s+imported_classes/i);
  if (!m) return null;

  // The markdown is the literal that opens the frontmatter block. Anchoring on
  // '--- rather than on argument position keeps this working whatever order the
  // columns are listed in.
  const start = sql.indexOf("'---", m.index);
  if (start < 0) {
    throw new Error("found the imported_classes INSERT but no markdown literal starting with '---");
  }

  let i = start;
  let out = '';
  for (;;) {
    if (sql[i] !== "'") throw new Error('unexpected token in the markdown expression at offset ' + i);
    i++;
    for (;;) {
      if (i >= sql.length) throw new Error('unterminated SQL string literal in the markdown');
      if (sql[i] === "'") {
        if (sql[i + 1] === "'") { out += "'"; i += 2; continue; }
        i++; break;
      }
      out += sql[i++];
    }
    // Concatenated onto something else?
    const cont = sql.slice(i).match(/^\s*\|\|\s*/);
    if (!cont) break;
    i += cont[0].length;
    const ch = sql.slice(i).match(/^char\(\s*(\d+)\s*\)/i);
    if (!ch) continue; // another quoted literal — the loop head handles it
    out += String.fromCharCode(Number(ch[1]));
    i += ch[0].length;
    const more = sql.slice(i).match(/^\s*\|\|\s*/);
    if (!more) break;
    i += more[0].length;
  }
  return out;
}

/**
 * Restriction names that resolve to a catalog row in a DIFFERENT category.
 *
 * `class-check` cannot see these through the missing-row check: the name
 * matches a skill, so it stays quiet. But the catalog files each skill under
 * exactly one category while the books file a skill under whichever category a
 * given class spends its pick from. "Espionage: Wilderness Survival only" is an
 * ordinary book line about a Wilderness skill.
 *
 * Three outcomes, and the difference is the whole point of checking:
 *
 *   granted      an `only` naming the skill, AND the class also lists the
 *                skill's real category. categoryAllows admits it, so the
 *                cross-category grant works. Worth showing so it reads as
 *                deliberate rather than as a typo.
 *   unreachable  an `only` naming the skill where the class does NOT list its
 *                real category. categoryAllows is bounded by that, so the
 *                class grants a skill nobody can take. A real defect.
 *   noop         an `except` naming a skill from another category. Excludes
 *                nothing, because nothing was offered there to exclude.
 *
 * Walks the class data itself rather than taking restrictionNames() output,
 * because the bound has to be checked against the SAME skill group the
 * restriction came from - an occ_related_skills entry is not made reachable by
 * a category that only secondary_skills grants.
 *
 * `categoryOf` maps a normalised skill name to its catalog category.
 */
export function crossCategoryRestrictions(data, categoryOf) {
  const norm = (s) => String(s ?? '').trim().toLowerCase();
  const nameOf = (entry) => (typeof entry === 'string' ? entry : entry?.name ?? null);
  const out = { granted: [], unreachable: [], noop: [] };

  for (const group of ['occ_related_skills', 'secondary_skills']) {
    const cats = data?.skills?.[group]?.categories || [];
    const listed = new Set(cats.map((c) => norm(nameOf(c))).filter(Boolean));
    for (const c of cats) {
      if (!c || typeof c !== 'object') continue;
      for (const kind of ['only', 'except']) {
        for (const name of c[kind] || []) {
          const actual = categoryOf.get(norm(name));
          if (actual === undefined) continue;        // no row - the missing-row check owns it
          if (norm(actual) === norm(c.name)) continue;
          const hit = { group, category: c.name, kind, name, actual };
          if (kind === 'except') out.noop.push(hit);
          else if (listed.has(norm(actual))) out.granted.push(hit);
          else out.unreachable.push(hit);
        }
      }
    }
  }
  return out;
}
