# Research prompt — MediaVault ISBN lookup failure + bulk-edit gaps

**Mode: research only. Write no application code.** The single deliverable is a
findings menu I take one item at a time. Do not open a PR, do not edit
`apps/media-vault/` or `functions/api/media-vault/`, do not "fix it while you're
in there." The one file you create is the audit document described at the end.

---

## 1. The report

A user of MediaVault reports that **ISBN lookup and add doesn't work**. The
symptom they describe: they enter an ISBN, it searches, and it comes back
**"No results found for that ISBN"** — including for books that plainly exist.

Take that symptom at face value as the starting point, but do not assume it is
the whole story. "Lookup and add" is one flow to the user: they type an ISBN and
expect an item in their library. Any step of that flow can be the real break.
Characterize what actually fails before proposing what to change.

### Scope of the ISBN workstream

**The reported bug is the core deliverable.** Fixing the not-found failure and
whatever save-path problem sits behind it is what actually matters; everything
else is secondary and must be sorted below it in the menu.

Two adjacent items are explicitly **in scope** as separate findings:

- **Batch ISBN paste-add** — paste a list of ISBNs, look them all up, add them
  in one pass. Pairs naturally with the bulk workstream. Note the shared
  concerns with bulk re-lookup in §6.4 (rate limits, partial failure, how many
  is sane in one run) and cross-reference rather than duplicating the analysis.
- **Check-digit feedback in the UI** — say "that ISBN's check digit is wrong"
  instead of "no results found", so a typo stops being indistinguishable from a
  missing book.

**Out of scope: camera/barcode scanning.** Do not propose it, do not cost it,
do not mention it as a future direction.

## 2. Where you are

- Repo: `C:\Users\natha\Projects\nates-apps` (git repo, remote
  `NateGrey0130/nates-workshop`, Cloudflare Pages auto-deploys `main`). Read the
  repo-root `CLAUDE.md` first — it does not auto-load when a session starts
  outside the repo.
- App: `apps/media-vault/` — `index.html` + `styles.css` + `app.js`. Plain
  HTML/JS/CSS, zero dependencies, no build step.
- API: `functions/api/media-vault/` — `lookup.js`, `items.js`, `migrate.js`,
  `items/bulk.js`, `items/bulk-update.js`, `items/bulk-delete.js`,
  `_lib/common.js`.
- Storage: the shared D1 database `nates-workshop-media`, bound as `DB`, table
  `media_items`. Schema in `db/schema.sql`.
