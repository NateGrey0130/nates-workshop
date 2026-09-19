# Character creator — ingestion and tooling audit, 2026-08-26

> **Since 2026-09-16 the closed findings live in `INGESTION-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **Nothing is open on this menu.** `F25` was filed and taken on 2026-09-03;
> everything before it was closed and re-verified on 2026-09-02. The header
> corrections below track how that list shrank, and the last of them ends
> *"NONE now — the menu is clear."*, which was true the day it was written and
> is true again. Status for any finding lives under its own heading; this line
> deliberately does not count them.
>
> **Adjusted 2026-09-19.** The line above stopped being true when `F35` was
> filed at the foot of this file. Read under each heading for what is open.
>
> **Two that misread, in opposite directions.** `F12`, `F16` and `F19` close as
> **moot** in a retirement table roughly 1,300 lines from their headings, so
> reading only under the heading reports three open that are not. And `F14` —
> the finding that describes this note's own format — carries `**Taken,
> 2026-08-25**` inside backticks as an example, so every grep reports it taken.
> **It also IS taken**, in PR #364, which is what produced
> `.claude/skills/audit-menu/SKILL.md`. That skill still says F14 is open; it
> was written while F14 was, and the sentence outlived it.
>
> **Adjusted 2026-09-02 (PR #552).** The last sentence above stopped being true
> eleven minutes after it was written. This banner landed at 07:55 (PR #531) and
> the skill was corrected at 08:06 (PR #534) — it now records F14 as taken, and
> records that its own wrong sentence stood for five days. Everything else here
> stands: F14 is taken, and this file's note remains the one every grep
> misreads. See `SKILL-AUDIT.md` F20.

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
- **F20** — skill, spell and psionic stubs got no `source_book` at all, while
  gear stubs always did. **Its headline was false and taking it is what found
  that**: the four gear rows it accused of citing the wrong page are correct,
  hand-written by `fix-body-fixer-page-break.sql` against the OCR cache, and
  the proposal's fix for them would have destroyed a verified citation. See
  the `Taken` note under the finding. Nothing was repaired because nothing was
  broken; the quiet half shipped.


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
| 8 | write `docs/surveys/<slug>.md` | manual, and there is a template for it now (F10/F21) |
| 9 | slice a page range out of the PDF | **manual, in an external tool** (F11) |
| 10 | upload, extract, review | in-app, one class per upload; no prompt caching (F12); unmetered (F7) |
| 11 | copy the markdown out to a scratch `.md` | **manual** |
| 12 | `class-check` / `class-check --field-sources` | scripted; the second is opt-in and nothing requires it |
| 13 | paste into `data-script.sql`, double apostrophes, ASCII-ise | **manual** |
| 14 | `d1-apply --local`, then `--remote`; smoke; drift-check; PR | scripted (`ship-pr`) |
| 15 | append the survey's ledger line | manual, and committable now (F21) |

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

## The in-app importer was retired, 2026-08-28 — and it takes five findings with it

Six of the findings below are about code that no longer exists. Read this
before taking any of them.

**It had never run against production.** Not once. `import_sessions` and
`import_staged` held zero rows, and of the 23 rows in `claude_usage` not one
was an import — 21 were Pick 3 Cut 5, one the proxy, one campaign-ask. Every
catalog row in this database was written by a data script, including all
seventeen classes from Wormwood. The audit said as much in its own Status
section — *"no finding should reason from rows the session UI imported until
one is actually run"* — and one never was.

What went: `import.html`, `import.js`, thirteen routes, `import-engine.js`,
`import-sessions.js`, `session-import.js`, four catalog prompt modules,
`class-blocks.js`, the write half of `class-store.js`, 103 smoke checks and a
regression phase. What replaced it: `scripts/extract-class.mjs` for classes,
and a hand-written data script for everything else.

| finding | what it is now |
|---|---|
| **F6** (#344) | Shipped, then deleted. It composed `source_book` per staged row; there are no staged rows. The rule it encoded — a row cites its book WITH a page range — survives in `class-check`, which reads that suffix to find its window |
| **F7** (#347) | **Followed the code rather than dying with it.** The extractor meters to `claude_usage` as `cc-extract-class`, before the parse, and the smoke checks that pinned the old endpoints now pin the new one. The cost of a book is still a query |
| **F12** | **Moot.** Prompt caching was blocked pending a real extraction; the path it would have cached no longer exists. The cost problem it addressed was solved differently: the extractor sends CACHED TEXT rather than a PDF page, which is a fraction of the tokens and needed no cache breakpoint |
| **F16** | **Moot as written, and its real lesson is sharper than it was.** `getExamples` fed the model the two oldest published classes forever; the extractor takes `--like` and defaults to the two most recent. But the first real run showed that examples do not teach NAMING at all — given a shipped class as an example, with the correct catalog names in it and notes saying the book spells them differently, it used the book's spelling every time. The renames are `class-check --remote`'s job, not the prompt's |
| **F18** (#351) | Shipped, then deleted with the skill importer it fixed. The 105 page-less skill rows it was about are still in the catalog and still page-less; nothing new joins them, because nothing writes a skill row through an extraction any more |
| **F19** | **Untaken and now unreachable.** `buildUpdate`'s `COALESCE` lived in `import-engine.js` |

**Two things did NOT go, deliberately.** `docs/plans/05`, `06` and `07` specify
the importers and are left exactly as written — that directory is a record of
decisions, not a description of current code, and deleting the plans would
leave the outcome without the reasoning. And `js/class-template.js`, the
annotated skeleton for writing a class BY HAND, was the one asset the importer
carried that the replacement workflow actually needs; it got a front door
(`scripts/new-class.mjs`) rather than a deletion.

**What has no automated path at all now:** skills, spells, psionic powers and
gear. The extractor covers classes only. In practice that changes nothing —
those catalogs were only ever filled by data script.

**The two tables are still there.** `import_sessions` and `import_staged` are
empty and unused, and dropping them is irreversible, so it is left as its own
decision rather than folded into a deletion PR. Migration 006 stays either way:
it has run, and `drift-check` compares migration FILES against
`schema_migrations`.

**Correction, 2026-08-28: they went too, in that same PR.** The paragraph above
is the plan #360 opened with and is left as written.
`db/migrations/041-drop-import-staging.sql` is applied to production — 41
migrations, 37 live tables, `NO DRIFT` — and both tables were re-checked empty
immediately before the drop. What the paragraph calls "its own decision" was
taken on the same day. Migration `006` is still not deleted, for exactly the
reason given, and the interesting part was the other end: a database built from
`schema.sql` seeds `schema_migrations` with guards on the schema each migration
produced, and `006`'s guard was `import_staged` **existing** — the only thing it
ever created. Left alone, every new environment would have reported itself
un-migrated on two files that have run everywhere, and nothing would have failed
at the moment of the mistake.

## Status, 2026-08-28 — the ledger moved, and the menu is four findings long

`main` is at the merge of PR #360. Since the status above: Wormwood shipped
(#352–#357), **F17** was taken (#358), the backend extractor landed (#359) and
the in-app importer was retired (#360).

**The coverage ledger moved, and nothing on this menu moved it.**
`node scripts/source-coverage.mjs --remote`, 2026-08-28:

| catalog | 2026-08-27 | 2026-08-28 |
|---|---|---|
| classes | 107 / 109 | **124 / 126** |
| gear | 727 / 902 | **800 / 975** |
| skills | 127 / 333 | 130 / 336 |
| spells | **0 / 570** | **37 / 607** |
| psionic powers | 7 / 101 | 7 / 101 |

Wormwood reads **`130 traceable / 0 other`** — the first fully traceable book in
this repo. The 2026-08-27 status says the ledger "will read exactly this until a
session import is run against production". It moved without one, and the
importer it was waiting on no longer exists. Seventeen hand-written data
scripts moved it, each citing its book with a page range: the rule F6 encoded,
which `class-check` reads and which outlived the code F6 shipped in. **Nothing
about tracing a row to a page ever depended on the importer.** The premise that
it did is the tenth error this audit has found in its own text.

Spells went from 0 to 37 for the same reason and the remaining 570 have not
moved: 323 carry no page range, 231 point into `bom`'s six-page cache and 16
cite nothing. That is **F24**, added below, and it is now the largest single
number left in this document.

**Taken since the last status**

| # | PR | what shipped |
|---|---|---|
| F17 | #358 | `source_pdf_dir` on all thirteen registry entries, verified by stat-ing every basename, and a caches-present line both scripts print every run. Print, do not fail — no exit code moved |
| F21, and F10 with it | #362 | The survey moved to `apps/character-creator/docs/surveys/<slug>.md`, **tracked**, and all nine books were backfilled offline. Template, three smoke checks, every instruction repointed. No gate moved, and **no check that a survey exists** |
| F14 | #364 | `.claude/skills/audit-menu/SKILL.md` — the sixth skill, junctioned in the same PR. One skill, no script, **no check**. Four corrections to the finding, including that a grep for `Taken` reports F14 itself as taken |
| F22 | #365 | `occ_group` and `xp_table` documented in `class-import/reference/frontmatter.md`. Documentation only. The enforcing checks are in `regression.mjs`, not smoke; a bad *value* is caught at parse time and a missing key is not |
| F8 | #366 | `~/.claude/agents` junctioned to the repo's directory, so `book-reconcile` resolves from `Downloads`. The per-file alternative needs administrator rights, so the directory shape was forced rather than preferred — and `~/.claude/agents` can now hold nothing that is not in this repo |
| F15 | #367, #368 | Part 1: the heading-anchor rule into `book-survey` §2, and both `parse-pf-spell-*.mjs` marked PF-shaped worked examples. Part 2: `class-check --emit-script <id>`, stdout only, escaping proved lossless. Part 3 deferred - `UI-AUDIT.md` does not exist |
| F23 | #369, #370 | The metered row is split: the format examples are **47.6%** of the input and the whole stable prefix **74.1%**, reconstructed to the exact 21,581 tokens. Step 2: one ephemeral breakpoint after the prefix, prompt byte-identical. The metering had to be fixed with it - cached tokens leave usage.input_tokens, which would have undercounted the row by 74% |
| F24 | #371 | Surveyed. `p.71-72` is Earth Warlock levels 6-7; the 231 rows are all four elemental lists. Book cached from its text layer (360 pp), authority table found at printed 348-352, 209 of 231 resolved to an exact page. **No data changed** - the repair is its own batch |

**Closed without being taken**

| # | why |
|---|---|
| F11 | **Moot.** It proposed a PDF slicer for an uploader that no longer exists; `extract-class.mjs` reads cached text. Nothing in the pipeline slices a PDF. Full note under the finding — its `Adjusted` warning about `pf`'s non-constant offset does **not** die with it |
| F12, F16, F19 | Moot with the importer; recorded in the retirement section above |
| F6, F18 | Shipped, then deleted with the code they fixed |

**Still open: F8, F10, F14, F15.** Four, not nine. F8 (the `book-reconcile`
junction) is unchanged and re-verified this session: `~/.claude/agents` does not
exist, while all five skills are junctioned. F10 has moved without being taken —
**one survey now exists**, `.cache/books/ww/SURVEY.md`, 251 lines, written
during the Wormwood import; the template it asks for still does not, and eight
books still have nothing. F14 and F15 are unchanged, except that F15's part (2)
(`class-check --emit-script`) is now the *only* automation left between a
validated draft and a data script, because the review UI that used to sit there
is gone.

**Corrected the same day (PR #362).** F21 was taken and took F10 with it, so the
paragraph above is a record of what was true when it was written, not the
current list. The survey it describes is now at
`apps/character-creator/docs/surveys/ww.md`, and eight books no longer have
nothing.

**Corrected again (PR #363): the open list is F8, F14, F15, F22, F23, F24 —
six.** *(F14 in #364, F22 in #365, F8 in #366, F15 in #367/#368, F23 in #369/#370, F24 in #371; NONE now — the menu is clear, and the bom citation repair is scoped as its own book batch.)* #362 said three, which counted only the findings the paragraph above
names and silently dropped the three #361 had added minutes earlier in this
same section. The paragraph it was correcting predates F22-F24 and was never
wrong about them; the correction read as a statement of the whole list and was.
**A correction inherits the scope of the sentence it corrects, and saying so is
cheaper than recounting.** This is the audit's eleventh error in its own text
and the first one written by the PR that was fixing the tenth.

Counted by **reading the lines under each heading**, not by grepping for
`Taken`. That grep says F14 is taken; F14's match is the string `**Taken,
2026-08-25**: as proposed` inside backticks, because F14 is the finding that
*describes the outcome-note format*. It is the fourth time that grep has
produced a false finding here. F12, F16 and F19 are closed as moot in the
retirement section rather than under their own headings, which is the same trap
pointing the other way — a scan of the findings alone reports three open that
are not. **No smoke check is added for this**: the outcome notes are prose and
vary in wording by design, so a mechanical reader is exactly the thing that got
it wrong twice on this page.

**Four findings added, 2026-08-28.** All four came out of the last three PRs
rather than out of a fresh pass: **F21** (`SURVEY.md` cannot be committed, which
three Wormwood PRs each reported as an unavoidable deviation), **F22**
(`occ_group` and `xp_table` are documented nowhere and each cost a regression
failure), **F23** (the first metered extraction is on record, which reopens the
question F12 closed), **F24** (`bom`).

**What the retirement did not change, and it is worth saying plainly.** The
pipeline is shorter and every step in it is a command, but the *paid* half is
unchanged in shape: one class per call, examples re-sent every time. What
changed is the price of the input — cached text instead of a page image — and
that is why F12 is moot rather than solved.

## Closed, 2026-08-28 — the menu is clear

**F1 through F24 are all taken, moot, or deferred by their own terms.** The one
deferral is F15 part 3, gated on a `UI-AUDIT.md` that does not exist. Counted by
reading the lines under each heading; the sections above are the record of what
was true when each was written and are left standing.

Twelve PRs closed it out on 2026-08-28: **#362** (F21 with F10), **#363**,
**#364** (F14), **#365** (F22), **#366** (F8), **#367**/**#368** (F15),
**#369**/**#370** (F23), **#371**/**#372** (F24).

**The final ledger** — `node scripts/source-coverage.mjs --remote`, 2026-08-28,
after #372:

| catalog | traceable | of |
|---|---|---|
| classes | 125 | 126 |
| gear | 800 | 975 |
| skills | 130 | 336 |
| spells | **268** | 607 |
| psionic powers | 7 | 101 |

`outside-cache` is **0** across the whole catalog; it was 232 that morning.
Spells were 0 of 570 two days earlier.

**What is left is content, not pipeline, and it is not on this menu.** Rows
citing a book with **no page range at all**, queried directly against production
on 2026-08-28 — this cross-cuts the report's buckets, which score an uncached
book as `not-cached` rather than `no-page-range`, so the totals differ by
design:

| book | rows | cache | what could resolve them |
|---|---|---|---|
| `bom` spells | **177** | 360 pp | the *Index of Rifts Magic*, already parsed |
| `rue` spells / skills / psionics | 118 / 93 / 82 | 382 pp | no authority table found yet; `rue.md` is a backfill stub |
| `rifts-skill-list` skills | 48 | none | a 40 KB PDF F17 verified is on hand — and it is a compilation, not a Palladium book, so re-citing those rows to `rue` may be the better repair |
| `pf` spells | 27 | 339 pp | `parse-pf-spell-index.mjs`, which already exists |
| slug-shaped `source_book` | 13 | — | `palladium-fantasy-core`, `pantheons-of-the-megaverse` — slugs in a title column |

**These are book batches under `book-survey` and `class-import`, deliberately
not findings.** This audit was about the machinery, and the machinery is done:
every step of the runbook is a command, every extraction is metered and cached,
every survey is tracked, and the protocol that governs this file is the sixth
skill. Numbering data repairs as F25+ would reopen a closed record to hold a
backlog that belongs to the books.

**The lesson this file ends on** is F24's, and it is about reading the ledger
above rather than about the pipeline: **a coverage ledger measures whether a
citation can be checked, not whether it is right.** `bom` read `232 / 177`
before the repair and `232 / 177` after it. Both numbers were correct, and
neither was evidence.

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

- **F1** — `source_book` is an uncontrolled vocabulary, and three separate mechanisms parse it — Taken, 2026-08-27 (PR: `books-registry`). `scripts/books.json` is committed: — full text in `INGESTION-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — there is no cache builder for a text-layer book, and six of the eight caches were built by code that no longer exists — Taken, 2026-08-27 (PR: `cache-any-book`). `ocr-book.py` is the one front — full text in `INGESTION-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — a truncated cache is indistinguishable from a complete one, and the guard that exists is fooled by the worse case — Taken, 2026-08-27 (PR: `cache-completeness`). The gate now compares against — full text in `INGESTION-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — the printed→PDF offset is recorded nowhere and re-derived at every use — Taken, 2026-08-27 (PR: `recorded-page-offset`). `class-check --field-sources` — full text in `INGESTION-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — nothing checks that what shipped can still be traced back to a cached page — Taken, 2026-08-27 (PR: `source-coverage`). `scripts/source-coverage.mjs`, — full text in `INGESTION-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — the catalog importers already know the page range and throw it away — Adjusted 2026-08-27, after F1 and F5. Two things moved. The sizing tool — full text in `INGESTION-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — the extraction calls are the only Claude calls in the repo that are not metered — Taken, 2026-08-27 (PR #347). All three call sites meter now, with the — full text in `INGESTION-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — `book-reconcile` has no junction, so phase 5's second reader does not exist where the book work happens — Taken, 2026-08-28 (PR #366). The directory junction, as the proposal — full text in `INGESTION-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — `CLAUDE.md` still tells sessions the skills do not load, which stopped being true on 2026-08-25 — Taken, 2026-08-27 (PR: `claude-md-skills-load`). `CLAUDE.md`'s heading and — full text in `INGESTION-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — `SURVEY.md` exists for none of the eight cached books — Adjusted 2026-08-27, after F5. The coverage line this proposal wants to — full text in `INGESTION-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — slicing a page range out of a PDF is manual, external, and leaves the slices in `Downloads` — Adjusted 2026-08-27, after F4 — and this one is load-bearing. The offset is — full text in `INGESTION-AUDIT.closed.md` under its own `### F11` heading.

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

