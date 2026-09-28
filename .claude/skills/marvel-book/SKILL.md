---
name: marvel-book
description: Import a Marvel Super Heroes (TSR, FASERIP) sourcebook into the Marvel app - its characters into the Marvel Codex's Notable NPCs and the GM tools, its items, locations and adventure into their Codex sections. Use when handed a Marvel/MSH sourcebook PDF or asked to add a Marvel book's characters, to correct one, or to give a team's members stats. NOT book-survey, class-import or scripts/ocr-book.py - those are the Palladium/Rifts pipeline and must not be used or changed for a Marvel book. Covers the scripts/msh/ chain, the registry fields a new book needs and how each is measured, the book's own arithmetic as the check, facts in the repo and prose in D1, and the traps that bit the first book.
---

# A Marvel sourcebook

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing** - read an undated claim here as true on
> the day it was written.

**A Marvel book has a pipeline of its own, in `scripts/msh/`, and never goes
through the Palladium one.** Not `book-survey`, not `class-import`, not the
`book-extract-worker` or `book-reconcile` agents, not `scripts/ocr-book.py`,
`scripts/books.json` or `.cache/books/`. They are Palladium's: written for
O.C.C.s, S.D.C. and Palladium's OCR damage, owned by another group, and pinned
by its tests. Do not read them for method either - their rules (cite to a
catalog, Rows lines per table) are not this pipeline's. `groups.json` gives
`scripts/msh/` to the marvel group; a Marvel book PR is `msh/...`.

The first book done this way is MA1, and its survey is the worked example:
`apps/marvel-heroes/docs/surveys/ma1.md`. Read it before starting a second.

## A SECOND book needs the scripts made multi-book FIRST

As of MA1 the chain is single-book, and running it for another book **destroys
the first**:

- `npcs.py` writes `data/npcs.json` whole from one book's parse, and
  `extras.py` writes `data/items.json` and `data/adventures.json` the same
  way. A second book would replace MA1's 180 characters, not add to them.
- A character's `team` is the Contents section its page falls in. A book
  laid out A-Z (a handbook) has no team sections.
- `roster.py` was tuned on MA1's three columns and header sizes. Expect
  `--failures` to show where another layout differs; generalise, then re-run
  MA1 and confirm its output is byte-identical before trusting the change.

So the first PR of a second book is the survey (registry entry + survey doc,
no data). The second makes the scripts merge by book, and decides with Nate
what a character in two books becomes (another version of one card, or two
cards). Only then does the new book's data land.

## The chain

| step | command | writes |
|---|---|---|
| register | an entry in `scripts/msh/books.json` (below) | committed |
| cache | `python scripts/msh/ocr-book.py <slug>` (`--probe` first) | `$WORKSHOP_MSH_CACHE/books/<slug>/tsv,txt` |
| measure | `python scripts/msh/survey.py <slug>` | nothing; feeds the survey doc |
| parse | `python scripts/msh/roster.py <slug>` | `.../roster.json` (prose, local only) |
| characters | `python scripts/msh/npcs.py <slug>` | `apps/marvel-heroes/data/npcs.json` + `.../book-text.sql` |
| the rest | `python scripts/msh/extras.py <slug>` | `data/items.json`, `data/adventures.json` + `.../extras-text.sql` |
| load | `node scripts/d1-apply.mjs --remote --db marvel <each .sql>` | `msh_book_text` in `DB_MARVEL`, BEFORE the merge (`ship-pr`) |

`WORKSHOP_MSH_CACHE` defaults to `.cache/msh` under the checkout. **From a
worktree, set it to the main checkout's `.cache/msh`**, or the worktree builds a
cache of its own and its removal deletes it. `roster.py` exits 1 on a failed
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
- `character_pages`, `item_pages`, `item_parts`, `adventure`: the ranges each
  script reads.

## The book checks itself

Every block must satisfy **Health = F+A+S+E, Karma = R+I+P, and each number
its rank code.** A failure is a page to look at:

- an OCR misread -> fix the parser, if it is a pattern, never for one block;
- a **misprint** in the book -> `scripts/msh/<slug>-overrides.json`, read off
  the page image, keeping `printed` AND `corrected` (the Codex shows the page,
  the GM tools play the corrected value);
- printed that way on purpose -> `as_printed`, with the reason.

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
with the cached prose, ten words at a time. It caught the first survey
quoting the book. Run the suite with the cache present, or it skips.

`npcs.py` and `extras.py` each delete only their own rows before inserting,
so either can be re-run alone. Keep it that way.

## Traps the first book hit

- **Stat grids:** `--psm 3` reads some grids' letter and number columns
  sideways. `roster.py` re-reads every grid from a `--psm 6` crop; trust that,
  not the page TSV.
- **Headers:** height alone is not enough (some prose words box tall); a header
  is capitals or short title case. A header with a U+FFFD apostrophe fails the
  test - handle it locally, and do not loosen the parser's rule without
  re-running every book: live data depends on it.
- **The Edit and Write tools turn `\uXXXX` into the literal character.** Every
  file here must stay ASCII. Check the bytes after editing.
- **Worktrees:** the local D1 may predate the Marvel tables; apply
  `db/migrations/marvel/*` locally before driving the GM page.

## Done means

- `roster.py` exits 0; every misprint has an override read off the page
- the Marvel suite passes **with the cache present** (leak check ran)
- the `.sql` applied to production before the merge and read back by count
- the survey's `**Rows citing this book:**` line updated in the same PR
- the Codex card and, for NPCs, "Add an NPC from the book" driven in a browser
