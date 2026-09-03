// scripts/class-check.mjs - the reviewer that reads a class back against the
// book it came from. Page-span resolution, field tokens, free-text fields,
// unmodelled keys and the unclosed-flow-scalar trap.
//
// It is a script rather than app code, so nothing else in the suite pins it;
// these checks are the whole guard. Split out of smoke.mjs unchanged.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { appDir, repoRoot, check, section, wantSection } from '../harness.mjs';
import { bestMatchingPages, detectPageOffset, extractClassMarkdown, fieldSourceSpans,
  fieldTokens, freeTextFields, parseSourcePages, resolveBookSlug, unclosedFlowLines,
  unmodelledKeys } from '../../../../scripts/class-check-lib.mjs';
import { SYSTEM_PROMPT_CACHE, buildUserPrompt } from '../../../../scripts/extraction-prompt.mjs';
import { money } from '../../../../scripts/ocr-fields-lib.mjs';
import { parseClassMarkdown } from '../../js/parser.js';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['class-check'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  // ---------- 1e. class-check ----------
  // The CLI validator reads a class back out of its data script. If that
  // extraction drifts from the shape the scripts actually use, the checker
  // silently checks nothing — which is worse than not having it, because a clean
  // run would then be read as a verified class.
  section('class-check');

  const sqlWrap = (md, insert = 'INSERT INTO imported_classes') =>
    `${insert} (class_id, name, system, markdown, status, created_by)\n`
    + `SELECT 'x', 'X', 'rifts', '${md.replace(/'/g, "''")}', 'published', 'data-script'\n`
    + "WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'x');";

  const tinyClass = '---\nid: x\nname: X\nsystem: rifts\nsource_book: B\ncategory: occ\n---\n\n## Lore\n\nA class.\n';

  check('reads the markdown back out of a data script',
    extractClassMarkdown(sqlWrap(tinyClass)) === tinyClass);

  // Both spellings ship. Matching only the plain one skipped add-godling-class.sql
  // entirely, and the checker reported "no class found" rather than checking it.
  check('handles INSERT OR IGNORE as well as plain INSERT',
    extractClassMarkdown(sqlWrap(tinyClass, 'INSERT OR IGNORE INTO imported_classes')) === tinyClass);

  check('unescapes a doubled quote back to one',
    extractClassMarkdown(sqlWrap("---\nid: x\n---\nthe Mystic's power")).includes("the Mystic's power"));

  // A non-ASCII character reaches D1 spliced in with char(N), because the file
  // itself must stay ASCII. Reassembling it is what lets the parser see the real
  // text rather than a broken literal.
  check('reassembles a char(N) splice',
    extractClassMarkdown(
      "INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)\n"
      + "SELECT 'x', 'X', 'rifts', '---' || char(10) || 'id: x' || char(8212) || 'y', 'published', 'd';")
      === '---\nid: x—y');

  check('gear stubs alone are not mistaken for a class',
    extractClassMarkdown("INSERT OR IGNORE INTO gear (slug) VALUES ('x');") === null);

  check('a malformed markdown expression throws rather than returning junk', (() => {
    try {
      extractClassMarkdown('INSERT INTO imported_classes (class_id) SELECT 1;');
      return false;
    } catch { return true; }
  })());

  // The signal that a class wants something the app cannot express yet.
  check('an unmodelled top-level key is reported',
    unmodelledKeys({ id: 'x', name: 'X', elemental_affinity: {} }).join() === 'elemental_affinity');

  // Every shipped class must come back clean. If one does not, KNOWN_KEYS has
  // gone stale and every future run cries wolf.
  const unmodelledOffenders = (() => {
    const dbDir = join(appDir, 'db');
    const out = [];
    for (const f of readdirSync(dbDir).filter((n) => /^add-.*-class[.]sql$/.test(n))) {
      const md = extractClassMarkdown(readFileSync(join(dbDir, f), 'utf8'));
      if (!md) { out.push(f + ' (no class found)'); continue; }
      const keys = unmodelledKeys(parseClassMarkdown(md).data);
      if (keys.length) out.push(`${f}: ${keys.join(', ')}`);
    }
    return out;
  })();
  check('no shipped class reports an unmodelled key', unmodelledOffenders.length === 0,
    unmodelledOffenders.join(' | ') + ' — KNOWN_KEYS in scripts/class-check-lib.mjs is out of date');

  // The parser reads inline [...] / {...} on ONE line only. A flow list wrapped
  // across lines parses the opener as a scalar and fails later with a shape
  // error that points nowhere near the cause — class-check now names the exact
  // line, and these pin what it fires on and, as importantly, what it ignores.
  {
    const md = (...lines) => '---\n' + lines.join('\n') + '\n---\n';
    check('an unclosed flow value is named by line', (() => {
      const hits = unclosedFlowLines(md('id: x', 'skills:', '  occ_skills:',
        '    - { choose: 2, from: [', '      "a", "b"', '    ] }'));
      return hits.length === 1 && hits[0].line === 5;
    })());
    check('a closed one-line flow value is clean',
      unclosedFlowLines(md('id: x', 'from: ["a", "b"]', 'b: { c: 1 }')).length === 0);
    check('a bracket inside a quoted value is not an opener',
      unclosedFlowLines(md('note: "uses [sic] brackets"')).length === 0);
    check('block-scalar prose may carry any bracket it likes',
      unclosedFlowLines(md('extraction_notes: |', '  The book prints [ ranges', '  across lines.')).length === 0);
    check('a bracket after a comment marker is not an opener',
      unclosedFlowLines(md('id: x # todo [check')).length === 0);
    check('a block sequence needs no brackets and is clean',
      unclosedFlowLines(md('from:', '  - "a"', '  - "b"')).length === 0);
  }

  // And the corpus: no shipped class trips it.
  const unclosedOffenders = (() => {
    const dbDir = join(appDir, 'db');
    const out = [];
    for (const f of readdirSync(dbDir).filter((n) => /^add-.*-class[.]sql$/.test(n))) {
      const md = extractClassMarkdown(readFileSync(join(dbDir, f), 'utf8'));
      if (!md) continue;
      const hits = unclosedFlowLines(md);
      if (hits.length) out.push(`${f}: line ${hits.map((h) => h.line).join(', ')}`);
    }
    return out;
  })();
  check('no shipped class leaves a flow value unclosed', unclosedOffenders.length === 0,
    unclosedOffenders.join(' | '));

  // The --field-sources mode: trace a free-text field (starting_money, the
  // equipment prose — the fields nothing else pins) back to the OCR-cache lines
  // it was drawn from. The rule that earns it its place is the page boundary:
  // both shipped starting_money errors were paragraphs that continued past a
  // page break the reading stopped at (PR #280), so a span ending near the
  // bottom of a page must carry the first lines of the page after it.
  {
    const psp = parseSourcePages('Rifts Ultimate Edition p.100-104');
    check('a source_book page range is read out of the title',
      psp !== null && psp.first === 100 && psp.last === 104);
    const one = parseSourcePages('Palladium Fantasy RPG Main Book p.312');
    check('a single page is a one-page range', one !== null && one.first === 312 && one.last === 312);
    // "Uprising" has a p in it; a word-internal p must not read as a page marker.
    check('a title with no page marker is null', parseSourcePages('Rifts World Book 10: Juicer Uprising') === null);

    const books = [{ slug: 'rue', sourcePdf: 'Rifts - Ultimate Edition.pdf' }, { slug: 'pf', sourcePdf: null }, { slug: 'bom', sourcePdf: null }];
    check('a slug resolves as an initialism of the title',
      resolveBookSlug('Rifts Ultimate Edition p.100-104', books) === 'rue'
      && resolveBookSlug('Palladium Fantasy RPG Main Book p.288-289', books) === 'pf'
      && resolveBookSlug('Rifts Book of Magic p.66-70', books) === 'bom');
    check('the manifest PDF name resolves when the initialism does not',
      resolveBookSlug('Ultimate Edition p.1', [{ slug: 'x1', sourcePdf: 'Rifts - Ultimate Edition.pdf' }]) === 'x1');
    check('an ambiguous title is refused, not guessed',
      resolveBookSlug('Rifts Ultimate Edition p.1', [{ slug: 'ru', sourcePdf: null }, { slug: 'ue', sourcePdf: null }]) === null);
    check('a title matching nothing is null', resolveBookSlug('Some Other Book p.5', books) === null);

    // The live near-miss: "Rifts" + "Book" routed fifteen Juicer Uprising
    // classes to the Book of Magic cache, caught only because that cache
    // happened to hold six pages. Words on most of this publisher's covers
    // carry no identity; the overlap route needs one that names the book.
    check('shared generic words do not resolve a book',
      resolveBookSlug('Rifts World Book 10: Juicer Uprising p.41-45',
        [{ slug: 'bom', sourcePdf: '526065744-Rifts-Book-of-Magic.pdf' }, ...books]) === null);
    check('a distinctive shared word still resolves',
      resolveBookSlug('Rifts World Book 10: Juicer Uprising p.41-45',
        [{ slug: 'zz', sourcePdf: 'Rifts - World Book 10 - Juicer Uprising.pdf' }]) === 'zz');
    check('a bare volume number is not a distinctive word',
      resolveBookSlug('Rifts World Book 10: Juicer Uprising p.41',
        [{ slug: 'q1', sourcePdf: 'Rifts World Book 10 New West.pdf' }]) === null);

    // The pf cache is the live case: printed "307" heads the file p309.txt.
    const off = detectPageOffset([
      { page: 309, lines: ['307', '', 'prose'] },
      { page: 310, lines: ['more prose', '', '308'] },
      { page: 311, lines: ['no number on this page at all'] },
    ]);
    check('the printed-page offset is read off the pages themselves',
      off !== null && off.offset === 2 && off.votes === 2 && off.sampled === 2);
    check('a book whose pages show no numbers detects nothing', detectPageOffset([{ page: 5, lines: ['prose only'] }]) === null);

    const fields = freeTextFields({
      starting_money: '2d4x1000',
      equipment_starting: [
        { item_id: 'wooden-arrows', qty: '2d6' },
        { choose: 1, label: 'energy pistol', from: ['ng-33-northern-gun-laser-pistol'] },
      ],
    });
    check('the free-text fields are starting_money and the equipment prose',
      fields.length === 2 && fields[0].field === 'starting_money' && fields[0].value === '2d4x1000'
      && fields[1].value.includes('wooden arrows') && fields[1].value.includes('northern gun laser pistol')
      && fields[1].value.includes('energy pistol'));
    check('a qty is not a search token — a bare number matched prose three paragraphs away',
      !freeTextFields({ equipment_starting: [{ item_id: 'rope', qty: 12 }] })[0].value.includes('12'));
    check('a class with neither field traces nothing', freeTextFields({ id: 'x' }).length === 0);

    const money = fieldTokens('starting_money', '2d4x1000');
    const boundaryPage = {
      page: 41,
      lines: [
        'lore prose that mentions no figures at all', '',
        'Money: 2D4x1,000 in credits', 'to start.', '',
        'filler', 'filler', 'filler',
      ],
    };
    const spans = fieldSourceSpans(money, [boundaryPage], { near: 6, lookup: (n) => (n === 42 ? ['', 'and 1D4x1000 in Black Market items.', 'Cybernetics: none.'] : null) });
    check('the value is found through the OCR comma and grown to its paragraph',
      spans.length === 1 && spans[0].page === 41 && spans[0].start === 3 && spans[0].end === 4
      && spans[0].lines[1] === 'to start.');
    check('a span ending near the page bottom carries the first lines of the next page',
      spans[0].continuation?.page === 42 && spans[0].continuation.lines[0] === 'and 1D4x1000 in Black Market items.');
    check('the next page missing from the cache is still named',
      fieldSourceSpans(money, [boundaryPage], { near: 6, lookup: () => null })[0].continuation?.lines === null);

    const midPage = { page: 50, lines: ['Money: 2d4x1000 credits', ...Array(20).fill('later prose, no figures')] };
    check('a span ending mid-page carries no continuation',
      fieldSourceSpans(money, [midPage], { near: 6, lookup: () => ['x'] })[0].continuation === undefined);

    check('the Money: heading alone is a source line even when OCR ate the figure',
      fieldSourceSpans(fieldTokens('starting_money', '3000'), [midPage], {}).length === 1);
    check('a figure only matches whole — 100 is not the 100 in 1000',
      fieldSourceSpans(fieldTokens('equipment_starting', 'ammo 100'), [{ page: 1, lines: ['costs 1000 credits', 'x', 'x', 'x', 'x', 'x', 'x', 'x'] }], {}).length === 0);

    check('the whole-book hint ranks pages for a wrong offset',
      bestMatchingPages(money, [midPage, boundaryPage, { page: 60, lines: ['nothing'] }]).map((h) => h.page).join() === '41,50');
  }
}
