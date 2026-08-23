-- Fifty-seven spells the Palladium Fantasy main book prints, that a Palladium
-- mage could not see.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/retag-pf-spells-both.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/retag-pf-spells-both.sql
--
-- inSystem() in app.js offers a catalog row when its system is NULL, 'both', or
-- the build's own, and every spell imported from a Rifts book is tagged
-- 'rifts'. The Palladium Fantasy main book prints 182 wizard spells; 155 of
-- them are in the catalog, and 57 of those 155 were invisible to a Palladium
-- character. A Palladium Wizard could reach 98 of the 182 its own book lists.
--
-- The damage is worst exactly where a caster earns it. Every spell from level
-- ten up is on this list bar one, so a Palladium Wizard who reached tenth level
-- was offered almost nothing new - Mystic Portal, Summon Shadow Beast,
-- Anti-Magic Cloud, Create Golem, Resurrection, Dimensional Portal and the four
-- Spells of Legend were all filed as Rifts-only.
--
-- THIS IS THE SAME DEFECT fix-pf-armor-and-cross-system-gear.sql fixed for
-- gear, where the Knight held clothing, gloves and a riding horse its own sheet
-- could not resolve. The trigger there was "a class in the OTHER system grants
-- the row outright", and the trigger here is stronger: the other system's core
-- book prints the spell in its own wizard spell list, by name, with a level and
-- a cost that the catalog already agrees with.
--
-- 'both' RATHER THAN NULL, and rather than moving them to 'palladium-fantasy'.
-- These spells are in both books, so both is the true statement; NULL would say
-- "unrestricted", which is the honest answer only when the operator does not
-- know. Nothing is taken away from anyone: 'both' is a superset of 'rifts', so
-- every Rifts character still sees every one of these.
--
-- NO OTHER COLUMN CHANGES. Level and cost stay exactly as the Rifts books set
-- them - the later book still wins - and the fourteen rows where Palladium
-- prints a different figure already carry it in variant_note from
-- add-palladium-variants.sql.
--
-- GUARDED on the stored value still being 'rifts', so this is safe to run twice
-- and stops rather than overwriting a row somebody has since changed.

UPDATE spells SET system = 'both'
 WHERE system = 'rifts'
   AND name IN (
   'Amulet',
   'Anti-Magic Cloud',
   'Apparition',
   'Astral Projection',
   'Barrier of Thoth',
   'Calm Storms',
   'Close Rift',
   'Create Golem',
   'Create Magic Scroll',
   'Create Mummy',
   'Create Zombie',
   'Crimson Wall of Lictalon',
   'Curse: Phobia',
   'Dimensional Portal',
   'Dimensional Teleport',
   'Doppleganger (Superior)',
   'Hallucination',
   'Havoc',
   'Horrific Illusion',
   'Id Barrier',
   'Impenetrable Wall of Force',
   'Invulnerability',
   'Memory Bank',
   'Metamorphosis: Insect',
   'Metamorphosis: Mist',
   'Metamorphosis: Superior',
   'Minor Curse',
   'Mystic Alarm',
   'Mystic Portal',
   'Oracle',
   'Protection Circle: Superior',
   'Remove Curse',
   'Restoration',
   'Resurrection',
   'Sanctuary',
   'Sanctum',
   'Seal',
   'Second Sight',
   'See Wards',
   'Stone to Flesh',
   'Summon Fog',
   'Summon Greater Familiar',
   'Summon Shadow Beast',
   'Summon and Control Animals',
   'Summon and Control Canines',
   'Summon and Control Entity',
   'Summon and Control Rodents',
   'Summon and Control Storm',
   'Swim as a Fish (Superior)',
   'Swords to Snakes',
   'Talisman',
   'Telekinesis',
   'Teleport: Superior',
   'Time Hole',
   'Time Slip',
   'Transferal',
   'Transformation');


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS now_both FROM spells
 WHERE system = 'both' AND name IN (
   'Amulet',
   'Anti-Magic Cloud',
   'Apparition',
   'Astral Projection',
   'Barrier of Thoth',
   'Calm Storms',
   'Close Rift',
   'Create Golem',
   'Create Magic Scroll',
   'Create Mummy',
   'Create Zombie',
   'Crimson Wall of Lictalon',
   'Curse: Phobia',
   'Dimensional Portal',
   'Dimensional Teleport',
   'Doppleganger (Superior)',
   'Hallucination',
   'Havoc',
   'Horrific Illusion',
   'Id Barrier',
   'Impenetrable Wall of Force',
   'Invulnerability',
   'Memory Bank',
   'Metamorphosis: Insect',
   'Metamorphosis: Mist',
   'Metamorphosis: Superior',
   'Minor Curse',
   'Mystic Alarm',
   'Mystic Portal',
   'Oracle',
   'Protection Circle: Superior',
   'Remove Curse',
   'Restoration',
   'Resurrection',
   'Sanctuary',
   'Sanctum',
   'Seal',
   'Second Sight',
   'See Wards',
   'Stone to Flesh',
   'Summon Fog',
   'Summon Greater Familiar',
   'Summon Shadow Beast',
   'Summon and Control Animals',
   'Summon and Control Canines',
   'Summon and Control Entity',
   'Summon and Control Rodents',
   'Summon and Control Storm',
   'Swim as a Fish (Superior)',
   'Swords to Snakes',
   'Talisman',
   'Telekinesis',
   'Teleport: Superior',
   'Time Hole',
   'Time Slip',
   'Transferal',
   'Transformation');
SELECT count(*) AS still_rifts_only FROM spells WHERE system = 'rifts';
SELECT count(*) AS reachable_by_a_palladium_mage FROM spells
 WHERE system IS NULL OR system IN ('both', 'palladium-fantasy');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('retag-pf-spells-both.sql');
