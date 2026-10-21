# Survey: MH3 Murderworld! (TSR6855)

Marvel Super Heroes adventure module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mh3`. Measured 2026-10-21.

**Rows citing this book:** 0 `msh_book_text` rows. Nothing is imported yet:
this is the survey, with no data and no parser (production `DB_MARVEL` read
back 2026-10-21: no `mh3` rows).

This is the third of the five Marvel books registered together by the
kickoff PR (#1917). It goes through `scripts/msh/`
only. **It is laid out as MH1 and MH2 are**, the two modules before it in the
same series: [mh2.md](mh2.md) is the nearest worked example, and
`cover-panels` (`scripts/msh/coverpanels.py`) the nearest reader. Full blocks
in rank words (no numbers) on the two inside panels of a loose cover and on
four booklet pages, and one-line `F A S E R I P` grids inside the chapters.
**What differs from MH2** is listed under *Which reader fits*.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places, even the ones with a stat line of their own
(the minotanks, below).

## The scan

- 22 PDF pages, a pure scan, already cached by the kickoff PR into the main
  checkout's `.cache/msh/books/mh3/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, written 2026-10-21).
- The print is clean. Tesseract reads the body text, the full blocks' label
  lines and the one-line grids' code rows well: every number below was read
  in the OCR and again on the page image, and they agree. It does not read
  the chapter titles (display lettering), the cover or the maps, and it
  **loses one card's header entirely**: HUMAN TORCH on the inside front
  cover, whose letters touch the frame of the portrait above them (read on
  the page image; the TSV has no word of it). The grids' S and I letters are
  read as `Ss` or `|`, and one Intuition reads `(c) EXCELLENT` (Arcade), a
  mark of the portrait beside the column.
- **PDF 22, one side of the map, prints a panel of text upside down.** Its
  OCR is mirrored nonsense. It is map key text, not a character.

**The PDF is a booklet inside a loose folding cover, plus a map sheet**, the
same six pieces as MH1 and MH2. Recorded as `parts` in the registry:

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2 | Inside front cover: the cards of Mr. Fantastic, the Invisible Girl and the Human Torch | - |
| 3-18 | Adventure Book | 1-16 |
| 19 | Inside back cover: the cards of She-Hulk, the Thing, Franklin Richards and Alicia Masters | - |
| 20 | Back cover | - |
| 21-22 | Map: Murderworld's grounds on one side, the Baxter Building's floors on the other | - |

As in MH2, the introduction does not say where the heroes' cards are. PDF 2
and 19 are identified as the cover's inside panels by what is on them (seven
cards, no folio) and by where they sit, outside the booklet's numbering on
either side of it. The back cover describes the module as a 16-page book and
a two-sided map, which agrees.

## Offset

`scripts/msh/survey.py`'s folio reader votes **printed = PDF - 2 on 7
pages** (PDF 12-18). Three pages vote once each otherwise, and each was
looked at: PDF 5 (k = -35) and PDF 8 (k = -4) read a number at the foot of
the page's text (a Karma table's +40, a line of prose) as the folio, and PDF
22 (k = 14) is the map.

Folios 2-6, 8, 10-13, 15 and 16 were also read on the page images of PDF
4-8, 10, 12-15, 17 and 18. PDF 3 (printed 1) prints the copyright line where
a folio would be. The text agrees: printed 8 sends the reader on to Chapter
5 by its title, and Chapter 5's banner is on printed 10.

As for MH1 and MH2, one offset would do for the booklet but not for the cards
on the panels, which have no page number, so the entry carries `parts` and no
`offset`, each inside panel a part of its own with `offset` null.

## The book's own authority lists

- **No Contents and no index.** Nothing in the book lists its characters.
- **The introduction** names the Fantastic Four and Arcade, and says what to
  do with fewer or more than four players; it lists no characters.
- **The banners**, each read on its page image, are the registry's
  `sections`: printed 1 (the title art, *The Fantastic Four: Murderworld!*;
  the registry calls it Introduction), Chapter 1 *Von Doom's Express!* (2),
  Chapter 2 *The Road to Murderworld!* (4), Chapter 3 *Raiders of the Lost
  Arcade!* (5), Chapter 4 *Home for the Holocaust* (8), Chapter 5
  *Recruiting Drive* (10), Chapter 6 *Accentuate the Negative!* (11) and
  Chapter 7 *Loose Ends* (12). Chapter 3's banner spells its number out
  (Chapter Three) and sits at the foot of printed 5's first column, under
  the art; the whole of printed 5 is Chapter 3, because Chapter 2's Karma
  table ends printed 4. Chapters 1-6 have Campaign, Battle and Aftermath
  subsections; Chapter 3's Battle is five numbered battles (printed 5-7),
  and Chapter 7 has no subsections. Every chapter ends on a Karma table
  (Tables 1-7).
