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
  - NOT READ YET: the opponents' run-in powers after their Powers: line
    (RUNIN_POWER below is their head, and nothing calls it), and the
    Super-Adaptoid's form on printed 9.

THE NUMBERS ARE DERIVED, as MHSP1's are: each ability's number is its rank's
standard number (`rank_only`), and Health = F+A+S+E and Karma = R+I+P hold on
every block read that way. A dash printed for an ability (four False robots'
Intuition and Psyche) is printed as a dash and is not an unread rank.
"""
import re, statistics

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
COLON_HEAD = re.compile(r"^([A-Z][A-Z0-9'’ /&-]{1,40}[A-Z0-9]):\s+(.*)$")
WHOLE_HEAD = re.compile(r"^([A-Z][A-Z0-9'’ /&-]{1,40}[A-Z0-9])[.:]()$")
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
APOSTROPHES = re.compile('(?<=[A-Za-z])[’�](?=s\\b)')


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
    ok = len(out) == 7 and toks[:2] == ['F', 'A'] and toks[-1] == 'P' and len(words) == 6
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
    Pages are printed pages, or null on a panel."""
    here = lambda p: p[0] == part and (p[1] is None or first <= p[1] <= last)
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
    entries, cur = [], None
    title = book.get('opponent_names') == 'title'
    grids = [g for g in book['card_grids'] if g['part'] == part and (g['page'] is None or first <= g['page'] <= last)] \
        if 'card_grids' in book else None
    i = 0
    while i < len(lines):
        line = lines[i]
        text = line['text'].strip()
        block, nxt = booklet.full_grid(lines, i, ranks, reader)
        if block:
            if cur is None:
                raise SystemExit('%s: a block with no header above it, %s PDF %d' % (slug, part, line['pdf']))
            for k in roster.LABELS:
                if block[k.lower()] is None:
                    block[k.lower()] = raw_value(lines[i:nxt], k)
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
            i = nxt
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
        if booklet.is_header(line) or line.get('lost_header'):
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
        m = booklet.SECTION_LINE.match(text)
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
            pm = booklet.POWER_HEAD.match(text) or COLON_HEAD.match(text) or WHOLE_HEAD.match(text) or MIXED_HEAD.match(text)
            prev = lines[i - 1]['text'].rstrip() if i else ''
            if pm and cur['powers'] and not prev.endswith(SENTENCE_END):
                # a line between the last power's text and this head that
                # Tesseract lost (MH3's Wizard: "speed." read as two marks)
                lost = lost_line(lines[i - 1], line, reader)
                if lost:
                    cur['powers'][-1]['text'].append(lost)
                    prev = lost
            # a name in capitals inside the Powers: prose ("... such as
            # ANNIHILUS and / NICHOLAS SCRATCH. These powers", MH3's Franklin
            # Richards) is no power: a first power opens the section or a line
            if pm and (not cur['powers'] and not cur['sections']['powers'] or prev.endswith(SENTENCE_END)):
                cur['powers'].append({'name': booklet.power_name(pm.group(1)), 'text': []})
                text = pm.group(2)
            sink = cur['powers'][-1]['text'] if cur['powers'] else cur['sections']['powers']
        elif sec in ('talents', 'background'):
            sink = cur['sections'][sec]
        else:
            sink = cur['prose']
        sink.append(text)
        i += 1
    if grids:
        # card_grids names a grid no letter row in that card was read as
        raise SystemExit('%s: card_grids names %s on %s that no one-line grid in the card matched'
                         % (slug, ', '.join('%s (%s)' % (g['entry'], g['label']) for g in grids), part))
    for e in entries:
        for b in e['blocks']:
            b['part'] = part
    return entries


