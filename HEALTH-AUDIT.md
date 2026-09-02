# Health audit — process, 2026-09-02

Read-only review of how this repo is documented, worked and tooled. Checked
against `main` @ `34a7eea` (the merge of #515), the GitHub merge and check-run
history, and the files themselves. No production data was queried and nothing
was changed except this file.

**This is half an audit.** Tracks A (documentation), B (ways of working) and C
(skills and agent tooling) are below. Track D — the platform: schema, bindings,
Access, secrets, dependencies, cost, backups, tests, observability — is a
separate session and will be **appended to this file** with numbers continuing
from `F11`.

The bar throughout is *could Nate operate and reconstruct this in six months*,
not *could a stranger*. Findings that only trouble an outsider were dropped.

This audit replaces tracks A–D of `REVIEW-BRIEF.md`, which were scoped for the
character creator alone and never ran. Scope here is the whole repo.

## What this audit did not redo

- `DOCS-AUDIT.md` (2026-08-25) inventoried every `.md` and closed five findings.
  Track A below is the **delta since that date**, not a second inventory.
- `EFFICIENCY-AUDIT.md` (2026-08-25) covered the token economics of the
  ingestion loop, F1–F7 all taken. Track B is the *delivery* loop — branches,
  merges, deploys — and does not revisit that ground.

## The pattern worth naming

`DOCS-AUDIT` named its pattern as *a doc quoting a number that moves*. That
pattern is now largely solved, and the mechanism that solved it is worth stating
because it is what the open findings below are missing.

**The claims that survived are the ones a test parses out of the prose.** The
smoke suite reads the README's table count, `SETUP.md`'s endpoint count, the
skill list in `CLAUDE.md` and the junction loop in `SETUP.md` back out of the
sentences that state them, and fails until they match the tree. Every one of
those was checked this session and every one is **correct**.

Every stale claim found below sits in a file nothing parses. The rot did not
stop; it moved to where the checks are not. That is the finding under F5.

## Method, and what it got wrong

The open/closed state of the twelve findings menus was established with a script
that splits each file into blocks and reports blocks carrying **no** outcome
marker — inverted deliberately, because the `audit-menu` skill records that
grepping *for* the notes has been wrong four times. The blocks it flagged were
then read by hand.

**The first version of that script was wrong, and wrong in the documented way.**
Its pattern for the bold-paragraph-lead findings in `pick3cut5/AUDIT.md`
(`**T1. …**`) also matched an *inline* cross-reference — `**F10 excluded this on
a premise that is false.**` — in the middle of `BOOK-INGEST-AUDIT` F14's body.
That split the block and hid F14's own `Taken, 2026-08-31 (PR #434)` note, and
F14 was briefly written up here as open work. It is not; it shipped.

That is the fifth mechanical misread of these notes on record, it happened to
the audit whose subject is that they cannot be read mechanically, and it is the
argument for F8. The corrected script is at
`scratchpad/audit-census.mjs` (session-local; not committed).

Two further flags from the corrected run were also false on reading:
`INGESTION-AUDIT` F12 and F19 are **closed as moot** in a retirement table 1,294
lines from their headings, exactly as that file's own trap paragraph warns.

## Findings

---

### F1 — Critical — 6,006 production rows have no backup, no restore path and no runbook, and the repo says so in writing

**Evidence.** `apps/character-creator/docs/operations.md:276-285` states it
plainly: *"It cannot restore production, by design."* — with a measured table of
**6,006 rows on 2026-08-28 that no data script creates**: `media_items` 3,639,
`ff_filaments` 2,051, `ff_brands` 157, `character_items` 111, `claude_usage` 26,
`characters` 11, `play_events` 6, `campaigns` 3, `character_drafts` 2.

Against that, a sweep of all 77 tracked `.md` files for `backup`, `restore`,
`roll ?back`, `time travel`, `point in time` and `d1 export` returns **no
runbook of any kind**. The only two hits on `backup` are
`operations.md:162`, which names "backup posture" as a hypothetical *reason one
might someday split the database*, and this file. `rollback` appears once, in
`REDESIGN-AUDIT.md`, about optimistic UI state.

**Impact.** One `DROP TABLE`, one bad `--remote` apply, one Cloudflare account
problem and the media library, every character, every campaign and every play
event are gone with no stated way to get them back. The repo's own rebuild path
recovers the catalog and class definitions **only** — `operations.md` is
explicit that this is by design and that "rebuild from the repo" has already
been misread as "restore production" by at least one audit brief. The exposure
is documented; the mitigation is not. This is the single largest thing in the
repo that is only survivable because it has not happened yet.

**Proposal.** One PR adding a `## Recovery` section to
`apps/character-creator/docs/operations.md`, directly beneath the *"It cannot
restore production"* paragraph that establishes the need, covering: (a) what D1
Time Travel actually offers on this account — the retention window and the exact
`wrangler d1 time-travel` invocation, **verified against the live database, not
quoted from documentation**; (b) a single copy-pasteable export command and
where the output should go; (c) which of the nine tables are irreplaceable and
which the repo can rebuild, reusing the table already in that file. Posture:
**documentation plus one verified command — no automation, no scheduled job, no
new dependency.** Automating the export is a separate decision and should be its
own finding if wanted.

**Effort.** M — the writing is short; verifying Time Travel against the live
database is the work.

**Ongoing cost.** Near zero as proposed. It is prose plus a command. It carries
no recurring obligation, which is deliberate: a scheduled export that silently
stops is worse than a documented manual one.

**Confidence.** High that no runbook exists — the sweep covers every tracked
`.md`. Medium on what recovery is actually available: D1 Time Travel is the
obvious candidate and this audit did not run it. Verifying it is step (a).

**Taken, 2026-09-02 (PR #519), with F12 folded in as F12 proposed.** A
`### Recovery` section in `operations.md`, beneath the paragraph this finding
named. Posture held: documentation plus verified commands, no automation, no
scheduled job, no new dependency. `time-travel restore` was **not** run — it
rewrites the live database and there is no scratch database to rehearse on.

**Step (b) of this proposal was impossible as written.** It asked for "a single
copy-pasteable export command". `wrangler d1 export` **fails outright on this
database**:

```
D1 Export error: cannot export databases with Virtual Tables (fts5)
```

`journal_fts`, from `026-campaign-notes.sql`, makes the *whole* database
un-exportable by that path, and no flag skips it. The finding assumed the
obvious command existed. It does not, and nothing in the repo had ever tried it.

What replaced it is a per-table dump, verified on the largest table rather than
assumed — 3,639 rows of `media_items`, 2.2 MB, exit 0. The loop over the other
thirty-three tables is **not** written here: this finding's posture was
documentation plus one command, and a backup script is a different decision.
Filed as **F21**.

Two smaller deviations, both recorded in the PR: the section is a `###` rather
than the `##` proposed, because the placement this finding specified sits inside
*Standing up a new environment* and a `##` there would have orphaned everything
after it; and step (c)'s table was written as a three-way comparison of what each
mechanism covers, because the interesting column turned out to be *survives
losing the Cloudflare account*, where Time Travel is the one that fails.

---

### F2 — High — the deploy check is correct, and it is a thing to remember once per merge, 48 times a day

**Evidence.** The check works. Every merge commit from `d5280fe` (2026-08-27) to
the fix in `cf86961` (PR #399, 2026-08-30) was walked this session:
**65 consecutive merges, every one reporting `Cloudflare Pages=failure`**, then
`success` on the fix and on all eight most recent merges. The signal was never
ambiguous and never noisy for those four days.

Nothing read it. The repo merged 25 PRs on 2026-08-27, 39 on 2026-08-28 and 16
on 2026-08-30 while every one of those merges carried a `failure` conclusion
that a single API call would have surfaced.

`ship-pr/SKILL.md` step 9 now requires that call, per-merge. Merge volume is
**48 PRs on 2026-09-01 and 47 on 2026-08-31**; the repo has 511 merged PRs
total. There is no `.github/` directory, no CI, and no hooks in
`.claude/settings.json` — nothing runs unprompted.

**Impact.** The control is per-merge and manual, so its reliability is the
probability of remembering it 48 times in a day. The failure mode it guards is
**silent in both directions** — the site keeps serving the last good build — so
a lapse costs a full day of work before anything looks wrong. It already did
once, and the recovery was four days late.

**Proposal.** One PR adding a **sweep** to `scripts/` — a single command that
reads the last N merge commits on `origin/main` and prints any whose Pages
check-run is not `success`, defaulting to 20. Document it in `ship-pr` as the
end-of-session check that backstops step 9, not a replacement for it. Posture:
**report only, no exit code, no gate** — matching every other check in this repo
that reads GitHub or production. One call answers "did anything I merged today
fail to ship", which is the question step 9 answers 48 times.

**Effort.** S — it is the loop this audit already ran, in a file.

**Ongoing cost.** One command per working session. No new dependency; `gh` is
already required by the merge loop.

**Confidence.** High. The 65/65 failure sequence and the current 8/8 success
sequence were both read from the GitHub API this session.

**Taken, 2026-09-02 (PR #517).** As proposed, posture included: `scripts/deploy-sweep.mjs`
reports and never moves the exit code. `ship-pr` gains it as the end-of-session
backstop and keeps step 9 unchanged.

Three things the work turned up that the finding did not say:

- **It reports three states, not two.** A merge commit with *no* check-run at
  all is listed as not deployed. Pages registers one per merge, so an empty list
  means the deploy never started — and that is indistinguishable from a quiet
  healthy merge on every other signal. The finding assumed a `failure`
  conclusion was the only shape.
- **Validated against the outage rather than reasoned about.** Over the last 130
  merges it names 23 that did not deploy, all 2026-08-27 and 08-28, none before
  or since. On the last 10 it reports `NOTHING MISSING`, which is also how PR
  #516 was confirmed live.
- **The smoke test failed the first run**, on a check the finding did not know
  existed: *"every script in `scripts/` is named in the file map"*, a reverse
  check added after two scripts sat undocumented for several PRs. The README's
  script map gains an entry. That the gate caught it is the pattern F5 describes
  working — and the fact that a new script has a documentation step written down
  nowhere but the test is filed as **F20**.

---

### F3 — High — the method that produced this repo is not in this repo

**Evidence.** `C:\Users\natha\Downloads` holds **sixteen** prompt and brief files
driving the repo's own work: `REVIEW-BRIEF.md`, `class-audit-prompt.md`,
`efficiency-audit-prompt.md`, `ui-audit-prompt.md`, `n-findings-prompt.md`,
`media-vault-isbn-bulk-research-prompt.md`,
`media-vault-standardization-prompt.md`,
`filament-forge-standardization-prompt.md`, `gm-grants-prompt.md`,
`setup-v2-rewrite-prompt.md`, `pick3cut5-claude-code-prompt.md`, and others —
including `setupv2rewriteprompt.md`, a second copy of one of them under a
different name. `git ls-files | grep -iE "prompt|brief"` returns exactly one
tracked file, `scripts/extraction-prompt.mjs`, which is unrelated.

Between them these produced twelve findings menus, 200 numbered findings and the
`SETUP.md` v2 rewrite. All twelve menus are committed. None of the prompts is.

`REVIEW-BRIEF.md` previously lived only in a session-keyed temp directory and
was copied to Downloads on 2026-08-28 specifically because a temp cleanup would
have destroyed it.

**Impact.** The audits are the repo's main quality mechanism, and the inputs to
them sit untracked, unversioned and unbacked-up in a folder that also holds
PDFs, 3MF files and pharmacy receipts. Losing that folder loses the ability to
re-run any audit the same way, to see what an audit was told to look for, or to
tell why a menu covers what it covers. It has already produced one duplicate
under two filenames, which is what an unmanaged directory does.

**Proposal.** One PR creating `docs/prompts/` and moving in the briefs that
produced a committed artefact, each keeping its filename, with a short
`README.md` mapping prompt → the menu or document it produced. Move, do not
rewrite: they are records, and the `audit-menu` rule against editing a
measurement applies to the instructions that produced one. Skip anything
superseded or personal; `setupv2rewriteprompt.md` and `setup-v2-rewrite-prompt.md`
should resolve to one file. Posture: **archival, no new process** — nothing
requires a future prompt to land here.

**Effort.** S — a move and one index file.

**Ongoing cost.** One `cp` when a prompt produces something worth keeping, and
only then.

**Confidence.** High for the file inventory. Medium on which sixteen are worth
keeping — that is Nate's call per file, and the PR should list them rather than
assume.

---

### F4 — Medium — the skill about not trusting a count states three wrong ones about itself

**Evidence.** `.claude/skills/audit-menu/SKILL.md`:

- Line 8: *"Eight files here are **findings menus**"*. The tree has **twelve**,
  by the skill's own `find` command four lines further down.
- Its own table at lines 100–110 lists **ten** rows, omitting
  `REDESIGN-AUDIT.md` and `UI-AUDIT.md`. The skill flags the table as a snapshot
  that "has been wrong" — but the *prose count* above it carries no such warning
  and is a number that moves.
- `SETUP-v2-CHANGES.md` is a **thirteenth** findings menu — eight numbered
  changes, closed with *"All eight taken, 2026-09-02 (PR #502)"* — that neither
  the count, the table, nor the `find` command reaches, because it is not named
  `*AUDIT*`.

**Impact.** This is the file a session reads before touching any menu, and it
under-reports the corpus by a third. A session trusting "eight" and the ten-row
table will not know `REDESIGN-AUDIT` or `UI-AUDIT` exist, and will not find
`SETUP-v2-CHANGES` by any means the skill offers.

**Proposal.** One PR: replace the "Eight files" sentence with a description that
does not carry a value — the `find` command is already there and is the right
answer — add the two missing table rows, and either rename `SETUP-v2-CHANGES.md`
to match the `*AUDIT*` convention or note in the skill that one menu sits
outside it. Posture: **describe the row, not its value** — the same fix
`DOCS-AUDIT` applied in four other places.

**Effort.** S.

**Ongoing cost.** Negative — it removes two numbers that need maintaining.

**Confidence.** High. All three counts were read from the tree this session.

---

### F5 — Medium — `schema-change` quotes a table count that is seven tables stale, because nothing parses a skill

**Evidence.** `.claude/skills/schema-change/SKILL.md:42` quotes the README
sentence a new table must move as *"Twenty-six tables in one shared D1
database"*. `apps/character-creator/README.md:178` says **Thirty-three**, and
`db/schema.sql` contains **33** `CREATE TABLE` statements. The README is right;
the skill quotes a value it left behind seven tables ago.

The README is correct **because it is parsed**: `apps/character-creator/test/smoke.mjs:6294`
matches `/([\w-]+) tables in one shared D1 database/` and compares it against
`schema.sql`. `SETUP.md`'s endpoint count is pinned the same way
(`test/checks/environment.mjs` §3) and is likewise exact — 35 route files,
35 claimed. The skill body is parsed by nothing.

This is the pattern `DOCS-AUDIT` named on 2026-08-25 and fixed in four files,
three of them skills — `ship-pr`, `claim-audit`, `class-import`. It did not
touch `schema-change`, and the pattern survived there.

**Impact.** Small directly: the number is an illustration, and step 9 works
whatever value is quoted. It matters as a signal — the doc-rot defence in this
repo is per-sentence pinning, and skill bodies are the largest body of live
instruction outside its reach. This is the one instance found; there is no check
that would find the next.

**Proposal.** One PR: change the quote to describe the row rather than its value
(*"the sentence stating how many tables are in the shared database"*), and add
one smoke check asserting that no `.claude/skills/**/*.md` quotes a
`"… tables in one shared D1 database"` value that disagrees with `schema.sql`.
Posture: **one narrow check for the one claim that recurs**, not a general
skill-prose linter — the `audit-menu` skill's argument against pinning things
whose wording varies applies here and should not be overridden.

**Effort.** S.

**Ongoing cost.** One assertion in a suite that already has thousands.

**Confidence.** High for the stale quote — README, `schema.sql` and the skill
were all read. Medium on the check being worth it: it pins one sentence shape
and would not have caught the other four instances `DOCS-AUDIT` fixed.

---

### F6 — Medium — the permission allowlist covers the read-only scripts and not the loop

**Evidence.** `.claude/settings.json` allows 26 Bash patterns. Compared against
every `node scripts/*.mjs` invocation the skills and `SETUP.md` actually
instruct: `class-check`, `drift-check`, `q`, `readme-section`, `repo-vs-live`
and `source-coverage` are allowed; **`audit-citations.mjs`, `catalog-diff.mjs`
and `d1-apply.mjs` are not**. The file contains **zero** entries for `gh`, `git`
or `npx` — the three commands the merge loop, the `--remote` queries and the
health check are built from, across 511 merged PRs.

**Impact.** Friction, concentrated on the highest-frequency work. Every merge,
every `d1 execute --remote`, every `gh api` check-run call prompts. F2's
proposed sweep would prompt too. `audit-citations.mjs` is read-only and step 5
of the `audit-menu` protocol; `catalog-diff.mjs` is read-only and instructed by
`book-survey`.

`d1-apply.mjs` writing to production is a **correct** omission and should stay
omitted — the point is that the allowlist reads as an accident of what was run
on the day it was written rather than a decision about what is safe.

**Proposal.** One PR adding the read-only instructed scripts
(`audit-citations.mjs`, `catalog-diff.mjs`), the read-only `gh` verbs the loop
uses (`gh pr list`, `gh pr view`, `gh pr checks`, `gh api repos/…/check-runs`),
and read-only `git` (`git status`, `git log`, `git diff`, `git ls-files`).
Posture: **read-only only.** `d1-apply.mjs`, `gh pr merge`, `git push`,
`git commit` and every `--remote` write stay off the list on purpose, and the
PR should say so in a comment so the omission is not read as an oversight and
"fixed" later.

**Effort.** S.

**Ongoing cost.** None. It is a static file.

**Confidence.** High on the contents. Medium on the value — this is Nate's own
friction, and he is the one who knows whether these actually prompt often enough
to matter.

**Taken, 2026-09-02 (PR #518).** As proposed, posture included: thirteen
read-only entries added, every write action left off. `deploy-sweep.mjs` was
added alongside the two the finding named — it did not exist when F6 was written
and shipped one PR earlier.

Two things the finding did not anticipate:

- **`settings.json` cannot hold a comment, so the explanation could not go where
  the proposal put it.** The finding asked for the omission to be stated "in a
  comment so it is not read as an oversight". A top-level `"//"` key — the
  convention `.claude/launch.json` already uses, and one the published schema
  appears to permit through `additionalProperties` — is **rejected**:
  `Unrecognized field: //`. The explanation is in `CLAUDE.md` instead, which is
  the better home anyway: it is the one file loaded in every session regardless
  of working directory. That section also records the constraint, so the next
  person does not retry the `"//"` key.
- **The `gh api` entry had to be narrowed to be safe.** A prefix wildcard cannot
  exclude a `-X DELETE`, so `gh api *` would not have been read-only in any
  meaningful sense. It is pinned to this repo's `commits/` path, which GitHub
  exposes no write verbs on. Written into `CLAUDE.md` as *do not widen*.

---

### F7 — Medium — port 8788 is hardcoded in three places, and three separate audits found it occupied by something else

**Evidence.** `.claude/launch.json` hardcodes port 8788 in both `pages dev`
configurations. `apps/character-creator/README.md:796` tells the reader the app
is at `http://localhost:8788/apps/character-creator/`. Three audits record
hitting it:

- `apps/character-creator/UI-AUDIT.md:5` — *"**not** 8788, which belongs to
  another worktree"*
- `apps/media-vault/BULK-AUDIT.md:31` — ran on **8801**, *"not 8788, which
  was…"*
- `apps/media-vault/ISBN-AUDIT.md:26` — *"8788 was already listening, owned by
  another process"*

No live instruction anywhere mentions this. All three records sit in dated audit
files, which is exactly where the next person will not look.

**Impact.** The failure is not the collision — it is that a page served from
*another worktree's* server on 8788 looks identical to your own. Verification
then passes against code you did not write, and the screenshot proves the wrong
thing. This repo has already learned once that a UI change can pass 768 smoke
checks and be broken on screen; verifying against the wrong server is the same
class of error with no check behind it.

**Proposal.** One PR adding a short note to `SETUP.md`'s local-development
material and to `.claude/launch.json`'s existing comment block: 8788 is a
convention, a second worktree makes it ambiguous, and the way to be sure is to
confirm the served page carries a string from *your* branch before trusting
anything you see. Posture: **documentation only, no port change** — moving the
default would invalidate the README line and three audit records and fix
nothing.

**Effort.** S.

**Ongoing cost.** None.

**Confidence.** High that the three records exist and that nothing live warns.
Medium that this still happens — nothing was listening on 8788 or 8799 during
this session, so the collision was not reproduced here.

---

### F8 — Medium — no menu states its own status, so establishing that there is no open work costs an audit

**Evidence.** Twelve findings menus, **200 numbered items**, 14,300 lines. Every
one of the 200 is closed — verified this session by the block-level census
described under *Method*, plus hand-reading every flagged block.

Establishing that took a purpose-built script, a bug in that script, and four
hand-reads. The known traps all fired: `INGESTION-AUDIT` F12 and F19 close in a
retirement table 1,294 lines from their headings; `BOOK-INGEST-AUDIT` F14's note
was hidden by an inline `**F10 …**` reference; `pick3cut5/AUDIT.md` T6 carries
its outcome in the heading and nowhere else.

**One file already solves this.** `apps/character-creator/AUDIT.md:12` opens
with *"**All fourteen items are closed**, re-verified against the tree on
2026-08-26"* and then a paragraph naming the exact trap — that a `**Fix**:` line
under a section heading is the outcome for D1–D6 and C1–C2. It records that two
scans had already reported them open. This audit's first pass made it three, and
the header is the only reason it took thirty seconds to correct rather than an
hour. It works, and it is the only file that has one.

**Impact.** The repo's largest documentation category is a closed archive that
cannot be recognised as closed without re-deriving it. That cost is paid every
time anyone asks "what is still open" — the `audit-menu` skill says the state
was reconstructed from the files "nine times before this was written", and this
is at least the tenth. It also means a genuinely open finding would be
indistinguishable from the closed ones, which is the direction that actually
loses work.

**Proposal.** One PR adding a single dated status line to the top of each of the
other eleven menus, in the shape `apps/character-creator/AUDIT.md` already uses:
what is closed, as of what date, and — where the file has one — the trap that
makes a scan disagree. Do not add a check that the line is accurate: the
`audit-menu` skill's rule against a mechanical reader of these notes is correct
and this proposal does not overturn it. The line is a claim a human maintains,
the same as every other measurement in these files. Posture: **one line per
file, no automation, no reformatting of any finding.**

**Effort.** M — eleven files, and each needs its state read before the line can
be written honestly. This audit did that reading; the PR should redo the two
that were subtle rather than trust this file.

**Ongoing cost.** One line updated in the same PR that takes a finding —
alongside the dated outcome note the protocol already requires, so it is one
extra line in a commit that is already touching the file.

**Confidence.** High that all 200 are closed. High that the pattern works —
`AUDIT.md` is the worked example and it demonstrably shortened this audit.

---

### F9 — Low — `CLAUDE.md` sends a reader to the wrong file for the migration list

**Evidence.** `CLAUDE.md:7-8`: *"App conventions, the data model, and the
migration list live in `apps/character-creator/README.md`."* The README was split
on 2026-08-26 (PR #309). It still holds the data model (`## Data model`, line
176) and the conventions, but the **migration list** — the per-file table
describing what each migration adds — is now
`apps/character-creator/docs/operations.md:68-86`. The README's only remaining
mentions are two lines of directory tree.

`CLAUDE.md` was itself committed on 2026-08-28, two days after the split, so the
pointer was edited past and not corrected.

**Impact.** Small and real. `CLAUDE.md` is the one file loaded into every
session regardless of working directory — the smoke suite has a check that
exists solely to protect that property — so a reader arriving from Downloads
follows this sentence first. The README's `## Contents` table does list
`docs/operations.md` with an accurate description, so the reader recovers in one
hop rather than being stranded.

**Proposal.** One PR changing the sentence to name `docs/operations.md` for
migrations and keeping the README for the data model and conventions.
Posture: **one sentence, no restructuring.**

**Effort.** S.

**Ongoing cost.** None.

**Confidence.** High. Both files were read this session.

**Taken, 2026-09-02 (PR #522).** As proposed: one sentence, no restructuring.
Re-audited first and the premise held exactly — `operations.md` carries **43**
migration-table rows, the README carries **0**, and the other two things the
sentence claims (app conventions, `## Data model` at README:176) are still
there.

Written as a **negative** rather than simply corrected: *"The migration list is
**not** there."* A reader who half-remembers the old sentence needs to be told
the thing they are looking for moved, not just shown a different filename.

---

### F10 — Low — the same fact is stated as "four" and as "five" in the same skill

**Evidence.** `.claude/skills/audit-menu/SKILL.md` on how often a mechanical read
of the outcome notes has been wrong: line 46 *"produced **four** false findings
here"*, line 68 *"has been wrong **five** times"*, line 174 *"has got this wrong
**four** times"*.

**Impact.** Trivial in itself. It earns a line because it is the argument the
skill makes about every other file, appearing inside the file that makes it —
and because the true figure moved again today: the census under *Method* above
is the fifth or sixth instance depending on which of the skill's own numbers is
right.

**Proposal.** One PR settling the three to one value, or — better, and
consistent with F4 and F5 — replacing the count with the argument, which does
not move: a mechanical reader of these notes **has been wrong repeatedly and in
both directions**. Add today's instance if a count is kept. Posture:
**describe the failure, not its tally.**

**Effort.** S.

**Ongoing cost.** Negative — it removes a number that has already drifted twice
inside one file.

**Confidence.** High.

---

### F11 — Low — two documents are reachable from nothing

**Evidence.** Every tracked `.md` was checked for an inbound reference by
filename from any other `.md`. Two have none:
**`SETUP-v2-CHANGES.md`** (219 lines, a closed eight-item menu) and
**`apps/character-creator/REDESIGN-AUDIT.md`** (1,110 lines, fifteen closed
findings, R1–R7 and N1–N8).

The five `docs/surveys/*.md` files that the same check flags are **not** orphans
— `README.md`'s Contents table links the `docs/surveys/` directory rather than
each file, which is deliberate. `test/fixtures/long-bowman.md` is a parser
fixture referenced by code.

Note that internal links are already pinned: `test/checks/environment.mjs`
asserts *"all internal markdown links resolve"*. That check catches links
pointing at nothing; nothing catches a file nothing points at.

**Impact.** Low. Both are closed records, so nothing is lost by not finding
them — but `REDESIGN-AUDIT` is the menu behind roughly twenty of the last
sixty PRs, and it is invisible to anyone navigating from the README.

**Proposal.** One PR adding both to a list of menus — the `audit-menu` skill's
table is the natural home and F4 already opens that file, so **fold this into
F4's PR rather than opening a second one** if F4 is taken. Otherwise, one line
each in `apps/character-creator/README.md`'s Contents table and `SETUP.md`'s
structure block. Posture: **make them findable; change neither file's body.**

**Effort.** S.

**Ongoing cost.** None.

**Confidence.** High.

---

## Bus factor

Not a finding — a reading of the ones above, because the question "what is
unrecoverable if Nate is unavailable" cuts across them.

Three things in this half of the review are held in one place:

1. **The data.** F1. Nine tables of hand-built and hand-transcribed content with
   no stated recovery. This is the one that is unrecoverable in the literal
   sense.
2. **The method.** F3. Sixteen prompts in a Downloads folder. The repo's outputs
   are all versioned; the instructions that produced them are not.
3. **The state of the backlog.** F8. Two hundred findings whose closure exists
   only as prose that a reader has to interpret, in files that have already been
   misread five times.

Everything else found here is friction, not loss.

**A fourth belongs to Track D and is only noted here**: `SETUP.md` records that
there is no Access policy-as-code in the repo and that every Access and Pages
change is dashboard work through one person's browser. That is assessed in the
platform half.

## What was checked and found healthy

Recorded so the next audit does not redo it.

- **Every pinned documentation claim checked is correct.** The README's
  *"Thirty-three tables"* matches 33 `CREATE TABLE` in `schema.sql`;
  `SETUP.md`'s endpoint count matches 35 route files exactly; `CLAUDE.md` names
  all six skills and states the right number; `SETUP.md`'s junction loop names
  all six. Each of these is parsed back out of the prose by the smoke suite,
  which is why.
- **The skill and agent junctions are intact on this machine.** All six repo
  skills are present in `~/.claude/skills` alongside eleven plugin skills, and
  `~/.claude/agents/book-reconcile.md` resolves.
- **`SETUP.md` v2 (PR #502, 2026-09-01) is accurate.** Its project-structure
  tree, its deploy-failure section and its Access destination table all match
  the tree and the recorded history. It is the newest large document in the repo
  and it is the one with nothing wrong in it.
- **The deploy is currently landing.** The eight most recent merge commits all
  report `Cloudflare Pages=success`.
- **All 200 findings across all twelve menus are closed.** No open work exists
  anywhere in the audit corpus. `REBUILD-AUDIT` F16 and `REDESIGN-AUDIT` R3 read
  as open to a scan and are not: F16 is *"Posture: blocked, no action"*, a
  deliberately recorded negative result, and R3 is closed unadopted (PR #464).
- **`docs/plans/README.md` is internally consistent.** Its first table has
  sixteen rows against nineteen plan files, which reads as a mismatch and is
  not — the remaining plans are listed in two further tables below it. Nearly
  filed as a finding.
- **Commit and PR discipline is uniform.** 511 merged PRs, one branch each,
  descriptive prose titles, `--delete-branch` throughout. Zero reviews on the
  last forty, which is correct for a single-author repo and is not a finding at
  the stated bar.

Three of the items in this section were nearly filed as findings before being
checked. That ratio is the same one `DOCS-AUDIT` reported, and the same argument
for reading rather than believing a pattern match.

---

# Health audit — platform, 2026-09-02

Track D, appended to the process half above. Checked against `main` @ `34a7eea`,
**production D1 by `--remote` query**, and **production HTTP by unauthenticated
`curl`**. Nothing was written: no D1 writes, no deploys, no dashboard changes,
no commits. Numbers continue from `F11`.

Scope was a hygiene pass — confirm the patterns are applied consistently — not
a threat model. No attacker model was built and nothing was exploited.

## Correction to F1, 2026-09-02

**F1 said the recovery path was unknown and rated that Medium confidence. It is
now known, and F1 understates the situation in one direction and overstates it
in another.**

`wrangler d1 time-travel info nates-workshop-media` answers. The database has
point-in-time restore available right now, the D1-scoped token can read it, and
the retention ceiling was measured rather than quoted: a timestamp 45 days back
is refused with *"Please provide a timestamp within the last 30 days"*, and one
20 days back resolves to a bookmark. **The window is 30 days.**

So recovery is not absent — it is one command, and nobody has written it down.
`time travel`, `time-travel` and `bookmark` appear nowhere in the repo's 77
tracked markdown files.

F1's proposal stands and step (a) is now answered; F12 below carries the
verified detail. F1's severity does not change: an undocumented, never-exercised
mechanism with a rolling 30-day ceiling is not a backup, and the thing F1 is
really about — that nobody has looked — is unaffected.

## Findings

---

### F12 — High — the only real recovery is a 30-day rolling window nobody has written down, and the rebuild that is documented reproduces names but not values

**Evidence.** Two commands, both run this session.

`npx wrangler d1 time-travel info nates-workshop-media` returns a current
bookmark and the exact restore invocation. Retention was probed and is **30
days** (45 days back: refused; 20 days back: resolves). Nothing in the repo
mentions it.

`node scripts/repo-vs-live.mjs` completes with:

> *"The repo creates the right ROWS. Some of them hold the wrong VALUES.
> 32 field(s) across 30 row(s) differ in value."*

and names the two causes it already knows — a `restore-*.sql` carrying 6 of
`gear`'s 18 columns, and rows enriched through the catalog editor or importer,
which write straight to D1 and leave nothing in git. It closes with *"Reported,
not enforced: this does not move the exit code."*

A third command matters for how these read together: `node
scripts/drift-check.mjs --remote` prints **`NO DRIFT`**. Both are correct.
`drift-check` compares migrations, tables, columns and class *names*;
`repo-vs-live` compares *values*. Quoting the first as evidence the repo can
reproduce production is the misreading available here, and `operations.md`
records that an audit brief already opened on that assumption once.

**Impact.** Stacking the three: the catalog rebuild recovers the right rows with
30 wrong field values and no exit code to notice; the other 6,006 rows (F1) it
cannot recover at all; and the one mechanism that recovers everything expires
30 days after the damage, is undocumented, and has never been run.

A concrete illustration arrived during this audit rather than being hypothetical.
`operations.md` measured `characters` at **11 rows on 2026-08-28**. It holds
**3 today** — a drop of eight, across the window in which PR #480 shipped
character deletion. That is very probably intentional cleanup of test
characters. **Nothing in the system can tell Nate whether it was**, and after
2026-09-27 nothing can undo it either.

**Proposal.** Fold into F1's PR rather than opening a second one, since F1
already proposes the `## Recovery` section this belongs in. That section should
carry: the verified 30-day window and that it is **rolling**, the two
`time-travel` invocations (`info` to find a bookmark, `restore` to use one), the
fact that the D1-scoped token reaches it, and a plain statement that
`drift-check`'s `NO DRIFT` and `repo-vs-live`'s value diff answer different
questions — with the 30-row value gap named as the reason a rebuild is not a
restore. Posture: **documentation plus verified commands. Do not run
`time-travel restore` to test it** — it mutates production, and a drill belongs
on a scratch database if it is wanted at all.

**Effort.** S as a fold-in; the verification is already done and recorded here.

**Ongoing cost.** None. The window is Cloudflare's and needs no maintenance.

**Confidence.** High throughout. Every number was produced by a command this
session, not quoted.

**Taken, 2026-09-02 (PR #519), folded into F1 as this finding proposed.** The
`### Recovery` section carries the rolling 30-day window, both `time-travel`
invocations, that the D1-scoped token reaches them, and the plain statement that
`NO DRIFT` and the 30-row value diff answer different questions.

**One thing this finding had right and F1 did not, and one it missed.** It was
right that the recovery story needed the *rolling* qualifier rather than just the
number. It missed that `wrangler d1 export` does not run here at all — see F1's
note and **F21**. That failure strengthens this finding rather than weakening it:
the 30-day window is not merely the *only documented* recovery, it is the only
recovery reachable by a single command, and it lives inside the same Cloudflare
account as the thing it protects.

---

### F13 — Medium — a third production secret exists, and the section that enumerates the secrets says there are two

**Evidence.** `SETUP.md` → *Environment configuration (Cloudflare Pages
dashboard)* opens *"Settings → Environment variables, **both encrypted**"*,
lists `ANTHROPIC_API_KEY` and `ADMIN_EMAIL`, and then reinforces it: *"the
dashboard holds only **the two** encrypted secrets above"*.

`functions/api/media-vault/lookup.js:2-3` states that the TMDB key *"lives in the
**TMDB_API_KEY Pages secret**"*, and `env.TMDB_API_KEY` is read there. Line 16:
*"TMDB modes fail with a clear 503 when the secret is missing."*

`.dev.vars.example` omits it as well — it lists exactly the same two.

**Impact.** The one document an operator would use to stand up, audit or rotate
this deployment's secrets is wrong by one, and says "two" twice, so a careful
reader gets no hint to look further. The failure is graceful — MediaVault's
video lookup 503s with a well-written error naming the secret — but the operator
has no inventory to work from, and a rotation performed from `SETUP.md` silently
covers two of three keys. A fresh local checkout following `.dev.vars.example`
gets the same gap.

The full inventory, as established this session: **`ANTHROPIC_API_KEY`** (Pages
*and* the standalone Worker — two places, documented),
**`ADMIN_EMAIL`** (Pages), **`TMDB_API_KEY`** (Pages, undocumented here), and
**`CLOUDFLARE_API_TOKEN`** (local User-scope environment variable, documented in
`CLAUDE.md`). `ACCESS_TEAM_DOMAIN` and `ACCESS_AUD` are plain vars in
`wrangler.jsonc`, correctly described as not secrets.

**Proposal.** One PR adding `TMDB_API_KEY` to `SETUP.md`'s environment section
with the same shape as its neighbours — what reads it, what happens when it is
missing, and where a new value takes effect — replacing "both encrypted" and
"the two" with wording that does not carry a count, and adding the same entry to
`.dev.vars.example`. Posture: **documentation only; no secret is created,
rotated or moved.**

**Effort.** S.

**Ongoing cost.** None, if the count is removed rather than corrected — the
current wording is a number that moves, which is this repo's known rot pattern.

**Confidence.** High. All four files were read this session.

**Taken, 2026-09-02 (PR #520).** As proposed, posture included — documentation
only, no secret created, rotated or moved. `TMDB_API_KEY` is in `SETUP.md` with
the same shape as its neighbours and in `.dev.vars.example`; both counts were
removed rather than corrected, since "two" is a number that moves.

**Every premise held on re-check** — the first taken finding in this menu that
needed no correction. Two things were added that it did not name, both belonging
where a rotation actually starts:

- **The Anthropic key is a two-place rotation.** The standalone Worker holds its
  own copy. `SETUP.md` said so two sections up, under *Its secret is separate*,
  and not in the list an operator would work from.
- **TMDB's key must be the 32-character v3 key, not a v4 read access token.**
  `lookup.js:47` knows this well enough to report it by name on a 401. No
  document said it.

Worth carrying to the next inventory: this secret could sit unlisted because its
failure is *partial*. Only the three `video-*` modes need it, so an unset key
takes out part of one app while every other route stays healthy. **An inventory
omission survives in proportion to how gracefully the thing degrades** — which
is an argument for auditing secrets from the code that reads them rather than
from the document that lists them.

---

### F14 — Medium — local wrangler is a full major version ahead of the one that compiles the deploy, and one text check guards one syntax

**Evidence.** `npx wrangler --version` on this machine resolves **4.114.0**.
`SETUP.md:157` records that the Pages build image ships **3.114.17**, and five
other files repeat it. There is no `package.json`, no `node_modules` and no
lockfile, so nothing pins either side: `npx` resolves whatever its cache holds,
and Cloudflare moves the build image on its own schedule.

The guard that exists is
`apps/character-creator/test/checks/environment.mjs` §9, a **text** check that
fails on an import attribute in either spelling or on a reach into `scripts/`.
`SETUP.md` explains why it is text and not a build, and the reasoning is right:
building with the wrangler that resolves *here* compiles the broken syntax
happily and would have passed straight through the four-day outage.

But the reasoning rules out one build, not all builds. **Nothing has been tried
with the build image's own version pinned**, which is the check the argument
does not cover.

**Impact.** The 2026-08-30 outage was one syntax form out of a major-version
gap, and it cost 65 merges (F2). The text check now catches that one form. Every
other 3.x/4.x divergence — any syntax, config key or bundler behaviour esbuild
3.x rejects — fails identically and silently, and the local toolchain gives no
warning because it is a version that accepts everything.

**Proposal.** One PR adding a pre-merge check that runs
`npx wrangler@3.114.17 pages functions build` into a scratch directory and fails
on a non-zero exit — pinned to the build image's version explicitly, which is
the distinction `SETUP.md`'s argument turns on. Keep §9's text check: it is
faster, it needs no network, and it names the specific hazard. Posture:
**additive. Do not remove the text check, and do not move any existing exit
code** — the new check should report until it has run clean for a while, because
a false failure that blocks a merge is worse here than the thing it guards.

The version literal has to be maintained by hand when Cloudflare moves the build
image, which is the argument for treating this as a decision rather than an
obvious win — see the ongoing cost.

**Effort.** M — the check is short; deciding the posture and confirming
`wrangler@3.114.17` still installs is the work.

**Ongoing cost.** Real, and the reason this may be worth declining: a pinned
version literal that Cloudflare can invalidate without telling anyone, plus a
network fetch on every pre-merge run. If the answer is no, the cheaper half is
worth taking alone — record the current gap (4.114.0 vs 3.114.17) in `SETUP.md`
beside the outage section, so the next person reads it as *two versions apart*
rather than as one bad import.

**Confidence.** High on the version gap — both numbers are from this session and
the file. Medium on the proposal: whether a 3.114.17 build actually reproduces
the Pages environment closely enough to be worth the maintenance is exactly what
the trial would establish.

---

### F15 — Medium — the Access bypass prefix serves the gated landing page to anyone, on any path under it

**Evidence.** Thirteen production paths were fetched unauthenticated this
session. The wall behaves exactly as documented — `/`,
`/apps/character-creator/`, `/apps/media-vault/`, `/api/claude`,
`/api/media-vault/items`, `/api/character-creator/*`,
`/api/filament-forge/catalog` and `/shared/js/api.js` all **302** to the login
wall; the four intended bypass paths answer (`/apps/pick3cut5/` 200,
`/shared/styles.css` 200, `/shared/js/ui.js` 200, `/api/pick3cut5/room` **426**,
correctly demanding a WebSocket upgrade).

The exception is what happens on a path *under* the bypass prefix that no
function claims:

```
GET /api/pick3cut5/zzz-not-a-route  ->  200  text/html  7,255 bytes
```

That is the site's `index.html` — `<title>Nate's Workshop</title>`,
`<h1>Nate's Workshop</h1>` — served unauthenticated. `/` itself 302s. The cause
is documented behaviour the repo already knows: `PUBLIC_PREFIXES` is
prefix-matched (`_middleware.js:43`), it calls `next()`, no function matches, and
Pages' static handler answers an unknown path with the landing page at 200 —
which is why `apps/pick3cut5/test/smoke.mjs` checks content type rather than
status. The two facts are recorded separately and have not been put together.

**Impact.** Low in content, real in kind. What leaks is `index.html` and, through
it, `apps/manifest.json`: the four app names, their descriptions, and the
"More Coming Soon — Model Router and more" teaser. No data, no API, no identity.
But it is the one place the site's only wall is bypassed by a static fallback
rather than by a decision, and the same mechanism will serve whatever the landing
page grows into next. It also means a probe under that prefix cannot distinguish
"route exists" from "route does not", which is exactly the confusion `/shared/`
already caused once.

**Proposal.** One PR narrowing `PUBLIC_PREFIXES` from a prefix test to the exact
route set the app uses — `/api/pick3cut5/room`, `/api/pick3cut5/solo/generate`
and whatever else `apps/pick3cut5/app.js` calls, derived rather than
hand-listed — with anything else under the prefix refused by the middleware
rather than handed to `next()`. Posture: **narrow the hole, change no behaviour
the game depends on.** The existing smoke test derives the Access destination
list from `index.html` and its stylesheets; the same derivation should produce
this list, so the two cannot drift apart.

**Effort.** S.

**Ongoing cost.** None if derived; a maintenance burden if hand-listed, which is
the argument for deriving it.

**Confidence.** High on the behaviour — reproduced twice with different paths.
Medium on the proposal shape: whether the route list is cleanly derivable from
`app.js` was not checked, and if it is not, a hand-maintained list may be worse
than the prefix.

---

### F16 — Medium — the component holding the key, the money path and the rate limiters is the one with 2.5% test coverage, no preview and a manual deploy

**Evidence.** `workers/pick3cut5-room/src/` is **2,072 lines** — `room.js`
1,226, `generate.js` 437, `anthropic.js` 197, `index.js` 161, `rules.js` 51.
`apps/pick3cut5/test/game.mjs` imports **`rules.js` only**. The other 2,021
lines are imported by no test.

That component is simultaneously: the holder of a **second copy** of
`ANTHROPIC_API_KEY`; the only publicly reachable path that can spend it —
`claude_usage` shows `pick3cut5-solo` at **21 of 28 calls and 94% of all input
tokens**, most recently **today**; the only place the rate limit bindings exist,
because Pages Functions cannot use them; **not deployed by a merge**
(`npx wrangler deploy --config …`, by hand, and it must run *before* the Pages
deploy that binds it); and untestable on a preview, because the Access bypass is
hostname-specific and does not follow the app onto preview URLs — so `SETUP.md`
states it is *"verified on production immediately after merge."*

By contrast the character creator, which is behind the login wall and cannot
spend anything without an admin email, carries **11,233 lines** of test.

**Impact.** Every structural safety net this repo has — merge-is-deploy, the
smoke suite, the preview environment, the login wall — stops at this Worker's
boundary, and coverage is thinnest exactly where they stop. A regression in
`generate.js` or the limiter wiring reaches production with nothing between it
and a stranger, and the first signal would be a spend row or a broken game.

**Proposal.** One PR adding unit coverage for the two pure, high-consequence
seams in `generate.js`: category validation (what the caller is allowed to ask
for) and the limiter decision (which bucket a request is charged to, and what
happens when either is exhausted) — imported directly, the way `game.mjs`
already imports `rules.js`, with no network and no Worker runtime. Posture:
**pure-function tests only.** Do not attempt to test the Durable Object, the
Anthropic call or the WebSocket here; that needs a Worker test runner and is a
much larger decision.

Extracting whatever is needed to make those two seams importable is part of the
work and should be kept to the minimum that achieves it.

**Effort.** M.

**Ongoing cost.** Small — it joins a suite that already runs on every merge.
`game.mjs` proves the import path across the `workers/` boundary works.

**Confidence.** High on the numbers and the structural facts. Medium on the
proposal: whether those two seams are cleanly extractable was not verified, and
if `generate.js` is tightly coupled to the Worker runtime the effort is L rather
than M.

---

### F17 — Low — the spend table is a good instrument that nothing looks at

**Evidence.** Metering works and is honest. Every Claude call in `functions/`
and both Worker paths write a `claude_usage` row, fail-open. Queried this
session: 28 calls since 2026-08-24, ~350K input and ~14.5K output tokens across
five endpoints. Spend to date is negligible.

The guardrails around it are unusually well reasoned. `/api/claude` enforces an
`ALLOWED_MODELS` allowlist and a `MAX_TOKENS_CEILING` of 16,000
(`_lib/claude-client.js:10,17,47,77`). The Worker's two rate limiters are **sized
in money** in their own comment — a verified generation measured at ~57,000 input
tokens and ~$0.19, a global cap of 12/minute chosen to hold the ceiling under
~$180/hour rather than the ~$860/hour the original 60/minute allowed.

What is missing is a reader. `SETUP.md` states the posture outright —
*"Spend visibility, not a cap. Nothing on the request path reads this table,
there is no budget and no refusal"* — and that is a **deliberate, recorded
decision this finding does not reopen.** But visibility that nobody looks at is
not visibility. The three queries `SETUP.md` provides are run when someone
thinks to run them, and the table has three read-and-remember properties in
common with the deploy check in F2.

**Impact.** The rate limiter caps the *rate*, not the *total*. At the global
ceiling, sustained, the documented arithmetic reaches roughly $4,300/day, and
the only thing that would surface it is someone running a query unprompted. The
realistic case is far smaller and far more likely: a slow leak — a stuck client,
a scripted caller under the limit — accumulating quietly for weeks. Nothing
distinguishes that from silence.

**Proposal.** The cheapest control is not in this repo at all: **a spend limit on
the Anthropic account itself**, which refuses rather than reports and needs no
code. That is console work and is listed under *Cannot verify from here*. If a
repo-side change is wanted instead, one PR adding the `claude_usage` daily
rollup to whatever end-of-session sweep F2 produces, so one command answers both
"did anything fail to deploy" and "did anything spend". Posture: **report only —
do not add a cap, a refusal or a gate on the request path**, which would
contradict a decision already made and written down.

**Effort.** S, and only if F2 is taken first — this is one query appended to it.

**Ongoing cost.** None beyond F2's.

**Confidence.** High on the measurements and the code. The claim that nobody
looks is inferred from there being no mechanism, not from evidence that Nate
does not run the query.

---

### F18 — Low — the Worker has observability enabled and the Pages half has nothing configured

**Evidence.** `workers/pick3cut5-room/wrangler.jsonc` sets
`"observability": { "enabled": true }`, with a comment explaining the choice:
*"Free on Workers and unavailable on Pages… When a room misbehaves in production
this is the only way to find out why."* The root `wrangler.jsonc` contains no
`observability`, `logpush` or `tail` configuration of any kind.

So the API surface behind the login wall — 35 character-creator endpoints, the
MediaVault CRUD and lookup proxy, FilamentForge's data routes, `/api/claude` —
produces no queryable log. The failure modes those routes have are real and
already documented in `SETUP.md`'s troubleshooting section: a 503 naming signing
keys when `ACCESS_TEAM_DOMAIN` is wrong, a 500 when `ANTHROPIC_API_KEY` is
unset, a fail-closed 403 when `ADMIN_EMAIL` is missing. Each is diagnosed today
by a person hitting it and reading the browser console.

**Impact.** Low while the user base is a handful of friends who will say
something. It sets the floor on how quickly anything is noticed: for the Pages
half, the detection mechanism is a human complaining.

**Proposal.** This is a **question before it is a change.** The Worker comment
asserts observability is unavailable on Pages; whether that is still true is
worth five minutes in the dashboard before any code is written. If it has become
available, one PR turns it on and the asymmetry closes. If it has not, the honest
outcome is a line in `SETUP.md`'s troubleshooting section saying the Pages half
has no logs and the browser console is the tool — which is what the section
already implies without stating. Posture: **verify first; documentation if the
answer is no.**

**Effort.** S either way.

**Ongoing cost.** None.

**Confidence.** High that nothing is configured. Low on whether it *can* be —
that claim comes from a code comment of unknown age and was not verified, which
is the whole proposal.

---

### F19 — Nit — both wrangler configs point `$schema` at a directory this repo does not have

**Evidence.** `wrangler.jsonc:2` and `workers/pick3cut5-room/wrangler.jsonc:2`
both set `"$schema": "node_modules/wrangler/config-schema.json"`. `CLAUDE.md`
opens by stating there is no `package.json` and no `node_modules`; both are
absent, confirmed this session.

**Impact.** None at runtime — `$schema` is an editor hint and wrangler ignores
it. The two files that configure production carry a path that resolves to
nothing, in a repo whose stated identity is that it has no dependency tree.

**Proposal.** One PR either removing both lines or pointing them at the
published URL (`https://unpkg.com/wrangler/config-schema.json`), whichever suits
how the files are edited. Fold into any other PR touching a wrangler config
rather than opening one for this. Posture: **cosmetic.**

**Effort.** S.

**Ongoing cost.** None.

**Confidence.** High.

---

## What was checked and found healthy — platform

The platform half is in better shape than the documentation half. Recorded so
the next audit does not redo it.

- **`node scripts/drift-check.mjs --remote` prints `NO DRIFT`.** Every migration
  matches `schema_migrations`, every data script matches `data_script_runs`,
  every table and column matches `sqlite_master`, and every published class
  matches one a data script can recreate. Read F12 for what this does *not*
  cover.
- **Schema and live agree exactly.** 33 base tables plus the `journal_fts`
  virtual table in both; **22 indexes in both**. Two apparent discrepancies were
  chased and both were my own grep: `CREATE VIRTUAL TABLE` does not match
  `CREATE TABLE`, and `CREATE UNIQUE INDEX` does not match `CREATE INDEX`.
- **The five-place rule holds on the newest migration.** `043-character-grants`
  is present as the migration, as a `CREATE` in `schema.sql`, as a guarded row
  in the seeding block, in `operations.md`'s migration table, and in the
  README's data model. The seeding block's guards are per-feature
  (`WHERE EXISTS (SELECT 1 FROM pragma_table_info(…))`), which is what lets a
  fresh database skip migrations correctly.
- **Every statement against the per-user tables is scoped.** All fifteen
  `SELECT`/`UPDATE`/`DELETE` statements touching `media_items`, `ff_config`,
  `ff_history`, `ff_presets` and `ff_custom_filaments` carry
  `WHERE user_email = ?` or `WHERE email = ?`. No unscoped read or write exists.
  The column name differs per app (`user_email`, `email`,
  `owner_email`/`player_email`) but is consistent within each.
- **The one piece of dynamic SQL is allowlist-gated.** `bulk-update.js` builds
  `SET` assignments by string, and every field name passes `SETTABLE[f]` first;
  values are bound, ids are type- and length-checked, and the batch is capped.
  No injection path.
- **`/api/claude` is properly bounded** — `ALLOWED_MODELS`, a 16,000
  `MAX_TOKENS_CEILING`, a 400 on a malformed body, and fail-open metering that
  cannot break the call it measures.
- **The Access wall holds.** Thirteen unauthenticated fetches: everything 302s
  except the four intended bypass paths. F15 is the single exception and it
  serves the landing page, not data.
- **The rate limiters are sized in money, not requests**, with the arithmetic in
  the config comment. This is the best-reasoned control in the repo.
- **The two wrangler configs have not drifted.** Same `compatibility_date`
  (2026-04-19), same D1 database id, `workers_dev` correctly off, `script_name`
  present on the Durable Object binding as Pages requires. Neither codebase
  imports a `node:` builtin.
- **The documented rebuild path works today** — `scripts/rebuild-local.mjs`
  applied 360 files and 4,264 statements with 0 failures. What it does *not*
  reproduce is F12.
- **Growth is not a risk.** `media_items` 3,639 and `ff_filaments` 2,051 are
  unchanged since the 2026-08-28 measurement in `operations.md`; the whole
  database is roughly 8,000 rows against a 5M-reads/day free tier.
- **No secret is tracked.** `.gitignore` covers `.dev.vars*`, `.env*`,
  `.wrangler`, `.cache/` and `*.tmp`, with the commit-message trap explained in
  a comment; only `.dev.vars.example` is committed, and it contains
  placeholders.

Two things were nearly filed as findings and killed by checking: the index and
table "drift" above, and the eight endpoints calling `request.json()` bare —
which all wrap it in a `try`/`catch` returning a 400, exactly as
`apps/character-creator/AUDIT.md` C1 recorded when it fixed the four that did
not.

---

# Summary — both halves

## The three that would hurt most

1. **F1 + F12 — the data.** 6,006 rows no script can recreate, 30 rows that
   rebuild with wrong values, and a 30-day rolling restore window that is
   undocumented and has never been exercised. Everything else on this list is
   recoverable work; this one is not.
2. **F2 — the silent deploy.** The check is correct and manual, at ~48 merges a
   day. It has already failed once for 65 consecutive merges over four days.
   Nothing has changed structurally since; only the habit has.
3. **F16 — the Worker.** The key, the money path and the only public endpoint,
   with 51 of 2,072 lines under test, no preview, and a deploy that a merge does
   not perform.

## The three cheapest wins

1. **F12 folded into F1** — write down the two `time-travel` commands and the
   30-day window. The verification is already done and in this file. Effort S,
   and it converts the largest exposure in the repo into a known procedure.
2. **F13** — add `TMDB_API_KEY` to `SETUP.md` and `.dev.vars.example`, and drop
   the word "both". Effort S, and it makes the secret inventory true.
3. **F2's sweep** — one command over the last N merge commits. Effort S, near-zero
   ongoing cost, and F17's spend query rides along in the same command.

## Cannot verify from here

- **Anthropic account spend limits.** Whether a budget cap exists on the API key
  is console work. It is the cheapest possible control for F17 and this audit
  cannot see it.
- **Cloudflare Access policies.** The allow list, the Pick 3 Cut 5 bypass
  application's five destinations, and the separate preview-access policy are
  dashboard-only; `pages project list` exits 1 under the D1-scoped token. The
  *effects* were verified by curl (F15); the policies themselves were not read.
- **Whether Pages observability has become available** (F18). One dashboard
  look, and the proposal turns on the answer.
- **R2.** The `MEDIA` bucket's contents, size and public-access setting are
  unreachable — the token has no R2 scope, re-confirmed in `CLAUDE.md`
  2026-08-25. Nothing in the code serves a public bucket URL, which is the part
  that could be checked.
- **Whether `wrangler@3.114.17` still installs and builds** (F14). Not attempted;
  it is the trial the proposal asks for.
- **Whether the eight deleted characters mattered** (F12). Only Nate knows
  whether those were test rows.
- **The 8788 collision** (F7). Nothing was listening during this session, so
  three audit records are the evidence and it was not reproduced.

## Risk register

Failure modes this setup carries **by design**, with the control that catches
each. Several are correct trades that were made deliberately; the column that
matters is the last one.

| # | Failure mode | Control today | Gap |
|---|---|---|---|
| 1 | Data destroyed or corrupted in D1 | D1 Time Travel, 30 days, rolling | Undocumented, never run, expires. **F1/F12** |
| 2 | A merge compiles locally and not on the build image | Text check §9 for one syntax; check-runs per merge | Guards one form out of a major-version gap; the per-merge read is manual. **F2, F14** |
| 3 | The standalone Worker is not deployed, or deployed after Pages | `SETUP.md` states the order | Nothing enforces it; symptom is a 503 in party mode only |
| 4 | A stranger spends the Anthropic key | Two rate limiters, sized in money; model allowlist; token ceiling | Caps rate, not total; nothing reads the spend table. **F17** |
| 5 | The site's only wall is bypassed | Access on every route; `PUBLIC_PREFIXES` must agree with the dashboard policy; `smoke.mjs --remote` checks both | Two lists in two systems, one dashboard-only; unrouted prefix paths serve the landing page. **F15** |
| 6 | An Access or Pages setting is lost or changed | None — no policy-as-code, dashboard only | Not reconstructible from the repo. One person, one browser |
| 7 | An API route breaks behind the login wall | The smoke and regression suites, pre-merge | No production logs; detection is a human complaining. **F18** |
| 8 | The catalog and the repo diverge | `drift-check --remote`, `repo-vs-live.mjs` | Both are manual; `repo-vs-live` reports without an exit code by design. **F12** |
| 9 | A secret is rotated in one place and not the other | `SETUP.md` documents the two `ANTHROPIC_API_KEY` copies | The inventory omits a third secret. **F13** |
| 10 | Work is lost because a finding was never closed | The audit-menu protocol; 200 findings, all closed | No menu states its own status; five mechanical misreads on record. **F8** |

Rows 3 and 6 have no proposed finding. Row 3 is a documented ordering rule whose
blast radius is one app's party mode, and enforcing it needs a deploy pipeline
this repo has deliberately declined. Row 6 is the largest structural risk in the
system and its fix — Access policy-as-code, or an exported record of the
policies — is a decision about how much infrastructure this project wants, not a
defect to be filed. Both are recorded here so they are chosen rather than
forgotten.

---

# Findings raised while working the menu

Findings that did not exist when the audit was written, added as the menu was
worked. Numbered from `F20` and appended here rather than filed among F1–F19,
because those are a dated record of what two sessions found and renumbering them
would destroy it.

Each carries a **When** line: whether it should be settled before the next wave
of the plan, or after the waves are done.

---

### F20 — Nit — a new script in `scripts/` has a documentation step that exists only in the test

**Raised.** Taking F2 (PR #517).

**Evidence.** The first merge-gate run on F2's branch failed:

```
FAIL  every script in scripts/ is named in the file map — deploy-sweep.mjs - add it or delete it
```

`apps/character-creator/test/smoke.mjs:6346-6358` reads the README's *The
scripts at the repo root* section and requires every `.mjs`, `.py`, `.txt` and
`.json` on disk to appear in it. Its comment gives the reason: `read-columns.py`
and `ocr-fields-lib.mjs` both sat in `scripts/` undocumented for several PRs,
*"and a file map that quietly stops being a map is worse than none, because the
count of entries reassures you the list is whole."*

The requirement is written down nowhere else. `schema-change` documents the
**five** places a column lands and the nine a table needs; `ship-pr` covers the
merge loop; neither mentions that adding a script has a second place. Nothing in
`CLAUDE.md` or `SETUP.md` does either.

**Impact.** Nearly none, and this finding argues for its own decline. The check
is a hard gate, so the map cannot silently rot — which is the failure it was
built for, and it holds. The cost is one failed test run and one confused minute,
paid by whoever adds the next script.

The error message already does most of the work a document would: it names the
file and says *"add it or delete it"*. What it does not say is **where** the map
is, which is the only part a reader has to go and find.

**Proposal.** The cheapest version is not a document at all — extend the check's
failure message to name the section and the file, so the answer arrives with the
question:

```
deploy-sweep.mjs - add it to "The scripts at the repo root" in
apps/character-creator/README.md, or delete it
```

Decline the documentation half. A line in `ship-pr` saying "a new script needs a
README entry" would be a second place to keep current, describing a rule the
test already enforces perfectly, in a skill that is read before the merge loop
rather than before writing a script. Posture: **improve the message, add no
document.**

**Effort.** S — one string.

**Ongoing cost.** None. It replaces a string with a longer string.

**Confidence.** High. Reproduced by failing the gate, then fixed by adding the
entry and passing it.

**When — after the waves.** Nothing is blocked by it. Every remaining wave that
adds a script will hit the same clear failure and recover in a minute, which is
evidence for the finding rather than a reason to hurry it.

---

### F21 — Medium — the one-command way to copy this database off Cloudflare does not run, and nothing replaces it

**Raised.** Taking F1 (PR #519).

**Evidence.** `wrangler d1 export nates-workshop-media --remote` fails on this
database, every time:

```
D1 Export error: cannot export databases with Virtual Tables (fts5)
```

The virtual table is `journal_fts` — campaign-note search, created by
`db/migrations/026-campaign-notes.sql`. One FTS5 table makes the **whole**
database un-exportable by that path; there is no flag that skips it, and the
error is a hard refusal rather than a partial export.

The per-table alternative works. Verified against the largest table on
2026-09-02: `--json --command "SELECT * FROM media_items"` returned all **3,639
rows**, 2.2 MB, exit 0. The database has **34 tables**; nothing loops them.

**Impact.** F1 and F12 establish that D1 Time Travel is the recovery mechanism
and that it is a rolling 30 days. What this finding adds is that Time Travel
lives **inside the same Cloudflare account as the data it protects**, and the
standard way to hold a copy anywhere else does not run here. So the account
itself is a single point of failure with no working one-command mitigation — not
because the data cannot be copied, but because copying it takes a loop nobody has
written and nobody has run.

This is not urgent in the way F1 reads. The realistic loss is not "Cloudflare
deletes the account"; it is that the only off-platform copy requires
thirty-four commands typed by hand at exactly the moment somebody is panicking.

**Proposal.** One PR adding `scripts/d1-backup.mjs`: enumerate the user tables
from `sqlite_master`, skip the FTS5 virtual table and its four shadow tables
(`journal_fts_data`, `_idx`, `_docsize`, `_config` — all derived, all rebuilt by
the triggers in `026`), and write one JSON file per table into a directory the
caller names. Print a row count per table and a total, so a short file is
visible rather than silent.

Posture: **manual, report-only, no schedule and no new dependency.** Do not add
a cron, a hook, or a GitHub Action — F1's posture note applies here too, and a
scheduled export that quietly stops is worse than a documented manual one. Do not
attempt to make `d1 export` work by dropping and recreating `journal_fts`; that
is a production mutation in a recovery tool, which is the wrong shape entirely.

It needs a README script-map entry in the same PR (see **F20**), and the
`### Recovery` section in `operations.md` should lose its "nothing automates this
loop" sentence when it lands.

**Effort.** S — a `sqlite_master` query, a loop, and the invocation this session
already verified.

**Ongoing cost.** Two lines: a file-map entry to keep current, and a script that
will need touching if a table is ever added whose contents should not be written
to disk. Running it is the operator's choice, not an obligation.

**Confidence.** High on both halves — the export failure and the per-table
success were each reproduced this session against production.

**When — before wave 3, if it is taken at all.** Nothing is blocked by it and it
can wait until after the waves without risk. But it belongs with F1 and F13 in
the data-protection wave rather than filed among the cleanups: it is the missing
half of the runbook that just shipped, and the `operations.md` sentence pointing
at it is written as an open loop.

**Taken, 2026-09-02 (PR #521).** `scripts/d1-backup.mjs`, run against production
before it was committed: **33 of 33 tables, 8,723 rows, complete**, with the six
skips resolving exactly as intended (`_cf_KV`, `journal_fts`, and its four
shadow tables).

Two departures from the proposal, both deliberate:

- **It derives the skip list instead of naming the four shadow tables.** The
  proposal listed `journal_fts_data`, `_idx`, `_docsize` and `_config` by hand.
  Virtual tables come out of `CREATE VIRTUAL TABLE` in `sqlite_master`, their
  shadow tables from a prefix off the virtual table's own name, and Cloudflare's
  from `_cf_`. A second FTS table added later is covered without editing the
  file; the hardcoded list would have been wrong the day that happened, silently
  and in the direction that writes junk into a backup.
- **It exits non-zero when a table fails**, which reads against the stated
  report-only posture and is not. Report-only here means it gates nothing and
  schedules nothing — no cron, no hook, no Action, nothing consuming the exit
  code. A backup tool that reports success after writing half a database is a
  defect rather than a posture, and the two ideas were worth separating in the
  file itself.

Everything else held: manual, no dependency, and `d1 export` was **not** worked
around by touching `journal_fts` in production. `operations.md`'s Recovery
section lost its "nothing automates this loop" sentence and points here.

The README script map entry went in with the PR rather than after the smoke test
asked for it — **F20 being useful one PR after it was filed**, which is a
small argument that F20 should be closed as already-solved-by-knowing rather
than taken.

One thing left undone on purpose: `d1-backup.mjs` is **not** in the
`.claude/settings.json` allowlist. It only reads D1, but it writes files to a
caller-named path, which is a different question from the read-only rule F6
settled. Worth a decision rather than a default.
