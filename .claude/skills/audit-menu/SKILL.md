---
name: audit-menu
description: Run this repo's audit-menu protocol — how a finding is numbered, scoped, taken, recorded and merged. Use when reading or writing an audit file, when told to "take F6" or any numbered finding, when adding a finding to a menu, and before quoting an audit's own text as fact. Covers why the outcome notes cannot be grepped, why audit files are records rather than documents, and the rule that taking a finding means auditing it first.
---

# The audit-menu protocol

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`), and (`smoke.mjs`) that this file
> requires correcting every class note citing a finding and points at
> `scripts/audit-citations.mjs`. The incident and measurement behind each rule
> is in `reference/why.md`.

A **findings menu** is a dated record of an investigation, carrying numbered
findings taken one at a time, on a separate word, one PR each. Nothing enforces
the protocol except `audit-menus.mjs` (each number used once) and
`menu-check.mjs` (claims about other files cite their source).

**Never trust a count of the menus, including one written anywhere.** Get the
list from the tree (the command under *The headings are not uniform*), then add
`SETUP-v2-CHANGES.md`, a menu whose filename does not say `AUDIT`.

## The loop

1. A finding is proposed, numbered, with a `**Proposal:**` paragraph specific
   enough to implement from and a stated **posture**.
2. **Nate names one**: "take F6". Nothing is taken until he does, and a menu is
   never worked top to bottom. **Taking is invoked by `/take <MENU> <ID>`** (the
   `take` skill): the subject grep and the premise audit from *Taking a finding
   is also AUDITING the finding*, in that order, and the branch last.
3. **One PR per finding.** Not two in a PR, not one across two.
4. A dated outcome note — `**Taken, <date> (branch <name>)**` — appended under
   the finding **in the same PR**, including whatever you found that contradicts
   it. The branch, not `PR #N`: the number does not exist when the note is
   written, and a second commit to fill it in is the cost this avoids.
   `gh pr list --state all --head <name>` finds the PR.
5. **Correct every class note that cites the finding, in the same PR.** A
   class's `extraction_notes` records what the book prints and what the app
   could do that day; taking a finding falsifies the second half.
   `node scripts/audit-citations.mjs --remote F10` lists who cites what, with no
   opinion on whether the finding was taken.
6. **Merge on a separate word.** Opening the PR is not permission to merge it.

"Take F6" means **as written, scope and posture both.** If the finding is
wrong, say so in the note and implement it anyway, or stop and ask. Never
quietly substitute your own scope.

## Posture is half of what is being agreed to

Log, do not cap. Warn, do not block. Opt-in. Documentation only. No new gate.
The right mechanism with the wrong posture is the wrong change: when a proposal
says "add a check but move no exit code", a check that fails the build is a
defect. **Say the posture back in the outcome note.**

## The shape a finding takes, so a brief does not have to say

A brief can say "findings follow the `audit-menu` shape" and stop. A finding
carries:

- **Severity** in the heading, in whatever shape the menu already uses.
- **`Proposal`** specific enough to implement from, and a stated **posture**.
- **Evidence**: the command and the day, or *inferred* / *not measured* /
  *reported by `<file>`* (see *Every number carries its date and its source*).
- **Confidence**: high / medium / low, **and what would raise it**
  (*"medium until someone runs X"*).
- **Ongoing cost**: what it costs forever once adopted. **A proposal whose
  ongoing cost exceeds its impact says so and recommends declining itself.**

Not *Effort* (wrong in both directions here) and not *Impact* (the severity and
proposal already say it). **Bound to the `Proposal`:** a finding that is still a
suspicion needs none of this, because filing must stay cheap. No check enforces
it, and no existing menu is retrofitted.

## Taking a finding is also AUDITING the finding

**The highest-value rule here.** Verify the premises against current code before
scoping, and lead the report with the corrections.

**Hand the premise check to the `audit-premise-auditor` subagent.** It has no
write tools, so it cannot start implementing while still checking, which is the
failure this rule keeps losing to. It reads the status header first, never greps
an outcome note, and returns the **posture** in the proposal's own words.

Two different failures hide here:

- **The finding's premises are wrong.** Rarer and expensive, because a taker
  implements from them. **Re-measuring catches these** (the auditor).
- **Something else turns out wrong while doing the work.** Near-universal and
  healthy. **Re-measuring does not catch these; measuring what you are about
  to write does.** That is yours, not the auditor's.

Distrust first what is cheapest to check: line numbers, counts, "X exists
nowhere", and any claim about what another **file** or finding says. The check
earns its place by what it finds, so run it every time.

