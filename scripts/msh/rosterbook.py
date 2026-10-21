# -*- coding: utf-8 -*-
"""Parse a Marvel module whose Roster Book is set as MHSP2's.

    python scripts/msh/roster.py mhsp2     # roster.py hands this book to here

A book whose registry entry says "layout": "roster-book" is read here, and
comes back as the same entries roster.py writes to roster.json. It is MHSP1's
kind of object (a boxed module, blocks that print rank words and no numbers,
a Reference Summary chart as the only checklist), so it reuses
scripts/msh/booklet.py's pieces: its page stream, its rank ladder, its rank
and value parsing, its block check and its coverage of the chart. It does not
change any of them, and MHSP1's path through booklet.py is not touched.

WHAT IS DIFFERENT FROM MHSP1 (apps/marvel-heroes/docs/surveys/mhsp2.md,
"Which reader fits"), and so is read here instead:
  - three columns a page and no heavy rule
  - Karma is usually printed with no colon ("Karma 80"), and some Fighting
    rows too ("Fighting TYPICAL")
  - "Known Powers:", then run-in powers ending in a COLON ("ARMORED FORM:"),
    as roster.py reads MA1's; "Talents:" and "RUNNING <NAME>:" inside the
    entry, as MA1's are, not in another booklet
  - a one-line grid prints its Health and Karma with an equals sign
    ("Health = 80 Karma = 100"), sometimes only four physical codes
    (Psycho-Man's suits), sometimes "Health" as an eighth column (Valkyrie's
    steed); its row of codes often reads below Tesseract's confidence floor,
    so it is re-read from a crop of the page image
  - team banners ("Heroes: The X-Men") set taller than the text, with a
    paragraph about the team under them: each is a heading of its own, so that
    paragraph does not join the entry before it. An entry's team is the
    registry's `teams` (the code-grids form)
  - the book prints apostrophes of its own, so MHSP1's rule that every single
    mark is a double quote is false here. Quote marks are left as read, as
    roster.py leaves MA1's, and npcs.py pairs them
  - ranks the book prints with no number: BEYOND (the Beyonder), and
    NOT APPLICABLE or UNLIMITED as a Health or Karma. A block with one of these
    is checked on what it does print and never counts as unread

THE NUMBERS ARE DERIVED, as in MHSP1: each rank's standard number
(apps/marvel-heroes/data/ranks.json), and every block says `rank_only`.
"""
import re, statistics

import roster, booklet

ABILITY_LABELS = booklet.ABILITY_LABELS
LABEL_WORDS = ABILITY_LABELS + ['Health', 'Karma', 'Resources', 'Resource', 'Popularity']
# a stat row: the label, then a colon, a semicolon or nothing, then the value
STAT_ROW = re.compile(r'^\W{0,2}(Fighting|Agility|Strength|Endurance|Reason|Intuition|Psyche|Health|Karma|Resources?|Popularity)\s*[:;.,]?\s+(\S.*)$')
SECTION_LINE = re.compile(r'^(Known Powers|Powers|Talents|Contacts|Background)\s*[:;.]\s*(.*)$')
# the letters over a one-line grid: F A S E [R I P] and perhaps Health, as
# Tesseract reads them ("Ss", "S)", "iS}", "|", "!", "l", "Pp")
GRID_LETTER = {'F': 'F', 'A': 'A', 'S': 'S', 'Ss': 'S', 'iS': 'S', 'E': 'E', 'R': 'R', 'I': 'I', 'l': 'I', '': 'I',
               'P': 'P', 'Pp': 'P'}
# what a row of two-letter codes may read as besides the codes themselves
CODE_FIX = {'0': 'O'}
UNNUMBERED = ('NOT APPLICABLE', 'UNLIMITED', 'NONE')


def team_banner(line, teams):
    """Whether a line is a team banner: set taller than the text and naming a
    team the registry records ("Heroes: The X-Men", "Bad Guys: ...")."""
    if line['h'] < 1.3 * line['body_h']:
        return False
    t = roster.norm(booklet.TRADEMARK.sub('', line['text']))
    return any(t == n or t.endswith(' ' + n) for n in teams)


def stat_rows(lines):
    rows = {}
    for t in lines:
        m = STAT_ROW.match(t)
        if m:
            label = 'Resources' if m.group(1).startswith('Resource') else m.group(1)
            rows.setdefault(label, m.group(2).strip())
    return rows


