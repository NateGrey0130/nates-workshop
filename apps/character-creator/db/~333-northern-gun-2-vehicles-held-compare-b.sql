-- Ten hovercycles, motorcycles and trucks the catalog already held follow
-- Rifts World Book 34: Northern Gun Two, their newest printing.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~333-northern-gun-2-vehicles-held-compare-b.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~333-northern-gun-2-vehicles-held-compare-b.sql
--
-- Northern Gun Two reprints ten machines production already held under older
-- citations: four NG hovercycles from Rifts World Book 13: Lone Star, the
-- Speedster, Highwayman, Wastelander, Big Boss and Mountaineer from Rifts
-- Ultimate Edition (the Highwayman held twice, as a vehicles row and a gear
-- row of the same slug), and the Rolling Thunder from Rifts World Book 10:
-- Juicer Uprising. Each was read off a render of Northern Gun Two (PDF offset
-- +1, printed 166-172, 202-205, 209-210, 213-214 and 217-219), every M.D.C. by
-- Location block included, and compared with the held rows read whole from
-- production on 2026-11-17, locations and weapons included. By Nate's rulings
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
-- no child row is added for one (the Speedster's headlight and windshield,
-- the motorcycles' headlights, storage compartments and windshields, the
-- ATVs' windows, doors and lights, the Rolling Thunder's new rear mini-missile
-- launcher, which its description now names). Where this book counts a
-- location differently, the held label stays and its note gives this book's
-- count. A metric conversion of an unchanged imperial figure counts only on
-- a row that changes anyway. The cost column keeps the low end of the new
-- list prices; a used price is in cost_note.
--
-- Edited (11 held rows, every one this book reprints):
--   ng-230-prowler-hovercycle (p.166-167): price; nose turret 180 degrees,
--     not 300; 5% speed per extra weapon, not 10%; altitude 213 m.
--   ng-220-rocket-hovercycle (p.169): price; ion blasters 600 feet, single
--     shot, 12 shots an E-Clip, 24,000 credits; weapon mounts; length 3.7 m.
--   speedster-hovercycle (p.169-170): main body 75, not 85; hover jets 35
--     (rear) and 40 (front), not 30; price; altitude where none was held.
--   ng-400-stinger-hovercycle (p.170): price; never used by the CS; called
--     shot -5; per-weapon penalties; length 3.7 m.
--   ng-480-turbo-hovercycle (p.171-172): price; +2 to dodge above 100 mph;
--     nose laser 40 dual blasts; housings 40 each; length 3.4 m.
--   the-highway-man-motorcycle, vehicles (p.202-203): no weapon standard;
--     tires 5 each where none was printed; electric 39,500, not 29,000.
--   the-highway-man-motorcycle, gear (p.202-203): the same figures.
--   the-wastelander-motorcycle (p.204-205): main body 66, not 60; tires 5
--     each, not 2; electric 28,500, not 21,000.
--   big-boss-atv (p.209-210): tires 18 each, not 5; length 4.9 m.
--   mountaineer-atv (p.213-214): price 138,000 new, not 76,000 Black Market;
--     three tires, not four; height 5.5 m.
--   rolling-thunder-apv (p.217-219): price 635,000 new, not 275,000; rail gun
--     2,000 round belt, not 300; mines optional, 6 not 12; called shot -4.
--
-- Left as they are, citation included: none. Every held row differs.
--
-- Not in this script: five more gear rows twin these vehicles by slug
-- (the-wastelander-motorcycle, speedster-hovercycle, big-boss-atv,
-- mountaineer-atv, rolling-thunder-apv), still at their older figures. Only
-- the Highwayman's twin was ruled into this row.
--
-- Guarded on each row still citing its older book, and each child row on the
-- value it replaces, so a re-run is a no-op. No row is inserted. THIS SCRIPT
-- CHANGES PRODUCTION. The tilde number is claimed at merge.

-- The NG-230 Prowler, printed 166-167.

