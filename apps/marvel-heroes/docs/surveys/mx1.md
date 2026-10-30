# Survey: MX1 Nightmares of Futures Past (TSR6873)

> **DRAFT.** Measured up to *Which reader fits*, which is not finished: the
> trial parse that settles it is the next row's. Nothing here is data yet.

Official Advanced Game Adventure for Marvel Super Heroes, Steve Winter, 1987.
Registry entry: `scripts/msh/books.json` -> `mx1`. Measured 2026-10-30.

**Rows citing this book:** 0 `msh_book_text` rows (no data has been built).

Everything here was measured and read on the page images.

The first module of the MX series, through `scripts/msh/` only. Characters
only (Nate, 2026-10-21): the adventure, items and places are not imported.

## The scan

- 37 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 on PDF 2, 5, 10
  and 20), cached 2026-10-30 into the main checkout's `.cache/msh/books/mx1/`
  (`manifest.json`: 300 dpi, `--psm 3`, Tesseract 5.4.0, 37 pages OCR'd).
- **One 32-page booklet**, its covers, two inside covers and one map sheet.
  The back cover names the package as a 32-page book and one map. The print
  is clean; the grids and the run-in labels OCR well, the banners (capitals
  in a brick band) mostly do not.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 601 x 779 | Cover (outside front) | - |
| 2 | 598 x 770 | Search Flow Chart (an inside cover) | - |
| 3-34 | 594 x 767 | Adventure Book | 1-32 |
| 35 | 598 x 770 | Sentinels' Surveillance Base map (the other inside cover) | - |
| 36 | 601 x 779 | Back cover (product code 6873, ISBN 0-88038-402-6) | - |
| 37 | 2344 x 1520 | Map sheet: a suburban neighbourhood and the Mutant Internment Center | - |

The Contents names both inside covers (`inside cover`), so each is a part of
its own with `offset` null; the flow chart's boxes print rank words (it is
a search table), and the base map is a floor plan. Neither, nor the map
sheet, prints a statistic. None is imported.

## Offset

`survey.py` votes **printed = PDF - 2 on 22 pages** (PDF 9-34 but 10, 11,
19 and 31). The rest, each read on the page image:

- PDF 4, 5, 6, 8, 10 and 11: their folios (2, 3, 4, 6, 8 and 9) are at the
  foot, missed by Tesseract.
- PDF 7, 19 and 31 (printed 5, 17 and 29): full-page art, no folio.
- PDF 3 (printed 1): the title and Contents page, no folio.
- PDF 36: a vote of 8 (k = 28), the bar code's digits. Not a folio.

So `parts`, as MH9's single booklet, with the covers, the inside covers and
the map sheet as parts of their own.

## The book's own authority lists

**A Contents** on printed 1 (PDF 3), in two columns, transcribed from the
page image (the OCR mangles the dot leaders) and stored as `sections`. Every
entry was read on its page, its banner at the top of column 1:

| printed | Contents | banner as printed |
|---|---|---|
| 2 | Welcome To My Nightmare | WELCOME TO MY NIGHTMARE |
| 3 | The Mutant Affairs Control Act | THE MUTANT AFFAIRS CONTROL ACT |
| 6 | The X-Factor | THE X-FACTOR |
| 8 | Project Wideawake | PROJECT WIDEAWAKE |
| 13 | The Tools of Oppression | THE TOOLS OF OPPRESSION |
| 15 | Mutants Underground | MUTANTS UNDERGROUND |
| 19 | Special Rules | SPECIAL RULES |
| 20 | Night & Fog | NIGHT & FOG |
| 24 | Non-Player Characters | NON-PLAYER CHARACTERS |
| 26 | Scenarios and Events | **EVENTS AND SCENARIOS** |
| inside cover | Sentinels' Surveillance Base | (PDF 35) |
| inside cover | Search Flow Chart | (PDF 2) |

**Every page agrees**, so there is no `contents_errata`. One banner's words
differ from its Contents line (printed 26); the registry keeps the Contents
as printed, as ME2's does its inverted names. The prose numbers the chapters
(chapter 9 for the NPCs, chapter 10 for Scenarios and Events); the banners
print no number.

