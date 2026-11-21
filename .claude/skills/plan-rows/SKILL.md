---
name: plan-rows
description: Turn an approved list of work into a chain the pr-worker agent can run - a state file and one brief per row in the memory store - and drive that chain. Use when Nate approves a multi-PR plan, when asked to "write the briefs", "queue the rows" or "get the chain ready", when a row is added to or split in an existing plan, and when arming a plan, running a driver tick or resuming a chain.
---

# Planning rows, and driving them

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`). The incident behind each rule
> is in `reference/why.md`.

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

**The folder has no history and no backup**: it is outside the repo, and
nothing copies it. A memory clean-up or consolidation must not touch
`memory\plans\`.

A row id is a number in run order; a row split from row 9 is `9a`, `9b`.
**`state.md` is not a history**; the pull requests are. It is six lines at
most, each one sentence, replaced whole by whoever writes it; nothing is
ever appended to it. Its first line is
`NEXT: row <id> (brief: rows/<id>.md), then row <id>.`, or
`BLOCKED: <one sentence>`, or `READY: <the open pull request>` above a
`NEXT:` line, or `DONE`. Then the last row with its pull request and
outcome in one line, and `In flight:`. Nothing else: a ruling a later row
needs goes on that row's brief as a `From row` line (below), and every
other fact lives in a pull request. The measurement behind this is in
`reference/why.md`.

## Before a brief is written

1. **Every claim a row makes about the code is run against the code that
   day**, with the instrument that shows it. A claim that no longer holds is
   not queued; tell Nate which rows fell. One you could not check goes in the
   brief as `Not checked when written:`.
2. **Settle every open choice before any brief exists**, because a worker
   cannot ask. A choice is raised in `/go`'s interview, before Nate's "go",
   or taken on the recommendation: name the option you recommend and why,
   and put it on its brief's `Rulings:` line as
   `taken on the recommendation, <date>: <choice>; not taken: <other>`.
   **After Nate's "go" nothing is asked**, by the planner, the driver or a
   worker. Every choice taken that way keeps its line, and is told to him in
   the closing message.
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
   before its first edit fills the rest. (200k and 37k are dated values, as
   this page stood on 2026-11-10: re-check both, and every 200k below, at a
   model change.) **A reading set over 400 KB (about
   100k tokens) is split at plan time**, never left for the split agent under
   *Driving the chain*, which stays the fallback for a row that outgrew a
   brief sized this way. 400 KB is a starting value, to be recalibrated
   against the peaks real rows report (the measurement behind it is in
   `reference/why.md`).
6. **A row that reads a book is two rows from the start**: extraction (the
   pages or renders and the skills, ending at a pushed branch that holds the
   drafts or data scripts with `class-check` reading `ready`, and no pull
   request) and shipping (resuming that branch for the survey line, the
   suites, the `--remote` apply and the pull request). The extraction brief
   has its worker end by appending `From row <id>: resume <branch> at
   <commit>` to the shipping row's brief and writing `state.md` with the
   shipping row as `NEXT:` and its own row as `PUSHED` (the incident is in
   `reference/why.md`). Before it ends, the extraction worker also frees its
   local branch: confirm `git ls-remote --heads origin <branch>` shows the
   commit it names, then `git branch -D <branch>`, so the shipping row's
   `checkout -b` does not find the name taken.

Ruling 3 is Nate's, 2026-10-12. Ruling 2 is his of 2026-11-21, "Nothing is
asked"; the options he did not take were asking only the irreversible
choices (the planner's recommendation that day) and keeping the asked list
of 2026-11-10. The history is in `reference/why.md`.

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

## Starting the driver

**The driver is a run of the scheduled task `plan-driver`**, whose whole
prompt is `Load plan-rows and run one tick.` It fires every 30 minutes, and
each run is one tick (*Driving the chain*). A session where Nate types that
line is a driver too, under the same lock. No session starts another
session: the app refuses that call in any session another session started,
and that guard is not routed around (the Splynn figures are in
`reference/why.md`). Nate, 2026-11-21: the scheduled task is the driver; the
option he did not take was session hand-offs with the task as a fallback.

The planning session arms the plan once the briefs and `state.md` are
written and Nate has said "go":

```
node .claude/scripts/plan-tick.mjs --arm <plan>
```

The first tick comes within 30 minutes (taken on the recommendation,
2026-11-21: a 30-minute tick; not taken: 45 or 15). To start at once, the
planning session may call `mcp__scheduled-tasks__run_scheduled_task` on
`plan-driver`; a refusal there is not a stop, since the next tick comes
anyway. It is not a reason to type the tick's prompt into a session by hand
either, or to drive the chain from the planning session. One plan is driven
at a time (Nate, 2026-11-21; the option he did not take was one driver per
group): a tick takes the first plan that needs it.

The driver's model is whatever the task's edit form holds, and only Nate
sets it. The Sonnet driver is a trial (Nate, 2026-10-22; the option he did
not take was keeping the driver on Opus), judged against the Opus drivers'
spend per merge measured that day (`reference/why.md`). Each tick's closing
message says its model and the number of rows it merged, so the next
retrospective can read its spend per merge off the transcript against that
figure. The worker's model is what `.claude/agents/pr-worker.md`'s
frontmatter says; this changes nothing there.

## Driving the chain

The driver is one tick (*Starting the driver*). It reads `plan-tick.mjs`,
`state.md` and each worker's report, never a brief or the code: a driver
that opens a brief or a book cache is planning in the context every later
row pays for. **One tick:**

1. `node .claude/scripts/plan-tick.mjs` prints one verdict per armed plan.
   Take the first plan whose verdict is `MERGE-FIRST` or `DRIVE`. `LIVE`,
   `BLOCKED`, `DONE`, `STOP` or nothing armed: end in one line and start
   nothing. (`STOP` is written to that plan's `state.md` as a `BLOCKED`
   line first; see *Any other disagreement* below.) `UNKNOWN` is a reading
   that failed: end in one line, and the next tick reads again.
2. `node .claude/scripts/plan-tick.mjs --claim <plan>`. Exit 1 means
   another driver is live: end in one line.
3. `MERGE-FIRST #<n>`: merge it by the four steps below, write `state.md`,
   and carry on with the plan. `DRIVE row <id>`: spawn the row.
