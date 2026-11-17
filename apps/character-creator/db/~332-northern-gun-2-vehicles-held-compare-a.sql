-- Two power armours the catalog already held follow Rifts World Book 34:
-- Northern Gun Two, their newest printing, and the Sky King becomes a vehicle.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~332-northern-gun-2-vehicles-held-compare-a.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~332-northern-gun-2-vehicles-held-compare-a.sql
--
-- Northern Gun Two reprints four machines production already held under
-- older citations: the Defender (J.A.P.E. II) and the Juicer Killer from
-- Rifts World Book 10: Juicer Uprising (the Juicer Killer held twice, as a
-- vehicles row and a gear row of the same slug), the Samson from Rifts
-- Ultimate Edition, and the Sky King, held only as a gear row citing the
-- original Rifts core book. Each was read off a render of Northern Gun Two
-- (PDF offset +1, printed 78-80, 106-110, 140-143 and 197-198), every M.D.C.
-- by Location block included, and compared with the held rows read whole from
-- production on 2026-11-16, locations and weapons included. By Nate's rulings
-- of 2026-10-04 (the newest printing that states a figure wins) and
-- 2026-11-16 (the held row takes this book's figure and its citation, and the
-- older figure goes in the description), a row where a figure differs is
-- UPDATED in place, its source_book moves to Northern Gun Two, the
-- description's own statement of the figure is corrected, and one sentence
-- appended to description gives the older figures and the book they came
-- from. Name and slug are unchanged; no row is deleted. A changed location or
-- weapon row belongs to its vehicle, and its vehicle carries the sentence.
--
-- A figure counts as differing when this book prints another value for a
-- column, or prints one where the column is empty. A location or weapon this
-- book lists that the row never carried is an addition, not a difference, and
-- no child row is added for one: the Juicer Killer's Collar, 90 (JK1B 110),
-- and Robot Weapon Arms (4), 50 (JK1B 60); the Defender's hand to hand
-- damage. A metric conversion of an unchanged imperial figure counts only on a
-- row that changes anyway.
--
-- Edited (4 held rows):
--   bm-japeii-defender-exoskeleton, vehicles (p.78-80): Robot P.S. 24 for 30;
--     running fatigue 30% at 90 mph and over; hover 1D4 melee rounds; water
--     speed and depth where none was held; head 90 for 100; forearm lasers
--     15 each (three) for 35; shoulder grenade launchers 35 each apart from
--     the 65 shoulder plates; laser damage, range and rate; capture system
--     damage, range, rate and payload; grenade standard issue; rifle range
--     rolled per shot.
--   ng-jk1-juicer-killer-power-armor, vehicles (p.106-110): running fatigue
--     20%; only the JK1B makes the thruster leap; water walking where none was
--     held; 1.5 million off without the computer, not 2 million; forearm guns
--     30 each (JK1B 50) for 40 (60); particle beams 5D6+6 a blast with no
--     double blast; each weapon arm two attacks a melee; the computer's bonuses
--     where none were held.
--   ng-jk1-juicer-killer-power-armor, gear (p.106-110): the same price, speed,
--     leap and forearm figures, and kick 2D4 M.D. with a 2D8 leap kick.
--   northern-gun-sky-king, gear (p.197-198): main body 155 for 130 (this
--     book's Mk II), jets cool after 24 hours, not twenty; it now names the
--     new vehicles row beside it.
--
-- Inserted (1 vehicle, 7 locations, 2 weapons), in the shape
-- scripts/vessel-sql.mjs writes, INSERT OR IGNORE on the slug:
--   ng-a70-sky-king (p.197-198), the NG-A70 Mk II Sky King. The gear row
--   above stays, re-cited beside it (Nate, 2026-11-16).
--
-- Left as it is, citation included (1):
--   ng-x9-samson-power-armor (p.140-143). This book prints the NG-X9 Mk III,
--     a later mark it sets apart from the Mk I the row holds (it says the Mk I
--     had P.S. 30 and a launcher on both forearms with no Tri-Laser, which is
--     the row). The Mk III's own figures (main body 320, Tri-Laser, fifteen
--     locations) would need child rows this script may not add; whether the
--     Mk III becomes a row of its own is Nate's.
--
-- Guarded on each row still citing its older book, and each child row on the
-- value it replaces, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION.
-- The tilde number is claimed at merge.

-- The Defender (J.A.P.E. II), printed 78-80.

