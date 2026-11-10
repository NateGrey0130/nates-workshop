# Why claim-audit's rules exist

**Contents:**

- What actually turned up
- Where the claims live
- Finding them
- The rule that makes it cheap
- Verify, do not assume, in both directions
- A MEASUREMENT keeps. A CLAIM ABOUT NOW rots. Tell them apart before deleting

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

## Where the claims live

Moved out of `SKILL.md` on 2026-11-10, unchanged. "This table" and "this
paragraph" mean that section of `SKILL.md`.

Five of `SKILL-AUDIT.md`'s findings were sentences inside `.claude/` that a
`claim-audit` pass would never have opened, because this table did not list them.

**The `docs/` row is the one this skill kept missing.** The README was split into
a spine plus eleven topic files on 2026-08-26 (PR #309) — thirteen now — and the
command below was written the day before and not touched again, so for a week it
searched the spine and skipped the majority of what it hunts. A file named
`known-limitations.md` is precisely the shape described two sections down as *the
expensive one*, and the skill's own search could not see it.

This table used to
say "~4,600 lines" and "~190 sentences over 76 classes"; by 2026-08-25 the README
had passed 5,600 lines and the catalog 88 classes, and a skill about stale claims
that carries stale claims is the worst possible advertisement.

**Removing them from the table was not enough, which is the lesson.** The line
count survived three lines above this paragraph, in the opening sentence, and the
sentence count survived in *When not to* at the bottom: the fix was applied where
the number had been noticed rather than to the file. Both were still standing on
2026-09-02, by which time the README had been **split** (PR #309) and was under a
thousand lines — the figure was out by nearly a factor of five, in the skill
whose subject is exactly that.

## Finding them

On `scripts/retro-check.mjs`:

`CLASS-AUDIT` S4 found the first on the Godling and
`RETRO-AUDIT` R1 found five more.

## The rule that makes it cheap

That is the whole discipline, and it is what PR #208 got right:
the psionic save fix included a follow-up script rewriting the four classes that
said *"the app currently derives 12"*.

## Verify, do not assume, in both directions

On *Ask production, not local*:

An audit run against mine reported two catalog duplicates that production had merged away
weeks earlier.

## A MEASUREMENT keeps. A CLAIM ABOUT NOW rots. Tell them apart before deleting

On *Grep the whole file, not the paragraph*:

`claim-audit` deleted its own
counts from one table and left the same figure standing three lines above and
again at the bottom — the fix went where the number had been noticed rather
than to the file.

**The three skills that state this rule are the three that broke it.**
`claim-audit`, `ship-pr` and `schema-change` each say some version of *do not
quote a moving number* — and on 2026-09-02 the live breaches were in
`claim-audit`, `class-import` and `book-survey`. Each of the three had fixed its
own file after being burned and none had looked at the others'. Being the author
of the rule is not evidence of following it.
