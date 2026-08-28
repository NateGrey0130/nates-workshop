-- The 60 gear values a rebuild loses, and the four it must NOT overwrite
-- (REBUILD-AUDIT.md F18, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-gear-values.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-gear-values.sql
--
-- A DIFFERENT POPULATION FROM F5's. Not one of these 33 rows is created by
-- restore-gear-missing-from-repo.sql; F5 closed all 193 of those. These are
-- ordinary catalog rows enriched through the editor - F6's gap, gear's share.
--
-- ONE ROW HERE IS SOURCED FROM WEB REFERENCES, NOT THE BOOK, and this header
-- says so because the row alone is not enough - the provenance has to be
-- visible in the repo as well as in the column. `tinted-goggles` takes
-- source_book = 'Web reference (not book-verified)' along with its price,
-- weight and description, exactly as production holds them. That marker is
-- load-bearing: it is how a reader tells a checked row from an unchecked one,
-- and how a later book correction knows what it is overwriting. Nothing else
-- in this file carries it, and the two rows that USED to - the Dead Boy suits
-- - are moved off it and onto RUE p.261-265 above.
--
-- F18 SAID "READ THE EIGHT NON-NULL CASES FIRST". THERE ARE TWENTY-FOUR.
-- The finding counted only `category`, `system`, `source_book` and
-- `weight_lbs` and missed that `description` and `cost` disagree too. All 24
-- were read. Twenty are exported and four are not.
--
-- THE FOUR THAT ARE NOT, AND WHY - this is the load-bearing part.
--
--   hand-held-blood-pressure-machine, unbreakable-vial, medical-bag, poncho
--   have `category` NULL in production and 'gear' in a rebuild. THE REBUILD IS
--   RIGHT. fix-body-fixer-page-break.sql inserts these four with no category,
--   and zzz-gear-tidy-3-categories.sql ends with an unconditional
--   `UPDATE gear SET category = 'gear' WHERE category IS NULL`. In a rebuild
--   the insert sorts under `f` and the tidy under `zzz`, so the tidy catches
--   them. On production the two were applied by hand THREE HOURS APART in the
--   other order:
--
--     zzz-gear-tidy-3-categories.sql   first run 2026-08-25 16:12:11
--     fix-body-fixer-page-break.sql    first run 2026-08-25 19:12:19
--
--   So production has four uncategorised rows and a rebuild has none.
--   Exporting production's NULL would delete a category a rebuild correctly
--   has. This is the same hand-application hazard as F15 and F19, in a third
--   table; correcting PRODUCTION for it belongs with F19, not here.
--
-- THE TWENTY THAT ARE EXPORTED, each checked rather than assumed:
--
--   cost, both non-null (8). Production stores the LOW END of a published
--   range in `cost` and the full range in `cost_note`; a rebuild carries only
--   the top of that range, with no note. In all eight the repo's figure is
--   exactly production's upper bound. The Dead Boy suits settle it from the
--   book: RUE printed 261 prints "Black Market Price: 35,000 to 45,000 with a
--   custom paint job" under "Features Common to All 'Dead Boy' Armor", so
--   35,000 is the shared floor for BOTH suits - which is what production
--   holds, against a rebuild's 40,000 and 70,000 taken from a web reference.
--
--   description, both non-null (11). A rebuild holds
--   "STUB - split out of a choice or bundle row"; production holds real prose.
--   Strictly better in every case.
--
--   source_book (2). ca-1- and ca-2-dead-boy-armor cite
--   "Web reference (not book-verified)" in a rebuild and RUE p.261-265 live.
--   Verified: printed 261 opens "There are two types of Dead Boy armor, light
--   and heavy."
--
--   system (2). first-aid-kit and bandages are 'rifts' in a rebuild because
--   the CLASS importer's stub creation sets system from the class being
--   imported, and 'both' live because someone made a per-item call in the
--   editor. A first aid kit is not a laser rifle; backfill-gear-system.sql
--   says outright that precision here is the point.
--
-- The remaining 36 are plain: production holds a value, a rebuild holds NULL.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after zzz-gear-tidy-2-stub-stats
-- and zzz-gear-tidy-3-categories, which rewrite these very columns, and after
-- zzzz-restore-gear-full-columns.sql, which is F5's and touches gear too.
-- `zzzz-restore-gear-v` sorts after `zzzz-restore-gear-f`.
--
-- Every statement targets one slug and sets absolute values, so it is safe to
-- re-run: on production every value below is already the value in the row.

UPDATE gear SET
      cost_note = '110-160 cr.'
  WHERE slug = 'sleeping-bag';

UPDATE gear SET
      system = 'both'
  WHERE slug = 'first-aid-kit';

UPDATE gear SET
      weight_lbs = 0.13,
      cost = 75,
      description = 'Polarized goggles that lighten and darken with the ambient light, against glare and sudden brightness. Typically 75 to 100 credits; a high-impact version runs about 1,200.',
      source_book = 'Web reference (not book-verified)'
  WHERE slug = 'tinted-goggles';

UPDATE gear SET
      cost = 30,
      description = 'A plain robe.',
      source_book = 'Estimate - no published price found'
  WHERE slug = 'robe';

UPDATE gear SET
      cost = 30,
      description = 'A shoulder cape.',
      source_book = 'Estimate - no published price found'
  WHERE slug = 'cape';

UPDATE gear SET
      cost = 1,
      description = 'A marker pen. A dozen runs 6 to 8 credits.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'pen';

UPDATE gear SET
      cost = 2,
      description = 'A mechanical pencil, 2 to 5 credits. A 24-pack of lead runs 10 credits.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'pencil';

UPDATE gear SET
      cost = 4,
      description = 'Priced as the soft-cover sketch book, 100 sheets - the book lists no separate note pad.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'note-pad';

UPDATE gear SET
      cost = 4,
      description = 'A soft-cover sketch book of 100 sheets. A hardcover runs 8 to 12 credits.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'sketch-pad';

UPDATE gear SET
      cost = 5,
      description = 'A striking flint.',
      source_book = 'Estimate - no published price found'
  WHERE slug = 'flint';

UPDATE gear SET
      cost = 3,
      description = 'Charcoal, for drawing or for a fire.',
      source_book = 'Estimate - no published price found'
  WHERE slug = 'charcoal';

UPDATE gear SET
      cost = 50,
      description = 'Camouflage-pattern military fatigues.',
      source_book = 'Estimate - no published price found'
  WHERE slug = 'camouflage-fatigues';

UPDATE gear SET
      cost = 35000,
      description = 'Coalition CA-2 Light "Dead Boy" body armor, old style, worn by pilots, city police and for espionage work. M.D.C. by location: main body 50, helmet 35, arms 15 each, legs 24 each. No mobility penalty; -5% on Acrobatics, Climbing, Prowl, Swimming and similar. Full environmental armor, with the same life support and shielding as the heavy suit.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'ca-2-light-dead-boy-armor';

UPDATE gear SET
      cost = 35000,
      description = 'Coalition CA-1 Heavy "Dead Boy" body armor, old style, worn by the infantry. M.D.C. by location: main body 80, helmet 50, arms 35 each, legs 50 each. -10% on Acrobatics, Climbing, Prowl, Swimming and other high-mobility skills. Full environmental armor: life support, internal cooling, gas filtration, a five hour oxygen supply, radiation shielding, heat resistance to 300 degrees centigrade, and a helmet radio good for 5 miles.',
      source_book = 'Rifts Ultimate Edition p.261-265'
  WHERE slug = 'ca-1-heavy-dead-boy-armor';

UPDATE gear SET
      cost = 2,
      cost_note = '2-5 cr.'
  WHERE slug = 'mechanical-pencil';

UPDATE gear SET
      system = 'both'
  WHERE slug = 'bandages-6-foot-1-8-m-roll';

UPDATE gear SET
      cost_note = '60-100 cr.'
  WHERE slug = 'bicycle-basic';

UPDATE gear SET
      cost_note = '2-6 cr.'
  WHERE slug = 'cigarettes-16-in-a-pack';

UPDATE gear SET
      cost_note = '25-80 cr.'
  WHERE slug = 'duffle-bag';

UPDATE gear SET
      cost_note = '80-200 cr.'
  WHERE slug = 'knife-skinning';

UPDATE gear SET
      cost_note = '200-600 cr.'
  WHERE slug = 'knife-throwing';

UPDATE gear SET
      cost_note = '2-5 cr.'
  WHERE slug = 'pocket-or-signal-mirror';

UPDATE gear SET
      cost = 100,
      cost_note = '100-200 cr.'
  WHERE slug = 'backpack-large';

UPDATE gear SET
      cost = 12,
      cost_note = '12-20 cr.'
  WHERE slug = 'flashlight-large';

UPDATE gear SET
      cost = 50,
      cost_note = '50-80 cr. (half that used)'
  WHERE slug = 'gas-mask-human-size';

UPDATE gear SET
      cost = 80,
      cost_note = '80-120 cr.'
  WHERE slug = 'gas-mask-oversized';

UPDATE gear SET
      cost = 100,
      cost_note = '100-300 cr.'
  WHERE slug = 'sunglasses-light-adjusting';

UPDATE gear SET
      cost_note = '20-100 cr.'
  WHERE slug = 'knife-large';

UPDATE gear SET
      cost_note = '15-75 cr.'
  WHERE slug = 'knife-small';

-- Reads the result back rather than trusting the exit code.
--   gear_with_no_cost         105 = production's own figure. A rebuild had 115
--                             after F5, and these 10 priced rows are the rest.
--   dead_boy_floor_price       2 = both Dead Boy suits now carry the book's
--                             shared 35,000 floor, not a web reference's
--                             40,000 and 70,000.
--   uncategorised_gear         4 = UNCHANGED AND DELIBERATE. This is
--                             production's number; a rebuild reads 0 and is
--                             right. If this ever reads 0 on production, F19
--                             has been taken. If a REBUILD ever reads 4,
--                             something here exported `category` and undid
--                             zzz-gear-tidy-3-categories.sql.
SELECT (SELECT count(*) FROM gear WHERE cost IS NULL) AS gear_with_no_cost,
       (SELECT count(*) FROM gear WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
          AND cost = 35000) AS dead_boy_floor_price,
       (SELECT count(*) FROM gear WHERE category IS NULL) AS uncategorised_gear;

-- Records this run. One row per run rather than per file: the statements above
-- set absolute values, so this script is safe to re-run, and a run that
-- correctly changed nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-gear-values.sql');
