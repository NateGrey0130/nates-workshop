# -*- coding: utf-8 -*-
"""Cache a Marvel Super Heroes sourcebook scan as page-addressed OCR, locally.

    python scripts/msh/ocr-book.py ma1                 # every page of the book
    python scripts/msh/ocr-book.py ma1 --pages 5-12    # just these PDF pages
    python scripts/msh/ocr-book.py ma1 --page 9 --force
    python scripts/msh/ocr-book.py ma1 --probe         # text layer? then stop

The book is named by its slug in scripts/msh/books.json, which says where its
PDF is. Output goes under the gitignored Marvel cache, never into the repo -
this repository is public and the text is TSR's:

    $WORKSHOP_MSH_CACHE/books/<slug>/tsv/pNNN.tsv   Tesseract word geometry
    $WORKSHOP_MSH_CACHE/books/<slug>/txt/pNNN.txt   Tesseract's own text
    $WORKSHOP_MSH_CACHE/books/<slug>/manifest.json  how it was made

WORKSHOP_MSH_CACHE defaults to .cache/msh under this checkout, as it does for
scripts/msh-extract.py. From a worktree, point it at the main checkout's
.cache/msh, or the worktree gets a cache of its own that its removal deletes.

pNNN is the PDF page, 1-based. The printed page is pNNN minus the book's
`offset` in scripts/msh/books.json; this script does not apply it, so a cache never
has to be rebuilt because an offset was measured wrong.

WHY THIS IS NOT scripts/ocr-book.py. That script belongs to the Palladium
books and is tuned to them: its wordlist is palladium-words.txt and its .txt
is run through repairs for Palladium's abbreviations (S.D.C., I.S.P., "fect").
Those rules have no business near a FASERIP block, and changing that script to
take a Marvel mode would put this work inside the Palladium pipeline. So this
borrows its settings, not its code:

  --psm 3, so Tesseract does its own layout analysis and usually puts each of
  the book's three columns in its own block rather than welding them into
  lines. Not always: on MHSP1's Adventure p.2 it fused a column's lines and
  read them twice, so scripts/msh/booklet.py finds such runs and re-reads
  them as a block from the page image (mend_fused).
  TSV alongside the text, in one invocation, because the stat grid and the
  column spans are read from word geometry, not from reading order.
  300 dpi. ocr-book.py measured that raising it does not help a clean scan.

There is NO normalisation pass. The Marvel parser reads the TSV, and its
checks (a rank code must agree with its number; Health = F+A+S+E; Karma =
R+I+P) catch digit damage where a blanket substitution would hide it.
"""
import argparse, concurrent.futures, datetime, io, json, os, shutil, statistics, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = os.environ.get('WORKSHOP_MSH_CACHE') or os.path.join(ROOT, '.cache', 'msh')
REGISTRY = os.path.join(ROOT, 'scripts', 'msh', 'books.json')
WORDS = os.path.join(ROOT, 'scripts', 'msh', 'words.txt')
PSM = '3'


def find_tesseract():
    for c in (shutil.which('tesseract'),
              r'C:\Program Files\Tesseract-OCR\tesseract.exe',
              r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe'):
        if c and os.path.exists(c):
            return c
    sys.exit('tesseract not found - install it or put it on PATH')


def parse_pages(spec, last):
    out = set()
    for part in filter(None, (spec or '').split(',')):
        a, _, b = part.partition('-')
        out.update(range(int(a), int(b or a) + 1))
    bad = sorted(p for p in out if not 1 <= p <= last)
    if bad:
        sys.exit('no such PDF page: %s (the book has %d)' % (bad, last))
    return sorted(out)


def load_book(slug):
    books = json.load(io.open(REGISTRY, encoding='utf-8'))['books']
    if slug not in books:
        sys.exit('%s is not in %s; known: %s' % (slug, REGISTRY, ', '.join(sorted(books))))
    b = books[slug]
    pdf = os.path.join(b['source_pdf_dir'], b['source_pdf'])
    if not os.path.exists(pdf):
        sys.exit('the registry names %s and it is not there' % pdf)
    return b, pdf


def ocr_one(tess, png, stem):
    cmd = [tess, png, stem, '--psm', PSM]
    if os.path.exists(WORDS):
        cmd += ['--user-words', WORDS]
    subprocess.run(cmd + ['txt', 'tsv'], check=True, capture_output=True)
    os.remove(png)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('slug')
    ap.add_argument('--pages', help='PDF pages, e.g. 5-12,40 (default: all)')
    ap.add_argument('--page', type=int)
    ap.add_argument('--dpi', type=int, default=300)
    ap.add_argument('--force', action='store_true', help='redo pages already cached')
    ap.add_argument('--probe', action='store_true', help='report the text layer and stop')
    ap.add_argument('--jobs', type=int, default=6)
    a = ap.parse_args()

    import pymupdf
    book, pdf = load_book(a.slug)
    doc = pymupdf.open(pdf)
    n = doc.page_count

    if a.probe:
        sample = sorted({max(1, round(i * n / 20)) for i in range(1, 21)})
        chars = [len(doc[p - 1].get_text().strip()) for p in sample]
        print('%s: %d PDF pages; median text-layer chars over %d samples: %d'
              % (a.slug, n, len(sample), statistics.median(chars)))
        return

    out = os.path.join(CACHE, 'books', a.slug)
    for sub in ('tsv', 'txt', 'png'):
        os.makedirs(os.path.join(out, sub), exist_ok=True)
    pages = [a.page] if a.page else parse_pages(a.pages, n) if a.pages else list(range(1, n + 1))
    tess = find_tesseract()

    todo = []
    for p in pages:
        stem = os.path.join(out, 'tsv', 'p%03d' % p)
        if os.path.exists(stem + '.tsv') and os.path.exists(os.path.join(out, 'txt', 'p%03d.txt' % p)) and not a.force:
            continue
        todo.append(p)
    print('%s: %d of %d requested pages to OCR into %s' % (a.slug, len(todo), len(pages), out), flush=True)

    # The PDF is read on this thread only (pymupdf documents are not thread
    # safe); Tesseract, a separate process per page, is what runs in parallel.
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        futures = {}
        for p in todo:
            png = os.path.join(out, 'png', 'p%03d.png' % p)
            doc[p - 1].get_pixmap(dpi=a.dpi).save(png)
            futures[pool.submit(ocr_one, tess, png, os.path.join(out, 'tsv', 'p%03d' % p))] = p
        for i, f in enumerate(concurrent.futures.as_completed(futures), 1):
            f.result()
            p = futures[f]
            os.replace(os.path.join(out, 'tsv', 'p%03d.txt' % p), os.path.join(out, 'txt', 'p%03d.txt' % p))
            if i % 10 == 0:
                print('  %d pages...' % i, flush=True)

    manifest = {
        'slug': a.slug, 'source_pdf': book['source_pdf'], 'pdf_pages': n,
        'dpi': a.dpi, 'psm': PSM, 'wordlist': os.path.basename(WORDS),
        'tesseract': subprocess.run([tess, '--version'], capture_output=True, text=True).stdout.splitlines()[0],
        'page_naming': 'pNNN is the PDF page, 1-based; printed = pNNN - offset (scripts/msh/books.json)',
        'written': datetime.date.today().isoformat(),
    }
    io.open(os.path.join(out, 'manifest.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(manifest, indent=2) + '\n')
    shutil.rmtree(os.path.join(out, 'png'), ignore_errors=True)
    print('done: %d OCR\'d, %d already cached' % (len(todo), len(pages) - len(todo)))


if __name__ == '__main__':
    main()
