-- Tag every skill with the games whose books print it (skills.systems).
--
-- THIS REVERSES A SETTING DECISION, ON PURPOSE AND ON NATE'S WORD (2026-09-18).
-- untag-cross-system.sql (PR #62) set skills.systems NULL on every row because
-- Rifts and Palladium Fantasy share a multiverse. That was written when the
-- catalog held two games; Nightbane and Heroes Unlimited arrived later, the
-- wizard has never let a class cross into another game's build (it filters
-- classes on system), and the result was that every skill was offered in every
-- game - a Palladium Fantasy mercenary could pick W.P. Heavy Military Weapons.
-- The psionic half of the same decision was already partly reversed by
-- zzzzzzzzzzzzzzz-retag-game-psionics.sql.
--
-- THE RULE, per skill and per game. A skill is IN a game when any of:
--   - a live published class of that game names it in its frontmatter (a
--     fixed grant, a choice option, an only or except list, an M.O.S. or
--     skill program), following catalog_redirects for renamed skills;
--   - the game's core skill list prints it: RUE printed 302, Palladium
--     Fantasy printed 49, Nightbane printed 48, Heroes Unlimited printed 27-28;
--   - skill_system_bases holds a base for it in that game;
--   - its source_book is that game's book. source_book only ever ADDS a game.
--     untag-cross-system.sql's warning about tagging FROM source_book stands:
--     118 skills cite RUE p.302-303 alone, including ones Palladium Fantasy
--     prints too.
-- A skill in all four games stays NULL, which the wizard reads as every game.
--
-- Decisions taken with it (the proposal is in the PR that adds this file):
--   - skills in three of the four games are tagged with those three;
--   - Hunting and Locksmith leave Palladium Fantasy, whose own list prints
--     Track & Trap Animals and Pick Locks instead - accepted;
--   - two corrections read off the page: Interrogation Techniques is printed
--     by Juicer Uprising (printed 64-66) and New West (printed 71-73), so it
--     gains rifts; W.P. Heavy M.D. Weapons matched Nightbane's "W.P. Heavy" by
--     prefix, and Nightbane has no M.D. weapons, so it is rifts alone.
--
-- WHY THE NAME SORTS LAST. untag-cross-system.sql and
-- fix-pf-armor-and-cross-system-gear.sql both end in
--   UPDATE skills SET systems = NULL WHERE systems IS NOT NULL;
-- naming no row, so on a clean rebuild - one sorted glob, filename order as
-- execution order - they clear any tag set before them. This file has to run
-- after both, and after every file that inserts a skill.
--
-- Keyed on name, never id. Guarded on systems IS NULL, so a row somebody has
-- deliberately tagged since is left alone and a re-run is a no-op.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzzz-tag-skill-systems.sql

