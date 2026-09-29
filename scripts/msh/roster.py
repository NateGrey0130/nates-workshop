# -*- coding: utf-8 -*-
"""Parse a cached Marvel sourcebook into its character entries.

    python scripts/msh/roster.py ma1              # parse, check, write, report
    python scripts/msh/roster.py ma1 --show Nightcrawler   # one entry as JSON
    python scripts/msh/roster.py ma1 --failures   # every entry a check refuses

Reads the TSV that scripts/msh/ocr-book.py cached and the book's entry in
scripts/msh/books.json. Writes $WORKSHOP_MSH_CACHE/books/<slug>/roster.json,
which holds the book's prose and so is never committed. The committed half is
scripts/msh/<slug>-overrides.json: hand corrections, each citing its page.

HOW A BOOK BECOMES ENTRIES, and why in this order.

1. Words, from TSV geometry, never from Tesseract's reading order. --psm 3
   splits a FASERIP grid into a column of letters, a column of numbers and a
   column of codes on a quarter of the blocks (survey: 48 of 184), so the
   order it emits is not the order on the page.
2. Columns, per page, by the two x-ranges with the least ink in the body
   region: the gutters. A word belongs to the column its centre falls in.
3. Lines, per column, by clustering word centres in y; then the book as ONE
   stream: page 1 column 1, 2, 3, page 2 column 1 ... A column or page break
   is never an entry break. Magneto runs from p.6 into p.7 and Phoenix
   (original) has its grid at the foot of one column and its powers at the
   head of the next; both are one entry here because nothing cuts at a column.
4. Headers are lines set half again taller than the page's body text (39-40
   px against 26 at 300 dpi). An entry runs from a header to the next one.
5. A grid is seven consecutive rows of <letter> <number> <rank code>. Health,
   Karma, Resources and Popularity are read from the text to the right of rows
   F, S, R and P, wherever each label appears within the grid's lines.
6. Inside an entry: run-in labels (KNOWN POWERS:, TALENTS:, CONTACTS:,
   RUNNING <NAME>:) divide the text, and within KNOWN POWERS each paragraph
   that opens with a short capitalised phrase and a colon is one power.

CHECKS, run on every block and never silenced: each number agrees with its
rank code; Health = F+A+S+E; Karma = R+I+P. A block that fails is kept, marked,
and listed by --failures; the fix is an override citing the page, never a
change to the parser to make one block pass. The book itself misprints some
(survey: Northstar's Health, Poltergeist's S), and an override records the
printed value beside the corrected one.
"""
import argparse, collections, io, json, os, re, statistics, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = os.environ.get('WORKSHOP_MSH_CACHE') or os.path.join(ROOT, '.cache', 'msh')
REGISTRY = os.path.join(ROOT, 'scripts', 'msh', 'books.json')

# PB p.2: the number each rank's code stands for. Fb/Po/Go/Re are MA1's own
# misprints (books.json rank_aliases); Sh codes and Class ranks are exact.
RANK_NUMBER = {'Sh0': 0, 'Fe': 2, 'Fb': 2, 'Pr': 4, 'Po': 4, 'Ty': 6, 'Gd': 10, 'Go': 10,
               'Ex': 20, 'Rm': 30, 'Re': 30, 'In': 40, 'Am': 50, 'Mn': 75, 'Un': 100,
               'ShX': 150, 'ShY': 200, 'ShZ': 500, 'C-1000': 1000, 'C-3000': 3000, 'C-5000': 5000}
ABILITIES = ['F', 'A', 'S', 'E', 'R', 'I', 'P']
CODE = r'(?:C-?\d{3,4}|C[lI1]\s?\d{4}|Shift\s?[XYZ0]|Sh[XYZ0]|[A-Za-z]{1,2})'
# <row letter, up to 3 chars of OCR noise> <number> <code> [(<alt number> <alt code>)] <rest>
# The alternate is the book's own convention (printed p.2): a changed value
# is set in parentheses after the usual one, as in Magma's S 10 Gd(30Rm) or
# an armoured form. Codes are read loosely and made
# canonical by canon(); a code OCR mangled past recognition ("20 x") is kept
# as unread and the number stands.
ROW = re.compile(r'^\s*(\S{1,3})\s+([0-9OolI]{1,4})[\u00b0\'\u2019:.,]?\s*[^\w\s(]{0,2}(' + CODE + r')(?![a-z])_?\s*'
                 r'(?:\(\s*([0-9OolI]{1,4})\s*(' + CODE + r')\s*\))?\s*(.*)$')
CANON = {k.lower(): k for k in RANK_NUMBER}
CANON.update({'shift0': 'Sh0', 'shiftx': 'ShX', 'shifty': 'ShY', 'shiftz': 'ShZ',
              'c1000': 'C-1000', 'c3000': 'C-3000', 'c5000': 'C-5000'})
