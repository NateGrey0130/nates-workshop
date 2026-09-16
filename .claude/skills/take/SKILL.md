---
name: take
description: Take a numbered audit finding the way audit-menu requires, in the order it requires - grep every menu and the memory directory for the finding's subject, run the audit-premise-auditor on it, and only then create the branch. Use when told "take F76", "/take BOOK-INGEST-AUDIT F76", or whenever a numbered finding is about to be implemented. Adds nothing new; it exists so the two steps that get skipped cannot be skipped.
---

# /take <MENU> <ID>

`/take BOOK-INGEST-AUDIT F76`. The menu is the file's stem (`BOOK-INGEST-AUDIT`,
`SKILL-AUDIT`, `apps/pick3cut5/AUDIT`) and the id is the finding's own
(`F76`, `G8`, `M7`). **If either is missing, stop and ask which.** A bare number
identifies nothing - eleven menus number with `F` (`audit-menu` -> *Which is why
a finding reference names its menu*).

**This skill adds no rule.** Every step below is already in `audit-menu`, and
`audit-menu` is the authority; where the two disagree, that skill is right and
this file is stale. What this file adds is *order*: the two steps that were
skipped on every finding where they would have mattered - the subject grep and
the premise audit - run before anything that feels like starting work, and the
branch is the last thing created, not the first. `F33` was filed proposing a
detector that had already shipped; four `SHIP-PR-AUDIT` findings rested on a
claim about another file. Both are caught by steps 2 and 3, and both were
skipped because the branch already existed and the session was already
building.

**The steps run in order, and each one gates the next.** Do not start the grep
or spawn the auditor while step 1 is still reading: the first live run of this
skill (2026-09-16, `BOOK-INGEST-AUDIT F97`) fired steps 2 and 3 alongside step
1, and step 1 then found the finding already taken - a heading with no outcome
word on its line and a `**Taken, 2026-09-15 (PR #1082)**` note beneath it,
which is the trap `audit-menu` -> *Never grep for the outcome note* describes.
The grep and the agent were wasted. One step, read the answer, then the next.

## 1. Locate the finding, and read the menu's header first

```bash
find . -name '<MENU>.md' -not -path './node_modules/*'
```

Read the menu's **status header** before the finding - it is the status and
names that menu's own trap. Then find the finding's heading and read
everything under it bounded by the **next heading of any depth**, never by a
line count (`bound-section-edits-by-any-heading`):

```bash
grep -n -E '^#{2,4} .*\b<ID>\b' <menu-file>
```

Some menus keep findings in a table row rather than under a heading
(`audit-menu` -> *The headings are not uniform*); if the grep finds no heading,
grep the bare id and read the row. Quote the `**Proposal:**` paragraph and the
**posture** it asks for, in its own words, into your report. If the finding's
own heading or a note under it already records it as taken, closed, merged or
declined, **stop here and say so** - there is nothing to take.

## 2. Grep every menu and the memory directory for the SUBJECT

Not for the number. Take the nouns out of the heading and the proposal - the
filename, the mechanism, the flag, the setting, the endpoint - and grep every
menu in the repo for each of them, plus the memory directory, which no grep of
the repo reaches:

```bash
find . -name '*-AUDIT.md' -not -path './node_modules/*' | xargs grep -n -i '<subject word>'
grep -rn -i '<subject word>' ~/.claude/projects/*/memory/
```

**Print every hit with its file and line, or print `no hits` in those words.**
A `### F29 - high -` heading in another menu naming the same endpoint, or a
memory note saying *recorded so it is not re-proposed*, means the finding may be
reversing a decision already made with reasons, or building something that
already exists. Say which hits matter and why before going on. Never exclude
the menu being taken from this grep
(`subject-grep-must-not-exclude-its-own-file`).

## 3. Spawn the premise auditor, and print its disagreements

Spawn the `audit-premise-auditor` agent with the menu, the id, and the path.
It has no write tools, which is the point: the session that will build the
finding is not the session checking whether it is still true. Paste what it
returns **verbatim** - the disagreements, the posture in the proposal's words,
what still cites the finding, and how many premises it settled. *These premises
hold* is a real and common result; say so plainly and move on.

If the agent answers `Agent type 'audit-premise-auditor' not found`, the agents
junction is missing on this machine - `SETUP.md` -> *Setting up a machine*.
Run the audit by hand from `audit-menu` -> *Taking a finding is also AUDITING
the finding*, and say that you did.

## 4. Only then, the branch

Refuse unless all three hold, and say which failed:

```bash
git status --porcelain          # must be empty - another session may be mid-write in this tree
git branch --show-current       # must be main
git fetch -q && git status -sb  # must not be behind origin/main
```

Then, named for the menu and the finding, per `ship-pr` step 1:

```bash
git checkout -b <menu-stem-lowercase>-<id-lowercase>-<three-word-slug>
```

`book-ingest-audit-f76-talent-picks`, never `f76-talent-picks`.

## 5. Hand back, then stop

Report, in this order: the posture in the proposal's own words, the subject-grep
hits and what they mean, the auditor's disagreements or *premises hold*, the
branch name. **Then stop.** Implementing the finding is `ship-pr`'s loop and
Nate's word; taking it is this file's. If a hit in step 2 or a disagreement in
step 3 changes the scope or the posture, say so here and ask before building -
*"Take F6" means as written*, and a finding that turned out wrong is implemented
anyway with the correction in its note, or not at all on his word, never
quietly re-scoped.
