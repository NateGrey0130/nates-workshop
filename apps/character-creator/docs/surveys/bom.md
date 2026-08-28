# Rifts Book of Magic — survey

Slug `bom`. Cached 2026-08-28 from `526065744-Rifts-Book-of-Magic.pdf`,
360 PDF pages, **text layer**, no OCR.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Surveyed 2026-08-28 for `INGESTION-AUDIT` F24.** Before that this file was a
backfilled stub and the cache was six pages.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1,
so printed folio F is `p<F+1>.txt`. `printed_pages: 352`.

**The registry was right and the manifest is the one to distrust here.**
`ocr-book.py` measured the last detectable folio as **347** and wrote that into
the manifest; the registry says **352**, and 352 is correct — printed 348-352 is
the *Index of Rifts Magic*, whose folios the text layer does not surface the same
way. This is `books.json`'s own `_doc` rule holding up in the direction it was
written for: the registry outranks the manifest's copies.

## The book had a TEXT LAYER all along, and was OCR'd anyway

`ocr-book.py --probe` reports a median of **5,411 characters a page** over
twenty samples — a healthy text layer, comparable to `pf`'s ~5,700 and nowhere
near the 400-character threshold.

The registry note called it a *sparse* text layer. It is not sparse. The whole
book now caches from it in seconds, with no OCR, no Tesseract and no cost.

Re-caching needed `--force`, and the refusal fired exactly as designed: *"bom is
cached as OCR and this run would rebuild it as a text layer, overwriting 6
page(s)."* The six OCR pages (`p090-p095`, printed 89-94) were kept aside before
forcing. They are the tail of an index page plus the start of the general
invocation descriptions.

## The book's authority table

| printed | table | states |
|---|---|---|
| **348-352** | *Index of Rifts Magic* | every spell's NAME, P.P.E. COST **and PAGE** |

**799 entries parse out of it.** This is the single most valuable thing in the
book and the six-page cache did not include it.

Entry shape is `Name (cost) p. NNN`, and the text layer splits digits — `p. 1 10`
is 110, `( 1 0)` is 10 — so numbers need their spaces stripped before use. The
`book-survey` §2 rules apply unchanged: a name is whatever precedes the **last**
parenthetical, and a cost is anything carrying a digit or Special/Varies.

**The index alone does not settle where an elemental spell is printed**, because
the book prints many spells twice — once in a Warlock elemental list and again in
the general invocations. **71 of the 231 elemental spells carry two or more index
pages.**

## Inventory

Counted by structure over all 360 cached pages.

| section | printed pages | what is there |
|---|---|---|
| **Air Warlock magic** | **57-66** | 8 level headings, Level One through Eight |
| **Earth Warlock magic** | **67-74** | 8 level headings |
| **Fire Warlock magic** | **74-81** | 8 level headings |
| **Water Warlock magic** | **82-88** | 8 level headings |
| General invocations | 89-153 | the main spell body, by level |
| classes, gear, lore | 1-56, 154-347 | one class defined, per F1's earlier count |
| **Index of Rifts Magic** | **348-352** | the authority table |
| Palladium catalogue | 353-360 | not numbered by the book |

**Earth and Fire share printed 74.** Fire's *Level One* heading sits partway down
it, so the last Earth spells and the first Fire spells are on the same page —
the case `book-survey` §5 describes, met here in the page ranges rather than in
an extraction.

### A mention is not a definition, one level down

The first pass at locating spells searched the whole book and found *Water: Calm
Waters* "defined" on pages 51 through 203. Elemental spell names **recur across
the book's other lists as full stat blocks**, not as cross-references — so the
usual test (does a `Range:` line follow within a few lines?) passes on all of
them. Only the element's own page block separates them.

A second false positive worth recording: grepping for `Level Four: Air` matched
**`Level Four: Air Doubler`**, a spell name, not a section heading.

## Classes

One class cites this book, `stone-master`. F1's earlier count found the book
defines exactly one class in 360 pages, at printed 223.

## Catalog diff

**Not run, and deliberately not.** Nothing here is an import: every row this
book is credited with is already shipped. The question F24 asks is where the
shipped rows *came from*, which is a provenance audit rather than a diff.

### What `p.71-72` actually is

**Earth Warlock spell descriptions, Level Six and Level Seven.** Roughly eight
spells across two pages. It is not an index, not a table, and not where 231
spells are printed.

The 231 spells stamped with it are **the four elemental lists in full** — Air 65,
Earth 62, Water 52, Fire 52. So a page range covering part of *one* element's
*two* levels was applied to all four elements. The stamp reaches **spells only**:
gear, skills and psionic powers carry none of it.

### Where they are actually printed

Reconciled from two independent readings — the index's stated page, and the
element block bounds taken from the level headings:

| outcome | rows |
|---|---|
| resolved to exactly one page | **209** |
| index page(s) fell outside the element block | 6 |
| still ambiguous inside the block | 1 |
| absent from the index entirely | 15 |
| **total** | **231** |

Every one of the 231 is inside the block the book prints that element in.

Six worth eyes before any repair ships. `Air: Snow Storm` indexes to **p.86**,
which is inside the **Water** block. `Earth: Magnetism`, `Earth: Suspended
Animation` and `Earth: Transference of Essence` all index to **p.74**, the page
Earth and Fire share. `Air: Calm Storms` indexes to p.143 and `Earth: Create
Wood` to p.96, both in the general invocations — so those names exist twice and
the catalog may hold the wrong one.

## Extraction plan

**Nothing is extracted from this book. Phase 4 costs nothing here.** The work is
a provenance repair over rows that already shipped:

1. **209 rows** get an exact printed page.
2. **22 rows** get their element's page range, which is true but less precise —
   the 15 the index omits, the 6 whose index page lands outside the block, and
   `Water: Calm Waters`, which the index lists at both 84 and 88.
3. The six anomalies above get read on the page before anything is written.

**Done, 2026-08-28.** All six were read, and every one resolved:

| row | reading |
|---|---|
| `Earth: Magnetism`, `Suspended Animation`, `Transference of Essence` | all three sit on printed **74**, above the *Level One: Fire* heading partway down that page. The block bound was a page short, not the index |
| `Air: Snow Storm` | printed **twice** — Air at 64 and Water at 86. The index gave the Water twin; the Air row takes 64 |
| `Air: Calm Storms` | printed at 60 in the Air block; the index's 143 is a third occurrence in the invocations |
| `Earth: Create Wood` | printed at 67 in the Earth block; the index's 96 is the invocation of the same name |
| `Water: Calm Waters` / `(greater)` | **two different Water spells**, at 84 and 88 — not an ambiguity |

Re-running the resolver with Earth extended to printed 74 moved the result from
209 exact to **222 exact of 231**. The nine that still take a range are names the
book spells differently from the catalog.

Deliberately left: the general invocations, the classes, the gear and the lore.
This book is a compilation and re-importing it would duplicate the catalog.

**The repair is its own book batch, not part of this survey** — F24 says so, and
F20 is this repo's case for not writing a repair before reading the page.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-26 | — | six pages cached (`p090-p095`) for one extraction; no survey |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `bom` registered in `books.json` |
| 2026-08-28 | [#362](https://github.com/NateGrey0130/nates-workshop/pull/362) | this file, backfilled offline as a stub |
| 2026-08-28 | [#371](https://github.com/NateGrey0130/nates-workshop/pull/371) | **all 360 pages cached from the text layer**; the authority table found at printed 348-352; `p.71-72` identified; all 231 rows located. No data changed |
| 2026-08-28 | [#372](https://github.com/NateGrey0130/nates-workshop/pull/372) | `fix-bom-elemental-citations.sql` — all **231** elemental spells re-cited: **222 to an exact printed page**, 9 to their element's range. Applied `--remote` before the PR. **THE REPAIR IS COMPLETE.** |
| 2026-08-28 | [#374](https://github.com/NateGrey0130/nates-workshop/pull/374) | `zzzz-cite-bom-invocations.sql` — the other 177, the general invocations, **all to an exact printed page**. Applied `--remote` before the PR. **`bom` is 409 / 0.** |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28, **after** the
cache was built:

```
  bom                232 / 177
```

**It read `0 / 409` before, and the CACHE alone moved it — which was the warning,
not the win.** The 231 spells scored `traceable` the moment printed 71-72 became
a page the cache holds, while still pointing at the wrong pages.

**The repair (#372) changed the citations and did not move this number at all.**
It reads 232 / 177 before and after. That is the whole lesson of this survey in
one line: the ledger was already green, and being green never depended on the
rows being right.

**A coverage ledger measures whether a citation can be checked, not whether it is
right.** That distinction was invisible while the book was uncached.

The remaining 177 are spells citing `Rifts Book of Magic` with **no page range at
all**. They are a separate, larger question this survey does not answer.

## The 177, answered — and the ledger moved this time

The general invocations, printed 91-159. `source-coverage --remote` reads
**`bom  409 / 0`** after the repair, up from `232 / 177`, and catalog-wide spells
went **268 → 445**.

**This is the mirror image of #372 and worth holding beside it.** That repair
changed 231 citations from wrong to right and moved the ledger by zero. This one
moved it by 177, because these rows had no page at all. The two together are the
whole distinction: **the ledger sees an absent citation and cannot see a wrong
one.**

### The method, and the reading that did the work

Three readings, and no row rests on fewer than three:

| # | reading | what it settles |
|---|---|---|
| 1 | the *Index of Rifts Magic*'s stated page | which page |
| 2 | the index SECTION the name is listed under, whose level must match the row's own `level` column | **which of two spells with the same name** |
| 3 | the body text carries the spell's HEADING there — the name alone on a line, followed by `Range:`/`P.P.E.` | that the page is real |

Reading 2 is the one that matters, and reading 1 alone would have been wrong six
times. The book prints **Wave of Frost at 60 (*Air* Level Three) and again at 99
(*Invocations* Level Three)**, and `Throwing Stones`, `Shatter`, `Create Wood`,
`Orb of Cold` and `Light Target` are printed twice the same way. The catalog
names the Warlock version with an `Air: `/`Earth: ` prefix and the invocation
without one; the index does not, so the section is the only thing that
distinguishes them.

Reading 3 has to be a HEADING and not a substring. `Ice`, `Seal` and `Horror`
occur in ordinary prose on many pages.

### The book disagrees with itself once

**`Warrior Horde` is `p. 158` in the index's sectioned list and `p. 159` in the
same index's Alphabetical List.** The body puts the heading on printed 159, and
159 is what shipped. This is `book-survey` §4b — two authorities checking each
other — met *inside* the authority table rather than between the table and an
extraction, which is not a case that section anticipates.

### Two traps in the checking, both mine

Neither was in the data, and both produced confident false failures:

- The first verifier built its cache filename without zero-padding, so **every
  printed page below 99 read as empty** and seven correct rows were reported as
  not found. The cluster of failures in one page range is what gave it away.
- The body prints ritual spells as `Create Golem (Ritual)` where the catalog
  name drops the qualifier — eight more false failures.

**A verification pass that fails is a claim about the verifier first.** All 177
were confirmed once both were fixed.
