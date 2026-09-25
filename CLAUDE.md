# CLAUDE.md — nates-workshop

> **What pins this file:** `apps/character-creator/test/checks/documented-counts.mjs`
> asserts the skill table below — every skill named, no skill named that does not
> exist, the count stated in words, and that this file still says they load from
> anywhere. `apps/character-creator/test/checks/instruction-paths.mjs` asserts that
> every absolute path it names resolves.
>
> **Everything else here is prose and is pinned by nothing.** The Cloudflare
> sections say so themselves and give the command to ask instead.

Plain HTML/JS/CSS, zero dependencies, no build step. There is no `package.json`
and no `node_modules`; `npx wrangler` resolves from the npx cache. Merging to
`main` IS the deploy, and **since 2026-09-16 CI blocks that merge**.

The smoke suites run on pull requests (`.github/workflows/tests.yml`,
`REPO-AUDIT.md` G8, since 2026-09-03) and so does `regression.mjs`
(`regression.yml`, since 2026-09-04). **Since 2026-09-25 not every suite runs
on every pull request** — see *Three groups* below: the character creator's
smoke suite and the menu check always do, and the rest run for the group a
change touches. **Their three check-runs — `smoke`,
`menus`, `regression` — are required status checks** on `main`'s ruleset
`22209348`, *"main: require a pull request"*: the merge button is disabled and
`gh pr merge` is refused until all three report success. `play-flow` and
`deploy-alarm` are still reporting only. From 2026-09-03 to 2026-09-16 the
ruleset carried **zero** required checks and every line here said so; the
sentence before that denied the ruleset existed (`SKILL-AUDIT` `F29`). Ask it
rather than trusting this paragraph —
`gh api repos/NateGrey0130/nates-workshop/rulesets/22209348`.

That does not move the rule below — the checks still run
before the merge, and step 4 of `ship-pr` is still yours — it means a red run
now stops the merge instead of being noticed afterwards.

## Three groups, and which one you are in

The repo is three unrelated groups plus what they share: **Palladium** (the
character creator and the five apps split from it), **Marvel**
(`marvel-heroes`), and **tools** (FilamentForge, MediaVault, Pick 3 Cut 5).
`groups.json` at the root says which group owns every path and every D1 table,
and `node scripts/groups.mjs <path>` answers for one file. The point is that
sessions on different groups can run at once without colliding.

- **One session per group, each in its own worktree** —
  `node scripts/group-worktree.mjs <palladium|marvel|tools>` makes one, and the
  `worktree` skill has the rest.
- **CI runs a group's suites only when that group, or a shared path, changed**
  (`node scripts/groups.mjs --affected origin/main...HEAD` shows what a branch
  will run). `regression` and `play-flow` are Palladium's; a tools-only pull
  request skips them and says so in the log, and the check still reports.
  The character creator's smoke suite runs on everything, because it also pins
  every skill, agent, audit menu and app tile.
- **A shared path runs every group's suites** — `shared/`, the middleware,
  `db/schema.sql`, `apps/manifest.json`, `SETUP.md`, the workflows. Change one
  in a pull request of its own, not inside a group's work.
- **A new file must have an owner.** `groups.mjs --check` runs in `smoke` and
  fails on a path no entry covers. When unsure, the owner is `shared`.

App conventions and the data model live in `apps/character-creator/README.md`.
**The migration list is not there** — it moved to
`apps/character-creator/docs/operations.md` when that README was split, and its
table is the one place each migration says what it adds. This file covers the
skills and what is easy to get wrong about Cloudflare auth.

## Fourteen skills, and they load from anywhere on this machine

`.claude/skills/` holds them. They are **directory-scoped** by nature: a session
started anywhere else — in the working directory, say, with the PDF — would not
see them, and one session ran an entire class import by hand for exactly that
reason.
That is why each skill is **junction-linked into `~/.claude/skills`** — see the
junction block in `SETUP.md`. They load by name from any working directory now.

