# Survey: MHSP1 Secret Wars (TSR6860)

Marvel Super Heroes special module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mhsp1`. Measured 2026-09-28.

**Rows citing this book:** 209 `msh_book_text` rows over 41 entries in
production (`DB_MARVEL`, read back 2026-09-29):
- 189 over 37 character entries (the Wrecking Crew's four members have their
  text on the team's card)
- 20 over 2 items and the 2 adventure sections its two vehicles read (First
  Blood, Patrol); the other 28 sections' rows were deleted 2026-09-29, when
  adventures left the app

Committed:
- 41 characters in `apps/marvel-heroes/data/npcs.json`: 45 blocks and 112
  powers, 38 of them linked to the Ultimate Powers Book
- 4 items in `data/items.json`
- the Secret Wars adventure's 30 sections were in `data/adventures.json`
  until 2026-09-29, when adventures left the app; the registry still names
  them, because the locations and vehicles are found inside them

This is the second Marvel book, and the first since the scripts became
multi-book (#1520). It went through `scripts/msh/` only. The worked example is
[ma1.md](ma1.md), and this file follows its order. **Most of what MA1 taught
the parser does not carry over, because this book is a different kind of
object:** a boxed module of three booklets with no index, and a stat block
that prints rank *names* and no numbers.

## The scan

- 37 PDF pages, a pure scan: `scripts/msh/ocr-book.py mhsp1 --probe`
  medians 0 text-layer characters over 20 sampled pages.
- Cached with `python scripts/msh/ocr-book.py mhsp1` into the main checkout's
  `.cache/msh/books/mhsp1/`: all 37 pages in 1m14s.
- The print is clean, and Tesseract reads the body text and the roster's stat
  labels well. It cannot read the maps (PDF 36-37) or the covers, which is
  expected and harmless.

**The PDF is three booklets and a folder, each numbered from 1.** Recorded
as `parts` in the registry:

| PDF | part | printed |
|---|---|---|
| 1 | Adventure Book cover | - |
| 2-17 | Adventure Book | 1-16 |
| 18-33 | Roster Booklet | 1-16 |
| 34 | Reference Summary, the inside of the module folder (a two-page spread on one PDF page) | - |
| 35 | the folder's outside cover | - |
| 36-37 | Maps 1 and 2 | - |

## Offset: two of them

`scripts/msh/survey.py`'s folio reader (TSV geometry, bare digits in the
bottom tenth) finds 19 folios:
- **8 vote printed = PDF - 1**: PDF 2 and 11-17, the Adventure Book.
- **8 vote printed = PDF - 17**: PDF 18 and 27-33, the Roster Booklet.
- 3 are noise: a table reference at the foot of PDF 6, art on PDF 7, and the
  "Map 2" label on PDF 37.

Every Roster Booklet folio 2-16 was also read on its page image.

**The registry's single `offset` cannot describe this book,** and neither can
anything keyed by printed page alone: `sections`, `character_pages`,
`index` and a card's page citation all assume one numbering. "p.4" is Bases
in one booklet and Iron Man in the other. So this entry carries `parts` and no
`offset`. For the survey, the scripts that read `offset` (`survey.py`,
`roster.py`) were run from a scratch copy of the registry with `offset` set per
part. The parser PR taught both to read `parts` (see
[The parser](#the-parser)), and each part carries the `cite` a card shows:
`Roster`, `Adventure` and `Reference Summary`.

## The book's own authority lists

- **No Contents and no index.** Neither booklet has one.
- **Adventure Book section banners**, each read on its page: 1 Introduction
  (printed 1), 2 Judge's Briefing (2), 3 The Battleplanet (4), 4 Bases (5),
  5 Events (7), 6 Running Heroes (12), 7 Running the Villains (14), and an
  unnumbered Karma Awards page (16), which also carries the credits.
- **Roster Booklet, printed 1:** an introduction that names seven heroes it
  leaves out on purpose, because the boxed rules already stat them. In
  alphabetical order: Captain America, Captain Marvel, Mister Fantastic,
  Spider-Man, the Human Torch, the Thing and Wolverine.
- **The Reference Summary (PDF 34)** is the nearest thing to an index. It
  lists 23 heroes and 17 villains (13, plus the Wrecking Crew's four), each
  with seven four-letter rank abbreviations, Health, Karma and a short list of
  powers. **Transcribed by eye** from a 130 dpi render and stored as
  `reference_summary`. It is the coverage checklist: 33 of its 40 rows have
  a Roster Booklet block, and the other 7 are exactly the seven heroes above.
  So for those seven, **the Summary row is the only stat block this box
  has.**

## What an entry looks like

```
COLOSSUS(tm)                   bold capitals with a trademark glyph
Peter Rasputin, student        identity: real name, then an occupation
Fighting:    GOOD              seven rows: label, then a rank NAME;
Agility:     GOOD              no numbers anywhere in the block
Strength:    EXCELLENT [MONSTROUS]   bracket = another form's rank
...
Health:      60 [145]          Health, Karma, Resources, Popularity
Karma:       32                below the seven rows, same two columns
Resources:   POOR
Popularity:  10
Powers:                        then "CAPITALISED NAME." run-ins (a period,
                               not MA1's colon), then Talents:, Background:
```

**Two entries a page**, one above and one below a heavy rule. Each has an
illustration on one side and the text in two columns beside it; which side
alternates. An entry can run from its stat column into the next column but
never onto another page. **Printed 16 is the exception:** one Wrecking Crew
header over a group illustration, then four member blocks (Wrecker,
Thunderball, Piledriver, Bulldozer) with one shared Powers, Talents and
Background, in three columns.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `Reason: ?`, and Karma 40 = Intuition + Psyche, so `?` counts 0 | Lockheed, Roster p.9 |
| `Resources: none`; `Popularity: none` | Galactus's "Cat", Lockheed and Zsaji; the "Cat" only, p.9 |
| `Health: 2,150 (Varies)`, `Karma: 1,200 (Varies)`, `CLASS 1000` | Galactus, p.12 |
| `GOOD (Varies)`, `EXCELLENT (Varies)` | Absorbing Man, p.10 |
| `TYPICAL [INCREDIBLE]`, `Health: 52 [155]` | Iron Man (armour), p.4; Colossus (steel form), p.2 |
| `Resource:` (singular) | Titania p.14, Wrecker p.16 |
| `Background.` (a period) | Klaw p.13, Enchantress p.11, Wrecker p.16 |
| a one-line grid: `F A S E R I P` over seven codes, then Health (and Karma) | see *Blocks* below |

**The rank spellings.** The Roster Booklet spells ranks in full capitals, the
Summary abbreviates them to four letters (`Feeb`, `Typi`, `Exce`, `Rema`,
`Incr`, `Amaz`, `Mons`, `Unea`, `C1 1000`), and the one-line grids use
two-letter codes, including MA1's `Fb` for Feeble. All three sets are in
`rank_aliases`.

## Stat blocks: 33 full, 5 one-line, 40 summary rows

| measure | count |
|---|---|
| full Roster Booklet blocks (printed 2-16) | 33: 16 heroes, 17 villains |
| of those, Health = F+A+S+E by the ranks' standard numbers | **33** |
| of those, Karma = R+I+P | **33** |
| bracketed alternate forms, Health checked too | 2 (Colossus 145, Iron Man 155), both pass |
| one-line grids | 5, all pass: She-Hulk's human form (Roster p.6), Lizard's (p.13), Volcana's (p.15), Klaw's sound creatures (p.13, Health only), Ben Grimm (Adventure p.13) |
| Reference Summary rows | 40 |
| of those, pass their own arithmetic | 37 |

**Because nothing prints a number, the checks run on the rank's standard
number** (`ranks.json` `standard`: Feeble 2, Poor 4 ... Unearthly 100, Class
1000 1000). That every full block passes is the evidence that this is how the
book computed Health and Karma. So an imported ability's number is derived,
not read (Decision 3).

**The Reference Summary misprints three values.** Each was read on the page,
and in each the Roster Booklet's own ranks agree with the Roster Booklet:

| row | Summary prints | its own ranks sum to | Roster Booklet prints |
|---|---|---|---|
| Galactus | Health 2100 | 2150 | 2,150 (p.12) |
| Lizard | Karma 54 | 44 | 44 (p.13) |
| Molecule Man | Karma 104 | 89 | 89 (p.14) |

One more row differs without failing: **Lockheed's** Karma is a dash in the
Summary and 40 in the Roster Booklet. **The other 29 roster characters agree
with their Summary row in all nine values.** For Colossus and Iron Man, the
Summary prints the armoured form's ranks and Health (the bracketed values).

**The Marvel smoke suite's leak check did not cover this book.** It compares
the repo with each book's parsed `roster.json`, and MHSP1 has none yet. So the
same ten-word comparison was run by hand against the raw OCR text of all 37
pages. It found one run in this file, a list of names in the book's own order,
which is now reordered. It also found two runs in `books.json`: the Summary rows
for Galactus's "Cat" and the Wrecker. Those are rank abbreviations, not
prose, but they pass the check's "six real words" filter because words like
`typi` and `amaz` look like words to it. That filter needs to know the rank
abbreviations before the parser PR feeds this book's text to the check.

`survey.py`, unchanged, finds **1** block in this book, and it is not one: the
line where the text gives Doom a Health of 45 after an event (Adventure p.11).
It keys on `Health =`, and the roster prints `Health:`. The 33 + 5 above come
from a scratch reader of the Roster Booklet's label lines, checked block by
block against the page images, and from the Summary transcription. None of
that reader is committed.

## The parser dry run

`python scripts/msh/roster.py mhsp1 --failures`, run from a scratch copy of the
registry with `offset` 17, `columns` 2 and `character_pages` [2, 16], so that it
reads the Roster Booklet. `roster.py` is unchanged in this PR.

| measure | MA1 | MHSP1 |
|---|---|---|
| entries | 205 | **2** |
| stat blocks found | 189 | 29 of 33 |
| blocks passing every check | 180 | **0** |
| exit | 0 | 1 |

It fails for four separate reasons, measured on the TSV:

1. **Headers are not tall enough.** `is_header` wants a line 1.35 times the
   page's body height. Roster headers box at 29-30 px against a body height of
   25-26 at 300 dpi, a ratio of about 1.15. Tesseract also reads the trademark
   glyph as U+FFFD. So no header is found: all 33 characters merge into 2
   entries.
2. **The grid is words, not numbers.** `grid_at` reads seven rows of
   `<letter> <number> <code>`, and this book prints `Fighting: EXCELLENT`. All
   29 blocks come back with seven null numbers. They were found only by their
   `Health:` anchor.
3. **The column cut welds prose onto the stats.** The stat column sits beside
   a prose column, and the illustration swaps sides every half page, so the
   two least-inked gutters are not the text gutters. Cyclops's Health comes
   back as "76" followed by five words of his background.
4. **Two numberings.** `offset` is one integer, and it is used for every page
   and page citation.

*The dry run above is kept as it was measured. The parser PR's own section
follows.*

## The parser

`python scripts/msh/roster.py mhsp1` reads this book through
`scripts/msh/booklet.py`, because its registry entry says
`"layout": "roster-booklet"`. It writes the same `roster.json` entries that
MA1's path does, so `npcs.py` and `extras.py` take either. MA1's path through
`roster.py` is unchanged. Rebuilt on this branch, MA1's `roster.json`,
`book-text.sql` (902 rows), `extras.json`, `extras-text.sql` and `npcs.json`
are byte-identical to `main`'s, and so is `survey.py ma1 --json`.

How the reader works:
- **Pages are cut at the heavy rule**, found on the page image as a row that is
  dark across more than 60% of its width. There is one on every roster page.
  Each half is cut into three columns by MA1's `gutters()` and read top to
  bottom, left to right. This is what fixed the dry run's welded columns.
- **A header** is capitals ending in the trademark sign, or capitals set at
  least 1.1 times the body height. Galactus's "Cat" reads at confidence 0 and
  is still found, because a low-confidence line is kept when a stat block
  follows it.
- **A full block is re-read from a crop of the page image** at `--psm 6`, as
  MA1's GridReader does. The labels box taller than their values on some pages
  (46-66 px against 26 on Cyclops's), so the TSV misplaces them. The crop ends
  at the block's own text: Lockheed's illustration read as words. A value
  neither reading gets is read from that one line at `--psm 7`: Storm's
  Popularity is a lone "4" that both read as a mark.
- **Ranks become numbers through the registry.** `rank_aliases` gives the rank,
  and `ranks.json` gives its standard number, so every block is `rank_only`.
  The number is derived, never read.
- **One-line grids** are read code by code, under the letters by x. There are
  five, including Ben Grimm's in the Thing's running note.
- **Running notes** (registry `running`) are found by the capitals-plus-
  trademark run-in. Balloon lettering from the comic panels is dropped
  because it is capitals, and a word below 75 confidence is dropped from a
  prose line (prose reads 92 or better).
- **The Reference Summary is the index.** Every row must be an entry, and every
  roster block must agree with its row, or the difference must be recorded in
  `scripts/msh/mhsp1-overrides.json`. Otherwise `roster.py` exits 1.

Measured 2026-09-28:

| measure | count |
|---|---|
| entries | 41: 33 characters, 7 from the Summary alone, and the Wrecking Crew |
| stat blocks | 45: 33 full, 5 one-line, 7 from the Summary |
| pass Health and Karma on derived numbers | 44 |
| explained by an override | 1: Lockheed's printed `?` Reason (Karma 40 = I + P) |
| failing | 0 |
| Summary rows placed | 40 of 40; 4 chart disagreements recorded (the 3 misprints and Lockheed's dash) |
| running notes | 35: 22 heroes, 12 villains and the Wrecking Crew's shared one |
| powers named | 112, across 37 entries |

Three one-line grids have no name above them, so the overrides name them from
the entry's own identity lines: Klaw's sound creatures, Curtis Connors and
Marsha Rosenberg. Jennifer Walters and Ben Grimm are named in print.

**The leak check now covers a book before it is parsed.** The Marvel smoke
suite also shingles the OCR of every cached page that no parser covers
(`character_pages`, `item_pages`, `adventure` and `running`, per the
registry). That takes in MA1's contents page and introduction, and all of
MHSP1's Adventure Book outside its running notes. It found one real 10-word
quote of MA1 that the old check had missed: a `roster.py` comment quoting
printed 2, now paraphrased. It also found one false match, the team names in
`npcs.json` in Contents order, so the check no longer counts the registry's
own names, or the Summary's four-letter rank abbreviations, as prose words.
A first version shingled whole pages, character pages included, and so also
flagged the identity lines `npcs.json` is meant to carry. That is why a page
a parser covers is left to the parsed text.

## Entry kinds

Reconciling the 33 blocks, the 5 one-line grids and the 40 Summary rows sorts
the box into these kinds:

1. **Character, with a Roster Booklet block.** 33.
2. **Character with a Summary row only.** 7: the heroes the boxed rules
   already stat. Each has seven ranks, Health, Karma and power *names*, but no
   powers text, Resources or Popularity. Their running notes are in Adventure
   Book section 6.
3. **Forms.**
   - Bracketed, inside the one block: Colossus's steel form, and Iron Man
     with and without the armour's boosts.
   - A one-line grid for the human side of a transformed character: Jennifer
     Walters (She-Hulk), Curt Connors (Lizard), Marsha Rosenberg (Volcana),
     and Ben Grimm (the Thing, in the Adventure Book).
   - These map to the snapshot's `forms`, as MA1's Wolfsbane did.
4. **A prose-only variant.** The Hulk's adrenaline surge raises named
   abilities in the text, with no block. Galactus weakens month by month, in
   the text. The Absorbing Man's ranks vary with what he touches.
5. **A statted non-character.** Klaw's sound creatures: a one-line grid with a
   Health and no Karma, inside Klaw's entry.
6. **A team.** Only one, the Wrecking Crew: four full blocks under one header,
   sharing one Powers, Talents and Background.
7. **Running notes.** Adventure Book sections 6 and 7 give most characters a
   paragraph on how to play them on the Battleplanet. This is the same kind of
   text as MA1's `RUNNING <NAME>:`, but it sits in a different booklet from
   the character.

## What is not character-shaped

All of it is in the Adventure Book:
- **The adventure is not chaptered.** It is a campaign frame: 12 Planned
  Events, each on a set day and shift over the nine-day war (Day 1 Morning to
  Day 10 Morning), and a 10-entry Random Event table (d10) rolled each
  morning.
- **Section 3** describes 10 numbered terrain sectors of the Battleplanet.
- **Section 4** is a room table: 26 lettered sectors (A-Z, each with a d100
  range) for four bases (Herobase, Doombase, Magneto's Fortress and Taa II),
  followed by notes on each room type. The notes carry item-like entries: the
  Ultimate Nullifier, the auto-docs, the security vaults.
- **A statted vehicle in prose:** the villains' gunnery platform (Adventure
  p.8) gets control, speed and body ranks, like MA1's Blackbird.
- **Karma Awards (printed 16)** is a table of fixed awards and penalties per
  character and event.

`extras.py` reads `item_pages` and `adventure` ranges as MA1 laid them out
(run-in items, encounter sections). Neither is set for this book yet (Decision
6).

## Decisions this survey leaves open

*Nate took 1, 2, 5 and 6 as recommended on 2026-09-28. 3 and 4 were taken as
recommended in the parser PR, where they first mattered, and 7 was already
settled by #1520.*

1. **Page citations across two booklets.** Printed pages repeat (1-16 twice).
   Should a card cite `Roster p.4` and `Adventure p.13`, or should `parts` stay
   internal and cards cite the PDF page? The recommendation is the part's short
   name plus the printed page, because that is what someone holding the box
   can find.
2. **The seven Summary-only heroes.** Import them as cards with ranks, Health,
   Karma and power names only (and their section-6 running note), or leave them
   out as "stats are in the boxed rules"? They are Secret Wars' headliners
   (Spider-Man, Captain America, Wolverine ...), so the recommendation is
   cards, marked as Summary-only.
3. **Ability numbers.** The book prints ranks only. Store each ability's number
   as the rank's standard number (the method that reproduces all 33 Healths and
   Karmas), with the block flagged as rank-only so the Codex does not present a
   derived number as printed?
4. **The Summary's misprints** (Galactus 2100, Lizard 54, Molecule Man 104,
   Lockheed's dash). The Roster Booklet is right each time. Record them the way
   MA1's overrides record misprints (printed and corrected), even though they
   are in the checklist and not in a character's own block?
5. **What `team` means.** There are no team sections. The book's own division is
   Heroes against Villains: the Summary's two lists, Adventure Book sections 6
   and 7, and the Roster Booklet's order (heroes printed 2-9, with Galactus's "Cat" on
   9, then villains 10-16).
   The Wrecking Crew is the one real team. The recommendation is the side as
   `team`, with the Wrecking Crew as its members' team and the side kept as
   well. The Adventure Book's suggested player groupings (X-Men, Avengers,
   Fantastic Four) are advice, not data.
6. **The adventure and the bases.** Model the 12 Planned and 10 Random Events
   as the adventure's sections, and the base rooms as a location with parts
   (the way MA1's Danger Room is), or leave the Adventure Book as `msh_book_text`
   prose only for now?
7. **The ten characters already in MA1** (Colossus, Cyclops, Lockheed,
   Magneto, Nightcrawler, Professor X, Rogue, Spider-Woman, Storm, Wolverine).
   By the rule #1520 pinned, each is a second card with a `-mhsp1` id. This is
   listed only so that nobody is surprised by ten pairs of same-named cards.

## The data

`npcs.py mhsp1` and `extras.py mhsp1` built the committed facts and the two
data scripts, applied to production before the merge. What MA1's pipeline did
not already do, and where it differs from the plan above:
- **Page citations.** Every MHSP1 version, block, item and section carries
  `part` (the registry's `cite`), and the Codex, the GM's sheet tagline and
  the source lines show it: "MHSP1 Roster p.4", "MHSP1 Adventure p.13",
  "MHSP1 Reference Summary". `msh_book_text.page` stays a bare number, because
  a text row's booklet is its entry's (a running note is always in the
  Adventure Book), so D1 needed no new column.
- **Teams** are "Secret Wars Heroes" and "Secret Wars Villains", not bare
  "Heroes" and "Villains". MA1 already has a team called Villains (its VIP
  chapter), and the Codex filter would have merged the two books' villains.
  Every card keeps the side as `side`.
- **Names** are the Reference Summary's spelling: Hulk, not THE HULK;
  Lockheed, not LOCKHEED THE DRAGON.
- **Two vehicles.** The alien hovercraft is in the Random Event "Patrol"
  (printed 11), not "The Trap", as the plan had it: the paragraph opens column
  3, which continues Patrol.
- **"Going Home"** is found by its first words, because Tesseract did not read
  its title at all (the registry records them).
- **Word confidence.** Text lines keep a word Tesseract read at 50-75 only when
  the book has that word elsewhere at 75 or better. That keeps "Cat" in the
  bases' notes, and drops fragments of the art. *The follow-up PR re-reads the
  rest:* a prose line that still lost a word is read again alone, from a crop
  of the page image as one line of text (`--psm 7`), and the crop's words are
  kept where the book has them confidently elsewhere. That brought back 46
  runs of words across the adventure and the running notes, among them
  "First" in "First Blood", "It is", "Iron", "Mr." and "not tell", with no
  art fragments. A word the book never prints confidently anywhere can
  still be lost.
- **The bases' room table** (printed 5) is carried as data in the follow-up
  PR: 26 sectors, A-Z, each with its d100 range and a room for each of the four
  bases, transcribed by eye into the registry (`locations[].rooms`) and shown on
  the location's card. The Marvel smoke suite holds the ranges to tiling 01-00.
- **Fused lines** (found by the marvel-book pressure test, fixed in a third
  follow-up). On Adventure p.2, Tesseract's page pass fused the lines of two
  columns and read the Beyonder paragraph twice. The print is clean. The
  one-line re-read then cropped two or three printed lines at once, and
  "more words wins" picked the garble. So the Players' and Judge's Briefings
  opened with junk and repeated themselves, and a pair of lines in Cyclops's
  background (Roster p.2) came out mixed. Now:
  - `booklet.py` finds each fused stretch in a column (lines overlapping by half
    a line, boxed two lines deep, or 4 px slivers) and re-reads it as a block
    from a crop as wide as the column's clean text (`mend_fused`).
  - A one-line re-read never runs on a box two lines deep, crops to where a
    line's words sit when one word stretches its box, and restores a dropped
    word where the crop reads the same word, rather than letting the longer
    reading win.
  - The second half of a hyphenated word ("con-" / "tinues") is kept against
    the line above; dot leaders read as "eee", doubled quotes and "xX:" are
    folded; and art that passes the lower-case test is dropped unless it reads
    as the book's words.
  - `extras.py` now stops if a line two printed lines deep reaches the text.
    With the mend switched off it stops on 25.
  - Both tables in the adventure text, the Random Event table and The Hunt's,
    are cut out of the prose by their box (`adventure_tables`). The Hunt's is
    carried as data, transcribed by eye: ten d10 rolls, each a villain against
    a hero, two only after Betrayal. The smoke suite holds it to the book's
    characters.
- **Quote marks.** The book quotes only with double quotes, and OCR read them
  as single quotes, pairs, mixes and asterisks (`'First`, `''nerd"`,
  `'"'kit-bashed"`). Every piece of MHSP1's text is now normalized once it is
  joined (`booklet.quotes`): any quote mark that is not an apostrophe inside a
  word or after a plural becomes a double quote. The build stops if a piece is
  left with an unpaired one. Of the 237 text rows, none changed in anything
  but quote marks, asterisks and spaces, and every row's quotes pair.
