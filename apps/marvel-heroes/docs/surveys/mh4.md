# Survey: MH4 Lone Wolves (TSR6859)

Marvel Super Heroes adventure module, Bruce Nesmith, 1984. Registry entry:
`scripts/msh/books.json` -> `mh4`. Measured 2026-10-23.

**Rows citing this book:** 66 `msh_book_text` rows over 15 character entries
in production (`DB_MARVEL`, read back 2026-10-23).

This is the fourth module of the series MH1, MH2 and MH3 come from, and it
goes through `scripts/msh/` only. **It is laid out as the three before it
are**: [mh3.md](mh3.md) is the nearest worked example, and `cover-panels`
(`scripts/msh/coverpanels.py`) the nearest reader. Full blocks in rank words
(no numbers) on the two inside panels of a loose cover and on two booklet
pages, and one-line `F A S E R I P` grids inside the chapters. **What differs
from MH3** is listed under *Which reader fits*; the largest difference is a
full block set inside a chapter's prose (the Kingpin's, printed 5).

Characters only, as the five books of 2026-10-21 were (Nate's ruling that day
covered those five; this survey assumes it holds for a sixth, and says so
under *Decisions*): the adventure is not imported, and neither are items or
places (the Fisk Building, Kraven's jungle lair, Modok's warehouse and the
street map).

## The scan

- 21 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0 text-layer
  characters over 20 samples), cached 2026-10-23 into the main checkout's
  `.cache/msh/books/mh4/` (`manifest.json`: 300 dpi, `--psm 3`, Tesseract
  5.4.0).
- The print is clean. Tesseract reads the body text, the cards' label lines
  and the one-line grids' code rows well: every number below was read in the
  OCR and again on the page image, and they agree. It does not read the
  chapter titles (display lettering), the cover, the map, or the PROOF OF
  PURCHASE stamp at the top of printed 16's second column (the TSV holds no
  word of it). Three cards' `Strength:` row reads with a mark before the rank
  word (a copyright-sign mark before `EXCELLENT` on Sabertooth's and Vermin's, a section-sign mark before `EXCELLENT` on the
  Taskmaster's; Vermin's `Fighting:` reads `| REMARKABLE`), which the reader
  already drops. **One header splits at its trademark sign**: TASKMASTER on
  printed 16 reads as `TASKMASTE` and `R` with the sign, two words 150 px apart (x 910 and
  1365, y 1095, 300 dpi), so the trial parse below names him `TASKMASTE R`.
  The grids' S and I letters read as `Ss`, `iS)` or `|`, as in MH3.
- **PDF 21 is the map sheet as one PDF page** (2346 x 1497 pt against the
  booklet's 594 x 767): four panels, the Fisk Building's floors, the jungle
  lair, Modok's warehouse on two levels and the street map. Its OCR is map
  lettering, not a character.

**The PDF is a booklet inside a loose folding cover, plus a map sheet**, the
same pieces as MH1-3 (one map page here, not two). Recorded as `parts` in the
registry:

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2 | Inside front cover: the cards of Daredevil and Power Man | - |
| 3-18 | Adventure Book | 1-16 |
| 19 | Inside back cover: the cards of Iron Fist and Black Widow | - |
| 20 | Back cover | - |
| 21 | Map | - |

As in MH1-3, the introduction does not say where the heroes' cards are. PDF 2
and 19 are identified as the cover's inside panels by what is on them (four
cards, no folio) and by where they sit, outside the booklet's numbering on
either side of it. The back cover describes the module as a 16-page book and
a large full-colour map, which agrees.

## Offset

`scripts/msh/survey.py`'s folio reader votes **printed = PDF - 2 on 7 pages**
(PDF 12-18). PDF 3-11 cast no vote, and the one other vote, PDF 21 (k = 17),
is the map sheet.

Folios 1-16 were read on the page images of PDF 3-18, each at the foot of
its page; printed 1 prints its folio under the credits and the copyright
line. The text agrees: printed 3 sends the reader to Chapter 2 for Kraven,
and Chapter 2's banner is on printed 4.

