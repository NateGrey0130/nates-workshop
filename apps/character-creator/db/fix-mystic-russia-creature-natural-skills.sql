-- The six Woodland Spirits' Natural Abilities percentages, granted as catalog
-- skills. 25 skill grants across 6 classes, and 17 sentences corrected.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-mystic-russia-creature-natural-skills.sql
--
-- WHY THIS CHANGES A DECISION THE IMPORT MADE DELIBERATELY. Rifts World Book 18
-- separates `Natural Abilities` from `R.C.C. Skills`, and the import kept that
-- seam: prowl, climb, swim and the tracking percentages were recorded as prose
-- because that is the block the book prints them in. `natural_abilities` is
-- DISPLAY-ONLY, so the effect was that a Domovoi player character had no Prowl
-- on their sheet while the book printed 70%.
--
-- FOLLOWING THE BOOK EXACTLY DOES NOT SETTLE IT, because the book is
-- inconsistent with itself: the Spirit Wolf puts Prowl in its R.C.C. SKILLS
-- line and the other five put theirs under Natural Abilities. Reproducing that
-- gives one creature a sheet-visible Prowl and five identical creatures none.
-- So the percentages are granted, and the entries that record them keep every
-- detail a skill row cannot hold - the rappel figure, the breath-holding, the
-- depth, the animal-form bonuses.
--
-- PROWL IS ABSENT FROM THE SPIRIT WOLF'S LIST BELOW, and that is the one thing
-- in this file most likely to read as an omission. It already grants Prowl at
-- 70% as a skill; adding it again would be a duplicate, which the create
-- validator refuses with HTTP 422 `duplicate_skill`.
--
-- EVERY FIGURE IS THE BOOK'S. A two-number climb - "90%/80%" - gives its FIRST
-- number, the climb figure, because the catalog holds one Climbing row; the
-- rappel figure stays in natural_abilities. Conditional figures are not
-- granted: the Leshii tracks at 50% and 65% in animal form, the Man-Wolf at 85%
-- and 50 points lower in human form, and `base` holds one number, so the
-- unconditional one is stored and the condition stays prose.
--
-- ONE INTERACTION, AND IT IS THE CORRECT ONE. `Track & Trap Animals` is a
-- WILDERNESS skill and five of the six classes grant Wilderness choice groups,
-- so granting it removes it from those pools through `takenNames()`. That is a
-- skill that cannot be taken twice, and it replaces a pick at the catalog's base
-- of 20% with the creature's printed 60-90%. `Prowl`, `Climbing` and
-- `Swimming` are PHYSICAL and `Tracking (people)` is ESPIONAGE; no creature here
-- grants a choice group from either category, so those fifteen grants interact
-- with nothing.
--
-- `per_level: 0` ON EVERY ONE, because five of the six entries say outright that
-- the skills do not advance. That key is read by `resolveSkill` and, since
-- BOOK-INGEST-AUDIT F80, validated on both branches of `validateSkillEntries`.
--
-- THE SPIRIT WOLF'S SCENT LINE IS UNQUALIFIED and is granted as BOTH tracking
-- rows. Printed 68 reads "track by scent alone 75%" with no object; the
-- Man-Wolf's parallel line three pages later reads "track humanoids or animals
-- by scent alone", and a wolf tracks both. The reading is recorded in the notes
-- rather than assumed.
--
-- GENERATED FROM THE LIVE MARKDOWN, not written by hand. The generator verified
-- for every class that the `natural_abilities:` anchor occurs exactly once,
-- that no class already GRANTS one of these as a skill (checked against the
-- PARSED occ_skills, since every one of these names is also a natural_abilities
-- entry - a substring test cannot tell those apart, and its first run stopped on
-- exactly that false positive), and that the edited markdown parses and yields
-- each skill at the intended base, `per_level` 0, and a note that round-trips
-- byte for byte through the escaped inner quotes.
--
-- Each UPDATE is guarded on the grant it adds, so a re-run is a no-op.

