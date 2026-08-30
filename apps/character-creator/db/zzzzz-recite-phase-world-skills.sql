-- Eight skills that cite "Rifts Skill List" are printed in Rifts Dimension
-- Book 2: Phase World. Move the citation to the book and the page.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzz-recite-phase-world-skills.sql
--
-- "Rifts Skill List" is a one-page skill sheet, not a book. source-coverage
-- reports it as 0 traceable of 48, and it always will: there is no PDF to
-- cache, so every row citing it is permanently uncheckable. Caching it would
-- make the ledger lie rather than fix anything.
--
-- Eight of those 48 turn out to be printed in Phase World, which IS cached.
-- The evidence is that the numbers agree exactly - same category, same base,
-- same per-level step - across eight rows read independently off 200 dpi
-- renders of printed 52-53 and 150-151:
--
--   catalog row                        Phase World prints        page  values
--   Space: Space Fighter               Pilot: Space Fighter      150   50 +3  agree
--   Space: Small Spacecraft            Pilot: Small Spacecraft   150   60 +3  agree
--   Space: Starship                    Pilot: Starship           151   36 +4  agree
--   Space: Extra-Vehicular Activity    EVA                       150   40 +5  agree
--   Navigation: Stellar                Navigation - Space        151   40 +5  agree
--   Lore: Galactic/Alien               Lore: Galactic/Alien      151   25 +5  agree
--   Language: Trade Five/Reptile       Trade Five                 52   40 +5  agree
--   Language: Trade Six                Trade Six               52-53   45 +5  agree
--
-- add-rifts-skill-list-gaps.sql half-knew this already: its naming note calls
-- Trade Five and Trade Six "the Phase World trade languages" while citing them
-- to the sheet. This finishes that thought with a page number.
--
-- THE ACTION IS RE-CITATION AND NEVER A RENAME, and the distinction is the
-- whole point. Characters reference skills by NAME, so renaming Space: Space
-- Fighter to the book's Pilot: Space Fighter would strand every character and
-- every class restriction that names the old string - and an unmatched `except`
-- fails OPEN, so a class would silently start offering a skill its book
-- forbids. Renaming is duplicate-tool work that writes redirects and rewrites
-- characters; SQL cannot do it safely. Same reasoning BOOK-INGEST-QUEUE.md
-- records for W.P. Rope. EIGHT published classes name three of these strings in
-- their Pilot `except` lists today - counted against production, not guessed.
--
-- So: source_book moves, name does not, and every value stays exactly where it
-- was. The book's own spelling goes in the note, which is the only place it
-- was previously recorded nowhere at all.
--
-- ONE CATEGORY DISAGREEMENT, recorded and not applied. Phase World files EVA
-- under Pilot Skills; the catalog holds Space: Extra-Vehicular Activity as
-- Physical. The values agree, so this is the book and the sheet disagreeing
-- about filing rather than about the skill. Physical stands: it is what the
-- catalog has, what the pickers group on, and changing a category changes
-- which classes can offer the row.
--
-- WHY THIS FILE SORTS LAST. A clean rebuild applies apps/character-creator/db/
-- *.sql as one sorted glob, so filename order IS execution order.
-- "add-phase-world-skills.sql" sorts BEFORE "add-rifts-skill-list-gaps.sql" -
-- p before r - and these eight rows do not exist until that later file runs.
-- Put these updates in the add- file and they would match zero rows on a
-- rebuild and be silently undone, which is the fix-long-bowman-armor.sql
-- failure exactly. zzzzz- sorts after everything.
--
-- Guarded on the old citation still being present, so re-running is a no-op
-- and a row someone has already re-cited by hand is left alone.

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.150',
       note = 'Printed as Pilot: Space Fighter, under Pilot Skills. One to three man fighters built for fighter, power armor, ship and robot combat in space.'
 WHERE name = 'Space: Space Fighter' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.150',
       note = 'Printed as Pilot: Small Spacecraft, under Pilot Skills. Cargo and shuttle craft for short planet-to-planet or station runs; typical speed about half light.'
 WHERE name = 'Space: Small Spacecraft' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.151',
       note = 'Printed as Pilot: Starship, under Pilot Skills. The large intergalactic vessels - cargo ships, ore haulers, battleships - crewed in the hundreds or thousands.'
 WHERE name = 'Space: Starship' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.150',
       note = 'Printed as EVA, Extra-Vehicular Activity. Working outside a spacecraft in a vacuum suit: suit operation and repair, damage control and manoeuvring. The book files it under PILOT skills; the catalog holds it as Physical and that stands, because a category change moves which classes can offer it. The book asks for Zero Gravity Movement before this skill.'
 WHERE name = 'Space: Extra-Vehicular Activity' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.151',
       note = 'Printed as Navigation - Space, under Pilot Related Skills. As terrestrial navigation but using stars and shipboard sensors; a failed roll puts the ship 4D6 light years off course.'
 WHERE name = 'Navigation: Stellar' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.151',
       note = 'Identifies known alien races and their culture and habits, and covers the legends about the Cosmic Forge, cosmo-knights, kreeghor and prometheans. G.M. may assign -5% to -30% for a less known species.'
 WHERE name = 'Lore: Galactic/Alien' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.52',
       note = 'Galactic Trade Tongue Five, built on hisses, whistles and clicks and favoured by reptilian and insectoid races. Air breathers learn it at no penalty but keep an accent. Common to the kreeghor and seljuk, and usually the draconid second language. One of the two Trade Tongues the book bases below 50%; Trade Six is the other, at 45%.'
 WHERE name = 'Language: Trade Five/Reptile' AND source_book = 'Rifts Skill List';

UPDATE skills
   SET source_book = 'Rifts Dimension Book 2: Phase World p.52-53',
       note = 'Galactic Trade Tongue Six, the newest, built by CCW linguists so every word has two or three equivalents - two sounds and one gesture - and can be learned by any species at no bonus or penalty.'
 WHERE name = 'Language: Trade Six' AND source_book = 'Rifts Skill List';

-- Read the result back rather than trusting the exit code. Two questions: did
-- all eight move, and did anything else move with them. One SELECT with IN
-- rather than a UNION - D1 rejects a compound SELECT past five terms and rolls
-- the whole file back.
SELECT name, category, base, per_level, source_book FROM skills
 WHERE name IN ('Space: Space Fighter', 'Space: Small Spacecraft', 'Space: Starship',
                'Space: Extra-Vehicular Activity', 'Navigation: Stellar',
                'Lore: Galactic/Alien', 'Language: Trade Five/Reptile', 'Language: Trade Six')
 ORDER BY name;

-- Should be 40, down from 48, and nothing else in the catalog should cite the
-- sheet that is not on the list above.
SELECT COUNT(*) AS still_citing_the_sheet FROM skills WHERE source_book = 'Rifts Skill List';
SELECT COUNT(*) AS now_citing_phase_world FROM skills
 WHERE source_book LIKE 'Rifts Dimension Book 2: Phase World%';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-recite-phase-world-skills.sql');
