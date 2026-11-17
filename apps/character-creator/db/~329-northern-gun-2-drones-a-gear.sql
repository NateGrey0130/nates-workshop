-- Rifts World Book 34: Northern Gun Two, the DX-202 Cargo Walker Combat Kit and its two priced options (printed 239)
-- 3 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~329-northern-gun-2-drones-a-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-dx202-cargo-walker-combat-kit', 'Cargo Walker Combat Kit (DX-202)', 'rifts', 'gear', NULL, 2500000, '2.5 million credits for the whole kit, items 1-8. Sensors and further weapons are extra.', 'Ion blaster arm 4D6+3 M.D.; shoulder rail gun 1D4x10 M.D. per 30-round burst; silver-edged Vibro-Sword arm 4D6 M.D.; shoulder laser 5D6 M.D.; mini-missiles usually 1D4x10 M.D. high-explosive or 1D6x10 M.D. plasma', 1, 'Ion blaster 1,800 ft (549 m); rail gun 4,000 ft (1,219 m); laser 2,000 ft (610 m); mini-missiles one mile; sword melee, 8 ft (2.4 m) reach', 'Ion blaster and laser unlimited off the robot''s power; rail gun 3,000 rounds (100 bursts, anti-monster rounds sold separately); 16 mini-missiles, four per tube', 'Each blast or burst is one melee attack; the rail gun fires bursts only; mini-missiles singly or in volleys of two, three, four or six', NULL, NULL, NULL, 'NG''s own conversion kit for the DX-202 Cargo Walker; a skilled Operator needs 1D4+2 weeks to fit it, half that with a team. 1. Extra armour welded to the frame: +20% M.D.C. on arms, legs and main body. 2. The pilot''s cage closed in (100 M.D.C.), still non-environmental and still one seat. 3. Removing the back crane gives a top running speed of 58 mph (93 km). 4. A combat computer, useless without sensors (NG''s top model is 2.5 million credits on its own, comparable to the Coalition''s; half that used on the Black Market). 5. Right forklift replaced by a heavy ion blaster arm, Robot P.S. dropping to 35; the small 30 P.S. utility arm (4 ft/1.2 m reach) stays. 6. A rail gun behind and above the right shoulder with a 180 degree arc forward, up and back. 7. Left forklift replaced by a huge serrated Vibro-Sword with a silver-plated edge, also good for felling and cutting up trees. 8. A shoulder pairing of a laser cannon and a four-tube mini-missile launcher. 9. Or the pilot fights hand to hand at Robot P.S. 35 (30 with the extra forward arms). Extras sold separately: a sensor package (1.1 million) and extra forward robot arms (3.5 million) are their own rows; up to four hovercycle weapon options, mostly mounted on arms or roof, or a single heavy weapon taken from another robot, are priced per weapon.', 'Rifts World Book 34: Northern Gun Two p.239', NULL),
  ('ng-dx202-cargo-walker-sensor-package', 'Sensor Package (Cargo Walker Combat Kit option)', 'rifts', 'gear', NULL, 1100000, '1.1 million credits.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 30, 'An add-on sensor array for the DX-202 Cargo Walker, usually on the left shoulder, giving the sensorless robot all the standard robot sensors and communications and linking them to its combat computer and the pilot''s HUD. Without it, Heavy Ground Robot piloting bonuses are halved.', 'Rifts World Book 34: Northern Gun Two p.239', NULL),
  ('ng-dx202-cargo-walker-forward-robot-arms', 'Additional Forward Robot Arms (Cargo Walker Combat Kit option)', 'rifts', 'gear', NULL, 3500000, '3.5 million credits.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Extra forward arms for the DX-202 Cargo Walker, Robot P.S. 30, usable in hand to hand combat with damage and bonuses by Robot P.S. and Ground Robot Training (Rifts Ultimate Edition p.352). With them fitted, the combat-kit walker fights at Robot P.S. 30 rather than 35.', 'Rifts World Book 34: Northern Gun Two p.239', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 3 gear rows are in' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug IN ('ng-dx202-cargo-walker-combat-kit', 'ng-dx202-cargo-walker-sensor-package', 'ng-dx202-cargo-walker-forward-robot-arms') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~329-northern-gun-2-drones-a-gear.sql');
