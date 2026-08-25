-- Five more classes whose Pilot exclusion had quietly stopped excluding.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-robots-power-armor-citations.sql
--
-- THE SAME BUG AS THE GODLING'S, in five more places. Each of these classes
-- bars robots and power armor in its book and names the skill
-- "Robots and Power Armor" in an `except` list. The catalog renamed that row to
-- "Robots & Power Armor" and kept the old spelling as a catalog_redirects entry
-- - and restrictions deliberately do NOT consult redirects, because
-- categoryAllows compares literal names. So all five exclusions matched nothing
-- and every one of these classes has been offering the one Pilot skill its book
-- forbids.
--
-- An unmatched `except` fails OPEN. That is why this is worth a script rather
-- than a note: nothing about it looks wrong from inside the app, the class reads
-- complete, and the only thing that ever said so was a cross-reference run by
-- hand. fix-godling-demigod-accuracy.sql fixed the first instance on
-- 2026-08-24; this sweep found the rest.
--
-- Found by checking every `only` and `except` name in all 83 published classes
-- against the live skill catalog at once. The only other unmatched names are the
-- Priest of Light's "W.P. Siege" and "W.P. Large Axes", which are the documented
-- forward-compatible case - it names weapons ahead of those rows existing and
-- says so in its own note.
--
-- THE ROBOT PILOT IS DELIBERATELY NOT TOUCHED, though it also names the old
-- spelling. Its reference is a GRANTED SKILL carrying its own base and per-level
-- numbers, not an exclusion - and redirects ARE consulted for missing
-- references, only restrictions skip them. class-check --remote reports its
-- skills as ok, so that citation resolves and works. The distinction is the
-- whole point: the same string is a live reference in one place and a dead
-- exclusion in another.
--
-- Guarded and idempotent. Pure ASCII, LF endings.

UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'Robots and Power Armor' || char(34), char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'burster' AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'Robots and Power Armor' || char(34), char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'mystic' AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'Robots and Power Armor' || char(34), char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'shifter' AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'Robots and Power Armor' || char(34), char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'warlock' AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'Robots and Power Armor' || char(34), char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker' AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

-- Read the result back, scoped to the five this script touches. A whole-catalog
-- search would also match the Robot Pilot's working reference above and report
-- a failure that is not one.
SELECT count(*) AS five_classes_still_citing_the_old_name
  FROM imported_classes
 WHERE class_id IN ('burster', 'mystic', 'shifter', 'warlock', 'wild-psi-stalker')
   AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

SELECT count(*) AS five_classes_now_citing_the_real_row
  FROM imported_classes
 WHERE class_id IN ('burster', 'mystic', 'shifter', 'warlock', 'wild-psi-stalker')
   AND instr(markdown, char(34) || 'Robots & Power Armor' || char(34)) > 0;

INSERT INTO data_script_runs (filename) VALUES ('fix-robots-power-armor-citations.sql');
