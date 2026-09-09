-- Rifts Ultimate Edition vessels, printed 266-267: the five machines the book's
-- `Common Vehicles` section stats, moved from prose in `gear` into the three
-- tables built for them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-rue-vessels-p266-267.sql
--
-- BOOK-INGEST-AUDIT.md F41, taken for Rifts Ultimate Edition - the third of the
-- five book sessions that finding proposes. Migration 053 added
-- `gear.vehicle_slug` in its own PR ahead of the first of them, per F41.
--
-- == THE SECTION IS FIVE VEHICLES AND A JET PACK, ON TWO PAGES ==
--
-- `Common Vehicles` opens on printed 266 - the book's own Contents says 266 -
-- and ends on printed 267 at `Wilk's Jet Pack`, where
-- `Mega-Damage Capacity Body Armor` begins. In printed order:
--
--   Speedster Hovercycle, Wastelander Motorcycle, Highway-Man Motorcycle,
--   Big Boss ATV, Mountaineer ATV, and then Wilk's Jet Pack.
--
-- The jet pack is NOT imported. It is worn kit, and F41 lists `wilk-s-jet-pack`
-- by name among the 45 rows that are explicitly not vessels and are not to be
-- re-proposed.
--
-- == WHAT THIS FILE DOES NOT TOUCH, AND WHY ==
--
-- Reading the book turned up three problems in the RUE gear rows that are NOT
-- this finding's business. They are filed as `BOOK-INGEST-AUDIT` F42, F43 and
-- F44 rather than fixed here, because F41 is about moving vessels and a book
-- session that quietly rewrote catalog values would be doing something nobody
-- agreed to:
--
--   * **F42** - five gear rows carry FIRST-EDITION M.D.C. under a
--     `Rifts Ultimate Edition` citation. Confirmed against the original core
--     book: RUE errata'd these figures upward and the rows kept the old ones.
--     Ten published class references point at them.
--   * **F43** - `wilk-s-atv-transport-vehicle` and `northern-gun-sky-king` name
--     machines this book does not print at all.
--   * **F44** - `findDuplicates` cannot see two of the three duplicate pairs,
--     because `normaliseName` splits `A.T.V.` into three tokens.
--
-- So the gear rows below keep every value they have, right or wrong, and gain
-- only a pointer. **The pointer makes F42 visible rather than hiding it**: the
-- codex will show a Wastelander gear row reading 45 beside a Wastelander vessel
-- reading 60, which is the honest interim state until Nate settles F42. The
-- vessel is the RUE reading and says so in its `source_book`.
--
-- == EVERY GEAR ROW NAMING A MACHINE POINTS AT THAT MACHINE'S VESSEL ==
--
-- A departure from the Juicer Uprising and Wormwood imports, where each vessel
-- had exactly one gear row. Here three of the five machines are stored TWICE
-- under different slugs, so eight gear rows name five vessels:
--
--   speedster-hovercycle + a-t-v-speedster-hover-cycle -> speedster-hovercycle
--   the-highway-man-motorcycle                         -> itself
--   the-wastelander-motorcycle                         -> itself
--   big-boss-atv + the-big-boss-a-t-v                  -> big-boss-atv
--   mountaineer-atv + the-mountaineer-a-t-v            -> mountaineer-atv
--
-- Pointing both members of a pair is deliberate: it is what makes the
-- duplication legible - two gear rows arriving at one vessel - and it gives the
-- row carrying the older figures a route to the RUE ones. `wilk-s-atv-transport-vehicle`
-- gets NO pointer even though its figures are the Mountaineer's, because its
-- NAME is the thing F43 disputes and resolving that here would take a finding
-- nobody has taken.
--
-- THE VESSEL SLUG IS THE GEAR SLUG of the correctly-named row, as in the two
-- earlier imports. Where a pair exists, the short slug wins - it is the one
-- whose name matches what the book prints (`Speedster Hovercycle`,
-- `Big Boss ATV`, `Mountaineer ATV`) and the one whose figures are already RUE's.
--
-- == READ FROM THE BOOK, TWICE, BECAUSE THIS ONE IS A SCAN ==
--
-- `rue` is `text_layer: false`, so `scripts/read-columns.py` is unavailable -
-- it needs a text layer, exactly as in the Wormwood session. Every figure below
-- was read from the cached OCR of printed 266-267 and then confirmed against a
-- 200 dpi RENDER of both pages, with 500-600 dpi crops for the three figures
-- that decide F42. The render and the OCR agree on every number.
--
-- The offset was confirmed the free way `book-survey` section 0d prescribes: the
-- renders of printed 266 and 267 each carry that folio at the foot of the page,
-- so `page_offset: 3` as `scripts/books.json` records. The cache manifest agrees
-- with the registry on `page_offset` and `printed_pages` both.
--
-- ONE PRINTED VALUE IS MISSING FROM THE BOOK, and it is recorded as missing
-- rather than guessed: the Highway-Man's `Tires (2)` figure. The line reads
-- `M.D.C. by Location: Main Body: 75, Tires (2)` and stops - the motorcycle
-- illustration overlaps where the number belongs. The OCR renders the same
-- truncation (`Tires (2), ,`) and a 600 dpi crop shows no digit under the art.
-- Its `mdc` is NULL with the reason in `mdc_note`. Every other vehicle in the
-- section prints its tire value, so this is a defect in this entry, not a
-- convention.
--
-- Pure ASCII with LF endings.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('speedster-hovercycle', 'Speedster Hovercycle', 'rifts', 'vehicle',
   'One rider.',
   'One is possible, but not comfortable on long trips.',
   NULL,
   'Maximum 220 mph (352 km). A hover vehicle; the book prints one speed and no separate regimes.',
   NULL,
   '9 feet (2.7 m) long',
   '700 lbs (315 kg)',
   85,
   98000,
   'Black market 98,000 credits with a gasoline engine, 110,000 for electric, or 450,000 for nuclear with a ten year life. Add 4,000 for the machine-gun and 11,000 for the laser. The low end of the range is stored, per the convention gear.cost documents.',
   'A fast all-terrain hover vehicle, common throughout the land and the first entry in the book''s Common Vehicles section. Combustion or electric engine; maximum range 800 miles (1280 km). The Highway-Man Motorcycle carries the same weapon options by reference.',
   'Rifts Ultimate Edition p.266'),

  ('the-highway-man-motorcycle', 'Highway-Man Motorcycle', 'rifts', 'vehicle',
   'One rider.',
   NULL,
   'Maximum 180 mph (288 km).',
   NULL,
   NULL,
   '6 feet (1.8 m) long',
   '240 lbs (108 kg)',
   75,
   24000,
   'Black market 24,000 credits with a gasoline engine or 29,000 for electric. Add 6,500 for the machine-gun and 12,000 for the laser.',
   'A fast, rugged vehicle common to the city and flat lands, coming standard with a laser or heavy machine-gun. Combustion or electric engine; maximum range 400 miles (640 km). Its weapons are printed as "Same as Speedster hovercycle" rather than restated. This is the one machine in the section whose main body did NOT change between the original Rifts core book and this edition - both print 75.',
   'Rifts Ultimate Edition p.266'),

  ('the-wastelander-motorcycle', 'Wastelander Motorcycle', 'rifts', 'vehicle',
   'One rider.',
   NULL,
   'Maximum 120 mph (192 km).',
   NULL,
   NULL,
   '9 feet (2.7 m) long',
   '800 lbs (360 kg)',
   60,
   18000,
   'Black market 18,000 credits with a gasoline engine or 21,000 for electric. Add 4,000 for a machine-gun and 11,000 for a laser.',
   'A heavy-duty, rough terrain vehicle with a large storage area built into the back end. Combustion or electric engine; maximum range 400 miles (640 km). No weapons are standard. The original Rifts core book prints its main body as 45; this edition prints 60 - see BOOK-INGEST-AUDIT F42, which the gear row of the same slug is part of.',
   'Rifts Ultimate Edition p.266'),

  ('big-boss-atv', 'Big Boss ATV', 'rifts', 'vehicle',
   'One pilot.',
   'Three, comfortably.',
   'Maximum 150 mph (240 km).',
   NULL,
   NULL,
   '16 feet (4.8 m) long',
   'One ton',
   100,
   24000,
   'Black market 24,000 credits with a gasoline engine or 28,000 for electric.',
   'A popular all-terrain vehicle with good speed and good fuel mileage, printed as an ATV dune buggy type. Combustion or electric engine; maximum range 300 miles (480 km). It often comes with a sunroof and a standard laser rifle attached to the roof, with 360 degree rotation and a 90 degree arc of fire; the rifle is costed separately from the vehicle.',
   'Rifts Ultimate Edition p.266'),

  ('mountaineer-atv', 'Mountaineer ATV', 'rifts', 'vehicle',
   'One pilot.',
   'Four, comfortably, plus a cargo area. The pilot''s compartment seats five in all.',
   'Maximum 120 mph (192 km).',
   NULL,
   NULL,
   '25 feet (7.6 m) long, 18 feet (5.4 m) tall; the enclosed cargo bay is 10x8x8 feet (3x2.4x2.4 m)',
   '6 tons',
   210,
   76000,
   'Black market 76,000 credits for the basic vehicle with a gasoline engine, 70,000 for electric, or 500,000 for nuclear with a twenty year life. Radar, radio, a rail gun and similar features cost separately. Additional armour can be added at 10,000 credits per 30 M.D.C.',
   'An extremely popular armoured all-terrain vehicle, printed as a three wheeled armoured ATV transport. Combustion, electric or nuclear engine; maximum range 600 miles (960 km) on an extra large tank or batteries. No weapons are standard. Its entry breaks across printed 266 and 267 - the heading and opening sentence sit at the foot of 266 and the stat block continues at the top of 267 - which is how an earlier import came to store its figures under the invented name wilk-s-atv-transport-vehicle. See BOOK-INGEST-AUDIT F43.',
   'Rifts Ultimate Edition p.266-267');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('speedster-hovercycle', 'Main Body',      85, NULL, 1),
  ('speedster-hovercycle', 'Hover Jets (3)', 30, 'Each.', 2),

  ('the-highway-man-motorcycle', 'Main Body', 75, NULL, 1),
  ('the-highway-man-motorcycle', 'Tires (2)', NULL, 'The printed value is missing. The line reads "Main Body: 75, Tires (2)" and stops, with the motorcycle illustration overlapping where the number belongs; a 600 dpi crop shows no digit under the art and the OCR renders the same truncation. Every other vehicle in this section prints its tire figure - the Wastelander 2 each, the Big Boss 5 each, the Mountaineer 25 each.', 2),

  ('the-wastelander-motorcycle', 'Main Body', 60, NULL, 1),
  ('the-wastelander-motorcycle', 'Tires (2)',  2, 'Each.', 2),

  ('big-boss-atv', 'Main Body', 100, NULL, 1),
  ('big-boss-atv', 'Tires (4)',   5, 'Each.', 2),

  ('mountaineer-atv', 'Main Body',                     210, NULL, 1),
  ('mountaineer-atv', 'Super Tires (4)',                25, 'Each.', 2),
  ('mountaineer-atv', 'Reinforced Pilot''s Compartment', 50, NULL, 3);