As for MH1-3, one offset would do for the booklet but not for the cards on
the panels, which have no page number, so the entry carries `parts` and no
`offset`, each inside panel a part of its own with `offset` null.

## The book's own authority lists

- **No Contents and no index.** Nothing in the book lists its characters.
- **The introduction** (printed 1) names the four heroes (Daredevil, Black
  Widow, Power Man and Iron Fist) and the villains' chain of command:
  Kraven the Hunter over Sabretooth (spelt so there; the card spells
  SABERTOOTH) and Vermin, and Modok over the Taskmaster, who trains the
  cyber-sergeants and minions. It does not name the Kingpin, the Punisher or
  Reggie.
- **The back cover** names the same four heroes.
- **The banners**, each read on its page image, are the registry's
  `sections`: printed 1 (the title art and the heading INTRODUCTION; the
  registry calls it Introduction), Chapter 1 *I Smell a Rat* (2), Chapter 2
  *Jungle Stalk!* (4), Chapter 3 *Lion's Den* (6), Chapter 4 *King of the
  Jungle* (8), Chapter 5 *A Hard Taskmaster* (10), Chapter 6 *Cornered Prey*
  (12) and Chapter 7 *It's About Time...* (14). Each is a small `Chapter N`
  line over a title in display lettering; Tesseract reads the chapter lines
  (with a colon, a period or nothing after the number) and none of the
  titles. Each chapter is set as Campaign, Battle and Aftermath subsections
  in the order the chapter needs them: Chapters 1, 2 and 4 open on Campaign
  and print a second Campaign after Battle; Chapters 3, 5 and 6 open on
  Battle; Chapter 5 has no Campaign. Every chapter ends on a Karma table,
  numbered 2-5 and 7-9: Table 1 is Chapter 1's Random Crowd Actions and
  Table 6 is Chapter 5's Danger Room Effects.
- So **the coverage checklist is this survey's own list** of blocks (below),
  read off the page images. The registry carries it in `cover-panels`' own
  fields: `cards` for the full blocks, `opponents` for the one-line grids,
  `panels` and `character_ranges` for where the cards are.

## What an entry looks like

**A full block** is MH3's, line for line: a bold capital header with a
trademark sign, an identity line (two lines on every card here: the name and
role, then the origin, `Altered Human`, `hi-tech wonder` or `origin
unknown`), the seven `Fighting: GOOD` rows, `Health:`, `Karma:`, `Resources:`
and `Popularity:`, then `Powers:` with run-in powers, `Talents:` and
`Background:`. What is new:

- **Every card prints `Important People:`** between Talents and Background,
  a label MH1-3 never print, and **two print `Equipment:`** (the Taskmaster's,
  a paragraph; the Punisher's, four run-ins of its own, `GUNS.`, `GRENADES.`,
  `KNIFE.` and `VAN.`). The Punisher prints `Powers: none.` and **Iron Fist's
  card prints no `Talents:` at all** (Powers, Important People, Background).
  `section_labels` lists all five labels the book prints; the reader knows
  three of them (*Which reader fits*).
- **One header wraps** onto a second line (KRAVEN / THE HUNTER).
- **The Kingpin's block is set inside Chapter 2's Campaign** (printed 5,
  second column), headed by a **title-case name line**, `The Kingpin`, with
  his two identity lines under it; the `Health:` row follows `Psyche:` with no
  gap, and the gap comes before `Karma:`. It prints five run-in powers,
  Important People and Background, and the BATTLE banner follows it.
- **Run-in powers end in a period or a colon**, both on the same card
  (Daredevil's `SENSES.` and `BILLY CLUB:`; Black Widow's `WRIST BRACELETS.`
  and `BELT:`). One name holds a slash (`ANIMAL COMMUNICATION/CONTROL.`,
  Vermin).

