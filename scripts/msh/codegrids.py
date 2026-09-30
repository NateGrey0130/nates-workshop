# -*- coding: utf-8 -*-
"""Parse a Marvel sourcebook whose grid rows print the rank code first (MA4).

    python scripts/msh/roster.py ma4     # roster.py hands this book to here

A book whose registry entry says "layout": "code-grids" is read here. It is
set like MA1 - one numbering, three columns, KNOWN POWERS:, TALENTS:,
CONTACTS:, BACKGROUND:, RUNNING <NAME>: - so the stream, the grid crop, the
entry loop and the secondary values are scripts/msh/roster.py's own
(page_stream, GridReader, read_entries, secondary). What differs is all this
module does (survey: ma4.md):

  - THE ROW. "F  GD  (10)  Health: 46": letter, code, then the number in
    parentheses, and labels with a colon. roster.ROW wants the number first,
    so it reads no row of this book. A Class rank prints no number ("C3000",
    "CL1000"), a Shift rank prints its letter alone ("X (150)", "Shift 0"),
    and a rank the being lacks prints "N/A". Rows are taken in order from the
    crop, F A S E R I P: the letters themselves read as "Ss", "iS)", "|" or
    nothing too often to be matched on.
  - A DIGIT THE CROP MISREADS. Tesseract reads the printed "(30)" as "(80)" or
    "(380)" and "(50)" as "(80)" or "($0)": 37 rows of 130 grids, measured
    2026-09-30. The code beside it is
    printed too, and a number is taken as the code's own when putting a 3 or a
    5 for its 8, or dropping one 8, gives exactly that; the row keeps what was
    read as `read_as`. It cannot hide a misprint of the number: Health and
    Karma are checked against the numbers kept, and the book's seven
    arithmetic misprints are overrides (scripts/msh/ma4-overrides.json).
  - THE HEADERS, from the grid (mark_headers), as gridbooks.mark_headers
    finds ME1's: MA4's headers box at 1.09-1.17 times the body height, so
    roster's 1.35 rule finds none. Every character has a grid. Where the
    page defeats that, the registry says so and each claim must match once:
    `grid_headers` (a header the OCR lost), `block_labels` (a grid that is a
    form or an item, not a character) and `headings` (a title that is not a
    character, which opens a heading entry so its text is not taken into the
    character above).
  - A GRID WITH NO POPULARITY LINE (19: creatures, tiers, forms) ends seven
    row pitches below its Health line; the pitch is half the distance to its
    Karma line, which is printed two rows down.
  - BEINGS STATTED IN THE TRAVEL GUIDE (`statted_pages`) are read a page at a
    time in read_entries' opponent mode, as ME1's chapter opponents are.
  - TEAMS are the book's own groupings (`teams`), not its Contents sections.
"""
import re

import gridbooks
import roster

# the marks OCR hangs between a code and its parenthesis: 'RM _ (30)', 'EX, (20)'
JUNK = '[\\s_=~,.\'"`' + chr(0x2014) + chr(0x2019) + chr(0xac) + chr(0xfffd) + '-]*'
# "CL1000" reads as "Ct3000" too (Terminus, p.72); '$' is a 5 or a stray mark
CODE = r'(?:C[L1lIt]?\s?[135]000|Shift\s?[0XYZ]|N/?A\.?|FE|PR|TY|GD|EX|RM|RE|IN|AM|MN|UN|[XYZ])'
ROW = re.compile(r'^\s*(\S{0,3}?)\s*[~_=-]*\s*(' + CODE + r')(?![A-Za-z0-9])' + JUNK
                 + r'(?:[(\[{]?\s*([\d$]{1,4})\s*[)\]}]?)?\s*(.*)$')
SHIFT = {'X': 'ShX', 'Y': 'ShY', 'Z': 'ShZ'}
DASH = chr(0x2013) + chr(0x2014) + '-'


def code_of(printed):
    """The canonical code (roster.RANK_NUMBER's) for a code as printed, or None
    for N/A."""
    p = re.sub(r'\s', '', printed)
    if p.upper().startswith('N'):
        return None
    if p in SHIFT:
        return SHIFT[p]
    m = re.match(r'^C[L1lIt]?([135]000)$', p)
    if m:
        return 'C-' + m.group(1)
    return roster.canon(p)


