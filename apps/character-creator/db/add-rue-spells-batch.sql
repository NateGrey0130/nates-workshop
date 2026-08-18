-- One hundred and twelve spell rows from the Rifts Ultimate Edition
-- invocations chapter: 110 the catalog did not carry, plus two the book
-- corrects (Cloud of Smoke is level 1 here, Befuddle costs 6). Extracted
-- through the session importer (session 908, six overlapping page-range
-- passes) and confirmed after review.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/add-rue-spells-batch.sql
--
-- PARTIAL CHAPTER, deliberately: the upstream model declined to produce
-- output for the chapter's last two page ranges (content filtering), so
-- coverage runs through roughly spell level ten. The remaining entries can
-- be added by hand through the catalog editor.
--
-- Twenty-five rows the extraction staged without a level (the chapter states
-- levels as running headings, which a chunk can open without) were resolved
-- by two independent means that agreed: interpolation over the strictly
-- level-ordered staging sequence, and a levels-only read of the pages.
--
-- Manipulate Objects keeps ppe 0: its entry prices the cost by a schedule
-- with no single figure, and spells have no cost-note column yet (the
-- psionic_powers.isp_note precedent, migration 020, is the shape to copy if
-- one is wanted).
--
-- ON CONFLICT (name) DO UPDATE rather than INSERT OR IGNORE, deliberately:
-- the environment this was reviewed in already holds the rows, and the
-- upsert makes this script the authoritative bytes in both environments.
-- Pure ASCII on purpose - em-dashes and curly quotes through `wrangler d1
-- execute` on Windows have produced mojibake before.

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Cloud of Smoke', 1, 2, NULL, '90 feet (27.4 m)', 'Four melees (one minute) per level of experience', NULL, 'None', NULL, NULL, 'This magic enables the mage to create a cloud of dense, black smoke (30x30x30 feet/9x9x9 meter maximum size) up to ninety feet (27.4 m) away. Victims caught in the cloud will be unable to see anything beyond the cloud, and their impaired vision allows them to see no more than three feet (0.9 m) within the cloud, and even then that means only blurry shapes. While in the cloud, victims are -5 to strike, parry, dodge, disarm and entangle.', 'seed', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Death Trance', 1, 1, NULL, 'Self only', '10 melee rounds (two and a half minutes) per level of experience', NULL, 'None', NULL, NULL, 'A magically induced trance which makes the mage caster appear to be dead. There is no breathing, pulse, heartbeat, or any other signs of life. While in the trance, the mage is quite helpless, unable to speak, move or invoke magic. Only minor physical sensations felt by the character are recognizable, like being jostled, carried or hearing voices, but no specific identification or memories are possible. The magic can be canceled at will at any time.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('See Aura', 1, 6, NULL, '100 feet (30.5 m)', 'One melee', NULL, 'None. Only the psychic powers of Mind Block or Alter Aura will mask the presence of psychic abilities, the level of P.P.E., or possession', NULL, NULL, 'All things, organic and inorganic, have an aura. The aura has many features and distinctions, and can be used to see or sense things invisible to the eye. Seeing an aura will indicate the following: Estimate the general level of experience. Low (1-3), medium (4-7), high (8th and up). The presence of magic (no indication of what, or power level). The presence of psychic abilities. Low (Minor) or high (Major or Master). High or low base P.P.E. The presence of a possessing entity (does not indicate Psychic Possession or mind control). The presence of an unusual human aberration which indicates a serious illness or that the character is not human and may be a mutant, D-Bee, or demon, but does not reveal which. Note: One can not use this spell to determine another character''s alignment.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('See the Invisible', 1, 4, NULL, '200 feet (61 m)', 'One minute (4 melee rounds) per each level of experience', NULL, 'None', NULL, NULL, 'The character can see Astral beings, entities, Elementals, ghosts, objects, forces and creatures that can turn invisible or are naturally invisible. Even if the creature has no form per se, the mystic will be able to discern the vaporous image or energy sphere that is the being.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Befuddle', 2, 6, NULL, '100 feet (30.5 m)', 'Two minutes (8 melees) per level of experience', NULL, 'Standard', NULL, NULL, 'An enchantment that temporarily causes its victim to become confused and disoriented. Concentration and reactions are impaired. Those affected are -2 to strike, parry and dodge; attacks per melee are reduced by half and all skills suffer a penalty of -20%. Each invocation affects only one individual each time it is cast. A successful save vs magic means the intended victim suffers no impairment.', 'seed', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Cleanse', 2, 6, NULL, 'Self, one person and the clothes he''s wearing up to 10 feet (3 m) away, or two people by touch', 'Instant', NULL, 'None', NULL, NULL, 'This is a simple but useful spell designed to remove dirt and grime from the body of a living being and the clothes he wears. Magic energy flows over the person and magically removes dirt, grime, stains, and just about anything that the spell caster considers "unclean." The recipient of this magic instantly becomes spotless, from head to toe. The hair and body look as if right out of the shower (only dry) and the clothes as if freshly washed and dried. The spell cannot be used on body armor, buildings, vehicles, streets, or anything else, only living creatures and clothes/fabric. One pile of clothes, weighing no more than 25 pounds (11.25 kg; no living person) can also be washed in place of a specific character''s clothes. Note: This spell only cleans off the surface of the target and will not rid them of diseases or poison, although it will kill most surface parasites, such as ticks and fleas.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Climb', 2, 3, NULL, 'Self, or others up to 40 feet away (12.2 m)', 'Five minutes (20 melees) per level of experience', NULL, 'None', NULL, NULL, 'A spell that enables the enchanted individual to climb with exceptional, almost inhuman, skill, speed and agility. Skill level is 98% to climb normal, rough, climbable surfaces; speed is equal to Speed attribute. Smooth, presumably unclimbable or extremely difficult surfaces to climb normally can be scaled with a skill level of 60%. Rappelling is possible at 90%.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Cloak of Darkness', 2, 6, NULL, 'Self plus a 5 foot (1.5 m) radius around the character', 'Four minutes per level of experience', NULL, 'None', NULL, NULL, 'This magic cloaks the spell caster in a field of darkness that follows him or her everywhere. The mage can see perfectly from within the darkness, but those outside the radius of magic cannot see in. At night, it renders the cloaked individual virtually invisible, although he can still be detected by infrared and/or heat sensors, thermo-imaging optics, motion detectors and similar sensor systems. Furthermore, the aura of darkness may noticeably obscure a particular part of the background/area around him, making it obvious to visual detection, especially in daylight or when bathed in light - the magic darkness cannot be dispelled by ordinary light. Consequently, this cloaking spell is ideal in darkness for hiding, escape and setting up an ambush. In combat, opponents who attack a character cloaked in darkness from any distance (beyond the 5 foot/1.5 m area of magic) are -3 to strike, unless guided by thermal-optics or similar heat based optic systems, and even then are -1 to strike. Those who step into the darkness for hand to hand combat will see their quarry without difficulty; no penalty unless they step outside the 5 foot (1.5 m) radius of effect.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Extinguish Fire', 2, 4, NULL, '20 foot (6.1 m) radius. The spell can be cast a distance of up to 80 feet (24.4 m) away +10 feet (3 m) per level of experience', 'One minute (4 melee rounds)', NULL, 'None', NULL, NULL, 'The spell caster can instantly put out up to a 20 foot (6.1 m) radius of fire up to 80 feet (24.4 m) away. A total of 40 feet (12.2 m) can be extinguished every 15 seconds (one melee round).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fear (Horror Factor: 16)', 2, 5, NULL, '20 feet (6.1 m) diameter, up to 100 feet (30.5 m) away', 'One minute (4 melee rounds) per level of experience', NULL, 'Special; save vs Horror Factor', NULL, NULL, 'The invocation creates a sensation of fear over a particular area (20 feet/6.1 m maximum area of affect). The spell caster can place the enchantment on an area occupied with people, or an area that is not presently occupied. Anybody entering the area of enchantment must roll to save vs Horror Factor 16. A failed roll means the character is suddenly washed with terror and will be momentarily stunned, loses initiative and one melee attack/action, is the last character to attack, and can not defend against an opponent''s first strike each melee the individual is in the area of fear. Also see the "Horror Factor" explanation in the combat section of this book.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Heavy Breathing', 2, 5, NULL, '60 feet (18.3 m) away', '75 seconds (5 melee rounds) per level of experience', NULL, 'Standard; those who save are not affected/fearful', NULL, NULL, 'The mage is able to conjure a mysterious, frightful sound of heavy, labored breathing, as if something invisible was lurking about. The spell caster can mentally manipulate the sound, increasing or decreasing the breathing rhythm, and move the sound around up to 60 feet (18.3 m) away. The breathing can be heard in a six foot (1.8 m) radius. Those hearing the breathing will become fearful and panicky. There is a 01-60% chance that a frightened fellow will flee in terror. Those who hear the breathing, but do not run, will be -2 to strike, and -1 to parry and dodge as they shake in their boots.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Manipulate Objects', 2, 0, NULL, '50 feet (15.2 m) +10 feet (3 m) per level of experience; line of sight', 'Two minutes (8 melee rounds) per level of experience', NULL, 'None for inanimate objects. Living beings are immune to this magic', NULL, NULL, 'The Manipulate Objects spell was designed to help a sorcerer when he needs an extra pair of hands, but has nobody to assist him. It is used mainly to hold an item in mid-air, to bring an item from across the room without having to get up and get it, and to use magic energy to pick up, move, carry or hold one or more small objects. The spell caster summons forth blue strands of magical energy that wrap around an item and bring it to him, hold it near or in place or still, or to pick up or carry it, following the mage around at waist or shoulder level. Being able to magically hold an item in mid-air until needed, or to magically carry or retrieve an item, allows the mage to keep his hands free to perform more delicate tasks. This also means the mystical movement of objects weighing less than 10 pounds (4.5 kg) is very simple and requires little concentration. When the mage is not consciously manipulating an object, the item hangs suspended 3-5 feet (0.9 to 1.5 m) above the ground, usually within arm''s reach. The P.P.E. cost varies with the combined weight of the objects, two P.P.E. points per five pounds (2.3 kg). Inanimate objects get no save against this spell; this means that even tiny, lightweight robots get no save, although they may struggle or attack. Limitations: Maximum speed of moving objects that weigh 10 lbs (4.5 kg) or less is a speed factor of 10. Reduce speed by half when the total weight becomes 100 lbs (45 kg) or more. Maximum height: Six feet (1.8 m). Maximum number of objects: Two per level of experience. Maximum weight: 10 pounds (4.5 kg) per level of experience. The spell caster cannot manipulate more than his maximum weight, so a first level spell caster can manipulate up to two items with a combined weight of 10 lbs (4.5 kg), while a third level mage can manipulate as many as six items weighing up to 30 lbs (13.5 kg). The magic force has the equivalent P.S. of 8, +1 per additional level of the spell caster (9 at 2nd level, 10 at 3rd, etc.). The magic energy is designed to hold and carry objects, so it can not be used to open a container, open a door or window, shoot a gun, pull a trigger or lever, press a button, or turn a knob, however, a small object can be "manipulated" to gently press or tap against a button or switch to turn it on or off. The spell caster must concentrate to direct the object and each action by the object counts as one of the character''s melee actions. Likewise, the slow speed of movement, relatively low P.S., and the fact that this spell is not intended for combat, means that small objects can NOT be hurled or used to stab or pound an opponent. Each object manipulated to hit/attack requires the conscious focus of the spell caster, uses up one of his attacks per melee, and is easy to dodge or parry (the magic force is -2 to strike, and no other combat bonuses apply). Note: This magic cannot be used to pick pockets or steal items unnoticed. Nor to grab an item, lift it in the air and drop it. The magic energy will not drop anything, because it is designed to hold and carry. A few seconds before the spell duration elapses, the objects are gently lowered to a tabletop or the floor.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Turn Dead', 2, 6, NULL, 'Up to 60 feet (18.3 m) away', 'Instant effect', NULL, 'Standard', NULL, NULL, 'The utterance of this invocation will turn/repel 1D6 animated dead per level of experience. This means that those creatures affected will turn and immediately leave the area without harming the spell caster or anyone near him. The dead who are turned will not come back for 24 hours. This magic only affects "animated" dead and skeletons or corpses that are magically animated like marionettes, but will not affect vampires, zombies, mummies, other undead or any corpse or skeleton possessed by a living entity.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Float in Air', 3, 5, NULL, 'Self or others within 30 feet (9.1 m)', '10 melees per level of experience', NULL, 'None', NULL, NULL, 'This spell creates air currents which hold a person or object aloft, hovering about one or two feet (0.3-0.6 m) above the ground. It can be used to slow someone''s descent from a fall or used to float on top of water. Movement is awkward and slow while in the air. The floating individual suffers the following penalties: All attacks, strikes, parries and dodges are at -1; normal speed/movement is reduced by half.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fuel Flame', 3, 5, NULL, '120 feet (36.6 m)', 'Instant', NULL, 'None', NULL, NULL, 'The magic feeds any existing fire, doubling it in size. It can affect a 100 foot area (30.5 m) up to 100 feet (30.5 m) away.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Ignite Fire', 3, 6, NULL, '40 feet (12.2 m)', 'Instant (counts only as one attack; fire lasts until it is put out)', '2D6 S.D.C. per melee round (beginning after the first 2 melees)', 'None', NULL, NULL, 'The spell causes spontaneous combustion, igniting any material that can burn. This means the mage could set a chair cushion, a jacket, paper, dry leaves, hair, etc., on fire. Note: Volatile substances that are contained in something, like gasoline in the gas tank of a car or a container, can NOT be ignited. Furthermore, the target to be set on fire must be clearly visible. Maximum area of affect is 3 feet (0.9 m) away. If somebody''s clothes or hair are set on fire, they have two melee rounds (30 seconds) to get it off or put the fire out before damage is inflicted; no other combat or action is possible as all energy is used on dousing the flame.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Impervious to Fire', 3, 5, NULL, 'Self or others up to 60 feet (18.3 m) away', 'Five minutes (20 melees) per level of experience', NULL, 'None', NULL, NULL, 'A magic invocation that makes the individual temporarily impervious to fire. Normal, magical and Mega-Damage fires do no damage to the enchanted individual or to anything he is wearing or is on his person.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Impervious to Poison', 3, 5, NULL, 'Self or others by touch', 'Five minutes (20 melees) per level of experience', NULL, 'None', NULL, NULL, 'This enchantment makes the person temporarily impervious to poisons, venom, deadly toxins, pollution and poison gases.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Life Source', 3, 2, NULL, 'Self', 'Instant', NULL, 'Not applicable', NULL, NULL, 'By using the Life Source spell, the mage is able to convert his own life energy (S.D.C. and/or Hit Points) into P.P.E. points for casting spells. Casting Life Source costs two P.P.E. points and inflicts physical pain and weakness upon the spell caster. The sacrifice of portions of his own life force in order to gain P.P.E. racks the body with sharp pain and invisible physical damage. Obviously, this is a spell of desperation. In game terms, the willing sacrifice of two S.D.C. points (counts as S.D.C. damage) makes available one P.P.E. point. The willing sacrifice of one Hit Point makes available one P.P.E. point. Unlike the Indian Shaman power (see Rifts Spirit West), the mage can accidentally kill himself by burning up all his Hit Points (down to zero). If Hit Points reach zero (even if S.D.C. points are still available), the character falls into a coma and is -20% to save vs coma and death! Furthermore, for every ten points of S.D.C. or five Hit Points of damage to the spell caster (from this spell), he becomes weak and is -2 on all rolls for bonuses, saving throws and combat (initiative, strike, etc.), while skill rolls are -10%. At some point, the character can do little more than sit or lay in a heap to mumble spells and speak - too weak and injured to move! Note: This damage resists both bio-regeneration and magical healing, but is not permanent, and will heal at the normal rate.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Light Healing', 3, 6, NULL, 'Touch', 'Instant', NULL, 'None', NULL, NULL, 'The spell caster grasps the injured character with both hands, then channels magical energy into him, willing it to aid the person''s body in healing. The magic speeds the healing process to clear out minor infection, minor food poisoning/upset stomach, a slight headache, tiny cuts, bumps and bruises. It restores 1D6 S.D.C. or 1D4 Hit Points (not both). The healing is instant and painless. The spell caster may not use this spell on himself.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Magic Shield', 3, 6, NULL, 'Self or other', 'Two minutes per level of the spell caster', NULL, 'None', NULL, NULL, 'This spell creates a pale white field of energy in the shape of a large, round shield with 60 M.D.C. The shield can be used by the spell caster or be given to someone else. It functions as a normal shield to parry melee attacks (sword blades, clubs, etc.), with a bonus of +1 to parry. The shield wielder can also attempt to parry energy blasts and projectiles, but the user has no bonuses and suffers a -8 penalty to parry. The shield takes one quarter damage from all attacks it parries and disappears when all M.D.C. are used up, the spell duration elapses, or if the user loses contact with the shield.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Mystic Fulcrum', 3, 5, NULL, 'Self or two others by touch', 'Five minutes per level of experience', NULL, 'Not applicable', NULL, NULL, 'Mystic Fulcrum is another spell that defies or tweaks the laws of physics. Those enchanted by the magic can pick up and move objects that they would otherwise not have the leverage and ability to do without a lever and support. Those enchanted by Mystic Fulcrum can lift 50% more weight than usual and carry 10% more.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Negate Poison/Toxin', 3, 5, NULL, 'Self or by touch', 'Instant', NULL, 'None', NULL, NULL, 'The spell caster can magically turn a poisonous substance inert, rendering it harmless. The magic can also be used to instantly negate poison in the bloodstream, preventing further damage by the foul substance. However, any damage caused by the poison before the magic is used can not be reversed.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Resist Fire', 3, 6, NULL, 'Self or others', '20 melees per level of the spell caster', NULL, 'None', NULL, NULL, 'With this spell the sorcerer can make himself, or one or two others, fire resistant. This means heat has no ill effect and fire, normal and magical, does half damage. The spell can be cast up to 60 feet (18.3). Mega-Damage plasma and fire also do half damage.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Blind', 4, 6, NULL, 'Touch or 10 feet (3 m) away', 'One minute (four melee rounds) per level of experience', NULL, 'Standard', NULL, NULL, 'An enchantment that can blind one person or animal each time the spell is cast. The intended victim must be visible and within range. The victim will be temporarily blind; -5 to strike, -10 to parry and dodge, and likely to stumble and fall for every 10 feet (3 m) of movement (50% chance). Does not affect people inside environmental M.D.C. body armor, power armor, robots or vehicles. If the Blind spell is cast upon another spell caster he can not use any spells that require vision/line of sight. If the blind spell caster uses any defensive/assault spells, such as Magic Net, Call Lightning, Fire Ball, etc., there is a 01-65% chance that the spell will be misdirected upon his own comrades.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Carpet of Adhesion', 4, 10, NULL, '30 feet (9.1 m) +10 feet (3 m) per level of the spell caster', '10 melee rounds (two and a half minutes) per level of the spell caster', NULL, 'Special', NULL, NULL, 'The spell caster creates a sticky carpet, up to 10 feet wide by 20 feet (3x6 m) long, that will adhere firmly to anyone who touches it. The victim stays stuck until the carpet spell time elapses or until the spell caster cancels it. The carpet can be cast on a floor, table, wall, etc., or actually cast upon a person. The spell caster can create this super-flypaper up to 90 feet (27.4 m) away and can alter the size and shape (without exceeding the stated limit of 200 square feet/18.6 sq. m). Saving Throw: If a successful saving throw vs magic is made, that player rolls two six-sided dice to see how many melee rounds it will take him to pull free. Those failing to make the saving throw are stuck for the entire duration of the spell. Effective even against cyborgs, power armor, robots and those with Supernatural P.S. Someone who Teleports away will Teleport part of the Carpet with them (just the immediate area around them) and remains stuck when they reach their new destination.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Charismatic Aura', 4, 10, NULL, '60 foot radius (18.3 m)', 'Six melee rounds per level of experience', NULL, 'Standard', NULL, NULL, 'A particularly handsome tool of deception, this magic can be cast upon the spell caster or another person. The spell instantly enhances that person''s Physical Beauty by eight points, and increases his charisma to charm all who behold him. Although the focal point of the spell is the person on whom it was cast, it affects everybody in a 60 foot (18.3 m) radius (emanating from the person with the charismatic aura). Thus, everybody in that radius is allowed a saving throw vs magic. Those who successfully save will not be affected at all; those who fail to save are charmed and will respond accordingly. The person with a charismatic aura can invoke one of three responses: friendship/trust, power/fear, and successful deception. Friendship/Trust: The first few words spoken will set up the response. Thus, a statement of friendship, peace, or trust will inspire those sentiments in everyone affected. Power/Fear: A statement of power, anger, strength, or vile intent, will strike awe and fear into everyone affected. (Example: "Lay down your weapons and let us pass, lest you suffer my wrath!"). Horror Factor: 13. Successful Deception: This enables the character with Charismatic Aura to convincingly lie like a master con-man. There is an 01-80% chance that those affected will believe anything he tells them, no matter how outlandish. This response is triggered by a phrase like: "Trust me completely," or "I would never lie to you, you know that."', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Cure Minor Disorders', 4, 10, NULL, 'Touch or 10 feet (3 m)', 'Instant', NULL, 'Standard (if unwanted)', NULL, NULL, 'A unique bit of curative magic that will instantly relieve minor physical disorders and illnesses such as headaches, indigestion, gas, heartburn, nausea, hiccups, muscle stiffness, low fever (under 101 degrees) and similar. This invocation will also negate simple curses that inflict Minor Disorders.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Electric Arc', 4, 8, NULL, '30 feet (9 m) per level of experience', 'One melee round', '2D6 M.D.', 'Dodge', NULL, NULL, 'A simple offensive spell, the Electric Arc causes a crackling bolt of blue energy to leap from the spell caster''s hand(s) to the intended target; point and shoot; +2 to strike. Each electrical blast counts as one melee attack/action and is limited by the character''s total number of attacks. This means a character with four attacks per melee round uses up two attacks to cast the spell, leaving him with two electrical attacks possible that melee round. While the damage is not great, it is accurate, and is an easy, inexpensive spell to cast.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Energy Field', 4, 10, NULL, 'Self or others up to 60 feet (18.3 m) away', 'One minute (4 melees) per level of experience or until it is destroyed', NULL, 'None', NULL, NULL, 'The magic creates a protective field of energy that can be placed around the mage, others, or an object. The maximum area of protection is about 8 feet (2.4 m), which means it can protect a small room full of people (about 6 to 8 individuals). The energy field appears as a semitransparent wall or bubble that shimmers with a blue-white light. The field normally provides a total protection of 60 M.D.C., but is doubled at ley lines and tripled at a ley line nexus.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fire Bolt', 4, 7, NULL, '100 feet (30.5 m) plus 5 feet (1.5 m) per level of experience', 'Instant', '4D6 M.D.', 'Dodge', NULL, NULL, 'The spell caster creates and directs a bolt of M.D. fire that is +4 to strike. Damage is normally 4D6 M.D., or 1D6x10 S.D.C. (the mage can pick which).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fist of Fury', 4, 10, NULL, 'Self or one person by touch', 'One melee round per level of experience', 'Varies with P.S.', 'None', NULL, NULL, 'P.P.E.: Ten for oneself or fifty to cast upon another. This spell causes the spell caster''s dominant hand to glow with a fierce red light. The character can then punch with Mega-Damage power as if his or her strength were supernatural (1D6 M.D. minimum damage). However, the character can only do normal punches, not power punches, and does not get any additional attacks per melee round. Furthermore, the character can not parry Mega-Damage energy attacks, but can grab and parry physical Mega-Damage melee weapons such as a magical sword or Vibro-Blade. The fist is encased in magical energy and releases a shower of energy sparks on impact. Note: This spell cannot be placed on Automatons, robots or other non-living things, nor the supernatural.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fool''s Gold', 4, 10, NULL, '5 feet (1.5 m)', '20 melees per level of the spell caster', NULL, 'Standard', NULL, NULL, 'This Elemental magic enables the magician to cause any object to appear to be made of gold. After the mage leaves, the object will still retain its gold appearance until the spell elapses. The effect is temporary, and upon close examination by those who can recognize precious metals it is seen not to be gold. Those who save recognize it as worthless fool''s gold.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Ley Line Transmission', 4, 30, NULL, 'Limited by the length of the ley line', 'Instant', NULL, 'A psionic Mind Block will block and destroy the message', NULL, NULL, 'The spell caster can send a verbal and/or audio message directly along a ley line to another person so long as that person is located somewhere on the line. The best messages are brief ones of under a hundred words to avoid overwhelming the recipient. Unfortunately, the message is a one-way transmission unless the other person is a Ley Line Walker or other mage with the Ley Line Transmission spell or O.C.C. power. Range is limited only by the length of the ley line and the people''s position on the line. The time lapse between sending and receiving a ley line transmission is only a matter of seconds. The same message can be sent to several people (one person per level of experience) at different locations, as long as they are all on the ley line. The only danger is that a telepath (psionic or magic) may be able to listen in on the message. There is a 01-20% chance that any psionic or magic character with the Telepathy power will sense a Ley Line Transmission coming through, and there is a 01-31% chance that they too will automatically receive the message. There is no way for the sender to know if others have eavesdropped, nor is there any way to scramble the message.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Magic Net', 4, 7, NULL, '60 feet (18.3 m)', 'Two melees (30 seconds) per level of the spell caster', NULL, 'Dodge of 16 or higher', NULL, NULL, 'This spell creates a net composed of magic fibers and can snare up to 1-6 human-sized victims within a 10 foot (3 m) area. Normal weapons can not cut through the net; only Mega-Damage weapons, magic weapons, and magic can affect this net. Even then, it requires a full two melee rounds to cut or blast out (a Dispel Magic Barriers will dispel it instantly). Anyone caught in the Magic Net is helpless and unable to attack or defend. The spell caster can cancel the net at any time. Note: A Magic Net can trap beings larger than human-sized provided the spell does not exceed the normal area of effect. To hurt someone already caught in a Magic Net without harming the net itself requires a Called Shot or a roll of 16 or higher to strike.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Multiple Image', 4, 7, NULL, 'Self', 'One minute (4 melees) per level of experience', NULL, '-4 to save', NULL, NULL, 'An illusion that creates three identical images of the mage, each of which mimics his every movement exactly. Only piercing the false image with iron will dispel that particular image. This is a great way to confuse, scare and distract an opponent. Provides the mage with a bonus of +2 on initiative, +2 to dodge, and +1 to strike. Viewers may be able to see through the illusion and identify the true person, but must roll to save vs magic at -4.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Repel Animals', 4, 7, NULL, '30 feet (9.1 m)', 'Immediate', NULL, 'Standard for animals', NULL, NULL, 'The character can invoke an enchantment that will make even a hostile predatory animal stop, turn, and leave the area without harming the mage or anybody near him. The animal will not return for hours. The enchantment can affect six animals simultaneously.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Shadow Meld', 4, 10, NULL, 'Self', 'Two minutes (8 melees) per level of experience', NULL, 'None', NULL, NULL, 'This unique magic enables the spell caster to step into shadows, becoming totally invisible, even to a "See the Invisible" spell. The shadow must be at least five feet (1.5 m) tall or long to become an effective hiding place. The shadow serves as a superior means of hiding or moving unseen. The mage can move, walk, or run through the length of a shadow or from shadow to shadow. While in shadow/darkness, the character prowls at a 60% proficiency (or at +15% to normal skill, whichever is higher). While hidden in shadow, the character is still susceptible to magic, psionic and physical attacks, although attackers are -5 to strike him (because they can not see him). Area affect magic does not suffer any penalty. Infrared/thermal-optics are the only means that can be used to see somebody in a shadow. Intense light will dispel the shadow, leaving the mage revealed. Of course, sanctuary can be found by fleeing into another shadow. Feeble light, less than 10 torches or 300 watts, will only create more shadows.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Swim as a Fish (lesser)', 4, 6, NULL, 'Self or others up to 10 feet (3 m) away', 'Five minutes (20 melees) per level of experience', NULL, 'None', NULL, NULL, 'An incantation that provides the character with exceptional swimming abilities. Equal to Advanced Swimming and SCUBA skills combined. Base Skill is 96%, can swim a distance of 100x P.S. in yards/meters without tiring, survive depths of up to 600 feet (183 m) without special gear, and is +1 to parry and dodge while in water. Can hold breath for five minutes per level of experience.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Trance', 4, 10, NULL, 'Touch or within 12 feet (3.6 m)', 'Five minutes per level of experience', NULL, 'Standard', NULL, NULL, 'This enchantment places another character into a zombie-like state in which the entranced victim is in a hypnotic daze, unaware of his environment or happenings around him. He can not formulate thoughts, use skills, or act on his own. While entranced, the individual is only aware of the enchanter''s voice and will follow extremely simple commands, such as stay, sit, follow me, get inside, lay down, give me your hand, etc. The entranced victim can NOT engage in any type of combat to any degree, nor any actions that require skill or thought, and offers no resistance. The magic is meant to incapacitate more than it is to enslave. Evil men of magic often use trance on prisoners or intended victims of a human sacrifice. While entranced, the person can not be made to reveal secrets, betray a friend, harm himself, or act against his alignment. All physical attributes function as if they were half of what they really are; thus, a speed of 10 is 5 while entranced. The victim of a trance will remember nothing of the events that occurred while entranced. Can not affect people inside power and M.D.C. body armor, robots, or vehicles.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Armor Bizarre', 5, 15, NULL, 'Self or one other up to 30 feet (9 m) away', 'One minute (4 melee rounds) per level of the spell caster', NULL, 'To save vs Horror Factor only', NULL, NULL, 'Like the Armor of Ithan spell, Armor Bizarre creates a suit of magical form-fitting force to serve as armor. However, it provides 15 M.D.C. per level of the caster and this armor appears to be composed of dozens to hundreds of writhing tentacles, pulsating slime, or crawling worms. This magical illusion provides a Horror Factor of 9 +1 for every two levels of the spell caster (10 at 2nd, 11 at 4th, 12 at 6th, etc.). Anyone fighting an opponent in Armor Bizarre is automatically distracted by the moving parts (-1 on initiative) and must make a save vs Horror Factor at the beginning of every melee round. A failed roll means the usual Horror Factor penalties.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Calling', 5, 8, NULL, '2 miles (3.2 km) per level of experience', 'Five minutes per level of experience', NULL, 'Standard', NULL, NULL, 'The Calling is like a limited form of telepathic communication in which the mage can mentally call a specific individual. To use "the call," the mystic must know the person''s whole name (first and last), must have personally met the individual (even if only briefly) and must be within range. The call sends a telepathic message to that particular character, calling him or her by full name, and leaves an impression of where the caller can be found. A typical call message will be something like "Erick Wujcik, come to me," or "Richard Burke, I need you." Pranksters might use the spell for harassment purposes: "Joseph Prosek, you are a goose-stepping noodle head," or "Erin Tarn, you are a D-Bee loving blowhard." Only the individual to whom the call is made can hear it, no one else. If a successful saving throw is made, the Call, and impression of location, is heard only once. If the saving throw is not successful the Call will repeat itself over and over again, three times per melee round, until the spell elapses or the person goes to the mage. Nothing except a Mind Block can block out the call. A failed roll means the call keeps coming and coming, compelling the individual to answer it. Communication without visual contact can only be done between people who know each other extremely well, but has a very limited range of 500 feet (152 m) maximum, regardless of experience, and each needs some object that once belonged to the other. Although limited, this form of magical communication can not be easily monitored or traced (no radio waves, electronics or conventional power source or means of transmission); perfect for a group in hiding. However, a hidden microphone will be sensitive enough to pick up both conversations. Note: The Federation of Magic uses Distant Voice as its main form of communication.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Charm', 5, 12, NULL, '15 feet (4.6 m)', 'Four melees (one minute) per level of the spell caster', NULL, 'Standard', NULL, NULL, 'The charm spell can influence any intelligent creature. The spell''s victim falls under the immediate influence of the spell caster. He will believe everything the mage tells him, trusts the spell caster as if he were a trustworthy friend, does his best to please/help/assist or protect him, and will answer any questions asked by the spell caster truthfully and with as much detail as requested. Note that other than perceiving the spell caster as his best and favorite friend, whom he is anxious to please, the charmed individual will not do anything that is contrary to his alignment or character.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Circle of Flame', 5, 10, NULL, '10 feet (3 m) around self', 'Two minutes (8 melee rounds)', '6D6 S.D.C.', 'None', NULL, NULL, 'The spell caster can create a circle of flame around himself. No combustible material is required. The flame is five feet (1.5 m) tall and inflicts 6D6 S.D.C. damage to anybody who tries to pass through the fire.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Distant Voice', 5, 10, NULL, '2000 feet (610 m) per level of experience; line of sight', 'Five minutes per level of experience', NULL, 'Not applicable', NULL, NULL, 'Distant Voice is a spell that allows two-way communication over great distances. Magic is used to create a doorway for sound between two points within the given range. Voices can pass both ways and be heard as if the speaker were only a few feet (a meter) away. The only real limits to this spell are that the spell caster must know the person he wishes to speak with (at least in passing or by his appearance) and that individual must be partially visible, even if only a speck on the horizon. If they have never met, but the character is known to the mage by reputation and photograph, communication is still possible provided there is visual contact. Communication without visual contact can only be done between people who know each other extremely well, but has a very limited range of 500 feet (152 m) maximum, regardless of experience, and each needs some object that once belonged to the other. Although limited, this form of magical communication can not be easily monitored or traced (no radio waves, electronics or conventional power source or means of transmission); perfect for a group in hiding. However, a hidden microphone will be sensitive enough to pick up both conversations. Note: The Federation of Magic uses Distant Voice as its main form of communication.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Domination', 5, 10, NULL, 'Touch or within 4 feet (1.2 m)', '15 minutes per level of experience', NULL, 'Standard', NULL, NULL, 'Domination is another trance-like enchantment that enables the spell caster to impose his will over his victim''s, forcing the individual to do his bidding. The victim of Domination appears to act oddly, dazed, confused, slow and unfriendly (ignoring friends, etc.). The enchanted character has one goal, to fulfill the commands of the spell caster. Under the enchantment of Domination, the character''s alignment does not apply. He will steal, lie, assist in crimes, kidnap, betray friends, reveal secrets and so on. The victim is under the (almost) complete control of the spell caster. The only things the bewitched victim will not do are commit suicide, inflict self-harm, or kill a friend or loved one. A good aligned character, Principled, Scrupulous and even Unprincipled, can not be made to kill anybody; it is too deeply against their alignment. Note: The enchanted person is not himself and suffers the following penalties. Attacks per melee round are half, speed is half, all skills are half their usual proficiency, speech is slow, and the person seems distracted or a little dazed. A successful saving throw versus magic means the magic has no effect. The character is 100% his normal self. The effects of the Domination magic can not be faked. Can not affect a person inside environmental M.D.C. body armor, power armor, robots, or vehicles.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Energy Disruption', 5, 12, NULL, '60 feet (18.3 m)', 'Three minutes (12 melees) per level of experience', NULL, 'None', NULL, NULL, 'A particularly useful magic in a tech environment. The invocation will temporarily knockout, stop, or immobilize, any electrical device it is aimed at. This includes normal automobiles, computers, radios, surveillance cameras, sensors, appliances, entire fuse boxes, batteries, electric alarm systems, etc. The apparatus is not harmed in any way, it simply ceases to function. When the magic elapses, the item(s) work perfectly again, with no sign of malfunction, damage or energy loss. Can not affect M.D.C. environmental armor, power armor, robots or military vehicles.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Escape', 5, 8, NULL, 'Self, touch or 5 feet (1.5 m)', 'Instant', NULL, 'None', NULL, NULL, 'The escape invocation enables the mage to magically escape any bonds, or open any locking mechanism that bars his way. This includes being tied with rope, handcuffs, prison cells, doors, trunks, locks, straitjackets, etc. One restraint or lock can be undone per each invocation (one per melee round is possible). Only gagging the mage will prevent the use of this magic.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Eyes of Thoth', 5, 8, NULL, 'Self or others by touch', '10 minutes per level of experience', NULL, 'None', NULL, NULL, 'Thoth is the god of knowledge and wisdom of the ancient Egyptians and said to know all languages. This invocation enables the character to read and understand ALL written languages, modern and ancient. However, spoken languages are incomprehensible unless a Tongues spell is also invoked or the character has an education in that language.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Featherlight', 5, 10, NULL, 'Touch or up to 10 feet (3 m) away', '10 minutes per level of the spell caster', NULL, 'None', NULL, NULL, 'Featherlight allows a spell caster to reduce an object''s weight (does not work on a living creature) to that of a feather. Due to loss of mass, that item is of no use as a weapon, because it is too light. Furthermore, even if the mage cancels the magic, the object does not return to normal until it is sheathed or put down, so there is no picking up boulders and throwing them, then canceling the magic. Yes, robots and vehicles can be made Featherlight, provided the spell caster can affect the weight of the entire object (i.e. part of a robot or hovercycle can NOT be made Featherlight, it must be the entire thing). Limitations: The spell is limited to 200 pounds (90 kg) per level of the spell caster and only one object is affected per use of the spell, even if the object weighs far less than the mage''s weight limit. Penalties: This spell was designed mainly to enable practitioners of magic to carry great weight easily. Used in a combat context, something made Featherlight can not inflict damage and is also easily blown by the wind, like a feather. Thus, if a rifle or bow was made Featherlight, the weapon would flutter in the wind (-3 to strike) and might even blow away unless it was held tight, pocketed or tied down. This also applies to robots who may be made Featherlight, plus their speed is reduced by 80% and they must hold on to things or get blown away! Pushing a Featherlight robot with a P.S. 7 or greater will knock it off its feet and send it flying 3D4 yards/meters. A vehicle like a motorcycle or hovercycle made Featherlight will rocket at double the desired speed (10 mph/16 km is really 20 mph/32 km, and so on). The vehicle is incredibly hard to handle at speeds above 50 mph (80 km made 100 mph/160 km when made Featherlight) because the light weight causes the vehicle to spin and get buffeted by wind even at low speed; the driver is -30% to his piloting skill under 50 mph (80 km) and -60% over. Note: Cybernetics, bionics, M.O.M. implants and any object/machine that is connected to a living being is immune to this spell.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fly', 5, 15, NULL, 'Object by touch', 'Six minutes per level of experience', NULL, 'None', NULL, NULL, 'The spell caster can magically bestow the power of flight to an inanimate object not made of metal or plastic. That object can then be used to fly. This spell may be the origin of the myth about the witch and her broom and of flying carpets. The object must be big enough to hold onto or, preferably, large enough to sit on. If the item is small, the mage must hold on for dear life, and if his grip should give way, he will fall to his doom. To avoid muscle strain and tragedy, it is best that the object can be comfortably sat upon. The maximum length and width of the enchanted item must not exceed six feet (1.8 m). This maximum size is enough to accommodate three additional adult passengers or six children. Note: The magic will not work if the object has any metal or plastic on it, including nails, screws or metal bands. Maximum altitude is 1000 feet (305 m). Maximum speed is 35 mph (56 km); the object can be made to hover stationary.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Heal Wounds', 5, 10, NULL, 'Touch or 3 feet (0.9 m) away', 'Instant', NULL, 'Standard, if the person resists the magic', NULL, NULL, 'This powerful invocation will instantly heal minor physical wounds, such as bruises, cuts, gashes, bullet wounds, burned flesh and pulled muscles. It will not help against illness, internal damage to organs or nerves, broken bones or poisons/drugs. In the case of bullet wounds, the bullet should be removed first. If the bullet is left inside a person it will be a constant irritant causing chronic pain; reduce the character''s P.E. attribute by one and P.P. attribute by one (and attribute bonuses accordingly) due to stiffness and discomfort. The heal wound magic restores 3D6 S.D.C. and 1D6 Hit Points.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('House of Glass', 5, 12, NULL, 'Up to 100 feet (30.5 m) away', 'One minute per level of the spell caster', 'Special', 'Standard; gods are immune to this spell', NULL, NULL, '"People who live in glass houses shouldn''t throw stones..." While hackneyed, this saying sums up the spell''s effect. The recipient of this magic appears to turn into living glass, but suffers no damage, only a strange, semi-transparent appearance. It is not until the victim of this magic attacks the spell caster that the enchanted individual learns the effect of this magic. The victim of this spell can not harm the spell caster without suffering identical damage in return! Any harm the victim inflicts on the mage is also visited upon him. Thus, an enchanted mercenary who fires a laser rifle at the spell caster and inflicts 22 M.D., will automatically suffer 22 M.D. in return. The damage is always identical, so if the mage suffered damage to his armor (magical or physical body armor), the same damage will be inflicted on his enchanted attacker. If the damage was to physical M.D.C./Hit Points, the attacker will suffer the same damage in the same location. Similarly, if the attacker is a fellow mage, and he casts a Speed of the Snail spell upon the other mage, he too will be affected by his own magic. Of course, the returning attack may offer greater or lesser consequences to the attacker depending on the situation and the two combatants.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Lifeblast', 5, 15, NULL, 'Can be cast upon one character up to 30 feet (9 m) away per level of experience, or two by touch', 'Varies', 'Varies, see description below', 'Varies; typically as None; automatically hits its target', NULL, NULL, 'Used on the living (good and evil), the Lifeblast is a powerful magic energy that brings renewed hope and optimism to the character(s) it is cast upon. This renewed faith motivates those it enchants to press on, and provides the following bonuses for the first melee round a character is affected by the magic: +3 on initiative, +1 on all combat rolls, +1 melee attack action, and +1 on all saving throws! After the first melee round and for the next half hour, the affected character continues to feel optimistic and is +1 on initiative, +5% on the performance of skills and +10% to save vs coma/death. In the alternative, the Lifeblast can be used against creatures of death and undeath with interesting results: Animated dead: Negates the magic that animated the corpse, and the hellish thing drops lifeless to the ground. Drive away mummy or zombie: The blast inflicts 1D6 damage and makes the creature fear the person who wields the powerful energy of life; equal to a Horror Factor of 16. A failed roll to save vs H.F. means the creature is held at bay (will not attack, shuffles around confused and frightened) for 1D4 melee rounds. Roll for each blast. Drive away Banshee or Grave Ghoul: Equal to a Horror Factor of 19. A failed roll means the monster will immediately flee the area. Roll percentile to see for how long: 01-33% leaves the area for 1D4 hours, 34-66% leaves the area for 1D6 days, 67-00% leaves the area permanently. Kill vampires. The undead are too powerful and evil to be driven away easily, but each Lifeblast inflicts 1D6x10 damage to the vampire it strikes. Only a Master Vampire can roll to save vs magic. If successful, he takes half damage. Combat Necromancer: A Lifeblast shot directly against a Necromancer will inflict 4D6 S.D.C./Hit Point damage (or 3D6 M.D. if a Mega-Damage creature) and destroys two of its additional undead appendages (if any; only affects appendages attached to the Necromancer''s body). If the Death Mage was in the process of casting a spell, the blast will interrupt the incantation and burn up half the P.P.E. needed for that Necromantic spell. Note: A Lifeblast can only be directed at one target/person at a time (or two by touch) and automatically hits.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Sleep', 5, 10, NULL, 'Touch or one foot (0.3 m) away', 'Becomes inert within 15 minutes; effects last 10 minutes per level of experience', NULL, 'Standard', NULL, NULL, 'The invocation can turn any normal food or drinkable fluid into a sleep inducing potion. Immediately after two bites of enchanted food or two gulps of fluid, the character will fall into an enchanted sleep. The victim can not be awakened by any means except the mage canceling the magic or until the magic''s duration time lapses. A successful save means the enchanted food or drink has no effect whatsoever.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Superhuman Endurance', 5, 12, NULL, 'Self or one person up to 10 feet (3 m) away or two by touch', 'Two hours', NULL, 'Standard, provided the character resists its magic', NULL, NULL, 'This spell enables the mage to magically enhance the stamina of living creatures (himself included) to have greater physical endurance and fortitude. Recipients of this magic can engage in any type of strenuous activity without getting tired in the least. At the end of the magical duration, the character will feel fresh, but without further magic, fatigues at his normal rate. This means a horse (or man) could run for this period, non-stop, without getting tired or losing strength. The spell does not endanger the recipient, as the magic does not force the body to work past its normal endurance, rather it changes the recipient''s body in such a way as to mimic supernatural endurance with virtually no fatigue and no stress on the body. Bonuses: In addition, the character can lift and carry 10% more than usual, and is +2 to save vs disease, poison and toxins. Willing recipients do not attempt to resist the enchantment and are affected automatically. If, for some reason, a character resists this helpful magic, he gets to make a standard save vs magic, and if successful, will be unaffected. Animals (such as horses) are always unwilling, and will resist as best they can. Remember, though, that animals are at -4 to save.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Superhuman Speed', 5, 10, NULL, 'Self or others by touch', 'One minute (4 melee rounds) per level of experience', NULL, 'None', NULL, NULL, 'The invocation bestows the character with the equivalent of a Speed attribute of 44 (equal to 30 mph/48 km) and adds a bonus of +2 to parry and +6 to dodge for the duration of the magic. All movements performed during this period are done without fatigue.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Superhuman Strength', 5, 10, NULL, 'Self or others by touch', '2 melee rounds (30 seconds) per level of experience', NULL, 'None', NULL, NULL, 'The incantation magically gives the character a Supernatural P.S. of 30 and a P.E. of 24, as well as adds 30 S.D.C. for the duration of the magic. Supernatural strength, endurance and bonuses last for the duration of the magic.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Call Lightning', 6, 15, NULL, '300 feet (91.5 m); line of sight', 'Instant', '1D6 M.D.C. per level of the spell caster', 'None', NULL, NULL, 'This spell creates a lightning bolt which can be directed at any specific target up to 300 feet (91.5 m) away. The lightning bolt shoots down from the sky, hitting the desired target. The target or area must be within the spell caster''s line of vision. The lightning bolt does one six-sided die (1D6) of M.D. per level of the spell caster.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Compulsion', 6, 20, NULL, '60 feet (18.3 m) and within line of vision', '24 hours', NULL, 'Standard', NULL, NULL, 'The spell caster can implant a sudden desire or need in another character''s mind. The focus of the irresistible impulse should be something reasonable and attainable, although the motive may seem quite irrational. The enchanted character will be consumed with the object or action of the implanted compulsion, whether it be something very simple, like a craving for a candy bar, or the need to visit somebody, or something more extravagant. The victim of this enchantment will be obsessed with attaining whatever it is for the full duration time of the incantation or until it is attained. A "remove curse" will instantly negate the compulsion.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Cure Illness', 6, 15, NULL, 'Touch or 3 feet (0.9 m)', 'Instant cure', NULL, 'None; standard if the person resists treatment', NULL, NULL, 'A potent magic that can cure ordinary disease and illness, such as fever, flu, and other common diseases. The magic can not cure cancer, AIDS, lung disease, wounds, broken bones or internal damage to organs, only sickness caused by bacteria. Nor can it cure magically induced sicknesses or disorders.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fire Ball', 6, 10, NULL, '90 feet (27.4 m)', 'Instant', '1D4 M.D. per level of the spell caster', 'None except dodge, but the victim must know the attack is coming and must roll an 18 or higher', NULL, NULL, 'The spell caster creates a large Fire Ball which hurls at its target at an awesome speed, inflicting 1D4 Mega-Damage per each level of the spell caster. The Fire Ball is magically directed and seldom misses.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Impervious to Energy', 6, 20, NULL, 'Self or others by ritual', 'Two minutes (8 melees) per level of experience', NULL, 'None', NULL, NULL, 'The spell caster can make himself impervious to all forms of energy, including fire, heat, electricity, lasers and so on. Energy attacks do no damage whatsoever. Physical attacks, guns, knives, clubs, explosives, and even punches, etc., do normal damage.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Magic Pigeon', 6, 20, NULL, 'Immediate area', 'Two months per level of the spell caster', NULL, 'None', NULL, NULL, 'Through the means of a special incantation the spell caster is able to create a mystic facsimile of a pigeon. The Magic Pigeon is able to deliver a spoken (30 words or less) or written message to anyone, anyplace in this world (in the same dimension). However, the spell caster must know at least the general location of the recipient of the message and a specific person (or two) to receive the message. Upon reaching its destination, the pigeon seeks out that person and immediately delivers the message. If the recipient of the message is not at the prescribed destination it will wait until he returns or until the spell duration elapses and the pigeon fades away. The Magic Pigeon looks exactly like a real pigeon, but needs no food or rest; thus it can fly 720 miles (1152 km) every 24 hours at a speed of 30 mph (48 km). Normal weapons can not harm or capture the pigeon, but magic spells of entrapment can capture it (Magic Net, Carpet of Adhesion, etc.). Only a Dispel Magic spell can destroy it.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Mask of Deceit', 6, 15, NULL, 'Self', '10 minutes per level of experience', NULL, 'Everyone who encounters the disguised character gets a save vs magic, but is -4 to succeed. A successful save means the true features are seen, not the mask. However, those who don''t really pay attention or care who the character might be, are automatically fooled by the deception (no chance to save).', NULL, NULL, 'A useful tool for deception, it magically creates an illusionary mask over the spell caster''s own facial features. Age, gender, skin color, hair, hair length, and specific features are composed with thought. However, the magic is limited to facial features and does not apply to any other part of the body. The mage can attempt to imitate a specific person''s face, but has a mere 20%+5% chance per level of experience. If the character has the Disguise skill, use that base skill instead.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Reduce Self (6 inches)', 6, 20, NULL, 'Self', '10 melees per level of spell caster', NULL, 'None', NULL, NULL, 'This spell instantly shrinks the spell caster, his clothes and possessions to six inches tall. Note that reduced weapons do virtually no damage. Weapons that normally inflict Mega-Damage do a mere ONE point of S.D.C. damage when shrunken. All others just sting for a moment.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Sheltering Force', 6, 20, NULL, 'Around self, or up to 20 feet (6.1 m) away', 'One hour per level of experience', NULL, 'Not applicable', NULL, NULL, 'The Sheltering Force is essentially a light force field that appears as a semi-opaque (can see figures, outlines and blurred colors, but not faces or details), bluish-white dome. The "shelter" can be small enough to accommodate two people or big enough to accommodate six (eight cramped). In either case, it resembles a dome shaped tent made of semi-opaque plastic. It is dry inside and maintains a temperature that is 10 degrees Fahrenheit cooler than outside in hot weather and 10 degrees warmer in cool weather. It will hold smoke in, so any campfire must be made outside. The magical shelter keeps rain and insects out, but animals, people, ''bots and spirits can come and go as they please, much like a real tent. Furthermore, if attacked, the Sheltering Force will only stop 1D6 M.D. per each attack blast/arrow/whatever, with the remaining damage penetrating the force field and possibly hitting those inside the shelter. The semi-opaque nature of the force field means that those attacking from outside can not get a clear shot and are -3 to strike, but they can see shapes and shadows inside to shoot at.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Agony', 7, 20, NULL, '5 feet (1.5 m) per level of experience', 'One minute (4 melees)', 'Special', 'Standard', NULL, NULL, 'A particularly cruel and painful invocation that incapacitates its victim with pain. Under the influence of this spell, the victim has no attacks per melee, can not move, perform skills or even speak; only writhe in agony. Although there is no physical damage (no S.D.C. or Hit Points are lost), the pain is very real. It takes another minute for the victim to regain his full composure. During that second minute his number of attacks per melee are at half, speed is half, and he suffers a penalty of -1 to strike, parry and dodge. Only one person can be affected per invocation.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Animate and Control Dead', 7, 20, NULL, '400 feet (122 m); line of vision', 'Five minutes (20 melees) per level of experience', NULL, 'None', NULL, NULL, 'With this incantation the practitioner of magic can animate the remains of dead bodies - human, animal or monster - and mentally control them like a puppet master would a marionette. The remains are not alive and do not have any intelligence whatsoever. It is the sorcerer who controls their actions. Restrictions: 1. The mage can animate and control only two corpses/skeletons, plus one per level of experience. 2. The animated dead must remain in his line of vision. If it can not be seen, it can not be animated. 3. The animated dead can be a corpse or skeleton. Attacks per melee: two each, Speed: 7, Damage: 1D6 from punch, bite, claw or blunt weapon. Modern weapons, such as guns of any kind, can NOT be used by animated dead. 4. Only total destruction will stop an animated dead, or knocking out the controlling mage. S.D.C. of a small corpse/skeleton, about 3 or 4 feet (0.9-1.2 m) tall, is 50 S.D.C.; medium, 5 or 6 feet (1.5-1.8 m), is 80 S.D.C., large, 7 to 12 feet (2.1-3.6 m), is 140 S.D.C. Vulnerabilities: Bullets do half damage, blunt and smashing attacks do full damage, fire does double normal damage. Animated dead can not be stunned or affected by a death blow or critical hit, nor frightened. They are S.D.C. structures and inflict S.D.C. damage unless they wield an M.D.C. weapon such as a Vibro-Blade.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Ballistic Fire', 7, 25, NULL, '1,000 feet (305 m) +10 additional feet (3 m) per level of experience', 'Instant', '1D6 M.D. per fiery missile', 'None. Potential victim(s) can attempt to dodge at -10 and without benefit of any other bonuses', NULL, NULL, 'Ballistic Fire is an anti-infantry spell designed to mow down large numbers all at once. The spell creates one fiery missile per level of the spell caster which can then be directed and fired simultaneously at whatever multiple targets the mage desires. Actually, these mini-missiles can be directed at several different targets (as few as one target per missile), as volleys of several missiles directed at two or more targets, or all concentrated as one large volley to all hit the same target. The balls of fire are magically guided and rarely miss! Regardless of the missiles created and the way they are distributed, the attack of a Ballistic Fire takes only a single spell attack (approximately 7 seconds to cast).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Constrain Being', 7, 20, NULL, '30 feet (9.1 m)', 'Two minutes (8 melee rounds) per level of experience', NULL, 'Standard', NULL, NULL, 'This invocation is useful for controlling lesser supernatural creatures, such as most entities, sub-demons (Gargoyles and Brodkil included), lesser demons and Deevils, Minor Elementals, and similar. The enchantment forces the being to obey the spell caster to a very limited degree. Mainly, the mage can hold the thing at bay with an order like: "Back, stay back," "Go ... begone," "Stay there ... don''t move," "No," "Stop," "Back away." No commands more elaborate than this will be obeyed. The Constrain Being incantation works in the same way as a cross holds a vampire at bay. As long as the mage and his allies stay out of the creature''s reach, the magic will hold it at bay. If it can reach out and hurt somebody, it will. If it is attacked, the enchantment is broken and it is free to lash out at everybody. Note: Possessing Entities and greater supernatural beings are not affected by this magic, nor are non-supernatural beings such as dragons, Faerie Folk, or mortal humans, D-Bees, or aliens.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Dispel Magic Barriers', 7, 20, NULL, '100 feet (30.5 m)', 'Instant', NULL, 'The magic spell being attacked automatically gets a standard saving throw (12) as if it were a person. If a successful save is made, the negation spell has no effect; the barrier remains.', NULL, NULL, 'The Dispel Magic Barriers invocation negates/dispels all magic barriers of any kind, including the Sorcerer''s Seal, Carpet of Adhesion, Magic wall spells, ward spells, etc.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Fly as the Eagle', 7, 25, NULL, 'Self or two others by touch or cast upon one to 100 feet (30.5 m) away', '20 minutes per level of the spell caster', NULL, 'None', NULL, NULL, 'The power of flight is bestowed upon the spell caster or person it is cast upon. It is especially effective outdoors, and in large, open areas. Maximum Speed: 50 mph (80 km). Bonuses: +1 to parry, +2 to dodge and +2 to damage on a diving attack. Bonuses apply only when in flight. The character enchanted by this spell can fly and land as he pleases without intense concentration, and spell casters can cast other spells while flying.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Globe of Silence', 7, 20, NULL, 'Up to 90 feet (27.4 m) away', 'Six melee rounds per level of the spell caster', NULL, 'None. There is no saving throw because it is actually the physical space within the globe that is being altered. A Negate Magic spell can be attempted to dispel/cancel the globe and its influence.', NULL, NULL, 'This spell immediately creates an invisible, 10 foot (3 m) radius globe which stops all sound. Voices, screams, footsteps, everything within that radius is absorbed by the globe. This means that absolutely no sound can leave or penetrate the area covered by the globe. So while it can prevent those within the globe from making noise, it also prevents sound from outside to enter. Those within the globe can not hear anything. A spell caster, reliant on spoken incantations, is completely powerless inside a Globe of Silence because his words can not be heard. The spell affects those within its radius; stepping beyond the radius frees that character from its effect. The globe itself can be fixed in a stationary area or mentally moved and manipulated by the spell caster. However, the spell caster must be inside the globe to move it, and can not cast another spell while manipulating the globe. Once fixed to one spot, that is where the globe remains until the spell duration time elapses or it is canceled.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Heal Self', 7, 20, NULL, 'Self', 'Instant', NULL, 'None', NULL, NULL, 'This is a (comparatively) costly and mid-level spell because of all the mental, physical and magical aspects of this magic. The mage must have any external wounds/cuts bound to stop or slow bleeding, and meditate for one minute while whispering a mantra-like chant. At the minute''s end, the mage is washed with mystical energy that heals cuts, bruises, internal injuries and broken (not shattered) bones, restoring 3D6 S.D.C. and 1D6 Hit Points (or 1D4 M.D. if a Mega-Damage creature).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Invisibility (Superior)', 7, 20, NULL, 'Self or one other by touch', 'Three minutes (12 melees) per level of experience', NULL, 'None', NULL, NULL, 'A powerful incantation that makes the spell caster invisible to all means of detection. Ordinary vision, infrared, ultraviolet and other optics, heat, motion detectors, and even an animal''s sense of smell, can NOT locate the invisible person. No footprints are made, and little sound (prowls at 84%). The magic is broken only if the character makes a hostile move, or engages in combat/attacks. At that instant, he becomes completely visible. Note: The invisible character is not ethereal and can not walk through walls; he must still use a door. The act of forcing open a door or window, picking a lock, tapping somebody, accidentally bumping somebody, or accidentally getting shot or hurt, is not considered an act of aggression or combat, so invisibility is maintained.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Life Drain', 7, 25, NULL, '30 feet (9.1 m)', 'Two melees (30 seconds) per level of experience', 'Special; see description', 'Standard. A successful saving throw means the magic has no affect on the character. Characters inside power armor, environmental body armor, manned robots, or military vehicles are affected by this spell! ''Borgs, the undead, adult dragons and greater supernatural beings are impervious; so are true robots and androids.', NULL, NULL, 'The Life Drain is a debilitating magic that weakens an opponent. The victim will turn pale and experience weakness. Reduce S.D.C. by half, Hit Points by half, speed by half, attacks per melee by one, and skills are -10%. Low level practitioners of magic (1-3) can only affect one individual per each spell cast, but at fourth level the mage can also cast the magic on an area 15 feet (4.6 m) in diameter, affecting everyone who enters and remains in the area of enchantment. Once the magic''s duration time has lapsed, the victim''s skills and attacks per melee return to normal, S.D.C. returns at a rate of 8 per hour, and Hit Points return at a rate of 4 per hour. Reduced speed (by half) and a feeling of weakness remains for six hours.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Lightblade', 7, 20, NULL, 'Self; close combat/hand to hand', 'One minute (4 melee rounds) per level of experience', '1D4x10 +1 M.D. point per level of experience', 'Parry or dodge', NULL, NULL, 'This spell causes a sword of brilliant white light to form in the spell caster''s dominant hand. The size varies with the blade''s power, which is represented by the character''s level of experience. Thus, a first to third level mage creates a Lightblade the size of a short sword and rapier thin, a mid-level sorcerer makes a blade resembling a bastard sword, while at 10th level or higher it is a large lightblade with the length of a two-handed sword (although it can be easily wielded one-handed) and as thick as a two-by-four. The blade is weightless, serves as an extension of the sorcerer, is +1 to strike, and can be used to attempt to parry energy attacks (no special bonus to parry, however). Against vampires, Shadow Beasts, and other demons vulnerable to light, the Lightblade inflicts double its normal damage (double Hit Point damage to vampires). However, the sword inflicts no damage against those immune to light or energy, and only the spell caster can use the Lightblade he creates.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Metamorphosis: Animal', 7, 25, NULL, 'Self or other by ritual', '20 minutes per level of experience', NULL, 'None', NULL, NULL, 'The invocation can completely transform a character into a particular animal, from an alley cat or cocker spaniel to a lion, wolf, alligator or bird. As the animal, the character gets all the inherent abilities and defenses that animal form may offer, but retains his own ability to speak, memory, S.D.C. and Hit Points. The mage can return to his natural humanoid form (naked) at will. To determine the general abilities of an animal type, use the following tables. Note: For an in-depth description of animals and their abilities (monsters too), you might want to take a look at The Palladium Fantasy RPG sourcebook, Monsters & Animals. Retractable Claws: Small Cats (lynx, bobcat): 1D6. Big Cats (lion, tiger): 2D6. Claws: Digging (badger, wolverine): 1D8. Miscellaneous (rodent, lizard): 1D4. Birds of Prey: 1D6. Bear: 1D8. Teeth: Bear: 2D4. Polar Bear: 2D6. Canine (generic): 1D6. Wolf: 2D6. Feline: 1D6. Tiger/Lion: 2D6. Mustelid: 1D4. Badger/Wolverine: 1D6. Herbivores (horse, goat, ape, humans): 1D4. Birds of Prey (beak): 1D4. Antlers: Small Antlers: 1D4. Large Antlers: 2D4. Horns: Small Horns: 1D6. Large Horns: 2D6. Hooves: Small: 1D6 (kick). Speeds: Wild Canine: about 35 mph (56 km) maximum for up to an hour. Small Wildcats: 15 mph (24 km) in spurts of 10 to 20 minutes. Large Wildcats: 30 mph (48 km) in spurts of 10 to 20 minutes. Cheetah: 90 mph (144 km) in 3 to 5 minute spurts. Deer/Antelope: 30 mph (48 km) maximum for up to an hour. Horse: 40 mph (64 km) maximum for up to an hour. Elephant: 25 mph (40 km) for up to an hour long. Rhinoceros: 35 mph (56 km) in 3 to 8 minute spurts. Alligator: 35 mph (56 km) in 2 minute spurts. Lizards: 10 to 20 mph (16 to 32 km) in 2 to 5 minute spurts. Typical Birds: 30 mph (48 km) for up to 1D4 hours. Birds of Prey: 40 mph (64 km) for up to 1D4+1 hours. Animal Abilities and Bonuses: 1. Extraordinary vision approximately 10 times better than a normal human''s. This means the character can clearly see an 18 inch (0.45 m) item up to two miles (3.2 km) away. 2. Nightvision: 600 feet (183 m); can see in the dark. 3. Extraordinary sense of smell allows the character to detect very faint scent traces. Tracking by smell is at a skill level of 35% +5% per level of experience (+10% if a predator following a blood trail). Identify person by scent is a 48% chance. 4. Natural prowl skill is 65% +2% per level of experience, climb 35%, and swim 50%. 5. +2 to save vs poison and disease.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Purification', 7, 20, NULL, 'Touch or 3 feet (0.9 m)', 'Instant', NULL, 'None', NULL, NULL, 'The mystic can purify food or water, cleansing it of disease, bacteria and poison/toxins. Up to 50 pounds (22 kg) of food or 10 gallons (38 liters) of water/fluids can be purified.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Teleport: Lesser', 7, 15, NULL, 'Five miles (8 km) per level of experience; touch', 'Requires two full melees (30 seconds)', NULL, 'None', NULL, NULL, 'The power to transmit matter from one place to another. The Teleport: Lesser invocation is limited to non-living substances. Up to 50 lbs (22 kg) can be instantly transported from the location of the spell weaver to any location miles away. The only requirements are that the mage touches the object to be teleported and that the location of where it is being sent to is known to him. Success Ratio: 80% +2% per level of the mage. An unsuccessful roll means that the object never arrived where it was supposed to and could be anywhere within the mage''s range.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Tongues', 7, 12, NULL, 'Self or others by touch', '3 minutes (12 melees) per level of experience', NULL, 'None', NULL, NULL, 'The magic enables the character to perfectly understand and speak all spoken languages; 98% proficiency. An understanding of written languages is not provided by this magic. See the Eyes of Thoth.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Wind Rush', 7, 20, NULL, '120 feet (36.6 m)', 'One melee (15 seconds)', NULL, 'A roll of 18, 19 or 20 saves one from losing one''s balance and/or losing some item(s)', NULL, NULL, 'This spell creates a short, powerful wind gusting at 60 mph (96 km), which is capable of knocking people down, knocking riders off mounts, blowing small objects 20 to 120 feet (6-36 m) away, or creating dust storms. The wind can be directed by the spell caster at a specific target or a general sweep can be made (maximum wind width is 20 feet/6.1 m). Anyone caught in the wind is helpless and unable to attack or move forward. It takes an additional melee to recover, and 1D8 melees to gather up all items blown away.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Words of Truth', 7, 15, NULL, '5 feet (1.5 m)', 'One minute (4 melees) per level of experience', NULL, 'Standard. The enchanted character makes a saving throw for each question asked. A successful save means he does not have to answer. Questions can, however, be repeated.', NULL, NULL, 'A person affected by this enchantment is compelled to answer all questions truthfully. The spell caster must be within five feet (1.5 m) and can ask two brief questions per melee round. It is wise to keep questions simple and clear to avoid confusion.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Commune with Spirits', 8, 25, NULL, 'Self, or others by ritual; 200 feet (61 m) away', 'Five minutes per level of experience', NULL, 'None', NULL, NULL, 'The incantation enables the spell caster to see and speak with all types of "entities," including Poltergeists, Haunting Spirits, trapped entities and possessing entities, as well as most other types of ghostly spirits. The ability to see and communicate with these ghostlike beings does not mean that they will obey the character, but a dialogue can be exchanged. Note: "Entities" are a specific type of supernatural beings. See Rifts Dark Conversions for details on Entities.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Exorcism', 8, 30, NULL, '30 feet (9.1 m)', 'The spell lasts 3 minutes, results last 6 months or longer', NULL, 'Standard; 12 by spell or 16 by ritual', NULL, NULL, 'Exorcism is a powerful magic that forces a possessing supernatural being to relinquish its control over the enslaved person, animal or object. Forced out of its host body, the evil intelligence will try to possess any other human or animal within the immediate area (30 feet/9.1 m line of vision). The horrid thing gets two attempts at possession. Fortunately, the exorcism incantation protects the person who was its original victim with a bonus of +12 to save vs possession and the mage conducting the exorcism gets a bonus of +6 to save vs possession. Anybody else in the area has no extra bonus and is in great peril. If the evil force fails in both of its attempts to take possession of a host body, roll percentile dice: 01-52%: The evil intelligence is instantly returned to its own dimension. 53-00%: The being can continue to exist in our world, but must immediately flee the area and can not return for at least six months. Note: Ritual exorcism always has a greater chance for success but takes 20 minutes. An exorcism can be repeated by the same character on the same victim as often as needed (just be certain the sorcerer has sufficient P.P.E.).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Expel Demons', 8, 35, NULL, NULL, 'Immediate, 1D6 hours', NULL, 'Special', '10 foot (3 m) area per level of experience', NULL, 'The spell caster is able to repel all lesser demons and other lesser supernatural beings, forcing them to leave the area and not return for at least one hour (roll 1D6 hours). The spell may also expel greater demons with less efficiency. Note: Lesser supernatural beings must roll an 18 or higher to save vs spell magic. Greater demons and supernatural beings only have to roll 12 or higher to save, and usually have significant bonuses that apply. Demon Lords, Elementals (any), Spirit beings and gods are impervious to this spell.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Eyes of the Wolf', 8, 25, NULL, 'Self or one other by touch', 'Five minutes (20 melees) per level of the spell caster', NULL, 'None', NULL, NULL, 'Bestows the following abilities at the noted level of proficiency: Nightvision (60 feet/18.3 m), See the Invisible (75%), Identify Plants & Fruits (70%), Identify Tracks (85%), Track (50%; humanoids or animals), and Recognize Poison (65%).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Forcebonds', 8, 25, NULL, 'Touch', '30 minutes per level of experience', NULL, 'Special', NULL, NULL, 'The spell, Forcebonds, transforms ordinary S.D.C. materials (chains, leather strips, rope, or even strips of cloth, string, yarn or rubber bands) into magical restraints that glow with mystic force. This enchantment is made to bind and restrain captives in the same way as M.D.C. handcuffs, manacles or cord. The captive must already be subdued, or have surrendered and been tied with some ordinary material. A single captive can be bound at the wrists and/or ankles, or at the wrists with two bands around the arms and upper torso, pinning the arms tight to the body (or to a chair, pole, tree, etc.). To tie the hands, arms and legs requires two spells. Forcebonds requires a combined supernatural P.S. of 45 to pull free or break the magical bonds (takes 2D4 minutes of trying to do so), or 100 M.D. to destroy them. Dispel Magic Barriers and Negate Magic can be used to make them disappear, but the Forcebonds get a +2 to save. An Anti-Magic Cloud will dispel them instantly. Characters with the Escape Artist skill will find Forcebonds extremely difficult to escape from; reduce the success rate by half, and each attempt takes three times as long. When bound by this magic, the Escape spell functions as the Escape Artist skill at a 50% maximum proficiency. An escape can be tried once every five minutes (needs a roll of 01-50% on percentile dice to succeed). Teleporting away, while bound, will take the character to a new location, but he is still bound. Metamorphosis into a mist works wonderfully. Metamorphing into any animal or insect with legs and a body is futile, as the animal will remain tied up by the magical Forcebonds.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Greater Healing', 8, 30, NULL, 'One character by touch (can not be used on oneself)', 'Instant', NULL, 'None', NULL, NULL, 'A powerful healing spell that can instantly heal external and internal injuries and restore up to 2D4x10 S.D.C. and 6D6 Hit Points, or 1D4 M.D. (only if the latter is a Mega-Damage creature)! The mage may not cast this spell on himself nor give (even temporarily) a character more S.D.C. or Hit Points than he had to begin with.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Ley Line Tendril Bolts', 8, 26, NULL, '10 feet (3 m) per level of experience', 'One melee round. Each four tier blast counts as one melee attack', '2D6 M.D. at level one, +1D6 M.D. per every two additional levels of experience (i.e. 2D6 at level one, 3D6 at level three, 4D6 at level five, 5D6 at level seven, and so on). The level of damage inflicted can be regulated by the spell caster in increments of 1D6 M.D., so as little as 1D6 M.D. to full damage (depending on the level of the mage) or anything in between can be inflicted. Each blast counts as one melee attack. The casting of the spell to create this attack uses up at least one melee attack/action to begin with.', '-2; a successful save means the victim suffers only half damage', NULL, NULL, 'Limitation: This spell can only be cast when on a ley line. P.P.E.: 26 (half for Ley Line Walkers and Shifters). Doubling the amount of P.P.E. (26 points for Ley Line Walkers and Shifters) adds +20 M.D. to each of the bolts. This spell creates a sphere of energy that either encircles the hand or appears floating in the palm of the character''s hand (as depicted on the cover of this book). Four bolts of mystic energy emit from the energy sphere simultaneously to strike four different targets, each suffering the same amount of damage. Each energy bolt appears to shoot out like miniature arcs of lightning to strike the four nearest enemies/opponents to the spell caster (never an ally). When used against one opponent, only two energy tendrils strike him, each doing damage. The other two don''t even appear. If there are two opponents, two energy tendrils will strike each. If there are three opponents, two energy tendrils will strike either the nearest opponent or a supernatural opponent (if present), and one will strike each of the other two antagonists.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Lightning Arc', 8, 30, NULL, '100 feet (30.5 m) per level of experience', 'One melee round per level of experience', '4D6 +2 M.D. per level of experience', 'Dodge', NULL, NULL, 'This is a more powerful version of the Electric Arc spell, pumping more magical energy into the jolt for greater range and damage; point and shoot. +4 to strike targets within 100 feet (30.5 m), but only +1 to strike those at greater distances. Each lightning blast counts as one melee attack/action and is limited by the character''s total number of attacks. This means a character with four attacks per melee round use up two attacks to cast the spell and fire once. This leaves two more electrical attacks that melee round, but in the next three melee rounds the mage in our example can fire up to four times (once for each of his attacks per melee round). In addition, the character may vary or combine attacks. That is to say, a sorcerer with four attacks may elect to fire once, cast another spell and draw and fire a weapon or perform a skill, and so on.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Locate', 8, 30, NULL, '15 miles (24 km) per level of experience', 'Instant', NULL, 'None', NULL, NULL, 'Locate is a magic invocation that enables the spell caster to sense the general location of his quarry. The location is limited to a general area or environment, like a specific apartment building, aircraft, house, shopping mall, church, park, or wherever. To locate a particular person the spell caster must have either personally encountered the individual or a photograph of said individual must be available to him. The success ratio for a spell is 01-41% (+1% per level of experience). The success ratio for a ritual is 01-89%, but this also requires an object owned by the person or a lock of hair, fingernail clippings, or dried blood from that person.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Luck Curse', 8, 40, NULL, 'Touch or 10 feet (3 m)', '24 hours per level of experience', NULL, 'Standard; 12 by spell, 16 by ritual', NULL, NULL, 'The incantation inflicts the victim with bad luck. The character''s normal bonuses to strike, parry, dodge, initiative, and roll with punch are all reduced to zero; no bonuses! Critical strikes do normal damage (except a Natural 20 which always does double damage); a death or knockout/stun punch does only 1D4 damage. Kick attacks have a 01-60% chance of causing the character to trip and fall down (losing initiative and one melee attack). Prowl skill turns into a clumsy roll, making noise every time it is tried. All skills are minus 40%, but only during critical situations. The G.M. can add other minor occurrences of bad luck. Only a "Remove Curse" invocation can negate the effect of this enchantment.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Magical-Adrenal Rush', 8, 45, NULL, '100 feet (30.5 m); line of sight, self or one by touch', 'One melee round per level of experience', NULL, 'Not applicable', NULL, NULL, 'This powerful spell produces a magical rush that puts Juicers to shame. P.S. is raised to supernatural equivalent (punches and kicks do M.D.), the character gets two additional melee actions/attacks per round, speed is increased by 50%, fatigue has no effect, and the sorcerer is impervious to drugs, mind control, possession, illusions, pain and Horror Factor, as well as able to endure triple the normal damage to his body, and is +3 on initiative, +1 to strike and dodge, and +1 on all saving throws while the enchantment lasts. The spell does have consequences, however. Once the enhancement wears off, the once hyped-up character feels so tired and weak that he is barely able to move for 1D4 minutes. During this period reduce attacks per melee round, speed, skill performance and all combat bonuses by half. After this "down" time, the character returns to normal (minus the effects of normal fatigue or any damage sustained in combat).', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Metamorphosis: Human', 8, 40, NULL, 'Self, or other by ritual', '20 minutes per level of experience', NULL, 'None', NULL, NULL, 'A human spell caster can shape to alter his or her physical structure to look like somebody else. The ultimate disguise, the character can change his height, weight, age, hair color, hair length, skin color, gender, and features. A non-human D-Bee or demon can transform itself to appear completely human. To attempt to impersonate a specific, real person, the spell caster must have the Disguise skill, even though he/she is mentally molding his/her features through magic. A good photograph will do. The success ratio for imitating/impersonating the appearance of a real person is the mage''s Disguise skill +20%. The better he knows the person the more complete the disguise. In a ritual version of this same magic, the mage can metamorph somebody else, rather than himself. Also in the ritual magic, the spell caster can metamorph someone else into an exact duplicate of himself. Likewise, a captive or anybody at the ritual ceremony can be duplicated without flaw. Note: The metamorphosis process only changes the appearance of the body. The transformed person retains his own voice, memory, skills, and attributes.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Negate Magic', 8, 30, NULL, 'Touch or 60 feet (18.3 m)', 'Instant', NULL, 'Special (Ritual magic has a greater chance of success)', NULL, NULL, 'This incantation will instantly cancel the effects or influence of most magic. To determine whether the negation is successful or not roll a saving throw. If the roll is a successful save against the magic in place, its influence is immediately destroyed, negated, canceled. 12, 13, 14, or 15 is needed for spell magic depending on the experience level of the mage (usually 12 or 13 is needed), while 16 or higher to save vs ritual magic. A failed save means the negation attempt did not work. Try again if sufficient P.P.E. is available. Negation will not work against possession, Exorcism, Constrain Being, Banishment, Talisman, Amulet, Enchanted objects, Symbols/Circles of protection (or magically drawn circles of any kind), wards, summoning magic, Zombies, Golems, Restoration, magical healings or cures. Negation can be attempted to cancel a spell curse, but only has a 01-25% possibility of succeeding. Of course, it has no effect against psychic abilities or Techno-Wizard or Bio-Wizard/rune devices.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Power Weapon', 8, 35, NULL, 'One weapon by touch', 'Two melee rounds (30 seconds) per level of the spell caster', NULL, 'None', NULL, NULL, 'This spell temporarily infuses an S.D.C. melee weapon (knife, spear, sword, club, etc.) with great magical energy. For the duration of the spell, the weapon will inflict the Mega-Damage equivalent of the S.D.C. weapon; i.e. a knife that does 1D6 S.D.C. now does 1D6 M.D., or a mace that does 2D6 S.D.C. now does 2D6 M.D., and so on. In the alternative, this spell can be used to increase the damage capability of Mega-Damage melee weapons (Vibro-Blade, etc.) or M.D. magic weapons (rune sword, TW-weapons, etc.) by 25%. So a magical flaming sword that normally does 4D6 M.D. now does 5D6, a Vibro-Blade that does 2D6 now does 4D4 M.D., etc. Note: This magic does not work on long-range weapons like the bow and arrow, projectile weapons or energy guns. Casting this spell on the same weapon repeatedly has no cumulative effect.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Shockwave', 8, 45, NULL, 'Radius around the spell caster', 'Instant', '1D4 M.D. per level plus knockdown', 'Special; roll percentile', '10 foot (3 m) radius per level of experience', NULL, 'This powerful offensive spell creates a circular shockwave that emanates from the spell caster in the air in all directions. Only those touching the spell caster are not affected. The shockwave inflicts Mega-Damage. The exact amount of damage can be regulated in increments of 1D4 M.D. (i.e. a 5th level mage can create a 5D4 shockwave, but may elect to create only a 1D4 shockwave, or 2D4, and so on). S.D.C. objects are shattered as if struck by a tornado force. Likewise, the spell caster can adjust the radius of the area affected by five foot (1.5 m) increments. In addition to the damage inflicted to everything in the radius of affect, those caught in the shockwave are likely to be knocked down (roll percentile dice). People and animals (and objects) weighing less than 500 lbs (225 kg) are likely (01-88%) to be knocked off their feet and hurled 3D4 yards/meters. Only a percentile roll of 89-00% (defenders always win ties) sees them keep their balance without the knockdown penalty, but they suffer full damage. Creatures and characters (supernatural beings, giants, dragons, cyborgs, robots, etc.) weighing 501-1000 lbs (225 to 450 kg) have a 01-50% chance off being knocked off their feet and knocked 1D4 yards/meters. Creatures and characters weighing up to one ton have only a 01-20% chance of being knocked off their feet and to the ground - knocked only a few feet back. Flying characters are hurled through the air at twice the distance, but do not get knocked to the ground, although they still suffer the penalties from the impact of the shockwave and disorientation. G.M.s can also have them slammed into walls, trees, etc., for an additional 1D4 M.D. Knockdown penalties: Those who fail to keep their balance are hurled through the air and knocked to the ground. There is a 01-40% chance of dropping anything they are holding, plus the character loses initiative and two melee attacks/actions. Only the spell caster and those touching him are unaffected by the shockwave. Note: Those with Acrobatics, Gymnastics or other skill abilities involving "balance" are +10% to save vs knockdown. Likewise, a character who makes a successful roll with fall or impact (14 or higher) takes half damage but still suffers full penalties.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Desiccate the Supernatural', 9, 50, NULL, 'One up to 50 feet (15.2 m) away per level of experience, or two by touch', 'Instant', '3D6x10 M.D. (or Hit Points, whichever is appropriate)', '-1 to save', NULL, NULL, 'Desiccate is a vicious spell designed for use against supernatural monsters. It will not work against any opponent in full environmental armor (body armor or power armor), or safely locked inside an armored M.D.C. vehicle or room. Likewise, it will not work against ordinary mortals, human or D-Bee. Only supernatural beings, good or evil, including spirits in physical form, sub-demons (Gargoyles, Brodkil, etc.), demons, Deevils, Elementals, Spirits of Light, demigods, godlings, gods, avatars (the life essences of Alien Intelligences, including vampires), angels, and others. It is important to note that the sphinx, dragons, unicorns, Faerie Folk and a handful of other superhuman beings possessing supernatural strength and abilities, but known as creatures of magic, are not supernatural creatures (they are more magical than supernatural, or at least not in the same way as demons and gods) and are immune to this magic. The spell works by drawing moisture out of the target, killing it in a matter of 2D4 seconds, and hopefully reducing it to a withered husk. Regenerating creatures will be unable to Bio-Regenerate damage caused by this spell until they replenish their body''s water supply. Creatures that do not incorporate water in their bodies (i.e. pure energy) will not be harmed by this spell. Water Elementals suffer double damage. A successful save vs magic means the creature suffers half damage.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Dragon Fire', 9, 40, NULL, '100 feet (30.5 m)', 'One melee round per level of experience', '1D4x10 M.D.', 'None except dodge, but the victim must know the attack is coming and must roll a 16 or higher', NULL, NULL, 'This spell allows the caster to temporarily breathe fire just like an adult Fire Dragon. Every melee round that the spell is in effect, the mage is able to breathe as many as two searing blasts of fire that each inflict 1D4x10 M.D. The Dragon fire blasts are magically directed and seldom miss. For the spell to work there can be nothing covering the spell caster''s mouth, no helmet, gas mask, etc.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Familiar Link', 9, 55, NULL, 'Self and animal; 600 feet (183 m)', 'Indefinite', NULL, 'None', NULL, NULL, 'At third level, a practitioner of magic is experienced enough to mentally link with a small animal (mammal, bird or reptile). This link is permanent, producing a rather impressive symbiotic relationship. No matter how wild or mean the animal may have been, it is instantly linked to the mage, becoming docile and submissive to him and him alone. The two are now one. The spell caster is its friend and master, and, in effect, an extension of the animal. The animal familiar will understand and obey any command, verbal or mental, from the sorcerer it is bound to. For the mage, the familiar is now a sensory extension enabling him to see, hear, smell, taste and feel everything the animal experiences. Thus, familiars make great spies; listening to conversations and prowling into areas not easily accessible to its master. Just as the spell caster knows what the familiar is feeling, so does the familiar know what its master is experiencing. If one is in danger the other will know it. Because of the magical nature of the union, the mage and the familiar both get an additional six Hit Points. However, if the familiar is hurt or attacked, its master also takes the same damage even if miles apart. If the familiar is killed, the sorcerer permanently loses 10 Hit Points. There is a 01-50% chance he will also suffer shock from the ordeal. If he does, the mage will lapse into a coma for 1-6 hours. Another Familiar Link can not be tried again for at least a year and a half. Although the familiar understands and obeys its master, it can not actually speak to him. Other Limitations: 1. Telepathic/empathic communications: maximum range: 600 feet (183 m). 2. Familiar possesses its normal animal abilities. 3. Size: 25 pounds (11.3 kg) maximum. 4. Usual animal types used: cats, dogs, coyotes, foxes, weasels, rodents, birds, lizards, and snakes.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Mute', 9, 50, NULL, 'By touch or up to 30 feet (9.1 m) away', '20 melees per level of spell caster', NULL, 'Standard', NULL, NULL, 'This spell temporarily affects the voice box and vocal cords, preventing any voice or sounds to be uttered.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Protection Circle: Simple', 9, 45, NULL, 'Radius of the circle', '24 hours; can be reactivated', NULL, 'None', NULL, NULL, 'Even as a spell, this invocation might be considered a ritual, for it requires the physical drawing of a circle and symbols while the spell incantation is recited. Chalk or charcoal, or almost any substance, can be used to draw the circle. 45 Potential Psychic Energy points are needed to initially create the circle, but a mere four P.P.E. is all that is needed to reactivate it. Anybody with sufficient P.P.E. and desire can reactivate a Protection Circle. However, if the circle is damaged (scraped, scarred, rubbed out, etc.), it will not function and a new one will have to be created. The simple protection circle will protect everybody inside its radius by keeping lesser supernatural creatures five feet (1.5 m) away from its outer edge. The creatures can not come any closer, nor enter the circle itself. The circle also provides its occupants with a bonus of +2 to save vs magic and psychic attack. Although lesser supernatural beings, including lesser demons, Entities, Ghouls, and Gremlins, can not come near or enter the circle, they can hurl objects, use weapons, or use magic and psychic powers against those inside the circle. Greater beings, such as vampires, Elementals and demigods, are not affected by the simple circle and can enter effortlessly. No bonuses vs magic apply against these powerful beings.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Sickness', 9, 50, NULL, 'Touch or 20 feet (6 m)', '12 hours per level of experience', NULL, 'Standard', NULL, NULL, 'Sickness is a debilitating magic which afflicts its victims with the symptoms of a specific disease. However, only the symptoms of the disease manifest themselves, not the actual disease. Consequently, a medical examination will show there to be no physical cause to the illness. At best, it will be diagnosed as psychological or unknown. No matter how ill or helpless the victim may become he can not die from the magic sickness, but the character will suffer greatly. All sickness caused by this magic is severe, inflicting the following penalties and modifiers: Attacks per melee are reduced to one, physical endurance is reduced by 70%, -4 to strike, parry and dodge; no initiative, and skills are reduced by 40%. The person is very weak, disoriented and uncomfortable.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Speed of the Snail', 9, 50, NULL, '60 feet (18.3 m)', '2 melees per level of the spell caster', NULL, 'Standard', NULL, NULL, 'This time distortion spell reduces the physical prowess, speed, and mobility of its victims to one-third their normal ability. Speed, attacks per melee, dodge, and parry are all reduced to one-third. Thus, a character with six attacks per melee round and a speed of 10 suddenly has only two attacks and moves at only a speed of 3 (round down). Talking and spell casting are not reduced. This spell can be cast upon 1D6 persons up to 60 feet away (18.3 m), but within the spell caster''s line of vision. Also affects robots and vehicles as well as people.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Spoil', 9, 30, NULL, 'Touch or 3 feet (0.9 m)', 'Instant', NULL, 'None', NULL, NULL, 'Basically, this magic is the opposite of the Purification (food/water) incantation. In this case, the mage can instantly transform good food into spoiled, affecting 50 lbs (22 kg) or 10 gallons (37.9 liters) of water/fluids, making the food inedible and the water undrinkable. Anybody who forces themselves to eat or drink the horrible tasting food or drink will get sick with stomach cramps and diarrhea. Penalties: -1 on initiative, -1 to strike, parry and dodge.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Wall of Defense', 9, 55, NULL, 'Can be cast up to 100 feet (30.5 m) away', 'One melee (15 seconds) round per level of experience', NULL, 'None', NULL, NULL, 'By casting this spell, the mage summons into being a small, shimmering wall of magical energy (semi-opaque; only shadowy forms can be seen moving behind it). The wall is so thin as to be nearly two dimensional (the thickness of a sheet of paper), stands 10 feet (3 m) tall, and six feet (1.8 m) long in length per level of the spell caster, plus six feet (1.8 m) in length per level of the spell caster. The magical wall will stop all incoming "attacks," including thrown rocks, arrows, bullets, missiles, energy blasts and spells! All projectiles are stopped in their tracks, suspended in midair. When the spell ends, they fall harmlessly to the ground. Explosives (grenades, missiles, etc.) are stopped and held by the wall and will not explode until the wall vanishes and even then, most, 01-65%, will simply fall harmlessly to the ground without detonation (roll percentile dice; a roll of 66-00% means it will explode when the magic ends). Energy blasts are dispelled completely, as if magic forces meant to pass through the wall. Living beings who touch or try to pass through the magic wall will be held frozen in mid-step (leap, flight, whatever) until the magic ends. Note: The magical defenses work the same on both sides of the wall, so even the mage who created it can not send magic or weapons through it. He must move around the wall to launch additional attacks. Also note that airborne enemies can easily fly above and over the wall to attack, but this magical defense is excellent in confined areas and against ground troops.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Water to Wine', 9, 40, NULL, '12 feet (3.6 m)', 'Instant/permanent', NULL, 'None', NULL, NULL, 'Another transformation spell, the spell caster is able to change ordinary fresh water into wine, affecting ten gallons (37.9 liters) per level of the spell caster''s experience. The wine is of fair to average quality, with the quality increasing by 5% per each level of the sorcerer''s experience.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Wisps of Confusion', 9, 40, NULL, '90 feet (27.4 m)', 'Five melees per level of the spell caster', NULL, 'Standard', NULL, NULL, 'Wisps cause 2D4 people/creatures to become confused and disoriented. Those affected strike, dodge, and parry at -5 and attacks per melee are reduced by half.', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Banishment', 10, 65, NULL, '100 feet (30.5 m)', 'Two weeks per level of experience', NULL, 'Standard', NULL, NULL, 'A useful invocation for controlling supernatural beings is Banishment. The magic forces one lesser supernatural being/demon, per experience level of the spell caster, to leave the immediate area (600 feet/183 m radius). The creature(s) can not return for at least two weeks per level of the spell caster''s experience. A successful save means it is not banished and can stay to cause trouble. As always, a Banishment ritual has a greater chance of success (16 or higher is needed to save.)', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

INSERT INTO spells (name, level, ppe, system, "range", duration, damage, saving_throw, area_of_effect, casting_time, description, source, source_book)
VALUES ('Control & Enslave Entity', 10, 80, NULL, '30 feet (9.1 m)', '48 hours per level of experience', NULL, 'Standard', NULL, NULL, 'Another incantation used to control supernatural forces. This magic does not summon entities, but does enable the practitioner of magic to control them when encountered. The mage can control two entities per each of his levels of experience. All varieties of entities are susceptible', 'import', 'Rifts Ultimate Edition')
ON CONFLICT (name) DO UPDATE
   SET level = excluded.level,
       ppe = excluded.ppe,
       system = excluded.system,
       range = excluded.range,
       duration = excluded.duration,
       damage = excluded.damage,
       saving_throw = excluded.saving_throw,
       area_of_effect = excluded.area_of_effect,
       casting_time = excluded.casting_time,
       description = excluded.description,
       source = excluded.source,
       source_book = excluded.source_book;

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS batch_rows FROM spells WHERE name IN ('Cloud of Smoke', 'Death Trance', 'See Aura', 'See the Invisible', 'Befuddle', 'Cleanse', 'Climb', 'Cloak of Darkness', 'Extinguish Fire', 'Fear (Horror Factor: 16)', 'Heavy Breathing', 'Manipulate Objects', 'Turn Dead', 'Float in Air', 'Fuel Flame', 'Ignite Fire', 'Impervious to Fire', 'Impervious to Poison', 'Life Source', 'Light Healing', 'Magic Shield', 'Mystic Fulcrum', 'Negate Poison/Toxin', 'Resist Fire', 'Blind', 'Carpet of Adhesion', 'Charismatic Aura', 'Cure Minor Disorders', 'Electric Arc', 'Energy Field', 'Fire Bolt', 'Fist of Fury', 'Fool''s Gold', 'Ley Line Transmission', 'Magic Net', 'Multiple Image', 'Repel Animals', 'Shadow Meld', 'Swim as a Fish (lesser)', 'Trance', 'Armor Bizarre', 'Calling', 'Charm', 'Circle of Flame', 'Distant Voice', 'Domination', 'Energy Disruption', 'Escape', 'Eyes of Thoth', 'Featherlight', 'Fly', 'Heal Wounds', 'House of Glass', 'Lifeblast', 'Sleep', 'Superhuman Endurance', 'Superhuman Speed', 'Superhuman Strength', 'Call Lightning', 'Compulsion', 'Cure Illness', 'Fire Ball', 'Impervious to Energy', 'Magic Pigeon', 'Mask of Deceit', 'Reduce Self (6 inches)', 'Sheltering Force', 'Agony', 'Animate and Control Dead', 'Ballistic Fire', 'Constrain Being', 'Dispel Magic Barriers', 'Fly as the Eagle', 'Globe of Silence', 'Heal Self', 'Invisibility (Superior)', 'Life Drain', 'Lightblade', 'Metamorphosis: Animal', 'Purification', 'Teleport: Lesser', 'Tongues', 'Wind Rush', 'Words of Truth', 'Commune with Spirits', 'Exorcism', 'Expel Demons', 'Eyes of the Wolf', 'Forcebonds', 'Greater Healing', 'Ley Line Tendril Bolts', 'Lightning Arc', 'Locate', 'Luck Curse', 'Magical-Adrenal Rush', 'Metamorphosis: Human', 'Negate Magic', 'Power Weapon', 'Shockwave', 'Desiccate the Supernatural', 'Dragon Fire', 'Familiar Link', 'Mute', 'Protection Circle: Simple', 'Sickness', 'Speed of the Snail', 'Spoil', 'Wall of Defense', 'Water to Wine', 'Wisps of Confusion', 'Banishment', 'Control & Enslave Entity');
SELECT level, count(*) AS n FROM spells GROUP BY level ORDER BY level;
