# Survey: MH2 Time Trap (TSR6853)

Marvel Super Heroes adventure module, Bruce Nesmith, 1984. Registry entry:
`scripts/msh/books.json` -> `mh2`. Measured 2026-10-21.

**Rows citing this book:** 91 `msh_book_text` rows over 20 character entries
in production (`DB_MARVEL`, read back 2026-10-21).

Committed: 20 characters in `apps/marvel-heroes/data/npcs.json` (12 full
blocks, 8 named one-line grids, and the Mimic's absorbed form as a second
block on his card), with 54 powers, 21 of them linked to the Ultimate Powers
Book, read by the `cover-panels` layout. No items and no adventure.

This is the seventh Marvel book, and the second of the five registered
together by the kickoff PR (#1917). It goes through `scripts/msh/` only. **It
is laid out as MH1 is**, the module before it in the same series:
[mh1.md](mh1.md) is the nearest worked example, and `cover-panels`
(`scripts/msh/coverpanels.py`, #1923) the nearest reader. Full blocks in
MHSP1's form (rank words, no numbers) on the two inside panels of a loose
cover and on two booklet pages, and one-line `F A S E R I P` grids inside the
chapters. **What differs from MH1** is listed under *Which reader fits*.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places, even the one with a stat line of its own (the
Skrull landing craft, below).

## The scan

- 22 PDF pages, a pure scan, already cached by the kickoff PR into the main
  checkout's `.cache/msh/books/mh2/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, written 2026-10-21).
- The print is clean. Tesseract reads the body text, the full blocks' label
  lines and the one-line grids' code rows well. It does not read the chapter
  titles (display lettering), the cover, or the maps. On three full blocks a
  mark of the portrait beside the column is read in front of a rank word
  (`<U+FFFD> AMAZING`, `| AMAZING`), and the grids' S and I letters are read as
  `Ss`, a section sign or `|`.

**The PDF is a booklet inside a loose folding cover, plus a map sheet**, the
same six pieces as MH1. Recorded as `parts` in the registry:

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2 | Inside front cover: the cards of Captain America, Starfox and the Wasp | - |
| 3-18 | Adventure Book | 1-16 |
| 19 | Inside back cover: the cards of Captain Marvel, the Scarlet Witch and the Vision | - |
| 20 | Back cover | - |
| 21-22 | Map: Avengers Mansion's main floor and the outdoors on one side, the Eternal Fortress on the other | - |

Unlike MH1's, the introduction does not say where the heroes' cards are. PDF
2 and 19 are identified as the cover's inside panels by what is on them (six
Avengers' cards, three a panel, no folio) and by where they sit, outside the
booklet's numbering on either side of it. The back cover describes the
module as a 16-page book and a two-sided map, which agrees.

## Offset

`scripts/msh/survey.py`'s folio reader finds 5 folios, and **all 5 vote
printed = PDF - 2**: PDF 14-18. Nothing votes otherwise.

Folios 1, 2, 4, 6-8 and 10-16 were also read on the page images of PDF 3, 4,
6, 8-10 and 12-18. The text agrees: Chapter 5 is where the fortress's rooms
are described, and Chapter 7 (printed 14) sends the reader to Chapter 5 for
them.

As for MH1, one offset would do for the booklet but not for the cards on the
panels, which have no page number, so the entry carries `parts` and no
`offset`, each inside panel a part of its own with `offset` null.

## The book's own authority lists

- **No Contents and no index.** Nothing in the book lists its characters.
- **The introduction** names Kang and the Avengers and nothing else.
- **The banners**, each read on its page image, are the registry's
  `sections`: printed 1 (the title art, then a run-in INTRODUCTION; the
  registry calls it Introduction), Chapter 1 *Double Time* (2), Chapter 2
  *Drax - Foiled Again!* (4), Chapter 3 *Skrull and Crossbones* (6), Chapter
  4 *Stone Walled!* (8), Chapter 5 *The Omega Dimension!* (10), Chapter 6
  *Truth and Consequences* (12), and *Something Borrowed* (14). **The last
  banner prints no chapter number**; the text calls it Chapter 7, and its
  Karma table is Table 7. Each chapter has Campaign, Battle and Aftermath
  subsections; Chapters 2, 4, 6 and 7 have a second Campaign, and Chapter 5
  opens on its Battle, the fortress's Rooms 1-9. Every chapter ends on a
  Karma table (Tables 1-7).
- So **the coverage checklist is this survey's own list** of blocks (below),
  read off the page images. The registry carries it in `cover-panels`' own
  fields: `cards` for the full blocks, `opponents` for the one-line grids,
  `panels` and `character_ranges` for where the cards are.

## What an entry looks like

**A full block** is MH1's, line for line: a bold capital header with a
trademark sign, an identity line, the seven `Fighting: GOOD` rows, `Health:`,
`Karma:`, `Resources:` and `Popularity:`, then `Powers:` with run-in powers,
`Talents:` and `Background:`. One header wraps onto a second line (DRAX THE /
DESTROYER). No block prints `Special:`, so `section_labels` has the three.

**Where they are set:** three cards a page, one to a column, each a portrait
over its name and block, on all four pages: the two panels (PDF 2 and 19) and
printed 15-16 (PDF 17-18). No heavy rule, no dashed rule, and no other text on
those pages, so the entry needs no `faint_rules` and no `drop_above`.

**Run-in powers end in a period, except on two cards.** Captain America's one
power and all three of Captain Marvel's end in a colon (`UNIQUE WEAPON:`,
`BODY TRANSFORMATION:`). The Wasp's fourth power (`ANIMAL COMMUNICATION AND
CONTROL.`) fills its line, and its text starts on the next.

**A one-line grid** is a name in **bold title case** (MH1's are capitals),
alone on its line, sometimes with a qualifier in brackets (`Omegatrons
(robots)`) and once with a colon (`Skrulls:`); the seven letters; a row of
two-letter codes under them; one line `Health: 56   Karma: 30`; and usually a
`Powers:` line of names with a run-in paragraph each. They sit in the
chapters' prose columns.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `Resources: none` | Dragon Man (printed 16) |
| bracketed alternate ranks and Health: `TYPICAL [GOOD]`, `24 [110]`, and `Popularity: 50 [10]` | Grey Gargoyle (16), his stone form |
| `Karma: 0` with Reason, Intuition and Psyche above Shift 0 | Spirits (10), Omegatrons, Centipedes, Energy Spiders (11) |
| a one-line grid with no Karma | Kang's Minions (13) |
| a one-line grid with no name above it | the Mimic's absorbed form (3) |
| `Body`, `Speed`, `Control` with four-letter rank words | the Skrull landing craft (7), a vehicle |

**Rank spellings.** The full blocks spell ranks in capitals, FEEBLE to
UNEARTHLY (Drax's Endurance is the one Unearthly), and the grids use MA1's
two-letter codes, Fb to Mn. All are in `rank_aliases`, as MH1's are; `Un` is
not, because no grid prints it. Tesseract adds a stray mark after a code once
(the Skrulls' `Pr_`); the page image and the arithmetic settle it.

## Stat blocks: 12 full, 9 one-line

**Full blocks (12 characters):**

| card | where | Health | Karma |
|---|---|---|---|
| Captain America | inside front cover | 140 | 60 |
| Starfox | inside front cover | 110 | 56 |
| Wasp | inside front cover | 46 | 50 |
| Kang | printed 15 | 86 | 90 |
| Mimic | printed 15 | 24 | 18 |
| Drax the Destroyer | printed 15 | 180 | 50 |
| Dragon Man | printed 16 | 145 | 8 |
| Grey Gargoyle | printed 16 | 24 [110] | 36 |
| Super-Skrull | printed 16 | 150 | 22 |
| Captain Marvel | inside back cover | 60 | 22 |
| Scarlet Witch | inside back cover | 46 | 60 |
| Vision | inside back cover | 140 | 56 |

**One-line grids (9):**

| name | printed | chapter | Health | Karma |
|---|---|---|---|---|
| *the Mimic, absorbed form* (no name) | 3 | 1 | 170 | 90 |
| Aliens (humanoid) | 5 | 2 | 56 | 30 |
| Skrulls | 7 | 3 | 32 | 20 |
| Spirits | 10 | 5, Room 2 | 66 | 0 |
| Omegatrons (robots) | 11 | 5, Room 5 | 155 | 0 |
| Centipedes (robots) | 11 | 5, Room 6 | 56 | 0 |
| Energy Spiders | 11 | 5, Room 7 | 46 | 0 |
| Champion | 11 | 5, Room 8 | 60 | 80 |
| Kang's Minions | 13 | 6 | 32 | none printed |

The registry's `opponents` lists the eight with a name; the Mimic's form is
not an opponent of its own (decision 2).

**The book checks itself, on each rank's standard number** (`ranks.json`
`standard`, as MH1's and MHSP1's blocks are checked):

| measure | count |
|---|---|
| full blocks, Health = F+A+S+E | **12 of 12** |
| the bracketed form, Health checked too | **1 of 1** (Grey Gargoyle 110) |
| full blocks, Karma = R+I+P | **12 of 12** |
| one-line grids, Health = F+A+S+E | **8 of 9**: the Energy Spiders print 46, and their ranks give 44 |
| one-line grids printing a Karma above 0, Karma = R+I+P | **4 of 4** (the Mimic's form, Aliens, Skrulls, Champion) |
| one-line grids printing Karma 0 | 4, whose R+I+P would be 90, 20, 10 and 40 |

Every block was read on its page image as well as in the OCR.

**One misprint:** the Energy Spiders (printed 11) print `Ty Rm Fb Ty` and
Health 46, read on the page image. Ty Rm Fb Ty is 44. A Poor Strength
(`Pr`) would make 46, so either the Health or the Strength is wrong, and the
page does not say which. It is for the data row to record in
`scripts/msh/mh2-overrides.json`, keeping `printed` and `corrected`
(decision 4).

**Karma 0 is printed on purpose**, on the four grids that are machines or
spirits (the fortress's guardians); every grid for a living being prints its
R+I+P. The data row needs an `as_printed` for each, with that reason, or the
Marvel smoke suite's Health/Karma check will find them unrecorded.

Two Strengths on the cards (Super-Skrull's and the Vision's, both AMAZING)
are read with a mark of the portrait in front of the word. Both cards' Health
holds with Amazing, and the page images show nothing but the word.

## Which reader fits

**`cover-panels` (`scripts/msh/coverpanels.py`), with two things taught to
it.** Measured, not argued: a scratch copy of `scripts/msh/` at `origin/main`
(`c40fe485`) with this entry plus `"layout": "cover-panels"`, run on a copy of
the cache under its own `WORKSHOP_MSH_CACHE`:

- **With the opponents, it stops at once:** `mh2: a one-line grid with no
  name above it, Adventure Book p.5`. Its name rule takes a line of
  capitals, or capitals before a colon, and every name here is in title case.
- **With the opponents list emptied, the cards parse:** 12 entries, 12 blocks,
  the checklist's 12 cards all found, 10 blocks passing and 2 failing. The two
  are the unread Strengths above (Super-Skrull, Vision). The run also shows
  0 powers read for Captain America and Captain Marvel (the colon run-ins)
  and 3 of the Wasp's 4.

The other readers do not fit, for MH1's reasons (mh1.md, *Which reader
fits*): `roster.py` (MA1) and `codegrids.py` (MA4) read printed ability
numbers, which this book does not print (`survey.py` finds **0** blocks on
the `Health =` anchor); `gridbooks.py` (ME1) reads MA1's numbered grids;
`booklet.py` (MHSP1) reads this block but one range in one part, not the
panels or the chapters' grids, which is why `coverpanels.py` was written.

So the parser row is next, as the skill sets out. What it needs, all in
`coverpanels.py` behind the registry, with MH1's `roster.json`,
`book-text.sql` and `npcs.json` rows proved byte-identical before and after:

1. **A one-line grid's name in title case**, alone on its line, with an
   optional bracketed qualifier and an optional colon. MH1's rule (capitals,
   or capitals and a description after a colon) must still hold for MH1.
2. **The Mimic's absorbed-form grid**, which has no name above it: a
   registry field naming it as a second block of the Mimic's card (decision
   2), in the way `block_labels` names a form in MA4.
3. **The two unread Strengths**, a mark before a rank word on a card; a
   pattern, so a parser fix rather than two overrides.
4. **Run-in powers that end in a colon**, on two cards, and a run-in that
   fills its line.

This survey sets no `layout`, as MH1's did not: that is the parser's choice.
It does write `panels` and `cards`, which `cover-panels` reads and which are
measurements of the book, not choices.

## Entry kinds

1. **A character with a full block:** 12, listed above. All are single
   characters; none is a type.
2. **An opponent with a one-line grid:** 8 with a name. Six are types (one
   grid for several: the aliens, the Skrulls, the spirits, the three robot
   and spider kinds, Kang's minions); the Champion is one being.
3. **A form, in brackets inside one block:** the Grey Gargoyle's stone form.
4. **A form with a grid of its own:** the Mimic once he has copied the
   Avengers' powers (printed 3).
5. **Variants in prose only, with no block:**
   - the Super-Skrull charged by his landing craft's power beam (printed 7),
     which raises his Health and Karma for as long as the beam's dish stands;
   - the football players who join the fight in Chapter 1 (printed 3), whose
     ranks and Health 32 are stated in a sentence (and 32 = Ty + Gd + Ty + Gd,
     so the sentence agrees with itself).
6. **Hazards with a partial stat line, not characters:** Room 3's tentacles
   and Room 4's lasers and rocket launchers (printed 10-11). The
   recommendation is to leave them in the adventure's text, which is not
   imported.
7. **A vehicle:** the Skrull landing craft (printed 7), with Body, Speed and
   Control. Out of scope by Nate's ruling (no items or places now). Kang's
   time ship and gauntlets are powers on his card, not items of their own.

## Names the Codex already has

Seven MH2 characters share a name with a card from another book. By the rule
#1520 pinned (Nate, 2026-09-28), each is a card of its own, with a `-mh2` id:

- in MHSP1: Captain America, the Wasp, Captain Marvel and Kang (MHSP1 states
  Captain America and Captain Marvel only in its Reference Summary, with no
  identity line);
- in MA1: the Mimic (Calvin Rankin in both) and the Scarlet Witch; MH1 also
  has a False Scarlet Witch, a robot;
- in MA4: the Super-Skrull; MA4's Skrull and ME1's Typical Skrull Warrior are
  the same kind of being as MH2's Skrulls, under other names;
- **the Champion is a different being.** ME1's Champion is an Elder of the
  Universe; MH2's is the guardian of the fortress's Room 8. The book's name
  stands, and each card's book and text tell them apart.

Starfox, Drax the Destroyer, Dragon Man, the Grey Gargoyle and the Vision are
new to the Codex.

## Quote marks

**The book prints single quotes of its own.** Measured on the OCR of all 22
pages: 78 double marks and 8 opening single marks. Read on the page images:
two words in single quotes are printed as such, in Chapter 3's Super-Skrull
tactics (printed 7) and in Room 6 (printed 11), and Tesseract lost the
opening mark of the second. The other seven opening singles are not quotes of the
book's own: double marks read as one or two singles (the credits, speeches in
Chapters 2 and 6), the copyright sign on the map, and a speck in a picture. So, as in
MA1 and not as in MH1 or MHSP1, **a single mark is not always a misread**: a
lost closing or opening single is a `text` override, never a rule. Both
printed pairs are in the adventure's prose, which is not imported; no card or
grid text examined prints one. Apostrophes after a plural (`Thanos'`,
`Avengers'`) are real.