-- ORDINALS ARE THIS FILE'S, NOT THE BOOK'S. RUE prints a `Weapons:` paragraph
-- per vehicle rather than a numbered list, so there is no printed numbering to
-- preserve - unlike the Free Quebec and Triax vessels, whose ordinals are the
-- book's own.
INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('speedster-hovercycle', 1, 'Laser',
   '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '20 shots', NULL,
   'One of two alternatives; the book prints the laser and the machine-gun as a choice, not a pair. Costed separately from the vehicle at 11,000 credits.'),
  ('speedster-hovercycle', 2, 'Machine-Gun',
   '1D4 M.D. per burst of 50 rounds', 1, '2000 feet (610 m)', NULL, '600 rounds, which is 12 bursts', NULL,
   'The other alternative to the laser. Costed separately at 4,000 credits.'),
  ('speedster-hovercycle', 3, 'Mini-Missile Launchers (2, optional)',
   'By mini-missile type', 1, NULL, NULL, 'Two mini-missiles each', NULL,
   'Not standard. Can be added to the sides; 55,000 credits for the pair.'),

  ('the-highway-man-motorcycle', 1, 'Laser or Machine-Gun',
   'Laser 1D6 M.D.; machine-gun 1D4 M.D. per burst of 50 rounds', 1,
   'Laser 1200 feet (366 m); machine-gun 2000 feet (610 m)', NULL,
   'Laser 20 shots; machine-gun 600 rounds, which is 12 bursts', NULL,
   'The book prints only "Same as Speedster hovercycle" and does not restate the figures; they are carried across from that entry and marked as such. One or the other comes standard with the vehicle. Add 12,000 credits for the laser or 6,500 for the machine-gun.'),

  ('the-wastelander-motorcycle', 1, 'None standard',
   NULL, 0, NULL, NULL, NULL, NULL,
   'The book prints "None standard" and then gives the prices to add one: 4,000 credits for a machine-gun and 11,000 for a laser.'),

  ('big-boss-atv', 1, 'Roof-Mounted Laser Rifle (1, usual but not standard)',
   'By rifle type', 1, NULL, NULL, NULL, NULL,
   'The book says the vehicle often comes with a sunroof and a standard laser rifle attached to the roof, with 360 degree rotation and a 90 degree arc of fire, and that the rifle''s cost is added to the vehicle''s. It names no specific model, so no damage figure is stored.'),

  ('mountaineer-atv', 1, 'None standard',
   NULL, 0, NULL, NULL, NULL, NULL,
   'The book prints "None are standard." Radar, radio and a rail gun are named as features that cost separately.');

