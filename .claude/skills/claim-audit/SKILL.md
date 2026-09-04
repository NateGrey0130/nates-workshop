---
name: claim-audit
description: Check what this repo says about itself against what it does — README sentences, code comments, class markdown prose, and the counts pinned in the test suite. Use when auditing, when a doc feels stale, before trusting a comment that explains why something cannot be done, and after any change that lifts a limitation something else describes. Covers where the claims are, how to find the false ones, and why a note about a fixed bug is worse than no note.
---

# Auditing what the repo claims about itself

This repo explains itself unusually well, and that is the hazard. A README and
thirteen topic files under `docs/`, comments that argue their case, and class
markdown carrying `extraction_notes` about what the app cannot do — all of it
written when it was true, and none of it rechecked when it stopped being.

**A note describing a fixed limitation is worse than no note**, because the
instruction attached to it is *do not try*. Every finding below was found by
reading a sentence and then asking the code.

## Where the claims live

| where | how many | what goes stale |
|---|---|---|
| `apps/character-creator/README.md` | the spine | counts, "N of M" sentences, "the app does X" |
| `apps/character-creator/docs/*.md` | **more limitation prose than the README** | everything the README row says, and `known-limitations.md` is a whole file of it |
| code comments in `js/` **and `functions/`** | everywhere | counts of things ("offers five"), and "cannot express" |
| class markdown in D1 | a couple of sentences per published class | `extraction_notes` saying the schema cannot hold something |
| `docs/rules-audit.md`, `docs/plans/` | | superseded by later work; the plans README says so |
| `.claude/skills/`, `.claude/agents/`, `CLAUDE.md`, `~/.claude/.../memory/` | the skills, their reference files, one agent | the same two shapes as everything above — **and these are the files that TELL you what to believe** |

**The instruction layer is in scope, and it was the last place anyone looked.**
Five of `SKILL-AUDIT.md`'s findings were sentences inside `.claude/` that a
`claim-audit` pass would never have opened, because this table did not list them.
A wrong sentence in a skill is worse than a wrong sentence in the README: the
README describes the app, and a skill tells the next session what to do. Memory
is worse again — no grep of the repo reaches it.

