# -*- coding: utf-8 -*-
"""Parse a Marvel module whose characters are MA1's grids in booklets (ME1).

    python scripts/msh/roster.py me1     # roster.py hands this book to here

A book whose registry entry says "layout": "grid-booklets" is read here. Its
pages are set like MA1's - three columns, a FASERIP grid of numbers and rank
codes, KNOWN POWERS:, TALENTS:, CONTACTS:, BACKGROUND: - so the lines, the
grid crop and the entry loop are scripts/msh/roster.py's own (lines_of,
GridReader, read_entries). What differs is where the characters are and how
their headers are told apart, and that is all this module does:

  - THE PAGES. A boxed module of booklets each numbered from 1 (registry
    `parts`), so every line carries its booklet (`part`) and printed page.
    The characters are in `character_ranges` (the Adventure Book's four
    non-pregenerated heroes, the whole Resource Book) and on `opponents`
    pages: an adventure chapter that stats the character its heroes meet in
    the middle of its prose.
  - THE HEADERS, found from the grid. ME1's headers are set 1.16-1.26 times
    the body height, and so, as Tesseract boxes them, are body lines with
    tall capitals and descenders (1.29 on some), so height cannot tell them
    apart (survey: me1.md). Every character here has a grid, so a header is
    the line above its grid: the nearest line in capitals within three lines,
    below which only an identity line or two sit ("BLACK BOLT" / "Blackagar
    Boltagon"), or else the short name line right above it ("Ghoul Captain").
  - WHERE AN ENTRY ENDS. At the next header; at the Contents' own titles that
    are not characters ("Kree", "Cosmic Indifference"), where the book's prose
    between the characters begins; at each top-level section's first page; and
    on an opponent's page where the chapter resumes (read_entries' opponent
    mode).
  - THE CHECKLISTS. The Contents' character lines (`roster_sections`), the
    registry's opponents and tiers, and the Pregenerated Heroes Summary
    (`reference_summary`): every name must be an entry, every statted entry
    must be on one of them, and each Summary row must agree with its block
    unless scripts/msh/<slug>-overrides.json records the chart's misprint.
    Four Summary heroes have no block anywhere else; their entries are built
    from the chart, numbers and all, as printed.
"""
import collections, io, json, os, re, statistics

import roster

# stands in for the colon of a registry not_run_ins name while the entries are
# read (U+2236 RATIO: roster.RUN_IN wants a colon), and is put back after
NOT_A_COLON = chr(0x2236)


def part_of(book, name):
    return next(p for p in book['parts'] if p['name'] == name)


def base(header):
    return roster.norm(re.sub(r'\([^)]*\)', '', header or ''))


def short(text):
    return len(text.split()) <= 6 and not text.rstrip().endswith(('.', ':', ',', ';'))


