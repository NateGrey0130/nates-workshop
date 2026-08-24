# -*- coding: utf-8 -*-
"""Read a multi-column page in READING ORDER, from a PDF that has a text layer.
;
    python scripts/read-columns.py "book.pdf" 88          # one page
    python scripts/read-columns.py "book.pdf" 87 92       # a range

PAGE NUMBERS HERE ARE 1-BASED - the number a PDF viewer shows - because main()
reads `doc[n - 1]`. **`pymupdf`'s own index is 0-BASED.** So one page is
`doc[87]` in a probe script and `88` on this command line, and a survey that
derives the printed-to-PDF offset with one and then reads with the other lands
one page early - a whole page of the wrong class, which reads as the book
simply not saying what you expected rather than as an off-by-one.

Pantheons of the Megaverse makes that trap worst, because its printed-to-PDF
offset is ZERO: printed 16 is `d[16]` in pymupdf and `17` here, so the only
discrepancy left is this one, and it is very easy to blame on the book.

Passing a single page prints no `===== pN =====` header; a range prints one per
page. So the cheapest confirmation you are on the right page is to read the
folio printed at the end of the output, which is what `book-survey` 0d already
tells you to do for the offset itself.

`page.get_text()` returns text in the order the drawing operations appear,
which on a two-column page is not the order a person reads. For prose that is
untidy. For a stat block it is corrupting: the Knight's "O.C.C. Skills:" list
runs into the page number, the running header, and the first line of the next
column, so a naive read attributes the wrong skills to the class.

This is the text-layer twin of what `ocr-book.py --psm 3` does for a scan: let
the geometry decide the order. Blocks are bucketed into columns by their left
edge, then walked top to bottom within each column.

Column detection is by GAP, not by assuming a count: a page with a full-width
heading over two columns, or a three-column price list, both read correctly
without being told which they are.
"""
import sys

import pymupdf


def columns_of(page, min_gap=40):
    """Blocks grouped into columns, each column sorted top to bottom."""
    blocks = [b for b in page.get_text('blocks') if b[6] == 0 and b[4].strip()]
    if not blocks:
        return []

    # A full-width block (a heading, a table rule) belongs to no column and
    # would otherwise merge two columns into one bucket.
    width = page.rect.width
    narrow = [b for b in blocks if (b[2] - b[0]) < width * 0.75]
    wide = [b for b in blocks if (b[2] - b[0]) >= width * 0.75]

    # Find the vertical gutters: sort by left edge and split wherever the jump
    # exceeds min_gap.
    edges = sorted({round(b[0]) for b in narrow})
    groups, cur = [], []
    for x in edges:
        if cur and x - cur[-1] > min_gap:
            groups.append(cur)
            cur = []
        cur.append(x)
    if cur:
        groups.append(cur)

    cols = []
    for g in groups:
        lo, hi = min(g), max(g)
        members = [b for b in narrow if lo <= round(b[0]) <= hi]
        cols.append(sorted(members, key=lambda b: b[1]))

    # Wide blocks are emitted first, in page order: they head the page.
    return ([sorted(wide, key=lambda b: b[1])] if wide else []) + cols


def read(page):
    out = []
    for col in columns_of(page):
        for b in col:
            out.append(b[4].rstrip())
    return '\n'.join(out)


def main():
    if len(sys.argv) < 3:
        sys.exit('usage: read-columns.py <pdf> <page> [last-page]')
    pdf, first = sys.argv[1], int(sys.argv[2])
    last = int(sys.argv[3]) if len(sys.argv) > 3 else first
    doc = pymupdf.open(pdf)
    for n in range(first, last + 1):
        if len(sys.argv) > 3:
            print('\n========== p%d ==========' % n)
        print(read(doc[n - 1]))


if __name__ == '__main__':
    main()
