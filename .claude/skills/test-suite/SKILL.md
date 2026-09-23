---
name: test-suite
description: Add or change a check in this repo's test suites without writing one that cannot fail. Use when adding a test, pinning a count or a claim, reading a failure, deciding which suite a check belongs in, or splitting a checks module — "add a check for this", "pin that number", "why did smoke fail", "write a test" — and when writing or changing a skill, which is pressure-tested before it ships. Covers the five suites and which three gate a merge, why a section list is declared twice, why regression truncates instead of filtering, and the ports that let another worktree answer for yours.
---

# Adding a check

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing** — read an undated claim here as true on
> the day it was written.

A seventh of the commits here touch these suites. They are the mechanism the
repo uses instead of remembering things, so the cost of a check that cannot fail
is not zero — it is a green tick that retires a real rule.

**Make it fail before you believe it.** Break the thing the check describes,
watch the check go red, then put it back. A check that has only ever passed
proves nothing about the code and everything about your regex. Inject the fault
**upstream** of the stage you doubt: a fixture edited after the parse step tests
the parser's output, not the parser.

## The suites, and which of them stop a merge

| suite | proves | gates |
|---|---|---|
| `apps/character-creator/test/smoke.mjs` | the machinery: parser, dice, composition, schema, and what the repo says about itself | **`smoke`** |
| `apps/filament-forge/test/smoke.mjs` | that app's README, its snapshot SQL, its sanitizers | **`smoke`** |
| `apps/pick3cut5/test/smoke.mjs` | which paths must sit outside the Access wall, and that they are exempted | **`smoke`** |
| `apps/pick3cut5/test/game.mjs` | all 56 reachable rounds, server budget rules against the client's copy | **`smoke`** |
| `apps/media-vault/test/smoke.mjs` | the localStorage merge planner, and that no endpoint can replace a library | **`smoke`** |
| `scripts/menu-check.mjs` | every new claim about another file says where it was read | **`menus`** |
| `apps/character-creator/test/regression.mjs` | real HTTP against real endpoints, on a D1 built from nothing | **`regression`** |
| `apps/character-creator/test/play-flow.mjs` | the play loop in a browser | reporting only |

The three bold names are required status checks on `main`. **`.github/workflows/tests.yml` runs
the first five under one job, so a job id is a check-run name: renaming a job
leaves a required check that never reports and nothing can merge.** Do not rename
one without editing the ruleset.

**CI gets no credentials, deliberately.** Every D1 call in the suites is
`--local`, which is a SQLite file the runner throws away. A write to production
here costs a deliberate keystroke, so CI is not given a token that could perform
one — which also means **nothing in these suites can test a `--remote` path.**

## Where a new check goes

- **a fact about a file** — a count, a path, a sentence, a claim one file makes
  about another → `apps/character-creator/test/smoke.mjs` or a module under
  `apps/character-creator/test/checks/`. Text checks, no wrangler.
- **a fact about the environment** — the schema, whether `db/schema.sql` alone
  builds a current database, the migration record, what Pages will compile →
  `apps/character-creator/test/checks/environment.mjs`. This is the file that
  shells out to wrangler and it is nearly all of the suite's wall clock.
- **a count the database can answer** → `apps/character-creator/test/regression.mjs`,
  which builds a database from nothing and asks the running worker.
- **anything that needs a request** → `regression.mjs`. `smoke.mjs` has never
  proved that a request works, and both production bugs in the week it was
  written lived in that gap.
- **another app's own rules** → that app's suite. They are separate so a failure
  names its app in the step list rather than inside a log.

**A check that fires on correct values is worse than no check**, because it
trains you to stop reading the output. That is the argument `class-check.mjs`
makes about its own UNMODELLED list and the reason
`scripts/retro-check.mjs` is not a capability-vs-date diff. If the shape you
want to catch has a meaningful unset default, you are probably writing a report
rather than a gate.

## The harness, and the two things it will not let you hand-maintain

`apps/character-creator/test/harness.mjs` exports `section()`, `check()`,
`appDir`, `repoRoot` and `wantSection`. Use them; a bare `console.log` is how the
section numbering came to assert something false about the file it labelled —
`[1c25l]`-style labels had stopped matching execution order in nine places.

**1. A checks module declares its sections twice, and both copies are read.**
Every module under `test/checks/` opens `run()` with

```js
if (!SECTIONS.some(wantSection)) return;
```

so a `--section` run can skip the whole module without parsing it. That list is
typed by hand, and drift in either direction is invisible to the flagless run:
a `section()` call the list lacks is unreachable by name, and a listed name no
call announces matches nothing. Both end in *no section matched*, which reads as
the reader's typo. `rendered-ui.mjs` carried two such names until 2026-09-17.
The flagless run now reads every module's list against its calls, so **add the
name to `SECTIONS` in the same edit that adds the `section()` call.**

Two consequences for how you write the call: it must be **the first thing on its
line** and its name must be a **plain string literal**. The reader is anchored
to statement position precisely so a comment containing the word cannot count as
a call — a descriptive comment in `checks/second-body.mjs` read as a fifth call
and failed the suite. `if (x) section('y')` is invisible to it and will be
reported from the other direction.

