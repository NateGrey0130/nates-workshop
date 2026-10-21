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
    for p, first, name in book.get('teams', []):
        if p == part and first <= page:
            team = name
    return team


def place_headers(book, stream):
    """A header Tesseract did not read at all (ME2's BALDER, YMIR and GAL: in
    neither the TSV nor the text) is placed above its grid from the registry's
    `grid_headers`, each naming its grid by booklet, printed page and Health.
    Read off the page images; nothing but the grid sits under each."""
    for g in book.get('grid_headers', []):
        at = [i for i, l in enumerate(stream) if l['part'] == g['part'] and l['printed'] == g['page']
              and re.search(r'Heal?th' + roster.EQ + r'?\s*%d\b' % g['health'], l['text'])]
        if not at:
            continue                    # another range's page
        if len(at) != 1:
            raise SystemExit('grid_headers: %s p.%d Health %d is on %d lines, not 1' % (g['part'], g['page'], g['health'], len(at)))
        line = stream[at[0]]
        stream.insert(at[0], dict(line, text=g['name'], big=True, conf=100, y0=line['y0'] - 50, y1=line['y0'] - 8))
    return stream


# ME2's one-line grids: the seven letters, a row of numbers (or none: Beta
# Ray Bill's humanoid form prints codes only), a row of codes, then Health and
# Karma on lines of their own or one ("Health: 80 Karma: 100").
LETTERS = re.compile(r'^F\s+A\s+\S{1,2}\s+E\s+R\s+\S{1,2}\s+P$')
HEALTH_LINE = re.compile(r'^Heal?th:\s*(\S+)(?:\s+Karma:\s*(\S+))?$')
KARMA_LINE = re.compile(r'^Karma:\s*(\S+)$')
# a bare X, Y or Z under a number is Shift X, Y or Z (Actus, printed 16)
SHIFT = {'X': 'ShX', 'Y': 'ShY', 'Z': 'ShZ'}


def line_codes(text, spill):
    """The codes row as seven codes. A Class rank set on two lines ("Cl" over
    "1000") takes its number from the line below (`spill`); two Shift codes run
    together ("ZZ") are two codes."""
    tokens, out = text.split(), []
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


def read_line_grid(stream, i):
    """The one-line grid whose letters are stream[i]: (rows, Health, Karma,
    the index after it), or None. Every line is in one column of one page."""
    same = lambda j: j < len(stream) and stream[j]['pdf'] == stream[i]['pdf'] and stream[j]['col'] == stream[i]['col']
    h = next((j for j in range(i + 1, i + 6) if same(j) and HEALTH_LINE.match(stream[j]['text'].strip())), None)
    if h is None:
        return None
    m = HEALTH_LINE.match(stream[h]['text'].strip())
    health, karma, end = m.group(1), m.group(2), h + 1
    if karma is None and same(h + 1) and KARMA_LINE.match(stream[h + 1]['text'].strip()):
        karma, end = KARMA_LINE.match(stream[h + 1]['text'].strip()).group(1), h + 2
    texts = [stream[j]['text'].strip() for j in range(i + 1, h)]
    numbers = None
    if texts and all(re.search(r'\d', t) for t in texts[0].split()):
        # a mark OCR hangs on a number ('�50', Charon's P) is not a digit
        numbers = [roster.fix_digits(re.sub(r'[^0-9OolI]', '', t)) for t in texts.pop(0).split()]
    spill = [t for x in texts[1:] for t in x.split() if re.fullmatch(r'\d{4}', t)]
    codes = line_codes(texts[0], spill) if texts else []
    canon = [SHIFT.get(c) or roster.canon(c) for c in codes]
    if len(canon) != 7 or None in canon or (numbers is not None and len(numbers) != 7) or spill:
        raise SystemExit('a one-line grid read wrong, %s p.%d: %r' % (stream[i]['part'], stream[i]['printed'], texts))
    rows = [{'letter': roster.ABILITIES[n], 'number': numbers[n] if numbers else roster.RANK_NUMBER[c],
             'code': c, 'printed_code': codes[n], 'rest': ''} for n, c in enumerate(canon)]
    return rows, health, karma, end


