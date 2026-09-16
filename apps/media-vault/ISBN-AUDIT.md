# MediaVault — ISBN lookup audit

> **Since 2026-09-16 the closed findings live in `ISBN-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

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
a separate file, `BULK-AUDIT.md`, whose findings are numbered
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

- **F1** — The ISBN gate rejects every ISBN-10 ending in `X`, and waves through 11- and 12-digit strings that are not ISBNs — - Taken, 2026-08-26 (PR #312, commit `c001512`): — full text in `ISBN-AUDIT.closed.md` under its own `## F1` heading.

- **F2** — A pasted ISBN with an en dash, a leading `ISBN `, or a trailing period is rejected as "Invalid ISBN" — - Taken, 2026-08-26 (PR #313): as proposed, and the normaliser went further than the finding asked: it now — full text in `ISBN-AUDIT.closed.md` under its own `## F2` heading.

- **F3** — A second lookup in the same modal keeps the previous book's cover, silently — - Taken, 2026-08-26 (PR #313): as proposed, plus `actors` and `producers`, which the finding offered as — full text in `ISBN-AUDIT.closed.md` under its own `## F3` heading.

- **F4** — Nothing distinguishes "you mistyped it" from "we don't have it", and a typo with a valid check digit auto-fills the wrong book — - Closed, 2026-08-26 (PR #313): diagnosis only, no code of its own. Its — full text in `ISBN-AUDIT.closed.md` under its own `## F4` heading.

- **F5** — A successful ISBN lookup fills three fields and adds nothing; the flow the user calls "lookup and add" is six more steps — - Taken, 2026-08-26 (PR #313): the *fuller* option, sharing F9's machinery as the finding advised — an — full text in `ISBN-AUDIT.closed.md` under its own `## F5` heading.

- **F6** — The `isbn` mode drops the cover whenever the *edition* has none, though OpenLibrary has one for the *work* — - Taken, 2026-08-26 (PR #313): as proposed plus a timeout, which was not optional. Written exactly as — full text in `ISBN-AUDIT.closed.md` under its own `## F6` heading.

- **F7** — The ISBN is never stored, so a bad lookup can never be corrected and a re-lookup can never be exact — - Taken, 2026-08-26 (PR #323), when both conditions the hold named came — full text in `ISBN-AUDIT.closed.md` under its own `## F7` heading.

- **F8** — Check-digit feedback in the UI *(§1 adjacent item)* — - Taken, 2026-08-26 (PR #313): as proposed, client-side only, with one correction to the wording. The — full text in `ISBN-AUDIT.closed.md` under its own `## F8` heading.

- **F9** — Batch ISBN paste-add *(§1 adjacent item)* — - Taken, 2026-08-26 (PR #313): as proposed. Client-side loop, capped at 100, cancellable, reusing the `isbn` — full text in `ISBN-AUDIT.closed.md` under its own `## F9` heading.

- **F10** — A transient OpenLibrary failure is indistinguishable from a book OpenLibrary does not have — - Taken, 2026-08-26 (PR #320): as proposed, and the "consider" was taken — full text in `ISBN-AUDIT.closed.md` under its own `## F10` heading.

## Ordering, if you want one

`F1` → `F2` → `F8` → `F3` → `F5` → `F6` → `F9` → `F7`.

F1+F2+F8 together turn every failure mode in the corpus into either a correct
result or a message that names the actual problem, and none of the three needs
a schema change, a new endpoint, or a README edit. That is the shippable week.
