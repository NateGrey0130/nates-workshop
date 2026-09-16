# MediaVault — bulk edit and delete: gap analysis

> **Since 2026-09-16 the closed findings live in `BULK-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

A feature menu, findings `B1`…`B9`, to be taken one at a time. **Every finding here is now
closed**, across PRs #315–#325 — B1–B8 built, **B9 declined** as it recommended. **B6 was the largest item and
took two of them** — #323 for its layer 1, which is the ISBN file's `F7`, then
#324 for the rest. Each outcome note sits under its own finding, and the
evidence throughout describes the app as it stood **before** any of this landed.

**Investigated 2026-08-26** against `9d16e9a` (`main`). The live ISBN bug is a
separate file, `ISBN-AUDIT.md`, whose findings are numbered
`F1`…`F10` — all shipped but `F7`. Two findings here depend on that file and
say so by number.

**Adjusted 2026-08-31.** The sentence above is the state on the morning of
2026-08-26 and it is left standing as one. `ISBN-AUDIT.md` `F1`-`F10` are
**all ten closed**, `F7` included: it shipped later the same day as PR #323,
which is the same PR the paragraph above already credits with B6's layer 1.
The two statements were three lines apart and disagreed from the moment the
second was written. Read each finding's own note; this header is a summary and
summaries here go stale.

Much of what the brief asks for already exists. Where it does, this says so and
gives the line that proves it, rather than proposing it again.

## How this was verified

- **Code** — `apps/media-vault/app.js`, `index.html`,
  `functions/api/media-vault/items.js`, `items/bulk.js`, `items/bulk-update.js`,
  `items/bulk-delete.js`, `_lib/common.js`, `db/schema.sql`,
  `apps/media-vault/test/smoke.mjs`.
- **Local dev** — `wrangler pages dev` on port **8801** (not 8788, which was
  already listening and is not this worktree), against a local D1 built from
  `db/schema.sql`. The running build was confirmed to be `9d16e9a` before
  anything was concluded. Every claim below about behaviour was **reproduced in
  the browser or against the running endpoints**, not read off the source.
- **Production shape** — read-only `--remote` aggregate query only. No writes.

**Caveat that bounds everything here:** local D1 is Miniflare's SQLite, not
production D1. Timings from it are a floor, not a forecast. The *documented*
D1 limits below were read from Cloudflare's own limits page, not inferred from
local behaviour.

## Production shape, as of 2026-08-26

Read-only aggregate over `media_items`. These numbers move; do not quote them as
fixed.

| | |
|---|---|
| Distinct users | 1 |
| Rows | 3,544 (71% of the 5,000 cap) |
| Rows with an empty `cover` | 1,579 (44.5%) |
| Rows with an empty `author` | 889 |
| Rows with an empty `genre` | 1,071 |
| By type | 2,906 audiobook · 580 movie · 58 series |
| First / last `added_at` | 2026-04-26 / **2026-08-24** |

The last item was added two days before this audit, so the library is in active
use. The 1,579 coverless rows are the size of the prize for **B6**.

## The four asks, scored

| # | Ask | Verdict | Proof |
|---|---|---|---|
| 1 | **Bulk delete** across library / list / search / filtered views | **Satisfied** for the grid and list views, and it does span the whole filter, not the page | `bulkDelete` `app.js:427-440` → `items/bulk-delete.js`; checkboxes are rendered into both the grid card (`app.js:108`) and the list row (`app.js:128`); the id list comes from `getFilteredIds()` over the entire filtered set (`app.js:383-397`). Absent only on the Stats view — **B9**, and it should stay absent |
| 2 | **Bulk edit of common fields** | **Partly** — the server already allows `format`, the UI never offers it; nothing else is reachable at all | `SETTABLE` is `{type, format}` at `items/bulk-update.js:8-11`; the bulk bar offers only three type buttons, `index.html:328-331`. **B4** (free) and **B5** (the rest) |
| 3 | **Select-all-matching-filter** | **Satisfied, and genuinely — but it misleads** | `bulkSelectAll` → `getFilteredIds` → `getFilteredLibrary` (`app.js:19-37`) walks the whole `library` array, which is the complete library in memory (see below), while `renderLibrary` paginates only the render at `app.js:90-93`. Reproduced: 61 items, page shows 20, "Select All" selects **61**. The problems are that nothing on screen says so (**B7**) and that the selection is not scoped to the view it was made in (**B2**) |
| 4 | **Bulk re-lookup / enrich** | **Absent**, and blocked | No endpoint, no client function, and — the harder problem — `media_items` stores no ISBN and no TMDB id, so there is nothing to re-look-up *by*. **B6**, which depends on **F7** |

**The in-memory `library` really is complete.** `items.js:15-19` selects every
row for the caller with no `LIMIT` or `OFFSET`; `app.js:913` assigns the whole
result to `library`; pagination happens only inside `renderLibrary`
(`app.js:90-93`). This is the load-bearing fact under **B1** — the undo buffer
can be taken from memory because memory holds everything, not a page.

## Which screens lack selection, and whether they should have it

| Screen | Selection today | Should it have bulk actions? |
|---|---|---|
| Library — **grid** | Yes (`app.js:108`) | Already does |
| Library — **list/table** | Yes (`app.js:128`) | Already does |
| Library under a **type filter** or **search** | Yes, and it spans the whole filtered set | Already does — but see **B2**, **B7** |
| **Stats** page and its ranked lists (`renderStats` `app.js:1025`, `renderRankedList` `app.js:977`) | No checkboxes (verified: 0 `input[type=checkbox]` inside `#statsPage`) | **No — deliberately.** See **B9**. The bar leaking in there today is a bug, **B3** |
| **Detail** modal | n/a, one item | No — it has its own Edit and Delete |
| **Add/Edit** modal | n/a | No |
| **CSV import preview** | No | No — nothing exists to select yet; the rows are not in the library until Import is pressed |

