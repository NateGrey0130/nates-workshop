# Powers Unlimited One — survey

**Status:** `imported` — under D0 in heroes-unlimited-core.md. (2026-09-24)

Slug `powers-unlimited-1`. Cached 2026-09-12 from
`236094939-Powers-Unlimited-1-0.pdf`, 99 PDF pages, **a scan (no text layer)**,
OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

A sourcebook for Heroes Unlimited **2nd Edition** (its own copyright page, cache
p004), surveyed against the **Revised first edition** core this catalog holds.
The edition question is **D0**, answered in
`heroes-unlimited-core.md`; this file carries the measurements it rests on.

## Page offset

`page_offset: 2` — cache file page = printed folio + 2, so printed folio F is
`p<F+2>.txt`. No `page_offset_exceptions`.

Verified by folio: **83 pages agree at +2**, one disagrees at -3 and is noise,
one region p003-p098 with no split. `printed_pages` is **95**, the last page of
content at cache p097; cache p098-p099 are Palladium house ads.

**`ocr-book.py` measured `printed_pages: 79` and it is wrong** — a max-folio
misread, the same fault the core book's `248` came from. The registry outranks
the manifest.

**OCR quality.** Median 4,960 chars/page. Entry titles survived well. Two
column-welding traps are recorded under Authority tables; both were resolved
rather than worked around.

## The book's authority tables

| printed page | table | states |
|---|---|---|
| **4-5** | *Contents*, two columns | the whole roster, one entry per line, with page numbers for whichever column OCR read last |
| **8** | *Alphabetical List of New Minor Super Abilities* | the minor roster |
| **51** | *Listing of New Major Super Abilities* | the major roster |
| **93-95** | *Quick Find* | a cross-reference index, NOT a roster - it repeats entries under alternative names |

**Two independent readings exist for both rosters**, and both were taken rather
than trusting one:

| roster | Contents | the book's own list page | agree? |
|---|---|---|---|
| minor | 125 | **125** (printed 8) | **yes, exactly** |
| major | 45 | **45** (printed 51, after un-welding) | **yes, exactly** |

### The major list page welds two columns, and the naive count is 56

Printed 51 reads as 61 candidate lines. Eleven of them are the bare prefix
`Alter Physical Structure:` and eleven more are the suffixes — `Acid`,
`Crystal`, `Lava`, `Light`, `Oil or Tar`, `Putty`, `Rubber`, `Sand`, `Shadow`,
`Vapor or Fog`, `Wood` — read as a separate column. Counted as printed they are
22 entries; they are **11**. With five lines of art noise removed and the
prefix/suffix pairs joined, the page gives **1 + 11 + 2 + 31 = 45**, which is
what the Contents says.

**The Quick Find index is not a roster and must not be counted as one.** It
lists 32 lines, most of them pointers to entries already counted under a
different name — `Weapon: Whip (see Whip Attack)`.

## Inventory

Counted by structure over all 99 cached pages.

| section | printed pages | what is there |
|---|---|---|
| introduction | 5 | — |
| new MINOR super abilities | 6-50 | **125** |
| new MAJOR super abilities | 51-86 | **45** |
| psionics | 87-95 | **21** |
| Quick Find index | 93-95 | not entries |

**Total: 191 new entries.**

### What this book has ZERO of

Each reads like a gap and is not. Checked by marker scan across all 99 pages:

- **No new power categories.** The book adds abilities to the categories that
  already exist; it defines none. This is the whole difference between it and
  Powers Unlimited Two.
- **No classes, no O.C.C.s, no experience tables.**
- **No spells** — the `P.P.E.` marker appears on **2 of 99 pages**.
- **No gear, no vehicles, no equipment lists.**

### The psionics are a different taxonomy from the Revised core's

The 21 powers on printed 87-95 are tagged **Sensitive / Healing / Super
Psionics** — the Rifts and HU2 taxonomy, which this catalog already uses. The
**Revised core** splits its 33 psionics into **Major** and **Secondary**
instead. The two schemes do not map onto each other, and that is a fact about
the two books rather than a defect in either.

| power | category | power | category |
|---|---|---|---|
| Bio-Alteration | Super | Psychic Omni-Sight | Super |
| Calm Rage | Healing | Psychosomatic Disease | Super |
| Group Trance | Super | Precognition | Sensitive |
| Intuitive Combat | Sensitive | Read Dimensional Portal | Sensitive |
| Machine Ghost | Sensitive | Remote Viewing | Super |
| Mask I.S.P. & Psionics | Sensitive | Sensory Link | Sensitive |
| Mimic Skills | Sensitive & Super | Steal Memory | Super |
| Psionic Invisibility | Super | Steal Skills | Super |
| Psychic Body Field | Super | Telemechanic Mental Operation | Super |
| | | Telemechanic Paralysis | Super |
| | | Telemechanic Possession | Super |
| | | Wound Transfer | Healing |

**The Contents names only four of these.** A survey that trusted the Contents
for this section would have reported 5 and missed 16.

## Catalog diff

### `psionic_powers`: 21 entries, **13 matched, 8 missing**

`node scripts/catalog-diff.mjs --remote --table psionic_powers`, 116 rows.

Missing: `Bio-Alteration`, `Calm Rage`, `Mimic Skills`, `Precognition`,
`Sensory Link`, `Steal Memory`, `Steal Skills`, `Wound Transfer`.

**Hand-checked, and none is a false gap.** The three that looked most likely to
be one were queried directly: production holds `Bio-Manipulation (the evil
eye)`, `Bio-Regeneration` and `Bio-Regeneration (Super)` but **no
`Precognition`, no `Sensory Link` and no `Mimic Skills` at all**. A 116-row
psionics catalog with no Precognition is a real gap and worth noting on its own.

