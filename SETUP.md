# Nate's Workshop — Deployment Reference

> **Pinned sentences, not a pinned file.** `documented-counts.mjs`,
> `environment.mjs` and `smoke.mjs` (character creator), `apps/pick3cut5/test/smoke.mjs`
> and `apps/media-vault/test/smoke.mjs` each read one passage here, and
> `instruction-paths.mjs` resolves every absolute path. Everything else is
> prose: ask the thing it describes before acting on it. History is in
> `git log -- SETUP.md` and the audit menus, not here.

How the deployment is configured and what to touch when adding to it. Working
*in* the repo is `CLAUDE.md`; Cloudflare credentials are
`docs/cloudflare-credentials.md`; the character creator is its own README.

## Where it lives

<https://nates-workshop.pages.dev>, named by `"name": "nates-workshop"` in
`wrangler.jsonc`. Pages publishes the repo root and rewrites nothing, so an
app is at `/apps/<slug>/`.

**Cloudflare Access fronts every route, `/api/*` included.**

| From | What you get |
|---|---|
| a browser you are logged into | the app |
| `curl`, a script, an automated browser | **302 to the Access login wall** |
| either, on a Pick 3 Cut 5 bypass path | the real response |

A 302 is the wall working, not the site down. To ask production a question,
query D1 (`scripts/q.mjs --remote`) rather than fetching a page. Two things fetch
it on purpose: `node apps/pick3cut5/test/smoke.mjs --remote` (the bypass holds,
the rest still 302s), and confirming a deploy (ask production for a string the
change added; D1 cannot answer that, because it moved before the merge).

## Project Structure

```
nates-workshop/
├── index.html            Dashboard; renders cards from apps/manifest.json
├── wrangler.jsonc        Pages config: D1 bindings DB, DB_MARVEL, DB_TOOLS; R2 MEDIA; plain vars
├── groups.json           Which group owns every path and D1 table (scripts/groups.mjs)
├── CLAUDE.md             Rules for working in the repo
├── shared/               Design system (styles.css, fonts) and shared JS (ui.js, api.js, appnav.js)
├── apps/
│   ├── manifest.json     One entry per app; the hub and the app switcher read it
│   ├── _template/        Skeleton for a new app
│   └── <app>/            Each app; the big ones document themselves in a README
├── db/
│   ├── schema.sql        Palladium's D1 (DB); idempotent, every statement IF NOT EXISTS
│   ├── schema-marvel.sql Marvel's D1 (DB_MARVEL)
│   ├── schema-tools.sql  The tools' D1 (DB_TOOLS)
│   └── migrations/       One-shot ALTERs per database, tracked in schema_migrations
├── docs/                 Cross-app docs; docs/prompts/ is one-off briefs (hidden from ripgrep)
├── .claude/              settings.json, hooks/, launch.json, skills/, agents/
├── scripts/              d1-apply, q, drift-check, deploy-sweep, groups, the book tools
├── workers/
│   ├── pick3cut5-room/   Durable Object server. NOT deployed by a merge
│   └── table-room/       The Table's live game room. NOT deployed by a merge either
└── functions/api/
    ├── _middleware.js    Access JWT verification on /api/*; PUBLIC_PATHS exemptions
    ├── _lib/             access.js (the ONE identity read), access-jwt.js, claude-client.js
    ├── claude.js         /api/claude proxy: model allowlist + token cap
    ├── media-vault/      per-item CRUD, lookup proxy (TMDB key server-side), sharing
    ├── pick3cut5/        room + solo; outside the wall; thin proxies to the Worker
    ├── table/            lookup: which game a table code belongs to (behind the wall)
    ├── filament-forge/   catalog (OFD snapshot) + per-user data
    ├── marvel-heroes/    saved heroes, campaigns, The Table's Marvel routes
    └── character-creator/  73 endpoints + _lib; see the app README
```

`.claude/` is repo-local until a machine links it (*Setting up a machine*).
Pages turns `functions/` into routes: `claude.js` is `/api/claude`, and a
directory is a path segment.

**R2:** one bucket, `nates-workshop-media`, bound as `MEDIA` (NPC portraits).
A bucket must exist **before** the deploy that binds it. Every read goes
through a Function that checks campaign membership: **never enable public
access on it.** Which credential can reach R2: `docs/cloudflare-credentials.md`.

## How deploys work

