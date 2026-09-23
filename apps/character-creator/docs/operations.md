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
verification SELECTs are re-run and their `assertion` / `got` / `want` rows
are **enforced** - checked first in a scratch replay of the data directory
before anything is applied, then again on the target after each file, and a
mismatch in either place exits non-zero (since 2026-09-16; before that the
rows were printed and the run carried on); and remote runs start with a throwaway
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
| `044-inventory-gear-slug.sql` | adds `gear_slug` to `character_items` and `campaign_items`, and backfills it from the id already there. A gear id is `AUTOINCREMENT`, so it is INSERTION ORDER, and insertion order is not the same in two databases - measured 2026-09-05, a rebuild from this repo matched production on **0 of 1025** gear ids, so a rebuilt database would attach every inventory row to the wrong item with the foreign key satisfied throughout. `item_id` stayed at the time, on Nate's word - additive now, drop later - and **045 is the drop**. Not called `item_slug`, which two endpoints already use as an alias for `gear.slug`. See `RETRO-AUDIT.md` R21 |
| `045-inventory-check-on-slug.sql` | moves both inventory `CHECK` constraints from `item_id` to `gear_slug`, and changes nothing else. **It exists so `046` can ship with no deploy window.** The ordering rule below - schema to production BEFORE the merge - is written for ADDITIVE changes, and a DROP is the mirror image: apply the drop first and the deployed sheet 500s on a join to a column that has gone; merge first and the wizard cannot finish a character, because the new code writes no `item_id` and the old `CHECK` still demands one. This removes the second horn - after it, both the deployed code and the merged code are valid, because `044` already made every write derive the slug inside its own statement. A table rebuild, since SQLite cannot `ALTER` a `CHECK`. See `RETRO-AUDIT.md` R21 |
| `046-drop-inventory-item-id.sql` | drops `item_id` from `character_items` and `campaign_items`, leaving `gear_slug` as the only key. A **full table rebuild**, on `036`'s twelve-step precedent: SQLite refuses `DROP COLUMN` while a `CHECK` names the column - probed rather than assumed, and the `CHECK` is the sole blocker, which is why `045` moves it first. Unlike `036` these tables have an index each, recreated after the rename; nothing references either by foreign key. **The ten data scripts that joined on `item_id` were rewritten onto the slug**, which breaks the rule that an applied script is never edited - knowingly, on Nate's word, because every alternative costs a rule too: leaving the column in `schema.sql` while production loses it is schema drift `drift-check.mjs` reports, and `no such column` is a prepare-time error no guard can duck. The rewrite is provably equivalent - a guard keyed on `ci.item_id = gear.id` and one keyed on `ci.gear_slug = gear.slug` return the same rows. **Applied to production AFTER the merge**, which is the one place this file's ordering rule is deliberately inverted; `045` is what makes that safe. The wire format is unchanged - the wizard still POSTs a numeric `item_id` and `character_drafts.state` still holds raw gear ids - so the slug is derived inside each insert. See `RETRO-AUDIT.md` R21 |
| `047-gear-slug-not-null.sql` | makes `gear.slug` `NOT NULL`. `046` left the whole of inventory's meaning on a column the schema still allowed to be null, and `UNIQUE` does not help - SQLite permits any number of NULLs in a unique column. A table rebuild, since SQLite cannot add `NOT NULL` in place; `gear` has no index of its own, but two tables declare `REFERENCES gear(slug)`, so the drop and rename run with foreign keys off. **Ids are copied explicitly** - `catalog_redirects.to_id` points at them, and letting `AUTOINCREMENT` reassign would silently repoint twenty redirects at the wrong rows. **No code change and no deploy window**: the app already refused a blank slug (`catalog-fields.js` marks it `required`, and `coerceField` counts `''` as blank), and all 477 committed `INSERT INTO gear` statements name it. Does NOT refuse an empty string - that would need a `CHECK`, and is a separate decision. See `RETRO-AUDIT.md` R21 |
| `048-vehicles.sql` | `vehicles`, `vehicle_locations` and `vehicle_weapons` - three tables for power armour, robots, drones, borg models, combat vehicles and ships. **`BOOK-INGEST-AUDIT.md` F3 named this gap and CLOSED it once**, on 2026-09-03 in PR #616, as the third of three options: keep dropping vessels and say so in `docs/known-limitations.md`. That closure declined this table and a JSON `systems` column both, on the measurement that *"nothing has asked"* - and named the trigger for revisiting: *"Reopen it the moment something asks."* Something asked on 2026-09-07, and this is F3's own first option built as described; F3 carries a dated reopening note and its closure stands unedited. **THREE tables because a vessel is not a row**: M.D.C. arrives BY LOCATION and weapon systems as a numbered list, and folding either into one column is the loss F3 refused - *"picking one weapon system out of eight and dropping the rest... the row would read as complete."* **Nothing migrates the 36 existing `gear` rows with `category = 'vehicle'`**, and nothing in the app reads these tables yet: this is the shape, and the data and the reader come after. See `BOOK-INGEST-AUDIT.md` F3 |
| `049-spell-same-spell-as.sql` | adds `spells.same_spell_as`, a `name` reference saying *this row is another book's retelling of that row*. `spells` is keyed on a unique name and carries ONE `level` and ONE `ppe`, which is right for a catalog where a spell belongs to one tradition; Rifts is not that catalog. Underseas prints an Ocean Magic list the Book of Magic already publishes as Water Warlock invocations, at different levels and costs, so the import shipped them under an `Ocean:` prefix - correct at runtime, and two rows holding one spell that drift the moment either is corrected. **`drift-check` cannot see that**: it compares a row to its cited page and both rows cite pages that agree with them. This is F26's SMALLER option, `copy_of` for spells; the larger one - a `spell_traditions` join table with a per-tradition level and cost - was declined as too big for ten rows. **Nothing reads it at runtime**; the checker does. A `name` reference rather than an id, because ids are insertion order and differ per environment, and NO foreign key, because the target may legitimately be created by a later data script and filename order is execution order. **Six rows carry a link, not the nine the finding listed** - four of the ten same-named pairs are different spells wearing one name. See `BOOK-INGEST-AUDIT.md` F26 |
| `050-catalog-pair-dismissals.sql` | `catalog_pair_dismissals` - a suggested duplicate pair a human looked at and judged DISTINCT, so `findDuplicates` stops proposing it. **It records only the NO.** A confirmed duplicate is executed rather than recorded: `mergeRows` repoints the inventory, collapses existing redirects, leaves a forwarding redirect and DELETES the losing row, so that pair can never be suggested again and a row saying "these were merged" would be a second copy of a fact the catalog already holds. The shape is `npc_proposals_dismissed`, which solved this for a different suggester. **The two keys are stored SORTED** because the detector walks rows in id order, so which is `a` and which is `b` differs between a rebuilt database and production; sorting gives one pair one identity and makes the UNIQUE constraint mean what it looks like. Keys rather than ids for the reason `049` gives - ids are insertion order. **No foreign key**, so a dismissal survives one of its rows being merged away later: the record that somebody judged the pair stays true, and a dismissal naming a row that no longer exists is inert rather than broken. **Nothing merges automatically and this changes no row in any catalog.** See `BOOK-INGEST-AUDIT.md` F33 |
| `051-media-shares.sql` | `media_shares` — one MediaVault user lets another **read** their library. Every statement in that app binds the caller's own email, so a library has been readable by exactly one person since it was built; this row is the only thing that says otherwise, and the single endpoint consulting it is `SHARE-AUDIT.md` V2's. **The pair `(owner_email, viewer_email)` is the key**, so granting twice is idempotent and revoking is a `DELETE` of one known row. **No token**: the viewer passes Cloudflare Access to reach the site at all, so the reader checks the viewer's own Access email against `viewer_email` and a leaked row identifier grants nothing. **No foreign key** — this site has no users table, identity being a header Access injects, and a grant naming an address that cannot sign in is inert rather than broken. **No `revoked_at`**: revocation is a `DELETE`, and a row claiming a share was revoked would be a second copy of what the row's absence already states — the argument `050` makes for recording only the NO, from the other side. `created_at` is epoch ms to match `media_items.added_at` rather than the `datetime('now')` text this app's tables use. See `apps/media-vault/SHARE-AUDIT.md` V1 |
| `052-character-vehicles.sql` | `character_vehicles` — the vessel a character owns, and the damage it carries. Vessels have been a catalog since `048` and readable since the codex learned the section, but nothing could OWN one: `character_items.gear_slug` REFERENCES `gear(slug)`, so a robot could not go in an inventory even in principle. **A separate table rather than a column on `character_items`** — that table's `CHECK` and its `gear(slug)` foreign key are load-bearing and widening them to mean "gear OR vessel" makes both weaker; the sheet's inventory table renders every row that endpoint returns, so a robot would arrive as a line item with a quantity box; and `qty` and `equipped` are the wrong questions about a robot where `mdc_current` is the right one. **`mdc_current` is JSON keyed by LOCATION NAME**, because the maxima are catalog data and the damage is per-instance: two Glitter Boys in a party take different hits to the same arm. A location absent from the object is undamaged, so a fresh vessel is `{}` rather than a copy of the catalog — which also means a book correcting a location's M.D.C. does not rewrite every character who owns one. `_lib/character-json.js` owns that empty value, as it does for `character_items.enchantments`. **Soft removal** via `removed_at`, exactly as inventory does it: a vessel lost in play is history. |
| `053-gear-vehicle-slug.sql` | `gear.vehicle_slug` — this gear row is really a VESSEL, and the vessel is in `vehicles` under this slug. `BOOK-INGEST-AUDIT.md` F41: 24 rows carry `category = 'vehicle'` and a real per-location stat block, written before `048` gave vessels three tables. **They cannot simply move**, because class markdown cites gear by slug in `equipment_starting[].item_id` and `catalog_redirects` cannot forward a key out of its own catalog — its `to_id` is documented as "row in that catalog's table", and five query sites resolve a gear slug through it, every one binding `catalog = 'gear'`. So the gear row stays as the citation target and points at the vessel. **NULL is the normal state** and there is **no foreign key**, deliberately: the 24 rows span five books and are transcribed one book-session at a time, so a pointer naming a vessel not yet imported is inert rather than broken — the same choice `051` makes, for the same reason. It does not delete, hide or re-categorise the gear row, and nothing reads it to decide what a thing IS. |
| `054-campaign-rest-rates.sql` | `campaigns.rest_rates` - the table's own per-hour recovery rate for each pool, as JSON, set by the G.M. on the campaign dashboard. `UI-AUDIT.md` F52: the rates lived only in one device's localStorage, so a player on a new phone started blank. **NULL means none**, and there is still **no default number anywhere** - the books' recovery pages are not in the rules audit, and a rate the app invented would be silently trusted. The sheet prefers the campaign's rates and falls back to the device's. The campaign PATCH accepts only the five pool names and non-negative numbers, and drops zeroes. |
| `055-spell-tradition.sql` | `spells.tradition` - the family a spell belongs to (warlock, ocean, dolphin, spellsong, cloud, shaman; NULL is a general invocation) - and `pending_power_picks.spell_traditions`, the allowance a banked level-up grant carries. `BOOK-INGEST-AUDIT.md` F57: a class whose spell pick is a LEVEL RANGE was offered every tradition's spells; now it reaches one only if its `magic.spell_traditions_allowed` names it. **A named list is unaffected.** The rows are tagged by `zzzzzzzzz-f57-spell-traditions.sql`, not the migration. A banked grant from before 055 has NULL and stays unrestricted. **A new spell import must set `tradition`.** |
| `057-super-abilities.sql` | `super_abilities` - the FIFTH kind of power here, after spells, psionics, skills and enchantments, and the one that has NEITHER a cost NOR a level. A Heroes Unlimited super ability is a permanent trait the character simply has; what it prints instead is a stat block - Range, Duration, Damage - describing the trait in use. Storing one in `spells` would demand a level it does not have, and in `psionic_powers` an I.S.P. cost it does not have, putting a non-psionic trait behind an I.S.P. gate on the sheet. Decision **D3** of the Heroes Unlimited batch (`docs/surveys/heroes-unlimited-core.md`); roughly **364 rows** were waiting on it - 69 in the Revised core, 170 in Powers Unlimited One, 125 in Three - and none could be imported before it existed. `tier` is minor | major and is deliberately **not a CHECK**, for the reason `BOOK-INGEST-AUDIT` F73 spent a whole finding on: SQLite cannot widen one without rebuilding the table. That was written while `gear.system` and `vehicles.system` were still two-valued; migrations 059 and 060 have since paid that cost, and the sixteen-table rebuild 058 needed is the argument for this column staying free text. **No `bonuses` column**, though many of these abilities grant one - nothing reads it and no importer writes it yet, and a column that is always NULL reads as missing data rather than as a feature not yet built. **Declared in `js/catalog-fields.js`**, so the editor, the write endpoints and the importers all build themselves from it - that config is the single place that knows what a row looks like. It carries **no cost field and no level field**, and their absence is the whole reason it is not `spells` or `psionic_powers`. **Wired into `catalogs.js` since PR #1033**, when the `super_abilities` grant block gave a class a way to reference one - the boot payload carries a lean projection of name, tier, system, source_book and the stat line, never the 994KB of descriptions. |
| `058-campaign-system-third-game.sql` | `campaigns.system` admits `nightbane` and `heroes-unlimited`. **`BOOK-INGEST-AUDIT` F73's blocking half**, left standing when F73 was taken in PR #996 as its own Option C - catalog and classes only, the CHECK deliberately untouched. Two games were behind it: Nightbane surveyed since 2026-09-12, and Heroes Unlimited with fourteen classes, 364 super abilities and 388 skills in production and no campaign they could be played in. **This rebuilds SIXTEEN tables to change one constraint**, because SQLite cannot alter a CHECK in place and `campaigns` has six direct children which are themselves parents of nine more. F73's options table called it "a table rebuild on `campaigns`", one table; its premise audit corrected that to "roughly 3 parents and 11 children"; both were low. **A cheaper route was tried and it destroys data silently** - `PRAGMA legacy_alter_table = ON`, probed against local D1, was IGNORED, and the `DROP TABLE` that followed took a child row with it through `ON DELETE CASCADE` while reporting `"success": true`. That is worse than the two pragmas `047` tried, which at least failed. So the ORDER does the work, exactly as `047` established: build suffixed copies, copy rows parents-first, drop originals children-first, rename back, recreate the 19 indexes and triggers. Tested end to end against a populated local foreign-key graph - 26 rows across 20 tables, nothing lost, the cascade still firing, and a typo still refused. |
| `059-gear-system-third-game.sql` | The same widening for `gear.system`, rebuilding `gear`, `character_items` and `campaign_items`. `character_items` is in this subtree AND in 058's, so it is rebuilt twice; the row-count comparison covers both passes. |
| `060-vehicle-system-third-game.sql` | The same for `vehicles.system`, rebuilding `vehicles`, `vehicle_locations`, `vehicle_weapons` and `character_vehicles`. |
| `061-skill-system-bases.sql` | `skill_system_bases (skill_name, system, base, per_level)` - a skill's percentage where one GAME prints a different one. **`BOOK-INGEST-AUDIT` F83.** The catalog holds one `base` per skill, which was true enough while every book in it was Palladium's own; Heroes Unlimited prints its own figure for every skill and disagrees with the catalog on **64 of the 74 names they share** - Computer Operation is 60% there and 40% here, Prowl 46%/+8 against 25%/+5. (This cell said *48 of the 55* until 2026-09-14, when the whole of printed 30-36 was re-read with a reader validated against the rows already shipped; the row count itself is the clean-run table below, which a test pins.) A class can already state an absolute for a skill it NAMES; what it cannot do is state one for a skill the PLAYER picks, because a choice group's `bonus:` adds to whatever the picked row holds. Across the sixteen Heroes Unlimited education classes that is 108 of 432 entries. Keyed on `skills.name`, which is `NOT NULL UNIQUE`, and never on `id` - that is AUTOINCREMENT and so differs per environment. `ON UPDATE CASCADE` so a catalog rename carries the override rather than stranding it, which is how a rename broke six classes' restrictions once before. |
| `062-vehicle-sdc-and-armor-rating.sql` | `vehicles.ar` and `vehicles.is_mega_damage`. Migration `060` opened `vehicles.system` to `heroes-unlimited` and gave the table nowhere to put what that game prints: its 49 conventional and military vehicles carry an **A.R. and an S.D.C.**, never an M.D.C. - *"A.R.: 18, S.D.C.: Main body - 1000, main gun - 200, treads - 75 each"*. **M.D.C. and S.D.C. are a unit, not a label**: one M.D.C. point absorbs a hundred S.D.C., so writing the Patton's 1000 into `mdc_main_body` would state it survives what a Glitter Boy survives, and the editor form labels that field *"M.D.C. (main body)"* so it would say so on screen too. `gear` settled this when it was built and has carried `is_mega_damage` ever since; this is the same flag on the other catalog. The flag governs that vehicle's `vehicle_locations.mdc` rows as well, so no column is added there and the Patton's *"treads - 75 each"* needs no second flag. **Defaults to 1**, which states what was already true of all 171 rows in the table - every one a Rifts vessel, checked rather than assumed; a default of 0 would silently reclassify them. `ar` is a column and not a note because an Armour Rating is a to-hit threshold the rules read, the same number `gear.ar` already holds for body armour, and it stays NULL for M.D.C. vessels, which do not have one. |
| `063-talents.sql` | `talents` - the NINTH catalog, and the only power here that costs something to HAVE as well as something to USE. A Nightbane Talent is bought once with a permanent P.P.E. expenditure and paid for again on every activation, so neither `spells` nor `psionic_powers` can hold it: each carries one integer cost column and a Talent stored in either silently loses a number. `BOOK-INGEST-AUDIT.md` F76. **The finding's "two cost columns" is wrong and the table is not shaped that way** - counted off the cache 2026-09-15, printed 106-115, only THREE of the 25 Talents are a clean acquire/activate pair and the other 22 carry a third term (`"15 to activate, plus 15 P.P.E. for each additional minute"`), with two stating no activation integer at all. So it is `acquire_ppe` plus `ppe` plus `ppe_note`, where `ppe` is the activation MINIMUM and the note carries the schedule - **exactly the pair `spells` and `psionic_powers` already have and which F76 never weighs**, live on 143 spells and 21 psionic powers. `form_required` is free text rather than a `morphus_only` flag because the 25 `Limitations:` blocks give four answers - morphus 22, facade 1, both 1, and one that states no form at all - so a boolean would have to invent three of them. `min_character_level` is an INTEGER because the book is not: ten Talents are level-gated and those ten lines spell it six different ways, mixing `3rd` with `third` and `fifth`. `prerequisite` is free text and F76 does not mention it at all - five Talents have one, four gated on a Morphus characteristic and one, Mirror Search, on another Talent. **No `damage` column**, though `super_abilities` has one: no Talent prints a flat damage, Shadow Blast dealing 1D4 S.D.C. per P.P.E. spent and Bloodbath's 1D6 landing on the USER, so the column would hold a formula nothing parses. **No CHECK on `system`**, matching the other three power catalogs - what F73's blocking half widened in #1037 was the CHECK on `campaigns`, `gear` and `vehicles`, and adding one here would re-create the problem F73 was filed about. **Its seed line sits beside its CREATE in `db/schema.sql`, not in the seeding block**, because a guard that runs before its own table never fires; verified on a one-pass `node:sqlite` build 2026-09-15. |
| `064-pending-power-picks-talent.sql` | `pending_power_picks.kind` admits `talent`. `BOOK-INGEST-AUDIT.md` F76 (4 of 4). The Nightbane's FREE Talents are a LEVEL schedule rather than a creation-time lump - printed 106, *"Acquiring Talents"*, gives one Talent free at first level and one more at levels four, seven, ten and twelve - so a grant at level four has to be banked, and banking writes a row here. **This is a CHECK widening and adds no column, which is the whole reason it was possible**: `js/leveling.js` still refuses a per-level super-ability grant because a banked one would need a TIER column this table has not got, whereas a Talent's gate is its own `min_character_level` and `prerequisite` - properties of the catalog row and the character, evaluated when the pick is spent. **A single-table rebuild, unlike `058`'s sixteen**: nothing references `pending_power_picks` (checked against `sqlite_master` on 2026-09-16, which answers `[]`), it has one index, and production held 0 rows. **Columns are copied BY NAME**, because production's table is `036`'s rebuild plus five later `ALTER`s - `categories`, `slot`, `from_names`, `note` and `spell_traditions` sit at the END there and in the middle in `db/schema.sql` - so a positional `SELECT *` would land `note` in `spell_levels`. After this runs the two agree about column order for the first time. Its seed line sits beside the table's `CREATE` and is guarded on the CHECK TEXT rather than on `pragma_table_info`, which cannot see a constraint. |
| `065-character-ppe-base-spent.sql` | `characters.ppe_base_spent` - P.P.E. taken PERMANENTLY out of a character's base. `BOOK-INGEST-AUDIT.md` F101. A Nightbane buys Talents with it (printed 106, *"each purchase will cost the character a permanent expenditure of P.P.E."*) and seven catalog spells burn it from the caster - Close Rift, Ley Line Resurrection, Ley Line Restoration, Enchant Weapon (Minor), Bone: Return from the Grave, Nature: Sacred Oath and Summon & Use Stones & Crystals - so it is **not named for Talents**. **`ppe_max` stays the ROLLED maximum** and the effective one is derived as `ppe_max - ppe_base_spent`, which was Nate's choice (2026-09-16) and is what makes it safe: writing the reduced number into `ppe_max` instead would have the validator refuse the character with a 422, because it bounds `ppe_max` against the class formula on both sides, and it would let the three server paths that rewrite `ppe_max` - create, level-confirm and the variant re-roll - silently erase the spend, the same failure shape `F67`, `F68`, `F70` and `F71` were each filed against. None of them touches this column. **Two readers use the effective maximum and nothing else needs to**: the PATCH route's clamp on `ppe_current`, and the sheet, through one function `poolMax` that the first render, the live repaint and the rest-recovery preview all read. **Not player-editable**, matching `ppe_max` rather than `ppe_current`: a permanent spend is a rules fact, and a free PATCH could set it back to 0. Its seed line sits directly after the `characters` CREATE, per `F99`. |
| `067-spell-ppe-permanent.sql` | `spells.ppe_permanent` - P.P.E. a spell burns out of the CASTER'S base, as a dice expression (`2`, `2D6`). `BOOK-INGEST-AUDIT.md` F101 (3 of 3). Seven catalog spells in three books take P.P.E. from the caster's base - Close Rift, Ley Line Resurrection, Ley Line Restoration and Enchant Weapon (Minor) in the Book of Magic, Bone: Return from the Grave and Nature: Sacred Oath in Mystic Russia, Summon & Use Stones & Crystals in Wormwood - and the number lived only in prose. **The number only, which was Nate's answer (2026-09-16)**: WHEN it is burned - on success, only if made permanent, each full moon, doubled for a creature of magic - stays in the description, and the sheet rolls the expression into `characters.ppe_base_spent` when the player says the condition was met. TEXT because five of the six filled are dice. NULL burns nothing. Its seed line sits in the seeding block after the `spells` CREATE, with the column's other guards. |
| `066-pending-power-picks-talent-purchase.sql` | `pending_power_picks.kind` admits `talent_purchase`. `BOOK-INGEST-AUDIT.md` F101 (2 of 3). Printed 106 lets a Nightbane BUY two Talents at level one and at every level after, each for a permanent expenditure of P.P.E., and an unused purchase banks like a free pick (Nate, 2026-09-16) - so it writes a row here. **A kind of its own and not a `talent` row**: a purchase is spent by choosing AND paying the Talent's `acquire_ppe` out of `ppe_max - ppe_base_spent`, and at levels four, seven, ten and twelve a free grant and a purchase allowance would otherwise share the key `talent:level:slot`. **The same single-table rebuild as `064`**, re-measured `--remote` 2026-09-16 rather than assumed: no table references it, one index, 0 rows, 13 columns. Columns copied by name. Its seed line sits beside `064`'s, guarded on the CHECK text. |
| `068-morphus-characteristics.sql` | `morphus_characteristics` - the TENTH catalog: one row per ENTRY of the 19 percentile tables Nightbane prints on 91-106 (154 entries, every one "Roll or select"), plus one `intro` row per table for the preamble above its bands. Nightbane survey D5, **decided 2026-09-16 in #1133 on Nate's word** - the catalog, then the second body and its Facade/Morphus sheet toggle, then the wizard generator, as separate PRs. **Schema only: no row, no character column, and nothing reads it yet**; the entries follow as a data script. **Keyed on a stored `key` (`<table_name>: <name>`), not on the composite (`table_name`, `roll_low`, `name`)**, because `catalog-fields.js` keys a catalog on ONE column and the clash check, rename redirects and pair dismissals all read it as one; a table CHECK holds `key` equal to its parts, and `catalogs/rows.js` now answers a CHECK failure with a 422 rather than a 500. The key is stricter than the composite - it forbids one table printing a name twice - and the cache was read table by table to confirm none does; names DO repeat across tables ("Combination of Two" is in four). `kind` is effect / route / combination / intro, free text. `bonuses` is a class `bonuses` block through the same `validateBonuses`, dice and pools allowed as on `totems`. **Horror Factor is two columns**, `horror_factor` (added) and `horror_factor_set`, because three entries SET it and a set is not a sum. **`horror_factor` is TEXT**: 73 entries add a roll (`1d4`, `1d6`, `1d4+1`, `1d4+2`) and only a few a fixed number, so it holds a whole number or a dice expression through a new `dice` field type that reuses the parser's `isDiceBonus` (now exported) - rolled once when the Morphus is created, the way dice attribute bonuses are rolled into `rolled_bonuses`. `horror_factor_set` stays INTEGER. `routes` (`[{table, count}]`) and `sub_choices` (strings) are JSON lists, edited as JSON text through a new `json_list` field type - no parser owns either shape, so there was no validator to reuse. `routes[].table` references nothing: Animal Form routes to a Bear and an Amphibian table the book never prints. **No CHECK on `table_name` or `system`.** No `MERGE_REFS` entry - names that match across tables are different entries by construction. In `drift-check`'s `CITATION_TABLES`, since its names are the printed entry headings. **Its seed line sits beside its CREATE in `db/schema.sql`**; verified on a one-pass `node:sqlite` build 2026-09-16. |
| `069-character-second-form.sql` | `characters.second_form` - a character's SECOND BODY, as JSON, `NOT NULL DEFAULT '{}'`. `BOOK-INGEST-AUDIT.md` F74, built by Nightbane survey D5 (PR 2 of 4; after 068 read by this PR). A class describes how its second form differs in a `second_form` frontmatter block; this column holds what the character ROLLED for it - `form_rolls` (the form's own dice, the Morphus's 2D6x10 S.D.C.), `hp_rolls` (one per level), `results` (`morphus_characteristics.key`, a `sub_choice`, and every dice value the entry carries, rolled once) - plus `active` (which form the sheet shows) and the form's own `sdc_current` / `hp_current`, because Nate's answer was that **damage is tracked separately per form**. **Rolls, never totals**: the second form's maxima are folded from them on every read by `js/second-form.js`, because its hit points are read against ITS P.E., which a result moves. **One JSON column and not a second set of pool columns**, so every path that reads or writes the first form's columns - play events, rest, the G.M. dashboard, level-up, the validator - is untouched, and a one-body character cannot be affected. The create endpoint refuses a key that is no entry, a roll outside its dice and a current value above the form's maximum; the PATCH clamps. **Its seed line sits directly after `065`'s, beside the `characters` CREATE.** |
| `070-character-kind.sql` | `characters.kind` - `'pc'` or `'npc'`, `NOT NULL DEFAULT 'pc'`. Phase 1 of the NPC / bestiary work (decided with Nate 2026-09-17): a G.M.'s statted NPC is a `characters` row owned by the campaign's G.M. with `kind = 'npc'`, so the sheet, level-up, play mode, rest and the validator all work on it unchanged. **Rejected**: a separate `campaign_npcs` table (~40 duplicated columns and a second sheet renderer) and stat columns on `npcs` (the dossier is the narrative record, and has no pools, skills or powers shape). **No CHECK**, as `skills[].type` has none - a CHECK refuses a saved row rather than a bad write, and `058` rebuilt sixteen tables to widen one. **The column hides nothing by itself**: character reads are open to any signed-in user, so NPC privacy is the read path's job, and that lands before anything can write `'npc'`. Seed line directly after `069`'s. |
| `071-npc-character-link.sql` | `npcs.character_id` - the statted sheet behind a dossier, a `characters` row with `kind = 'npc'`. **Optional both ways**: a dossier with no stats is the normal case, and a rolled bandit needs no dossier. `ON DELETE SET NULL`, so deleting the sheet never takes the dossier and its journal backlinks with it. Not unique. Seed line directly after the `npcs` indexes. |
| `072-notable-npcs.sql` | `notable_npcs` - the named people the books stat, one row each: the ELEVENTH catalog, and Phase 2 of the NPC / bestiary work (decided with Nate 2026-09-17). A book prints FIXED numbers for one person, so the row stores what was printed - structured where a sheet reads it (`attributes`, the pools, `combat` and `skills` as JSON) and prose where the book writes prose (magic, psionics, super powers, cybernetics, equipment - prose by decision, not catalog links). **Filed by a mechanical rule**: a stat block with a Real/True/Greek Name line or a numeric experience level is a notable NPC, not a creature. A G.M. copies one into a campaign through `campaigns/[id]/npcs/from-notable` as a `kind = 'npc'` character with class_id `notable:<slug>` - one-way, and with no class rules over the book's own totals. `description` is a short cited paraphrase, never the book's prose. Seed line directly after its CREATE. |
| `073-stat-attacks.sql` | `stat_attacks` - a printed stat block's attacks, one row each, for ANY owner: `owner_kind` 'notable_npc' now and 'creature' when the bestiary lands (one table for both, decided 2026-09-17). **No foreign key**, `gear.vehicle_slug`'s reason, which is what lets it land before `creatures` exists. `UNIQUE (owner_kind, owner_slug, name)` so a data script can `INSERT OR IGNORE` and be re-run. `damage` is TEXT and `is_mega_damage` structured, for gear's reason. Seed line directly after its CREATE. |
| `074-creatures.sql` | `creatures` - the species the books stat, one row each: the TWELFTH catalog, and Phase 3 of the NPC / bestiary work (decided with Nate 2026-09-17: two tables, not one). A species prints DICE, so the row stores FORMULAS - `attributes` as JSON of sheet keys to formulas, the pools as formula text - in the one strict grammar of `js/creature-roll.js`, and `campaigns/[id]/npcs/from-creature` rolls them. Filed by 072's mechanical rule from the other side: no Real Name line and no numeric level. Attacks reuse `stat_attacks` (073) as `owner_kind = 'creature'`. Seed line directly after 073's. |
| `075-skill-system-bases-level-bonuses.sql` | `skill_system_bases.level_bonuses` - a W.P.'s bonus schedule where one GAME prints a different one. **`BOOK-INGEST-AUDIT` F102**, option A. A W.P. is `base 0 / per_level 0` and carried wholly by `level_bonuses`, so 061's two columns could not hold Heroes Unlimited's W.P. Targeting (+1 strike at 2, 4, 7, 10, 13, thrown AND bows) against the catalog's Palladium Fantasy row. The override REPLACES the row's schedule rather than merging into it. A single-table REBUILD, not an ALTER, because 061's CHECK refused a row with neither `base` nor `per_level`; measured first `--remote`: nothing references the table, one index, 89 rows. `json_valid` on the new column. Seed line guarded on the column, beside 061's. |
| `076-psionic-system-costs.sql` | `psionic_system_costs (power_name, system, isp, isp_note)` - a psionic power's I.S.P. price where one GAME prints a different one. **`BOOK-INGEST-AUDIT` F102**, the psionic half: Hypnotic Suggestion is 6 in the catalog, 2 in Heroes Unlimited, 2 or 4 in Nightbane. The sibling of 061 rather than a second row per game, because `psionic_powers.name` is UNIQUE and a second row would split the one name every game prints. `isp`/`isp_note` mean what they mean on `psionic_powers` (the minimum, and the varying schedule), NULL = the catalog's own. Keyed on the name, `ON UPDATE CASCADE`. Seed line directly after its CREATE. |
| `077-claude-usage-cache-tokens.sql` | `claude_usage.cache_write_tokens`, `cache_read_tokens` - the cached part of a call's `input_tokens`, split by how it bills (a write at 1.25x, a read at 0.1x). **`INGESTION-AUDIT` F35**, from `F23`'s closing paragraph: the table could count tokens and not price them. `input_tokens` stays the TOTAL the call processed - the extractor has summed it that way since F23, and the proxy's `recordUsage` now does too. NULL = no figure, which is every row before this one. Record only, and both writers stay fail-open; **apply before the code**, or the fail-open catch drops rows silently. Seed line beside 038's, guarded on the column. |
| `078-campaign-entries.sql` | `campaign_entries` and `campaign_images` - the GM's own pages, and the pictures shown from them. P4a of the app split. `campaigns.gm_notes` was ONE blob per campaign, so a city, a faction, next session's prep and a handout shared a paragraph or had nowhere. THE SPLIT BETWEEN THE TWO TABLES IS THE RULE: an entry is the GM's and is never revealed; an image is revealed one at a time and its `caption` is the only text a player ever reads (Nate, 2026-09-19). `revealed_at` is a TIMESTAMP, not a flag, because "what have I shown them, and when" is asked mid-session. `entry_id` is nullable, so a picture can exist with no page behind it. Deleting a page cascades the image ROWS; the endpoint deletes the R2 OBJECTS in the same request, because no cascade reaches a bucket. Seed line directly after the tables. |
| `079-npc-library.sql` | `npc_library` - a G.M.'s own statted NPCs, belonging to no campaign (Prompt 3 Phase 3, 2026-09-23). A separate table, NOT a nullable `characters.campaign_id`: that column is NOT NULL, cascades, and is read by 37 files (Nate chose the table, 2026-09-22). An entry is a SNAPSHOT in `sheet` (JSON): the character row's own columns - read from the row, not listed, so a later column travels - plus its open skill and power picks, grants, live items and live vehicles. No level history, no play log, no portrait (that is on `npcs`). OWNER ONLY by `owner_email`, 404 to anyone else. Pulling makes an independent `kind = 'npc'` copy in a campaign the caller runs; a game mismatch is a 409 until the request says `force`. Seed line directly after the table. |
| `056-totems.sql` | `totems` - one row per totem animal, Spirit West printed 96-105 - and `characters.totem`, the slug a character took. `BOOK-INGEST-AUDIT.md` F56: nine of the book's O.C.C.s pick one, and a totem grants SKILLS, which no choice a class could offer was able to carry (a chosen ability grants only `bonuses`, `psionics` and `magic`). **A shared table rather than forty entries written into nine classes**, which would have been 360 definitions that must stay identical. A class opts in with `totem: { from: "animal" }`, plus `powers: true` on the Totem Warrior; `composeClass` folds the chosen row in, appending its skills - or printed 96's +10% where the O.C.C. already has one - and summing its bonuses. **No foreign key**, as `051` and `053` argue: a removed totem leaves the character loadable and the validator reports `totem_unknown`. A class without the key is unchanged. |
| `043-character-grants.sql` | `character_grants` — things a table hands out that no class schedule granted: a patron teaches a skill, an artefact confers a power, an implant adds S.D.C. The G.M. usually says so out loud mid-session, so the PLAYER types it in on their own sheet; that is why it is not a G.M.-only table and why `reason` is NOT NULL with no default — the person entering a grant is usually its beneficiary. All eight kinds are in the `CHECK` though only `skill` is implemented, because SQLite cannot alter one. See `docs/plans/19-gm-grants.md` |
| `042-skill-base-formula.sql` | adds `skills.base_formula`, an attribute-derived starting percentage such as `PP*5`. One skill needs it - Phase World's Zero Gravity Movement & Combat, stated as the P.P. attribute number x5% - and storing it at `base` 0 made it indistinguishable from a W.P., which is what 0 means in that column. Consulted only when set, so `base` keeps its meaning and stays the fallback. See `BOOK-INGEST-AUDIT.md` F2 |
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

