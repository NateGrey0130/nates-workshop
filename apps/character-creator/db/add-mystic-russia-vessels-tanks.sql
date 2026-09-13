-- The three Sovietski tanks, from Rifts World Book 18: Mystic Russia printed
-- 164-170. Three vehicles, 43 M.D.C. locations, 18 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-russia-vessels-tanks.sql
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1). None of
-- these pages is on the welded or glyph-corrupt list; all are on the
-- digit-substitution one.
--
-- DICE THE TEXT LAYER SETS WRONG are read as the only dice they can be
-- (BOOK-INGEST-AUDIT F53): !D4xlO is 1D4x10, !D6xlO is 1D6x10, 2D6xlO is
-- 2D6x10, "2D4x 10+20" is 2D4x10+20, and the Maelstrom's mini-missile line
-- prints "lD6x 10" - an l, and a space - for 1D6x10.
--
-- ALL THREE PRINT A SINGLE MAIN BODY, so all three carry `mdc_main_body`.
-- That is the opposite of the transports, where two of three print several and
-- the column is NULL by design; see
-- add-mystic-russia-vessels-transports.sql.
--
-- FOUR BOOK SLIPS, STORED AS PRINTED AND NOTED WHERE THEY SIT:
--
--   printed 165  the Groundthunder's "Medium-Range Missile Launcher (1; rear)
--                - 130 each". One launcher, and an "each".
--   printed 166  its main gun is headed "SGT-SO High-Powered Cannon". SO is
--                almost certainly 50, but a designation is not a dice
--                expression and has no forced reading, so it is stored as
--                printed rather than corrected.
--   printed 167  the Hailstorm's Length reads "3 8 feet (11.6m)". 11.6 m IS 38
--                feet, so the space is a text-layer artifact and the figure is
--                not in doubt.
--   printed 168  the Hailstorm's mini-missile launchers are introduced as "a
--                pair of six shot mini-missile launchers" and then given a
--                payload of "48 total; 24 per each launcher". Six and 24 cannot
--                both be right. Both figures are recorded; neither is chosen.
--
-- A fifth is cosmetic: the Maelstrom's smoke dispensers say they can "cover the
-- APC if it is stationary", wording carried over from the Groundthunder. The
-- Maelstrom is a tank.
--
-- Descriptions are paraphrases, never the book's prose.
--
-- No production row collided with any slug or name below (checked --remote
-- 2026-09-13).

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('groundthunder-heavy-tread-tank', '"Groundthunder" Heavy Tread Tank', 'rifts', 'vehicle',
   'Five: a pilot, a co-pilot/gunner, two gunners, and a communications officer, field scientist or intelligence officer.',
   'One more can squeeze into the crew compartment, but quarters are cramped.',
   '90 mph (144.8 km) - excellent speed for a tread-driven tank.',
   'None.',
   'NOT AMPHIBIOUS, though it can slosh through water up to its turret, roughly five feet (1.5 m), without trouble.',
   'Height 10 feet (3 m) overall; the lower main body is only 5 feet 3 inches (1.55 m) and the turret with the medium-range missile launcher and sensor tower adds another 5 feet (1.5 m). Width 11 feet (3.3 m). Length 16 feet (4.87 m).',
   '21 tons unloaded',
   375, 18000000,
   '18 million credits. Exclusive to the Sovietski military and not available on the Black Market.',
   'Model Type SU-52. Class: Assault Tank. One of the last pre-Rifts ground assault tanks, built on the traditional and less expensive tread pattern. Not as fast or as versatile as the later hover tanks, but 100% reliable: it takes a beating and keeps running, rarely breaks down in the field, is comparatively easy to pilot, and carries an impressive battery of weapons. Its front M.D.C. wheels are spiked, for traction and for crushing infantry. The heavily armoured turret turns 360 degrees and holds the main gun, the medium-range missile launcher, the hatch gun, a spotlight, a large searchlight and the smoke dispensers; the mini-missile launcher and laser turret are tucked below the cannon in the forward section. THE SOVIETSKI FIELDS 3,600 OF THEM: six A-3 Armored Tank Battalions of 600 Groundthunders, 20 Hailstorms and 20 Maelstroms each. Colour typically grey or camouflage. No cargo. Nuclear, average energy life 20 years, indefinite mileage without overheating. Destroying one tread cuts speed by 50% and costs -20% piloting on sharp turns and special manoeuvres; destroying both immobilises it.',
   'Rifts World Book 18: Mystic Russia p.164-166'),

  ('hailstorm-medium-hover-tank', '"Hailstorm" Medium Hover Tank', 'rifts', 'vehicle',
   'Five or six: a pilot, a co-pilot/gunner, two gunners, a communications officer and sometimes one more, typically a field scientist or intelligence officer.',
   'Two more can squeeze into the crew compartment, cramped. The rear cargo bay typically carries a squad of six Light Machines, four to six Heavy Machines with jet packs, and two to six Thunderstrike Cyborg Shocktroopers.',
   '160 mph (256 km).',
   '160 mph (256 km), maximum altitude 2,000 feet (610 m).',
   'It can jet across the surface of water provided it holds at least 50 mph (80 km). It CANNOT go into or under water.',
   'Height 24 feet (7.3 m) overall; the main body is 14 feet (4.3 m) and the big gun adds another 10 feet (3 m). Width 15 feet (4.6 m). Length 38 feet (11.6 m) - the page prints "3 8 feet", a text-layer space.',
   '20 tons unloaded',
   410, 26000000,
   '26 million credits. Exclusive to the Sovietski military and not available on the Black Market. The book adds that it is expensive even so, and that approximately 960 are in service.',
   'Model Type SUH-86. Class: Assault Hover Tank. An unusual pre-Rifts design: classified as a tank but really a combination APC and tank. As a tank it carries a huge rail cannon, hidden pop-up mini-missile launchers, a forward laser turret and a pair of medium-range missile launchers. As a troop carrier the crew sit in the compartment with the two spotlights and the rest of the vehicle is given over to the high-powered hover system and the rear cargo bay. Its troops often jettison into combat while the Hailstorm is flying at full speed, which is what it is for: troop support, extraction and rescue, air drops and surgical strikes. Colour typically blue-grey or camouflage. No cargo beyond the bay. Nuclear, average energy life 20 years, indefinite mileage. Destroying four hover jets cuts speed by 50% and costs -20% piloting on sharp turns; destroying more than six immobilises it.',
   'Rifts World Book 18: Mystic Russia p.166-168'),

  ('maelstrom-medium-heavy-hover-tank', '"Maelstrom" Medium-Heavy Hover Tank', 'rifts', 'vehicle',
   'Five or six: a pilot, a co-pilot/gunner, two gunners, a communications officer and sometimes one more, typically a field scientist or intelligence officer.',
   'Two more can squeeze into the crew compartment, but quarters are cramped.',
   '120 mph (192 km). It normally hovers three to four feet (0.9 to 1.2 m) up, can rise as high as 20 feet (6 m), and can jump up to 60 feet (18.3 m).',
   'See the ground speed; it is a hover vehicle rather than a flyer.',
   'Hovers across the surface at 100 mph (160 km), AND CAN SUBMERGE to an ocean depth of 1,500 feet (457 m), travelling about 25 miles an hour (40 km / 21 knots) underwater. It cannot open its hatches underwater without flooding and sinking.',
   'Height 11 feet (3.3 m) overall - a low profile; the main body is 9 feet (2.7 m) and the targeting box and rail gun add another two feet (0.6 m). Width 11 feet (3.3 m). Length 20 feet (6 m).',
   '18 tons unloaded',
   540, 32000000,
   '32 million credits. Exclusive to the Sovietski military and not available on the Black Market. The book calls it very expensive and says there are only 480 in service.',
   'Model Type SUH-88. Class: Assault Hover Tank. A compact, low-profile, fast and powerful frontline hover tank on six large hover jets - three a side - plus three down the middle of the undercarriage. IT CARRIES A STEALTH SYSTEM THAT MAKES IT INVISIBLE TO RADAR. Its main weapon is a high-powered plasma cannon, something of an experiment for the Sovietski military: based on pre-Rifts designs, it took years to develop, and its range is inferior to a rail gun or a cannon while its payload is effectively unlimited. Around it sit a rack of medium-range missiles, a forward drum-style ion turret, a pop-up mini-missile launcher on top of the main cannon, a manned rail gun behind it, and 16 concealed mini-missile tubes built along the sides and back of the turret. Colour typically blue-grey or camouflage. Minimal cargo. Nuclear, average energy life 20 years, indefinite mileage. Destroying four hover jets cuts speed by 50% and costs -20% piloting on sharp turns; destroying more than six immobilises it.',
   'Rifts World Book 18: Mystic Russia p.169-170');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('groundthunder-heavy-tread-tank', 'Cannon Turret Housing', 300, NULL, 1),
  ('groundthunder-heavy-tread-tank', 'Main Cannon (1)', 150, NULL, 2),
  ('groundthunder-heavy-tread-tank', 'Medium-Range Missile Launcher (1; rear)', 130, 'The page prints "130 each" for a count of one. A book slip, stored as printed.', 3),
  ('groundthunder-heavy-tread-tank', 'Hatch Rail Gun (1; side)', 90, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 4),
  ('groundthunder-heavy-tread-tank', 'Low Profile Laser Turret (1; front)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 5),
  ('groundthunder-heavy-tread-tank', 'Mini-Missile Launcher (1; front)', 90, NULL, 6),
  ('groundthunder-heavy-tread-tank', 'Smoke/Gas Dispensers (6; per side)', 5, '5 each, six on each side of the tank.', 7),
  ('groundthunder-heavy-tread-tank', 'Main Hatch (1; front, top)', 150, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 8),
  ('groundthunder-heavy-tread-tank', 'Sensor Tower (1; rear)', 35, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 9),
  ('groundthunder-heavy-tread-tank', 'Gunner''s Hatch (1; top of turret)', 150, NULL, 10),
  ('groundthunder-heavy-tread-tank', 'Armor Covered Treads (2)', 120, '120 each. Destroying one cuts speed by 50% and costs -20% piloting on sharp turns and special manoeuvres; destroying both immobilises the tank.', 11),
  ('groundthunder-heavy-tread-tank', 'Reinforced Crew Compartment', 170, 'Depleting the main body exposes it.', 12),
  ('groundthunder-heavy-tread-tank', 'Main Body', 375, 'Depleting its M.D.C. shuts the tank down completely and exposes the inner reinforced crew compartment.', 13),

  ('hailstorm-medium-hover-tank', 'Main Cannon (1)', 280, NULL, 1),
  ('hailstorm-medium-hover-tank', 'Medium-Range Missile Launchers (2; sides)', 130, '130 each.', 2),
  ('hailstorm-medium-hover-tank', 'Forward Laser Turret (1)', 100, NULL, 3),
  ('hailstorm-medium-hover-tank', 'Pop-Up Mini-Missile Launchers (2; near cannon)', 80, '80 each.', 4),
  ('hailstorm-medium-hover-tank', 'Main Hatch (1; front, top)', 150, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 5),
  ('hailstorm-medium-hover-tank', 'Concealed Hatch (1; rear, floor)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 6),
  ('hailstorm-medium-hover-tank', 'Concealed Door (1; crew compartment)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 7),
  ('hailstorm-medium-hover-tank', 'Rear Bay Door (1; rear)', 35, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike. Note this is the WEAKEST location on the tank, on the door its troops disembark through.', 8),
  ('hailstorm-medium-hover-tank', 'Spotlights (2; crew compartment)', 6, '6 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 9),
  ('hailstorm-medium-hover-tank', 'Headlights (7)', 4, '4 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 10),
  ('hailstorm-medium-hover-tank', 'Bottom Hover Jets (12; six per side)', 120, '120 each. Destroying four cuts speed by 50% and costs -20% piloting on sharp turns and special manoeuvres; destroying more than six immobilises the tank.', 11),
  ('hailstorm-medium-hover-tank', 'Side Jet Thrusters (2; sides)', 150, '150 each.', 12),
  ('hailstorm-medium-hover-tank', 'Reinforced Crew Compartment', 200, 'Depleting the main body exposes it.', 13),
  ('hailstorm-medium-hover-tank', 'Main Body', 410, 'Depleting its M.D.C. shuts the tank down completely and exposes the inner reinforced crew compartment.', 14),

  ('maelstrom-medium-heavy-hover-tank', 'Main Turret', 360, NULL, 1),
  ('maelstrom-medium-heavy-hover-tank', 'Main Cannon (1)', 250, NULL, 2),
  ('maelstrom-medium-heavy-hover-tank', 'Hatch Rail Gun (1)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 3),
  ('maelstrom-medium-heavy-hover-tank', 'Ball-Ion Turret (1; front)', 70, NULL, 4),
  ('maelstrom-medium-heavy-hover-tank', 'Pop-Up Mini-Missile Launcher (1; near cannon)', 70, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 5),
  ('maelstrom-medium-heavy-hover-tank', 'Mini-Missile Launch Tubes (16; main turret)', 6, '6 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 6),
  ('maelstrom-medium-heavy-hover-tank', 'Medium-Range Missile Launcher (1; rear)', 90, NULL, 7),
  ('maelstrom-medium-heavy-hover-tank', 'Main Hatches (2; front & top)', 150, '150 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 8),
  ('maelstrom-medium-heavy-hover-tank', 'Concealed Hatch (1; rear, floor)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 9),
  ('maelstrom-medium-heavy-hover-tank', 'Box Targeting & Sensor System (1; cannon)', 100, NULL, 10),
  ('maelstrom-medium-heavy-hover-tank', 'Secondary Sensor Cluster (1; main turret)', 20, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 11),
  ('maelstrom-medium-heavy-hover-tank', 'Spotlight (1; Main Turret)', 8, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 12),
  ('maelstrom-medium-heavy-hover-tank', 'Headlights (5)', 4, '4 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 13),
  ('maelstrom-medium-heavy-hover-tank', 'Bottom Hover Jets (9)', 100, '100 each. Destroying four cuts speed by 50% and costs -20% piloting on sharp turns and special manoeuvres; destroying more than six immobilises the tank.', 14),
  ('maelstrom-medium-heavy-hover-tank', 'Reinforced Crew Compartment', 220, 'Depleting the main body exposes it.', 15),
  ('maelstrom-medium-heavy-hover-tank', 'Main Body', 540, 'Depleting its M.D.C. shuts the tank down completely and exposes the inner reinforced crew compartment.', 16);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, note) VALUES
  ('groundthunder-heavy-tread-tank', 1, 'SGT-SO High-Powered Cannon (1)', '1D4x10 M.D. per single blast.', 1,
   '6,000 feet (1828 m) maximum effective.', 'Four per melee round.', '60 rounds.',
   'The big gun: a high-powered long-range cannon in a swivel housing offering 360 degree rotation, though the entire top turret turns with it. Arc of fire 45 degrees up and down. The page heads it "SGT-SO"; SO is almost certainly 50, but a model designation has no forced reading the way a dice expression does, so it is stored as printed. Primary purpose: anti-armour. Secondary: anti-personnel and defence.'),
  ('groundthunder-heavy-tread-tank', 2, 'Hatch Rail Gun', 'A full damage burst is 40 rounds and inflicts 1D4x10 M.D. At the flip of a switch it fires short 10 round bursts for 2D6 M.D.', 1,
   '4,000 feet (1220 m) maximum effective.', 'Equal to the combined hand to hand attacks of the gunner, usually 4-6.',
   'An 8,000 round drum feed: 200 full bursts or 800 short ones. Reloading takes about 20 minutes untrained, five for someone with engineering or field armorer skills.',
   'Fired remotely from inside the tank or manually by a hatch gunner. Rotates 360 degrees with a 45 degree arc up and down. Primary purpose: anti-aircraft. Secondary: anti-personnel and defence.'),
  ('groundthunder-heavy-tread-tank', 3, 'Low Profile Laser Turret (1)', '4D6 M.D. per single blast.', 1,
   '1,200 feet (366 m).', 'Equal to the combined hand to hand attacks of the gunner, usually 3-6.', 'Effectively unlimited.',
   'A heavy laser that rotates 90 degrees side to side with a 45 degree arc. Primary purpose: anti-armour. Secondary: anti-personnel.'),
  ('groundthunder-heavy-tread-tank', 4, 'Medium-Range Missile Launcher (1)', 'Varies with missile type; heavy missiles are standard.', 1,
   '40-60 miles (64.3 to 96.9 km) for medium-range missiles.', 'One at a time, or in volleys of two or three.', 'Six total.',
   'In the rear, taking short or medium-range missiles; medium are standard issue. Typically worked by one of the gunners. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('groundthunder-heavy-tread-tank', 5, 'Mini-Missile Launcher (1)', 'Varies with missile type; standard issue is fragmentation at 5D6 M.D. and plasma at 1D6x10 M.D.', 1,
   'About one mile.', 'One at a time, or in volleys of 2, 3, 6 or 9.', '36 total.',
   'A nine shot launcher in the front of the vehicle, worked by one of the gunners. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('groundthunder-heavy-tread-tank', 6, 'Smoke Dispensers (12)', 'None; it releases smoke or tear gas.', 0,
   'Covers an 80 foot (24 m) area behind the tank, or the tank itself if it is stationary.', NULL,
   '12 total. The usual mix is eight smoke and four tear gas.',
   'Six units mounted on each side.'),
  ('groundthunder-heavy-tread-tank', 7, 'Close Combat', 'Bouncing a target off the side 2D6 M.D.; running one over 1D6x10 M.D.; ramming 4D6 M.D.', 1,
   'Contact.', NULL, 'Not applicable.',
   'The Groundthunder can run over enemy troops and smash through light M.D.C. walls and barriers.'),

  ('hailstorm-medium-hover-tank', 1, 'SRG-500 High-Powered Rail Cannon (1)', 'A full damage burst is 80 rounds and inflicts 2D6x10 M.D. At the flip of a switch it fires 40 round bursts for 1D6x10 M.D.', 1,
   '8,000 feet (2438 m) maximum effective - the longest reach of any weapon in this book.',
   'Equal to the combined hand to hand attacks of the gunner, usually 4-7.',
   'A 24,000 round drum feed: 300 full bursts or 600 short ones. Reloading takes about 20 minutes untrained, five for someone with engineering or field armorer skills.',
   'The big gun rotates 360 degrees with a 45 degree arc up and down. The page heads it "Higb-Powered". Primary purpose: anti-armour. Secondary: anti-aircraft and dragons.'),
  ('hailstorm-medium-hover-tank', 2, 'Ball-Laser Turret (1)', '4D6 M.D. per single blast.', 1,
   '2,000 feet (610 m).', 'Equal to the combined hand to hand attacks of the gunner, usually 4-6.', 'Effectively unlimited.',
   'A heavy laser that rotates 180 degrees side to side and up and down. Primary purpose: anti-missile and anti-armour. Secondary: anti-personnel.'),
  ('hailstorm-medium-hover-tank', 3, 'Medium-Range Missile Launchers (2)', 'Varies with missile type; heavy missiles are standard.', 1,
   '40-60 miles (64.3 to 96.9 km) for medium-range missiles.', 'One at a time, or in volleys of two or three.', 'Six total.',
   'A pair on the sides, taking short or medium-range missiles; medium are standard issue. Typically worked by one of the gunners. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('hailstorm-medium-hover-tank', 4, 'Pop-Up Mini-Missile Launchers (2)', 'Varies with missile type; standard issue is fragmentation at 5D6 M.D. and plasma at 1D6x10 M.D.', 1,
   'About one mile.', 'One at a time, or in volleys of two, three or four.',
   '48 total, 24 per launcher - BUT the same paragraph introduces them as "a pair of six shot mini-missile launchers". Six and 24 cannot both be right; both figures are recorded and neither is chosen.',
   'A pair located near the main gun, worked by one of the gunners. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),

  ('maelstrom-medium-heavy-hover-tank', 1, 'SPC-100 High-Powered Plasma Cannon (1)', '2D4x10+20 M.D. per blast.', 1,
   '4,000 feet (1220 m) maximum effective.', 'Equal to the combined hand to hand attacks of the gunner, usually 4-7.', 'Effectively unlimited.',
   'The turret rotates 360 degrees and the cannon has a 45 degree arc up and down. AFTER 50 BLASTS WITHOUT A BREAK IT SHUTS DOWN FOR ONE MINUTE TO COOL. An experiment for the Sovietski military, based on pre-Rifts designs and years in development: shorter ranged than a rail gun or cannon, but its payload never runs out. Primary purpose: anti-armour. Secondary: anti-aircraft and dragons.'),
  ('maelstrom-medium-heavy-hover-tank', 2, 'Ball-Ion Turret (1)', '6D6 M.D. per single blast.', 1,
   '1,400 feet (426.7 m).', 'Equal to the combined hand to hand attacks of the gunner, usually 4-6.', 'Effectively unlimited.',
   'A heavy ion turret rotating 180 degrees side to side and up and down. Primary purpose: ANTI-MONSTER. Secondary: anti-personnel and defence.'),
  ('maelstrom-medium-heavy-hover-tank', 3, 'Hatch Rail Gun', 'A full damage burst is 40 rounds and inflicts 1D4x10 M.D. At the flip of a switch it fires short 10 round bursts for 2D6 M.D.', 1,
   '4,000 feet (1220 m) maximum effective.', 'Equal to the combined hand to hand attacks of the gunner, usually 4-6.',
   'An 8,000 round drum feed: 200 full bursts or 800 short ones. Reloading takes about 20 minutes untrained, five for someone with engineering or field armorer skills.',
   'Fired remotely from inside the tank or manually by a hatch gunner. Rotates 360 degrees with a 45 degree arc up and down. Primary purpose: anti-aircraft. Secondary: anti-personnel and defence.'),
  ('maelstrom-medium-heavy-hover-tank', 4, 'Pop-Up Mini-Missile Launcher (1)', 'Varies with missile type; standard issue is fragmentation at 5D6 M.D. and plasma at 1D6x10 M.D.', 1,
   'About one mile.', 'One at a time, or in volleys of two or four.', '32 total.',
   'Sits on the plasma cannon next to the box targeting sensor. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('maelstrom-medium-heavy-hover-tank', 5, 'Concealed Mini-Missile Launch Tubes (16)', 'Varies with missile type; standard issue is fragmentation at 5D6 M.D. and plasma at 1D6x10 M.D.', 1,
   'About one mile.', 'One at a time, or in volleys of 2, 3 or 4.', '32 total, two missiles per launch tube.',
   'All sixteen sit on the cannon turret. The book gives them the same stats as the pop-up launcher except for payload and rate of fire. Worked by one of the gunners.'),
  ('maelstrom-medium-heavy-hover-tank', 6, 'Medium-Range Missile Launcher (1)', 'Varies with missile type; heavy missiles are standard.', 1,
   '40-60 miles (64.3 to 96.9 km) for medium-range missiles.', 'One at a time, or in volleys of two or three.', 'Six total.',
   'In the rear, taking short or medium-range missiles; medium are standard issue. Typically worked by one of the gunners. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('maelstrom-medium-heavy-hover-tank', 7, 'Smoke Dispensers (2)', 'None; it releases smoke or tear gas.', 0,
   'Covers an 80 foot (24 m) area behind the tank, or the tank itself if it is stationary.', NULL, 'Four, two in each unit.',
   'A pair mounted on the rear. The book''s wording says the cloud can "cover the APC if it is stationary" - carried over from the Groundthunder entry; the Maelstrom is a tank.');

-- Read the result back. INSERT OR IGNORE is SILENT on a collision, so the
-- counts are what prove nothing was lost. Every want is counted off the stat
-- blocks, not out of the database.
SELECT 'the three tanks' AS assertion, count(*) AS got, 3 AS want
  FROM vehicles WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.164-166', 'Rifts World Book 18: Mystic Russia p.166-168', 'Rifts World Book 18: Mystic Russia p.169-170');

SELECT 'their M.D.C. locations: 13 + 14 + 16' AS assertion, count(*) AS got, 43 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('groundthunder-heavy-tread-tank', 'hailstorm-medium-hover-tank', 'maelstrom-medium-heavy-hover-tank');

SELECT 'their weapon entries: 7 + 4 + 7' AS assertion, count(*) AS got, 18 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('groundthunder-heavy-tread-tank', 'hailstorm-medium-hover-tank', 'maelstrom-medium-heavy-hover-tank');

-- 375 + 410 + 540. All three print ONE main body, unlike two of the three
-- transports; if a later reading split one of these the sum moves.
SELECT 'all three carry a single main body, summing to 1325' AS assertion, sum(mdc_main_body) AS got, 1325 AS want
  FROM vehicles WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.164-166', 'Rifts World Book 18: Mystic Russia p.166-168', 'Rifts World Book 18: Mystic Russia p.169-170');

-- 18 + 26 + 32 million.
SELECT 'their prices sum to the pages' AS assertion, sum(cost) AS got, 76000000 AS want
  FROM vehicles WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.164-166', 'Rifts World Book 18: Mystic Russia p.166-168', 'Rifts World Book 18: Mystic Russia p.169-170');

-- THE ONLY NON-MEGA-DAMAGE ENTRIES ARE THE TWO SMOKE DISPENSERS. This want was
-- 3 on the first --remote apply and the assertion caught it: the Groundthunder's
-- Close Combat entry had been counted as a third, and it is not one - running a
-- man over does 1D6x10 M.D. and ramming does 4D6 M.D. No row was wrong, only
-- this constant, and correcting a readback constant writes nothing.
SELECT 'only the two smoke dispenser entries are not M.D. weapons' AS assertion, count(*) AS got, 2 AS want
  FROM vehicle_weapons WHERE is_mega_damage = 0
   AND vehicle_slug IN ('groundthunder-heavy-tread-tank', 'hailstorm-medium-hover-tank', 'maelstrom-medium-heavy-hover-tank');

-- The Hailstorm's contradiction must survive as a contradiction.
SELECT 'the Hailstorm keeps both of its mini-missile payload figures' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'hailstorm-medium-hover-tank'
   AND instr(payload, 'six shot') > 0 AND instr(payload, '48 total') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-russia-vessels-tanks.sql');
