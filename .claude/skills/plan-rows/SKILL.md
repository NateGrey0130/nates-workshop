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
**`state.md` is not a history**; the pull requests are. It is six lines at
most, each one sentence, replaced whole by whoever writes it; nothing is
ever appended to it. Its first line is
`NEXT: row <id> (brief: rows/<id>.md), then row <id>.`, or
`BLOCKED: <one sentence>`, or `READY: <the open pull request>` above a
`NEXT:` line, or `DONE`. Then the last row with its pull request and
outcome in one line, and `In flight:`. Nothing else: a ruling a later row
needs goes on that row's brief as a `From row` line (below), and every
other fact lives in a pull request. Measured 2026-10-18: the file had grown
to 16KB in five lines, and every worker and every driver re-read it.

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
5. **Size the row's reading set before its brief is written, and split what
   does not fit.** List what the worker reads before its first edit: the
   files the fix touches or must read, every skill the brief names with its
   `reference/` files, and any book pages, renders or OCR cache files. Size
   the list in bytes with an instrument run that day: `wc -c` on the files,
   `ls -l` on a directory, a page count times the cache's bytes per page
   (the `txt` directory's total over its file count). The mechanism: a
   worker's run is capped at 200k, it starts at about 37k, and what it reads
   before its first edit fills the rest. **A reading set over 400 KB (about
   100k tokens) is split at plan time**, never left for the split agent under
   *Driving the chain*, which stays the fallback for a row that outgrew a
   brief sized this way. 400 KB is a starting value, to be recalibrated
   against the peaks real rows report. Measured 2026-10-22: 60 of 204
   workers hit the cap, and the 48 rows the outstanding-work plan planned
   ran as 107 briefs.
6. **A row that reads a book is two rows from the start**: extraction (the
   pages or renders and the skills, ending at a pushed branch that holds the
   drafts or data scripts with `class-check` reading `ready`, and no pull
   request) and shipping (resuming that branch for the survey line, the
   suites, the `--remote` apply and the pull request). The extraction brief
   has its worker end by appending `From row <id>: resume <branch> at
   <commit>` to the shipping row's brief and writing `state.md` with the
   shipping row as `NEXT:` and its own row as `PUSHED`. Every book row's
   first worker capped in the 2026-10-20 book-imports plan (ten rows).

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
Reading set: the files above, the skills named and any pages, with the total in KB and the instrument that measured it.
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

The driver is a session, started from one line that Nate types or the driver
before it sends (below): `Load plan-rows and drive <plan> from its state.md.`
It reads `state.md` and each worker's report, never a brief or the code: a
driver that opens a brief or a book cache is planning in the context every
later row pays for. One row is one spawn, in the foreground:

```
Agent  subagent_type: pr-worker   isolation: worktree   run_in_background: false
prompt:
  State file: <absolute path to state.md>
  Row brief:  <absolute path to rows\<id>.md>
```

**Nothing else goes in the prompt.** A correction to how workers work is a
pull request against the agent file; a fact about a row belongs in its brief.

After each return, read `state.md` again and go by it. `MERGED`, `DROPPED`
or `PUSHED` (an extraction row, *Before a brief is written* 6) with a
`NEXT:` line: spawn that row. A report that begins `READY` leaves
`state.md` still naming the worker's own row: a `READY` worker does not write
it, because the classifier refused that write on three of five rows on
2026-10-14 (Nate's ruling that day; the option he did not take was leaving
the worker to try). Its report carries the lines instead, and the driver
writes them.

**`READY` is a row the driver merges.** No word from Nate is needed in the
session: `.claude/settings.json` allows `Bash(gh pr merge *)` (PR #1853,
2026-10-18; the option he did not take was typing the word once per driver
session), and the `ship-pr` order still binds the call: every required check
green, D1 applied first, the merge as its own command. The driver merges a
`READY` row and nothing else (his ruling, 2026-10-12; the option he did not
take was the driver merging every row). The worker still never merges: one
that did would skip the steps below. Four steps, each call on its own:

1. `gh pr merge <n> --merge --repo NateGrey0130/nates-workshop`, with no
   `--delete-branch`: the worker's worktree still holds the branch.
2. `node .claude/scripts/pr-landed.mjs <n> --wait`, which must exit 0.
3. `git pull --ff-only origin main` in the driver's checkout, then
   `node scripts/drift-check.mjs --remote`, which must print `NO DRIFT`.
   Drift-check reads the checkout's data scripts, so after a data row an
   un-pulled `main` prints `RUN BUT NO FILE` for the script just merged
   (row 32a, 2026-10-14).
4. **Bring this checkout's local D1 up to the merge.** Every worker starts
   from a copy of it, and nothing else applies a merged migration here.
   `node scripts/d1-apply.mjs --check --local db/migrations/*.sql` lists
   every migration; each one it does not mark `ALREADY RECORDED` goes in one
   call, in its order: `node scripts/d1-apply.mjs --local <those files>`. A
   Marvel or tools row does the same with `--db marvel db/migrations/marvel/*.sql`
   or `--db tools db/migrations/tools/*.sql`. A data script the merge added is
   applied the same way, `--local` with its path, but a failure there is said
   in the closing message and is not a stop: this database is hundreds of
   data scripts behind production, and a new one can need a row it never got.
   Measured 2026-10-19: rows 46a1, 46b and 46c1 applied migrations 091 to 093
   to production and to their own copies only, and five of the next seven
   workers' copies failed smoke's *Migration state* and served the creator a
   500.

Then replace `state.md` whole, with the `NEXT:` line from the report first and
the row as `MERGED` by the driver, and spawn the next row. A refusal is not a
request for Nate's word: if a call in steps 1 to 4 is refused or fails, other
than a data script's local apply, stop.

**A capped row with only the CI wait left is the driver's to finish, not a
split.** That is a `BLOCKED` report from the worker's cap that says its pull
request is open, every suite was green locally and the watch is all that is
left. One call:
`gh pr checks <n> --repo NateGrey0130/nates-workshop`. Every required check
passing makes the row `READY`: merge it by the four steps above and write
`state.md` from the `NEXT:` line the report carries (`pr-worker` puts it
there for this case). Checks still pending: the same command with `--watch`,
at the Bash tool's ten-minute timeout, once. A red check, or a report that
names any other work left, goes to the split below. Measured 2026-10-19: rows 48a and 48b each stopped
at the cap with their work committed and suites green, and each then cost a
split agent (about 87k) and a resume worker (about 60k) to open a pull
request and watch it.

**A row that outgrew its brief is split by an agent, not by the driver.** Two
reports mean that: a `BLOCKED` that stopped at the worker's cap with work
pushed (it names a branch and a commit) and more than the CI wait above left,
and one that says the row is larger
than its brief describes. Neither is a stop, and neither is a reason to open
the brief. The driver spawns one agent, in the foreground:

```
Agent  subagent_type: general-purpose   run_in_background: false
prompt:
  Load the `plan-rows` skill. Split one row of a plan into rows a worker can finish.
  State file: <absolute path to state.md>
  Row brief:  <absolute path to rows\<id>.md>
  Report:     <the worker's report, pasted whole>
  Return only the new row ids in run order, and the first one's branch and commit to resume from.
```

That agent does the planning: it reads the brief and the pushed work, checks
each claim it carries forward against the code that day, writes the new
briefs (`9a`, `9b`, … under *What a brief carries*; the first resumes the
pushed branch and commit, the last takes the old row's `Next row:`, the old
brief stays), and returns the ids and the resume point and nothing else.
The driver then replaces `state.md` whole with a `NEXT:` line naming the
first new row, and spawns it. Nate is not asked (his ruling, 2026-10-15: a
row that stops at the cap with its work pushed is resumed without asking
him; the option he did not take was a stop at every cap). The split is told
to him in the closing message. One thing is the driver's before that spawn:
a capped worker's worktree still has the branch checked out, so remove it
through the `worktree` skill and delete the local branch, or the resuming
worker's `checkout -b` finds the name taken.

**The driver stops for Nate only at the first of these** (his ruling,
2026-10-12: no row cap), and at nothing else:

- the report or the state file says `BLOCKED`, other than the two cap cases
  above.
  Do not retry or fix the row.
- the state file says `DONE`, or the next row has no brief.
- the report and the state file disagree, other than a `READY` report over a
  state file that still names that row.

A ruling a brief lacks is not a stop: ask it with `AskUserQuestion`, and the
row waits for the answer. The driver does not guess a ruling, and does not
end the session over one.

**The driver's own budget warning is a hand-off the driver makes itself, not
a stop.** It arrives as the UserPromptSubmit line (`session-budget: context
is …, past 200k`), or as the post-merge line (`session-budget: a PR just
merged and this session holds …`) once the figure it prints is 150k or more.
Then the driver finishes the row in hand, replaces `state.md` whole, and
starts the next driver with `mcp__ccd_session__start_session` (load it with
`ToolSearch` if it is deferred): initiation `user_asked`, context `fresh`, no
worktree, and the one-line prompt above with the plan's name in it. Nate is
not asked, and the new driver needs no word from him: the allow rule above
is what lets it merge. Then the old driver's closing message. Below 150k the
post-merge line is nothing: it fires from 100k today (PR #1854 raises it to
150k), which a driver reaches before its first row, and five drivers that
obeyed it there each handed off after one merge and the next paid a fresh
start (2026-10-18). Continue to the 200k line.

The closing message carries each row's outcome and pull request, every row
that was split and into what, every line a worker marked as Nate's, and
`node scripts/deploy-sweep.mjs`. It also carries each row's `Peak context:`
line, copied from the worker's report beside the row's pull request; the
planner of the next plan reads those lines before choosing its reading
budget (*Before a brief is written*). Worktrees a run leaves behind are
removed through the `worktree` skill's scan.