- So **the coverage checklist is this survey's own list** of blocks (below),
  read off the page images. The registry carries it in `cover-panels`' own
  fields: `cards` for the full blocks, `opponents` for the named one-line
  grids, `panels` and `character_ranges` for where the cards are.

## What an entry looks like

**A full block** is MH2's, line for line: a bold capital header, usually
with a trademark sign, an identity line, the seven `Fighting: GOOD` rows,
`Health:`, `Karma:`, `Resources:` and `Popularity:`, then `Powers:` with
run-in powers, `Talents:` and `Background:`. No block prints `Special:`, so
`section_labels` has the three. What is new:

- **Two headers wrap** onto a second line (SUPER- / ADAPTOID, FRANKLIN /
  RICHARDS), one of them at a hyphen, and one is two words on two lines
  (SKRULL / SOLDIERS).
- **Doctor Doom's header has a banner above it**, *In Loving Memory*, in the
  same face but smaller (Doom is dead at the time of the adventure, and his
  card is written in the past tense).
- **Three cards are short**: Miss Locke and Mr. Chambers print the ten stat rows and a
  sentence or two of prose, with no `Powers:`, `Talents:` or `Background:`;
  the Skrull Soldiers print no identity line, and `Powers:` only.
- **Two cards carry a second grid inside them**: She-Hulk's and the Thing's
  `ALTER EGO.` powers end on a one-line grid of the human form (Jennifer
  Walters, Ben Grimm), with its own `Health:` and `Karma:` line.
- **One card prints bracketed alternates**: the Skrull Soldiers'
  `GOOD [EXCELLENT]` Reason and `22 [32]` Karma, for the Skrull technicians.

**Where they are set:** not one to a column, as MH2's are. The cards are
placed around the portraits: four on printed 13, two on 14, four on 15 and
one, Doom's, on 16, whose prose runs on into the page's other two columns.
Three cards on the inside front cover, one to a column; four on the inside
back cover, two of them stacked in the third column. Printed 16 also prints
a product code at the foot of its first column, which Tesseract reads as a
line of capitals (`6855XXX1501`).