UPDATE vehicles
   SET speed_air = 'Maximum 190 mph (304 km). Maximum altitude 700 feet (213 m); handles drops of up to 900 feet (274 m). A hover vehicle; the book prints one speed.',
       cost = 142000,
       cost_note = '142,000 credits with a gasoline engine, 198,000 electric, 780,000 Solid Oxide, or 995,000 nuclear with a ten year life. One nose gun of the customer''s choice on a simple turret is standard; weapon extras are full price even during sales. The low end is stored.',
       description = replace(replace(replace(description,
           'The nose laser turret rotates 300 degrees with a 40 degree arc of fire.',
           'The nose laser turret rotates 180 degrees side to side with a 40 degree up and down arc of fire.'),
           'A multi-shot missile pod, or more than three weapon systems, reduces speed by 10% and prowl by 20% and cancels the piloting bonus; a machinegun is not suitable.',
           'A multi-shot missile pod, or more than three weapon systems, reduces speed by 5% each and prowl by 20% and cancels the piloting bonus; one more weapon can go on each side, each cutting speed by 5%.'),
           'Deluxe armored model: add 30% to all M.D.C. and 30% to the cost.',
           'Deluxe armored model (104 M.D.C. main body): add 30% to the main body''s M.D.C. and 30% to the cost, and reduce speed by 10%.')
         || ' Lone Star, which this row followed before Northern Gun Two, priced it at 182,000 credits gas, 195,000 electric or 875,000 nuclear with the heavy laser standard, swung its nose turret through 300 degrees, took 10% off its speed for a missile pod or a fourth weapon, and put its ceiling at 210 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.166-167'
 WHERE slug = 'ng-230-prowler-hovercycle'
   AND source_book = 'Rifts World Book 13: Lone Star p.58-59';

UPDATE vehicle_weapons
   SET note = 'The nose gun on a simple turret is standard and the customer''s choice; this heavy laser is the one Lone Star made standard.'
 WHERE vehicle_slug = 'ng-230-prowler-hovercycle' AND ordinal = 1 AND note = 'Standard.';

-- The NG-220 Rocket, printed 169.

UPDATE vehicles
   SET dimensions = '12 feet (3.7 m) long',
       cost = 100000,
       cost_note = '100,000 credits with a gasoline engine, 127,000 electric, 670,000 Solid Oxide, or 995,000 nuclear with a ten year life; about 40% of what it used to cost. Weapon extras are full price even during sales. The low end is stored.',
       description = replace(replace(replace(description,
           'a further -10% at 300 mph (482 km) or faster.',
           'a further -10% at 300 mph (480 km) or faster, and -10% for every 250 feet (76 m) above the ground.'),
           'The body fits three lasers (or two machineguns with ammo drums) and four dual mini-missile launchers or two multi-shot pods; six dual launchers, or four dual and two pods, in place of two lasers.',
           'One more weapon of any kind can go in the nose, on each side at the back and on top at the back, each cutting speed by 5%.'),
           'Deluxe armored model: add 30% to all M.D.C. and 30% to the cost.',
           'Deluxe armored model (109 M.D.C. main body): add 30% to the main body''s M.D.C. and 30% to the cost, and reduce speed by 10%.')
         || ' Lone Star, which this row followed before Northern Gun Two, priced it at 120,000 credits gas, 135,000 electric or 675,000 nuclear, gave its ion blasters a 500 foot reach, 60 shots each and a 6D6 dual blast, fitted three lasers and four dual launchers or two pods, and gave its length as 3.6 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.169'
 WHERE slug = 'ng-220-rocket-hovercycle'
   AND source_book = 'Rifts World Book 13: Lone Star p.57-58';

UPDATE vehicle_weapons
   SET damage = '3D6 M.D.',
       range = '600 feet (183 m)',
       rate_of_fire = 'Single shot only; each shot counts as one melee attack',
       payload = '12 shots per E-Clip',
       note = 'Standard: NG-HL12 short-range ion blasters, one on each side, disguised as small air intake ports and street legal in most towns and cities. 24,000 credits.'
 WHERE vehicle_slug = 'ng-220-rocket-hovercycle' AND ordinal = 1 AND range = '500 feet (152 m)';

-- The NG-300 Speedster, printed 169-170.

