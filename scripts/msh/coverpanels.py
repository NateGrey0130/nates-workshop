# -*- coding: utf-8 -*-
"""Parse a Marvel module whose cards are on its cover's inside panels (MH1, MH2).

    python scripts/msh/roster.py mh1     # roster.py hands this book to here

A book whose registry entry says "layout": "cover-panels" is read here, and
comes back as the same entries roster.py writes to roster.json. Its blocks are
MHSP1's (scripts/msh/booklet.py): seven "Fighting: GOOD" rows of rank words and
no numbers, Health:, Karma:, Resources: and Popularity:, then Powers:, run-in
"CAPITALISED NAME." powers, Talents: and Background:. So the block reader and
the text pieces are booklet.py's own (full_grid, is_header, clean_name,
power_name, quotes, block_check). What differs is where the blocks are, and
that is all this module does (apps/marvel-heroes/docs/surveys/mh1.md):

  - THE PANELS. The cards are on the two inside panels of a loose cover
    (registry `panels`), which print no page number, and on three pages of
    the Adventure Book (`character_ranges`). A panel's lines, blocks and
    entries carry its part and no page.
  - TWO-LINE HEADERS. Three names wrap onto a second line (LOCKHEED / THE
    DRAGON). booklet.py's stream re-reads any run of tall lines as fused prose
    and drops capitals, which removes those headers whole, so this stream does
    not mend: on these pages the only tall runs are headers (measured
    2026-10-21) and adjoining header lines are joined instead.
  - TEXT THAT IS NOT A CARD. The Epilog above Magneto's card (registry
    `drop_above`) and the Blackbird's card, a vehicle (`not_characters`).
  - OPPONENTS. A third of the characters are statted only by a one-line grid
    in a chapter's prose (registry `opponents`): a name in capitals (ending in
    a colon, or followed on its line by a short description), a row of the
    letters F A S E R I P, a row of two-letter codes under them, Health:, and
    a Powers: or Special: line. Each is an entry of its own.
  - THE CHECKLIST. The book has no index. The registry's `cards` and
    `opponents` are the survey's list, read off the page images: every name
    must be an entry with a block and every entry with a block on the list.

MH2 is the same series and layout (apps/marvel-heroes/docs/surveys/mh2.md),
and differs in ways its registry entry turns on, so MH1's path is unchanged:

  - `opponent_names: "title"`: a one-line grid's name is in title case on the
    line right above it ("Aliens (humanoid)", "Skrulls:"); the run-in powers
    after its Powers: line are its powers, as a card's are, and go on after a
    paragraph break; an indented line that is no run-in, or a sub-heading
    ("Room 6"), ends the text; a letter row may read two letters as one word
    ("RI").
  - `form_grids`: a grid with no name above it is a second block on a card
    (the Mimic's absorbed form), carrying its own text.
  - `drop_corner`: a corner of a page that is no card's (a coupon).

And in every cover-panels book, as MH1 never needed: a card's run-in power
may end in a colon or fill its line, and a rank word read with a mark in front
of it is read without the mark.

MH3 is the same series again (apps/marvel-heroes/docs/surveys/mh3.md), and
what it adds is behind its registry fields, or reads nothing MH1 or MH2 print
(each proved by building both books before and after, byte for byte):

  - `lost_headers`: a card whose header Tesseract did not read at all (the
    Human Torch's, whose letters touch the portrait's frame), placed above its
    identity line. `drop_lines`: a line that is no card's text (the banner over
    Doom's card, art read as letters). `moves`: a card's text set round a
    portrait, which goes on at the top of another column (the
    Super-Adaptoid's, printed 15).
  - `card_grids`: a one-line grid inside a card's powers (She-Hulk's and the
    Thing's human forms), a second block on that card.
  - A run-in power in mixed case ("GROWTH and SHRINKING."); a name in
    capitals inside a card's Powers: prose is no power; a line Tesseract lost
    between a power's last line and the next head is re-read from the page;
    a dash the block's crop reads where nothing else does is a dash; a
    bracketed Karma is held to the bracketed ranks, as a bracketed Health is.
  - `opponent_powers: "run-in"`: the run-in powers after a one-line grid's
    Powers: line are its powers (RUNIN_POWER), a run-in there is not the next
    name, an indented line ends the text, and a run-in at the top of the next
    column goes on. A Health that opens a bracket it does not close (the
    Super-Adaptoid's form, printed 9, a `form_grids` grid) keeps its number,
    and the bracket is prose.

MH4 is the fourth of the series (apps/marvel-heroes/docs/surveys/mh4.md).
What it adds is behind its registry fields, or reads a shape no earlier book
prints (each proved by building MH1, MH2 and MH3 before and after, byte for
byte):

  - `prose_cards`: a full block set inside a chapter's prose (the Kingpin's,
    printed 5), headed by its name in title case on a line of its own, which
    booklet.is_header does not take; read as a card from that line to the
    next header (the BATTLE banner) or one-line grid.
  - `section_labels` beyond Powers, Talents and Background are sections too
    (Important People, Equipment), keyed in lower case with underscores. A
    run-in under Equipment (the Punisher's GUNS., GRENADES., KNIFE., VAN.) is
    read as a run-in power is and carries `section: "equipment"`; a card may
    print no Talents (Iron Fist's). One that prints a list (GUNS.: an intro
    ending in a colon, then a gun a line) keeps a line break per item
    (gear_text).
  - `split_headers`: a header Tesseract read as two words (TASKMASTE R, split
    at the trademark sign), joined by the registry.
  - `unnamed_grids`: a one-line grid with no name line above it that is a
    character of its own (Reggie, the cyber-sergeants), named by what the
    page's prose calls it. A count before a title-case name ("1 White Tiger",
    "2 Minions") is not part of the name (COUNTED_NAME), and in a title book
    the next grid's name line ends the previous grid's text.
  - A Special: value on a grid's Health line ("Health: 60 Special: Claws"):
    the Health is the number, and the Special is the grid's one power, named
    as printed (survey mh4.md decision 7).
  - `repeat_grids`: a grid that repeats another entry's grid code for code
    (the two "2 Minions" grids, Modok's Minions'), checked against it and not
    an entry (decision 6).
  - `panel_foot`: a panel's text runs below the foot booklet.stream_of keeps
    for a page with a folio (95.5% of the height): the last line of a column
    (Daredevil's "Incredible temporarily.", three lines of the inside back
    cover). Without them the run-in at the top of the next column (BILLY
    CLUB:, CHI:) follows an open sentence and is read as its text.

THE NUMBERS ARE DERIVED, as MHSP1's are: each ability's number is its rank's
standard number (`rank_only`), and Health = F+A+S+E and Karma = R+I+P hold on
every block read that way. A dash printed for an ability (four False robots'
Intuition and Psyche) is printed as a dash and is not an unread rank.
"""
import os, re, statistics

import booklet
import roster

DASH = re.compile(r'^[-_~\u2014\u2013\ufffd]+$')
# a code Tesseract misread, as the page images read it (survey: mh1.md, Rank
# spellings): no rank code starts "Fo" or "tn", so these can be nothing else
CODE_MISREADS = {'FO': 'Fb', 'TN': 'In'}
# a run-in head: a word of capitals, then a colon on the line ("ROBOT
# MENTALLO:", "STORM and ROGUE: Storm and"); "Powers:" and "Special:" are not
RUN_IN_HEAD = re.compile(r"^[A-Z][A-Z'.-]+\b[^:]*:")
# a card's run-in power that ends in a colon, not booklet.POWER_HEAD's period
# (MH2's Captain America and Captain Marvel: "UNIQUE WEAPON: Captain America"),
# and one that fills its line, its text starting on the next (MH2's Wasp:
# "ANIMAL COMMUNICATION AND CONTROL.")
COLON_HEAD = re.compile(r"^([A-Z][A-Z0-9'\u2019 /&-]{1,40}[A-Z0-9]):\s+(.*)$")
WHOLE_HEAD = re.compile(r"^([A-Z][A-Z0-9'\u2019 /&-]{1,40}[A-Z0-9])[.:]()$")
# a one-line grid's name in title case, alone on the line above the letters,
# with an optional qualifier in brackets and an optional colon (MH2:
# "Aliens (humanoid)", "Skrulls:", "Kang's Minions"); registry
# "opponent_names": "title". MH1's are capitals and keep MH1's rule.
TITLE_NAME = re.compile(r"^([A-Z][a-z]+(?:'s)?(?: (?:[A-Z][a-z]+(?:'s)?|\([a-z ]+\)))*):?$")
# a card's run-in power in mixed case, words of capitals joined by a small word
# (MH3's three Skrulls: "GROWTH and SHRINKING. Along with their")
MIXED_HEAD = re.compile(r"^([A-Z][A-Z'-]+(?: (?:and|or|of|the) [A-Z][A-Z'-]+)+)\.\s+(.*)$")
# an opponent's run-in power (registry "opponent_powers": "run-in"): capitals
# ended by a colon or a period ("WEAPONS: Each tower", "BODY ARMOR. Incredible"),
# or capitals going on into their sentence ("FLIGHT is at good speed.")
RUNIN_POWER = re.compile(r"^([A-Z][A-Z'-]+(?: [A-Z][A-Z'-]+)*)(?:\s*([:.])\s+|\s+(?=[a-z]))(.*)$")
SENTENCE_END = ('.', ':', ')', '"', '\u201d', '!')
# an item of a list under an Equipment run-in: a name, a colon and a number
# ("M16 assault rifle: 10 shots, range 7, damage 20", MH4's Punisher)
GEAR_ITEM = re.compile(r'^[A-Z][^:]{0,40}:\s+\d')
APOSTROPHES = re.compile('(?<=[A-Za-z])[\u2019\ufffd](?=s\\b)')

