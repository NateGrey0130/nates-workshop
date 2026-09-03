# Repository architecture audit — git, GitHub, layout and the merge path, 2026-09-03

**Status: `G8` taken 2026-09-03 (PR #620). The other sixteen are OPEN.** Read
the lines under a finding's own heading for its state — this line is a
convenience and it is the kind of line that goes stale first. Every other `G`
number is a proposal awaiting a word.

**`G8`'s central premise was false, and its note is worth reading before taking
anything else here.** It claimed the suite "has never been runnable on a bare
clone"; a bare clone passes all 1662 checks. The real blocker was one
`existsSync` assertion. That is the second finding in this menu whose premises
did not survive contact — the header below already records two caught before
filing — so treat the *reasoning* in these findings as a lead, not as
established fact.

**This menu's own trap, stated first, as the `audit-menu` skill asks.** Every
number in this file is a **GitHub-side or filesystem-side measurement taken on
2026-09-03**, and most of them are settings a single click changes without
touching git. A finding here can therefore become false without any commit,
which is the opposite of how the rest of this repo's menus rot. **Re-measure
before taking one** — the commands are quoted inside each finding, and every one
is read-only.

## Findings are `### G<n> — <severity> — <title>`

`G` for git. It collides with nothing: `F` is in use by **eleven** menus, and
`D`, `M`, `R`, `S`, `B`, `C`, `T`, `N` and `P` are each taken. Severity is
lowercase — `high`, `medium`, `low` — in the `UI-AUDIT.md` and
`apps/character-creator/AUDIT.md` shape rather than `HEALTH-AUDIT.md`'s
capitalised one.

## What this menu does NOT cover

**Portability is not here.** `docs/prompts/portability-audit-prompt.md` — added
2026-09-02 in `c7fe004`, and **never run** — asks for `PORTABILITY-AUDIT.md`
with findings `P1, P2, …` covering the nine junctions, the untracked permissions
file, the OCR cache, the PDFs, the two secrets files and the two environment
variables. That brief owns the question *"what would it take to work from
another machine."*

This menu touches that boundary at exactly one point — **G8**, where the test
suite's inability to run on a bare clone is what forecloses continuous
integration — and hands the general problem back. **Do not file portability
findings here.** If `PORTABILITY-AUDIT.md` is ever produced, G8's outcome note
should cite its number rather than restate it.

Also out of scope by prior ownership: the instruction layer (`SKILL-AUDIT.md`),
documentation content (`DOCS-AUDIT-2.md`, D1–D3 open), the machine itself
(`MACHINE-AUDIT.md`), and the book-ingestion loop (`BOOK-INGEST-AUDIT.md`).

## The scope Nate set, 2026-09-03

Reproduced because four findings only make sense in its light:

1. **All four layers are in scope** — git/GitHub, repo layout on disk, the
   authoring workflow, and release/deploy mechanics.
2. **Non-blocking checks only.** A check may report; it may not gate the merge
   button. G1 is written to respect this and says so explicitly, and G14 records
   the blocking alternative as *declined in advance* rather than pretending it
   does not exist.
3. **Visibility is genuinely undecided.** G2 is written with both paths costed
   and no recommendation.

---

## Found healthy — do not file against these

Checked and correct on 2026-09-03. Listed so a later pass does not spend a
finding on them.

- **Branch pruning works.** `git ls-remote --heads origin` returns **one** ref,
  `main`, against **616 pull requests**. The hand step in `ship-pr` is being
  done. G4 is about the guarantee, not about a mess.
- **`.gitattributes` is doing real work and its comments say why.** `*.sql text
  eol=lf` exists because three classes reached production with literal `\r`
  inside stored markdown in PR #92. The vendored-library and `woff2` rules are
  both justified in-file.
- **`.gitignore` is ahead of its failures.** It excludes `.cache/`, `.dev.vars*`
  with a re-included `.example`, `.claude/settings.local.json`, and `*.tmp` —
  the last carrying the story of `commit-msg.tmp` shipping inside PR #404.
- **No secret has ever been committed.** `git log --all --diff-filter=A` over
  `*.pdf`, `.cache/*` and `*.epub` returns nothing: the OCR cache and the
  sourcebook PDFs have never entered history, so no rewrite is needed for them.
  The values that *are* public — `ACCESS_AUD`, the D1 `database_id`, the team
  domain — are addressed in G2 and are not secrets in the credential sense.
- **The PR body convention is exceptional and consistent.** PR #615 carries a
  gap statement, a before/after table measured against production, an explicit
  "nothing regresses — checked, not assumed" section, a posture line, an
  acceptance test, a recorded decline path, the five suites' pass lines, and the
  diff stat. G7 is about that convention being invisible to GitHub, not about
  its quality.
- **The permission allowlist's gaps are deliberate and documented.**
  `.claude/settings.json` withholds `d1-apply.mjs`, `gh pr merge`, `git push`
  and every `wrangler d1 execute`, and `CLAUDE.md` explains why in a section
  that exists because `settings.json` rejects comments. G1's posture was chosen
  to agree with this.
- **`git config remote.origin.prune=true`** is set locally, so stale
  remote-tracking refs clean themselves.

---

### G1 — high — `main` has no protection of any kind, and a merge here IS a deploy

`gh api repos/NateGrey0130/nates-workshop/branches/main/protection` returns
**`404 Branch not protected`**. There is no ruleset either. Measured
2026-09-03.

So nothing at the GitHub end distinguishes the reviewed, PR-shaped path this
repo uses **616 times** from a direct `git push origin main`. The only thing
standing between a stray push and a production deploy is that
`.claude/settings.json` withholds `git push` from the agent — a client-side
convention on one machine, which stops an agent in this repo and stops nothing
else: not a session started elsewhere under the working directory's own
settings, not `git` run by hand, not a push from a second machine.

**This is asymmetric with how carefully everything else here is gated.** An
apply to production D1 costs a deliberate keystroke by design. A push straight
to `main` — which deploys the site — costs nothing.

**Proposal:** add a GitHub **ruleset** on `main` with exactly one rule:
*require a pull request before merging*, with **zero required approvals** and
**no required status checks**. Solo repos can self-merge under this rule; it
forbids the direct push and nothing else. Do **not** enable "require
conversation resolution", "require linear history", or any status check —
those are the gates Nate ruled out.

Record it in `CLAUDE.md` beside the allowlist section, which is where the "what
is deliberately absent, so nobody reads it as an oversight" reasoning already
lives.

**Posture: forbid the bypass, gate nothing.** The merge button stays as free as
it is today. If taking this makes the merge button harder in any way, the
finding has been implemented wrong.

**Decline path, and it is real.** A ruleset that requires a PR removes the
emergency direct push — the "production is broken and the fix is one line"
path. Two answers exist: rulesets support a **bypass list** that can name the
repo owner, which preserves the escape hatch while making it a deliberate act;
or decline on the grounds that a one-line fix through a PR takes ninety seconds
here and the escape hatch has never been used. **Check that second claim before
relying on it** — `git log --first-parent main` will show any commit that
reached `main` without a merge.

### G2 — high — the repo is public, and no file in it records that as a decision

`"private": false, "visibility": "public"` — measured 2026-09-03. Nothing in
`CLAUDE.md`, `SETUP.md` or any menu states that this was chosen, or on what
grounds.

**What is public, measured rather than assumed:**

| what | size / value | already documented as safe? |
|---|---|---|
| Transcribed sourcebook prose in SQL | **4.5 MB** across 359 scripts in `apps/character-creator/db/` | **no** |
| `ACCESS_AUD` + team domain | `wrangler.jsonc` | **yes** — the file says outright neither is a secret, and the AUD rides in every login redirect |
| D1 `database_id` | two `wrangler.jsonc` files | not stated; account-identifying, not a credential |
| The whole instruction layer | `.claude/skills/`, ~2.5 MB of menus | not stated |

**The first row is the finding.** `.gitignore` says of the OCR cache: *"OCR
caches of commercial sourcebooks - local only, never committed."*
`apps/character-creator/README.md` says of `docs/surveys/`: *"Facts about each
book; no prose from it."* Two deliberate rules, both about keeping book text out
of the repo — and the data scripts are the exception nobody wrote a rule for.
`add-rue-spells-batch.sql` alone is **180 KB** and carries full descriptive
paragraphs verbatim: *Cloud of Smoke*'s and *Death Trance*'s complete entries
are in it, attributed to *Rifts Ultimate Edition*, in a public repository.

**This is not a bug report about the app.** The rows have to exist for the app
to work, they are correctly attributed, and their provenance discipline is the
best thing in this repo. The question is only whether the **public mirror** of
them was intended.

**Proposal — path A, go private.** `gh repo edit --visibility private`. Costs:
nothing on the Cloudflare side (Pages builds from an installed GitHub App, which
keeps working on a private repo — **verify this before flipping**, it is the one
claim here that would hurt if wrong); public links to the repo break; no other
consumer exists.

**Proposal — path B, stay public and make it deliberate.** Add a `LICENSE` (see
G17) plus a short `NOTICE` or a paragraph in the root README (G3) stating that
catalog rows are transcriptions from Palladium Books material, reproduced for
personal play, unaffiliated and unendorsed. This does not manufacture a right
that does not exist; it stops the repo being silent about the one thing a reader
would ask.

**Posture: a decision recorded either way.** The failure this finding is really
about is that neither answer is written down anywhere.

**Do not take this one on a reading of this finding alone.** It is the only
finding in the menu with a consequence outside the repository.

### G3 — medium — a public repo with 693 files and no root `README.md`

There is no `README.md`, `LICENSE`, `CONTRIBUTING.md` or `SECURITY.md` at the
root. GitHub's landing page for this repository is a bare file listing whose
first readable entry is `BOOK-INGEST-AUDIT.md`, a 139 KB menu.

`CLAUDE.md` is the de facto root document and is addressed to an agent — it
opens on the absence of a build step and moves to Cloudflare token scoping. It
is the right document for its reader and the wrong one for a human arriving
cold. Meanwhile `apps/character-creator/README.md` is an excellent front door
for **one app** and is two directories down.

**Proposal:** a short root `README.md` — a screenful, not a document. What Nate's
Workshop is; the four apps with one line and a link each; the stack in one line
(Cloudflare Pages + D1, no build step, no dependencies); that merging to `main`
deploys; and a routing table to `CLAUDE.md`, `SETUP.md` and the audit menus.
**It must not restate anything.** Every count it might quote is either pinned by
the smoke test elsewhere or free to drift, and this repo's recurring failure is
docs quoting moving numbers.

**Posture: documentation only, and deliberately thin.** A root README that grows
past a screen becomes a fifth place that goes stale.

**Watch for one thing when taking it.** The smoke suite pins documentation
claims (`Documentation claims` is a named section in
`test/checks/environment.mjs`). Adding a README that makes a checkable claim may
extend that check's surface — which is fine, but the count moves and the pass
line changes.

### G4 — low — branch deletion on merge is discipline, not a setting

`"delete_branch_on_merge": false`. The remote nonetheless holds exactly one
branch, so the hand step in `ship-pr` is being performed reliably across 616
PRs.

**Proposal:** turn the setting on and simplify `ship-pr`'s pruning step to a
verification rather than an action.

**Posture: settings only, one click.**

**Decline path, and it is a genuine conflict rather than a formality.** Stacked
PRs die when their base branch is deleted: `gh pr merge --delete-branch` on a
base has closed a child PR here, and a closed-that-way PR cannot be reopened,
only replaced. Turning the repo setting on makes that deletion automatic and
unconditional — it would fire on every merge, including the base of a stack,
where today the hand step at least *could* be skipped. If stacked PRs are still
part of the workflow, **decline this**, and say so in the note so it is not
re-proposed.

### G5 — low — three merge methods are enabled and only one is used

`allow_merge_commit`, `allow_squash_merge` and `allow_rebase_merge` are all
`true`. History shows **501 merge commits** against **1,267 commits** — the
merge-commit path, exclusively, in the shape `Merge pull request #N from
NateGrey0130/<branch>` over one or two subject commits.

That history shape is genuinely useful here: `deploy-sweep.mjs` walks merge
commits on `main` as its unit of work, and `--first-parent` gives a clean
per-PR ledger. Squashing would flatten it; rebasing would remove the merge
commits the script counts.

**Proposal:** disable squash and rebase merging, leaving merge commits as the
only button. Nothing about existing history changes.

**Posture: settings only.** This removes a way to accidentally produce a history
shape a script depends on not seeing.

**Verify one premise before taking it.** Confirm `deploy-sweep.mjs` genuinely
keys on merge commits rather than merely defaulting to them — the header says
"the last 20 merge commits", which reads as a window rather than a contract.

### G6 — medium — Issues, Projects and Wiki are all enabled and all empty

`has_issues`, `has_projects`, `has_wiki` — all `true`. The tracker in practice
is the audit-menu system: seventeen files, numbered findings, taken one at a
time.

On a **public** repo this is not merely untidy. Issues are open to strangers,
and an issue filed there would land in a place nobody looks, with no template
and no answer — while the actual queue lives in `BOOK-INGEST-QUEUE.md` and the
menus.

**Proposal:** disable Projects and Wiki outright. For Issues, choose
deliberately: disable it as well (the menus are the tracker, and there is no
second contributor), **or** keep it and add a single `.github/ISSUE_TEMPLATE/config.yml`
with `blank_issues_enabled: false` and one contact link pointing at the menus.

**Posture: reduce the number of places to look.** Whichever way Issues goes,
the outcome note should say which and why, because "we use the menus" is exactly
the kind of unwritten convention this repo keeps rediscovering.

### G7 — medium — the PR convention is excellent, and invisible to GitHub

PR bodies here follow a strict, unusually good shape. That shape exists only
inside the `ship-pr` skill. GitHub offers no prompt: `.github/` does not exist,
so the compose box opens empty.

Today that costs nothing, because every PR is opened by an agent that has read
the skill. It costs everything the first time one is not.

**Proposal:** add `.github/pull_request_template.md` carrying the section
headings the convention already uses — the gap; what was measured, with its
source and date; posture; what regresses and how that was checked; the decline
path; verification output. Comment each heading with a line saying what belongs
under it.

**Do not have it duplicate `ship-pr`.** It is a prompt, not a second copy of the
procedure — a second copy is a second thing to keep in sync, which is the
argument `CLAUDE.md` already makes about junctions.

**Posture: documentation only, no gate.** Nothing checks that the template was
filled in.

### G8 — high — nothing but a person ever runs the tests, and CI is foreclosed by something upstream of CI

There is no `.github/workflows/`. The five suites — 1,662 checks in the
character-creator smoke alone, plus `regression.mjs` and four app smokes — run
because a human or an agent runs them. Nothing runs them on a pull request.

**The obvious fix does not work, and this is the finding.** The suite **has
never been runnable on a bare clone**, which is what a CI runner is:

- `environment.mjs` shells out to `wrangler` and reads a **local D1**, which on
  a fresh checkout is *empty*. `docs/prompts/portability-audit-prompt.md` §3
  states a fresh checkout fails two checks for this reason.
- `DOCS-AUDIT-2.md` D1's outcome note adds a second, newer one: the
  absolute-path check resolves paths **on this machine**, so *"a fresh clone
  elsewhere fails it — every `C:\Users\natha\…` is absent there."*
- The paths are Windows paths and a runner would be Linux.

So a naive Action is red on its first run, and a red check nobody can fix
teaches everyone to ignore checks — which is precisely the failure G14 records
having already happened here once.

**Proposal, in the only order that works:**

1. **First**, split the suite's machine-dependent sections behind a flag or an
   environment probe, so a `--portable` (or equivalently gated) run is
   green on a bare Linux clone. The harness already has the machinery —
   `--section` filtering exists, `wantSection` gates the wrangler half, and a
   partial run labels itself `PARTIAL` so it cannot pass for the gate.
2. **Then**, and only then, add one workflow that runs that portable subset on
   `pull_request`, reporting only.

Step 1 is the whole cost and it is worth having on its own merits, CI or not.
**Step 2 is nearly free once step 1 exists, and worthless before it.**

**Posture: reporting only, never a gate.** No required status check, no branch
protection wired to it. Per Nate's scope decision, an Action here may go red
without stopping a merge.

**Boundary:** step 1 overlaps `PORTABILITY-AUDIT.md`'s territory. If that menu
is produced first, this finding should defer to its numbering and say so rather
than doing the work twice.

**Decline path:** the suites are in fact run before every merge today, the PR
bodies prove it by pasting the pass lines, and the marginal value of CI on a
solo repo where the agent already runs the tests is smaller than it looks. The
honest version of this finding is *"step 1 is valuable, step 2 is tidiness."*

**Taken, 2026-09-03 (PR #620). Posture held: reporting only, no required
status check, no ruleset.** Both steps shipped.

**This finding's central premise was FALSE, and the correction is the most
useful thing the work produced.** *"The suite has never been runnable on a bare
clone"* does not reproduce. Measured by cloning this repo into a scratch
directory with no `.wrangler`, no `.cache` and no `.dev.vars` and running the
flagless suite: **1662 checks, PASSED.** Clone state was never the obstacle, and
the two sources the finding leaned on were both about something else —
`portability-audit-prompt.md` §3 and the *"fresh worktree fails two checks"*
note describe `class-check --local` and phantom **drift**, not the smoke suite.
The finding took two true statements about D1 tooling and concluded something
false about the test suite.

**What actually blocked CI was one assertion, not a class of them.**
`instruction-paths.mjs` ends in `existsSync` against `C:\` paths — eleven of
them — which cannot resolve on Linux. That is the whole of step 1.

**So step 1 shipped much smaller than proposed, and by a different mechanism.**
Not a `--portable` flag and not `--section` gating: the check now **probes
`process.platform`** and skips only its final assertion off Windows. A flag was
rejected on the finding's own logic — the flagless run here is the merge gate,
and a flag is a way to opt out of it and still quote the result. The skip is
placed *after* the two anti-vacuous-pass guards, which touch no filesystem, so
Linux still proves the paths are being **found** and only declines to say
whether they exist. That preserves the defence the check's author built twice
and named in its header.

**Proved by making it fail, not by watching it pass.** Faking
`process.platform = 'linux'` and re-running the real suite shows the skip firing
(`absolute paths are not resolved on linux`) with both guards still green.

**That same run also produced twelve failures that are NOT real, and nearly
sent this in the wrong direction.** All twelve were the wrangler-backed local-D1
section. The cause was the instrument: overriding `process.platform` changes
which shell Node's own `spawnSync` selects, so every `npx wrangler` call died on
`spawnSync /bin/sh ENOENT` — a fault of the fake, absent on a real runner.
Confirmed directly rather than assumed. **The faked platform can prove the probe
and can say nothing about the wrangler half**; only a real Linux runner can, and
this PR's own workflow run is that test, read before the merge rather than
after.

**Two things added that the finding did not ask for, both defensive:**

- `.github/workflows/*.yml text eol=lf` in `.gitattributes` — kept, but **not
  for the reason it was added**, and the correction is worth more than the rule.
  It went in to stop a trailing CR reaching a bash `run:` step. Then the
  measurement that justified it turned out to be taken with a broken instrument:
  `grep -c $'\r$'` returns the **line count** for every file in this repo,
  because the `$'…'` quoting does not survive the tool, so the pattern matches
  every line. Re-measured with `tr -cd '\r' | wc -c`: git stores **LF** in the
  index for every text file here — `HEALTH-AUDIT.md`'s committed blob is **0
  CR** — the CRLF is a working-tree artifact of `core.autocrlf`, and a Linux
  runner checks out what is stored. **The fault the rule prevents could not
  occur.** It stays as a pin against a future `core.autocrlf` or attribute
  change, which is precisely what the `woff2` rule beside it already says of
  itself, and its comment now says that rather than claiming a live fault.
  **PR #619's body carries the same broken measurement** — it reports this
  file's blob as "614 CR for 614 lines" and every neighbour likewise. The
  conclusion it drew (consistent with its neighbours) was right; the number
  supporting it was noise. Left standing there as a record, corrected here.
- `regression.mjs` is deliberately **excluded** from the workflow. It boots
  `wrangler pages dev` and tears it down along a platform-specific path, making
  it the piece most likely to be red for reasons that are not about the repo.
  It is also the most valuable check for a fresh environment, so it should be
  added — **as its own finding**, once this workflow has a track record.

**Four live claims that this change falsified were corrected in the same PR**,
per the rule that anything citing a finding goes stale: `CLAUDE.md`,
`.claude/skills/ship-pr/SKILL.md`, `SETUP.md` and
`apps/character-creator/docs/operations.md` each said *no CI*. All four now say
what is true — nothing gates the merge, and the suites report on a PR. The same
phrase in the audit menus and in `docs/prompts/` was **left alone**: those are
records.

**The boundary held.** No portability work was done here beyond the single
platform probe, and `PORTABILITY-AUDIT.md` remains unwritten and unclaimed.

### G9 — medium — eleven markdown files at the root, and the canonical way to list them misses one

The root holds **eleven** `.md` files totalling roughly 700 KB, seven of which
are audit menus. The `audit-menu` skill's own listing command —

```bash
find . -name '*AUDIT*.md' -not -path './.cache/*' -not -path './node_modules/*'
```

— **cannot find `SETUP-v2-CHANGES.md`**, which is a menu by every property
except its filename: eight numbered changes under `## Changes`, with dated
outcome notes. The skill says so itself and calls the gap the argument against
globbing a convention nothing enforces.

It is right about globs, and there is still a cheaper fix available than either
an index or a glob: **make the outlier's name match the convention.**

**Proposal:** rename `SETUP-v2-CHANGES.md` to `SETUP-AUDIT.md` (or
`SETUP-V2-AUDIT.md`) with `git mv`, so the one command in the skill returns the
complete set. Update the inbound references — grep the tree *and*
`C:\Users\natha\.claude\projects\C--Users-natha-Downloads\memory\`, which no
grep of the repo reaches. Then delete the paragraph in the `audit-menu` skill
that exists solely to warn about this file, and replace it with a sentence
saying the naming convention is now load-bearing and a new menu must match it.

**Explicitly NOT proposed: an index file listing the menus.** The skill argues
at length against a maintained count of them and has been wrong every time it
tried; an `AUDITS.md` would be exactly the artefact it warns about. The rename
makes the tree answerable instead of adding a second place to be wrong.

**Posture: one rename plus the citations it invalidates.** No new file, no
check. Nothing enforces the convention afterwards either — that is accepted.

**Decline path:** audit files are records, and a rename is a change to a record.
It is a change to its *name* rather than its content, which this menu reads as
permitted, but if that reads as too much, decline — and then leave the skill's
warning paragraph exactly where it is.

### G10 — medium — 359 run-once scripts in one flat directory, ordered by filename, escalated five `z` deep

`apps/character-creator/db/` holds **359** `.sql` files totalling **4.5 MB**,
applied by a rebuild as one sorted glob. Filename order is execution order, and
the prefixes record the strain: **197** `add-`, **77** `fix-`, 18 `backfill-`,
and then **13 `zz-`, 9 `zzz-`, 14 `zzzz-` and 2 `zzzzz-`** — a sort key
escalated four times because each level ran out of room. `docs/operations.md`
documents the third escalation in a table cell, and F25 (#567, `zz- stops
claiming to sort after everything`) has already corrected the claim that `zz-`
sorts last.

**The mechanism is understood and the individual failures are closed. What is
open is that the ordering channel is the filename.** A `fix-` that must run
after an `add-` it corrects has nowhere to go but a `z`, and the next collision
needs `zzzzzz-`.

**Before proposing anything, one premise that constrains every option:** the
live ledger `data_script_runs` is **keyed on filename**, and `drift-check.mjs`
compares repo filenames against it. **A rename is therefore not free** — it
either orphans a ledger row or needs a migration that carries the old name
forward, on every environment. Any proposal that says "just renumber them"
is wrong, and this is the finding's own most likely error.

**Proposal — the cheap half only.** Do **not** renumber the existing 359. Add a
`NNN-` numeric prefix convention for **new** data scripts from a stated date,
documented in `docs/operations.md` beside the existing ordering table, so the
escalation stops growing. Leave every existing name alone: they are applied
history, their ledger rows key on them, and `docs/operations.md` explains each
tier.

**The expensive half, stated and not proposed:** a real answer moves ordering
out of the filename into a manifest the rebuild reads. That is a change to
`rebuild-local.mjs`, `drift-check.mjs`, `data_script_runs` and every doc
describing the glob — a schema-change-shaped job, and it should be its own
finding if it is ever wanted.

**Posture: convention for new files, nothing retroactive, no rename.**

### G11 — low — audit menus sit at the root or in an app directory by no stated rule

Seven menus at the root; eight under `apps/`. `BOOK-INGEST-AUDIT.md` is at the
root though it is entirely about the character creator's catalog;
`apps/character-creator/INGESTION-AUDIT.md` is app-scoped and covers adjacent
ground. `EFFICIENCY-AUDIT.md` is at the root and is about the ingestion loop.

Nothing is broken. But a reader deciding where a *new* menu goes has no rule to
follow, and the two ingestion menus are genuinely easy to confuse.

**Proposal:** one paragraph in the `audit-menu` skill stating the rule — root
for anything spanning apps or covering the repo, process or machine; the app
directory for anything scoped to one app. Do **not** move any existing file:
they are records, their paths are cited across menus, memory files and skills,
and a move would invalidate citations that no repo grep reaches.

**Posture: documentation only, zero files moved.**

### G12 — medium — `F18` names eleven different things, and the branch names inherit the ambiguity

Eleven menus number their findings with `F`:

| menu | F-headings |
|---|---|
| `apps/character-creator/UI-AUDIT.md` | 30 |
| `apps/character-creator/INGESTION-AUDIT.md` | 25 |
| `SKILL-AUDIT.md` | 25 |
| `HEALTH-AUDIT.md` | 24 |
| `BOOK-INGEST-AUDIT.md` | 21 |
| `apps/character-creator/REBUILD-AUDIT.md` | 20 |
| `apps/character-creator/CLASS-AUDIT.md` | 20 |
| `apps/pick3cut5/AUDIT.md` | 10 |
| `apps/media-vault/ISBN-AUDIT.md` | 10 |
| `EFFICIENCY-AUDIT.md` | 7 |
| `apps/character-creator/AUDIT.md` | 6 |

Counted 2026-09-03 with `grep -cE '^#{2,3} F[0-9]+'`, which by the skill's own
argument undercounts files whose items are not headings — `CLASS-AUDIT`'s nine
`S` bullets and `pick3cut5/AUDIT`'s eleven `T` paragraph leads are invisible to
it. The undercount does not weaken the finding; it widens it.

**The collision is already in the permanent record.** Across all **767**
non-merge commit subjects, **nine** are the unqualified `Take F<n>` / `File
F<n>` shape and **five** name their menu (`Take MACHINE-AUDIT M19`, `Take DOCS-AUDIT-2 D1`). Branches show the
same split: `f18-local-behind` and `f3-vessel-schema-decision` beside
`machine-audit-m21-shell-measurements`. `git log --grep='F18'` cannot tell you
which F18, and neither can the branch name after the branch is deleted.

**Proposal:** require the menu name in the commit subject and the branch name
for every finding whose prefix is not globally unique — `Take UI-AUDIT F30`,
branch `ui-audit-f30-…`. Add it to `ship-pr` as a naming rule and to
`audit-menu` beside the numbering rules. **Going forward only**; history is not
rewritten and the nine existing unqualified subjects stay as they are.

**Posture: convention, documentation only.** No hook, no check. The `audit-menu`
skill argues against mechanical readers of this exact surface, and a commit-msg
hook enforcing a prefix would be one.

**Note when taking it:** `M`, `D`, `R`, `S`, `B`, `C`, `T`, `N` and `P` are each
currently unique to one menu, so the rule bites almost entirely on `F`. Say that
in the rule, or it reads as heavier than it is.

### G13 — low — branch names come in at least three shapes

From the last 60 merges: `<menu>-<id>-<slug>`
(`docs-audit-2-d1-instruction-paths`), `<id>-<slug>` (`f18-local-behind`,
`m16-tesseract`), an abbreviated menu (`bia-f18-skillbase-on-picks`), and plain
descriptive names with no finding at all (`memory-store-junctions`,
`test-extract-smoke-modules`) — correct for work that is not a finding.

Since the remote is pruned to one branch, this costs nothing at rest. It costs
only while a branch is alive and when reading history.

**Proposal:** fold into G12 rather than taking separately — state the branch
shape as `<menu>-<id>-<slug>` for findings and a bare slug for everything else,
in the same `ship-pr` edit.

**Posture: convention only.** Filed separately so it can be declined
independently if G12 is taken narrowly.

### G14 — high — the Pages check went red for 65 consecutive merges and nobody saw it

`deploy-sweep.mjs`'s header records it: every merge commit from `d5280fe`
(2026-08-27) to the fix in #399 (2026-08-30) reported `Cloudflare Pages=failure`
on its own check-runs — *"65 consecutive, no ambiguity, no flapping - and every
merge since reports success. Nobody read it, for four days."*

**The signal exists and is reliable.** Confirmed 2026-09-03: the current
`origin/main` head carries `{"name": "Cloudflare Pages", "conclusion":
"success"}`, and PR #615's head carried the same check before merge. So Pages
posts a check-run **on pull requests as well as on `main`** — the information is
present at the moment of merging, not only afterwards.

The fix already shipped is `deploy-sweep.mjs`, a backstop run at the end of a
session, plus step 9 of `ship-pr` asking for a per-merge read. Both depend on a
person remembering, at a merge rate that has twice passed 45 in a day. That is
the same mechanism that failed for four days.

**The blocking answer is available and was declined in advance.** A required
status check on `Cloudflare Pages` in a `main` ruleset would make the failure
structurally impossible to merge past. Nate ruled out blocking checks for this
audit before it was written. Recorded here so a future reader knows it was
considered rather than missed.

**Proposal, non-blocking:** a scheduled workflow — daily, or on `push` to
`main` — that reads the check-runs of recent merge commits and, on finding a
failure, **opens a GitHub issue** (or fails its own run, producing GitHub's
standard failure notification email). This is `deploy-sweep.mjs`'s logic, moved
somewhere that runs without being remembered.

**Be honest that this is more than "a PR check".** It is the one proposal in the
menu that creates something outside a pull request, and if Issues are disabled
under G6 it needs the workflow-failure-notification form instead. **G6 and G14
interact — take them in a known order and say which in the note.**

**Decline path:** `deploy-sweep.mjs` exists, works, and is cheap to run. If the
session-end habit is holding, the marginal value here is the merge you did not
check on a day you did not finish cleanly.

### G15 — medium — one of the two deploy paths produces no signal at all

The site deploys two ways. Merging to `main` deploys Pages and posts a
check-run. `workers/pick3cut5-room` — which owns the Durable Object and the rate
limit binding — is deployed **by hand** and **produces no check-run at all**.
`wrangler.jsonc` states the order is unenforced: the Worker must be deployed
first, or the bindings resolve to nothing and party mode answers 503 while the
rest of the site looks fine.

`deploy-sweep.mjs` was extended to cover this after its first version printed
`NOTHING MISSING` while saying nothing about the Worker — so the gap is known
and half-closed.

**Proposal:** the smallest honest thing is to make the Worker's deployed version
**readable** rather than to automate its deploy. A `/api/pick3cut5/version`-style
response, or a recorded deployment id the sweep compares against
`workers/pick3cut5-room`'s HEAD, turns "was it deployed" from memory into a
question with an answer.

Automating the deploy in CI is **not** proposed: it needs a Cloudflare token in
a repo secret, and this repo's whole credential posture is that a write to
production costs a deliberate keystroke.

**Posture: make it observable, do not automate it.**

**Verify before scoping.** Read `deploy-sweep.mjs`'s Worker half first — it may
already answer this, in which case the finding shrinks to a documentation note.
This is the premise in the menu most likely to be stale.

### G16 — low — 1,267 commits, 616 PRs, zero tags

`git tag` returns nothing. Nothing in the repository names a version, a release,
or a known-good point.

For a continuously deployed site with no consumers this is defensible, and
`--first-parent` history plus the Pages deployment list answers most of what a
tag would. The gap shows up only in one question: *"what was live on the day
that bug appeared"* — answerable today by correlating merge timestamps against
Cloudflare's deployment list, which is two systems and a clock.

**Proposal:** either decline explicitly and record why in `SETUP.md`, or adopt
the lightest possible convention — an annotated tag at any point worth returning
to, created by hand, no automation and no schedule.

**Posture: low, and declining it is a perfectly good outcome.** Filed so the
absence is a decision rather than an omission.

### G17 — low — a public repo with no `LICENSE`

No `LICENSE` file. Under GitHub's terms a public repo without one is "all rights
reserved" for the parts Nate owns, with the sourcebook-derived content under
Palladium's rights regardless of what any file says.

**This is downstream of G2 and should not be taken before it.** If the repo goes
private, the finding is moot and should be closed as such. If it stays public,
the shape that fits is a split: a permissive licence (MIT) over the code, and an
explicit `NOTICE` stating that catalog content is transcribed from Palladium
Books material for personal use, unaffiliated and unendorsed, and is not covered
by that licence.

**Posture: documentation only, and blocked on G2.**

**Do not treat a licence as protection.** It clarifies intent for the code; it
does not create a right to redistribute the book content. G2 is where that
question actually lives.

---

## How to take one

Per the `audit-menu` skill: Nate names one — *"take G6"* — it becomes one PR on
its own branch, the outcome note is appended **under that finding's heading in
the same PR**, and the merge waits for a separate word. Taking a finding means
auditing it first: **every measurement above is a 2026-09-03 GitHub-side or
filesystem reading, and several are one click from being false.** Re-run the
command in the finding and lead the report with whatever it contradicts.
