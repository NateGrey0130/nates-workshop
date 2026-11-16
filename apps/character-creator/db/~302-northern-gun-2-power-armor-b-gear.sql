-- Rifts World Book 34: Northern Gun Two, the separately priced Cougar flamethrower, Deathmark rifle and Wild Coyote Jet Pack (printed 75-77)
-- 3 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~302-northern-gun-2-power-armor-b-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-x114-cougar-forearm-flamethrower', 'Cougar Forearm Flamethrower', 'rifts', 'weapon', NULL, 50000, '50,000 credits as an alternative modular attachment for the Cougar power armor, which carries one on the left forearm as standard.', '3D6 M.D. to the target and anyone within 10 ft (3 m), double to beings vulnerable to fire; 1D6 M.D. on diesel or gasoline', 1, '80 ft (24.4 m)', '3 bursts from a 6 gallon (22.7 liter) reserve of military napalm', 'Each burst counts as one melee action/attack', NULL, NULL, NULL, 'A compact flamethrower for the Cougar power armor''s forearm, mounted underneath or on top between the twin Vibro-Swords and fed by a 3 M.D.C. hose from a fuel tank at the hard-shell backpack. Used to clear bunkers and dug-in positions and against troops and fire-vulnerable monsters. Waterproof: valves seal it off underwater so no water reaches the napalm. Victims caught in a bunker, cave or unsealed vehicle without their own air save vs poison or pass out for 1D4 melee rounds.', 'Rifts World Book 34: Northern Gun Two p.75', NULL),
  ('ng-x132-deathmark-dual-sniper-rifle', 'NG-X132 "Deathmark" Dual Sniper Rifle', 'rifts', 'weapon', NULL, 35000, '35,000-50,000 credits on the secondary market, poor availability. Northern Gun does not sell it apart from the Coyote power armor, which comes with one.', 'Laser 3D6 M.D.; ion beam 4D6+2 M.D.; per single shot', 1, 'Laser 2,000 ft (610 m); ion beam 1,200 ft (366 m)', '20 laser blasts per standard E-Clip (in the handle); 10 ion blasts per E-Clip (in the stock)', 'Each blast counts as one melee attack; the laser or the ion beam, never both at once', NULL, NULL, NULL, 'The Coyote power armor''s own assassin''s rifle: an over-under precision weapon with a single-shot ion rifle on top and a single-shot laser below, the laser reaching farther and the ion beam hitting harder. Well balanced, with a telescopic passive nightvision scope (2,000 ft/610 m) and a removable sling. +1 to strike on an Aimed/Called Shot. Suited to sniping and to knocking out sensor pods, tires and antennas.', 'Rifts World Book 34: Northern Gun Two p.76-77', NULL),
  ('ng-wild-coyote-jet-pack', 'Wild Coyote Jet Pack', 'rifts', 'gear', 40, 52000, '52,000 credits combustion, 70,000 electric, 290,000 Solid Oxide, 910,000 nuclear; the lowest is stored. Standard with the Coyote power armor.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 35, 'Northern Gun''s newest and most compact personal jet pack, made for short hops, boarding ships and commando raids. It clips as a backpack onto mountings in non-environmental armor, EBA and light power armor, and is not safe for anyone unarmored. It takes voice or code commands through the armor''s or helmet''s communications, or typed codes from a mini wrist computer. Carries one armored rider at up to 80 mph (128 km), with a ceiling of 900 ft (274 m). Range: combustion 200 miles (320 km), electric 600 miles (960 km), Solid Oxide 1,200 miles (1,920 km), nuclear unlimited over a ten year life. On power armor it can be wired to the suit''s power for unlimited flight, though 96% of users keep it a separate, removable unit. Size 2.4 ft (0.73 m). No built-in weapons; the flyer can use ordinary handguns and rifles in the air.', 'Rifts World Book 34: Northern Gun Two p.77', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 3 gear rows are in' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug IN ('ng-x114-cougar-forearm-flamethrower', 'ng-x132-deathmark-dual-sniper-rifle', 'ng-wild-coyote-jet-pack') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~302-northern-gun-2-power-armor-b-gear.sql');
