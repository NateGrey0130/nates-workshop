# -*- coding: utf-8 -*-
"""OCR a scanned sourcebook once, properly, into a reusable local cache.

    python scripts/ocr-book.py "C:/path/Rifts - Ultimate Edition.pdf" --slug rue
    python scripts/ocr-book.py ... --tables 200-202,167 --dpi-tables 500
    python scripts/ocr-book.py ... --page 200 --force      # redo one page

WHY THIS EXISTS. Every one of these settings was learned by getting it wrong
during the RUE import, and re-learning them per book is how the same mistakes
come back:

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

The cache lives OUTSIDE git on purpose - see README. It is the full text of a
book Palladium still sells.
"""
import argparse, io, json, os, re, shutil, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_CACHE = os.path.join(REPO, '.cache', 'books')
WORDS = os.path.join(REPO, 'scripts', 'palladium-words.txt')

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


def normalise(text):
    for a, b, bounded in SUBS:
        if bounded:
            text = re.sub(r'(?<![A-Za-z])' + re.escape(a) + r'(?![A-Za-z])', b, text)
        else:
            text = text.replace(a, b)
    # OCR'd bullet glyphs and stray replacement characters.
    text = text.replace(' @ ', ' ').replace('\ufffd', "'")
    return text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pdf')
    ap.add_argument('--slug', help='cache folder name (default: from filename)')
    ap.add_argument('--cache', default=DEFAULT_CACHE)
    ap.add_argument('--dpi', type=int, default=300)
    ap.add_argument('--dpi-tables', type=int, default=500)
    ap.add_argument('--tables', default='', help='pages to render at --dpi-tables')
    ap.add_argument('--page', type=int, help='just this one page')
    ap.add_argument('--psm', default='3')
    ap.add_argument('--force', action='store_true')
    ap.add_argument('--keep-png', action='store_true',
                    help='keep page images (large); off by default')
    a = ap.parse_args()

    import pymupdf
    tess = find_tesseract()
    slug = a.slug or re.sub(r'[^a-z0-9]+', '-', os.path.splitext(
        os.path.basename(a.pdf))[0].lower()).strip('-')
    out = os.path.join(a.cache, slug)
    for sub in ('txt', 'tsv', 'png'):
        os.makedirs(os.path.join(out, sub), exist_ok=True)

    tables = parse_pages(a.tables)
    doc = pymupdf.open(a.pdf)
    pages = [a.page] if a.page else range(1, doc.page_count + 1)

    done = skipped = 0
    for pno in pages:
        txt = os.path.join(out, 'txt', 'p%03d.txt' % pno)
        tsv = os.path.join(out, 'tsv', 'p%03d.tsv' % pno)
        if os.path.exists(txt) and os.path.exists(tsv) and not a.force:
            skipped += 1
            continue
        dpi = a.dpi_tables if pno in tables else a.dpi
        png = os.path.join(out, 'png', 'p%03d.png' % pno)
        doc[pno - 1].get_pixmap(dpi=dpi).save(png)
        base = os.path.join(out, 'tsv', 'p%03d' % pno)
        cmd = [tess, png, base, '--psm', a.psm]
        if os.path.exists(WORDS):
            cmd += ['--user-words', WORDS]
        # One invocation, two outputs - the geometry is never a second pass.
        subprocess.run(cmd + ['txt', 'tsv'], check=True, capture_output=True)
        raw = io.open(base + '.txt', encoding='utf-8', errors='replace').read()
        io.open(os.path.join(out, 'txt', 'p%03d.raw.txt' % pno), 'w',
                encoding='utf-8', newline='').write(raw)
        io.open(txt, 'w', encoding='utf-8', newline='').write(normalise(raw))
        os.remove(base + '.txt')
        if not a.keep_png:
            os.remove(png)
        done += 1
        if done % 25 == 0:
            print('  %d pages...' % done, flush=True)

    manifest = {'slug': slug, 'source_pdf': os.path.basename(a.pdf),
                'pages': doc.page_count, 'dpi': a.dpi, 'dpi_tables': a.dpi_tables,
                'table_pages': sorted(tables), 'psm': a.psm,
                'wordlist': os.path.basename(WORDS) if os.path.exists(WORDS) else None,
                'normalisations': len(SUBS)}
    io.open(os.path.join(out, 'manifest.json'), 'w', encoding='utf-8',
            newline='').write(json.dumps(manifest, indent=1))
    print('%s: %d page(s) OCR\'d, %d already cached -> %s' % (slug, done, skipped, out))
    print('  text     %s' % os.path.join(out, 'txt'))
    print('  geometry %s   (block_num groups columns - see book-survey skill)'
          % os.path.join(out, 'tsv'))


if __name__ == '__main__':
    main()
