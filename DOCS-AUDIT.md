# Documentation audit, 2026-08-25

> **All 5 findings (`D1`–`D5`) are closed**, re-verified on 2026-09-02. D1–D3 carry
> `Taken` notes, **D5 is WITHDRAWN** and deliberately left in place because how
> it went wrong is the subject of the audit.
>
> **The one that misreads:** `D4` is an information item whose closure is the
> words *"No action proposed."* — which wrap across a line break, so a search for
> that phrase does not find it.

Read-only pass over every `.md` in the repo — 38 files, ~11,600 lines — asking
what has gone stale, what points at nothing, and what records a decision that
has since been reversed. Checked against `main` @ the merge of #268, production
D1 (`--remote`, per the repo's own rule), and a clean smoke run.

**Five things were fixed in the same PR as this file** because they were
unambiguous rot in *live instructions*. Everything below the fold is a finding
with a proposal, for you to take or decline one at a time.

> **The character-creator README was split on 2026-08-26** (PR #309) into an
> 827-line spine plus eleven topic files under `apps/character-creator/docs/`.
> No section was renamed, so every section *name* below still resolves — but
> the `README.md` paths and `line ~NNN` references in this document are as of
> the audit date above, and several sections cited here now live in `docs/`.
> Find one by name rather than by number:
>
> ```bash
> node scripts/readme-section.mjs "Class definition format"
> ```
>
> It searches README.md and every `docs/*.md`, and prints the file and the line
> range. The file and line counts in the paragraph above are also pre-split:
> the same prose is spread over more, smaller files now. Count them when you
> need the number — quoting it here is the mistake this audit is about.

## The pattern worth naming

Almost every real finding is the same mistake: **a doc quoting a number that
moves.** Not a wrong number — a number that was right when written and cannot
stay right.

`ship-pr` quoted the README's pinned row verbatim (`| classes (published, live)
| 76 |`) as an illustration of what to update. `claim-audit` sized the README at
"~4,600 lines" and the class markdown at "~190 sentences over 76 classes". By
this morning those were 88 classes and 5,600+ lines — and `claim-audit` is *the
skill about stale claims*.

The fix applied in all four places was the same: **describe the row, not its
value.** The tests already print the real numbers on failure, which is where a
reader should get them.

## Fixed here

| what | where | was |
|---|---|---|
| Quoted the pinned counts verbatim | `ship-pr/SKILL.md` | `76` / "Fifty-three of seventy-six" |
| Sized the README and class markdown | `claim-audit/SKILL.md` | "~4,600 lines", "~190 over 76 classes" |
| Named a class count in a sweep result | `class-import/SKILL.md` | "all 83 published classes" — written last night, stale by morning |
| Pointed at a deleted script copy | `README.md` (MOS section) | `.claude/skills/book-survey/reference/read-columns.py` |
| Counted the plans in a heading | `docs/plans/README.md` | "All twelve PRs" against a table of 18 plans and PR #228 |

## Findings

### D1 — low — six plan docs point at files that moved or were renamed

`docs/plans/` 04, 06 and 07 cite
`functions/api/character-creator/_lib/catalog-fields.js`; the file lives at
`apps/character-creator/js/catalog-fields.js`. Plan 15 and `AUDIT.md` cite
`_lib/claude-client.js` and `access.js`, both now under
`functions/api/_lib/`. Plan 17 cites `db/migrations/034-enchantments.sql` (it is
`035-`). Plan 18 cites `add-pf-xp-tables.sql` (it is
`zz-pf-experience-tables.sql`).

**This may be correct as written.** `docs/plans/README.md` states outright that
a plan "describes the code as it stood the day the plan was written", and
`AUDIT.md` is dated in its own title. A dated record pointing at where a file
*was* is history, not rot.

**Proposal**: leave the plan bodies alone, and add one line to
`docs/plans/README.md` saying that paths inside plans are as-of-writing and may
have moved — turning a reader's "this is wrong" into "this is old", which is
the actual truth. Decline if you would rather the plans stay untouched.

- **Taken, 2026-08-25**: as proposed. One paragraph added to
  `docs/plans/README.md`, next to the existing **As built** note, and no plan
  body touched. All six citations were re-checked first and all six still
  read as described — but two of them are not renames at all. Plan 17's
  `034-enchantments.sql` shipped as `035-` because `034-gear-sdc.sql` took
  the number the plan itself had recommended doing first, and Plan 18's
  `add-pf-xp-tables.sql` shipped as `zz-pf-experience-tables.sql` because
  **that plan works out the reason on its own page** — a script that rewrites
  class markdown must sort after every script that writes those rows, so it
  wants an `apply-` or `zz-` prefix. The plan predicted its own filename
  change. That is the strongest possible argument for leaving the bodies
  alone, and the added paragraph says so: a plan naming a migration number or
  a filename is naming what it *proposed*.

  The paragraph deliberately names **no paths**. Enumerating the six would
  have recreated the exact rot this audit is about — a doc quoting values
  that move — so it describes the rule and points at `git log --follow`
  instead.

### D2 — low — `class-import/SKILL.md` cites a file that no longer exists

The sort-order warning tells the story of `fix-long-bowman-armor.sql` sorting
before `fix-long-bowman.sql` and being overwritten on every rebuild. Only
`fix-long-bowman.sql` exists now — the armor file was resolved away, which is
the happy ending the anecdote does not mention.

A reader who checks will find nothing and may doubt the whole warning, which
would be a shame: the hazard is real and the `zz-` convention exists because of
it.

**Proposal**: add four words — "since folded away" — so the anecdote reads as
history rather than as a pointer. The `(ls … | sort | grep)` recipe above it is
the part that matters and is unaffected.

- **Taken, 2026-08-25**: as proposed, in three lines rather than four words —
  the anecdote ends on a paragraph break, so a mid-sentence aside would have
  landed between the filename and the hex codes that explain the sort. The
  recipe above it is untouched. `docs/plans/18-experience-tables.md` names the
  same file and was **left alone**: it is a dated plan, and D1's new paragraph
  in `docs/plans/README.md` now covers exactly that case.

### D3 — low — the README's class-format example uses a `source_book` no class carries

`README.md` line ~320 shows `source_book: rifts-core   # required` in the
canonical YAML example. After last night's re-audit, **zero** published classes
use `rifts-core` — the four that did now name Rifts Ultimate Edition or the
original Rifts RPG.

Harmless as an example, mildly misleading as a model to copy: it is the one
value in that block a reader might paste into a new class.

**Proposal**: change the example to `source_book: rifts-ultimate-edition`. Note
the smoke test pins that this example still *parses*, so the change is safe but
must keep the block valid.

- **Taken, 2026-08-25, with one refinement**: the proposed value would have had
  the same defect. Asked production what the published classes actually carry,
  and `source_book` is **not a slug** — 51 of 56 distinct values are free-text
  citations with page numbers (`Rifts Ultimate Edition p.61-66`,
  `Palladium Fantasy RPG Main Book p.288-289`). Only three slug-style values
  survive anywhere. `rifts-ultimate-edition` would have been a second value no
  class uses, modelling a convention the catalog abandoned.

  The example is the **Cyber-Knight**, so it now carries the Cyber-Knight's
  real value, `Rifts Ultimate Edition p.61-66`, with the comment widened to
  `# required; the book as printed` so the shape is taught and not just shown.
  `smoke.mjs` already asserted a parse yielding `Rifts Ultimate Edition`
  elsewhere, which is the convention agreeing with itself.

### D4 — info — two test fixtures now diverge from the classes they are named for

`test/fixtures/cyber-knight.md` and `test/fixtures/dragon-hatchling.md` both
carry `source_book: rifts-core`, which the real classes no longer do.

**This is almost certainly fine** — a fixture is an input to a parser test, not
a claim about production, and freezing it is the point. Recorded only so the
next person to grep `rifts-core` does not think they have found a bug. **No
action proposed.**

### D5 — WITHDRAWN — `pick3cut5/AUDIT.md` has no open items

**This finding was wrong, and is left here rather than deleted** because how
it went wrong is the whole subject of this audit.

As filed, it said F1–F5, F7, F8 and F9 carry an outcome and that **F6**
(fold the Worker back in) and **F10** (the wedge fix) do not. They do. F6
carries `> **Not now**, as recommended.` and F10 carries `> **Not code** —
nothing to implement.`, and `git log -S` puts both in commit `4eb5f8a` on
**2026-08-24** — the day *before* this audit ran.

The finding was a grep for two exact strings, `**Taken.**` and
`**Not taken.**`, reported as a reading of the file. That is the third time in
this one audit that a grep disagreed with the surrounding sentence, and the
only one of the three that got past the check and into the document. The other
two are in *What was checked and found healthy* below, caught before filing.

All ten findings in `pick3cut5/AUDIT.md` carry an outcome. **The repo has no
live backlog.** F6 is on hold by its own note and F10 was never work — it is a
note asking the next reader to treat `catchUpDeadline()` as unproven insurance
rather than as a fix for a known production bug.

**Withdrawn 2026-08-25**, at Nathan's request to put F6 and F10 on hold — a
request that turned out to be already satisfied. F6's note now carries a dated
confirmation so the hold is explicit rather than inferred.

## What was checked and found healthy

Worth recording, so the next audit does not redo it:

- **The README's structural counts are accurate** — 34 tables, 39 migrations —
  and the big five catalog counts are pinned by `regression.mjs` against a
  database built from nothing. That pinning is why they were the *only* counts
  in the repo that had not drifted.
- **`apps/character-creator/AUDIT.md` is fully consumed** — six findings, six
  `Taken` notes — and is dated in its title and header. Its "76 published
  classes total 747,934 bytes" is a measurement *as of* that date, not a claim
  about today.
- **`docs/plans/` is deliberately historical** and says so in its own README,
  including which plan is most changed since and where to look instead.
- **`docs/rules-audit.md`** is a rule-to-page reference, not a to-do list, and
  its Palladium Fantasy page-offset note still matches that scan.
- **`AUDIT.md`'s "there are no static catalogs — `skills.json` / `spells.json`
  / `psionics.json`"** reads as a dead reference to a link checker and is the
  opposite: a deliberate statement that those files do *not* exist.
- **`claim-audit/SKILL.md`'s table row for `reference/read-columns.py`** is
  likewise correct — it is a record of a stale claim that *was* found, and the
  file being gone is the point.

Two of those six were nearly filed as findings before checking. That ratio is
the argument for the skill's own rule: **read the surrounding sentence before
believing a grep.**
