# Documentation audit, second pass — brief

Written 2026-09-02, the evening of a day that landed **202 commits and 88
merges** (counted on the day, across all branches) and **moved the working
directory** (`MACHINE-AUDIT.md` M7/M9/M12). The move is the reason this pass
exists: it falsified pointers by design, and the layer it falsified hardest is
the one no grep of the repo reaches.

The previous documentation audit — `DOCS-AUDIT.md`, 2026-08-25 — is **closed**,
all five findings re-verified earlier today. Do not reopen it, do not append to
it, and do not rewrite its measurements. It is a record.

## Read before starting

- `.claude/skills/claim-audit/SKILL.md` — where the claims live, the two shapes
  that rot, and the negatives fixture. **It has uncommitted changes and an
  untracked `reference/negatives.md` as of this writing; read the working tree,
  not `HEAD`.**
- `.claude/skills/audit-menu/SKILL.md` — how a finding is numbered, scoped,
  taken and recorded. The loop, and the posture rule.
- `.claude/skills/windows-shell/SKILL.md` — before any in-place edit.
- `DOCS-AUDIT.md`'s closing section, *What was checked and found healthy* — six
  things already cleared, two of which were nearly filed as findings. Do not
  re-file them.

## The three surfaces, all in scope

**1. Repo docs** — `nates-apps`, 106 `.md` files counted on 2026-09-02. The
character-creator README spine plus `docs/`, per-app READMEs, the root audit
files, `docs/plans/`, `docs/surveys/`.

`SETUP.md` belongs to this surface — it is at the repo root, not out on the
machine — but **what it describes is the machine**, which is why it goes stale
without a single repo file changing. Read it against surface 3, not against the
tree around it.

**2. The instruction layer** — `CLAUDE.md`, `.claude/skills/` (nine dirs on
2026-09-02), `.claude/agents/`. **Every one of the nine skills was edited
today**, and `claim-audit` was edited again after its own commit and is sitting
uncommitted. A wrong sentence here tells the next session what to do, so it
costs more than a wrong README line. This is the layer `SKILL-AUDIT.md` was
opened to audit, and the one its own brief records as the last place anyone
looked.

**3. The machine layer, outside the repo** — the global
`~/.claude/CLAUDE.md`, the memory store, and
`C:\Users\natha\Projects\workshop\` (`briefs/`, `books/`, `.claude/`,
`profile.ps1`, `tools/`). **Nothing in the repo points at any of it and no
commit hook touches it.** The global `CLAUDE.md` says so about itself: *"This
file is checked in nowhere, so nothing updates it but a hand."*

Treat the memory store as part of this layer. There are **two** memory
directories under `~/.claude/projects/` — one keyed to the old `Downloads`
working directory and one to `Projects-workshop`. Establish which is live before
trusting either. M10 recorded the old store as removed; verify that against the
filesystem rather than against the note.

## What counts as a finding

The two shapes from `claim-audit`, and essentially nothing else:

1. **A count or a name in prose** that nothing recomputes and nothing fails on.
2. **"The app cannot do X"** — true the day it was written, falsified when X
   shipped, and its attached instruction is *do not try*. These are the
   expensive ones.

Plus, for this pass specifically, the three orphan classes below.

**A measurement keeps. A claim about now rots.** Past tense and dated survives
forever; present tense and undated is wrong within weeks. Do not strip the good
numbers — they are the evidence for the rules they sit under.

### Some of this is already pinned — check before filing

`apps/character-creator/test/checks/documented-counts.mjs` exists precisely to
stop this rot, and it already asserts counts in prose, the scripts file map, the
data-script and migration tables, **the skill list in `CLAUDE.md`**, and the
file-size table in `docs/known-limitations.md`. It was split out of `smoke.mjs`
today, so its path is new even though the checks are not.

Two consequences, both easy to get backwards:

- **A pinned number that disagrees with the docs is a failing test, not a
  finding.** Run the suite before filing a count as stale. If it passes, the
  number is right and your reading is wrong.
- **A finding whose fix is a corrected number is half a fix.** The other half is
  a pin, so it cannot rot again — that is what turned these counts from prose
  into assertions in the first place. Propose the pin with the correction.

A count no test can reach — anything on surface 3, and most of the instruction
layer — is the part that genuinely needs a human eye, and is where this pass
earns its keep.

## The orphan work

**a. The prompt archive is incomplete, and its own README predicted it.**
`workshop/briefs/` and `nates-apps/docs/prompts/` hold twenty same-named files
that are **byte-identical apart from line endings** — verified 2026-09-02 with
`diff --strip-trailing-cr`; a plain `diff` calls all twenty different and is
lying to you. `briefs/` holds six the archive does not: `RETRO-CHECK-PROMPT.md`,
`SPELL-DESCRIPTIONS-RESEARCH-PROMPT.md`, `juicer.md`, `mech-boxer-statblocks.md`,
and two that look like un-hyphenated second copies of their own neighbours
(`REVIEWBRIEF.md` beside `REVIEW-BRIEF.md`; `setupv2rewriteprompt.md` beside
`setup-v2-rewrite-prompt.md` — **diff those two pairs before calling either a
duplicate**).

`docs/prompts/README.md` already establishes the intended relationship: these
are **records, not documents**, rescued out of `Downloads` because the outputs
were versioned and the instructions were not. So the archive is the repo copy
and the working copy is `briefs/`. The finding is not "there are duplicates" —
it is that the archive is **missing at least four briefs right now**, in a
directory whose README says in its own words that a hand-assembled archive is
missing something the day it lands. Propose the mechanism, not just the catch-up
copy: what makes the next brief arrive on its own?

**b. Docs nothing links to.** Files no README, index or skill points at. Start
with `SETUP-v2-CHANGES.md` sitting beside `SETUP.md` — note that it is a
findings menu whose filename does not say `AUDIT`, so no glob finds it — and
sweep `docs/plans/`, `docs/surveys/` and `briefs/` for entries with no inbound
reference. **An unreferenced file is not automatically rot**; a dated record
that nothing links to is still a record. Say which it is before proposing
anything.

**c. Stale catalog data in D1.** Rows nothing references — unpublished or
soft-deleted classes, catalog entries no class or wizard path reaches. **Ask
production, not local:** `node scripts/q.mjs --remote "…"`. A local database
accumulates, and a previous audit reported two duplicates against a local copy
that production had merged away weeks earlier. This is the one part of the pass
that is a data question rather than a docs question — **report it, propose it,
and do not fix it here.** Changing what a published class offers is its own
change with its own blast radius, not a line in a docs commit.

## Posture: fix live-instruction rot, propose everything else

This is what `DOCS-AUDIT.md` did and it is the agreed posture for this pass.

**Fix in the audit's own PR** only where all three hold: the file is a *live
instruction* (a skill, an agent, `CLAUDE.md`, a README command a reader will
run), the rot is *unambiguous*, and the correct value was *verified* rather than
inferred. A path that plainly moved in today's directory move qualifies. Record
each one in a `## Fixed here` table naming what, where, and what it said —
**describing the old claim, never reprinting its wording**, because a note
quoting the stale phrase defeats the grep that should find the next copy of it.

