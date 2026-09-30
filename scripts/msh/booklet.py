# -*- coding: utf-8 -*-
"""Parse a Marvel module whose characters are a Roster Booklet (MHSP1).

    python scripts/msh/roster.py mhsp1     # roster.py hands this book to here

scripts/msh/roster.py reads a book laid out like MA1: a three-column stream,
headers half again taller than the text, and a FASERIP grid of numbers and
rank codes. A book whose registry entry says "layout": "roster-booklet" is
read here instead, and comes back as the same entries roster.py writes to
roster.json, so the rest of the chain does not need to know which layout a
book had. MA1's path through roster.py is not touched by any of this.

WHAT A ROSTER BOOKLET IS (apps/marvel-heroes/docs/surveys/mhsp1.md):
  - a boxed module of several booklets, each numbered from 1, so every page
    is (part, printed page); the registry's `parts` map PDF pages to both
  - two entries a page, one above and one below a heavy rule, each on a grid
    of three columns beside an illustration
  - a block of seven "Fighting: EXCELLENT" rows with NO numbers, then
    Health:, Karma:, Resources: and Popularity:, each with a colon
  - "Powers:", then run-in powers in capitals ending in a period
    ("ARMORED FORM."), then "Talents:" and "Background:" (or "Background.")
  - a one-line grid for a second form (a human alter ego): a row of the
    letters F A S E R I P over a row of rank codes, then Health and Karma
  - a Reference Summary chart of every character (registry
    `reference_summary`), the book's only coverage list; seven characters
    have nothing else
  - running notes for most characters in another booklet (registry
    `running`), each opening with the name in capitals and a trademark sign

THE NUMBERS ARE DERIVED. The book prints ranks only. Each ability's number is
the rank's standard number (apps/marvel-heroes/data/ranks.json), and every
block says so (`rank_only`). The book's own arithmetic still checks it:
Health = F+A+S+E and Karma = R+I+P hold on every block when the ranks are
read this way, which is the evidence that this is how the book computed them.
A block that fails is kept and listed by --failures, exactly as in roster.py.
"""
import io, json, os, re, statistics

import roster

RANKS = os.path.join(roster.ROOT, 'apps', 'marvel-heroes', 'data', 'ranks.json')
ABILITY_LABELS = ['Fighting', 'Agility', 'Strength', 'Endurance', 'Reason', 'Intuition', 'Psyche']
TM = '\u2122\ufffd'
# a word ending in the trademark sign as Tesseract reads it: the sign itself,
# U+FFFD, or a stray closing quote; a name is in capitals before it
TRADEMARK = re.compile(r'[' + TM + r']|(?<=[A-Z])(?:TM|["\u201d])(?=\W|$)')
STAT_LINE = re.compile(r'^\W{0,2}(Fighting|Agility|Strength|Endurance|Reason|Intuition|Psyche|Health|Karma|Resources?|Popularity)\s*[:;.,]\s*(.*)$')
SECTION_LINE = re.compile(r'^(Powers|Talents|Background)\s*[:.;]\s*(.*)$')
POWER_HEAD = re.compile(r"^([A-Z][A-Z0-9'\u2019 /&-]{1,40}[A-Z0-9])\.\s+(.*)$")
NOISE = re.compile(r'^(\d{3,}\S*|ISBN\b.*|\d{3}-\d+-\S+|PROOF|OF PURCHASE)$')


def ladder(book):
    """{printed spelling: (roster.py code, standard number)} for every spelling
    the registry's rank_aliases lists. The code is roster.py's (C-1000, not
    ranks.json's CL1000), so a block reads the same whichever parser made it."""
    ranks = {r['id']: r for r in json.load(io.open(RANKS, encoding='utf-8'))['ranks']}
    code = {'shift-0': 'Sh0', 'class-1000': 'C-1000', 'class-3000': 'C-3000', 'class-5000': 'C-5000'}
    out = {}
    for spelling, rid in book['rank_aliases'].items():
        c = code.get(rid, ranks[rid]['abbr'])
        assert roster.RANK_NUMBER.get(c) == ranks[rid]['standard'], (spelling, c)
        out[spelling.upper()] = (c, ranks[rid]['standard'])
    return out


def part_of(book, pdf):
    for p in book['parts']:
        if p['pdf'][0] <= pdf <= p['pdf'][1]:
            return p
    return None


def pdf_of(book, part_name, printed):
    p = next(p for p in book['parts'] if p['name'] == part_name)
    return printed + p['offset']


def rules(book, pdf, height):
    """The y (in TSV pixels) of each heavy rule across the page: a row of the
    page image dark for more than 60% of its width. Each roster page has one,
    between its two entries."""
    import pymupdf
    doc = rules.doc = getattr(rules, 'doc', None) or pymupdf.open(os.path.join(book['source_pdf_dir'], book['source_pdf']))
    pm = doc[pdf - 1].get_pixmap(dpi=75, colorspace=pymupdf.csGRAY)
    w, s, out = pm.width, pm.samples, []
    for y in range(pm.height):
        run = best = 0
        for v in s[y * w:(y + 1) * w]:
            run = run + 1 if v < 100 else 0
            best = max(best, run)
        if best > 0.6 * w and not (out and y - out[-1] <= 3):
            out.append(y)
    return [y * height / pm.height for y in out]


