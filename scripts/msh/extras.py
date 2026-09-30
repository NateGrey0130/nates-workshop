# -*- coding: utf-8 -*-
"""Build a sourcebook's items and locations for the Marvel codex.

    python scripts/msh/extras.py ma1

The rest of a book after its characters. It reads the same OCR stream as
scripts/msh/roster.py - imported, never copied, so columns and pages are read
one way - over the page ranges scripts/msh/books.json names, and writes the
same two halves scripts/msh/npcs.py does:

  apps/marvel-heroes/data/items.json        FACTS: each item's and location's
      name, kind and page, a vehicle's Control, Speed and Body as printed, and
      the names of the parts a location lists (the Danger Room's event kinds).
  $WORKSHOP_MSH_CACHE/books/<slug>/extras.json and extras-text.sql
      THE PROSE, never committed: the parse, and msh_book_text rows (migration
      087) under entry ids item-<id>, applied with
          node scripts/d1-apply.mjs --remote --db marvel <that .sql>

ADVENTURES ARE NOT IN THE APP (Nate, 2026-09-29): data/adventures.json and the
Codex's Adventures section were removed, and MHSP1 is the only registry book
with an `adventure` left. It is still parsed, because a roster-booklet book
finds its locations and vehicles inside the adventure's sections, and a vehicle stated in passing has no text
but its section's. So the one adventure text written is a section an item
names (`section`), under entry id <adventure>-<section>; the .sql deletes the
book's other adventure rows. extras.json keeps the whole parse, so smoke's
prose-leak check still compares against all of it.

items.json holds every book's rows, each with its `book`; this replaces the
named book's and keeps the rest, with ids made as scripts/msh/npcs.py makes
them (the registry's first book plain, a later one's ending in -<slug>). A
book with no item_pages in the registry has none.

HOW THE BOOK SETS THEM. Items and locations are run-in entries - "ACID BOMB:
This Brood weapon..." - under a heading (Special Items, Locations); a vehicle
follows its run-in with Control:, Speed: and Body: lines. A run-in inside a
location that names one of its parts (the Danger Room's ENERGY WEAPONS,
MISSILES...) is listed in the registry's item_parts, because nothing in the
type tells it from a new item.
"""
import importlib.util, io, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, 'apps', 'marvel-heroes', 'data')
_spec = importlib.util.spec_from_file_location('roster', os.path.join(ROOT, 'scripts', 'msh', 'roster.py'))
roster = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(roster)
_spec = importlib.util.spec_from_file_location('npcs', os.path.join(ROOT, 'scripts', 'msh', 'npcs.py'))
npcs = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(npcs)

VEHICLE = re.compile(r'^(Control|Speed|Body)\s*:\s*(.+)$')
SMALL = {'of', 'the', 'and', 'a', 'an', 'in', 'on', 'to', 'with', 'for'}


def small_caps_title(s):
    """A run-in's name in title case, as npcs.title_case, but with the small
    words small ("Knights of Hellfire Armor") and a short name that is an
    acronym kept whole ("CIA")."""
    if re.fullmatch(r'[A-Z]{2,3}', s) and s.lower() not in SMALL:
        return s
    words = npcs.title_case(s).split(' ')
    return ' '.join(w.lower() if i and w.lower() in SMALL else w for i, w in enumerate(words))


def stream_for(book, slug, pages):
    b = dict(book)
    b['character_pages'] = pages
    return roster.page_stream(b, slug)


def run_in(line):
    m = roster.RUN_IN.match(line['text'])
    return m if m and line['x0'] - line['left'] < 40 and not line.get('big') else None


