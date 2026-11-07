# Why plan-rows' rules exist

`SKILL.md` states the rules and keeps every ruling of Nate's with its date and
the option he did not take; this holds the measurements and incidents behind
them, moved out so that the record is not loaded every time a driver re-reads
the skill. Each section below is named for the one it came from, and the text
is moved unchanged, except where a sentence was split (the Sonnet yardstick
and row 32a, reworded only to stand alone) and where a dated note under it says
otherwise. Read an
undated claim as true on the day it was written.

## Where a plan is stored: `state.md` is six lines

Measured 2026-10-18: the file had grown to 16KB in five lines, and every
worker and every driver re-read it.

## Before a brief is written, 5: the 400 KB reading set

Measured 2026-10-22: 60 of 204 workers hit the cap, and the 48 rows the
outstanding-work plan planned ran as 107 briefs.

## Before a brief is written, 6: a book row is two rows

Every book row's first worker capped in the 2026-10-20 book-imports plan (ten
rows).

## Starting the driver: the Sonnet trial's yardstick

The trial is judged against the 0.72M per merge the Opus drivers measured on
2026-10-22: a driver's context is almost all session start, and it reads
reports, never code.

## Driving the chain, step 3: pull before drift-check

Row 32a, 2026-10-14: after a data row, an un-pulled `main` printed
`RUN BUT NO FILE` for the script just merged.

## Driving the chain, step 4: the driver's local D1

Measured 2026-10-19: rows 46a1, 46b and 46c1 applied migrations 091 to 093 to
production and to their own copies only, and five of the next seven workers'
copies failed smoke's *Migration state* and served the creator a 500.

## Driving the chain: a capped row with only the CI wait left

Measured 2026-10-19: rows 48a and 48b each stopped at the cap with their work
committed and suites green, and each then cost a split agent (about 87k) and a
resume worker (about 60k) to open a pull request and watch it.

## Driving the chain: the post-merge line below 150k

Below 150k the post-merge line is nothing: it fires from 100k today (PR #1854
raises it to 150k), which a driver reaches before its first row, and five
drivers that obeyed it there each handed off after one merge and the next paid
a fresh start (2026-10-18).

Note, 2026-11-06: #1854 has merged. `.claude/hooks/session-budget.mjs` has
`WARN_AT = 150_000` as the merge boundary, so the line fires from 150k, and the
100k above is history.
