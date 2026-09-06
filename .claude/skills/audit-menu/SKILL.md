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
by the time that was corrected the tree held fourteen, which was wrong within the
week. **It no longer says how many, and it will not say again**: an ordinal in
this paragraph has been wrong every single time anyone has read it, including the
one that replaced the last wrong one.

Get the list from the tree, with the command under the table, then add the one it
cannot find: `SETUP-v2-CHANGES.md` is a menu whose filename does not say `AUDIT`,
so no glob for that word will find it.

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

## The shape a finding takes, so a brief does not have to say

**A brief can now say "findings follow the `audit-menu` shape" and stop.** Until
2026-09-03 it could not: every brief in `docs/prompts/` re-derived the research
discipline in its own words — *"Verify, don't infer"*, *"Do not quote a count you
did not verify against the tree in front of you"*, *"quote counts only if you
verified them against `--remote`"*, *"Verify before asserting"*, *"check before
filing"* — five wordings of one rule, and this file owned none of it.

**That mattered, because a menu inherits its brief's discipline and one menu had
no brief.** `REPO-AUDIT.md` has none on this machine, and it is the menu whose
own header records a substantial minority of its findings carrying wrong claims.
**A correlation, not a demonstrated cause** — different subject matter, and small
numbers — and the only evidence either way.

A finding carries these, and the list is deliberately short:

- **Severity** in the heading, in whatever shape the menu already uses.
- **`Proposal`** specific enough to implement from, and a stated **posture**.
- **Evidence** — the command and the day, or *inferred* / *not measured* /
  *reported by `<file>`*. The rule and its reasoning are further down, under
  *Every number carries its date and its source*.
- **Confidence** — high / medium / low, **and what would raise it.** The last
  clause is the whole value: *"medium until someone runs X"* tells a taker where
  to start, and a bare *medium* tells them nothing.
- **Ongoing cost** — what the proposal costs *forever* once adopted: a check to
  remember, a file to keep current, a CI minute. **A proposal whose ongoing cost
  exceeds its impact should say so and recommend declining itself.**

**Two fields are deliberately absent.** *Effort* (S/M/L) has been wrong in both
directions here — `REPO-AUDIT` `G8` shipped far smaller than proposed and `G5`
grew a second defect while being taken — and *Impact* duplicates what a severity
word and a proposal already say.

**Bound to the `Proposal`, like `G18`, and for the same reason.** A finding that
is still a suspicion needs none of this. Filing one must stay cheap, and friction
there is friction on the wrong part of the loop.

**What it costs, stated rather than hidden**, because a rule that adds an hour to
every pass is a trade and not a free improvement: four fields at roughly two to
four lines each, so tens of lines and perhaps a quarter of an hour on a menu of
any size. **No check enforces it and no existing menu is retrofitted.**

**This is not new, which is the argument for it.** `HEALTH-AUDIT` carries
`Evidence` on every finding and `Confidence` on all but one, and `SKILL-AUDIT`
carries `Evidence` throughout — both from `health-audit-prompt.md`'s template,
both filed 2026-09-02. The fields above are that template minus the two that rot.
`META-AUDIT` `A9`.

## Taking a finding is also AUDITING the finding

**The highest-value rule here.** Verify the premises against current code before
scoping, and lead the report with the corrections.

**Hand that check to the `audit-premise-auditor` subagent.** It has no write
tools, so it cannot begin implementing while it is still checking — which is the
failure this rule keeps losing to: the same session verifies the premises and
then writes the PR, having already decided it wants them to hold. It reads the
menu's status header first, never greps an outcome note, carries the bare-number
ambiguity from the section below, and returns the **posture** in the proposal's
own words.

**It covers the first failure below, not the second.** Re-measuring a finding is
work an agent can do cold. Measuring what *you* are about to write is yours, and
no hand-off reaches it.

**Checking a finding before scoping it turns something up nearly every time, and
it is usually not the premises.** Two different failures hide behind that, and
they need different remedies:

- **The finding's premises are wrong.** Rarer, and the expensive one, because a
  taker implements from them. `REPO-AUDIT` `G8` said the suite had never run on
  a bare clone; a bare clone passes everything. One such error would have shipped
  a silent bug if implemented as written. **Re-measuring catches these.**
- **Something else is found wrong while doing the work.** Near-universal, and
  mostly healthy — it is what auditing the finding is *for*. `SKILL-AUDIT` `F4`
  confirmed both its premises and then caught **two of its own replacement
  sentences** being false, by measuring the fix instead of shipping it.
  **Re-measuring the finding does not catch these. Measuring what you are about
  to write does.**

