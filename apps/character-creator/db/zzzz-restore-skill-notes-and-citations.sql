-- The skill notes and citations a rebuild loses - and the eleven differences
-- that are NOT losses (REBUILD-AUDIT.md F14, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-skill-notes-and-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-skill-notes-and-citations.sql
--
-- F14 said this one is NOT mechanical and must not be taken as if it were.
-- Reading all 37 differences bore that out: 26 are losses and 11 are not, and
-- three of the 37 could only be settled by opening the book.
--
-- WHAT IS EXPORTED (26 values, 22 skills), all of them production being richer
-- or righter than a rebuild:
--
--   note (14)         Nine rows where a rebuild has NULL and production has a
--                     Palladium Fantasy conversion - "Palladium Fantasy: 30%
--                     +5% per level" on Cook, Fishing, First Aid and the rest -
--                     and five where production is the rebuild's own note plus
--                     an appended PF clause (Surveillance, Play Musical
--                     Instrument, Interrogation Techniques, Brewing, Breed
--                     Dogs). Strictly additive in every case.
--
--   source_book (9)   Seven where a rebuild cites nothing at all, plus two
--                     where it cites the WRONG place and the book settles it:
--
--                       SCUBA   a rebuild says RUE p.302-303. Printed 302 is
--                               the Physical skill LIST - "Swimming (50%+5%) /
--                               SCUBA (50%+5%) / Wrestling". The entry with the
--                               description is on printed 317, which is what
--                               production cites. Production is right.
--
--                       Botany  a rebuild says "Rifts Skill List", which is a
--                               fan-compiled index and not a book at all (F16).
--                               Production cites RUE p.322. This removes one
--                               row from the 48 that cite that compilation.
--
--   base, per_level   Horsemanship: General. A rebuild says 35% +5%.
--   (2)               RUE printed 311 says, in as many words: "Base Skill:
--                     40%/20% +4% per level of experience." Production's 40 and
--                     4 are the book's. THIS IS A RULES CORRECTION, not a
--                     citation one, and it is the only one here.
--
--   level_bonuses (1) W.P. Targeting. A rebuild has NULL.
--
-- WHAT IS DELIBERATELY NOT EXPORTED (11), because production is not righter:
--
--   source (8)        `manual` or `import` live against `seed` or
--                     `palladium-fantasy-core` in a rebuild. This column
--                     records HOW A ROW GOT THERE, not what it is, and a
--                     rebuild saying `seed` is telling the truth about itself.
--                     Same argument that excluded `created_by` from
--                     repo-vs-live.mjs under F12. Exporting it would write
--                     "this row was typed in by hand" into a row no hand
--                     touched.
--
--   Gymnastics and    Production reads "RUE p.302 lists varies Also +1D6
--   Acrobatics        S.D.C." and a rebuild reads "Also +1D6 S.D.C.; RUE p.302
--   (note, 2)         lists varies" - the same two facts, reordered, and the
--                     rebuild's is the one with punctuation between them.
--                     Exporting would make the repo worse to close a diff.
--
--   W.P. Targeting    Production cites "Palladium Fantasy RPG Main Book p.84";
--   (source_book, 1)  a rebuild cites "Rifts Ultimate Edition". PF printed 84
--                     lists the skill inside an O.C.C.'s skill list rather than
--                     defining it, and the skill appears in RUE as well. Both
--                     citations are defensible and neither is the entry. LEFT
--                     ALONE ON PURPOSE: picking one without reading both books
--                     properly is how a wrong citation becomes a permanent one.
--
-- So this file closes 26 of 37 and leaves 11 standing, 8 of them correctly.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after rename-skills-to-rue.sql,
-- which renames rows it matches by name, and after the zzzz-cite-* files, which
-- rewrite source_book on skills. `zzzz-restore-s` sorts after `zzzz-restore-p`.
--
-- Every statement targets one name and sets absolute values, so it is safe to
-- re-run and safe to run early: on production every value below is already the
-- value in the row.

UPDATE skills SET
      base = 40,
      per_level = 4,
      source_book = 'Rifts Ultimate Edition p.311'
  WHERE name = 'Horsemanship: General';

UPDATE skills SET
      note = 'Requires: Electronics: Basic or Electrical Engineering, and Computer Operation and Literacy (latter two needed only for complex, high-tech systems); Palladium Fantasy: 25% +5% per level'
  WHERE name = 'Surveillance';

UPDATE skills SET
      note = 'Palladium Fantasy: 30% +5% per level'
  WHERE name = 'Cook';

UPDATE skills SET
      note = 'Palladium Fantasy: 30% +5% per level'
  WHERE name = 'Fishing';

UPDATE skills SET
      note = 'Each specific instrument requires separate selection of this skill; Palladium Fantasy: 25% +5% per level'
  WHERE name = 'Play Musical Instrument';

UPDATE skills SET
      note = 'Palladium Fantasy: 30% +5% per level'
  WHERE name = 'First Aid';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Assassin';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Basic';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.316'
  WHERE name = 'Hand to Hand: Martial Arts';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.317',
      note = 'Requires swimming skill'
  WHERE name = 'SCUBA';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition'
  WHERE name = 'Robot Combat: Basic';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.322'
  WHERE name = 'Botany';

UPDATE skills SET
      level_bonuses = '[{"level":1,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":1,"note":"Sling, slingshot, boomerangs, shurikens, throwing knives, sticks, small axes and spears, even siege weapons - but not bows, crossbows or guns. Requires any one W.P. for a missile weapon. Stacks with that W.P. Can throw two small items at one target simultaneously. All bonuses lost and rate of fire halved when running, flying, riding or shooting from a moving vehicle."},{"level":3,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":7,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}},{"level":10,"applies_when":"with a thrown or projectile weapon","combat":{"strike":1}}]'
  WHERE name = 'W.P. Targeting';

UPDATE skills SET
      source_book = 'Palladium Fantasy RPG 2nd Ed.',
      note = 'RUE p.302 lists 88%+1%'
  WHERE name = 'Language: Native Tongue';

UPDATE skills SET
      note = 'base transcribed from memory - verify against the book; Palladium Fantasy: 20% +5% per level; Possible duplicate of Interrogation (Espionage); Juicer Uprising p.64 files this skill under Espionage'
  WHERE name = 'Interrogation Techniques';

UPDATE skills SET
      note = 'base transcribed from memory - verify against the book; Palladium Fantasy: 25%, no per-level gain'
  WHERE name = 'Brewing';

UPDATE skills SET
      note = 'Palladium Fantasy: 30% +5% per level'
  WHERE name = 'Sing';

UPDATE skills SET
      source_book = 'Rifts Ultimate Edition p.302-303'
  WHERE name = 'Hand to Hand: Commando';

UPDATE skills SET
      note = 'Juicer Uprising p.66 lists 30%+4%'
  WHERE name = 'Gambling (Standard)';

UPDATE skills SET
      note = '40%/20%+5%; Palladium Fantasy: 40%, no per-level gain'
  WHERE name = 'Breed Dogs';

UPDATE skills SET
      note = 'Palladium Fantasy: 30% +5% per level'
  WHERE name = 'Masonry';

UPDATE skills SET
      note = 'Palladium Fantasy: 15% +5% per level'
  WHERE name = 'Locate Secret Compartments';

-- Reads the result back rather than trusting the exit code.
--   horsemanship_base       40 = the book's figure, RUE printed 311. It was 35.
--   horsemanship_per_level   4 = likewise. It was 5.
--   skills_with_pf_note     15 = skills carrying a Palladium Fantasy conversion
--                           in their note. PRODUCTION'S OWN FIGURE, and not the
--                           26 above: 26 is the number of VALUES this file
--                           writes, across 22 skills and four columns. Fifteen
--                           of those skills end up with a PF note.
--   botany_cites_the_list    0 = Botany no longer cites the compiled skill list
--                           (F16). One row off that 48.
SELECT (SELECT base FROM skills WHERE name = 'Horsemanship: General') AS horsemanship_base,
       (SELECT per_level FROM skills WHERE name = 'Horsemanship: General') AS horsemanship_per_level,
       (SELECT count(*) FROM skills WHERE instr(note, 'Palladium Fantasy:') > 0) AS skills_with_pf_note,
       (SELECT count(*) FROM skills WHERE name = 'Botany' AND source_book = 'Rifts Skill List') AS botany_cites_the_list;

-- Records this run. One row per run rather than per file: the statements above
-- set absolute values, so this script is safe to re-run, and a run that
-- correctly changed nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-skill-notes-and-citations.sql');
