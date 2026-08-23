-- The Druid names three wizard spells the catalog spells differently.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- a row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-druid-spell-names.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-druid-spell-names.sql
--
-- Palladium Fantasy main book, the Druid O.C.C., printed 77-79.
--
-- The Druid's level_progression is prose, so none of this was BROKEN - the app
-- never resolved these names and nothing failed. It was misleading, which is
-- the same thing to a player: the class page tells you that at ninth level you
-- gain Faerie's Dance, and typing that into the spell picker finds nothing,
-- because the row is Faeries' Dance.
--
-- Worth doing now rather than later because add-pf-invocations.sql is what
-- makes these names findable at all. Before it, six of the sixteen spells the
-- Druid names had no catalog row of any spelling - Faerie Speak, Control the
-- Beasts, Summon and Control Canines, Witch Bottle, Faeries' Dance and Monster
-- Insect - so correcting the spelling would have pointed at nothing.
--
-- WHAT IS NOT CHANGED, and why it is not a gap: Healing Touch, Kindle Flame,
-- Prophecy, Divination, Phoenix Healing, Protection Charm, Weather Control and
-- Communication are DRUIDIC MAGIC POWERS with their own descriptions on the
-- Druid's own pages, not wizard spells. They have no catalog row and should
-- not have one. Kindle Flame is the one that reads like an oversight and is
-- not: printed 76 gives it a full description of its own, and the level four
-- line does not say "as the wizard spells" the way levels 2, 5 and 7 do.
--
-- Guarded on the text still being what it was, so re-running is a no-op and a
-- row somebody has since edited is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown, 'Negate Poisons/Toxins', 'Negate Poison/Toxin')
 WHERE class_id = 'druid' AND instr(markdown, 'Negate Poisons/Toxins') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Faerie''s Dance', 'Faeries'' Dance')
 WHERE class_id = 'druid' AND instr(markdown, 'Faerie''s Dance') > 0;

-- Sentence case, so it matches the catalog row a player would search for. The
-- book sets it lower case mid-sentence; every other spell on the same line is
-- capitalised.
UPDATE imported_classes
   SET markdown = replace(markdown, 'and control the beasts, all as the wizard spells',
                          'and Control the Beasts, all as the wizard spells')
 WHERE class_id = 'druid' AND instr(markdown, 'and control the beasts, all as the wizard spells') > 0;


-- Read the result back rather than trusting the exit code. Each of these
-- should be 1, and each of the old spellings 0.
SELECT
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'druid' AND instr(markdown, 'Negate Poison/Toxin') > 0) AS negate_fixed,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'druid' AND instr(markdown, 'Faeries'' Dance') > 0) AS dance_fixed,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'druid' AND instr(markdown, 'and Control the Beasts, all as') > 0) AS beasts_fixed,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'druid' AND instr(markdown, 'Negate Poisons/Toxins') > 0) AS old_negate_left,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'druid' AND instr(markdown, 'Faerie''s Dance') > 0) AS old_dance_left;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-druid-spell-names.sql');
