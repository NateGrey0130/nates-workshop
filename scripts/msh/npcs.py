# -*- coding: utf-8 -*-
"""Build the Marvel codex's Notable NPCs from a parsed sourcebook.

    python scripts/msh/npcs.py ma1

Reads $WORKSHOP_MSH_CACHE/books/<slug>/roster.json (scripts/msh/roster.py) and
writes two things, split by what may be committed:

  apps/marvel-heroes/data/npcs.json            FACTS ONLY, committed: names,
      identity lines, every stat block's numbers and rank codes, Health, Karma,
      Resources and Popularity as printed, power and member NAMES, pages, and
      each misprint's printed and corrected value (scripts/msh/<slug>-overrides.json).
  $WORKSHOP_MSH_CACHE/books/<slug>/book-text.sql   THE PROSE, never committed:
      one msh_book_text row (migration 087) per power, section, member and
      cross-reference, applied with
          node scripts/d1-apply.mjs --remote --db marvel <that file>

ONE FILE, EVERY BOOK. npcs.json holds every book's characters, each with its
`book`; this replaces the named book's and keeps the rest. The registry's
first book keeps plain ids, and every later book's end in -<slug>, so the same
character in two books is two cards whose ids never collide or depend on
build order. Append books to scripts/msh/books.json; never reorder them.

HOW ENTRIES BECOME CHARACTERS. A character is one printed name; its versions
are the printed entries under that name, each with its own stat blocks
(scripts/msh/roster.py keeps an entry's forms and tiers - HUMAN FORM, BROOD
QUEEN - as labelled blocks of one entry). So:
  - two entries with blocks under one name, parenthetical aside, are one
    character with two versions: PHOENIX (original) and (Current),
    THUNDERBIRD (original) and (current).
  - an entry with no block whose name is a character's is a CROSS-REFERENCE
    (Blob and Magneto on p.30, Rogue p.34, Warlock p.38): it becomes an
    appearance on that character, and its text - the early-version modifiers
    for Magneto, Quicksilver and the Scarlet Witch - goes to D1 as its prose.
    No block is derived from it (survey decision 4).
  - a member without a block (AMPHIBUS: under the Savage Land Mutates) is
    listed by name and page under its team's entry, with its text in D1. No
    stats are invented for it (survey decision 2).
  - a second, unlabelled block inside an entry (S'ym in Magik's) is labelled
    "Additional statistics" with its page (survey decision 3).
An entry with no block and no character of its name is a team heading or
background, and is not a Notable NPC.

A power is linked to the Ultimate Powers Book when its name is a UPB power's
name, or is in apps/marvel-heroes/data/npc-power-aliases.json. Everything else
stays a book-only power.
"""
import io, json, os, re, sys, unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = os.environ.get('WORKSHOP_MSH_CACHE') or os.path.join(ROOT, '.cache', 'msh')
DATA = os.path.join(ROOT, 'apps', 'marvel-heroes', 'data')
REGISTRY = os.path.join(ROOT, 'scripts', 'msh', 'books.json')

FOLD = {'\u2018': "'", '\u2019': "'", '\u201c': '"', '\u201d': '"', '\u2013': '-', '\u2014': ' - ',
        '\u2026': '...', '\u00a0': ' ', '\ufffd': "'", '\u00ad': '',
        '\u2122': ''}  # a trademark sign after a name: NFKD would spell it TM


LQ, RQ, LS, RS = chr(0x201c), chr(0x201d), chr(0x2018), chr(0x2019)