**No index.** The coverage checklist is this survey's list, carried as
`cards` and `opponents` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's rows and its
  labels are two sub-columns of one column.
- **Three grid shapes in one book** (read on the page images of printed
  9-11, 13, 24, 25 and 28):
  1. **The sentinels' blocks** (printed 9-11): MA1's, a number then its code
     (`20 Ex`, `150 Shift X`) on seven rows, with `Health =`, `Karma =`,
     `Resources =` and `Popularity =` beside rows F, S, R and P, under a
     header in **bold title case** (`Mark IV Sentinel`), with no identity
     line. The Mark VI's header ends in a colon. The OCR welds number and
     code (`20Ex`).
  2. **The character blocks** (Blue, printed 13; the five NPCs, printed 24
     and 25; Oliver Pierce, printed 28): **the code, then the number in
     brackets** (`Gd (10)`), with `Health:`, `Karma:`, `Resources:` and
     `Popularity:` beside them, under a bold header and a bold identity line
     (`Human journalist`). This is MA4's order, not MA1's.
  3. **Codes-only grids** (printed 13 and 28): an `F A S E R I P` row, a row
     of seven codes, then `Health:` and `Karma:` on one line. None of the four
     prints a row of numbers. Three sit under bold title-case subheads
     (`The Blue Knight`, `SWAT:AM`, `Mantinels`), set in the same type as a
     card's header but with no identity line; the fourth under a plain line,
     `Typical Rogue`.
- **Section labels**, counted on the OCR of printed 9-14 and 24-30 and read
  on the images: `Known Powers:` (14, four of them `Known Powers: none.`),
  `Talents:` (8), `Contacts:` (7), `Background:` (7) and `Talent:` once (the
  typical policeman). Bold title-case run-ins. The sentinels print `Known
  Powers:` only, their powers as run-in heads ending in a colon.
