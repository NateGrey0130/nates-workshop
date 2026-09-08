-- Underseas vessels from printed pages 118-133: the New Navy fleet.

--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-vessels-p118-133.sql
--
-- See zzzzzz-underseas-vessels-p081-105.sql for the standing notes: the three
-- tables, why a vessel belongs to the slice its heading falls in, and the fact
-- that NOTHING IN THE APP READS THESE TABLES YET.
--
-- OFFSET: this file straddles the split. Printed 118-130 sit at cache pN;
-- printed 132-133 sit at cache pN-1. PRINTED 131 IS NOT IN THE SCAN AT ALL.
--
-- THE MISSING PAGE COSTS THE TICONDEROGA MOST OF ITS GUNS, and this is the
-- clearest case in the whole book of the defect scripts/books.json warns about.
-- Cache p130 ends part-way through the carrier's SECOND weapon system - the
-- Laser CIWS Turrets - after its rate of fire and before its range and
-- payload. Cache p131 opens mid-sentence in the tail of a sensor note, and the
-- USS Stingray heading follows. Everything between is gone: the CIWS range and
-- payload, and weapon systems 3 onward, which the M.D.C. location list proves
-- must include torpedo tubes, nose ion pulse cannons, cruise missile turrets,
-- counter-missile batteries and depth charge launchers.
--
-- The Ticonderoga is imported anyway and deliberately. Its identity, crew,
-- complement, speed, dimensions and its FULL twelve-row M.D.C. table are all
-- on cache p130 and are complete; only the weapon roster is short. Two of its
-- weapon systems are stored, the second carries the absence in its own note,
-- and NO ROW IS INVENTED for the systems the location table implies. Re-caching
-- cannot fix this - the page is not in the source PDF - so the gap is
-- permanent and is recorded rather than papered over.
--
-- FIVE MORE THINGS THE BOOK PRINTS THAT DO NOT ADD UP, transcribed as printed
-- and flagged on the row that carries them:
--   * the Merovingian's fragmentation mini-missile, "SD6 M.D.", which is not a
--     die - almost certainly 5D6
--   * the Iwo-Jima's sunk depth, "500 feet (15 m)"
--   * the Sea Hawk's cruise speed, "Mach One (675mph/1080mph)", both in mph
--   * the Sea Hawk's long-range missiles, FOUR in the M.D.C. table and SIX in
--     the weapon text
--   * the Ticonderoga's crew, 10,520 with troops on the stat line against
--     11,520 in the narrative on the same page
--
-- SIX OF THESE NINE VESSELS HAVE NO PRICE, and that is a finished state rather
-- than a gap: the book prints "Not available" or "Not for sale" and then an
-- estimate of what one would fetch. An estimate is not a price and none of
-- them is stored as one - see the gear.cost comment in db/schema.sql.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('semper-fi-apa-15', '"Semper Fi" APA-15 Amphibious Assault Power Armor', 'rifts', 'Sea-Air-Land Tactical Assault Exoskeleton', 'One.', NULL, 'Running 60 mph (96 km) maximum; leaps up to 12 feet (3.65 m).', 'Not possible.', '40 mph (64 km/34 knots), submerged or semi-submerged.', 'Height 8 feet (2.4 m), width 4 feet (1.2 m), length 3 feet (0.9 m). Physical strength equal to a P.S. of 30.', '450 lbs (202.5 kg)', 300, 2500000, '2.5 million credits new. Never traded or sold to outsiders - though Tritonia is not counted as an outsider.', 'The Marine assault suit, equally at home running ashore or swimming on its back-mounted thruster. It is the armour the Marine O.C.C. is trained on, and the APA-15 its Power Armor Combat: Elite names.', 'Rifts World Book 7: Underseas p.118-119'),
('merovingian-amphibious-tank', 'Merovingian Amphibious Tank', 'rifts', 'Amphibious Main Battle Tank', 'Three - commander and main gunner, secondary gunner and loader, and pilot. One or two more can be squeezed in without seats.', NULL, '70 mph (112 km).', NULL, 'Floating on its turbine, 50 mph (80 km).', 'Height 20 feet (6.1 m), width 14 feet (4.3 m), length 32 feet (9.7 m).', '25 tons fully loaded.', 550, 40000000, '40 million credits new.', 'A French pre-Rifts design the US Marines adopted, made fully amphibious by balloon tyres and a water turbine. Its over-and-under laser and 200mm autocannon is the heaviest gun on any New Navy land vehicle, and Salvation Base builds it as its main production tank.', 'Rifts World Book 7: Underseas p.120-121'),
('iwo-jima-class-mifv', 'Iwo-Jima Class MIFV', 'rifts', 'Marine Infantry Fighting Vehicle (MIFV)/Troop Carrier', 'Three - pilot, gunner, and commander/gunner.', 'Ten soldiers, or six in power armour.', 'Hovering, 100 mph (160 km) maximum, to a hover height of 20 feet (6.1 m).', 'Not possible.', 'It can hover above water but cannot be launched underwater. If sunk its maximum depth is printed as "500 feet (15 m)", where the two figures disagree.', 'Height 12 feet (3.65 m), width 10 feet (3.0 m), length 25 feet (7.6 m).', '20 tons fully loaded.', 225, 40000000, '40 million credits new. Around 300 have been sold to outside groups, mostly away from the Pacific.', 'The hovercraft that puts a ten-man Marine squad ashore, or six in power armour. Six firing ports let the embarked infantry shoot from cover at -2 to strike.', 'Rifts World Book 7: Underseas p.121-122'),
('s-14-sea-hawk', 'S-14 Sea Hawk VTOL Jet Fighter', 'rifts', 'Fighter Jet', 'One.', 'Seats for two more - a bombardier and communications engineer, or passengers.', '10 mph (16 km), for conventional take-off, landing and parking only.', 'Maximum Mach 3.2 (2144 mph/3450 km), ceiling 63,000 feet (19,200 m). Minimum glide speed 60 mph (96 km) or it may stall. Cruise from 250 mph (400 km) to Mach One.', NULL, 'Height 12 feet (3.65 m) with the gear down or 9 feet (2.7 m) retracted; wingspan 45 feet (13.7 m); length 65 feet (19.8 m).', '16 tons empty, 20 tons loaded.', 210, NULL, 'NO PRICE. The book prints "Not available" - it is New Navy only and never sold - and estimates 50 to 80 million credits on the open market, plus 30 million more for the S-16S stealth version. An estimate rather than a price, so nothing is stored.', 'A pre-Rifts VTOL supersonic jet that launches from the Ticonderoga deck or any forty foot clearing. Its whole cockpit module ejects as a flotation-capable survival pod. The S-16S stealth variant trades top speed for radar invisibility and swaps the belly gun for a sensor cluster.', 'Rifts World Book 7: Underseas p.122-124'),
('striker-attack-helicopter', 'Striker Attack Helicopter', 'rifts', 'Helicopter Gunship', 'Four - pilot, co-pilot and gunner, communications technician, and secondary gunner. Two more can be squeezed in.', 'Six troops in body armour, or four in power armour.', 'Not possible.', 'Hover and VTOL; maximum 300 mph (480 km), cruising and attacking at 100 to 200 mph, ceiling 20,000 feet (6096 m), combat height 3000 feet (914 m).', 'No speed given; it lands on water on pontoon runners.', 'Height 15 feet (4.6 m); body width 10 feet (3.0 m) with a 17 foot 2 inch (5.23 m) wingspan and a 50 foot (15.2 m) main rotor; length 55 feet (16.8 m).', '10 tons fully loaded.', 275, NULL, 'NO PRICE. The book prints "Not available", New Navy only, and estimates about 30 million credits nuclear or 2.4 million for the liquid-fuel version. An estimate rather than a price.', 'The gunship workhorse - reconnaissance, insertion and extraction, and anti-ship and anti-submarine attack, with pontoons for water landings. It carries six troops or four power-armour Marines and can drop them in mid-flight. Losing the tail rotor or a main blade cripples its handling.', 'Rifts World Book 7: Underseas p.124-126'),
('manta-ray-attack-ship', 'Manta Ray Multi-Environment Attack Ship', 'rifts', 'Multi-Environment Attack Ship', 'One pilot.', NULL, 'Not possible, though it hovers as low as 10 feet (3 m).', 'Mach 1.5 (1005 mph/1617 kmph) maximum, cruising about 300 mph (482 km).', 'Surface up to 300 mph (482 km) hydrofoil-style; underwater 50 knots (92.5 km/58 mph). It must slow to about 250 mph (400 km) to dive. Maximum depth two miles (3.2 km).', 'Height 7 feet (2.1 m), or 10 feet (3.0 m) with the gear down; width 20 feet (6.1 m); length 20 feet (6.1 m).', '5 tons', 250, NULL, 'NO PRICE. The book prints "Not for sale" and says it would fetch up to 90 million credits on the black market. A valuation rather than a price.', 'A fighter and mini-submarine in one - an air-sub that switches between flight and underwater running on vectored thrust, working as scout and striker for the big submersible carriers. Its ion guns sit nearly flush with the hull and can only be hit on a called shot at -8.', 'Rifts World Book 7: Underseas p.126-127'),
('trident-submersible-carrier', 'Trident Submersible Carrier', 'rifts', 'Light Submersible Carrier', '24, including officers.', '60 - twenty Manta Ray pilots and forty Marines.', 'Not possible.', 'Not possible.', 'Surface 60 knots (111.3 km/69.6 mph); underwater 40 knots (73.6 km/46 mph). It can stay submerged 24 months, to a maximum depth of 2.5 miles (4 km).', 'Height 40 feet (12.2 m), width 40 feet (12.2 m), length 380 feet (115.8 m).', '8,200 tons', 1500, NULL, 'NO PRICE. The book prints "Not for sale" and says hundreds of millions on the open market.', 'The small, factory-producible carrier: it fires its Manta Rays out of launch tubes four at a time rather than flying them off a deck. The book proposes it as a campaign centrepiece in its own right, carrying scaled-down versions of the Ticonderoga armament.', 'Rifts World Book 7: Underseas p.127-128'),
('ticonderoga-submersible-carrier', 'The Ticonderoga Submersible Carrier', 'rifts', 'Submersible Air-Sea-Land Carrier', '3,200, or 10,520 with troops. The surrounding narrative separately gives the total complement as 11,520; both figures are as printed.', '7,320 troops, with room for 2,000 more before conditions get cramped: an armoured battalion, two mechanised infantry battalions, two Marine infantry brigades, four air wings and a medical company.', 'Not possible.', 'Not possible.', 'Surface 50 knots (92.5 km/58 mph); underwater 30 knots (54 km/34.5 mph).', 'Height 200 feet (61 m), width 400 feet (122 m), length 2000 feet (610 m).', '200,000 tons fully loaded.', 20000, NULL, 'NO PRICE, and the book gives none: it says only that Atlantis, the Coalition States or Triax would pay billions for it captured intact. A ransom, not a market price.', 'The New Navy capital ship - a nuclear submersible super-carrier that fights as a submarine, flies conventional and VTOL aircraft off a top deck, and lands armour and Marines ashore. Captain Nemo-2 has commanded it for over two centuries. Two escort attack submarines dock to its hull to hide from sonar.', 'Rifts World Book 7: Underseas p.128-132'),
('uss-stingray-seadragon', 'USS Stingray & Seadragon Attack Submarines', 'rifts', 'Attack Submarine', '100 - sixty crew and forty Marines. Twelve can pilot her at a basic level, at -20% on piloting and -2 on initiative. Twenty more can be squeezed aboard in an emergency.', NULL, 'Not possible.', 'Not possible.', 'Surface 25 knots (29 mph/47 kmph); underwater 45 knots (52 mph/84 kmph).', 'Height 40 feet (12.2 m), width 30 feet (9.1 m), length 360 feet (109.7 m).', '4,500 tons', 3200, NULL, 'NO PRICE. The Market Cost line other vessels carry is simply absent here; the block runs from the power system straight into the weapon systems.', 'The pair of fleet submarines that dock to the Ticonderoga flanks to hide from sonar, then release when she is attacked and abruptly triple the apparent number of enemy submarines. Each carries a Marine platoon in Semper Fi power armour who double as crew and boarding party.', 'Rifts World Book 7: Underseas p.132-133');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('semper-fi-apa-15', 'Head', 90, NULL, 1),
('semper-fi-apa-15', 'Arms (2)', 100, 'Each.', 2),
('semper-fi-apa-15', 'Legs (2)', 120, 'Each.', 3),
('semper-fi-apa-15', 'MWAS "Rifle"', 80, NULL, 4),
('semper-fi-apa-15', 'Thruster System (back)', 80, NULL, 5),
('semper-fi-apa-15', 'Main Body', 300, NULL, 6),
('merovingian-amphibious-tank', 'Turret', 250, NULL, 1),
('merovingian-amphibious-tank', 'Over-and-Under Cannon', 200, 'Combined.', 2),
('merovingian-amphibious-tank', 'Heavy Missile Launcher (turret, left)', 100, NULL, 3),
('merovingian-amphibious-tank', 'Mini-Missile Launchers (2, sides)', 40, 'Each.', 4),
('merovingian-amphibious-tank', 'Laser Machinegun (cupola)', 75, NULL, 5),
('merovingian-amphibious-tank', 'Laser Gun (main body)', 60, NULL, 6),
('merovingian-amphibious-tank', 'Main Body', 550, NULL, 7),
('merovingian-amphibious-tank', 'Balloon Tires (6)', 75, 'Each.', 8),
('iwo-jima-class-mifv', 'Weapon Turret', 180, NULL, 1),
('iwo-jima-class-mifv', 'Ion Pulse Cannon in Turret', 100, NULL, 2),
('iwo-jima-class-mifv', 'Heavy Missile Launchers (2)', 100, 'Each.', 3),
('iwo-jima-class-mifv', 'Light Missile Launcher (1)', 70, NULL, 4),
('iwo-jima-class-mifv', 'Light Ion Gun (1)', 45, NULL, 5),
('iwo-jima-class-mifv', 'Main Body', 225, NULL, 6),
('s-14-sea-hawk', 'Forward Mounted Laser Guns (2, nose)', 40, 'Each.', 1),
('s-14-sea-hawk', 'Retractable Belly Gun (1)', 60, NULL, 2),
('s-14-sea-hawk', 'Wing Mounted Long-Range Missiles (4)', 50, 'Each. THE BOOK DISAGREES WITH ITSELF: this list says four, and the weapon-system text says six, three per wing.', 3),
('s-14-sea-hawk', 'Wing Mounted Mini-Missile Launchers (2)', 60, 'Each.', 4),
('s-14-sea-hawk', 'Bomb Bay (1, hatch)', 60, NULL, 5),
('s-14-sea-hawk', 'Large Wings (2)', 125, 'Each.', 6),
('s-14-sea-hawk', 'Small Forward Wings (2)', 90, 'Each.', 7),
('s-14-sea-hawk', 'Main Body', 210, NULL, 8),
('s-14-sea-hawk', 'Reinforced Pilot''s Compartment', 90, NULL, 9),
('s-14-sea-hawk', 'Pilot''s Seat (1)', 2, NULL, 10),
('striker-attack-helicopter', 'Four-Blade Top Rotor', 92, '23 per blade.', 1),
('striker-attack-helicopter', 'Rear Rotor', 75, NULL, 2),
('striker-attack-helicopter', 'Mini-Missile Launchers (2, wings)', 100, 'Each.', 3),
('striker-attack-helicopter', 'Medium-Range Missile Launchers (4)', 50, 'Each.', 4),
('striker-attack-helicopter', 'Belly Gun (1)', 65, NULL, 5),
('striker-attack-helicopter', 'Nose Lasers (2)', 35, NULL, 6),
('striker-attack-helicopter', 'Pontoon Runners (2)', 90, 'Each.', 7),
('striker-attack-helicopter', 'Main Body', 275, NULL, 8),
('striker-attack-helicopter', 'Reinforced Pilots'' Compartment', 110, NULL, 9),
('manta-ray-attack-ship', 'Missile/Torpedo Pod', 120, NULL, 1),
('manta-ray-attack-ship', 'Pilot''s Compartment', 100, NULL, 2),
('manta-ray-attack-ship', 'Ion Pulse Guns (2)', 30, 'Each. They are -8 to strike, on a called shot only, and cannot be hit at all near Mach One.', 3),
('manta-ray-attack-ship', 'Main Body', 250, NULL, 4),
('trident-submersible-carrier', 'Ion Pulse Cannons (2, forward third)', 400, 'Each.', 1),
('trident-submersible-carrier', 'Laser Cannons (2)', 200, 'Each.', 2),
('trident-submersible-carrier', 'Torpedo Tubes (6; four front, two rear)', 100, 'Each.', 3),
('trident-submersible-carrier', 'Long-Range Missile Launchers (4)', 150, 'Each.', 4),
('trident-submersible-carrier', 'Cruise Missile Launchers (4)', 200, 'Each.', 5),
('trident-submersible-carrier', 'Depth Charge Launchers (2, rear)', 90, 'Each.', 6),
('trident-submersible-carrier', 'Bridge', 800, NULL, 7),
('trident-submersible-carrier', 'Forward Third / Launch Section', 1000, NULL, 8),
('trident-submersible-carrier', 'Main Body (rear two thirds)', 1500, NULL, 9),
('ticonderoga-submersible-carrier', 'Laser CIWS Turrets (6)', 150, 'Each.', 1),
('ticonderoga-submersible-carrier', 'Torpedo Tubes (6)', 800, 'Each.', 2),
('ticonderoga-submersible-carrier', 'Ion Pulse Cannons (2, nose)', 500, 'Each.', 3),
('ticonderoga-submersible-carrier', 'Cruise Missile Turrets (8)', 600, 'Each.', 4),
('ticonderoga-submersible-carrier', 'Counter-Missile Batteries (4)', 400, 'Each.', 5),
('ticonderoga-submersible-carrier', 'Depth Charge Launchers (4)', 50, 'Each.', 6),
('ticonderoga-submersible-carrier', 'Hull, per 40 foot (12.2 m) area', 80, NULL, 7),
('ticonderoga-submersible-carrier', 'Flight Deck', 8000, NULL, 8),
('ticonderoga-submersible-carrier', 'Bridge', 1800, NULL, 9),
('ticonderoga-submersible-carrier', 'Main Sensors and Communication Tower', 480, NULL, 10),
('ticonderoga-submersible-carrier', 'Secondary Sensor/Comm Arrays (3)', 210, 'Each.', 11),
('ticonderoga-submersible-carrier', 'Main Body', 20000, NULL, 12),
('uss-stingray-seadragon', 'Ion Pulse Cannon (1, nose)', 100, NULL, 1),
('uss-stingray-seadragon', 'Torpedo Tubes (2, forward)', 100, 'Each.', 2),
('uss-stingray-seadragon', 'Mini-Torpedo Tubes (6)', 60, 'Each.', 3),
('uss-stingray-seadragon', 'Retractable Missile Launcher (1, deck)', 120, NULL, 4),
('uss-stingray-seadragon', 'Deck Laser (1)', 90, NULL, 5),
('uss-stingray-seadragon', 'Blue-Green Lasers (6)', 50, 'Each.', 6),
('uss-stingray-seadragon', 'Tail Section (1)', 1250, NULL, 7),
('uss-stingray-seadragon', 'Main Body', 3200, NULL, 8);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('semper-fi-apa-15', 1, 'Wrist Ion-Gun', '4D6 M.D. per burst.', 1, '2000 feet (610 m)', 'The pilot''s combined hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('semper-fi-apa-15', 2, 'Mini-Missile Launchers (2)', 'Typically plasma or heat, 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One, or volleys of two, four or six.', '6 total, three per shoulder launcher.', NULL, NULL),
('semper-fi-apa-15', 3, 'M-90 Multi-Weapon Assault System', 'Ion pulse 1D6x10+10 M.D. per burst; LAWS varies by grenade or torpedo; vibro-bayonet 4D6 M.D.', 1, '4000 feet (1220 m) for the gun and LAWS; the bayonet is close combat only.', 'Each mode is one melee action.', 'The gun is effectively unlimited on its cable; the LAWS drum holds 12 rounds.', NULL, NULL),
('semper-fi-apa-15', 4, 'Hand to Hand Combat', 'Punch or kick 1D6 M.D.; power punch 2D6 M.D. counting as two attacks.', 1, 'Melee.', NULL, NULL, NULL, 'The book numbers the pilot own attacks as a weapon system.'),
('merovingian-amphibious-tank', 1, 'Over-and-Under Laser & Cannon', 'Laser 2D6x10+10 M.D. per blast. The 200mm autocannon varies by round: high explosive 2D6x10 M.D. to a 50 foot (15.2 m) blast, armour-piercing or HEAT 3D6x10 M.D. to 12 feet (3.65 m), and A.P. sabot 2D6x10 M.D. with no blast.', 1, '6000 feet (1830 m) direct. High explosive can be fired indirect to five miles (8 km) with a forward observer, at -4 to strike beyond 6000 feet.', 'Each barrel twice per round, four attacks in all, capped by the gunner hand to hand attacks.', 'The laser is unlimited; the cannon holds 60 rounds in any mix.', NULL, NULL),
('merovingian-amphibious-tank', 2, 'Heavy Missile Launcher (1)', 'Varies by missile.', 1, 'Varies by missile.', 'One, or volleys of one, two or four.', '4 long-range missiles.', NULL, NULL),
('merovingian-amphibious-tank', 3, 'Mini-Missile Launchers (2)', 'Varies. Usually fragmentation, which the book prints as "SD6 M.D." - almost certainly 5D6 - or plasma at 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One, or volleys of two, four or eight.', '32 total, 16 per launcher.', NULL, 'The fragmentation damage is printed as SD6, which is not a die. Transcribed as printed rather than corrected to 5D6.'),
('merovingian-amphibious-tank', 4, 'Laser Machinegun (1)', '5D6 M.D. per blast.', 1, '2000 feet (610 m)', 'The gunner''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('merovingian-amphibious-tank', 5, 'Bow-Mounted Laser Gun (1)', '1D4x10 M.D. per blast.', 1, '4000 feet (1220 m)', 'The pilot or gunner hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('iwo-jima-class-mifv', 1, 'Ion Pulse Cannon', '3D4x10 M.D. per blast.', 1, '6000 feet (1830 m)', 'Four times per melee.', 'Effectively unlimited.', NULL, NULL),
('iwo-jima-class-mifv', 2, 'Heavy Missile Launchers (2)', 'Varies - long or medium range.', 1, 'Varies.', 'One, or volleys of one, two, four or eight.', '8 total, four per launcher.', NULL, NULL),
('iwo-jima-class-mifv', 3, 'Light Missile Launcher (1)', 'Varies - short range.', 1, 'Varies.', 'One, or volleys of one, two or four.', '4', NULL, NULL),
('iwo-jima-class-mifv', 4, 'Light Pulse Gun', '1D6x10 M.D. on a multiple ion burst; it fires bursts only.', 1, '4000 feet (1220 m)', 'The pilot or gunner hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('s-14-sea-hawk', 1, 'Wing Mounted Long-Range Missiles (6)', 'Varies, typically cruise missiles.', 1, 'Varies.', 'One, or volleys of two.', '6 total, three per wing. The M.D.C. list says four launchers where this says six.', NULL, NULL),
('s-14-sea-hawk', 2, 'Mini-Missile Launchers (2)', 'Varies.', 1, 'About one mile (1.6 km)', 'Total hand to hand attacks; one, or volleys of two or four.', '48 total, 24 per launcher.', NULL, NULL),
('s-14-sea-hawk', 3, 'Concealed Bomb Bay', 'A bomb does 2D4x10 M.D. to a 100 foot (30.5 m) radius. A depth charge does 2D4x10 M.D. to 100 feet plus 4D6 M.D. to a further 30 feet (9 m) underwater, or an 80 foot (24.4 m) radius on land.', 1, 'About one mile (1.6 km)', 'One, or clusters of two or four.', '48 total, and it reloads automatically.', NULL, NULL),
('s-14-sea-hawk', 4, 'Forward Mounted Lasers (2)', '5D6 M.D. single, 1D6x10 M.D. dual.', 1, '4000 feet (1220 m)', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('s-14-sea-hawk', 5, 'Retractable Belly Gun (1)', '4D6 M.D. It cannot fire bursts.', 1, '2000 feet (610 m)', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('s-14-sea-hawk', 6, 'Combat Systems & Bonuses', NULL, 0, NULL, NULL, NULL, '+1 on initiative, +1 to strike with the nose guns, +3 to dodge, +5% on piloting for aerial manoeuvres.', 'Not a weapon; the book numbers it among the weapon systems.'),
('striker-attack-helicopter', 1, 'Medium-Range Missile Launchers (4)', 'Varies, often cruise missiles.', 1, 'About 50 miles (80 km)', 'One, or volleys of two or four.', '16 total, four per launcher.', NULL, NULL),
('striker-attack-helicopter', 2, 'Mini-Missile Launchers (2)', 'Varies.', 1, 'About one mile (1.6 km)', 'One, or volleys of two, three, five, ten or twenty-four.', '48 total, 24 per launcher.', NULL, NULL),
('striker-attack-helicopter', 3, 'Forward Mounted Lasers (2)', '4D6 M.D. single, 1D4x10+8 M.D. dual.', 1, '3000 feet (910 m)', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('striker-attack-helicopter', 4, 'Belly Gun (1)', '3D6 M.D. single, 6D6 M.D. on a double pulse.', 1, '3000 feet (914 m)', 'The gunner''s hand to hand attacks.', 'Effectively unlimited.', '-1 to strike on a double pulse.', NULL),
('striker-attack-helicopter', 5, 'Troops', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon; the book numbers it. Six troops in body armour or four in power armour, who can disembark in mid-air.'),
('striker-attack-helicopter', 6, 'Depth Charges', NULL, 1, NULL, NULL, '10 can be stowed.', '-2 to strike.', 'Pushed out by two crew rather than launched.'),
('striker-attack-helicopter', 7, 'Features of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Doppler radar for tracking storms and position, a winch and hook rated to 700 lbs (315 kg), and standard aircraft sensors.'),
('manta-ray-attack-ship', 1, 'Ion Pulse Guns (2)', '1D6x10 M.D. single burst, 2D6x10 M.D. double burst counting as one melee attack.', 1, '4000 feet (1220 m)', 'The pilot''s combined hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('manta-ray-attack-ship', 2, 'Missile Pods', 'Varies - short, medium or long range missiles, torpedoes, or a cruise missile.', 1, 'Varies.', 'One, a volley of two, or the full payload.', 'Up to 16 short range, 8 medium, 6 long range, or one cruise missile, or the torpedo equivalents and combinations.', NULL, NULL),
('manta-ray-attack-ship', 3, 'Stealth System', NULL, 0, NULL, NULL, NULL, '-15% on sensor rolls against it, and -15% on sonar rolls underwater.', 'Radar-absorbent above water and sonar-absorbent below.'),
('manta-ray-attack-ship', 4, 'Laser Communication and Targeting System', '2D6 M.D. if fired as a weapon.', 1, '50 miles (80 km) for communication; 2000 feet (610 m) as a weapon.', NULL, NULL, '+2 to strike with either weapon system, +1 on initiative, +2 to dodge - none of it against an underwater target beyond 1000 feet (305 m).', NULL),
('trident-submersible-carrier', 1, 'Ion Pulse Cannons (2)', '4D6x10 M.D. per blast. The two cannot engage the same target simultaneously.', 1, 'Two miles (3.2 km)', 'Two shots each per melee.', 'Effectively unlimited.', NULL, NULL),
('trident-submersible-carrier', 2, 'Laser Cannons (2)', '2D4x10 M.D. per blast.', 1, 'Two miles (3.2 km)', 'Four shots each per melee.', 'Effectively unlimited.', NULL, NULL),
('trident-submersible-carrier', 3, 'Torpedo Tubes (6)', '1D4x100 M.D. super-heavy down to 1D6x10 M.D. light.', 1, 'One to twenty miles (1.6 to 32 km)', 'Up to four per melee.', '132 total - 12 super-heavy, 20 heavy, 40 medium, 60 light.', NULL, NULL),
('trident-submersible-carrier', 4, 'Long-Range Missile Launchers (4)', 'Varies.', 1, 'Varies.', 'One, or volleys of two, four or eight per launcher, to 32 in all.', '128, and another 128 in storage.', NULL, NULL),
('trident-submersible-carrier', 5, 'Cruise Missile Launchers (4)', '2D6x100 M.D. to the target and 2D6x10 M.D. to a 100 foot (30.5 m) area. Each missile has 50 M.D.C. of its own.', 1, '1000 miles (1600 km)', 'One per launcher, to a maximum volley of four.', '8 total, two per launcher, with no reloads.', '+5 to strike.', NULL),
('trident-submersible-carrier', 6, 'Depth Charge Launchers (2)', '2D4x10 M.D.', 1, 'Two miles (3.2 km) of depth.', 'One, or volleys of two, up to three times per melee.', '80 total, 40 per launcher.', NULL, NULL),
('trident-submersible-carrier', 7, 'Sensor Systems of Note', NULL, 0, '500 miles (800 km) for both radar and sonar.', NULL, NULL, NULL, 'Not a weapon. Enhanced radar tracking 96 targets at once, sonar, a sound pulse system, long-range communications, independent weapon targeting and life-support monitoring, plus sea sleds, diving gear, a sick bay and a brig.'),
('ticonderoga-submersible-carrier', 1, 'Ion Pulse Cannons (2)', '1D4x100 M.D. per blast, or 2D4x100 M.D. if both engage the same target.', 1, 'Four miles (6.4 km)', 'Two shots per cannon.', 'Effectively unlimited.', NULL, NULL),
('ticonderoga-submersible-carrier', 2, 'Laser CIWS Turrets (6)', '1D4x10 M.D.', 1, 'NOT PRINTED - the page carrying it is missing from the scan.', 'Six attacks per turret per melee round.', 'NOT PRINTED - the page carrying it is missing from the scan.', '+3 to strike missiles, +2 to strike aircraft.', 'Close-in weapon systems firing rapid-pulse lasers at missiles and low-flying aircraft, tracking by radar. THIS IS THE LAST WEAPON SYSTEM THE SCAN CARRIES: printed 131 is absent from the source PDF, and its range and payload lines are on it.'),
('uss-stingray-seadragon', 1, 'Ion Pulse Cannon (1)', '2D4x10 M.D. per blast.', 1, 'One mile (1.6 km)', 'Two shots per melee.', 'Effectively unlimited.', NULL, NULL),
('uss-stingray-seadragon', 2, 'Heavy Torpedo/Missile Launch Tubes (2)', '4D6x10 M.D.', 1, 'Twenty miles (32 km) underwater.', 'One, or volleys of two or four.', '40 torpedoes in a shared internal magazine, routable to either tube.', NULL, 'The M.D.C. list calls these simply Torpedo Tubes; both names are the book.'),
('uss-stingray-seadragon', 3, 'Mini-Torpedo Launch Tubes (6; four forward, two rear)', '1D6x10 M.D., high explosive or plasma.', 1, 'One mile (1.6 km)', 'One, or volleys of two or four.', '360 total, 60 per tube.', NULL, NULL),
('uss-stingray-seadragon', 4, 'MRS-AML "Missus Amelee" Multi-Rocket Surface-to-Air Missile Launcher (1)', 'Medium-range missiles 3D6x10 M.D., or cruise missiles; mini-missiles 1D6x10 M.D.', 1, '50 miles (80 km) for a medium-range missile, one mile (1.6 km) for a mini.', 'One, or volleys of two or four.', '4 medium-range and 24 mini-missiles, with one reload of the same taking a full minute.', NULL, 'Retractable, and it can only be used on the surface.'),
('uss-stingray-seadragon', 5, 'Blue-Green Lasers (6; four forward, two tail)', '1D4x10 M.D. per blast. They cannot fire simultaneously.', 1, '4000 feet (1220 m)', 'The gunner''s hand to hand attacks, typically one gunner per laser.', 'Effectively unlimited.', NULL, NULL),
('uss-stingray-seadragon', 6, 'Double-Barrelled Deck Laser (1)', '5D6 M.D. single, 1D6x10 M.D. double - a simultaneous double is one melee action.', 1, '4000 feet (1220 m) surfaced, 1200 feet (366 m) underwater.', 'The gunner''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('uss-stingray-seadragon', 7, 'Complement', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon; the book numbers it. Typically forty Semper Fi power armour suits plus a dozen sea sleds, diving gear, wet suits, life rafts, a sick bay, a brig, and the sonar, radar, communications and life support common to the Ticonderoga.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is SILENT on a collision, which is exactly how a row goes missing without
-- an error, so these COUNT.
SELECT 'these vessels' AS assertion,
       count(*) AS got, 9 AS want
  FROM vehicles WHERE slug IN ('semper-fi-apa-15', 'merovingian-amphibious-tank', 'iwo-jima-class-mifv', 's-14-sea-hawk', 'striker-attack-helicopter', 'manta-ray-attack-ship', 'trident-submersible-carrier', 'ticonderoga-submersible-carrier', 'uss-stingray-seadragon');

SELECT 'their M.D.C. locations' AS assertion,
       count(*) AS got, 72 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('semper-fi-apa-15', 'merovingian-amphibious-tank', 'iwo-jima-class-mifv', 's-14-sea-hawk', 'striker-attack-helicopter', 'manta-ray-attack-ship', 'trident-submersible-carrier', 'ticonderoga-submersible-carrier', 'uss-stingray-seadragon');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 46 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('semper-fi-apa-15', 'merovingian-amphibious-tank', 'iwo-jima-class-mifv', 's-14-sea-hawk', 'striker-attack-helicopter', 'manta-ray-attack-ship', 'trident-submersible-carrier', 'ticonderoga-submersible-carrier', 'uss-stingray-seadragon');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT count(*) AS underseas_vessels FROM vehicles WHERE source_book LIKE '%Underseas%';
SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-vessels-p118-133.sql');
