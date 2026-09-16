# Rebuild audit — what a fresh build of this database actually breaks

> **Since 2026-09-16 the closed findings live in `REBUILD-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **All 20 findings (`F1`–`F20`) are closed**, re-verified on 2026-09-02.
>
> **The one that misreads:** `F16` has no `Taken` note and is not open. It ends
> *"Posture: blocked, no action. This finding exists so the negative result is
> not re-derived"* — a deliberate dead end, recorded so two plausible OCR runs
> are not spent rediscovering it.

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

- **F1** — `d1-apply.mjs` honours `-- local-only` under `--remote` only — Taken, 2026-08-28 (PR #385). The premise held: the skip did live inside — full text in `REBUILD-AUDIT.closed.md` under its own `### F1` heading.

- **F2** — `README.md:769` names one file where 27 now sort after `seed-dev.sql` — Closed as moot, 2026-08-28 (PR #385) — not taken. F1 changed the behaviour — full text in `REBUILD-AUDIT.closed.md` under its own `### F2` heading.

- **F3** — nothing pins the rebuild's row *contents*, so this class of regression is invisible — Taken, 2026-08-28 (PR #377). Posture held: report, do not fail. A missing or — full text in `REBUILD-AUDIT.closed.md` under its own `### F3` heading.

- **F4** — the citation comparison counted one bucket, so a total loss read as an improvement — Taken, 2026-08-28 (PR #386). Posture held: measurement only, no data change, — full text in `REBUILD-AUDIT.closed.md` under its own `### F4` heading.

- **F5** — `restore-gear-missing-from-repo.sql` exports 6 of gear's 18 columns — Taken, 2026-08-28 (PR #379). The premises held — 193 field values across 53 — full text in `REBUILD-AUDIT.closed.md` under its own `### F5` heading.

- **F6** — the app writes rows the repo has no mechanism to capture, and 38 psionic powers are bare because of it — Taken, 2026-08-28 (PR #380). Posture held: documentation only. No data — full text in `REBUILD-AUDIT.closed.md` under its own `### F6` heading.

- **F7** — `fix-class-skill-names-to-rue.sql` still defeats a later `fix-` script, and the `zz-` remedy creates a duplicate — Taken, 2026-08-28 (PR #383). Both halves — the data script and the — full text in `REBUILD-AUDIT.closed.md` under its own `### F7` heading.

- **F8** — 22 `catalog_redirects` rows exist only in production — Taken, 2026-08-28 (PR #387) — the reporting half only. The export is still — full text in `REBUILD-AUDIT.closed.md` under its own `### F8` heading.

- **F9** — "rebuild from the repo" has never meant "restore production", and nothing says so — Taken, 2026-08-28 (PR #388). Posture held: documentation only. No tooling, — full text in `REBUILD-AUDIT.closed.md` under its own `### F9` heading.

- **F10** — the fast rebuild harness is worth keeping — Taken, 2026-08-28 (PR #389). Posture held: new tooling, opt-in, no test — full text in `REBUILD-AUDIT.closed.md` under its own `### F10` heading.

- **F11** — a fresh build cites 10 gear slugs that do not exist; production cites 0 — Taken, 2026-08-28 (PR #378). Both halves — the data script and the test — full text in `REBUILD-AUDIT.closed.md` under its own `### F11` heading.

- **F12** — `repo-vs-live.mjs` does not cover `imported_classes` at all — Taken, 2026-08-28 (PR #382). Posture held: report, do not fail. Exit code — full text in `REBUILD-AUDIT.closed.md` under its own `### F12` heading.

- **F13** — export the 38 divergent psionic powers, the way F5 did for gear — Taken, 2026-08-28 (PR #381). Posture held: a new data script, `zzzz-` tier, — full text in `REBUILD-AUDIT.closed.md` under its own `### F13` heading.

- **F14** — export the 25 divergent skills, and read them before assuming enrichment — Taken, 2026-08-28 (PR #390). Posture held exactly: investigated first, and — full text in `REBUILD-AUDIT.closed.md` under its own `### F14` heading.

- **F15** — production has 16 psionic powers tagged rifts-only against a decision that says they must not be — Taken, 2026-08-28 (PR #391). THE ONLY FINDING IN THIS AUDIT THAT CHANGED — full text in `REBUILD-AUDIT.closed.md` under its own `### F15` heading.

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

- **F17** — `dragon-hatchling` still cites the pre-RUE edition, alone among its seven — Taken, 2026-08-28 (PR #393). Both halves — the data script and the registry — full text in `REBUILD-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — the 64 gear values a rebuild still loses, and the four it would wrongly overwrite — Taken, 2026-08-28 (PR #396). Posture held: investigated first, and the — full text in `REBUILD-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — the six classes where the REBUILD is ahead of production — Taken, 2026-08-28 (PR #397). Posture held: this changed production, on a — full text in `REBUILD-AUDIT.closed.md` under its own `### F19` heading.

- **F20** — five spells missing their Palladium Fantasy P.P.E. variant — Taken, 2026-08-28 (PR #395). `spells` is at zero — the third table to reach — full text in `REBUILD-AUDIT.closed.md` under its own `### F20` heading.

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
