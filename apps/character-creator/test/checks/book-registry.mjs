// The book registry: titles, spellings, slugs, printed-page offsets, and the
// source-coverage summary built on them.
//
// Against a FIXTURE, deliberately - a test that read the live vocabulary would
// pass on a machine whose database happens to be missing the rows it is about.
// That reasoning belongs to these checks and moved with them.
//
// Split out of smoke.mjs unchanged.

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { repoRoot, check, section, wantSection } from '../harness.mjs';
import { bookSpellings, bookTitles, cacheCoverage, loadBookRegistry, loadNotBooks } from '../../../../scripts/books-lib.mjs';
import { detectPageOffset, detectPageOffsetRegions, isNotABook, normalizeBookTitle,
  offsetForPrintedPage, registryBookSlug, resolveBookSlug } from '../../../../scripts/class-check-lib.mjs';
import { buildUserPrompt } from '../../../../scripts/extraction-prompt.mjs';
import { bucketFor, summarise, summariseValues, valuePresent, valueSpellings } from '../../../../scripts/source-coverage-lib.mjs';

// Declared so a --section run can skip the module without reading it.
const SECTIONS = ['Book registry'];

export function run() {
  if (!SECTIONS.some(wantSection)) return;

  // ---------- 1e-bis. The book registry ----------
  // `source_book` is free text, and three separate mechanisms parse it:
  // resolveBookSlug (a row -> its cached pages), drift-check's citation check,
  // and the extraction prompt that writes the field. They used to disagree.
  // The Palladium Fantasy main book was spelled FIVE ways in production, and the
  // 312 gear rows saying `Palladium RPG Main Book` resolved to nothing at all -
  // every word of that title is generic, so the word-overlap route is disabled by
  // design and the initialism route needs a `pf` the title never spells.
  //
  // Against a FIXTURE, deliberately. A test that read the live vocabulary would
  // pass on a machine whose database happens to be missing the rows it is about.
  section('Book registry');

  {
    const fixture = {
      pf: {
        title: 'Palladium Fantasy RPG Main Book',
        aliases: ['Palladium RPG Main Book', 'palladium-fantasy-core'],
      },
      rue: { title: 'Rifts Ultimate Edition', aliases: [] },
      triax: { title: 'Rifts World Book 5: Triax and the NGR', aliases: [] },
    };

    check('a page range, case and punctuation all fall out of a title',
      normalizeBookTitle('Palladium-Fantasy_Core p.96-97') === 'palladium fantasy core'
      && normalizeBookTitle('  Rifts Ultimate Edition  ') === 'rifts ultimate edition');

    check('the canonical title names its book',
      registryBookSlug('Palladium Fantasy RPG Main Book p.288-289', fixture) === 'pf');
    check('and so does every alias',
      registryBookSlug('Palladium RPG Main Book p.273', fixture) === 'pf'
      && registryBookSlug('palladium-fantasy-core p.96-97', fixture) === 'pf');
    check('a book the registry has never heard of is null, not a guess',
      registryBookSlug('Rifts World Book 04: Africa p.12', fixture) === null);

    // The registry answers WHICH BOOK. Whether that book is readable here is a
    // separate question, and conflating them is how a Triax citation would get
    // traced against whichever cache looked closest.
    const cached = [{ slug: 'pf', sourcePdf: null }, { slug: 'rue', sourcePdf: null }];
    check('an alias reaches the cache no heuristic could reach',
      resolveBookSlug('Palladium RPG Main Book p.273', cached, fixture) === 'pf'
      && resolveBookSlug('Palladium RPG Main Book p.273', cached) === null);
    check('a known book with no cache is null, not the nearest cache',
      resolveBookSlug('Rifts World Book 5: Triax and the NGR p.20', cached, fixture) === null);
    check('without a registry the two heuristic routes are unchanged',
      resolveBookSlug('Rifts Ultimate Edition p.100-104', cached) === 'rue');

    // The shipped file, not the fixture: two books claiming one spelling would
    // make registryBookSlug refuse both, silently.
    const registry = loadBookRegistry();
    const seen = new Map();
    const clashes = [];
    for (const slug of Object.keys(registry)) {
      for (const s of bookSpellings(registry, slug)) {
        const k = normalizeBookTitle(s);
        if (seen.has(k) && seen.get(k) !== slug) clashes.push(`${s} (${seen.get(k)} / ${slug})`);
        seen.set(k, slug);
      }
    }
    check('no two books in scripts/books.json claim the same spelling',
      clashes.length === 0, clashes.join(', '));

    const shapeBad = Object.entries(registry).filter(([slug, b]) =>
      !/^[a-z0-9-]+$/.test(slug) || typeof b.title !== 'string' || !b.title
      || !Array.isArray(b.aliases)
      || !['number', 'object'].includes(typeof b.printed_pages)
      || !['number', 'object'].includes(typeof b.page_offset)).map(([slug]) => slug);
    check('every registry entry has the shape its readers assume',
      shapeBad.length === 0, shapeBad.join(', '));

    // THE RECOVERY RECORD. .cache/books/ is gitignored on purpose and holds the
    // full text of books Palladium still sells, so every cache is a working file
    // that can be rebuilt - but only from a PDF somebody still has. One
    // ocr-book.py run rebuilds a cache from source_pdf + source_pdf_dir; nothing
    // rebuilds a PDF that was never kept. A book that names its PDF and not the
    // directory it was read from is half a record, which is why this is pinned
    // rather than left to whoever adds the next book.
    const noDir = Object.entries(registry)
      .filter(([, b]) => b.source_pdf && typeof b.source_pdf_dir !== 'string')
      .map(([slug]) => slug);
    check('every book that names a source PDF also names the directory it was in',
      noDir.length === 0, noDir.join(', '));

    // And the other half: a directory for a PDF that is not named points nowhere.
    const dirNoPdf = Object.entries(registry)
      .filter(([, b]) => !b.source_pdf && b.source_pdf_dir)
      .map(([slug]) => slug);
    check('no book records a directory without the PDF that was in it',
      dirNoPdf.length === 0, dirNoPdf.join(', '));

    // The prompt is where the vocabulary is set: asking for a `kebab-case slug`
    // is what produced five spellings of one book. It offers the registry's
    // titles now, and the ` p.N-M` suffix that --field-sources takes its window
    // from - which the prompt had never once mentioned.
    const prompt = buildUserPrompt([{ name: 'X', text: 'md' }], null);
    const missingTitles = bookTitles(registry).filter((t) => !prompt.includes(t));
    check('the extraction prompt offers every registry title',
      missingTitles.length === 0, missingTitles.join(', '));
    check('and asks for the page range the field-source window needs',
      prompt.includes('<Title> p.N-M'));

    // ---- cache completeness ----
    // The gate that decides whether a citation check may believe a cache. It
    // used to compare the file count against `manifest.pages`, which is the
    // SOURCE PDF's page count -- a property of the file, not of the book.
    //
    // `fom` was the case that breaks: a 73-page cache of a 161-page book, built
    // from a truncated PDF, whose manifest therefore said `"pages": 73`. It
    // PASSED, and half a book read as all of it. These numbers are the real
    // ones, kept as a fixture because the live cache has since been completed
    // and can no longer demonstrate the bug.
    const fomAsItWas = {
      cachedPages: 73,
      manifest: { pages: 73, cached_pages: 73, printed_pages: 72, page_offset: 1 },
      registryEntry: { printed_pages: 159, page_offset: 1 },
    };
    check('the old rule passed a 73-page cache of a 161-page book',
      fomAsItWas.cachedPages >= fomAsItWas.manifest.pages);
    check('and the book\'s own last folio catches it',
      cacheCoverage(fomAsItWas).complete === false
      && cacheCoverage(fomAsItWas).needed === 160);

    // Why the registry outranks the manifest, in one check: ocr-book.py derives
    // printed_pages by reading the last folio it can SEE, so a truncated cache
    // derives its own truncation and passes itself. A number that comes from the
    // cache cannot judge the cache.
    check('a manifest derived from a truncated cache does not get to judge it',
      cacheCoverage({ ...fomAsItWas, registryEntry: undefined }).complete === true
      && cacheCoverage(fomAsItWas).printedFrom === 'scripts/books.json');

    // bom: six pages of a 352-page book, and no folio in those six survived OCR,
    // so the registry is the only source of the length at all.
    const bom = cacheCoverage({
      cachedPages: 6,
      manifest: { pages: 360, printed_pages: null, page_offset: null },
      registryEntry: { printed_pages: 352, page_offset: 1 },
    });
    check('a cache too short to read its own folio still gets measured',
      bom.complete === false && bom.cached === 6 && bom.needed === 353);

    // Unnumbered back matter means a complete cache holds MORE files than the
    // last printed page needs. rue: 382 files, last folio 374, offset +3.
    check('unnumbered back matter does not make a complete cache look short',
      cacheCoverage({ cachedPages: 382, manifest: { pages: 382 },
        registryEntry: { printed_pages: 374, page_offset: 3 } }).complete === true);

    // A book in no registry with no folio anywhere falls back to the old, weaker
    // test rather than to nothing -- and says which test it used.
    const fallback = cacheCoverage({ cachedPages: 100, manifest: { pages: 100 } });
    check('with no folio anywhere it falls back to the PDF page count, and says so',
      fallback.complete === true && fallback.basis.includes('PDF page count')
      && fallback.printedFrom === null);
    check('and unknown is not complete',
      cacheCoverage({ cachedPages: 100, manifest: null }).complete === false);

    // ---- the offset is recorded, not re-guessed ----
    // A per-book constant that was computed by a human at survey time, thrown
    // away, and re-derived by majority vote at every check. Recording it would be
    // dull if not for `pf`, whose offset is NOT constant: +1 for printed 1-15 and
    // +2 for printed 18-336, because an extra page sits at cache p018/p019. The
    // majority is +2 by 287 votes to 11, so a single recorded number sends every
    // lookup in the first sixteen pages one page early - which is the failure
    // book-survey 0d is thirty lines about, and its worked example is the
    // Attribute Bonus Chart at printed 16.
    // Shaped like the real thing: a SHORT head region and a long tail, so the
    // majority is the tail's offset and the head is the part that gets lost.
    const pfPages = [
      ...[2, 3, 4].map((p) => ({ page: p, lines: ['prose', String(p - 1)] })),
      ...[20, 21, 22, 23, 24, 25, 26, 27].map((p) => ({ page: p, lines: ['prose', String(p - 2)] })),
    ];
    const pfRegions = detectPageOffsetRegions(pfPages);
    check('a book that paginates two ways reports two regions',
      pfRegions.length === 2
      && pfRegions[0].offset === 1 && pfRegions[0].fromPrinted === 1 && pfRegions[0].toPrinted === 3
      && pfRegions[1].offset === 2 && pfRegions[1].fromPrinted === 18);
    check('and a majority vote flattens it to the wrong one for the minority region',
      detectPageOffset(pfPages).offset === 2);

    // `fom` has one page voting -3 and `rue` two voting +33 and +38, all single
    // votes in front matter. A stray bare number is not a pagination, and the
    // runs it splits must be re-joined or every book looks split.
    const strayed = [
      { page: 1, lines: ['x', '0'] }, { page: 2, lines: ['x', '1'] },
      { page: 3, lines: ['x', '2'] },
      { page: 9, lines: ['1994', '12'] },
      { page: 11, lines: ['x', '10'] }, { page: 12, lines: ['x', '11'] },
      { page: 13, lines: ['x', '12'] },
    ];
    check('a stray bare number is not a region, and does not split the one it is in',
      detectPageOffsetRegions(strayed).length === 1
      && detectPageOffsetRegions(strayed)[0].offset === 1);

    // The registry is the only one of the three sources that can express a split:
    // the manifest and live detection both hold one number.
    const pfEntry = { page_offset: 2, page_offset_exceptions: [{ printed_through: 16, offset: 1 }] };
    check('a recorded exception answers per printed page',
      offsetForPrintedPage(16, pfEntry).offset === 1
      && offsetForPrintedPage(17, pfEntry).offset === 2
      && offsetForPrintedPage(308, pfEntry).offset === 2);
    check('and says which rule it applied',
      offsetForPrintedPage(16, pfEntry).from === 'printed <= 16'
      && offsetForPrintedPage(17, pfEntry).from === 'page_offset');
    check('a book with no exceptions is a one-line lookup',
      offsetForPrintedPage(1, { page_offset: 3 }).offset === 3
      && offsetForPrintedPage(999, { page_offset: 3 }).offset === 3);
    check('and an entry with no offset at all resolves to nothing, not to zero',
      offsetForPrintedPage(1, { page_offset: null }) === null
      && offsetForPrintedPage(1, undefined) === null);

    // The shipped registry against the shipped caches: every book that detection
    // says paginates two ways must SAY so, or --field-sources reads the minority
    // region one page out and nothing notices.
    const splitButUnrecorded = [];
    for (const [slug, book] of Object.entries(registry)) {
      const txtDir = join(repoRoot, '.cache', 'books', slug, 'txt');
      if (!existsSync(txtDir)) continue;
      const cachePages = readdirSync(txtDir)
        .map((f) => f.match(/^p(\d+)\.txt$/)).filter(Boolean)
        .map((m) => ({ page: Number(m[1]),
          lines: readFileSync(join(txtDir, m[0]), 'utf8').split(/\r?\n/) }));
      for (const r of detectPageOffsetRegions(cachePages)) {
        if (offsetForPrintedPage(r.fromPrinted, book)?.offset !== r.offset
          || offsetForPrintedPage(r.toPrinted, book)?.offset !== r.offset) {
          splitButUnrecorded.push(`${slug} ${r.offset >= 0 ? '+' : ''}${r.offset} `
            + `over printed ${r.fromPrinted}-${r.toPrinted}`);
        }
      }
    }
    // Skips entirely on a machine with no caches - they are gitignored.
    check('every offset region the caches show is recorded in scripts/books.json',
      splitButUnrecorded.length === 0, splitButUnrecorded.join(' | '));

    // ---- source coverage ----
    // "Can what shipped still be traced back to a cached page?" was a question
    // nobody had asked across the corpus, so nobody knew the answer - and it is
    // exactly the kind of answer that stops being yes as books are cached
    // partially, re-sliced, or cited under a new spelling.
    //
    // The BUCKETING is pinned here, against a fixture. The live numbers are not
    // and must not be: the caches are gitignored, so a clean clone traces nothing
    // and a test that asserted otherwise would fail for everyone.
    {
      const reg = {
        rue: { title: 'Rifts Ultimate Edition', aliases: [], page_offset: 3, source_pdf: null },
        pf: {
          title: 'Palladium Fantasy RPG Main Book', aliases: ['palladium-fantasy-core'],
          page_offset: 2, page_offset_exceptions: [{ printed_through: 16, offset: 1 }],
          source_pdf: null,
        },
        bom: { title: 'Rifts Book of Magic', aliases: [], page_offset: 1, source_pdf: null },
        'rifts-core': { title: 'Rifts RPG (original core book)', aliases: [], source_pdf: null },
      };
      const notBooks = ['Estimate - no published price found'];
      // rue holds p100-p110, bom holds only p090-p095 — the shape of the real one.
      const caches = {
        rue: new Set(Array.from({ length: 11 }, (_, i) => 100 + i)),
        bom: new Set([90, 91, 92, 93, 94, 95]),
        pf: new Set(Array.from({ length: 20 }, (_, i) => 1 + i)),
      };
      const opts = { registry: reg, caches, notBooks };
      const b = (s) => bucketFor(s, opts);

      check('a window inside the cache is traceable',
        b('Rifts Ultimate Edition p.100-104').bucket === 'traceable');
      check('and the offset it used is the recorded one, not zero',
        b('Rifts Ultimate Edition p.100-104').window[0] === 103);
      check('a row citing nothing is its own bucket',
        b(null).bucket === 'no-source-book' && b('   ').bucket === 'no-source-book');
      check('a book with no page range cannot be located in it',
        b('Rifts Ultimate Edition').bucket === 'no-page-range');

      // The two that the audit lumped together, and why they must not be: one is
      // fixed by caching a book, the other by finishing one.
      check('a registered book with no cache here is not-cached',
        b('Rifts RPG (original core book) p.98-101').bucket === 'not-cached'
        && b('Rifts RPG (original core book) p.98-101').slug === 'rifts-core');
      check('a cached book that does not hold those pages is outside-cache',
        b('Rifts Book of Magic p.223-228').bucket === 'outside-cache'
        && b('Rifts Book of Magic p.223-228').reason === 'no page of it cached');
      check('and a half-covered window says how much of it is there',
        b('Rifts Ultimate Edition p.105-115').bucket === 'outside-cache'
        && b('Rifts Ultimate Edition p.105-115').reason === '3 of 11 pages cached');

      check('a spelling the registry has never seen is unknown-book',
        b('Rifts World Book 04: Africa p.12').bucket === 'unknown-book');

      // `Estimate - no published price found` resolved to `pf` for 104 gear rows
      // before `not_books` existed: the initialism route reads e-n-p-p-f and
      // finds `pf` inside it. Reporting those as gaps would be 104 false alarms.
      check('a provenance marker is not a book and not a gap',
        b('Estimate - no published price found').bucket === 'not-a-book');
      check('and it does not resolve to a cache through the initialism route',
        resolveBookSlug('Estimate - no published price found',
          [{ slug: 'pf', sourcePdf: null }], reg, notBooks) === null
        && resolveBookSlug('Estimate - no published price found',
          [{ slug: 'pf', sourcePdf: null }], reg) === 'pf');
      check('the shipped registry names both markers',
        loadNotBooks().length === 2
        && isNotABook('Web reference (not book-verified)', loadNotBooks()));

      // The reading this report invites and must refuse. `bom` read 232/177
      // both before and after the citation repair: caching the book flipped 231
      // rows to `traceable` while every one still pointed at two pages of Earth
      // Warlock descriptions, and fixing them moved nothing. Pin the CURRENT
      // claim, in the output a reader actually sees - not the absence of the
      // old wording, which any deletion would satisfy.
      const coverageSrc = readFileSync(
        join(repoRoot, 'scripts', 'source-coverage.mjs'), 'utf8');
      const printed = [...coverageSrc.matchAll(/console\.log\('([^']*)'\)/g)]
        .map((m) => m[1]).join(' ');
      check('the report says traceable is not the same as correct',
        /traceable means CHECKABLE, not correct/.test(printed));
      check('and names the case that proves it',
        /Book of\s+Magic/.test(printed) && printed.includes('231'));

      // The offset exception has to reach this too, or every pf row in the head
      // of the book is reported as untraceable.
      check('a page inside a recorded offset exception traces at that offset',
        b('Palladium Fantasy RPG Main Book p.14-16').window[0] === 15);

      const rolled = summarise([
        { label: 'a', sourceBook: 'Rifts Ultimate Edition p.100-104' },
        { label: 'b', sourceBook: 'Rifts Book of Magic p.223-228' },
        { label: 'c', sourceBook: null },
      ], opts);
      check('the roll-up counts every bucket and names only the offenders',
        rolled.total === 3 && rolled.counts.traceable === 1
        && rolled.offenders['outside-cache'][0].label === 'b'
        && rolled.offenders.traceable.length === 0);

      // ── the VALUES pass (BOOK-INGEST-AUDIT.md F1) ───────────────────────────
      // Is the NUMBER printed on the page the row cites? Driven from a fixture
      // here rather than from whatever caches this machine has, which is the
      // whole reason the pure half lives in the lib.
      check('a number is spelled three ways: bare, comma-grouped, and the dot form the OCR produces',
        JSON.stringify(valueSpellings(18000)) === JSON.stringify(['18000', '18,000', '18.000']));
      check('and a value with nothing to check yields no spellings at all',
        valueSpellings(0).length === 0 && valueSpellings(null).length === 0);

      check('the comma form is found where the book prints one',
        valuePresent(18000, 'Black Market Cost: 18,000 credits.'));
      check('and so is the dot form a scan produces for it',
        valuePresent(18000, 'Black Market Cost: 18.000 credits.'));

      // The boundary rule, both directions. Both were live bugs in the first
      // draft: the first over-matched, the second under-matched.
      check('a value is NOT found inside a longer number',
        !valuePresent(18000, 'costs 118,000 credits') && !valuePresent(500, 'adds 1,500 M.D.C.'));
      check('but a trailing comma is punctuation, not a digit group',
        valuePresent(12, 'Steelcloth loose-fitting robes (A.R. 12,')
        && valuePresent(65, 'Main body M.D.C. 65. The turret'));

      // A price the book states in words is the false positive this pass cannot
      // see past, and pretending otherwise would trade it for a silent miss.
      check('a figure printed in words reads as absent, and that is known and accepted',
        !valuePresent(3600000, 'Cost: 3.6 million credits'));

      const vpages = {
        'rue/103': 'NG-101 Rail Gun. Weight: 128 lbs.',
        'rue/104': 'Black Market Cost: 55,000 credits.',
        'rue/102': 'Main body M.D.C. 140.',
      };
      const vals = summariseValues([
        { label: 'on-the-page', sourceBook: 'Rifts Ultimate Edition p.100-100', values: { weight_lbs: 128 } },
        { label: 'one-page-late', sourceBook: 'Rifts Ultimate Edition p.100-100', values: { cost: 55000 } },
        { label: 'one-page-early', sourceBook: 'Rifts Ultimate Edition p.100-100', values: { mdc: 140 } },
        { label: 'nowhere', sourceBook: 'Rifts Ultimate Edition p.100-100', values: { cost: 987654 } },
        { label: 'no-window', sourceBook: null, values: { cost: 12 } },
      ], opts, (slug, n) => vpages[`${slug}/${n}`] ?? null);

      check('a value printed on the cited page is not a miss',
        vals.columns.get('weight_lbs').misses.length === 0);
      check('a miss on the NEXT page is reported as a short citation, not a wrong number',
        vals.byWhere.late === 1 && vals.columns.get('cost').misses[0].where === 'late');
      check('and a miss on the PREVIOUS page the same way',
        vals.byWhere.early === 1 && vals.columns.get('mdc').misses[0].where === 'early');
      check('only a value near neither page counts as absent',
        vals.byWhere.absent === 1);
      check('a row with no page window is a coverage gap, not a value one',
        vals.noWindow === 1 && vals.tested === 4);
    }

    // catalog-diff answers the question that decides what gets extracted, and
    // phase 4 is the only step in the pipeline that costs money. It defaults to
    // --local ON PURPOSE — an offline diff is legitimate — so the guard is that
    // a --local answer never travels without production's number beside it.
    //
    // This is not hypothetical: local held 336 skills against production's 333
    // the day it was written, and 327 against 324 in an earlier session.
    const diffSrc = readFileSync(join(repoRoot, 'scripts', 'catalog-diff.mjs'), 'utf8');
    check('catalog-diff still defaults to --local, deliberately',
      /argv\.includes\('--remote'\) \? '--remote' : '--local'/.test(diffSrc));
    check('and prints its target on the first line of output',
      /console\.log\(`\$\{table\} \(\$\{target\}\)/.test(diffSrc));
    check('a --local diff asks production for a second opinion',
      /if \(target === '--local'\)/.test(diffSrc)
      && /target: '--remote'/.test(diffSrc));
    check('and being offline costs the second opinion, never the diff',
      /catch \{ \/\* offline/.test(diffSrc)
      && /could not reach production/.test(diffSrc));

    // The skill is where the command is copied from, so the form it shows is the
    // form that gets run.
    const survey = readFileSync(join(repoRoot, '.claude', 'skills', 'book-survey', 'SKILL.md'), 'utf8');
    check('and book-survey phase 3 shows the --remote form',
      /node scripts\/catalog-diff\.mjs --remote --table/.test(survey));
  }
}
