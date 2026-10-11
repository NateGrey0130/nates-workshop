// Finding two catalog rows that are one thing, and what happens to the row
// that loses: duplicate detection (`_lib/catalog-merge.js`) and the redirects
// that keep a retired key resolving (`_lib/catalog-redirects.js`).
//
// Two sections, adjacent in smoke.mjs and one subject, lifted out whole on
// 2026-10-10. Twelve bindings are used here and nowhere else in the suite -
// all of both modules above, and `normalise` from the match library - which
// is the test `second-body.mjs` passed when it was cut.
//
// The body moved verbatim. `run()` is async because the sections await the
// functions they test, and smoke.mjs awaits it.

import { readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { join } from 'node:path';
import { classesMentioning, findDuplicates, normaliseName, pairKey, qualifiersDisagree, similarity }
  from '../../../../functions/api/character-creator/_lib/catalog-merge.js';
import { collapseStatement, gearJoin, keysOf, redirectStatements, resolveKeys }
  from '../../../../functions/api/character-creator/_lib/catalog-redirects.js';
import { normalise } from '../../../../scripts/catalog-match-lib.mjs';
import { CATALOGS } from '../../js/catalog-fields.js';
import { repoRoot, check, section, wantSection } from '../harness.mjs';

const SECTIONS = ['Duplicate detection', 'Catalog redirects'];

export async function run() {
  if (!SECTIONS.some(wantSection)) return;

// ---------- 1c5. Duplicate detection ----------
// Every pair below is a REAL clash found importing the Rifts skill chapter:
// the book and the hand-seeded catalog name the same skill differently, and
// exact-name dedupe in the importers cannot see any of them.
section('Duplicate detection');
const REAL_CLASHES = [
  ['Skin and Prepare Animal Hides', 'Skin & Prepare Animal Hides'],
  ['Lore — Demons and Monsters', 'Lore: Demons & Monsters'],
  ['Tracking', 'Tracking (people)'],
  ['Mathematics — Basic', 'Basic Math'],
  ['Mathematics — Advanced', 'Advanced Math'],
  ['Laser', 'Laser Communications'],
  ['Horsemanship', 'Horsemanship: General'],
  ['Language', 'Language: Other'],
  ['Track Animals', 'Track & Trap Animals'],
  ['W.P. Archery and Targeting', 'W.P. Archery'],
];
const missed = REAL_CLASHES.filter(([a, b]) => similarity(a, b) < 0.7);
check('every real clash from the Rifts import is detected', missed.length === 0,
  'missed: ' + missed.map((p) => p.join(' / ')).join('; '));

check('punctuation and ampersands normalise away',
  normaliseName('Lore — Demons and Monsters') === normaliseName('Lore: Demons & Monsters'));
check('bracketed qualifiers are ignored',
  normaliseName('Tracking (people)') === normaliseName('Tracking'));
// A DOTTED ACRONYM IS ONE TOKEN. Without this, the separator strip turns
// `A.T.V.` into `a t v`, which can never match the token `atv` - so the
// acronym that makes two names obviously the same machine is the thing that
// stops them scoring. Both pairs below are the SAME vehicle stored twice, and
// both sat under the threshold until 2026-09-09. `BOOK-INGEST-AUDIT` F44.
check('a dotted acronym collapses to one token',
  normaliseName('The Big Boss A.T.V.') === 'the big boss atv');
check('and a real duplicate pair clears the threshold because of it',
  similarity('Big Boss ATV', 'The Big Boss A.T.V.') >= 0.7
  && similarity('Mountaineer ATV', 'The Mountaineer A.T.V.') >= 0.7);
// The guard is TWO OR MORE letters, so an ordinary name is untouched.
check('an unrelated pair is still below the threshold',
  similarity('Mountaineer ATV', "Wilk's ATV Transport Vehicle") < 0.7);
check('an identical pair scores 1', similarity('Skin & Prepare Animal Hides', 'Skin and Prepare Animal Hides') === 1);
// Found in the real gear catalog. These used to score 0.75 and sit in the
// loosest tier — a genuine duplicate filed where genuine duplicates get
// ignored, and below the threshold the duplicate badge counts.
check('names identical but for spacing score 1',
  similarity('Back Pack', 'Backpack') === 1 && similarity('Vibro Blade', 'Vibro-Blade') === 1);
check('collapsing spaces does not merge genuinely different names',
  similarity('Back Pack', 'Backpacking') < 1);
check('a reordered/inflected pair scores in the likely band', (() => {
  const s = similarity('Mathematics — Basic', 'Basic Math');
  return s >= 0.9 && s < 1;
})());
check('a containment pair scores below the likely band', (() => {
  const s = similarity('Laser', 'Laser Communications');
  return s >= 0.7 && s < 0.9;
})());

// INGESTION-AUDIT F27. normaliseName drops brackets, so two rows differing ONLY
// inside them score a perfect 1 and used to land in `certain` - the tier whose
// whole job is to be trusted, because merging repoints every character holding
// the losing name. The category-clash guard cannot see these: both Gambling
// rows are Rogue, and all three Acid rows are magic.
check('two rows differing only inside their brackets disagree',
  qualifiersDisagree('Gambling (Standard)', 'Gambling (Dirty Tricks)')
  && qualifiersDisagree('Acid (cleanser)', 'Acid (organic)')
  && qualifiersDisagree('Arrows (long bow)', 'Arrows (short bow)'));
// The opposite case, and the one that must NOT be demoted: a bare form beside a
// qualified one is what a real duplicate of this shape looks like. `Law` and
// `Law (General)` are one skill, and RUE printed 303 prints the second.
check('a bare name beside a qualified one still reads as one row',
  qualifiersDisagree('Law', 'Law (General)') === false
  && qualifiersDisagree('Tracking (people)', 'Tracking (people)') === false
  && qualifiersDisagree('Back Pack', 'Backpack') === false);
// The scores are untouched: this changes the TIER, never whether a pair is
// reported. A demoted pair still appears under `contains`.
check('demotion does not change the similarity score',
  similarity('Gambling (Standard)', 'Gambling (Dirty Tricks)') === 1
  && similarity('Law', 'Law (General)') === 1);

// Genuinely different skills that share words. These SHOULD score low enough
// to sit in the loosest group rather than looking confident.
for (const [a, b] of [
  ['Chemistry', 'Chemistry — Analytical'],
  ['Demolitions', 'Demolitions Disposal'],
  ['Hand to Hand: Basic', 'Hand to Hand: Expert'],
]) {
  check(`"${a}" vs "${b}" never reaches the confident bands`, similarity(a, b) < 0.9);
}
check('unrelated names do not match at all', similarity('Swimming', 'Sewing') < 0.7);

// Different categories mean different rows, however alike the names look.
// Found importing the Rifts psionics chapter: `Telekinesis` is Physical at
// 3 I.S.P. and `Telekinesis (Super)` is Super at 10, but normaliseName strips
// "(Super)" the same way it strips "(people)", scoring them a perfect 1. Three
// of eight confident suggestions on that catalog were this.
// SQL-aware, because findDuplicates now asks TWO questions: the catalog rows,
// and the pairs a human has already dismissed. A shim that answered both with
// the same list would hand the dismissal filter a set of catalog rows and quietly
// mean nothing — the shape of trap this repo keeps meeting, so the fixture
// distinguishes them rather than the caller remembering to.
const catalogDb = (rows, dismissals = []) => ({
  DB: {
    prepare: (sql) => ({
      bind: () => ({ all: async () => ({ results: /catalog_pair_dismissals/.test(sql) ? dismissals : rows }) }),
      all: async () => ({ results: /catalog_pair_dismissals/.test(sql) ? dismissals : rows }),
    }),
  },
});

// ---------- applies_to is a third identity column (F93) ----------
// `clash` reads `category` and `systemClash` reads `system`. The enchantments
// catalog has NO category column and one system, so neither could ever fire on
// it - and what separates its rows is `applies_to`. Palladium Fantasy prints
// three enchantment lists and repeats names across them at different prices, so
// five of the SIX `certain` suggestions in the whole database were this shape.
//
// A FIXTURE RATHER THAN PRODUCTION, deliberately: the six live pairs were all
// dismissed in PR #1067, and findDuplicates filters dismissed pairs BEFORE it
// computes a tier - so re-running the scan against production shows nothing
// either way and could not tell this change from no change.
{
  const ench = async (rows) => findDuplicates(catalogDb(rows), 'enchantments');

  const glow = await ench([
    { id: 1, slug: 'armor-continual-glow', name: 'Continual Glow', applies_to: 'armor',
      cost: 1200, max_per_item: 4, system: 'palladium-fantasy' },
    { id: 2, slug: 'weapon-continual-glow', name: 'Continual Glow', applies_to: 'weapon',
      cost: 1200, max_per_item: 3, system: 'palladium-fantasy' },
  ]);
  check('a same-name pair differing only in applies_to is demoted', glow.length === 1
    && glow[0].tier === 'contains', JSON.stringify(glow.map((p) => p.tier)));
  check('and it is still SUGGESTED rather than dropped', glow.length === 1);
  check('and the flag says which column did it', glow[0].applies_to_clash === true);

  // The string matters as much as the tier. Without it the pair falls through to
  // "one name contains the other", which is flatly false when the two names are
  // identical - a demotion with no explanation is worse than the confident
  // suggestion it replaced.
  check('and the confidence names both targets rather than the fall-through',
    glow[0].confidence.includes('armor') && glow[0].confidence.includes('weapon')
    && !glow[0].confidence.includes('contains the other'), glow[0].confidence);

  // THE OTHER DIRECTION: two rows with the SAME applies_to must not be demoted
  // by this, or the change would empty a tier it has no business touching.
  const same = await ench([
    { id: 1, slug: 'armor-color', name: 'Color', applies_to: 'armor',
      cost: 600, max_per_item: 4, system: 'palladium-fantasy' },
    { id: 2, slug: 'armor-colour', name: 'Color', applies_to: 'armor',
      cost: 600, max_per_item: 4, system: 'palladium-fantasy' },
  ]);
  check('while two rows sharing an applies_to stay confident',
    same.length === 1 && same[0].tier === 'certain', JSON.stringify(same.map((p) => p.tier)));

  // And a catalog with no applies_to at all is untouched - no other catalog
  // declares the field, so this must be inert everywhere else.
  const gearPairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'a', name: 'Large Sack', system: 'rifts', cost: 2 },
    { id: 2, slug: 'b', name: 'Large Sack', system: 'rifts', cost: 2 },
  ]), 'gear');
  check('a catalog with no applies_to is unaffected',
    gearPairs.length === 1 && gearPairs[0].tier === 'certain'
    && gearPairs[0].applies_to_clash === false);
}


