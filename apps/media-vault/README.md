# MediaVault — a personal audiobook, movie and series library

Catalogue what you own. Add an item by hand, or look it up by ISBN, title,
author, actor or director and let the fields fill themselves in — one at a
time with **Add now**, or by pasting a whole shelf of ISBNs at once. Browse it
as a grid or a table, filter and sort it, select many at once to retype,
reformat or delete them, import and export CSV, and read the whole collection
back as ranked stats — most-collected authors, directors, actors, producers
and genres, each one clickable through to the items behind it.

Part of Nate's Workshop: Cloudflare Pages + D1, behind the site-wide Access
gate. No build step, no framework, no dependencies.

---

## Where everything lives

```
apps/media-vault/
├── index.html            The page: header, toolbar, grid/list, stats page,
│                         add-edit / detail / import modals, bulk action bar
├── styles.css            Loaded after /shared/styles.css
├── app.js                Everything the page does, one plain script
└── test/
    └── smoke.mjs         The merge planner, the sanitizer, the ISBN input
                          rules, and the claims this README makes

functions/api/media-vault/
├── _lib/common.js        Identity (Access email, dev@localhost fallback),
│                         the JSON helper, the item sanitizer, the upsert,
│                         the four ISBN rules
├── items.js              GET / POST / DELETE — the library, one item at a time
├── items/bulk.js         POST — upsert many (CSV import)
├── items/bulk-update.js  POST — retype a selection
├── items/bulk-delete.js  POST — delete a selection
├── migrate.js            POST — the one-time localStorage retirement
└── lookup.js             GET  — OpenLibrary + TMDB, proxied

db/schema.sql             media_items — see "Data model"
```

Run the tests from anywhere:

```
node apps/media-vault/test/smoke.mjs
```

The shared framework rules apply: the app is registered in
`apps/manifest.json`, loads `/shared/styles.css` then its own, and uses
`/shared/js/ui.js`.

## Storage: D1, and only D1

**The browser stores no library data.** The app loads the caller's rows from
D1 on startup, writes every change straight through to the API, and holds the
result in memory for filtering, sorting, paging and stats. There is no
localStorage copy, no offline mode and no sync step, because there are no
longer two copies to reconcile.

That is a deliberate reversal. The app used to treat localStorage as the
working copy and push it to D1 on a 1.5-second debounce — and the push was a
*whole-library replace*, deleting every row the user had and reinserting the
browser's array. Three things went wrong with that, and a user reported all
three as "local and cloud are out of sync":

- a tab closed inside the debounce window never sent its edits;
- two open tabs each replaced the other's library with their own stale copy;
- when the two disagreed at startup, a modal asked the user to choose, and one
  of the three choices was "keep local, replace cloud".

So the replace is gone. Every endpoint below touches only the rows it names —
a `DELETE` from `media_items` filtered by `user_email` alone, with no
`item_id`, appears nowhere in this app, and the smoke test fails if it comes
back. A failed write is never silent either: the client reports it and
re-fetches from the server rather than letting the screen drift away from the
stored truth.

**Nor is a write that landed on fewer rows than it named.** `bulk-update` and
`bulk-delete` each report how many rows they actually changed, summed from
D1's own `meta.changes`, and the client compares that against the number it
selected. They disagree when a **second tab** has already deleted something
this one still has on screen — the same two-tabs problem as above, arriving
from the other direction. On a disagreement the library is re-read from the
server and the screen redrawn from it, with no alert: the user is not being
told off for something another tab did.

A short **delete** count also **withdraws the Undo**, which is the point of
comparing rather than tidiness. The undo buffer would name rows the server
says it never deleted, so restoring it would put back exactly what somebody
else deliberately threw away. No Undo button is the right answer there.

This applies to those two endpoints and no others. `items/bulk` reports a
count too, but it is an **echo of the request** — an upsert changes every row
it is handed, inserting or updating, so that number can never disagree.
Restoring an undo, committing a pasted ISBN list and importing a CSV all go
through it, and all skip the comparison on purpose.

