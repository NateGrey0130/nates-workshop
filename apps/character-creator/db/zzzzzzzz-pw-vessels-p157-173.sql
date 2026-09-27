-- Phase World vessels, second half: the twelve starships and shuttles of
-- `Starships & Space`, printed 157-173 - six space fighters, two military
-- shuttles, a patrol ship, a warship, a runner and a merchantman.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-pw-vessels-p157-173.sql
--
-- BOOK-INGEST-AUDIT.md F3, for the rest of this book. The survey closed on
-- 2026-08-31 leaving these vessels out because `gear` had no shape for one;
-- migration 048 built vehicles, vehicle_locations and vehicle_weapons on
-- 2026-09-03, and zzzzzzzz-pw-vessels-p128-130.sql moved the one Phase World
-- vessel that was already hiding in `gear` (the Psionic Power Armor, F41).
-- This is the data that was still waiting on those tables.
--
-- == THE COUNT, TAKEN OFF THE PAGES RATHER THAN THE SURVEY ==
--
-- The survey and F3 both said 25 vessels in 130-149 and 157-173 (6 + 5 + 14).
-- Counting `M.D.C. by Location` blocks in the cache, and checking the book's
-- own Contents (printed 5-6) against them, gives 23: 6 robots and power armour
-- (130-142), 5 tanks and IFVs (143-149) and TWELVE starships and shuttles
-- (157-173), not fourteen. The two the survey over-counted are Contents lines
-- with no stat block - `Star Ships` on printed 173 is one prose paragraph
-- about capital ships (12,000-40,000 M.D.C., no model, no weapons) - and
-- the survey's own line 395 counted "ten" in 130-149 where there are eleven.
-- Printed 134 and 136 are full-page art with no text, which is why the cache
-- is empty there; the Groundpounder's block runs 135 -> 137 across them.
--
-- == WHAT IS DELIBERATELY PROSE ==
--
-- VARIABLE FORCE FIELDS stay in `description`. Printed 156 gives military
-- and large ships six shield values - front, back, left, right, top and
-- bottom - and lets the crew shift points between them or stack the total on
-- one side, so the number is a pool redistributed in play, not a location
-- that takes damage in a fixed place. `vehicle_locations` holds what the
-- book's `M.D.C. by Location` block prints and nothing else.
--
-- `cost` is the LOW end of any range, in credits, per the convention
-- gear.cost documents; `cost_note` carries the whole Market Cost line. A
-- vessel the book says is never sold carries cost NULL, which is a finished
-- answer here.
--
-- Every figure was read from the cached OCR of a SCAN and then confirmed
-- against a 150-250 dpi render of the page, by the extraction pass and again
-- by a book-reconcile pass; the OCR repairs are listed per vessel below.
--
-- INSERT OR IGNORE throughout, and the readbacks COUNT rather than trusting
-- the exit code. Sorts after zzzzzzzz-pw-vessels-p128-130.sql, whose readback
-- asserts exactly one Phase World vessel; checked with the class-import sort
-- command rather than reasoned about.
--
-- Pure ASCII with LF endings. The book sets curly quotes and em-dashes; they
-- are stripped here.
--
-- == THIS FILE, VESSEL BY VESSEL ==
--
-- VARIABLE FORCE FIELDS ARE PROSE on the Proctor (400 per side), Flying Fang
-- and Broadsword (200 per side), Scimitar and Berserker (1,000 per side) and
-- the Typical Runner Ship (300 per side) - the last prints no `Variable` but
-- does print `per side (1800 total)`, which is the same mechanism. The
-- Rain of Death and the Typical Merchantman print `Force Field (regular)` of
-- 1,200, one value for the whole hull, and the Shadow Bolt's Armor of Ithan
-- (180, three times a day) is one value too; those three are location rows.
--
-- The book's asterisks are footnote markers, not part of a location's name:
-- they are stripped and the footnote they point at is the row's mdc_note.
--
-- THE SHADOW BOLT RUNS ONTO PRINTED 165: its Bottled Demon Missile Launchers
-- and TK-Machineguns are stat-blocked above the `Military Shuttles` heading.
-- The TK-Machinegun range is printed `2 miles (3.2 m)` in space - km meant -
-- and the Rain of Death's hover height `20 ft. (6.1 km)`; both are kept as
-- printed and flagged in the row. The Scorpion's M.D.C. list prints
-- `CCW69B only` for a model called SF-69B everywhere else in its entry.
--
-- THE SCIMITAR RUNS ONTO PRINTED 170: its Market Cost line breaks across the
-- 169/170 folio and weapon systems 3-6 sit above the Berserker heading, so
-- it cites p.168-170. The first draft cited 168-169; this was caught by
-- re-reading the page, not by the reconcile pass.
--
-- The Star Ghost's systems 5 and 6 (phase fields, phase-jump) are numbered
-- inside the book's Weapon Systems list, so they are weapon rows with no
-- damage and say so in their note.
--
-- The Rain of Death carries cost NULL: `Never on sale legally`, with a
-- black-market guess in cost_note.
--
-- WHICH PRICE IS `cost`: the low end of the price for the vessel AS STATTED.
-- A stripped, army-surplus or knock-off version the book also prices is a
-- different machine - less M.D.C., fewer systems - so it lives in cost_note.
-- That puts the Proctor at 250 million (not the 200 million private-sale
-- version without its sensors, laser cannon and cruise missiles) and the
-- Scimitar at 400 million (not the 100-200 million army-surplus hull). The
-- first draft took the Proctor's 200 and the Scimitar's 400, two rules in
-- one file; the reconcile pass caught it.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('scorpion-class-light-fighter', 'Scorpion-Class Light Fighter (CAF)', 'rifts', 'ship',
   'One',
   NULL,
   NULL,
   'In space: Mach 8, or Mach 18 with the auxiliary engine thruster (reduced to Mach 8 if the auxiliary engine is destroyed). In an atmosphere: maximum speed is Mach 3 (the SF-69B has the same space performance but only Mach 2 in an atmosphere, the missiles adding to air drag). Range: effectively unlimited, limited only by the pilot''s endurance and oxygen supply (life support lasts 12 days).',
   NULL,
   'Height: 10 feet (3.0 m); Width: 31 feet (9.5 m); Length: 34 feet (10.4 m)',
   '6 tons/5400 kg (7 tons/6350 kg for the SF-69B)',
   550, 30000000,
   '30 million credits; 50 million credits for the SF-69B model.',
   'Model Type: SF-69, or SF-69B. Class: Light Interceptor or Fighter-Bomber (SF-69B). A small, fast CCW space fighter operated from carrier ships like the Pack Master; engages enemy fighters and short-range vessels, protects larger fleet ships, and supports heavy fighters/combat robots like the Silverhawk. One of the fastest sublight fighters in the CCW''s armed forces and extremely maneuverable, but lightly armored with no force field, making it vulnerable if hit, though it is notoriously hard to hit. Not aerodynamic - a true space fighter that flies ''like a brick'' in atmosphere, so Scorpions are meant to operate only in space and are based aboard large ships, space stations and similar facilities. Cargo: a small utility closet with room for a sidearm, dry rations for 12 days, and a water dispenser. Power System: Antimatter, average energy life of 25 years. No force field is fitted. Bonuses: +2 on initiative, +1 to strike, +4 to dodge, +10% on dog-fighting and special maneuvers, plus an additional +2 to dodge in space (Combat Performance).',
   'Rifts Dimension Book 2: Phase World p.157-158'),

  ('proctor-class-long-range-interceptor', 'Proctor-Class Long-Range Interceptor (CAF)', 'rifts', 'ship',
   'Four: Pilot/captain, co-pilot, gunner and communications/technical officer.',
   'Can accommodate an additional six passengers; ten ''coffins'' (small cubicles with room for one person lying down) are stacked in two rows around the ship''s common room.',
   'Not possible',
   'Flying: Mach 10 in space, dropping to Mach 2.5 in an atmosphere. FTL: G-Drive allows travel at four light years per hour. Range: limited by supplies and life-support; usually supports 8 people for a four month trip, or six months under strict rationing or with extra supplies.',
   NULL,
   'Height: 20 feet (6 m); Width: 50 feet (15.2 m) at the body or 80 feet (24.4 m) at the wings; Length: 80 feet (24.4 m)',
   '500 tons',
   1450, 250000000,
   '250 million credits to legitimate governments; 200 million credits to private individuals (with advanced sensors/stealth, the heavy laser cannon and cruise missiles removed); fully-equipped Black Market ships sell for as much as 500 million credits (drop 50 million credits per sensor or weapon system missing).',
   'Model Type: CAF LRF-25. Class: Long-range fighter/light frigate. An oversized CAF space fighter used by the Consortium for patrol roles that do not warrant a full frigate; operates alone as a scout, escort or patrol ship. Often sold to private individuals and converted into yachts, convoy escorts and small cargo ships; over 260,000 are in service outside the regular CAF fleet, popular with runners, mercenaries, pirates and adventurers, and hundreds have recently appeared with the Free World Council (the Transgalactic Empire suspects the CAF is secretly arming the rebels). Has long-range travel capability and a G-drive; unlike most fighters it has room for passengers, sleeping quarters and a small cargo bay. The military model carries an advanced stealth/sensor system, usually stripped before private sale; fully outfitted Black Market Proctors can be bought for millions of credits. Force Field: a variable force field of 400 M.D.C. per side (2400 total), protecting six sectors - front, back, left, right, top and bottom - with the pilot able to shift density between sectors by concentrating energy on one side. Depleting the main body''s M.D.C. leaves the ship crippled - life support and contragravity knocked out, unable to fight or move under its own power (though its missile batteries may still function); reduced to -200 M.D.C. it explodes for 4D6x10 M.D. to anything within 500 feet (152 m). Cargo: a bay 10 feet (3.0 m) tall and 20 feet (6.1 m) wide and long, maximum 100 tons. Power System: anti-matter, average energy life 50 years.',
   'Rifts Dimension Book 2: Phase World p.158-159'),

  ('flying-fang-interceptor', 'Flying Fang Interceptor (Transgalactic Empire)', 'rifts', 'ship',
   'One',
   NULL,
   'Not possible',
   'Flying: maximum speed in space is Mach 10 (cruising and combat speed is typically Mach 5); maximum atmospheric speed is Mach 4 (drops to Mach 2 with all maneuver bonuses eliminated if a horn-wing is destroyed). Range: Unlimited.',
   NULL,
   'Height: 14 feet (4.3 m); Width: 40 feet (12.2 m) from ''horn'' to ''horn''; Length: 40 feet (12.2 m)',
   '10 tons (9070 kg)',
   480, 55000000,
   'Market cost 55 million credits.',
   'Model Type: FF-100. Class: Space/Atmospheric Interceptor. A Transgalactic Empire fighter resembling the ancient Kreeghor ''Fang'' weapon (two animal horns on a central handle); its two curved ''horn'' laser cannons are meant to ''stab'' targets alongside three other weapon systems. Large enough to threaten a frigate-class vessel, but its main job is destroying enemy fighters and robots before they can threaten larger ships; also deployed on space stations and in planetary defense forces. Its aerodynamic profile lets it fight and maneuver well in an atmosphere. The cockpit is built for kreeghor pilots; human and other humanoid configurations exist but are rare, since the Imperials prefer kreeghor and relegate other races to less capable vessels - a human piloting a kreeghor-outfitted Flying Fang is at -2 to all combat actions/attacks and -15% on piloting maneuvers due to the uncomfortable seating and console layout. Cargo: none. Power System: Antimatter, average energy life of 25 years. Force Field: variable, 200 M.D.C. per side (1200 total). Destroying the main body knocks out the propulsion system and ejects the escape pod.',
   'Rifts Dimension Book 2: Phase World p.159-160'),

  ('broadsword-delta-wing-multi-environmental-fighter', 'Broadsword Delta-Wing Multi-Environmental Fighter (NE)', 'rifts', 'ship',
   'One',
   NULL,
   'Not possible',
   'Flying: Mach 9 in space, Mach 2 in an atmosphere. Range: Effectively unlimited.',
   NULL,
   'Height: 10 feet (3.0 m); Width: 30 feet (9.1 m); Length: 50 feet (15.2 m)',
   '20 tons (18,000 kg)',
   550, 65000000,
   'Market cost 65 million credits.',
   'Model Type: NE-SF10. Class: Space fighter. A Naruni Enterprises product - sleek and effective, with force fields, a wide array of weaponry and excellent speed and handling. The Free World Council has bought hundreds and they have proven their worth against the Transgalactic Empire''s best hardware. Broadswords are not very good atmospheric fighters and are best used in outer space. The name comes from its flat, triangular-nosed shape with tiny ''wings'' (actually mini-missile launchers) near the tail, reminiscent of a sword''s crossguard; every weapon system besides the missile launchers is built into the fuselage to protect it from enemy fire, visible only as small notches in the hull. Cargo: none. Power System: Nuclear, average energy life of 20 years. Force Field: variable, 200 M.D.C. per side (1200 total). Depleting the main body''s M.D.C. destroys the ship and all its (fuselage-mounted) weapon systems.',
   'Rifts Dimension Book 2: Phase World p.160-161'),

  ('star-ghost-class-fighter', 'Star Ghost-Class Fighter (Phase World)', 'rifts', 'ship',
   'One, plus life support for up to three passengers.',
   'Up to three, in addition to the one-person crew; reconfigurable to support four people for a week (or one person for a month) by sacrificing the mini-missile launchers for extra life support and food.',
   'Not possible',
   'Flying: up to Mach 12 in space, or Mach 8 in an atmosphere; cruising speed is Mach 4 to 6. Plus, it has a P-drive that lets it travel at one light year per hour. Range: Effectively unlimited; life support and food on the basic ship sustain one person for up to a week, or 4 people for 48 hours (see passengers for the reconfigured option).',
   NULL,
   'Height: 35 feet (10.7 m); Width: 40 feet (12.2 m); Length: 65 feet (19.8 m)',
   '25 tons (22,700 kg)',
   440, 280000000,
   '280 million credits; only planetary governments and mega-corps can afford them.',
   'Model Type: SG-1. Class: Strategic Fighter-Bomber. A promethean/Phase World vessel with an unmistakable delicate, crystalline, latticed hull that glows in impossible colors and seems to twist and change; in flight it can appear as a translucent ghost image, and even sophisticated visual systems may not register it as a solid object. This and other small fighter- and frigate-class ships are the only known vessels to rely completely on phase technology - whether the enabling systems simply do not work on larger hulls, or the prometheans have not built larger ones, is unknown (old tales speak of shape-shifting dreadnoughts, mostly disbelieved). In armor and raw performance the Star Ghost is only average; its edge is its phase fields, which can disperse incoming damage or render it briefly insubstantial, plus short teleport jumps that enable the fearsome one ship barrage tactic. Its special maneuvers are limited before the phase generators need to recharge, and it is hard to fly - pilots need a separate Star Ghost/phase-fighter skill, 20% lower than the conventional piloting skill. Sold on the weapons market; governments that buy and dismantle captured ships to study them find the phase drives vanish the moment anyone tries to remove them. The CCW, Transgalactic Empire, UWW and the rebel Free World Council each field small numbers; Phase World itself fields more of this class than all the others combined. Cargo: 4x4x4 feet (1.2x1.2x1.2 m). Power System: Antimatter, average energy life 25 years, plus a separate phase-field generator with 200 charges (each phase-field or jump use costs one charge; a full hour is needed to recharge once depleted, and no phase powers work until it does). If half the main body''s M.D.C. is destroyed the ship loses all phase powers; depleting it destroys the ship outright. Bonuses: +1 to strike and dodge in addition to its phase powers (Combat Performance).',
   'Rifts Dimension Book 2: Phase World p.162-163'),

  ('shadow-bolt-strike-ship', 'Shadow Bolt Strike Ship (UWW)', 'rifts', 'ship',
   'One',
   NULL,
   NULL,
   'Flying: maximum speed of Mach 9.5 in space, or Mach 4.5 in an atmosphere. Cruising speed in space is Mach 2 to 5. Range: Effectively unlimited.',
   NULL,
   'Height: 13 feet (4.0 m); Width: 40 feet (12.2 m); Length: 50 feet (15.2 m)',
   '9 tons (8200 kg)',
   400, 70000000,
   'Market cost 70 million credits.',
   'Model Type: WF-F15. Class: Dual-purpose interceptor and bomber. The mainstay fighting ship of the United Worlds of Warlock, a triumph of techno-wizardry with several enchantments and special powers, including the vaunted Bottled Demon weapon system. Enchanted with Impervious to Energy, rendering it invulnerable to laser, ion, microwave, plasma and particle beam attacks, but not missiles, rail guns, gravity guns, magic or phase weapons; also generates a special version of the Armor of Ithan spell for an invisible second M.D.C. skin. Good as a conventional technological ship too, though not as fast or maneuverable as the best CAF or Imperial fighters. Its lines resemble a normal aircraft, with bat-shaped wings for psychological intimidation and an aerodynamic configuration meant for atmospheric use; usually painted black with white or yellow monster-face nose art, Flying Tigers style. Cargo: none. Power System: Nuclear, average energy life of 10 years (called relatively primitive). Force Field: Armor of Ithan, 180 M.D.C., usable 3 times per day, giving limited invulnerability against conventional energy weapons. Depleting the main body destroys the fighter, but damage is subtracted from the mystic force field first; remember it remains vulnerable to missiles, rail guns, gravity guns, magic and phase weapons even while the force field/enchantment holds.',
   'Rifts Dimension Book 2: Phase World p.164-165'),

  ('caf-assault-shuttle', 'CAF Assault Shuttle', 'rifts', 'ship',
   'Seven: a pilot, copilot, communications/sensors officer, and four gunners.',
   'Troop Capacity: can carry ONE of: (1) One Mechanized Infantry Company and attached Tank Platoons - 80 soldiers in standard body armor, 10 troopers in power armor (any), 5 Maniple IFVs, 4 Shield-Bearer Missile Tanks, 4 Phalanx Main Battle Tanks; (2) One Power Armor Company and Tank Company - 40 soldiers in power armor (any), 30 soldiers in standard body armor, 2 Maniple IFVs, 4 Shield-Bearer Missile Tanks, 6 Phalanx Main Battle Tanks; or (3) other troop units, or up to 300 people (no vehicles, cramped conditions) for evacuation.',
   'Driving on the ground not possible; can hover at up to 20 feet (6.1 m) off the ground.',
   'Mach 6 in space or 400 mph (640 km) in an atmosphere; squat, almost square profile makes it as aerodynamic as a rock. FTL systems are expensive options seldom used in combat shuttles. Range: effectively unlimited.',
   NULL,
   'Height: 70 feet (21.3 m); Width: 50 feet (15.2 m); Length: 240 feet (73 m)',
   '1200 tons (1090 metric tons) fully loaded',
   2200, 150000000,
   'Market Cost: 150 million credits',
   'Model Type: SAS-12. Class: Tactical Troop Transport (Space). Standard Consortium Armed Forces design used as lifeboats, small transports and attack shuttles; a wing or more is found on most large starships and battleships. As a war vessel it is heavily armed and armored, with over twice the M.D.C. of an equivalent civilian shuttle and enough weapons to give a small frigate a run for its money; troops are most vulnerable in transit, so shuttles are a favorite target of planetary defenses, fighter aircraft and flying robots. Without troops the shuttle can carry 500 tons (450 metric tons) of cargo; with its troop complement, storage space is minimal (only compartments for extra weapons, ammunition and supplies). Power System: Anti-matter, average energy life of 40 years.',
   'Rifts Dimension Book 2: Phase World p.165-166'),

  ('rain-of-death-troop-transport', '"Rain of Death" Troop Transports (Transgalactic Empire)', 'rifts', 'ship',
   'Six: pilot, co-pilot and four gunners.',
   'Can carry as many as 60 soldiers (with or without powered armor) and 8 tanks or APCs, or 20 soldiers and one Doomsday Machine, or 10 giant robots and 40 soldiers in powered armor, or as many as 12 vehicles.',
   'Driving on the ground not possible. Can hover 20 ft. (6.1 km) above the ground (the book prints "6.1 km"; 20 feet is 6.1 m).',
   'Mach 4 in space, or 100 mph (160 km) in an atmosphere. Range: effectively unlimited.',
   NULL,
   'Height: 80 feet (24.4 m); Width: 80 feet (24.4 m); Length: 200 feet (61 m)',
   '2,000 tons loaded (1800 metric tons)',
   3700, NULL,
   'Market Cost: Never on sale legally; on the black market it could go for as much as 300 million credits, although it might be missing one or more weapon systems, or have reduced M.D.C.',
   'Model Type: TIV-TT1. Class: Assault Shuttle. Gray-and-black Transgalactic Empire planetary assault vehicle; as it descends toward a planet''s atmosphere it opens up with a savage barrage of missiles and smart bombs to soften up the opposition before landing, decimating defenders (and civilians). Heavily armored with strong force fields; unlike other troop carriers, its dozens of weapon hardpoints are manned not by ship''s gunners but by the troops being transported, which helps morale. Main disadvantage: cannot carry as many troops as other shuttles - the Kreeghor favor its firepower and armor over more capacity, so these ships make several trips between larger motherships and the target planet; occasionally sent on assault missions against enemy ships to reinforce decimated fighter and frigate squadrons. Cargo: minimal storage space. Power System: Anti-matter, average energy life of 40 years.',
   'Rifts Dimension Book 2: Phase World p.166-168'),

  ('scimitar-class-light-patrol-ship', 'Scimitar-Class Light Patrol Ship (CAF)', 'rifts', 'ship',
   '96, plus 100 troops, including officers. Has room for as many as 640 additional troops/people, but in cramped conditions in the cargo holds - only has staterooms for about 200 additional passengers.',
   'Fighter wing and power armor squadron: 6 Scorpion SF-69B fighter-bombers and 10 Silverhawk power armor. Infantry company of 100 soldiers, including 12 Ground-Pounder powered armor suits. Too small to carry shuttles; instead has six small escape pods with 100 M.D.C. each, carrying up to 20 people and keeping them alive for a week.',
   'Driving on the ground not possible.',
   'Mach 8 in space (maximum speed), or up to Mach 2 in an atmosphere; cruising speed is Mach 3 to 4. Star Drive: Gravitonic drive, maximum speed 5 light years per hour. Range: effectively unlimited; carries enough life support and supplies (including hydroponic garden) for two years of uninterrupted travel (stretchable to five or six in an emergency); typical patrol mission lasts six months in space.',
   NULL,
   'Height: 80 feet (24.4 m); Width: 140 feet (42.6 m), wingspan of 220 feet (67 m); Length: 500 feet (152 m)',
   '12,000 tons fully loaded, plus up to 1,000 tons of extra cargo',
   5000, 400000000,
   'Market Cost: 400 million credits to governments (the CCW only sells this ship to member planets or respectable planets); or the army-surplus version, which can cost from 100 to 200 million credits (reduce M.D.C. by 30 percent, remove all weapon systems, stealth system and advanced sensory systems, plus power armor and fighters are NOT included).',
   'Model Type: SF-20. Class: Frigate Combat and Patrol Ship. Common CAF patrol and escort ship, big enough to handle a squadron of fighters; its main guns can seriously damage larger vessels and its combined armor and force fields can take a pounding from all but the heaviest weapons, at least for a short while. Fast and maneuverable, and small enough to operate in an atmosphere with only minimal maneuvering penalties. Shaped like a giant rocket or missile with tiny wings on the side; main guns protrude from each side of the front section/command bridge; fighter/power armor bay on its underside; secondary weapon turrets placed at strategic points to cover the entire ship. Variable force fields of 1,000 M.D.C. each side (6,000 total), printed in the M.D.C. by Location list and redistributable between the six facings. Cargo: a hold 20 feet (6.1 m) tall, 20 feet (6.1 m) wide and 200 feet (61 m) long - 4,000 square feet (372 sq m) and 80,000 cubic feet (2300 cu.m) - carrying up to 1,000 tons (907 metric tons). Power System: anti-matter, average energy life 50 years.',
   'Rifts Dimension Book 2: Phase World p.168-170'),

  ('berserker-class-warship', 'Berserker Class Warship (Transgalactic Empire)', 'rifts', 'ship',
   '94',
   'None: has no troop complement, space fighters or robots.',
   'Driving on the ground not possible.',
   'Mach 9 in space; not designed to fly in an atmosphere. Star Drive: Gravitonic drive, maximum speed 4 light years per hour. Range: effectively unlimited.',
   NULL,
   'Height: 104 feet (32.7 m) from the horn-cannons to the top of the ship, or 80 feet (24.4 m, main body only); Width: 65 feet (19.8 m); Length: 300 feet (91.5 m)',
   '7,000 tons (6300 metric tons) fully loaded',
   3000, 250000000,
   'Market Cost: 250 million credits. Never sold to the public. Black market knock-offs or captured ships may be missing as much as 50 percent of its M.D.C. and some or all of its weapon systems, and will not be much cheaper, either.',
   'Model Type: TIV-AS. Class: Light Attack Vessel/Missile Ship. An ultra-tech version of the torpedo boats of the 20th century; a light starship-destroyer whose mission is to close in at point-blank range and unleash a barrage of anti-matter missiles enough to destroy anything smaller than a dreadnought. Has a variable force field and typically rushes in with all shields concentrated on the front side, meaning enemy ships would have to inflict over 9,000 M.D.C. of damage to stop it. Also used for patrol and reconnaissance and can get the better of most vessels of its class in a one-to-one fight. Distinctive profile, with its main laser cannons protruding from its belly like two horns or pincers; its two main missile batteries are in the front, side by side. Variable force field of 1,000 M.D.C. per side (6,000 maximum), redistributable between the six facings. Disadvantages: no troop complement, space fighters or robots, and a limited selection of close-range weapons; in large-scale combat it is screened by fighters from a carrier, but in a skirmish it is on its own. Cargo: a small 20x20x20 foot (6.1 m) hold, 8,000 cubic feet (227 cu.m); most of the ship is armour, inner hulls, redundant systems and extra ammunition, and emptied of ammunition with its M.D.C. halved it could carry half its total weight in cargo. Power System: anti-matter, average energy life 45 years.',
   'Rifts Dimension Book 2: Phase World p.170-171'),

  ('typical-runner-ship', 'Typical Runner Ship', 'rifts', 'ship',
   'Five',
   NULL,
   'Driving on the ground not possible.',
   'Mach 4 in an atmosphere, Mach 10 in space, and can travel at 5 light years per hour using a CG-drive. Range: effectively unlimited; life support will keep the crew alive for four months.',
   NULL,
   'Height: 30 feet (9.1 m); Width: 30 feet (9.1 m); Length: 100 feet (30.5 m)',
   '300 tons (270 metric tons)',
   2000, 30000000,
   'Market Cost: 30 million credits',
   'Class: Light Cargo Ship. A small and light cargo ship ideal for slipping through planetary defenses; includes a stealth system that cannot be detected unless it gets within 5,000 miles (8000 km) of enemy ships. Runner vessels are better armed than most civilian ships and have variable force fields. Cargo: can carry up to 100 tons (90 metric tons) of cargo. Power System: Nuclear, average energy life of 15 years. Force field of 300 M.D.C. per side (1,800 total), printed in the M.D.C. by Location list; per side, so it follows the six-facing rule of printed 156.',
   'Rifts Dimension Book 2: Phase World p.171-172'),

  ('typical-merchantman', 'Typical Merchantman', 'rifts', 'ship',
   '30',
   NULL,
   'Driving on the ground not possible.',
   'Up to Mach 7 in space (cannot fly in an atmosphere). Its CG-drive allows the ship to travel at 3 light years per hour. Range: limited only by supplies; carries enough food and life support components to keep the crew alive for up to 6 months in relative comfort, stretchable to 9 months in an emergency.',
   NULL,
   'Height: 70 feet (21.3 m); Width: 90 feet (27.4 m); Length: 600 feet (183.3 m)',
   '10,000 tons (9100 metric tons)',
   5000, 125000000,
   'Market Cost: 125 million credits',
   'Class: Freighter. A common cargo freighter used by most merchants and even some runners; has light weapon systems and force fields for self-defense, and is not particularly fast or maneuverable. Cargo: can carry up to 5,000 tons (4500 metric tons) of cargo. Power System: Nuclear, average energy life of 15 years. Other weapon systems can be added at the purchaser''s own expense, but may classify the ship as a military vessel and be denied access to many spaceports.',
   'Rifts Dimension Book 2: Phase World p.172-173');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('scorpion-class-light-fighter', 'Nose GR Cannon', 40, NULL, 1),
  ('scorpion-class-light-fighter', 'Wings/Missile Launchers (2)', 150, 'Each.', 2),
  ('scorpion-class-light-fighter', 'Cruise Missiles (CCW69B only; 2 in underbelly)', 60, 'Each.', 3),
  ('scorpion-class-light-fighter', 'Auxiliary Engine', 150, 'If the auxiliary engine is destroyed, the ship''s top speed is reduced to Mach 8.', 4),
  ('scorpion-class-light-fighter', 'Reinforced Pilot''s Compartment/Escape Pod', 110, NULL, 5),
  ('scorpion-class-light-fighter', 'Main Body', 550, 'Depleting the main body destroys the vehicle. The pilot''s only hope is to eject: the reinforced pilot''s compartment becomes an escape pod with 48 hours'' worth of oxygen.', 6),
  ('proctor-class-long-range-interceptor', 'Laser Cannons (2, on sides)', 300, 'Each.', 1),
  ('proctor-class-long-range-interceptor', 'Cruise Missiles (6, 3 under each wing)', 60, 'Each.', 2),
  ('proctor-class-long-range-interceptor', 'Medium Missile Launchers (2, one over each wing)', 180, 'Each.', 3),
  ('proctor-class-long-range-interceptor', 'Gravity Autocannon (1, on nose)', 150, NULL, 4),
  ('proctor-class-long-range-interceptor', 'Reinforced Pilot''s Cabin', 250, NULL, 5),
  ('proctor-class-long-range-interceptor', 'Main Body', 1450, 'Depleting the main body leaves the ship in tatters, with life support and contragravity knocked out, unable to fight or move under its own power (the missile batteries excepted). Reduced to -200 M.D.C. it explodes, doing 4D6x10 M.D. to anything in a 500 foot (152 m) area.', 6),
  ('flying-fang-interceptor', 'Horn Laser Cannons (2)', 150, 'Each. Destroying a horn-wing does not affect the vehicle in space, but in an atmosphere speed drops to Mach 2 and all maneuver bonuses are lost.', 1),
  ('flying-fang-interceptor', 'Dual Gravity Autocannons (2)', 80, 'Each.', 2),
  ('flying-fang-interceptor', 'Medium Missile Launchers (2, belly)', 120, 'Each.', 3),
  ('flying-fang-interceptor', 'Mini-Missile Launcher (1, top)', 80, NULL, 4),
  ('flying-fang-interceptor', 'Main Body', 480, 'Depleting the main body destroys the propulsion system and causes the escape pod to eject.', 5),
  ('flying-fang-interceptor', 'Reinforced Pilot''s Compartment/Escape Pod', 100, NULL, 6),
  ('broadsword-delta-wing-multi-environmental-fighter', 'Mini-Missile Launchers (2)', 100, 'Each.', 1),
  ('broadsword-delta-wing-multi-environmental-fighter', 'Reinforced Pilot''s Compartment', 200, NULL, 2),
  ('broadsword-delta-wing-multi-environmental-fighter', 'Main Body', 550, 'All the ship''s weapon systems are built into the fuselage except the mini-missile launchers; depleting the main body destroys the ship and all weapon systems.', 3),
  ('star-ghost-class-fighter', 'Phase Cannon (1)', 150, NULL, 1),
  ('star-ghost-class-fighter', 'Laser Turrets (2)', 120, 'Each.', 2),
  ('star-ghost-class-fighter', 'Mini-Missile Launchers (2, top and bottom)', 60, 'Each.', 3),
  ('star-ghost-class-fighter', 'Cruise Missile Launchers (2, bottom)', 60, 'Each.', 4),
  ('star-ghost-class-fighter', 'Reinforced Pilot''s Compartment', 150, NULL, 5),
  ('star-ghost-class-fighter', 'Main Body', 440, 'Depleting the main body destroys the ship. If half of the main body M.D.C. is destroyed, the ship loses all its special phase powers.', 6),
  ('shadow-bolt-strike-ship', 'Wings (2)', 120, 'Each.', 1),
  ('shadow-bolt-strike-ship', 'Bottled Demon Missile Launchers (2, beneath wings)', 100, 'Each.', 2),
  ('shadow-bolt-strike-ship', 'Lightning Rod (1, in the nose)', 90, NULL, 3),
  ('shadow-bolt-strike-ship', 'TK-Machineguns (2, on the sides)', 80, 'Each.', 4),
  ('shadow-bolt-strike-ship', 'Reinforced Pilot''s Compartment', 70, NULL, 5),
  ('shadow-bolt-strike-ship', 'Armor of Ithan Force Field (3 times per day)', 180, 'Printed in the M.D.C. by Location list. A special version of the Armor of Ithan spell, usable three times per day; damage comes off it before the main body.', 6),
  ('shadow-bolt-strike-ship', 'Main Body', 400, 'Depleting the main body destroys the fighter, but damage comes off the mystic force field first. The ship stays magically impervious to most energy weapons, not to missiles, rail guns, gravity guns, magic or phase weapons.', 7),
  ('caf-assault-shuttle', 'Laser/Missile Turrets (4)', 150, 'Each', 1),
  ('caf-assault-shuttle', 'Particle Beam Cannons (2)', 100, 'Each', 2),
  ('caf-assault-shuttle', 'Reinforced Pilot''s Compartment', 200, NULL, 3),
  ('caf-assault-shuttle', 'Door-Ramp (back)', 400, NULL, 4),
  ('caf-assault-shuttle', 'Main Body', 2200, 'Depleting the M.D.C. of the main body knocks out propulsion and all systems; it will drift in space or crash if flying in an atmosphere. Even one point below zero completely destroys the vessel. If destroyed while approaching a planet, the shuttle''s passengers and crew will be destroyed upon entering the atmosphere.', 5),
  ('rain-of-death-troop-transport', 'Laser Batteries (12)', 80, 'Each', 1),
  ('rain-of-death-troop-transport', 'Mini-Missile Batteries (12)', 60, 'Each', 2),
  ('rain-of-death-troop-transport', 'Gravity Cannon Batteries (4)', 150, 'Each', 3),
  ('rain-of-death-troop-transport', 'Bomb/Missile Bays (4)', 300, 'Each', 4),
  ('rain-of-death-troop-transport', 'Reinforced Pilot''s Compartment', 200, NULL, 5),
  ('rain-of-death-troop-transport', 'Main Body', 3700, 'Depleting the M.D.C. of the main body causes the shuttle to drift in space, or to crash if flying in an atmosphere; if destroyed while approaching a planet, the shuttle''s passengers and crew will be destroyed when entering the atmosphere.', 6),
  ('rain-of-death-troop-transport', 'Force Field (regular)', 1200, 'A single value for the whole hull, printed in the M.D.C. by Location list; not a variable (per-facing) field.', 7),
  ('scimitar-class-light-patrol-ship', 'Main Laser Cannons (2)', 800, 'Each', 1),
  ('scimitar-class-light-patrol-ship', 'G-Cannon Turrets (2)', 200, 'Each', 2),
  ('scimitar-class-light-patrol-ship', 'Particle Beam Cannons (4)', 150, 'Each', 3),
  ('scimitar-class-light-patrol-ship', 'Mini-Missile Launchers (8)', 100, 'Each', 4),
  ('scimitar-class-light-patrol-ship', 'Fighter Hangar Door', 600, 'Each', 5),
  ('scimitar-class-light-patrol-ship', 'Bridge', 2000, 'A direct hit doing more than 200 M.D. may injure or kill the bridge crew. If the bridge is destroyed, the ship can be controlled from the engineering room, but all piloting skills are -20 percent and combat rolls are -2.', 6),
  ('scimitar-class-light-patrol-ship', 'Main Body', 5000, 'Depleting the M.D.C. of the main body shuts the ship down, causing it to drift in space; the secondary weapon turrets have independent power supplies and can fight on. If the ship is reduced to -1,000 M.D.C., it blows up, causing 4D6x1000 M.D. to anything in a 300 foot (91.5 m) area.', 7),
  ('scimitar-class-light-patrol-ship', 'Main Engines (2, on the sides)', 1200, 'Each. Destroying the main engines eliminates FTL systems, leaving only sub-light systems.', 8),
  ('berserker-class-warship', 'Laser Cannons (2, underside)', 700, 'Each', 1),
  ('berserker-class-warship', 'Cruise Missile Launchers (2, front)', 1000, 'Each', 2),
  ('berserker-class-warship', 'Bridge', 1500, 'Destroying the Bridge will eliminate the main computer and controls. The ship can be controlled from the engineering section deep inside the ship, but those controls are less sensitive (-2 to strike, parry and dodge from there, and piloting is at -10 percent).', 3),
  ('berserker-class-warship', 'GR-gun-Missile Batteries (8)', 400, 'Each', 4),
  ('berserker-class-warship', 'Main Body', 3000, 'Depleting the M.D.C. of the main body means the ship is in tatters, with life support and contragravity systems knocked out, and unable to fight or move under its own power (the missile batteries are another matter). If the ship is reduced to -1,000 M.D.C., it explodes, doing 1D4x10,000 M.D. to all other ship components and any target within 1000 feet (305 m).', 5),
  ('typical-runner-ship', 'Laser Turrets (3)', 300, 'Each', 1),
  ('typical-runner-ship', 'Cockpit', 500, NULL, 2),
  ('typical-runner-ship', 'Main Body', 2000, 'Depleting the M.D.C. of the main body means the ship is in tatters, with life support and contragravity systems knocked out, and unable to fight or move under its own power except for launching missiles. If the ship is reduced to -200 M.D.C., it explodes, doing 1D4x100 M.D. to all other ship components and any target within 1000 feet (305 m).', 3),
  ('typical-merchantman', 'G-Drives (2)', 2000, 'Each', 1),
  ('typical-merchantman', 'Main Drive (back 1/5 of the ship)', 3000, NULL, 2),
  ('typical-merchantman', 'Laser Batteries (4)', 500, 'Each', 3),
  ('typical-merchantman', 'Missile Batteries (4)', 300, 'Each', 4),
  ('typical-merchantman', 'Force Field (regular)', 1200, 'A single value for the whole hull, printed in the M.D.C. by Location list; not a variable (per-facing) field.', 5),
  ('typical-merchantman', 'Bridge', 1000, 'Destroying the Bridge will eliminate the main computer and controls. The ship can be controlled from the engineering section deep inside the ship, but those controls are less sensitive (-2 to strike, parry and dodge from there, and -15 percent to pilot rolls).', 6),
  ('typical-merchantman', 'Main Body', 5000, 'Depleting the M.D.C. of the main body means the ship is in tatters, with life support and contragravity systems knocked out, and unable to fight or move under its own power except to launch missiles. If the ship is reduced to -1,000 M.D.C., it explodes, doing 1D4x1,000 M.D. to all other ship components and any target within 1000 feet (305 m).', 7);

