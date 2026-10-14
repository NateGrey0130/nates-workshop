---
name: plan-rows
description: Turn an approved list of work into a chain the pr-worker agent can run - a state file and one brief per row in the memory store - and drive that chain. Use when Nate approves a multi-PR plan, when asked to "write the briefs", "queue the rows" or "get the chain ready", when a row is added to or split in an existing plan, and when starting or resuming a driver session. Covers the stored format, what a brief must carry, Nate's three rulings on planning, how a worker hands something to a later row, and when the driver stops.
---

# Planning rows, and driving them

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing.** Read an undated claim here as true on
> the day it was written.

A row is run by the `pr-worker` agent (`.claude/agents/pr-worker.md`), which
reads two small files and nothing else of the plan. **The brief is everything
the worker knows.** This is a skill and not an agent because planning needs
Nate's rulings, and only a session can ask him.

## Where a plan is stored

In the memory store, which a worker in a worktree reaches by absolute path:

```
C:\Users\natha\.claude\projects\C--Users-natha-Projects-nates-apps\memory\plans\<plan>\
  state.md         six lines at most, replaced whole by whoever writes it
  rows\<id>.md     one brief per row
```

A row id is a number in run order; a row split from row 9 is `9a`, `9b`.
**`state.md` is not a history**; the pull requests are. Its first line is
`NEXT: row <id> (brief: rows/<id>.md), then row <id>.`, or
`BLOCKED: <one sentence>`, or `READY: <the open pull request>` above a
`NEXT:` line, or `DONE`. Then at most the last row with its pull
request and outcome, and `In flight:`.

## Before a brief is written

1. **Every claim a row makes about the code is run against the code that
   day**, with the instrument that shows it. A claim that no longer holds is
   not queued; tell Nate which rows fell. One you could not check goes in the
   brief as `Not checked when written:`.
2. **Ask Nate everything that is his in one batch, before any brief exists.**
   No brief is written with an open question, because a worker cannot ask.
3. **Split a big row, never fold two**, and tell Nate what was split. More
   than two fixes that reproduce separately is two rows: the trial's four-fix
   row peaked at 197k against the worker's 200k stop.
4. `node scripts/groups.mjs <path>` gives each file's group. A row spanning
   two groups is two rows; a shared path is its own row.

Rulings 2 and 3 are Nate's, 2026-10-12.

## What a brief carries

Thirty lines at most, and nothing the agent file or a skill already owns.

```
# Row <id>: <what changes, in a sentence>

Group `<group>`, branch `<grp>/<type>/<slug>`. Skills: `<skill>`, `ship-pr`. Next row: <id>.
Checked against the code <date> at `<short sha of origin/main>`.

What is wrong: one claim to a numbered line, as checked.
Reproduce: the exact recipe and what it shows today, or `nothing`.
Measure with: the instrument that proves the fix, and the reading that counts as fixed.
Files: the paths the fix is expected to touch.
Rulings: Nate's that apply, dated, with the option he did NOT take.
Do not: the neighbouring work this row leaves alone.
```

`Skills:` is the worker's whole reading list. The brief stands alone: no "see
the plan", no link into the memory directory.

## Handing something to a later row

**One appended line at the end of that row's brief, and nothing else in it
changes:** `From row <id> (#<pr>): <the fact>`. A worker does this for
something a later row needs; the planner does it for a ruling that arrives
late. Anything else goes in the pull request's *What this left*.

## Driving the chain

The driver is a session. It reads `state.md` and each worker's report, never a
brief or the code. One row is one spawn, in the foreground:

```
Agent  subagent_type: pr-worker   isolation: worktree   run_in_background: false
prompt:
  State file: <absolute path to state.md>
  Row brief:  <absolute path to rows\<id>.md>
```

**Nothing else goes in the prompt.** A correction to how workers work is a
pull request against the agent file; a fact about a row belongs in its brief.

After each return, read `state.md` again and go by it. `MERGED` or `DROPPED`
with a `NEXT:` line: spawn that row. A report that begins `READY` leaves
`state.md` still naming the worker's own row: a `READY` worker does not write
it, because the classifier refused that write on three of five rows on
2026-10-14 (Nate's ruling that day; the option he did not take was leaving
the worker to try). Its report carries the lines instead, and the driver
writes them.

**`READY` is a row the driver merges**, when Nate has said in this session to
merge green rows (his ruling, 2026-10-12; the option he did not take was the
driver merging every row). The worker's own merge was refused because no word
of his is in a worker's context. Three calls, each on its own:

1. `gh pr merge <n> --merge --repo NateGrey0130/nates-workshop`, with no
   `--delete-branch`: the worker's worktree still holds the branch.
2. `node .claude/scripts/pr-landed.mjs <n> --wait`, which must exit 0.
3. `git pull --ff-only origin main` in the driver's checkout, then
   `node scripts/drift-check.mjs --remote`, which must print `NO DRIFT`.
   Drift-check reads the checkout's data scripts, so after a data row an
   un-pulled `main` prints `RUN BUT NO FILE` for the script just merged
   (row 32a, 2026-10-14).

Then replace `state.md` whole, with the `NEXT:` line from the report first and
the row as `MERGED` by the driver, and spawn the next row. Without that word from Nate
in this session, or if any of the three is refused or fails, stop.

**Stop and tell Nate at the first of these** (his ruling, 2026-10-12: no row
cap):

- the report or the state file says `BLOCKED`. Do not retry or fix the row.
- the state file says `DONE`, or the next row has no brief.
- the report and the state file disagree, other than a `READY` report over a
  state file that still names that row.
- the driver's own budget warning.

The closing message carries each row's outcome and pull request, every line a
worker marked as Nate's, and `node scripts/deploy-sweep.mjs`. Worktrees a run
leaves behind are removed through the `worktree` skill's scan.