const psiPairs = await findDuplicates(catalogDb([
  { id: 1, name: 'Telekinesis', category: 'Physical', isp: 3 },
  { id: 2, name: 'Telekinesis (Super)', category: 'Super', isp: 10 },
  { id: 3, name: 'Levitation (psionic)', category: 'Physical', isp: 2 },
  { id: 4, name: 'Levitation', category: 'Physical', isp: 2 },
]), 'psionics');
const findPair = (x, y) => psiPairs.find((p) =>
  (p.a.name === x && p.b.name === y) || (p.a.name === y && p.b.name === x));

check('a category clash is demoted out of the confident tiers', (() => {
  const p = findPair('Telekinesis', 'Telekinesis (Super)');
  return p && p.tier === 'contains' && p.category_clash === true;
})());
check('the demoted pair says why', (() => {
  const p = findPair('Telekinesis', 'Telekinesis (Super)');
  return p && /Physical and Super/.test(p.confidence);
})());
check('a real duplicate in one category still reaches certain', (() => {
  const p = findPair('Levitation (psionic)', 'Levitation');
  return p && p.tier === 'certain' && !p.category_clash;
})());
// Demoted, never dropped: the category itself may be the thing that is wrong.
check('a clashing pair is still reported', !!findPair('Telekinesis', 'Telekinesis (Super)'));

