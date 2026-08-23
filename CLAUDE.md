# CLAUDE.md — nates-workshop

Plain HTML/JS/CSS, zero dependencies, no build step. There is no `package.json`
and no `node_modules`; `npx wrangler` resolves from the npx cache. Merging to
`main` IS the deploy — there is no CI.

App conventions, the data model, and the migration list live in
`apps/character-creator/README.md`. This file covers the five skills and what is
easy to get wrong about Cloudflare auth.

## Five skills, and they only load from the repo root

`.claude/skills/` holds them. They are **directory-scoped**: a session started
anywhere else — in `Downloads`, say, with the PDF — will not see them, and one
session ran an entire class import by hand for exactly that reason.

| skill | when |
|---|---|
| `book-survey` | handed a sourcebook PDF, before extracting anything from it |
| `class-import` | adding or correcting an O.C.C./R.C.C., or importing skills, spells, psionics or gear |
| `schema-change` | any new D1 table or column — a column lands in **five** places, a table in nine |
| `ship-pr` | branch to deployed, and **whenever a change touches D1**, because data is applied BEFORE the merge |
| `claim-audit` | checking what the docs, comments and class prose say against what the code does |

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

**Do not use `npx wrangler whoami` as a health check.** It exits non-zero here,
and that is correct behaviour, not a broken credential: `whoami` lists accounts,
and the `CLOUDFLARE_API_TOKEN` in use is scoped to Account → D1 → Edit, which
cannot read the account list. Reporting that failure as an auth problem sends
the reader chasing a credential that is working.

Two ways to tell which credential a command used, if it matters: an API token
returns zeros for `read_queries_24h` / `rows_read_24h` in `d1 info` (analytics
need a scope the token lacks), where an interactive OAuth login returns real
counts.

## Auth setup

`CLOUDFLARE_API_TOKEN` (scoped Account → D1 → Edit) and `CLOUDFLARE_ACCOUNT_ID`
are set at **User** scope. The token removes the expired-OAuth failure mode
(`Authentication error [code: 10000]`) that used to hit the first remote call
after idle.

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
portraits). **The `CLOUDFLARE_API_TOKEN` above cannot touch it.** Scoped to
Account -> D1 -> Edit, it has no R2 scope at all - `r2 bucket create` and
`r2 bucket list` both fail identically:

```
A request to the Cloudflare API (/accounts/<id>/r2/buckets) failed.
  Authentication error [code: 10000]
```

Unlike the `whoami` failure above, this one is real: the operation did not
happen. The follow-on line about failing to retrieve account IDs is wrangler's
fallback attempt after the first failure, not a second problem, and the same
D1-scope explanation covers it.

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