UPDATE vehicles
   SET speed_air = 'Maximum 220 mph (352 km). Maximum altitude 120 feet (36.6 m); handles drops of up to 600 feet (183 m). A hover vehicle; the book prints one speed.',
       mdc_main_body = 75,
       cost = 80000,
       cost_note = '80,000 credits with a gasoline engine, 98,000 electric, 600,000 Solid Oxide, or 950,000 nuclear with a ten year life. Weapons cost extra and are full price even during sales; Northern Gun runs 10-20% discounts two to four times a year. Deluxe armored model: 97 M.D.C. main body at 30% more cost, speed unchanged. The low end is stored.',
       description = description
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, gave it 85 M.D.C. on the main body and three hover jets of 30 each, priced it at 98,000 credits gas, 110,000 electric or 450,000 nuclear, and offered the laser, machine-gun and mini-missile launchers below; this book lets any hovercycle weapon go on each side at the front and on the back, each cutting speed by 5%.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.169-170'
 WHERE slug = 'speedster-hovercycle'
   AND source_book = 'Rifts Ultimate Edition p.266';

UPDATE vehicle_locations
   SET mdc = 75
 WHERE vehicle_slug = 'speedster-hovercycle' AND location = 'Main Body' AND mdc = 85;

UPDATE vehicle_locations
   SET mdc = 35,
       mdc_note = 'each for the two rear jets; the front jet is 40. Northern Gun Two prints them as Rear Hover Jets (2) and Front Hover Jet (1), small targets needing a called shot at -3 to strike.'
 WHERE vehicle_slug = 'speedster-hovercycle' AND location = 'Hover Jets (3)' AND mdc = 30;

-- The NG-400 Stinger, printed 170.

UPDATE vehicles
   SET dimensions = '12 feet (3.7 m) long',
       cost = 145000,
       cost_note = '145,000 credits with a gasoline engine, 190,000 electric, 650,000 Solid Oxide, or 965,000 nuclear with a ten year life. No weapon is standard; extras are full price even during sales. The low end is stored.',
       description = replace(replace(replace(replace(replace(description,
           'one of the two the CS military uses most (hundreds of thousands in service)',
           'never purchased or used by the CS'),
           'A multi-shot missile pod costs -10% piloting and any weapon system beyond three another -10% (-20% at most).',
           'Every weapon mounted costs -5% piloting and 5% of its speed, a multi-shot missile pod -10%, and any weapon system beyond three another -10%.'),
           'The body fits three lasers (or two machineguns with ammo drums) and four dual mini-missile launchers or two multi-shot pods; six dual launchers, or four dual and two pods, in place of two lasers.',
           'One more weapon of any kind can go in the nose, on the back and on each side.'),
           'Deluxe armored model: add 30% to all M.D.C. and 30% to the cost.',
           'Deluxe armored model (117 M.D.C. main body): add 30% to the main body''s M.D.C. and 30% to the cost.'),
           'Small targets need a called shot; the page prints the penalty as "5 to strike" with no sign, where the other bikes print -3 or -4.',
           'Locations marked as small targets need a called shot at -5 to strike; the hunched driver is as hard to hit.')
         || ' Lone Star, which this row followed before Northern Gun Two, priced it at 180,000 credits gas, 200,000 electric or 795,000 nuclear, had hundreds of thousands in CS service, fitted three lasers and four dual launchers or two pods, printed its called-shot penalty without a sign, and gave its length as 3.6 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.170'
 WHERE slug = 'ng-400-stinger-hovercycle'
   AND source_book = 'Rifts World Book 13: Lone Star p.59-60';

-- The NG-480 Turbo, printed 171-172.

UPDATE vehicles
   SET dimensions = '11 feet (3.4 m) long',
       cost = 199000,
       cost_note = '199,000 credits with a gasoline combustion engine, 230,000 electric, or 850,000 nuclear with a ten year life. The nose ball-laser is standard; weapon extras are full price even during sales. The low end is stored.',
       description = replace(replace(replace(description,
           '+1 to dodge and +5% to piloting for basic driving',
           '+1 to dodge under 100 mph (160 km) and +2 faster, +5% to piloting for basic driving'),
           'Two additional weapon systems can be added',
           'One additional weapon can be added to each side, each cutting speed by 5%'),
           'Deluxe armored model: add 30% to all M.D.C. and 30% to the cost.',
           'Deluxe armored model (printed as 110 M.D.C. main body): add 30% to the main body''s M.D.C. and 30% to the cost, and reduce speed by 10%.')
         || ' Lone Star, which this row followed before Northern Gun Two, priced it at 225,000 credits gas or 240,000 electric, gave +1 to dodge at any speed, fed its nose laser 60 double shots or 120 single, and gave its length as 3.3 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.171-172'
 WHERE slug = 'ng-480-turbo-hovercycle'
   AND source_book = 'Rifts World Book 13: Lone Star p.60-61';

