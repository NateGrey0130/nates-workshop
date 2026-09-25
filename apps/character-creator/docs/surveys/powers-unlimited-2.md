# Powers Unlimited Two — survey

**Status:** `excluded` — D0 in heroes-unlimited-core.md excludes it; that is where to look before reopening it. (2026-09-24)

**Rows citing this book:** none

Slug `powers-unlimited-2`. Cached 2026-09-12 from `97891933-Powers-Unlimited-2.pdf`,
98 PDF pages, **a scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

A sourcebook for Heroes Unlimited **2nd Edition** (its own copyright page, cache
p003). **This is the book D0 turns on**, and the one D0's answer excludes. The
answer and its reasoning are in `heroes-unlimited-core.md`; the measurements are
here.

## Page offset

`page_offset: 1` — cache file page = printed folio + 1. No exceptions.

Verified by folio: **86 pages agree at +1 and NONE disagrees**, one region
p002-p097. `printed_pages` is **96**, the last page of content at cache p097
(the Hero Character Sheet); cache p098 is a house ad.

**OCR quality.** Median 5,490 chars/page, the cleanest of the three
supplements. The contents runs across two pages (cache p005-p006) and its
left-hand column loses page numbers, which is why section ranges below were
taken from the sections themselves rather than from the contents.

## The book's authority tables

| printed page | table | states |
|---|---|---|
| **7** | *Random Power Category Table* | **twenty** power categories by percentile, and which are new |
| **4-5** | *Contents*, two pages | the section roster with page numbers |
| **94-95** | *New Super Abilities* | two new major abilities, by Kevin Siembieda |
| **96** | *Hero Character Sheet* | a blank record sheet |

### The Random Power Category Table is the most important page in the book

Printed 7 states the categories number **twenty**, and says outright that the
table spans this sourcebook **and Heroes Unlimited 2nd Edition**. It excludes
three things from rolling: **Mega-Hero** and the **Crazy Hero**, both named as
optional HU2 add-ons, and this book's own **Minor Heroes**.

**Its ten non-new rows are EXACTLY the Revised core's ten categories:**

| PU2's table, not marked new | Revised core, printed 12 |
|---|---|
| Experiment, Robotics, Bionics and Implants, Special Training, Mutant, Psionics, Physical Training, Magic, Hardware, Alien | Experiments, Robotics, Bionics, Special Training, Mutants, Psionics, Physical Training, Magic, Hardware, Aliens |

That is a same-set match, and it is worth stating plainly because it cuts
against the first reading of this book: **the category roster is not what makes
PU2 hard to port.** See *Edition coupling* for what does.

**One line on this page has no home in the Revised core.** The table's P.P.E.
note gives every superbeing 6D6 P.P.E. unless its category says otherwise. The
Revised core uses P.P.E. on **zero of its 240 pages**.

## Inventory

Counted by structure over all 98 cached pages.

| section | printed | what is there |
|---|---|---|
| Expanding the concept / Determining Your Power Category | 6-7 | the twenty-category table |
| **Empowered** | 7-16 | impairment tables, bionics, three Physical Metamorphosis lines, lycanthropy, robotics, underwater |
| **Eugenic Heroes** | 17-36 | a genetic-construction budget and ~30 purchasable features |
| **Gestalt Superhumans** | 36-56 | **four** sub-types: Animal (37), Physical Human (43), Psychic Human (48), Plant (50) |
| **Imbued Heroes** | 56-58 | |
| **Immortals** | 58-65 | |
| **Personal Weapon** | 66 | |
| **Super-Invention** | 67-70 | |
| **Minor Heroes** | 71-72 | an add-on, NOT an independent character type, by its own statement |
| **Natural Genius** | 72-75 | mental disciplines |
| **Supersoldier** | 76-86 | an EXPANSION of an existing option, plus three alternative types and equipment |
| **Symbiotic Superhuman** | 86-89 | |
| **Ancient Weapons Master** | 90-93 | weapon expertise trees |
| New Super Abilities | 94-95 | **2** |
| Hero Character Sheet | 96 | |

**Twelve new power categories** (thirteen entries if the four Gestalt sub-types
are counted separately, sixteen), plus **two** new major super abilities.

### What this book has ZERO of

