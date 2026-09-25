---
name: worktree
description: Create, work in and remove a git worktree of this repo without destroying the OCR caches or half-merging a PR. Use when a second session needs its own tree, when told to work in a worktree, before running `git worktree remove`, and when a merge from one exits 1. Covers the two environment variables a worktree needs, the junction that made a removal delete the main checkout's book caches, why `gh pr merge` fails after succeeding there, and what a worktree session does not inherit.
---

# Working in a worktree

> **What pins this file:** its frontmatter and every repo path it names, by
> `apps/character-creator/test/checks/environment.mjs`; every absolute path it
> names, by `apps/character-creator/test/checks/instruction-paths.mjs`.
>
> **The prose is pinned by nothing** — read an undated claim here as true on
> the day it was written.

A worktree is the **only** acceptable shape for a second concurrent session
here. Two sessions in one checkout is the thing that is never acceptable: it has
cost four incidents, and in two of them one session's commit landed on the
other's branch while `git status` looked clean throughout.

It is also the operation with the largest unguarded downside in this repo. One
`git worktree remove` emptied every sourcebook cache in the **main** checkout,
and nothing warned.

## Making one

**For a sourcebook, use the script instead:**

```bash
node scripts/book-worktree.mjs <slug>
```

It makes `../nates-apps-books/<slug>` off `origin/main` on a `<slug>-` branch.
It builds the tree its own local D1 from the tree's files (about three
minutes; `--copy-d1` copies the main checkout's instead, as real files), and
writes both environment variables
below into the tree's own `.claude/settings.local.json`. It links the tree's
memory directory to the real store. Start the book's session in that tree.
`--remove` refuses while the tree holds uncommitted changes or any junction,
which is the removal hazard below. `book-survey` §8 has the parallel-book
routine it belongs to.

Anything else:

```bash
git worktree add ../nates-apps-wt -b short-kebab-description origin/main
```

Branch **off `origin/main`**, not off whatever the shared checkout has checked
out. That is also the escape hatch when a session has already tangled with
another: make the worktree, then `git cherry-pick` your own commit into it,
rather than moving the shared checkout a second time.

Then give it the two things it does not inherit:

- **`WORKSHOP_OCR_CACHE` and `WORKSHOP_LOCAL_D1`.** Every script computed the
  OCR cache and wrangler's local D1 relative to its own repo root, so a worktree
  re-rooted both to itself and found nothing — the smoke suite's D1 sections
  failed and a survey would have re-OCR'd a book that was already cached.
  `SETUP.md` → *Worktrees, and the two stores that live under the repo root* has
  the table of what reads each. Point them at the main checkout.
- **its own dev port.** `apps/character-creator/test/dev-server.mjs` picks a free
  one per run, but a dev server you start by hand does not. See `verify-ui` §0
  and the port section of `test-suite`: a fixed port let one worktree's `workerd`
  answer another's poll with a `200`, and that run reported the wrong tree's
  catalog counts as a regression.

**A dev server started in a worktree serves that worktree's `.wrangler/state`,
which is empty**, unless you start it by hand with `--persist-to`. The two
variables do not reach it.

## Checking whether another session is already in a tree

`git branch -a`, `gh pr list --state open` and `git worktree list` are **all
blind** to a session editing the same working tree. A session that checked all
three, found a clean `main`, no branches and no open PRs, and said so in its PR
was sharing the checkout with a live import session at the time.

**The check is `git status` and file mtimes, repeatedly** — `ls -lt` on what you
are about to stage, or `find . -newermt '-5 minutes'`. `git status --porcelain`
showing changes you did not make is the same signal one step later.

## Removing one. This is the dangerous step

**On 2026-09-19 `git worktree remove` on five clean, merged worktrees emptied the
main checkout's `.cache/books` at the same second** — every sourcebook's OCR and
text-layer cache. The likeliest mechanism is that a worktree held the cache as a
**junction** to the main one and removal deleted through it; the worktrees were
gone by the time anyone looked, so it is not proven. All five printed `removed`.
Nothing warned.

Two reasons nothing caught it, and both generalise past this one directory:

- **`git status --porcelain` says nothing about ignored paths.** The caches are
  gitignored, so a clean status is not evidence the tree holds nothing you want.
  `git status --porcelain --ignored` is the one that answers.
- **On Windows a directory junction inside a tree being deleted can be followed**,
  so the blast radius of a removal is not bounded by the tree.

So, before `git worktree remove` on anything:

```powershell
Get-ChildItem -Recurse -Attributes ReparsePoint -Force <worktree path>
```

and delete each junction it names with `cmd /c rmdir <junction>`, which removes
the **link** and not the target. Then remove the worktree.

