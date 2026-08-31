# MediaVault — bulk edit and delete: gap analysis

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

## B1 — Bulk delete is permanent the instant it is confirmed, with no undo

**What's wrong.** `bulkDelete` confirms once and then destroys the rows. The
confirm text — *"Permanently delete N item(s)? This cannot be undone."* — is
accurate, which is the problem: on a library of thousands, a mis-scoped
selection (see **B2**) can take out most of it with one click.

**Evidence.** `app.js:427-440`. Line 429 is the confirm; line 436,
`library = library.filter(item => !selectedIds.has(item.id));`, **discards the
deleted objects** — after this line the only copy of those rows is gone from the
client too. `items/bulk-delete.js:33` issues a real `DELETE`, no soft-delete
column anywhere in `db/schema.sql:13-29`.

**Proposed fix.** An undo toast backed by the copy the client already holds. The
shape is fixed — no schema change, no `deleted_at`, no trash table. The details
that decide whether it works:

1. **Capture before the filter.** In `bulkDelete`, before line 436:
   `const restoreBuffer = library.filter(i => selectedIds.has(i.id));`
   This is safe because `library` is the **complete** library, not a page or a
   filtered subset — proved above from `items.js:15-19` and `app.js:913`. The
   buffer is therefore always exactly the rows deleted. If that ever stops being
   true (a future paginated GET), this design collapses; say so in the code
   comment.
2. **Window: 10 seconds**, counted from when the toast appears, with the
   remaining seconds visible on the button. Long enough to catch the "oh no"
   reflex, short enough that the user is still on the page and has not started
   the next operation. Do not make it dismissable-by-clicking-elsewhere; require
   either Undo or the timer.
3. **On navigate or reload inside the window: the rows are gone, permanently.**
   The buffer is memory only and must stay that way — the alternative is writing
   deleted rows to localStorage, which is exactly the second-copy-of-the-truth
   this app was rebuilt to eliminate (`README.md:50-74`). Make the toast say so:
   *"Undo (9) — closing this page will finish the delete."* That is the honest
   contract, and it is the one thing about this design the user must be told.
4. **Restore goes through `POST /api/media-vault/items/bulk`.** It round-trips
   faithfully — **verified**: an item with every field populated (including
   quotes, commas and a newline in `notes`) was saved, read back, deleted, and
   restored through `items/bulk`; the JSON before and after was **identical,
   including `id` and `addedAt`**. Ids are preserved because `sanitizeItem`
   keeps `item.id` (`_lib/common.js:32`) and `UPSERT_SQL` binds it
   (`_lib/common.js:60-73`). This is a real restore, not a re-add.
5. **If the restore itself fails**, `apiWrite` already does the right thing: it
   alerts with the server's message and re-fetches the library from D1
   (`app.js:855-871`), so the screen ends up matching the database rather than
   drifting. Keep the buffer after a failed restore and leave the Undo button
   live for one retry; drop it after the second failure and tell the user
   plainly which items were lost.
6. **The one case that legitimately fails:** the user deletes 500 items, then
   inside the window imports a CSV that refills the library to 5,000. The
   restore is then refused with `Import would exceed the library cap (max 5000
   items)` (verified at the boundary above). Surface that message verbatim
   rather than a generic failure — it tells the user exactly what to do.
7. **Cancel the timer** if the user starts another bulk operation, and drop the
   buffer. Two overlapping undo windows is a bug generator.

**Blast radius.** `apps/media-vault/app.js` (the buffer, the timer, the restore
call), `apps/media-vault/index.html` + `styles.css` (the toast element),
`apps/media-vault/README.md` (the feature sentence at lines 3-8 mentions
"select many at once to retype or delete them"). **No schema change. No new
endpoint file** — it reuses `items/bulk`, which matters because `smoke.mjs:216-219`
asserts the endpoint files are *exactly the six documented*. **The 57-check
smoke suite still passes**: nothing pins `bulkDelete`'s body, and the structural
checks at `smoke.mjs:147-158` (every delete names `item_id`, no `onRequestPut`)
are untouched. **Verifiable before merge** end-to-end on a local library —
delete, undo, compare the round-tripped JSON, which is the test already run
above.

**Independence.** Take alone. It is **strictly better after B2**, because B2 is
what makes a catastrophic mis-selection possible in the first place — but B1 is
the safety net for every cause, not just that one.

