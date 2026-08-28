# Book-ingestion batch — queue, opened 2026-08-28

Seven books handed over on 2026-08-28, cached in one kickoff session. This file
is the cross-session state: **one session per book** from here, each reading
this file first and updating it last. Deferred code changes go in
`BOOK-INGEST-AUDIT.md`, not here.

Slugs, offsets and printed page counts below are recorded in
`scripts/books.json`, which is the authority the tooling reads. This table is
the human view of the same thing plus the import status.

## The books

| slug | book | PDF pages | layer | printed | offset | status |
|---|---|---|---|---|---|---|
| `triax` | Rifts WB 5: Triax and the NGR | 225 | SCAN (OCR) | 222 | **+0** | cached |
| `underseas` | Rifts WB 7: Underseas | 216 | SCAN (OCR) | 214 | **+0 / -1 split** | cached |
| `new-west` | Rifts WB 14: New West | 226 | text layer | 224 | +1 | cached |
| `spirit-west` | Rifts WB 15: Spirit West | 210 | text layer | 208 | +1 | cached |
| `mystic-russia` | Rifts WB 18: Mystic Russia | 178 | text layer | 176 | +1 | cached |
| `free-quebec` | Rifts WB 22: Free Quebec | 194 | text layer | 192 | +1 | cached |
| `phase-world` | Rifts DB 2: Phase World | 209 | SCAN (OCR) | TBD | TBD | queued |

Status is `cached` -> `surveyed` -> `imported`. Nothing here is surveyed yet:
the kickoff session caches and registers only, by design.

**`triax` and `new-west` were already registry stubs** with `source_pdf: null` —
one gear row cites Triax, one skill row cites New West. Their entries were
filled in, not created, and their existing `aliases` were kept: those aliases
are the live vocabulary those two rows resolve through.

**Those two rows still cannot be traced, and caching did not fix it.** Both cite
their book with no page number at all — `gear.Triax Pump Weapon` says
`Triax & The NGR`, `skills.W.P. Rope` says `Rifts New West`. Caching moved them
out of `not-cached` and straight into `no-page-range`, which is the same
untraceable in a different bucket. **Give each a page range in its own book's
session**, now that there is a book to find it in; it is the cheapest task
either session has and it closes the only two rows those books own today.

## What the kickoff session established

**The page counts in the file listing were wrong.** It reported Triax at 734
pages, Underseas at 689 and Phase World at 640 — three to four times their real
length. pymupdf reads them as 225, 216 and 209. Believe pymupdf; this is the
same disagreement `ju` showed in the other direction (listing 120, pymupdf 162).

**Three of the seven are scans.** They are also the three large files (60-70MB
against 10-13MB), and the correlation held exactly. The four text-layer books
cached in seconds; the scans needed ~650 pages of Tesseract.

**`triax` has a ZERO offset** — printed N is cache `pNNN`, `read-columns.py N+1`.
The third book here with one, after `potm` and `ww`. Verified by folio rather
than assumed: 177 pages agree at +0, 1 at +1. The skill's warning applies — a
zero offset leaves no discrepancy to explain when a page reads wrong.

**The other four measured +1 and were verified the same way** — 198/3,
190/2, 157/0 and 165/4 pages agreeing. The handful of disagreements are all
contents and index pages, which print many numbers and defeat a
"short line of digits is the folio" heuristic. None is a real offset conflict.

## The `ju` cache rebuild — done, and what it found

`.cache/books/ju/txt/` was raw `page.get_text()` with columns welded across the
gutter on 148 of 162 pages (INGESTION-AUDIT F2). Rebuilt 2026-08-28 with
`--force`; all 162 pages changed. Re-verification against the corrected cache:

- **16 classes** cite the book. All parse clean (0 errors, 0 warnings) and all
  resolve onto their cited pages.
- **All 16 `starting_money` values confirmed**, including the four the book
  states in prose rather than on a `Money:` line. The two figures fixed in
  PR #280 (Gambler `6d6x10`, Wannabe `5d6x100`) both match the book.
- **42 gear rows confirmed** — every `cost` and `mdc` present on the cited
  pages. The three that did not match a digit string are prices the book writes
  in words: 1.1, 3.2 and 3.6 million credits.
- **All 12 of the book's new skills accounted for** — the 4 imported plus the 8
  RUE absorbed, each matched by value as well as name (`Technical: Juicer Lore`
  is the catalog's `Lore: Juicers`, RUE p.302-303).
- **One real error found**, and it is column-weld damage:
  `Juicer Uprising p.66 lists 30%+4%` sat on **Gambling (Standard)**, which the
  book gives as 30%+5% — identical to RUE, no disagreement at all. The 30%+4%
  belongs to **Gambling (Dirty Tricks)**, which RUE gives as 20%+4%. In the old
  cache that line sat in the right-hand column two thirds of a page above its
  own entry. Fixed by `zzzzz-fix-ju-gambling-notes.sql`.

The rebuild was worth doing and the yield was one row. That is the honest
figure; it is not an argument that the other caches are fine, and it is not an
argument that they are worth re-reading either.

## Per-book rules for the sessions that follow

- Survey first, diff second, extract last. `catalog-diff.mjs --remote` — local
  is stale.
- Read every class entry **to the end, onto the next page**. Both ju
  `starting_money` errors were page-break misses.
- Read tables as rendered images at 200 dpi. A text layer gives prose, not
  chart geometry.
- Data PRs merge as they go, applied `--remote` before merge. Nothing stacks.
- **No application code, schema, validator or generator changes from a book.**
  Import what the schema supports, note the drop in `extraction_notes`, file the
  gap in `BOOK-INGEST-AUDIT.md`, keep going.
