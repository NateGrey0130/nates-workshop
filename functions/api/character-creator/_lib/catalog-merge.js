// Finding and merging duplicate catalog rows.
//
// The importers dedupe on an EXACT name, which is the right default and misses
// a whole class of real duplicate. A single skill chapter produced ten pairs the
// exact match could not see, because the book and the hand-seeded catalog use
// different conventions for the same skill:
//
//   Skin and Prepare Animal Hides  /  Skin & Prepare Animal Hides
//   Lore — Demons and Monsters     /  Lore: Demons & Monsters
//   Mathematics — Basic            /  Basic Math
//   Tracking                       /  Tracking (people)
//
// So: normalise hard, suggest pairs, and let a human confirm each one. Nothing
// here merges anything on its own.
//
// REFERENCES DIFFER BY CATALOG, and that is the part worth reading carefully.
// Skills, spells and psionic powers are referenced BY NAME inside characters'
// JSON columns. Gear is referenced BY SLUG, through character_items.gear_slug -
// it was by id until migration 046, and the id is what made a gear merge a
// straight integer repoint. Merging therefore rewrites JSON for the first three
// and repoints a text key for the last.

import { CATALOGS, getCatalog } from '../../../../apps/character-creator/js/catalog-fields.js';
import { json } from './auth.js';
import { safeParse } from './character-json.js';
import { keysOf, redirectStatements, collapseStatement } from './catalog-redirects.js';

// Internal since resolveCatalog() moved into this file - the two endpoints that
// used to import it now call that instead.
const MERGE_REFS = {
  skills: { kind: 'json', column: 'skills' },
  spells: { kind: 'json', column: 'powers', type: 'spell' },
  psionics: { kind: 'json', column: 'powers', type: 'psionic' },
  // `key` is the column on the CATALOG row whose value the reference stores.
  // For gear that is the slug; before migration 046 the reference stored the
  // id and this branch could bind keepId/removeId directly.
  gear: { kind: 'fk', table: 'character_items', column: 'gear_slug', key: 'slug' },
};

// ─── name normalisation ───

// Everything that differs between two spellings of the same skill and carries
// no meaning: separators, ampersands, and trailing qualifiers like "(people)".
export function normaliseName(name) {
  return String(name ?? '')
    .toLowerCase()
    .replace(/\([^)]*\)/g, ' ')          // drop "(people)", "(self)", "(general)"
    .replace(/&/g, ' and ')
    .replace(/[—–:_/,.]/g, ' ')
    .replace(/[^a-z0-9 ]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// The bracketed qualifiers normaliseName throws away, normalised the same way.
// Two rows whose names differ ONLY inside their brackets are distinguished BY
// those brackets - "Gambling (Standard)" and "Gambling (Dirty Tricks)" are two
// skills on one RUE page at 30% and 20%. INGESTION-AUDIT F27.
export function qualifiers(name) {
  return [...String(name ?? '').matchAll(/\(([^)]*)\)/g)]
    .map((m) => m[1].toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim())
    .filter(Boolean);
}

// True when both names carry a qualifier and the sets differ. One name having
// none is the opposite case - "Law" against "Law (General)" is the bare form
// beside the qualified one, which is what a real duplicate of this shape looks
// like - so that stays confident.
export function qualifiersDisagree(nameA, nameB) {
  const a = qualifiers(nameA), b = qualifiers(nameB);
  if (!a.length || !b.length) return false;
  return a.join('|') !== b.join('|');
}

const STOPWORDS = new Set(['and', 'of', 'the', 'a', 'an']);

function tokens(name) {
  return normaliseName(name).split(' ').filter((t) => t && !STOPWORDS.has(t));
}

// "math" and "mathematics" are the same word for our purposes; "basic" and
// "basics" likewise. Prefix matching from 4 characters catches those without
// collapsing genuinely different short words.
function tokenPairs(a, b) {
  return a === b || (a.length >= 4 && b.length >= 4 && (a.startsWith(b) || b.startsWith(a)));
}