check('a missing category on either row is not a clash', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Back Pack', category: null },
    { id: 2, name: 'Backpack', category: 'gear' },
  ]), 'gear');
  return pairs[0]?.tier === 'certain' && !pairs[0].category_clash;
})());

// INGESTION-AUDIT F30. F27 kept a BARE name beside a QUALIFIED one confident on
// the strength of one instance. Gear gave 24 counterexamples - a half suit, a
// long cape, a two-man tent - and the numbers are what separate them: a variant
// that costs something different is a different product.
check('a qualified variant with different numbers is demoted', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'plate-armor', name: 'Plate Armor', system: 'palladium-fantasy', category: 'armor', cost: 1000 },
    { id: 2, slug: 'plate-armor-half', name: 'Plate Armor (Half Suit)', system: 'palladium-fantasy', category: 'armor', cost: 450 },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].tier === 'contains';
})());
// The half that must NOT be demoted, and the reason the rule keys on numbers
// rather than on brackets alone: same price means the qualifier is a spelling of
// one item, not a second product. This pair is a real duplicate.
check('a qualified variant with identical numbers stays confident', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'gas-mask', name: 'Gas Mask', system: 'rifts', category: 'gear', cost: 50 },
    { id: 2, slug: 'gas-mask-human-size', name: 'Gas Mask (human-size)', system: 'rifts', category: 'gear', cost: 50 },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].tier === 'certain';
})());
// RETRO-AUDIT R20 kept `Water: Calm Waters` and `(greater)` as two rows on
// purpose - "the book disambiguates by position and the catalog cannot". The
// duplicate finder used to call them identical. It must not.
check('a pair another finding deliberately kept is not called certain', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Water: Calm Waters', level: 3, ppe: 15, system: 'rifts' },
    { id: 2, name: 'Water: Calm Waters (greater)', level: 8, ppe: 100, system: 'rifts' },
  ]), 'spells');
  return pairs.length === 1 && pairs[0].tier !== 'certain';
})());