Plenty of notes here record premises that held exactly — `HEALTH-AUDIT` `F5`,
`F7`, `F9`, `F23`; `MACHINE-AUDIT` `M4`, `M6`, `M15`, `M16`; `SKILL-AUDIT` `F2`,
`F4`, `F11`, `F15`. **The check earns its place by what it finds, not by the
document being untrustworthy**, which is a better reason to run it every time.

Distrust first whatever is cheapest to check: line numbers, counts, "X exists
nowhere", and any claim about what another **file** or finding says. **That last
one is the shape that actually fails**, it has its own section below, and it is
the only one of the three with something that runs.

### And before WRITING a proposal, grep the other menus for its subject

The rule above fires when a finding is **taken**. This one fires earlier, when
one is **written**, and it catches a different failure: **a proposal that
reverses a decision another menu already made, on purpose, with reasons.**

**Not a grep for a finding number — a grep for the thing being proposed**: the
filename, the mechanism, the setting, the convention. And
`~/.claude/.../memory/` is part of it, which no grep of this repo reaches. That
is a different sweep from the one further down this page, which runs *after* a
finding is taken and searches for its *number*.

**Re-measuring cannot catch this, and neither can an evidence line.** The facts
in these were right; what was missing was that somebody had already weighed
them:

- `REPO-AUDIT` `G9` proposed renaming `SETUP-v2-CHANGES.md` to fit the glob.
  `HEALTH-AUDIT` `F4` had chosen the opposite **the day before**, in PR #523,
  and written down why. `G9` had verified its own facts twice.
- `REPO-AUDIT` `G10` proposed numbering the data scripts. `SKILL-AUDIT` `F25(b)`
  had closed that in PR #567, in a note ending *"recorded so it is not
  re-proposed"* — the clause exists for precisely this, and nobody read it.
- `REPO-AUDIT`'s own **scope statement** handed territory to a
  `PORTABILITY-AUDIT.md` that had been dropped the day before, and said so in
  four files. The header warning about this shape carried an instance of it.
- `REPO-AUDIT` `G18` proposed the evidence line as a new convention.
  `HEALTH-AUDIT` and `SKILL-AUDIT` had been writing one on every finding since
  the previous day; its note calls it *"a convention that starts today"*.

**No tally of these is kept, deliberately** — see *Never grep for the outcome
note* below for what a maintained count of a recurring failure costs here. They
are named instead, because a name stays right.

**What a hit looks like.** Menus here defend their closed decisions in writing,
and the phrasing is consistent enough to search for: `SKILL-AUDIT` `F8` ends
*"Not to be re-proposed"*, `F25(b)` *"Recorded so it is not re-proposed"*, and
`REDESIGN-AUDIT` carries a whole `## Not carried forward, and why` section
opening *"Recorded so the same material does not get re-proposed from the same
prompt."* Those sentences were written for this grep. Nothing makes them fire on
their own.

**A finding may still re-propose a settled decision.** Circumstances change, and
`G10` had a second, independent ground that killed it anyway. What a finding may
**not** do is fail to say that a decision exists. `G10`'s note is the model: it
names `F25(b)`, quotes it, and then argues past it.

**No script, and this is not the mechanical reader ruled out below.** It greps
for a *subject* and hands back paragraphs for a person to read — the same posture
as `scripts/audit-citations.mjs`, and for the same reason. **The grep is the
tool; noticing is the work.** Thirty seconds.

### And before the menu is handed over, re-run every command it quotes

The rule above fires per proposal. This one fires **once, on the whole menu, just
before Nate reads it** — and it is the cheapest of the three, because the
commands are already written inside the findings.

**Report the pass in the menu**, including what did *not* move. `REPO-AUDIT`'s is
the worked example: a table naming every finding re-measured, the two found
materially wrong, and the ten whose central claim held. The rows that held are
what make the wrong ones legible; a pass that reports only its catches reads like
a list of complaints and tells a reader nothing about coverage.

**What it caught, stated exactly**, because the tempting version of this number
is wrong: of the **thirteen** findings still open when `REPO-AUDIT` ran its pass,
it found **`G11` and `G15` materially wrong**, and flagged **`G6` as right by
luck** — verified *enabled* while asserting *empty*. That menu's other three
wrong claims were in findings **already taken by then**; the pass never saw them,
and it was prompted by their failure rather than the reverse. **Run it earlier
than `REPO-AUDIT` did and it is strictly better than that record.**