UPDATE vehicles
   SET speed_ground = 'Running: 120 mph (192 km) maximum. Running tires the operator at 30% of the usual rate at 90 mph (144 km) and over, and at 10% below 70 mph (112 km).',
       speed_air = 'Not flight. Unassisted leaps reach 30 feet (9.1 m) high or across; a jet-assisted leap reaches 120 feet (36.6 m) high and 200 feet (61 m) across, and the thrusters hold a hover in place for up to 1D4 melee rounds before they overheat.',
       speed_water = 'Not designed for water, but swims or walks along the bottom at 3 mph (4.8 km/2.6 knots); maximum depth 500 feet (152 m). Swimming tires the wearer at 20% of the usual rate.',
       dimensions = 'Height 8 feet (2.4 m), width 2 feet 8 inches (0.8 m), length 4 feet (1.2 m)',
       description = replace(description, 'Physical strength equal to a P.S. of 30', 'Robot P.S. of 24')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, gave it a strength equal to P.S. 30, a 100 M.D.C. head, 35 M.D.C. forearm lasers doing 3D6 or 6D6 M.D., a 65 M.D.C. shoulder plate and launcher counted as one, a capture system doing 5D6 S.D.C. twice a melee, a hover of 2D4x10 seconds and a running fatigue of 10% at any speed.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.78-80'
 WHERE slug = 'bm-japeii-defender-exoskeleton'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.80-81';

UPDATE vehicle_locations
   SET mdc = 90,
       mdc_note = 'Reinforced; a called shot at -4 to strike. Destroying it costs all optical and sensory enhancement and the Robot Combat bonuses.'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Head' AND mdc = 100;

UPDATE vehicle_locations
   SET mdc_note = 'each, for the plates; the grenade launchers behind them are 35 each, a called shot at -4 to strike.'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Shoulder Plates/Grenade Launchers (2)'
   AND mdc_note = 'each';

UPDATE vehicle_locations
   SET mdc = 15,
       mdc_note = 'each; three in the right forearm, a called shot at -4 to strike.'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Forearm Mounted Variable Laser' AND mdc = 35;

UPDATE vehicle_weapons
   SET range = '1,200 feet (366 m) as built; in use it is rolled for every shot at 1D6x100+600 feet (213 to 366 m), a defect the Black Market never fixed',
       payload = 'Effectively unlimited tied into the power armour''s nuclear supply; a standard E-Clip gives 6 Setting One or 3 Setting Two blasts'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 1 AND range = '1200 feet (365 m)';

UPDATE vehicle_weapons
   SET damage = 'Varies with the grenade; any can be used, and standard issue is tear gas: a 25 foot (7.6 m) radius in which the unprotected are -10 to strike, parry and dodge, -3 on initiative and lose one melee attack, lasting 1D6+1 melee rounds after they leave it',
       range = '1,200 feet (366 m)',
       payload = '24 total, 12 per launcher, all of one type or a mixture'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 2 AND range = '1200 feet (365 m)';

UPDATE vehicle_weapons
   SET damage = '2D6 M.D. per single blast, 4D6 M.D. per double blast or 6D6 M.D. per simultaneous triple blast at one target',
       range = '1,200 feet (366 m) or closer; out to 2,000 feet (610 m) at -1 to strike',
       rate_of_fire = 'Each shot counts as one melee attack',
       payload = 'Effectively unlimited; each is tied into the armour''s power supply',
       note = 'Three medium-powered lasers in the right forearm, fired singly or linked; the suit''s targeting computer recalibrates their frequency to an opponent''s armour within 1D4 melee rounds.'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 3 AND damage = '3D6 M.D. or 6D6 M.D.';

UPDATE vehicle_weapons
   SET damage = 'None as a rule: it fires Mega-Damage polymer bolas that bind the legs. The cord has 12 M.D.C.; breaking free takes Supernatural P.S. 20 or Robot P.S. 28, and cutting free takes 1D4+1 melee actions. An entangled victim cannot run, loses initiative and has half his combat bonuses.',
       range = '300 feet (91.4 m)',
       rate_of_fire = 'One; it must be reloaded after every shot, which takes 1D4 melee attacks',
       payload = 'One, with 10 reloads standard'
 WHERE vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 4 AND damage = '5D6 S.D.C.';

-- The Juicer Killer, printed 106-110: the vehicles row, then its gear twin.