// How alike two names are, 0 to 1. Deliberately generous — a false suggestion
// costs a glance, a missed duplicate costs a wrong catalog.
export function similarity(nameA, nameB) {
  const a = tokens(nameA), b = tokens(nameB);
  if (!a.length || !b.length) return 0;
  if (normaliseName(nameA) === normaliseName(nameB)) return 1;

  // Identical once spacing is ignored, which is as safe as ignoring punctuation
  // — "Back Pack" and "Backpack" are not similar names, they are one name typed
  // two ways. Without this they scored 0.75 and sat in the loosest tier, which
  // is where a real duplicate goes to be ignored.
  if (normaliseName(nameA).replace(/ /g, '') === normaliseName(nameB).replace(/ /g, '')) return 1;

  const [small, large] = a.length <= b.length ? [a, b] : [b, a];
  const used = new Set();
  let matched = 0;
  for (const t of small) {
    const i = large.findIndex((u, idx) => !used.has(idx) && tokenPairs(t, u));
    if (i >= 0) { used.add(i); matched++; }
  }
  if (matched !== small.length) return matched / large.length;

  // Every word of the shorter name appears in the longer one. That is either
  // the same skill written two ways, or a genuine narrowing like
  // "Chemistry" vs "Chemistry Analytical" — hence a score, not a verdict.
  return small.length === large.length ? 0.95 : 0.75;
}

// ─── candidates ───

const THRESHOLD = 0.7;

