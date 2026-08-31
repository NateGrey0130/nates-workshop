# Production configuration and operations

Bindings, the one-database decision, migrations, data scripts, and how to check that
the live database still matches the repo.

Part of the [character creator](../README.md) documentation.

---

## Production configuration

Set in the Cloudflare Pages dashboard, not in the repo:

- `ANTHROPIC_API_KEY` — encrypted secret, used by the proxy, the campaign Ask
  and the NPC sweep. `scripts/extract-class.mjs` reads its own copy from the
  environment or `.dev.vars`; it runs on a workstation, not in a Worker.
- `ADMIN_EMAIL` — the single email allowed to reach the admin routes. Fails closed.

**Schema changes are applied by hand, before the deploy that needs them.**
`db/schema.sql` is safe to re-run — every statement is `IF NOT EXISTS`:

```bash
npx wrangler d1 execute nates-workshop-media --remote --file db/schema.sql
```

Content written this way is **not** safe for non-ASCII on Windows — see the
em-dash note in [Known limitations](known-limitations.md#known-limitations-and-refactor-candidates).
Schema files are pure ASCII, so this applies to data loads, not migrations.

`db/migrations/*.sql` are **one-shot** and cannot be made idempotent, because
SQLite has no `ADD COLUMN IF NOT EXISTS`. Run each once per environment, in
filename order.

**Apply migrations and data scripts through `scripts/d1-apply.mjs`** rather
than raw wrangler commands:

```bash
node scripts/d1-apply.mjs --remote db/migrations/021-spell-ppe-note.sql apps/character-creator/db/backfill-spell-ppe-notes.sql
```

It encodes what the raw commands kept re-learning: the target is explicit
(no default database, because an accidental `--remote` is the costly
direction); every file is pre-checked for CR and non-ASCII bytes before
anything runs (both have changed production bytes before); files apply in
the order given and the run stops at the first failure, so a migration
always lands before the backfill that needs it; each file's trailing
verification SELECTs are printed; and remote runs start with a throwaway
`wrangler whoami`, which absorbs the expired-OAuth-token failure
(`Authentication error [code: 10000]`) that an interactive login hits on
its first call after idle. A `CLOUDFLARE_API_TOKEN` environment variable
(scoped to Account -> D1 -> Edit) removes that failure mode entirely and is
the recommended setup; the warm-up is then redundant but harmless.

**Ask the database what it has had applied** rather than inferring it from
columns:

```bash
npx wrangler d1 execute nates-workshop-media --remote --command "SELECT filename, applied_at FROM schema_migrations ORDER BY filename"
```

| Migration | Adds |
|---|---|
| `001-character-detail.sql` | `bio`, `combat`, `saves`, `armor` on `characters` |
| `002-catalog-provenance.sql` | `source_book` + `note` on `skills`; `source_book` on `spells`, `psionic_powers` |
| `003-class-soft-delete.sql` | `deleted_at` on `imported_classes` |
| `004-items-to-gear.sql` | renames `items` to `gear`. **Not additive** — apply immediately before the matching deploy, not ahead of it |
| `005-spell-detail.sql` | range, duration, damage, saving_throw, area_of_effect, casting_time, description on `spells` |
| `006-import-sessions.sql` | `import_sessions` + `import_staged` — **both dropped again by 041**. The file stays because it has run everywhere, and drift-check compares migration FILES against `schema_migrations` |
| `007-psionic-detail.sql` | range, duration, saving_throw, description, min_tier on `psionic_powers` |
| `008-gear-detail.sql` | gear stat block; **drops the `stats` JSON blob**, which was empty in every row |
| `009-pending-skill-picks.sql` | `pending_skill_picks` |
| `010-catalog-redirects.sql` | `catalog_redirects` — where a retired key forwards to |
| `011-character-drafts.sql` | `character_drafts` — one unfinished wizard build per person |
| `012-catalog-system.sql` | `system` on `spells` and `psionic_powers` (it added one to `import_sessions` too, which 041 dropped) |
| `013-character-variant.sql` | `class_variant` on `characters` |
| `014-character-occ.sql` | `occ_class_id` + `occ_class_variant` on `characters` |
| `015-character-psychic-tier.sql` | `psychic_tier` + `psychic_shape` on `characters` — a tier the character **rolled** |
| `016-character-attribute-bonuses.sql` | `attribute_bonuses` on `characters` — what a class's **dice** bonuses came up |
| `017-pick-kind.sql` | `kind` on `pending_skill_picks`, so a scheduled grant records whether it was related or secondary |
| `018-character-abilities.sql` | `abilities` on `characters` — the powers a player chose from a class's choice group |
| `019-character-rolled-bonuses.sql` | `rolled_bonuses` on `characters` — what a class's **dice** combat and save bonuses came up |
| `020-psionic-isp-note.sql` | `isp_note` on `psionic_powers` — the cost schedule when a power's I.S.P. is not one number; `isp` keeps the minimum the use button deducts |
| `021-spell-ppe-note.sql` | `ppe_note` on `spells` — the same variable-cost shape as 020, for spells; `ppe` keeps the minimum the use button deducts |
| `022-play-events.sql` | `play_events` — play mode's append-only action log: undo, the who-did-what trail, and the session recap boundary |
| `023-skill-bonuses.sql` | `skills.bonuses` — what a skill grants beyond its percentage, in a class's `bonuses:` shape. Boxing is +1 attack per melee and +2 P.S. |
| `024-data-script-runs.sql` | `data_script_runs` — which data scripts have run against this database. The same question `schema_migrations` answers for migrations, for the 55 scripts that answer it nowhere |
| `030-power-pick-slots.sql` | `pending_power_picks.slot`, `.from_names` and `.note` — several grants can share a level with different restrictions. The Shifter gains two spells from a named list and one of any kind at every level; `slot` tells them apart, and `note` carries a restriction the catalog cannot check |
| `031-character-mos.sql` | `characters.mos` — which Military Occupational Specialty a character took. RUE gives several classes an MOS ("select one area of specialty, gain all skills under that MOS"); the skills land in `skills` like any other, but which specialty was chosen has to be remembered rather than inferred back out of the skill list |
| `032-gear-cost-note.sql` | `gear.cost_note` — what a price will not fit in one integer. RUE prices much of its common gear as a **range** (`Belt, Utility: 3-5 cr.`) and sometimes qualifies it instead (`double for gold`). `cost` holds the range’s LOW end, the way `spells.ppe` holds a variable cost’s minimum, and `cost_note` carries the wording verbatim |
| `033-variant-note.sql` | `spells.variant_note` and `psionic_powers.variant_note` — what an OLDER book prints instead. Not `ppe_note`: the wizard treats the mere presence of that column as "this cost varies" and renders `7+ P.P.E.`, so a cross-book note there would make fourteen fixed-cost spells look variable |
| `040-media-vault-source-id.sql` | `media_items.source_id` — where a MediaVault row came from, so its lookup can be re-run exactly. Not this app's table either. One generic column rather than two nullable ones: the normalised ISBN for a book, `tmdb:movie:1234` / `tmdb:tv:1234` for video, so the prefix names the lookup and the rest is its key. Empty on every pre-existing row, which is why the backfill it enables matters more than the column |
| `041-drop-import-staging.sql` | drops `import_sessions` + `import_staged`. The in-app importer that wrote them was retired without ever having written a row - both held ZERO in production on the day they went, and `claude_usage` held no import call that could have produced one. 006 is not deleted: a recorded migration with no file is drift in the other direction |
| `039-filament-forge.sql` | The six `ff_` tables — FilamentForge's whole server side, not this app's. Its OFD catalog snapshot (`ff_brands`, `ff_filaments`, refreshed by `scripts/ofd-refresh.mjs`) and what its localStorage used to hold (`ff_config`, `ff_history`, `ff_presets`, `ff_custom_filaments`), keyed to the Access email the way `media_items` is |
| `038-claude-usage.sql` | `claude_usage` — who is spending the Anthropic key, on what. A site-level table written fail-open, so metering can never break the call it measures: the log half of the audit's F3, spend visibility rather than a cap. **Every Claude call in `functions/` writes it** — the proxy, the campaign Ask and the NPC sweep — plus the Pick 3 Cut 5 Worker's own rows and `scripts/extract-class.mjs` (`cc-extract-class`), which meters itself from the command line so that retiring the in-app importer did not take the spend ledger with it. Read it with the queries in SETUP.md §Who is spending the Anthropic key |
| `037-campaign-open.sql` | `open` on `campaigns` — the join gate. Joining a campaign IS creating a character in it (membership is "owns a character here"), so an ungated create was an ungated door onto the campaign's notes, stash and ledger. 1, the default every existing campaign keeps, is the open table; 0 admits only the GM and existing members. Enforced by `POST /characters`, toggled on the GM dashboard |
| `036-enchantments-charm.sql` | `enchantments.applies_to` gains **charm** — a third family, and the book draws it the same way as the other two: *"The following magic effects can be **placed in** rings, bracelets, charms, and medallions"*, three powers to an item. Thirty of them, printed 253. SQLite cannot alter a `CHECK`, so the table is rebuilt and the rows copied by named column |
| `035-enchantments.sql` | `enchantments`, and `character_items.enchantments` — what an alchemist puts INTO a sword, as opposed to a sword. Printed 249-250 sells three finished suits and then **32 properties** that go into ordinary gear, four to a suit and three to a weapon, cumulatively. The JSON array is on the **instance**: one long sword in a party of four can be the Demon Slayer while the other three stay ordinary |
| `034-gear-sdc.sql` | `gear.sdc` — Structural Damage Capacity, which the book calls one of the **two** attributes of armour alongside A.R. (printed 270). The rules spend it: damage subtracts from it, at half S.D.C. the A.R. drops two points, at zero the armour is gone. All six Palladium suits kept it in free-text `description`, where no sheet and no arithmetic can reach it. Never the `1D6 S.D.C.` a knife *deals*, which is `damage` |
| `029-power-pick-categories.sql` | `pending_power_picks.categories` — a banked PSIONIC grant's own category list. The Mystic gains a **Super** power at levels 4 and 8, a category a major psychic cannot otherwise take, so the restriction belongs to the grant rather than to the class |
| `028-pending-power-picks.sql` | `pending_power_picks` — the spells and psionic powers a level-up granted and nobody chose. `pending_skill_picks` with a different subject; `spell_levels` carries the cap the granting level came with, because that cap belongs to the grant rather than to the character |
| `027-npc-dossiers.sql` | `npcs`, `npc_mentions`, `npc_sweeps` and `npc_proposals_dismissed`. **The first migration whose feature also needs a bucket** — R2 `MEDIA` must exist before the deploy that binds it |
| `026-campaign-notes.sql` | `journal_fts` and its three triggers, plus `campaign_items` and `campaign_currency`. The FTS table is external-content, so the triggers are not optional — without them the index silently stops matching anything written after the migration ran |
| `025-skill-level-bonuses.sql` | `skills.level_bonuses` — what a skill grants **at each level**, summed up to the character's. The Hand to Hand tables are level-by-level and accumulative, which the flat `bonuses` column cannot express; entries may carry `applies_when` for a W.P. bonus that needs that weapon in hand |

### One database, and the case for keeping it that way

Every app in the monorepo shares one D1, `nates-workshop-media`, bound as `DB`.
That reads like a thing to fix, so here are the numbers it should be judged
against — read off production on **26 August 2026**, not estimated.

They are a dated snapshot, and no test pins them: a count read off production
cannot be checked by a suite that builds its database from nothing, which is
exactly why the previous set went stale — `media_items` had drifted by more
than 1,400 rows before anyone noticed, and the figure sat in this table
looking authoritative the whole time. Re-read them rather than trusting them,
and date whatever you write down. The counts cover the 34 real tables; they
exclude `sqlite_sequence` and `_cf_KV`, and the five `journal_fts*` tables,
whose rows are `journal_entries` counted a second time. Read them in batches
of five tables — D1 caps a compound SELECT at five terms and answers
`SQLITE_ERROR 7500` above that.

| | |
|---|---|
| database size | **4.3 MB** of D1's 10 GB — 0.04% |
| tables | 41 (incl. FTS internals) |
| rows, everything | **8,322** |
| of which `media_items` (MediaVault) | 3,544 |
| the OFD snapshot (FilamentForge) | 2,208 |
| the five catalogs together | 1,968 |
| characters, live | **10** |
| the largest table this app owns | `gear`, 902 rows |

**The apps already have zero overlap.** `functions/api/media-vault/` and
`functions/api/filament-forge/` are the only D1 consumers outside
`functions/api/character-creator/`; each touches only its own tables —
`media_items`, and the six `ff_` ones — and nothing under `character-creator/`
reads any of them. There is no join to break. Of 39 migrations, **one** mentions
`media_items` — `004-items-to-gear.sql`, and only because renaming `items` to
`gear` had to stay clear of it — and one, `039-filament-forge.sql`, is
FilamentForge's entirely and touches nothing of anyone else's.

**So a split is possible and is not worth it.** The single risk it removes is one
app's migration disturbing another, which has never happened and has one file of
surface area. What it costs is concrete and recurring: a second binding, a second
entry in `wrangler.jsonc`, and a second target for every one of `d1-apply.mjs`,
`drift-check.mjs`, `repo-vs-live.mjs`, `q.mjs` and the regression harness — five
tools that each take one database name today. `schema_migrations` and
`data_script_runs` would have to be split or duplicated, and the smoke test's
migration-state checks with them.

**What would change the answer**, so this is a decision rather than a habit:

- a second app growing real tables — which FilamentForge now has: six `ff_`
  tables, migration `039`. The answer held, because the prefix keeps the
  namespace disjoint and the new rows are a catalog snapshot plus one user's
  saved settings. A third app, or any table another app would need to join,
  should run these numbers again;
- any app approaching a size where the 10 GB limit or a row-scan matters,
  which is still orders of magnitude away;
- any need to give one app a different retention, backup or access posture from
  the others.

**Nothing is unindexed that matters, and adding indexes would be cargo cult.**
The five catalogs are read *whole* by `/catalogs` and `/items` — that is
deliberate, see [Catalog lists are deliberately
unbounded](known-limitations.md#known-limitations-and-refactor-candidates) — so a full scan is the
query plan, and 902 rows is the largest scan in the app. Every hot filter that
is not a full read is already covered: `characters` by campaign and by player,
`character_items` by character, `journal_entries` by campaign and by character,
`play_events` and both pending-pick tables by character, `npcs` by campaign,
`imported_classes` by status and by `deleted_at`, and `catalog_redirects` by
`(catalog, from_key)` through its own `UNIQUE`.

**Referential integrity is clean.** Fifteen orphan checks — every foreign key in
the app, plus `characters.class_id` and `occ_class_id`, which are slugs rather
than real references and so could rot silently — return **zero**. No character
drafts abandoned, no soft-deleted classes, no unpublished ones, no open import
sessions.

The two counts that are not zero are both known and deliberate: **78 gear rows
still marked `STUB`**, which is the figure
[Known limitations](known-limitations.md#known-limitations-and-refactor-candidates) explains and
defends, and **52 skills with no `source_book`**, which are seed rows that
predate the column.

### Checking the live database against the repo

```bash
node scripts/drift-check.mjs --remote
```

Read-only, so it is safe to point at production. It compares five things:

| | |
|---|---|
| migration files | vs `schema_migrations` |
| data scripts | vs `data_script_runs` |
| tables in `schema.sql` | vs `sqlite_master` |
| columns in `schema.sql` | vs the live `CREATE` text |
| published classes | vs a class a data script can recreate |

**The smoke test and the regression test cannot see production.** Smoke proves
the repo is internally consistent; regression proves a database built *from* the
repo works. The gap between them is where the expensive mistakes live, and the
first run of this check found two that had been sitting there for weeks:

**Two classes existed only in production.** `chiang-ku-dragon` and `juicer`
predate the data-script convention — they were imported through the UI, and
every correction since is a `fix-*.sql` that *patches a row nothing in the repo
creates*. `schema.sql` plus the data scripts rebuilt **24 of 26** published
classes. Had production been lost, those two definitions were not in git at all.
`add-chiang-ku-dragon-class.sql` and `add-juicer-class.sql` close it, exported
from the live rows; a fresh build now reaches 26 and both come out byte-identical
to production.

**A run record that asserted something untrue.**
`backfill-data-script-runs.sql` swept `seed-dev.sql` in with everything else, so
production recorded a local-only script as having run there. Nothing was
actually seeded — checked before fixing — but the row is the exact lie
`data_script_runs` exists to prevent. `fix-seed-dev-run-record.sql` removes the
asserted row and leaves any genuinely observed one alone.

Two facts about `wrangler` are baked into the script because both cost an hour:
`--file` over `--remote` returns a **summary** row rather than query results, so
every count comes back as 1; and `execFileSync` with `shell: true` does not
quote the arguments it joins, while without a shell Node refuses to spawn
`npx.cmd` on Windows at all.

**Prose counts drift silently.** The README claimed *"Sixteen of twenty-five
published classes state no hit point formula"* when the answer was eighteen of
twenty-six — stale before the Stone Master, not because of it — and still
described 15 of the Shifter's 34 spells as missing from the catalog seventy
lines after the section saying all three lists resolve in full. Both are now
pinned by the regression test, which is the only place that can count them,
because the class definitions live in D1 rather than in the repo.

### Standing up a new environment

Verified end to end; the counts below are what a clean run produces.

```bash
node scripts/d1-apply.mjs --remote db/schema.sql
node scripts/d1-apply.mjs --remote db/seed-catalogs.sql
node scripts/d1-apply.mjs --remote apps/character-creator/db/*.sql
```

The glob is expanded by `d1-apply.mjs` itself, sorted — PowerShell does not
expand globs for native commands, so the same line works in either shell. It
prints `skipping ... marked local-only` for `seed-dev.sql`, which inserts a test
campaign and character and must never reach production. That exclusion is the
file's own `-- local-only` marker, not a list kept in the script, so a new
local-only script is protected as soon as it says so.

| After | Rows |
|---|---|
| classes (published, live) | 137 |
| skills | 345 |
| spells | 607 |
| psionic powers | 101 |
| gear | 1020 |

**These are pinned by `test/regression.mjs`**, which is the only thing that can
honestly check them: it builds a database from nothing under a scratch directory
and asks the running worker what it serves. The previous version of this table
claimed 23/231/366/52/407 and was verified by nothing - three paragraphs after
the note above about prose counts drifting silently.

**What a rebuild produces, and what it does not.** The table above is the
CATALOG and the class definitions. That is the whole of what this repo can
rebuild, and it is worth stating because the sentence "rebuild from the repo"
is read as "restore production" often enough that an audit brief opened on the
assumption.

**It cannot restore production, by design.** Production held **6,006 rows on
2026-08-28 that no data script creates** and none of them belong in git:

| | | | |
|---|---|---|---|
| `media_items` | 3,639 | `characters` | 11 |
| `ff_filaments` | 2,051 | `play_events` | 6 |
| `ff_brands` | 157 | `campaigns` | 3 |
| `character_items` | 111 | `character_drafts` | 2 |
| `claude_usage` | 26 | | |

Campaigns, characters, journals, NPCs, MediaVault libraries and FilamentForge
spools exist in D1 and nowhere else. **They are protected by Cloudflare's
backups, not by this repository**, and no mechanism here is a substitute for
that. A repo build is for standing up a NEW environment - a fresh preview, a
scratch database for a test - never for recovering this one.

Two consequences worth carrying. `test/regression.mjs` and
[`repo-vs-live.mjs`](../../../scripts/repo-vs-live.mjs) build into scratch
directories and compare catalogs, so neither is a restore drill and neither
proves one would work. And `scripts/repo-vs-live.mjs`'s own opening question -
*"Can the repo rebuild the live catalog, row for row?"* - is scoped correctly
where the prose around it sometimes is not: the CATALOG, never the database.

### The rebuild did not match production, and nothing was watching

Pinning those counts immediately found that two of them disagreed with
production, in opposite directions. Both are fixed; the story is kept because
the cause will recur.

**Six psionic powers.** A clean run produced 107 against production's 101, and
the extra six were not new content - they were the OLD HALF of six merges
somebody performed through the catalog editor, which writes straight to D1:

| the repo still created | production kept |
|---|---|
| `Bio-Manipulation` | `Bio-Manipulation (the evil eye)` |
| `Bio-Regenerate (self)` | `Bio-Regeneration` |
| `Levitation (psionic)` | `Levitation` |
| `Nightvision (psionic)` | `Nightvision` |
| `Object Read` | `Object Read (Psychometry)` |
| `Telekinesis (minor)` | `Telekinesis` |

**One of those six was already supposed to be fixed.**
`merge-bio-regenerate-duplicate.sql` has been in the repo for weeks doing
nothing, and the reason is **filename order**: it sorts under `m`, while every
surviving row is created by `restore-psionics-missing-from-repo.sql` under `r`.
Running first, its guards correctly found no survivor to merge into and it did
nothing - silently, because doing nothing is exactly what a guarded script does
when its precondition is absent. `zz-merge-psionic-duplicates.sql` supersedes
it and sorts last, the same fix `zz-canonicalise-class-skill-names.sql` needed.

Three of the retired names are cited by class definitions - `Bio-Manipulation`
by the Combat Cyborg, `Object Read` by the Cyber-Knight and Techno-Wizard - and
are deliberately **not** rewritten. That is what `catalog_redirects` are for,
and rewriting a class's markdown to match a catalog rename loses the book's own
wording.

**Seven gear rows**, hidden inside a difference of one. Four existed only in
production (`Huntsman Armor`, `Air Filter And Gas Mask`, `Hovercycle`,
`Light Mdc Body Armor`) - class-import stubs the importer wrote straight to D1.
Three existed only in the repo, generic stubs production had superseded with
specific rows (`Sunglasses Or Tinted Goggles` against production's `Sunglasses`
*and* `Tinted Goggles`). **Counts alone would have called that a one-row
problem.**

### `scripts/repo-vs-live.mjs`

The guard that should have existed. `drift-check` compares *bookkeeping* -
which migrations and data scripts have run - and every script here was recorded
in both places while the rows differed. It demands that every published **class**
be creatable from the repo, and nothing made the same demand of catalog rows.

```bash
node scripts/repo-vs-live.mjs              # all five catalogs
node scripts/repo-vs-live.mjs --table gear
```

It builds from the repo into a scratch database and diffs the **names** against
live, because counts are not enough. Exits non-zero on any difference and
prints which direction each is:

- **ONLY LIVE** - added through the app and never written back. Export it into a
  data script, the way `restore-*.sql` did.
- **ONLY REPO** - merged or renamed away in the app while the repo still creates
  the old row. `zz-merge-psionic-duplicates.sql` is the shape: move redirects,
  add a forwarding one, then delete.

This is the third time rows added through the UI have diverged from the repo.
The first two were found by hand.

**Do not run the migrations on a new database.** This is the part that looks
wrong and is not: `db/schema.sql` already contains every column the migrations
add, so on a fresh database **the ALTER-based majority of them fail** —
`duplicate column name: bio`, `no such table: items`, and so on; only the pure
`CREATE TABLE IF NOT EXISTS` migrations run clean. They exist to bring an EXISTING
database forward, and `schema.sql` records all 24 as applied the moment it runs,
guarded on the schema feature each one adds. A fresh database is current
immediately and says so.

So the two directions never mix:

| | new database | existing database |
|---|---|---|
| `db/schema.sql` | **yes** — creates everything, records every migration | yes — harmless, and how you backfill the records |
| `db/migrations/*.sql` | **no** — the ALTERs error | yes — the ones it has not had, in order |
| `db/seed-catalogs.sql` | yes | no — it seeds the ORIGINAL three classes |
| `apps/character-creator/db/*.sql` | yes — the corrections on top | as needed; the log says which have run |

`seed-catalogs.sql` seeds the three classes **as originally written, not as the
rules audit corrected them**, which is why the data scripts follow it rather
than being optional. Apply them in filename order; every one guards itself, so
a script whose moment has not come does nothing and can be re-run later.

Then confirm, rather than trusting the exit codes:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT (SELECT count(*) FROM schema_migrations) AS migrations,
          (SELECT count(*) FROM imported_classes WHERE status='published') AS classes,
          (SELECT count(*) FROM skills) AS skills,
          (SELECT count(*) FROM data_script_runs) AS script_runs;"
```

### The migration convention

- Filenames are `NNN-kebab-description.sql`, applied in ascending order.
- Every migration **ends by recording itself**:
  `INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('NNN-….sql');`
- Migrations are **never edited after being applied anywhere**. A mistake gets a
  new numbered file.
- `db/schema.sql` also seeds `schema_migrations`, because a database created from
  it already contains every column the migrations add and is current the moment
  it exists. **Each seeded row is guarded by the schema feature its migration
  adds** — on an existing database every `CREATE` in `schema.sql` is skipped, so
  an unguarded insert would mark an old, un-migrated database as migrated, which
  is exactly the lie this table exists to prevent. Add a guarded line to that
  block whenever you add a migration.
- **A migration that adds a column must add it to `schema.sql`'s `CREATE` too.**
  The two are not alternatives: the migration brings an existing database
  forward, the `CREATE` is what a brand-new one gets. Skipping the second half
  is invisible until someone builds a fresh environment. It has happened —
  `020` and `021` added `isp_note` / `ppe_note`, neither reached `schema.sql`,
  and the documented local-dev recipe produced a database whose very first API
  call (`/catalogs`, which selects both) failed.
- The smoke test fails if a file in `db/migrations/` has no matching row, or if a
  recorded row has no matching file. It separately fails if a migrated column is
  missing from `schema.sql`'s `CREATE`, if a migration has no seed line there, or
  if a seed line is unguarded — those read the files rather than the database,
  because the database check cannot see any of it. The local database has had the
  migrations applied to it by hand, so it reports itself current however wrong
  `schema.sql` is.

Running `db/schema.sql` against an already-current database is therefore how you
backfill the records — no separate backfill migration is needed.

### Data scripts

`apps/character-creator/db/*.sql` are a different thing from `db/migrations/`
and are easy to mistake for them. A migration changes **schema**; these change
**rows**, and are run by hand per environment as needed.

They used to be tracked nowhere, which left "has production had the Juicer
correction?" answerable only by querying the rows it writes and inferring —
the same guessing game `schema_migrations` was created to end. Migration 024
added `data_script_runs` and every script now ends by writing itself into it.

| Kind | Files | What they are |
|---|---|---|
| Dev seed | `seed-dev.sql` | Optional local character/campaign rows. Never applied to production |
| Run tracking | `backfill-data-script-runs.sql` | One-time, optional, and an **assertion**: records every script that had already been applied before `data_script_runs` existed, stamped with a note saying the run was asserted rather than observed. Guarded per filename, so it cannot double-record a script that has genuinely run since |
| Data cleanup | `estimate-*.sql`, `backfill-*.sql`, `rename-*.sql`, `merge-*.sql`, `retag-*.sql`, `retire-gear-placeholders.sql`, `retire-leather-armor-placeholder.sql`, `retire-orphan-gear-stubs.sql`, `untag-cross-system.sql` | One-off corrections to rows an earlier import or data script got wrong or left NULL. A `rename-*` also leaves a `catalog_redirects` row, so class markdown citing the old key keeps resolving. A `retag-*` changes which system a row belongs to, never what it is — `retag-pf-spells-both.sql` moves 57 spells the Palladium Fantasy book prints from `rifts` to `both` |
| Class corrections | `fix-*.sql`, `apply-*.sql`, `long-bowman-money.sql`, `ley-line-walker-spells-per-level.sql`, `mystic-spells-per-level.sql`, `shifter-spells-per-level.sql`, `ley-line-rifter-spells-per-level.sql`, `record-warlock-palladium-deltas.sql` | The rules audit's output: stored class definitions rewritten against the books, and class data written for a schema feature the day it landed. The Ley Line Walker one is the first to fill `spells_per_level` — the format gained the key before any class carried it, so every caster read as "not recorded" until a book was opened |
| Additions | `add-*.sql` | Something the book gives that the database never had — a catalog row, a whole-table batch extracted from page scans (`add-pf-weapons-batch`, `add-pf-equipment-batch`, the RUE spell and psionics batches), or a whole class. A missing skill named in an `only` restriction narrows its category to nothing, which is usually how one gets noticed. A class goes in this way only when the import tool cannot be reached: production sits behind Cloudflare Access, so a hand-transcribed class is applied by script instead |
| Repo rescue | `restore-*.sql` | Rows that existed **only in production**. The catalog editor and the importer's confirm step both write straight to D1, so nothing in git created what they added: a database built from the repo came up 75 skills, 36 psionic powers and 58 gear rows short, and every class citing one had a dead reference. Exported from the live rows and guarded on the key, so on production they find everything present and do nothing — it is a fresh environment that needs them. Named `restore-` rather than `add-` **for ordering**: an `add-` file sorts before `rename-skills-to-rue.sql`, which would insert the post-rename name, leave the rename's guard to find its target taken, and end up holding both |
| Ordering-sensitive | `zz-*.sql` | Applied in filename order like everything else, which is exactly the problem: **filename order is not the order things were actually run**. `fix-class-skill-names-to-rue.sql` was applied to production by hand, last, so it won; in a repo build it sorts under `f` and three scripts after it (`fix-dead-skill-restrictions`, `fix-dragon-hatchling`, `fix-juicer-rue-edition`) wrote the pre-RUE skill names back. Production was right and a fresh build was wrong, and only the regression restriction audit caught it. Editing those three would break the rule that an applied script is never edited, so the alternative is to sort after all of them — and `zz-` is the only prefix that guarantees it |
| Sorts after the `zz-` files | `zzz-*.sql` | The same escalation a second time. A `zz-` file that CORRECTS another `zz-` file has to sort after it, and `zz-gear-tidy-…` would land before `zz-wire-juicer-uprising-equipment.sql`, which creates three of the rows it corrects — so the tidy would run first and find nothing. The numbers inside the name (`zzz-gear-tidy-1-names`, `-2-stub-stats`, `-3-categories`) order the three against each other for the same reason: `-2-` fills the stubs and `-3-` categorises whatever is still uncategorised, which is only the right set once `-2-` has run |
| Sorts after the `zzz-` files | `zzzz-*.sql` | The same escalation a THIRD time, and the one with a measurement behind it. The three citation files — `zzzz-cite-bom-invocations.sql`, `zzzz-cite-pf-rows.sql`, `zzzz-cite-rue-rows.sql` — give catalog rows the page they are printed on, and every row they touch has to exist and be named correctly first. Written as `fix-*.sql` they sorted in the MIDDLE: **`restore-skills-missing-from-repo.sql` and its gear and psionics twins CREATE rows the citation scripts then failed to find**, `rename-skills-to-rue.sql` renames rows they match by name, and `zzz-gear-tidy-2-stub-stats.sql` rewrites the very column they set. Applied to production by hand they ran last and were right; **a database rebuilt from `schema.sql` plus every data script in filename order lost 148 citations** — 26 rows carrying a bare book title in production against 172 in the rebuild. Measured before the rename, not reasoned. Their `data_script_runs` rows were moved with them: each script deletes the record written under its old name, which never existed in `main`, on the `fix-seed-dev-run-record.sql` precedent that only a record asserting something untrue is removed |
| Sorts after the `zzzz-` files | `zzzzz-*.sql` | The same escalation a FOURTH time, and the tier is now what it looks like: a counter, not a category. `zzzzz-fix-ju-gambling-notes.sql` corrects a `skills.note` that `add-juicer-uprising-skills.sql` writes and `zzzz-restore-skill-notes-and-citations.sql` then writes again from the live rows — so a correction has to sort after **both**, and only a fifth `z` does it. Nothing about the content needs a new tier; the restore files are simply the last thing in the order, and anything correcting what they assert lands here |

**The `zz-` escalation fixed the NAMES and left DUPLICATES behind.** The row
above records that `fix-class-skill-names-to-rue.sql` beats three later `fix-`
scripts in a rebuild, and that `zz-canonicalise-class-skill-names.sql` re-applies
the rename after all of them. That is true and it is not the whole story. A
fourth consequence of the same pair went unnoticed until a rebuild was compared
to production column by column on 2026-08-28 — **the first of these four found
by looking rather than by accident:**

`fix-dead-skill-restrictions.sql` exists to collapse the Burster's and Mystic's
four-name heavy W.P. list to two. It sorts `fix-de`, *after* `fix-cl`, so by the
time it runs the rename has already turned `"W.P. Heavy"` and
`"W.P. Heavy Energy Weapons"` into the two names the list already held. Its
guard matches the pre-rename string, finds nothing, and **the list keeps each
name twice**. The Mystic's `Pilot` list is the same shape one step longer, and
there the corrective script is the culprit: `"Warships"` survives the same
missed guard, and `zz-canonicalise-class-skill-names.sql` renames it to
`"Military: Warships & Patrol Boats"` — which is already in the list.

`zzzz-dedupe-skill-restrictions.sql` closes it. The general lesson is the one
worth keeping: **a guarded `replace()` whose guard names a string another script
renames is not idempotent, it is inert** — and it fails silently, because a
`replace()` that matches nothing is indistinguishable from one that had nothing
to do. When a `fix-` script guards on a skill or gear name, check what sorts
between it and the rename.

**One more thing about `--file` over `--remote`,** learned applying that script:
its `changes` and `rows_written` are **import-endpoint aggregates, not row
counts**. This one reported `changes: 2` against production while changing
nothing at all — verified by dumping `imported_classes` before and after, 126
rows, zero field differences, `updated_at` unmoved. The section below already
says `--file` returns a summary rather than results and that exit codes here are
advisory; the counts inside that summary are advisory too. Dump the table and
diff it.

Three conventions hold across all of them, with one stated exception: the
dev seed is a different kind of file and follows only the third. Its inserts
are unguarded and re-applying it fails on `gear.slug`, which is the right
behaviour for a file whose whole job is to put known rows into an empty
local database.

- **Every statement guards itself**, so a script is safe to run twice and safe
  to run *early*. `retire-gear-placeholders.sql` is the clearest case — it does
  nothing at all until the options it rewrites toward exist, and its closing
  `SELECT` reports what it did and what it is still waiting for. See
  [Starting gear the class leaves open](wizard-and-sheet.md#starting-gear-the-class-leaves-open).
- **Each one opens with the book and page it is correcting against**, because a
  script that rewrites a class is a claim about a source, and six months later
  the citation is the only way to check it.
- **Each one ends by recording its own run**:
  `INSERT INTO data_script_runs (filename) VALUES ('<this-file>.sql');`
  One row per **run**, not per file, and deliberately not keyed on the
  filename — because of the guard convention above. A script that ran early
  and correctly did nothing has still run, and an applied-once flag would
  record that no-op as done and hide that the real work never happened.
  `retire-gear-placeholders.sql` is exactly that case. The smoke test fails if
  a script has no footer, or if a copy-pasted one names a different file —
  which logs the wrong script and looks entirely fine.

**What a data script cannot recover: a row that was ENRICHED.** `restore-*.sql`
closes one gap and is regularly mistaken for closing another. It restores that a
row **exists**. It does not restore what a row **became**.

The catalog editor and the importer's confirm step write straight to D1.
Nothing in git creates what they add, which is the gap the `restore-*` scripts
were written for — but they are `INSERT OR IGNORE` on the key, so they only
ever recover a row that was **absent**. A row that already existed and was then
**edited in the app** is invisible to them, and to every other script here.
Nothing in this repo can reconstruct it.

`Healing Touch` is the clearest case. `db/seed-catalogs.sql` creates it with a
name, a category and an I.S.P. cost; every other value is NULL. **No other file
in a rebuild touches it again** — traced through all 292, 2026-08-28. Production
holds the full RUE text cited to p.165, typed into the catalog editor, and that
text exists in production and nowhere else. Rebuilt from this repo, 21 psionic
powers have no description at all against production's one, and 32 have no
`source_book` against production's twelve. `add-rue-psionics-batch.sql` cannot
help: it is `INSERT OR IGNORE` on name, and the seed row is already there.

**This is not a bug in any script.** Each one does what it says. It is a
property of a system where the app is a writer and the repo is not the only
source of truth, and closing it would mean writing every catalog edit back into
a data script by hand, forever — a discipline this repo has already tried and
lost twice.

**It is no longer silent, which it was until 2026-08-28.** Since PR #377,
[`scripts/repo-vs-live.mjs`](../../../scripts/repo-vs-live.mjs) compares every
column of every row whose name matches and prints the count. That is the number
to watch:

```sh
node scripts/repo-vs-live.mjs
```

It exits 0 on a value difference, deliberately — the comparison began life with
413 findings and a gate that fails on the day it lands gets switched off rather
than fixed. `drift-check --remote` will keep saying `NO DRIFT` throughout, and
is right to: bookkeeping and row contents are different questions.

Closing it is done **per catalog**, by exporting the divergent rows from
`--remote` into a `zzzz-`-tier script.
[`zzzz-restore-gear-full-columns.sql`](../db/zzzz-restore-gear-full-columns.sql)
is the worked example: `restore-gear-missing-from-repo.sql` carries six of
gear's eighteen columns, so 53 rebuilt rows had a name and prose and no price,
weight, damage or mega-damage flag — **twenty-four weapons that are
mega-damage in production rebuilt as S.D.C.** That one script took the catalog
totals from 428 field differences to 230. The skills and psionics `restore-*`
twins carry ten and eleven columns and do not have that particular defect; what
they have is this one.

The full account, and what is left, is
[`REBUILD-AUDIT.md`](../REBUILD-AUDIT.md).

What an environment has had run, and when:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT filename, count(*) AS runs, max(run_at) AS last_run,
          max(note) AS asserted FROM data_script_runs
    GROUP BY filename ORDER BY last_run DESC;"
```

A script on disk with no row there has never been run against that database.

**The reverse is not fine, and this paragraph used to say it was.** It read
*"a data script may be deleted once its correction is folded into the class it
rewrote, and the log keeps the record that it ran"* — and
[`scripts/drift-check.mjs`](../../../scripts/drift-check.mjs) reports a recorded
filename with no file as `RUN BUT NO FILE`, which is a **problem**, not an
advisory: the run prints `DRIFT FOUND` and exits 1. Two documents, one saying
delete freely and the other failing the build for it.

The tool is right and the sentence was wrong, for a reason deeper than the exit
code. **A correction is never "folded into the class it rewrote"**, because a
`fix-*.sql` does a guarded `replace()` against markdown living in D1 — its
effect is in the database and nowhere else. The repo can only rebuild that
database by running the script again, which is exactly what
[`repo-vs-live.mjs`](../../../scripts/repo-vs-live.mjs) checks. Delete the file and
a rebuilt environment silently comes up with the pre-fix class.

So: **a data script is as permanent as a migration once applied.** The only
difference is that it changes rows rather than schema. If one truly becomes
redundant — because a later script overwrites the same text unconditionally —
the honest move is a header comment saying so, not a deletion. Nothing in 171
scripts has met that bar.

The audit that produced most of them is [`docs/rules-audit.md`](rules-audit.md).

Merging to `main` is the deploy — Pages auto-deploys, no CI, no build command.
Cloudflare Access fronts the whole site with the path left blank, so every route
including `/api/*` is covered; there is no Access policy-as-code in the repo.

Verify anything applied to production by querying it back, not by trusting an
exit code — `wrangler d1 execute` has been observed reporting a non-zero exit on
a fully successful run. Twice now, in different disguises:

- a plain non-zero exit on a run that fully applied
- `Authentication error [code: 10000]` from `--remote --file`. `--file` does not
  run your SQL over the query API: it uploads the file, triggers D1's separate
  **import** endpoint, then polls it. That endpoint is the unreliable part —
  the same command, same token, minutes apart, has both **succeeded while
  printing this error** (011, which had fully landed) and **genuinely failed**
  (012, which had not applied at all). The message is auth-shaped either way and
  sends you off checking credentials that are working fine.

  **Prefer `--command` for remote migrations.** It goes over the query API,
  takes multiple statements separated by `;`, and has not failed. Use `--file`
  locally, where none of this applies.

  **`--command` fights PowerShell over double quotes.** PowerShell has no
  backslash escaping, so `\"` inside a double-quoted `--command` does not
  escape anything — the string ends early and the rest word-splits into
  arguments wrangler rejects. That bites hardest on exactly the queries most
  worth running remotely, because class markdown cites gear as
  `item_id: "slug"` with real double quotes in it.

  Build them in SQL instead, the same way `char(8212)` already handles the
  em-dash: `instr(markdown, 'item_id: ' || char(34) || 'energy-rifle' ||
  char(34))`. The command then carries no inner double quote at all.

  **`scripts/d1-apply.mjs` is not affected** and needs none of this: it spawns
  wrangler with a real argv array and no shell, so a statement passes through
  untouched however it is quoted. The trap is only for a `--command` typed at
  a PowerShell prompt.

  **Reading a result set back is easier as a file than as terminal output.**
  `--json | Out-File -Encoding utf8 out.json` gives you something to parse
  rather than something to transcribe. Slugs are the reason: `ng-l5-northern-
  gun-laser-rifle` reads as `ng-15-` in most terminal fonts, and a `from:`
  list naming a slug that does not exist is worse than the placeholder it
  replaces.

The check that settles it, every time:

```sh
npx wrangler d1 execute DB --remote --command \
  "SELECT name FROM sqlite_master WHERE name='<your_table>';
   SELECT filename FROM schema_migrations ORDER BY filename;"
```

`sqlite_master` and `schema_migrations` are authoritative. `pragma_table_info`
is not — over `--remote` it has returned stale replica data mid-migration.
Migrations are safe to re-run regardless (`IF NOT EXISTS` plus
`INSERT OR IGNORE`), so the cost of checking first is nothing.

---
