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
  // Which of the book's five groupings an O.C.C. belongs to, and which
  // occupations a race may take. Both are modelled and validated in
  // parser.js; a race's restrictions were free text and display-only until
  // the structured field landed beside them.
  'occ_group', 'occ_restrictions',
  // The mirror: which races may take an O.C.C. "none" is the human case,
  // because Rifts prints no Human R.C.C.
  'race_restrictions',
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
 * Frontmatter lines that open an inline `[...]` or `{...}` and never close it
 * on the same line.
 *
 * The YAML subset in parser.js reads flow sequences and inline maps on ONE
 * line only. A list wrapped across lines —
 *
 *   from: [
 *     "a", "b"
 *   ]
 *
 * — parses the `[` as a scalar string and the following lines as structure, so
 * the failure surfaces later as a shape error ("equipment_starting entries
 * must be objects") that points nowhere near the cause. That loop has cost
 * real transcription sessions; this names the exact line instead.
 *
 * Comment stripping and quote handling mirror the parser's own rules, and
 * block-scalar bodies (`key: |` / `key: >`) are skipped entirely — sourcebook
 * prose may carry any bracket it likes. A warning, not an error: the accepted
 * rewrites are one (arbitrarily long) line, or a block sequence under the key.
 */
export function unclosedFlowLines(markdown) {
  const text = String(markdown ?? '');
  const fm = text.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  if (!fm) return [];
  const lines = fm[1].split(/\r?\n/);
  const out = [];
  let skipIndent = null; // inside a block-scalar body: skip deeper lines
  for (let idx = 0; idx < lines.length; idx++) {
    const raw = lines[idx];
    if (!raw.trim()) continue;
    const indent = raw.length - raw.trimStart().length;
    if (skipIndent !== null) {
      if (indent > skipIndent) continue;
      skipIndent = null;
    }
    // Strip a comment, respecting quotes — the same rule stripComment applies.
    let inQuote = null;
    let line = raw;
    for (let i = 0; i < raw.length; i++) {
      const ch = raw[i];
      if (inQuote) {
        if (ch === inQuote) inQuote = null;
      } else if (ch === '"' || ch === "'") {
        inQuote = ch;
      } else if (ch === '#' && (i === 0 || raw[i - 1] === ' ' || raw[i - 1] === '\t')) {
        line = raw.slice(0, i);
        break;
      }
    }
    const t = line.trim();
    if (!t) continue;
    // A `key: |` / `key: >` value starts a block scalar; its body is prose.
    if (/^(?:-\s+)?[^:]+:\s*[|>][-+]?\d*\s*$/.test(t)) { skipIndent = indent; continue; }
    // Bracket balance outside quotes. Positive at end of line = left open.
    let depth = 0;
    inQuote = null;
    for (const ch of t) {
      if (inQuote) {
        if (ch === inQuote) inQuote = null;
      } else if (ch === '"' || ch === "'") {
        inQuote = ch;
      } else if (ch === '[' || ch === '{') {
        depth++;
      } else if (ch === ']' || ch === '}') {
        depth--;
      }
    }
    // idx is 0-based inside the frontmatter; +2 restores the file's own
    // numbering (1-based, plus the opening `---` line).
    if (depth > 0) out.push({ line: idx + 2, text: t.length > 80 ? t.slice(0, 77) + '...' : t });
  }
  return out;
}

// ── field sources ──
// The free-text fields (`starting_money`, `equipment_starting`) are the fields
// no test pins, and the two on-record transcription errors were both a value
// read from a paragraph that continued past a page break (fixed in PR #280).
// These functions locate a field's value in the page-addressed OCR cache under
// .cache/books/<slug>/txt/ so class-check can print the lines a value was
// drawn from — and, when the source span ends near the bottom of its page,
// the first lines of the following page, which is where the missing half of a
// broken paragraph lives. Pure text against text: the CLI does the file I/O.

/**
 * The printed page range out of a `source_book` line —
 * "Rifts Ultimate Edition p.100-104" → { first: 100, last: 104 }.
 * A single page reads as a one-page range; no `p.N` at all is null.
 */
export function parseSourcePages(sourceBook) {
  const m = String(sourceBook ?? '').match(/\bp\.?\s*(\d+)(?:\s*-\s*(\d+))?/i);
  if (!m) return null;
  const a = Number(m[1]);
  const b = m[2] ? Number(m[2]) : a;
  return a <= b ? { first: a, last: b } : { first: b, last: a };
}

/**
 * Which cached book a `source_book` title means.
 *
 * `books` is [{ slug, sourcePdf }] — the directories under .cache/books plus
 * whatever their manifests name as the source PDF. Two deterministic routes:
 * the slug as an initialism of consecutive title words ("rue" in "Rifts
 * Ultimate Edition", "pf" in "Palladium Fantasy RPG Main Book"), and word
 * overlap with the manifest's PDF name. Returns the unique best match, or
 * null — a tie is refused rather than guessed, and the CLI asks for --book.
 *
 * The overlap route needs at least one word that actually names the book.
 * Words this publisher stamps on most covers carry no identity — "Rifts" and
 * "Book" together routed a Juicer Uprising class to the Book of Magic cache,
 * caught only because that cache happened to hold six pages — and a bare
 * volume number ("World Book 10") is no better, since every line of the
 * series has one.
 */
const GENERIC_TITLE_WORDS = new Set([
  'rifts', 'palladium', 'book', 'books', 'world', 'rpg', 'main', 'edition',
  'of', 'the', 'and',
]);

export function resolveBookSlug(sourceBook, books) {
  const title = String(sourceBook ?? '').replace(/\bp\.?\s*\d+(?:\s*-\s*\d+)?/i, '');
  const wordsOf = (s) => (String(s ?? '').toLowerCase().match(/[a-z0-9]+/g) || []);
  const titleWords = wordsOf(title);
  const titleSet = new Set(titleWords);
  const initials = titleWords.map((w) => w[0]).join('');

  let best = null;
  let tied = false;
  for (const { slug, sourcePdf } of books) {
    let score = 0;
    if (slug && initials.includes(String(slug).toLowerCase())) score = 3 + slug.length;
    const shared = [...new Set(wordsOf(sourcePdf))].filter((w) => titleSet.has(w));
    const distinctive = shared.filter((w) => !GENERIC_TITLE_WORDS.has(w) && !/^\d+$/.test(w));
    if (shared.length >= 2 && distinctive.length >= 1) score = Math.max(score, shared.length);
    if (!score) continue;
    if (!best || score > best.score) { best = { slug, score }; tied = false; }
    else if (score === best.score) tied = true;
  }
  return best && !tied ? best.slug : null;
}

/**
 * The printed-page → PDF-page offset, read off the pages themselves.
 *
 * OCR'd pages usually carry their printed page number as a bare integer near
 * the top or bottom — the pf cache prints "307" at the head of p309.txt, an
 * offset of +2 that would otherwise send every p.N lookup two pages early.
 * One vote per page (pdf page minus printed number, implausible gaps
 * discarded), majority wins; ties go to the offset nearest zero. Returns
 * { offset, votes, sampled } or null when no page shows a number — the caller
 * decides how many votes it takes to act on.
 */
export function detectPageOffset(pages) {
  const votes = new Map();
  let sampled = 0;
  for (const { page, lines } of pages) {
    const nonblank = lines.map((l) => l.trim()).filter(Boolean);
    for (const t of [...nonblank.slice(0, 5), ...nonblank.slice(-5)]) {
      const m = t.match(/^(\d{1,4})$/);
      if (!m) continue;
      const off = page - Number(m[1]);
      if (Math.abs(off) > 40) continue;
      votes.set(off, (votes.get(off) ?? 0) + 1);
      sampled++;
      break;
    }
  }
  let best = null;
  for (const [offset, n] of votes) {
    if (!best || n > best.votes
      || (n === best.votes && Math.abs(offset) < Math.abs(best.offset))) {
      best = { offset, votes: n };
    }
  }
  return best ? { ...best, sampled } : null;
}

/**
 * The free-text fields of a parsed class worth tracing to the page.
 *
 * Exactly the fields no test pins: `starting_money`, and the equipment list
 * flattened to prose (slugs de-hyphenated, choice labels and options
 * included) so its words can be looked for in the book's own equipment
 * paragraph.
 */
export function freeTextFields(data) {
  const out = [];
  if (data?.starting_money != null && String(data.starting_money).trim() !== '') {
    out.push({ field: 'starting_money', value: String(data.starting_money) });
  }
  const eq = data?.equipment_starting;
  if (Array.isArray(eq) && eq.length) {
    const parts = [];
    for (const e of eq) {
      if (typeof e === 'string') { parts.push(e); continue; }
      if (!e || typeof e !== 'object') continue;
      // qty stays out on purpose: the books word quantities ("a dozen pair"),
      // and a bare "12" matched level-progression prose three paragraphs away.
      if (e.item_id) parts.push(String(e.item_id).replace(/-/g, ' '));
      if (e.label) parts.push(String(e.label));
      for (const f of e.from || []) parts.push(String(f).replace(/-/g, ' '));
    }
    if (parts.length) out.push({ field: 'equipment_starting', value: parts.join(' ') });
  }
  return out;
}

const FIELD_ANCHORS = {
  // The books head these paragraphs "Money:" / "Standard Equipment:", and the
  // heading is worth finding even when OCR mangled the value beside it — the
  // paragraph is the source whether or not the number in it survived.
  starting_money: /^\W*(?:starting\s+)?money\b/i,
  equipment_starting: /^\W*(?:standard\s+|starting\s+)?equipment\b/i,
};

const STOP_WORDS = new Set(['with', 'from', 'and', 'the', 'each', 'item', 'items', 'plus', 'worth']);

const normalizeLine = (s) => String(s).toLowerCase()
  .replace(/(\d),(?=\d)/g, '$1')   // "3,000" and "3000" are the same figure
  .replace(/\s+/g, ' ');

const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/**
 * What to look for on the page: numeric/dice tokens ("2d4x1000", "3000" —
 * two-digit figures only when nothing longer exists, they match too much),
 * words of four letters and up, and the field's paragraph-heading anchor.
 */
export function fieldTokens(field, value) {
  const v = normalizeLine(value);
  const rawNums = v.match(/\d[\dxd.+]*/g) || [];
  const cleaned = rawNums.map((t) => t.replace(/[.+]+$/, ''));
  let nums = cleaned.filter((t) => t.length >= 3 || /d/.test(t));
  if (!nums.length) nums = cleaned.filter((t) => t.length === 2);
  const words = (v.match(/[a-z][a-z']{3,}/g) || []).filter((w) => !STOP_WORDS.has(w));
  return { nums: new Set(nums), words: new Set(words), anchor: FIELD_ANCHORS[field] ?? null };
}

// A token only counts against whole figures: "100" must not match the "1000"
// in "2D4x1000". Anchors score like a number because the heading alone is a
// source line; words are weak evidence and only add up.
function lineScore(tokens, rawLine) {
  const line = normalizeLine(rawLine);
  let score = 0;
  for (const n of tokens.nums) {
    if (new RegExp(`(?<!\\d)${escapeRe(n)}(?!\\d)`).test(line)) score += 3;
  }
  for (const w of tokens.words) if (line.includes(w)) score += 1;
  if (tokens.anchor && tokens.anchor.test(rawLine)) score += 3;
  return score;
}

/**
 * Where on the page a field's value came from.
 *
 * `pages` is the window to search, [{ page, lines }] in PDF numbering. Each
 * matching line is grown to its paragraph (blank-line bounded, capped), and
 * whenever a span ends within `near` lines of the bottom of its page the
 * result carries the first `follow` lines of the following page — fetched via
 * `lookup(pageNo)`, which returns that page's lines or null. A continuation
 * with `lines: null` still names the page: the span reaches the boundary and
 * the cache has nothing to show, which is itself worth seeing.
 */
export function fieldSourceSpans(tokens, pages, { near = 6, follow = 10, threshold = 3, lookup = null } = {}) {
  const spans = [];
  for (const { page, lines } of pages) {
    const scores = lines.map((l) => lineScore(tokens, l));
    const groups = [];
    scores.forEach((s, i) => {
      if (s < threshold) return;
      const g = groups[groups.length - 1];
      if (g && i - g.end <= 3) { g.end = i; g.score += s; }
      else groups.push({ start: i, end: i, score: s });
    });
    // Grow each group to its paragraph, then merge the overlaps the growth made.
    const grown = groups.map((g) => {
      let start = g.start;
      for (let k = 0; k < 4 && start > 0 && lines[start - 1].trim(); k++) start--;
      let end = g.end;
      for (let k = 0; k < 12 && end < lines.length - 1 && lines[end + 1].trim(); k++) end++;
      return { start, end, score: g.score };
    });
    const merged = [];
    for (const g of grown) {
      const m = merged[merged.length - 1];
      if (m && g.start <= m.end + 1) { m.end = Math.max(m.end, g.end); m.score += g.score; }
      else merged.push({ ...g });
    }
    for (const g of merged) {
      const span = {
        page,
        start: g.start + 1,
        end: g.end + 1,
        score: g.score,
        lines: lines.slice(g.start, g.end + 1),
      };
      if (lines.length - (g.end + 1) <= near) {
        const next = lookup ? lookup(page + 1) : null;
        if (next) {
          let i = 0;
          while (i < next.length && !next[i].trim()) i++;
          span.continuation = { page: page + 1, lines: next.slice(i, i + follow) };
        } else {
          span.continuation = { page: page + 1, lines: null };
        }
      }
      spans.push(span);
    }
  }
  spans.sort((a, b) => b.score - a.score || a.page - b.page || a.start - b.start);
  return spans;
}

/**
 * The strongest-scoring pages anywhere in the book — the hint printed when
 * the stated range matches nothing, which is what a wrong page offset looks
 * like from inside the window.
 */
export function bestMatchingPages(tokens, pages, top = 3) {
  return pages
    .map(({ page, lines }) => ({ page, score: lines.reduce((s, l) => s + lineScore(tokens, l), 0) }))
    .filter((p) => p.score > 0)
    .sort((a, b) => b.score - a.score || a.page - b.page)
    .slice(0, top);
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
