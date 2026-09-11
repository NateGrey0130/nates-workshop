-- BOOK-INGEST-AUDIT F61: a spell pick drawn from a named list now keeps the
-- class's level cap when the entry asks for it - `spell_levels:
-- "up_to_character_level"` beside `from_list`.
--
-- Three Spirit West shamans' books cap their later list-bound picks at the
-- character's own level, and until now the app kept the list and dropped the
-- cap, showing it as a note "the catalog cannot check". Each capped entry gets
-- the value and loses that note, since the cap is enforced now:
--
--   plant-shaman   levels 3-15, list B (printed 52)  - 13 entries
--   animal-shaman  levels 3-15, list B (printed 55)  - 13 entries
--   elemental      levels 2-15, list S (printed 66)  - 14 entries
--
-- NOT the Plant and Animal Shamans' level-2 grant: "Every remaining Shamanistic
-- spell" from list A, which spans spell levels 1-11 and 1-12 - a cap of 2 would
-- make it impossible to fill, and the book states none there. The three class
-- notes that called the cap "a note on each grant rather than enforced" are
-- rewritten. The ten Warlocks keep their pre-filtered lists (RETRO-AUDIT R3).

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         ', note: "Printed 52 lists these by level; no pick may be higher than the character''s own level." }',
         ', spell_levels: "up_to_character_level" }'),
         'The book caps each later pick at the character''s own level on that list; a named list replaces the spell-level gate in this app, so the cap is shown to the player as a note on each grant rather than enforced.',
         'The book caps each later pick at the character''s own level on that list, and each of those grants says so with spell_levels: up_to_character_level beside its list (BOOK-INGEST-AUDIT F61).'),
       updated_at = datetime('now')
 WHERE class_id = 'plant-shaman' AND instr(markdown, 'spell_levels: "up_to_character_level"') = 0;

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         ', note: "Printed 55 lists these by level; no pick may be higher than the character''s own level." }',
         ', spell_levels: "up_to_character_level" }'),
         'The book caps each later pick at the character''s own level on that list; a named list replaces the spell-level gate in this app, so the cap is a note on each grant rather than enforced.',
         'The book caps each later pick at the character''s own level on that list, and each of those grants says so with spell_levels: up_to_character_level beside its list (BOOK-INGEST-AUDIT F61).'),
       updated_at = datetime('now')
 WHERE class_id = 'animal-shaman' AND instr(markdown, 'spell_levels: "up_to_character_level"') = 0;

UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         ', note: "Two Shamanistic spells, none higher than the character''s own level." }',
         ', spell_levels: "up_to_character_level" }'),
         'From level two a named list replaces the level gate in this app, so the cap is a note on each grant.',
         'From level two each grant''s list is capped at the character''s own level by spell_levels: up_to_character_level (BOOK-INGEST-AUDIT F61).'),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman' AND instr(markdown, 'spell_levels: "up_to_character_level"') = 0;

SELECT 'plant-shaman caps levels 3-15' AS assertion,
       (length(markdown) - length(replace(markdown, 'spell_levels: "up_to_character_level"', ''))) / length('spell_levels: "up_to_character_level"') AS got, 13 AS want
  FROM imported_classes WHERE class_id = 'plant-shaman';
SELECT 'animal-shaman caps levels 3-15' AS assertion,
       (length(markdown) - length(replace(markdown, 'spell_levels: "up_to_character_level"', ''))) / length('spell_levels: "up_to_character_level"') AS got, 13 AS want
  FROM imported_classes WHERE class_id = 'animal-shaman';
SELECT 'elemental-shaman caps levels 2-15' AS assertion,
       (length(markdown) - length(replace(markdown, 'spell_levels: "up_to_character_level"', ''))) / length('spell_levels: "up_to_character_level"') AS got, 14 AS want
  FROM imported_classes WHERE class_id = 'elemental-shaman';
SELECT 'the level-2 remaining-spells grants stay uncapped' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes WHERE class_id IN ('plant-shaman', 'animal-shaman')
   AND instr(markdown, '{ level: 2, count:') > 0 AND instr(markdown, 'from_list: "A", note: "Every remaining Shamanistic') > 0;
SELECT 'no capped entry still tells the player to honour the cap' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id IN ('plant-shaman', 'animal-shaman', 'elemental-shaman')
   AND (instr(markdown, 'no pick may be higher than the character') > 0
        OR instr(markdown, 'none higher than the character''s own level." }') > 0);
SELECT 'no note still calls the cap unenforced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id IN ('plant-shaman', 'animal-shaman', 'elemental-shaman')
   AND instr(markdown, 'the cap is') > 0 AND instr(markdown, 'a note on each grant') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzz-f61-list-cap.sql');