**Say what the pass cannot see**, in the menu, so its silence is not read as
coverage:

- **A finding with no command to re-run is not verified by it.** That is the
  asymmetry `G18` names — a wrong inference has nothing to re-run. **Half of that
  hole is now covered by something that runs** — the section below, and
  `scripts/menu-check.mjs`.
- **A finding proposing a *decision* is untouched by it.** `G9` and `G10` had
  their facts right; no amount of re-measuring reaches an already-settled
  question. That is the grep above, not this pass.

**No check, no schedule, and it is not a phase.** `REPO-AUDIT` ran its pass
because the error rate alarmed whoever was writing, which is the right trigger.
`META-AUDIT` `A10`.

### A claim about ANOTHER FILE is the shape that fails

**The three rules above, plus this one, plus the `Proposal` evidence rule further
down, are five statements of one idea, and they were all in force when the shape
got through anyway.** That is the argument for reading this section rather than
trusting that you already know it.

**Of the four false premises on `SHIP-PR-AUDIT`, every one was a claim about what
a different file said** — not a measurement, not a count, not a claim about the
file being changed:

| the sentence | what was true |
|---|---|
| `REPO-AUDIT` `G7` — the PR body convention *"exists only inside the `ship-pr` skill"* | it was in no file at all, so the template `G7` built shipped as the only written copy of a convention it said lived elsewhere |
| `F12` — asked this skill to say its table is not a list of menus | it already said exactly that, in the paragraph above the table |
| `F14` — place a paragraph *"beside the existing exit-code material"* in `windows-shell` | there was none |
| the menu's own header | stated the wrong cost for filing a new menu, written by someone who had just read the finding naming the right one |

**A claim about the file you are editing gets checked, because you have it open.
A claim about a different file is the one nobody opens** — and it is cheaper to
check than any measurement, which is what makes it worth a rule rather than a
habit.

**The older half of this section, and the reason absence is the worst case.**
`CLASS-AUDIT` `F17` reported missing attribute requirements in seven classes.
**Five of the seven were false** — those classes held their printed requirements
in multi-line blocks and the audit had grepped the inline `{ }` form, concluding
absence from a pattern matching one of two shapes. What was real was smaller and
different in kind: one class carried *wrong* values rather than none, and the fix
turned up two page ranges the finding never listed. **"X appears nowhere" is the
claim most likely to be wrong**, and wrong in the direction that makes a finding
look bigger than it is. Prove absence by reading.

**So: before FILING a finding, open every file it makes a claim about, read the
section, and put the grep, the path with a line number, or the date in the same
paragraph.** Not when the finding is taken — by then the sentence has already
been read and believed.

**`scripts/menu-check.mjs` runs this in CI**, on the lines a pull request adds to
any menu. It flags the phrasing — *appears nowhere*, *exists only in*, *does not
mention*, *already says*, *the existing* — where nothing nearby gives a command,
a date or a line number. **A backticked path deliberately does NOT count as a
citation:** naming the file you are making a claim about is not evidence that you
opened it, which is exactly how `G7` read as sound. It cannot tell whether a
claim is true; it can refuse to let the sentence stay invisible.

**It also cannot tell a QUOTED specimen from an assertion, and you will hit
this.** An outcome note correcting a false premise quotes the false phrasing —
that is what an outcome note is for — and the check reads the quote as a fresh
claim. Mark those `<!-- claim-ok: quoting the premise this note corrects -->`.
The table three paragraphs above trips its own check four times for exactly this
reason, which is the honest state of a matcher that reads phrasing rather than
meaning.

**Why a check and not a sixth rule.** `SHIP-PR-AUDIT` was filed at 20:48 on
2026-09-03. The hand-over pass above landed on `main` at 17:16 the same day, and
*"an absence claim needs a fresh read"* had been in this file since 2026-08-28.
Three and a half hours, five rules, four false premises. **Rules that are read do
not fire; a job that runs does.**

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

### It is not only class notes. ANYTHING that cites a finding goes stale

Step 5 says *class notes* because that is where it was first caught, and the
scope is wrong. Four kinds of file cite findings here, and
`audit-citations.mjs` can see **one** of them:

| what cites a finding | covered by the script |
|---|---|
| a class's `extraction_notes` | **yes** |
| another menu's header or a finding's body | no |
| a memory file | no |
| a skill | no |

All three of the uncovered kinds have gone stale in practice, and two did so
within the hour:

- `INGESTION-AUDIT`'s header said the `audit-menu` skill still called F14 open.
  The skill was corrected **eleven minutes later** and nothing revisited the
  header (`SKILL-AUDIT` F20).
- `MEMORY.md`'s line for the health audit said its findings were all closed; a
  new one merged **seventeen minutes** after that line was written
  (`SKILL-AUDIT` F16).
- This skill itself said F14 was open for five days after F14 shipped, which is
  what `HEALTH-AUDIT` F22 fixed.

**So when a finding is taken, grep the whole tree for its number — not just the
classes** — and check `~/.claude/.../memory/` too, which no grep of the repo
reaches. **No script is proposed for this**, for the reason the paragraph above
gives about `audit-citations.mjs`: a mechanical reader would fire on every
citation of a still-open finding, which is correct and useless. The grep is the
tool; noticing is the work.

### Which is why a finding reference names its menu

That grep is the tool, and **a bare number defeats it.** Prefixes are not unique
across menus — established 2026-09-03 by walking every menu's own headings, and
re-walked 2026-09-04:

| prefix | menus using it |
|---|---|
| `F` | **most of them**, and far more than any other letter — this is the one a bare number never identifies |
| `D`, `N`, `R` | **more than one each** — `D` includes `DOCS-AUDIT`, `DOCS-AUDIT-2` and `apps/character-creator/AUDIT`; `N` includes `SKILL-AUDIT` and `apps/character-creator/REDESIGN-AUDIT`; `R` includes `apps/character-creator/REDESIGN-AUDIT` and `apps/character-creator/RETRO-AUDIT` |
| `A` `B` `C` `G` `M` | one each |

**This table carried counts until 2026-09-04 and no longer does** —
`META-AUDIT` `A14`. The `F` row said *eleven*, which was true when it was
written at 13:50 on 2026-09-03 and false by 20:48, when `SHIP-PR-AUDIT.md`
landed with ten `F` headings. **The bottom row was wrong the same day in a way a
count would not have caught**: `META-AUDIT.md` was created at 16:20 that
afternoon and its `A` was missing from it until `A14` was taken. So a letter
rotted as well as a number, and the row now lists `A`. **Do not put the figures
back.** Per `SKILL-AUDIT` `F7`, removing an ordinal beats incrementing one,
because incrementing leaves the same trap armed — and the argument this table
exists to make needs no arithmetic. Re-walk it with:

```bash
for f in $(find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './docs/*') ./SETUP-v2-CHANGES.md; do
  grep -oE '^#{2,3} `?[A-Z][0-9]+' "$f" | sed -E 's/^#+ `?//; s/[0-9]+//' | sort -u
done | sort | uniq -c
```

So `git log --grep='F18'` cannot tell you which `F18`, and neither can a branch
name after the branch is deleted. `S`, `T` and `P` are absent from that table
because they are **not headings** — `CLASS-AUDIT`'s `S` items are bullets and
`pick3cut5/AUDIT`'s `T` items are bold paragraph leads — so the census
undercounts, exactly as the heading table further down warns.

**Going forward, name the menu wherever a finding number is written outside its
own file** — commit subjects, branch names, and cross-references in another
menu, a skill or a memory file:

- `Take UI-AUDIT F30: …`, not `Take F30: …`
- branch `ui-audit-f30-banked-picks`, not `f30-banked-picks`
- *"see `SKILL-AUDIT` F25(b)"*, not *"see F25(b)"*

**Inside its own file a bare number is right** and should stay — `G12` referring
to `G9` needs no prefix, and adding one there is noise.

**No check enforces this, deliberately** — same reason as everything else on
this page. History is not rewritten either: the unqualified subjects already in
`git log` stay as they are. `REPO-AUDIT.md` G12/G13.

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

## What a status header may carry, and what it may not

A menu's dated header is the only place a status belongs — the section above and
the index-decline further down both land there. **Nothing said how much of one
it may hold, and the headers grew with the churn beneath them** until the widest
ran to 98 lines naming 33 findings, and the menu that had audited every header
for accuracy carried a stale one of its own within a day. `META-AUDIT` `A13`.

**The line is not length. It is whether the sentence can go stale on its own.**

**A header MAY carry** — these survive:

- **whether anything is open**, and the instruction to read under the finding;
- **how to read the file**: where a family of items hides from a `###` scan,
  which heading level and prefix it uses, where the `##` sections sit and in
  what order, what a reader will misread if they stop early;
