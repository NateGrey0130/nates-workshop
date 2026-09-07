-- Four skill rows get a real page: the New Skills section at Triax printed 155.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-triax-skill-citations.sql
--
-- TWO OF THESE CITED A BOOK THAT DOES NOT EXIST. 'Rifts Skill List' is not a
-- publication - it is the label 42 skill rows carry in place of a source, and
-- source-coverage scores every one of them 'other' because no cached book
-- answers to that name. Two of the 42 are printed on a page this machine has.
--
-- THE OTHER TWO CITED NOTHING AT ALL, which the ledger cannot even see: it
-- reports an absent citation, never a wrong one.
--
-- WHAT THE PAGE SAYS, read from .cache/books/triax/txt/p155.txt (page_offset 0,
-- so printed 155 is p155.txt, and the folio 155 is printed on the page):
--
--   Basic Mechanics ............ "Base Skill: 30% +5% per level of experience."
--   Lore - Magic ............... "Base Skill (general knowledge): 25% +5% per
--                                 level of experience."
--   Recognize wards, runes and circles ..... "15% +5% per level of experience."
--   Recognize Enchantment .................. "10% +5% per level of experience."
--
-- EVERY ONE OF THE FOUR MATCHES THE CATALOG'S STORED base AND per_level
-- EXACTLY - 30/5, 25/5, 15/5, 10/5. That agreement is the evidence the page is
-- really the source, and it is why these four were taken and the other 38 were
-- not: nothing else in the cached corpus produced a definition whose numbers
-- match the row.
--
-- BASIC MECHANICS CARRIED A NOTE ASKING FOR EXACTLY THIS. It reads "base
-- transcribed from memory - verify against the book". It has now been verified
-- against the book, and it says 30% +5%, so the note is cleared rather than
-- left standing over a number somebody has since checked.
--
-- THE LAST TWO ARE SUB-ABILITIES, NOT FREE-STANDING SKILLS, and the catalog
-- files them as their own rows anyway. Printed 155 lists them under Lore -
-- Magic: "The following abilities come with this layman's skill". The rows are
-- not changed to reflect that - splitting or merging them is a different
-- decision from citing them - but the citation now points at the page where a
-- reader will find them described that way.
--
-- TRIAX IS NOT NECESSARILY THE EARLIEST PRINTING, and this script does not
-- claim it is. Palladium Fantasy prints the same two sub-abilities in the same
-- shape at its own printed 61 ("Recognize magic wards, runes and circles:
-- 15%+5% ... Recognize enchantment ... 10%+5%"), and four skill rows already
-- cite that book. What source-coverage asks of a citation is that it resolve to
-- a real cached page, which this does; if the convention is ever tightened to
-- EARLIEST printing, these two are the rows to revisit and pf p.61 is the
-- candidate. Written down so that question is not re-derived from scratch.
--
-- Each UPDATE is guarded on the WRONG value still being present, so re-running
-- is a no-op and none of them can overwrite a citation somebody has since
-- corrected by hand.

UPDATE skills
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.155',
       note = NULL
 WHERE name = 'Basic Mechanics'
   AND source_book IS NULL;

UPDATE skills
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.155'
 WHERE name = 'Lore: Magic'
   AND source_book IS NULL;

UPDATE skills
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.155'
 WHERE name = 'Recognize Enchantment'
   AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.155'
 WHERE name = 'Recognize Wards, Runes & Circles'
   AND source_book = 'Rifts Skill List';

-- Read the result back rather than trusting the exit code.
SELECT 'all four now cite Triax printed 155' AS assertion,
       count(*) AS got, 4 AS want
  FROM skills
 WHERE source_book = 'Rifts World Book 5: Triax and the NGR p.155'
   AND name IN ('Basic Mechanics', 'Lore: Magic', 'Recognize Enchantment',
                'Recognize Wards, Runes & Circles');

SELECT 'and none of the four still names the non-book' AS assertion,
       count(*) AS got, 0 AS want
  FROM skills
 WHERE source_book = 'Rifts Skill List'
   AND name IN ('Basic Mechanics', 'Lore: Magic', 'Recognize Enchantment',
                'Recognize Wards, Runes & Circles');

-- REPORTED, NOT ASSERTED. How many rows still name the non-book is a property
-- of the environment, not of this script: production held 42 before this ran
-- and local held 40, because local D1 drifts from production in both
-- directions. A `want` here would fail in one environment while the script was
-- working perfectly in it. The assertion above is the one that holds anywhere.
SELECT 'rows still citing the non-book, for information only' AS observation,
       count(*) AS remaining
  FROM skills WHERE source_book = 'Rifts Skill List';

SELECT 'and the stale verify-against-the-book note is cleared' AS assertion,
       coalesce(note, 'cleared') AS got, 'cleared' AS want
  FROM skills WHERE name = 'Basic Mechanics';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-triax-skill-citations.sql');