**A new skill needs its own link in the same PR that adds it.** Nothing notices
the gap: the skill simply does not exist for a session started outside the repo,
which is the working directory the book work uses.

**A new or changed skill is also pressure-tested before it merges.** Run a
realistic scenario through fresh subagents before the edit and again after
it, and put what each run did in the PR body. `test-suite` → *A skill is a
check too* has the method (`SKILL-AUDIT` `F64`). Run it in the **main
checkout**, and run the "before" half first. The junctions point there and at
no worktree, so an edit saved in the main checkout reaches every subagent **in
the same turn**. It arrives **after a delay, though, not on save**. Measured
2026-09-23: a probe spawned two tool calls after the edit loaded the old text.
The session then showed a skill-listing refresh, and the next probe loaded the
new text. Wait for that refresh before running the "after" half.

**The agents directory is linked too, since 2026-08-28** (`INGESTION-AUDIT` F8),
when `book-reconcile` was the only agent in it. There are more now — `ls
.claude/agents/` is the list, and it is the **only** list; nothing enumerates
them, so a count written here would rot the next time one lands.
`book-survey` §5 can spawn `book-reconcile` from the working directory, the one
place the book work runs — `C:\Users\natha\Projects\workshop` since 2026-09-02
(`MACHINE-AUDIT.md` M7/M9/M12), and `Downloads` before that. The link is to the
whole directory, so it followed the move without being touched. Until it existed
the spawn could not happen at all: `~/.claude/agents` was not there.

The agents link is the **whole directory**, not one entry per file, because an
agent is a file and a junction only works on a directory — the per-file symlink
needs administrator rights on this machine. So a new agent is covered the moment
its file lands, and `~/.claude/agents` cannot hold anything that is not in this
repo. See the junction block in `SETUP.md`.

**Covered is not usable, and the gap costs a session that does not know it.** An
agent file written mid-session **cannot be spawned in that session**: the
junction shows it instantly and a spawn still answers `Agent type '<name>' not
found` until the next turn. Measured 2026-09-04 (`SKILL-AUDIT` `F26`) — three
attempts across 82 seconds and ten tool calls, five test suites among them, all
`not found`; it is the turn, not elapsed time and not tool calls. **Write the
agent in one pass and use it in the next**, and do not build a plan that spawns
something it just wrote.

| skill | when |
|---|---|
| `audit-menu` | reading or writing an audit file, and whenever a numbered finding is taken |
| `take` | `/take <MENU> <ID>` — the moment a finding is taken: subject grep across every menu, then the premise auditor, then and only then the branch. Adds no rule; fixes the order |
| `book-survey` | handed a sourcebook PDF, before extracting anything from it |
| `class-import` | adding or correcting an O.C.C./R.C.C., or importing skills, spells, psionics or gear |
| `schema-change` | any new D1 table or column — a column lands in **five** places, a table in nine |
| `ship-pr` | branch to deployed, and **whenever a change touches D1**, because data is applied BEFORE the merge |
| `claim-audit` | checking what the docs, comments and class prose say against what the code does |
| `verify-ui` | any CSS, template or layout change, and before calling anything visual done |
| `test-suite` | adding or changing a check, pinning a count, reading a failure, or splitting a checks module — a seventh of the commits here land in these files |
| `windows-shell` | before an in-place edit, an inline script with backslashes, or a query whose answer you will act on |
| `worktree` | a second concurrent session, and **before `git worktree remove`** — one removal emptied the main checkout's book caches |
| `pick3cut5` | anything under `apps/pick3cut5/`, `workers/pick3cut5-room/`, `shared/`, or an Access policy |
| `media-vault` | anything under `apps/media-vault/` or `functions/api/media-vault/`, and any change touching `media_items` or `media_shares` |
| `app-suite` | adding an app, editing `apps/manifest.json`, the hub, the app switcher, or splitting an app in two |

**Read the skill before the code.** Each one is written from failures that
reached production, and several name the exact wrong turn that is about to look
reasonable.