UPDATE vehicles
   SET speed_ground = 'Running: 90 mph (144 km) maximum. Running tires the operator at 20% of the usual fatigue rate, and at 10% below 50 mph (80 km).',
       speed_air = 'JK1A: none. Both models leap 25 feet (7.6 m) high and 30 feet (9.1 m) across unassisted, 30% farther with a running start; only the JK1B uses its thrusters for a leap of 100 feet (30.5 m) high or across. The JK1B''s upper-back thrusters (70 M.D.C.) also let it hover and fly in five-minute bursts at up to 100 mph (160 km), maximum altitude 300 feet (91.4 m), and land softly from as high as 400 feet (122 m).',
       speed_water = 'Cannot swim, but walks along the bottom at 10 mph (16 km/8.6 knots); maximum depth 500 feet (152 m).',
       dimensions = 'Height 7 feet (2.1 m), width 4.5 feet (1.37 m), length 4 feet (1.2 m)',
       cost_note = 'Black Market price for a stolen and refurbished suit: JK1A 3.6 million credits new and undamaged; the JK1B model 4.4 million. Drop the price by 1.5 million credits if the targeting computer is not included. Built exclusively for the Coalition Army; Northern Gun does not sell it.',
       description = description
         || ' Juicer Uprising, which this row followed before Northern Gun Two, had running tire the operator at 10% at any speed, gave both models the 100 foot thruster leap, took 2 million credits off a suit without its computer, gave the forearm mini-rail guns 40 M.D.C. each (60 on the JK1B), gave the particle beams 5D6 M.D. a blast or 1D6x10 for a double blast, and tied the gun arms'' attacks to those of the pilot or the computer.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.106-110'
 WHERE slug = 'ng-jk1-juicer-killer-power-armor'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.77-79';

UPDATE vehicle_locations
   SET mdc = 30,
       mdc_note = 'each; JK1B 50 each; a called shot at -4 to strike.'
 WHERE vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND location = 'Forearm Mini-Rail Guns (2)' AND mdc = 40;

UPDATE vehicle_weapons
   SET range = '4,000 feet (1,219 m)',
       rate_of_fire = 'Two attacks per melee round from each weapon arm, in addition to the pilot''s own attacks'
 WHERE vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 1 AND range = '4000 feet (1220 m)';

UPDATE vehicle_weapons
   SET damage = '5D6+6 M.D. per single blast from one weapon arm; the arms cannot be linked to fire at one target simultaneously',
       rate_of_fire = 'Two attacks per melee round from each weapon arm, in addition to the pilot''s own attacks'
 WHERE vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 2
   AND damage = '5D6 M.D. per blast, or 1D6x10 M.D. per double blast';

UPDATE vehicle_weapons
   SET bonus = 'Weapon arms: +2 on initiative, +1 to strike, +1 on an Aimed or Called Shot, and +2 to dodge an attack aimed at one; none under the pilot''s manual control'
 WHERE vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 5 AND bonus IS NULL;

UPDATE gear
   SET cost_note = 'Black Market price for a stolen and refurbished suit: 3.6 million credits for a new JK1A; the JK1B is 4.4 million. Drop 1.5 million credits if the targeting computer is not included.',
       range = 'Running 90 mph (144 km) maximum, tiring the operator at 20% of the usual rate (10% below 50 mph/80 km). JK1A cannot fly; the JK1B has upper-back thrusters (70 M.D.C.) for five-minute bursts at up to 100 mph (160 km) and 300 feet (91.4 m). Unassisted leap 25 feet (7.6 m) up or 30 feet (9.1 m) across; only the JK1B makes a thruster leap, 100 feet (30.5 m) high or across.',
       damage = replace(replace(damage, 'range 4,000 feet (1,220 m)', 'range 4,000 feet (1,219 m)'),
                        'kick 1D6 M.D.', 'kick 2D4 M.D., leap kick 2D8 M.D.'),
       description = replace(description, 'forearm mini-rail guns 40 each (60)', 'forearm guns 30 each (50)')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, had running tire the operator at 10% at any speed, gave both models the 100 foot thruster leap, took 2 million credits off a suit without its computer, gave the forearm mini-rail guns 40 M.D.C. each (60 on the JK1B) and its kick 1D6 M.D.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.106-110'
 WHERE slug = 'ng-jk1-juicer-killer-power-armor'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.77-88';

