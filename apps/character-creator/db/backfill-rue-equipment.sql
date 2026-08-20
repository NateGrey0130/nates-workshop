-- The equipment chapter, from the book at last.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-rue-equipment.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-rue-equipment.sql
--
-- Rifts Ultimate Edition p.261-265: Common Gear, Communications, Medical,
-- Optics, and the Coalition armour stat blocks. This is the source the gear
-- catalog had been waiting for, and it does three things at once.
--
-- 1. FILLS twenty-two rows the open web could not settle, including two that
--    were written off as book-only: the Juicer's Bio-Comp Monitor (2,500 cr)
--    and the portable I.R.M.S.S. kit (42,000 cr).
--
-- 2. CORRECTS eight rows filled from web references whose numbers the book
--    contradicts. Every one of them is now book-sourced. The corrections are
--    not small - a survival knife is 120-300 credits and does 1D6, not 20-50
--    and 1D4 - which is the argument for having marked them "not book-verified"
--    rather than letting them pass as fact.
--
-- 3. CONFIRMS the Dog Pack riot armor at 30 M.D.C. and 8 lbs, recorded earlier
--    at MEDIUM confidence from a forum, and adds the locations and the fact it
--    carries NO Prowl penalty. The two Dead Boy suits keep their M.D.C. but
--    their price drops to the book's black market range of 35,000-45,000.
--
-- STILL NOT PRICED, and now for a reason read off the page rather than inferred
-- from failed searches: the Basic Gear list runs alphabetically through
-- Cigarettes, Compass and Cross/Crucifix with no entry for clothing, and none
-- for food rations anywhere in the chapter. The book simply does not price them.
--
-- Every UPDATE is guarded so a row already carrying book data is never
-- overwritten by this, and so re-running does nothing.


-- -- 1. Rows the web could not settle --

UPDATE gear SET description = 'Typically 50 to 150 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 50
  WHERE slug = 'compass' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A small magnifying glass; double for a large one.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 5
  WHERE slug = 'magnifying-glass' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A silver cross or crucifix, 4 to 6 inches. Typically 80 to 150 credits, and double that in gold.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 80
  WHERE slug = 'small-silver-cross' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A silver cross or crucifix, 8 to 12 inches. Typically 200 to 400 credits, and double that in gold.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 200
  WHERE slug = 'large-silver-cross' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A pocket or signal mirror, 2 to 5 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2
  WHERE slug = 'pocket-mirror' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A pocket or signal mirror, 2 to 5 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2
  WHERE slug = 'small-mirror' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A pocket or signal mirror, 2 to 5 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2
  WHERE slug = 'signal-mirror' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Typically 110 to 160 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 110
  WHERE slug = 'sleeping-bag' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Typically 110 to 160 credits. Same item as the plain Sleeping Bag row; the two should probably be merged.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 110
  WHERE slug = 'sleeping-bag-rifts' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A grappling hook with 100 feet of line.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 80
  WHERE slug = 'grappling-hook' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A soft-cover sketch book of 100 sheets. A hardcover runs 8 to 12 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 4
  WHERE slug = 'sketch-pad' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Priced as the soft-cover sketch book, 100 sheets - the book lists no separate note pad.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 4
  WHERE slug = 'note-pad' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A marker pen. A dozen runs 6 to 8 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 1
  WHERE slug = 'pen' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A mechanical pencil, 2 to 5 credits. A 24-pack of lead runs 10 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2
  WHERE slug = 'pencil' AND description LIKE 'STUB%';

UPDATE gear SET description = 'An old-style radio communicator, the basic instrument issued to military personnel and field operatives. Range about 3 miles. 30 S.D.C. for the unit, 15 each for the parts. Weighs 6 to 10 ounces.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 150,
  weight_lbs = 0.5
  WHERE slug = 'walkie-talkie' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A P.D.D. audio player and recorder that plays and records on one and three inch discs. Typically 1,200 to 2,400 credits. Blank discs run 10 to 20 credits for two or three hours.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 1200
  WHERE slug = 'pocket-digital-disc-recorder' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A portable computer about the size of a paperback. From about 100 credits for a palm organizer up to tens of thousands for a military mega-computer. Weighs from a few ounces to a pound.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 100,
  weight_lbs = 1
  WHERE slug = 'hand-held-computer' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A portable computer about the size of a paperback. From about 100 credits for a palm organizer up to tens of thousands for a military mega-computer.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 100,
  weight_lbs = 1
  WHERE slug = 'pocket-computer' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Programmed with the nine known languages of the Americas and holding three more, with twelve others available on a supplemental disc. Recognises up to three voices and two languages at once. 98.7% accurate on one speaker with a three second delay, dropping to 78% on three speakers with a six second delay.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 9600,
  weight_lbs = 0.5
  WHERE slug = 'portable-language-translator' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A Bio-Comp Monitor: a portable computer and sensor system clipped to the ears or fingers, measuring and recording blood pressure, temperature, heartbeat, respiration, hydration and a number of chemical responses detectable through the skin. Warns of dangerous or irregular signs.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2500
  WHERE slug = 'bio-comp-system' AND description LIKE 'STUB%';

