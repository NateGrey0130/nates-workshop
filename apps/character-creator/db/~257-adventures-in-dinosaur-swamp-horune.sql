-- The Horune weapons and vehicles that Adventures in Dinosaur Swamp reprints
-- take that book's figures where it states a different one (plan
-- book-imports-2026-10-20, row 5e; Nate's ruling D23).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~257-adventures-in-dinosaur-swamp-horune.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~257-adventures-in-dinosaur-swamp-horune.sql
--
-- Rifts World Book 27: Adventures in Dinosaur Swamp (2005) reprints, on
-- printed 150-155, the three Horune hand weapons and five Horune vessels
-- the catalog holds from Underseas (printed 166-172). Each was compared
-- line by line, and its vehicle_weapons and vehicle_locations rows row by
-- row, with the held row as production carried it on 2026-10-20 and with
-- Underseas's own page cache, so a difference between the printings is
-- told apart from a line the held row never carried. By Nate's ruling of
-- 2026-10-04 the newest printing that STATES a figure wins, and where it is
-- silent the held figure stays; a complete line Dinosaur Swamp restates
-- without an item drops that item (the line rule ~232 applied). By ruling
-- D23 (2026-10-20) a difference is recorded on the held row: no new rows,
-- and source_book stays Underseas, with Dinosaur Swamp's pages and the old
-- figures in each description and in the changed weapon or location row's
-- note.
--
-- Three figures read like misprints and are taken anyway, because the
-- ruling makes no exception: the Land Shark's elbow blades at 6 M.D. (6D6
-- in Underseas), the Dream Ship's laser turrets at 2D4x10 (4D6x10) and the
-- Strike Ships' at 4D6 (4D6x10). The old figure is kept in each note. One
-- is not taken: the Sea-Horse's Fireball Bite prints 300 feet as 914 m, a
-- conversion its own line contradicts, so the row keeps 91 m.
--
-- The missile lines of both ships are a correction as well as a
-- comparison: both printings give the dice there as how many missiles are
-- carried, and the held rows had them as damage. They move to payload.
--
-- Lines the held rows do not carry (the drones' attacks per melee and
-- combat bonuses, the weapons' metric conversions, the Strike Ships' plasma
-- cannon range) are not compared. Every figure that differs was read off a
-- render of Dinosaur Swamp at PDF offset +1.
--
-- Guarded on each row's old value, and each parent row on its description
-- not yet citing Dinosaur Swamp, so a re-run is a no-op. THIS SCRIPT
-- CHANGES PRODUCTION. The tilde number is claimed at merge.

-- gear ----------------------------------------------------------------------

UPDATE gear
   SET cost_note = 'Manufactured in Atlantis or by Ship Dreamers.',
       description = description || ' Adventures in Dinosaur Swamp printed 150-151 reprints it, and by ~257 its figures win: it is made in Atlantis or by the Ship Dreamers. Underseas printed 166, which this row cites, named Atlantis alone. Every other line the row holds is the same in both printings.'
 WHERE slug = 'horune-harpoon-gun'
   AND source_book = 'Rifts World Book 7: Underseas p.166'
   AND cost_note = 'Manufactured in Atlantis.'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE gear
   SET payload = '40 blasts; unlimited when used by a Dolphin Combat Drone.',
       cost_note = 'Only a Ship Dreamer, or six hours left aboard a Dream Ship, recharges it. Adventures in Dinosaur Swamp printed 151 gives the 10,000 credit price with no reason; Underseas printed 166 called it low because most other beings have no way to recharge it.',
       description = 'A Ship Dreamer techno-wizard rifle with 100 M.D.C. and a reputation for durability. Adventures in Dinosaur Swamp printed 151 reprints it, and by ~257 its figures win: its payload is unlimited in the hands of a Dolphin Combat Drone, and it gives no reason for the price. Underseas printed 166, which this row cites, gave 40 blasts with no exception on its payload line and called the price low because the rifle is nearly impossible for an outsider to recharge. Every other line the row holds is the same in both printings.'
 WHERE slug = 'horune-sonic-rifle'
   AND source_book = 'Rifts World Book 7: Underseas p.166'
   AND payload = '40 blasts'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE gear
   SET description = 'Stolen from the Naut''yll, the Kittani and other beings, all with the same basic stats. Adventures in Dinosaur Swamp printed 151 reprints it, and by ~257 its figures win: it names the Naut''yll and the Kittani as those it is stolen from. Underseas printed 166, which this row cites, named the naut''yll and said others are two-pronged Splugorth knock-offs. Every other line the row holds says the same in both printings.'
 WHERE slug = 'horune-energy-trident'
   AND source_book = 'Rifts World Book 7: Underseas p.166'
   AND description = 'Usually stolen from the naut yll, or bought as a two-pronged Splugorth copy.';

