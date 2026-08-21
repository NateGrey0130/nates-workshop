# -*- coding: utf-8 -*-
"""Read a multi-column sourcebook page in READING ORDER.

`page.get_text()` returns a PDF's text in the order the drawing operations
appear, which on a two- or three-column page is not the order a person reads.
For prose this is untidy. For an INDEX it is corrupting: the "Level N" headings
and the entries beneath them interleave from different columns, so entries end up
filed under the wrong heading.

Concretely, on the Rifts Book of Magic master index (pp.89-92), reading linearly:

    Level One  -> 0 entries
    Level Two  -> 0 entries
    Level Three -> 48 entries, including Blinding Flash and Globe of Daylight

Both of those are level ONE spells. Nothing about that output looks broken; the
counts are plausible and the names are real. It is caught only by probing a
handful of entries whose answer you already know.

Reading geometrically:

    Level One -> 10, Level Two -> 17, Level Three -> 21   (and the probes pass)

Usage:

    from read_columns import ordered_lines
    for line in ordered_lines(doc[p - 1]):
        ...

ALWAYS probe the result. A column reader that is subtly wrong - a threshold that
splits one column in two, a page whose margin differs - produces output that
looks exactly like output that works.
"""
import re


def ordered_lines(page, gap=40):
    """Every non-empty line on `page`, in column-then-vertical order.

    `gap` is the horizontal distance that separates one column from the next.
    The gutter between columns is far wider than the jitter of line starts
    within a column, so a threshold on the sorted x-positions finds the
    boundaries without knowing the layout in advance. Widen it if a single
    column is being split; narrow it if two columns are being merged.
    """
    data = page.get_text('dict')
    lines = []
    for block in data['blocks']:
        for line in block.get('lines', []):
            text = ''.join(span['text'] for span in line['spans'])
            text = re.sub(r'\s+', ' ', text).strip()
            if text:
                lines.append((line['bbox'][0], line['bbox'][1], text))
    if not lines:
        return []

    xs = sorted(x for x, _, _ in lines)
    cuts = [xs[i + 1] for i in range(len(xs) - 1) if xs[i + 1] - xs[i] > gap]

    def column(x):
        return sum(1 for c in cuts if x >= c)

    return [t for _, _, t in sorted(lines, key=lambda l: (column(l[0]), l[1]))]


def probe(parsed, expected, label='probe'):
    """Assert a few known-good facts before trusting the whole parse.

    `expected` is {name: value}. Prints one line per probe and returns whether
    all of them held. Four probes are enough to catch a column reader that is
    off, and cost nothing.
    """
    ok = True
    for name, want in expected.items():
        got = parsed.get(name)
        good = got == want
        ok = ok and good
        print('  %-12s %-30s expected %-8s got %-8s %s'
              % (label, name, want, got, 'ok' if good else '*** WRONG'))
    return ok