## Hard limits, checked rather than assumed

**Documented (Cloudflare D1 limits page):**

- **Maximum bound parameters per query: 100.** The endpoints chunk at 90
  (`bulk-delete.js:29`, `bulk-update.js:45`, `bulk.js:41`), and the README pins
  that number at `apps/media-vault/README.md:90-93`.
  - `bulk-delete`: 1 email + 90 ids = **91**. Safe.
  - `bulk-update`: *n* set-values + 1 email + 90 ids = **93** with today's two
    fields. **The headroom is nine more fields in one call** — relevant to B5.
  - `bulk.js` upsert: 14 parameters per statement, independent of batch size.
- **Maximum SQL statement length: 100 KB**, applied to *each statement inside a
  batch*. A 90-id `IN()` list is nowhere near it.
- **Maximum SQL query duration: 30 seconds**, and Cloudflare's own footnote says
  this applies to **the entire `batch()` call**, not per statement. This is the
  real ceiling on a 5,000-row operation.
- **`batch()` is a SQL transaction.** Cloudflare: *"If a statement in the
  sequence fails, then an error is returned for that specific statement, and it
  aborts or rolls back the entire sequence."* So **a bulk delete or update
  cannot be half-applied server-side** — it is all or nothing. That closes the
  brief's partial-failure worry for the *server*; the client-side drift question
  survives as **B8**.

**Measured, local dev, 3,544-row scale (Miniflare SQLite — a floor, not a
forecast):**

| Operation | Result |
|---|---|
| `items/bulk` upsert 3,000 items | 200, 330 ms |
| `items/bulk-update` 3,005 ids | 200, `count: 3005`, 35 ms |
| `items/bulk-delete` 4,906 ids (55 chunks) | 200, `count: 4906`, 42 ms |
| Client: 200 checkbox toggles at 3,544 rows | 19.6 ms total, **0.1 ms each** |
| Client: `bulkSelectAll()` at 3,544 rows | **3.5 ms** |
| Client: one `updateBulkBar()` at 3,544 rows | **0.2 ms** |
| Request body for a 3,544-id delete | **30,795 bytes**, 40 chunks of 90 |