# ME1 prints a Class rank as "Cl 1000", which OCR reads as CI or C1 too
CANON.update({p + n: 'C-' + n for p in ('cl', 'ci', 'c1') for n in ('1000', '3000', '5000')})


def canon(code):
    return CANON.get(re.sub(r'[\s-]', '', code).lower()) if code else None
LABELS = ('Health', 'Karma', 'Resources', 'Popularity')
# The printed '=' OCRs as ':', a quote or a dash often enough to matter:
# Binary's "Health " 110" hid both her blocks from the first survey count.
EQ = r'\s*[=:"\u201c\u201d-]'
LABEL_RX = {k: re.compile(('Heal?th' if k == 'Health' else k) + EQ +r'\s*(.+?)\s*(?=(?:Health|Karma|Resources|Popularity)' + EQ + r'|$)') for k in LABELS}
RUN_IN = re.compile(r"^([A-Z][A-Z0-9 .,'&()/-]{1,60}?):\s*(.*)$")
SECTION = {'KNOWN POWERS': 'powers', 'POWERS': 'powers', 'TALENTS': 'talents', 'TALENT': 'talents',
           'CONTACTS': 'contacts', 'CONTACT': 'contacts', 'BACKGROUND': 'background'}


def section_of(label):
    """The entry section a run-in label opens, or None for a member's name.
    Labels can carry a name ("MOON-BOY AND DEVIL'S TALENTS", "RUNNING THE
    ORIGINAL PHOENIX") or be a note ("NOTE", "ADDITIONAL QUEEN STATISTICS")."""
    if label in SECTION:
        return SECTION[label]
    if label.startswith('RUNNING'):
        return 'running'
    for word, key in (('POWERS', 'powers'), ('TALENTS', 'talents'), ('CONTACTS', 'contacts')):
        if label.endswith(' ' + word):
            return key
    if label in ('NOTE', 'NOTES') or label.startswith(('ADDITIONAL ', 'NOTE ')):
        return 'notes'
    return None
POWER_HEAD = re.compile(r"^([A-Z][A-Za-z0-9'/&-]*(?:\s+(?:[A-Z(][A-Za-z0-9'()/&-]*|of|the|and|to|vs\.|in|a|an|with|from)){0,6}):\s*(.*)$")


def load_book(slug):
    books = json.load(io.open(REGISTRY, encoding='utf-8'))['books']
    if slug not in books:
        sys.exit('%s is not in %s' % (slug, REGISTRY))
    return books[slug]


def read_words(path):
    words, size = [], None
    for row in io.open(path, encoding='utf-8').read().splitlines()[1:]:
        f = row.split('\t')
        if len(f) < 12:
            continue
        if f[0] == '1':
            size = (int(f[8]), int(f[9]))
        elif f[0] == '5' and f[11].strip() and float(f[10]) >= 0:
            x, y, w, h = map(int, f[6:10])
            words.append({'x': x, 'y': y, 'w': w, 'h': h, 'c': float(f[10]), 't': f[11].strip()})
    return words, size


def gutters(words, width, ncol):
    """The x-positions of the ncol-1 gutters: the least-inked stretch near each
    expected boundary."""
    ink = [0] * (width + 1)
    for w in words:
        for x in range(max(0, w['x']), min(width, w['x'] + w['w'])):
            ink[x] += 1
    cuts = []
    for k in range(1, ncol):
        centre = width * k // ncol
        lo, hi = centre - width // 10, centre + width // 10
        best = min(range(lo, hi), key=lambda x: (sum(ink[x - 6:x + 7]), abs(x - centre)))
        cuts.append(best)
    return cuts


def lines_of(words):
    """Cluster a column's words into lines by vertical centre."""
    out = []
    for w in sorted(words, key=lambda w: w['y'] + w['h'] / 2):
        cy = w['y'] + w['h'] / 2
        if out and abs(cy - out[-1]['cy']) < 0.55 * max(18, statistics.median(x['h'] for x in out[-1]['w'])):
            out[-1]['w'].append(w)
            ys = [x['y'] + x['h'] / 2 for x in out[-1]['w']]
            out[-1]['cy'] = sum(ys) / len(ys)
        else:
            out.append({'w': [w], 'cy': cy})
    lines = []
    for ln in out:
        ws = sorted(ln['w'], key=lambda w: w['x'])
        lines.append({
            'text': ' '.join(w['t'] for w in ws),
            'x0': ws[0]['x'], 'x1': max(w['x'] + w['w'] for w in ws),
            'y0': min(w['y'] for w in ws), 'y1': max(w['y'] + w['h'] for w in ws),
            'h': statistics.median(w['h'] for w in ws if any(c.isalpha() for c in w['t'])) if any(any(c.isalpha() for c in w['t']) for w in ws) else statistics.median(w['h'] for w in ws),
            'conf': statistics.mean(w['c'] for w in ws),
        })
    return lines