export async function findDuplicates(env, catalogKey) {
  const cat = CATALOGS[catalogKey];
  const cols = ['id', cat.uniqueField, cat.displayField, ...cat.fields.map((f) => f.name)];
  const { results } = await env.DB.prepare(
    `SELECT ${[...new Set(cols)].join(', ')} FROM ${cat.table} ORDER BY id`
  ).all();

  // Fields whose disagreement is worth showing: the numbers, not the prose.
  const numeric = cat.fields.filter((f) => f.type === 'int' || f.type === 'real').map((f) => f.name);

  // Only pairs that share a token are candidates, and that is exact rather than
  // an approximation. `similarity` returns at least THRESHOLD only when at least
  // one token matched - `matched / large.length` needs `matched >= 1` to clear
  // 0.7 - and `tokenPairs` matches either identical tokens or two tokens of four
  // or more characters where one prefixes the other. Both cases share the first
  // four characters, so bucketing on that key cannot drop a pair the all-pairs
  // walk would have found. INGESTION-AUDIT F29.
  //
  // The walk it replaces was O(n^2): gear is roughly 900 rows, ~404,000 pairs,
  // and the endpoint exceeded the Worker CPU limit and returned 503 every time -
  // including the counts_only request the catalog page fires on every load to
  // badge the button, where the failure was silent and no badge read as no
  // duplicates.
  const bucketKey = (t) => (t.length >= 4 ? t.slice(0, 4) : t);
  const buckets = new Map();
  results.forEach((row, idx) => {
    for (const k of new Set(tokens(row[cat.displayField]).map(bucketKey))) {
      if (!buckets.has(k)) buckets.set(k, []);
      buckets.get(k).push(idx);
    }
  });

  const pairs = [];
  const seen = new Set();
  for (const idxs of buckets.values()) {
    for (let x = 0; x < idxs.length; x++) {
      for (let y = x + 1; y < idxs.length; y++) {
        // i < j preserved, so `a` and `b` keep the order the all-pairs walk gave
        // them and a pair reached through two shared tokens is only built once.
        const i = Math.min(idxs[x], idxs[y]), j = Math.max(idxs[x], idxs[y]);
        const seenKey = i * results.length + j;
        if (seen.has(seenKey)) continue;
        seen.add(seenKey);

      const a = results[i], b = results[j];
      const score = similarity(a[cat.displayField], b[cat.displayField]);
      if (score < THRESHOLD) continue;
      const sameNumbers = numeric.every((f) => a[f] === b[f]);

      // Two rows filed under different categories are not the same row, however
      // alike the names look. normaliseName strips every bracketed qualifier,
      // which is right for "Tracking (people)" and wrong for the psionics
      // chapter: `Telekinesis` is Physical at 3 I.S.P. and `Telekinesis (Super)`
      // is Super at 10, and stripping "(Super)" made them score a perfect 1.
      // Three of eight confident suggestions on that catalog were this.
      //
      // Demoted rather than dropped, because a category can also simply be
      // wrong on one of the rows — which is itself worth a look.
      const clash = a.category && b.category
        && String(a.category).toLowerCase() !== String(b.category).toLowerCase();

      // The same argument one column over. Gear carries `system` and the catalog
      // holds ONE ROW PER BOOK on purpose, because the economies differ: `Large
      // sack` is 3 in Palladium Fantasy and `Large Sack` is 2 in Rifts, and the
      // `-pf` slugs say the split is deliberate. 18 of gear's 34 confident pairs
      // were this. INGESTION-AUDIT F31.
      //
      // `both` is NOT a clash with either specific system: a row offered to
      // everyone and a row offered to one system can genuinely be the same item
      // filed twice, which is the case worth keeping confident. Only two
      // DIFFERENT specific systems are evidence of two different books.
      const specific = (v) => v && String(v).toLowerCase() !== 'both';
      const systemClash = specific(a.system) && specific(b.system)
        && String(a.system).toLowerCase() !== String(b.system).toLowerCase();

      // Same shape as `clash`, for the case a category cannot see: the names
      // are identical once normaliseName drops their brackets, and the brackets
      // are the whole distinction. On gear that is 68 pairs across 36 groups -
      // Acid three ways, Jacket five - all in one category. Demoted rather than
      // dropped, for `clash`'s reason: the pair is still worth a glance.
      const bracketed = qualifiersDisagree(a[cat.displayField], b[cat.displayField]);

      // The other half of the same shape, added by INGESTION-AUDIT F30 after F27
      // got it wrong. F27 kept a BARE name beside a QUALIFIED one confident, on
      // the strength of one instance - `Law` against `Law (General)`, which was a
      // real duplicate. Gear gave 24 counterexamples and no supporting cases:
      // `Plate Armor` against `Plate Armor (Half Suit)`, `Cape` against `(Short)`
      // and `(Long)`, `Tent` against `(One man)`. On a gear catalog that shape is
      // a base item and its variant, which is what a catalog should hold twice.
      //
      // The numbers separate them. 22 of those 24 differ in price - a half suit
      // is 450 against 1000 - and a variant that costs something different is a
      // different product. The two that matched were `Gas Mask` against
      // `Gas Mask (human-size)`, a real duplicate, and `Robe (Heavy)` against
      // `Robe`, a coincidence inside a 20/30/35 clothing set.
      //
      // Stated rather than hidden: this would have demoted `Law` too, whose base
      // was 25 against 35. F28 would have been found in `contains` instead of
      // `certain`. That is the accepted cost.
      const qualifierCount = (n) => qualifiers(n).length;
      const oneSideQualified =
        (qualifierCount(a[cat.displayField]) > 0) !== (qualifierCount(b[cat.displayField]) > 0);
      const variantByNumbers = oneSideQualified && !sameNumbers;

      // The tiers have different precision. `contains` was measured at about
      // 40% on a real catalog. `certain` and `likely` were measured at no false
      // positives, and `certain` no longer holds that: on the skills catalog it
      // offers two pairs and one of them - `Gambling (Standard)` against
      // `Gambling (Dirty Tricks)` - is wrong, which is what `bracketed` above
      // now demotes. Do not restore the old claim without re-measuring it.
      // INGESTION-AUDIT F27.
      const tier = clash || systemClash || bracketed || variantByNumbers ? 'contains'
        : score >= 1 ? 'certain' : score >= 0.9 ? 'likely' : 'contains';
      pairs.push({
        score: Math.round(score * 100) / 100,
        same_numbers: sameNumbers,
        tier,
        category_clash: !!clash,
        system_clash: !!systemClash,
        a, b,
        confidence: clash ? `same name, but filed as ${a.category} and ${b.category} — probably different powers`
          : systemClash ? `same name, but ${a.system} and ${b.system} — one row per book, probably deliberate`
          : bracketed ? 'same name, but the brackets differ — probably two variants, not one row'
          : variantByNumbers ? 'one name is the other plus a qualifier, and the numbers differ — probably a variant'
          : tier === 'certain' ? 'identical once punctuation is ignored'
          : tier === 'likely' ? 'same words, different order or ending'
          : 'one name contains the other — check this one',
      });
      }
    }
  }
  // Strongest first, and identical numbers ahead of differing ones at the same
  // score, because that is the pair you can decide fastest.
  pairs.sort((x, y) => y.score - x.score || Number(y.same_numbers) - Number(x.same_numbers));
  return pairs;
}

