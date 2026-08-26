---
name: ship-pr
description: Take a change in this repo from branch to deployed, the way this repo actually works. Use when opening, reviewing, merging or deploying a PR — "ship this", "open a PR", "merge it", "deploy this" — and whenever a change touches D1, because schema and data are applied BEFORE the merge rather than by it. Covers the branch/verify/PR/merge/prune loop, the ordering rule that makes it safe, and the shell traps that have corrupted commits and commands here before.
---

# Shipping a change

**Merging to `main` IS the deploy.** Cloudflare Pages publishes the repo root on
every merge. There is no build step, no CI, and nothing runs your tests for you.
Whatever is on `main` is live within a minute or two.

That single fact drives everything below: there is no stage where a mistake is
caught for you, so the checks happen before the merge or they do not happen.

## The loop

1. **Branch.** Never commit to `main` — it deploys.
   ```bash
   git checkout -b short-kebab-description
   ```
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
     `node apps/pick3cut5/test/smoke.mjs --remote`. It fetches the app and its
     assets from production with **no** Access session, and checks the rest of
     the site is still gated. This is the only check that can catch the bug it
     was written for: the app shipped bypassed on its own two paths but not on
     `/shared/styles.css` or `/shared/js/ui.js`, so every friend with a room
     code got an unstyled page and `escHtml is not defined` at the first flip —
     while `curl /apps/pick3cut5/` returned 200 the whole time and local dev,
     which has no Access at all, played perfectly.
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
   - changed anything visible: drive it in a browser

   The three catch different classes of bug and none substitutes for another.
   A class picker that rendered everything 1300px below the fold passed all 768
   smoke checks and was reported as "nothing happens".
5. **Commit.** See [commit messages](#commit-messages).
6. **Push and open the PR.**
   ```bash
   git push -u origin short-kebab-description
   gh pr create --base main --head short-kebab-description --title "..." --body-file pr-body.tmp
   ```
7. **Merge**, only when asked. It deploys. `--delete-branch` removes the
   branch from GitHub *and* locally, so there is nothing left to tidy.
   ```bash
   gh pr merge <n> --merge --delete-branch
   ```
8. **Sync**, then confirm the merge from GitHub rather than from the pull.
   ```bash
   git checkout main && git pull origin main
   ```
   ```bash
   gh pr view <n> --json state,mergeCommit --jq '.state + "  " + .mergeCommit.oid'
   ```
   **`Already up to date` means nothing on its own.** `gh pr merge` fast-forwards
   local `main` itself, so a successful merge and a merge that never happened
   print the same line. PR #165 printed it because the PR was still open; #176
   and #177 printed it because the work was already local. Only `state` and the
   merge commit distinguish them, and `git log --oneline -2 origin/main` should
   show the merge commit on top.
9. **Verify production**, by asking it — not by reading the exit code.

## Pruning is not a step

This clone sets:

```bash
git config remote.origin.prune true
```

so every `git fetch` — and therefore every `git pull` — drops
remote-tracking refs whose branch is gone from GitHub. Nothing needs pruning
by hand.

It is set **per clone**, not in the repo, because git has no way to ship
config with a checkout. A fresh clone needs the one line above; until then it
accumulates stale `origin/*` refs that are cosmetic but keep showing up in
`git branch -r`.

What used to be here was a four-command dance — delete the remote branch,
delete the local branch, fetch with `--prune`. Three of those four are
unnecessary: `gh pr merge --delete-branch` does both deletions, and the config
does the pruning. The dance was being repeated by hand every few PRs, which is
the tell that it should have been configuration rather than instructions.

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

Two traps when writing that query from PowerShell:

- **`\"` does not escape anything.** The string ends early and the rest
  word-splits into arguments wrangler rejects. Class markdown cites gear as
  `item_id: "slug"`, so the queries most worth running are the ones that break.
  Build the quote in SQL instead: `char(34)`. Same trick as `char(8212)` for an
  em-dash.
- **`--file` returns a summary over `--remote`, not results.** A `SELECT` sent
  with `--file` comes back as `Total queries executed / Rows read`, so every
  count reads as 1 and a drift check built on it reports everything as missing.
  Use `--command` for anything whose rows you need.
- **Read results from a file, not the terminal.** `--json | Out-File -Encoding
  utf8 out.json`, then read `out.json`. Transcribing from terminal output put
  `ng-15-northern-gun-laser-rifle` a keystroke away from being written into a
  class definition; the real slug is `ng-l5-`.

## Commit messages

This repo's history reads as prose. A message says what was wrong and why, not
what files moved — `git log` is the only place some of these decisions are
recorded. Match the surrounding style before writing one.

**Write it to a file and use `-F`.** Backticks in a `-m` string are evaluated by
the shell: a commit message here once ran `wrangler d1 execute` and pasted its
help output into the commit. Backticks are natural in this repo's prose, so this
is not a hypothetical.

```bash
git commit -F commit-msg.tmp
```

**Do not `git add -A` immediately before `--amend`.** It sweeps the message file
into the commit. If it happens: `git add -A && git commit --amend --no-edit`
after deleting the file, then confirm with `git ls-tree -r HEAD --name-only`.

## Line endings

`.sql` is pinned to LF by `.gitattributes` — a CRLF checkout once changed the
bytes that reached production. Everything else in the repo is CRLF. A script
that rewrites a file must preserve what that file had; the smoke test fails a
`.sql` carrying a CR.

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
- branch deleted on both sides, `git status` clean
- if the change is user-visible, it has been exercised in a browser