## Filling in the blanks

**✨ Fill blanks** in the bulk bar goes back to where each selected item came
from and fills in what is missing. As of 2026-08-26 the library had 1,579 rows
with no cover, 889 with no author and 1,071 with no genre.

**It never overwrites a non-empty field.** Only `cover`, `author` and `genre`
are touched, and only where they are already empty. `title`, `series`,
`location`, `notes`, `format` and `type` are never touched at all — a
"re-lookup" that rewrites a hand-corrected title is a data-loss bug wearing a
feature's clothes.

The single exception is opt-in and **off by default**: covers can be replaced
as well as filled. An existing cover is not necessarily a *correct* one — the
cover carry-over bug wrote wrong images into this library for months — but one
you already have may equally be one you chose, so it is your call rather than
the code's.

**Exact and guessed are different things, and the list says which is which.**

| | How it is looked up | How it arrives |
|---|---|---|
| Has a `source_id` | by that id — same record, same book | 🔒 **ticked** |
| No `source_id` | searched for by title and author | ≈ **unticked** |

The tick is what makes a guess trustworthy, and nothing is written without it.
OpenLibrary returned 24 results for an ISBN that does not exist; a title match
is fuzzier still, so guesses **arrive unticked** with the candidate named.

A confirmed guess for a **film or series** records the TMDB id it matched, so
the next run is exact. `video-title` answers with an id and a poster but no
directors or genres, so the first pass fills the cover and the second — now
exact — fills the rest. Two cheap passes rather than two calls per item against
TMDB limits nobody here has measured. A confirmed guess for a **book** cannot
do the same: OpenLibrary's title search returns no ISBN to record.

**The run is capped at up to **100** items** — about a minute against a healthy
OpenLibrary — and says how many it left out rather than truncating silently.
The loop runs in the **browser**, sequentially, which sidesteps the 30-second
Worker ceiling, lets the run be stopped halfway, and lets progress be watched.

**Partial failure is the normal case, not the exception**: every item is an
independent upstream call. Nothing is written until Apply, and then everything
lands in a single `items/bulk` call — one `db.batch()`, one transaction. A
failed item is left completely untouched, so "resume" is just *select the
failures and run again*; there is no checkpointing because none is needed.

## Undoing a bulk delete

A bulk delete is irreversible on the server: there is no `deleted_at` column
and no trash table, and `items/bulk-delete` issues a real `DELETE`. The undo
is therefore the copy the CLIENT already holds — the rows are captured out of
the in-memory `library` array before the array is filtered, which works only
because that array is the **whole** library rather than a page. If a paginated
GET ever arrives, this design collapses; `bulkDelete` says so in a comment.

The window is **10 seconds** and the toast counts it down. There are exactly
two ways out — the Undo button and the clock — because a toast that vanishes
when the mouse moves is not a safety net. Starting another bulk operation, or
re-entering select mode, ends the window as well: the user has moved on, and
two overlapping windows is a bug generator.

**The buffer is memory only, and the toast says so** (*"Closing this page will
finish the delete"*). Writing deleted rows to localStorage would recreate the
second copy of the truth this app was rebuilt to eliminate, so a reload inside
the window finishes the delete. That is the honest contract and it is the one
thing about this design the user has to be told.

Restoring goes through `items/bulk`, which round-trips a row faithfully —
**`item_id` and `added_at` included** — so it is a restore rather than a
re-add. If it fails, the server's own message is shown (that is what surfaces
*"Import would exceed the library cap"* when the freed space has since been
refilled), the buffer is kept for **one** retry, and after a second failure
the app names the items that were lost rather than dropping them silently.

## Data model

One table in the site's shared D1 database.

| Table | Notes |
|---|---|
| `media_items` | One row per item, keyed `(user_email, item_id)`. `user_email` is the Cloudflare Access identity, so a user only ever sees their own rows. Columns: the twelve item fields (`type`, `format`, `title`, `author`, `actors`, `producers`, `genre`, `series`, `location`, `cover`, `notes`, `source_id`) plus `added_at`. |