**Recovery, if it happens anyway.** The PDFs in
`C:\Users\natha\Projects\workshop\books` are the source; `scripts/ocr-book.py
--slug <x>` rebuilds one. The text-layer books take seconds and the scans took
about 50 minutes in three parallel lanes. **Two things do not come back:** any
hand repair made to a cached page, and byte-identity — the 2026-09-19 rebuild
gained a folio on one page that broke an offset-regions check until the detector
learned to drop it. Expect small text differences, and expect them to surface as
`drift-check` citation advisories.

## Merging from a worktree

`gh pr merge <n> --merge --delete-branch` merges on GitHub first, then tries to
switch **the tree it was run in** to the base branch and delete the local
branch. What happens next depends on **whether any other tree has `main`
checked out** — and with a second session in the main checkout, that changes
from one merge to the next. Both outcomes have been seen:

| the main checkout is on | `gh` exits | what the worktree is left holding | seen |
|---|---|---|---|
| `main` | **1**, after the merge | its own branch, still there locally | PR #1142, 2026-09-17 |
| any other branch — another session's feature branch, say | **0** | **`main`**, fast-forwarded, local branch already deleted | PR #1273, 2026-09-22 |

**Exit 1.** The error is `fatal: 'main' is already used by worktree at
'C:/Users/natha/Projects/nates-apps'`, because git will not check one branch
out in two trees. State `MERGED`, remote branch deleted, only the local half
failed. **Never retry the merge on that error.** Read the state instead:

```bash
gh pr view <n> --json state,mergeCommit --jq '.state + "  " + .mergeCommit.oid'
```

Then do `ship-pr` steps 8 and 9 **from the main checkout**, with `git fetch`
rather than a pull into a tree another session may be using. Finally
`git worktree remove` (after the reparse-point scan above) and `git branch -D` —
capital `D`, because local `main` is behind and `-d` will call the branch
unmerged.

**Exit 0 is the one that costs someone else.** It looks like a clean merge, and
it is one — but the worktree now holds `main`, and for as long as it does **no
other tree can check `main` out**. A session in the main checkout that merges
and then returns to `main`, which is what `ship-pr` does after every PR, gets
the same `already used by worktree` refusal, pointed the other way. So remove
the worktree **straight away**: read the state as above, run the reparse-point
scan, then `git worktree remove`. There is no `git branch -D` to do; `gh`
already deleted the branch.

`git worktree list` tells you which case you are in before you merge, since it
prints each tree's branch. The same mechanism also means **never run the merge
from the main checkout while another session is using it** — `gh` would switch
*that* tree to `main` under the other session. That half is inferred from the
mechanism rather than seen; nobody has done it here.

## What a worktree session does not inherit

The skills and agents load, because those are junctioned into `~/.claude` per
machine rather than per directory.

**Memory does not.** The memory directory is keyed to the working directory, and
the three that matter — the repo, the working directory and `Downloads` — are
junctioned to one real store. **A worktree gets its own project directory with no
memory directory at all**, verified 2026-09-21: the one worktree project folder
under `C:\Users\natha\.claude\projects` holds a transcript and nothing else.

So a session in a worktree starts blind to everything memory holds — including
the removal incident this page exists for. **The exception is a tree made by
`scripts/book-worktree.mjs`**, which links the new project directory's `memory`
to the real store before any session starts there. **Say what you learned into the PR
body or the audit menu**, which are the two stores a worktree session does share,
and do not assume the next session in one will know what this one did.

## Briefing a worker you spawn into one

A parallel campaign gives each worker a slice and assumes it brings the standing
rules with it. It does not, and the slice is the only half that belongs in the
prompt. Measured 2026-09-17: one session spawned **23** workers, 16 following a
brief written into that session's own scratchpad and 5 told to implement inside
a named worktree. The briefs were good and they were per-session; the standing
half was re-derived in that session's words because it was written nowhere.

**Do not retype the two environment variables into a brief.** *Making one*,
above, has them and what breaks without them. Point the worker at the tree and
give it the values from there, so there is one copy to keep true.

**The refusals are for the WORKER, and they are not what this page tells you.**
*Merging from a worktree* is written for the session that owns the tree. A
worker it spawns gets the opposite instruction, and it needs it in words: do not
push, do not open a pull request, **do not merge**, do not apply anything to the
remote database, and **never delete a file you did not create**. The 2026-09-17
prompts carried the middle three in some form. They did not carry *do not
merge*, and *never delete* survived only because one brief happened to say it.

**Give every path the worker needs, and expect the instruction not to hold.** A
worker hunting for a file it was not handed searches from the drive root, and
the process outlives the agent that started it: **18 such calls** across
2026-09-16, 09-18 and 09-19, every one from a spawned worker. One brief said
*"NEVER search from / or C:\\"* and gave the full path; two workers searched from
the root anyway, for fifty minutes. **So the paths are the control and the
sentence is a reminder** — and since `SKILL-AUDIT` `F54` the hook refuses the
shape outright, which is the control that does not depend on being read.

**Sweep after every batch, because that is what actually caught it.**
`Stop-Process` reports success on a stray search and leaves it running;
`taskkill /F /PID` ends it.