-- The pointer. Eight gear rows, five vessels - see the header for the mapping
-- and for why both members of a duplicate pair are pointed.
UPDATE gear SET vehicle_slug = 'speedster-hovercycle'
 WHERE slug IN ('speedster-hovercycle', 'a-t-v-speedster-hover-cycle');

UPDATE gear SET vehicle_slug = 'the-highway-man-motorcycle'
 WHERE slug = 'the-highway-man-motorcycle';

UPDATE gear SET vehicle_slug = 'the-wastelander-motorcycle'
 WHERE slug = 'the-wastelander-motorcycle';

UPDATE gear SET vehicle_slug = 'big-boss-atv'
 WHERE slug IN ('big-boss-atv', 'the-big-boss-a-t-v');

UPDATE gear SET vehicle_slug = 'mountaineer-atv'
 WHERE slug IN ('mountaineer-atv', 'the-mountaineer-a-t-v');

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is how a row goes missing
-- without an error, so these COUNT. Every want below is counted off the VALUES
-- lists in THIS FILE, not read back out of a database that has just loaded it.

SELECT 'the five vessels' AS assertion, count(*) AS got, 5 AS want
  FROM vehicles WHERE source_book LIKE '%Ultimate%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 11 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Ultimate%';

SELECT 'their weapon entries' AS assertion, count(*) AS got, 7 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.source_book LIKE '%Ultimate%';

