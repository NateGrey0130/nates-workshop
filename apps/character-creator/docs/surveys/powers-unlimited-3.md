# Powers Unlimited Three — survey

**Status:** `imported` — under D0 in heroes-unlimited-core.md. (2026-09-24)

Slug `powers-unlimited-3`. Cached 2026-09-12 from
`793577120-HU-Powers-Unlimited-3-PAL523P.pdf`, 120 PDF pages, **OCR at 300 dpi,
psm 3 — and the only book in this registry cached with `--force-ocr`.** See
*The text layer is a trap*, below.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

A sourcebook for Heroes Unlimited **2nd Edition** (its credits page, cache
p004), surveyed against the **Revised first edition** core this catalog holds.
The edition question is **D0**, answered in `heroes-unlimited-core.md`.

## The text layer is a trap, and it is BOOK-INGEST-AUDIT F79

`ocr-book.py --probe` reports **median 5505 chars/page** against a 400-char
threshold and calls this book a clean **TEXT LAYER**. It is not. A font-encoding
fault maps a large share of glyphs to nothing, so the character count survives
and the words do not. Its credits page renders Kevin Siembieda as `Kev Sebea`,
Wayne Smith as `Waye S`, Alex Marciniszyn as `Alex acszy`.

**Neither existing detector can see it.** `corrupt_pages` hunts characters a
clean layer never makes and there are none; `substituted_digits` hunts a digit
rendered as a look-alike letter and this is not a digit fault. What survives is
ordinary letters in ordinary positions.

**Do not re-cache this book without `--force-ocr`.** A plain run takes the cheap
path, and it refuses to overwrite only because the cache kinds now differ.

