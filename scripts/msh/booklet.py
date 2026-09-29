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
                    out.append(l)
    return out


PUNCT = '.,;:!?()"*' + ''.join(map(chr, (0x201c, 0x201d, 0x2018, 0x2019)))


def sure_text(line, book, slug):
    """A line of prose without the words Tesseract was unsure of. Prose reads at
    92 or better; balloon lettering and art that share a line read lower ("vex",
    61). A word read at 50-75 is kept when the book has it elsewhere at 75 or
    better ("Cat", "Iron", "II"), so a real word read unsurely once survives
    and a fragment of the art ("fom", "dto") does not."""
    vocab = sure_text.vocab.get(slug)
    if vocab is None:
        vocab = sure_text.vocab[slug] = set()
        tsv = os.path.join(roster.CACHE, 'books', slug, 'tsv')
        for f in os.listdir(tsv):
            vocab.update(w['t'].strip(PUNCT).lower() for w in roster.read_words(os.path.join(tsv, f))[0] if w['c'] >= 75)
    keep = lambda w: w['c'] >= 75 or (w['c'] >= 50 and len(w['t'].strip(PUNCT)) > 1
                                       and w['t'].strip(PUNCT).lower() in vocab)
    words = sorted(line['words'], key=lambda w: w['x'])
    sure = [w['t'] for w in words if keep(w)]
    if len(sure) == len(words):
        return ' '.join(sure)
    # A word was dropped, and some dropped words are real ("created", "First",
    # read below 50 in the page's layout pass). The line alone, cropped from the
    # page image and read as one line of text (--psm 7), usually reads them;
    # its words are kept where the book has them elsewhere at 75 or better, so
    # the art beside the line still cannot come in. The better reading wins.
    reader = sure_text.readers.get(slug) or sure_text.readers.setdefault(slug, roster.GridReader(book, slug))
    crop = reader.read(line['pdf'], (line['x0'] - 8, line['y0'] - 8, line['x1'] + 8, line['y1'] + 8), psm='7')
    def real(t):
        s = t.strip(PUNCT + '|-')
        if not any(c.isalnum() for c in s):
            return False                      # a pipe, a dash, a dot leader
        if len(s) == 1 and s.isalpha():
            return s in ('A', 'a', 'I')       # the words a lone letter can be
        return s.lower() in vocab or s.replace(',', '').lstrip('-+').isdigit()
    # a table's dot leaders come off the number they lead to (".......-20")
    # and a capital I read as a bar comes back ("|ron")
    tokens = [re.sub(r'^\|(?=[a-z])', 'I', re.sub(r'^\.+', '', t)) for t in ' '.join(crop).split()]
    again = [t for t in tokens if real(t)]
    return ' '.join(again if len(again) > len(sure) else sure)


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
            p['text'] = roster.join_text(p['text'])
        e['sections'] = {k: roster.join_text(v) if isinstance(v, list) else v for k, v in e['sections'].items()}
        e['prose'] = roster.join_text(e['prose'])
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
        sure = sure_text(line, book, slug)
        if m:
            cur = {'name': m.group(2).strip(), 'page': line['printed'], 'part': line['part'], 'text': [m.group(3)], 'blocks': []}
            notes.append(cur)
        elif cur and sum(c.islower() for c in sure) >= 0.5 * sum(c.isalpha() for c in sure) > 0:
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
    e['sections']['running'] = roster.join_text(note['text'])
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
            return t[m.end() + 1:].strip() if m else ''
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
            sure = sure_text(line, book, slug)
            # comic balloons are capitals; headings the registry already names are not text
            # (a line of text may name the game in capitals, "MARVEL SUPER HEROES
            # Campaign", 28% lower case; balloon lettering is about 10%)
            if sure and sure not in HEADINGS and sum(c.islower() for c in sure) >= 0.2 * sum(c.isalpha() for c in sure):
                cur['lines'].append(dict(line, text=sure))
        i += 1
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

    out = []
    for s in sections:
        if s['kind'] in ('skip', 'location'):
            continue
        texts = [l['text'] if isinstance(l, dict) else l for l in s['lines']]
        out.append({'title': s['title'], 'kind': s['kind'], 'page': s['page'], 'part': a['part'], 'parts': [],
                    **({'when': s['when']} if 'when' in s else {}),
                    **({'roll': s['roll'], 'once': s['once']} if 'roll' in s else {}),
                    'text': [['prose', None, texts]]})
    return items, {'title': a['title'], 'pages': a['pages'], 'part': a['part'], 'sections': out}