// ─── merging ───

// Rewrite one name to another inside a character's JSON column.
function rewriteJson(raw, { column, type }, fromName, toName) {
  const list = safeParse(raw, null);
  if (!Array.isArray(list)) return null;

  let changed = false;
  const out = list.map((entry) => {
    if (!entry || typeof entry !== 'object') return entry;
    if (type && entry.type !== type) return entry;
    if (String(entry.name ?? '').toLowerCase() !== fromName.toLowerCase()) return entry;
    changed = true;
    return { ...entry, name: toName };
  });

  // A character holding BOTH names ends up with the same skill twice, which the
  // validator would then flag. Collapse them, keeping the first.
  const seen = new Set();
  const deduped = out.filter((entry) => {
    if (!entry || typeof entry !== 'object' || !entry.name) return true;
    const key = `${entry.type ?? ''}|${String(entry.name).toLowerCase()}`;
    if (seen.has(key)) { changed = true; return false; }
    seen.add(key);
    return true;
  });

  return changed ? JSON.stringify(deduped) : null;
}

// Which class definitions mention the losing name. Reported, never rewritten:
// class markdown is frontmatter plus prose, and a blind replace would hit lore
// text as readily as a skill list.
// Class definitions reference catalog rows two different ways: skills, spells
// and psionic powers by DISPLAY NAME in prose-ish frontmatter lists, and gear by
// SLUG in equipment_starting[].item_id. Both are checked.
//
// The slug case matters most and was missed at first, because it is the one
// structured reference: after the merge, building a character from that class
// drops the item to a bare custom line, and re-importing the class re-creates
// the very stub the merge just removed.
//
// A redirect now keeps both of those working (see catalog-redirects.js), so
// this list is no longer a repair queue — it is the record of which classes
// still SAY the old key, which is worth knowing but no longer urgent.
export async function classesMentioning(env, terms) {
  const list = [...new Set(terms.filter(Boolean).map(String))];
  if (!list.length) return [];
  const where = list.map(() => 'markdown LIKE ?').join(' OR ');
  const { results } = await env.DB.prepare(
    `SELECT class_id, name FROM imported_classes
     WHERE deleted_at IS NULL AND (${where})`
  ).bind(...list.map((t) => `%${t}%`)).all();
  return results;
}

