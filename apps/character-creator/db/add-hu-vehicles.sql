-- Heroes Unlimited's conventional and military vehicles. Printed 221-225.
-- Forty-nine vehicles, fourteen location rows and twelve weapon systems.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-vehicles.sql
--
-- REQUIRES MIGRATION 062, which adds `vehicles.ar` and `vehicles.is_mega_damage`.
--
-- ===================================================================
-- EVERY ROW HERE IS S.D.C., NOT M.D.C.
-- ===================================================================
--
-- This is the first non-Rifts book in the vehicles table, and it does not deal
-- in mega-damage at all:
--
--   M-48A3 PATTON II (tank)
--   A.R.: 18, S.D.C.: Main body - 1000, main gun - 200, treads - 75 each.
--
-- One M.D.C. point absorbs a hundred S.D.C., so the unit is not a labelling
-- question. Every row sets `is_mega_damage = 0`, which is what says that the
-- number in `mdc_main_body` - and in this vehicle's `vehicle_locations` rows -
-- is S.D.C. Forty of the forty-nine also carry an `ar`; the five underwater
-- vehicles and the four helicopters are the nine that do not, because the book
-- prints none for them.
--
-- ===================================================================
-- WHAT THE BOOK DOES NOT PRICE
-- ===================================================================
--
-- Fourteen rows have a NULL cost and each is a finished row, not an unfinished
-- one - the convention `gear.cost` and `vehicles.cost` already share. The book
-- simply gives no figure for the three airplanes, the five underwater vehicles,
-- the four military transport vehicles, or the two prototypes on printed 223.
-- The military vehicles and helicopters that ARE priced carry a "Mercenary
-- Price", which is the phrase the book uses and which `cost_note` records.
--
-- ===================================================================
-- THREE THINGS ON THESE PAGES THAT LOOK LIKE SCAN DAMAGE AND ARE NOT
-- ===================================================================
--
-- 1. THE BOOK'S OWN METRIC CONVERSIONS ARE WRONG on printed 225. It prints the
--    jeep at "65mph (1000kmph)", the M-35 at "56mph (891kmph)" and the M-816 at
--    "52mph (830kmph)". Confirmed on a 245 dpi render: that is the page, not the
--    cache. The M-88's "31mph (49kmph)" is correct, which is what makes the
--    other three errors rather than a house style. The mph figure is stored and
--    each row says what the book printed beside it.
--
-- 2. `OH-6A CAYUSE ("LOACH") / A LIGHT OBSERVATION HELICOPTER` IS AN
--    ILLUSTRATION CAPTION, hand-lettered beside the drawing, with no statistics
--    under it. It is not an entry and there is no row for it. `A TYPICAL LIGHT
--    OBSERVATION HELICOPTER`, which reads like a caption and is not, IS an entry
--    with a full stat block, and does have one.
--
-- 3. THE OH-23 RAVEN HAS NO S.D.C. The other three helicopters print one - 250,
--    325 and 400 - and the Raven prints length, weight, payload, speed, range
--    and price with no S.D.C. between them. Checked on the render before the row
--    was written, so the NULL is the book's answer rather than a dropped line.
--
-- THE M-41A3 WALKER BULLDOG IS ON PRINTED 222, not 223. Its illustration and
-- caption are on 223 and its stat block is not, which is the kind of split that
-- puts a citation one page out.
--
-- ===================================================================
-- WHAT IS NOT HERE
-- ===================================================================
--
-- The helicopter armament systems on printed 224 and 226 - the M-5 40mm grenade
-- launcher, the XM-30, the M-21 coordinated system, the XM-134 mini-gun and the
-- rest. They are not vehicles, and `vehicle_weapons` cannot hold them either:
-- that table is keyed to one `vehicle_slug`, and the book's own framing is that
-- "virtually any of the following systems could be used on any helicopter".
-- They belong in `gear`, with the book's note that they can NOT be carried.
--
-- Printed 227 is helicopter stunts and flying rules, which is prose about
-- piloting rather than a vehicle or an item.
--
-- `vehicle_class` is 'vehicle' on all forty-nine, which is the normalised
-- vocabulary the README names; the book's own section heading opens each
-- description, which is the other half that same note asks for.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('compact', 'Compact', 'heroes-unlimited', 'vehicle', NULL, NULL, '110mph (176.9kmph)', NULL, NULL, NULL, NULL, 300, 0, 5, 6500, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 350 miles (563km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('mid-size', 'Mid-Size', 'heroes-unlimited', 'vehicle', NULL, NULL, '110mph (176.9kmph)', NULL, NULL, NULL, NULL, 350, 0, 6, 9500, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 300 miles (482km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('full-size-sedan', 'Full-Size Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 450, 0, 7, 15000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 250 miles (402km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('luxury-sedan', 'Luxury Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 450, 0, 7, 25000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. American and Japanese. Range: 250 miles (402km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('sports-car', 'Sports Car', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph unmodified, but can be suped to 180mph', NULL, NULL, NULL, NULL, 350, 0, 5, 20000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('corvette', 'Corvette', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph, unmodified', NULL, NULL, NULL, NULL, 300, 0, 5, 15000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 270 miles (434km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('mini-van', 'Mini Van', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 350, 0, 6, 15000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 350 miles (562km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('full-size-van', 'Full-Size Van', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 400, 0, 7, 9000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('jeep-4-wheel-drive', 'Jeep (4 wheel drive)', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 300, 0, 6, 12000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 400 miles.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('small-truck-4-wheel-drive', 'Small Truck (4 wheel drive)', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 350, 0, 6, 10000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 400 miles.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('small-truck', 'Small Truck', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 300, 0, 6, 8000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 300 miles (482km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('16ft-truck-u-haul-type', '16ft Truck (U-Haul type)', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 400, 0, 7, 20000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 200 miles.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('24ft-truck-u-haul-type', '24ft Truck (U-Haul Type)', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 500, 0, 8, 50000, 'and up', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 190 miles (305km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('semi-truck-cab-only', 'Semi-Truck (Cab only)', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 600, 0, 10, 90000, '$90,000 and up for the cab; add another $90,000 for the cargo bed (trailer)', 'TYPICAL CONSUMER AUTOMOBILES, printed 221. Range: 150 miles (241km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('bmw-sedan', 'BMW Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '140mph (225kmph)', NULL, NULL, NULL, NULL, 350, 0, 6, 80000, '$80,000 to $150,000', 'FOREIGN AND SPORTS CARS, printed 221. German. Range: 250 miles (402km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('bmw-sports-car', 'BMW Sports Car', 'heroes-unlimited', 'vehicle', NULL, NULL, '180mph (290kmph)', NULL, NULL, NULL, NULL, 325, 0, 5, 90000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. German. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('delorean', 'Delorean', 'heroes-unlimited', 'vehicle', NULL, NULL, '140mph (225kmph)', NULL, NULL, NULL, NULL, 325, 0, 6, 60000, NULL, 'FOREIGN AND SPORTS CARS, printed 221. Irish, as the book has it. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('jaguar', 'Jaguar', 'heroes-unlimited', 'vehicle', NULL, NULL, '180mph (290kmph)', NULL, NULL, NULL, NULL, 300, 0, 5, 80000, NULL, 'FOREIGN AND SPORTS CARS, printed 221. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('lamborghini-countach', 'Lamborghini Countach', 'heroes-unlimited', 'vehicle', NULL, NULL, '200mph+ (321kmph)', NULL, NULL, NULL, NULL, 350, 0, 5, 150000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. Italy. Range: 220 miles (355km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('mercedes-benz-sedan', 'Mercedes Benz Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '140mph (225kmph)', NULL, NULL, NULL, NULL, 350, 0, 6, 90000, '$90,000 to $150,000 and up', 'FOREIGN AND SPORTS CARS, printed 221. German. Range: 250 miles (402km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('mercedes-benz-sports-car', 'Mercedes Benz Sports Car', 'heroes-unlimited', 'vehicle', NULL, NULL, '200mph+ (321kmph)', NULL, NULL, NULL, NULL, 300, 0, 6, 100000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. German. Range: 220 miles (355km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('porsche', 'Porsche', 'heroes-unlimited', 'vehicle', NULL, NULL, '200mph+ (321kmph)', NULL, NULL, NULL, NULL, 300, 0, 5, 65000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. The book says Italy, which is wrong - Porsche is German - and it is printed that way. Range: 200 miles (321km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('rolls-royce-luxury-sedan', 'Rolls Royce Luxury Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 450, 0, 6, 100000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. Great Britain. Range: 190 miles (305km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('volvo-sedan', 'Volvo Sedan', 'heroes-unlimited', 'vehicle', NULL, NULL, '140mph (225kmph)', NULL, NULL, NULL, NULL, 300, 0, 5, 45000, 'and up', 'FOREIGN AND SPORTS CARS, printed 221. Range: 250 miles (402km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('motorcycle-light', 'Motorcycle - Light', 'heroes-unlimited', 'vehicle', NULL, NULL, '90mph (144kmph)', NULL, NULL, NULL, NULL, 50, 0, 5, 500, 'and up', 'MOTORCYCLES, printed 221. Range: 120 miles (193km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('motorcycle-medium', 'Motorcycle - Medium', 'heroes-unlimited', 'vehicle', NULL, NULL, '110mph (176kmph)', NULL, NULL, NULL, NULL, 100, 0, 5, 1800, '$1,800 to $2,500', 'MOTORCYCLES, printed 221. Range: 350 miles (562km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('motorcycle-heavy', 'Motorcycle - Heavy', 'heroes-unlimited', 'vehicle', NULL, NULL, '120mph (193kmph)', NULL, NULL, NULL, NULL, 150, 0, 5, 5500, '$5,500 to $10,000', 'MOTORCYCLES, printed 221. Range: 350 miles (562km).', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('single-engine', 'Single Engine', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '300mph (482kmph)', NULL, NULL, NULL, 400, 0, 4, NULL, NULL, 'AIRPLANES, printed 222. The book prints no price for any of the three. Range: 680 miles (1040km).', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('twin-engine', 'Twin Engine', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '420mph (670kmph)', NULL, NULL, NULL, 550, 0, 5, NULL, NULL, 'AIRPLANES, printed 222. The book prints no price for any of the three. Range: 600 miles (964km).', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('small-jet', 'Small Jet', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '600mph (960kmph)', NULL, NULL, NULL, 850, 0, 5, NULL, NULL, 'AIRPLANES, printed 222. The book prints no price for any of the three. Range: 1370 miles (2205km).', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('s-c-u-b-a-scooter', 'S.C.U.B.A. Scooter', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, NULL, '3 knots', 'Length 3ft 1in (0.94m), width 1ft 5in (0.32m), height 10 inches (0.25m)', '57lbs (26kg) dry, 5oz (0.23kg) submerged', 50, 0, NULL, NULL, NULL, 'UNDERWATER VEHICLES, printed 222. The book prints no price for any of the five. Capable of pulling one to three divers; the handles are designed to pull them with minimum stress on the arm muscles. Cylindrical in shape with a front mounted rotor. Maximum depth 300ft. Range 3 nautical miles. Can function on the water''s surface or submerged.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('s-c-u-b-a-scooter-platform', 'S.C.U.B.A. Scooter Platform', 'heroes-unlimited', 'vehicle', NULL, 'One pilot, and can pull up to four more divers', NULL, NULL, '5 knots', 'Length 9ft 3in (2.8m), 4ft (1.2m) from side fin tip to fin tip', '270lbs dry, 18lbs submerged', 120, 0, NULL, NULL, NULL, 'UNDERWATER VEHICLES, printed 222. The book prints no price for any of the five. A larger, more stable version of the little scooter that a diver can lie on top of to ride. Its basic purpose is to carry S.C.U.B.A. divers and their equipment into the sea and return them safely; it also serves as a precisely controlled stable platform for underwater photography. Maximum depth 1970ft (600m). Range 15 nautical miles. Cargo capacity 1000lbs (450kg).', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('sea-sled-cav', 'Sea Sled (CAV)', 'heroes-unlimited', 'vehicle', '2', NULL, NULL, NULL, '3 knots', 'Length 27ft (8.23m); cargo bed 11 x 4.5 x 1.5ft (3.35 x 1.37 x 0.46m)', NULL, 270, 0, NULL, NULL, NULL, 'UNDERWATER VEHICLES, printed 222. The book prints no price for any of the five. CAV is Construction Assistance Vehicle. An underwater pickup truck capable of delivering up to 2000lbs (910kg) of wet weight cargo, with a two-seat cockpit and an open cargo bed in the rear. Maximum depth 150ft (45.7m). Range 15 miles (24km). Life support is 5 compressed air bottles, a 2 hour air supply. Can function on the surface or submerged.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('waterdinger', 'Waterdinger', 'heroes-unlimited', 'vehicle', NULL, 'Two S.C.U.B.A. divers and equipment', NULL, NULL, '2 knots', 'Length 7ft (2.1m)', NULL, 150, 0, NULL, NULL, NULL, 'UNDERWATER VEHICLES, printed 222. The book prints no price for any of the five. A small diver assist vehicle. Maximum depth 300ft (91m). Range 4 nautical miles. Cargo capacity 750lbs dry (340kg).', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('two-diver-submersible-transport-vehicle', 'Two Diver Submersible Transport Vehicle', 'heroes-unlimited', 'vehicle', '2', NULL, NULL, NULL, '1.5 to 9 knots', 'Length 12 to 16ft (3.6m to 4.9m)', NULL, 550, 0, NULL, NULL, NULL, 'UNDERWATER VEHICLES, printed 222. The book prints no price for any of the five. A variety of two-man research submersibles with similar capabilities. Maximum depth 2000ft (610m). SPEED AND RANGE TRADE AGAINST EACH OTHER: at 1.5 knots the range is 100 miles, at 6 knots about 45 miles (72km), and at 9 knots 10 miles (16km). Life support endurance 18 hours plus 6 hours emergency.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('m-113-personnel-carrier', 'M-113 Personnel Carrier', 'heroes-unlimited', 'vehicle', '1', '11 troops, one of whom would act as gunner', '42mph (67kmph)', NULL, NULL, 'Length 191.5 inches', '24,238lbs (10,900kg)', 600, 0, 14, 75000, 'Mercenary price', 'MILITARY VEHICLES, printed 222. Armour: stops pistol, rifle, machinegun and fragments; the underside is vulnerable to mines and the side walls can be easily penetrated by antitank rockets. Attacks per melee: three. The book notes the soldiers often rode on top because of the high temperature inside, and that the armour could be deadly to the occupants when it contained the effect of mines and shaped charges.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-113-personnel-carrier', 1, '.50 caliber machinegun', '7D6 per round', 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('m-551-sheridan-tank', 'M-551 Sheridan Tank', 'heroes-unlimited', 'vehicle', '4', NULL, '45mph (70kmph)', NULL, '3.5mph (5.8kmph)', 'Length 21ft (6.2m)', '35,100lbs (15,830kg)', 600, 0, 13, 550000, 'Mercenary price', 'MILITARY VEHICLES, printed 222. Armour: stops pistol, rifle, machinegun and fragments; the underside is vulnerable. Attacks per melee: four, any combination. Designed to be light enough to be air-portable, which the light armour paid for - the book calls it not particularly successful. Still in service in the U.S. and some U.S. military installations in Europe.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-551-sheridan-tank', 1, '152mm gun/launcher', '2D6 x 10 per blast', 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-551-sheridan-tank', 2, '7.62mm machinegun', NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-551-sheridan-tank', 3, '.50 caliber heavy machinegun', NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-551-sheridan-tank', 4, 'Smoke grenade launcher', NULL, 0, NULL, NULL, '8 rounds', NULL, NULL);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('m-41a3-walker-bulldog', 'M-41A3 Walker Bulldog', 'heroes-unlimited', 'vehicle', '4', NULL, '46mph (72kmph)', NULL, NULL, 'Length 27ft (8.2m)', '52,200lbs (23,495kg)', 800, 0, 14, 350000, 'Mercenary price', 'MILITARY VEHICLES, printed 222. A tank. Its illustration and caption sit over on printed 223, which is not where the entry is. Armour: stops pistol, rifle, machinegun and fragments, with a 40% chance of destruction from antitank rockets. Attacks per melee: three, any combination. Obsolete in U.S. forces but still used in many foreign countries, including Argentina, Brazil, Chile, Greece, Italy, Japan, Lebanon, New Zealand, Pakistan, South Africa, Taiwan, Thailand and Vietnam.', 'Revised Heroes Unlimited p.222');
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-41a3-walker-bulldog', 'Main Body', 800, NULL, 1);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-41a3-walker-bulldog', 'Tread', 75, 'each', 2);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-41a3-walker-bulldog', 'Cannon', 100, NULL, 3);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-41a3-walker-bulldog', 1, '76mm gun', '1D8 x 10 per blast', 0, NULL, NULL, '65 rounds', NULL, NULL);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-41a3-walker-bulldog', 2, '.50 caliber machinegun (2)', '7D6', 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('m-48a3-patton-ii', 'M-48A3 Patton II', 'heroes-unlimited', 'vehicle', '4', NULL, '30mph (48.2kmph)', NULL, NULL, 'Length 28ft (8.6m)', '104,820lbs (47,173kg)', 1000, 0, 18, 500000, 'Mercenary price', 'MILITARY VEHICLES, printed 223. A tank. Armour: stops pistol, rifle, machinegun and fragments and is highly resistant to mines and antitank rockets - the book gives it a 65% chance of surviving an encounter. Attacks per melee: four total, any combination. The main battle tank of the Vietnam war, reliable even under rough terrain conditions. Still used by the U.S., Bolivia, Chile, Iran, Israel, Pakistan, South Korea, Taiwan, Thailand, Turkey, West Germany and Vietnam, where over 340 were abandoned by U.S. forces.', 'Revised Heroes Unlimited p.223');
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-48a3-patton-ii', 'Main Body', 1000, NULL, 1);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-48a3-patton-ii', 'Main Gun', 200, NULL, 2);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('m-48a3-patton-ii', 'Tread', 75, 'each', 3);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-48a3-patton-ii', 1, '90mm gun', '2D4 x 10 per blast', 0, NULL, NULL, NULL, NULL, 'the primary piece');
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-48a3-patton-ii', 2, '.30 caliber machinegun', '5D6', 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('m-48a3-patton-ii', 3, '.50 caliber heavy machinegun', '7D6', 0, NULL, NULL, NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('an-average-high-tech-tank-prototype', 'An Average High-Tech Tank (Prototype)', 'heroes-unlimited', 'vehicle', '2, plus up to 3 passengers', NULL, '55mph on land', NULL, '5mph in water', 'Length 21ft (6.2m)', '43 tons', 600, 0, 15, NULL, NULL, 'MILITARY VEHICLES, printed 223. A prototype rather than a service vehicle, and the book prices it at nothing. Attacks per melee: five, any combination. Bonuses: full sensory capabilities - heat, infrared, nightvision and so on - to a range of 1600ft, and +2 to strike. The book adds that both the cannon and the laser can be fired four times per melee.', 'Revised Heroes Unlimited p.223');
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('an-average-high-tech-tank-prototype', 'Main Body', 600, NULL, 1);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('an-average-high-tech-tank-prototype', 'Turret', 110, NULL, 2);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('an-average-high-tech-tank-prototype', 'Main Cannon', 80, NULL, 3);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('an-average-high-tech-tank-prototype', 'Laser Gun', 50, NULL, 4);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('an-average-high-tech-tank-prototype', 'Tread', 75, 'each side', 5);
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('an-average-high-tech-tank-prototype', 1, 'High Speed Laser', '1D4 x 10 per blast', 0, '4000ft (1200m)', '4 per melee', NULL, NULL, 'mounted on top of the turret in place of the traditional machinegun');
INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage,
  is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES ('an-average-high-tech-tank-prototype', 2, 'Air Cooled 90mm Cannon', '2D4 x 10 per blast', 0, '6000ft (1600m)', '3 per melee', NULL, NULL, NULL);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('high-tech-armored-land-rover', 'High-Tech Armored Land Rover', 'heroes-unlimited', 'vehicle', 'One pilot and up to five passengers (3 comfortably)', NULL, '120mph (193kmph)', NULL, NULL, 'Length 24ft (7.3m)', '3.8 tons', 600, 0, 10, NULL, NULL, 'MILITARY VEHICLES, printed 223. A lightly armoured reconnaissance vehicle suitable for rough terrain - sturdy and open-air. Range 500 miles (804.50km). WEAPON SYSTEMS: NONE, which the book states rather than leaves out. Bonuses: none. Special equipment: a radio with a range of 50 miles (96.5km); high intensity headlights throwing a 50ft beam (15.2m); a loudspeaker amplifying the voice by 90 decibels; and a mini-radar with a range of 4 miles (6.4km) that is only 75% accurate and easily obscured by hills, mountains and forest. If all the S.D.C. of the main body is depleted the vehicle is destroyed.', 'Revised Heroes Unlimited p.223');
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('high-tech-armored-land-rover', 'Main Body', 600, NULL, 1);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('high-tech-armored-land-rover', 'Wheel', 50, 'each of six', 2);
INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES ('high-tech-armored-land-rover', 'Headlights', 10, NULL, 3);
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('25-ton-truck-utility-jeep', '.25 Ton Truck Utility Jeep', 'heroes-unlimited', 'vehicle', NULL, NULL, '65mph', NULL, NULL, 'Length 133 inches', '3,600lbs (1620kg)', 400, 0, 6, NULL, NULL, 'MILITARY TRANSPORT VEHICLES, printed 225. The book prints no price for any of the four. Cruising range 300 miles (482km). The classic and reliable jeep served as a great way to move small cargo and personnel in safe areas. THE BOOK''S METRIC CONVERSION IS WRONG: it prints 65mph as 1000kmph, where 65mph is about 105kmph. Three of the four transport vehicles on this page carry a bad conversion; the M-88''s 31mph/49kmph is the one that is right.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('2-5-ton-m-35-truck-cargo', '2.5 Ton M-35 Truck Cargo', 'heroes-unlimited', 'vehicle', NULL, NULL, '56mph', NULL, NULL, 'Length 264.5 inches', '13,425lbs (6030kg)', 500, 0, 7, NULL, NULL, 'MILITARY TRANSPORT VEHICLES, printed 225. The book prints no price for any of the four. Cruising range 350 miles (562km). Although rated for 2.5 tons (5,000lbs), up to twice as much can be loaded onto this truck. The book prints 56mph as 891kmph, which is wrong - 56mph is about 90kmph.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('5-ton-m-816-wrecker', '5 Ton M-816 Wrecker', 'heroes-unlimited', 'vehicle', '2', NULL, '52mph', NULL, NULL, 'Length 356 inches', '36,100lbs (16,245kg)', 650, 0, 8, NULL, NULL, 'MILITARY TRANSPORT VEHICLES, printed 225. The book prints no price for any of the four. Cruising range 350 miles (562km). The book prints 52mph as 830kmph, which is wrong - 52mph is about 84kmph.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('m-88-truck-recovery-vehicle', 'M-88 Truck, Recovery Vehicle', 'heroes-unlimited', 'vehicle', '4', NULL, '31mph (49kmph)', NULL, NULL, 'Length 325.5 inches', '110,000lbs (49,500kg)', 800, 0, 8, NULL, NULL, 'MILITARY TRANSPORT VEHICLES, printed 225. The book prints no price for any of the four. Cruising range 222 miles (356km). Alone among the four on this page, its printed metric conversion is correct.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('a-typical-light-observation-helicopter', 'A Typical Light Observation Helicopter', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '150mph (240kmph) cruising', NULL, 'Length 30ft (9m)', '1,160lbs (519kg) basic', 250, 0, NULL, 450000, 'Mercenary cost', 'HELICOPTERS, printed 225. A generic entry rather than a named aircraft, which is how the book opens the section. Payload 930lbs (415kg). Range 380 miles (610km).', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('oh-23-raven', 'OH-23 Raven', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '90mph (144kmph) cruising', NULL, 'Length 41ft (12.5m)', '1,821lbs (810kg) basic', NULL, 0, NULL, 90000, 'Mercenary cost', 'HELICOPTERS, printed 225. THE BOOK PRINTS NO S.D.C. FOR THIS ONE, alone among the four helicopters, and the omission is on the page rather than in the scan. Payload 851lbs (383kg). Range 439 miles (707km). Used as a light observation helicopter and seen in older television shows - the book names The Prisoner. A cheap, easy to find and expendable vehicle; different versions are in use in Canada, Columbia, Thailand and the United Kingdom.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('uh-1h-huey', 'UH-1H Huey', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '127mph (203kmph) cruising', NULL, 'Length 57ft (17m)', '4,900lbs (2205kg) basic', 325, 0, NULL, 344000, 'Mercenary cost', 'HELICOPTERS, printed 225. Payload 3,116lbs (1395kg). Range 314 miles (406km). Featuring a more powerful engine than earlier models but otherwise the same as the UH-1D. By April 1969 some 2,202 UH choppers were serving in Vietnam, and pilots greatly preferred the UH-1H for its extra unofficial power. Used in Argentina, Australia, Bolivia, Canada, Cambodia, Chile, El Salvador, Ethiopia, Greece, Japan, New Zealand, Spain, Taiwan, Thailand and Venezuela.', 'Revised Heroes Unlimited p.225');
INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers,
  speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body,
  is_mega_damage, ar, cost, cost_note, description, source_book)
VALUES ('ah-1g-huey-cobra', 'AH-1G Huey Cobra', 'heroes-unlimited', 'vehicle', NULL, NULL, NULL, '138mph (225kmph) cruising', NULL, 'Length 53ft (16m)', '8,404lbs (3780kg) basic', 400, 0, NULL, 1500000, 'Mercenary cost; an updated version is $1,700,000', 'HELICOPTERS, printed 225. Payload 2,500lbs (1125kg). Range 359 miles (578km). By July 1969 there were 441 Cobras active in Vietnam. A typical ''Snake'' was armed with a 40mm grenade launcher, an XM-3 48-tube 2.75 inch rocket pod system and two M-60 machineguns. UPDATED VERSIONS are available to small nations and mercenaries for $1,700,000 each and generally have Noroc armour for the crew seats and sides, 2 M-18 mini-gun pods, 2 M-157 rocket pods, a special turret-mounted M-29 40mm grenade launcher and a Vulcan six-barreled 20mm cannon.', 'Revised Heroes Unlimited p.225');

-- ASSERTIONS.

SELECT 'all forty-nine vehicles landed' AS assertion, count(*) AS got, 49 AS want
  FROM vehicles WHERE system = 'heroes-unlimited';

SELECT 'twenty-seven from printed 221' AS assertion, count(*) AS got, 27 AS want
  FROM vehicles WHERE source_book = 'Revised Heroes Unlimited p.221';
SELECT 'eleven from printed 222' AS assertion, count(*) AS got, 11 AS want
  FROM vehicles WHERE source_book = 'Revised Heroes Unlimited p.222';
SELECT 'three from printed 223' AS assertion, count(*) AS got, 3 AS want
  FROM vehicles WHERE source_book = 'Revised Heroes Unlimited p.223';
SELECT 'eight from printed 225' AS assertion, count(*) AS got, 8 AS want
  FROM vehicles WHERE source_book = 'Revised Heroes Unlimited p.225';

-- THE UNIT. This is the assertion the whole migration exists for: not one of
-- these rows may read as mega-damage.
SELECT 'every one of them is S.D.C., not M.D.C.' AS assertion, count(*) AS got, 49 AS want
  FROM vehicles WHERE system = 'heroes-unlimited' AND is_mega_damage = 0;
-- COUNTED AS ZERO, NOT AS 171. The number of Rifts vessels differs per
-- environment - a stale local database had 164 where production had 171 - so an
-- assertion naming the total tests the environment rather than this change.
-- What must be true everywhere is that the new DEFAULT reclassified nothing.
SELECT 'and no Rifts vessel was reclassified by the new default' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE system = 'rifts' AND is_mega_damage = 0;
SELECT 'nor did any Rifts vessel acquire an A.R.' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE system = 'rifts' AND ar IS NOT NULL;

-- A.R.: forty carry one, and the nine that do not are the five underwater
-- vehicles and the four helicopters.
SELECT 'forty carry the A.R. the book prints' AS assertion, count(*) AS got, 40 AS want
  FROM vehicles WHERE system = 'heroes-unlimited' AND ar IS NOT NULL;
SELECT 'the Patton is A.R. 18 with 1000 S.D.C. in the main body' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE name = 'M-48A3 Patton II' AND ar = 18 AND mdc_main_body = 1000
   AND is_mega_damage = 0;

-- WHAT THE BOOK DOES NOT PRICE. Fourteen finished rows, not fourteen gaps.
SELECT 'fourteen rows carry no price, because the book prints none' AS assertion, count(*) AS got, 14 AS want
  FROM vehicles WHERE system = 'heroes-unlimited' AND cost IS NULL;
SELECT 'no airplane is priced' AS assertion, count(*) AS got, 3 AS want
  FROM vehicles WHERE name IN ('Single Engine', 'Twin Engine', 'Small Jet') AND cost IS NULL;
SELECT 'and every priced military row says Mercenary' AS assertion, count(*) AS got, 8 AS want
  FROM vehicles WHERE system = 'heroes-unlimited' AND instr(cost_note, 'Mercenary') > 0;

-- THE ONE HELICOPTER WITH NO S.D.C., which is the book's answer and not a
-- dropped line.
SELECT 'the OH-23 Raven has no S.D.C.' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE name = 'OH-23 Raven' AND mdc_main_body IS NULL AND cost = 90000;
SELECT 'and it is the only Heroes Unlimited vehicle without one' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE system = 'heroes-unlimited' AND mdc_main_body IS NULL;

-- NO ROW FOR THE ILLUSTRATION CAPTION.
SELECT 'the Cayuse caption did not become a vehicle' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE instr(name, 'Cayuse') > 0 OR instr(name, 'LOACH') > 0;
SELECT 'while the typical light observation helicopter, which is an entry, is here' AS assertion,
       count(*) AS got, 1 AS want
  FROM vehicles WHERE name = 'A Typical Light Observation Helicopter' AND mdc_main_body = 250;

-- LOCATIONS AND WEAPON SYSTEMS.
SELECT 'fourteen location rows' AS assertion, count(*) AS got, 14 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
 WHERE v.system = 'heroes-unlimited';
SELECT 'twelve weapon systems' AS assertion, count(*) AS got, 12 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
 WHERE v.system = 'heroes-unlimited';
SELECT 'and not one of those weapons is mega-damage either' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
 WHERE v.system = 'heroes-unlimited' AND w.is_mega_damage = 1;
SELECT 'the Patton keeps its main gun and its treads apart' AS assertion, count(*) AS got, 2 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'm-48a3-patton-ii'
   AND location IN ('Main Gun', 'Tread') AND mdc IN (200, 75);
SELECT 'the prototype tank has five locations and two weapons' AS assertion, count(*) AS got, 5 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'an-average-high-tech-tank-prototype';
SELECT 'and its laser is 1D4 x 10 at 4000ft' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'an-average-high-tech-tank-prototype'
   AND name = 'High Speed Laser' AND instr(damage, '1D4 x 10') > 0 AND instr(range, '4000ft') > 0;

-- THE LAND ROVER SAYS IT HAS NO WEAPONS, so it should have none rather than
-- none-by-omission.
SELECT 'the Land Rover carries no weapon systems' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'high-tech-armored-land-rover';
SELECT 'and says so in its own description' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'high-tech-armored-land-rover'
   AND instr(description, 'WEAPON SYSTEMS: NONE') > 0;

-- TEXT CHECKS, because a batch in this import once passed every count while
-- every string in it was mangled.
SELECT 'the Sheridan description survived' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE name = 'M-551 Sheridan Tank' AND instr(description, 'air-portable') > 0;
SELECT 'the Huey kept its unofficial power' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE name = 'UH-1H Huey' AND instr(description, 'extra unofficial power') > 0;
SELECT 'and the jeep records the conversion the book got wrong' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE name = '.25 Ton Truck Utility Jeep'
   AND instr(description, 'METRIC CONVERSION IS WRONG') > 0 AND speed_ground = '65mph';

INSERT INTO data_script_runs (filename) VALUES ('add-hu-vehicles.sql');
