# CLAUDE.md — nates-workshop

> Pinned by `test/checks/documented-counts.mjs` (the skill table, the count in
> words, "load from anywhere") and `instruction-paths.mjs` (every absolute path
> resolves). Rules only. History lives in git, PR bodies and the audit menus.

Plain HTML/JS/CSS, no build step, no `package.json`. `npx wrangler` resolves
from the npx cache. **Merging to `main` is the deploy.** `main` refuses direct
pushes. A merge needs `smoke`, `menus` and `regression` green; ask the ruleset
itself: `gh api repos/NateGrey0130/nates-workshop/rulesets/22209348`.

## Three groups, and which one you are in

Three groups plus what they share, and `process` for what belongs to none of them: **palladium** (character creator and the
apps split from it), **marvel** (`marvel-heroes`), and **tools** (FilamentForge,
MediaVault, Pick 3 Cut 5). `groups.json` owns every path and D1 table.

- `node scripts/groups.mjs <path>` gives the owner of one path.
  `node scripts/groups.mjs --affected origin/main...HEAD` shows what CI will run.
- One session per group, each in its own worktree:
  `node scripts/group-worktree.mjs <palladium|marvel|tools>`. See the
  `worktree` skill.
- A **shared** path runs every group's suites. The shared paths are `shared/`,
  the middleware, `apps/manifest.json`, `functions/api/claude.js`, `SETUP.md`
  and the workflows. Change a shared path in its own PR, never inside a
  group's work.
- Each group has its own D1: `DB` (`db/schema.sql`), `DB_MARVEL`
  (`db/schema-marvel.sql`) and `DB_TOOLS` (`db/schema-tools.sql`). Server code
  reaches only its own binding.
- A new file must have an owner in `groups.json`. If you are unsure, use `shared`.

## Before you open a PR, and again before you merge

1. `git fetch origin` then `git diff --name-only HEAD...origin/main`. If
   `main` moved and touched any path you touched, or any shared path, merge
   `origin/main` into your branch and re-run the suites before you push.
2. Name the branch and title by *Naming* below. Check that the name is free.
3. D1 changes are applied **before** the merge (`ship-pr`). Nate merges.

## Naming

Branch: `<group>/<type>/<slug>`. group: `pal|msh|tools|shared|proc`, where
`proc` is `groups.json`'s `process` owner (docs, audit menus, this file). type:
`feat|fix|data|schema|docs|test|skill|audit`. slug: kebab-case, 40 characters
at most. A book's slug starts with the book's (`pal/data/triax-ngr-police`),
because `book-board.mjs` finds book work by that prefix. A finding's slug
starts with its menu (`proc/audit/skill-audit-f64-pressure-test`).
PR title: `[<group>/<type>] Sentence-case summary`. Commits: the summary
alone, imperative.

Before you create a branch, all three of these must print nothing:

```bash
git branch --list "<name>"; git ls-remote --heads origin "<name>"; gh pr list --state all --head "<name>" --json number
```

The group must match `groups.mjs --affected`. Any `shared` path forces
`shared`, and a diff spanning two groups is two PRs or it is `shared`. Sequence numbers (`db/migrations/NNN-`, data scripts `~NNN-`, audit
`F<n>`) are **claimed at merge**. Re-read `origin/main` for the highest number
immediately before the merge, never earlier.

## Fourteen skills, and they load from anywhere on this machine

Each one lives in `.claude/skills/` and is junction-linked into
`~/.claude/skills` (`SETUP.md` → junction block). A new skill needs its link in
the same PR, and a pressure test before it merges (`test-suite` → *A skill is
a check too*). Agents are in `.claude/agents/`, and the whole directory is
linked. An agent written mid-session cannot be spawned until the next turn.

| skill | when |
|---|---|
| `audit-menu` | reading or writing an audit file, and whenever a numbered finding is taken |
| `take` | `/take <MENU> <ID>` — subject grep, then premise auditor, then the branch |
| `book-survey` | handed a sourcebook PDF, before extracting anything |
| `class-import` | adding or correcting an O.C.C./R.C.C., or importing skills, spells, psionics or gear |
| `schema-change` | any new D1 table or column: a column lands in five places, a table in nine |
| `ship-pr` | branch to deployed, and **whenever a change touches D1** |
| `claim-audit` | checking what docs, comments and class prose say against the code |
| `verify-ui` | any CSS, template or layout change, before calling it done |
| `test-suite` | adding or changing a check, pinning a count, reading a failure |
| `windows-shell` | before an in-place edit, an inline script with backslashes, or a query you will act on |
| `worktree` | a second concurrent session, and **before `git worktree remove`** |
| `pick3cut5` | `apps/pick3cut5/`, `workers/pick3cut5-room/`, `shared/`, or an Access policy |
| `media-vault` | `apps/media-vault/`, `functions/api/media-vault/`, `media_items`, `media_shares` |
| `app-suite` | adding an app, `apps/manifest.json`, the hub, the app switcher |

Read the skill before the code.

## Three things that fail late

- **Filename order is execution order.** A rebuild applies
  `apps/character-creator/db/*.sql` as one sorted glob, so a `fix-` that sorts
  before the file it corrects is silently undone.
- **Each book's row counts are pinned** on the `**Rows citing this book:**`
  line of its survey. A data PR updates its own book's line. `regression`
  prints the line to paste.
- **`--local` is not a mirror of production.** It accumulates. Ask production.

## When a check goes red

Before the edit that turns it green, write down two things. First, the cause
as a mechanism. Second, every table that cause wrote to, marking which ones a
check reads. You can find those tables with
`grep -l -i "<book name>" apps/character-creator/db/*.sql`. Sweep the unread
ones, or say in the PR body that you did not.

## D1 and Cloudflare

- Apply with `node scripts/d1-apply.mjs --remote|--local [--db marvel|tools] <files…>`,
  never with a hand-typed `wrangler d1 execute`. `skipping auth warm-up` is expected.
- `npx wrangler d1 info nates-workshop-media` is the health check.
- `CLOUDFLARE_API_TOKEN` reaches D1 only, not R2 or Pages. Pages, R2 and Access
  go through the `cloudflare-api` / `cloudflare-bindings` MCP plugin. Read
  `docs/cloudflare-credentials.md` **before** any Cloudflare call other than D1,
  and before any Access write.
- Never enable public access on the R2 bucket.

## Permissions and the hook are deliberate

`.claude/settings.json` allows only reporting commands. `d1-apply.mjs`,
`gh pr create/merge`, `git push/commit/checkout` and `wrangler d1 execute` are
absent **on purpose**. Do not add them, and do not widen the `gh api` entry.
`.claude/hooks/guard-bash.sh` refuses six command shapes. It is also registered
at user level in `C:\Users\natha\.claude\settings.json`, so it runs twice in
this repo, and that is intended. A refusal appears as
`PreToolUse:Bash hook error: … guard-bash: <reason>`. Rationale:
`docs/cloudflare-credentials.md` → *Permissions*.