## Decisions this survey leaves open

For Nate. Each has a recommendation.

1. **What `team` means.** There are no team sections. The recommendation: the
   six heroes on the panels as **Avengers**, a new filter group (no book has
   one yet; MHSP1 files the same people under Secret Wars Heroes), and
   everything else under the book's title, **MH2 Time Trap**, as MH1 does.
   The alternative is to file the Super-Skrull and the Skrulls under the
   **Skrulls** group MA4 and ME1 already share. Not written to the registry
   until decided.
2. **The Mimic's absorbed form** (printed 3): a second block on the Mimic's
   card, as Colossus's armoured form is in MH1 (recommended), or an entry of
   its own.
3. **Karma 0 on the four machine and spirit grids:** `as_printed`, with the
   reason that they are not living beings (recommended), or derive R+I+P.
4. **The Energy Spiders' Health 46 against ranks that give 44:** an override
   keeping printed and corrected. Which value is corrected is a guess either
   way; the recommendation is to correct the Health to 44 and keep the ranks
   as printed, since the ranks are what the GM rolls on.
5. **Kang's Minions print no Karma:** leave Karma unset (recommended, as for
   MH1's robots) or derive 10.
6. **The variants in prose** (the charged Super-Skrull, the football
   players): leave them in their text, as MH1's Special Sentinels were left
   (recommended), or give them cards.

