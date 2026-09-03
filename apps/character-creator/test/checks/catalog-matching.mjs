// Reading a value off a scanned page, and deciding whether it names a row the
// catalog already holds.
//
// The two halves of the same problem: ocr-fields-lib turns printed text into a
// number, catalog-match-lib decides whether that name is one the catalog has
// under a different spelling. Ten skills already existed under other spellings
// on one import, which is what these guard.
//
// Split out of smoke.mjs unchanged.

import { check, section, wantSection } from '../harness.mjs';
import { aliasCounts, buildIndex, diffCatalog, loose, match, nearest, normalise,
  stem, variants, vocabularyWarnings } from '../../../../scripts/catalog-match-lib.mjs';
import { dice, isMegaDamage, isVariableCost, money, weightLbs } from '../../../../scripts/ocr-fields-lib.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['OCR field readers', 'Catalog matching'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  // ---------- Reading numbers out of OCR ----------
  section('OCR field readers');

  // Every string here was taken verbatim off a page of the cached RUE text. The
  // OCR is CONFIDENT about these misreads - "Ibs" scores 91-94, "18.000" scores
  // 93-97 - so no confidence filter and no amount of DPI would catch them, and a
  // reader that does not know what a price is allowed to look like will believe
  // a rifle costs eighteen credits.

  check('a thousands separator OCRs as a period', money('18.000 credits.') === 18000);
  check('and so does a bigger one', money('1.500.000 credits') === 1500000);
  check('a real comma still works', money('55,000 credits. Good availability.') === 55000);
  check('cr misread as er, after a digit', money('20-100 er.') === 20);
  check('a range yields its LOW end', money('100-200 cr.') === 100);
  check('the low end is the convention gear.cost holds', money('12-25 cr.') === 12);
  check('a metric decimal is not a separator', money('0.9 m') === 0);
  check('unreadable price is null, not zero', money('Varies with availability') === null);

  check('a range is flagged as variable', isVariableCost('100-300 cr.'));
  check('so is a qualifier', isVariableCost('6 credits per 16 ounce can'));
  check('a flat price is not', !isVariableCost('20 cr.'));

  check('Ibs is lbs', weightLbs('5 Ibs (2.25 kg)') === 5);
  check('a lone pipe is a 1', weightLbs('| Ib (0.45 kg)') === 1);
  check('pounds beat the metric conversion', weightLbs('128 lbs (57.6 kg)') === 128);
  check('kg alone converts', Math.abs(weightLbs('20 kg') - 44.09) < 0.05);

  check('bracket misread as a 1', dice('[D4 S.D.C. damage') === '1D4');
  check('a multiplier keeps its x', dice('2D6x10 M.D.') === '2D6x10');
  check('spacing in a multiplier', dice('1D6x 10') === '1D6x10');
  check('prose damage reads as null, not zero', dice('Varies with missile type') === null);

  check('M.D. means mega-damage', isMegaDamage('3D6 M.D.'));
  check('and so does the word', isMegaDamage('2D4 Mega-Damage'));
  check('S.D.C. does not', !isMegaDamage('1D6 S.D.C. damage'));

  // ---------- Catalog name matching ----------
  section('Catalog matching');

  // Every case below is a mistake that shipped or nearly shipped during the RUE
  // import. The matcher exists because the same class of error kept producing
  // confident, wrong answers, so these are pinned rather than remembered.

  check('normalise folds & to and', normalise('Control & Enslave Entity') === 'control and enslave entity');
  check('stem drops a parenthetical', stem('Object Read (Psychometry)') === 'object read');
  check('loose drops connectives', loose('Animate and Control Dead') === 'animate control dead');

  // A catalog shaped like the real one: the pairs that broke things are here.
  const MATCH_ROWS = [
    { name: 'Bio-Regeneration' },              // RUE prints "Bio-Regenerate (self)"
    { name: 'Bio-Regeneration (Super)' },
    { name: 'Telekinesis' },
    { name: 'Telekinesis (Super)' },
    { name: 'Telekinetic Punch' },
    { name: 'Telekinetic Leap' },
    { name: 'Commune with Spirit' },           // RUE prints the plural
    { name: 'Impervious to Poison/Toxin' },    // RUE prints "Impervious to Poison"
    { name: 'Object Read (Psychometry)' },     // RUE prints "Object Read"
    { name: 'Control & Enslave Entity' },      // RUE prints "Control/Enslave Entity"
    { name: 'Animate and Control Dead' },      // RUE prints "Animate/Control Dead"
    { name: 'Power Weapon' },                  // RUE prints the plural
    { name: 'Swim as a Fish (lesser)' },       // three candidates - unresolvable
    { name: 'Swim as a Fish (Superior)' },
    { name: 'Water: Swim as a Fish: Superior' },
  ];
  const MATCH_IDX = buildIndex(MATCH_ROWS);
  const hit = (n, book = []) =>
    match(n, MATCH_IDX, aliasCounts(book.map((x) => ({ name: x }))))?.row?.name ?? null;

  // --- must match: the same thing spelled differently ---
  check('plural on the last word', hit('Commune with Spirits') === 'Commune with Spirit');
  check('plural, other direction', hit('Power Weapons') === 'Power Weapon');
  check('slash half meets the whole', hit('Impervious to Poison') === 'Impervious to Poison/Toxin');
  check('book omits a parenthetical', hit('Object Read') === 'Object Read (Psychometry)');
  check('slash vs ampersand', hit('Control/Enslave Entity') === 'Control & Enslave Entity');
  check('slash vs the word and', hit('Animate/Control Dead') === 'Animate and Control Dead');

  // --- must NOT match: different things that look alike ---
  // These are the expensive direction. Collapsing either pair produced confident
  // "corrections" to rows that were already right.
  const BIO_BOOK = ['Bio-Regenerate (self)', 'Bio-Regeneration (Super)'];
  check('Bio-Regeneration pair stays split',
    hit('Bio-Regeneration (Super)', BIO_BOOK) === 'Bio-Regeneration (Super)');
  const TK_BOOK = ['Telekinesis', 'Telekinesis (Super)'];
  check('Telekinesis exact still wins over its Super sibling',
    hit('Telekinesis', TK_BOOK) === 'Telekinesis');
  check('Telekinesis (Super) does not collapse onto Telekinesis',
    hit('Telekinesis (Super)', TK_BOOK) === 'Telekinesis (Super)');
  check('Push is not Punch', hit('Telekinetic Push') === null);
  check('Lift is not Leap', hit('Telekinetic Lift') === null);

  // Ambiguity on the CATALOG side must refuse too: "Swim as a Fish" has three
  // candidates and picking one is a coin flip.
  check('ambiguous catalog stem refuses to match', hit('Swim as a Fish') === null);

  // nearest() is reporting only, and this is exactly why: the closer pair is the
  // one that must not be merged.
  check('nearest is advisory, not a verdict', (() => {
    const push = nearest('Telekinetic Push', MATCH_IDX);
    const animate = nearest('Animate/Control Dead', MATCH_IDX);
    // Push/Punch is nearer than Animate/Control Dead vs Animate and Control Dead,
    // yet Push must not merge and Animate must.
    return push.distance < animate.distance
        && hit('Telekinetic Push') === null
        && hit('Animate/Control Dead') === 'Animate and Control Dead';
  })());

  check('variants stay small', variants('Commune with Spirits').length <= 4);

  // --- the diff, end to end ---
  check('diffCatalog separates corrections from gaps', (() => {
    const entries = [
      { name: 'Commune with Spirits', isp: 6 },   // present, cost disagrees
      { name: 'Telekinetic Punch', isp: 6 },      // present, agrees
      { name: 'Telekinetic Push', isp: 4 },       // genuinely missing
    ];
    const rows = [
      { name: 'Commune with Spirit', isp: 8 },
      { name: 'Telekinetic Punch', isp: 6 },
    ];
    const d = diffCatalog({
      entries, rows,
      fields: { isp: { book: (e) => e.isp, row: (r) => r.isp } },
    });
    return d.disagree.length === 1 && d.disagree[0].diffs[0].catalog === 8
        && d.matched.length === 1
        && d.missing.length === 1 && d.missing[0].entry.name === 'Telekinetic Push'
        && d.missing[0].nearest.row.name === 'Telekinetic Punch';
  })());

  // A field where nearly every disagreement is the SAME substitution is one
  // vocabulary difference, not N corrections. 22 of 23 reported category errors
  // were the book writing "Super-Psionics" where the catalog says "Super";
  // applying them would have broken every picker that filters on category.
  check('vocabulary difference is flagged, not applied', (() => {
    const rows = [], entries = [];
    for (let i = 0; i < 12; i++) {
      rows.push({ name: `Power ${i}`, category: 'Super' });
      entries.push({ name: `Power ${i}`, category: 'Super-Psionics' });
    }
    const d = diffCatalog({ entries, rows,
      fields: { category: { book: (e) => e.category, row: (r) => r.category } } });
    const w = vocabularyWarnings(d);
    return d.disagree.length === 12 && w.length === 1
        && w[0].from === 'Super-Psionics' && w[0].to === 'Super';
  })());

  // And it must stay quiet for real corrections, which spread across values.
  // The six RUE spell levels were 7->6 three times and 9->8 three times: no
  // single substitution dominates, and every one of them was a genuine fix.
  check('genuine corrections raise no vocabulary warning', (() => {
    const entries = [
      { name: 'Teleport: Lesser', level: 6 }, { name: 'Tongues', level: 6 },
      { name: 'Words of Truth', level: 6 }, { name: 'Sickness', level: 8 },
      { name: 'Spoil', level: 8 }, { name: 'Wisps of Confusion', level: 8 },
    ];
    const rows = entries.map((e) => ({ name: e.name, level: e.level + 1 }));
    const d = diffCatalog({ entries, rows,
      fields: { level: { book: (e) => e.level, row: (r) => r.level } } });
    return d.disagree.length === 6 && vocabularyWarnings(d).length === 0;
  })());

  check('diffCatalog reports catalog rows the book never mentions', (() => {
    const d = diffCatalog({
      entries: [{ name: 'Telekinetic Punch' }],
      rows: [{ name: 'Telekinetic Punch' }, { name: 'Attack Disease' }],
    });
    return d.extra.length === 1 && d.extra[0].name === 'Attack Disease';
  })());
}
