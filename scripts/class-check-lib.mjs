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
 * matches a skill, so it stays quiet. But `categoryAllows` filters within a
 * category, and the catalog files each skill under exactly one while the books
 * file a skill under whichever category a given class spends its pick from.
 * "Espionage: Wilderness Survival only" is an ordinary book line about a
 * Wilderness skill.
 *
 * The two kinds are not equally serious, so they are reported separately:
 *
 *   only    the class GRANTS the skill by name, and since categoryAllows
 *           matches an `only` entry by name regardless of category, it works.
 *           Reported so a cross-category grant is visible rather than looking
 *           like a typo.
 *   except  excludes NOTHING, because the skill was never offered in that
 *           category to begin with. A no-op, and usually a sign the class
 *           names a category the catalog disagrees with.
 *
 * `wanted` is the output of catalog.js's restrictionNames(); `categoryOf` maps
 * a normalised skill name to its catalog category.
 */
export function crossCategoryRestrictions(wanted, categoryOf) {
  const norm = (s) => String(s ?? '').trim().toLowerCase();
  const out = { granted: [], noop: [] };
  for (const w of wanted || []) {
    const actual = categoryOf.get(norm(w.name));
    if (actual === undefined) continue;          // no row at all - already reported
    if (norm(actual) === norm(w.category)) continue;
    (w.kind === 'only' ? out.granted : out.noop).push({ ...w, actual });
  }
  return out;
}