def items(book, slug):
    """[{name, kind, page, vehicle?, parts?, text: [(part, name, body)]}]"""
    parts_of = {k.upper(): {p.upper() for p in v} for k, v in book.get('item_parts', {}).items()}
    out, heading, cur = [], None, None
    for line in stream_for(book, slug, book['item_pages']):
        if line.get('big') and not VEHICLE.match(line['text']):
            heading = line['text'].strip()
            cur = None
            continue
        m = run_in(line)
        if m:
            label = m.group(1).strip()
            if cur and label in parts_of.get(cur['name'].upper(), ()):
                cur['parts'].append(small_caps_title(label))
                cur['text'].append(['part', small_caps_title(label), [m.group(2)]])
                continue
            if label in ('NOTE', 'NOTES') and cur:
                cur['text'].append(['notes', None, [m.group(2)]])
                continue
            kind = 'location' if heading == 'Locations' else 'item'
            cur = {'name': label, 'kind': kind, 'page': line['printed'], 'vehicle': {}, 'parts': [],
                   'text': [['prose', None, [m.group(2)]]]}
            out.append(cur)
            continue
        if cur is None:
            continue
        v = VEHICLE.match(line['text'])
        if v and len(cur['vehicle']) < 3 and v.group(1) not in cur['vehicle'] and len(cur['text']) == 1:
            cur['vehicle'][v.group(1)] = v.group(2).strip()
            cur['kind'] = 'vehicle'
            continue
        cur['text'][-1][2].append(line['text'])
    return out


def merged(path, key, slug, mine, order):
    """A data file's list with this book's rows replaced and every other
    book's kept, in registry order. The single-book shape had one `book` for
    the whole file; its rows are that book's."""
    old = json.load(io.open(path, encoding='utf-8')) if os.path.exists(path) else {key: []}
    others = [dict(r, book=r.get('book', old.get('book'))) for r in old.get(key, []) if r.get('book', old.get('book')) != slug]
    rows = sorted(others + mine, key=lambda r: order.index(r['book']))
    ids = [r['id'] for r in rows]
    assert len(ids) == len(set(ids)), '%s: an id is in two books' % key
    return rows