-- Horune Sea-Horse Sled & Speeder -------------------------------------------

UPDATE vehicles
   SET speed_water = 'Surface - the Sled 35 mph (56 kmph; 30 knots), the Speeder 90 mph (144 kmph; 77.7 knots). Submerged - the Sled 35 mph while towing up to 6 tons, the Speeder up to 60 mph, diving to 3000 feet.',
       cost_note = 'NO PRICE. Never sold, and it only works for the Horune race.',
       description = description || ' Adventures in Dinosaur Swamp printed 151 reprints it, and by ~257 its figures win: the Speeder makes 77.7 knots on the surface, and the craft works only for the Horune race. Underseas printed 167, which this row cites, gave 77.4 knots and said it works for horune and for horune pirates of any race. Dinosaur Swamp prints the Fireball Bite''s 300 feet as 914 m, a conversion its own line contradicts, so the weapon keeps 91 m. Every other figure the row holds is the same in both printings.'
 WHERE slug = 'horune-sea-horse-sled-and-speeder'
   AND source_book = 'Rifts World Book 7: Underseas p.167'
   AND instr(speed_water, '77.4 knots') > 0
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- Horune Dolphin Combat Drone -----------------------------------------------

UPDATE vehicle_locations
   SET mdc_note = '15 each in Adventures in Dinosaur Swamp printed 152; Underseas printed 167 gave a flat 15 with no each, where every sibling line carries one.'
 WHERE vehicle_slug = 'horune-dolphin-combat-drone'
   AND location = 'Hip Lasers (2)'
   AND mdc = 15
   AND instr(mdc_note, 'Dinosaur Swamp') = 0;

UPDATE vehicles
   SET description = description || ' Adventures in Dinosaur Swamp printed 151-152 reprints it, and by ~257 its figures win: the Hip Lasers are 15 M.D.C. each. Underseas printed 167, which this row cites, printed a flat 15. Every other figure the row holds is the same in both printings.'
 WHERE slug = 'horune-dolphin-combat-drone'
   AND source_book = 'Rifts World Book 7: Underseas p.167-168'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- Horune Land Shark Drone ---------------------------------------------------

UPDATE vehicle_weapons
   SET damage = '1D6x10 M.D. single, 2D6x10 M.D. double.',
       rate_of_fire = 'A single or double blast counts as one melee attack.',
       note = 'Adventures in Dinosaur Swamp printed 153; Underseas printed 170 gave 1D6x10 per blast, six blasts per melee.'
 WHERE vehicle_slug = 'horune-land-shark-drone'
   AND ordinal = 1 AND name = 'Plasma Ejector'
   AND damage = '1D6x10 M.D. per blast.';

UPDATE vehicle_weapons
   SET damage = 'Elbow blades 6 M.D., claw 5D6 M.D., punch or kick 5D6 M.D., power punch 1D6x10 M.D., tail strike 5D6 M.D., bite 1D4x10 M.D., head butt 3D6 M.D.',
       note = 'Adventures in Dinosaur Swamp printed 153 prints the elbow blades as 6 M.D.; Underseas printed 170 gave 6D6.'
 WHERE vehicle_slug = 'horune-land-shark-drone'
   AND ordinal = 6 AND name = 'Bonuses & Hand to Hand'
   AND instr(damage, 'Elbow blades 6D6 M.D.') > 0;

UPDATE vehicles
   SET description = description || ' Adventures in Dinosaur Swamp printed 152-153 reprints it, and by ~257 its figures win: the mouth Plasma Ejector fires a single 1D6x10 or a double 2D6x10 blast as one melee attack, and the elbow blades do 6 M.D. Underseas printed 170, which this row cites, gave 1D6x10 per blast at six blasts per melee and 6D6 for the elbow blades. Every other figure the row holds is the same in both printings.'
 WHERE slug = 'horune-land-shark-drone'
   AND source_book = 'Rifts World Book 7: Underseas p.169-170'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- Horune Dream Ship ---------------------------------------------------------

UPDATE vehicle_weapons
   SET rate_of_fire = 'Each single blast counts as one melee attack; a double blast counts as two.',
       note = 'Adventures in Dinosaur Swamp printed 154; Underseas printed 171 gave five shots per melee round for each turret.'
 WHERE vehicle_slug = 'horune-dream-ship'
   AND ordinal = 2 AND name = 'Forward Plasma Turrets (2)'
   AND rate_of_fire = 'Five times per melee round.';

