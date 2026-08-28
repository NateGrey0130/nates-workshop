# Rebuild audit — what a fresh build of this database actually breaks

**2026-08-28.** Audit only. Nothing here was repaired, and production was read
but never written: every remote call in this pass was a `SELECT`.

**On the filename.** The brief offered `DATA-SCRIPT-AUDIT.md`. This is
`REBUILD-AUDIT.md` because the subject turned out not to be the data scripts.
Two of the three largest findings (F5, F6) are about a **column list in an
export** and about **rows the app writes that nothing ever exports**, neither of
which is a data-script ordering problem, and `operations.md` §Data scripts
already owns that name. The question this file answers is "can the repo rebuild
what production holds", so it is named for that.

---

## What was run, and what it cost

Two independent builds of the same file list, then a full-row comparison
against production.

| | |
|---|---|
| Build input | `db/schema.sql`, `db/seed-catalogs.sql`, then all **291** `apps/character-creator/db/*.sql` in sorted filename order, minus the **1** carrying `-- local-only` |
| Build A | `node:sqlite` in-process, **one file at a time**, 3,807 statements, **19 seconds** |
| Build B | `wrangler d1 execute --local --persist-to <scratch> --file` over one concatenated bootstrap (`repo-vs-live.mjs`'s shape), **~5 minutes** |
| Comparison | every column of every row of seven catalog tables, keyed on the natural key |

**The two builds are identical in content.** Comparing them row for row, the
only differences are 252 `imported_classes` and 23 `catalog_redirects`
timestamps — `datetime('now')` firing at build time. Zero differences in
`gear`, `skills`, `spells`, `psionic_powers`, `enchantments`. Every number below
comes from Build A and is reproducible in Build B.

**The `.wrangler/state` hazard the brief warns about was avoided entirely, not
managed.** Build A writes a plain `.sqlite` under the scratchpad; Build B uses
`--persist-to` a temp directory, which is what `repo-vs-live.mjs` and
`test/regression.mjs` already do. **No backup of the local dev database was
needed and none was taken.** The WAL trap is only reachable by building into
`.wrangler/state`, and nothing has to.

**The hour is avoidable too.** `d1-apply.mjs --local db/*.sql` costs an hour
because it spawns 292 `wrangler` processes. Concatenating buys the time back and
gives up per-file failure isolation, which is the trade the brief names. Build A
gives up neither: same SQLite, one process, per-file boundaries kept. Its one
real limitation is that `sql-statements.mjs` splits on every top-level
semicolon, which is right for the data scripts and wrong for `schema.sql`'s
three `CREATE TRIGGER` bodies — the harness re-joins those. `wrangler --file`
does not have that problem, which is why Build B exists.

---

## Corrections to the brief, before the findings

Per the audit-menu rule that taking a finding means auditing it: four premises
in the brief did not survive contact.

1. **"Nothing found so far documents that a rebuild must skip `seed-dev.sql`."**
   It is documented in at least four places.
   [`README.md:765-771`](README.md) states the failure, names the file, and
   gives the workaround. [`test/regression.mjs:87`](test/regression.mjs) and
   [`scripts/repo-vs-live.mjs`](../../scripts/repo-vs-live.mjs) both skip
   `-- local-only` files with an inline comment saying why.
   [`docs/operations.md:249`](docs/operations.md) notes the `skipping …
   marked local-only` line in the standing-up recipe. The real gap is narrower
   and is F1.

2. **"The repo currently cannot complete a fresh build."** It can, and does. Two
   scripts in the repo already build from nothing and both pass:
   `repo-vs-live.mjs` exits 0, and `test/regression.mjs` builds a database and
   drives real endpoints against it. What cannot complete is the specific
   hand-typed command `d1-apply.mjs --local apps/character-creator/db/*.sql`.

3. **"`untag-cross-system.sql`, the only file that sorts after `seed-dev.sql`."**
   ([`README.md:769`](README.md)) **27 files sort after it** as of today —
   `shifter-spells-per-level`, `untag-cross-system`, thirteen `zz-*`, nine
   `zzz-*`, three `zzzz-*`. True when written, false now. F2.

4. **"287 data scripts."** 291 on disk, 290 applied in a rebuild. (Also:
   `INGESTION-AUDIT.md:2805` records "three carry `-- local-only`"; exactly one
   does today. That is a dated record and is left standing per the audit-menu
   rule against rewriting measurements.)

---

## The three questions

### 1. Can a fresh build complete? Yes — and the blocker is real but narrower than stated.

`seed-dev.sql` **does** fail a from-scratch apply, and the brief's diagnosis of
*why* is wrong in a way that matters:

```
seed-dev.sql — statement 3/6: UNIQUE constraint failed: gear.slug
```

That is statement 3, the `INSERT INTO gear ... 'survival-knife'`. It fails on
the **first** pass of a build from an empty database, not on a second pass.
`README.md:766` and the file's own closing comment both explain the failure as
*"its inserts are unguarded and a second pass fails on `gear.slug`"* — but there
is no second pass. `seed-dev.sql` sorts **264th of 291**, and by the time it
runs, `survival-knife` has already been created by an earlier data script. The
file has not been re-runnable-from-empty since whichever script first added that
slug, and the stated explanation hides that.

This only bites the `--local` glob, because `d1-apply.mjs`'s `-- local-only`
skip is inside `if (remote)`. That is F1.

### 2. Does the `zzzz-` rename work? Yes. Verified by a completed rebuild.

The measurement the rename was made to move, run over both datasets with
`source-coverage-lib.mjs`'s own `bucketFor`:

| bucket | fresh build | production | delta |
|---|---|---|---|
| **no-page-range** | **29** | **30** | **−1** |
| traceable | 1,754 | 1,787 | −33 |
| no-source-book | 118 | 81 | **+37** |
| not-a-book | 129 | 133 | −4 |
| not-cached | 51 | 50 | +1 |

**The 148 are gone.** PRs #374/#375/#376 claim the rename fixes the bare-title
loss, and it does — 29 against production's 30, where before the rename it was
172 against 26. The merged claim holds.

**But the citation gap did not close, it moved.** The rebuild has **37 rows with
no `source_book` at all** where production has one, and **33 fewer traceable
rows**. The comparison that produced the 148 counted bare titles only, so a row
that loses its citation *completely* was invisible to it — it left the
`no-page-range` bucket and landed in `no-source-book`, and the headline number
improved. Those 37 rows are 20 psionic powers, 12 gear and 5 skills, and they
are lost for the reasons in F5 and F6, not for an ordering reason. F4.

### 3. What else diverges? A great deal, and the repo's own guard cannot see it.

`node scripts/repo-vs-live.mjs` (2026-08-28) prints:

```
skills   336/336  spells 607/607  psionic_powers 101/101
gear     975/975  enchantments 62/62
The repo rebuilds the live catalog exactly.
```

Every count matches. Every **name** matches. Comparing **every column of every
row** against production on the same day:

| table | rows | rows only in prod | field differences | rows affected |
|---|---|---|---|---|
| `imported_classes` | 126 / 126 | 0 | **15** | 15 |
| `gear` | 975 / 975 | 0 | **257** | 86 |
| `skills` | 336 / 336 | 0 | **37** | 25 |
| `spells` | 607 / 607 | 0 | 5 | 5 |
| `psionic_powers` | 101 / 101 | 0 | **114** | 38 |
| `enchantments` | 62 / 62 | 0 | 0 | 0 |
| `catalog_redirects` | 23 / 45 | **22** | 0 | — |

**428 field-level differences and 22 missing rows, under a green check.** By
direction:

- **335** — production holds a value, the rebuild holds `NULL`. The rebuild
  loses it.
- **89** — both hold a value and they disagree. The rebuild would overwrite
  production.
- **4** — the rebuild holds a value production does not.

Bookkeeping, by contrast, is spotless: 290 distinct filenames in
`data_script_runs` on both sides, `seed-dev.sql` correctly never recorded on
production, `schema_migrations` 41/41. **`drift-check --remote` reports no drift
and is right to.** The bookkeeping and the rows are simply different questions,
and only one of them is being asked.

---

## Findings

### F1 — `d1-apply.mjs` honours `-- local-only` under `--remote` only

The skip lives inside `if (remote)`
([`scripts/d1-apply.mjs:91-98`](../../scripts/d1-apply.mjs)). Under
`--local`, `seed-dev.sql` is applied, fails on `gear.slug`, and because the run
stops at the first failure **the 27 files that sort after it never run** —
`untag-cross-system`, every `zz-*`, every `zzz-*`, and all three new `zzzz-*`.
The last three tiers of corrections, including the citation scripts this repo
just spent three PRs getting into the right order, are unreachable by the one
documented command a person is most likely to type.

The comment above the skip argues correctly that dying on the file would break
the documented glob. That argument applies identically to `--local`; the code
does not.

**Proposal:** move the `-- local-only` filter out of the `if (remote)` branch so
it applies to both targets, keeping the printed `skipping …` line. `seed-dev.sql`
is then applied on its own, exactly as `README.md:765` already instructs.
**Posture: change the skip, add no gate, move no exit code.** A `--local` run
that skips it still exits 0; nothing new fails.

**Taken, 2026-08-28 (PR #385).** The premise held: the skip did live inside
`if (remote)`, and `--local` did strand everything after `seed-dev.sql`.

**The count was stale — 27 is now 31, of 295 data scripts**, because four
`zzzz-` scripts have landed since this was written (F5, F7, F11, F13). The
stranded set is the same in kind: `untag-cross-system.sql`, every `zz-`, every
`zzz-` and every `zzzz-`.

**The posture said "nothing new fails", and that is true of the case it means
and not of one other.** A `--local` glob now skips the file and exits 0, which
is the whole point. But **naming a local-only file explicitly now fails where it
used to apply** — `d1-apply.mjs --local .../seed-dev.sql` prints the skip and
then dies "nothing left to apply", exit 1. That is the pre-existing `--remote`
behaviour extended rather than a new mechanism, and the proposal anticipated it
("`seed-dev.sql` is then applied on its own, exactly as the README instructs" —
which instructs plain `wrangler`). Recorded because "nothing new fails" is not
quite the whole truth.

**This finding could not be code-only, and that is the part worth reading.**
Changing the behaviour falsified the README paragraph that described the old
one — *"dies on `seed-dev.sql` and never reaches `untag-cross-system.sql`"* — so
the paragraph was rewritten in the same PR. Shipping a behaviour change and
leaving the sentence that documents the old behaviour is the exact defect
`claim-audit` exists to catch.

**That rewrite makes F2 moot, and F2 is closed below rather than left looking
open.** F2's whole scope was two claims inside that paragraph: the "only file
that sorts after it" count, and the "a second pass fails" explanation. Neither
sentence exists now — the replacement states 31 files and says the failure is on
the FIRST pass from empty. Nothing is left for F2 to correct.

**Verified by running both targets, not by reading the diff:**

```
--local  seed-dev.sql + untag-cross-system.sql
  skipping .../seed-dev.sql — marked local-only; apply it on its own.
  ── applying .../untag-cross-system.sql (--local) ──
  d1-apply: 1 file(s) applied to local in order, 1 skipped as local-only.   exit 0

--remote seed-dev.sql
  skipping .../seed-dev.sql — marked local-only; apply it on its own.
  d1-apply: nothing left to apply: every file given is local-only          exit 1
```

The `--remote` protection is unchanged: `seed-dev.sql` still cannot reach
production. Nothing was applied to D1 by this finding.

### F2 — `README.md:769` names one file where 27 now sort after `seed-dev.sql`

*"`untag-cross-system.sql`, the only file that sorts after it."* True when
written. Today: `shifter-spells-per-level.sql`, `untag-cross-system.sql`, 13
`zz-*`, 9 `zzz-*`, 3 `zzzz-*`. The sentence makes the F1 blast radius read as
one file of tidying rather than every escalated-prefix correction in the repo.

**Proposal:** replace the count with the tiers it now spans, and correct the
adjacent *"a second pass fails"* explanation — the failure is on the **first**
pass from empty, because `seed-dev.sql` sorts 264th and `survival-knife` already
exists by then. State the current fact; do not quote the phrase being replaced.
**Posture: documentation only.**

**Closed as moot, 2026-08-28 (PR #385) — not taken.** F1 changed the behaviour
this finding's target sentence described, so the sentence was rewritten in F1's
own PR rather than left false. Both claims F2 existed to correct are gone with
it: the *"only file that sorts after it"* count (the replacement says 31, of
295) and the *"a second pass fails on `gear.slug`"* explanation (the replacement
says it fails on the FIRST pass from an empty database, because the gear row it
inserts has already been created by an earlier script by the time a glob reaches
it).

Nothing is left here to take. Recorded as closed rather than left open, because
an open finding whose target text no longer exists is the kind of thing that
gets "fixed" a second time.

### F3 — nothing pins the rebuild's row *contents*, so this class of regression is invisible

`repo-vs-live.mjs` compares **names**, by design and with the reasoning written
down ("Counts are not enough — gear was off by one row and that one row hid
seven disagreements"). The lesson generalised one step further than it was
taken: names are not enough either. `test/regression.mjs` pins five **counts**.
Between them, 428 field differences and 22 missing rows sit in the blind spot,
and both tools report success.

**Proposal:** extend `repo-vs-live.mjs` to compare **all columns** of the rows
whose names already match, printing a per-table, per-column difference count and
the offending keys — the shape this audit used. Report the number; **do not**
move its exit code, which currently means "the repo creates the right set of
rows" and should keep meaning that.
**Posture: report, do not fail. Advisory, exits 0 on content differences.**
A gate here would fail on day one with 428 findings and be switched off.

**Taken, 2026-08-28 (PR #377).** Posture held: report, do not fail. A missing or
extra row still exits 1; a differing value is printed and exits 0.

**Two premise corrections, both found by running it rather than by reading it.**

1. **This finding was wrong about its own scope.** It says "428 field differences
   and 22 missing rows sit in the blind spot". Inside the five tables
   `repo-vs-live.mjs` actually covers, the figure is **413 fields across 154
   rows** — reproduced exactly by the new code, independently of the harness that
   first measured it. The other 15 field differences are `imported_classes`,
   which this script does not cover at all, and the 22 rows are
   `catalog_redirects`, which is F8's scope. Implemented over the five tables as
   written rather than quietly widened; the `imported_classes` gap is now F12.

2. **The name column is not the row-identity column, and this finding assumed it
   was.** `TABLES` carried one column per table, used for the name-set
   comparison. Reusing it to join rows for the value comparison paired an armor
   enchantment with a weapon one: `enchantments` prints Color, Continual Glow and
   Impervious to Fire once per `applies_to`, and gear holds two Sleeping Bags.
   The first run reported **437 across 157** — 24 of them manufactured by the
   collision. `TABLES` now carries `[table, name column, identity column]`, gear
   and enchantments join on `slug`, and a key that is not unique **refuses to
   compare** rather than printing a number built on a collision.

Beyond the proposal, and worth saying because it was a choice: the per-row list
is capped at eight rows per table with `--offenders` to see all, matching
`source-coverage.mjs`'s flag of the same name. Uncapped, this prints 154 rows.

**Not fixed here, and not claimed to be:** every one of the 413 differences
still stands. This finding was only ever about making them visible. F5 is the
first instalment of closing them.

Taking it also turned up **F11** and **F12**, added to this menu in the same PR
and not taken.

### F4 — the citation comparison counted one bucket, so a total loss read as an improvement

The 148 measurement counted rows with a **bare book title**. A row that ends the
rebuild with **no `source_book` at all** leaves that bucket, so losing a citation
outright made the number go *down*. Production 81 `no-source-book` against the
rebuild's 118, and 33 fewer traceable rows, were never in view.

**Proposal:** whenever the rebuild's citation coverage is quoted, quote the
**whole bucket table** from `source-coverage-lib.mjs`, both datasets side by
side, not a single bucket. Add the two-dataset comparison as a documented
invocation of the existing library. **Posture: measurement only, no data change.**

**Taken, 2026-08-28 (PR #386).** Posture held: measurement only, no data change,
and `source-coverage.mjs` still never moves its exit code.

`node scripts/source-coverage.mjs --remote --vs-build` builds a database from
the repo into a scratch `--persist-to` directory, runs `summarise()` from
`source-coverage-lib.mjs` over both datasets, and prints the whole bucket table
side by side with deltas. The existing invocations are untouched.

**Every number this finding quotes is stale, and in the good direction —
because F5 and F13 landed in between.** Re-measured today:

| bucket | production | build | delta | this finding said |
|---|---|---|---|---|
| traceable | 1,850 | 1,837 | **−13** | −33 |
| not-a-book | 133 | 129 | −4 | — |
| **no-source-book** | 81 | **98** | **+17** | build 118 |
| **no-page-range** | 30 | **29** | **−1** | — |
| not-cached | 51 | 52 | +1 | — |
| unknown-book / outside-cache | 0 | 0 | — | — |
| rows | 2,145 | 2,145 | — | — |

**The pathology is still live and the table now shows it in one command.** A
rebuild is *better* than production on `no-page-range` — 29 against 30 — while
being **17 rows worse** on `no-source-book`. Quote the bare-title bucket alone
and today's rebuild still reads as an improvement over production. That is the
exact shape of the original error, unchanged in kind and merely smaller: 148
became 17.

Two smaller deltas worth naming rather than smoothing over: `not-a-book` is 4
lower in the build, and `not-cached` is **1 higher** — a row in the build cites
a book this machine does not hold where production's copy does not. Neither is
chased here; both are visible now, which is the point of the finding.

**One thing beyond the proposal.** The build's `fromBuild()` takes the first
slice of wrangler's output that *parses*, rather than the first `[`. wrangler
prefixes a log line that also opens with `[`, so the obvious `indexOf('[')`
returns a position inside the banner — the same trap `repo-vs-live.mjs`
documents. Copied deliberately rather than rediscovered.

**Not closed by this:** the 17 rows. This finding was only ever about making a
single-bucket quote impossible to mistake for coverage. The rows themselves are
F6's, and F14's for the skills half.

### F5 — `restore-gear-missing-from-repo.sql` exports 6 of gear's 18 columns

The root cause of the largest single cluster. The script's `INSERT OR IGNORE`
carries `(slug, name, system, category, description, source_book)` and nothing
else ([line 30](db/restore-gear-missing-from-repo.sql)). It restores that a
row **exists**; it does not restore what the row **is**.

**198 of the 428 field differences sit on rows a `restore-*.sql` creates, 193 of
them on gear columns this export drops:**

| column | rows | column | rows |
|---|---|---|---|
| `cost` | 40 | `payload` | 19 |
| `weight_lbs` | 32 | `rate_of_fire` | 18 |
| `damage` | 29 | `mdc` | 8 |
| `is_mega_damage` | **24** | `cost_note`, `ar`, `system` | 3 |
| `range` | 20 | **gear subtotal** | **193** |

(The remaining 5 are `skills.note` on rows
`restore-skills-missing-from-repo.sql` creates, whose column list is fine — see
F6.)

The `is_mega_damage` row is the one to look at. **24 weapons that are
mega-damage in production come out S.D.C. in a rebuild** — the Boom Gun, the
C-40R SAMAS rail gun, the JA-11, the L-20 pulse rifle. The name is right, the
description is right, the weapon is wrong. Nothing in the repo has ever
disagreed about it, because nothing compared it.

The script was verified by a name-level diff, so a six-column export passed.
This is F3's blind spot with a body count.

**Proposal:** re-export the rows `restore-gear-missing-from-repo.sql` creates
from `--remote`, all 18 columns, as a **new** `zzzz-`-or-later data script that
`UPDATE`s them — the existing file is applied and is never edited. It must sort
after `zzz-gear-tidy-2-stub-stats.sql`, which rewrites the same columns, for
exactly the reason the `zzzz-` tier exists.
**Posture: a new data script, applied to local only** — production already
holds these values and needs no change. This is repo-side repair.

**Taken, 2026-08-28 (PR #379).** The premises held — 193 field values across 53
rows, all twelve dropped columns, 24 weapons rebuilding as S.D.C. — and were
re-measured against a build from current `main` rather than quoted from above.
Two things had to change anyway.

**The posture as written is impossible.** It says *"applied to local only —
production already holds these values and needs no change."* The first half of
that reasoning is right and the instruction that follows from it is wrong:
[`drift-check.mjs:65`](../../scripts/drift-check.mjs) reports any
non-local-only data script with no `data_script_runs` row as
`DATA SCRIPT NOT RUN` and exits 1, so a script that never runs remotely leaves
`main` permanently drifting. Marking it `-- local-only` would be worse still —
it is a correction a fresh production would need, not a dev seed. **Applied to
`--remote` before the merge**, and because this script's `WHERE slug = ...`
matches rather than guarding itself out, the apply rewrote 53 rows with the
values they already held: `changes: 55`, where F11's script reported 0.
Production was dumped before and after — 975 rows, **zero field differences,
byte-for-byte unchanged**. That diff, not the change count, is the check.

**"All 18 columns" was narrowed to the columns that differ.** 53 `UPDATE`s each
rewriting an unchanged multi-kilobyte `description` would make the file
unreviewable in order to change nothing; the effect is identical. Stated here
rather than done quietly.

**One row on the restore script's list is in neither database.**
`leather-armor` — `retire-leather-armor-placeholder.sql` removes it in both, so
it is absent here rather than silently skipped. It briefly looked like a
row-level divergence and is not.

**Measured, on a database built from nothing:**

| | before | after |
|---|---|---|
| `gear` field differences vs production | 257 | **64** |
| all catalogs | 428 | **230** |
| `mega_damage_rows` in a rebuild | 52 | **76**, production's own figure |
| gear rows with no cost, in a rebuild | 155 | 115 |

`mega_damage_rows` reaches parity exactly — every one of the twenty-four
missing flags was on a row this script corrects. **The cost figure does not**:
production holds 105 and a rebuild now holds 115. Those ten are gear rows no
`restore-*` script created, priced through the catalog editor, and they belong
to F6 rather than here. Recorded as a gap rather than rounded into a win.

**What this does not close.** 230 field differences remain across the five
catalogs plus `imported_classes`: 114 in `psionic_powers` and 37 in `skills`
(F6), 64 still in gear (F6's ten priced rows and the citation drift F4
describes), 10 class-markdown and `created_by` differences (F7, F12), and the
22 `catalog_redirects` rows (F8).

### F6 — the app writes rows the repo has no mechanism to capture, and 38 psionic powers are bare because of it

Traced one row through all 292 files
(`trace-row.mjs psionic_powers name "Healing Touch"`):

```
── after db/seed-catalogs.sql
     name         Healing Touch
     category     Healing
     isp          6
     source_book  NULL
     range        NULL
     duration     NULL
     description  NULL
```

**No other file in the rebuild touches it again.** Production has the full RUE
text, cited to p.165. Thirty-eight psionic powers differ from production in at
least one column; of those, **21 have no `description` at all** in a rebuilt
database against production's 1, and **32 rows have no `source_book`**. Healing
Touch, Telepathy, Telekinetic Lift, Mind Bolt and Sixth Sense are among the
name-and-ISP stubs.

The mechanism is not ordering. `seed-catalogs.sql` creates the bare row; the
richer text arrived later through the catalog editor or the importer's confirm
step, both of which write straight to D1; `add-rue-psionics-batch.sql` is
`INSERT OR IGNORE` on name, so it finds the stub already there and does nothing.
`restore-psionics-missing-from-repo.sql` only restores rows that were **absent**
— it has no view of a row that was present and got **enriched**. (Its column
list is fine: 11 columns. So is `restore-skills-missing-from-repo.sql`'s 10.
Only gear's is narrow, F5.)

This is the structural finding behind both F5 and F4: **`restore-*` closes
row-existence drift and nothing closes row-content drift**, and every write the
app makes to an existing catalog row is permanently outside the repo.

**Proposal:** state it in `docs/operations.md` §Data scripts as a named
limitation — a `restore-*.sql` restores existence, not values; a catalog row
edited in the app diverges from the repo silently and forever. Then decide
separately whether to close it (F5 is the gear-sized instalment).
**Posture: documentation now; the repair is a separate finding per catalog.**

**Taken, 2026-08-28 (PR #380).** Posture held: **documentation only.** No data
script, no code, no D1 change — the repair stays a separate finding per catalog,
now numbered F13 (psionics) and F14 (skills) so taking either is its own
decision.

**One word of this finding is now wrong, and it is the load-bearing one.** The
proposal says a catalog row edited in the app *"diverges from the repo silently
and forever"*. Since PR #377 it is **not silent**: `repo-vs-live.mjs` compares
every column of every row whose name matches and prints the count. The
divergence is now a number anyone can read in one command, which is the whole
reason F3 was taken first. The paragraph written into `operations.md` says that
and points at the command, rather than repeating the claim that it cannot be
seen. *"Forever"* still stands — nothing in the repo reconstructs such a row.

**Re-measured rather than quoted**, on a build from `main` after F5 landed: 21
psionic powers with no `description` against production's one, 32 with no
`source_book` against production's twelve, and the `Healing Touch` trace re-run
through all 292 files to confirm `seed-catalogs.sql` is still the only file that
touches it. The heading count in the finding — "38 psionic powers" — is rows
differing in *at least one* column; 21 is the number that are genuinely bare.
Both figures appear in F13 so neither can be quoted as the other.

**Where it went, and one thing avoided.** `docs/operations.md` §Data scripts,
after the three conventions and before the run-log query. It is a **bold lead-in
paragraph, not a `####` heading**, and that is not a style preference: the smoke
test bounds §Data scripts with `search(/\r?\n#{1,6} /)` — the next heading of
**any** depth — and parses every `` `*.sql` `` pattern inside it to prove each
data script is covered. A new sub-heading there would have silently truncated
the section the check reads. The file had 0 `####` headings before this and has
0 after.

**Not closed, and not claimed to be:** 230 field differences across the
catalogs stand exactly where they did. This finding was always about naming the
limitation, and naming it does not move a row.

### F7 — `fix-class-skill-names-to-rue.sql` still defeats a later `fix-` script, and the `zz-` remedy creates a duplicate

The bug the `zz-` tier was invented for is not fully fixed. Traced:

```
── after add-burster-class.sql
   except: ["W.P. Heavy", "W.P. Heavy Energy Weapons",
            "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]

── after fix-class-skill-names-to-rue.sql
   except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons",
            "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]
```

`fix-class-skill-names-to-rue.sql` (sorts `fix-cl…`) renames the first two names
into the second two. `fix-dead-skill-restrictions.sql` (sorts `fix-de…`, i.e.
**after**) then tries to collapse the four-name list, but its guard matches the
**pre-rename** string, which no longer exists — so it does nothing and the
duplicate stands. On production `fix-class-skill-names-to-rue.sql` was applied
by hand **last**, so the collapse ran first and was right.

`mystic` shows the same shape one step longer, and there the `zz-` remedy is the
culprit: `fix-dead-skill-restrictions`'s statement removing `"Warships"` also
misses its renamed guard, `"Warships"` survives, and
`zz-canonicalise-class-skill-names.sql` then renames it to `"Military: Warships
& Patrol Boats"` — **which is already in the list**. The corrective script
creates the duplicate.

Affected in a rebuild: `mystic` and `burster` (duplicated W.P. entries),
`mystic` (duplicated Pilot entry). `operations.md`'s `zz-` row names three
scripts that `fix-class-skill-names-to-rue` beats; this is a **fourth
consequence** of the same pair, of a different kind — not a wrong name, a
doubled entry — and the `zz-` escalation did not address it.

**Proposal:** one new correction script in the `zzzz-` tier or later that
de-duplicates the three lists, guarded on the doubled string so it is a no-op on
production. Add a row to `operations.md` §Data scripts recording that the `zz-`
escalation fixed the names and left duplicates behind — the fourth occurrence of
this bug, and the first found by looking rather than by accident.
**Posture: a new data script plus a documentation row. Local only; production
is already correct.**

**Taken, 2026-08-28 (PR #383).** Both halves — the data script and the
documentation. The premises held exactly: three lines, two classes, and the
causal chain traced file by file through a rebuild reproduces as written.

**`mystic` and `burster` now match production byte for byte**, taking the
class-markdown divergence from 8 to **6**. The six that remain all run the other
way — the rebuild carries the resolved value and production carries the
placeholder — and belong with F15 rather than here.

**Not guarded on `class_id`.** The proposal said "de-duplicates the three
lists"; the statements guard on the doubled string instead, so any class that
acquires the same shape later is fixed by the same file. A repeated entry in an
`except:` list is never intentional.

**The documentation is a paragraph, not a table row.** The proposal said "add a
row to `operations.md` §Data scripts", and a row is the wrong shape: the table's
`zzzz-*.sql` entry already covers this file, so a new row would only restate it,
and the thing worth recording is a lesson rather than a file family. It sits
directly under the tier table as a bold lead-in — **not** a `####` heading, for
the reason F6's note gives.

**Two things learned in the applying, both now in `operations.md`:**

1. **A guarded `replace()` whose guard names a string another script renames is
   not idempotent, it is inert** — and it fails silently, because a `replace()`
   that matches nothing is indistinguishable from one that had nothing to do.
   That is the general form of this bug and it is what the paragraph leads with.

2. **`--file` over `--remote` reports `changes` and `rows_written` that are
   import-endpoint aggregates, not row counts.** This script reported
   `changes: 2` against production while changing *nothing*: `imported_classes`
   was dumped before and after — 126 rows, zero field differences, `updated_at`
   unmoved on every one. `operations.md` already warned that `--file` returns a
   summary rather than results and that its exit code is advisory; the counts
   inside that summary are advisory too, and this is the first time that has
   been written down. Without the dump this would have read as an unexplained
   production write.

**Applied to `--remote` before the merge**, against the finding's stated "local
only" posture, for the reason F5's note gives: `drift-check` reports a data
script with no `data_script_runs` row as `DATA SCRIPT NOT RUN` and exits 1.

**Read-backs on a fresh build:** `wp_lists_still_doubled` 0,
`pilot_lists_still_doubled` 0, `mystic_warships_mentions` 1. Same three on
production.

### F8 — 22 `catalog_redirects` rows exist only in production

`catalog_redirects` is written by `_lib/catalog-redirects.js` when a merge or
rename happens in the app. 23 of the 45 live rows come from data scripts; **22
do not** — `Horsemanship`, `SCUBA`, `W.P. Heavy`, `back-pack`,
`irmss-portable-kit` and 17 more. Exactly the `restore-*` situation, for a table
`repo-vs-live.mjs` does not check.

**The blast radius is smaller than it looks, and it was checked rather than
assumed.** None of the 22 is cited as a skill or gear key by class markdown in
the fresh build. `"Horsemanship"` appears in 49 classes and looked like 49 dead
references until read properly — it is there as a **skill category**, and the
category exists in both databases. What these rows actually protect is **saved
characters** whose stored keys predate a merge, and a rebuilt database has no
characters (F9). So this is a latent gap, not a live break.

**Proposal:** add `catalog_redirects` to `repo-vs-live.mjs`'s table list so the
gap is at least reported, and export the 22 as a `restore-catalog-redirects.sql`
if and only if F9's answer is that rebuilds are supposed to be restorable.
**Posture: reporting first; the export is contingent on F9.**

**Taken, 2026-08-28 (PR #387) — the reporting half only.** The export is still
contingent on F9, which is taken next.

The premise held: **22 redirects exist only in production**, verified today, and
the list is unchanged from the audit. `repo-vs-live.mjs` now covers the table.

**`from_key` is unique across all 45 rows**, so it serves as both the set column
and the identity column. Checked rather than assumed — the same assumption
broke F3 for `enchantments` and gear.

**`to_id` had to be excluded, and that is not cosmetic.** It is the ROWID of the
gear or skill a redirect points at, so two correct databases built in a
different order disagree about it by construction. Left in, it would have
reported **all 23 shared redirects as broken** while every one of them resolves
— a table that is fine reading as totally corrupt.

**This turns `repo-vs-live.mjs` RED. Exit 1, and it will stay there.** Row-level
differences drive the exit code by design — F3 was careful to keep it meaning
exactly "a missing or extra row", and these 22 are missing rows. It is the same
state the tool showed for the original 2 classes and 169 catalog rows until
`restore-*.sql` was written, so this is the tool working rather than breaking:
nothing automated depends on it, the merge gate is the smoke suites, and
`drift-check --remote` still prints `NO DRIFT`.

But it is a standing red, and F3's own note warns that a check which fails on
the day it lands gets switched off rather than fixed. **Whether to clear it by
exporting the 22, or to make redirect rows advisory the way value differences
are, is a live decision** — and it turns on F9's answer about what a rebuild is
FOR. Raised rather than settled here.

Full run after this change: `128 field(s) across 85 row(s)` and `22 row(s)
differ`, exit 1. `imported_classes` is down to 6 differing rows, F7 having
closed two.

**Second half taken, 2026-08-28 (PR #392). The red is cleared:
`repo-vs-live.mjs` exits 0 again**, with `catalog_redirects 45 / 45  names
match`.

**The contingency discharged, though not the way F8 framed it.** F8 made the
export conditional on *"F9's answer that rebuilds are supposed to be
restorable"*, and F9's answer is that a rebuild produces the **catalog and the
class definitions**, never the user data. A redirect is catalog metadata — it is
what makes a saved key resolve after a merge — so it sits **inside** that scope.
F9's own note said this finding was not discharged by it; on re-reading, F9
answers it in the affirmative rather than leaving it open. Recorded because the
two notes disagree and this one is later.

**`to_id` could not be exported and the statements resolve it at apply time.**
It is a ROWID, which is why F8's first half excluded it from comparison; the
same fact means it cannot be written down. Each statement selects the target by
its natural key, the shape `zz-merge-psionic-duplicates.sql` already uses. If a
target is absent the INSERT selects nothing and no redirect is created — the
right failure, since a redirect pointing at a missing row is worse than none.
All 22 resolved against production; none pointed at a missing row.

18 skills and 4 gear.

**The smoke test is STRICTER THAN `d1-apply.mjs`, and finding that out cost a
red build.** `d1-apply` exempts comments from its non-ASCII check — its own
header explains why, having once refused 11 of the repo's migrations for
em-dashes in prose. The smoke test does not exempt them: *"every data script is
pure ASCII"* covers the whole file. One comment line here read
`-- Lore — Faerie -> ...`, describing a `from_key` that genuinely contains an
em-dash, and it failed smoke while `d1-apply` had accepted it happily on both
targets. The comment now spells the key with `char(8212)` like the executable
line beneath it. **Two guards, two rules, and the stricter one is not the one
that runs first.**

**Verified:** a fresh build reaches **45 redirects, 0 dangling targets** —
production's own figures. Production dumped before and after: 45 rows before,
45 after, **0 added and 0 changed**, since all 22 already existed there.

Field differences are unchanged at **86 across 54 rows** — this finding adds
rows, it does not touch values.

### F9 — "rebuild from the repo" has never meant "restore production", and nothing says so

Production holds **6,006 rows no data script creates**:

| | | | |
|---|---|---|---|
| `media_items` | 3,639 | `characters` | 11 |
| `ff_filaments` | 2,051 | `play_events` | 6 |
| `ff_brands` | 157 | `campaigns` | 3 |
| `character_items` | 111 | `character_drafts` | 2 |
| `claude_usage` | 26 | | |

A rebuild reconstructs the **character-creator catalog**. It does not
reconstruct the database, and it never could: the repo has no user data in it
and should not. `operations.md` §"Standing up a new environment" is titled
correctly and is about exactly that — a *new* environment. But
`repo-vs-live.mjs`'s opening line asks *"Can the repo rebuild the live catalog,
row for row?"* and the surrounding prose slides between "the catalog" and "the
database" often enough that the audit brief itself asked whether production
could be rebuilt from the repo. It cannot, by design.

**Proposal:** one paragraph in `docs/operations.md` stating the scope plainly —
a repo build produces the catalog and the class definitions; campaigns,
characters, journals, NPCs, MediaVault and FilamentForge rows exist only in D1
and are protected by Cloudflare's backups, not by git. Name the number and its
date. **Posture: documentation only. No new tooling, no backup mechanism
proposed here** — that is a separate decision, and F10 argues it is not needed.

**Taken, 2026-08-28 (PR #388).** Posture held: documentation only. No tooling,
no backup mechanism, nothing applied to D1. **6,006 re-measured today and
unchanged.**

**One cross-reference in this finding is wrong.** It says the backup question is
*"a separate decision, and F10 argues it is not needed"*. F10 is about keeping
the fast rebuild harness and says nothing about backups. The argument it means
lives in this file's closing verdict — production is backed by Cloudflare and no
rebuild has ever been needed. Corrected here rather than in the finding, which
is a record.

The paragraph went into `operations.md` §Standing up a new environment, directly
after the pinned clean-run counts, because that table is exactly the thing being
scoped: it is the catalog and the class definitions, and it is the whole of what
a rebuild produces.

**It does not resolve F8's contingency, and F8 assumed it would.** F8 said the
export of its 22 redirects was *"contingent on F9's answer that rebuilds are
supposed to be restorable"*. F9's answer is about **user data** — characters,
campaigns, media, filaments — which is not what `catalog_redirects` holds. Those
22 rows are app-written **catalog metadata**, the same family as F6's enrichment
gap, not the same family as a character sheet. So F8's question stands on its
own and `repo-vs-live.mjs` stays red until it is decided. Said plainly because
the contingency was written expecting to be discharged here and is not.

Beyond the proposal, the paragraph names two consequences: neither
`test/regression.mjs` nor `repo-vs-live.mjs` is a restore drill, and
`repo-vs-live.mjs`'s own opening question is scoped correctly where the prose
around it sometimes is not.

### F10 — the fast rebuild harness is worth keeping

An hour per rebuild is why the `zzzz-` rename shipped unverified, and why three
occurrences of the ordering bug were found by accident. 19 seconds changes what
gets checked. The harness is ~90 lines: `node:sqlite`, the repo's own
`sql-statements.mjs`, one file at a time, per-file failure isolation kept, and
`trace-row.mjs` — which replays the build and prints every file that changes one
row — is what produced F6 and F7 and is not obtainable from a concatenated
bootstrap at all.

The honest caveats: it is Node's SQLite rather than workerd's, and it needs the
trigger re-join `wrangler --file` does not. Build B is the answer to the first
and found zero content differences across all seven tables — 2,081 catalog rows,
126 classes and 23 redirects.

**Proposal:** land the harness as `scripts/rebuild-local.mjs` and
`scripts/trace-row.mjs`, documented as a **development** tool with the fidelity
caveat stated and `repo-vs-live.mjs` named as the authority.
**Posture: new tooling, opt-in, no test-suite dependency, no CI.** Nothing
should start depending on it.

**Taken, 2026-08-28 (PR #389).** Posture held: new tooling, opt-in, **no test
imports either script and neither gates anything**. Both exit 0 by design, the
way `source-coverage.mjs` does.

`scripts/rebuild-local.mjs` and `scripts/trace-row.mjs`, both with the two
caveats stated in their headers: Node's SQLite is not workerd's, and
`sql-statements.mjs` splits inside a `CREATE TRIGGER` body so triggers are
re-joined. `repo-vs-live.mjs` is named in both as the authority.

**The README file map was not optional.** `smoke.mjs` pins that every
`.mjs`/`.py`/`.txt`/`.json` in `scripts/` is named in *The scripts at the repo
root*, and that every name there is a script that exists — so a new script
without a map entry fails the merge gate. Caught by running smoke, which is
what that check is for.

**While editing that map, a stale line was corrected: `repo-vs-live.mjs` was
still described as "diffs NAMES, not counts".** It has diffed names *and* every
column since PR #377, and classes since #382. F3 and F12 both missed the file
map. Corrected here because leaving a known-false line in the block being edited
is exactly what `claim-audit` exists to catch — but recorded as a correction
belonging to F3, not as part of F10.

**Verified by running both against the cases they were built on**, not by
reading them:

- `trace-row.mjs imported_classes class_id burster --grep "Weapon Proficiencies"`
  reports **4** files touching that line and shows the list ending collapsed —
  the state F7 produced. Before F7 the same command showed it doubled.
- `trace-row.mjs psionic_powers name "Healing Touch"` reports **2** files:
  `seed-catalogs.sql` creating it bare, and
  `zzzz-restore-psionic-powers-full.sql` filling it. Before F13 it reported
  **1**, which was the finding.

Both are now regression evidence as much as tools: the traces show the fixes
holding.

`rebuild-local.mjs` builds 296 files, 3,897 statements, 0 failures.

### F11 — a fresh build cites 10 gear slugs that do not exist; production cites 0

Found while taking F3, by the smoke test rather than by the comparison F3 adds —
this is a **dead reference**, not a differing value, so F3's new output cannot see
it. Running the smoke test's own gear-citation sweep (`referencedGear()` from
`_lib/catalog.js`) against a fresh build instead of the shared local database:

```
FRESH BUILD   126 classes, 3027 citations, 10 unresolved
   headhunter-techno-warrior: energy-rifle, automatic-pistol, energy-pistol
   ley-line-rifter:           energy-pistol, energy-rifle
   mind-melter:               energy-pistol, energy-rifle
   robot-pilot:               automatic-pistol, energy-pistol
   warlock:                   automatic-pistol
PRODUCTION    126 classes, 3033 citations,  0 unresolved
```

`energy-pistol`, `energy-rifle` and `automatic-pistol` exist in neither database,
as a gear row or as a `catalog_redirects` key. Production's copies of these five
classes cite real slugs (`wilk-s-320-laser-pistol`, `ng-33-northern-gun-laser-pistol`,
`l-20-pulse-rifle`); the repo's copies still carry the generic placeholders, and
the script that resolved them on production left nothing in git. **This is the
exact failure `retire-orphan-gear-stubs.sql` and the smoke check were written
for** (class audit F2): a wizard pick of one of those options resolves to nothing.

**The check that catches it is load-bearing by accident.** It reads the shared
local database (`--local`, no `--persist-to`). It fails on this machine because
that database holds repo-shaped markdown; on a machine whose local D1 was synced
from production it would pass, and the defect would be invisible everywhere. It
is currently failing on `main` — verified by stashing this branch and re-running.

**Proposal:** export the five classes' resolved `from:` lists from `--remote`
into a new `zzzz-`-or-later data script, the same shape F5 proposes for gear
columns. Separately, point the smoke sweep at a database built from the repo
rather than at whatever `.wrangler/state` holds, so the result stops depending
on the machine.
**Posture: two changes, and they are separable — take the data script alone if
the test change is unwanted.** Production needs neither; it is already correct.

**Taken, 2026-08-28 (PR #378).** Both halves — the data script and the test
move — since the separable clause was not invoked.

**This finding's stated cause was wrong.** It says *"the script that resolved
them on production left nothing in git"*. `zzz-resolve-choice-group-gear.sql`
**is** in git and **does** rewire choice lists; it just does not touch these
six. The real mechanism, read out of the script rather than inferred:

`retire-gear-placeholders.sql` deletes the four category placeholder rows
guarded on `NOT EXISTS (... instr(markdown, 'item_id: "' || slug || '"'))`.
That guard matches only **fixed** equipment entries, never a choice group's
`from:` list, so the rows are deleted while five classes still cite them there.
**It is the same guard shape, and the same blind spot, that class audit F2
found in `retire-orphan-gear-stubs.sql`** — fixed there by
`zzz-resolve-choice-group-gear.sql`, and never checked for in the other
`retire-*` script. The half of the premise that survives is that production's
correct lists came from the catalog editor and left nothing in git; what was
wrong was calling that the cause rather than the reason nobody noticed.

**What landed.** `zzzz-resolve-energy-placeholder-choices.sql` rewires the six
lists to production's slugs, exported row for row rather than composed — a
rebuild agreeing with production is the whole point, so a better list would
defeat it. Applied to `--remote` before the merge: **0 rows changed**, run
recorded. The sweep moved from `smoke.mjs` to `regression.mjs`.

**Two implementation errors, both found by running it:**

1. The read-back counted classes *citing* `ng-57-…` rather than classes this
   script *rewired*, and returned **7** where its own comment claimed 5 —
   other classes already cite that slug. Rewritten to scope the count to the
   five targets. Caught before the file reached `main` or production, which is
   the only window in which an applied script may be edited.
2. The sweep needed `environment.mjs`'s `maxBuffer: 1e9` and it was left
   behind. 126 class markdowns overrun `spawnSync`'s 1 MB default; the JSON
   truncates mid-parse and the failure names neither size nor buffers. Moved
   with the check.

**Verified:** fresh build 10 unresolved → **0** (production 0 throughout); the
five classes' markdown now matches production byte for byte, dropping the
class-markdown divergence from 13 to **8**; `smoke.mjs` 1331/89 → 1327/88
PASSED, `regression.mjs` 206 → **210 PASSED**.

**Left standing on purpose:** `CLASS-AUDIT.md:112` records that smoke *gained*
a `Gear citations resolve` section. True on 2026-08-26; the section has since
moved here. Records are not rewritten, and amending another menu inside this
PR would be the scope widening the protocol warns about.

**The remaining 8 class-markdown differences are F7's and others' — not
touched.** F12 is still what would make them visible.

### F12 — `repo-vs-live.mjs` does not cover `imported_classes` at all

Its `TABLES` list is the five catalogs. The class definitions — the largest and
most consequential thing the repo rebuilds — are checked by `drift-check` only
for **existence** ("every published class is creatable from the repo"), and by
nothing for content. The 15 `imported_classes` field differences this audit
found, including F7's duplicated skill restrictions and F11's dead gear
citations, sit outside every automated comparison.

F3 was implemented over the five tables as written and does not close this.

**Proposal:** add `['imported_classes', 'class_id', 'class_id']` to `TABLES`,
comparing `markdown` and `status` and skipping `created_by`, `created_at` and
`updated_at`. A markdown difference should print a line diff rather than two
truncated 40 KB blobs, which is why this is a separate finding and not part of
F3.
**Posture: report, do not fail — same as F3.**

**Taken, 2026-08-28 (PR #382).** Posture held: report, do not fail. Exit code
unmoved, and it still means what it meant — a missing or extra row.

The premises held. `imported_classes` was outside every content comparison, and
adding it surfaces **8 markdown differences across 8 classes** that no tool in
the repo could previously see, including F7's duplicated `except:` entries in
`mystic` and `burster`.

**`created_by` is excluded, as the proposal said, and it was right to.** Its two
differences — `juicer` and `chiang-ku-dragon`, `import` live against
`data-script` in a rebuild — record *how the row got there*, not what it is. A
rebuild saying `data-script` is telling the truth about itself, and reporting it
would be reporting the mechanism as a defect. Total field differences therefore
read **130**, not the 132 a naive all-columns comparison gives. The same
argument is open for `skills.source` under F14 and is not settled here.

**`deleted_at` is compared as presence rather than as a timestamp.** The
proposal named `created_at` and `updated_at` as skips and did not name this one,
so it is compared — but comparing the minute a class was soft-deleted would be
noise, while a class deleted in one database and live in the other is exactly
what this script is for. Zero rows carry one today, in either database.

**Long values are diffed by line**, as the proposal required. Set-based rather
than positional, so a class whose yaml gained one entry reads as one line rather
than as every line after it. Capped at three per side, `--offenders` for all.

**One mistake, and it reached the file before it was caught.** The patch script
that applied this split its replacement blocks on `===` alone, which puts each
block NAME in its own chunk and left every block `undefined`; `String.replace`
then wrote the literal text `undefined` into `repo-vs-live.mjs` four times. It
was caught by running the result — `ReferenceError: TABLES is not defined` — and
the file was restored from `main` rather than hand-repaired. The tooling now
asserts every block parsed and refuses to write a file containing a bare
`undefined`. Recorded because the failure mode is silent in the general case:
had the corruption landed inside a comment rather than a declaration, the script
would have run and quietly compared nothing.

**Measured, 2026-08-28, `node scripts/repo-vs-live.mjs`:**

```
imported_classes repo  126  live  126   names match
   SAME NAME, DIFFERENT VALUE: 8 field(s) across 8 row(s)
     markdown 8
     burster [markdown]
        live | - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"] }
        repo | - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons", ...
```

130 field(s) across 87 row(s), exit 0. **Nothing was repaired**: this finding
was only ever about making the class definitions visible to the comparison. The
8 belong to F7 and to the `retire-gear-placeholders.sql` guard-and-wait cases.

### F13 — export the 38 divergent psionic powers, the way F5 did for gear

Opened by F6, which says the repair is a separate finding per catalog. This is
the largest single cluster left: **114 field values across 38 of the 101 psionic
powers**, measured 2026-08-28 on a build from `main` after F5.

| column | rows | column | rows |
|---|---|---|---|
| `source_book` | 20 | `saving_throw` | 7 |
| `range` | 20 | `isp` | 4 |
| `duration` | 20 | `isp_note` | 4 |
| `description` | 20 | `variant_note` | 2 |
| `system` | 16 | `category` | 1 |

**21 powers rebuild with no `description` at all** against production's one, and
32 with no `source_book` against production's twelve. Healing Touch, Telepathy,
Telekinetic Lift, Mind Bolt, Sixth Sense are among them: `db/seed-catalogs.sql`
creates the row bare and nothing in the remaining 292 files touches it again.
The text is in production and nowhere else.

**Proposal:** export the 38 rows' divergent columns from `--remote` into
`zzzz-restore-psionic-powers-full.sql`, exactly the shape of
[`zzzz-restore-gear-full-columns.sql`](db/zzzz-restore-gear-full-columns.sql):
values taken from production rather than composed, only the columns that
differ, guarded per name, sorting in the `zzzz-` tier. Expected effect —
catalog field differences **230 → ~116**.
**Posture: a new data script. Applied to `--remote` before its merge** — not
because production needs it, but because `drift-check` reports any data script
with no `data_script_runs` row as `DATA SCRIPT NOT RUN` and exits 1. F5's
outcome note has the worked version of this.

**Taken, 2026-08-28 (PR #381).** Posture held: a new data script, `zzzz-` tier,
applied to `--remote` before the merge. Production dumped before and after —
101 rows, **zero field differences, byte-for-byte unchanged**.

**The proposal said "export the 38 rows' divergent columns". Sixteen of those
rows must not be exported, and this is the important part of taking it.**

Those sixteen differ from production in `system` *alone*: production says
`'rifts'`, a rebuild says `NULL`. **The rebuild is right.**
`untag-cross-system.sql` nulls `system` on every psionic power and states that
it is "a DELIBERATE setting decision, not an oversight", adding *"Do not 'fix'
it by tagging these rows from their source_book; that was considered and
rejected"* — because a tag strips the power from Palladium characters. Exporting
production's value would have re-tagged sixteen powers rifts-only and silently
undone it. Found by reading the scripts that write the column before exporting
it, which is the only reason it was found at all.

So `system` is excluded, 22 rows and **98 values** were written rather than 114,
and the divergence that remains is now numbered **F15** — the first finding here
where production is the wrong one. The script's read-back asserts
`powers_tagged_to_one_system = 0` so a rebuild can never acquire the problem.

**One row was a rules call and was read rather than assumed.** `Resist Fatigue`
is `Healing` in production and `Physical` in a rebuild. RUE prints it in **both**
category lists on printed 164 (cache p167) and prints its description in the
**Healing** section on printed 166 (cache p169), which is the page production
cites. Healing taken on that basis, and said in the script's header, because the
catalog holds one category per row and this is a choice rather than a
correction.

**Two mechanical things worth recording.** One value carried an em-dash, which
`d1-apply.mjs` refuses in executable SQL, so the generator now splices any
non-ASCII codepoint as `char(N)` rather than only handling the em-dash case.
And the read-back's `telepathy_has_text` read **0** on this machine's local
database — not a failure: that database holds **81** of the 101 powers and has
no row named `Telepathy` at all. On a fresh build and on production it reads 1.
The comment in the script now says so, because a future reader will hit it.

**Measured, on a database built from nothing:**

| | before | after |
|---|---|---|
| `psionic_powers` field differences | 114 across 38 rows | **16 across 16 rows** |
| all catalogs | 230 | **132** |
| powers with no `description` | 21 | **1** — production's own figure |
| powers with no `source_book` | 32 | **12** — production's own figure |

The sixteen that remain are entirely the `system` column, and closing them means
correcting production, not the repo. That is F15 and it is not taken.

### F14 — export the 25 divergent skills, and read them before assuming enrichment

The other catalog F6 leaves open: **37 field values across 25 of the 336
skills** — `note` 16, `source_book` 10, `source` 8, `base` 1, `per_level` 1,
`level_bonuses` 1.

**Do not treat this as F13 with different nouns.** Sampling it, the differences
are at least three kinds, and one of them is not enrichment at all:

- **Enrichment**, like F13 — `Cook` and `Fishing` hold
  `Palladium Fantasy: 30% +5% per level` in production and NULL in a rebuild.
- **Provenance** — eight rows differ only in `source`, production saying
  `manual` or `import` where the repo says `seed`. That records *how the row got
  there*, and a rebuild saying `seed` is arguably telling the truth about
  itself.
- **A rules disagreement** — `Horsemanship: General` is `base 40, per_level 4`
  in production and `base 35, per_level 5` in the repo, with production also
  citing `Rifts Ultimate Edition p.311` where the repo cites nothing. One of
  those two is wrong about the book, and this audit did not open it.

**Proposal:** read all 37 against the books before exporting any of them, then
export the ones that are genuinely production-is-right. The `source` column may
belong in neither direction — decide explicitly rather than sweeping it.
**Posture: investigate first, then a data script for whatever survives. This one
is not mechanical and should not be taken as if it were.**

**Taken, 2026-08-28 (PR #390).** Posture held exactly: **investigated first, and
only what survived was exported.** All 37 differences were read; **26 are losses
and 11 are not.** Applied to `--remote` before the merge for the reason F5's note
gives; production dumped before and after, 336 rows, **zero field differences.**

**Three could only be settled by opening a book, and two of them reversed the
obvious reading.**

- **`Horsemanship: General`** — this finding called it "a rules disagreement…
  one of those two is wrong about the book", and the book answers plainly. RUE
  printed 311: *"Base Skill: 40%/20% +4% per level of experience."* Production's
  40 and 4 are the book's; a rebuild's 35 and 5 are wrong. **The only rules
  correction in the file.**
- **`SCUBA`** — a rebuild cites RUE p.302-303, production p.317. Printed 302 is
  the Physical skill **list** (*"Swimming (50%+5%) / SCUBA (50%+5%) /
  Wrestling"*); the entry is on 317. Production right.
- **`W.P. Targeting`** — production cites PF Main Book p.84, a rebuild cites
  RUE. PF printed 84 lists the skill inside an **O.C.C.'s skill list** rather
  than defining it, and the skill appears in RUE too. Both defensible, neither
  is the entry. **Left alone** — picking one without reading both books properly
  is how a wrong citation becomes a permanent one.

**The eight `source` differences are not exported, and that is the finding's
main result.** `manual`/`import` live against `seed`/`palladium-fantasy-core` in
a rebuild. The column records **how a row got there**, not what it is, and a
rebuild saying `seed` is telling the truth about itself — the same argument that
excluded `created_by` under F12. Exporting would write "a hand typed this in"
onto a row no hand touched.

`Gymnastics` and `Acrobatics` are also left: production reads *"RUE p.302 lists
varies Also +1D6 S.D.C."* and a rebuild *"Also +1D6 S.D.C.; RUE p.302 lists
varies"* — the same two facts reordered, and **the rebuild's is the one with
punctuation between them.** Closing that diff would make the repo worse.

**One incidental win:** `Botany` cited *"Rifts Skill List"*, the fan compilation
F16 is about. It now cites RUE p.322 — one row off that 48.

**A read-back comment was wrong and was corrected before it shipped:** it
claimed `skills_with_pf_note` would read 26. Twenty-six is the number of VALUES
this file writes, across 22 skills and four columns; the count of skills
carrying a PF note is **15**, which is production's own figure. Caught by
running it.

**Measured on a fresh build: skills differences 37 → 11**, and all eleven are
the deliberately excluded set. Every read-back matches production.

### F15 — production has 16 psionic powers tagged rifts-only against a decision that says they must not be

**The first finding in this audit where PRODUCTION is the wrong one.** Found
while taking F13, by checking a column before exporting it rather than after.

`untag-cross-system.sql` sets `psionic_powers.system = NULL` on every row and
says why, at length:

> This is a DELIBERATE setting decision, not an oversight. NULL means "every
> system" … Do not "fix" it by tagging these rows from their source_book; that
> was considered and rejected

Untagging the Rifts psionics chapter is what makes a major psychic's *"eight
powers from one category"* possible in a Palladium Fantasy campaign at all — the
largest Palladium-visible category held six.

**Sixteen rows in production still carry `system = 'rifts'`.** They reached
production through the importer *after* `untag-cross-system.sql` had run there,
so they were never untagged. A database built from the repo has all 101 correct,
because the script runs at `u` and everything that creates these rows sorts
before it.

```
Restore P.P.E.            Telekinetic Lift          Psionic Invisibility
Stop Bleeding             Telekinetic Push          Psychic Omni-Sight
Ectoplasmic Disguise      Intuitive Combat          Psychosomatic Disease
Mask I.S.P. & Psionics    Read Dimensional Portal   Telekinetic Acceleration Attack
Mask P.P.E.               Remote Viewing            Telemechanic Possession
Group Trance
```

**The effect is live.** A Palladium Fantasy psychic cannot currently pick any of
these sixteen, including Telekinetic Lift, Telekinetic Push and Psionic
Invisibility. `zzzz-restore-psionic-powers-full.sql` deliberately does **not**
export this column, and its read-back asserts `powers_tagged_to_one_system = 0`
so a rebuild can never acquire the problem.

**Proposal:** a data script re-running the untag against the rows that escaped
it — `UPDATE psionic_powers SET system = NULL WHERE system IS NOT NULL` — in the
`zzzz-` tier, applied to `--remote`. It is one statement and it is already
written, in `untag-cross-system.sql`; what it needs is to run again where new
rows have landed since.
**Posture: this one CHANGES PRODUCTION, which nothing else in this audit does.**
The brief's rule was "do not repair production" on the grounds that production is
correct. Here it is not, and that rule was written before this was known — so
this needs a decision rather than an assumption, and it is why this is a finding
rather than a line in F13.

**Worth checking before taking it:** whether the importer should be tagging at
all. Fixing sixteen rows leaves the next import to re-create the problem, and
the durable fix may be in the importer rather than in a data script.

**Taken, 2026-08-28 (PR #391). THE ONLY FINDING IN THIS AUDIT THAT CHANGED
PRODUCTION.** Sixteen live rows moved, deliberately, because production was the
side that was wrong. Every other correction has been repo-side and applied to
`--remote` as a no-op.

**The finding asked whether the importer should be tagging at all. It should
not, and it does not.** The catalog INSERT in
`functions/api/character-creator/_lib/catalog.js` writes
`(name, category, isp, source, source_book)` and never `system`; the column has
no `DEFAULT`, so an imported row is NULL and therefore unrestricted; and no
endpoint `UPDATE`s the column anywhere. **No importer change is needed** — the
durable fix the finding worried about does not exist because the problem is not
there.

**The cause is the ordering bug again, pointing the other way, and
`data_script_runs` names it exactly.** `add-rue-psionics-gap.sql` inserts
sixteen rows with `system = 'rifts'` — sixteen `'rifts'` literals, matching the
sixteen tagged rows one for one. Production's run log:

```
untag-cross-system.sql       first run 2026-08-19 22:37:07
add-rue-psionics-gap.sql     first run 2026-08-22 04:38:12
```

Three days apart, in the wrong order. In a rebuild `add-` sorts under `a` and
`untag-` under `u`, so the untag runs afterwards and catches them — which is why
a fresh build has always had zero. This is the same hand-application hazard the
`zz-` tier was invented for, and the first time it has left **production**
holding the defect.

**Verified against production before and after, not by exit code:** 101 rows
before, 101 after, **16 field values changed and every one of them
`system: 'rifts' → NULL`**. Nothing else in the table moved.

The sixteen: Restore P.P.E., Stop Bleeding, Ectoplasmic Disguise, Telekinetic
Lift, Telekinetic Push, Intuitive Combat, Mask I.S.P. & Psionics, Mask P.P.E.,
Read Dimensional Portal, Remote Viewing, Group Trance, Psionic Invisibility,
Psychic Omni-Sight, Psychosomatic Disease, Telekinetic Acceleration Attack,
Telemechanic Possession — now pickable by a Palladium Fantasy psychic, which is
what `untag-cross-system.sql` decided in the first place.

**With this, `psionic_powers` matches production exactly: 0 differences, down
from 114 when the audit opened.** The script is unconditional and idempotent,
written the way `untag-cross-system.sql` wrote it, so it is a no-op on any
database where the ordering came out right — every rebuild included.

### F16 — the `not-cached` bucket is a provenance problem, not a caching problem

**BLOCKED: waiting on sourcebooks.** Recorded now so the measurement is not
re-done. Opened 2026-08-28 after the assumption behind it turned out to be
wrong twice in one session.

`source-coverage.mjs --remote` reports **51 rows** as `not-cached` — a book the
registry knows and this machine does not hold. Two of the four books had PDFs
sitting in `Downloads`, both text-layer, so the obvious read was "two free OCR
runs close 49 rows". **Neither should be cached.**

| book | rows | what it actually is |
|---|---|---|
| `rifts-skill-list` | 48 | **not a book.** A one-page fan-compiled cross-book index whose entries carry source tags — `(US)`, `(PW)`, `(WOR)`, `(CWC)`, `(JU)`, `(NW)`. |
| `rifts-core` | 1 | **not a missing book.** The ORIGINAL Rifts core book; RUE is its errata'd revision. Same book, earlier edition. See F17. |
| `triax` | 1 | genuinely absent — Triax & The NGR |
| `new-west` | 1 | genuinely absent — Rifts New West |

**Caching `rifts-skill-list` would make the ledger lie.** All 48 skills citing
it were searched against all nine cached books: **zero have a genuine skill
entry.** A `Base Skill:` proximity search reported five and every one
spot-checked was a false positive — `Trap Construction` and `Toxicology` appear
inside *other* skills' entries as bonus lines, `Recognize enchantment` is a
Wizard **O.C.C. ability** in PF printed 107, `Law` was the ordinary word in
prose. Against RUE alone, 42 of 48 appear nowhere at all. Caching the
compilation would flip all 48 from `not-cached` to `traceable` while their
provenance stayed unestablished — exactly what `source-coverage`'s own warning
means by *traceable is CHECKABLE, not correct*.

**Which books they need**, from the tags in the compilation. 38 of 48 map
cleanly; the abbreviations are the compiler's and only the obvious ones are
expanded here:

| tag | n | skills |
|---|---|---|
| `US` (Underseas) | 5 | Boat: Submersibles, Navigation: Underwater, Submersible Vehicle Mechanics, Undersea & Sea Survival, Undersea Farming |
| `MH` | 5 | Doctor of Veterinary Medicine, Geology, Physics, Space: Antigrav Suit, Space: Radio: Deep Space |
| `PW` (Phase World) | 5 | Navigation: Stellar, Space: Small Spacecraft, Space: Space Fighter, Space: Spacecraft Mechanics, Space: Starship |
| `MIO` (Mutants in Orbit) | 3 | Cyberjacking, Space: Defense Systems, Space: Satellite Systems |
| `WOR` (Warlords of Russia) | 3 | Falconry, Language: Mongolian, Wingrider Flying Wing |
| `CWC` (Coalition War Campaign) | 3 | Radar/Sonar Operations, Streetwise: Drugs, Trap Construction |
| `JU` (Juicer Uprising) | 2 | Air Assault Armor, Juicer Technology |
| `NB` (Nightbane) | 2 | Strategy/Tactics, Toxicology |
| `MERC`, `MC`, `NW`, `PF` | 1 each | Combat Pod; Language Dialects; Law; Locate Secret Compartments |
| untagged | 6 | Navigation: Terrestrial, Ocean Geographic Surveying, Recognize Enchantment, Recognize Wards Runes & Circles, Space: Extra-Vehicular Activity, Space: Oxygen Conservation |
| unmapped | 10 | Antiquarian, Ice Skating, Language: Trade Five/Reptile, Language: Trade Six, Lore: Astral, Lore: Galactic/Alien, Lore: Nightbane, Lore: Nightlands, Lore: Vampires, Snow Skiing |

**The tags are a lead, not a citation.** `Air Assault Armor` and
`Juicer Technology` are tagged `(JU)` and Juicer Uprising **is** cached, yet
neither has an entry there — so either the book prints them under another name
or the tag is wrong. Each row still needs the three-readings treatment when its
book arrives.

**Proposal:** hold. When books land, cache each under the slug the registry
already uses, then re-cite the affected rows by page. Do **not** register the
compilation as a book; if anything, retire the `rifts-skill-list` registry entry
once its rows have real citations, since its only job was to keep 48 rows out of
the `unknown-book` bucket.
**Posture: blocked, no action. This finding exists so the negative result is not
re-derived — two plausible OCR runs were about to be spent on it.**

### F17 — `dragon-hatchling` still cites the pre-RUE edition, alone among its seven

Actionable now; **not** blocked on F16.

`rifts-core` is the original Rifts core book and **RUE is its errata'd
revision**. Exactly one row cites it:

```
dragon-hatchling                 Rifts RPG (original core book) p.98-101
dragon-hatchling-cats-eye        Rifts Ultimate Edition p.159-160
dragon-hatchling-flame-wind      Rifts Ultimate Edition p.160-161
dragon-hatchling-forest-runner   Rifts Ultimate Edition p.161-162
dragon-hatchling-royal-frilled   Rifts Ultimate Edition p.161-162
dragon-hatchling-snow-lizard     Rifts Ultimate Edition p.162-163
dragon-hatchling-whip-tailed     Rifts Ultimate Edition p.163
```

All six variants were re-done from RUE and the parent was left behind — the
same pre-RUE residue `fix-pre-rue-class-audit.sql` and
`fix-class-skill-names-to-rue.sql` exist to clear. RUE carries the material:
printed 157-159 holds the generic Dragon Hatchling R.C.C. text — lifespan,
alignment, hatchling size, magic knowledge — and `Cat's-Eye Dragon Hatchling`
begins on printed 159, which is exactly where its variant's citation starts.
Read from the cache, not recalled.

**Proposal:** re-cite `dragon-hatchling` to RUE, pinning the range by the
three-readings method rather than by the approximate 157-159 above. A one-
statement data script in the `zzzz-` tier, guarded on the old string.
Separately, correct the `rifts-core` note in `scripts/books.json`, which is
wrong twice: it says *"Cited by two published classes"* (one does —
`rifts-priest` matches on prose, its `source_book` is Pantheons) and *"this is
the next book to cache, not a missing one"* (it should not be cached at all).
**Posture: a data script plus a registry-note correction. Production carries the
same stale citation, so this one DOES change production — it is a repair to a
citation, not to a rule, but say so when taking it.**

Takes `not-cached` from 51 to 50 and `rifts-core` to zero rows citing it.

**Taken, 2026-08-28 (PR #393).** Both halves — the data script and the registry
note. **This changed production**, as the posture said it would: one class, one
column.

**The three readings, done rather than approximated.** This finding warned
against the "approximate 157-159" it carried, and it was right to — the answer
is **156-159**:

1. **Table of contents.** Four separate entries, on printed 5, 6 and 7, all
   giving the same page: *"Dragon Hatchling … 156"*, *"Dragon Hatchlings: …
   156"*, *"The Dragon Hatchling has psionics & magic: … 156"*, *"Dragon
   Hatchling R.C.C. … 156"*.
2. **The body heading agrees.** Printed 156 opens with the heading *Dragon
   Hatchling*.
3. **The entry's extent.** The R.C.C. material runs through 157 and 158 —
   *Alignments*, *R.C.C. (Racial Character Class)*, *Magic Knowledge* — and its
   tail, *Hatchling's Size*, sits at the top of printed **159**, where
   *Cat's-Eye Dragon Hatchling* then begins. The generic section therefore
   **shares 159 with the first variant**, which is exactly why that variant
   cites 159-160.

Four pages, as the `p.98-101` it replaces was. The seven now form one
contiguous run, 156 through 163.

**Verified against production before and after:** 126 classes before, 126 after,
**one field value changed** — `dragon-hatchling.markdown` — and `updated_at`
moved on that row alone.

**The registry note was wrong twice and is corrected.** It claimed *"Cited by
two published classes"* (one did — `rifts-priest` matched a grep on prose, its
`source_book` is Pantheons) and *"this is the next book to cache, not a missing
one"* (it should not be cached at all). The replacement states what
`rifts-core` actually is — the original edition RUE revises — and that nothing
cites it. The entry is **kept** rather than deleted so the spelling stays known
vocabulary if it reappears. `books.json` was re-parsed before writing; a
registry three mechanisms read is not a file to leave syntactically doubtful.

**Ledger effect, `source-coverage.mjs --remote`:** classes go to **126
traceable, 0 not-cached** — every published class is now traceable — and the
`not-cached` bucket drops **51 → 50**, with `rifts-core` gone from it entirely.
The remaining 50 are the 48 F16 is about plus `triax` and `new-west`.

**One check read 6 where the comment says 7, and it was the local database
again**, not the script: this machine's dev D1 has no `dragon-hatchling` row at
all. On a fresh build and on production it reads 7. The same drift that made
F13's `telepathy_has_text` read 0.

### F18 — the 64 gear values a rebuild still loses, and the four it would wrongly overwrite

The largest remaining cluster, and a **different population from F5's**:
measured 2026-08-28 on a build from `main`, **64 values across 33 rows**, and
**none of them is on a row `restore-gear-missing-from-repo.sql` creates.** F5
closed those 193 completely. These are ordinary catalog rows enriched through
the editor — F6's gap, gear's share of it.

| column | n | column | n |
|---|---|---|---|
| `cost` | 18 | `source_book` | 12 |
| `cost_note` | 15 | `category` | 4 |
| `description` | 12 | `system` | 2 |
| | | `weight_lbs` | 1 |

**Mostly mechanical.** The `cost`, `cost_note`, `description` and most
`source_book` differences are production holding a value where a rebuild holds
`NULL` — `pen` costs 1 credit, `sleeping-bag` carries `110-160 cr.`,
`note-pad` cites RUE p.261-265, and a rebuild knows none of it.

**Two small groups are not, and one would do damage:**

- **`category` (4) runs the OTHER WAY.** `hand-held-blood-pressure-machine`,
  `unbreakable-vial`, `medical-bag` and `poncho` are `NULL` in production and
  `'gear'` in a rebuild. Exporting production here would **delete a category a
  rebuild correctly has.** F13 hit the same shape with `system` and the answer
  was to exclude the column; this needs the same read before anything is
  written.
- **`system` (2) and two `source_book` rows are both-non-null disagreements.**
  `first-aid-kit` and `bandages-6-foot-1-8-m-roll` are `both` live and `rifts`
  in a rebuild — production is broader and probably right, but that is the
  `untag-cross-system` question again and deserves the same care. `ca-1-` and
  `ca-2-heavy/light-dead-boy-armor` cite RUE p.261-265 live against
  `Web reference (not book-verified)` in a rebuild, where production is plainly
  the better citation.

**Proposal:** the F14 treatment, not the F5 treatment. Read the 8 non-`NULL`
cases first and decide each; export the rest — production's values, only the
columns that differ, guarded per slug, `zzzz-` tier. Expected effect: catalog
field differences **86 → about 30**.
**Posture: investigate the eight, then a data script for whatever survives.
Applied to `--remote` before its merge, per F5's note. NOT mechanical, despite
how it looks.**

**Taken, 2026-08-28 (PR #396).** Posture held: investigated first, and the
non-mechanical cases decided one at a time. **Gear differences 64 → 4**, and the
four that remain are the four this finding predicted must not be touched.
Catalogs overall **81 → 21 across 20 rows.** Applied to `--remote`; production
dumped before and after, 975 rows, **zero field differences.**

**This finding said "read the eight non-NULL cases first". There are
TWENTY-FOUR.** It counted `category`, `system`, `source_book` and `weight_lbs`
and missed that `description` (11) and `cost` (8) disagree too. All 24 were
read. Twenty exported, four not.

**The four not exported, and the reason is the whole point of the finding.**
`hand-held-blood-pressure-machine`, `unbreakable-vial`, `medical-bag` and
`poncho` have `category` NULL live and `'gear'` in a rebuild — **the rebuild is
right.** `fix-body-fixer-page-break.sql` inserts them with no category, and
`zzz-gear-tidy-3-categories.sql` ends with an unconditional
`UPDATE gear SET category = 'gear' WHERE category IS NULL`. In a rebuild the
insert sorts under `f` and the tidy under `zzz`. On production the two were
applied **three hours apart in the other order**:

```
zzz-gear-tidy-3-categories.sql   16:12:11
fix-body-fixer-page-break.sql    19:12:19    (both 2026-08-25)
```

Exporting production's NULL would have deleted a category a rebuild correctly
has. **A third table with the same hand-application hazard as F15 and F19** —
and correcting production for it belongs with F19, not here.

**The eight `cost` disagreements turned out to be a convention, and the book
settled it.** Production stores the LOW END of a published range in `cost` and
the range in `cost_note`; a rebuild carries only the top, with no note. In all
eight the repo's figure is exactly production's upper bound. RUE printed 261
prints *"Black Market Price: 35,000 to 45,000 with a custom paint job"* under
**Features Common to All "Dead Boy" Armor** — a shared floor for both suits,
which is why production holds 35,000 for each against a rebuild's 40,000 and
70,000 taken from a web reference.

The 11 `description` disagreements are a rebuild's
`STUB - split out of a choice or bundle row` against real prose. The 2 `system`
rows are the class importer's stub tag against a considered per-item call.

**A smoke check caught something the audit had not, and it took two attempts to
satisfy.** `zzzz-restore-gear-values.sql` **assigns**
`source_book = 'Web reference (not book-verified)'` to `tinted-goggles`, and the
suite requires any script writing that marker to declare it in its header —
because otherwise the provenance lives in the database and nowhere in the repo.
The first fix added the declaration and still failed: the check reads
`text.split('UPDATE')[0].split('INSERT')[0]`, and this header **quotes an
`UPDATE` statement** while explaining the category case, so everything after
that quote is invisible to it. The declaration had to move above the quote.
**A header that explains SQL truncates its own machine-readable half.**

### F19 — the six classes where the REBUILD is ahead of production

The mirror of every other finding here, and the second one that would change
production. Six classes' markdown differs; in **four** of them the rebuild holds
the corrected value and production holds the placeholder.

- **`body-fixer`, `rogue-scientist`, `wilderness-scout`, `rifts-priest`** —
  production still carries `- { item_id: "light-mdc-body-armor", qty: 1 }`; a
  rebuild carries the resolved `choose:` block enumerating real armour slugs.
  `retire-gear-placeholders.sql` is the guard-and-wait script that does this,
  and it **ran on production before the options existed**, found nothing, and
  correctly did nothing. Nobody re-ran it. In a rebuild the options are there by
  the time it runs. **Production is behind by exactly one no-op.**
- **`coalition-samas-pilot`** — production has one merged
  `air-filter-and-gas-mask`; a rebuild has `air-filter` and `gas-mask`
  separately. All three slugs exist in both databases, so this is a content
  choice rather than a missing row, and it is **not** obvious which is right.
- **`wizard`** — one word of prose in `extraction_notes`: *"stated as **the**
  fifth starting group"* live against *"stated as **a** fifth starting group"*.
  Cosmetic, and worth naming only so nobody spends an afternoon on it.

**Proposal:** re-run `retire-gear-placeholders.sql` against production, which is
what its own guard was written to allow — it is idempotent and does nothing
where the swap has already happened. Decide `coalition-samas-pilot` on the book.
Leave `wizard`.
**Posture: this CHANGES PRODUCTION, like F15, and for the same kind of reason —
a script that ran too early. It needs a deliberate yes, not a queue position.**

### F20 — five spells missing their Palladium Fantasy P.P.E. variant

The smallest thing left and the most mechanical. Five `variant_note` values,
`NULL` in a rebuild and present in production, all the same shape:

```
Impervious to Fire    Palladium Fantasy: 6 P.P.E.
Resist Fire           Palladium Fantasy: 3 P.P.E.
Blind                 Palladium Fantasy: 8 P.P.E.
Fire Bolt             Palladium Fantasy: 10 P.P.E.
Energy Disruption     Palladium Fantasy: 15 P.P.E.
```

Pure F6 enrichment — typed into the catalog editor, never written back. No
column runs the other way, no citation is in dispute, nothing needs a book.

**Proposal:** export the five, exactly the shape
`zzzz-restore-psionic-powers-full.sql` used. One statement per spell.
**Posture: a data script, mechanical, applied to `--remote` before its merge.
Takes `spells` to zero.**

**Taken, 2026-08-28 (PR #395). `spells` is at zero** — the third table to reach
it, after `psionic_powers` and `catalog_redirects`. Applied to `--remote` before
the merge; production dumped before and after, 607 rows, **zero field
differences**.

The finding was right that this one is mechanical: five values, all the same
shape, nothing running the other way, no citation in dispute, no book opened.

**Two figures in the script's own comments were invented and both were replaced
with measured ones before it shipped.** The header claimed
`backfill-spell-ppe-notes.sql` was "where the other 57 came from" — that script
contains a single `UPDATE` and is not where they came from — and the read-back
comment predicted `spells_with_a_pf_variant` would read **62**. The real figures:
**production 14, a rebuild 9, and these five are the whole of the difference.**
Caught by querying production before trusting the sentence, which is the only
reason it did not ship as a confident wrong number in a file nobody re-reads.

That is the third time in this audit a read-back comment has been wrong while
the SQL beneath it was right — F11's `classes_rewired`, F14's
`skills_with_pf_note`, and now this. **The statements get checked because they
run; the comments only get checked if someone runs them and compares.** Worth
saying plainly: a data script's prose is the least-verified thing in it.

**Measured:** spells differences **5 → 0** on a fresh build, and the catalogs
overall **86 → 81 across 49 rows**. What remains is F18's 64 in gear, F19's 6 in
classes, and F14's 11 deliberately-excluded skills.

---

## The question the brief asked

**"Is 'rebuild from the repo' a capability this project actually has, or a
belief?"**

**It is a real capability with an overstated scope and one measured blind spot.**

What is genuinely true and was verified today: a fresh build **completes**,
produces the **right set of rows** in every catalog (2,081 of them, names and
counts exact), rebuilds **all 126 published classes**, and reaches the counts
the regression test pins. The `zzzz-` fix works. The bookkeeping is honest. Two
tools in the repo already do this and both pass. That is more than most projects
of this size have, and it was not luck — it is the `restore-*` scripts, the
prefix tiers and `repo-vs-live.mjs`, each bought with a specific past failure.

What is belief: that matching names means matching rows. **428 field values and
22 rows diverge under a green check**, and the differences are not cosmetic —
24 weapons lose mega-damage, 38 psionic powers lose their text and citation, 37
rows lose their `source_book` entirely, and two classes gain duplicated skill
restrictions. A database rebuilt from this repo today would run, serve every
class, and be quietly wrong about what a Boom Gun does.

**Is it worth fixing? Partly — and the split is not where the brief expected.**

The ordering machinery is in good shape. Three escalations, three documented,
and the fourth consequence found today (F7) affects three lines in two classes.
That is a maintained system, and the case for more process around it is weak.

The two findings worth taking are the ones that are **not** about ordering. F5
is bounded, mechanical and high-value: one re-export, 198 differences closed,
24 weapons fixed, no production change. F3 is what stops the next one being
found by accident — extending the existing comparison from names to columns,
reporting rather than failing, so the number is visible without anyone deciding
to look.

The rest is documentation. F9 in particular: the most expensive
misunderstanding available here is not a missing column, it is someone
believing the repo is a backup. It is not, production is backed by Cloudflare,
no rebuild has ever been needed, and **"do not fix, document the limitation" is
the right answer for F6, F8 and F9.** Closing F6 properly would mean writing
back every app edit to a data script forever — a discipline this repo has
already tried and lost twice — and the alternative is to say plainly that the
catalog editor's writes live in D1 and only in D1.

---

## Not covered

- **Whether production's values are correct.** This compares the rebuild to
  production and treats production as the reference, as the brief instructed.
  Where they differ, F5/F6/F7 say which side the repo would move — not which
  side the book supports. The four `light-mdc-body-armor` classes are the case
  to watch: there the **rebuild** carries the resolved `choose:` block and
  production still carries the placeholder `item_id`, because
  `retire-gear-placeholders.sql` ran on production before its options existed
  and no-opped. That may mean production is behind, not the rebuild. Unaudited.
- **The other apps' tables.** `media_items`, `ff_*` and `claude_usage` were
  counted for F9 and not otherwise examined.
- **`spells`.** Five `variant_note` differences, all on rows nothing else
  touches. Noted, not chased.
- **Whether `d1-apply.mjs`'s per-file cost can be reduced** without giving up
  isolation. F10 sidesteps it rather than solving it.
