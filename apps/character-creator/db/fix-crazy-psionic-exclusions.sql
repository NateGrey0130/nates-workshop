-- Give the Crazy the exclusion its book states.
--
-- BOOK-INGEST-AUDIT.md F16, taken in PR #NNN. The code half teaches
-- `psionics.categories_allowed` the same only/except grammar a skill category
-- has had since the beginning; this is the one class in the catalog that needs
-- it.
--
-- Rifts Ultimate Edition printed 55: "Select three psionic powers from either
-- the Psychic Sensitive or Physical Psychic category (excluding Astral
-- Projection, Ectoplasm, Object Read and Telekinesis)." Read off the page.
--
-- F15 (PR #435) repaired the two category names, which turned this from moot
-- into real: a class that could pick nothing could not pick a forbidden power.
-- The Crazy has been offering 51 powers where its book allows 47.
--
-- "OBJECT READ" IS NOT WHAT THE CATALOG CALLS IT. The row is
-- "Object Read (Psychometry)", and an `except` naming a row that does not exist
-- excludes NOTHING, silently - the exact failure the class-import skill records
-- for six classes that named `Robots and Power Armor` after that row was
-- renamed. All four names were checked against psionic_powers before this ran;
-- the other three match exactly.
--
-- The exclusions are split across the two entries by the category the catalog
-- files each power under - Astral Projection and Object Read are Sensitive,
-- Ectoplasm and Telekinesis are Physical - because `except` is scoped to its
-- own category entry.

UPDATE imported_classes
   SET markdown = replace(markdown, '  categories_allowed: ["Sensitive", "Physical"]',
       '  categories_allowed:' || char(10) || '    - { name: "Sensitive", except: ["Astral Projection", "Object Read (Psychometry)"] }' || char(10) || '    - { name: "Physical", except: ["Ectoplasm", "Telekinesis"] }'),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, '  categories_allowed: ["Sensitive", "Physical"]') > 0
   AND instr(markdown, '  categories_allowed:' || char(10) || '    - { name: "Sensitive", except: ["Astral Projection", "Object Read (Psychometry)"] }' || char(10) || '    - { name: "Physical", except: ["Ectoplasm", "Telekinesis"] }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical (excluding Astral Projection, Ectoplasm, Object Read and Telekinesis)',
       '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical, excluding Astral Projection, Ectoplasm, Object Read and Telekinesis - all four held in `except` and enforced, with Object Read spelled as the catalog''s Object Read (Psychometry)'),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical (excluding Astral Projection, Ectoplasm, Object Read and Telekinesis)') > 0
   AND instr(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical, excluding Astral Projection, Ectoplasm, Object Read and Telekinesis - all four held in `except` and enforced, with Object Read spelled as the catalog''s Object Read (Psychometry)') = 0;

-- Readback: both categories now carry an exclusion, all four names are present,
-- and the pool is 47 rather than 51.
SELECT class_id,
       instr(markdown, 'except: ["Astral Projection", "Object Read (Psychometry)"]') > 0 AS sensitive_narrowed,
       instr(markdown, 'except: ["Ectoplasm", "Telekinesis"]') > 0 AS physical_narrowed,
       (SELECT count(*) FROM psionic_powers WHERE category IN ('Sensitive', 'Physical')) AS pool_before,
       (SELECT count(*) FROM psionic_powers WHERE category IN ('Sensitive', 'Physical')
          AND name NOT IN ('Astral Projection', 'Object Read (Psychometry)', 'Ectoplasm', 'Telekinesis'))
         AS pool_after
  FROM imported_classes
 WHERE class_id = 'crazy';

INSERT INTO data_script_runs (filename) VALUES ('fix-crazy-psionic-exclusions.sql');
