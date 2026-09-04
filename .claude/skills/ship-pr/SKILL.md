---
name: ship-pr
description: Take a change in this repo from branch to deployed, the way this repo actually works. Use when opening, reviewing, merging or deploying a PR — "ship this", "open a PR", "merge it", "deploy this" — and whenever a change touches D1, because schema and data are applied BEFORE the merge rather than by it. Covers the branch/verify/PR/merge/prune loop, the ordering rule that makes it safe, and the shell traps that have corrupted commits and commands here before.
---

# Shipping a change

**Merging to `main` IS the deploy.** Cloudflare Pages publishes the repo root on
every merge. There is no build step, and nothing gates the merge. Whatever is on
`main` is live within a minute or two.

That single fact drives everything below: there is no stage where a mistake is
caught for you, so the checks happen before the merge or they do not happen.

**Step 4 is still yours, even though a workflow now runs the same suites.**
`.github/workflows/tests.yml` runs the five smoke suites on every pull request
(`REPO-AUDIT.md` G8), and it is **reporting only** — not a required status
check, no ruleset behind it, and a red run does not stop a merge. It also
reports *after* you have opened the PR, which is after the point where step 4
would have saved you. Treat it as a second pair of eyes on a run you already
did, never as the reason to skip one. `regression.mjs` is not in it at all.

## The loop

1. **Branch.** Never commit to `main` — it deploys. Since 2026-09-03 a GitHub
   ruleset refuses a direct push to `main` server-side, so this is enforced
   rather than remembered (`REPO-AUDIT.md` G1) — but it fires at `git push`,
   after you have already committed, and unpicking a commit made on `main` is
   still your problem. Branch first.
   ```bash
   git checkout -b short-kebab-description
   ```
   **If the change takes a numbered finding, the branch and the commit subject
   name the menu** — `ui-audit-f30-banked-picks` and `Take UI-AUDIT F30: …`,
   not `f30-banked-picks` and `Take F30: …`. Eleven menus number with `F`,
   three with `D` and two with `N`, so a bare number identifies nothing once
   the branch is deleted and `git log --grep` is all that is left. Anything
   that is **not** a finding keeps the plain slug above. `audit-menu` →
   *Which is why a finding reference names its menu*; `REPO-AUDIT.md` G12/G13.
