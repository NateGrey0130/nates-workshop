# Task: make `SURVEY.md` a committable artifact — INGESTION-AUDIT F21

Prerequisite: PR #361 — the audit re-status that added F21 — must be merged first.

Repo: `C:\Users\natha\Projects\nates-apps` (sessions start in `Downloads`; read
`CLAUDE.md` at the repo root before touching D1 or wrangler). One PR, taken the
`audit-proposals-taken-one-by-one` way: implement as written, append a `Taken`
note under the finding, merge on my word.

## The failure, stated

Three separate Wormwood PRs (#352–#357) reported the same thing as a deviation
they could not avoid: *"the `SURVEY.md` ledger row is appended, but `.cache/` is
gitignored (`.gitignore:24`), so it's untracked and cannot be in any commit."*

The instructions that ask for it are live and specific:

- `.claude/skills/book-survey/SKILL.md:505` — write the survey to
  `.cache/books/<slug>/SURVEY.md`
- `SKILL.md:519` — start a fresh session every 2–4 PRs, **booted from it**
- `SKILL.md:528` — *"all of it in `.cache/books/<slug>/SURVEY.md`, not just said
  in chat"* — the definition of "surveyed"
- `.claude/skills/class-import/SKILL.md:69` — append a ledger line there when a
  PR merges
- `EFFICIENCY-AUDIT.md` F1 (**Taken, 2026-08-25**) measured the fresh-session
  discipline this file carries at a **2–7× token saving per book**

So the repo's own durable state for a book import lives in exactly one
gitignored directory, on one machine, with no backup — which is
`INGESTION-AUDIT` **F17**'s concern aimed at the survey rather than at the OCR
text. F17 shipped a recovery record for the *caches* and deliberately did not
touch this.

**Do not treat the location as an oversight.** `EFFICIENCY-AUDIT` F1 put the
file in `.cache/` on purpose — *"local beside the OCR cache it quotes, so no
commercial text enters the repo."* That reason is real and it is the thing this
PR has to answer, not route around.

## What the evidence actually says about that reason

Nine caches exist (`bom cb1 dag fom ju pf potm rue ww`). **One survey exists**:
`.cache/books/ww/SURVEY.md`, 251 lines, written during the Wormwood import.
Read it first — it is the only worked example and the template has to match it.

Of those 251 lines, **three** are blockquoted book prose (the p.157 rule about
which classes are playable). Everything else is *facts about* the book: slug,
source PDF, page offset and how it was verified, authority-table page numbers,
an inventory, class lists with page ranges, the catalog diff with its
hand-checked false gaps, the extraction plan, and a per-PR ledger. Page numbers,
counts, offsets and class names are facts; the three blockquotes are the only
thing F1's rule was protecting against.

## What to do

**1. Move the survey to a tracked path.** `apps/character-creator/docs/surveys/<slug>.md`
— beside `importing-from-pdfs.md`, in the app whose pipeline it serves. One home,
not two: do not leave a copy in `.cache/`, and do not try to make git track a
path under `.cache/` with `.gitignore` negations (a re-included file under an
excluded *directory* is a known git footgun and the pattern stack needed is six
lines of unreadable precedence).

**2. Carry the rule that makes it safe.** The tracked survey states facts about
a book and **quotes no prose from it**. Where the ww survey blockquotes p.157,
paraphrase it and cite the page — the fact is *which classes the book excludes*,
and that survives paraphrase intact. Put the rule in the template header and in
`book-survey` §7 in its own voice, with F1's reasoning as the why.

**3. Add the template F10 has been asking for.** `.claude/skills/book-survey/reference/SURVEY.md`
(that directory does not exist yet; `class-import/reference/` is the shape to
copy). Seven §7 headings as empty sections, one worked ledger line, and the
no-quoting rule at the top. Per F10's `Adjusted 2026-08-27` note the offset
section says **read it from `scripts/books.json`**, not "re-derive it", and the
"what remains" section is a **paste from `source-coverage.mjs`**, not a count.

**4. Backfill all nine, offline.** Everything needed is already in the repo:
slug, `source_pdf` and `page_offset` from `scripts/books.json`; `text_layer`,
`cached_pages`, `cached_range`, `printed_pages` from each cache manifest;
per-book traceable/other from `node scripts/source-coverage.mjs --remote`; and
the shipped-content ledger reconstructed from `git log --oneline`. `ww` is a
*relocation and a redaction*, not a rewrite — keep its 251 lines. The other
eight are thin by construction, and that is correct: a thin true survey beats no
file, and the next session to open that book fills it in.

Two numbers in F10's text are stale and must not be copied: `fom` is 161 pages
(not 73) and `potm` is 210 (not 202). `bom` is the one partial cache — 6 pages
of a 409-row book — and its survey should say so loudly, because 231 spells cite
`Rifts Book of Magic p.71-72` and that is the largest untraceable block in the
catalog.

**5. Repoint every instruction.** `book-survey` §7 and its "what surveyed means"
list, `book-survey`'s fresh-session paragraph, `class-import:69`, the
`INGESTION-AUDIT` runbook steps 6 and 12, and any README/CLAUDE.md file map that
gains a directory. Grep `SURVEY.md` repo-wide; there were 21 hits before this
change.

**6. Pin it, but pin the right thing.** Smoke checks:
- every directory in `.cache/books/` that is a registered book slug has a survey
  in `docs/surveys/` — **NO.** Do not add this. The caches are gitignored and a
  clean clone has none, so the check could only fail on the machines that matter
  (F10 says this explicitly).
- **DO** check that every `docs/surveys/*.md` names a slug that exists in
  `scripts/books.json`, and that no survey file contains a markdown blockquote —
  the crude proxy for verbatim prose, and the only mechanical grip on the rule
  in step 2.
- **DO** check that whatever file map lists the docs directory names it.

Pin the *current* claim, never the stale phrase you are replacing — a correction
that quotes the old wording defeats a grep for the old wording (F7 hit this).

## Posture

**Relocation plus a one-time backfill. No gate moves, no exit code changes, no
check that a survey exists.** The point is that the ledger the skills call
durable state can survive this machine; it is not to start enforcing surveys.

## Before you open the PR

- `node apps/character-creator/test/smoke.mjs`
- `node scripts/drift-check.mjs --remote` (no schema in this PR — it should say
  `NO DRIFT` and you are confirming you did not disturb it)
- Confirm `git status` shows the nine survey files as **tracked additions**.
  That is the whole point of the PR; if they are still ignored, nothing shipped.
- Follow the `ship-pr` skill. No D1 to apply — this PR is docs and skills only.

## Then

Append **`Taken, <date> (PR #N)`** under `### F21` in
`apps/character-creator/INGESTION-AUDIT.md`, in the same PR, in the shape the
other Taken notes use — including anything you found that contradicts this
brief. Every finding taken so far has turned up an error in its own premises,
and reporting those is half the value of taking it.
