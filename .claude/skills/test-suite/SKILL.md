---
name: test-suite
description: Add or change a check in this repo's test suites without writing one that cannot fail. Use when adding a test, pinning a count or a claim, reading a failure, deciding which suite a check belongs in, or splitting a checks module — "add a check for this", "pin that number", "why did smoke fail", "write a test" — and when writing or changing a skill, which is pressure-tested before it ships.
---

# Adding a check

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`). The incident behind each rule
> is in `reference/why.md`.

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
| `apps/media-vault/test/smoke.mjs` | the localStorage merge planner, and that no endpoint can replace a library | **`smoke`** |
| `apps/marvel-heroes/test/smoke.mjs` | the Marvel app's rules: its roll tables cover every roll, the NPC blocks add up, its endpoints read only the owner's rows, and no book prose is in a tracked file | **`smoke`** |
| `scripts/menu-check.mjs` | every new claim about another file says where it was read | **`menus`** |
| `apps/character-creator/test/regression.mjs` | real HTTP against real endpoints, on a D1 built from nothing | **`regression`** |
| `apps/character-creator/test/play-flow.mjs` | the play loop in a browser | reporting only |
| `apps/character-creator/test/ui-shots.mjs` | that seven pages load in a real headless Chrome at desktop and phone size without a console error, a sideways scroll or sticky chrome over half the screen; keeps a PNG of each | not run by CI; a report, exit 0 unless `--strict` |

The four smoke suites run as steps of one job, `smoke` (`.github/workflows/tests.yml`).

The three bold names are required status checks on `main`; why a workflow's job id must not be renamed is in `.claude/rules/workflows.md`. That file loads by itself only when a workflow file is read, so read it before renaming a job or adding a workflow.

**Not every suite runs on every pull request** (since 2026-09-25). Each job
first asks `node scripts/groups.mjs --affected HEAD^1 HEAD` which groups the
change touches (`groups.json`). The character creator's smoke suite and the
menu check always run, because they pin every skill, agent, menu and tile.
`regression` and `play-flow` run for Palladium or shared changes. The tools and
Marvel suites run for their own group or a shared change. A skipped step still
leaves the job green, so **a new suite belongs to a group**: gate its step the
same way, or it runs everywhere, which is the safe mistake.

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

`shared/test/harness.mjs` exports `section()`, `check()`, `summary()`,
`repoRoot` and `wantSection`, and every app's suite imports it. The character
creator's `apps/character-creator/test/harness.mjs` re-exports those and adds
`appDir`, `appPath` and `siblingAppDirs`. Use them; a bare `console.log` is how the
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
the reader's typo.
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
`readdir` of `appDir`.

The incidents behind both are in `reference/why.md`.

## The flagless run is the gate. Both flags say so themselves

`smoke.mjs --section <name>` runs only matching sections, case-insensitive,
repeatable, comma-separated, and skips the wrangler half. `regression.mjs --upto
<stage>` truncates at `setup`, `play` or `data`.

**A truncated or filtered run labels its summary `PARTIAL`**, specifically so its
output cannot be pasted into a PR as the **Verify** step of `ship-pr` → *The loop*. If you are quoting a pass
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
The OCR sweep in `apps/character-creator/test/regression.mjs` is the record:
widening what it read turned up dozens of defective rows that no check had
shown red (`reference/why.md`).

**The rule that follows from this lives in `CLAUDE.md`**, in the paragraph
opening *When a check goes red*, and not here, because every session reads
`CLAUDE.md` and few load this skill (`SKILL-AUDIT` `F67`; the measurement is
in `reference/why.md`). This section keeps the reasoning behind the rule:

- **Grep a book's scripts by the name it prints, not the filenames by its
  slug.** Filenames do not reliably carry the slug (an example is in
  `reference/why.md`). The content grep over-includes,
  which is the safe direction for a sweep.
- **What the sweep above does not read.** A book usually feeds gear, classes
  and creatures as well as spells and psionics. The sweep reads only spells,
  psionic powers, talents and super abilities. Skill notes are written by
  hand rather than scanned (the comment above that loop).

## The port, and the other worktree that answers on it

`regression.mjs` and `play-flow.mjs` boot `wrangler pages dev` through
`apps/character-creator/test/dev-server.mjs`, which exists because a fixed port
is not safe here: a server another worktree left running can answer this run's
poll with a 200, and its catalog then reads as a regression in this tree
(the incident is in `reference/why.md`).

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

`smoke.mjs` has been split three times and will be again (the three are in
`reference/why.md`). **`smoke.mjs`'s own
header is the record**: how to cut, which names are really shared, and which
sections are the next candidate. Read it there, because this page went stale
once already by repeating it.

**The test for a good cut:** sections that are **one subject**, that read
nothing the rest of the file declares, and that declare nothing the rest
reads. Adjacent is cheaper and not required: two of the nine modules were
gathered from runs thousands of lines apart.

**Derive the list, do not eyeball it**, by counting each imported binding and
each column-0 declaration inside and outside the range. **Then read every hit
the count calls shared, because most are not.** `rel`, `legal`, `bad` and
`skill` are declared at column 0 somewhere and found in dozens of other
sections, and every one of those is a local of the same name or the word in a
string.

**The trap is a local no import analysis can see.** `D` is built in the
`Psychic tiers` section, and `derive` in `Class bonuses`, by evaluating
`js/derive.js` against a stand-in global. Other sections read them far below.
Do not let either section travel with a split. A module that needs
`js/derive.js` builds its own the same way, as `skill-rules.mjs` and
`second-body.mjs` do.

**A moved section can carry a path.** A static import is rewritten when the
import block is. An `import('../js/...')` inside a section body is not, and
from `checks/` it is one directory deeper.

## A skill is a check too, so pressure-test it before it ships

**A new or changed skill is run against a scenario before it merges**, whenever
the change is meant to make a session **do** something differently. Skip it
for a typo, a moved path, or a dated fact.

The shape: RED before the edit, GREEN after, the same prompt both times, run
from the main checkout. The method is in `reference/pressure-test.md`: read it
before writing or changing a skill.

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