UPDATE gear SET description = 'An I.R.M.S.S. - Internal Robot Medical Surgeon System. Injects a dozen microscopic robots into the bloodstream to repair internal injury: blood clots, torn veins, internal bleeding and minor organ damage, equal to a surgical skill of 75%. Each kit holds 48 surgical robots, good for four uses; the robots are not reusable and flush from the body after about an hour.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 42000
  WHERE slug = 'portable-irmss-kit' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A Multi-Optics Helmet (M.O.H.), an optical enhancement system built into a protective helmet: targeting sight and infrared optics to 1,600 feet, a telescopic monocular lens to 2 miles, and a thermal-imager to 1,600 feet that sees in darkness, shadow and through smoke. GIVES +1 TO STRIKE while the optics and targeting sight are engaged. Typically 2,800 to 3,400 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2800
  WHERE slug = 'optic-helmet' AND description LIKE 'STUB%';

-- -- 2. Web values the book contradicts --
-- Guarded on the row still carrying the web marker, so a hand correction made
-- since is never clobbered.

UPDATE gear SET description = 'A survival knife doing 1D6 S.D.C. Typically 120 to 300 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 120,
  weight_lbs = 1.2,
  damage = '1D6',
  is_mega_damage = 0
  WHERE slug = 'survival-knife' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A large flashlight, 12 to 20 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 12,
  weight_lbs = 0.5
  WHERE slug = 'flashlight' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A large flashlight, 12 to 20 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 12,
  weight_lbs = 0.5
  WHERE slug = 'large-flashlight' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A small mallet, 2 to 4 credits. Earlier priced as a metal claw hammer because no mallet entry had been found; the book lists one.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 2,
  weight_lbs = 1
  WHERE slug = 'small-mallet' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A military-style utility belt, 3 to 5 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 3,
  weight_lbs = 1.8
  WHERE slug = 'utility-belt' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A knapsack, 50 to 100 credits.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 50,
  weight_lbs = 4
  WHERE slug = 'knapsack' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A large knife doing 1D6 S.D.C. Typically 20 to 100 credits. A small knife (1D4) runs 15 to 75.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 20,
  weight_lbs = 0.22,
  damage = '1D6',
  is_mega_damage = 0
  WHERE slug = 'knife' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'A pack of 12 disposable filters, 5 credits. An earlier note recorded a second source claiming 35 credits; the book settles it at 5.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 5,
  weight_lbs = 1.5
  WHERE slug = 'air-filter' AND source_book = 'Web reference (not book-verified)';

-- -- 3. Armour: locations from the book, and the real price --

UPDATE gear SET description = 'Coalition Dog Pack DPM 101 light riot armor. M.D.C. by location: main body 30, arms 10 each, legs 20 each. Full mobility - NO Prowl or movement penalty - but it offers none of the environmental systems of a full Dead Boy suit, and serves mostly as protection against gunfire.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  mdc = 30,
  weight_lbs = 8,
  is_mega_damage = 1
  WHERE slug = 'dog-pack-dpm-riot-armor' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'Coalition CA-1 Heavy "Dead Boy" body armor, old style, worn by the infantry. M.D.C. by location: main body 80, helmet 50, arms 35 each, legs 50 each. -10% on Acrobatics, Climbing, Prowl, Swimming and other high-mobility skills. Full environmental armor: life support, internal cooling, gas filtration, a five hour oxygen supply, radiation shielding, heat resistance to 300 degrees centigrade, and a helmet radio good for 5 miles.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  mdc = 80,
  weight_lbs = 18,
  is_mega_damage = 1,
  cost = 35000
  WHERE slug = 'ca-1-heavy-dead-boy-armor' AND source_book = 'Web reference (not book-verified)';

UPDATE gear SET description = 'Coalition CA-2 Light "Dead Boy" body armor, old style, worn by pilots, city police and for espionage work. M.D.C. by location: main body 50, helmet 35, arms 15 each, legs 24 each. No mobility penalty; -5% on Acrobatics, Climbing, Prowl, Swimming and similar. Full environmental armor, with the same life support and shielding as the heavy suit.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  mdc = 50,
  weight_lbs = 9,
  is_mega_damage = 1,
  cost = 35000
  WHERE slug = 'ca-2-light-dead-boy-armor' AND source_book = 'Web reference (not book-verified)';

-- Reports the result back, so it is read rather than assumed.
--   book_sourced      rows now citing the equipment chapter
--   web_left          rows still citing the web - should be small and shrinking
--   irmss             42000, one of the two written off as book-only
--   biocomp            2500, the other
--   knife_dmg         '1D6', the corrected survival knife
--   dogpack_mdc         30, confirmed rather than guessed
--   stubs_now         the running total, for comparison against 78
SELECT (SELECT count(*) FROM gear WHERE source_book LIKE 'Rifts Ultimate Edition p.261%%') AS book_sourced,
       (SELECT count(*) FROM gear WHERE source_book = 'Web reference (not book-verified)') AS web_left,
       (SELECT cost FROM gear WHERE slug = 'portable-irmss-kit') AS irmss,
       (SELECT cost FROM gear WHERE slug = 'bio-comp-system') AS biocomp,
       (SELECT damage FROM gear WHERE slug = 'survival-knife') AS knife_dmg,
       (SELECT mdc FROM gear WHERE slug = 'dog-pack-dpm-riot-armor') AS dogpack_mdc,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-rue-equipment.sql');
