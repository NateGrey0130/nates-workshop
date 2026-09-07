-- Triax body armour, the two jet packs, and the gurgoyle armour suit.
-- Printed 34-38 and 205. Fourteen new rows, plus three stubs filled.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-gear-a-armor.sql
--
-- The book is a SCAN. Every number here was read off the OCR cache and then
-- CHECKED against a render of the page, per the Phase World precedent that gear
-- numbers are not to be taken from OCR alone.
--
-- THREE STUBS ARE FILLED RATHER THAN DUPLICATED. add-ngr-*-class.sql created
-- t-10-infantry-cyclops-body-armor, t-12-field-medic-body-armor and
-- t-13-field-mechanic-body-armor as stubs cited to the O.C.C. pages that
-- mention them; the armour chapter is where they are actually statted, so the
-- UPDATEs below give them their numbers and re-cite them to printed 35-37.
-- FIVE published classes reference t-10 by SLUG, so the slug is untouched -
-- rewriting a referenced slug is the catalog editor's duplicate-tool job. Each
-- UPDATE is guarded on the STUB marker, so it cannot fire twice and cannot
-- overwrite a row somebody has since filled by hand.
--
-- THE T-40 IS THE ARMOUR THE GYPSY CLASSES NAME. All four Gypsy O.C.C.s offer
-- T-40 "plain clothes" armour as an alternative to light M.D.C. body armour,
-- and their extraction notes record it as a Triax row the gear batch had not
-- reached. It is SEVEN priced garments rather than one suit, so it lands as
-- seven rows.
--
-- THE T-40 LINE USES AN ARMOUR RATING, which most Rifts armour does not: an
-- attack rolling under the A.R. hits the wearer normally and one rolling over
-- it strikes the armour. Both the A.R. and the M.D.C. are stored.
--
-- TWO PLACES THE BOOK DISAGREES WITH ITSELF, recorded rather than resolved:
--   * the Businessman Suit and the Jump-suit both print "12 pounds (5.9 kg)",
--     and 12 lbs is 5.44 kg. Verified on a render - the book prints 12 both
--     times - so the CONVERSION is what is wrong and the pound figure stands.
--   * the Falcon 300 prints a maximum speed of 120 mph and then describes its
--     electric range as "about 200 miles an hour". Both are the book's own; the
--     description carries the contradiction rather than resolving it.
--
-- T-43 EXPLORER IS NOT THE CATALOG'S "Explorer Armor". That row is a light
-- M.D.C. suit named in passing by the Book of Magic and carrying an estimated
-- price; this is a different suit from a different book, so it takes its own
-- slug rather than filling that one.
--
-- A PRICE RANGE STORES ITS LOW END in cost, with the range in cost_note - the
-- CA-1/CA-2 Dead Boy precedent that add-juicer-uprising-gear-a.sql records.
-- That is why the Ultra-Businessman reads 75,000 and the Falcon 300 reads
-- 30,000 rather than an invented midpoint.
--
-- Sorts after every add-ngr-*-class.sql, which is what creates the three stubs -
-- checked against the directory rather than assumed.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('t-11-enhanced-body-armor', 'T-11 Enhanced Body Armor', 'rifts', 'armor', 40, 100000, 'Black market 100,000 credits; poor availability. Exclusive to the NGR Military.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 100, 'A bulkier variant of the T-10 with a built-in robot exo-skeleton, assigned to soldiers of notable strength and speed - sergeants, rail gunners, special operatives, heavy weapons and construction personnel. Good mobility, -5% prowl penalty. The exo-skeleton gives +6 to P.S., +10 to Spd, +10 feet (3 m) to leaping distance, +10% to climbing, and halves the rate of fatigue. It takes twice as long to put on as ordinary armour. Colours: light grey or camouflage, officers a darker grey or camouflage.', 'Rifts World Book 5: Triax and the NGR p.35'),
('t-40-urban-businessman-suit', 'T-40 Urban Armor: Businessman Suit or Tuxedo', 'rifts', 'armor', 12, 50000, '50,000 credits', NULL, 0, NULL, NULL, NULL, 19, NULL, 12, 'T-40 Urban "plain clothes" armour - das Panzer Kleidung. Armour worn as ordinary clothing, using an Armour Rating rather than relying on M.D.C. alone: an attack rolling under the A.R. strikes the wearer normally, and one rolling over it hits the armour. Excellent mobility, -2% prowl penalty. Colours: any, though camouflage is not offered on business suits or tuxedos.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-ultra-businessman-suit', 'T-40 Urban Armor: Ultra-Businessman Suit or Tuxedo', 'rifts', 'armor', 20, 75000, '75,000 to 100,000 credits depending on style and quality', NULL, 0, NULL, NULL, NULL, 20, NULL, 20, 'T-40 Urban "plain clothes" armour, the heavier dress version, supplied with hat, gloves and boots. Good mobility, -5% prowl penalty. Colours: any, though camouflage is not offered on business suits or tuxedos.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-jump-suit', 'T-40 Urban Armor: Jump-suit with Hood', 'rifts', 'armor', 12, 50000, '50,000 credits', NULL, 0, NULL, NULL, NULL, 19, NULL, 12, 'T-40 Urban "plain clothes" armour in jump-suit form. A.R. 19 with the hood down and 20 with it up. Excellent mobility, -2% prowl penalty. Colours: any, including camouflage.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-outdoorsman', 'T-40 Urban Armor: Outdoorsman Pants and Jacket', 'rifts', 'armor', 15, 45000, '45,000 credits', NULL, 0, NULL, NULL, NULL, 19, NULL, 15, 'T-40 Urban "plain clothes" armour cut as outdoor pants and jacket. Good mobility, -5% prowl penalty. Colours: any, including camouflage.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-long-coat', 'T-40 Urban Armor: Long Coat/Trench Coat', 'rifts', 'armor', 15, 50000, '50,000 credits', NULL, 0, NULL, NULL, NULL, 18, NULL, 15, 'T-40 Urban "plain clothes" armour cut as a long or trench coat. Good mobility, -5% prowl penalty. Colours: any, including camouflage.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-standard-jacket', 'T-40 Urban Armor: Standard Jacket', 'rifts', 'armor', 10, 25000, '25,000 credits', NULL, 0, NULL, NULL, NULL, 12, NULL, 10, 'T-40 Urban "plain clothes" armour as a plain jacket - the cheapest full garment in the line. Excellent mobility, no prowl penalty. Colours: any, including camouflage.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-40-urban-standard-vest', 'T-40 Urban Armor: Standard Vest', 'rifts', 'armor', 10, 20000, '20,000 credits', NULL, 0, NULL, NULL, NULL, 10, NULL, 10, 'T-40 Urban "plain clothes" armour as a vest, the lightest and cheapest of the line. Excellent mobility, no prowl penalty. Colours: any, including camouflage.', 'Rifts World Book 5: Triax and the NGR p.37'),
('t-41-riot-suit', 'T-41 Riot Suit', 'rifts', 'armor', 13, 25000, '25,000 credits; good availability', NULL, 0, NULL, NULL, NULL, NULL, NULL, 50, 'Der Aufstandanzug - mass market full composite body armour used by corporate security other than Triax itself, which issues the T-10 to T-13 in blue with grey and gold trim. It has the same environmental features as the NGR military armour minus the cyclops sensor and optics package, trading M.D.C. for mobility. Excellent mobility, no prowl penalty. Supplied with a large rectangular impact-resistant shield of 23 M.D.C. weighing 6 lbs (2.7 kg), its upper portion clear, used defensively against thrown objects and S.D.C. weapons; carrying it is -1 to parry. Colours: black, white, dark brown or tan only.', 'Rifts World Book 5: Triax and the NGR p.37-38'),
('t-42-commando-scout', 'T-42 Commando Scout', 'rifts', 'armor', 12, 50000, '50,000 credits. New, and currently poor availability from high demand and low production; expected to reach good availability by 106 P.A.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 70, 'The latest Triax armour: a hybrid super-lightweight composite. Excellent mobility, no prowl penalty. The mainstream helmet carries its optics, laser and sensors in a small box on the right side rather than in a military cyclops helmet, and has no computer or video link; the solid plate visor flips up outside combat and environmental sealing. Enhancements: normal optics and split-view, passive nightvision to 2000 feet (610 m), 5x telescopic to 6000 feet (1830 m), light filters, a system-status and oxygen computer, a laser distancer to 1000 feet (305 m), and laser targeting to 1000 feet (305 m) giving +1 to strike. Colours: light green, dark green, light grey, medium grey, tan, black, white or camouflage.', 'Rifts World Book 5: Triax and the NGR p.38'),
('t-43-explorer', 'T-43 Explorer', 'rifts', 'armor', 20, 45000, '45,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, 70, 'Der Forscher - all-purpose heavy padded kevlar and plate composite armour, built so a jet pack or backpack attaches and detaches quickly. Fair to poor mobility, -20% prowl penalty. The Falcon 300 is the standard jet pack for it, though the military T-100 Eagle or a Wilk''s jet pack also fit. Colours: light green, dark green, light grey, medium grey, tan, black, white or camouflage. NOT the same suit as the catalog''s Explorer Armor, which is a light M.D.C. suit named in passing by the Book of Magic and carrying an estimated price.', 'Rifts World Book 5: Triax and the NGR p.38'),
('t-100-eagle-jet-pack', 'T-100 Eagle Jet Pack', 'rifts', 'gear', 35, 600000, '600,000 credits; available upon assignment', NULL, 0, 'Maximum speed 200 mph (321.8 km); range effectively unlimited on its nuclear engine, but 600 miles (1000 km) is the practical limit before overheating becomes a risk', NULL, NULL, NULL, NULL, 30, 'The Triax military jet pack, fitting all NGR military body armour and the new T-42 Commando Scout. Faster and longer-flying than the mainstream Falcon 300, which - or a Wilk''s jet pack - can substitute at a pinch. Nuclear engine with a ten year life. It must cool for 20 minutes after every three hours of continuous use; pushed to four hours there is a 1-40% chance of overheat and burnout. Colours: light grey or camouflage.', 'Rifts World Book 5: Triax and the NGR p.34-35'),
('falcon-300-jet-pack', 'Falcon 300 Jet Pack', 'rifts', 'gear', 35, 30000, 'Priced by engine: 30,000 credits with a gasoline engine, 46,000 credits electric/rechargeable, or 400,000 credits for a nuclear engine with a ten year life. The stored cost is the gasoline figure, the low end of the three.', NULL, 0, 'Maximum speed 120 mph (192 km). Range 600 miles (960 km) on gasoline - 200 miles per gallon, three gallon (11.4 litre) tank - or up to 800 miles (1280 km) electric; the nuclear engine is effectively unlimited', NULL, NULL, NULL, NULL, 18, 'The mainstream civilian jet pack, three feet (0.9 m) long, carrying no weapons, and the standard pack for the T-43 Explorer. It must cool for two hours after every two to three hours of continuous use, with four hours the maximum; past that there is a 1-40% chance of overheat every 20 minutes. THE BOOK CONTRADICTS ITSELF HERE: it prints a maximum speed of 120 mph and then describes the electric range as "about 200 miles an hour - four hours of energy". Both figures are the book''s own.', 'Rifts World Book 5: Triax and the NGR p.38-39'),
('gargoyle-body-armor', 'Gargoyle Body Armor', 'rifts', 'armor', 100, 40000, 'Black market 40,000 credits; poor availability', NULL, 0, NULL, NULL, NULL, NULL, NULL, 150, 'Giant-size plate body armour for creatures 8 to 12 feet (2.4 to 3.6 m) tall. About 40% of the gurgoyle army wears it, and only about 25% of the winged gargoyles do. It adds mega-damage protection but is NOT a full environmental suit. Fair mobility, -10% prowl penalty. Colours: any.', 'Rifts World Book 5: Triax and the NGR p.205');

UPDATE gear
   SET weight_lbs = 25, cost = 60000, cost_note = 'Black market 60,000 credits; poor availability. Exclusive to the NGR Military.', mdc = 100,
       category = 'armor', description = 'The standard NGR infantry suit, open to any NGR Military O.C.C. and affording the most mega-damage protection of the line armours. Fair mobility, -15% prowl penalty. Colours: light grey or camouflage; officer armour is a darker grey or camouflage for special assignments.',
       source_book = 'Rifts World Book 5: Triax and the NGR p.35'
 WHERE slug = 't-10-infantry-cyclops-body-armor' AND description LIKE '%STUB%';

UPDATE gear
   SET weight_lbs = 17, cost = 65000, cost_note = 'Black market 65,000 credits; poor availability. Exclusive to the NGR Military.', mdc = 70,
       category = 'armor', description = 'Worn by field medics and doctors, lighter than the infantry suit for mobility. Good mobility, -5% prowl penalty. It comes with a medical harness of pouches, two smoke grenades, a signal flare, and a medical and surgical kit on the belt; the helmet adds angled directional lights, a 10x macro lens and thermo-imaging. An unmarked light grey, black or camouflage version with the same helmet features and no medical symbols is available to intelligence and espionage specialists. Colours: white or light grey with a red cross on the belly, left arm, ankles, back and/or backpack.',
       source_book = 'Rifts World Book 5: Triax and the NGR p.35-36'
 WHERE slug = 't-12-field-medic-body-armor' AND description LIKE '%STUB%';

UPDATE gear
   SET weight_lbs = 18, cost = 75000, cost_note = 'Black market 75,000 credits; poor availability. Exclusive to the NGR Military.', mdc = 80,
       category = 'armor', description = 'Worn by field mechanics, with a sidearm shoulder holster and a tool-kit belt. Good mobility, -6% prowl penalty. A built-in laser torch on one arm calibrates from 1D6 to 6D6 M.D. in 1D6 increments at 100 feet (30.5 m); its clip is good for twenty 1D6 blasts or two at 6D6, extendable tenfold with an optional energy pack, and a narrow-beam mode reaches 1000 feet (305 m) but caps at 3D6 M.D. An extendable robot arm on the opposite side weighs 1 lb (0.45 kg), adds 3 feet (0.9 m) of reach at P.S. 9, lifts 90 lbs (40.8 kg), and carries a laser finger with a 2 foot (0.6 m) reach doing 1D6 S.D.C. up to 2D6x10 S.D.C. or 1 M.D. The helmet adds angled directional lights, a 2-10x macro lens, infrared, thermo-imaging and a spectrographic scanner to 4 feet (1.2 m).',
       source_book = 'Rifts World Book 5: Triax and the NGR p.36-37'
 WHERE slug = 't-13-field-mechanic-body-armor' AND description LIKE '%STUB%';

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got FROM gear WHERE slug LIKE 't-4%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-gear-a-armor.sql');