-- ["rifts"]: 168
UPDATE skills SET systems = '["rifts"]'
 WHERE systems IS NULL
   AND name IN (
    'Advanced Deep Sea Diving',
    'Advanced Fishing',
    'Aerobic Athletics',
    'Air Assault Armor',
    'Antiquarian',
    'Appraise Goods',
    'Artificial Intelligence',
    'Barter',
    'Bicycling',
    'Bioware Mechanics',
    'Boat: Paddle Types/Canoe/Kayak',
    'Boat: Submersibles',
    'Branding',
    'Breaking/Taming Wild Horse',
    'Brewing: Medicinal',
    'Calligraphy',
    'Chemistry: Pharmaceutical',
    'Combat Driving',
    'Combat Pod',
    'Crime Scene Investigation',
    'Cyberjacking',
    'Cybernetic Medicine',
    'Cybernetics: Basic',
    'Deadball',
    'Demolitions: Underwater',
    'Doctor of Veterinary Medicine',
    'Electricity Generation',
    'Electronic Countermeasures',
    'Entomological Medicine',
    'Excavation',
    'Fighter Combat: Basic',
    'Fighter Combat: Elite',
    'Find Contraband',
    'Firefighting',
    'Flight System Combat',
    'Gambling (Dirty Tricks)',
    'Gambling (Standard)',
    'Gardening',
    'Geology',
    'Herding Cattle',
    'History of the West',
    'History: Post-Apocalypse',
    'History: Pre-Rifts',
    'Horsemanship: Cossack',
    'Horsemanship: Cowboy',
    'Horsemanship: Cyber-Knight',
    'Horsemanship: Equestrian',
    'Housekeeping',
    'Hovercycles, Skycycles & Rocket Bikes',
    'I.D. Undercover Agent',
    'Ice Skating',
    'Imitate Voices & Sounds',
    'Juicer Football',
    'Juicer Technology',
    'Jump Bike Combat',
    'Jury-Rig',
    'Kick Boxing',
    'Language Dialects',
    'Law',
    'Law: CCW',
    'Leather Working',
    'Literacy: Euro',
    'Literacy: Gypsy',
    'Literacy: Russian',
    'Lore: American Indians',
    'Lore: Cattle & Animals',
    'Lore: D-Bee',
    'Lore: Galactic/Alien',
    'Lore: Juicers',
    'Lore: Wormwood',
    'M.D. in Cybernetics',
    'Marine Biology',
    'Metalwork and Forge',
    'Military Fortification',
    'Military: Submersibles',
    'Military: Warships & Patrol Boats',
    'Mining',
    'Murderthon',
    'Mythology',
    'NBC Warfare',
    'Naval History',
    'Naval Tactics',
    'Navigation: Terrestrial',
    'Navigation: Underwater',
    'No Hand to Hand Combat Skill',
    'Ocean Geographic Surveying',
    'Outdoorsmanship',
    'Parachuting',
    'Performance',
    'Philosophy',
    'Physical Labor',
    'Physics',
    'Professional Restoration',
    'Prospecting',
    'Psychology',
    'Radar/Sonar Operations',
    'Recognize Authenticity',
    'Recognize Machine Quality',
    'Recycle',
    'Recycling',
    'Roadwise',
    'Robot Combat Elite',
    'Robot Combat Elite: Glitter Boy',
    'Robot Combat Elite: SAMAS',
    'Robot Combat Elite: T-31 Super Trooper',
    'Robot Combat Elite: X-1000 Ulti-Max',
    'Robot Combat Elite: X-10A Predator',
    'Robot Combat Elite: X-2000 Dyna-Max',
    'Robot Combat Elite: X-2500 Black Knight',
    'Robot Combat Elite: X-500 Forager',
    'Robot Combat Elite: X-535 Jager',
    'Robot Combat Elite: X-545 Super Jager',
    'Robot Combat Elite: X-60 Flanker',
    'Robot Combat: Basic',
    'Robots & Power Armor',
    'Roping',
    'SCUBA',
    'Safe-Cracking',
    'Salvage',
    'Sculpt, Carve & Whittle Wood',
    'Sea Holistic Medicine',
    'Seduction',
    'Sense of Balance',
    'Shape, Engrave, Etch & Emboss Metal',
    'Snow Skiing',
    'Space: Antigrav Suit',
    'Space: Contragravity Pak',
    'Space: Defense Systems',
    'Space: Extra-Vehicular Activity',
    'Space: Oxygen Conservation',
    'Space: Radio: Deep Space',
    'Space: Satellite Systems',
    'Space: Space Fighter',
    'Space: Spacecraft Mechanics',
    'Space: Starship',
    'Space: Zero Gravity Movement & Combat',
    'Spelunking',
    'Submersible Vehicle Mechanics',
    'Tailing',
    'Track & Hunt Sea Animals',
    'Tracked & Construction Vehicles',
    'Trap Construction',
    'Trap/Mine Detection',
    'Trick Riding',
    'Undercover Ops',
    'Undersea & Sea Survival',
    'Undersea Farming',
    'Undersea Salvage',
    'Vehicle Armorer',
    'Veterinary Science',
    'W.P. Axe',
    'W.P. Bola',
    'W.P. Deadball',
    'W.P. Handguns',
    'W.P. Harpoon & Spear Gun',
    'W.P. Heavy M.D. Weapons',
    'W.P. Quick Draw',
    'W.P. Rope',
    'W.P. Sharpshooting',
    'W.P. Shotgun',
    'W.P. Tomahawk',
    'W.P. Trident',
    'Wardrobe & Grooming',
    'Water Scooters',
    'Water Skiing & Surfing',
    'Wingrider Flying Wing',
    'Xenology',
    'Zoology'
  );

-- ["rifts","nightbane","heroes-unlimited"]: 38
UPDATE skills SET systems = '["rifts","nightbane","heroes-unlimited"]'
 WHERE systems IS NULL
   AND name IN (
    'Aircraft Mechanics',
    'Airplane',
    'Automobile',
    'Automotive Mechanics',
    'Basic Electronics',
    'Basic Mechanics',
    'Boat: Motor, Race & Hydrofoil',
    'Boat: Sail Type',
    'Chemistry',
    'Chemistry ' || char(8212) || ' Analytical',
    'Computer Hacking',
    'Computer Operation',
    'Computer Programming',
    'Computer Repair',
    'Demolitions',
    'Demolitions Disposal',
    'Electrical Engineer',
    'Forensics',
    'Helicopter',
    'Jet Aircraft',
    'Locksmith',
    'Mechanical Engineer',
    'Motorcycles & Snowmobiles',
    'Optic Systems',
    'Paramedic',
    'Pathology',
    'Photography',
    'Radio: Basic',
    'Radio: Scramblers',
    'Sensory Equipment',
    'T.V./Video',
    'Truck',
    'W.P. Automatic Pistol',
    'W.P. Automatic and Semi-automatic Rifles',
    'W.P. Heavy Military Weapons',
    'W.P. Revolver',
    'W.P. Submachine-Gun',
    'Weapon Systems'
  );