def line_grids(book, stream, keyed, labelled):
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
    out, i = [], 0
    while i < len(stream):
        l = stream[i]
        key = (l['part'], l['printed'])
        got = read_line_grid(stream, i) if want.get(key) and LETTERS.match(l['text'].strip()) else None
        if not got:
            out.append(l)
            i += 1
            continue
        rows, health, karma, end = got
        g = want[key].pop(0)
        rank_only = not re.search(r'\d', stream[i + 1]['text'])
        if g.get('name'):
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
            block['check'] = roster.check(block)
            labelled.append((g, block))
        i = end
    left = [g for gs in want.values() for g in gs if (g['part'], g['page']) in pages]
    if left:
        raise SystemExit('one_line_grids not found: %s' % ', '.join(g.get('name') or g['label'] for g in left))
    return out


def grid(stream, i, reader):
    line = stream[i]
    if line.get('line_grid'):
        return line['line_grid'], i + 1
    return roster.grid_at(stream, i, reader)


def parse(book, slug):
    reader = roster.GridReader(book, slug)
    streams, keyed, labelled = [], {}, []
    for r in book['character_ranges']:
        s = stream_of(book, slug, r['part'], r['pages'][0], r['pages'][1])
        s = line_grids(book, place_headers(book, s), keyed, labelled)
        streams.append((mark_breaks(book, s, r['part'], mark_headers(s)), False))
    for o in book['opponents']:
        s = stream_of(book, slug, o['part'], o['page'], o['page'])
        s = line_grids(book, place_headers(book, s), keyed, labelled)
        mark_headers(s)
        streams.append((s, True))
    stream, entries = [], []
    for s, opponent in streams:
        stream += s
        got = roster.read_entries(s, reader, opponent=opponent, grid=grid)
        for e in got:
            e['part'] = s[0]['part']
            e['team'] = team_of(book, e['part'], e['pages'][0])
            for b in e['blocks']:
                b['part'] = e['part']
                key = (b['pdf'], b['col'], b['health'])
                if key in keyed:
                    b['kind'] = 'line'
                    if keyed[key]:
                        b['rank_only'] = True
            # Death's "Health: 20,000" (ME2, Resource p.2): check() reads no comma
            for b in e['blocks']:
                if ',' in (b['health'] or '') and b['check'].get('health') is None:
                    b['check'] = roster.check(dict(b, health=b['health'].replace(',', '')))
        entries += got
    for g, block in labelled:
        hits = [e for e in entries if e['part'] == g['part'] and base(e['header']) == roster.norm(g['entry'])]
        if len(hits) != 1:
            raise SystemExit('one_line_grids: %s names %d entries, not 1' % (g['entry'], len(hits)))
        block['part'] = g['part']
        hits[0]['blocks'].append(block)
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
        entries.append({'kind': 'summary', 'header': name, 'name': name, 'part': s['part'], 'team': s.get('team'), 'pages': [],
                        'identity': [], 'blocks': [block], 'sections': {}, 'members': [], 'prose': '',
                        'powers': [{'name': p, 'text': ''} for p in powers]})


def coverage(book, entries, overrides):
    """Every checklist name is an entry and every statted entry is on a
    checklist; each Summary row agrees with its block, or its misprint is
    recorded. Returns the lines to print and whether anything failed."""
    lines, bad = [], False
    where = [(sub, part, None) for section, sub, _page, part in book['sections'] if section in book['roster_sections'] and sub]
    contents = [w[0] for w in where]
    where += [(n, o['part'], o['page']) for o in book['opponents'] for n in o['names']]
    opponents = [n for o in book['opponents'] for n in o['names']]
    listed = contents + opponents + book.get('tiers', [])
    for n, part, page in where + [(t, None, None) for t in book.get('tiers', [])]:
        if not match(n, entries, part, page):
            lines.append('  CHECKLIST NAME WITH NO ENTRY: %s' % n)
            bad = True
    known = {f for n in listed for f in forms(n)} | {roster.norm(r[0]) for r in book['reference_summary']['heroes']}
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
