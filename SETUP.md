# Nate's Workshop — Deployment Reference

This repo is **live**: Cloudflare Pages deploys `main` on every merge — no
build step, no CI. This file describes how the deployment is configured and
what to touch when adding to it. Guidance for working *in* the repo (D1 auth,
the apply routine) is in `CLAUDE.md`; the character creator documents itself
in `apps/character-creator/README.md`.

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
│   ├── filament-forge/       AI slicer-settings engine
│   ├── media-vault/          Personal media library
│   └── character-creator/    Palladium/Rifts character builder — the big one;
│                             see its README for everything about it
├── db/
│   ├── schema.sql            Shared D1 schema — MediaVault + character creator.
│   │                         Idempotent: every statement IF NOT EXISTS
│   └── migrations/           One-shot ALTERs, tracked in schema_migrations
├── scripts/
│   └── d1-apply.mjs          The migration/data-script apply routine
└── functions/
    └── api/
        ├── _lib/access.js    Cloudflare Access identity — the ONE place the
        │                     identity header is read
        ├── _lib/claude-client.js  The only code that calls the Anthropic API
        ├── claude.js         /api/claude — proxy (model allowlist + token cap)
        ├── media.js          /api/media — MediaVault CRUD, per-user via Access
        └── character-creator/  ~20 endpoints + _lib; see the app README
```

Cloudflare Pages deploys `functions/` as serverless Workers automatically —
`claude.js` becomes `/api/claude`, and directories map to routes. The D1
database (`nates-workshop-media`) is bound as `DB` in `wrangler.jsonc`.

## How deploys work

Merging to `main` **is** the deploy. Pages builds nothing (no build command)
and publishes the repo root. Schema changes are applied by hand **before** the
merge that needs them:

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-whatever.sql
```

See `apps/character-creator/README.md` → *Production configuration* for the
full migration convention, and `CLAUDE.md` for the `CLOUDFLARE_API_TOKEN`
setup the routine expects.

## Environment configuration (Cloudflare Pages dashboard)

Settings → Environment variables, both encrypted:

- `ANTHROPIC_API_KEY` — used by the `/api/claude` proxy and the character
  creator's PDF importers. A new value takes effect on the **next deployment**.
- `ADMIN_EMAIL` — the single email allowed to use the importers and catalog
  editor. The check **fails closed** when unset.

## Access (the login wall)

Cloudflare Zero Trust → Access fronts the whole site — application domain set
to the Pages URL with the path blank, so every route including `/api/*` is
covered. The allow policy is a plain email list; add a friend by adding their
email. Sessions are one-time email codes. There is **no Access policy-as-code
in the repo** — it is dashboard-only.

The Workers read the identity from the `Cf-Access-Authenticated-User-Email`
header in exactly one place: `functions/api/_lib/access.js`. On localhost,
where Access is absent, the character creator's auth falls back to
`dev@localhost`.

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
   `functions/api/media.js` pattern — identity via `_lib/access.js`
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
