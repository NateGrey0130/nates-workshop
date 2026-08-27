# -*- coding: utf-8 -*-
"""Cache a sourcebook once, properly, into a reusable page-addressed local cache.

    python scripts/ocr-book.py "C:/path/Book.pdf" --probe   # text layer? then stop
    python scripts/ocr-book.py "C:/path/Book.pdf" --slug rue
    python scripts/ocr-book.py ... --tables 200-202,167 --dpi-tables 500
    python scripts/ocr-book.py ... --page 200 --force      # redo one page

ONE COMMAND, EITHER KIND OF BOOK. `--slug <x>` and nothing else does the right
thing whether the PDF has a text layer or is a scan, because the failure this
prevents is a session inventing its own caching loop. Seven of the first eight
caches were built that way -- six by throwaway code that is in no commit, one
(`pf`, the most-cited book in the database) without even a manifest -- and they
do not agree with each other. Four of the six reproduce exactly under
`read-columns.read`; `pf` puts 68 pages' blocks in a different order; and `ju`
is raw `page.get_text()`, columns welded across the gutter, which is precisely
the corrupting read `read-columns.py` exists to prevent.

  TEXT LAYER -> the cheap path. `read-columns.read` (imported, never copied)
  through the same gap-bucketed column detection, into the same `txt/pNNN.txt`
  layout. No `png/`, no `tsv/`, no Tesseract, no model call, no cost. Detected
  by sampling 20 pages spread through the book: a scan medians ZERO characters
  a page and a text layer medians thousands, so the threshold is not delicate.
  `--force-ocr` overrides it.

  A SCAN -> everything below.

The text-layer path does NOT run the substitution table. Those repairs are
OCR damage -- `LS.P.`, `$.D.C.`, `18.000` -- and a text layer does not make
them; it makes typesetting damage instead (missing spaces, a mis-set glyph),
which no blanket rule fixes. Applying the OCR table to clean text would only
put the `18.000`->`18000` rule near real decimals for no gain.

WHY THE OCR SETTINGS ARE WHAT THEY ARE. Every one was learned by getting it
wrong during the RUE import, and re-learning them per book is how the same
mistakes come back:

  --psm 3, NOT --psm 6.  At psm 6 Tesseract treats a page as one uniform block
  and welds columns together: "Level Two  Magic Shield (6)  Distant Voice (10)"
  arrives as a single line. At psm 3 it does its own layout analysis and puts
  each column in its own BLOCK, which is what makes an index readable at all.

  TSV, always, alongside the text.  Reading an index in reading order needs
  word geometry. The first pass saved text only, so the moment geometry was
  needed two pages had to be re-OCR'd mid-task.

  A WORDLIST.  Tesseract reads "I.S.P." as "LS.P." on most Rifts psionics
  pages. A strict pattern found 10 stat blocks in a chapter that has 86.
  --user-words fixes this at the source instead of in every downstream regex.

  HIGHER DPI FOR TABLES.  Index and checklist pages are the authority for
  levels and costs, and they are set in the smallest type in the book. They are
  worth 500 dpi even when 300 is fine for prose.

  NORMALISE ONCE, HERE.  Book-wide OCR damage ($.D.C., [.S.P., a lone "fect")
  is a property of the scan, not of whatever is being imported today. Fixing it
  per-import is how an unbounded 'fect'->'feet' rule turned "effectively" into
  "effeetively". `.txt` is normalised; `.raw.txt` keeps what Tesseract said.

AND THE THING THAT DOES NOT WORK: raising the DPI. Measured over four pages
whose errors are known, going 300 -> 600 dpi took the price-unit misreads from
7 to 5 and the l/I confusions from 15 to 14. `--oem 1` changed nothing at all.
Greyscale and unsharp-masking changed nothing worth having.

The reason is in the confidence column: Tesseract reads "Ibs" at 91-94 percent
and "18.000" at 93-97 percent. It is not hesitating. `Ibs` and `18.000` are
perfectly plausible strings, and nothing tells an OCR engine that Palladium
does not price things in thousandths of a credit. Only 1.3% of words score
under 70, and NONE of the known misreads are among them - filtering on
confidence would find nothing.

So the leverage is not in the scan. It is in knowing what a field is allowed to
look like, which is why the repairs below are CONTEXTUAL and why the typed
readers live in scripts/ocr-fields-lib.mjs.

RESUMING IS BY CACHE KIND, NOT BY FILE COUNT. A page of an OCR cache is done
when its `txt` AND its `tsv` exist; a page of a text-layer cache is done when
its `txt` does, because that path writes no geometry at all. Keyed on both, as
it was, running this against any of the six text-layer caches resumed NOTHING:
it re-rendered every page and overwrote clean extraction with 300 dpi Tesseract
output. Silently, and `pf` is 339 pages of it. The manifest says which kind a
cache is, and switching kinds now needs --force and says what it would destroy.

The cache lives OUTSIDE git on purpose - see README. It is the full text of a
book Palladium still sells.
"""
import argparse, importlib.util, io, json, os, re, shutil, statistics, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_CACHE = os.path.join(REPO, '.cache', 'books')
WORDS = os.path.join(REPO, 'scripts', 'palladium-words.txt')
READ_COLUMNS = os.path.join(REPO, 'scripts', 'read-columns.py')