// INGESTION-AUDIT F31. Gear holds one row per book on purpose - Large sack is 3
// in Palladium Fantasy and Large Sack is 2 in Rifts - so two DIFFERENT specific
// systems are evidence of two books rather than of one row typed twice. This is
// the category-clash guard beside it, one column over.
check('two different systems demote the pair', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'large-sack', name: 'Large Sack', system: 'rifts', category: 'gear' },
    { id: 2, slug: 'large-sack-pf', name: 'Large sack', system: 'palladium-fantasy', category: 'gear' },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].tier === 'contains' && pairs[0].system_clash === true;
})());
// `both` is deliberately NOT a clash: a row offered to everyone beside a row
// offered to one system can genuinely be the same item filed twice, and that is
// the case worth keeping confident.
check('`both` does not clash with a specific system', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'cape', name: 'Cape', system: 'both', category: 'gear' },
    { id: 2, slug: 'cape-2', name: 'Cape', system: 'palladium-fantasy', category: 'gear' },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].system_clash === false && pairs[0].tier === 'certain';
})());
// And the one real duplicate this guard must not touch: same name, same system.
check('one system on both rows stays confident', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, slug: 'sleeping-bag', name: 'Sleeping Bag', system: 'rifts', category: 'gear' },
    { id: 2, slug: 'sleeping-bag-rifts', name: 'Sleeping Bag', system: 'rifts', category: 'gear' },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].tier === 'certain' && pairs[0].system_clash === false;
})());

// ── a pair somebody already judged DISTINCT ──────────────────────────────────
// BOOK-INGEST-AUDIT F33. The detector was never the missing part; the answer
// had nowhere to go, so every reader re-judged the same pairs. Gear suggests
// 591 and 589 of those are the loosest tier.
const CAPES = [
  { id: 1, slug: 'cape', name: 'Cape', system: 'both', category: 'gear' },
  { id: 2, slug: 'cape-long', name: 'Cape', system: 'both', category: 'gear' },
];
check('a dismissed pair is not suggested again',
  (await findDuplicates(catalogDb(CAPES, [{ key_a: 'cape', key_b: 'cape-long' }]), 'gear')).length === 0);
