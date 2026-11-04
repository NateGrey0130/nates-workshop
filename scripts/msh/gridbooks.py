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
    label_powers = collections.Counter({tuple(d): 0 for d in book.get('label_powers', []) if d[0] == part and first <= d[1] <= last})
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
        # MLA1 (registry body_top): the first line of a column sets at 9.6-10%
        # of the page (Gypsy Moth's header, printed 57, y 314 of 3197), so the
        # body starts higher; every other book's starts at 10%
        # MLBA1 (registry page_bottoms [part, page, fraction]): the card page's
        # lower cards run to 95.7% of the page (Wolverine's and Sunspot's
        # Talents, printed 32), under the 93.5% every other page ends at
        bottom = next((d[2] for d in book.get('page_bottoms', []) if d[:2] == [part, printed]), 0.935)
        body = [w for w in words if w['y'] > book.get('body_top', 0.10) * H and w['y'] + w['h'] < bottom * H
                and '\u2122' not in w['t'] and '\u00ae' not in w['t']]
        # ME2 (plan marvel-11-residue row 5): the bottom cut is a word's, not a
        # line's, so a column's last line that straddles it loses the words
        # that box lower. Geirrodur's "dian god of mischief, Geirrodur over-"
        # (printed 12) kept its last two words, bottoms at 3029 under a cut at
        # 3029.4, and dropped the first four, bottoms at 3030-3039. A word
        # whose top is above the cut and whose centre is inside a kept word's
        # box is on a line the body holds, and is kept with it.
        cut = bottom * H
        spans = [(w['y'], w['y'] + w['h']) for w in body if w['y'] + w['h'] > cut - 4 * w['h']]
        marks = (chr(0x2122), chr(0xae))
        body += [w for w in words if w['y'] + w['h'] >= cut and w['y'] < cut
                 and not any(m in w['t'] for m in marks)
                 and any(y0 <= w['y'] + w['h'] / 2 <= y1 for y0, y1 in spans)]
        if not body:
            continue
        page_start = len(stream)
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
                    # MLBA1 (registry semicolon_labels): a run-in label read
                    # with a semicolon (Boom-Boom's Talents;, printed 32)
                    if book.get('semicolon_labels') and l['text'].startswith(lab + ';'):
                        l['text'] = lab + ':' + l['text'][len(lab) + 1:]
                    if l['text'].startswith(lab + ':'):
                        # MLA1 (registry label_powers [part, page, label]): a
                        # power whose name is a section label (the Whirlwind's
                        # Weaponry, printed 63, under KNOWN POWERS) is left in
                        # title case, a power head, not raised to open a section
                        if (part, printed, lab) in label_powers:
                            label_powers[(part, printed, lab)] += 1
                            continue
                        l['text'] = lab.upper() + l['text'][len(lab):]
                # MT2 (registry subhead_labels): a section subhead in capitals
                # with no colon (KNOWN POWERS, BACKGROUND, printed 52-63) opens
                # its section as a run-in does
                if l['text'].strip() in subheads:
                    l['text'] = l['text'].strip() + ':'
                    # MLBA1 (registry subhead_caps): a title-case subhead
                    # (Background, Known Powers, every villain) is raised to
                    # the capitals roster.RUN_IN and roster.SECTION read
                    if book.get('subhead_caps'):
                        l['text'] = l['text'].upper()
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
        # MLBA1 (registry banner_bands [part, page, y], TSV pixels): a band
        # set across the page's columns above a page-wide banner or the card
        # page's cards (printed 26: Goliath's text above VII. King's Pawn;
        # printed 32: the Conclusion above the cards) is read column by column
        # before the band under it, not each column top to bottom across it.
        # Each cut must have lines on both sides, or the build stops.
        for d in [d for d in book.get('banner_bands', []) if d[:2] == [part, printed]]:
            seg = stream[page_start:]
            above, below = [l for l in seg if l['y0'] < d[2]], [l for l in seg if l['y0'] >= d[2]]
            if not above or not below:
                raise SystemExit('%s: banner_bands %s p.%d at y %d cuts no band' % (slug, part, printed, d[2]))
            stream[page_start:] = above + below
    for (p, page, lab), n in stopped.items():
        if n != 1:
            raise SystemExit('%s: stop_labels finds %r %d times on %s p.%d, not once' % (slug, lab + '.', n, p, page))
    for (p, page, lab), n in label_powers.items():
        if n != 1:
            raise SystemExit('%s: label_powers finds %r %d times on %s p.%d, not once' % (slug, lab + ':', n, p, page))
    # MX1 (registry speck_lines [part, page, as read, as printed], MH9's
    # shape): a line the OCR misread that only the page image settles (Blue's
    # identity line, printed 13: Biumal for Blumal). Each must be found
    # exactly once on its page, or the build stops.
    for p, page, old, new in [d for d in book.get('speck_lines', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and l['text'].strip() == old]
        if len(hits) != 1:
            raise SystemExit('%s: speck_lines finds %r %d times on %s p.%d, not once' % (slug, old, len(hits), part, page))
        hits[0]['text'] = new
    # MX3 (registry label_line_powers [part, page, power name]): a power set
    # on its section label's line ("Known Powers: Body Armor:", the Maintenance
    # Robots, printed 27), read after title_case_labels raised the label, is
    # cut into two lines, the label alone and then the power, so the label
    # opens its section and the power is read as one. Each must be found
    # exactly once on its page, after a label that opens a section.
    for p, page, head in [d for d in book.get('label_line_powers', []) if d[0] == part and first <= d[1] <= last]:
        rx = re.compile(r'^([A-Z][A-Z ]*:)\s+(' + re.escape(head) + r':.*)$')
        hits = [k for k, l in enumerate(stream) if l['printed'] == page and rx.match(l['text'])
                and roster.section_of(rx.match(l['text']).group(1)[:-1])]
        if len(hits) != 1:
            raise SystemExit('%s: label_line_powers finds %r %d times on %s p.%d, not once' % (slug, head, len(hits), part, page))
        k = hits[0]
        m = rx.match(stream[k]['text'])
        stream[k:k + 1] = [dict(stream[k], text=m.group(1)), dict(stream[k], text=m.group(2))]
    # MSL2 (registry subhead_line_powers [part, page, power name]): a
    # subhead_labels label printed with no colon and run into the first power
    # on its line ("KNOWN POWERS Alter Ego:", Stygorr, printed 31) is cut into
    # the label, given its colon, and the power. Each must be found exactly
    # once on its page.
    for p, page, head in [d for d in book.get('subhead_line_powers', []) if d[0] == part and first <= d[1] <= last]:
        rx = re.compile(r'^(' + '|'.join(re.escape(s) for s in sorted(subheads)) + r')\s+(' + re.escape(head) + r':.*)$')
        hits = [k for k, l in enumerate(stream) if l['printed'] == page and rx.match(l['text'].strip())]
        if len(hits) != 1:
            raise SystemExit('%s: subhead_line_powers finds %r %d times on %s p.%d, not once' % (slug, head, len(hits), part, page))
        k = hits[0]
        m = rx.match(stream[k]['text'].strip())
        stream[k:k + 1] = [dict(stream[k], text=m.group(1) + ':'), dict(stream[k], text=m.group(2))]
    # ME3 (registry power_heads [part, page, power name]): a run-in power whose
    # line above ends no sentence (Firelord's Energy Sheath after a list of
    # forms, Adventure p.4; Mephisto's Enlargement after "Galactus.]",
    # Resource p.6) is marked as a power head, which roster.read_entries takes
    # as a new power. Each must be found exactly once on its page.
    for d in [d for d in book.get('power_heads', []) if d[0] == part and first <= d[1] <= last]:
        p, page, head = d[:3]
        # MLBA1 (a fourth field, the line's start as read): a power head that
        # roster.POWER_HEAD cannot read, a lower-case word in its name or a
        # semicolon for its colon (Richtor's Vibration touch;, printed 32; the
        # Chimpanzee's Light manipulation:, printed 31), is read as the head,
        # its name kept as printed (roster.read_entries reads power_name)
        if len(d) > 3:
            hits = [l for l in stream if l['printed'] == page and l['text'].startswith(d[3])]
            if len(hits) != 1:
                raise SystemExit('%s: power_heads finds %r %d times on %s p.%d, not once' % (slug, d[3], len(hits), part, page))
            hits[0]['text'] = head + ':' + hits[0]['text'][len(d[3]):]
            hits[0]['power_name'] = head
        hits = [l for l in stream if l['printed'] == page and l['text'].startswith(head + ':')]
        if len(hits) != 1:
            raise SystemExit('%s: power_heads finds %r %d times on %s p.%d, not once' % (slug, head, len(hits), part, page))
        hits[0]['power_head'] = True
    # MSL4 (registry repeated_power_heads [part, page, power name, how many]):
    # a power head roster.POWER_HEAD cannot read (the comma in Force Field,
    # Personal) printed on more than one card of a page (the Mark II's and the
    # Mark III's, printed 29), which power_heads, one per page, cannot name.
    # Every line of the page that starts with the name and a colon is a head,
    # its name kept as printed, and there must be exactly that many.
    for p, page, head, n in [d for d in book.get('repeated_power_heads', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and l['text'].startswith(head + ':')]
        if len(hits) != n:
            raise SystemExit('%s: repeated_power_heads finds %r %d times on %s p.%d, not %d' % (slug, head, len(hits), part, page, n))
        for l in hits:
            l['power_head'] = True
            l['power_name'] = head
    # MLBA1 (registry powers_open [part, page, the first power's name]): a
    # codes-only grid's powers set as run-ins under it with no Known Powers
    # label (the three animals, printed 31) open a powers section at the
    # first, as a KNOWN POWERS: line would. Each must be found once.
    for p, page, head in [d for d in book.get('powers_open', []) if d[0] == part and first <= d[1] <= last]:
        at = [k for k, l in enumerate(stream) if l['printed'] == page and l['text'].startswith(head + ':')]
        if len(at) != 1:
            raise SystemExit('%s: powers_open finds %r %d times on %s p.%d, not once' % (slug, head, len(at), part, page))
        label = {k: v for k, v in stream[at[0]].items() if k not in ('power_head', 'power_name')}
        stream.insert(at[0], dict(label, text='KNOWN POWERS:', synthetic_label=True))
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
    # MSL4 (plan marvel-11-books close-out, 2026-11-03): a power head the
    # registry names (power_heads, repeated_power_heads) because roster.POWER_HEAD
    # cannot read it is a head wherever it starts a line with its colon, named
    # or not. With repeated_power_heads off, the Mark II's and the Mark III's
    # Force Field, Personal (printed 29) folded into the power above them: 38
    # powers, exit 0, and nothing said so (survey msl4.md item 27). A line that
    # starts with such a name and is not marked stops the build, unless the
    # registry's heads_in_text [part, page, power name, how many] records it as
    # text left where it is (Rigger's bulleted implant list, printed 30), and
    # then exactly that many must be there.
    named = {d[2] for key in ('power_heads', 'repeated_power_heads') for d in book.get(key, [])}
    for head in sorted(named):
        if roster.POWER_HEAD.match(head + ':'):
            continue
        loose = [l for l in stream if l['text'].startswith(head + ':') and not l.get('power_head')]
        for p, page, name, n in [d for d in book.get('heads_in_text', []) if d[0] == part and first <= d[1] <= last and d[2] == head]:
            kept = [l for l in loose if l['printed'] == page]
            if len(kept) != n:
                raise SystemExit('%s: heads_in_text finds %r %d times on %s p.%d, not %d' % (slug, head, len(kept), part, page, n))
            loose = [l for l in loose if l['printed'] != page]
        if loose:
            raise SystemExit('%s: %r heads %d unnamed line(s) on %s p.%s; name each in power_heads, repeated_power_heads or heads_in_text'
                             % (slug, head, len(loose), part, ','.join(str(l['printed']) for l in loose)))
    # MT3 (registry entry_ends [part, page, the whole line as read]): a
    # sidebar or box set in an entry's column that the page does not open
    # with a header (Attuma's KANG'S SCRIPT, printed 16; the SPIRE box under
    # the alligators, printed 22). read_entries ends the entry at the line.
    # Each must be one whole line (as roster.norm reads it) found exactly
    # once on its page, or the build stops.
    for p, page, start in [d for d in book.get('entry_ends', []) if d[0] == part and first <= d[1] <= last]:
        hits = [l for l in stream if l['printed'] == page and roster.norm(l['text']) == roster.norm(start)]
        if len(hits) != 1:
            raise SystemExit('%s: entry_ends finds %r on %d lines of %s p.%d, not 1' % (slug, start, len(hits), part, page))
        hits[0]['ends_entry'] = True
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
    # MSL1 (registry split_labels [part, page, first line's end, second
    # line's start], as read): a run-in label hyphenated over two lines
    # ("TAL-" / "ENTS:", Dominus, printed 30) is one label on the second line
    for p, page, a_end, b_start in [d for d in book.get('split_labels', []) if d[0] == part and first <= d[1] <= last]:
        at = [k for k in range(len(stream) - 1) if stream[k]['printed'] == page
              and stream[k]['text'].rstrip().endswith(a_end) and stream[k + 1]['text'].startswith(b_start)]
        if len(at) != 1:
            raise SystemExit('%s: split_labels finds %r / %r %d times on %s p.%d, not once' % (slug, a_end, b_start, len(at), part, page))
        k = at[0]
        head = stream[k]['text'].rstrip()[:-len(a_end)].rstrip()
        label = (a_end.rstrip('-') + b_start).upper()
        stream[k + 1] = dict(stream[k + 1], text=label + stream[k + 1]['text'][len(b_start):])
        if head:
            stream[k] = dict(stream[k], text=head)
        else:
            del stream[k]
    # MSL1 (registry mid_runins [part, page, label as read]): a run-in
    # label set after a sentence on the same line ("... actions. TALENTS:",
    # Mister Sinister, printed 29) starts a line of its own, so it opens its
    # section. Each must be found exactly once on its page.
    for p, page, lab in [d for d in book.get('mid_runins', []) if d[0] == part and first <= d[1] <= last]:
        rx = re.compile(r'^(.*?[.!?])\s+(' + re.escape(lab) + r':.*)$')
        at = [k for k, l in enumerate(stream) if l['printed'] == page and rx.match(l['text'])]
        if len(at) != 1:
            raise SystemExit('%s: mid_runins finds %r %d times on %s p.%d, not once' % (slug, lab, len(at), part, page))
        k = at[0]
        m = rx.match(stream[k]['text'])
        stream[k:k + 1] = [dict(stream[k], text=m.group(1)), dict(stream[k], text=m.group(2), x0=stream[k]['left'])]
    # MSL1 (registry identity_background [labels]): a card's identity
    # run-ins set after its powers and talents (Real Name:, Occupation: ...,
    # printed 26-32) open a BACKGROUND section at the first of them after a
    # KNOWN POWERS label, as MT2's BACKGROUND subhead does, so they are not
    # read as powers or as the talents' text
    opens = tuple(l + ':' for l in book.get('identity_background', []))
    if opens:
        k, after_powers = 0, False
        while k < len(stream):
            t = stream[k]['text'].lstrip()
            if t.startswith('KNOWN POWER'):
                after_powers = True
            elif after_powers and t.startswith(opens):
                stream.insert(k, dict(stream[k], text='BACKGROUND:', synthetic_label=True))
                after_powers = False
                k += 1
            k += 1
    return stream


def mark_headers(stream, cards=(), depth=3):
    """Mark the header above each grid. Returns the headers' texts. With
    `cards` (the registry's, MX1), a line above the grid that is a card's name
    is its header: MX1 sets them in title case over an identity line ("Blue" /
    "Hugh Blumal, mutant hound"), and the Mark VI's ends in a colon, which is
    dropped. `depth` is how many lines up a card's name is looked for (MX4's
    identity_lines plus one); the header rule without cards reads three."""
    found = []
    names = {roster.norm(c) for c in cards}
    for i, line in enumerate(stream):
        if not roster.ANCHOR.search(line['text']) or line.get('headed'):
            continue
        above, j = [], i - 1
        while j >= 0 and len(above) < depth:
            if not roster.ROW.match(stream[j]['text']):
                above.append(j)
            j -= 1
        named = [j for j in above if names and roster.norm(stream[j]['text']) in names]
        above = above[:3]
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
    # MT3 (registry mid_page_tops [part, page]): a top-level section whose
    # title is set partway down its page (Non-Player Characters, printed 6,
    # under the Scarlet Witch's background) breaks at that title, which the
    # header reading finds, and not at the page's top, where the text above
    # it still belongs to the entry before
    for p, page in book.get('mid_page_tops', []):
        if p == part:
            if page not in tops or not any(l['printed'] == page and roster.norm(l['text']) == roster.norm(tops[page]) for l in stream):
                raise SystemExit('mid_page_tops: %s p.%d has no line reading as its top-level title' % (part, page))
            del tops[page]
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
        if len(hits) > 1 and book.get('subhead_exact_case'):
            # MLA1 (MX2's registry subhead_exact_case): the factions' list ('-
            # the Maggia', printed 7) is the subhead's words in lower case, so
            # the line printed as the title is kept (where two matched, the
            # build stopped, so no book that builds can move)
            hits = [l for l in hits if l['text'].strip() == title]
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
    th = {d[3] for d in mends if isinstance(d, tuple) and d[0] == 'text_health'
          and (d[1], d[2]) == (stream[i]['part'], stream[i]['printed'])} if h is None else set()
    words = re.compile(r'^Heal?th:\s*(.+)$')
    t = next((j for j in range(i + 1, i + 6) if same(j) and words.match(stream[j]['text'].strip())
              and words.match(stream[j]['text'].strip()).group(1) in th), None) if th else None
    if t is not None:
        # MSL3 (registry text_health [part, printed page, words]): a Health
        # printed in words ("Health = See text", the Robotic Dragon, printed
        # 30) under a grid with no Karma line is kept as printed, which
        # roster.check skips; the grid is read as if its Health were a number
        health = words.match(stream[t]['text'].strip()).group(1)
        fake = stream[:t] + [dict(stream[t], text='Health: 0')] + stream[t + 1:]
        got = read_line_grid(fake, i, sentence, {m for m in mends if not (isinstance(m, tuple) and m[0] == 'text_health')})
        return (got[0], health, None, got[3]) if got else None
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
    dash = r'[-\u2013\u2014]'
    if 'codes_over_numbers' in mends and len(texts) == 2 \
            and all(re.fullmatch(r'[0-9OolI]{1,4}|' + dash, t) for t in texts[1].split()) \
            and not all(re.search(r'\d', t) for t in texts[0].split()):
        # MSL1 (registry codes_over_numbers): the codes row is printed
        # above the numbers row; a Shift code set with a space after its
        # hyphen ("Shift- X", Dominus's R, printed 30) is one code, and N/A
        # over a dash (his S) is no code over 0
        codes_t = re.sub(r'\bShift-?\s+([XYZ0])\b', r'Shift-\1', texts[0])
        numbers = [0 if re.fullmatch(dash, t) else roster.fix_digits(re.sub(r'[^0-9OolI]', '', t)) for t in texts[1].split()]
        codes = [None if re.sub(r'[^A-Za-z]', '', t).upper() == 'NA' else t for t in codes_t.split()]
        if 'code_marks' in mends:
            # MT3's code_marks: a mark hung on a code ("GD~", printed 29)
            codes = [c if c is None else re.sub(r'[^0-9A-Za-z-]', '', c) for c in codes]
            codes = [c for c in codes if c != '']
        canon = [None if c is None else (SHIFT.get(c) or roster.canon(c)) for c in codes]
        # MSL2 (registry short_number_rows [part, page, numbers row as read]):
        # a numbers row printed short (Stygorr's six numbers under seven
        # codes, printed 31) is read as printed and the rows it does not
        # reach are null; the book's misprint override corrects them
        if ('short', stream[i]['part'], stream[i]['printed'], texts[1]) in mends and len(numbers) < 7:
            numbers = numbers + [None] * (7 - len(numbers))
        if len(canon) != 7 or len(numbers) != 7 or any(c is None and codes[n] is not None for n, c in enumerate(canon)) \
                or any(c is None and numbers[n] != 0 for n, c in enumerate(canon)):
            raise SystemExit('a one-line grid read wrong, %s p.%d: %r' % (stream[i]['part'], stream[i]['printed'], texts))
        rows = [{'letter': roster.ABILITIES[n], 'number': numbers[n], 'code': c,
                 'printed_code': codes[n] if codes[n] is not None else 'N/A', 'rest': ''} for n, c in enumerate(canon)]
        return rows, health, karma, end
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
    mends = {k for k in ('class_i_digit', 'code_marks', 'derived_totals', 'codes_over_numbers') if book.get(k)}
    # MSL2: short_number_rows, read in read_line_grid
    mends |= {('short', d[0], d[1], d[2]) for d in book.get('short_number_rows', [])}
    # MSL3: text_health, read in read_line_grid
    mends |= {('text_health', d[0], d[1], d[2]) for d in book.get('text_health', [])}
    if book.get('equals_labels'):
        # MSL3 (registry equals_labels): a grid's labels set with an equals
        # sign, "Health = 22 Karma = 10" (every grid, printed 5-30), are read
        # as the roster's "Health: 22 Karma: 10"
        for k in range(len(stream)):
            if (stream[k]['part'], stream[k]['printed']) in want and re.match(r'^Heal?th\s*=', stream[k]['text'].strip()):
                stream[k] = dict(stream[k], text=re.sub(r'\b(Heal?th|Karma)\s*=\s*', r'\1: ', stream[k]['text'].strip()))
    if book.get('resources_beside_health'):
        # MSL1 (registry resources_beside_health): a chapter grid prints
        # "Health: 70 Resources: GD (10)" over "Karma: 26 Popularity: 0"
        # (printed 4, 9, 12), which is read as the roster's two lines,
        # "Health: 70 Karma: 26" over "Resources: GD (10) Popularity: 0"
        hr = re.compile(r'^(Heal?th:\s*\S+)\s+(Resources:\s*.+)$')
        kp = re.compile(r'^(Karma:\s*\S+)\s+(Popularity:\s*.+)$')
        for k in range(len(stream) - 1):
            a, b = hr.match(stream[k]['text'].strip()), kp.match(stream[k + 1]['text'].strip())
            if a and b and (stream[k]['part'], stream[k]['printed']) in want and stream[k]['col'] == stream[k + 1]['col']:
                stream[k] = dict(stream[k], text=a.group(1) + ' ' + b.group(1))
                stream[k + 1] = dict(stream[k + 1], text=a.group(2) + ' ' + b.group(2))
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
        grid_end, extra = end, ''
        while book.get('line_grid_resources') and end < len(stream) and stream[end]['pdf'] == l['pdf'] \
                and stream[end]['col'] == l['col'] \
                and re.match(r'^(?:Resources|Popularity):\s*\S', stream[end]['text'].strip()) \
                and stream[end]['text'].split(':')[0] not in extra:
            # MX2 (registry line_grid_resources): a codes-only grid that prints
            # Resources and Popularity on lines of their own under its Karma
            # (Vincent Scarlesi's, printed 14) keeps them, not its prose
            extra += ' ' + stream[end]['text'].strip()
            if book.get('line_popularity_minus'):
                # MSL1 (registry line_popularity_minus): MLBA1's
                # popularity_minus on a one-line grid's Resources line
                # (a minus read as U+FFFD, printed 4, 29 and 30)
                extra = re.sub(r'(Popularity:\s*)(?:' + MINUS_MARKS + r'\s*-?|-\s+)(\d+)', r'\1-\2', extra)
            end += 1
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
            # MX2 (a grid's `karma`): a Health two grids share on a page (46,
            # printed 14; 20, printed 16) is told apart by the Karma printed
            # under it, where the registry records one
            hits = [g for g in want[key] if str(g.get('health')) == health
                    and ('karma' not in g or str(g['karma']) == karma)]
            if len(hits) != 1:
                raise SystemExit('one_line_grids: %s p.%d Health %s names %d grids, not 1' % (l['part'], l['printed'], health, len(hits)))
            g = hits[0]
            want[key].remove(g)
        else:
            g = want[key].pop(0)
        rank_only = not re.search(r'\d', (stream[i] if lost else stream[i + 1])['text'])
        if 'codes_over_numbers' in mends and not lost:
            # MSL1: the numbers are the row under the codes
            rank_only = rank_only and not re.search(r'\d', stream[i + 2]['text'])
        if g.get('name') and g.get('subhead'):
            # MX1: the grid's name is the subhead above the paragraph that
            # introduces it ("The Blue Knight" over a typical policeman's
            # grid), so the entry starts there and the next subhead ends it
            # MX2 (a grid's `subhead_page`): a subhead set at the foot of the
            # page before its grid (SWAT:AM, printed 13, its grid on 14)
            skey = (l['part'], g.get('subhead_page', l['printed']))
            at = [k for k in range(len(out)) if (out[k]['part'], out[k]['printed']) == skey
                  and roster.norm(out[k]['text']) == roster.norm(g['subhead'])]
            if len(at) > 1 and book.get('subhead_exact_case'):
                # MX2 (registry subhead_exact_case): the paragraph under a
                # subhead holds a line of the same words in lower case (the
                # Secret Service's, printed 14), which roster.norm makes equal;
                # the subhead is the line in the subhead's own case
                at = [k for k in at if out[k]['text'].strip() == g['subhead']]
            if len(at) != 1:
                raise SystemExit('one_line_grids: subhead %r is on %d lines of %s p.%d, not 1' % (g['subhead'], len(at), l['part'], l['printed']))
            out[at[0]] = dict(out[at[0]], text=g['name'], big=True, subhead=True)
            rows[0]['rest'] = 'Health: %s Karma: %s' % (health, karma) + extra
            if karma is None and book.get('no_karma_line'):
                # MSL3 (registry no_karma_line): a grid that prints Health and
                # no Karma line (the Flying Robotic Snake, printed 6; the
                # Robotic Dragon, 30) keeps no Karma, not the string 'None'
                rows[0]['rest'] = 'Health: %s' % health + extra
            # MSL3 (registry text_health): a Health printed in words anchors
            # its block all the same (roster.read_entries)
            th = {'text_health': True} if book.get('text_health') and not re.search(r'\d', health or '') else {}
            out.append(dict(stream[grid_end - 1], text=rows[0]['rest'], line_grid=rows, headed=True, **th))
            keyed[(l['pdf'], l['col'], health)] = rank_only
        elif g.get('name'):
            out.append(dict(l, text=g['name'], big=True, conf=100, y1=l['y0'] - 8))
            rows[0]['rest'] = 'Health: %s Karma: %s' % (health, karma) + extra
            out.append(dict(stream[grid_end - 1], text=rows[0]['rest'], line_grid=rows))
            keyed[(l['pdf'], l['col'], health)] = rank_only
        elif extra and not book.get('form_resources'):
            raise SystemExit('line_grid_resources: %s p.%d: the form %s prints%s, which a labelled grid does not read'
                             % (l['part'], l['printed'], g['label'], extra))
        else:
            block = {'label': g['label'], 'kind': 'line', 'page': l['printed'], 'pdf': l['pdf'], 'col': l['col'],
                     'abilities': [{k: r[k] for k in ('letter', 'number', 'code', 'printed_code')} for r in rows],
                     'health': health, 'karma': karma, 'resources': None, 'popularity': None}
            if extra:
                # MSL2 (registry form_resources): a form's grid that prints
                # its own Resources and Popularity lines (Stygorr's human
                # form, printed 31) keeps them on its block
                rp = re.match(r'^\s*Resources:\s*(.+?)\s+Popularity:\s*(\S+)\s*$', extra)
                if not rp:
                    raise SystemExit('form_resources: %s p.%d: the form %s prints %r' % (l['part'], l['printed'], g['label'], extra))
                block['resources'], block['popularity'] = rp.group(1), rp.group(2)
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


KARMA_GRID_ROWS = ('R', 'I', 'P')


def karma_grids(book, stream, reader, karma_keyed):
    """MLA1 (registry karma_grids [part, page, name]): a grid of three rows,
    R, I and P, with Karma beside R and no Health (Bartholomew Jacobs, printed
    40: the chapter gives him the physical abilities of the hero he
    possesses), under a line of prose and with no header. It has no Health
    line for roster.read_entries to anchor on, so its Karma line is the anchor
    (a line marked karma_grid), the name the registry's, and its F, A, S, E
    and Health are unset. The rows are read from a crop of the grid with
    codegrids' row, the book's code_rows. Each must be the one Karma line with
    no Health on its page, and three rows, or the build stops. `karma_keyed`
    gets the grid's (pdf, col, Karma), which parse() checks as such."""
    want = [g for g in book.get('karma_grids', []) if any((l['part'], l['printed']) == (g[0], g[1]) for l in stream)]
    if not want:
        return stream
    import codegrids
    row = codegrids.code_row(bool(book.get('unread_codes')), bool(book.get('code_row_specks')), bool(book.get('dash_shift_codes')))
    for part, page, name in want:
        at = [k for k, l in enumerate(stream) if (l['part'], l['printed']) == (part, page)
              and re.search(r'Karma\s*:\s*\d', l['text']) and not roster.ANCHOR.search(l['text'])]
        if len(at) != 1:
            raise SystemExit('karma_grids: %s p.%d prints %d Karma lines with no Health, not 1' % (part, page, len(at)))
        k = at[0]
        l = stream[k]
        p = next((j for j in range(k + 1, min(len(stream), k + 4)) if (stream[j]['pdf'], stream[j]['col']) == (l['pdf'], l['col'])
                  and re.match(r'^\s*P\s+\S', stream[j]['text'])), None)
        if p is None:
            raise SystemExit('karma_grids: %s p.%d %s: no P row under the Karma line' % (part, page, name))
        got = codegrids.rows_from(reader.read(l['pdf'], (l['col_x0'], l['y0'] - 20, l['col_x1'], stream[p]['y1'] + 10)), pattern=row)
        if len(got) != 3:
            raise SystemExit('karma_grids: %s p.%d %s: the crop gives %d rows, not 3' % (part, page, name, len(got)))
        rows = [{'letter': x, 'number': None, 'code': None, 'printed_code': None, 'rest': ''} for x in roster.ABILITIES[:4]]
        rows += [dict(r, letter=x) for x, r in zip(KARMA_GRID_ROWS, got)]
        karma = re.search(r'Karma\s*:\s*(\d+)', ' '.join(r['rest'] for r in got))
        if not karma:
            raise SystemExit('karma_grids: %s p.%d %s: the crop reads no Karma' % (part, page, name))
        karma_keyed.add((l['pdf'], l['col'], karma.group(1)))
        stream[k:p + 1] = [dict(l, text=name, big=True, conf=100, y1=l['y0'] - 8),
                           dict(stream[p], text='Karma: ' + karma.group(1), line_grid=rows, karma_grid=True)]
    return stream


def table_grids(book, stream, reader, keyed):
    """MX2 (registry table_grids [{part, page, first, names, health, karma}]):
    one table of several characters' codes (the Mutant Affairs Committee,
    printed 15): a letters row headed by the word `first`, a row per name (the
    name, then seven codes) and one Health and Karma under them all. The page
    stream drops and welds its codes, so the rows are read from a --psm 6 crop
    of the column from the letters row to the Karma line, and a welded pair
    (GDTY) is split in two. The table leaves the stream, and each name becomes
    an entry: a header and a one-line grid put in at the run-in that opens its
    paragraph ("Chuck:"), which is its prose to the next header. Each block
    keeps the table's Health and Karma as printed; the overrides correct
    them to its codes' sums (survey mx2.md decision 6)."""
    for t in book.get('table_grids', []):
        where = '%s p.%d' % (t['part'], t['page'])
        on = [k for k, l in enumerate(stream) if (l['part'], l['printed']) == (t['part'], t['page'])]
        if not on:
            continue
        tops = [k for k in on if stream[k]['text'].split()[:3] == [t['first'], 'F', 'A']]
        if len(tops) != 1:
            raise SystemExit('table_grids: %r and its letters are on %d lines of %s, not 1' % (t['first'], len(tops), where))
        top = tops[0]
        same = lambda j: stream[j]['pdf'] == stream[top]['pdf'] and stream[j]['col'] == stream[top]['col']
        k = next((j for j in range(top + 2, min(len(stream), top + 12))
                  if same(j) and KARMA_LINE.match(stream[j]['text'].strip())), None)
        if k is None or not HEALTH_LINE.match(stream[k - 1]['text'].strip()) or not all(same(j) for j in range(top, k + 1)):
            raise SystemExit('table_grids: no Health and Karma line in the column under the table on %s' % where)
        health = HEALTH_LINE.match(stream[k - 1]['text'].strip()).group(1)
        karma = KARMA_LINE.match(stream[k]['text'].strip()).group(1)
        if (health, karma) != (str(t['health']), str(t['karma'])):
            raise SystemExit('table_grids: %s prints Health %s and Karma %s, not %s and %s'
                             % (where, health, karma, t['health'], t['karma']))
        head = stream[top]
        texts = reader.read(head['pdf'], (head['col_x0'], head['y0'] - 15, head['col_x1'], stream[k]['y1'] + 10))
        rows_of = {}
        for name in t['names']:
            hit = [x for x in texts if x.split()[:1] == [name]]
            if len(hit) != 1:
                raise SystemExit('table_grids: %s is %d rows of the crop on %s, not 1' % (name, len(hit), where))
            codes = []
            for tok in hit[0].split()[1:]:
                if roster.canon(tok) is None and len(tok) == 4 and roster.canon(tok[:2]) and roster.canon(tok[2:]):
                    codes += [tok[:2], tok[2:]]
                else:
                    codes.append(tok)
            canon = [roster.canon(c) for c in codes]
            if len(canon) != 7 or None in canon:
                raise SystemExit('table_grids: %s reads %r on %s, not seven codes' % (name, hit[0], where))
            rows_of[name] = [{'letter': roster.ABILITIES[n], 'number': roster.RANK_NUMBER[c], 'code': c,
                              'printed_code': codes[n], 'rest': ''} for n, c in enumerate(canon)]
        del stream[top:k + 1]
        for name in t['names']:
            at = [j for j, l in enumerate(stream) if (l['part'], l['printed']) == (t['part'], t['page'])
                  and l['text'].startswith(name + ':')]
            if len(at) != 1:
                raise SystemExit('table_grids: the run-in %r is on %d lines of %s, not 1' % (name + ':', len(at), where))
            l, rows = stream[at[0]], rows_of[name]
            rows[0]['rest'] = 'Health: %s Karma: %s' % (health, karma)
            stream[at[0]:at[0] + 1] = [dict(l, text=name, big=True, conf=100, y1=l['y0'] - 8),
                                       dict(l, text=rows[0]['rest'], line_grid=rows, headed=True),
                                       dict(l, text=l['text'][len(name) + 1:].strip())]
            keyed[(l['pdf'], l['col'], health)] = True
    return stream


def grid(stream, i, reader, code_rows=False, end_at_p=False, resources_below=False,
         unread_codes=False, specks=False, end_at_popularity=False, by_pitch=False, dash_shift=False,
         rising_pitch=False, undashed_shift=False, s_numbers=False, aliases=None, health_mend=False,
         upper_shift=False, stream_fallback=False):
    """`resources_below` is the registry's code_rows_resources_below (MX2),
    passed to scripts/msh/codegrids.py's row reader. MX3's, each with
    code_rows: `unread_codes` (registry unread_codes) and `specks` (registry
    code_row_specks) choose codegrids.code_row's row, and `end_at_popularity`
    (registry code_rows_end_at_popularity) is codegrids.grid_at's. MLA1's,
    each with code_rows: `dash_shift` (registry dash_shift_codes) is
    codegrids.code_row's, and `by_pitch` (registry code_grids_by_pitch) reads
    a grid seven row pitches down where no Popularity line ends it. MLA2's,
    each with code_rows and a registry field of its own: `rising_pitch`
    (rising_row_pitch) tries larger pitches where by_pitch's least one cuts
    the grid; `undashed_shift` (undashed_shift_zero) and `s_numbers`
    (s_before_number) are codegrids.code_row's; `aliases` (code_rank_aliases,
    booklet.ladder(book)) gives code_row the spellings roster.canon cannot
    read and codegrids.code_of their codes; `health_mend` (mend_by_health) is
    codegrids.rows_from's. MLA3's, each a registry field of its own:
    `stream_fallback` (stream_row_fallback) is the by_pitch path's, below;
    `upper_shift` (upper_shift_zero, with undashed_shift_zero) has
    codegrids.code_of fold the Shift 0 it reads in capitals too."""
    extra =tuple(sorted(k for k in (aliases or {}) if re.match(r'^[A-Z]{1,2}$', k) and roster.canon(k) is None))
    rules = dict(aliases=aliases, fold_shift=('any_case' if undashed_shift and upper_shift else undashed_shift),
                 health_mend=health_mend)
    line = stream[i]
    if line.get('line_grid'):
        return line['line_grid'], i + 1
    rows, end = roster.grid_at(stream, i, reader)
    if rows is None and end == i and by_pitch and code_rows and roster.ANCHOR.search(line['text']):
        # MLA1 (registry code_grids_by_pitch): a code-first grid with no
        # Popularity (Security Officers, printed 36) or no Karma either (the
        # chapter 32 three, printed 42), its row letters lost from the stream,
        # so grids_end_at_p finds no P row: read seven row pitches down (the
        # pitch the least gap of the column's next lines; 6.9 pitches cut the
        # Mosquito Swarm's P, printed 42)
        import codegrids
        row = codegrids.code_row(unread_codes, specks, dash_shift, undashed_shift, s_numbers, extra)
        same = [j for j in range(i, min(len(stream), i + 12))
                if stream[j]['pdf'] == line['pdf'] and stream[j]['col'] == line['col']]
        gaps = [stream[b]['y0'] - stream[a]['y0'] for a, b in zip(same, same[1:4]) if stream[b]['y0'] > stream[a]['y0']]
        if gaps:
            pitches = [min(gaps)]
            if rising_pitch:
                # MLA2 (registry rising_row_pitch): a lone row letter read
                # low makes the least gap too small (the Old Man's S 24 px
                # under his A, his rows 46 px apart, printed 23), so the
                # pitch is at least half the Health-to-Karma distance, then
                # the median of the column's next three gaps; the first crop
                # that gives seven rows wins
                kar = next((j for j in same if 'Karma' in stream[j]['text']), None)
                first = pitches[0]
                if kar is not None and stream[kar]['y0'] > line['y0']:
                    first = max(first, (stream[kar]['y0'] - line['y0']) / 2)
                pitches = sorted({first, max(first, sorted(gaps)[len(gaps) // 2])})
            for pitch in pitches:
                bottom = line['y0'] + 7 * pitch + 10
                box = (line['col_x0'], line['y0'] - 45, line['col_x1'], bottom)
                got = codegrids.rows_from(reader.read(line['pdf'], box), pattern=row, unread_codes=unread_codes, **rules)
                if len(got) >= 7:
                    end = i + 1
                    while end < len(stream) and stream[end]['pdf'] == line['pdf'] and stream[end]['col'] == line['col'] \
                            and stream[end]['y0'] < bottom - 10 and not roster.RUN_IN.match(stream[end]['text']):
                        end += 1
                    return got[:7], end
            if stream_fallback:
                # MLA3 (registry stream_row_fallback): no crop gives seven
                # rows (the Hammerhead Robot's P, printed 15, reads with a bar
                # before its row letter in every crop; the Creature From the
                # Void's I, printed 44, reads as a 1 with no number in every
                # one, so its P is counted the sixth row),
                # so the stream's own lines over seven of the first pitch
                bottom = line['y0'] + 7 * pitches[0] + 10
                got = codegrids.rows_from([stream[j]['text'] for j in same if stream[j]['y0'] < bottom - 10],
                                          pattern=row, unread_codes=unread_codes, **rules)
                if len(got) >= 7:
                    end = i + 1
                    while end < len(stream) and stream[end]['pdf'] == line['pdf'] and stream[end]['col'] == line['col'] \
                            and stream[end]['y0'] < bottom - 10 and not roster.RUN_IN.match(stream[end]['text']):
                        end += 1
                    return got[:7], end
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
        row = codegrids.code_row(unread_codes, specks, dash_shift, undashed_shift, s_numbers, extra)
        rows2, end2 = codegrids.grid_at(stream, i, reader, pattern=row, resources_below=resources_below,
                                        unread_codes=unread_codes, end_at_popularity=end_at_popularity, **rules)
        if rows2 is not None:
            return rows2, end2
        # the stream can lose the Karma line under confidence 45 (Bernard
        # Carns, printed 25), and codegrids.grid_at wants it, so read
        # roster.grid_at's own box, the Health line to the Popularity line
        pop = next((j for j in range(i, min(len(stream), i + 12)) if stream[j]['pdf'] == line['pdf']
                    and stream[j]['col'] == line['col'] and 'Popular' in stream[j]['text']), None)
        if pop is not None:
            box = (line['col_x0'], line['y0'] - 45, line['col_x1'], stream[pop]['y1'] + 10)
            rows3 = codegrids.rows_from(reader.read(line['pdf'], box), pattern=row,
                                        resources_below=resources_below, unread_codes=unread_codes, **rules)
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


# MLBA1's grid shapes, each gated by a registry field of its own (survey
# mlba1.md, Which reader fits, reader changes 1-9), rewritten into the shape
# the code_rows path reads (MLA1's: Health beside F, Karma beside S,
# Resources beside R, Popularity beside P)
WORD_ROWS = {'Fighting': 'F', 'Agility': 'A', 'Strength': 'S', 'Endurance': 'E',
             'Reason': 'R', 'Intuition': 'I', 'Psyche': 'P'}
CAPS_CODE = r'(?:FE|PR|TY|GD|EX|RM|IN|AM|MN|UN)'
WELDED = re.compile(r'(?<![A-Za-z])(' + CAPS_CODE + r')(\d{1,3})(?!\d)')
SEMI_TOTAL = re.compile(r'\b(Heal?th|Karma);')
TOTAL_LABEL = re.compile(r'^(Health|Karma|Resources|Popularity):\s*(.*)$')
BESIDE_ROW = {'F': 'Health', 'S': 'Karma', 'R': 'Resources', 'P': 'Popularity'}
# a minus read as U+FFFD, an em dash, an en dash or a tilde
MINUS_MARKS = '[' + chr(0xfffd) + chr(0x2014) + chr(0x2013) + '~]'
GRID_MENDS = ('welded_codes', 'semicolon_labels', 'card_art', 'popularity_minus', 'one_as_i')


def total_mends(book, t):
    """A grid line's misreads, each gated by its registry field."""
    # MLBA1 (registry welded_codes): a code welded to its number ("TY6",
    # "GD10": the cards, printed 32, and the low grids, printed 4 and 6)
    if book.get('welded_codes'):
        t = WELDED.sub(r'\1 \2', t)
    # MLBA1 (registry semicolon_labels): "Health;" and "Karma;" (printed 32)
    if book.get('semicolon_labels'):
        t = SEMI_TOTAL.sub(r'\1:', t)
    # MLBA1 (registry card_art): a card's portrait read beside its totals
    # ("Health: 110 nt, oe", printed 32): a total keeps its number, and a
    # bracketed second (Sunspot's 52(76)), and a Resources its code
    if book.get('card_art'):
        t = re.sub(r'((?:Heal?th|Karma):\s*\d+(?:\(\d+\))?)\s+(?!(?:Health|Karma|Resources|Popularity)\b)[^\n]*$', r'\1', t)
        t = re.sub(r'(Resources:\s*[A-Z]{2}\s*\(\d+\))\s+[^\n]*$', r'\1', t)
    # MLBA1 (registry popularity_minus): a Popularity's minus read as U+FFFD,
    # a dash or a spaced hyphen (printed 12, 25)
    if book.get('popularity_minus'):
        t = re.sub(r'(Popularity:\s*)(?:' + MINUS_MARKS + r'\s*-?|-\s+)(\d+)', r'\1-\2', t)
    return t


def mend_reader(book, reader):
    """The grid crop's lines mended as the stream's are (MLBA1). A book that
    sets none of GRID_MENDS keeps the reader as it is."""
    if not any(book.get(k) for k in GRID_MENDS):
        return reader
    read = reader.read

    def mended(pdf, box, psm='6'):
        out = []
        for t in read(pdf, box, psm):
            # MLBA1 (registry one_as_i): a 1 read as i in a row's number
            # (Richtor's P "GD i0", printed 32)
            if book.get('one_as_i'):
                t = re.sub(r'(?<=' + CAPS_CODE + r' )i(?=\d)', '1', t)
            t = total_mends(book, t)
            m = re.match(r'^(\S{0,3}\s*' + CAPS_CODE + r'\s*\(?\s*\d{1,3}\s*\)?)\s*(.*)$', t)
            if book.get('card_art') and m:
                # a card's portrait read beside its rows ("A RM 30 '", printed
                # 32): what is not a total after the row is art
                lab = re.search(r'\b(?:Heal?th|Karma|Resources|Popularity):', m.group(2))
                t = m.group(1) + (' ' + m.group(2)[lab.start():] if lab else '')
            out.append(t)
        return out
    reader.read = mended
    return reader


def synth_rows(lines, rows, labels):
    """Seven lines in MLA1's shape from rows [(letter, code and number)] and
    totals {label: value}; each line copies its source line's place."""
    out = []
    first = lines[0]
    for k, (letter, value) in enumerate(rows):
        src = lines[k] if k < len(lines) else lines[-1]
        lab = BESIDE_ROW.get(letter)
        text = '%s %s' % (letter, value)
        if lab and labels.get(lab) is not None:
            text += ' %s: %s' % (lab, labels[lab])
        out.append(dict(src, text=text, col=first['col'], col_x0=first['col_x0'], col_x1=first['col_x1'],
                        y0=first['y0'] + 46 * k, y1=first['y0'] + 46 * k + 36, big=False, synth_row=True))
    return out


def word_rows(book, stream, log):
    """MLBA1 (registry word_rows): a grid of seven full-word rows ("Fighting
    RM (30)") with Health, Karma, Resources and Popularity as four lines under
    it (printed 3, 8, 9, 12, 18, 25, 29)."""
    if not book.get('word_rows'):
        return stream
    out, i = [], 0
    while i < len(stream):
        at, m, k, skipped = [], [], i, []
        for w in WORD_ROWS:
            x = re.match(r'^\s*(' + w + r')\s+(.*)$', stream[k]['text']) if k < len(stream) else None
            # MLBA1 (registry split_word_rows): a grid broken across a column
            # (Mauler, printed 9) with a map's lettering between its parts in
            # the stream: up to four lines that are no row are skipped where
            # the column changes
            if x is None and at and book.get('split_word_rows'):
                for kk in range(k, min(len(stream), k + 5)):
                    y = re.match(r'^\s*(' + w + r')\s+(.*)$', stream[kk]['text'])
                    if y and stream[kk]['col'] != stream[at[-1]]['col']:
                        skipped += stream[k:kk]
                        x, k = y, kk
                        break
            if x is None:
                break
            at.append(k)
            m.append(x)
            k += 1
        if len(m) == 7:
            rows = [(WORD_ROWS[x.group(1)], x.group(2).strip()) for x in m]
            j, labels = k, {}
            while j < len(stream) and len(labels) < 4:
                lm = TOTAL_LABEL.match(stream[j]['text'].strip())
                if not lm or lm.group(1) in labels:
                    break
                labels[lm.group(1)] = lm.group(2).strip()
                j += 1
            log.append('word_rows p.%d: %s / %s%s' % (stream[i]['printed'], ' '.join(r[1] for r in rows), labels,
                                                     ' skipped %r' % [s['text'] for s in skipped] if skipped else ''))
            out += synth_rows([stream[a] for a in at], rows, labels)
            i = j
            continue
        out.append(stream[i])
        i += 1
    return out


def low_grids(book, stream, reader, log):
    """MLBA1 (registry low_grids [part, page, header]): rows F to P under a
    header, Health beside E and Karma beside P, whose row letters the stream
    reads sideways (printed 4, 6), so the rows come from a crop of the grid,
    the header's foot to the Karma line. Each header must be one line of its
    page, with a Karma line under it and seven rows in the crop."""
    import codegrids
    want = [g for g in book.get('low_grids', []) if any((l['part'], l['printed']) == (g[0], g[1]) for l in stream)]
    for part, page, name in want:
        at = [k for k, l in enumerate(stream) if (l['part'], l['printed']) == (part, page) and l['text'].strip() == name]
        if len(at) != 1:
            raise SystemExit('low_grids: %r on %d lines of p.%d, not 1' % (name, len(at), page))
        h = at[0]
        head = stream[h]
        kar = next((k for k in range(h + 1, min(len(stream), h + 12)) if stream[k]['col'] == head['col']
                    and re.search(r'Karma:\s*\d+\s*$', stream[k]['text'])), None)
        if kar is None:
            raise SystemExit('low_grids: no Karma line under %r' % name)
        box = (head['col_x0'], head['y1'] + 2, head['col_x1'], stream[kar]['y1'] + 10)
        texts = reader.read(head['pdf'], box)
        got = codegrids.rows_from(texts, pattern=codegrids.code_row())
        if len(got) != 7:
            raise SystemExit('low_grids: %r crop gives %d rows: %r' % (name, len(got), texts))
        rest = ' '.join(r['rest'] for r in got)
        labels = {k: (re.search(k + r':\s*(\S+)', rest) or [None, None])[1] for k in ('Health', 'Karma')}
        rows = [(roster.ABILITIES[n], '%s (%s)' % (r['printed_code'], r['number'])) for n, r in enumerate(got)]
        log.append('low_grids p.%d %s: %s / %s' % (page, name, ' '.join(r[1] for r in rows), labels))
        lines = [stream[k] for k in range(h + 1, kar + 1) if stream[k]['col'] == head['col']]
        lines.sort(key=lambda l: l['y0'])
        new = synth_rows([dict(lines[0], y0=head['y1'] + 10)] + lines[1:], rows, labels)
        stream = stream[:h + 1] + new + stream[kar + 1:]
    return stream


def total_lines(book, stream):
    return [dict(l, text=total_mends(book, l['text'])) if re.match(r'^\s*\S{0,3}\s*' + CAPS_CODE + r'\s*\(?\d', l['text'])
            or SEMI_TOTAL.search(l['text']) or l['text'].lstrip().startswith('Popularity:') else l for l in stream]


def mend_grids(book, stream, reader):
    """MLBA1's grid shapes read into MLA1's (see WORD_ROWS above). A book that
    sets none of their fields gets its stream back as it was."""
    if not any(book.get(k) for k in GRID_MENDS + ('word_rows', 'low_grids')):
        return stream
    log = []
    stream = total_lines(book, word_rows(book, total_lines(book, stream), log))
    stream = low_grids(book, stream, reader, log)
    for x in log:
        print('  grid', x)
    return stream


def parse(book, slug):
    reader = mend_reader(book, roster.GridReader(book, slug))
    ranges = roster.rank_ranges(book)
    streams, keyed, labelled, derived = [], {}, [], {}
    karma_keyed = set()
    cards = [c[2] for c in book.get('cards', [])] if book.get('card_headers') else ()
    # MX4 (registry identity_lines): an identity line of up to four lines
    # (Mystique, printed 29), so a card's name is looked for that many lines
    # plus one above its grid, and that many identity lines are kept; every
    # other book reads three
    identity_lines = book.get('identity_lines', 3)
    for r in book['character_ranges']:
        s = mend_grids(book, stream_of(book, slug, r['part'], r['pages'][0], r['pages'][1]), reader)
        s = table_grids(book, place_headers(book, s), reader, keyed)
        s = mark_titles(book, line_grids(book, s, keyed, labelled, derived))
        streams.append((mark_breaks(book, s, r['part'], mark_headers(s, cards, identity_lines + 1 if 'identity_lines' in book else 3)),
                        False, ()))
    # MX2: a book whose blocks are all in its character ranges sets no
    # opponents (every earlier grid-booklets book sets the key)
    for o in book.get('opponents', []):
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
        s = mend_grids(book, s, reader)
        s = line_grids(book, place_headers(book, s), keyed, labelled, derived)
        s = mark_titles(book, karma_grids(book, s, reader, karma_keyed))
        mark_headers(s, cards)
        streams.append((s, True, tuple(o.get('runs_on', []))))
    stream, entries = [], []
    code_rows, end_at_p = bool(book.get('code_rows')), bool(book.get('grids_end_at_p'))
    below = bool(book.get('code_rows_resources_below'))
    mx3 = dict(unread_codes=bool(book.get('unread_codes')), specks=bool(book.get('code_row_specks')),
               end_at_popularity=bool(book.get('code_rows_end_at_popularity')),
               by_pitch=bool(book.get('code_grids_by_pitch')), dash_shift=bool(book.get('dash_shift_codes')))
    # MLA2's, each a registry field of its own (grid's docstring)
    if book.get('code_rank_aliases'):
        import booklet
        mx3['aliases'] = booklet.ladder(book)
    for k, field in (('rising_pitch', 'rising_row_pitch'), ('undashed_shift', 'undashed_shift_zero'),
                     ('s_numbers', 's_before_number'), ('health_mend', 'mend_by_health'),
                     # MLA3's (grid's docstring)
                     ('upper_shift', 'upper_shift_zero'), ('stream_fallback', 'stream_row_fallback')):
        if book.get(field):
            mx3[k] = True
    read_grid = (lambda st, i, rd: grid(st, i, rd, code_rows=code_rows, end_at_p=end_at_p, resources_below=below, **mx3)) \
        if code_rows or end_at_p else grid
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
                                  identity_lines=identity_lines,
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
                # MLA1 (registry derived_karma): a vertical grid that prints no
                # Karma (the chapter 32 three, printed 42) derives it, R+I+P,
                # as MT3's derived_totals does a one-line grid's, and lists it
                # in the block's derived (survey mla1.md decision 7)
                if book.get('derived_karma') and b['karma'] is None and b.get('kind') != 'line' \
                        and all(a['number'] is not None for a in b['abilities'][4:]):
                    b['karma'] = str(sum(a['number'] for a in b['abilities'][4:]))
                    b['derived'] = sorted(set(b.get('derived', [])) | {'karma'})
                    b['check'] = roster.check(b, ranges)
                if (b['pdf'], b['col'], b['karma']) in karma_keyed and b['health'] is None \
                        and all(a['number'] is None for a in b['abilities'][:4]):
                    # MLA1 (karma_grids): the grid prints R, I, P and Karma
                    # alone, so the Karma is held to R+I+P and each row to its
                    # code, and what it does not print is listed as unprinted,
                    # which coverage() reads (roster.check fails a block with
                    # any row unset)
                    rip = [a['number'] for a in b['abilities'][4:]]
                    k = roster.as_int(b['karma'])
                    c = {'ranks': [x for n, x in enumerate(roster.ABILITIES) if n >= 4 and not roster.rank_ok(b['abilities'][n], ranges)],
                         'codes_unread': [x for n, x in enumerate(roster.ABILITIES) if n >= 4 and b['abilities'][n]['code'] is None],
                         'health': None, 'karma': None if k is None or None in rip else sum(rip) == k}
                    c['ok'] = not c['ranks'] and not c['codes_unread'] and c['karma'] is True
                    b['check'], b['unprinted'] = c, list(roster.ABILITIES[:4]) + ['health']
            # Death's "Health: 20,000" (ME2, Resource p.2): check() reads no comma
            for b in e['blocks']:
                if ',' in (b['health'] or '') and b['check'].get('health') is None:
                    b['check'] = roster.check(dict(b, health=b['health'].replace(',', '')), ranges)
        entries += got
    # MLA1 (registry grid_cards [part, page, host, n, name]): a card's n-th
    # grid set inside its text that is a being of its own (the zombie and the
    # skeleton the Black Talon raises, his second and third grids, printed 53;
    # survey mla1.md decision 4) is an entry of its own, named by the
    # registry, with the grid alone and the host's team. The text stays the
    # host's. The host must be one entry and hold the grid, or the build stops.
    split = collections.defaultdict(list)
    for part, page, host, n, name in book.get('grid_cards', []):
        split[(part, page, host)].append((n, name))
    for (part, page, host), gs in split.items():
        hits = [k for k, e in enumerate(entries) if e['part'] == part and e['pages'][0] == page and e['header'] == host]
        if len(hits) != 1 or any(not 2 <= n <= len(entries[hits[0]]['blocks']) for n, _ in gs):
            raise SystemExit('grid_cards: %s p.%d %r is %d entries, not 1 holding grids %s'
                             % (part, page, host, len(hits), [n for n, _ in gs]))
        h = entries[hits[0]]
        made = [{'kind': 'entry', 'header': name, 'pages': [h['blocks'][n - 1]['page']], 'identity': [],
                 'blocks': [h['blocks'][n - 1]], 'sections': {}, 'powers': [], 'members': [], 'prose': [], '_sec': None,
                 'part': part, 'team': h['team']} for n, name in sorted(gs)]
        h['blocks'] = [b for n, b in enumerate(h['blocks'], 1) if n not in {n for n, _ in gs}]
        entries[hits[0] + 1:hits[0] + 1] = made
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


def forms(name, bracketed=False):
    """A checklist name as a header may print it. ME2's Contents inverts some
    ("Chimaera, The", "Asgardian, Typical") where the header reads CHIMAERA,
    The FENRIS WOLF or Typical ASGARDIAN; a leading The is dropped either way.
    `bracketed` is MLA2's registry bracketed_card_names: a name with a
    variant in brackets (Captain America (Original), printed 54; Iron Man
    (Mark VIII Armor), 58) is matched as base() reads its header too, with
    the bracket gone."""
    out = {roster.norm(name)} | ({base(name)} if bracketed else set())
    if ', ' in name:
        surname, given = name.split(', ', 1)
        out.add(roster.norm(given + ' ' + surname))
    return out | {re.sub(r'^the ', '', n) for n in out}


def match(name, entries, part=None, page=None, bracketed=False):
    """The one entry with a block that a checklist name names. A name on two
    checklists (ME2's Titans and Zeus: a Resource Book entry and a second grid
    in a chapter) is told apart by the booklet and page each list gives.
    `bracketed` is forms'."""
    n = forms(name, bracketed)
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
    where += [(n, o['part'], o['page']) for o in book.get('opponents', []) for n in o['names']]
    opponents = [n for o in book.get('opponents', []) for n in o['names']]
    # MX1: no Contents line names a character, so the registry's cards (each
    # header with a block, by booklet and page) are a checklist too
    cards = [(n, part, page) for part, page, n in book.get('cards', [])]
    # MLA1: a grid_cards entry is a card the registry names too
    cards += [(n, part, page) for part, page, _host, _k, n in book.get('grid_cards', [])]
    where += cards
    listed = contents + opponents + book.get('tiers', []) + [c[0] for c in cards]
    bracketed = bool(book.get('bracketed_card_names'))
    for n, part, page in where + [(t, None, None) for t in book.get('tiers', [])]:
        if not match(n, entries, part, page, bracketed):
            lines.append('  CHECKLIST NAME WITH NO ENTRY: %s' % n)
            bad = True
    known = {f for n in listed for f in forms(n, bracketed)} | {roster.norm(r[0]) for r in summary['heroes']}
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
            # ...or the grid prints no such line (MLA1's karma_grids)
            explained |= set(b.get('unprinted', ()))
            for k in ('health', 'karma'):
                if roster.as_int((b[k] or '').replace(',', '')) is None and k not in explained:
                    lines.append('  %s IS NOT A NUMBER: %s %s p.%s: %r' % (k.upper(), e['header'], e['part'], b['page'], b[k]))
                    bad = True
                # MLA3 (registry totals_checked): roster.check also passes a
                # total whose rows it cannot read, a code or a number unset
                # (the Hammerhead Robot's I, printed 15, with upper_shift_zero
                # off: check health and karma None, ok true), so each Health
                # and Karma must have been held to its rows
                if book.get('totals_checked') and k not in explained and (b.get('check') or {}).get(k) is None:
                    lines.append('  %s NOT CHECKED, A ROW UNREAD: %s %s p.%s' % (k.upper(), e['header'], e['part'], b['page']))
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
            # MX3 (registry override_values): an override's printed values are
            # the block's as read. roster.apply_overrides matches a block by
            # page and header alone, so a grid the parse leaves unread (Gilda
            # Ginsel's, printed 6, with unread_codes off) passed on the override
            # that explains its totals, and its Health was no number
            for x in ([o] + o.get('also', [])) if book.get('override_values') and o else ():
                f, want = x.get('field'), x.get('printed')
                if f in ('health', 'karma'):
                    got = (b.get(f) or '').strip()
                    same = got == str(want)
                elif f in roster.ABILITIES:
                    a = b['abilities'][roster.ABILITIES.index(f)]
                    got = '%s %s' % (a.get('printed_code'), a.get('number'))
                    same = isinstance(want, dict) and a.get('number') == want.get('number') \
                        and (a.get('printed_code') or '').upper() == str(want.get('code')).upper()
                else:
                    continue
                if not same:
                    lines.append('  OVERRIDE PRINTED IS NOT THE BLOCK AS READ: %s %s p.%s %s: %r for %r'
                                 % (e['header'], e['part'], b['page'], f, got, want))
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