def stream_of(book, slug, part, first, last, split_at_rules, min_conf=0, keep_unsure=False):
    """The part's pages first..last (printed) as one stream of lines: per page,
    each band between rules, each band's three columns left to right, each
    column top to bottom. Lines are roster.py's (lines_of), with where they are."""
    tsv = os.path.join(roster.CACHE, 'books', slug, 'tsv')
    out = []
    for printed in range(first, last + 1):
        pdf = pdf_of(book, part, printed)
        words, (W, H) = roster.read_words(os.path.join(tsv, 'p%03d.tsv' % pdf))
        # On the Roster Booklet, every word Tesseract kept, however unsure: a
        # header it read right at confidence 0 ("GALACTUS'S "CAT"", printed 9)
        # is still the header. The running notes share their columns with comic
        # panels, whose balloon lettering reads as unsure words (min_conf).
        body = [w for w in words if 0.03 * H < w['y'] and w['y'] + w['h'] < 0.955 * H and w['c'] >= min_conf]
        if not body:
            continue
        body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
        cuts = rules(book, pdf, H) if split_at_rules else []
        bands = list(zip([0] + cuts, cuts + [H]))
        for band, (y0, y1) in enumerate(bands):
            bw = [w for w in body if y0 <= w['y'] + w['h'] / 2 < y1]
            if not bw:
                continue
            edges = [0] + roster.gutters(bw, W, 3) + [W]
            for c in range(3):
                col = [w for w in bw if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
                lines = roster.lines_of(col)
                kept = []
                for n, l in enumerate(lines):
                    # a mark from the art ("A", "JB") is not a line of text
                    if sum(ch.isalnum() for ch in l['text']) < 3:
                        continue
                    # an unsure line is the illustration read as text, unless a
                    # stat block follows it: then it is that block's name
                    if l['conf'] < 45 and not keep_unsure and not any(re.match(r'^\W{0,2}Fighting', x['text']) for x in lines[n + 1:n + 4]):
                        continue
                    l.update(pdf=pdf, printed=printed, part=part, band=band, col=c + 1, body_h=body_h,
                             col_x0=edges[c], col_x1=edges[c + 1],
                             words=[w for w in col if l['y0'] <= w['y'] + w['h'] / 2 <= l['y1']])
                    kept.append(l)
                out.extend(mend_fused(book, slug, kept))
    return out


def fused_runs(lines):
    """Runs of lines Tesseract's page pass fused: each overlaps the next by more
    than half a line of text. On MHSP1's Adventure p.2 the layout pass read the
    Beyonder paragraph twice, as a top half and a bottom half of each printed
    line ("The B der i lien bei" over "le Peyonder Is an alien being"), and
    boxed some words across two printed lines. So a line is damaged when it
    overlaps a neighbour that way, is boxed half again as tall as the text, or
    is a sliver (a top half, 4 px tall). Damaged lines with at most one clean
    line between them are one stretch, re-read as one: a stretch cut in two
    puts a crop edge through a printed line. Three lines, or two where one is
    tall, make a run. A stat line is never in one: the stat block has its own
    crop."""
    def over(a, b):
        return b['y0'] < a['y1'] - 0.5 * a['body_h']

    def tall(l):                        # a box two printed lines deep
        return l['y1'] - l['y0'] > 1.7 * l['body_h']
    bad = []
    for n, l in enumerate(lines):
        if STAT_LINE.match(l['text']):
            bad.append(False)
            continue
        prev = lines[n - 1] if n else None
        nxt = lines[n + 1] if n + 1 < len(lines) else None
        bad.append(tall(l) or l['y1'] - l['y0'] < 0.5 * l['body_h']
                   or bool(prev and over(prev, l)) or bool(nxt and over(l, nxt)))
    runs, cur, gap = [], [], []
    for l, b in zip(lines, bad):
        if b:
            cur += gap + [l] if cur else [l]
            gap = []
        elif cur and not gap:
            gap = [l]                   # one clean line may sit inside a stretch
        else:
            runs.append(cur)
            cur, gap = [], []
    runs.append(cur)
    return [r for r in runs if len(r) >= 3 or (len(r) == 2 and any(tall(x) for x in r))]


def mend_fused(book, slug, lines):
    """A column's lines with every fused run replaced by a re-read of the run
    as a block (--psm 6), from a crop of the page image bounded by the clean
    lines above and below. The print is clean on these pages; only the page
    pass went wrong, and a block read comes back line by line. Line-by-line
    re-reads cannot mend it: a fused line's box spans two or three printed
    lines, so its crop does too."""
    runs = fused_runs(lines)
    if not runs:
        return lines
    reader = sure_text.readers.get(slug) or sure_text.readers.setdefault(slug, roster.GridReader(book, slug))
    # The crop is as wide as the column's clean text, not as the damaged lines:
    # those take in art beside the column ("begun. Vi bp (T MAKES THAT").
    damaged = {id(x) for run in runs for x in run}
    clean = [l for l in lines if id(l) not in damaged]
    lefts, rights = sorted(l['x0'] for l in clean), sorted(l['x1'] for l in clean)
    out, i = [], 0
    for run in runs:
        start = lines.index(run[0])
        out += lines[i:start]
        end = start + len(run)
        above = lines[start - 1] if start else None
        below = lines[end] if end < len(lines) else None
        y0 = max(min(x['y0'] for x in run) - 6, above['y1'] + 2 if above else 0)
        y1 = min(max(x['y1'] for x in run) + 6, below['y0'] - 2 if below else 10 ** 6)
        if len(clean) >= 5:
            x0, x1 = lefts[len(lefts) // 10] - 10, rights[len(rights) * 9 // 10] + 10
        else:
            x0, x1 = min(x['x0'] for x in run) - 10, max(x['x1'] for x in run) + 10
        # prose is never mostly capitals; balloon lettering caught in the crop is
        texts = [t for t in reader.read(run[0]['pdf'], (x0, y0, x1, y1)) if sum(ch.isalnum() for ch in t) >= 3
                 and sum(c.islower() for c in t) >= 0.35 * sum(c.isalpha() for c in t)]
        step = (y1 - y0) / max(1, len(texts))
        for k, t in enumerate(texts):
            ly0 = int(y0 + k * step)
            out.append(dict(run[0], text=t, x0=x0, x1=x1, y0=ly0, y1=int(ly0 + step), h=run[0]['body_h'], conf=100,
                            reread=True, words=[{'t': tok, 'c': 100, 'x': x0 + n, 'y': ly0, 'w': 1, 'h': run[0]['body_h']}
                                                for n, tok in enumerate(t.split())]))
        i = end
    return out + lines[i:]


PUNCT = '.,;:!?()"*' + ''.join(map(chr, (0x201c, 0x201d, 0x2018, 0x2019)))


def book_vocab(slug):
    """Every word the book prints at confidence 75 or better, lower case."""
    vocab = sure_text.vocab.get(slug)
    if vocab is None:
        vocab = sure_text.vocab[slug] = set()
        tsv = os.path.join(roster.CACHE, 'books', slug, 'tsv')
        for f in os.listdir(tsv):
            vocab.update(w['t'].strip(PUNCT).lower() for w in roster.read_words(os.path.join(tsv, f))[0] if w['c'] >= 75)
    return vocab


def wordy(text, slug, line):
    """Whether a line reads as the book's words: at least half its tokens of two
    letters or more are words the book prints confidently, here or elsewhere.
    Balloon lettering and art that pass the lower-case test do not ("YH =e a!
    Vi bp", under the Players' Briefing); a line of rare words read cleanly
    ("ascribed to men - emotions, morals, phys-") does."""
    # words split at anything not a letter: "men - emotions" is two, joined by a dash
    toks = [t for t in re.findall(r'[a-z]+', text.lower()) if len(t) >= 2 and not leader(t)]
    if line.get('reread'):
        # a block re-read has no confidence of its own: a long line of it is
        # the column's prose, and a short one is judged by the book's words
        # alone ("YH =e a!", "se Nall 64": art caught at a crop's edge)
        # (of three letters or more: art also reads as "My y f", "a a a ag al")
        long = [t for t in toks if len(t) >= 3]
        return len(toks) >= 5 or (bool(long) and sum(t in book_vocab(slug) for t in long) >= 0.5 * len(long))
    # read confidently on this line counts too, from three letters: art reads as
    # confident two-letter fragments (") v My y f a a a ag * al)", printed 5)
    sure = {w['t'].strip(PUNCT + '|-').lower() for w in line['words'] if w['c'] >= 75}
    return not toks or sum(t in book_vocab(slug) or (t in sure and len(t) >= 3) for t in toks) >= 0.5 * len(toks)


def sure_text(line, book, slug, prev=None):
    """A line of prose without the words Tesseract was unsure of. Prose reads at
    92 or better; balloon lettering and art that share a line read lower ("vex",
    61). A word read at 50-75 is kept when the book has it elsewhere at 75 or
    better ("Cat", "Iron", "II"), so a real word read unsurely once survives
    and a fragment of the art ("fom", "dto") does not. The first word of a line
    is kept down to 30 when it ends a word the line above broke ("con-" /
    "tinues", 49): `prev` is that line's text."""
    vocab = book_vocab(slug)
    lead = re.search(r'([A-Za-z]+)-$', prev.strip()) if prev else None
    first = min(line['words'], key=lambda w: w['x']) if line['words'] else None
    keep = lambda w: w['c'] >= 75 or (w['c'] >= 50 and len(w['t'].strip(PUNCT)) > 1
                                       and w['t'].strip(PUNCT).lower() in vocab) or (
        w is first and lead and w['c'] >= 30 and (lead.group(1) + w['t'].strip(PUNCT)).lower() in vocab)
    words = sorted(line['words'], key=lambda w: w['x'])
    sure = [w['t'] for w in words if keep(w)]
    if len(sure) == len(words):
        return ' '.join(sure)
    # A line whose box is taller than a line of text spans more than one printed
    # line ("To answer these questions" over "together the strongest", 69 px
    # against 28), and so would its one-line crop: that reading must not compete.
    # A line beside art boxes a little tall ("slabs came from...", 54); a fused
    # one is two lines deep.
    if line['y1'] - line['y0'] > 2.0 * line['body_h']:
        return ' '.join(sure)
    # the words the page pass read but was unsure of: where the crop reads the
    # same word, two readings agree, and it is kept ("great wave", read at 0)
    doubted = {w['t'].strip(PUNCT + '|-').lower() for w in words if not keep(w)}
    # A word was dropped, and some dropped words are real ("created", "First",
    # read below 50 in the page's layout pass). The line alone, cropped from the
    # page image and read as one line of text (--psm 7), usually reads them;
    # its words are kept where the book has them elsewhere at 75 or better, so
    # the art beside the line still cannot come in. The better reading wins.
    reader = sure_text.readers.get(slug) or sure_text.readers.setdefault(slug, roster.GridReader(book, slug))
    # cropped where the line's words sit, not to its box: one tall word stretches
    # the box into the lines above and below, and a one-line read of that
    # returns nothing ("slabs came from the Denver area", printed 2)
    # (a box of normal height is cropped as it is: "Do nottell" reads "not tell")
    if line['y1'] - line['y0'] > 1.4 * line['body_h']:
        top = statistics.median(w['y'] for w in words) - 10
        bottom = statistics.median(w['y'] + w['h'] for w in words) + 10
    else:
        top, bottom = line['y0'] - 8, line['y1'] + 8
    crop = reader.read(line['pdf'], (line['x0'] - 8, top, line['x1'] + 8, bottom), psm='7')
    def real(t):
        s = t.strip(PUNCT + '|-')
        if not any(c.isalnum() for c in s) or leader(s):
            return False                      # a pipe, a dash, a dot leader
        if len(s) == 1 and s.isalpha():
            return s in ('A', 'a', 'I')       # the words a lone letter can be
        return s.lower() in vocab or s.lower() in doubted or s.replace(',', '').lstrip('-+').isdigit()
    # a table's dot leaders come off the number they lead to (".......-20")
    # and a capital I read as a bar comes back ("|ron")
    # and quotes a crop reads as two apostrophes are one (''Cat")
    tokens = [re.sub(r'^\|(?=[a-z])', 'I', re.sub(r'^\.+', '', t)).replace("''", '"') for t in ' '.join(crop).split()]
    # and a capital read twice in two cases is the one capital ("PROFESSOR xX:")
    tokens = [re.sub(r'^([a-z])([A-Z])(?=\W*$)', lambda m: m.group(2) if m.group(1).upper() == m.group(2) else m.group(0), t)
              for t in tokens]
    again = [t for t in tokens if real(t)]
    # Two ways to use the crop. A word the page pass dropped comes back where
    # the crop reads the same word ("pieces", 36), each in its place; or the
    # crop's whole reading, where it found more (the page pass read "Galant"
    # for "Galactus"). The longer wins.
    seen = {t.strip(PUNCT + '|-').lower() for t in again}
    restored = [w['t'] for w in words if keep(w) or w['t'].strip(PUNCT + '|-').lower() in seen]
    best = max((restored, again, sure), key=len)
    return ' '.join(best)


def quotes(t):
    """A piece of MHSP1's text with its quotation marks as the book prints them.
    The book quotes only with double quotes, and its apostrophes sit inside a
    word (Doom's) or after a plural (heroes'). OCR reads the double quotes as
    single ones, pairs, mixes and asterisks ('First, ''nerd"', '"'kit-bashed",
    Blood,' and "*...And"). So any other quote mark is a double quote. Run on a
    whole joined piece, so a quote opened on one line closes on the next."""
    t = t.translate({0x2018: "'", 0x2019: "'", 0x201c: '"', 0x201d: '"'})
    t = re.sub(r'''["']{2,}''', '"', t)                              # ''nerd"  "'shifts  "worms"'
    t = re.sub(r'''(^|[\s(\[])'(?=[\w*.])''', r'\1"', t)             # 'First  ('Hulk
    t = re.sub(r'''(?<=[,.!?;:])'(?=[\s)\],.;:!?]|$)''', '"', t)     # Blood,'  Galactus!')
    t = re.sub(r'"\*(?=\.)', '"', t)                                 # "*...And
    out, inside = [], False
    for tok in t.split(' '):
        if tok == "'":
            tok = '"'                                                # a quote read on its own
        after = inside != (tok.count('"') % 2 == 1)
        # a single quote after a word closes an open double quote: 'Cat' -> "Cat"
        m = re.search(r"(?<=\w)'(?=[)\].,;:!?]*$)", tok)
        if after and m:
            tok = tok[:m.start()] + '"' + tok[m.end():]
            after = False
        out.append(tok)
        inside = after
    return ' '.join(out)


def unpaired(pieces, slug):
    """Stop if a piece of text has an odd number of double quotes: quotes()
    pairs every one the book prints, so an odd count is a mark it could not
    place, and the next book with one stops here rather than in the Codex."""
    odd = [t for t in pieces if t and t.count('"') % 2]
    if odd:
        t = odd[0]
        raise SystemExit('%s: %d piece(s) of text with an unpaired double quote, e.g. ...%s...'
                         % (slug, len(odd), t[max(0, t.find('"') - 30):t.find('"') + 30]))


def leader(s):
    """A dot leader Tesseract read as letters: one letter repeated ("eee")."""
    return len(s) >= 3 and len(set(s.lower())) == 1 and s.isalpha()


sure_text.vocab = {}
sure_text.readers = {}


def is_header(line):
    """A name: capitals ending in the trademark sign ("COLOSSUS(tm)", "GALACTUS'S
    "CAT"(tm)"), or capitals set taller than the text. Never a stat label, a
    run-in power ("ARMORED FORM." ends in a period) or a sentence."""
    t = line['text'].strip()
    if STAT_LINE.match(t) or SECTION_LINE.match(t) or t.endswith(('.', ':', ',')) or re.search(r'[a-z]{2}', TRADEMARK.sub('', t)):
        return False
    bare = TRADEMARK.sub('', t)
    if sum(c.isalpha() for c in bare) < 3 or not roster.is_caps(bare):
        return False
    return bool(TRADEMARK.search(t)) or line['h'] >= 1.1 * line['body_h']


def clean_name(t):
    t = TRADEMARK.sub('', t)
    t = t.replace('\u2018', "'").replace('\u2019', "'").replace('\u201c', '"').replace('\u201d', '"')
    t = re.sub(r"'+", "'", t)
    t = re.sub(r'\s+', ' ', t).strip(' .')
    # the closing quote of GALACTUS'S "CAT" goes with the trademark sign after it
    return t + '"' if t.count('"') % 2 else t


def power_name(caps):
    """ARMORED FORM -> Armored Form, WASP'S STINGS -> Wasp's Stings."""
    return ' '.join('-'.join(p[:1] + p[1:].lower() for p in w.split('-')) for w in caps.split())


def parse_rank(text, ranks):
    """'EXCELLENT [MONSTROUS]' -> (('Ex', 20, 'EXCELLENT'), ('Mn', 75, 'MONSTROUS'), None);
    'GOOD (Varies)' -> (('Gd', 10, 'GOOD'), None, 'Varies'); '?' -> (None, None, None)."""
    t = re.sub(r'[_~|]+', ' ', text).strip().rstrip('.,')
    m = re.match(r'^(.+?)\s*(?:[\[(]\s*(.+?)\s*[\])]?)?$', t)
    if not m:
        return None, None, None
    base, extra = m.group(1).strip(), (m.group(2) or '').strip()
    b = ranks.get(base.upper())
    b = (b[0], b[1], base) if b else None
    a = ranks.get(extra.upper()) if extra else None
    return b, ((a[0], a[1], extra) if a else None), (extra if extra and not a else None)


def first_int(s):
    m = re.match(r'^\s*(-?\d[\d,]*)', s or '')
    return int(m.group(1).replace(',', '')) if m else None


def second_int(s):
    m = re.search(r'[\[(]\s*(\d[\d,]*)\s*[\])]', s or '')
    return int(m.group(1).replace(',', '')) if m else None


def block_check(block):
    """roster.py's check, on derived numbers: Health = F+A+S+E and Karma = R+I+P
    against the first number printed, and the bracketed form's Health against
    the bracketed ranks. There is no rank-code check: the rank is all there is."""
    nums = [a['number'] for a in block['abilities']]
    alts = [(a.get('alt') or a)['number'] for a in block['abilities']]
    h, k = first_int(block.get('health')), first_int(block.get('karma'))
    res = {'ranks': [], 'unread': [roster.ABILITIES[i] for i, n in enumerate(nums) if n is None]}
    res['health'] = None if h is None or None in nums[:4] else sum(nums[:4]) == h
    res['karma'] = None if k is None or None in nums[4:] else sum(nums[4:]) == k
    h2 = second_int(block.get('health'))
    if h2 is not None and None not in alts[:4]:
        res['alt_health'] = sum(alts[:4]) == h2
    res['ok'] = not res['unread'] and res['health'] is not False and res['karma'] is not False and res.get('alt_health') is not False
    return res


def secondary(text):
    """Health, Karma, Resources, Popularity from the lines after a grid, which a
    one-line grid sets two to a line ("Health: 50 Karma: 50")."""
    out = {}
    for k in roster.LABELS:
        m = re.search(k + r's?\s*:\s*(.+?)\s*(?=(?:Health|Karma|Resources?|Popularity)\s*:|$)', text)
        out[k.lower()] = re.sub(r'[\s_|~.,]+$', '', m.group(1)).strip() if m else None
    return out


def one_line_grid(stream, i, ranks):
    """If stream[i] is a row of the letters F A S E R I P, return (block, next
    index): each code is the word under its letter, by x."""
    line = stream[i]
    letters = [w for w in line['words'] if re.sub(r'\W', '', w['t']) in ('F', 'A', 'S', 'Ss', 'E', 'R', 'I', 'l', 'P', '') and w['t'].strip()]
    if len(letters) < 6 or len(letters) != len(line['words']) or i + 1 >= len(stream) or 'F' not in line['text'][:3]:
        return None, i
    # the codes row, less the marks Tesseract hangs off it ('_', 'Fb~'); seven
    # codes are read in order, fewer by the letter each sits under
    codes = [dict(w, t=re.sub(r'[^A-Za-z]', '', w['t'])) for w in stream[i + 1]['words']]
    codes = sorted([w for w in codes if w['t']], key=lambda w: w['x'])
    if len(codes) != 7:
        if len(letters) != 7:
            return None, i
        xs = [w['x'] for w in sorted(letters, key=lambda w: w['x'])]
        codes = [min(codes, key=lambda w: abs(w['x'] - x)) for x in xs]
    abilities = []
    short = {v[0].upper(): v for k, v in ranks.items()}
    for n, w in enumerate(codes):
        hit = ranks.get(w['t'].upper()) or short.get(w['t'].upper())
        abilities.append({'letter': roster.ABILITIES[n], 'number': hit[1] if hit else None,
                          'code': hit[0] if hit else None, 'printed_code': w['t']})
    j, text = i + 2, []
    while j < len(stream) and stream[j]['pdf'] == line['pdf'] and STAT_LINE.match(stream[j]['text']):
        text.append(stream[j]['text'])
        j += 1
    block = {'label': None, 'kind': 'line', 'page': line['printed'], 'part': line['part'], 'pdf': line['pdf'],
             'col': line['col'], 'abilities': abilities, 'rank_only': True}
    block.update(secondary(' '.join(text)))
    prev = stream[i - 1]['text'].strip() if i else ''
    # a name on the line above ("Jennifer Walters", "Ben Grimm"); a sentence
    # ending "...the following abilities:" is not one, and the override names it
    if prev and len(prev.split()) <= 4 and not prev.endswith((':', '.', ',')) and prev[0].isupper():
        block['label'] = prev
    block['check'] = block_check(block)
    return block, j


def stat_rows(texts):
    """{label: value} from 'Label: value' lines; Resource and Resources are one."""
    rows = {}
    for t in texts:
        m = STAT_LINE.match(t)
        if m:
            label = 'Resources' if m.group(1).startswith('Resource') else m.group(1)
            rows.setdefault(label, m.group(2).strip())
    return rows


def full_grid(stream, i, ranks, reader):
    """If stream[i] is 'Fighting: ...', read the seven rows and the four values
    after them. The page's TSV places a value beside its label only when both
    box the same height, and the labels box tall on some pages (46-66 px
    against 26 on Cyclops's, printed 2), so the block is re-read from a crop of
    the page image at --psm 6, as roster.py's GridReader does for MA1's grids.
    A value the crop cannot read is taken from the TSV. Returns (block, next
    index)."""
    line = stream[i]
    if not re.match(r'^\W{0,2}Fighting\s*[:;.]', line['text']):
        return None, i
    j = i
    while j < len(stream) and stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col'] and j < i + 14:
        m = STAT_LINE.match(stream[j]['text'])
        if not m and j > i + 7:
            break
        j += 1
        if m and m.group(1) == 'Popularity':
            break
    tsv = stat_rows(s['text'] for s in stream[i:j])
    # the crop ends where the block's own text does, not at the column's edge:
    # an illustration beside it reads as words (Lockheed's, printed 9)
    right = min(line['col_x1'], max(s['x1'] for s in stream[i:j]) + 60)
    crop = stat_rows(reader.read(line['pdf'], (line['col_x0'], line['y0'] - 15, right, stream[j - 1]['y1'] + 45)))
    rows, sec = {}, {}
    for label in ABILITY_LABELS + [k for k in roster.LABELS]:
        good = lambda v: v and (parse_rank(v, ranks)[0] if label in ABILITY_LABELS else value(v))
        v = crop.get(label) if good(crop.get(label)) else tsv.get(label) if good(tsv.get(label)) else None
        if v is None:
            # neither read it: that one line alone, as a single line of text
            # (Storm's Popularity, printed 7, is a lone "4" both read as a mark)
            at = next((s for s in stream[i:j] if s['text'].startswith(label[:6])), None)
            if at:
                v = stat_rows(reader.read(line['pdf'], (at['x0'] - 10, at['y0'] - 12, right, at['y1'] + 12), psm='7')).get(label)
            v = v if good(v) else crop.get(label) or tsv.get(label)
        (rows if label in ABILITY_LABELS else sec)[label] = v or ''
    abilities = []
    for n, label in enumerate(ABILITY_LABELS):
        base, alt, note = parse_rank(rows.get(label, ''), ranks)
        a = {'letter': roster.ABILITIES[n], 'number': base[1] if base else None, 'code': base[0] if base else None,
             'printed_code': rows.get(label)}
        if alt:
            a['alt'] = {'number': alt[1], 'code': alt[0]}
        if note:
            a['note'] = note
        abilities.append(a)
    block = {'label': None, 'page': line['printed'], 'part': line['part'], 'pdf': line['pdf'], 'col': line['col'],
             'abilities': abilities, 'rank_only': True}
    for k in roster.LABELS:
        block[k.lower()] = value(sec.get(k))
    block['check'] = block_check(block)
    return block, j


VALUE = re.compile(r'^(-?\d[\d,]*(?:\s*[\[(][^\])]*[\])])?|[A-Za-z?]+(?: \d{3,4})?(?:\s*\([^)]*\))?)')


def value(v):
    """A printed Health, Karma, Resources or Popularity, less what OCR hangs
    after it: '60 [145]', '2,150 (Varies)', 'CLASS 1000', 'none'."""
    m = VALUE.match((v or '').strip())
    return m.group(1).strip() if m else None


def parse(book, slug):
    ranks = ladder(book)
    first, last = book['character_pages']
    stream = stream_of(book, slug, book['character_part'], first, last, split_at_rules=True)
    reader = roster.GridReader(book, slug)
    entries, cur = [], None

    def start(name, line):
        nonlocal cur
        cur = {'kind': 'entry', 'header': clean_name(name), 'part': line['part'], 'pages': [line['printed']],
               'identity': [], 'blocks': [], 'sections': {}, 'powers': [], 'members': [], 'prose': [],
               '_sec': None, '_pdf': line['pdf']}
        entries.append(cur)

    i, credits, sink = 0, None, None
    while i < len(stream):
        line = stream[i]
        text = line['text'].strip()
        # the booklet's credits, set in a column of Titania's page (printed
        # 14): from "Designed by" to the foot of that column
        if text.startswith('Designed by'):
            credits = (line['pdf'], line['band'], line['col'])
        if NOISE.match(text) or credits == (line['pdf'], line['band'], line['col']):
            i += 1
            continue
        block, nxt = full_grid(stream, i, ranks, reader)
        full = bool(block)
        if not full:
            # a one-line grid sits inside a power's text (ALTER EGO, SOUND
            # OBJECTS), which carries on after it
            block, nxt = one_line_grid(stream, i, ranks)
        if block:
            if cur is None:
                start('(unheaded)', line)
            cur['blocks'].append(block)
            if full:
                cur['_sec'] = 'after-grid'
            # the name over a one-line grid ("Jennifer Walters") is its label,
            # not the last line of the power it sits in
            if block['label'] and sink and sink[-1].strip() == block['label']:
                sink.pop()
            i = nxt
            continue
        if is_header(line):
            start(text, line)
            i += 1
            continue
        if cur is None:
            i += 1
            continue
        if line['printed'] not in cur['pages']:
            cur['pages'].append(line['printed'])
        m = SECTION_LINE.match(text)
        if m:
            key = m.group(1).lower()
            cur['_sec'] = key
            cur['sections'].setdefault(key, [])
            if m.group(2):
                cur['sections'][key].append(m.group(2))
            i += 1
            continue
        sec = cur['_sec']
        if sec is None and not cur['blocks'] and len(cur['identity']) < 2:
            sink = cur['identity']
        elif sec == 'powers':
            pm = POWER_HEAD.match(text)
            prev = stream[i - 1]['text'].rstrip() if i else ''
            if pm and (not cur['powers'] or prev.endswith(('.', ':', ')', '"', '\u201d', '!'))):
                cur['powers'].append({'name': power_name(pm.group(1)), 'text': []})
                text = pm.group(2)
            sink = cur['powers'][-1]['text'] if cur['powers'] else cur['sections']['powers']
        elif sec in ('talents', 'background'):
            sink = cur['sections'][sec]
        else:
            sink = cur['prose']
        sink.append(text)
        i += 1

    teams(entries)
    running(book, slug, entries, ranks)
    summary_entries(book, entries, ranks)
    for e in entries:
        e.pop('_sec', None)
        e.pop('_pdf', None)
        for p in e['powers']:
            p['text'] = quotes(roster.join_text(p['text']))
        e['sections'] = {k: quotes(roster.join_text(v)) if isinstance(v, list) else v for k, v in e['sections'].items()}
        e['prose'] = quotes(roster.join_text(e['prose']))
    unpaired([t for e in entries for t in list(e['sections'].values()) + [p['text'] for p in e['powers']] + [e['prose']]], slug)
    return stream, entries


def teams(entries):
    """A header with no block of its own, followed on its page by statted
    headers, is a team (WRECKING CREW, printed 16): those entries are its
    members, and the Powers, Talents and Background printed after the last
    member's block are the team's, shared by all of them."""
    for n, e in enumerate(entries):
        if e['blocks']:
            continue
        members = []
        for x in entries[n + 1:]:
            if x['_pdf'] != e['_pdf'] or not x['blocks']:
                break
            members.append(x)
        if not members:
            continue
        e['kind'] = 'team'
        for x in members:
            x['team'] = e['header']
            for k, v in x['sections'].items():
                e['sections'].setdefault(k, []).extend(v)
            x['sections'] = {}
            e['powers'] += x['powers']
            x['powers'] = []
            e['prose'] += x['prose']
            x['prose'] = []
        e['members'] = [{'name': x['header'], 'page': x['pages'][0]} for x in members]


def match_name(name, entries, aliases):
    """The entry a name from another list means: its alias, else the same name,
    else the entry whose header starts or ends with it (LOCKHEED THE DRAGON,
    THE HULK)."""
    n = roster.norm(aliases.get(name.upper(), aliases.get(name, name)))
    heads = [(roster.norm(e['header']), e) for e in entries]
    for h, e in heads:
        if h == n:
            return e
    for h, e in heads:
        if h.startswith(n + ' ') or h.endswith(' ' + n):
            return e
    return None


def running(book, slug, entries, ranks):
    """The running notes (registry `running`): a paragraph per character in
    another booklet, each opening with its name in capitals and a trademark
    sign, perhaps after an epithet ("The Winsome WASP(tm). Although..."). A
    one-line grid inside a note (Ben Grimm, in the Thing's) is a form of that
    character. A note whose name matches nothing is kept for the Reference
    Summary's characters, which summary_entries() adds after this."""
    r = book.get('running')
    if not r:
        return
    stream = stream_of(book, slug, r['part'], r['pages'][0], r['pages'][1], split_at_rules=False)
    head = re.compile(r"^((?:[A-Z][a-z]+ ){0,2})([A-Z][A-Z .'\u2019-]*[A-Z.])\s*(?:[" + TM + r"]|TM)\.?\s*(.*)$")
    notes, cur, i = [], None, 0
    while i < len(stream):
        line = stream[i]
        text = line['text'].strip()
        block, nxt = one_line_grid(stream, i, ranks)
        if block:
            if cur:
                cur['blocks'].append(block)
                if block['label'] and cur['text'] and cur['text'][-1].strip() == block['label']:
                    cur['text'].pop()
            i = nxt
            continue
        if text.startswith('SECTION') or text in r.get('stop', []):
            cur = None
            i += 1
            continue
        m = head.match(text)
        # Prose reads at 92 or better here; a balloon word that shares a line
        # with it reads lower ("vex", 61, printed 14). A run-in name is read
        # from every word, because a bold name can read low too.
        sure = sure_text(line, book, slug, cur['text'][-1] if cur and cur['text'] else None)
        if m:
            cur = {'name': m.group(2).strip(), 'page': line['printed'], 'part': line['part'], 'text': [m.group(3)], 'blocks': []}
            notes.append(cur)
        elif cur and sum(c.islower() for c in sure) >= 0.5 * sum(c.isalpha() for c in sure) > 0 and wordy(sure, slug, line):
            # balloon lettering in the comic panels is capitals ("THAT GUY--
            # YOu"); a line of prose is mostly lower case
            cur['text'].append(sure)
        i += 1
    book['_notes'] = notes
    for note in notes:
        e = match_name(note['name'], entries, r.get('aliases', {}))
        if e:
            attach_note(e, note)


def attach_note(e, note):
    e['sections']['running'] = quotes(roster.join_text(note['text']))
    e['running'] = {'part': note['part'], 'page': note['page']}
    e['blocks'] += note['blocks']


def summary_entries(book, entries, ranks):
    """Every Reference Summary row without a Roster Booklet entry becomes one,
    its block read from the chart (kind 'summary'); a running note that matched
    nothing earlier goes to it now."""
    s = book['reference_summary']
    short = {}
    for spelling, (code, n) in ranks.items():
        short.setdefault(spelling, (code, n))
    for side in ('heroes', 'villains'):
        for name, faserip, health, karma, powers in s[side]:
            e = match_name(name.split(': ')[-1], entries, {})
            if e:
                # the chart's spelling is the card's name: Hulk, not THE HULK;
                # Lockheed, as MA1 and the chart both have him
                e['side'], e['name'] = side, name.split(': ')[-1]
                continue
            abilities = []
            for n, tok in enumerate(re.findall(r'C1 1000|\S+', faserip)):
                hit = ranks.get(tok.upper())
                abilities.append({'letter': roster.ABILITIES[n], 'number': hit[1] if hit else None,
                                  'code': hit[0] if hit else None, 'printed_code': tok})
            block = {'label': None, 'kind': 'summary', 'page': None, 'part': 'Reference Summary', 'abilities': abilities,
                     'rank_only': True, 'health': str(health), 'karma': None if karma is None else str(karma),
                     'resources': None, 'popularity': None}
            block['check'] = block_check(block)
            e = {'kind': 'summary', 'header': name, 'part': 'Reference Summary', 'pages': [], 'side': side,
                 'identity': [], 'blocks': [block], 'sections': {}, 'members': [], 'prose': [],
                 'powers': [{'name': p, 'text': []} for p in powers]}
            entries.append(e)
    for note in book.pop('_notes', []):
        e = match_name(note['name'], entries, book['running'].get('aliases', {}))
        if e and 'running' not in e:
            attach_note(e, note)


def coverage(book, entries, overrides):
    """The Reference Summary is this book's index. Every row must be an entry,
    and every roster block must agree with its row - seven ranks (its form in
    brackets counts), Health and Karma - unless the disagreement is recorded in
    scripts/msh/<slug>-overrides.json as the chart's own misprint. Returns the
    lines to print and whether anything failed."""
    ranks = ladder(book)
    known = {(o['match']['summary'], o['field']): o for o in overrides if 'summary' in o['match']}
    used, lines, bad = set(), [], False
    rows = [(side, r) for side in ('heroes', 'villains') for r in book['reference_summary'][side]]
    notes = sum(1 for e in entries if 'running' in e)
    for side, (name, faserip, health, karma, _powers) in rows:
        e = match_name(name.split(': ')[-1], entries, {})
        if not e:
            lines.append('  SUMMARY ROW WITH NO ENTRY: %s' % name)
            bad = True
            continue
        if e['kind'] == 'summary':
            continue
        b = e['blocks'][0]
        codes = [ranks[t.upper()][0] if t.upper() in ranks else None for t in re.findall(r'C1 1000|\S+', faserip)]
        diffs = []
        for n, a in enumerate(b['abilities']):
            if codes[n] not in (a['code'], (a.get('alt') or {}).get('code')):
                diffs.append((roster.ABILITIES[n], codes[n], a['code']))
        if str(health) not in {str(first_int(b['health'])), str(second_int(b['health']))}:
            diffs.append(('health', health, b['health']))
        if str(karma) != str(first_int(b['karma'])):
            diffs.append(('karma', karma, b['karma']))
        for field, printed, roster_value in diffs:
            o = known.get((name, field))
            if o and str(o['printed']) == str(printed) and str(o['corrected']) == str(first_int(str(roster_value)) or roster_value):
                used.add((name, field))
                continue
            lines.append('  SUMMARY DISAGREES: %s %s: chart %s, Roster Booklet %s' % (name, field, printed, roster_value))
            bad = True
    for key in known:
        if key not in used:
            lines.append('  SUMMARY OVERRIDE MATCHES NOTHING: %s %s' % key)
            bad = True
    lines.insert(0, '  reference summary: %d rows, %d found as an entry (%d of them the chart alone), %d chart misprints recorded; running notes on %d entries'
                 % (len(rows), len(rows) - sum(1 for l in lines if 'NO ENTRY' in l),
                    sum(1 for e in entries if e['kind'] == 'summary'), len(used), notes))
    return lines, bad


# ------------------------------------------------------------ the Adventure Book

# the quotes a title is set in, straight or curly, and the asterisk OCR makes of one
QUOTES = ''.join(map(chr, (0x201c, 0x201d, 0x2018, 0x2019))) + '"\'*'
VEHICLE_STATS = re.compile(r'control\s+(\w+);\s*speed\s+(\w+);\s*body\s+(\w+)', re.I)
HEADINGS = {'Planned Events', 'Random Events', 'Further Notes'}


def extras(book, slug):
    """The Adventure Book as extras.py's two shapes: (items, adventure).

    It has no chapters. Its sections are read in page order off the registry's
    adventure.sections, each found by how its first line reads: a section
    banner ("SECTION 3"), a Planned Event's title in quotes on a line of its
    own, a Random Event's title in quotes as a run-in ("Lesser Tempest." This
    is...). A section runs to the next one. Bases is a location, not a section:
    its run-in room types are its parts, and the Ultimate Nullifier among them
    is an item. The running notes in sections 6 and 7 are on the characters
    (roster.json), so they are skipped here. A vehicle stated inside a section
    (control, speed and body) is an item whose text is that section's."""
    a = book['adventure']
    # every line, however unsure: an event's title can read low ("Going Home",
    # printed 10); a line of text is filtered word by word below
    stream = stream_of(book, slug, a['part'], a['pages'][0], a['pages'][1], split_at_rules=False, keep_unsure=True)
    # The bases' room table (printed 5): 26 rows of a d100 range and four
    # bases' rooms, across two columns, which the column cut splits into
    # pieces inside the Storage and Auxiliary Bridge notes. It is left out of
    # the text, and carried as data instead: the registry's transcription
    # (locations[].rooms) goes on the location.
    dice = re.compile(r'^\d{2}-\d{2}\b')
    for pdf in {l['pdf'] for l in stream}:
        rows = [l for l in stream if l['pdf'] == pdf and dice.match(l['text'])]
        if len(rows) >= 5:
            y0, y1 = min(l['y0'] for l in rows) - 130, max(l['y1'] for l in rows) + 25
            x0 = min(l['x0'] for l in rows) - 20
            stream = [l for l in stream if not (l['pdf'] == pdf and l['y0'] >= y0 and l['y1'] <= y1 and l['x0'] >= x0)]
    # Tables the registry names (adventure_tables) are cut out of the text by
    # their box: the column cut reads their columns as prose ("Doc Octopus
    # Lizard Titania ..."), and one sits at the head of the section after its
    # own (The Hunt's, under Hearts and Minds). Their facts are data.
    def in_table(l):
        cx, cy = (l['x0'] + l['x1']) / 2, (l['y0'] + l['y1']) / 2
        return any(t['pdf'] == l['pdf'] and t['box'][0] <= cx <= t['box'][2] and t['box'][1] <= cy <= t['box'][3]
                   for t in book.get('adventure_tables', []))
    stream = [l for l in stream if not in_table(l)]
    running_head = re.compile(r"^((?:[A-Z][a-z]+ ){0,2})([A-Z][A-Z .'-]*[A-Z.])\s*(?:[" + TM + r"]|TM)\.?\s")
    marks = a['sections']

    def starts(kind, title, match, line, first=None):
        """None, or the rest of the line after the section's opening."""
        t = line['text'].strip()
        if first:
            # Tesseract did not read this title at all ("Going Home", printed
            # 10), so the section starts at its first words, which are text
            return t if roster.norm(t).startswith(roster.norm(first)) else None
        if kind == 'skip':
            return '' if running_head.match(t + ' ') else None
        if kind in ('setting', 'location'):
            if match.startswith('SECTION'):
                return '' if t.startswith(match + ':') or t == match else None
            return '' if roster.norm(t).startswith(roster.norm(match)) else None
        if not t or t[0] not in QUOTES:
            return None
        n, want = roster.norm(t), roster.norm(title)
        if kind == 'planned':
            return '' if len(n) >= 6 and want.startswith(n) else None
        if n == want or n.startswith(want + ' '):
            m = re.search('[' + QUOTES[1] + QUOTES[3] + '"]', t[1:])
            # a title's close can read as two marks ("Betrayal." then two
            # apostrophes): the rest of the line starts after all of them
            return t[m.end() + 1:].lstrip(QUOTES).strip() if m else ''
        return None

    sections, cur, k, i = [], None, 0, 0
    while i < len(stream):
        line = stream[i]
        if k < len(marks):
            first = marks[k][3] if marks[k][0] == 'planned' and len(marks[k]) > 3 else None
            rest = starts(marks[k][0], marks[k][1], marks[k][2], line, first)
            if rest is not None:
                kind, title = marks[k][0], marks[k][1]
                cur = {'kind': kind, 'title': title, 'page': line['printed'], 'lines': [rest] if rest else []}
                if kind == 'planned':
                    cur['when'] = marks[k][2]
                if kind == 'planned' and not first:
                    # a title set on two lines ("The Beyonder's" / "Judgment")
                    got = roster.norm(line['text'])
                    while got != roster.norm(title) and roster.norm(title).startswith(got) and i + 1 < len(stream):
                        i += 1
                        got = (got + ' ' + roster.norm(stream[i]['text'])).strip()
                if kind == 'random':
                    cur['roll'] = marks[k][2]
                    cur['once'] = 'once' in marks[k][3:]
                sections.append(cur)
                k += 1
                i += 1
                continue
        if cur and cur['kind'] != 'skip':
            before = cur['lines'][-1]['text'] if cur['lines'] and isinstance(cur['lines'][-1], dict) else None
            sure = sure_text(line, book, slug, before)
            # comic balloons are capitals; headings the registry already names are not text
            # (a line of text may name the game in capitals, "MARVEL SUPER HEROES
            # Campaign", 28% lower case; balloon lettering is about 10%), and art
            # that passes that is not the book's words (wordy)
            if sure and sure not in HEADINGS and sum(c.islower() for c in sure) >= 0.2 * sum(c.isalpha() for c in sure) \
                    and wordy(sure, slug, line):
                cur['lines'].append(dict(line, text=sure))
        i += 1
    # A line two printed lines deep that reached the text is a fused run
    # mend_fused did not mend: the next book with one stops here, loudly, rather
    # than putting its garble in the Codex.
    fused = [l for s in sections for l in s['lines'] if isinstance(l, dict) and not l.get('reread')
             and l['y1'] - l['y0'] > 2.0 * l['body_h']]
    if fused:
        raise SystemExit('%s: %d line(s) two printed lines deep reached the text, e.g. printed %d column %d: %r'
                         % (slug, len(fused), fused[0]['printed'], fused[0]['col'], fused[0]['text'][:60]))
    missing = [m[1] for m in marks[k:]]
    if missing:
        raise SystemExit('%s: the adventure sections after %s were not found: %s' % (slug, marks[k - 1][1] if k else 'the start', ', '.join(missing)))

    items = []
    for loc in book.get('locations', []):
        sec = next(s for s in sections if s['title'] == loc['section'])
        alias = {roster.norm(k): v for k, v in loc.get('part_aliases', {}).items()}
        names = {roster.norm(n): n for n in loc['parts'] + loc.get('items', [])}
        place = {'name': loc['name'], 'kind': 'location', 'page': sec['page'], 'part': a['part'], 'vehicle': {},
                 'parts': [], 'text': [['prose', None, []]],
                 # its room table is facts, transcribed into the registry: the
                 # column cut cannot read it as text (see the room table above)
                 **({'rooms': loc['rooms']} if loc.get('rooms') else {})}
        items.append(place)
        target = place
        for l in sec['lines']:
            t = l['text'] if isinstance(l, dict) else l
            m = re.match(r'^(.{3,45}?)\.(?:\s+(.*))?$', t)
            key = m and (alias.get(roster.norm(m.group(1))) or names.get(roster.norm(m.group(1))))
            key = names.get(roster.norm(key)) if key else None
            if key in loc.get('items', []):
                target = {'name': key, 'kind': 'item', 'page': l['printed'], 'part': a['part'], 'vehicle': {},
                          'parts': [], 'text': [['prose', None, [m.group(2) or '']]]}
                items.append(target)
                continue
            if key:
                target = place
                place['parts'].append(key)
                place['text'].append(['part', key, [m.group(2) or '']])
                continue
            target['text'][-1][2].append(t)
    for v in book.get('vehicles', []):
        sec = next(s for s in sections if s['title'] == v['section'])
        texts = [l['text'] if isinstance(l, dict) else l for l in sec['lines']]
        joined = roster.join_text(texts)
        m = VEHICLE_STATS.search(joined)
        if not m:
            raise SystemExit('%s: no control, speed and body in %s for %s' % (slug, v['section'], v['name']))
        at = next((l['printed'] for l in sec['lines'] if isinstance(l, dict) and 'control' in l['text'].lower()), sec['page'])
        items.append({'name': v['name'], 'kind': 'vehicle', 'page': at, 'part': a['part'], 'section': v['section'],
                      'vehicle': {'Control': m.group(1), 'Speed': m.group(2), 'Body': re.sub(r'-\s*', '', m.group(3))},
                      'parts': [], 'text': []})

    for it in items:                    # each piece joined once, its quote marks as printed
        for piece in it['text']:
            piece[2] = [quotes(roster.join_text(piece[2]))]
    out = []
    for s in sections:
        if s['kind'] in ('skip', 'location'):
            continue
        texts = [l['text'] if isinstance(l, dict) else l for l in s['lines']]
        out.append({'title': s['title'], 'kind': s['kind'], 'page': s['page'], 'part': a['part'], 'parts': [],
                    **({'when': s['when']} if 'when' in s else {}),
                    **({'roll': s['roll'], 'once': s['once']} if 'roll' in s else {}),
                    'text': [['prose', None, [quotes(roster.join_text(texts))]]]})
    unpaired([p[2][0] for it in items for p in it['text']] + [s['text'][0][2][0] for s in out], slug)
    return items, {'title': a['title'], 'pages': a['pages'], 'part': a['part'], 'sections': out}