**2. Four pages moved and the engine did not.** Since 2026-09-19 the sheet, the
codex, the notes and the dashboard live in their own app directories while
`apps/character-creator/js/` stayed put, because the Pages Functions import
those modules by path. `harness.mjs` owns that map: call `appPath('sheet.js')`
rather than joining a directory, and sweep with `siblingAppDirs` rather than a
`readdir` of `appDir`. A sweep written the readdir way silently covered four
fewer files the moment they moved — the parse check stopped opening `sheet.js`
and said nothing, which is the exact hole it exists to close.

## The flagless run is the gate. Both flags say so themselves

`smoke.mjs --section <name>` runs only matching sections, case-insensitive,
repeatable, comma-separated, and skips the wrangler half. `regression.mjs --upto
<stage>` truncates at `setup`, `play` or `data`.

**A truncated or filtered run labels its summary `PARTIAL`**, specifically so its
output cannot be pasted into a PR as `ship-pr` step 4. If you are quoting a pass
line, it has no flags in it.

**`regression.mjs` takes `--upto` rather than `--section`, and that is not a
copy of the smoke flag done badly.** The suite is a pipeline: every stage
inherits the character state the one before it built. Step 5 posts gear; step 7
then asserts that an unenchanted inventory row decodes to an empty array against
that row. Skip step 5 and the check still passes — against a state no real run
ever has. **Truncation preserves the semantics; omission does not**, so there is
deliberately no way to ask for the last stage without the middle one.

Steps 1 to 4 always run. They were 183 of the suite's 325 seconds measured
2026-09-21, so the floor for any truncated run is about three minutes and the
most the flag can save is roughly 142 seconds. A smaller win than the smoke
flag, for a structural reason rather than a fixable one.

## Reading a failure: the check's rows are not the whole cause

A red check names the rows **it reads**. Fixing those rows turns it green, but
that says nothing about the rows the same cause wrote where no check looks.
The OCR sweep in `apps/character-creator/test/regression.mjs` is the record.
Until 2026-09-18 it read only super abilities, and only for page numbers,
headings and junk. Commit `0d4bef06` widened it in two directions: three more
tables, and a digit-cipher pattern. It found 46 spells, 1 psionic power and 2
more super abilities (the comment at its `SELECT * FROM ${table}` loop). The
defects were mostly level headings attached to the end of a spell, with 8
spells in the cipher. None of those rows was red until someone widened what
was read.

**So before the first edit that turns a failing check green, write two lines
in the session:**

1. **The cause, as a mechanism, not a row.** For example, "this book's cache
   sets 0 as O", not "this row has a typo".
2. **Every place that cause wrote to, not only this branch, and which of those
   places any check reads.** A cause in a book's cache is in every table that
   book ever fed, including tables imported by earlier PRs. **Grep the
   scripts' contents for the book's printed name, not the filenames for its
   slug.** Filenames do not reliably carry the slug. All four of Mystic
   Russia's spell imports are `zzzzzzzzzz-mr-*-spells.sql`, and a slug grep
   finds none of them (measured 2026-09-23).

   ```bash
   grep -l -i "<book name as printed>" apps/character-creator/db/*.sql
   ```

   It over-includes, which is the safe direction for a sweep. A book usually
   feeds gear, classes and creatures as well as spells and psionics, and the
   sweep above reads only spells, psionic powers, talents and super abilities.
   Skill notes are written by hand rather than scanned (the comment above
   that loop). Sweep the unread tables by hand, or say in the PR body that you
   did not.

If you can't write line 1, you're not ready to fix yet. Reading is the work.

## The port, and the other worktree that answers on it

`regression.mjs` and `play-flow.mjs` boot `wrangler pages dev` through
`apps/character-creator/test/dev-server.mjs`, which exists because a fixed port
is not safe here. On 2026-09-16 a run in one worktree left a `workerd`
listening; a later run from another worktree spawned its own wrangler on the
same port, and **its poll got a 200 from the foreign server.** It reported that
tree's catalog counts as a regression in this one, with a block of Talent
failures that read exactly like a real break.

Nothing failed to bind, and that is the part worth knowing: against a `workerd`
holder, the second wrangler's `workerd` binds the same port too, both show
LISTENING, and connections keep reaching the older server. **So "my child is
alive" proves nothing, and neither does a 200.**

Three defences, and only the third makes the failure unmisreadable: the OS picks
a free port per run (`REGRESSION_PORT` pins one), the port is checked before
spawning and its holder's parents are named, and the poll demands a **marker row
this run wrote into its own scratch database**. If you write a suite that boots a
server, use this module rather than a port number.

## Splitting a checks module

`smoke.mjs` has been split twice and will be again — it passed 4,000 lines,
`checks/environment.mjs` came out, it grew back past 10,000, and
`checks/second-body.mjs` took four Nightbane sections out. `smoke.mjs`'s own
header records where to cut next so it does not have to be re-derived.

**The test for a good cut:** a run of **adjacent** sections that are **one
subject** and whose imports are their own. `second-body` used 26 bindings there
and nowhere else, so nothing had to be shared out or duplicated.

