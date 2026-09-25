-- Coalition War Campaign vessels, printed 105-121: the seven Coalition power
-- armors of Rifts World Book 11. 7 vehicles, 91 M.D.C. locations, 25 weapon
-- entries.
--
--   PA-100 Mauler, printed 106-107
--   PA-200 Terror Trooper, printed 107-110
--   PA-300 Glitter Boy Killer, printed 110-112
--   PA-06A "Death's Head" SAMAS, printed 113-114
--   PA-07A "Smiling Jack" Light Assault SAMAS, printed 114-116
--   PA-09A Super SAMAS, printed 117-119
--   PA-08A Special Forces "Striker" SAMAS, printed 119-122 (its weapon
--     systems 2-7 run onto printed 122, the first page of the Skelebots)
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local <this file>
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1) and
-- pymupdf doc[N]. The text layer carries the digit cipher (!D4xlO = 1D4x10)
-- on every weapon page here and was used only to find things.
--
-- PAGES READ OFF A 200 DPI RENDER: printed 105-122, every one. Printed 111 and
-- 120 are full-page art (their cache pages p112 and p121 are empty). The text
-- layer sets the Smiling Jack's location list out of order (Legs before
-- Hands); the render is two columns, and the ordinals follow the render.
--
-- PRINTED 105 is the section opener, not a machine. What it gives every CS
-- power armor: nuclear power, average life 15 to 20 years; upgraded radar
-- identifying 72 and tracking 48 targets at 10 miles (16 km); combat computer
-- feeding a helmet H.U.D.; targeting computer, 10 mile (16 km) range; laser
-- targeting (a strike bonus with long-range weapons, not hand to hand);
-- long-range directional radio about 500 miles (800 km) plus a 5 mile (8 km)
-- short-range radio; 80 decibel loudspeaker; full environmental armor
-- (underwater from several hundred feet to one mile depending on the suit,
-- and outer space) with life support, cooling, air filtration, an eight hour
-- oxygen supply stretched to days by recycling, shielding to 400 degrees
-- centigrade (normal fire does nothing; nuclear, plasma and magic fire do
-- full damage), radiation shielding and a polarized visor; and +2 on
-- initiative and +1 to strike from the combat and targeting computers. Each
-- description repeats the bonus and points here for the rest.
--
-- BOOK SLIPS, stored as printed and noted on the row:
--   printed 107  the Mauler's shoulder plasma ejectors do "4D6 per laser
--                blast"; its forearm weapon is "Forearm Blasters" in the
--                M.D.C. list and "Forearm Lasers" in the weapons.
--   printed 107/109  the Terror Trooper's standard hand weapon is the CTT-P40
--                in the prose and the CTT-M20 in the weapon list. The M20's
--                payload repeats the back launchers' "20 total; 10 per launch
--                tube"; the P40 does 1D6x10 "per single laser blast".
--   printed 112  the Glitter Boy Killer's ranges convert feet to km: 1600 feet
--                (488 km), 1200 feet (366 km), 1200 feet (365 km), 2000 feet
--                (610 km). Its plasma and ion guns do damage "per single
--                laser blast", and the anti-missile laser turret's printed
--                purpose is Anti-Glitter Boy/Anti-Armor.
--   printed 118  the Super SAMAS's main body is set "Mam Body" (stored as
--                Main Body); on printed 119 its plasma range is 1600 feet
--                (488 km) and grenade range 1000 feet (305 km), its light
--                laser does "3D6 damage" with no unit, and the ram costs the
--                suit "1D4" with no unit.
--   printed 121  the Striker's C-40R entry says it is standard equipment for
--                the "Smiling Jack" - copied from printed 116.
--
-- PRICES. Every suit prints a figure: "CS Cost" for six, "Black Market Cost"
-- for the Death's Head SAMAS, which is the one old model the market sees.
-- All seven are stored; the note says which kind of figure it is.
--
-- THE HAND WEAPONS ARE ALSO GEAR ROWS: ctt-m20-missile-rifle,
-- ctt-p40-particle-beam-cannon and c-40r-coalition-samas-rail-gun. Where a
-- suit's own weapon list numbers and stats one of them, it is a
-- vehicle_weapons row here too. Numbered entries that only say "energy rifles
-- can be used", "hand to hand combat" or "sensor system note" are in the
-- description, with each suit's hand to hand table and sensor bonuses. The
-- catalog's gear row samas-power-armor is a different, older record and is
-- not touched.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('pa-100-mauler-power-armor', 'PA-100 Mauler Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 40 mph (64 km) maximum; tires the pilot at 10% of the usual rate. Legs and jets together leap 15 feet (4.6 m) high or lengthwise with a short running start.', NULL, 'Swimming 15 mph (24 km/12.75 knots) on its thrusters, about the same on the surface; maximum depth one mile (1.6 km)', 'Height 8 feet (2.4 m), width 4.5 feet (1.4 m), length 4 feet (1.2 m)', '1800 lbs (810 kg)', 280, 3400000, 'CS Cost: 3.4 million credits.', 'Model PA-100, heavy all-purpose combat power armor, nicknamed "No Neck": an Iron Heart design, slow and heavily armored, a small walking tank best at urban assault, riot control, heavy infantry support and deep-water work; poor at pursuit, guerilla or forest operations. The Navy Advisory Commission has used it on the Great Lakes for four years. Maneuvering jets on hips, forearms, shoulders and back aid leaps and drive it underwater; four head lights (two infrared) and two infrared belly lights; rated for space. P.S. equal to 36; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike. Energy rifles, rail guns or other hand weapons can be carried as well. Hand to hand: Basic Power Armor Combat Training only (Rifts RPG p.45), no better.', 'Rifts World Book 11: Coalition War Campaign p.106-107'),
  ('pa-200-terror-trooper-power-armor', 'PA-200 Terror Trooper Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 60 mph (96.5 km) maximum; tires the pilot at 10% of the usual rate. Leaps 15 feet (4.6 m) high or lengthwise with a short running start.', NULL, 'Swimming about 5 mph (8 km/4.25 knots) by paddling (no thrusters); walks the sea bottom at about 25% of its running speed; maximum depth one mile (1.6 km)', 'Height 11 feet (3.3 m), width 6 feet (1.8 m), length 5 feet (1.5 m)', '1250 lbs (562.5 kg)', 400, 4100000, 'CS Cost: 4.1 million credits.', 'Model PA-200, heavy assault combat power armor: a black, spiked Chi-Town suit with a Special Forces style skull face plate, built for RPA pilots, commandos and Special Forces. The pilot sits in the chest and works the robot limbs, as in the Triax Ulti-Max. Low enough profile to ride in a truck, helicopter or APC. Extendable finger claws; two chest cameras (x15 telescopic, passive night sight) back up the head optics. P.S. equal to 40; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike. The standard hand weapon is the CTT-M20 missile rifle in the weapon list but the CTT-P40 in the prose (printed 107); a rail gun can substitute, and other heavy weapons can be carried. Hand to hand: Basic or Elite Power Armor Combat Training (Rifts RPG p.45) except restrained punch 1D4 M.D., normal punch or kick 2D4 M.D., power punch 4D4 M.D. (two attacks), claw strike 2D6 M.D., claw power strike 4D6 M.D., leap kick 2D6 M.D. (two attacks), body flip/throw 1D6 M.D., body block/tackle 1D6 M.D.', 'Rifts World Book 11: Coalition War Campaign p.107-110'),
  ('pa-300-glitter-boy-killer-power-armor', 'PA-300 Glitter Boy Killer Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 100 mph (160 km) maximum, zero to 60 mph (96.5 km) in 11 seconds; running does not tire the pilot. Leaps 20 feet (6 m) high or lengthwise with a short running start.', NULL, 'Swimming about 4 mph (6.4 km/3.4 knots) by paddling (no thrusters); walks the sea bottom at about 25% of its running speed; maximum depth 4000 feet (1200 m)', 'Height 14 feet (4.3 m), width 7 feet (2.1 m), length 5 feet (1.5 m)', '2 tons', 440, 12600000, 'CS Cost: 12.6 million credits.', 'Model PA-300, heavy assault combat power armor: an experimental suit built to beat the Glitter Boy through speed and close-quarters firepower, knocking out the Boom Gun with missiles first. Nearly 10,000 ordered, 90% already bound for the Quebec front. It is strong in cover and cities and loses to a Glitter Boy in the open at half a mile or more, so the CS plans to field it in pairs. The pilot sits in the chest working levers and pedals; spiked knee guards; heavy feet for traction. Destroying the head does not blind the pilot: two chest sensor clusters take over, and only when all three are gone are the power armor bonuses lost. P.S. equal to 40; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike. It cannot use energy rifles or other heavy hand weapons because of its forearms, though the hands can carry things. Hand to hand: Basic or Elite Power Armor Combat Training (Rifts RPG p.45) except punch or kick 1D6 M.D., power punch 2D6 M.D. (two attacks), vibro-blade strike 3D6 or 2D6 M.D. single or 5D6 M.D. double, double-blade power strike 1D6x10 M.D. (two attacks), leap kick 2D6 M.D. (two attacks), body flip/throw 1D4 M.D., body block/tackle 1D6 M.D.', 'Rifts World Book 11: Coalition War Campaign p.110-112'),
  ('pa-06a-deaths-head-samas', 'PA-06A "Death''s Head" SAMAS', 'rifts', 'power-armor', 'One', NULL, 'Running 60 mph (96 km) maximum, zero to 60 mph (96.5 km) in 12 seconds; tires the pilot at 10% of the usual rate. Leaps 15 feet (4.6 m) high or across unassisted; thruster-assisted 100 feet (30.5 m) high and 200 feet (61 m) across.', 'Hovers up to 200 feet (61 m); 300 mph (480 km) maximum, 150 mph (240 km) cruising. Holds 6000 feet (1829 m) in the field, optimum ground level to 1000 feet (305 m). The jets must cool after 10 hours above cruising speed or 24 at cruise; indefinite with rest stops.', 'Swimming about 4 mph (6.4 km/3.4 knots) by paddling; bottom-walking at about 25% of running speed; on thrusters 50 mph (80 km/42.5 knots) on the surface and 40 mph (64 km/34 knots) underwater; maximum depth 1000 feet (305 m)', 'Height 8 feet (2.4 m), width 3.5 feet (1.06 m) wings down and 10 feet (3 m) extended, length 4 feet 6 inches (1.4 m)', '340 lbs (153 kg) without rail gun', 250, 1600000, 'Black Market Cost: 1.6 million credits for a new, undamaged, fully powered suit with rail gun and one full ammo drum; rarely available.', 'Model PA-06A, Strategic Armor Military Assault Suit, nicknamed "Old Sam": the original flying SAMAS, now semi-retired to the ISS, with over 3.2 million stockpiled and half in ISS use; still issued to commandos, Special Forces and elite RPA pilots. Folding wings allow VTOL and flight down corridors; losing a wing ends flight but not jet leaps or hovering. Secretly a lightly modified pre-Rifts American Air Force design. P.S. equal to 30; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike. Full optics (laser targeting, telescopic, passive nightvision, thermo-imaging, infrared, ultraviolet, polarization) add +1 to strike and +1 to dodge. Any infantry weapon can replace or back up the rail gun (usually one handgun and/or one rifle), and the CTT-M20 or CTT-P40 serves as an oversized two-handed weapon; a satchel of 6-12 grenades can be dropped like bombs. Hand to hand: Basic or Elite Power Armor Combat Training (Rifts RPG p.45).', 'Rifts World Book 11: Coalition War Campaign p.113-114'),
  ('pa-07a-smiling-jack-light-assault-samas', 'PA-07A "Smiling Jack" Light Assault SAMAS', 'rifts', 'power-armor', 'One', NULL, 'Running 60 mph (96 km) maximum; tires the pilot at 10% of the usual rate. Leaps 15 feet (4.6 m) high or across unassisted; thruster-assisted 100 feet (30.5 m) high and 200 feet (61 m) across.', 'Hovers up to 1000 feet (305 m); 300 mph (480 km) maximum, 150 mph (240 km) cruising; maximum altitude 6000 feet (1829 m), optimum ground level to 4000 feet (1200 m). The jets must cool after 10 hours above cruising speed or 24 at cruise; indefinite with rest stops.', 'Swimming about 4 mph (6.4 km/3.4 knots) by paddling; bottom-walking at about 25% of running speed; on thrusters 50 mph (80 km/42.5 knots) on the surface and 40 mph (64 km/34 knots) underwater; maximum depth 1000 feet (305 m)', 'Height 8 feet (2.4 m), 10 feet (3 m) with the top air foil; width 3.5 feet (1.06 m) wings down and 12 feet (3.6 m) extended; length 4 feet 6 inches (1.4 m)', '500 lbs (225 kg) without the rail gun and ammo drum', 250, 1800000, 'CS Cost: 1.8 million credits for a new, undamaged, fully powered suit with rail gun and one full ammo drum. None has yet reached the Black Market.', 'Model PA-07A, Strategic Armor Military Assault Suit: the new low-altitude SAMAS, styled like the new CS body armor, its jaw set in a fixed toothy grin behind a one-way M.D. glass visor. Same basic features and roles as the Death''s Head; the differences are a single top air intake jet, lighter but equally strong armor, mini-missiles in the wings and five lower jets for control above 1000 feet. Losing a wing ends flight but not jet leaps or hovering. P.S. equal to 30; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike. Full optics as the Death''s Head add +1 to strike and +1 to dodge. Infantry weapons, or the CTT-M20 or CTT-P40 as an oversized two-handed weapon, as the Death''s Head. Hand to hand: Basic or Elite Power Armor Combat Training (Rifts RPG p.45).', 'Rifts World Book 11: Coalition War Campaign p.114-116'),
  ('pa-09a-super-samas', 'PA-09A Super SAMAS', 'rifts', 'power-armor', 'One', NULL, 'Running 40 mph (64 km) maximum with the flight pack, 60 mph (96.5 km) without; tires the pilot at 10% of the usual rate. With the pack it leaps only thruster-assisted, up to 200 feet (61 m) high and 300 feet (91.5 m) across; without it, 20 feet (6 m) unassisted or 40 feet (12.2 m) on the foot thrusters.', 'Hovers at any altitude; 500 mph (804.5 km) maximum, 150-200 mph (240-321.8 km) cruising; maximum altitude 16,000 feet (4876.8 m), roughly three miles. The jets must cool after eight hours above cruising speed or 16 at cruise; indefinite with rest stops. Each destroyed jet thruster costs 25% of speed.', 'Swimming about 4 mph (6.4 km/3.4 knots) by paddling; bottom-walking at about 25% of running speed; on thrusters 100 mph (160 km/85 knots) on the surface and 70 mph (112.6 km/59.5 knots) underwater; maximum depth 3000 feet (910 m)', 'Height 10 feet (3 m), 13 feet (3.96 m) with the top intake jets; width 5 feet (1.5 m) wings down and 16 feet (4.87 m) extended; length 6 feet (1.8 m)', '2.4 tons without the rail gun or other heavy hand weapon; the flight pack alone is 1.2 tons', 425, 5800000, 'CS Cost: 5.8 million credits for a new, undamaged, fully powered suit with rail gun and one full ammo drum. None has yet reached the Black Market.', 'Model PA-09A, Strategic Armor Military Assault Suit, the "Grinning Demon" or "Super-Sam": a heavy high- and low-altitude SAMAS for front-line combat and support, built to dogfight slow and medium aircraft, hover vehicles, power armor and flying monsters, and to gang up on tanks and Glitter Boys in squads of 4-10. Weak against anything supersonic, and short-ranged apart from the rail gun. The wings, jets and shoulder guns sit on a flight pack that comes off in two melee rounds (30 seconds), halving the weight; reattaching takes 2D4 minutes and two power armor troops or a crane, and the ammo drum then moves to a back mount. Losing a wing ends flight but not jet leaps or hovering. P.S. equal to 38; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike; sensors as the other SAMAS. No standard hand weapon: usually a rail gun, CTT-M20 or CTT-P40, fired one-handed without penalty, or any infantry rifle or vibro-blade. Hand to hand: Elite Power Armor Combat Training (Rifts RPG p.45) plus +3 to pull punch and +2 on initiative; restrained punch 1D4 M.D., full strength punch 2D4 M.D., power punch 3D6 M.D. (two attacks), tear or pry 1D4 M.D., kick 2D6 M.D., running leap kick 6D6 M.D. (first attack of a round, uses all but one attack), body block/tackle 1D6 M.D., full speed running or flying ram 5D6 M.D. (three attacks, and 1D4 to the suit - no unit printed).', 'Rifts World Book 11: Coalition War Campaign p.117-119'),
  ('pa-08a-special-forces-striker-samas', 'PA-08A Special Forces "Striker" SAMAS', 'rifts', 'power-armor', 'One', NULL, 'Running 70 mph (112.6 km) maximum; tires the pilot at 10% of the usual rate. Leaps 20 feet (6 m) high or across unassisted; thruster-assisted 100 feet (30.5 m) high and 200 feet (61 m) across.', 'Hovers or flies; 330 mph (528 km) maximum, 150 mph (240 km) cruising; maximum altitude 6000 feet (1829 m), optimum ground level to 4000 feet (1200 m). The jets must cool after 10 hours above cruising speed or 24 at cruise; indefinite with rest stops.', 'Swimming about 4 mph (6.4 km/3.4 knots) by paddling; bottom-walking at about 25% of running speed; on thrusters 50 mph (80 km/42.5 knots) on the surface and 40 mph (64 km/34 knots) underwater; maximum depth 2000 feet (610 m)', 'Height 8 feet 6 inches (2.4 m), 10.6 feet (3.25 m) with the top intake jets, as printed; width 3.5 feet (1.06 m) wings down and 12 feet (3.6 m) extended; length 4 feet 6 inches (1.4 m)', '600 lbs (270 kg) without the rail gun and ammo drum', 325, 2600000, 'CS Cost: 2.6 million credits for a new, undamaged, fully powered suit with rail gun and one full ammo drum. None has yet reached the Black Market.', 'Model PA-08A, Strategic Armor Military Assault Suit: a Special Forces low-altitude SAMAS crossing the Death''s Head (which it resembles) with the Super SAMAS''s heavier armor and weapons, used for sabotage, assassination, deep reconnaissance, anti-supernatural and other covert missions; only rarely lent to elite RPA pilots. Black, with the Special Forces Death''s Head face plate, two extra chest sensor clusters and two chest spotlights (one infrared); mini-missile launchers in the collar, wings and forearms. Losing a wing ends flight but not jet leaps or hovering. P.S. equal to 36; no cargo. Nuclear, average 20 years. Has the standard CS power armor features of printed 105, including +2 on initiative and +1 to strike; its full optics add +1 on initiative, +1 to strike and +1 to dodge. The CTT-P40 particle beam rifle is its standard issue (stats on the Terror Trooper, printed 109), the CTT-M20 or any rail gun substituting; either oversized gun fired one-handed is -2 to strike. It can also use any infantry weapon, as the Death''s Head. Hand to hand: Basic or Elite Power Armor Combat Training (Rifts RPG p.45).', 'Rifts World Book 11: Coalition War Campaign p.119-122');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('pa-100-mauler-power-armor', 'Hands (2)', 25, 'Each. Called shot only, at -4 to strike.', 1),
  ('pa-100-mauler-power-armor', 'Arms (2)', 100, 'Each.', 2),
  ('pa-100-mauler-power-armor', 'Legs (2)', 150, 'Each.', 3),
  ('pa-100-mauler-power-armor', 'Plasma Shoulder Guns (2)', 65, 'Each.', 4),
  ('pa-100-mauler-power-armor', 'Concealed Mini-Missile Launcher (1; back)', 50, NULL, 5),
  ('pa-100-mauler-power-armor', 'Concealed Forearm Blasters (2)', 50, 'Each. The weapon list calls them Forearm Lasers.', 6),
  ('pa-100-mauler-power-armor', 'Retractable Vibro-Sabers (2)', 50, 'Each.', 7),
  ('pa-100-mauler-power-armor', 'Rear Jet Thruster (1)', 50, NULL, 8),
  ('pa-100-mauler-power-armor', 'Shoulder Thruster Units (2)', 30, 'Each.', 9),
  ('pa-100-mauler-power-armor', 'Maneuvering Jets (8)', 15, 'Each. Called shot only, at -4 to strike.', 10),
  ('pa-100-mauler-power-armor', 'Mini-Lights (6)', 1, 'Each. Called shot only, at -4 to strike.', 11),
  ('pa-100-mauler-power-armor', 'Head', 90, 'Destroying it loses all optics and sensors and the power armor bonuses to strike, parry and dodge. Tucked between the shoulders: called shot only, at -4 to strike.', 12),
  ('pa-100-mauler-power-armor', 'Main Body', 280, 'Depleting it shuts the armor down completely.', 13),
  ('pa-200-terror-trooper-power-armor', 'Hands (2)', 45, 'Each. Called shot only, at -4 to strike.', 1),
  ('pa-200-terror-trooper-power-armor', 'Arms (2)', 85, 'Each.', 2),
  ('pa-200-terror-trooper-power-armor', 'Legs (2)', 160, 'Each.', 3),
  ('pa-200-terror-trooper-power-armor', 'Tube Mini-Missile Launchers (2; back)', 50, 'Each.', 4),
  ('pa-200-terror-trooper-power-armor', 'Forearm Lasers (2)', 70, 'Each. Called shot only, at -4 to strike.', 5),
  ('pa-200-terror-trooper-power-armor', 'Rifle or Rail Gun (1)', 100, NULL, 6),
  ('pa-200-terror-trooper-power-armor', 'Secondary Optics/Cameras (2; chest)', 5, 'Each. Called shot only, at -4 to strike. The back-up optics if the head is lost.', 7),
  ('pa-200-terror-trooper-power-armor', 'Head (Main sensors)', 100, 'Destroying it loses radar, sensors and main optics and the power armor bonuses to strike, parry and dodge. Called shot only, at -3 to strike.', 8),
  ('pa-200-terror-trooper-power-armor', 'Main Body', 400, 'Depleting it shuts the armor down completely.', 9),
  ('pa-300-glitter-boy-killer-power-armor', 'Hands (2)', 25, 'Each. Called shot only, at -4 to strike.', 1),
  ('pa-300-glitter-boy-killer-power-armor', 'Lower Arms (2)', 110, 'Each.', 2),
  ('pa-300-glitter-boy-killer-power-armor', 'Upper Arms (2; thin)', 55, 'Each. Called shot only, at -4 to strike.', 3),
  ('pa-300-glitter-boy-killer-power-armor', 'Forearm Plasma Gun (1; left)', 35, 'Called shot only, at -4 to strike.', 4),
  ('pa-300-glitter-boy-killer-power-armor', 'Forearm Ion Gun (1; left)', 15, 'Called shot only, at -4 to strike.', 5),
  ('pa-300-glitter-boy-killer-power-armor', 'Forearm Grenade Launcher (1; right)', 20, 'Called shot only, at -4 to strike.', 6),
  ('pa-300-glitter-boy-killer-power-armor', 'Small Forearm Vibro-Blades (2)', 50, 'Each.', 7),
  ('pa-300-glitter-boy-killer-power-armor', 'Large Forearm Vibro-Blades (2)', 90, 'Each.', 8),
  ('pa-300-glitter-boy-killer-power-armor', 'Extra Gun Arms (2; shoulders)', 45, 'Each. Called shot only, at -4 to strike.', 9),
  ('pa-300-glitter-boy-killer-power-armor', 'Triple Barrel Laser Turret (1; back)', 80, NULL, 10),
  ('pa-300-glitter-boy-killer-power-armor', 'Legs (2)', 230, 'Each.', 11),
  ('pa-300-glitter-boy-killer-power-armor', 'Feet (2)', 100, 'Each.', 12),
  ('pa-300-glitter-boy-killer-power-armor', 'Mini-Tube Mini-Missile Launchers (10; shoulders)', 10, 'Each. Called shot only, at -4 to strike.', 13),
  ('pa-300-glitter-boy-killer-power-armor', 'Secondary Sensor Clusters (2; chest)', 45, 'Each. They replace the head sensors if it is lost.', 14),
  ('pa-300-glitter-boy-killer-power-armor', 'Head (Main sensors)', 90, 'Destroying it loses the main sensors and optics but does not blind the pilot while a chest cluster survives; with all three gone the power armor bonuses to strike, parry and dodge are lost. Called shot only, at -3 to strike.', 15),
  ('pa-300-glitter-boy-killer-power-armor', 'Main Body', 440, 'Depleting it shuts the armor down completely.', 16),
  ('pa-06a-deaths-head-samas', 'Shoulder Wings (2)', 50, 'Each (improved M.D.C.). Called shot only, at -4 to strike. Destroying a wing makes flight impossible.', 1),
  ('pa-06a-deaths-head-samas', 'Main Rear Jets (2)', 60, 'Each.', 2),
  ('pa-06a-deaths-head-samas', 'Lower Maneuvering Jets (2; small)', 25, 'Each.', 3),
  ('pa-06a-deaths-head-samas', 'Ammo Drum (rear)', 35, 'Called shot only, at -4 to strike.', 4),
  ('pa-06a-deaths-head-samas', 'Rail Gun', 50, 'Called shot only, at -4 to strike.', 5),
  ('pa-06a-deaths-head-samas', 'Forearm Mini-Missile Launcher (1; left)', 50, NULL, 6),
  ('pa-06a-deaths-head-samas', 'Hands (2)', 25, 'Each. Called shot only, at -4 to strike.', 7),
  ('pa-06a-deaths-head-samas', 'Arms (2)', 50, 'Each.', 8),
  ('pa-06a-deaths-head-samas', 'Legs (2)', 100, 'Each.', 9),
  ('pa-06a-deaths-head-samas', 'Head', 70, 'Destroying it loses all optics and sensors and the power armor combat bonuses to strike, parry and dodge. Called shot only, at -3 to strike.', 10),
  ('pa-06a-deaths-head-samas', 'Main Body', 250, 'Depleting it shuts the armor down completely.', 11),
  ('pa-07a-smiling-jack-light-assault-samas', 'Shoulder Wings (2)', 85, 'Each. Called shot only, at -4 to strike. Destroying a wing makes flight impossible.', 1),
  ('pa-07a-smiling-jack-light-assault-samas', 'Wing Mini-Missile Launchers (6 total)', 8, 'Each. Called shot only, at -4 to strike.', 2),
  ('pa-07a-smiling-jack-light-assault-samas', 'Main Rear Jets (2)', 60, 'Each.', 3),
  ('pa-07a-smiling-jack-light-assault-samas', 'Lower Maneuvering Jets (5)', 25, 'Each.', 4),
  ('pa-07a-smiling-jack-light-assault-samas', 'Intake Jet (1; top)', 40, NULL, 5),
  ('pa-07a-smiling-jack-light-assault-samas', 'Ammo Drum (rear)', 35, 'Called shot only, at -4 to strike.', 6),
  ('pa-07a-smiling-jack-light-assault-samas', 'Rail Gun', 50, 'Called shot only, at -4 to strike.', 7),
  ('pa-07a-smiling-jack-light-assault-samas', 'Hands (2)', 25, 'Each. Called shot only, at -4 to strike.', 8),
  ('pa-07a-smiling-jack-light-assault-samas', 'Arms (2)', 50, 'Each.', 9),
  ('pa-07a-smiling-jack-light-assault-samas', 'Legs (2)', 100, 'Each.', 10),
  ('pa-07a-smiling-jack-light-assault-samas', 'Head', 70, 'Destroying it loses all optics and sensors and the power armor combat bonuses to strike, parry and dodge. Called shot only, at -3 to strike.', 11),
  ('pa-07a-smiling-jack-light-assault-samas', 'Main Body', 250, 'Depleting it shuts the armor down completely.', 12),
  ('pa-09a-super-samas', 'Shoulder Wings (2)', 95, 'Each. Called shot only, at -4 to strike. Destroying a wing makes flight impossible.', 1),
  ('pa-09a-super-samas', 'Main Rear Jets (4)', 100, 'Each. Each destroyed jet thruster costs 25% of speed.', 2),
  ('pa-09a-super-samas', 'Lower Maneuvering Jets (3; rear)', 30, 'Each. Called shot only, at -4 to strike.', 3),
  ('pa-09a-super-samas', 'Twin Air-Intake Jets (2; top)', 100, 'Each.', 4),
  ('pa-09a-super-samas', 'Ammo Drum (1; hip mounted)', 35, 'Called shot only, at -4 to strike.', 5),
  ('pa-09a-super-samas', 'Rail Gun (1)', 50, 'Called shot only, at -4 to strike.', 6),
  ('pa-09a-super-samas', 'CTT-M20 or CTT-P40 rifle (1; instead of rail gun)', 100, NULL, 7),
  ('pa-09a-super-samas', 'Dual Plasma/Laser Guns (2; shoulders)', 40, 'Each.', 8),
  ('pa-09a-super-samas', 'Forearm Vibro-Blades (6)', 50, 'Each. Called shot only, at -4 to strike.', 9),
  ('pa-09a-super-samas', 'Forearm Grenade Launchers (2)', 50, 'Each. Called shot only, at -4 to strike.', 10),
  ('pa-09a-super-samas', 'Hands (2)', 45, 'Each. Called shot only, at -4 to strike.', 11),
  ('pa-09a-super-samas', 'Arms (2)', 120, 'Each.', 12),
  ('pa-09a-super-samas', 'Legs (2)', 200, 'Each.', 13),
  ('pa-09a-super-samas', 'Head', 90, 'Destroying it loses all optics and sensors and the power armor bonuses to initiative, strike, parry and dodge. Shielded by the intake and rear jets: called shot only, at -5 to strike.', 14),
  ('pa-09a-super-samas', 'Main Body', 425, 'Printed "Mam Body". Depleting it shuts the armor down completely.', 15),
  ('pa-08a-special-forces-striker-samas', 'Shoulder Wings (2)', 80, 'Each. Called shot only, at -4 to strike. Destroying a wing makes flight impossible.', 1),
  ('pa-08a-special-forces-striker-samas', 'Wing Mini-Missile Launchers (6 total)', 8, 'Each. Called shot only, at -4 to strike.', 2),
  ('pa-08a-special-forces-striker-samas', 'Chest Mini-Missile Launchers (6 total)', 8, 'Each. Called shot only, at -4 to strike.', 3),
  ('pa-08a-special-forces-striker-samas', 'Forearms with Missile Launchers (2)', 80, 'Each. Called shot only, at -4 to strike.', 4),
  ('pa-08a-special-forces-striker-samas', 'Upper Arms (2)', 70, 'Each.', 5),
  ('pa-08a-special-forces-striker-samas', 'Hands (2)', 25, 'Each. Called shot only, at -4 to strike.', 6),
  ('pa-08a-special-forces-striker-samas', 'Legs (2)', 130, 'Each.', 7),
  ('pa-08a-special-forces-striker-samas', 'Main Rear Jets (2)', 60, 'Each.', 8),
  ('pa-08a-special-forces-striker-samas', 'Lower Maneuvering Jets (3)', 30, 'Each.', 9),
  ('pa-08a-special-forces-striker-samas', 'Intake Jets (2; top)', 50, 'Each.', 10),
  ('pa-08a-special-forces-striker-samas', 'Ammo Drum (rear)', 35, 'Called shot only, at -4 to strike.', 11),
  ('pa-08a-special-forces-striker-samas', 'Rail Gun', 50, 'Called shot only, at -4 to strike.', 12),
  ('pa-08a-special-forces-striker-samas', 'CTT-M20 or CTT-P40 rifle (1; instead of rail gun)', 100, NULL, 13),
  ('pa-08a-special-forces-striker-samas', 'Head', 90, 'Destroying it loses all optics and sensors and the power armor combat bonuses to strike, parry and dodge. Called shot only, at -3 to strike.', 14),
  ('pa-08a-special-forces-striker-samas', 'Main Body', 325, 'Depleting it shuts the armor down completely.', 15);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('pa-100-mauler-power-armor', 1, 'Shoulder Plasma Ejectors (2)', '4D6 M.D. per blast (printed "per laser blast")', 1, '1200 feet (365.7 m)', 'Each twice per melee round', 'Effectively unlimited; tied to the suit''s power supply', NULL, 'Anti-personnel, secondary defense. Behind both shoulders; each rotates 180 degrees with a 60 degree arc of fire.'),
  ('pa-100-mauler-power-armor', 2, 'Concealed Back Mini-Missile Launcher (1)', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.)', 1, 'Usually about a mile (1.6 km)', 'One at a time or in volleys of two or three', 'Eight; reloadable by hand by power armor or a soldier with P.S. 20, about 10 seconds per missile', NULL, 'Anti-armor/anti-aircraft, secondary defense. Disguised as a set of directional thrusters on top of the jet thruster.'),
  ('pa-100-mauler-power-armor', 3, 'Forearm Lasers (2)', '2D6 M.D. per blast', 1, '1200 feet (365.7 m)', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Anti-personnel, secondary defense. Concealed in the forearm plates.'),
  ('pa-100-mauler-power-armor', 4, 'Retractable Forearm Vibro-Sabers (2)', '2D4 M.D. each', 1, 'Hand to hand', NULL, NULL, '+1 to strike and parry', 'Short vibro-swords from underarm housings; can parry M.D. attacks, energy blasts at -6 and arrows and missiles at -4.'),
  ('pa-200-terror-trooper-power-armor', 1, 'Forearm Laser Blasters (2)', '3D6 M.D. per blast; both arms on one target 6D6 M.D. (one attack, -2 to strike, and nothing large can be held)', 1, '2000 feet (610 m)', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Anti-personnel, secondary defense.'),
  ('pa-200-terror-trooper-power-armor', 2, 'Mini-Missile Launcher Tubes (2)', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.)', 1, 'Usually about a mile (1.6 km)', 'One at a time or in volleys of two or four', '20 total; 10 per launch tube', NULL, 'Anti-armor/anti-aircraft, secondary defense. Back-mounted.'),
  ('pa-200-terror-trooper-power-armor', 3, 'CTT-M20 Missile Rifle (1)', 'Mini-missiles vary; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.). Top-mounted laser 2D6 M.D. per shot', 1, 'Mini-missiles usually about a mile (1.6 km); laser 2000 feet (610 m)', 'One at a time or in volleys of two or four', '20 total; 10 per launch tube (as printed, repeating the back launchers). The laser takes a standard E-clip (20 shots) or long E-clip (30 shots)', 'Laser targeting sight +1 to strike', 'Anti-armor/anti-aircraft, secondary defense. A giant twin-barrel rifle firing one self-guided mini-missile per trigger pull. Listed as the Terror Trooper''s standard issue here, though the prose on printed 107 gives the CTT-P40; also used by SAMAS, full conversion borgs and the odd Juicer. Also a gear row: ctt-m20-missile-rifle.'),
  ('pa-200-terror-trooper-power-armor', 4, 'CTT-P40 Particle Beam Cannon (1; optional)', '1D6x10 M.D. per blast (printed "per single laser blast")', 1, '2000 feet (610 m)', 'Equal to the hand to hand attacks per melee', '40 particle beam blasts; the back half of the weapon is a rechargeable energy cell', NULL, 'Anti-personnel, secondary defense. Giant P-beam rifle with a box laser targeting system and passive nightvision scope (20x, 3000 foot/910 m range); standard issue on the Striker SAMAS. Also a gear row: ctt-p40-particle-beam-cannon.'),
  ('pa-300-glitter-boy-killer-power-armor', 1, 'Forearm Plasma Gun (1)', '6D6 M.D. per blast (printed "per single laser blast"); 1D6x10 M.D. fired with the ion gun on one target (one attack)', 1, '1600 feet (488 km) as printed; 1600 feet is 488 m', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Anti-Glitter Boy/anti-armor, secondary anti-personnel and defense. Left forearm, over the ion gun.'),
  ('pa-300-glitter-boy-killer-power-armor', 2, 'Forearm Ion Gun (1)', '3D6 M.D. per blast (printed "per single laser blast"); 1D6x10 M.D. fired with the plasma gun on one target (one attack)', 1, '1200 feet (366 km) as printed; 1200 feet is 366 m', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Anti-Glitter Boy/anti-armor, secondary anti-personnel and defense. Left forearm, beneath the plasma gun.'),
  ('pa-300-glitter-boy-killer-power-armor', 3, 'Forearm Grenade Launcher (1)', 'Conventional M.D. rifle grenade 2D6 M.D. to a 12 foot (3.6 m) blast area; micro-fusion grenade 6D6 M.D. to a 12 foot (3.6 m) diameter/six foot (1.8 m) radius', 1, '1200 feet (365 km) as printed; 1200 feet is 365 m', 'Equal to the hand to hand attacks per melee, singly or in volleys of two (one attack)', '40 total', NULL, 'Anti-Glitter Boy/anti-armor, secondary anti-personnel and defense. Right forearm, a quad launcher for rifle grenades.'),
  ('pa-300-glitter-boy-killer-power-armor', 4, 'Forearm Vibro-Blades (4)', '3D6 M.D. large blade, 2D6 M.D. small blade, 5D6 M.D. simultaneous double blade strike', 1, 'Hand to hand', NULL, NULL, NULL, 'A large fixed blade and a smaller movable one on each arm; the small blade can stab a victim pinned on the large one repeatedly, or lock forward to strike as a double blade.'),
  ('pa-300-glitter-boy-killer-power-armor', 5, 'Extra Weapon Arms (2; light rail guns)', '4D6 M.D. per full 20 round burst, or 2D6 M.D. per 10 round burst at the flip of a switch', 1, '4000 feet (1220 m)', 'Equal to the pilot''s combined hand to hand attacks (usually 4-6)', '3200 round drum, 80 bursts per arm (160 total)', NULL, 'Assault. Small gun arms under the shoulder plates; independent, or slaved to the main arm on their side.'),
  ('pa-300-glitter-boy-killer-power-armor', 6, 'Triple Barrel Laser Turret (1)', '2D6 M.D. per blast; 6D6 M.D. with all three on one target (one attack)', 1, '2000 feet (610 km) as printed; 2000 feet is 610 m', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Described as an anti-missile and anti-aircraft weapon, but its printed purpose is anti-Glitter Boy/anti-armor, secondary anti-personnel and defense. Back-mounted; the three synchronized barrels swing through a 180 degree arc, front and back.'),
  ('pa-06a-deaths-head-samas', 1, 'C-40R SAMAS Rail Gun (1)', '1D4x10 M.D. per 40 round burst; one round 1D4 M.D.', 1, '4000 feet (1200 m)', 'Equal to the combined hand to hand attacks (usually 4-6)', '2000 round drum (50 bursts). A second drum hooks under the jets; swapping needs another SAMAS or P.S. 26+, about 5 minutes untrained or one minute trained', NULL, 'Assault, secondary defense. Powered by the suit; gun 92 lbs (41.4 kg), drum 190 lbs (85.5 kg). Heavier rail guns, the CTT-M20 or the CTT-P40 can substitute. Also a gear row: c-40r-coalition-samas-rail-gun.'),
  ('pa-06a-deaths-head-samas', 2, 'CM-2 Rocket Launcher', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One or two', 'Two', NULL, 'Anti-aircraft, secondary defense. A simple two-rocket mini-missile launcher on the forearm not holding the rail gun, usually the left.'),
  ('pa-07a-smiling-jack-light-assault-samas', 1, 'C-40R SAMAS Rail Gun (1)', '1D4x10 M.D. per 40 round burst; one round 1D4 M.D.', 1, '4000 feet (1200 m)', 'Equal to the combined hand to hand attacks (usually 4-6)', '3000 round drum (75 bursts). A second drum hooks under the jets; swapping needs another SAMAS or P.S. 26+, about 5 minutes untrained or one minute trained', NULL, 'Assault, secondary defense. Gun 92 lbs (41.4 kg), drum 190 lbs (85.5 kg). Heavier rail guns, the CTT-M20 or the CTT-P40 can substitute. Also a gear row: c-40r-coalition-samas-rail-gun.'),
  ('pa-07a-smiling-jack-light-assault-samas', 2, 'SJ-6 Mini-Missile Launchers', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of two, four or six', 'Six total; three per wing', NULL, 'Anti-aircraft, secondary defense. Three small tube launchers in each wing.'),
  ('pa-09a-super-samas', 1, 'SS-09 Dual Plasma & Laser Weapon System', 'Plasma 1D6x10 M.D. per blast, 2D6x10 M.D. per dual synchronized blast; light laser 3D6 per blast (no unit printed), 6D6 M.D. dual', 1, 'Plasma 1600 feet (488 km) as printed, 1600 feet is 488 m; laser 2000 feet (610 m)', 'Equal to the pilot''s combined attacks; each single or simultaneous double blast at one target is one attack', 'Effectively unlimited; powered by the armor', NULL, 'Anti-aircraft and anti-power armor, secondary anti-armor and anti-personnel. On the flight pack above and behind the shoulders, each gun 180 degrees side to side with a 90 degree arc. Plasma and laser cannot fire together. Split between two targets, each blast is one attack and no initiative or strike bonuses apply.'),
  ('pa-09a-super-samas', 2, 'Forearm Grenade Launchers (2)', 'Conventional M.D. rifle grenade 2D6 M.D. to a 12 foot (3.6 m) blast area; usually micro-fusion grenades, 6D6 M.D. to a 12 foot (3.6 m) diameter/six foot (1.8 m) radius', 1, '1000 feet (305 km) as printed; 1000 feet is 305 m', 'Equal to the hand to hand attacks per melee, singly or in volleys of two, four, six or eight; a volley is one attack', '80 total; 40 per arm', NULL, 'Anti-Glitter Boy/anti-armor, secondary anti-personnel and defense. Rapid-fire rifle grenade launchers in the top of the forearm housings.'),
  ('pa-09a-super-samas', 3, 'Forearm Vibro-Blades (6)', '2D6 M.D. single blade; 6D6 M.D. when all three strike', 1, 'Hand to hand', NULL, NULL, NULL, 'Three fin-like blades per arm for backhand slashes at power armor, robots and aircraft. Clipping a propeller: 01-45% breaks it and forces an emergency landing or crash; 46-00 the SAMAS is caught, loses a blade, takes 2D4x10 M.D. and is flung 2D4x100 feet.'),
  ('pa-08a-special-forces-striker-samas', 1, 'C-40R SAMAS Rail Gun (1)', '1D4x10 M.D. per 40 round burst; one round 1D4 M.D.', 1, '4000 feet (1200 m)', 'Equal to the combined hand to hand attacks (usually 4-6)', '3000 round drum (75 bursts). A second drum hooks under the jets; swapping needs another SAMAS or P.S. 26+, about five minutes untrained or one minute trained', NULL, 'Assault, secondary defense. Gun 92 lbs (41.4 kg), drum 190 lbs (85.5 kg). The entry calls it standard equipment for the "Smiling Jack", copied from printed 116. Also a gear row: c-40r-coalition-samas-rail-gun.'),
  ('pa-08a-special-forces-striker-samas', 2, 'Striker-6 Mini-Missile Wing Launchers', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of two, four or six', 'Six total; three per wing', NULL, 'Anti-aircraft and anti-missile, secondary defense.'),
  ('pa-08a-special-forces-striker-samas', 3, 'Striker-6 Mini-Missile Chest Launchers', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of two, three or six', 'Six total', NULL, 'Anti-aircraft, secondary defense. Three small tubes at each collar bone.'),
  ('pa-08a-special-forces-striker-samas', 4, 'Striker-8 Forearm Mini-Missile System', 'Varies with missile; standard armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of two, four or six', '16 total; eight per arm', NULL, 'Anti-aircraft, secondary defense. Oversized forearm plating holds eight mini-missiles each.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 7 CS power armors of printed 105-121' AS assertion, count(*) AS got, 7 AS want
  FROM vehicles WHERE slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas');

SELECT 'their M.D.C. locations: 13 + 9 + 16 + 11 + 12 + 15 + 15' AS assertion, count(*) AS got, 91 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas');

SELECT 'their weapon entries: 4 + 4 + 6 + 2 + 2 + 3 + 4' AS assertion, count(*) AS got, 25 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas');

SELECT 'main bodies: 280 + 400 + 440 + 250 + 250 + 425 + 325' AS assertion, sum(mdc_main_body) AS got, 2370 AS want
  FROM vehicles WHERE slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas');

SELECT 'prices: 3.4 + 4.1 + 12.6 + 1.6 + 1.8 + 5.8 + 2.6 million' AS assertion, sum(cost) AS got, 31900000 AS want
  FROM vehicles WHERE slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas');

SELECT 'every main body location matches its vehicle' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('pa-100-mauler-power-armor', 'pa-200-terror-trooper-power-armor', 'pa-300-glitter-boy-killer-power-armor', 'pa-06a-deaths-head-samas', 'pa-07a-smiling-jack-light-assault-samas', 'pa-09a-super-samas', 'pa-08a-special-forces-striker-samas')
    AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-cwc-vessels-p105-121.sql');
