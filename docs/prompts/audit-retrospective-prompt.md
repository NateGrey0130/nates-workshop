# Audit retrospective — the corpus as a board: conflicts, non-taken closures, and what is actually open

Written 2026-09-06 against `main` @ `c54a794` (the merge of #750). **Revised the
same day**, after #748-#750 landed between the first draft and this one - all
three taking `RETRO-AUDIT` findings. The revision is recorded rather than made
silently, because one of those PRs **falsified a row in this brief's own
evidence table**, in exactly the way the brief warns about. It is corrected in
place and flagged, not quietly rewritten.

**Nate asked for this by name**, naming the concern as: too many menus were opened, some may
conflict or block each other, and some findings may have been marked clear
without being properly considered. Those are three different problems with three
different remedies, and this brief keeps them apart on purpose.

**This is not a staleness audit and not a protocol audit.** Nine menus already
ask *is this sentence still true*. The 2026-09-04 protocol retrospective already
asked *are these conventions the right shape*. Neither asked **whether the board
they produce can be read as a board** — whether a finding in one menu is
reachable from another, whether a closure with no PR behind it holds up, and
whether anyone can say what is open without reading 31,736 lines.

**This session changes nothing.** No fix, no unblock, no data script, no
migration, no PR beyond filing the findings and archiving this brief. Read-only.

---

## The pause, and what Nate's ask does and does not lift

`.claude/skills/audit-menu/SKILL.md` → **When not to**, verified 2026-09-06 at
`:784`:

> **And as of 2026-09-04, do not open a menu about the audit apparatus itself
> without Nate asking for one by name.**

**Nate asked, on 2026-09-06, and named these three questions.** That satisfies
the condition as written. It does **not** authorise a twenty-second menu — the
findings go on `META-AUDIT.md` as `A16` onward, per *The plan*. And it does not
lift the pause for anything beyond the three questions below.

**Explicitly out of scope, and Nate declined it when offered:** a stop rule, a
moratorium, a policy on when a menu should not be opened. The pause above
already is that rule. Do not propose a stronger one, do not propose a weaker
one, and do not treat the corpus's size as a finding in its own right — it has
been measured twice already and Nate has read both.

---

## Baseline, measured 2026-09-06 at `c54a794`

Re-measure every one of these. The middle column is this brief's first draft,
~90 minutes earlier at `ba4a2e4`; the right-hand column is the protocol
retrospective's figure from `2eed604`, two days earlier. **Both deltas are
evidence for Q3** — and the 90-minute one is the sharper of the two.

| | 2026-09-06, `c54a794` | first draft, `ba4a2e4` | 2026-09-04, `2eed604` |
|---|---|---|---|
| findings menus | **21** (incl. `SETUP-v2-CHANGES.md`) | 21 | 19 (+ the same) |
| lines in those menus | **31,736** | 31,680 | 27,952 |
| markdown in the repo | **56,496** | 56,439 | 51,953 |
| latest first-parent merge | **#750** | #749 | #699 |

**Three PRs (#748, #749, #750) landed while this brief was being written**, all
three taking `RETRO-AUDIT` findings. Only `RETRO-AUDIT.md` changed among the 21
menus — no other menu, no skill, and neither `CLAUDE.md`, verified with
`git diff --name-only da97d98~1 c54a794`. The apparatus held still; the live
menu moved.

Command used for the menu total, so you can reproduce and correct it:

```bash
cd /c/Users/natha/Projects/nates-apps && cat BOOK-INGEST-AUDIT.md DOCS-AUDIT.md DOCS-AUDIT-2.md EFFICIENCY-AUDIT.md HEALTH-AUDIT.md MACHINE-AUDIT.md META-AUDIT.md REPO-AUDIT.md SETUP-v2-CHANGES.md SHIP-PR-AUDIT.md SKILL-AUDIT.md apps/character-creator/AUDIT.md apps/character-creator/CLASS-AUDIT.md apps/character-creator/INGESTION-AUDIT.md apps/character-creator/REBUILD-AUDIT.md apps/character-creator/REDESIGN-AUDIT.md apps/character-creator/RETRO-AUDIT.md apps/character-creator/UI-AUDIT.md apps/media-vault/BULK-AUDIT.md apps/media-vault/ISBN-AUDIT.md apps/pick3cut5/AUDIT.md | wc -l
```

**Do not take that file list as authoritative.** It is this brief's hand-built
list and the skill says so of its own shape table: *"a file missing from it is
missing rather than absent."* Derive the list yourself and record how, and if it
differs from 21, the difference is a finding rather than a correction to make
quietly. `docs/rules-audit.md` and `BOOK-INGEST-QUEUE.md` were excluded as not
being findings menus — check that judgement.

**`RETRO-AUDIT.md` is the live menu and moved three times during the writing of
this brief.** Anything this pass measures about it is a snapshot with hours of
life. Say so where it matters rather than pretending otherwise, and **re-read it
last** so the snapshot is as fresh as the pass can make it.

---

## The standard this pass is held to

Same as `META-AUDIT` and the protocol retrospective, because it is the same
surface:

- **Every claim measured, with the command and the day it was run.** A claim
  reasoned to is labelled **reasoned**, in place.
- **Run `META-AUDIT` `A11` before writing each proposal** — grep the tree, the
  nine skills, both `CLAUDE.md` files and the memory store at
  `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\memory\` for the
  subject, and establish whether it has already been decided. This brief ran one
  pass and records it under each question. **That is a starting point, not a
  substitute.** Every prior brief that ran a second pass found its first one
  wrong.
- **Run `A10`'s self-check pass** before the file is handed over.
- **Every finding carries a stated posture.** The posture is half of what is
  being agreed to.
- **Never grep for an outcome note.** The wordings vary by design; `CLASS-AUDIT`'s
  nine `S` items are bullets rather than headings and a `###` scan misses them
  with no error; `INGESTION-AUDIT` `F14` quotes its own note format so every grep
  reports it taken. Every classification in Q2 and Q3 is a **read**. Budget for
  that — it is the single largest cost in this pass and the reason to do it once,
  carefully, rather than twice.
- **Expect this brief's premises to be wrong.** Q1 below states a thesis; it is a
  hypothesis to test, not a conclusion to illustrate.

**A result of "the board reads fine, here is the evidence" is a complete
result.** Do not manufacture findings to justify the pass. Given that the ask
came from a worry rather than from an incident, a retrospective that finds
little and shows its work is the more valuable outcome, and should say so
plainly.

---

## Question 1 — do the menus conflict, duplicate, or block each other?

**What Nate is worried about.** That opening many menus created contradictions
between them, or findings held forever on another menu's decision.

**Already decided — do not re-derive these.**

- **An index of the menus: declined three times.** `REPO-AUDIT` `G9`,
  `META-AUDIT` `A1`, and the skill carries the decline. `A1` measured the one
  place an index exists at a **0-for-4 record**. Do not propose one, in any form,
  under any name, including "a dependency map" or "a cross-reference table."
- **A script, check, regex or glob over the menus: argued against explicitly** in
  the skill's *When not to*, and `A2` is about the file list nothing can keep
  right. Do not propose one.
- **A closed menu goes nowhere. It stays.** The skill has a section by that name
  (`:740`), shipped by the protocol retrospective. Moving or archiving a menu is
  settled and off the table; `BOOK-INGEST-AUDIT.md` was explicitly refused a move
  because *"existing paths are cited from other menus, from skills and from the
  memory store, and a move breaks citations no grep of this repo reaches."*
- **Renumbering is off the table**, in any form, for any file. 75% of findings
  live under an ambiguous ID and that is the size of the problem, not an argument
  for renumbering. The mitigation already exists: a finding reference names its
  menu.

**So the remedy space is narrow, and that is deliberate.** What is left is a
description of the failure — what shape it takes, how often, and what it cost —
plus at most a small durable statement of the kind the skill already carries.

**The evidence to start from. Verify each; several are quoted from headers, and
headers are the thing that rots.**

| case | what it looks like |
|---|---|
| `REPO-AUDIT` `G9`, `G10` | closed, not taken — *"each already decided by another menu"* |
| `DOCS-AUDIT-2`'s own trap | four of its five repairs were **already recorded as done** by closed findings in another menu (`M7`, `M13`, `M14`, `M17`), all the same day |
| `ISBN-AUDIT` `F7` ↔ `BULK-AUDIT` `B6` | `F7` held for a schema change it could not justify alone; the hold lifted only when `B6` followed it (#323, #324) |
| `RETRO-AUDIT` `R11` → `R13` | `R11` found a `CLASS-AUDIT` *"Checked and still true"* entry stale and **did not act**, because a sweep does not get to decide another menu's entry; `R13` took it after Nate released it |
| `SKILL-AUDIT` `F44` | names, and **deliberately excludes**, a live wrong number in `BOOK-INGEST-QUEUE.md` — a known-wrong thing left standing because it belongs to another file |
| `SETUP-v2-CHANGES` open question 1 | `META-AUDIT` `A5`: recorded as *"filed for a separate PR"*; **it was never filed and never fixed** |
| `BOOK-INGEST-AUDIT` `F3` | taken in halves, with a residue and a named reopen trigger — *"the only finding **on this menu** ever taken in halves"* |
| `RETRO-AUDIT` `R20` (#748) | **the repo had already answered its central mechanism, twice, in writing** — and neither place was a menu |

> **This brief got that `F3` row wrong, twice, and the correction is left
> visible on purpose.** The first draft wrote *"the only finding ever taken in
> halves"*, dropping the source's *"on this menu"* — a scoped claim widened into
> a corpus-wide one by transcription, which is the identical failure `META-AUDIT`
> recorded against `UI-AUDIT` `F30`'s quoted string. And the widened version was
> **falsified within 90 minutes** by `R20`, taken as **eight of twelve** on
> Nate's word (#748), while `R21` was taken across **three** PRs (#747, #749,
> #750). **Partial takes are ordinary, not exceptional.** Treat any "the only
> one that…" sentence anywhere in the corpus as a claim to check, including the
> ones in this brief.

**`R20`'s outcome note (#748) is the strongest single piece of evidence for this
question, and it arrived after the brief was drafted. Read it in full before
writing anything here.** `R20` proposed a rename mechanism resting on
`catalog_redirects`; the note opens *"The mechanism this finding proposed does
not work for spells"* and shows the three places a spell citation resolves, none
of which sees a redirect. Then:

> **And the repo had already answered this, twice, in writing.**
> `fix-rue-spell-levels.sql` refuses five RUE spellings on exactly these grounds
> […] and `docs/spell-and-psionic-imports.md` restates it. `audit-menu` says a
> finding may not fail to say a decision exists, and `R20` did not.

**That widens this question, and the widening is the point.** Neither of those
two places is a menu. A decision that a finding must reach can live in a **SQL
script comment** or a **doc**, and the handoff failed across that boundary just
as it would between two menus. **Q1 is therefore not "do the menus conflict with
each other" but "is a decision recorded anywhere reachable from the menu that
needs it."** Scope the measurement accordingly.

**The thesis to test — and it may be wrong.** These do not look like
*contradictions*. No two menus appear to assert opposite facts. They look like
**failed handoffs**: menu A establishes something true, and menu B either
re-derives it, waits on it, or never learns it. If that holds, "conflicting
menus" is the wrong frame for the whole problem and the finding should say so
in those words, because it changes what a remedy would even be. **If it does not
hold — if you find two menus that genuinely disagree on a fact — that is a
bigger result than anything else in this pass and should be filed on its own.**

**What to measure.**

1. Every cross-menu citation in the 21 menus, **plus every citation out of a menu
   into a script comment, a doc or a skill** — `R20` shows the boundary that
   failed was the second kind. Split it: a citation that **informs**
   (here is where this was decided), one that **defers** (this is another menu's
   call), one that **blocks** (this cannot proceed until that closes), one that
   **duplicates** (this re-derived something already recorded).
2. For every *block*: is it still blocked today, and on what? `SETUP-v2` open Q1
   is a known one. Are there others, and how long have they stood?
3. For every *duplicate*: what did the re-derivation cost, and would anything
   reachable have prevented it? Be honest about the answer — the skill, the memory
   store and `A11`'s grep all already exist, and `A11`'s whole argument is that
   the grep reaches errors re-measurement cannot.
4. Has a cross-menu confusion ever produced a **wrong action** — a change made or
   not made — as opposed to a slow lookup? That distinction decides the severity
   of anything filed here. **`R20` is one candidate**: had the finding been taken
   as written, the rename would have `422`'d a level-up confirm in both
   directions. It was caught by the taker, not by the menu, which is `audit-menu`
   → *Taking a finding is also AUDITING the finding* working — record that as the
   control it is, rather than counting it as a failure.

**Off the table:** an index, a map, a table of dependencies, a script, a check, a
regex, a renumbering, a move, an archive, any edit to an existing outcome note.

---

## Question 2 — the closures with no pull request behind them

**This is the question closest to Nate's actual worry, and it collides with
standing doctrine. The collision is resolved below; do not resolve it
differently.**

**The doctrine.** `META-AUDIT`'s retrofit section states: *"Closed findings are
**not** retrofitted — they are records."* The skill has *Audit files are RECORDS.
Do not rewrite a measurement.*

**The narrowing Nate authorised, on 2026-09-06.** Split closures by whether a
merged PR stands behind them.

- A finding closed **taken** has a diff as evidence. Something shipped, CI ran,
  the tree changed. **These are out of scope. Do not re-verify them.**
- A finding closed **moot / declined / withdrawn / superseded / "closed, not
  taken" / "blocked, no action" / diagnosed-as-another-finding** has only a
  paragraph behind it. **These are in scope**, and only these.

**A third category exists and this brief's first draft missed it: taken, but
with a recorded residue.** #748-#750 made it unmissable. `R20` shipped **eight
of twelve** and its note names *"the four left alone, each for a reason that is
not taste."* `R21` shipped across three PRs and closes with a section headed
*"What it deliberately does not do"* — `NOT NULL` landed, `''` still joins to
nothing, and closing that *"needs a `CHECK (slug <> '')`, which is a further
decision and a fourth rebuild."* `BOOK-INGEST` `F3` has the same shape and names
its own reopen trigger.

**These residues are neither open nor done, and no header names them** — the
header rule forbids it, correctly. They are reachable only by reading under the
finding, which is precisely the reader Nate is worried does not exist. **Census
them as part of this question.** For each: what was left, why, and is the stated
reason still true. Do **not** propose a list, a tracker or a status marker for
them — the same three declines apply. The finding is the census plus, if the
evidence supports it, one sentence about where a residue belongs.

**The records rule is not lifted, it is respected.** Nothing in an existing
outcome note is edited, corrected, annotated or deleted — not one word, however
wrong it turns out to be. Where a non-taken closure does not survive
re-verification, it becomes a **new finding on `META-AUDIT`** citing the old one
by menu and number. The old note stands as the record of what was believed on
the day it was written, which is what a record is for.

**The asymmetry that should drive the ordering, and the sharpest point in this
brief.** These closures do not carry equal risk:

- A finding **declined** being wrong costs a decision Nate can simply re-make.
  Low stakes. `SHIP-PR-AUDIT` `F10` even says outright that its gap *"is real and
  open"* — a decline that already documents its own cost is working correctly,
  not failing.
- A finding closed **moot — the defect was not there** being wrong means **a live
  defect is recorded as absent**, and the record actively discourages anyone from
  looking again. `UI-AUDIT` `F17` closed moot against a real print render.
  `REBUILD-AUDIT` `F16` ends *"Posture: blocked, no action. This finding exists so
  the negative result is not re-derived."* Those two are the highest-risk shape in
  the entire corpus: **a negative result written down specifically to stop
  re-investigation.** If one is wrong it is permanently wrong.

**Do the moot and blocked ones first, in that order, and if the pass runs long,
stop after them and say so.** A partial answer that covered the dangerous half is
worth more than a complete one that spread thin.

**Candidate list — assembled from status headers on 2026-09-06, therefore
unreliable by construction. Derive your own by reading; report the delta.**

| menu | finding | closure shape as the header describes it |
|---|---|---|
| `UI-AUDIT` | `F17` | moot — checked against a real print render, defect not there |
| `REBUILD-AUDIT` | `F16` | blocked, no action; negative result recorded deliberately |
| `INGESTION-AUDIT` | `F12`, `F16`, `F19` | moot, in a retirement table ~1,300 lines from their headings |
| `REDESIGN-AUDIT` | `R3` | closed unadopted (#464) — decided against |
| `SHIP-PR-AUDIT` | `F10`, `F11` | declined, each on its own stated condition |
| `BULK-AUDIT` | `B9` | declined as it recommended |
| `DOCS-AUDIT` | `D5` | withdrawn, left in place because how it went wrong is the subject |
| `DOCS-AUDIT` | `D4` | information item; closure is *"No action proposed."* wrapped across a line break |
| `REPO-AUDIT` | `G9`, `G10` | closed, not taken — decided by another menu |
| `REPO-AUDIT` | `G16` | declined, decline written into `SETUP.md` |
| `REPO-AUDIT` | `G5` half (b) | closed by decision |
| `MACHINE-AUDIT` | `M20` | closed without being taken, superseded by `M22` |
| `ISBN-AUDIT` | `F4` | closed as `F8`'s diagnosis |
| `META-AUDIT` | `A1` | index declined |
| `RETRO-AUDIT` | several | *"some turned out to be wrong about their own premises"* — the menu says so itself |
| `RETRO-AUDIT` | `R20`, `R21` | **residues**, not closures: four spell rows left alone by decision; `gear.slug` `NOT NULL` shipped while `''` is still permitted |
| `BOOK-INGEST-AUDIT` | `F3` | **residue** — schema half taken, keep-dropping option standing, reopen trigger named |

**Expect this table to be wrong in both directions**, and expect the reading pass
to find non-taken closures no header mentions. `CLASS-AUDIT`'s `S` items are
bullets. `pick3cut5/AUDIT`'s `T` items are bold paragraph leads. `INGESTION`'s
three sit 1,300 lines downstream. None of those are reachable by a scan.

**What to measure, per candidate.**

1. What did it actually claim, in its own words, and what was the stated reason
   for closing it?
2. Is that reason **still true today**? Re-verify by the method the reason
   implies — a print render for `F17`, production D1 for a count, the running app
   for a UI claim, the API for a repository setting. Record the command and the
   day.
3. **Was the closing reason ever true?** Distinct from (2) and more important. A
   reason that was wrong when written is a different failure from one that has
   since gone stale, and it means the method failed rather than time passing.
4. **Was a check ever the evidence, and was the check blind?** `R20` found
   `regression.mjs`'s *"every named spell list resolves against the catalog"* had
   been iterating **two classes** while eleven Warlock classes and 134 citations
   sat outside it — a green suite that proved nothing about the thing it named.
   Where a closure rests on "the tests pass" or "the check is clean", establish
   what the check actually walks. And note `R20`'s own method warning: it proved
   both new checks by making them fail, and **the first attempt to make them fail
   was wrong** — a reverted citation reddened the normalised check rather than
   the exact one, because `norm()` maps `&` to *"and"*. Making a check fail is
   only evidence if it fails *for the reason you meant*.
5. Was the finding **blocked by a wrong premise about the method**, rather than
   about the subject? `META-AUDIT` records exactly this: `SKILL-AUDIT` `F12` sat
   unrun because a session concluded the test *"needs an interactive Claude Code
   session"* — it does not, `claude -p` refuses on a miss, which is the same
   observable. **Nothing in the menu machinery catches that shape. Only trying it
   does.** Where a closure rests on "this cannot be checked", try to check it.
6. Label each **measured** or **reasoned**, and report which did not survive.

**Off the table:** editing any existing outcome note or measurement; re-verifying
findings closed as taken; fixing anything you find; renumbering or reopening a
finding in its own file. A finding that does not survive becomes a new `A`
finding on `META-AUDIT`, and Nate decides what happens to the original.

---

## Question 3 — what is actually open, across the whole corpus

**What Nate is worried about.** That there is open work he cannot see, because
seeing it means reading every menu.

**The tension you must engage rather than route around.** Two menus refuse to
name their open findings in their headers, and both refusals are **correct under
a rule that shipped for good reasons**:

- `RETRO-AUDIT`: *"Work is open on this menu, and this line will not say which
  findings."* Its own header records that the version naming them *"was true when
  written and false within the day, twice over."*
- `HEALTH-AUDIT`: no status header at all, on purpose (`META-AUDIT` `A4`, PR #531).
- The governing rule, `A13`, `audit-menu` → *What a status header may carry*: **a
  header MAY NOT carry a per-finding state.** Not a range, not a count, not
  *"`F3` is still open"*, not a roll-call.

**#748-#750 are a live demonstration that the rule works.** Three PRs landed
against `RETRO-AUDIT` in one morning, taking two findings across four PRs
counting #747 — and its header **needed no edit and got none**, verified by
diff. A header naming its open findings would have gone stale three times before
lunch. That is the second independent confirmation, after the one the header
already records about itself.

**So a durable list of open findings is forbidden, and the prohibition is
load-bearing.** Do not propose one. Do not propose putting one in `META-AUDIT`'s
header, in the skill, in `CLAUDE.md`, in the memory store, or in a new file.

**What is permitted, and what this question is actually for.** A **dated
measurement inside a finding body** — the same thing every other audit produces.
The header rule allows *"a dated historical statement, marked as one"*, and a
finding is a record of what was measured on a day. So:

> Produce the open set **once**, as a dated snapshot in the body of an `A`
> finding, labelled explicitly as a measurement taken on the day of the pass and
> at the revision it ran against, and **not** as a list anything may cite as
> current. Say in the finding itself that it begins going stale the moment it is
> written, and name `RETRO-AUDIT` as the reason — its list was false within a
> day, twice, and its findings moved four times in the hours this brief took to
> write.

That gives Nate the thing he asked for, once, without creating the artifact that
has now been declined four times.

**What to measure.**

1. Read all 21 menus. For each finding, its state as the text under its own
   heading gives it. **Read, do not grep** — and check for items that are not
   `###` headings before concluding a menu has none.
2. Report the open set, per menu, with the finding's own words for what it wants.
3. For each open item, is it **actionable now** or **waiting** — and if waiting,
   on what, and is that thing still real? This is where Q1 and Q3 meet: an item
   waiting on something that already happened is the blocker Nate suspects
   exists.
4. **Report residues separately from open findings.** A residue under a taken
   finding is not open work and must not be listed as though it were — but it is
   also not nothing, and Q2's census is where it belongs. Keep the two lists
   apart or the snapshot overstates the board.
5. Known starting points, all needing verification: `SKILL-AUDIT` `F44` (open as
   of 2026-09-04), `RETRO-AUDIT` (open, unnamed, and moving — `R20` and `R21`
   both closed 2026-09-06, so its open set is smaller than it was when this brief
   was drafted), `BOOK-INGEST-AUDIT` `F3`'s residue and `F11`'s recorded warning,
   `SETUP-v2-CHANGES` open question 1. `HEALTH-AUDIT` is unread by this brief and
   must be read.
6. Record the **cost of the read** — how long it took, how many findings, how many
   needed a second look. That number is the honest measure of the problem Nate is
   describing, and it is the one thing here nobody has measured.

**Off the table:** an index, a status column, a live list, a script, a check, a
count in any header, a proposal to add status headers to `HEALTH-AUDIT` or to
name findings in `RETRO-AUDIT`'s.

---

## The plan

1. Re-measure the baseline and record the delta from the table above — **both
   columns**. The 90-minute delta is the sharper evidence for Q3, and by the time
   this runs there will be a third.
2. Derive the menu list yourself. Report any difference from 21.
3. Run `A11`'s grep for each of the three subjects, independently of what this
   brief records. **Assume this brief is wrong somewhere and find it.**
4. Work the questions in order — **Q1, then Q2, then Q3** — because Q1's cross-menu
   map makes Q2's candidates easier to classify, and Q2's reading pass produces
   most of Q3's data for free. Doing them in the other order reads the corpus
   twice.
5. Each question produces **zero, one or two findings**. If a question splits,
   file the split rather than the pieces.
6. Run `A10`'s self-check pass.
7. **The findings go on `META-AUDIT.md` as `A16` onward**, under a new dated `##`
   heading at the end of the file, in the shape the 2026-09-04 protocol
   retrospective used. **Do not create a new file.** Update `META-AUDIT`'s header
   — it currently says nothing on that menu is open — and update it within the
   rule `A13` shipped: no count, no roll-call, no per-finding state.
8. Archive this brief to `docs/prompts/` in the same PR, per `A12`.

---

## What not to do

- **Do not fix anything**, however small, however obvious. Taking a finding is a
  separate decision on Nate's word, one PR each.
- **Do not open a new menu.** The pause is lifted for these three questions, not
  for a twenty-second file.
- **Do not edit an outcome note, a measurement, or an existing status header.**
  Audit files are records. A wrong note becomes a new finding, never a
  correction in place.
- **Do not re-verify findings closed as taken.** A merged PR is the evidence.
- **Do not propose an index, a map, a dependency table, a status column, a
  script, a check, a regex or a glob over the menus.** Declined three times and
  argued against in the skill.
- **Do not renumber, rename, move or archive any file.**
- **Do not put a count, a range, or a per-finding state in any header you write.**
- **Do not propose a stop rule, a moratorium, or a policy on opening menus.**
  Offered to Nate on 2026-09-06 and declined; the existing pause is the rule.
- **Do not grep for outcome notes.** Read under the heading.
- **Do not treat this brief's tables as authoritative.** Both were built from
  status headers, which is the failure mode two of these questions are about, and
  **one row of one of them was already wrong twice** — see the callout under Q1.
- **Do not assume `RETRO-AUDIT`'s state from this brief.** It moved four times
  during the writing of it (#747–#750). Read it directly, and read it last.