**There is no performance finding here.** `updateBulkBar` re-walks the entire
library on every checkbox click, which looks alarming and is not: 0.1 ms per
toggle at production scale. Do not "optimise" it.

**At the `MAX_ITEMS` boundary** (local library filled to exactly 5,000):

| Attempt | Result |
|---|---|
| `POST /items`, **new** id | `400 Library is full (max 5000 items)` |
| `POST /items`, **existing** id | `200` — edits still work at the cap, correctly |
| `POST /items/bulk`, 1 **new** item | `400 Import would exceed the library cap (max 5000 items)` |
| `POST /items/bulk`, 1 **existing** item | `200` |
| `bulk-update` / `bulk-delete` with 5,001 ids | `400 Too many ids (max 5000)` |

The cap behaves correctly and says so out loud. It matters for **B1**: an undo
restore is a `bulk` upsert of ids the library *used to have*, so it fits — unless
the user filled the freed space inside the undo window.

---

# Findings

Safety first, then capability, then the smaller ones.

---

- **B1** — Bulk delete is permanent the instant it is confirmed, with no undo — - Taken, 2026-08-26 (PR #319): all seven points as specified — capture — full text in `BULK-AUDIT.closed.md` under its own `## B1` heading.

- **B2** — A selection is never cleared when the view changes, so Delete can take out items the user cannot see — - Taken, 2026-08-26 (PR #317): the recommended scope-to-the-view option, — full text in `BULK-AUDIT.closed.md` under its own `## B2` heading.

- **B3** — The bulk bar follows the user into the Stats view, with a live Delete and no visible way out — - Taken, 2026-08-26 (PR #316): as proposed — leaving the library ends — full text in `BULK-AUDIT.closed.md` under its own `## B3` heading.

- **B4** — `format` is already bulk-settable on the server and unreachable in the UI — - Taken, 2026-08-26 (PR #315): as proposed, generalising `bulkChangeType` — full text in `BULK-AUDIT.closed.md` under its own `## B4` heading.

- **B5** — No field beyond `type` and `format` can be bulk-edited, and the current design cannot express a free-text one — - Taken, 2026-08-26 (PR #322): the `{ values }` / `{ text: true }` shape as — full text in `BULK-AUDIT.closed.md` under its own `## B5` heading.

- **B6** — Bulk re-lookup / enrich does not exist, and cannot be exact until the source id is stored — - Taken, 2026-08-26: layer 1 as PR #323 (which is F7, taken first and — full text in `BULK-AUDIT.closed.md` under its own `## B6` heading.

- **B7** — "Select All" reaches past the page and nothing on screen says so — - Taken, 2026-08-26 (PR #318): all three parts as proposed — the button — full text in `BULK-AUDIT.closed.md` under its own `## B7` heading.

- **B8** — `bulkChangeType` assumes every row it selected was changed, and never reads the count the server returns — - Taken, 2026-08-26 (PR #321): as proposed, and two of this finding's — full text in `BULK-AUDIT.closed.md` under its own `## B8` heading.

- **B9** — Bulk actions on the Stats screen: don't build them — - Declined, 2026-08-26 (PR #325), on Nate's word: *"I don't think B9 adds — full text in `BULK-AUDIT.closed.md` under its own `## B9` heading.

## Ordering, if you want one

`B4` → `B3` → `B2` → `B7` → `B1` → `B5` → `B6`, with `B8` whenever and `B9`
closed on sight.

B4 is nearly free and proves the bulk-bar UI pattern. B3 and B2 are small,
contained safety fixes with no server or schema exposure, and B1's undo is worth
more once they have removed the ways a selection goes wrong. B5 and B6 are the
two that cost real work — B5 breaks two smoke checks and a README line by
design; B6 wants a schema column and shares its lookup loop with the ISBN
audit's F9, so it should follow that work rather than lead it.
