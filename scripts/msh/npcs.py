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
        '\u2026': '...', '\u00a0': ' ', '\ufffd': "'", '\u00ad': ''}


def ascii_fold(s):
    s = ''.join(FOLD.get(ch, ch) for ch in s or '')
    return unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii')


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


def title_case(s):
    """MARVEL GIRL -> Marvel Girl, SHI'AR -> Shi'ar, X-FACTOR -> X-Factor, keeping
    Mr./Dr. and any parenthetical as printed."""
    def word(w):
        if not any(c.isalpha() for c in w) or not w.isupper():
            return w
        return '-'.join(p[:1] + p[1:].lower() for p in w.split('-'))
    out, depth = [], 0
    for tok in re.split(r'(\s+|\(|\))', s):
        if tok == '(':
            depth += 1
        elif tok == ')':
            depth -= 1
        out.append(tok if depth or tok in ('(', ')') else word(tok))
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


def main(slug_arg):
    book = json.load(io.open(REGISTRY, encoding='utf-8'))['books'][slug_arg]
    roster = json.load(io.open(os.path.join(CACHE, 'books', slug_arg, 'roster.json'), encoding='utf-8'))
    powers = json.load(io.open(os.path.join(DATA, 'powers.json'), encoding='utf-8'))['powers']
    aliases = json.load(io.open(os.path.join(DATA, 'npc-power-aliases.json'), encoding='utf-8'))['aliases']
    upb = {norm(p['name']): p['code'] for p in powers}
    upb.update({norm(k): v for k, v in aliases.items()})
    index_case = {}
    for name, _p in book['index']:
        index_case[norm(name)] = name

    def display(header):
        b = base_name(header)
        return index_case.get(norm(b)) or title_case(b)

    entries = roster['entries']
    statted = [e for e in entries if e['blocks']]
    by_name = {}
    for e in statted:
        by_name.setdefault(norm(base_name(e['header'])), []).append(e)

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
            eslug = slug(roman(e['header']))
            blocks = []
            for n, b in enumerate(e['blocks']):
                label = b['label']
                if not label and n:
                    label = 'Additional statistics, p.%d' % b['page']
                abilities, derived = [], []
                for i, a in enumerate(b['abilities']):
                    code = a['code']
                    if code is None and a['number'] in CODE_OF:
                        code = CODE_OF[a['number']]
                        derived.append('FASERIP'[i])
                    abilities.append(['FASERIP'[i], a['number'], code]
                                     + ([[a['alt']['number'], a['alt']['code']]] if a.get('alt') else []))
                blocks.append({
                    'label': title_case(roman(label)) if label else None,
                    'page': b['page'],
                    'abilities': abilities,
                    **({'derived': derived} if derived else {}),
                    'health': ascii_fold(b['health']), 'karma': ascii_fold(b['karma']),
                    'resources': ascii_fold(b['resources']), 'popularity': ascii_fold(b['popularity']),
                    **({'override': b['override']} if b.get('override') else {}),
                    **({'kind': b['kind']} if b.get('kind') else {}),
                })
            pw = []
            for n, p in enumerate(e['powers'], 1):
                code = upb.get(norm(p['name']))
                pw.append({'name': ascii_fold(p['name']), **({'upb': code} if code else {})})
                text_row(eslug, 'power', n, p['name'], e['pages'][0], p['text'])
            for part in ('talents', 'contacts', 'running', 'background', 'notes'):
                text_row(eslug, part, None, None, e['pages'][0], e['sections'].get(part, ''))
            if e['sections'].get('powers'):
                text_row(eslug, 'powers-intro', None, None, e['pages'][0], e['sections']['powers'])
            # A header's identity is its name and status lines: one or two short
            # lines. Three is the parser's cap, reached when a team's opening
            # paragraph follows its header ("The Gladiators was an organization
            # of..."). That is prose, so it goes to D1 and the identity is empty.
            identity = [ascii_fold(x) for x in e['identity']]
            prose = e['prose']
            if len(identity) >= 3:
                prose = ' '.join(e['identity']) + ' ' + prose
                identity = []
            text_row(eslug, 'prose', None, None, e['pages'][0], prose)
            members = []
            for n, m in enumerate(e['members'], 1):
                members.append({'name': display(m['name']), 'page': m['page']})
                text_row(eslug, 'member', n, display(m['name']), m['page'], m['text'])
            versions.append({
                'id': eslug, 'label': variant(e['header']), 'team': section_at(book, e['pages'][0]),
                'pages': e['pages'], 'identity': identity,
                'blocks': blocks, 'powers': pw, 'members': members,
                'text': sorted({r[3] for r in rows if r[2] == eslug}),
            })
        cid = slug(base_name(group[0]['header']))
        chars.append({'id': cid, 'name': display(group[0]['header']), 'team': versions[0]['team'],
                      'versions': versions, 'appearances': []})

    by_id = {c['id']: c for c in chars}
    for e in entries:
        if e['blocks']:
            continue
        c = by_id.get(slug(base_name(e['header'])))
        if not c:
            continue
        eslug = '%s-p%d' % (c['id'], e['pages'][0])
        text_row(eslug, 'appearance', None, None, e['pages'][0], ' '.join(e['identity']) + ' ' + e['prose'])
        c['appearances'].append({'id': eslug, 'team': section_at(book, e['pages'][0]), 'page': e['pages'][0]})

    # Team members the book gives no block of their own, given one
    # (scripts/msh/<slug>-members.json): the team's tier block, with the ranks
    # the member's own text states. Where the text prints a Health the build
    # must reproduce it - Barbarus 106, Gaza 96 - or nothing is written.
    mpath = os.path.join(ROOT, 'scripts', 'msh', '%s-members.json' % slug_arg)
    std = {code: n for n, code in CODE_OF.items()}
    for m in (json.load(io.open(mpath, encoding='utf-8'))['members'] if os.path.exists(mpath) else []):
        team_entry = next((e for e in entries if (e['header'] or '').upper() == m['team'].upper()), None)
        team = next((c for c in chars for v in c['versions'] if team_entry and v['id'] == slug(roman(team_entry['header']))), None)
        member = team_entry and next((x for x in team_entry['members'] if x['name'].upper() == m['member'].upper()), None)
        if not team or not member:
            sys.exit('%s-members.json: no member %s under %s' % (slug_arg, m['member'], m['team']))
        if m.get('skip'):
            # a cross-reference: the member links to their own statted entry
            own = by_id.get(slug(display(m['member'])))
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
        cid = slug(name)
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

    chars.sort(key=lambda c: (min(v['pages'][0] for v in c['versions']), c['name']))
    teams = []
    for c in chars:
        if c['team'] not in teams:
            teams.append(c['team'])
    out = {
        'about': [
            'Notable NPCs from %s, built by scripts/msh/npcs.py from the parse of the book (scripts/msh/roster.py).' % book['title'],
            'Facts only: numbers, rank codes, names and pages. The book\'s prose is in D1 (msh_book_text, migration 087), keyed ma1:<version id>:<part>, and never in this file.',
            'A character is one printed name; each version is one printed entry, with its stat blocks (forms and tiers are labelled blocks).',
            'abilities: [letter, number, rank code, [alternate number, code]?] - the alternate is the book\'s parenthesised altered value.',
            'health, karma, resources, popularity: as printed. override: a misprint or an as-printed value, read off the page (scripts/msh/%s-overrides.json).' % slug_arg,
            'powers[].upb: the Ultimate Powers Book code, where the name is a UPB power or in npc-power-aliases.json.',
        ],
        'sources': [{'book': book['title'], 'code': book['code'], 'pages': '%d-%d' % tuple(book['character_pages'])}],
        'book': slug_arg,
        'teams': teams,
        'characters': chars,
    }
    text = json.dumps(out, indent=1, ensure_ascii=True)
    io.open(os.path.join(DATA, 'npcs.json'), 'w', encoding='utf-8', newline='\n').write(text + '\n')

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
               slug_arg, " AND entry NOT LIKE '%s-%%'" % slug(book['adventure']['title']) if book.get('adventure') else '')]
    for r in rows:
        sql.append('INSERT INTO msh_book_text (key, book, entry, part, name, page, body) VALUES (%s);' % ', '.join(q(v) for v in r))
    path = os.path.join(CACHE, 'books', slug_arg, 'book-text.sql')
    io.open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(sql) + '\n')
    keys = [r[0] for r in rows]
    assert len(keys) == len(set(keys)), 'duplicate msh_book_text keys'
    print('%s: %d characters, %d versions, %d blocks, %d appearances, %d powers (%d linked to the UPB)'
          % (slug_arg, len(chars), sum(len(c['versions']) for c in chars),
             sum(len(v['blocks']) for c in chars for v in c['versions']), sum(len(c['appearances']) for c in chars),
             sum(len(v['powers']) for c in chars for v in c['versions']),
             sum(1 for c in chars for v in c['versions'] for p in v['powers'] if 'upb' in p)))
    print('  wrote apps/marvel-heroes/data/npcs.json (%d bytes) and %s (%d rows)' % (len(text), path, len(rows)))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else sys.exit('usage: npcs.py <slug>'))
