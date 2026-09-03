# Documentation audit, second pass — 2026-09-02

> **Status: `D2` and `D3` are OPEN, both `low`. `D1` is taken.** Status for any
> finding lives under its own heading; this line does not count them. Five
> repairs were made in this pass and are listed under **Fixed here**; they are
> not findings and carry no numbers.
>
> **This menu's own trap:** four of the five things it repaired were *already
> recorded as done* by a closed finding in another menu. `M7` moved the working
> directory, `M13` settled the briefs, `M14` reconciled the two `launch.json`
> files and `M17` swept the memory store — all on this same day, all closed. The
> rot this pass found is not in any of that work. It is in the instruction files
> that **point at** what those findings moved, which no closed finding owned.
> Read a finding here as *"the move was recorded and the pointers were not"*,
> never as *"the move was botched"*.

Read-only pass over three surfaces — the repo's `.md`, the instruction layer
(`CLAUDE.md`, `.claude/skills/`, `.claude/agents/`) and the machine layer outside
the repo (`~/.claude/CLAUDE.md`, the memory store, `C:\Users\natha\Projects\workshop`).
Run against `main` after the day's merges, production D1 via `--remote`, and a
clean smoke run (1655 checks in 113 sections, before and after the repairs).

Driven by the brief at `workshop\briefs\docs-audit-2-prompt.md`. **Three of that
brief's own premises were wrong**, which is recorded below rather than quietly
fixed, because two of them are the exact failure this audit is about.

## The pattern worth naming

**A move gets recorded where it happens and rots where it is pointed at.**

2026-09-02 moved the working directory from `Downloads` to
`C:\Users\natha\Projects\workshop`. Every menu that owned a piece of that move
closed its finding: `M7` did the move, `M13` proved the briefs were archived byte
for byte, `M14` reconciled the untracked `launch.json`, `M17` corrected eleven
memories that named the old path.

The memory store came out of it **more accurate than the repo did.** The
`two-allowlists` memory now says `<working dir>\.claude\settings.local.json` —
generic, so it cannot rot again — while `CLAUDE.md` was still naming the full
old absolute path hours later, in a section describing a file that had moved that
afternoon. The sweep ran where a finding pointed it and stopped there.

Nothing walks the other direction: from a path that moved, to every sentence that
names it. That is `D1`.

## Fixed here

Unambiguous rot in live instructions, each verified against the filesystem rather
than inferred, and each a pointer at something a closed finding had already moved.
Described rather than quoted, so the grep that should find the next copy is not
defeated by this table.

| what | where |
|---|---|
| A permission claim that the same day's prune reversed — the skill told the next session an arbitrary-execution wildcard was available where it fires; that wildcard was removed hours earlier | `.claude/skills/book-survey/SKILL.md` |
| The escape-hatch port instruction named a second `launch.json` at a path that no longer exists | `.claude/skills/verify-ui/SKILL.md` |
| The subagent-spawn directory, and the illustration of where a session starts | `CLAUDE.md` |
| The second allowlist's path — a whole section addressed a file by an absolute path that had moved that afternoon | `CLAUDE.md` |
| The subagent-spawn directory, in the junction block | `SETUP.md` |

The `book-survey` one is the only repair here that changes what a reader would
**do**. The others repoint a path; that one had the permission backwards, and its
paragraph had already been wrong once in the opposite direction — so it now
carries an instruction to check the live allowlist rather than a third assertion
about it.

## Findings

### D1 — medium — nothing walks from a moved path to the sentences naming it

Four instruction files named the old working directory hours after the move, in a
day that produced a dedicated move finding, a memory sweep and two reconciliation
findings. They were not missed through carelessness: each sweep was scoped to what
its own finding owned, and no finding owned *"every sentence in the instruction
layer that names an absolute path"*.

The cost is asymmetric. A stale path in an audit file is history. A stale path in
a **skill** is an instruction, and one of the four told a session that a
permission existed after it had been revoked.

**Proposal:** a check that reads the instruction layer — `CLAUDE.md`,
`.claude/skills/**`, `.claude/agents/**`, `SETUP.md` — extracts every absolute
Windows path, and fails on one that does not resolve on this machine. Not a
grep for `Downloads`: the point is to catch the *next* move, not this one.
Paths inside fenced blocks that are deliberate examples, and paths inside
explicitly dated historical sentences, need an exemption — probably by requiring
that a non-resolving path sit next to a date.

**Posture:** a new check in the existing smoke suite, failing the build. No new
file layout, no move of any instruction, and **no exemption list keyed to today's
paths** — an allowlist of known-dead paths would rot exactly like the sentences
it excuses.

