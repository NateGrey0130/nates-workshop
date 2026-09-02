---
name: audit-menu
description: Run this repo's audit-menu protocol — how a finding is numbered, scoped, taken, recorded and merged. Use when reading or writing an audit file, when told to "take F6" or any numbered finding, when adding a finding to a menu, and before quoting an audit's own text as fact. Covers why the outcome notes cannot be grepped, why audit files are records rather than documents, and the rule that taking a finding means auditing it first.
---

# The audit-menu protocol

A **findings menu** is a dated record of an investigation, carrying numbered
findings taken one at a time, on a separate word, one PR each. Several files
here are one. Nothing enforces any of it — it lived only in the files, and was
reconstructed from them nine times before this was written.

**Do not trust a count of them, including one written here.** This sentence used
to say "Eight files", the table below listed ten, and the tree held twelve — and
by the time that was corrected the tree held fourteen. Get the list from the
tree, with the command under the table, and remember the fourteenth:
`SETUP-v2-CHANGES.md` is a menu whose filename does not say `AUDIT`, so no glob
for that word will find it.

## The loop

1. A finding is proposed, numbered, with a `**Proposal:**` paragraph specific
   enough to implement from and a stated **posture**.
2. **Nate names one** — "take F6". Nothing is taken until he does, and a menu is
   never worked top to bottom.
3. **One PR per finding.** Not two in a PR, not one across two.
4. A dated outcome note — `**Taken, <date> (PR #N)**` — appended under the
   finding **in the same PR**, including whatever you found that contradicts it.
5. **Correct every class note that cites the finding, in the same PR.** A
   class's `extraction_notes` records both what the book prints and what the app
   could do that day; taking a finding falsifies the second half wherever it was
   written down. `node scripts/audit-citations.mjs --remote F10` lists who cites
   what — it has no opinion about whether the finding was taken, which is
   deliberate (see below).
6. **Merge on a separate word.** Opening the PR is not permission to merge it.

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

## A class note that cites a finding goes stale when the finding is taken

An `extraction_notes` entry does two jobs in one paragraph. *What the book
prints and what was stored* is permanent. *What the app could do on the day of
the import* is not, and it rots inside a record that otherwise stays true.

**Write the DECISION and cite the finding; let the finding own the mechanism.**
*"Not stored; see F8"* never goes stale. *"`rollAttribute` parses only NdM
forms"* always will. Where the mechanism has to be in the class, write it
past-tense and name the PR — the same doctrine this file already applies to
audit measurements, extended to class prose.

`scripts/audit-citations.mjs` lists which classes cite which finding, and flags
passages carrying limitation language beside a citation. **It parses no outcome
notes and has no exit code**, for the reason in the next section: a mechanical
reader of those notes has been wrong repeatedly, and a gate would fire on every
class citing a still-open finding, which is the correct and useless answer. It
answers *who mentions F8*; whether the citation is stale stays a judgement.

This was skipped once and the false claim reached production and stayed for
three PRs. It recurred three more times in a single day — two Prometheans and
the Fallen Cosmo-Knight, from PRs merged hours earlier.

## Never grep for the outcome note. Read under the heading

Grepping for `Taken` has produced false findings here **repeatedly, and in both
directions** — work reported open that had shipped, and work reported closed
that had not.

**How many times is not written down on purpose.** This section used to say
four; two paragraphs earlier the same file said five, and a third place said
four again. The number was wrong somewhere no matter which you believed, and it
moved twice more on 2026-09-02 alone — once when an audit's own census script
split a finding's block on an inline `**F10 …**` cross-reference and reported a
shipped finding as open, and again when `apps/character-creator/AUDIT.md`'s
header caught its third scan misreading D1–D6. A tally of a recurring failure is
one more thing to keep current, and this file is about not doing that.

The notes are prose — `Taken`, `Adjusted`, `Closed`, `Moot`, `Closed without
being taken`, or a bare date — sitting under the finding, inside its `Proposal`
paragraph, in a separate table, or in a retirement section three hundred lines
away.