**Where they are set:** around the portraits, as MH3's are. On the inside
front cover Daredevil's card fills the first column under his portrait and
goes on at the top of the second (`BILLY CLUB:`, x 926, y 147, then Talents,
Important People and Background), above Power Man's second portrait; Power
Man's card is the third column. On the inside back cover Iron Fist's card
does the same (`CHI:` at x 918, y 142 of the second column), and Black
Widow's starts under a portrait in the second column and goes on in the
third, under hers. Printed 15 and 16 set three cards each, one to a column,
each header under its portrait at its own height. Printed 16 also prints the
product code at the foot of its first column (`6859XXX1501`, x 154-392,
y 3085-3114) and the PROOF OF PURCHASE stamp at the top of its second, of
which only the code is in the TSV.

**A one-line grid** is a name in **title case** on the line above it (MH2's
form), sometimes with a count in front (`1 White Tiger`, `2 Panthers`,
`1 Leopard`, and `2 Minions` twice); the seven letters; a row of two-letter
codes; and one `Health:` line. **Two grids print no name line of their own**:
Reggie's (printed 3) follows the paragraph that opens `REGGIE.`, a run-in in
capitals, and the cyber-sergeants' (printed 10) sits inside the room
paragraph headed `3) CYBER-SERGEANTS QUARTERS.` No grid prints a `Powers:`
line; four print a second value on the Health line.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `Health: 60   Special: Claws` on one line | the White Tiger, the Panthers, the Leopard (printed 6) |
| `Health: 46   Special: Martial Arts` on one line | the Flying Tigers (printed 9) |
| `Health: 32   Karma: 14` on one line | Reggie (printed 3) |
| a one-line grid with no Karma | the eight other grids |
| `Powers: none.` | the Punisher (printed 16) |
| `Talents: none.` | Modok, Sabertooth (15), Vermin (16) |
| `Popularity: 0` | Vermin (16) |
| a count before the name line | the White Tiger, the Panthers, the Leopard (6), the Minions (12, 13) |
| no name line | Reggie (3), the cyber-sergeants (10) |

**Rank spellings.** The full blocks spell ranks in capitals, FEEBLE to
MONSTROUS (Daredevil's Intuition is the one Monstrous, and no card prints
Unearthly), and the grids use five codes, Fb, Pr, Ty, Gd and Ex. The
registry's `rank_aliases` lists those, and nothing the book does not print.

## Stat blocks: 11 full and 9 one-line

**Full blocks (11):**

| card | where | Health | Karma |
|---|---|---|---|
| Daredevil | inside front cover | 110 | 91 |
| Power Man | inside front cover | 130 | 36 |
| The Kingpin | printed 5, Chapter 2 Campaign | 100 | 120 |
| Kraven the Hunter | printed 15 | 140 | 66 |
| Modok | printed 15 | 30 | 110 |
| Sabertooth | printed 15 | 120 | 22 |
| Vermin | printed 16 | 120 | 12 |
| Taskmaster | printed 16 | 150 | 56 |
| Punisher | printed 16 | 100 | 32 |
| Iron Fist | inside back cover | 100 | 100 |
| Black Widow | inside back cover | 100 | 60 |

**One-line grids (9):**

| name as printed | printed | where | codes | Health | Karma |
|---|---|---|---|---|---|
| (none; the `REGGIE.` paragraph) | 3 | Chapter 1, Campaign | Gd Gd Ty Ty Pr Pr Ty | 32 | 14 |
| 1 White Tiger | 6 | Chapter 3, Battle | Ex Gd Gd Ex Fb Ex Fb | 60 | - |
| 2 Panthers | 6 | Chapter 3, Battle | Gd Ex Ty Gd Fb Ex Fb | 46 | - |
| 1 Leopard | 6 | Chapter 3, Battle | Ex Ex Ty Gd Fb Gd Fb | 56 | - |
| Flying Tigers | 9 | Chapter 4, Battle | Ex Gd Ty Gd Pr Ty Ty | 46 | - |
| Modok's Minions | 10 | Chapter 5, Battle | Gd Ty Ty Gd Pr Ty Pr | 32 | - |
| (none; `3) CYBER-SERGEANTS QUARTERS.`) | 10 | Chapter 5, Battle | Ex Ty Ex Ex Fb Fb Pr | 66 | - |
| 2 Minions | 12 | Chapter 6, Battle | Gd Ty Ty Gd Pr Ty Pr | 32 | - |
| 2 Minions | 13 | Chapter 6, Campaign | Gd Ty Ty Gd Pr Ty Pr | 32 | - |