-- domovoi: 5 skills, Prowl, Climbing, Swimming, Tracking (people), Track & Trap Animals.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Prowl", base: 70, per_level: 0, note: "Printed 58 under Natural Abilities: \"prowl 70%\"." }' || char(10) || '    - { name: "Climbing", base: 90, per_level: 0, note: "Printed 58: \"climb 90%/80%\". The catalog holds one Climbing row, so 90 is the climb figure and the 80% to rappel stays in natural_abilities." }' || char(10) || '    - { name: "Swimming", base: 80, per_level: 0, note: "Printed 58: \"swim 80%\". The breath-holding and depth figures stay in natural_abilities; they are not skill data." }' || char(10) || '    - { name: "Tracking (people)", base: 50, per_level: 0, note: "Printed 58: \"track humanoids 50%\". The catalog files this under Espionage, which this class grants no choice group from, so there is no interaction with its picks." }' || char(10) || '    - { name: "Track & Trap Animals", base: 60, per_level: 0, note: "Printed 58: \"track animals 60%\". Filed under Wilderness, which this class DOES grant two picks from - so granting it here removes it from that pool, which is correct: a skill cannot be taken twice." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'domovoi'
   AND instr(markdown, '{ name: "Prowl", base: 70') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.', 'The book files this under Natural Abilities rather than R.C.C. Skills. The percentage is ALSO granted as a catalog skill, so it reaches the sheet; this entry keeps the detail a skill row cannot hold.')
 WHERE class_id = 'domovoi' AND instr(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Filed by the book under Natural Abilities.', 'Filed by the book under Natural Abilities, and also granted as a catalog skill so it reaches the sheet.')
 WHERE class_id = 'domovoi' AND instr(markdown, 'Filed by the book under Natural Abilities.') > 0;

-- leshii: 5 skills, Prowl, Climbing, Swimming, Tracking (people), Track & Trap Animals.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Prowl", base: 65, per_level: 0, note: "Printed 60 under Natural Abilities: \"prowl 65%\"." }' || char(10) || '    - { name: "Climbing", base: 90, per_level: 0, note: "Printed 60: \"climb 90%/85%\". 90 is the climb figure; the 85% to rappel stays in natural_abilities." }' || char(10) || '    - { name: "Swimming", base: 80, per_level: 0, note: "Printed 60: \"swim 80%\"." }' || char(10) || '    - { name: "Tracking (people)", base: 50, per_level: 0, note: "Printed 60: \"track humanoids 50%\", rising to 65% in animal form - a conditional the catalog cannot hold, so the base figure is granted and the animal-form bonus stays prose." }' || char(10) || '    - { name: "Track & Trap Animals", base: 90, per_level: 0, note: "Printed 60: \"track animals 90%\", rising to 95% in animal form. The base figure is granted; the animal-form bonus stays prose." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'leshii'
   AND instr(markdown, '{ name: "Prowl", base: 65') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.', 'The book files this under Natural Abilities rather than R.C.C. Skills. The percentage is ALSO granted as a catalog skill, so it reaches the sheet; this entry keeps the detail a skill row cannot hold.')
 WHERE class_id = 'leshii' AND instr(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Filed by the book under Natural Abilities.', 'Filed by the book under Natural Abilities, and also granted as a catalog skill so it reaches the sheet.')
 WHERE class_id = 'leshii' AND instr(markdown, 'Filed by the book under Natural Abilities.') > 0;

-- polevoi: 5 skills, Prowl, Climbing, Swimming, Tracking (people), Track & Trap Animals.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Prowl", base: 55, per_level: 0, note: "Printed 62 under Natural Abilities: \"prowl 55%\"." }' || char(10) || '    - { name: "Climbing", base: 70, per_level: 0, note: "Printed 62: \"climb 70%/65%\". 70 is the climb figure; the rappel figure stays in natural_abilities." }' || char(10) || '    - { name: "Swimming", base: 70, per_level: 0, note: "Printed 62: \"swim 70%\"." }' || char(10) || '    - { name: "Tracking (people)", base: 50, per_level: 0, note: "Printed 62: \"track humanoids 50%\", +15% in animal form - the bonus is conditional and stays prose." }' || char(10) || '    - { name: "Track & Trap Animals", base: 70, per_level: 0, note: "Printed 62: \"track animals 70%\", +15% in animal form." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'polevoi'
   AND instr(markdown, '{ name: "Prowl", base: 55') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.', 'The book files this under Natural Abilities rather than R.C.C. Skills. The percentage is ALSO granted as a catalog skill, so it reaches the sheet; this entry keeps the detail a skill row cannot hold.')
 WHERE class_id = 'polevoi' AND instr(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Filed by the book under Natural Abilities.', 'Filed by the book under Natural Abilities, and also granted as a catalog skill so it reaches the sheet.')
 WHERE class_id = 'polevoi' AND instr(markdown, 'Filed by the book under Natural Abilities.') > 0;

-- vodianoi: 2 skills, Swimming, Climbing.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Swimming", base: 98, per_level: 0, note: "Printed 65 under Natural Abilities: swims flawlessly and faster than most fish, 98%. The highest swim figure in the book." }' || char(10) || '    - { name: "Climbing", base: 60, per_level: 0, note: "Printed 66: \"climb 60%/50%\". 60 is the climb figure; the rappel figure stays in natural_abilities." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'vodianoi'
   AND instr(markdown, '{ name: "Swimming", base: 98') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.', 'The book files this under Natural Abilities rather than R.C.C. Skills. The percentage is ALSO granted as a catalog skill, so it reaches the sheet; this entry keeps the detail a skill row cannot hold.')
 WHERE class_id = 'vodianoi' AND instr(markdown, 'The book files this under Natural Abilities rather than R.C.C. Skills, so it is recorded here rather than granted as a catalog skill - see extraction_notes.') > 0;

-- spirit-wolf: 4 skills, Swimming, Climbing, Tracking (people), Track & Trap Animals.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Swimming", base: 85, per_level: 0, note: "Printed 68 under Natural Abilities: an excellent and speedy swimmer, 85%. NOTE this entry already grants Prowl as a skill, which is why Prowl is not added here." }' || char(10) || '    - { name: "Climbing", base: 60, per_level: 0, note: "Printed 68: \"climb 60%/50%\"." }' || char(10) || '    - { name: "Tracking (people)", base: 75, per_level: 0, note: "Printed 68: \"track by scent alone 75%\", unqualified. Granted as BOTH tracking rows because the Man-Wolf''s parallel line in the same bestiary reads \"track humanoids or animals by scent alone\", and a wolf tracks both; the reading is recorded rather than assumed." }' || char(10) || '    - { name: "Track & Trap Animals", base: 75, per_level: 0, note: "The other half of that unqualified scent-tracking line." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'spirit-wolf'
   AND instr(markdown, '{ name: "Swimming", base: 85') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Filed by the book under Natural Abilities.', 'Filed by the book under Natural Abilities, and also granted as a catalog skill so it reaches the sheet.')
 WHERE class_id = 'spirit-wolf' AND instr(markdown, 'Filed by the book under Natural Abilities.') > 0;

-- man-wolf: 4 skills, Swimming, Climbing, Tracking (people), Track & Trap Animals.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'natural_abilities:',
         char(10) || '    - { name: "Swimming", base: 45, per_level: 0, note: "Printed 71 under Natural Abilities: they hate water and are only fair swimmers, 45%. The lowest swim figure of the six." }' || char(10) || '    - { name: "Climbing", base: 60, per_level: 0, note: "Printed 71: \"climb 60%/50%\"." }' || char(10) || '    - { name: "Tracking (people)", base: 85, per_level: 0, note: "Printed 71: \"track humanoids or animals by scent alone 85%\", dropping 50 points in human form - a conditional the catalog cannot hold, so the wolf-form figure is granted and the human-form penalty stays prose." }' || char(10) || '    - { name: "Track & Trap Animals", base: 85, per_level: 0, note: "The animals half of that line, which this entry names explicitly." }' || char(10) || 'natural_abilities:')
 WHERE class_id = 'man-wolf'
   AND instr(markdown, '{ name: "Swimming", base: 45') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'Filed by the book under Natural Abilities.', 'Filed by the book under Natural Abilities, and also granted as a catalog skill so it reaches the sheet.')
 WHERE class_id = 'man-wolf' AND instr(markdown, 'Filed by the book under Natural Abilities.') > 0;

-- Read the result back, ONE ASSERTION PER CLASS naming the exact fragment each
-- grant writes. 5 + 5 + 5 + 2 + 4 + 4 = 25.
--
-- THE OBVIOUS READBACK IS WRONG HERE AND ITS FIRST DRAFT WAS. Counting a marker
-- like `, per_level: 0, note: "Printed ` catches SIXTEEN skills these classes
-- already granted, whose notes begin "Printed at 80%" or "Printed as" - so it
-- returned 41 against a want of 25. Counting the specific grants cannot drift
-- that way. Booleans are arithmetic in SQLite, so summing instr() tests gives
-- the number present; a 25-term UNION would not work, because D1 caps compound
-- SELECT terms below six.

SELECT 'the domovoi gains its 5' AS assertion,
         (instr(markdown, '- { name: "Prowl", base: 70, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 90, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Swimming", base: 80, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Tracking (people)", base: 50, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Track & Trap Animals", base: 60, per_level: 0') > 0) AS got, 5 AS want
  FROM imported_classes WHERE class_id = 'domovoi';

SELECT 'the leshii gains its 5' AS assertion,
         (instr(markdown, '- { name: "Prowl", base: 65, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 90, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Swimming", base: 80, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Tracking (people)", base: 50, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Track & Trap Animals", base: 90, per_level: 0') > 0) AS got, 5 AS want
  FROM imported_classes WHERE class_id = 'leshii';

SELECT 'the polevoi gains its 5' AS assertion,
         (instr(markdown, '- { name: "Prowl", base: 55, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 70, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Swimming", base: 70, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Tracking (people)", base: 50, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Track & Trap Animals", base: 70, per_level: 0') > 0) AS got, 5 AS want
  FROM imported_classes WHERE class_id = 'polevoi';

SELECT 'the vodianoi gains its 2' AS assertion,
         (instr(markdown, '- { name: "Swimming", base: 98, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 60, per_level: 0') > 0) AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'vodianoi';

SELECT 'the spirit-wolf gains its 4' AS assertion,
         (instr(markdown, '- { name: "Swimming", base: 85, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 60, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Tracking (people)", base: 75, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Track & Trap Animals", base: 75, per_level: 0') > 0) AS got, 4 AS want
  FROM imported_classes WHERE class_id = 'spirit-wolf';

SELECT 'the man-wolf gains its 4' AS assertion,
         (instr(markdown, '- { name: "Swimming", base: 45, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Climbing", base: 60, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Tracking (people)", base: 85, per_level: 0') > 0)
       + (instr(markdown, '- { name: "Track & Trap Animals", base: 85, per_level: 0') > 0) AS got, 4 AS want
  FROM imported_classes WHERE class_id = 'man-wolf';

-- The Spirit Wolf must still grant Prowl exactly ONCE - it had one already, and
-- this file deliberately adds none.
SELECT 'the Spirit Wolf still grants Prowl exactly once' AS assertion,
       (length(markdown) - length(replace(markdown, '{ name: "Prowl"', ''))) / length('{ name: "Prowl"') AS got,
       1 AS want
  FROM imported_classes WHERE class_id = 'spirit-wolf';

-- No sentence may still claim these are NOT granted.
SELECT 'no creature still says the percentage is not granted' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(markdown, 'recorded here rather than granted as a catalog skill') > 0;

-- The highest and lowest swim figures in the book, which is the cheapest way to
-- catch a transposed number across six classes.
SELECT 'the Vodianoi swims at 98 and the Man-Wolf at 45' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'vodianoi' AND instr(markdown, '{ name: "Swimming", base: 98,') > 0)
    OR (class_id = 'man-wolf' AND instr(markdown, '{ name: "Swimming", base: 45,') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-mystic-russia-creature-natural-skills.sql');
