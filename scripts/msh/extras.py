# -*- coding: utf-8 -*-
"""Build a sourcebook's items, locations and adventure for the Marvel codex.

    python scripts/msh/extras.py ma1

The rest of a book after its characters. It reads the same OCR stream as
scripts/msh/roster.py - imported, never copied, so columns and pages are read
one way - over the page ranges scripts/msh/books.json names, and writes the
same two halves scripts/msh/npcs.py does:

  apps/marvel-heroes/data/items.json        FACTS: each item's and location's
      name, kind and page, a vehicle's Control, Speed and Body as printed, and
      the names of the parts a location lists (the Danger Room's event kinds).
  apps/marvel-heroes/data/adventures.json   FACTS: each adventure's sections -
      its introduction, numbered encounters and locales - by title and page,
      with the names of the parts each prints (Summary, Starting, Aftermath...).
  $WORKSHOP_MSH_CACHE/books/<slug>/extras.json and extras-text.sql
      THE PROSE, never committed: the parse, and msh_book_text rows (migration
      087) under entry ids item-<id> and <adventure>-<section>, applied with
          node scripts/d1-apply.mjs --remote --db marvel <that .sql>

HOW THE BOOK SETS THEM. Items and locations are run-in entries - "ACID BOMB:
This Brood weapon..." - under a heading (Special Items, Locations); a vehicle
follows its run-in with Control:, Speed: and Body: lines. An adventure's
sections are headers ("Encounter 3" over "Fe Fi Fo Fum", "The Federal
Building"), and each divides into run-ins (SUMMARY:, STARTING:, ENCOUNTER:,
AFTERMATH:, KARMA:). A run-in inside a location that names one of its parts
(the Danger Room's ENERGY WEAPONS, MISSILES...) is listed in the registry's
item_parts, because nothing in the type tells it from a new item.
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


def adventure(book, slug):
    """{title, pages, sections: [{title, number?, page, parts: [...], text: [...]}]}"""
    title = book['adventure']['title']
    sections, cur, pending_number = [], None, None
    for line in stream_for(book, slug, book['adventure']['pages']):
        if line.get('synthetic'):
            continue
        if line.get('big'):
            t = line['text'].strip().rstrip(':\\').strip()
            num = re.match(r'^Encounter\s+(\d+)$', t)
            if num:
                pending_number = int(num.group(1))
                cur = {'title': 'Encounter %d' % pending_number, 'number': pending_number, 'page': line['printed'],
                       'parts': [], 'text': [['prose', None, []]]}
                sections.append(cur)
                continue
            if pending_number is not None and cur and cur.get('number') == pending_number and cur['title'].startswith('Encounter'):
                cur['title'] = 'Encounter %d: %s' % (pending_number, t)
                pending_number = None
                continue
            pending_number = None
            cur = {'title': t, 'page': line['printed'], 'parts': [], 'text': [['prose', None, []]]}
            sections.append(cur)
            continue
        if cur is None:
            continue
        # An encounter's title set a size up from the text but read as prose by
        # the header test, because its apostrophe OCRs as U+FFFD ("It\ufffds All
        # Done With Mirrors") and splits a word: the line straight after
        # "Encounter N", set tall, is that title.
        if pending_number is not None and line['h'] >= 1.3 * line['body_h']:
            cur['title'] = 'Encounter %d: %s' % (pending_number, line['text'].strip().replace('\ufffd', "'"))
            pending_number = None
            continue
        pending_number = None
        m = run_in(line)
        if m:
            label = small_caps_title(m.group(1).strip())
            cur['parts'].append(label)
            cur['text'].append(['section', label, [m.group(2)]])
            continue
        cur['text'][-1][2].append(line['text'])
    return {'title': title, 'pages': book['adventure']['pages'], 'sections': sections}


def main(slug):
    book = json.load(io.open(roster.REGISTRY, encoding='utf-8'))['books'][slug]
    its = items(book, slug)
    adv = adventure(book, slug)
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

    item_out = []
    for it in its:
        iid = 'item-' + npcs.slug(it['name'])
        text_rows(iid, it['text'], it['page'])
        item_out.append({'id': iid, 'name': small_caps_title(it['name']), 'kind': it['kind'], 'page': it['page'],
                         **({'vehicle': it['vehicle']} if it['vehicle'] else {}),
                         **({'parts': it['parts']} if it['parts'] else {})})
    aid = npcs.slug(adv['title'])
    sec_out = []
    for s in adv['sections']:
        sid = '%s-%s' % (aid, npcs.slug(s['title'].split(':')[0] if s.get('number') else s['title']))
        text_rows(sid, s['text'], s['page'])
        sec_out.append({'id': sid, 'title': npcs.ascii_fold(s['title']), 'page': s['page'],
                        **({'number': s['number']} if s.get('number') else {}), 'parts': s['parts']})
    ids = [r[0] for r in rows]
    assert len(ids) == len(set(ids)), 'duplicate keys'
    assert len({i['id'] for i in item_out}) == len(item_out) and len({s['id'] for s in sec_out}) == len(sec_out), 'duplicate ids'

    about = lambda what: [
        '%s from %s, built by scripts/msh/extras.py from the OCR of the book.' % (what, book['title']),
        "Facts only: names, kinds, pages, a vehicle's printed Control, Speed and Body, and the names of the parts each prints. "
        "The book's prose is in D1 (msh_book_text, migration 087), keyed %s:<id>:<part>:<n>, and never in this file." % slug,
    ]
    src = [{'book': book['title'], 'code': book['code']}]
    io.open(os.path.join(DATA, 'items.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(
        {'about': about('Items and locations'), 'sources': [dict(src[0], pages='%d-%d' % tuple(book['item_pages']))],
         'book': slug, 'items': item_out}, indent=1, ensure_ascii=True) + '\n')
    io.open(os.path.join(DATA, 'adventures.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(
        {'about': about('The adventure'), 'sources': [dict(src[0], pages='%d-%d' % tuple(adv['pages']))], 'book': slug,
         'adventures': [{'id': aid, 'title': adv['title'], 'pages': adv['pages'], 'sections': sec_out}]},
        indent=1, ensure_ascii=True) + '\n')
    cache = os.path.join(roster.CACHE, 'books', slug)
    io.open(os.path.join(cache, 'extras.json'), 'w', encoding='utf-8', newline='\n').write(json.dumps(
        {'items': its, 'adventure': adv}, indent=1, ensure_ascii=False) + '\n')

    def q(v):
        return 'NULL' if v is None else str(v) if isinstance(v, int) else "'" + v.replace("'", "''") + "'"
    sql = ["-- msh_book_text: %s's items, locations and adventure, written by scripts/msh/extras.py. NEVER COMMIT: the book's text." % slug,
           "DELETE FROM msh_book_text WHERE book = '%s' AND (entry LIKE 'item-%%' OR entry LIKE '%s-%%');" % (slug, aid)]
    sql += ['INSERT INTO msh_book_text (key, book, entry, part, name, page, body) VALUES (%s);' % ', '.join(q(v) for v in r) for r in rows]
    io.open(os.path.join(cache, 'extras-text.sql'), 'w', encoding='utf-8', newline='\n').write('\n'.join(sql) + '\n')
    print('%s: %d items (%d vehicles, %d locations), adventure "%s" in %d sections (%d numbered encounters); %d text rows'
          % (slug, len(item_out), sum(1 for i in item_out if i['kind'] == 'vehicle'), sum(1 for i in item_out if i['kind'] == 'location'),
             adv['title'], len(sec_out), sum(1 for s in sec_out if 'number' in s), len(rows)))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else sys.exit('usage: extras.py <slug>'))
