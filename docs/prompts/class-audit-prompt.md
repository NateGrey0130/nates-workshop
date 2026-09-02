Audit every imported class — all O.C.C.s and R.C.C.s — in the character creator against the source books. Repo is `C:\Users\natha\Projects\nates-apps`. This is a read-only investigation: produce a findings menu, apply nothing until I take findings one by one.

## Setup

Read the repo `CLAUDE.md` first, then `apps/character-creator/AUDIT.md` (note its opening finding: the previous audit brief was stale — start from what the repo is now, not what you remember it being). Load the repo's `class-import` and `claim-audit` skills before judging any class. Audit against production D1 with `--remote` — local D1 is known-stale. Record the baseline (class count, smoke suite pass) before anything else.

## Step 1 — build a provenance roster

Pull every row from `imported_classes` in production. For each class, establish:

- the `source_book` line from its markdown frontmatter (book + page range)
- whether a repo data script exists in `apps/character-creator/db/add-*-class.sql`, or whether it only exists in D1 (UI-era import; some have only a `fix-*` script — Cyber-Knight is one)
- whether its book has an OCR cache under `.cache/books/` (currently `rue`, `pf`, `bom`)
- when it entered the repo (git history of its script)

Tier the audit from that roster:

- **Tier 1 — full re-verification.** Classes imported early from a screenshot or a few-page PDF excerpt: no OCR cache for their book, and/or no `add-*-class.sql`, and/or predating the class-check/book-survey tooling. Every field gets checked against the actual book. If the book PDF is not on this machine, do NOT guess or trust the original extraction — list the class and the specific unverifiable fields under a **"Blocked: need book"** section so I can supply pages. Never commit book text; the OCR cache is local-only by design.
- **Tier 2 — cited spot-check.** Classes whose book is cached: run `scripts/class-check.mjs` per class and use its citation printing to confirm each frontmatter value against the cached page text. Cheap — do all of them. Batch by book (survey a book's slice once, audit all its classes together), not class-by-class page flipping.

## Step 2 — what to check per class

The defect patterns that have actually bitten, in rough priority:

- **Page-break splices**: a value read from a paragraph that continued onto the next page (this put two wrong `starting_money` figures into live Juicer Uprising data; also hit Body Fixer and Wilderness Scout). Any field whose source span ends near a page bottom deserves the next page's opening lines.
- **Skill bases and names**: the convention is catalog base + printed bonus already summed, and names canonicalized through `catalog_redirects`. Check both directions — a base that's just the printed bonus, or a raw name that dodges a restriction match.
- **Bonuses and saves** against the printed tables (the Warrior Monk disease-save class of bug).
- **Selections**: skill/spell/psionic allowances, per-level schedules, choice options — the "phantom choice options" and "dead skill restrictions" bug families.
- **Gear, starting money, cybernetics, ISP/PPE bases**, and `source_book` page ranges themselves (printed-page vs PDF-page offset).
- **Do NOT flag zero related/secondary skills on an R.C.C.** — those come from the paired O.C.C.; zero is correct, not a gap. This has been falsely flagged three times already.

## Step 3 — re-review old gaps and assumptions against the current schema

Many classes were imported when the app couldn't express mechanics it can now (per-level spell schedules, dice attribute bonuses, group bonuses, category and race/O.C.C. restrictions, the gear system, new bonus keys — see the `apply-*` and `backfill-*` script history). Sweep for assumptions recorded then and never revisited:

- notes fields in class markdown that stash a real mechanic in prose ("+15% held in a note", "handled manually")
- comments in `add-*` / `fix-*` scripts saying the schema can't express something, or that a value was assumed/estimated
- `apps/character-creator/docs/rules-audit.md` and the README's known-limitations section
- whatever the class-import skill's "mechanic the app cannot express yet" guidance lists as previously-deferred

For each: state whether the current `db/schema.sql` + validator can now express it, and if so, what the data migration would look like. A limitation note that is no longer true is itself a finding.

## Deliverable

Write `apps/character-creator/CLASS-AUDIT.md` in the same shape as `AUDIT.md`: numbered findings (most severe first), each with the class, the field, what the book says (page citation), what production says, and the proposed fix as a data script sketch. Separate sections for **verified-clean classes** (say so explicitly, per tier), **Blocked: need book**, and the **schema-can-now-express** review from Step 3. Findings are a menu — one PR per taken finding, `Taken` notes appended under each as they land. Don't change any data or docs during the audit itself; quote counts only if you verified them against `--remote`.