def is_caps(text):
    letters = [c for c in re.sub(r'\([^)]*\)', '', text) if c.isalpha()]
    return len(letters) >= 2 and sum(c.isupper() for c in letters) / len(letters) >= 0.8


def is_header(line):
    """Set half again taller than the page's body text, confidently read, and
    not a grid row: the sideways junk Tesseract makes of a grid's letter
    column is tall too ('v-~wMNYT 30 Rm')."""
    text = line['text']
    letters = sum(c.isalpha() for c in text)
    if not (line['h'] >= 1.35 * line['body_h'] and line['conf'] >= 60 and letters >= 3
            and not ROW.match(text) and not ANCHOR.search(text)):
        return False
    # On a few pages Tesseract boxes ordinary prose words taller than they
    # are (41-45 px on pp. 10, 15, 42), so height alone is not enough: a
    # header is in capitals, or a short phrase in title case ("Heartbreak
    # Hotel", "Mark I Sentinel", "(Original Organization)"), and never a line
    # of a stat table ("Endurance Ex").
    words = re.findall(r"[A-Za-z(][\w'().:-]*", text)
    if any(w.strip('():') in STAT_WORDS for w in words):
        return False
    # An illustration's caption: the trademark sign OCRs as a closing quote
    # ('Time Bomb"'), and art itself reads as short capital noise ('RL WE CS').
    if text.rstrip().endswith(('"', '\u201d')) or not any(len(re.sub(r'\W', '', w)) >= 3 for w in words):
        return False
    return is_caps(text) or (len(words) <= 5 and all(w[0].isupper() or w[0] == '(' or w in ('of', 'the', 'and') for w in words))


STAT_WORDS = {'Fighting', 'Agility', 'Strength', 'Endurance', 'Reason', 'Intuition', 'Psyche',
              'Health', 'Karma', 'Resources', 'Popularity'}


def section_starts(book):
    """{printed page: section title}: where each Contents section begins, with
    the Contents' errata applied. A team's name is set in the page banner,
    which is not read, so the stream gets a synthetic header there; without
    it a team's tiers and members land in the entry before the team."""
    fixed = {e['section']: e['page'] for e in book.get('contents_errata', [])}
    out = {}
    for section, sub, page in book.get('sections', []):
        title = sub or section
        out[fixed.get(title, page)] = title
    return out


