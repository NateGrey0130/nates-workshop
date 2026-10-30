# Survey: ME3 The Left Hand of Eternity (TSR6882)

> **DRAFT.** Measured 2026-10-30 over two plan rows: 4a the scan, the parts
> and offsets, the authority lists and the Adventure Book's stat blocks; 4b
> the Resource Book's blocks, the Pregenerated Heroes Summary, the names the
> Codex already has, the quote marks and the decisions. *Which reader fits*
> is the trial parse's (row 4c).

Official Advanced Game Adventure for Marvel Super Heroes, Ray Winninger, 1988.
Registry entry: `scripts/msh/books.json` -> `me3`. Measured 2026-10-30.

**Rows citing this book:** 0 `msh_book_text` rows: nothing is imported yet,
and the data row sets this line from production's read-back.

This is the module after ME2, by the same series, through `scripts/msh/` only.
**It is laid out as ME1 and ME2 are**: a boxed module of an Adventure Book and
a Resource Book, each numbered from 1, whose blocks are MA1's numbered grids
(the number before the code). [me2.md](me2.md) is the nearest worked example.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places.

## The scan

- 55 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-30 into the main
  checkout's `.cache/msh/books/me3/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, 55 pages OCR'd).
- sha256 `d8ec852c...b1e10908`. PDF 1-54 are 601 x 778 pt; PDF 55 is
  1540 x 1167 pt, the map sheet.
- The print is clean. Tesseract reads the body text and the grids well. It
  reads none of the chapter banners (lettering in a textured band) and
  mangles the Contents' dot leaders, so both were read on the page images.
- **One page is set sideways:** the Pregenerated Heroes Summary (PDF 53).
  Tesseract reads it as noise.

**The PDF is two booklets, their covers, a facsimile prop and one map
sheet.** The Introduction (printed Adventure 2) lists the package as a
16-page Resource Book, a 32-page Adventure Book, a four-colour map, the
prop and the hero summary on the inside back cover. Recorded as `parts`:

| PDF | part | printed |
|---|---|---|
| 1 | Cover | - |
| 2 | Map of the Iron Labyrinth and Map of Mephisto's Realm (inside cover) | - |
| 3-34 | Adventure Book | 1-32 |
| 35-50 | Resource Book | 1-16 |
| 51-52 | Mephisto's Hourglass, the prop: the hourglass, then its directions and hour scale | - |
| 53 | Pregenerated Heroes Summary, sideways | - |
| 54 | Back cover | - |
| 55 | Map Sheet: Landscape #2, The Dark Dimension, Landscape #1, Death's Inner Sanctum | - |

The Contents names the map sheet's four maps one by one; the scan has one
sheet page carrying all four. Printed Adventure 9 also prints a Referee's
Map: Landscape #1 of its own, inside the booklet.

## Offset: two of them

`scripts/msh/survey.py`'s folio reader finds 36 folios:
- **24 vote printed = PDF - 2**: the Adventure Book.
- **9 vote printed = PDF - 34**: the Resource Book.
- **3 are not folios**, each read on the page image: PDF 6 (k=-494, a
  number at the page's foot; the image prints 4), PDF 42 (k=42, the folio
  read as 0; the image prints 8) and PDF 53 (k=49, the sideways summary).

The folios Tesseract missed (PDF 5, 7-11, 36, 37 and 39-41) were read on a
strip of each page's foot and agree. **Two pages print no folio**: PDF 3 and
PDF 35, each booklet's printed page 1 (title, Contents and credits).

So the entry carries `parts` and no `offset`, as ME1's and ME2's do, with
the same `cite`s: `Adventure`, `Resource`, `Pregenerated Heroes Summary`.

## The book's own authority lists

- **Two Contents**, one on each booklet's printed page 1 (PDF 3 and 35),
  transcribed from the page images. Stored as `sections`, each entry with its
  booklet as the fourth field, as printed.
- **Every Adventure Book entry was checked on its page, and all agree**: the
  Introduction (2), the 14 chapter banners (6, 7, 10, 11, 12 twice, 14, 16,
  17, 19, 24, 27, 29 twice) and the Epilogue (32), from a strip of each page,
  and the four heroes' headers (Mantis 3, Gladiator 3, Firelord 4, Beta Ray
  Bill 5). **One title differs**: the Contents prints `Epilogue`, the banner
  `EPILOGUE: ETERNAL THANKS`. The page agrees, so there is no
  `contents_errata`; `contents_note` records it.
