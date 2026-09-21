# MediaVault — bulk edit and delete: gap analysis

> **Since 2026-09-16 the closed findings live in `BULK-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

A feature menu, taken one at a time. **Read each finding's own note for its
state** — this header gives none. Findings filed after the original run sit
under their own dated headings at the end of the file.

`B1`…`B9` are all closed, across PRs #315–#325 — B1–B8 built, **B9 declined**
as it recommended. **B6 was the largest item and
took two of them** — #323 for its layer 1, which is the ISBN file's `F7`, then
#324 for the rest. Each outcome note sits under its own finding, and the
evidence throughout describes the app as it stood **before** any of this landed.

*(Until 2026-09-21 the paragraph above read **"Every finding here is now
closed"** and scoped itself to `B1`…`B9`, which is per-finding state written
into a header — the thing `audit-menu` forbids, for this exact reason. It was
true when written and stopped being true the day `B10` was appended beneath it,
in a PR that did not come back here. `UI-AUDIT`'s header records the same
failure happening to it three times. Read each finding's own note.)*
<!-- claim-ok: quoting the sentence this paragraph replaces, with the date it stopped being true -->

**A premise audit was run on 2026-09-21** by the `audit-premise-auditor`, at
Nate's word to file rather than build. Its corrections are recorded under the
finding itself so nobody implements from the original text; read that
finding's own note for what happened after.

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

## Filed 2026-09-20, from a hand-over note rather than from a run of this menu

**On this menu rather than a new one, and rather than ISBN-AUDIT or
SHARE-AUDIT**, because the subject is the same one `B1`'s note argues about —
a second copy of the library living outside D1. `BULK-AUDIT.closed.md:38`
declines to write deleted rows to localStorage as *"exactly the
second-copy-of-the-truth"* problem; this is the last surviving instance of that
copy and whether it was ever put away. A menu holding one finding would be
worse than a slightly loose fit, per `audit-menu` → *When not to*.
<!-- claim-ok: quoting the note that makes this the right menu -->

## B10 — the one-shot that retires localStorage reports success or failure to nobody, and one of its failure modes is permanent and silent

**The code is correct, and that is the point of filing this.** Read on `main`
@ `f61c537`, 2026-09-20:

- `apps/media-vault/app.js:2154` `migrateLocalIfNeeded` reads `mv_library`,
  POSTs it, and removes the key **after** the await.
- `apps/media-vault/app.js:2111` `apiFetch` **throws** on a non-2xx, so a
  failed migration never reaches the `removeItem`. The comment above
  `migrateLocalIfNeeded` promises exactly that and it is kept — no data is at
  risk and this finding proposes no fix to either function.
- `apps/media-vault/app.js:2339` `initApp` wraps the call in its own
  `try`/`catch` whose body is a single `console.error`. **So the failure signal
  is a console line in the affected person's own browser**, and the affected
  person is `lillcreeper@gmail.com`, not Nate.

**Nothing on the server distinguishes ran from never-ran.**
`functions/api/media-vault/migrate.js` inserts through the shared `UPSERT_SQL`
and returns `{ imported, skipped }` to the caller. No row, column or log
survives the request, so the question *"did lillcreeper's browser ever hand its
cache over"* has no answer available from here — by construction, not by
oversight.

**And the cloud row count cannot answer it either.** `media_items` on
production, `scripts/q.mjs --remote` 2026-09-20: `lillcreeper@gmail.com`
**3,444 rows**, `nathanrapert@gmail.com` **2**. Those rows are consistent with
the migration having run *and* with it never having run, because the app's
previous design pushed the whole library to D1 on a debounce — the README's
*Storage: D1, and only D1* section describes that reversal. A library that
arrived by the old sync looks identical to one that arrived by the merge.

**The permanent failure mode, which is the part worth acting on.**
`migrate.js` refuses with a **400** when the merged total would exceed
`MAX_ITEMS` (5000, `functions/api/media-vault/_lib/common.js:108`). A 400
throws, so the key stays, so the next load retries, so it 400s again — forever,
logging to a console nobody reads. Today's headroom is **1,556 rows**, which
makes this unlikely rather than impossible, and the likelihood is not knowable
without seeing what that browser still holds.

**Proposal — two options, and the cheap one may well be enough.**

- **A (recommended): answer the question once, by hand, and then delete the
  path.** Ask Nate to have lillcreeper open MediaVault and read
  `localStorage.getItem('mv_library')` in the browser console: `null` means the
  migration ran (or there was never a cache) and **the whole code path can be
  deleted** — `migrateLocalIfNeeded`, `migrate.js`, `planMigration`, its nine
  smoke checks and the README section. A non-null value means it never
  completed, and the length says whether the cap is why. **Posture: a question,
  then either a deletion PR or a real bug.** It is the only option that can end
  this rather than instrument it.
- **B: make the failure visible** — surface a failed migration in the UI
  instead of the console, or return the counts somewhere durable. **Posture:
  report only, no gate.** This is worth doing only if A comes back non-null and
  the cause is not the cap.

**Evidence:** the four source locations above, read 2026-09-20 on `f61c537`;
the two production counts by `scripts/q.mjs --remote`, same day. **The one
thing that is inferred** is that the path has never been exercised in
production — it is *unobservable*, which is the finding, and must not be
written down as *unused*.

**Confidence: high that the state is unknowable from here. No confidence at all
about which state it is in**, and there is exactly one thing that would settle
it, named as option A. **Do not take B first**: instrumenting a path that may
have completed a year ago is the expensive way to answer a question a console
read answers for free.

**Ongoing cost.** A: none, and it *removes* ongoing cost — a one-shot nobody
can retire is a permanent line item in every reading of this app. B: one more
UI state to maintain.

**Subject grep, 2026-09-20:** `apps/media-vault/**` and the memory store for
`lillcreeper`, `localStorage`, `mv_library` and `migrate`. The hits are this
app's README, `ISBN-AUDIT.closed.md:64` and `:367` (both about the migration
path holding a new column's default so old payloads still merge — a
compatibility point, not this question), `SHARE-AUDIT.md:91`'s row counts, and
the memory note `app-work-ledger`, which records that the library is
lillcreeper's and says nothing about the migration. Nothing has weighed this.

### Premise audit, 2026-09-21 — NOT taken, corrections recorded first

Run by the `audit-premise-auditor` before asking Nate the question option A
asks for. **The five code premises above all hold**, re-read on `main` @
`bd5cc51` where `B10` was filed against `f61c537`: `app.js:2154`, `:2111`,
`:2339`, the `UPSERT_SQL` / `{ imported, skipped }` / nothing-persisted claim in
`migrate.js`, and the cap 400 at `migrate.js:78-80` against `MAX_ITEMS = 5000`
at `_lib/common.js:108`. Three things option A rests on and does not state also
hold: the call is **not gated** (`initApp()` runs unconditionally at
`app.js:2542` and again from the Retry button at `index.html:147`), **nothing
else touches `mv_library`** (three references, all in `app.js`, no
`setItem` anywhere, pinned by `smoke.mjs:561`), and `planMigration` has one
non-test consumer. Six corrections:

**1. "Nothing has weighed this" is wrong, and it moves the odds.** The memory
note `app-work-ledger.md:17-18` does not merely record whose library it is — it
ends *"and their one-time migration has not run."* Dated 2026-08-26, no basis
given, and any load since could have run it, so **it does not settle the
question**; what it does is make option A's non-null branch the likely one
rather than the coin-flip this finding describes. Read it before asking, and
correct it in the PR that closes `B10`.
<!-- claim-ok: quoting the memory line that falsifies this finding's own subject-grep sentence, with its path and lines -->

**2. "Its nine smoke checks" undercounts the deletion by about half.**
`test/smoke.mjs`'s `section('The migration planner')` (lines 82-142) holds
**twelve** `check(` calls; nine is the number of *lines mentioning*
`planMigration`, which is what a grep returns. Two more live outside it at
`:562` and `:564`, and two README pins at `:633` and `:635`. **One of them
would pass vacuously rather than fail:** `:860` does
`appSrc.slice(appSrc.indexOf('migrateLocalIfNeeded'))`, so with the function
gone `indexOf` returns `-1` and the check inspects the file's last character. A
deletion PR that only watches for red misses it. And `:19` imports
`{ mergeKey, planMigration }` from `migrate.js` at module level, so deleting
that file breaks the whole suite at import — `mergeKey` actually lives in
`_lib/common.js` and is only re-exported, and the duplicate-scanner check at
`:981-982` still needs it, so that import must be **repointed, not removed**.

**3. The deletion list omits a pinned count and two README structures.**
`smoke.mjs:585-586` asserts *"the endpoint files are exactly the nine
documented"*; deleting `migrate.js` makes it eight, and the check above it ties
that to the README's file map. So option A also moves `README.md:44`, the
endpoint-table row at `:441`, and the `## The one-time migration` section at
`:485-500` — not just "the README section". Nothing outside this app pins it.

**4. The permanent-400 is wider than the cap, which STRENGTHENS the finding.**
Two more permanent 400s on the same path, neither bounded by headroom:
`migrate.js:66` — `sanitizeItem` returns `null` for an item with a missing or
blank `title` (`_lib/common.js:112-113`), and one such item 400s the whole
batch; and `migrate.js:59` — an array longer than `MAX_ITEMS` 400s before the
merge is planned. So *"unlikely rather than impossible"* is too generous: a
single old cached row with a blank title is a forever-retry on any library size.

**5. The `null` reading is three-valued, not two.** `app.js:2161-2163` removes
the key with **no POST at all** when the parsed value is not an array or is
empty, and a `JSON.parse` failure reaches the same branch. So `null` means
migrated, *or* never cached, *or* the browser cleared a corrupt value by itself.
The deletion decision is unaffected; the diagnostic sentence is incomplete.

**6. This menu's header said nothing was open.** Fixed in the same PR as this
note; see the header.

**Nothing cites `B10` by number** — `grep -rn "B10"` across the repo returns
only its own heading, and the memory store has none. Two memory files cite the
*menu* and go stale while it is open. The count the auditor could not settle is
the production row count: three values are recorded — **3,544** on 2026-08-26
(`app-work-ledger.md:17`), **3,637** on 2026-09-08 (`SHARE-AUDIT.md:91`),
**3,444** in this finding on 2026-09-20 — non-monotonic, because the library is
actively edited. **The argument does not depend on which is right**: the count
cannot distinguish ran from never-ran in either direction, and only the derived
headroom moves.

**Closed without being taken, 2026-09-21, on Nate's word. Parked with a
trigger, not declined on the merits.**

**Option A is unavailable.** It needs a one-line check run in lillcreeper's own
browser console, and they are not comfortable doing it. Option B is scoped by
this finding as worth doing *"only if A comes back non-null"* — A cannot come
back at all, so that condition cannot be evaluated. Substituting a scope this
finding did not propose is what `audit-menu` forbids, so the question is left
unanswered rather than answered a different way.

**Waiting is safe, and that is why this parks rather than decides.**
`migrateLocalIfNeeded` removes `mv_library` only after a confirmed 2xx
(`app.js:2162`, re-read 2026-09-21) and `initApp` calls it unconditionally on
every load. A migration that has never completed has therefore lost nothing:
the cache sits where it is and is retried on every visit. **The failure is
invisible, not destructive** — which is the whole reason the cost of not
knowing is bounded.

**What reopens this**, so the decision is not re-derived from scratch:

- lillcreeper reports items missing, or a library smaller than they remember;
- anyone becomes willing to run option A's check, or to have it run for them;
- **the migration path is about to be deleted for any other reason.** That
  deletion is the single action that turns a latent failure into a permanent
  one, and it must not happen on the strength of this note.

**One number bounds the risk.** The permanent-and-silent mode is the cap 400 at
`migrate.js:78-80` against `MAX_ITEMS = 5000` (`_lib/common.js:108`). Against
**3,444** cloud rows — re-queried with `scripts/q.mjs --remote` on 2026-09-21,
unchanged from this finding's 2026-09-20 figure — it can only bite if the
stranded cache holds more than **1,556** items not already matched by
title+type. Every other failure mode retries and would succeed once its cause
cleared.

**Two memory corrections were made with this closure**, both required by the
premise audit above and neither reachable by any grep of this repo:
`app-work-ledger` said their migration *"has not run"*, dated 2026-08-26 with
no basis given, and `audit-menus` said `B10` was open.
<!-- claim-ok: quoting the memory line the premise audit above requires correcting, with its date -->

**And one correction to this finding's own text, recorded rather than edited**
per *Audit files are RECORDS*: *"Nothing cites `B10` by number"* was false when
written. PR #1206 added three references to `B10` in this menu's header **in
the same commit** as the premise audit that says it. A tree-wide grep on
2026-09-21 returns seven, all in this file.
