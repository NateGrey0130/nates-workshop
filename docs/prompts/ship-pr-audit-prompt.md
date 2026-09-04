# Prompt — audit `ship-pr` against the workflow it now describes

`.claude/skills/ship-pr/SKILL.md` is 386 lines and was last edited **2026-09-03
14:43** (`89af6f7`, taking `REPO-AUDIT` G5(a)). Since the week it was written the
repo grew a ruleset, two GitHub Actions workflows, a PR template and three new
skills, and the skill absorbed some of that and not the rest. Audit it and
produce a findings menu.

**Write one file and change nothing else.** Do not edit the skill in this pass,
however obvious a fix looks — taking a finding is a separate decision, and the
one thing that has gone wrong repeatedly on this surface is a correction shipped
without being measured.

## Where things are, and what to load first

The monorepo is `C:\Users\natha\Projects\nates-apps`. This session may have
started elsewhere; read the repo's `CLAUDE.md` yourself. Load **`audit-menu`**
before writing anything — it owns the finding shape, so this brief does not
restate it — and run a **`claim-audit`** pass over the skill itself, because
every path, command, count, line number and *"X exists nowhere"* in it is a claim
with a date on it.

`ship-pr` fires on *"ship this"*, so it is loaded during the pass that audits it.
Notice when you are following it rather than reading it.

## Scope

1. `.claude/skills/ship-pr/SKILL.md`, every section.
2. **The four surfaces it now has to agree with**, none of which existed when the
   loop was first written: `.github/workflows/tests.yml`,
   `.github/workflows/deploy-alarm.yml`, `.github/pull_request_template.md`, and
   the `main` ruleset (`gh api repos/NateGrey0130/nates-workshop/rulesets`).
3. **The scripts it names and the ones it does not:** `deploy-sweep.mjs`,
   `drift-check.mjs`, `repo-vs-live.mjs`, `d1-apply.mjs`. Read their headers —
   two of them argue with the skill.
4. **The skills it points at, and the ones it should.** `windows-shell`,
   `schema-change`, `class-import`, `audit-menu` are named. `verify-ui`,
   `pick3cut5` and `book-survey` are not.