**Everything else becomes a numbered finding** with a `**Proposal:**` paragraph
specific enough to implement from and a stated posture. Nothing is taken until
Nathan names it. Do not take a finding in the same PR that files it.

## Routing — which menu owns the finding

`audit-menu` says outright: **do not open a new menu for work belonging in an
existing one.** Several open menus already own parts of these three surfaces —
`SKILL-AUDIT.md` owns the instruction layer, `MACHINE-AUDIT.md` owns the PC,
`UI-AUDIT.md` has an open F30, and the per-app menus own their apps.

So: **a finding an existing menu clearly owns goes there, in that file's own
prefix and heading shape.** The new menu is for cross-cutting documentation
findings none of them owns. Get the current list of menus from the tree, not
from the table inside `audit-menu` — that table has been wrong every time it has
been read, including twice today:

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

then add `SETUP-v2-CHANGES.md`, which that command cannot find.

**Read each target file's own headings before adding to it.** Prefixes, heading
levels and the optional severity word differ per file, two menus keep whole
families of items as bullets or bold paragraph leads rather than headings, and
any regex you write will be wrong about at least one of them.

If routing sends most findings elsewhere and the new menu ends up thin, that is
a correct outcome, not a failed pass. Say so.

## The new menu

`DOCS-AUDIT-2.md` at the repo root, prefix `D`, `###` headings, severity word in
the slot after the number — matching `DOCS-AUDIT.md`'s shape, whose `D5` puts a
*status* (`WITHDRAWN`) where the others put a severity. Open it with a status
line naming its own trap, as every menu here now does. Dated title.

Add its line to `MEMORY.md` in the live memory store when it is filed.

## Traps, all of which have fired here before

- **`diff` reports every cross-directory file as different** because the repo
  copies are CRLF and the workshop copies are LF. Use `--strip-trailing-cr`.
  Twenty false findings sit behind this one.
- **Never grep for an outcome note** to decide whether a finding is open. The
  wording varies by design — `Taken`, `Adjusted`, `Closed`, `Moot`, `Withdrawn`,
  and one closure whose text wraps across a line break so the phrase is
  unfindable. Read the lines under the heading to the next heading.
- **`--remote`, not local**, for anything the database answers.
- **Grep the whole file for a number you are deleting**, not the paragraph you
  are editing. `claim-audit` deleted its counts from one table and left the same
  figure standing three lines above and again at the bottom.
- **An absence claim needs a fresh read, not a grep.** *"X appears nowhere"* is
  the claim most likely to be wrong. Five of seven were false last time.
- **`MACHINE-AUDIT.md` M18 is open and it aims straight at this pass.** A bare
  command name intermittently fails to resolve and then works minutes later,
  undiagnosed. Half of this audit is *"does this path still exist"* and *"does
  this command still run"* — questions a spurious failure answers **no** to,
  producing orphan findings for files that are fine. **Re-run any negative
  before believing it**, and prefer a check that distinguishes "not found" from
  "did not run". M18 proposes nothing by design; do not try to fix it here, and
  do not re-run its four dead hypotheses.
- **Take a section, not a file:** `node scripts/readme-section.mjs "<heading>"`
  indexes `docs/` as well as the README. Auditing one sentence never needs the
  thousands of lines around it.
- **`node scripts/audit-citations.mjs --remote <F>`** lists what cites a
  finding. It has no opinion about whether that finding was taken — deliberately.

## Do not

- Turn the audit into a rewrite. Most of the prose is correct and carefully
  argued.
- Ship a behaviour change inside a documentation pass.
- Edit a brief in `docs/prompts/` to match what actually happened — the gap
  between what was asked and what was built is the point of keeping them.
- Rewrite any measurement in any audit file.
- Add a check that a finding was taken, or that the open count is right.

## Deliverable

1. `DOCS-AUDIT-2.md` — findings, numbered, each with a proposal and a posture,
   plus a `## Fixed here` table and a closing *checked and found healthy*
   section so the next pass does not redo the clearing work.
2. Findings routed into existing menus where those menus own them, listed in the
   new file by number and destination so nothing is lost between the two.
3. A short report of what was fixed inline and what is waiting on a word.
