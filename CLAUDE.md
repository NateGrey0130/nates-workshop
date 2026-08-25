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
is the argument for testing rather than quoting: as of 2026-08-25 it does D1 and
reads the account, and it does **not** do R2 or Pages. Check what you need
against the thing itself; this line will drift again.

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

`pages project list` fails the same way and for the same reason, which is why
every Pages and Access change is dashboard work through Nate's Chrome.

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
