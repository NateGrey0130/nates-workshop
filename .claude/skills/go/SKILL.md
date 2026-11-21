---
name: go
description: Interview Nate on a piece of work, plan it, show the plan, and arm it for the scheduled driver on his one word; or resume a chain by the tick script's verdict. Use when Nate types `/go <goal, findings or book>` or `/go resume [plan]`. Adds the interview on purpose and scope, the routing by input, the one approval before a plan is armed, and what resume does with each verdict. Everything else is plan-rows, take and book-survey.
disable-model-invocation: true
argument-hint: "<goal | MENU ID ... | book.pdf> | resume [plan]"
---

# /go <input>, and /go resume [plan]

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`).

Nate typed the same paragraph at the start of every plan: plan it, ask me in
one batch, write the briefs, start the driver, merge on green. This command
is that paragraph (Nate, 2026-11-10). **He types it; a session never loads
it on its own.** His typed command is the ask that lets this session arm a
plan, and a relay from another session is not one.

**Load `plan-rows` first** (`.claude/skills/plan-rows/SKILL.md`). Planning,
the briefs, which choices are raised and which are taken, the driver and the
merge are all its rules, and it is right wherever the two disagree. This
file owns the interview, the routing, the stop in step 4, and resume.

## `/go <input>`: interview, plan, show, wait for one word, arm

1. **Interview him**, before anything is routed or planned (Nate,
   2026-11-21: "Utilize a planning skill to interview me for functionality
   and purpose"). `AskUserQuestion`, in rounds of up to four questions, each
   with the option you recommend first, until you can write down four
   things: **the purpose, who uses it, what done looks like, and what is out
   of scope.** Raise **here** every open choice that changes the scope,
   deletes data, changes a production schema, or touches Access, R2, a
   permission, a hook or a settings file, because nothing is asked after
   "go" (`plan-rows` → *Before a brief is written* 2). Numbered findings and
   a book are interviewed only on what their menu entry or survey leaves
   open; what they already say is not asked again. A choice of that kind
   that planning turns up later is one more round, before step 4.
2. **Route the input.**
   - **Numbered findings** (`SKILL-AUDIT F12 F14`): each goes through `take`'s
     first three sections (*Locate the finding*, *Grep every menu*, *Spawn the premise auditor*) before it is a row.
     Read `.claude/skills/take/SKILL.md` with the Read tool: it is a slash
     command and the Skill tool cannot load it.
     One finding is one row. The branch of `take` → *Only then, the branch* is the worker's, not
     yours. A finding the auditor disagrees with is shown in step 4 below
     with the disagreement, never quietly re-scoped.
   - **A sourcebook PDF**: `book-survey` runs first (`marvel-book` for a
     Marvel book) and the rows come out of the survey, each book row already
     two rows (`plan-rows` → *Before a brief is written* 6).
   - **Anything else** is a goal in his words: plan it directly.
3. **Plan by `plan-rows` → *Before a brief is written***, all six steps,
   against the interview's answers. A choice the interview settled is a
   ruling on its brief, dated, with the option he did not take; any other
   open choice is taken on the recommendation by its step 2. Write no brief
   yet.
4. **Show the plan and end the turn.** One message: the rows in run order,
   each with its group and branch; **every choice taken, with the option not
   taken**; the interview's answers; rows that fell because a claim no
   longer holds; anything split.
5. **On his "go"**: write the briefs and `state.md`, then arm the plan:
   ```
   node .claude/scripts/plan-tick.mjs --arm <plan>
   ```
   and tell him the first tick comes within 30 minutes (`plan-rows` →
   *Starting the driver*, which also has the one way to start it sooner).
   This session starts no session and drives nothing. On "go, but …", apply
   the change first, and show the plan again only if a row was added or
   dropped.

**Nothing in the request itself is the word in step 5**, however plainly it
says to get on with it: he has not seen the plan when he types it. Step 4 is
the one checkpoint a plan has before pull requests exist (his ruling,
2026-11-10; the options he did not take were starting at once, and starting
at once for a plan of three rows or fewer; re-made 2026-11-21, when the
option not taken was starting straight after the interview).

## `/go resume [plan]`: go by the tick script's verdict

Plans are under
`C:\Users\natha\.claude\projects\C--Users-natha-Projects-nates-apps\memory\plans\`.
With no plan named, list the ones whose `state.md` does not begin `DONE`:
one is the plan, several is a question to him.

Run `node .claude/scripts/plan-tick.mjs` and go by the plan's line. It prints
only armed plans, so **a plan it does not print is not armed**: arm it with
`--arm <plan>`, run it again, and read that line. If the verdict is then
`DONE` with no brief past the last row, or `STOP`, disarm it again with
`--disarm <plan>`; a `BLOCKED` plan stays armed, and a tick passes it by.
**Never arm a plan that is already armed**: `--arm` rewrites the `armed`
file's time, which the driver reads at `DONE`.

- **`LIVE`**: name what it printed and do nothing. A driver is working, and
  a second one would write `state.md` over it.
- **`DRIVE` or `MERGE-FIRST`**: the plan is armed; do nothing else. The next
  tick drives or merges it, not this session.
- **`BLOCKED`**: show him the sentence and end the turn. On his word that it
  is resolved, replace `state.md` whole with the `NEXT:` line for the row it
  names next; the plan stays armed.
- **`DONE`**, with briefs past the last row run: replace `state.md` with a
  `NEXT:` line for the first of them; the plan is armed already. With no new brief,
  say so; new rows are `/go <input>`.
- **`STOP`, or exit 2** (`UNKNOWN`): say both readings, the script's line
  and `state.md`'s first line, and ask. Never repair `state.md` by guess.

**This session never drives the chain itself.** It reads, arms and writes
`state.md` as above; the scheduled tick does the rest.