**The `docs/` row is the one this skill kept missing.** The README was split into
a spine plus eleven topic files on 2026-08-26 (PR #309) — thirteen now — and the
command below was written the day before and not touched again, so for a week it
searched the spine and skipped the majority of what it hunts. A file named
`known-limitations.md` is precisely the shape described two sections down as *the
expensive one*, and the skill's own search could not see it.

**Sizes and class counts are deliberately not given here.** This table used to
say "~4,600 lines" and "~190 sentences over 76 classes"; by 2026-08-25 the README
had passed 5,600 lines and the catalog 88 classes, and a skill about stale claims
that carries stale claims is the worst possible advertisement. Count them when
you need the number.

**Removing them from the table was not enough, which is the lesson.** The line
count survived three lines above this paragraph, in the opening sentence, and the
sentence count survived in *When not to* at the bottom: the fix was applied where
the number had been noticed rather than to the file. Both were still standing on
2026-09-02, by which time the README had been **split** (PR #309) and was under a
thousand lines — the figure was out by nearly a factor of five, in the skill
whose subject is exactly that.

**Grep the whole file for a number you are deleting, not just the paragraph you
are editing** — and do not restate the deleted wording anywhere, or the grep that
should find the next copy finds your note instead.

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

That returns a couple of hundred hits. **Most are fine** — they describe the book
against the schema and both are stable. What you are looking for is the subset
that describes a *limitation*, because those are the ones a later change can
falsify — and this repo falsifies them regularly: the `bonus` key on a
related-skill category turned "the format cannot hold a per-category percentage"
from true into false across four classes in a single PR.

**The README and comments:**

```bash
grep -rn "currently\|does not\|cannot\|has no\|is not modelled\|not modeled" \
  apps/character-creator/README.md apps/character-creator/docs/ \
  apps/character-creator/js/ functions/ | head -60
```

**All four paths, every time.** Dropping `docs/` or `functions/` is not a
narrower search, it is a search that misses most of the corpus — and both
omissions were invisible because what came back still looked like a full result.

When a hit needs its surrounding section, take the section, not the file:
`node scripts/readme-section.mjs "<heading>"` prints exactly one, bounded by
the next heading of any depth (no arguments prints the index). **It indexes
`docs/` as well as the README**, so a heading from either answers the same way.
Auditing a sentence never requires the thousands of lines around it — the
efficiency audit counted 37 full reads of this README in one season, and the
audit session itself was responsible for seven of them.

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

**Re-verified against production on 2026-09-02 and written up as a fixture:**
`reference/negatives.md`. Score a sweep with it — a proposed edit to any of
those sentences is a failure however good the rest of the pass was. Two things
that check turned up. The axe claim is in **six** class records, not the two
named above, and two of those phrase it as a compound that also asserts Siege
has no row — a sweep can get Large Axes right and still have answered half the
question. And the *"twelve poisons"* figure two lines up does not reproduce by
a name match on `gear`, which returns eight.

Two shapes repeat, and they are worth recognising on sight:

1. **A count in prose.** *"offers five"*, *"two Palladium O.C.C.s"*, *"the
   exception"*. Nothing recomputes these and nothing fails when they move.
2. **"The app cannot do X."** True on the day, and nobody goes back when X is
   built. These are the expensive ones: the Merc Soldier's cost a player seven
   skills, not a paragraph.

**Each shape has its own subagent, and the split is the point.** Neither has
write tools, so neither can "correct" a sentence it misread:

- shape 1 → **`claim-count-verifier`** (`sonnet`). Volume work — go count it.
- shape 2 → **`claim-capability-verifier`** (`opus`). Low volume, high cost of
  error, and every expensive miss above came from here.

**Hand them claims, not a corpus.** Bound each hit with
`scripts/readme-section.mjs` first; a whole-file read is what `EFFICIENCY-AUDIT`
`F4` measured and closed.

**They are scored against `reference/negatives.md`** — three claims that look
stale and are true, across six class records. An agent that proposes an edit to
any of those six sentences has failed the sweep however good the rest of it was.

**Do not hand that fixture to the agent.** It is the answer key; an agent that
has read it cannot be scored, and the score is the only reason to trust the
sweep. The file carries its own scoring rules and the result of the last run.
It measures **precision only** — a pass that touches nothing scores clean — so
pair it with a claim you know to be stale before believing a number.

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

## A MEASUREMENT keeps. A CLAIM ABOUT NOW rots. Tell them apart before deleting

Not every number is a liability, and stripping the good ones makes a file
weaker. The test is the tense and the date, not the digits:

| shape | looks like | fate |
|---|---|---|
| **measurement** — past tense, dated | *"N spells came back one level too high"*, *"local held N skills where production had M"* | keeps forever |
| **claim about now** — present tense, undated | *"an N-line README"*, *"N scripts follow this shape"*, *"X is the only book that does Y"* | wrong within weeks |

The measurements are the strongest sentences in the files they sit in: they are
the evidence for a rule, and evidence does not expire. The claims were all true
when written.

*(The examples above are deliberately paraphrased. Reprinting the exact wording
of a claim you deleted defeats the grep that should find the next copy of it —
see the second rule below, which this table would otherwise break.)*

So: **date a measurement and keep it. Replace a claim with the shape.** *"Most
corrections follow this pattern"* cannot rot; *"Fifteen do"* did, by a factor of
five.

Two rules that fall out of it, both learned the expensive way:

- **Grep the whole file, not the paragraph.** `claim-audit` deleted its own
  counts from one table and left the same figure standing three lines above and
  again at the bottom — the fix went where the number had been noticed rather
  than to the file.
- **Do not restate the wording you are replacing.** A note quoting the old
  phrase defeats the grep that should find the next copy. Describe what the
  sentence said; do not reprint it.

**The three skills that state this rule are the three that broke it.**
`claim-audit`, `ship-pr` and `schema-change` each say some version of *do not
quote a moving number* — and on 2026-09-02 the live breaches were in
`claim-audit`, `class-import` and `book-survey`. Each of the three had fixed its
own file after being burned and none had looked at the others'. Being the author
of the rule is not evidence of following it.

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

Do not turn an audit into a rewrite. Most of the class prose is correct and
carefully argued, and the sentences describing a book against the schema will
still be true in a year. Read for the two shapes above, check those, and leave
the rest alone.

And keep a behaviour change out of a documentation pass. Seven classes offering
the whole Technical category where the book says "two languages of choice" is a
real defect found by this audit — and correcting what seven published classes
*offer* is its own change, with its own blast-radius measurement, not a line in a
docs commit.