4. `node .claude/scripts/plan-tick.mjs --heartbeat <plan>` before every
   spawn and after every return, so a later tick reads the lock as live.
5. `node .claude/scripts/plan-tick.mjs --release <plan>` at every stop, at
   `DONE`, and at the budget line (below), before the closing message.

One row is one spawn, in the foreground:

```
Agent  subagent_type: pr-worker   run_in_background: false
prompt:
  State file: <absolute path to state.md>
  Row brief:  <absolute path to rows\<id>.md>
```

**Nothing else goes in the prompt.** A correction to how workers work is a
pull request against the agent file; a fact about a row belongs in its brief.

**A worker return with no outcome line is not a stop**: run
`plan-tick.mjs` again and go by its verdict for the plan.

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
   `--delete-branch` while a worker's worktree still holds the branch, which
   is true of every plan row. When no worktree holds it, `ship-pr` → *The loop*, **Merge**,
   applies.
2. `node .claude/scripts/pr-landed.mjs <n> --wait`, which must exit 0.
3. `git pull --ff-only origin main` in the driver's checkout, then
   `node scripts/drift-check.mjs --remote`, which must print `NO DRIFT`.
   Drift-check reads the checkout's data scripts, so after a data row an
   un-pulled `main` prints `RUN BUT NO FILE` for the script just merged
   (the incident is in `reference/why.md`).
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
   The incident behind this step is in `reference/why.md`.

Two more steps follow the merge, and **neither is ever a stop**: a refusal, a
failure or a missing tool is one line in the closing message, and the chain
goes on.

5. **Remove the merged row's worktree** through the `worktree` skill
   (*Removing one*): kill a dev server the worker left on its port first, by
   the `--port` in its command line, then unlink every junction the
   reparse-point scan names, then `git worktree remove <its path>`, then
   `git branch -D <the row's branch>` (capital `D`, since local `main` may be
   behind). Its closing-message line is `worktree <path>: removed`, or
   `refused: <the call and its message>`, or `failed: <what it printed>`.
6. **Refresh the Plan Board**, https://claude.ai/artifact/RNdwDDxNnP9A7m9F5tNyfF.
   `node .claude/scripts/plan-board.mjs --export <a scratchpad dir>` writes
   `reading.json`, `plans.json` and `rows.json` there. Upload each with the
   Artifact tool (`url` that link, `asset: true`, `file_path`), one call per
   file. Then, with `ArtifactData`, `get` the docs `reading`, `plans` and
   `rows` in collection `datasets` for their versions, and send one `batch` of
   three `update` writes, each with `if_version`, setting `source.url` to the
   file's new blob url and `updated.at` to now. The page itself is never
   republished. Load each tool with `ToolSearch`. Its closing-message line is
   `board: refreshed`, or `refused: <the call>`, or
   `no tool: <the name ToolSearch did not find>`, or `failed: <what it printed>`.

Then replace `state.md` whole, with the `NEXT:` line from the report first and
the row as `MERGED` by the driver, and spawn the next row. A refusal is not a
request for Nate's word: if a call in steps 1 to 3 is refused or fails, stop
(*The five stops* below). A failure in step 4 is said in the closing message
and is not a stop: each worker applies the migrations its copy lacks.

