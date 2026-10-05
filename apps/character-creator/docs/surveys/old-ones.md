# The Palladium RPG Book II: Old Ones — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. The edition question under *Extraction plan* comes first. (2026-10-05)

**Rows citing this book:** none

Slug `old-ones`. Cached 2026-10-05 from
`959867819-PFRPG-Book-02-Old-Ones.pdf`, 218 PDF pages, **text layer** (no
OCR). `--probe` median 6,121 chars/page.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## This is the first-edition book

The copyright page (cache `p003`) gives a 1984 copyright and a fifth
printing dated January 1993, under the title *The Palladium RPG Book II: Old
Ones*. The file name calls it a Palladium Fantasy book, but it is **not**
the 1996 second-edition *Old Ones*. The two Palladium Fantasy books already
registered (`pf` and `dag`) are both 1996 second-edition printings.

That matters for everything mechanical in it. Its three character classes
and every stat block were written for the first-edition rules. Whether the
catalog should hold first-edition rows beside second-edition ones is a
decision for Nate, and nothing is extracted until it is made.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 7` — cache file page = printed folio + 7, so printed folio F is
`p<F+7>.txt` and `read-columns.py <F+7>`.

Checked by reading the folio in the cached page:

| cache page | folio printed on it |
|---|---|
| `p011` | 4 |
| `p012` | 5 |
| `p020` | 13 |
| `p050` | 43 |
| `p100` | 93 |
| `p150` | 143 |
| `p200` | 193 |
| `p217` | 210 |

One region, no `page_offset_exceptions`. Printed 1 is cache `p008`. Cache
`p001`-`p007` are cover, notice and copyright, title, the Contents and list
of maps (`p005`-`p006`) and a map key. **`printed_pages` is 210**, at cache
`p217`; `p218` is blank.

## Cache health

This is the most damaged text layer registered so far.

| key | count | where it matters |
|---|---|---|
| `welded_pages` | 38 pages | cache 4-7 (front matter), 12 and 14 (**the Illusionist's tables and powers**), then scattered through the town and fort write-ups (22-142) and 171-174 in the last adventure. Read every one of them from a render |
| `corrupt_pages` | 51 pages | worst: cache p39 (18), p44 (12), p56 and p121 (11 each), p36 and p104 (9 each). Most are pages that carry a hand-lettered town map, where the map lettering comes through as noise; the prose around it is suspect too |
| `substituted_digits` | 21 pages | worst: cache p94 (26), p114 (24), p30 (15), p63 (14), p36 (13). These are town and fort pages with population and garrison figures. Read each token as the number it can only be |

**No number in this book is taken from the cache.** Every figure that would
enter a row is read off a render.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | front | *Table of Contents* | the printed page of every section, city, town, fort and adventure |
| **p006** | front | *List of Maps* | the page of every map |
| **p011** | 4 | the Illusionist's level table | experience levels for the class |
| **p013-p015** | 6-8 | *Power Descriptions* | the fifteen levels of illusion, by level heading |
| **p020** | 13 | *Timiro Encounter Tables* | random encounters; G.M. material |

The Contents reads cleanly through `read-columns.py` except for a few lines
whose page numbers are lost (Nibis, Sino, Fort Mirr and Fort Pont among
them); those pages come from the headings in the body.

## Inventory

Counted by structure (headings by font size, and stat-block markers per
page) over all 218 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Glossary, travel | front, 1 | terms and travel rules |
| Monks | 2-3 | **1 optional O.C.C.** |
| Illusionist | 4-8 | **1 optional O.C.C.**, its level table (4) and **15 levels of illusion powers** (6-8), each with a cost line |
| The Timiro military, magic, laws, history | 9-12 | lore and a kingdom map (12) |
| Encounter tables, animals, wilderness | 13-16 | G.M. tables; animals in brief |
| Cities | 17-59 | **8 cities** (Acoroc, Aracho, Credia, Old Timiro, Rankin, Smia, Tanis, Tomoro), each with keyed maps; **1 optional O.C.C.**, the Lumber-Jack, inside Tanis (54) |
| Towns | 60-115 | **25 towns**, most with a keyed map |
| Forts | 116-130 | fort types (116-119) and **21 forts** |
| Game Master's Section | 131-210 | eight adventures: the Mystic Parcel (131), the Giant Firebrand (134), Ogre Invasion (137), the Ogre Caravan (139), the Hidden Temple (141), the Forest of Enchantment (151), the Secret Complex of the Old Ones (157), the Place of Magic (161); a closing note on the Old Ones (208) |

`Alignment:` opens **115 lines on 50 pages**: the rulers, garrison
commanders and shopkeepers of the towns and forts, and the cast of the
adventures. That is a count of markers, read from a damaged text layer, and
the people are counted from renders.

### Spells: zero

No spell description is printed. The illusion powers are the Illusionist's
own ability ladder with I.S.P. costs, not spells.

### Skills, gear, vehicles: zero

No skill list, price list or vehicle entry. Shop inventories in the town
keys name ordinary goods.

## Classes

| class | printed | note |
|---|---|---|
| Monk (optional O.C.C.) | 2-3 | attribute requirements and a skill list |
| Illusionist (optional O.C.C.) | 4-8 | attribute requirements, a skill list, a level table and fifteen power levels |
| Lumber-Jack (optional O.C.C.) | 54 | three lines inside the Tanis write-up: requirements and a short skill list |

All three are first-edition classes.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05.

### classes: 3 entries, 0 held

The catalog's `monk` is a Rifts class, and its Palladium Fantasy
`warrior-monk` is a different, second-edition class. No Illusionist and no
Lumber-Jack is held in any system.

### psionic_powers: the illusion ladder is not held

The one near name, `Mental Illusion`, is a different power. The fifteen
levels here are steps of one class ability (sound, then image, smell, taste
and touch, then combinations), which is closer to a class feature than to
fifteen catalog powers.

### notable_npcs: none held

Production holds 73 Palladium Fantasy NPC rows and none cites this book. The
115 stat blocks here were not diffed by name, because the names cannot be
trusted from this text layer.

## Extraction plan

**Nothing is planned until the edition question is answered.** The choices:

1. **Leave the book out** (`excluded`). Its mechanics are first-edition and
   the catalog's Palladium Fantasy rows are second-edition.
2. **Import the people and places only.** The named rulers, commanders and
   adventure cast as `notable_npcs`, with first-edition figures recorded as
   printed and each row saying it is first edition.
3. **Import the three classes as well**, as first-edition classes. That
   needs a ruling on how a first-edition class sits beside second-edition
   ones in the picker, which is a code question, not a data one.

If any of it is imported, every page is read off a render, and the work is
split by section: classes (printed 2-8, 54), then towns and forts (17-130),
then the adventures (131-210).

What is left under every choice:

- **Town, city and fort maps and their keys** — places.
- **The encounter tables and the animals in brief** (13-15) — G.M. material.
- **The eight adventures as adventures** — only their casts are candidates.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/old-ones-survey` | cache built (218 pp), `old-ones` registered in `books.json`, this survey written, offset +7 verified, the edition recorded. No data. |

### What remains

The edition decision, and then everything that follows from it. Nothing from
this book has been imported.