- **scope, method, and the day it was written**;
- **a dated historical statement**, marked as one.

**A header MAY NOT carry a per-finding state.** Not a range of closed numbers,
not a count, not "`F3` is still open", not a roll-call. Where a finding's state
needs saying, say **read under the heading** and stop. The state lives under the
finding, in the same PR that changes it — which is the one place it cannot
disagree with itself.

**The trap paragraphs are NOT what this restricts, and deleting them would take
the half that works.** Every *"the one that misreads"* and *"this menu's own
trap"* paragraph in this repo describes **shape** — that `CLASS-AUDIT`'s `S`
items are bullets, that `INGESTION-AUDIT` `F14` quotes its own note format so
every grep reports it taken, that `pick3cut5/AUDIT`'s `T` items are bold
paragraph leads. **Shape does not change when a finding closes**, which is
exactly why those have stayed true while the status narrations rotted. Keep
them. Write more of them.

**Two of them carry an instruction to a taker** — `MACHINE-AUDIT`'s *"Take `M7`
against the list, not against a fresh scan"* and `SKILL-AUDIT`'s pointer to
`F7` — and both name findings that have since been taken. They are still
correct as dated statements and they are the edge of this rule rather than a
violation of it: an instruction about *how to implement* is not a claim about
*what is open*.

**Arrangement belongs in a header, not in the shape table below.** `SKILL-AUDIT`
`F42` cut the arrangement prose out of that table on 2026-09-04, on the grounds
that the table's job is shape, and put arrangement where *"a menu's own dated
header, which is where `audit-menu` already puts status for the same reason."*
**That is consistent with this section**, because arrangement is *how to read
the file* and not a per-finding state: a sentence like *"the `N` block sits in
the middle of the `F` run"* stays true as findings close, which is exactly why
it belongs in a header and why `F42` could remove it from a table about shape
without anything being lost. **What a header still may not do is give each of
those findings its state on the way past.**

**No retrofit, no check, and no count in this rule.** Existing headers are
records and stay as they are; this governs the next header written and the next
line added to one. A check is ruled out for the reason the whole page gives —
the notes vary in wording by design and a mechanical reader keeps getting this
wrong.

## The headings are not uniform, and that is the argument

**This table is a shape reference for the files it names. It is NOT the list of
menus, and a file missing from it is missing rather than absent.** Get the list
from the tree with the command below, every time. The rows exist to record what
no command can tell you — which files put a severity word in the heading, which
put a *status* there, and which keep a whole family of items somewhere a `###`
scan will never see.

*That distinction is the fix, and it arrives late.* This table has been wrong
**every time it has been read**, always about the same half: **the rows it did
not have.** The count of readings is deliberately not given — it was `five` here
until 2026-09-04, when a sixth reading made it wrong in the one paragraph
explaining why ordinals in this section go stale. `SKILL-AUDIT` `F7` corrected it on 2026-09-02, predicted its own
falsification in the same paragraph, and was right within the hour. What `F7`
also did is the model for this — it removed the *ordinal* from the paragraph
above rather than incrementing it, on the grounds that changing fourteen to
fifteen *"leaves the same trap armed."* A row list that claims to be complete is
that trap one level down.

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
| `apps/media-vault/BULK-AUDIT.md` | `B` | `##` | `## B1 — …` |
| `apps/media-vault/ISBN-AUDIT.md` | `F` | `##` | `## F1 — …` |
| `apps/pick3cut5/AUDIT.md` | `F`; `T` | `###`; **not a heading** | `### F1. …`, and `**T1. … — PASSED.**` as BOLD PARAGRAPH LEADS under `## T — paths that have never run` |
| `HEALTH-AUDIT.md` | `F` | `###` | severity word, capitalised: `### F1 — Critical — …` |
| `SKILL-AUDIT.md` | `F`, `N` | `###` | `### F1 — …`, no severity word, and **every `###` is a finding** (`F38`, 2026-09-04). That file's own header names its sections. |
| `SHIP-PR-AUDIT.md` | `F` | `###` | `### F1 — …`, no severity word |
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

**Every reading of this table has found it wrong, and always about the rows.**
Read on 2026-08-31 it was missing two whole files and wrong about three cells;
read on 2026-09-02 it was missing four. Audited against every file's headings
later the same day, it was **right on thirteen rows of fourteen and wrong on one
cell** — `DOCS-AUDIT.md`, whose findings all carry a word in the severity slot,
and whose `D5` carries `WITHDRAWN` there: a *status* where four other files put a
severity, and the one cell here that would change a scan's answer. Read again on
2026-09-03 it was **missing four**, one of them the menu doing the reading. Read
on 2026-09-04 it was **missing one — again the menu doing the reading**
(`SHIP-PR-AUDIT` `F12`), whose own header had stated a different and wrong cost
for filing a new menu, written by someone who had just read `F7`.

