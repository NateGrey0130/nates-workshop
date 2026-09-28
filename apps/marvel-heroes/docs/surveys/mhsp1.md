# Survey: MHSP1 Secret Wars (TSR6860)

Marvel Super Heroes special module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mhsp1`. Measured 2026-09-28.

**Rows citing this book:** 0. This is the survey PR: a registry entry and this
file, with no characters, items or `msh_book_text` rows yet.

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
`offset`, and the scripts that read `offset` (`survey.py`, `roster.py`) were
run from a scratch copy of the registry with `offset` set per part. See
[The parser](#the-parser-dry-run).

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

## The next PRs

1. **Parser (`msh/feat/...`):** make `scripts/msh/` read this layout without
   changing MA1's output. Before merging it, confirm that MA1's `book-text.sql`
   and `roster.json` are byte-identical to what they are now.
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
2. **Data (`msh/data/mhsp1-...`):** `npcs.py mhsp1`, then `extras.py mhsp1` if
   Decision 6 says so, the `.sql` applied to production before the merge, and
   this file's Rows line updated.

## How to reproduce

```bash
python scripts/msh/ocr-book.py mhsp1
```

`survey.py` and `roster.py` need an `offset`, which this entry deliberately
does not have. Until the parser PR, run them from a copy of the registry
with `offset` set to 1 (the Adventure Book) or 17 (the Roster Booklet).
Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from a
worktree.