Three things they will not let you get wrong, listed here because they are the
ones that fail LATE:

- **Filename order is execution order.** A rebuild applies
  `apps/character-creator/db/*.sql` as one sorted glob, so a `fix-` that sorts
  before the file it corrects is silently undone.
- **Each book's row counts are pinned by the test suite**, on the
  `**Rows citing this book:**` line of its survey. Since 2026-09-24 they
  replace the catalog totals the README and `docs/operations.md` used to
  pin. A data PR updates its own book's line, and `regression` prints the
  line to paste when it is wrong.
- **`--local` is not a mirror of production.** It accumulates. Ask production.

**When a check goes red, the rows it names are not the whole cause.** Before
the first edit that turns it green, write two lines:

1. **The cause, as a mechanism.** For example, "this book's cache sets 0 as O",
   not "this row has a typo".
2. **Every table that cause wrote to, marking which ones any check reads.**
   For a book, including tables imported by earlier PRs:

   ```bash
   grep -l -i "<book name as printed>" apps/character-creator/db/*.sql
   ```

Sweep the unread tables, or say in the PR body that you did not.

## Health check

```bash
npx wrangler d1 info nates-workshop-media
```

`d1 info` is the health check because it exercises what you actually need — a
real call against the real database. Prefer it on those grounds.

**Two things this section used to say are no longer true.** Both were re-measured
on 2026-08-25 rather than reasoned about:

- It said `npx wrangler whoami` **exits non-zero here by design**, the token
  being unable to read the account list. It now **exits 0** and prints the
  account name and ID.
- It said an API token returns **zeros** for `read_queries_24h` / `rows_read_24h`
  in `d1 info`, so real counts meant an interactive OAuth login. `d1 info` now
  returns real counts under the environment token, so that tell is gone. Use
  `whoami` instead — it states outright where the credential came from
  (*"The API Token is read from the CLOUDFLARE_API_TOKEN environment variable"*),
  which beats inferring it from analytics.

The token has been widened at some point beyond the Account → D1 → Edit it was
originally cut with. **What it still cannot do was re-tested and holds:** both
`r2 bucket list` and `pages project list` exit 1, so **this token** does not
reach R2 or Pages. Both are reachable anyway, through the Cloudflare MCP plugin
— see *Three credentials* under the R2 section.

The lesson that outlived the facts: **a failing wrangler command here is not
automatically a broken credential, and a succeeding one is not proof the
credential is the one you assume.** Ask for the specific thing you need, and let
`whoami` tell you which credential answered.

## Auth setup

`CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set at **User** scope. The
token removes the expired-OAuth failure mode (`Authentication error [code:
10000]`) that used to hit the first remote call after idle.

It was cut as Account → D1 → Edit and is **wider than that now** — it reads the
account list, which the original could not. Nobody wrote down when or why, which
is the argument for testing rather than quoting: re-tested **2026-09-02**, it
does D1 and reads the account, and it does **not** do R2 or Pages. Check what you
need against the thing itself; this line will drift again.

**"The token cannot" is not "this repo cannot."** Pages is reachable through the
`cloudflare-api` MCP plugin and R2 through `cloudflare-bindings`, both of which
authenticate separately — see *Three credentials* under the R2 section. The two
facts lived in one sentence here for weeks and only the first half was ever
true, and R2 repeated the mistake until 2026-09-22.

Set them with PowerShell, not the Windows Environment Variables dialog:

```powershell
[Environment]::SetEnvironmentVariable('CLOUDFLARE_API_TOKEN','<token>','User')
```

The dialog holds a snapshot of the whole variable set taken when it opened and
writes that snapshot back on OK — a second dialog open anywhere silently
deletes variables added since. It ate this token twice.

Env vars reach only newly launched processes. After setting one, restart Claude
Code before expecting a session to see it. To confirm the write immediately,
read the registry rather than the process:

```powershell
[Environment]::GetEnvironmentVariable('CLOUDFLARE_API_TOKEN','User').Length
```

## R2 is NOT reachable with the D1 token

The site binds one R2 bucket, `nates-workshop-media`, as `MEDIA` (NPC
portraits). **The `CLOUDFLARE_API_TOKEN` above cannot touch it** - re-tested
2026-08-25, and still true after the token was widened enough to read the
account list. It has no R2 scope at all; `r2 bucket create` and `r2 bucket list`
both exit 1 and fail identically:

```
A request to the Cloudflare API (/accounts/<id>/r2/buckets) failed.
  Authentication error [code: 10000]