The worst case is not odd wording. `INGESTION-AUDIT` **F14**, the finding that
*describes this format*, carries the note's own shape inside backticks as an
example, so every grep reports it taken.

**And it IS taken — in PR #364, which is the PR that produced this file.** That
is the sharper version of the lesson, not a softer one. The grep said "taken"
from 2026-08-26, when F14 was filed, until 2026-08-28, when it shipped: two days
of being confidently right about a question it had not looked at. It stopped
being wrong because the world moved, not because anything checked. **A
coincidence is not a check**, and a reader who confirmed the grep's answer
against reality on 08-29 would have concluded the method works.

*(Until 2026-09-02 this paragraph ended by declaring F14 outstanding — true when
written, because F14 was still open while the skill it asked for was being
drafted, and left standing for five days after it shipped. The file that warns
against stale outcome claims carried one about its own origin.)*

The trap runs the other way too: F12, F16 and F19 there are closed as moot in a
retirement section rather than under their headings, so scanning the findings
alone reports three open that are not. On one page the two errors cancelled into
a plausible total and a PR shipped the wrong count.

**Read the lines under the heading, to the next heading.** Thirty seconds.

## The headings are not uniform, and that is the argument

| file | prefix | level | shape |
|---|---|---|---|
| `BOOK-INGEST-AUDIT.md` | `F` | `###` | em dash on `F1`–`F4`, hyphen from `F5` on |
| `DOCS-AUDIT.md` | `D` | `###` | `### D1 — …` |
| `EFFICIENCY-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/AUDIT.md` | `D`, `C`, `F` | `###` | severity word: `### D1 — low — …` |
| `apps/character-creator/CLASS-AUDIT.md` | `F`; `S` | `###`; **not a heading** | `### F17 — low — …`, and `- **S1 — …**` as BULLETS under `## Schema-can-now-express` |
| `apps/character-creator/INGESTION-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REBUILD-AUDIT.md` | `F` | `###` | `### F1 — …` |
| `apps/character-creator/REDESIGN-AUDIT.md` | `R`, `N` | `###` | severity word: `### R1 — high — …` |
| `apps/character-creator/UI-AUDIT.md` | `F` | `###` | severity word: `### F1 — high — …` |
| `apps/media-vault/BULK-AUDIT.md` | `B` | `##` | `## B1 — …` |
| `apps/media-vault/ISBN-AUDIT.md` | `F` | `##` | `## F1 — …` |
| `apps/pick3cut5/AUDIT.md` | `F`; `T` | `###`; **not a heading** | `### F1. …`, and `**T1. … — PASSED.**` as BOLD PARAGRAPH LEADS under `## T — paths that have never run` |
| `HEALTH-AUDIT.md` | `F` | `###` | severity word, capitalised: `### F1 — Critical — …` |
| `SETUP-v2-CHANGES.md` | **none** | `###` | `### 1. …` — bare numbers under `## Changes`, and the one menu whose filename does not say `AUDIT` |

Two heading levels, an optional severity word in either case, an em dash or a
hyphen or a period, more distinct prefixes than are worth counting — one file
uses no prefix at all — and two files where a whole family of items is **not a
heading at all**. Any regex will be wrong about at least one file, which is the
argument for reading, and against pinning any of this with a check.

**The not-a-heading rows are the sharpest version of that argument.**
`CLASS-AUDIT`'s nine `S` items are bullets and `pick3cut5/AUDIT`'s eleven `T`
items are bold paragraph leads, so a scan that walks `###` headings does not
report them open — it does not see them at all, and twenty items vanish with no
error. Both live under their own `##` section, which is the thing to look for.

**This table is a snapshot and it has been wrong twice.** Read on 2026-08-31 it
was missing two whole files and wrong about three cells; read on 2026-09-02 it
was missing four. Get the current list from the tree rather than from here, then
read each file's own headings:

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

**That command does not find every menu, and the gap is not a bug in it.**
`SETUP-v2-CHANGES.md` carries eight numbered changes with dated outcome notes
and is a menu by every property except its filename. A glob is the wrong shape
for a convention nothing enforces — which is this whole section in one line.

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
reader is exactly the thing that keeps getting this wrong.
