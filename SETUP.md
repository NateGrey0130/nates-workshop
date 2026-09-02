# Nate's Workshop — Deployment Reference

This repo is **live**: Cloudflare Pages deploys `main` on every merge — no
build step, no CI. This file describes how the deployment is configured and
what to touch when adding to it. Guidance for working *in* the repo (D1 auth,
the apply routine) is in `CLAUDE.md`; the character creator documents itself
in `apps/character-creator/README.md`.

## Where it lives

<https://nates-workshop.pages.dev> — the Pages default, derived from
`"name": "nates-workshop"` in `wrangler.jsonc`. The character creator is at
`/apps/character-creator/`, because `pages_build_output_dir` is the repo root and
nothing rewrites paths.

**Cloudflare Access fronts every route, `/api/*` included**, so with one
standing exception this URL is not reachable from anything without a session:

| From | What you get |
|---|---|
| a browser you are logged into | the app |
| `curl`, a script, an automated browser | **302 to the Access login wall** |
| either of those, on a Pick 3 Cut 5 bypass path | the real response, no session needed |

That 302 is easy to misread as the site being down or a path being wrong. It is
neither — it is the login wall doing its job. For most checks against
production, query D1 directly (see `CLAUDE.md`) rather than fetching the site.

Two standing checks fetch it anyway, on purpose:

- **`node apps/pick3cut5/test/smoke.mjs --remote`** fetches the bypass paths
  with no session — that is the exception in the table, and the test exists to
  confirm it holds while everything *else* still 302s.
- **Confirming a deploy landed** means asking production for a string the change
  added, in whatever way reaches the page — a fetch on a bypass path, a
  logged-in browser anywhere else. D1 cannot answer it at all: the database
  moved *before* the merge, so it reads the same whether or not the code ever
  shipped. See *When the merge does not deploy* below.

## Project Structure

```
nates-workshop/
├── index.html                Dashboard — renders cards from apps/manifest.json
├── wrangler.jsonc            Pages config; the D1 binding (DB) lives here
├── CLAUDE.md                 Cloudflare auth facts + the migration routine
├── shared/
│   ├── styles.css            Shared design system (tokens, header, buttons, modals)
│   └── js/
│       ├── ui.js             openModal/closeModal, escHtml, copyWithFeedback
│       └── api.js            claudeRequest() wrapper for /api/claude
├── apps/
│   ├── manifest.json         One entry per app; the dashboard reads this
│   ├── _template/            Skeleton to copy when starting a new app
│   ├── filament-forge/       AI slicer-settings engine; see its README
│   ├── media-vault/          Personal media library
│   ├── pick3cut5/            Party game; see its README — its server is
│   │                         the standalone Worker below, not this project
│   └── character-creator/    Palladium/Rifts character builder — the big one;
│                             see its README for everything about it
├── db/
│   ├── schema.sql            Shared D1 schema — MediaVault, FilamentForge
│   │                         (ff_-prefixed) and the character creator.
│   │                         Idempotent: every statement IF NOT EXISTS
│   └── migrations/           One-shot ALTERs, tracked in schema_migrations
├── docs/
│   └── pages-to-workers-migration.md   The Workers alternative — written up
│                             and not taken; the second-Worker section cites it
├── .claude/
│   ├── launch.json           Dev-server config for the editor's preview
│   ├── agents/               Subagents, one per file
│   │   └── book-reconcile.md   Checks extracted rows against the book's own text
│   └── skills/               Repo-specific instructions, loaded by name
│       ├── audit-menu/       Numbering, taking and recording an audit finding
│       ├── book-survey/      Surveying a sourcebook PDF before extracting
│       ├── claim-audit/      Checking what the repo says against what it does
│       ├── class-import/     Transcribing a class from a sourcebook
│       ├── schema-change/    Adding a migration without breaking a fresh DB
│       └── ship-pr/          Branch, verify, PR, merge, prune, verify again
├── scripts/
│   ├── d1-apply.mjs          The migration/data-script apply routine
│   ├── sql-statements.mjs    Splitting .sql into statements; d1-apply, q.mjs
│   │                         --batch and the smoke test share it
│   ├── class-check.mjs       Checks a class definition before it lands
│   ├── class-check-lib.mjs   The checks themselves, so the smoke test can run them
│   ├── ofd-refresh.mjs       Snapshot the Open Filament Database into D1 for
│   │                         FilamentForge's catalog
│   └── ofd-refresh-lib.mjs   Its pure half, so FilamentForge's smoke test can
│                             run it
├── workers/
│   └── pick3cut5-room/       The Durable Object server — rooms, the
│                             generation pipeline, its own Anthropic key.
│                             NOT deployed by a merge; see its section below
└── functions/
    └── api/
        ├── _middleware.js    Optional JWT verification on every /api/* route;
        │                     pass-through until ACCESS_TEAM_DOMAIN + ACCESS_AUD
        │                     are set (see Access below)
        ├── _lib/access.js    Cloudflare Access identity — the ONE place the
        │                     identity header is read
        ├── _lib/access-jwt.js  Verifying the Access JWT against the team's keys
        ├── _lib/claude-client.js  The only code that calls the Anthropic API,
        │                     and the fail-open claude_usage spend log
        ├── claude.js         /api/claude — proxy (model allowlist + token cap)
        ├── media-vault/      /api/media-vault — per-item CRUD, lookup proxy
        │                     (TMDB key lives server-side), one-time migrate
        ├── pick3cut5/        room + solo; both OUTSIDE the login wall,
        │                     and both thin proxies to the Worker
        ├── filament-forge/   catalog (the OFD snapshot) + data (per-user
        │                     config/history/presets/custom filaments)
        └── character-creator/  35 endpoints + _lib; see the app README
```

