# Rifts World Book 12: Psyscape — survey

**Status:** `importing` — psionic powers shipped; gear next, then classes. (2026-09-25)

**Rows citing this book:** psionic_powers 16

Slug `psyscape`. Cached 2026-09-25 from `Rifts- World Book 12 Psyscape.pdf`,
162 PDF pages, **text layer** (no OCR). `--probe` median 5,172 chars/page,
36.1% stop words, so this is a real text layer and not the glyph-dropped kind
(`BOOK-INGEST-AUDIT` F73). Second printing, 1999; copyright 1997.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on five pages:

| cache page | folio printed on it | offset |
|---|---|---|
| `p020` | 19 | +1 |
| `p080` | 79 | +1 |
| `p120` | 119 | +1 |
| `p160` | 159 | +1 |
| `p161` | 160 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 158.** The
Experience Tables are printed 157 (cache `p158`), and printed 158 (cache
`p159`) is a map of eastern North America with no text. Printed 159-160 are
Rifter house ads and `p162` is the back cover. `ocr-book.py` wrote 160 into
the manifest because it counted the ads.

## Cache health

| key | pages | where it matters |
|---|---|---|
| `welded_pages` | 5, 6, 8, 27, 40, 52 | 5/6/8 are the contents and index. **27 = printed 26** (City of the Mind's Eye, lore), **40 = printed 39** (Intuitive Combat / Machine Ghost descriptions), **52 = printed 51** (the Burster's fire powers). Read 40 from a render before transcribing those two powers |
| `corrupt_pages` | 5 (6), 147 (1), 159 (3) | contents page, one stray glyph on printed 146, and the map labels. No stat block affected |
| `substituted_digits` | 50 pages | nearly every class and monster page. Heaviest: `p025` (Nxla), `p138` (Zaayr), `p095` (Dark Behemoth), `p116` (Vyarnect). Read `!D4xlO` as 1D4x10: the damage is in the ink, so a render does not fix it |
| **not flagged, still broken** | printed 157 | the Experience Tables have 13 ladders in five columns; the cache keeps the headers and loses which numbers belong to which. **Read from a render** (done for this survey, below) |

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** (cache p005-p006) | *Contents* | the page of every section, class and monster |
| **6-8** (cache p007-p009) | *Index* | alphabetical, welded. Use the contents |
| **35-36** (cache p036-p037) | *Complete Alphabetical Listing* of psionic powers | every power a psychic can take, by category, with its I.S.P. cost in parentheses and either a Rifts RPG page (a reprint pointer) or **New**. Mind Bleeder powers are listed apart and all new |
| **29** (cache p030) | Psyscape populace | the master-psychic class mix of the city, by percentage. Setting only |
| **157** | *Experience Point Tables* | thirteen printed ladders and a note that three dragon-type classes use the Dragon R.C.C.'s |

**The alphabetical listing is the authority for names, categories and costs.**
Each new power's description (printed 36-48) repeats its I.S.P. cost, so costs
are printed twice and are reconciled, not transcribed.

### The XP ladders (printed 157), read off a render

| ladder | classes |
|---|---|
| Burster, Mystic & Psi-Stalker | reprints; all three already in production |
| Mind Bleeder | Mind Bleeder |
| Mind Melter | reprint; in production |
| Psi-Druid, Psi-Ghost, Darkhound | three classes |
| Psi-Tech, Nega-Psychic & Zapper | three classes |
| Psi-Nullifier, Psi-Warrior | two classes |
| Zenith Moon Warper, Lanotaur Hunter | two classes |
| Amorph, Psi-Slayer, Yhabbayar Bubblemaker | three classes |
| Dragon-Cat | Dragon-Cat |
| Dragon-Ape | an NPC-only monster, but a ladder exists |
| Psymbiote, Psi-Goblin | Psymbiote is NPC-only; Psi-Goblin is playable |
| Power Leech | NPC-only, but a ladder exists |
| Vyarnect | NPC-only villain, but a ladder exists |
| *same as the Dragon R.C.C.* | Demon-Dragonmage, Zaayr Crystal Dragon, Lipoca Sun Demon |

## Inventory

