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

**Cloudflare Access fronts every route, `/api/*` included**, so this URL is not
reachable from anything without a session:

| From | What you get |
|---|---|
| a browser you are logged into | the app |
| `curl`, a script, an automated browser | **302 to the Access login wall** |

That 302 is easy to misread as the site being down or a path being wrong. It is
neither — it is the login wall doing its job. To check production from a tool,
query D1 directly (see `CLAUDE.md`) rather than fetching the site.

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
├── .claude/
│   ├── launch.json           Dev-server config for the editor's preview
│   └── skills/               Repo-specific instructions, loaded by name
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
        └── character-creator/  46 endpoints + _lib; see the app README
```

**The skills need a junction, once per machine.** The book work runs from
Downloads (the PDFs land there, and the session memory is keyed to it), and a
session started outside the repo never registers `.claude/skills/` — so the
skills were being pasted into context by hand instead of loading by name
(efficiency audit, F5). Junction-link them into the global skills directory;
junctions, so repo edits propagate, and no admin rights are needed:

```powershell
foreach ($s in 'book-survey','claim-audit','class-import','schema-change','ship-pr') {
  New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\$s" -Target "C:\Users\natha\Projects\nates-apps\.claude\skills\$s"
}
```

A skill added to the repo later needs its own link — there is nothing that
notices the gap, so add the link in the same PR that adds the skill.

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

**One thing in this repo is not covered by that sentence.** `workers/pick3cut5-room/`
is a standalone Worker and merging does not deploy it — see the next section.

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

### Previews are gated, deliberately

Pick 3 Cut 5 **cannot be played on a PR preview**. The bypass application targets
`nates-workshop.pages.dev`; a preview lands on `<hash>.nates-workshop.pages.dev`,
which it does not match, and the preview-access application gates it.

Opening previews would need a second Access application on
`*.nates-workshop.pages.dev` — which would make every preview of the whole site
public on those paths, including a generation endpoint per live preview.
Declined 2026-08-24: too much permanent exposure for a convenience.

So this app is **verified on production immediately after merge**. That is
weaker than a preview, and the check that makes it good enough is:

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
   **four** destinations, all on `nates-workshop.pages.dev`:

   | path | why |
   |---|---|
   | `apps/pick3cut5` | the app itself |
   | `api/pick3cut5` | rooms, WebSocket, solo generation |
   | `shared/styles.css` | the design system the page loads |
   | `shared/js/ui.js` | `escHtml`, which the game calls on every flip |

   Dashboard only; the `CLOUDFLARE_API_TOKEN` in `CLAUDE.md` is scoped to D1
   and cannot create it.

   **The last two are the ones that get forgotten.** The app shipped without
   them and was broken for every unauthenticated player: the page rendered in
   Times New Roman and `escHtml is not defined` froze the game at the first
   flip, while `curl /apps/pick3cut5/` cheerfully returned 200. A route
   answering is not the same as a page working.
   `node apps/pick3cut5/test/smoke.mjs` derives this list from `index.html` and
   fails if it and this table disagree; `--remote` checks the live policy.
   Note Access allows five destinations per application, so one more dependency
   fits and the one after that needs a second application.
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

### Who is spending the Anthropic key

Every `/api/claude` proxy call and every campaign **Ask** writes one row to
`claude_usage` (email, endpoint, model, tokens, upstream status) — written
fail-open, so metering can never break the call it measures. The admin
importers are deliberately unlogged: they are already gated to `ADMIN_EMAIL`,
which is the question this table answers. To read the spend:

```bash
node scripts/q.mjs --remote "SELECT email, date(created_at) AS day, count(*) AS calls, sum(input_tokens) AS input, sum(output_tokens) AS output FROM claude_usage GROUP BY email, day ORDER BY day DESC LIMIT 30"
```

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
| Cloudflare D1            | Free    | 5M row reads/day on free plan   |
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
