# The Palladium RPG Book II: Old Ones — survey

**Status:** `imported` — the plan is done: 144 notable NPCs and 9 creatures, every one marked first edition. Left out on purpose: the three classes, one-line people, the one-line residents of the Place of Magic, generic garrisons and the places themselves. (2026-10-05)

**Rows citing this book:** notable_npcs 144, creatures 9

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

## What Nate decided (2026-10-05)

Asked with a recommendation each; the answers are his.

1. **People only.** The named people and monsters go in; the Monk,
   Illusionist and Lumber-Jack classes do not. A stat block stands on its
   own, and a first-edition class would build a character on second-edition
   rules.
2. **Every full stat block.** A person is a row when the entry prints Hit
   Points with a level or class and an alignment. One-line people in the town
   code keys are counted below, not imported.
3. **A named being is a notable NPC; a kind of monster is a creature.**
4. **One-line dungeon residents fold into their kind.** The Place of Magic
   (printed 176-196) names 132 residents on a line each: a name, Hit Points,
   one or two powers and a height. They are not rows. The book prints a
   typical block for each kind, and those are the creature rows.
5. **Merge each PR when green.**

Every row says it is first edition: `bonuses_note` opens with that sentence
and `description` closes with one. Figures are as printed, including
first-edition damage ranges such as 1-8+2. No personal S.D.C. or P.P.E. is
entered, because the book prints none; an armour's S.D.C. sits with the
armour.

## What went in

Read from page renders, never the text layer. `book-reconcile` then checked
every row against the renders, by section.

| section | printed | notable NPCs |
|---|---|---|
| Cities | 17-59 | 9 (all in Credia, 34-38) |
| Towns | 60-115 | 12 (Arian, Baca, Hanna, Tanith) |
| Forts | 116-130 | 32 across 19 forts |
| The Mystic Parcel | 131-133 | 1 |
| The Giant Firebrand | 134-136 | 4 |
| Ogre Invasion and the Ogre Caravan | 137-140 | 6 |
| The Hidden Temple | 141-150 | 22 |
| The Forest of Enchantment | 151-156 | 2 |
| The Secret Complex of the Old Ones | 157-160 | 4 |
| The Place of Magic | 161-210 | 52, the seven Old Ones (210) among them |

**Creatures (9):** Serpent Beast (145-146), Mystic Spider (157), Monster Toad
(157), Serpent Man (158), Pseudo-Demon Guard (174), Low Caste Pseudo-Demon
(174), Tomb Worm (182), Minotaur (188, slug `minotaur-old-ones`), Zombie of
Artimus (199). Categories are the catalog's: monster, humanoid, undead.

### Left out, and counted

- **One-line people with no Hit Points**, roughly 600 across the code keys.
  The larger keys: Aracho about 110, Credia about 160 over three keys, Yria
  about 45, Acoroc about 30, Aria about 27, Hanna about 22. These are
  estimates made while reading, not tallies.
- **People with a partial block and no Hit Points:** Captain Jersi Braws and
  Lt. Camphar Moss (Fort Ac, 121), Sgt. Bull Tull (Fort Ibi, 127), Samoan
  Pletol (156), Cardinal Palance Medean (Old Timiro, 43-46), Dominana
  (Rankin, 50), Tanda (Smia, 54), and Antipator's three attendants (35).
- **The 132 one-line residents of the Place of Magic** (176-196): 98
  pseudo-demons, 17 minotaurs, and 17 dwarves, humans, orcs, ogres and a dog.
- **Animals printed inside an owner's block** are on the owner's row, in
  `allies` or the equipment line, not rows: Brother Bear's fox and two bears
  (63), the war horses Nightshade (65), Silver (122), Titan (126), Mad-Cap
  (130) and Kea-la (138), and the Mystic's weasel (167).
- **Unnamed groups that print Hit Points:** the Sword and Buckler guards
  (84), the red-bear knights (132-133), the raiders table (135), the ogre
  army (137-140), mummies, golems, skeletons and cave spiders of the Hidden
  Temple (145-148), the serpent man hunters (160), the four changelings
  (164), the twenty henchmen (208).
- **Beings with no Hit Points:** Xy the Great Old One (210), the imprisoned
  Old One of the pit (201-205), the seven Helmet of Rurga personas (193).

### Readings worth knowing

- The book spells the alignment *Abberant* in places; rows use *Aberrant*.
- Sir Arin Gatik's block says age 72 and the Tanith text says seventy-four
  (108, 110). The row holds 72.
- Kimmbot's block gives one true name and the room text another (207-208).
  One row, both names recorded.
- Grol-tee prints two damage bonuses (207-208). The row holds the Bonuses
  line's figure and notes the other.
- Three goblins of the Hidden Temple (150) print no race on their lines; the
  rows leave `race` empty and say why.
- The Monster Toad prints a range of 10 ft with nothing to say what it
  measures (157). It is in the note, not on the bite.

## Extraction plan, as surveyed

*Kept as the record of what was proposed. The section above is what was
decided and done.* The choices were:

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

| 2026-10-05 | `pal/data/old-ones-people-and-monsters` | 144 notable NPCs and 9 creatures with their attacks, one data script. Status to `imported`. |

### What remains

Nothing is planned. The three classes are out by decision; a first-edition
class in the picker would need a ruling and code. The one-line people and
residents are counted above if a later decision wants them.
