---
name: ship-pr
description: Take a change in this repo from branch to deployed, the way this repo actually works. Use when opening, reviewing, merging or deploying a PR — "ship this", "open a PR", "merge it", "deploy this" — and whenever a change touches D1, because schema and data are applied BEFORE the merge rather than by it. Covers the branch/verify/PR/merge/prune loop, the ordering rule that makes it safe, and the shell traps that have corrupted commits and commands here before.
---

# Shipping a change

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`), and four runnable lines: it
> merges with `--delete-branch`, records `git config remote.origin.prune true`,
> and teaches no manual prune. The incident behind each rule is in
> `reference/why.md`.

**Merging to `main` IS the deploy.** Pages publishes the repo root on every
merge with no build step, so nothing after the merge catches a mistake: the
checks happen before it or not at all.

**Three checks are required** by `main`'s ruleset `22209348`: `smoke` and
`menus` (`.github/workflows/tests.yml`) and `regression` (`regression.yml`).
The merge button and `gh pr merge` are refused until all three pass.
`play-flow` and `deploy-alarm` report only. Ask the ruleset itself:
`gh api repos/NateGrey0130/nates-workshop/rulesets/22209348`. A green check is
not always a suite that ran: `regression` and `play-flow` run only for a
Palladium or shared change, and each group's suites only for that group or a
shared change (`CLAUDE.md` → *Three groups*). A skipped suite says so in its log.

**Step 4 is still yours.** CI reports after the PR is open. Treat it as a
second pair of eyes on a run you already did.

## The loop

1. **Branch.** Never commit to `main`; the ruleset refuses the push, but only
   after you have committed. Name it per `CLAUDE.md` → *Naming*
   (`<group>/<type>/<slug>`), and check the name is free with the three
   commands there:
   ```bash
   git checkout -b pal/data/triax-ngr-police-club
   ```
   **A branch that takes a numbered finding names the menu** in its slug and
   its commit subject: `proc/audit/ui-audit-f30-banked-picks` and
   `Take UI-AUDIT F30: …`, never a bare `f30`. Menus number with `F`, `D` and
   `N`, so a bare number identifies nothing once the branch is gone.
2. **Make the change.**
3. **Apply schema and data FIRST**, if the change needs them. See
   [the ordering rule](#the-ordering-rule). This step is wrong by default.
4. **Verify**, at the layer the change lives in:
   - **always**, the five smoke suites:
     `node apps/character-creator/test/smoke.mjs`,
     `node apps/filament-forge/test/smoke.mjs`,
     `node apps/pick3cut5/test/smoke.mjs`,
     `node apps/pick3cut5/test/game.mjs`,
     `node apps/media-vault/test/smoke.mjs`.
     `smoke.mjs --section <name>` is for iterating; **the merge gate is the
     flagless run**, and a partial run labels itself `PARTIAL SMOKE PASSED` so
     it cannot be quoted as this step.
   - **touched anything Pick 3 Cut 5 loads, or an Access policy:**
     `node apps/pick3cut5/test/smoke.mjs --remote`, the only check that fetches
     production's assets with no session (`pick3cut5`).
   - **added a class or catalog rows:** update the book's
     `**Rows citing this book:**` line in its survey **in the same commit**, and
     its `**Status:**` line if it moved. `test/regression.mjs` prints the line to
     paste. Rows citing no surveyed book are the one shared count, in
     `docs/operations.md`. Never quote a current value from memory; run the test.
   - **touched documentation, class prose or a `note`, or lifted a limitation
     one describes:** sweep the sentences describing the old limit, in the same
     change, and hand them to `claim-capability-verifier` (*the app cannot do
     X*) and `claim-count-verifier` (a count in prose). `claim-audit` owns the
     method. Nothing fails if you skip this; it is still required.
   - **touched an endpoint, the schema or a data script:**
     `node apps/character-creator/test/regression.mjs`, which builds a database
     from nothing and drives the real routes.
   - **changed anything visible:** `verify-ui`, then drive it in a browser.

   None of these substitutes for another.
5. **Commit.** See [commit messages](#commit-messages).
6. **Freshness, push, and the PR.** Run `CLAUDE.md` → *Before you open a PR*
   first: `git fetch origin`, then `git diff --name-only HEAD...origin/main`.
   If `main` touched your paths or any shared path, merge `origin/main` in and
   re-run step 4.
   ```bash
   git push -u origin pal/data/triax-ngr-police-club
   gh pr create --base main --head pal/data/triax-ngr-police-club --title "[pal/data] ..." --body-file pr-body.tmp
   ```
   The body, one line each, dropping any that do not apply:
   - **The gap**: what was wrong and why it mattered, not which files moved.
   - **What was measured**: numbers with source and date, `--remote` or
     `--local`. **Say so in words if a claim was reasoned to rather than run.**
   - **Posture**: log/cap, warn/block, opt-in, docs only, no new gate.
   - **Nothing regresses, checked, not assumed**: what could have broken and the
     check that says it did not. An absence claim is proved by reading.
   - **Decline path**: the honest case for not doing this.
   - **Verification**: the flagless pass lines. Touched D1? Say which files are
     **already applied**.

   `.github/pull_request_template.md` carries the same six for the browser.
7. **Merge**, only when asked. It deploys. Re-run the freshness check first.
   Run the merge as a command on its own (the hook refuses it chained):
   ```bash
   gh pr merge <n> --merge --delete-branch
   ```
   `--delete-branch` removes the branch on GitHub and locally. Keep passing it
   even though `delete_branch_on_merge` is on, because that setting does not
   touch your local branch.

   **Never stack PRs if you can avoid it. If one is stacked on this branch,
   `--delete-branch` closes the child, and a closed PR whose base is gone cannot
   be reopened.** For a stack, **retarget the child first**:
   `gh pr edit <child> --base main`, confirm with `gh pr view <child> --json
   baseRefName,state`, and only then merge the base. Merging the base without
   `--delete-branch` is not enough, because `delete_branch_on_merge` deletes it
   anyway. **Then refresh the child before merging it**: its checks still
   describe its merge into the OLD base, and a base change re-runs nothing. Once
   the base has merged, merge `origin/main` into the child and push, **even when
   the freshness check says no merge is needed**, and merge the child only on
   `smoke`, `menus` and `regression` from that push. `gh run rerun` is not a
   refresh; it replays the old merge.

   `--merge` is the default shape (the branch's own messages survive); squash
   and rebase are enabled and not wrong.
8. **Sync, then confirm the merge from GitHub**, not from the pull:
   ```bash
   git checkout main && git pull
   ```
   **Bare, with no `origin main`**, or the merged branch's tracking ref is not
   pruned (see *Pruning*).
   ```bash
   gh pr view <n> --json state,mergeCommit --jq '.state + "  " + .mergeCommit.oid'
   ```
   **`Already up to date` means nothing**: `gh pr merge` fast-forwards local
   `main` itself, so a merge that happened and one that did not print the same
   line. Only `state` and the merge commit tell them apart.
9. **Confirm the deploy ran.** Not the same step as confirming the merge:
   ```bash
   gh api repos/NateGrey0130/nates-workshop/commits/<sha>/check-runs \
     --jq '[.check_runs[] | select(.name=="Cloudflare Pages")]
           | if length == 0 then "NO RUN" else (.[0].status + "/" + (.[0].conclusion // "pending")) end'
   ```
   Filtered to the Pages run, because another workflow posts to `main` too.
   `completed/success` is the pass. **`pending` means wait and look again**: a
   build takes 20–35 seconds and `conclusion` is null while it runs. `NO RUN`
   right after the merge may be too early; `NO RUN` a minute later is a merge
   that registered no deploy at all.
10. **Verify production by asking it** for a string this change added (see
    below). D1 cannot answer it: the database moved before the merge.

## The deploy is not guaranteed

Pages compiles **every** file under `functions/`, routed or not, plus their
imports, with its build image's wrangler (3.x), not the one here (4.x). Syntax
that image cannot parse fails the whole deploy, and the site keeps serving the
last build, so nothing looks wrong. `SETUP.md` → *When the merge does not
deploy* has the mechanism; `environment.mjs` §9 catches the known shape in
step 4. `gh pr checks` has shown a red Pages mark on PRs that deployed fine, so
read step 9, not that.

**Merges seconds apart skip builds, and that is not a failure.** Cloudflare
**skips** a deployment a later build overtakes, and its check-run says
`Building` forever, so step 9 stays `pending` for that merge. Nothing is
missing: the next build publishes the whole repo root. **Tell skipped from
wedged by whether a later commit deployed, never by how long it has been
pending, and never delete a deployment on a pending check-run.** `SETUP.md` →
*A skipped deployment looks exactly like a wedged one* has the table.

**End a session, or a batch of merges, with the sweep:**

```bash
node scripts/deploy-sweep.mjs
```

It walks the last twenty first-parent commits on `origin/main`, names any that
did not ship (including one with no check-run), and says which pending ones a
later deploy already carried. It also compares `workers/pick3cut5-room`'s
newest commit with its live `GIT_SHA`, because a merge never deploys that
Worker. A timestamp gap there says the Worker may be stale, not that it
matters: read the diff, then deploy or decide not to. Report only; it never
fails. It does not replace step 9.

`.github/workflows/deploy-alarm.yml` runs the same walk daily over 26 hours and
fails its own run, which is how it emails Nate. It is not a gate, covers only
Pages, and goes silent if Actions notifications are muted.

## Verify production by asking it

```bash
node scripts/drift-check.mjs --remote
```

It compares migrations, data scripts, tables, columns and published classes
against production. **Run it before the merge as well as after**: an unapplied
data script shows as `DATA SCRIPT NOT RUN`. A clean run prints `NO DRIFT`.

Then ask production for a string the change added:

```bash
curl -s https://nates-workshop.pages.dev/apps/pick3cut5/ | grep -c '<a string the change added>'
```

Most of the site 302s to the Access wall, so that works only on the Pick 3
Cut 5 bypass paths; elsewhere, load the page in a logged-in browser and look for
the string.

Exit codes from `wrangler d1 execute` are advisory: query the thing back.

```bash
npx wrangler d1 execute DB --remote --command "SELECT count(*) FROM schema_migrations;"
```

**Three ways that query comes back wrong without failing** (`\"` in PowerShell,
`--file` over `--remote`, transcribing from the terminal) are in
**`windows-shell`**. Read it before a query you will act on.

## Pruning is a step only when you name a refspec

This clone sets:

```bash
git config remote.origin.prune true
```

That is necessary and not sufficient. Pruning considers only the refs the
refspec covers:

| command | a merged branch's dead tracking ref |
|---|---|
| `git pull origin main` | **survives** |
| `git pull` | pruned |
| `git fetch` | pruned |

So step 8 is bare. The setting is per clone; a fresh clone needs the line
above. `gh pr merge --delete-branch` plus the config plus a bare fetch replaces
any manual pruning.

## The ordering rule

**Schema and data are applied to production BEFORE the merge that needs them**,
because Pages deploys the moment `main` moves:

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-thing.sql
```

The PR body then says which files are **already applied**, so a reviewer does
not look for a deploy step. This writes production ahead of review, so know the
recovery first: D1 Time Travel (a rolling 30 days) and `scripts/d1-backup.mjs`
(`apps/character-creator/docs/operations.md` → *Recovery*). No backup is
prescribed per apply. Migrations themselves: `schema-change`.

## `--local` is not a mirror of production

**Never audit against the local database.** It drifts in both directions and
neither is visible from inside it: extra rows give false reports, and missing
rows make `class-check` print stub SQL for rows that exist, which
`--emit-script` writes into a file that ships (`class-import`). Local is for
applying and testing a script; production is for asking what is true, and this
proves the repo and production agree, by name:

```bash
node scripts/repo-vs-live.mjs
```

## Commit messages

The history reads as prose: say what was wrong and why, not which files moved.
**Write the message to a file named `.tmp` and commit with `-F`**, because
backticks in `-m` are evaluated by the shell and `*.tmp` is gitignored:

```bash
git commit -F commit-msg.tmp
```

## Line endings

`.sql` is pinned to LF by `.gitattributes`, and smoke fails a `.sql` with a CR.
**Read `windows-shell` before any in-place edit.**

## A rotated secret is two places

Production reads its own copy as a Pages secret, so rotating a key is a change
here and there, and only the second ships. The local half (`.dev.vars` is read
at boot) is in **`windows-shell`**.

## What "done" means

- the smoke test passes on `main` after the merge
- `node scripts/drift-check.mjs --remote` prints `NO DRIFT`
- production queried, and matching what the change intended
- the PR is `MERGED` and its merge commit is on top of `origin/main`
- **the merge commit's Pages check-run is `completed/success`, and production
  answers with a string the change added**; merged is not deployed
- the branch deleted on both sides, `git status` clean
- a user-visible change exercised in a browser