UPDATE vehicle_weapons
   SET damage = '2D4x10 M.D.',
       note = 'Adventures in Dinosaur Swamp printed 154; Underseas printed 171 gave 4D6x10.'
 WHERE vehicle_slug = 'horune-dream-ship'
   AND ordinal = 3 AND name = 'Laser Cannon Turrets (2)'
   AND damage = '4D6x10 M.D.';

UPDATE vehicle_weapons
   SET damage = NULL,
       payload = '2D4x10 long- or medium-range missiles and 1D4x100 mini-missiles.',
       note = 'A typical loadout rather than a fixed one - the book says so. Both printings (Underseas printed 171, Adventures in Dinosaur Swamp printed 154) give these dice as how many missiles are carried; this row had them as damage until ~257.'
 WHERE vehicle_slug = 'horune-dream-ship'
   AND ordinal = 5 AND name = 'Missiles'
   AND damage = '2D4x10 M.D. long and medium range; 1D4x100 M.D. mini-missiles.';

UPDATE vehicle_weapons
   SET payload = 'From a dozen up to 100 of each combat drone aboard.',
       note = 'Adventures in Dinosaur Swamp printed 154; Underseas printed 171 gave up to 100 with no lower figure.'
 WHERE vehicle_slug = 'horune-dream-ship'
   AND ordinal = 6 AND name = 'Power Armor & Robots'
   AND payload = 'Up to 100 of each combat drone aboard.';

UPDATE vehicles
   SET crew = 'One captain, ten officers, one or two Air or Water Warlocks (all 1D4+4th level) or one dragon or practitioner of magic (Ocean Wizard, Warlock and the like), and 1D4x100 pirates.',
       speed_water = 'Surface 90 mph (144 kmph; 77.7 knots); submerged 35 mph (56 kmph; 30 knots) for up to twelve hours. Depth unlimited.',
       description = description || ' Adventures in Dinosaur Swamp printed 153-154 reprints it, and by ~257 its figures win: 77.7 knots on the surface, a dragon or any practitioner of magic in place of the warlocks, Forward Plasma Turrets whose double blast counts as two melee attacks, Laser Cannon Turrets at 2D4x10 M.D., and a dozen to 100 of each combat drone. Underseas printed 170-171, which this row cites, gave 77.4 knots, a dragon or ocean wizard, five shots per melee round for each plasma turret, 4D6x10 M.D. for the lasers and up to 100 drones. Both printings count the missiles rather than giving their damage. Every other figure the row holds is the same in both printings.'
 WHERE slug = 'horune-dream-ship'
   AND source_book = 'Rifts World Book 7: Underseas p.170-171'
   AND instr(speed_water, '77.4 knots') > 0
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- Horune Strike Ships -------------------------------------------------------

UPDATE vehicle_weapons
   SET damage = '1D4x100 M.D. per blast.',
       note = 'Adventures in Dinosaur Swamp printed 155; Underseas printed 172 gave 1D4x100 single and 2D4x100 for a double turret blast.'
 WHERE vehicle_slug = 'horune-strike-ship'
   AND ordinal = 2 AND name = 'Forward Plasma Turrets (2)'
   AND damage = '1D4x100 M.D. single, 2D4x100 M.D. double.';

UPDATE vehicle_weapons
   SET damage = '4D6 M.D.',
       note = 'Adventures in Dinosaur Swamp printed 155; Underseas printed 172 gave 4D6x10.'
 WHERE vehicle_slug = 'horune-strike-ship'
   AND ordinal = 3 AND name = 'Laser Cannon Turrets (2)'
   AND damage = '4D6x10 M.D.';

UPDATE vehicle_weapons
   SET damage = NULL,
       payload = '1D4x10 long- or medium-range missiles and 2D4x10 mini-missiles.',
       note = 'A typical loadout. Adventures in Dinosaur Swamp printed 155 carries 2D4x10 mini-missiles; Underseas printed 172 gave 100. Both give 1D4x10 as how many long- and medium-range missiles are carried; this row had it as damage until ~257.'
 WHERE vehicle_slug = 'horune-strike-ship'
   AND ordinal = 5 AND name = 'Missiles'
   AND damage = '1D4x10 M.D. long and medium range, plus about 100 mini-missiles.';

UPDATE vehicle_weapons
   SET payload = '3D6+2 of each combat drone aboard.',
       note = 'Adventures in Dinosaur Swamp printed 155; Underseas printed 172 gave as many as 20 of each.'
 WHERE vehicle_slug = 'horune-strike-ship'
   AND ordinal = 6 AND name = 'Power Armor & Robots'
   AND payload = 'Up to 20 drones aboard.';