2. **Make the change.**
3. **Apply schema and data FIRST, if the change needs them.** See
   [ordering](#the-ordering-rule) below. This is the step that is wrong by
   default.
4. **Verify**, at the layer the change lives in:
   - always: `node apps/character-creator/test/smoke.mjs` and
     `node apps/filament-forge/test/smoke.mjs` — the second is fast (no
     wrangler) and pins FilamentForge's README, the snapshot SQL generator and
     the data endpoint's sanitizers, plus
     `node apps/pick3cut5/test/smoke.mjs`, which derives from `index.html` the
     paths that must be outside the Access wall and checks they are documented
     and exempted, and `node apps/pick3cut5/test/game.mjs`, which walks all 56
     reachable rounds and proves the server's budget rules and the client's copy
     of them still agree. Finally `node apps/media-vault/test/smoke.mjs`, which
     proves the merge planner that retires MediaVault's localStorage cache,
     pins that app's README, and fails if any endpoint regains the power to
     replace a whole library — the bug that app was rebuilt to end.

     The character-creator smoke test takes `--section <name>` for iterating
     between edits — it runs only the matching sections and skips the
     wrangler-backed environment half. **The merge gate is the flagless run.**
     A partial run labels its summary `PARTIAL SMOKE PASSED` precisely so its
     output cannot be quoted as this step.
   - **touched anything Pick 3 Cut 5 loads, or any Access policy:**
     `node apps/pick3cut5/test/smoke.mjs --remote`. It fetches the app *and its
     assets* from production with **no** Access session, and it is the only
     check that sees a bypass covering the app's own paths but not the shared
     CSS and JS it loads. `pick3cut5` has the case, and read it before touching
     an Access policy.
   - added a class or catalog rows: **update the README's pinned counts in the
     same commit.** `test/regression.mjs` reads them out of the prose and
     compares against a database built from nothing, so they fail the run rather
     than drifting — the clean-run table (classes published-and-live, skills,
     spells, psionic powers, gear) and the sentence *"N of M published classes
     state no hit point formula"*, which is parsed as WORDS. Adding a class
     moves at least two of those.

     **The current values are deliberately not quoted here.** They used to be,
     and went stale on the next import; a skill naming a moving number is wrong
     more often than right. Run the test — it prints what it wanted against what
     it found, which is the answer anyway.
   - touched an endpoint, the schema or a data script:
     `node apps/character-creator/test/regression.mjs` — it builds a database
     from nothing and drives the real routes, which is the only thing that
     catches a fresh environment being broken
   - changed anything visible: **`verify-ui`**, then drive it in a browser

   The three catch different classes of bug and none substitutes for another.
   A class picker that rendered everything 1300px below the fold passed all 768
   smoke checks and was reported as "nothing happens".
5. **Commit.** See [commit messages](#commit-messages).
6. **Push and open the PR.**
   ```bash
   git push -u origin short-kebab-description
   gh pr create --base main --head short-kebab-description --title "..." --body-file pr-body.tmp
   ```
   **What goes in the body**, one line each, and delete any that does not apply —
   a short honest PR beats a padded one:
   - **The gap** — what was wrong, and why it mattered. Not what files moved.
   - **What was measured** — numbers with their SOURCE and their DATE, and
     whether `--remote` or `--local`. **If a claim was reasoned to rather than
     run, say so in those words.**
   - **Posture** — log/cap, warn/block, opt-in, documentation only, no new gate.
     Half of what is being agreed to, and the cheapest thing to get wrong.
   - **Nothing regresses — checked, not assumed** — what could have broken and
     the check that says it did not. *"Nothing else uses this"* is an absence
     claim: prove it by reading, not by grepping one of its two shapes.
   - **Decline path** — the honest case for NOT doing this, so declining stays a
     real option.
   - **Verification** — paste the pass lines. **The merge gate is the flagless
     run**; a `--section` run labels itself `PARTIAL` so it cannot stand in.
     Touched D1? Say which files are **already applied**.

   `.github/pull_request_template.md` carries the same six as a compose-box
   prompt for a PR opened in the browser. `--body-file` replaces it, which is
   this path, so **this list is the copy that gets read** and the template
   follows it.
7. **Merge**, only when asked. It deploys. `--delete-branch` removes the
   branch from GitHub *and* locally, so there is nothing left to tidy.
   Since 2026-09-03 the repository also has **`delete_branch_on_merge`** on, so
   the **remote** branch goes whether or not you pass the flag — including on a
   merge from the web UI, which is the case the setting was turned on for
   (`REPO-AUDIT.md` G4). **Keep passing `--delete-branch` anyway:** the setting
   does nothing about your *local* branch, and that half is still yours.
   ```bash
   gh pr merge <n> --merge --delete-branch
   ```
8. **Sync**, then confirm the merge from GitHub rather than from the pull.
   ```bash
   git checkout main && git pull
   ```
   **Bare, with no `origin main` after it.** Naming a refspec is what stops the
   merged branch's tracking ref being pruned — see [pruning](#pruning-is-a-step-only-when-you-name-a-refspec).
   ```bash
   gh pr view <n> --json state,mergeCommit --jq '.state + "  " + .mergeCommit.oid'
   ```
   **`Already up to date` means nothing on its own.** `gh pr merge` fast-forwards
   local `main` itself, so a successful merge and a merge that never happened
   print the same line. PR #165 printed it because the PR was still open; #176
   and #177 printed it because the work was already local. Only `state` and the
   merge commit distinguish them, and `git log --oneline -2 origin/main` should
   show the merge commit on top.
9. **Confirm the deploy actually ran.** Not optional, and not the same step as
   confirming the merge. See [the deploy is not
   guaranteed](#the-deploy-is-not-guaranteed).
   ```bash
   gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs \
     --jq '[.check_runs[] | select(.name=="Cloudflare Pages")]
           | if length == 0 then "NO RUN" else (.[0].status + "/" + (.[0].conclusion // "pending")) end'
   ```
   **Filtered to the Pages run, and printing status as well as conclusion.**
   Both halves are load-bearing. Another workflow posts `check-recent-deploys`
   to `main`, so an unfiltered read fails the commit when a *different* monitor
   is red — `deploy-sweep.mjs` did exactly that on 2026-09-03 and calls it
   "two tools feeding each other false alarms". And `conclusion` is **null while
   a build is in flight**, which is where you are standing: this runs seconds
   after the merge and a Pages build takes 20-35 of them. `gh`'s jq is gojq,
   where `null` is the identity for `+`, so the old command printed the check's
   name and nothing else — a blank that is not `success` and is not a failure
   either. `completed/success` is the pass. `pending` means wait and look again.
10. **Verify production**, by asking it — not by reading the exit code.

## The deploy is not guaranteed

Merging to `main` starts a deploy. It does not finish one. Cloudflare Pages
compiles **every** file under `functions/` — routed or not — plus everything
they import, with the wrangler its build image ships rather than the one here.
Syntax that image cannot parse fails the whole deploy, and nothing on the
request path changes: the site keeps serving the last build that compiled.
Merges landed on `main` for four days in August 2026 without one of them
reaching production. `SETUP.md` → *When the merge does not deploy* has the
mechanism.

So the merge commit's own check-runs are the step, above — and anything but
`completed/success` on the Pages run means the merge has not shipped **yet**.
`NO RUN` is the one that misreads: a merge registering no check-run at all looks
exactly like a quiet healthy merge and is not one, which is why the query says
so in words rather than printing nothing. `gh pr checks` is not a substitute: it
has shown a red "Cloudflare Pages fail" on PRs that deployed perfectly well, so
the mark there is noise.

**Step 9 is per-merge, and it is a thing to remember.** The signal was never the
problem: every merge commit across those four days reports
`Cloudflare Pages=failure` — 65 consecutive, no flapping, no ambiguity — and
every merge since reports `success`. Nobody read it, at a merge rate that has
twice passed 45 in a day. So end a working session with the backstop:

```bash
node scripts/deploy-sweep.mjs
```

It walks the last twenty **first-parent** commits on `origin/main` and names any
that did
not ship, including one that registered no check-run at all — which looks
exactly like a quiet healthy merge and is not one. Report only: it never moves
the exit code, because a deploy that failed needs a person rather than a
non-zero, and a script that failed on four-day-old history would fail every run
until someone rewrote the past.

**It answers for both deploy paths, and that is the second half.**
`workers/pick3cut5-room` produces no check-run at all — a merge does not deploy
it — so the Pages half is silent about it by construction, and the sweep once
printed a clean summary while saying nothing about the one component you deploy
by hand. It now compares the newest commit touching that directory against the
active deployment's timestamp and reports the gap.

**A timestamp cannot tell you whether the change mattered.** A `$schema` line
fires it as loudly as a rewrite of `room.js`. Read the diff it names, then either
deploy or decide it does not need deploying — but do not silence it, because the
alternative it replaced was a gap nothing reported at all.

It does **not** replace step 9. The sweep tells you something is broken; step 9
tells you *while you still remember what you merged*.

**There is a third one, and it is the only one that does not depend on you.**
`.github/workflows/deploy-alarm.yml` runs daily on a schedule, walks the same
`--first-parent` history over a 26-hour window, and **fails on purpose** —
because a failed scheduled run is what GitHub emails about, and that email is
the whole alarm. Three things about it are worth knowing at a merge and are not
worth reading its header for:

- **It is not a gate.** It runs on a schedule, never on a pull request, and it
  is not a required status check. It cannot block a merge or a deploy.
- **Its channel is notification email**, confirmed reaching Nate on its first
  red run, 2026-09-03. Mute this repo's Actions notifications and the alarm goes
  silent without failing.
- **It answers only for Pages.** `workers/pick3cut5-room` needs Cloudflare
  credentials that CI deliberately does not get, so the sweep above remains the
  only thing covering that half.

It changes nothing about steps 9 and 10, which still happen at the merge. What
it changes is the consequence of forgetting them: a day, rather than the four
that went unnoticed in August.

Then ask production for **a string this change added** — a route, a heading, a
new class name. It is the only check that distinguishes deployed from merged,
and D1 cannot answer it: the database moved *before* the merge, so it looks
identical whether or not the code shipped.

```bash
curl -s https://nates-workshop.pages.dev/apps/pick3cut5/ | grep -c '<a string the change added>'
```

Most of the site 302s to the Access login wall, so a fetch like that only works
on the Pick 3 Cut 5 bypass paths. For anything else, load the page in a logged-in
browser and look for the string there — the point is the string, not the tool.

The known shape of this is caught *before* the merge by the smoke test's
*What Pages will compile* section
(`apps/character-creator/test/checks/environment.mjs` §9), which the flagless
run in step 4 already covers. It is a text check on purpose: building with the
wrangler that resolves here compiles the broken syntax happily, so a
build-based check would pass straight through the outage it exists to prevent.

## Pruning is a step only when you name a refspec

This clone sets:

```bash
git config remote.origin.prune true
```

**That config is necessary and it is not sufficient, and the difference is the
form of the command you fetch with.** Pruning only ever considers the refs the
refspec covers. Fetch with an explicit one — `git pull origin main` — and the
refspec is that branch alone, so no other ref is even a candidate and the
merged branch's `origin/*` survives. Fetch bare, and the default refspec covers
every branch, so the dead ones go.

Measured 2026-09-02, both with `remote.origin.prune` and `fetch.prune` already
`true`, against a tracking ref pointed at a branch that does not exist on the
remote:

| command | the dead ref |
|---|---|
| `git pull origin main` | **survives** |
| `git pull` | pruned |
| `git fetch` | pruned |

So step 8 above is bare on purpose. This section previously reasoned from the
config to the outcome and got it wrong in the direction that hides: the config
was set, the reasoning was plausible, and nothing failed — the stale ref just
sat in `git branch -r` looking like a branch that had not been cleaned up. It
was caught twice in one session, after two merges that had both deleted their
branch correctly.

It is set **per clone**, not in the repo, because git has no way to ship
config with a checkout. A fresh clone needs the one line above; until then it
accumulates stale `origin/*` refs that are cosmetic but keep showing up in
`git branch -r`.

What used to be here was a four-command dance — delete the remote branch,
delete the local branch, fetch with `--prune`. Three of those four are still
unnecessary: `gh pr merge --delete-branch` does both deletions, and the config
plus a bare fetch does the pruning. The dance was being repeated by hand every
few PRs, which is the tell that it should have been configuration rather than
instructions.

**Retiring the dance was right; the sentence that replaced it claimed one step
too few.** Configuration removed the three commands it could remove, and then
the note read as though it had removed all four. That is the failure worth
remembering here — not the git behaviour, which is documented, but the habit of
writing down what a change was *supposed* to achieve rather than what was left
standing afterwards.

---

## The ordering rule

**Schema and data changes are applied to production BEFORE the merge that needs
them**, never after. Pages deploys the moment `main` moves, so code that expects
a column merged first is code running against a database that does not have it.

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-thing.sql
```

The PR body should then say plainly which files are **already applied**, because
by the time anyone reviews it, merging those is a no-op and the branch is only
catching the repo up to a database that already moved. A reviewer who does not
know that will look for the deploy step and not find one.

For anything about migrations themselves, use the `schema-change` skill.

## `--local` is not a mirror of production

**Do not audit against the local database.** It accumulates: rows from a failed
confirm, a draft class from an experiment, whatever a review left behind. Mine
carried **327 skills where the repo and production both have 324**, and an
audit run against it reported two catalog duplicates that production merged away
weeks ago — a finding that would have been fixed twice and was never real.

**It drifts the other way too, and that direction is worse.** On 2026-08-30 the
same database held **293 skills against production's 345** — 52 short. An extra
row costs a false report; a missing one makes `class-check` print stub SQL to
create a row that already exists, which `--emit-script` then writes into a file
that ships. See `class-import` → *Rules that are easy to get wrong*. Neither
direction is detectable from inside the local database, which is the argument
for `--remote` rather than for keeping local tidy.

Local is for *applying and testing a script*. Production is for *asking what is
true*, and `repo-vs-live.mjs` is what proves the two agree:

```bash
node scripts/repo-vs-live.mjs
```

It builds a database from the repo in a scratch directory and diffs **names**
against live, not counts.

## Verify production by asking it

Start with the whole picture, which is one command and read-only:

```bash
node scripts/drift-check.mjs --remote
```

It compares every migration against `schema_migrations`, every data script
against `data_script_runs`, every table and column against `sqlite_master`, and
every published class against one a data script can recreate. **Run it before
merging as well as after**: an unapplied data script on the branch shows up as
`DATA SCRIPT NOT RUN`, which is the ordering rule checked rather than
remembered. A clean run prints `NO DRIFT`.

It is also what catches the failure nobody looks for — a row that exists only in
production. Two classes were in that state for weeks, recreatable from nothing
in the repo, and no test could see it.

Then query the specific thing the change intended.

`wrangler d1 execute` has reported a non-zero exit on runs that fully applied,
and an `Authentication error [code: 10000]` on one that succeeded. Exit codes
here are advisory, and so is a parse of its output — a `--remote` apply that
worked was reported as failed this week because the *reader* choked on
wrangler's multi-block JSON, not because anything went wrong. Query the thing
back:

```bash
npx wrangler d1 execute DB --remote --command "SELECT count(*) FROM schema_migrations;"
```

**Three ways that query comes back wrong rather than failing** — `\"` escapes
nothing in PowerShell, `--file` returns a summary instead of rows over
`--remote`, and transcribing from terminal output has put a wrong gear slug one
keystroke from a class definition. Each is in the **`windows-shell`** skill with
its case. Read it before writing a query whose answer you intend to act on.

## Commit messages

This repo's history reads as prose. A message says what was wrong and why, not
what files moved — `git log` is the only place some of these decisions are
recorded. Match the surrounding style before writing one.

**Write it to a file and use `-F`** — backticks in a `-m` string are evaluated by
the shell, and this repo's prose is full of them. **Name it `.tmp`**: `*.tmp` is
gitignored, so `git add -A` cannot sweep it into the commit the way one shipped
inside PR #404. Details in the **`windows-shell`** skill.

```bash
git commit -F commit-msg.tmp
```

## Line endings

`.sql` is pinned to LF by `.gitattributes` — a CRLF checkout once changed the
bytes that reached production. Everything else in the repo is CRLF, and the
smoke test fails a `.sql` carrying a CR.

**A script that rewrites a file must preserve what that file had**, and the
usual tools do not: `sed -i` flips a whole file to LF, and the obvious grep
check reports it clean anyway. See the **`windows-shell`** skill before any
in-place edit.

## A changed secret needs the dev server restarted

`wrangler pages dev` reads `.dev.vars` **at boot**. Rotate a key, and the running
server keeps sending the old one — so the importer reported
`credit balance is too low` against an account that had just been topped up,
while the same key tested `200 OK` when called directly.

The tell is the shape of the failure, not its text: real API calls take seconds,
and every one of these came back in **0s**. A fast failure is a local one.

```bash
# after editing .dev.vars, or rotating a key
# stop and restart the preview server, then retry one small request
```

Production reads its own copy as a Pages secret, so a rotation is **two** places.

## What "done" means

- smoke test passes on `main` after the merge
- `node scripts/drift-check.mjs --remote` prints `NO DRIFT`
- production queried and matching what the change intended
- the PR shows `MERGED` and its merge commit is on top of `origin/main`
- **the merge commit's check-runs show the Pages deploy at `success`, and
  production answers with a string the change added** — merged is not deployed
- branch deleted on both sides, `git status` clean
- if the change is user-visible, it has been exercised in a browser