-- ["rifts","palladium-fantasy"]: 38
UPDATE skills SET systems = '["rifts","palladium-fantasy"]'
 WHERE systems IS NULL
   AND name IN (
    'Animal Husbandry',
    'Astronomy & Navigation',
    'Begging',
    'Breed Dogs',
    'Brewing',
    'Camouflage',
    'Cardsharp',
    'Dowsing',
    'Falconry',
    'Fasting',
    'Field Armorer & Munitions Expert',
    'Field Surgery',
    'Forced March',
    'Gemology',
    'General Repair & Maintenance',
    'History',
    'Horsemanship: Exotic Animals',
    'Horsemanship: Knight',
    'Literacy: Dragonese/Elven',
    'Locate Secret Compartments',
    'Lore: Astral',
    'Lore: Dimensions',
    'Lore: Faeries & Creatures of Magic',
    'Lore: Magic',
    'Lore: Psychics & Psionics',
    'Masonry',
    'Public Speaking',
    'Recognize Enchantment',
    'Recognize Wards, Runes & Circles',
    'Rope Works',
    'Sign Language',
    'Ventriloquism',
    'W.P. Forked',
    'W.P. Grappling Hook',
    'W.P. Lance',
    'W.P. Shield',
    'W.P. Spear',
    'Whittling & Sculpting'
  );

-- ["rifts","heroes-unlimited"]: 34
UPDATE skills SET systems = '["rifts","heroes-unlimited"]'
 WHERE systems IS NULL
   AND name IN (
    'Astrophysics',
    'Fencing',
    'Language: Ancient Greek',
    'Language: Brodkil',
    'Language: Chinese',
    'Language: Demongogian',
    'Language: Dolphin/Whale',
    'Language: Dwarven',
    'Language: Euro',
    'Language: Gargoyle',
    'Language: Gobblely',
    'Language: Gypsy',
    'Language: Mongolian',
    'Language: Old Norse',
    'Language: Russian',
    'Language: Spanish',
    'Language: Trade Five/Reptile',
    'Language: Trade Four',
    'Language: Trade One',
    'Language: Trade Six',
    'Language: Trade Three',
    'Language: Trade Two',
    'Language: Troll/Giant',
    'Laser Communications',
    'Military: Combat Helicopter',
    'Military: Jet Fighters',
    'Military: Tanks & APCs',
    'Navigation: Stellar',
    'Robot Electronics',
    'Robot Mechanics',
    'Space: Small Spacecraft',
    'W.P. Energy Pistol',
    'W.P. Energy Rifle',
    'W.P. Rifles'
  );

-- ["rifts","palladium-fantasy","nightbane"]: 19
UPDATE skills SET systems = '["rifts","palladium-fantasy","nightbane"]'
 WHERE systems IS NULL
   AND name IN (
    'Anthropology',
    'Archaeology',
    'Astronomy',
    'Boat Building',
    'Carpentry',
    'Holistic Medicine',
    'Horsemanship: General',
    'Interrogation Techniques',
    'Lore: Demons & Monsters',
    'Lore: Religion',
    'Lore: Vampires',
    'Military Etiquette',
    'Play Musical Instrument',
    'Preserve Food',
    'Sewing',
    'Skin & Prepare Animal Hides',
    'Streetwise',
    'W.P. Pole Arm',
    'W.P. Whip'
  );

-- ["rifts","nightbane"]: 13
UPDATE skills SET systems = '["rifts","nightbane"]'
 WHERE systems IS NULL
   AND name IN (
    'Boat: Ships',
    'Hand to Hand: Commando',
    'Hover Craft (ground)',
    'Hunting',
    'Jet Packs',
    'Lore: Nightbane',
    'Lore: Nightlands',
    'Research',
    'Streetwise: Drugs',
    'W.P. Bolt Action Rifle',
    'W.P. Military Flamethrowers',
    'W.P. Torpedo',
    'Weapons Engineer'
  );