- There is an existing smoke suite for MediaVault (57 checks, registered in
  `.claude/settings.json` and the `ship-pr` skill's always-run list). Read it.
  It tells you what behavior is currently pinned, and therefore which of your
  proposed changes would break a test — that belongs in each finding.

MediaVault was standardized onto D1 on 2026-08-26 (PRs #305 and #306). Before
that, localStorage was the working copy. Some of what looks like a lookup bug
could be residue from that era; some could be genuinely new. Check git log/blame
on the lookup path rather than guessing which.

## 3. Ground truth you must not get wrong

- **The library is not the repo owner's.** All ~3,544 rows belong to
  `lillcreeper@gmail.com`. `nathanrapert@gmail.com` has zero items. You cannot
  reproduce a user-visible bug by looking at Nate's account, and you must not
  conclude "works fine" from an empty library.
- **`MAX_ITEMS` is 5,000** and they sit at ~71% of it. Any bulk proposal has to
  survive selections in the thousands.
- **Local D1 is stale** relative to production. If you query D1 for shape or
  counts, use `--remote`, and read only — never write to production data.
- **TMDB is fixed and is not your problem.** Two stacked TMDB credential faults
  were diagnosed and resolved in PR #306. If TMDB looks broken, you have found a
  regression worth reporting, but do not go re-litigating the old diagnosis.
  ISBN lookup uses **OpenLibrary**, which has no key at all — so "it's the API
  key" cannot be the ISBN answer.
- A Pages **secret change does not take effect until the next deployment**.
  Relevant if any finding proposes a new secret.

## 4. How to verify — code, local dev, and live API probes

Do all three. A finding backed only by reading code is a hypothesis, not a
finding.

1. **Read the code.** `apps/media-vault/app.js` (`handleLookupEnter`,
   `lookupISBN`, `fillBookFields`, and the save path they feed),
   `functions/api/media-vault/lookup.js` (the `isbn` case, `fetchJson`),
   `functions/api/media-vault/items.js` and `_lib/common.js` (`sanitizeItem`,
   `UPSERT_SQL`, the `MAX_ITEMS` guard).
2. **Run it locally.** From the repo root:
   `npx wrangler d1 execute DB --local --file db/schema.sql`, then
   `npx wrangler pages dev --port <a port you pick>`. Drive the real ISBN flow
   against your own local database and watch what the endpoint returns.
   **Do not assume port 8788 is yours** — a dev server on 8788 has previously
   turned out to be a *different worktree*, which makes your edits look like
   they had no effect and someone else's code look like your bug. Pick your own
   port and confirm the page you are hitting is the build you just started.
3. **Probe the upstream API directly.** `curl` OpenLibrary yourself with a
   spread of real ISBNs and compare its raw response to what our endpoint does
   with it. This is the step that separates "OpenLibrary has no data" from "we
   mishandle the data OpenLibrary gives us" — and those two lead to completely
   different fixes.

Do **not** browse production and do **not** touch the Cloudflare dashboard for
this. Read-only `--remote` D1 queries are fine if you need real row shapes.

Build yourself a **test corpus of at least 15 real ISBNs** before concluding
anything, deliberately spanning: ISBN-10 and ISBN-13; an ISBN-10 whose check
digit is `X`; a `979-` prefixed ISBN-13; hyphenated and spaced input; a popular
book and an obscure one; an audiobook edition; a valid-format ISBN that is
genuinely not in OpenLibrary; and a mistyped ISBN that fails its check digit.
Report the pass/fail result per ISBN as a table — that table is the evidence
base for every ISBN finding, and it is also the acceptance test I will use when
a fix lands.

## 5. Hypotheses to test — these are unconfirmed, disprove them

I noticed these while scoping. **They are leads, not conclusions.** Confirm or
kill each one with evidence, and say plainly which ones were wrong. A menu that
just agrees with everything below is a failed piece of research.

- `lookup.js:86` gates on `/^\d{10,13}$/`. That rejects every ISBN-10 whose
  check digit is `X`, and it also accepts 11- and 12-digit strings that are not
  ISBNs at all. `app.js:452` (`handleLookupEnter`) has the *same* regex, so the
  same input may not even route to the ISBN path.
- The endpoint calls `/api/books?bibkeys=ISBN:...&jscmd=data`, then returns
  `{ found: false }` when the key is absent. OpenLibrary's `jscmd=data` view is
  known to be sparser than its other endpoints — an edition can exist at
  `/isbn/{isbn}.json` or via `search.json` while returning nothing here. If so,
  "No results found" is being reported for books OpenLibrary actually has, which
  matches the report exactly. Establish empirically how large that coverage gap
  is across your corpus; the size of the gap decides whether a fallback chain is
  worth it. **Any fallback you propose stays inside OpenLibrary** — additional
  OpenLibrary endpoints are fair game, a second provider such as Google Books is
  not. It would mean a new upstream, likely a new API key and Pages secret, and
  a second metadata shape to normalize. If your evidence says OpenLibrary alone
  genuinely cannot cover these books, report that finding plainly rather than
  proposing the provider — that is a decision to escalate, not to design around.
- The `isbn` branch returns only `title`, `authors`, `genre`, `cover` — no
  `year`, publisher, or page count, unlike `bookOut()` used by the title/author
  modes. Check what `fillBookFields` expects and whether a "successful" lookup
  still leaves the user hand-typing fields.
- ISBN lookup **auto-fills a form; it does not add anything**. Confirm whether
  the user's "and add" complaint is a second, separate failure in the save path
  (`items.js` upsert, `sanitizeItem`, the `MAX_ITEMS` ceiling at 71% full) or
  just their description of the one flow.
- No check-digit validation anywhere, so a typo is indistinguishable from a
  missing book in the UI. Consider whether that alone could explain a user
  reporting a working feature as broken.

Look past this list too. It came from a scoping pass, not a real investigation.

## 6. Second workstream — bulk edit and delete

**Much of this already exists. Your job is a gap analysis, not a design from
scratch.** Read the current implementation before proposing anything:

- Client: `selectMode`, `toggleSelectMode`, `toggleSelect`, `bulkSelectAll`,
  `getFilteredIds`, `updateBulkBar`, `bulkChangeType`, `bulkDelete` in
  `apps/media-vault/app.js`; the checkboxes rendered into both the grid card and
  the list row; the `#bulkBar` element in `index.html`.
- Server: `items/bulk-delete.js` (`{ ids: [] }`), `items/bulk-update.js`
  (`{ ids: [], set: {} }` with a `SETTABLE` whitelist of `type` and `format`),
  `items/bulk.js` (upsert-many, used by CSV import).

The goal: **users can bulk edit and/or delete items from every screen where that
makes sense.** Determine what is genuinely missing against these four asks, and
for each, say whether it is already satisfied, partly satisfied, or absent —
with the line reference that proves it:

1. **Bulk delete** across library/list/search/filtered views.
2. **Bulk edit of common fields** — the UI exposes only `type`; the server
   allows `type` and `format`. Everything else (status, rating, tags/collection,
   owned/wishlist, or whatever the real `media_items` columns are — read the
   schema, do not assume my field names) is unreachable in bulk.
3. **Select-all-matching-filter** — selection that spans the entire current
   filter/search rather than the visible page. Note that `bulkSelectAll` already
   calls `getFilteredIds()` over the whole filtered set while the render
   paginates; work out whether that is genuinely working, or working by accident
   in a way that misleads the user about how many items they just selected.
4. **Bulk re-lookup / enrich** — re-run ISBN/TMDB lookup across a selection to
   backfill missing covers and metadata. Nothing like this exists today. This is
   the one net-new capability, and it is the riskiest: it is a write loop over
   third-party APIs. Address rate limits, partial failure, how many items is
   sane in one run, whether it needs to be resumable, and what it must never
   overwrite.

Then enumerate **which screens lack selection entirely** — the Stats view and
its ranked lists (`renderStats`, `renderRankedList`) are the obvious candidates.
For each screen, state whether bulk actions there would be genuinely useful or
just clutter. "Every screen" is my ask; your job includes telling me where it is
a bad idea and why.

For anything involving thousands of rows, check the actual limits rather than
assuming: D1's bound-parameter ceiling per statement, whether the existing bulk
endpoints chunk their work, what happens at the `MAX_ITEMS` boundary, and
whether a partly-applied bulk operation leaves the client's in-memory `library`
array disagreeing with D1.

**Bulk delete needs a safety net, and the shape is already decided: an undo
toast backed by a client-side restore.** After a bulk delete, the user gets a
short window to put the rows back from the copy the client still holds in
memory. Spec this as its own finding. No schema change, no `deleted_at` column,
no trash table — if you find yourself proposing one, you have the wrong finding.
What I want from you is the hard part: how long the window is, what happens if
the user navigates or reloads inside it, whether restore goes through
`items/bulk.js` upsert-many and whether that faithfully round-trips every column
(including ids — a "restore" that mints new ids is not a restore), and what the
UI does if the restore itself partly fails. Also confirm the in-memory copy is
actually complete at delete time rather than a paginated or filtered subset,
because the whole design collapses if it isn't.

## 7. Deliverable

Write **two files at the repo root** (leave them uncommitted in the working tree
or on a branch — do not open a PR):

1. **`MEDIA-VAULT-ISBN-AUDIT.md`** — the live user-facing bug. Findings
   `F1` … `Fn`, sorted by severity, with the reported not-found failure and its
   save path at the top and the two in-scope adjacent items (§1) below them.
2. **`MEDIA-VAULT-BULK-AUDIT.md`** — the bulk gap analysis. Findings numbered
   `B1` … `Bn` so the two menus can never be confused when I say "take F3".

They are split because the first is a bug I may want to ship this week and the
second is a feature menu I'll work through at leisure; I don't want the feature
items sitting between me and the fix. Each file must stand on its own — if a
bulk finding depends on an ISBN finding (batch paste-add and bulk re-lookup are
the likely pair), state the cross-file dependency explicitly by number in both
places.

Every finding, in either file, gets:

- **What's wrong** — one or two sentences, concrete.
- **Evidence** — file:line, plus the observed behavior that proves it (the API
  response you got, the failing ISBN from your corpus, the test that passes when
  it shouldn't). No finding ships on reasoning alone.
- **Proposed fix** — specific enough that I can hand `F7` back to you as
  "take F7" and you implement it without re-deriving anything.
- **Blast radius** — files touched, whether the 57-check smoke suite breaks,
  whether it needs a schema change (see the `schema-change` skill — a D1 column
  lands in five places), whether it touches the one-time migration path that has
  not yet fired for `lillcreeper@gmail.com`, and whether it can be verified
  before merge given that the data is not ours.
- **Independence** — can this be taken alone, or does it require another F
  first? Say which. I take these one at a time as separate PRs.

Also include, up top **in `MEDIA-VAULT-ISBN-AUDIT.md`**:

- The **ISBN test corpus table** (ISBN → expected → actual → verdict).
- A short **"questions for the reporter"** list — the specific things only the
  user who hit this can answer, phrased so they can be pasted to them as-is.
  Concrete failing ISBNs beat any amount of synthetic testing, and asking for
  three of them costs nothing. Keep it to what genuinely can't be settled from
  the code and your own probes; do not use it as a place to park work.
- A short **"what I disproved"** section: which hypotheses in §5 turned out to
  be wrong, and anything already working that a reasonable person would assume
  was broken.
- A **root-cause statement** for the reported symptom. If several faults stack —
  as they did with TMDB, where the correct-but-incomplete first diagnosis would
  have left a revoked key undiscovered — say so explicitly and rank them. Do not
  stop at the first plausible cause.

Keep findings separable. Do not bundle "fix the regex" and "add a fallback
chain" into one item because they are both about ISBNs; they have different risk
profiles and I want to take them independently.

## 8. Rules

- Research only. No application code, no PR, no production writes.
- Never quote a live credential in any file you write — this repo is public.
- Don't quote counts that move (row totals, item counts) as if they were fixed;
  date them, or pin them to a test.
- If something is genuinely undecidable without production access or without
  `lillcreeper@gmail.com`'s data, say so and name what you would need. Don't
  guess and don't pad the menu to look thorough.