UPDATE vehicle_locations
   SET mdc_note = 'each; small target: called shot only'
 WHERE vehicle_slug = 'ng-480-turbo-hovercycle' AND location = 'Rear Hover Ball Jet Housing (2)'
   AND mdc_note = 'small target: called shot only';

UPDATE vehicle_weapons
   SET rate_of_fire = 'Each single or double blast counts as one melee attack',
       payload = '40 dual blasts (each is powered by two E-Clips)',
       note = 'Standard: a double-barrel HL20 long-range medium laser in a ball turret, fire-linked, with two small spotlights. Lone Star listed it at 80,000 credits.'
 WHERE vehicle_slug = 'ng-480-turbo-hovercycle' AND ordinal = 1 AND payload = '60 double shots or 120 single';

-- The Highwayman, printed 202-203: the vehicles row, then its gear twin.

UPDATE vehicles
   SET speed_ground = 'Maximum 180 mph (288 km); half that or less on grassy plains, dirt roads, stony deserts and broken, rough terrain.',
       cost_note = '24,000 credits with a gasoline engine, 39,500 for the improved electric battery, 340,000 Solid Oxide, or 890,000 nuclear (rare). No weapon is standard; one light hovercycle weapon can be added at extra cost.',
       description = replace(replace(description,
           'coming standard with a laser or heavy machine-gun. Combustion or electric engine; maximum range 400 miles (640 km).',
           'on the market since 80 P.A. No weapon is standard; one light weapon from the hovercycle options can be added, and two buyers in three add none. Gasoline, electric, Solid Oxide or nuclear; maximum range 400 miles (640 km) on gasoline, 1,800 miles (2,880 km) per charge, unlimited on Solid Oxide or nuclear.'),
           'Its weapons are printed as "Same as Speedster hovercycle" rather than restated.',
           'Rifts Ultimate Edition printed its weapons only as "Same as Speedster hovercycle".')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, sold it with a laser or machine-gun standard, priced the electric model at 29,000 credits, and printed no figure for its tires.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.202-203'
 WHERE slug = 'the-highway-man-motorcycle'
   AND source_book = 'Rifts Ultimate Edition p.266';

UPDATE vehicle_locations
   SET mdc = 5,
       mdc_note = 'each; small target: called shot at -4 to strike, -8 at the tires of a speeding vehicle. Destroying one cuts speed by 90%; both immobilise the bike.'
 WHERE vehicle_slug = 'the-highway-man-motorcycle' AND location = 'Tires (2)' AND mdc IS NULL;

UPDATE vehicle_weapons
   SET note = 'None is standard; one light hovercycle weapon can be added at extra cost. Rifts Ultimate Edition printed only "Same as Speedster hovercycle" and made one or the other standard; the figures are carried across from that entry, with 12,000 credits for the laser or 6,500 for the machine-gun.'
 WHERE vehicle_slug = 'the-highway-man-motorcycle' AND ordinal = 1 AND note LIKE 'The book prints only%';

UPDATE gear
   SET cost_note = '24,000 credits with a gasoline engine, 39,500 for the improved electric battery, 340,000 Solid Oxide, or 890,000 nuclear (rare). No weapon is standard; one light hovercycle weapon can be added at extra cost.',
       description = replace(replace(replace(replace(description,
           'Comes standard with a laser or heavy machine gun.',
           'No weapon is standard; one light hovercycle weapon can be added at extra cost.'),
           'Engine: Combustion or electric engine. Maximum Range: 400 miles (480 km).',
           'Engine: Gasoline, electric battery, Solid Oxide or nuclear. Maximum Range: 400 miles (640 km) on gasoline, 1,800 miles (2,880 km) per charge, unlimited on Solid Oxide or nuclear.'),
           'Tires (2) - 1 each',
           'Tires (2) - 5 each'),
           'Black Market Cost: 24,000 credits gasoline engine or 29,000 credits for electric. Add 6500 for machinegun and 12,000 for laser.',
           'Cost: 24,000 credits gasoline engine or 39,500 credits for the improved electric battery system; 340,000 credits for Solid Oxide and 890,000 credits for nuclear (rare).')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, sold it with a laser or machine gun standard at 24,000 credits gas or 29,000 electric, adding 6,500 for the machinegun or 12,000 for the laser, and gave its tires 1 M.D.C. each.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.202-203'
 WHERE slug = 'the-highway-man-motorcycle'
   AND source_book = 'Rifts Ultimate Edition p.266';

