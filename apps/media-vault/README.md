# MediaVault — a personal audiobook, movie and series library

Catalogue what you own. Add an item by hand, or look it up by ISBN, title,
author, actor or director and let the fields fill themselves in — one at a
time with **Add now**, or by pasting a whole shelf of ISBNs at once. Browse it
as a grid or a table, filter and sort it, select many at once to retype or
delete them, import and export CSV, and read the whole collection back as
ranked stats — most-collected authors, directors, actors, producers and genres,
each one clickable through to the items behind it.

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

## Data model

One table in the site's shared D1 database.

| Table | Notes |
|---|---|
| `media_items` | One row per item, keyed `(user_email, item_id)`. `user_email` is the Cloudflare Access identity, so a user only ever sees their own rows. Columns: the eleven item fields (`type`, `format`, `title`, `author`, `actors`, `producers`, `genre`, `series`, `location`, `cover`, `notes`) plus `added_at`. |

It is **not** prefixed, unlike FilamentForge's `ff_` tables. It predates that
convention and holds live data; renaming it would buy consistency at the price
of a data-copy migration. `db/schema.sql` notes that the character creator's
gear table is called `gear` rather than `items` specifically to stay clear of
it.

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
| `/api/media-vault/items/bulk-update` | POST | `{ ids, set }` — only `type` and `format` are settable, against a value whitelist |
| `/api/media-vault/items/bulk-delete` | POST | `{ ids }` — deletes exactly the named rows |
| `/api/media-vault/migrate` | POST | The one-time localStorage merge, below |
| `/api/media-vault/lookup` | GET | Metadata proxy, below |

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