The failure mode changed shape across those readings — missing rows, more missing
rows, a wrong cell, missing rows again — and the constant is that **the cells
have been reliable and the roll-call has not.** That is why the table stopped
claiming to be one.

**The row that is missing has twice been the reader's own.** That is not
coincidence, and it is the practical instruction hiding in this section: *the
menu you are writing is the row you will forget.* Add it in the PR that creates
the file, or accept that the next reader finds it. Get the list from the tree, then read each file's own
headings:

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

**That command is wrong in BOTH directions, and neither gap is a bug in it.**

- **It misses one.** `SETUP-v2-CHANGES.md` carries eight numbered changes with
  dated outcome notes and is a menu by every property except its filename.
- **It returns one that is not a menu.** `docs/prompts/SKILLAUDITPROMPT.md` is
  the *brief* that produced `SKILL-AUDIT.md`, archived under `HEALTH-AUDIT` `F3`.
  Anything in `docs/prompts/` matching the word is a brief, not a menu.

So the answer is the glob's output, minus the briefs, plus the one it cannot see.
**Do not fix this with a better pattern.** `-not -path './docs/*'` is correct
today and wrong the moment a menu lands under `docs/` — a rule with an expiry
date nobody will notice. A glob is the wrong shape for a convention nothing
enforces, which is this whole section in one line.

**And do not fix it with an index file either. That has now been declined
twice** — `REPO-AUDIT` `G9` on 2026-09-03, and `META-AUDIT` `A1` the same day
with the evidence `G9` did not have. The two halves an `AUDITS.md` would carry
fail differently and both fail:

- **The file list is derivable**, so an index adds a second place to be wrong
  rather than a first place to be right — and the table above *was* that index,
  wrong on all five of its readings.
- **A status column is not derivable and rots faster.** On 2026-09-03 three
  sources described one menu's status and **all three disagreed**, two of them
  while carrying an explicit *do not trust this line* guard. A memory cannot hold
  a status and neither can an index; **a menu's own dated header is the only
  place one belongs**, which is the same conclusion the memory store reached
  after a line there went stale in seventeen minutes.

*(The over-return went unstated until 2026-09-03, `META-AUDIT` `A7`. The
paragraph prepared a reader for exactly one of the two errors, and `REPO-AUDIT`
`G11` then miscounted the root with this command and was re-scoped for it.)*

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

## Every number carries its date and its source

`124 / 126 classes` means nothing alone. Write where it came from —
`source-coverage.mjs --remote`, `claude_usage`, the smoke summary — and the day.
Ask production: `--local` accumulates, and has reported catalog duplicates that
production merged away weeks earlier. Quote a moving number only where something
pins it; the test suite pins the README's counts, so those survive, and a count
in prose does not.

### And a `Proposal` says whether its central claim was measured or reasoned to

The rule above covers numbers. **The claims that have actually caused damage
here carried no number at all.**

`REPO-AUDIT.md` produced a run of them, and most share a shape: **reasoned to
rather than run**. Its `G8` said the test suite "has never been runnable on a
bare clone" — a bare clone passes all 1662 checks, and the sentence contains no
figure to date or source. `G5` said merge commits were used "exclusively" against
117 squash merges. `G15` said a deploy path produced "no signal at all" while the
tool already reported it. **Every claim in that menu that came from a command
someone actually ran has survived re-measurement.**

*(A count opened this paragraph until 2026-09-04 and no longer does. It said
five of eighteen; `G7` made it six, in a passage whose subject is claims that go
stale. `SKILL-AUDIT` `F7`'s rule applies here too — removing the ordinal beats
incrementing it, because incrementing leaves the same trap armed.)*

**The second shape is not this one, and re-measuring never reaches it** — a claim
about what another file says. See *A claim about ANOTHER FILE is the shape that
fails*, above, which is the only one of these with a check behind it.

The cost is not symmetric, which is why this is worth a line:

- **A wrong measurement is caught the moment someone re-runs the command.**
- **A wrong inference gets implemented.** It reads as settled, and there is
  nothing to re-run.

So a **`Proposal:` paragraph** names its evidence, in one line:

