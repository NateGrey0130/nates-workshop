---
name: book-survey
description: Survey a whole sourcebook PDF before importing any of it, so the import is driven by what the book actually contains rather than by the pages someone happened to open. Use when handed a full book — "here is the PDF", "what's in this book", "pull everything relevant out of it", "import the whole thing" — and before any large spell, skill, gear or class import.
---

# Surveying a book before importing it

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`), and (`book-registry.mjs`) that
> phase 3 shows the `--remote` form of `scripts/catalog-diff.mjs`. The incident
> behind each rule is in `reference/why.md`; worked cases are in
> `reference/WORKED-EXAMPLES.md`.

A whole sourcebook does not fit in one model call and should not be fed to one.
**Read the book's structure offline first, decide what is worth importing, then
extract only that.** Offline structural work is free; extraction costs money and
is the step to spend least on. Every step below exists because skipping it
produced a plausible-looking wrong answer.

## The loop

| phase | question | costs |
|---|---|---|
| 1. inventory | what kinds of content, and where? | free |
| 2. authority | what does the book state its own facts in? | free |
| 3. diff | what is actually missing from the catalog? | free |
| 4. extract | pull only the gap, batched by section | money |
| 5. reconcile | does every row agree with the authority? | free |
| 6. ship | data script, rebuild, verify | free |

Phases 1–3 routinely cut phase 4 by more than half. **Get agreement on the
survey (see *What "surveyed" means*) before spending anything.**

## 0. Does it have a text layer? Ask before you OCR

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --probe
```

It samples twenty pages, prints each one's character count, says TEXT LAYER or
SCAN, and writes nothing. **Use it, not a hand-rolled `python -c`**: the same
script writes the page-addressed cache and manifest everything else reads.
Thousands of characters a page means a text layer (no OCR, no model call, no
cost); zeros mean a scan.

A text layer's damage is typesetting, not misreading: missing spaces, a mis-set
character, a kept hyphen, a heading welded to a paragraph. It is fixed by
knowing what the value should look like, and by the book's other authority
table, not by a better reader. Cases: `reference/WORKED-EXAMPLES.md` →
*Palladium Fantasy's text layer*.

**Before extracting, read three manifest keys**, all keyed by cache page, not
folio (convert with §0d):

- `welded_pages`: both columns in one text block, so cached lines do not
  follow one another and a `Money:` line can take the far column's figure.
  Read those pages off a render. `class-check --field-sources` prints a
  `WELDED` advisory.
- `corrupt_pages` (`GLYPHS` in the output): a broken font mapping, as a
  count per page. There is no safe threshold; small counts are real damage too.
  **A page with corrupt prose is corrupt everywhere, including numbers that look
  ordinary**: render it and read the numbers off the render. Some damage is in
  the ink itself; expect both kinds.

### And there is a THIRD kind, which neither of those detectors sees

`substituted_digits` (`DIGITS` in the output): a digit swapped for a letter
that looks like it (`1` as `!` or `l`, `0` as `O` or `Q`), producing ordinary
characters the glyph detector cannot see. **Assume any Palladium text layer
has it.** The damage is in the ink, so a render does not help: read the token
as the dice expression it can only be (`!D4xlO` is 1D4x10). It reaches
starting money. Re-running `ocr-book.py` on an existing cache recomputes all
three keys in seconds without re-reading a page.

## 0b. Cache it — the SAME command either way

```bash
python scripts/ocr-book.py "path/to/Book.pdf" --slug rue
```

**Do this whichever answer step 0 gave, before anything else, for the WHOLE
book.** `class-check --field-sources` and `drift-check` read the page cache
under `.cache/books/<slug>/txt/`; without it a row cannot be traced to its page.
Then add the book to `scripts/books.json`, sorted by slug (smoke checks the
order). The cache is gitignored: it is a commercial book.

- **In a worktree, check `$WORKSHOP_OCR_CACHE`** (`echo "$WORKSHOP_OCR_CACHE"`).
  Empty means `<repo>/.cache/books`, which is right in the main checkout and
  empty in a worktree. `SETUP.md` has the table of what reads each variable.