-- The Sky King, printed 197-198: a new vehicles row, then the gear row beside it.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('ng-a70-sky-king', 'NG-A70 Mk II Sky King', 'rifts', 'vehicle', 'One.', NULL, 'Not possible.', 'Hovers stationary up to 1,000 feet (305 m) or flies; 570 mph (912 km) maximum, cruising at 100 to 200 mph (160 to 320 km). Maximum altitude 10,000 feet (3,048 m). VTOL capable, landing on three struts that unfold from the undercarriage. The jet rockets must cool after 24 hours of continuous flight at top speed, or 48 hours at cruising speed.', 'None.', 'Height 17 feet (5.2 m), width 5 feet 6 inches (1.7 m), length 11 feet 5 inches (3.5 m)', '2,600 pounds (1,170 kg) fully loaded', 155, 1, NULL, 1500000, '1.5 million credits and up for a new, fully powered Sky King with laser, mini-missiles and rail guns; about half a million for a rebuilt cycle without weapon systems. Fair availability.', 'One of Northern Gun''s first and most famous combat aircraft: a heavy assault Sky Cycle that flies attack, reconnaissance, border patrol, escort and courier work, hovers, rides low to the ground and climbs to nearly two miles. The Mk II carries 20% more M.D.C. than the original. Class: All-Purpose Sky Cycle Air Combat Vehicle. Nuclear, average energy life 12 years. Minimal cargo: about four feet (1.2 m) behind the seat for clothing, weapons and personal items. Standard robot sensors and communications, including radar. +2 to dodge at cruising speeds and +5 to dodge above 350 mph (560 km). Destroying the top fin cuts speed and altitude by 30% and gives -15% to piloting; destroying the bottom fin cuts speed by 20% and gives -10% to piloting; the two penalties add.', 'Rifts World Book 34: Northern Gun Two p.197-198');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('ng-a70-sky-king', 'Forward Mounted Nose Laser', 40, 'A called shot at -4 to strike.', 1),
  ('ng-a70-sky-king', 'Rail Gun and Mini-Missile Launchers (2)', 50, 'each; a called shot at -4 to strike.', 2),
  ('ng-a70-sky-king', 'Landing Struts (3)', 20, 'each; a called shot at -4 to strike.', 3),
  ('ng-a70-sky-king', 'Rear Jets (2)', 50, 'each; a called shot at -4 to strike.', 4),
  ('ng-a70-sky-king', 'Top Fin', 90, 'A called shot at -4 to strike. Destroying it cuts speed and altitude by 30% and gives -15% to piloting.', 5),
  ('ng-a70-sky-king', 'Bottom Fin', 70, 'Destroying it cuts speed by 20% and gives -10% to piloting.', 6),
  ('ng-a70-sky-king', 'Main Body', 155, 'Depleting it shuts the vehicle down and knocks it out of the sky.', 7);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('ng-a70-sky-king', 1, 'NG-SK101 Dual Rail Gun and Mini-Missile Launcher (2)', 'Rail guns: 1D4x10 M.D. per 30 round burst from one, or 2D4x10 M.D. per dual burst from both at one target. Mini-missiles: by type; mini-torpedoes may replace them (2D4x10 M.D. high explosive or 1D6x10 M.D. plasma).', 1, 'Missiles one mile (1.6 km); rail guns 4,000 feet (1,219 m)', 'Missiles one at a time or in volleys of two; each rail gun burst counts as one melee attack', '12 mini-missiles, 6 in each side launcher; 810 rounds per rail gun, 27 bursts each', NULL, 'One rail gun and one mini-missile launcher on each side near the midsection. Assault, dogfights and anti-aircraft; also anti-personnel, anti-monster and anti-armor.'),
  ('ng-a70-sky-king', 2, 'Forward Mounted Heavy Laser (1)', '4D6 M.D. per blast', 1, '4,000 feet (1,219 m)', 'Each blast counts as one melee attack', 'Effectively unlimited', NULL, 'Fixed in the nose; fires straight ahead only. Assault and dogfights; also anti-personnel and defense.');