**The two `2 Minions` grids repeat Modok's Minions' grid** code for code,
with the same Health, each under its own room's text (rifles on 12, blaster
pistols on 13). They are the same minions in two more rooms, not two more
kinds (decision 6).

**The book checks itself, on each rank's standard number** (`ranks.json`
`standard`, as MH1-3's blocks are checked):

| measure | count |
|---|---|
| full blocks, Health = F+A+S+E | **10 of 11**: Modok prints 30, and Fb + Fb + Pr + Ex is 2 + 2 + 4 + 20 = 28 |
| full blocks, Karma = R+I+P | **10 of 11**: the Kingpin prints 120, and Gd + Ex + Gd is 10 + 20 + 10 = 40 |
| one-line grids, Health = F+A+S+E | **9 of 9** |
| one-line grids printing a Karma, Karma = R+I+P | **1 of 1** (Reggie's 14 = Pr 4 + Pr 4 + Ty 6) |
| one-line grids printing no Karma | 8 |

Every block was read on its page image as well as in the OCR.

**Two misprints, by the rule the other books set.** Each failing value is
printed unambiguously, and the page gives no reason for it (not a machine's
Karma 0, not an android's fixed Health). MA4's and MHSP2's Karma slips of
this shape are `misprint` overrides, `printed` and `corrected` both kept, the
Codex showing the page and the GM tools playing the sum. Modok's Health
(30, corrected 28) and the Kingpin's Karma (120, corrected 40) are the data
row's two overrides, unless Nate rules otherwise (decision 2); the Kingpin's
is the larger gap by far, and a Karma pool can be raised in play, so the
alternative is stated there.

## Which reader fits

**`cover-panels` (`scripts/msh/coverpanels.py`), with things taught to it.**
Measured, not argued: a scratch copy of `scripts/msh/` at `origin/main`
(`45f92d61`) with this entry plus `"layout": "cover-panels"` and
`"opponent_names": "title"`, run on a copy of the cache under its own
`WORKSHOP_MSH_CACHE`. The stock reader exits 1 at once:
`a one-line grid with no name above it, Adventure Book p.3` (Reggie's grid),
and with that page left out, the same on printed 6 (`1 White Tiger` is not a
title-case name line to `TITLE_NAME`, because of the count).

With two trial-only patches to the scratch copy, a count stripped before the
name match and a nameless grid given a placeholder name, `roster.py mh4`
reads the rest and exits 1 on the checklist:

- **19 entries, 19 blocks; 18 pass, 1 fails**: Modok's Health, the misprint
  above. The Kingpin is not among them (next).
- **`CHECKLIST NAME IN 0 ENTRIES: The Kingpin`.** His block is on printed 5,
  outside `character_ranges`, and `opponents` reads one-line grids only; no
  reader of this series has read a full block inside a chapter's prose.
- **`CHECKLIST NAME IN 0 ENTRIES: Taskmaster`**, found as `TASKMASTE R`: the
  trademark sign read as a word of its own.
- **Powers missed:** 25 found of the 27 the ten cards print. The two lost
  are the run-in at the top of a card's second column, Daredevil's `BILLY
  CLUB:` and Iron Fist's `CHI:`, each the first line of the column.
- **`Important People:` is read as text**, into Talents on nine cards and,
  on Iron Fist's, which prints no Talents, into his last power's text;
  **`Equipment:` the same** (the Punisher's four run-ins land in his Talents,
  1,193 characters of it, and `POWERS: TEXT AND NO RUN-IN POWER: PUNISHER`
  is reported for his `Powers: none.`). `booklet.SECTION_LINE` knows Powers,
  Talents and Background.
- **The grids:** the `Special:` value stays on the Health line (`HEALTH '60
  Special: Claws'` four times); the name line of the next grid is read as the
  previous entry's prose (`2 Panthers` is the White Tiger's text); the two
  placeholder names stand for Reggie and the cyber-sergeants; and the two
  Minions grids come out as two entries named Minions, which `npcs.py` would
  give one id.
- The product code at the foot of printed 16 and the stamp above the
  Taskmaster's portrait reached no entry: the code is below the last card's
  text and the stamp is not in the TSV. No `drop_corner` is needed, as far as
  the trial shows.

The other readers do not fit, for MH1-3's reasons (mh2.md, *Which reader
fits*): `roster.py` (MA1) and `codegrids.py` (MA4) read printed ability
numbers, which this book does not print (`survey.py` finds 0 blocks on the
`Health =` anchor); `gridbooks.py` (ME1) reads MA1's numbered grids;
`booklet.py` (MHSP1) reads one range in one part.

So the parser row is next, as the skill sets out. What it needs, all in
`coverpanels.py` behind the registry, with MH1's, MH2's and MH3's
`roster.json`, `book-text.sql` and `npcs.json` rows proved byte-identical
before and after:

1. **A full block inside a chapter's prose** (the Kingpin, printed 5): found
   by its title-case name line and read as a card, its Health row directly
   under Psyche. A registry field naming the block and its page.
2. **`Important People:` and `Equipment:` as sections**, with Equipment's
   run-ins (the Punisher's) read as a card's powers are, and a card with no
   `Talents:` (Iron Fist).
3. **A run-in power at the top of a card's second column** (`BILLY CLUB:`,
   `CHI:`).
4. **The trademark sign read as a word** after TASKMASTER.
5. **Grids named by the registry** where no name line exists (Reggie, the
   cyber-sergeants); **a count before a title-case name**, and the name
   without it; the next grid's name line is not the previous entry's prose.
6. **`Special:` on the Health line**: the Health as a number, and the
   Special value kept (where it goes is decision 7).
7. **Two Minions grids that repeat a third** (decision 6).

This survey sets no `layout`, as MH1-3's did not: that is the parser's
choice. It does write `panels`, `cards` and `opponents`, which `cover-panels`
reads and which are measurements of the book; `opponents` names each grid as
the page prints it, count and all, and the two nameless ones by what the
text calls them.

## Entry kinds

1. **A character with a full block:** 10, the ten cards. All single
   characters.
2. **A character with a full block inside a chapter:** the Kingpin.
3. **A person with a one-line grid:** Reggie, with a Karma.
4. **Animals with one-line grids:** the White Tiger, the Panthers and the
   Leopard, Kraven's cats, each with `Special: Claws`.
5. **A gang with a one-line grid:** the Flying Tigers (`Special: Martial
   Arts`).
6. **Types with one-line grids:** Modok's Minions, the cyber-sergeants, and
   the Minions twice more.
7. **Variants in prose only, with no block:** the rioters of Chapter 1 (all
   Typical, a Health of 24, no Karma, stated in a sentence on printed 3),
   the Kingpin's thugs and goons (printed 5, the same way), Bob and the
   Flying Tigers' truck crew (printed 9), and the cyber-sergeants' four
   named weapons (Laser, Blade, Ripper, Vibro; printed 10), which are the
   sergeants' arms, not characters.
8. **Items and places:** the Fisk Building, the Hawk Animal Research
   Laboratories (Kraven's lair) and its jungle, Modok's warehouse and its
   rooms, the Punisher's van and guns, and the street map. Out of scope by
   the ruling on items and places.

## Names the Codex already has

Eight MH4 cards share a name, or a person, with a card from another book.
By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own, with
a `-mh4` id:

- **in MHSP2:** Daredevil, Power Man, Iron Fist, the Kingpin and Kraven
  (MHSP2 prints `Kraven`; this book's card is `KRAVEN THE HUNTER`);
- **in MA4:** Power Man again, and the Punisher (MA4's card is `Punisher I`);
- **in MA1:** Sabertooth and the Taskmaster, spelt as this book spells them.

Black Widow, Modok, Vermin, Reggie, the three cats, the Flying Tigers, Modok's
Minions and the cyber-sergeants are new to the Codex. MA1's `Cybernetic
Agents` are not the cyber-sergeants.

## Quote marks

**On the cards every single mark is an apostrophe inside a word** (read on
the page images and listed from the OCR: `Daredevil's`, `man's`,
`Bernstein's`, `Modok's`, `K'un-Lun` three times, `monks'`, `Widow's`,
`Fist's`, `Daniel's`), and no card prints a single-quoted phrase. The
double-quoted ones are `"Foggy"` on Daredevil's card and `"widow's bite"`
and `"widow's line"` on Black Widow's, each holding an apostrophe. The
Kingpin's block on printed 5 prints none of either. Measured on the OCR of
all 21 pages: the chapters' prose and boxed speeches print apostrophes of
the same kind and a few single marks Tesseract reads for double ones; none
of that is imported. So, as in MH1 and MHSP1, a single mark that is not an
apostrophe is a misread, and the data row checks each mark on a card against
the page image (`npcs.pair_quotes`), with a lost one a `text` override.

## Decisions this survey leaves open

For Nate. Each has a recommendation. **The data PR applied all nine as
recommended, unanswered**: #1954 and #1955 merged without a ruling on them.

1. **What `team` means.** There are no team sections, and the four heroes are
   lone wolves by the book's own account. The recommendation: every card
   under the book's title, **MH4 Lone Wolves**, as the rule for a book with no
   team sections says, and no `teams` in the registry. The alternative is
   Power Man and Iron Fist under a new **Heroes for Hire** group (their
   agency, named on both cards), which no other book's cards would share.
2. **The two misprints.** Modok's Health 30 (ranks give 28) and the Kingpin's
   Karma 120 (ranks give 40): `misprint` overrides with `printed` and
   `corrected`, as MA4's and MHSP2's Karma slips are (recommended), or
   `as_printed` for the Kingpin's, if 120 is read as the Karma he has
   accumulated rather than a slip.
3. **Characters only** for this sixth book, as for the five of 2026-10-21
   (recommended: no items, no places, no adventure), or Kraven's lair,
   Modok's warehouse and the Punisher's arsenal as items and places.
4. **The Kingpin**: a card, read from his block in Chapter 2 (recommended),
   or left in the chapter's text.
5. **Kraven's cats** (the White Tiger, the Panthers, the Leopard): cards under
   the book's title, named without the counts (recommended; they are statted
   opponents the GM fields), or left in the text.
6. **The Minions**: one card, Modok's Minions, from printed 10, with the two
   `2 Minions` grids checked against it and not imported (recommended), or
   three cards.
7. **`Special: Claws` and `Special: Martial Arts`**: kept as the grid's one
   power, named as printed (recommended), or dropped.
8. **Karma on the eight grids that print none**: left unset, as MH2's and
   MH3's grids without a ruling are (recommended), or derived R+I+P and
   flagged.
9. **Reggie and the cyber-sergeants**: named by the registry, `Reggie` and
   `Cyber-Sergeants` (recommended), since the page names them in its prose
   and a heading rather than on a name line.

## How to reproduce

```bash
python scripts/msh/survey.py mh4
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at
30-110 dpi into the scratchpad, never into the repo, and the trial parse
wrote its `roster.json` into a scratch copy of the cache, never the main
checkout's.