- A text layer takes the cheap path by itself (`"text_layer": true`,
  seconds for a whole book). A scan gets Tesseract; add the table pages you
  know about:

  ```bash
  python scripts/ocr-book.py "path/to/Book.pdf" --slug rue --tables 167,200-202 --dpi-tables 500
  ```
- Re-running resumes. Switching a cache between kinds needs `--force`.
- **Do not raise the DPI when text is wrong**: OCR is confident about its
  mistakes, and higher DPI or preprocessing barely moves them. Fix meaning at
  ingest and in `scripts/ocr-fields-lib.mjs`; `--renormalise` re-applies the
  substitution table without re-running Tesseract. But do look at the page:
  failed layout analysis (a list beside line art) loses items, and a render
  (§0c) reads them.

## 0c. A cache of EITHER kind can lose a page. Render it and look

A text layer extracts prose faithfully and loses a chart's geometry: columns
arrive as disconnected runs, headers land elsewhere, silently. A scan can merge
adjacent columns or drop a list beside artwork. Every authority table that
mattered here had to be read as an image. **Render it and read it** (a
throwaway probe; nothing depends on the PNG):

```python
import pymupdf
doc = pymupdf.open(pdf)
doc[printed_page_to_pdf_index].get_pixmap(dpi=200).save('page.png')
```

200 dpi is enough for a stat block. Use rows the catalog already holds as a
check on the reading: each is an independent confirmation.

## 0d. Read the offset from the registry. Derive it only if there is none

`scripts/books.json` records `page_offset` per book, and the manifest records
what `ocr-book.py` measured. `class-check --field-sources` resolves it in this
order and prints which it used:

```
--offset            you override everything
scripts/books.json  the durable, hand-checked copy, PER PRINTED PAGE
the manifest        what ocr-book.py measured when it built this cache
live detection      majority vote over the folios, for an unregistered book
0                   and it SAYS so, rather than quietly using it
```

The offset is not always constant. `page_offset_exceptions` covers a book
whose offset changes part-way (`pf` early, `underseas` mid-book); ask the
registry who has one, not this sentence:

```json
"page_offset": 2,
"page_offset_exceptions": [ { "printed_through": 16, "offset": 1 } ]
```

With no recorded offset, render a candidate next to the page you want and
read its printed folio, then record it. `class-check --field-sources` reports
every offset region it detects and says when the registry does not describe
them, and smoke fails a cache with a region `books.json` cannot resolve.

One rule converts every base:

```
cache page = printed folio + page_offset        cache pNNN = pymupdf d[NNN - 1]
```

`read-columns.py` takes the cache page number (1-based, what a PDF viewer
shows); a `pymupdf` probe is 0-based. Mixing them lands one page early.

| printed p.16 in a book registered… | cache page | pymupdf probe | `read-columns.py` |
|---|---|---|---|
| `page_offset: 0` — `phase-world`, `triax`, `ww` | `p016` | `d[15]` | `... 16 16` |
| `page_offset: 1` — `potm` and most books | `p017` | `d[16]` | `... 17 17` |
| `page_offset: 2` — `pf` past its exception | `p018` | `d[17]` | `... 18 18` |

A zero offset is the worst case: there is then no offset to hunt, so a wrong
page reads as the book not saying what you expected. **State an offset in the
registry's base.** Read the folio at the end of `read-columns` output every
time; a single-page call prints no header, so pass the page twice.

## 0e. Extracting priced entries out of prose

Item lists are paragraphs with a price inside. An extractor finds boundaries,
not answers. Three failures put a plausible wrong number in a numeric column:

- A price wrapped across a line: `20,000-\n30,000` must stay a range. A
  hyphen BETWEEN DIGITS is never de-hyphenated.
- A long entry labels its own parts (`Duration:`, `A.R.:`, `Cost:`), each
  looking like a new item.
- **The first price in an entry is not its price.**