def value(v):
    """A printed Health, Karma, Resources or Popularity: a number, a number and
    another form's in parentheses ('60 (145)'), or a rank word or phrase
    ('UNLIMITED', 'NOT APPLICABLE', 'CLASS 1000')."""
    v = re.sub(r'[\s_|~.,]+$', '', (v or '').strip())
    m = re.match(r'^(-?\d[\d,]*(?:\s*[\[(]\s*-?\d[\d,]*\s*[\])])?)', v)
    if m:
        return m.group(1)
    m = re.match(r'^([A-Z][A-Z]+(?: [A-Z]+)*(?: \d{3,4})?)\b', v)
    return m.group(1) if m else (v or None)


def rank_of(text, ranks):
    """booklet.parse_rank, and a slash read as the other form's rank
    ('TYPICAL/REMARKABLE', the Puma's human and puma forms)."""
    t = (text or '').strip()
    if '/' in t and '(' not in t:
        a, b = t.split('/', 1)
        t = '%s (%s)' % (a.strip(), b.strip())
    return booklet.parse_rank(t, ranks)


def check(block):
    """booklet.block_check, where a rank or value the book prints with no
    number (BEYOND, NOT APPLICABLE, UNLIMITED) is not a misread: the sum it
    belongs to is not checked, and the block is not unread for it. A one-line
    grid that prints only the four physical codes is checked on Health."""
    res = booklet.block_check(block)
    absent = [a['letter'] for a in block['abilities'] if a.get('absent')]
    unnumbered = [a['letter'] for a in block['abilities'] if a['code'] and a['number'] is None]
    res['unread'] = [x for x in res['unread'] if x not in absent and x not in unnumbered]
    if absent or unnumbered:
        res['unnumbered'] = unnumbered
        nums = [a['number'] for a in block['abilities']]
        h, k = booklet.first_int(block.get('health')), booklet.first_int(block.get('karma'))
        res['health'] = None if h is None or None in nums[:4] else sum(nums[:4]) == h
        res['karma'] = None if k is None or None in nums[4:] else sum(nums[4:]) == k
    res['ok'] = not res['unread'] and res['health'] is not False and res['karma'] is not False \
        and res.get('alt_health') is not False
    return res


def full_grid(stream, i, ranks, reader):
    """If stream[i] is a Fighting row, read the seven rows and the four values
    after it, in the same column. The page pass reads this book's rows whole
    (label and value on one line); a row whose value does not parse is
    re-read from a crop of that line of the page image. Returns (block, next
    index)."""
    line = stream[i]
    m = STAT_ROW.match(line['text'])
    if not m or m.group(1) != 'Fighting':
        return None, i
    j = i
    while j < len(stream) and j < i + 14 and stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col']:
        mm = STAT_ROW.match(stream[j]['text'])
        if not mm and j > i + 7:
            break
        j += 1
        if mm and mm.group(1) == 'Popularity':
            break
    span = stream[i:j]
    rows = stat_rows(s['text'] for s in span)
    right = min(line['col_x1'], max(s['x1'] for s in span) + 60)
    for label in LABEL_WORDS[:7] + ['Health', 'Karma', 'Resources', 'Popularity']:
        good = (lambda v: v and rank_of(v, ranks)[0]) if label in ABILITY_LABELS else (lambda v: bool(v and value(v)))
        if good(rows.get(label)):
            continue
        at = next((s for s in span if s['text'].lstrip('\'"*').startswith(label[:6])), None)
        if at:
            again = stat_rows(reader.read(line['pdf'], (at['x0'] - 10, at['y0'] - 12, right, at['y1'] + 12), psm='7'))
            if good(again.get(label)):
                rows[label] = again[label]
    abilities = []
    for n, label in enumerate(ABILITY_LABELS):
        base, alt, note = rank_of(rows.get(label, ''), ranks)
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
        block[k.lower()] = value(rows.get(k))
    # a state or form named on the line above the block, in quotes
    # ('"Original State"', '"Human" Form': the Beyonder, printed 2)
    prev = stream[i - 1]['text'].strip() if i else ''
    if prev[:1] in '"“‘\'' and not booklet.is_header(stream[i - 1]):
        block['label'] = re.sub(r'["“”‘’]', '', prev).strip()
    block['check'] = check(block)
    return block, j