def page_stream(book, slug):
    tsv = os.path.join(CACHE, 'books', slug, 'tsv')
    first, last = book.get('character_pages', [1 - book['offset'], book['pdf_pages'] - book['offset']])
    starts = section_starts(book)
    stream = []
    for pdf in range(first + book['offset'], last + book['offset'] + 1):
        path = os.path.join(tsv, 'p%03d.tsv' % pdf)
        if not os.path.exists(path):
            continue
        if pdf - book['offset'] in starts:
            stream.append({'text': starts[pdf - book['offset']], 'synthetic': True, 'big': True, 'pdf': pdf,
                           'printed': pdf - book['offset'], 'col': 0, 'x0': 0, 'x1': 0, 'y0': 0, 'y1': 0,
                           'h': 0, 'conf': 100, 'left': 0, 'body_h': 0, 'col_x0': 0, 'col_x1': 0})
        words, (W, H) = read_words(path)
        # The chevron banner across the top and the folio at the foot are not
        # body text; the banner's OCR is noise and its title is recorded in
        # books.json sections instead.
        body = [w for w in words if w['y'] > 0.10 * H and w['y'] + w['h'] < 0.935 * H
                and '\u2122' not in w['t'] and '\u00ae' not in w['t']]
        if not body:
            continue
        # the page's typical word height, ascenders and capitals included:
        # 26 px at 300 dpi against 39-40 for a header
        body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
        cuts = gutters(body, W, book['columns'])
        edges = [0] + cuts + [W]
        for c in range(book['columns']):
            col = [w for w in body if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
            lines = [l for l in lines_of(col) if l['conf'] >= 45 and any(ch.isalnum() for ch in l['text'])]
            if not lines:
                continue
            left = sorted(l['x0'] for l in lines)[len(lines) // 10]
            for l in lines:
                l.update(pdf=pdf, printed=pdf - book['offset'], col=c + 1, left=left, body_h=body_h,
                         col_x0=max(0, edges[c] if c else left - 20), col_x1=edges[c + 1])
                l['big'] = is_header(l)
                stream.append(l)
    # A run-in RUNNING label set on two lines ("RUNNING MOON-BOY AND DEVIL" /
    # "DINOSAUR: ...") is one label; left apart, the second half reads as a
    # member's run-in name.
    out = []
    for l in stream:
        if out and re.match(r"^RUNNING [A-Z .,'&-]+$", out[-1]['text']) and RUN_IN.match(l['text']):
            out[-1] = dict(out[-1], text=out[-1]['text'] + ' ' + l['text'])
            continue
        out.append(l)
    return out


def fix_digits(s):
    return int(s.replace('O', '0').replace('o', '0').replace('l', '1').replace('I', '1'))


ANCHOR = re.compile(r'Heal?th' + EQ + r'?\s*\d')      # "Heath: 80", ME1 printed 18


def rows_from(texts):
    """The grid's rows from its lines. A line that is not a row is the tail of
    a value that wrapped ('Resources: Ex' then '(20)'), so it joins the row
    above rather than breaking the run.

    Three ways ME1's crops read, mended first: a Shift rank set on two lines
    ("I 500 Shift" / "Z"), a row letter set against its number ("R150 Shift X",
    "A2 Fe"), and Incredible set against its number ("40In"), whose I the
    number would otherwise take as a 1."""
    texts = list(texts)
    for n in range(len(texts) - 1, 0, -1):
        nxt = re.match(r'^\s*([XYZ0])\b\s*(.*)$', texts[n])
        if nxt and re.search(r'\bShift\s*$', texts[n - 1]):
            texts[n - 1] = texts[n - 1].rstrip() + ' ' + nxt.group(1) + ' ' + nxt.group(2)
            del texts[n]
    texts = [re.sub(r'(?<=\d)In(?![a-z])', ' In', re.sub(r'^(\s*[FASERIP|$])(?=\d)', r'\1 ', t)) for t in texts]
    rows = []
    for t in texts:
        m = ROW.match(t)
        if m and len(rows) < 7:
            row = {'letter': m.group(1), 'number': fix_digits(m.group(2)), 'code': canon(m.group(3)),
                   'printed_code': m.group(3), 'rest': m.group(6)}
            if m.group(4):
                row['alt'] = {'number': fix_digits(m.group(4)), 'code': canon(m.group(5))}
            rows.append(row)
        elif rows:
            rows[-1]['rest'] += ' ' + t.strip()
    return rows


class GridReader:
    """Re-reads a stat grid from the page image. Tesseract's page layout pass
    reads the grid's letter and number columns as sideways junk on some pages
    ('v-pDmorn DMAAMDAMAAAD'), so the words are not in the TSV at all. A crop
    of just the grid, read as one uniform block (--psm 6), comes back row by
    row. Each crop's text is cached beside the page's TSV."""

    def __init__(self, book, slug):
        self.dir = os.path.join(CACHE, 'books', slug, 'grid')
        os.makedirs(self.dir, exist_ok=True)
        self.pdf_path = os.path.join(book['source_pdf_dir'], book['source_pdf'])
        self.doc = None

    def read(self, pdf, box, psm='6'):
        x0, y0, x1, y1 = (int(v) for v in box)
        path = os.path.join(self.dir, 'p%03d-%d-%d-%d-%d%s.txt' % (pdf, x0, y0, x1, y1, '' if psm == '6' else '-psm' + psm))
        if not os.path.exists(path):
            import pymupdf, subprocess, shutil
            if self.doc is None:
                self.doc = pymupdf.open(self.pdf_path)
            tess = shutil.which('tesseract') or r'C:\Program Files\Tesseract-OCR\tesseract.exe'
            s = 72 / 300
            png = path[:-4] + '.png'
            self.doc[pdf - 1].get_pixmap(dpi=300, clip=pymupdf.Rect(x0 * s, y0 * s, x1 * s, y1 * s)).save(png)
            r = subprocess.run([tess, png, 'stdout', '--psm', psm], capture_output=True)
            os.remove(png)
            io.open(path, 'w', encoding='utf-8', newline='\n').write(r.stdout.decode('utf-8', 'replace'))
        return [l for l in io.open(path, encoding='utf-8').read().splitlines() if l.strip()]


def grid_at(stream, i, reader):
    """If stream[i] is a grid's Health line, return (rows, first index after
    the grid). The grid's box runs from the Health line to the Popularity line
    in the same column, from the column's left edge to its gutter."""
    line = stream[i]
    if not ANCHOR.search(line['text']):
        return None, i
    j = i
    while j < min(len(stream), i + 12) and stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col']:
        if 'Popularity' in stream[j]['text'] or 'Popularlty' in stream[j]['text']:
            break
        j += 1
    else:
        return None, i
    if j >= len(stream) or stream[j]['pdf'] != line['pdf'] or 'Popular' not in stream[j]['text']:
        return None, i
    # A row line the TSV read in order starts the grid one or two lines above
    # the Health label when the F row's letters were split off.
    # The Health label can sit a little below the top of the F row it shares a
    # line with, so the box starts a line higher; the line it may take in from
    # above is prose, and rows_from ignores lines before the first row.
    top = line['y0'] - 45
    box = (line['col_x0'], top, line['col_x1'], stream[j]['y1'] + 10)
    rows = rows_from(reader.read(line['pdf'], box))
    if len(rows) != 7:
        rows = rows_from([s['text'] for s in stream[i:j + 1]])
    end = j + 1
    # skip stream lines that are the grid's sideways junk or its split columns
    while end < len(stream) and stream[end]['pdf'] == line['pdf'] and stream[end]['col'] == line['col'] \
            and stream[end]['y0'] < stream[j]['y1'] and not RUN_IN.match(stream[end]['text']):
        end += 1
    return (rows[:7] if len(rows) >= 7 else None), end


def secondary(rows, stream, end):
    """Health, Karma, Resources, Popularity as printed, from the text beside the
    rows, plus a Popularity that wraps to the line after the grid."""
    text = ' '.join(r['rest'] for r in rows)
    out = {}
    for k in LABELS:
        m = LABEL_RX[k].search(text)
        # OCR hangs an underscore or a stray mark off the column's edge
        v = re.sub(r'^[\s:=]+|[\s_|~:=.,\\]+$', '', m.group(1)).strip() if m else None
        # the printed minus sign comes back as U+FFFD ('-\ufffd20', '\ufffd10')
        out[k.lower()] = re.sub('-?\ufffd(?=\\s*\\d)', '-', v) if v else v
        # an illustration beside the grid reads as a letter or two after a
        # Health, Karma or Popularity ('330 k', '100 Sc': ME1's Beta Ray Bill,
        # printed 6; '0 or': the Grandmaster, Resource p.9)
        if v and k in ('Health', 'Karma', 'Popularity'):
            out[k.lower()] = re.sub(r'(?<=\d)(?:\s+[A-Za-z]{1,2})+$', '', out[k.lower()])
    if end < len(stream) and stream[end]['text'].startswith('(') and out.get('popularity'):
        out['popularity'] += ' ' + stream[end]['text']
        end += 1
    if end < len(stream) and out.get('popularity') and out['popularity'].count('(') > out['popularity'].count(')') \
            and ')' in stream[end]['text'] and stream[end]['col'] == stream[end - 1]['col']:
        # the parenthesis wraps to the line after the grid: '15 (95 among Inhu-'
        # then 'mans)', '0 (And' then 'dropping)' (ME1, Resource p.4, Adventure p.15)
        tail = stream[end]['text'].strip()
        p = out['popularity']
        out['popularity'] = p[:-1] + tail if p.endswith('-') and tail[:1].islower() else p + ' ' + tail
        end += 1
    return out, end


def as_int(s):
    if s is None:
        return None
    m = re.match(r'^[-\u2013\u2014]?\s*\d+$', s.replace(' ', ''))
    return int(s.replace(' ', '').replace('\u2013', '-').replace('\u2014', '-')) if m else None


def check(block):
    nums = [a['number'] for a in block['abilities']]
    if None in nums:
        return {'ranks': [], 'health': None, 'karma': None, 'unread': True, 'ok': False}
    h, k = as_int(block['health']), as_int(block['karma'])
    res = {
        'ranks': [ABILITIES[n] for n, a in enumerate(block['abilities'])
                  if RANK_NUMBER.get(a['code']) not in (None, a['number'])],
        'codes_unread': [ABILITIES[n] for n, a in enumerate(block['abilities']) if a['code'] is None],
        'health': None if h is None else sum(nums[:4]) == h,
        'karma': None if k is None else sum(nums[4:]) == k,
    }
    res['ok'] = not res['ranks'] and res['health'] is not False and res['karma'] is not False
    return res


def parse(slug):
    book = load_book(slug)
    if book.get('layout') == 'roster-booklet':
        # a boxed module's Roster Booklet (MHSP1): scripts/msh/booklet.py reads
        # it into the same entries; nothing below runs for it
        import booklet
        stream, entries = booklet.parse(book, slug)
        return book, stream, entries
    if book.get('layout') == 'grid-booklets':
        # MA1's grids in a boxed module's booklets (ME1): scripts/msh/gridbooks.py
        # builds the streams and runs read_entries() below over each
        import gridbooks
        stream, entries = gridbooks.parse(book, slug)
        return book, stream, entries
    stream = page_stream(book, slug)
    entries = read_entries(stream, GridReader(book, slug))
    finish(entries)
    return book, stream, entries


def read_entries(stream, reader, opponent=False):
    """The book's entries from one stream. With opponent set, the stream is an
    adventure's page with a character statted in its prose (ME1's chapters): an
    entry is read from its header through its grid and powers, and ends where
    the adventure's own text resumes - an indented paragraph, or a run-in that
    is not one of the entry's sections - after which lines are dropped until
    the next header."""
    entries, cur = [], None

    def start(kind, name, line):
        nonlocal cur
        cur = {'kind': kind, 'header': name, 'pages': [line['printed']], 'identity': [],
               'blocks': [], 'sections': {}, 'powers': [], 'members': [], 'prose': [], '_sec': None}
        entries.append(cur)

    def add_page(line):
        if cur and line['printed'] not in cur['pages']:
            cur['pages'].append(line['printed'])

    i = 0
    while i < len(stream):
        line = stream[i]
        anchored = bool(ANCHOR.search(line['text']))
        rows, nxt = grid_at(stream, i, reader) if anchored else (None, i)
        if anchored and nxt > i:
            if rows is None:
                # a grid is here and could not be read: keep it, so the count
                # of blocks never silently drops, and --failures names it
                rows = [{'letter': l, 'number': None, 'code': None, 'rest': ''} for l in ABILITIES]
                rows[0]['rest'] = ' '.join(s['text'] for s in stream[i:nxt])
            label = None
            if cur is None:
                start('unheaded', None, line)
            # a small all-caps line right above a grid names a sub-block:
            # HUMAN FORM, TOP FIGHTERS, ANDREAS, AVERAGE MUTATE ABILITIES
            prev = stream[i - 1] if i else None
            if prev and not prev['big'] and prev['text'].upper() == prev['text'] and any(c.isalpha() for c in prev['text']) \
                    and cur['blocks'] + [None] and not RUN_IN.match(prev['text']):
                label = prev['text'].strip()
            sec, end = secondary(rows, stream, nxt)
            block = {'label': label, 'page': line['printed'], 'pdf': line['pdf'], 'col': line['col'],
                     'abilities': [{k: r[k] for k in ('letter', 'number', 'code', 'printed_code', 'alt') if k in r}
                                   for r in rows]}
            block.update(sec)
            block['check'] = check(block)
            cur['blocks'].append(block)
            if label and cur['identity'] and cur['identity'][-1] == label:
                cur['identity'].pop()
            add_page(line)
            cur['_sec'] = 'after-grid'
            i = end
            continue
        if line['big']:
            # A header set on two lines is one header when both halves are in
            # capitals or the second is its variant in parentheses:
            # "21st CENTURY / ALPHA SENTINEL / (Warrior type)". A mixed-case
            # sub-banner above a name ("Villains" over "ARCADE") is not part
            # of it, and becomes a heading of its own.
            name = line['text']
            j = i + 1
            while j < len(stream) and stream[j]['big'] and not line.get('synthetic') \
                    and stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col'] \
                    and stream[j]['y0'] - line['y1'] < 1.5 * line['h'] \
                    and is_caps(line['text']) and (stream[j]['text'].startswith('(') or (
                        is_caps(stream[j]['text']) and max(line['h'], stream[j]['h']) <= 1.18 * min(line['h'], stream[j]['h']))):
                # A team's sub-heading is set larger than a name (51 px against
                # 38-42): "X-FACTOR STUDENTS" over "COLLINS, RUSTY", "VILLAINS"
                # over "ARCADE". The halves of one name are within a tenth of
                # each other (NERAMANI, / PRINCESS-MAJESTRIX / LILANDRA).
                name += ' ' + stream[j]['text']
                line = stream[j]
                j += 1
            start('heading' if line.get('synthetic') else 'entry', name.strip(), stream[i])
            i = j
            continue
        if cur is None:
            i += 1
            continue
        text = line['text']
        m = RUN_IN.match(text)
        if opponent and cur['blocks']:
            prev_text = stream[i - 1]['text'].rstrip() if i else ''
            # the chapter's run-ins print a curly apostrophe ("CLAUD VICTOR'S:")
            r = RUN_IN.match(text.replace('\u2019', "'"))
            resumes = (r and line['x0'] - line['left'] < 40 and not section_of(r.group(1).strip())) or (
                line['x0'] - line['left'] >= 25 and prev_text.endswith(('.', '!', '?', '"', '\u201d')))
            if resumes:
                cur = None
                i += 1
                continue
        add_page(line)
        if m and line['x0'] - line['left'] < 40:
            label = m.group(1).strip()
            key = section_of(label)
            if key:
                cur['_sec'] = key
                cur['sections'].setdefault(key, [])
                if m.group(2):
                    cur['sections'][key].append(m.group(2))
                i += 1
                continue
            if cur['blocks'] or cur['kind'] == 'entry':
                # a run-in name that is not a section: a member without a block
                cur['members'].append({'name': label, 'page': line['printed'], 'text': [m.group(2)]})
                cur['_sec'] = 'member'
                i += 1
                continue
        sec = cur['_sec']
        if not cur['blocks'] and sec is None and len(cur['identity']) < 3:
            cur['identity'].append(text)
        elif sec == 'member':
            cur['members'][-1]['text'].append(text)
        elif sec == 'powers':
            pm = POWER_HEAD.match(text)
            # Power paragraphs are set flush like their continuation lines, so
            # a new power is told by the line before it ending a sentence (or
            # the section having just opened), not by indentation.
            prev_text = stream[i - 1]['text'].rstrip() if i else ''
            paragraph_start = (line['x0'] - line['left'] < 25
                               and (not cur['powers'] or prev_text.endswith(('.', ':', ')', '"', '\u201d', '!'))))
            if pm and paragraph_start and len(pm.group(1)) <= 40:
                cur['powers'].append({'name': pm.group(1), 'text': [pm.group(2)]})
            elif cur['powers']:
                cur['powers'][-1]['text'].append(text)
            else:
                cur['sections'].setdefault('powers', []).append(text)
        elif sec in ('talents', 'contacts', 'running', 'background', 'notes'):
            cur['sections'][sec].append(text)
        else:
            cur['prose'].append(text)
        i += 1
    return entries


def finish(entries):
    # An entry with nothing in it is a caption the header test let through
    # ("Scarlet" over the Scarlet Witch's picture, p.59): drop it, and count it.
    empty = [e for e in entries if not (e['identity'] or e['blocks'] or e['prose'] or e['sections']
                                        or e['powers'] or e['members'])]
    entries[:] = [e for e in entries if e not in empty]
    for e in entries:
        e.pop('_sec')
        for p in e['powers']:
            p['text'] = join_text(p['text'])
        for m in e['members']:
            m['text'] = join_text(m['text'])
        e['sections'] = {k: join_text(v) for k, v in e['sections'].items()}
        e['prose'] = join_text(e['prose'])


def apply_overrides(slug, entries):
    """Apply scripts/msh/<slug>-overrides.json. Returns the overrides that
    matched nothing, which main() reports: an override that no longer finds its
    block is a parser change that moved the block, and must not pass quietly."""
    path = os.path.join(ROOT, 'scripts', 'msh', '%s-overrides.json' % slug)
    if not os.path.exists(path):
        return []
    unmatched = []
    for o in json.load(io.open(path, encoding='utf-8'))['overrides']:
        m = o['match']
        if 'summary' in m or 'row' in m:
            continue                    # a Reference Summary misprint (booklet.coverage) or a text fix (npcs.text_fixes)
        hits = [(e, b) for e in entries for b in e['blocks']
                if b['page'] == m['page'] and (e['header'] or '').upper().startswith(m['header'].upper())
                and ('label' not in m or (b['label'] or '').upper() == m['label'].upper())
                and ('kind' not in m or b.get('kind') == m['kind'])]
        if o['verdict'] == 'table':
            hits = [(e, None) for e in entries
                    if m['page'] in e['pages'] and (e['header'] or '').upper().startswith(m['header'].upper())]
        if len(hits) != 1:
            unmatched.append((o, len(hits)))
            continue
        e, b = hits[0]
        if o['verdict'] == 'label':
            b['label'] = o['label']
        elif o['verdict'] == 'rows':
            # a grid that prints fewer than seven rows (ME1's Oolafat: F, A, S
            # and E, then one line for R, I and P): its rows as the page gives
            # them, a row it does not print as null
            b['abilities'] = [{'letter': l, 'number': n, 'code': c, 'printed_code': c} for l, n, c in o['abilities']]
            b.update({k: o[k] for k in ('health', 'karma', 'resources', 'popularity')})
            b['override'] = {k: o[k] for k in ('verdict', 'field', 'printed', 'corrected') if k in o}
            b['check'] = dict(check(b), known=o['verdict'], ok=True)
        elif o['verdict'] == 'table':
            t = o['block']
            block = {'label': t['label'], 'page': m['page'], 'kind': 'table',
                     'abilities': [{'letter': l, 'number': n, 'code': c} for l, n, c in t['abilities']],
                     'health': t['health'], 'karma': t['karma'], 'resources': t['resources'],
                     'popularity': t['popularity'], 'override': o['verdict']}
            block['check'] = {'ok': True, 'known': 'table'}
            target = next((x for x in entries if (x['header'] or '').upper() == o['entry'].upper()), e)
            target['blocks'].append(block)
            if target is not e:
                entries.remove(e)
        else:
            # 'also': a second value of the same block kept as printed (ME1's
            # Ghoul Captain: a misprinted Agility and a Karma 0)
            b['override'] = {k: o[k] for k in ('verdict', 'field', 'printed', 'corrected', 'also') if k in o}
            b['check']['known'] = o['verdict']
            b['check']['ok'] = True
    return unmatched


def index_misses(book, entries):
    """Index names found nowhere in the parse. A name is found when it is an
    entry's header, a member's run-in name or a sub-block's label, compared
    without its parenthetical, in either name order ("Flynn, Alexander" is
    printed ALEXANDER FLYNN), and through the registry's index_aliases."""
    seen = set()
    for e in entries:
        names = [e['header'] or ''] + [m['name'] for m in e['members']] + [b['label'] or '' for b in e['blocks']]
        for n in names:
            seen.add(norm(re.sub(r'\([^)]*\)', '', n)))
    alias = book.get('index_aliases', {})
    first, last = book.get('character_pages', [-10 ** 6, 10 ** 6])
    out = []
    for name, pages in book.get('index', []):
        if not any(first <= p <= last for p in pages):
            continue                    # the Danger Room, p.85: items are phase 6, not this range
        n = alias.get(name, name)
        forms = {norm(re.sub(r'\([^)]*\)', '', n))}
        if ', ' in n:
            surname, given = n.split(', ', 1)
            forms.add(norm(re.sub(r'\([^)]*\)', '', given + ' ' + surname)))
        # a header may carry more than the index name: "NIMROD (Ultimate Sentinel
        # Robot)", "LILANDRA (c)", "AGUILA, EL (The Eagle)"
        if not any(f in seen or any(s.startswith(f + ' ') or s == f for s in seen) for f in forms):
            out.append(name)
    return out


def join_text(parts):
    out = ''
    for p in parts:
        p = p.strip()
        if not p:
            continue
        if out.endswith('-') and not out.endswith(' -') and p[:1].islower():
            out = out[:-1] + p
        else:
            out = (out + ' ' + p) if out else p
    return out


def norm(s):
    return re.sub(r'[^a-z0-9]+', ' ', (s or '').lower()).strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('slug')
    ap.add_argument('--show')
    ap.add_argument('--failures', action='store_true')
    a = ap.parse_args()
    book, stream, entries = parse(a.slug)
    unmatched = apply_overrides(a.slug, entries)
    if a.show:
        for e in entries:
            if norm(a.show) in norm(e['header']):
                print(json.dumps(e, indent=1, ensure_ascii=False))
        return
    out = os.path.join(CACHE, 'books', a.slug, 'roster.json')
    io.open(out, 'w', encoding='utf-8', newline='\n').write(json.dumps({'slug': a.slug, 'entries': entries}, indent=1, ensure_ascii=False) + '\n')
    blocks = [(e, b) for e in entries for b in e['blocks']]
    bad = [(e, b) for e, b in blocks if not b['check']['ok']]
    if a.failures:
        for e, b in bad:
            print('p%-3s %-32s %-22s %s' % (b['page'], (e['header'] or '(none)')[:32], (b['label'] or '')[:22],
                  json.dumps({k: v for k, v in b['check'].items() if k != 'ok'})))
        return
    known = collections.Counter(b['check'].get('known') for e, b in blocks if b['check'].get('known'))
    print('%s: %d stream lines, %d entries, %d stat blocks' % (a.slug, len(stream), len(entries), len(blocks)))
    print('  entries with a block: %d; without: %d; members without a block: %d'
          % (sum(1 for e in entries if e['blocks']), sum(1 for e in entries if not e['blocks']),
             sum(len(e['members']) for e in entries)))
    print('  blocks passing every check: %d; known from the overrides: %s; FAILING: %d'
          % (len(blocks) - len(bad) - sum(known.values()), dict(known) or 0, len(bad)))
    print('  powers: %d across %d entries' % (sum(len(e['powers']) for e in entries), sum(1 for e in entries if e['powers'])))
    for o, n in unmatched:
        print('  OVERRIDE MATCHES %d BLOCKS, not 1: %s' % (n, json.dumps(o['match'])))
    missing = index_misses(book, entries)
    first, last = book.get('character_pages', [-10 ** 6, 10 ** 6])
    in_range = [n for n, pages in book.get('index', []) if any(first <= p <= last for p in pages)]
    if book.get('layout') == 'roster-booklet':
        # no printed index: the Reference Summary chart is the checklist
        import booklet
        path = os.path.join(ROOT, 'scripts', 'msh', '%s-overrides.json' % a.slug)
        lines, missed = booklet.coverage(book, entries, json.load(io.open(path, encoding='utf-8'))['overrides'] if os.path.exists(path) else [])
        print('\n'.join(lines))
        missing = missing or (['the Reference Summary'] if missed else [])
    elif book.get('layout') == 'grid-booklets':
        # no printed index: the Contents, the opponents and the Summary are the checklists
        import gridbooks
        path = os.path.join(ROOT, 'scripts', 'msh', '%s-overrides.json' % a.slug)
        lines, missed = gridbooks.coverage(book, entries, json.load(io.open(path, encoding='utf-8'))['overrides'] if os.path.exists(path) else [])
        print('\n'.join(lines))
        missing = ['a checklist'] if missed else []
    else:
        print('  printed index: %d names in printed %d-%d, %d found as an entry, member or sub-block%s'
              % (len(in_range), first, last, len(in_range) - len(missing),
                 '' if not missing else '; NOT FOUND: ' + ', '.join(missing)))
    print('  wrote %s' % out)
    if bad or unmatched or missing:
        sys.exit(1)


if __name__ == '__main__':
    main()