def number_of(code, raw):
    """(number, read_as): the printed number, or the code's own when the one
    read is a 3 or 5 misread as 8, or a stray 8. A Class or Shift rank that
    prints no number stands for its code's."""
    std = roster.RANK_NUMBER.get(code)
    digits = re.sub(r'\D', '', raw or '')
    if not digits:
        return std, None
    n = int(digits)
    if std is None or n == std:
        return n, None
    tries = {digits.replace('8', '3'), digits.replace('8', '5'), re.sub(r'\D', '', raw.replace('$', '5'))}
    tries |= {digits[:k] + digits[k + 1:] for k, ch in enumerate(digits) if ch == '8'}
    if str(std) in tries:
        return std, raw
    return n, None


def rows_from(texts):
    """The grid's rows from the crop's lines, in order. A line that is not a
    row after the first is the tail of a value that wrapped, and joins the row
    above, as in roster.rows_from."""
    rows = []
    for t in texts:
        m = ROW.match(t)
        ok = m and (m.group(3) or not re.match(r'^(?:FE|PR|TY|GD|EX|RM|RE|IN|AM|MN|UN|[XYZ])$', m.group(2)))
        if ok and len(rows) < 7:
            code = code_of(m.group(2))
            number, read_as = number_of(code, m.group(3))
            if code is None:
                number = None
            row = {'letter': roster.ABILITIES[len(rows)], 'number': number, 'code': code,
                   'printed_code': re.sub(r'\s+', ' ', m.group(2)).strip(), 'rest': m.group(4)}
            if read_as:
                row['read_as'] = read_as
            rows.append(row)
        elif rows:
            rows[-1]['rest'] += ' ' + t.strip()
    return rows