def grid_letters(line):
    """The letters of a one-line grid's top row, with their x, or None: every
    word a FASERIP letter as read, the first F, at least four, and perhaps a
    last word Health (a steed's Health printed as an eighth column)."""
    words = sorted(line['words'], key=lambda w: w['x'])
    out, health = [], None
    for n, w in enumerate(words):
        t = re.sub(r'[^A-Za-z]', '', w['t'])
        if t == 'Health' and n == len(words) - 1:
            health = w
            continue
        if t not in GRID_LETTER:
            return None, None
        out.append((GRID_LETTER[t], w))
    letters = [l for l, _ in out]
    if len(out) < 4 or letters[0] != 'F' or letters != list('FASERIP')[:len(letters)]:
        return None, None
    return out, health


def codes_of(words, ranks):
    """Two-letter codes from a row of words: each word less the marks OCR hangs
    off it ('FB~'), kept where it is a rank this book prints."""
    out = []
    for w in sorted(words, key=lambda w: w['x']):
        t = re.sub(r'[^A-Za-z0-9]', '', w['t']).upper()
        t = ''.join(CODE_FIX.get(c, c) for c in t)
        if t:
            out.append(dict(w, t=t))
    return out


CODE_LETTERS = 'ABDEFGIMNPRTUXY'


def codes_read(reader, pdf, box, psm='7'):
    """The rank codes in a box of the page image, as words: the crop made
    black and white at half grey, then read by Tesseract for the letters of
    this book's codes only. Cached beside roster.GridReader's crops."""
    import io, os, shutil, subprocess
    x0, y0, x1, y1 = (int(v) for v in box)
    path = os.path.join(reader.dir, 'p%03d-%d-%d-%d-%d-codes-psm%s.txt' % (pdf, x0, y0, x1, y1, psm))
    if not os.path.exists(path):
        import pymupdf
        if reader.doc is None:
            reader.doc = pymupdf.open(reader.pdf_path)
        s = 72 / 300
        pm = reader.doc[pdf - 1].get_pixmap(dpi=300, clip=pymupdf.Rect(x0 * s, y0 * s, x1 * s, y1 * s), colorspace=pymupdf.csGRAY)
        bw = pymupdf.Pixmap(pymupdf.csGRAY, pm.width, pm.height, bytes(0 if v < 128 else 255 for v in pm.samples), False)
        png = path[:-4] + '.png'
        bw.save(png)
        tess = shutil.which('tesseract') or r'C:\Program Files\Tesseract-OCR\tesseract.exe'
        r = subprocess.run([tess, png, 'stdout', '--psm', psm, '-c', 'tessedit_char_whitelist=' + CODE_LETTERS + ' '],
                           capture_output=True)
        os.remove(png)
        io.open(path, 'w', encoding='utf-8', newline='\n').write(r.stdout.decode('utf-8', 'replace'))
    return io.open(path, encoding='utf-8').read().split()