def pair_quotes(s):
    """Tesseract reads a printed double quote as a single one (MA1 printed 20
    "greatest fear" as a curly double open and a single close), as two single
    ones (printed 66 "the Creator,"), as a double with a thin single beside it
    (printed 25 "lifeglow"), or reads a speck or a trademark sign as one
    (printed 41, 36). A single mark beside a double joins it, then each mark is
    decided by where it sits: a single quote becomes double when it is the
    other end of a double quote, and a double quote that closes nothing or
    stands alone is dropped. A mark inside a word or after a digit (6'2") is
    an apostrophe or a measure and is left alone."""
    sing = LS + RS + "'"
    s = re.sub('[%s]+(?=[%s%s"])' % (sing, LQ, RQ), '', s)
    s = re.sub('(?<=[%s%s"])[%s](?!s(?![a-z]))' % (LQ, RQ, sing), '', s)
    s = re.sub('(?<=[a-z])[%s]{2,}(?=[a-z])' % sing, "'", s)
    s = s.replace(LS * 2, LQ).replace(RS * 2, RQ)
    marks = []
    for m in re.finditer('[%s%s%s%s"]' % (LQ, RQ, LS, RS), s):
        i, ch = m.start(), m.group()
        before = s[i - 1] if i else ' '
        after = s[i + 1] if i + 1 < len(s) else ' '
        left, right = before.isspace() or before in '([', after.isspace() or after in ')]'
        if before.isdigit() or not (left or right or after in '.,;:!?'):
            continue
        role = 'alone' if left and right else 'open' if left else 'close'
        marks.append((i, ch in (LQ, RQ, '"'), role))
    fix, inside = {}, False
    for k, (i, double, role) in enumerate(marks):
        later = next((r for _, d, r in marks[k + 1:] if d and r != 'alone'), None)
        if double and role == 'alone':
            fix[i] = ''
        elif double and role == 'open':
            inside = True
        elif double:
            if not inside:
                fix[i] = ''
            inside = False
        elif role == 'open' and not inside and later == 'close':
            fix[i], inside = LQ, True
        elif role == 'close' and inside and later != 'close':
            fix[i], inside = RQ, False
    if not fix:
        return s
    out = ''.join(fix.get(i, ch) for i, ch in enumerate(s))
    return re.sub(' {2,}', ' ', out)


def minus(s):
    """A stat value's minus sign as ME1's OCR gives it, an en or em dash
    ('-5' read as a long dash then 5), is a minus; ascii_fold would spell it ' - '."""
    return re.sub('^[%s%s]\\s*(?=\\d)' % (chr(0x2013), chr(0x2014)), '-', s) if s else s


def ascii_fold(s):
    s = ''.join(FOLD.get(ch, ch) for ch in pair_quotes(s or ''))
    return unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii')


def unpaired(rows, slug):
    """Stop before writing if a row's name or body has an odd number of
    double quotes: pair_quotes() placed every mark it could, so an odd count
    is one it could not, and it stops here rather than in the Codex."""
    # a mark after a digit is a measure, not a quote (5'7", ME1's Alpha
    # Primitives), and pair_quotes() leaves it alone too
    odd = [t for r in rows for t in r[4:] if isinstance(t, str) and re.sub(r'(?<=\d)"', '', t).count('"') % 2]
    if odd:
        t = odd[0]
        raise SystemExit('%s: %d row(s) with an unpaired double quote, e.g. ...%s...'
                         % (slug, len(odd), t[max(0, t.find('"') - 30):t.find('"') + 30]))


def text_fixes(rows, slug):
    """Apply the 'text' verdicts of scripts/msh/<slug>-overrides.json: a mark
    only the page image can settle (MA1 prints real single quotes, so a lost
    closing mark looks like any other). Each names its row and a fragment of
    a few words; it must be found exactly once, or the build stops, because a
    fix that no longer finds its text must not pass quietly."""
    path = os.path.join(ROOT, 'scripts', 'msh', '%s-overrides.json' % slug)
    fixes = [o for o in (json.load(io.open(path, encoding='utf-8'))['overrides'] if os.path.exists(path) else [])
             if o['verdict'] == 'text']
    at = {r[0]: i for i, r in enumerate(rows)}
    missed = []
    for o in fixes:
        i = at.get(o['match']['row'])
        if i is None or rows[i][6].count(o['read']) != 1:
            missed.append(o['match']['row'])
            continue
        r = rows[i]
        rows[i] = r[:6] + (r[6].replace(o['read'], o['printed']),)
    if missed:
        raise SystemExit('%s: %d text override(s) found no single match: %s' % (slug, len(missed), ', '.join(missed)))


