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
import io, json, os, re, statistics

import roster


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
    for printed in range(first, last + 1):
        pdf = printed + offset
        words, (W, H) = roster.read_words(os.path.join(tsv, 'p%03d.tsv' % pdf))
        body = [w for w in words if w['y'] > 0.10 * H and w['y'] + w['h'] < 0.935 * H
                and '\u2122' not in w['t'] and '\u00ae' not in w['t']]
        if not body:
            continue
        body_h = statistics.median(w['h'] for w in body if any(c.isalpha() for c in w['t']))
        edges = [0] + roster.gutters(body, W, book['columns']) + [W]
        for c in range(book['columns']):
            col = [w for w in body if edges[c] <= w['x'] + w['w'] / 2 < edges[c + 1]]
            lines = [l for l in roster.lines_of(col) if l['conf'] >= 45 and any(ch.isalnum() for ch in l['text'])]
            if not lines:
                continue
            left = sorted(l['x0'] for l in lines)[len(lines) // 10]
            for l in lines:
                l.update(pdf=pdf, printed=printed, part=part, col=c + 1, left=left, body_h=body_h,
                         col_x0=max(0, edges[c] if c else left - 20), col_x1=edges[c + 1], big=False)
                stream.append(l)
    return stream


def mark_headers(stream):
    """Mark the header above each grid. Returns the headers' texts."""
    found = []
    for i, line in enumerate(stream):
        if not roster.ANCHOR.search(line['text']):
            continue
        above, j = [], i - 1
        while j >= 0 and len(above) < 3:
            if not roster.ROW.match(stream[j]['text']):
                above.append(j)
            j -= 1
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


def team_of(book, part, page):
    team = None
    for p, first, name in book['teams']:
        if p == part and first <= page:
            team = name
    return team


def parse(book, slug):
    reader = roster.GridReader(book, slug)
    streams = []
    for r in book['character_ranges']:
        s = stream_of(book, slug, r['part'], r['pages'][0], r['pages'][1])
        streams.append((mark_breaks(book, s, r['part'], mark_headers(s)), False))
    for o in book['opponents']:
        s = stream_of(book, slug, o['part'], o['page'], o['page'])
        mark_headers(s)
        streams.append((s, True))
    stream, entries = [], []
    for s, opponent in streams:
        stream += s
        got = roster.read_entries(s, reader, opponent=opponent)
        for e in got:
            e['part'] = s[0]['part']
            e['team'] = team_of(book, e['part'], e['pages'][0])
            for b in e['blocks']:
                b['part'] = e['part']
        entries += got
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
    summary_entries(book, entries)
    return stream, entries


def match(name, entries):
    n = roster.norm(name)
    hits = [e for e in entries if e['blocks'] and base(e['header']) == n]
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
    chart's row as printed (kind 'summary')."""
    s = book['reference_summary']
    for name, values, health, karma, powers in s['heroes']:
        e = match(name, entries)
        if e:
            e['name'] = name
            continue
        block = {'label': None, 'kind': 'summary', 'page': None, 'part': s['part'], 'abilities': summary_abilities(values),
                 'health': str(health), 'karma': str(karma), 'resources': None, 'popularity': None}
        block['check'] = roster.check(block)
        entries.append({'kind': 'summary', 'header': name, 'name': name, 'part': s['part'], 'team': s['team'], 'pages': [],
                        'identity': [], 'blocks': [block], 'sections': {}, 'members': [], 'prose': '',
                        'powers': [{'name': p, 'text': ''} for p in powers]})


def coverage(book, entries, overrides):
    """Every checklist name is an entry and every statted entry is on a
    checklist; each Summary row agrees with its block, or its misprint is
    recorded. Returns the lines to print and whether anything failed."""
    lines, bad = [], False
    contents = [sub for section, sub, _page, _part in book['sections'] if section in book['roster_sections'] and sub]
    opponents = [n for o in book['opponents'] for n in o['names']]
    listed = contents + opponents + book.get('tiers', [])
    for n in listed:
        if not match(n, entries):
            lines.append('  CHECKLIST NAME WITH NO ENTRY: %s' % n)
            bad = True
    known = {roster.norm(n) for n in listed} | {roster.norm(r[0]) for r in book['reference_summary']['heroes']}
    for e in entries:
        if e['blocks'] and e['kind'] != 'summary' and base(e['header']) not in known:
            lines.append('  STATTED ENTRY ON NO CHECKLIST: %s (%s p.%s)' % (e['header'], e['part'], e['pages'][0]))
            bad = True
    # roster.check() passes a Health or Karma it cannot read as a number, which
    # is right for MA1's robots ("Karma = -") and wrong here: ME1 prints a
    # number for every one, so anything else is OCR ('330 k' was, once)
    for e in entries:
        for b in e['blocks']:
            for k in ('health', 'karma'):
                if roster.as_int((b[k] or '').replace(',', '')) is None:
                    lines.append('  %s IS NOT A NUMBER: %s %s p.%s: %r' % (k.upper(), e['header'], e['part'], b['page'], b[k]))
                    bad = True
    marked = {(o['match']['summary'], o['field']): o for o in overrides if 'summary' in o['match']}
    used = set()
    rows = book['reference_summary']['heroes']
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
                    sum(1 for e in entries if e['kind'] == 'summary'), len(used)))
    return lines, bad
