# Meta-audit — the menus themselves, and the discipline that fills them

Written 2026-09-03, after `REPO-AUDIT.md` closed with five wrong claims in
eighteen findings.

Two questions, one menu:

1. **Are seventeen audit menus across ~24,000 lines still usable as a
   reference**, and would an index make them more so — without moving a file?
2. **Why does an audit here file findings that turn out to be wrong**, and what
   rule, phase or artifact would have caught them before Nate read them?

Produce **one file**: `META-AUDIT.md` at the repo root. Change nothing else.
Do not fix a skill, an index or a menu in this pass, however small the fix looks
— the whole point of a menu is that taking a finding is a separate decision, and
this menu is about that protocol.

---

## Setup

The monorepo is `C:\Users\natha\Projects\nates-apps`. This session may have
started elsewhere, so **read the repo's `CLAUDE.md` yourself** — it does not
auto-load from outside the repo.

**Load the `audit-menu` skill before writing anything.** You are auditing it.
Read it as a subject, not as instructions to follow silently: where you follow a
rule in it during this pass, notice whether the rule did any work.

Record a baseline before you read anything else, and put it in the file:

- the current menu list, taken from the tree, **plus the one the glob cannot
  find** (the skill says which, and why that is not a bug in the glob);
- total lines across the menus;
- what is actually open, established by reading under the headings — not by a
  grep, and not by trusting a menu's own status header;
- `main`'s SHA and the last merged PR number.

This audit is read-only. No production write. `SELECT` is fine; nothing else.

## The standard this menu is held to, because it is the subject

`REPO-AUDIT.md` `G18` shipped today: a `Proposal:` names its evidence — the
command and the day it was run, or the words *inferred* / *not measured* /
*reported by `<file>`*. **Every proposal in this file does that, with no
exceptions and no retrofitting excuse.** A menu about research discipline that
files an unmeasured claim has answered its own question in the worst way.

Two failure shapes are already on record. Find out whether there are more.

- **`G18`'s shape — reasoned to rather than run.** Every wrong claim in
  `REPO-AUDIT` was an inference; every claim that came from a command someone
  ran survived re-measurement. The asymmetry is the point: a wrong measurement
  is caught the moment someone re-runs the command, and a wrong inference gets
  implemented.
- **`G9`'s shape — proposing a reversal of a decision without checking one
  exists.** `G9` proposed renaming a file that `HEALTH-AUDIT` `F4` had
  deliberately chosen not to rename **one day earlier**. It was not wrong about
  any fact; it had verified the fact twice. No amount of re-measuring would have
  caught it. The check is a thirty-second grep for the filename across the other
  menus, and it was not done.

**`G9`'s shape is not in the skill.** Whether it should be is a finding for this
menu, not a decision this brief makes.

---

## Part 1 — the menus

### The thing to establish first, before proposing anything

**`REPO-AUDIT` `G9` already considered an index and declined to propose one**,
on the grounds that the `audit-menu` skill argues against relying on a
mechanical list of things nothing enforces. Read `G9` in full, including its
outcome note, before you write a word about an index.

Nate has since said he wants the index-only option. **That is not permission to
skip `G9` — it is the reason to engage it.** The honest question is whether an
index of *menus, their scope, their status and their traps* is the same artifact
`G9` declined, or a different one. Argue it either way, but argue it against
what `G9` actually says.

If the answer is that they are the same artifact, **say so and propose against
the index anyway.** A finding that tells Nate his stated preference was already
decided the other way, with reasons, is worth more than one that builds what was
asked for. He decides; you establish.

### What to measure rather than assume

- **Does the reference problem still exist?** `HEALTH-AUDIT` `F8` — *"no menu
  states its own status, so establishing that there is no open work costs an
  audit"* — was taken, and every menu now opens with a status header. So the
  cost `F8` measured has already been paid down once. **Measure what it costs
  today**: pick a real question of the kind Nate asks ("is anything open?",
  "which menu covers the wizard?", "has this been decided before?") and answer
  it from a cold start, timing what it actually takes. Report the number and the
  method.
- **Are the status headers accurate right now?** Check each one against the
  findings beneath it. `MEMORY.md`'s line for `MACHINE-AUDIT` says `M19`/`M20`
  were filed open; the file's own header says nothing is open. One of those is
  stale. Find every such disagreement — between a header and its findings,
  between two menus, and between a menu and the memory store, which no grep of
  this repo reaches.
- **What would an index go stale about, and how fast?** The skill's own
  doctrine is that a maintained count is wrong every time it is read. An index
  carrying statuses inherits that. Name the specific fields that would rot, and
  say what an index would have to omit to be worth having.
- **What already does the index's job?** `CLAUDE.md`, `SETUP.md`, the skill's
  own shape table, `docs/prompts/README.md`, `MEMORY.md`. Establish what a
  reader actually has today before proposing an eighteenth place to look.
- **`docs/rules-audit.md` is not a menu** and the glob returns it. Say whether
  that matters.

### Posture, fixed by Nate