# a one-line grid's name line with a count in front of it (MH4's "1 White
# Tiger", "2 Panthers", "2 Minions"): the name is the rest
COUNTED_NAME = re.compile(r'^(\d+) ([A-Z].*)$')
# a Special: value printed on a one-line grid's Health line (MH4's "Health: 60
# Special: Claws"): the Health is the number before it
HEALTH_SPECIAL = re.compile(r'^(Health\s*:\s*\d[\d,]*)\s+(Special\s*:\s*(.*?))\s*$')


def section_line(book):
    """booklet.SECTION_LINE for the labels this book prints (registry
    `section_labels`): Powers, Talents and Background in MH1-3, and MH4's
    Important People and Equipment too. Special is a one-line grid's line
    (MH1), read in opponents(), never a card's section."""
    labels = [l for l in book.get('section_labels') or ['Powers', 'Talents', 'Background'] if l != 'Special']
    return re.compile(r'^(%s)\s*[:.;]\s*(.*)$' % '|'.join(re.escape(l) for l in labels))


def bare_name(name):
    """A checklist or registry name less the count the page prints before it
    ("2 Panthers" is the Panthers)."""
    m = COUNTED_NAME.match(name)
    return m.group(2) if m else name


def left_x(line):
    return min(w['x'] for w in line['words'])


def letter_row(text):
    """The row of letters over a one-line grid: seven short marks, F A . E R
    . P (Tesseract reads S as "iS)" or "Ss" and I as "|" or "Jt")."""
    t = text.split()
    return len(t) == 7 and all(len(x) <= 3 for x in t) and (t[0], t[1], t[3], t[4], t[6]) == ('F', 'A', 'E', 'R', 'P')


def letter_xs(line, fused):
    """The seven x centres of a letter row's letters, or None. With `fused`
    (an opponent_names "title" book), two letters Tesseract read as one word
    are split by the word's width (MH2's Champion, printed 11: "F A S E RI P")."""
    if letter_row(line['text']):
        return [w['x'] + w['w'] / 2 for w in sorted(line['words'], key=lambda w: w['x'])]
    if not fused:
        return None
    words = sorted(line['words'], key=lambda w: w['x'])
    out, want = [], 'FASERIP'
    for w in words:
        t = re.sub(r'[^A-Za-z]', '', w['t'])
        if len(t) == 2 and t.upper() == want[len(out):len(out) + 2]:
            out += [w['x'] + w['w'] / 4, w['x'] + 3 * w['w'] / 4]
        elif len(w['t']) <= 3:
            out.append(w['x'] + w['w'] / 2)
        else:
            return None
    toks = [re.sub(r'[^A-Za-z]', '', w['t']) for w in words]
    # the fused pair may be the last two letters (MH5's Humanoids, printed
    # 12: "F A S E R IP")
    ok = len(out) == 7 and toks[:2] == ['F', 'A'] and toks[-1] in ('P', 'IP') and len(words) == 6
    return out if ok else None


def heading(line):
    """A chapter's sub-heading on a line of its own, set taller than the text
    ("Room 6" under the Omegatrons' grid, MH2 printed 11): three words at
    most, no closing punctuation."""
    t = line['text'].strip()
    return len(t.split()) <= 3 and t[:1].isupper() and not t.endswith(('.', ',', ':', ';', ')', '!', '?')) \
        and not t.startswith('Powers') and line['h'] >= 1.1 * line['body_h']


def power_named(text, intro):
    """A run-in head ("BODY ARMOR. The aliens' ...") whose name is on the
    grid's Powers: line, or None."""
    pm = booklet.POWER_HEAD.match(text)
    if pm and intro and roster.norm(pm.group(1)) in roster.norm(intro):
        return pm
    return None


def offsets(book):
    """The parts with a panel's offset filled in: a panel is read as page 1 of
    itself, and its lines lose that page again in stream()."""
    return dict(book, parts=[dict(p, offset=p['pdf'][0] - 1) if p['offset'] is None else p for p in book['parts']])


def stream(book, slug, part, first, last, split_at_rules):
    """booklet.stream_of's lines, without its fused-run mending, with each
    header set on two lines joined into one, and with the registry's
    drop_above applied. A panel's lines carry printed None."""
    panel = next(p for p in book['parts'] if p['name'] == part)['offset'] is None
    orig, orig_rules = booklet.mend_fused, booklet.rules
    # a rule booklet.rules() cannot see (printed 15's is dashed: no dark run
    # crosses 60% of the page), from the registry's `faint_rules`, read off the
    # page image; without it Mentallo's second column is read after the
    # Crimson Dynamo's card, and lands on it
    faint = {}
    for p, page, y in book.get('faint_rules', []):
        faint.setdefault(booklet.pdf_of(offsets(book), p, page), []).append(y)
    booklet.mend_fused = lambda _book, _slug, lines: lines
    booklet.rules = lambda b, pdf, height: sorted(orig_rules(b, pdf, height) + faint.get(pdf, []))
    try:
        lines = booklet.stream_of(offsets(book), slug, part, first, last, split_at_rules)
    finally:
        booklet.mend_fused, booklet.rules = orig, orig_rules
    if panel and book.get('panel_foot'):
        lines = foot_lines(book, slug, part, lines)
    if panel and book.get('panel_head'):
        lines = head_lines(book, slug, part, lines)
    cuts = {(p, page): y for p, page, y in book.get('drop_above', [])}
    # a box in a page's corner that is not a card's text (registry
    # `drop_corner`, [part, printed page, x, y]: every word right of x and
    # below y): MH2's PROOF OF PURCHASE coupon, read onto the last line of the
    # Super-Skrull's card
    corners = {(p, page): (x, y) for p, page, x, y in book.get('drop_corner', [])}
    out, seen, hit = [], set(), set()
    for l in lines:
        if panel:
            l['printed'] = None
        if l['y1'] <= cuts.get((part, l['printed']), -1):
            continue
        corner = corners.get((part, l['printed']))
        if corner:
            seen.add(l['printed'])
            gone = [w for w in l['words'] if w['x'] >= corner[0] and w['y'] >= corner[1]]
            if gone:
                hit.add(l['printed'])
            if gone and len(gone) == len(l['words']):
                continue
            if gone:
                text = l['text'].rstrip()
                for w in sorted(gone, key=lambda w: -w['x']):
                    if not text.endswith(w['t']):
                        raise SystemExit('%s: drop_corner: %r is not at the end of %r, %s p.%s' % (slug, w['t'], l['text'], part, l['printed']))
                    text = text[:-len(w['t'])].rstrip()
                l = dict(l, text=text, words=[w for w in l['words'] if w not in gone])
        prev = out[-1] if out else None
        # a name with no trademark sign yet goes on ("LOCKHEED" / "RS-150" /
        # "BLACKBIRD(tm)"): the next line, in capitals set as tall, is its rest
        if prev and booklet.is_header(prev) and not booklet.TRADEMARK.search(prev['text']) \
                and roster.is_caps(l['text']) and l['h'] >= 1.1 * l['body_h'] \
                and (prev['pdf'], prev['band'], prev['col']) == (l['pdf'], l['band'], l['col']) and l['y0'] - prev['y1'] < prev['h']:
            out[-1] = dict(prev, text=prev['text'] + ' ' + l['text'], y1=l['y1'])
            continue
        out.append(l)
    if seen - hit:
        # the corner's coordinates no longer find the box: a re-OCR moved it
        raise SystemExit('%s: drop_corner removes nothing on %s p.%s' % (slug, part, sorted(seen - hit)))
    return mend(book, slug, part, first, last, out)