- **The GM tools** read a rank word as a Resources rank ("POOR", "CLASS
  1000"), a printed "2,150" as 2150, and a block flagged `form` as a form.
  The Marvel smoke suite pins each, and each check failed with its fix removed.

## The next PRs

1. **Parser (`msh/feat/mhsp1-parser`), done; see [The parser](#the-parser).**
   What it was asked to do, as the survey set it out:
   - Per-part offsets from `parts`, in place of `offset`, wherever `survey.py`,
     `roster.py`, `npcs.py` and `extras.py` turn PDF pages into printed pages.
     A page citation carries the part.
   - A second grid shape: seven `Label: RANK NAME [ALT]` rows, with numbers
     from `ranks.json`. Also the one-line `F A S E R I P` grid, which
     `survey.py` and `roster.py` both miss.
   - Headers found by bold capitals plus the trademark glyph (or U+FFFD) at
     about 1.15x. This must be a per-book setting, not a loosened global rule
     (the marvel-book skill's warning).
   - Columns found per half page, split at the heavy rule, with the
     illustration's side detected rather than assumed.
   - Run-in powers ending in a period; `Resource:`; `Background.`.
   - The Reference Summary as a coverage checklist, as the index is for MA1,
     and as the stat source for the seven Summary-only rows.
   - Expected: 33 blocks plus 5 one-line grids, every one passing, and 40 of 40
     Summary names placed.
2. **Data (`msh/data/mhsp1-secret-wars`), done; see [The data](#the-data).**
   What it was asked to do, as the survey set it out:
   - a `part` on every page a card cites. The Codex shows
     `MHSP1 Roster p.4`, and cites a Summary-only card as `MHSP1 Reference
     Summary` with no page. MA1's cards read as they do now.
   - `team` is the side (Heroes, Villains), and the Wrecking Crew's four
     members are its team, with the side kept.
   - the Wrecking Crew's shared Powers, Talents, Background and running note
     go on the team entry once, not four times.
   - each running note goes to D1 with its own part and page, not the
     character's.
   - the 7 Summary-only cards are marked as such.
   - Lockheed's `?` Reason is played as Shift 0 (0), since his printed Karma
     counts it as 0; the Codex shows the `?`.
   - `extras.py` learns the Adventure Book: the 12 Planned and 10 Random Events
     as the adventure's sections; the four bases as a location with the room
     types as parts; the Ultimate Nullifier as an item; the gunnery
     platform as a vehicle.

## How to reproduce

```bash
python scripts/msh/ocr-book.py mhsp1
```

```bash
python scripts/msh/survey.py mhsp1
```

```bash
python scripts/msh/roster.py mhsp1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from a
worktree.
