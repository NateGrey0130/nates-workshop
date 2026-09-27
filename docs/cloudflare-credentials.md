# Cloudflare credentials, and what each one reaches

Read this before any Cloudflare call other than D1. None of it is pinned by a
test. **Ask the thing itself** before you act on any line here: every fact
below has drifted at least once.

## Which credential to reach for

| you want | reach for |
|---|---|
| D1, read or write, local or `--remote` | `npx wrangler` under `CLOUDFLARE_API_TOKEN`, via `scripts/d1-apply.mjs` / `q.mjs` |
| a Pages question, or a deployment | the `cloudflare-api` MCP plugin |
| an R2 question (which buckets exist) | the plugin's `cloudflare-bindings` server (`r2_buckets_list`) |
| an Access question | the plugin: `GET` on apps, policies, IdPs, organizations |
| an Access change | per endpoint. See *Access writes* |

`npx wrangler whoami` says where the environment token came from. It says
nothing about the plugin.

## The environment token

- `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set at User scope.
- The token does D1 and reads the account. It does **not** reach R2 or Pages.
  `r2 bucket list` and `pages project list` exit 1 with `Authentication error
  [code: 10000]`, and that failure is real.
- Set it with PowerShell, never the Environment Variables dialog. The dialog
  writes back a stale snapshot and has deleted this token twice.

  ```powershell
  [Environment]::SetEnvironmentVariable('CLOUDFLARE_API_TOKEN','<token>','User')
  [Environment]::GetEnvironmentVariable('CLOUDFLARE_API_TOKEN','User').Length
  ```

  A new value reaches only newly launched processes, so restart Claude Code
  after setting one.

## The MCP plugin

- The desktop app cannot sign in `cloudflare-api`: the redirect URI is refused.
  Run `claude` in a terminal, then `/mcp` → `plugin:cloudflare:cloudflare-api`,
  and confirm with `claude mcp list`. Restart the desktop app, possibly more
  than once. A desktop session showing `needs_auth` while `claude mcp list`
  says `Connected` is not a failed sign-in.
- `execute` runs any HTTP verb, and each call asks for approval. Read the
  method in the code before you approve it.
- Untested and **not to be probed**: `r2_bucket_create`, `r2_bucket_delete`
  (the delete takes every portrait with it). Use `d1_database_query` only if
  you mean to bypass `d1-apply.mjs`'s pre-flight, which you never do.

## Access writes

| call | result |
|---|---|
| `GET` apps / policies / IdPs / organizations | works |
| `DELETE /accounts/{id}/access/policies/{id}` | works (`202`) |
| `PATCH /accounts/{id}/access/apps/{app}` | refused, `10405`, nothing changed |
| anything else | untested |

A refused write changes nothing. For an IdP, a session duration, or the
site-wide login policy, use the dashboard in Chrome. Adding a friend takes more
than one place: see `SETUP.md` → *Access*. Never enable public access on the
`MEDIA` bucket: every portrait read goes through a membership check.

## Permissions

- **Repo allowlist** (`.claude/settings.json`) allows only commands that report
  or query. Merge, push, commit, checkout, `d1-apply.mjs` and `wrangler d1 execute`
  are absent so that each one costs a deliberate keystroke. The `gh api` entry
  is pinned to `commits/`, because a wildcard cannot exclude `-X DELETE`.
  `settings.json` rejects comment keys, so this rationale lives here.
- **Working-directory allowlist**
  (`C:\Users\natha\Projects\workshop\.claude\settings.local.json`) governs
  sessions started there. It is **alone**: neither list reaches the other
  directory (tested). Keep it read-only.
- **Ruleset** `22209348` on `main`: no direct push, 0 required reviews,
  required checks `smoke`/`menus`/`regression`, strict off, no bypass actors.
- **Hook** `guard-bash.sh` is registered in both the repo and the user
  settings. Each copy guards only its own tree, which is why both stay
  (`SKILL-AUDIT` F60).