- **Ranks**: Fb (never Fe), Pr, Ty, Gd, Ex, Rm, In, Am, Mn, Un (the Mark V's
  Endurance) and `Shift X` (four sentinels' Endurance). In `rank_aliases`.
  Nimrod's `Gy` is a misprint, not an alias (below).
- **Resources** prints a code and number (`Pr (4)`), wraps the number onto a
  second line on three blocks (Nimrod `In` / `(40)`, Morava and Carns `Ex` /
  `(20)`), prints `0` on the five sentinels, and `Fb` with no number on
  Oliver Pierce's.
- **`survey.py` finds 6 blocks and reads none of them**: it finds the
  sentinels' `Health =` lines (no other block prints `=`), but its header
  rule wants capitals and its row pattern a space between number and code.
  Its block count is not this book's measure.

## Where the blocks are

Printed 9-11 (Project Wideawake: the six sentinels), printed 13 (The Tools
of Oppression: three codes-only grids and Blue, whose text runs on to 14),
printed 24-25 (Non-Player Characters: five) and printed 28 (Scenarios and
Events: the Typical Rogue and Oliver Pierce, whose text runs on past the art
of printed 29 to printed 30). The Health and Karma the OCR finds anywhere
else are rules prose (printed 9, 11, 15, 19, 30, 31), not grids. Not one page
outside the booklet holds a Health, Karma or rank row.

## Stat blocks: 12 cards and 5 grids

| printed (PDF) | name | shape | F A S E R I P as printed | Health | Karma |
|---|---|---|---|---|---|
| 9 (11) | Mark IV Sentinel | 1 | 20 Ex, 20 Ex, 50 Am, 75 Mn, 6 Ty, 6 Ty, 6 Ty | 165 | 0 |
| 9 (11) | Mark V Sentinel | 1 | 20 Ex, 20 Ex, 50 Am, 100 Un, 10 Gd, 6 Ty, 6 Ty | 190 | 0 |
| 9 (11) | Mark VI Sentinel | 1 | 30 Rm, 20 Ex, 50 Am, 150 Shift X, 10 Gd, 10 Gd, 6 Ty | 250 | 0 |
| 10 (12) | Alpha Sentinel | 1 | 50 Am, 40 In, 50 Am, 150 Shift X, 20 Ex, 10 Gd, 10 Gd | 290 | 0 |
| 11 (13) | Omega Sentinel | 1 | 50 Am, 40 In, 50 Am, 150 Shift X, 30 Rm, 20 Ex, 10 Gd | 290 | 0 |
| 11 (13) | Nimrod | 1 | 50 Am, 50 Am, 50 Am, 150 Shift X, 30 **Ex**, 30 **Gd**, 10 **Gy** | 300 | 70 |
| 13 (15) | Blue (Hugh Blumal, mutant hound) | 2 | Gd 10, Gd 10, Pr 4, In 40, Pr 4, Mn 75, Rm 30 | 64 | 109 |
| 24 (26) | Gerald Gage | 2 | Pr 4, Ty 6, Pr 4, Ty 6, Ty 6, Gd 10, Ty 6 | 20 | 22 |
| 24 (26) | Timbre Morava | 2 | Pr 4, Ty 6, Ty **4**, Ty 6, Ex **6**, Ty **8**, Ty 6 | 22 | 32 |
| 25 (27) | Big Foot | 2 | Gd 10, Gd 10, **Ty** 4, Ex 20, Pr 4, **Ty** 8, Ty 6 | 44 | 18 |
| 25 (27) | Bernard Carns | 2 | Pr 4, Pr 4, Pr 4, Pr 4, Gd 10, Ty 6, Ty 6 | 16 | 22 |
| 25 (27) | Arthur Faber | 2 | Ex 20, Gd 10, Ty 6, Gd 10, Ty 6, Ty 6, Ty 6 | 46 | 18 |
| 13 (15) | Typical Policeman (opponent) | 3 | Gd Gd Ty Gd Ty Ty Ty | 36 | 18 |
| 13 (15) | SWAT:AM (opponent) | 3 | Ex Gd Gd Ty Ty Ty Gd | 46 | 22 |
| 13 (15) | Mantinels (opponent) | 3 | Gd Gd Rm Ex Ty Ty Ty | 70 | 18 |
| 28 (30) | Typical Rogue (opponent) | 3 | Ty Ty Ty Gd Pr Ty Pr | 28 | **16** |
| 28 (30) | Oliver Pierce (opponent) | 2 | Fb 2, Ty 6, Pr 4, Pr 4, Pr 4, Ty 6, Ty 6 | 16 | 16 |

Shape 1 prints the number before the code, shape 2 the code before the
number; the table writes each in its own order. Resources and Popularity:
the sentinels 0 and 0 (Nimrod `In (40)` and 0), Blue `Fb (2)` and 0, Gage
`Pr (4)` and 5, Morava `Ex (20)` and 10, Big Foot `Fb (2)` and 0, Carns
`Ex (20)` and 0, Faber `Ty (6)` and 20, Pierce `Fb` and 0. The codes-only
grids print neither.

**The Omega Sentinel's sixth row prints the letter `U`, not `I`** (printed
11, read on the image): its value, 20 Ex, is the Intuition row's. A row
letter, not a value; the reader takes the row by position.

**The book checks itself**, each value read on a crop of the page image, and
codes-only grids on each code's standard number (`ranks.json`):

| measure | count |
|---|---|
| Health = F+A+S+E | **16 of 17**; Timbre Morava's fails as printed (20, printed 22) |
| Karma = R+I+P | **10 of 17**; the five sentinels' `Karma = 0` (printed on purpose, below), Morava's (20, printed 32) and the Typical Rogue's (14, printed 16) |
| every number its rank code's standard | **14 of 17** (the codes-only four included); Nimrod, Morava and Big Foot are not |
| every number within its rank code's range | the same 14; Big Foot's I 8 is inside Good's range (8-15) once its code is corrected |

