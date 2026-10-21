# -*- coding: utf-8 -*-
"""Parse a Marvel module whose cards are on its cover's inside panels (MH1).

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


def letter_row(text):
    """The row of letters over a one-line grid: seven short marks, F A . E R
    . P (Tesseract reads S as "iS)" or "Ss" and I as "|" or "Jt")."""
    t = text.split()
    return len(t) == 7 and all(len(x) <= 3 for x in t) and (t[0], t[1], t[3], t[4], t[6]) == ('F', 'A', 'E', 'R', 'P')


def offsets(book):
    """The parts with a panel's offset filled in: a panel is read as page 1 of
    itself, and its lines lose that page again in stream()."""
    return dict(book, parts=[dict(p, offset=p['pdf'][0] - 1) if p['offset'] is None else p for p in book['parts']])


def stream(book, slug, part, first, last, split_at_rules):
    """booklet.stream_of's lines, without its fused-run mending, with each
    header set on two lines joined into one, and with the registry's
    drop_above applied. A panel's lines carry printed None."""
    panel = next(p for p in book['parts'] if p['name'] == part)['offset'] is None
    orig = booklet.mend_fused
    booklet.mend_fused = lambda _book, _slug, lines: lines
    try:
        lines = booklet.stream_of(offsets(book), slug, part, first, last, split_at_rules)
    finally:
        booklet.mend_fused = orig
    cuts = {(p, page): y for p, page, y in book.get('drop_above', [])}
    out = []
    for l in lines:
        if panel:
            l['printed'] = None
        if l['y1'] <= cuts.get((part, l['printed']), -1):
            continue
        prev = out[-1] if out else None
        # a name with no trademark sign yet goes on ("LOCKHEED" / "RS-150" /
        # "BLACKBIRD(tm)"): the next line, in capitals set as tall, is its rest
        if prev and booklet.is_header(prev) and not booklet.TRADEMARK.search(prev['text']) \
                and roster.is_caps(l['text']) and l['h'] >= 1.1 * l['body_h'] \
                and (prev['pdf'], prev['band'], prev['col']) == (l['pdf'], l['band'], l['col']) and l['y0'] - prev['y1'] < prev['h']:
            out[-1] = dict(prev, text=prev['text'] + ' ' + l['text'], y1=l['y1'])
            continue
        out.append(l)
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


def cards(book, slug, part, first, last, ranks, reader):
    """The entries of one card range: a header, its block, its text."""
    lines = stream(book, slug, part, first, last, split_at_rules=True)
    entries, cur = [], None
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
            wrapped_alternates(block, lines[i:nxt], ranks)
            block['check'] = booklet.block_check(block)
            cur['blocks'].append(block)
            cur['_sec'] = 'after-grid'
            i = nxt
            continue
        if booklet.is_header(line):
            cur = {'kind': 'entry', 'header': booklet.clean_name(text), 'part': part,
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
            pm = booklet.POWER_HEAD.match(text)
            prev = lines[i - 1]['text'].rstrip() if i else ''
            if pm and (not cur['powers'] or prev.endswith(('.', ':', ')', '"', '\u201d', '!'))):
                cur['powers'].append({'name': booklet.power_name(pm.group(1)), 'text': []})
                text = pm.group(2)
            sink = cur['powers'][-1]['text'] if cur['powers'] else cur['sections']['powers']
        elif sec in ('talents', 'background'):
            sink = cur['sections'][sec]
        else:
            sink = cur['prose']
        sink.append(text)
        i += 1
    for e in entries:
        for b in e['blocks']:
            b['part'] = part
    return entries


def opponents(book, slug, part, page, ranks):
    """The one-line grids on one chapter page, each an entry of its own."""
    lines = stream(book, slug, part, page, page, split_at_rules=False)
    short = {v[0].upper(): v for v in ranks.values()}
    entries = []
    for i, line in enumerate(lines):
        if not letter_row(line['text']) or i + 1 >= len(lines):
            continue
        # the name: the nearest line above in capitals before a colon, or all
        # capitals; the lines between are its description ("GIANT: a large
        # humanoid ...", wrapped)
        head = None
        for j in range(i - 1, max(-1, i - 5), -1):
            m = re.match(r"^([A-Z][A-Z .'-]+[A-Z])(?::\s*(.*))?$", lines[j]['text'].strip())
            if m and lines[j]['col'] == line['col'] and (m.group(2) is not None or roster.is_caps(lines[j]['text'])):
                head = (j, m.group(1), m.group(2))
                break
        if head is None:
            raise SystemExit('%s: a one-line grid with no name above it, %s p.%d' % (slug, part, page))
        j, name, desc = head
        letters = sorted(line['words'], key=lambda w: w['x'])
        xs = [w['x'] + w['w'] / 2 for w in letters]
        if len(xs) != 7:
            raise SystemExit('%s: %s p.%d: %d letters in the grid row, not 7' % (slug, name, page, len(xs)))
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
        # the text: the Powers: or Special: line and the paragraph it opens,
        # or the paragraph right under the grid; it ends at a paragraph break
        pitch = statistics.median(b['y0'] - a['y0'] for a, b in zip(lines, lines[1:]) if 0 < b['y0'] - a['y0'] < 60)
        text, last = [], lines[k - 1]
        while k < len(lines) and lines[k]['col'] == line['col'] and lines[k]['y0'] - last['y0'] < 1.3 * pitch \
                and not letter_row(lines[k]['text']):
            text.append(lines[k]['text'])
            last = lines[k]
            k += 1
        sections, prose = {}, [desc] if desc else []
        prose += [lines[x]['text'] for x in range(j + 1, i)]
        m = re.match(r'^(Powers|Special)\s*:\s*(.*)$', text[0]) if text else None
        if m:
            sections[m.group(1).lower()] = booklet.quotes(roster.join_text([m.group(2)] + text[1:]))
        else:
            prose += text
        entries.append({'kind': 'opponent', 'header': name, 'part': part, 'pages': [page], 'identity': [],
                        'blocks': [block], 'sections': sections, 'powers': [], 'members': [],
                        'prose': prose, '_sec': None})
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
    for o in book['opponents']:
        entries += opponents(book, slug, o['part'], o['page'], ranks)
    for e in entries:
        e.pop('_sec', None)
        for p in e['powers']:
            p['text'] = booklet.quotes(roster.join_text(p['text']))
        e['sections'] = {k: booklet.quotes(roster.join_text(v)) if isinstance(v, list) else v for k, v in e['sections'].items()}
        e['prose'] = booklet.quotes(roster.join_text(e['prose']))
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
    no_health = {roster.norm(n) for n in book.get('no_health', [])}
    for e in entries:
        for b in e['blocks']:
            h = roster.as_int(b['health'].split('[')[0]) if b['health'] else None
            if (h is None) != (b.get('kind') == 'line' and roster.norm(e['header']) in no_health):
                lines.append('  HEALTH %r: %s' % (b['health'], e['header']))
                bad = True
    full = sum(1 for e in entries for b in e['blocks'] if b.get('kind') != 'line')
    line = sum(1 for e in entries for b in e['blocks'] if b.get('kind') == 'line')
    if (full, line) != (len(card_names), len(opp_names)):
        lines.append('  BLOCKS: %d full and %d one-line, the checklist has %d and %d' % (full, line, len(card_names), len(opp_names)))
        bad = True
    lines.insert(0, '  checklist: %d cards, %d opponents; %d full blocks, %d one-line grids; all found: %s'
                 % (len(card_names), len(opp_names), full, line, 'no' if bad else 'yes'))
    return lines, bad