def norm(s):
    return re.sub(r'[^a-z0-9]+', ' ', (s or '').lower()).strip()


def slug(s):
    return norm(s).replace(' ', '-')


def roman(header):
    """OCR sets a header's Roman numerals in whatever looks like an I: MARK |
    SENTINEL, MARK Ill SENTINELS, PHASE | LIVING MONOLITH. A token made only of
    those shapes, three at most, is the numeral."""
    return re.sub(r'(?<![\w|])[Il|]{1,3}(?![\w|])', lambda m: 'I' * len(m.group(0)), header or '')


def base_name(header):
    return re.sub(r'\s*\([^)]*\)\s*', ' ', roman(header)).strip()


def variant(header):
    m = re.search(r'\(([^)]*)\)', header or '')
    return m.group(1).strip() if m else None


# II to XXXIX, and V, X: a lone I is left to the word rule, which keeps it I
ROMAN = re.compile(r'(?=[IVX]{2}|[VX]$)X{0,3}(IX|IV|V?I{0,3})')
TITLE_SMALL = {'of', 'the', 'and', 'a', 'an', 'in', 'on', 'to', 'with', 'for'}


def title_case(s):
    """MARVEL GIRL -> Marvel Girl, SHI'AR -> Shi'ar, X-FACTOR -> X-Factor, keeping
    Mr./Dr. and any parenthetical as printed. A Roman numeral stays one (MARK IV
    SENTINEL -> Mark IV Sentinel), and a small word after the first is small
    (MOON-BOY AND DEVIL DINOSAUR -> Moon-Boy and Devil Dinosaur)."""
    def word(w, first):
        if not any(c.isalpha() for c in w) or not w.isupper():
            return w
        if ROMAN.fullmatch(w):
            return w
        if not first and w.lower() in TITLE_SMALL:
            return w.lower()
        return '-'.join(p[:1] + p[1:].lower() for p in w.split('-'))
    out, depth, first = [], 0, True
    for tok in re.split(r'(\s+|\(|\))', s):
        if tok == '(':
            depth += 1
        elif tok == ')':
            depth -= 1
        if depth or tok in ('(', ')') or not tok.strip():
            out.append(tok)
        else:
            out.append(word(tok, first))
            first = False
    return ''.join(out)


# PB p.2 read backwards: the code a rank's number stands for. Used only where the
# OCR could not read the printed code ("R 20 x"); the block then lists the
# letter under `derived`, so nobody mistakes it for a code read off the page.
CODE_OF = {2: 'Fe', 4: 'Pr', 6: 'Ty', 10: 'Gd', 20: 'Ex', 30: 'Rm', 40: 'In', 50: 'Am', 75: 'Mn', 100: 'Un',
           150: 'ShX', 200: 'ShY', 500: 'ShZ', 1000: 'C-1000', 3000: 'C-3000', 5000: 'C-5000'}


def section_at(book, page):
    fixed = {e['section']: e['page'] for e in book.get('contents_errata', [])}
    best = None
    for section, sub, p in book['sections']:
        start = fixed.get(sub or section, p)
        if start <= page and (best is None or start >= best[0]):
            best = (start, sub or section)
    return best[1] if best else None


def part_cite(book, name):
    """How a card names one of a module's booklets (registry parts[].cite)."""
    return next(p['cite'] for p in book['parts'] if p['name'] == name)


def ranges(book):
    """A grid-booklets book's character pages, per booklet in the order they
    are read: [{part (its cite), pages: [[first, last], ...]}]. The opponents'
    chapter pages count as one span, first to last."""
    out = {}
    for r in book['character_ranges']:
        out.setdefault(r['part'], []).append(list(r['pages']))
    opp = {}
    for o in book.get('opponents', []):
        opp.setdefault(o['part'], []).append(o['page'])
    for part, pages in opp.items():
        out.setdefault(part, []).append([min(pages), max(pages)])
    return [{'part': part_cite(book, p), 'pages': sorted(spans)} for p, spans in out.items()]


