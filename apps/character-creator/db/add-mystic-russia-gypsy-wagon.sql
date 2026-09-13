-- The Gypsy Wagon, from Rifts World Book 18: Mystic Russia printed 141-142.
-- One vehicle, 9 M.D.C. locations, no weapons.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-russia-gypsy-wagon.sql
--
-- THIS IS THE SEVENTH AND LAST VESSEL IN THE BOOK, and the only one outside the
-- military chapter. The survey filed it as "a Steeds table at printed 142 ...
-- not yet classified as vessels, creatures or gear". It is not a table: the
-- steeds are one line of percentages inside a vehicle entry that carries
-- `M.D.C. by Location`, Speed, Size, Width, Height and Cargo. See
-- add-mystic-russia-vessels-transports.sql for the count, which the survey and
-- then PR #1015 both got wrong.
--
-- EVERY SINGLE M.D.C. FIGURE ON THIS ENTRY IS A RANGE, which no other vessel in
-- the book does. The book says why: "The exact amount of M.D.C. will vary
-- somewhat depending on the individual clan, sub-group, available resources,
-- the amount of combat the group and vehicle has seen lately, etc."
--
-- `mdc` and `mdc_main_body` are INTEGER, so each carries the LOW END of its
-- range with the full range in mdc_note beside it - the same convention
-- `gear.cost` documents for a price range, and the same one the Mystic Russia
-- gear import used for "600,000 to a million credits". Nothing is lost and
-- nothing is invented: the stored number is a figure the book prints.
--
-- NOTE the main body is NULL for a DIFFERENT reason on two of the transports -
-- there the book prints several main bodies and the column holds one. Here
-- there is exactly one main body and it is merely imprecise, so it is carried.
--
-- IT HAS NO WEAPONS AND NO PRICE. The book gives it neither, so no
-- vehicle_weapons rows and cost NULL. What it has instead of armament is
-- MAGIC, and the four protections are named in the description rather than
-- invented as weapon rows: a permanent Sanctum, a Circle of Protection (Lesser
-- or Superior), and Circle of Travel and Watchguard from Federation of Magic.
--
-- The book has a TEXT LAYER; offset +1, so printed 141 is cache p142 and
-- printed 142 is cache p143. Neither is on the welded or glyph-corrupt list,
-- and no figure in this entry is ciphered - there is not an "x10" on the page.
--
-- Descriptions are paraphrases, never the book's prose.
--
-- No production row collided with the slug or the name (checked --remote
-- 2026-09-13; the catalog holds a "Cavalry War Wagon" and nothing else close).

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('gypsy-wagon', 'Gypsy Wagon', 'rifts', 'vehicle',
   'A driver, with room for three on the front seat when the wagon is drawn by animals. A Gypsy Wagon is rarely left unattended: there is usually at least one elder, typically a woman, and more often the elder plus one to three children, a male guardian and one or two others.',
   'Four to six folding bunk-beds, with floor space where another two to six people can pull up a pillow or bedroll.',
   'Varies entirely with what is pulling it. An animal-drawn wagon averages 10-15 mph (16 to 24 km) and tops out around 30-40 mph (48 to 64 km) depending on the animals. A motorised conveyance can reach 80 mph (128 km), but seldom goes faster for fear of tipping the wagon and rolling it.',
   'None, unless the cab pulling it flies. 18%-25% are hitched to a modern M.D.C. tractor, truck cab, or wheeled or hover land rover.',
   'None.',
   'Three sizes. Length: small 12-15 feet (3.6 to 4.6 m), medium 20-25 feet (6 to 7.6 m), large 30-40 feet (9 to 12 m). Width: small 8-10 feet (2.4 to 3 m), medium 12-15 feet (3.6 to 4.6 m), large 16-20 feet (4.9 to 6 m). Height is typically 8-14 feet (2.4 to 4.9 m) whatever the size.',
   'Not printed. It carries 20-40 tons without fear of breaking a wheel or axle, and pulls twice that.',
   225, NULL,
   'THE BOOK PRINTS NO PRICE. A Gypsy Wagon is a family''s home rather than a thing sold.',
   'More than transport: a Gypsy group''s home, meeting place, lair and sanctuary, and a safe haven protected by magic. Ornate, covered in carvings, inlay and detailing, and though most look like wood and shingles the majority are built of M.D.C. materials. ITS ARMAMENT IS MAGIC - a permanent Sanctum spell, a Circle of Protection (Lesser or Superior), and Circle of Travel and Watchguard from Federation of Magic - which is why it carries no weapon rows. WHAT PULLS IT: 18%-25% are hitched to a modern M.D.C. tractor, truck cab or land rover, and the rest are drawn by horses or, more often, Mega-Steeds - 41% Horned Steeds, 22% Ursan Forest Steeds, 12% Burkov Mastodon, 9% Bionic Horses, 4% Hell Horses, 1% Serpent Hounds, 1% Mega-Horse and 10% other creatures. The true Megahorse is the most coveted and 99% use something else. Inside: a trunk that doubles as a seat for two or three, a locking wall cabinet, a stove piped through the ceiling (anything from wood-burning to a microwave with its own generator), hooks and pegs for grain and supplies, and a barrel or a modern sink. ONE OR TWO SECRET TRAP DOORS in the floor or roof let Gypsies slip in and out, and a handful of secret compartments are built into the floor, walls and ceiling. The rear quarter is a separate room with plush sofas, a table and a tall-backed chair, where fortunes are told, potions and herbs are sold, healings are performed and deals are made with gadji. The decorative railings, posts, statuary and charms outside are also hand-holds, tethering posts, and places to hang loot or to grab hold of a moving wagon - most have a front and rear hitch, and up to four wagons can be hooked together. EVERY M.D.C. FIGURE IN THIS ENTRY IS A RANGE; the stored numbers are the low ends, and each location carries its full range.',
   'Rifts World Book 18: Mystic Russia p.141-142');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('gypsy-wagon', 'Chimney/Smokestack (1; small, metal)', 10, 'The book prints a RANGE of 10-20; the stored figure is the low end.', 1),
  ('gypsy-wagon', 'Windows (2-6)', 10, 'The book prints 10-30 each, and the count itself is a range of two to six; the stored figure is the low end.', 2),
  ('gypsy-wagon', 'Doors (2-3)', 50, 'The book prints 50-120 each; the stored figure is the low end. The exterior door is solid M.D.C. material with strong locks and a sliding bolt.', 3),
  ('gypsy-wagon', 'Trap Door (1 or 2)', 35, 'The book prints 35-50 each; the stored figure is the low end. These are the SECRET doors in the floor or roof that let Gypsies slip in and out unseen.', 4),
  ('gypsy-wagon', 'Wheels (4-6)', 20, 'The book prints 20-100 each; the stored figure is the low end, and the range is the widest on the entry.', 5),
  ('gypsy-wagon', 'Hitch for Horses or Cab (1 set)', 90, 'The book prints 90-150; the stored figure is the low end. Most wagons have a front AND a rear hitch, and as many as four can be hooked together and pulled.', 6),
  ('gypsy-wagon', 'Roof', 100, 'The book prints 100-250; the stored figure is the low end.', 7),
  ('gypsy-wagon', 'Cab/Pulling Vehicle (when applicable)', 250, 'The book prints 250+, a FLOOR rather than a range, and says the real figure varies dramatically with the vehicle - tractor, semi-truck cab, Land Rover, hover vehicle or even a tank. It also notes the puller is more likely to be a team of two to four Mega-Steeds, or a cyborg or a monster serving willingly, in indenture or in slavery.', 8),
  ('gypsy-wagon', 'Wagon (main body)', 225, 'The book prints 225-450; the stored figure is the low end, and it is also what mdc_main_body carries.', 9);

-- Read the result back. Every want is counted off the pages, not out of the
-- database.
SELECT 'the Gypsy Wagon' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'gypsy-wagon';

SELECT 'its nine M.D.C. locations' AS assertion, count(*) AS got, 9 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'gypsy-wagon';

-- 10 + 10 + 50 + 35 + 20 + 90 + 100 + 250 + 225, every figure a low end.
SELECT 'their low ends sum to the page' AS assertion, sum(mdc) AS got, 790 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'gypsy-wagon';

-- EVERY location on this entry is a range or a floor, which no other vessel in
-- the book does. If one ever loses its note the count drops.
SELECT 'every location records the range it came from' AS assertion, count(*) AS got, 9 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'gypsy-wagon'
   AND (instr(mdc_note, 'low end') > 0 OR instr(mdc_note, 'FLOOR') > 0);

SELECT 'it has no weapons' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'gypsy-wagon';

SELECT 'and no price' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'gypsy-wagon' AND cost IS NULL AND cost_note IS NOT NULL;

-- BATCH 5 IS NOW COMPLETE: seven vessels from this book and no more.
SELECT 'the book''s seven vessels are all in' AS assertion, count(*) AS got, 7 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 18: Mystic Russia%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-russia-gypsy-wagon.sql');