### Some of those columns are stored but not rendered

**A column in the table above is not a promise that anything shows it.** Several
are written by data scripts, hold real values, and reach **no runtime surface** —
no API projection selects them, so nothing a player opens can display them. That
is not a defect list; it is a fact worth writing down once, because a retro
audit rediscovered it as one (`RETRO-AUDIT` `R7`, 2026-09-04) after asking *who
reads this* rather than *who sets this* — a question none of that audit's four
detectors asked.

Measured against production on **2026-09-04** with
`grep -rn "variant_note" --include=*.js apps/ functions/ scripts/` and by reading
each endpoint's projection:

| column | migration | rows set | read by |
|---|---|---|---|
| `spells.variant_note`, `psionic_powers.variant_note` | `033` | 18 + 2 | **nothing.** Not in any API projection, and not in `apps/character-creator/js/catalog-fields.js` either, so it is not even editable in the catalog admin UI |
| `gear.sdc` | `034` | 34 | the catalog editor only |
| `gear.cost_note` | `032` | 243 | the catalog editor only |
| `gear.ar`, `gear.mdc`, `gear.range`, `gear.rate_of_fire` | `008` | — | the catalog editor only |

**What IS served from the gear stat block is three columns**, and only on a
character's own items: `functions/api/character-creator/characters/[id].js`
joins `gear.category`, `gear.damage` and `gear.payload` for play mode's weapon
cards. `functions/api/character-creator/items.js` — the picker — projects eight
columns and **not one of them is a stat**.