-- The Wastelander, printed 204-205.

UPDATE vehicles
   SET mdc_main_body = 66,
       cost_note = '18,000 credits with a gasoline engine or 28,500 for the improved electric battery; special orders, taking 1D4+1 weeks, buy Solid Oxide at 385,000 or nuclear at 880,000. No weapon is standard; one light hovercycle weapon can be added at extra cost, and 95% of buyers add none.',
       description = replace(replace(description,
           'Combustion or electric engine; maximum range 400 miles (640 km).',
           'Gasoline, electric, Solid Oxide or nuclear; maximum range 400 miles (640 km) on gasoline, 3,000 miles (4,800 km) per charge on the upgraded multi-battery system, unlimited on Solid Oxide or nuclear.'),
           'this edition prints 60',
           'Rifts Ultimate Edition prints 60')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, gave it 60 M.D.C. on the main body and 2 on each tire, and priced the electric model at 21,000 credits.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.204-205'
 WHERE slug = 'the-wastelander-motorcycle'
   AND source_book = 'Rifts Ultimate Edition p.266';

UPDATE vehicle_locations
   SET mdc = 66
 WHERE vehicle_slug = 'the-wastelander-motorcycle' AND location = 'Main Body' AND mdc = 60;

UPDATE vehicle_locations
   SET mdc = 5,
       mdc_note = 'each; small target: called shot at -4 to strike, -8 at the tires of a speeding vehicle.'
 WHERE vehicle_slug = 'the-wastelander-motorcycle' AND location = 'Tires (2)' AND mdc = 2;

UPDATE vehicle_weapons
   SET note = 'None standard, but one light hovercycle weapon can be added at extra cost. Rifts Ultimate Edition priced a machine-gun at 4,000 credits and a laser at 11,000.'
 WHERE vehicle_slug = 'the-wastelander-motorcycle' AND ordinal = 1 AND note LIKE 'The book prints%';

-- The Big Boss, printed 209-210.

UPDATE vehicles
   SET dimensions = '16 feet (4.9 m) long',
       cost_note = '24,000 credits with a gasoline engine, 28,000 for the old electric battery, 62,000 for the advanced multi-battery system, 435,000 Solid Oxide, or 860,000 nuclear with a ten year life. The roof laser rifle and its E-Clips are sold separately.',
       description = replace(replace(description,
           'It often comes with a sunroof and a standard laser rifle',
           'It comes standard with a sunroof and a swivel-mounted laser rifle'),
           'Combustion or electric engine; maximum range 300 miles (480 km).',
           'Every power system is available; maximum range 300 miles (480 km) on gasoline, 1,000 miles (1,600 km) per charge on the advanced battery (half that on the old one), unlimited on Solid Oxide or nuclear. It pulls 4 tons, and as many as three hovercycle weapons can be added at the front.')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, gave it four tires of 5 M.D.C. each and a length of 4.8 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.209-210'
 WHERE slug = 'big-boss-atv'
   AND source_book = 'Rifts Ultimate Edition p.266';

UPDATE vehicle_locations
   SET mdc = 18,
       mdc_note = 'each; Northern Gun Two prints Armored Tires (3) for this buggy. A called shot; destroying one cuts speed by 35% and piloting by 25%, two immobilise it.'
 WHERE vehicle_slug = 'big-boss-atv' AND location = 'Tires (4)' AND mdc = 5;

-- The Mountaineer, printed 213-214.

