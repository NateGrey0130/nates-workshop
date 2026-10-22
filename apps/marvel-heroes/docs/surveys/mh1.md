# Survey: MH1 The Breeder Bombs (TSR6851)

Marvel Super Heroes adventure module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mh1`. Measured 2026-10-21.

**Rows citing this book:** 63 `msh_book_text` rows over 25 character entries
in production (`DB_MARVEL`, read back 2026-10-21, again after Ariel's three
moved from `ariel-mh1` to `ariel-kitty-pryde-mh1` the same day).

Committed: 25 characters in `apps/marvel-heroes/data/npcs.json` (12 full
blocks, 13 one-line grids), with 28 powers, 15 of them linked to the Ultimate
Powers Book, read by the `cover-panels` layout. No items and no adventure.

This is the fifth Marvel book, and the first of the five registered together
by the kickoff PR (#1917). It goes through `scripts/msh/` only. **Its stat
blocks are MHSP1's** (Jeff Grubb, the same year): rank words and no numbers,
the same labels, and the same one-line `F A S E R I P` grid. So
[mhsp1.md](mhsp1.md) is the nearest worked example. **Its layout is not
MHSP1's:** the full blocks are in three places, two of them the inside panels
of a loose cover, and a third of the characters are statted only by a
one-line grid inside the adventure's chapters, as ME1's opponents are.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places, even the one with a block of its own (the
Blackbird, below).

## The scan

- 22 PDF pages, a pure scan, already cached by the kickoff PR into the main
  checkout's `.cache/msh/books/mh1/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, written 2026-10-21).
- The print is clean. Tesseract reads the body text, the full blocks' label
  lines and the one-line grids' code rows well. It does not read the
  chapter titles (outline display lettering), the cover, or the maps.

**The PDF is a booklet inside a loose folding cover, plus a map sheet.**
Recorded as `parts` in the registry:

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2 | Inside front cover: the cards of Colossus, Nightcrawler and Rogue | - |
| 3-18 | Adventure Book | 1-16 |
| 19 | Inside back cover: the cards of Storm, Ariel, Lockheed and the Blackbird | - |
| 20 | Back cover | - |
| 21-22 | Map: the X-Men's mansion by floors, and the outdoor map | - |

The introduction (printed 1) says the X-Men's cards are on the inside of the
folding cover, all but Wolverine's, which is in the boxed game and summarised
in Chapter One. That is how PDF 2 and 19 are identified as the cover's two
inside panels: they sit outside the booklet's numbering, either side of it.

## Offset

`scripts/msh/survey.py`'s folio reader finds 9 folios:
- **7 vote printed = PDF - 2**: PDF 6 and 12-17.
- 2 are numbers in the text: a Karma award at the foot of a column on PDF 8,
  and the publisher's box number on the back cover (PDF 20).

Every folio from 2 to 16 was also read on the page images of PDF 4-18.
Printed 1 (PDF 3) prints none. Chapter Four (printed 8) refers the reader to
page 14 for the normal Sentinel, and the Sentinels' block is on PDF 16, which
agrees.

**One offset would do for the booklet, but not for the cards,** which have
no page number. A card on the inside cover has to cite the panel, as ME1's
Flowchart and MHSP1's Reference Summary do. So the entry carries `parts`, and
no `offset`, with each inside panel as a part of its own and `offset` null.

## The book's own authority lists

- **No Contents and no index.** Nothing in the book lists its characters.
- **The introduction** names the six active X-Men (Storm, Ariel, Colossus,
  Nightcrawler, Wolverine and Rogue) and Magneto, and says where their cards
  are (above).
- **The banners**, each read on its page image, are the registry's
  `sections`: printed 1 (no banner, only the title art; the registry calls it
  Introduction), then Chapter One *Be It Ever So Deadly...* (2), Two *Whatever
  Happened to Mentallo?* (4), Three *Interlude* (6), Four *Sentinels!* (7),
  Five *Back in the USSR* (9), Six *Land Down Under* (10), Seven *Magneto's
  Defeat* (11), the Epilog (13), and Map C: Magneto's Lair (16). Each chapter
  is set as Campaign, Battle and Aftermath, and Chapter Seven has two
  Campaigns and two Battles. Chapters One, Two and Four to Seven each have a
  Karma awards table (Tables 1, 2, 4, 5, 6 and 7); Table 3 is the Special
  Sentinels roll.
- So **the coverage checklist is this survey's own list** of blocks (below),
  read off the page images. The registry's `opponents` carries the one-line
  grids' names, and `character_ranges` the cards' pages in the booklet.

## What an entry looks like

**A full block** is MHSP1's Roster Booklet block, line for line:

```
COLOSSUS(tm)                   bold capitals with a trademark sign (Tesseract
                               reads the sign as the sign, not U+FFFD)
Peter Nikolaievitch Rasputin, student      identity line
Fighting:    GOOD              seven rows: label, then a rank NAME
Strength:    EXCELLENT [MONSTROUS]         bracket = the other form's rank
...
Health:      60 [145]          Health, Karma, Resources, Popularity
Karma:       32
Resources:   POOR
Popularity:  10
Powers:                        then "CAPITALISED NAME." run-ins (a period),
                               then Talents: and Background:
```

Two headers wrap onto a second line (LOCKHEED / THE DRAGON, CRIMSON / DYNAMO,
SOVIET / SUPER-TROOPERS). The labels and run-ins are spelled the same in
every block: `Powers:`, `Talents:`, `Background:`, and `Resources:` (never
the singular).

**Where they are set:**
- **The inside cover panels (PDF 2 and 19):** three columns, each card a
  portrait over its name, block and text. No heavy rule. On PDF 19 the third
  column holds two cards, Lockheed's and the Blackbird's.
- **Printed 13 (PDF 15):** the Epilog runs across the top of the page, and
  Magneto's block sits below it in two columns beside his portrait. No rule.
- **Printed 14-15 (PDF 16-17):** two entries a page above and below a heavy
  rule, the portrait on the side that alternates, as MHSP1's Roster Booklet.
  Printed 15's lower half has two blocks (Crimson Dynamo, Soviet
  Super-Troopers) under one group illustration.

**A one-line grid** is a name in bold capitals (ending in a colon, except
Augie Hickman's, which is plain capitals with none), the seven letters, a row
of two-letter codes under them, `Health:`, and a `Powers:` or `Special:` line
of power names. The Chapter Seven creatures print a short description after
the name on the same line instead (`GIANT: a large humanoid ...`). They sit in
the chapter's prose columns, between paragraphs or after a Karma table.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `Reason: ?`, and no Karma, Resources or Popularity at all | Lockheed, inside back cover |
| `Karma: -`, `Resources: -`, `Popularity: -` | Sentinels (printed 14); Resources and Popularity only, Soviet Super-Troopers (15) |
| `Resources: (supplied by USSR)` | Crimson Dynamo (15) |
| bracketed alternate ranks and Health: `EXCELLENT [MONSTROUS]`, `80 [175]` | Colossus (cover), Crimson Dynamo and Soviet Super-Troopers (15) |
| `-` for Intuition and Psyche in a one-line grid | four of the five False robots (12); False Magneto prints I `Gd` and P `Pr` |
| a one-line grid with no Health line | Fluffy (2), Augie Hickman (7) |
| `Control:`, `Speed:`, `Body:` | the Blackbird (inside back cover), a vehicle |

**Rank spellings.** The full blocks spell ranks in capitals (FEEBLE to
UNEARTHLY; nothing higher appears), and the one-line grids use MA1's
two-letter codes, `Fb` for Feeble. All of them are in `rank_aliases`; `Un` is
not, because no grid prints it. Tesseract reads `In` as `tn` once (the Giant),
`Fb` as `Fo` in three False robots' rows, and puts a stray mark after a code
(`In'`, `Fb_`, `Fb-`). The page images settle every one, and so does the
arithmetic below.

## Stat blocks: 12 full, 13 one-line

**Full blocks (12 characters, and 1 vehicle):**

| card | where | Health | Karma |
|---|---|---|---|
| Colossus | inside front cover | 60 [145] | 32 |
| Nightcrawler | inside front cover | 106 | 50 |
| Rogue | inside front cover | 90 | 18 |
| Magneto | printed 13 | 125 | 100 |
| Professor X | printed 14 | 44 | 165 |
| Sentinels | printed 14 | 190 | - |
| Mentallo | printed 15 | 52 | 90 |
| Crimson Dynamo | printed 15 | 80 [175] | 36 |
| Soviet Super-Troopers | printed 15 | 50 [90] | 18 |
| Storm | inside back cover | 106 | 36 |
| Ariel | inside back cover | 40 | 46 |
| Lockheed the Dragon | inside back cover | 48 | (none) |
| *Lockheed RS-150 Blackbird* | inside back cover | a vehicle: Control, Speed, Body; not imported | |

**One-line grids (13):**

| name | printed | chapter | Health |
|---|---|---|---|
| Fluffy | 2 | One | none printed; the prose gives 80 |
| Wolverine | 3 | One | 110 |
| Fixer | 3 | One | 24 |
| Robot Wolverine | 5 | Two | 84 |
| Robot Mentallo | 5 | Two | 16 |
| Augie Hickman | 7 | Four | none printed |
| Giant | 11 | Seven | 104 |
| Flyer | 11 | Seven | 44 |
| False Blob | 12 | Seven | 94 |
| False Scarlet Witch | 12 | Seven | 100 |
| False Quicksilver | 12 | Seven | 80 |
| False Toad | 12 | Seven | 80 |
| False Magneto | 12 | Seven | 76 |

**The book checks itself, on each rank's standard number** (`ranks.json`
`standard`, as MHSP1's blocks are checked):

| measure | count |
|---|---|
| full blocks, Health = F+A+S+E | **12 of 12** |
| bracketed forms, Health checked too | **3 of 3** (Colossus 145, Crimson Dynamo 175, Super-Troopers 90) |
| full blocks printing a Karma number, Karma = R+I+P | **10 of 10** (Sentinels print a dash, Lockheed none) |
| one-line grids printing a Health, Health = F+A+S+E | **11 of 11** |
| one-line grids printing no Health | 2: Fluffy, whose prose gives 80 (= 4 x Excellent, so it agrees), and Augie Hickman (Typical, Poor, Typical, Good: 26 if derived) |
| one-line grids printing a Karma | 0 |

Every block was read on its page image as well as in the OCR. **No block's
numbers are misprinted.** One misprint in the prose was found on the way: the
Robot Wolverine's claws are given as Remarkable damage "(20 points)" (printed
5), and Remarkable is 30. It is in a `Special:` line, not a block, so it is
for the data row to record as printed or correct (below).