def foot_lines(book, slug, part, lines):
    """A panel's lines below the foot booklet.stream_of keeps (registry
    `panel_foot`): a page with a folio ends its text above 95.5% of its
    height, and a panel prints no folio, so its columns run lower (MH4's
    inside front cover: "Incredible temporarily." at 96.4%). Each such line
    goes on after the last line of its column, read as stream_of reads one.
    MH1-3's panels hold no word there (measured on the TSV 2026-10-23)."""
    pdf = next(p for p in book['parts'] if p['name'] == part)['pdf'][0]
    words, (W, H) = roster.read_words(os.path.join(roster.CACHE, 'books', slug, 'tsv', 'p%03d.tsv' % pdf))
    body = [w for w in words if 0.03 * H < w['y'] and w['y'] + w['h'] < 0.955 * H]
    foot = [w for w in words if w['y'] + w['h'] >= 0.955 * H]
    if not body or not foot:
        return lines
    body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
    edges = [0] + roster.gutters(body, W, 3) + [W]
    out = list(lines)
    for c in range(3):
        col = [w for w in foot if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
        for l in roster.lines_of(col):
            if sum(ch.isalnum() for ch in l['text']) < 3 or l['conf'] < 45:
                continue
            at = [n for n, x in enumerate(out) if x['pdf'] == pdf and x['col'] == c + 1]
            if not at:
                continue
            last = out[at[-1]]
            l.update(pdf=pdf, printed=last['printed'], part=part, band=last['band'], col=c + 1, body_h=body_h,
                     col_x0=edges[c], col_x1=edges[c + 1],
                     words=[w for w in col if l['y0'] <= w['y'] + w['h'] / 2 <= l['y1']])
            out.insert(at[-1] + 1, l)
    return out


def head_lines(book, slug, part, lines):
    """A panel's lines above the head booklet.stream_of keeps (registry
    `panel_head`): a page with a running head starts its text below 3% of its
    height, and a panel prints none, so a header at the top of a column can
    sit above it (MH5's six: SHAMAN, SNOWBIRD and SASQUATCH on the inside
    front cover, PUCK, HEATHER and AURORA on the inside back, each at y 50-56
    of 3197). Each such line goes before the first line of its column, read
    as stream_of reads one, so it is a header over its card."""
    pdf = next(p for p in book['parts'] if p['name'] == part)['pdf'][0]
    words, (W, H) = roster.read_words(os.path.join(roster.CACHE, 'books', slug, 'tsv', 'p%03d.tsv' % pdf))
    body = [w for w in words if 0.03 * H < w['y'] and w['y'] + w['h'] < 0.955 * H]
    head = [w for w in words if w['y'] <= 0.03 * H]
    if not body or not head:
        return lines
    body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
    edges = [0] + roster.gutters(body, W, 3) + [W]
    out = list(lines)
    for c in range(3):
        col = [w for w in head if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
        for l in reversed(roster.lines_of(col)):
            if sum(ch.isalnum() for ch in l['text']) < 3 or l['conf'] < 45:
                continue
            at = [n for n, x in enumerate(out) if x['pdf'] == pdf and x['col'] == c + 1]
            if not at:
                continue
            first = out[at[0]]
            l.update(pdf=pdf, printed=first['printed'], part=part, band=first['band'], col=c + 1, body_h=body_h,
                     col_x0=edges[c], col_x1=edges[c + 1],
                     words=[w for w in col if l['y0'] <= w['y'] + w['h'] / 2 <= l['y1']])
            out.insert(at[0], l)
    return out


def mend(book, slug, part, first, last, out):
    """The registry's line fixes, each read off the page image, and each an
    error if it no longer finds its line (a re-OCR moved it):
      drop_lines   [part, page, text]: a line that is no card's (MH3: the
                   "In Loving Memory" banner over Doom's card, art at the top
                   of the inside front cover read as letters)
      lost_headers [part, page, identity, name]: a card whose header no word
                   of the TSV holds (MH3's Human Torch), placed above the
                   line that is its identity
      moves        [part, page, col, y from, y to, after col, after y]: the
                   lines of that column between those heights go on after the
                   last line of the other column ending above that height (a
                   card set round its portrait: the Super-Adaptoid's text goes
                   on at the top of printed 15's third column)
      speck_lines  [part, page, as read, as printed]: a line that carries a
                   speck of the scan read as a mark (MH5's Raider Armor,
                   printed 14: "Remarkable speed. -", a 2 x 3 px dot after
                   the sentence's end, which held the sentence open so the
                   next run-in, BODY ARMOR., was read as its text)
      split_headers [part, page, as read, NAME]: a header Tesseract read as
                   two words (MH4's TASKMASTER, "TASKMASTE" and "R" with the
                   trademark sign 7 px apart), matched once by its cleaned
                   text and joined, the sign kept
    Pages are printed pages, or null on a panel."""
    here = lambda p: p[0] == part and (p[1] is None or first <= p[1] <= last)
    for p, page, old, new in [d for d in book.get('split_headers', []) if here(d)]:
        hits = [n for n, l in enumerate(out) if l['printed'] == page and booklet.clean_name(l['text']) == old]
        if len(hits) != 1:
            raise SystemExit('%s: split_headers finds %r %d times on %s p.%s, not once' % (slug, old, len(hits), part, page))
        sign = re.search('[' + booklet.TM + ']*$', out[hits[0]]['text'].rstrip()).group(0)
        out[hits[0]] = dict(out[hits[0]], text=new + sign)
    for p, page, old, new in [d for d in book.get('speck_lines', []) if here(d)]:
        hits = [n for n, l in enumerate(out) if l['printed'] == page and l['text'].strip() == old]
        if len(hits) != 1:
            raise SystemExit('%s: speck_lines finds %r %d times on %s p.%s, not once' % (slug, old, len(hits), part, page))
        out[hits[0]] = dict(out[hits[0]], text=new)
    for p, page, text in [d for d in book.get('drop_lines', []) if here(d)]:
        hits = [l for l in out if l['printed'] == page and l['text'].strip() == text]
        if len(hits) != 1:
            raise SystemExit('%s: drop_lines finds %r %d times on %s p.%s, not once' % (slug, text, len(hits), part, page))
        out.remove(hits[0])
    for p, page, identity, name in [d for d in book.get('lost_headers', []) if here(d)]:
        hits = [n for n, l in enumerate(out) if l['printed'] == page and l['text'].strip() == identity]
        if len(hits) != 1:
            raise SystemExit('%s: lost_headers finds %r %d times on %s p.%s, not once' % (slug, identity, len(hits), part, page))
        out.insert(hits[0], dict(out[hits[0]], text=name, lost_header=True))
    for p, page, col, y0, y1, after_col, after_y in [d for d in book.get('moves', []) if here(d)]:
        moved = [l for l in out if l['printed'] == page and l['col'] == col and y0 <= l['y0'] <= y1]
        rest = [l for l in out if l not in moved]
        at = [n for n, l in enumerate(rest) if l['printed'] == page and l['col'] == after_col and l['y1'] <= after_y]
        if not moved or not at:
            raise SystemExit('%s: moves finds %d lines and %d to follow on %s p.%s' % (slug, len(moved), len(at), part, page))
        out = rest[:at[-1] + 1] + moved + rest[at[-1] + 1:]
    return out


def raw_value(stream_lines, label):
    """A secondary value as printed where booklet.value() reads none: a dash
    (the Sentinels' Karma) or a parenthesis (Crimson Dynamo's Resources)."""
    for s in stream_lines:
        m = booklet.STAT_LINE.match(s['text'])
        if m and m.group(1).startswith(label[:8]):
            v = m.group(2).strip()
            if DASH.match(v.replace(' ', '')):
                return '-'
            if v.startswith('('):
                return v if v.endswith(')') else v + ')'
    return None


def wrapped_alternates(block, block_lines, ranks):
    """A bracketed rank set on the line under its row ("Strength: EXCELLENT" /
    "[MONSTROUS]", Colossus's and Crimson Dynamo's) is that row's alternate.
    full_grid reads rows from a crop whose lines wrap the same way, so it
    reads the row and not the bracket."""
    for prev, l in zip(block_lines, block_lines[1:]):
        w = re.match(r'^\[\s*([A-Z]+)\s*\]$', l['text'].strip())
        m = booklet.STAT_LINE.match(prev['text'])
        if not (w and m and m.group(1) in booklet.ABILITY_LABELS):
            continue
        a = block['abilities'][booklet.ABILITY_LABELS.index(m.group(1))]
        hit = ranks.get(w.group(1))
        if hit and 'alt' not in a:
            a['alt'] = {'number': hit[1], 'code': hit[0]}


def second_reason(block, block_lines, header, slug):
    """A block that prints Reason: a second time, after Karma, where
    Resources: belongs (registry `second_reason`: MH5's Northstar, printed 16,
    "Reason: EXCELLENT" between Karma and Popularity). That value is its
    Resources, and the block keeps the label as printed (`printed_labels`)."""
    seen = [n for n, l in enumerate(block_lines) if (booklet.STAT_LINE.match(l['text']) or [None, ''])[1] == 'Reason']
    karma = [n for n, l in enumerate(block_lines) if (booklet.STAT_LINE.match(l['text']) or [None, ''])[1] == 'Karma']
    if len(seen) != 2 or not karma or not seen[0] < karma[0] < seen[1] or block['resources'] is not None:
        raise SystemExit('%s: second_reason finds no Reason: after Karma: in %s' % (slug, header))
    block['resources'] = booklet.value(booklet.STAT_LINE.match(block_lines[seen[1]]['text']).group(2))
    block['printed_labels'] = {'resources': 'Reason'}


def round_alternates(block, block_lines, ranks):
    """A rank set's alternate in round brackets (registry `round_alternates`:
    MH5's Sasquatch, whose bracketed ranks are his bestial form): on the line
    under its row ("Strength: GOOD" / "(MONSTROUS)"), or opened after the rank
    and wrapped mid-word onto the next line ("Agility: GOOD (REMARK-" /
    "ABLE)"). full_grid reads the first as nothing and the second as a note
    ("REMARK-"); each is the row's alternate, and the note goes."""
    for prev, l in zip(block_lines, block_lines[1:]):
        m = booklet.STAT_LINE.match(prev['text'])
        if not (m and m.group(1) in booklet.ABILITY_LABELS):
            continue
        a = block['abilities'][booklet.ABILITY_LABELS.index(m.group(1))]
        under = re.match(r'^\(\s*([A-Z]+)\s*\)$', l['text'].strip())
        wrap = re.match(r'^[A-Z]+\s*\(\s*([A-Z]+)-$', m.group(2).strip())
        tail = re.match(r'^([A-Z]+)\)$', l['text'].strip())
        word = under.group(1) if under else wrap.group(1) + tail.group(1) if wrap and tail else None
        hit = ranks.get(word) if word else None
        if hit and 'alt' not in a:
            a['alt'] = {'number': hit[1], 'code': hit[0]}
            a.pop('note', None)


def marked_ranks(block, ranks):
    """A rank word read with a mark of the portrait in front of it ("Strength:
    <U+FFFD> AMAZING", MH2's Super-Skrull and Vision): booklet.parse_rank
    drops '|' and '_' but not that mark, so the row reads as unread. The
    word after the mark is the rank, as the page images show."""
    for a in block['abilities']:
        pc = a.get('printed_code') or ''
        bare = re.sub(r'^[^A-Za-z\[(]+', '', pc)
        if a['number'] is not None or bare == pc or not bare:
            continue
        base, alt, note = booklet.parse_rank(bare, ranks)
        if base:
            a['number'], a['code'] = base[1], base[0]
            if alt and 'alt' not in a:
                a['alt'] = {'number': alt[1], 'code': alt[0]}


def printed_value(v, ranks):
    """A Resources or Popularity the book prints: a number, a rank, none or
    varies (or a note in brackets, Crimson Dynamo's)."""
    t = (v or '').strip()
    return bool(t) and (booklet.first_int(t) is not None or t.startswith('(') or t == '-'
                        or booklet.parse_rank(t, ranks)[0] is not None
                        or re.match(r'^(none|varies)\b', t, re.I) is not None)


def crop_dashes(block, lines, i, j, ranks, reader):
    """A dash printed for Resources or Popularity that neither the TSV nor the
    crop's value reading kept (MH3's Skrull Soldiers, printed 15: the TSV
    reads nothing after either label, and the crop's "ae" is taken as a word).
    The block's crop is re-read with full_grid's own box (the same cached
    text), and where it reads a dash after the label and the value held is
    nothing the book prints, the value is that dash."""
    line = lines[i]
    right = min(line['col_x1'], max(s['x1'] for s in lines[i:j]) + 60)
    crop = booklet.stat_rows(reader.read(line['pdf'], (line['col_x0'], line['y0'] - 15, right, lines[j - 1]['y1'] + 45)))
    for label in ('Resources', 'Popularity'):
        key = label.lower()
        v = (crop.get(label) or '').replace(' ', '')
        if not printed_value(block[key], ranks) and v and DASH.match(v):
            block[key] = '-'


def check_alt_karma(block, res):
    """booklet.block_check holds a bracketed Health to the bracketed ranks;
    a bracketed Karma is held to them the same way (MH3's Skrull Soldiers'
    "22 [32]", the technicians' Reason). Only where a bracket is printed, so a
    block with none keeps block_check's result as it was."""
    k2 = booklet.second_int(block.get('karma'))
    alts = [(a.get('alt') or a)['number'] for a in block['abilities']]
    if k2 is None or None in alts[4:]:
        return res
    res['alt_karma'] = sum(alts[4:]) == k2
    res['ok'] = res['ok'] and res['alt_karma']
    return res


def lost_line(prev, line, reader):
    """A line Tesseract lost between prev and line, two lines of one column,
    or None. Only a gap wider than 0.8 of a body line is looked at, and it is
    re-read as one line (--psm 7) from the column's left edge for 305 px: a
    lost line here is a sentence's last word or two (MH3's Wizard, printed 14:
    "speed.", read in the TSV as two marks), and a wider box takes in the art
    beside it and the line above. What it reads must be lower-case words that
    end a sentence, or it is not a line."""
    if (prev['pdf'], prev['col']) != (line['pdf'], line['col']) or line['y0'] - prev['y1'] <= 0.8 * line['body_h']:
        return None
    x0 = min(prev['x0'], line['x0']) - 11
    got = reader.read(line['pdf'], (x0, prev['y1'] - 2, x0 + 305, line['y0'] + 3), psm='7')
    t = ' '.join(got).strip()
    return t if re.match(r"^[a-z][a-z'-]*(?: [a-z][a-z'-]*){0,3}[.!?]$", t) else None


def cards(book, slug, part, first, last, ranks, reader):
    """The entries of one card range: a header, its block, its text."""
    lines = stream(book, slug, part, first, last, split_at_rules=True)
    grids = [g for g in book['card_grids'] if g['part'] == part and (g['page'] is None or first <= g['page'] <= last)] \
        if 'card_grids' in book else None
    return read_cards(book, slug, part, lines, grids, ranks, reader)


def gear_text(lines):
    """An Equipment run-in's lines joined as roster.join_text joins them,
    except where the run-in prints a list: an intro ending in a colon, then
    one item a line (GEAR_ITEM). Each item, and the prose after the last, then
    starts a line of its own. A line that is no item and opens in lower case
    or a digit is the item above it wrapping ("damage 25"); the first that
    opens in capitals ends the list."""
    lines = [t for t in lines if t.strip()]
    if len(lines) < 2 or not lines[0].rstrip().endswith(':') or not GEAR_ITEM.match(lines[1]):
        return roster.join_text(lines)
    groups, listing = [[lines[0]]], True
    for t in lines[1:]:
        if listing and GEAR_ITEM.match(t):
            groups.append([t])
        elif listing and not t.strip()[:1].isupper():
            groups[-1].append(t)
        elif listing:
            groups.append([t])
            listing = False
        else:
            groups[-1].append(t)
    return '\n'.join(roster.join_text(g) for g in groups)


def prose_card(book, slug, part, page, name, ranks, reader, spec=None):
    """A full block set inside a chapter's prose (registry `prose_cards`:
    MH4's Kingpin, printed 5, Chapter 2's Campaign). Its header is its name
    in title case on a line of its own, which booklet.is_header does not
    take, so the registry names it; the line must sit over a Fighting: row.
    The card is read as a panel's are, from that line to the line that ends
    it: the next header (the BATTLE banner) or a one-line grid's letter row,
    through a column break (the Kingpin's powers go on at the top of the
    second column).

    MH5's Kimara (printed 10, Chapter 5 Battle 2) is set otherwise, and the
    prose_cards entry says how (`spec`):
      header_lines 2   the name is two lines in capitals ("KIMARA," / "THE
                       CLOUDSTALKER(tm)"), matched joined to the registry name
      colonless        its rank rows print no colon ("Fighting MONSTROUS"),
                       read as if they did
      no_powers_line   it prints no Powers: line: the colon run-ins after the
                       block (BODY ARMOR:, REGENERATION:) are its powers, and
                       the card ends at the first indented line, where the
                       chapter's prose resumes"""
    spec = spec or {}
    lines = stream(book, slug, part, page, page, split_at_rules=False)
    span = spec.get('header_lines', 1)
    if spec.get('colonless'):
        rows = re.compile(r'^(%s) +([A-Z]{4,})$' % '|'.join(booklet.ABILITY_LABELS))
        lines = [dict(l, text=rows.sub(r'\1: \2', l['text'].strip())) for l in lines]
    if span == 1:
        at = [n for n, l in enumerate(lines) if l['text'].strip() == name
              and any(re.match(r'^\W{0,2}Fighting\s*[:;.]', x['text']) for x in lines[n + 1:n + 4])]
    else:
        at = [n for n in range(len(lines) - span) if all(roster.is_caps(l['text']) for l in lines[n:n + span])
              and roster.norm(booklet.clean_name(' '.join(l['text'].strip() for l in lines[n:n + span]))) == roster.norm(name)
              and any(re.match(r'^\W{0,2}Fighting\s*[:;.]', x['text']) for x in lines[n + span:n + span + 3])]
    if len(at) != 1:
        raise SystemExit('%s: prose_cards finds %r over a block %d times on %s p.%s, not once' % (slug, name, len(at), part, page))
    i = at[0]
    head = dict(lines[i], named_header=True)
    if span > 1:
        head = dict(head, text=name, y1=lines[i + span - 1]['y1'])
    end = next((n for n in range(i + 3 + span, len(lines)) if booklet.is_header(lines[n]) or letter_xs(lines[n], True) is not None),
               len(lines))
    if spec.get('no_powers_line'):
        # the block's rows sit at its left edge; the first line set in from it
        # after the block opens the chapter's next paragraph
        base = left_x(lines[i + span])
        k = next(n for n in range(i + span, end) if re.match(r'^(Karma|Health)\s*:', lines[n]['text']))
        end = next((n for n in range(k + 1, end) if left_x(lines[n]) > base + 20), end)
    entries = read_cards(book, slug, part, [head] + lines[i + span:end], None, ranks, reader,
                         runin_powers=bool(spec.get('no_powers_line')))
    for e in entries if spec.get('no_powers_line') else []:
        # the card prints no Powers: line, so no Powers section
        if e['sections'].get('powers') == []:
            del e['sections']['powers']
    return entries


def read_cards(book, slug, part, lines, grids, ranks, reader, runin_powers=False):
    """The entries in a run of card lines: a header, its block, its text.
    `grids` is the registry's card_grids for the run, or None. With
    `runin_powers` (a prose card that prints no Powers: line, MH5's Kimara)
    the lines after the block are read as under Powers:."""
    entries, cur = [], None
    title = book.get('opponent_names') == 'title'
    section = section_line(book)
    i = 0
    sets = [s for s in book.get('power_form_sets', []) if s['part'] == part]
    cuts = [c for c in book.get('cut_grids', []) if c['part'] == part and any(l['printed'] == c['page'] for l in lines)]
    inner = {(roster.norm(s['entry']), roster.norm(s['power'])): {roster.norm(h) for h in s['heads']}
             for s in book.get('inner_runins', [])}
    while i < len(lines):
        line = lines[i]
        text = line['text'].strip()
        spec = [s for s in sets if cur and cur['_sec'] == 'powers' and cur['powers'] and text == s['intro']
                and roster.norm(s['entry']) == roster.norm(cur['header'])]
        if spec:
            # a power's list of forms, each a name over four rank rows, F A S
            # and E (registry `power_form_sets`: MH5's Snowbird, EXAMPLES: /
            # WHITE OWL (Wings,Claws) / Fighting: EXCELLENT ...): the power's
            # text, a line each as printed, and never a block
            got, k = [text], i + 1
            while k + 4 < len(lines) and re.match(r'^[A-Z][A-Z ]+\(', lines[k]['text'].strip()) \
                    and all((booklet.STAT_LINE.match(lines[k + n]['text']) or [None, ''])[1] == booklet.ABILITY_LABELS[n - 1]
                            for n in range(1, 5)):
                got += [lines[k + n]['text'].strip() for n in range(5)]
                k += 5
            if len(got) != 1 + 5 * spec[0]['sets']:
                raise SystemExit('%s: power_form_sets reads %d sets under %s in %s, not %d'
                                 % (slug, (len(got) - 1) // 5, text, cur['header'], spec[0]['sets']))
            mine = cur['powers'][-1]
            mine['text'] = ['\n'.join([roster.join_text(mine['text'])] + got)]
            sets.remove(spec[0])
            if k < len(lines):
                lines = lines[:k] + [dict(lines[k], after_sets=True)] + lines[k + 1:]
            i = k
            continue
        block, nxt = booklet.full_grid(lines, i, ranks, reader)
        if block and book.get('round_alternates'):
            round_alternates(block, lines[i:nxt + 1], ranks)
        if block:
            if cur is None:
                raise SystemExit('%s: a block with no header above it, %s PDF %d' % (slug, part, line['pdf']))
            for k in roster.LABELS:
                if block[k.lower()] is None:
                    block[k.lower()] = raw_value(lines[i:nxt], k)
            if roster.norm(cur['header']) in {roster.norm(n) for n in book.get('second_reason', [])}:
                second_reason(block, lines[i:nxt], cur['header'], slug)
            crop_dashes(block, lines, i, nxt, ranks, reader)
            wrapped_alternates(block, lines[i:nxt], ranks)
            marked_ranks(block, ranks)
            block['check'] = check_alt_karma(block, booklet.block_check(block))
            # a Resources or Popularity line the block prints whose value is
            # still nothing the book prints fails the block (the Skrull
            # Soldiers' "ae" read for a dash, before crop_dashes)
            unprinted = [k for k in ('Resources', 'Popularity') if not printed_value(block[k.lower()], ranks)
                         and any((booklet.STAT_LINE.match(s['text']) or [None, ''])[1].startswith(k[:8]) for s in lines[i:nxt])]
            if unprinted:
                block['check'].update(unprinted=unprinted, ok=False)
            cur['blocks'].append(block)
            cur['_sec'] = 'after-grid'
            if runin_powers:
                cur['_sec'] = 'powers'
                cur['sections'].setdefault('powers', [])
            i = nxt
            continue
        cut = [c for c in cuts if cur and roster.norm(c['entry']) == roster.norm(cur['header']) and c['page'] == line['printed']]
        if cut and letter_xs(line, title) is not None:
            # a one-line grid inside a card that is an entry of its own
            # (registry `cut_grids`: MH5's Humanoids, in the Leader's
            # HUMANOIDS. power): opponents() reads it, through `unnamed_grids`,
            # with the paragraph under it, and the card skips all of that to
            # its next run-in or section
            k = i + 2
            while k < len(lines) and booklet.STAT_LINE.match(lines[k]['text']):
                k += 1
            while k < len(lines) and not (booklet.POWER_HEAD.match(lines[k]['text']) or section.match(lines[k]['text'])):
                k += 1
            cuts.remove(cut[0])
            i = k
            continue
        if grids is not None and letter_xs(line, title) is not None:
            # a one-line grid inside a card (registry `card_grids`): She-Hulk's
            # ALTER EGO. power ends on Jennifer Walters' grid
            spec = [g for g in grids if cur and roster.norm(g['entry']) == roster.norm(cur['header'])
                    and g['page'] == line['printed']]
            if len(spec) != 1:
                raise SystemExit('%s: a one-line grid in a card that card_grids does not name, %s PDF %d'
                                 % (slug, part, line['pdf']))
            block, nxt = line_block(lines, i, title, ranks, part, line['printed'], slug, cur['header'])
            block['label'] = spec[0]['label']
            cur['blocks'].append(block)
            grids.remove(spec[0])
            i = nxt
            continue
        if booklet.is_header(line) or line.get('lost_header') or line.get('named_header'):
            cur = {'kind': 'entry', 'header': re.sub(r'(?<=[A-Z])- (?=[A-Z])', '-', booklet.clean_name(text)), 'part': part,
                   'pages': [line['printed']] if line['printed'] else [], 'identity': [], 'blocks': [],
                   'sections': {}, 'powers': [], 'members': [], 'prose': [], '_sec': None}
            entries.append(cur)
            i += 1
            continue
        if cur is None:
            i += 1
            continue
        if line['printed'] and line['printed'] not in cur['pages']:
            cur['pages'].append(line['printed'])
        m = section.match(text)
        if m:
            key = m.group(1).lower().replace(' ', '_')
            cur['_sec'] = key
            cur['sections'].setdefault(key, [])
            if m.group(2):
                cur['sections'][key].append(m.group(2))
            i += 1
            continue
        sec = cur['_sec']
        if sec is None and not cur['blocks'] and len(cur['identity']) < 2:
            sink = cur['identity']
        elif sec in ('powers', 'equipment'):
            # the run-ins under Powers:, and under MH4's Equipment: (the
            # Punisher's GUNS., GRENADES., KNIFE. and VAN.), which are read
            # the same way and carry their section
            mine = [p for p in cur['powers'] if (p.get('section') or 'powers') == sec]
            pm = booklet.POWER_HEAD.match(text) or COLON_HEAD.match(text) or WHOLE_HEAD.match(text) or MIXED_HEAD.match(text)
            # a run-in inside a power's text, no power of its own (registry
            # `inner_runins`: MH5's Melter, whose MELTING DEVICE. prints its
            # four settings as METAL:, STONE:, WOOD: and FLESH:)
            if pm and mine and roster.norm(pm.group(1)) in inner.get((roster.norm(cur['header']), roster.norm(mine[-1]['name'])), ()):
                pm = None
            prev = lines[i - 1]['text'].rstrip() if i else ''
            if pm and mine and not prev.endswith(SENTENCE_END):
                # a line between the last power's text and this head that
                # Tesseract lost (MH3's Wizard: "speed." read as two marks)
                lost = lost_line(lines[i - 1], line, reader)
                if lost:
                    mine[-1]['text'].append(lost)
                    prev = lost
            # a name in capitals inside the Powers: prose ("... such as
            # ANNIHILUS and / NICHOLAS SCRATCH. These powers", MH3's Franklin
            # Richards) is no power: a first power opens the section or a line
            if pm and (not mine and not cur['sections'][sec] or prev.endswith(SENTENCE_END) or line.get('after_sets')):
                power = {'name': booklet.power_name(pm.group(1)), 'text': []}
                if sec != 'powers':
                    power['section'] = sec
                cur['powers'].append(power)
                mine.append(power)
                text = pm.group(2)
            sink = mine[-1]['text'] if mine else cur['sections'][sec]
        elif sec in cur['sections']:
            sink = cur['sections'][sec]
        else:
            sink = cur['prose']
        sink.append(text)
        i += 1
    if sets:
        raise SystemExit('%s: power_form_sets names %s on %s, found in no power'
                         % (slug, ', '.join(s['entry'] for s in sets), part))
    if cuts:
        raise SystemExit('%s: cut_grids names %s on %s, found in no card'
                         % (slug, ', '.join(c['name'] for c in cuts), part))
    if grids:
        # card_grids names a grid no letter row in that card was read as
        raise SystemExit('%s: card_grids names %s on %s that no one-line grid in the card matched'
                         % (slug, ', '.join('%s (%s)' % (g['entry'], g['label']) for g in grids), part))
    for e in entries:
        for b in e['blocks']:
            b['part'] = part
    return entries


def line_block(lines, i, title, ranks, part, page, slug, name, notes=False):
    """A one-line grid's block, from its letter row at lines[i]: each code is
    the word under its letter, by x, and the stat lines after the codes row
    are its Health and Karma. Returns (block, index after the stat lines).
    Read the same way for an opponent's grid and for one inside a card
    (registry `card_grids`). With `notes`, also returns the lines of a
    bracketed note a stat line opens, as a third value."""
    line = lines[i]
    short = {v[0].upper(): v for v in ranks.values()}
    xs = letter_xs(line, title)
    if xs is None or len(xs) != 7:
        raise SystemExit('%s: %s p.%s: %d letters in the grid row, not 7' % (slug, name, page, len(line['words'])))
    codes = {}
    for w in lines[i + 1]['words']:
        n = min(range(7), key=lambda k: abs(w['x'] + w['w'] / 2 - xs[k]))
        codes.setdefault(n, []).append(w['t'])
    abilities = []
    for n in range(7):
        t = ''.join(codes.get(n, []))
        word = re.sub(r'[^A-Za-z]', '', t)
        # a code that carries a digit, where the registry spells it so (MH5's
        # C1, Class 1000, on Kimara's powered grid): read with the digit
        alnum = re.sub(r'[^A-Za-z0-9]', '', t)
        if alnum != word and alnum.upper() in ranks:
            word = alnum
        if not word and t and DASH.match(t):
            abilities.append({'letter': roster.ABILITIES[n], 'number': None, 'code': None, 'printed_code': '-'})
            continue
        word = CODE_MISREADS.get(word.upper(), word)
        hit = ranks.get(word.upper()) or short.get(word.upper())
        abilities.append({'letter': roster.ABILITIES[n], 'number': hit[1] if hit else None,
                          'code': hit[0] if hit else None, 'printed_code': word or t})
    block = {'label': None, 'kind': 'line', 'page': page, 'part': part, 'pdf': line['pdf'], 'col': line['col'],
             'abilities': abilities, 'rank_only': True}
    k = i + 2
    stats, note = [], []
    # "Total Health: 1300" under a grid (MH5's Kimara, fully powered) is its
    # Health; no earlier book prints the words (MH1-4's caches, 2026-10-23)
    total = lambda t: re.sub(r'^Total\s+(?=Health\s*:)', '', t)
    while k < len(lines) and booklet.STAT_LINE.match(total(lines[k]['text'])):
        stats.append(total(lines[k]['text']))
        k += 1
        # a Special: value on the Health line (MH4's "Health: 60 Special:
        # Claws"): the Health is the number, and opponents() reads the Special
        hs = HEALTH_SPECIAL.match(stats[-1])
        if hs:
            stats[-1] = hs.group(1)
        # a stat line that opens a bracket and does not close it (registry
        # "opponent_powers": "run-in"; MH3's Super-Adaptoid, printed 9:
        # "Health: 150 (No matter what abilities the" over three more lines)
        # keeps its number, and the bracket to its close is a note for prose
        m = re.match(r'^(.*?\d)\s*(\(.*)$', stats[-1]) if notes else None
        if m and ')' not in m.group(2):
            stats[-1], note = m.group(1), [m.group(2)]
            while k < len(lines) and ')' not in note[-1]:
                note.append(lines[k]['text'])
                k += 1
    block.update(booklet.secondary(' '.join(stats)))
    block['check'] = check(block)
    if notes:
        return block, k, note
    return block, k


def opponents(book, slug, part, page, ranks):
    """The one-line grids on one chapter page, each an entry of its own."""
    lines = stream(book, slug, part, page, page, split_at_rules=False)
    # MH2 (registry "opponent_names": "title"): names in title case, a grid
    # with no name that is a form of a card (registry `form_grids`), run-in
    # powers after the Powers: line, and paragraphs that open indented
    title = book.get('opponent_names') == 'title'
    # MH3 (registry "opponent_powers": "run-in"): names in capitals, as MH1's,
    # and run-in powers after the Powers: line, read by RUNIN_POWER
    runin = book.get('opponent_powers') == 'run-in'
    forms = [f for f in book.get('form_grids', []) if (f['part'], f['page']) == (part, page)]
    # MH4 (registry `unnamed_grids`): a grid with no name line that is a
    # character of its own, named by what the prose calls it, in page order
    unnamed = [u for u in book.get('unnamed_grids', []) if (u['part'], u['page']) == (part, page)]
    is_row = lambda l: letter_xs(l, title) is not None
    # a title book's name line, with or without a count before it
    is_name = lambda l: TITLE_NAME.match(bare_name(APOSTROPHES.sub("'", l['text'].strip()))) is not None
    entries = []
    for i, line in enumerate(lines):
        if not is_row(line) or i + 1 >= len(lines):
            continue
        # the name: the nearest line above in capitals before a colon, or all
        # capitals; the lines between are its description ("GIANT: a large
        # humanoid ...", wrapped)
        head, form = None, None
        for j in range(i - 1, max(-1, i - 5), -1):
            if title:
                # a count before the name ("1 White Tiger", MH4) is not part of it
                m = TITLE_NAME.match(bare_name(APOSTROPHES.sub("'", lines[j]['text'].strip())))
                if m and j == i - 1 and lines[j]['col'] == line['col']:
                    head = (j, m.group(1), None)
                break
            m = re.match(r"^([A-Z][A-Z .'-]+[A-Z])(?::\s*(.*))?$", lines[j]['text'].strip())
            if m and lines[j]['col'] == line['col'] and (m.group(2) is not None or roster.is_caps(lines[j]['text'])):
                head = (j, m.group(1), m.group(2))
                break
        if head is None and forms:
            # the grid is the card's second block: the line above is prose
            # ("If he succeeds, his abilities and powers become:")
            form = forms.pop(0)
            head = (i, form['entry'], None)
        gap = 2
        if head is None and unnamed:
            # the grid follows its paragraph (MH4's "REGGIE." run-in, the
            # "3) CYBER-SERGEANTS QUARTERS." room): the registry names it
            u = unnamed.pop(0)
            head = (i, u['name'], None)
            # its text may open further under it than a grid's row gap
            # (`first_gap`, in body lines: MH5's Humanoids, printed 12)
            gap = u.get('first_gap', gap)
        if head is None:
            raise SystemExit('%s: a one-line grid with no name above it, %s p.%d' % (slug, part, page))
        j, name, desc = head
        note = []
        if runin:
            block, k, note = line_block(lines, i, title, ranks, part, page, slug, name, notes=True)
        else:
            block, k = line_block(lines, i, title, ranks, part, page, slug, name)
        # the text: the Powers: or Special: line and the paragraph it opens,
        # or the paragraph right under the grid; it ends at a paragraph break.
        # The first line may sit a grid's row gap under a grid with no Health
        # (Fluffy's, Augie Hickman's). A run-in head in capitals is the next
        # grid's name or the adventure's ("ROBOT MENTALLO:", "STORM and
        # ROGUE:"). A sentence left open at a column's foot goes on at the top
        # of the next column to the first indented line (the False Magneto's).
        pitch = statistics.median(b['y0'] - a['y0'] for a, b in zip(lines, lines[1:]) if 0 < b['y0'] - a['y0'] < 60)
        #
        # In a title book a run-in power named on the Powers: line goes on
        # after a paragraph break (MH2's Aliens, printed 5), an indented line
        # that is not one opens the adventure's next paragraph (Kang's
        # Minions, printed 13), and a paragraph goes on at the top of the next
        # column when that line is not indented (the Skrulls' laser pistols,
        # printed 7).
        text, last, first_k, carry = [], lines[k - 1], k, None
        base_x = left_x(line)
        intro = lambda: roster.join_text(text) if text and re.match(r'^Powers\s*:', text[0]) else ''
        # In a run-in book (MH3) a run-in after the Powers: line is the grid's
        # power, not the next name ("WEAPONS: Each tower", the Water Tower
        # Robots, printed 4), an indented line opens the adventure's next
        # paragraph, and a run-in at the top of the next column goes on
        # ("MOVEMENT: A tower moves", the same robots).
        while k < len(lines) and not is_row(lines[k]) and not (RUN_IN_HEAD.match(lines[k]['text']) and not (runin and intro())):
            l = lines[k]
            where = (l['pdf'], l['band'])
            named = title and power_named(l['text'], intro())
            # a run-in power after a gap (the Super-Adaptoid's BODY ARMOR.,
            # printed 9, a paragraph under its Powers: line) goes on
            named = named or (runin and intro() and text[-1].rstrip().endswith(SENTENCE_END) and RUNIN_POWER.match(l['text']))
            if title and heading(l):
                break
            if title and k + 1 < len(lines) and is_row(lines[k + 1]) and is_name(l):
                break                   # the next grid's name line (MH4's "2 Panthers" under the White Tiger's)
            if carry is None and l['col'] == line['col'] and where == (line['pdf'], line['band']):
                if l['y0'] - last['y0'] >= (gap if k == first_k else 1.3) * pitch and not named:
                    break
                if (title or runin) and k != first_k and left_x(l) > base_x + 20 and not named:
                    break
            elif carry is None and text and l['col'] == line['col'] + 1 and where == (line['pdf'], line['band']) \
                    and (not text[-1].rstrip().endswith(('.', '!', '?'))
                         or (runin and intro() and RUNIN_POWER.match(l['text']))
                         or (title and (named or (k + 1 < len(lines) and left_x(l) <= left_x(lines[k + 1]) + 10)))):
                carry = left_x(l)
            elif carry is not None and l['col'] == last['col'] and where == (last['pdf'], last['band']):
                if (left_x(l) > carry + 20 and not named) or l['y0'] - last['y0'] >= 1.3 * pitch:
                    break
            else:
                break
            text.append(l['text'])
            last = l
            k += 1
        powers = []
        if title and intro():
            # the run-ins after the Powers: line are the grid's powers, as a
            # card's are; the Powers: paragraph itself is its powers section
            head_lines = []
            for t in text:
                pm = power_named(t, roster.join_text(head_lines)) if head_lines else None
                if pm and (powers or head_lines[-1].rstrip().endswith('.')) and (not powers or powers[-1]['text'][-1].rstrip().endswith(('.', ')', '"'))):
                    powers.append({'name': booklet.power_name(pm.group(1)), 'text': [pm.group(2)]})
                elif powers:
                    powers[-1]['text'].append(t)
                else:
                    head_lines.append(t)
            text = head_lines
        elif runin and intro():
            # MH3's run-ins after the Powers: line: a head in capitals after a
            # sentence's end, ended by a colon or a period ("WEAPONS: Each
            # tower", "BODY ARMOR. Incredible"), or going on into its sentence
            # ("FLIGHT is at good speed.", the Doombot), whose whole line is
            # its text
            head_lines = []
            for t in text:
                pm = RUNIN_POWER.match(t) if head_lines else None
                prev = (powers[-1]['text'] if powers else head_lines)[-1].rstrip() if head_lines else ''
                if pm and prev.endswith(SENTENCE_END):
                    powers.append({'name': booklet.power_name(pm.group(1)), 'text': [pm.group(3) if pm.group(2) else t]})
                elif powers:
                    powers[-1]['text'].append(t)
                else:
                    head_lines.append(t)
            text = head_lines
        # a Special: value on the Health line ("Health: 60 Special: Claws",
        # MH4's cats and Flying Tigers) is the grid's one power, named as
        # printed (survey mh4.md decision 7); line_block kept the Health
        for x in range(i + 2, k):
            hs = HEALTH_SPECIAL.match(lines[x]['text'])
            if hs:
                powers.append({'name': hs.group(3).strip(), 'text': []})
        sections, prose = {}, [desc] if desc else []
        prose += note
        prose += [lines[x]['text'] for x in range(j + 1, i)]
        m = re.match(r'^(Powers|Special)\s*:\s*(.*)$', text[0]) if text else None
        if m:
            sections[m.group(1).lower()] = booklet.quotes(roster.join_text([m.group(2)] + text[1:]))
        else:
            prose += text
        if form:
            block['label'] = form['label']
        entries.append({'kind': 'form' if form else 'opponent', 'header': name, 'part': part, 'pages': [page],
                        'identity': [], 'blocks': [block], 'sections': sections, 'powers': powers, 'members': [],
                        'prose': prose, '_sec': None})
    if forms:
        raise SystemExit('%s: form_grids names %d grid(s) on %s p.%d that no unnamed grid matched' % (slug, len(forms), part, page))
    if unnamed:
        raise SystemExit('%s: unnamed_grids names %d grid(s) on %s p.%d that no unnamed grid matched' % (slug, len(unnamed), part, page))
    return entries


def check(block):
    """booklet.block_check, with a printed dash not counted as unread."""
    res = booklet.block_check(block)
    dashes = [roster.ABILITIES[n] for n, a in enumerate(block['abilities']) if a.get('printed_code') == '-']
    if dashes:
        res['unread'] = [x for x in res['unread'] if x not in dashes]
        res['dashes'] = dashes
        res['ok'] = not res['unread'] and res['health'] is not False and res['karma'] is not False \
            and res.get('alt_health') is not False
    return res


def parse(book, slug):
    ranks = booklet.ladder(book)
    reader = roster.GridReader(book, slug)
    # in the PDF's order: the inside front cover, the booklet's cards, the
    # inside back cover
    parts = {p['name']: offsets(book)['parts'][n] for n, p in enumerate(book['parts'])}
    ranges = sorted([(p, 1, 1, None) for p in book['panels']] + [(r['part'], r['pages'][0], r['pages'][1], None) for r in book['character_ranges']]
                    # a full block inside a chapter's prose (MH4's Kingpin, printed 5)
                    + [(c['part'], c['page'], c['page'], c['name']) for c in book.get('prose_cards', [])],
                    key=lambda r: r[1] + parts[r[0]]['offset'])
    entries = []
    for part, first, last, name in ranges:
        spec = next((c for c in book.get('prose_cards', []) if c['name'] == name), None) if name else None
        entries += prose_card(book, slug, part, first, name, ranks, reader, spec) if name else cards(book, slug, part, first, last, ranks, reader)
    skip = {roster.norm(n) for n in book.get('not_characters', [])}
    dropped = [e for e in entries if roster.norm(e['header']) in skip]
    if len(dropped) != len(skip):
        raise SystemExit('%s: not_characters found %d of %d' % (slug, len(dropped), len(skip)))
    entries = [e for e in entries if e not in dropped]
    pages = [(o['part'], o['page']) for o in book['opponents']]
    pages += [(f['part'], f['page']) for f in book.get('form_grids', []) if (f['part'], f['page']) not in pages]
    for part, page in pages:
        entries += opponents(book, slug, part, page, ranks)
    # a grid that repeats another entry's (registry `repeat_grids`: MH4's two
    # "2 Minions" grids, printed 12 and 13, Modok's Minions' grid again under
    # two more rooms) is checked against it, code for code, Health and Karma,
    # and is not an entry: one card (survey mh4.md decision 6)
    for r in book.get('repeat_grids', []):
        hits = [e for e in entries if e['kind'] == 'opponent' and (e['part'], e['pages']) == (r['part'], [r['page']])
                and roster.norm(e['header']) == roster.norm(bare_name(r['name']))]
        of = [e for e in entries if e['kind'] == 'opponent' and roster.norm(e['header']) == roster.norm(r['of'])]
        if len(hits) != 1 or len(of) != 1:
            raise SystemExit('%s: repeat_grids finds %s %d times on %s p.%s and %s %d times, not once each'
                             % (slug, r['name'], len(hits), r['part'], r['page'], r['of'], len(of)))
        a, b = hits[0]['blocks'][0], of[0]['blocks'][0]
        same = [x['code'] for x in a['abilities']] == [x['code'] for x in b['abilities']] \
            and (a['health'], a['karma']) == (b['health'], b['karma'])
        if not same:
            raise SystemExit('%s: repeat_grids: %s on %s p.%s does not repeat %s (%s %s/%s against %s %s/%s)'
                             % (slug, r['name'], r['part'], r['page'], r['of'],
                                ' '.join(x['code'] or '?' for x in a['abilities']), a['health'], a['karma'],
                                ' '.join(x['code'] or '?' for x in b['abilities']), b['health'], b['karma']))
        entries.remove(hits[0])
    for e in entries:
        e.pop('_sec', None)
        for p in e['powers']:
            p['text'] = booklet.quotes(gear_text(p['text']) if p.get('section') == 'equipment' else roster.join_text(p['text']))
        e['sections'] = {k: booklet.quotes(roster.join_text(v)) if isinstance(v, list) else v for k, v in e['sections'].items()}
        e['prose'] = booklet.quotes(roster.join_text(e['prose']))
    # a form grid (registry `form_grids`, MH2's Mimic once he has copied the
    # Avengers' powers) is a second block on its card, carrying its own text:
    # its Powers: line, its run-in powers and any prose under it
    for f in [e for e in entries if e['kind'] == 'form']:
        card = [e for e in entries if e['kind'] == 'entry' and roster.norm(e['header']) == roster.norm(f['header'])]
        if len(card) != 1:
            raise SystemExit('%s: form_grids names %s, found as %d cards, not 1' % (slug, f['header'], len(card)))
        b = f['blocks'][0]
        b['text'] = {'sections': f['sections'], 'powers': f['powers'], 'prose': f['prose']}
        card[0]['blocks'].append(b)
        entries.remove(f)
    # No booklet.unpaired() here: this book prints a speck read as a quote
    # (after "all", the Sentinels' Learning, printed 14), which is a `text`
    # verdict in the overrides, and those are applied by npcs.py, whose own
    # unpaired() stops the build after them.
    return [l for part, first, last, name in ranges for l in stream(book, slug, part, first, last, True)], entries


def coverage(book, entries):
    """Every name on the checklist (registry `cards` and `opponents`) is one
    entry with a block, and every entry with a block is on it; every full
    block prints a Health, and a one-line grid prints one unless the registry
    says it does not (`no_health`). Returns the lines to print and whether
    anything failed."""
    lines, bad = [], False
    card_names = [n for _part, _page, n in book['cards']]
    # a grid the registry says repeats another entry's (MH4's "2 Minions"
    # twice) is checked in parse() and is no entry; a count before a name
    # ("2 Panthers") is the page's, not the entry's
    repeats = [(r['part'], r['page'], r['name']) for r in book.get('repeat_grids', [])]
    opp_names = [bare_name(n) for o in book['opponents'] for n in o['names'] if (o['part'], o['page'], n) not in repeats]
    listed = {roster.norm(n) for n in card_names + opp_names}
    for n in card_names + opp_names:
        hits = [e for e in entries if e['blocks'] and roster.norm(e['header']) == roster.norm(n)]
        if len(hits) != 1:
            lines.append('  CHECKLIST NAME IN %d ENTRIES, not 1: %s' % (len(hits), n))
            bad = True
    for e in entries:
        if e['blocks'] and roster.norm(e['header']) not in listed:
            lines.append('  STATTED ENTRY ON NO CHECKLIST: %s (%s)' % (e['header'], e['part']))
            bad = True
        if not e['blocks']:
            lines.append('  ENTRY WITH NO BLOCK: %s (%s)' % (e['header'], e['part']))
            bad = True
    # a card's run-in powers were all found: a Powers: section with text and
    # no power is a run-in head the reader missed (MH2's "UNIQUE WEAPON:"),
    # and a head inside a power's text is one read as the power before's
    # (the Wasp's "ANIMAL COMMUNICATION AND CONTROL.", a line of its own).
    # The first is held only in an opponent_names "title" book (MH2), whose
    # run-in reading it was written for: MH1's SOVIET SUPER-TROOPERS prints
    # Powers text with no run-in head, and MH1's parse path is not changed.
    title = book.get('opponent_names') == 'title'
    # In a run-in book (MH3) the same two hold for every one-line grid with a
    # Powers: line, an opponent's or a form's: its run-ins were all read
    runin = book.get('opponent_powers') == 'run-in'
    for e in entries:
        # a Powers: section that is the word none (MH4's Punisher) names no
        # power; an Equipment: run-in (his GUNS.) is not a Powers: run-in
        none = re.match(r'^none\.?$', (e['sections'].get('powers') or '').strip(), re.I)
        # a card whose Powers: is a sentence and names no power (registry
        # `powers_prose`: MH5's Justin Hammer, who has none), each by name
        none = none or roster.norm(e['header']) in {roster.norm(n) for n in book.get('powers_prose', [])}
        if title and e['kind'] == 'entry' and e['sections'].get('powers') and not none \
                and not [p for p in e['powers'] if not p.get('section')]:
            lines.append('  POWERS: TEXT AND NO RUN-IN POWER: %s' % e['header'])
            bad = True
        grids = ([(e['header'], e)] if e['kind'] == 'opponent' else []) \
            + [('%s (%s)' % (e['header'], b['label']), b['text']) for b in e['blocks'] if b.get('text')]
        for name, t in grids if runin else []:
            if t['sections'].get('powers') and not t['powers']:
                lines.append('  POWERS: A ONE-LINE GRID\'S POWERS LINE AND NO RUN-IN POWER: %s' % name)
                bad = True
            for p in t['powers']:
                m = re.search(r"(?:^|[.!?] )([A-Z][A-Z' -]{3,}[A-Z])[.:] ", p['text'])
                if m:
                    lines.append('  POWERS: A HEAD INSIDE %s\'s %s: %s' % (name, p['name'], m.group(1)))
                    bad = True
        for p in e['powers']:
            m = re.search(r"(?:^|[.!?] )([A-Z][A-Z' -]{6,}[A-Z])[.:] ", p['text'])
            if e['kind'] == 'entry' and m:
                lines.append('  POWERS: A HEAD INSIDE %s\'s %s: %s' % (e['header'], p['name'], m.group(1)))
                bad = True
            # a head straight after a sentence left open: the line that ended
            # the sentence was lost and not re-read (MH3's Wizard: "fly at
            # Typical POWER GLOVES. WIZARD", without lost_line's "speed.")
            m = re.search(r"[a-z,] ([A-Z][A-Z'-]+(?: [A-Z][A-Z'-]+)+)\. [A-Z]", p['text'])
            if e['kind'] == 'entry' and m:
                lines.append('  POWERS: A HEAD AFTER AN OPEN SENTENCE IN %s\'s %s: %s' % (e['header'], p['name'], m.group(1)))
                bad = True
    no_health = {roster.norm(n) for n in book.get('no_health', [])}
    for e in entries:
        for b in e['blocks']:
            # a bracketed second form's Health, square or round ("70 (185)",
            # MH5's Sasquatch), is not the first Health
            h = roster.as_int(re.split(r'[\[(]', b['health'])[0]) if b['health'] else None
            if (h is None) != (b.get('kind') == 'line' and roster.norm(e['header']) in no_health):
                lines.append('  HEALTH %r: %s' % (b['health'], e['header']))
                bad = True
    full = sum(1 for e in entries for b in e['blocks'] if b.get('kind') != 'line')
    line = sum(1 for e in entries for b in e['blocks'] if b.get('kind') == 'line')
    # a form grid (registry `form_grids`) and a grid inside a card
    # (`card_grids`) are each a one-line grid on a card's entry
    forms = len(book.get('form_grids', [])) + len(book.get('card_grids', []))
    if (full, line) != (len(card_names), len(opp_names) + forms):
        lines.append('  BLOCKS: %d full and %d one-line, the checklist has %d and %d' % (full, line, len(card_names), len(opp_names) + forms))
        bad = True
    lines.insert(0, '  checklist: %d cards, %d opponents%s; %d full blocks, %d one-line grids; all found: %s'
                 % (len(card_names), len(opp_names), ', %d form grid%s' % (forms, '' if forms == 1 else 's') if forms else '',
                    full, line, 'no' if bad else 'yes'))
    if repeats:
        lines.insert(1, '  repeats: %d one-line grid%s read and checked against the entry each repeats, not entries: %s'
                     % (len(repeats), '' if len(repeats) == 1 else 's', ', '.join('%s (p.%s)' % (n, p) for _part, p, n in repeats)))
    return lines, bad