UPDATE vehicles
   SET passengers = 'Four, with plenty of room; six crowded. The pilot''s compartment seats five in all.',
       dimensions = '25 feet (7.6 m) long, 18 feet (5.5 m) tall, 21 feet (6.4 m) wide overall; the large cargo bay is 10x8x8 feet (3x2.4x2.4 m) and a small one 10x3x8 feet (3x0.9x2.4 m)',
       cost = 138000,
       cost_note = '138,000 credits with a liquid fuel engine, 185,000 electric, 380,000 Solid Oxide, or 850,000 nuclear with a 15-20 year life. A used gas or electric one sells for 76,000 and a Black Market nuclear one for 500,000, as a stripped-down rig missing 1D4x10% of its main body M.D.C. Radar, radio, sensors and weapons cost extra; as much as 90 more M.D.C. can be added at 10,000 credits per 30, reducing speed by 10%.',
       description = replace(replace(description,
           'Combustion, electric or nuclear engine; maximum range 600 miles (960 km) on an extra large tank or batteries. No weapons are standard.',
           'Every power system is available; maximum range 600 miles (960 km) on gasoline, 2,000 miles (3,200 km) per charge, unlimited on Solid Oxide or nuclear. It carries 40 tons and pulls 20 more. No weapons are standard; as many as six hovercycle weapons or two heavy vehicle weapons can be added.'),
           'Its entry breaks across printed 266 and 267',
           'In Rifts Ultimate Edition its entry breaks across printed 266 and 267')
         || ' Rifts Ultimate Edition, which this row followed before Northern Gun Two, gave it four super tires and a height of 5.4 m, and priced it only on the Black Market, at 76,000 credits gas, 70,000 electric or 500,000 nuclear with a twenty year life.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.213-214'
 WHERE slug = 'mountaineer-atv'
   AND source_book = 'Rifts Ultimate Edition p.266-267';

UPDATE vehicle_locations
   SET mdc_note = 'each; Northern Gun Two prints Armored Super-Tires (3). A called shot at -4 to strike; destroying one cuts speed by 40% and piloting by 20%, two immobilise it.'
 WHERE vehicle_slug = 'mountaineer-atv' AND location = 'Super Tires (4)' AND mdc_note = 'Each.';

-- The Rolling Thunder, printed 217-219.

UPDATE vehicles
   SET speed_ground = 'Top speed 166 mph (266 km) with nuclear or Solid Oxide, or 142 mph (227 km) on the battery or fuel systems. Acceleration 0-60 in 5.7 seconds, 6.5 with the battery system; braking 60-0 in 100 feet (30.5 m). Maximum range 525 miles (840 km) on fuel or battery, unlimited on Solid Oxide or nuclear.',
       dimensions = 'Height 5 feet 6 inches (1.7 m), width 6 feet 8 inches (2.0 m), length 20 feet (6.1 m)',
       weight_tons = '2,875 lbs (1,294 kg)',
       cost = 635000,
       cost_note = 'Flex-fuel 635,000 credits (275,000 used), full electric 758,000, Solid Oxide 895,000, nuclear 1.1 million; manufactured by Wellington Industries and Northern Gun. Wiring the particle beams into a Solid Oxide or nuclear supply costs another 250,000.',
       description = replace(replace(description,
           'A favourite of Juicer mercenaries.',
           'Once a favourite of Juicer mercenaries, it now sells poorly and may be discontinued.'),
           'and a voice-activated mine layer that can seal a road behind it against reinforcements and invaders until the mines are cleared. Flex-fuel internal combustion with electric back-up.',
           'and a rear mini-missile launcher (one mile, six mini-missiles, fired singly or in volleys of 2, 4 or 6); the voice-activated mine layer of the original model is now an optional alternative for crews working away from towns, many of which outlawed the vehicle. Flex-fuel internal combustion with electric back-up, full electric, Solid Oxide or nuclear. Augmented humans get +10% to piloting, jumps and stunts.')
         || ' Juicer Uprising, which this row followed before Northern Gun Two, sold it for 275,000 credits new, fed its rail gun from a 300 round belt, made the mine layer standard with twelve mines and gave it no missile launcher, put its wheels and particle beams at -2 to a called shot, and gave its height as 1.65 m.',
       source_book = 'Rifts World Book 34: Northern Gun Two p.217-219'
 WHERE slug = 'rolling-thunder-apv'
   AND source_book = 'Rifts World Book 10: Juicer Uprising p.84-85';

UPDATE vehicle_locations
   SET mdc_note = 'each, mud guards included; a called shot at -4 to strike (-6 at the tires of a moving vehicle). Destroying one cuts speed by 30% and piloting by 25% (half for Juicers and Crazies); two immobilise it.'
 WHERE vehicle_slug = 'rolling-thunder-apv' AND location = 'Wheels (4)'
   AND mdc_note = 'each; a difficult target, -2 on a called shot';