// The order the panel happened to show is not the order it is stored in: the
// detector walks rows in id order, so a dismissal keyed the way it was
// displayed would stop matching in a rebuilt database.
check('and the stored order does not matter',
  (await findDuplicates(catalogDb(CAPES, [{ key_a: 'cape-long', key_b: 'cape' }]), 'gear')).length === 0);
check('and case does not matter, matching the columns COLLATE NOCASE',
  (await findDuplicates(catalogDb(CAPES, [{ key_a: 'CAPE', key_b: 'Cape-Long' }]), 'gear')).length === 0);
// The half that would make this dangerous: a dismissal must silence ONE pair,
// not the panel. A filter keyed on either row alone would hide every pair that
// row is in, and the row with the most suggestions is the one most worth
// reading.
check('dismissing one pair leaves that row\'s OTHER pairs alone', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    ...CAPES, { id: 3, slug: 'cape-short', name: 'Cape', system: 'both', category: 'gear' },
  ], [{ key_a: 'cape', key_b: 'cape-long' }]), 'gear');
  const slugs = pairs.map((p) => [p.a.slug, p.b.slug].sort().join('|')).sort();
  return pairs.length === 2 && slugs.join(' ') === 'cape-long|cape-short cape|cape-short';
})());
check('a dismissal naming a row that no longer exists is inert', await (async () => {
  const pairs = await findDuplicates(catalogDb(CAPES,
    [{ key_a: 'cape', key_b: 'a-row-that-was-merged-away' }]), 'gear');
  return pairs.length === 1;
})());
// pairKey is the identity both halves agree on - the writer sorts on the way in
// so the stored row is canonical, and the reader sorts so a mis-sorted row
// still matches. Pinned directly because everything above depends on it.
check('pairKey is order- and case-independent',
  pairKey('b', 'a') === pairKey('a', 'b') && pairKey('A', 'B') === pairKey('b', 'a'));

// INGESTION-AUDIT F29. The all-pairs walk became a token-prefix index, and the
// risk of an index is a pair it never compares. These are the three shapes that
// reach THRESHOLD without sharing a whole token, so if the bucket key is ever
// narrowed they are what goes quiet - and a missed pair is invisible, because
// the endpoint simply reports one fewer suggestion.
// `Math` and `Mathematics` share NO exact token - the pair exists only because
// tokenPairs prefix-matches from four characters - so an index keyed on whole
// tokens loses it. Chosen deliberately over `Mathematics - Basic` / `Basic
// Math`, which survives an exact-token index by sharing `basic` and therefore
// pins nothing about prefixes.
check('the index still finds a pair that matches ONLY by prefix', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Math', category: null },
    { id: 2, name: 'Mathematics', category: null },
  ]), 'skills');
  return pairs.length === 1 && pairs[0].score >= 0.7;
})());
check('the index still finds a pair that differs only by spacing', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Back Pack', category: 'gear' },
    { id: 2, name: 'Backpack', category: 'gear' },
  ]), 'gear');
  return pairs.length === 1 && pairs[0].score === 1;
})());
check('the index still finds a containment pair', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Laser', category: null },
    { id: 2, name: 'Laser Communications', category: null },
  ]), 'skills');
  return pairs.length === 1 && pairs[0].tier === 'contains';
})());
// The other half: rows sharing no token must not become candidates. This is
// what stops the index quietly widening into the walk it replaced.
check('rows sharing no token produce no pair', await (async () => {
  const pairs = await findDuplicates(catalogDb([
    { id: 1, name: 'Climbing', category: null },
    { id: 2, name: 'Astronomy', category: null },
    { id: 3, name: 'Barter', category: null },
  ]), 'skills');
  return pairs.length === 0;
})());

