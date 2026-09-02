# The prompts that produced this repo

Briefs that each produced something committed. They lived only in
`C:\Users\natha\Downloads`, untracked, beside PDFs and 3MF files, and one of
them (`REVIEW-BRIEF.md`) had already been rescued once from a session-keyed temp
directory that a cleanup would have emptied.

The outputs were all versioned. The instructions that produced them were not.
That is the whole reason this directory exists — `HEALTH-AUDIT.md` F3.

**Three more arrived on 2026-09-02**, hours after this directory was created:
`CHANGE-PLAN.md`, `BOOK-INGEST-PROMPT.md` and `SKILLAUDITPROMPT.md`. All three
existed in `Downloads` that morning and were missed — `SKILL-AUDIT.md` F19. The
largest by output was `CHANGE-PLAN.md`, which drove seventeen PRs. **An archive
assembled by hand is missing something the day it lands**, which is worth knowing
before trusting this list to be complete.

**These are records, not documents.** Do not edit them to match what happened.
A brief that asked for the wrong thing, or named a file that shipped under a
different name, is more useful left as it was written: the difference between
what was asked and what was built is the interesting part, and the audit files
themselves already carry the reasoning for each divergence.

### One of them is not a record

**`BOOK-INGEST-PROMPT.md` is a TEMPLATE**, and the rule above does not fit it. It
holds three prompts — kickoff, one per book, and a planning pass — and prompt B
was run seven times, once per book in the 2026-08-28 batch. It is written to be
run again.

That makes it the only file here that can be *wrong* rather than merely
historical, and it already is: it opens by telling the reader to read the repo's
`CLAUDE.md` because it does not auto-load from `Downloads` — a workaround that
`SKILL-AUDIT.md` F11 replaced with `~/.claude/CLAUDE.md` on 2026-09-02. Its
durable content moved into `book-survey` §8 under F17.

**If you run it, read `book-survey` first and treat this as the roster.** If you
edit it, it stops being a record — which is fine for this one file and for no
other here.

The copies in `Downloads` were left in place rather than deleted.

## What each one produced

Build briefs, in rough order:

| brief | produced |
|---|---|
| `claude-code-phase1-prompt.md` | the character creator's first build — the core data model |
| `pick3cut5-claude-code-prompt.md` | `apps/pick3cut5/` and `workers/pick3cut5-room/` |
| `filament-forge-standardization-prompt.md` | FilamentForge onto D1 with the `ff_` prefix |
| `media-vault-standardization-prompt.md` | MediaVault onto D1 |
| `gm-grants-prompt.md` | `apps/character-creator/docs/plans/19-gm-grants.md`, then the first grants slice |
| `surveycommittableprompt.md` | `apps/character-creator/docs/surveys/` — one file per cached sourcebook |
| `setup-v2-rewrite-prompt.md` | `SETUP.md` v2, and `SETUP-v2-CHANGES.md` as its findings menu |
| `CHANGE-PLAN.md` | the Rust & Ash redesign — nine phases plus a module extraction and the landing page, PRs #484-#500 |
| `BOOK-INGEST-PROMPT.md` | the seven-book batch of 2026-08-28 — **a template, not a record**, see above |

Audit briefs:

| brief | produced |
|---|---|
| `efficiency-audit-prompt.md` | `EFFICIENCY-AUDIT.md` |
| `class-audit-prompt.md` | `apps/character-creator/CLASS-AUDIT.md` |
| `whatbrokeevalprompt.md` | `apps/character-creator/REBUILD-AUDIT.md` |
| `media-vault-isbn-bulk-research-prompt.md` | `apps/media-vault/ISBN-AUDIT.md` and `apps/media-vault/BULK-AUDIT.md` |
| `ui-audit-prompt.md` | `apps/character-creator/UI-AUDIT.md` |
| `n-findings-prompt.md` | the `N` series in `apps/character-creator/REDESIGN-AUDIT.md` |
| `health-audit-prompt.md` | `HEALTH-AUDIT.md`, both halves |
| `REVIEW-BRIEF.md` | `apps/character-creator/INGESTION-AUDIT.md` — tracks E and F only |
| `SKILLAUDITPROMPT.md` | `SKILL-AUDIT.md` — the instruction-layer audit, and this row |

## Three of them named a file that shipped under a different name

Worth knowing before searching for an artefact by the name its brief used.

- **`whatbrokeevalprompt.md`** offered `apps/character-creator/DATA-SCRIPT-AUDIT.md`
  *"(or a name you argue for)"*. It shipped as `REBUILD-AUDIT.md`, and that
  file's own header carries the argument: the subject turned out not to be the
  data scripts.
- **`media-vault-isbn-bulk-research-prompt.md`** asked for
  `MEDIA-VAULT-ISBN-AUDIT.md` and `MEDIA-VAULT-BULK-AUDIT.md`. They shipped as
  `ISBN-AUDIT.md` and `BULK-AUDIT.md` under `apps/media-vault/`.
- **`REVIEW-BRIEF.md`** planned seven tracks across three sessions and only one
  session ran. Tracks E and F became `INGESTION-AUDIT.md`. Track G was
  superseded by `ui-audit-prompt.md`, and tracks A–D — which would have been
  `HEALTH-AUDIT.md` — were superseded by `health-audit-prompt.md`, written from
  scratch rather than reused. **Its baseline numbers are stale** (recorded
  against `main` @ `ad6b818`); read it for what was scoped, never for a value.

## One duplicate was resolved

`setup-v2-rewrite-prompt.md` and `setupv2rewriteprompt.md` were byte-identical
in `Downloads`. Only the hyphenated name is here. That is what an unmanaged
directory does over time, and the second-best argument for this one.

## Nothing requires a future prompt to land here

This is an archive, not a process. Copy a brief in when it produces something
worth keeping, and only then.