def main(slug):
    registry = json.load(io.open(roster.REGISTRY, encoding='utf-8'))['books']
    book = registry[slug]
    order = list(registry)
    # as npcs.py: the registry's first book keeps plain ids, a later one's end in -<slug>
    sfx = '' if order[0] == slug else '-' + slug
    if book.get('layout') == 'roster-booklet':
        # a boxed module's Adventure Book (MHSP1): scripts/msh/booklet.py reads
        # it into the same two shapes, each row with the booklet it is in
        import booklet
        its, adv = booklet.extras(book, slug)
    else:
        # a book set like MA1: items only. Its adventure's parser went with
        # MA1's registry entry (2026-09-30); a new book imports no adventure.
        its = items(book, slug) if book.get('item_pages') else []
        adv = None
    cite = {p['name']: p['cite'] for p in book.get('parts', [])}
    rows = []

    def text_rows(entry, pieces, page):
        n = 0
        for part, name, body in pieces:
            body = npcs.ascii_fold(roster.join_text(body)).strip()
            if not body:
                continue
            n += 1
            rows.append(('%s:%s:%s:%d' % (slug, entry, part, n), slug, entry, part,
                         npcs.ascii_fold(name) if name else None, page, body))

    aid = npcs.slug(adv['title']) + sfx if adv else None
    section_id = lambda s: '%s-%s' % (aid, npcs.slug(s['title'].split(':')[0] if s.get('number') else s['title']))
    item_out = []
    for it in its:
        iid = 'item-' + npcs.slug(it['name']) + sfx
        text_rows(iid, it['text'], it['page'])
        item_out.append({'id': iid, 'name': small_caps_title(it['name']) if not it.get('part') else npcs.ascii_fold(it['name']),
                         'kind': it['kind'], 'page': it['page'],
                         **({'part': cite[it['part']]} if it.get('part') else {}),
                         **({'vehicle': it['vehicle']} if it['vehicle'] else {}),
                         **({'parts': it['parts']} if it['parts'] else {}),
                         **({'rooms': it['rooms']} if it.get('rooms') else {}),
                         # a vehicle stated inside an adventure section reads that section's text
                         **({'section': section_id({'title': it['section']})} if it.get('section') else {}), 'book': slug})
    # The adventure is not in the app; only the sections an item reads keep their text.
    wanted = {i['section'] for i in item_out if i.get('section')}
    kept = []
    if adv:
        sids = [section_id(s) for s in adv['sections']]
        assert len(set(sids)) == len(sids), 'duplicate section ids'
        for s, sid in zip(adv['sections'], sids):
            if sid in wanted:
                text_rows(sid, s['text'], s['page'])
                kept.append(sid)
    assert set(kept) == wanted, 'an item names a section the adventure does not have: %s' % sorted(wanted - set(kept))
    keys = [r[0] for r in rows]
    assert len(keys) == len(set(keys)), 'duplicate keys'

    all_items = merged(os.path.join(DATA, 'items.json'), 'items', slug, item_out, order)
    about = lambda what: [
        '%s from the Marvel sourcebooks, built by scripts/msh/extras.py from the OCR of each book, one book at a time.' % what,
        "Facts only: names, kinds, pages, a vehicle's printed Control, Speed and Body, and the names of the parts each prints. "
        "The book's prose is in D1 (msh_book_text, migration 087), keyed <book>:<id>:<part>:<n>, and never in this file.",
        'Every row carries its book. The first book in scripts/msh/books.json keeps plain ids; a later book\'s end in -<slug>.',
    ]

    npcs.unpaired(rows, slug)

    def listing(rows_, pages_of):
        present = [b for b in order if any(r['book'] == b for r in rows_)]
        return ([{'book': registry[b]['title'], 'code': registry[b]['code'], 'pages': '%d-%d' % tuple(pages_of(b))} for b in present],
                [{'slug': b, 'short': registry[b]['short'], 'title': registry[b]['title'], 'pages': list(pages_of(b)),
                  **({'part': part_of(b)} if part_of(b) else {})} for b in present])
    part_of = lambda b: npcs.part_cite(registry[b], registry[b]['item_part']) if registry[b].get('item_part') else None
    src, books = listing(all_items, lambda b: registry[b]['item_pages'])
    io.open(os.path.join(DATA, 'items.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(
        {'about': about('Items and locations'), 'sources': src, 'books': books, 'items': all_items},
        indent=1, ensure_ascii=True) + '\n')
    cache = os.path.join(roster.CACHE, 'books', slug)
    io.open(os.path.join(cache, 'extras.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(
        {'items': its, 'adventure': adv or {'title': None, 'pages': None, 'sections': []}}, indent=1, ensure_ascii=False) + '\n')

    def q(v):
        return 'NULL' if v is None else str(v) if isinstance(v, int) else "'" + v.replace("'", "''") + "'"
    # every adventure row of the book goes, so a section no item reads any more does not linger
    mine = ["entry LIKE 'item-%'"] + (["entry LIKE '%s-%%'" % aid] if aid else [])
    sql = ["-- msh_book_text: %s's items and locations, written by scripts/msh/extras.py. NEVER COMMIT: the book's text." % slug,
           "DELETE FROM msh_book_text WHERE book = '%s' AND (%s);" % (slug, ' OR '.join(mine))]
    sql += ['INSERT INTO msh_book_text (key, book, entry, part, name, page, body) VALUES (%s);' % ', '.join(q(v) for v in r) for r in rows]
    io.open(os.path.join(cache, 'extras-text.sql'), 'w', encoding='utf-8', newline='\n').write('\n'.join(sql) + '\n')
    print('%s: %d items (%d vehicles, %d locations), %s; %d text rows'
          % (slug, len(item_out), sum(1 for i in item_out if i['kind'] == 'vehicle'), sum(1 for i in item_out if i['kind'] == 'location'),
             'adventure "%s" parsed, %d of its %d sections kept for the items that read them' % (adv['title'], len(kept), len(adv['sections']))
             if adv else 'no adventure',
             len(rows)))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else sys.exit('usage: extras.py <slug>'))