**`034-gear-sdc.sql` justified itself on the grounds that S.D.C. in free text is
somewhere "no sheet and no arithmetic can reach".** That is still true of the
column: no sheet reaches it either. The migration was not wrong to move the data
out of prose — a column can be queried, corrected and counted where a sentence
cannot — but the payoff it named has not arrived.

**Nothing here is proposed as a fix.** Wiring a field to a surface is real UI
work for data nobody has asked to see, and `RETRO-AUDIT` `R7` recommends
declining that until someone does. This section exists so the next audit finds
the answer instead of the question.

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
| classes (published, live) | 337 |
| skills | 390 |
| per-system skill bases | 92 |
| spells | 974 |
| psionic powers | 133 |
| gear | 2830 |
| vehicles | 255 |

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

### Recovery

The paragraphs above establish what this repo cannot restore. This is what can.

**D1 Time Travel is the protection, and it is a rolling 30 days.** Not a backup
you hold - a window Cloudflare keeps, which moves forward every day. Damage older
than thirty days is not recoverable by any mechanism in this account. Measured
against the live database on 2026-09-02 rather than quoted: a timestamp 45 days
back is refused with *"Please provide a timestamp within the last 30 days"*, and
one 20 days back resolves to a bookmark.

Find a point to restore to - either the current bookmark, or the one covering a
moment before the damage:

```bash
npx wrangler d1 time-travel info nates-workshop-media
npx wrangler d1 time-travel info nates-workshop-media --timestamp "2026-08-30T12:00:00Z"
```

Both print the exact `restore` invocation for what they found. The
`CLOUDFLARE_API_TOKEN` in `CLAUDE.md` reaches this, unlike R2 and Pages.

**Do not run `restore` as a drill.** It rewrites the live database, and there is
no scratch database to rehearse on. Practise the `info` half; trust the other.

**`wrangler d1 export` does not work on this database.** It is the obvious
command and it fails outright:

```
D1 Export error: cannot export databases with Virtual Tables (fts5)
```

`journal_fts` is that virtual table - campaign-note search, from
`026-campaign-notes.sql`. One FTS5 table makes the whole database
un-exportable by that path, and no flag skips it.

**A per-table dump is the way to hold a copy off Cloudflare**, and
[`d1-backup.mjs`](../../../scripts/d1-backup.mjs) is that loop:

```bash
node scripts/d1-backup.mjs backups/2026-09-02
```

One JSON file per table, a row count and a byte count for each, and a **non-zero
exit if any table fails** - a backup that reports success after writing half a
database is a defect rather than a posture. Verified against production on
2026-09-02: **33 of 33 tables, 8,723 rows**.

