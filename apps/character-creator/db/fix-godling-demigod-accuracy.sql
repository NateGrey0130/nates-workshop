-- The Godling and Demigod R.C.C.s, corrected against the book itself.
--
-- Rifts Conversion Book Two: Pantheons of the Megaverse, printed p.16-17. Both
-- classes were TRANSCRIBED BY HAND WITHOUT THE BOOK - their own headers say so,
-- because the PDF was not in the source collection at the time. It is now, it
-- has a text layer, and the printed page number equals the PDF page index, so
-- every field was re-read geometrically with scripts/read-columns.py and
-- compared line by line.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-godling-demigod-accuracy.sql
--
-- The audit is mostly a clean bill. Every attribute die, both M.D.C. formulas,
-- S.D.C. and Hit Points, both conditional P.P.E. and I.S.P. branches, horror
-- factor, all five natural abilities, all eleven powers' numbers, every combat
-- and save bonus, the skill counts (eight related at levels 3/7/11/15, five
-- secondary), money, equipment and life span all match the page. So does the
-- trickiest call in the original import: printed p.17's left column is the tail
-- of the GODLING entry, not the Demigod, and it was read that way.
--
-- Four things were wrong. This script fixes them.
--
-- F1. A DURATION ON THE WRONG POWER. Both classes.
--     Power 3 on p.16 is "Energy Aura: A field of magical energy that protects
--     with 20 M.D.C. (or S.D.C.) per level of experience. Can be created up to
--     three times per 24 hour period." - no duration at all. Power 6 is "Shape
--     Shifter: The character can change at will into one animal, one time a day
--     per level, FOR ONE HOUR." The stored text has that hour on Energy Aura and
--     missing from Shape Shifter, so an aura that the book never limits reads as
--     hourly, and a shape shift that lasts an hour reads as indefinite. Both
--     classes carry the identical eleven-power block, so both carry the error.
--
-- F2. AN EXCLUSION THAT EXCLUDED NOTHING. Godling only.
--     p.17: "Pilot: Any; except robots and power armor". The class named
--     "Robots and Power Armor" in its `except` list, and the catalog renamed
--     that row to "Robots & Power Armor". categoryAllows compares literal
--     names, so the exclusion silently did nothing and a Godling could take the
--     one Pilot skill the book forbids. There IS a catalog_redirects row for
--     the old spelling, and it does not help: redirects are deliberately not
--     consulted for restrictions, exactly as the README says. scripts/
--     class-check.mjs --remote reported this independently.
--
-- F3. FIVE SKILL BONUSES THE FORMAT COULD NOT HOLD. Godling only.
--     p.16-17 print "Domestic: Any (+10%)", "Medical: Any (except cybernetics;
--     +10%)", "Pilot: Any; except robots and power armor, (+15% for
--     Horsemanship)", "Technical: Any (+10%)" and "Wilderness: Any (+5%)". A
--     related-skill category could only say `only` or `except` until the
--     preceding PR, so all five were dropped.
--
--     Note where the +15% lands. The book states it FOR HORSEMANSHIP, not for
--     Pilot as a whole, and this catalog files Horsemanship skills under their
--     own `Horsemanship` category - which this class already grants. So the
--     bonus goes on that entry and Pilot itself keeps none. Reading it as a
--     Pilot bonus would have handed fifteen points to every aircraft and
--     hovercycle skill the book never mentions.
--
-- F4. A FIXED FIGHTING STYLE WHERE THE BOOK OFFERS A CHOICE. Godling only.
--     p.16 says "Hand to Hand: Any of choice". The class granted Hand to Hand:
--     Expert outright, with a note saying any may be taken - and a note is
--     advisory, never enforced, so the wizard handed out Expert and offered
--     nothing else. It is now a choice group over the five styles the catalog
--     holds. It also lacked base/per_level, the only class in the repo missing
--     them, which is what class-check was warning about.
--
-- Every replacement below is guarded with instr() and was verified to match
-- EXACTLY ONCE against the live markdown before this file was written, so a
-- replace() cannot rewrite something it was not aimed at. Re-running is a
-- no-op: the guard fails once the text is already corrected.
--
-- Pure ASCII with LF endings, per PR #93 and #101 - wrangler on Windows has
-- turned a non-ASCII character in one of these scripts into mojibake in
-- production before, and the smoke test checks the whole file, comments too.

-- ---------------------------------------------------------------------------
-- F1a. Energy Aura loses the hour the book never gave it. Both classes.
-- ---------------------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         'experience, for one hour. Can be created',
         'experience. Can be created'),
       updated_at = datetime('now')
 WHERE class_id IN ('godling', 'demigod')
   AND instr(markdown, 'experience, for one hour. Can be created') > 0;

-- ---------------------------------------------------------------------------
-- F1b. Shape Shifter gains the hour that is actually printed on it.
-- ---------------------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         'one time a day per level. Gets all',
         'one time a day per level, for one hour. Gets all'),
       updated_at = datetime('now')
 WHERE class_id IN ('godling', 'demigod')
   AND instr(markdown, 'one time a day per level. Gets all') > 0;