**Merging to `main` is the deploy** for the Pages site: no build command, the
repo root is published. `main` refuses direct pushes, and a merge needs the
`smoke`, `menus` and `regression` checks green (ruleset `22209348`;
`gh api repos/NateGrey0130/nates-workshop/rulesets/22209348` is the source of
truth). `play-flow` and `deploy-alarm` report only.

Schema and data are applied **before** the merge that needs them:

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-whatever.sql
```

`apps/character-creator/docs/operations.md` has the migration convention and
the per-migration table. Two things are outside *merge = deploy*: the
`workers/pick3cut5-room` and `workers/table-room` Workers (next section), and a
deploy that fails.

After a merge, `ship-pr` steps 8–10 confirm it: the merge commit's `Cloudflare
Pages` check-run, then a string the change added. `node scripts/deploy-sweep.mjs`
walks the last twenty first-parent commits and names any that did not ship,
and `.github/workflows/deploy-alarm.yml` does the same daily and fails its own
run (that failure email is the alarm). No tags: `git log --first-parent main` and
Cloudflare's deployment list already say what was live when.

### A branch push competes with the merge it is about to become

Every branch push starts a **preview** build, and previews share one serialised
build queue with production. A wedged preview holds the production deploy
behind it.

- A normal build takes **20–35 seconds**. Past a couple of minutes it is stuck,
  not slow.
- GitHub's check-run says `Building` for a deployment Cloudflare has not
  started. Do not go hunting a compile error on the strength of it.
- Ask Cloudflare for the real stage (the `cloudflare-api` plugin,
  `docs/cloudflare-credentials.md` → *Which credential to reach for*):

  ```
  GET /accounts/{id}/pages/projects/nates-workshop/deployments
      -> per deployment: environment, latest_stage.name, latest_stage.status
  ```

  The Pages check-run's `details_url` is the deployment id, and
  `deploy-sweep.mjs` prints it. The oldest deployment not in `deploy` is the
  blocker, and deleting it releases the queue. **Read the next section first.**

### A skipped deployment looks exactly like a wedged one

Merges seconds apart do not each get a build: Cloudflare **skips** the ones a
later build overtakes, and a skipped deployment's check-run says `Building`
forever. Tell them apart by **what came after**, never by how long it has been
pending:

| | superseded | wedged |
|---|---|---|
| a later commit deployed | **yes**, and it carried this content | no |
| `latest_stage` | `queued` / `skipped` | `queued` or `initialize`, empty log |
| the content | already on the site | **not** on the site |
| what to do | nothing | delete the blocker |

`deploy-sweep.mjs` makes this call itself, from first-parent order (the D1
token cannot read Pages, so a script cannot ask Cloudflare). A pending commit
with a newer deployed commit behind it has shipped.

### When the merge does not deploy

Pages compiles **every** file under `functions/`, routed or not, plus
everything they import, with the wrangler its **build image** ships (3.x),
not the one `npx` resolves here (4.x). Nothing pins either side. Syntax the
build image cannot parse fails the **whole** deploy, and the site keeps serving
the last build that compiled, so every symptom is absent. `gh pr checks` has
shown a red Pages mark on PRs that deployed fine, so do not read it.

The known case is a JSON import attribute (`with { type: 'json' }`), which
parses locally and not in the build image.
`apps/character-creator/test/checks/environment.mjs` §9, *What Pages will
compile*, walks `functions/` and its import closure and fails on an import
attribute or any reach into `scripts/`. It is a **text** check deliberately:
building with the local wrangler would pass the broken syntax.

## Pick 3 Cut 5 and the second Worker

A Pages project cannot define a Durable Object class, only bind to one exported
by a standalone Worker (with `script_name` on the binding). So the room server
is `workers/pick3cut5-room/` and deploys separately.
`docs/pages-to-workers-migration.md` is the alternative considered and not taken.

### Deploy order, which is not enforced anywhere

The Worker must exist **before** the Pages deploy that binds it; backwards,
party mode answers 503 while the rest of the site looks fine.

```bash
npx wrangler deploy --config workers/pick3cut5-room/wrangler.jsonc --var GIT_SHA:$(git rev-parse HEAD)
```

**Keep the `--var`:** `deploy-sweep.mjs` reads `GIT_SHA` back to say which
build is live, and falls back to timestamps without it. There is deliberately
no public version route. A change under `workers/pick3cut5-room/` needs this
deploy again, and a change under `apps/pick3cut5/` alone needs only the merge.

### Its secret is separate

```bash
npx wrangler secret put ANTHROPIC_API_KEY --config workers/pick3cut5-room/wrangler.jsonc
```

Rotating the Anthropic key is **two places**, the Pages secret and this one.
Model ids are plain vars in the Worker's `wrangler.jsonc`. The Worker binds
`DB` only to write `claude_usage` rows (`pick3cut5-party`, `pick3cut5-solo`,
null email, fail-open). No game state touches D1, because rooms live in Durable
Object memory.

### The Table's room, the same way

`workers/table-room/` is The Table's live game room, bound as `TABLE_ROOM` and
deployed exactly like Pick 3 Cut 5's, with the same order: **before** the Pages
deploy that binds it, or every `table/` route answers 503.

```bash
node scripts/deploy-table-room.mjs
```

It stamps `GIT_SHA` and refuses a dirty tree (`scripts/deploy-worker-lib.mjs`),
and `deploy-sweep.mjs` checks it beside the other Worker. It has no secret and
binds no database: rooms keep their feeds in Durable Object storage, and the
Pages routes save a feed to the campaign's own D1 when the table closes. Unlike
Pick 3 Cut 5 it sits **behind** Access - its routes are on no bypass list.

### It cannot be played on a preview

Previews are behind their own Access policy and the bypass does not reach them
(see *Access*). This app is therefore **verified on production right after the
merge**, with:

```bash
node apps/pick3cut5/test/smoke.mjs --remote
```

It fetches the app and its assets with no session and confirms the rest of the
site is still walled.

### It has to be let out of the login wall

Both halves are required:

1. **Zero Trust → Access → Applications**: *Pick 3 Cut 5 (public)*, a
   **Bypass** policy (include: Everyone), and exactly **five** destinations on
   `nates-workshop.pages.dev`, which is Cloudflare's limit:

   | path | why |
   |---|---|
   | `apps/pick3cut5` | the app |
   | `api/pick3cut5` | rooms, WebSocket, solo generation |
   | `shared/styles.css` | the design system |
   | `shared/js/ui.js` | `escHtml`, called on every flip |
   | `shared/fonts` | self-hosted fonts, referenced from inside `styles.css` |

   A sixth dependency needs a **second** Access application. The `shared/` rows
   are the ones that get forgotten: without them the route answers 200 and the
   game is broken. `apps/pick3cut5/test/smoke.mjs` derives this list from
   `index.html` and the stylesheets it loads and fails if this table disagrees.
   `--remote` checks the live policy, including content type, because Pages
   answers a missing path with the landing page at 200.
2. **`PUBLIC_PATHS` in `functions/api/_middleware.js`**, with the **exact**
   paths `/api/pick3cut5/room` and `/api/pick3cut5/solo`. A bypass lets the
   request through without a JWT, so an unlisted path takes a 403 from our own
   middleware. A new route under `functions/api/pick3cut5/` fails the smoke
   suite until it is listed.

Everything else stays gated. The room code is the only barrier on party mode,
by design. Local dev, round costs and challenges are in `apps/pick3cut5/README.md`.

## Environment configuration (Cloudflare Pages dashboard)

Settings → Environment variables. This list is all of it. Whether each value is
`secret_text` or `plain_text` is a dashboard choice, not a property (a Function
reads both through `env`), so read the current set back rather than trusting a
count here:

```
GET /accounts/{account_id}/pages/projects/nates-workshop
  → deployment_configs.production.env_vars
