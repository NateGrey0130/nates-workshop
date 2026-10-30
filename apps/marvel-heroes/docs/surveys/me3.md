# Survey: ME3 The Left Hand of Eternity (TSR6882)

> **DRAFT.** The first half, measured 2026-10-30 (plan row 4a): the scan,
> the parts and offsets, the authority lists and the Adventure Book's stat
> blocks. The Resource Book's blocks, the Pregenerated Heroes Summary and
> every section marked *Not finished* are the next row's.

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
  three section banners were read on their pages and agree; the character
  headers are read with the Resource Book's blocks (*Not finished*).
- **No index.** As in ME2, the Resource Book's Contents is that booklet's
  checklist, and neither Contents names the opponents statted inside the
  chapters (below), which the registry lists as `opponents`.
- **The Pregenerated Heroes Summary** (PDF 53) is *Not finished*. The
  Adventure Book's text (printed 3) sends the judge to pages of a Judge's
  Book, not this box, for Thor, the Silver Surfer, Nova and Doctor Strange, so expect those four
  on the Summary alone, as in ME1 and ME2.

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

## Stat blocks: the Adventure Book (the Resource Book's are *Not finished*)

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
calls them; that is a decision left to the next row. No other chapter page
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
Ray Bill's `10(Gd)` here against `Gd(10)`. Which is right is a question for
the next row's *Names the Codex already has*.

`survey.py`, unchanged, finds **0** blocks in this book. It keys on
`Health =`, and this book prints `Health:`, as ME1 and ME2 do.

## Stat blocks: the Resource Book

Not finished.

## Names the Codex already has

Not finished.

## Quote marks

Not finished.

## Which reader fits

Not finished.

## Decisions this survey leaves open

Not finished.

## How to reproduce

```bash
python scripts/msh/ocr-book.py me3 --probe
python scripts/msh/ocr-book.py me3
python scripts/msh/survey.py me3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 25-110
dpi into the scratchpad, never into the repo.
