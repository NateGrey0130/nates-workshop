# Prompt: Bring FilamentForge onto the workshop standard

Work in `C:\Users\natha\Projects\nates-apps` (sessions start in Downloads; the repo is there). Before touching anything, read the root `CLAUDE.md`, `SETUP.md`, and `apps/character-creator/README.md` — the character creator is the reference implementation for the standard you are bringing FilamentForge up to.

## Context

FilamentForge (`apps/filament-forge/`) is already on the shared front-end framework: three-file split, registered in `apps/manifest.json`, Claude calls through the shared `claudeRequest` proxy. What it lacks is everything server-side:

- All user data lives in localStorage (`ff_config`, `ff_history`, `ff_presets`, `ff_custom_filaments`, `ff_onboarding_done`) — device-local, lost on a browser clear.
- The brand/filament catalog is fetched client-side from `https://api.openfilamentdatabase.org/csv/brands.csv` and `.../filaments.csv` on every page load — a hard runtime dependency on a third-party site.
- It has no `functions/api/filament-forge/` namespace, no README, no tests.

Decisions already made — do not relitigate:
1. Presets, history, custom filaments, and printer config all move to D1, keyed to the Cloudflare Access email.
2. The OFD catalog gets snapshotted into D1 with a refresh script; the app reads only from our own API.
3. The work lands as **two PRs**, described below. Finish PR 1, open it, and stop for review before starting PR 2.

## Hard rules (collision avoidance)

The site is one Pages project with one shared D1 database (`nates-workshop-media`, bound as `DB`). The character creator's tables are unprefixed, so:

- **Every new table is prefixed `ff_`.** Never create, alter, or read a table that isn't `ff_`-prefixed (except `claude_usage` if the shared proxy already handles that — don't touch it either way).
- All new endpoints live under `functions/api/filament-forge/`. Do not modify anything under `functions/api/character-creator/` or the shared `functions/api/_lib/` and `functions/api/_middleware.js` — if a shared helper seems to need a change, stop and ask.
- Schema additions are appended to the root `db/schema.sql` as idempotent `CREATE TABLE IF NOT EXISTS` / `CREATE INDEX IF NOT EXISTS` statements. No per-app wrangler config, no migrations directory.
- Identity comes from `functions/api/_lib/access.js` (`getAccessEmail`) — the one and only place Access identity is read.

## PR 1 — schema, API, persistence

**Schema** (append to `db/schema.sql`):
- `ff_brands`, `ff_filaments` — the OFD snapshot. Mirror the CSV columns you actually use plus a `fetched_at` timestamp.
- `ff_presets`, `ff_history`, `ff_custom_filaments`, `ff_config` — per-user tables, each with an `email` column and sensible indexes. Look at how the character creator shapes per-user rows first and match it.

**OFD refresh**: a script in `scripts/` (e.g. `ofd-refresh.mjs`, matching the style of the existing `scripts/*.mjs`) that fetches both CSVs, upserts into `ff_brands`/`ff_filaments`, and reports row counts. It should target either local or remote D1 the same way the existing scripts do (`scripts/d1-apply.mjs` / `d1-query-lib.mjs` are the pattern). Run it against remote once so production has data before the front-end switch lands. Note: `npx wrangler whoami` exits non-zero by design under the scoped token — the health check is `npx wrangler d1 info nates-workshop-media`. Local D1 is stale relative to production; verify data against `--remote`.

**API** under `functions/api/filament-forge/`:
- `GET catalog` — brands + filaments from the snapshot (shape it to what `app.js` needs, not to the raw CSVs).
- CRUD for presets, history, custom filaments, and config, scoped to the caller's email.
- `POST import` — one-time migration: accepts the caller's localStorage payload and inserts it, idempotently.

**Front-end** (`apps/filament-forge/app.js`):
- Replace the OFD fetch with `GET /api/filament-forge/catalog`.
- Replace localStorage reads/writes with the API. On first load, if the ff_ localStorage keys exist and the server has no data for this user, POST them to `import`, then clear or mark them migrated. Keep `ff_onboarding_done` in localStorage — it's per-device by nature.
- Degrade sanely: if the catalog is empty (refresh never ran), say so in the UI instead of silently showing nothing.

**Verify** before opening the PR: `npx wrangler d1 execute DB --local --file db/schema.sql`, run the refresh script locally, then `npx wrangler pages dev` from the repo root and exercise the app in a browser — save a preset, reload, confirm it round-trips through D1. Take a screenshot of the working UI; metrics alone don't count as proof.

## PR 2 — README and tests (after PR 1 merges)

- `apps/filament-forge/README.md` in the spirit of the character creator's: what the app is, where everything lives, the data model (each `ff_` table and what owns it), the API surface, and the OFD refresh procedure.
- `apps/filament-forge/test/smoke.mjs` following the character-creator test conventions (`apps/character-creator/test/` is the pattern — reuse its harness approach, don't invent a new one). Cover the pure logic worth pinning (settings computation, CSV/catalog shaping) and pin the README the same way the character creator's suite does, so docs drift fails the tests.
- Wire it into however the existing test commands are run/documented so it isn't an orphan.

## Workflow

Branch per PR off `main`, carry each PR through end-to-end (code, verify, push, open PR) without checking in at every step, then stop for review — merging to `main` is the deploy, and merges happen on Nate's word, not yours. Commit messages and PR bodies follow whatever style the recent PRs in this repo use.
