# Book surveys

A survey is a **reading of one sourcebook, taken on a date**: what the book
contains, where it contains it, and how its contents compared to this catalog
that day. It is written before anything is imported, so the import is driven by
what the book actually holds rather than by the pages someone happened to open.
`book-survey` is the skill that produces one; §7 there is the rule these files
follow — *facts about the book, not prose from it*.

**A survey is a dated record, not a description of the current catalog.** That
distinction is the whole point of this note, and it is not evenly distributed
across the file:

| section | ages? |
|---|---|
| `Ledger`, `Inventory`, `Page offset`, the book's authority tables | **no** — facts about a printed book, true for as long as the book exists |
| `Catalog diff` | **yes** — a comparison against the catalog on the survey date |
| `Extraction plan` | **yes** — it proposes work, and some of it has since been done |

So a survey saying a spell is missing from the catalog means *it was missing on
the survey date*. Check the catalog before acting on it. A survey saying the book
prints that spell on page 131 does not go stale at all.

**No counts of spells, skills, gear or classes live in this file**, deliberately.
Those move with every import, nothing pins a number written here, and a count in
prose is wrong more often than it is right. The surveys carry their own numbers
with their own dates attached, which is where a number belongs.

## The surveys, and where each book stands

One file per book, named by its slug. The slug is also the
`.cache/books/<slug>/` directory and the key in `scripts/books.json`: all
three are the same word. **`ls` this directory for the list.** This section
used to be a table titled *The ten surveys*, and by 2026-09-24 it had fallen
far behind the files beside it.

**Each survey's first line under its title is its status**, and that line is
the only place a book's status is written:

```
**Status:** `imported` — a short note. (2026-09-24)
```

| status | means |
|---|---|
| `cached` | registered and cached; no survey yet |
| `surveyed` | surveyed; nothing from the book's plan has shipped |
| `importing` | some of the plan has shipped, and more is planned |
| `imported` | the plan is done; what was left out on purpose is in the survey |
| `excluded` | surveyed and deliberately not imported; the survey says why |
| `backfilled` | rows arrived before surveys existed and no full inventory has been taken, so how complete the import is is not known |

**The line after it is the book's row count**, per table, in a database built
from the repo:

```
**Rows citing this book:** classes 12, gear 40, notable_npcs 2, creatures 25
```

`test/regression.mjs` checks it against a clean build, and a wrong line fails with
the line to paste. **Update it in the PR that adds the rows.** It replaced the
catalog totals in `docs/operations.md`, which every import moved. This is the
one number in these files that is pinned; see *No counts* above for the rest.

**Why here, and only here:** until 2026-09-24 the status sat in a table in
`BOOK-INGEST-QUEUE.md`. Two book sessions running in parallel edit neighbouring
rows of that table and conflict. The table also disagreed with the surveys:
`mystic-russia` was recorded as `surveyed` there for eight days after its
survey said *fully imported*. A book session updates its own survey anyway,
so the status now moves in the same edit.
`apps/character-creator/test/checks/book-registry.mjs` holds every survey to
one status line in this vocabulary, and every registered book to a survey.

**Surveys here often have no inbound link from anywhere in the repo, and they
are not orphans.** `book-survey` and `class-import` both address this directory by
**slug pattern** rather than by link, so every file here is reachable by the rule
whether or not anything points at it. A link check run over this directory
reported six dead ends on an earlier date and was wrong about all six — which is recorded in
`DOCS-AUDIT-2.md` under *What was checked and found healthy*, because it read as
a defect once already.

## Where the rest of the story is

- **`BOOK-INGEST-QUEUE.md`** (repo root) — each batch's roster and the dated
  record of what was done about each book. A book's current status is its
  survey's status line, above, not the queue.
- **`BOOK-INGEST-AUDIT.md`** (repo root) — code changes the ingestion turned up.
  Where a survey says something *cannot* be stored, the reason is usually a
  numbered finding there.
- **`.cache/books/<slug>/txt/`** — the pages a survey was read from. **`txt/` is
  the cache**; `tsv/` beside it is a secondary artifact and is short for most
  books, so measuring coverage against it reports complete caches as empty.
