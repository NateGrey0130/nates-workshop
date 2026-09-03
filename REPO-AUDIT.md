# Repository architecture audit — git, GitHub, layout and the merge path, 2026-09-03

**Status: `G8`, `G1`, `G3` and `G7` taken 2026-09-03 (PRs #620, #621, #623, #624); `G12`+`G13` taken together (PR #627); `G4` (PR #628), `G6` (PR #629) and `G14` (PR #630, fixed in #631) taken; `G16` CLOSED BY DECISION - declined and recorded (PR #632); `G2` taken via PATH B - stays public, deliberately (PR #633); `G17` taken (PR #634); `G9` and `G10` closed WITHOUT being taken (PRs #625, #626); `G5`, `G11` and `G15` RE-SCOPED 2026-09-03 (PR #635) and now takeable; they
carry `Adjusted` notes; `G18` filed 2026-09-03. The rest are OPEN.**
Read the lines under a finding's own heading for its state — this line is a
convenience and it is the kind of line that goes stale first.

**Every finding taken from this menu so far has turned up an error in its own
premises, and one of them was in a finding nobody had touched.** `G8` claimed
the suite "has never been runnable on a bare clone" — a bare clone passes
everything, and the real blocker was one `existsSync` assertion. `G1`'s
suggested verification command counts 117 squash-merged PRs as direct pushes.
And taking `G1` disproved **`G5`**, which still says merge commits are used
"exclusively"; it now carries an `Adjusted` banner.

So: **treat the reasoning in these findings as a lead, not as established
fact**, and distrust first anything cheap to check — a count, a command, or a
claim that something has never happened.

## Every remaining finding was re-verified on 2026-09-03

Prompted by the error rate above, not by a schedule. Each open finding's central
claim was re-measured against the repo and the GitHub API the same day the menu
was written. **Two were materially wrong and now carry `Adjusted` banners:**

| finding | verdict |
|---|---|
| `G11` | **WRONG** — "eight under `apps/`" is nine, and it miscounted the root with the very glob `G9` says is incomplete |
| `G15` | **WRONG** — "produces no signal at all" is false; `deploy-sweep.mjs` already reports the Worker, and most of the proposal exists |
| `G6` | claim TRUE, but it was **unverified when written** — only "enabled" had been checked, never "empty" |
| `G2` `G3` `G4` `G7` `G9` `G12` `G13` `G14` `G16` `G17` | central claim **holds** |
| `G3` `G9` `G10` `G12` | hold, with counts that have since **drifted** — see each note |

**There are two failure shapes, and naming them is the useful part.**

**One: reasoned to rather than run.** `G8`'s bare clone, `G1`'s counting
command, `G5`'s "exclusively", `G11`'s totals, `G15`'s "no signal". Every claim
that came from a command actually executed has held; the menu wrote both kinds
in the same voice, and nothing on the page told a reader which was which.
`G18` proposes the fix.

**Two: proposing something another menu had already decided.** `G9` asked to
rename `SETUP-v2-CHANGES.md`; `HEALTH-AUDIT.md` F4 had settled that on
2026-09-02 in PR #523 and chosen the opposite, with reasons. `G10` proposed
numbering the data scripts; `SKILL-AUDIT.md` F25(b) had closed that on
2026-09-02 in PR #567, and its note ends *"recorded so it is not re-proposed."*
**Re-measuring would never have caught either** — `G9`'s facts were right — and
the check is a grep for the subject across the other menus, thirty seconds,
done for neither.

**Both shapes can occur in one finding.** `G10` re-proposed a settled decision
*and* never ran the one command that would have shown its mechanism backwards:
a `NNN-` prefix sorts **first**, not last.

This section was added on 2026-09-03 when `G9` was closed, and widened when
`G10` was; the paragraph above it used to say the failure had *one* shape.

**`G6` is the subtler case and worth reading twice.** It was right, and it was
right by luck: the check performed confirmed the tabs were *enabled*, and the
finding asserted they were *empty*. Verifying it required excluding pull
requests from the issues endpoint, which returns 100 rows for a repo with zero
issues. **A coincidence is not a check** — the same lesson `audit-menu` records
about `INGESTION-AUDIT` F14.

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

**Taken, 2026-09-03 (PR #621). Posture held: the bypass is gone and nothing is
gated.** Ruleset `22209348`, *"main: require a pull request"*, `enforcement:
active`, one rule, **no bypass actors**.

Verified by asking GitHub which rules evaluate for the branch —
`gh api repos/…/rules/branches/main` returns exactly `pull_request`, with
`required_approving_review_count: 0`, no `required_status_checks` rule at all,
`required_review_thread_resolution: false`, and no linear-history, signed-commit,
deletion or force-push rule. Legacy branch protection is still absent (`404`),
so this ruleset is the only thing evaluating.

**GitHub added a gate that was not asked for, and it had to be switched off
explicitly.** The created ruleset came back carrying
`require_extra_approval_for_unattributed_changes: true` — a server-side default
that can demand an approval even where `required_approving_review_count` is `0`.
Under this finding's posture that is a defect, so it was set to `false` and
re-read. **Worth knowing for any future ruleset here: the parameters you send
are not the parameters you get.**

**The decline path resolved on measurement, and the finding's own suggested
command would have got it wrong.** `git log --first-parent --no-merges main`
reports **138** commits — but **117 of them carry a `(#N)` suffix and are
squash-merged pull requests**, which reach `main` without a merge *commit* while
still going through a PR. The real count of direct pushes is **21**, every one
between **2026-04-18 and 2026-04-26** — the repo's first nine days — and **none
in the four months and roughly 600 pull requests since**. The escape hatch was
not in use, so no bypass actor was added.

**It is still reversible in seconds.** An admin can disable or delete the
ruleset from the repository's Rules settings, which is now the escape hatch the
direct push used to be. That is why "no bypass actors" is not a lock-out.

**One live instruction corrected in the same PR:** `ship-pr` step 1 said *"Never
commit to `main`"* as advice; it now says the push is refused server-side, while
keeping the advice, because the rule fires at `git push` and a commit already
made on `main` is still yours to unpick.

**This PR was its own acceptance test** — opened, checked and merged under the
new rule.

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

**Taken via path B, 2026-09-03 (PR #633). The repo stays public, deliberately,
and this is the record of that.**

**Path A was attempted first and was refused by the harness**, not declined on
its merits: `gh repo edit --visibility private` was blocked by the auto-mode
classifier. The pre-flight this finding demanded had already been done —
Cloudflare Pages connects as `source_type: github`, the GitHub App integration,
which keeps building on a private repo — so the block was a tooling boundary
rather than a finding. **Nate then chose public on the merits**, which is the
decision this note records; the block is incidental and should not be read as
the reason.

**The measurement that fed the choice, and it cuts the other way from the
recommendation given:** `stars=0 watchers=0 forks=0 network=0`. Nobody is
consuming the public repo. That was offered as an argument for going private —
publicity that is not being used against an exposure that cannot be undone —
and it was heard and overruled. **Recorded because a decision made against a
stated argument is the kind that gets re-litigated by whoever finds the argument
later.**

**What shipped here is the notice only.** The root README gains *A note on the
game data*: three sentences saying the catalog is transcribed from Palladium
Books sourcebooks for personal use at one table, that the project is
unaffiliated and unendorsed, and that the rules text belongs to them.

**It is a disclaimer, not a licence, and it changes nothing legally** — this
finding says so itself: *"This does not manufacture a right that does not
exist."* Its whole function is that a reader arriving at a public repo full of
verbatim spell descriptions finds an acknowledgement instead of silence.

**The `LICENSE` half is `G17` and is deliberately not here**, so the README does
not link a file that will not exist until that PR merges. `G17` adds the licence
and the sentence saying it does **not** cover the catalog content — a bare MIT
file alone would be worse than none, because it would appear to license the
sourcebook text along with the JavaScript.

### G3 — medium — a public repo with 693 files and no root `README.md`

**Re-verified 2026-09-03: holds.** Still no `README.md`, `LICENSE`,
`CONTRIBUTING.md` or `SECURITY.md`. The tracked-file count has drifted 693 →
**696**; the claim does not depend on it.

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

**Taken, 2026-09-03 (PR #623). Posture held: documentation only, one screen, and
it restates nothing.**

**The finding's own instruction — "the four apps with one line and a link each" —
was not followed, deliberately.** Those one-liners already exist in
`apps/manifest.json`, which the landing page reads at runtime, so writing them
into a README would have created a second copy of live data and a fifth place to
go stale. The table names the apps and links their directories; the descriptions
are pointed at, with a sentence saying the manifest is the source and the table
is deliberately not repeating it. **This is the one place a finding said "copy
this" and copying it was the wrong move.**

**No count appears in it.** The draft said *"the five test suites"* and that was
cut — a sixth app would falsify it, and the finding itself warns that every
count a README quotes is either pinned elsewhere or free to drift.

**One paragraph was written and then removed, because it belongs to `G2`.** A
note that the catalog is transcribed from Palladium Books material, unaffiliated
and unendorsed, is exactly what `G2`'s path B calls for *"in the root README
(G3)"* — but `G2` is undecided and unowned, and adding the note here would have
implemented half of it without the decision. It is a two-minute edit whenever
`G2` resolves; it is moot if the repo goes private.

**Verified rather than assumed:** every one of the nine links in the file
resolves, checked with a loop over the extracted paths. The smoke suite did not
gain or lose a check — 1665 before and after — so the `Documentation claims`
surface was not extended, which the caution above allowed for either way.

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

**Taken, 2026-09-03 (PR #628).** `delete_branch_on_merge` is now `true`.

**The decline path was measured rather than weighed, and it did not survive.**
Every pull request in the repo was checked for a base other than `main`:

| | |
|---|---|
| stacked PRs, ever | **three** — #89, #90, #261 |
| when | **2026-08-18 to 2026-08-24**, none since |
| how they ended | **two of the three closed unmerged**; only #89 merged |

So the pattern the decline path protects was tried briefly, killed two of its
own three PRs — the death-on-base-deletion this finding describes — and was
abandoned ten days before the finding was written. Nothing was being protected.

**What the setting actually buys is narrower than "tidiness", and it is worth
saying because the remote was already clean.** `ship-pr`'s hand step was being
performed reliably across 616 PRs, so this changes nothing about the path an
agent follows. It covers **the merge that does not go through `ship-pr`** — the
web UI's merge button, which passes no flag and left a branch behind every time.

**`ship-pr` keeps `--delete-branch`.** The setting deletes the *remote* branch
only; the local one is still the flag's job, and dropping it would have traded a
guarantee for a mess in the working copy. The skill now says which half each
mechanism owns.

### G5 — low — three merge methods are enabled and only one is used

`allow_merge_commit`, `allow_squash_merge` and `allow_rebase_merge` are all
`true`. History shows **501 merge commits** against **1,267 commits** — the
merge-commit path, exclusively, in the shape `Merge pull request #N from
NateGrey0130/<branch>` over one or two subject commits.

That history shape is genuinely useful here: `deploy-sweep.mjs` walks merge
commits on `main` as its unit of work, and `--first-parent` gives a clean
per-PR ledger. Squashing would flatten it; rebasing would remove the merge
commits the script counts.

**Adjusted 2026-09-03, while taking G1 — this finding's premise is wrong.**
"The merge-commit path, exclusively" is false. `git log --first-parent
--no-merges main` filtered on a `(#N)` suffix finds **117 squash-merged pull
requests** on `main`, alongside the 501 merge commits. The squash button has not
merely been available, it has been **used**, on more than a sixth of this
repo's PRs.

That makes this finding *more* worth taking rather than less — a script keying
on merge commits is already blind to 117 of them — but it also means the
proposal below is **not** the no-op it claims. Disabling squash would change
which button is available for a path the repo has actually used, and anything
reasoning over `main`'s history has to cope with both shapes regardless, since
the existing 117 do not go away. **Re-scope before taking it**, and check
`deploy-sweep.mjs` against a squash-merged commit specifically.

The original measurement and proposal are left standing below.

**Proposal:** disable squash and rebase merging, leaving merge commits as the
only button. Nothing about existing history changes.

**Posture: settings only.** This removes a way to accidentally produce a history
shape a script depends on not seeing.

**Verify one premise before taking it.** Confirm `deploy-sweep.mjs` genuinely
keys on merge commits rather than merely defaulting to them — the header says
"the last 20 merge commits", which reads as a window rather than a contract.

**RE-SCOPED 2026-09-03 — this is not a tidiness finding. Both deploy monitors
are blind to a merge shape the repo has used 117 times, most recently three days
ago, and the button still offers it.** The premise check above was run, and it
turned this into a different finding.

| measured 2026-09-03 | |
|---|---|
| `scripts/deploy-sweep.mjs:74` | `git log --merges` — **merge commits only** |
| `.github/workflows/deploy-alarm.yml:75` | `git log --merges` — **the same** |
| squash merges on `main` | **117**, spanning 2026-08-16 → **2026-08-31** |
| squash button today | **still enabled** |

**The signal exists on those commits and nothing reads it.** Three squash-merged
commits from 2026-08-31 were checked directly and all carry
`Cloudflare Pages completed/success` — and `git log --merges` returns **zero** of
them. A squash-merged deploy *failure* would be reported by neither tool: the
four-day outage's failure mode, reached by a different route.

**`G14`'s alarm inherited the defect on the day it shipped**, from the script it
was modelled on. This is not dormant history; it is a live blind spot in code
merged an hour before this re-scope was written.

**Re-scoped proposal, two independent halves.**

- **(a) The substantive fix: walk `--first-parent`, not `--merges`**, in both
  `deploy-sweep.mjs` and `deploy-alarm.yml`. Every first-parent commit on `main`
  is a state the branch was in, and therefore a deploy that either happened or
  did not — which is the question both tools ask. One pass covers merge commits,
  squash merges and direct pushes, and it needs no repository setting to be
  correct.
- **(b) Optional, and no longer the point: disable squash and rebase.** It
  narrows what can arrive, but it does **not** fix either tool for the 117
  commits already on `main`, and under `G1`'s ruleset every merge is a PR merge
  whose dropdown still offers squash. Take (a) whether or not (b) is taken;
  **taking (b) alone leaves the bug.**

**Posture: fix the readers; treat the button as a separate call.** The original
proposal is left standing above, and its *"nothing about existing history
changes"* is now visibly the error — what needed changing was never the button.

**Acceptance test:** after (a), both tools must report the three 2026-08-31
squash commits. Today they return nothing for them, which is the check that
proves the fix rather than assuming it.

### G6 — medium — Issues, Projects and Wiki are all enabled and all empty

**Verified 2026-09-03, and it had NOT been when this was written.** The original
check confirmed the three tabs were *enabled*; the finding then asserted they
were *empty*, which is a different claim. Now measured: **0 issues ever**
(`search/issues?q=repo:…+is:issue` → `total_count: 0`), **no wiki** — cloning
`…nates-workshop.wiki.git` returns *"Repository not found"*, so one was never
created — and no classic projects.

**The trap that makes this worth stating:** the obvious command,
`gh api repos/…/issues?state=all`, returns **100** rows for a repo with zero
issues, because that endpoint includes pull requests. Filter on
`select(.pull_request == null)`. The finding was right; the reasoning behind it
had not been done.

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

**Taken, 2026-09-03 (PR #629). All three disabled** — `has_issues`,
`has_projects` and `has_wiki` are now `false`.

**Issues went off rather than staying with a template**, which was the fork.
The reasoning, recorded so it is not re-litigated: the menus are the tracker,
there is no second contributor, and an enabled Issues tab is a place someone can
file into that nobody reads. A contact link would have been a second thing to
maintain pointing at a queue that already has a home. **If a contact channel is
ever wanted, re-enabling Issues with
`.github/ISSUE_TEMPLATE/config.yml` is a two-minute change** — nothing here
forecloses it.

**Nothing was lost, verified before disabling rather than assumed:** `0` issues
ever (`search/issues?q=repo:…+is:issue` → `total_count: 0`), no wiki — cloning
`…nates-workshop.wiki.git` returned *"Repository not found"*, so one was never
created — and no classic projects. Disabling a tab hides it; it does not delete
content, and there was none.

**This finding's claim was true and had not been checked when it was written** —
only "enabled" had been measured, never "empty". See the verification pass in
this menu's header, and the trap it turns on: `gh api repos/…/issues?state=all`
returns **100** rows for a repo with zero issues, because that endpoint includes
pull requests.

**One consequence for `G14`**, which is why these were sequenced together: with
Issues off, `G14`'s deploy alarm **cannot file an issue** and has to take the
workflow-failure form instead. That is now the only shape available to it.

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

**Taken, 2026-09-03 (PR #624). Posture held: a prompt, no gate, nothing checks
it.**

Six headings — the gap, what was measured, posture, nothing regresses, the
decline path, verification — each carrying an HTML comment saying what belongs
under it, and an opening comment stating that `ship-pr` owns the loop and
`audit-menu` owns what taking a finding means. **It does not restate either**,
which was the finding's explicit constraint.

**The comments carry the traps rather than the steps**, which is what makes it a
prompt instead of a second copy: `--local` accumulates, the merge gate is the
flagless run because a `--section` run labels itself `PARTIAL`, D1 files are
already applied by review time, and an absence claim has to be proven by reading.
Each is one line, and each is a failure this repo has actually had.

**One line was added that the finding did not ask for**, under *what was
measured*: *"If a claim here was reasoned to rather than run, say so in those
words."* That is `G18`'s proposal, and it is here only because this template was
being written anyway and the sentence costs nothing. **It does not take `G18`** —
that finding asks for the convention across the menus, and a hint in a compose
box is not that.

**Its reach is narrower than it looks, and that is fine.** `--body-file`
replaces the template entirely, which is how every PR in this repo is opened,
so this changes nothing about the agent path. It is for a PR opened in the
browser, or by `gh pr create` with no body — the case that has never happened
here and would be the first one written by someone who had not read `ship-pr`.
**Verified on this PR:** opened with `--body-file`, and the resulting body
contains none of the template's markers.

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

**The first Linux run FAILED, and reading it before the merge is the whole
reason this was sequenced that way.** `1 of 1662` — and not a platform check.
The failure was a real assertion, `toggling the mode is a class flip, not a
re-render`, and behind it were **three** function-body slices in
`test/checks/rendered-ui.mjs` searching for a **hardcoded CRLF** (`'\r\n}'`, or
`String.fromCharCode(13, 10)`). On an LF checkout every one of those `indexOf`
calls returns `-1`, and `slice(start, -1)` does not fail — it silently returns
the rest of the file.

**One of the three was failing loudly and one was passing vacuously**, which is
why this became a shared helper rather than three small edits:

| slice | on LF |
|---|---|
| `togglePlay` | **FAILED** — the rest of the file contains `render()`, which the check forbids |
| `paintPool` | **PASSED while testing almost nothing.** Its body became the rest of the file, so the `src.replace(painter, '')` under it deleted nearly everything and *"no pool write bypasses it"* then searched a handful of lines |
| `poolCard` | passed by luck — the ids it looks for are present either way |

So the fix is one `functionBody()` helper, tolerant of both line endings, which
**returns null rather than guessing**, plus a named guard per caller asserting
the body was located. A missing delimiter is now a named failure instead of
either a confusing one or a silent pass. **1662 → 1665 checks.**

**Reproduced locally without a Linux box, and the rig is reusable.** In a
throwaway clone: `git config core.autocrlf false`, then `git rm --cached -r .`
and `git reset --hard` to re-materialise the working tree from the blobs. That
gives a true LF tree on this machine, and it reproduced the CI failure exactly —
same check, same `1 of 1662`. After the fix: **1665 passed on the LF tree and
1665 on this repo's CRLF tree.** Both platforms, same number.

**That is the second broken-instrument lesson of this finding, pointing the
other way.** The faked `process.platform` proved a probe and lied about twelve
checks; a real LF checkout cost three shell commands and found a defect nothing
else had. When the question is *"does this behave differently over there"*,
change the input, not the platform report.

**The boundary held.** No portability work was done here beyond the single
platform probe and the line-ending fix the run forced.
`PORTABILITY-AUDIT.md` remains unwritten and unclaimed.

### G9 — medium — eleven markdown files at the root, and the canonical way to list them misses one

**Re-verified 2026-09-03: the core claim holds and the count has drifted — by
this menu's own doing.** The glob still cannot see `SETUP-v2-CHANGES.md`
(`find … -name '*AUDIT*.md' | grep -c 'SETUP-v2'` → **0**), which is the whole
finding. The root is now **twelve** `.md` files rather than eleven, because
`REPO-AUDIT.md` is one of them.

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

**Closed without being taken, 2026-09-03 (PR #625). This had already been
decided, one day earlier, the other way.**

`HEALTH-AUDIT.md` F4 was **taken 2026-09-02 in PR #523** and considered this
exact choice — *"either rename `SETUP-v2-CHANGES.md` to match the `*AUDIT*`
convention or note in the skill that one menu sits outside it."* It chose
**naming rather than renaming**, for two reasons this finding never weighed:

> renaming it to fit the `*AUDIT*` glob would break the PR #503 record that
> refers to it by name, in order to make a glob correct that this same file
> argues nobody should rely on.

**The second reason is the stronger one, and this finding half-made the same
argument itself** — it declined to propose an index precisely because the
`audit-menu` skill argues against relying on a mechanical list. Renaming the
file to satisfy the glob is that same reliance, arriving from the other
direction.

**So the premise was also incomplete.** This finding says the skill's listing
command "misses one" and treats that as an unaddressed gap. It is addressed, by
a different mechanism, on purpose: the skill names `SETUP-v2-CHANGES.md` **three
times** — in the paragraph above the command, in the shape table, and in the
paragraph below the command that says outright the command does not return it
and that this is not a bug in the command. What remains is a glob with a
documented blind spot, which is the state F4 deliberately chose.

**Nothing was renamed.** The ~24 repo references and 2 memory files stay as they
are, and the PR #503 record keeps meaning what it says.

**The thing worth carrying forward is the failure shape**, which is not the one
`G18` describes. This finding was not wrong about a fact it failed to measure —
the glob really does miss the file, verified twice. It proposed **reversing a
shipped decision without checking whether one existed**. No amount of
re-measuring would have caught that; the check is a grep for the filename across
the other menus, which takes thirty seconds and was not done.

### G10 — medium — 359 run-once scripts in one flat directory, ordered by filename, escalated five `z` deep

**Re-verified 2026-09-03: holds, with drift from another session.** Now **360**
`.sql` files and **78** `fix-` (was 359 and 77) — one `fix-` script landed while
this menu was being written. The `z` tiers are unchanged and confirmed at
**13 / 9 / 14 / 2 = 38** files. The ledger constraint that shapes the proposal —
`data_script_runs` keyed on filename — is unchanged.

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

**Closed without being taken, 2026-09-03 (PR #626). Two independent reasons,
either of which is sufficient.**

**One — the design question was closed by decision the day before.**
`SKILL-AUDIT.md` F25 part (b) asked whether the `z` escalation is a convention
worth keeping, and listed the alternatives: *"a `zzzz-`-and-done rule, or
**numbering by intended run order**, or making the rebuild order explicit rather
than lexical."* Its outcome note reads:

> Part (b) **CLOSED by decision, not deferred** — Nate chose documentation only,
> leaving the four tiers as they are. **Recorded so it is not re-proposed**: the
> escalation is untidy and has never actually broken anything, and every
> alternative is a migration of applied one-shot scripts.

This finding re-proposed it, one day later, in the teeth of a note whose last
clause exists to prevent exactly that. Part of the closure reasoning does not
bite here — a new-files-only convention is not a migration of applied scripts —
but the decision covered the design question, not one mechanism for it.

**Two — and this one kills it regardless: `NNN-` sorts the wrong way.**
Measured 2026-09-03 by adding two synthetic names to the real listing and
sorting it:

| name | position of 362 |
|---|---|
| `001-a-new-script.sql` | **1** |
| `500-a-new-script.sql` | **2** |
| `add-apok-class.sql` | 3 |

Digits precede letters in ASCII, so **every** numerically prefixed file sorts
ahead of **all 360** existing scripts, whatever number it carries. A new data
script almost always has to run *after* what is already there. The proposal
would have put new work first and called it ordering — producing the silent
undo-on-rebuild failure that the `z` tiers, `repo-vs-live.mjs` and F25 all exist
to prevent.

**This finding is the first here to exhibit both failure shapes at once.** It
re-proposed a settled decision without checking (shape two, as `G9` did), *and*
its mechanism was reasoned to rather than run (shape one) — the sort order was
never tested, and testing it takes one command.

**Nothing changed in the repo.** The four `z` tiers stand exactly as F25(b)
decided. `docs/operations.md` keeps its ordering table, and the durable
instruction remains the one F25(a) shipped: run the `sort` one-liner, read where
your name lands, and **do not reason from the convention**.

### G11 — low — audit menus sit at the root or in an app directory by no stated rule

**Adjusted 2026-09-03 — both counts in the first sentence are wrong, and the
way they are wrong is the joke.** There are **nine** menus under `apps/`, not
eight (`find apps -name '*AUDIT*.md'`). And the root count was taken with the
`*AUDIT*.md` glob — **the exact incomplete instrument `G9`, two findings above,
exists to warn about** — so it missed `SETUP-v2-CHANGES.md`, making the root
figure 8 at the time of writing rather than 7. It is 9 now, because this menu
added a file to the root.

The finding's substance is untouched: there is still no stated rule for where a
menu goes, and the two ingestion menus are still easy to confuse. Only the
arithmetic was wrong. The original sentence stands below.

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

**RE-SCOPED 2026-09-03 — the substance survives, the arithmetic is replaced, and
the rule must be written so it does not need the arithmetic.**

Correct figures, from the tree rather than from a glob:

| | |
|---|---|
| under `apps/` | **nine** — six in `character-creator`, two in `media-vault`, one in `pick3cut5` |
| at the root | **nine** — eight matching `*AUDIT*.md`, plus `SETUP-v2-CHANGES.md` |

The original said seven and eight. Both were wrong, and the root figure was
wrong **because it was taken with the `*AUDIT*.md` glob that `G9` exists to warn
about** — the same instrument, two findings apart.

**That is the re-scope, not a correction.** A placement rule stated as *"there
are nine and nine"* is a rule that needs re-counting every time a menu is added,
and this finding has already demonstrated that the count will be taken with the
wrong tool. **The rule must be countless.**

**Re-scoped proposal.** One paragraph in the `audit-menu` skill, beside the
placement question it already implies, saying:

- **root** — anything spanning apps, or covering the repo, the process, the
  machine or the instruction layer;
- **the app directory** — anything scoped to exactly one app;
- and that the decision is made by **what the menu is about**, not by where
  similar-sounding files already sit. `BOOK-INGEST-AUDIT.md` sits at the root
  while being about the character creator's catalog, and is the standing
  counter-example: it is not moved, and the rule does not pretend it fits.

**No counts in the paragraph. No files moved.** Every existing path is cited
from other menus, from skills and from the memory store, and a move would break
citations that no repo grep reaches — that part of the original stands unchanged.

**Posture: documentation only, zero files moved, no number that can go stale.**

### G12 — medium — `F18` names eleven different things, and the branch names inherit the ambiguity

**Re-verified 2026-09-03: holds.** Still **eleven** menus using `F`. The
subject counts have moved with this session's own commits — unqualified **9**
(unchanged), qualified **5 → 8**, over **772** non-merge subjects rather than
767. The collision is unaffected.

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

**Taken with `G13`, 2026-09-03 (PR #627). Posture held: convention,
documentation only, no hook and no check, going forward only.**

**The caution directly above is wrong, and the rule is heavier than it says.**
Censused 2026-09-03 by walking every menu's own headings: **`D` is used by three
menus** — `DOCS-AUDIT`, `DOCS-AUDIT-2` and `apps/character-creator/AUDIT` — and
**`N` by two**, `SKILL-AUDIT` and `REDESIGN-AUDIT`. Three prefixes collide, not
one. The caution was reasoned from the shape table in the `audit-menu` skill
rather than from the tree, which is failure shape one again, in a paragraph
warning the reader not to overstate the finding.

`S`, `T` and `P` are absent from that census because they are **not headings** —
`CLASS-AUDIT`'s `S` items are bullets, `pick3cut5/AUDIT`'s `T` items are bold
paragraph leads — so the real figure is a floor, not a total. The skill's own
heading table says so, and the census inherits the blind spot it warns about.

**Shipped in two places, neither of them a new document.** `audit-menu` gains
*Which is why a finding reference names its menu*, placed deliberately against
the existing *"grep the whole tree for its number"* rule — **that grep is the
tool this finding exists to un-break**, and the two paragraphs now sit together.
`ship-pr` step 1 gains the branch-and-subject form, which is `G13`.

**One boundary the rule states explicitly:** inside its own file a bare number
stays correct — `G12` referring to `G9` needs no prefix, and adding one there is
noise. The rule binds only where a number is written **outside** its own menu:
commit subjects, branch names, and cross-references from another menu, a skill
or a memory file.

**History is not rewritten.** The nine unqualified subjects already in `git log`
stand.

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

**Taken with `G12`, 2026-09-03 (PR #627), exactly as this finding asked — folded
into the same `ship-pr` edit rather than taken separately.**

The shape shipped as `<menu>-<id>-<slug>` for a finding and a plain slug for
everything else, which preserves the existing `short-kebab-description` line
above it rather than replacing it: **most branches here are not findings**, and
`memory-store-junctions` or `test-extract-smoke-modules` were never wrong.

**This PR's own branch was renamed before pushing** to obey the rule it
introduces — `repo-audit-g12-g13-qualify-refs`, not the
`g12-g13-qualify-finding-refs` it was created as. Worth recording because the
first branch created under the new convention broke it, which is the same
lesson `SKILL-AUDIT` keeps filing: **a rule written today does not fire
tomorrow by itself.**

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

**Taken, 2026-09-03 (PR #630).** `.github/workflows/deploy-alarm.yml` — a daily
cron that walks the last 26 hours of merges on `main`, reads each one's
`Cloudflare Pages` check-run, and **fails its own run** when any did not deploy.

**The form was forced by `G6`.** With Issues disabled there is no issue to file,
so the failed run *is* the alarm, reaching you through GitHub's Actions failure
notification. That makes it depend on notifications being on for this repo —
stated in the workflow's header rather than assumed.

**It moves an exit code, which `deploy-sweep.mjs` deliberately does not**, and
the divergence is the interesting part. That script says outright: *"Report
only. This never moves the exit code"* — because a deploy that failed needs a
person rather than a non-zero, and a script failing on four-day-old history
would fail every run until someone rewrote the past.

That reasoning is about **a script a person runs.** Here the exit code **is the
notification channel**: a green run nobody looks at is precisely the thing that
already went wrong. **The 26-hour window is what makes it safe** — an old
failure ages out instead of alarming forever, so this cannot decay into the
permanent red tick that trained everyone to ignore check-runs in the first
place. 26 rather than 24 because the schedule drifts and a gap between windows
would let a failure through unseen.

**Proved in both directions before shipping, not after.**

| window | result |
|---|---|
| last 26 hours (67 merges) | every one `ok`, **exit 0** |
| 2026-08-28, the outage | **8 of 8 `FAILED`**, exit 1 — the alarm fires |

The second row is the one that matters: a check that has only ever passed proves
nothing.

**Three things it deliberately does not do.** It has **no `pull_request`
trigger** — at push time Pages has not finished building, so a fresh merge is
legitimately pending and would alarm falsely. It is **not a required status
check**, so it cannot block a merge or a deploy; `G1`'s ruleset requires a PR
and nothing else. And it **does not answer for the Worker**, because
`workers/pick3cut5-room` produces no check-run and reaching it needs Cloudflare
credentials that CI is deliberately not given (`G8`). `deploy-sweep.mjs` remains
the only thing covering that half.

**A merge carrying no check-run at all counts as a failure**, not a pass —
`deploy-sweep.mjs`'s header records that this *"looks exactly like a quiet
healthy merge and is not one."*

**Its first real run failed, and the alarm was wrong rather than the deploy
(PR #631).** Dispatched immediately after merging, it reported `NO RUN` for
`1ce6ea92` — **its own merge commit** — and exited 1. That commit had deployed
fine; read minutes later it gives
`Cloudflare Pages status=completed conclusion=success`.

**The bug: `conclusion` is `null` while a run is in flight, and the jq collapsed
null into `MISSING`.** The alarm could not tell *still building* from *never
ran*, which need opposite answers, so every merge checked shortly after landing
would have alarmed.

**This is the failure the workflow's own header warns about, arriving on its
first run** — a false red is how a check trains everyone to ignore it, which is
precisely how 65 real ones went unread. Two fixes:

- **Read `status` as well as `conclusion`.** `completed/success` passes,
  `completed/<anything else>` fails, no check-run at all is `MISSING`, and
  `queued/` or `in_progress/` past the grace period prints `PENDING` **without
  failing** — a build wedged for half an hour is worth seeing, and #565 was
  exactly that.
- **A 30-minute grace period.** A merge younger than that is legitimately still
  deploying and is skipped as `young`.

**Re-proved in both directions after the fix**, because verifying a repair only
on the happy path is how the first version shipped:

| window | result |
|---|---|
| last 26 hours | five recent merges skipped as `young`, older `ok` — **exit 0** |
| 2026-08-28, the outage | **4 of 4 `FAILED`** — **exit 1**, still fires |

### G15 — medium — one of the two deploy paths produces no signal at all

**Adjusted 2026-09-03 — the heading is false, and this finding predicted its own
error.** Its last line said this was "the premise in the menu most likely to be
stale" and told a taker to read `deploy-sweep.mjs`'s Worker half first. Done,
and the warning was right.

**There is a signal.** `deploy-sweep.mjs` shells out to `wrangler deployments
list` for `workers/pick3cut5-room`, takes the active deployment, and compares
its timestamp against the newest commit touching that directory on
`origin/main`. Run twice on 2026-09-03, it printed:

```
workers/pick3cut5-room - deployed by hand, so no check-run exists for it
  up to date - 7ed9f916 deployed 2026-09-02T13:01:56.478Z
  newest commit d5de69f 2026-09-02T12:03:32.000Z
```

So "produces **no signal at all**" is wrong — what is true is the narrower
"produces no **check-run**", which the body already said. And the proposal's
second half — *"a recorded deployment id the sweep compares against
`workers/pick3cut5-room`'s HEAD"* — **is substantially what already exists**,
except keyed on timestamps rather than on an id.

**What is genuinely left is smaller and different in kind**, and
`deploy-sweep.mjs`'s own header states it: *a timestamp cannot tell you whether
the change mattered* — a `$schema` edit fires it as loudly as a rewrite of
`room.js`. So the residual gap is that nothing identifies **which build** is
live, only that something newer exists in git. A version string the Worker
serves would close that; the timestamp comparison cannot.

**Re-scope to that before taking it**, and drop the half of the proposal that is
already built. The original text stands below.

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

**RE-SCOPED 2026-09-03. The finding shrank, as its own caution predicted, and
what is left is one specific question the existing tool cannot answer.**

**Drop entirely:** *"produces no signal at all"*, and the half of the proposal
asking for a deployment id the sweep compares. Both are already built —
`deploy-sweep.mjs` runs `wrangler deployments list`, takes the active
deployment, and compares its timestamp against the newest commit touching
`workers/pick3cut5-room`.

**What remains, in the sweep's own words:** *"A timestamp cannot tell you whether
the change mattered. A `$schema` line fires it as loudly as a rewrite of
`room.js`."* So the tool answers *"something newer exists in git"* and cannot
answer **"which build is actually live"**. Those are different questions, and
only the second one settles whether party mode is running the code you think it
is.

**Re-scoped proposal: the Worker states its own version, and the sweep reads it
back.**

- The Worker serves its commit sha — an existing route, or a trivial
  `/api/pick3cut5/version`. It is deployed by hand with `wrangler`, so the sha
  can be injected at deploy time (`--var` or equivalent); no build step exists
  or is wanted.
- `deploy-sweep.mjs` fetches it and compares against `git rev-parse HEAD` for
  `workers/pick3cut5-room`. **Equal is the answer the timestamp cannot give.**
- The timestamp comparison **stays** as the fallback for when the route cannot
  be reached at all.

**Posture unchanged and worth restating: make it observable, do not automate the
deploy.** No Cloudflare credentials in CI (`G8`), and the deploy stays the
deliberate keystroke it is.

**Note for whoever takes it:** the route must be reachable without an Access
session, or the sweep cannot read it — `pick3cut5` already has bypass paths, and
`apps/pick3cut5/test/smoke.mjs --remote` is the check that they still work. A
version route that 302s to the login wall answers nothing.

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

**Closed by decision, 2026-09-03 (PR #632) — declined, and recorded.** The
finding offered two outcomes and the decline was chosen, which is why this says
*closed by decision* rather than *closed without being taken*: the work it asked
for was done, and that work was writing down a no.

`SETUP.md` → *How deploys work* gains **"There are no tags, and that is a
decision"**, so the absence is not read later as an oversight and "fixed". The
reasoning recorded there: the site is continuously deployed with no consumers
pinning a version, and the one question a tag would answer — *what was live
when* — already has two answers, `git log --first-parent main` for the order and
Cloudflare's deployment list for the times. **A tag convention nobody maintains
is worse than none**, because it looks authoritative while going stale, which is
the failure this repo keeps filing findings about.

The escape hatch is recorded too: if it ever changes, an annotated tag by hand
at a point worth returning to. No automation, no schedule, no `v1.0.0` ladder.

**Still zero tags** — `git tag` re-checked the same day, returns nothing.

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

**Taken, 2026-09-03 (PR #634), unblocked by `G2` choosing to stay public.**
`LICENSE` (MIT, © 2026 Nathan Rapert) and `NOTICE`.

**Two files rather than one, and the reason is the whole care in this finding.**
A bare MIT `LICENSE` would have been **worse than none**: it would read as
licensing the transcribed sourcebook text along with the JavaScript, which is
not mine to license and not what is meant. But appending a scope note to the MIT
text makes the file no longer MIT — GitHub's detector stops recognising it, and
more importantly a modified licence is a licence a reader has to parse rather
than recognise.

So `LICENSE` is **verbatim MIT**, unambiguous about the code, and `NOTICE`
carries the scope: what the licence covers, and that the catalog — classes,
skills, spells, psionic powers, gear and the descriptive text stored with them —
is Palladium Books' material, not licensed here and not mine to license.
`NOTICE` says why it exists as a separate file, so nobody later "tidies" it by
folding it into `LICENSE`.

The README's *A note on the game data*, added by `G2`, gains one sentence
pointing at both.

**The copyright holder is a real name, and that was a deliberate choice** rather
than a default: the repo previously showed only the `NateGrey0130` handle, and
naming a person in a licence on a public repo publishes something the repo did
not previously carry. Asked and answered rather than assumed.

**This does not make the transcription lawful, and the finding already said
so.** A licence clarifies intent for the code; it creates no right to the book
content, and `NOTICE` states that outright rather than implying a permission by
silence.

### G18 — medium — a finding does not say whether its central claim was measured or reasoned to

**Filed 2026-09-03, out of this menu's own error rate rather than from a survey
of anything else.** Five claims here have been wrong: `G8`'s bare clone, `G1`'s
counting command, `G5`'s "exclusively", `G11`'s totals, `G15`'s "no signal at
all".

**They have one shape.** Every one was **reasoned to rather than run**. Every
claim that came from a command actually executed has survived re-measurement —
including the ones that sound most fragile, like `404 Branch not protected` and
`eleven menus number with F`. The problem is not carelessness about facts; it is
that a finding presents *"I ran this and it printed that"* and *"this follows
from those two things"* in the same voice, and a reader — including the person
who wrote it a week later — cannot tell which is which.

The consequences are not symmetrical. A wrong measurement is usually caught the
moment someone re-runs the command. **A wrong inference gets implemented**,
because it reads as settled and there is nothing to re-run. `G8` would have sent
a taker into portability work that was not needed; `G5` still proposes disabling
a merge button on the grounds that it is unused, when it has been used 117
times.

**Proposal:** every finding names its evidence for its central claim, in one of
two forms — the **command and the date**, or the words *inferred*, *reported by*
or *not measured*. One line. Where a proposal tells a taker to run a command, it
says whether the author ran it: `G1`'s did not, and it was wrong.

`audit-menu` already requires *"every number carries its date and its source"*.
**This is that rule extended from numbers to claims**, which is where it was
actually needed — `G8`'s bare-clone sentence contains no number at all and was
the most expensive error in the menu.

**Posture: convention for new findings, documentation only.** No retrofit of
existing menus, and **no check** — the `audit-menu` skill argues at length that
a mechanical reader of these files keeps being wrong, and a linter for
"does this finding cite evidence" would be exactly that.

**Decline path, and it is not weak.** Findings are meant to be cheap to file,
and a required evidence line is friction on the part of the loop that should
stay frictionless — the menu exists to capture a suspicion before it is lost.
The counter-argument is that the five errors above all reached a *proposal*
specific enough to implement from, which is past the suspicion stage; the rule
could bind only on the `**Proposal:**` paragraph and leave the observation free.
**That narrower version is probably the right one** and is offered as the
default reading if this is taken.

---

## How to take one

Per the `audit-menu` skill: Nate names one — *"take G6"* — it becomes one PR on
its own branch, the outcome note is appended **under that finding's heading in
the same PR**, and the merge waits for a separate word. Taking a finding means
auditing it first: **every measurement above is a 2026-09-03 GitHub-side or
filesystem reading, and several are one click from being false.** Re-run the
command in the finding and lead the report with whatever it contradicts.