def line_block(lines, i, title, ranks, part, page, slug, name):
    """A one-line grid's block, from its letter row at lines[i]: each code is
    the word under its letter, by x, and the stat lines after the codes row
    are its Health and Karma. Returns (block, index after the stat lines).
    Read the same way for an opponent's grid and for one inside a card
    (registry `card_grids`)."""
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
    stats = []
    while k < len(lines) and booklet.STAT_LINE.match(lines[k]['text']):
        stats.append(lines[k]['text'])
        k += 1
    block.update(booklet.secondary(' '.join(stats)))
    block['check'] = check(block)
    return block, k


def opponents(book, slug, part, page, ranks):
    """The one-line grids on one chapter page, each an entry of its own."""
    lines = stream(book, slug, part, page, page, split_at_rules=False)
    # MH2 (registry "opponent_names": "title"): names in title case, a grid
    # with no name that is a form of a card (registry `form_grids`), run-in
    # powers after the Powers: line, and paragraphs that open indented
    title = book.get('opponent_names') == 'title'
    forms = [f for f in book.get('form_grids', []) if (f['part'], f['page']) == (part, page)]
    is_row = lambda l: letter_xs(l, title) is not None
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
                m = TITLE_NAME.match(APOSTROPHES.sub("'", lines[j]['text'].strip()))
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
        if head is None:
            raise SystemExit('%s: a one-line grid with no name above it, %s p.%d' % (slug, part, page))
        j, name, desc = head
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
        while k < len(lines) and not is_row(lines[k]) and not RUN_IN_HEAD.match(lines[k]['text']):
            l = lines[k]
            where = (l['pdf'], l['band'])
            named = title and power_named(l['text'], intro())
            if title and heading(l):
                break
            if carry is None and l['col'] == line['col'] and where == (line['pdf'], line['band']):
                if l['y0'] - last['y0'] >= (2 if k == first_k else 1.3) * pitch and not named:
                    break
                if title and k != first_k and left_x(l) > base_x + 20 and not named:
                    break
            elif carry is None and text and l['col'] == line['col'] + 1 and where == (line['pdf'], line['band']) \
                    and (not text[-1].rstrip().endswith(('.', '!', '?'))
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
        sections, prose = {}, [desc] if desc else []
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
    ranges = sorted([(p, 1, 1) for p in book['panels']] + [(r['part'], r['pages'][0], r['pages'][1]) for r in book['character_ranges']],
                    key=lambda r: r[1] + parts[r[0]]['offset'])
    entries = []
    for part, first, last in ranges:
        entries += cards(book, slug, part, first, last, ranks, reader)
    skip = {roster.norm(n) for n in book.get('not_characters', [])}
    dropped = [e for e in entries if roster.norm(e['header']) in skip]
    if len(dropped) != len(skip):
        raise SystemExit('%s: not_characters found %d of %d' % (slug, len(dropped), len(skip)))
    entries = [e for e in entries if e not in dropped]
    pages = [(o['part'], o['page']) for o in book['opponents']]
    pages += [(f['part'], f['page']) for f in book.get('form_grids', []) if (f['part'], f['page']) not in pages]
    for part, page in pages:
        entries += opponents(book, slug, part, page, ranks)
    for e in entries:
        e.pop('_sec', None)
        for p in e['powers']:
            p['text'] = booklet.quotes(roster.join_text(p['text']))
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
    return [l for part, first, last in ranges for l in stream(book, slug, part, first, last, True)], entries


def coverage(book, entries):
    """Every name on the checklist (registry `cards` and `opponents`) is one
    entry with a block, and every entry with a block is on it; every full
    block prints a Health, and a one-line grid prints one unless the registry
    says it does not (`no_health`). Returns the lines to print and whether
    anything failed."""
    lines, bad = [], False
    card_names = [n for _part, _page, n in book['cards']]
    opp_names = [n for o in book['opponents'] for n in o['names']]
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
    for e in entries:
        if title and e['kind'] == 'entry' and e['sections'].get('powers') and not e['powers']:
            lines.append('  POWERS: TEXT AND NO RUN-IN POWER: %s' % e['header'])
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
            h = roster.as_int(b['health'].split('[')[0]) if b['health'] else None
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
    return lines, bad
