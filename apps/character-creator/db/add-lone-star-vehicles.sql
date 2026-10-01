-- Rifts World Book 13: Lone Star - six hovercycles (printed 55-61) and the CS
-- Death Wing Air Assault Armor (printed 62-64), with their M.D.C.-by-location
-- tables and weapon lists. See apps/character-creator/docs/surveys/lone-star.md.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-lone-star-vehicles.sql
--
-- EVERY NUMBER WAS READ OFF A 170 DPI RENDER by book-extract-worker and checked
-- by book-reconcile: the text layer interleaves these stat blocks, and printed
-- 60 is a corrupt page.
--
-- NOT HERE: the NG-300 Speedster of printed 54-55 is the catalog's
-- speedster-hovercycle, held from Rifts Ultimate Edition.
--
-- PRICES: cost is the cheapest engine; the others are in cost_note. An optional
-- weapon's price is in that weapon's note.
--
-- STORED AS PRINTED, and said so in the rows: the Stinger's called-shot penalty
-- prints with no sign; the Death Wing's footnote gives half a wing 145 M.D.C.
-- where its location line gives each wing 210; the Prowler's single laser
-- turret prints "6 each".

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
  ('mi-3000-firefly-hovercycle', 'MI-3000 "Firefly" Hovercycle', 'rifts', 'vehicle', 'One rider.', 'One can sit behind the driver, but it is cramped even on short trips and imposes -5% on the piloting skill.', NULL, 'Maximum 190 mph (304 km). Maximum altitude 60 feet (18.3 m); handles drops of up to 400 feet (122 m). A hover vehicle; the book prints one speed.', NULL, '5 feet, 6 inches (1.65 m) long', '330 lbs (148.5 kg)', 72, 148000, '148,000 credits with a gasoline combustion engine or 164,000 electric; nuclear is not available. The weapons are standard and included. The low end is stored.', 'The Manistique Imperium''s answer to the Speedster: a small one-seater with a ball-action rear hoverjet and full VTOL. +10% to the piloting skill and +1 to dodge. Maximum range 800 miles (1280 km); combustion or electric engine. It can drive along the side of a wall for up to three minutes. The forward laser mini-turret rotates 180 degrees side to side with a 40 degree arc of fire, and the side launchers rotate 360 degrees. Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Locations marked as small targets need a called shot at -4 to strike; the hunched driver is as hard to hit. Never purchased or used by the CS.', 'Rifts World Book 13: Lone Star p.55-56'),
  ('mi-1010-desert-fox-hovercycle', 'MI-1010 Desert Fox Hovercycle', 'rifts', 'vehicle', 'One rider.', 'One can sit behind the driver, but it is cramped even on short trips and imposes -5% on the piloting skill.', NULL, 'Maximum 170 mph (272 km). Maximum altitude 80 feet (24.4 m); handles drops of up to 600 feet (183 m). A hover vehicle; the book prints one speed.', NULL, '6 feet (1.8 m) long', '400 lbs (180 kg)', 65, 90000, '90,000 credits with a gasoline combustion engine or 105,000 electric; nuclear is not available. Weapons are extra and full price even during sales. The low end is stored.', 'A small Manistique Imperium hovercycle built for desert and prairie, with engines that shrug off heat, sand and dust; popular in Lone Star, the Pecos Empire and the Western Wilderness. +10% to the piloting skill. Maximum range 700 miles (1120 km); combustion or electric engine. Light armor and modest speed are its drawbacks, and it is hard to fit more than one weapon (most carry none). Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Locations marked as small targets need a called shot at -4 to strike; the hunched driver is as hard to hit. Never purchased or used by the CS.', 'Rifts World Book 13: Lone Star p.56-57'),
  ('ng-220-rocket-hovercycle', 'NG-220 Rocket Combat Hovercycle', 'rifts', 'vehicle', 'One rider.', 'One can sit behind the driver, but not comfortably on long trips.', NULL, 'Maximum 340 mph (544 km). Maximum altitude 1000 feet (305 m), and it handles drops of the same. A rocket-propelled hover vehicle; the book prints one speed.', NULL, '12 feet (3.6 m) long', '850 lbs (382.5 kg)', 84, 120000, '120,000 credits with a gasoline engine, 135,000 electric, or 675,000 nuclear with a ten year life; about 40% of what it used to cost. Weapon extras are full price even during sales. The low end is stored.', 'An older Northern Gun rocket bike built for straight-line speed over flatland, a favorite of the Pecos bandits. It handles poorly: -15% to the piloting skill, -30% on sudden stops, sharp turns or stunts, and a further -10% at 300 mph (482 km) or faster. Maximum range 600 miles (960 km) on gas or electric, indefinite with a nuclear engine. Two short-range ion blasters are disguised as directional jet ports. The body fits three lasers (or two machineguns with ammo drums) and four dual mini-missile launchers or two multi-shot pods; six dual launchers, or four dual and two pods, in place of two lasers. Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Locations marked as small targets need a called shot at -3 to strike; the hunched driver is as hard to hit. Never purchased or used by the CS.', 'Rifts World Book 13: Lone Star p.57-58'),
  ('ng-230-prowler-hovercycle', 'NG-230 Prowler Combat Hovercycle', 'rifts', 'vehicle', 'One rider.', 'None; there is no space for a passenger.', NULL, 'Maximum 190 mph (304 km). Maximum altitude 700 feet (210 m); handles drops of up to 900 feet (274 m). A hover vehicle; the book prints one speed.', NULL, '7 feet, 3 inches (2.2 m) long', '700 lbs (315 kg)', 80, 182000, '182,000 credits with a gasoline engine, 195,000 electric, or 875,000 nuclear with a ten year life. The heavy laser is standard; weapon extras are full price even during sales. The low end is stored.', 'An old, reliable Northern Gun bike favored by adventurers and explorers. +5% to the piloting skill. It runs silent but for a faint hiss below 36 mph (57.6 km): the driver may apply his Prowl skill while driving at 35 mph (56 km) or less, and one without the skill uses the vehicle''s 20%. Maximum range 900 miles (1440 km). The nose laser turret rotates 300 degrees with a 40 degree arc of fire. A multi-shot missile pod, or more than three weapon systems, reduces speed by 10% and prowl by 20% and cancels the piloting bonus; a machinegun is not suitable. Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Locations marked as small targets need a called shot at -4 to strike; the hunched driver is as hard to hit. Only occasionally purchased and used by the CS military.', 'Rifts World Book 13: Lone Star p.58-59'),
  ('ng-400-stinger-hovercycle', 'NG-400 Stinger Combat Hovercycle', 'rifts', 'vehicle', 'One rider.', 'None; there is no space for a passenger.', NULL, 'Maximum 250 mph (400 km). Maximum altitude 200 feet (61 m); handles drops of up to 600 feet (183 m). A hover vehicle; the book prints one speed.', NULL, '12 feet (3.6 m) long', '850 lbs (382.5 kg)', 90, 180000, '180,000 credits with a gasoline engine, 200,000 electric, or 795,000 nuclear with a ten year life. No weapon is standard; extras are full price even during sales. The low end is stored.', 'A sleek, low-profile Northern Gun combat bike, one of the two the CS military uses most (hundreds of thousands in service). The low profile gives +1 to dodge; -5% on the piloting roll for sudden stops or elaborate stunts. Maximum range 800 miles (1280 km). A multi-shot missile pod costs -10% piloting and any weapon system beyond three another -10% (-20% at most). The body fits three lasers (or two machineguns with ammo drums) and four dual mini-missile launchers or two multi-shot pods; six dual launchers, or four dual and two pods, in place of two lasers. Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Small targets need a called shot; the page prints the penalty as "5 to strike" with no sign, where the other bikes print -3 or -4.', 'Rifts World Book 13: Lone Star p.59-60'),
  ('ng-480-turbo-hovercycle', 'NG-480 Turbo Hovercycle', 'rifts', 'vehicle', 'One rider.', 'One can sit behind the driver, but it is cramped even on short trips and imposes -5% on the piloting skill.', NULL, 'Maximum 220 mph (352 km). Maximum altitude 400 feet (122 m); handles drops of up to 400 feet (122 m). A hover vehicle; the book prints one speed.', NULL, '11 feet (3.3 m) long', '1000 lbs (450 kg)', 92, 225000, '225,000 credits with a gasoline combustion engine, 240,000 electric, or 850,000 nuclear with a ten year life. The nose ball-laser is standard; weapon extras are full price even during sales. The low end is stored.', 'Northern Gun''s newest combat bike, with the ball-action rear hoverjets first seen on the Firefly; the other bike the CS military uses most (a few hundred thousand in service). +1 to dodge and +5% to piloting for basic driving, -10% on jumps and special stunts; it is nose heavy. Maximum range 800 miles (1280 km). The nose turret turns 180 degrees side to side with a 45 degree arc up and down. Two additional weapon systems can be added; a second double-barrel laser is not possible and a machinegun is not appropriate. No prowl ability. Deluxe armored model: add 30% to all M.D.C. and 30% to the cost. Locations marked as small targets need a called shot at -4 to strike; the hunched driver is as hard to hit.', 'Rifts World Book 13: Lone Star p.60-61'),
  ('cs-death-wing-air-assault-armor', 'CS Death Wing Air Assault Armor (PA-101W / PA-102W)', 'rifts', 'power-armor', 'One', NULL, 'Not possible on the wing. The light power armor alone doubles the wearer''s running speed and leaps up to 10 feet (3 m) high or across.', 'Up to about Mach One, 600 mph (960 km); cruising usually 200-400 mph (321-640 km); VTOL capable. Maximum altitude 16,000 feet (4876.8 m); can fly as low as two feet (0.6 m) off the ground. The jets need cooling after 18 hours at cruising speed or nine hours at maximum.', NULL, 'Height 7 feet (2.1 m); wingspan 20 feet (6 m); length 5 feet, 5 inches (1.65 m)', '1.3 tons; the power armor alone is about 160 lbs (72 kg)', 290, 4300000, 'Market cost 4.3 million credits. Not available on the Black Market.', 'A one-man flying wing that mates with a light suit of ceramic power armor (180 M.D.C., P.S. 28). Built at Lone Star to observe mutants and later armed; PA-101W is the combat model and PA-102W the reconnaissance model. Nuclear powered, average energy life five years. In flight and attached to the wing: +2 on initiative, +1 to strike, +2 to dodge and one extra attack per melee round, on top of power armor training. The armor detaches at low speed or hover (one melee action) and the wing can be ordered by remote control from the ground. The wing as a whole is -2 to hit; a called shot on the pilot is -4. Main body gone: it crashes. Half the wing destroyed: it spins and crashes (the footnote prints 145 M.D.C. for half a wing where the location line prints 210 each). One secondary thruster lost: no effect; both: -10% speed and -1 to dodge. One main thruster: -25% speed; both: -50% speed, -4 to dodge, -3 on initiative. One directional thruster: -15% speed; both: -30% speed, -2 to dodge, -2 on initiative. If the pilot is killed or unconscious the wing returns to base on autopilot. Robot-arm sensors: telescopic, macro, infrared, passive nightvision and thermo-optics to 6000 feet (1830 m), with 24 hour video. Hand weapons carried in flight are likely to tear loose above 350 mph (560 km). The CS fields perhaps one Death Wing for every 50 SAMAS.', 'Rifts World Book 13: Lone Star p.62-64');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('mi-3000-firefly-hovercycle', 'Rear Hover Ball Jet Housing (1)', 40, 'small target: called shot only', 1),
  ('mi-3000-firefly-hovercycle', 'Forward Directional Jets (4)', 4, 'each; small target: called shot only', 2),
  ('mi-3000-firefly-hovercycle', 'Undercarriage Directional Jets (4)', 4, 'each; small target: called shot only', 3),
  ('mi-3000-firefly-hovercycle', 'Forward Headlights (2)', 3, 'each; small target: called shot only', 4),
  ('mi-3000-firefly-hovercycle', 'Forward Laser Turret (1)', 28, 'small target: called shot only', 5),
  ('mi-3000-firefly-hovercycle', 'Side Mini-Missile Launchers (2)', 20, 'each, one per side; small target: called shot only', 6),
  ('mi-3000-firefly-hovercycle', 'Reinforced Windshield (1)', 15, NULL, 7),
  ('mi-3000-firefly-hovercycle', 'Main Body', 72, NULL, 8),
  ('mi-1010-desert-fox-hovercycle', 'Rear Hover Jets (2; upper)', 30, 'each; small target: called shot only', 1),
  ('mi-1010-desert-fox-hovercycle', 'Main Jet (1; lower body)', 55, 'small target: called shot only', 2),
  ('mi-1010-desert-fox-hovercycle', 'Large Lower Directional Jets (2)', 15, 'each; small target: called shot only', 3),
  ('mi-1010-desert-fox-hovercycle', 'Forward Headlights (2)', 2, 'each; small target: called shot only', 4),
  ('mi-1010-desert-fox-hovercycle', 'Small Windshield (1)', 5, 'small target: called shot only', 5),
  ('mi-1010-desert-fox-hovercycle', 'Main Body', 65, NULL, 6),
  ('ng-220-rocket-hovercycle', 'Rear Hover Rocket Jets (6)', 25, 'each; small target: called shot only', 1),
  ('ng-220-rocket-hovercycle', 'Front Directional Jets (2)', 5, 'each; small target: called shot only', 2),
  ('ng-220-rocket-hovercycle', 'Undercarriage Directional Jets (6)', 5, 'each; small target: called shot only', 3),
  ('ng-220-rocket-hovercycle', 'Forward Headlights (2)', 5, 'each; small target: called shot only', 4),
  ('ng-220-rocket-hovercycle', 'Forward Ion Blasters (2; disguised as mini-jets)', 6, 'each; small target: called shot only', 5),
  ('ng-220-rocket-hovercycle', 'Windshield (1)', 18, NULL, 6),
  ('ng-220-rocket-hovercycle', 'Main Body', 84, NULL, 7),
  ('ng-220-rocket-hovercycle', 'Optional Weapons', NULL, 'typically 2D6+14 M.D.C. each; small target: called shot only', 8),
  ('ng-230-prowler-hovercycle', 'Large Hover Jet (1; rear)', 38, 'small target: called shot only', 1),
  ('ng-230-prowler-hovercycle', 'Small Hover Jet (1; rear)', 15, 'small target: called shot only', 2),
  ('ng-230-prowler-hovercycle', 'Side Hover Jets (2)', 30, 'each', 3),
  ('ng-230-prowler-hovercycle', 'Undercarriage Directional Jets (4)', 5, 'each; small target: called shot only', 4),
  ('ng-230-prowler-hovercycle', 'Side Stabilizing Wings (2)', 18, 'each; small target: called shot only', 5),
  ('ng-230-prowler-hovercycle', 'Tail Fin (1; large)', 28, 'small target: called shot only', 6),
  ('ng-230-prowler-hovercycle', 'Forward Headlights (1)', 4, 'small target: called shot only', 7),
  ('ng-230-prowler-hovercycle', 'Forward Laser Turret (1)', 6, 'printed as 6 each; small target: called shot only', 8),
  ('ng-230-prowler-hovercycle', 'Windshield (1)', 18, NULL, 9),
  ('ng-230-prowler-hovercycle', 'Main Body', 80, NULL, 10),
  ('ng-230-prowler-hovercycle', 'Optional Weapons', NULL, 'typically 2D6+14 M.D.C. each; small target: called shot only', 11),
  ('ng-400-stinger-hovercycle', 'Rear Hover Jets (2)', 25, 'each; small target: called shot only', 1),
  ('ng-400-stinger-hovercycle', 'Concealed Directional Jets (6)', 5, 'each; small target: called shot only', 2),
  ('ng-400-stinger-hovercycle', 'Undercarriage Directional Jets (4)', 5, 'each; small target: called shot only', 3),
  ('ng-400-stinger-hovercycle', 'Forward Headlights (2)', 5, 'each; small target: called shot only', 4),
  ('ng-400-stinger-hovercycle', 'Tail Fin (1)', 28, NULL, 5),
  ('ng-400-stinger-hovercycle', 'Windshield (1)', 18, NULL, 6),
  ('ng-400-stinger-hovercycle', 'Main Body', 90, NULL, 7),
  ('ng-400-stinger-hovercycle', 'Optional Weapons', NULL, 'typically 2D6+14 M.D.C. each; small target: called shot only', 8),
  ('ng-480-turbo-hovercycle', 'Rear Hover Ball Jet Housing (2)', 40, 'small target: called shot only', 1),
  ('ng-480-turbo-hovercycle', 'Rear Jet Boosters (2)', 35, 'each; small target: called shot only', 2),
  ('ng-480-turbo-hovercycle', 'Undercarriage Directional Jets (8)', 4, 'each; small target: called shot only', 3),
  ('ng-480-turbo-hovercycle', 'Forward Headlight (1)', 5, 'small target: called shot only', 4),
  ('ng-480-turbo-hovercycle', 'Forward Laser Turret (1)', 32, 'small target: called shot only', 5),
  ('ng-480-turbo-hovercycle', 'Reinforced Windshield (1)', 20, NULL, 6),
  ('ng-480-turbo-hovercycle', 'Main Body', 92, NULL, 7),
  ('cs-death-wing-air-assault-armor', 'Wings (2)', 210, 'each', 1),
  ('cs-death-wing-air-assault-armor', 'Main Thrusters (2; center)', 100, 'each', 2),
  ('cs-death-wing-air-assault-armor', 'Directional VTOL Thruster Pods (2; center)', 60, 'each', 3),
  ('cs-death-wing-air-assault-armor', 'Secondary Thrusters (2; wing tips)', 130, 'each', 4),
  ('cs-death-wing-air-assault-armor', 'Twin Lasers (2; in the Secondary Thrusters)', 22, 'each; small target: called shot only, -3 to strike', 5),
  ('cs-death-wing-air-assault-armor', 'Top Mounted Weapon System (1)', 80, 'small target: called shot only, -3 to strike', 6),
  ('cs-death-wing-air-assault-armor', 'Robot Arms (2)', 40, 'each; small target: called shot only, -3 to strike', 7),
  ('cs-death-wing-air-assault-armor', 'Main Body of Wing', 290, 'depleting it makes the aircraft crash', 8),
  ('cs-death-wing-air-assault-armor', 'Pilot in AAA Power Armor', 180, 'small target: called shot only, -4 to strike', 9);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('mi-3000-firefly-hovercycle', 1, 'Light Laser', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '20 shots', NULL, 'Standard. Listed at 11,000 credits; add 5,000 to double the payload.'),
  ('mi-3000-firefly-hovercycle', 2, 'Heavy Laser', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '20 shots', NULL, 'Standard. Listed at 25,000 credits; add 5,000 for 40 shots.'),
  ('mi-3000-firefly-hovercycle', 3, 'Double-Barrel Heavy Laser', '2D6 M.D. per single shot; 4D6 M.D. per simultaneous double shot', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, 'Standard. Listed at 58,000 credits.'),
  ('mi-3000-firefly-hovercycle', 4, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, 'Standard; one launcher on each side, rotating 360 degrees. Listed at 55,000 credits each. The multi-shot missile pods do not fit.'),
  ('mi-1010-desert-fox-hovercycle', 1, 'Light Laser (optional)', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '20 shots', NULL, '11,000 credits.'),
  ('mi-1010-desert-fox-hovercycle', 2, 'Heavy Laser (optional)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '20 shots', NULL, '25,000 credits.'),
  ('mi-1010-desert-fox-hovercycle', 3, 'Dual Mini-Missile Launchers (optional)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, '55,000 credits. As many as two launchers, one on each side or the undercarriage.'),
  ('ng-220-rocket-hovercycle', 1, 'Concealed Ion Guns (2)', '3D6 M.D. per single blast; 6D6 M.D. per dual blast', 1, '500 feet (152 m)', NULL, '60 shots each', NULL, 'Standard; one on each side, disguised as small jet ports.'),
  ('ng-220-rocket-hovercycle', 2, 'Light Laser (optional)', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '40 shots', NULL, '16,000 credits.'),
  ('ng-220-rocket-hovercycle', 3, 'Heavy Laser (optional)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, '30,000 credits.'),
  ('ng-220-rocket-hovercycle', 4, 'Machinegun (optional)', '1D4 M.D. per burst of 50 rounds', 1, '2000 feet (610 m)', NULL, '1200 rounds (24 bursts)', NULL, '5,000 credits.'),
  ('ng-220-rocket-hovercycle', 5, 'Dual Mini-Missile Launchers (optional)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, '55,000 credits each. As many as four, two on each side (front, rear or undercarriage).'),
  ('ng-220-rocket-hovercycle', 6, 'Mini-Missile Pod, Multi-Shot (optional)', 'Varies with missile type', 1, NULL, 'One at a time, or 2, 4 or 6 at once', '12 mini-missiles', NULL, '110,000 credits each. Cuts maximum speed to 310 mph (496 km) and adds -10% to piloting above 200 mph (321 km).'),
  ('ng-230-prowler-hovercycle', 1, 'Heavy Laser (nose turret)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, 'Standard.'),
  ('ng-230-prowler-hovercycle', 2, 'Light Laser (optional)', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '40 shots', NULL, '16,000 credits.'),
  ('ng-230-prowler-hovercycle', 3, 'Heavy Laser (optional)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, '30,000 credits.'),
  ('ng-230-prowler-hovercycle', 4, 'Dual Mini-Missile Launchers (optional)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, '55,000 credits. As many as two, one on each side.'),
  ('ng-400-stinger-hovercycle', 1, 'Light Laser (optional)', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '40 shots', NULL, '16,000 credits.'),
  ('ng-400-stinger-hovercycle', 2, 'Heavy Laser (optional)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, '30,000 credits.'),
  ('ng-400-stinger-hovercycle', 3, 'Double-Barrel Heavy Laser (optional)', '2D6 M.D. per single shot; 4D6 M.D. per simultaneous double shot', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, '58,000 credits.'),
  ('ng-400-stinger-hovercycle', 4, 'Machinegun (optional)', '1D4 M.D. per burst of 50 rounds', 1, '2000 feet (610 m)', NULL, '1200 rounds (24 bursts)', NULL, '5,000 credits.'),
  ('ng-400-stinger-hovercycle', 5, 'Dual Machinegun & Heavy Laser (optional)', 'As the Machinegun and the Heavy Laser', 1, 'As each weapon', NULL, 'As each weapon', NULL, '34,000 credits. Both in one housing; nose only.'),
  ('ng-400-stinger-hovercycle', 6, 'Dual Mini-Missile Launchers (optional)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, '55,000 credits each. As many as four, two on each side (front, rear or undercarriage).'),
  ('ng-400-stinger-hovercycle', 7, 'Mini-Missile Pod, Multi-Shot (optional)', 'Varies with missile type', 1, NULL, 'One at a time, or 2, 4 or 6 at once', '12 mini-missiles', NULL, '100,000 credits each. Cuts maximum speed to 225 mph (360 km).'),
  ('ng-480-turbo-hovercycle', 1, 'Double-Barrel Heavy Ball-Laser (nose gun)', '2D6 M.D. per single shot; 4D6 M.D. per simultaneous double shot', 1, '2000 feet (610 m)', NULL, '60 double shots or 120 single', NULL, 'Standard. Listed at 80,000 credits.'),
  ('ng-480-turbo-hovercycle', 2, 'Light Laser (optional)', '1D6 M.D.', 1, '1200 feet (366 m)', NULL, '40 shots', NULL, '16,000 credits.'),
  ('ng-480-turbo-hovercycle', 3, 'Heavy Laser (optional)', '2D6 M.D.', 1, '2000 feet (610 m)', NULL, '40 shots', NULL, '30,000 credits.'),
  ('ng-480-turbo-hovercycle', 4, 'Dual Mini-Missile Launchers (optional)', 'Varies with missile type', 1, NULL, NULL, 'Two mini-missiles each; manual reloading, not possible while moving', NULL, '55,000 credits each. As many as two, one on each side.'),
  ('ng-480-turbo-hovercycle', 5, 'Mini-Missile Pod, Multi-Shot (optional)', 'Varies with missile type', 1, NULL, 'One at a time, or 2, 4 or 6 at once', '12 mini-missiles', NULL, '100,000 credits each. Front mount only. Cuts maximum speed by 15%, cancels the piloting bonus and makes stunts -15%.'),
  ('cs-death-wing-air-assault-armor', 1, 'High-Powered Wing Laser Guns (2)', '4D6 M.D. per single blast; 8D6 M.D. (or 1D4x10+8) per double blast from one wing; 2D4x10+12 M.D. per quadruple blast from both wings', 1, '4000 feet (1220 m)', 'Equal to the pilot''s hand to hand attacks; a double or quadruple blast counts as one attack', 'Effectively unlimited', NULL, 'Double-barrelled lasers in the wing tips, firing forward with a 25 degree arc up and down. A quadruple blast needs a target at least 22 feet (6.7 m) wide.'),
  ('cs-death-wing-air-assault-armor', 2, 'Short-Range Robot Arm Lasers (2)', '2D6 M.D. per single blast; 4D6 M.D. per double blast from both arms', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks, plus one', 'Effectively unlimited', NULL, 'The arms swing through 300 degrees front to back and 180 degrees side to side; their main purpose is as the pilot''s eyes.'),
  ('cs-death-wing-air-assault-armor', 3, 'CAAA-60R Rail Gun (top mount)', '1D4x10 M.D. per 40 round burst; 1D4 M.D. per single round', 1, '4000 feet (1200 m)', 'Equal to the pilot''s combined hand to hand attacks (usually 4-6)', '6000 round drum, 150 bursts', NULL, 'Standard. Turns 180 degrees side to side with a 45 degree arc up and down. Reloading takes about five minutes and a small crane or a SAMAS. Gun 150 lbs (67.5 kg), 250 lbs (112.5 kg) with its drum.'),
  ('cs-death-wing-air-assault-armor', 4, 'Mini-Missile Launcher (top mount)', 'Varies with missile type', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of 2, 4 or 6', '18 mini-missiles', NULL, 'Optional, in place of the rail gun.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 7 Lone Star vehicles are in' AS assertion, count(*) AS got, 7 AS want
  FROM vehicles WHERE slug IN ('mi-3000-firefly-hovercycle', 'mi-1010-desert-fox-hovercycle', 'ng-220-rocket-hovercycle', 'ng-230-prowler-hovercycle', 'ng-400-stinger-hovercycle', 'ng-480-turbo-hovercycle', 'cs-death-wing-air-assault-armor') AND source_book LIKE 'Rifts World Book 13: Lone Star p.%';
SELECT 'their 57 M.D.C. locations are in' AS assertion, count(*) AS got, 57 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('mi-3000-firefly-hovercycle', 'mi-1010-desert-fox-hovercycle', 'ng-220-rocket-hovercycle', 'ng-230-prowler-hovercycle', 'ng-400-stinger-hovercycle', 'ng-480-turbo-hovercycle', 'cs-death-wing-air-assault-armor');
SELECT 'their 33 weapon entries are in' AS assertion, count(*) AS got, 33 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('mi-3000-firefly-hovercycle', 'mi-1010-desert-fox-hovercycle', 'ng-220-rocket-hovercycle', 'ng-230-prowler-hovercycle', 'ng-400-stinger-hovercycle', 'ng-480-turbo-hovercycle', 'cs-death-wing-air-assault-armor');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-lone-star-vehicles.sql');
