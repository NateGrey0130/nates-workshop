-- Descriptions for the 23 spells that had none.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-spell-descriptions.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-spell-descriptions.sql
--
-- All 23 came in with the seed rather than through the PDF importers, which is
-- why they carried a name, a level and a P.P.E. cost but no text. They are not
-- obscure: seventeen of them are levels 1-3, and Armor of Ithan and Energy Bolt
-- are cast constantly.
--
-- The supplied P.P.E. costs were checked against the stored ones before any of
-- this was written. All 23 matched, so nothing here touches `ppe` - a
-- correction that quietly rewrote a cost would be far worse than a missing
-- description.
--
-- `damage` and `duration` are set only where the source states them outright:
-- Energy Bolt's 4D6 and Breathe Without Air's 12 melees per level. Everything
-- else keeps NULL rather than a guess.
--
-- Each UPDATE is guarded on the description still being empty, so re-running is
-- safe and nothing later edited by hand is overwritten.


UPDATE spells SET description = 'A burst of light in a small area. A failed save vs magic means temporary blindness for a few melee rounds. Polarized or tinted optics negate it entirely.'
  WHERE name = 'Blinding Flash'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'A floating sphere of natural daylight that the caster can move around at a distance. Illumination only - it gives off no heat and does no damage.'
  WHERE name = 'Globe of Daylight'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'A weaker, cheaper light source than Globe of Daylight, with a smaller radius - roughly equivalent to a lantern.'
  WHERE name = 'Lantern Light'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Detects the presence of supernatural evil and evil-aligned supernatural beings in range. It does NOT detect ordinary evil humans.'
  WHERE name = 'Sense Evil'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Detects active magic, enchanted objects and magic energy in range. It does not identify which spell is at work.'
  WHERE name = 'Sense Magic'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Creates a loud crack of thunder at a chosen point. Does no damage; used for distraction, startling an opponent, or signalling.'
  WHERE name = 'Thunderclap'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The recipient''s coloring blends with the surroundings. Very hard to spot while standing still, and much easier to notice while moving.'
  WHERE name = 'Chameleon'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Hides a small object on the caster''s person from sight and from casual search.'
  WHERE name = 'Concealment'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Reveals hidden compartments, concealed objects, secret doors, and anything hidden by the Concealment spell.'
  WHERE name = 'Detect Concealment'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The target must save vs magic or flee in panic. A horror-factor style effect.'
  WHERE name = 'Fear'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Raises or lowers the caster or an object vertically. No horizontal movement - that is Fly.'
  WHERE name = 'Levitation'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Mystic armor with 10 M.D.C. per level of experience. Magic, fire, lightning and cold do half damage against it. Can be cast on someone else by touch. The workhorse survival spell.'
  WHERE name = 'Armor of Ithan'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Lets the recipient function normally without air - underwater, in vacuum, or in a low-oxygen environment. Protects against natural and man-made gases, but NOT against magic toxins.',
  duration = '12 melees (3 minutes) per level of experience'
  WHERE name = 'Breathe Without Air'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'A ranged bolt of magic energy. The Shifter''s basic attack spell.',
  damage = '4D6'
  WHERE name = 'Energy Bolt'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Gusts of wind used to push or shove, knock over light objects, or disturb papers and small items at a distance.'
  WHERE name = 'Fingers of the Wind'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The recipient becomes invisible. It breaks, or becomes detectable, on taking aggressive action against others.'
  WHERE name = 'Invisibility: Simple'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The target saves vs magic or is frozen in place, unable to move or act, for the duration.'
  WHERE name = 'Paralysis: Lesser'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Removes the need for food, water and sleep for the duration. A long-duration utility spell for travel and vigils.'
  WHERE name = 'Sustain'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The caster briefly slips a few seconds out of the timestream, effectively vanishing and reappearing an instant later. Used to dodge an incoming attack.'
  WHERE name = 'Time Slip'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Calls wild and feral canines from the surrounding area and places them under the caster''s command. The number summoned depends on what is actually nearby.'
  WHERE name = 'Summon and Control Canines'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'The same mechanic as Summon and Control Canines, for rodents: larger numbers, individually much weaker.'
  WHERE name = 'Summon and Control Rodents'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Reopens a rift or dimensional gateway that recently closed, at the same location and to the same destination. Cheaper than opening a new portal, which is the point.'
  WHERE name = 'Re-Open Gateway'
    AND (description IS NULL OR description = '');

UPDATE spells SET description = 'Opens a controlled portal to another dimension. The signature Shifter capstone - the cost effectively requires a ley line nexus or a group ritual.'
  WHERE name = 'Dimensional Portal'
    AND (description IS NULL OR description = '');

-- Reports the result back, so it is read rather than assumed.
--   described        23 = every one of them landed
--   still_missing     0 = no spell anywhere is left without text
--   bolt_damage    '4D6'
--   breathe_duration the per-level duration, not a flat number
--   ppe_intact       23 = every cost is still what it was before this ran
SELECT (SELECT count(*) FROM spells
          WHERE description IS NOT NULL AND description != ''
            AND name IN ('Blinding Flash', 'Globe of Daylight', 'Lantern Light', 'Sense Evil',
                         'Sense Magic', 'Thunderclap', 'Chameleon', 'Concealment',
                         'Detect Concealment', 'Fear', 'Levitation', 'Armor of Ithan',
                         'Breathe Without Air', 'Energy Bolt', 'Fingers of the Wind',
                         'Invisibility: Simple', 'Paralysis: Lesser', 'Sustain', 'Time Slip',
                         'Summon and Control Canines', 'Summon and Control Rodents',
                         'Re-Open Gateway', 'Dimensional Portal')) AS described,
       (SELECT count(*) FROM spells
          WHERE description IS NULL OR description = '') AS still_missing,
       (SELECT damage FROM spells WHERE name = 'Energy Bolt') AS bolt_damage,
       (SELECT duration FROM spells WHERE name = 'Breathe Without Air') AS breathe_duration,
       (SELECT count(*) FROM spells WHERE (name, ppe) IN (VALUES
          ('Blinding Flash', 1), ('Globe of Daylight', 2), ('Lantern Light', 1),
          ('Sense Evil', 2), ('Sense Magic', 4), ('Thunderclap', 4),
          ('Chameleon', 6), ('Concealment', 6), ('Detect Concealment', 6),
          ('Fear', 5), ('Levitation', 5), ('Armor of Ithan', 10),
          ('Breathe Without Air', 5), ('Energy Bolt', 5), ('Fingers of the Wind', 5),
          ('Invisibility: Simple', 6), ('Paralysis: Lesser', 5), ('Sustain', 12),
          ('Time Slip', 20), ('Summon and Control Canines', 50),
          ('Summon and Control Rodents', 70), ('Re-Open Gateway', 180),
          ('Dimensional Portal', 1000))) AS ppe_intact;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-spell-descriptions.sql');