def main(slug_arg):
    registry = json.load(io.open(REGISTRY, encoding='utf-8'))['books']
    book = registry[slug_arg]
    # The registry's first book keeps plain ids; every later book's end in
    # -<slug>, so two books' Magnetos are two cards (Nate, 2026-09-28) whose ids
    # never collide and never depend on which book was built first.
    sfx = '' if next(iter(registry)) == slug_arg else '-' + slug_arg

    def ident(s):
        return slug(s) + sfx

    def team_of(page):
        # a book laid out A-Z has no team sections: its characters file under it
        return section_at(book, page) or book['title']

    # A boxed module's Roster Booklet (MHSP1, scripts/msh/booklet.py) has no
    # team sections and two numberings, so what MA1 reads off the page it
    # reads off the entry (Nate, 2026-09-28):
    #   - a character's team is its side in the Reference Summary, named for
    #     the book so it does not share a filter with MA1's Villains; the
    #     Wrecking Crew's four are that team, and keep the side as `side`
    #   - every version and block carries the booklet it is printed in (`part`,
    #     the registry's cite), because p.4 is in both booklets
    #   - the seven characters only the Summary gives are `summary_only`
    #   - its numbers are the ranks' standard values (`rank_only`)
    #   - an alter ego's one-line block is a form of the character
    #
    # A grid-booklets book (ME1, scripts/msh/gridbooks.py) is read the same
    # way, with three differences: it has no sides, its entries carry their
    # team (the registry's `teams`), and a header's parenthesis is kept as the
    # version's label ("Update", "Blue or Pink").
    grid = book.get('layout') == 'grid-booklets'
    booklet = book.get('layout') == 'roster-booklet' or grid
    cite = {p['name']: p['cite'] for p in book.get('parts', [])}
    SIDE = {'heroes': '%s Heroes' % book['title'].split(' ', 1)[-1], 'villains': '%s Villains' % book['title'].split(' ', 1)[-1]}
    tiers = set(book.get('one_line_tiers', []))

    def team_of_entry(e):
        # a header's capitals (WRECKING CREW) are cased; a registry team is as written
        return (title_case(e['team']) if e['team'].isupper() else e['team']) if e.get('team') else SIDE[e['side']]

    def name_of(e):
        return e.get('name') or title_case(base_name(e['header']))

    roster = json.load(io.open(os.path.join(CACHE, 'books', slug_arg, 'roster.json'), encoding='utf-8'))
    powers = json.load(io.open(os.path.join(DATA, 'powers.json'), encoding='utf-8'))['powers']
    rank_abbr = {r['id']: r['abbr'] for r in json.load(io.open(os.path.join(DATA, 'ranks.json'), encoding='utf-8'))['ranks']}
    aliases = json.load(io.open(os.path.join(DATA, 'npc-power-aliases.json'), encoding='utf-8'))['aliases']
    upb = {norm(p['name']): p['code'] for p in powers}
    upb.update({norm(k): v for k, v in aliases.items()})
    index_case = {}
    for name, _p in book.get('index', []):
        index_case[norm(name)] = name

    def display(header):
        b = base_name(header)
        return index_case.get(norm(b)) or title_case(b)

    entries = roster['entries']
    statted = [e for e in entries if e['blocks']]
    by_name = {}
    for e in statted:
        by_name.setdefault(norm(name_of(e) if booklet else base_name(e['header'])), []).append(e)

    chars, rows = [], []

    def text_row(entry_slug, part, n, name, page, body):
        body = ascii_fold(body).strip()
        if not body:
            return
        key = '%s:%s:%s%s' % (slug_arg, entry_slug, part, '' if n is None else ':%d' % n)
        rows.append((key, slug_arg, entry_slug, part, ascii_fold(name) if name else None, page, body))

    for name_key, group in by_name.items():
        versions = []
        for e in group:
            eslug = ident(name_of(e)) if booklet else ident(roman(e['header']))
            # an alter ego's one-line block makes every block of the entry a
            # form (She-Hulk and Jennifer Walters); Klaw's sound creatures are
            # beings of their own, a tier (registry one_line_tiers)
            forms = booklet and any(b.get('kind') == 'line' and b['label'] not in tiers for b in e['blocks'])
            blocks = []
            for n, b in enumerate(e['blocks']):
                label = b['label']
                # the main block of an entry with more than one is named for
                # the character, so the GM picks "Klaw", not "Klaw - block 1"
                if booklet and not label and len(e['blocks']) > 1 and n == 0:
                    label = name_of(e)
                if not label and n:
                    label = 'Additional statistics, p.%d' % b['page']
                abilities, derived = [], []
                for i, a in enumerate(b['abilities']):
                    code, number = a['code'], a['number']
                    o = b.get('override') or {}
                    if number is None and 'FASERIP'[i] in (o.get('field') or '') and isinstance(o.get('corrected'), dict):
                        # printed as no rank at all (Lockheed's "?" Reason; ME1's Oolafat's
                        # R, I and P, field "RIP"): played as the override says
                        number, code = o['corrected']['number'], o['corrected']['code']
                    if code is None and number in CODE_OF:
                        code = CODE_OF[number]
                        derived.append('FASERIP'[i])
                    abilities.append(['FASERIP'[i], number, code]
                                     + ([[a['alt']['number'], a['alt']['code']]] if a.get('alt') else []))
                blocks.append({
                    'label': (title_case(roman(label)) if not booklet else label) if label else None,
                    'page': b['page'],
                    **({'part': cite[b['part']]} if booklet and b.get('part') != e['part'] else {}),
                    'abilities': abilities,
                    **({'derived': derived} if derived else {}),
                    **({'rank_only': True} if b.get('rank_only') else {}),
                    **({'form': True} if forms else {}),
                    # a value the book does not print is null, not an empty
                    # string, in a roster booklet (the Summary gives no
                    # Resources or Popularity); MA1's file is kept as it was
                    **{k: (None if booklet and b[k] is None else ascii_fold(minus(b[k]) if grid else b[k]))
                       for k in ('health', 'karma', 'resources', 'popularity')},
                    **({'override': b['override']} if b.get('override') else {}),
                    **({'kind': b['kind']} if b.get('kind') else {}),
                })
            pw = []
            # a Summary-only character has no page; its running note has its own
            page0 = e['pages'][0] if e['pages'] else None
            for n, p in enumerate(e['powers'], 1):
                pname, prank = p['name'], None
                # ME1's chart prints a power with its rank ("Healing-Un",
                # "Flight-Cl 3000"): the name links to the UPB and the rank is the
                # power's, where the suffix is one of the book's rank spellings
                m = re.match(r'^(.+)-([A-Za-z0-9 ]+)$', pname) if grid and e['kind'] == 'summary' else None
                if m and m.group(2) in book['rank_aliases']:
                    pname, prank = m.group(1), rank_abbr[book['rank_aliases'][m.group(2)]]
                code = upb.get(norm(pname))
                pw.append({'name': ascii_fold(pname), **({'rank': prank} if prank else {}), **({'upb': code} if code else {})})
                text_row(eslug, 'power', n, pname, page0, p['text'])
            for part in ('talents', 'contacts', 'running', 'background', 'notes'):
                text_row(eslug, part, None, None, e['running']['page'] if part == 'running' and e.get('running') else page0,
                         e['sections'].get(part, ''))
            if e['sections'].get('powers'):
                text_row(eslug, 'powers-intro', None, None, page0, e['sections']['powers'])
            # A header's identity is its name and status lines: one or two short
            # lines. Three is the parser's cap, reached when a team's opening
            # paragraph follows its header ("The Gladiators was an organization
            # of..."). That is prose, so it goes to D1 and the identity is empty.
            identity = [ascii_fold(x) for x in e['identity']]
            prose = e['prose']
            if len(identity) >= 3:
                prose = ' '.join(e['identity']) + ' ' + prose
                identity = []
            text_row(eslug, 'prose', None, None, page0, prose)
            members = []
            for n, m in enumerate(e['members'], 1):
                members.append({'name': display(m['name']), 'page': m['page']})
                text_row(eslug, 'member', n, display(m['name']), m['page'], m['text'])
            versions.append({
                'id': eslug, 'label': variant(e['header']) if grid or not booklet else None,
                'team': team_of_entry(e) if booklet else team_of(e['pages'][0]),
                **({'side': SIDE[e['side']]} if booklet and e.get('side') else {}),
                **({'part': cite[e['part']]} if booklet else {}),
                'pages': e['pages'], 'identity': identity,
                'blocks': blocks, 'powers': pw, 'members': members,
                'text': sorted({r[3] for r in rows if r[2] == eslug}),
            })
        cid = ident(name_of(group[0])) if booklet else ident(base_name(group[0]['header']))
        chars.append({'id': cid, 'name': name_of(group[0]) if booklet else display(group[0]['header']),
                      'team': versions[0]['team'],
                      **({'side': versions[0]['side']} if booklet and versions[0].get('side') else {}),
                      **({'summary_only': True} if booklet and group[0]['kind'] == 'summary' else {}),
                      'versions': versions, 'appearances': []})

    # A team the Roster Booklet prints over its members' blocks (the Wrecking
    # Crew): a card with no block of its own, its members linked, and its
    # shared Powers, Talents, Background and running note once, on it.
    for e in (entries if booklet else []):
        if e['kind'] != 'team':
            continue
        tslug = ident(name_of(e))
        mine = [c for c in chars if c['team'] == name_of(e)]
        page0 = e['pages'][0]
        pw = []
        for n, p in enumerate(e['powers'], 1):
            code = upb.get(norm(p['name']))
            pw.append({'name': ascii_fold(p['name']), **({'upb': code} if code else {})})
            text_row(tslug, 'power', n, p['name'], page0, p['text'])
        for part in ('talents', 'running', 'background'):
            text_row(tslug, part, None, None, e['running']['page'] if part == 'running' and e.get('running') else page0,
                     e['sections'].get(part, ''))
        text_row(tslug, 'prose', None, None, page0, e['prose'])
        for c in mine:
            c['member_of'], c['member_of_id'] = name_of(e), tslug
        chars.append({'id': tslug, 'name': name_of(e), 'team': name_of(e), 'side': mine[0]['side'], 'versions': [{
            'id': tslug, 'label': None, 'team': name_of(e), 'side': mine[0]['side'], 'part': cite[e['part']],
            'pages': e['pages'], 'identity': [', '.join(c['name'] for c in mine[:-1]) + ' and ' + mine[-1]['name']],
            'blocks': [], 'powers': pw,
            'members': [{'name': c['name'], 'page': c['versions'][0]['pages'][0], 'id': c['id']} for c in mine],
            'text': sorted({r[3] for r in rows if r[2] == tslug})}], 'appearances': []})

    by_id = {c['id']: c for c in chars}
    for e in entries:
        if e['blocks'] or booklet:
            continue                    # a roster booklet has no cross-references; its team is a card above
        c = by_id.get(ident(base_name(e['header'])))
        if not c:
            continue
        eslug = '%s-p%d' % (c['id'], e['pages'][0])
        text_row(eslug, 'appearance', None, None, e['pages'][0], ' '.join(e['identity']) + ' ' + e['prose'])
        c['appearances'].append({'id': eslug, 'team': team_of(e['pages'][0]), 'page': e['pages'][0]})

    # Team members the book gives no block of their own, given one
    # (scripts/msh/<slug>-members.json): the team's tier block, with the ranks
    # the member's own text states. Where the text prints a Health the build
    # must reproduce it - Barbarus 106, Gaza 96 - or nothing is written.
    mpath = os.path.join(ROOT, 'scripts', 'msh', '%s-members.json' % slug_arg)
    std = {code: n for n, code in CODE_OF.items()}
    for m in (json.load(io.open(mpath, encoding='utf-8'))['members'] if os.path.exists(mpath) else []):
        team_entry = next((e for e in entries if (e['header'] or '').upper() == m['team'].upper()), None)
        team = next((c for c in chars for v in c['versions'] if team_entry and v['id'] == ident(roman(team_entry['header']))), None)
        member = team_entry and next((x for x in team_entry['members'] if x['name'].upper() == m['member'].upper()), None)
        if not team or not member:
            sys.exit('%s-members.json: no member %s under %s' % (slug_arg, m['member'], m['team']))
        if m.get('skip'):
            # a cross-reference: the member links to their own statted entry
            own = by_id.get(ident(display(m['member'])))
            for x in team['versions'][0]['members']:
                if own and x['name'].upper() == display(m['member']).upper():
                    x['id'] = own['id']
            continue
        tier = next((b for v in team['versions'] for b in v['blocks'] if (b['label'] or '').upper() == m['tier'].upper()), None)
        if not tier:
            sys.exit('%s-members.json: %s has no block %s' % (slug_arg, team['name'], m['tier']))
        abilities = [[l, std[m['changes'][l]], m['changes'][l]] if l in m['changes'] else [l, n, c]
                     for l, n, c, *_ in tier['abilities']]
        health = sum(a[1] for a in abilities[:4])
        karma = sum(a[1] for a in abilities[4:])
        if m.get('printed_health') not in (None, health):
            sys.exit('%s: the text prints Health %s and the build gives %d' % (m['member'], m['printed_health'], health))
        name = m.get('name') or display(m['member'])
        cid = ident(name)
        if cid in by_id:
            sys.exit('%s-members.json: %s collides with a character; give it a name' % (slug_arg, name))
        text_row(cid, 'prose', None, None, m['page'], member['text'])
        for x in team['versions'][0]['members']:
            if x['name'].upper() == display(m['member']).upper():
                x['id'] = cid
        c = {'id': cid, 'name': name, 'team': team['team'], 'member_of': team['name'], 'appearances': [], 'versions': [{
            'id': cid, 'label': None, 'team': team['team'], 'pages': [m['page']], 'identity': [],
            'blocks': [{'label': None, 'page': m['page'], 'abilities': abilities,
                        'health': str(health), 'karma': str(karma), 'resources': tier['resources'], 'popularity': tier['popularity'],
                        'built_from': {'tier': tier['label'], 'page': tier['page'], 'changes': m['changes'],
                                       **({'printed_health': m['printed_health']} if 'printed_health' in m else {})}}],
            'powers': [{'name': p, 'rank': r, **({'upb': upb[norm(p)]} if norm(p) in upb else {})} for p, r in m.get('powers', [])],
            'members': [], 'text': ['prose']}]}
        chars.append(c)
        by_id[cid] = c

    for c in chars:
        c['book'] = slug_arg
    # a Summary-only character has no page, and comes after the book's pages
    # a grid-booklets book reads its booklets in order, so they sort that way:
    # the Adventure Book's p.3 before the Resource Book's p.2
    booklet_rank = {p['cite']: n for n, p in enumerate(book.get('parts', []))} if grid else {}
    chars.sort(key=lambda c: (booklet_rank.get(c['versions'][0].get('part'), 0),
                              min(v['pages'][0] if v['pages'] else 10 ** 6 for v in c['versions']), c['name']))

    text_fixes(rows, slug_arg)
    unpaired(rows, slug_arg)
    # EVERY book's characters live in this one file. Rebuilding one book
    # replaces that book's characters and leaves the others as they are.
    path_out = os.path.join(DATA, 'npcs.json')
    old = json.load(io.open(path_out, encoding='utf-8')) if os.path.exists(path_out) else {'characters': []}
    old_book = old.get('book')     # the single-book shape had one book for the whole file
    others = [c for c in old['characters'] if c.get('book', old_book) != slug_arg]
    for c in others:
        c.setdefault('book', old_book)
    order = list(registry)
    chars = sorted(others + chars, key=lambda c: order.index(c['book']))
    ids = [c['id'] for c in chars]
    assert len(ids) == len(set(ids)), 'a character id is in two books'
    present = [b for b in order if any(c['book'] == b for c in chars)]
    teams = []
    for c in chars:
        if c['team'] not in teams:
            teams.append(c['team'])
    out = {
        'about': [
            'Notable NPCs from the Marvel sourcebooks, built by scripts/msh/npcs.py from the parse of each book (scripts/msh/roster.py), one book at a time.',
            'Facts only: numbers, rank codes, names and pages. The book\'s prose is in D1 (msh_book_text, migration 087), keyed <book>:<version id>:<part>, and never in this file.',
            'Every character carries its book. The first book in scripts/msh/books.json keeps plain ids; a later book\'s end in -<slug>, so the same character in two books is two cards.',
            'A character is one printed name; each version is one printed entry, with its stat blocks (forms and tiers are labelled blocks).',
            'abilities: [letter, number, rank code, [alternate number, code]?] - the alternate is the book\'s parenthesised altered value.',
            'health, karma, resources, popularity: as printed. override: a misprint or an as-printed value, read off the page (scripts/msh/<book>-overrides.json).',
            'powers[].upb: the Ultimate Powers Book code, where the name is a UPB power or in npc-power-aliases.json.',
        ],
        'sources': [{'book': registry[b]['title'], 'code': registry[b]['code'],
                     'pages': '; '.join('%s %s' % (r['part'], ', '.join('%d-%d' % tuple(p) for p in r['pages'])) for r in ranges(registry[b]))
                     if registry[b].get('character_ranges') else '%d-%d' % tuple(registry[b]['character_pages'])}
                    for b in present],
        'books': [{'slug': b, 'short': registry[b]['short'], 'title': registry[b]['title'],
                   **({'pages': ranges(registry[b])[0]['pages'][0], 'ranges': ranges(registry[b])} if registry[b].get('character_ranges') else
                      {'pages': list(registry[b]['character_pages']),
                       **({'part': part_cite(registry[b], registry[b]['character_part'])} if registry[b].get('character_part') else {})})}
                  for b in present],
        'teams': teams,
        'characters': chars,
    }
    text = json.dumps(out, indent=1, ensure_ascii=True)
    io.open(path_out, 'w', encoding='utf-8', newline='\n').write(text + '\n')

    def q(v):
        if v is None:
            return 'NULL'
        if isinstance(v, int):
            return str(v)
        return "'" + v.replace("'", "''") + "'"
    sql = ['-- msh_book_text for %s, written by scripts/msh/npcs.py. NEVER COMMIT THIS FILE: it is the book\'s text.' % slug_arg,
           # The book's character rows only: its items' and its adventure's are
           # scripts/msh/extras.py's, so either script can be re-run alone.
           "DELETE FROM msh_book_text WHERE book = '%s' AND entry NOT LIKE 'item-%%'%s;" % (
               slug_arg, " AND entry NOT LIKE '%s-%%'" % ident(book['adventure']['title']) if book.get('adventure') else '')]
    for r in rows:
        sql.append('INSERT INTO msh_book_text (key, book, entry, part, name, page, body) VALUES (%s);' % ', '.join(q(v) for v in r))
    path = os.path.join(CACHE, 'books', slug_arg, 'book-text.sql')
    io.open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(sql) + '\n')
    keys = [r[0] for r in rows]
    assert len(keys) == len(set(keys)), 'duplicate msh_book_text keys'
    mine = [c for c in chars if c['book'] == slug_arg]
    print('%s: %d characters, %d versions, %d blocks, %d appearances, %d powers (%d linked to the UPB); %d from other books kept'
          % (slug_arg, len(mine), sum(len(c['versions']) for c in mine),
             sum(len(v['blocks']) for c in mine for v in c['versions']), sum(len(c['appearances']) for c in mine),
             sum(len(v['powers']) for c in mine for v in c['versions']),
             sum(1 for c in mine for v in c['versions'] for p in v['powers'] if 'upb' in p), len(others)))
    print('  wrote apps/marvel-heroes/data/npcs.json (%d bytes) and %s (%d rows)' % (len(text), path, len(rows)))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else sys.exit('usage: npcs.py <slug>'))