**Derive that list, do not eyeball it** — and derive it by counting occurrences
outside the import block, not by analysing scope. Four scope-aware passes written
while doing the last split each returned a confidently wrong answer.

**The trap is a local no import analysis can see.** `D` is built in the `Psychic
tiers` section by evaluating `js/derive.js` against a stand-in global, and used
in 95 places as far down as the last few hundred lines. Do not let that section
travel with a split, and check for the same shape before any cut: it is what
broke the `second-body` cut on its first run.

## A skill is a check too, so pressure-test it before it ships

A skill in `.claude/skills/` is a check on behaviour, and until 2026-09-23 none
had been seen to fail. Each was written after an incident and tested by the
next one. `take` is what that costs: it exists because `audit-menu` already
required the subject grep and the premise audit, and sessions skipped both
anyway (`.claude/skills/take/SKILL.md:21-30`). A skill that reads as correct
and changes nothing is a green tick that retired a real rule, which is the
same failure this file opens with.

**So a new or changed skill is run against a scenario before it merges.** The
method comes from obra/superpowers' `writing-skills`, reviewed 2026-09-22 and
adopted without the plugin (`SKILL-AUDIT` `F64`):

1. **Write the scenario with the pressure that caused the incident.** Use a
   real failing line, a request to "just fix it tonight", or a branch that's
   already open. A calm scenario tests reading comprehension, not behaviour.
2. **RED: run it BEFORE editing the skill.** Use two fresh subagents with the
   same prompt. Make it planning only: they may read anything and run nothing
   that writes, and they reply with their steps and the first change they would
   make. **Do this before the edit, because the junction serves the main
   checkout:** once a skill file there is edited, that edit is what every
   subagent loads, including ones spawned in the same turn. It is also what
   every other session on the machine loads.
   **In a worktree the junction serves nothing you edit**, so GREEN would
   load the old skill and match RED. Step 4 would then read that as "the
   skill adds nothing", and the verdict would be false. Run this from the
   main checkout.
   **Keep the prompt blind.** It describes the situation and never the
   behaviour you hope for. `claim-audit`'s fixture rule is the precedent: an
   agent that has read the answer key cannot be scored (`SKILL-AUDIT` `F28`,
   `.claude/skills/claim-audit/reference/negatives.md`).
   **The prompt is not the only place the answer can be.** Subagents grep
   the tree and read files from disk, and the harness hands every one of them
   a git snapshot. So keep the answer out of all three places below while any
   run is live:
   - **The branch name and commit subjects.** The snapshot carries the
     current branch, the uncommitted file list and recent commit subjects,
     whatever the tree holds. A branch called `…-sweep-past-the-check` states
     the answer. Run from a neutrally named branch, and don't commit anything
     that describes the test until the runs are done.
   - **The working tree.** An uncommitted finding, a PR-body draft or a
     notes file that describes the test is an answer key. Keep drafts in the
     scratchpad, and write the finding after the runs.
   - **The skill under test.** It must not name the scenario, quote the
     failing row, or record its own RED and GREEN results. Evidence belongs
     in the finding, not in the skill.

   A run that read any of these does not count. Say so in the record, and run
   it again. `SKILL-AUDIT` `F65` had all three leaks in its second GREEN
   round, and its one hit there was discarded. The branch name was still live
   in its third round too (`SKILL-AUDIT` `F66`).
3. **GREEN: edit, WAIT, then run the identical prompt again**, two more runs.
   The edit reaches subagents after a delay, not on save. Measured 2026-09-23:
   a probe spawned two tool calls after an edit loaded the old headings. The
   session then showed a skill-listing refresh carrying the new description,
   and the next probe loaded the new headings. **Wait for that refresh**, or
   have one probe list the skill's `## ` headings, before believing a GREEN
   run saw the new text.
4. **Read the difference, and trust a failure more than a pass.**
   - If RED already does what the skill asks, the skill adds nothing on that
     scenario. **Say so, then ship it smaller or not at all.**
   - If GREEN still misses, either the wording is wrong or the skill never
     loaded. The description is what makes it load.
   - A pass in a clean scenario is weak evidence. A miss is strong evidence.
5. **Put the prompt and what each run did in the PR body.** The next person to
   change the skill can then re-run the same scenario, not invent a new one.

**An agent file is different.** One written mid-session answers
`Agent type '<name>' not found` until the next turn (`CLAUDE.md`,
`SKILL-AUDIT` `F26`), so an agent's GREEN half waits for the next turn. A
skill's waits only for the refresh in step 3.

**Cost: four subagent runs per skill change.** Skip it for a typo, a moved
path, or a dated fact. Run it whenever the change is meant to make a session
**do** something differently.

## What "checked" means

- the check has been **seen to fail**, with the fault injected upstream of the
  stage in question
- its section name is in that module's `SECTIONS` list, and the call is a plain
  literal at the start of its line
- the pass line you are quoting has no `--section` and no `--upto` in it
- a count you pinned is read back out of the thing that owns it, not
  transcribed into the check beside it
- if it needed a server, it went through `dev-server.mjs` and proved the server
  was its own
