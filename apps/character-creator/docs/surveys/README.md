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

## The ten surveys

The slug is the file's name, the `.cache/books/<slug>/` directory, and the key in
`scripts/books.json`. All three are the same word.

| slug | book | surveyed |
|---|---|---|
| [`bom`](bom.md) | Rifts Book of Magic | 2026-08-28 |
| [`cb1`](cb1.md) | Rifts Conversion Book One | 2026-08-28 |
| [`dag`](dag.md) | Palladium Fantasy Dragons and Gods | 2026-08-28 |
| [`fom`](fom.md) | Rifts World Book 16: Federation of Magic | 2026-08-28 |
| [`ju`](ju.md) | Rifts World Book 10: Juicer Uprising | 2026-08-28 |
| [`pf`](pf.md) | Palladium Fantasy RPG Main Book | 2026-08-28 |
| [`phase-world`](phase-world.md) | Rifts Dimension Book 2: Phase World | 2026-08-28 |
| [`potm`](potm.md) | Rifts Conversion Book Two: Pantheons of the Megaverse | 2026-08-28 |
| [`rue`](rue.md) | Rifts Ultimate Edition | 2026-08-28 |
| [`ww`](ww.md) | Rifts Dimension Book 1: Wormwood | 2026-08-27 |

**Six of these ten have no inbound link from anywhere in the repo, and they are
not orphans.** `book-survey` and `class-import` both address this directory by
**slug pattern** rather than by link, so every file here is reachable by the rule
whether or not anything points at it. A link check run over this directory
reports six dead ends and is wrong about all six — which is recorded in
`DOCS-AUDIT-2.md` under *What was checked and found healthy*, because it read as
a defect once already.

## Where the rest of the story is

- **`BOOK-INGEST-QUEUE.md`** (repo root) — the `cached → surveyed → imported`
  ladder, and which books are where on it. A survey says what a book holds; the
  queue says what has been done about it.
- **`BOOK-INGEST-AUDIT.md`** (repo root) — code changes the ingestion turned up.
  Where a survey says something *cannot* be stored, the reason is usually a
  numbered finding there.
- **`.cache/books/<slug>/txt/`** — the pages a survey was read from. **`txt/` is
  the cache**; `tsv/` beside it is a secondary artifact and is short for most
  books, so measuring coverage against it reports complete caches as empty.
