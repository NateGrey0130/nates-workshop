# FilamentForge — AI slicer settings for Bambu printers

Pick a printer, pick a filament, say what the print is for, and get a full set
of Bambu Studio slicer settings back — temperatures, speeds, layers, cooling,
supports, adhesion and the advanced numbers — with notes on why. Optionally
drop a 3MF or STL on it first and the model's dimensions and triangle count
ride along into the request. Results land in a history you can reload, and the
ones worth keeping become named presets.

Part of Nate's Workshop: Cloudflare Pages + D1, behind the site-wide Access
gate. No build step, no framework, no dependencies. The settings themselves
come from Claude through the site's `/api/claude` proxy — the model and prompt
live in `app.js`, the key lives on the server.

---

## Where everything lives

```
apps/filament-forge/
├── index.html            The page: sidebar (printer + filament + intent),
│                         results / history main tabs, onboarding + export modals
├── styles.css            Loaded after /shared/styles.css
├── app.js                Everything the page does, one plain script
├── vendor/
│   └── jszip.min.js      JSZip v3.10.1, vendored — see "What still leaves the site"
└── test/
    └── smoke.mjs         Pure logic + the claims this README makes

functions/api/filament-forge/
├── _lib/common.js        Identity (Access email, dev@localhost fallback) + JSON helper
├── catalog.js            GET  /api/filament-forge/catalog — the OFD snapshot
└── data.js               GET/PUT /api/filament-forge/data — everything per-user

db/schema.sql             The six ff_ tables (and migration 039-filament-forge.sql,
                          which brought them to a database that predates them)
scripts/ofd-refresh.mjs   Rebuild the OFD snapshot; the ONLY code that talks to OFD
scripts/ofd-refresh-lib.mjs  Its deterministic half, so the smoke test can run it
```

Run the tests from anywhere:

```
node apps/filament-forge/test/smoke.mjs
```

The shared framework rules apply: the app is registered in
`apps/manifest.json`, loads `/shared/styles.css` then its own, and uses
`/shared/js/ui.js` (modals, copy feedback) and `/shared/js/api.js`
(`claudeRequest`).

## Data model

Six tables in the site's shared D1 database, every one prefixed `ff_` — the
character creator's tables share that database unprefixed, so the prefix is
the collision boundary. Nothing here joins to, reads, or is read by any other
app's table.

| Table | Notes |
|---|---|
| `ff_brands` | The OFD snapshot's brands: `id` (OFD's uuid), `name`, `fetched_at`. |
| `ff_filaments` | The snapshot's filaments, keeping OFD's CSV column names (`brand_id`, `min_print_temperature`, …) so the client's field handling never changed when the fetch moved server-side. `fetched_at` is the same instant on every row of a snapshot; the catalog endpoint reports `MAX(fetched_at)` as the snapshot's age. |
| `ff_config` | The three sidebar dropdowns — printer, nozzle, AMS — one row per user, upserted on every change. |
| `ff_history` | One row per generated result, **capped at fifty per user** by the endpoint (the client has always kept fifty). `settings` and `raw_json` are the parsed and unparsed halves of the same Claude response; both are stored because both are displayed. |
| `ff_presets` | A history entry the user named and chose to keep — same shape plus `preset_name` and `saved_at`, and no cap, because saving is deliberate where history is automatic. |
| `ff_custom_filaments` | A filament the user typed in because OFD does not list it: brand, name, material, and the four temperature bounds. |

The user tables key on the Cloudflare Access email, the way `media_items`
does. Rows round-trip in insertion order (`ORDER BY rowid`), so the client's
newest-first arrays come back exactly as they were sent.

## The OFD snapshot

The app used to fetch the Open Filament Database's CSVs from the browser on
every page load, which made a third-party site a runtime dependency — when OFD
blinked, the filament picker died. Now the catalog is a snapshot in D1 and
only one script ever talks to OFD:

```
node scripts/ofd-refresh.mjs --remote
```

(`--local` for a dev database; the target is explicit because an accidental
`--remote` is the costly direction.) The script fetches both CSVs, refuses an
implausibly small result — an OFD outage must not replace a good snapshot with
an empty one — rewrites `ff_brands`/`ff_filaments`, and verifies by querying
the counts back rather than trusting wrangler's exit code. The generated SQL
is pure ASCII: brand names carry `–` and `™`, and every non-ASCII character is
spliced in as `char(N)` because non-ASCII through wrangler on Windows has
produced mojibake in production before.

