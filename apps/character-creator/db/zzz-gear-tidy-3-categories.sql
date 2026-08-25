-- The remaining gear rows with no category.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzz-gear-tidy-3-categories.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzz-gear-tidy-3-categories.sql
--
-- 184 of 893 gear rows had a null category. 85 were import stubs and are
-- handled by zzz-gear-tidy-2-stub-stats.sql; these are the other 99, which
-- have had prices all along and still rendered thin because the detail line
-- starts with the category.
--
-- The assignments follow what the 709 rows that ALREADY have a category do,
-- rather than a fresh opinion:
--
--   boots, robes, cloaks, helmets and clothing are gear - Boots (Leather),
--     Robe (Hooded) and Communications Helmet all are
--   grenades are weapons - Deadball Grenade already is
--   power armour is a VEHICLE, not armour - NG-JK1A/B "Juicer Killer" Power
--     Armor is filed there, and so is Wilk's Jet Pack
--   ammunition is gear - there is no ammunition category and Grenade Bracers
--     are gear
--   iron spikes and wooden stakes are gear - Rifts Ultimate Edition sells them
--     under Basic Gear, not as weapons
--
-- The riding horse is the one judgement call: it goes under vehicle, with the
-- ATVs and the hover cycles, because that is where a player looks for how the
-- character gets about.
--
-- Guarded on the category still being null.


UPDATE gear SET category = 'weapon' WHERE category IS NULL AND slug IN ('c-18-laser-pistol','hand-axe','hatchet','knife','survival-knife','smoke-grenade');

UPDATE gear SET category = 'vehicle' WHERE category IS NULL AND slug IN ('glitter-boy-power-armor','riding-horse');

UPDATE gear SET category = 'armor' WHERE category IS NULL AND slug IN ('dead-boy-body-armor','dog-pack-dpm-riot-armor');

-- Everything still uncategorised is gear.
UPDATE gear SET category = 'gear' WHERE category IS NULL;

-- Readback.
SELECT count(*) AS rows_without_a_category FROM gear WHERE category IS NULL;
SELECT category, count(*) AS n FROM gear GROUP BY category ORDER BY n DESC;


-- Records this run. REQUIRED: the smoke test fails a data script
-- that has no footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zzz-gear-tidy-3-categories.sql');
