# CLAUDE.md — nates-workshop

Plain HTML/JS/CSS, zero dependencies, no build step. There is no `package.json`
and no `node_modules`; `npx wrangler` resolves from the npx cache. Merging to
`main` IS the deploy — there is no CI.

App conventions, the data model, and the migration list live in
`apps/character-creator/README.md`. This file covers only what is easy to get
wrong about Cloudflare auth.

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

## Applying migrations

Use the script, not a hand-typed `wrangler d1 execute`:

```bash
node scripts/d1-apply.mjs --remote db/migrations/021-x.sql apps/character-creator/db/backfill-y.sql
```

It requires an explicit `--remote` or `--local`, pre-flights every file (exists,
pure ASCII, no CR) before running any of them, applies in the order given, and
stops at the first failure. Under `CLOUDFLARE_API_TOKEN` it prints
`skipping auth warm-up` and goes straight to applying — expected, not a warning.