### The 170 super abilities cannot be diffed, because there is nothing to diff against

`super_abilities` **does not exist**. It is `heroes-unlimited-core.md`'s D3,
answered in principle and not built. Until it is, not one of this book's 170
abilities can be imported — the catalog has no shape that holds a permanent
trait with a Range and a Damage and no cost and no level.

## Edition coupling, measured

The numbers D0 rests on. Counted over `txt/p*.txt` **excluding `*.raw.txt`** —
including them doubles every figure, which it did on the first pass here.

| measure | this book | PU2 | PU3 | Revised core |
|---|---|---|---|---|
| pages mentioning HU2 | **6 of 99 (6%)** | 45 of 98 (45%) | 20 of 120 (16%) | — |
| `page N of HU2` citations | **2** | 42 | 7 | — |
| `Step 6` references | **0** | 5 | 0 | — |
| `Educational Level` references | **0** | 2 | 0 | — |
| pages using P.P.E. | 2 of 99 | 15 of 98 | 3 of 120 | **0 of 240** |
| pages using S.D.C. | 61 of 99 | 63 of 98 | 63 of 120 | 108 of 240 |

**This is the least edition-coupled of the three.** It is S.D.C.-based like the
Revised core, never mentions a sixth creation step the Revised core does not
have, and never touches the Educational Level table the two editions write
differently.

**Its two HU2 page citations point at content the Revised core HAS**, at
different page numbers: P.S. damage, lifting and carrying (HU2 p.294; Revised
printed 9, *Different Applications of Physical Strength*) and animal damage
(HU2 p.251; Revised printed 111-123). That is a translation cost of two
citations, not a missing mechanic.

## Extraction plan

**D0 is answered and this book is IN.** The two halves of it are gated
differently, and conflating them is what an earlier draft of this section did:

**1. The 8 psionic powers, printed 87-95 — NOT gated on anything, and
importable now.** `psionic_powers` exists, the eight are hand-checked as real
gaps, and their Sensitive / Healing / Super categories are already this
catalog's vocabulary. This is the smallest complete unit in the whole Heroes
Unlimited batch and the natural first data PR.

**2. The 170 super abilities, printed 6-86 — gated on D3**, because
`super_abilities` does not exist. Batch by letter when it does.

*This section previously read "Gated on D3 and on D0 ... nothing here is
extractable today." The D0 half is settled, and the psionics were never gated
on D3 at all — they go in a table that has been there all along.*

Deliberately left:

- **The Quick Find index, printed 93-95** — pointers to entries already counted.
- **Nothing else.** This book is abilities and psionics end to end.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | [#992](https://github.com/NateGrey0130/nates-workshop/pull/992) | cached, registered in `books.json`, offset +2 verified |
| 2026-09-13 | - | surveyed in full; rosters confirmed by two authorities each; psionics diffed `--remote`. **No data.** |
| 2026-09-13 | [#1028](https://github.com/NateGrey0130/nates-workshop/pull/1028) | **all 170 super abilities** - 125 minor, 45 major. |
| 2026-09-13 | `af196d9` | **the NEW psionic powers**, of the 21 on printed 87-95. |
| 2026-09-18 | this PR | **OCR text repair**, `fix-super-ability-ocr-text.sql`: **81 of the 170** rows. Mostly two-digit page numbers inside the text, which the core's folio fix deliberately left alone; plus illustration junk on eight endings and the major roster (printed 51) read onto the end of `Whip Attack`. `Weapon Melding` stopped at the page turn and is completed from printed 87. Applied `--remote` before the merge. |
| 2026-09-15 | this PR | **closed out.** Nothing outstanding; the verification is below. |

### What remains

**NOTHING. This book is fully imported**, verified `--remote` 2026-09-15.

| what the survey counted | what production holds |
|---|---|
| 125 minor + 45 major super abilities | **170**, 125 minor and 45 major, every one citing `Powers Unlimited One p.N` |
| 21 psionic powers, 13 already matched, 8 new | **all 21 present**; 9 cite this book and 12 cite Rifts Ultimate Edition |
| no classes, no spells, no gear, no vehicles | nothing to import, re-checked below |

**The "8 new psionics" figure is 9 in the rows**, which is the discrepancy
`heroes-unlimited-core.md`'s ledger already records against `af196d9`'s subject
line. The rows are the authority.

**Re-checked rather than taken from this survey's own inventory**, because the
sentence that used to stand here sent a later session looking for classes that
do not exist. A marker scan across all 99 cached pages on 2026-09-15 finds
`O.C.C.`, `R.C.C.`, `Experience Table`, `Experience Levels`, `Attribute
Requirement`, `Character Class`, `Alignment:`, `Skills of Note` and `Educational
Level` on **zero pages each**. `Cost:` and `Weight:` appear nowhere; `P.P.E.` on
2 pages and `M.D.C.` on 1.

**THE SENTENCE THAT STOOD HERE WAS TRUE AND MISLEADING, and it is worth saying
why.** It read: *"`node scripts/source-coverage.mjs --remote` reports nothing
for this slug: no production row cites this book."*

<!-- claim-ok: quoting the sentence this section corrects -->
That was accurate when written and it is accurate today - and this book has held
179 production rows since 2026-09-13. `source-coverage.mjs:115` walks `gear`,
`skills`, `spells`, `psionic_powers` and `vehicles`, read 2026-09-15, and
`super_abilities` is not among them, so 170 of those 179 rows are invisible to
it. **Do not re-derive this book's state from that tool.** That is
`BOOK-INGEST-AUDIT` **F85**, filed 2026-09-14, which quotes this very sentence.
(PR #1068 cited it as F94, a duplicate filed a day later and withdrawn the same
day; F85 is the open finding.)
