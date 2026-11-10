# Why worktree's rules exist

`SKILL.md` states the rules; this holds the incidents and measurements behind
them, moved out so that the record is not loaded on every call of the skill.
Each section below is named for the one it came from, and the text is moved
unchanged. Read an undated claim as true on the day it was written.

## Checking whether another session is already in a tree

A session that checked all
three, found a clean `main`, no branches and no open PRs, and said so in its PR
was sharing the checkout with a live import session at the time.

## Removing one. This is the dangerous step

**On 2026-09-19 `git worktree remove` on five clean, merged worktrees emptied the
main checkout's `.cache/books` at the same second** — every sourcebook's OCR and
text-layer cache. The likeliest mechanism is that a worktree held the cache as a
**junction** to the main one and removal deleted through it; the worktrees were
gone by the time anyone looked, so it is not proven. All five printed `removed`.
Nothing warned.

## Briefing a worker you spawn into one

Measured 2026-09-17: one session spawned **23** workers, 16 following a
brief written into that session's own scratchpad and 5 told to implement inside
a named worktree. The briefs were good and they were per-session; the standing
half was re-derived in that session's words because it was written nowhere.

### The refusals are for the worker

The 2026-09-17
prompts carried the middle three in some form. They did not carry *do not
merge*, and *never delete* survived only because one brief happened to say it.

### Give every path the worker needs

One brief said
*"NEVER search from / or C:\\"* and gave the full path; two workers searched from
the root anyway, for fifty minutes.
