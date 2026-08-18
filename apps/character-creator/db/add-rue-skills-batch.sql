-- One hundred and twenty skill rows from the Rifts Ultimate Edition Skill
-- List, p.302-303 - the two summary pages that open the skill chapter, each
-- entry a name, base percentage and per-level step, grouped by category.
-- Extracted from 300dpi page renders (the scan has no text layer) and
-- diffed against the whole existing catalog before a single row was written.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-rue-skills-batch.sql
--
-- The diff is the point. Of the book's 248 list entries:
--   - 95 already match the catalog exactly (largely the earlier RUE
--     description-page import) and are not touched;
--   - 21 are RUE RENAMES of skills the catalog holds under older spellings
--     (Surveillance for Surveillance Systems, Sensory Equipment for Read
--     Sensory Equipment, Creative Writing for Writing, Forensics for
--     Criminal Sciences & Forensics, Mathematics: Advanced for Advanced
--     Math, W.P. Submachine-Gun for W.P. Sub-Machinegun, the two heavy
--     W.P.s, Motorcycles & Snowmobiles for Motorcycle, and so on) and are
--     DELIBERATELY NOT INSERTED - characters reference skills by name, so
--     name convergence belongs to the catalog editor's merge/rename tools,
--     which write redirects and rewrite characters. Inserting the new
--     spelling would have manufactured exactly the ten-duplicates problem
--     the last skill import taught (README, Merging duplicate catalog rows);
--   - 12 rows DISAGREE with the catalog on numbers (below); the stored
--     numbers are kept and the book's figure lands in the note;
--   - 120 are genuinely new and inserted here.
--
-- Conventions carried over from the existing catalog rather than the book:
--   - Pilot skills store WITHOUT the "Pilot:" prefix (catalog has Airplane,
--     Automobile...), and W.P.s use the single 'Weapon Proficiencies'
--     category rather than the book's Ancient/Modern split.
--   - base 0 / per_level 0 means non-percentile (hand-to-hands, W.P.s,
--     "varies"/"Special" rows), matching the catalog's own convention.
--   - Dual percentages ("66%/50%+3%") store the FIRST figure in base and
--     the printed pair in note - the Medical Doctor precedent.
--   - systems stays NULL: skills are deliberately cross-system (README,
--     Which system a catalog row belongs to).
--   - The book lists some skills under two categories (Pick Locks, Prowl,
--     Sing, Wilderness Survival...); the catalog holds one row, and inserts
--     take the category of their primary listing. Recycle/Recycling is the
--     book listing one skill under two NAMES; one row, noted.
--
-- Known pre-existing duplicate this script does NOT touch: the catalog holds
-- both 'Basic Math' (45%+5) and a zeroed seed row 'Mathematics: Basic' -
-- that is a job for Find duplicates in the catalog editor, which rewrites
-- characters; SQL here cannot do it safely.
--
-- ON CONFLICT DO NOTHING, not UPDATE: every collision here is a row the
-- earlier import already filled, and its numbers were reviewed then.
INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Barter', 'Communications', 30, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Electronic Countermeasures', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Literacy: Native Language', 'Communications', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Literacy: Other', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Performance', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Public Speaking', 'Communications', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Sing', 'Communications', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Branding', 'Cowboy', 50, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Breaking/Taming Wild Horses', 'Cowboy', 20, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Herding Cattle', 'Cowboy', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Horsemanship: Cowboy', 'Cowboy', 66, 3, '66%/50%+3%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Lore: American Indians', 'Cowboy', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Lore: Cattle & Animals', 'Cowboy', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Roping', 'Cowboy', 20, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Trick Riding', 'Cowboy', 0, 0, 'Special', 'import', 'Rifts Ultimate Edition p.302-303'),
('Gardening', 'Domestic', 36, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Housekeeping', 'Domestic', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Recycle', 'Domestic', 30, 5, 'listed again as Recycling under Technical', 'import', 'Rifts Ultimate Edition p.302-303'),
('Wardrobe & Grooming', 'Domestic', 50, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Electricity Generation', 'Electrical', 50, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Impersonation', 'Espionage', 30, 4, '30%/16%+4%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Undercover Ops', 'Espionage', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Horsemanship: Cossack', 'Horsemanship', 55, 5, '55%/45%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Horsemanship: Cyber-Knight', 'Horsemanship', 70, 3, '70%/50%+3%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Horsemanship: Equestrian', 'Horsemanship', 40, 5, '40%/30%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Bioware Mechanics', 'Mechanical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Vehicle Armorer', 'Mechanical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Brewing: Medicinal', 'Medical', 25, 5, '25%/30%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Crime Scene Investigation', 'Medical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Cybernetic Medicine', 'Medical', 40, 5, '40%/60%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Entomological Medicine', 'Medical', 40, 5, '40%/20%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Field Surgery', 'Medical', 16, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Psychology', 'Medical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Veterinary Science', 'Medical', 50, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Demolitions: Underwater', 'Military', 56, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Find Contraband', 'Military', 26, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Forced March', 'Military', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Military Fortification', 'Military', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Naval History', 'Military', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Naval Tactics', 'Military', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('NBC Warfare', 'Military', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Parachuting', 'Military', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Trap/Mine Detection', 'Military', 20, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Hand to Hand: Commando', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Aerobic Athletics', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Fencing', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Juggling', 'Physical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Kick Boxing', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Outdoorsmanship', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Physical Labor', 'Physical', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('SCUBA', 'Physical', 50, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Bicycling', 'Pilot', 44, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Boat: Paddle Types/Canoe/Kayak', 'Pilot', 50, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Combat Driving', 'Pilot', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Flight System Combat', 'Pilot', 40, 5, 'Juicer', 'import', 'Rifts Ultimate Edition p.302-303'),
('Hovercycles, Skycycles & Rocket Bikes', 'Pilot', 70, 3, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Jump Bike Combat', 'Pilot', 45, 5, 'Juicer', 'import', 'Rifts Ultimate Edition p.302-303'),
('Military: Combat Helicopter', 'Pilot', 52, 3, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Military: Submersibles', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Military: Warships & Patrol Boats', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Tracked & Construction Vehicles', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Water Scooters', 'Pilot', 50, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Water Skiing & Surfing', 'Pilot', 40, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Cardsharp', 'Rogue', 24, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Gambling (Standard)', 'Rogue', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Gambling (Dirty Tricks)', 'Rogue', 20, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('I.D. Undercover Agent', 'Rogue', 30, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Imitate Voices & Sounds', 'Rogue', 42, 4, '42%/36%+4%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Roadwise', 'Rogue', 26, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Safe-Cracking', 'Rogue', 20, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Seduction', 'Rogue', 20, 3, 'plus attribute bonuses', 'import', 'Rifts Ultimate Edition p.302-303'),
('Tailing', 'Rogue', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Artificial Intelligence', 'Science', 30, 3, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Astronomy & Navigation', 'Science', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Astrophysics', 'Science', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Chemistry: Pharmaceutical', 'Science', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Xenology', 'Science', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Zoology', 'Science', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Appraise Goods', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Begging', 'Technical', 30, 3, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Breed Dogs', 'Technical', 40, 5, '40%/20%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Calligraphy', 'Technical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Cybernetics: Basic', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Excavation', 'Technical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Firefighting', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Gemology', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('History: Pre-Rifts', 'Technical', 32, 4, '32%/24%+4%', 'import', 'Rifts Ultimate Edition p.302-303'),
('History: Post-Apocalypse', 'Technical', 35, 5, '35%/30%+5%', 'import', 'Rifts Ultimate Edition p.302-303'),
('Jury-Rig', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Law (General)', 'Technical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Leather Working', 'Technical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Lore: D-Bee', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Lore: Juicers', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Lore: Psychics & Psionics', 'Technical', 25, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Masonry', 'Technical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Mining', 'Technical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Mythology', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Philosophy', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Research', 'Technical', 40, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Rope Works', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Salvage', 'Technical', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Ventriloquism', 'Technical', 16, 4, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Whittling & Sculpting', 'Technical', 30, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Axe', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Forked', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Grappling Hook', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Pole Arm', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Quick Draw', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Rope', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Spear', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Staff', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Whip', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Handguns', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Rifles', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Shotgun', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Military Flamethrowers', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('W.P. Harpoon & Spear Gun', 'Weapon Proficiencies', 0, 0, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Dowsing', 'Wilderness', 20, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Fasting', 'Wilderness', 40, 3, NULL, 'import', 'Rifts Ultimate Edition p.302-303'),
('Spelunking', 'Wilderness', 35, 5, NULL, 'import', 'Rifts Ultimate Edition p.302-303')
ON CONFLICT (name) DO NOTHING;

-- Number conflicts: the RUE list disagrees with the stored row. The stored
-- numbers are NOT changed (curated values are never silently overwritten);
-- the note records what the RUE list prints, visibly, for a human to settle.
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 88%+1%' WHERE name = 'Language: Native Tongue' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 50%+3%' WHERE name = 'Language: Other' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 25%+5%' WHERE name = 'T.V./Video' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 30%+5%' WHERE name = 'Computer Repair' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 35%+5%' WHERE name = 'Electrical Engineer' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 30%/20%+5%' WHERE name = 'Holistic Medicine' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists varies' WHERE name = 'Acrobatics' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists varies' WHERE name = 'Gymnastics' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 20%+5%' WHERE name = 'Computer Hacking' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 30%+5%' WHERE name = 'Anthropology' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 30%/20%+5%' WHERE name = 'Archaeology' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');
UPDATE skills SET note = COALESCE(note || '; ', '') || 'RUE p.302 lists 30%+5%' WHERE name = 'Preserve Food' AND (note IS NULL OR note NOT LIKE '%RUE p.302%');

-- Read the result back rather than trusting the exit code.
SELECT COUNT(*) AS rue_list_rows FROM skills WHERE source_book = 'Rifts Ultimate Edition p.302-303';
SELECT COUNT(*) AS conflict_notes FROM skills WHERE note LIKE '%RUE p.302%';
SELECT name, base, per_level, note FROM skills WHERE name IN ('Horsemanship: Cowboy', 'Language: Other', 'Seduction', 'W.P. Handguns');
