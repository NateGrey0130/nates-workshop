# Documentation audit, 2026-08-25

Read-only pass over every `.md` in the repo — 38 files, ~11,600 lines — asking
what has gone stale, what points at nothing, and what records a decision that
has since been reversed. Checked against `main` @ the merge of #268, production
D1 (`--remote`, per the repo's own rule), and a clean smoke run.

**Five things were fixed in the same PR as this file** because they were
unambiguous rot in *live instructions*. Everything below the fold is a finding
with a proposal, for you to take or decline one at a time.

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

### D4 — info — two test fixtures now diverge from the classes they are named for

`test/fixtures/cyber-knight.md` and `test/fixtures/dragon-hatchling.md` both
carry `source_book: rifts-core`, which the real classes no longer do.

**This is almost certainly fine** — a fixture is an input to a parser test, not
a claim about production, and freezing it is the point. Recorded only so the
next person to grep `rifts-core` does not think they have found a bug. **No
action proposed.**

### D5 — info — `pick3cut5/AUDIT.md` has two genuinely open items

F1–F5, F7, F8 and F9 all carry an outcome (`**Taken.**`, `**Not taken.**`).
**F6** (fold the Worker back in — the Pages → Workers migration) and **F10**
(the wedge fix is insurance of unknown necessity) do not.

Both read as deliberately open rather than forgotten — F6 has a whole design
doc at `docs/pages-to-workers-migration.md`. This is the repo's only live
backlog and it is two items. **No action proposed**; noted so it is not lost.

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