It is **not** prefixed, unlike FilamentForge's `ff_` tables. It predates that
convention and holds live data; renaming it would buy consistency at the price
of a data-copy migration. `db/schema.sql` notes that the character creator's
gear table is called `gear` rather than `items` specifically to stay clear of
it.

**`source_id` is where the row came from**, so its lookup can be run again
exactly: the normalised ISBN for a book, `tmdb:movie:1234` / `tmdb:tv:1234` for
video — the prefix names the lookup, the rest is that lookup's key. One generic
column rather than two nullable ones, since both would be empty on the same
rows anyway.

Before it existed, the link back to the source record was thrown away the
moment an item was saved: the ISBN lookup wrote four fields and discarded the
number it had been handed. So anything wanting to re-run a lookup could only
guess from title and author — and OpenLibrary's own search returned **24
results for an ISBN that does not exist**, which is how a library quietly fills
with the wrong covers.

It is written by the two paths that actually know one: an **ISBN** lookup, and
selecting a **TMDB** result. A title or author search leaves it **empty on
purpose** — those results carry no ISBN, and inventing one from the title is
the exact guess this column exists to avoid. Every row saved before migration
`040` is empty too, which is honest rather than a gap.

It is not in the add form, not bulk-settable, and not editable by hand: it is a
fact about the lookup rather than a field. It *is* carried through the edit
form, the CSV export and the CSV import, because each of those would otherwise
erase it silently.

Limits the API enforces: **5000 items per user**, and 4000 characters per
field. Anything longer is truncated rather than rejected. Id lists in the bulk
endpoints are chunked at **90** ids per statement, because D1 caps bound
parameters per query.

## API surface

Every endpoint reads identity from `_lib/common.js` and scopes every statement
to that email.

| Endpoint | Method | Notes |
|---|---|---|
| `/api/media-vault/items` | GET | The caller's whole library, oldest first |
| `/api/media-vault/items` | POST | Upsert one item |
| `/api/media-vault/items` | DELETE | `?id=` — delete one item |
| `/api/media-vault/items/bulk` | POST | Upsert many. CSV import's endpoint. Rows not named in the body are untouched |
| `/api/media-vault/items/bulk-update` | POST | `{ ids, set }` — five settable fields, below. Every one is reachable from the bulk bar; the endpoint accepts several at once |
| `/api/media-vault/items/bulk-delete` | POST | `{ ids }` — deletes exactly the named rows |
| `/api/media-vault/migrate` | POST | The one-time localStorage merge, below |
| `/api/media-vault/lookup` | GET | Metadata proxy, below |

**What is bulk-settable, and what is deliberately not.** `bulk-update`'s
whitelist gives each field a *kind*, not just a list of allowed values:

| Field | Kind | Why |
|---|---|---|
| `type` | one of `audiobook` `movie` `series` | closed vocabulary |
| `format` | one of `digital` `physical` | closed vocabulary |
| `location` | free text | moving a shelf's worth of physical media is the case this whole feature exists for |
| `series` | free text | filing a run of books under one name |
| `genre` | free text | the coarsest correction, and the one most often missing |

The whitelist began as `field: [allowed, values]`, which works for two closed
vocabularies and **cannot express `location` at all** — there is no list of
every shelf a person owns.

**`title`, `author`, `cover` and `notes` are absent, and should stay absent.**
Setting every selected row's title to one string is destructive by definition
and has no use that is not a mistake. The smoke test asserts they are missing
from both the server whitelist and the client's picker, so adding one is a
deliberate act rather than an oversight.

**Bulk-set text is trimmed; the single-item save is not.** That asymmetry is on
purpose. Someone editing one row can see the box they typed into; a bulk set
propagates one value to hundreds of rows, so a trailing space becomes hundreds
of rows whose `location` looks identical to `Shelf B` and does not group,
filter or search with it. A blank value is **allowed** — clearing a field
across a selection is a real edit — and gets its own confirm sentence
(*"Clear the location on 412 items?"*) rather than the generic one, because a
blank box is easy to press Apply on by accident.