-- ---------------------------------------------------------------------------
-- F2. The Pilot exclusion starts working.
-- ---------------------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         char(34) || 'Robots and Power Armor' || char(34),
         char(34) || 'Robots & Power Armor' || char(34)),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, char(34) || 'Robots and Power Armor' || char(34)) > 0;

-- ---------------------------------------------------------------------------
-- F3. The five percentages the pages print beside the categories.
--
-- One statement each rather than a chain, so a guard that has already fired
-- cannot suppress the others, and so d1-apply names the one that failed.
-- ---------------------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - ' || char(34) || 'Domestic' || char(34),
         '      - { name: ' || char(34) || 'Domestic' || char(34) || ', bonus: 10 }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, '      - ' || char(34) || 'Domestic' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'except: [' || char(34) || 'M.D. in Cybernetics' || char(34) || '] }',
         'except: [' || char(34) || 'M.D. in Cybernetics' || char(34) || '], bonus: 10 }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, 'except: [' || char(34) || 'M.D. in Cybernetics' || char(34) || '] }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - ' || char(34) || 'Technical' || char(34),
         '      - { name: ' || char(34) || 'Technical' || char(34) || ', bonus: 10 }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, '      - ' || char(34) || 'Technical' || char(34)) > 0;

-- The +15% the book states for Horsemanship, on the category this catalog
-- files those skills under. Not on Pilot - see F3 in the header.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - ' || char(34) || 'Horsemanship' || char(34),
         '      - { name: ' || char(34) || 'Horsemanship' || char(34) || ', bonus: 15 }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, '      - ' || char(34) || 'Horsemanship' || char(34)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '      - ' || char(34) || 'Wilderness' || char(34),
         '      - { name: ' || char(34) || 'Wilderness' || char(34) || ', bonus: 5 }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, '      - ' || char(34) || 'Wilderness' || char(34)) > 0;

-- ---------------------------------------------------------------------------
-- F4. "Hand to Hand: Any of choice" becomes a choice the player actually makes.
--
-- All five styles the catalog holds, because "any" is what the page says. The
-- alignment condition on Assassin is prose, as conditional rules always are
-- here - the format has no way to gate a choice on alignment.
-- ---------------------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         '    - { name: ' || char(34) || 'Hand to Hand: Expert' || char(34)
           || ', note: ' || char(34) || 'Hand to hand of choice; any may be taken.' || char(34) || ' }',
         '    - { choose: 1, from: [' || char(34) || 'Hand to Hand: Basic' || char(34)
           || ', ' || char(34) || 'Hand to Hand: Expert' || char(34)
           || ', ' || char(34) || 'Hand to Hand: Martial Arts' || char(34)
           || ', ' || char(34) || 'Hand to Hand: Commando' || char(34)
           || ', ' || char(34) || 'Hand to Hand: Assassin' || char(34)
           || '], base: 0, per_level: 0, note: ' || char(34)
           || 'The book says hand to hand of choice; any may be taken. Assassin needs an evil alignment.'
           || char(34) || ' }'),
       updated_at = datetime('now')
 WHERE class_id = 'godling'
   AND instr(markdown, '    - { name: ' || char(34) || 'Hand to Hand: Expert' || char(34)
         || ', note: ' || char(34) || 'Hand to hand of choice; any may be taken.' || char(34) || ' }') > 0;

-- ---------------------------------------------------------------------------
-- Read the result back rather than trusting the exit code.
--
-- Counted with a single arithmetic SELECT rather than a UNION of literals: D1
-- rejects a compound SELECT built from about nine terms with "too many terms in
-- compound SELECT", and rolls the whole file back when it does.
-- ---------------------------------------------------------------------------
SELECT class_id,
       length(markdown) AS bytes,
       instr(markdown, char(13)) > 0                              AS has_cr,
       instr(markdown, 'experience, for one hour') > 0             AS f1a_unfixed,
       instr(markdown, 'per level, for one hour. Gets all') > 0    AS f1b_fixed,
       instr(markdown, char(34) || 'Robots and Power Armor') > 0   AS f2_unfixed
  FROM imported_classes WHERE class_id IN ('godling', 'demigod') ORDER BY class_id;

-- Five bonuses and one choice group, on the Godling only.
SELECT (instr(markdown, char(34) || 'Domestic' || char(34) || ', bonus: 10') > 0)
     + (instr(markdown, 'M.D. in Cybernetics' || char(34) || '], bonus: 10') > 0)
     + (instr(markdown, char(34) || 'Technical' || char(34) || ', bonus: 10') > 0)
     + (instr(markdown, char(34) || 'Horsemanship' || char(34) || ', bonus: 15') > 0)
     + (instr(markdown, char(34) || 'Wilderness' || char(34) || ', bonus: 5') > 0)  AS bonuses_of_five,
       instr(markdown, 'Hand to Hand: Commando') > 0                                 AS hth_is_a_choice
  FROM imported_classes WHERE class_id = 'godling';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-godling-demigod-accuracy.sql');
