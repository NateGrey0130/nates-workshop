-- The S.D.C. that was trapped in prose, moved into the column that holds it.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Migration 034 adds `gear.sdc`; this fills it.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-gear-sdc-backfill.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-gear-sdc-backfill.sql
--
-- SIX ARMOUR ROWS, every one checked against the Types of Armor table on
-- Palladium Fantasy printed 270:
--
--   soft-leather      A.R. 10   S.D.C. 20      hard-leather      A.R. 11   S.D.C. 30
--   studded-leather   A.R. 13   S.D.C. 38      chain-mail        A.R. 14   S.D.C. 44
--   scale-mail        A.R. 15   S.D.C. 75
--
-- The small shield is not in that table; printed 60 has it under W.P. Shield:
-- "The average small wood & leather shield has 30 S.D.C. and costs 35 gold",
-- which is the row's stored cost as well.
--
-- SEVEN MORE THAT ARE NOT ARMOUR. Anything solid enough to be broken has an
-- S.D.C., and these already stated one in their own descriptions.
--
-- AND THE TWO THIS DELIBERATELY DOES NOT TOUCH, because a regex over
-- descriptions would have got both wrong and put nonsense in a numeric column:
--
--   * "1D6 S.D.C." on a knife, hatchet, hand-axe or hammer is DAMAGE, not
--     durability. It belongs in `damage`, where it already is. Seven rows read
--     that way.
--   * wilk-s-portable-laser-torch-tool says it "can slice through a 600 S.D.C.
--     metal door". That is the DOOR. A laser torch with 600 S.D.C. would be the
--     toughest object in the catalog.
--
-- The description keeps its wording. This is not a migration of the text out of
-- prose, it is the number becoming reachable - the sheet's armour block can
-- subtract from a column and cannot subtract from a sentence.
--
-- ONE ROW ENDS UP WITH BOTH, on purpose. polarized-goggles reads "High impact
-- goggles have 1 M.D.C. Ordinary Polarized Goggles are 15 S.D.C." - two
-- products in one row, and both numbers are its own. The readback below is
-- scoped to ARMOUR for that reason: a SUIT has one scale or the other, and a
-- row that conflates two products is a different problem, recorded rather than
-- papered over.
--
-- Guarded on the column being empty, so re-running is a no-op and a value
-- somebody has since corrected by hand is left alone.
--
-- NAMED zz- ON PURPOSE, and it was named fix- first. On a database built from
-- nothing, studded-leather does not exist yet when a fix-g... script runs:
-- fix-pf-armor-and-cross-system-gear.sql creates it, and sorts later. The
-- regression suite caught it because it builds from nothing; a local database
-- that already had the row could not have. This is the trap that cost
-- fix-long-bowman-armor its whole effect, one file later.

-- Armour, printed 270.
UPDATE gear SET sdc = 20 WHERE slug = 'soft-leather'     AND sdc IS NULL;
UPDATE gear SET sdc = 30 WHERE slug = 'hard-leather'     AND sdc IS NULL;
UPDATE gear SET sdc = 38 WHERE slug = 'studded-leather'  AND sdc IS NULL;
UPDATE gear SET sdc = 44 WHERE slug = 'chain-mail'       AND sdc IS NULL;
UPDATE gear SET sdc = 75 WHERE slug = 'scale-mail'       AND sdc IS NULL;

-- The shield, printed 60.
UPDATE gear SET sdc = 30 WHERE slug = 'small-shield'     AND sdc IS NULL;

-- Equipment that states its own S.D.C. The two sunglasses rows agree at 8;
-- polarized goggles are 15 in their own text.
UPDATE gear SET sdc = 30 WHERE slug = 'walkie-talkie'                 AND sdc IS NULL;
UPDATE gear SET sdc = 30 WHERE slug = 'communicator-old-style-radio'  AND sdc IS NULL;
UPDATE gear SET sdc = 30 WHERE slug = 'communicators-medium'          AND sdc IS NULL;
UPDATE gear SET sdc = 10 WHERE slug = 'communicators-small'           AND sdc IS NULL;
UPDATE gear SET sdc = 15 WHERE slug = 'polarized-goggles'             AND sdc IS NULL;
UPDATE gear SET sdc =  8 WHERE slug = 'sunglasses'                    AND sdc IS NULL;
UPDATE gear SET sdc =  8 WHERE slug = 'sunglasses-or-tinted-visor'    AND sdc IS NULL;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS rows_with_an_sdc FROM gear WHERE sdc IS NOT NULL;
SELECT count(*) AS palladium_armour_still_empty FROM gear
 WHERE category = 'armor' AND system = 'palladium-fantasy' AND sdc IS NULL;
SELECT count(*) AS an_armour_row_with_both_scales FROM gear
 WHERE category = 'armor' AND mdc IS NOT NULL AND sdc IS NOT NULL;
SELECT count(*) AS non_armour_rows_with_both FROM gear
 WHERE (category IS NULL OR category <> 'armor') AND mdc IS NOT NULL AND sdc IS NOT NULL;
SELECT count(*) AS a_weapon_given_its_own_damage FROM gear
 WHERE sdc IS NOT NULL AND damage IS NOT NULL;
SELECT slug, ar, sdc FROM gear WHERE category = 'armor' AND sdc IS NOT NULL ORDER BY sdc;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-gear-sdc-backfill.sql');
