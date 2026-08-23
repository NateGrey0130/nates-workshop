---
name: claim-audit
description: Check what this repo says about itself against what it does — README sentences, code comments, class markdown prose, and the counts pinned in the test suite. Use when auditing, when a doc feels stale, before trusting a comment that explains why something cannot be done, and after any change that lifts a limitation something else describes. Covers where the claims are, how to find the false ones, and why a note about a fixed bug is worse than no note.
---

# Auditing what the repo claims about itself

This repo explains itself unusually well, and that is the hazard. A 4,600-line
README, comments that argue their case, and class markdown carrying
`extraction_notes` about what the app cannot do — all of it written when it was
true, and none of it rechecked when it stopped being.

**A note describing a fixed limitation is worse than no note**, because the
instruction attached to it is *do not try*. Every finding below was found by
reading a sentence and then asking the code.

## Where the claims live

| where | how many | what goes stale |
|---|---|---|
| `apps/character-creator/README.md` | ~4,600 lines | counts, "N of M" sentences, "the app does X" |
| code comments | everywhere | counts of things ("offers five"), and "cannot express" |
| class markdown in D1 | ~190 sentences over 76 classes | `extraction_notes` saying the schema cannot hold something |
| `docs/rules-audit.md`, `docs/plans/` | | superseded by later work; the plans README says so |

Class markdown is the one people forget, because it is **in the database**, not
in the repo. It does not turn up in a grep of the working tree.

## Finding them

**The class prose**, which needs a query rather than a grep:

```bash
node scripts/q.mjs --remote "SELECT class_id, markdown FROM imported_classes WHERE status = 'published'" > /tmp/classes.json
```

then match sentences containing `the app`, `the wizard`, `the sheet`, `the
catalog`, `the validator`, `derive.js`, `parser.js`, `compose.js`, `the schema`,
`not modelled`, `cannot express`, `does not model`, `no schema field`.

That returns about 190 hits over 76 classes. **Most are fine** — they describe
the book against the schema and both are stable. What you are looking for is the
subset that describes a *limitation*, because those are the ones a later change
can falsify.

**The README and comments:**

```bash
grep -rn "currently\|does not\|cannot\|has no\|is not modelled\|not modeled" \
  apps/character-creator/README.md apps/character-creator/js/ | head -60
```

## What actually turned up

Every one of these was live, and every one had been true when written:

| claim | where | reality |
|---|---|---|
| *"12+ for Major and Master psychics, 15+ for everyone else"* | README | three tiers, not two — fixed in the code and not in the prose |
| *"the Coalition Technical Officer offers five"* | `parser.js` | seven |
| *"the Robot Pilot two"* | README | **none** — it had no `mos` block at all |
| *"MOS skills are not modeled; add them by hand"* | Merc Soldier markdown | `skills.mos` had existed for months; the class was seven skills short |
| *"a package choice the schema cannot express"* | Robot Pilot markdown | same, eight skills short |
| *"has no save key in derive.js, so it stays in prose"* | Warrior Monk markdown | the key landed two days earlier |
| *"with two Palladium O.C.C.s there is very little to restrict"* | README | twenty-five |
| *"Military: Warships & Patrol Boats is the exception"* | a skill's own reference | five such rows exist |
| *"the catalog has no individual language rows"* | 7 classes | it holds nine |
| `reference/read-columns.py` | a skill | a **fork** of `scripts/read-columns.py`, diverged completely |

A second pass, after ten more PRs, found the same two shapes and nothing else:

| claim | where | reality |
|---|---|---|
| *"All four catalogs (items, skills, spells, psionic powers)"* | `_lib/catalog.js` | **five**, and `items` was renamed to `gear` in migration 004 |
| *"the four catalogs together \| 1,653"* | README | five, 1,901 |
| *"rows, everything \| 4,143"* | README | 4,420 |
| *"all four catalogs"* | README, on `repo-vs-live.mjs` | the tool compares five |
| *"Proposals, not delivered"* | plans README | both had shipped |

The `catalog.js` one is the shape to fear: a count that was wrong AND a name
that had been renamed **twenty-two migrations earlier**, sitting in the same
sentence, in a file nobody had reason to open.

**Two claims that looked stale and were not**, checked rather than assumed:

- The Ranger's *"the catalog has no poison row"* — twelve poisons had just been
  imported, and they are `gear`. The claim is about a **skill** row, and there
  is still no poison skill.
- The Diabolist's and Summoner's *"the catalog has no Large Axes row"* — still
  true; the catalog has `W.P. Axe` and nothing else.

Both would have been "corrected" into falsehoods by a careless pass.

Two shapes repeat, and they are worth recognising on sight:

1. **A count in prose.** *"offers five"*, *"two Palladium O.C.C.s"*, *"the
   exception"*. Nothing recomputes these and nothing fails when they move.
2. **"The app cannot do X."** True on the day, and nobody goes back when X is
   built. These are the expensive ones: the Merc Soldier's cost a player seven
   skills, not a paragraph.

## The rule that makes it cheap

**When you lift a limitation, grep for the sentence that described it — in the
same change.** That is the whole discipline, and it is what PR #208 got right:
the psionic save fix included a follow-up script rewriting the four classes that
said *"the app currently derives 12"*.

## Verify, do not assume, in both directions

- **A claim can be right.** The README's *"An R.C.C. with no related or secondary
  skills is correct, not a gap"* exists precisely so nobody "fixes" it. Read the
  reasoning before acting.
- **A claim can be wrong in your favour.** `psionics_allowed` and `xp_table`
  were both reported UNMODELLED by `class-check` and both had been fully
  modelled all along — the list is hand-maintained. A false alarm's instruction
  is *delete the key*, which breaks a working field.
- **Ask production, not local.** A local database accumulates. An audit run
  against mine reported two catalog duplicates that production had merged away
  weeks earlier.

## Turning a finding into something that cannot recur

A corrected sentence goes stale again. Where the claim is checkable, pin it:

- a **count** the database can answer → `test/regression.mjs`, which builds a
  database from nothing and asks the running worker. That is where the README's
  clean-run table and the MOS package counts live.
- a **number read out of a book** → `test/smoke.mjs` as well, transcribed beside
  the code it checks. The nine rows of the Attribute Bonus Chart are pinned
  column by column against printed 16, because nothing else compared `derive.js`
  to the book — and the last time that file was wrong it was wrong in every row
  at once, applying `v - 15` to all nine and calling it "the standard Palladium
  tables".
- a **count a file can answer** → `test/smoke.mjs`. The scripts file map, the
  data-scripts table and the migration table are all pinned this way, and each
  fails on a file the docs do not name *and* on a name with no file.
- a **stale note in an applied one-shot script** cannot be edited — that is the
  rule. What must be true is that a **later-sorting** script undoes it, and that
  is what to assert.

## When not to

Do not turn an audit into a rewrite. Most of those 190 sentences are correct and
carefully argued, and the ones describing a book against the schema will still be
true in a year. Read for the two shapes above, check those, and leave the rest
alone.

And keep a behaviour change out of a documentation pass. Seven classes offering
the whole Technical category where the book says "two languages of choice" is a
real defect found by this audit — and correcting what seven published classes
*offer* is its own change, with its own blast-radius measurement, not a line in a
docs commit.
