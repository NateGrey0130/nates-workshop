# Protocol retrospective — three conventions, and whether they still earn their cost

Written 2026-09-04. **Revised the same day**, after 21 pull requests (#679–#699)
landed between the first draft and this one — all on the instruction layer,
taking `SKILL-AUDIT` from `F27` to `F42`. The revision is recorded rather than
made silently, because *what changed in four hours* is itself evidence for the
question this brief asks. **Q2's premise was materially wrong in the first
draft and is corrected below.**

**This is not a staleness audit, and that is the whole point of it.** Eight
menus already ask *is this sentence still true* — `DOCS-AUDIT`, `DOCS-AUDIT-2`,
`HEALTH-AUDIT`, `MACHINE-AUDIT`, `META-AUDIT`, `REPO-AUDIT`, `SHIP-PR-AUDIT`,
`SKILL-AUDIT`. Not one of them asks *was this the right shape, and is it still
worth what it costs.* A convention can be perfectly accurate, fully documented,
enforced everywhere, and still be the wrong shape. That is the only question
here.

Three conventions, named by Nate. Nothing else is in scope.

---

## The pause, and why this brief exists

`.claude/skills/audit-menu/SKILL.md` → **When not to** carries this, dated
2026-09-04 and **unchanged as of the revision** (verified at `:672`):

> Do not open a menu about the audit apparatus itself without Nate asking for
> one by name.

**Nate asked, on 2026-09-04, and named these three.** That satisfies the
condition as written. It does **not** lift the pause for anything else, and it
does not authorise a twentieth menu — read *The plan* below for where the output
goes.

---

## The baseline this brief was written from

Re-measured 2026-09-04 at `2eed604` (the merge of #699). **Re-measure every one
of these anyway.** The first-draft figures are kept in the right-hand column
because the four-hour delta is part of the subject.

| | at #699 | first draft, ~4h earlier |
|---|---|---|
| findings menus | 19 (+ `SETUP-v2-CHANGES.md`, a menu by every property but its filename) | 19 |
| lines in those menus | **27,952** | 26,718 |
| markdown in the repo | **51,953** | 50,682 |
| skills | **3,213** across 9 | 3,184 |
| file touches, last 7 days | **494 governance / 469 other — 51.3%** | 465 / 479 — 49.3% |
| `SKILL-AUDIT` findings | **`F1`–`F42`** | `F1`–`F27` |

**Governance prose crossed into the majority of file touches during the window
between the two drafts.** State that in the audit; do not soften it and do not
editorialise past it.

---

## The standard this pass is held to

Same as `META-AUDIT`, because this is the same surface:

- **Every claim measured, with the command and the day it was run.** A claim
  reasoned to is labelled as one.
- **Run `A11` before writing each proposal** — grep the tree, the skills and the
  memory store for the subject and establish whether it has already been
  decided. This brief ran two passes and records what they found under each
  question. **That is a starting point, not a substitute**: the point of `A11`
  is that the grep reaches errors re-measurement cannot, and the second pass
  here found the first one wrong.
- **Run `A10`'s self-check pass** before the file is handed over.
- **Every finding carries a stated posture**, and the posture is half of what is
  being agreed to.
- **Expect this brief's own premises to be wrong.** One already was, inside four
  hours, and it is flagged in place below rather than quietly rewritten.

**A result of "all three hold, here is the evidence" is a complete result.**
Given the pause and the error rate this brief responds to, a retrospective that
declines to change anything and shows its work is worth more than three marginal
findings. Do not manufacture findings to justify the pass.

---

## Question 1 — the status-header convention

**What it is.** Every menu opens with a prose block stating whether it has open
work. `HEALTH-AUDIT` `F8` created the convention and taking it in PR #531 "gave
every other menu a status line."

**Already decided — do not re-derive these.**

- `META-AUDIT` `A3` (PR #643): `BOOK-INGEST-AUDIT`'s header went stale **within
  five minutes** of `F3` closing, same session, same file.
- `META-AUDIT` `A4` (PR #645): `HEALTH-AUDIT` carries no status header on
  purpose; adding one is the thing that decision refused.
- `MACHINE-AUDIT` `M19` and `BOOK-INGEST`'s header **already found the shape that
  does not go stale**: a description plus an instruction to look, in place of an
  enumeration.
- An index with a status column: **declined twice**, `G9` and `A1`.
- A check, script or regex over the menus: argued against explicitly in the
  skill; `A2` is about the file list nothing can keep right.

**New since the first draft, and it changes this question.**

- **`SKILL-AUDIT` `F38`** (taken, #695) — a commentary heading was
  indistinguishable from a finding and a scan counted 37 findings where there
  were 36.
- **`F40`** (taken, #698) — `audit-menu`'s shape-table row for `SKILL-AUDIT`
  described an arrangement the file no longer had.
- **`F42`** (**OPEN**) — proposes cutting arrangement prose out of the shape
  table entirely, and says where it belongs instead: ***"a menu's own dated
  header, which is where `audit-menu` already puts status for the same
  reason."***

**That last one is the live tension and the pass must engage it directly.**
`F42` would move *more* into menu headers, on the same reasoning `F8` used. Q1
asks whether headers are already carrying more than they can hold. **These can
both be right — the header may be the correct home precisely because it is
dated and hand-maintained — but nothing has tested them against each other.**

**`SKILL-AUDIT`'s own header is the exhibit that did not exist when this brief
was first written.** Read it. It runs past forty lines, narrates seven separate
`##` placements, and tracks findings that reverse each other within hours —
`F42` partly reverses `F40`, taken the same morning. The header says of itself
that the fifth and sixth placements are *"past the point where the arrangement
helps anyone."* That is the convention under load, and it is the single best
piece of evidence available for this question.

**What to measure.**

1. Read the opening block of all 20 files. For each: is there a status claim at
   all, and is it in the durable shape (*status lives under the finding, read to
   the next heading*) or the enumerating shape (a range, a count, "all N are
   closed")?
2. A `head -45` scan on 2026-09-04 suggested **4 files still enumerate**
   (`DOCS-AUDIT`, `EFFICIENCY-AUDIT`, `REBUILD-AUDIT`, `BULK-AUDIT`) and **9
   carry neither marker**. That is exactly the mechanical read the skill warns
   about. **Verify by reading. Expect it to be wrong.**
3. Classify the ten self-warning paragraphs — *"this menu's own trap"*, *"the one
   that misreads"*; `MACHINE-AUDIT` has 5, `REPO-AUDIT` 4. How many are about a
   stale header, how many about findings out of order or a note hidden behind a
   bold lead, how many about a number colliding with another menu's? **Three
   different causes, three different remedies, and the first draft of this brief
   lumped them.**
4. Does header length correlate with churn? `SKILL-AUDIT`'s header grew with its
   finding count; `EFFICIENCY-AUDIT`, closed and quiet, has three clean lines.

**The question this has to answer:** is the residue the price of the
convention, or the price of not applying the durable shape once it was found —
and does a live, churning menu need a *different* header contract from a closed
one? Those have different remedies.

**Check `F42`'s state before writing anything here**, and if it has shipped,
re-read the skill rather than trusting this brief's quotation of it.

**Off the table:** a status line for `HEALTH-AUDIT`, an index, a check, a script,
a regex, any proposal putting a count in a header.

---

## Question 2 — the finding namespace

> **The first draft of this brief called this question "nearly dead" and said a
> new scheme had "almost no surface left to apply to." That was wrong, and it
> was wrong because it reasoned from one anecdote — seven menus carrying an
> `F18` — instead of measuring. The measurement is below. This is the largest of
> the three questions by evidence.**

**What it is.** Each menu numbers its findings with a letter and an integer,
letters assigned as menus were created. `META-AUDIT` had to census every menu's
markers to find a free letter and settled on `A`.

**Measured 2026-09-04 across all 19 menus:**

| | |
|---|---|
| distinct finding IDs in the tree | 126 |
| IDs that name **more than one** finding | 43 |
| **findings living under an ambiguous ID** | **248 of 331 — 75%** |
| `F1` through `F6` | each names **12 different findings** |
| menus using the `F` prefix | 12 |

**Already decided — do not re-derive these.**

- The skill already carries the mitigation: **a finding reference names its
  menu** (`## Which is why a finding reference names its menu`).
- **Audit files are records.** Renumbering destroys the account of what an audit
  found and every citation to it. **Renumbering is off the table — do not
  propose it, in any form, for any file.** The 75% is the size of the problem,
  not an argument for renumbering.
- The letters in use, censused 2026-09-03: `A B C D F G M N R S T`. Re-run it.

**So the remedy is constrained to the citation convention, and the live question
is whether that convention is actually holding at this scale.**

**What to measure.**

1. Count citations of a bare finding number that do not name their menu — across
   the 19 menus, the 9 skills, `CLAUDE.md`, `~/.claude/CLAUDE.md`, and the memory
   store at `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\memory\`.
2. Split them: genuinely ambiguous (an `F3` in a file citing four other menus)
   versus unambiguous in context (a within-file back-reference). **Most
   within-file references will be fine and should not be counted against the
   convention.**
3. Establish real cost. Has an unqualified citation ever sent a reader to the
   wrong finding, or only cost a slow lookup? `BOOK-INGEST`'s `F18` note claims a
   tree-wide grep returns mostly other menus' history — check whether that ever
   produced a wrong action.
4. **Consider the asymmetry:** the risk is not uniform. `F1`–`F6` are twelve-way
   ambiguous and are also the most-cited findings in any menu, because early
   findings get referenced by later ones. Check whether the citations cluster
   where the ambiguity is worst.

**If compliance is high, this closes with no action and the convention is shown
to hold at 75% ambiguity — which is a stronger result than it sounds.**

---

## Question 3 — where a closed menu goes

**Still the one with no prior decision, and unchanged by the day's work.**

**What it is.** The skill has `## Where a new menu goes` and `## When not to`.
It has nothing for where a *finished* one goes. 17 of 19 menus are fully closed
and all **27,952** lines sit live in the tree, in every glob and grep, beside
the documents describing how the repo works today.

**Already decided — do not re-derive these.**

- An index: **declined twice** (`G9`, `A1`).
- **Moving `BOOK-INGEST-AUDIT.md` was explicitly refused**, and the reason
  generalises: *"existing paths are cited from other menus, from skills and from
  the memory store, and a move breaks citations no grep of this repo reaches."*
  **A proposal to move or archive starts from behind and must beat that with
  evidence.**
- Retirement *sections within* a menu are already a documented trap —
  `INGESTION-AUDIT`'s `F12`/`F16`/`F19` sit ~1,300 lines from their headings and
  a scan reports three open that are not. **Do not propose more of those.**

**The likely correct answer is that they stay where they are, permanently, on
purpose. The finding is that no decision says so.** An absent decision and a
deliberate one look identical in the tree — precisely the argument `A4` made
about `HEALTH-AUDIT`'s missing header, and it was worth a paragraph there.

**What to measure — the cost of them staying, concretely.**

1. Take three or four lookups a working session actually performs — *what is the
   rule for a schema change*, *has this been decided*, *what does the repo say
   about D1 drift* — run them as real greps and count what fraction of hits come
   from closed menus versus live instructions.
2. Has a closed menu ever been mistaken for live guidance? `DOCS-AUDIT-2`'s
   pattern — *"the move was recorded and the pointers were not"* — is the nearest
   known case; check whether the reverse has happened.
3. What does a reader lose if the answer is "they stay": nothing, or a real and
   recurring tax?

**Then propose the decision, whichever way it goes**, in the smallest durable
form — most likely one short section in `audit-menu/SKILL.md` beside *Where a
new menu goes*, so the next reader meets a decision instead of a gap.

---

## The plan

1. Re-measure the baseline. Record it, and record the delta from the table
   above — the rate of change is evidence.
2. Run `A11`'s grep for each subject independently of what this brief records.
   **The second draft of this brief found the first one wrong; assume a third
   pass finds this one wrong too.**
3. Work the three questions in order. Each produces **zero or one finding**. If
   a question splits, file the split rather than the pieces.
4. Run `A10`'s self-check pass.
5. **The findings go on `META-AUDIT.md` as `A13` onward** — it owns the protocol,
   and the pause says a single finding about the apparatus belongs on the menu
   owning that surface. **Do not create a new file.** Update `META-AUDIT`'s
   header, which currently says nothing on that menu is open.
6. Archive this brief to `docs/prompts/` in the same PR — `A12` records the
   archive running two short. **Archive this revised text**, and let the
   revision note at the top stand.

---

## What not to do

- **Do not open a twentieth menu.** The pause is lifted for these three
  questions, not for a new file.
- **Do not fix anything in this pass**, however small. Taking a finding is a
  separate decision and that is the convention under review.
- **Do not collide with `F42`.** It is open, it is on Q1's surface, and it
  argues the opposite direction. Check its state first; engage its reasoning
  rather than working around it.
- **Do not propose a script, a check, an index, a regex or a glob over the
  menus.**
- **Do not renumber, rename or move any file.**
- **Do not edit an outcome note or a measurement.** Audit files are records.
- **Do not count the menus in any rule you write.**