// Class definitions cite skills by display name and gear by SLUG. A gear merge
// that only checked the name reported nothing, so a character built from that
// class afterwards would re-create the very stub the merge removed.
check('class-mention lookup searches every supplied term', await (async () => {
  const asked = [];
  const db = { prepare: (sql) => ({ bind: (...t) => { asked.push({ sql, t }); return { all: async () => ({ results: [] }) }; } }) };
  await classesMentioning({ DB: db }, ['Ja 11 Energy Rifle', 'ja-11-energy-rifle']);
  const { sql, t } = asked[0];
  return (sql.match(/markdown LIKE \?/g) || []).length === 2
      && t.includes('%ja-11-energy-rifle%') && t.includes('%Ja 11 Energy Rifle%');
})());
check('class-mention lookup skips blank terms', await (async () => {
  let called = false;
  const db = { prepare: () => { called = true; return { bind: () => ({ all: async () => ({ results: [] }) }) }; } };
  const out = await classesMentioning({ DB: db }, [null, undefined, '']);
  return out.length === 0 && !called;
})());

// ---------- 1c6. Catalog redirects ----------
// A merge deletes a row that class markdown may still cite by slug or by name.
// The redirect is what keeps that citation resolving, so the cases that matter
// are the ones where it must NOT be written: a key the surviving row already
// answers to would shadow a live key with a forwarding address.
section('Catalog redirects');

// ── the inventory join survives a gear RENAME — RETRO-AUDIT R21 ──
//
// Keying inventory on the slug bought portability and cost something the id
// gave for free: a gear row's slug can be RENAMED by an admin
// (`catalogs/rows.js`, which files a 'rename' redirect), and twenty renames
// have already happened on skills. Held by id, a rename could not reach the
// inventory. Held by slug it would orphan every row - the LEFT JOIN yields
// NULL and the sheet renders a bare custom line - unless the read falls
// through `catalog_redirects`.
//
// Proved on an in-memory database rather than against the real one, so it
// can assert the FAILING direction too: the plain join really does lose the
// row, which is the only reason to believe the redirect arm is doing work.
{
  const mem = new DatabaseSync(':memory:');
  mem.exec(`CREATE TABLE gear (id INTEGER PRIMARY KEY, slug TEXT UNIQUE, name TEXT);
    CREATE TABLE character_items (id INTEGER PRIMARY KEY, gear_slug TEXT);
    CREATE TABLE catalog_redirects (catalog TEXT, from_key TEXT, to_id INTEGER, reason TEXT);
    INSERT INTO gear VALUES (7, 'long-sword', 'Long Sword');
    INSERT INTO character_items VALUES (1, 'long-sword');`);

  // THE JOIN THAT SHIPS (2026-10-10). This block ran against its own typed copy
  // of the join, which still carried an arm for a column migration 046 dropped -
  // so it proved a query nothing served. gearJoin() is what the sheet, the stash
  // and the campaign's question-answering all interpolate now.
  const resolved = (alias) => mem.prepare(
    `SELECT ${alias}.name AS item_name FROM character_items ci
     ${gearJoin('ci.gear_slug', alias)}
     WHERE ci.id = 1`).get()?.item_name ?? null;
  const plain = () => mem.prepare(
    `SELECT g.name AS item_name FROM character_items ci
     LEFT JOIN gear g ON g.slug = ci.gear_slug WHERE ci.id = 1`).get()?.item_name ?? null;

  check('the inventory join resolves an unrenamed slug', resolved('g') === 'Long Sword');
  check('and under the gear table\'s own name, as the sheet writes it',
    mem.prepare(`SELECT gear.name AS n FROM character_items
      ${gearJoin('character_items.gear_slug')} WHERE character_items.id = 1`).get()?.n === 'Long Sword');

  mem.exec(`UPDATE gear SET slug = 'sword-long' WHERE id = 7;
    INSERT INTO catalog_redirects VALUES ('gear', 'long-sword', 7, 'rename');`);
  check('a plain slug join LOSES the row after a rename', plain() === null);
  check('and the redirect arm still resolves it', resolved('g') === 'Long Sword');
  mem.close();

  // Every read of an inventory row's gear goes through it.
  const fnRoot = join(repoRoot, 'functions/api/character-creator');
  for (const [rel, call] of [['characters/[id].js', "gearJoin('character_items.gear_slug')"],
    ['campaigns/[id]/items.js', "gearJoin('ci.gear_slug', 'g')"], ['campaigns/[id]/ask.js', "gearJoin('ci.gear_slug', 'g')"]]) {
    const text = readFileSync(join(fnRoot, rel), 'utf8');
    check(`${rel} joins gear through gearJoin`, text.includes('${' + call + '}') && !/LEFT JOIN catalog_redirects/.test(text));
  }

  // The same handler, and the request every sheet opens with. It awaited ten
  // independent reads one after another; they are one round now, and a read
  // added back in sequence should be a decision, not an accident.
  {
    const whole = readFileSync(join(fnRoot, 'characters/[id].js'), 'utf8');
    const get = whole.slice(whole.indexOf('export async function onRequestGet'), whole.indexOf('export async function onRequestPatch'));
    check('the sheet handler is found', get.length > 2000, `${get.length}`);
    const round = get.match(/= await Promise\.all\(\[\s+itemsRead, vehiclesRead,[\s\S]*?\n  \]\);/)?.[0] || '';
    const together = ['listPending(env, params.id)', 'listPendingPowers(env, params.id)', 'listGrants(env, params.id)',
      'getStored(env, character.class_id)', 'getStored(env, character.occ_class_id)', 'loadSkillBonuses(env, character)',
      'loadTotem(env, character.totem)', 'loadPowerDescriptions(env, character.powers)'];
    const apart = together.filter((c) => !round.includes(c));
    check('the sheet\'s independent reads are asked for in one round', round.length > 0 && apart.length === 0, apart.join(', '));
    check('and none of them is awaited on its own', !together.some((c) => get.includes(`await ${c}`)));
    check('the character is decoded before the reads that use its decoded lists',
      get.indexOf('decodeCharacter(character);') > 0 && get.indexOf('decodeCharacter(character);') < get.indexOf(round)
      && (get.match(/decodeCharacter\(character\);/g) || []).length === 1);
    const awaits = (get.match(/\bawait\b/g) || []).length;
    check('four waits remain: the character, the round, the vehicle parts, the trait rows', awaits === 4, `${awaits}`);
  }
}