```

**This failure is real: the operation did not happen.** Worth stating because it
is the one wrangler failure here that means what it says - and because the
health-check section above no longer has a *harmless* failure to contrast it
with, `whoami` having started succeeding. The follow-on line about failing to
retrieve account IDs, and the `User->Memberships->Read` warning, are wrangler's
fallback attempts after the first failure rather than separate problems.

`pages project list` fails the same way and for the same reason. **That is a
fact about this token, and it is no longer a fact about Pages — or about R2.**
The heading means the token, not the bucket: see the table below.

### Three credentials, and only one of them is the token

| you want | reach for |
|---|---|
| D1 — read or write, local or `--remote` | `npx wrangler`, under `CLOUDFLARE_API_TOKEN` |
| a Pages question, or a deployment | the **`cloudflare-api` MCP plugin** |
| an R2 **question** — which buckets exist | the plugin's **`cloudflare-bindings`** server. It lists them |
| an Access **question** — who is allowed, which IdPs, how long a session lasts | the **plugin**. It reads Access |
| an Access **change** | **per endpoint** — one write is measured to work, one to fail. Read the block below before assuming either |

The plugin authenticates **separately from the environment token** and is enabled
in `~/.claude/settings.json`. On 2026-09-02 it served the project, the full
deployment list with `latest_stage` and `stages[]`, a deployment's build logs,
and a `DELETE` on a wedged deployment — which is how a stalled build was
diagnosed and cleared in one call, where this file's advice was a hand-off. See
`HEALTH-AUDIT.md` F24.

**Signing `cloudflare-api` in cannot be done from the desktop app.** Its `/mcp`
sign-in sends a `claude://` redirect URI, and `mcp.cloudflare.com` refuses it
before the login page: *"Redirect URI must use HTTPS or a local loopback
address"*, `invalid_request`. Seen 2026-09-22. The plugin's other servers
(`cloudflare-bindings`, `-builds`, `-observability`) sit on their own hosts,
accept the same redirect, and sign in from the desktop app normally. So:

1. run `claude` in a terminal, `/mcp`, pick `plugin:cloudflare:cloudflare-api`,
   authenticate — the CLI uses a `localhost` redirect, which is accepted;
2. confirm it there with `claude mcp list`, which should say `Connected`;
3. restart the desktop app. **Expect more than one restart:** on 2026-09-22 one
   restart left the desktop session at `needs_auth` while `claude mcp list`
   already said `Connected`. The tools appeared on 2026-09-23 after a Claude
   Code update and a second restart, and served the Pages project, its
   deployments and the Access apps.

A desktop session's `needs_auth` therefore does not mean the sign-in failed.
Ask `claude mcp list` before signing in again.

The server exposes **three tools, and one of them is every verb**: `search`
reads the API spec, `docs` reads documentation, and `execute` runs code that
calls `cloudflare.request()` with any method — `GET` through `DELETE`, on any
endpoint the credential reaches. No allowlist entry covers it, so each call
asks. Read the method in the code before approving; the prompt is the only
place a write is visible ahead of time.

**Access has now been tested twice, and the second test broke the first one's
conclusion.** This block said *"the plugin READS it and cannot WRITE it"* from
2026-09-05 until 2026-09-09, when a reusable-policy `DELETE` went straight
through. **The blanket was wrong, and the replacement is not another blanket:
the boundary is per ENDPOINT**, and only three have ever been tried.

