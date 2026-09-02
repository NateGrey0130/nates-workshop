# Media Vault standardization — D1-only storage, kill local/cloud sync

## Context

Repo: `C:\Users\natha\Projects\nates-apps` (Nate's Workshop monorepo, Cloudflare Pages + one shared D1 database `nates-workshop-media` bound as `DB`). The app is `apps/media-vault/` (index.html + styles.css + app.js, no build step). Read the repo root `CLAUDE.md` before touching wrangler or D1. Use the `ship-pr` skill for the branch/PR/deploy loop and the `schema-change` skill if any schema edit turns out to be needed.

Media Vault is already half-standard: it has a D1 table `media_items` (in `db/schema.sql`, keyed by `user_email` + `item_id`), a Pages Function `functions/api/media.js` (GET / whole-library PUT / single DELETE), and identity via `functions/api/_lib/access.js` (`getAccessEmail`). What it does NOT have is D1 as the source of truth.

**The bug being fixed:** `apps/media-vault/app.js` treats localStorage (`mv_library`) as the working copy. Every edit rewrites localStorage, then a debounced (1.5s) `PUT /api/media` **deletes the user's entire library and reinserts it**. On startup, if local and cloud both have items, a merge modal makes the user choose merge/local/cloud. A user reported local and cloud getting out of sync — which this design makes easy: a closed tab inside the debounce window loses the push, two open tabs clobber each other with full replaces, and one wrong merge-modal choice discards data. The fix is to remove local storage as a data store entirely and make D1 the only store.

## Locked decisions (do not re-litigate)

1. **D1 is the sole store.** localStorage is no longer read or written for library data. No offline mode, no cache, no merge modal. (Cloudflare Access fronts the whole site, so there is no unauthenticated production scenario.)
2. **One-time auto-migration, no modal.** On first load after this ships: if `mv_library` in localStorage is non-empty, send it to a one-shot merge endpoint. Server merges: items whose `title+type` (case-insensitive title) already exist in the user's cloud rows are skipped (cloud wins), the rest are inserted. On success, `localStorage.removeItem('mv_library')` — permanently. If the migration call fails, leave localStorage untouched and retry next load; never delete local data before the server confirms.
3. **Per-item CRUD replaces the whole-library PUT.** Create/update/delete touch only the affected rows. Bulk operations (CSV import, bulk type-change, bulk delete) get bulk endpoints that operate on explicit id lists / item lists — nothing ever does `DELETE ... WHERE user_email = ?` for a full replace again.
4. **Lookups move server-side.** The TMDB API key currently hardcoded in `app.js` (`TMDB_KEY`) moves to a Pages env secret (e.g. `TMDB_API_KEY`); the client calls a new lookup proxy instead of TMDB/OpenLibrary directly. Cover images remain hotlinked from `image.tmdb.org` / `covers.openlibrary.org` — do not proxy images.
5. **Keep the `media_items` table as-is.** No rename to an `mv_` prefix, no schema change expected (per-item CRUD fits the existing columns). If a column does become necessary, follow the `schema-change` skill.
6. **Two PRs, FilamentForge-style:** PR 1 = API + client migration; PR 2 = README + smoke tests pinning the new behavior. Schema/data changes (if any) are applied to remote D1 BEFORE the merge that deploys the code needing them.

## PR 1 — API + client

### API (`functions/api/media-vault/` — new namespace, matching `api/filament-forge/`)

Move Media Vault's API under its own namespace like FilamentForge's. Keep `functions/api/media.js` working during the transition only if needed for deploy ordering; end state is the old whole-library PUT **gone** (the old file deleted or reduced to the new handlers — no code path that replaces a whole library except the explicit migration endpoint).

Endpoints (all identity from `getAccessEmail`, all scoped to the caller's rows, JSON in/out, reuse the existing `sanitizeItem`-style validation: string id ≤100 chars, non-empty title, field cap 4000 chars, library cap 5000 items):

- `GET /api/media-vault/items` → `{ email, items }`
- `POST /api/media-vault/items` — body one item → upsert that row (`INSERT OR REPLACE` on `(user_email, item_id)`)
- `POST /api/media-vault/items/bulk` — body `{ items: [...] }` → upsert many (CSV import); enforce the 5000-item cap counting existing rows
- `POST /api/media-vault/items/bulk-update` — body `{ ids: [...], set: { type } }` → bulk type change (whitelist which fields are settable)
- `POST /api/media-vault/items/bulk-delete` — body `{ ids: [...] }`
- `DELETE /api/media-vault/items?id=...` — single delete
- `POST /api/media-vault/migrate` — body `{ items: [...] }` → the one-shot merge from decision 2. Idempotent: safe to call twice.
- `GET /api/media-vault/lookup?...` — the proxy from decision 4. Sub-modes mirroring the current client calls: ISBN lookup, book title search, book author search (all OpenLibrary), movie/tv title search, person (actor/director) search + credits, and detail fetch with credits (TMDB, key from `context.env.TMDB_API_KEY`). Return only the fields the client renders — don't relay raw TMDB payloads.

**Secret setup:** the local `CLOUDFLARE_API_TOKEN` is D1-scoped and cannot touch Pages settings; the `TMDB_API_KEY` secret must be added in the Cloudflare dashboard (Pages project → Settings → Environment variables) by Nate / via real Chrome. The lookup endpoint must fail with a clear JSON error if the secret is missing. Coordinate ordering: add the secret before merging the PR that requires it.

### Client (`apps/media-vault/app.js`)

- Delete: `saveLibrary()`'s localStorage write, `syncToCloud`/`pushAllToCloud`/debounce, `initSync`'s branching, the merge modal (`openMergeModal`/`handleMerge` + its HTML/CSS), and all `mv_library` reads except the one-time migration check.
- Startup: run migration check (decision 2), then `GET /api/media-vault/items`, render. If the API call fails, show an error state with a retry button — not an empty library, and not local data.
- Writes: save/edit → upsert endpoint; delete → delete endpoint; bulk ops → bulk endpoints; CSV import → bulk upsert. After each write either apply the change locally in the in-memory `library` array on 2xx (current pattern) or re-fetch — but on ANY non-2xx, surface the error and leave the UI consistent with the server (re-fetch on failure is the simple correct option).
- Repurpose the sync dot as a save-status indicator (saving / saved / error). An error state must be loud enough to notice — the old design's failure mode was silent divergence.
- Lookups: point `lookupISBN`/`lookupBook`/`lookupTMDB`/`selectTMDBResult` at `/api/media-vault/lookup`; remove `TMDB_KEY`, `TMDB_BASE`, and all direct `openlibrary.org`/`api.themoviedb.org` fetches. `ITEMS_PER_PAGE` pagination, filtering, sorting, stats all stay client-side over the in-memory array — no server-side querying needed at this scale.
- `mv_` localStorage keys that are pure UI convenience (none currently exist, but e.g. a remembered view mode would be fine) are allowed; library DATA in localStorage is not.

### Verification (before calling PR 1 done)

- Local: `npx wrangler d1 execute DB --local --file db/schema.sql` then `npx wrangler pages dev` from the repo root (use the Downloads `launch.json` browser preview — port 8788 may belong to another worktree; verify you're on your own server).
- Exercise in the browser and screenshot: add via ISBN lookup, add via TMDB lookup, edit, single delete, bulk type-change, bulk delete, CSV import, CSV export, reload-and-still-there. Seed `mv_library` in localStorage manually and confirm the one-time migration merges (dupe by title+type skipped), clears the key, and never re-fires.
- Confirm via devtools network tab that no request leaves the origin except cover image hotlinks.
- Run the full smoke suite; it must stay green.

## PR 2 — README + smoke tests

- Rewrite `apps/media-vault/README.md` (or create it) to describe the D1-only design: storage model, endpoint list, the migration behavior, the lookup proxy, and the secret dependency. Follow the repo rule: any count or endpoint list quoted in the README must be pinned by a smoke test, not prose (`docs-quote-moving-numbers`).
- Add a Media Vault smoke suite following FilamentForge's pattern: endpoints exist and reject unauthenticated/malformed input, per-item upsert round-trips, bulk caps enforced, migration endpoint idempotent, lookup endpoint errors cleanly without the secret, and a static check that `apps/media-vault/app.js` contains no `localStorage.setItem('mv_library'` and no hardcoded TMDB key / direct third-party API URL.
- Wire the suite into whatever `ship-pr` runs so it executes on every PR.

## Process

- One unit of work end-to-end per PR; check in at PR boundaries (Nate's standing preference). Merging to `main` is the deploy; there is no CI build step.
- Any remote D1 change: `npx wrangler d1 execute nates-workshop-media --remote --file ...` BEFORE merging the dependent code. Audit data against `--remote`, not the stale local DB.
- Do not use inline Bash heredocs for files containing Windows paths — write scripts with the Write tool.