- **F13** — the diff that decides what gets extracted defaults to the database the repo says is not a mirror — Adjusted 2026-08-27, after F5. `source-coverage.mjs` is a second script — full text in `INGESTION-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — the sixth skill should be the audit-menu protocol, and it is the only one that qualifies — Adjusted 2026-08-27, after F1-F5. The protocol now has nine precedent — full text in `INGESTION-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — what should move between skills and scripts, and what should not become a skill — Adjusted 2026-08-27, after F2 and F4 — part (1) is half done, and its — full text in `INGESTION-AUDIT.closed.md` under its own `### F15` heading.

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

- **F17** — every guard in the pipeline is designed to fail silent when the cache is gone, and the cache is unbacked — Adjusted 2026-08-27, after F1-F5 — one premise is now false and one risk — full text in `INGESTION-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — the skill importer is the one confirm path with no page range in it at all — Taken, 2026-08-27 (PR #351). Implemented as written, and its measurements — full text in `INGESTION-AUDIT.closed.md` under its own `### F18` heading.

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

- **F20** — a stub gets the page of the class that mentioned it, and four rows in production point at the wrong page as a result — Taken, 2026-08-27 (PR #349) — and its headline was false. This finding was — full text in `INGESTION-AUDIT.closed.md` under its own `### F20` heading.

- **F21** — `SURVEY.md` cannot be committed, so the ledger the skills call durable state lives on one machine — Taken, 2026-08-28 (PR #362). As proposed, with F10 folded in. — full text in `INGESTION-AUDIT.closed.md` under its own `### F21` heading.

- **F22** — `occ_group` and `xp_table` are enforced by the test suite and documented nowhere — Taken, 2026-08-28 (PR #365). As proposed. Posture held exactly: — full text in `INGESTION-AUDIT.closed.md` under its own `### F22` heading.

### F23 — the first metered extraction is on record, and it reopens the question F12 closed

**What is true today.** `claude_usage` held zero import rows when F12 was written
and F12 was blocked on that. It holds one now: `cc-extract-class`, **21,581
input / 4,940 output**, the Apok from printed 55, 57 and 59. The cost of a class
is a number rather than an estimate for the first time in this repo's history.

The number is small, and the reason matters: the extractor sends cached **text**
rather than a page image, which is the change that made F12 moot. What it does
**not** do is what F12's first half was about — `--like` re-sends two complete
published class markdown files as format examples on every call, a stable prefix
re-billed per class. On a seventeen-class book that prefix is paid seventeen
times.

**Why it matters, and why this is a finding rather than a fix.** One sample is
not a measurement. What share of those 21,581 tokens is the example block is
knowable — it is two files on disk — and until somebody counts it, "add a cache
breakpoint" is a guess about which half of a number nobody has split.

**Proposal:** two steps, and stop after the first if it says stop. (1) Split the
one row: count the tokens the example block contributes against the cached page
text, from the files themselves, and write the split into this finding. (2) Only
if the examples dominate, put a `cache_control: { type: 'ephemeral' }` breakpoint
at the end of the system prompt and example block in `extract-class.mjs` — the
stable prefix, which already precedes the varying page text. Posture: **measure
first; a cache miss is exactly today's behaviour, so there is nothing to gate
either way.** Do not reason from the old F12 text: its second half described a
retry path that no longer exists.

**Step (1) taken, 2026-08-28 (PR #369). The row is split.** Measured with
`/v1/messages/count_tokens` — free, not metered, nothing spent — over the prompt
`extract-class.mjs` actually builds.

| component | input tokens | share |
|---|---|---|
| system prompt + call overhead | 662 | 3.1% |
| schema + output scaffold | 5,056 | 23.4% |
| **format examples** (`apok`, `monk`) | **10,268** | **47.6%** |
| **stable prefix, total** | **15,986** | **74.1%** |
| varying: page text + title | 5,595 | 25.9% |
| **total** | **21,581** | 100% |

**The reconstruction reproduces the metered row EXACTLY — 21,581, difference
zero.** So this is not a same-shaped estimate; it is the call `claude_usage`
recorded, and the `--like` set nobody wrote down is recoverable by
reconstruction: it was `--like apok,monk` over printed 55, 57 and 59.

**The examples dominate, which is the condition step (2) sets.** They are 47.6%
of the input — nearly double the page text they exist to help read. On a
seventeen-class book the stable prefix is re-billed seventeen times:
**271,762 of ~366,877 input tokens, 74%, is the same bytes over and over.**

Characters would have got the direction right and the number wrong: they say
45.4% examples / 27.3% page text where tokens say 47.6% / 25.9%. OCR noise
tokenizes worse than clean markdown, so the page text is a *smaller* share of
tokens than of characters — the opposite of what the caution about proxies would
lead you to expect, and the reason this was counted rather than estimated.

**One premise of this finding is wrong, and it is the one step (2) rests on.**
The posture says *"a cache miss is exactly today's behaviour, so there is
nothing to gate either way."* It is not. Under Anthropic's published cache
pricing a cache **write** costs **1.25x** a normal input token and a **read**
costs **0.1x**, with a **5-minute** default TTL. So:

| pattern | effective prefix tokens per book |
|---|---|
| today, no caching | 271,762 |
| 17 extractions inside the TTL — 1 write, 16 reads | ~45,600 (**83% cheaper**) |
| every extraction >5 min apart — 17 writes | ~339,700 (**25% DEARER**) |

A miss is today's behaviour **plus 25%**, not today's behaviour. The change is
therefore a bet on extractions being *batched*, and the Wormwood ledger says
they were — but it is a bet, and this finding says there is nothing to decide.
There is.

**Step (2) is NOT taken here.** Its stated trigger is met and its stated
risk-free-ness is false, so it is a decision rather than a mechanical follow-on,
and the audit protocol says not to substitute a different scope quietly. Two
things a step (2) PR would also have to handle that this finding does not
mention: the user prompt is **one text block**, so a breakpoint means splitting
it into a cached block and a varying block rather than adding a field; and the
page corpus currently arrives through `buildUserPrompt`'s **`hints` parameter**,
appended last under a `## Operator hints` heading — which is why the stable part
does precede it, but is also a misnomer worth fixing in the same pass.

**Step (2) taken, 2026-08-28 (PR #370), on Nate's word after step (1) reported
the corrected economics.** One `cache_control: { type: 'ephemeral' }` breakpoint
at the end of the stable prefix. The cached span runs from the start of the
request through that block, so it covers the system prompt, the schema and the
format examples; the page text follows in its own uncached block.

**The prompt did not change by a byte.** `buildUserPromptParts` returns
`{ stable, varying }` and `buildUserPrompt` is now those two joined, so the
split is a cut rather than a rewrite; `extract-class` **asserts the identity
before it sends anything** and dies if a future edit moves the boundary instead
of moving the cut. Verified with `count_tokens`: the two-block request is
accepted, costs the same **21,581** input tokens as the single block it
replaces, and the cacheable prefix is **15,986** — comfortably over the
1,024-token minimum.

**The metering had to be fixed in the same PR, and this is the part with teeth.**
With caching on, `usage.input_tokens` counts **only the uncached remainder** —
the cached span comes back as `cache_creation_input_tokens` or
`cache_read_input_tokens` instead. Nothing in this repo read either field.
Recording `input_tokens` alone would have dropped this row from 21,581 to
**~5,600 the moment the breakpoint landed**: a silent **74% undercount**, in the
very ledger step (1) used to justify the breakpoint, and it would have looked
like a spectacular saving. The insert now records the sum, so the column keeps
meaning what it always meant — input tokens this call processed.

**What is NOT recorded, and it needs a decision.** `claude_usage` has no column
for the write/read split, so the table still cannot express **cost**: a cached
read bills at 0.1x and a write at 1.25x, and a row reading 21,581 is now three
different prices depending on which it was. The run prints the breakdown and
says HIT or MISS; the table cannot hold it. Two columns
(`cache_write_tokens`, `cache_read_tokens`) would fix it — a schema change,
five places per the `schema-change` skill, and deliberately **not** smuggled
into a finding whose posture is a prompt breakpoint. **Worth its own number if
you want the ledger to answer cost rather than volume.**

**What remains unproven.** That the cache actually engages in production. Every
check above is free — `count_tokens` and a byte-identity assertion — and proving
a hit costs two real extractions back to back. The next real extraction proves
it either way and now prints which it was, so the evidence arrives with the next
class rather than needing a call spent on it here.

- **F24** — `bom` is 232 of the untraceable rows, its cache is six pages, and nobody has opened it — Taken, 2026-08-28 (PR #371) — surveyed, and the proposal is rewritten below — full text in `INGESTION-AUDIT.closed.md` under its own `### F24` heading.

- **F25** — four W.P. rows cite RUE for skills RUE replaced, and the catalog already holds the replacements — Taken, 2026-09-03 (PR #618), as REPOINT rather than retire. Nate's call, on — full text in `INGESTION-AUDIT.closed.md` under its own `### F25` heading.

## Adding book N — the runbook

**Rewritten 2026-08-28 for the pipeline that exists**, and **steps 6 and 12
became real later the same day** when F21 took F10 with it: the template exists
at `.claude/skills/book-survey/reference/SURVEY.md` and the survey is tracked at
`apps/character-creator/docs/surveys/<slug>.md`, so the ledger line goes in the
same PR as the work rather than waiting on a merge it could never be part of.
Steps 0-5, 7 and 8 were already real: F1-F5 and F13 are taken, and step 7 is
`extract-class.mjs` rather than an upload, which is why F11 is closed.
**Nothing in this runbook is a forecast any longer**: step 9's `--emit-script`
shipped with F15 part 2 (#368), and step 11's `book-reconcile` resolves from
`Downloads` since F8 junctioned the agents directory (#366).

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
6. **(once)** Write `apps/character-creator/docs/surveys/<slug>.md` from
   `.claude/skills/book-survey/reference/SURVEY.md`: inventory, authority pages,
   the offset **read from `scripts/books.json`**, the diff with its hand-checked
   gaps, the extraction plan, and an empty ledger. It is tracked, so it goes in
   a commit like anything else — and it states facts about the book and quotes
   no prose from it. **Get agreement on this before spending anything.**
7. Per class — `node scripts/extract-class.mjs --book <slug> --pages
   <printed list or range> --like <id,id> --out draft.md`. Printed pages, not
   PDF pages; it reads the cache, refuses any page under 400 bytes as a
   full-page illustration and names it, and meters the call to `claude_usage`
   before parsing. Nothing is uploaded and nothing is sliced.
8. `node scripts/class-check.mjs draft.md --remote` until it reads `ready`, then
   `--field-sources` and **read the continuation block** — it uses the recorded
   offset and warns if live detection disagrees. **`--remote` is required, not
   optional.** The first real extraction was given the shipped Apok as an
   example, with the correct catalog names in it and notes saying the book
   spells them differently, and it used the book's spelling every time. Examples
   teach shape; they do not teach naming, and this step is where the renames are
   caught.
9. `node scripts/class-check.mjs draft.md --emit-script <id> >
   apps/character-creator/db/add-<id>-class.sql`, then run `class-check` on the
   `.sql` so the ASCII/CRLF pre-flight fires against the real artifact.
10. `node scripts/d1-apply.mjs --local …`, ask before `--remote`, then smoke,
    `drift-check --remote`, PR per `ship-pr`.
11. Hand the extracted rows to the `book-reconcile` subagent before the data
    script, not after. Every number read twice, from two places.
12. Append one ledger line to `docs/surveys/<slug>.md` **in the same PR as the
    work** — the file is tracked, so it no longer has to wait for the merge.
    **Start a fresh session every 2–4 PRs**, booted from that file plus
    `git log --oneline -15`.

Steps 0–6 are free and are done once. Step 7 is the only step that costs money,
and as of 2026-08-28 it costs a known one: 21,581 input / 4,940 output for the
first class extracted this way (F23). **74% of that input is a stable prefix**
and it is cached since F23 step 2 — on a **5-minute** tier, so **extract a
book's classes back to back**. Inside the window the prefix bills at 0.1x;
further apart than that, each call pays 1.25x to refill it and costs *more* than
no caching at all. The run prints HIT or MISS.
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

---

## Filed by META-AUDIT A16, 2026-09-06

- **F26** — low — the 105 page-less skill rows have never had a number, and the backlog grew rather than shrank — Taken, 2026-09-06 as option (a) — reconcile, then accept and document — with — full text in `INGESTION-AUDIT.closed.md` under its own `### F26` heading.

## Filed 2026-09-06, from the catalog's own duplicate suggestions

Three findings turned up by reading the `Find duplicates` panel on production —
the skills catalog reports **48 pairs: 2 `certain`, 0 `likely`, 46 `contains`**
(`GET /api/character-creator/catalogs/duplicates?catalog=skills`, 2026-09-06).
Reading all 48 is what produced these.

**None is taken by the PR that filed it.**

- **F27** — medium — the `certain` tier's "no false positives" claim is false, and the mechanism is the bracket-stripping the code documents two lines above it — Taken, 2026-09-06. Posture held: this changes which TIER a pair lands in, and — full text in `INGESTION-AUDIT.closed.md` under its own `### F27` heading.

- **F28** — low — two `Law` rows, and the one 62 classes cite is the one with no book — Taken, 2026-09-06 (`zzzzzz-ingestion-f28-law-canonical.sql`). Posture held: — full text in `INGESTION-AUDIT.closed.md` under its own `### F28` heading.

- **F29** — high — `Find duplicates` cannot run on the gear catalog, and never could at this size — Taken, 2026-09-06. Posture held: performance only — identical output on every — full text in `INGESTION-AUDIT.closed.md` under its own `### F29` heading.

## Filed 2026-09-06, from what F29 made visible

`F29` ended by saying gear now returns **511 pairs, 34 of them `certain`**, and
that the button finally has something behind it. Reading those 34 is what
produced these. **None is taken by the PR that filed it.**

The 34 split three ways, and only one of them is a duplicate:

| shape | count | what it is |
|---|---|---|
| bare vs qualified — `Cape` / `Cape (Long)`, `Plate Armor` / `(Half Suit)` | **27** | distinct items |
| cross-system — `Large sack` `palladium-fantasy` vs `Large Sack` `rifts` | **18** | deliberate, one row per book |
| same system, same shape, genuinely one row twice | **1** | `F32` |

*(The two shapes overlap: 15 pairs are both.)*

- **F30** — medium — `F27`'s rule was built on one instance and gear gives 27 counterexamples — Adjusted 2026-09-06 and RE-SCOPED before being taken, on Nate's word. The — full text in `INGESTION-AUDIT.closed.md` under its own `### F30` heading.

- **F31** — medium — `findDuplicates` has no `system` guard, and gear is duplicated across systems on purpose — Taken, 2026-09-06. Posture held: one condition mirroring the guard beside it. — full text in `INGESTION-AUDIT.closed.md` under its own `### F31` heading.

## Filed 2026-09-06, found while measuring F30

Both are `F32`'s shape — a duplicate somebody noticed and wrote into a row's
`description`, where nothing reads it. **Neither is taken by the PR that filed
it.**

- **F33** — low — `Gas Mask` and `Gas Mask (human-size)` are the same mask — Taken, 2026-09-06 (`zzzzzz-ingestion-f33-gas-mask.sql`), and it does one thing — full text in `INGESTION-AUDIT.closed.md` under its own `### F33` heading.

- **F34** — low — `Gas Mask and Air Filter` exists twice, and the note saying so is itself wrong — Adjusted 2026-09-06 and RE-SCOPED before being taken. This finding read the — full text in `INGESTION-AUDIT.closed.md` under its own `### F34` heading.

## Filed 2026-09-19, from F23's own note

### F35 — low — `claude_usage` records how many tokens a call processed, and cannot say what it cost

**Filed on Nate's word, 2026-09-19**, from the paragraph in `F23` that ends
*"Worth its own number if you want the ledger to answer cost rather than
volume"* (this file, under the `F23` heading). He asked for the number and for
the columns that paragraph names. Filed here and taken in a separate PR, as
`audit-menu` → *When not to* requires.

**What is true today, each read 2026-09-19.**

- `claude_usage` (`db/schema.sql:62`) has `input_tokens` and `output_tokens` and
  nothing about the prompt cache.
- Three places write it. `scripts/extract-class.mjs:307` stores `input_tokens`
  as the SUM of fresh, cache-write and cache-read tokens, and prints the split
  to the console, where nothing keeps it. `functions/api/_lib/claude-client.js:117`
  (through `recordUsage`, whose three callers are the Pages proxy, the campaign Ask
  and the NPC sweep - `git grep -n "recordUsage(" -- functions`) and `workers/pick3cut5-room/src/anthropic.js:69`
  store `usage.input_tokens` alone, which counts only the UNCACHED part of a
  prompt.
- Only the extractor sends a cache breakpoint: `git grep -n cache_control -- functions workers apps scripts`
  returns `scripts/extract-class.mjs:266` and no other code, 2026-09-19. So the
  other two writers' rows are complete today, and would undercount the day
  either gained one.
- Production holds **28 rows**, and **none** involved the cache.
  (`q.mjs --remote`, grouped by `endpoint`, 2026-09-19.) The one extractor row,
  `cc-extract-class` at 21,581 input tokens, was written at 00:23:40 UTC on
  2026-08-28 - about five hours BEFORE the breakpoint existed: commit `4f5a249`,
  2026-08-28 01:31 -0400 (`git log -S cache_control -- scripts/extract-class.mjs`).
  `F23` says the same of that row. This line said "one" when first written, and
  the take-time premise audit corrected it before the finding merged.

**Why it matters, as `F23` put it.** A cached read bills at 0.1x and a cache
write at 1.25x, so an `input_tokens` of 21,581 is three different prices and the
row cannot say which. The table answers *how much* and not *how much it cost*.

**Proposal:** a migration adding two nullable INTEGER columns to `claude_usage`,
`cache_write_tokens` and `cache_read_tokens`, taken from the response's
`usage.cache_creation_input_tokens` and `usage.cache_read_input_tokens`. Both
Pages-side writers fill them: the extractor (which already computes both) and
`recordUsage` in `claude-client.js`. That second writer also sums them into
`input_tokens` the way the extractor does, so the column means the same thing
from every writer. NULL means the response carried no figure; 0 means it said
zero. `SETUP.md`'s spend queries (around line 545) gain the two columns. The
five schema places per the `schema-change` skill. **Evidence:** the three
writers and the schema were read 2026-09-19; the row counts are from
`q.mjs --remote` the same day. **Not measured:** whether the proxy's callers
will ever send a breakpoint.

**Posture: record only.** Nothing reads these on a request path, nothing caps
or blocks on them, and `input_tokens` keeps its current meaning. A missing
column must not break a call: both writers are fail-open already
(`claude-client.js:97`, *"metering that can break the call it measures"*),
and that stays.

**Not proposed: the Pick 3 Cut 5 Worker.** It sends no breakpoint, so its
rows are complete as they stand. And a merge does not deploy it — the
`pick3cut5` skill and `SETUP.md` say it ships by hand — so changing it costs a
separate deploy for no row that exists. If it ever gains a breakpoint, this
finding's proposal applies to it unchanged. This is a deliberate drop, not a
deferral.

**Confidence: high** that the table cannot express cost, because the schema has
no such column. **Low on value**: no row in production has ever carried cached
tokens, so the columns record almost nothing until extraction runs regularly
again. What would raise it: a second book extracted through
`extract-class.mjs`, or a breakpoint added to any proxy caller.

**Ongoing cost:** two columns in five places, once, and every future writer of
`claude_usage` has two more fields to fill, each of which fails silent (NULL)
when forgotten. **The case for declining** is that no row in the table's life
would have used them. Nate has asked for it anyway, on the grounds `F23` gives:
the ledger should answer cost.