def one_line_grid(stream, i, ranks, reader):
    """If stream[i] is a row of the letters F A S E (R I P), return (block,
    next index). Each code is the word under its letter, by x. The codes row
    is the stream's next line where that line is codes; else it is read from
    a crop of the page image under the letters (Tesseract dropped it as
    unsure on the Kingpin's tiers, printed 26)."""
    line = stream[i]
    letters, health_col = grid_letters(line)
    if not letters:
        return None, i
    nxt = stream[i + 1] if i + 1 < len(stream) else None
    same = nxt and nxt['pdf'] == line['pdf'] and nxt['col'] == line['col']
    def as_codes(ws):
        cs = codes_of(ws, ranks)
        known = [c for c in cs if c['t'] in ranks or re.match(r'^\d+$', c['t'])]
        return cs if cs and len(known) >= 0.6 * len(cs) and len(cs) <= len(letters) + 2 else None
    codes = as_codes(nxt['words']) if same else None
    j = i + 2 if codes else i + 1
    def pick(cs):
        # one code per letter, the nearest by x; the steed's Health is a number
        nums = [c for c in cs if c['t'].isdigit()]
        cs = [c for c in cs if not c['t'].isdigit()]
        if len(cs) != len(letters):
            cs = [min(cs, key=lambda c: abs(c['x'] - w['x'])) for _, w in letters] if cs else []
        return cs, nums
    picked, nums = pick(codes) if codes else ([], [])
    if not codes or len(picked) != len(letters) or any(c['t'] not in ranks for c in picked):
        # The codes row from the page image. The rows sit on art's halftone on
        # some pages (Iron Man's, printed 15), which the page pass read as
        # unsure words and dropped, so the crop is made black and white and
        # read for code letters only. Its rows: the codes line where the
        # stream has one, else the gap between the letters and the next line.
        if same and not (re.match(r'^\W{0,2}(Health|Karma)', nxt['text']) or nxt['y0'] - line['y1'] > 1.5 * line['body_h']):
            y0, y1 = nxt['y0'] - 6, nxt['y1'] + 6
        else:
            y0, y1 = line['y1'] - 2, (nxt['y0'] + 2 if same else line['y1'] + 50)
        x0 = min(w['x'] for _, w in letters) - 20
        row = codes_read(reader, line['pdf'], (x0, y0, max(w['x'] + w['w'] for _, w in letters) + 90, y1))
        if len(row) == len(letters) and all(t in ranks for t in row):
            picked = [{'t': t} for t in row]
        else:
            # one cell a letter: from left of its letter to left of the next
            xs = [w['x'] for _, w in letters] + [letters[-1][1]['x'] + 110]
            cells = [codes_read(reader, line['pdf'], (xs[n] - 20, y0, xs[n + 1] - 20, y1), psm='8') for n in range(len(letters))]
            if all(len(c) == 1 and c[0] in ranks for c in cells):
                picked = [{'t': c[0]} for c in cells]
    abilities = []
    for n, letter in enumerate(roster.ABILITIES):
        if n >= len(letters):
            abilities.append({'letter': letter, 'number': None, 'code': None, 'printed_code': None, 'absent': True})
            continue
        c = picked[n]['t'] if n < len(picked) else None
        hit = ranks.get(c) if c else None
        abilities.append({'letter': letter, 'number': hit[1] if hit else None, 'code': hit[0] if hit else None,
                          'printed_code': c})
    text = []
    while j < len(stream) and stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col'] \
            and re.match(r'^\W{0,2}(Health|Karma)\s*[=:]', stream[j]['text']):
        text.append(stream[j]['text'])
        j += 1
    sec = {}
    for k in roster.LABELS:
        m = re.search(k + r's?\s*[=:]\s*(.+?)\s*(?=(?:Health|Karma|Resources?|Popularity)\s*[=:]|$)', ' '.join(text))
        sec[k.lower()] = value(re.sub(r'\)+$', '', m.group(1))) if m else None
    if health_col is not None and sec['health'] is None and nums:
        sec['health'] = nums[0]['t']
    block = {'label': None, 'kind': 'line', 'page': line['printed'], 'part': line['part'], 'pdf': line['pdf'],
             'col': line['col'], 'abilities': abilities, 'rank_only': True}
    block.update(sec)
    prev = stream[i - 1]['text'].strip() if i else ''
    # a name on the line above (GENERAL ZEDRAO, HENCHMEN); a sentence ending
    # "...the following abilities:" is not one, and an override names it
    if prev and len(prev.split()) <= 4 and not prev.endswith((':', '.', ',')) and prev[0].isupper() \
            and not booklet.is_header(stream[i - 1]):
        block['label'] = prev
    block['check'] = check(block)
    return block, j


