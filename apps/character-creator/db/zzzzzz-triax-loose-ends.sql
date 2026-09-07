-- Triax loose ends: the two re-citations, the pump-weapon page range, and the
-- Gargoylite ladder note that is no longer true.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-triax-loose-ends.sql
--
-- FOUR CORRECTIONS, all of them things the triax survey's extraction plan asked
-- for and none of which the six class batches did.
--
-- SORTS LAST ON PURPOSE. Every row touched here is written by something else
-- earlier in the glob: zzz-gear-tidy-2-stub-stats.sql rewrites gear.source_book,
-- the zzzz-cite-* tier writes skill citations, and add-gargoylite-class.sql
-- creates the class. Checked against the directory rather than assumed - this
-- name sorts after zzzzzz-ingestion-f34-gas-mask-bundle.sql, which was the last
-- file before it.
--
-- (1) Streetwise: Drugs is cited to the PHANTOM "Rifts Skill List", which is not
-- a book and is not cached - see the rifts-skill-list rows in
-- scripts/source-coverage.mjs. Triax printed 155 prints it under the book's own
-- New Skills section ("Streetwise - Drugs: The following additional street
-- knowledge..."), and that is the earliest real printing on this machine. This
-- takes rifts-skill-list from 43 untraceable rows to 42.
--
-- (2) Horsemanship: Exotic Animals has NO source_book at all. RUE printed 302
-- lists it as "Horsemanship: Exotic Animals (30%/20%+5%)" - verified in the rue
-- cache, printed 302 = cache p305 at the registry's +3 offset - which is where
-- the catalog's 30 +5 comes from. Triax printed 155 prints the same skill at
-- "30% +4% per level", a DIFFERENT per-level figure. RUE is the later book and
-- the catalog is already right, so the citation goes to RUE and the Triax
-- variant goes in the note rather than changing the row. The catalog holds the
-- 30% ride figure; RUE's paired 20% care figure has no column and is noted too.
--
-- (3) triax-pump-weapon carries the bare title "Triax & The NGR" with no page
-- range, which is this book's only row in source-coverage's "other" bucket. The
-- book describes TWO pump weapons - the TX-5 Pump Pistol on printed 143 and the
-- TX-16 Pump Rifle on printed 144 - and this row is a PLACEHOLDER standing for
-- both, referenced by the ten Warlock classes. The page range covers both.
-- IT STAYS A GEAR STUB: the description keeps its STUB marker, because the row
-- still has no stats and the gear importer keys on that marker. Replacing the
-- placeholder with two real rows and a choice group is gear-batch work and is
-- recorded in the queue, not done here.
--
-- (4) The Gargoylite's extraction note says its borrowed experience table is
-- unresolved. It was, for one day. RUE settles it: the Dog Pack IS the Dog Boy.
-- A note that records a resolved question as open is the shape the class-import
-- skill warns about - it is durable, and the next session believes it.
--
-- Every write is guarded on the text it replaces, so re-running is a no-op, and
-- every one is keyed on name, slug or class_id rather than on a literal id.

UPDATE skills
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.155',
       note = 'Printed in the New Skills section of Rifts World Book 5, which is the earliest real printing of this skill on this machine. It was previously cited to the phantom Rifts Skill List, which is not a book.'
 WHERE name = 'Streetwise: Drugs' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Ultimate Edition p.302',
       note = 'RUE p.302 prints this as 30%/20% +5% - the catalog holds the 30% riding figure and the 20% animal-care figure has no column. Rifts World Book 5: Triax and the NGR p.155 reprints the skill at 30% +4% per level, a lower per-level step; RUE is the later book, so the catalog follows RUE and the Triax figure is recorded here as the variant.'
 WHERE name = 'Horsemanship: Exotic Animals' AND source_book IS NULL;

UPDATE gear
   SET source_book = 'Rifts World Book 5: Triax and the NGR p.143-144'
 WHERE slug = 'triax-pump-weapon' AND source_book = 'Triax & The NGR';

UPDATE imported_classes
   SET markdown = replace(markdown, '  - ITS EXPERIENCE LADDER IS THE ONE THING IN THIS BATCH THAT DOES NOT RESOLVE,' || char(10) || '    AND IT IS UNRESOLVED ON THE CATALOG''S SIDE RATHER THAN THE BOOK''S. Printed' || char(10) || '    202 says player characters use the same experience table as the DOG PACK.' || char(10) || '    There is no row named Dog Pack in this catalog; the nearest is `dog-boy`' || char(10) || '    (Dog Boy). Whether Rifts prints the Dog Pack ladder as the Dog Boy''s is a' || char(10) || '    question to settle from RUE, and it is NOT an equivalence to assume from' || char(10) || '    the names - the survey flagged it before the import and it is still open.' || char(10) || '    Nothing is stored either way: a Rifts class carries no `xp_table` here, so' || char(10) || '    the question costs nothing today and would cost something the moment' || char(10) || '    anything reads a ladder for this class.', '  - ITS EXPERIENCE LADDER SAYS "DOG PACK" AND THAT IS THE DOG BOY. Printed 202' || char(10) || '    says player characters use the same experience table as the Dog Pack, and' || char(10) || '    the survey left this open because no catalog row carries that name and an' || char(10) || '    equivalence must not be assumed from two names that merely look alike.' || char(10) || '    SETTLED 2026-09-07 from RUE, which is where the survey said to settle it.' || char(10) || '    RUE names the class "Dog Boys (Coalition Dog Pack - Mutant Canines)" in its' || char(10) || '    own O.C.C. list, and its contents page files "Coalition Dog Pack" as a' || char(10) || '    section INSIDE the Dog Boy O.C.C. - the pack is the unit, the Dog Boy is' || char(10) || '    the class. So the borrowed ladder is `dog-boy`''s, which RUE printed 295' || char(10) || '    heads "CS Grunt & Dog Boys" and shares with `coalition-grunt`. Both rows' || char(10) || '    are published here.' || char(10) || '    Nothing is stored either way: a Rifts class carries no `xp_table` here, so' || char(10) || '    this was never a defect - it was a citation nobody could follow, and now it' || char(10) || '    can be.')
 WHERE class_id = 'gargoylite' AND instr(markdown, 'the names - the survey flagged it before the import and it is still open.') > 0;

-- Read the results back rather than trusting the exit code. Separate statements
-- rather than a compound SELECT: D1 caps a compound SELECT below six terms.
SELECT name, source_book, note FROM skills
 WHERE name IN ('Streetwise: Drugs', 'Horsemanship: Exotic Animals') ORDER BY name;

SELECT slug, source_book, description FROM gear WHERE slug = 'triax-pump-weapon';

SELECT 'the gargoylite ladder note is resolved' AS assertion,
       instr(markdown, 'SETTLED 2026-09-07 from RUE') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'gargoylite';

SELECT 'and the open-question wording is gone' AS assertion,
       instr(markdown, 'it is still open') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'gargoylite';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-triax-loose-ends.sql');