**At `DONE`, before the closing message**, four things, in order, none of them
a stop either:

1. step 6 once more, so the board shows the plan finished;
2. read the plan's `armed` file for the time it was armed, then
   `node .claude/scripts/plan-tick.mjs --disarm <plan>` and
   `node .claude/scripts/plan-tick.mjs --release <plan>`;
3. the `worktree` skill's reparse-point scan over every worktree the plan's
   rows left, removing each as in step 5;
4. **archive this plan's finished driver sessions**:
   `mcp__scheduled-tasks__list_task_runs` on `plan-driver`, and
   `mcp__ccd_session_mgmt__archive_session` for each run since the armed time
   that succeeded, never the run doing it. Load both with `ToolSearch`.

Each has its line in the closing message, as worked, refused or no tool; for
step 4, the runs archived and the runs left with the reason.

**A capped row with only the CI wait left is the driver's to finish, not a
split.** That is a `BLOCKED` report from the worker's cap that says its pull
request is open, every suite was green locally and the watch is all that is
left. One call:
`gh pr checks <n> --repo NateGrey0130/nates-workshop`. Every required check
passing makes the row `READY`: merge it by the four steps above and write
`state.md` from the `NEXT:` line the report carries (`pr-worker` puts it
there for this case). Checks still pending: the same command with `--watch`,
at the Bash tool's ten-minute timeout, once. A red check, or a report that
names any other work left, goes to the split below. What this saves is
measured in `reference/why.md`.

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

**The five stops.** The driver stops only at these, and at nothing else
(Nate, 2026-11-21: stops "only on breaking items", with explicit reasoning;
his ruling of 2026-10-12, no row cap, still holds):

1. a required check red for a reason outside the row's diff;
2. a merge, landing or drift step (steps 1 to 3 above) refused or failed;
3. a `--remote` D1 apply refused or failed;
4. a choice with no recommendable option, including one whose only option
   breaks a `CLAUDE.md` never-rule, such as public access on the R2 bucket;
5. the same row `BLOCKED` twice for the same cause.

Do not retry or fix a stopped row. `DONE` is the end of the chain, not a
stop. **Every stop is written as `state.md`'s first line, one sentence in
three clauses:**
`BLOCKED: <the cause as a mechanism>; <what was tried>; <what unblocks it>`.
When a row is spawned a second time, the last-row line carries `attempt 2`,
so that the fifth stop can be read off `state.md`.

**Any other disagreement** between a report, `state.md` and GitHub is not a
stop. Go by `node .claude/scripts/plan-tick.mjs`: its verdict for the plan
says what to do next, and only its `STOP` verdict is written as a `BLOCKED`
line, carrying both readings that disagreed.

**A `BLOCKED` report that carries a recommendation is taken**, whatever the
choice (Nate, 2026-11-21, "Nothing is asked"; the options he did not take
were asking the irreversible ones and keeping the asked list): append
`From row <id>: taken on the recommendation, <date>: <choice>; not taken:
<other>` to that row's brief, replace `state.md` whole with a `NEXT:` line
naming the same row and any branch and commit the report gave to resume
from, free that branch as for a split above, and spawn the row again with
`attempt 2` on the last-row line. It is told to him in the closing message.
Nothing in driving asks Nate a question, and there is no `AskUserQuestion`
call anywhere in it. A report with no recommendation is stop 4. The driver
does not form a recommendation of its own, since it has read neither the
brief nor the code.

**The driver's own budget line ends the tick, and nothing is handed off.**
It arrives as the UserPromptSubmit line (`session-budget: context is …,
past 200k`), or as the post-merge line (`session-budget: a PR just merged
and this session holds …`) once the figure it prints is 150k or more. Then
the driver finishes the row in hand, replaces `state.md` whole, runs
`--release <plan>`, writes its closing message and ends. It starts no
session: the next tick picks the plan up, and needs no word from Nate,
since the allow rule above is what lets it merge. The post-merge line fires
from 150k (`WARN_AT` in `.claude/hooks/session-budget.mjs`), so below that a
merge prints nothing; continue to the 200k line. Why it is not 100k is in
`reference/why.md`.

The closing message carries each row's outcome and pull request, every row
that was split and into what, every line a worker marked as Nate's, and
`node scripts/deploy-sweep.mjs`. It also carries each row's `Peak context:`
line, copied from the worker's report beside the row's pull request; the
planner of the next plan reads those lines before choosing its reading
budget (*Before a brief is written*). It carries the lines of steps 5 and 6
for each merged row, and at `DONE` the lines of the four things above.
