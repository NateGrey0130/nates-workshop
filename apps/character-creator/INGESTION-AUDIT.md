# Character creator — ingestion and tooling audit, 2026-08-26

Read-only audit of **Track E (the PDF import process)** and **Track F (skills
and tooling gaps)** from the 2026-08-26 review brief. Tracks A–D and G are a
different session and are not covered here; see *Not covered* at the end.

Nothing outside this file was changed. No PR was opened.

## Method

Read in full: `.claude/skills/book-survey/SKILL.md` (444 lines),
`.claude/skills/class-import/SKILL.md` (285), `.claude/agents/book-reconcile.md`,
`scripts/ocr-book.py` (210), `scripts/read-columns.py` (97), the offset/field-source
half of `scripts/class-check-lib.mjs` and its CLI in `scripts/class-check.mjs`,
`scripts/catalog-diff.mjs`, the citation section of `scripts/drift-check.mjs`,
`apps/character-creator/import.html` (37) and the upload/session halves of
`import.js` (964), `functions/api/character-creator/_lib/import-engine.js` (520),
`functions/api/character-creator/import/extract.js`,
`functions/api/character-creator/_lib/import-sessions.js`,
`functions/api/_lib/claude-client.js`, `.claude/settings.json`, `CLAUDE.md`,
`SETUP.md` §skills, and the sections of `apps/character-creator/README.md` and
`docs/importing-from-pdfs.md` / `docs/spell-and-psionic-imports.md` reached by
`node scripts/readme-section.mjs`.

Ran against **production** (`node scripts/q.mjs --remote`): the `source_book`
vocabulary of `imported_classes`, `spells`, `psionic_powers`, `skills` and
`gear`; `claude_usage` by endpoint; `import_sessions` / `import_staged` row
counts; `data_script_runs`. Ran three throwaway scripts (in the scratchpad, not
committed) that import the repo's own `class-check-lib.mjs` and walk
`.cache/books/` — one to detect each cached book's printed→PDF offset, one to
resolve every production `source_book` string through `resolveBookSlug`, and one
to check whether every published class's page window is actually inside its
book's cache. Their outputs are quoted inline and are reproducible from the
library functions named.

Not re-measured, taken from the brief as the established baseline: `main` @
`ad6b818`, tree clean, last merged PR #336; character-creator smoke 1,341 checks
/ 89 sections, regression 215 checks, filament-forge 58, pick3cut5 17 + game 23,
media-vault 200, all green; `node scripts/drift-check.mjs --remote` prints
**NO DRIFT** with four pre-existing W.P. citation advisories.

Measured today, and dated because they rot: production holds **109 published
classes**, **333 skills**, **570 spells**, **101 psionic powers**, **902 gear**;
`apps/character-creator/db/` holds **267 `.sql` files**; `.cache/books/` holds
**eight** book caches (`bom cb1 dag fom ju pf potm rue`). This worktree's local
D1 agreed with production on all five catalog counts today — which is not the
usual case and is not a reason to trust it (F13).

**This is a findings menu, not a fix.** Each `F<n>` carries a `Proposal:`
paragraph written to be implemented as stated, scope and posture included. One
PR each, with a `Taken, <date>:` note appended under the finding in that PR.
F1–F5 are one cluster and are cheapest taken in order; each is independently
shippable and each says what it assumes.

## Fixed in this PR

**Nothing.** F9 is unambiguous rot in a live instruction and would qualify under
the audit convention, but this session was asked for findings only. It is one
sentence in `CLAUDE.md` and is written up below so it can be taken as a
one-line PR or folded into whichever finding lands first.

---

## Status, 2026-08-27 — F1 through F6, and F9, taken

Seven PRs, one per finding, each with its `Taken` note under the finding
itself. `main` is at `ecfc8ad`, the merge of PR #344.

| # | PR | what shipped |
|---|---|---|
| F1 | #337 | `scripts/books.json` — 12 books, canonical title + every live spelling + source PDF + last folio + offset. `resolveBookSlug`, `drift-check` and the extraction prompt all read it |
| F2 | #338 | `ocr-book.py` is the one front door: `--probe`, text-layer auto-detection, resume by cache KIND |
| F3 | #339 | the completeness gate measures the BOOK (`printed_pages + page_offset`), not the source PDF's page count |
| F4 | #340 | the offset is read, not re-derived — and answers **per printed page**, because `pf`'s is not constant |
| F5 | #341 | `scripts/source-coverage.mjs` — can what shipped still be traced to a page, and what is stubbed |
| F6 | #344 | a confirmed row's `source_book` is composed PER STAGED ROW — the session's book resolved through `books.json`, plus that row's page range normalised to `p.N-M` |
| F9 | #343 | `CLAUDE.md` stops telling every session the skills do not load, and four smoke checks stop it saying so again |

**This audit's own premises were wrong in nine places, and taking the findings
is what found it.** Every finding taken so far has turned up an error in its
own text. Each is written up under its finding; collected here because five of
them change findings that have not been taken yet:

1. **`pf`'s offset is not constant** (F4). This file says the majority vote
   contradicts `book-survey` §0d and that "none of these books has the
   non-constant offset §0d warns about". §0d is right: +1 for printed 1-16, +2
   for 18-336, 11 contiguous votes against 287. Taking F4 as written would have
   recorded +2, preferred +2, found live detection in perfect agreement, and
   sent every lookup in the first sixteen pages of the most-cited book one page
   early — silently. **F11 depends on this.**
2. **Seven of eight caches have a text layer, not six** (F2). `bom` medians
   5,411 characters a page and was OCR'd anyway.
3. **`fom` and `potm` are no longer partial** (F2, F3). Fixing F2's resume bug
   completed them on the next run: `fom` 73 → 161 pages, `potm` 202 → 210.
   `potm` was short and this file does not say so. `bom` is the one partial
   cache left. **F3's table is stale in three of its five rows.**
4. **`ju`'s cache is built wrong** (F2). 148 of its 162 pages are raw
   `page.get_text()` with the columns welded across the gutter — the corrupting
   read `read-columns.py` exists to prevent. Juicer Uprising is the import that
   shipped two wrong `starting_money` figures. **Not re-cached**; it is 148
   pages of changed text under a completed import.
5. **`Estimate - no published price found` resolved to `pf`** for 104 gear rows
   (F5). The initialism route reads e-n-p-p-f and finds `pf` inside it. F1's
   `_doc` had deliberately left the provenance markers out of the registry,
   which left them to the heuristic, which had an answer. `not_books` names them
   now.
6. **The stub backlog is 4x over-counted** (F5). "21 imported skills at 0/0 that
   are not W.P.s" counts five Hand to Hand rows and eight deliberately
   non-percentile skills whose whole content is a long `note` saying why nothing
   is stored. There are **5** real stubs. "32 gear rows with no price" is 27;
   "1 stub spell" is 0 spells and 1 psionic power.
7. **`import_staged.page_range` is a free-text LABEL, not a range** (F6).
   `import.js:740` prompts for it with the placeholder `pp. 180-181`, so F6's
   literal `source_book + ' p.' + page_range` mints
   `Rifts Ultimate Edition p.pp. 180-181` — which `parseSourcePages` refuses,
   because its `\bp\.?\s*(\d+)` cannot cross the second `p`. Taken as written it
   would have produced rows that LOOK attributed and still score
   `no-page-range`, which is worse than a bare title. **Any finding that
   composes or reads one of these labels has to parse it rather than append
   it.**
8. **Skills is not a session importer** (F6). `import/skills/extract.js` takes
   no `session_id` and no `page_range` and stages nothing; it confirms through
   `skills/confirm.js` with one batch-level `source_book`. F6 named it among
   "the session importers, ..." and F6's fix does not reach it. **Its 105
   page-less rows need their own finding.**
9. **Production `import_sessions` and `import_staged` are EMPTY** (F6, and F7
   says so independently). Every catalog row in production came from a data
   script: `add-burster-psionic-powers.sql` wrote 4 of the 7 traceable psionic
   rows, `add-rue-psionics-batch.sql` wrote the bare title 22 times. So F6's
   "that is the whole explanation for F5's coverage numbers" is wrong — the
   session UI has never written a psionic row to production and cannot be what
   dropped their pages. **Taking F6 moved no number, and no finding should
   reason from "rows the session UI imported" until one is actually run.**

**One number nothing else would have surfaced: 231 spells cite `Rifts Book of
Magic p.71-72`.** Two pages. Whatever that range is, it is not where 231 spells
are printed. Nobody has looked at it yet.

**And the coverage picture as it now stands** (`source-coverage.mjs --remote`,
2026-08-27): classes 107/109 traceable, gear 727/902, skills 127/333, psionic
powers 7/101, and **spells 0 of 570** — 323 with no page range, 231 pointing
into `bom`'s six-page cache, 16 citing nothing. That last row is the largest
number in this audit and was not in it.

Unchanged by F6, and that is the point: it governs rows imported from here on,
not the ones already shipped. **The ledger will read exactly this until a
session import is run against production**, and nothing that has been taken so
far moves it. F10-F17 are the findings that could.

**Three findings were added to the menu on 2026-08-27**, all of them things
taking F6 exposed rather than things the original pass missed:

- **F18** — the skill importer never collected a page range in the first place,
  which is where 105 of the ledger's page-less skill rows come from. F6 does
  not reach it; it is not a session importer.
- **F19** — `buildUpdate`'s `COALESCE` stops a NULL, and the value that erases
  a page range is a bare title, not a NULL.
- **F20** — a stub created by a class import inherits **the class's** page
  range, so four gear rows in production cite the City Rat's page for a poncho,
  a medical bag, a vial and a blood pressure machine — and the coverage ledger
  counts all four as traceable. Skill, spell and psionic stubs get no
  `source_book` at all. **The only finding here where the ledger reports a
  wrong answer as a right one.**


## What book #9 costs today

Walked as the actual steps for a book that is not yet cached — there are five
such PDFs already sitting in `C:\Users\natha\Downloads` (Baalgor Wastelands, PFRPG
Book 02 Old Ones, World Book 04 Africa, `Rifts Main.pdf`, Heroes Unlimited), so
this is not hypothetical.

| # | step | tooling today |
|---|---|---|
| 1 | text layer? | **manual** — `python -c "import pymupdf…"` from the skill; `python -c` is deliberately outside the allowlist, so it prompts every time |
| 2 | build the cache | **manual and unscripted for a text-layer book** — `ocr-book.py` only OCRs (F2) |
| 3 | write `manifest.json` | **manual** — `text_layer` appears in no script; all six text-layer manifests were hand-written (F2) |
| 4 | derive the printed→PDF offset | **manual** — render a page, read the folio (F4) |
| 5 | inventory by structure markers | **manual** — the regexes are pasted out of `SKILL.md` each time |
| 6 | parse the authority table | half scripted — `read-columns.py`, then a per-book parser; the only two that exist are hard-coded to Palladium Fantasy (F15) |
| 7 | diff against the catalog | scripted — `catalog-diff.mjs`, but defaulting to `--local` (F13) |
| 8 | write `SURVEY.md` | **manual, and has never once been done** (F10) |
| 9 | slice a page range out of the PDF | **manual, in an external tool** (F11) |
| 10 | upload, extract, review | in-app, one class per upload; no prompt caching (F12); unmetered (F7) |
| 11 | copy the markdown out to a scratch `.md` | **manual** |
| 12 | `class-check` / `class-check --field-sources` | scripted; the second is opt-in and nothing requires it |
| 13 | paste into `data-script.sql`, double apostrophes, ASCII-ise | **manual** |
| 14 | `d1-apply --local`, then `--remote`; smoke; drift-check; PR | scripted (`ship-pr`) |
| 15 | append the `SURVEY.md` ledger line | **manual, never done** (F10) |

**Steps 1-4 are no longer manual, as of 2026-08-27.** F2 made step 1
`ocr-book.py --probe` (allowlisted), steps 2 and 3 one auto-detecting command
that writes its own manifest, and F1/F4 made step 4 a recorded value read from
`scripts/books.json` rather than a derivation. Step 7 is unchanged (F13), and
steps 5, 8, 9, 11, 13 and 15 are still by hand. **Five unscripted steps, not
nine.** The table above is left as audited.