5. The memory layer at
   `C:\Users\natha\.claude\projects\C--Users-natha-Downloads\memory\` — several
   entries are shipping lessons that never reached the skill.

Out of scope: the other eight skills, except where a sentence should move
between them.

## Starting points — measured 2026-09-03, and still yours to re-measure

These were run by the session that wrote this brief, on 2026-09-03, against
`origin/main` at `c6beaad`. **Re-measure each before filing it.** *Taking a
finding is also auditing the finding*, and this brief is not exempt: some of
these will have moved, and at least one is probably wrong in a way that only
shows when you run it.

1. **The skill never mentions `deploy-alarm.yml`.** `grep -c deploy-alarm` on
   `SKILL.md` returns `0`. The workflow has run since 2026-09-03 and its own
   header names `ship-pr` step 9 as one of the two things it exists to back up.
   The skill's *The deploy is not guaranteed* section still reasons from *"both
   depend on a person remembering"* — a premise the alarm was built to falsify.
2. **Step 9's command is unfiltered, and `deploy-sweep.mjs` was filtered on
   exactly this ground the same day.** Step 9 reads every check-run on the merge
   commit. `4e4eb128` carries two — `Cloudflare Pages` and
   `check-recent-deploys`. The sweep's comment block (`scripts/deploy-sweep.mjs`,
   the `--jq` line) records what happened when it did the same thing: the
   alarm's first run was red, and the sweep reported a commit as DID NOT DEPLOY
   on the same line that showed `Cloudflare Pages=success`. *"Two tools feeding
   each other false alarms is precisely how a check stops being read."* Step 9
   was not filtered.
3. **Step 9 reads `.conclusion` alone, and runs at the moment it is null.**
   `deploy-alarm.yml` reads status *and* conclusion, with a comment saying why:
   conclusion is null in flight, so reading it alone cannot tell *still building*
   from *never ran*, and those need opposite answers. Step 9 sits immediately
   after step 8, a Pages build here takes 20–35 seconds, and the skill says
   *"anything but `success` … means the merge did not ship."* **What does step
   9's exact command print for a run still in flight?** Run it against a live
   merge rather than reasoning about jq — this brief reasoned, and says so.
4. **The PR body convention is not in the skill.** Step 6 passes
   `--body-file pr-body.tmp` and the file never says what goes in the file.
   `REPO-AUDIT` G7 asserts *"That shape exists only inside the `ship-pr` skill"*
   and built `.github/pull_request_template.md` from that premise. The template
   now carries six headings the skill does not. Which is authoritative, and is
   G7's sentence a false claim to correct in G7's own note?
5. **Step 7 hardcodes `--merge`, and the repo allows three merge shapes.**
   `REPO-AUDIT` G5(b) was closed by decision: squash and rebase stay enabled.
   `git log --first-parent` on `origin/main` shows **137** single-parent commits
   against 535 merge commits (2026-09-03; this number moves). Both deploy
   monitors walk `--first-parent` *because of* those. The skill says nothing
   about them — is that a gap, or is `--merge` the house shape and the finding is
   that the skill should say so?
6. **`verify-ui` and `pick3cut5` are named zero times.** Step 4's last bullet is
   *"changed anything visible: drive it in a browser"* — nine words for the
   ground `verify-ui` covers in full, including the three ways the Browser pane
   lies. The `--remote` bullet above it is nine lines of Pick 3 Cut 5 Access
   material that `pick3cut5` owns. Both skills shipped 2026-09-02
   (`SKILL-AUDIT` N1–N3), after the section they belong beside.
   **Precedent for the posture:** `SKILL-AUDIT` F1 moved the shell material out
   of `ship-pr` and left a pointer, deliberately not a duplicate, and the skill
   came out shorter. Say which of these should move, which should stay, and why
   — not all of them are the same case.
7. **Nothing about worktrees, parallel sessions, or a stacked PR.** The memory
   layer holds `stacked-pr-base-deletion` (`gh pr merge --delete-branch` closes
   the child PR, and it cannot be reopened — only replaced),
   `one-session-at-a-time`, and `dev-server-8788-is-another-worktree`. Step 7
   recommends `--delete-branch` unconditionally. Is the stacked case rare enough
   here to leave in memory, or is it a clause in step 7? Memory fires on
   relevance; a skill fires on its description.

## What to ask of each section

- **Is it still true?** Cheapest claims first — the prune table, `d1-apply`
  paths, script behaviour, the check-run shape, and any claim about what another
  file says.
- **Does it teach the trap, or only the procedure?** The sections that work here
  name the failure that made them. Flag any passage a session would follow
  correctly and still get burned by.
- **Does it fire at the moment it is needed?** Step 3 (*schema first*) and step 9
  (*confirm the deploy*) are the two the loop exists for. Everything else is
  competing with them for attention in a 386-line read.
- **Does it quote a moving number?** The skill argues against this at line 79 and
  should be held to it.
- **Is it duplicated in `CLAUDE.md`, another skill, or memory — and do the copies
  agree?** `CLAUDE.md` restates the merge-is-the-deploy rule and the tests.yml
  posture in its own words.

## Trim — the pass is not allowed to only add

386 lines are read in full every time this fires, and every line added to step 4
costs attention at step 9. **Propose at least three deletions or moves**, with
the destination named for anything that moves. Candidates worth pricing, not a
list to implement:

- *A changed secret needs the dev server restarted* (14 lines) — a dev-server
  and importer failure. Does it belong in a shipping skill at all?
- *Line endings* (8 lines) — already a pointer to `windows-shell` wrapped in a
  restatement of what it points at.
- *Pruning*'s closing two paragraphs (~10 lines) — a good lesson about writing
  down what a change was supposed to achieve, and the third meta-paragraph of
  that kind in the file.

**Moving is not deleting.** A sentence lifted out has to land somewhere and the
PR has to show both halves, or the next pass finds the gap instead of the
duplicate.

## The subagent question — answer it, do not assume it

Propose and rank a `ship-verify` subagent: given a branch or a merge commit, it
runs the verification battery — the five suites, `drift-check --remote`,
`repo-vs-live`, the merge-commit check-runs, `deploy-sweep` — and **reports
disagreements only**, writing nothing, merging nothing, deploying nothing.

**Read `SKILL-AUDIT` N4 before writing a word of this.** A `deploy-verify`
*skill* was proposed and **DECLINED 2026-09-02** on a stated condition: *"the
only honest trigger is 'you just merged', which is exactly when `ship-pr` is
already loaded. Splitting it moves the step further from the moment. Do not
re-propose without a new failure."* A subagent is not a skill split — it does not
need a trigger, it is called from inside `ship-pr` — but **the burden N4 set is
still yours**: name the new failure, or recommend declining.

The one precedent that works here is `book-reconcile`: read-only, returns
disagreements only, spawned from inside the skill that owns the step. Judge
against it, and answer these:

- **What does it buy that a step does not?** The battery is mechanical and
  token-heavy; a subagent returns a verdict instead of thousands of lines of
  test output into the main context. Price that against `EFFICIENCY-AUDIT`'s
  measured numbers rather than asserting it.
- **What does it cost forever?** A file to keep current, a second place the
  suite list lives — the duplication problem this repo already names — and a
  layer between the person and the output. Step 4's own rule is that a
  `--section` run labels itself `PARTIAL` so it cannot be quoted as the gate; a
  subagent reporting *"smoke passed"* is a summary nobody can audit.
- **Does it move the failure or remove it?** The four-day outage was not a
  missing check. It was 65 unambiguous red signals nobody read. A subagent that
  reports to the same session that was not reading is the same mechanism with
  more machinery.
- **What can it not do?** It cannot merge, it cannot decide, and it must not hold
  a Cloudflare credential — `tests.yml` deliberately has none, on the stated
  posture that a write to production costs a deliberate keystroke.

State plainly whether you would build it. **A recommendation to decline is a
successful answer** and should be recorded as one so the negative result is not
re-derived a third time.

## Output

Write `SHIP-PR-AUDIT.md` at the repo root, in the house protocol — findings
follow the `audit-menu` shape, `### F1 — …`, em dash, no severity word,
`**Proposal:**` specific enough to implement from, stated posture, evidence with
its command and its day, confidence *and what would raise it*, ongoing cost.
`### N1 — …` for the subagent proposal.

**State the cost of the file itself in its header:** this makes a **sixteenth**
findings menu, on a machine where every existing menu is closed, and
`META-AUDIT` A1 declined an index of them. If the pass turns up fewer than four
findings worth taking, **say so and file them into the menu that owns the
surface instead** — most of the starting points above are `REPO-AUDIT`-shaped —
rather than opening a menu to hold three items.

Open with a status line naming this menu's own trap, as the others do. No
outcome notes; nothing is taken until Nate names one.

Then report in the session: how many findings, the three you would take first
and why, your one-line verdict on the subagent, and **anything you found that
contradicts the seven starting points above** — that list is the most likely
thing in this brief to be wrong.

## Non-goals

No edit to any skill, to `CLAUDE.md`, to memory or to a workflow in this pass. No
new script, no new check, no PR beyond the one that adds this file. Do not file a
finding you intend to take yourself. **Do not make anything a required status
check** — the repo's posture is warn, do not block, and changing it is a separate
decision that needs its own finding.

When this pass is run, archive this brief into `docs/prompts/` in the same PR
(`HEALTH-AUDIT` F3, and `META-AUDIT` A12 — two briefs went missing before anyone
noticed the archive was assembled by hand).