UPDATE vehicles
   SET speed_water = 'Surface 120 mph (192 kmph; 103.6 knots); submerged 35 mph.',
       description = description || ' Adventures in Dinosaur Swamp printed 155 reprints it, and by ~257 its figures win: 103.6 knots on the surface, Forward Plasma Turrets at 1D4x100 M.D. per blast with no double, Laser Cannon Turrets at 4D6 M.D., 2D4x10 mini-missiles and 3D6+2 of each combat drone. Underseas printed 172, which this row cites, gave 103.2 knots, a 2D4x100 double turret blast, 4D6x10 M.D. for the lasers, 100 mini-missiles and as many as 20 drones. Every other figure the row holds is the same in both printings.'
 WHERE slug = 'horune-strike-ship'
   AND source_book = 'Rifts World Book 7: Underseas p.172'
   AND instr(speed_water, '103.2 knots') > 0
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'eight rows carry the note and still cite Underseas' AS assertion, count(*) AS got, 8 AS want
  FROM (SELECT description, source_book FROM gear WHERE slug IN ('horune-harpoon-gun', 'horune-sonic-rifle', 'horune-energy-trident')
        UNION ALL
        SELECT description, source_book FROM vehicles WHERE slug IN ('horune-sea-horse-sled-and-speeder', 'horune-dolphin-combat-drone', 'horune-land-shark-drone', 'horune-dream-ship', 'horune-strike-ship'))
 WHERE instr(description, 'Adventures in Dinosaur Swamp printed') > 0
   AND instr(description, '~257') > 0
   AND source_book LIKE 'Rifts World Book 7: Underseas p.%';

SELECT 'the row figures landed' AS assertion, count(*) AS got, 5 AS want
  FROM (SELECT slug, cost_note, payload, NULL AS crew, NULL AS speed_water FROM gear WHERE slug LIKE 'horune-%'
        UNION ALL
        SELECT slug, cost_note, NULL, crew, speed_water FROM vehicles WHERE slug LIKE 'horune-%')
 WHERE (slug = 'horune-harpoon-gun' AND instr(cost_note, 'Ship Dreamers') > 0)
    OR (slug = 'horune-sonic-rifle' AND instr(payload, 'unlimited') > 0)
    OR (slug = 'horune-sea-horse-sled-and-speeder' AND instr(speed_water, '77.7 knots') > 0 AND instr(cost_note, 'Horune race') > 0)
    OR (slug = 'horune-dream-ship' AND instr(speed_water, '77.7 knots') > 0 AND instr(crew, 'practitioner of magic') > 0)
    OR (slug = 'horune-strike-ship' AND instr(speed_water, '103.6 knots') > 0);

SELECT 'eleven weapon and location rows carry a Dinosaur Swamp note' AS assertion, count(*) AS got, 11 AS want
  FROM (SELECT note FROM vehicle_weapons WHERE vehicle_slug LIKE 'horune-%'
        UNION ALL
        SELECT mdc_note FROM vehicle_locations WHERE vehicle_slug LIKE 'horune-%')
 WHERE instr(note, 'Adventures in Dinosaur Swamp printed') > 0;

SELECT 'the weapon figures landed' AS assertion, count(*) AS got, 10 AS want
  FROM vehicle_weapons
 WHERE (vehicle_slug = 'horune-land-shark-drone' AND ordinal = 1 AND damage LIKE '%2D6x10 M.D. double.')
    OR (vehicle_slug = 'horune-land-shark-drone' AND ordinal = 6 AND damage LIKE 'Elbow blades 6 M.D.,%')
    OR (vehicle_slug = 'horune-dream-ship' AND ordinal = 2 AND rate_of_fire LIKE '%counts as two.')
    OR (vehicle_slug = 'horune-dream-ship' AND ordinal = 3 AND damage = '2D4x10 M.D.')
    OR (vehicle_slug = 'horune-dream-ship' AND ordinal = 5 AND damage IS NULL AND payload LIKE '2D4x10 long%')
    OR (vehicle_slug = 'horune-dream-ship' AND ordinal = 6 AND payload LIKE 'From a dozen%')
    OR (vehicle_slug = 'horune-strike-ship' AND ordinal = 2 AND damage = '1D4x100 M.D. per blast.')
    OR (vehicle_slug = 'horune-strike-ship' AND ordinal = 3 AND damage = '4D6 M.D.')
    OR (vehicle_slug = 'horune-strike-ship' AND ordinal = 5 AND damage IS NULL AND payload LIKE '%2D4x10 mini-missiles.')
    OR (vehicle_slug = 'horune-strike-ship' AND ordinal = 6 AND payload = '3D6+2 of each combat drone aboard.');

INSERT INTO data_script_runs (filename) VALUES ('~257-adventures-in-dinosaur-swamp-horune.sql');