| call | result | measured |
|---|---|---|
| `GET` — apps, an app's policies, identity providers, organizations | serves, unprompted by any dashboard session | 2026-09-05 |
| `DELETE /accounts/{id}/access/policies/{id}` | **`202`, and a read-back showed the policy gone** | 2026-09-09 |
| `PATCH /accounts/{id}/access/apps/{app}` | `10405: Method not allowed for this authentication scheme`, app unchanged afterwards | 2026-09-05 |

What the `GET`s serve: all three applications with `session_duration`,
`allowed_idps` and `auto_redirect_to_identity`; an app's policies and the
addresses they admit; the configured IdPs; and the team domain from
`access/organizations`, which is what a new IdP's redirect URI is built from.
**The address count moves whenever Nate adds someone — read it, do not quote a
number back out of this file.**

**Everything else is UNTESTED**, and the list is longer than the tested one:
creating a policy, updating one, changing an IdP, changing a session duration,
touching a destination. A probe of create-and-update against a throwaway policy
attached to no application was **refused by this machine's own permission
classifier** on 2026-09-09, so that gap is recorded rather than closed. It is a
gap in what anyone here knows, not evidence of a limit.

**`10405` is about the credential and not the endpoint**, which is why one
refusal never generalised to the rest of Access — and a refused write costs the
call and nothing else, because it fails before it changes anything.

The practical shape is therefore no longer *diagnose here, change there*. It is:
**ask the endpoint you actually need.** A read is free. A write may work, and
the failure mode is a clean refusal rather than a half-done change. Reach for
Chrome when the write is one you would not want to discover the hard way — an
IdP, a session duration, the policy the whole site logs in through.

This changes nothing about the token and widens nothing — the plugin's reach
already existed and this file was simply wrong about it. It does mean the
*"let `whoami` tell you which credential answered"* rule above now has a second
credential to be explicit about: `whoami` describes the environment token and
says nothing about the plugin. And a Pages **deploy** through it would still be
the deliberate keystroke the allowlist section argues for, exactly as
`d1-apply.mjs` is.

**Listing buckets no longer needs the token or the dashboard.** On 2026-09-22
the plugin's `cloudflare-bindings` server — a separate OAuth sign-in from
`cloudflare-api` — returned `nates-workshop-media` from `r2_buckets_list`. That
is the **only** R2 call measured. The same server also carries
`r2_bucket_create` and `r2_bucket_delete`, and they are **untested**, like most
of Access above; do not reach for either to find out, since a bucket delete
takes every portrait with it. Its `d1_database_query` would also write
production D1 around `d1-apply.mjs` and its pre-flight — use the script.

Creating a bucket by a route someone has actually tested still needs **Workers
R2 Storage -> Edit** added to the token, or the Cloudflare dashboard. Widening
the token is the bigger decision of the two, since the same variable is what
every `d1 execute --remote` in this repo runs under.

**Do not enable public access on the bucket.** The whole site sits behind
Access, and every portrait read goes through a Pages Function that checks
campaign membership first; a public bucket URL would be the one unauthenticated
hole in the site.

## Applying migrations

Use the script, not a hand-typed `wrangler d1 execute`:

```bash
node scripts/d1-apply.mjs --remote db/migrations/021-x.sql apps/character-creator/db/backfill-y.sql
```

It requires an explicit `--remote` or `--local`, pre-flights every file (exists,
pure ASCII, no CR, and since 2026-09-16 its read-back assertions evaluated in a
scratch replay of the data directory) before running any of them, applies in
the order given, and stops at the first failure — including a read-back
assertion that fails on the target after its file is applied. Under `CLOUDFLARE_API_TOKEN` it prints
`skipping auth warm-up` and goes straight to applying — expected, not a warning.

**Which database is `--db`'s question**, and without it the answer is
Palladium's (`DB`), as it always was. A group whose tables have moved to its own
D1 is reached with `--db marvel` or `--db tools`, and so are `q.mjs` and
`d1-backup.mjs`; `drift-check.mjs` checks every group's database on its own.

