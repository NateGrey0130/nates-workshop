---
name: go
description: Plan a piece of work and start the driver chain on it from one typed command, or restart a chain that has no driver. Use when Nate types `/go <goal, findings or book>` or `/go resume [plan]`. Adds the routing by input, the one approval before a driver starts, and what is read before a driver is started on an existing plan. Everything else is plan-rows, take and book-survey.
disable-model-invocation: true
argument-hint: "<goal | MENU ID ... | book.pdf> | resume [plan]"
---

# /go <input>, and /go resume [plan]

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`).

Nate typed the same paragraph at the start of every plan: plan it, ask me in
one batch, write the briefs, start the driver, merge on green. This command
is that paragraph (Nate, 2026-11-10). **He types it; a session never loads
it on its own.** His typed command is the ask that lets this session start a
driver, and a relay from another session is not one.

**Load `plan-rows` first** (`.claude/skills/plan-rows/SKILL.md`). Planning,
the briefs, which choices are asked and which are taken, the driver and the
merge are all its rules, and it is right wherever the two disagree. This
file owns the routing, the stop in step 4, and the resume table.

## `/go <input>`: plan, show, wait for one word, launch

1. **Route the input.**
   - **Numbered findings** (`SKILL-AUDIT F12 F14`): each goes through `take`
     steps 1 to 3 (locate, subject grep, premise auditor) before it is a row.
     Read `.claude/skills/take/SKILL.md` with the Read tool: it is a slash
     command and the Skill tool cannot load it.
     One finding is one row. `take` step 4's branch is the worker's, not
     yours. A finding the auditor disagrees with is shown in step 4 below
     with the disagreement, never quietly re-scoped.
   - **A sourcebook PDF**: `book-survey` runs first (`marvel-book` for a
     Marvel book) and the rows come out of the survey, each book row already
     two rows (`plan-rows` → *Before a brief is written* 6).
   - **Anything else** is a goal in his words: plan it directly.
2. **Plan by `plan-rows` → *Before a brief is written***, all six steps.
   Its step 2 says which open choices go to him in one batch and which are
   taken on the recommendation. Write no brief yet.
3. **Ask the batch**, if there is one, and take the rest.
4. **Show the plan and end the turn.** One message: the rows in run order,
   each with its group and branch; **every choice taken, with the option not
   taken**; the answers he just gave; rows that fell because a claim no
   longer holds; anything split.
5. **On his "go"**: write the briefs and `state.md`, then start the driver
   by `plan-rows` → *Starting the driver*. On "go, but …", apply the change
   first, and show the plan again only if a row was added or dropped.

**Nothing in the request itself is the word in step 5**, however plainly it
says to get on with it: he has not seen the plan when he types it. Step 4 is
the one checkpoint a plan has before pull requests exist (his ruling,
2026-11-10; the options he did not take were starting at once, and starting
at once for a plan of three rows or fewer).

## `/go resume [plan]`: read why there is no driver before starting one

Plans are under
`C:\Users\natha\.claude\projects\C--Users-natha-Projects-nates-apps\memory\plans\`.
With no plan named, list the ones whose `state.md` does not begin `DONE`:
one is the plan, several is a question to him.

Read three things, then go by the table. **Start nothing before all three
are read.**

1. `state.md`, whole.
2. `mcp__ccd_session_mgmt__list_sessions` (load it with `ToolSearch`): a
   running or waiting session whose prompt names this plan is a live driver.
3. `node scripts/ground-truth.mjs`: the open pull requests with their CI
   verdict, and any worktree still holding a row's branch. Exit 2 is
   UNKNOWN, not clean.

| read | do |
|---|---|
| a live driver | stop and name the session; two drivers on one plan merge and write `state.md` over each other |
| `NEXT:` or `READY:`, and GitHub agrees | start a driver |
| a row `state.md` calls `READY` under a `NEXT:` first line, its pull request open and green | replace `state.md` whole with the `READY:` line above the `NEXT:` line, start a driver; the driver merges it, not you |
| `BLOCKED:` | show him the sentence and ask whether it is resolved; on yes, replace `state.md` with the `NEXT:` line and start a driver |
| `DONE`, with briefs past the last row run | replace `state.md` with a `NEXT:` line for the first of them, start a driver |
| `DONE`, no new brief | say so; new rows are `/go <input>` |
| anything else `state.md` and GitHub disagree on | say both readings and ask; never repair `state.md` by guess |

The driver is started exactly as `plan-rows` → *Starting the driver* says.
**This session never drives the chain itself**, and a refused
`start_session` is a stop.