Filed as `BOOK-INGEST-AUDIT` **F79** (filed as F73 and renumbered; the Nightbane
survey took F73-F78 in PR #991).

## Page offset

`page_offset: 1` — cache file page = printed folio + 1. No exceptions.

Verified by folio: **98 pages agree at +1 and NONE disagrees**, one region
p002-p113. `printed_pages` is **112**, the last page of content at cache p113;
cache p114-p120 are house ads and a Palladium order form.

**OCR quality.** Median 5,525 chars/page after the forced OCR. The major-ability
list page welds three columns — see below — and that is the one place a naive
read goes wrong.

## The book's authority tables

| printed page | table | states |
|---|---|---|
| **4** | *Contents* | the whole roster with page numbers, one entry per line |
| **6** | *Alphabetical List of New Minor Super Abilities* | the minor roster, sharing the page with the introduction |
| **24** | *Listing of New Major Super Abilities* | the major roster, in THREE columns |
| **105** | *New Random Super Abilities Tables* | replacement random tables |

**Two independent readings taken for both rosters:**

| roster | Contents | the book's own list page | agree? |
|---|---|---|---|
| minor | 46 | **46** (printed 6) | **yes, exactly** |
| major | 80 | **79** (printed 24, after un-welding) | **no — see below** |

### The major list welds THREE columns, and the Contents over-counts by one

Printed 24 sets its list in three columns, and the OCR reads them across rather
than down: the line beginning `Alter Physical Structure: Air` continues
`Force Manipulation`, which is a separate entry in the next column. Read with
Tesseract's own block geometry from the cached TSV and reassembled by column,
the page gives **79**.

The Contents gives 80. **The two were diffed by name rather than by count**, and
the difference resolves completely: 14 of the 15 apparent discrepancies are the
same entry with OCR leader noise (`Aerodynamics Se`, `IluSionS`) or a dropped
`(Reprinted)` suffix. **The one real extra is `New Random Super Abilities
Tables`** — a section heading on printed 105, not an ability.

**So the roster is 79 major abilities**, and the Contents' 80 counts a heading.

## Inventory

Counted by structure over all 120 cached pages.

| section | printed pages | what is there |
|---|---|---|
| introduction | 6 | shares the page with the minor list |
| new MINOR super abilities | 6-23 | **46** |
| new MAJOR super abilities | 24-104 | **79** |
| new random super ability tables | 105-111 | replacement tables |

**Total: 125 new super abilities.**

Several entries are marked `(Reprinted)` by the book itself — `Flight: Space`,
`Space Native`, `Machine Merge`, `Super-Regeneration`, `Superluminal Flight
(FTL)`, `Control the Void`, `Alter Physical Structure: Void`. They are reprints
from earlier books in the series, and an import must not create a second row for
one that is already held.

### What this book has ZERO of

- **No new power categories, no classes, no experience tables.**
- **No spells** — `P.P.E.` appears on 3 of 120 pages.
- **No gear, no vehicles.**
- **No M.D.C. anywhere** — the marker appears on **0 of 120 pages**, the only
  book of the four with none at all.
- **No psionics section**, unlike Powers Unlimited One.

## Catalog diff

**There is nothing to diff against.** `super_abilities` does not exist; it is
`heroes-unlimited-core.md`'s D3, answered in principle and not built. All 125
entries here are un-importable until it does.

The only diff this book could support is against **itself and PU1** — the
`(Reprinted)` entries above, plus any name that collides with one of PU1's 170.
That check belongs to the import, not to the survey, and it is recorded here so
the import does not skip it.

## Edition coupling, measured

Counted over `txt/p*.txt` **excluding `*.raw.txt`**.

| measure | this book | PU1 | PU2 | Revised core |
|---|---|---|---|---|
| pages mentioning HU2 | **20 of 120 (16%)** | 6 of 99 (6%) | 45 of 98 (45%) | — |
| `page N of HU2` citations | **7** | 2 | 42 | — |
| `Step 6` references | **0** | 0 | 5 | — |
| `Educational Level` references | **0** | 0 | 2 | — |
| pages using P.P.E. | 3 of 120 | 2 of 99 | 15 of 98 | **0 of 240** |
| pages using M.D.C. | **0 of 120** | 1 of 99 | 7 of 98 | 2 of 240 |
| pages using S.D.C. | 63 of 120 | 61 of 99 | 63 of 98 | 108 of 240 |

**Portable, on the same argument as PU1.** S.D.C.-based, no sixth creation step,
no Educational Level dependency, no M.D.C. at all. Its seven HU2 page citations
point at content the Revised core HAS under different pagination — P.S. damage
and carrying (HU2 p.294; Revised printed 9), animal damage (HU2 p.251; Revised
printed 111-123), Underwater abilities (a minor ability the Revised core lists
in its own 31).

**The one thing it does NOT carry over cleanly** is the replacement random
tables on printed 105-111: they roll on a category roster that is HU2's, not the
Revised core's ten. Those tables are excluded by D0's answer.

## Extraction plan

Gated on **D3** and **D0**, both in `heroes-unlimited-core.md`.

1. **46 minor + 79 major super abilities** from printed 6-104, batched by
   letter, once `super_abilities` exists.
2. **De-duplicate against PU1 first**, and against the book's own `(Reprinted)`
   markers. Seven entries are flagged by the book itself.

Deliberately left:

- **The random super ability tables, printed 105-111** — they roll on HU2's
  category roster. Under D0 this catalog uses the Revised core's ten categories,
  so the tables would return categories that do not exist here.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | [#992](https://github.com/NateGrey0130/nates-workshop/pull/992) | cached with `--force-ocr`, registered, offset +1 verified, F79 filed |
| 2026-09-13 | - | surveyed in full; the three-column list un-welded and reconciled against the Contents. **No data.** |
| 2026-09-13 | [#1029](https://github.com/NateGrey0130/nates-workshop/pull/1029) | **all 125 super abilities** - 46 minor, 79 major. Catalog total 364. |
| 2026-09-18 | this PR | **OCR text repair**, `fix-super-ability-ocr-text.sql`: **76 of the 125** rows, almost all two-digit page numbers inside the text, often splitting a hyphenated word. The new-major roster read onto the end of `Without Sustenance`; `Zombie Flesh`'s regeneration rate put back where the scan lifted it from. Applied `--remote` before the merge. |
| 2026-09-15 | this PR | **closed out.** Nothing outstanding; the verification is below. |

### What remains

**NOTHING. This book is fully imported**, verified `--remote` 2026-09-15:
**125 rows**, 46 minor and 79 major, every one citing `Powers Unlimited Three
p.N` - exactly the split this survey's inventory counted.

**The text layer is no longer a trap, because the cache is not the text layer.**
`.cache/books/powers-unlimited-3/manifest.json` records `"text_layer": false`
across all 120 pages, read 2026-09-15, and this survey's own page-offset section
quotes a median of 5,525 chars/page *after the forced OCR*. The F79 warning
above stands as the reason the cache is what it is; **it is not an instruction
to re-cache before reading it.**

**The two exclusions still stand and neither is outstanding work.** The random
super ability tables on printed 105-111 roll on HU2's category roster rather
than the Revised core's ten, and D0 excludes them. The `(Reprinted)` entries
were de-duplicated by the import.

**Re-checked rather than taken from this survey's own inventory.** A marker scan
across all 120 cached pages on 2026-09-15 finds `O.C.C.`, `R.C.C.`, `Experience
Table`, `Attribute Requirement`, `Alignment:` and `Educational Level` on **zero
pages each**. The three apparent exceptions are all false: the single `Character
Class` hit is a house advertisement on cache p117, outside the content range
this survey already puts at p002-p113; every `Cost:` hit is a `Personal Cost:`
or `Life Force Cost:` ability line; every `Weight:` hit is a `Maximum Weight:`
telekinesis line; and the one `Black Market` hit is the order form on p119.

**THE SENTENCE THAT STOOD HERE WAS TRUE AND MISLEADING**, exactly as its twin in
`powers-unlimited-1.md` was. It read: *"`node scripts/source-coverage.mjs
--remote` reports nothing for this slug: no production row cites this book."*

<!-- claim-ok: quoting the sentence this section corrects -->
Accurate when written, accurate today, and this book has held 125 production
rows since 2026-09-13 - because `source-coverage.mjs:115` does not walk
`super_abilities`, read 2026-09-15, and every row this book contributed is in
that table. This book is the worst case of the gap: **100% of its rows are
invisible to the coverage report.** That is `BOOK-INGEST-AUDIT` **F85**, filed
2026-09-14, which quotes this very sentence and counts the same 125 rows. (PR
#1068 cited it as F94, a duplicate filed a day later and withdrawn the same day;
F85 is the open finding.)