## The permission allowlist is read-only, and its gaps are the point

`.claude/settings.json` allows the tests, the reporting scripts, and read-only
`git` and `gh`. Everything on it either reports or asks a question.

**What is deliberately absent, so nobody reads it as an oversight and "fixes" it:**
`scripts/d1-apply.mjs` — the script directly above, which writes production —
plus `gh pr merge`, `gh pr create`, `git push`, `git commit`, `git checkout`, and
every `wrangler d1 execute`. Those are the actions worth stopping for. A merge
here IS the deploy, and an apply moves the live database before the merge that
needs it; both should cost a deliberate keystroke.

The `gh api` entry is pinned to this repo's `commits/` path rather than written
as `gh api *`, because a prefix wildcard cannot exclude a `-X DELETE` and the
commits API has no write verbs. **Do not widen it.**

**Comments do not survive in this file.** `settings.json` is validated against a
schema that rejects unrecognised top-level keys, so the `"//"` convention that
`.claude/launch.json` uses is refused there — which is why this explanation lives
here instead. See `HEALTH-AUDIT.md` F6.

**Since 2026-09-16 the same file also carries a `PreToolUse` hook.**
`.claude/hooks/guard-bash.sh` runs before every `Bash` call and exits 2 with a
one-line reason for six command shapes that used to be prose rules: `git add
-A` / `git add .`, `sed -i` on a path under the repo, `q.mjs` or `d1-apply.mjs`
with neither `--local` nor `--remote`, `gh pr merge` sharing a call with anything
else, `git commit -m` with a backtick in it, and — since 2026-09-22 — `find`
rooted at a drive root. The script's header names the
incident behind each rule. **A refusal is the hook rather than a permission
denial, but it does NOT start `guard-bash:`** — Claude Code wraps the hook's
stderr, so a transcript carries `PreToolUse:Bash hook error: [<the registered
command>]: guard-bash: <reason>`. Grep for the wrapper, never for a leading
`guard-bash:`; `SKILL-AUDIT` `F55` and `F54` each built a count on that string
and each got it wrong, in opposite directions.

**Unlike the allowlist above, the hook is NOT project-scoped.** Since
2026-09-22 it is registered at user level in
`C:\Users\natha\.claude\settings.json` with an absolute path, so it governs
every directory on this machine — which is the point, because the book work
runs from `C:\Users\natha\Projects\workshop` and that is where a session
started outside the repo used to run unguarded.
`apps/character-creator/test/checks/hook-registration.mjs` pins the user-level
registration locally and asserts nothing in CI, where the file does not exist.

**The repo's registration is still live too, so a session started here runs the
hook twice, and that is DELIBERATE** — `SKILL-AUDIT` `F60` proposed removing it
and was declined on measurement, 2026-09-22. The two are not interchangeable:
each copy of `guard-bash.sh` guards only the tree it lives in, so in a git
worktree the repo's registration is the one that guards the worktree. The repo
block is also the only half that is checked in — `SETUP.md` documents no hook at
all, so nothing tracked would tell a second machine that the user-level
registration has to exist. **Do not remove it without reading `F60`'s note.**

### And since 2026-09-03 the allowlist is no longer the only thing holding that line

`git push` being absent above stops **an agent in this repo**. It is a
client-side convention on one machine, and it stopped nothing else: not a
session started elsewhere, not a push by hand, not a second machine.

There is now a GitHub **ruleset** on `main` — *"main: require a pull request"* —
that refuses a direct push server-side (`REPO-AUDIT.md` G1). Two rules since
2026-09-16, and the list of what it does **not** do is still the point:

| | |
|---|---|
| required approving reviews | **0** — self-merge works |
| required status checks | **`smoke`, `menus`, `regression`** (GitHub Actions), since 2026-09-16; `play-flow` and `deploy-alarm` are not |
| strict (branch must be up to date with `main`) | **off** — a merge under an open PR does not force a rebase |
| conversation resolution | not required |
| linear history, signed commits, deletion, force-push rules | not enabled |
| bypass actors | **none** |