UPDATE gear
   SET mdc = 155,
       vehicle_slug = 'ng-a70-sky-king',
       description = replace(replace(description, 'after a maximum of twenty hours of flight', 'after a maximum of 24 hours of flight'),
                             'Height: 17 feet (5 m).', 'Height: 17 feet (5.2 m).')
         || ' The original Rifts core book, which this row followed before Northern Gun Two, gave the first model a 130 M.D.C. main body and had its jets cool after twenty hours above cruising speed; this book''s Mk II carries 20% more.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.197-198'
 WHERE slug = 'northern-gun-sky-king'
   AND source_book = 'Rifts RPG (original core book) p.228';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the four edited held rows cite Northern Gun Two' AS assertion, count(*) AS got, 4 AS want
  FROM (SELECT slug FROM vehicles
         WHERE (slug = 'bm-japeii-defender-exoskeleton' AND source_book = 'Rifts World Book 34: Northern Gun Two p.78-80')
            OR (slug = 'ng-jk1-juicer-killer-power-armor' AND source_book = 'Rifts World Book 34: Northern Gun Two p.106-110')
        UNION ALL
        SELECT slug FROM gear
         WHERE (slug = 'ng-jk1-juicer-killer-power-armor' AND source_book = 'Rifts World Book 34: Northern Gun Two p.106-110')
            OR (slug = 'northern-gun-sky-king' AND source_book = 'Rifts World Book 34: Northern Gun Two p.197-198'));

SELECT 'the edited held rows carry this book''s figures' AS assertion, count(*) AS got, 4 AS want
  FROM (SELECT slug FROM vehicles
         WHERE (slug = 'bm-japeii-defender-exoskeleton' AND instr(description, 'Robot P.S. of 24') > 0
                AND speed_water LIKE 'Not designed for water%' AND speed_ground LIKE '%at 30% of the usual rate%')
            OR (slug = 'ng-jk1-juicer-killer-power-armor' AND cost_note LIKE '%by 1.5 million credits%'
                AND speed_water LIKE 'Cannot swim%')
        UNION ALL
        SELECT slug FROM gear
         WHERE (slug = 'ng-jk1-juicer-killer-power-armor' AND instr(description, 'forearm guns 30 each (50)') > 0
                AND instr(damage, 'leap kick 2D8 M.D.') > 0 AND cost_note LIKE '%Drop 1.5 million%')
            OR (slug = 'northern-gun-sky-king' AND mdc = 155 AND vehicle_slug = 'ng-a70-sky-king'
                AND instr(description, 'after a maximum of 24 hours of flight') > 0));

SELECT 'the changed locations carry this book''s M.D.C.' AS assertion, count(*) AS got, 4 AS want
  FROM vehicle_locations
 WHERE (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Head' AND mdc = 90)
    OR (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Forearm Mounted Variable Laser' AND mdc = 15)
    OR (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND location = 'Shoulder Plates/Grenade Launchers (2)'
        AND mdc_note LIKE '%launchers behind them are 35 each%')
    OR (vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND location = 'Forearm Mini-Rail Guns (2)' AND mdc = 30);

SELECT 'the changed weapons carry this book''s figures' AS assertion, count(*) AS got, 7 AS want
  FROM vehicle_weapons
 WHERE (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 1 AND range LIKE '%1D6x100+600 feet%')
    OR (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 2 AND range = '1,200 feet (366 m)')
    OR (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 3 AND damage LIKE '2D6 M.D. per single blast%')
    OR (vehicle_slug = 'bm-japeii-defender-exoskeleton' AND ordinal = 4 AND range = '300 feet (91.4 m)')
    OR (vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 1 AND range = '4,000 feet (1,219 m)')
    OR (vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 2 AND damage LIKE '5D6+6 M.D.%')
    OR (vehicle_slug = 'ng-jk1-juicer-killer-power-armor' AND ordinal = 5 AND bonus LIKE 'Weapon arms: +2 on initiative%');

SELECT 'the Samson keeps its older citation' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles
 WHERE slug = 'ng-x9-samson-power-armor' AND source_book = 'Rifts Ultimate Edition p.271-272';

SELECT 'the Sky King vehicle is in with 7 locations and 2 weapons' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles
 WHERE slug = 'ng-a70-sky-king' AND mdc_main_body = 155
   AND (SELECT count(*) FROM vehicle_locations WHERE vehicle_slug = 'ng-a70-sky-king') = 7
   AND (SELECT count(*) FROM vehicle_weapons WHERE vehicle_slug = 'ng-a70-sky-king') = 2;

SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
 WHERE v.slug IN ('ng-a70-sky-king', 'bm-japeii-defender-exoskeleton', 'ng-jk1-juicer-killer-power-armor')
   AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

INSERT INTO data_script_runs (filename) VALUES ('~332-northern-gun-2-vehicles-held-compare-a.sql');