Counted by structure over all 162 cached pages: `I.S.P.:` lines for powers,
the four class markers (`Attribute Requirement`, `O.C.C. Skills`,
`R.C.C. Skills`, `Standard Equipment`) for classes, and the monster stat fields
(`M.D.C.`, `Horror Factor`, `Size`, `Weight`, `Alignment`). Then each hit was
checked by hand.

| section | printed | what is there |
|---|---|---|
| Introduction, Psyscape Legends (Erin Tarn) | 9-15 | lore |
| Dark Harvest | 15-24 | fiction, then the **Harvester O.C.C.** (17-21, stated NPC-only), **Soulless Xombie** (21-22, a monster) and **Nxla, Harvester of Souls** (22-24, a named NPC with a stat block) |
| Enter Psyscape | 24-31 | G.M. notes, Psynex, City of the Mind's Eye, populace, the special powers of Psyscape's own psychics (29-30), places of note. Setting |
| Psychics & Psionic Powers | 32-48 | the minor/major/master rules (32-34), the **alphabetical listing** (35-36), **43 new power descriptions** (36-48): 2 Healing, 7 Physical, 9 Sensitive, 10 Super, 15 Mind Bleeder |
| Psychic Character Classes | 48-83 | **11 psychic R.C.C.s** (the class table below). Burster and Mind Melter are reprints |
| Psi-Stalker note | 83 | prose about Psi-Stalkers raised in Psyscape; no stat block |
| Mutants & Other Psychics, Psi-Cola | 83-90 | the psychic-drug **Psi-Cola**: effects, psychic effects, addiction and side-effect tables, legality and price (88), **Fake Psi-Cola** (90) |
| Monsters | 91-116 | **11 monster entries** plus notes on the Spiny Ravager and on dragons (115-116, no stats) |
| D-Bees of Note | 116-139 | **8 R.C.C.s** |
| The CS & Psionics | 141-148 | Psi-Battalion (lore, organisation), the bonuses from CS psionic training (145), and **Lt. Col. Carol Black** (147), a named NPC with full stats |
| Psionic Technology | 148-156 | psi-implants: side-effect and removal tables (149-151), **7 named implants** (152-153); then **11 psionic devices and Techno-Wizard items** (154-156) |
| Experience Tables | 157 | the table above |
| Map | 158 | no text |

### Things this book has zero of, checked rather than assumed

- **Skills: none defined.** Every `Base Skill:` hit (19 across printed 30-123)
  is a class ability with its own percentage, not a skill row. Every
  "new skills" hit is the usual "additional skills at levels N" clause.
- **Spells: none defined.** The Yhabbayar's Bubble Magic (printed 132-133)
  puts existing spells and psi-powers inside bubbles, with an I.S.P. surcharge
  table for bubble features. It is a class ability and stays prose on that
  class. The Harvester's soul powers are NPC abilities.
- **Vehicles: none.** No vehicle stat block. The TK artificial limbs are gear.

## Psionic powers

`catalog-diff.mjs --remote --table psionic_powers --compare category,isp`
against the 43 new entries, 2026-09-25: **matched 25, disagree 1, missing 17,
plus 1 matched only by an alias.** Almost everything outside the Mind Bleeder
list came into the catalog from Rifts Ultimate Edition, which reprinted it.

| result | powers | action |
|---|---|---|
| matched (25) | Restore P.P.E., Suppress Fear, Deaden Senses, Ectoplasmic Disguise, Telekinetic Leap/Lift/Punch/Push, Intuitive Combat, Machine Ghost, Mask I.S.P. & Psionics, Mask P.P.E., Read Dimensional Portal, Remote Viewing, Sense Dimensional Anomaly, Sense Time, Group Trance, Psionic Invisibility, Psychic Omni-Sight, Psychosomatic Disease, Radiate Horror Factor, the three Telemechanic powers | none. They cite RUE, the later book |
| alias | the book's *Commune with Spirits*; the catalog's *Commune with Spirit* | none |
| disagree | *Telekinetic Acceleration Attack*: listed Physical here, **Super** in the catalog | **none.** RUE, the later edition, files it Super; the later book wins |
| false gap | *Pyschic Body Field*, the listing's misprint | none. The description heading (printed 43) spells it *Psychic Body Field*, which the catalog holds |
| **missing (16)** | **Astral Golem** (Super, 50+), and all fifteen **Mind Bleeder** powers: Bleed Aura (6), Bleed P.E. Energy (10), Bleed Memory (6), Bleed Skills (15), Bleed Truth (8), Brain Bleed (10), Brain Scan (10), Day Dream (8), Healing Leech (6), Impervious to Bio-Manipulation (10), Mental Block (10 or 30), Mental Block Removal (12 to 200), Mind Trip (6), Neuro-Touch (4 to 14), Neural Strike (25) | new rows |