# A scan medians zero characters a page; every text layer measured here medians
# 4,000-6,100. Nothing lands between, so the threshold only has to not be zero.
TEXT_LAYER_MIN_CHARS = 400
SAMPLE_PAGES = 20

# Book-wide OCR damage. Applied once, at ingest.
#
# `bounded` entries only match as whole words. Without that, 'fect'->'feet'
# rewrites "effectively" to "effeetively" - which shipped into a description
# before it was caught.
SUBS = [
    ('[.S.P.', 'I.S.P.', False), ('1.S.P.', 'I.S.P.', False),
    ('LS.P.', 'I.S.P.', False), ('L.S.P.', 'I.S.P.', False),
    ('1.8.P.', 'I.S.P.', False), ('I:S.P.', 'I.S.P.', False),
    ('$.D.C.', 'S.D.C.', False), ('P.P-E.', 'P.P.E.', False),
    ('M.D.C .', 'M.D.C.', False),
    ('fect', 'feet', True), ('Ibs', 'lbs', True), ('tbs', 'lbs', True),
    ('melce', 'melee', True), ('melces', 'melees', True),
    ('lcvel', 'level', True), ('experlence', 'experience', True),
]


def find_tesseract():
    for c in (shutil.which('tesseract'),
              r'C:\Program Files\Tesseract-OCR\tesseract.exe',
              r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe'):
        if c and os.path.exists(c):
            return c
    sys.exit('tesseract not found - install it or put it on PATH')


def parse_pages(spec):
    """'200-202,167' -> {167, 200, 201, 202}"""
    out = set()
    for part in filter(None, (spec or '').split(',')):
        if '-' in part:
            a, b = part.split('-', 1)
            out.update(range(int(a), int(b) + 1))
        else:
            out.add(int(part))
    return out


# Repairs that need CONTEXT, not a lookup. Each was verified across the whole
# cached book before being turned on, because a blanket version of any of them
# would corrupt ordinary prose.
CONTEXTUAL = [
    # "20-100 er." is "20-100 cr." Every one of the 14 occurrences in this book
    # follows a digit, and no legitimate word does. A bare er->cr would of
    # course wreck "her", "over", "player".
    (re.compile(r'(?<=\d)(\s*)er\b\.?'), r'\1cr.'),
    # 18.000 credits is eighteen thousand. Guarded to EXACTLY three digits and a
    # word boundary: this book writes measurements as "1.8 m" and "0.9 m", never
    # to three places, and it mixes the two separators itself - "130.101 -
    # 180,200" is one range on one line. All 44 occurrences are thousands.
    (re.compile(r'(\d)\.(\d{3})\b'), r'\1\2'),
]


def normalise(text):
    for a, b, bounded in SUBS:
        if bounded:
            text = re.sub(r'(?<![A-Za-z])' + re.escape(a) + r'(?![A-Za-z])', b, text)
        else:
            text = text.replace(a, b)
    for rx, rep in CONTEXTUAL:
        text = rx.sub(rep, text)
    # OCR'd bullet glyphs and stray replacement characters.
    text = text.replace(' @ ', ' ').replace('\ufffd', "'")
    return text


def read_columns():
    """`read-columns.py`, IMPORTED rather than copied.

    The hyphen in the filename is why this is not a plain import. Copying the
    twenty lines of `columns_of` would be easier, and is the mistake the smoke
    test already guards against elsewhere: book-survey once shipped its own
    fork of this file, the two diverged completely, and the fork read as
    authoritative while every extraction ran the other one.
    """
    spec = importlib.util.spec_from_file_location('read_columns', READ_COLUMNS)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def sample_text_lengths(doc, n=SAMPLE_PAGES):
    """[(1-based page, characters in its text layer)] for n pages spread out.

    Spread through the book, not the first n: front matter is sparse in both
    kinds of book, and a sample of pages 1-20 can read a text layer as a scan.
    """
    total = doc.page_count
    if total <= n:
        idx = range(total)
    else:
        idx = sorted({int(i * (total - 1) / (n - 1)) for i in range(n)})
    return [(i + 1, len(doc[i].get_text())) for i in idx]


def has_text_layer(samples):
    return statistics.median([c for _, c in samples]) >= TEXT_LAYER_MIN_CHARS


def detect_folios(pages):
    """The printed-to-cache page offset, and the last printed folio.

    `pages` is [(cache page number, its text)]. The Python twin of
    detectPageOffset in scripts/class-check-lib.mjs, deliberately line for
    line: a bare integer near the top or bottom of a page is that page's
    printed folio, one vote per page, majority wins, implausible gaps
    discarded, ties to the offset nearest zero. Returns {} when no page shows a
    number -- which is what a six-page cache of a scan looks like, and is not
    an error.

    `cache page = printed folio + page_offset`, the direction --field-sources
    reads it.
    """
    votes = {}
    sampled = 0
    last = None
    for pno, text in pages:
        nonblank = [l.strip() for l in text.splitlines() if l.strip()]
        for t in nonblank[:5] + nonblank[-5:]:
            m = re.match(r'^(\d{1,4})$', t)
            if not m:
                continue
            printed = int(m.group(1))
            off = pno - printed
            if abs(off) > 40:
                continue
            votes[off] = votes.get(off, 0) + 1
            sampled += 1
            if last is None or printed > last:
                last = printed
            break
    if not votes:
        return {}
    offset = sorted(votes, key=lambda o: (-votes[o], abs(o)))[0]
    return {'page_offset': offset, 'votes': votes[offset], 'sampled': sampled,
            'printed_pages': last}


def cached_pages(txt_dir):
    """The pNNN.txt pages actually on disk. A `.raw.txt` is not a page."""
    out = []
    if os.path.isdir(txt_dir):
        for f in os.listdir(txt_dir):
            m = re.match(r'^p(\d+)\.txt$', f)
            if m:
                out.append(int(m.group(1)))
    return sorted(out)


def prior_manifest(out):
    try:
        return json.loads(io.open(os.path.join(out, 'manifest.json'),
                                  encoding='utf-8').read())
    except Exception:
        return None


def write_manifest(out, base, txt_dir):
    """The manifest, plus what can only be known once the pages are written.

    `cached_pages` and `cached_range` say what this cache actually HOLDS, which
    `pages` -- the source PDF's page count -- does not: a cache of 73 pages of
    a 161-page book whose manifest says `"pages": 73` reads as a complete book.
    `printed_pages` and `page_offset` are read off the cached pages themselves.

    drift-check's completeness gate reads them (via cacheCoverage in
    books-lib.mjs), preferring scripts/books.json's hand-checked numbers to
    these -- a printed_pages DERIVED from a truncated cache is the truncation's
    own last folio, and would pass itself. These are the fallback for a book
    the registry does not carry, and the check that the registry is right for
    one it does.
    """
    nums = cached_pages(txt_dir)
    base['cached_pages'] = len(nums)
    base['cached_range'] = ('p%03d-p%03d' % (nums[0], nums[-1])) if nums else None
    folios = detect_folios(
        [(n, io.open(os.path.join(txt_dir, 'p%03d.txt' % n),
                     encoding='utf-8', errors='replace').read()) for n in nums])
    base['printed_pages'] = folios.get('printed_pages')
    base['page_offset'] = folios.get('page_offset')
    io.open(os.path.join(out, 'manifest.json'), 'w', encoding='utf-8',
            newline='').write(json.dumps(base, indent=1))
    return base


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pdf')
    ap.add_argument('--slug', help='cache folder name (default: from filename)')
    ap.add_argument('--cache', default=DEFAULT_CACHE)
    ap.add_argument('--probe', action='store_true',
                    help='print the per-page text-layer sample and exit; writes nothing')
    ap.add_argument('--force-ocr', action='store_true',
                    help='OCR even a PDF that has a text layer')
    ap.add_argument('--dpi', type=int, default=300)
    ap.add_argument('--dpi-tables', type=int, default=500)
    ap.add_argument('--tables', default='', help='pages to render at --dpi-tables')
    ap.add_argument('--page', type=int, help='just this one page')
    ap.add_argument('--psm', default='3')
    ap.add_argument('--force', action='store_true')
    ap.add_argument('--renormalise', action='store_true',
                    help='re-apply the substitution table to the cached raw\n                          text and exit; no Tesseract, seconds not minutes')
    ap.add_argument('--keep-png', action='store_true',
                    help='keep page images (large); off by default')
    a = ap.parse_args()

    import pymupdf
    slug = a.slug or re.sub(r'[^a-z0-9]+', '-', os.path.splitext(
        os.path.basename(a.pdf))[0].lower()).strip('-')
    out = os.path.join(a.cache, slug)
    txt_dir = os.path.join(out, 'txt')

    # --probe answers book-survey step 0 and writes nothing. It exists so the
    # first command aimed at a new book is a script that can be allowlisted
    # rather than a bare `python -c`, which prompts every single time.
    doc = pymupdf.open(a.pdf)
    samples = sample_text_lengths(doc)
    text_layer = has_text_layer(samples) and not a.force_ocr
    if a.probe:
        print('%s: %d pages, sampled %d' % (slug, doc.page_count, len(samples)))
        for i in range(0, len(samples), 5):
            print('  ' + '  '.join('p%03d %6d' % s for s in samples[i:i + 5]))
        median = statistics.median([c for _, c in samples])
        print('  median %d chars/page -> %s (threshold %d)'
              % (median, 'TEXT LAYER' if has_text_layer(samples) else 'SCAN',
                 TEXT_LAYER_MIN_CHARS))
        print('  cache it:  python scripts/ocr-book.py "%s" --slug %s'
              % (a.pdf, slug))
        return

    # Switching a cache from one kind to the other is destructive and has
    # never once been intended: keyed on txt+tsv, a plain run against any
    # text-layer cache resumed nothing and overwrote every page with Tesseract
    # output. Say what would be lost, and make it explicit.
    prior = prior_manifest(out)
    if prior is not None and not a.renormalise:
        was_text = bool(prior.get('text_layer'))
        if was_text != text_layer and not a.force:
            sys.exit(
                '%s is cached as %s and this run would rebuild it as %s, '
                'overwriting %d page(s).\n'
                'Pass --force if that is what you want, or --force-ocr / nothing '
                'to keep the kind it has.'
                % (slug, 'a text layer' if was_text else 'OCR',
                   'a text layer' if text_layer else 'OCR',
                   len(cached_pages(txt_dir))))

    for sub in (('txt',) if text_layer else ('txt', 'tsv', 'png')):
        os.makedirs(os.path.join(out, sub), exist_ok=True)

    if a.renormalise:
        # The expensive half of OCR is Tesseract, and its output is already on
        # disk in .raw.txt. Improving a substitution rule should not cost 25
        # minutes of re-scanning a book that has not changed.
        import glob
        n = 0
        for raw in sorted(glob.glob(os.path.join(txt_dir, 'p*.raw.txt'))):
            txt = raw.replace('.raw.txt', '.txt')
            io.open(txt, 'w', encoding='utf-8', newline='').write(
                normalise(io.open(raw, encoding='utf-8', errors='replace').read()))
            n += 1
        print('%s: renormalised %d page(s) from cached raw text' % (slug, n))
        return

    pages = [a.page] if a.page else range(1, doc.page_count + 1)
    base = {'slug': slug, 'source_pdf': os.path.basename(a.pdf),
            'pages': doc.page_count, 'text_layer': text_layer}

    if text_layer:
        # The cheap path. Same reader as read-columns.py because it IS
        # read-columns.py: blocks bucketed into columns by gap and walked top
        # to bottom, so a two-column stat block does not arrive with the
        # neighbouring column welded into its lines. `ju`'s cache is what
        # skipping that looks like -- 148 of its 162 pages are raw get_text().
        #
        # UTF-8, not the ASCII the old loops wrote: they mangled every (R) and
        # (TM) to a replacement character. Nothing downstream needs them gone,
        # and `class-check --field-sources` quotes these lines to a human.
        rc = read_columns()
        done = skipped = 0
        for pno in pages:
            txt = os.path.join(txt_dir, 'p%03d.txt' % pno)
            if os.path.exists(txt) and not a.force:
                skipped += 1
                continue
            io.open(txt, 'w', encoding='utf-8', newline='').write(
                rc.read(doc[pno - 1]) + '\n')
            done += 1
            if done % 50 == 0:
                print('  %d pages...' % done, flush=True)
        m = write_manifest(out, base, txt_dir)
        print('%s: %d page(s) read from the text layer, %d already cached -> %s'
              % (slug, done, skipped, out))
        print('  text     %s   (no OCR, no geometry, no cost)' % txt_dir)
        print('  cached   %s file(s) %s; last printed folio %s, offset %s'
              % (m['cached_pages'], m['cached_range'],
                 m['printed_pages'] or '?',
                 '?' if m['page_offset'] is None else '%+d' % m['page_offset']))
        return

    tess = find_tesseract()
    tables = parse_pages(a.tables)

    done = skipped = 0
    for pno in pages:
        txt = os.path.join(txt_dir, 'p%03d.txt' % pno)
        tsv = os.path.join(out, 'tsv', 'p%03d.tsv' % pno)
        # An OCR page is done when BOTH exist; a text-layer page has no tsv at
        # all, which is why the kind guard above runs before this loop.
        if os.path.exists(txt) and os.path.exists(tsv) and not a.force:
            skipped += 1
            continue
        dpi = a.dpi_tables if pno in tables else a.dpi
        png = os.path.join(out, 'png', 'p%03d.png' % pno)
        doc[pno - 1].get_pixmap(dpi=dpi).save(png)
        stem = os.path.join(out, 'tsv', 'p%03d' % pno)
        cmd = [tess, png, stem, '--psm', a.psm]
        if os.path.exists(WORDS):
            cmd += ['--user-words', WORDS]
        # One invocation, two outputs - the geometry is never a second pass.
        subprocess.run(cmd + ['txt', 'tsv'], check=True, capture_output=True)
        raw = io.open(stem + '.txt', encoding='utf-8', errors='replace').read()
        io.open(os.path.join(txt_dir, 'p%03d.raw.txt' % pno), 'w',
                encoding='utf-8', newline='').write(raw)
        io.open(txt, 'w', encoding='utf-8', newline='').write(normalise(raw))
        os.remove(stem + '.txt')
        if not a.keep_png:
            os.remove(png)
        done += 1
        if done % 25 == 0:
            print('  %d pages...' % done, flush=True)

    base.update({'dpi': a.dpi, 'dpi_tables': a.dpi_tables,
                 'table_pages': sorted(tables), 'psm': a.psm,
                 'wordlist': os.path.basename(WORDS) if os.path.exists(WORDS) else None,
                 'normalisations': len(SUBS)})
    m = write_manifest(out, base, txt_dir)
    print('%s: %d page(s) OCR\'d, %d already cached -> %s' % (slug, done, skipped, out))
    print('  text     %s' % txt_dir)
    print('  geometry %s   (block_num groups columns - see book-survey skill)'
          % os.path.join(out, 'tsv'))
    print('  cached   %s file(s) %s; last printed folio %s, offset %s'
          % (m['cached_pages'], m['cached_range'], m['printed_pages'] or '?',
             '?' if m['page_offset'] is None else '%+d' % m['page_offset']))


if __name__ == '__main__':
    main()