- **The Contents prints `Pregenerated Heroes:` as a heading with no page**,
  over Mantis, Gladiator, Firelord and Beta Ray Bill, in that order (ME2's
  was alphabetical). No such heading is printed on the pages: the four
  blocks follow the Introduction's Rollcall paragraph (printed 2), which
  names the eight heroes. No null-subsection line for it.
- **The Resource Book's Contents** names three sections and 19 characters:
  The Entities (2: Death 2, Eternity 3, Galactus 3), The Death Gods (6:
  Mephisto 6, Mephisto's Demonic Thralls 7, Mephisto's Footsoldiers 7,
  Pluto 8, Pluto's Footsoldiers 9, Hela 9, Seth 10) and Other Characters
  (11: Voyd 11, Uatu 11, Clea 12, Dormammu 13, Mindless Ones 14, Dark
  Dimension Inhabitant, Typical 14, Thanos 15, Captain Marvel 15, The Purple
  Man 16). It inverts one name (`Dark Dimension Inhabitant, Typical`). The
  three section banners were read on their pages and agree, and so do 17 of
  the 19 character headers. **Two are swapped**: `DORMAMMU` is printed on 12
  (PDF 46, column 2, after Uatu's entry) and `CLEA` on 13 (PDF 47, column 3),
  where the Contents prints Clea 12 and Dormammu 13. Recorded as
  `contents_errata`, the page winning; `sections` keeps the Contents' order.
- **No index.** As in ME2, the Resource Book's Contents is that booklet's
  checklist, and neither Contents names the opponents statted inside the
  chapters (below), which the registry lists as `opponents`.
- **The Pregenerated Heroes Summary** (PDF 53), transcribed by eye from a
  render turned 90 degrees, is the registry's `reference_summary`: the eight
  heroes in the order Mantis, Gladiator, Firelord, Beta Ray Bill, Nova,
  Thor, Silver Surfer, Doc Strange. The Adventure Book's text (printed 3)
  sends the judge to pages of a Judge's Book, not this box, for the last
  four, so they are on the Summary alone, as in ME1 and ME2 (*Stat blocks:
  the Resource Book*, below).

## What an entry looks like

ME1's and ME2's: a bold capital header, an identity line in bold mixed case,
MA1's seven rows of number and rank code with `Health:`, `Karma:`,
`Resources:` and `Popularity:` to the right on rows F, S, R and P, then
`KNOWN POWERS:` with italic run-in powers, and `TALENTS:`, `CONTACTS:`,
`BACKGROUND:` as run-in capitals. Three columns a page (TSV line starts at
about 5%, 35% and 65% of the width on the Adventure Book's pages), art
taking a column on printed 3-5, and column 3 empty on printed 28.

Counted on the OCR of all 55 pages: `KNOWN POWERS:` 25, `BACKGROUND:` 18
(all in the Resource Book: the four heroes print none), `TALENTS:` 10,
`CONTACTS:` 10. Run-ins inside an entry that are not sections: `ITEMS:`
(Gladiator, Adventure 4), and in the Resource Book `WEAKNESS:` 4 times,
`WEAKNESSES:`, `LIMITATION:` and `MAGICAL ITEMS:`.

**Values the parser must accept as printed, in the Adventure Book:**

| printed | where |
|---|---|
| `Resources: Fe` / `(2)`, `Resources:` / `Mn(75)`, `Resources:` / `Pr(4)`, wrapped onto a second line | Mantis, Gladiator (3), Firelord (4) |
| `Resources:` / `10(Gd)`, the number before the code | Beta Ray Bill (5) |
| `Popularity: 15` / `(100 in the` / `Empire)`, wrapped over three lines | Gladiator (3) |
| `500 Shift Z`, with a space (ME2 printed `Sh Z`) | Gladiator's E and P (3) |
| `Health:325` with no space | Firelord (4) |
| `MANTIS (Update)` | Adventure p.3, as in ME1 and ME2 |
| a full block that prints each **code before its number** (`F Am 50`), with no identity line | Charon (24) |
| a codes-only one-line grid, `ShX` for Shift X | the Keeper (14) |
| a codes-only one-line grid wrapped after R, letters and codes on two lines each | the nine-headed serpent (11) |
| `Resources: N/A` | Charon (24) |

## Stat blocks: the Adventure Book

| where | blocks |
|---|---|
| Pregenerated heroes (printed 3-5) | 4 full grids: Mantis, Gladiator, Firelord, Beta Ray Bill |
| inside Beta Ray Bill's entry (printed 5) | 1 codes-only grid: his humanoid form |
| the chapters (printed 11-28) | 1 full block, code first: Charon; 4 codes-only grids |

**The chapters' blocks**, each read on its page image:

| name (as the registry has it) | printed | chapter | what is printed | Health | Karma |
|---|---|---|---|---|---|
| Vulture Flock | 11, column 1 | 3 | a codes-only grid with **no name line** (introduced on printed 10, the Purple Man's chapter) | 325 | 34 |
| Nine-Headed Serpent | 11, column 2 | 4 | a codes-only grid with **no name line**, wrapped after R | 350 | 34 |
| Keeper | 14, column 3 | 7 | `The Keeper`, a bold name line, over a codes-only grid | 260 | 450 |
| Charon | 24, column 2 | 11 | `CHARON`, a full seven-row block, code before number, with `KNOWN POWERS:` | 250 | 130 |
| Dimensional Shambler | 28, column 1 | 12 | `DIMENSIONAL SHAMBLER`, a codes-only grid, `KNOWN POWERS:` in column 2 | 275 | 22 |

The two names with no name line are this registry's, from what the prose
calls them (decision 5). No other chapter page
prints a grid: the OCR of PDF 8-34 holds no other `Health` line or row of
codes, and contact sheets of PDF 8-34 (about 210 pixels a page) show no
other grid.

**The book checks itself.** Each value below was read on the page image, and
each block held to Health = F+A+S+E, Karma = R+I+P, and each number to its
rank code (`apps/marvel-heroes/data/ranks.json`; a codes-only grid on each
code's standard number).

| block | printed | F A S E R I P | Health | Karma | holds |
|---|---|---|---|---|---|
| Mantis (Update) | 3 | 40 In, 40 In, 6 Ty, 30 Rm, 6 Ty, 20 Ex, 50 Am | 116 | 76 | yes |
| Gladiator | 3 | 75 Mn, 50 Am, 100 Un, 500 Shift Z, 100 Un, 75 Mn, 500 Shift Z | 725 | 675 | yes |
| Firelord | 4 | 75 Mn, 100 Un, 50 Am, 100 Un, 30 Rm, 50 Am, 30 Rm | 325 | 110 | yes |
| Beta Ray Bill | 5 | 100 Un, 30 Rm, 100 Un, 100 Un, 30 Rm, 20 Ex, 50 Am | 330 | 100 | yes |
| Beta Ray Bill, humanoid form | 5 | Ex Ex Ex Ex Rm Ex Am | 80 | 100 | yes |
| Vulture Flock | 11 | Mn Mn Mn Un Fe Rm Fe | 325 | 34 | yes |
| Nine-Headed Serpent | 11 | Un Mn Mn Un Fe Rm Fe | 350 | 34 | yes |
| Keeper | 14 | Gd Am Am ShX ShX ShX ShX | 260 | 450 | yes |
| Charon | 24 | Am 50, Mn 75, Am 50, Mn 75, In 40, In 40, Am 50 | 250 | 130 | yes |
| Dimensional Shambler | 28 | Am Mn Mn Mn Ty Gd Ty | 275 | 22 | yes |

| measure | count |
|---|---|
| full blocks, Health = F+A+S+E | **5 of 5** |
| full blocks, Karma = R+I+P | **5 of 5** |
| codes-only grids, Health and Karma both hold on standard numbers | **5 of 5** |
| every number its rank code's standard | **5 of 5** full blocks; no number inside a range and not its standard |

**No misprint in the Adventure Book's blocks** (page:name:field
printed->corrected: none). Mantis's, Gladiator's, Firelord's and Beta Ray
Bill's seven numbers and codes, Health, Karma and Popularity are ME2's
cards', value for value (`apps/marvel-heroes/data/npcs.json`, the `-me2`
rows), Beta Ray Bill's humanoid form included. Two Resources differ in
print: Gladiator's `Mn(75)` here against `Mn(175)` on his ME2 card, and Beta
Ray Bill's `10(Gd)` here against `Gd(10)`; *Names the Codex already has*
reads both.

`survey.py`, unchanged, finds **0** blocks in this book. It keys on
`Health =`, and this book prints `Health:`, as ME1 and ME2 do.

## Stat blocks: the Resource Book

| where | blocks |
|---|---|
| The Entities (printed 2-5) | 3: Death, Eternity, Galactus |
| The Death Gods (printed 6-10) | 8: Mephisto, `MEPHISTO (w/Galactus)`, Mephisto's Demonic Thralls, Mephisto's Footsoldiers, Pluto, Pluto's Footsoldiers, Hela, Seth |
| Other Characters (printed 11-16) | 10: Voyd, Uatu, Dormammu, Dormammu's second grid, Clea, Mindless Ones, Dark Dimension Inhabitant (Typical), Thanos, Captain Marvel, The Purple Man |
| **full grids** | **21**: the 19 Contents names and two second blocks |

Every grid was found from a `Health:` word in the TSV of PDF 36-50, and a
contact sheet of the 15 pages (34 dpi) shows no other. Each was read on a
crop of the page image at 120 dpi. The Resource Book prints no one-line or
codes-only grid.

**Two second blocks**, each a full grid for the being while it holds
Galactus's power:
- `MEPHISTO (w/Galactus)`, printed 6, column 1, a header of its own under
  Mephisto's first grid.
- Dormammu's second grid, printed 12, column 2, with **no header**: the
  sentence before it introduces it, and a note after it says his bracketed
  power ranks apply only while he holds Galactus.

**Two being changes stated in prose, not blocks:** a paragraph under Pluto's
grid (printed 8) gives other values in prose (his Health among them), and
Dormammu's powers print a second rank in brackets. Neither is a grid.

| block | printed | F A S E R I P | Health | Karma | Resources | Popularity | holds |
|---|---|---|---|---|---|---|---|
| Death | 2 | 5000 Cl 5000 seven times | 20,000 | Unlim. | Unlimited | -1000 | Health yes; Karma printed so |
| Eternity | 3 | 5000 Cl 5000 seven times | 20,000 | Unlimited | Unlimited | 0 | Health yes; Karma printed so |
| Galactus | 3 | 75 Mn, 75 Mn, 1000 Cl 1000, 3000 Cl 3000, 1000 Cl 1000, 1000 Cl 1000, 1000 Cl 1000 | 4150 | 3000 | Cl 3000 | -1000 | yes |
| Mephisto | 6 | 75 Mn, 75 Mn, 75 Mn, 3000 Cl 3000, 75 Mn, 75 Mn, 100 Un | 3225 | 250 | Cl 3000 | -1000 | yes |
| Mephisto (w/Galactus) | 6 | 100 Un, 100 Un, 1000 Cl 1000, 3000 Cl 3000, 75 Mn, 100 Un, 1000 Cl 1000 | 4200 | 1175 | - | - | yes |
| Mephisto's Demonic Thralls | 7 | 50 Am, 50 Am, 50 Am, 30 Rm, 6 Ty, 10 Gd, 20 Ex | 180 | 36 | - | - | yes |
| Mephisto's Footsoldiers | 7 | 40 In, 40 In, 40 In, 30 Rm, 4 Pr, 6 Ty, 10 Gd | 150 | 20 | - | - | yes |
| Pluto | 8 | 100 Un, 100 Un, 100 Un, 250 Shift Y, 75 Mn, 100 Un, 100 Un | 550 | 275 | Unearthly(100) | -500 | yes |
| Pluto's Footsoldiers | 9 | **code first**: Rm 30, Rm 30, In 40, In 40, Gd 10, Gd 10, Ex 20 | 140 | 40 | - | - | yes |
| Hela | 9 | 50 Am, 50 Am, 100 Un, 1000 Cl 1000, 30 Rm, 40 In, 100 Un | 1200 | 170 | Mn(75) | -75 | yes |
| Seth | 10 | 40 In, 40 In, 75 Mn, 75 Mn, 30 Rm, 40 In, 100 Un | 230 | 170 | Mn(75) | -50 | yes |
| Voyd | 11 | 5000 Cl 5000 four times, 50 Am, 1000 Cl 1000, 3000 Cl 3000 | 20,000 | 4050 | Fe(2) | 0 | yes |
| Uatu | 11 | 50 Am, 50 Am, 50 Am, 100 Un, 100 Un, 100 Un, 100 Un | 250 | 300 | Un(100) | 0 | yes |
| Dormammu | 12 | 100 Un, 100 Un, 75 Mn, 1000 Cl 1000, 75 Mn, 75 Mn, 100 Un | 1275* | 250 | Mn(75) | -30 | yes |
| Dormammu, second grid | 12 | 100 Un, 100 Un, 150 Shift X, 1000 Cl 1000, 75 Mn, 75 Mn, 150 Shift X | 1350 | 300 | - | - | yes |
| Clea | 13 | 20 Ex, 20 Ex, 30 Rm, 30 Rm, 20 Ex, 50 Am, 100 Un | 100 | 170 | Mn(75) | 70 | yes |
| Mindless Ones | 14 | 30 Rm, 4 Pr, 10 Gd, 20 Ex, 2 Fb, 2 Fb, 2 Fb | 64 | 6 | - | - | yes |
| Dark Dimension Inhabitant, Typical | 14 | 6 Ty, 10 Gd, 6 Ty, 6 Ty, 6 Ty, 10 Gd, 10 Gd | 28 | 26 | - | - | yes |
| Thanos | 15 | 75 Mn, 30 Rm, 100 Un, 100 Un, 50 Am, 20 Ex, 50 Am | 305 | 120 | Am(50) | -100 | yes |
| Captain Marvel | 15 | 30 Rm, 30 Rm, 40 In, 30 Rm, 10 Gd, 50 Am, 30 Rm | 130 | 90 | Pr(4) | 55 | yes |
| The Purple Man | 16 | 10 Gd, 10 Gd, 10 Gd, 20 Ex, 20 Ex, 10 Gd, 10 Gd | 50 | 40 | Rm(30) | -10 | yes |

Identity lines, bold mixed case under the header, where one is printed:
Galactus (Galan of Taa), Mephisto (an aka line of four names), Pluto
(Hades), Hela (Death Goddess of Asgard), Seth (Heliopolitan God of the
Dead), Uatu (The Watcher), Thanos (Thanos of Titan, deceased), Captain
Marvel (Mar-Vell of the Kree, deceased), the Purple Man (Zebediah Kilgrave,
deceased). The rest print none.

**Values the parser must accept as printed, in the Resource Book:**

| printed | where |
|---|---|
| `Health:` / `20,000`, with a comma | Death (2), Eternity (3), Voyd (11) |
| `Karma:` / `Unlim.`, abbreviated, and `Unlimited` | Death (2); Eternity (3) |
| `Resources:` / `Cl 3000`, `Unearthly(100)` (the rank word spelled out), `Fe(2)` | Galactus (3), Mephisto (6); Pluto (8); Voyd (11) |
| `Health:1275*`, no space, an asterisk keying a note under the grid | Dormammu (12) |
| a full block printing each **code before its number** (`F Rm 30`) | Pluto's Footsoldiers (9), as Charon (Adventure 24) |
| a header over two lines, its second line mixed case (`DARK DIMENSION` / `INHABITANT, Typical`) | 14 |
| a header with an apostrophe over two lines (`MEPHISTO'S DEMONIC` / `THRALLS`, `MEPHISTO'S` / `FOOTSOLDIERS`); Tesseract reads the mark as U+2019 | 7 |
| a header with a qualifier, `MEPHISTO (w/Galactus)` | 6 |
| a full grid with no header (Dormammu's second) | 12 |
| `Cl 1000`, `Cl 3000`, `Cl 5000` with a space, read by Tesseract as `Cl1000`, `CI5000`, `ClI3000` and `cCI1000` | throughout |

**The book checks itself**, each block held to Health = F+A+S+E, Karma =
R+I+P and each number to its rank code (`apps/marvel-heroes/data/ranks.json`):

| measure | count |
|---|---|
| full grids, Health = F+A+S+E | **21 of 21** |
| full grids, Karma = R+I+P, or printed otherwise | **21**: 19 hold; Death prints `Unlim.` and Eternity `Unlimited` (R, I and P 5000 each), as ME2's Death prints `Unlimited` |
| every number its rank code's standard | **20 of 21**: Pluto's E `250 Shift Y` is inside Shift Y's range (176-350), not its standard 200, and his Health 550 adds it; ME2's Pluto card prints the same E |
| every number within its rank code's range | **21 of 21** |

**No misprint in the Resource Book's blocks.**

**The Pregenerated Heroes Summary** (PDF 53, sideways), transcribed by eye
from a render turned 90 degrees into the registry's `reference_summary`.
Its eight rows are ME2's chart's, value for value and power for power.

| measure | count |
|---|---|
| Summary rows passing their own arithmetic | **7 of 8** (Firelord's Karma) |
| Summary rows with a block, agreeing with it in all nine values (a repeat) | **3 of 4** (Firelord's Karma) |

**The book's misprints**, page:name:field printed->corrected, each read on
the page image:

| misprint | the book's own arithmetic |
|---|---|
| Summary:Firelord:Karma 90->110 | his chart row's R 30, I 50 and P 30 sum to 110, and his block (Adventure 4) prints 110; ME1's and ME2's charts print the same 90 |

**Over the whole book:** 26 full blocks (the four heroes, Charon and the
Resource Book's 21), 5 codes-only one-line grids (Beta Ray Bill's humanoid
form, the vulture flock, the nine-headed serpent, the Keeper and the
Dimensional Shambler) and 8 Summary rows, four of them repeats of the
heroes' blocks. No chapter grid repeats a Resource Book block. **Card pages:**
Adventure 3-5 and Resource 2-16 (`character_ranges`); **chapter pages that
stat a being inside the prose:** Adventure 11, 14, 24 and 28 (`opponents`,
set by row 4a). One misprint, the Summary's Firelord Karma.

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-me3` id. Checked against `apps/marvel-heroes/data/npcs.json`:

- **All eight heroes are ME1's and ME2's.** The four with a block print
  ME2's seven numbers and codes, Health, Karma and Popularity, and the
  Summary is ME2's chart. Two Resources differ in print:
  - Gladiator: `Mn(75)` here, `Mn (175)` on ME1's card and `Mn(175)` on
    ME2's. 75 is Monstrous's standard and 175 is outside its range (63-87),
    so this book's print is the consistent one. Resources are not held to
    any arithmetic, and each card shows its own book's print, so nothing
    here is corrected. Whether ME1's and ME2's 175 is a misprint is a
    question about those books, not this one.
  - Beta Ray Bill: `10(Gd)` here, `Gd(10)` on ME2's card. The same value,
    number first: a format the parser accepts, not a difference.
- **The same values as an existing card:** Galactus (MA4, ME2), Mephisto
  (MA4), Pluto (ME2), Hela (ME2), Death (ME2) and Uatu (MA4 and MHSP2,
  each filed as `Watcher` with the identity Uatu; this book prints the
  header `UATU` and the identity The Watcher).
- **Other values than an existing card:** Eternity (MHSP2: Class 1000
  throughout, Health 4000), Death (MHSP2), Mephisto (MHSP2 and MH9: E
  Class 1000, Health 1225), Galactus (MHSP1) and Charon (ME2's, Adventure
  18, another grid with other numbers).
- **Captain Marvel is a different person.** MHSP1's, MH2's and MHSP2's are
  Monica Rambeau (identity lines on MH2 and MHSP2); this book's is Mar-Vell
  of the Kree, deceased. Decision 6.
- MHSP2's Vulture (Adrian Toomes) and MH6's Giant Vulture and Crystal
  Serpent are other beings than the vulture flock and the nine-headed
  serpent here.

Every other name is new to the Codex: Mephisto's Demonic Thralls, Mephisto's
Footsoldiers, Pluto's Footsoldiers, Seth, Voyd, Dormammu, Clea, the Mindless
Ones, the Dark Dimension Inhabitant, Thanos, the Purple Man, the Keeper, the
Dimensional Shambler, the vulture flock and the nine-headed serpent.

## Quote marks

**No single-quoted phrase of the book's own was found.** Measured on the OCR
of all 55 pages: 147 double marks (76 opening, 71 closing), 43 opening
singles, 354 closing singles (apostrophes, nearly all) and 10 straight
marks. On the card pages (Adventure 3-5, Resource 2-16) and the opponents'
pages (Adventure 11, 14, 24 and 28) there are 12 opening singles, on four
pages: PDF 40 (6), 41 (2), 44 (2) and 16 (2). Every one is an opening double
read as two singles, or as a double and a single: Mephisto's aka line and a
word on printed 6 were read on the page image and print doubles, and the
rest are paired singles before a word closed by a double. The opponents'
pages 11, 24 and 28 hold none. So the rule is MHSP1's, ME1's and ME2's:
every single that is not an apostrophe is half of a double. Apostrophes in
the headers (`MEPHISTO'S`, `PLUTO'S`) are real.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with things taught to it**,
as ME2's was. Measured 2026-10-30 (plan row 4c): a scratch copy of
`scripts/msh/` and `apps/marvel-heroes/data` at this branch's `042f868f`,
the me3 entry given `"layout": "grid-booklets"`, `rank_ranges: true`
(decision 3), `roster_sections` (Pregenerated Heroes, The Entities, The
Death Gods, Other Characters) and trial `teams` (decision 1), and a trial
`me3-overrides.json` holding decision 4's three, run on a copy of the cache
under its own `WORKSHOP_MSH_CACHE`.

**The stock reader stops.** `roster.py me3` exits 1 at
`one_line_grids not found: Nine-Headed Serpent` (item 1) and writes nothing.
Past that one stop it runs to the end:

| measure | stock, past the stop | with every trial change |
|---|---|---|
| entries | 34: 21 with a block, 13 without | 33: 32 with a block, 1 without (The Entities' banner) |
| stat blocks | 22 | 35: 26 full grids, 5 codes-only grids, 4 Summary-only heroes |
| blocks passing every check | 21 | 32, and 3 known from the overrides |
| failing | 1 (Charon, unread) | 0 |
| Contents names with no entry | 11 | 0 |
| opponents with no entry | 0 of 5 | 0 of 5 |
| Health or Karma not a number | 5 | 0 |
| Summary | 8 of 8 placed; Firelord's Karma matched to its override | the same |
| exit code | 1 | **0** |

What the reader row needs. Items 1-11 are reader changes (each was made in
the scratch copy, marked as the trial's, except 7's remainder and 8); 12 and
13 are overrides only:

1. **A codes-only grid wrapped after R** (Adventure p.11, column 2, the
   serpent): its letters and its codes are each set on two lines.
   `line_grids` wants the seven letters on one line, so the stock reader
   stops. Reader: join the two halves of each.
2. **A Health set on the line below its label** (`Health:`, then the value
   at the column's right): Death (Resource p.2), Eternity and Galactus (3),
   Mephisto and his second grid (6), Hela (9), Voyd (11) and Dormammu's
   second grid (12), 8 grids. With no number after the label
   `roster.ANCHOR` finds no grid, so `mark_headers` finds no header either,
   and each grid's lines fall into the entry above as its identity or text.
   Reader: join the value to its label's line.
3. **A Popularity set on the line below its label**, on every Resource Book
   grid that prints one (14: Death, Eternity, Galactus, Mephisto, Pluto,
   Hela, Seth, Voyd, Uatu, Dormammu, Clea, Thanos, Captain Marvel, the
   Purple Man). `roster.grid_at`'s crop ends at the label's line, so the
   value is cut off and every one reads as none. Reader: take the value's
   line into the crop, and skip it after the grid.
4. **Grids that print no Resources and no Popularity**: Mephisto's second
   grid (6), Mephisto's Demonic Thralls and Mephisto's Footsoldiers (7),
   Pluto's Footsoldiers (9), Dormammu's second grid (12), the Mindless Ones
   and the Dark Dimension Inhabitant (14), 7 grids. `grid_at` ends a grid at
   its Popularity line and, finding none, reads no grid. Reader: end such a
   grid at its P row.
5. **Rows that print the code before the number** (`F Am 50`): Charon
   (Adventure 24) and Pluto's Footsoldiers (Resource 9). `roster.ROW` wants
   the number first, so Charon's block is unread and his Health and Karma
   take in the next rows. MA4's `code_rows` reads a code then a bracketed
   number, not this. Reader: turn such a row round.
6. **A Class code read with a mark before it** (a copyright sign, then
   `ClI1000`: Dormammu's E, Resource 12). The mend for ME2's `CIl5000` wants the code right after the
   number, so E's code is unread and the rest of its row welds onto the
   Karma (`250 I1000`). Reader: allow one mark before it.
7. **Marks of the art beside a grid, after a number**: Captain Marvel's
   Karma `90 = R` (Resource 15) and the Mindless Ones' Health `64` with a
   quote mark after it (14). `secondary()` strips trailing letters, not
   marks. Reader: strip a trailing mark and what follows it. **Left by the
   trial:** Captain Marvel's Resources still read `Pr(4) : a` and his
   Popularity `/) 55`, the same art read beside his rows.
8. **A bracketed note right under a grid joined onto its Popularity**
   (Mephisto 6, Pluto 8). `secondary()` takes a line opening with a bracket
   after the grid as the rest of a wrapped Popularity, which Gladiator's is
   (Adventure 3, three lines). **Left by the trial.** Reader: tell the two
   apart.
9. **A header Tesseract misread**: `VOYD` (Resource 11) is read at
   confidence 38 and dropped, so his grid lands in the Other Characters
   banner's entry. Registry: ME2's `grid_headers`, but its Health match
   reads no comma (`20,000`), so one reader line too.
10. **Headers set on two lines**: `MEPHISTO'S DEMONIC` / `THRALLS` and
    `MEPHISTO'S` / `FOOTSOLDIERS` (7), `DARK DIMENSION` /
    `INHABITANT, Typical` (14). `mark_headers` marks only the line nearest
    the grid, so the entries were `THRALLS`, `FOOTSOLDIERS` and
    `DARK DIMENSION`, which match no Contents name. Reader: a way to join
    them. The trial used a registry list of the two lines as read
    (`two_line_headers`, the trial's name); a rule (a capital line right
    above the header joins it) is the alternative, proved on every earlier
    book before it ships.
11. **A header that labels a second grid**: `MEPHISTO (w/Galactus)` (6)
    becomes an entry of its own that takes every power printed under it,
    leaving Mephisto's entry none. Reader: fold it into the entry above as a
    labelled block (the trial: a registry list, `block_labels`). `npcs.py`'s
    `second_blocks` joins a chapter's grid to a card in the other booklet,
    not this.
12. **Dormammu's `Health:1275*`** (12), the asterisk keying the note under
    his grid. Override only: `as_printed` on his first grid's Health,
    matched by its codes, since his second grid shares the page and header.
13. **Death's `Unlim.` and Eternity's `Unlimited` Karma, and the Summary's
    Firelord Karma.** Overrides only, decision 4, as ME2's.

**Read right with nothing changed:** the four heroes and Beta Ray Bill's
humanoid form; the vulture flock, the Keeper and the Dimensional Shambler
through `one_line_grids` (the flock's letters read with marks for S and I,
and still match); Dormammu's second grid with no header, which lands as a
second block on his entry, as decision 5 wants (its label is the reader
row's); the inverted Dark Dimension Inhabitant name; the swapped Clea and
Dormammu pages; `Health: 20,000` with a comma, once anchored (ME2's); and
the Summary's eight rows.

**So the reader must learn 11 things** (items 1-11, item 9 a single line
beside a registry field), and the overrides file holds 4 entries. The trial
did not judge the power run-ins (Death, Eternity and Voyd read none;
Dormammu, Clea, the Dark Dimension Inhabitant and the Purple Man one each)
or run `npcs.py`. The trial's registry patch, its two reader diffs and its
last run are kept in the plan's store (row 4c, `trial/me3/`), not the repo.

The other readers fit less: `roster.py` (MA1) reads one offset, not two
booklets; `codegrids.py` (MA4) reads every row code first with the number
bracketed; `booklet.py` (MHSP1), `rosterbook.py` (MHSP2) and
`coverpanels.py` (MH1, MH2) read rank words with no numbers.

This survey sets no `layout`, as ME2's did not: that is the reader row's.

## Decisions this survey leaves open

Each has a recommendation, and each recommends what ME2 (the nearest book)
did. Nate, 2026-10-30: take the survey's recommendations when a decision
arises. None is written to the registry until the row that applies it.

1. **Teams.** Recommendation: the Resource Book's banners without the
   leading The, as ME2's were: **Entities** (ME2's group already) and
   **Death Gods** (new). `Other Characters` names no team, so those ten
   file under the book's title, **ME3 The Left Hand of Eternity**, as the
   chapters' opponents do (ME1's and ME2's rule for a chapter's opponent).
   The four heroes and the Summary's four as **Left Hand of Eternity
   Heroes**, as ME2's are Ragnarok and Roll Heroes. The alternative for the
   heroes is one group shared by the three books' eight.
2. **Page citations.** Recommendation: ME2's shape, `ME3 Adventure p.3`,
   `ME3 Resource p.12`, and `ME3 Pregenerated Heroes Summary` with no page.
3. **Pluto's in-range number** (`250 Shift Y`, Resource 8). Recommendation:
   ME2's ruling, `rank_ranges: true` for this book, so the number passes as
   printed; it is the same E ME2's Pluto card prints. The alternative is one
   override, as ME1's Superkree has.
4. **The misprint and the unlimited Karmas.** Recommendation: an override
   keeping printed and corrected for the Summary's Firelord Karma (90 to
   110), as ME2's; Death's `Unlim.` and Eternity's `Unlimited` kept as
   printed (`as_printed`), as ME2's Death.
5. **Second blocks and the grids with no name line.** Recommendation:
   `MEPHISTO (w/Galactus)` and Dormammu's second grid as second blocks on
   their cards, each labelled for Galactus, and Beta Ray Bill's humanoid
   form as a second block on his, as ME2's Titans, Zeus and humanoid form
   are. The vulture flock and the nine-headed serpent as entries of their
   own named as the registry has them (`Vulture Flock`,
   `Nine-Headed Serpent`, from the prose), as ME2 named its grids with no
   name line; the Keeper (the leading The dropped), Charon and the
   Dimensional Shambler as entries of their own.
6. **Names.** Recommendation: as printed, the leading The dropped (Purple
   Man) and the inverted `Dark Dimension Inhabitant, Typical` kept, as ME2
   kept `Olympian, Typical`; Uatu as printed, not MA4's and MHSP2's
   `Watcher`. **Captain Marvel:** Nate's ruling on MA1's and MH1's Ariel
   (2026-10-21) was that each card's name says which person, so this
   book's card as `Captain Marvel (Mar-Vell)` and the three Monica Rambeau
   cards (MHSP1, MH2, MHSP2) as `Captain Marvel (Monica Rambeau)`, through
   `card_names`. The option that ruling did not take is to label the new
   card only, which leaves the three other books untouched.
7. **The four Summary-only heroes.** Recommendation: cards marked
   Summary-only, as ME1's and ME2's four are.

## How to reproduce

```bash
python scripts/msh/ocr-book.py me3 --probe
python scripts/msh/ocr-book.py me3
python scripts/msh/survey.py me3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 25-110
dpi into the scratchpad, never into the repo.
