-- Six skills that cite "Rifts Skill List" are printed in Rifts World Book 7:
-- Underseas. Move the citation to the book and the page.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzz-recite-underseas-skills.sql
--
-- "Rifts Skill List" is a one-page skill sheet, not a book. source-coverage
-- reports every row citing it as untraceable, and always will: there is no PDF
-- to cache, so those rows are permanently uncheckable. Caching it would make
-- the ledger lie rather than fix anything. The only real fix is finding the
-- book each row actually came from, one book at a time as they are cached.
-- zzzzz-recite-phase-world-skills.sql took eight of them; this takes six more.
--
-- The evidence is that the numbers agree exactly - same category, same base,
-- same per-level step - across six rows read independently off the Underseas
-- OCR cache:
--
--   catalog row                     Underseas prints           page  values
--   Submersible Vehicle Mechanics   same name, Mechanical:      210  25 +5 agree
--   Ocean Geographic Surveying      same name, Science:         211  15 +5 agree
--   Undersea Farming                same name, Science:         211  35 +5 agree
--   Undersea & Sea Survival         Undersea & Sea Survival     212  25 +5 agree
--   Boat: Submersibles              Pilot Submersibles          212  40 +4 agree
--   Navigation: Underwater          Underwater Navigation       212  30 +4 agree
--
-- Six for six on every value is the argument. A single agreeing row would be a
-- coincidence; six read off one chapter is the chapter.
--
-- THE ACTION IS RE-CITATION AND NEVER A RENAME. Characters reference skills by
-- NAME, so renaming Boat: Submersibles to the book's Pilot Submersibles would
-- strand every character and every class restriction naming the old string -
-- and an unmatched `except` fails OPEN, so a class would silently start
-- offering a skill its book forbids. Renaming is duplicate-tool work that
-- writes redirects and rewrites characters; SQL cannot do it safely.
--
-- So: source_book moves, name does not, and every value stays exactly where it
-- was. The book's own spelling goes in the note.
--
-- ONE CATEGORY DISAGREEMENT, recorded and not applied. Underseas files
-- Underwater Navigation under WILDERNESS; the catalog holds Navigation:
-- Underwater as Pilot Related. The values agree, so the book and the catalog
-- disagree about filing rather than about the skill - and the same printed
-- page carries a Pilot Related: Navigation Note saying that surface and
-- submersible navigation are aspects of the standard navigation skill, which
-- argues FOR the catalog's placement. Pilot Related stands.
--
-- ONE NEAR-DUPLICATE NOTICED AND NOT TOUCHED. The catalog holds TWO rows for
-- the submersible-piloting skill: Boat: Submersibles (this one) and Military:
-- Submersibles, citing RUE p.302-303, both Pilot 40% +4%. Underseas prints it
-- once. Merging them is duplicate-tool work for the same reason a rename is,
-- and picking which name survives is a catalog decision rather than a reading
-- of this book. Recorded in the survey and in BOOK-INGEST-QUEUE.md, NOT filed
-- as an audit finding: that menu holds deferred CODE changes, and this is a
-- catalog decision. Same handling as W.P. Rope.
--
-- WHY THIS FILE SORTS LAST. A clean rebuild applies apps/character-creator/db/
-- *.sql as one sorted glob, so filename order IS execution order, and these
-- six rows do not exist until add-rifts-skill-list-gaps.sql has run. Put these
-- updates in an add- file and they would match zero rows on a rebuild and be
-- silently undone, which is the fix-long-bowman-armor.sql failure exactly.
-- Checked against the directory as it stands: this name sorts after every
-- add-, backfill-, fix-, zz-, zzz- and zzzz- file, and after
-- zzzzz-recite-phase-world-skills.sql, which touches none of these rows.
--
-- Guarded on the old citation still being present, so re-running is a no-op
-- and a row someone has already re-cited by hand is left alone.

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.210',
       note = 'Printed under Mechanical:. Diagnosis and repair of submersible vehicles - submarines, underwater robots, probes and stations. Mechanical engineers can also make these repairs at -15%; aircraft mechanics at -40%.'
 WHERE name = 'Submersible Vehicle Mechanics' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.211',
       note = 'Printed under Science:. Identifying natural undersea formations, wreckage and sunken cities, Earth minerals, earthquake damage and zones, plus depth determination, map making and map reading, and basic geology and oceanography. +15% to read maps.'
 WHERE name = 'Ocean Geographic Surveying' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.211',
       note = 'Printed under Science:. Cultivating undersea plants and algae and breeding aquatic animals for harvest - hydroponic and sea-floor crops, lobster farms, oyster beds and fish hatcheries.'
 WHERE name = 'Undersea Farming' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.212',
       note = 'Printed under Wilderness:. Surviving underwater or lost at sea on the surface - which sea life is edible and easiest to catch, improvised hooks and lines, predators to avoid, sun protection, and rationing. The book offers this as part of the standard Wilderness Survival skill at the GM''s option, especially for Navy men, sailors, pirates, sea druids, ocean wizards and aquatic D-bees.'
 WHERE name = 'Undersea & Sea Survival' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.212',
       note = 'Printed as Pilot Submersibles, under Pilot Skills. All types of submersible - underwater sleds, mini-subs and most submarines including military ones. -20% with alien or unusual submarines. Does NOT include power armor or deep sea diving suits, which are separate skills.'
 WHERE name = 'Boat: Submersibles' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts World Book 7: Underseas p.212',
       note = 'Printed as Underwater Navigation, and the book files it under WILDERNESS rather than Pilot Related. The catalog''s placement stands - the same printed page carries a Pilot Related: Navigation Note making surface and submersible navigation aspects of the standard navigation skill, and a category change moves which classes can offer the row. The deep sea version of land navigation: undersea landmarks, currents, tides, time of day, sounds, surface landmarks and star positions. Roll once per ten miles travelled; a failed roll drifts 1D6x100 yards off course, and consecutive failures go unnoticed.'
 WHERE name = 'Navigation: Underwater' AND source_book = 'Rifts Skill List';

-- Read the result back. One SELECT with IN rather than a UNION: D1 rejects a
-- compound SELECT past five terms and rolls the whole file back.
SELECT name, source_book FROM skills
 WHERE name IN ('Submersible Vehicle Mechanics', 'Ocean Geographic Surveying',
                'Undersea Farming', 'Undersea & Sea Survival',
                'Boat: Submersibles', 'Navigation: Underwater')
 ORDER BY name;
SELECT COUNT(*) AS still_citing_the_sheet FROM skills WHERE source_book = 'Rifts Skill List';

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-recite-underseas-skills.sql');