A book may print several items under one name, and a section may price by
band rather than per row. Check an extraction against itself where the
book prints redundant numbers (each level's low = previous high + 1).

## 1. Inventory: what is in here?

Count structure, not prose: stat-block markers per page range.

```python
PPE   = re.compile(r'^\s*P\.?\s?P\.?\s?E\.?\s*(Cost)?\s*:', re.M | re.I)   # a spell/power
CLASS = ['Attribute Requirement', 'O.C.C. Skills', 'R.C.C. Skills', 'Standard Equipment']
```

**A mention is not a definition**: search for the stat block, never the name.
**Report the inventory as a table before extracting anything.**

## 2. The authority table

Find where the book states the fact a description cannot give you, such as
a spell's level, stated once in a section heading or a master index. The index
is the single most valuable page; spend passes on it.

Read it geometrically. Columns do not come out of `get_text()` in reading
order. Use `scripts/read-columns.py` (columns split on the gap, full-width
blocks first as headings, a page range):

```bash
python scripts/read-columns.py "book.pdf" 189 191
```

A scan has no text layer: let Tesseract do the layout analysis and group by
its blocks, never reconstruct columns from raw x coordinates
(`reference/WORKED-EXAMPLES.md` → *Reading a column index off a SCAN*):

```
tesseract page.png out --psm 3 tsv     # then group rows by block_num
```

- **Probe the parse against three or four facts you can verify independently.**
  A subtly wrong reader looks exactly like a working one.
- Be generous about what an entry looks like: a cost is anything carrying a
  digit or *Special*/*Varies*; a name is whatever precedes the last
  parenthetical. Strict patterns silently drop rows.
- Find a heading by looking BACKWARDS from the field that is always there,
  with every other field name in the stop list.
- **Names come from the index, not the headings.**
- `scripts/parse-pf-spell-index.mjs` and `parse-pf-spell-descriptions.mjs` are
  worked examples, hard-coded to one book: copy the rules, not the scripts.

## 3. Diff before you extract

**Use `scripts/catalog-diff.mjs`. Do not write another matcher**; every
hand-rolled one here was confidently wrong.

```bash
node scripts/catalog-diff.mjs --remote --table psionic_powers \
     --entries book-entries.json --compare category,isp
```

**`--remote` when the answer will be spent against** (`CLAUDE.md` → *Three
things that fail late*); a local run prints production's count beside its own. The matching rules live in `scripts/catalog-match-lib.mjs`.

- A dominant single substitution is a vocabulary difference, not N
  corrections (the book's "Super-Psionics" is the catalog's "Super").
- **A small edit distance is not permission to merge.**
- Normalise both sides (lowercase, `&`→`and`, strip punctuation) and
  hand-check the "missing" list: OCR-mangled names are false gaps.
- Query the whole table and filter in the diff; rows are tagged
  inconsistently (`system IS NULL`).

## 4. Extract, batched by what the book states

**One batch per section the authority names**, carrying that section's fact
explicitly:

```
level: 7,
hints: 'Every spell in these pages is a level 7 invocation.
        Do NOT infer a level from the text; use the level given.'
```

Necessary, not sufficient (phase 5). Keep batches small: a reply that
overruns the output ceiling is rejected. **Re-run
`node scripts/catalog-diff.mjs --remote` for that batch right before writing its
data script**: another session may have shipped the same rows since, and a
second `INSERT OR IGNORE` is silently dropped.

A book too big for one pass fans out to `book-extract-worker`, one per
slice. It cites the printed folio and does not map to catalog vocabulary.
Give each worker one page beyond each end of its range, and say slice
edge, not boundary, when briefing it. **Fanning out does not skip phase 5.**

## 4b. A book may ship TWO authorities, and they check each other

**Look for a second index before parsing the first.** Two tables (and an
entry's own stat block) give independent readings of every value. Reconcile them
by name with the catalog diff's normalisation, plus a tiny explicit alias list
for names the book spells differently between its own tables; never lower the
edit-distance bar instead. (`reference/WORKED-EXAMPLES.md` → *Two authorities*.)

## 4c. When a description page argues with the index

The index usually wins, and the losing reading is recorded in
`variant_note`. But find out which is wrong first: count independent readings,
and ask whether the disputed value is the right size for where it sits.
(`reference/WORKED-EXAMPLES.md` → *The Finger of Lictalon*.) A field a chapter
states only a handful of times marks those entries as a category of their own.

## 5. Reconcile — the step that is easiest to skip

**Hand this to `book-reconcile`**, which has no write tools and did not write
the parse. **Check every extracted row against the authority, not a sample.**
Section headings sit partway down a page, so a batch's first page carries the
previous section's tail, stamped with the wrong fact. The index is the
authority; page position is not. Also:

- A failed probe is a question, not a verdict: find out who is wrong.
- Two independent readings of every number (stat block and index).
- A row straddling a BATCH or SLICE edge loses its far side: look for cost 0
  with no note. A page break inside one range is harmless.
- Anything the authority does not list needs eyes, not a guess.

## 6. Ship it

A data script, per `class-import` (production is behind Access, so the import
UI cannot reach it). Creatures and notable NPCs go from reconciled JSON to
their script through `node scripts/bestiary-sql.mjs`, not a generator
rebuilt in the scratchpad; its header gives the JSON shape. The same holds for
vehicles with their locations and weapons (`node scripts/vessel-sql.mjs`) and
for flat catalog rows - spells, gear, skills, psionic powers, enchantments
(`node scripts/rows-sql.mjs`), both as `<worker-json-dir> <out.sql>`; each
header gives its JSON shape, each has a `--self-test` and refuses to overwrite
a file that exists (BOOK-INGEST-AUDIT.md F124). No check enforces their use,
and that is not leave to write your own, retyped from memory or by hand: when
one refuses the input, the JSON is what gets fixed. **Delete the rows and re-apply the script from scratch**:
the script is what ships, not the review's leftovers. Then
`node scripts/drift-check.mjs --remote`, and drive one real user path in the
browser: a picker offering the new rows is the only proof they are reachable.

## 7. Persist the survey — it is the next session's boot file

Write `apps/character-creator/docs/surveys/<slug>.md` from
`.claude/skills/book-survey/reference/SURVEY.md`. It is tracked and ships with
the work. It holds the inventory, authority pages, offset, catalog diff with its
hand-checked false gaps, the agreed plan, and a progress ledger: one line per
PR, written in that PR before it opens and citing its branch (see
`class-import` → *A batch outlives the session on purpose*).

**Read the offset from `scripts/books.json`**, and paste "what remains" from
`node scripts/source-coverage.mjs --remote`, never a count you did yourself.

### It states facts about the book. It quotes no prose from it

Page numbers, offsets, counts, names, ranges, table locations and diffs are
facts about the book, and they are all the next session needs. Paraphrase a
rule and cite the page. Smoke fails a markdown blockquote in
`docs/surveys/*.md`, but cannot see an italic inline quote: **the check is a
floor, not the rule.**

Start a fresh session every 2–4 PRs, booted from the survey plus
`git log --oneline -15`. The caches do not travel; the survey does.

## 8. A BATCH: where each book's state lives, and running two at once

A batch's roster and decisions live in `BOOK-INGEST-QUEUE.md`; a book's status,
row count and ledger live in its own survey. One session per book, and one
worktree per book: `node scripts/book-worktree.mjs <slug>`. Import what the
schema supports, file the gap in `BOOK-INGEST-AUDIT.md` and keep going: **do
not stop to implement.** **Data ships with its book; UNASKED-FOR code waits**:
the three tiers of what "no code from a book" forbids are in
`reference/batches.md`, and that is the copy that governs. **Read
`reference/batches.md` before running a batch or two books at once.**

## What "surveyed" means

- an inventory table of the book, by chapter, with counts
- the authority table parsed, and probed against facts known independently
- a diff against the catalog, hand-checked for false gaps
- a stated plan of what will be extracted and what will be left, with reasons
- all of it in `apps/character-creator/docs/surveys/<slug>.md`, committed, not
  just said in chat

Get agreement on that before spending anything.