-- ORDINALS ARE THE BOOK'S. Phase World numbers every Weapon Systems list.
INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('scorpion-class-light-fighter', 1, 'GR Cannon',
   '4D6x10 M.D. per 20 round burst (can only fire bursts)', 1, '16 miles (25 km) in space, half that amount in an atmosphere',
   'Equal to the total number of hand to hand attacks of the pilot',
   '10,000 rounds (500 bursts)', NULL,
   'Primary: anti-spacecraft. Secondary: assault. Main weapon; medium gravity rail gun used against fighters and to strafe larger ships or ground targets.'),

  ('scorpion-class-light-fighter', 2, 'Missile Launchers (2)',
   'Varies with missile type; commonly plasma (1D6x10 M.D.)', 1, 'About two miles (3.2 km)',
   'One at a time or volleys of 2, 4 or 8',
   '32, 16 on each wing', NULL,
   'Primary: anti-spacecraft. Secondary: defense. Each ''wing'' is a mini-missile launcher used in dogfights against enemy fighters.'),

  ('scorpion-class-light-fighter', 3, 'Cruise Missiles (2)',
   'Nuclear warhead: 2D6x100 M.D.; antimatter warhead: 4D6x100 M.D.', 1, '1,000 miles/1600 km (optimum launching range is 1-3 miles)',
   'One at a time or volley of two',
   'Two missiles', '+5 to strike (smart bombs); use pilot''s bonus or +5, whichever is higher, if fired point-blank (one mile)',
   'Primary: anti-starship. Secondary: strategic bombardment. SF-69B only; carried to destroy or severely damage a starship or ravage ground targets. Enemy fighters and robot-sized targets get +3 to dodge it. At point-blank range (one mile or less) the missiles travel at 1800 mph/2900 km and cannot be dodged or destroyed.'),

  ('scorpion-class-light-fighter', 4, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, '+2 to dodge in space',
   'In addition to any normal skill bonuses, the Scorpion is at +2 to dodge in space.'),

  ('proctor-class-long-range-interceptor', 1, 'Laser Cannons (2)',
   '4D6x10 M.D. per blast', 1, '10 miles (16 km)',
   'Equal to combined hand to hand attacks of the pilot or gunner',
   'Effectively unlimited', NULL,
   'Primary: anti-fighter. Secondary: defense. One laser cannon mounted on each side; the primary anti-fighter/light ship weapon system.'),

  ('proctor-class-long-range-interceptor', 2, 'Cruise Missiles',
   '2D6x100 M.D. (nuclear)', 1, '1,000 miles (1600 km)',
   'One at a time or volleys of two, three, four or six missiles',
   '6 missiles', NULL,
   'Primary: anti-ship. Secondary: anti-personnel. Only issued during combat missions; can severely damage vessels of any size.'),

  ('proctor-class-long-range-interceptor', 3, 'Medium Missile Launchers (2)',
   'Varies with missile type', 1, 'About 40 miles (64 km)',
   'One at a time or in volleys of 2, 4, or 8 missiles per launcher',
   '16 total, 8 per launcher', NULL,
   'Primary: anti-spacecraft. Secondary: defense. Used to engage enemy fighters and robots.'),

  ('proctor-class-long-range-interceptor', 4, 'Gravity Autocannon',
   '2D6x10 M.D. per 20-round burst (can only fire bursts)', 1, '5 miles (8 km) in space',
   'Equal to the number of combined hand to hand attacks per melee',
   '4,000 rounds; that''s 200 bursts', NULL,
   'Primary: anti-spacecraft. Secondary: defense. Nose-mounted dogfight weapon.'),

  ('flying-fang-interceptor', 1, 'Horn Cannons (2)',
   'A double blast from both horns: 2D6x10 M.D.; a single cannon blast: 1D6x10 M.D.', 1, '2 miles (3.2 km) in space, 4,000 feet (1200 m) in an atmosphere',
   'Equal to the total number of hand to hand attacks of the pilot',
   'Effectively unlimited', NULL,
   'Primary: anti-ship. Secondary: defense. High-power laser cannons that fire simultaneous blasts at the same target.'),

  ('flying-fang-interceptor', 2, 'Dual Autocannons (2)',
   'A dual burst does 2D6x10 M.D.; each gun does 1D6x10 M.D. per 10 round burst', 1, '3 miles in space (4.8 km), 4,000 feet (1200 m) in an atmosphere',
   'Equal to the number of combined hand to hand attacks',
   '10,000 rounds each (2000 bursts total)', NULL,
   'Primary: anti-ship. Secondary: defense. Two gravity guns in the nose for close combat.'),

  ('flying-fang-interceptor', 3, 'Medium Missile Launchers (2)',
   'Varies with missile type; typical payload is plasma/heat (2D6x10 M.D.) or multi-warhead (2D4x10 M.D.) smart bombs', 1, '50 to 100 miles (80 to 160 km); optimum attack range is under 50 miles (80 km)',
   'One at a time or in volleys of one, two, four or eight',
   'Eight total, four on each launcher', '+5 to strike (smart bomb missiles)',
   'Primary: anti-spacecraft and anti-ship. Secondary: defense. Used against fighters or larger vessels.'),

  ('flying-fang-interceptor', 4, 'Mini-Missile Launcher (1)',
   'Varies with missile type', 1, 'About two miles (3.2 km)',
   'One at a time or volleys of two',
   '24 missiles', NULL,
   'Primary: anti-ship and anti-missile. Secondary: defense. Auto-loading launcher over/behind the pilot''s compartment, magazine inside the ship; used against short-range targets or incoming missiles.'),

  ('flying-fang-interceptor', 5, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, '+1 to strike and dodge',
   'The Flying Fang is at +1 to strike and dodge in both space and atmosphere combat.'),

  ('broadsword-delta-wing-multi-environmental-fighter', 1, 'Plasma Projectors (2)',
   'A double blast does 3D6x10 M.D.', 1, '1 mile (1.6 km) in space, 2,000 feet (610 m) in an atmosphere',
   'Equal to the number of combined hand to hand attacks',
   'Effectively unlimited', NULL,
   'Primary: anti-ship. Secondary: defense. Nose-mounted guns firing relatively low-range but very powerful plasma bursts.'),

  ('broadsword-delta-wing-multi-environmental-fighter', 2, 'Rail Guns (2)',
   'A dual 80 round burst does 4D6x10 M.D. (can only fire bursts)', 1, '3 miles (4.8 km) in space, 4,000 feet (1200 m) in an atmosphere',
   'Equal to the number of combined hand to hand attacks',
   '8,000 rounds each; that''s 200 bursts total', NULL,
   'Primary: anti-spacecraft. Secondary: defense. Twin rail gun cannons mounted on the sides, fired simultaneously at the same target.'),

  ('broadsword-delta-wing-multi-environmental-fighter', 3, 'Mini-Missile Launchers',
   'Varies with missile type', 1, 'About two miles (3.2 km)',
   'One at a time or in volleys of 2, 4, 8, and 16 missiles',
   '64; 32 missiles per launcher', NULL,
   'Primary: anti-ship. Secondary: defense. Located on the sides and back of the ship; used for anti-ship and bombardment purposes, or to knock down incoming missiles.'),

  ('star-ghost-class-fighter', 1, 'Phase Cannon (1)',
   '3D6 to all living targets in a 30 ft (9.1 m) diameter around the blast point, or 1D6x10 to force fields and creatures 10 feet (3.0 m) or larger; S.D.C. to non-M.D.C. creatures, M.D. to M.D.C. creatures and force fields', 1, '3 miles (4.8 km) in space, 10,000 feet (3,000 m) in an atmosphere',
   'Equal to the number of combined hand to hand attacks',
   'Effectively unlimited', NULL,
   'Primary: anti-ship (anti-personnel). Secondary: anti-force field. Does not damage machinery/inanimate objects, only living creatures and force fields.'),

  ('star-ghost-class-fighter', 2, 'Laser Turrets (2)',
   '1D6x10 M.D., or three-shot pulse 3D6x10 M.D.', 1, '2 miles (3.2 km) in space, 4,000 feet (1,200 m) in an atmosphere',
   'Equal to the total number of hand to hand attacks',
   'Effectively unlimited', NULL,
   'Primary: anti-ship and anti-missile. Secondary: defense. Front and back mounted; must be aimed separately at each target, cannot fire simultaneously.'),

  ('star-ghost-class-fighter', 3, 'Mini-Missile Launchers (2)',
   'Varies with missile type', 1, 'About two miles (3.2 km)',
   'One at a time or volleys of two, four, or eight',
   '24, 12 on each launcher', NULL,
   'Primary: anti-ship. Secondary: defense. Top and bottom mounted.'),

  ('star-ghost-class-fighter', 4, 'Cruise Missiles (2)',
   '4D6x100 M.D.', 1, '1,000 miles (1600 km); optimal range is under one mile (1.6 km)',
   'One at a time or volley of two',
   'Two missiles', NULL,
   'Primary: anti-ship. Secondary: bombardment. Typically anti-matter warheads; fighters/robot-sized targets get +4 to dodge. At point-blank range (one mile or less) travel at 1800 mph/2900 km and cannot be dodged or destroyed.'),

  ('star-ghost-class-fighter', 5, 'Phase Fields',
   NULL, 0, NULL,
   NULL,
   '200 charges shared with the phase-field generator; each activation consumes one charge', NULL,
   'Two protective fields, only one active at a time: a deflector field that divides all incoming energy damage by ten (except magic, psionics and other phase weapons, which do full damage) but disables the phase cannon and missiles while active, leaving only the laser turrets usable; and ghost mode (an Out-of-Phase field) that renders the ship insubstantial and immune to non-magical attacks/energy, undetectable by normal sensors and the see the invisible spell (but detectable to prometheans/phase tech), reduces speed to 25% while allowing movement through normal barriers, and disables all weapons while active. Duration: deflector field 8 minutes per charge; ghost mode 1 minute per charge. Activating a field counts as one melee attack/action and can be used as a dodge.'),

  ('star-ghost-class-fighter', 6, 'Phase-Jump System',
   NULL, 0, 'Up to two miles (3.2 km) instantly per jump',
   NULL,
   'Shares the 200-charge phase-field generator; each jump consumes one charge', '+2 to dodge, +2 on initiative, +1 to strike (vs. single-pilot fighters/robots); +2 to dodge, +3 on initiative, +2 to strike (vs. a big ship)',
   'Short-range teleportation jump; counts as one melee attack/action and can be combined with attacks (jump, fire, jump away as a dodge, fire again, repeat).'),

  ('star-ghost-class-fighter', 7, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, '+1 to strike and dodge',
   'In addition to its phase powers, the Star Ghost is at +1 to strike and dodge.'),

  ('shadow-bolt-strike-ship', 1, 'Lightning Rod (1)',
   '1D6x10 M.D. (magical; will affect beings and force fields that resist non-magical attacks)', 1, 'One mile (1.6 km) in both space and atmosphere',
   'Equal to the number of combined hand to hand attacks',
   'Unlimited while the enchantment holds; the spell must be renewed every two months (400 P.P.E. and 20,000 credits), whether the weapon is used or not', NULL,
   'Primary: anti-aircraft. Secondary: defense. A TW-lightning gun firing magical blasts of electricity.'),

  ('shadow-bolt-strike-ship', 2, 'Bottled Demon Missile Launchers (2)',
   '3D4x10 M.D. of magical energy every time the missile strikes (3% chance of releasing the demon every time it hits).', 1, 'Effectively unlimited: the demon-controlled missile pursues the designated target until the target or the missile is destroyed, or the target vanishes from sight.',
   'One at a time or volleys of two, three or four.',
   '16; eight in each launcher.', '+4 to strike and +5 to dodge (missile bonuses).',
   'Primary purpose anti-ship. Demons summoned and bound into a missile shell as an intelligent, aggressive targeting system; slightly bigger than mini-missiles and needing special launchers. A missile that misses turns back and keeps pursuing, striking three times per melee round until destroyed; it attacks only the designated target, and vanishes when that target is gone or when the missile takes 50 M.D.C. of damage (which also sends the demon home). Missile speed Mach 10 in space, Mach 2 in an atmosphere. On each impact there is a 3% chance the demon is released, free to fight the enemy, flee, or turn on the UWW forces that imprisoned it.'),

  ('shadow-bolt-strike-ship', 3, 'TK-Machineguns (2)',
   '6D6 M.D. per burst.', 1, '2 miles in space (printed "2 miles (3.2 m)"; 3.2 km meant), 3,000 feet (914 m) in an atmosphere.',
   'Equal to the number of combined hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary purpose anti-ship, secondary defense. Giant versions of the TK-machinegun techno-wizard device described in Rifts, page 92; they must be re-enchanted every two months (400 P.P.E.).'),

  ('caf-assault-shuttle', 1, 'Laser/Missile Turrets (4)',
   'Laser: 1D4x10 M.D. Mini-Missiles: varies with missile type.', 1, 'Laser: 2 miles (3.2 km) in space, or 4,000 feet (1200 m) in an atmosphere. Missiles: one mile (1.6 km) (two miles/3.2 km in space).',
   'Laser: equal to the number of combined hand to hand attacks of the gunner. Missiles: one at a time or volleys of 2, 4 or 8 missiles per turret.',
   'Lasers: effectively unlimited. Mini-Missiles: 32 per turret (128 total; four turrets).', 'Computerized gunner is +2 to strike',
   'Primary Purpose: Anti-aircraft. Secondary Purpose: Defense. Located on each of the four corners of the shuttle; gunner sits at a weapons station in the turret, or the weapon is left on automatic.'),

  ('caf-assault-shuttle', 2, 'Particle Beam Cannons (2)',
   'Two settings: the first does 4D6x10 M.D. to one target; the other does 5D6 M.D. to everything in a 50 ft (15.2 m) diameter.', 1, '3 miles (4.8 km) in space, or 1 mile (1.6 km) in an atmosphere; cannot reach targets closer than 50 feet (15.2 m) away from the ship.',
   'Equal to the number of combined hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-ship. Secondary Purpose: Anti-Personnel/Defense. Beneath the pilot''s compartment; can be operated by pilot, co-pilot or sensors officer; used to engage large enemy vessels, ground installations or massed troop formations.'),

  ('caf-assault-shuttle', 3, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'Shuttles are not very maneuverable. Only the benefits of Basic Spaceship Combat apply, and even then the ship is at -2 to dodge attacks (-4 in an atmosphere), and a successful dodge takes one melee attack away from ALL the gunners in the ship (the violent and sudden movement knocks them all off balance).'),

  ('rain-of-death-troop-transport', 1, 'Gravity Cannon Batteries (4)',
   '4D6x10 M.D. per 20-round burst. Can only fire bursts.', 1, '16 miles (25 km) in space, half that amount in an atmosphere.',
   'Equal to the total number of hand to hand attacks of the gunner.',
   '20,000 rounds (1,000 bursts).', NULL,
   'Primary Purpose: Anti-aircraft. Secondary Purpose: Defense. One turret on each side of the ship, to engage enemy aircraft.'),

  ('rain-of-death-troop-transport', 2, 'Laser Batteries (12)',
   '1D4x10 M.D.', 1, '2 miles (3.2 km) in space, 4,000 feet (1200 m) in an atmosphere.',
   'Equal to the total number of hand to hand attacks of the gunner.',
   'Effectively unlimited.', '+2 to strike via gunner computers (if left automatic)',
   'Primary Purpose: Anti-aircraft. Secondary Purpose: Defense, anti-personnel. Manned by the soldiers being transported, or left on automatic; gunner sits at a station separated from the rest of the ship by an airlock - if the battery is destroyed, the gunner (if he survives) is cut off from the ship.'),

  ('rain-of-death-troop-transport', 3, 'Mini-Missile Batteries (12)',
   'Varies with missile type.', 1, 'About two miles (3.2 km) (half that in an atmosphere).',
   'One at a time or in volleys of two, four or six per turret.',
   '32 missiles per launcher (384 total).', NULL,
   'Primary Purpose: Anti-ship and anti-personnel. Secondary Purpose: Defense. Also used by the passengers or through computerized systems, for the same purpose as the laser batteries.'),

  ('rain-of-death-troop-transport', 4, 'Bomb/Missile Bays (4)',
   'Varies with missile type. Usually 3D6x10 or 4D6x10 M.D.', 1, 'Varies with missile type; bombs have a 200 mile range (320 km).',
   'Up to 16 missiles, 32 bombs, or any combination of the two in one melee round; bombs blanket an area with a radius of 300 feet (91.5 m) per four bombs dropped (32 bombs cover a 2400 feet/280 m area); missiles attack the nearest targets of the assigned class (each missile has a 10 mile/16 km sensor range).',
   'Typically carries 48 missiles and 68 bombs; two bombs can be replaced by one missile and vice versa.', 'Missiles +5 to strike; bombs +2 to strike',
   'Primary Purpose: Bombardment and anti-armor. Secondary Purpose: Anti-ship. Located on the underbelly, opened on final approach; missiles do the same damage as long-range missiles (nuclear or multi-warhead); missiles (not bombs) can be used against enemy spaceships in a space battle, bombs can be dropped on larger vessels or used as drifting mines.'),

  ('rain-of-death-troop-transport', 5, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'The shuttle is a poor fighting aircraft. Only bonuses from basic air-space combat apply, and even then the ship is at -2 to dodge (-4 in an atmosphere), and a successful dodge takes one attack away from ALL the gunners in the ship (a violent movement knocks them all off balance).'),

  ('scimitar-class-light-patrol-ship', 1, 'Laser Cannons (2)',
   '2D6x100 M.D. per cannon, or a double blast does 4D6x100 M.D.', 1, '16 miles (25 km).',
   'Twice per melee round each (or two double blasts).',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-ship. Secondary Purpose: Anti-building. Heavy artillery pieces used to engage large ships, space stations and other important targets; can be aimed at different targets or fired simultaneously at the same target.'),

  ('scimitar-class-light-patrol-ship', 2, 'G-Cannons (2)',
   'A burst is 80 rounds and does 1D4x100 M.D.; can only fire bursts.', 1, '10 miles (16 km).',
   'Equal to the total number of hand to hand attacks of the gunner.',
   '32,000 rounds per turret (400 bursts).', '+2 to hit, 3 attacks per melee (gunner or gunner program); robots and fighters are +2 to dodge these attacks',
   'Primary Purpose: Anti-ship. Secondary Purpose: Anti-spacecraft and anti-missile. Each cannon in a separate turret, used for anti-ship combat or to engage enemy fighters and robots that get past the ships normal defense.'),

  ('scimitar-class-light-patrol-ship', 3, 'Particle Beam Cannons (4)',
   '3D6x10 M.D. per blast.', 1, '6 miles (9.6 km).',
   'Equal to the total number of hand to hand attacks of the gunner.',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-spacecraft and anti-missile. Secondary Purpose: Anti-ship. Four turrets with light particle beam cannons, used to engage enemy vessels and to knock down missiles and fighters.'),

  ('scimitar-class-light-patrol-ship', 4, 'Mini-Missile Launchers (8)',
   'Varies with missile type. Usual load is a mix of plasma and armor-piercing missiles.', 1, 'About two miles (3.2 km).',
   'One at a time or volleys of four or eight missiles.',
   '128 missiles per launcher-turret (1,024 missiles) plus cargo hold carries an additional 2,048 missiles; reloading a turret from the cargo hold takes 1D6 minutes.', NULL,
   'Primary Purpose: Anti-spacecraft and anti-missile. Secondary Purpose: Defense. Point defense against fighters and missiles; each turret usually fires volleys of 4 missiles per target to insure a kill.'),

  ('scimitar-class-light-patrol-ship', 5, 'Aircraft and Military Vehicles',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'In addition to its main weaponry, the Scimitar has a complement of 6 Scorpion SF-69B fighter-bombers and 10 Silverhawk power armor; also an infantry company of 100 soldiers, including 12 Ground-Pounder powered armor suits. The Scimitars standard load does not normally include large troop concentrations or military vehicles.'),

  ('scimitar-class-light-patrol-ship', 6, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'Spaceship Combat Bonuses (Basic) apply, but the ship is -2 to dodge against attacks at 3 miles (4.8 km) or closer.'),

  ('berserker-class-warship', 1, 'Horn Lasers (2)',
   '1D6x100+100 M.D. per single blast, or 2D6x100+200 M.D. per double blast.', 1, '16 miles (25 km).',
   'Two per melee per cannon or two double blasts.',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-ship. Underside-mounted laser cannons that fire high-intensity beams meant to melt and burn large ships; can engage different targets or perform simultaneous attacks.'),

  ('berserker-class-warship', 2, 'Cruise Missile Launchers (2)',
   'Each missile does 2D6x100 or 4D6x100 M.D. (a volley of 20 missiles does a combined 4D6x2000 M.D.).', 1, 'Over 1,000 miles (1600 km), but optimum range is 1 to 3 miles (1.6 to 4.8 km).',
   'Volleys of 10 per launcher, per melee round, for a total of 20 missiles per melee; launchers reload the same melee and can fire again the next.',
   '100 total; 50 missiles per launcher.', NULL,
   'Primary Purpose: Anti-ship. Secondary Purpose: Assault. The deadliest weapon of the Berserker; favorite tactic is to close within 1 to 3 miles and fire a volley of 20 missiles. Countermeasures work only if the missiles are launched at a distance greater than three miles; otherwise the missiles reach the target in under one second. Only a counter-volley of 20 missiles or more will stop the barrage (roll 2D6+8 to determine how many cruise missiles are destroyed; the remainder hits the target).'),

  ('berserker-class-warship', 3, 'GR Gun/Missile Batteries (8)',
   'GR Gun: 3D6x10 M.D. per 40 round burst. Mini-Missile: varies with missile type (usually plasma or armor piercing, 1D4x10 or 1D6x10 M.D.).', 1, '2 miles (3.2 km) for both weapons.',
   'GR Gun: equal to combined hand to hand attacks per melee. Mini-Missile: one at a time or volleys of two or four missiles.',
   '8,000 rounds/200 bursts for the gun and 32 missiles per turret (256 total).', NULL,
   'Primary Purpose: Anti-aircraft and anti-power armor. Secondary Purpose: Defense. Weapon turrets with a gravity gun and a co-axial mini-missile launcher used for point defense and anti-aircraft fire; when the ship is operating on its own, these batteries are its only line of defense against fighters and robot vehicles.'),

  ('berserker-class-warship', 4, 'Combat Performance',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'No modifiers.'),

  ('typical-runner-ship', 1, 'Laser Turrets (3)',
   '2D6x10 M.D. per blast.', 1, '6000 feet (1828 m).',
   'Equal to number of hand to hand attacks of the gunner.',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-Ship. Secondary Purpose: Defense. Each turret has a high-powered laser array.'),

  ('typical-runner-ship', 2, 'Long-Range Missile Tubes (2)',
   'Varies with missile type.', 1, 'About 500 miles (800 km).',
   'One at a time or volleys of two, four or eight missiles.',
   '48; 24 missiles per launcher. Extra loads can be kept in the cargo hold (1 ton per 48 missiles).', NULL,
   'Primary Purpose: Anti-Ship. Secondary Purpose: Defense. Launchers built into the ship''s main body; can only engage targets in front of the ship.'),

  ('typical-merchantman', 1, 'Laser Batteries (4)',
   '3D6x10 M.D. per blast.', 1, '1 mile (1.6 km).',
   'Equal to the number of combined hand to hand attacks of the gunner.',
   'Effectively unlimited.', NULL,
   'Primary Purpose: Anti-ship. Secondary Purpose: Defense. Weapon pods mounted on the top and bottom of the ship (2 each); used to ward off attackers and also to deal with meteorites and space debris.'),

  ('typical-merchantman', 2, 'Missile Batteries (4)',
   'Varies with missile type.', 1, 'About 40 miles (64 km).',
   'One at a time or volleys of four or eight.',
   '96; 24 missiles per battery.', NULL,
   'Primary Purpose: Anti-ship. Secondary Purpose: Defense. Batteries fire medium-range missiles.'),

  ('typical-merchantman', 3, 'Other Weapon Systems',
   NULL, 0, NULL,
   NULL,
   NULL, NULL,
   'Can be added at the purchaser''s own expense, but may classify the ship as a military vessel and be denied access to many spaceports.');

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is how a row goes missing
-- without an error, so these COUNT. Every want is counted off the VALUES lists
-- in THIS FILE, not read back out of a database that has just loaded it.

SELECT 'this file''s vessels' AS assertion, count(*) AS got, 12 AS want
  FROM vehicles WHERE slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman');

SELECT 'all of them cite Phase World' AS assertion, count(*) AS got, 12 AS want
  FROM vehicles WHERE slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman') AND source_book LIKE 'Rifts Dimension Book 2: Phase World p.%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 69 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman');

SELECT 'their weapon entries' AS assertion, count(*) AS got, 49 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman');

SELECT 'locations with no printed figure' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman') AND mdc IS NULL;

SELECT 'every vessel carries a main body' AS assertion, count(*) AS got, 12 AS want
  FROM vehicles WHERE slug IN ('scorpion-class-light-fighter', 'proctor-class-long-range-interceptor', 'flying-fang-interceptor', 'broadsword-delta-wing-multi-environmental-fighter', 'star-ghost-class-fighter', 'shadow-bolt-strike-ship', 'caf-assault-shuttle', 'rain-of-death-troop-transport', 'scimitar-class-light-patrol-ship', 'berserker-class-warship', 'typical-runner-ship', 'typical-merchantman') AND mdc_main_body IS NOT NULL;

-- Cumulative for the book: the Psionic Power Armor (zzzzzzzz-pw-vessels-p128-130.sql)
-- plus every Phase World vessel file that sorts at or before this one.
SELECT 'Phase World vessels in the catalog' AS assertion, count(*) AS got, 24 AS want
  FROM vehicles WHERE source_book LIKE '%Phase World%';

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Scoped to THIS book; the global version belongs to zzzzzz-vehicle-class-vocabulary.sql.
SELECT 'it carries a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Phase World%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-pw-vessels-p157-173.sql');