- **Almost no new super abilities** — **2**, against PU1's 170 and PU3's 125.
  Its categories draw their powers from other books' rosters.
- **No spells**, no spell lists.
- **No psionic power descriptions** — it has a Psychic Human Gestalt that USES
  psionics and defines none.
- **No skills or skill programs of its own.**

**So its entire value is the twelve categories.** A survey that treated this
book as "more super abilities" would have imported two rows and missed the book.

## Catalog diff

**Not run, and it would be meaningless today.** Every entry here is a power
CATEGORY — a class-shaped object. Under `heroes-unlimited-core.md`'s **D1** a
Power Category occupies the R.C.C. slot, so the comparable catalog rows are
`imported_classes`, and this catalog holds **no Heroes Unlimited class at all**
yet. There is nothing to diff against, and creating the first ten from the
Revised core has to happen before a supplement's categories mean anything.

The two new super abilities are blocked on **D3** like every other ability in
this batch.

## Edition coupling, measured

Counted over `txt/p*.txt` **excluding `*.raw.txt`**.

| measure | **this book** | PU1 | PU3 | Revised core |
|---|---|---|---|---|
| pages mentioning HU2 | **45 of 98 (45%)** | 6 of 99 (6%) | 20 of 120 (16%) | — |
| `page N of HU2` citations | **42** | 2 | 7 | — |
| `Step 6` references | **5** | 0 | 0 | — |
| `Educational Level` references | **2** | 0 | 0 | — |
| pages using P.P.E. | **15 of 98** | 2 of 99 | 3 of 120 | **0 of 240** |
| pages using M.D.C. | 7 of 98 | 1 of 99 | 0 of 120 | 2 of 240 |
| pages using S.D.C. | 63 of 98 | 61 of 99 | 63 of 120 | 108 of 240 |

**Three times PU3's coupling and seven times PU1's, on every measure.**

### The citations are load-bearing here, and that is the real finding

PU1 and PU3 cite HU2 for **reference tables** — P.S. damage and carrying,
animal damage — whose content the Revised core carries under different
pagination. Two citations and seven citations respectively.

**PU2's 42 citations are different in kind.** They name the specific super
abilities its categories GRANT: Plant Control (HU2 p.285), Energy Expulsion
(p.293), Tentacles (p.294), Nightstalking (p.236), a named Minor ability
(p.228), a named Major ability (p.247) — plus HU2 tables its categories roll on,
including Alien Appearance (p.91), Unusual Characteristics (p.159) and a bionic
feature (p.104).

**So a PU2 category cannot be transcribed until every ability it names is
resolved against a roster that does not exist yet.** Some resolve cleanly —
`Plant Control` is in the Revised core's own 38 major abilities, and Energy
Expulsion variants are in its 31 minor. Others point into HU2's roster
specifically. Each of the 42 is a lookup, and the lookups cannot be done before
PU1, PU3 and the Revised core's abilities are all in the catalog.

### The step sequence, which is narrower evidence than it first looked

PU2 writes `Step 3`, `Step 5: Alignments & Other Stuff` and **`Step 6: Other
Stuff`**. The Revised core defines five steps and stops at Step 5, *Rounding Out
One's Character*. So `Step 6` has no home.

**This was the first evidence found for the edition split and it is the weakest
of the three.** Step 5 and Step 6 here cover alignment, experience levels and
equipment — material the Revised core does carry, in its Step 5 and in the
per-category equipment lines. The mismatch is in the numbering more than in the
substance. The citation argument above is the one that actually decides it.

## Extraction plan

**Nothing, under D0's answer.** This book is excluded — see
`heroes-unlimited-core.md` for the reasoning and for what would reopen it.

If an HU2 core is ever acquired, this book becomes the most valuable of the
three, because it is the only one of the four that adds new **character types**
rather than new powers. That is also the argument for keeping the cache and the
registry entry rather than discarding them.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | [#992](https://github.com/NateGrey0130/nates-workshop/pull/992) | cached, registered in `books.json`, offset +1 verified |
| 2026-09-13 | — | surveyed in full; excluded by D0. **No data.** |

### What remains

Nothing is planned. `node scripts/source-coverage.mjs --remote` reports nothing
for this slug and is expected to keep doing so.