**Lockheed's `?` Reason** is the same mark MHSP1 prints for him, but here the
block prints no Karma, so nothing says what the `?` counts as. MHSP1's override
played it as 0 (Shift 0) because its printed Karma required that.

## Which reader fits

None of the four, as it stands. Measured against each:

- **`roster.py` (MA1)** reads numbered grids and keys on `Health =`. This book
  prints no ability numbers, and `Health:`. `survey.py`, which uses the same
  anchor, finds **0** blocks here.
- **`codegrids.py` (MA4)** reads rows of `F GD (10)`: code then number. Not
  printed here.
- **`gridbooks.py` (ME1)** reads MA1's numbered grids through
  `roster.read_entries()`. Its grid reader does not fit. **Its registry shape
  does:** characters in more than one range (`character_ranges`) plus
  opponents statted inside the chapters (`opponents`), so this entry uses those
  two fields, in ME1's form.
- **`booklet.py` (MHSP1)** reads exactly this block: label rows with rank
  words and bracketed alternates, the four secondary labels, `NAME.` power
  run-ins, the trademark header, the heavy rule (printed 14-15), and the
  one-line grid read code by code under the letters. **It is the nearest.**
  What it does not do, read in its code (`parse`, `one_line_grid`,
  `summary_entries`):
  1. `parse` reads one range in one part (`character_part`,
     `character_pages`). Here the full blocks are in three parts, two of them
     unpaged panels.
  2. `one_line_grid` takes the line above as the grid's name only when it does
     not end in a colon. Here every name but Augie Hickman's ends in one, and
     the Chapter Seven names run into a description on the same line.
  3. The one-line grids here are opponents in the chapters' prose, with no
     entry header above them, where `parse` expects every block inside an
     entry it has started.
  4. It holds the entries to a `reference_summary`. This book has none.

So the parser row is the second PR, as the skill sets out for a new layout.
The recommendation is to teach `booklet.py` these four things behind the
registry (a `layout` of its own, or `roster-booklet` reading
`character_ranges` and `opponents` when present), not to bend MA1's path, and
to prove MHSP1's `roster.json`, `book-text.sql`, `extras.json`,
`extras-text.sql` and `npcs.json` rows byte-identical before and after. This
survey sets no `layout`: that is the parser's choice.

## Entry kinds

1. **A character with a full block:** 12, listed above. The Sentinels and the
   Soviet Super-Troopers are types (one block for many), as MA1's Sentinels
   are.
2. **An opponent with a one-line grid:** 13, listed above. A one-line grid has
   no identity line, Karma, Resources or Popularity; its powers are a list of
   names on one line, sometimes followed by a paragraph.
3. **Forms, in brackets inside one block:** Colossus's armoured form, the
   Crimson Dynamo's armour, the Super-Troopers' armour.
4. **Variants in prose only, with no block:**
   - the six Special Sentinels (Table 3, printed 8: types N, C, W, A, R and S,
     each built against one X-Man), which raise a rank or add a weapon over
     the normal Sentinel;
   - the three Specials (printed 11: the shooter, the reaper and the
     phantasm), each a Flyer with one mutation;
   - the robots' upped tests in Chapter One's second Battle.
5. **Hazards with a partial stat line, not characters:** Chapter One's Danger
   Room tests (the hoops, the tentacles, and the holographic ghosts with a
   Health of 20). The recommendation is to leave them in the adventure's text,
   which is not imported.