- the **command and the day** it was run — `drift-check.mjs --remote,
  2026-09-03`; or
- the words **inferred**, **not measured**, or **reported by `<file>`**.

**And where a proposal tells a taker to run a command, say whether you ran it.**
`REPO-AUDIT.md` `G1` shipped a verification command that counts 117
squash-merged PRs as direct pushes. Nobody had run it, and nothing on the page
said so.

**Bound to the `Proposal` paragraph only, deliberately.** The observation above
it stays free-form: a menu exists to catch a suspicion before it is lost, and
friction there is friction on the wrong part of the loop. A suspicion is allowed
to be a suspicion. **A proposal specific enough to implement from is not.**

**No check, and no retrofit of existing findings** — same reason as everything
else on this page. `REPO-AUDIT.md` G18.

**This did not start with `G18`, and knowing that is worth more than the rule.**
`G18`'s note calls it *"a convention that starts today"*. It was already in force
the day before, in the two menus filed immediately ahead of `REPO-AUDIT`, and it
came from a **brief** rather than from here — `health-audit-prompt.md` prescribes
a finding template whose fields include *Evidence — the command, file:line, or PR
that proves it*. Censused 2026-09-03:

| menu | findings | `**Evidence**` lines | `**Confidence**` lines |
|---|---|---|---|
| `HEALTH-AUDIT.md` (2026-09-02) | 24 | **24** | **23** |
| `SKILL-AUDIT.md` (2026-09-02) | 25 `F` | **25** | 0 |
| `REPO-AUDIT.md` (2026-09-03) | 18 | **0** | 0 |

So the rule has been **tried**, and there is evidence about it rather than none.
Two things follow.

**The `Confidence` line did the job it was added for, at least once.**
`HEALTH-AUDIT` `F18` carried a low-confidence half, and that half is the one that
moved when the finding was taken — its note reads *"The low-confidence half is
now high."* A marker that flags the part most likely to be wrong, and then is
right about which part, has earned a look. It is **not** adopted here; that is
its own decision.

**And `REPO-AUDIT` inherited none of it, because it had no brief.** No brief for
that menu exists anywhere on this machine (`docs/prompts/README.md` carries the
row). It is also the menu carrying the largest share of wrong claims. **That is
a correlation and not a demonstrated cause** — different subject matter, and
small numbers against 24 — and it is the only evidence available either way.
`META-AUDIT` `A8`, `A9`.

## Where a new menu goes

Decide by **what the menu is about**, not by where similar-sounding files
already sit:

- **the repo root** — anything spanning more than one app, or covering the repo,
  the process, the machine, or the instruction layer;
- **the app's own directory** — anything scoped to exactly one app.

**No count belongs in this rule, and that is deliberate.** `REPO-AUDIT.md` G11
tried to state the placement question by counting the menus in each location and
got both numbers wrong — the root figure because it was counted with the
`*AUDIT*.md` glob that misses `SETUP-v2-CHANGES.md`, which is the trap described
above the `find` command earlier in this file. A rule carrying a tally needs
re-counting every time a menu lands, with the tool that has already proven
wrong. This one does not.

**`BOOK-INGEST-AUDIT.md` is the standing counter-example.** It sits at the root
and is entirely about the character creator's catalog. It is **not** moved to
fit this rule, and the rule does not pretend it fits: existing paths are cited
from other menus, from skills and from the memory store, and a move breaks
citations no grep of this repo reaches. The rule is for the **next** menu.

## And where a closed menu goes: nowhere. It stays

A menu with no open work is **not** archived, moved, folded into another file,
or deleted. It stays at the path it was written at, indefinitely.

**This is a decision Nate already made, not a new rule.** `docs/prompts/meta-audit-prompt.md`
→ *Posture, fixed by Nate*, 2026-09-03: *"Index only. Move nothing, merge
nothing, rename nothing. Do not propose archiving closed menus into
`docs/audits/`, folding them into a single file, or renaming anything to fit the
glob."* It is written here because a decision that lives only in a brief is
invisible to anyone reading the skill, and the natural repair — tidying the
closed ones away — is the thing it refuses. `META-AUDIT` `A15`.

**The reason is the one directly above**, and it is why *closed* changes
nothing: a menu's path is cited from other menus, from skills, from
`docs/prompts/`, and from the memory store, and a move breaks citations no grep
of this repo reaches. Closing a menu does not retract a single one of those
citations. A closed menu is also still the only record of what was decided and
why, which is the other half — the findings are the reasoning, not a to-do list
that has been emptied.

