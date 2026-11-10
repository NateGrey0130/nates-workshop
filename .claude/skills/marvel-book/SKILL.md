---
name: marvel-book
description: Import a Marvel Super Heroes (TSR, FASERIP) sourcebook into the Marvel app - its characters into the Marvel Codex's Notable NPCs and the GM tools, its items and locations into the Codex's Items and locations. A book's adventure is not imported. Use when handed a Marvel/MSH sourcebook PDF or asked to add a Marvel book's characters, to correct one, or to give a team's members stats. NOT book-survey, class-import or scripts/ocr-book.py - those are the Palladium/Rifts pipeline and must not be used or changed for a Marvel book.
---

# A Marvel sourcebook

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`).

**A Marvel book has a pipeline of its own, in `scripts/msh/`, and never goes
through the Palladium one.** Not `book-survey`, not `class-import`, not the
`book-extract-worker` or `book-reconcile` agents, not `scripts/ocr-book.py`,
`scripts/books.json` or `.cache/books/`. They are Palladium's: written for
O.C.C.s, S.D.C. and Palladium's OCR damage, owned by another group, and pinned
by its tests. Do not read them for method either - their rules (cite to a
catalog, Rows lines per table) are not this pipeline's. `groups.json` gives
`scripts/msh/` to the marvel group; a Marvel book PR is `msh/...`.

Three books are done, and each survey is a worked example. Read the one whose
layout is nearest before starting another:
- `apps/marvel-heroes/docs/surveys/ma1.md`: a sourcebook of numbered grids,
  a printed Contents and index, read by `scripts/msh/roster.py`
- `apps/marvel-heroes/docs/surveys/mhsp1.md`: a boxed module (three booklets,
  each numbered from 1) whose blocks print rank words and no numbers, with no
  index, read by `scripts/msh/booklet.py`
- `apps/marvel-heroes/docs/surveys/me1.md`: a boxed module of two booklets
  whose blocks are MA1's numbered grids, with characters statted inside an
  adventure's chapters too, read by `scripts/msh/gridbooks.py` through
  `roster.py`'s own entry loop

**Many books in one set of files** (merging by book, the registry's order, a reader per layout, proving every earlier book did not move) is in `.claude/rules/marvel-pipeline.md`. That file loads by itself only when a file under `scripts/msh/` or `apps/marvel-heroes/` is read, so read it now if it is not in context.

## The chain

| step | command | writes |
|---|---|---|
| register | an entry in `scripts/msh/books.json` (below) | committed |
| cache | `python scripts/msh/ocr-book.py <slug>` (`--probe` first) | `$WORKSHOP_MSH_CACHE/books/<slug>/tsv,txt` |
| measure | `python scripts/msh/survey.py <slug>` | nothing; feeds the survey doc |
| parse | `python scripts/msh/roster.py <slug>` | `.../roster.json` (prose, local only) |
| characters | `python scripts/msh/npcs.py <slug>` | `apps/marvel-heroes/data/npcs.json` + `.../book-text.sql` |
| items | `python scripts/msh/extras.py <slug>` | `data/items.json` + `.../extras-text.sql` |
| load | `node scripts/d1-apply.mjs --remote --db marvel <each .sql>` | `msh_book_text` in `DB_MARVEL`, before the merge (`ship-pr` → *The ordering rule*) |

`WORKSHOP_MSH_CACHE` from a worktree is in `.claude/rules/marvel-pipeline.md`: read it before running the chain in one.
`roster.py` exits 1 on a failed
check, an override that no longer matches, or an index name it cannot place:
that exit code is the gate, not the report's numbers.

## The registry entry, and how each field is MEASURED

Every field is read off the book, never assumed from the last book.

- `offset`: printed = PDF - offset. `survey.py` votes by folio from TSV
  geometry; take the value nearly every page agrees on and look at the
  outliers on the image.
- `columns`, `stat_labels`, `section_labels`, `rank_aliases`: the book's own
  spellings. MA1 misprints rank codes (`Fb`, `Po`, `Go`, `Re`) - alias them.
- `sections`: the printed Contents, **then check every banner on its page.**
  MA1's Contents was wrong seven times; `contents_errata` records the page
  that wins. A section header placed at the Contents' page cuts an entry in
  half, which is how the parser found them.
- `index`: the printed index, **transcribed by eye** from renders. Dot leaders
  defeat Tesseract. It is the coverage checklist: `roster.py` must place
  every name. A name with two pages is usually a cross-reference or an
  early-version modifier, not a second stat block - read each page.
- `character_pages`, `item_pages`, `item_parts`: the ranges each script reads.
  `adventure` is MHSP1's only; a new book leaves it out.
- **A boxed module** replaces `offset` with `parts`: each booklet's PDF range,
  offset and `cite` (how a card names it, "Roster"). Then `character_part`,
  `item_part` and `adventure.part` say which booklet a range counts in, and
  every card, block, item and section carries its `part`. MHSP1's entry also
  shows `reference_summary` (a chart as the index), `running` (notes in another
  booklet), `adventure.sections` (parsed only because its locations and
  vehicles are found inside them), `locations` (with a room table transcribed
  as data) and `vehicles`. The registry's `about` list documents every field.

## The book checks itself

Every block must satisfy **Health = F+A+S+E, Karma = R+I+P, and each number
its rank code.** A failure is a page to look at:

- an OCR misread -> fix the parser, if it is a pattern, never for one block;
- a **misprint** in the book -> `scripts/msh/<slug>-overrides.json`, read off
  the page image, keeping `printed` AND `corrected` (the Codex shows the page,
  the GM tools play the corrected value);
- printed that way on purpose -> `as_printed`, with the reason;
- a mark in the prose only the page image settles -> a `text` verdict (the
  row key, a few words as read and as printed); `npcs.py` stops if the
  fragment is not found exactly once in its row.

**A book that prints ranks and no numbers checks itself the same way**, on
each rank's standard number (`apps/marvel-heroes/data/ranks.json`). That every
MHSP1 block adds up that way is the evidence the numbers are right to derive;
its blocks say `rank_only` so the Codex never shows a derived number as
printed. A chart that repeats the blocks (MHSP1's Reference Summary) is held
to them too, and its own misprints are overrides.

Where the text prints a Health for something without a block of its own, it
is a free check on any stats you build (`scripts/msh/<slug>-members.json`:
a team's tier plus only the ranks the member's text states). If the build
does not reproduce the printed Health, the method is wrong.

## Facts in the repo, prose in D1

The repo is public and the text is TSR's. **Commit numbers, rank codes,
names, short identity lines and pages; never a sentence of the book.** The
prose goes to `msh_book_text` (migration 087) through the generated `.sql`,
which is never committed. The Marvel smoke suite's leak check compares every
file under the app, its endpoints, `scripts/msh/` and the Marvel migrations
with the cached prose, ten words at a time: the parsed text, and the raw OCR
of every page no parser covers yet. So a book is covered from the day it is
cached. It caught the first survey quoting the book. Run the suite with the
cache present, or it skips.

`npcs.py` and `extras.py` each delete only their own rows before inserting,
so either can be re-run alone. Keep it that way.

## Traps the books hit

- **Stat grids:** `--psm 3` reads some grids' letter and number columns
  sideways. `roster.py` re-reads every grid from a `--psm 6` crop; trust that,
  not the page TSV.
- **Headers:** height alone is not enough (some prose words box tall); a header
  is capitals or short title case. A header with a U+FFFD apostrophe fails the
  test - handle it locally, and do not loosen the parser's rule without
  re-running every book: live data depends on it.
- **Height can fail outright.** ME1's headers box at 1.16-1.26 times the body
  and its body lines reach 1.29, so no ratio separates them. Measure it on the
  TSV before choosing a rule. Where every character has a grid, find the header
  from the grid (`gridbooks.mark_headers`) and not from its size.
- **A check that cannot read a value passes it.** `roster.check()` skips a
  Health or Karma that is not a number, which is right for MA1's robots
  (`Karma = -`) and hid ME1's `330 k` (art beside the grid) and an unread grid's
  welded rows. A book that prints a number for every one should assert it
  (`gridbooks.coverage`).
- **One override matches one block, and marks all of it explained.** A second
  fault in the same block goes in its `also`, or the Marvel smoke suite's
  Health/Karma check finds it unrecorded, as it did ME1's Ghoul Captain.
- **Characters statted inside an adventure's prose** (ME1's chapter
  opponents) are read in `read_entries(opponent=True)`: an entry ends where
  the chapter resumes, at an indented paragraph or a run-in that is not a
  section. A run-in's curly apostrophe (`CLAUD VICTOR'S:`) defeats `RUN_IN`
  unless it is folded first.
