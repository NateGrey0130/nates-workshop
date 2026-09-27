# Why each ship-pr rule exists

`SKILL.md` states the rules; this holds the incident behind each, for when a
rule looks wrong. Read an undated claim as true on the day it was written.

## The gate

- **The ruleset.** A direct push to `main` is refused since 2026-09-03
  (`REPO-AUDIT.md` G1). From 2026-09-03 to 2026-09-16 it carried zero required
  checks; `smoke`, `menus` (G8) and `regression` (`SKILL-AUDIT` F32/F36) became
  required on 2026-09-16. Before that, this skill denied the ruleset existed (F29).
- **Group-scoped suites** since 2026-09-25: a green check is not always a suite
  that ran.
- **Step 4 covers more than smoke.** A class picker that rendered everything
  1300px below the fold passed all 768 smoke checks and was reported as
  "nothing happens". Smoke has never proved that a request works.
- **The claim sweep** (`SKILL-AUDIT` F47) was already in `claim-audit`; it was
  named at this step because that is where a change is verified.
- **Rows lines, not catalog totals**, since 2026-09-24: every import moved the
  totals, and two parallel book PRs always collided on them. A skill naming a
  moving number is wrong more often than right.

## Branches and merges

- **Finding branches name the menu** (`REPO-AUDIT.md` G12/G13): once the branch
  is deleted, `git log --grep` is all that is left, and a bare `F30` matches
  eleven menus.
- **Stacked PRs.** #261 merged with `--delete-branch` on 2026-08-24 and closed
  its child; `gh pr reopen` answered *"Could not open the pull request"* and
  `gh pr edit --base main` refuses on a closed PR. It was replaced by #262 from
  the same head branch.
- **`--merge` over squash** (`REPO-AUDIT.md` G5(b)): the history reads as prose
  and a merge commit keeps the branch's messages. A squash still lands one
  first-parent commit, which both deploy monitors walk.
- **`delete_branch_on_merge`** was turned on 2026-09-03 (G4) for merges from
  the web UI.
- **`Already up to date`.** PR #165 printed it because the PR was still open;
  #176 and #177 because the work was already local.

## Deploys

- **The four-day outage.** From `d5280fe` (2026-08-27) until #399 on
  2026-08-30, a JSON import written as Node requires it
  (`with { type: 'json' }`) failed the build image's wrangler 3.114.17. Every
  merge in those four days reported `Cloudflare Pages=failure`, 65 in a row, and
  nobody read the signal. Merges had twice passed 45 in a day.
- **The step 9 query.** An unfiltered read failed a commit because a different
  monitor was red (`deploy-sweep.mjs`, 2026-09-03: "two tools feeding each other
  false alarms"). `gh`'s jq is gojq, where `null` is the identity for `+`, so the
  old command printed a blank while a build was in flight.
- **Skipped builds.** On 2026-09-04, #714–#717 merged within 17 seconds; all four
  were skipped and all four shipped with #718, four seconds later. For eight
  hours the sweep called them *probably stuck* and pointed at deleting a
  deployment to release a queue that did not exist.
- **The Worker.** The sweep once printed a clean summary while saying nothing
  about `workers/pick3cut5-room`, which no merge deploys.
- **The alarm** (`REPO-AUDIT.md` G14) was confirmed reaching Nate by email on
  its first red run, 2026-09-03.
- **`gh pr checks`** showed a red "Cloudflare Pages fail" on PRs that deployed
  perfectly for months.

## Pruning

- Measured 2026-09-02 with `remote.origin.prune` and `fetch.prune` both on:
  `git pull origin main` left a dead tracking ref; bare `git pull` and
  `git fetch` pruned it. This section once reasoned from the config to the
  outcome and got it wrong; it was caught twice in one session. The four-command
  manual prune it replaced was being repeated by hand every few PRs.

## D1

- **Local drift.** Local once held 327 skills where the repo and production had
  324, and an audit against it reported two duplicates production had merged
  weeks before. On 2026-08-30 it held 293 against production's 345.
- **Exit codes.** `wrangler d1 execute` has reported a non-zero exit on runs
  that fully applied, and `Authentication error [code: 10000]` on one that
  succeeded. A `--remote` apply was reported as failed because the reader
  choked on wrangler's multi-block JSON.
- **Unrecoverable rows.** Two classes existed only in production for weeks,
  recreatable from nothing in the repo, which is what `drift-check` catches.
- **Backups.** `wrangler d1 export` fails outright here (one fts5 virtual table
  makes the database un-exportable), which is why `d1-backup.mjs` exists. No
  backup is prescribed per apply because a ritual on every one-script apply
  would be skipped within a week.

## Commit messages

- A `-m` message once ran `wrangler d1 execute` and pasted its help output into
  the commit. `commit-msg.tmp` shipped inside PR #404 before `*.tmp` was
  gitignored.
