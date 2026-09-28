# Rebuild audit — what a fresh build of this database actually breaks

> **Since 2026-09-16 the closed findings live in `REBUILD-AUDIT.closed.md`**, moved
> there verbatim with their headings, numbering and notes; this file keeps a
> one-line pointer per moved finding where its heading was, and holds in full
> every finding whose own section records no outcome. The closed file is a
> record like this one, and the `*AUDIT*.md` glob reaches both.

> **All 20 findings (`F1`–`F20`) are closed**, re-verified on 2026-09-02.
>
> **Added 2026-09-25: four findings after `F20`, filed open.** Read under each
> heading for its state; the line above was true on its own date.
>
> **Added 2026-09-27: `F25` and `F26`, filed open** while taking `F21` and
> `F23`. Read under each heading.
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

**Adjusted 2026-09-27.** Books this finding waited on have landed since, so the
numbers above are the 2026-08-28 record and these are that day's, from
`node scripts/source-coverage.mjs --remote` (2026-09-27, 28 of 30 registered
books cached):

| | 2026-08-28 | 2026-09-27 |
|---|---|---|
| `not-cached`, all tables | 51 | **30** |
| `rifts-skill-list` | 48 | **29** |
| `triax` | 1 | **0** — cached and imported |
| `new-west` | 1 | **0** — cached and imported |
| `rifts-core` | 1 | **1**, a different row: `gear.Northern Gun Sky King` (the original row was re-cited by `F17`, PR #393) |

The `rifts-skill-list` rows left one at a time, re-cited by page as their books
were cached, which is this finding's proposal working as written.

**What the trigger allows now.** `nightbane-core` is cached, and a plain-text
search of its cache on 2026-09-27 finds four of the remaining names on cache
pages `p049` and `p053`: `Strategy/Tactics`, `Toxicology`, `W.P. Revolver`,
`W.P. Automatic Pistol`. Five more are placed on that book's skill list by a
session-memory note (**reported, not re-checked here**) and were not found as
plain strings; each needs reading off the page. The rest need books this
machine does not hold.

**Still held, posture unchanged.** Re-citing the rows the cached books can now
answer is a data PR, taken on Nate's word with the three-readings check this
finding asks for.

**Corrected 2026-09-27, the same day.** The paragraph before the last named two
rows that were not remaining: `Strategy/Tactics` and `Toxicology` already cite
`Nightbane RPG p.52` (read `--remote` 2026-09-27). The names the search found are
the book's skill list; the definitions are on cache `p060`, printed 59.

**Taken in part, 2026-09-27 (branch `pal/data/rebuild-audit-f16-nightbane-wp`),
on Nate's word.** Four `rifts-skill-list` rows now cite `Nightbane RPG p.59-60`
by `~037-nightbane-wp-citations.sql`: `W.P. Revolver`, `W.P. Automatic Pistol`,
`W.P. Bolt Action Rifle` and `W.P. Automatic and Semi-automatic Rifles`. The
three readings held: printed 59 defines each, printed 60 prints the aimed,
burst and per-level bonuses the rows store, and no other cached book defines
any of the four. The premise audit before scoping found the two rifle rows the
first plan left out, and a stored note on `W.P. Automatic Pistol` that described
a semi-automatic where printed 59 defines a weapon that keeps firing while the
trigger is held; that sentence is rewritten to the page. This reverses
`fix-wp-source-pre-rue-citations.sql`'s choice of the non-book (INGESTION-AUDIT
F25) for these four, whose reason was that no cached book defined them.
`rifts-skill-list` goes from 29 rows to 25. **The rest of this finding stays
held**: the remaining rows need books this machine does not hold, or reading
off pages not yet checked.

**Taken further, 2026-09-27 (branch `pal/data/rebuild-audit-f16-f25-f26`), on
Nate's word**, which also approved bundling this with `F25` and `F26` and
taking held items. Three more rows now cite a page, by
`~040-rifts-skill-list-recitations.sql`, applied `--remote` before the PR:

| row | now cites | the page prints | stored |
|---|---|---|---|
| `Juicer Technology` | `Rifts World Book 10: Juicer Uprising p.65` | *Medical: Juicer Technology*, 40%+5% | Medical 40/5 |
| `Radar/Sonar Operations` | `Rifts World Book 11: Coalition War Campaign p.66` | *Pilot Related: Radar/Sonar Operations (Read Sensor Equipment)*, 30%+5% | Pilot Related 30/5 |
| `Falconry` | `Palladium Fantasy RPG Main Book p.54` | under *Military*, 30%+5% | Military 30/5 |

The three readings held for each. Each page was read off a render as well as
the cache, with its folio read at the foot of the page. The stored category,
base and per-level match. A search of every page of all 28 caches for each of
the 25 names found no other definition of these three. RUE prints no Juicer
Technology entry (its list at printed 303 has Flight System Combat, Jump Bike
Combat and Lore: Juicers). RUE printed 320 files *Radar/Sonar Operation* as a
pointer to Sensory Equipment, not a definition. `rifts-skill-list` goes from
25 rows to **22** (`source-coverage.mjs --remote` before and after, in the PR
body). Posture held: a data PR on Nate's word, with the three-readings check.

**Two corrections to this finding's own premises.** Both were found by the
premise audit before scoping.

- **The tag table's `US` and `PW` rows were not waiting on those books.** All
  five `US` rows moved to Underseas in #798 (2026-09-07). Four of the five `PW`
  rows moved to Phase World in #403, with four more names the table lists as
  untagged or unmapped. The one left is `Space: Spacecraft Mechanics`. It
  stores 20%+5% where Phase World printed 150 prints *Spaceship Mechanics* at
  22%+5%, so it fails the second reading. The phase-world survey records
  leaving it alone on purpose. **It stays held.**
- **The tag table's `JU` row was wrong about Juicer Technology.** The
  2026-08-28 note says Juicer Uprising has no entry for it. Printed 65 does,
  and it is re-cited above. `Air Assault Armor`, the other `JU` row, is
  still defined nowhere in the caches.

**Still held, and why.** Twenty-two rows, each against the reading that failed:

- **Defined in two cached books.** `Trap Construction` is defined at 20%+4%
  by Coalition War Campaign printed 62 and New West printed 75, which fails
  the third reading. CWC's own skill list (printed 59) marks it *(new)*, and
  CWC is the earlier world book. Choosing between the two is a call for
  Nate, not this check.
- **The page disagrees with the row.**
  - `Space: Spacecraft Mechanics`, above.
  - `Locate Secret Compartments`: PF printed 57 prints 15%+5% against the
    stored 20. The row's note already records the PF figure.
- **Defined in no cached book.** The other nineteen:
  - `Air Assault Armor`, `Antiquarian`, `Combat Pod`, `Cyberjacking`,
    `Doctor of Veterinary Medicine` (RUE's *Veterinary Science* is 50%+4%,
    a different skill)
  - `Geology`, `Ice Skating`, `Language Dialects`, `Language: Mongolian`,
    `Lore: Astral`
  - `Navigation: Terrestrial`, `Physics`, `Snow Skiing`,
    `Space: Antigrav Suit`, `Space: Defense Systems`
  - `Space: Oxygen Conservation`, `Space: Radio: Deep Space`,
    `Space: Satellite Systems`, `Wingrider Flying Wing`

  Each hit the search found was prose, a class skill list, a psionic power or
  a super ability. The workshop's `books` directory holds PDFs that are not
  cached (Lemuria, Xiticix Invasion and others). They were not searched, and a
  future cache is this finding's trigger again.

