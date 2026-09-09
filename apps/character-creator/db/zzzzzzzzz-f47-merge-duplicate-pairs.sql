-- BOOK-INGEST-AUDIT.md F47: merge the duplicate pairs - and DON'T merge the two
-- that turned out not to be pairs.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzz-f47-merge-duplicate-pairs.sql
--
-- Five candidate pairs came out of F42, F43, F44 and F46. Reading the book split
-- them three to two, and the two that survive the split are the interesting half.
--
-- == THREE REAL MERGES ==
--
--   a-t-v-speedster-hover-cycle -> speedster-hovercycle
--   the-big-boss-a-t-v          -> big-boss-atv
--   the-mountaineer-a-t-v       -> mountaineer-atv
--
-- Same machine, same book, same printed page. The SHORT slug survives in each
-- case because its name is what RUE prints - `Speedster Hovercycle`,
-- `Big Boss ATV`, `Mountaineer ATV` - and because it already carries the
-- `p.261-270` citation and the `vehicle_slug` pointer. The retiring rows are the
-- `the-...` variants an earlier session created from the first edition.
--
-- **THE RETIRING ROWS CARRY WEIGHT THE SURVIVORS LACK**, and it moves first.
-- Each survivor has `weight_lbs` NULL while its twin holds the printed figure -
-- 700 lbs for the Speedster, 2000 (one ton) for the Big Boss, 12000 (six tons)
-- for the Mountaineer, all matching RUE. A merge that dropped them would lose
-- data to tidy a name, which is the opposite of the point.
--
-- **AND ONE OF THEM STILL HELD A FIRST-EDITION PRICE.** `the-mountaineer-a-t-v`
-- carries `cost = 64000`; RUE prints 76,000 and the surviving row has it. F42
-- moved the M.D.C. and the tire counts on these rows and did NOT move this,
-- because that finding's premise was that *"both prices matched RUE exactly"* -
-- true of the other rows and not of this one. The merge retires the wrong figure
-- rather than correcting it, which is the same outcome by a different route, and
-- it is recorded here because the premise stays wrong in F42's own text.
--
-- == TWO PAIRS THAT ARE NOT PAIRS, AND ARE CITED INSTEAD ==
--
-- **`hand-axe` and `hatchet` are BOTH printed in RUE.** They have identical
-- damage (1D6), weight (3) and cost (40), which is what made them look like one
-- row entered twice - and the book names them separately on separate pages:
-- printed 99 gives `survival knife and hand axe (both do 1D6 S.D.C. damage)` and
-- printed 56 gives `hatchet for cutting wood (1D6 S.D.C. damage)`. Two simple
-- chopping tools with the same numbers are not one item. **They stay, and
-- `hand-axe` is cited to printed 99** - which also takes the last web-marked row
-- carrying a combat number to ZERO, closing what F46 left open.
--
-- Merging them would have changed what **eleven** published classes hand a
-- player, on the strength of matching numbers alone.
--
-- **`W.P. Heavy M.D. Weapons` and `W.P. Heavy Military Weapons` are BOTH printed
-- in RUE, on the SAME page.** Printed 329 lists `W.P. Heavy Military Weapons`
-- (grenade launchers, mortars, machine-guns, mini-guns, S.D.C. and light M.D.
-- turrets) and `W.P. Heavy Mega-Damage Weapons` (plasma ejectors, M.D. rail
-- guns, rocket launchers, mini-missile launchers, robot and tank cannons). They
-- are different skills for different weapons. **F44's detector surfaced this pair
-- the day it shipped and it is a FALSE POSITIVE** - which is the detector working
-- as designed, since duplicate review is a report a person reads. The catalog's
-- `W.P. Heavy M.D. Weapons` is the book's `Heavy Mega-Damage` under an
-- abbreviation, and it is cited to printed 329 rather than merged away.
--
-- Merging them would have changed **twenty-seven** class references.
--
-- == HOW THE MERGES ARE DONE ==
--
-- The `zzzzzz-ingestion-f28-law-canonical.sql` pattern: carry data across, write
-- the redirect so the retired slug keeps resolving, then a guarded DELETE. No
-- `character_items` row references any of the three retiring slugs (checked
-- `--remote` 2026-09-09; the only inventory row among all these candidates is on
-- `hand-axe`, which is NOT being merged).
--
-- NINE Z'S AND `f47`. This file changes what four earlier scripts assert:
-- the RUE vessel script's pointer count of 8, F42's `each duplicate pair now
-- agrees` and `twelve RUE vehicle rows`, F43's `twelve RUE vehicle rows remain`,
-- and F46's `one web-marked row still carries a combat number`. `f47` sorts after
-- every one of them.
--
-- Pure ASCII with LF endings.

-- --- 1. carry the printed weights onto the survivors ---
UPDATE gear SET weight_lbs = 700
 WHERE slug = 'speedster-hovercycle' AND weight_lbs IS NULL;
UPDATE gear SET weight_lbs = 2000
 WHERE slug = 'big-boss-atv' AND weight_lbs IS NULL;
UPDATE gear SET weight_lbs = 12000
 WHERE slug = 'mountaineer-atv' AND weight_lbs IS NULL;

-- --- 2. redirects BEFORE deletes, so no slug stops resolving ---
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'a-t-v-speedster-hover-cycle', id, 'merge' FROM gear WHERE slug = 'speedster-hovercycle'
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = 'merge';

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'the-big-boss-a-t-v', id, 'merge' FROM gear WHERE slug = 'big-boss-atv'
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = 'merge';

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'the-mountaineer-a-t-v', id, 'merge' FROM gear WHERE slug = 'mountaineer-atv'
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = 'merge';

