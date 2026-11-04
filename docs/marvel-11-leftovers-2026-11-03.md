# Marvel 11-book ingestion: what is left (2026-11-03)

> **CLOSED 2026-11-04.** The fourteen items below were driven to completion by
> PRs #2082-#2120 (2026-11-03 and 2026-11-04), and the residue those PRs handed
> on was taken by the six-row plan `marvel-11-residue-2026-11-04` (PRs
> #2121-#2126, 2026-11-04). Each item's `Closed by` column names its PRs. The
> PR bodies' *What this left* sections are the record of anything smaller.
> Kept as a record only.

Books: MX2, MX3, MX4, MLA1, MLBA1, MLA2, MLA3, MSL1, MSL2, MSL3, MSL4 (255
characters, PRs #2039-#2071), the close-out (#2072-#2074) and the stray-bullet
sweep (#2075-#2081). Sources read: every PR body #2039-#2081, the eleven
surveys, the plan's `state.md`, the plan memory and the close-out notes in the
shared notes folder. Every open item was checked against `main` (3266e210),
the local cache build and, where the item is about D1, production read-only on
2026-11-03, and again against production on 2026-11-04 (`main` 28bd081a).

Not listed here because they are standing rulings: characters only, so no
adventures, items, vehicles or places; MSL3's inner-cover stat panels and
appendix are missing from the scan; the same character in two books is two
cards.

## The fourteen items

| # | Book | From | What was owed | Closed by |
|---|---|---|---|---|
| 1 | MLA1 | #2050 | The Alligator's card prose held the chapter's rat encounter ("2. Rats. Ahead, the stream..."). | #2085 (the entry ends before the encounter); production row gone 2026-11-04 |
| 2 | MLA1 | #2050 | Letter misreads: `lron`, `Kill`, bars and a backslash-f for I and If, stray tildes; 8 production rows. | #2084 (twelve text verdicts), #2109 (the proofread's twelve more); 0 rows match 2026-11-04 |
| 3 | MX2 and 13 more | #2041 | Line-end compound hyphens kept with a space (`Mutant- Communist`), 55 across 14 books. | #2089-#2106, one PR per book, verdicts read on the page (Nate: verdicts, no reader rule); the item rows #2122; the minus spacing #2121 |
| 4 | MSL1, MSL3 and six older cards | #2062, #2068 | The As printed line ended "which R+I+P does not give" whatever the field. | #2082 (the sum named by field: F+A+S+E for Health, none for an ability) |
| 5 | MSL2 | #2065 | Stygorr's Psyche misprint read "printed null Rm". | #2082 (a printed rank with no number shows as its code alone) |
| 6 | MSL2 | #2065 | The quote-mark count: row 27b reported 32 (22 apostrophes), the rows hold 27 (17 single). | No change, 2026-11-04: every quote-bearing OCR line on the character pages (PDF 6, 7, 21, 30-34) is in the rows; the extra marks are adventure prose. The pin of 17 stands. |
| 7 | MLA2 (and the class) | #2056 | No book's rows were proofread in full. | #2107-#2113: a proofread scan (dictionary misses, confusable glyphs, a hyphen and a space after a capital or a digit) over all eleven books; MX3, MSL2 and MSL3 had nothing. "In full" (every row against the page) is not planned. |
| 8 | GM sheet | #2074 | "Amazing" overflowed the Resources box at 1280 px. | #2083 (every rank name fits the four boxes at every width) |
| 9 | MX4 | #2047 | `magma-mx4:power:4` had a double space before a minus. | #2086 (two verdicts), then #2121: a reader rule for the shape in every book (202 rows, 20 books); the verdicts retired |
| 10 | MLBA1 | #2053 | The sources line read `Adventure 3-31, 32-32`. | #2087 (touching spans merge; a one-page span prints as its page) |
| 11 | MLA1-MSL4 | #2049-#2070 | The registry's `about` list did not cover 13 new fields. | #2088 (48 fields of the eight new books), #2126 (the 64 older fields, with a smoke check that every field is named) |
| 12 | All | plan memory | `extras.py` fails late on a book with no `item_pages`. | #2118 (reproduced: it rewrote `items.json` then died writing `extras.json`; it now stops before the write) |
| 13 | MLA2 | #2056 | The merged PR's title read "Import MLA2s 47 characters". | `gh pr edit`, 2026-11-03; the title reads "Import MLA2's 47 characters" |
| 14 | Housekeeping | close-out note | `.claude/worktrees/festive-hermann-122237`, an empty directory `rmdir` calls busy. | Diagnosed 2026-11-04: two orphan `python -m http.server 8831` processes (PIDs 20260 and 36692, started 2026-10-27 in that worktree) hold it as their working directory. The auto-mode classifier refused `Stop-Process`. Nate's: `Stop-Process -Id 36692,20260 -Force`, then `rmdir`. |

## The residue, and what took it

The PRs above handed on a second list. The plan `marvel-11-residue-2026-11-04`
took it on 2026-11-04 (Nate: "take the recommended resolutions, merge on
green"), one PR per row, each merged by its driver after `NO DRIFT`:

| Row | PR | What it did |
|---|---|---|
| 1 | #2121 | `body_spacing()` in `scripts/msh/npcs.py`: an em or en dash the OCR glued to a digit is a minus set against it, and no body keeps a double space. 202 rows across 22 cached `.sql` files rebuilt and applied. The option not taken: 62 text verdicts in 13 PRs. |
| 2 | #2122 | `extras.py` applies `text` verdicts to the item and location rows it writes; MA4's seven line-end breaks in those rows closed up, read on the page. |
| 3 | #2123 | MLA3's Security Robots entry reads on to printed 29 (`continues`): the run-on sentence is whole and the Knockout Gas power is its second row. MLA3 holds 214 rows over 41 entries. |
| 4 | #2124 | MHSP2's running note on Psycho-Man and Hate-Monger is Hate-Monger's `running` row, through a new registry field `split_heads` for a head hyphenated over two lines. |
| 5 | #2125 | `gridbooks.py` keeps a column's last line whole at the page's bottom cut, the fault that dropped "dian god of mischief," in ME2. Five rows in ME2 and MT2 gained words. |
| 6 | #2126 | The registry's `about` list names the 64 older fields it omitted, pinned by a smoke check. |

Settled with no PR, by instrument, 2026-11-04:

- `Cialist` and `Cialists` (MLA3): the OCR text itself capitalises them. Not a reader fault.
- Art read as a letter beside a line's end (ME3): an OCR confidence matter. Verdicts cover it; no reader rule.
- "Marvel smoke has no `--section` flag": it has, through `shared/test/harness.mjs` (`PARTIAL SMOKE PASSED (44 checks in 1 sections)` for "rank ladder").
- Kept as printed, ruling applied: MLBA1 `wallcrawl`, MSL1 `wide- angle`, MSL4 `Cl1000`, MA4 `Sub-Terraneans`, MLA2 `taki ng`.
- Decisions 3 and 4 below stay as shipped.

## Nate's decisions

Decisions 1 and 2 were taken under his ruling of 2026-11-04 (recommendations
taken): a reader rule for the minus spacing (#2121), the compound hyphens by
verdicts (#2089-#2106), and a blank printed number shown as its code (#2082).

3. **MSL1 Dominus `S N/A` (#2062):** kept as printed with no rank, as shipped. The other way was `Sh0`, as MA4's Destroyer is.
4. **MSL4 leak check vs identity (#2070):** the leak check keeps excusing a `line_identity` prose line, as shipped.
5. **The 102 survey decisions** were applied as recommended under the 2026-10-31 ruling; each survey lists them.

Two more the residue's workers took, which Nate may overrule:

6. **MT3 Thugs verdict (#2125):** retired, because with the reader fix it made the row end "long. long." and MT3's smoke check caught it.
7. **MHSP2 NOTE paragraph (#2124):** it had been read as a power named "Note"; it is now a `notes` part, so the Hate-Monger card loses that power row.

## Still open after the residue (the PRs' own hand-offs)

- **MA4 Baxter Building floor keys (printed 76-77):** six line-end breaks left as read, because the reader took those lines out of order. Reader work.
- MA4's Air-Walker Automaton and MT2's Mysterio Gas Nozzles, as #2122 and #2125 describe them; `body_top` left unmeasured in #2125.
- Item 14 above, which only a hand at the machine can finish.
- Each worker's first `gh pr checks --watch` returned early with only Cloudflare Pages listed; a second watch was needed once the Actions checks registered. A tooling note, not a fault.

## Already done before this record (2026-11-03)

| From | Item | Closed by |
|---|---|---|
| #2070, state.md | MSL4's `repeated_power_heads` was silent when off | #2072 |
| #2071, state.md | Stygorr's Matter Fluctuation bullets read as a stray `e` | #2073 |
| #2071, state.md | GM sheet: the hero ID column drew over the Points column at 1024 px | #2074 |
| #2062, sweep | Bullets read as `e` in MSL1, MSL4, MSL3, MA4, ME1, MH9, MX1 | #2075-#2081; production holds 0 stray rows over 30 books |
| #2040-#2070 | Reader fields silent when turned off, book by book | each book's data row pinned its cards, powers and blocks in Marvel smoke |
| #2053 | MH4's cached `book-text.sql` behind `main`'s build | production holds `main`'s form; the local cache was rebuilt 2026-11-04 |
| #2058 | MLA3 decision 12: Colossal Deathlok's identity | #2059 |
| #2049 | MLA1's Bartholomew Jacobs with four null rows | #2050 |
| #2051 | MLBA1 trial misreads | #2052, #2053 |
| #2063 | MSL2: Nick Fury's `Booy` misread and his quoted phrase | #2064, #2065 |
| #2115, #2116 | MH9 Super-Adaptoid's colon; MH8 Police notes' `lodse` | merged 2026-11-04 |
| #2117, #2119, #2120 | MLA1 chapter 31; the NPC generator's I.Q. fixture; the Sourcebooks lists' line ending | merged 2026-11-04 |
