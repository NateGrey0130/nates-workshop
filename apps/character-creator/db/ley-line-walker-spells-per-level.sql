-- Ley Line Walker: the spells it learns as it advances.
--
-- The book: "Automatically learns 2 additional spells per level of experience,
-- equal to or lower than their current level of experience, starting at level 2."
--
-- Two separate facts, and the second is the one that is easy to lose:
--
--   spells_per_level: 2                               how many
--   spells_per_level_levels: up_to_character_level    which
--
-- The cap is STRICTER than the starting selection and disagrees with it on
-- purpose. A fresh Ley Line Walker picks its twelve spells from
-- `spell_levels_allowed: [1, 2, 3, 4]`, but the two it gains at level 2 may
-- only be spell levels 1-2. Reusing the starting list for the per-level picks
-- would quietly let a level-2 walker take a level-4 spell.
--
-- "starting at level 2" needs no key: a per-level grant is earned for every
-- level ABOVE the first, which is levels 2 upward by definition.
--
-- Guarded with instr() and NOT LIKE, because `_` is a single-character WILDCARD
-- in a LIKE pattern: '%spells_per_level%' would also match "spells per level"
-- written as prose in the class body, and the guard would then read as already
-- applied on a class it had never touched.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '  spell_levels_allowed: [1, 2, 3, 4]',
      '  spell_levels_allowed: [1, 2, 3, 4]' || char(10) ||
      '  spells_per_level: 2' || char(10) ||
      '  spells_per_level_levels: up_to_character_level'
    )
WHERE class_id = 'ley-line-walker'
  AND instr(markdown, '  spell_levels_allowed: [1, 2, 3, 4]') > 0
  AND instr(markdown, 'spells_per_level') = 0;

-- Report what the row says now, so the run is verified by reading it back
-- rather than by trusting an exit code.
SELECT class_id,
       instr(markdown, 'spells_per_level: 2') > 0 AS has_count,
       instr(markdown, 'spells_per_level_levels: up_to_character_level') > 0 AS has_cap
FROM imported_classes
WHERE class_id = 'ley-line-walker';

INSERT INTO data_script_runs (filename) VALUES ('ley-line-walker-spells-per-level.sql');