-- --- 3. retire, each guarded on the figures that identify the row ---
DELETE FROM gear WHERE slug = 'a-t-v-speedster-hover-cycle' AND mdc = 85  AND cost = 98000;
DELETE FROM gear WHERE slug = 'the-big-boss-a-t-v'          AND mdc = 100 AND cost = 24000;
DELETE FROM gear WHERE slug = 'the-mountaineer-a-t-v'       AND mdc = 210 AND cost = 64000;

-- --- 4. the two that are NOT duplicates: cite them ---
UPDATE gear
   SET source_book = 'Rifts Ultimate Edition p.99'
 WHERE slug = 'hand-axe'
   AND source_book = 'Web reference (not book-verified)';

UPDATE skills
   SET source_book = 'Rifts Ultimate Edition p.329'
 WHERE name = 'W.P. Heavy M.D. Weapons'
   AND source_book = 'Rifts Ultimate Edition';

-- --- readback ---

SELECT 'the three duplicates are gone' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug IN ('a-t-v-speedster-hover-cycle', 'the-big-boss-a-t-v', 'the-mountaineer-a-t-v');

SELECT 'and all three slugs still resolve' AS assertion, count(*) AS got, 3 AS want
  FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
 WHERE r.catalog = 'gear'
   AND ((r.from_key = 'a-t-v-speedster-hover-cycle' AND g.slug = 'speedster-hovercycle')
     OR (r.from_key = 'the-big-boss-a-t-v'          AND g.slug = 'big-boss-atv')
     OR (r.from_key = 'the-mountaineer-a-t-v'       AND g.slug = 'mountaineer-atv'));

-- The weights survived the merge rather than dying with the retired rows.
SELECT 'the survivors carry the printed weights' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE (slug = 'speedster-hovercycle' AND weight_lbs =   700)
    OR (slug = 'big-boss-atv'         AND weight_lbs =  2000)
    OR (slug = 'mountaineer-atv'      AND weight_lbs = 12000);

-- The first-edition price left behind by F42 went with the row that held it.
SELECT 'no first-edition Mountaineer price survives' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE cost = 64000 AND category = 'vehicle' AND source_book LIKE '%Ultimate%';

SELECT 'and the Mountaineer holds the RUE price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'mountaineer-atv' AND cost = 76000 AND mdc = 210;

-- NINE RUE vehicle rows now: twelve less the three retired.
SELECT 'nine RUE vehicle rows remain' AS assertion, count(*) AS got, 9 AS want
  FROM gear WHERE category = 'vehicle' AND source_book LIKE '%Ultimate%';

-- Every surviving pointer still resolves; three went with their rows. NINE
-- Ultimate-cited rows carried one, not eight: the RUE vessel session set eight
-- and the Glitter Boy added a ninth when #861 re-cited it into this book. The
-- first draft of this line said 5 and was caught on the first --local apply.
SELECT 'six RUE gear rows still point at a vessel' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE vehicle_slug IS NOT NULL AND source_book LIKE '%Ultimate%';

SELECT 'every pointer in the catalog resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
 WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

-- THE TWO NON-PAIRS BOTH SURVIVE, and both now name a page.
SELECT 'the hand axe and the hatchet both remain' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('hand-axe', 'hatchet');

SELECT 'and both cite a RUE page' AS assertion, count(*) AS got, 2 AS want
  FROM gear
 WHERE (slug = 'hand-axe' AND source_book = 'Rifts Ultimate Edition p.99')
    OR (slug = 'hatchet'  AND source_book = 'Rifts Ultimate Edition p.56');

SELECT 'both heavy-weapon W.P.s remain' AS assertion, count(*) AS got, 2 AS want
  FROM skills WHERE name IN ('W.P. Heavy M.D. Weapons', 'W.P. Heavy Military Weapons');

SELECT 'and the Mega-Damage one now cites its page' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'W.P. Heavy M.D. Weapons' AND source_book = 'Rifts Ultimate Edition p.329';

-- F46's last open row is closed: NOTHING web-marked carries a combat number now.
SELECT 'no web-marked row carries a combat number' AS assertion, count(*) AS got, 0 AS want
  FROM gear
 WHERE source_book = 'Web reference (not book-verified)'
   AND (mdc IS NOT NULL OR damage IS NOT NULL OR ar IS NOT NULL);

SELECT 'the marker survives on the rest' AS assertion, count(*) AS got, 23 AS want
  FROM gear WHERE source_book = 'Web reference (not book-verified)';

-- NO INVENTORY ROW WAS ORPHANED. Production holds one character_items row among
-- all these candidates, on `hand-axe`, which is not being merged - but asserting
-- THAT would assert user data, and a fresh local database has no such row. The
-- first draft did exactly that and failed on --local while being true on
-- production. The invariant below holds in every environment and is the thing
-- that actually matters.
SELECT 'no inventory row points at a deleted gear row' AS assertion, count(*) AS got, 0 AS want
  FROM character_items ci LEFT JOIN gear g ON g.slug = ci.gear_slug
 WHERE ci.gear_slug IS NOT NULL AND g.slug IS NULL;

SELECT count(*) AS gear_rows FROM gear;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f47-merge-duplicate-pairs.sql');
