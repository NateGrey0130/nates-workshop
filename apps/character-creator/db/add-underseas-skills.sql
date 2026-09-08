-- The eight skills Rifts World Book 7: Underseas adds that the catalog does
-- not already hold under any name.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-underseas-skills.sql
--
-- The book is a SCAN with no text layer; every value below was read off the
-- OCR cache under scripts/books.json's recorded offset for this book, which is
-- -1 with an exception putting printed 1-130 at +0. The whole skills chapter
-- sits past the split, so printed 210 is cache p209, printed 211 is p210 and
-- printed 212 is p211. The chapter prints each percentage exactly once, in the
-- skill's own entry, so there is no second reading to reconcile against - but
-- see the re-provenance note below, which supplies six of them after the fact.
--
-- EIGHT, not nineteen. Printed 210 lists twenty-two entries. THREE of them are
-- rules notes rather than skills - Pilot Related: Navigation Note, Power Armor
-- Skill Note and Swimming & Fatigue Note - and define nothing to store. Of the
-- nineteen real skills, ELEVEN are already in the catalog:
--
--   book prints (printed page)        catalog holds                   action
--   Ocean Geographic Surveying (211)  same name, 15% +5%, Science     re-cite
--   Submersible Vehicle Mechanics(210) same name, 25% +5%, Mechanical re-cite
--   Undersea Farming (211)            same name, 35% +5%, Science     re-cite
--   Undersea & Sea Survival (212)     same name, 25% +5%, Wilderness  re-cite
--   Pilot Submersibles (212)          Boat: Submersibles, 40% +4%     re-cite
--   Underwater Navigation (212)       Navigation: Underwater, 30% +4% re-cite
--   Water Scooters (212)              same name, RUE                  leave
--   Water Skiing & Surfing (212)      same name, RUE                  leave
--   Warships/Patrol Boats (212)       Military: Warships & Patrol...  leave
--   Underwater Demolitions (210)      Demolitions: Underwater, RUE    leave
--   W.P. Harpoon Gun (212)            W.P. Harpoon & Spear Gun, RUE   leave
--
-- The six marked re-cite are handled by zzzzz-recite-underseas-skills.sql,
-- which sorts after this file and after everything that creates them. They are
-- a CITATION change, never a rename: all six agree with this book on category,
-- base and per-level, which is six independent confirmations that the chapter
-- was read correctly.
--
-- THREE THE BOOK PRINTS THAT ARE DELIBERATELY NOT HERE, each because the
-- catalog's existing row is the later book's and wins under the standard rule.
-- All three readings are recorded so the disagreement is on the record rather
-- than lost:
--
--   Underwater Demolitions - printed 210 gives 56% +3% per level. The catalog
--   row Demolitions: Underwater cites RUE p.302-303 at 56% +4%. Same base,
--   different step. RUE is later; the catalog is left alone.
--
--   W.P. Harpoon Gun - printed 212 gives +1 to strike at levels two, four,
--   seven, ten and THIRTEEN. The catalog row W.P. Harpoon & Spear Gun cites
--   RUE and gives the same schedule with FIFTEEN as the last step. RUE is
--   later; the catalog is left alone.
--
--   Underwater Navigation - printed 212 files it under Wilderness; the catalog
--   has Navigation: Underwater under Pilot Related. NOT changed, and not
--   because of book order: printed 212 also carries a Pilot Related:
--   Navigation Note saying surface and submersible navigation are aspects of
--   the standard navigation skill, which argues FOR the catalog's placement.
--   Moving a category silently changes which classes can take the skill.
--
-- ADVANCED DEEP SEA DIVING HAS NO STARTING PERCENTAGE THIS COLUMN CAN HOLD.
-- Printed 212 describes what the skill covers - diving suits, tethered pods,
-- light to medium power armor, not combat models - and gives no base and no
-- per-level step at all. This is the book rather than the OCR: the paragraph
-- reads clean start to finish and ends on a complete sentence. The row carries
-- base 0 and the omission is in its note. That 0 is NOT the 0 the schema
-- comment describes - it does not mean non-percentile the way a W.P.'s does.
-- NOT filed as an audit finding, and the distinction matters: this is not a
-- shape the schema cannot hold, it is a number the BOOK does not print.
-- base_formula, added for BOOK-INGEST-AUDIT F2, does not help - there is no
-- formula either. Do not "fix" it by inventing a number; it is recorded in
-- the row's note and in the survey.
--
-- TWO ROWS CARRY A SPLIT PERCENTAGE. Marine Biology and Track & Hunt Sea
-- Animals are both printed as two numbers - 35%/25% - where the second is a
-- narrower application of the same skill. base takes the general figure and
-- note carries the split, which is the convention Undersea & Sea Survival
-- already uses in this catalog.
--
-- NAMING. The book heads its entries with a category prefix (Technical:,
-- Science:, Wilderness:) which is the category column here, not part of the
-- name. Pilot skills store WITHOUT a Pilot: prefix per the class-import rules.

INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Advanced Fishing', 'Technical', 30, 5,
 'Commercial fishing rather than the recreational sport the standard Fishing skill covers: nets, cages, trolling, explosives and harpoon guns, plus baiting, cleaning, preserving and transporting a mass catch to market. -15% when dealing with alien creatures and mutants.',
 'import', 'Rifts World Book 7: Underseas p.211'),
('Marine Biology', 'Science', 35, 5,
 'BASE IS THE FIRST OF TWO NUMBERS. The book prints 35%/25% +5% per level: 35% is general knowledge of ocean ecology, habitats, tides, water composition and plant life; 25% is the specific medical and scientific application - antidotes to sea-creature poisons, capturing animals alive (+10% to hunt/kill), surgery on sea animals only (-60% on humanoids), and the care and treatment of marine mammals. -30% when dealing with alien and mutant life forms. Requires Biology, Advanced Mathematics and Chemistry.',
 'import', 'Rifts World Book 7: Underseas p.212'),
('Sea Holistic Medicine', 'Medical', 20, 5,
 'Natural medicines derived from aquatic plants, seaweed and animals - ink, blood, poisons and other secretions - including where to find them and how to extract them. Otherwise the same as the standard Holistic Medicine skill, and the two do NOT overlap: the standard skill excludes ocean-derived medicines and this one excludes all but a handful of the most common land herbs. A failed roll means the treatment or concoction did not work.',
 'import', 'Rifts World Book 7: Underseas p.210'),
('Track & Hunt Sea Animals', 'Wilderness', 35, 5,
 'BASE IS THE FIRST OF TWO NUMBERS. The book prints 35%/25% +5% per level: 35% is general knowledge of undersea habitats, what lives in them, what those animals eat, migration patterns and useful seaweed; 25% is the ability to locate and capture a specific creature. -20% when dealing with mutants and alien creatures. NOT the same row as Track & Trap Animals, which is the land skill.',
 'import', 'Rifts World Book 7: Underseas p.212'),
('Undersea Salvage', 'Technical', 30, 5,
 'Locating, identifying, retrieving, evaluating, restoring and selling underwater wreckage - ships, armor, weapons, E-clips, magic items, precious metals and scrap. Includes underwater cutting tools, cranes, pulleys and tow lines, and rudimentary undersea mining and gathering. +5% if the character is a mechanical engineer, who can also salvage working parts, make repairs and raise small sunken craft.',
 'import', 'Rifts World Book 7: Underseas p.211-212'),
('Advanced Deep Sea Diving', 'Pilot', 0, 0,
 'BASE IS NOT ZERO AND PER-LEVEL IS NOT ZERO: the book states neither. Printed 212 describes the skill and gives no percentage at all, so there is nothing to store - not a schema gap, a gap in the book. Methods, techniques and equipment for deep sea diving and exploration, including most diving suits, tethered diving pods, and light to medium power armor. Does NOT include combat models.',
 'import', 'Rifts World Book 7: Underseas p.212'),
('W.P. Torpedo', 'Weapon Proficiencies', 0, 0,
 NULL, 'import', 'Rifts World Book 7: Underseas p.212'),
