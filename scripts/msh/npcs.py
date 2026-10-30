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
    ('-5' read as a long dash then 5), is a minus; ascii_fold would spell it ' - '.
    So is a hyphen beside one (ME2's Fenris Wolf, '-5' read as a hyphen and a dash)."""
    return re.sub('^-?[%s%s]-?\\s*(?=\\d)' % (chr(0x2013), chr(0x2014)), '-', s) if s else s


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


def slash_forms(block, name, identity, header):
    """A roster-book block whose ranks print a slash (the Puma, MHSP2 Roster
    23) as its two forms: the ranks before the slash, labelled with the
    entry's identity line (Thomas Fireheart), then the ranks after it,
    labelled with the character's name. A rank printed with no slash is
    both forms'. The Health '36 (150)' (rosterbook.value reads 36/150 so) is
    split the same way, and the one Karma is both forms'. Each form's Health
    must be its F+A+S+E; the first form's Karma must be its R+I+P, and the
    second's may differ only under an override on that field, which goes on
    the second form alone. Anything else stops the build."""
    m = re.match(r'^\s*(\d+)\s*\((\d+)\)\s*$', block['health'] or '')
    if not m or not identity:
        raise SystemExit('%s: a slashed block needs a Health of two numbers and an identity line, found %r and %r'
                         % (header, block['health'], identity))
    first = dict(block, label=ascii_fold(identity[0]), abilities=[a[:3] for a in block['abilities']], health=m.group(1))
    first.pop('override', None)
    second = dict(block, label=name, abilities=[[a[0]] + (a[3] if len(a) > 3 else a[1:3]) for a in block['abilities']],
                  health=m.group(2))
    for f in (first, second):
        nums = [a[1] for a in f['abilities']]
        karma_ok = str(sum(nums[4:])) == f['karma'] or (f is second and (f.get('override') or {}).get('field') == 'karma')
        if str(sum(nums[:4])) != f['health'] or not karma_ok:
            raise SystemExit('%s: the slashed form %s does not add up: Health %s, Karma %s, ranks %s'
                             % (header, f['label'], f['health'], f['karma'], nums))
    return [first, second]


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
    #
    # A code-grids book (MA4, scripts/msh/codegrids.py) is read as MA1 is, with
    # three differences: its entries carry their team (the registry's `teams`:
    # the book's own groupings, not its Contents sections), a value the page
    # does not print is null (the New Men print no Health), and a member
    # without a block who has a card of their own links to it (the Notable
    # Skrulls' SUPER-SKRULL).
    #
    # A cover-panels book (MH1, scripts/msh/coverpanels.py) is read as MA1 is,
    # with five differences (survey: mh1.md, Nate's rulings 2026-10-21): a
    # character's team is the registry's `teams` list it is named in, or the
    # book's title; every version carries its part, so a card on a cover panel,
    # which prints no page, cites the panel; a value the page does not print is
    # null; a one-line grid printing no Health (`no_health`) is given F+A+S+E,
    # flagged `health_derived`; and a one-line grid's Special: line is a text
    # part of its own. MH2 (mh2.md, Nate's rulings 2026-10-21) adds two: a
    # grid printing no Karma that a ruling derives (`no_karma`) is given
    # R+I+P, flagged `karma_derived`; and a card with a form grid
    # (`form_grids`) is one being whose blocks are forms, the form's run-in
    # powers going to D1 as the card's.
    #
    # A roster-book book (MHSP2, scripts/msh/rosterbook.py) is read as MHSP1
    # is, with four differences: its entries carry the team whose banner they
    # are printed under (the registry's `teams`), named as `team_names` says
    # and filed under the book's title where no banner is printed; a block
    # label printed in capitals is cased (GENERAL ZEDRAO); a one-line block is
    # a form only in an entry of more than one block; and a one-line block
    # that prints only four codes (Psycho-Man's suits, Valkyrie's steed: a
    # `rows` override in mhsp2-overrides.json) is `partial`, on the Codex card
    # but not offered to the GM. A block whose ranks print a slash, one form's
    # rank then the other's (the Puma, Roster 23: TYPICAL/REMARKABLE and
    # Health 36/150), is two blocks, both forms (Nate, 2026-10-21, as MH2's
    # Mimic and MH3's Super-Adaptoid): the first rank's, named by the entry's
    # identity line, then the slashed ranks', named for the character, with
    # the Health after the slash and the Karma as printed. A rank printed
    # with no slash is both forms'. A bracketed form (Colossus's armour) is
    # not a slash and stays one block, in every book.
    grid = book.get('layout') == 'grid-booklets'
    rbook = book.get('layout') == 'roster-book'
    booklet = book.get('layout') == 'roster-booklet' or grid or rbook
    coded = book.get('layout') == 'code-grids'
    panels = book.get('layout') == 'cover-panels'
    team_names = book.get('team_names', {})
    cite = {p['name']: p['cite'] for p in book.get('parts', [])}
    SIDE = {'heroes': '%s Heroes' % book['title'].split(' ', 1)[-1], 'villains': '%s Villains' % book['title'].split(' ', 1)[-1]}
    tiers = set(book.get('one_line_tiers', []))

    def team_of_entry(e):
        if rbook:
            return team_names.get(e['team'], e['team']) if e.get('team') else book['title']
        # a header's capitals (WRECKING CREW) are cased; a registry team is as written
        return (title_case(e['team']) if e['team'].isupper() else e['team']) if e.get('team') else SIDE[e['side']]

    def name_of(e):
        # ME2 prints MUSPELHEIM DEMON, with a comma and nothing after it
        # (Resource p.14, read on the page image); its Contents prints none
        return e.get('name') or title_case(re.sub(r',$', '', base_name(e['header'])) if grid else base_name(e['header']))

    roster = json.load(io.open(os.path.join(CACHE, 'books', slug_arg, 'roster.json'), encoding='utf-8'))
    powers = json.load(io.open(os.path.join(DATA, 'powers.json'), encoding='utf-8'))['powers']
    rank_abbr = {r['id']: r['abbr'] for r in json.load(io.open(os.path.join(DATA, 'ranks.json'), encoding='utf-8'))['ranks']}
    aliases = json.load(io.open(os.path.join(DATA, 'npc-power-aliases.json'), encoding='utf-8'))['aliases']
    upb = {norm(p['name']): p['code'] for p in powers}
    upb.update({norm(k): v for k, v in aliases.items()})
    index_case = {}
    for name, _p in book.get('index', []):
        index_case[norm(name)] = name

    # A cover-panels card the registry names (MH9's page_names [part, page,
    # NAME, card name]: three Captains America, two Human Torches, two Wasps
    # and two Things, survey mh9.md decision 4), and a one-line grid the
    # registry names because the page prints none (unnamed_grids: MH9's
    # "A.I.M. Soldiers"): the name is the registry's as written. A page name's
    # parenthesis is part of the name, not a version label, so each is a card
    # of its own whose id follows it, as card_names' are. No earlier book sets
    # page_names, and its unnamed_grids names build the same either way.
    as_written = ({n[3] for n in book.get('page_names', [])}
                  | {g['name'] for g in book.get('unnamed_grids', [])}) if panels else set()
    page_named = {n[3] for n in book.get('page_names', [])} if panels else set()

    def group_name(header):
        return header if header in page_named else base_name(header)

    def display(header):
        if header in as_written:
            return header
        b = base_name(header)
        name = index_case.get(norm(b)) or title_case(b)
        if coded:
            # a Roman numeral stays one (VICTOR VON DOOM II, not "Ii"), and a
            # small word inside a name is small (Living Computers of Xandar).
            # MA1's names are left as they are: its file is live data.
            name = re.sub(r'\b[IV][iv]+\b', lambda m: m.group(0).upper(), name)
            name = re.sub(r'(?<=\s)(Of|The|And|In|Von)\b', lambda m: m.group(0).lower(), name)
        return name

    # A card the registry names (card_names: {name as built: card name}): two
    # books' different people who print one name (MA1's Ariel, a Fallen Angel,
    # and MH1's, Kitty Pryde; Nate, 2026-10-21). The parenthesis is part of the
    # name, not a version label, so the card's and its version's ids follow it.
    # Only a header with no parenthesis of its own is renamed, and each name
    # must find exactly one entry, so a stale field stops the build.
    card_names = book.get('card_names', {})

    def built_name(e):
        return name_of(e) if booklet else display(e['header'])

    def card_name(e):
        return card_names.get(built_name(e), built_name(e))

    for old in card_names:
        hits = [e for e in roster['entries'] if e.get('blocks') and e.get('header') and built_name(e) == old]
        if len(hits) != 1 or variant(hits[0]['header']):
            raise SystemExit('%s: card_names %r finds %d entries, not 1 with no parenthesis' % (slug_arg, old, len(hits)))

    no_health = {norm(n) for n in book.get('no_health', [])} if panels else set()
    no_karma = {norm(n) for n in book.get('no_karma', [])} if panels else set()

    def team_of_panel_card(e):
        # MH4 prints no teams (mh4.md decision 1): every card files under the book
        return next((t for t, names in book.get('teams', {}).items() if norm(display(e['header'])) in {norm(n) for n in names}),
                    book['title'])

    entries = roster['entries']
    # A leading THE is dropped from a character's header in every book, so the
    # card's name and id sort by the next word (Nate, 2026-10-21: MA4's and
    # MHSP2's The Thing, MA4's The Chosen, MHSP2's The Beyonder and The Watcher,
    # ME2's The Fenris Wolf, MH3's THE THING). Only an entry with a block is a
    # character: a team's banner (The Fantastic Four, The Asgardians) stands.
    for e in entries:
        if e.get('header') and e.get('blocks'):
            e['header'] = re.sub(r'^THE\s+', '', e['header'], flags=re.I)
    # A chapter's second grid for a character the Resource Book stats (ME2's
    # Titans tormenting Zeus, and Zeus powerless in Hades; registry
    # second_blocks, Nate 2026-10-21) is a labelled block on that character's
    # card, not a card of its own. Its run-in powers go to D1 as the card's,
    # named for the block. Only a grid-booklets book sets the field.
    second = {}
    for g in (book.get('second_blocks', []) if grid else []):
        hits = [e for e in entries if e['part'] == g['part'] and g['page'] in e['pages'] and e.get('header') == g['name']
                and len(e['blocks']) == 1]
        owners = [e for e in entries if e['part'] != g['part'] and e['blocks'] and norm(base_name(e['header'])) == norm(g['name'])]
        if len(hits) != 1 or len(owners) != 1:
            raise SystemExit('%s: second_blocks %s finds %d grids and %d cards, not 1 and 1' % (slug_arg, g['name'], len(hits), len(owners)))
        e = hits[0]
        if e['prose'].strip() or e['identity'] or e['members'] or any(v.strip() for k, v in e['sections'].items() if k != 'powers'):
            raise SystemExit('%s: the second block %s has text npcs.py has no part for' % (slug_arg, g['name']))
        entries = [x for x in entries if x is not e]
        second[id(owners[0])] = (dict(e['blocks'][0], label=g['label'], second=True), e['powers'])
    statted = [e for e in entries if e['blocks']]
    by_name = {}
    for e in statted:
        by_name.setdefault(norm(name_of(e) if booklet else group_name(e['header'])), []).append(e)

    chars, rows, card_part = [], [], {}

    def text_row(entry_slug, part, n, name, page, body):
        body = ascii_fold(body).strip()
        if not body:
            return
        key = '%s:%s:%s%s' % (slug_arg, entry_slug, part, '' if n is None else ':%d' % n)
        rows.append((key, slug_arg, entry_slug, part, ascii_fold(name) if name else None, page, body))

    for name_key, group in by_name.items():
        versions = []
        for e in group:
            eslug = ident(card_name(e)) if booklet or built_name(e) in card_names else ident(roman(e['header']))
            # an alter ego's one-line block makes every block of the entry a
            # form (She-Hulk and Jennifer Walters); Klaw's sound creatures are
            # beings of their own, a tier (registry one_line_tiers)
            forms = booklet and any(b.get('kind') == 'line' and b['label'] not in tiers for b in e['blocks']) \
                and (not rbook or len(e['blocks']) > 1)
            # MA4's The Thing prints his human form as a second grid: the
            # entry's blocks are forms of one being, the first named for him
            forms = forms or (coded and len(e['blocks']) > 1 and any('form' in (b['label'] or '').lower() for b in e['blocks']))
            # a cover-panels card with a form grid (registry form_grids, MH2's
            # Mimic once he has copied the Avengers' powers): one being, so its
            # blocks are forms and the first is named for him
            form_grid = panels and any(b.get('text') for b in e['blocks'])
            forms = forms or form_grid
            # a cover-panels card whose text ends on a one-line grid of its
            # human form (registry card_grids, MH3's She-Hulk and Thing,
            # mh3.md decision 3): one being, its blocks forms, as above
            card_labels = {g['label'] for g in book.get('card_grids', []) if panels
                           and norm(re.sub(r'^the\s+', '', g['entry'], flags=re.I)) == norm(re.sub(r'^the\s+', '', base_name(e['header']), flags=re.I))}
            forms = forms or any(b.get('kind') == 'line' and b['label'] in card_labels for b in e['blocks'])
            # a roster-book block whose ranks print a slash is two forms (above)
            slashed = [b for b in e['blocks'] if rbook and any('/' in (a.get('printed_code') or '') for a in b['abilities'])]
            if len(slashed) > 1 or (slashed and len(e['blocks']) > 1):
                raise SystemExit('%s: %s has %d blocks and %d with a slash; npcs.py splits one block alone'
                                 % (slug_arg, e['header'], len(e['blocks']), len(slashed)))
            forms = forms or bool(slashed)
            # a chapter's second grid (second_blocks above) is not a form: the
            # GM picks one block or the other
            eblocks = e['blocks'] + ([second[id(e)][0]] if id(e) in second else [])
            blocks = []
            for n, b in enumerate(eblocks):
                label = b['label']
                # the main block of an entry with more than one is named for
                # the character, so the GM picks "Klaw", not "Klaw - block 1"
                if (booklet or forms) and not label and len(eblocks) > 1 and n == 0:
                    label = name_of(e) if booklet else display(e['header'])
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
                    'label': (title_case(roman(label)) if not booklet or rbook else label) if label else None,
                    'page': b['page'],
                    **({'part': cite[b['part']]} if booklet and b.get('part') != e['part'] else {}),
                    'abilities': abilities,
                    **({'derived': derived} if derived else {}),
                    **({'rank_only': True} if b.get('rank_only') else {}),
                    **({'form': True} if forms and not b.get('second') else {}),
                    # a value the book does not print is null, not an empty
                    # string, in a roster booklet (the Summary gives no
                    # Resources or Popularity); MA1's file is kept as it was
                    **{k: (None if (booklet or coded or panels) and b[k] is None else ascii_fold(minus(b[k]) if grid or coded else b[k]))
                       for k in ('health', 'karma', 'resources', 'popularity')},
                    # a value printed under another field's label (MH5's
                    # Northstar prints his Resources under a second Reason:,
                    # coverpanels.second_reason): the block keeps the label
                    # as printed. No earlier book's block carries one.
                    **({'printed_labels': b['printed_labels']} if b.get('printed_labels') else {}),
                    # a grid the registry carries because the page's OCR cannot
                    # read it (MH6's red-pattern grids, coverpanels carried_grids),
                    # and a value read off the image where the OCR lost it (MH6's
                    # Ulik's Popularity, lost_values): the block says so, so the
                    # Codex can mark it. No earlier book's block carries either.
                    **({'carried': True} if panels and b.get('carried') else {}),
                    **({'read_off_image': b['read_off_image']} if panels and b.get('read_off_image') else {}),
                    **({'override': b['override']} if b.get('override') else {}),
                    # a cover-panels book's grid that prints a dash for R, I
                    # and P (MH7's Fire Creatures, a `rows` override in
                    # mh7-overrides.json) is partial as a roster book's is; no
                    # earlier cover-panels book has a `rows` override
                    **({'kind': 'partial' if (rbook or panels) and (b.get('override') or {}).get('verdict') == 'rows' else b['kind']}
                       if b.get('kind') else {}),
                })
                # an as_printed override names the value as the page prints it:
                # ME3's Death prints Karma "Unlim." (Resource p.2), and the
                # grid's crop drops the stop. The page's value is the card's.
                # No earlier grid-booklets book's override differs from its value.
                o = b.get('override') or {}
                if grid and o.get('verdict') == 'as_printed' and isinstance(o.get('printed'), str) \
                        and o.get('field') in ('health', 'karma', 'resources', 'popularity') \
                        and blocks[-1][o['field']] != o['printed']:
                    blocks[-1][o['field']] = o['printed']
                if panels and b['health'] is None and b.get('kind') == 'line' and norm(display(e['header'])) in no_health:
                    # printed with no Health (Fluffy, Augie Hickman): the ranks'
                    # standard numbers give it, as they give every number here
                    blocks[-1]['health'] = str(sum(a[1] for a in abilities[:4]))
                    blocks[-1]['health_derived'] = True
                if panels and norm(display(e['header'])) in no_karma and (
                        (b['karma'] is None and b.get('kind') == 'line')
                        or (not b.get('kind') and (b['karma'] or '').strip().lower() == 'none')):
                    # printed with no Karma, and a ruling derives it (MH2's
                    # Kang's Minions, survey decision 5): R+I+P of the ranks.
                    # A full block printing the word none (MH3's Miss Locke and
                    # Mr. Chambers, mh3.md decision 4) is derived the same way
                    blocks[-1]['karma'] = str(sum(a[1] for a in abilities[4:]))
                    blocks[-1]['karma_derived'] = True
                if b in slashed:
                    blocks[-1:] = slash_forms(blocks[-1], name_of(e), e['identity'], e['header'])
            pw = []
            # a Summary-only character has no page; its running note has its own
            page0 = e['pages'][0] if e['pages'] else None
            # MH4's Punisher prints his gear as run-ins under Equipment (GUNS.,
            # VAN.), and coverpanels.py hands them over with the powers, each
            # marked section: equipment. They are not powers: no card power, no
            # UPB link, and their text goes to D1 as named, numbered rows of an
            # equipment part. No earlier book's power carries a section.
            gear = [p for p in e['powers'] if p.get('section') == 'equipment']
            for n, p in enumerate(gear, 1):
                text_row(eslug, 'equipment', n, p['name'], page0, p['text'])
            for n, p in enumerate([p for p in e['powers'] if p.get('section') != 'equipment'], 1):
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
            # MH4's cards print Important People and Equipment sections (the
            # registry's section_labels; the reader keys them important_people
            # and equipment). No earlier cover-panels book's card has either.
            for part in ('talents', 'contacts', 'running', 'background', 'notes') + (('special', 'important-people', 'equipment') if panels else ()):
                text_row(eslug, part, None, None, e['running']['page'] if part == 'running' and e.get('running') else page0,
                         e['sections'].get(part.replace('-', '_'), ''))
            # a Powers line that is only "none." on a card with no powers and
            # Equipment run-ins (MH4's Punisher) is not a row: the card's empty
            # powers list says it. Gated on the gear: fourteen earlier cards
            # (MA1, MA4, MH3) print Powers: none. and keep their row as built
            bare = bool(gear) and not pw and norm(e['sections'].get('powers')) == 'none'
            if e['sections'].get('powers') and not bare:
                text_row(eslug, 'powers-intro', None, None, page0, e['sections']['powers'])
            # A form grid's own text (coverpanels.py keeps it on the block): its
            # run-in powers, numbered on after the card's and named for the
            # form, on the grid's page. Its Powers: line only lists those
            # names, so it is not a row. Any other text would have no key of
            # its own here, so the build stops on it rather than drop it.
            n = len(pw)
            for b in (e['blocks'] if form_grid else []):
                t = b.get('text')
                if not t:
                    continue
                if any(v.strip() for k, v in t['sections'].items() if k != 'powers'):
                    raise SystemExit('%s: the form grid %s of %s has text npcs.py has no part for' % (slug_arg, b['label'], e['header']))
                for p in t['powers']:
                    n += 1
                    text_row(eslug, 'power', n, '%s (%s)' % (p['name'], b['label']), b['page'], p['text'])
                # the grid's own note (MH3's Super-Adaptoid: a bracketed line
                # under its Health), after the form's powers and named for the
                # form. No earlier book's form grid has one: they stopped here.
                if t.get('prose', '').strip():
                    n += 1
                    text_row(eslug, 'power', n, b['label'], b['page'], t['prose'])
            # a chapter's second grid's run-in powers, the same way
            if id(e) in second:
                b, sp = second[id(e)]
                for p in sp:
                    n += 1
                    text_row(eslug, 'power', n, '%s (%s)' % (p['name'], b['label']), b['page'], p['text'])
            # A header's identity is its name and status lines: one or two short
            # lines. Three is the parser's cap, reached when a team's opening
            # paragraph follows its header ("The Gladiators was an organization
            # of..."). That is prose, so it goes to D1 and the identity is empty.
            # (a roster-book name's Roman numeral is read as the header's is:
            # Warren Kenneth Worthington Ill is III)
            identity = [ascii_fold(roman(x) if rbook else x) for x in e['identity']]
            # a word hyphenated across two identity lines is one word: ME3's
            # Mephisto (Resource p.6) prints "Luci-" / "fer, and ...". Only a
            # grid-booklets line ending in a letter and a hyphen, the next
            # opening in lower case; no earlier such book's identity has one.
            k = 0
            while grid and k + 1 < len(identity):
                if re.search(r'[a-z]-$', identity[k]) and identity[k + 1][:1].islower():
                    identity[k:k + 2] = [identity[k][:-1] + identity[k + 1]]
                else:
                    k += 1
            prose = e['prose']
            # A roster-book entry of tiers alone (Kingpin's Organization) opens
            # with a sentence, not a name: that is prose too.
            # A book whose reader keeps every line from the header to the block
            # (registry identity_to_block) prints no opening paragraph there,
            # only a name and a status set over more lines: MH8's Mastermind
            # (printed 12) is his name over a status wrapped across three full
            # lines, and the Wasp (printed 16) a role, then a name and status
            # whose last line starts in lower case. A line goes on from the one
            # before when that one is full (40 characters or more; MH8's
            # unwrapped lines are 36 at most) or it starts in lower case, as
            # the Codex joins them. Only an identity of three lines or more,
            # and no earlier book sets the field.
            if panels and book.get('identity_to_block') and len(identity) >= 3:
                joined = []
                for x in identity:
                    if joined and (len(joined[-1]) >= 40 or x[:1].islower()):
                        joined[-1] += ' ' + x
                    else:
                        joined.append(x)
                identity = joined
            if len(identity) >= 3 or (rbook and identity and all(b.get('kind') == 'line' for b in e['blocks'])):
                prose = ' '.join(e['identity']) + ' ' + prose
                identity = []
            text_row(eslug, 'prose', None, None, page0, prose)
            members = []
            for n, m in enumerate(e['members'], 1):
                members.append({'name': display(m['name']), 'page': m['page']})
                text_row(eslug, 'member', n, display(m['name']), m['page'], m['text'])
            versions.append({
                'id': eslug, 'label': variant(e['header']) if (grid or not booklet) and e['header'] not in page_named else None,
                'team': team_of_panel_card(e) if panels else team_of_entry(e) if booklet
                else (e.get('team') or team_of(e['pages'][0])) if coded else team_of(e['pages'][0]),
                **({'side': SIDE[e['side']]} if booklet and e.get('side') else {}),
                **({'part': cite[e['part']]} if booklet or panels else {}),
                'pages': e['pages'], 'identity': identity,
                'blocks': blocks, 'powers': pw, 'members': members,
                'text': sorted({r[3] for r in rows if r[2] == eslug}),
            })
        renamed = built_name(group[0]) in card_names
        cid = ident(card_name(group[0])) if booklet or renamed else ident(group_name(group[0]['header']))
        card_part[cid] = group[0].get('part')
        chars.append({'id': cid, 'name': card_name(group[0]),
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
    for c in (chars if coded else []):
        for v in c['versions']:
            for m in v['members']:
                own = by_id.get(ident(m['name']))
                if own and own is not c:
                    m['id'] = own['id']
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
    # and a cover-panels book in the PDF's order: the inside front cover, the
    # Adventure Book, the inside back cover
    booklet_rank = {p['cite']: n for n, p in enumerate(book.get('parts', []))} if grid or panels else {}
    # MH6's three card panels share one cite (Inside cover), so a cite's rank
    # is its last panel's and Thor (Inside cover 1) would sort after the
    # Adventure Book: a card sorts by its panel's own part. MH1-5's cites are
    # each one part's, so the two ranks agree there.
    part_rank = {p['name']: n for n, p in enumerate(book.get('parts', []))} if panels else {}
    chars.sort(key=lambda c: (part_rank[card_part[c['id']]] if card_part.get(c['id']) in part_rank
                              else booklet_rank.get(c['versions'][0].get('part'), 0),
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
    def panel_listing(r):
        # a cover-panels book (MH1): the Adventure Book's span, its cards' pages
        # and its opponents' together, and the panels, which print no page
        # MH6 reads no booklet page as a card page (character_ranges empty):
        # the span is its opponents', in their part. Its three card panels
        # cite alike (Inside cover), so a cite is listed once.
        spans = [p for x in r['character_ranges'] for p in x['pages']] + [o['page'] for o in r['opponents']]
        first = (r['character_ranges'] or r['opponents'])[0]['part']
        cites = []
        for p in r['panels']:
            if part_cite(r, p) not in cites:
                cites.append(part_cite(r, p))
        return {'pages': [min(spans), max(spans)], 'part': part_cite(r, first), 'panels': cites}

    def source_pages(r):
        if r.get('layout') == 'cover-panels':
            x = panel_listing(r)
            return '; '.join(['%s %d-%d' % (x['part'], x['pages'][0], x['pages'][1])] + x['panels'])
        if r.get('character_ranges'):
            return '; '.join('%s %s' % (g['part'], ', '.join('%d-%d' % tuple(p) for p in g['pages'])) for g in ranges(r))
        return '%d-%d' % tuple(r['character_pages'])

    def book_listing(r):
        if r.get('layout') == 'cover-panels':
            return panel_listing(r)
        if r.get('character_ranges'):
            return {'pages': ranges(r)[0]['pages'][0], 'ranges': ranges(r)}
        return {'pages': list(r['character_pages']),
                **({'part': part_cite(r, r['character_part'])} if r.get('character_part') else {})}

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
        'sources': [{'book': registry[b]['title'], 'code': registry[b]['code'], 'pages': source_pages(registry[b])}
                    for b in present],
        'books': [{'slug': b, 'short': registry[b]['short'], 'title': registry[b]['title'], **book_listing(registry[b])}
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