The cost of a snapshot is staleness. Nothing refreshes it automatically; run
the script when the catalog feels thin. If the tables are empty the app says
so in the sidebar status line instead of breaking, and manual entry still
works.

## API surface

Two endpoints, both requiring the Access identity (locally, `wrangler pages
dev` has no Access in front of it, so `localhost` gets `dev@localhost` — the
same fallback the character creator uses):

- `GET /api/filament-forge/catalog` → `{ fetchedAt, brands, filaments }`, the
  whole snapshot. Read whole on purpose: the client filters and groups in
  memory, and the snapshot is a couple thousand small rows.
- `GET /api/filament-forge/data` → `{ email, config, history, presets,
  customFilaments }`, everything the caller has, one round trip at boot.
- `PUT /api/filament-forge/data` with any subset of `{ config, history,
  presets, customFilaments }` — replaces exactly the collections the body
  carries and leaves the rest alone. MediaVault's whole-library-replace
  pattern, per collection: the client's in-memory arrays are the source of
  truth and every save sends the whole collection it changed.

There is no per-row endpoint. Deleting one history entry re-sends the other
forty-nine; at these sizes that is simpler than a CRUD surface, and it is what
makes the localStorage import below a plain PUT rather than a special path.

## Persistence, and the one-time localStorage import

Before migration `039` this app kept everything in localStorage under four
keys: `ff_config`, `ff_history`, `ff_presets`, `ff_custom_filaments`. On every
load the app now GETs `/data`; if the server has nothing for this user and any
of those keys exist, it PUTs their contents up and removes the keys — but only
after the PUT succeeds, because until that moment localStorage is still the
only copy. A browser that never had data just starts empty.

`ff_onboarding_done` stays in localStorage on purpose: whether this device has
seen the intro modal is per-device by nature.

If the server cannot be reached at boot, the session runs on whatever the
legacy keys still hold (so the import retries next load); if a later save
fails, the app says so once rather than silently dropping writes.

## What still leaves the site

One thing: `/api/claude`, the site's proxy — the generation request itself.

JSZip used to be the other one, fetched from cdnjs the first time a `.3mf`
was dropped (a 3MF is a zip; the STL path needs nothing). It is now vendored
at `vendor/jszip.min.js` — JSZip v3.10.1, dual-licensed MIT/GPLv3, committed
byte-exact (`.gitattributes` exempts the vendor directory from line-ending
normalization) so its SHA-512 still matches the SRI cdnjs publishes for that
version. Still loaded lazily: most sessions never upload a 3MF, so the 95 KB
stays off the boot path.

No external origin appears anywhere in `app.js` — not
`openfilamentdatabase.org`, not `cdnjs.cloudflare.com` — and the smoke test
pins that as a grep rather than trusting this paragraph.

## Printers

Six Bambu Lab models are hardcoded in `PRINTER_SPECS` in `app.js` — P2S, P1S,
P1P, X1C, A1, A1 Mini — each carrying max speed, acceleration, volumetric
flow, chamber and bed type, which go into the prompt so the model reasons from
the machine's real limits. Adding a printer is one line there and one
`<option>` in `index.html`.

## Tests

`test/smoke.mjs` uses the character creator's test harness (`section` /
`check` / `summary`) and covers what is deterministic:

- the CSV parser (quoted fields, escaped quotes, CRLF, garbage lines, dedupe)
- the generated snapshot SQL (pure ASCII whatever the input, quote doubling
  reversible, chunking at the statement cap, deletes before inserts)
- the `data.js` sanitizers (what they refuse, what they cap, and that an
  entry survives the row round-trip)
- this README's claims: the six table names against `db/schema.sql`, the
  migration file, the endpoint files, the history cap against the endpoint's
  constant, the printer count against `app.js`, the localStorage keys, the
  vendored JSZip's version against its own header, and that `app.js` names no
  external origin at all

The last group exists so this file cannot quietly stop being true — the same
bargain the character creator's README has with its own suite.