6. **A vehicle:** the Blackbird, with Control, Speed and Body. Out of scope by
   Nate's ruling (no items or places now).

## Names the Codex already has

Nine MH1 characters share a name with a card from another book. By the rule
#1520 pinned (Nate, 2026-09-28), each is a card of its own, with a `-mh1` id:

- in MA1 and MHSP1: Colossus, Nightcrawler, Rogue, Storm, Magneto,
  Professor X and Wolverine; Lockheed is "Lockheed the Dragon" in MA1 and
  "Lockheed" in MHSP1;
- **Ariel is a different person.** MA1's Ariel is a Fallen Angel. MH1's is
  Kitty Pryde (her identity line names her), so the two cards are named for
  who each is (Nate, 2026-10-21; registry `card_names`): **Ariel (Kitty
  Pryde)**, id `ariel-kitty-pryde-mh1`, and MA1's **Ariel (Fallen Angel)**,
  id `ariel-fallen-angel`. The parenthesis is part of the name, not a
  version label. The ids were `ariel-mh1` and `ariel` before.
- MA1 has the Blob, Quicksilver, the Scarlet Witch and the Toad; MH1's are
  robots named "False ..." and keep that name.
- MA1 has five Sentinel cards (Mark I to V, X-, Alpha, Omega); MH1's is the
  plain "Sentinels".

## Quote marks

**The book prints no single quotes of its own.** Measured on the OCR of all 22
pages: 66 double marks, and 6 opening single marks. Three of the 6 are on
PDF 6 (printed 4) and were read on its image: two are superscript footnote
numbers in Chapter Two, and one is a double quote Tesseract read as a single
and a double together. The other three (a nickname in the credits, a dialect
word in Chapter Four, a single letter in Table 5) show the same pairing in
the OCR, a single mark beside a double, around a printed quotation. So, as
with MHSP1, a single mark in the text is a misread, and
the data row can normalize it. Apostrophes after a plural (`Colossus'`) are
real and occur 10 times.

## Decisions this survey left open

All six were decided by Nate on 2026-10-21, each as recommended below, and
the import carries them: the robots' dashes play as Shift 0 with Karma unset,
as Lockheed's `?` does.

1. **What `team` means.** There are no team sections. The recommendation:
   the eight X-Men (the six active, Lockheed and Professor X) as **X-Men**,
   which shares MA1's X-Men filter group, and is the same team; everything
   else under the book's title, **MH1 The Breeder Bombs**, as the skill says
   for a book with no team sections. Not written to the registry, because the
   form `teams` takes depends on the reader.
2. **How a card on a cover panel cites its page.** The recommendation is the
   panel's name with no page ("MH1 Inside front cover"), as MHSP1 cites its
   Reference Summary. `character_ranges` lists only the booklet's printed
   13-15 for that reason: the two panels have no printed page, and the
   parser row decides how a range names them.
3. **Opponents with no printed Health** (Fluffy, Augie Hickman): derive the
   Health from the ranks (80 and 26) as MHSP1 derives every number, flagged
   rank-only, or leave it blank? Fluffy's prose agrees with 80.
4. **Lockheed's `?` Reason, with no Karma to settle it**, and the dashes
   four False robots print for Intuition and Psyche (False Magneto prints
   both): play them as Shift 0, or leave Karma unset? The recommendation is
   to leave Karma unset where the book prints none, and to play the `?` as
   Shift 0, as MHSP1's override did. Applied for Lockheed in
   `scripts/msh/mh1-overrides.json` (2026-10-21), on Nate's 2026-09-28 ruling
   for the same printed value in MHSP1. The robots' dashes were ruled the
   same day, as the paragraph above says: Shift 0, Karma unset.
5. **The Robot Wolverine's "Remarkable (20 points)"**: an override with
   printed and corrected (30), or `as_printed`? The recommendation is the
   override, read off printed 5.
6. **The variants in prose** (the six Special Sentinels, the three Specials):
   leave them in their parent card's text, as MHSP1 left the Hulk's surge, or
   give them cards? The recommendation is the text only.

## The next PRs

Both done: the parser is #1923 (`cover-panels`), the data is this file's Rows
line.

1. **Parser:** `booklet.py` (or a sibling) reads `character_ranges` across
   parts, the two cover panels, and `opponents`; names a one-line grid from a
   `NAME:` line; and holds the entries to the list above in place of a
   reference summary. Expected: 12 full blocks and 13 one-line grids, every
   Health that is printed passing, and MHSP1's outputs byte-identical.
2. **Data:** `npcs.py mh1`, the rows of `msh_book_text`, this file's Rows line
   and `node scripts/sourcebooks.mjs`.

## How to reproduce

```bash
python scripts/msh/survey.py mh1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 60-150
dpi into the scratchpad, never into the repo.