def stream_of(book, slug, part, first, last):
    """Printed pages first..last of one booklet as one stream, cut into
    columns and lines exactly as roster.page_stream does for MA1."""
    offset = part_of(book, part)['offset']
    tsv = os.path.join(roster.CACHE, 'books', slug, 'tsv')
    stream = []
    # MX1 (registry column_left_quantile): the art's lettering welds onto a
    # column's top lines (printed 10, column 2: five of 37 lines at x 734-836
    # against a body at 874-880), so the tenth-percentile left edge sits in
    # the art and a flush run-in reads as indented
    quantile = book.get('column_left_quantile', 10)
    labels = [lab for lab in book.get('section_labels', []) if lab != lab.upper()] if book.get('title_case_labels') else []
    subheads = set(book.get('subhead_labels', []))
    stops, stopped = collections.defaultdict(list), collections.Counter()
    for p, page, lab in book.get('stop_labels', []):
        if p == part and first <= page <= last:
            stops[(p, page)].append(lab)
            stopped[(p, page, lab)] = 0
    # MX1 (registry bullet_marks): a list's bullet read as a letter or a sign
    # at a line's start ('e pistol;', printed 13) is not a word of the text
    bullet = re.compile(r'^(?:%s)\s+(?=[a-z])' % '|'.join(re.escape(m) for m in book['bullet_marks'])) \
        if book.get('bullet_marks') else None
    for printed in range(first, last + 1):
        pdf = printed + offset
        words, (W, H) = roster.read_words(os.path.join(tsv, 'p%03d.tsv' % pdf))
        # MX1 (registry art_boxes [part, page, x0, y0, x1, y1], TSV pixels): an
        # illustration's lettering and linework read as words that weld onto
        # the column beside it (printed 10's map, printed 14's panel); a word
        # whose centre is inside a box is not text. A box that takes no word
        # is stale, and stops the build.
        boxes = [b[2:] for b in book.get('art_boxes', []) if b[0] == part and b[1] == printed]
        for box in boxes:
            inside = lambda w: box[0] <= w['x'] + w['w'] / 2 < box[2] and box[1] <= w['y'] + w['h'] / 2 < box[3]
            if not any(inside(w) for w in words):
                raise SystemExit('%s: art_boxes %s p.%d %r takes no word' % (slug, part, printed, box))
            words = [w for w in words if not inside(w)]
        body = [w for w in words if w['y'] > 0.10 * H and w['y'] + w['h'] < 0.935 * H
                and '\u2122' not in w['t'] and '\u00ae' not in w['t']]
        if not body:
            continue
        body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
        edges = [0] + roster.gutters(body, W, book['columns']) + [W]
        for c in range(book['columns']):
            col = [w for w in body if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
            # MX1 (registry art_box_edge): an art box whose right edge falls
            # inside this column narrows it, and the lines beside the box (the
            # Mark VI's Gas Jets and Customization beside printed 10's map, at
            # x 1272 against a column body at 874-880) start at the box's edge,
            # not at the column's left, so a flush run-in there reads as flush.
            # A word beside it boxed over twice the body height (that column's
            # "areas", 76 px against 32, which sorted it under "away.") is cut
            # to the body height from its top.
            beside = [box for box in boxes if edges[c] < box[2] < edges[c + 1]] if book.get('art_box_edge') else []
            near = lambda box, x, y0, y1: box[2] <= x and y0 < box[3] and y1 > box[1]
            col = [dict(w, h=int(round(body_h))) if w['h'] > 2 * body_h
                   and any(near(box, w['x'], w['y'], w['y'] + w['h']) for box in beside) else w for w in col]
            lines = [l for l in roster.lines_of(col) if l['conf'] >= 45 and any(ch.isalnum() for ch in l['text'])]
            if not lines:
                continue
            left = sorted(l['x0'] for l in lines)[len(lines) // quantile]
            for l in lines:
                edge = next((box[2] for box in beside if near(box, l['x0'], l['y0'], l['y1'])), None)
                # MX1 (registry title_case_labels): a run-in label set in title
                # case ("Known Powers:") is raised to the capitals roster.RUN_IN
                # and roster.SECTION read
                for lab in labels:
                    if l['text'].startswith(lab + ':'):
                        l['text'] = lab.upper() + l['text'][len(lab):]
                # MT2 (registry subhead_labels): a section subhead in capitals
                # with no colon (KNOWN POWERS, BACKGROUND, printed 52-63) opens
                # its section as a run-in does
                if l['text'].strip() in subheads:
                    l['text'] = l['text'].strip() + ':'
                # MT2 (registry stop_labels [part, page, label]): a run-in label
                # printed with a full stop for its colon (the Twain android's
                # Talents. and Contacts., printed 36) is read as the run-in
                for lab in stops.get((part, printed), ()):
                    if l['text'].startswith(lab + '.'):
                        l['text'] = lab.upper() + ':' + l['text'][len(lab) + 1:]
                        stopped[(part, printed, lab)] += 1
                # MX1 (registry not_run_ins): a name with a colon in it
                # ("SWAT:AM") is not a run-in label; parse() puts the colon back
                for phrase in book.get('not_run_ins', []):
                    l['text'] = l['text'].replace(phrase, phrase.replace(':', NOT_A_COLON))
                if bullet:
                    l['text'] = bullet.sub('', l['text'])
                l.update(pdf=pdf, printed=printed, part=part, col=c + 1, left=max(left, edge or 0), body_h=body_h,
                         col_x0=max(0, edges[c] if c else left - 20), col_x1=edges[c + 1], big=False)
                stream.append(l)
    for (p, page, lab), n in stopped.items():
        if n != 1:
            raise SystemExit('%s: stop_labels finds %r %d times on %s p.%d, not once' % (slug, lab + '.', n, p, page))
    # MX1 (registry speck_lines [part, page, as read, as printed], MH9's
    # shape): a line the OCR misread that only the page image settles (Blue's
    # identity line, printed 13: Biumal for Blumal). Each must be found
    # exactly once on its page, or the build stops.
    for p, page, old, new in [d for d in book.get('speck_lines', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and l['text'].strip() == old]
        if len(hits) != 1:
            raise SystemExit('%s: speck_lines finds %r %d times on %s p.%d, not once' % (slug, old, len(hits), part, page))
        hits[0]['text'] = new
    # ME3 (registry power_heads [part, page, power name]): a run-in power whose
    # line above ends no sentence (Firelord's Energy Sheath after a list of
    # forms, Adventure p.4; Mephisto's Enlargement after "Galactus.]",
    # Resource p.6) is marked as a power head, which roster.read_entries takes
    # as a new power. Each must be found exactly once on its page.
    for p, page, head in [d for d in book.get('power_heads', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and l['text'].startswith(head + ':')]
        if len(hits) != 1:
            raise SystemExit('%s: power_heads finds %r %d times on %s p.%d, not once' % (slug, head, len(hits), part, page))
        hits[0]['power_head'] = True
    # MT2 (registry indented_power_heads [part, page, power name]): a power
    # inside a chapter's block set indented like the chapter's paragraphs (the
    # Twain android's Body Armor and Radio Communication, printed 36), which
    # roster.read_entries would read as the chapter resuming. Each must be
    # found exactly once on its page.
    for p, page, head in [d for d in book.get('indented_power_heads', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and l['text'].startswith(head + ':')]
        if len(hits) != 1:
            raise SystemExit('%s: indented_power_heads finds %r %d times on %s p.%d, not once' % (slug, head, len(hits), part, page))
        hits[0]['indented_head'] = True
    # ME3 (registry health_below): a Health set on the line below its label
    # ("F 5000 Cl5000 Health:", then "20,000" at the column's right: Resource
    # pp.2, 3, 6, 9, 11 and 12), so the grid has no anchor and no header; the
    # value is joined to its label's line
    k = 0
    while book.get('health_below') and k + 1 < len(stream):
        a, b = stream[k], stream[k + 1]
        if re.search(r'Heal?th:\s*$', a['text']) and (b['pdf'], b['col']) == (a['pdf'], a['col']) \
                and b['x0'] > a['x0'] + 200 and re.match(r'^\d[\d,]*\*?$', b['text'].strip()):
            stream[k] = dict(a, text=a['text'].rstrip() + ' ' + b['text'].strip())
            del stream[k + 1]
        k += 1
    # ME3 (registry two_line_headers [part, page, first line, second line], as
    # read): a header set on two lines ("MEPHISTO'S DEMONIC" / "THRALLS",
    # Resource p.7), of which mark_headers marks only the line nearest the
    # grid, is joined to one line. Each must be found exactly once.
    for p, page, first_t, second_t in [d for d in book.get('two_line_headers', []) if d[0] == part and first <= d[1] <= last]:
        at = [k for k in range(len(stream) - 1) if stream[k]['printed'] == page
              and roster.norm(stream[k]['text']) == roster.norm(first_t) and roster.norm(stream[k + 1]['text']) == roster.norm(second_t)]
        if len(at) != 1:
            raise SystemExit('%s: two_line_headers finds %r / %r %d times on %s p.%d, not once' % (slug, first_t, second_t, len(at), part, page))
        k = at[0]
        stream[k] = dict(stream[k], text=stream[k]['text'].strip() + ' ' + stream[k + 1]['text'].strip(), y1=stream[k + 1]['y1'])
        del stream[k + 1]
    return stream


def mark_headers(stream, cards=()):
    """Mark the header above each grid. Returns the headers' texts. With
    `cards` (the registry's, MX1), a line above the grid that is a card's name
    is its header: MX1 sets them in title case over an identity line ("Blue" /
    "Hugh Blumal, mutant hound"), and the Mark VI's ends in a colon, which is
    dropped."""
    found = []
    names = {roster.norm(c) for c in cards}
    for i, line in enumerate(stream):
        if not roster.ANCHOR.search(line['text']) or line.get('headed'):
            continue
        above, j = [], i - 1
        while j >= 0 and len(above) < 3:
            if not roster.ROW.match(stream[j]['text']):
                above.append(j)
            j -= 1
        named = [j for j in above if names and roster.norm(stream[j]['text']) in names]
        if named:
            stream[named[0]]['text'] = stream[named[0]]['text'].rstrip(': ')
            stream[named[0]]['big'] = True
            found.append(stream[named[0]]['text'])
            continue
        head = None
        for k, j in enumerate(above):
            t = stream[j]['text']
            if roster.is_caps(t) and sum(c.isalpha() for c in t) >= 3 and not roster.RUN_IN.match(t) \
                    and all(short(stream[x]['text']) for x in above[:k]):
                head = j
                break
        if head is None and above and short(stream[above[0]]['text']):
            head = above[0]
        if head is not None:
            stream[head]['big'] = True
            found.append(stream[head]['text'])
    return found


def mark_breaks(book, stream, part, headers):
    """The Contents' titles that are not characters end the entry before them:
    the book's own prose starts there. A top-level section starts a page."""
    names = {base(h) for h in headers}
    titles = {roster.norm(sub or section) for section, sub, _p, p in book['sections'] if p == part}
    titles -= names
    tops = {page: section for section, sub, page, p in book['sections'] if p == part and sub is None}
    out, seen = [], set()
    for l in stream:
        if l['printed'] in tops and l['printed'] not in seen:
            seen.add(l['printed'])
            out.append(dict(l, text=tops[l['printed']], synthetic=True, big=True, x0=0, x1=0, y0=0, y1=0, h=0))
        if not l['big'] and short(l['text']) and roster.norm(l['text']) in titles:
            l['big'] = True
        out.append(l)
    return out


def team_of(book, part, page, seen=()):
    """The team a page files under. MT2: a team with a fourth field starts at
    that header on its page, not at the page's top (Non-Player Characters,
    printed 5, under the Scarlet Witch); `seen` is the headers read so far on
    the page, the entry's own among them."""
    team = None
    for t in book.get('teams', []):
        p, first, name = t[:3]
        if p == part and (first < page or first == page and (len(t) < 4 or t[3] in seen)):
            team = name
    return team


def place_headers(book, stream):
    """A header Tesseract did not read at all (ME2's BALDER, YMIR and GAL: in
    neither the TSV nor the text) is placed above its grid from the registry's
    `grid_headers`, each naming its grid by booklet, printed page and Health.
    Read off the page images; nothing but the grid sits under each. A
    `health_printed` (ME3's VOYD: "20,000") is the Health as the line reads."""
    for g in book.get('grid_headers', []):
        health = re.escape(g['health_printed']) if 'health_printed' in g else '%d' % g['health']
        at = [i for i, l in enumerate(stream) if l['part'] == g['part'] and l['printed'] == g['page']
              and re.search(r'Heal?th' + roster.EQ + r'?\s*' + health + r'\b', l['text'])]
        if not at:
            continue                    # another range's page
        if len(at) != 1:
            raise SystemExit('grid_headers: %s p.%d Health %d is on %d lines, not 1' % (g['part'], g['page'], g['health'], len(at)))
        line = stream[at[0]]
        stream.insert(at[0], dict(line, text=g['name'], big=True, conf=100, y0=line['y0'] - 50, y1=line['y0'] - 8))
    return stream


def mark_titles(book, stream):
    """The registry's `extra_titles` (MX1): [part, printed page, title] for a
    printed title the Contents does not list and that is not a character
    (Sentinel Surveillance Base, printed 12; Vigilantes, printed 28). Each
    opens a heading entry, so the text under it is not taken into the
    character above; each must be found exactly once on its page."""
    for part, page, title in book.get('extra_titles', []):
        if not any(l['part'] == part and l['printed'] == page for l in stream):
            continue                    # another range's page
        hits = [l for l in stream if l['part'] == part and l['printed'] == page and roster.norm(l['text']) == roster.norm(title)]
        if len(hits) != 1:
            raise SystemExit('extra_titles: %r is on %d lines of %s p.%d, not 1' % (title, len(hits), part, page))
        hits[0].update(text=title, big=True, synthetic=True)
    return stream


# ME2's one-line grids: the seven letters, a row of numbers (or none: Beta
# Ray Bill's humanoid form prints codes only), a row of codes, then Health and
# Karma on lines of their own or one ("Health: 80 Karma: 100").
LETTERS = re.compile(r'^F\s+A\s+\S{1,2}\s+E\s+R\s+\S{1,2}\s+P$')
# MX1 (registry letters_marks): SWAT:AM's S reads as a mark, S and a mark
# (printed 13), three characters where LETTERS allows two
LETTERS_MARKS = re.compile(r'^F\s+A\s+\S{1,3}\s+E\s+R\s+\S{1,3}\s+P$')
HEALTH_LINE = re.compile(r'^Heal?th:\s*(\S+)(?:\s+Karma:\s*(\S+))?$')
KARMA_LINE = re.compile(r'^Karma:\s*(\S+)$')
# MT2 (registry health_sentence): a form's Health and Karma in a sentence
HEALTH_SENTENCE = re.compile(r'Health is (\d+),? and (?:his|her|its) Karma (?:begins at|is) (\d+)')
# a bare X, Y or Z under a number is Shift X, Y or Z (Actus, printed 16)
SHIFT = {'X': 'ShX', 'Y': 'ShY', 'Z': 'ShZ'}


def line_codes(text, spill, marks=False):
    """The codes row as seven codes. A Class rank set on two lines ("Cl" over
    "1000") takes its number from the line below (`spill`); two Shift codes run
    together ("ZZ") are two codes."""
    tokens, out = text.split(), []
    if marks:
        # MT3 (registry code_marks): marks hung in a codes row, an underscore
        # token and a mark before a code (the Kang Duplicate's Battle Robots,
        # printed 46), are not codes
        tokens = [t for t in (re.sub(r'[^0-9A-Za-z]', '', t) for t in tokens) if t]
    k = 0
    while k < len(tokens):
        t = tokens[k]
        if re.fullmatch(r'C[lI1]', t):
            if k + 1 < len(tokens) and re.fullmatch(r'\d{4}', tokens[k + 1]):
                t, k = t + ' ' + tokens[k + 1], k + 1
            elif spill:
                t = t + ' ' + spill.pop(0)
            out.append(t)
        elif re.fullmatch(r'[XYZ]{2,3}', t):
            out += list(t)
        else:
            out.append(t)
        k += 1
    return out


def read_line_grid(stream, i, sentence=False, mends=()):
    """The one-line grid whose letters are stream[i]: (rows, Health, Karma,
    the index after it), or None. Every line is in one column of one page.
    `mends` is the registry's one-line grid mends set for the book (MT3)."""
    same = lambda j: j < len(stream) and stream[j]['pdf'] == stream[i]['pdf'] and stream[j]['col'] == stream[i]['col']
    h = next((j for j in range(i + 1, i + 6) if same(j) and HEALTH_LINE.match(stream[j]['text'].strip())), None)
    if h is None:
        # MT2 (registry health_sentence): a form's Health and Karma printed in
        # a sentence under its grid, not on lines of their own (Hamilton
        # Slade, printed 53); the sentence is kept in the entry's text
        s = next((j for j in range(i + 2, i + 5) if same(j) and 'Health is' in stream[j]['text']), None) if sentence else None
        m = s is not None and HEALTH_SENTENCE.search(stream[s]['text'] + ' ' + (stream[s + 1]['text'] if same(s + 1) else ''))
        if m:
            h, health, karma, end = s, m.group(1), m.group(2), s
        elif 'derived_totals' in mends and same(i + 2) and len(stream[i + 1]['text'].split()) == 7 \
                and len(stream[i + 2]['text'].split()) == 7 \
                and all(SHIFT.get(t) or roster.canon(t) for t in stream[i + 2]['text'].split()):
            # MT3 (registry derived_totals): a grid that prints neither Health
            # nor Karma (the scorpions, printed 34) ends at its row of seven
            # codes under its row of seven numbers; line_grids derives both
            h, health, karma, end = i + 3, None, None, i + 3
        else:
            return None
    else:
        m = HEALTH_LINE.match(stream[h]['text'].strip())
        health, karma, end = m.group(1), m.group(2), h + 1
    if karma is None and health is not None and same(h + 1) and KARMA_LINE.match(stream[h + 1]['text'].strip()):
        karma, end = KARMA_LINE.match(stream[h + 1]['text'].strip()).group(1), h + 2
    texts = [stream[j]['text'].strip() for j in range(i + 1, h)]
    numbers = None
    if texts and all(re.search(r'\d', t) for t in texts[0].split()):
        # a mark OCR hangs on a number ('�50', Charon's P) is not a digit
        numbers = [roster.fix_digits(re.sub(r'[^0-9OolI]', '', t)) for t in texts.pop(0).split()]
    spill = [t for x in texts[1:] for t in x.split() if re.fullmatch(r'\d{4}', t)]
    codes = line_codes(texts[0], spill, 'code_marks' in mends) if texts else []
    if 'class_i_digit' in mends:
        # MT3 (registry class_i_digit): a Class rank's 1 read as i (the
        # fish's Cl1000 as Cli000, printed 21)
        codes = [re.sub(r'^(C[lI1])i(?=\d{3}$)', r'\g<1>1', c) for c in codes]
    canon =[SHIFT.get(c) or roster.canon(c) for c in codes]
    if len(canon) != 7 or None in canon or (numbers is not None and len(numbers) != 7) or spill:
        raise SystemExit('a one-line grid read wrong, %s p.%d: %r' % (stream[i]['part'], stream[i]['printed'], texts))
    rows = [{'letter': roster.ABILITIES[n], 'number': numbers[n] if numbers else roster.RANK_NUMBER[c],
             'code': c, 'printed_code': codes[n], 'rest': ''} for n, c in enumerate(canon)]
    return rows, health, karma, end


def lost_letters(stream, i, letters):
    """MT2 (registry lost_letters): stream[i] is a seven-token row of numbers
    or codes with a Health line within two lines, and the line above it is not
    the letters, which read below confidence and left the stream."""
    toks = stream[i]['text'].split()
    if len(toks) != 7 or (i > 0 and letters.match(stream[i - 1]['text'].strip())):
        return False
    if not (all(re.fullmatch(r'[0-9OolI]{1,4}', t) for t in toks)
            or all(SHIFT.get(t) or roster.canon(t) for t in toks)):
        return False
    return any(j < len(stream) and stream[j]['col'] == stream[i]['col'] and HEALTH_LINE.match(stream[j]['text'].strip())
               for j in (i + 1, i + 2))


def line_grids(book, stream, keyed, labelled, derived=None):
    """Find the registry's `one_line_grids` on this stream's pages, in reading
    order. A grid with a `name` is a character of its own and gets a header
    line (the book prints none: the chapter's prose names it); its lines become
    one line that roster.read_entries reads as a grid through grid(). A grid
    with an `entry` and a `label` is a form inside that entry: its lines are
    taken out of the text, and the block is added to the entry afterwards."""
    want = collections.defaultdict(list)
    for g in book.get('one_line_grids', []):
        want[(g['part'], g['page'])].append(g)
    pages = {(l['part'], l['printed']) for l in stream}
    if not any(k in pages for k in want):
        return stream
    letters = LETTERS_MARKS if book.get('letters_marks') else LETTERS
    sentence = bool(book.get('health_sentence'))
    mends = {k for k in ('class_i_digit', 'code_marks', 'derived_totals') if book.get(k)}
    # ME3 (a grid's `wrapped`: the serpent, Adventure p.11 column 2): a grid
    # wrapped after R, letters "F A S E R" / "I P" and codes "Un Mn Mn Un Fe" /
    # "Rm Fe", is joined to one line of each on the pages of such a grid
    wrapped = {k for k, gs in want.items() if any(g.get('wrapped') for g in gs)}
    wrap_a, wrap_b = re.compile(r'^F\s+A\s+\S{1,2}\s+E\s+R$'), re.compile(r'^\S{1,2}\s+P$')
    k = 0
    while wrapped and k + 3 < len(stream):
        if (stream[k]['part'], stream[k]['printed']) in wrapped and wrap_a.match(stream[k]['text'].strip()) \
                and wrap_b.match(stream[k + 1]['text'].strip()) \
                and len(stream[k + 2]['text'].split()) == 5 and len(stream[k + 3]['text'].split()) == 2:
            stream[k] = dict(stream[k], text=stream[k]['text'].strip() + ' ' + stream[k + 1]['text'].strip())
            stream[k + 2] = dict(stream[k + 2], text=stream[k + 2]['text'].strip() + ' ' + stream[k + 3]['text'].strip())
            del stream[k + 3]
            del stream[k + 1]
        k += 1
    out, i = [], 0
    while i < len(stream):
        l = stream[i]
        key = (l['part'], l['printed'])
        got = read_line_grid(stream, i, sentence, mends) if want.get(key) and letters.match(l['text'].strip()) else None
        lost = False
        if not got and want.get(key) and book.get('lost_letters') and lost_letters(stream, i, letters):
            # MT2 (registry lost_letters): the letters line read below
            # confidence and left the stream (Khan's Champion, printed 33;
            # Lobo, 57), so the row under it starts the grid
            fake = [dict(l, text='F A S E R I P')] + stream[i:]
            got = read_line_grid(fake, 0, sentence, mends)
            if got:
                got = got[:3] + (i + got[3] - 1,)
                lost = True
        if not got:
            out.append(l)
            i += 1
            continue
        rows, health, karma, end = got
        made = []
        if 'derived_totals' in mends:
            # MT3 (registry derived_totals): a total the grid does not print
            # (the snakes' Karma, printed 33; the scorpions' Health and Karma,
            # 34) is derived from the rows, and the block says so, as rank_only
            # says a number is derived, since the check on it cannot fail
            if health is None:
                health, made = str(sum(r['number'] for r in rows[:4])), made + ['health']
            if karma is None:
                karma, made = str(sum(r['number'] for r in rows[4:])), made + ['karma']
        if any('health' in g for g in want[key]):
            # MX1: each name is tied to its grid by the Health it prints, so a
            # grid missed on the page cannot hand its name to the next one
            hits = [g for g in want[key] if str(g.get('health')) == health]
            if len(hits) != 1:
                raise SystemExit('one_line_grids: %s p.%d Health %s names %d grids, not 1' % (l['part'], l['printed'], health, len(hits)))
            g = hits[0]
            want[key].remove(g)
        else:
            g = want[key].pop(0)
        rank_only = not re.search(r'\d', (stream[i] if lost else stream[i + 1])['text'])
        if g.get('name') and g.get('subhead'):
            # MX1: the grid's name is the subhead above the paragraph that
            # introduces it ("The Blue Knight" over a typical policeman's
            # grid), so the entry starts there and the next subhead ends it
            at = [k for k in range(len(out)) if (out[k]['part'], out[k]['printed']) == key
                  and roster.norm(out[k]['text']) == roster.norm(g['subhead'])]
            if len(at) != 1:
                raise SystemExit('one_line_grids: subhead %r is on %d lines of %s p.%d, not 1' % (g['subhead'], len(at), l['part'], l['printed']))
            out[at[0]] = dict(out[at[0]], text=g['name'], big=True, subhead=True)
            rows[0]['rest'] = 'Health: %s Karma: %s' % (health, karma)
            out.append(dict(stream[end - 1], text=rows[0]['rest'], line_grid=rows, headed=True))
            keyed[(l['pdf'], l['col'], health)] = rank_only
        elif g.get('name'):
            out.append(dict(l, text=g['name'], big=True, conf=100, y1=l['y0'] - 8))
            rows[0]['rest'] = 'Health: %s Karma: %s' % (health, karma)
            out.append(dict(stream[end - 1], text=rows[0]['rest'], line_grid=rows))
            keyed[(l['pdf'], l['col'], health)] = rank_only
        else:
            block = {'label': g['label'], 'kind': 'line', 'page': l['printed'], 'pdf': l['pdf'], 'col': l['col'],
                     'abilities': [{k: r[k] for k in ('letter', 'number', 'code', 'printed_code')} for r in rows],
                     'health': health, 'karma': karma, 'resources': None, 'popularity': None}
            if rank_only:
                block['rank_only'] = True
            if made:
                block['derived'] = made
            block['check'] = roster.check(block, roster.rank_ranges(book))
            labelled.append((g, block))
        if made and g.get('name'):
            derived[(l['pdf'], l['col'], health)] = made
        i = end
    left = [g for gs in want.values() for g in gs if (g['part'], g['page']) in pages]
    if left:
        raise SystemExit('one_line_grids not found: %s' % ', '.join(g.get('name') or g['label'] for g in left))
    return out


def grid(stream, i, reader, code_rows=False, end_at_p=False):
    line = stream[i]
    if line.get('line_grid'):
        return line['line_grid'], i + 1
    rows, end = roster.grid_at(stream, i, reader)
    if rows is None and end == i and end_at_p and roster.ANCHOR.search(line['text']):
        # ME3 (registry grids_end_at_p): a grid that prints no Resources and
        # no Popularity (Mephisto's Thralls and Footsoldiers, Resource p.7; the
        # Mindless Ones, p.14; the second grids) ends at its P row, not at a
        # Popularity line, which roster.grid_at wants
        p = next((j for j in range(i + 1, min(len(stream), i + 9)) if stream[j]['pdf'] == line['pdf']
                  and stream[j]['col'] == line['col'] and re.match(r'^\s*P\s+\S', stream[j]['text'])), None)
        if p is not None:
            box = (line['col_x0'], line['y0'] - 45, line['col_x1'], stream[p]['y1'] + 10)
            got = roster.rows_from(reader.read(line['pdf'], box), reader.mends)
            if len(got) < 7:
                got = roster.rows_from([s['text'] for s in stream[i:p + 1]], reader.mends)
            return (got[:7] if len(got) >= 7 else None), p + 1
    if rows is None and end > i and code_rows:
        # MX1 (registry code_rows): a grid of the code then the number in
        # brackets ("F Gd (10) Health: 64"), MA4's order, read by
        # scripts/msh/codegrids.py's row in title case
        import codegrids
        rows2, end2 = codegrids.grid_at(stream, i, reader, pattern=codegrids.ROW_TITLE_CASE)
        if rows2 is not None:
            return rows2, end2
        # the stream can lose the Karma line under confidence 45 (Bernard
        # Carns, printed 25), and codegrids.grid_at wants it, so read
        # roster.grid_at's own box, the Health line to the Popularity line
        pop = next((j for j in range(i, min(len(stream), i + 12)) if stream[j]['pdf'] == line['pdf']
                    and stream[j]['col'] == line['col'] and 'Popular' in stream[j]['text']), None)
        if pop is not None:
            box = (line['col_x0'], line['y0'] - 45, line['col_x1'], stream[pop]['y1'] + 10)
            rows3 = codegrids.rows_from(reader.read(line['pdf'], box), pattern=codegrids.ROW_TITLE_CASE)
            if len(rows3) == 7:
                return rows3, end
    return rows, end


def restore_colons(book, value):
    """Put back the colons stream_of took out of the registry's not_run_ins."""
    if isinstance(value, str):
        for phrase in book.get('not_run_ins', []):
            value = value.replace(phrase.replace(':', NOT_A_COLON), phrase)
        return value
    if isinstance(value, list):
        return [restore_colons(book, v) for v in value]
    if isinstance(value, dict):
        return {k: restore_colons(book, v) for k, v in value.items()}
    return value


def parse(book, slug):
    reader = roster.GridReader(book, slug)
    ranges = roster.rank_ranges(book)
    streams, keyed, labelled, derived = [], {}, [], {}
    cards = [c[2] for c in book.get('cards', [])] if book.get('card_headers') else ()
    for r in book['character_ranges']:
        s = stream_of(book, slug, r['part'], r['pages'][0], r['pages'][1])
        s = mark_titles(book, line_grids(book, place_headers(book, s), keyed, labelled, derived))
        streams.append((mark_breaks(book, s, r['part'], mark_headers(s, cards)), False, ()))
    for o in book['opponents']:
        s = stream_of(book, slug, o['part'], o['page'], o['page'])
        # MX1: an opponent's text that runs on past the art of the next page
        # (Oliver Pierce, printed 28 to 30) reads the pages it names too
        for page in o.get('continues', []):
            s += stream_of(book, slug, o['part'], page, page)
        # MT2 (an opponent's `runs_on`): an opponent's text that runs on to
        # the next page, where another opponent of the registry starts (Hobart,
        # printed 28, into 29): that page is read too, and the entries that
        # start on it are left to its own opponent
        for page in o.get('runs_on', []):
            s += stream_of(book, slug, o['part'], page, page)
        s = mark_titles(book, line_grids(book, place_headers(book, s), keyed, labelled, derived))
        mark_headers(s, cards)
        streams.append((s, True, tuple(o.get('runs_on', []))))
    stream, entries = [], []
    code_rows, end_at_p = bool(book.get('code_rows')), bool(book.get('grids_end_at_p'))
    read_grid = (lambda st, i, rd: grid(st, i, rd, code_rows=code_rows, end_at_p=end_at_p)) if code_rows or end_at_p else grid
    unlabelled = [0]
    # MT2 (registry opponent_section_labels {label: section}): a run-in that
    # opens a section in a chapter's block and in no other book (ROLE PLAYING
    # NOTES, printed 28-29), read as that section in opponent mode alone, where
    # a run-in that is no section ends the entry. MT2 (registry
    # opponent_indented_paragraphs [part, page, header]): an opponent whose
    # own second paragraphs are set indented (Hobart's Talents and Background,
    # printed 28), so an indent after a sentence does not end it
    labels = book.get('opponent_section_labels') or {}
    run_on = book.get('opponent_indented_paragraphs', [])
    found = collections.Counter()
    for s, opponent, runs_on in streams:
        stream += [l for l in s if l['printed'] not in runs_on]
        part = s[0]['part']
        got = roster.read_entries(s, reader, opponent=opponent, grid=read_grid, ranges=ranges, labels=labels,
                                  run_on={(page, head) for p, page, head in run_on if p == part} if opponent else ())
        if runs_on:
            got = [e for e in got if e['pages'][0] not in runs_on]
        for p, page, head in run_on:
            found[(p, page, head)] += sum(1 for e in got if opponent and part == p and e['pages'][0] == page and e['header'] == head)
        for lab in labels if opponent else ():
            # each label must open a section somewhere, or it is stale
            if any(l['text'].startswith(lab + ':') for l in s):
                found[('label', lab)] += 1
        # ME3 (registry header_blocks [part, page, header as read]): a header
        # over a second grid of the entry above ("MEPHISTO (w/Galactus)",
        # Resource p.6) labels that grid, and what is under it is the entry's.
        # Each must be found exactly once in its booklet.
        for p, page, head in book.get('header_blocks', []):
            if s[0]['part'] != p or not any(l['printed'] == page for l in s):
                continue
            at = [n for n, e in enumerate(got) if n and e['pages'][0] == page and e['header'] == head]
            if len(at) != 1:
                raise SystemExit('header_blocks: %r is %d entries of %s p.%d, not 1' % (head, len(at), p, page))
            e, prev = got[at[0]], got[at[0] - 1]
            for b in e['blocks']:
                b['label'] = head
            prev['blocks'] += e['blocks']
            for k in ('identity', 'powers', 'members', 'prose'):
                prev[k] += e[k]
            for k, v in e['sections'].items():
                prev['sections'].setdefault(k, []).extend(v)
            prev['pages'] += [x for x in e['pages'] if x not in prev['pages']]
            del got[at[0]]
        # MT2 (registry not_labels): a capital subhead right above every grid
        # (STATISTICS, printed 52-63) is not a sub-block's name, which
        # read_entries takes such a line for
        for e in got:
            for b in e['blocks']:
                if b.get('label') in book.get('not_labels', []):
                    b['label'] = None
                    unlabelled[0] += 1
        subheads = {id(e) for e in got for l in s if l.get('subhead') and l['text'] == e['header'] and l['printed'] == e['pages'][0]}
        seen = collections.defaultdict(set)
        for e in got:
            if id(e) in subheads:
                # a subhead prints no identity line: the lines under it are
                # the paragraph that introduces the grid (MX1, printed 13)
                e['prose'], e['identity'] = e['identity'] + e['prose'], []
            e['part'] = s[0]['part']
            seen[e['pages'][0]].add(e['header'])
            e['team'] = team_of(book, e['part'], e['pages'][0], seen[e['pages'][0]])
            for b in e['blocks']:
                b['part'] = e['part']
                key = (b['pdf'], b['col'], b['health'])
                if key in keyed:
                    b['kind'] = 'line'
                    if keyed[key]:
                        b['rank_only'] = True
                    if key in derived:
                        b['derived'] = derived[key]
            # Death's "Health: 20,000" (ME2, Resource p.2): check() reads no comma
            for b in e['blocks']:
                if ',' in (b['health'] or '') and b['check'].get('health') is None:
                    b['check'] = roster.check(dict(b, health=b['health'].replace(',', '')), ranges)
        entries += got
    for p, page, head in run_on:
        if found[(p, page, head)] != 1:
            raise SystemExit('opponent_indented_paragraphs: %r is %d opponent entries of %s p.%d, not 1'
                             % (head, found[(p, page, head)], p, page))
    for lab in labels:
        if not found[('label', lab)]:
            raise SystemExit('opponent_section_labels: no opponent page prints %r' % (lab + ':'))
    for t in [t for t in book.get('teams', []) if len(t) > 3]:
        if not any(e['part'] == t[0] and e['pages'][0] == t[1] and e['header'] == t[3] for e in entries):
            raise SystemExit('teams: %s starts at %r, which is no entry on %s p.%d' % (t[2], t[3], t[0], t[1]))
    if book.get('not_labels') and not unlabelled[0]:
        raise SystemExit('not_labels: no block is labelled %s' % ' or '.join(book['not_labels']))
    for g, block in labelled:
        hits = [e for e in entries if e['part'] == g['part'] and base(e['header']) == roster.norm(g['entry'])]
        if len(hits) != 1:
            raise SystemExit('one_line_grids: %s names %d entries, not 1' % (g['entry'], len(hits)))
        block['part'] = g['part']
        hits[0]['blocks'].append(block)
    for g in [g for g in book.get('one_line_grids', []) if g.get('host')]:
        # MT2 (a named grid's `host`): a card's grid set inside another
        # card's entry (Lobo inside Red Wolf's KNOWN POWERS, printed 57) is
        # followed by the host's own sections, which the grid's entry would
        # take: they go back to the host, with the run-ins read as members
        # (Red Wolf's role-playing notes), and the grid's entry keeps its
        # block and the text under the grid
        e = [e for e in entries if e['part'] == g['part'] and g['page'] in e['pages'] and base(e['header']) == roster.norm(g['name'])]
        h = [e for e in entries if e['part'] == g['part'] and g['page'] in e['pages'] and base(e['header']) == roster.norm(g['host'])]
        if len(e) != 1 or len(h) != 1 or not e[0]['sections']:
            raise SystemExit('one_line_grids: %s in %s finds %d and %d entries, not 1 each with sections to give back'
                             % (g['name'], g['host'], len(e), len(h)))
        e, h = e[0], h[0]
        for k, v in e['sections'].items():
            if k in h['sections']:
                raise SystemExit('one_line_grids: %s already has a %s section for %s to give back' % (g['host'], k, g['name']))
            h['sections'][k] = v
        e['sections'] = {}
        h['members'] += e['members']
        e['members'] = []
        h['pages'] += [x for x in e['pages'] if x not in h['pages']]
        e['pages'] = [g['page']]
    slash_forms(book, entries, ranges)
    roster.finish(entries)
    for e in entries:
        # A run-in capital heading inside an entry is part of its text here
        # (Black Bolt's WEAKNESS, Crystal's LIMITATION, Gladiator's ITEMS), not
        # a member: this book prints no team whose members lack a block.
        notes = ['%s: %s' % (m['name'].capitalize(), m['text']) for m in e['members']]
        if notes:
            e['sections']['notes'] = ' '.join(filter(None, [e['sections'].get('notes')] + notes))
            e['members'] = []
        # an illustration beside a column can leave a line of marks ('G\')
        if not re.search(r'[A-Za-z]{3}', e['prose']):
            e['prose'] = ''
    if book.get('not_run_ins'):
        entries[:] = restore_colons(book, entries)
    # MX1 (registry talents_end [part, page, name, talents as printed]): a
    # codes-only grid's TALENT: line is its talents alone, and what follows it
    # (the type's equipment list and how it patrols, printed 13) goes on from
    # the paragraph that introduces the grid, as its prose. The talents must
    # start the section and something must follow, or the build stops.
    for part, page, name, talents in book.get('talents_end', []):
        hits = [e for e in entries if e['part'] == part and page in e['pages'] and e['header'] == name]
        if len(hits) != 1:
            raise SystemExit('talents_end: %s p.%d %r names %d entries, not 1' % (part, page, name, len(hits)))
        e = hits[0]
        t = e['sections'].get('talents', '')
        if not t.startswith(talents + ' '):
            raise SystemExit('talents_end: %s talents read %r, not %r and more' % (name, t[:60], talents))
        e['sections']['talents'] = talents
        e['prose'] = ' '.join(filter(None, [e['prose'].strip(), t[len(talents):].strip()]))
    summary_entries(book, entries)
    return stream, entries


def slash_forms(book, entries, ranges):
    """MT2 (registry slash_forms [{part, page, entry, labels}]): a block that
    prints two forms' values on each row, the second after a slash, and its
    Health as two values with a slash (Moon Knight, printed 4: Normal and
    Moonlight, Health 90/150), is made two blocks labelled as the registry
    says. roster.rows_from read each second value as the row's alternate. The
    entry must have one block, every row an alternate and the Health two
    values, or the build stops."""
    for f in book.get('slash_forms', []):
        hits = [e for e in entries if e['part'] == f['part'] and f['page'] in e['pages'] and base(e['header']) == roster.norm(f['entry'])]
        if len(hits) != 1 or len(hits[0]['blocks']) != 1:
            raise SystemExit('slash_forms: %s p.%d names %d entries, not 1 with one block' % (f['entry'], f['page'], len(hits)))
        b = hits[0]['blocks'][0]
        health = (b['health'] or '').split('/')
        if any('alt' not in a for a in b['abilities']) or len(health) != 2:
            raise SystemExit('slash_forms: %s p.%d reads no second form: %r' % (f['entry'], f['page'], b['health']))
        out = []
        for n, label in enumerate(f['labels']):
            c = dict(b, label=label, health=health[n].strip(),
                     abilities=[dict({k: v for k, v in a.items() if k != 'alt'}, **(a['alt'] if n else {}),
                                     **({'printed_code': a['alt']['code']} if n else {})) for a in b['abilities']])
            c['check'] = roster.check(c, ranges)
            out.append(c)
        hits[0]['blocks'] = out


def forms(name):
    """A checklist name as a header may print it. ME2's Contents inverts some
    ("Chimaera, The", "Asgardian, Typical") where the header reads CHIMAERA,
    The FENRIS WOLF or Typical ASGARDIAN; a leading The is dropped either way."""
    out = {roster.norm(name)}
    if ', ' in name:
        surname, given = name.split(', ', 1)
        out.add(roster.norm(given + ' ' + surname))
    return out | {re.sub(r'^the ', '', n) for n in out}


def match(name, entries, part=None, page=None):
    """The one entry with a block that a checklist name names. A name on two
    checklists (ME2's Titans and Zeus: a Resource Book entry and a second grid
    in a chapter) is told apart by the booklet and page each list gives."""
    n = forms(name)
    hits = [e for e in entries if e['blocks'] and re.sub(r'^the ', '', base(e['header'])) in n
            and (part is None or e['part'] == part) and (page is None or page in e['pages'])]
    return hits[0] if len(hits) == 1 else None


def summary_abilities(values):
    out = []
    for n, v in enumerate(values):
        num, code = v.split(' ', 1)
        out.append({'letter': roster.ABILITIES[n], 'number': int(num), 'code': roster.canon(code), 'printed_code': code})
    return out


def summary_entries(book, entries):
    """Each Summary hero with a block elsewhere takes the chart's spelling as
    its name; each without one becomes an entry of its own, its block the
    chart's row as printed (kind 'summary'). A book with no chart (MX1) has
    no `reference_summary`."""
    s = book.get('reference_summary') or {'heroes': []}
    for name, values, health, karma, powers in s['heroes']:
        e = match(name, entries)
        if e:
            e['name'] = name
            continue
        block = {'label': None, 'kind': 'summary', 'page': None, 'part': s['part'], 'abilities': summary_abilities(values),
                 'health': str(health), 'karma': str(karma), 'resources': None, 'popularity': None}
        block['check'] = roster.check(block, roster.rank_ranges(book))
        entries.append({'kind': 'summary', 'header': name, 'name': name, 'part': s['part'], 'team': s.get('team'), 'pages': [],
                        'identity': [], 'blocks': [block], 'sections': {}, 'members': [], 'prose': '',
                        'powers': [{'name': p, 'text': ''} for p in powers]})


def coverage(book, entries, overrides):
    """Every checklist name is an entry and every statted entry is on a
    checklist; each Summary row agrees with its block, or its misprint is
    recorded. Returns the lines to print and whether anything failed."""
    lines, bad = [], False
    summary = book.get('reference_summary') or {'heroes': []}
    where = [(sub, part, None) for section, sub, _page, part in book['sections'] if section in book.get('roster_sections', []) and sub]
    contents = [w[0] for w in where]
    where += [(n, o['part'], o['page']) for o in book['opponents'] for n in o['names']]
    opponents = [n for o in book['opponents'] for n in o['names']]
    # MX1: no Contents line names a character, so the registry's cards (each
    # header with a block, by booklet and page) are a checklist too
    cards = [(n, part, page) for part, page, n in book.get('cards', [])]
    where += cards
    listed = contents + opponents + book.get('tiers', []) + [c[0] for c in cards]
    for n, part, page in where + [(t, None, None) for t in book.get('tiers', [])]:
        if not match(n, entries, part, page):
            lines.append('  CHECKLIST NAME WITH NO ENTRY: %s' % n)
            bad = True
    known = {f for n in listed for f in forms(n)} | {roster.norm(r[0]) for r in summary['heroes']}
    for e in entries:
        if e['blocks'] and e['kind'] != 'summary' and re.sub(r'^the ', '', base(e['header'])) not in known:
            lines.append('  STATTED ENTRY ON NO CHECKLIST: %s (%s p.%s)' % (e['header'], e['part'], e['pages'][0]))
            bad = True
    # roster.check() passes a Health or Karma it cannot read as a number, which
    # is right for MA1's robots ("Karma = -") and wrong here: ME1 prints a
    # number for every one, so anything else is OCR ('330 k' was, once)
    for e in entries:
        for b in e['blocks']:
            # ...unless the page prints a word on purpose and an override says so
            # (ME2's Death: "Karma: Unlimited", Resource p.2)
            o = b.get('override') or {}
            explained = {o.get('field')} | {x['field'] for x in o.get('also', [])}
            for k in ('health', 'karma'):
                if roster.as_int((b[k] or '').replace(',', '')) is None and k not in explained:
                    lines.append('  %s IS NOT A NUMBER: %s %s p.%s: %r' % (k.upper(), e['header'], e['part'], b['page'], b[k]))
                    bad = True
            # ME3 (registry popularity_numbers): every grid that prints
            # Resources prints a Popularity, a number with a sign or a dash
            # before it and at most a bracket that opens with a number
            # (Gladiator's '15 (100 in the Empire)', Adventure p.3). A value
            # cut off below its label (popularity_below) reads as nothing, and
            # a note under the grid joined to it (popularity_notes) opens with
            # a word, so neither passes unseen. A field of its own, so that
            # turning either mend off turns this red; ME1 and ME2 print words
            # in a Popularity ('0 (And dropping)', ME1 Adventure p.15)
            if book.get('popularity_numbers') and b.get('resources') \
                    and not re.match(r'^[^\w\s(]?\s*\d+(?:\s*\(\d[^)]*\))?$', (b.get('popularity') or '').strip()):
                lines.append('  POPULARITY IS NOT A NUMBER: %s %s p.%s: %r' % (e['header'], e['part'], b['page'], b.get('popularity')))
                bad = True
    marked ={(o['match']['summary'], o['field']): o for o in overrides if 'summary' in o['match']}
    used = set()
    rows = summary['heroes']
    for name, values, health, karma, _powers in rows:
        e = match(name, entries)
        if not e or e['kind'] == 'summary':
            continue
        b = e['blocks'][0]
        diffs = [(a['letter'], '%d %s' % (c['number'], c['code']), '%s %s' % (a['number'], a['code']))
                 for a, c in zip(b['abilities'], summary_abilities(values))
                 if (a['number'], a['code']) != (c['number'], c['code'])]
        if str(health) != (b['health'] or '').strip():
            diffs.append(('health', health, b['health']))
        if str(karma) != (b['karma'] or '').strip():
            diffs.append(('karma', karma, b['karma']))
        for field, printed, value in diffs:
            o = marked.get((name, field))
            if o and str(o['printed']) == str(printed) and str(o['corrected']) == str(value):
                used.add((name, field))
                continue
            lines.append('  SUMMARY DISAGREES: %s %s: chart %s, block %s' % (name, field, printed, value))
            bad = True
    for key in marked:
        if key not in used:
            lines.append('  SUMMARY OVERRIDE MATCHES NOTHING: %s %s' % key)
            bad = True
    lines.insert(0, '  checklists: %d Contents names, %d opponents, %d tiers, all found: %s; summary: %d rows, %d the chart alone, %d chart misprints recorded'
                 % (len(contents), len(opponents), len(book.get('tiers', [])), 'no' if bad else 'yes', len(rows),
                    sum(1 for e in entries if e['kind'] == 'summary'), len(used))
                 + ('; cards: %d' % len(cards) if cards else ''))
    return lines, bad
