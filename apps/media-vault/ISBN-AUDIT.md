# MediaVault — ISBN lookup audit

Research pass on the reported "ISBN lookup and add doesn't work". Findings are
`F1`…`F10`, a menu to be taken one at a time. **All ten are now closed.** F1 as
PR #312, then F2/F3/F5/F6/F8/F9 together as #313, with F4 closing as F8's
diagnosis. **F10 was found while building those** and shipped as #320. **F7
went last, as #323** — it was held for a schema change it could not justify
alone, and the hold lifted when `B6` in the bulk file followed it immediately
(#324). Each outcome note sits under its own finding.
The evidence throughout describes the code as it stood **before** any of
this landed, which is what keeps the corpus table usable as an acceptance
test.

**Investigated 2026-08-26** against `9d16e9a` (`main`). The bulk/feature menu is
a separate file, `MEDIA-VAULT-BULK-AUDIT.md`, whose findings are numbered
`B1`…`B9`.

## How this was verified

Three ways, because code reading alone proves nothing:

1. **Code** — `apps/media-vault/app.js`, `functions/api/media-vault/lookup.js`,
   `items.js`, `_lib/common.js`, `db/schema.sql`, `apps/media-vault/test/smoke.mjs`.
2. **Local dev** — `npx wrangler d1 execute DB --local --file db/schema.sql`,
   then `npx wrangler pages dev --port 8801`. Port **8801**, deliberately not
   8788 (8788 was already listening, owned by another process). The build was
   confirmed mine before anything was concluded: the dev server reported
   `CF_PAGES_COMMIT_SHA 9d16e9a…`, matching local `HEAD`. Every corpus ISBN was
   driven through the real endpoint, and the ISBN flow was driven through the
   real page in a browser — the "what the user sees" column below is the actual
   `#lookupStatus` text, not an inference from the code.
3. **Upstream** — OpenLibrary probed directly for every corpus ISBN across four
   endpoints (`/api/books?jscmd=data`, `?jscmd=details`, `/isbn/{isbn}.json`,
   `/search.json?isbn=`), plus a 2,555-edition sample for check-digit frequency
   and a burst test for rate limits.

Two environment caveats, stated up front so nothing below is over-claimed:

- **The TMDB half of local dev is dead**, and that is a *local* fact only. The
  `TMDB_API_KEY` in the untracked, git-ignored `.dev.vars` is the right shape
  (32 chars) and is rejected by TMDB — exactly the burned-key condition
  `apps/media-vault/README.md:155-162` already documents. It is not evidence
  about the production Pages secret, and this audit makes no claim about
  production TMDB. It only limited one probe, noted at F1.
- **Nothing was verified as the affected user.** Production holds **1 distinct
  user and 3,544 rows** as of 2026-08-26 (read-only `--remote` aggregate), all
  `lillcreeper`; `nathanrapert@gmail.com` has none. Local dev runs as
  `dev@localhost` against an empty database. Where that matters, it is said.

---

## Root-cause statement

**There is no single fault. At least three stack, and the first diagnosis you
reach is not the one that matches the reported words.**

Ranked by how likely each is to be what the reporter actually hit:

1. **A mistyped or transcribed-wrong ISBN, reported back as "No results found
   for that ISBN."** This is the *only* input class in the whole corpus that
   produces that exact string. Every real ISBN that OpenLibrary holds came back
   found; the four corpus rows that produced "No results found" were a wrong
   check digit, a second wrong check digit, a truncated 12-digit string, and an
   11-digit non-ISBN. Nothing in the app distinguishes "you mistyped it" from
   "OpenLibrary doesn't have it", so a typo is reported as a missing book. See
   **F8** for the fix and **F4** for the nastier version, where a typo that
   happens to have a valid check digit auto-fills a *completely different book*
   and reports success.

2. **An ISBN-10 whose check digit is `X` — 9.6% of all ISBN-10s (measured, see
   F1).** These never reach OpenLibrary at all. The user sees either
   `Lookup failed: Invalid ISBN` (ISBN button) or the result of a **TMDB movie
   search for the ISBN string** (Enter key) — and the movie-search branch ends
   at `No movies found for "043935806X".` (`app.js:636`), which is a
   "no results" message about an ISBN. If the reporter is paraphrasing rather
   than quoting, this is the cause that best explains the complaint. **F1.**

3. **A pasted ISBN carrying an en dash, a leading `ISBN `, or a trailing
   period.** Normalisation strips only `[-\s]`. Publisher pages and Amazon
   listings routinely use `–` (U+2013). **F2.**

**The "and add" half of the complaint is not a second failure in the save
path.** The save path was driven end-to-end locally — ISBN lookup, then *Add to
Vault* — and the row landed in D1 with every field byte-identical to the
in-memory copy, sync dot green, modal closed. `MAX_ITEMS` is not implicated
either: the library sits at 3,544 of 5,000 and the cap failure, when it does
fire, is an explicit `Library is full (max 5000 items)` surfaced through
`apiWrite`'s alert, not a silent no-op. What "and add" most likely describes is
that a *successful* lookup still leaves the user with six more fields and a
button (**F5**) — or simply that the user says "lookup and add" for one flow, as
the brief anticipated.

---

## ISBN test corpus

19 ISBNs, chosen before any conclusion was drawn, spanning every axis the brief
named. "What the user sees" is the observed `#lookupStatus` text via the ISBN
button; the last column records where the **Enter key** sends the same input.

| # | Input (as typed) | Book / why it's here | Expected | Endpoint returned | What the user sees | Enter routes to | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | `9780743273565` | The Great Gatsby — popular, ISBN-13 | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 2 | `0743273567` | same book, ISBN-10 | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 3 | `978-0-06-112008-4` | To Kill a Mockingbird — hyphenated | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 4 | `0 451 52493 4` | Nineteen Eighty-Four — space-separated | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 5 | `043935806X` | HP: Order of the Phoenix — **ISBN-10, check digit X** | found | `400 {error:"Invalid ISBN"}` | Lookup failed: Invalid ISBN | **TMDB movie search** | **FAIL — F1** |
| 6 | `052562483X` | Ready Player One **audiobook** (Random House Audio, `audio cd`) — ISBN-10, X | found | `400 {error:"Invalid ISBN"}` | Lookup failed: Invalid ISBN | **TMDB movie search** | **FAIL — F1** |
| 7 | `9780525624837` | same audiobook, ISBN-13 | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 8 | `9781491523223` | The Martian **audiobook** (Podium/Brilliance, `audio cd`) | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 9 | `9798465662277` | Pride and Prejudice — **`979-` prefix** (KDP) | found | `200 {found:true}`, **`cover:""`** | ✓ Found! Fields auto-filled. | ISBN | **pass, no cover — F6** |
| 10 | `9798885799263` | Fourth Wing — **`979-` prefix** (Cengage Gale) | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 11 | `9780262033848` | Introduction to Algorithms — 4 authors | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 12 | `9782356414915` | *Le Hobbitt* 2 CD MP3 — obscure, French, audio | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 13 | `0001046764` | The Hobbit, **Audio Cassette** (HarperCollins Audio) — obscure ISBN-10 | found | `200 {found:true}` | ✓ Found! Fields auto-filled. | ISBN | **pass** |
| 14 | `054792822X` | The Hobbit pbk — ISBN-10 ending X, and OpenLibrary's record carries **no** ISBN-13 | found | `400 {error:"Invalid ISBN"}` | Lookup failed: Invalid ISBN | **TMDB movie search** | **FAIL — F1** |
| 15 | `9781234567897` | constructed: valid check digit, invented number | not found | `200 {found:true}` → *"Construction Cost Consultant for Residential Commercial and Industrial Construction Projects"* | ✓ Found! Fields auto-filled. | ISBN | **wrong book reported as success — F4** |
| 16 | `9780743273566` | row 1 with the last digit mistyped | not found | `200 {found:false}` | **No results found for that ISBN.** | ISBN | **matches the report — F4 / F8** |
| 17 | `0439358061` | row 5 with the `X` mistyped as `1` | not found | `200 {found:false}` | **No results found for that ISBN.** | ISBN | **matches the report — F4 / F8** |
| 18 | `978074327356` | 12 digits — a truncated paste | rejected as malformed | `200 {found:false}` | **No results found for that ISBN.** | ISBN | **FAIL — F1** (accepted as an ISBN) |
| 19 | `12345678901` | 11 digits — not an ISBN in any scheme | rejected as malformed | `200 {found:false}` | **No results found for that ISBN.** | ISBN | **FAIL — F1** (accepted as an ISBN) |

Supplementary normalisation probes (same endpoint, same run):

| Input | After `replace(/[-\s]/g,'')` | Result |
|---|---|---|
| `978–0–06–112008–4` (en dash U+2013) | unchanged, still has dashes | `400 Invalid ISBN` — **F2** |
| `978‑0‑06‑112008‑4` (non-breaking hyphen U+2011) | unchanged | `400 Invalid ISBN` — **F2** |
| `ISBN 978-0-06-112008-4` | `ISBN9780061120084` | `400 Invalid ISBN` — **F2** |
| `9780061120084.` (trailing period) | unchanged | `400 Invalid ISBN` — **F2** |
| `9780061120084​` (zero-width space) | unchanged | `400 Invalid ISBN` — **F2** |
| `978 0 06 112008 4` (NBSP) | `9780061120084` | ✓ found — `\s` already covers NBSP |
| `043935806x` (lowercase x) sent straight to OpenLibrary | — | **miss**; `043935806X` **hits**. Any fix must upper-case — **F1** |

**This table is the acceptance test.** A fix for F1 turns rows 5, 6, 14 green
and rows 18, 19 into an explicit malformed-input message. A fix for F8 turns
rows 16 and 17 into a check-digit message. Rows 1–4, 7–13 must stay green.

---

## Questions for the reporter

Paste as-is. These are the things the code and my own probes genuinely cannot
settle.

1. Can you send me **three actual ISBNs** that failed for you — copied and
   pasted exactly as you typed them, including any dashes or spaces? Three real
   failures beat any amount of testing on my end.
2. For each one: **did you type it by hand, or paste it** from somewhere? If
   pasted, where from (an Amazon page, a publisher's site, a spreadsheet)?
3. When it failed, what did the message say, **word for word**? Specifically,
   was it "No results found for that ISBN.", "Lookup failed: Invalid ISBN", or
   something mentioning movies?
4. Did you press **Enter**, or click the **ISBN** button?
5. Were these mostly **audiobooks**, and if so did you take the ISBN off a
   physical case, a retailer page, or somewhere else? (Audible-only titles often
   have no ISBN at all — an ASIN is not an ISBN and will never resolve.)
6. What **browser and device** — phone, tablet, laptop, and which browser?
7. When it "didn't add": did the fields **fill in and then the save fail**, or
   did the lookup itself never find anything?

---

## What I disproved

Three of the leads in the brief were wrong, and one turned out to be sound.

- **The `jscmd=data` coverage gap does not exist.** This was the most promising
  hypothesis and it is dead. Across every real ISBN in the corpus,
  `/api/books?jscmd=data` returned a hit wherever `/isbn/{isbn}.json` or
  `search.json` did — **14 of 14**, no exceptions. It survives a further test
  too: for editions whose OpenLibrary record carries *only* an ISBN-10, the
  derived ISBN-13 also hits, and vice versa (12 of 12 across two directions),
  so OpenLibrary normalises the two forms itself. **A fallback chain would buy
  nothing**, and the one endpoint that behaves differently behaves *worse*:
  `search.json?isbn=9781234567897` returned **24 results** for an invented
  number, and the three endpoints returned three unrelated titles for it. Do
  not build the fallback. (This also means the escalation the brief anticipated
  — "OpenLibrary alone cannot cover these books" — is not needed. It covers
  them.)
- **The save path is not broken.** Driven end-to-end locally: lookup →
  *Add to Vault* → row in D1, every column identical to the client's copy, sync
  dot green. `sanitizeItem`, `UPSERT_SQL` and the `MAX_ITEMS` guard all behaved
  correctly at and around the cap (verified separately by filling a local
  library to exactly 5,000: a new id is refused with an explicit error, an
  *existing* id still saves, which is the right behaviour).
- **The leaner `isbn` response shape costs the user nothing.** The brief
  suspected that returning only `title/authors/genre/cover` — no `year` — leaves
  the user hand-typing fields that the title/author flow would have filled. It
  does not. `fillBookFields` (`app.js:580-589`) reads exactly
  `title`, `authors`, `genre`, `cover` and ignores `year` entirely, and it is
  the *same function* both flows call. There is also no `year` column on
  `media_items` for it to land in (`db/schema.sql:13-29`). The two paths fill
  identically. Nothing to fix here.
- **The regex hypothesis was right, and worse than described.** It rejects
  `X` check digits *and* accepts 11- and 12-digit non-ISBNs, and the same regex
  at `app.js:452` misroutes the input before the endpoint ever sees it. **F1.**

Also working, and worth saying so because a reasonable person would assume
otherwise:

- Hyphenated and space-separated ISBNs work fine (corpus rows 3, 4) — including
  non-breaking spaces.
- `979-` prefixed ISBN-13s work fine (rows 9, 10). They have no ISBN-10 form and
  never hit the `X` bug.
- Audiobook editions are in OpenLibrary and resolve fine when they have an ISBN
  (rows 7, 8, 12, 13). Of 113 audio-format editions in a 2,555-edition sample,
  exactly **1** carried no ISBN at all.
- Obscure and non-English editions resolve (rows 12, 13).
- OpenLibrary is not rate-limiting us: 30 back-to-back requests all returned
  200 (16.3 s total, ~540 ms each), and 12 concurrent all returned 200 in 2.0 s.
  No rate-limit headers are exposed. Slow, but not throttled.

---

# Findings

Core faults first, then the two adjacent items §1 put in scope. Note that the
root-cause statement ranks a *cause* (mistyping) above F1 whose *fix* is filed
at F8 — that is deliberate, and follows the brief's ordering rule. If you want
the single change most likely to end the complaint, it is **F8**; the single
change that fixes the most books outright is **F1**.

---

## F1 — The ISBN gate rejects every ISBN-10 ending in `X`, and waves through 11- and 12-digit strings that are not ISBNs

**What's wrong.** `/^\d{10,13}$/` is used as an ISBN test in two places. It
rejects the `X` check digit that **9.6% of ISBN-10s carry**, and it accepts any
run of 10–13 digits, so a truncated paste is sent to OpenLibrary as if it were a
book and comes back as "No results found". The same regex on the client
*misroutes* the input before the endpoint is ever called.

**Evidence.**

- `functions/api/media-vault/lookup.js:86` — `if (!/^\d{10,13}$/.test(isbn)) return json({ error: 'Invalid ISBN' }, 400);`
- `apps/media-vault/app.js:452` — `if (/^\d{10,13}$/.test(val.replace(/[-\s]/g, ''))) lookupISBN(); else lookupMovie();`
- Corpus rows **5, 6, 14** — three real, in-OpenLibrary books (including a
  Random House Audio audiobook and a Tolkien paperback) rejected `400 Invalid
  ISBN`. All three exist: probed directly, `jscmd=data` returns full records for
  each.
- Corpus rows **18, 19** — `978074327356` (12 digits) and `12345678901`
  (11 digits) were both accepted as ISBNs and reported as "No results found for
  that ISBN", which is a lie about what went wrong.
- **Frequency, measured not assumed:** across 2,555 OpenLibrary edition records
  for 8 works, **118 of 1,233** ISBN-10 values end in `X` = **9.6%** (the
  theoretical 1-in-11). This is not an exotic edge case.
- **Case matters:** OpenLibrary returns a hit for `ISBN:043935806X` and a **miss**
  for `ISBN:043935806x`. A fix that accepts lowercase `x` without upper-casing
  it converts a hard failure into a silent "not found".
- Browser-driven: with an `X` ISBN, the Enter key produced no `mode=isbn`
  request at all — the request went to `mode=video-title`. (Locally that ends in
  the burned-key TMDB error; in production, with a working key, it ends at
  `app.js:636`, `No movies found for "043935806X".`)

**Proposed fix.** One shared shape test, used by both call sites:

- Add an exported helper (`_lib/common.js` is the natural home — it is already
  imported by `lookup.js`, and the app duplicates rather than imports, so the
  client needs its own copy):
  `normalizeIsbn(s)` → strip separators, upper-case, return the string;
  `isIsbnShape(s)` → `/^(?:\d{9}[\dX]|\d{13})$/`.
- `lookup.js:85-86` — normalise with the shared function, gate on
  `isIsbnShape`, and use the **normalised, upper-cased** value in the
  `bibkeys=ISBN:` URL.
- `app.js:452` — gate on the same shape test so Enter routes correctly, and
  `app.js:474` — normalise identically before sending.
- Keep the 400 for genuinely malformed input, but change the message from
  `Invalid ISBN` to something that names the problem, e.g.
  `That isn't a 10- or 13-digit ISBN` — so rows 18/19 stop being reported as
  missing books.

Do **not** fold check-digit validation into this. That is F8, it has a different
risk profile, and a shape test is the correct gate for the endpoint regardless.

**Blast radius.** `functions/api/media-vault/lookup.js`,
`apps/media-vault/app.js`, and `functions/api/media-vault/_lib/common.js` if the
helper lands there. **No schema change.** **The 57-check smoke suite still
passes** — nothing pins either regex; the only lookup-related checks are
`smoke.mjs:222-227` (README documents every `case` in `lookup.js` — unaffected,
no new mode) and `smoke.mjs:256-258` (no `Lookup failed:` prefix in the
proxy — keep the new message free of that prefix). Does not touch the
localStorage migration path. **Verifiable before merge** entirely from the
corpus table above, on your own data — rows 5, 6, 14 must go green.

**Independence.** Take alone. Nothing depends on it, though F7 and F8 are more
useful after it.

- **Taken, 2026-08-26** (PR #312, commit `c001512`):
  substantially as proposed, with one deliberate departure and two additions.
  `normalizeIsbn` and `isIsbnShape` are exported from
  `functions/api/media-vault/_lib/common.js`; `lookup.js` gates on them and
  sends the normalised value upstream; the 400 now reads *"That isn't a 10- or
  13-digit ISBN"*. Check-digit validation was left out, as specified — that is
  still F8.

  **The departure:** `handleLookupEnter` routes on `/^\d{9,}X?$/` — "could this
  only be an ISBN?" — not on `isIsbnShape`. Routing on the shape test would
  have failed this finding's *own* acceptance criterion: corpus rows 18 and 19
  reach "an explicit malformed-input message" only if they land on the ISBN
  path, and gating on shape would have sent `978074327356` to TMDB and answered
  it with *"No movies found for 978074327356"* — worse than the behaviour being
  fixed. `1984` still routes to the film search, as it must.

  **The additions:** `isIsbnShape` is deliberately *not* copied into `app.js`,
  so the malformed-ISBN message exists in exactly one place; only the
  normaliser is duplicated, and a new smoke section pins the two copies
  byte-for-byte and fails if the shape test is duplicated in as well. The
  MediaVault suite went from **57 checks in 5 sections to 67 in 6**. The README
  gained a "What counts as an ISBN" paragraph and two file-map lines, so the
  test suite's own description stays true. The finding predicted the 57 checks
  would pass untouched, and they would have — this is a pin added on top, not a
  break repaired.

  **Verified** by re-running the corpus table through the real endpoint and the
  real page: rows 5, 6 and 14 now report ✓ Found with title, author, genre and
  cover filled; rows 18 and 19 now report the malformed message; the twelve
  that passed before still pass. Lower-case `x` was confirmed to resolve, which
  it does not without the upper-casing.

  **Merged 2026-08-26** as `4da02a0`, and confirmed live in production through
  Access: the deployed `app.js` carries `normalizeIsbn` and correctly does not
  carry `isIsbnShape`; `0-439-35806-X`, `052562483X`, `054792822X` and the
  lower-case `0-439-35806-x` all return Order of the Phoenix / Ready Player One
  / The Hobbit with covers, `978074327356` returns the malformed message, and
  Enter routes all four ISBN forms to the ISBN path while `Blade Runner` and
  `1984` still go to the film search. Nothing was saved during that check.
  `scripts/drift-check.mjs --remote` prints `NO DRIFT`.

---

## F2 — A pasted ISBN with an en dash, a leading `ISBN `, or a trailing period is rejected as "Invalid ISBN"

**What's wrong.** Normalisation strips only ASCII hyphens and whitespace.
Publisher and retailer pages routinely render ISBNs with a typographic en dash,
and copy-paste routinely drags in a label or a sentence-ending period.

**Evidence.** `lookup.js:85` and `app.js:474`, both
`.replace(/[-\s]/g, '')`. Probed against the running local endpoint:

| Pasted | Result |
|---|---|
| `978–0–06–112008–4` (U+2013) | `400 Invalid ISBN` |
| `978‑0‑06‑112008‑4` (U+2011) | `400 Invalid ISBN` |
| `ISBN 978-0-06-112008-4` | `400 Invalid ISBN` |
| `9780061120084.` | `400 Invalid ISBN` |
| `9780061120084​` (trailing U+200B) | `400 Invalid ISBN` |

The same book with plain hyphens (corpus row 3) is found.

**Proposed fix.** In the shared `normalizeIsbn` from F1: strip a
case-insensitive leading `ISBN` and any `:` after it, then remove every
character that is not `[0-9Xx]`, then upper-case. That single rule subsumes
hyphens, all dash variants, all space variants, zero-width characters, the label
and the trailing period, and needs no per-character allow-list. Length and shape
are then checked by `isIsbnShape`.

**Blast radius.** Same two-or-three files as F1. No schema change. Smoke suite
unaffected — nothing pins the normaliser. Verifiable before merge from the table
above.

**Independence.** **Requires F1 first** — it edits the same normaliser F1
introduces. Taking F2 alone would mean writing that helper here instead, which
is fine but then F1 becomes the dependent one. Take F1, then F2.


- **Taken, 2026-08-26** (PR #313): as proposed, and the normaliser went further than the finding asked: it now
  deletes every character that is not a digit or an `X` rather than
  allow-listing separators. That needed a guard the finding did not foresee —
  `Apollo 13 1995 1080p` normalises to ten digits, a valid ISBN-10 shape — so a
  new `looksLikeIsbn` decides routing on "carries no letters beyond the label
  and a trailing X". Verified: en dashes, non-breaking hyphens, a pasted
  `ISBN`/`ISBN:` label, a trailing full stop and a zero-width space all
  normalise to the same thirteen digits, and `The Matrix` stays a film search.

---

## F3 — A second lookup in the same modal keeps the previous book's cover, silently

**What's wrong.** `fillBookFields` overwrites title, author and genre
unconditionally but only writes the cover **if the new book has one**. Look up
two books without closing the modal and the second one is saved with the first
one's cover art. Nothing warns; the status line says "✓ Found! Fields
auto-filled."

**Evidence.** `apps/media-vault/app.js:580-589`, specifically
`if (book.cover) { … }` at line 585 — there is no `else` clearing it.
Reproduced in the browser against local dev:

| Step | title | cover |
|---|---|---|
| Look up `9780743273565` | The Great Gatsby | `…/b/id/14314120-L.jpg` |
| Then look up `9798465662277` in the same modal | **Pride and Prejudice** | `…/b/id/14314120-L.jpg` ← **still Gatsby's** |

Corpus row 9 is the trigger: the `979-` Pride and Prejudice edition record has
no cover, so the endpoint returns `cover: ""`. Saving at that point writes
Gatsby's jacket onto Austen's row. The same test also showed `series` and
`notes` the user had typed by hand surviving both lookups — which is arguably
correct, but means the modal has no clean "this is now a different book" state.

**Proposed fix.** In `fillBookFields`, set the cover unconditionally:

```js
const cover = book.cover || '';
document.getElementById('coverUrl').value = cover;
document.getElementById('itemCoverInput').value = cover;
```

That is the whole fix. Optionally also blank `actors`/`producers` when filling
from a book, since a book result can never populate them; leave `series`,
`location` and `notes` alone — those are the user's, not the lookup's.

**Blast radius.** `apps/media-vault/app.js` only, three lines. No schema change,
no endpoint change, smoke suite unaffected. **Verifiable before merge** by the
two-lookup sequence above. Note this fault can already have written wrong covers
into `lillcreeper`'s rows — that is not repairable from here and
would need B6 (bulk re-lookup) or a manual pass; do not attempt a data fix as
part of this finding.

**Independence.** Take alone.


- **Taken, 2026-08-26** (PR #313): as proposed, plus `actors` and `producers`, which the finding offered as
  optional and which carry a film's cast onto a book for exactly the same
  reason. `series`, `location` and `notes` are left alone. Verified: Gatsby
  then the 979- edition in one modal now changes cover with the book, while a
  hand-typed `series` survives both lookups.

---

## F4 — Nothing distinguishes "you mistyped it" from "we don't have it", and a typo with a valid check digit auto-fills the wrong book

*(This is the diagnosis; the UI change is F8, filed below with the other §1
adjacent item. It is stated here because it is the leading root cause and
belongs among the core findings.)*

**What's wrong.** No check-digit validation exists anywhere in the app or the
endpoint. Every malformed, mistyped or truncated ISBN takes the same path as a
genuinely missing book and ends at the same sentence. Worse, roughly 1 in 10
single-digit typos produces a *valid* check digit, and OpenLibrary's catalogue
is dense enough that such a number can resolve to a real, unrelated book that is
then auto-filled and reported as a success.

**Evidence.**

- Corpus rows **16** (`9780743273566`, Gatsby's last digit off by one) and
  **17** (`0439358061`, an `X` mistyped as `1`) both produce, verbatim,
  **"No results found for that ISBN."** — the reported symptom, from valid-format
  input, on books that plainly exist under their correct ISBNs (rows 1 and 5).
- Corpus row **15**: `9781234567897` — an invented number with a correct check
  digit — returned `found: true` and auto-filled *"Construction Cost Consultant
  for Residential Commercial and Industrial Construction Projects"* with a real
  cover, under the status "✓ Found! Fields auto-filled." The one mitigation is
  that the filled title is visible, so an attentive user would notice.
- `app.js:484-487` is the only branch that produces the message, and it fires
  solely on `!data.found`; `lookup.js:89` returns `{found:false}` with no
  distinction between causes.

**Proposed fix.** See **F8** — this finding exists to rank the cause, not to
duplicate the remedy.

**Blast radius / independence.** See F8.

- **Closed, 2026-08-26** (PR #313): diagnosis only, no code of its own. Its
  remedy shipped as F8.

---

## F5 — A successful ISBN lookup fills three fields and adds nothing; the flow the user calls "lookup and add" is six more steps

**What's wrong.** ISBN lookup populates `title`, `author`, `genre` and `cover`
and stops. `type` is forced to `audiobook`; `format`, `series`, `location` and
`notes` are untouched; the item exists only when the user then clicks *Add to
Vault*. Nothing on screen says "now press the button". For a user cataloguing a
shelf one book at a time, this is the whole complaint even when every lookup
succeeds.

**Evidence.** `app.js:490` calls `fillBookFields(data.book)` and returns;
`fillBookFields` (`580-589`) writes four fields and forces
`itemType = 'audiobook'`. The save is a separate user action, `saveItem`
(`app.js:253`), reached only from the *Add to Vault* button. Verified in the
browser: after a successful lookup the library was still empty; after clicking
save it held one row.

**Proposed fix.** Two options, take one:

- *Minimal:* change the success line at `app.js:491` from
  `✓ Found! Fields auto-filled.` to `✓ Found — check the fields, then Add to
  Vault.`, and focus the save button.
- *Fuller:* add an **Add now** button beside the ISBN button that runs the
  lookup and, on a hit, calls `saveItem()` immediately, leaving the modal open
  and the lookup field selected so the next ISBN can be typed straight away.
  This is the single-item form of **F9** and should reuse whatever F9 builds.

**Blast radius.** `apps/media-vault/app.js` and, for the fuller option, one
button in `apps/media-vault/index.html`. No endpoint, no schema change. Smoke
suite unaffected. Verifiable locally.

**Independence.** Take alone. If you intend to take **F9** as well, take F9
first and let this be its one-at-a-time front end, or the work is done twice.


- **Taken, 2026-08-26** (PR #313): the *fuller* option, sharing F9's machinery as the finding advised — an
  **Add now** button beside ISBN that saves and leaves the modal open with the
  box empty and focused. One case the finding missed: in edit mode it would
  have minted a new id and duplicated the row, so it refuses there and says to
  press Save Changes instead.

---

## F6 — The `isbn` mode drops the cover whenever the *edition* has none, though OpenLibrary has one for the *work*

**What's wrong.** `jscmd=data` returns cover URLs per **edition**. Print-on-
demand and reissue editions frequently have no cover image of their own even
when OpenLibrary holds several for the work. The endpoint returns `cover: ""`
and the item is saved coverless.

**Evidence.** `lookup.js:96` reads `book.cover.large || medium || small` and
nothing else. Corpus row 9, `9798465662277`: the edition record has
`covers: []` so the endpoint returned `cover: ""` — while `search.json` for the
same ISBN returns `cover_i: 14348537`, an existing OpenLibrary cover for the
work. Production has **1,579 of 3,544 rows with an empty cover** as of
2026-08-26 (read-only `--remote` aggregate); this fault is one contributor.

**Proposed fix.** Inside OpenLibrary only — no second provider. When
`book.cover` is absent, make one further call to
`${OL_BASE}/search.json?isbn=${isbn}&limit=1&fields=cover_i` and, if `cover_i`
comes back, return `https://covers.openlibrary.org/b/id/${cover_i}-L.jpg`. Guard
it so it fires **only** on the no-cover path, so the common case stays a single
request. `search.json` is unreliable as a *lookup* (see "What I disproved") but
is being used here only to fetch a cover id for an ISBN we have already
resolved, which is a different and much weaker claim.

**Blast radius.** `functions/api/media-vault/lookup.js` only. No schema change.
Smoke suite unaffected — no new mode, no new file, `smoke.mjs:222-227` still
sees six `case` labels. Adds at most one upstream request per coverless lookup;
OpenLibrary showed no rate limiting at 12 concurrent. Verifiable before merge
with corpus row 9.

**Independence.** Take alone.


- **Taken, 2026-08-26** (PR #313): as proposed **plus a timeout, which was not optional**. Written exactly as
  specified, the fallback took OpenLibrary **21 seconds** for the first ISBN it
  met and took the whole lookup down with it — a request that returned a book
  in under a second returned a 502. `search.json` is a query, not a key lookup,
  and it is unpredictable by whole seconds. It now gets 2.5s via
  `AbortSignal.timeout` and every failure returns an empty string. Verified on
  corpus row 9: `9798465662277` now comes back with the work's cover,
  `…/14348537-L.jpg`, which is the id this finding's evidence cited.

---

## F7 — The ISBN is never stored, so a bad lookup can never be corrected and a re-lookup can never be exact

**What's wrong.** `media_items` has no ISBN column and the lookup never persists
the number the user typed. Once an item is saved, the link back to its source
record is gone. Every downstream capability that wants to "re-run the lookup"
must instead guess from title and author.

**Evidence.** `db/schema.sql:13-29` — columns are `user_email`, `item_id`,
`type`, `format`, `title`, `author`, `actors`, `producers`, `genre`, `series`,
`location`, `cover`, `notes`, `added_at`. No ISBN, and no TMDB id either.
`ITEM_FIELDS` (`_lib/common.js:24`) matches. `fillBookFields`
(`app.js:580-589`) writes four fields and discards the ISBN it was called with;
`selectTMDBResult` (`app.js:665-700`) likewise writes year/runtime/rating into
`notes` but never the TMDB id.

**Proposed fix.** Add one column, `source_id TEXT NOT NULL DEFAULT ''`, holding
the normalised ISBN for books and `tmdb:movie:1234` / `tmdb:tv:1234` for video;
populate it in `fillBookFields` and `selectTMDBResult` via a hidden input the
way `coverUrl` already works. A single generic column beats two nullable ones
and keeps `media_items` under D1's 100-column ceiling with room to spare.

**Blast radius.** This is the one finding here that **needs a schema change**,
and per the `schema-change` skill a column lands in **five** places:
`db/schema.sql`, a new `db/migrations/0NN-*.sql`, `ITEM_FIELDS` in
`_lib/common.js` (which flows into `sanitizeItem`, `rowToItem`, `UPSERT_SQL` and
`bindUpsert`), `apps/media-vault/index.html` (the hidden input), and
`apps/media-vault/README.md`. **The smoke suite WILL fail** until the README is
updated: `smoke.mjs:247-250` asserts every `ITEM_FIELDS` entry is a schema
column *and* that the README names each one in backticks, and `smoke.mjs:82`'s
"eleven item fields" sentence becomes wrong. `UPSERT_SQL` goes from 14 to 15
bound parameters — still far under the 100 ceiling. It does **not** break the
migration path: `planMigration` keys on title+type and `sanitizeItem` defaults
the new column to `''`, so old localStorage payloads still merge. **Cannot be
fully verified before merge for the affected user** — existing rows all get
`''`, and only newly-added items carry a source id, so a real backfill needs
B6.

- **Held, 2026-08-26**: deliberately NOT taken with F2/F3/F5/F6/F8/F9. Two
  reasons. It is the one item here that needs a D1 column, and this repo applies
  schema to production *before* the merge that needs it — bundling it would mean
  a revert of any UI item leaves a column already live. And it touches the exact
  functions PR #313 rewrote (`ITEM_FIELDS`, `UPSERT_SQL`, `fillBookFields`,
  `selectTMDBResult`), so branching it off `main` alongside #313 guarantees a
  conflict in the rewritten code. It should be taken **after #313 merges**, and
  only if B6 is going to follow — on its own it changes nothing a user can see.

- **Taken, 2026-08-26** (PR #323), when both conditions the hold named came
  true: #313 has merged, and B6 followed immediately (PR #324). `source_id
  TEXT NOT NULL DEFAULT ''` as proposed, in all five places the `schema-change`
  skill names, plus the hidden input and the two writers.

  **Migration `040` was applied to production before the merge**, per the
  ordering rule. Verified by asking production rather than by exit code: column
  present, `040` recorded, **3,544 rows all at `''`**, and
  `drift-check --remote` reports `NO DRIFT` across 40 migrations.

  The column was the easy half. The work was the **four paths that would have
  dropped it without failing anything** — `saveItem` not reading the input,
  `editItem` silently erasing it when you correct an item's notes, `clearForm`
  letting one book inherit the last one's source (the F3 cover carry-over bug
  again, and worse: a stale cover is a wrong picture, a stale source id is what
  a re-lookup *trusts*), and the CSV round trip dropping it from every row.
  Each has a smoke check, each proven to fail when the line is removed.

  One decision the finding left open: **a title or author search stores
  nothing.** Those results carry no ISBN, and inventing one from the title is
  the guess the column exists to avoid. Empty is the honest answer.

  Suite 129 to 143. **Merged 2026-08-26** as `bd6abc5`. Confirmed in production:
  the deployed client carries the hidden input and both writers, and
  `drift-check --remote` reports `NO DRIFT`.

**Independence.** Take alone, but it is **only worth taking if you intend to
take B6** (bulk re-lookup) or want to future-proof. On its own it changes
nothing a user can see. **Cross-file dependency: `MEDIA-VAULT-BULK-AUDIT.md`
B6 depends on this finding** — without it, bulk re-lookup can only match by
title, which is lossy.

---

## F8 — Check-digit feedback in the UI *(§1 adjacent item)*

**What's wrong.** The user cannot tell a typo from a missing book. See F4 for
the full diagnosis and evidence; this is the remedy.

**Evidence.** Corpus rows 16, 17 — both produce "No results found for that
ISBN." from a single mistyped digit. `app.js:484-487` is the only branch that
produces that string.

**Proposed fix.** Validate the check digit **client-side only**, before the
request is sent, in `lookupISBN` (`app.js:473`):

```js
// after normalising, before fetching
if (!isbnCheckDigitValid(isbn)) {
  status.textContent = `That ISBN's check digit doesn't match — it's probably a typo. Check the last character of ${formatted}.`;
  status.className = 'lookup-status error';
  return;
}
```

with the standard mod-11 (ISBN-10, `X` = 10) and mod-10 alternating-weight
(ISBN-13) algorithms. **Client-side only** is deliberate: the endpoint's job is
a shape gate (F1), and putting a checksum in the proxy would reject numbers
OpenLibrary might legitimately hold under a mis-keyed record, for no benefit.
Also change the not-found message at `app.js:485` to name the check digit as
verified, e.g. `That ISBN is well-formed, but OpenLibrary has no record of it —
try the title search.` and point at the 📚 button.

**Blast radius.** `apps/media-vault/app.js` only. No endpoint change, no schema
change, smoke suite unaffected. Verifiable before merge with corpus rows 16, 17
(must show the check-digit message) and rows 1–4, 7–13 (must be unaffected).

**Independence.** Take alone. **Cleanest after F1 and F2**, because the
normaliser they introduce is what feeds the validator — taken first, F8 has to
carry its own normalisation and F1 will then have two to reconcile.


- **Taken, 2026-08-26** (PR #313): as proposed, client-side only, with **one correction to the wording**. The
  empty-handed message was first written as the finding suggested —
  "OpenLibrary has no record of it" — and OpenLibrary disproved it the same
  afternoon: 2 requests in 12 failed outright, one took 8.5s, and `043935806X`
  came back empty from an API that certainly holds it. Asserting a catalogue is
  missing a book when the API had a bad second is a *more confident* lie than
  the vague message it replaced, so it now says what it saw and suggests a
  retry. The residual fault is filed as **F10**.

---

## F9 — Batch ISBN paste-add *(§1 adjacent item)*

**What's wrong.** There is no way to paste a list of ISBNs and add them all.
Cataloguing a shelf is one modal open, one lookup, one save, per book.

**Evidence.** The add modal (`index.html:191-213`) accepts a single value in
`#lookupInput`; `lookupISBN` (`app.js:473`) reads that one field and fills one
form. CSV import (`app.js:792-831`) is the only many-at-once path and it takes
already-complete rows — it performs no lookup at all.

**Proposed fix.** A textarea in the import modal (or a third tab there) taking
one ISBN per line, and a **client-side** loop that, for each line:

1. normalises and shape-checks it (F1/F2's helper), then check-digit-validates
   it (F8) — malformed lines are reported without ever leaving the browser;
2. calls the existing `GET /api/media-vault/lookup?mode=isbn` — **no new
   endpoint, no new lookup mode**;
3. accumulates hits into an item array, and finally posts the whole array once
   to the existing `POST /api/media-vault/items/bulk`.

Run the lookups client-side and **sequentially with a small delay**, not in a
Pages Function. Three reasons: it sidesteps every Worker execution limit; it
makes the operation naturally resumable and cancellable; and it lets the UI show
per-ISBN progress. Measured throughput for sizing: OpenLibrary served 30
back-to-back requests in **16.3 s** (~540 ms each) and 12 concurrent in
**2.0 s**, all 200, with no rate-limit headers. **Cap a single run at 100
ISBNs** — about a minute of wall clock, comfortably inside a user's attention
span, and far below anything OpenLibrary would object to. Show a per-line
result table (found / not found / bad check digit) and let the user deselect
before committing; do not silently skip failures.

**Blast radius.** `apps/media-vault/app.js`, `apps/media-vault/index.html`, and
`apps/media-vault/README.md` (the feature description at lines 3-8). **No new
endpoint file and no new lookup mode — which matters**: `smoke.mjs:216-219`
asserts the endpoint files are *exactly the six documented*, and
`smoke.mjs:222-227` asserts the README documents every `case` in `lookup.js`.
Both stay green only because this reuses what exists. No schema change. The
`MAX_ITEMS` guard in `items/bulk.js:51-53` already refuses a batch that would
cross 5,000 with an explicit message — surface it rather than swallowing it.
Verifiable before merge with a pasted list built from the corpus table.

**Independence.** **Requires F1 and F8.** Without F1 it silently drops ~1 in 10
ISBN-10s from every pasted list; without F8 a typo in a 60-line paste is
indistinguishable from a missing book and the user has no way to find it.
**Cross-file dependency: `MEDIA-VAULT-BULK-AUDIT.md` B6 (bulk re-lookup) shares
this finding's rate-limit, partial-failure and run-size analysis** — build the
per-item throttled lookup loop here and B6 should reuse it rather than write a
second one.


- **Taken, 2026-08-26** (PR #313): as proposed. Client-side loop, capped at 100, cancellable, reusing the `isbn`
  mode and `items/bulk` — no new endpoint and no new lookup mode, so
  `smoke.mjs`'s "exactly the six documented" and "documents every mode" checks
  stay green. Two additions: the same ISBN written two ways is deduped within a
  run (and the count reported, not swallowed), and the head count updates live
  when a row is unticked — it first read "5 selected to add" while committing
  four. Verified with a nine-line paste containing a duplicate, a typo and two
  malformed lines: exactly the four books left ticked reached D1.

  **Merged 2026-08-26** as `27e9739`, with F2/F3/F5/F6/F8, and confirmed live in
  production through Access. One thing the tests could not see and a screenshot
  could: while a run is in flight the stop control read "Cancel" directly beside
  the modal's own "Cancel". Relabelled to "Stop" and pinned, in PR #314.

---

## F10 — A transient OpenLibrary failure is indistinguishable from a book OpenLibrary does not have

**What's wrong.** `/api/books` answers an empty body while it is struggling, and
the proxy reports that as `{ found: false }` — the same response it gives for an
ISBN genuinely absent from the catalogue. The client then tells the user the
book is not there. Found while building F8, whose whole job is telling failures
apart.

**Evidence.** Measured 2026-08-26 against OpenLibrary, 12 sequential requests
for `043935806X` — a book it certainly holds, and the very ISBN from corpus row
5: **2 hard-failed** (`fetch failed` after ~10.8s each) and one took **8.5s**;
median 726ms, max 8,483ms. Through the proxy in a separate 14-request run, one
came back `502` after **21 seconds** while 13 returned the book. Separately,
during a paste-add run the same ISBN produced a `found: false` — a 200 with no
record for a book that resolved seconds earlier and seconds later.
`lookup.js:110` returns `{ found: false }` whenever the bibkey is absent, with
no way to distinguish "absent from the catalogue" from "absent from this
response".

This is not theoretical for the reported bug: **"No results found for that
ISBN" for a book that plainly exists** is precisely the symptom, and this
produces it without any typo involved.

**Proposed fix.** One retry inside the proxy's `isbn` branch before concluding
`found: false` — a single re-request after ~400ms, since the failure is
transient by nature. If the second attempt is also empty, return `found: false`
as now. Keep it to one retry: two would double the worst case against an
upstream already measured at 21 seconds, and the endpoint has no timeout of its
own. Consider bounding the primary `/api/books` call with `AbortSignal.timeout`
the way F6's cover fallback now is, so a hung upstream returns a *named* error
rather than an opaque runtime 502.

**Blast radius.** `functions/api/media-vault/lookup.js` only. No schema change,
no new endpoint, no new mode. Smoke suite unaffected. **Hard to verify
deterministically** — it reproduces only while OpenLibrary is degraded; test it
by pointing `OL_BASE` at a stub locally, or accept it as a change verified by
inspection and say so in the PR.

**Independence.** Take alone. Independent of everything above; F8 already
softened the *wording* so the message no longer asserts something this fault
makes false, which is why this is a real finding rather than an urgent one.


- **Taken, 2026-08-26** (PR #320): as proposed, and the "consider" was taken
  too — the primary `/api/books` call is bounded now as well, at ten seconds.
  That turned out to be the half worth having: while verifying, a real request
  to the real OpenLibrary hit the bound and rendered a message naming
  OpenLibrary instead of an opaque `502`.

  **The finding called this hard to verify deterministically. It isn't.** A
  local stub scripted to misbehave on demand, with `OL_BASE` pointed at it and
  the upstream requests counted, settles every case: answers-first-time stays
  **one** request (92ms); empty-then-the-book becomes **found** at 515ms, which
  is the fix; empty-twice and empty-then-`500` both land on `found: false`; a
  hung upstream is named at 10.1s; and the worst case — a slow-empty primary
  followed by a hung retry — measured **14.5s**, under the 21s this endpoint
  could already take. Then confirmed against the real OpenLibrary, and in a
  browser.

  Two things the finding did not anticipate. The budget arithmetic is now a
  **smoke check** rather than a comment, so "one retry, not two" fails the
  suite instead of being remembered. And the client's not-found sentence hedges
  *less* than F8 left it — it used to end "it is worth one retry before you
  trust it", advice the code now takes on the user's behalf.

  A genuine miss costs ~400ms and a second request that it did not before,
  which in a 100-line paste of all-missing ISBNs is real. Accepted: the
  client's check-digit test already turns typos away without a request, so a
  miss that reaches the network is a real miss.

  Suite 97 to 105. **Merged 2026-08-26** as `42a07d2`.

---

## Ordering, if you want one

`F1` → `F2` → `F8` → `F3` → `F5` → `F6` → `F9` → `F7`.

F1+F2+F8 together turn every failure mode in the corpus into either a correct
result or a message that names the actual problem, and none of the three needs
a schema change, a new endpoint, or a README edit. That is the shippable week.
