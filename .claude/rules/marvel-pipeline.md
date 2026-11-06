---
paths:
  - "scripts/msh/**"
  - "apps/marvel-heroes/**"
---

# The Marvel pipeline

> **What pins this file:** every absolute path it names, by
> `apps/character-creator/test/checks/instruction-paths.mjs`. Nothing pins
> its frontmatter or the repo paths it names: it is a path-scoped rule, not a
> skill, so `environment.mjs` does not read it.
>
> **The prose is pinned by nothing** - read an undated claim here as true on
> the day it was written.

These bind anyone editing `scripts/msh/` or `apps/marvel-heroes/`. They were
moved unchanged out of the `marvel-book` skill (2026-11-06), which still owns
the chain itself and how a book is imported.

## Many books in one set of files

Since 2026-09-28 the chain is multi-book. What that means for a new one:

- **`npcs.py` and `extras.py` merge by book.** Every character and item
  carries its `book`, and rebuilding one book replaces only that book's rows
  in `data/npcs.json` and `data/items.json`. The D1 rows were already keyed by
  book.
- **Adventures are not in the app** (Nate, 2026-09-29, #1550). There is no
  `data/adventures.json` and no Adventures section. Do not set a new book's
  registry `adventure` or import its adventure's sections, and ask before
  importing items that live only inside one. `extras.py` still parses
  MHSP1's, the only registry `adventure` left, because its items are found
  inside it, and writes text only for a section an item names (`section`:
  its two vehicles read First Blood and Patrol).
- **The registry's ORDER is part of the data.** The first book in
  `scripts/msh/books.json` keeps plain ids (`magneto`); every later book's ids
  end in `-<slug>` (`magneto-mhsp1`). **Append a new book; never reorder**, or
  every id, Codex link and saved GM sheet of the moved books changes.
- **The same character in two books is two cards** (Nate, 2026-09-28), each
  citing its own book. The GM's list tells them apart by book.
- A book needs a `short` (the code a card cites it by, e.g. MA1).
- A book with no team sections (laid out A-Z) files its characters under
  the book's own title.
- **A book laid out differently gets a reader of its own**, chosen by the
  registry's `layout`: absent is MA1's (`roster.py`), `roster-booklet` is
  MHSP1's (`booklet.py`), `grid-booklets` is ME1's (`gridbooks.py`). The
  reader returns the same `roster.json` entries, and `npcs.py` and
  `extras.py` gate what is new behind the same field. Do not bend MA1's path
  to fit another book: its header height, column cut and number grid are
  tuned to MA1 and live data depends on them. Reusing its pieces is fine:
  `gridbooks.py` builds its own streams and headers and hands them to
  `roster.read_entries()`.
- **Prove every earlier book did not move.** Before a PR that touches
  `scripts/msh/` merges, build each book already in the registry with
  `origin/main`'s scripts (a
  `git archive origin/main scripts/msh apps/marvel-heroes/data` into the
  scratchpad, with a copy of the cache under its own `WORKSHOP_MSH_CACHE`)
  and with the branch's, and `cmp` its `roster.json`, `book-text.sql`,
  `extras.json`, `extras-text.sql` and its rows of `npcs.json`.
  Byte-identical, or say why not: ME1's parser fixed a real MA1 misread
  (Nekra's `40In` alternate, stored as 401), and a difference like that is
  read on the page image before it ships.
- **A team name is a filter group shared by every book.** MHSP1's sides are
  "Secret Wars Heroes" and "Secret Wars Villains" because MA1 already has a
  team called Villains.

So a new book's first PR is the survey (registry entry and survey doc, no
data). If its layout is new, the reader is the second, and the data is last.

## The cache from a worktree

`WORKSHOP_MSH_CACHE` defaults to `.cache/msh` under the checkout. **From a
worktree, set it to the main checkout's `.cache/msh`**, or the worktree builds a
cache of its own and its removal deletes it.

## Two traps

- **The Edit and Write tools turn `\uXXXX` into the literal character**, and
  the Bash tool's heredocs lose one backslash of `\\u` (build it with
  `chr(92)`). Every file here must stay ASCII. Check the bytes after editing.
- **Worktrees:** the local D1 may predate the Marvel tables; apply
  `db/migrations/marvel/*` locally before driving the GM page.
