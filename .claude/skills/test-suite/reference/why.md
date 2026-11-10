# Why test-suite's rules exist

`SKILL.md` states the rules; this holds the incidents and measurements behind
them, moved out of its *Reading a failure* and *The port, and the other
worktree that answers on it* so that the record is not loaded on every call of
the skill. Each section below is named for the one it came from, and the text
is moved unchanged. Read an undated claim as true on the day it was written.

## Reading a failure: the check's rows are not the whole cause

The OCR sweep in `apps/character-creator/test/regression.mjs` is the record.
Until 2026-09-18 it read only super abilities, and only for page numbers,
headings and junk. Commit `0d4bef06` widened it in two directions: three more
tables, and a digit-cipher pattern. It found 46 spells, 1 psionic power and 2
more super abilities (the comment at its `SELECT * FROM ${table}` loop). The
defects were mostly level headings attached to the end of a spell, with 8
spells in the cipher. None of those rows was red until someone widened what
was read.

### Why the rule lives in `CLAUDE.md`

Measured 2026-09-23
(`SKILL-AUDIT` `F67`): six sessions fixing a red check had the rule in this
section, and only one of them loaded this skill.
- Of the four that had it **only** here, that one session was the only one to
  act on it.
- The two that also had it in `CLAUDE.md` both acted on it from there. Every session
reads `CLAUDE.md`.

### Grep by the printed name

All four of Mystic
  Russia's spell imports are `zzzzzzzzzz-mr-*-spells.sql`, and a slug grep
  finds none of them (measured 2026-09-23).

## The port, and the other worktree that answers on it

On 2026-09-16 a run in one worktree left a `workerd`
listening; a later run from another worktree spawned its own wrangler on the
same port, and **its poll got a 200 from the foreign server.** It reported that
tree's catalog counts as a regression in this one, with a block of Talent
failures that read exactly like a real break.

## The harness, and the two things it will not let you hand-maintain

On a checks module declaring its sections twice:

`rendered-ui.mjs` carried two such names until 2026-09-17.

On the four pages that moved:

A sweep written the readdir way silently covered four
fewer files the moment they moved — the parse check stopped opening `sheet.js`
and said nothing, which is the exact hole it exists to close.

## Splitting a checks module

It passed 4,000
lines and `checks/environment.mjs` came out. It grew back past 10,000 and
`checks/second-body.mjs` took four Nightbane sections out. At 11,000, on
2026-10-10, nine more modules took thirty-nine sections.

On deriving the list:

Four scope-aware passes written during the second split each returned
a confidently wrong answer, and a bare count during the third was pessimistic
in the same way.
