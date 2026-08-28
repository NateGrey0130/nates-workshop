---
name: audit-menu
description: Run this repo's audit-menu protocol — how a finding is numbered, scoped, taken, recorded and merged. Use when reading or writing an audit file, when told to "take F6" or any numbered finding, when adding a finding to a menu, and before quoting an audit's own text as fact. Covers why the outcome notes cannot be grepped, why audit files are records rather than documents, and the rule that taking a finding means auditing it first.
---

# The audit-menu protocol

Eight files here are **findings menus**: dated records of an investigation,
carrying numbered findings taken one at a time, on a separate word, one PR each.
Nothing enforces any of it — it lived only in the files, and was reconstructed
from them nine times before this was written.

## The loop

1. A finding is proposed, numbered, with a `**Proposal:**` paragraph specific
   enough to implement from and a stated **posture**.
2. **Nate names one** — "take F6". Nothing is taken until he does, and a menu is
   never worked top to bottom.
3. **One PR per finding.** Not two in a PR, not one across two.
4. A dated outcome note — `**Taken, <date> (PR #N)**` — appended under the
   finding **in the same PR**, including whatever you found that contradicts it.
5. **Merge on a separate word.** Opening the PR is not permission to merge it.

"Take F6" means **as written — scope and posture both**, not the version you
would have proposed. If the finding is wrong, say so in the note and implement
it anyway, or stop and ask. Never quietly substitute your own scope.

## Posture is half of what is being agreed to

Log, do not cap. Warn, do not block. Opt-in. Documentation only. No new gate. A
finding taken with the right mechanism and the wrong posture has shipped the
wrong change: when a proposal says "add a check but move no exit code", a check
that fails the build is a defect even though it works. Say the posture back in
the outcome note — cheapest place to catch a misread.

## Taking a finding is also AUDITING the finding

**The highest-value rule here.** Verify the premises against current code before
scoping, and lead the report with the corrections.

Every finding taken so far has turned up an error in its own premises — not a
slur on the audits, just what happens when a document sits still while the tree
moves. One such error would have shipped a silent bug if implemented as written.
Distrust first whatever is cheapest to check: line numbers, counts, "X exists
nowhere", and any claim about what another finding says.

## Never grep for the outcome note. Read under the heading

Grepping for `Taken` has produced **four** false findings here.

The notes are prose — `Taken`, `Adjusted`, `Closed`, `Moot`, `Closed without
being taken`, or a bare date — sitting under the finding, inside its `Proposal`
paragraph, in a separate table, or in a retirement section three hundred lines
away.

The worst case is not odd wording. `INGESTION-AUDIT` **F14**, the finding that
*describes this format*, carries the note's own shape inside backticks as an
example, so every grep reports it taken. It is open. The trap runs the other way
too: F12, F16 and F19 there are closed as moot in a retirement section rather
than under their headings, so scanning the findings alone reports three open
that are not. On one page the two errors cancelled into a plausible total and a
PR shipped the wrong count.

**Read the lines under the heading, to the next heading.** Thirty seconds.

## The headings are not uniform, and that is the argument

| file | prefix | level | shape |
|---|---|---|---|
| `DOCS-AUDIT.md` | `D` | `###` | `### D1 — …` |
| `EFFICIENCY-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/AUDIT.md` | `D`, `S` | `###` | closed, all fourteen |
| `apps/character-creator/CLASS-AUDIT.md` | `F`, `S` | `###` | severity word: `### F17 — low — …` |
| `apps/character-creator/INGESTION-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/media-vault/BULK-AUDIT.md` | `B` | `##` | `## B1 — …` |
| `apps/media-vault/ISBN-AUDIT.md` | `F` | `##` | `## F1 — …` |
| `apps/pick3cut5/AUDIT.md` | `F`, `T` | `###` | trailing period: `### F1. …` |

Two heading levels, five prefixes, an optional severity word, an em dash or a
period. Any regex will be wrong about at least one file — which is the argument
for reading, and against pinning any of this with a check.

## Audit files are RECORDS. Do not rewrite a measurement

A number true on the day it was measured is not rot; editing it destroys the
only account of what the audit found. When the world moves under a finding,
append a dated banner or an `**Adjusted <date>**` note and leave the original
standing. PR #310 established this — three audit files cited a README layout
that no longer existed and each gained a banner, plus the command that turns a
section name into a location (`scripts/readme-section.mjs`), rather than having
its paths edited.

**Correct the current claim; never quote the stale phrase you replace.** A note
repeating the old wording defeats a grep for it, and a check asserting a file
"no longer says X" passes the day someone deletes the row entirely.

**A correction inherits the scope of the sentence it corrects.** A paragraph
listing what was open *before* four findings were added is not a statement about
all of them, and a correction to it is not either. Say which scope you mean.

## An absence claim needs a fresh read, not a grep

`CLASS-AUDIT` F17 reported missing attribute requirements in seven classes.
**Five of the seven were false** — those classes held their printed requirements
in multi-line blocks and the audit had grepped the inline `{ }` form, concluding
absence from a pattern matching one of two shapes. What was real was smaller and
different in kind: one class carried *wrong* values rather than none, and the
fix turned up two page ranges the finding never listed.

**"X appears nowhere" is the claim most likely to be wrong**, and wrong in the
direction that makes a finding look bigger than it is. Prove absence by reading.

## Every number carries its date and its source

`124 / 126 classes` means nothing alone. Write where it came from —
`source-coverage.mjs --remote`, `claude_usage`, the smoke summary — and the day.
Ask production: `--local` accumulates, and has reported catalog duplicates that
production merged away weeks earlier. Quote a moving number only where something
pins it; the test suite pins the README's counts, so those survive, and a count
in prose does not.

## When not to

Do not open a new menu for work belonging in an existing one, and do not add a
finding you intend to take in the same PR — the numbering exists so the decision
to take it can be separate. Do not add a check that a finding was taken or that
the open count is right: the notes vary in wording by design, and a mechanical
reader is exactly the thing that has got this wrong four times.
