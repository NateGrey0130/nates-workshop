-- Mystic: the spells and psionic powers it gains as it advances. Rifts
-- "Mystic O.C.C. Magic Powers", bullet 2 "Learning New Spells".
--
-- The book states three different things, and the count is not the only one
-- that varies:
--
--   "At second level of experience the Mystic can select a total of FOUR
--    additional, new, magic spells from levels one, two, and three. Upon
--    reaching third level of experience, the Mystic can select THREE, new,
--    spells from magic levels one through four. At fourth level and each
--    additional level of experience, the Mystic can select TWO additional, new,
--    spells from any of the levels, up to his corresponding experience level.
--    Thus a sixth level Mystic can select two new spells from any of the levels
--    1-6. An eighth level Mystic can select two new magic spells from levels
--    1-8, and so on."
--
--   level 2      4 spells, from spell levels 1-3    <- the character's level + 1
--   level 3      3 spells, from spell levels 1-4    <- the character's level + 1
--   level 4+     2 spells, from spell levels 1-N    <- the character's level
--
-- So the cap is NOT one rule: it is level+1 for the first two grants and level
-- thereafter. That is why levels 2 and 3 carry their own `spell_levels` and the
-- rest fall back to the class-wide `up_to_character_level`.
--
-- "and each additional level of experience" has to be written out, because a
-- schedule is a finite list. It runs to 15, the level cap of the default XP
-- table; a class with its own shorter `xp_table` simply never reaches the tail.
--
-- `spells_starting: 8` and `spell_levels_allowed: [1, 2]` are already correct
-- and untouched - the book's bullet 1 says "At first level select a total of
-- eight spells from the magic spell levels of one and two."
--
-- Guarded with instr() rather than LIKE, because `_` is a single-character
-- wildcard in a LIKE pattern and '%spells_schedule%' would also match the words
-- written as prose.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  spell_levels_allowed: [1, 2]',
      '  spell_levels_allowed: [1, 2]' || char(10) ||
      '  spells_per_level_levels: up_to_character_level' || char(10) ||
      '  spells_schedule:' || char(10) ||
      '    - { level: 2, count: 4, spell_levels: [1, 2, 3] }' || char(10) ||
      '    - { level: 3, count: 3, spell_levels: [1, 2, 3, 4] }' || char(10) ||
      '    - { level: 4, count: 2 }' || char(10) ||
      '    - { level: 5, count: 2 }' || char(10) ||
      '    - { level: 6, count: 2 }' || char(10) ||
      '    - { level: 7, count: 2 }' || char(10) ||
      '    - { level: 8, count: 2 }' || char(10) ||
      '    - { level: 9, count: 2 }' || char(10) ||
      '    - { level: 10, count: 2 }' || char(10) ||
      '    - { level: 11, count: 2 }' || char(10) ||
      '    - { level: 12, count: 2 }' || char(10) ||
      '    - { level: 13, count: 2 }' || char(10) ||
      '    - { level: 14, count: 2 }' || char(10) ||
      '    - { level: 15, count: 2 }'
    )
WHERE class_id = 'mystic'
  AND instr(markdown, '  spell_levels_allowed: [1, 2]') > 0
  AND instr(markdown, 'spells_schedule') = 0;

-- Read it back rather than trusting an exit code.
SELECT class_id,
       instr(markdown, 'spells_schedule') > 0 AS has_schedule,
       instr(markdown, 'level: 2, count: 4, spell_levels: [1, 2, 3]') > 0 AS has_level2,
       instr(markdown, 'level: 15, count: 2') > 0 AS has_tail,
       instr(markdown, 'spells_per_level_levels: up_to_character_level') > 0 AS has_fallback
FROM imported_classes
WHERE class_id = 'mystic';

-- ---------------------------------------------------------------------------
-- Bullet 4 on the same page, "Additional Psychic Abilities Include":
--
--   "Select three additional psychic abilities from the Sensitive category and
--    another two from the Healer category. At levels four and eight the Mystic
--    can select one additional ability from the Super category."
--
-- The starting five are already right (powers_starting: 5, categories_allowed
-- Sensitive + Healing). What is new is that the level 4 and 8 powers come from
-- SUPER - a category a MAJOR psychic cannot otherwise take, since tier is
-- enforced by category here. The grant naming it is the book granting the
-- exception, which is why a grant's categories REPLACE the class's rather than
-- narrowing them.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  categories_allowed: ["Sensitive", "Healing"]',
      '  categories_allowed: ["Sensitive", "Healing"]' || char(10) ||
      '  powers_schedule:' || char(10) ||
      '    - { level: 4, count: 1, categories: ["Super"] }' || char(10) ||
      '    - { level: 8, count: 1, categories: ["Super"] }'
    )
WHERE class_id = 'mystic'
  AND instr(markdown, '  categories_allowed: ["Sensitive", "Healing"]') > 0
  AND instr(markdown, 'powers_schedule') = 0;

SELECT class_id,
       instr(markdown, 'powers_schedule') > 0 AS has_psi_schedule,
       instr(markdown, 'level: 4, count: 1, categories: ["Super"]') > 0 AS has_level4,
       instr(markdown, 'level: 8, count: 1, categories: ["Super"]') > 0 AS has_level8
FROM imported_classes
WHERE class_id = 'mystic';

INSERT INTO data_script_runs (filename) VALUES ('mystic-spells-per-level.sql');
