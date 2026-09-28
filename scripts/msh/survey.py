# -*- coding: utf-8 -*-
"""Measure a cached Marvel sourcebook before anything is parsed out of it.

    python scripts/msh/survey.py ma1            # the report
    python scripts/msh/survey.py ma1 --json     # the same, machine-readable

Reads only the OCR cache scripts/msh/ocr-book.py wrote (WORKSHOP_MSH_CACHE,
default .cache/msh) and the book's entry in scripts/msh/books.json. Writes
nothing. It answers the four questions the survey
(apps/marvel-heroes/docs/surveys/<slug>.md) records:

  OFFSET   every page with a bare number in its bottom tenth (TSV geometry)
           is a folio vote for printed = PDF - offset. Disagreements are
           listed, not averaged.
  BLOCKS   every stat block, found by its one `Health =` line, with the
           header above it: the first line upward that is set in capitals.
           A block is the unit the parser will extract, so this count is the
           number every later step is held to.
  CHECKS   each block's seven ability numbers and Health/Karma, read off the
           lines as OCR'd, tested against Health = F+A+S+E and Karma = R+I+P.
           A failure here is a page to look at, not yet a fact about the book.
  INDEX    every printed-index name against the headers found, both ways,
           with the index's page against the block's page.

The header rule is deliberately simple, because it is a measurement: the
parser in the next phase reads word geometry and header type size. Where
this report and the parser disagree, the page image decides.
"""
import argparse, io, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = os.environ.get('WORKSHOP_MSH_CACHE') or os.path.join(ROOT, '.cache', 'msh')
REGISTRY = os.path.join(ROOT, 'scripts', 'msh', 'books.json')

# The rank a code stands for, by its number (PB p.2). Fb, Po, Go and Re are this
# book's own misprints of Fe, Pr, Gd and Rm (books.json rank_aliases); they are
# accepted here so that a rank failure means a number that disagrees with its
# code, not a spelling.
RANK_NUMBER = {'Fe': 2, 'Fb': 2, 'Pr': 4, 'Po': 4, 'Ty': 6, 'Gd': 10, 'Go': 10, 'Ex': 20,
               'Rm': 30, 'Re': 30, 'In': 40, 'Am': 50, 'Mn': 75, 'Un': 100}
ABILITY_ROW = re.compile(r'^\s*\S{1,2}\s+(\d{1,4})\s+([A-Za-z]{2}|C-?\d{3,4})\b')
HEALTH = re.compile(r'Health\s*=\s*(\S+)')
KARMA = re.compile(r'Karma\s*=\s*(\S+)')


def norm(s):
    return re.sub(r'[^a-z0-9]+', ' ', s.lower()).strip()


def is_header(line):
    t = line.strip()
    letters = [c for c in t if c.isalpha()]
    if len(letters) < 3:
        return False
    head = re.sub(r'\([^)]*\)', '', t)          # PHOENIX (original): the variant is mixed case
    hl = [c for c in head if c.isalpha()]
    return len(hl) >= 3 and sum(c.isupper() for c in hl) / len(hl) > 0.85 and not t.endswith(':')


def tsv_folio(path):
    """The page's folio: a word of bare digits in the bottom tenth of the page.
    Read from geometry because Tesseract rarely puts it on the last text line."""
    if not os.path.exists(path):
        return None
    height, best = None, None
    for row in io.open(path, encoding='utf-8').read().splitlines()[1:]:
        f = row.split('\t')
        if len(f) < 12:
            continue
        if f[0] == '1':
            height = int(f[9])
        elif f[0] == '5' and height and re.fullmatch(r'\d{1,3}', f[11].strip()):
            top = int(f[7])
            if top > 0.9 * height and (best is None or top > best[0]):
                best = (top, int(f[11]))
    return best[1] if best else None


def num(s):
    s = s.strip().rstrip('.,')
    return int(s) if s.isdigit() else None