-- ["heroes-unlimited"]: 10
UPDATE skills SET systems = '["heroes-unlimited"]'
 WHERE systems IS NULL
   AND name IN (
    'Building Super Vehicles',
    'Disguise Scent',
    'Feign Death',
    'Hot Wiring',
    'Make and Modify Weapons',
    'Modify Weapon Cartridges',
    'Radio: Satellite Relay',
    'Recognize Quality and Complexity of Electrical Systems',
    'Recognize Vehicle Quality',
    'The Cleansing Spirit'
  );

-- ["rifts","palladium-fantasy","heroes-unlimited"]: 9
UPDATE skills SET systems = '["rifts","palladium-fantasy","heroes-unlimited"]'
 WHERE systems IS NULL
   AND name IN (
    'Creative Writing',
    'Identify Plants & Fruit',
    'Impersonation',
    'Juggling',
    'Recognize Weapon Quality',
    'Track & Trap Animals',
    'W.P. Paired Weapons',
    'W.P. Staff',
    'W.P. Targeting'
  );

-- ["palladium-fantasy"]: 3
UPDATE skills SET systems = '["palladium-fantasy"]'
 WHERE systems IS NULL
   AND name IN (
    'Heraldry',
    'Horsemanship: Palladin',
    'Recognize Magic'
  );

-- ["nightbane"]: 3
UPDATE skills SET systems = '["nightbane"]'
 WHERE systems IS NULL
   AND name IN (
    'Lore: Geomancy or Lines of Power',
    'Strategy/Tactics',
    'Toxicology'
  );

-- ["palladium-fantasy","nightbane"]: 1
UPDATE skills SET systems = '["palladium-fantasy","nightbane"]'
 WHERE systems IS NULL
   AND name IN (
    'Language: All (magical)'
  );

-- ASSERTIONS.

SELECT 'skills tagged ["rifts"]' AS assertion, count(*) AS got, 168 AS want
  FROM skills WHERE systems = '["rifts"]';

SELECT 'skills tagged ["rifts","nightbane","heroes-unlimited"]' AS assertion, count(*) AS got, 38 AS want
  FROM skills WHERE systems = '["rifts","nightbane","heroes-unlimited"]';

SELECT 'skills tagged ["rifts","palladium-fantasy"]' AS assertion, count(*) AS got, 38 AS want
  FROM skills WHERE systems = '["rifts","palladium-fantasy"]';

SELECT 'skills tagged ["rifts","heroes-unlimited"]' AS assertion, count(*) AS got, 34 AS want
  FROM skills WHERE systems = '["rifts","heroes-unlimited"]';

SELECT 'skills tagged ["rifts","palladium-fantasy","nightbane"]' AS assertion, count(*) AS got, 19 AS want
  FROM skills WHERE systems = '["rifts","palladium-fantasy","nightbane"]';

SELECT 'skills tagged ["rifts","nightbane"]' AS assertion, count(*) AS got, 13 AS want
  FROM skills WHERE systems = '["rifts","nightbane"]';

SELECT 'skills tagged ["heroes-unlimited"]' AS assertion, count(*) AS got, 10 AS want
  FROM skills WHERE systems = '["heroes-unlimited"]';

SELECT 'skills tagged ["rifts","palladium-fantasy","heroes-unlimited"]' AS assertion, count(*) AS got, 9 AS want
  FROM skills WHERE systems = '["rifts","palladium-fantasy","heroes-unlimited"]';

SELECT 'skills tagged ["palladium-fantasy"]' AS assertion, count(*) AS got, 3 AS want
  FROM skills WHERE systems = '["palladium-fantasy"]';

SELECT 'skills tagged ["nightbane"]' AS assertion, count(*) AS got, 3 AS want
  FROM skills WHERE systems = '["nightbane"]';

SELECT 'skills tagged ["palladium-fantasy","nightbane"]' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE systems = '["palladium-fantasy","nightbane"]';

-- The four-game set, left NULL on purpose.
SELECT 'skills every game offers stay NULL' AS assertion, count(*) AS got, 54 AS want
  FROM skills WHERE systems IS NULL;

SELECT 'nothing is tagged with a value this file did not write' AS assertion, count(*) AS got, 0 AS want
  FROM skills WHERE systems IS NOT NULL AND systems NOT IN ('["rifts"]', '["rifts","nightbane","heroes-unlimited"]', '["rifts","palladium-fantasy"]', '["rifts","heroes-unlimited"]', '["rifts","palladium-fantasy","nightbane"]', '["rifts","nightbane"]', '["heroes-unlimited"]', '["rifts","palladium-fantasy","heroes-unlimited"]', '["palladium-fantasy"]', '["nightbane"]', '["palladium-fantasy","nightbane"]');

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzz-tag-skill-systems.sql');