## The parser (done 2026-10-21)

Nate ruled on all six decisions above on 2026-10-21, each as recommended
except 5: Kang's Minions get Karma derived as 10 (not taken: unset). The
registry entry now has `"layout": "cover-panels"`, `teams` (Avengers), and
three fields `coverpanels.py` reads for this book alone: `opponent_names`
(the title-case names, and each grid's run-in powers), `form_grids` (the
Mimic's absorbed form, a second block on his card) and `drop_corner` (the
PROOF OF PURCHASE coupon on printed 16, which Tesseract reads onto the last
line of the Super-Skrull's card). Two fixes apply to any cover-panels book:
a card's run-in power that ends in a colon or fills its line, and a rank
word read with a mark in front of it (the Super-Skrull's and the Vision's
Strength). `python scripts/msh/roster.py mh2` exits 0: 12 full blocks, 8
named one-line grids and the Mimic's form, all found. `mh2-overrides.json`
holds the Energy Spiders' Health (printed 46, corrected 44, decision 4) and
the four Karma 0s as printed (decision 3), each read again on the page image.
MH1's outputs, and every other book's, were built with `origin/main`'s
scripts and the branch's and compared byte for byte.

## The data (done 2026-10-21)

`python scripts/msh/npcs.py mh2` writes the 20 characters and 91 rows of
`msh_book_text`, applied to production before the merge. Two things were
taught to `npcs.py`, each behind a registry field only this book sets:
`no_karma` gives Kang's Minions R+I+P as their Karma (Pr Fe Pr = 10,
decision 5), flagged `karma_derived` so the Codex says it was not printed;
and a card with a `form_grids` block is one being whose blocks are forms, so
the GM adds the Mimic as one NPC with two forms (Mimic, Absorbed Form), and
the form's eight run-in powers go to D1 as the card's powers 2-9, each named
for the form, on printed 3. The form's Powers: line only lists those names,
so it is not a row of its own. Every earlier book's `npcs.json` rows and
`book-text.sql` were built with `origin/main`'s scripts and the branch's and
compared byte for byte: identical.

## How to reproduce

```bash
python scripts/msh/survey.py mh2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 60-200
dpi into the scratchpad, never into the repo, and the trial parse wrote its
`roster.json` into a scratch copy of the cache, never the main checkout's.