**Do the subject grep here too** (next section). A finding proposing to build
something that already exists reads exactly like one proposing something new,
and every premise can hold while the work is already done.

### And before WRITING a proposal, grep the other menus for its subject

This catches **a proposal that reverses a decision another menu already made,
on purpose, with reasons**, or that proposes a capability that already exists.

- **Grep for the thing being proposed**: the filename, mechanism, setting or
  convention, not a finding number. **Include `~/.claude/.../memory/`**, which
  no repo grep reaches.
- **Menus defend closed decisions in searchable words**: *"Not to be
  re-proposed"*, *"Recorded so it is not re-proposed"*,
  `## Not carried forward, and why`. Those were written for this grep.
- **When a finding says something does not exist or cannot be done, settle it
  by running the code**: import the real module and point it at production. A
  claim about a capability is an absence claim in another coat.
- **In practice this fires when a finding is TAKEN**, so run it as step one of
  taking as well as before writing.
- **A finding may still re-propose a settled decision.** What it may not do is
  fail to say that the decision exists: name it, quote it, then argue past it.

No script: the grep hands back paragraphs, and noticing is the work.

### And before the menu is handed over, re-run every command it quotes

Once, on the whole menu, just before Nate reads it. **Report the pass in the
menu, including what did not move**: a table of every finding re-measured, the
ones found wrong, and the ones whose central claim held. Say what the pass
cannot see: a finding with no command to re-run, and a finding proposing a
*decision* (that is the grep above). No check, no schedule.

### A claim about ANOTHER FILE is the shape that fails

**Before FILING a finding, open every file it makes a claim about, read the
section, and put the grep, the path with a line number, or the date in the same
paragraph.** Not when it is taken: by then the sentence has been read and
believed. A claim about the file you are editing gets checked because it is
open; a claim about a different file is the one nobody opens.

**Absence is the worst case.** "X appears nowhere" is the claim most likely to
be wrong, in the direction that makes a finding look bigger. A grep that matches
one of two shapes proves nothing: **prove absence by reading.**

**`scripts/menu-check.mjs` runs this in CI** on the lines a PR adds to a menu,
flagging *appears nowhere*, *exists only in*, *does not mention*, *already
says*, *the existing* where nothing nearby gives a command, date or line number.
A backticked path does NOT count as a citation. It diffs **committed** lines, so
run it after committing. It cannot tell a quoted specimen from an assertion:
mark a quote `<!-- claim-ok: quoting the premise this note corrects -->`.

## A class note that cites a finding goes stale when the finding is taken

An `extraction_notes` entry is permanent (*what the book prints and what was
stored*) and perishable (*what the app could do that day*) in one paragraph.
**Write the DECISION and cite the finding; let the finding own the
mechanism.** *"Not stored; see F8"* never goes stale. Where the mechanism must
be in the class, write it past tense and name the PR.

`scripts/audit-citations.mjs` lists which classes cite which finding and flags
limitation language beside a citation. **It parses no outcome notes and has no
exit code**: a gate would fire on every class citing a still-open finding.

### It is not only class notes. ANYTHING that cites a finding goes stale

`audit-citations.mjs` sees class notes only. Other menus' headers and bodies,
memory files and skills also cite findings, and all have gone stale in practice.
**So when a finding is taken, grep the whole tree for its number (with its
menu), and check `~/.claude/.../memory/` too.** No script: noticing is the work.

### Which is why a finding reference names its menu

**A bare number defeats that grep.** Prefixes are not unique across menus: `F`
is used by most of them, and `D`, `N` and `R` by more than one each. So
`git log --grep='F18'` cannot tell you which `F18`. Re-walk the prefixes with:

```bash
for f in $(find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './docs/*') ./SETUP-v2-CHANGES.md; do
  grep -oE '^#{2,3} `?[A-Z][0-9]+' "$f" | sed -E 's/^#+ `?//; s/[0-9]+//' | sort -u
