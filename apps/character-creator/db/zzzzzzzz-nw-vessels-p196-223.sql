-- New West vessels, second half: the four robot horses, the Bandit K-9, the
-- Bronco Scooter, the Cavalry War Wagon, the Glittermount and the TW
-- Ironhorse. Printed 196-223. Nine vehicles.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-nw-vessels-p196-223.sql
--
-- == THERE ARE FOUR ROBOT HORSES, NOT THREE ==
--
-- The survey and my own first heading scan both found three, because the scan
-- looked for `Model Type:` lines and the RH-1001A Appaloosa''s sits under a
-- heading - "Appaloosa or Pony" - that gives no model number, on a page
-- (printed 196) otherwise full of accessory prices. It is the LIGHT horse and
-- the cheapest of the four. Count the entries, not the headings.
--
-- == A BOOK-WIDE GLYPH SUBSTITUTION THAT `corrupt_pages` DOES NOT SEE ==
--
-- This book renders the digit 1 as `!` or `l` and the digit 0 as `O` or `Q`
-- inside almost every `NDNx10` and `NDNx100` construction: `!D4xlO` for
-- 1D4x10, `3D4xlOO` for 3D4x100, `10Q` for 100. It is in the INK, not just the
-- text layer - confirmed at 600 dpi on printed 223 - so a render does NOT cure
-- it, unlike printed 217, which is the other kind.
--
-- IT AFFECTS ROUGHLY SIXTY PAGES and the cache manifest''s `corrupt_pages`
-- lists THREE (cache p031, p143, p218). The detector is looking for glyphs that
-- fail to map; these map to perfectly valid characters, so a substitution
-- cipher is invisible to it. What gives it away is that the result is nonsense
-- AS A DICE EXPRESSION - `!D4xlO` cannot be read any other way than 1D4x10.
--
-- Every affected figure in this file, and in the four gear batches and the
-- first vessel batch before it, was read that way. Verified `--remote` on
-- 2026-09-10 after the fact: NO row in `imported_classes`, `gear` or `vehicles`
-- contains `xlO`, `xlOO` or `!D`, and 23 of the 27 class rows mentioning this
-- book carry a correct `x100`. Nothing leaked.
--
-- == ONE M.D.C. FIGURE IS SIMPLY NOT PRINTED ==
--
-- The Ironhorse''s `Emergency Exit (1; small; in ceiling/roof)` line on printed
-- 222 ends with the em-dash and NO number, the same shape as the RUE Highway
-- Man''s tires. It is stored with `mdc` NULL and the absence recorded in
-- `mdc_note`, rather than guessed from its neighbours.
--
-- == THE IRONHORSE IS THE LOCOMOTIVE ONLY ==
--
-- The book says so outright: box cars and passenger cars are magically pulled
-- along with it and are not part of the vehicle. Their M.D.C. is recorded in
-- the description because it is stated on the same line as the locomotive''s
-- own locations, and a reader will look for it there.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('rh-1001a-appaloosa-light-robot-horse', 'Bandito Arms Appaloosa, Light Robot Horse', 'rifts', 'robot',
   'One humanoid rider.', 'One additional rider possible in emergencies.',
   'Running maximum 75 mph (120 km). Leaping 10 feet (3 m) high and 20 feet (9 m) lengthwise, with a running start.',
   'Not applicable.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 3 mph (4.8 km or 2.6 knots). Maximum depth 500 feet (152.4 m).',
   'Height usually about 13.2 hands (4 feet 4 inches / 1.34 m) at the shoulders. Width 2.6 feet (0.8 m). Length approximately 6.6 feet (roughly 2 m).',
   '800 lbs (360 kg)',
   200, 2500000,
   '2.5 million credits; sometimes on sale for 10-20% less. The DELUXE ARMORED MODEL adds 30% to all M.D.C. and 30% to the cost.',
   'Model Type RH-1001A. Class: Robot Horse. THE FOURTH ROBOT HORSE, and the one a heading scan misses - its heading is "Appaloosa or Pony" with no model number. A light robot horse, smaller than the others, tough and reliable with good speed and carrying capacity, designed for female riders, children and small D-bees. True Appaloosas are 14-15.2 hands tall; this one is 13.2. ATTRIBUTES OF NOTE: robot P.S. 26, P.P. 20, P.B. 10 (15 with hide), Spd 110, equivalent I.Q. 9. Power system nuclear, average life 15 years. CARGO: one rider and one companion if both are roughly human-size, up to 1000 pounds (450 kg) - the second seat is never comfortable for long periods - and IT CAN PULL UP TO TWO TONS. Colour of hide: Leopard (white over the loins and hips with dark oval spots), Snowflake (spotted all over), Marble (mottled colours all over) and Frosted (white specks on a dark grey or brown background); generally grey, white and a variety of browns. WEAPON SYSTEMS: none to start; see the Special Robot Features for what can be fitted. COMBAT: three attacks per melee round; +2 on initiative, +1 to strike, +3 to dodge when running, +2 to roll with punch, fall or impact. Damage: restrained hoof strike 2D4x10 S.D.C., full hoof strike 1D6 M.D., rear kick or power kick 2D6 M.D., stomp 1D4 M.D., running body block 1D4 M.D., head butt 5D6 S.D.C., bite 5D6 S.D.C. GENERAL: the RH 1000 series from Bandito Arms - Northern Gun offers identical horses for 10% more - was developed with the adventurer, gunslinger and lawman in mind. They are stronger and faster than living horses and can be programmed to be much more intelligent: the average robot horse follows complex commands, recognizes its owner and up to 96 of its owner''s friends, associates and enemies, warns the rider about approaching enemies, and identifies snakes, lions and alien predators without being afraid itself. It responds completely to the physical and voice commands of the rider and can be programmed to obey six others of the owner''s choice, so it will NOT allow unauthorized people to ride or command it. All can be covered in a realistic hide, though 40% of purchases are without it.',
   'Rifts World Book 14: New West p.196-197'),

  ('rh-1002b-mustang-medium-robot-horse', 'Bandito Arms Medium Robot Horse (Mustang or Pinto)', 'rifts', 'robot',
   'One humanoid rider.', 'One additional rider possible in emergencies.',
   'Running maximum 100 mph (160 km). Leaping 15 feet (4.6 m) high and 40 feet (12.2 m) lengthwise, with a running start.',
   'Not applicable.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 3 mph (4.8 km or 2.6 knots). Maximum depth 500 feet (152.4 m).',
   'Height usually about 15 hands (5 feet / 1.5 m) at the shoulders. Width 3 feet (0.9 m). Length approximately 8 feet (2.4 m).',
   '1200 lbs (540 kg)',
   250, 5200000,
   '5.2 million credits; sometimes on sale for 10-20% less. The DELUXE ARMORED MODEL adds 30% to all M.D.C. and 30% to the cost.',
   'Model Type RH-1002B. Class: Robot Horse. A robot horse with the same basic shape and size as the wild Mustang, tough and reliable with good speed and cargo capacity. THE ONLY DIFFERENCE BETWEEN THE MUSTANG AND THE PINTO IS THE COLOUR OF ITS FAKE HIDE - Mustang: various shades of brown and grey, solid with highlights on the lower legs; Pinto, also known as the Paint Horse or Calico, distinguished by blotches of colour, typically Ovaro (one solid brown or grey with large splashes of white) or Tobiano (white overall with small splashes of brown or grey). ATTRIBUTES OF NOTE: robot P.S. 28, P.P. 20, P.B. 9 (14 with hide), Spd 148, equivalent I.Q. 9. Power system nuclear, average life 15 years. CARGO: one rider and one companion, up to 1400 pounds (630 kg), and IT CAN PULL UP TO FIVE TONS. WEAPON SYSTEMS: none to start. COMBAT: three attacks per melee round; +2 on initiative, +2 to strike, +4 to dodge when running, +2 to roll with punch, fall or impact. Damage: restrained hoof strike 1D4 M.D., full hoof strike 1D6 M.D., rear kick or power kick 2D6 M.D., stomp 1D4 M.D., running body block 1D4 M.D., head butt 1D4x10 S.D.C., bite 6D6 S.D.C.',
   'Rifts World Book 14: New West p.197-198'),

  ('rh-1003c-arabian-robot-horse', 'Bandito Arms Arabian Robot Horse', 'rifts', 'robot',
   'One humanoid rider.', 'One additional rider possible in emergencies.',
   'Running maximum 120 mph (192 km) - the FASTEST of the four. Leaping 20 feet (9 m) high and 50 feet (15.2 m) lengthwise, with a running start; it comes standard with JETS TO ASSIST IN LEAPS, which is its claim to fame.',
   'Not applicable.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 3 mph (4.8 km or 2.6 knots). Maximum depth 500 feet (152.4 m).',
   'Height usually about 15 hands (5 feet / 1.5 m) at the shoulders. Width 3 feet (0.9 m). Length approximately 9 feet (2.7 m).',
   '1400 lbs (630 kg)',
   240, 6000000,
   '6 million credits; sometimes on sale for 10-20% less. The DELUXE ARMORED MODEL adds 30% to all M.D.C. and 30% to the cost.',
   'Model Type RH-1003C. Class: Robot Horse. As beautiful as the real breed - tall, sleek and graceful, with long, thin but powerful legs - and treated with synthetic skin and musculature giving it the look of a jet black real horse. The Arabians also have an UPGRADED SKILL PROGRAM and are slightly more intelligent than the Calico. Colour of hide: a solid body colour, often with "stockings" of a different colour on the lower legs, and a colour marking, usually white, on top of the muzzle. ATTRIBUTES OF NOTE: robot P.S. 28, P.P. 22, P.B. 11 (17 with hide), Spd 180 - the highest of the four - equivalent I.Q. 9. Power system nuclear, average life 15 years. CARGO: one rider and one companion, up to 1200 pounds (540 kg), and it can pull up to four tons. WEAPON SYSTEMS: none to start. COMBAT: three attacks per melee round; +3 on initiative, +2 to strike, +5 to dodge when running, +1 to roll with punch, fall or impact. Damage: restrained hoof strike 1D4 M.D., full hoof strike 1D6 M.D., rear kick or power kick 2D6 M.D., stomp 1D4 M.D., running body block 1D4 M.D., head butt 6D6 S.D.C., bite 6D6 S.D.C.',
   'Rifts World Book 14: New West p.198-199'),

  ('rh-1004d-war-horse-heavy-robot-horse', 'Bandito Arms Heavy Robot Horse (The War Horse)', 'rifts', 'robot',
   'One humanoid rider.', 'One additional rider possible in emergencies.',
   'Running maximum 75 mph (120 km). Leaping 15 feet (4.6 m) high and 40 feet (12.2 m) lengthwise, with a running start.',
   'Not applicable.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 3 mph (4.8 km or 2.6 knots). Maximum depth 500 feet (152.4 m).',
   'Height usually about 16 hands (5.4 feet / 1.58 m) at the shoulders. Width 3.8 feet (1.1 m). Length approximately 10 feet (3 m).',
   '2000 lbs (900 kg)',
   350, 6100000,
   '6.1 million credits; sometimes on sale for 10-20% less. The DELUXE ARMORED MODEL adds 30% to all M.D.C. and 30% to the cost.',
   'Model Type RH-1004D. Class: Robot Horse. A robot with a stocky build, thick legs and extra armour, in the basic shape the average non-horse person would call a Clydesdale. Designed for hard work and combat, and especially popular among Cyber-Knights and the 1st Cavalry. THE ONLY ONE OF THE FOUR WITH FOUR ATTACKS PER MELEE ROUND, and the best armoured by a wide margin. Colour of hide: various shades of brown, grey and white; may be speckled. ATTRIBUTES OF NOTE: robot P.S. 38 - the strongest of the four - P.P. 20, P.B. 9 (14 with hide), Spd 110, equivalent I.Q. 9. Power system nuclear, average life 15 years. CARGO: one rider and one companion, up to 2000 pounds (900 kg), and IT CAN PULL UP TO EIGHT TONS. WEAPON SYSTEMS: none to start. COMBAT: FOUR attacks per melee round; +2 on initiative, +1 to strike, +3 to dodge when running, +2 to roll with punch, fall or impact. Damage: restrained hoof strike 1D4 M.D., full hoof strike 2D6 M.D., rear kick or power kick 4D6 M.D., stomp 1D6 M.D., running body block 1D6 M.D., head butt 1D4x10 S.D.C., bite 1D4x10 S.D.C.',
   'Rifts World Book 14: New West p.199-200'),

  ('k-9r-1100-bandit-k-9-companion', 'Bandit K-9 Companion', 'rifts', 'robot',
   'None; the K-9 is a robot dog rather than a mount or a piloted vehicle.', 'None.',
   'Running maximum 40 mph (64 km). Leaping 12 feet (3.6 m) high and 25 feet (7.6 m) lengthwise, with a running start.',
   'Not applicable.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 3 mph (4.8 km or 2.6 knots). Maximum depth 500 feet (152.4 m).',
   'Height usually about 3 feet (0.9 m) at the top of the head. Width 1.6 feet (0.5 m). Length approximately 3-4 feet (0.9 to 1.2 m).',
   '300 lbs (135 kg)',
   120, 2500000,
   '2.5 million credits; sometimes on sale for 10-20% less. The DELUXE ARMORED MODEL adds 30% to all M.D.C. and 30% to the cost. Voice recognition and response (talks) is an extra 100,000 credits.',
   'Model Type K-9R-1100. Class: Robot Dog. A robot dog designed to be both companion and helper. Most are programmed to behave like a real dog - barking, growling or snarling when the bot detects danger, and barking or howling in warning. UNLIKE THE ROBOT HORSE, the artificial dog typically comes WITH a life-like covering of fur, padding and musculature. It performs combat and non-combat duties from hunting and tracking, fetching and herding animals (a big attraction in the west) to guarding, warning and attack. Fairly intelligent: it follows relatively complex orders, recognizes its owner and up to 64 of its owner''s friends, associates and enemies, warns about the approach of enemies, and identifies and warns about 300 hostile life forms including snakes, scorpions, lions and alien predators without being afraid itself. It responds completely to the HAND SIGNS - pointing, waving, finger snapping - and voice commands of its owner and can be programmed to obey six other people, so it will not allow unauthorized people to command it and will bark or growl a warning to all intruders. It can be made to look like any medium to large dog; the standard styles are German Shepherd and Retriever. Companions are found all over the New West and, for some reason, are not as popular in the East and most "civilized" areas. ATTRIBUTES OF NOTE: robot P.S. 22, P.P. 20, P.B. 10 (15 with hide), Spd 59, equivalent I.Q. 9. Power system nuclear, average life 15 years. CARGO: can carry up to 500 pounds (225 kg) and pull up to 1000 pounds (450 kg). SPECIAL SENSORS: keen polarized colour vision, passive nightsight (1600 ft / 488 m range), amplified hearing, ultra ear and a molecular analyzer in the nose, all basically the same as the bionic counterparts. K-9 COMPANION SKILL PROGRAM: land navigation, track animals, herd cattle and swim all at 90%; track humanoids 75%, climb 70%/0%, and prowl 70%. WEAPON SYSTEMS: none to start. COMBAT: three attacks per melee round; +2 on initiative, +3 to strike, +1 to parry, +3 to dodge when running, +2 to roll with punch, fall or impact. Damage: restrained bite strike 6D6 S.D.C., full strength bite 2D4 M.D., POWER BITE 3D6 M.D. but it counts as TWO melee attacks, claw strike 1D4 M.D., running body block or leaping tackle 1D4 M.D., head butt 2D6 S.D.C.',
   'Rifts World Book 14: New West p.199-201'),

  ('bronco-scooter', 'Bronco Scooter', 'rifts', 'vehicle',
   'One rider.', 'No room for a passenger.',
   NULL,
   'Maximum speed 190 mph (304 km). Maximum altitude 60 feet (18.3 m), and it can handle drops of up to 400 feet (122 m). Maximum range 800 miles (1280 km).',
   NULL,
   'Length 6 feet (1.8 m).',
   '350 lbs (157.5 kg)',
   110, 146000,
   '146,000 credits for the gasoline combustion engine or 162,000 for electric. NUCLEAR IS NOT AVAILABLE. The deluxe armored model adds 30% to all M.D.C. and 30% to the cost.',
   'Vehicle Type: Hovercycle. One of the stranger - and surprisingly popular - vehicles to come from any manufacturer: Bandito Arms'' HORSE SHAPED hovercycle, also known as the "Hobby Horse" by those who find it silly or unbefitting a real cowboy. Despite that it is incredibly popular, especially among Greenhorns, City Slickers and would-be cowboys, and its popularity is due in part to its LOW COST - it is by a wide margin the cheapest vessel in this book, at a fraction of the price of the robot horse it imitates. SPECIAL BONUSES: +1 to dodge. Engine: combustion or electric. WEAPONS: any standard hovercycle weapons can be added; lasers are usually built into the mouth or under the eyes and headlights. DAMAGE NOTES: a single asterisk indicates small and/or difficult targets requiring a called shot, and even then the attacker is -4 to strike. THE DRIVER, hunched down low to the body of the hovercycle, IS EQUALLY DIFFICULT TO HIT.',
   'Rifts World Book 14: New West p.201-202'),

  ('baww-120-cavalry-war-wagon', 'Cavalry War Wagon', 'rifts', 'vehicle',
   'Two: a pilot and a gunner.', 'Four passengers comfortably; a fifth can be squeezed in, but makes for cramped, uncomfortable conditions.',
   NULL,
   'Flying 200 mph (321.8 km), though cruising speed is considered to range between 80 and 150 mph (128 and 240 km). VTOL capable, can hover stationary, and has retractable landing gear. Maximum altitude is limited to about 2000 feet (610 m). The nuclear power gives the vehicle decades of life, and it can be flown continuously for 48 hours without fear of overheating.',
   'Can skim across the surface of water at 110 mph (160 km / 93.5 knots). IT IS SUBMERSIBLE, with an underwater speed of 50 mph (80.4 km / 42.5 knots), but a maximum ocean depth of only 300 feet (91.5 m).',
   'Height 7 feet (2.1 m), not including the rail gun which adds another two feet (0.6 m) for an overall 9 feet (2.7 m). Width 5 feet 6 inches (1.7 m). Length 23 feet (7 m) including the heavy ram prow.',
   '3.1 tons',
   290, 2300000,
   'CS Cost 2.3 million credits; fair availability. NOTE: the Black Market and Northern Gun sell knock-offs of the "Scarab" Officer''s Car, complete with weapon systems, for 2.1 million credits, or 1.3 million for a rebuilt; fair availability. See Rifts World Book 11: Coalition War Campaign for other knock-offs.',
   'Model Type BAWW-120. Class: Military Transport. Supposed to be the answer to an armored assault vehicle. The basic body design and propulsion system is a KNOCK-OFF OF THE COALITION "SCARAB" OFFICER''S CAR, not that one would recognize it as such: the front "Death''s Head" design has been replaced with a large ram prow like the "cow catchers" on old style trains, and the vehicle is more heavily armored. A pair of headlights are mounted on the roof. The top and roof are flat, with a rail gun mounted on it, operated by the co-pilot or a passenger, which turns 360 degrees and has a 45 degree arc of fire. The concealed mini-missile launchers have been kept, along with the forward laser ball turrets, but the REAR LASER TURRETS HAVE BEEN REPLACED WITH ADDITIONAL JETS. Typically used as a town, fort or outpost defender, though one or two are not uncommon travelling with a 1st Cavalry column. The combination of firepower and armor makes it an excellent light combat hover vehicle, popular among the 1st Cavalry Justice Rangers, wealthy ranchers and towns as a means of defense, and also used by some mercenary companies and bandit gangs - especially large gangs and those who hold up trains. CARGO: minimal storage, about three feet (0.9 m) behind the seats for extra clothing, weapons and personal items. Power system nuclear, average cycle''s energy life 20 years. SENSORS: long and short range radio, infrared optics, and short range radar. DAMAGE NOTES: every item marked by a single asterisk is small and/or difficult to strike, requiring a called shot at -3. Destroying one of the bottom hover jets reduces speed by 10%; destroying one of the rear jets reduces speed by 20%. THE BOOK IS INTERNALLY INCONSISTENT ABOUT THE LASER TURRET COUNT: the M.D.C. block prints "Laser Turrets (2; bottom)" while the weapon entry describes two turrets and then refers to "all four turrets". Both readings are recorded as printed rather than reconciled.',
   'Rifts World Book 14: New West p.202-203'),

  ('glittermount-tw-mechanical-horse', 'Glittermount (Techno-Wizard Mechanical Horse)', 'rifts', 'robot',
   'One humanoid rider.', 'One additional rider possible in emergencies.',
   'Running maximum 80 mph (128.7 km), DOUBLE when on a ley line. Leaping 20 feet (6 m) high and 50 feet (15.2 m) lengthwise with a running start, double on a ley line.',
   'Can RUN INTO THE AIR, at double the usual speed, up to 1000 feet (305 m) high when running on a ley line.',
   'Can function in and under water, walking the sea bottom at about 25% of normal running speed or swimming at 5 mph (8 km or 4.3 knots). Maximum depth 600 feet (183 m).',
   'Height usually about 14 hands (approx. 4.8 feet / 1.4 m) at the shoulders; Glittermounts specially designed to be larger cost an additional 5% per every two hands (8 inches / 0.24 m) of additional size. Width 2.6 feet (0.8 m). Length approximately 8 feet (2.4 m).',
   '800 lbs (360 kg)',
   220, 6600000,
   '6.6 to 10 million credits depending on the seller and the needs of the market; famed champions of good or fellow mages of renown may be given a 10% discount. Generally POOR availability at most places - THE COLORADO BARONIES ARE AN EXCEPTION, where the TW horse sells for 6 million credits. Extremely popular among Techno-Wizards and Cyber-Knights, otherwise too pricey for the average cowpoke. NOTE: a destroyed head must be replaced by a Techno-Wizard at a cost of 1.5 million credits.',
   'Model Type: Glittermount. An artificial horse plated in polished silver, robotic in appearance - in many ways it resembles a suit of barding brought to life. As a Techno-Wizard construct it is made from S.D.C. materials magically transformed into mega-damage materials, and although it appears robotic its POWER SYSTEM IS MAGICAL and its internal structure defies modern science. In any bright light the horse glitters in an array of brilliant colours, and as it gallops a stream of glittering magical residue is left behind like a semitransparent stream of sparkling fireworks or a gossamer rainbow. It acts and functions much like a real horse with roughly equal intelligence and behaviour, is not as intelligent or programmed as a robot horse and cannot speak to its rider, but is obedient and dutiful; riding one requires any of the horsemanship skills. NEVER COVERED WITH FAKE FUR - the trim is often painted, rider''s choice, red, yellow, gold and black being most popular. SPECIAL FEATURES: magical rejuvenation, regenerating 5D6 M.D.C. per hour, and a destroyed leg magically regrown in 24 hours provided 240 P.P.E. is pumped into the construct; nightvision 1000 feet (305 m) and can see in total darkness, sees all spectrums of light, keen hearing, but NO sense of smell and no speech. BONDING: once a Glittermount magically bonds with a rider it never willingly leaves his side, and if the rider is slain 73% will accept a new one - there are stories of Glittermounts defending the graves of fallen riders until they wear out. To bond, the very first time the character rides the TW horse he must expend 3/4 OF HIS P.P.E. into the magical batteries; this does not power the horse, it links the two. LIMITED SPELL CASTING: globe of daylight (2 P.P.E.), blinding flash (1), turn dead (6) and levitation (5; self and rider only), all at 4th level spell strength, four spells per day, though if the rider wills it the horse can draw on HIS P.P.E. to cast more. RECHARGING: must be recharged with 120 P.P.E. every four months. Without it the construct slows down - halve speed, leaping distance, attacks per melee and all bonuses. After 10 months it slows to a crawl (Spd 6, no bonuses, cannot leap, one melee action per round) and needs a boost of 240 P.P.E.; by 12 months it shuts down completely and needs 400 P.P.E. just to get back to half speed and 600 to get back to full. NEVER LET IT GET BELOW HALF POWER. Any practitioner of magic or superhuman being with sufficient P.P.E. can recharge it, but feeding it less than 120 P.P.E. at a time is USELESS - the creation is calibrated to accept 120 or more, so nothing less works. ATTRIBUTES OF NOTE: equivalent of robot P.S. 30, P.P. 20, P.B. 12, Spd 75, equivalent I.Q. 7. CARGO: one rider and one companion, up to 1400 pounds (630 kg); it can pull up to two tons. CREATION: initial P.P.E. cost 285; spells needed Constrain Being (20), Energy Field (10), Armor of Ithan (10), Superhuman Speed (10), Globe of Daylight (2), Blinding Flash (1), Turn Dead (6), Levitation (5) and a number of secret incantations. Physically it needs mechanical components, armor plating, silver to plate the exterior armor and mechanical parts, two large rose quartz crystals for eyes (typically concealed under large saucer-like coverings), A TECTONIC ENTITY LOCKED WITHIN THE HEART, and a number of secret components; about 960 to 1100 hours to build, which is 4-8 months. NOTE: the tectonic entity inside does not consider itself enslaved or abused and enjoys its life as part of the TW mechanical horse; the magical constructions keep it controlled, obedient and focused. COMBAT: FOUR attacks per melee round; +2 on initiative, +2 to strike, +4 to dodge when running, +4 to roll with punch, fall or impact. IMPERVIOUS to cold, heat, fire, disease, poison and horror factor - it is not alive, so it does not need food, water or rest and can travel without tiring. Its magical nature and silver coated body mean it can attack and damage most supernatural beings including dragons, demons and vampires, and it does DOUBLE DAMAGE to creatures vulnerable to silver or magic. Damage: restrained hoof strike 1D4 M.D., full hoof strike 1D6 M.D., rear kick or power kick 2D6 M.D., stomp 1D4 M.D., running body block 1D4 M.D., head butt 1D4 M.D.; bite not applicable.',
   'Rifts World Book 14: New West p.218-220'),

  ('tw-ironhorse-locomotive', 'The TW Ironhorse', 'rifts', 'vehicle',
   'The engineers'' compartment typically holds as many as 8-10 people. Crew includes two engineers or pilots, typically a low level (1D4 each) Techno-Wizard and a Shifter, 2-4 assistants and helpers to the engineers, and 6-24 defenders, usually 2-4 in the locomotive and the rest scattered throughout the train.',
   'May include a cargo work staff of 10-100 people to help load and unload. If a passenger train, there is an assistant conductor for every two cars and one chief conductor for the entire train; passenger trains usually also have one or two box cars and a caboose for luggage and incidental cargo, and a dining car with a service staff of about 12-20 people.',
   'On the ground 100 mph (160.9 km), the same as in the air.',
   'Flying or on the ground 100 mph (160.9 km) with a maximum altitude of 1000 feet (305 m), though it often travels below the tree line to avoid being too obvious. Range effectively unlimited. LEY LINE STORMS reduce speed to a sluggish 1D4x10 mph, and a magical lightning bolt from such a storm knocks the Ironhorse temporarily out of commission, sending it to a crashing halt and leaving it powerless for 1D4 hours.',
   'If a ley line is present, the Ironhorse can ride ATOP THE WATER at full speed. No underwater capabilities.',
   'Height 10-15 feet (3-4.6 m) tall; the smokestack may add another 4-8 feet (1.2 to 2.4 m). Length 20-30 feet (6-9 m) long plus 5-10 feet (1.5 to 3 m) for the heavy ram prow.',
   '14-20 tons',
   640, 500000000,
   'CS Cost 500+ million credits; RARE. Ironhorses are typically owned and operated by Techno-Wizards. There are two in operation in Colorado, one in Nevada/Arizona - one of the few owned by an independent, non-magical organization, Bandito Arms - one in Wyoming, Washington and the Pecos Empire, and several in Minnesota and the Magic Zone, among others.',
   'Class: Ironhorse. NOTE THAT THE IRONHORSE IS ONLY THE LOCOMOTIVE; box cars and passenger cars are magically pulled along with it and are not part of the vehicle. Their M.D.C. is printed on the same lines as the locomotive''s own: S.D.C. box cars have 1D6x100 S.D.C. or the equivalent of 1D6 M.D. each, and M.D. box cars typically have 100 M.D.C. each. One of the greatest creations of Techno-Wizardry to come out of Tolkeen: the return of the railway. TW Ironhorses ride ALONG THE LEY LINES, drawing power both from the lines themselves and from the rage of THREE BAAL-ROG DEMONS locked inside the engine of the locomotive - in the alternative, a lesser fire and air elemental can be used, and these creatures, linked to the Ironhorse and able to move as the train, do not usually feel enslaved or imprisoned. NEXUS POINTS, where two or more ley lines intersect, are used to "switch tracks" by turning down a different line, and can also open a dimensional Rift to teleport from one ley line to a completely different one up to 300 miles (482 km) away. The portal is open for just a few seconds (2D4) and bridges space and time in the same reality rather than opening on other dimensions, so there is little risk of encountering other-dimensional beings - though outside forces (alien intelligences, gods, Splugorth) could at that exact moment alter the Rift and carry the train, cargo and passengers to another dimension, alien world, or another continent on Earth. Such occurrences are incredibly rare, under 1%. BEING LIMITED TO LEY LINES STILL LIMITS ITS RANGE, and leaps must be directed to lines that have at least one intersecting nexus or the train is stranded on a single line, incapable of teleportation. It also means TRAIN ROBBERS, COALITION TROOPS AND OTHER BRIGANDS KNOW EXACTLY WHERE THE TELEPORTATION JUNCTION IS and can set traps, ambushes and barriers there. THE TW TRAINS ARE OUTLAWED BY THE COALITION STATES and are attacked whenever they appear in the States or CS Territories, sometimes even far away - Coalition troops figure anybody riding one is an enemy, enemy sympathizer, traitor, sorcerer or D-bee and therefore a military target. The locomotive can pull as few as 2 cars or as many as 30, sealed windowless cargo box cars or passenger cars with seats and windows or a combination of both. A typical box car holds 70 to 80 tons and weighs 10 tons empty; the Ironhorse can haul up to 24,000 tons or roughly five million pounds. Cargo can be raw materials, finished products or livestock. POWER SYSTEM: magical and effectively unlimited, powered in part by the three Baal-rog demons or two minor elementals and the ambient P.P.E. of the ley lines. MAGICAL HEALING: 1D4x10 M.D.C. can be restored to the locomotive for every 100 P.P.E. pumped into it, and ley line energy restores M.D.C. at a rate of 5D6 per day, a slow process. DANGER: depleting the main body completely destroys the vehicle and UNLEASHES THE BEINGS CONTAINED INSIDE - elementals are likely to lash out for 1D6 minutes before vanishing, but the Baal-rog demons will seek revenge on the train''s operators and defenders and anybody who dares to challenge or annoy them, and they are not compelled to leave Earth. Worse, after 80% of the M.D.C. has been depleted there is a 01-50% chance the Baal-rogs break loose and escape, rendering the Ironhorse without power and severely damaged - 4D6 weeks of repair at a cost of 1D4x10 million credits. Only a 01-30% chance of elementals escaping. BONUSES: +1 on initiative, +2 to strike, +2 to dodge, +2 to roll with impact, crash or fall. The locomotive is IMPERVIOUS TO HEAT AND FIRE, including M.D. plasma and magic fire; however, cold based attacks (typically magical), rune weapons and Millennium Tree weapons do DOUBLE their normal damage. CREATION: P.P.E. cost 9,540; spells too numerous to list but including protection circle for the engineers, dimensional portal and restoration. Physically it needs mechanical components, armor plating, wheels, struts and engine for the locomotive, several expensive crystals, and either three Baal-rog demons or one lesser fire and air elemental; the supernatural forces are magically and physically bound to the Ironhorse and cannot escape unless it is severely damaged, or attack and cause trouble. About 3700 to 4000 hours to build, which is 12-18 months.',
   'Rifts World Book 14: New West p.220-223');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('rh-1001a-appaloosa-light-robot-horse', 'Head',      80, 'Destruction of the head shuts the bot down.', 1),
  ('rh-1001a-appaloosa-light-robot-horse', 'Legs (4)',  80, 'Each. Destroying one leg will hobble the robot and reduce speed and leaping distance and height by 33%.', 2),
  ('rh-1001a-appaloosa-light-robot-horse', 'Main Body', 200, 'Destruction of the main body will destroy the bot.', 3),

  ('rh-1002b-mustang-medium-robot-horse', 'Head',      100, 'Destruction of the head shuts the bot down.', 1),
  ('rh-1002b-mustang-medium-robot-horse', 'Legs (4)',  100, 'Each. Destroying one leg will hobble the robot and reduce speed and leaping distance and height by 33%.', 2),
  ('rh-1002b-mustang-medium-robot-horse', 'Main Body', 250, 'Destruction of the main body will destroy the bot.', 3),

  ('rh-1003c-arabian-robot-horse', 'Head',      100, 'Destruction of the head shuts the bot down.', 1),
  ('rh-1003c-arabian-robot-horse', 'Legs (4)',   90, 'Each. Destroying one leg will hobble the robot and reduce speed and leaping distance and height by 33%.', 2),
  ('rh-1003c-arabian-robot-horse', 'Main Body', 240, 'Destruction of the main body will destroy the bot. NOTE that the Arabian is the fastest robot horse and NOT the best armoured - its main body is 10 points under the Mustang''s.', 3),

  ('rh-1004d-war-horse-heavy-robot-horse', 'Head',      150, 'Destruction of the head shuts the bot down.', 1),
  ('rh-1004d-war-horse-heavy-robot-horse', 'Legs (4)',  150, 'Each. Destroying one leg will hobble the robot and reduce speed and leaping distance and height by 33%.', 2),
  ('rh-1004d-war-horse-heavy-robot-horse', 'Main Body', 350, 'Destruction of the main body will destroy the bot. The best armoured robot horse by a wide margin.', 3),

  ('k-9r-1100-bandit-k-9-companion', 'Head',       50, 'Destruction of the head shuts the bot down.', 1),
  ('k-9r-1100-bandit-k-9-companion', 'Legs (4)',   50, 'Each. Destroying one leg will hobble the robot and reduce speed and leaping distance and height by 33%.', 2),
  ('k-9r-1100-bandit-k-9-companion', 'Main Body', 120, 'Destruction of the main body will destroy the bot.', 3),

  ('bronco-scooter', 'Lower "Hoof Jets" (4)',              40, 'A small target: called shot at -4 to strike. The book prints "40" with no "each", where the very next line says "4 each", so the figure is recorded exactly as printed rather than multiplied.', 1),
  ('bronco-scooter', 'Forward Directional Jets (4; concealed)', 4, 'Each. A small target: called shot at -4.', 2),
  ('bronco-scooter', 'Forward Headlights (2; eyes)',        2, 'Each. A small target: called shot at -4.', 3),
  ('bronco-scooter', 'Main Body',                         110, 'Add 30% to all M.D.C. for the deluxe, armored model, but also add 30% to the cost.', 4),

  ('baww-120-cavalry-war-wagon', 'Light Rail Gun (1; roof top)',          70, 'A small target: called shot at -3 to strike.', 1),
  ('baww-120-cavalry-war-wagon', 'Laser Turrets (2; bottom)',             50, 'Each. A called shot at -3. The weapon entry describes two turrets and then refers to "all four turrets"; the book disagrees with itself and both readings are recorded as printed.', 2),
  ('baww-120-cavalry-war-wagon', 'Mini-Missile Launchers (2)',            50, 'Each. A called shot at -3.', 3),
  ('baww-120-cavalry-war-wagon', 'Front Windshield (1)',                  40, NULL, 4),
  ('baww-120-cavalry-war-wagon', 'Rear Windshield (1)',                   40, NULL, 5),
  ('baww-120-cavalry-war-wagon', 'Side Windows (4)',                      20, 'Each.', 6),
  ('baww-120-cavalry-war-wagon', 'Doors (4)',                             70, 'Each.', 7),
  ('baww-120-cavalry-war-wagon', 'Headlights (2)',                        15, 'Each. Mounted on the roof.', 8),
  ('baww-120-cavalry-war-wagon', 'Bottom Hover Jets (5)',                 50, 'Each. A called shot at -3. Destroying one reduces speed by 10%.', 9),
  ('baww-120-cavalry-war-wagon', 'Rear Ball Jets (2; in place of rear ball lasers)', 50, 'Each. These replaced the Scarab''s rear laser turrets.', 10),
  ('baww-120-cavalry-war-wagon', 'Rear Jets (3)',                         50, 'Each. Destroying one reduces speed by 20%.', 11),
  ('baww-120-cavalry-war-wagon', 'Ram Prow (1; large)',                  130, 'The "cow catcher" that replaced the Scarab''s Death''s Head design.', 12),
  ('baww-120-cavalry-war-wagon', 'Main Body',                            290, 'Depleting the M.D.C. of the main body completely destroys the vehicle.', 13),

  ('glittermount-tw-mechanical-horse', 'Head',      100, 'A small target: called shot at -3 to strike. Destruction of the head shuts it down, and THE HEAD MUST BE REPLACED BY A TECHNO-WIZARD at a cost of 1.5 million credits.', 1),
  ('glittermount-tw-mechanical-horse', 'Legs (4)',  100, 'Each. A called shot at -3. Destroying one leg will hobble the Glittermount and reduce speed, leaping distance and height by 33%. A destroyed leg can be magically REGROWN in 24 hours provided 240 P.P.E. is pumped into the construct.', 2),
  ('glittermount-tw-mechanical-horse', 'Main Body', 220, 'Complete destruction of the main body will destroy the magical construct and FREE THE TECTONIC ENTITY bound inside it.', 3),

  ('tw-ironhorse-locomotive', 'Windows (4-6)',                                  15, 'Each. A small target: called shot at -3 to strike.', 1),
  ('tw-ironhorse-locomotive', 'Doors (2; on the sides)',                        80, 'Each. A called shot at -3.', 2),
  ('tw-ironhorse-locomotive', 'Sliding Door (1; large, in the rear of locomotive)', 125, 'A called shot at -3.', 3),
  ('tw-ironhorse-locomotive', 'Emergency Exit (1; small; in ceiling/roof)',   NULL, 'THE BOOK PRINTS NO FIGURE. Printed 222 ends this line with the dash and no number, the same shape as the RUE Highway Man''s tires. Nothing is guessed from its neighbours. A small target: called shot at -3.', 4),
  ('tw-ironhorse-locomotive', 'Headlights (4; front)',                          10, 'Each. A called shot at -3.', 5),
  ('tw-ironhorse-locomotive', 'Spotlight (1-2; optional)',                      15, 'Each. A called shot at -3.', 6),
  ('tw-ironhorse-locomotive', 'Large Wheels (2-4)',                            100, 'Each. Destroying 1-4 of the wheels has NO effect on the locomotive. Destroying 6 or 8 reduces speed and bonuses by 25% - yes, even when flying in the air; TW devices have a certain logic to them, and here moving wheels are a necessary component of travel on the ground AND in the air. Destroying all or most reduces speed and bonuses by half.', 7),
  ('tw-ironhorse-locomotive', 'Small Wheels (12-20)',                           50, 'Each. A small target: called shot at -3. See the large wheels for the effect of destroying them.', 8),
  ('tw-ironhorse-locomotive', 'Smokestacks (1-4)',                              80, 'Each. The smoke is actually from the fire of the Baal-rogs or fire elemental that powers the vehicle.', 9),
  ('tw-ironhorse-locomotive', 'Ram Prow/Cattle-Catcher (1; large)',             450, NULL, 10),
  ('tw-ironhorse-locomotive', 'Main Body',                                      640, 'Depleting the M.D.C. of the main body completely destroys the vehicle and UNLEASHES THE BEINGS CONTAINED INSIDE. After 80% has been depleted there is a 01-50% chance the Baal-rogs break loose (01-30% for elementals), rendering it powerless and severely damaged: 4D6 weeks of repair at a cost of 1D4x10 million credits.', 11);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('baww-120-cavalry-war-wagon', 1, 'C-40BT Laser Turrets (2)',
   '4D6 M.D. per double blast from one turret, or 8D6 M.D. per simultaneous dual blasts from two turrets', 1,
   '2000 feet (610 m)',
   'Equal to the number of hand to hand attacks per melee round of the pilot or gunner (usually 4 to 6).',
   'Effectively unlimited.', NULL,
   'Two double barrel lasers built into ball turrets located in the front corners of the car where the wheel would be on a normal car. Each is capable of 180 degree rotation and arc of fire. Primary purpose anti-personnel; secondary defense. ALL FOUR TURRETS CANNOT FIRE IN TANDEM - the book says "all four turrets" here while its M.D.C. block prints two; both are recorded as printed.'),
  ('baww-120-cavalry-war-wagon', 2, 'CR-10 Concealed Mini-Missile Launcher (2)',
   'Varies with missile type. Standard issue is fragmentation (anti-personnel, 5D6 M.D.) and plasma (1D6x10 M.D.), but any type of mini-missile can be used.', 1,
   'About one mile.',
   'One at a time or in volleys of two, three, four or five.',
   'Twenty; ten missiles in each launcher.', NULL,
   'A pair of mini-missile launchers mounted on the sides of the vehicle. Primary purpose anti-personnel; secondary anti-armor. These were kept from the Coalition "Scarab" Officer''s Car the vehicle is a knock-off of.'),
  ('baww-120-cavalry-war-wagon', 3, 'Light Rail Gun',
   'A burst is 30 rounds and inflicts 6D6 M.D.; one round does 1D4 M.D.', 1,
   '4000 feet (1220 m)',
   'Equal to the number of combined hand to hand attacks (usually 4-6).',
   '2400 rounds, that is 80 bursts. The ammo compartment is inside the vehicle.', NULL,
   'Located on the roof of the vehicle with 360 degree rotation and a 45 degree arc of fire, operated by the co-pilot or a passenger. Primary purpose anti-personnel; secondary defense. The gun itself weighs 90 lbs (40.8 kg).'),

  ('glittermount-tw-mechanical-horse', 1, 'Energy Bolt Eyes',
   '2D6 M.D. per blast', 1, '500 feet (152 m)',
   'Twice per melee round; each blast counts as one attack.',
   'Effectively unlimited.', NULL,
   'The eyes can fire blasts of energy equivalent to a light ion blast, though the energy is MAGICAL in nature. Primary purpose defense.'),
  ('glittermount-tw-mechanical-horse', 2, 'Magic Spells',
   'By spell. Globe of daylight (2 P.P.E.), blinding flash (1), turn dead (6) and levitation (5; self and rider only).', 0,
   'By spell.',
   'Four spells per day (24 hours), or more if the rider wills it and lends his own P.P.E.',
   'Four per day from the construct''s own reserve.', NULL,
   'All spells are cast at the equivalent of 4th level. The limited spells are not devastating magic but have combat applications: blinding flash startles, confuses or temporarily blinds an opponent or pursuers, globe of daylight can reap havoc with vampires and blind other nocturnal creatures, and turn dead has its obvious use.'),

  ('tw-ironhorse-locomotive', 1, 'Fire Bolt or Fire Balls (2)',
   '1D6x10 M.D. per double blast, which automatically unleashes two fire balls', 1,
   '1000 feet (305 m)',
   'As often as twice per melee round.',
   'Effectively unlimited.', NULL,
   'Fire bolts of magical energy fired either from the eyes of the locomotive or from the mouth. It can only fire in the direction the Ironhorse faces, although the engine can momentarily point in a 30 degree arc of fire, side to side and up and down, without getting off course. Primary purpose defense.'),
  ('tw-ironhorse-locomotive', 2, 'Additional Weapon Systems (up to four)',
   'By the system fitted.', 1, NULL, NULL, NULL, NULL,
   'Weapons and defenses vary from manufacturer to manufacturer and often reflect the needs of the owner and the level of hostility in the territory it travels. LASER TURRETS, RAIL GUNS AND MISSILE LAUNCHERS ARE MOST COMMON. A total of FOUR different weapon systems can be built into the locomotive, and as many as two on each boxcar or caboose - however, boxcars are generally considered expendable and rarely have weapons built into them.');