**Decline it** if the exemption rule looks like more machinery than the problem
justifies; the alternative is one sentence in `claim-audit` telling a mover to
grep the instruction layer for the path they changed, which is cheaper and
weaker.

**Taken, 2026-09-03 (PR #609), as the PRIMARY proposal — the check, in the smoke
suite, failing the build.** Scope as written: `CLAUDE.md`, `SETUP.md`,
`.claude/skills/**`, `.claude/agents/**`. Not a grep for the old directory name.
**No exemption list**, which this finding's posture forbids and which turned out
not to be needed at all.

`apps/character-creator/test/checks/instruction-paths.mjs`, wired into
`smoke.mjs` beside the other check modules and run before the wrangler-backed
ones.

**The open question this finding leads with does not arise, and that is why the
primary proposal was taken rather than the cheaper alternative.** It asks how to
exempt *"paths inside explicitly dated historical sentences"*, and calls that the
thing that might make this more machinery than it is worth. Measured
2026-09-03: **15 checkable absolute paths in the instruction layer and all 15
resolve.** Nothing is dead, so nothing needs exempting, and no date rule was
built. If a genuinely historical path is ever written there, the first failure is
the right moment to decide — cheaper than machinery built for a case that does
not exist.

**What is actually hard is extraction, which this finding does not mention.**
A whitespace-delimited regex over the same corpus was measured at a **100%
false-positive rate**: five reported failures, all five spurious.

| what broke it | example |
|---|---|
| a path containing a **space** | `` `C:\Program Files\Git\cmd` `` truncates to `C:\Program`, which never resolves — four of the five |
| a **shell template**, not a path | `"…\.claude\skills\$s"`, a PowerShell loop variable in a fenced block in `SETUP.md` |

So paths are read out of **inline code spans and quoted strings** — which is how
this repo writes them, and which gives a delimiter that survives a space — and
any span carrying `$`, `%VAR%` or a `<placeholder>` is skipped as a template.
That templated skip is narrower and simpler than the *"exempt fenced blocks"*
rule sketched above, and it covers the only fenced-block path that exists. A real
path written outside a span is invisible to the check: a **miss**, not a false
failure, which is the direction a gate should fail in.

**Proved by making it fail**, which is the only reason to trust a new gate. Two
dead paths were planted in `CLAUDE.md` and the check reported both and exited
**1**:

```
FAIL every absolute path in the instruction layer resolves —
  CLAUDE.md:7 C:\Users\natha\Projects\moved-away\briefs;
  CLAUDE.md:8 C:\Program Files\NotInstalled\thing.exe
```

The second is the one that matters: **a spaced path, caught** — the exact shape
the naive version could not even represent. Reverted, and the flagless suite runs
clean.

**Two guards against a vacuous pass**, because "every path resolves" is trivially
true when nothing is being read. The check asserts the walk finds at least ten
instruction files and that at least eight checkable paths were extracted. Without
those, a broken walk or a broken span regex reports success while checking
nothing — which is this finding's own failure mode wearing a green tick.

Smoke 1655 → **1658 in 114 sections.**

**One consequence worth stating, since this finding did not.** The check resolves
paths **on this machine**, so a fresh clone elsewhere fails it — every
`C:\Users\natha\…` is absent there. That is not a new class of problem: the
suite already shells out to `wrangler` and reads a local D1, so it has never been
runnable on a bare clone. But it is one more thing `SETUP.md` → *Setting up a
machine* would have to account for, and it is recorded here rather than
discovered there.

### D2 — low — `docs/surveys/` has no index, and `docs/plans/` does

Ten surveys, no `README.md`. `docs/plans/` carries one that states what a plan is,
that it describes the code as of its writing date, and which plan is most changed
since — the note that turns "this is wrong" into "this is old".

The surveys need the same framing more than the plans do, because a survey is a
reading of a **book** taken on a date, against a catalog that has moved since.
Six of the ten have no direct inbound reference from anywhere in the repo.

**They are not orphans**, and that is why this is `low` — `book-survey` and
`class-import` both address the directory by slug pattern, so every file in it is
reachable by the rule rather than by a link. What is missing is a reader's list of
which books have been surveyed and what a survey is for.

**Proposal:** a short `README.md` in `docs/surveys/`, naming what a survey is, the
as-of-date rule, and listing the slugs with their book titles. **Do not** put
counts of spells or skills in it.

**Posture:** documentation only, one new file, no survey body touched.

### D3 — low — two byte-identical duplicate pairs inside `briefs\`

`REVIEWBRIEF.md` is byte-identical to `REVIEW-BRIEF.md`, and
`setupv2rewriteprompt.md` to `setup-v2-rewrite-prompt.md` — same sizes, no
difference at all once line endings are normalised. Both pairs are un-hyphenated
second copies sitting beside their hyphenated originals.

`M13` covers the *archive* relationship completely and this is not a gap in it:
both hyphenated originals are archived, and `M13` establishes that loose working
copies are redundant rather than authoritative — "safe to keep, and safe to lose".
This finding is only about the second copy of a file that is already loose.

**Proposal:** delete the two un-hyphenated copies. Nothing references them by
either name.

**Posture:** delete two untracked working files outside the repo, nothing else.
**Decline it** freely — by `M13`'s own reasoning these are safe to keep, and the
only cost is two confusing filenames in a directory a person reads by eye.

## Routed elsewhere

Two findings belong to `MACHINE-AUDIT.md`'s surface rather than this one, and are
filed there as `M19` and `M20` rather than duplicated here:

| there | what |
|---|---|
| `M19` | the global `~/.claude/CLAUDE.md` lists what the working directory holds, and the list is short by two entries created the same day |
| `M20` | the old memory store's `memory\` directory survives as an empty husk under the old key |

`audit-menu` says not to open a new menu for work an existing one owns. The
instruction-layer repairs above would by the same rule belong to `SKILL-AUDIT.md`
— they are in **Fixed here** rather than filed as findings, so they open nothing.

## Three premises of this audit's own brief were wrong

Recorded because the brief was written four hours before the audit ran, by the
same process the audit is about.

- **"The archive is missing at least four briefs."** It is missing none. `M13`
  had already established that an unrun brief stays in the working directory by
  the archive's own rule, and that two of the four named files are game content
  rather than briefs at all. The brief turned a directory listing into a gap
  without reading the finding that had settled it **that morning**.
- **"Every one of the nine skills was edited today."** True, and it replaced an
  earlier draft that said eight — a count in prose, in a brief whose subject is
  counts in prose.
- **"`SETUP.md` is on the machine layer, outside the repo."** It is at the repo
  root. Corrected before the run.

The first is the one worth keeping. A brief that lists what a directory contains
and calls the difference a finding will produce exactly this, and the defence is
the audit-menu rule it skipped: **read the finding that owns the surface before
filing against it.**

## What was checked and found healthy

Worth recording, so the next pass does not redo it. Four of these read as defects
and are not.

- **The subagent looks like an unlinked copy and is not.** `~/.claude/agents/book-reconcile.md`
  shows in `ls` as a regular file with no link marker, because the junction is on
  the **directory**. Same inode as the repo's copy, confirmed with `fsutil`. The
  per-file symlink alternative needs elevation, which `SETUP.md` explains — the
  directory shape is forced, not sloppy, and it is why the link survived the move
  untouched.
- **All nine skills are genuine symlinks** into the repo, one per skill, matching
  the junction block in `SETUP.md`.
- **The ten survey files are not orphans**, despite six having no inbound link.
  They are addressed by slug pattern from two skills. Filing them as orphans on
  the strength of a link check would have been wrong.
- **`known-limitations.md`'s "a flat constant on top of dice AND an attribute is
  not expressible" is still true.** Checked against `js/dice.js`: the grammar
  reads a dice expression and an attribute, and a third standalone term is still
  dropped rather than added. This is the shape most likely to have rotted and it
  has not.
- **No orphaned class rows in production D1.** 160 published, and no other status
  at all — nothing soft-deleted, nothing stranded in draft.
- **The allowlist prune held across the move.** The moved file carries 258
  entries, matching what `CLAUDE.md` records; no write or arbitrary-execution
  wildcard survives, and the ten remaining wildcards are read-only or
  `git fetch` / `ls-remote` / `check-ignore`.
- **The memory store's historical `Downloads` references are correctly dated.**
  Twelve of sixty-five name it; each one reads as a past observation with its date
  attached, which is a measurement and keeps. Only the *filename*
  `two-allowlists-downloads-and-repo.md` still carries the old word, and renaming
  it would break the `[[links]]` pointing at it for no gain.
- **`docs/prompts/` was left entirely alone**, per its own README: those are
  records of what was asked, not documents to reconcile with what happened.

One process note, because it nearly produced a false result here: **a truncated
grep looks exactly like a complete one.** A repo-wide search for the old path,
piped through `head`, cut off before `SETUP.md` and returned a clean-looking list
that was missing a file with three hits. It was caught only because that file was
opened directly for another reason.