**Index only. Move nothing, merge nothing, rename nothing.** Do not propose
archiving closed menus into `docs/audits/`, folding them into a single file, or
renaming anything to fit the glob. The skill's reason stands: menu paths are
cited from other menus, from skills and from the memory store, and a move breaks
citations no grep reaches.

Consolidating `docs/prompts/` is **out of scope** for this part. The briefs are
in scope for Part 2, as evidence about how audits are commissioned — not as
files to reorganize.

---

## Part 2 — why the findings are wrong

### Re-derive the five, one at a time

`REPO-AUDIT.md`'s header names them and its findings carry `Adjusted` banners.
For **each** wrong claim:

- what was asserted, and in what words;
- what is actually true, and the command that establishes it;
- **the cheapest check that would have caught it before filing** — name the
  command and estimate its cost in seconds;
- whether it was caught before or after Nate read the menu, and by what.

Then do the same for the three re-scoped findings (`G5`, `G11`, `G15`). A
re-scope is a different failure from a wrong claim and may have a different
cause; do not fold them together because they are adjacent.

**Do not stop at `REPO-AUDIT`.** Sample the other recent menus — `HEALTH-AUDIT`,
`MACHINE-AUDIT`, `SKILL-AUDIT`, `DOCS-AUDIT-2` — for findings that carry
`Adjusted`, `WITHDRAWN`, `moot`, or an outcome note that contradicts the
finding's own premise. The skill says **every finding taken so far has turned up
an error in its own premises.** Test that sentence. If it is true, the rate is a
number worth having; if it is an overstatement that has been repeated into
doctrine, that is a finding in itself.

### The question the evidence has to answer

Not "should audits be more careful" — that is unfalsifiable and unimplementable.
Something a session can be held to. Candidates, to argue for or against on the
evidence, not to adopt because they are listed here:

- **A research phase that produces an artifact.** An audit currently reads and
  writes in one pass. A separate, checkable evidence log — every command run,
  with its output and its day — filed before any finding is drafted, and cited
  by number from the proposals.
- **A self-check pass before the menu is handed over.** The audit re-reads its
  own findings hunting only for unmeasured claims and already-decided questions,
  and reports what it found. `REPO-AUDIT` caught its own errors *while findings
  were being taken*, which is the expensive place to catch them.
- **A "has this been decided?" step**, per `G9` — a grep of every menu and the
  memory store for the subject of the proposal, before the proposal is written.
- **A confidence marker in the heading**, so a `medium` finding built on an
  inference is visibly different from one built on a command.
- **Extending `G18` past the `Proposal:` paragraph.** It is deliberately bound
  there so a suspicion can stay a suspicion. Say whether the boundary held —
  and note that `G9`'s wrong claim was in a *heading*, not a proposal.
- **Where the rule should live.** The `audit-menu` skill governs reading and
  taking; the research demands are currently re-derived in each brief in
  `docs/prompts/`. Diff three of those briefs and say whether the discipline is
  being reinvented per audit, and which layer should own it.

For each proposal state the **posture** — documentation only, a required phase,
an artifact, a check — and say plainly what it costs per audit. A rule that adds
an hour to every pass is a real trade, not a free improvement.

### Retrofit, which Nate has asked for

Only `UI-AUDIT` `F30` appears open, so this is small. Establish the real open
set first. Then for each open finding, propose labelling its central claim
**measured** or **reasoned**, re-verifying it as you go — and report which ones
did not survive. **Verify F30 against the running app**, not against its own
text; the `verify-ui` skill covers how, and `UI-AUDIT`'s header records that
seven of its proposals turned out to be wrong rather than merely stale.

Do not retrofit closed findings. Audit files are records; a closed finding's
premises are part of what was found that day.

---

## The plan

The last section of `META-AUDIT.md` is a **sequencing recommendation**, not a
schedule: which findings are worth taking first, which are cheap, which are
mutually exclusive, and which would be wasted if another is taken. If Part 1
concludes the index is not worth building, say so there in one line rather than
proposing it weakly.

Say explicitly what you could **not** verify from this session, and why.

## Conventions

Follow the `audit-menu` protocol as it stands. Findings are `### A1 — <severity>
— <title>`, `A2`, and so on — **but census the prefixes yourself first** from
every menu's own headings, including the ones whose items are bullets and bold
paragraph leads rather than headings. The skill's table admits it undercounts.
If `A` collides, pick another and say why in the header.

The file opens with a status header naming **this menu's own trap** — the thing
about its layout that a future reader will misread. Every menu here has one; if
you believe yours does not, `EFFICIENCY-AUDIT.md` is the only file that gets to
say that, and it earned it.

Nothing is taken until Nate names it. One PR per finding. Outcome note appended
under the finding in the same PR.

## What not to do

- Do not edit a skill, an index, a menu or `MEMORY.md` in this pass. Findings
  about them go in the file.
- Do not propose a check that mechanically reads outcome notes. That is the one
  thing the skill has ruled out repeatedly, and it has been wrong in both
  directions every time it was tried.
- Do not propose a count of anything as a maintained figure.
- Do not add a finding you intend to take in the same PR.
- Do not treat this brief's suggestions as a list to work through. Several of
  them are probably wrong; the evidence decides which.
