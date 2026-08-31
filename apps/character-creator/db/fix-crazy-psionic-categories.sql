-- Point the Crazy's psionic categories at categories the catalog has.
--
-- BOOK-INGEST-AUDIT.md F15, taken in PR #435. The class asked for
-- ["Psychic Sensitive", "Physical Psychic"]; the catalog's five categories are
-- Healing, Phase, Physical, Sensitive and Super. `categories_allowed` gates the
-- picker by exact name, so a Crazy was offered three starting picks from a pool
-- of NOTHING. It is the only class affected - 77 `categories_allowed` entries
-- across all 160 published classes and exactly these two name something that
-- does not exist.
--
-- THE TRANSCRIPTION WAS FAITHFUL, WHICH F15 GETS SLIGHTLY WRONG. The finding
-- calls the names "a longer form" of the book's section headings. They are not
-- a form of anything - Rifts Ultimate Edition printed 55 states the rule in
-- exactly these words: "select three psionic powers from either the Psychic
-- Sensitive or Physical Psychic category". Read off the page, in the block
-- belonging to this class. It is the vocabulary gap `catalog-diff` warns about
-- - the book's word against the catalog's - not a sloppy reading, and the note
-- now carries both so the next person sees why they differ.
--
-- The pool this opens is 51 powers: 29 Sensitive and 22 Physical.
--
-- FOUR OF THOSE FIFTY-ONE ARE FORBIDDEN BY THE SAME SENTENCE AND STILL ARE.
-- The book excludes Astral Projection, Ectoplasm, Object Read and Telekinesis.
-- `psionics` has no exclusion: `powers_from` is a positive list that REPLACES
-- the category gate rather than narrowing it, so the only way to express this
-- today is to enumerate the other forty-seven, which would go stale the moment
-- a Sensitive power is added. The exclusion stays in extraction_notes, where it
-- already was, and is filed as its own finding.
--
-- That gap was moot until now - a class that can pick nothing cannot pick the
-- wrong thing - and this script makes it live. Three picks from 51 where four
-- should be barred is a large improvement on three picks from zero, and saying
-- so is better than leaving the class unplayable to avoid admitting it.

UPDATE imported_classes
   SET markdown = replace(markdown, '  categories_allowed: ["Psychic Sensitive", "Physical Psychic"]',
       '  categories_allowed: ["Sensitive", "Physical"]'),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, '  categories_allowed: ["Psychic Sensitive", "Physical Psychic"]') > 0
   AND instr(markdown, '  categories_allowed: ["Sensitive", "Physical"]') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category',
       '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical'),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category') > 0
   AND instr(markdown, '  - Psionics: "Minor Psionics" - select three psionic powers from either the Psychic Sensitive or Physical Psychic category, which are the catalog''s Sensitive and Physical') = 0;

-- Readback: both names now resolve, and the count is what the catalog actually
-- offers for those two categories.
SELECT class_id,
       instr(markdown, 'categories_allowed: ["Sensitive", "Physical"]') > 0 AS fixed,
       instr(markdown, 'Psychic Sensitive", "Physical Psychic') AS old_names_gone,
       (SELECT count(*) FROM psionic_powers WHERE category IN ('Sensitive', 'Physical'))
         AS powers_now_offered
  FROM imported_classes
 WHERE class_id = 'crazy';

INSERT INTO data_script_runs (filename) VALUES ('fix-crazy-psionic-categories.sql');
