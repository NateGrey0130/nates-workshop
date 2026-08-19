-- Category restrictions that named a skill the catalog does not spell that way.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-dead-skill-restrictions.sql
--
-- Found by scripts/class-check.mjs, which reports restriction names matching no
-- catalog row. `categoryAllows` compares literal names, so an unmatched name in
-- an `except` list excludes NOTHING and an unmatched name in an `only` list
-- offers nothing. Both are silent. The `except` direction fails OPEN, which is
-- the dangerous way round: the class goes on offering a skill its book forbids.
--
-- The names come from the book; the catalog stores several of them under older
-- spellings. add-rue-skills-batch.sql records the mapping and the reasoning -
-- RUE renames are deliberately NOT inserted as new rows, because characters
-- reference skills by name and a second row would manufacture a duplicate.
-- So the class file is what moves to the catalog's spelling, not the reverse.
--
-- Two kinds of edit here, and they are not the same kind of thing.


-- ===== 1. Live bugs: the restriction did nothing =====
-- Each of these is the only name in its list for that skill, so the exclusion
-- (or, for the Dog Boy, the permission) was simply lost.

-- Pilot skills are stored WITHOUT the "Pilot:" or "Military:" prefix - the
-- catalog row is "Jet Fighters". These three classes named only the prefixed
-- form, so each has been offering Jet Fighters against the book.
UPDATE imported_classes SET markdown = replace(markdown, '"Military: Jet Fighters"', '"Jet Fighters"')
  WHERE class_id IN ('burster', 'wild-psi-stalker', 'warlock')
    AND instr(markdown, '"Military: Jet Fighters"') > 0;

-- The catalog row is "Interrogation Techniques". Anchored on the closing
-- bracket so it cannot match a name that already carries the suffix.
UPDATE imported_classes SET markdown = replace(markdown, '"Interrogation"]', '"Interrogation Techniques"]')
  WHERE class_id = 'long-bowman'
    AND instr(markdown, '"Interrogation"]') > 0;

-- An `only` list, so this one failed CLOSED: the Dog Boy could not take
-- Motorcycle at all, which its own note says the book grants
-- ("Pilot: Motorcycle, Hovercycle, Jet Pack, Truck & Motorboat only").
UPDATE imported_classes SET markdown = replace(markdown, '"Motorcycles & Snowmobiles"', '"Motorcycle"')
  WHERE class_id = 'dog-boy'
    AND instr(markdown, '"Motorcycles & Snowmobiles"') > 0;

-- The catalog row is singular.
UPDATE imported_classes SET markdown = replace(markdown, '"W.P. Pole Arms"', '"W.P. Pole Arm"')
  WHERE class_id = 'priest-of-light'
    AND instr(markdown, '"W.P. Pole Arms"') > 0;


-- ===== 2. Redundant aliases: the restriction already worked =====
-- These lists name the SAME skill twice - once as the catalog spells it, once
-- as RUE does. The exclusion was never broken. They are removed because a
-- permanently-unmatched name makes class-check report a problem on every future
-- run, and a checker that always finds something is one you stop reading.
--
-- Only removed where the catalog spelling is present in the SAME list. Names
-- for skills the catalog genuinely lacks are left alone - the Priest of Light's
-- W.P. Siege, W.P. Large Axes and W.P. Lance are declared ahead of the rows
-- arriving, which its note says outright, and the Long Bowman's Falconry and
-- Locate Secret Compartments are the same case.

-- "Jet Fighters" is already in both lists.
UPDATE imported_classes SET markdown = replace(markdown,
  '"Military: Warships & Patrol Boats", "Military: Jet Fighters"]',
  '"Military: Warships & Patrol Boats"]')
  WHERE class_id IN ('mystic', 'shifter')
    AND instr(markdown, '"Military: Warships & Patrol Boats", "Military: Jet Fighters"]') > 0;

-- "Military: Warships & Patrol Boats" is already in the same list.
UPDATE imported_classes SET markdown = replace(markdown,
  '"Tanks and APCs", "Warships", "Robots and Power Armor"',
  '"Tanks and APCs", "Robots and Power Armor"')
  WHERE class_id = 'mystic'
    AND instr(markdown, '"Tanks and APCs", "Warships", "Robots and Power Armor"') > 0;

-- The two RUE heavy W.P. names are renames of the two catalog rows that open
-- the same list - see add-rue-skills-batch.sql, "the two heavy W.P.s".
UPDATE imported_classes SET markdown = replace(markdown,
  '["W.P. Heavy", "W.P. Heavy Energy Weapons", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"]',
  '["W.P. Heavy", "W.P. Heavy Energy Weapons"]')
  WHERE class_id IN ('mystic', 'burster')
    AND instr(markdown, '"W.P. Heavy Military Weapons"') > 0;


-- Read the result back rather than trusting the exit code.
--
-- Every name this script touches must be gone. The names left standing are the
-- deliberate forward declarations named above. The second check counts CLASSES,
-- not names: the Priest of Light holds three of them and the Long Bowman two.
SELECT 'still dead (expect 0)' AS check_name, count(*) AS n
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (instr(markdown, '"Military: Jet Fighters"') > 0
     OR instr(markdown, '"Interrogation"]') > 0
     OR instr(markdown, '"Motorcycles & Snowmobiles"') > 0
     OR instr(markdown, '"W.P. Pole Arms"') > 0
     OR instr(markdown, '"Warships"') > 0
     OR instr(markdown, '"W.P. Heavy Military Weapons"') > 0
     OR instr(markdown, '"W.P. Heavy M.D. Weapons"') > 0);

SELECT 'classes declaring ahead of the catalog (expect 2)' AS check_name, count(*) AS n
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (instr(markdown, '"W.P. Siege"') > 0
     OR instr(markdown, '"W.P. Large Axes"') > 0
     OR instr(markdown, '"W.P. Lance"') > 0
     OR instr(markdown, '"Falconry"') > 0
     OR instr(markdown, '"Locate Secret Compartments"') > 0);

-- Every class this script touches, so a partial apply is visible.
SELECT class_id,
       instr(markdown, '"Jet Fighters"') > 0 AS has_jet_fighters,
       instr(markdown, '"Interrogation Techniques"') > 0 AS has_interrogation,
       instr(markdown, '"Motorcycle"') > 0 AS has_motorcycle,
       instr(markdown, '"W.P. Pole Arm"') > 0 AS has_pole_arm
  FROM imported_classes
 WHERE class_id IN ('burster', 'wild-psi-stalker', 'warlock', 'long-bowman', 'dog-boy', 'priest-of-light', 'mystic', 'shifter')
 ORDER BY class_id;