done | sort | uniq -c
```

**Name the menu wherever a finding number is written outside its own file**:

- `Take UI-AUDIT F30: …`, not `Take F30: …`
- branch `pal/audit/ui-audit-f30-banked-picks` (`CLAUDE.md` → *Naming*), not `f30-banked-picks`
- *"see `SKILL-AUDIT` F25(b)"*, not *"see F25(b)"*

**Inside its own file a bare number is right.** Do not put counts back in the
prefix census, and do not rewrite history.

## Never grep for the outcome note. Read under the heading

Grepping for `Taken` has reported shipped work open and open work closed. The
notes are prose (`Taken`, `Adjusted`, `Closed`, `Moot`, `Closed without being
taken`, a bare date) and sit under the finding, inside its `Proposal`, in a
table, or in a retirement section far away. `INGESTION-AUDIT` F14 quotes the
note's own shape, so every grep reports it taken.

**Closed findings live in `<MENU>.closed.md`**, text and numbering unchanged;
the live file keeps a one-line pointer where each heading was.
`ls *.closed.md apps/*/*.closed.md` is the list. A closed file is a record, and
its findings are not open.

**Read the lines under the heading, to the next heading.** Thirty seconds.

## What a status header may carry, and what it may not

A menu's dated header is the only place a status belongs. **The line is whether
a sentence can go stale on its own.**

**A header MAY carry:** whether anything is open and the instruction to read
under the finding; how to read the file (where a family of items hides from a
`###` scan, heading levels and prefixes, section order, what a reader misreads
if they stop early); scope, method and date; a dated historical statement,
marked as one.

**A header MAY NOT carry a per-finding state**: no range of closed numbers, no
count, no "`F3` is still open", no roll-call. Say **read under the heading** and
stop. The state lives under the finding, in the PR that changes it.

- **Shape paragraphs are not restricted.** *"`CLASS-AUDIT`'s `S` items are
  bullets"* stays true as findings close. Keep them; write more.
- **An instruction about how to implement** is not a claim about what is open.
- **The prohibition applies wherever the sentence is written**: a `##` lead, an
  outcome note, a preamble. A numberless claim about numbered work is invisible
  to every sweep here, so not writing one is the only defence.

No retrofit and no check.

## The headings are not uniform, and that is the argument

**This table is a shape reference for the files it names. It is NOT the list of
menus**; a file missing from it is missing, not absent. The menu you are writing
is the row you will forget: **add it in the PR that creates the file.**

| file | prefix | level | shape |
|---|---|---|---|
| `BOOK-INGEST-AUDIT.md` | `F` | `###` | em dash on `F1`–`F4`, hyphen from `F5` on |
| `DOCS-AUDIT-2.md` | `D` | `###` | severity word: `### D1 — medium — …` |
| `MACHINE-AUDIT.md` | `M` | `###` | severity word: `### M1 — high — …` |
| `META-AUDIT.md` | `A` | `###` | severity word: `### A1 — medium — …`, **not in severity order** — it runs in its brief's order |
| `REPO-AUDIT.md` | `G` | `###` | severity word: `### G1 — high — …` |
| `DOCS-AUDIT.md` | `D` | `###` | severity **or status** word: `### D1 — low — …`, and `### D5 — WITHDRAWN — …` |
| `EFFICIENCY-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/AUDIT.md` | `D`, `C`, `F` | `###` | severity word: `### D1 — low — …` |
| `apps/character-creator/CLASS-AUDIT.md` | `F`; `S` | `###`; **not a heading** | `### F17 — low — …`, and `- **S1 — …**` as BULLETS under `## Schema-can-now-express` |
| `apps/character-creator/INGESTION-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REBUILD-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REDESIGN-AUDIT.md` | `R`, `N` | `###` | severity word: `### R1 — high — …` |
| `apps/character-creator/RETRO-AUDIT.md` | `R` | `###` | severity word: `### R1 — high — …`. **Its `R` collides with `REDESIGN-AUDIT`'s**, so a bare `R3` names neither |
| `apps/character-creator/UI-AUDIT.md` | `F` | `###` | severity word: `### F1 — high — …` |
| `WORKSHOP-UI-AUDIT.md` | `W` | `###` | severity word: `### W1 — high — …`. **No other menu uses `W`**, chosen from a census so a bare number is unambiguous |
| `apps/media-vault/SHARE-AUDIT.md` | `V` | `##` | `## V1 — high — …`. **No other menu here uses `V`**, chosen so a bare number is unambiguous |
| `apps/media-vault/BULK-AUDIT.md` | `B` | `##` | `## B1 — …` |
| `apps/media-vault/ISBN-AUDIT.md` | `F` | `##` | `## F1 — …` |
| `apps/pick3cut5/AUDIT.md` | `F`; `T` | `###`; **not a heading** | `### F1. …`, and `**T1. … — PASSED.**` as BOLD PARAGRAPH LEADS under `## T — paths that have never run` |
| `HEALTH-AUDIT.md` | `F` | `###` | severity word, capitalised: `### F1 — Critical — …` |
| `SKILL-AUDIT.md` | `F`, `N` | `###` | `### F1 — …`, no severity word, and **every `###` is a finding** (`F38`, 2026-09-04). That file's own header names its sections. |
| `SHIP-PR-AUDIT.md` | `F` | `###` | `### F1 — …`, no severity word |
| `SETUP-v2-CHANGES.md` | **none** | `###` | `### 1. …` — bare numbers under `## Changes`, and the one menu whose filename does not say `AUDIT` |

Two heading levels, an optional severity word, an em dash, a hyphen or a period,
and two files where a whole family is **not a heading at all** (`CLASS-AUDIT`'s
`S` bullets, `pick3cut5/AUDIT`'s `T` paragraph leads, each under its own `##`).
A `###` scan does not see those. **Read; do not pin shape with a check.**
(`audit-menus.mjs` checks only that a number is used once.)

Get the list from the tree, then read each file's own headings:

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

**That command is wrong in both directions, and neither is a bug in it:** it
misses `SETUP-v2-CHANGES.md`, and anything it returns under `docs/prompts/` is
a brief, not a menu. The answer is its output, minus the briefs, plus the one it
cannot see. **Do not fix it with a better pattern**, and **do not fix it with an
index file**: declined twice (`REPO-AUDIT` `G9`, `META-AUDIT` `A1`), because
the file list is derivable and a status column rots faster than anything else.

## Audit files are RECORDS. Do not rewrite a measurement

A number true on the day it was measured is not rot; editing it destroys the
only account of what was found. When the world moves, **append a dated banner or
an `**Adjusted <date>**` note** and leave the original standing.

- **Correct the current claim; never quote the stale phrase you replace.** A
  note repeating the old wording defeats a grep for it.
- **A correction inherits the scope of the sentence it corrects.** Say which
  scope you mean.

## Every number carries its date and its source

`124 / 126 classes` means nothing alone. Write where it came from
(`source-coverage.mjs --remote`, `claude_usage`, the smoke summary) and the day.
Ask production, not `--local`. Quote a moving number only where something pins
it; the tests pin each book's row count in its survey, and a count in prose does
not survive.

### And a `Proposal` says whether its central claim was measured or reasoned to

The claims that caused damage here carried no number: **reasoned to, not run.**
A wrong measurement is caught when someone re-runs the command; **a wrong
inference gets implemented**, because it reads as settled.

So a **`Proposal:` paragraph names its evidence in one line**: the **command and
the day** it was run, or the words **inferred**, **not measured** or **reported
by `<file>`**. **Where a proposal tells a taker to run a command, say whether you
ran it.** Bound to the `Proposal` only: the observation above it stays free-form,
because a suspicion is allowed to be a suspicion. No check, no retrofit.

## Where a new menu goes

By **what the menu is about**:

- **the repo root**: anything spanning more than one app, or the repo, the
  process, the machine or the instruction layer;
- **the app's own directory**: anything scoped to exactly one app.

No count belongs in this rule. `BOOK-INGEST-AUDIT.md` sits at the root while
being about one app; it is not moved, because existing paths are cited from
places no grep reaches. The rule is for the next menu.

## And where a closed menu goes: nowhere. It stays

A menu with no open work is **not** archived, moved, folded or deleted
(Nate's posture, `docs/prompts/meta-audit-prompt.md`, 2026-09-03; `META-AUDIT`
`A15`). Its path is cited from menus, skills, briefs and memory, and it is still
the record of what was decided and why. **Do not re-propose:** an index of the
menus, archiving closed menus, or a retirement section collecting closed items
away from their headings (a documented trap in `INGESTION-AUDIT`). The cost, a
tax on every tree-wide grep, is accepted.

## A deferral is work. Give it a number or say you are dropping it

A finding that scopes part of its subject out and names the rest *"a separate
finding"* must **file it in the same PR and cite it by number, or write that it
is dropping it.** Filing obliges nobody (*When not to* forbids *taking* a finding
in the PR that adds it, not adding one). A deliberate drop is a complete answer.
What is refused is naming the work, not filing it, and leaving a reader to guess.
This is `book-survey` §8's "file the gap and keep going", applied to findings.
No check, no index of deferrals, no retrofit.

## When not to

Do not open a new menu for work belonging in an existing one, and **do not add a
finding you intend to take in the same PR**: the numbering exists so the decision
to take it can be separate. Do not add a check that a finding was taken or that
the open count is right: the notes vary in wording by design.

**Do not open a menu about the audit apparatus itself without Nate asking for one
by name** (a default since 2026-09-04). The apparatus is the most-measured thing
here and a menu about the loop can cost more in rework than it returns. Menus
about the product (an app, the catalog, the data, the UI) are unaffected, and a
single finding about the apparatus still belongs on the existing menu that owns
that surface. The pause expires when Nate says so.