('W.P. Trident', 'Weapon Proficiencies', 0, 0,
 NULL, 'import', 'Rifts World Book 7: Underseas p.212')
ON CONFLICT(name) DO NOTHING;

-- The two new W.P.s carry their bonus schedules in level_bonuses, the same
-- shape W.P. Harpoon & Spear Gun and W.P. Spear already use. The trident's
-- "catch or pin" bonus is NOT a combat key: sheet.js draws a closed list of
-- combat fields and an invented key would store, validate, compose and render
-- nowhere. It goes in a per-level note instead, which is where W.P. Blunt puts
-- the equivalent.
UPDATE skills SET level_bonuses = '[{"level":1,"note":"Maintenance and a keen understanding of a torpedo''s speed, range, trajectory and most effective use."},{"level":2,"applies_when":"with a torpedo","combat":{"strike":1}},{"level":4,"applies_when":"with a depth charge","combat":{"strike":1}},{"level":6,"applies_when":"with a torpedo","combat":{"strike":1}},{"level":12,"applies_when":"with a torpedo","combat":{"strike":1}}]'
 WHERE name = 'W.P. Torpedo' AND level_bonuses IS NULL;

UPDATE skills SET level_bonuses = '[{"level":1,"applies_when":"with a trident","combat":{"strike":1,"parry":1}},{"level":1,"note":"Typical damage 3D6 S.D.C. or 3D6 M.D.; can be thrown 50 feet in the air or 30 feet underwater. A pinned limb or weapon can be twisted and swung to flip the opponent off his feet or upside down underwater, costing him initiative and one melee action. The body flip is available only when using the trident."},{"level":2,"note":"+1 to catch or pin an opponent''s arm, hand, foot or weapon between the prongs."},{"level":3,"applies_when":"with a trident","combat":{"strike":1,"parry":1}},{"level":5,"note":"+1 to catch or pin an opponent''s arm, hand, foot or weapon between the prongs."},{"level":7,"applies_when":"with a trident","combat":{"strike":1,"parry":1}},{"level":10,"note":"+1 to catch or pin an opponent''s arm, hand, foot or weapon between the prongs."},{"level":11,"applies_when":"with a trident","combat":{"strike":1,"parry":1}},{"level":15,"applies_when":"with a trident","combat":{"strike":1,"parry":1}},{"level":15,"note":"+1 to catch or pin an opponent''s arm, hand, foot or weapon between the prongs."}]'
 WHERE name = 'W.P. Trident' AND level_bonuses IS NULL;

-- Record the two readings this book loses, on the rows that won. Guarded on
-- the absence of the text so a re-run is a no-op.
UPDATE skills SET note = 'Rifts World Book 7: Underseas p.210 prints this skill at 56% +3% per level. RUE is the later book and its +4% stands; the Underseas reading is recorded here rather than discarded.'
 WHERE name = 'Demolitions: Underwater' AND note IS NULL;

UPDATE skills SET note = 'Rifts World Book 7: Underseas p.212 prints this weapon as W.P. Harpoon Gun with its last strike bonus at level THIRTEEN. RUE is the later book and its level fifteen stands; the Underseas reading is recorded here rather than discarded.'
 WHERE name = 'W.P. Harpoon & Spear Gun' AND note IS NULL;

-- Read the result back rather than trusting the exit code. One SELECT with IN
-- rather than a UNION: D1 rejects a compound SELECT past five terms and rolls
-- the whole file back.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Advanced Fishing', 'Marine Biology', 'Sea Holistic Medicine',
                'Track & Hunt Sea Animals', 'Undersea Salvage',
                'Advanced Deep Sea Diving', 'W.P. Torpedo', 'W.P. Trident')
 ORDER BY name;
SELECT name, substr(level_bonuses, 1, 40) AS lb FROM skills
 WHERE name IN ('W.P. Torpedo', 'W.P. Trident') ORDER BY name;
SELECT name, substr(note, 1, 60) AS n FROM skills
 WHERE name IN ('Demolitions: Underwater', 'W.P. Harpoon & Spear Gun') ORDER BY name;
SELECT COUNT(*) AS total_skills FROM skills;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-underseas-skills.sql');
