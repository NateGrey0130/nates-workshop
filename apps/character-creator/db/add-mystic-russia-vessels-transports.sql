-- Three Sovietski transports and weapon platforms, from Rifts World Book 18:
-- Mystic Russia printed 158-164. Three vehicles, 48 M.D.C. locations, 10 weapon
-- entries.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-russia-vessels-transports.sql
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1). None of
-- these pages is on the welded or glyph-corrupt list; all are on the
-- digit-substitution one.
--
-- BATCH 5 IS SEVEN VESSELS, NOT EIGHT AND NOT NINE. The survey said eight,
-- counting PAGES carrying `M.D.C. by Location` rather than entries; PR #1015
-- then said nine, adding the Gypsy Wagon to that eight. Both are wrong, and the
-- eighth block is not a vehicle at all: cache p022, printed 21, is the DEMON
-- CLAW, a bestiary NPC whose main body is "P.E. number x3". The whole book has
-- eight such blocks - six Sovietski vehicles, the Gypsy Wagon at printed 142,
-- and that demon. `grep -c "M.D.C. by Location"` over the cache is the check,
-- and `^Model Type:` returns exactly the six military ones.
--
-- DICE THE TEXT LAYER SETS WRONG are read as the only dice they can be
-- (BOOK-INGEST-AUDIT F53): 2D4xlO is 2D4x10, 4D4xlO is 4D4x10, !D6xlO is
-- 1D6x10, !D4xlO is 1D4x10. Every weapon damage below carrying an "x10" came
-- through that reading.
--
-- `mdc_main_body` IS NULL WHERE THE BOOK PRINTS MORE THAN ONE MAIN BODY, and
-- that is deliberate rather than missing data. The column's own schema comment
-- says it holds "the main body only" and that "a reader that wants the total
-- must sum them", so putting a derived total in it would contradict the column.
-- The Thunderbolt has two - Forward Cab Section 175 and Truck Bed 180 - and the
-- Thundersword has three - Front Section 530, Rear Section 600 and the flexible
-- Mid-Section 310. Every section is a vehicle_locations row, so nothing is lost.
-- The Bull Dog prints one Main Body and carries it.
--
-- A BOOK SLIP THE UNIQUE CONSTRAINT WOULD HAVE EATEN: the Thundersword's
-- location list prints "Rear Treads (4; two concealed) - 180 each" TWICE, once
-- in the front-section block and once in the rear. `vehicle_locations` is
-- UNIQUE on (vehicle_slug, location), so two identical strings would have
-- collided and `INSERT OR IGNORE` would have dropped one SILENTLY - 21
-- locations where the page has 22, with no error. The two rows are
-- disambiguated by section and both carry an mdc_note saying the book names
-- them identically. The vehicle has four tread units per section, front and
-- rear, and the front block's label is the one that reads as a misprint.
--
-- THE FIRST VEHICLE IS PRINTED UNDER TWO NAMES. Printed 158 heads the prose
-- "Thunderbolt Assault Truck" and the stat block immediately below it
-- "Thunderbolt Artillery Truck". The stat block's name is the one stored and
-- the other is in the description.
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
  ('thunderbolt-artillery-truck', 'Thunderbolt Artillery Truck', 'rifts', 'vehicle',
   'Two: a driver and a CGO gunner - Cannon Guidance Operator, the crewman who activates, aims and fires the cannons.',
   'One more can be squeezed into the cab, and as many as half a dozen can ride outside on the cannons when the guns are not in use.',
   'Top 70 mph (112 km), typical cruising speed 40 mph (64 km). Deep snow and treacherous terrain may reduce it to under 20 mph (32 km).',
   'None.',
   'None.',
   'Height 6 feet 5 inches (1.9 m) with the guns lowered, 15 feet (4.6 m) at maximum elevation. Width 7 feet (2.1 m) with the cannon housing, otherwise 6 feet (1.8 m). Length 18 feet (5.5 m).',
   '22 tons fully loaded',
   NULL, 3500000,
   '3.5 million Universal credits with the cannon artillery unit and the nuclear power system. A basic half-track with no cannons and a fuel engine is 600,000; the equivalent bought anywhere but the Sovietski would run 5 to 7 million.',
   'Model Type ZSU 13/14. A medium half-track cargo truck modified to carry a pair of the big cannons the Thunderstorm Artillery Cyborg uses, built into the bed on a hydraulic system that raises, lowers and absorbs the recoil. The driver''s compartment has a sliding roof panel on the passenger side giving the CGO access to a mounted Cyclone Pulse Laser Rifle. Part of the mobile artillery network defending the cities of the Sovietski: they move between strategic positions so an enemy cannot target a fixed one. Nuclear. Printed 158 heads the prose "Thunderbolt Assault Truck" and the stat block "Thunderbolt Artillery Truck"; the stat block''s name is the one stored here. TWO MAIN BODIES, 175 and 180, both in vehicle_locations - the book''s rule is that depleting the ENTIRE main body destroys the vehicle. The Reinforced Pilot''s Compartment line reads "Not applicable".',
   'Rifts World Book 18: Mystic Russia p.158-160'),

  ('bull-dog-armored-tracked-combat-vehicle', 'Bull Dog Armored Tracked Combat Vehicle', 'rifts', 'vehicle',
   'Four: a driver/pilot, a co-pilot/communications officer and two gunners. A fifth and sixth crewman fit with cramping.',
   '20 troops comfortably, 30 cramped, half that if they are Heavy Cyborgs. A dozen more can ride on the exterior in an emergency.',
   'Top 80 mph (128 km) on relatively flat ground; a more cautious 40 to 50 mph (64 to 80 km) over difficult terrain and 25 mph (40 km) in mountainous or treacherous conditions, less another 10% in deep snow or ice.',
   'None.',
   'NONE - the book says the Bull Dog sinks like a rock. Its airtight compartment holds three hours of air and tolerates a depth of up to 300 feet (91 m), which is survival rather than travel.',
   'Height 6 feet (1.8 m) to the deck, another 5 feet (1.5 m) for the guns and missile launcher, 11 feet (3.3 m) in total. Width 7 feet (2.1 m). Length 20 feet (6 m), and the plow adds another four feet (1.2 m).',
   '10 tons, able to carry another 20 and pull 40',
   340, 2200000,
   '2.2 million Universal credits complete with weapons and missiles. Seldom sold by the Armiya Sovietski, though a few hundred have reached outsiders. The Poles sell a knock-off called the "Mighty Little Hound" at 2.5 million which is 10% slower with 20% less M.D.C., and a gasoline version of it at 1.1 million with a 120 mile (192 km) range.',
   'Model Type ZSU 17/18. Class: multi-purpose, all-terrain, armoured assault and transport vehicle. A comparatively small four-tracked military ground vehicle built for rough terrain and Russian winters: its wide independent tracks ride on top of deep snow or plow through it, and 75% are fitted with a wide V-shaped heavy M.D.C. plow that doubles as a battering ram and a bulldozer. Used for troop transport, exploration, light assault, civil defence, hauling and snow removal. A side port bubble on each side can be looked through or slid open as a gun port, though a shooter firing from inside has an obstructed view and is -3 to strike. A heavy-duty winch and cable is built into the rear. Nuclear fusion, average energy life 10 years. Cargo is minimal in the cab; the removable bench seats come out to haul supplies, and it can pull up to 40 tons at a cost of 5% speed per ten tons. IT HAS NO CYBER-LINK FEATURE, which the book states outright.',
   'Rifts World Book 18: Mystic Russia p.160-162'),

  ('thundersword-multi-combat-platform', 'Thundersword Multi-Combat Platform', 'rifts', 'vehicle',
   'Ten: a pilot, a co-pilot, two communications officers, two forward gunners, a Medical Officer, a Field Commander and two rear gunners. Four more fit comfortably, typically one or two Military Specialists or Field Scientists and one or two paramedics or field doctors.',
   'Front section 18-24 human-sized troops. Rear section 40 human-sized, 50 cramped, or 30 Heavy Machines, or 20 Thunderhammer or Thunderstrike Cyborg Shocktroopers, or any combination. Another 20 could ride on top in an emergency.',
   '80 mph (128.7 km) maximum.',
   'None.',
   '50 mph (80 km), but no deeper than 12 feet (3.6 m).',
   'Height: front section 13 feet (4 m), rear section 16 feet (4.9 m) counting the lasers and sensor cluster. Width 14 feet (4.3 m). Length 42 feet (12.8 m).',
   '40 tons unloaded',
   NULL, 23000000,
   '23 million credits. Exclusive to the Sovietski, nobody has knocked it off, and it is not available on the Black Market.',
   'Model Type APC. Class: Infantry Assault and Transport Vehicle. An armoured personnel carrier nicknamed the "Centipede" for the sliding accordion-style plates of its flexible mid-section, which let it bend 45 degrees in any direction: it makes turns a long vehicle could not, turns half of itself to face an enemy while the other half stays behind cover, crawls over uneven ground, and if it must, BREAKS IN TWO - though only the forward half can then drive. Designed before the Great Cataclysm to carry troops safely and then give them heavy field support. The front half is a mobile field command centre with its own radar, combat computers and sensors; the rear half is a troop transport and weapon platform whose entire roof slides open so troops can fly or climb out en masse, with the two plate shields extending sideways to give them cover, even while moving. HIDDEN TREADS: each section has an outer tread pair and a second concealed pair toward the middle that drops down when the outer one is destroyed; the concealed ones are -5 to strike even with a called shot, unless the attacker is running alongside and can shoot past the wrecked outer tread. Colour grey with silver, black and red detailing. Nuclear, average energy life 20 years. Carries up to 100 tons of cargo and tows another 50. THREE MAIN BODIES, 530, 600 and 310, all in vehicle_locations. Destroying the four-part rear sensor cluster costs it long-range communications and radar, leaving only the front section''s standard systems.',
   'Rifts World Book 18: Mystic Russia p.162-164');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('thunderbolt-artillery-truck', 'Forward Windows (4; cab)', 25, '25 each.', 1),
  ('thunderbolt-artillery-truck', 'Headlights (2)', 2, '2 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 2),
  ('thunderbolt-artillery-truck', 'Rear Lights (2)', 2, '2 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 3),
  ('thunderbolt-artillery-truck', 'Roof Hatches (1; top)', 30, NULL, 4),
  ('thunderbolt-artillery-truck', 'Doors (2; side)', 50, '50 each.', 5),
  ('thunderbolt-artillery-truck', 'Tractor Treads (2)', 75, '75 each.', 6),
  ('thunderbolt-artillery-truck', 'Front Tires (2; cab)', 20, '20 each.', 7),
  ('thunderbolt-artillery-truck', 'Reinforced Pilot''s Compartment', NULL, 'The book prints "Not applicable" - this vehicle has none.', 8),
  ('thunderbolt-artillery-truck', 'Forward Laser Weapon (1; cab)', 50, NULL, 9),
  ('thunderbolt-artillery-truck', 'Cannon Barrels (2)', 180, '180 each.', 10),
  ('thunderbolt-artillery-truck', 'Cannon & Missile Housing', 300, NULL, 11),
  ('thunderbolt-artillery-truck', 'Main Body: Forward Cab Section', 175, 'One of TWO main bodies. Depleting the M.D.C. of the entire main body destroys the vehicle.', 12),
  ('thunderbolt-artillery-truck', 'Main Body: Truck Bed', 180, 'The other main body. Depleting the M.D.C. of the entire main body destroys the vehicle.', 13),

  ('bull-dog-armored-tracked-combat-vehicle', 'Tracks (4)', 100, '100 each. Destroying one slows the vehicle by 20%, two by 70%; three or four reduce speed to 5% of normal.', 1),
  ('bull-dog-armored-tracked-combat-vehicle', 'Rail Gun Turret (1; top, front)', 55, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 2),
  ('bull-dog-armored-tracked-combat-vehicle', 'Forward Laser Turrets (2)', 50, '50 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 3),
  ('bull-dog-armored-tracked-combat-vehicle', 'Mini-Missile Launcher (1; rear)', 90, NULL, 4),
  ('bull-dog-armored-tracked-combat-vehicle', 'Headlights (6)', 4, '4 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 5),
  ('bull-dog-armored-tracked-combat-vehicle', 'Main Bay Hatch (1; rear)', 140, NULL, 6),
  ('bull-dog-armored-tracked-combat-vehicle', 'Doors (2)', 90, '90 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 7),
  ('bull-dog-armored-tracked-combat-vehicle', 'Top Hatch (1; rear roof)', 80, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 8),
  ('bull-dog-armored-tracked-combat-vehicle', 'Windows (4; large)', 30, '30 each.', 9),
  ('bull-dog-armored-tracked-combat-vehicle', 'Small Windows (2; sides)', 12, '12 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 10),
  ('bull-dog-armored-tracked-combat-vehicle', 'Winch (2, front and rear)', 90, '90 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 11),
  ('bull-dog-armored-tracked-combat-vehicle', 'Reinforced Pilot''s Compartment', 65, NULL, 12),
  ('bull-dog-armored-tracked-combat-vehicle', 'Main Body', 340, 'Depleting the M.D.C. of the entire main body destroys the vehicle.', 13),

  ('thundersword-multi-combat-platform', 'Main Body: Front Section', 530, 'One of THREE main bodies. Depleting the M.D.C. of the main body shuts the APC down completely.', 1),
  ('thundersword-multi-combat-platform', 'Window Slit (1; long)', 100, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 2),
  ('thundersword-multi-combat-platform', 'Forward Headlights (3; lower front)', 5, '5 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 3),
  ('thundersword-multi-combat-platform', 'Forward Laser Turret', 80, NULL, 4),
  ('thundersword-multi-combat-platform', 'Main Outer Hatch/Door (2; on sides)', 140, '140 each.', 5),
  ('thundersword-multi-combat-platform', 'Main Inner Hatch (2; on sides)', 80, '80 each.', 6),
  ('thundersword-multi-combat-platform', 'Roof Hatches (2; top)', 90, '90 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 7),
  ('thundersword-multi-combat-platform', 'Rail Cannon (1; top turret)', 140, NULL, 8),
  ('thundersword-multi-combat-platform', 'Pop-Up Mini-Missile Launcher (1; top)', 110, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 9),
  ('thundersword-multi-combat-platform', 'Rear Treads (4; two concealed) - front section', 180, '180 each. THE BOOK PRINTS THIS LINE TWICE under the identical label "Rear Treads (4; two concealed)", once in the front-section block and once in the rear. This is the front-section occurrence and its label reads as a misprint: the vehicle has four tread units in each half. Stored under a disambiguated name because vehicle_locations is UNIQUE on (vehicle_slug, location) and two identical strings would have dropped one row silently. Concealed treads are -5 to strike even on a called shot.', 10),
  ('thundersword-multi-combat-platform', 'Communications Antenna (1)', 10, 'A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 11),
  ('thundersword-multi-combat-platform', 'Concealed Searchlight (lower front)', 50, '50 for the cover, 15 for the light itself.', 12),
  ('thundersword-multi-combat-platform', 'Main Body: Rear Section', 600, 'One of THREE main bodies, and the largest. Depleting the M.D.C. of the main body shuts the APC down completely.', 13),
  ('thundersword-multi-combat-platform', 'Rear Missile Housings (2)', 100, '100 each.', 14),
  ('thundersword-multi-combat-platform', 'Laser Cannons (2)', 150, '150 each.', 15),
  ('thundersword-multi-combat-platform', 'Sensor Cluster (1)', 90, 'Destroying it costs the APC long-range communications and radar; only the front section''s standard systems remain.', 16),
  ('thundersword-multi-combat-platform', 'Sliding Bay Shields (top lasers)', 220, '220 each.', 17),
  ('thundersword-multi-combat-platform', 'Main Rear Hatch (1; large)', 130, NULL, 18),
  ('thundersword-multi-combat-platform', 'Concealed Escape Hatch (2; ceiling)', 80, '80 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 19),
  ('thundersword-multi-combat-platform', 'Rear Treads (4; two concealed) - rear section', 180, '180 each. The second of the two identically labelled tread lines; see the front-section row. Concealed treads are -5 to strike even on a called shot.', 20),
  ('thundersword-multi-combat-platform', 'Tail Lights (3)', 5, '5 each. A small or difficult target: only hit on a called shot, and the attacker is -3 to strike.', 21),
  ('thundersword-multi-combat-platform', 'Mid-Section/Flexible Main Body', 310, 'The third main body, and the accordion section the "Centipede" nickname comes from.', 22);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, note) VALUES
  ('thunderbolt-artillery-truck', 1, 'Artillery Unit', 'Cannons: 2D4x10 M.D. per single round, 4D4x10 per simultaneous double blast of two rounds. Mini-missiles vary with type.', 1,
   'Cannon 8,300 feet (2530 m), about a mile and a half. Mini-missiles one mile (1.6 km).',
   'Each single or double blast counts as one melee attack; a simultaneous twin blast is still one attack.',
   '20 cannon shells, for 10 double blasts or 20 single ones, plus 40 mini-missiles - four in each of ten tubes, five tubes a side.',
   'A self-loading double-barrelled Howitzer plus a mini-missile launch system. The twin cannons raise, lower and tilt through a 45 degree arc and rotate 45 degrees side to side. A sliding panel on the side of each cannon conceals five mini-missile tubes, used offensively and defensively and especially effective against light flying targets. A three man team, two of them wearing MM-61 Explorer Exoframes or being Light or Heavy Machines, can reload four shells per melee round. Primary purpose: tactical bombardment. Secondary: anti-armour and infantry support.'),
  ('thunderbolt-artillery-truck', 2, 'Manned S-500 "Cyclone" Pulse Laser Rifle (mounted)', '1D6x10 M.D. per pulse blast, or 2D6 M.D. for a single precision shot at the flip of a switch.', 1,
   '3,000 feet (914 m) maximum effective.',
   'Each blast counts as one melee attack.',
   '60 from an E-Pack, two of which are standard issue; four shots from a standard E-Clip inserted in the side in an emergency.',
   'A modified mounted S-500 heavy laser built into a housing on the passenger side of the half-track. The passenger, usually the CGO, slides the ceiling panel open, stands on the seat, straps into a support harness and fires. It rotates 180 degrees side to side and tilts through a 30 degree arc. IT HAS AN INDEPENDENT POWER PACK, so it still fires if the cannon power system is knocked out. Primary purpose: anti-personnel. Secondary: assault and defence.'),

  ('bull-dog-armored-tracked-combat-vehicle', 1, 'Forward Mini-Laser Turrets (2)', '4D6 M.D. per single blast, or 6D8 M.D. for a simultaneous double blast at the same target.', 1,
   '2,000 feet (610 m) maximum effective.',
   'Equal to the hand to hand attacks of the gunner or pilot.',
   'Effectively unlimited; runs off the nuclear power system.',
   'A pair of single-barrelled heavy lasers in ball turrets in the forward section, each with a 60 degree arc up and down and 180 degrees side to side. They fire independently or together at one target, and are typically worked by the pilot and the co-pilot/communications officer. The book prints the heading "Foward". Primary purpose: defence. Secondary: anti-personnel.'),
  ('bull-dog-armored-tracked-combat-vehicle', 2, 'Rail Gun Turret (top)', 'A burst is 16 rounds and inflicts 1D4x10 M.D.', 1,
   '4,000 feet (1200 m) maximum effective.',
   'Fires 16 round bursts only, each counting as one melee attack.',
   'A 9,600 round drum for 600 bursts is standard issue. A second drum is usually carried and installs in one minute - four melee rounds.',
   'Set in an elevated seat between the pilot and co-pilot in the forward section, which leaves the gunner recessed and a low-profile target. All targeting is by sensors and a computer-generated screen; the gunner can instead look through a narrow viewing slit. Primary purpose: anti-personnel. Secondary: defence.'),
  ('bull-dog-armored-tracked-combat-vehicle', 3, 'Mini-Missile Launcher', 'Varies with missile type; a typical load is armour piercing at 1D4x10 M.D. or plasma at 1D6x10 M.D.', 1,
   'About one mile (1.6 km) maximum effective.',
   'Volleys of 2, 4 or 8 missiles.',
   '32 in the launcher with another 64 stored inside. Reloading takes one minute.',
   'Mounted on top toward the rear. Blast radius varies with the missile. Primary purpose: anti-vehicle and anti-aircraft. Secondary: anti-personnel and defence.'),

  ('thundersword-multi-combat-platform', 1, 'S-5050 Rail Cannon', 'A full damage burst is 40 rounds and inflicts 1D6x10 M.D. At the flip of a switch it fires 10 shot bursts for 3D6 M.D.', 1,
   '5,000 feet (1524 m) maximum effective.',
   'Equal to the combined hand to hand attacks of the gunner, usually 4-6.',
   'A 12,000 round drum feed: 300 long bursts or 1,200 short ones. Reloading takes about 15 minutes untrained, five for someone with engineering or field armorer skills.',
   'A heavy long-range general purpose weapon for assault, anti-armour work and covering fire in support of infantry. Primary purpose: assault.'),
  ('thundersword-multi-combat-platform', 2, 'LSU-10 Laser Turret (1; forward section)', '4D6 M.D. per single blast.', 1,
   '2,000 feet (610 m).',
   'Equal to the combined hand to hand attacks of the gunner, usually 4-6.',
   'Effectively unlimited.',
   'A short-range heavy laser turret built into the front lower right hand side of the APC, pointing forward with a 60 degree arc up and down. Primary purpose: anti-personnel. Secondary: defence.'),
  ('thundersword-multi-combat-platform', 3, 'Pop-Up Mini-Missile Launcher (1; forward section)', 'Varies with missile type; standard issue is fragmentation at 5D6 M.D. and plasma at 1D6x10 M.D.', 1,
   'About one mile.',
   'One at a time, or in volleys of two or four.',
   '80 total, on a self-loading auto-launch system.',
   'Sits next to the Rail Cannon. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.'),
  ('thundersword-multi-combat-platform', 4, 'SU-L60 High-Powered Tri-Laser Cannons (2; rear section)', '1D6x10 M.D. per single blast per cannon.', 1,
   '6,000 feet (1828 m) maximum effective.',
   'Equal to the combined hand to hand attacks of the gunner, usually 3-6. EACH CANNON HAS ITS OWN INDEPENDENT GUNNER.',
   'Effectively unlimited.',
   'The two big guns that slide off to the sides when the ceiling bay door opens, and the Thundersword''s main armament. Each moves through a 45 degree arc up and down and the whole turret rotates a full 360 degrees. Powered from the vehicle''s nuclear supply. The book prints the heading "Higb-Powered". Primary purpose: anti-aircraft and anti-armour. Secondary: defence.'),
  ('thundersword-multi-combat-platform', 5, 'Medium-Range Missile Launchers (2; rear section)', 'Varies with missile type; heavy missiles are standard.', 1,
   '40-60 miles (64.3 to 96.9 km) for medium-range missiles.',
   'One at a time, or in volleys of two or four.',
   'Eight total, four per launcher. Another 8-16 may be carried, at the cost of six human-sized troops of payload. Each takes 1D4 minutes to reload by hand.',
   'A pair of vertical launchers that take short or medium-range missiles; medium are standard issue. Primary purpose: anti-aircraft and anti-armour. Secondary: anti-personnel.');

-- Read the result back. INSERT OR IGNORE is SILENT on a collision, so the
-- counts are what prove nothing was lost. Every want is counted off the stat
-- blocks, not out of the database.
SELECT 'the three transports' AS assertion, count(*) AS got, 3 AS want
  FROM vehicles WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.158-160', 'Rifts World Book 18: Mystic Russia p.160-162', 'Rifts World Book 18: Mystic Russia p.162-164');

SELECT 'their M.D.C. locations: 13 + 13 + 22' AS assertion, count(*) AS got, 48 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('thunderbolt-artillery-truck', 'bull-dog-armored-tracked-combat-vehicle', 'thundersword-multi-combat-platform');

-- THE CHECK THAT CATCHES THE DUPLICATE LABEL. The Thundersword's page lists 22
-- locations and two of them print the identical string; if the disambiguation
-- were ever removed this would read 21.
SELECT 'and the Thundersword keeps both of its identically labelled tread rows' AS assertion, count(*) AS got, 22 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'thundersword-multi-combat-platform';

SELECT 'their weapon entries: 2 + 3 + 5' AS assertion, count(*) AS got, 10 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('thunderbolt-artillery-truck', 'bull-dog-armored-tracked-combat-vehicle', 'thundersword-multi-combat-platform');

-- The Bull Dog is the only one of the three printing a single Main Body.
SELECT 'only the Bull Dog carries an mdc_main_body' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE mdc_main_body IS NOT NULL
   AND source_book IN ('Rifts World Book 18: Mystic Russia p.158-160', 'Rifts World Book 18: Mystic Russia p.160-162', 'Rifts World Book 18: Mystic Russia p.162-164');

-- 175 + 180 + 340 + 530 + 600 + 310, every section the book marks as a main body.
SELECT 'the six main-body sections sum to the pages' AS assertion, sum(mdc) AS got, 2135 AS want
  FROM vehicle_locations
 WHERE vehicle_slug IN ('thunderbolt-artillery-truck', 'bull-dog-armored-tracked-combat-vehicle', 'thundersword-multi-combat-platform')
   AND (location LIKE 'Main Body%' OR location = 'Mid-Section/Flexible Main Body');

-- 3,500,000 + 2,200,000 + 23,000,000.
SELECT 'their prices sum to the pages' AS assertion, sum(cost) AS got, 28700000 AS want
  FROM vehicles WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.158-160', 'Rifts World Book 18: Mystic Russia p.160-162', 'Rifts World Book 18: Mystic Russia p.162-164');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-russia-vessels-transports.sql');
