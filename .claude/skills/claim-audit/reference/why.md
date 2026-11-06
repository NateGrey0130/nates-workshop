# Why claim-audit's rules exist

`SKILL.md` states the rules; this holds the findings behind them, moved out
of its *What actually turned up* so that one audit's record is not loaded on
every call of the skill. Read an undated claim as true on the day it was
written.

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