const capturingDb = (results = []) => ({
  DB: { prepare: (sql) => ({ bind: (...args) => ({ sql, args, all: async () => ({ results }) }) }) },
});

check('gear answers to both its slug and its name',
  keysOf(CATALOGS.gear, { slug: 'ja-11-energy-rifle', name: 'JA-11 Energy Rifle' }).length === 2);
check('a name-keyed catalog yields one key, not the same one twice',
  keysOf(CATALOGS.skills, { name: 'Track Animals' }).length === 1);

check('one redirect is filed per retired key', (() => {
  const s = redirectStatements(capturingDb(), 'gear', ['ja-11-energy-rifle', 'JA-11 Energy Rifle'], 7, 'merge');
  return s.length === 2
    && s[0].args[0] === 'gear' && s[0].args[1] === 'ja-11-energy-rifle'
    && s[0].args[2] === 7 && s[0].args[3] === 'merge';
})());

// Merging two rows whose names differ only by case would otherwise file a
// redirect that shadows the very key it points at.
check('a key the survivor already answers to is never redirected', (() => {
  const s = redirectStatements(capturingDb(), 'skills', ['Track Animals'], 7, 'merge', ['TRACK ANIMALS']);
  return s.length === 0;
})());
check('blank keys file nothing', redirectStatements(capturingDb(), 'gear', [null, '', undefined], 7, 'merge').length === 0);

check('collapsing points existing redirects at the survivor', (() => {
  const s = collapseStatement(capturingDb(), 'gear', 4, 7);
  return s.args[0] === 7 && s.args[1] === 'gear' && s.args[2] === 4;
})());

check('resolving returns a case-insensitive key map', await (async () => {
  const map = await resolveKeys(capturingDb([{ from_key: 'JA-11-Energy-Rifle', to_id: 7 }]),
    'gear', ['ja-11-energy-rifle']);
  return map.get('ja-11-energy-rifle') === 7;
})());
check('resolving an empty list never touches the database', await (async () => {
  let called = false;
  const db = { DB: { prepare: () => { called = true; return { bind: () => ({ all: async () => ({ results: [] }) }) }; } } };
  const map = await resolveKeys(db, 'gear', []);
  return map.size === 0 && !called;
})());

}