def survey(slug):
    book = json.load(io.open(REGISTRY, encoding='utf-8'))['books'][slug]
    txt_dir = os.path.join(CACHE, 'books', slug, 'txt')
    if not os.path.isdir(txt_dir):
        sys.exit('no cache at %s - run scripts/msh/ocr-book.py %s first' % (txt_dir, slug))
    off = book['offset']
    folios, blocks = [], []
    for pdf in range(1, book['pdf_pages'] + 1):
        path = os.path.join(txt_dir, 'p%03d.txt' % pdf)
        lines = io.open(path, encoding='utf-8').read().splitlines() if os.path.exists(path) else []
        folio = tsv_folio(os.path.join(CACHE, 'books', slug, 'tsv', 'p%03d.tsv' % pdf))
        if folio is not None:
            folios.append((pdf, folio))
        for i, line in enumerate(lines):
            m = HEALTH.search(line)
            if not m:
                continue
            header = None
            for j in range(i - 1, max(-1, i - 12), -1):
                if is_header(lines[j]):
                    header = (j, lines[j].strip())
                    break
            # the seven ability rows start on the Health line and run down
            rows, k = [], i
            while k < len(lines) and len(rows) < 7 and k < i + 16:
                r = ABILITY_ROW.match(lines[k])
                if r:
                    rows.append((int(r.group(1)), r.group(2)))
                k += 1
            karma = None
            for k2 in range(i, min(len(lines), i + 8)):
                km = KARMA.search(lines[k2])
                if km:
                    karma = km.group(1)
                    break
            nums = [n for n, _ in rows]
            check = None
            if len(nums) == 7 and num(m.group(1)) is not None:
                h_ok = sum(nums[:4]) == num(m.group(1))
                k_ok = karma is not None and num(karma) is not None and sum(nums[4:]) == num(karma)
                rank_ok = all(RANK_NUMBER.get(code) in (None, n) for n, code in rows)
                check = {'health': h_ok, 'karma': k_ok if num(karma or '') is not None else None, 'ranks': rank_ok}
            blocks.append({
                'pdf': pdf, 'printed': pdf - off, 'line': i + 1,
                'header': header[1] if header else None,
                'header_distance': (i - header[0]) if header else None,
                'rows_read': len(rows), 'health': m.group(1), 'karma': karma, 'check': check,
            })
    votes = {}
    for pdf, printed in folios:
        votes.setdefault(pdf - printed, []).append(pdf)

    idx = book['index']
    alias = book.get('index_aliases', {})
    found = {}
    for b in blocks:
        if b['header']:
            key = norm(re.sub(r'\([^)]*\)', '', b['header']))
            found.setdefault(key, []).append(b)

    def index_key(name):
        # Surname-first names ("Collins, Rusty") are printed surname-first in
        # the header too, so the index spelling is compared as it stands.
        return norm(re.sub(r'\([^)]*\)', '', alias.get(name, name)))

    index_hits, index_misses = [], []
    for name, pages in idx:
        k = index_key(name)
        hits = found.get(k, [])
        (index_hits if hits else index_misses).append({'name': name, 'index_pages': pages,
                                                       'block_pages': sorted({b['printed'] for b in hits})})
    indexed = {index_key(n) for n, _ in idx}
    unindexed = [b for b in blocks if b['header'] and norm(re.sub(r'\([^)]*\)', '', b['header'])) not in indexed]
    return {'slug': slug, 'offset_votes': {str(k): v for k, v in sorted(votes.items())},
            'blocks': blocks, 'index_hits': index_hits, 'index_misses': index_misses,
            'unindexed_blocks': unindexed}


def report(r):
    print('OFFSET votes (printed = PDF - k):')
    for k, pages in r['offset_votes'].items():
        print('  k=%s  %d pages%s' % (k, len(pages), '' if len(pages) > 5 else '  ' + str(pages)))
    b = r['blocks']
    print('\nBLOCKS: %d stat blocks (one Health = line each)' % len(b))
    print('  no header found above:  %d' % sum(1 for x in b if not x['header']))
    print('  fewer than 7 rows read: %d' % sum(1 for x in b if x['rows_read'] < 7))
    checked = [x for x in b if x['check']]
    print('  checkable:              %d' % len(checked))
    print('  Health = F+A+S+E holds: %d' % sum(1 for x in checked if x['check']['health']))
    print('  Karma = R+I+P holds:    %d' % sum(1 for x in checked if x['check']['karma']))
    print('  every rank code agrees: %d' % sum(1 for x in checked if x['check']['ranks']))
    print('\nINDEX: %d names found as headers, %d not found; %d headers not in the index'
          % (len(r['index_hits']), len(r['index_misses']), len(r['unindexed_blocks'])))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('slug')
    ap.add_argument('--json', action='store_true')
    a = ap.parse_args()
    r = survey(a.slug)
    print(json.dumps(r, indent=1)) if a.json else report(r)