It derives what to skip rather than carrying a list: virtual tables
(`journal_fts` is an INDEX of `journal_entries`, rebuilt by the triggers in
`026`), their shadow tables - found by prefix off the virtual table's own name -
and Cloudflare's own `_cf_*` bookkeeping. A second FTS table added later is
covered without editing the script.

**It is manual, deliberately.** A scheduled export that quietly stops is worse
than a documented one somebody runs, because the first kind is believed.

**What each mechanism actually covers:**

| | Time Travel | a repo rebuild | a per-table dump |
|---|---|---|---|
| the 6,006 rows in the table above | ✅ 30 days | ❌ never | ✅ whenever it was run |
| catalog and class definitions | ✅ 30 days | ✅ | ✅ |
| holds up if the Cloudflare account is lost | ❌ | ✅ | ✅ |

**`NO DRIFT` is not "the repo can reproduce production".** The two checks answer
different questions and both are correct:
[`drift-check.mjs`](../../../scripts/drift-check.mjs) compares migrations, data
scripts, tables, columns and class *names*;
[`repo-vs-live.mjs`](../../../scripts/repo-vs-live.mjs) compares *values*, and
on 2026-09-02 reported **32 fields across 30 rows** differing - reported without
moving the exit code, by design. A green `drift-check` beside a 30-row value gap
is the normal state, and it is the reason a rebuild is not a restore even for
the half of the database a rebuild covers.

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
node scripts/repo-vs-live.mjs              # every catalog it knows
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