**The misprints, each read on the page image** (printed page: name: field
printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 11:Nimrod:R code Ex -> Rm (30) | Karma 70 = 30+30+10 holds on the numbers; 30 is Remarkable; MA1 (p.81) prints his R 30 Rm |
| 11:Nimrod:I code Gd -> Rm (30) | as above; MA1 prints I 30 Rm |
| 11:Nimrod:P code Gy -> Gd (10) | Gy is no code; 10 is Good; MA1 prints P 10 Gd |
| 24:Timbre Morava:S 4 -> 6 | Health 22 = 4+6+6+6 holds on her code Ty's standard 6, and on no reading that keeps 4 |
| 24:Timbre Morava:R 6 -> 20 | Karma 32 = 20+6+6 holds on her codes (Ex, Ty, Ty); her printed numbers sum to 20 |
| 24:Timbre Morava:I 8 -> 6 | as above; 8 is not Typical (5-7) |
| 25:Big Foot:S code Ty -> Pr (4) | Health 44 = 10+10+4+20 holds on the numbers and fails on Ty's 6; 4 is Poor |
| 25:Big Foot:I code Ty -> Gd (8) | Karma 18 = 4+8+6 holds on the numbers and fails on Ty's 6; 8 is Good's range, not its standard (decision 5) |
| 28:Typical Rogue:Karma 16 -> 14 | a codes-only grid: Pr+Ty+Pr = 4+6+4 = 14, and its Health 28 holds on the same codes |

Morava and Big Foot print the same two wrong pairs, `Ty (4)` on S and
`Ty (8)` on I, but they resolve opposite ways: Big Foot's numbers add to his
Health and Karma, Morava's codes add to hers. The Typical Rogue's 16 would
hold if either Pr were Ty; nothing on the page says which, so the codes are
kept and the Karma corrected (decision 4).

**Printed on purpose:** the five sentinels other than Nimrod print `Karma =
0`, `Resources = 0` and `Popularity = 0` (robots; MA1 prints `-` for the same
machines). Their R, I and P are printed, so Karma = R+I+P cannot hold.

## Entry kinds

1. **A robot type with a number-code block**: the five sentinel marks, a
   header and no identity line.
2. **A named robot**: Nimrod, the same shape, with Karma and Resources.
3. **A named character with a code-number block**: Blue (a mutant hound),
   Gerald Gage, Timbre Morava, Big Foot, Bernard Carns, Arthur Faber.
4. **A type with a codes-only grid**, under a subhead and introduced by the
   text: the typical policeman (subhead The Blue Knight), SWAT:AM and the
   Mantinels (the armor's wearer; the text says the ranks are the original
   armor's), and the Typical Rogue (the line `Typical Rogue` over the grid).
5. **A named character with no header line**: Oliver Pierce (printed 28),
   introduced by an event's prose, whose grid is shape 2. The text offers a
   female variant, Olive Pierce.
6. **Characters in the prose only**, named and not statted: the history's
   (Robert Kelly, Gyrich and others, printed 3-4), Dana Washington (the back
   cover's journal) and Wolverine (an example, printed 9).
7. **Gear with ranks**, out of scope by Nate's ruling: the police and
   SWAT:AM equipment lists (printed 13), the Mantinel armor's weapon systems,
   the surveillance base (printed 12).

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-mx1` id:

- **MA1's Sentinels** (The Mutant Menace, MA1 p.80-81): `Mark IV & V
  Sentinels` (one card, a block each, and a third block `Mark VI Prototype
  Sentinel`), `Alpha Sentinel`, `Omega Sentinel` and `Nimrod`, read against
  `npcs.json`. **Every MX1 sentinel prints MA1's numbers and codes** except:
  the Mark IV's and Mark V's P, `6 Ty` here and `4 Pr` in MA1 (both hold:
  neither prints a Karma); Nimrod's three codes, MA1's right and MX1's
  misprinted (above); and Nimrod's A code, `Am` here where MA1's card stores
  `In`. MA1 gives the Mark IV and Mark V one card; MX1 gives each a header
  of its own (decision 1).
- MH1's `Sentinels` and MHSP2's `Sentinels` are other blocks of the same
  machines under other names.
- MH8's `Police` and `SWAT Team Member` are other books' police, with
  different ranks; MA1's and others' `Rogue` is the X-Man, not the Typical
  Rogue.

Every other name (Blue, the five NPCs, Oliver Pierce, SWAT:AM, the
Mantinels) is new to the Codex.

## Quote marks

**No single-quoted phrase of the book's own was found.** Measured on the OCR
of all 37 pages: 43 double marks (19 opening, 24 closing), 4 straight
doubles, 44 opening singles and 235 closing singles (mostly apostrophes).
Most opening singles are an opening double read as a pair of singles, or as
a double followed by a single. The 21 lines with a lone single mark hold
one on a character page, in the lettering of the art on printed 10, and
none in a block's text; three read on the images were doubles (printed 4,
around a directive; printed 19, around a three-word phrase) or a speck of
the scan (printed 3). So the rule looks like MHSP1's and ME2's (every single
that is not an apostrophe is half of a double), and **the data row must
confirm it on the character pages** before relying on it. Apostrophes after
a name ending in s are real; the Contents' `Sentinels'` is one.

## Which reader fits

**Not finished.** The next row runs the trial parse. What it starts from,
measured above: three grid shapes (*Columns, labels and ranks*); headers in
title case, not capitals, and three subheads in the same type with no
identity line; an `=` on the sentinels' labels and a `:` on
everyone else's; two Resources lines wrapped and one with no number; the
Omega's `U` row; five grids with no header and identity line; and one
booklet, as MH9's. ME2's `grid-booklets` reads shape 1's order but `Health:`;
MA4's `codegrids.py` reads shape 2's order; MH9's `cover-panels` reads rank
words. None is chosen here, and the entry sets no `layout`.

## Decisions this survey leaves open

Each has a recommendation, the one ME2 and MH9 took where they had the same
question (Nate 2026-10-30: take the survey's recommendations).

1. **Teams.** The book has no team sections. Recommendation: every card
   under the book's title, **MX1 Nightmares of Futures Past**, as MH1 filed
   its Sentinels and MH9 its divergent Earth; the six sentinels each a card
   of their own (the Mark IV and Mark V too, since each prints its own
   header). The alternative is MA1's group, The Mutant Menace, for the
   sentinels. Not written to the registry until decided.
2. **Page citations.** Recommendation: MH9's single-booklet shape,
   `MX1 Adventure p.24` (the part's `cite` is `Adventure`).
3. **Names for the five grids with no header and identity line.**
   Recommendation, as MH9's opponents were named from what the text calls
   them: **Typical Policeman** (the text's own words, under the subhead The
   Blue Knight), **SWAT:AM** and **Mantinels** (their
   subheads), **Typical Rogue** (the line over its grid) and **Oliver
   Pierce** (the prose). Each an entry of its own. In the registry as
   `opponents`.
4. **The misprints.** Recommendation: overrides keeping printed and
   corrected, as listed under *Stat blocks*: Nimrod's three codes (as MA1
   prints them), Morava's three numbers (to her codes), Big Foot's two codes
   (to his numbers), the Typical Rogue's Karma 16 to 14 (its codes kept, as
   its Health holds on them); and the five sentinels' `Karma = 0` kept
   `as_printed` (robots). The Omega's `U` row letter is a reading matter for
   the parser, not an override.
5. **Big Foot's I 8**, the one number inside a rank's range but not its
   standard. Recommendation: an `also` inside his code override, as ME2's
   Chimaera's S, rather than `rank_ranges` for the book, which ME2 took for
   twenty-seven values and this book needs for one.
6. **Shape 2's Resources with no number** (Oliver Pierce's `Fb`).
   Recommendation: kept as printed, the card showing the code alone.
7. **Oliver or Olive Pierce.** Recommendation: one card, **Oliver Pierce**,
   the name the text gives first; the variant is the Judge's choice at the
   table, not a second block.
8. **Characters only.** The equipment lists, the Mantinel armor's weapons,
   the surveillance base and the maps are not imported (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mx1 --probe
python scripts/msh/ocr-book.py mx1
python scripts/msh/survey.py mx1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 50-150
dpi into the scratchpad, never into the repo.