-- INSERT OR IGNORE is SILENT on a collision, so these COUNT. Every want is
-- counted off the VALUES lists in THIS FILE.

-- Counted by SLUG, not by a source_book LIKE. The first version of this
-- assertion used '%New West p.19%' and returned 12, because the PREVIOUS vessel
-- batch cites p.189-191, p.191-192, p.192-193 and p.193-195 - a page-range
-- pattern is not a batch boundary when two batches meet inside the same
-- hundred.
SELECT 'the nine vessels' AS assertion, count(*) AS got, 9 AS want
  FROM vehicles WHERE slug IN
    ('rh-1001a-appaloosa-light-robot-horse','rh-1002b-mustang-medium-robot-horse',
     'rh-1003c-arabian-robot-horse','rh-1004d-war-horse-heavy-robot-horse',
     'k-9r-1100-bandit-k-9-companion','bronco-scooter','baww-120-cavalry-war-wagon',
     'glittermount-tw-mechanical-horse','tw-ironhorse-locomotive');

SELECT 'the four robot horses, not three' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE slug LIKE 'rh-100%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 46 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IN ('rh-1001a-appaloosa-light-robot-horse','rh-1002b-mustang-medium-robot-horse',
                   'rh-1003c-arabian-robot-horse','rh-1004d-war-horse-heavy-robot-horse',
                   'k-9r-1100-bandit-k-9-companion','bronco-scooter','baww-120-cavalry-war-wagon',
                   'glittermount-tw-mechanical-horse','tw-ironhorse-locomotive');

SELECT 'their weapon entries' AS assertion, count(*) AS got, 7 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.slug IN ('baww-120-cavalry-war-wagon','glittermount-tw-mechanical-horse','tw-ironhorse-locomotive');

-- The one location the book does not print a figure for. Asserted by value so
-- a later backfill cannot quietly invent one.
SELECT 'the Ironhorse emergency exit has no printed figure' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_locations
  WHERE vehicle_slug = 'tw-ironhorse-locomotive' AND mdc IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-nw-vessels-p196-223.sql');