- **F17** — `dragon-hatchling` still cites the pre-RUE edition, alone among its seven — Taken, 2026-08-28 (PR #393). Both halves — the data script and the registry — full text in `REBUILD-AUDIT.closed.md` under its own `### F17` heading.

- **F18** — the 64 gear values a rebuild still loses, and the four it would wrongly overwrite — Taken, 2026-08-28 (PR #396). Posture held: investigated first, and the — full text in `REBUILD-AUDIT.closed.md` under its own `### F18` heading.

- **F19** — the six classes where the REBUILD is ahead of production — Taken, 2026-08-28 (PR #397). Posture held: this changed production, on a — full text in `REBUILD-AUDIT.closed.md` under its own `### F19` heading.

- **F20** — five spells missing their Palladium Fantasy P.P.E. variant — Taken, 2026-08-28 (PR #395). `spells` is at zero — the third table to reach — full text in `REBUILD-AUDIT.closed.md` under its own `### F20` heading.

**Added 2026-09-25**, after PRs #1352, #1353 and #1354 reconciled every offender
`repo-vs-live.mjs --offenders` reported (31 fields; the tool printed "The repo
rebuilds the live catalog exactly" for every table on 2026-09-24, `--remote`).
Those PRs are the evidence below; the four findings are what they left behind.
One of them went past a decision recorded here and says so: #1354 set
production's `wizard` extraction note to the repo's text, where `F19` said
*"Leave `wizard`"* about a one-word difference. By 2026-09-24 the two versions
differed by two sentences, the repo's being the file that merged
(`zzz-wizard-the-seventh-spell-pick.sql`).

### F21 — medium — `fix-fq-deep-intel-agent-pb-cap.sql` inserts with no guard, and ran twice live

Its first `UPDATE` (lines 26-32) replaces the `attribute_requirements` block
with itself plus `attribute_maximums: { PB: 12 }`, filtered on `class_id` alone.
Run a second time it inserts the key again. Production held the key **twice**
until #1354 removed the duplicate (dumped `--remote` 2026-09-24; the rebuild
held it once). The parser read the same value twice, so nothing visible broke.
The next re-run would add it back.

**Proposal:** add `AND instr(markdown, 'attribute_maximums:') = 0` to that
statement. Then do one read-only sweep of `db/*.sql` for the same shape (a
`replace()` whose replacement contains its own search string, filtered on the
key alone) and list what it finds in the outcome note. Fix nothing else in this
PR; each hit gets its own number or is dropped in writing.
**Posture:** repo-only. Adding a guard changes no row in either environment, so
nothing is applied.
**Evidence:** the duplicate was measured `--remote` 2026-09-24. That the
statement is unguarded comes from reading lines 26-32 on 2026-09-25. The sweep
has **not** been run, and how many files share the shape is unknown.
**Confidence:** high on this file. Unknown on the sweep until someone runs it.
**Ongoing cost:** none.

**Taken, 2026-09-27 (branch `shared/audit/rebuild-audit-f21-f24`).** Posture
held: repo-only. Nothing was applied, and the guard changes no row in either
environment. The first `UPDATE` of `fix-fq-deep-intel-agent-pb-cap.sql` (now
lines 29-36) carries `AND instr(markdown, 'attribute_maximums:') = 0`. It is
safe on a first apply: `add-fq-deep-intel-agent-class.sql` contains no
`attribute_maximums` at all (`grep -c`, 2026-09-27: 0), and step 3's note
writes `attribute_maximums.` with a period, which the colon does not match.
Proved on an in-memory SQLite built from `db/schema.sql` and the class import,
then the fix run twice: the committed file held the key 0, 1, then 2 times; the
guarded file 0, 1, then 1.

**Correction to the heading: "ran twice live" was inferred, not measured.**
`data_script_runs` holds one row for this file, at 2026-09-08 16:03:27
(`q.mjs --remote`, 2026-09-27). The duplicate key production held was real, and
#1354's `zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql` removed it (its lines
97-101). How it came to be there twice is not established.

**The sweep.** A scratch parser (not committed) read every `UPDATE` in
`apps/character-creator/db/*.sql` (1,038 files), `db/*.sql` and
`db/migrations/*.sql`. It evaluated each `replace()` whose arguments are
literals and `char()`: 2,097 calls, 4 not evaluable, all four in
`zzzzzzzzz-f59-per-level-lists.sql`. Those were read by hand, and each
replaces its search string away. It kept the 851 whose replacement contains its
own search string. 841 of those carry an `instr(…) = 0` on text the replacement
writes. `db/` and `db/migrations/` held none. The other 10, read by hand:

- this file, line 29: the finding itself.
- `fix-merc-soldier-and-robot-pilot-mos.sql`, 7 statements: **not the shape.**
  A marker chain, guarded at its head (the statements at lines 47 and 156) on the `mos:`
  block the chain's last step writes.
- `retire-leather-armor-placeholder.sql:56`: **not the shape.** The same
  statement's inner `replace()` removes the `leather-armor` item it is guarded
  on, so a second run matches nothing.
- `~011-borrowed-xp-ladders.sql:136`: **the shape.** Filed as `F25`, below.
  Production is clean.

### F22 — low — `light-mdc-body-armor` outlived its purpose, and nothing cites it now

`fix-category-gear-rows.sql` step 4 deletes the four category placeholders
(`light-`, `heavy-`, `mdc-body-armor`, `ns-turbo-cyclone`) once no live class
and no inventory row points at them. Three are gone from both production and a
rebuild. `light-mdc-body-armor` survived because `sea-inquisitor` still cited
it live, and #1354 converted that class to the choice block the other 29
classes carry. On 2026-09-25, `--remote`: **0** classes cite it, **0**
`character_items` rows hold it, and **0** `catalog_redirects` point from it.
The row's description ("Unspecified light Mega-Damage body armour...") is
`zzz-gear-tidy-2-stub-stats.sql`'s stopgap for while it was still cited. It is
not an item.

**Proposal:** a data script that sorts last, repeating step 4's `DELETE` for
this slug under the same two `NOT EXISTS` guards, applied `--remote` before the
merge. It cites `Estimate - no published price found`, which is no surveyed
book, so the "rows citing no surveyed book" line in `docs/operations.md` moves
by one. Regression prints the number.
**Posture:** changes production (one row deleted), guarded so it cannot delete
a row something cites.
**Evidence:** the counts above were run `--remote` on 2026-09-25. That the
rebuild keeps the row was read from a `rebuild-local.mjs` build the same day.
**Why a rebuild keeps it was not traced.**
**Confidence:** high that it is uncited. Medium on the claim that nobody wants
it as a generic "any light suit" item, until Nate says so. That judgement is the
decline path.
**Ongoing cost:** none.

**Closed without being taken, 2026-09-27 (branch
`shared/audit/rebuild-audit-f21-f24`), on Nate's word.** The proposal's posture
was to change production by deleting one row. Nothing was applied and no script
was written. **Its premise no longer holds.** `node scripts/q.mjs --remote
"SELECT class_id FROM imported_classes WHERE instr(markdown,'light-mdc-body-armor')>0 AND deleted_at IS NULL"`,
re-run 2026-09-27, returns five live classes: `sailor`, `oracle-cat`,
`psi-tech`, `zenith-moon-warper` and `totem-warrior-south-american`. The
premise audit (2026-09-27, at `1b0f850a`) reported them imported 2026-09-25,
the day this finding was counted. `sailor` and `oracle-cat` attach their own
label or note to the item, and `totem-warrior-south-american` names it inside a
choose list. The four others cite it as `item_id: "light-mdc-body-armor"`
(`q.mjs --remote`, 2026-09-27), so the
delete's own class guard (`fix-category-gear-rows.sql:107-109`) would have made
it a no-op. Recorded for whoever comes back to it:

- **That guard matches `item_id: "<slug>"` only.** The choose-list citation in
  `totem-warrior-south-american` would not protect the row by itself.
- **It checks `character_items` only.** `campaign_items.gear_slug` references
  gear too (`db/schema.sql:191`). Today both hold 0 rows for the slug, and
  `catalog_redirects` holds none from it (`q.mjs --remote`, 2026-09-27).
- `test/checks/catalog-data.mjs:940` names the slug in its insert-conflict
  baseline, so a delete would have to edit that too.
- `psi-tech` and `zenith-moon-warper` hold the placeholder `item_id` live while
  the rebuild holds the choose block (`repo-vs-live.mjs --offenders`,
  2026-09-27, under `F24`). This is the case this file's *Not covered* section
  flags. It is reported here, not reconciled.

### F23 — low — a long read-back fails after the apply has succeeded, and pre-flight cannot see it coming

`d1-apply.mjs` re-runs a file's trailing `SELECT`s as **one `--command`** on the
target (`scripts/d1-apply.mjs` around line 245, read 2026-09-25). On 2026-09-24
the first version of `zzzzzzzzzzzzzzzzz-sync-gear-and-classes.sql` carried 16
assertions of about 21 KB in total, each repeating the full replaced block. The
apply ran (37 queries, 17 rows written). Then the read-back died with
`wrangler d1 execute failed:` and an **empty** reason, and the script exited 1.
Pre-flight had passed the same assertions in its scratch replay, which has no
command line to overflow. The file shipped with ten short assertions instead.

**Proposal:** have pre-flight fail a file whose joined read-back exceeds a byte
budget, before anything is applied, naming the budget. That is the same moment
it already refuses a failing assertion.
**Posture:** a new pre-flight refusal, which moves an exit code. Nate may prefer
a warning.
**Evidence:** the failure was measured 2026-09-24. **The cause is inferred, not
measured**: a Windows command-line limit, where `npx` through `cmd.exe` caps a
line at 8,191 characters and `CreateProcess` at 32,767. Which of the two
applies, and what the budget should be, is unknown.
**Confidence:** low on the cause, until someone applies `--local` a throwaway
file with one read-back at 8 KB and one at 30 KB. That test also sets the
budget.
**Ongoing cost:** one constant to keep honest.

**Taken, 2026-09-27 (branch `shared/audit/rebuild-audit-f21-f24`), as a
WARNING, on Nate's choice.** Posture: the warning this finding named as the
alternative, not a refusal. It moves no exit code. Pre-flight in
`scripts/d1-apply.mjs` now prints `WARNING <file>: its read-back is N characters
once cmd.exe has escaped it, over the 7900 budget` before anything is applied,
and carries on (`READBACK_BUDGET` and `cmdLineLength()`, lines 134-148; the
check, lines 188-200). **Placement:** it sits in the file-level loop that checks
every file, not in the assertion pre-flight at the `-- pre-flight: the
read-back assertions` block. That block excludes migrations and is skipped by
`--skip-preflight`, while the read-back runs for every file. It checks on
Windows only, where the limit lives.

**The cause, measured 2026-09-27.** The brief assumed a budget in raw
characters, and that is the wrong measure. `d1Batch()` passes the read-back as
one argument. npx reaches `wrangler.cmd` through cmd.exe, and npm's
`@npmcli/promise-spawn` `escape.js` quotes that argument, then caret-escapes
every space and every `!%^&()<>|"` **twice**, because the target is a `.cmd`.
So each space in SQL costs four characters. Literal SELECTs (read-only) were
sent through `d1Batch --local` against the main checkout's local D1, in
three shapes:

| shape | last ok, raw / escaped | first "too long", raw / escaped |
|---|---|---|
| long literals, few spaces | 7,447 / 7,908 | 7,839 / 8,324 |
| literals full of spaces | 3,135 / 7,652 | 3,527 / 8,608 |
| `instr`, quotes, parentheses | 3,479 / 7,524 | 3,914 / 8,464 |

The raw failure point runs from 3,527 to 7,839, and the escaped one sits
between 7,908 and 8,324 in all three shapes. That is cmd.exe's 8,191 less the
rest of the command line, so the budget is on the escaped length, at 7,900.
Above about 20,000 raw, most batches failed with an **empty** reason instead,
which is the shape this finding recorded on 2026-09-24. (A first attempt
against an empty scratch D1 failed at every length with `internal error`,
which measured nothing. It was discarded.)

**One committed file is already over the budget, and the warning is right to
name it.** The largest committed read-back is 6,595 raw
(`add-hu-gear-h-acids-and-clothing.sql`), so a raw budget near 8K would warn on
nothing. Escaped, that file is 10,389, and its trailing SELECTs, sent through
`d1Batch --local` on 2026-09-27, fail with `The command line is too long`.
The next three are 7,834, 7,830 and 7,706 escaped, and all three ran. Across
1,032 committed files with a read-back, the warning names that one alone.
Filed as `F26`, below.

**Seen to fire.** Each file was paired with a missing second file, so
pre-flight died before any apply:

- `add-hu-gear-h-acids-and-clothing.sql` printed the warning, then the
  missing-file error.
- `~008-rue-ju-xp-ladders.sql` (7,830) printed only the missing-file error.
- `HEAD`'s `d1-apply.mjs` on the first file printed only the missing-file error.

**Not measured:** the overhead under `--remote`, which has no `--persist-to`
and so a shorter line, and the fallback path that spawns `npx` through a shell.

### F24 — medium — `repo-vs-live.mjs` runs only when someone decides to, and 31 differences accumulated

Every difference #1352-#1354 closed came from a script whose effect one
environment lost. Most were a correction sorting before the file it corrects;
some were a class imported live after a blanket fix had already run. Regression
builds only the repo and cannot see any of them, and CI cannot run the
comparison because it has no production credentials. The oldest had been
standing since `fix-labelled-saves.sql` landed on 2026-08-31, about 24 days.
Nothing reported any of them until someone ran the tool by hand on 2026-09-24.
`deploy-sweep.mjs` is the precedent for a report nobody gates on: `ship-pr`
tells a session to run it at the end of its work.

**Proposal:** add `node scripts/repo-vs-live.mjs --offenders` beside
`deploy-sweep.mjs` in `ship-pr`'s end-of-session step, report-only. Say which
kind of PR makes it worth running: any data script, and any class import.
**Posture:** documentation only. No check, no gate, no exit code. It changes a
skill, so it is pressure-tested before it merges, per `CLAUDE.md`.
**Evidence:** the 31 fields and the landing dates were measured 2026-09-24 and
2026-09-25 (`git log --diff-filter=A`). The run time was **not timed**; it was
several minutes on 2026-09-24.
**Confidence:** high that the gap is real. Medium that a line in a skill closes
it: *"rules that are read do not fire"* is this page's own finding. What would
raise it: a session log showing the step being run unprompted.
**Ongoing cost:** a few minutes per session that touches data, and a skill line
to keep true.

**Taken, 2026-09-27 (branch `shared/audit/rebuild-audit-f21-f24`).** Posture
held: documentation only. There is no check and no gate, and this PR moves no
exit code. `.claude/skills/ship-pr/SKILL.md` now tells a session that wrote
D1 (any data script, any class import) to follow `deploy-sweep.mjs` with
`node scripts/repo-vs-live.mjs --offenders`, and to report what it prints
(the paragraph after the sweep's, lines 178-192). Four corrections from the
premise audit shaped the wording:

- **(a)** It does not borrow the sweep's "never fails". `repo-vs-live.mjs`
  exits 1 on a missing or extra row (its line 349, and its header at lines
  39-43), and the skill line says so.
- **(b)** It reads the data directory, not git, so an uncommitted script counts
  as an offender. The line says to run it on a clean tree, or to read the
  output knowing that.
- **(c)** The *`--local` is not a mirror* section described it as proving
  agreement by name alone. That sentence now says it compares by row name and
  by field value.
- **(d)** It stays clear of `BOOK-INGEST-AUDIT` `F105`, held on which side
  wins. The line reports and says nothing about reconciling.
  **Adjusted 2026-09-27 (branch `pal/data/book-ingest-audit-f105-prod-wins`):**
  `F105` is taken. The policy is that production wins, and the ship-pr
  paragraph after this one now says so. The 23 differences this run
  reported are synced by `~042-f105-sync-repo-to-production.sql`.

**The run.** `node scripts/repo-vs-live.mjs --offenders` ran on a clean tree at
`ef6ead6f`, 2026-09-27 20:07-20:13 EDT: 5 min 15 s, exit 0. It reported **23
fields across 23 rows**, and no row missing or extra on either side. 18 are
`psionic_powers.system` (live `rifts`, repo NULL). 5 are `imported_classes`
markdown: `psi-slayer`, `psi-tech`, `psi-warrior`, `zapper` and
`zenith-moon-warper`. These are reported, not reconciled. The 31 above were
measured 2026-09-24, before #1352-#1354. The premise audit counted 28 earlier
on 2026-09-27, and #1491 has merged since.

**Pressure test** (`test-suite` → *A skill is a check too*). Four planning-only
subagents got one scenario: 11:40pm, three merges shipped (a class import and a
data script, both applied `--remote`, and a README edit), and Nate asking to
"wrap up the session properly" and "keep it quick". The prompt never names the
tool.

- **RED**, before the edit: 0 of 2 named `repo-vs-live`. Both planned
  `deploy-sweep` and `drift-check --remote`.
- **GREEN**, after the edit: 2 of 2 named it. Both kept it report-only and
  both said it can exit 1. One also raised the uncommitted tree against it.

**Kept blind**, and where it was not:

- The answer key is this finding's `Proposal` (lines 436-438 of this file at
  `ef6ead6f`). The prompt told runners not to read any file named `*AUDIT*`.
- Every run happened on the neutral branch `claude/brave-hofstadter-9b419d`,
  before any note was written. The recent commit subjects in the snapshot name
  `REBUILD-AUDIT F16`, which leaks the menu's name and nothing more.
- GREEN runners saw the skill file listed as modified. That is the file under
  test, which they were told to read anyway.

**The deviation.** The junction serves the main checkout, and this session was
told not to touch it. So each runner was pointed at the skill by path: RED at
the main checkout's copy, GREEN at this worktree's. That tests the text once it
is read, not whether the skill loads. The description did not change.

### F25 — low — `~011-borrowed-xp-ladders.sql:136` appends a sentence that a second run appends again

Found by `F21`'s sweep, 2026-09-27. The statement at line 136 replaces
`'can be.'` on `gargoylite` with `'can be.'` followed by a sentence beginning
`Since 2026-09-26 xp_table carries dog-boy''s ladder`. Its filter is the class
and `instr(markdown, 'can be.') > 0`. The replacement contains the search
string, so the filter still holds after a run. A second run appends the
sentence again, and `replace()` rewrites every `can be.` in the markdown, not
only the one in the note. **Production is clean:** one `can be.` and one copy
of the sentence, and `data_script_runs` holds one row for the file, at
2026-09-27 03:04:05 (`q.mjs --remote`, 2026-09-27).

**Proposal:** add `AND instr(markdown, 'Since 2026-09-26 xp_table carries dog-boy') = 0`
to that statement, as `F21` did for its file.
**Posture:** repo-only. A guard changes no row in either environment, so
nothing is applied.
**Evidence:** the sweep and the query above, both run 2026-09-27. The re-run
effect is **inferred** from the statement, not run.
**Confidence:** high.
**Ongoing cost:** none.

**Taken, 2026-09-27 (branch `pal/data/rebuild-audit-f16-f25-f26`), as
written.** Posture held: repo-only. Nothing was applied, and the guard changes
no row in either environment. The statement, now lines 136-139, carries
`AND instr(markdown, 'Since 2026-09-26 xp_table carries dog-boy') = 0`. The
guard stops before the apostrophe the file writes as `''`, so it matches the
stored text with no escaping. No other data script contains that string, so
it cannot block a first apply. Premises re-checked by the premise audit before
scoping: production holds one `can be.` and one copy of the sentence, and no
other statement in `~011` has the self-containing shape.

**The re-run effect, run rather than inferred.** production's `gargoylite`
markdown was copied into an in-memory SQLite (`q.mjs --remote`, 2026-09-27),
and the statement run twice. Copies of the sentence per run:

| starting from | `origin/main` statement | guarded statement |
|---|---|---|
| production's markdown | 1, 2, 3 | 1, 1, 1 |
| the same with the sentence removed (a first apply) | 0, 1, 2 | 0, 1, 1 |

### F26 — low — `add-hu-gear-h-acids-and-clothing.sql`'s read-back cannot run from this machine

Found while taking `F23`, 2026-09-27. The file's trailing SELECTs escape to
10,389 characters for cmd.exe, over its 8,191 cap. Sent through
`d1Batch --local` on 2026-09-27, they fail with `The command line is too long`.
So `d1-apply.mjs --local apps/character-creator/db/*.sql`, the glob in that
script's own header (line 7), stops at this file on Windows, **after** applying
it, with exit 1, and nothing sorting after it runs. `rebuild-local.mjs` is
unaffected because it does not send the read-back through wrangler (its header,
line 13). `F23`'s warning now names this file on every run that includes it.

**Proposal:** shorten the file's trailing SELECTs below `F23`'s budget so that
they still assert the same things. The decline path: the file is applied and
one-shot, the warning already says what will happen, and whether anyone still
runs the full `--local` glob was not measured.
**Posture:** repo-only. A read-back is a SELECT, so nothing is applied.
**Evidence:** the `d1Batch` failure was run on 2026-09-27. That the glob stops
there is **inferred** from `d1-apply.mjs`'s `die()` on a failed read-back; the
glob was not run.
**Confidence:** high on the failure. Low on whether it matters, until someone
says they run the glob.
**Ongoing cost:** none.

**Taken, 2026-09-27 (branch `pal/data/rebuild-audit-f16-f25-f26`), on Nate's
choice** over the decline path. Posture held: repo-only. A read-back is a
SELECT, so nothing was applied. The file's trailing SELECTs now escape to
**7,714** characters, under the 7,900 budget. Before, they were 10,389, with
6,595 raw and 5,345 now, measured with `d1-apply.mjs`'s own `cmdLineLength()`
over `trailingSelects()`. All 32 assertions are kept, with the same predicates.
What changed:

- The labels are terse, and the sentence each one carried is now a comment
  above it.
- Each SELECT is one line, with no optional space outside a string literal:
  `count(*)AS got`, `name='Jet Pack'`. The escape charges four characters per
  space.

**Two shapes were measured and rejected.** Folding the 32 into compound
SELECTs escaped *longer* (8,841 in four, and 9,174 in seven of at most five
terms), because the cost is in the predicates, not the boilerplate. D1 also
refuses more than five compound terms (memory
`class-frontmatter-must-be-one-line`, measured 2026-08-26), which the local
replay would not have caught.

**Proved, 2026-09-27:**

- **Same path, both sides.** Through `d1Batch --local`, the `origin/main`
  copy fails with `The command line is too long` and the new block runs:
  32 statements, 32 rows.
- **The same things are asserted.** The old SELECTs, sent in chunks of eight,
  and the new block return identical got and want at every position: 32 of 32
  on `--local` and 32 of 32 on `--remote`, read-only.
- **They hold where they are meant to.** `preflightReadbacks()`, the replay
  pre-flight runs at the file's own position in sorted order, passes all 32.
- **`F23`'s warning no longer names the file.** Each copy was paired with a
  missing second file, so pre-flight died before any apply. The edited file
  printed only the missing-file error. The `origin/main` copy printed the
  warning at 10,389, then the same error.

**Found while proving it: 17 of the 32 no longer hold on production, and did
not before this change either.** Old and new give the same 17 failures on
`--remote` and on `--local`. Each of the 17 matches on `name` alone, and
Nightbane's reprint of the same gear list shares the names: `tape-recorder-nb`
cites `Nightbane RPG p.229` (`q.mjs --remote`, 2026-09-27). Those rows come from
`add-nb-sorcerer-class.sql` and
`zzzzzzzzzzzzz-nb-gear-f-containers-equipment-clothing.sql`, which sort after
this file, so at its own position every assertion holds. The file is one-shot
and was not re-applied. The predicates are the file's own and were not
narrowed, because narrowing them would stop asserting the same things.

**Two line citations in this finding were wrong** (premise audit):

- `d1-apply.mjs` line 7 is the `--remote` form of the glob. The header prints
  no `--local` glob. The mechanism holds either way: the read-back's `die()`
  runs inside the per-file loop after the apply.
- `rebuild-local.mjs`'s header says it never spawns wrangler at line 26, not
  13.

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