UPDATE vehicle_locations
   SET mdc_note = 'each, concealed in the nose; a called shot at -4 to strike.'
 WHERE vehicle_slug = 'rolling-thunder-apv' AND location = 'Particle Beam Guns (2)'
   AND mdc_note = 'each; a difficult target, -2 on a called shot';

UPDATE vehicle_weapons
   SET damage = 'A 40-round burst inflicts 1D4x10 M.D.; one round does 1D4 M.D.',
       range = '4,000 feet (1,219 m)',
       rate_of_fire = 'Each single shot or burst counts as one melee attack',
       payload = '2,000 round belt, enough for 50 bursts',
       bonus = '+1 to strike from its laser tracking system',
       note = 'Mounted on the right side; cannot be operated by the driver.'
 WHERE vehicle_slug = 'rolling-thunder-apv' AND ordinal = 1 AND payload = 'A 300 round belt as a machinegun';

UPDATE vehicle_weapons
   SET range = '1,200 feet (366 m)',
       rate_of_fire = 'Each single or double blast counts as one melee attack',
       payload = '25 dual blasts from both guns, or 50 single shots divided between the two',
       note = 'Concealed in the nose, connected to the steering linkage and able to fire to either side. Six E-Clips, three per gun, slow to load; 250,000 credits to wire them into a Solid Oxide or nuclear supply.'
 WHERE vehicle_slug = 'rolling-thunder-apv' AND ordinal = 2 AND range = '1200 feet (365 m)';

UPDATE vehicle_weapons
   SET damage = 'Varies; the standard Type One load is light high explosive, 5D6 M.D. to a 20 foot (6.1 m) area, or plasma, 1D6x10 M.D. to a 30 foot (9.1 m) area',
       range = 'Close proximity, timer or touch; dropped mines can be set to trigger at 30-70 feet (9.1-21.3 m)',
       rate_of_fire = 'One at a time or in volleys of 2, 4 or 6',
       payload = '6 high explosive or plasma mines, or a mix of the two',
       note = 'Optional, in place of the rear mini-missile launcher. Voice-activated: it tracks pursuers and detonates by radio, with a safety that will not set one off within range of the vehicle.'
 WHERE vehicle_slug = 'rolling-thunder-apv' AND ordinal = 3 AND payload = '12 total; four of each type';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the ten edited vehicles rows cite Northern Gun Two' AS assertion, count(*) AS got, 10 AS want
  FROM vehicles
 WHERE slug IN ('ng-230-prowler-hovercycle', 'ng-220-rocket-hovercycle', 'speedster-hovercycle',
                'ng-400-stinger-hovercycle', 'ng-480-turbo-hovercycle', 'the-highway-man-motorcycle',
                'the-wastelander-motorcycle', 'big-boss-atv', 'mountaineer-atv', 'rolling-thunder-apv')
   AND source_book LIKE 'Rifts World Book 34: Northern Gun Two p.%';

SELECT 'the Highwayman gear twin cites Northern Gun Two' AS assertion, count(*) AS got, 1 AS want
  FROM gear
 WHERE slug = 'the-highway-man-motorcycle'
   AND source_book = 'Rifts World Book 34: Northern Gun Two p.202-203'
   AND instr(description, 'Tires (2) - 5 each') > 0
   AND instr(description, 'for the improved electric battery system;') > 0;

SELECT 'the hovercycles carry this book''s figures' AS assertion, count(*) AS got, 5 AS want
  FROM vehicles
 WHERE (slug = 'ng-230-prowler-hovercycle' AND cost = 142000
        AND instr(description, 'rotates 180 degrees side to side') > 0
        AND instr(description, 'reduces speed by 5% each') > 0)
    OR (slug = 'ng-220-rocket-hovercycle' AND cost = 100000
        AND instr(description, 'every 250 feet (76 m) above the ground') > 0)
    OR (slug = 'speedster-hovercycle' AND cost = 80000 AND mdc_main_body = 75)
    OR (slug = 'ng-400-stinger-hovercycle' AND cost = 145000
        AND instr(description, 'never purchased or used by the CS') > 0
        AND instr(description, 'called shot at -5 to strike') > 0)
    OR (slug = 'ng-480-turbo-hovercycle' AND cost = 199000
        AND instr(description, 'and +2 faster') > 0);

