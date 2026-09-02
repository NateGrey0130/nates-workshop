# Multi-book ingestion — prompts

Three prompts. Run **A** once, then **B** once per book (one session each),
then **C** when every book is cached and imported.

Books are handed over by dropping the PDFs in `C:\Users\natha\Downloads` and
naming the exact filenames in prompt A.

---

## A. Kickoff (run once, one short session)

> Repo is `C:\Users\natha\Projects\nates-apps` — read its `CLAUDE.md` first,
> it does not auto-load from Downloads.
>
> I'm ingesting a batch of seven Rifts sourcebooks. The PDFs are in
> `C:\Users\natha\Downloads`:
>
> | file | proposed slug | note |
> |---|---|---|
> | `Rifts- World Book 5 Triax and the NGR.pdf` | `triax` | **already in `books.json`** — update the stub, do not add a key |
> | `Rifts- World Book 7 Underseas.pdf` | `underseas` | new |
> | `Rifts- World Book 14 New West.pdf` | `new-west` | **already in `books.json`** — update the stub, do not add a key |
> | `Rifts- World Book 15 Spirit West.pdf` | `spirit-west` | new |
> | `Rifts- World Book 18 Mystic Russia.pdf` | `mystic-russia` | new |
> | `Rifts- World Book 22 Free Quebec.pdf` | `free-quebec` | new |
> | `Rifts- Dimension Book 2 Phase World.pdf` | `phase-world` | new |
>
> `triax` and `new-west` already exist as registry entries with
> `source_pdf: null` — one gear row and one skill row cite them. Fill in
> `source_pdf`, `source_pdf_dir`, `printed_pages` and `page_offset` on the
> existing entries and keep their existing `aliases`; those aliases are the
> live vocabulary those two rows are matched by, so removing one silently
> unresolves a citation.
>
> **Resolve the page counts before caching.** The file listing reports Triax at
> 734 pages, Underseas at 689 and Phase World at 640 — three to four times the
> printed length of those books, against 112-134 for the other four. Something
> is different about those three scans (duplicated pages, split spreads, a
> bundled second book). Get pymupdf's count and render a few pages to see what
> is actually there **before** committing to an OCR run, and report what you
> find. Do not trust the count in the file listing either way: it read `ju` as
> 120 pages where pymupdf read 162.
>
> Expect those same three to be scans rather than text layers — they are
> 60-70MB against 10-13MB for the others. `--probe` decides it, but if they are
> scans, say how long the OCR will take before starting it, not after.
>
> This session does the **cheap, free work only** — no extraction, no model
> calls on book text, no data scripts, no code changes.
>
> For each PDF, in order:
>
> 1. `python scripts/ocr-book.py "<pdf>" --probe` — record TEXT LAYER or SCAN
>    and the median chars/page.
> 2. Pick a slug (short, matches how the book is cited; check it does not
>    collide with an existing key in `scripts/books.json`).
> 3. `python scripts/ocr-book.py "<pdf>" --slug <slug>` to cache it. A scan
>    will take real time — say so before starting rather than after.
> 4. Add a `scripts/books.json` entry: `title`, `aliases`, `source_pdf`,
>    `source_pdf_dir`, `printed_pages`, `page_offset`. Derive the offset by
>    rendering a page and reading its printed folio — do not assume zero and do
>    not assume it is constant. Remember `read-columns.py` is 1-based and a
>    pymupdf probe is 0-based.
> 5. Run `node scripts/class-check.mjs --field-sources` (or the smoke test) far
>    enough to confirm the new cache resolves and no offset region is
>    unresolvable.
>
> ### Also in this session — rebuild the `ju` cache
>
> `.cache/books/ju/txt/` was built with raw `page.get_text()`: 148 of its 162
> pages have the two columns welded across the gutter, which is the exact
> corrupting read `scripts/read-columns.py` exists to prevent. Juicer Uprising
> is already fully imported, so this is a re-verification, not an import.
>
> ```
> python scripts/ocr-book.py "C:\Users\natha\Downloads\Rifts- World Book 10 Juicer Uprising.pdf" --slug ju --force
> ```
>
> `--force` is required and will say what it destroys. The book has a text
> layer, so the rebuild itself takes seconds. Then:
>
> 1. Re-read all 15 Juicer Uprising classes with
>    `node scripts/class-check.mjs --field-sources` against the corrected
>    cache, plus the 4 skills and 41 gear rows.
> 2. Pay particular attention to `starting_money` on the Gambler and the Juicer
>    Wannabe — both shipped wrong once (`2d6x100`, fixed in PR #280), and a
>    page-break miss and a column-weld look identical from the outside. No test
>    checks that field.
> 3. Any row that disagrees with the corrected cache is a **data** fix — ship
>    it as its own PR, separate from the `books.json` registration PR. Any
>    disagreement you cannot resolve from the pages goes in the audit menu.
>
> Report the before/after: how many of the 15 classes now trace cleanly, and
> what changed.
>
> ### Then create two files at the repo root, both committed in one PR with the
> `books.json` entries:
>
> - **`BOOK-INGEST-QUEUE.md`** — one row per book: slug, title, PDF filename,
>   text-layer/scan, PDF page count, printed pages, page offset, and a status
>   column (`cached` / `surveyed` / `imported`). This is the cross-session
>   state; every later session reads it first and updates it last.
> - **`BOOK-INGEST-AUDIT.md`** — empty numbered menu (`F1..Fn`) in the same
>   format as the existing audit menus, with a header saying it holds
>   **code changes deferred out of the book ingestion batch**, one finding per
>   change, taken one at a time later.
>
> Do not survey the contents of any of the NEW books in this session — the `ju`
> re-verification above is the only reading that happens here. Report the table
> and the `ju` result, then stop.

---

## B. Per book (one session per book — the main prompt)

> Repo is `C:\Users\natha\Projects\nates-apps` — read its `CLAUDE.md` first,
> it does not auto-load from Downloads. Read `BOOK-INGEST-QUEUE.md` and
> `BOOK-INGEST-AUDIT.md` at the repo root before anything else.
>
> This session ingests **one book: `<slug>` (`<Title>`)**. It is already cached
> and registered in `scripts/books.json` from the kickoff session. Do not touch
> any other book.
>
> Use the `book-survey` skill for the survey and the `class-import` skill for
> the classes. Follow them; do not re-invent a caching loop, a matcher, or a
> column reader.
>
> ### Phase 1 — survey (free, no model calls on book text)
>
> Inventory by structure, not prose. Report a table before extracting anything,
> covering at minimum:
>
> - **O.C.C.s and R.C.C.s** — count and printed page for each, by stat-block
>   markers (`Attribute Requirement`, `O.C.C. Skills`, `R.C.C. Skills`,
>   `Standard Equipment`), not by names in a cross-reference list.
> - **Spells / magic** — `P.P.E. Cost:` + `Saving Throw:` pages. If there is no
>   `Saving Throw:` line in the whole book, say so explicitly; that is the
>   finding, and it means no spell import.
> - **Psionic powers** — `I.S.P.` stat blocks, same rule.
> - **Skills** — new skill definitions, and where the book states them.
> - **Gear / items / vehicles / armour** — priced entries, page ranges.
> - **Anything else importable** — tables the app already models (attribute
>   bonuses, experience tables, race widenings, O.C.C. bonuses).
> - **What is setting only** — organizations, places, NPC stat blocks,
>   narrative. Name it so it is on the record as deliberately not imported.
>
> Find the book's own **authority table** for anything the descriptions do not
> state (spell level, item price, skill percentage). Read tables as **rendered
> images at 200 dpi** — a text layer gives prose, not chart geometry.
>
> ### Phase 2 — diff before extracting
>
> `node scripts/catalog-diff.mjs --remote --table <table> --entries <json>` for
> every category the survey found. **`--remote`, not `--local`** — local is
> stale. Spot-check the "missing" list by hand; roughly one in twenty is a
> false gap from a spelling or vocabulary difference. A dominant single
> substitution is a vocabulary difference, not N corrections.
>
> Report the gap before spending anything on extraction.
>
> ### Phase 3 — extract and import
>
> Batch per section the authority names, carrying that section's stated fact
> explicitly. Then run the reconciliation pass — `book-reconcile` /
> `class-check --field-sources` — before any row goes into a data script.
>
> **Read every class entry to the end, including onto the next page.** The
> Juicer Uprising import shipped two wrong `starting_money` figures because a
> reading stopped at a page break, and no test checks that field.
>
> ### Phase 4 — ship, per category
>
> Follow the `ship-pr` skill. Data scripts applied `--remote` **before** merge.
> One PR per coherent batch (classes / skills / spells / gear), not one giant
> PR. Merge as you go — do not leave branches stacked.
>
> ### THE STANDING CONSTRAINT — no code changes from this book
>
> **Do not change application code, schema, validators, or generators because
> of what this book contains.** Data scripts, `scripts/books.json`, class
> markdown and catalog rows are in scope. Anything else is not.
>
> When the book needs a mechanic the app cannot express:
>
> 1. Import the class/row with the fields the schema **does** support.
> 2. Record precisely what was dropped in that row's `extraction_notes`.
> 3. Add a numbered finding to `BOOK-INGEST-AUDIT.md` — scope, what the book
>    says, what the app cannot represent, which rows are affected, and a
>    proposed change. One finding per change; if a later book hits the same
>    gap, add its rows to the existing finding rather than filing a new one.
> 4. Keep going. Do not stop to ask, and do not implement it.
>
> Same rule for a bug you notice in passing: file it, do not fix it.
>
> ### Finish
>
> Update `BOOK-INGEST-QUEUE.md` — status, counts imported per category, and a
> one-line "what is deliberately not imported from this book". Then report:
> what was imported, what was deferred and under which finding numbers, and
> anything you are unsure you read correctly.

---

## C. Planning pass (after every book is cached and imported)

> Repo is `C:\Users\natha\Projects\nates-apps` — read its `CLAUDE.md`,
> `BOOK-INGEST-QUEUE.md` and `BOOK-INGEST-AUDIT.md`.
>
> Every book in the queue is imported. Now plan the deferred code work.
>
> 1. Verify the menu against reality before planning off it: for each finding,
>    confirm the limitation still exists and the affected rows are still
>    described correctly. Some will have been fixed incidentally; some will
>    have been filed twice under different words.
> 2. Merge duplicates into single findings, renumbering only if you say so
>    explicitly in the file.
> 3. Order the survivors by what unblocks the most parked data, and note which
>    findings need a schema change (`schema-change` skill: one column lands in
>    five places) versus which are code-only.
> 4. For each, state the blast radius — which classes/rows get backfilled once
>    it lands, and whether that backfill is itself a data PR.
>
> Give me the ordered menu. **Implement nothing** — I will take findings one at
> a time, as with the previous audit menus.