def parse(book, slug):
    ranks = booklet.ladder(book)
    first, last = book['character_pages']
    stream = booklet.stream_of(book, slug, book['character_part'], first, last, split_at_rules=False)
    reader = roster.GridReader(book, slug)
    teams = {roster.norm(t) for _p, _h, t in book.get('teams', [])}
    credits = book.get('credits')
    entries, cur = [], None

    def start(kind, name, line):
        nonlocal cur
        cur = {'kind': kind, 'header': name, 'part': line['part'], 'pages': [line['printed']],
               'identity': [], 'blocks': [], 'sections': {}, 'powers': [], 'members': [], 'prose': [], '_sec': None}
        entries.append(cur)

    i, skip = 0, None
    while i < len(stream):
        line = stream[i]
        text = line['text'].strip()
        # the module's credits and trademark list, set in a column of the last
        # page (registry `credits`: its first words, to the foot of the column)
        if credits and text.startswith(credits):
            skip = (line['pdf'], line['col'])
        if skip == (line['pdf'], line['col']) or booklet.NOISE.match(text):
            i += 1
            continue
        block, nxt = full_grid(stream, i, ranks, reader)
        if not block:
            block, nxt = one_line_grid(stream, i, ranks, reader)
        if block:
            if cur is None:
                start('unheaded', None, line)
            cur['blocks'].append(block)
            # a one-line grid sits inside a power's text, which carries on after it
            if block.get('kind') != 'line':
                cur['_sec'] = 'after-grid'
            # a label is the line above the block, not the end of what precedes it
            if block['label']:
                for sink in [cur['identity'], cur['prose']] + [p['text'] for p in cur['powers'][-1:]] + list(cur['sections'].values()):
                    if sink and re.sub(r'["“”]', '', sink[-1]).strip() == block['label']:
                        sink.pop()
                        break
            if line['printed'] not in cur['pages']:
                cur['pages'].append(line['printed'])
            i = nxt
            continue
        if team_banner(line, teams):
            start('heading', booklet.clean_name(text), line)
            i += 1
            continue
        if booklet.is_header(line) and ',' not in text:
            start('entry', booklet.clean_name(text), line)
            i += 1
            continue
        if cur is None:
            i += 1
            continue
        if line['printed'] not in cur['pages']:
            cur['pages'].append(line['printed'])
        m = SECTION_LINE.match(text)
        r = roster.RUN_IN.match(text.replace('’', "'"))
        label = r.group(1).strip() if r else None
        key = None
        if m and not (m.group(1) == 'Powers' and cur['_sec'] == 'powers'):
            key, rest = {'known powers': 'powers'}.get(m.group(1).lower(), m.group(1).lower()), m.group(2)
        elif label and (label.startswith('RUNNING') or label in ('TALENTS', 'TALENT', 'CONTACTS', 'CONTACT')):
            key, rest = roster.section_of(label), r.group(2)
        elif label and cur['_sec'] != 'powers' and roster.section_of(label) in ('powers', 'talents', 'contacts'):
            key, rest = roster.section_of(label), r.group(2)
        if key:
            cur['_sec'] = key
            cur['sections'].setdefault(key, [])
            if rest:
                cur['sections'][key].append(rest)
            i += 1
            continue
        sec = cur['_sec']
        if sec is None and not cur['blocks'] and len(cur['identity']) < 2 and cur['kind'] == 'entry':
            cur['identity'].append(text)
        elif sec == 'powers':
            pm = roster.POWER_HEAD.match(text)
            prev = stream[i - 1]['text'].rstrip() if i else ''
            if pm and len(pm.group(1)) <= 40 and roster.is_caps(pm.group(1)) \
                    and (not cur['powers'] or prev.endswith(('.', ':', ')', '"', '”', '!'))):
                cur['powers'].append({'name': booklet.power_name(pm.group(1)), 'text': [pm.group(2)]})
            elif cur['powers']:
                cur['powers'][-1]['text'].append(text)
            else:
                cur['sections']['powers'].append(text)
        elif sec in ('talents', 'contacts', 'running', 'background', 'notes'):
            cur['sections'][sec].append(text)
        else:
            cur['prose'].append(text)
        i += 1

    team_of(book, entries)
    for e in entries:
        e.pop('_sec', None)
        for p in e['powers']:
            p['text'] = roster.join_text(p['text'])
        e['sections'] = {k: roster.join_text(v) for k, v in e['sections'].items()}
        e['prose'] = roster.join_text(e['prose'])
    return stream, entries


def team_of(book, entries):
    """The registry's `teams`: [page, header, team] in book order, each the
    first entry of a run of that team; an entry takes the last team started at
    or before it, and one before the first banner has none. A banner's own
    heading takes the team it names. Every mark must name an entry."""
    marks = {(p, roster.norm(h)): t for p, h, t in book.get('teams', [])}
    found, team = set(), None
    for e in entries:
        key = (e['pages'][0], roster.norm(e['header']))
        if key in marks:
            team = marks[key]
            found.add(key)
        if e['kind'] == 'heading':
            e['team'] = next((t for t in [x[2] for x in book.get('teams', [])]
                              if roster.norm(e['header']).endswith(roster.norm(t))), None)
        else:
            e['team'] = team
    missing = [k for k in marks if k not in found]
    if missing:
        raise SystemExit('teams name no entry: %s' % missing)