**Reading the `z-` rows' ordinals.** They count **escalations, not `z`s**, and
the two differ by one: `zz-` is the first escalation, `zzz-` the second — which
is why the row for `zzzzzz-` (six `z`s) opens "A FIFTH `z`". **The prefix column
is the authority; the ordinal word is a label.** One row counted `z`s instead
and called seventeen of them "a SEVENTEENTH", which read as a tier skipped
between it and the sixteen-`z` row above; corrected 2026-09-21, and it is the
only row that ever disagreed.

| Kind | Files | What they are |
|---|---|---|
| Dev seed | `seed-dev.sql` | Optional local character/campaign rows. Never applied to production |
| Run tracking | `backfill-data-script-runs.sql` | One-time, optional, and an **assertion**: records every script that had already been applied before `data_script_runs` existed, stamped with a note saying the run was asserted rather than observed. Guarded per filename, so it cannot double-record a script that has genuinely run since |
| Data cleanup | `estimate-*.sql`, `backfill-*.sql`, `rename-*.sql`, `merge-*.sql`, `retag-*.sql`, `retire-gear-placeholders.sql`, `retire-leather-armor-placeholder.sql`, `retire-orphan-gear-stubs.sql`, `retire-warlock-generic.sql`, `retire-elemental-shaman-generic.sql`, `untag-cross-system.sql` | One-off corrections to rows an earlier import or data script got wrong or left NULL. `retire-warlock-generic.sql` is the odd one: it retires a CLASS rather than a catalog row, soft-deleting the generic Warlock that the ten per-Force ones replace (RETRO-AUDIT R3), and it sorts after every `add-warlock-*` file so a clean rebuild adds the ten before retiring the one. `retire-elemental-shaman-generic.sql` does the same for the Elemental Shaman, split into four per-element classes by BOOK-INGEST-AUDIT F63. A `rename-*` also leaves a `catalog_redirects` row, so class markdown citing the old key keeps resolving. A `retag-*` changes which system a row belongs to, never what it is — `retag-pf-spells-both.sql` moves 57 spells the Palladium Fantasy book prints from `rifts` to `both` |
| Class corrections | `fix-*.sql`, `apply-*.sql`, `long-bowman-money.sql`, `ley-line-walker-spells-per-level.sql`, `mystic-spells-per-level.sql`, `shifter-spells-per-level.sql`, `ley-line-rifter-spells-per-level.sql`, `record-warlock-palladium-deltas.sql` | The rules audit's output: stored class definitions rewritten against the books, and class data written for a schema feature the day it landed. The Ley Line Walker one is the first to fill `spells_per_level` — the format gained the key before any class carried it, so every caster read as "not recorded" until a book was opened |
| Additions | `add-*.sql` | Something the book gives that the database never had — a catalog row, a whole-table batch extracted from page scans (`add-pf-weapons-batch`, `add-pf-equipment-batch`, the RUE spell and psionics batches), or a whole class. A missing skill named in an `only` restriction narrows its category to nothing, which is usually how one gets noticed. A class goes in this way only when the import tool cannot be reached: production sits behind Cloudflare Access, so a hand-transcribed class is applied by script instead |
| Repo rescue | `restore-*.sql` | Rows that existed **only in production**. The catalog editor and the importer's confirm step both write straight to D1, so nothing in git created what they added: a database built from the repo came up 75 skills, 36 psionic powers and 58 gear rows short, and every class citing one had a dead reference. Exported from the live rows and guarded on the key, so on production they find everything present and do nothing — it is a fresh environment that needs them. Named `restore-` rather than `add-` **for ordering**: an `add-` file sorts before `rename-skills-to-rue.sql`, which would insert the post-rename name, leave the rename's guard to find its target taken, and end up holding both |
| Ordering-sensitive | `zz-*.sql` | Applied in filename order like everything else, which is exactly the problem: **filename order is not the order things were actually run**. `fix-class-skill-names-to-rue.sql` was applied to production by hand, last, so it won; in a repo build it sorts under `f` and three scripts after it (`fix-dead-skill-restrictions`, `fix-dragon-hatchling`, `fix-juicer-rue-edition`) wrote the pre-RUE skill names back. Production was right and a fresh build was wrong, and only the regression restriction audit caught it. Editing those three would break the rule that an applied script is never edited, so the alternative is to sort after all of them — and `zz-` is the only prefix that guarantees it |
| Sorts after the `zz-` files | `zzz-*.sql` | The same escalation a second time. A `zz-` file that CORRECTS another `zz-` file has to sort after it, and `zz-gear-tidy-…` would land before `zz-wire-juicer-uprising-equipment.sql`, which creates three of the rows it corrects — so the tidy would run first and find nothing. The numbers inside the name (`zzz-gear-tidy-1-names`, `-2-stub-stats`, `-3-categories`) order the three against each other for the same reason: `-2-` fills the stubs and `-3-` categorises whatever is still uncategorised, which is only the right set once `-2-` has run |
| Sorts after the `zzz-` files | `zzzz-*.sql` | The same escalation a THIRD time, and the one with a measurement behind it. The three citation files — `zzzz-cite-bom-invocations.sql`, `zzzz-cite-pf-rows.sql`, `zzzz-cite-rue-rows.sql` — give catalog rows the page they are printed on, and every row they touch has to exist and be named correctly first. Written as `fix-*.sql` they sorted in the MIDDLE: **`restore-skills-missing-from-repo.sql` and its gear and psionics twins CREATE rows the citation scripts then failed to find**, `rename-skills-to-rue.sql` renames rows they match by name, and `zzz-gear-tidy-2-stub-stats.sql` rewrites the very column they set. Applied to production by hand they ran last and were right; **a database rebuilt from `schema.sql` plus every data script in filename order lost 148 citations** — 26 rows carrying a bare book title in production against 172 in the rebuild. Measured before the rename, not reasoned. Their `data_script_runs` rows were moved with them: each script deletes the record written under its old name, which never existed in `main`, on the `fix-seed-dev-run-record.sql` precedent that only a record asserting something untrue is removed |
| Sorts after the `zzzz-` files | `zzzzz-*.sql` | The same escalation a FOURTH time, and the tier is now what it looks like: a counter, not a category. `zzzzz-fix-ju-gambling-notes.sql` corrects a `skills.note` that `add-juicer-uprising-skills.sql` writes and `zzzz-restore-skill-notes-and-citations.sql` then writes again from the live rows — so a correction has to sort after **both**, and only a fifth `z` does it. Nothing about the content needs a new tier; the restore files are simply the last thing in the order, and anything correcting what they assert lands here |
| Sorts after the `zzzzz-` files | `zzzzzz-*.sql` | A FIFTH `z`, and the row above already called the tier a counter rather than a category. `zzzzzz-ingestion-f28-law-canonical.sql` gives the `Law` skill RUE's base and citation and retires the duplicate `Law (General)` (`INGESTION-AUDIT` F28). It has to sort after `add-rifts-skill-list-gaps.sql`, which creates the row it corrects, after `add-rue-skills-batch.sql`, which creates the row it retires, and after `restore-skills-missing-from-repo.sql`, which re-creates skills from the live rows - and a fifth `z` is already taken by the retro files, so the sixth is what puts it last. **The count of z's carries no meaning beyond ordering**: read it as 'later than everything above', never as a severity |
| Sorts after the `zzzzzz-` files | `zzzzzzz-*.sql` | A SIXTH `z`, and the rows above already call the tier a counter rather than a category - read it as *later than everything above*, never as severity. `zzzzzzz-bom-sonic-blast-link.sql` links a Book of Magic spell to the row the same book publishes it as a second time (`BOOK-INGEST-AUDIT` F29). It needs this tier for a specific reason: `zzzzzz-underseas-same-spell-links.sql` asserts that **six rows in the whole catalog** carry a `same_spell_as` link, which is the right assertion for that file and which a seventh link breaks if it is written first. Six z's sorts `bom` BEFORE `underseas` alphabetically, so a clean rebuild would run the new file first and fail the older one's readback. Found with the sorted-glob check rather than reasoned from the prefix |
| Sorts after the `zzzzzzz-` files | `zzzzzzzz-*.sql` | A SEVENTH `z`, and the same counter as every row above - *later than everything above*, never a severity. `zzzzzzzz-rue-vessels-p266-267.sql` imports the Rifts Ultimate Edition vessels (`BOOK-INGEST-AUDIT` F41). It needs this tier because `zzzzzzz-ju-vessels-p077-088.sql` asserts a **global** count of `gear.vehicle_slug` pointers - 7, the ones it sets - and any later book session landing first falsifies that readback on a clean rebuild. **THE CONSTRAINT IS NARROWER THAN THIS ROW FIRST SAID**, and the correction is worth more than the rule: the ONLY global readback among the vessel scripts is the `ju` one, so the whole requirement is *sort after `ju`* and nothing more. The Wormwood and RUE scripts' own readbacks are all book-scoped, so nothing has to sort after either of them - `zzzzzzzz-pw-vessels-p128-130.sql` shares this tier with `rue` and lands ahead of it alphabetically, which is fine. This row previously said `rue` sorts before `ju` and `ww` both (it sorts after `ju`) and closed by declaring the book sessions ordered by z-count from here on; that overstated it, and a reader following it would spend a ninth `z` to buy nothing. Corrected 2026-09-09 |
| Sorts after the `zzzzzzzz-` files | `zzzzzzzzz-*.sql` | An EIGHTH `z`, and the first tier created by a readback rather than by a rebuild order. `zzzzzzzzz-f43-rue-misattributed.sql` and `zzzzzzzzz-f42-rue-editions.sql` (`BOOK-INGEST-AUDIT` F42 and F43) change gear rows that `zzzzzzzz-rue-vessels-p266-267.sql` **asserts the state of** - it checks that four rows still carry their first-edition figures and that two disputed rows still exist. F42 rewrites those four figures and F43 deletes one of those two, so both must sort after it, and after `zzzzzzzz-web-glitter-boy-p071-072.sql` which already held the end of the eighth tier. **The lesson is the one the row above states: read the earlier scripts' readbacks before naming a new file.** A script that CHANGES what an older script asserts needs a later tier, even when nothing about a rebuild requires it |
| Sorts after the `zzzzzzzzz-` files | `zzzzzzzzzz-*.sql` | A NINTH `z`, and the row it was added for needs far less than that. `zzzzzzzzzz-f26b-skill-page-citations.sql` gives three skill rows the page they are printed on (`INGESTION-AUDIT` F26(b)). Its real constraint is only that it follow `zzzz-restore-skill-notes-and-citations.sql`, which rewrites `skills.note` and `source_book` from the live rows, and `zzzzzz-ingestion-f28-law-canonical.sql`, which is the last earlier file to touch `skills` citations - so a SEVENTH `z` would have ordered it correctly. It takes the tenth because the ninth tier is occupied and **the count of z's is a counter, not a category**, exactly as the four rows above say: read it as *later than everything above* and never as severity or as a claim about how much had to sort before it. Guarded on the old citation, so a re-run is a no-op |
| Sorts after the `zzzzzzzzzz-` files | `zzzzzzzzzzz-*.sql` | A TENTH `z`, and the first tier created because a `fix-` file SORTED BEFORE THE FILE IT CORRECTS. `zzzzzzzzzzz-fix-nature-glimpse-name-on-a-rebuild.sql` re-runs the rename in `fix-nature-glimpse-of-the-future-name.sql`, which sorts at 436 against 619 for `zzzzzzzzzz-mr-nature-spells.sql` - the file that creates the row - so on a clean rebuild the correction matched nothing and the spell kept its subtitle for a name. Production was right only because the two were applied by hand in the order they were written, which is the `fix-long-bowman-armor.sql` shape exactly. **The original file is not renamed and not edited**: `scripts/drift-check.mjs` reports `RUN BUT NO FILE` for a `data_script_runs` name with no file on disk, and production recorded the old name. Proved both directions with `scripts/rebuild-local.mjs` on 2026-09-13 - without the new file a rebuild produces `Nature: A Wood & Water Divination`, with it `Nature: Glimpse of the Future`. **The count of z's is a counter, not a category**, exactly as the five rows above say. Two more landed in this tier on 2026-09-14: `zzzzzzzzzzz-hu-skill-bases-completion.sql`, which finishes `skill_system_bases` for Heroes Unlimited and is named to sort LAST so its assertions read the finished table, and `zzzzzzzzzzz-hu-secondary-skills-key.sql`, which renames `occ_secondary_skills` to the key the app reads in sixteen classes |
| Sorts after the `zzzzzzzzzzz-` files | `zzzzzzzzzzzz-*.sql` | An ELEVENTH `z`, added 2026-09-14 for `zzzzzzzzzzzz-f89-restore-clobbered-gear-citations.sql` — and the first tier whose reason is the defect it repairs. `BOOK-INGEST-AUDIT` F89: three gear citations exist in the repo and a rebuild does not keep them, because **`zzzz-restore-gear-values.sql` sets `source_book` on two of the rows unconditionally and `zzzz-r…` sorts after `zzzz-c…`** — so the `zzzz-cite-*` tier, which exists for exactly this job and which the finding proposed using, is itself clobbered by a file beside it. A corrective file that sorts merely after the *known* clobberers would be correct only until the next one lands, which is how this whole column of rows came to exist; this one sorts after **every** data script in the tree instead. The count of z's is a counter and not a category, as the five rows above say. The same finding's other half needed no new tier: the Meditation Chip is a stub two class imports race to `INSERT OR IGNORE`, and nothing rewrites it afterwards. |
| Sorts after the `zzzzzzzzzzzz-` files | `zzzzzzzzzzzzz-*.sql` | A TWELFTH `z`, added 2026-09-15 for `zzzzzzzzzzzzz-f95-gear-repo-vs-live-residue.sql` (`BOOK-INGEST-AUDIT` F95). It has to follow **every** data script for two independent reasons at once, which is why neither half could take a smaller tier. Its first half corrects what `zzz-gear-tidy-3-categories.sql`'s unconditional `UPDATE gear SET category = 'gear' WHERE category IS NULL` left behind in PRODUCTION only — that script ran 2026-08-25 and four later scripts created rows it would have swept, so a rebuild has always been ahead of production here. Its second half re-applies an append that `add-spirit-west-weapons-of-note.sql` makes to a row `add-triax-gear-c-ammunition.sql` creates: **`add-s` sorts before `add-t`**, so on a rebuild the guarded `UPDATE` matches nothing and the citation is lost, exactly the way F89's was. Every statement in the file is guarded on the value it changes, so production moves where it is behind and a rebuild moves where it is behind, and neither does the other's work. The count of z's is a counter and not a category, as the six rows above say. |
| Sorts after the `zzzzzzzzzzzzz-` files | `zzzzzzzzzzzzzz-*.sql` | A THIRTEENTH `z`, added 2026-09-17 for `zzzzzzzzzzzzzz-hand-to-hand-prices.sql`, which writes `skills.hand_to_hand` - what the class charges to change or buy a Hand to Hand style - into the 199 published classes that print a price (`js/hand-to-hand.js`). It edits class MARKDOWN with a guarded `replace()` anchored on `occ_skills:`, so it has to sort after every `add-*-class.sql` that creates a row it edits and after every `fix-`/`zz*-` file that rewrites one - which is every tier above, and the reason it takes the end rather than a slot. Thirteen z's with an `h` would have sorted BEFORE the `zzzzzzzzzzzzz-nb-*` Nightbane files; found with the sorted-glob check, not reasoned from the prefix. Proved on a `rebuild-local.mjs` build: 732 files, no failure, all eleven of its read-backs true, and all 337 published classes still parse. **A class imported after it carries its own block** - `class-import` -> `reference/frontmatter.md` says how, and `test/regression.mjs` fails a class whose Hand to Hand note prints a price with no block beside it. The count of z's is a counter and not a category, as the seven rows above say. |
| Sorts after the `zzzzzzzzzzzzzz-` files | `zzzzzzzzzzzzzzz-*.sql` | A FOURTEENTH `z`, added 2026-09-18 for `zzzzzzzzzzzzzzz-rename-perun-celestial-fire-bolt.sql`, which renames a spell the text layer misread (`Rerun's` for the `Perun's` printed 116) and leaves a `catalog_redirects` row behind. It must follow `zzzzzzzzzzzzzz-fix-spell-psionic-ocr-text.sql` (#1154), which repairs that row's text and damage UNDER ITS OLD NAME - renamed first, that script's guarded UPDATEs match nothing on a rebuild. A rename has to run after every script that keys the row by its old name, which is why a rename takes the end. Found with the sorted-glob check. |
| Sorts after the `zzzzzzzzzzzzzzz-` files | `zzzzzzzzzzzzzzzz-*.sql` | A FIFTEENTH `z`, added 2026-09-18 for `zzzzzzzzzzzzzzzz-tag-skill-systems.sql`, which tags 311 skills with the games whose books print them and leaves 79 NULL: the 54 all four print, and the 25-row language and literacy family. It has to sort after three kinds of file. Two files, `untag-cross-system.sql` and `fix-pf-armor-and-cross-system-gear.sql`, end in an unguarded `UPDATE skills SET systems = NULL` that clears every tag set before them on a rebuild (the psionic retag one row up describes the same trap). Every file that inserts a skill, because a row created after it lands untagged. And every skill rename, because it keys on the CURRENT name. `test/regression.mjs` pins the 79, so **a skill imported after it must carry its own `systems`**. The class importer's stubs do that by themselves. |
| Sorts after the `zzzzzzzzzzzzzzzz-` files | `zzzzzzzzzzzzzzzzz-*.sql` | A SIXTEENTH escalation - seventeen `z`s in the prefix - added 2026-09-20 for `zzzzzzzzzzzzzzzzz-f103-wp-targeting-provenance.sql` (`BOOK-INGEST-AUDIT` F103), which recites `W.P. Targeting` to the book its stored text actually came from and gives Palladium Fantasy the schedule that book prints. **Its real constraint is only that it follow the two files that write that citation** — `zzzz-cite-pf-rows.sql` and `zzzz-restore-skill-notes-and-citations.sql` — so a FIFTH `z` would have ordered it correctly. It takes a seventeenth `z` because the sixteen-`z` tier is occupied, which is the counter this table's rows keep saying it is: read it as *later than everything above*, never as severity or as a claim about how much had to sort before it. **It is NOT guarded on the old citation**, and that is the interesting part: production holds `Palladium Fantasy RPG Main Book p.84` while a database built from this repo holds `Rifts Ultimate Edition` with no page — the `REBUILD-AUDIT` F14 disagreement — so a guard on either value is a silent no-op in the other environment. `d1-apply`'s scratch replay caught exactly that before anything was applied. Guarding on the name converges the two |
| Sorts after **every** `z-` tier above | `~NNN-*.sql` | **The counter stops at seventeen `z`s, and this is where it goes instead.** `~` is U+007E and `z` is U+007A, so one `~` sorts after any number of z's — and `NNN` is a numeric counter with room left, which is what the z's were standing in for all along. There are **no files in this tier yet**: it is the slot the eighteenth `z` would have taken, documented before it is needed rather than after. `test/checks/environment.mjs` → *Data script conventions* enforces both halves — it fails a data script carrying an eighteenth `z` and names this row, and it pins the sort property itself so this paragraph cannot quietly stop being true. **Why `~` is safe and a locale cannot break it:** all four things that order these files use JavaScript's own `.sort()`, which is UTF-16 code-unit order and reads no locale — `scripts/rebuild-local.mjs`, `scripts/repo-vs-live.mjs`, `scripts/d1-apply.mjs` (which re-globs a directory itself rather than trusting the shell) and `test/regression.mjs` step `[1/7]`. A shell glob *would* be locale-sensitive; nothing here depends on one. The rows above still read as a counter and not a category, and so does this one: `~001-` means *later than everything above*, never severity |

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

**A RETIRED SLUG IS ABSENT FROM THE TABLE AND STILL TAKEN,** found the same way
on 2026-09-14 and the second entry in this section found by looking. An import
of Heroes Unlimited's containers list gave its Back Pack the slug `back-pack`.
The generator that wrote it picked slugs by reading **the slugs production
holds**, and production held none — `merge-backpack-duplicate.sql` had retired
that spelling into `backpack` long before, deleting the row and leaving a
`catalog_redirects` row behind. So the slug looked free, and was not. Two
results, and the second is the one that hid: in production the new row went in
and `back-pack` became **a live gear slug that is simultaneously a redirect
`from_key`** — the trap `merge-backpack-duplicate.sql`'s own header warns about
— while on a clean rebuild `add-` sorts before `merge-`, so the row was created
and then deleted again, every time. **A rebuilt database held 2009 gear rows
against production's 2010**, and the only thing that said so was the clean-run
count in the table above, which reports a total and never names a row. The row
was found by dumping both slug lists and diffing them.
`fix-hu-back-pack-slug.sql` moves it to `back-pack-hu`; the import now emits
that directly, so the fix is a no-op on a fresh build. **A collision check that
reads only the catalog table cannot see a retired key — read
`catalog_redirects` too.**

**One more thing about `--file` over `--remote`,** learned applying that script:
its `changes` and `rows_written` are **import-endpoint aggregates, not row
counts**. This one reported `changes: 2` against production while changing
nothing at all — verified by dumping `imported_classes` before and after, 126
rows, zero field differences, `updated_at` unmoved. The section below already
says `--file` returns a summary rather than results and that exit codes here are
advisory; the counts inside that summary are advisory too. Dump the table and
diff it.

Four conventions hold across all of them, with one stated exception: the
dev seed is a different kind of file and follows only the run-recording one.
Its inserts are unguarded and re-applying it fails on `gear.slug`, which is the
right behaviour for a file whose whole job is to put known rows into an empty
local database.

- **Never key a catalog write on a literal `id`.** Match on `name` for skills,
  spells and psionic powers, and on `slug` for gear; all four columns are
  `UNIQUE`, so it costs nothing. Catalog ids are
  `INTEGER PRIMARY KEY AUTOINCREMENT` — **insertion order**, and insertion
  order is not the same in two databases. Measured against a rebuild on
  2026-09-05: **0 of 1025 gear ids matched production**, along with 344 of 345
  skills, 551 of 607 spells and 96 of 116 psionic powers. So `WHERE id = 283`
  is `Fire: Fire Gout` in production and `Earth: Track` in a rebuilt database,
  and a script written that way writes the right data onto the wrong rows
  **with no error at all**. It happened while writing the Book of Magic
  backfill, and the readback caught it only because it counted the whole
  corpus rather than the rows the script had touched — which is the argument
  for writing readbacks that way.
  **A JOIN on an id is fine**: a join between two id columns is a
  relation inside one database and says nothing about which. Eight scripts do
  it and all eight are correct. `test/smoke.mjs` refuses only a literal number.
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

Merging to `main` is the deploy — Pages auto-deploys, no build command, and
nothing gates the merge. The five smoke suites run on every pull request
(`.github/workflows/tests.yml`, `REPO-AUDIT.md` G8) and report only: they are
not a required status check and cannot block a deploy.
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