```

- `ANTHROPIC_API_KEY`: the `/api/claude` proxy and the PDF importers. It takes
  effect on the **next deployment**. The Pick 3 Cut 5 Worker holds its own copy.
- `ADMIN_EMAIL`: the one email allowed the importers and catalog editor.
  **Fails closed** when unset.
- `TMDB_API_KEY`: MediaVault's `video-*` lookups, proxied by
  `functions/api/media-vault/lookup.js`. It must be the 32-character **v3** key;
  a v4 read token returns 401s. Unset, those three modes answer 503 and the rest
  of MediaVault works, which is how it goes unnoticed.
- `MV_SHARE_CANDIDATES`: who MediaVault's share picker may offer. It is a
  **hand-kept mirror of the Access allow policy**, re-checked by
  `functions/api/media-vault/shares.js` on every grant. **Unset means nobody.**
  It lives in the dashboard (not `wrangler.jsonc`) because it lists real
  people's addresses and the repo is public. Stored as a secret, it cannot be
  read back; the picker is the only view of who is in it.

  **How many it holds is readable:** `GET /api/media-vault/shares` returns `candidateCount`, which
  should equal the number of email rules on the *Friends Only* Access policy.
  When they disagree the mirror is the one to fix. It fails closed meanwhile:
  the new person is simply not offered.
- `ACCESS_TEAM_DOMAIN` + `ACCESS_AUD`: JWT verification of the Access identity
  on every `/api/*` route. Neither is secret. Both live in `wrangler.jsonc`
  `vars` **and** in the dashboard. `ACCESS_AUD` is the application's AUD tag
  (Zero Trust → Access → Applications → Additional settings). The middleware
  passes through when either is missing and exempts `localhost`. To stand
  down, remove both from `wrangler.jsonc` and merge.

### Who is spending the Anthropic key, and on what

**Every Claude call in `functions/` writes one row to `claude_usage`** (email,
endpoint, model, tokens, upstream status), fail-open. The endpoints are `proxy`,
`campaign-ask`, `cc-npc-sweep` and `cc-extract-class`. The last is written by
`scripts/extract-class.mjs` from a workstation. The Pick 3 Cut 5 Worker adds
`pick3cut5-solo` and `pick3cut5-party`. A failed extraction is recorded too,
because the tokens were spent.

```bash
node scripts/q.mjs --remote "SELECT endpoint, count(*) AS calls, sum(input_tokens) AS input, sum(cache_write_tokens) AS cache_write, sum(cache_read_tokens) AS cache_read, sum(output_tokens) AS output, min(created_at) AS first, max(created_at) AS last FROM claude_usage GROUP BY endpoint ORDER BY input DESC"
node scripts/q.mjs --remote "SELECT date(created_at) AS day, endpoint, count(*) AS calls, sum(input_tokens) AS input, sum(cache_write_tokens) AS cache_write, sum(cache_read_tokens) AS cache_read, sum(output_tokens) AS output FROM claude_usage GROUP BY day, endpoint ORDER BY day DESC LIMIT 30"
node scripts/q.mjs --remote "SELECT email, date(created_at) AS day, count(*) AS calls, sum(input_tokens) AS input, sum(output_tokens) AS output FROM claude_usage GROUP BY email, day ORDER BY day DESC LIMIT 30"
```

A cache write bills at 1.25× input and a read at 0.1×. Both cache columns are
NULL before migration 077. **This is spend visibility, not a cap:** nothing on
the request path reads the table.

## Access (the login wall)

Zero Trust → Access fronts the whole site: the application domain is the Pages
URL with the path blank. The allow policy (*Friends Only*) is a plain email
list, and sessions are one-time email codes. **There is no policy-as-code**; it
is dashboard-only, and readable through the `cloudflare-api` plugin.

Identity is read from `Cf-Access-Authenticated-User-Email` in exactly one
place, `functions/api/_lib/access.js`. On localhost the fallback is
`dev@localhost`.

### Adding a friend is TWO steps, and the second one is easy to forget

1. Add their address to the *Friends Only* allow policy.
2. Add it to `MV_SHARE_CANDIDATES` (above), in the same sitting.

Nothing checks that the two agree, and no request can reveal an allow list. The
drift fails closed, so it is a note and not a gate. The policy `PUT` replaces
the whole policy, so send every field back.

**Previews are walled separately** (Pages → Settings → Preview access), by an
auto-created Access policy. A friend who needs a preview is added there too.
**The Pick 3 Cut 5 bypass does not reach previews:** its destinations are
hostname-specific. A wildcard bypass on `*.nates-workshop.pages.dev` would make
every preview public on those paths, and it was declined.

## Setting up a machine

**The skills and the agents need a junction, once per machine**, because a
session started outside the repo (the book work runs from
`C:\Users\natha\Projects\workshop`) would register neither. Junctions need no
admin rights and follow repo edits:

```powershell
foreach ($s in 'app-suite','audit-menu','book-survey','claim-audit','class-import','marvel-book','media-vault','pick3cut5','schema-change','ship-pr','take','test-suite','verify-ui','windows-shell','worktree') {
  New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\$s" -Target "C:\Users\natha\Projects\nates-apps\.claude\skills\$s"
}
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\agents" -Target "C:\Users\natha\Projects\nates-apps\.claude\agents"
```

- **A new skill needs its own line here, in the PR that adds it.** Nothing
  notices the gap. A new agent needs nothing, because the whole directory is
  linked.
- The agents link is a directory because an agent is a file, and a per-file
  symlink needs administrator rights here. So `~/.claude/agents` **is** the
  repo's directory and can hold nothing else.
- An agent file written mid-session cannot be spawned until the next turn.

**Session memory is one store behind junctions.** The real store is
`C:\Users\natha\.claude\projects\C--Users-natha-Projects-workshop\memory`; the
repo's and `Downloads`' project folders link to it:

```powershell
foreach ($p in 'C--Users-natha-Downloads','C--Users-natha-Projects-nates-apps') {
  New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\projects\$p\memory" `
    -Target "$env:USERPROFILE\.claude\projects\C--Users-natha-Projects-workshop\memory"
}
```

A worktree's project slug does not exist until the worktree does, so a session
in one starts with no memory. The exception is `scripts/book-worktree.mjs`,
which links it. See the `worktree` skill.

**The answer is a pointer at the user level.** A repo `CLAUDE.md` loads only
inside the repo, so `~/.claude/CLAUDE.md` holds a few lines pointing at it:
where the repo is, read its `CLAUDE.md` when the work touches it, and where the
working directory is. It is neither a copy nor a junction. It is checked in
nowhere, so **edit it by hand when anything it names moves**.
`machine-instructions.mjs` (local smoke only) holds it to naming no skill or
agent and stating no count.

**The Bash guard hook is registered twice, on purpose.** Once in the repo's
`.claude/settings.json` and once at user level in
`C:\Users\natha\.claude\settings.json`, with an absolute path to
`.claude/hooks/guard-bash.sh`. A fresh machine must add the user-level
registration by hand; `hook-registration.mjs` checks it locally.

**`launch.json` exists twice.** The tracked `.claude/launch.json` is
machine-independent. The working directory's untracked copy has every command
wrapped in `cmd /c cd /d C:\Users\natha\Projects\nates-apps && …`. **Mirror any
change by hand, comments included.**

**The working directory's `.claude/settings.local.json` is per-machine.** Keep
it read-only in posture and never promote its grants into the tracked
`settings.json`.

**PowerShell profile:** `$PROFILE.CurrentUserAllHosts` (inside OneDrive) is a
two-line stub that dot-sources `C:\Users\natha\Projects\workshop\profile.ps1`.
Edit the real file, never the stub, and keep PATH out of both. It carries a
`CommandNotFoundAction` recorder that appends to `workshop\command-not-found.log`
for `MACHINE-AUDIT` `M18`. **If that log ever appears, read it first.** Agents
run `-NoProfile`, so none of this affects them.

### Per-clone git config, because git cannot ship config with a checkout

```bash
git config remote.origin.prune true
git config gc.auto 1000
```

`prune` is necessary but not sufficient: only a **bare** `git pull`/`git fetch`
prunes (`ship-pr` step 8). `gc.auto 1000` makes automatic repacking actually
fire here. At git's default of 6700 loose objects this clone reached 136 MB
against 18 MB after a `gc`.

### Worktrees, and the two stores that live under the repo root

The OCR caches (`.cache/books/`) and wrangler's local D1 (`.wrangler/state/`)
are gitignored and per-machine. Two variables point a worktree at the right
ones; the main checkout needs neither:

| variable | read by | default |
|---|---|---|
| `WORKSHOP_OCR_CACHE` | `scripts/books-lib.mjs` `ocrCacheDir()` and `scripts/ocr-book.py` | `<repo>/.cache/books` |
| `WORKSHOP_LOCAL_D1` | `scripts/d1-query-lib.mjs` `localD1Args()`, passed as `--persist-to` to every `--local` wrangler call | `.wrangler/state` under the cwd |

The working directory sets both in
`C:\Users\natha\Projects\workshop\.claude\settings.json` (`env`), pointing at
the main checkout.

- **A group worktree:** `node scripts/group-worktree.mjs <palladium|marvel|tools>`.
- **A book worktree:** `node scripts/book-worktree.mjs <slug>`. It points the
  OCR cache at the main checkout and gives the tree its **own** local D1
  (`--copy-d1` copies the main one instead). `--remove` refuses on uncommitted
  changes or any junction inside the tree.
- **Before `git worktree remove`, read the `worktree` skill.** A removal once
  deleted through a junction and emptied the main checkout's caches.
- `regression.mjs` and `play-flow.mjs` build their own scratch database and
  ignore both variables. A `wrangler pages dev` started in a worktree serves
  that tree's local D1 unless started with `--persist-to`.
- **One session per tree.** A second session gets its own worktree and dev port.

### The command-line tools

`node`, `npm`, `git` and `gh` put themselves on PATH.

- **`pdftotext`** ships with Git for Windows at
  `C:\Program Files\Git\mingw64\bin\pdftotext.exe`. That directory is appended
  to the **end** of the User PATH, so that `C:\WINDOWS\system32\curl.exe` still
  beats Git's `curl.exe`. Agents get it anyway, because Git Bash prepends
  `/mingw64/bin`.
- **Editing the User PATH:** `HKCU\Environment\PATH` is `REG_EXPAND_SZ`.
  `[Environment]::SetEnvironmentVariable(…,'User')` rewrites it as `REG_SZ` and
  breaks `%USERPROFILE%\…\WindowsApps` (where `python` resolves). Write through
  `Microsoft.Win32.Registry` with `RegistryValueKind::ExpandString`. An
  already-open terminal never sees a PATH change.
- **`tesseract`** is required by `scripts/ocr-book.py`, is not on PATH, and
  works because `find_tesseract()` falls back to
  `C:\Program Files\Tesseract-OCR\tesseract.exe` (v5, `eng` + `osd` only).
  **Leave the fallback alone.** A machine with Tesseract elsewhere needs a PATH
  entry, not a script edit.
- **`python`** is the Microsoft Store alias forwarding to Python 3.14. Its only
  third-party import is `pymupdf`. There is no pinned interpreter or
  `requirements.txt`, deliberately. If the alias is switched off, `python`
  opens the Store instead of failing.
- **Process Monitor** is staged, not running, at
  `C:\Users\natha\Projects\workshop\tools\procmon\` for `M18` only. Nothing
  depends on it. Its `README.md` has the capture steps. The filter needs
  **Drop Filtered Events**, and capture health is checked with
  `m18-capture-health.ps1`, never the file size (it preallocates).

## Adding a New App

The `app-suite` skill is the full procedure. The short form:

1. `cp -r apps/_template apps/my-new-app`, then delete its
   `manifest-entry.example.json`.
2. Add an entry to `apps/manifest.json`. The hub renders from it; no HTML edits.
3. Build in `apps/my-new-app/`: import `/shared/styles.css` and the shared JS,
   override `--accent` in the app's own `styles.css`, and call Claude through
   `claudeRequest()`. Per-user storage follows `functions/api/media-vault/`:
   identity via `_lib/access.js` (`getAccessEmail`), and a table in the
   owning group's schema file (`IF NOT EXISTS`), per `schema-change`.
4. Give every new path an owner in `groups.json`, then branch, PR and merge.

## Custom Domain

Pages → project → Custom domains → add it, create the DNS record it asks for,
and change the Access application domain to match.

## Cost Summary

| Service | Cost | Limits |
|---|---|---|
| Cloudflare Pages + Functions | Free | 100K requests/day |
| Cloudflare Workers | Free | `pick3cut5-room`, its own request budget |
| Cloudflare D1 | Free | 5M row reads/day |
| Cloudflare R2 | Free | `nates-workshop-media`; free storage allowance, no egress |
| Cloudflare Access | Free | up to 50 users |
| GitHub | Free | |
| Anthropic API | usage | pennies; PDF imports are the costly calls (see *Who is spending*) |

## Troubleshooting

**The Pages half has no server logs; the browser console is the tool.** Only
`pick3cut5-room` has Workers observability enabled. So a quiet week means only
that nobody hit anything.

| symptom | cause |
|---|---|
| "API key not configured on server" | `ANTHROPIC_API_KEY` unset, or set and not yet redeployed |
| importer buttons missing, 403 on import | `ADMIN_EMAIL` unset (fails closed) or not the logged-in email |
| an API call does nothing; `/api/...` returns HTML | Access intercepted it, usually an expired session. Reload and log in |
| merged, production did not change | the deploy failed to compile. See *When the merge does not deploy* |
| every API call 503s naming signing keys | `ACCESS_TEAM_DOMAIN` wrong. Fix it in `wrangler.jsonc`, or remove the pair to fall back to header trust |
| no Access screen | the application domain must exactly match the Pages URL or custom domain |
| a friend gets no email code | spam folder, or their address is not in the policy |
| database looks wrong after a migration | ask it: `node scripts/drift-check.mjs --remote` |