Everything under `.claude/` is repo-local until a machine links it into the
global directories — see *Setting up a machine*, below, for the once-per-machine
step that makes the skills and the subagent load by name.

**R2**: the site binds one bucket, `nates-workshop-media`, as `MEDIA`. It holds
NPC portraits today and is named for the site rather than for that app because
the other two will want it. **It must exist before the deploy that binds it** —
same discipline as a migration:

```bash
npx wrangler r2 bucket create nates-workshop-media
npx wrangler r2 bucket list          # verify, rather than trusting the exit code
```

Nothing is served from a public bucket URL; every read goes through a Function
that checks who is asking. Do not enable public access on it.

Cloudflare Pages deploys `functions/` as serverless Workers automatically —
`claude.js` becomes `/api/claude`, and directories map to routes. The D1
database (`nates-workshop-media`) is bound as `DB` in `wrangler.jsonc`.

## How deploys work

Merging to `main` **is** the deploy — for the Pages site. Pages builds nothing
(no build command) and publishes the repo root. Schema changes are applied by
hand **before** the merge that needs them:

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-whatever.sql
```

See `apps/character-creator/docs/operations.md` for the full migration
convention, and `CLAUDE.md` for the `CLOUDFLARE_API_TOKEN` setup the routine
expects.

**Two things in this repo are not covered by that sentence.** One is
`workers/pick3cut5-room/`, a standalone Worker that merging does not deploy —
see the next section. The other is the deploy failing outright.

### When the merge does not deploy

Pages compiles **every** file under `functions/` — reachable from a route or
not — and everything those files import, using the wrangler its **build image**
ships (3.114.17) rather than the one this repo runs. Syntax that image cannot
parse fails the whole deploy. Not the one route: the deploy.

**The failure is silent in both directions.** The site keeps serving the last
build that compiled, so every symptom you would look for is absent — pages load,
the API answers, and the code is simply old. And `gh pr checks` has shown a red
"Cloudflare Pages fail" on PRs that deployed perfectly well for months, so a red
mark there carries no information and reads as noise.

That is how this ran undetected from `d5280fe` (2026-08-27) until PR #399
restored it on 2026-08-30: a JSON import written the way Node requires it —
`with { type: 'json' }` — parses under a current wrangler and does not parse
under 3.114.17. Merges kept landing on `main`, and not one of them reached
production.

The guard that now exists is
`apps/character-creator/test/checks/environment.mjs` §9, *What Pages will
compile*. It walks `functions/` plus the closure of everything the routes
import, and fails on an import attribute in either spelling, or on any reach
into `scripts/`. **It is a TEXT check, deliberately.** Shelling out to
`npx wrangler pages functions build` would use whatever version resolves on this
machine, which is newer than the build image and compiles the broken syntax
happily — a check written that way would have passed through the whole outage.
That was measured, not assumed.

The guard catches the shape that has already bitten. Confirming that a given
deploy actually landed is a separate step, and it belongs to the merge loop
rather than to this document: **the `ship-pr` skill requires it** — the merge
commit's check-runs read from the GitHub API, plus asking production for a
string the change added.

## Pick 3 Cut 5 and the second Worker

Pick 3 Cut 5 needs a Durable Object per room, and **a Pages project cannot
define a Durable Object class** — it can only bind to one exported from a
standalone Worker, and unlike Workers, Pages requires `script_name` on the
binding. That is current documented behaviour, not a legacy quirk. So the room
server lives in `workers/pick3cut5-room/` and deploys on its own.
`docs/pages-to-workers-migration.md` covers the alternative that was considered
and not taken.

### Deploy order, which is not enforced anywhere

The Worker must exist **before** the Pages deploy that binds it — the same
discipline as creating an R2 bucket before binding it. Get it backwards and
party mode answers 503 while the rest of the site looks completely fine.

```bash
npx wrangler deploy --config workers/pick3cut5-room/wrangler.jsonc
```

Then merge. On any later change that touches only `apps/pick3cut5/`, merging is
enough; on any change under `workers/pick3cut5-room/`, deploy the Worker again.

### Its secret is separate

The Worker holds its own copy of the Anthropic key. The Pages secret does not
reach it:

```bash
npx wrangler secret put ANTHROPIC_API_KEY --config workers/pick3cut5-room/wrangler.jsonc
```

Rotating the key means rotating it in **both** places. Model IDs are plain vars
in the Worker's own `wrangler.jsonc`, not secrets.

This Worker **does** write `claude_usage` rows — it binds `DB` for metering and
nothing else, so its spend shows up in the query under *Who is spending the
Anthropic key* below. Rows carry a null email (there is no identity here by
design) and an endpoint of `pick3cut5-party` or `pick3cut5-solo`; one generation
writes two or three rows depending on whether verification ran. Writes are
fail-open, so a missing table or a D1 hiccup can never break a round.

No game state touches D1 — rooms still live and die in Durable Object memory.

### It cannot be played on a preview

Previews are gated, and the bypass does not follow the app onto them — both
halves of that are under *Access*, because both are site-wide. The consequence
here is that a PR preview cannot be played, so this app is **verified on
production immediately after merge**. That is weaker than a preview, and the
check that makes it good enough is:

```bash
node apps/pick3cut5/test/smoke.mjs --remote
```

It fetches the app and its assets with no Access session and confirms the rest
of the site is still walled — which is the thing a browser tab you are logged
into cannot tell you.

### It has to be let out of the login wall

Two halves, and **both** are required — either one alone leaves the app broken:

1. **Zero Trust → Access → Applications**, one self-hosted application named
   *Pick 3 Cut 5 (public)* with a **Bypass** policy (include: Everyone) and
   **five** destinations, all on `nates-workshop.pages.dev`:

   | path | why |
   |---|---|
   | `apps/pick3cut5` | the app itself |
   | `api/pick3cut5` | rooms, WebSocket, solo generation |
   | `shared/styles.css` | the design system the page loads |
   | `shared/js/ui.js` | `escHtml`, which the game calls on every flip |
   | `shared/fonts` | Saira and IBM Plex Sans, self-hosted since the fonts came off the CDN |

   **`shared/fonts` is the fifth and last destination that fits** — the limit is
   five, so a sixth dependency needs a second Access application rather than a
   surprise. It is also the only one invisible to `index.html`: the fonts are
   referenced from inside `shared/styles.css`, by a `url()` no tag mentions.
   Since 2026-09-01 the derivation in `apps/pick3cut5/test/smoke.mjs` follows
   the stylesheets it finds in the HTML, so this row is derived like the other
   four rather than kept by hand.

   Dashboard only; the `CLOUDFLARE_API_TOKEN` in `CLAUDE.md` is scoped to D1
   and cannot create it.

   **The three `shared/` rows are the ones that get forgotten.** The app shipped
   without `shared/styles.css` and `shared/js/ui.js` and was broken for every
   unauthenticated player: the page rendered in Times New Roman and
   `escHtml is not defined` froze the game at the first flip, while
   `curl /apps/pick3cut5/` cheerfully returned 200. A route answering is not the
   same as a page working.
   `node apps/pick3cut5/test/smoke.mjs` derives this list from `index.html` and
   the stylesheets it loads, and fails if it and this table disagree; `--remote`
   checks the live policy, and checks the content type as well as the status —
   Pages answers a path it does not have with the landing page, at 200.
2. **`PUBLIC_PREFIXES` in `functions/api/_middleware.js`**, which already lists
   `/api/pick3cut5/`. A bypass policy lets the request through *without*
   minting a JWT, so without this exemption every call takes a hard 403 from
   our own middleware.

Everything else in the Workshop stays gated. The room code is the only barrier
on party mode, by design.

### The rest of it is in the app's own README

Local dev with two clients against one room, what a round costs to build,
and the two ways a player can challenge an item all live in
`apps/pick3cut5/README.md`. They are how the game behaves, not how it is
deployed; what stays here is the part that needs the Cloudflare dashboard.

## Environment configuration (Cloudflare Pages dashboard)

Settings → Environment variables, both encrypted:

- `ANTHROPIC_API_KEY` — used by the `/api/claude` proxy and the character
  creator's PDF importers. A new value takes effect on the **next deployment**.
- `ADMIN_EMAIL` — the single email allowed to use the importers and catalog
  editor. The check **fails closed** when unset.
- `ACCESS_TEAM_DOMAIN` + `ACCESS_AUD` — turn on JWT verification of the
  Access identity on every `/api/*` route (defence in depth — the identity
  header alone is only as good as the Access application staying configured).
  **Both live in `wrangler.jsonc` `vars`, not the dashboard**: this project
  manages plain variables through its wrangler config (the dashboard holds
  only the two encrypted secrets above), and neither value is a secret — the
  AUD tag rides in every login redirect URL. `ACCESS_TEAM_DOMAIN` is the
  team's domain (`<team>.cloudflareaccess.com`); `ACCESS_AUD` is the Access
  application's **Application Audience (AUD) tag** (Zero Trust → Access →
  Applications → this app → Additional settings). The middleware passes
  through when either is missing, and exempts `localhost` — local dev reads
  the same vars and has no Access to mint a token. To stand down, remove both
  from `wrangler.jsonc` and merge.

### Who is spending the Anthropic key, and on what

**Every Claude call in `functions/` writes one row to `claude_usage`** (email,
endpoint, model, tokens, upstream status) — fail-open, so metering can never
break the call it measures. The endpoints are `proxy`, `campaign-ask`,
`cc-npc-sweep`, and `cc-extract-class` — which is written by
`scripts/extract-class.mjs` from a workstation rather than by a Worker (`skills`,
`spells`, `psionics`, `gear`). The Pick 3 Cut 5 Worker writes its own
`pick3cut5-solo` and `pick3cut5-party` rows into the same table.

This used to say the admin importers were deliberately unlogged because they
are gated to `ADMIN_EMAIL` already. That was answering the wrong question. The
table records what was **spent**, not who is allowed to spend it, and a class
extraction sends a whole PDF page — the most expensive call this repo makes,
and the one that was invisible. A failed extraction is recorded too: the tokens
go out whether or not the reply parses.

What a book costs, by endpoint:

```bash
node scripts/q.mjs --remote "SELECT endpoint, count(*) AS calls, sum(input_tokens) AS input, sum(output_tokens) AS output, min(created_at) AS first, max(created_at) AS last FROM claude_usage GROUP BY endpoint ORDER BY input DESC"
```

The same spend by day, which is how an import session reads:

```bash
node scripts/q.mjs --remote "SELECT date(created_at) AS day, endpoint, count(*) AS calls, sum(input_tokens) AS input, sum(output_tokens) AS output FROM claude_usage GROUP BY day, endpoint ORDER BY day DESC LIMIT 30"
```

And who spent it:

```bash
node scripts/q.mjs --remote "SELECT email, date(created_at) AS day, count(*) AS calls, sum(input_tokens) AS input, sum(output_tokens) AS output FROM claude_usage GROUP BY email, day ORDER BY day DESC LIMIT 30"
```

**Spend visibility, not a cap.** Nothing on the request path reads this table,
there is no budget and no refusal — the same posture `recordUsage`'s own
comment states.

## Access (the login wall)

Cloudflare Zero Trust → Access fronts the whole site — application domain set
to the Pages URL above with the path blank, so every route including `/api/*` is
covered. The allow policy is a plain email list; add a friend by adding their
email. Sessions are one-time email codes. There is **no Access policy-as-code
in the repo** — it is dashboard-only.

The Workers read the identity from the `Cf-Access-Authenticated-User-Email`
header in exactly one place: `functions/api/_lib/access.js`. On localhost,
where Access is absent, the character creator's auth falls back to
`dev@localhost`.

**Preview deployments are restricted too** (Pages → Settings → Preview
access), because they sit outside the main Access application while binding
the production database. That wall is a second, auto-created Access policy —
separate from the Friends Only one — so a friend who needs to see a preview
must be added to it in Zero Trust.

**The Pick 3 Cut 5 bypass does not reach a preview either.** Its destinations
are hostname-specific — all on `nates-workshop.pages.dev` — and a preview lands
on `<hash>.nates-workshop.pages.dev`, which they do not match. Letting the app
out on previews would mean a second bypass application on
`*.nates-workshop.pages.dev`, which would make every preview of the whole site
public on those paths, including a generation endpoint per live preview.
**Declined 2026-08-24**: too much permanent exposure for a convenience. What
that costs the game is under *It cannot be played on a preview* above.

## Setting up a machine

**The skills and the agents need a junction, once per machine.** The book work
runs from Downloads (the PDFs land there, and the session memory is keyed to
it), and a session started outside the repo registers neither `.claude/skills/`
nor `.claude/agents/` — so the skills were being pasted into context by hand
instead of loading by name (efficiency audit, F5), and the `book-reconcile`
subagent `book-survey` §5 calls for simply did not exist there
(`INGESTION-AUDIT` F8). Junction-link them into the global directories;
junctions, so repo edits propagate, and no admin rights are needed:

```powershell
foreach ($s in 'audit-menu','book-survey','claim-audit','class-import','schema-change','ship-pr') {
  New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\$s" -Target "C:\Users\natha\Projects\nates-apps\.claude\skills\$s"
}
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\agents" -Target "C:\Users\natha\Projects\nates-apps\.claude\agents"
```

**The agents line links the whole DIRECTORY, and the skills are linked one by
one. That difference is forced, not stylistic.** An agent is a *file*
(`.claude/agents/book-reconcile.md`), a Windows junction only works on a
directory, and the per-file alternative — `-ItemType SymbolicLink` — **fails
with "Administrator privilege required"** on this machine, which has Developer
Mode off (re-tested 2026-08-28). Linking the directory is the only shape that
keeps the "no admin rights" property this whole block depends on.

It has one consequence worth knowing: `~/.claude/agents` **is** the repo's
directory, so nothing else can live there. `~/.claude/skills` is shared —
plugin-installed skills sit beside the six repo junctions as real directories —
and the agents directory cannot be. If a non-repo agent is ever wanted, this
link has to become per-file, and that will need elevation.

A skill added to the repo later needs its own link — there is nothing that
notices the gap, so add the link in the same PR that adds the skill. **A new
agent needs nothing**: the directory junction covers it the moment the file
lands.

**Once these exist, `CLAUDE.md` says the skills load from anywhere, and that
sentence is only true on a machine that has run the block above.** A fresh
machine has to run it before the book work will find them by name.

`.claude/agents/` is covered as of 2026-08-28 (`INGESTION-AUDIT` F8), so
`book-survey` §5 can spawn `book-reconcile` from Downloads. Confirm it the way
you would confirm a skill — by asking for it by name, not by trusting this line.

## Adding a New App

1. Copy the template:
   ```bash
   cp -r apps/_template apps/my-new-app
   rm apps/my-new-app/manifest-entry.example.json
   ```
2. Add an entry to `apps/manifest.json` (see the example file). The dashboard
   renders its cards from the manifest — no HTML edits. `"status": "soon"`
   with `"slug": null` makes a greyed-out teaser card.
3. Build in `apps/my-new-app/`: `index.html` imports `/shared/styles.css` and
   the shared JS; override `--accent` in the app's own `styles.css`; call
   Claude through `claudeRequest()`. Per-user storage follows the
   `functions/api/media-vault/` pattern — identity via `_lib/access.js`
   (`getAccessEmail`), a table added to `db/schema.sql` (keep it
   `IF NOT EXISTS`).
4. Commit on a branch, PR, merge — the merge deploys it.

## Custom Domain

Pages → project → Custom domains → add the domain, create the DNS record it
asks for, and update the Access application domain to match.

## Cost Summary

| Service                  | Cost    | Limits                          |
|--------------------------|---------|---------------------------------|
| Cloudflare Pages         | Free    | Unlimited static sites          |
| Cloudflare Functions     | Free    | 100K requests/day               |
| Cloudflare Workers       | Free    | The standalone `pick3cut5-room` — a separate script with its own request budget |
| Cloudflare D1            | Free    | 5M row reads/day on free plan   |
| Cloudflare R2            | Free    | `nates-workshop-media`, bound as `MEDIA`; free storage allowance, no egress fees |
| Cloudflare Access        | Free    | Up to 50 users                  |
| GitHub (private repo)    | Free    | Unlimited                       |
| Anthropic API            | Usage   | Pennies; PDF imports are the costly calls |

## Troubleshooting

**"API key not configured on server"**
→ `ANTHROPIC_API_KEY` unset, or set but not yet redeployed.

**Importer buttons missing / 403 on import endpoints**
→ `ADMIN_EMAIL` unset (fails closed) or doesn't match the logged-in email.

**An app's Generate/API call does nothing**
→ Browser console (F12). If `/api/...` returns HTML, Access intercepted the
request — usually a session that expired mid-use; reload and log back in.

**I merged and production did not change**
→ The deploy failed to compile, and nothing said so. Read the merge commit's
check-runs, then look for a file under `functions/` — or anything one of them
imports — using syntax the pinned build wrangler rejects. See *When the merge
does not deploy* above; `ship-pr` carries the check as a step.

**Every API call returns 503 naming signing keys**
→ `ACCESS_TEAM_DOMAIN` is set but wrong (or the certs endpoint is unreachable).
Fix the value in `wrangler.jsonc`, or remove the
`ACCESS_TEAM_DOMAIN`/`ACCESS_AUD` pair there to fall back to header-trust —
either way, merging is the deploy that applies it.

**Cloudflare Access screen doesn't appear**
→ The application domain must exactly match the Pages URL (or custom domain).
Zero Trust → Access → Applications.

**Friends don't get the email code**
→ Spam folder, or their exact email isn't in the Access policy.

**Database looks wrong after a migration**
→ Ask the database, not the docs:
`npx wrangler d1 execute nates-workshop-media --remote --command "SELECT filename FROM schema_migrations ORDER BY filename"` —
and see the *Verify anything applied to production* notes in the character
creator README.
