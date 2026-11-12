# Rifts World Book 3: England — survey

**Status:** `importing` — Mystic Herbology, the 31 gear rows, the Millennium Tree comparison all seventeen creatures and twelve NPCs (Zazshan, Mrrlyn, the Lady of the Lake, Guinevere, Arr'thuu, Prrcyvel, Dred, Galahad, and the gods Balor II, Bres, Lugh and Dagda) and seven classes (Herbalist, Filidh, Dryad, Scathach, Millennium Druid, Earth Child, Star Child) shipped; the other classes are next. The plan is under *Extraction plan*. (2026-11-12)

**Rows citing this book:** classes 7, gear 31, skills 1, notable_npcs 12, creatures 17

Slug `england`. Cached 2026-11-12 from `Rifts - World Book 03 - England.pdf`,
154 PDF pages, **text layer** (`--probe` median 5,301 chars/page).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions.

| cache page | folio printed on it |
|---|---|
| `p027` | 26 |
| `p050` | 49 |
| `p075` | 74 |
| `p100` | 99 |
| `p130` | 129 |
| `p148` | 147 |
| `p152` | 151 |
| `p153` | 152 (read off a render; the folio is not in the text layer) |

`printed_pages` is 152, not the manifest's 151. Cache `p154` is blank.

Text-layer damage, by cache page (the manifest's three keys):

- welded (both columns in one block; read off a render): 5, 6, 10, 23, 28, 114, 150, 151
- glyph-corrupt (render before trusting any number): 6, 42, 119, 120, 122, 123, 124, 149
- digit-substituted (read the token as the dice expression it can only be): 25, 37, 61, 70, 72, 73, 104, 109, 119

Cache 120 and 122-124 (printed 119, 121-123, the British Isles gazetteer) were
never rendered. No row in the plan rests on them.

## The book's authority tables

| page | table | states |
|---|---|---|
| **152** | *O.C.C. & R.C.C. Experience Tables* | eleven ladders, and which class uses which |
| **5** | *Quick Find Table* | a second index; marks which races are R.C.C.s. Welded: read off a render |
| **83** | list of temporal spells | 25 names by level |
| **32** | list of herb-magic powers | the herb items by kind |

Printed 152 is the more valuable, and it was read off a render. Its ladders:
Chiang-Ku Dragon (1-15) with Ancient Chiang-ku (16-26); Dabugghs, Earth & Star
Child; Temporal Warrior; Temporal Wizard, Cernun Serpent & Ogeeyin; Temporal
Raider; Millennium Druid; Herbalist, Woodland Druids, Blood Druids (a note says
Woodland Druids are the Dryad, Filidh and Scathach); Knights of Camelot, Royal
Knights & Human Nexus Knights; Knights (general); Mantaz Sectle. It also
reprints the Warlock & Witch ladder, which belongs to the Conversion Book.

Two entries disagree with it. The Mantaz Sectle entry (58) says to use the
Earth and Star Child table; 152 prints a Mantaz Sectle ladder of its own. The
Cernun entry (59) says to use the Mystic's table; 152 groups the Cernun with
the Temporal Wizard. **152 wins for both** (it names each class; the entry
lines are the NPC average-level lines), and the entry's reading goes in each
class's `extraction_notes`.

Levels and costs are printed once, except temporal spells (list on 83 and each
description on 74-83).

## Inventory

| section | printed pages | what is there |
|---|---|---|
| Millennium Trees | 9-21 | tree gifts 15, wands 18, staves 20, corrupted items 21: 24 items; one partial tree block (14) |
| Herbalist, herbs, herb magic | 22-37 | 1 class, 1 skill (22), 67 herb-magic items (27-32), 26 herbs-of-legend items (33-37) |
| Woodland Druids | 38-43 | 3 classes (Filidh 39, Dryad 40, Scathach 41); 23 Scathach items (41-42) |
| Millennium Druid | 44-45 | 1 class |
| Chiang-Ku | 46-50 | 1 class and creature; the Elixir of Power and Deceit (49-50) |
| Earth Child, Star Child | 51-54 | 2 classes |
| Dabuggh, Mantaz Sectle, Cernun | 55-59 | 3 optional player races, each with a full block |
| Monsters | 60-66 | 6 creature kinds |
| Temporal magic | 66-83 | 3 classes (Wizard 66, Warrior 69, Raider 71); 25 spells (74-83) |
| Camelot's powers | 84-97 | Zazshan, Mrrlyn, Lady of the Lake, Guinevere; Zllyphan, Supreme Nexus Knights, Ghost Knights |
| Knights | 98-110 | human Nexus Knight (98), Knight (100), Royal Knight (103); Arr'thuu, Prrcyvel, Dred, Galahad; Caliber X (106-107) |
| New Camelot | 110-113 | Bionic Centre price list (113): 5 items |
| British Isles | 113-124 | 15 people with attributes, level and alignment but no hit points or combat; Eternal Spring water (118) |
| Celtic gods | 125-131 | Fomorians (125-126); Balor, Bres, Lugh, Dagda |
| Ireland | 132-137 | prose; level-only names |
| Adventures, Ogeeyin | 138-145 | Ogeeyin (142-144, two forms); the Golden Table (144-145) |
| France, Blood Druids | 145-147 | 1 class in O.C.C. format, marked an NPC villain |
| Experience Tables | 152 | the authority table |

**No vehicle, robot or power-armor stat block**, and **no psionic power** is
defined: the stat-block scan found none, and the bestiary pass found only the
prose bionic-horse specs on 113.

## Classes

### Classes the plan imports — pages 22-144

| class | pages | XP table on p.152 |
|---|---|---|
| Herbalist | 22-25 | Herbalist / Woodland Druids / Blood Druids |
| Filidh | 39 | same |
| Dryad | 40-41 | same |
| Scathach | 41-43 | same |
| Millennium Druid | 44-45 | Millennium Druid |
| Chiang-Ku Dragon | 46-50 | Chiang-Ku Dragon (levels 16-26 do not fit the 15-entry `xp_table`) |
| Earth Child | 51-53 | Dabugghs, Earth & Star Child |
| Star Child | 53-54 | same |
| Dabuggh | 55-57 | same |
| Mantaz Sectle | 57-58 | Mantaz Sectle |
| Cernun | 58-59 | Temporal Wizard, Cernun Serpent & Ogeeyin |
| Temporal Wizard | 66-69 | same |
| Temporal Warrior | 69-71 | Temporal Warrior |
| Temporal Raider | 71-72 | Temporal Raider |
| Knight | 100-103 | Knights (general) |
| Royal Knight | 103-104 | Knights of Camelot, Royal Knights & Human Nexus Knights |
| Ogeeyin | 142-144 | Temporal Wizard, Cernun Serpent & Ogeeyin |

Ids that collide with a published class: `chiang-ku-dragon` and `knight` are
both Palladium Fantasy classes. This book's are `rifts-chiang-ku-dragon` and
`rifts-knight` (the `rifts-wolfen` precedent).

### Classes the book marks as not for players, or does not finish

Nate ruled on all four on 2026-11-12:

- **Temporal Raider** (71-72): the book offers it as an optional R.C.C. or an
  NPC and does not suggest it for players. It gets a class row and a creature
  row; its ladder is its own on 152.
- **Blood Druid** (145-147): an NPC villain written in O.C.C. format. No row
  of any kind.
- **Fomorian** (125-126): no ladder printed. A creature row only, no class.
- **Human Nexus Knight** (98-99): no skill lists; it is an overlay on the
  character's original O.C.C. This note only, no row.

## Catalog diff

Run against **production** on 2026-11-12: 0 rows cite this book in any table.

- **spells: 0 missing.** All 25 temporal spells are held as `Temporal: <name>`
  rows citing the Book of Magic, matching by name, level and base P.P.E. The
  five second P.P.E. figures this book prints are already in `ppe_note`.
- **skills: 1 missing**, Mystic Herbology (22). Faerie Speak and English need
  no row: a language rides `Language: Other`.
- **gear: 31 missing of 152 counted.** Held from later printings: 67 `herb-*`
  rows, 26 herbs-of-legend rows, 21 Millennium Tree rows, 4 Nexus Knight rows.
  Missing: 23 Scathach items (41-42), the Elixir of Power and Deceit (49-50),
  Caliber X (106-107), five Bionic Centre items (113), Eternal Spring water (118).
  False gaps checked: `magic-hammer` and `angel-horseshoes` (Mystic Russia),
  `herb-oak-throwing-stick`, `tw-throwing-irons` and the two Warlords of Russia
  bionic horses are different items.
- **gear, held and different: 3.** `millennium-vampire-slaying-javelin`,
  `millennium-throwing-stick` and `corrupted-millennium-wand-or-staff` (all
  citing Japan, 1995) carry figures this 1993 book prints differently.
  Done: each row's `description` now gives England's figure and page
  (`~275`); its figures and `source_book` still follow Japan.
- **creatures: 16 kinds missing**, 1 held in another system
  (`chiang-ku-dragon`, Palladium Fantasy).
- **notable_npcs: 12 missing.** `erin-tarn` is held from Coalition War
  Campaign; her letter here (7-8) has no block.
- **classes: 20 defined, 0 held.**

## Extraction plan

Approved by Nate 2026-11-12. One branch per line; each is an extraction row,
then a shipping row. Gear and the skill go before the classes that name them,
and a race's creature row before its class.

1. `pal/data/england-skill-and-gear`: Mystic Herbology (22); 31 gear rows:
   23 Scathach items (41-42), the Elixir of Power and Deceit (49-50) as one
   row, Caliber X (106-107), five Bionic Centre items (113) as gear, Eternal
   Spring water (118).
2. `pal/data/england-millennium-compare`: England's figures for the three
   held Japan rows go into their descriptions; `source_book` stays.
3. `pal/data/england-creatures-a`: 9 creatures, 55-66.
4. `pal/data/england-creatures-b`: 8 creatures: Temporal Raider, Zllyphan
   Energy Being, Supreme Nexus Knight, Ghost Knight, Fomorian, Ogeeyin natural
   and Guardian forms, `chiang-ku-dragon-england`.
5. `pal/data/england-npcs-a`: Zazshan, Mrrlyn, Lady of the Lake, Guinevere
   (85-91).
6. `pal/data/england-npcs-b`: Arr'thuu, Prrcyvel, Dred, Galahad (104-110).
7. `pal/data/england-npcs-gods`: Balor II, Bres, Lugh, Dagda (127-131), as
   notable NPCs.
8. `pal/data/england-classes-woodland`: Herbalist, Filidh, Dryad, Scathach.
9. `pal/data/england-classes-millennium-earth-star`: Millennium Druid, Earth
   Child, Star Child.
10. `pal/data/england-classes-dabuggh-mantaz-cernun`: Dabuggh, Mantaz Sectle,
    Cernun.
11. `pal/data/england-classes-temporal`: Temporal Wizard, Temporal Warrior,
    Temporal Raider.
12. `pal/data/england-classes-knights`: `rifts-knight`, Royal Knight.
13. `pal/data/england-class-chiang-ku`: `rifts-chiang-ku-dragon`.
14. `pal/data/england-class-ogeeyin`: Ogeeyin.
15. `pal/docs/england-close-out`.

What is left, and why:

- the 15 attribute-only people on 100-121 (Nate, 2026-11-12: D21 read as
  covering them);
- the Millennium Tree (14) and the Golden Table (144-145) (Nate, 2026-11-12:
  both left);
- level-only names (D21);
- the typical human Nexus Knight block on 99 (D22);
- the major life essence (inside Mrrlyn's block);
- the tectonic stone figures (one line, no block);
- the medicinal herb lists on 26-27;
- Erin Tarn (a letter, no block);
- no spell work: all 25 temporal spells are held, and the five second P.P.E.
  figures are already in `ppe_note`;
- no language skill rows.

Rulings that govern it: 2026-10-04, the newest printing that states a figure
wins; D21, no stat block, no NPC row; D22, typical-member blocks are left.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-11-12 | — | cache built (154 pp, text layer), offset +1 verified, inventory and production diff |
| 2026-11-12 | `pal/data/england-skill-and-gear` | 1 skill (Mystic Herbology) and 31 gear rows (`~274`), written through `scripts/rows-sql.mjs`. Applied `--remote` first. Status to `importing`. |
| 2026-11-12 | `pal/data/england-millennium-compare` | 3 held Millennium Tree gear rows (Japan) gained an England sentence in `description` (`~275`, hand-written). No figure or `source_book` changed. Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-creatures-a` | 9 creature rows, 55-66 (Dabuggh, Mantaz Sectle and Cernun playable), with 20 `stat_attacks` (`~276`), written through `scripts/bestiary-sql.mjs`. Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-creatures-b` | 8 creature rows, 48-50, 71-73, 85-97, 125-126 and 142-144 (Temporal Raider, Zllyphan Energy Being, Supreme Nexus Knight, Ghost Knight, Fomorian, Ogeeyin and Ogeeyin Guardian, `chiang-ku-dragon-england`; Temporal Raider, Ogeeyin and the Chiang-Ku playable), with 7 `stat_attacks` (`~277`), written through `scripts/bestiary-sql.mjs`. No attack for the Fomorian or either Ogeeyin form: the book prints no damage dice for them. Left: the Millennium Tree and the Golden Table (Nate, 2026-11-12), the major life essence, the tectonic stone figures, the typical human Nexus Knight (D22) and the Blood Druid (Nate, 2026-11-12: no row). Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-npcs-a` | 4 notable NPC rows, 85-91 (Zazshan, Mrrlyn, The Lady of the Lake, Lady Guinevere), with 6 `stat_attacks` (`~278`), written through `scripts/bestiary-sql.mjs`. Left: the major life essence (inside Mrrlyn's block, no row). Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-npcs-b` | 4 notable NPC rows, 104-110 (King Arr'thuu, Sir Prrcyvel, Sir Dred, Sir Galahad), with 30 `stat_attacks` (`~279`), written through `scripts/bestiary-sql.mjs`. Left: the 15 attribute-only people on 100-121 (Nate, 2026-11-12: D21 read as covering them), the level-only names (D21), the typical human Nexus Knight on 99 (D22) and Erin Tarn (a letter). Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-npcs-gods` | 4 notable NPC rows for the gods, 127-131 (Balor of the Poisonous Eye II, Bres the Beautiful, Lugh The Shining One, Dagda), with 14 `stat_attacks` (`~280`), written through `scripts/bestiary-sql.mjs`. Left: the faerie folk of Ireland on 132-134 (no block; the book refers to the Conversion Book) and the level-only names on 135-137 (D21). Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-classes-woodland` | 4 classes, 22-43 (Herbalist, Filidh, Dryad, Scathach), written through `class-check --emit-script`. Left: the Blood Druid (Nate, 2026-11-12: no row) and the medicinal herb lists on 26-27. Applied `--remote` first. |
| 2026-11-12 | `pal/data/england-classes-millennium-earth-star` | 3 classes, 44-54 (Millennium Druid, Earth Child, Star Child), written through `class-check --emit-script`. Left: the Millennium Tree (Nate, 2026-11-12: a creature row, not taken). The Earth Child's stone form and the Star Child's light form are in prose, not `mdc_base`. Applied `--remote` first. |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-11-12. Its `caches:`
line lists `england (154)`; its *BY BOOK* table prints no `england` line,
because no row in any table cites this book yet. Everything in the plan
remains.