**So the merge button waits for three green checks and is otherwise as free as
it was.** A merge refused for any other reason is a defect rather than the rule
working.

**It is not a lock-out.** An admin can delete or disable the ruleset from the
repository's Rules settings in seconds, which is the escape hatch the emergency
direct push used to be — and that hatch was measured before this went in: **21
direct pushes, all of them between 2026-04-18 and 2026-04-26**, the repo's first
nine days, and **none in the four months and ~600 pull requests since.**

**A caution about measuring that yourself**, because the obvious command is
misleading: `git log --first-parent --no-merges main` reports **138** commits
here, and **117 of them are squash-merged pull requests** carrying a `(#N)`
suffix. Squash merges reach `main` without a merge *commit* while still going
through a PR. Filter on the suffix, or you will conclude this repo has been
pushed to directly a hundred times.

### There is a SECOND allowlist, and it is not this one

`C:\Users\natha\Projects\workshop\.claude\settings.local.json` — untracked,
accumulated by approval. It is the project settings for a session started in the
working directory, which this file calls the one place the book work runs. **It
moved there with everything else on 2026-09-02** (`MACHINE-AUDIT.md`
M7/M9/M12); the path it had before the move no longer exists, and neither does
the `.claude` directory that held it.

**Pruned 2026-09-02.** It held wildcards for every action the section above
withholds on purpose — `npx wrangler *`, `gh pr *`, `git push *`, `git commit *`,
`git add *`, `git reset *`, `git checkout *` — plus `gh api *` in the exact form
this file says not to write, and `python -c ' *` / `node -e ' *` for arbitrary
code. **Fifteen entries removed** (273 → 258), backed up beside the file. What
stayed is read-only: `git fetch`, `git ls-remote`, `git check-ignore` and some
`Read()` paths.

**So the two lists now agree in posture**, which they did not before: writes and
arbitrary execution ask, wherever the session started. A further ~45 entries are
literal command strings pinned to session scratchpad directories that no longer
exist; they are dead rather than dangerous and were left alone.

**Established:** the file is scoped to the working directory rather than to this
repo, and had **stopped growing on 2026-08-28** — unchanged across a long
working session on 2026-09-02, before the prune. That scoping is why the move
carried it: it belongs to the directory, not to the repo.

**Established 2026-09-03, by running the test rather than reasoning about it:
each directory is governed by its OWN project settings, and they do not
compose.** A session started in the working directory is governed by
`workshop\.claude\settings.local.json` alone; a session started here is governed
by this repo's `.claude/settings.json` alone. Neither list reaches the other
directory.

Four cells, each a `claude -p` run whose `Bash` call was either permitted or
refused:

| session started in | probe | on this repo's list | on the working directory's | result |
|---|---|---|---|---|
| the repo | `node --check <file>` | **yes** | no | **allowed** |
| the repo | `git --version` | no | **yes** | **refused** |
| the working directory | `node --check <file>` | **yes** | no | **refused** |
| the working directory | `git --version` | no | **yes** | **allowed** |

**So the section above means what it says.** The actions this repo withholds on
purpose are withheld from a session started here, and the working directory's
258 entries cannot widen them. That was the reassuring possibility and it is the
true one — but it was worth testing, because the opposite would have meant every
gap above was decorative whenever work started one directory over.

**What this does NOT settle:** whether a *subdirectory* of a project inherits its
parent's settings, and anything about `--add-dir`. Neither was tested.
`SKILL-AUDIT.md` F12 carries the method, the probe pair, and why an earlier
attempt concluded the test was impossible when it was not.

That question is now less load-bearing than it was — both lists withhold the
same actions — but it is still the difference between a posture and a
guarantee, and the file starts accumulating again the next time something is
approved. See `SKILL-AUDIT.md` F12.