-- The one figure the book does not print.
SELECT 'exactly one location has no printed figure' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Ultimate%' AND l.mdc IS NULL;

-- The five main bodies are RUE's, not the first edition's. Asserted by value
-- because F42 is entirely about these numbers and a silent revert would be the
-- worst way to find out.
SELECT 'the five main bodies are the RUE figures' AS assertion, count(*) AS got, 5 AS want
  FROM vehicles
  WHERE (slug = 'speedster-hovercycle'       AND mdc_main_body =  85)
     OR (slug = 'the-highway-man-motorcycle' AND mdc_main_body =  75)
     OR (slug = 'the-wastelander-motorcycle' AND mdc_main_body =  60)
     OR (slug = 'big-boss-atv'               AND mdc_main_body = 100)
     OR (slug = 'mountaineer-atv'            AND mdc_main_body = 210);

SELECT 'eight gear rows now point at a vessel' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE vehicle_slug IS NOT NULL AND source_book LIKE '%Ultimate%';

-- The two rows F43 disputes gain NO pointer, and neither does the jet pack.
SELECT 'the two disputed rows are untouched' AS assertion, count(*) AS got, 2 AS want
  FROM gear
  WHERE slug IN ('wilk-s-atv-transport-vehicle', 'northern-gun-sky-king')
    AND vehicle_slug IS NULL;

SELECT 'and the jet pack is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'wilk-s-jet-pack' AND vehicle_slug IS NULL;

-- The gear rows keep every value they had. F42 is filed, not applied.
SELECT 'the first-edition figures are still in gear, unaltered' AS assertion, count(*) AS got, 4 AS want
  FROM gear
  WHERE (slug = 'a-t-v-speedster-hover-cycle' AND mdc =  75)
     OR (slug = 'the-big-boss-a-t-v'          AND mdc =  65)
     OR (slug = 'the-wastelander-motorcycle'  AND mdc =  45)
     OR (slug = 'the-mountaineer-a-t-v'       AND mdc = 140);

SELECT 'every pointer in the catalog resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Scoped to THIS book's five, for the reason the Juicer Uprising script gives:
-- the global version belongs to zzzzzz-vehicle-class-vocabulary.sql.
SELECT 'these five carry a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Ultimate%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;
SELECT count(*) AS total_gear_pointers FROM gear WHERE vehicle_slug IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-rue-vessels-p266-267.sql');
