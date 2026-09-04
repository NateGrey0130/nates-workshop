# CLAUDE.md — nates-workshop

Plain HTML/JS/CSS, zero dependencies, no build step. There is no `package.json`
and no `node_modules`; `npx wrangler` resolves from the npx cache. Merging to
`main` IS the deploy, and **nothing gates that merge**.

Since 2026-09-03 the five smoke suites also run on every pull request
(`.github/workflows/tests.yml`, `REPO-AUDIT.md` G8). That is **reporting only**:
it is not a required status check, and a red run does not stop a merge.

**`main` does have a ruleset — it just does not gate on CI.** `22209348`,
*"main: require a pull request"*, active since 2026-09-03: one `pull_request`
rule and **zero** required status checks, so a direct push is refused and a red
run is not. It was created five minutes after `G8` merged, and this sentence was
wrong about it for a day (`SKILL-AUDIT` `F29`, 2026-09-04). Ask it rather than
trusting this line — `gh api repos/NateGrey0130/nates-workshop/rulesets`.

So it does not move the rule below — the checks still happen
before the merge or they do not happen — it only means a skipped run gets
noticed afterwards instead of never.

App conventions and the data model live in `apps/character-creator/README.md`.
**The migration list is not there** — it moved to
`apps/character-creator/docs/operations.md` when that README was split, and its
table is the one place each migration says what it adds. This file covers the
skills and what is easy to get wrong about Cloudflare auth.

## Nine skills, and they load from anywhere on this machine

`.claude/skills/` holds them. They are **directory-scoped** by nature: a session
started anywhere else — in the working directory, say, with the PDF — would not
see them, and one session ran an entire class import by hand for exactly that
reason.
That is why each skill is **junction-linked into `~/.claude/skills`** — see the
junction block in `SETUP.md`. They load by name from any working directory now.

**A new skill needs its own link in the same PR that adds it.** Nothing notices
the gap: the skill simply does not exist for a session started outside the repo,
which is the working directory the book work uses.

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
| `book-survey` | handed a sourcebook PDF, before extracting anything from it |
| `class-import` | adding or correcting an O.C.C./R.C.C., or importing skills, spells, psionics or gear |
| `schema-change` | any new D1 table or column — a column lands in **five** places, a table in nine |
| `ship-pr` | branch to deployed, and **whenever a change touches D1**, because data is applied BEFORE the merge |
| `claim-audit` | checking what the docs, comments and class prose say against what the code does |
| `verify-ui` | any CSS, template or layout change, and before calling anything visual done |
| `windows-shell` | before an in-place edit, an inline script with backslashes, or a query whose answer you will act on |
| `pick3cut5` | anything under `apps/pick3cut5/`, `workers/pick3cut5-room/`, `shared/`, or an Access policy |

**Read the skill before the code.** Each one is written from failures that
reached production, and several name the exact wrong turn that is about to look
reasonable.

Three things they will not let you get wrong, listed here because they are the
ones that fail LATE:

- **Filename order is execution order.** A rebuild applies
  `apps/character-creator/db/*.sql` as one sorted glob, so a `fix-` that sorts
  before the file it corrects is silently undone.
- **The README's counts are pinned by the test suite** — classes, skills,
  spells, psionic powers, gear, and a sentence parsed as words. Adding a class
  moves two of them.
- **`--local` is not a mirror of production.** It accumulates. Ask production.

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
`r2 bucket list` and `pages project list` exit 1, so R2 and Pages remain
dashboard-or-Chrome work and the R2 section below stands.

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
`cloudflare-api` MCP plugin, which authenticates separately — see *Three
credentials* under the R2 section. The two facts lived in one sentence here for
weeks and only the first half was ever true.

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
fact about this token, and it is no longer a fact about Pages.**

### Three credentials, and only one of them is the token

| you want | reach for |
|---|---|
| D1 — read or write, local or `--remote` | `npx wrangler`, under `CLOUDFLARE_API_TOKEN` |
| a Pages question, or a deployment | the **`cloudflare-api` MCP plugin** |
| Access policies, destinations, the dashboard | Nate's Chrome |

The plugin authenticates **separately from the environment token** and is enabled
in `~/.claude/settings.json`. On 2026-09-02 it served the project, the full
deployment list with `latest_stage` and `stages[]`, a deployment's build logs,
and a `DELETE` on a wedged deployment — which is how a stalled build was
diagnosed and cleared in one call, where this file's advice was a hand-off. See
`HEALTH-AUDIT.md` F24.

**Access was NOT tested and stays Chrome work.** The sentence this replaces
coupled "Pages and Access" and only the Pages half has been exercised; do not
assume the plugin reaches Access policies.

This changes nothing about the token and widens nothing — the plugin's reach
already existed and this file was simply wrong about it. It does mean the
*"let `whoami` tell you which credential answered"* rule above now has a second
credential to be explicit about: `whoami` describes the environment token and
says nothing about the plugin. And a Pages **deploy** through it would still be
the deliberate keystroke the allowlist section argues for, exactly as
`d1-apply.mjs` is.

Creating or listing a bucket needs **Workers R2 Storage -> Edit** added to the
token, or the Cloudflare dashboard. Widening the token is the bigger decision of
the two, since the same variable is what every `d1 execute --remote` in this
repo runs under.

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
pure ASCII, no CR) before running any of them, applies in the order given, and
stops at the first failure. Under `CLOUDFLARE_API_TOKEN` it prints
`skipping auth warm-up` and goes straight to applying — expected, not a warning.

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

### And since 2026-09-03 the allowlist is no longer the only thing holding that line

`git push` being absent above stops **an agent in this repo**. It is a
client-side convention on one machine, and it stopped nothing else: not a
session started elsewhere, not a push by hand, not a second machine.

There is now a GitHub **ruleset** on `main` — *"main: require a pull request"* —
that refuses a direct push server-side (`REPO-AUDIT.md` G1). Exactly one rule,
and the list of what it does **not** do is the point:

| | |
|---|---|
| required approving reviews | **0** — self-merge works |
| required status checks | **none**, and the `tests` workflow is deliberately not one |
| conversation resolution | not required |
| linear history, signed commits, deletion, force-push rules | not enabled |
| bypass actors | **none** |

**So the merge button is exactly as free as it was, and only the bypass is
gone.** If anything about merging got harder, that is a defect rather than the
rule working.

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