SELECT 'the motorcycles and trucks carry this book''s figures' AS assertion, count(*) AS got, 5 AS want
  FROM vehicles
 WHERE (slug = 'the-highway-man-motorcycle' AND instr(description, 'on the market since 80 P.A.') > 0)
    OR (slug = 'the-wastelander-motorcycle' AND mdc_main_body = 66
        AND instr(description, '3,000 miles (4,800 km) per charge') > 0)
    OR (slug = 'big-boss-atv' AND dimensions = '16 feet (4.9 m) long'
        AND instr(description, '1,000 miles (1,600 km) per charge') > 0)
    OR (slug = 'mountaineer-atv' AND cost = 138000
        AND instr(description, 'It carries 40 tons and pulls 20 more.') > 0)
    OR (slug = 'rolling-thunder-apv' AND cost = 635000
        AND instr(description, 'rear mini-missile launcher (one mile') > 0);

SELECT 'the changed locations carry this book''s figures' AS assertion, count(*) AS got, 10 AS want
  FROM vehicle_locations
 WHERE (vehicle_slug = 'speedster-hovercycle' AND location = 'Main Body' AND mdc = 75)
    OR (vehicle_slug = 'speedster-hovercycle' AND location = 'Hover Jets (3)' AND mdc = 35)
    OR (vehicle_slug = 'ng-480-turbo-hovercycle' AND location = 'Rear Hover Ball Jet Housing (2)'
        AND mdc_note LIKE 'each;%')
    OR (vehicle_slug = 'the-highway-man-motorcycle' AND location = 'Tires (2)' AND mdc = 5)
    OR (vehicle_slug = 'the-wastelander-motorcycle' AND location = 'Main Body' AND mdc = 66)
    OR (vehicle_slug = 'the-wastelander-motorcycle' AND location = 'Tires (2)' AND mdc = 5)
    OR (vehicle_slug = 'big-boss-atv' AND location = 'Tires (4)' AND mdc = 18)
    OR (vehicle_slug = 'mountaineer-atv' AND location = 'Super Tires (4)'
        AND mdc_note LIKE '%Armored Super-Tires (3)%')
    OR (vehicle_slug = 'rolling-thunder-apv' AND location = 'Wheels (4)' AND mdc_note LIKE '%-4 to strike%')
    OR (vehicle_slug = 'rolling-thunder-apv' AND location = 'Particle Beam Guns (2)' AND mdc_note LIKE '%-4 to strike%');

SELECT 'the changed weapons carry this book''s figures' AS assertion, count(*) AS got, 8 AS want
  FROM vehicle_weapons
 WHERE (vehicle_slug = 'ng-230-prowler-hovercycle' AND ordinal = 1 AND note LIKE '%customer''s choice%')
    OR (vehicle_slug = 'ng-220-rocket-hovercycle' AND ordinal = 1 AND range = '600 feet (183 m)'
        AND payload = '12 shots per E-Clip')
    OR (vehicle_slug = 'ng-480-turbo-hovercycle' AND ordinal = 1 AND payload LIKE '40 dual blasts%')
    OR (vehicle_slug = 'the-highway-man-motorcycle' AND ordinal = 1 AND note LIKE 'None is standard%')
    OR (vehicle_slug = 'the-wastelander-motorcycle' AND ordinal = 1 AND note LIKE 'None standard, but%')
    OR (vehicle_slug = 'rolling-thunder-apv' AND ordinal = 1 AND payload LIKE '2,000 round belt%')
    OR (vehicle_slug = 'rolling-thunder-apv' AND ordinal = 2 AND range = '1,200 feet (366 m)')
    OR (vehicle_slug = 'rolling-thunder-apv' AND ordinal = 3 AND payload LIKE '6 high explosive%');

SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
 WHERE v.slug IN ('ng-230-prowler-hovercycle', 'ng-220-rocket-hovercycle', 'speedster-hovercycle',
                  'ng-400-stinger-hovercycle', 'ng-480-turbo-hovercycle', 'the-highway-man-motorcycle',
                  'the-wastelander-motorcycle', 'big-boss-atv', 'mountaineer-atv', 'rolling-thunder-apv')
   AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

INSERT INTO data_script_runs (filename) VALUES ('~333-northern-gun-2-vehicles-held-compare-b.sql');