// Merge `removeId` into `keepId`. Returns a description of everything it did.
export async function mergeRows(env, catalogKey, keepId, removeId) {
  const cat = CATALOGS[catalogKey];
  const ref = MERGE_REFS[catalogKey];
  if (!cat || !ref) return { error: 'Unknown catalog', status: 400 };
  if (keepId === removeId) return { error: 'Cannot merge a row into itself', status: 400 };

  const [keep, remove] = await Promise.all([
    env.DB.prepare(`SELECT * FROM ${cat.table} WHERE id = ?`).bind(keepId).first(),
    env.DB.prepare(`SELECT * FROM ${cat.table} WHERE id = ?`).bind(removeId).first(),
  ]);
  if (!keep || !remove) return { error: 'One of those rows no longer exists', status: 404 };

  const statements = [];
  const repointed = [];

  if (ref.kind === 'fk') {
    // Gear: inventory points at the row by SLUG, so this is a straight repoint
    // of one text key onto another. A character holding both rows keeps both
    // inventory lines, which is correct — two of the same item is a quantity,
    // not a duplicate.
    //
    // Binds keep[ref.key] rather than keepId. Before migration 046 the stored
    // reference WAS the id, so binding the ids was right; it is now a slug, and
    // binding an integer here would match nothing and silently repoint no rows -
    // the merge would appear to succeed and leave every inventory line pointing
    // at the row it just deleted. RETRO-AUDIT R21.
    const keepKey = keep[ref.key], removeKey = remove[ref.key];
    const { results } = await env.DB.prepare(
      `SELECT id FROM ${ref.table} WHERE ${ref.column} = ?`
    ).bind(removeKey).all();
    if (results.length) {
      statements.push(env.DB.prepare(
        `UPDATE ${ref.table} SET ${ref.column} = ? WHERE ${ref.column} = ?`
      ).bind(keepKey, removeKey));
      repointed.push({ table: ref.table, rows: results.length });
    }
  } else {
    // Skills, spells, psionics: referenced by name inside a JSON column.
    const { results } = await env.DB.prepare(
      `SELECT id, name, ${ref.column} AS payload FROM characters`
    ).all();
    for (const row of results) {
      const next = rewriteJson(row.payload, ref, remove[cat.displayField], keep[cat.displayField]);
      if (!next) continue;
      statements.push(env.DB.prepare(
        `UPDATE characters SET ${ref.column} = ?, updated_at = datetime('now') WHERE id = ?`
      ).bind(next, row.id));
      repointed.push({ character_id: row.id, character: row.name });
    }
  }

  // Anything already redirecting to the row about to disappear has to move onto
  // the survivor first, or the chain breaks at the first hop.
  statements.push(collapseStatement(env, catalogKey, removeId, keepId));

  // Leave a forwarding address for the keys the removed row answered to. Class
  // markdown still cites them and is never rewritten by a merge.
  const forwarded = keysOf(cat, remove);
  statements.push(...redirectStatements(env, catalogKey, forwarded, keepId, 'merge', keysOf(cat, keep)));

  statements.push(env.DB.prepare(`DELETE FROM ${cat.table} WHERE id = ?`).bind(removeId));

  // One batch: a repoint that landed without the delete would leave both rows
  // in the catalog with everything pointing at one of them, which is a stranger
  // state than either doing both or doing neither. The redirects belong in it
  // for the same reason — a forwarding address to a row that still exists, or a
  // deleted row with no forwarding address, are both worse than doing nothing.
  await env.DB.batch(statements);

  return {
    ok: true,
    kept: { id: keep.id, name: keep[cat.displayField] },
    removed: { id: remove.id, name: remove[cat.displayField] },
    repointed,
    redirected: forwarded,
    // Advisory: these still reference the removed row and need a human edit in
    // the class importer. Checked for EVERY catalog, by both the display name
    // and the unique key, since classes cite skills by name and gear by slug.
    classes_mentioning: await classesMentioning(env, [
      remove[cat.displayField],
      remove[cat.uniqueField],
    ]),
  };
}

// The `?catalog=` query parameter, validated once. Both admin endpoints that
// take one wrote their own `resolve()` - near-identical, and differing only in
// that one also returned the URLSearchParams it had already built. Returning
// both makes one function serve both callers.
//
// The check is deliberately two-sided: a key must name a catalog the field
// config knows AND one MERGE_REFS can rewrite references for. A catalog added
// to the first without the second would otherwise reach a merge that cannot
// repoint anything that cites it.
export function resolveCatalog(request) {
  const params = new URL(request.url).searchParams;
  const key = params.get('catalog');
  if (!getCatalog(key) || !MERGE_REFS[key]) return { err: json({ error: 'Unknown catalog' }, 400) };
  return { key, params };
}