**Run-in powers end in a period or a colon**, both on the same card (the
Invisible Girl's `FLIGHT:`, the Human Torch's and Blastaar's `BODY ARMOR:`).
One run-in is in mixed case, `GROWTH and SHRINKING.`, on three Skrull cards.

**A one-line grid** is a name in **bold capitals**, alone on its line (MH1's
form, not MH2's title case); the seven letters; a row of two-letter codes
under them; one line `Health: 120   Karma: 0`; and a `Powers:` line of names,
each then given a run-in paragraph that begins with the power's name in
capitals and either goes straight on into its sentence with no period
(the Doombot's) or ends the name with a colon (the Water Tower Robots'). They sit in the chapters' prose columns.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `Karma: none` | Miss Locke and Mr. Chambers (printed 13) |
| `Popularity:` as a dash | Miss Locke, Mr. Chambers (13), Sally Flack, Captain Sk'yll, the Skrull Soldiers (15) |
| `Resources:` as a dash | Sally Flack, Captain Sk'yll, the Skrull Soldiers (15) |
| `Resources: varies` | the Wizard and the Trapster (14) |
| `Resources: none` | the Super-Adaptoid (15), Franklin Richards (inside back cover) |
| `Health: 150` over ranks that give 24, and `Karma: varies` | the Super-Adaptoid (15) |
| bracketed alternate ranks and Karma: `GOOD [EXCELLENT]`, `22 [32]` | the Skrull Soldiers (15) |
| `Karma: 0` with Reason, Intuition and Psyche above Shift 0 | the Doombot (3), the Water Tower Robots (4) |
| a one-line grid with no name above it, and no Karma | the Super-Adaptoid's current form (9) |
| `B S C A E R I` over seven codes, with no Health or Karma | the minotanks (7) |

**Rank spellings.** The full blocks spell ranks in capitals, FEEBLE to
UNEARTHLY (Blastaar's Endurance is the one Unearthly on a card), and the
grids use MA1's two-letter codes, Fb to Un. **`Un` is printed here** (the
Water Tower Robots' Endurance), so `rank_aliases` has it, which MH2's does
not need. A stray mark after a code once (`In.`, the Super-Adaptoid's form)
is settled by the page image.

## Stat blocks: 18 full, 5 one-line, and the minotanks

**Full blocks (18 cards):**

| card | where | Health | Karma |
|---|---|---|---|
| Mr. Fantastic | inside front cover | 42 | 100 |
| Invisible Girl | inside front cover | 46 | 40 |
| Human Torch | inside front cover | 60 | 26 |
| Miss Locke | printed 13 | 36 | none |
| Mr. Chambers | printed 13 | 32 | none |
| Arcade | printed 13 | 38 | 56 |
| Blastaar | printed 13 | 180 | 40 |
| Wizard | printed 14 | 40 | 52 |
| Trapster | printed 14 | 28 | 40 |
| Super-Adaptoid | printed 15 | 150 | varies |
| Sally Flack | printed 15 | 46 | 40 |
| Captain Sk'yll | printed 15 | 46 | 26 |
| Skrull Soldiers | printed 15 | 32 | 22 [32] |
| Doctor Doom | printed 16 | 120 | 140 |
| She-Hulk | inside back cover | 150 | 36 |
| The Thing | inside back cover | 200 | 50 |
| Franklin Richards | inside back cover | 16 | 91 |
| Alicia Masters | inside back cover | 18 | 40 |

**One-line grids (5):**

| name | printed | where | Health | Karma |
|---|---|---|---|---|
| Doombot | 3 | Chapter 1, Battle | 120 | 0 |
| Water Tower Robots | 4 | Chapter 2, Battle | 180 | 0 |
| *the Super-Adaptoid, current form* (no name) | 9 | Chapter 4, Battle | 150 | none printed |
| *Jennifer Walters*, inside She-Hulk's card | inside back cover | ALTER EGO | 26 | 26 |
| *Ben Grimm*, inside the Thing's card | inside back cover | ALTER EGO | 50 | 50 |

The registry's `opponents` lists the two with a name. The other three are
forms of a card (decisions 2 and 3).

**The minotanks** (top of printed 7, closing Chapter 3's Battle 3, which
begins on printed 6) print a grid of
their own kind: the letters `B S C A E R I` over `In Fb Ex Ex Ex Fb Fb`, and
no Health or Karma. The text calls them vehicle-robots. Neither the
F A S E R I P check nor the vehicle reader's Body, Speed and Control fits
them, and they are not in `opponents` (decision 5).

**The book checks itself, on each rank's standard number** (`ranks.json`
`standard`, as MH1's, MH2's and MHSP1's blocks are checked):

| measure | count |
|---|---|
| full blocks, Health = F+A+S+E | **17 of 18**: the Super-Adaptoid prints 150, and its ranks give 24 |
| the bracketed alternate, Karma checked too | **1 of 1** (the Skrull technicians' 32 = Ex + Ty + Ty) |
| full blocks printing a number for Karma, Karma = R+I+P | **15 of 15** |
| full blocks printing a word for Karma | 3: `none` (Miss Locke 30, Mr. Chambers 32 by R+I+P) and `varies` (the Super-Adaptoid) |
| one-line grids, Health = F+A+S+E | **4 of 5**: the Super-Adaptoid's form prints 150, its ranks give 200 |
| one-line grids printing a Karma above 0, Karma = R+I+P | **2 of 2** (Jennifer Walters, Ben Grimm) |
| one-line grids printing Karma 0 | 2, whose R+I+P would be 18 each (the Doombot's Gd Pr Pr, the Water Tower Robots' Pr Gd Pr, read on the page images) |

Every block was read on its page image as well as in the OCR.

**No misprint.** The two Health 150s are printed on purpose: the
Super-Adaptoid's form says, under its grid, that the android's Health is
always 150 whatever it has absorbed, and its card prints all Typical ranks
over the same 150. The data row needs an `as_printed` for each, with
that reason, and for the two Karma 0s on the machines (as MH2's four were),
or the Marvel smoke suite's Health/Karma check will find them unrecorded.

## Which reader fits

**`cover-panels` (`scripts/msh/coverpanels.py`), with things taught to it.**
Measured, not argued: a scratch copy of `scripts/msh/` at `origin/main`
(`7b9a10e6`) with this entry plus `"layout": "cover-panels"`, run on a copy
of the cache under its own `WORKSHOP_MSH_CACHE`. `roster.py mh3` exits 1:

- 20 entries, 20 blocks; 17 blocks pass, 3 fail, and the three are the
  printed-on-purpose values above (the Super-Adaptoid's Health, the two
  machines' Karma 0), which are overrides, not parser work.
- **`CHECKLIST NAME IN 0 ENTRIES: Human Torch`.** With its header unread,
  the Torch's block and five powers are filed under the Invisible Girl's
  entry, as her second block.
- **`ENTRY WITH NO BLOCK: 6855XXX1501`.** The product code at the foot of
  printed 16 is taken for a header, and the rest of Doom's text (the page's
  second and third columns) goes into it. Its TSV box is x 111-351, y
  2954-2984 (300 dpi). Above Doom, the *In Loving Memory*
  banner is read onto the end of Sally Flack's card (her entry spans printed
  15-16).
- **Powers missed or invented:** the mixed-case `GROWTH and SHRINKING.` is
  read on none of the three Skrull cards; the Wizard's third power (POWER
  GLOVES, in the same column as his other two, and read in the TSV) is not
  found; and a name in capitals in Franklin Richards' prose is read as a
  power of his (he has none named). The two opponents' powers read 0.
- The two alter-ego grids are not read as blocks, and the Super-Adaptoid's
  form is not read at all (it is not in `opponents`).

The other readers do not fit, for MH1's and MH2's reasons (mh2.md, *Which
reader fits*): `roster.py` (MA1) and `codegrids.py` (MA4) read printed
ability numbers, which this book does not print (`survey.py` finds 3 blocks
on the `Health =` anchor, and all three are the androids' Health in a
sentence on printed 6); `gridbooks.py` (ME1) reads MA1's numbered grids;
`booklet.py` (MHSP1) reads one range in one part, not the panels or the
chapters' grids, which is why `coverpanels.py` was written.

So the parser row is next, as the skill sets out. What it needs, all in
`coverpanels.py` behind the registry, with MH1's and MH2's `roster.json`,
`book-text.sql` and `npcs.json` rows proved byte-identical before and after:

1. **The Human Torch's lost header**: the card found without it, from a
   registry field naming the card by its identity line or its place, since
   no word of it is in the TSV.
2. **Printed 16's product code** dropped (a lower-left `drop_corner`; MH2's
   is lower right), and the *In Loving Memory* banner kept off Sally Flack's
   card (Doom's, or dropped).
3. **A mixed-case run-in power** (`GROWTH and SHRINKING.`), and why the
   Wizard's POWER GLOVES is not found.
4. **A name in capitals in a card's prose is not a power** (Franklin
   Richards').
5. **An opponent's run-in powers**: a name with no period after it, or one
   ended by a colon.
6. **Forms**: the Super-Adaptoid's current form on printed 9 (MH2's
   `form_grids`), and the two alter-ego grids inside cards on the inside back
   cover. `form_grids` has not been tried on those: MH2's names a grid in
   the Adventure Book's prose, and these sit inside a card, under a power.

This survey sets no `layout`, as MH1's and MH2's did not: that is the
parser's choice. It does write `panels`, `cards` and `opponents`, which
`cover-panels` reads and which are measurements of the book.

## Entry kinds

1. **A character with a full block:** 17, listed above. All but one are
   single characters.
2. **A type with a full block:** the Skrull Soldiers, with bracketed ranks
   for the technicians among them.
3. **An opponent with a one-line grid:** 2, the Doombot and the Water Tower
   Robots, both machines; the Water Tower Robots are one grid for several.
4. **A form with a grid of its own:** the Super-Adaptoid as it starts the
   fight in Chapter 4 (printed 9), with the Wizard's, the Trapster's and the
   Thing's abilities; and the two human forms inside the She-Hulk's and the
   Thing's cards.
5. **Variants in prose only, with no block:**
   - Arcade's goblin androids in Battle 1 (printed 6), in three waves whose
     ranks and Health (24, 40, 80) a sentence states, and each agrees with
     itself (all Typical, all Good, all Excellent);
   - the robot Aztecs and their chief in Battle 2 (printed 6), stated the
     same way (Health 40 on all Good ranks; 80 on all Excellent).
6. **Vehicle-robots with a grid of their own kind:** the minotanks (printed
   7). See decision 5.
7. **Items and places:** among them the Fantasticar, the Negative Zone
   portal, Murderworld's traps and the Baxter Building's floors on the map.
   Out of scope by Nate's ruling (no items or places now).

## Names the Codex already has

Thirteen MH3 cards share a name, or a person, with a card from another book.
By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own, with
a `-mh3` id:

- **in MA1: Arcade, Miss Locke and Mr. Chambers**, the same three people;
- in MA4: Mister Fantastic, the Invisible Woman, the Human Torch, the Thing,
  She-Hulk, Alicia (Reiss Masters Storm), Doctor Doom, Blastaar, the
  Trapster and the Wizard (MA4's Wingless Wizard); MA4's Skrull, ME1's
  Typical Skrull Warrior and MH2's and MHSP2's Skrulls are the same kind of
  being as MH3's Skrull Soldiers;
- in MHSP1: Mister Fantastic, the Human Torch, the Thing, She-Hulk and Doctor
  Doom; in MHSP2, the same five plus the Invisible Woman, Blastaar and the
  Wizard.

**MH3 prints two of those names differently**: `MR. FANTASTIC` where every
other book has Mister Fantastic, and `INVISIBLE GIRL` where MA4 and MHSP2
have the Invisible Woman (she was renamed later). The book's own names stand,
and each card's book tells them apart.

The Super-Adaptoid, Sally Flack (the Skrull Onalla), Captain Sk'yll and
Franklin Richards are new to the Codex.

## Quote marks

**The book prints single quotes of its own, on the cards.** Read on the page
images: two words in single quotes on the inside front cover (one in the
Invisible Girl's Flight, one in the Human Torch's Nova Blast) and one in the
Wizard's card (printed 14). Measured on the OCR of all 22 pages: 27 opening
and 16 closing double marks, and 50 opening single marks, most of them the
two maps' noise (PDF 21-22); in the booklet, several are double marks read
as one or two singles. So, as in MA1 and MH2, and not as in MH1 or MHSP1,
**a single mark is not always a misread**, and here a pair is in card text
that is imported: the data row must check each single mark on a card
against the page image, and a lost one is a `text` override, never a rule.
Apostrophes in names (`Sk'yll`, read as a curly apostrophe) are real.

## Decisions this survey leaves open

For Nate. Each has a recommendation.

1. **What `team` means.** There are no team sections. The recommendation:
   the five heroes of the Fantastic Four (Mr. Fantastic, the Invisible Girl,
   the Human Torch, She-Hulk and the Thing) under the existing **Fantastic
   Four** group, Franklin Richards and Alicia Masters under the existing
   **Friends of the FF**, Sally Flack, Captain Sk'yll and the Skrull
   Soldiers under the existing **Skrulls**, and everyone else under the
   book's title, **MH3 Murderworld!**, as MH1 and MH2 do. The alternative
   is MH2's ruling, which kept its Skrulls under the book's title. Not
   written to the registry until decided.
2. **The Super-Adaptoid's current form** (printed 9): a second block on its
   card, as the Mimic's absorbed form is in MH2 (recommended), or an entry
   of its own.
3. **The two alter-ego grids** (Jennifer Walters, Ben Grimm): a second block
   on each card, as forms (recommended), or entries of their own.
4. **Karma words**: `none` on Miss Locke and Mr. Chambers, and `varies` on
   the Super-Adaptoid. The recommendation follows MH2's ruling on Kang's
   Minions: derive R+I+P for the two assistants (30 and 32), flagged as not
   printed, and leave the Super-Adaptoid's `varies` unset, since the card
   says so in a word rather than leaving it out (its card also says it
   copies no Reason, Intuition or Psyche, so a derived 18 would be a guess
   at what `varies` means). The alternative is to leave all three unset.
5. **The minotanks** (printed 7): leave them in the adventure's text, as
   vehicles are left by the ruling on items (recommended), or teach the
   reader their `B S C A E R I` grid and give them a card.
6. **The prose variants** (the goblin waves, the robot Aztecs and their
   chief): leave them in their text, as MH2's football players were left
   (recommended), or give them cards.
7. **The Health 150s and the Karma 0s**: `as_printed`, with the reasons
   above (recommended), or derived.

## How to reproduce

```bash
python scripts/msh/survey.py mh3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at
40-200 dpi into the scratchpad, never into the repo, and the trial parse
wrote its `roster.json` into a scratch copy of the cache, never the main
checkout's.