**Five fields is not an arbitrary stopping point.** D1 allows 100 bound
parameters per query, and the batch binds one per field, one for the caller's
email, and one per id in the chunk: 5 + 1 + 90 = **96**. The headroom is four
more fields, and the smoke test does that arithmetic — a sixth and a seventh
fail the suite rather than failing in production against a query D1 refuses.

## The one-time migration

Browsers that still hold the old `mv_library` cache send it once to
`/api/media-vault/migrate`. The server merges rather than replaces: an item
whose **title + type** already exists in the caller's rows is skipped — cloud
wins, and the title comparison is case-insensitive — and the rest are
inserted. A local id that collides with an existing row gets a fresh one, so a
migration can never overwrite a row it did not create. The batch also dedupes
against itself.

The client deletes `mv_library` **only after the server confirms**. A failed
migration leaves the key in place and retries on the next load, which is safe
because the merge is idempotent: the second attempt skips everything the first
inserted. The decision half lives in `planMigration`, kept pure and covered by
the smoke test — it is the one place here where a bug would silently lose or
resurrect somebody's collection.

## Lookups, and what still leaves the site

`/api/media-vault/lookup` proxies the metadata searches so the browser never
talks to a third party. It takes a `mode`:

| Mode | Source | Takes |
|---|---|---|
| `isbn` | OpenLibrary | `isbn` |
| `book-title` | OpenLibrary | `q`, optional `year` |
| `book-author` | OpenLibrary | `q`, optional `year` — resolves the author, then their works |
| `video-title` | TMDB | `q`, `kind`, optional `year` |
| `video-person` | TMDB | `q`, `kind`, `role` — actor or director |
| `video-detail` | TMDB | `id`, `kind` — the full record, with credits |

Only the fields the client renders come back; raw upstream payloads are never
relayed.

**What counts as an ISBN.** Four rules in `_lib/common.js`, deliberately
separate because each one earns the user a different sentence.

`normalizeIsbn` deletes every character that is not a digit or an `X` and
upper-cases what is left. That is blunt on purpose: the list of things that
turn up between an ISBN's digits when somebody pastes one is long and keeps
growing — the ASCII hyphen, the soft hyphen, the whole `U+2010`–`U+2015` dash
block a publisher's page uses, non-breaking spaces, zero-width characters, a
sentence's trailing full stop, and the word `ISBN` itself. Deleting everything
cannot be got wrong the way six separate allowances can. **The upper-case is
not cosmetic**: OpenLibrary returns a full record for `ISBN:043935806X` and
**nothing** for `ISBN:043935806x`.

`isIsbnShape` requires nine digits and a check character that may be `X`, or
thirteen digits. The proxy gates on it and answers anything else with a 400
that says what it wanted. The rule this replaced was `/^\d{10,13}$/`, wrong
both ways — it rejected every `X` check digit, **9.6% of ISBN-10s**, so real
books came back `Invalid ISBN`; and it accepted 11- and 12-digit strings that
are not ISBNs in any scheme, so a truncated paste was looked up and reported as
a book nobody has.

`looksLikeIsbn` decides **routing** in the client, where the alternative is a
film-title search. It asks "was this an attempt at an ISBN", not "is this a
valid one", because a mistyped number has to reach the path that can say so.
It is what keeps `Apollo 13 1995 1080p` a film search: those digits alone
normalise to a perfectly good ISBN-10 shape, so the rule is that an ISBN
attempt carries no letters beyond the label and a trailing `X`.

`isbnCheckDigitValid` runs **in the client only, before the request goes out**.
A checksum in the proxy would refuse numbers OpenLibrary may hold under a
mis-keyed record, and the reason to know is to say *"the check digit doesn't
match — that is almost always a typo"* instead of *"no results found"*. Those
were the same sentence until it existed, which is most of why ISBN lookup was
reported as broken.