The near-matches the diff offered (*Steal Memory*, *Steal Skills*,
*Mind Block*, *Healing Touch*, *Alter Aura*) were all checked, and none is the
same power.

**Category, decided at survey:** the fifteen Mind Bleeder powers go in as a new
`Mind Bleeder` category. Phase World's `Phase` category is the precedent, a
class-exclusive list that went in as data with no code change (#417). Five
powers have variable costs (`10 or 30`, `12 to 200`, `4 to 14`, `50+`). They
store the low figure in `isp` and the printed range in the description. That is
the catalog's convention: Telekinetic Acceleration Attack (10-20) holds 10 and
Telekinesis (varies) holds 3, checked 2026-09-25.

## Classes

Production (2026-09-25) holds `burster` and `mind-melter` from RUE, and no
class citing this book.

### Playable R.C.C.s (17)

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| Mind Bleeder | 52-55 | Mind Bleeder | `mind-bleeder` | selects from the new `Mind Bleeder` category |
| Nega-Psychic | 57-59 | Psi-Tech/Nega/Zapper | `nega-psychic` | its powers work only against the supernatural and are always on. Mostly prose |
| Psi-Druid | 59-62 | Psi-Druid/Ghost/Darkhound | `psi-druid` | two plant/weather abilities with base percentages |
| Psi-Ghost | 63-66 | Psi-Druid/Ghost/Darkhound | `psi-ghost` | |
| Psi-Nullifier | 66-69 | Nullifier/Warrior | `psi-nullifier` | |
| Psi-Slayer | 69-74 | Amorph/Slayer/Yhabbayar | `psi-slayer` | P.P.E. drain from prey is prose |
| Psi-Tech | 74-76 | Psi-Tech/Nega/Zapper | `psi-tech` | its repressed alter ego is prose |
| Psi-Warrior | 76-80 | Nullifier/Warrior | `psi-warrior` | Psi-Sword bonuses are a class block |
| Zapper | 81-83 | Psi-Tech/Nega/Zapper | `zapper` | Electrokinesis at double strength |
| Darkhound | 95-98 | Psi-Druid/Ghost/Darkhound | `darkhound` | listed among the monsters; NPC villain and **optional player R.C.C.** |
| Dragon-Cat | 100-101 | Dragon-Cat | `dragon-cat` | optional player character, young when played |
| Amorph | 117-119 | Amorph/Slayer/Yhabbayar | `amorph` | optional player character; an ectoplasmic intelligence |
| Demon-Dragonmage | 120-123 | same as Dragon R.C.C. | `demon-dragonmage` | optional player character as a Young-Dragonmage |
| Psi-Goblin | 128-129 | Psymbiote/Psi-Goblin | `psi-goblin` | optional player character. Distinct from PF's `goblin` |
| Yhabbayar Bubblemaker | 130-134 | Amorph/Slayer/Yhabbayar | `yhabbayar` | a Mystic R.C.C.; Bubble Magic is prose |
| Zaayr Crystal Dragon | 135-137 | same as Dragon R.C.C. | `zaayr-crystal-dragon` | playable **as a hatchling only**. Refers back to the Rifts RPG hatchling rules |
| Zenith Moon Warper | 138-139 | Warper/Lanotaur | `zenith-moon-warper` | optional player character |

**One for Nate: the Lanotaur Hunter** (printed 123-125). Its block is headed
NPC Villain with no player note, which by the South America precedent
(Aunyain) makes it a creature. But the book gives it an XP ladder shared with
the playable Zenith Moon Warper. The plan below makes it a **class with a
G.M.-permission note**, as `cibola-gatherer` was, unless Nate says otherwise.

### Reprints, left alone

- **Burster** (printed 48-52) and **Mind Melter** (55-57): in production from
  RUE p.139-142 and p.150-151. The later edition wins, and this book's copies
  are not imported.
- **Psi-Stalker** (83): a note, not a stat block.

### NPC-only, by the book's own notes

The **Harvester** O.C.C. (17-21) and the Power Leech, Psymbiote, Dragon-Ape and
Vyarnect R.C.C.-shaped blocks each carry a note that they are not for players.
They become **creatures**. Several have ladders anyway (Power Leech, Psymbiote,
Dragon-Ape, Vyarnect), and the creature rows can say so.

## Gear

| group | printed | rows | note |
|---|---|---|---|
| Psi-Cola | 84-90 | 2 | Psi-Cola and Fake Psi-Cola. Price and legal status on 88-89. The addiction and side-effect tables are prose on the row |
| Psi-implants | 152-153 | 7 | Psi-Blocker, Psionic Inhibitor, Psionic Booster, Psionic Actuator, Sensitive, Physical Reactor, Eruptor. The side-effect and removal tables (149-151) are prose |
| CS psionic devices | 154-155 | 4 | Psionic Weapon Gauntlet, TK Artificial Limbs, Psi-Damper Helmet, Psi-Scanner. Several are **Status: Experimental** |
| Techno-Wizard items | 155-156 | 7 | TW Psi-Blocker Helmet, TW Psi-Bloodhound tracker, TW TK Pistol, TW TK Assault Rifle, TW Flamethrower, Psychic Camera, TW Thought Projector. Priced partly as **P.P.E. cost to make** |

**About 20 gear rows.** No gear row cites this book in production today, and no
`Psi-Cola` or implant name exists.

## Creatures and notable NPCs

**Creatures (16):** Soulless Xombie (21-22), Harvester (17-21, NPC-only
O.C.C.), Blood Hawk (92-93), Dark Behemoth (94-95), Dragon-Ape (99), Land Ray
(101-102), Necrophim and Soul Snake (103-105, two creatures on one entry),
Psymbiote (105-108), Shadeling (108-109), Lipoca Sun Demon (109-112), Vyarnect
(113-115), Lanotaur Hunter's NPC view if it goes in as a class, and Power Leech
(126-128). Plus the playable R.C.C.s' NPC views where past imports added one.

**Notable NPCs (2):** **Nxla, the Harvester of Souls** (22-24) and **Lt. Col.
Carol Black** (147). Callaway and the other characters of the *Dark Harvest*
fiction have no stat blocks and are left out.

Production holds none of these names in `creatures` or `notable_npcs`.
*Tezcatlipoca*, which matched a "Lipoca" search, is Pantheons' god.

## Extraction plan

Everything above cost nothing. The work in order, one PR each, applied
`--remote` before the PR, powers and gear before classes, so class drafts find
real rows:

1. **Registry and survey**: this file and the `books.json` entry.
2. **Psionic powers**: 16 rows. Astral Golem, plus the fifteen Mind Bleeder
   powers in a new `Mind Bleeder` category. Must land before the Mind Bleeder
   class.
3. **Gear**: about 20 rows. Every number is checked against the page, and
   printed 152-156 are read from a render.
4. **Psychic R.C.C.s**: the nine new ones, printed 52-83.
5. **D-Bee and monster R.C.C.s**: the eight playable ones, printed 95-139, plus
   the Lanotaur Hunter if Nate agrees.
6. **Creatures and notable NPCs**, through the Phase 3 pipeline.

What is deliberately left, with the reason:

- The Burster and Mind Melter: reprints of RUE, the later edition.
- Telekinetic Acceleration Attack's category: RUE files it Super, and RUE wins.
- Bubble Magic, the Psi-Cola addiction tables, the implant side-effect tables
  and the CS training bonuses: rules with no row shape. Each stays prose on the
  class or gear row it belongs to.
- The Psyscape city's special psychic powers (29-30): setting abilities of the
  city's people, with no stat blocks.
- The Spiny Ravager and dragon notes, the fiction, and the lore chapters.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-25 | — | cache built (162 pp, text layer), offset +1 verified at five folios, `psyscape` registered in `books.json`, survey written |
| 2026-09-25 | (this PR) | **psionic powers**: Astral Golem (Super, printed 42) and the fifteen Mind Bleeder powers (printed 45-48) in a new `Mind Bleeder` category, `add-psyscape-psionic-powers.sql`. Catalog 133 -> 149 psionic powers. Descriptions paraphrased; every cost read twice (listing and block) and checked by `book-reconcile`, one note wording fixed. Applied `--remote` before the PR. |