**Three things are already decided and should not be re-proposed:**

- **An index of the menus.** Declined twice — `REPO-AUDIT` `G9`, then
  `META-AUDIT` `A1` with the evidence `G9` did not have. The reasoning is with
  the `find` command earlier in this file.
- **Archiving or relocating closed menus.** Nate's posture above.
- **A retirement section inside a menu**, collecting closed items away from
  their headings. `INGESTION-AUDIT` has one and it is a documented trap: `F12`,
  `F16` and `F19` close as moot roughly 1,300 lines from their headings, so
  reading under the headings alone reports three open that are not.

**What this costs, stated rather than hidden:** the closed menus stay in every
glob and every grep, beside the documents describing how the repo works today.
That is a real tax on a tree-wide search and it is accepted, because every
alternative measured so far breaks something that cannot be grepped for.

## A deferral is work. Give it a number or say you are dropping it

A finding that scopes part of its subject out usually names the remainder as
*"a separate finding"*, *"its own finding"* or *"a separate PR"* — and then
nothing files one. The work is real, it has been measured, and it is now
reachable only by reading the interior of a **closed** finding. It is not open,
because open is a property of findings and this has no number.

**So: file it in the same PR and cite it by number, or write that you are
dropping it.** Filing costs a heading and a paragraph and obliges nobody —
`## When not to` below forbids *taking* a finding in the PR that adds it, not
adding one. `META-AUDIT` `A5` is the precedent for the mechanism: PR #644 filed
`pick3cut5/AUDIT` `F11` and `F12` while taking `A5`, and took neither.

**This is a generalisation, not a new rule.** `book-survey` → §8 has carried the
workflow-scoped version since the batch protocol was written, as the rule *"worth
memorising"*:

> Import what the schema supports, record what was dropped in the row's
> `extraction_notes`, file the gap in `BOOK-INGEST-AUDIT.md`, and keep going.
> **Do not stop to implement.**

`class-import` carries the citing half — *"Not stored; see `BOOK-INGEST-AUDIT.md`
F8. ← never goes stale"*. What neither says, and what this section adds, is that
the same discipline applies when the thing being deferred is **another finding**
rather than a book's mechanic.

**Measured 2026-09-06, which is why this is here rather than assumed.** Four
deferrals were standing at `c54a794` with no number between them. Two were
eventually caught by later passes, each as a one-off — `META-AUDIT` `A5` and
`SKILL-AUDIT` `F32`, neither of which generalised. One resolved itself and left
its own record asserting a condition that had become false. The rest were still
true and still invisible, the oldest ten days old, on menus whose status headers
correctly said nothing was open.

**A deliberate drop is a complete answer and is cheaper than a number.** *"The
`h2`→`h4` jumps are not worth fixing and this finding is not proposing them"*
closes the question forever. What this section refuses is the third option —
naming work, not filing it, and leaving a reader to infer which of the two
happened.

**No check, no list, no index of deferrals**, for the reasons the rest of this
page gives. This governs the next finding written, and **no existing menu is
retrofitted.** `META-AUDIT` `A16`.

## When not to

Do not open a new menu for work belonging in an existing one, and do not add a
finding you intend to take in the same PR — the numbering exists so the decision
to take it can be separate. Do not add a check that a finding was taken or that
the open count is right: the notes vary in wording by design, and a mechanical
reader is exactly the thing that keeps getting this wrong.

**And as of 2026-09-04, do not open a menu about the audit apparatus itself
without Nate asking for one by name.** Measured by first-commit date on
2026-09-04: **seven menus were filed on 2026-09-02 and 2026-09-03, and not one
is about an app or the data** — `SKILL-AUDIT`, `META-AUDIT` and `SHIP-PR-AUDIT`
audit the instruction layer, `REPO-AUDIT` and `HEALTH-AUDIT` the process and the
platform, `MACHINE-AUDIT` the PC, `DOCS-AUDIT-2` the documentation. The last
menus about the product itself are `UI-AUDIT` and `REDESIGN-AUDIT`, both
2026-08-31.

The apparatus is now the most-measured thing here, and the findings arrive at a
real error rate, so a menu whose subject is the loop can cost more in rework than
it returns. **Menus about the product — an app, the catalog, the data, the UI —
are unaffected and stay the normal way to work.**

This is a **pause and a default, not a closed door.** It expires when Nate says
so, and any single finding about the apparatus still belongs on whichever
existing menu owns that surface.