def grid_at(stream, i, reader):
    """If stream[i] is a grid's Health line, return (rows, first index after
    the grid), as roster.grid_at does. The box runs from a line above the
    Health label to the Popularity line in the same column, or seven row
    pitches down where no Popularity is printed."""
    line = stream[i]
    if not roster.ANCHOR.search(line['text']):
        return None, i
    same = [j for j in range(i, min(len(stream), i + 12))
            if stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col']]
    karma = next((j for j in same if 'Karma' in stream[j]['text']), None)
    if karma is None:
        return None, i                  # "his Health falls to 16": prose, not a grid
    pop = next((j for j in same if 'Popular' in stream[j]['text']), None)
    pitch = (stream[karma]['y0'] - line['y0']) / 2 or 60
    bottom = stream[pop]['y1'] + 10 if pop is not None else line['y0'] + 7 * pitch + 10
    box = (line['col_x0'], line['y0'] - 45, line['col_x1'], bottom)
    rows = rows_from(reader.read(line['pdf'], box))
    if len(rows) != 7:
        rows = rows_from([s['text'] for s in stream[i:(pop if pop is not None else karma) + 5]])
    end = i + 1
    while end < len(stream) and stream[end]['pdf'] == line['pdf'] and stream[end]['col'] == line['col'] \
            and stream[end]['y0'] < bottom - 10 and not roster.RUN_IN.match(stream[end]['text']):
        end += 1
    return (rows if len(rows) == 7 else None), end


def printed(text):
    """A header as the page prints it. Tesseract reads a roman numeral's I as
    '|', 'l' or '1' ('HATE-MONGER Ili', 'PUNISHER |', 'HUMAN TORCH (Il)',
    'H.E.R.B.1.E.') and the apostrophe as U+FFFD ('GALACTUS\\ufffd CAT')."""
    t = text.replace(chr(0xfffd), "'").replace(chr(0x2019), "'")
    t = re.sub(r'(?<=[\s(])[|Il1][|Ili1]{0,2}(?=[\s)]|$)', lambda m: 'I' * len(m.group(0)), t)
    return re.sub(r'(?<=\.)1(?=\.)', 'I', t)


def map_label(line):
    """A map's or an illustration's lettering: capitals set smaller than the
    body (18-22 px against 25-28), which the OCR reads as lines of text - the
    maps of Attilan (p.27), Atlantis (p.32) and Castle Doom (p.39), the Baxter
    Building's floor plans, a comic panel's balloons (p.82). A marked header is
    never one, though Salem's Seven's are set as small (p.71): so this is asked
    only after the headers are found. A map's degrees and marks ('60 S',
    '; lh FACTORY') are lettering too: a small line with no lowercase word, or
    one read at under 65. A paragraph's last line boxes small as well
    ('scars.', no ascenders), and it has a lowercase word."""
    t = line['text']
    small = line['h'] < 0.85 * line['body_h'] and (roster.is_caps(t) or not re.search(r'[a-z]{2}', t) or line['conf'] < 65)
    # at the body's size, only marks read with little confidence ('"AR', p.39)
    marks = line['conf'] < 65 and not re.search(r'[a-z]{3}', t)
    return not line.get('big') and (small or marks) and not roster.ANCHOR.search(t) and not ROW.match(t)


def same_column(a, b):
    return a['pdf'] == b['pdf'] and a['col'] == b['col']


def is_grid(stream, i):
    return bool(roster.ANCHOR.search(stream[i]['text'])) and any(
        'Karma' in stream[j]['text'] and same_column(stream[j], stream[i]) for j in range(i, min(len(stream), i + 8)))


def mark_headers(stream, skip):
    """Mark the header above each grid, as gridbooks.mark_headers does, but
    looking four lines up and letting an identity line end in a comma: MA4 sets
    up to three identity lines under a name (MEPHISTO / a.k.a. Satan,
    Mephistopheles, Lucifer, / Beelzebub, and ...). A name set on two lines
    (ALICIA REISS MASTERS / STORM) is marked on both, which read_entries joins.
    A grid in `skip` (a form's or an item's) gets no header."""
    for i in range(len(stream)):
        if i in skip or not is_grid(stream, i):
            continue
        above, j = [], i - 1
        while j >= 0 and len(above) < 4 and same_column(stream[j], stream[i]) and not stream[j].get('heading'):
            above.append(j)
            j -= 1
        head = None
        for k, j in enumerate(above):
            t = stream[j]['text']
            if roster.is_caps(t) and sum(c.isalpha() for c in t) >= 3 and not roster.RUN_IN.match(t) \
                    and not t.startswith('RUNNING') and all(not stream[x]['text'].rstrip().endswith(('.', ':')) for x in above[:k]):
                head = j
                break
        if head is None and above and gridbooks.short(stream[above[0]]['text']):
            head = above[0]
        if head is None:
            continue
        stream[head]['big'] = True
        up = head - 1
        if up >= 0 and same_column(stream[up], stream[head]) and roster.is_caps(stream[up]['text']) \
                and gridbooks.short(stream[up]['text']) and not roster.RUN_IN.match(stream[up]['text']) \
                and stream[head]['y0'] - stream[up]['y1'] < stream[head]['h'] and not stream[up].get('heading'):
            stream[up]['big'] = True


def find_grid(stream, page, health, what):
    hits = [i for i, l in enumerate(stream) if l.get('printed') == page and is_grid(stream, i)
            and re.search(r'Heal?th\W*%d\b' % health, l['text'])]
    if len(hits) != 1:
        raise SystemExit('%s: %d grids on printed %d with Health %d, not 1' % (what, len(hits), page, health))
    return hits[0]


def mark_headings(book, stream):
    """The registry's `headings`: printed titles that are not characters (a
    race, a place, a group, a list of items). Each opens a heading entry, so
    the text under it is not taken into the character above; each must be
    found exactly once on its page. A title set on two lines names both. A
    heading with a third field lists members without a block (NOTABLE
    SKRULLS: run-ins ANELLE:, DORREK: ...): it is read as an entry, so
    read_entries records them, and parse() hands them to the entry the field
    names (the SKRULL tier)."""
    for page, title, *to in book.get('headings', []):
        lines = title.split(' / ')
        hits = [i for i, l in enumerate(stream) if l.get('printed') == page
                and roster.norm(printed(l['text'])) == roster.norm(lines[0])]
        if len(hits) != 1:
            raise SystemExit('heading %r: %d lines on printed %d, not 1' % (title, len(hits), page))
        i = hits[0]
        for k, part in enumerate(lines[1:], 1):
            if roster.norm(printed(stream[i + k]['text'])) != roster.norm(part):
                raise SystemExit('heading %r: line %d reads %r' % (title, k + 1, stream[i + k]['text']))
        stream[i]['text'] = ' '.join(lines)
        # synthetic: read_entries opens a heading entry here, as at a section
        stream[i].update(big=True, heading=True, synthetic=not to)
        del stream[i + 1:i + len(lines)]


def insert_headers(book, stream):
    """The registry's `grid_headers`: [page, Health, NAME] for a header the OCR
    did not read at all (set beside art: Thundra, Gorgon). A line with the name
    goes in above the grid."""
    for page, health, name in book.get('grid_headers', []):
        i = find_grid(stream, page, health, name)
        # above the identity lines, which run up to the sentence that ends the
        # text before ("Humanoid Experimental Robot, B-Type," / "Integrated
        # Electronics" under H.E.R.B.I.E.)
        k = i
        while k > 0 and i - k < 3 and same_column(stream[k - 1], stream[i]) and not stream[k - 1]['big'] \
                and not stream[k - 1]['text'].rstrip().endswith(('.', ':', '!', '?', '"')):
            k -= 1
        stream.insert(k, dict(stream[k], text=name, big=True, y1=stream[k]['y0'] - 1))


def team_of(book, entries):
    """The registry's `teams`: [page, header, team] in book order, each the
    first entry of a run of that team; an entry takes the last team started at
    or before it. Every one must name an entry."""
    marks = {(p, roster.norm(h)): t for p, h, t in book.get('teams', [])}
    found, team = set(), None
    for e in entries:
        key = (e['pages'][0], roster.norm(e['header']))
        if key in marks:
            team = marks[key]
            found.add(key)
        e['team'] = team
    missing = [k for k in marks if k not in found]
    if missing:
        raise SystemExit('teams name no entry: %s' % missing)


def parse(book, slug):
    stream = roster.page_stream(book, slug)
    for line in stream:
        if not line.get('synthetic'):
            line['big'] = False
    mark_headings(book, stream)
    first, last = book['character_pages']
    insert_headers(dict(book, grid_headers=[h for h in book.get('grid_headers', []) if first <= h[0] <= last]), stream)
    labels = {find_grid(stream, p, h, lab): lab for p, h, lab in book.get('block_labels', [])}
    mark_headers(stream, set(labels))
    for line in stream:
        if line['big']:
            line['text'] = printed(line['text'])
    stream[:] = [l for l in stream if l.get('synthetic') or not map_label(l)]
    entries = roster.read_entries(stream, roster.GridReader(book, slug), grid=grid_at)
    # finish() drops an entry with nothing in it, which is right for a caption
    # the header test let through and wrong for a registry heading that only
    # opens a run of characters (THE SUPER-APES, over Igor's grid)
    titles = {' '.join(t.split(' / ')) for _p, t, *_to in book.get('headings', [])}
    for e in entries:
        if e['kind'] == 'heading' and e['header'] in titles and not e['prose']:
            e['prose'] = ['']
    roster.finish(entries)
    by_grid = {(p, str(h)): lab for p, h, lab in book.get('block_labels', [])}
    for page, title, *to in book.get('headings', []):
        if not to:
            continue
        src = [e for e in entries if e['header'] == ' '.join(title.split(' / ')) and e['pages'][0] == page]
        dst = [e for e in entries if roster.norm(e['header']) == roster.norm(to[0]) and e['blocks']]
        if len(src) != 1 or len(dst) != 1 or not src[0]['members']:
            raise SystemExit('heading %r: its members cannot go to %r' % (title, to[0]))
        src[0]['kind'] = 'heading'
        dst[0]['members'] += [dict(m, listed=True) for m in src[0]['members']]
        src[0]['members'] = []
    for e in entries:
        for b in e['blocks']:
            # art beside the grid reads as marks after a Health ('66  ~-',
            # Alpha Primitives, p.31); coverage() then holds every one to a number
            for k in ('health', 'karma'):
                m = re.match(r'^(-?\d+)[^A-Za-z0-9]*$', b[k] or '')
                if m and m.group(1) != b[k]:
                    b[k] = m.group(1)
                    b['check'] = roster.check(b)
            # the printed minus reads as a dash ('-100' as U+2014 100, Destroyer p.47)
            if b['popularity']:
                b['popularity'] = re.sub('^[' + DASH + r']\s*(?=\d)', '-', b['popularity'])
            lab = by_grid.get((b['page'], b['health']))
            if lab:
                b['label'] = lab
        # A run-in capital heading inside a character's entry is part of its
        # text (WEAKNESS, EQUIPMENT, SOUL GEM, THE SURFBOARD), as on ME1. Under
        # a heading (NOTABLE SKRULLS) the run-ins are members, handed above to
        # the tier the registry names.
        own = [m for m in e['members'] if not m.get('listed')]
        if e['kind'] == 'entry' and own:
            notes = ['%s: %s' % (m['name'].capitalize(), m['text']) for m in own]
            e['sections']['notes'] = ' '.join(filter(None, [e['sections'].get('notes')] + notes))
        e['members'] = [dict((k, v) for k, v in m.items() if k != 'listed') for m in e['members'] if m.get('listed')]
    team_of(book, entries)
    for s, got in statted(book, slug):
        stream += s
        entries += got
    return stream, entries


def statted(book, slug):
    """The registry's `statted_pages`: pages outside character_pages that stat
    a being inside a place's text (the Travel Guide's Central City breeds,
    Lava Men, Living Computers), {page, team, names}. Each page is read alone in
    read_entries' opponent mode, so an entry ends where the place's text
    resumes, and each takes the place as its team. Every name must be an
    entry. A `partial` grid prints only Reason, Intuition and Psyche (the New
    Men: their physical ranks are the animal's): its header is marked from its
    name, and its block is the Karma line's, its rows left for an override."""
    out = []
    for p in book.get('statted_pages', []):
        s = roster.page_stream(dict(book, character_pages=[p['page'], p['page']], sections=[]), slug)
        for line in s:
            line['big'] = False
        insert_headers(dict(book, grid_headers=[h for h in book.get('grid_headers', []) if h[0] == p['page']]), s)
        partial = {}
        for name, karma in p.get('partial', []):
            hits = [i for i, l in enumerate(s) if roster.norm(l['text']) == roster.norm(name)]
            k = next((j for j in range(hits[0], len(s)) if re.search(r'Karma\W*%d\b' % karma, s[j]['text'])), None) if len(hits) == 1 else None
            if k is None:
                raise SystemExit('partial grid %r (Karma %d) not found on printed %d' % (name, karma, p['page']))
            s[hits[0]]['big'] = True
            partial[name] = s[k]
            # the grid's own lines are not the entry's text: "Physical ranks
            # Vary" above the Karma line, and the rows under it
            end = k
            while end + 1 < len(s) and ROW.match(s[end + 1]['text']):
                end += 1
            start = k - 1 if 'ranks' in s[k - 1]['text'] else k
            del s[start:end + 1]
        mark_headers(s, set())
        for line in s:
            if line['big']:
                line['text'] = printed(line['text'])
        s[:] = [l for l in s if not map_label(l)]
        got =roster.read_entries(s, roster.GridReader(book, slug), opponent=True, grid=grid_at)
        roster.finish(got)
        for e in got:
            e['team'] = p['team']
            line = partial.get(e['header'])
            if line:
                # with no grid read, read_entries took the note under it as
                # identity lines ("(Note: The physical ranks ..."): it is text
                cut = next((n for n, t in enumerate(e['identity']) if t.startswith('(')), len(e['identity']))
                e['prose'] = roster.join_text(e['identity'][cut:] + [e['prose']])
                e['identity'] = e['identity'][:cut]
                e['blocks'].append({'label': None, 'page': line['printed'], 'pdf': line['pdf'], 'col': line['col'], 'kind': 'partial',
                                    'abilities': [{'letter': l, 'number': None, 'code': None} for l in roster.ABILITIES],
                                    'health': None, 'karma': None, 'resources': None, 'popularity': None,
                                    'check': {'ranks': [], 'health': None, 'karma': None, 'unread': True, 'ok': False}})
        missing = [n for n in p['names'] if not any(roster.norm(e['header']) == roster.norm(n) for e in got)]
        if missing:
            raise SystemExit('statted page %d: no entry for %s' % (p['page'], missing))
        out.append((s, got))
    return out


SUBHEAD = re.compile(r"^[A-Z][A-Z' &-]+$")


def items(book, slug):
    """The Travel Guide's places and the Vehicles, for scripts/msh/extras.py:
    [{name, kind, page, vehicle, parts, text: [[part, name, lines]]}], the
    shape extras.items() gives for MA1.

    A place or vehicle starts at its header, which the registry's
    `item_headers` names ([page, TITLE, kind]; ' / ' joins a title set on two
    lines); each must be found once on its page. A map's title set far larger
    than any header ('MANHATTAN' over the map of the island, p.85) is not one.
    Inside it:
      - a sub-heading in capitals (FF HEADQUARTERS, NOTABLE XANDARIANS) or a
        run-in (ARTHROS:) starts a named part, as the Danger Room's do in MA1
      - map lettering is dropped (map_label), and so is any other line in
        capitals: a comic panel's balloons (p.87)
      - a being statted there (`statted_pages`) is on a card of its own, so its
        text is cut from its name to the next header
    MA4 prints no Control, Speed or Body line; a vehicle's are in its text."""
    first, last = book['item_pages']
    stream = roster.page_stream(dict(book, character_pages=[first, last], sections=[]), slug)
    heads = {}
    for page, title, kind in book['item_headers']:
        lines = title.split(' / ')
        hits = [i for i, l in enumerate(stream) if l['printed'] == page and l['h'] <= 2 * l['body_h']
                and roster.is_caps(l['text']) and roster.norm(printed(l['text'])) == roster.norm(lines[0])]
        if len(hits) != 1:
            raise SystemExit('item %r: %d lines on printed %d, not 1' % (title, len(hits), page))
        i = hits[0]
        for k, part in enumerate(lines[1:], 1):
            if roster.norm(printed(stream[i + k]['text'])) != roster.norm(part):
                raise SystemExit('item %r: line %d reads %r' % (title, k + 1, stream[i + k]['text']))
            stream[i + k]['joined'] = True
        heads[i] = (' '.join(lines), kind)
    cuts = set()
    for p in book.get('statted_pages', []):
        for name in p['names']:
            hits = [i for i, l in enumerate(stream) if l['printed'] == p['page'] and len(roster.norm(l['text'])) >= 4
                    and roster.norm(name).startswith(roster.norm(l['text']))]
            if not hits:
                raise SystemExit('statted %r: not found on printed %d' % (name, p['page']))
            cuts.add(hits[0])
    out, cur, cutting = [], None, False
    for i, line in enumerate(stream):
        if i in heads:
            name, kind = heads[i]
            cur = {'name': name, 'kind': kind, 'page': line['printed'], 'vehicle': {}, 'parts': [], 'text': [['prose', None, []]]}
            out.append(cur)
            cutting = False
            continue
        if i in cuts:
            cutting = True
        if cur is None or cutting or line.get('joined') or map_label(dict(line, big=False)):
            continue
        t = line['text'].strip()
        m = roster.RUN_IN.match(t)
        nxt = stream[i + 1]['text'] if i + 1 < len(stream) else ''
        if m and line['x0'] - line['left'] < 40:
            label = m.group(1).strip()
            cur['parts'].append(label)
            cur['text'].append(['part', label, [m.group(2)]])
        elif SUBHEAD.match(t) and len(t.split()) <= 5 and sum(c.isalpha() for c in t) >= 4 \
                and line['h'] <= 2 * line['body_h'] and not roster.is_caps(nxt):
            cur['parts'].append(t)
            cur['text'].append(['part', t, []])
        elif not roster.is_caps(t):
            cur['text'][-1][2].append(t)
    return out


def coverage(book, entries):
    """Every Health and Karma is a number: MA4 prints one on every grid, and
    roster.check() passes one it cannot read (ME1's lesson, gridbooks.coverage).
    Returns the lines to print and whether anything failed."""
    lines = []
    for e in entries:
        for b in e['blocks']:
            if b.get('override', {}).get('verdict') == 'rows':
                continue                # its values are the page's, read off the image (the New Men print no Health)
            for k in ('health', 'karma'):
                if roster.as_int((b[k] or '').replace(',', '')) is None:
                    lines.append('  %s IS NOT A NUMBER: %s p.%s: %r' % (k.upper(), e['header'], b['page'], b[k]))
    lines.insert(0, '  every Health and Karma a number: %s' % ('no' if lines else 'yes'))
    return lines, len(lines) > 1