- **Taken, 2026-08-26** (PR #319): all seven points as specified — capture
  before the filter, a 10-second window with the seconds on the button, memory
  only with the toast admitting a reload finishes the delete, restore through
  `items/bulk`, one retry on failure then naming the losses, the cap message
  surfaced verbatim, and any other bulk operation ending the window.

  **One behaviour change the finding did not anticipate:** a successful bulk
  delete now leaves select mode. The toast and the bulk bar want the same
  corner, and with the selection emptied there was nothing left for the bar to
  act on. Re-entering select mode therefore ends the undo window too.

  The load-bearing claim — that the in-memory array is the whole library, so
  the buffer is exactly the deleted rows — is now pinned by a smoke check on
  the capture ORDER, proven by swapping the two lines and watching it fail.
  Verified end to end against a real local database, including a row carrying
  quotes, a comma and a newline in `notes` coming back byte-identical, the
  clock running out with the delete standing, and a forced restore failure
  retrying once before naming the titles. Suite 90 to 97. **Merged 2026-08-26** as `ff9e2d7`.

---

## B2 — A selection is never cleared when the view changes, so Delete can take out items the user cannot see

**What's wrong.** `selectedIds` survives a filter change and a search change.
Neither clearing path exists, and neither code path even refreshes the bulk bar.
A user can select everything under "All", switch to "Movies", search, and be
looking at ten items while Delete is aimed at all of them.

**Evidence.** `setFilter` (`app.js:185-191`) and `resetPageAndRender`
(`app.js:14-17`) both call `renderLibrary()` and nothing else — no
`selectedIds.clear()`, no `updateBulkBar()`. Only `toggleSelectMode`
(`app.js:350`) ever clears. Reproduced in the browser on a 61-item local
library:

| Step | On screen | Selected | Bulk bar says | Delete would target |
|---|---|---|---|---|
| Select mode, Select All under **All** | 20 of 61 | 61 | "61 selected" | 61 |
| Switch filter to **Movies** | 15 of 15 | **61** | "61 selected" | **61** |
| Type search "Title 3" | 10 of 10 | **61** | "61 selected" | **61** |

The confirm would read *"Permanently delete 61 item(s)?"* while ten items are
visible. The count is at least honest; nothing else about the state is.

There is a second, sharper form. The Select All / Deselect All label is computed
only inside `updateBulkBar` (`app.js:404-406`) and `bulkSelectAll`, neither of
which runs on a filter change. Reproduced:

| Step | Selected | Button reads | Truthful label | What clicking it does |
|---|---|---|---|---|
| Select All under **Movies** | 15 | "Deselect All" | Deselect All | — |
| Switch filter to **Audiobooks** | 15 | **"Deselect All"** | **"Select All"** | `bulkSelectAll` recomputes and **selects 30 more**, taking the total to 45 |

A button labelled "Deselect All" that adds thirty items to the selection is the
worst version of this.

**Proposed fix.** Decide the scope rule first, then implement it — the two
options are genuinely different products:

- *Recommended, and the smaller change:* **selection is scoped to the view it
  was made in.** Clear `selectedIds` in `setFilter` and in
  `resetPageAndRender`, and call `updateBulkBar()` from both. Two lines each.
  Nothing can then be deleted that was not visible under the current filter.
- *Alternative, if cross-filter selection is wanted:* keep the selection but
  make the bulk bar show both numbers — `"61 selected (10 in this view)"` — and
  recompute the Select All label on every render. Strictly more code and a
  harder confirm dialog to word.

Either way, `updateBulkBar()` must be called from every path that changes the
filtered set. The cost is 0.2 ms at 3,544 rows (measured), so call it freely.

**Blast radius.** `apps/media-vault/app.js` only, four to six lines for the
recommended option. No endpoint, no schema change, smoke suite unaffected.
**Verifiable before merge** by replaying the two tables above locally.

**Independence.** Take alone. Pairs naturally with **B7**, which is the same
class of problem one step earlier.

- **Taken, 2026-08-26** (PR #317): the recommended scope-to-the-view option,
  but **pruned rather than cleared**. The finding proposed clearing the
  selection in `setFilter` and `resetPageAndRender`; `resetPageAndRender` runs
  on every KEYSTROKE in the search box, so clearing would discard a careful
  selection the moment somebody typed a letter. Pruning keeps whatever is
  still on screen and drops only what left — the same guarantee without the
  punishment. It is one-way on purpose: widening the filter again does not
  restore what was dropped, which is what makes the subset property hold
  rather than flicker.

  Verified as a property rather than a case: across six view changes every
  selected id was on screen at every step. The stale-label case from this
  finding is closed too — 20 movies selected, switch to Audiobooks, and the
  button now reads "Select All" with 0 selected. Delete after All → Movies
  confirms "20 item(s)" where it used to say 60. Suite 83 to 86.

  **Merged 2026-08-26** as `a47579b`.

---

## B3 — The bulk bar follows the user into the Stats view, with a live Delete and no visible way out

**What's wrong.** `switchView('stats')` hides the toolbar, the grid, the list
and the **Select** toggle — but leaves select mode on and the floating bulk bar
visible, Delete included, over the Stats page.

**Evidence.** `switchView` (`app.js:929-957`) sets
`btnSelectMode.style.display = 'none'` at line 945 and never touches
`selectMode`, `selectedIds` or `updateBulkBar`. Reproduced in the browser with
61 items selected:

```
after switchView('stats'):
  bulkBar visible ......... true
  selectMode still on ..... true
  items selected .......... 61
  Select toggle hidden .... true   (the control that would cancel it)
  checkboxes on the page .. 0
```

The bar's own Cancel button (`index.html:334`) is the only exit, plus Escape
(`app.js:1067-1068`). So it is escapable — but a live "🗑 Delete 61 items"
floating over a page with no checkboxes on it is a hazard, and it is the one
place bulk actions appear on a screen that has no items to act on.

**Proposed fix.** In `switchView`, when leaving the library view: if `selectMode`
is on, turn it off — call `toggleSelectMode()`, or inline the three lines
(`selectMode = false`, `selectedIds.clear()`, `document.body.classList.remove('select-mode')`)
and then `updateBulkBar()`. Hiding the bar without clearing the selection is the
wrong fix: coming back to the library would then restore a bar the user thought
they had left behind.

**Blast radius.** `apps/media-vault/app.js` only, inside `switchView`. No
endpoint, no schema change, smoke suite unaffected. Verifiable before merge with
the reproduction above.

**Independence.** Take alone.

- **Taken, 2026-08-26** (PR #316): as proposed — leaving the library ends
  select mode rather than hiding the bar, which the finding was right to warn
  against. Reproduced in production first, with a screenshot: the bar over the
  Stats page, 6 selected, Delete live, not a checkbox in sight.

  **The finding understated it by one step.** Select-mode state lives in four
  places — the flag, the body class, the toggle's label and `active` class, and
  the bar — and they were only ever set together inside `toggleSelectMode`, so
  the inline three-line fix the finding suggested would have desynced them:
  clearing the flag without resetting the toggle leaves it reading "✕ Cancel"
  on the way back. Everything moves through a new `setSelectMode(on)`, and a
  smoke check pins that `selectMode` is assigned in exactly one place.
  Suite 81 to 83. Escape, the bar's Cancel and library-to-library switching all
  verified unchanged.

  **Merged 2026-08-26** as `b64d144`.

---

## B4 — `format` is already bulk-settable on the server and unreachable in the UI

**What's wrong.** The endpoint accepts `format` today, validated against
`['digital','physical']`. The bulk bar offers only the three type buttons. This
is the cheapest bulk-edit win available and it needs no server work at all.

**Evidence.** `items/bulk-update.js:8-11`:

```js
const SETTABLE = {
  type: ['audiobook', 'movie', 'series'],
  format: ['digital', 'physical'],
};
```

`index.html:324-335` — the bar has `bulkCount`, `bulkSelectAllBtn`, three
`bulkChangeType` buttons, Delete, Cancel. No format control. Verified against
the running endpoint: `POST /items/bulk-update` with
`{ids: […3005 ids], set: {format: 'physical'}}` returned `{ok:true, count:3005}`,
and with `{type:'movie', format:'digital'}` together it returned the same — **both
fields in one call already work.**

**Proposed fix.** Mirror the existing type buttons: a second labelled group in
the bulk bar, *"Change format to →  💾 Digital  📀 Physical"*, calling a
`bulkChangeFormat(newFormat)` that is `bulkChangeType` with `set: { format }`.
Better still, generalise `bulkChangeType` into
`bulkSet(setObject, confirmLabel)` and have both call it — the two functions
would otherwise be identical but for one word.

**Blast radius.** `apps/media-vault/app.js`, `apps/media-vault/index.html`,
`apps/media-vault/styles.css` (reuse `.bulk-type-btn`). **No server change and
no schema change.** **The smoke suite still passes** — critically,
`smoke.mjs:167-174` asserts the settable fields are *exactly* `type` and
`format`, and this finding adds neither. Parameter count stays at 93 of 100.
Verifiable before merge locally.

**Independence.** Take alone. This is the one item on this menu that is close to
free.

- **Taken, 2026-08-26** (PR #315): as proposed, generalising `bulkChangeType`
  into a shared `bulkSet(set, label)` the way the finding preferred. `SETTABLE`
  is untouched, so `smoke.mjs`'s "exactly type and format" check stays green and
  the parameter count stays 93 of 100.

  **The finding was wrong about the blast radius**, and only a measurement
  showed it. "Reuse `.bulk-type-btn`" understated the cost: the bulk bar is
  centred with a translate, has no width of its own and does not wrap, so it
  grows in BOTH directions. The format group adds 373px — 864px to 1237px — and
  at 891px wide Delete and Cancel went off-screen and the page scrolled
  sideways. The bar had been one group away from that the whole time. Two
  attempted fixes were wrong before the third: `flex-wrap: wrap` alone collapsed
  it to 343px, and `width: max-content` could not help while the translate left
  no containing width to clamp against. It is now inset from both edges with
  auto margins and `fit-content`: 1 row at 1600px, 2 rows at 891px, nothing
  off-screen either way.

  A new smoke check pins every server-settable value to a button in the bar —
  the check that would have caught this gap in the first place — proven by
  pointing a button at the wrong handler and watching it fail. Suite 79 to 81.
  Verified on local dev: 12 items to Physical, then only the 4 movies back to
  Digital, server and memory agreeing row for row, types untouched.

  **Merged 2026-08-26** as `b3d164d`, and screenshotted in production: one row,
  centred, both groups present, nothing off-screen.

---

## B5 — No field beyond `type` and `format` can be bulk-edited, and the current design cannot express a free-text one

**What's wrong.** The brief's guessed fields — status, rating, tags, owned /
wishlist — **do not exist**; the real columns are the eleven item fields. Of
those, only `type` and `format` are bulk-settable, because `SETTABLE` validates
by *enumerating allowed values*, which works for two closed vocabularies and
cannot express `location` or `series`.

**Evidence.** `db/schema.sql:13-29` — the columns are `user_email`, `item_id`,
`type`, `format`, `title`, `author`, `actors`, `producers`, `genre`, `series`,
`location`, `cover`, `notes`, `added_at`. No status, rating, tags, owned or
wishlist. `ITEM_FIELDS` (`_lib/common.js:24`) agrees.
`items/bulk-update.js:35-37` rejects anything outside `SETTABLE` and then
requires `SETTABLE[f].includes(set[f])` — a value whitelist, not a validator.

**Proposed fix.** Extend `SETTABLE` to carry a *kind* rather than only a value
list:

```js
const SETTABLE = {
  type:     { values: ['audiobook', 'movie', 'series'] },
  format:   { values: ['digital', 'physical'] },
  location: { text: true },   // free text, trimmed, capped at MAX_FIELD_LEN
  series:   { text: true },
  genre:    { text: true },
};
```

with `text: true` fields validated as `typeof v === 'string'` and
`.slice(0, MAX_FIELD_LEN)`, matching what `sanitizeItem` already does per field.
The three highest-value candidates in that order: **`location`** is the obvious
one (moving a shelf's worth of physical media), **`series`** next, **`genre`**
third. Do **not** make `title`, `author`, `cover` or `notes` bulk-settable —
setting all of those to one value is destructive by definition and has no
plausible use. In the UI: a small inline form in the bulk bar — field picker,
one text input, Apply — rather than more buttons.

**Two constraints that must be respected:**

- **The parameter ceiling.** `bulk-update.js:50` binds `...values, email,
  ...chunk`. At 90 ids that is *n* + 91, against D1's documented **100**. With
  the five fields above, setting all five at once = 96. Safe, but the headroom
  is nine fields, not unlimited — if this list ever grows past that, the chunk
  size must come down, and the chunk size is pinned by the README and the smoke
  test (see blast radius).
- **A blank value must be allowed** (clearing a location is a legitimate bulk
  edit), so the validator cannot reject empty strings — but the confirm dialog
  must say *"Clear the location on 412 items?"* rather than a generic message.

**Blast radius.** `functions/api/media-vault/items/bulk-update.js`,
`apps/media-vault/app.js`, `apps/media-vault/index.html`, **and
`apps/media-vault/README.md:106`**, which states that "only `type` and `format`
are settable". **This finding BREAKS the smoke suite as written**:
`smoke.mjs:167-174` parses `SETTABLE`'s keys and asserts
`JSON.stringify(fields) === '["type","format"]'`, and also asserts
`wl.includes('SETTABLE[f].includes(set[f])')` — both fail under the shape change
above. Budget for editing those two checks *and* the README line in the same PR;
that is the intended coupling, not an obstacle. No schema change. No new
endpoint file. Verifiable before merge locally.

**Independence.** Take alone, but **after B4** — B4 proves the UI pattern with
zero server risk, and this reuses it.


- **Taken, 2026-08-26** (PR #322): the `{ values }` / `{ text: true }` shape as
  proposed, with `location`, `series` and `genre`, and the inline field
  picker + text box + Apply in the bulk bar rather than more buttons. The two
  smoke checks this finding predicted would break did break, and were rewritten
  rather than deleted — the enumerated fields must still be *enumerated*, and
  the text fields must still be a *closed set*.

  Both constraints held as written. The parameter ceiling is now **arithmetic
  in the smoke test** rather than a note: it reads the chunk size out of the
  endpoint and fails at 101, which was confirmed by adding five fake fields.
  And the blank value passes through with its own confirm sentence.

  The trim needed a decision the finding left open: bulk-set text is trimmed
  and the single-item save is not. The asymmetry is deliberate and documented —
  a bulk set multiplies one trailing space into hundreds of rows that no longer
  group with `Shelf B`, which is a hazard specific to doing it in bulk.

  **Two layout faults surfaced that predate this finding.** The bulk bar split
  mid-group when it wrapped: a bare label is a flex child like any other, so at
  768px the three "Change … to →" labels sat on a line away from their buttons,
  and at 1024px Cancel was stranded alone on a third row. Every label and its
  controls is one child now. Geometry measured at 768/895/1024/1280/1440.

  Also fixed: a comment orphaned by PR #321, where `bulkSet`'s explanation
  ended up above `agreesWithServer`.

  Verified with 18 endpoint cases against a local database — including every
  one of `title`, `author`, `cover`, `notes`, `added_at` and `user_email`
  refused with a 400 — and through the real form in a browser. Suite 112 to
  129. **Merged 2026-08-26** as `469ddcc`.

---

## B6 — Bulk re-lookup / enrich does not exist, and cannot be exact until the source id is stored

**What's wrong.** Nothing re-runs a lookup over a selection. **1,579 of 3,544
rows (44.5%) have no cover** as of 2026-08-26, plus 889 with no author and 1,071
with no genre — a real and sizeable prize. But the harder problem is that
`media_items` stores **no ISBN and no TMDB id**, so there is nothing to look up
*by*: a re-lookup today can only guess from `title` and `author`, and a guess
that writes is how libraries get quietly corrupted.

**Evidence.** No `bulk-lookup`, `enrich` or equivalent exists in
`functions/api/media-vault/` (six files, all read). No client function.
`db/schema.sql:13-29` has no ISBN or TMDB column; `fillBookFields`
(`app.js:580-589`) discards the ISBN it was called with; `selectTMDBResult`
(`app.js:665-700`) writes year/runtime/rating into `notes` and never the TMDB
id. Corroborating the risk: `search.json?isbn=` returned **24 results** for an
invented ISBN during the ISBN probe — fuzzy upstream matching is real, and a
title-only match is fuzzier still.

**Proposed fix.** Three layers, and **do not build layer 3 without layer 1**:

1. **Store the source id first.** This is `ISBN-AUDIT.md` **F7** —
   one `source_id TEXT NOT NULL DEFAULT ''` column, populated on new saves. It
   only helps items added *after* it lands, which is why layer 2 exists.
2. **Backfill by confirmed match, never automatically.** A "Find covers"
   action over a selection that, per item, runs the existing
   `mode=book-title` (or `video-title`) search and presents the top candidate
   **for the user to confirm or skip**, one at a time or as a review list with
   thumbnails. The user's click is what makes the match trustworthy; nothing
   writes without it.
3. **Exact re-lookup**, once `source_id` is populated, running unattended over
   the selection.

**The rules this must obey, which are the actual hard part:**

- **It must never overwrite a non-empty field.** Fill blanks only — cover,
  author, genre where they are `''`. The user's own `title`, `series`,
  `location`, `notes` and `format` are theirs; a "re-lookup" that rewrites a
  hand-corrected title is a data-loss bug wearing a feature's clothes. Note that
  ISBN-audit **F3** has already been writing wrong covers into this library, so
  a non-empty `cover` is not automatically a *correct* cover — offer an explicit
  "replace existing covers too" checkbox, default off, rather than deciding for
  the user.
- **Rate limits and run size: reuse `ISBN-AUDIT.md` F9's loop.**
  Measured against OpenLibrary during this audit: 30 back-to-back requests all
  returned 200 in **16.3 s** (~540 ms each); 12 concurrent all returned 200 in
  **2.0 s**; no rate-limit headers are exposed. TMDB's published limits are
  stricter and were **not** measured here (the local key is the burned one — see
  the ISBN audit's caveats), so treat video enrichment as unmeasured and start
  conservative. **Cap a run at 100 items**, ~1 minute of wall clock. Run the
  loop **client-side**, sequentially, with a small delay — that sidesteps the
  30-second D1/Worker ceiling entirely, makes the run cancellable, and lets the
  UI show progress.
- **Partial failure is the normal case, not the exception.** Every item is an
  independent upstream call. Accumulate results and write **once** at the end
  through `POST /api/media-vault/items/bulk`, which is atomic
  (`db.batch()` is a transaction). Show a per-item outcome list — enriched /
  no match / skipped / failed — and let the user re-run only the failures.
- **Resumable:** yes, but for free. Because nothing is written until the end and
  the run is capped at 100, "resume" is just "select the ones that failed and go
  again". Do not build checkpointing.
- **At the cap:** enrichment only updates existing rows, so `items/bulk` will
  accept it even at 5,000 (verified: an existing id upserts fine at the cap).

**Blast radius.** `apps/media-vault/app.js`, `apps/media-vault/index.html`,
`apps/media-vault/README.md`. **Layer 1 needs a schema change** — see F7's blast
radius, where the column lands in five places and **the smoke suite fails until
the README is updated** (`smoke.mjs:247-250` asserts every `ITEM_FIELDS` entry is
both a schema column and named in the README). Layers 2 and 3 add no endpoint
file and no lookup mode, which keeps `smoke.mjs:216-219` and `smoke.mjs:222-227`
green. **It cannot be verified against the affected data before merge** — the
1,579 coverless rows are `lillcreeper`'s and this repo has no
non-production copy of them. Verify the mechanics locally on seeded rows, then
ship it behind a first run the user drives themselves over a small selection.

**Independence.** **Requires `ISBN-AUDIT.md` F7** for exact
re-lookup, and **shares its throttled per-item loop with F9** — build the loop
once in F9 and reuse it here, or you will write it twice. Layer 2 (confirmed
match) can technically be taken without F7 and is the fastest route to covers on
existing rows; if you want one thing from this finding, that is it. It is the
largest item on this menu — do not take it in the same week as the ISBN fix.


- **Taken, 2026-08-26**: **layer 1 as PR #323** (which is F7, taken first and
  alone because it needed the schema applied to production ahead of its own
  merge), then **layers 2 and 3 together as PR #324**.

  Layers 2 and 3 turned out to be **one code path, not two**. The only thing
  that differs is whether the item knows where it came from: with a `source_id`
  it is looked up by that id and arrives ticked, without one it is searched for
  by title and arrives unticked. Building them separately would have meant two
  loops, two result lists and two sets of rules about overwriting.

  Every rule this finding set was implemented and is pinned: never overwrite a
  non-empty field, only `cover`/`author`/`genre`, the replace-covers opt-in
  defaulting off, the 100-item cap that says what it left out, the client-side
  cancellable loop reusing F9's delay, one transactional write at the end, and
  resume-by-reselection with no checkpointing.

  **One thing the finding did not anticipate:** a confirmed guess for a film or
  series **records the TMDB id it matched**, so the next run is exact. That
  makes layer 2 a feeder for layer 3 rather than a parallel track, and it is why
  the video path needs only one upstream call per item instead of two against
  limits nobody has measured.

  The finding's warning about verification was right in an unexpected way. The
  logic was proven against a stubbed upstream — a row with a hand-set author had
  only its genre filled, and `MY OWN AUTHOR` survived — and then the unstubbed
  run found **OpenLibrary degraded**: two of three items hit F10's ten-second
  bound, were left untouched, and filled on a re-run of just those two. The
  partial-failure design proved itself by accident.

  It could not be verified against real data before shipping: the 1,579
  coverless rows are `lillcreeper`'s and have no non-production copy,
  so everything below the merge line was proven on seeded rows. See the live
  run recorded at the end of this note.

  Suite 143 to 157. **Merged 2026-08-26** as `05c3555`, after #323 (`bd6abc5`).
  Confirmed live: the deployed client carries `openEnrichModal`, `ENRICH_FIELDS`
  and the bulk bar renders all of it on one line at 1568px.

  **Exercised in production by Nate on 2026-08-26, and it worked.** That is
  the report as given — no detail on which items, or whether any were guesses
  rather than exact matches, so nothing further is claimed here. It closes the
  gap this note previously flagged: the feature had never been run against a
  real library, only against seeded rows.

  Still unconfirmed: **TMDB against the real API**, unless that run included a
  film or series. The local key is the burned one, so every video path here was
  proven with a stubbed response.

---

## B7 — "Select All" reaches past the page and nothing on screen says so

**What's wrong.** The button selects the entire filtered set while the page
shows twenty. That is the right behaviour — the brief asked for exactly it — but
the only feedback is a count in the bulk bar, and the pagination line right
beside it is still talking about twenty.

**Evidence.** `bulkSelectAll` (`app.js:383-393`) → `getFilteredIds`
(`app.js:395-397`) → `getFilteredLibrary` (`app.js:19-37`), which walks the
whole `library`. `renderLibrary:90-93` paginates only the render. Reproduced:
61-item library, `Showing 1–20 of 61` on screen, one click, **61 selected**, 20
checkboxes ticked. At the real library that is one click from 3,544 selected
with 20 rows visible.

**Proposed fix.** Make the reach explicit at the moment it happens:

- Change the button label to name the target — `Select all 3,544` /
  `Select all 15 movies` — computed from `getFilteredIds().length` (0.2 ms at
  3,544 rows, measured; recompute freely).
- Add a line to the bulk bar when the selection exceeds the page:
  `61 selected — 41 of them are not on this page.`
- For the destructive action only, raise the bar above a threshold: when a bulk
  delete would remove more than, say, 100 items, require the user to type the
  number rather than press OK on a `confirm()`.

**Blast radius.** `apps/media-vault/app.js`, `apps/media-vault/index.html`
(one span in the bar). No endpoint, no schema change, smoke suite unaffected.
Verifiable before merge locally.

**Independence.** Take alone. Overlaps **B2** in spirit; taking B2 first makes
the labels here easier to word, because the selection can then only mean one
thing.

- **Taken, 2026-08-26** (PR #318): all three parts as proposed — the button
  names its target, the bar says how many are off the page, and a delete of
  more than 100 asks for the number typed. The button label dropped the noun
  the finding suggested ("Select all 15 movies"): under a search it would be
  saying something narrower than it means, and the plain number is true in
  every state.

  **The off-page count is PAGE-dependent, which the finding did not reckon
  with.** Only `renderLibrary` knew how to paginate, so the bar could not
  compute it without a second copy of the sort and slice. `getPageView()` is
  now the one definition both read. That turned up a staleness this finding
  had not named either: paging and re-sorting did not refresh the bar, so
  selecting page 1's twenty and clicking page 2 still read "20 selected" with
  all twenty off-screen. `renderLibrary` refreshes the bar itself now.

  **Cost, measured:** `updateBulkBar` sorts on every checkbox click. At 3,544
  items a toggle went 0.10ms to 0.85ms and one refresh 0.20ms to 1.10ms —
  imperceptible, but 8x, and worth knowing before anything else joins that
  path. This partly retracts the "there is no performance finding here" line
  in the limits section above: that measurement was of the OLD
  `updateBulkBar`, and still holds for it. Suite 86 to 90.

  **Merged 2026-08-26** as `2cc3670`.

---

## B8 — `bulkChangeType` assumes every row it selected was changed, and never reads the count the server returns

**What's wrong.** The endpoint reports how many rows it actually changed. The
client throws that away and rewrites its own copy regardless. If the two ever
disagree, the screen is wrong and nothing says so.

**Evidence.** `items/bulk-update.js:53-55` computes
`changed = results.reduce((n, r) => n + (r.meta?.changes || 0), 0)` and returns
`{ ok: true, count: changed }`. In `app.js:413-421`, `apiWrite` is handed a
function whose resolved value is discarded, and the client then does
`library.forEach(item => { if (selectedIds.has(item.id)) item.type = newType; })`
unconditionally. `bulkDelete` (`app.js:430-436`) has the identical pattern
against `bulk-delete.js`'s `count`.

Today the two agree — verified: 3,005 selected, `count: 3005`; 4,906 deleted,
`count: 4906`. The gap is not currently reachable through the UI (the client
only ever selects ids that are in `library`), so this is a latent defect rather
than a live bug. It becomes reachable the moment two tabs are open on the same
library, which is precisely the failure class this app was rebuilt to end
(`README.md:58-74`).

**Proposed fix.** Capture the response and compare:

```js
const res = await apiFetch(…);            // { ok, count }
if (res.count !== selectedIds.size) {
  // the server and the screen disagree — take the server's word for it
  const data = await apiFetch('/api/media-vault/items');
  library = data.items;
}
```

`apiWrite` currently swallows the return value; either widen it to pass the
result through, or call `apiFetch` directly and keep `apiWrite`'s error
handling. Do not alert on a mismatch — a silent re-fetch is the right response,
matching what `apiWrite` already does on failure.

**Blast radius.** `apps/media-vault/app.js` only (and `apiWrite`'s signature if
you widen it — it has three call sites: `saveItem`, `deleteItem`, `importCSV`,
plus the two bulk paths). No endpoint, no schema change, smoke suite unaffected.
**Hard to verify before merge** — the mismatch is not reproducible through the
UI; test it by pointing the client at a hand-crafted id list, or accept it as a
defensive change verified by inspection. Say which in the PR.

**Independence.** Take alone. Lowest value on this menu; it is here because the
brief asked whether a partly-applied bulk operation can leave the client
disagreeing with D1, and this is the honest answer: **not through the server**
(`batch()` is transactional, so no partial application), **but the client would
not notice if it ever did.**


- **Taken, 2026-08-26** (PR #321): as proposed, and **two of this finding's
  own claims did not survive the work.**

  *"Hard to verify before merge — the mismatch is not reproducible through the
  UI."* It is, in about thirty lines: delete rows behind the client's back —
  which is all a second tab is — then run the bulk action from the stale tab.
  Done against a real local database, against the client as it stood on `main`.

  *"Lowest value on this menu … a latent defect rather than a live bug."* That
  was true the day it was written and **B1 has landed since**. Measured on the
  old client: a `bulk-update` of 8 selected against 6 real rows left the
  database holding 6 while the screen showed **8**, silently. Worse, a
  `bulk-delete` of 8 against 5 offered an Undo holding 8 rows, **3 of which the
  server had never deleted** — and pressing it **resurrected exactly the three
  rows the other tab had deliberately thrown away**. That is one tab undoing
  another tab's deletion, not a stale screen.

  So a short delete count now **withdraws the undo**, which this finding could
  not have asked for. Otherwise as specified: silent re-read, no alert,
  `apiWrite` widened to pass the body through rather than calling `apiFetch`
  directly.

  Not applied to `items/bulk` — the undo restore, the paste commit and the CSV
  import. Its `count` is an **echo of the request**, since an upsert changes
  every row it is handed, so it can never disagree; a smoke check pins those
  paths as uncompared so the omission reads as a decision.

  One repair while here: the undo's capture-order pin sliced a fixed 2000
  characters from `bulkDelete`, and a pattern falling outside that window gives
  `indexOf` `-1`, which the ordering test reads as **true** — so it could have
  passed while broken. Now bounded by the function's closing brace.

  Suite 105 to 112. **Merged 2026-08-26** as `da05c51`.

---

## B9 — Bulk actions on the Stats screen: don't build them

**What's wrong.** Nothing. This finding exists to close the "every screen" ask
with a reasoned no, so it does not sit open on the menu.

**Evidence.** `renderStats` (`app.js:1025-1063`) and `renderRankedList`
(`app.js:977-1003`) render aggregates — *"Brandon Sanderson · 47"* — not items.
Verified: zero checkboxes inside `#statsPage`. Each ranked row is already
clickable and already does the useful thing: `jumpToSearch`
(`app.js:1005-1023`) switches to the library, sets the search field and query,
and applies the type filter.

**Why not.** Selection on the Stats page would mean selecting an *aggregate* and
implying an operation on the items behind it — "delete Brandon Sanderson"
meaning 47 rows the user is not looking at. That is the **B2** hazard by design
rather than by accident. And the capability is already there in two clicks:
click the ranked row, which lands in a filtered library view, then **Select
All**, which already spans the whole filter. The right investment is making that
path obvious (**B7**), not putting checkboxes next to bar charts.

The ranked lists also cap at 50 entries (`app.js:974`), so a selection built
from them would silently miss the tail — another reason the library view is the
correct place for this.

**Proposed fix.** None. Close it. The one thing that *should* change on this
screen is **B3** — the bulk bar leaking into it — which is a separate finding.

**Blast radius.** None.

**Independence.** n/a.


- **Declined, 2026-08-26** (PR #325), on Nate's word: *"I don't think B9 adds
  value, let's remove that as an option/feature."* Which is what this finding
  recommended — it existed to close the "every screen" ask with a reasoned no.

  **Nothing was removed, because nothing was ever built.** Confirmed before
  writing anything: zero checkboxes in the `#statsPage` markup, neither stats
  renderer emitting one or reading `selectedIds`, and B3 already ending select
  mode on the way out of the library so the bar cannot follow.

  So the work was making the **no** durable rather than deleting anything: the
  reasoning is in the README and **five smoke checks guard the ADD direction** —
  a checkbox appearing in the markup, either renderer emitting one or reading
  the selection, a ranked row no longer routing to the filtered library, and
  the README losing the reasoning. A decision nobody can find is a decision
  that gets remade.

  One of the five was wrong on the first attempt and passed a break it should
  have caught — it matched the substring `jumpToSearch`, which
  `jumpToSearchDisabled` satisfies. Tightened to the call plus its paren.

  Suite 157 to 161, no behaviour change. **Merged 2026-08-26** as `d8b25c1`,
  which closes both audits: `F1`–`F10` and `B1`–`B9`.

---

## Ordering, if you want one

`B4` → `B3` → `B2` → `B7` → `B1` → `B5` → `B6`, with `B8` whenever and `B9`
closed on sight.

B4 is nearly free and proves the bulk-bar UI pattern. B3 and B2 are small,
contained safety fixes with no server or schema exposure, and B1's undo is worth
more once they have removed the ways a selection goes wrong. B5 and B6 are the
two that cost real work — B5 breaks two smoke checks and a README line by
design; B6 wants a schema column and shares its lookup loop with the ISBN
audit's F9, so it should follow that work rather than lead it.