**And step 10 is no longer unmetered** (F7, PR #347). Every extraction writes a
`claude_usage` row now — `cc-import-class` or `cc-import-<catalog>` — including
the ones that fail after spending the tokens. The row's other half stands: no
prompt caching (F12), one class per upload. **The cost of book #9 is now a
query rather than an estimate**, and the queries are in SETUP.md §Who is
spending the Anthropic key. What it is not yet is a NUMBER: the table still
holds zero import rows, because no import has been run since the metering
landed.

Nine unscripted steps stand between a new PDF and the first extraction, and
steps 9–13 and 15 repeat **per class** — 37 times for Rifts Ultimate Edition, 24
for the Palladium Fantasy main book. The reconciliation pass (`book-survey`
phase 5) is scripted only as a subagent, and that subagent does not load from
`Downloads` (F8).

**Is re-importing from an already-cached book cheaper?** Materially, yes for the
free half — steps 1–7 are done once per book and phases 1–3 routinely halve what
phase 4 has to extract. Materially, **no for the paid half**: every extraction
re-uploads its PDF slice with no cache breakpoint (F12), and the class importer
additionally re-sends two full published class markdown files as format examples
on every single call (`class-store.js` `getExamples`, `limit = 2`). The second
class out of the same book costs the same input tokens as the first.

---

## Findings

Ranked by value, with one exception of numbering: **F16 belongs with the F1–F5
cluster** and is numbered last only because it was found in a second pass. Take
it early.

**F18–F20 were added on 2026-08-27**, after the audit was written, and are at
the end of this section rather than in the ranking. They are gaps the ranking
could not have covered because taking F1–F6 is what exposed them — see the
Status section above. F20 is the one to read first: it is the only finding in
this file where a row traces to the *wrong* page rather than to none, which is
the failure the coverage ledger cannot report.

### F1 — `source_book` is an uncontrolled vocabulary, and three separate mechanisms parse it

**What is true today.** `source_book` is free text. `imported_classes` stores it
inside the markdown frontmatter (there is no column); the four catalog tables
store it as a column. The Palladium Fantasy main book is cited under **five**
distinct spellings across production, measured 2026-08-26:

| spelling | classes | spells+psionics+skills | gear |
|---|---|---|---|
| `Palladium RPG Main Book` | — | — | 312 |
| `Palladium Fantasy RPG` | — | — | 193 |
| `Palladium Fantasy RPG Main Book` | 15 | 27 | — |
| `palladium-fantasy-core` | 24 | 6 | 6 |
| `Palladium Fantasy RPG 2nd Ed.` | — | 3 | — |

Three things depend on parsing that string, and each degrades differently:

1. **`resolveBookSlug`** (`scripts/class-check-lib.mjs:242`) — the only route
   from a row to its cached pages. Run over the whole production vocabulary it
   resolves 11 of 15 spellings. The 312 gear rows citing `Palladium RPG Main
   Book` resolve to **nothing**, and cannot be made to: every word in that title
   is in `GENERIC_TITLE_WORDS`, so the word-overlap route is disabled by design
   and the initialism route needs a `pf` that is not there. Adding `pf`'s missing
   `manifest.json` does not fix it.
2. **The citation check** (`scripts/drift-check.mjs:144`) hard-codes
   `BOOK_SLUGS = { 'Rifts Ultimate Edition': 'rue' }` and selects with
   `source_book LIKE 'Rifts Ultimate Edition%'`. One book of the eight cached.
   It cannot grow with the shelf, and a prefix-LIKE over a five-spelling
   vocabulary would miss rows even if it did.
3. **The extraction prompt disagrees with the data-script template.**
   `functions/api/character-creator/_lib/extraction-prompt.js:39` asks the model
   for `source_book: kebab-case slug of the book (e.g. rifts-core)` — no page
   range. `.claude/skills/class-import/reference/data-script.sql:33` writes
   `source_book: <Source Book> p.NN-NN`. The ` p.N-M` suffix is what
   `--field-sources` takes its window from and is load-bearing, and the prompt
   that fills the field first never mentions it.

**Why it matters.** Every other finding in the F1–F5 cluster needs to know which
book a row means. There is no answer today that is better than a heuristic, and
the heuristic is provably blind on 312 rows.

**Proposal:** add a committed `scripts/books.json` — one entry per book, keyed by
slug, holding `title` (the canonical spelling), `aliases` (every spelling
production actually contains, seeded from the table above), `source_pdf`
(basename, as the manifests already record), `printed_pages` (the book's own
last folio — see F3) and `page_offset` (see F4). `resolveBookSlug` consults the
alias list **first** and falls back to the existing two heuristic routes
unchanged, so nothing that resolves today stops resolving. `drift-check`'s
`BOOK_SLUGS` is replaced by a walk of the registry intersected with the caches
present, and its `LIKE` becomes an `IN` over the aliases. `extraction-prompt.js`
is changed to ask for the canonical title **and** the page range, in the shape
`<Title> p.N-M`, with the registry's titles listed in the prompt as the allowed
values. Posture: **warn, not block** — `class-check` gains a warning when
`source_book` matches no registry title or alias, and does not fail on it, so a
genuinely new book is a warning to add a registry entry rather than a wall. The
registry file gets a line in the README script map (pinned at
`test/smoke.mjs:4998`) and its alias coverage gets a smoke check against a
fixture, not against production. Do **not** rewrite the 586 existing rows in this
PR — aliasing makes them resolvable without touching data, and a normalisation
pass over live rows is a separate decision.

**Taken, 2026-08-27** (PR: `books-registry`). `scripts/books.json` is committed:
twelve books keyed by slug, each with `title`, `aliases`, `source_pdf`,
`printed_pages` and `page_offset`. `resolveBookSlug` consults it first and falls
back to the two heuristics unchanged; over the fifteen live spellings the
resolution went 10 -> 11, and the eleventh is the 312-row `Palladium RPG Main
Book` this finding said could not be made to resolve at all. `class-check` warns
(never fails) on a `source_book` matching no title or alias, and
`extraction-prompt.js` now asks for `<Title> p.N-M` with the registry's titles
listed as the allowed values -- the ` p.N-M` half of that is new too, and is what
`--field-sources` takes its window from. No live row was rewritten. New smoke
section `Book registry` (11 checks) drives the matcher against a fixture, pins
that no two books claim one spelling, and renders the real prompt to prove every
title reaches it; the README script-map pin now covers `.json` as well.

Five departures from the letter of the proposal, all recorded here rather than
waved through:

1. **drift-check does not use an `IN` over the aliases.** D1 rejects the
   predicate outright -- `source_book = ... OR source_book LIKE ...` over pf's
   five spellings comes back `LIKE or GLOB pattern too complex: SQLITE_ERROR
   [code: 7500]`. It now reads the three tables whole (three queries, ~1,000
   rows) and buckets them with `registryBookSlug`, which is strictly better than
   the proposal: the citation check and `--field-sources` decide which book a row
   belongs to by calling the same function, not by two spellings of one
   intention. `BOOK_SLUGS` is gone; the check now covers every cached book the
   registry knows. 340 rows checked became 431.
2. **Twelve entries, not the eight cached books.** `rifts-core`, `triax`,
   `new-west` and `rifts-skill-list` are cited in production and cached nowhere;
   without entries the new warning would fire on rows that are perfectly
   correct. They resolve to null exactly as before -- being known vocabulary and
   being readable are different questions, which is why a registry hit whose
   cache is absent returns null rather than falling through to the heuristics.
   The heuristics answer "which of these caches looks like this title"; once the
   book is known and simply not cached, that question has a wrong answer
   available and no right one.
3. **`scripts/books-lib.mjs` came with it** -- the loader, because three callers
   needed the read and `class-check-lib.mjs` stays free of file I/O. The matching
   itself (`normalizeBookTitle`, `registryBookSlug`) is in `class-check-lib.mjs`,
   so the smoke test drives it against a fixture rather than against whatever
   this machine's database happens to hold.
4. **The Worker imports the JSON** (`import BOOKS from '.../books.json' with {
   type: 'json' }`). Verified with `npx wrangler pages functions build`: esbuild
   inlines the registry into the bundle. The attribute is not decoration --
   Node refuses a bare JSON import, and the smoke test renders this prompt.
5. **One fix in passing:** drift-check's `if (!existsSync(manifestPath))
   continue` was silent, and `pf` -- the most-cited book in the database -- is
   exactly the cache with no manifest (F2). It now prints why it skipped.

Measured after: smoke 1,352 checks / 90 sections, regression 215, filament-forge
58, pick3cut5 17 + game 23, media-vault 200, all green. `drift-check --remote`
prints **NO DRIFT** with **eight** advisories, up from four: the four new ones
are the potm language skills, and they are the same false-positive class as the
four W.P. rows -- the catalog writes `Language: Old Norse`, the book prints
`Old Norse`. All four were confirmed present in the potm cache by hand. Nothing
was silenced.

`printed_pages` and `page_offset` are seeded but **nothing reads them yet** --
F3 and F4 are the consumers. The values were measured, not assumed: offsets by
`detectPageOffset` over each cache, `printed_pages` from the last folio the
pages themselves print. Three carry a `note` saying why the number is not simply
read off the cache (`bom`'s cache is six pages; `fom` and `potm` stop short of
their source PDF's end). Also worth knowing for F3: **`potm`'s cache is short
too** -- 202 of the PDF's 210 pages -- which this finding did not list. The
missing tail is index, not text.

### F2 — there is no cache builder for a text-layer book, and six of the eight caches were built by code that no longer exists

**What is true today.** `scripts/ocr-book.py` is the only script that writes
`.cache/books/<slug>/`, and it always renders pages and runs Tesseract. Six of
the eight cached books have a text layer and were **not** built by it: their
manifests carry `"text_layer": true`, and the string `text_layer` appears in no
`.py`, `.mjs`, `.js` or `.md` file in the repo. `pf` — the single most-cited book
in the database, 339 cached pages — has **no `manifest.json` at all**.

`book-survey` step 0 tells a session to probe for a text layer and step 0b tells
it what to do if the answer is "scan". If the answer is "text layer", the skill
says what to *read* (`read-columns.py`, against the PDF) but nothing about how
the page-addressed cache that `--field-sources` and `drift-check` both require
comes to exist. It exists because six previous sessions each wrote a throwaway
loop, and none of them is in the repo.

**Why it matters.** This is manual step 2 and 3 of book #9 — the single largest
unscripted gap in the pipeline, and the one that has to be re-derived from
scratch every time, differently, by a session that does not know it is
re-deriving anything.

**Proposal:** turn `ocr-book.py` into the one front door for caching a book.
Add a `--probe` mode that prints the per-page text-length sample `book-survey`
step 0 asks for and exits — so the first command of every new book is an
allowlistable script rather than a bare `python -c` (add
`Bash(python scripts/ocr-book.py *)` to `.claude/settings.json`; it writes only
into gitignored `.cache/`). Auto-detect the text layer on a normal run and take
the cheap path when there is one: `page.get_text()` through the same
gap-bucketing `read-columns.py` uses, written to the same `txt/pNNN.txt` layout,
with no `png/`, no `tsv/` and no Tesseract, and a manifest recording
`"text_layer": true` plus the fields F3 and F4 add. `--force-ocr` overrides
detection. Posture: **one command, no flags required** —
`python scripts/ocr-book.py "<pdf>" --slug <slug>` must do the right thing for
either kind of book, because the failure this prevents is a session inventing a
seventh private caching loop. Backfill `pf`'s missing manifest in the same PR.
Update the README script map entry for `ocr-book.py` (pinned at
`test/smoke.mjs:4998`) and the `book-survey` steps 0/0b to name the one command.

**And fix the re-cache footgun in the same PR, because F3's backfill invites
it.** `ocr-book.py:173` decides a page is already cached with
`if os.path.exists(txt) and os.path.exists(tsv)` — it needs **both**. The six
text-layer caches have no `tsv/` directory at all: `pf` 339 txt / 0 tsv, `potm`
202/0, `cb1` 200/0, `dag` 240/0, `ju` 162/0, `fom` 73/0. So running today's
`ocr-book.py` against any of those six slugs — the obvious thing to try when
topping up the truncated `fom`, or when a session does not know that cache was
text-layer-built — resumes nothing, re-renders every page, and **overwrites 339
pages of clean text-layer extraction with 300 dpi Tesseract output**. Silently,
and for the most-cited book in the database. The resume test must key off what
the manifest says the cache is: `txt` alone for a text-layer cache, `txt` and
`tsv` for an OCR one.

**Taken, 2026-08-27** (PR: `cache-any-book`). `ocr-book.py` is the one front
door. `--probe` samples twenty pages spread through the book, prints each
page's character count and says TEXT LAYER or SCAN, writing nothing; it is
allowlisted (`Bash(python scripts/ocr-book.py *)`), so the first command aimed
at every new book no longer prompts. A normal run auto-detects and takes the
cheap path when there is one — `read-columns.read`, imported and not copied,
into the same `txt/pNNN.txt` layout, no `png/`, no `tsv/`, no Tesseract — and
`--force-ocr` overrides. The resume test keys off what the manifest says the
cache IS: `txt` alone for a text layer, `txt` and `tsv` for OCR. `pf`'s manifest
is backfilled. README script map, `book-survey` steps 0 and 0b, and the
`read-columns.py` map entry all updated.

**The reconstruction was verified against the six caches it replaces**, not
just run. Rebuilt from their source PDFs and compared page for page:

| cache | result |
|---|---|
| `potm` `cb1` `dag` `fom` | identical, every page |
| `pf` | 271 of 339 identical; the other 68 hold the SAME lines in a different block order. Zero content differences. |
| `ju` | **148 of 162 pages differ substantively** |

`ju`'s cache is raw `page.get_text()` — columns welded across the gutter, a
stat block's lines interleaved with its neighbour's. That is precisely the
corrupting read `read-columns.py` exists to prevent, and Juicer Uprising is the
import that shipped two wrong `starting_money` figures. **Not re-cached in this
PR** — it is 148 pages of changed text under a completed import, and re-reading
the fifteen Juicer classes against a corrected cache is its own decision. Worth
taking as a follow-up.

The old loops also wrote ASCII: every `(R)` and `(TM)` in those six caches is a
replacement character. The new path writes UTF-8, which is why the four
"identical" rows above are identical modulo that damage and a trailing blank
line.

**Four departures, and two repairs that fell out of the resume fix:**

1. **The audit says six of eight caches have a text layer. It is seven.** `bom`
   medians 5,411 characters a page and was OCR'd anyway. That makes it the
   exact case the kind guard exists for: a plain re-run would now take the
   text-layer path and destroy an OCR cache. Switching a cache's kind needs
   `--force` and prints what would be lost. Run against `bom` today it refuses,
   by name.
2. **The manifest gained F3's and F4's fields**, as the proposal says —
   `cached_pages`, `cached_range`, `printed_pages`, `page_offset`, alongside
   `text_layer`. **Nothing reads them yet.** `drift-check`'s completeness gate
   still compares against `pages`, which is F3's change to make. The offsets are
   derived by `detect_folios`, a deliberate line-for-line twin of
   `detectPageOffset` in `class-check-lib.mjs`, and every book it derived agrees
   with the value `scripts/books.json` carries by hand from F1.
3. **`--probe` prints twenty spread pages, not `range(20,30)`.** Front matter is
   sparse in both kinds of book; a contiguous early sample can read a text layer
   as a scan.
4. **The text-layer path does not run the substitution table.** Those repairs
   are OCR damage. A text layer makes typesetting damage instead, and the
   `18.000`->`18000` rule near real decimals would be a cost with no gain.

And two caches repaired themselves the moment resume worked, which is the
clearest evidence the footgun was real:

- **`fom` completed**: 73 cached of a 161-page PDF -> **161**. It read the 88
  missing pages and left the 73 existing ones untouched.
- **`potm` completed**: 202 -> **210**.

Both notes in `scripts/books.json` were trued up to say so, and `bom`'s gained
the text-layer fact. F3 should re-read its own numbers for those two before
being scoped: `fom` is no longer truncated, and `potm` — which F3 does not list
as partial — no longer is either.

Backfilling `pf`'s manifest also **unblocked 36 rows** in drift-check's citation
check, which had been skipping the most-cited book in the database silently:
431 rows checked -> **467**, and the `pf` skip line is gone.

Measured after: smoke 1,352 checks / 90 sections, regression 215,
filament-forge 58, pick3cut5 17 + game 23, media-vault 200, all green.
`drift-check --remote` prints **NO DRIFT** with nine advisories, up from eight —
the new one is `Language: Native Tongue` claiming the Palladium Fantasy main
book, the same `Language: ` prefix false positive as the other four, now visible
only because pf is finally being checked at all. `class-check --field-sources`
re-verified end to end against a `pf` class (offset +2, 287 votes) after the
manifest landed.


### F3 — a truncated cache is indistinguishable from a complete one, and the guard that exists is fooled by the worse case

**What is true today.** Two of the eight caches are partial, and they fail in
opposite directions:

- **`bom`** holds `p090`–`p095` — **six pages of a 360-page book**, and its
  manifest says `"pages": 360`. Production carries **408** catalog rows and one
  class citing the Book of Magic. The one class, `stone-master`, cites
  `p.223-228`; those pages are not in the cache and never were.
- **`fom`** holds `p001`–`p073` and its manifest says `"pages": 73`. The source
  PDF is itself a truncated copy of a 176-page book — `p073.txt` ends mid-word,
  mid-class ("*In an emergency they may be*"). Nothing in the cache records that
  the book continues.

`drift-check.mjs:157-165` already has a completeness gate, added after a partial
cache accused four gear rows. It compares the cached file count against
`manifest.pages`. That gate correctly skips `bom` (6/360). It would **pass**
`fom` (73/73) and read half a book as though it were all of it, because
`manifest.pages` is `doc.page_count` of whatever PDF was handed over — a property
of the file, not of the book.

**Why it matters.** The brief's question was whether anything warns a future
session that a cache is incomplete, "or does it just return nothing and look
like an absence". Today: `bom` looks like an absence, `fom` looks like a
complete book, and 408 rows sit behind the first one.

**Proposal:** add two fields to the manifest and make the gate read the right
one. `cached_pages` — how many `pNNN.txt` files this cache actually holds, and
which range. `printed_pages` — the book's own last printed folio, which
`ocr-book.py` can read off the final cached page the same way `detectPageOffset`
reads the rest, and which the F1 registry carries as the authority when the cache
is too short to see it. `drift-check`'s completeness gate compares
`cached_pages` against `printed_pages + page_offset` rather than against
`manifest.pages`, and its skip line names both numbers. Posture: **skip, not
fail** — an incomplete cache must keep silencing the citation check, exactly as
today; the change is only that `fom` starts being skipped and the reason is
printed. Backfill both manifests by hand in the same PR (`bom`: 6 cached of 360;
`fom`: 73 cached of 176) so the two known-partial caches announce themselves
immediately, and note both in the F1 registry. Depends on F1 only for
`printed_pages` of a book too truncated to read its own last folio; otherwise
independent.

**Taken, 2026-08-27** (PR: `cache-completeness`). The gate now compares against
the book's own length instead of the source PDF's. `cacheCoverage` in
`scripts/books-lib.mjs` is the pure decision — cached pages vs
`printed_pages + page_offset` — and `drift-check`'s citation check calls it.
Posture unchanged: **skip, not fail**, and a missing or short cache is still not
drift. What changed is that the skip line names both numbers and where they came
from:

```
citations:    bom cache incomplete (6 of 353 pages, printed 352 + offset 1,
              from scripts/books.json) — skipped
```

**Read this finding's premises before scoping anything on top of it — two of
them moved under F2.** F2 fixed the resume test, and two of the caches this
finding calls partial repaired themselves on the next run:

| this finding says | true on 2026-08-27 |
|---|---|
| `fom` holds p001-p073, manifest `"pages": 73` | **complete, 161 of 161.** The 88 missing pages were read off the source PDF |
| `bom` holds p090-p095 of 360 | still 6 pages; still skipped, now with a reason |
| the source PDF is "a truncated copy of a 176-page book" | the PDF on hand is **161 pages**, and the book's last folio is 159 |
| two of the eight caches are partial | **one** is. `potm` was also short (202 of 210), which this finding does not list, and is now complete too |
| `cached_pages` / `printed_pages` need adding to the manifest | F2 added them, along with `cached_range` and `page_offset` |

So the work left here was the consumer, and it is done.

**One departure, and it is the load-bearing one. The registry OUTRANKS the
manifest**, where the proposal reads as though the manifest is primary and the
registry a fallback "when the cache is too short to see" its own folio. It has
to be the other way round, because `ocr-book.py` derives `printed_pages` by
reading the last folio it can SEE — so a truncated cache derives the
truncation's last folio and passes itself. `fom` as it actually stood is the
proof: 73 files, and a manifest derived from it would say printed 72, offset +1,
needs 73. **73 >= 73 passes**, and the exact bug this finding is about survives
into the new field. A number that comes from the cache cannot judge the cache.
`scripts/books.json` is a human statement about the BOOK, so it wins whenever it
has one; the manifest is the fallback for a book the registry does not carry,
and a cross-check for one it does. Every cached book agrees with its registry
entry today.

Two smaller notes. The comparison is a file COUNT against a page NUMBER, which
is exact for a gapless cache starting at p001 and conservative for a gappy one
(`bom` holds p090-p095: six files, last number 95) — it can only under-claim
completeness, which is the safe direction for a gate whose failure mode is
believing half a book. And `bom`'s manifest was backfilled **by hand**, in the
shape `write_manifest` produces, because F2's kind guard now refuses to re-run
that cache: `bom` has a text layer and was OCR'd anyway, so rebuilding it would
destroy the six pages it was kept for.

Pinned, because the live caches can no longer demonstrate the bug: six checks in
the smoke test's `Book registry` section drive `cacheCoverage` against `fom`'s
real historical numbers — one asserts the OLD rule passed it, the next that this
one does not — plus the self-judging-manifest case, `bom`, rue's unnumbered back
matter, and the fallback when no folio is known anywhere.

Trued up, since both sentences became false: `write_manifest`'s docstring in
`ocr-book.py` said "nothing consumes the last three yet ... drift-check's
completeness gate still compares against `pages`", and `books.json`'s own `_doc`
did not say these two fields were load-bearing.

Measured after: smoke **1,359 checks / 90 sections** (up 7), regression 215,
filament-forge 58, pick3cut5 17 + game 23, media-vault 200, all green.
`drift-check --remote` prints **NO DRIFT**, 467 rows checked and nine advisories
— identical to before, which is the point: the gate got correct without changing
what it consults.


### F4 — the printed→PDF offset is recorded nowhere and re-derived at every use

**What is true today.** `book-survey` §0d is 30 lines on how badly this goes
wrong, and it ends with "verify the offset next to the page you actually want".
Nothing records the answer. The one mechanical detector,
`detectPageOffset` (`scripts/class-check-lib.mjs:275`), lives inside
`class-check --field-sources` and is reachable no other way — not from the
skill, not from a command, not from the manifest.

Run over all eight caches today it gives a clean, unanimous answer for seven of
them:

| slug | offset | votes | cached |
|---|---|---|---|
| cb1 | +1 | 77/77 | 200 |
| dag | +1 | 204/204 | 240 |
| fom | +1 | 51/52 | 73 |
| ju | +1 | 135/135 | 162 |
| potm | +1 | 174/174 | 202 |
| pf | **+2** | 287/298 | 339 |
| rue | **+3** | 29/31 | 382 |
| bom | **none** | 0 | 6 |

First-half and second-half detection agree for all seven, so none of these books
has the non-constant offset §0d warns about. `bom` — the one with 408 rows behind
it — cannot be detected at all, and `--field-sources` silently falls back to
offset 0 for it.

Note this measurement corrects a number in a live instruction:
`EFFICIENCY-AUDIT.md` F7's *Taken* note records "pf +2, rue +3" as the offsets it
found, which still holds, but `book-survey` §0d's worked example says Palladium
Fantasy is "+1 before that point and +2 after it" — over the whole cache the vote
is 287 to a scattered 11 for +2, first half and second half both.

**Why it matters.** The offset is a per-book constant that is free to compute
once and costs a wrong page read every time it is guessed. It is currently
guessed by a human at survey time, discarded, and re-guessed by a majority vote
at check time.

**Proposal:** record `page_offset` in the manifest at cache time (F2 writes it;
`ocr-book.py` runs `detectPageOffset`'s logic over the pages it just wrote) and
in the F1 registry as the durable copy. `class-check --field-sources` prefers the
recorded value over live detection, keeps `--offset` as the override, and
**warns when live detection disagrees with the recorded value by more than
zero** — that disagreement is the signature of a re-cached book, a duplicated
page, or the non-constant offset §0d describes, and it is the mechanical check
the brief asked for. Where detection yields nothing (`bom`), the recorded value
is the only one and `--field-sources` says so rather than quietly using 0.
Posture: **warn-not-block**, and **advisory on disagreement** — a mismatch prints
and does not change the exit code, because the recorded value can be right and
the cache newly partial. Rewrite `book-survey` §0d around "read it from the
manifest; verify only when the manifest has none", keeping the two-tools-disagree
table (`read-columns.py` is 1-based, `pymupdf` is 0-based), which stays true.

**Taken, 2026-08-27** (PR: `recorded-page-offset`). `class-check --field-sources`
reads the offset instead of re-deriving it, in this order — and prints which it
used, on the FIELD SOURCES line:

```
--offset            the human overrides everything
scripts/books.json  the durable, hand-checked copy, PER PRINTED PAGE
the manifest        what ocr-book.py measured when it built this cache
live detection      majority vote, for a book the registry does not carry
0                   and it SAYS so, rather than quietly using it
```

The registry outranks the manifest for the reason F3 gives, and because it is
the only one of the three that can express `pf`. Disagreement is **advisory**
and never touches the exit code. `bom` — 408 rows behind it, no folio anywhere
in its six pages — now uses the registry's `+1` and says nothing in the cache
can confirm it, instead of silently using 0.

**Half of this was already done.** F2 writes `page_offset` into the manifest at
cache time and F1 records it in the registry, so the proposal's first sentence
was satisfied before this PR opened. What was left was the consumer, the
advisory, and §0d.

---

**THIS FINDING'S OWN CORRECTION IS WRONG, AND IT MATTERS.** The note above says
`book-survey` §0d's worked example — Palladium Fantasy at "+1 before that point
and +2 after it" — is contradicted by a 287-to-11 vote for +2, and concludes
that **"none of these books has the non-constant offset §0d warns about."**

§0d is right. Those 11 votes are not scatter:

| offset | votes | printed pages |
|---|---|---|
| **+1** | 11 | **1-15**, contiguous |
| **+2** | 287 | **18-336**, contiguous |

An extra page sits at cache `p018`/`p019` (`p019` holds `p018`'s 107 lines plus
a *Throwing Objects* table, 153 in all). Cache `p016` prints folio 15, cache
`p020` prints folio 18. So the offset genuinely is +1 for the head of the book
and +2 for the rest, exactly as §0d says, and a majority vote **cannot see it**
because the minority region is 11 pages against 287.

That is not a footnote — it breaks the proposal as written. "Record
`page_offset` … prefer the recorded value … warn when live detection disagrees
by more than zero" would record +2 for `pf`, prefer +2, and find live detection
in perfect agreement at +2 — so **no warning fires**, and every lookup in the
first sixteen pages of the most-cited book in the database lands one page early,
silently. §0d's own example, the Attribute Bonus Chart at printed 16, is inside
that region.

**So the registry answers per printed page.** One optional key:

```json
"page_offset": 2,
"page_offset_exceptions": [ { "printed_through": 16, "offset": 1 } ]
```

First match wins; everything past the last exception falls through to
`page_offset`. `pf` is the only book that has one. Printed 17 is deliberately
left to the +2 rule, because that lands on `p019`, the fuller of the two pages.

**And the split is found mechanically now, not by a human noticing.**
`detectPageOffsetRegions` reports the contiguous runs a cache shows; a run needs
three agreeing pages to count, which drops `fom`'s single page voting -3 and
`rue`'s two voting +33 and +38 — strays in front matter, not paginations — and
re-joins the runs those strays split. `--field-sources` reports multiple regions
only when `scripts/books.json` does not already resolve each of them, so `pf`
prints nothing on a normal run rather than crying wolf on every class. A smoke
check walks every cache on the machine and fails if any region the pages show is
one the registry cannot resolve.

Run over all eight caches after F2's repairs, which moved two rows of this
finding's table (`fom` 51/52 over 73 pages became 113/114 over 161; `potm`
174/174 over 202 became 181/181 over 210):

| slug | regions | recorded |
|---|---|---|
| cb1 dag fom ju potm rue | one, constant | matches |
| **pf** | **two: +1 printed 1-15, +2 printed 18-336** | exception recorded |
| bom | none — no folio survives its six pages | registry `+1`, unconfirmable, and it says so |

---

Trued up, since this change falsifies both: the README's `--field-sources`
paragraph said the offset "is read off the pages themselves, by majority vote",
and `EFFICIENCY-AUDIT.md` F7's *Taken* note said the mode "detects it rather
than trusting `p.N`" and quoted "pf +2" flat. F7's note carries a **Superseded**
paragraph rather than a rewrite — it is a record of what shipped in August, and
editing it would lose that.

§0d is rebuilt around "read it from the registry; derive only if there is none",
keeping the two-tools-disagree table (`read-columns.py` 1-based, `pymupdf`
0-based) and the zero-offset warning, both of which stay true.

Measured after: smoke **1,367 checks / 90 sections** (up 8), regression 215,
filament-forge 58, pick3cut5 17 + game 23, media-vault 200, all green.
`drift-check --remote` prints **NO DRIFT**, 467 rows, nine advisories —
unchanged, as it should be; this PR does not touch that check. No live row cites
`pf` printed ≤ 17 today, so nothing that has shipped was read through the wrong
offset — the exception is a trap closed before it was sprung, not a repair.


### F5 — nothing checks that what shipped can still be traced back to a cached page

**What is true today.** `--field-sources` can trace a class **if** you run it,
**if** its `source_book` resolves, and **if** its page window is in the cache.
Nothing asks that question across the corpus, so nobody knows the answer. Walked
over all 109 published classes today (resolver and offset logic taken from
`class-check-lib.mjs`, offsets as in F4):

- **107 of 109** have their whole page window inside their book's cache.
- **`stone-master`** — `Rifts Book of Magic p.223-228`, cache holds p090–p095.
  Untraceable, and the book behind it is the 408-row one.
- **`dragon-hatchling`** — `Rifts RPG (original core book) p.98-101`. Resolves to
  no cached book at all, though `Rifts Main.pdf` is on disk uncached.
- Zero classes are missing the ` p.N-M` suffix, which is better than the prompt
  (F1) deserves.

There is **no equivalent for the catalog at all**, and most catalog rows could
not use one if it existed. Page-suffix coverage measured today: gear 727/902
(81%), spells 231/570 (41%), skills 127/333 (38%), **psionic powers 7/101 (7%)**.

**Why it matters.** F7 of the efficiency audit bought a page-break guard for
classes and it works. What was never bought is the check that the guard *can*
still run — which is the thing that quietly stops being true as books are cached
partially, re-sliced, or cited under a new spelling.

**Proposal:** add `scripts/source-coverage.mjs`, offline, reading production or
`--local`. For every published class and every catalog row carrying a
`source_book`, resolve the book through F1's registry, parse the page range,
and report four buckets: traceable, **book unresolved**, **no page range**,
**window outside the cache**. Print counts per book and the offending
`class_id`/name lists, and exit 0 always. Posture: **advisory, log-not-cap** —
it must never gate a merge, because a cache is gitignored and a clean clone has
none; on a machine with no `.cache/books` it prints "no caches" and exits 0, the
same way `drift-check`'s citation section does. **Have it print the stub backlog
in the same run** — the importers create stub rows by design and nothing has
ever reported how many are outstanding. Measured today: **5** gear rows whose
description starts `STUB`, **21** imported skills at 0/0 that are not W.P.s
(a class granting one of those gives a character 0%), **1** stub spell, and
**32** gear rows with no price. Those are small numbers and that is the point —
they are worth a ledger line now, before a shelf of books makes them a project.
Add a smoke check that pins the
*bucketing logic* against a fixture (not against the live cache), and add the
script to the README map. Once it exists, a book's `SURVEY.md` ledger (F10) can
quote its coverage line as the answer to "what remains".

**Taken, 2026-08-27** (PR: `source-coverage`). `scripts/source-coverage.mjs`,
offline apart from one read-only D1 pass, `--remote` by default because the
question is about what SHIPPED. It **always exits 0** and never gates a merge:
the caches are gitignored, so a clean clone traces nothing and that is not a
defect. `source-coverage-lib.mjs` is its pure half — one `source_book` string
in, one bucket out — so the smoke test pins the bucketing against a fixture and
never against live caches. Both are in the README script map and the allowlist.

Measured 2026-08-27, `--remote`:

```
COVERAGE        traceable  not-a-book  no-source-book  no-page-range  unknown-book  not-cached  outside-cache
  classes       107        0           0               0              0             1           1              of 109
  gear          727        133         1               40             0             1           0              of 902
  skills        127        0           52              105            0             49          0              of 333
  spells          0        0           16              323            0             0           231            of 570
  psionic_powers  7        0           12              82             0             0           0              of 101
```

**Not one of 570 spells can be traced to a page.** 323 carry no page range, 231
cite the Book of Magic whose cache is six pages, 16 cite nothing. That is the
single largest number in this report and it was not in the finding.

**Seven buckets, not four.** Two splits and one addition, each because the
action differs:

- **`not-cached` split from `unknown-book`.** `dragon-hatchling` cites a book
  the registry knows and this machine has not cached — the fix is one
  `ocr-book.py` run, not an edit to any row. Lumped in with genuinely unknown
  spellings, that is invisible. 51 rows are in it: 48 skills citing the Rifts
  Skill List, plus `dragon-hatchling`, one Triax gear row and one New West
  skill. Every one of those four PDFs' worth is a caching job, not a data job.
- **`not-a-book` is new, and it found a live defect.** `Estimate - no published
  price found` **resolved to `pf`** for 104 gear rows: the initialism route
  reads e-n-p-p-f and finds `pf` inside it. F1's `_doc` says that marker and
  `Web reference (not book-verified)` are deliberately not registry entries —
  which left them to the heuristic, which had an answer. A `not_books` list in
  `scripts/books.json` now names both, `resolveBookSlug` returns null for them
  before either route, and `pf`'s attributed rows went **146 → 42**. Without
  this the report would have opened with 133 false gaps.

**The stub backlog signature had to change, and the finding's number is an
over-count by 4x.** F5 records "21 imported skills at 0/0 that are not W.P.s (a
class granting one of those gives a character 0%)". Of those 21: five are Hand
to Hand rows, and eight are deliberately-modelled non-percentile skills carrying
long `note` text that says exactly why nothing is stored — Fencing, Combat
Driving, Robot Combat: Basic, Robot Combat Elite: Glitter Boy, Sniper, Hunting,
Trick Riding, Robot Combat Elite. Those are finished rows, not stubs. A stub is
a row an importer created and **nobody touched since**: no base %, no bonuses,
no note. There are **5**.

```
BACKLOG       rows an importer created and nobody finished
  gear stubs             5   description still says STUB — created by class import
  gear with no price    27   no cost and no cost_note to explain it
  skill stubs            5   created by an import and never given a base %, a bonus or a note
  spell stubs            0   level 0 and 0 P.P.E.
  psionic stubs          1   0 I.S.P.
```

Two other numbers in the finding moved: "32 gear rows with no price" is **27**
once the five carrying a `cost_note` that explains the absence are excluded, and
"1 stub spell" is **0 spells and 1 psionic power** (Meditation).

**The rest of the finding's measurements hold.** 107 of 109 classes traceable,
`stone-master` and `dragon-hatchling` the two that are not, zero classes missing
a page suffix. The page-suffix percentages are unchanged within a row or two.

Offenders are grouped **by book and cause** rather than listed: 232 of the
untraceable rows are one book with one cause, and printing 231 near-identical
`bom` lines would bury `stone-master`, which is the one that is different. Three
examples per cause, `--offenders` for the whole list.

One thing worth its own line for whoever takes F6 or F10: **231 spells cite
`Rifts Book of Magic p.71-72`** — two pages. Whatever that range is, it is not
where 231 spells are printed. It is not this PR's to fix, and nothing else would
have surfaced it.

Measured after: smoke **1,380 checks / 90 sections** (up 13), regression 215,
filament-forge 58, pick3cut5 17 + game 23, media-vault 200, all green.
`drift-check --remote` prints **NO DRIFT**, unchanged. `source-coverage` runs
clean against both `--remote` and `--local`.


### F6 — the catalog importers already know the page range and throw it away

**What is true today.** The session importers take `page_range` per extraction
(`import/spells/extract.js:2`, `gear/extract.js:2`, …), pass it to
`stageRows`, and persist it on `import_staged.page_range`
(`_lib/import-sessions.js:66,90`). At confirm time
`_lib/session-import.js:121` hands `applyDecisions` `sourceBook:
session.source_book` — the **session-level** book name only — and
`buildInsert`/`buildUpdate` (`import-engine.js:491,516`) write exactly that.
The page range is dropped one function call from the column it belongs in.

That is the whole explanation for F5's coverage numbers: psionic powers, which
were imported almost entirely through the session UI, carry a page on 7 of 101
rows; gear, most of which arrived through hand-written data scripts, carries one
on 727 of 902.

**Why it matters.** It is the precondition for ever extending the `--field-sources`
guard past classes, it is a one-expression change, and every row imported between
now and then is a row that can never be traced.

**Proposal:** in `session-import.js`, compose the row's `source_book` as
`session.source_book + ' p.' + staged.page_range` when the staged row has a page
range, and as `session.source_book` alone when it does not — per staged row, not
per session, since one session covers many page ranges. `applyDecisions` takes
the source book per decision rather than once for the batch. Leave `buildUpdate`'s
`COALESCE` semantics exactly as they are: a re-import that has no page range must
not blank one an earlier row already carries. Posture: **new rows only** — do not
backfill the existing 94 page-less psionic rows in this PR; that is a data
question about which extraction produced which row, and F5's report is the right
place to size it first. Pin the composition in the smoke test.

**Adjusted 2026-08-27, after F1 and F5.** Two things moved. The sizing tool
this proposal defers to now exists: `node scripts/source-coverage.mjs --remote`
reports the page-less rows per catalog and per book, so "how big is the
backfill" is one command rather than an open question. And the composed value
should be **the registry's canonical title** plus the page range, not
`session.source_book` verbatim — F1 made `scripts/books.json` the vocabulary
and the extraction prompt already offers those titles, so a session whose
`source_book` is a fifth spelling would otherwise mint rows in it. Resolve
`session.source_book` through `registryBookSlug` and write the entry's
`title`; fall back to the session's own string when it resolves to nothing,
and never compose a page range onto a `not_books` marker.

**Taken, 2026-08-27 (PR #344).** `_lib/source-book.js` composes the value;
`session-import.js` calls it per staged row; `applyDecisions` takes the book
per decision and keeps the batch value as the fallback `skills/confirm.js`
still passes. `buildUpdate`'s `COALESCE` is untouched. Pinned by a new
*Import provenance* smoke section (9 checks). Three of this finding's own
statements moved on contact:

1. **The page range is a free-text LABEL, and `' p.' + page_range` would have
   produced a value nothing can read.** `import.js:740` prompts for it with the
   placeholder `pp. 180-181`, so the literal composition mints
   `Rifts Ultimate Edition p.pp. 180-181` — and `parseSourcePages` refuses that
   string, because its `\bp\.?\s*(\d+)` cannot cross the second `p`. The rows
   would have looked attributed and still scored `no-page-range` in
   `source-coverage`, which is strictly worse than the bare title: a row that
   reports itself as missing gets fixed. The label is parsed and re-emitted in
   the canonical shape instead, and the smoke test pins the round trip through
   `parseSourcePages` and `registryBookSlug` rather than pinning the string.
2. **Skills is not a session importer**, so the finding's "…" does not reach
   it. `import/skills/extract.js` takes no `session_id` and no `page_range`,
   stages nothing, and confirms through `skills/confirm.js` with one
   batch-level `source_book`. Its 105 page-less rows are a different finding.
   Nothing about its behaviour changed here.
3. **"That is the whole explanation for F5's coverage numbers" is wrong, and
   this PR moves no number at all.** Production `import_sessions` and
   `import_staged` are both empty — F7 says so twelve findings later and F6
   reasons as though they were full. Every psionic row in production came from
   a data script: `add-burster-psionic-powers.sql` writes
   `Rifts Ultimate Edition p.141` (which is 4 of the 7 traceable rows) and
   `add-rue-psionics-batch.sql` writes the bare title 22 times. The session UI
   has never written a psionic row to production, so it cannot be what dropped
   their pages. **F6 is purely forward-looking**: the ledger reads identically
   before and after, and will keep reading identically until a session import
   is actually run against production.

One thing the proposal asks for that `COALESCE` cannot give, left alone as
instructed and recorded here instead: "a re-import that has no page range must
not blank one an earlier row already carries" holds for a session with **no
book label** (composes to `null`, `COALESCE` keeps the old value), and does not
hold for a session labelled with a book but a row with no range — that writes
the bare title over an existing `p.141`. It behaved that way before this PR
too, for every row rather than some, so nothing regressed; fixing it needs a
read-before-write on `source_book` that is a behaviour change on updates and
was not asked for.

### F7 — the extraction calls are the only Claude calls in the repo that are not metered

**What is true today.** `functions/api/_lib/claude-client.js:106` exports
`recordUsage`, described in its own comment as "one row in `claude_usage` per
model call — who spent the key, on what", fail-open by design. Exactly two
callers use it: `functions/api/claude.js:38` (the proxy) and
`campaigns/[id]/ask.js:109`. The three that do not are
`import/extract.js:77` (the class importer),
`_lib/import-engine.js:315` (**all four** catalog importers) and
`campaigns/[id]/npcs/sweep.js:75`.

Production `claude_usage` confirms it: 22 rows total, all `pick3cut5-solo`,
`pick3cut5-party`, `campaign-ask` and `proxy`. **Zero import rows.** Production
`import_sessions` and `import_staged` are both empty, so every import ever run
went through a local dev server — which means the local rows are the only ones
that could exist, and they were never written either.

**Why it matters.** Extraction is, by the `book-survey` skill's own framing, the
only step in the whole pipeline that costs money. The brief asks what book #9
costs end to end. The honest answer is that nobody can know, because the one
operation with a price attached is the one operation not recorded — while the
table to record it in has existed since migration 038.

**Proposal:** add `recordUsage` to all three call sites, with endpoint labels
`cc-import-class`, `cc-import-<catalog>` (spells / psionics / gear / skills, from
`spec.catalog`) and `cc-npc-sweep`. `import-engine.js` already returns
`payload.usage`; pass the same `upstream` object through. Posture: **spend
visibility, not a cap** — identical to the posture `recordUsage`'s own comment
states, fail-open, nothing on the request path reads it, no budget, no refusal.
Add one query pattern to `SETUP.md` beside the existing ones: tokens by endpoint
and by day, so "what did this book cost" is a question with an answer. This is
worth taking early, because every finding about batching or caching below is
otherwise argued from first principles rather than from numbers.

**And it closes a provenance gap nothing else can.** `import.html` offers a
per-extraction model choice — `claude-sonnet-5` (default) or `claude-opus-5`
(`import.js:284-287`, `ALLOWED_MODELS` in both extractors) — and **nothing
records which model produced which row**. There is no `model` column on
`imported_classes`, on `import_staged`, or on any catalog table; `claude_usage`
has one and the importers never write to it. So "were the rows we are least sure
about the ones extracted on the cheaper model" is unanswerable, and will stay
unanswerable for every row imported before this lands. `recordUsage` already
reads the served model out of the response body, so labelling the call by
endpoint gets this for free at the session level; recording it per row is a
larger change and is **not** proposed here.

**Taken, 2026-08-27 (PR #347).** All three call sites meter now, with the
labels this proposal names: `cc-import-class` (`import/extract.js`),
`cc-import-<catalog>` from `spec.catalog` (`import-engine.js`, covering
skills / spells / psionics / gear) and `cc-npc-sweep`. `email` is threaded in
from each endpoint's own guard, because `import-engine.js` has no request to
read one from. SETUP.md gains the two query patterns asked for — by endpoint
and by day — beside the one it had. Posture unchanged: fail-open, nothing on
the request path reads the table, no budget, no refusal.

Its measurements held, which is a first for this file. `claude-client.js:106`,
`claude.js:38`, `ask.js:109`, `import/extract.js:77`, `import-engine.js:315`
and `sweep.js:75` are all still exactly where this says. Production
`claude_usage` is **23 rows, not 22** — one more `pick3cut5-solo` since the
audit — across the same four endpoints, and still **zero import rows**.

Three things worth recording:

1. **Metered BEFORE the reply is parsed**, at all three sites. Every one of
   these endpoints has error paths between `callAnthropic` and the row it
   eventually returns — non-JSON body, non-200 status, `stop_reason:
   max_tokens`, no text block — and each of them spends the input tokens for a
   whole PDF page and then returns an error. A run that cost money and produced
   nothing is the run most worth having a number for. `recordUsage` already
   handles a body with no `usage` in it: the row records the attempt.
2. **The smoke test counts rather than lists.** It walks `functions/` for
   `await callAnthropic(` and fails if any file that has one lacks a
   `recordUsage(`. Naming today's five files would pass forever while the next
   endpoint that calls the model quietly went unmetered, which is the
   regression this exists for.
3. **Two live comments said the importers stay unlogged on purpose**, and both
   are corrected: `ask.js:107` ("The admin importers stay unlogged — they are
   gated to one email already, which is the question this table answers") and
   SETUP.md's spend section, which said the same thing in the same words. Both
   were answering the wrong question — the table records what was SPENT, not
   who may spend it. `operations.md`'s migration-038 row named only the proxy
   and the Ask, and now names all of them.

One trap for the next finding that corrects a doc: **the smoke check cannot be
"the stale phrase is absent."** The corrections above quote the old wording in
order to explain what changed, so a grep for it fails on the fix. The two
checks pin the CURRENT claim in SETUP.md instead.

What this does not do, exactly as proposed: **nothing records which model
produced which row.** `claude_usage` has a `model` column and now gets it
filled per extraction call, so spend is answerable per session; per-row
attribution is still a larger change and still not proposed.

### F8 — `book-reconcile` has no junction, so phase 5's second reader does not exist where the book work happens

**What is true today.** `book-survey` §5, "the step that is easiest to skip",
opens with "**Hand this to the `book-reconcile` subagent.**"
`.claude/agents/book-reconcile.md` exists in the repo. It is **not** junctioned
into `~/.claude/agents`, which does not exist — while all five skills are
junctioned into `~/.claude/skills` (verified: five symlinks, dated 2026-08-25,
from `EFFICIENCY-AUDIT` F5).

`SETUP.md:96` says in as many words why the junctions exist: "The book work runs
from `Downloads` (the PDFs land there, and the session memory is keyed to it),
and a session started outside the repo never registers `.claude/skills/`."
Everything that sentence says about skills is true of agents, and only skills
got the fix.

Verified in this session, which was started from `C:\Users\natha\Downloads`: all
five skills are available by name; `book-reconcile` is not in the agent list.

**Why it matters.** The instruction is live, it names the pass the skill itself
calls the easiest to skip, and it silently does nothing in the working directory
the setup docs say the book work happens in. A session that follows it either
runs the reconciliation itself — losing the entire "did not write the parse"
property the agent exists for — or concludes the agent was deleted.

**Proposal:** add the junction, in the same shape as the skills':
`New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\agents\book-reconcile" -Target "C:\Users\natha\Projects\nates-apps\.claude\agents\book-reconcile"` —
noting that agents are files rather than directories, so this needs either a
per-file link or the whole `.claude/agents` directory junctioned as
`~/.claude/agents`; prefer the directory, so a second agent added later is
covered for free. Extend `SETUP.md:96-110` to cover agents alongside skills, and
change its closing sentence — "A skill added to the repo later needs its own
link — there is nothing that notices the gap" — to name agents too. Posture:
**machine setup plus a doc change**, no code. If the directory junction is taken,
`book-survey` §5 needs no edit; if it is not, §5 must stop naming a subagent that
is not there.

### F9 — `CLAUDE.md` still tells sessions the skills do not load, which stopped being true on 2026-08-25

**What is true today.** `CLAUDE.md:11` is headed "**Five skills, and they only
load from the repo root**", and `CLAUDE.md:13-15` says: "They are
**directory-scoped**: a session started anywhere else — in `Downloads`, say, with
the PDF — will not see them, and one session ran an entire class import by hand
for exactly that reason."

`SETUP.md:96-107` documents the junctions that fixed precisely this, landed
2026-08-25 as `EFFICIENCY-AUDIT` F5, whose *Taken* note records "The five
junctions are live on this machine". This session, started in `Downloads`, has
all five skills available by name. The two files now contradict each other, and
the one that is wrong is the one loaded automatically into every session.

**Why it matters.** It is a live instruction that describes a solved problem as
unsolved, on the exact working directory the book work uses. The cost it invites
is the one it warns about — a session pasting skill text in by hand, or
`cd`-ing pointlessly — which is what F5 was bought to stop.

**Proposal:** rewrite `CLAUDE.md:11-15` to: the skills live in `.claude/skills/`
and are directory-scoped, **so they are junction-linked into
`~/.claude/skills` and do load from anywhere on this machine** — with a pointer
to `SETUP.md`'s junction block and its "a new skill needs its own link in the
same PR" rule (extended to agents by F8). Keep the sentence about the session
that ran an import by hand as the *reason the junctions exist*, past tense.
Posture: **doc-only, no behaviour**, and it qualifies as the audit convention's
in-PR rot fix if you would rather it rode along with whichever finding lands
first than take a PR of its own.

**Taken, 2026-08-27** (PR: `claude-md-skills-load`). `CLAUDE.md`'s heading and
opening paragraph now say the skills **do** load from anywhere on this machine,
keep the session-that-imported-by-hand sentence as the reason the junctions
exist, and point at `SETUP.md`'s junction block plus its "a new skill needs its
own link in the same PR" rule. Doc-only, no behaviour, taken as its own PR
rather than folded into another.

**One departure, and it is the half the proposal got backwards.** The proposal
says to extend the same-PR rule "to agents by F8". Extending it would state
something untrue: `~/.claude/agents/` is **empty**, verified today. The five
skills are junction-linked (`book-survey`, `claim-audit`, `class-import`,
`schema-change`, `ship-pr`, all dated 2026-08-25); `.claude/agents/`
is not covered by that loop at all, so `book-reconcile` cannot be spawned from
`Downloads`. `CLAUDE.md` and `SETUP.md` now say so and point at F8 — which turns
the rot this finding is about into a live pointer at the finding that fixes it,
rather than replacing one false sentence with another.

**Pinned, so it cannot rot the same way twice.** Four checks in the smoke test's
*Documented counts* section: `CLAUDE.md` must say the skills load from anywhere
and must NOT contain "only load from the repo root"; it must point at the
junction block; `SETUP.md` must still carry that block; and **the junction loop
must name every skill in `.claude/skills/`** — the same completeness problem the
`CLAUDE.md` table already had, and the gap a sixth skill (F14) would fall
straight into. The junctions themselves are per-machine and cannot be tested
from a repo, but every sentence about them can.

The comment above that smoke block said the same false thing and was trued up in
the same pass.

Measured after: smoke **1,384 checks / 90 sections** (up 4), regression 215,
filament-forge 58, pick3cut5 17 + game 23, media-vault 200, all green.


### F10 — `SURVEY.md` exists for none of the eight cached books

**What is true today.** `EFFICIENCY-AUDIT` F1 shipped 2026-08-25: persist the
survey to `.cache/books/<slug>/SURVEY.md` and boot fresh sessions from it.
`book-survey` §7 is a full page on what belongs in it — inventory table,
authority pages, the *verified* offset, the catalog diff with its hand-checked
false gaps, the extraction plan, and a per-PR progress ledger. `book-survey`'s
closing "What surveyed means" makes it the definition of the word.
`class-import` §"A batch outlives the session on purpose" tells every import to
append a ledger line there and start a fresh session every 2–4 PRs.

`ls .cache/books/*/SURVEY.md` returns nothing. **Zero of eight.** Books have
been imported since — Juicer Uprising and the Pantheons work both post-date the
instruction.

**Why it matters.** It is the load-bearing half of the fresh-session discipline
that F1 measured as a 2–7× token saving. Without it, "start a fresh session
every 2–4 PRs" costs a re-derivation of everything the last session knew, which
is a worse deal than staying in the long session — so the instruction is not just
unfollowed, it is actively unsafe to follow.

**Proposal:** two halves, both in one PR. First, a **template**:
`.claude/skills/book-survey/reference/SURVEY.md` with the seven §7 headings as
empty sections and one worked ledger line, so writing one is copying a file
rather than remembering a list — this is the same move `class-import` already
makes with `reference/data-script.sql`, and its absence is the likeliest reason
none exist. Second, **backfill the eight** from what the repo can already answer
without reading a book: slug, source PDF, cached page range, F4's offset, F3's
coverage, and the shipped-content ledger reconstructed from `git log --oneline`
plus F5's per-book class and catalog counts. That backfill is offline, free, and
it is what makes the file worth booting from on day one rather than after the
next import. Posture: **template plus one-time backfill**; do not add a check
that a survey exists — the caches are gitignored and a clean clone has none, so
such a check could only fail on the machines that matter.

**Adjusted 2026-08-27, after F5.** The coverage line this proposal wants to
quote exists: `source-coverage.mjs` reports per book, so a `SURVEY.md`'s
"what remains" section is a paste rather than a count. The backfill also has
more to draw on than this text assumes — the manifests now carry
`text_layer`, `cached_pages`, `cached_range`, `printed_pages` and
`page_offset` (F2/F3), so the template's offset section should say **read it
from `scripts/books.json`** rather than leaving a blank to re-derive. Two of
the eight books to backfill changed under F2: `fom` is 161 pages, not 73, and
`potm` is 210, not 202.

### F11 — slicing a page range out of a PDF is manual, external, and leaves the slices in `Downloads`

**What is true today.** `import.html` asks for "a focused page range covering
exactly one O.C.C./R.C.C." (`import.js:273`). The class importer is one class per
upload. Nothing in the repo produces such a slice. Seven hand-made slices are
sitting in `C:\Users\natha\Downloads` — `Rifts - Ultimate Edition-142-159.pdf`,
`-264-277.pdf`, `-329-332 (1).pdf`, `-347-356.pdf`, `Rifts Main-116-128.pdf`,
`-169-191.pdf`, `-206-230.pdf`, `-26-34.pdf`, `PFRPG - Dragons and
Gods-23-24.pdf` — named by an external tool's convention, not by slug, with no
record of which printed pages they hold or which import used them.

**Why it matters.** Step 9 repeats once per class, it is the step whose input is
a *printed* page range and whose output is addressed by *PDF* page, and it is
therefore the step where the F4 offset gets applied by hand, silently, 37 times.
The brief notes one stamp "was a full page high and shipped wrong"; this is where
that happens.

**Proposal:** add `scripts/slice-pages.py <slug> <first> [last]` — takes
**printed** page numbers, applies the recorded offset (F4), writes
`.cache/books/<slug>/slices/p<first>-<last>.pdf`, and prints the folio it found
on the first and last page of the slice as the confirmation `book-survey` §0d
already asks for. `pymupdf` can do this in four lines and the dependency is
already required. Slices land under the gitignored cache, so they are not
commercial book text in the repo and they accumulate where the book they came
from is. Posture: **prints the folio it actually found, every time** — the
confirmation is the point of the script, not the slicing. Add it to the README
map and to `.claude/settings.json` (it writes only into `.cache/`). Depends on
F4 for the offset; usable with an explicit `--offset` before F4 lands.

**Adjusted 2026-08-27, after F4 — and this one is load-bearing.** The offset is
no longer a scalar. `pf`'s is +1 for printed 1-16 and +2 for 18-336, carried
in `page_offset_exceptions`. A slicer that applies `page_offset` flat would
cut the wrong page for every request in the head of the most-cited book —
including the Attribute Bonus Chart at printed 16, which is the worked example
`book-survey` §0d is built around. Use `offsetForPrintedPage(first, entry)`
from `class-check-lib.mjs`, per call, and print the rule it applied beside the
folio it found. The `--offset` escape hatch this proposal mentions is still
worth having, but it is now the third choice, not the first.

### F12 — every extraction re-uploads its PDF and its examples with no cache breakpoint

**What is true today.** `cache_control` appears nowhere in `functions/` or
`apps/`. Both extraction paths send the PDF as a fresh base64 document block on
every call (`import/extract.js:69`, `import-engine.js:310`), and the class
importer additionally prepends two complete published class markdown files as
format examples, refetched per call
(`_lib/class-store.js` `getExamples`, `limit = 2`, read into
`buildUserPrompt`'s `exampleBlock`).

The two shapes are different and both are cacheable:

- The **class** importer's examples and system prompt are identical across every
  class in a run — a stable prefix that is re-billed per class.
- The **session** importers re-upload the same PDF slice whenever an extraction
  is retried, which `import-engine.js:338` actively invites: a `max_tokens` stop
  returns "Narrow the page range and try again", and narrowing means uploading a
  new slice of the same pages.

**Why it matters.** This is the direct answer to "is re-importing from a cached
book meaningfully cheaper". For the free half, yes. For the paid half, no — and
the paid half is the only half with a price.

**Proposal:** put a `cache_control: { type: 'ephemeral' }` breakpoint at the end
of the **system prompt and example block** in the class importer, which is the
stable prefix, and at the end of the **document block** in `extractRows`, which
is what a retry re-sends. Order matters: the document must precede the varying
instruction text for the breakpoint to help, which it already does in both
request builders. Do not cache the per-call user text. Posture: **cost only, no
behavioural change** — a cache miss is exactly today's behaviour, so there is no
correctness risk and nothing to gate. Take **F7 first**: with metering in place
this is a measurable before/after on the next book, and without it, it is a
change whose benefit cannot be shown.

### F13 — the diff that decides what gets extracted defaults to the database the repo says is not a mirror

**What is true today.** `scripts/catalog-diff.mjs:35` defaults to `--local`, with
the comment "a diff is exploratory and should not need the network". Every other
ingestion-adjacent script asks production: `drift-check` is `--remote` in the
documented invocation, `repo-vs-live` compares against live, and `CLAUDE.md` ends
its three-things-that-fail-late list with "`--local` is not a mirror of
production. It accumulates. Ask production."

Measured today, this worktree's local D1 agreed with production on all five
counts (skills 333, spells 570, psionics 101, gear 902, classes 109) — so this is
not a live bug, and I am not reporting one. The prior session's note that local
held 327 skills against production's 324 is the state this defaults into.

**Why it matters.** Phase 3 of the survey exists to cut phase 4 — the only step
that costs money — by more than half. The number it produces is the number that
decides what gets extracted, and it is answered from a database that the repo's
own top-level instructions say not to trust, in a script whose header quotes
three occasions where a confidently wrong diff answer did damage.

**Proposal:** keep `--local` reachable but make the target **explicit and
printed**. `catalog-diff.mjs` prints the target it used on the first line of its
output — it currently does not — and, when the target is `--local`, prints the
row count of the table it diffed beside production's, fetching the latter only
when the network is available and saying "could not reach production" when it is
not. Posture: **do not change the default and do not block** — flipping the
default would make an offline diff fail, and the failure this prevents is not "a
wrong default" but "a number quoted without its provenance". Update
`book-survey` §3 to show the `--remote` form as the one to use when the answer
is going to be spent against.

**Adjusted 2026-08-27, after F5.** `source-coverage.mjs` is a second script
that defaults to `--remote` and prints its target on the first line — the
shape this proposal asks `catalog-diff` to adopt. The precedent is set; the
proposal is unchanged.

### F14 — the sixth skill should be the audit-menu protocol, and it is the only one that qualifies

**What is true today.** Five skills exist. The protocol this very file is written
in — `F<n>` numbering, a `Proposal:` paragraph specific enough to implement from,
one PR per finding, a `Taken, <date>:` note appended under the finding in the
same PR, merge on a separate word — is written down **nowhere**. Grepping
`CLAUDE.md`, `SETUP.md`, the README, all eleven `docs/*.md` and all five
`SKILL.md` files for `Taken,`, "audit menu", "audit protocol", "F-number" or
"findings menu" returns nothing. It survives in four precedent files
(`AUDIT.md`, `CLASS-AUDIT.md`, `DOCS-AUDIT.md`, `EFFICIENCY-AUDIT.md`) and in
session memory.

The failure it prevents is on record and has cost time three separate times.
Reading the precedent files is not enough to run the protocol correctly: the
outcome notes are worded three different ways, so grepping for `Taken` has
produced **three false findings** about which items were closed — and this
session hit the same rock, since the brief that commissioned it states
`EFFICIENCY-AUDIT` F7 is "still open" when the file records
`**Taken, 2026-08-25**: as proposed, with one addition the caches forced`, and
`class-check --field-sources` demonstrably ships (`scripts/class-check.mjs:73`).
A skill that says "read the lines under the finding heading, never grep for the
word" would have cost thirty seconds and saved this audit a wrong premise.

**Why it matters.** Every other candidate the brief raises is a *mechanism* that
should be a script (F2, F4, F5, F11) rather than prose a session has to be told
to follow. This one is genuinely a protocol — it is about how findings are
numbered, scoped, taken and recorded, and there is no code that could enforce it.

**Proposal:** add `.claude/skills/audit-menu/SKILL.md`, short — under 120 lines,
in the shape of `claim-audit` rather than `book-survey`. It must carry: the
`F<n>` / `Proposal:` / `Taken,` / one-PR-each loop and the fact that "take F6"
means *as written, scope and posture both*; the rule that posture must be stated
explicitly (log-not-cap, warn-not-block, opt-in) because it is half of what is
being agreed to; the "never grep for `Taken`, read under the heading" rule with
the three-false-findings history that produced it; the "audit files are records —
add a dated banner, do not rewrite a past measurement" rule that `PR #310`
established; the "absence claims need a fresh read, not a grep" rule that cost
the seven-missing-attribute-requirements false finding; and the requirement that
every number carry its date and its source. It gets its `~/.claude/skills`
junction in the same PR (and, per F8, `SETUP.md`'s list is updated). Posture:
**one skill, no script** — nothing here is mechanisable, which is exactly why it
qualifies and the others do not.

**Adjusted 2026-08-27, after F1-F5.** The protocol now has **nine** precedent
files rather than four, and five of them are in this document. Worth adding to
whatever gets written: taking a finding is also **auditing the finding**. Five
of the five turned up an error in their own premises (see *Status* above), and
one of those errors would have shipped a silent bug if the proposal had been
implemented as written. "Verify the premises against current code before
scoping, and lead the report with the corrections" is the single highest-value
rule the protocol has, and it is currently unwritten.

### F15 — what should move between skills and scripts, and what should not become a skill

**What is true today**, and the dispositions this audit reached:

**Skill content that should be a script.** `book-survey` §0, §0b, §0d and the §1
inventory regexes are procedures a session retypes from prose every book. F2
(the one caching front door, including the probe), F4 (the recorded offset) and
F11 (the slicer) are the three that carry real failure histories; taking them
shortens `book-survey` by roughly 90 lines and replaces them with commands. The
skill's remaining value — §0c "a text layer does not give you TABLES", §2 the
authority table, §4b two authorities checking each other, §4c when a page argues
with the index, §5 reconciliation — is judgement, and none of it mechanises.

**A script that is stuck at one book.** `scripts/parse-pf-spell-index.mjs` (153
lines) and `parse-pf-spell-descriptions.mjs` (170) are named for Palladium
Fantasy and hard-coded to its two tables' shapes. What is reusable in them is
stated in their own headers and is genuinely general — "a name is whatever
precedes the **last** parenthetical", "a cost is anything carrying a digit or
Special/Varies", "find the heading by looking *backwards* from the field that is
always there rather than by trying to recognise a title". Book #9 will not run
either script and will re-derive both lessons. They are **not** worth
generalising speculatively — an index parser that has seen two books is a
parameterised guess. The right move is smaller: lift those three rules into
`book-survey` §2 as named rules with their failure histories (two of the three
are already there in weaker form), and leave the scripts as the worked examples
they are, with a one-line header on each saying it is PF-shaped and what to copy
from it.

**Not a skill: a UI skill for this app.** The brief raises it. The evidence for
what it would contain is Track G's, and Track G has not run. Proposing its
contents now would be writing documentation from a guess, which is the exact
thing the brief says disqualifies a skill. **Defer** to after `UI-AUDIT.md`
exists, and let its findings say whether the failure — "a prior session declared
tabs working on the strength of metrics, and the screenshot showed them below
the fold" — is one rule that belongs in an existing skill or a sixth skill's
worth of surface.

**Not a skill: a book-cache/page-offset skill.** The brief raises this too. Every
part of it that has a failure history is mechanisable, and F1–F4 mechanise it.
A skill here would be a manual for scripts that should not need one.

**No existing skill is too long or overlapping.** `book-survey` at 444 lines is
the longest and is the only one that reads as near its limit; F2/F4/F11 take
about 90 lines out of it and that is enough. `class-import` (285) and
`book-survey` overlap at exactly one seam — "check for a text layer FIRST" —
and it is a pointer, not a copy, which is right. `ship-pr` (258),
`claim-audit` (168) and `schema-change` (133) are each about a distinct
irreversible step and do not touch this pipeline. The one fork that *did* exist —
`book-survey/reference/`'s stale private copy of `read-columns.py` — was already
removed and the skill records why.

**Still done by hand often enough to deserve tooling, and not covered above:**
copying extracted markdown out of the review UI into a scratch `.md`, then into
the data-script template with apostrophes doubled and non-ASCII spliced through
`char()` (runbook steps 11 and 13, once per class). `class-check` already emits
the stub SQL block for exactly this reason — "writing them by hand is where the
STUB marker and the `char(8212)` splice get forgotten"
(`scripts/class-check.mjs:438-441`). The same argument applies to the
`imported_classes` INSERT, which is larger and has the apostrophe-doubling rule
on it.

**Proposal:** take this as **three separate PRs**, in this order, and treat the
two deferrals as decisions rather than gaps. (1) Once F2, F4 and F11 have landed,
rewrite `book-survey` §0/§0b/§0d/§1 down to the commands they became, and add the
three general parsing rules to §2 with a header line on each
`parse-pf-spell-*.mjs` marking it a PF-shaped worked example — one doc PR, no
code. (2) Extend `class-check` with `--emit-script <id>`, which writes the whole
`add-<id>-class.sql` — template header, stub SQL block it already produces, and
the `imported_classes` INSERT with apostrophes doubled and non-ASCII spliced —
to stdout, from a validated `.md`. Posture: **stdout, never a file, and it does
not apply anything**; it is the escaping that is worth automating, not the
decision to ship, and `class-check` on the resulting `.sql` remains a separate
step so the ASCII/CRLF pre-flight still runs against the real artifact. (3) The
UI skill: revisit after Track G, with `UI-AUDIT.md` in hand.

**Adjusted 2026-08-27, after F2 and F4 — part (1) is half done, and its
premise inverted.** `book-survey` §0, §0b and §0d have already been rewritten
around the commands they became. What is left of part (1) is **§1 only**
(the inventory regexes), plus the three parsing rules into §2 and the
PF-shaped header lines on `parse-pf-spell-*.mjs`.

But the length claim is now false in the other direction: `book-survey` is
**519 lines, not 444**. Replacing prose with commands did not shorten it,
because each rewrite carried its failure history in with it — the resume
footgun, the `bom` refusal, the `pf` split. That is the right trade for a file
whose whole job is stopping a session from re-deriving a mistake, but "F2/F4/
F11 take about 90 lines out of it" should not be quoted as a reason to expect
the file to shrink. If it needs to be shorter, that is now its own decision
about which failure histories have earned their place.

### F16 — every class extraction is taught the format by the two oldest and most-corrected classes in the repo, forever

**What is true today.** `_lib/class-store.js` `getExamples(env, limit = 2)`
selects `WHERE status = 'published' AND deleted_at IS NULL ORDER BY created_at,
class_id LIMIT 6`, then picks the first `occ` and the first `rcc` out of those
six and prepends both, in full, to every class extraction prompt
(`extraction-prompt.js` `buildUserPrompt`, `exampleBlock`).

That ordering is fixed. The six oldest published classes, measured 2026-08-26,
are `cyber-knight`, `dragon-hatchling`, `long-bowman` (all three stamped
`2026-08-13 23:39:20`, so the tie is broken alphabetically on `class_id`),
`juicer`, `chiang-ku-dragon`, `godling`. The two that get picked are therefore
**`cyber-knight`** (occ, 9,876 chars) and **`dragon-hatchling`** (rcc, 5,684).
They were published on day one and they will be the exemplars until one of them
is retired.

Three things make that the wrong pair:

1. **They are the two most-corrected classes in the repo.** Between them they
   are the subject of five correction scripts — `fix-cyber-knight.sql`,
   `fix-rue-cyber-knight-bonuses.sql`, `fix-rue-cyber-knight-psionics.sql`,
   `fix-dragon-hatchling.sql`, `fix-rifts-core-dragon-hatchling.sql`. Whatever
   was wrong with them was being taught to every extraction until each fix
   landed.
2. **`dragon-hatchling` is one of the two classes F5 flags as untraceable.** Its
   `source_book` is `Rifts RPG (original core book) p.98-101`, which resolves to
   no cached book at all and is one of the four unresolvable spellings in F1. The
   permanent RCC exemplar is the one class whose pages cannot be checked.
3. **They predate every convention the later imports taught.** The
   attribute-requirement shapes, the variant blocks, the `only`/`except`
   restriction idioms and the racial-S.D.C.-is-a-pool-bonus rule in
   `class-import` §"Rules that are easy to get wrong" were all learned after
   2026-08-13, and none of them is demonstrated in the two files the model
   actually sees.

**Why it matters.** This is the one place in the pipeline where a single choice
affects the quality of *every future extraction*, and it is currently made by
`ORDER BY created_at` — which is to say, not made at all. It is also invisible:
nothing in the UI, the prompt or the docs says which two classes are teaching
the format, so a session correcting an exemplar has no idea it is editing the
prompt.

**Proposal:** stop choosing exemplars by age. Add an explicit, committed list —
two `class_id`s for `occ` and `rcc`, in `extraction-prompt.js` beside the schema
it already documents — and have `getExamples` select those by id, falling back
to today's `created_at` ordering only when a named exemplar is missing or
retired (so a fresh database still works). Choose the pair on merit: a class
that is fully traceable under F5, that exercises the conventions later imports
taught, and that has *no* outstanding `fix-` script. On today's corpus `juicer`
(occ, 15,867 chars, `Rifts Ultimate Edition p.79-81`, traceable) is the obvious
OCC candidate; the RCC choice is a judgement call and this audit does not make
it — pick it when the finding is taken, with `class-check` run over the
candidates first. Posture: **named exemplars, with the age ordering kept as the
fallback** — do not delete the old path, because a database with neither named
class present must still extract. Add a comment on both exemplar rows' entry in
the list saying they are load-bearing for the prompt, so the next person to
correct one knows what else it is. This is cheap, it is a prompt change with no
schema and no data, and it is worth taking before the next book rather than
after it.

### F17 — every guard in the pipeline is designed to fail silent when the cache is gone, and the cache is unbacked

**What is true today.** `.cache/books/` is 33 MB across eight books — `rue`
25 MB, `pf` 2.5 MB, the rest under 1.6 MB each. It is gitignored by design and
that design is correct: it is the full text of books Palladium still sells, and
`ocr-book.py`'s header and `book-survey` §0b both say so.

Three separate checks read it, and two of them treat its absence as a non-event
by explicit design:

- `drift-check.mjs:141-142` — "on a machine without it this silently does
  nothing rather than failing — a missing cache is not drift".
- F5's proposed `source-coverage.mjs`, which this audit specified the same way,
  for the same reason.
- `class-check --field-sources` is the exception: it `die()`s with "this machine
  has none" (`class-check.mjs:169`).

That posture is right for a clean clone. Its consequence is that **total loss of
the cache is indistinguishable from a clean clone**: two of the three guards go
quiet, report nothing wrong, and keep exiting 0. Meanwhile the inputs needed to
rebuild — nine source PDFs — live loose in `C:\Users\natha\Downloads` among
everything else that lands there, in no inventory, named only as manifest
basenames with no directory recorded. `pf`, the most-cited book, has no manifest, so its
source PDF filename is written down nowhere at all.

**Why it matters.** The rebuild is genuinely cheap once F2 exists — one command
per book, and free for the six with a text layer. What is not cheap is *noticing*,
and what is not recoverable is a PDF nobody kept. Nathan expects to add many more
books; this is the point at which "the caches are just working files" stops being
true, because F1's registry, F4's offsets and F5's coverage all become claims
about books whose text may no longer be on the disk.

**Proposal:** make F1's registry double as the recovery record — it already
carries slug, canonical title, `source_pdf` and page counts, so add
`source_pdf_dir` (the directory the PDF was read from, `C:\Users\natha\Downloads`
today) and nothing else. That file is committed, holds no book text, and is
enough to rebuild every cache with F2's one command. Then close the silent half:
give `drift-check` and `source-coverage` a one-line summary they print
**always** — "caches: 6 of 9 registered books present" — so a missing cache is
visible without being an error. Posture: **print, do not fail** — the exit code
must not change, because a clean clone is legitimate and this is a status line,
not a gate. Separately, and outside the repo: the nine PDFs are the only
irreplaceable artifact in this pipeline and are worth a copy somewhere that is
not `Downloads`. That is a decision for you, not a change this audit proposes.

**Adjusted 2026-08-27, after F1-F5 — one premise is now false and one risk
dropped.** `pf` **has a manifest** (F2 backfilled it), so its source PDF
filename is written down in two places, not none. And `scripts/books.json`
already carries `source_pdf` for every book including the four that are cited
and uncached, so the recovery record this proposes is one field
(`source_pdf_dir`) away, not a new file.

The rebuild is now genuinely one command per book and free for the seven with
a text layer, exactly as this predicted — but with a caveat this could not
have known: a rebuild is **not** byte-identical for two of them. `pf` reorders
blocks on 68 pages (no content change) and `ju` changes 148 of 162 pages,
because its current cache is the wrong read. Rebuilding is safe; rebuilding
silently is not, which is why F2 made switching a cache's kind require
`--force`.

The always-printed status line is half shipped: `source-coverage.mjs` prints
`caches: 8 on this machine` with each one's page count on its first line.
`drift-check` still does not, and the registry now makes "8 of 12 registered"
a one-line computation.

### F18 — the skill importer is the one confirm path with no page range in it at all

**What is true today.** F6 composed a page range onto every row the *session*
importers confirm. The skill importer is not one of them.
`import/skills/extract.js` takes `{ pdf_base64, category?, source_book?,
systems?, hints? }` — no `session_id`, no `page_range` — stages nothing, and
returns its rows to the browser. `import/skills/confirm.js:27` then reads one
`source_book` off the request body and hands it to `applyDecisions` for the
whole batch. `import.js:151` fills that from a single `source-book` text input
filled in once per upload. There is nowhere in the flow for a page to be
recorded, so nothing is dropped — it is never collected.

Production, today: **105 of 333 skills carry a book with no page range.** 93 of
them say `Rifts Ultimate Edition`, 5 `palladium-fantasy-core`, 4
`pantheons-of-the-megaverse`, 3 `Palladium Fantasy RPG 2nd Ed.`. Another 123
skills *do* carry `p.N-M`, so the catalog is not uniformly untraceable — it is
traceable exactly where a data script wrote the citation by hand, and page-less
everywhere the importer wrote it.

**Why it matters.** This is the second-largest untraceable block in the ledger
after spells, and unlike spells it has a known single cause with a one-field
fix. It is also the only one that will keep growing: the skill importer is the
front door for every future skill chapter, and every row it confirms from here
on is another page-less row. F6 fixed the three catalogs that had the value and
threw it away; this is the fourth catalog, which never had it.

**Proposal:** give the skill importer the same page-range field the session
importers have. `import.js` grows a second text input beside `source-book`
labelled the same way (`Page range, e.g. pp. 26-34`), `skills/extract.js`
passes it back in its response the way it already echoes `source_book`, and
`skills/confirm.js` takes `page_range` off the body and composes the batch's
`source_book` through `composeSourceBook` before calling `applyDecisions`.
Batch-level, not per row — this importer has no staging table to hang a
per-range value on, and a skill chapter is uploaded a few pages at a time
anyway, so the batch *is* the range. Reuse `_lib/source-book.js` exactly as it
stands; it already resolves the book through the registry and normalises the
label. Posture: **new rows only.** The 105 existing rows are a backfill
question — they are 105 rows across four books whose chapters are known, so
they are answerable, but answering them is a data script and a different PR.
Pin the composition in the smoke test the way F6's is pinned.

### F19 — `COALESCE` protects a NULL, and the value that erases a page range is not NULL

**What is true today.** `buildUpdate` (`import-engine.js:527`) writes
`source_book = COALESCE(?, source_book)`, and F6 left it exactly as it was, on
the finding's own instruction: *"a re-import that has no page range must not
blank one an earlier row already carries."*

`COALESCE` delivers half of that. An import out of a session with **no book
label** composes to `null` and the existing value survives, which is the case
the sentence describes. But a session labelled with a book whose row has **no
page range** composes to the bare canonical title — a non-NULL string — and
that overwrites. A row that said `Rifts Ultimate Edition p.141` ends up saying
`Rifts Ultimate Edition`, and the ledger moves it from `traceable` to
`no-page-range` without anything reporting a change.

Nothing regressed in F6: before it, every update wrote the session's bare book
name over whatever was there, so this was the behaviour for *all* rows rather
than some. F6 made it rarer without making it impossible.

**Why it matters.** Every other guard in this pipeline is built so that the
absence of information cannot destroy information — that is what the `COALESCE`
on the descriptive fields is for, and what F6's `null` return is for. This is
the one path where a *less specific* answer silently beats a more specific one,
and it fires precisely when someone re-imports a chapter to correct a number,
which is the moment the row's provenance is least expendable.

**Proposal:** make the downgrade impossible rather than unlikely. In
`buildUpdate`, when the composed `source_book` carries no `p.` and the row may
already have one, write
`source_book = CASE WHEN ? LIKE '% p.%' OR source_book IS NULL THEN ? ELSE COALESCE(source_book, ?) END`
— or, if that reads badly in the one place it appears, an equivalent
`COALESCE(NULLIF(...))` form. The rule to encode is one sentence: **a value
with pages always wins; a value without pages only fills an empty column.**
Posture: **no read-before-write and no new query** — this is expressible in the
statement that already runs, and adding a lookup would put a second round trip
on every confirmed row to defend against a case that has not happened yet.
Three smoke checks: paged over paged replaces, paged over bare replaces, bare
over paged leaves the paged value alone.

### F20 — a stub gets the page of the class that mentioned it, and four rows in production point at the wrong page as a result

**Not in the original menu.** Found while taking F6, from the coverage ledger's
`traceable` column rather than its gaps.

**What is true today.** `buildStubStatements` (`_lib/catalog.js:175`) creates
catalog rows for everything a published class references and does not exist
yet. It writes `source_book` on exactly one of the four:

- **gear** gets `sourceBook`, which `import/confirm.js:31` sets to
  `parsed.data.source_book` — **the class's** `source_book`, page range and
  all.
- **skills** (`catalog.js:190`), **spells** (`:196`) and **psionic powers**
  (`:203`) have no `source_book` in the INSERT at all. The column is simply not
  named.

Both halves are wrong, and the first is worse. A class's `source_book` is where
the *class* is printed. A poncho mentioned in the City Rat's equipment list is
not printed on the City Rat's page. Production has four gear stubs — **Poncho**,
**Medical Bag**, **Unbreakable Vial** and **Hand Held Blood Pressure Machine**
— all claiming `Rifts Ultimate Edition p.88`, which is the City Rat O.C.C.
`source-coverage.mjs` counts all four as **traceable**, and `class-check
--field-sources` aimed at any of them would read the City Rat's stat block
looking for a poncho and report the nearest-looking lines it found.

The second half is quieter and larger: 12 skills, 16 spells and 12 psionic
powers carry **no `source_book` at all** because the statement that created
them never had the column. That is the whole of the ledger's
`no-source-book` count for spells and psionics.

**Why it matters.** F5 built the coverage ledger to answer "can what shipped
still be traced to a page". A row that traces to the *wrong* page answers yes.
Four rows is small; the mechanism is not, because it fires on every class
import that references an item the catalog does not have, which is most of
them. A missing citation is a gap the ledger reports. A confidently wrong one
is a gap the ledger hides, and this audit's own method — measure, then read the
page — is what it defeats.

**Proposal:** stop attributing a stub to a page nobody claimed. Two changes,
both in `buildStubStatements`:

1. **Drop the page range from the gear stub's `source_book`**, keeping the
   book: write the class's book resolved through `scripts/books.json` with no
   `p.` on it. The book is a real claim — the class that named the item was
   read out of it — and the page is not. `parseSourcePages` and
   `registryBookSlug` are already imported into `functions/` by
   `_lib/source-book.js`; this is that module gaining one small export rather
   than new machinery.
2. **Write the same value on the skill, spell and psionic stubs.** They have a
   `source_book` column and nothing has ever filled it. Three lines.

Posture: **new rows only, plus a named repair for the four.** The four City Rat
rows are a one-statement data script (`UPDATE gear SET source_book = 'Rifts
Ultimate Edition' WHERE description LIKE 'STUB —%' AND source_book = 'Rifts
Ultimate Edition p.88'`) and should ship in the same PR, because leaving four
known-false citations in place while fixing the mechanism that made them is the
half-fix this audit keeps finding elsewhere. Do **not** try to guess the right
page for them — that is a book read, and `Poncho` is exactly the kind of row
where a guess would look right. Pin in the smoke test that a stub's
`source_book` never carries `p.`.


---

## Adding book N — the runbook

**F1–F5 are taken as of 2026-08-27, so steps 0, 1, 2 and 8 are real today.**
What is still a forecast: step 6 needs F10 (`SURVEY.md`), step 7 needs F11
(`slice-pages.py`) and step 9 needs F15 part 2 (`--emit-script`). Step 5 is
real but its `--remote` form is F13. Step 11 needs F8.

One page. Steps marked **(once)** are per book; the rest repeat per class.

```bash
# 0. probe and cache — one command, either kind of book            (once)
python scripts/ocr-book.py "C:/Users/natha/Downloads/<Book>.pdf" --slug <slug> --probe
python scripts/ocr-book.py "C:/Users/natha/Downloads/<Book>.pdf" --slug <slug>
#    writes txt/ (+ tsv/ only if it OCR'd) and a manifest carrying
#    text_layer, page_offset, cached_pages and printed_pages.
```

1. **(once)** Add the book to `scripts/books.json`: slug, canonical title,
   aliases, `source_pdf`, `printed_pages`. This is what makes every later step
   able to say which book a row means.
2. **(once)** `node scripts/source-coverage.mjs --remote` — confirm the new book
   appears and that nothing already shipped points into a gap in it.
3. **(once)** Inventory: count structure markers per page range over
   `.cache/books/<slug>/txt/`. Report the table before extracting anything.
4. **(once)** Find and parse the authority table — `read-columns.py` for a
   text layer, `--psm 3` block grouping for a scan. Render and *look at* any
   chart; a text layer gives prose, not geometry. Probe three or four entries
   whose answer you can verify independently.
5. **(once)** `node scripts/catalog-diff.mjs --table <t> --entries <parsed>.json
   --compare <fields> --remote`. Hand-check the MISSING bucket for false gaps —
   roughly one in twenty is one.
6. **(once)** Write `.cache/books/<slug>/SURVEY.md` from
   `.claude/skills/book-survey/reference/SURVEY.md`: inventory, authority pages,
   the offset the manifest recorded, the diff with its hand-checked gaps, the
   extraction plan, and an empty ledger. **Get agreement on this before spending
   anything.**
7. Per class — `python scripts/slice-pages.py <slug> <printed-first>
   <printed-last>`, which applies the recorded offset and prints the folios it
   found. Upload the slice on `import.html`, extract, review.
8. Copy the markdown to a scratch `.md`. `node scripts/class-check.mjs draft.md`
   until it reads `ready`, then `--field-sources` and **read the continuation
   block** — it uses the recorded offset and warns if live detection disagrees.
9. `node scripts/class-check.mjs draft.md --emit-script <id> >
   apps/character-creator/db/add-<id>-class.sql`, then run `class-check` on the
   `.sql` so the ASCII/CRLF pre-flight fires against the real artifact.
10. `node scripts/d1-apply.mjs --local …`, ask before `--remote`, then smoke,
    `drift-check --remote`, PR per `ship-pr`.
11. Hand the extracted rows to the `book-reconcile` subagent before the data
    script, not after. Every number read twice, from two places.
12. Append one ledger line to `SURVEY.md` when the PR merges. **Start a fresh
    session every 2–4 PRs**, booted from `SURVEY.md` plus
    `git log --oneline -15`.

Steps 0–6 are free and are done once. Step 7 is the only step that costs money.
`node scripts/source-coverage.mjs` answers "what remains" at any point without
reading the book, and `claude_usage` answers "what did it cost" (F7).

---

## Not covered

- **Tracks A, B, C, D and G.** Different sessions. Where this audit touched their
  territory it stopped at the boundary: F13 notices `catalog-diff`'s target but
  does not audit local-vs-production drift (Track B/C); F15 defers the UI-skill
  question to Track G entirely.
- **The 267-script rebuild pile and the filename-sort hazard.** Track B. This
  audit counted the files (267) and confirmed three carry `-- local-only`, and
  went no further. `data_script_runs` holds 271 rows repo-wide against the
  brief's stated baseline of 266 character-creator data scripts; that gap spans
  other apps' scripts and `drift-check --remote` reports NO DRIFT, so it is
  noted and left to Track B rather than chased here.
- **The four pre-existing W.P. citation advisories.** Stated in the brief as not
  mine to fix, and not investigated. F1 and F3 change *which books* the citation
  check covers, not how it judges a name, so neither should move those four.
- **`import.js`'s five tabs as a user interface.** Track G, and the brief says a
  UI finding without a screenshot is a guess. This audit read `import.js` and
  `import.html` for the *pipeline* — what is uploaded, what is stored, what is
  written — and made no judgement about the page's layout, friction, or
  behaviour on a small screen.
- **The extraction prompts' content.** `extraction-prompt.js` (223 lines),
  `gear-prompt.js`, `spell-prompt.js`, `psionic-prompt.js` and `skill-prompt.js`
  were read for what they say about `source_book` (F1) and nothing else. Whether
  they ask the right questions of a page is a book-accuracy audit and belongs
  with `CLASS-AUDIT.md`'s method, not this one.
- **Local D1 as a working environment.** No dev server was started: ports 8788
  and 8791 belong to other sessions. Nothing in the in-app import path was
  exercised end to end; every claim about it above is read from source, from
  production tables, or from the caches on disk.
- **Cross-book duplicate classes.** Checked, and there is nothing to report: no
  two published classes share a name under case- and hyphen-insensitive
  comparison (0 collisions across 109). Whether the same class printed in two
  books gets reconciled rather than imported twice is therefore not yet an
  observed problem, and this audit did not design for it. It will become one:
  the doctrine `book-survey` §4c states — the later book wins, the losing number
  is recorded in `variant_note` — is carried in prose only, and nothing checks
  it.
- **`ocr-fields-lib.mjs` and the OCR substitution table.** Read only far enough
  to establish that `--renormalise` exists and that `manifest.normalisations`
  records a *count* (16) rather than a fingerprint — so a changed substitution
  rule leaves cached `.txt` stale with the manifest still reading 16, and
  nothing detects it. That is a real hazard and it is deliberately **not**
  written up as a finding: it has no observed failure behind it, and by this
  repo's own standard that makes it documentation rather than a finding. If F2
  is taken, replacing that count with a hash of the substitution table is a
  two-line addition to it.