`app.js` keeps its own copy of all four, because it is a plain script with no
module loader. **The smoke test pins every copy byte-for-byte** against
`_lib/common.js` and unit-tests the originals there.

**When OpenLibrary answers nothing.** `/api/books` returns `200` with an empty
body while it is having a bad moment, and that is byte-for-byte how it answers
for a book it has never catalogued. So the proxy **asks twice** before it
believes an empty answer: one repeat, after a short pause, and if that comes
back empty as well the lookup reports `found: false` exactly as it always did.
Measured against `043935806X` — a book OpenLibrary certainly holds — 2 of 12
direct requests hard-failed and one took 8.5 seconds, and a paste-add run got
`found: false` for it seconds after it had resolved perfectly. *"No results
found for that ISBN"* for a book that plainly exists is the symptom this app
was reported broken for, and this produced it with no typo involved.

Both calls are bounded, the first at **ten seconds** and the repeat more
tightly, so a hung upstream returns a message saying OpenLibrary was slow
rather than an opaque `502`. That budget is why there is **one** retry and not
two: the worst case has to stay under the 21 seconds this endpoint was already
measured taking, and the smoke test does that arithmetic rather than trusting
this paragraph. The retry can only ever turn a *no* into a *yes* — every way it
can fail returns the same `found: false` the code returned before it existed.

**Adding a shelf at once.** The import modal's second tab takes one ISBN per
line, up to **100** in a run, and looks each one up in turn. The loop runs in
the **browser**, not in a Pages Function: that sidesteps the 30-second limit
that applies to a Worker's whole batch, lets the run be cancelled halfway, and
lets the progress be watched. It calls the `isbn` lookup mode and the
`items/bulk` endpoint that already exist — **no new endpoint and no new mode**,
which is load-bearing, because the smoke test asserts the endpoint files are
exactly the six documented and that the README documents every mode the proxy
implements.

Nothing is written until Add selected is pressed, so cancelling, closing the
modal or losing the tab costs only the time already spent. Every line gets a
row saying what happened to it — found, not an ISBN, check digit wrong, or not
in OpenLibrary — and a found row can be unticked before committing; failures
are never silently skipped. A paste longer than the cap says how many lines it
is leaving out rather than quietly truncating. The commit is a single
`items/bulk` call, which is one `db.batch()` and therefore one transaction: it
all lands or none of it does. A run that would cross the 5000-item cap is
refused by that endpoint with a message naming the number, and the message is
shown as-is.

**TMDB needs a secret.** The v3 API key was hardcoded in `app.js` until this
moved server-side; it is now the **`TMDB_API_KEY`** environment variable —
`.dev.vars` locally, a Pages secret in production. The two failure modes are
reported differently on purpose: a **missing** secret returns 503 naming it,
and a **rejected** key returns an error naming both TMDB and the secret,
because the first time production rejected a key, the only clue was
`Upstream error 401`. It must be TMDB's 32-character v3 API key — a v4 read
access token is a long JWT and will not authenticate a `?api_key=` call. The
book modes are unaffected either way; so is the rest of the app.

**A key that was ever committed here is burned.** This repository is public,
and the old hardcoded key lived in `app.js` for months before moving
server-side — it is still readable in git history, and TMDB revoked it. The
fix for a rejected key is therefore to **regenerate it at TMDB** and paste the
new value into the Pages secret and `.dev.vars`; re-pasting the exposed one
will keep returning 401. Nothing in the app reads a key from the source any
more, and the smoke test fails if a 32-hex literal reappears in either the
client or the proxy.

**Cover images are still hotlinked** from `covers.openlibrary.org` and
`image.tmdb.org`, straight from the browser. That is deliberate: the images
carry no credential, and proxying them would put every poster through a Worker
for nothing. They are the only requests this app makes off-origin — the smoke
test checks that `app.js` names no external host at all, and no API key.
