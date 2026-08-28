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
