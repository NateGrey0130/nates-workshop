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

**`gh pr merge <n> --merge --delete-branch` exits 1 there, after the merge has
already happened.** The error is `fatal: 'main' is already used by worktree at
'C:/Users/natha/Projects/nates-apps'`: `gh` merges on GitHub first, then tries to
switch the current tree to the base branch, and git refuses because `main` is
checked out in the main checkout. PR #1142 went that way on 2026-09-17 — state
`MERGED`, remote branch deleted, only the local half failed.

**Never retry the merge on that error.** Read the state instead:

```bash
gh pr view <n> --json state,mergeCommit --jq '.state + "  " + .mergeCommit.oid'
```

Then do `ship-pr` steps 8 and 9 **from the main checkout**, with `git fetch`
rather than a pull into a tree another session may be using. Finally
`git worktree remove` (after the reparse-point scan above) and `git branch -D` —
capital `D`, because local `main` is behind and `-d` will call the branch
unmerged.

## What a worktree session does not inherit

The skills and agents load, because those are junctioned into `~/.claude` per
machine rather than per directory.

**Memory does not.** The memory directory is keyed to the working directory, and
the three that matter — the repo, the working directory and `Downloads` — are
junctioned to one real store. **A worktree gets its own project directory with no
memory directory at all**, verified 2026-09-21: the one worktree project folder
under `C:\Users\natha\.claude\projects` holds a transcript and nothing else.

So a session in a worktree starts blind to everything memory holds — including
the removal incident this page exists for. **Say what you learned into the PR
body or the audit menu**, which are the two stores a worktree session does share,
and do not assume the next session in one will know what this one did.