- **The ASCII-only trap and the worktree's local D1** are in `.claude/rules/marvel-pipeline.md`: read it if it is not in context.
- **Low confidence is not junk.** A title, a header or a real word can read at
  confidence 0 and still be right (MHSP1's "Galactus's 'Cat'" header), and art
  beside a column can read at 60. Filter prose by what the book reads
  confidently elsewhere, and re-read a line that lost a word from a crop of the
  page image (`--psm 7`). Never drop by a threshold alone.
- **Tesseract can miss a title entirely** (MHSP1's "Going Home"). Find the
  section by its first words, recorded in the registry, and say so there.
- **Quote marks are handled in the chain** (`npcs.pair_quotes`,
  `booklet.quotes`, and `npcs.unpaired`, which stops the build on an odd
  count). What a new book needs is one fact, read off the page images:
  **does it print single quotes of its own?** MHSP1 prints none, so every
  single mark is a misread; MA1 does, so a lost closing single is a `text`
  override, never a rule. `ma1.md` *Quote marks* is the worked example.
  A trademark sign after a name folds to nothing (NFKD would spell it TM).
- **Read the page before naming where something is.** The MHSP1 survey put a
  vehicle in the wrong event, because a paragraph at the top of a column
  continues the section above it.

## Done means

- `roster.py` exits 0; every misprint has an override read off the page
- `npcs.py` and `extras.py` exit 0, so no row has an unpaired double quote
- the Marvel suite passes **with the cache present** (leak check ran)
- the `.sql` applied to production before the merge (`ship-pr` → *The ordering
  rule*) and read back by count
- the survey's `**Rows citing this book:**` line updated in the same PR
- the Codex card and, for NPCs, "Add an NPC from the book" driven in a browser
