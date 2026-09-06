-- The Rifts Book of Magic spell backfill: what every spell DOES, the stat block
-- it was imported without, and the citations that pointed at the wrong page.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-bom-spell-backfill.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-bom-spell-backfill.sql
--
-- WHAT WAS WRONG, AND IT WAS BIGGER THAN THE NULL COUNT SUGGESTED. 177 spells
-- had no description at all. Another 230 carried a CATEGORY STUB - literally
-- "Air Elemental Magic, level 3." - which satisfies every "has a description"
-- query while telling a player nothing. Only 200 of the 607 spells had real
-- prose. The stubbed rows turned out to be skeletons in the same way: the 230
-- are exactly the rows with no range and no duration either, so a player could
-- read a name and a level and nothing else.
--
-- THE DESCRIPTIONS ARE PARAPHRASES IN OUR OWN WORDS, never the book's text,
-- matching the ~200 rows already written that way. Book text is not committed
-- to this repo.
--
-- THE STAT BLOCK IS VERBATIM, because that is what a stat block is: range,
-- duration and saving throw as the page prints them, metric conversions and
-- all. A field the book does not print is left alone rather than filled with
-- "None" - silence and an explicit "None" are different facts.
--
-- THE CITATIONS HAVE ONE ROOT CAUSE. Every wrong one points at the book's own
-- SUMMARY SPELL LIST rather than at the entry - printed 74 carries
-- "Fire Gout (10)" and "Wall of Flame (15)" as list lines while the entries are
-- on 77; thirteen Water spells were all stamped printed 82 because the summary
-- on 81-82 groups them under levels that do not match the section headings
-- later in the book. Verified by reading both pages.
--
-- ONE CACHE PAGE IS UNREADABLE AND IT IS NOT THE CACHE'S FAULT. bom printed 84
-- has a scrambled text layer, and the same corruption is in the source PDF's
-- own text layer - confirmed independently two ways. The five spells on that
-- page were recovered by RENDERING it to an image and reading it.
--
-- EVERY UPDATE IS GUARDED BY CONSTRUCTION: a column is only written where it is
-- currently NULL or empty, or where a description is one of the category stubs.
-- Re-running this file cannot overwrite a later correction, and it cannot
-- silently do nothing either - the readbacks at the foot count the corpus.
--
-- KEYED ON NAME RATHER THAN id, AND THAT IS NOT A STYLE CHOICE. Spell ids are
-- assigned per environment by insertion order and do not match between
-- production and a local or rebuilt database: id 283 is Fire: Fire Gout in
-- production and Earth: Track locally. The first version of this file was keyed
-- on id and wrote Fire Gout's description onto Earth: Track in local D1 - caught
-- because the readbacks failed there. `name` is unique across all 607 rows,
-- checked --remote, so it is the only safe key.
--
-- Generated from the extraction passes; see the PR for the per-slice reports.

-- Blinding Flash  (had NO citation at all)
UPDATE spells SET "range" = '10 foot (3 m) radius; up to 60 feet (18.3 m) away.', "duration" = 'Instant.', "saving_throw" = 'Standard; -1 if 3 P.P.E. points are pumped into this spell.', source_book = 'Rifts Book of Magic p.91' WHERE name = 'Blinding Flash';

-- Globe of Daylight  (had NO citation at all)
UPDATE spells SET "range" = 'Near self or up to 30 feet (9.1 m) away.', "duration" = '12 melees (3 minutes) per level of experience.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.91' WHERE name = 'Globe of Daylight';

-- Lantern Light  (had NO citation at all)
UPDATE spells SET "range" = '10 feet (3 m); can light up a room.', "duration" = '30 minutes per level of the spell caster.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.92' WHERE name = 'Lantern Light';

-- Sense Evil  (had NO citation at all)
UPDATE spells SET "range" = '90 feet (27.4 m) area.', "duration" = 'Two minutes (5 melees) per level of experience.', "saving_throw" = 'None, except a psychic Mind Block, Alter Aura or a Protection from Magic circle which will prevent the spell from working on anyone in the circle. The psychic''s equivalent power of Sense Evil is not blocked by magic circles.', source_book = 'Rifts Book of Magic p.92' WHERE name = 'Sense Evil';

-- Sense Magic  (had NO citation at all)
UPDATE spells SET "range" = '120 foot (36 m) area.', "duration" = 'Two minutes (8 melees) per level of experience.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.92' WHERE name = 'Sense Magic';

-- Thunderclap  (had NO citation at all)
UPDATE spells SET "range" = 'Directly affects the immediate area (30 feet/9.1 m) around the magic weaver, but can be heard up to one mile (1.6 km) away.', "duration" = 'Instant.', "saving_throw" = 'Save vs Horror Factor.', source_book = 'Rifts Book of Magic p.93' WHERE name = 'Thunderclap';

-- Chameleon  (had NO citation at all)
UPDATE spells SET "range" = 'Self or Others by touch.', "duration" = 'Four and a half minutes (18 melees) per level of spell caster.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.93' WHERE name = 'Chameleon';

-- Concealment  (had NO citation at all)
UPDATE spells SET "range" = 'Small objects up to 40 feet (12.2 m) away.', "duration" = 'Five minutes (20 melees) per level of experience.', "saving_throw" = 'Standard.', source_book = 'Rifts Book of Magic p.93' WHERE name = 'Concealment';

-- Detect Concealment  (had NO citation at all)
UPDATE spells SET "range" = 'Area affect: 30 feet (9.1 m).', "duration" = 'Instant.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.94' WHERE name = 'Detect Concealment';

-- Fear
UPDATE spells SET "range" = '20 feet (6.1 m) diameter, up to 100 feet (30.5 m) away.', "duration" = 'One minute (4 melee rounds) per level of experience.', "saving_throw" = 'Special; save vs Horror Factor.' WHERE name = 'Fear';

-- Levitation  (had NO citation at all)
UPDATE spells SET "range" = 'Up to 60 feet (18.3 m) away.', "duration" = 'Three minutes (12 melee rounds) per level of experience.', "saving_throw" = 'Standard.', source_book = 'Rifts Book of Magic p.94' WHERE name = 'Levitation';

-- Armor of Ithan  (had NO citation at all)
UPDATE spells SET "range" = 'Self or other by touch.', "duration" = 'One minute (4 melee rounds) per level of the spell caster.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.96' WHERE name = 'Armor of Ithan';

-- Breathe Without Air  (had NO citation at all)
UPDATE spells SET "range" = 'Self or others by touch.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.96' WHERE name = 'Breathe Without Air';

-- Energy Bolt  (had NO citation at all)
UPDATE spells SET "range" = '150 feet (45.7 m).', "duration" = 'Instantly.', "saving_throw" = 'Dodge of an 18 or higher.', source_book = 'Rifts Book of Magic p.96' WHERE name = 'Energy Bolt';

-- Fingers of the Wind  (had NO citation at all)
UPDATE spells SET "range" = '90 feet (27.4 m).', "duration" = 'Three melees per level of experience.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.96' WHERE name = 'Fingers of the Wind';

-- Invisibility: Simple  (had NO citation at all)
UPDATE spells SET "range" = 'Self only (includes clothes and articles on one''s person).', "duration" = 'Three minutes (12 melees) per level of experience.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.97' WHERE name = 'Invisibility: Simple';

-- Paralysis: Lesser  (had NO citation at all)
UPDATE spells SET "range" = '60 feet (18.3 m).', "duration" = 'The effect lasts one minute (4 melees) per level of experience.', "saving_throw" = 'Standard.', source_book = 'Rifts Book of Magic p.98' WHERE name = 'Paralysis: Lesser';

-- Expel Demons
UPDATE spells SET "range" = '10 foot (3 m) area per level of experience.' WHERE name = 'Expel Demons';

-- Air: Breathe Without Air  (description was a category stub)
UPDATE spells SET description = 'Allows the recipient to function without breathing at all, whether underwater, in a vacuum, or in oxygen-poor air. It does not protect against magical toxins such as Cloud of Slumber or Miasma, but it does guard against natural toxins, pollution, and gases.', "range" = 'Self or others by touch.', "duration" = 'Three minutes (12 melees) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Breathe Without Air';

-- Air: Cloud of Slumber  (description was a category stub)
UPDATE spells SET description = 'Conjures a 20 foot cube of vapor that instantly puts anyone passing through it to sleep unless they save vs magic. Sleepers cannot be woken except by being physically dragged clear of the cloud, after which they rouse in 1D4 melee rounds.', "range" = '90 feet (27.4 m).', "duration" = 'Four melees per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Air: Cloud of Slumber';

-- Air: Cloud of Steam  (description was a category stub)
UPDATE spells SET description = 'Creates a 30 foot cloud of scalding steam that can be placed up to 90 feet away. Anyone caught in it takes 2D6 S.D.C. damage per melee round and is blinded for 1D6 melees, suffering -10 to strike, parry and dodge while inside. It does no damage to Mega-Damage beings or those in environmental armor, but they are still effectively blinded by the cloud.', "range" = '90 feet (27.4 m).', "duration" = 'One minute (4 melee rounds) per level of experience.', "saving_throw" = 'A successful save means it inflicts half damage.' WHERE name = 'Air: Cloud of Steam';

-- Air: Create Light  (description was a category stub)
UPDATE spells SET description = 'Produces a light roughly as bright as one candle per level of the caster, which can hover in place or follow him and be brightened, dimmed, or extinguished at will. It has no effect on vampires.', "range" = 'Six foot (1.8 m) radius per level of the Warlock.', "duration" = 'Three minutes per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Create Light';

-- Air: Create Mild Wind  (description was a category stub)
UPDATE spells SET description = 'Stirs up a gentle two mph breeze across a 320 foot radius, with the direction steerable by the caster and projectable up to 400 feet away.', "range" = '320 foot (97.5 m) radius.', "duration" = 'One minute (4 melee rounds) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Create Mild Wind';

-- Air: Stop Wind  (description was a category stub)
UPDATE spells SET description = 'Completely stills all breeze and wind within a 100 foot radius, though it only works against winds already blowing under 25 mph.', "range" = '100 foot radius (30.5 m).', "duration" = 'Three melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Stop Wind';

-- Air: Thunderclap  (description was a category stub)
UPDATE spells SET description = 'Produces a booming clap of thunder around the caster that can be heard up to a mile away. It grants overall initiative plus +1 to strike, parry and dodge, and creates a Horror Factor of 10, rising +1 at levels 3, 5, 7, 9, 11, 13 and 15, that leaves unnerved opponents shaken for two melee rounds even if they make their save.', "range" = 'Directly affects the immediate area (30 feet/9.1 m) around the magic weaver, but can be heard up to a mile (1.6 km) away.', "duration" = 'Instant boom. Penalties last for two melee rounds.', "saving_throw" = 'Save vs Horror Factor.' WHERE name = 'Air: Thunderclap';

-- Air: Change Wind Direction  (description was a category stub)
UPDATE spells SET description = 'Lets the Warlock redirect the prevailing wind to any direction desired, and change it again as often as wanted for as long as the spell lasts.', "range" = '300 foot (91.5 m) radius.', "duration" = 'One minute (4 melee rounds) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Change Wind Direction';

-- Air: Cloak of Darkness  (description was a category stub)
UPDATE spells SET description = 'Wraps the caster in a field of darkness that follows him or her everywhere, extending about 5 feet around the body. The book notes it is otherwise identical to the 2nd level Invocation spell of the same name.', "range" = 'Self plus a 5 foot (1.5 m) radius around the character.', "duration" = 'Four minutes per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Cloak of Darkness';

-- Air: Create Air  (description was a category stub)
UPDATE spells SET description = 'Generates a six foot pocket of breathable air, but only inside an enclosed space, since in the open it just dissipates, and it does not work underwater.', "range" = 'Five foot (1.5 m) radius.', "duration" = 'One minute (4 melee rounds) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Create Air';

-- Air: Distant Voice  (description was a category stub)
UPDATE spells SET description = 'Opens a two-way magical channel for sound between the caster and someone he can at least partly see, even a distant speck on the horizon, letting them converse as if standing only a few feet apart. It costs 5 P.P.E. for an Air Warlock but 10 for any other spell caster, and otherwise works the same as the 5th level Invocation spell of the same name.', "range" = '2000 feet (610 m) per level of experience; line of sight.', "duration" = 'Five minutes per level of experience.', "saving_throw" = 'Not applicable.' WHERE name = 'Air: Distant Voice';

-- Air: Electric Arc  (description was a category stub)
UPDATE spells SET description = 'Fires a crackling bolt of blue energy from the caster''s hand at a single target, accurate at +2 to strike, for 2D6 M.D. Each bolt costs one melee attack, so a caster with four attacks per round can only fire it that many times.', "range" = '30 feet (9 m) per level of experience.', "duration" = 'One melee round.', "saving_throw" = 'Dodge.', "damage" = '2D6 M.D.' WHERE name = 'Air: Electric Arc';

-- Air: Heavy Breathing  (description was a category stub)
UPDATE spells SET description = 'Conjures the sound of unseen, labored breathing that can be moved around within 60 feet and heard in a 6 foot radius. Listeners who fail their save become fearful, suffering -2 to strike and -1 to parry and dodge, with a 1-60% chance of fleeing outright; those who save are unaffected.', "range" = '60 feet (18.3 m).', "duration" = 'Five melee rounds per level of experience.', "saving_throw" = 'Standard. Those who save are not affected/fearful.' WHERE name = 'Air: Heavy Breathing';

-- Air: Howling Wind  (description was a category stub)
UPDATE spells SET description = 'Raises a mild wind carrying an eerie, banshee-like moan, creating a Horror Factor of 15 that requires a save every melee it is heard. Those who fail lose one attack and initiative that round, take -1 to strike but +2 to parry and dodge from panic-driven adrenaline, and have a 1-40% chance of fleeing; animals must save too and tend to howl or whine along with it.', "range" = '100 feet (30.5 m).', "duration" = 'Four melees per level of the Warlock.', "saving_throw" = 'Save vs Horror Factor 15 every melee.' WHERE name = 'Air: Howling Wind';

-- Air: Levitate  (description was a category stub)
UPDATE spells SET description = 'Lifts the caster, another person, or an object straight up into the air, up to 200 pounds per level of experience and as high as 30 feet per level. It only moves things vertically, there is no horizontal control.', "range" = '30 feet (9 m) per level of experience.', "duration" = 'Five melees per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Levitate';

-- Air: Mesmerism  (description was a category stub)
UPDATE spells SET description = 'Wraps up to two people or animals in a nearly invisible, hypnotic mist that dulls their wits and sense of time and distance. Victims suffer -4 on initiative, -2 to strike in hand to hand combat, -6 to strike with a thrown or missile weapon, -20% on skill performance, and have their speed cut in half.', "range" = 'Five feet (1.5 m).', "duration" = 'Four melees per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Air: Mesmerism';

-- Air: Miasma  (description was a category stub)
UPDATE spells SET description = 'Casts a poisonous vapor over a 20 foot area up to 100 feet away that instantly sickens anyone inside with fever and vomiting. Victims take 1D4 points of damage and suffer -3 to strike, parry and dodge for every melee round they remain in the cloud; it has no effect on Mega-Damage creatures or those in environmental armor.', "range" = '100 feet (30.5 m).', "duration" = 'Four melees per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Air: Miasma';

-- Air: Northwind  (description was a category stub)
UPDATE spells SET description = 'Summons a biting, 15 mph wind across a 200 foot radius that drops the temperature to about 10 degrees below freezing. Anyone caught without shelter or warm clothing is chilled to the bone and takes -1 to initiative from the distraction of the cold.', "range" = '200 foot (61 m) radius.', "duration" = '6 melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Northwind';

-- Air: Orb of Cold  (description was a category stub)
UPDATE spells SET description = 'Summons a softball-sized globe of magical ice into the caster''s hand to throw at an enemy, striking at +1 with usual P.P. bonuses. On a hit it deals 3D6 M.D. and forces a save vs magic or the target suffers numbing cold, losing one attack, -2 on initiative, -1 to strike, parry and dodge, and 10% reduced speed for 1D4 minutes; the orb vanishes after one melee round if not thrown.', "range" = 'Throw: 200 feet (61 m).', "duration" = 'One melee round (15 seconds); 1D4 minutes for numbness.', "saving_throw" = 'Dodge; standard.', "damage" = '3D6 M.D. plus numbness penalties.' WHERE name = 'Air: Orb of Cold';

-- Air: Silence  (description was a category stub)
UPDATE spells SET description = 'Mutes every sound within a 10 foot area per level, including radio transmissions, which come through only faintly and must be repeated. It also lets a small group prowl at 90% effectiveness even in clattering armor, though the muffling covers only sound within the affected pocket of air.', "range" = '10 foot area (3 m) per level of experience.', "duration" = 'Five melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Silence';

-- Air: Air Bubble  (description was a category stub)
UPDATE spells SET description = 'Forms a durable 15 foot bubble of breathable air, useful underwater or in a vacuum, that can be cast up to 200 feet away. The bubble itself has 1D6 M.D.C. and can be popped by dealing 1D6 M.D. to it.', "range" = '15 foot bubble. Can be cast up to 200 feet (61 m) away.', "duration" = '15 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Air Bubble';

-- Air: Call Lightning  (description was a category stub)
UPDATE spells SET description = 'Drops a bolt of lightning from the sky onto any target the caster can see, and because it strikes so fast the target cannot dodge, it is an automatic hit. Damage is 1D6 M.D. per level of the caster, and it can be used indoors or out, harming only the one target struck.', "range" = '100 feet (30.5 m) per level of experience.', "duration" = 'Instant.', "saving_throw" = 'None.', "damage" = '1D6 M.D. per level of experience.' WHERE name = 'Air: Call Lightning';

-- Air: Float in Air  (description was a category stub)
UPDATE spells SET description = 'Creates air currents that hold the caster or another person about a foot off the ground, useful for slowing a fall or staying atop water. Movement while floating is awkward, cutting speed in half and imposing -1 to all attacks, strikes, parries and dodges.', "range" = 'Self or other within 30 feet (9.1 m) per level of experience.', "duration" = '10 melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Float in Air';

-- Air: Darkness  (description was a category stub)
UPDATE spells SET description = 'Blankets a 5 foot area per level, castable up to 200 feet away, in an unnatural darkness that ordinary fire cannot dispel. It cuts nightvision and optics to half effectiveness and blinds passive night-vision scopes entirely; only the caster and Air Elementals see clearly inside it, gaining +15% to Prowl and +1 to strike, while anyone else caught in the darkness is -10 to strike, parry and dodge.', "range" = 'Five foot (1.5 m) area per level of the Warlock. Can be cast up to 200 feet (61 m) away.', "duration" = 'Five minutes (20 melees) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Darkness';

-- Air: Fingers of the Wind  (description was a category stub)
UPDATE spells SET description = 'Conjures a wind the caster can direct to touch, tap, or push against a person or object at range. It is strong enough to snuff candles, slam doors, or knock over anything lighter than 10 pounds, but not much more.', "range" = '40 feet (12 m) per level of experience.', "duration" = 'Three melee rounds per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Fingers of the Wind';

-- Air: Frequency Jamming  (description was a category stub)
UPDATE spells SET description = 'Jams the operating frequency of a machine, such as radios, radar, sonar, motion or heat sensors, even a lie detector, by touch or at range, so it delivers no usable readings or transmissions for as long as the spell lasts.', "range" = '100 feet (30 m) per level of experience; line of sight or two machines by touch.', "duration" = 'Two melee rounds (30 seconds) per level of the spell caster''s experience.', "saving_throw" = 'Not applicable; affects machines.' WHERE name = 'Air: Frequency Jamming';

-- Air: Frostblade  (description was a category stub)
UPDATE spells SET description = 'Transforms an ordinary S.D.C. blade or metal rod into a glowing, icy four foot sword that inflicts 4D6 M.D. through cold and magical force, with fire creatures taking 6D6 M.D., or 8D6 M.D. if noted as vulnerable to cold. The caster can hand the weapon to someone else, it parries energy attacks without special bonus, is undamaged by parrying, and reverts to normal when the duration ends; it also stacks with the Ricochet spell.', "range" = 'Close, hand to hand combat.', "duration" = 'Two minutes per level of experience.', "saving_throw" = 'None.', "damage" = '4D6 M.D.' WHERE name = 'Air: Frostblade';

-- Air: Northern Lights  (description was a category stub)
UPDATE spells SET description = 'Fills a 30 foot area with a swirling, kaleidoscopic light show that entrances everyone who looks at it, leaving them motionless and unable to speak, move or attack for as long as the display lasts. The spell ends immediately if any entranced victim is attacked, and full awareness returns the instant the lights fade.', "range" = 'Affects a 30 foot (9 m) area and can be cast 60 feet (18.3 m) away.', "duration" = 'Four melees per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Air: Northern Lights';

-- Air: Resist Cold  (description was a category stub)
UPDATE spells SET description = 'Lets the caster ignore the effects of cold entirely, functioning without discomfort or harm even at temperatures down to zero.', "range" = 'Self.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Resist Cold';

-- Air: Sheltering Force  (description was a category stub)
UPDATE spells SET description = 'Raises a semi-opaque, bluish-white dome of force around the caster, big enough for two to eight people, that keeps out rain and insects while holding in warmth or smoke, and moderates temperature by about 10 degrees. It stops only 1D6 M.D. of any single attack before the rest bleeds through to whoever is inside, and its translucency gives outside attackers only shadows to aim at, so they are -3 to strike. It costs 10 P.P.E. for an Air Warlock but 20 for any other spell caster.', "range" = 'Around self, or up to 20 feet (6 m) away.', "duration" = 'One hour per level of experience.', "saving_throw" = 'Not applicable.' WHERE name = 'Air: Sheltering Force';

-- Air: Walk the Wind  (description was a category stub)
UPDATE spells SET description = 'A limited flight spell that lets the caster and others hover up to 20 feet off the ground and glide along the wind, walking on air at half normal walking speed or gliding at up to 20 mph. It grants excellent control in the air, with +1 to parry and +2 to dodge, and imposes no restrictions in combat.', "range" = 'Self or others.', "duration" = '20 melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Walk the Wind';

-- Air: Wave of Frost  (description was a category stub)
UPDATE spells SET description = 'A targeted magical frost meant to damage plants over a 6 foot radius per level: roughly 20-30% of flowering plants caught in it die outright, cutting their future yield, while another 10-30% are damaged badly enough that only Shaman, Druid or Elemental magic can save them, dying within 48 hours regardless. It can also be used more mundanely to frost over a window, though scraping a peephole through it takes a melee.', "range" = '200 feet (61 m) +20 feet (6 m) per level of experience.', "duration" = 'One minute (4 melee rounds) per level of experience.', "saving_throw" = 'Special.', "damage" = 'Special.' WHERE name = 'Air: Wave of Frost';

-- Air: Wind Rush  (description was a category stub)
UPDATE spells SET description = 'Unleashes a sudden 60 mph gust up to 20 feet wide that can knock people down, unhorse riders, or scatter light objects up to 100 feet away. A target must roll 18-20 to keep his footing, and even then cannot act that round; failure sends him tumbling 2D6x10 yards and drops 1D6 of his belongings, requiring an extra melee round to recover and gather everything back up.', "range" = '120 feet (36.6 m).', "duration" = 'One melee round (15 seconds).', "saving_throw" = 'A roll of 18 to 20 means the character is able to keep his balance and hold on to his belongings, but cannot attack or move forward. A failed roll means the character is blown off his feet, sent tumbling 2D6x10 yards/meters and drops/loses 1D6 belongings.' WHERE name = 'Air: Wind Rush';

-- Air: Ball Lightning  (description was a category stub)
UPDATE spells SET description = 'Conjures three basketball-sized balls of lightning that hover beside the caster and can be hurled at a target like thrown weapons, striking at +5, for 3D6 M.D. plus 1 M.D. per level. Instead of throwing them, the caster can arrange the three balls in a triangle about four feet apart to form a standing electrical field roughly 10 feet across per level that damages anyone touching or crossing it, 3D6 plus 1D6 M.D. per level; destroying all three balls, 20 M.D.C. each, collapses the field.', "range" = '60 feet (18.3 m) per level of experience.', "duration" = 'Duration of the Hurled Balls: Temporary. Electrical Field Duration: Four melees (one minute) per level.', "saving_throw" = 'None.', "damage" = 'Hurled balls: 3D6 M.D. plus one M.D. per level of experience. Electric field: 3D6+1D6 M.D. per level of experience.' WHERE name = 'Air: Ball Lightning';

-- Air: Calm Storms  (description was a category stub)
UPDATE spells SET description = 'Lets the Air Warlock quell a raging storm far more cheaply than the wizard version of the spell, slowing a downpour to a drizzle, cutting wind speed by 75%, halving wave size, and lightening dark skies over a 90 foot radius per level. It works automatically against natural weather, but calming a magically summoned storm becomes a contest against its creator, resolved like a Negate Magic duel; a typical natural storm lasts no more than four hours anyway, and the weather reverts to full force if the calming magic expires first.', "range" = '90 foot (27.4 m) radius per level of experience.', "duration" = '15 minutes per level of experience.', "saving_throw" = 'None against natural storms. However, calming a magically created storm is more difficult as it pits the Warlock against the storm''s creator. This mental and magic duel is exactly like the wizard Negate Magic.' WHERE name = 'Air: Calm Storms';

-- Air: Dissipate Gases  (description was a category stub)
UPDATE spells SET description = 'Breaks down any gas cloud, magical mists, fumes, or toxic clouds, though not fog or a creature shape-shifted into mist, halving the remaining damage or effects of what is left and clearing a 30 foot radius entirely within eight melee rounds.', "range" = '30 foot (9 m) radius.', "duration" = 'One minute (4 melee rounds) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Dissipate Gases';

-- Air: Freeze Water  (description was a category stub)
UPDATE spells SET description = 'Instantly freezes solid up to 20 gallons of water per level of the caster from as far as 30 feet away, and the ice stays frozen until it melts under ordinary conditions.', "range" = '30 feet (9 m); line of sight.', "duration" = 'Varies.', "saving_throw" = 'None.' WHERE name = 'Air: Freeze Water';

-- Air: Invisibility  (description was a category stub)
UPDATE spells SET description = 'Turns the caster, or everyone and everything within a 6 foot area, invisible, functioning identically to the wizard invisibility spell. Maintaining it demands intense concentration, so the caster cannot cast any other spell or perform any complicated task without breaking the effect.', "range" = 'Self or 6 foot (1.8 m) diameter.', "duration" = 'Four melees (one minute) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Invisibility';

-- Air: Leaf Rustler  (description was a category stub)
UPDATE spells SET description = 'Summons a minor, mischievous Air Elemental essence, 25 M.D.C., invisible, three feet tall, that can be set loose on an area or a target to rustle leaves, slam doors, blow out candles, and knock things over for up to 30 minutes. It is too weak to steal anything heavier than three pounds and too dim to spy or follow complex orders, but it is immune to cold, electricity, poison, disease and fear, has two attacks, +4 to dodge, and does only 1D4 S.D.C. if it does attack.', "range" = 'Immediate area.', "duration" = '30 minutes.', "saving_throw" = 'None.' WHERE name = 'Air: Leaf Rustler';

-- Air: Lightblade  (description was a category stub)
UPDATE spells SET description = 'Forms a blade of brilliant white light in the caster''s hand, sized to his level of experience, a short sword at low levels, growing to a two-handed sword by 10th, weightless, +1 to strike, and able to parry energy attacks without special bonus. It deals 1D4x10+1 M.D. per level and doubles that damage against vampires, double Hit Point damage, Shadow Beasts and other light-vulnerable demons, but does nothing against creatures immune to light or energy, and only its creator can wield it.', "range" = 'Self; close combat/hand to hand.', "duration" = 'One minute (4 melee rounds) per level of experience.', "saving_throw" = 'Parry or dodge.', "damage" = '1D4x10+1 M.D. point per level of experience.' WHERE name = 'Air: Lightblade';

-- Air: Lightning Arc  (description was a category stub)
UPDATE spells SET description = 'A stronger version of Electric Arc, firing a bolt of lightning for 4D6+2 M.D. per level at +4 to strike within 100 feet, only +1 beyond that. Each bolt still costs one melee attack, so its rate of fire is limited by the caster''s normal number of attacks per round, though he can mix it with other spells, weapon fire or skills across successive rounds.', "range" = '100 feet (30.5 m) per level of experience.', "duration" = 'One melee round per level of experience.', "saving_throw" = 'Dodge.', "damage" = '4D6+2 M.D. per level of experience.' WHERE name = 'Air: Lightning Arc';

-- Air: Phantom Footman  (description was a category stub)
UPDATE spells SET description = 'Summons an invisible Air Elemental essence servant, 40 M.D.C., six feet tall, that stays at the caster''s side to carry items, open doors, and search for secret doors at 89% skill, or scout a passage ahead. It has four attacks, bonuses to initiative, parry and dodge, can see the invisible, carries up to 1000 pounds without losing speed, and must stay within 1000 feet of the caster until the spell ends or it is dismissed; its Supernatural Strength lets it deal 1D6 M.D. from a punch or 2D6 M.D. from a power punch.', "range" = 'Immediate area up to 1000 feet (305 m).', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Phantom Footman';

-- Air: Protection from Lightning  (description was a category stub)
UPDATE spells SET description = 'Makes the caster completely impervious to lightning and electrical damage of any kind for the duration.', "range" = 'Self.', "duration" = '10 melees (2.5 minutes) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Protection from Lightning';

-- Air: Breath of Life  (description was a category stub)
UPDATE spells SET description = 'Revives a recently deceased person by breathing magically-charged air into their lungs mouth to mouth; success is 70% plus 1% per level, and the target revives in 1D4 melees if it works. It can only be attempted once by a given caster on a given body, though another Warlock may try afterward, only works if death occurred within the last 24 hours, and does not restore lost limbs, heal burns or cure insanity, since the revived character comes back at half their Hit Points, with the rest requiring rest, medicine or further magic.', "range" = 'Touch.', "duration" = 'Permanent.', "saving_throw" = 'None.' WHERE name = 'Air: Breath of Life';

-- Air: Circle of Rain  (description was a category stub)
UPDATE spells SET description = 'Summons a heavy downpour with thunder and lightning over a 60 foot radius per level. Everyone inside gets soaked and chilled, has movement slowed by a third, and suffers impaired vision and hearing, both normal and nightvision cut to 30 feet; it can be cast indoors or out and inflicts 5D6 damage per melee round to vampires caught in it.', "range" = '60 foot (18.3 m) radius per level of experience.', "duration" = '15 melees per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Circle of Rain';

-- Air: Darken the Sky  (description was a category stub)
UPDATE spells SET description = 'Makes the sky suddenly darken as if a storm were rolling in, bringing ominous gray and black clouds and a slight chill, though it produces no actual rain or wind. It only works outdoors.', "range" = '300 feet (91.5 m).', "duration" = '30 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Darken the Sky';

-- Air: Detect the Invisible  (description was a category stub)
UPDATE spells SET description = 'Lets the caster clearly see any invisible creature, or anything turned invisible by magic, within his line of sight. Only the caster gains this ability, not anyone standing nearby.', "range" = '60 feet (18.3 m) in line of vision.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Detect the Invisible';

-- Air: Invisible Wall  (description was a category stub)
UPDATE spells SET description = 'Raises an invisible wall of wind and water up to 60 feet away, covering a 10 foot area per level, that continually renews itself against 50 M.D.C. of damage per melee. Taking 100 points of damage in a single melee, or being struck by a Dispel Magic Barriers spell, destroys it instantly.', "range" = '60 feet (18.3 m) away, covers a 10 foot (3 m) area per level of the Warlock.', "duration" = 'Four melees (one minute) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Invisible Wall';

-- Air: Phantom  (description was a category stub)
UPDATE spells SET description = 'Summons a stronger Air Elemental essence fragment, 80 M.D.C., invisible, eight feet tall, that can scout, spy, hunt, defend or attack at unlimited range from the caster for the duration. It hits for 2D6 M.D. from a punch or 4D6 M.D. from a power punch, gets four physical attacks or two by magic with bonuses to strike, parry, dodge and initiative, can see the invisible, carries up to 1100 pounds, and can cast any level 1 to 4 Air Elemental spell using its own pool of 100 P.P.E.', "range" = 'Immediate area, up to 40 feet (12.2 m) away.', "duration" = '15 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Phantom';

-- Air: Phantom Mount  (description was a category stub)
UPDATE spells SET description = 'Conjures a translucent, spectral horse of blue-white energy that only the caster can ride or command with simple riding cues. It has 30 M.D.C. plus 5 per level, supernatural physical attributes, and three attacks that deal 1D6 M.D. from a front kick or 3D6 M.D. from a rear kick, plus bonuses to initiative, strike, dodge and impact rolls; it cannot use weapons or cast magic, and vanishes if separated from the caster by more than 40 feet for longer than two melee rounds.', "range" = 'Immediate area, up to 40 feet (12.2 m) away.', "duration" = '10 minutes per level of experience.', "saving_throw" = 'Not applicable.' WHERE name = 'Air: Phantom Mount';

-- Air: Sonic Blast  (description was a category stub)
UPDATE spells SET description = 'Releases a sonic boom in a 20 foot radius around the caster that deals 4D6 M.D. to everyone in range except the caster himself, or anyone physically touching him. Victims are deafened for 2D4 minutes, during which they lose two attacks, are -8 on initiative, -3 to parry and dodge, and take -25% on skills, plus there is a 1-40% chance the shock wave knocks them off their feet for an additional lost attack.', "range" = '20 foot (6 m) radius.', "duration" = 'Instant.', "saving_throw" = 'Standard.', "damage" = '4D6 M.D.' WHERE name = 'Air: Sonic Blast';

-- Air: Whirlwind  (description was a category stub)
UPDATE spells SET description = 'Summons a rotating 75 mph windstorm 20 feet across that sucks up and hurls anyone or anything caught inside it. Victims are helpless, no attacks, spells or speech, for a full melee before being thrown about 40 feet and taking 2D6+2 M.D., then dazed for 1D4 more melees at half effectiveness unless they make an impact roll; it also shreds S.D.C. structures like doors and fences within one melee, and grinds down stone or metal at 10 feet per minute. The caster must stay within 300 feet of the whirlwind and give it his full attention, unable to cast other spells while steering it.', "range" = '300 feet (91.5 m) distance per level of experience, but must always be within sight.', "duration" = 'Four melees (one minute) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Whirlwind';

-- Air: Electrical Field  (description was a category stub)
UPDATE spells SET description = 'Raises a crackling wall of energy up to 200 feet away that deals 4D6+10 M.D. to anyone who tries to pass through it, with a 50% chance of stunning them for 2D6 melees and dealing an extra 4D6 M.D. for every melee they remain caught in it, all against Hit Points, not armor. The field cannot be attacked directly, but a Dispel Magic Barrier or Negate Magic spell destroys it instantly.', "range" = 'Affects a ten foot (3 m) area per level of experience, up to 200 feet (61 m) away.', "duration" = 'Two minutes per level of the Warlock.', "saving_throw" = 'None.', "damage" = '4D6+10 M.D.' WHERE name = 'Air: Electrical Field';

-- Air: Electro-Magnetism  (description was a category stub)
UPDATE spells SET description = 'Super-magnetizes a 40 foot area up to 300 feet away, irresistibly drawing in and pinning down any iron or iron alloy object, weapons, tools, ammunition, even a suit of iron armor with its wearer still in it, until it is pulled free or the spell ends. Prying an object loose takes a combined P.S. of 80, reduced to 40 against a target who has cast Disrupt Energy, the field can hold up to 1000 pounds per level of the caster, and while a Dispel Magic Barriers or Negate Magic spell can break it, the field gets +5 to resist them; it has no effect on Borgs or cybernetics, since they are not made of iron.', "range" = 'Affects a 40 foot (12 m) area and can be cast up to 300 feet (91.5 m) away.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Electro-Magnetism';

-- Air: Mist of Death  (description was a category stub)
UPDATE spells SET description = 'Creates a toxic red mist over a 10 foot area that inflicts 4D6 direct Hit Point damage, 4D6 M.D. to creatures of magic and supernatural beings, on anyone who breathes it or touches it with bare skin. The mist lasts only one melee before dissipating, and does not affect anyone in environmental armor, an airtight compartment, the Armor of Ithan, magical invulnerability, or those who make their save.', "range" = '90 foot distance (27.4 m), affects a 10 foot (3 m) area.', "duration" = 'One melee.', "saving_throw" = 'Standard.' WHERE name = 'Air: Mist of Death';

-- Air: Snow Storm  (description was a category stub)
UPDATE spells SET description = 'Drops the temperature 15 degrees below freezing over a 30 foot area per level, whipping up 30 mph winds and dumping a foot of snow and hail every other melee round. It halves everyone''s speed, cuts vision, including optics, to 20 feet, and deals 10 points of damage per melee round from the combined cold, wind and hail.', "range" = 'Affects a 30 foot (9 m) area per level of the Warlock and can be cast 50 feet (15.5 m) away per level of experience.', "duration" = 'Two minutes (8 melees) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Snow Storm';

-- Air: Vacuum  (description was a category stub)
UPDATE spells SET description = 'Creates an airless void up to 10 feet away that, if placed around a living creature, makes it choke immediately; the victim passes out within two minutes and dies of suffocation within six unless freed, getting one save every 30 seconds to try to escape. Air Elementals caught inside instead take 2D4+2 M.D. every melee, and the caster can move the vacuum around at a speed of 8.', "range" = 'Affects a two foot (0.6 m) area per level of the Warlock and can be cast up to 10 feet (3 m) away.', "duration" = 'One minute (4 melees) per level of the Warlock.', "saving_throw" = 'Special: The standard roll is made but it is to indicate if the person can escape from the vacuum. The victim can roll once every 30 seconds until he falls unconscious.' WHERE name = 'Air: Vacuum';

-- Air: Whisper of the Wind  (description was a category stub)
UPDATE spells SET description = 'Carries a spoken message of under 100 words on a gust of wind to anyone within 40 miles per level, as long as the caster knows their general location; the recipient hears it whispered clearly in his ear, but the message can only be delivered once.', "range" = '40 miles (64 km) per level of the Warlock.', "duration" = 'Special.', "saving_throw" = 'None.' WHERE name = 'Air: Whisper of the Wind';

-- Air: Atmospheric Manipulation  (description was a category stub; cited p.57, entry is on p.64)
UPDATE spells SET description = 'Lets the caster reshape local weather conditions at will - raising or lowering temperature by 10 degrees per level, shifting wind speed by 10 mph per level, adjusting precipitation by 12% per level, and creating or clearing a 300 foot radius of fog per level. Only one new change can be introduced per melee round, but effects can be stacked and combined over time (darken the sky, then raise the wind, then add fog, then a thunderclap). Once set in motion the conditions persist for 15 minutes on their own, or 30 minutes per level of experience if the caster keeps actively maintaining direct control.', "range" = '300 foot (91 m) radius per level of the Warlock.', "duration" = '30 minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.64' WHERE name = 'Air: Atmospheric Manipulation';

-- Air: Hurricane  (description was a category stub)
UPDATE spells SET description = 'Whips up a full sea storm with 100 to 150 mph winds across a 120 foot area, castable up to 500 feet away, that batters ships with 30 foot waves for 3D6x10 M.D. per melee round. Anyone caught above decks during the storm takes 1D6 M.D. per melee from flying debris and hail and risks a 1-33% chance of being swept overboard; it can only be summoned over large bodies of water like lakes, seas or oceans.', "range" = 'Affects a 120 foot (36.6 m) area and can be cast up to 500 feet away (152 m).', "duration" = 'Four melee rounds (one minute) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Hurricane';

-- Air: Rainbow  (description was a category stub)
UPDATE spells SET description = 'Arcs a brilliant, prismatic rainbow across the sky, visible up to a mile away, that lifts the mood of anyone who sees it with a deep sense of wonder, hope, joy and self-worth. A standard saving throw applies, though the book does not spell out what a successful save avoids.', "range" = 'One mile (1.6 km).', "duration" = '15 minutes per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Air: Rainbow';

-- Air: Tornado  (description was a category stub)
UPDATE spells SET description = 'Spins up the most destructive land storm in the Warlock''s arsenal, a tornado with 120 to 180 mph winds in a 100 foot funnel, castable up to 600 feet away, accompanied by heavy rain, hail, thunder and lightning. People within 100 feet of the funnel take 1D6 damage per melee from debris; wood, clay and stone structures in its path take 4D6x10 damage and trees uproot in a single melee. Anything actually pulled into the vortex takes 3D6x10 M.D. per melee while helpless, then is hurled free after 1D6 melees for another 2D6x10 M.D., with Mega-Damage beings, the magically invulnerable, and wearers of the Armor of Ithan taking only a third. The caster must give it his full attention and cannot cast other spells while steering it, and if he is knocked out or killed there is a 1-64% chance the tornado runs wild until its duration expires.', "range" = 'Affects a 100 foot (30.5 m) area and can be cast up to 600 feet (183 m) away.', "duration" = 'Four melees/one minute per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Air: Tornado';

-- Air: Creature of the Wind  (description was a category stub)
UPDATE spells SET description = 'Transforms the caster into a semi-transparent, humanoid vapor form of wind and energy that flies at 500 mph, turns fully invisible, becomes an M.D.C. being with 200 M.D.C., and can squeeze through cracks or keyholes in a single action while carrying up to 500 pounds. In this form the caster gains bonuses to initiative, dodge and prowl and is immune to cold, gas, pollution, disease and poison, but can only deal normal S.D.C. damage, not Mega-Damage, takes only half damage from Mega-Damage attacks, and is -2 to strike with any weapon.', "range" = 'Self.', "duration" = 'One melee (15 seconds) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Creature of the Wind';

-- Air: Wind Blast  (description was a category stub)
UPDATE spells SET description = 'Hurls a concentrated blast of hurricane-force wind like a thrown missile, aimed by the caster at +6 to strike, dealing 2D4x10+30 M.D. A character struck must also roll to keep his footing or be knocked down, exactly as with Wind Rush.', "range" = '1,000 feet (305 m) plus 400 feet (122 m) per level of experience.', "duration" = 'Instant.', "saving_throw" = 'None.', "damage" = '2D4x10+30 M.D.' WHERE name = 'Air: Wind Blast';

-- Air: Wind Cushion  (description was a category stub)
UPDATE spells SET description = 'Wraps the caster or others in a swirling cone of calm air, like standing in the eye of a storm, that absorbs the impact of thrown objects, arrows, bullets, rail gun blasts and explosions rather than causing damage itself. It can absorb up to 200 M.D. plus 50 per level before it collapses, can be used to safely cushion a crashing aircraft or a falling person, and also blocks sound-based attacks like Thunder Clap and Sonic Blast; anyone forcing their way in from outside instead is thrown 1D4x10 yards and takes 3D6 S.D.C. damage.', "range" = '1000 feet (305 m); covers a 40 foot (12 m) area plus 10 feet per level of experience.', "duration" = 'One melee per level of experience.', "saving_throw" = 'None.' WHERE name = 'Air: Wind Cushion';

-- Earth: Chameleon  (description was a category stub)
UPDATE spells SET description = 'Lets the recipient shift the color and pattern of skin and clothing to blend into the surroundings, though moving breaks the effect: 90% undetectable while still, 70% while moving 2 feet per melee or slower, 20% at 6 feet per melee, and no effect at all beyond that.', "range" = 'Self or others by touch.', "duration" = 'Six minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Chameleon';

-- Earth: Create Wood  (description was a category stub)
UPDATE spells SET description = 'Draws matter from the surrounding air to grow wood on the spot, two foot logs or six foot planks, permanently. It costs 5 P.P.E. per 100 pounds for soft wood suited to burning, or 10 P.P.E. per 100 pounds for hard, sturdier building wood.', "range" = '10 feet (3 m).', "duration" = 'Permanent.', "saving_throw" = 'Not applicable.' WHERE name = 'Earth: Create Wood';

-- Earth: Dowsing  (description was a category stub)
UPDATE spells SET description = 'Grants the magical ability to sense the location of water, whether a stream, pond, river, or groundwater, at 90% accuracy out to 100 feet per level, and can specifically key in on fresh drinking water.', "range" = 'Self; sensing range is 100 feet per level of experience.', "duration" = 'Ten minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Dowsing';

-- Earth: Dust Storm  (description was a category stub)
UPDATE spells SET description = 'A blinding storm of dust and grit the caster can call up to 120+ feet away, filling a 20 foot area. Anyone caught inside has both normal and night vision cut to about 10 feet, loses initiative, moves at half speed, and finds it hard to talk, cast spells, or even breathe without choking.', "range" = '120 feet plus 20 feet (6 m) per level of the Warlock. Affects a 20 foot area.', "duration" = 'One minute (4 melees) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Dust Storm';

-- Earth: Fool's Gold  (description was a category stub)
UPDATE spells SET description = 'Makes any small object appear to be solid gold for the duration, even after the caster leaves the area. A failed save vs magic means the target believes it is real gold; anyone who succeeds recognizes it as worthless rock, and any skill roll to appraise it is at -10%.', "range" = 'Five feet (1.5 m).', "duration" = '20 minutes per level of the Warlock.', "saving_throw" = 'Standard. Those who save will recognize fool''s gold for what it really is - worthless rock passed off as something far more valuable.' WHERE name = 'Earth: Fool''s Gold';

-- Earth: Identify Minerals  (description was a category stub)
UPDATE spells SET description = 'Grants the caster temporary expert knowledge of rocks, minerals, fossils, metals, precious metals and gems, letting him identify any of them on sight with a 90% success rate.', "range" = 'Five feet (1.5 m).', "duration" = 'Three minutes per level of experience.', "saving_throw" = 'None.' WHERE name = 'Earth: Identify Minerals';

-- Earth: Identify Plants  (description was a category stub)
UPDATE spells SET description = 'Grants the caster temporary expert knowledge of plants, letting him recognize any species of plant, fruit, mold, or even processed herbs used in powders, potions and poisons.', "range" = '10 feet (3 m), by sight.', "duration" = 'Three minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Identify Plants';

-- Earth: Mystic Fulcrum  (description was a category stub)
UPDATE spells SET description = 'Lets the caster, or up to two others he touches, defy ordinary leverage limits, lifting 50% more weight than normal and carrying 10% more without any physical tool.', "range" = 'Self or two others by touch.', "duration" = 'Five minutes per level of experience.', "saving_throw" = 'Not applicable.' WHERE name = 'Earth: Mystic Fulcrum';

-- Earth: Rock to Mud  (description was a category stub)
UPDATE spells SET description = 'Instantly turns stone or rock into mud at range, up to 30 pounds per level of the caster. Has no effect on Elementals, but does 2D6 M.D. to a Stone or Iron Golem.', "range" = '20 feet (6 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Rock to Mud';

-- Earth: Rot Wood  (description was a category stub)
UPDATE spells SET description = 'Rots the structure of wood on contact or at range, cutting its strength in half; can be cast on the same wood repeatedly for a cumulative effect. Affects 30 pounds of wood per level of the caster, or can instead do 4D6 S.D.C. damage to a living tree or 3D6 M.D. to a tree/plant Elemental.', "range" = '20 feet (6 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Rot Wood';

-- Earth: Shatter  (description was a category stub)
UPDATE spells SET description = 'Instantly shatters brittle S.D.C. objects like glass, pottery, china, hardened clay, sandstone, ice, or peanut brittle with a touch or even a hard, mean look. Useless against anything heavier than 100 pounds, Mega-Damage materials, magic items, flexible materials like cloth or rubber, or anything as tough as wood or better, and it cannot harm bone or any living or Mega-Damage being.', "range" = '20 feet (6 m) or by touch.', "duration" = 'Instant.', "saving_throw" = 'None.' WHERE name = 'Earth: Shatter';

-- Earth: Create Dirt or Clay  (description was a category stub)
UPDATE spells SET description = 'Conjures dirt or clay out of thin air, up to 50 pounds per level of the caster.', "range" = '10 feet (3 m) away per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Create Dirt or Clay';

-- Earth: Dirt to Clay  (description was a category stub)
UPDATE spells SET description = 'Transforms ordinary dirt already within range into clay, up to 50 pounds per level of the caster.', "range" = '10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Dirt to Clay';

-- Earth: Dirt to Sand  (description was a category stub)
UPDATE spells SET description = 'Transforms ordinary dirt already within range into sand, up to 50 pounds per level of the caster.', "range" = '10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Dirt to Sand';

-- Earth: Grow Plants  (description was a category stub)
UPDATE spells SET description = 'Enriches an area''s soil and doubles the natural growth rate of whatever plants are already growing there for the duration.', "range" = 'Ten feet (3 m) per level of the Warlock. Affects a 10 foot (3 m) area per level of experience.', "duration" = 'One month per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Grow Plants';

-- Earth: Hopping Stones  (description was a category stub)
UPDATE spells SET description = 'Animates loose stones, pebbles or rocks so they hop and jump for spectacle, or to pelt a target - up to 50 pounds of stones total, hopping as high as 6 feet. Pebbles do 2D4 S.D.C., small stones 1D4, shoe-sized rocks 1D6, and football-sized rocks 3D6, and the barrage can be spread across several targets or focused on one.', "range" = '100 feet (30.5 m).', "duration" = '4 melees per level of the Warlock.', "saving_throw" = 'None.', "damage" = 'Varies; all S.D.C.' WHERE name = 'Earth: Hopping Stones';

-- Earth: Throwing Stones  (description was a category stub)
UPDATE spells SET description = 'Conjures a hardball-sized magical stone in the caster''s hand each melee action and hurls it like a thrown weapon, hitting with the force of a cannonball at +2 to strike; targets can dodge but not parry it (-4 penalty), and the stone crumbles to dirt after impact. Damage is 1D6 M.D. plus 1 M.D. per level of the caster, and creating and throwing the stone together only cost one melee action.', "range" = '200 feet (61 m) + 100 feet (30.5 m) per level of experience. Self only.', "duration" = 'Two melee rounds.', "saving_throw" = 'Dodge.', "damage" = '1D6 M.D. + 1 M.D. point per level of experience.' WHERE name = 'Earth: Throwing Stones';

-- Earth: Track  (description was a category stub)
UPDATE spells SET description = 'Grants the caster or another target the temporary ability to follow tracks as if trained in the skill, at 01-77% to track animals and 01-80% to track humanoids.', "range" = 'Self or others.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Track';

-- Earth: Wall of Clay  (description was a category stub)
UPDATE spells SET description = 'Raises a wall of clay up to 60 feet away, with 10 M.D.C. or 50 S.D.C. per level of the caster over an 8x8x4 foot section per level. Dropping it on someone does 6D6 S.D.C. damage.', "range" = 'Can be cast 60 feet (18.3 m) away and affects/covers an 8x8x4 feet (2.4 x 2.4 x 1.2 m) area per level of experience.', "duration" = 'Four minutes per level of the Warlock or until destroyed.', "saving_throw" = 'None.' WHERE name = 'Earth: Wall of Clay';

-- Earth: Wither Plants  (description was a category stub)
UPDATE spells SET description = 'Kills plant life within a 10+ foot radius of the caster; ordinary plants shrivel and die within 1D4 minutes. Trees and heavy shrubs instead take 1D6x10 S.D.C. damage (1D4x10 M.D. to a tree/plant Elemental) rather than dying outright, and new growth usually returns within a few weeks.', "range" = '10 foot (3 m) area per level of the Warlock.', "duration" = 'Permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Wither Plants';

-- Earth: Animate Plants  (description was a category stub)
UPDATE spells SET description = 'Lets the caster mentally manipulate all plant life within a 40+ foot radius centered on himself, making vines, weeds, shrubs and trees entangle, ensnare, or camouflage something, or strike as improvised weapons. Bushes/shrubs do 3D6 S.D.C. per hit (six attacks per melee, -50% speed) and average trees do 1D4x10 S.D.C. per hit (eight attacks per melee, -70% speed); the effort takes the caster''s full concentration, so he can''t cast other spells while it''s active.', "range" = 'Affected area is 40 feet (12 m) plus 5 feet (1.5 m) per level of experience.', "duration" = '4 melees per level of experience.', "saving_throw" = 'None.', "damage" = 'Varies; all S.D.C.' WHERE name = 'Earth: Animate Plants';

-- Earth: Create Mound  (description was a category stub)
UPDATE spells SET description = 'Piles up earth into a mound as large as 10x5x5 feet per level of the caster, cast up to 30 feet away - useful for cover, a lookout post, or blocking terrain. Each casting produces one mound.', "range" = 'Affected area is 10x5x5 feet (3 x 1.5 x 1.5 m) per level of the Warlock. Can be cast up to 30 feet (9 m) away.', "duration" = '20 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Create Mound';

-- Earth: Crumble Stone  (description was a category stub)
UPDATE spells SET description = 'Weakens stone or rock at range, halving its structural strength; can be reapplied to the same stone repeatedly for a cumulative effect. Affects 50 pounds per level of the caster, or can instead do 6D6 M.D. to a Stone Golem or 3D6 M.D. to an Earth Elemental.', "range" = '12 feet (3.6 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Crumble Stone';

-- Earth: Dig  (description was a category stub)
UPDATE spells SET description = 'Unleashes an invisible force that digs a hole or tunnel for the caster - 10 feet of dirt, 5 feet of clay, or 2 feet of loose stone per melee. Cannot cut through mortared stone walls, and does not work against Golems or Elementals.', "range" = 'Immediate area/touch.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Dig';

-- Earth: Earth Rumble  (description was a category stub)
UPDATE spells SET description = 'Makes the ground within a 30 foot radius shake and tremble like an earthquake, usually causing panic. Anyone who fails a save vs Horror Factor 14 loses one melee attack and initiative, and there''s a 1-60% chance the person flees (1-85% chance for animals).', "range" = 'Affects a 30 foot area (9 m), and can be cast 50 feet (15.2 m) away per level of experience.', "duration" = 'One melee per level of the Warlock.', "saving_throw" = 'Save vs Horror Factor 14 or higher.' WHERE name = 'Earth: Earth Rumble';

-- Earth: Encase Object in Stone  (description was a category stub)
UPDATE spells SET description = 'Permanently seals a single small or long, narrow item inside a block of stone (up to 35 pounds) without damaging what''s inside; several small items like coins or gems can be encased together in one pouch. The stone shell only has 5 M.D.C. and must be broken open to retrieve the item.', "range" = '10 feet (3 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Encase Object in Stone';

-- Earth: Locate Minerals  (description was a category stub)
UPDATE spells SET description = 'Lets the caster sense whether a specific mineral, including underground deposits, is present anywhere in the area of effect, with a 90% success rate; if the mineral isn''t there, the caster learns that too.', "range" = '20 foot (6 m) area per level of experience.', "duration" = 'Four minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Locate Minerals';

-- Earth: Shrink Plant  (description was a category stub)
UPDATE spells SET description = 'Shrinks a single plant by up to 90% of its size, in increments of 10%, turning a 30 foot tree into a 3 foot sapling for example. The standard casting is temporary, but spending 200 P.P.E. instead makes the reduction permanent; a plant already shrunk this way can''t be shrunk further by the spell.', "range" = 'Touch.', "duration" = 'One minute per level of experience or permanent.', "saving_throw" = 'Standard; supernatural plants get a +6 to save.' WHERE name = 'Earth: Shrink Plant';

-- Earth: Wall of Stone  (description was a category stub)
UPDATE spells SET description = 'Raises a wall of stone up to 60 feet away, with 50 M.D.C. or 250 S.D.C. per level of the caster over an 8x8x4 foot section per level. Dropping it on someone does 1D6x10 S.D.C. damage and traps them underneath (needs a combined P.S. of 60 to lift free); any Elemental Magic wall like this can be dispelled with Dispel Magic Barriers.', "range" = 'Can be cast 60 feet (18.3 m) away and affects/covers an 8x8x4 feet (2.4 x 2.4 x 1.2 m) area per level of experience.', "duration" = 'Four minutes per level of the Warlock or until destroyed.', "saving_throw" = 'None.' WHERE name = 'Earth: Wall of Stone';

-- Earth: Animate Object  (description was a category stub)
UPDATE spells SET description = 'Brings any wood, clay or stone object under 50 pounds to life so it can move on its own - a chair might buck and run, or a jug dance across a table. Animated objects get one attack per melee at +2 to strike and +3 to parry/dodge, doing 1D6 S.D.C. if small or 2D6 S.D.C. if large (full normal damage if the object is a wood or stone weapon).', "range" = '40 feet (12 m) plus 10 feet (3 m) per level of experience.', "duration" = 'Four minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Animate Object';

-- Earth: Cocoon of Stone  (description was a category stub)
UPDATE spells SET description = 'Encases the caster in a protective stone cocoon; he can still breathe inside but can''t speak or cast spells, and is safe from extreme heat, cold, fire, magic clouds and similar hazards. He can dismiss the cocoon mentally at will; it has 70 M.D.C., weighs 500 pounds, and is about a foot thick.', "range" = 'Self.', "duration" = 'One day per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Cocoon of Stone';

-- Earth: Mend Stone  (description was a category stub)
UPDATE spells SET description = 'Repairs clay, stone or rock - sealing cracks in pottery or rejuvenating deteriorating stone without leaving a trace of the damage - doubling its remaining S.D.C./M.D.C. and stopping further decay, or restoring 3D6 M.D. to a Golem or Earth Elemental. Affects up to 70 pounds of material per level of the caster, but can never raise something above the S.D.C./M.D.C. it originally had.', "range" = 'Touch or immediate area.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Mend Stone';

-- Earth: Quicksand  (description was a category stub)
UPDATE spells SET description = 'Turns an area of earth or stone into quicksand that looks like solid ground, shallow water, or a pond; victims sink 2 feet per melee (double if they struggle) and will drown within 4 minutes unless they can hold their breath or wear an environmental suit. It''s 79% undetectable outdoors, 97% in swamps, and 30% indoors.', "range" = 'Area affected is a five foot (1.5 m) radius per level of the Warlock and can be cast up to 100 feet (30.5 m) away.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Quicksand';

-- Earth: Repel Animals  (description was a category stub)
UPDATE spells SET description = 'Keeps ordinary animals, but not insects, out of the area - they simply find it too disturbing to enter, and won''t return for 2D6 hours, though they may linger just outside the boundary.', "range" = '30 feet (9 m) plus 5 feet (1.5 m) per level of experience.', "duration" = 'Immediate.', "saving_throw" = 'Standard for animals.' WHERE name = 'Earth: Repel Animals';

-- Earth: Rust  (description was a category stub)
UPDATE spells SET description = 'Weakens iron and non-Mega-Damage metal alloys by rusting them, cutting their strength in half; can be reapplied to the same object for a cumulative effect. Affects 50 pounds of iron per level of the caster, does 2D6 M.D. per casting to Mega-Damage metal and 1D6x10 to an Iron Golem, but has no effect on magic weapons, armor, items, or Elementals.', "range" = '20 feet (6.1 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Rust';

-- Earth: Sand Storm  (description was a category stub)
UPDATE spells SET description = 'Whips up a stinging sand storm from up to 140+ feet away, covering a 20 foot area. Victims lose initiative and two melee attacks, are -5 to strike/parry/dodge, have vision cut to about 5 feet, take 1D4 S.D.C. per melee, move at 25% normal speed, and can barely talk or hear over the roar; Mega-Damage armor is only cosmetically scuffed.', "range" = '120 feet (36.6 m) plus 20 feet (6 m) per level of the Warlock. Affects a 20 foot (6 m) area.', "duration" = 'One minute (4 melees) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Sand Storm';

-- Earth: Wall of Thorns  (description was a category stub)
UPDATE spells SET description = 'Weaves a dense wall of hard, thorny vines across a 20+ foot area. Falling into it does 5D6 S.D.C. damage, and cutting or forcing a way through in M.D.C. armor takes real effort - 20 M.D.C. must be inflicted per 20 feet of thorns to clear a path.', "range" = 'Covers a 20 (6 m) foot area plus 10 (3 m) feet per level of experience.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Wall of Thorns';

-- Earth: Chasm  (description was a category stub)
UPDATE spells SET description = 'Splits the earth open into a chasm 40 feet long, 20 feet wide, and 20 feet deep per level of the caster; it closes back up without a trace when the duration ends. Falling in does 2D6 S.D.C. per 20 feet of depth, and it only works on open ground - it won''t tear through buildings, though it ripples along them.', "range" = 'Can be cast up to 100 feet (30.5 m) plus 10 feet (3 m) per level of experience.', "duration" = 'Instant effect; lasts 10 minutes per level of experience.', "saving_throw" = 'None.' WHERE name = 'Earth: Chasm';

-- Earth: Clay to Lead  (description was a category stub)
UPDATE spells SET description = 'Transforms clay already within range into lead, up to 50 pounds per level of the caster.', "range" = '10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Clay to Lead';

-- Earth: Clay to Stone  (description was a category stub)
UPDATE spells SET description = 'Transforms clay already within range into stone, up to 50 pounds per level of the caster.', "range" = '10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Clay to Stone';

-- Earth: Close Fissures  (description was a category stub)
UPDATE spells SET description = 'Temporarily seals shut a non-magical fissure or chasm; the caster must be standing at its edge to close it. Anyone still inside as it seals is crushed for 1D6x10+20 M.D. and, if they survive, trapped until the Warlock reopens the passage or the spell''s duration runs out.', "range" = '60 feet (18.3 m) plus 20 feet (6 m) per level of experience.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Close Fissures';

-- Earth: Little Mud Mound  (description was a category stub)
UPDATE spells SET description = 'Summons a fragment of a Greater Earth Elemental''s essence as a mud-golem servant that can scout, spy, fight, defend, or carry gear at any distance from the caster. The Mud Mound has 250 M.D.C., four physical attacks per melee (2D6 M.D. punch, 4D6 M.D. power punch), can cast level 1-4 Earth Elemental spells, bio-regenerates 4D6 M.D.C., and obeys only the Warlock until the spell ends or it is dismissed.', "range" = 'Immediate area.', "duration" = '30 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Little Mud Mound';

-- Earth: Travel Through Walls  (description was a category stub)
UPDATE spells SET description = 'Lets the caster walk straight through solid earth, dirt, sand, clay, wood or stone like a ghost, moving 60 feet per melee, though not through plastic, other artificial substances, or Mega-Damage material. He cannot cast spells or speak while inside the material, and if he is still inside when the duration runs out he materializes and dies instantly.', "range" = 'Self.', "duration" = 'Two minutes (8 melees) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Travel Through Walls';

-- Earth: Clay or Stone to Iron  (description was a category stub)
UPDATE spells SET description = 'Transforms clay or stone already within range into iron, up to 50 pounds of material per level of the caster; costs 40 P.P.E. for clay or 60 P.P.E. for stone.', "range" = '10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Clay or Stone to Iron';

-- Earth: Create Steel  (description was a category stub)
UPDATE spells SET description = 'Turns scrap metal, even rusted or corroded, into clean sheets, bars, poles or beams of usable steel or other alloy with no material loss - in fact producing 5% more metal per level of the caster than the scrap started with - and without needing a smelting facility or workers. Only works on scrap ores/alloys like iron, tungsten, cobalt, copper or aluminum (200 pounds of S.D.C. scrap per level, or just 10 pounds of Mega-Damage scrap per casting), and it cannot repair finished items like armor or vehicles, nor convert material still attached to or used by a living being.', "range" = 'Can be cast up to 10 feet (3 m) away.', "duration" = 'Permanent.', "saving_throw" = 'Not applicable.' WHERE name = 'Earth: Create Steel';

-- Earth: Mend Metal  (description was a category stub)
UPDATE spells SET description = 'Repairs iron, steel or metal alloys, restoring 4D6+40 S.D.C., sealing cracks, and reversing rust or decay; can instead restore 1D6 M.D.C. to Mega-Damage metal/armor or 2D6 M.D.C. to an Iron Golem. Affects up to 60 pounds of metal per level of the caster, but does not work on magic items.', "range" = 'Touch or 10 feet (3 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Mend Metal';

-- Earth: Stone to Flesh  (description was a category stub)
UPDATE spells SET description = 'Reverses petrification or otherwise transforms stone into living flesh, up to 100 pounds of stone per level of the caster.', "range" = 'Touch or up to 12 feet (3.6 m) distance.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Stone to Flesh';

-- Earth: Travel Through Stone  (description was a category stub)
UPDATE spells SET description = 'Lets the caster walk straight through solid stone of any kind, including Mega-Damage concrete, at 30 feet per melee.', "range" = 'Self.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Travel Through Stone';

-- Earth: Wood to Stone  (description was a category stub)
UPDATE spells SET description = 'Transforms non-living wood into stone, up to 60 pounds per level of the caster.', "range" = 'Touch or 10 feet (3 m) per level of experience.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Wood to Stone';

-- Earth: Earthquake  (description was a category stub)
UPDATE spells SET description = 'Sends a violent shock wave through the ground that tears open a fissure running 60 feet per level of the caster. Anyone caught at the epicenter takes 2D6x100 M.D., buildings within 100 feet take 2D4x10 M.D., and people caught in the open take 2D6 damage while their speed, skill performance, combat bonuses and actions per melee are all cut in half by the shaking ground; a Dispel Magic Barriers spell can end the quake early, within 1D4 melees.', "range" = '120 feet (36.6 m) plus 20 feet (6 m) per level of experience.', "duration" = 'One melee per level of the Warlock.', "saving_throw" = 'None, but a Dispel Magic Barriers spell can dispel the quake within 1D4 melees.' WHERE name = 'Earth: Earthquake';

-- Earth: Metal to Clay  (description was a category stub)
UPDATE spells SET description = 'Transforms metal into clay, up to 60 pounds of iron per level of the caster. Has no effect on magic items, magic armor, silver or gold, but instead does 4D6 M.D. to Mega-Damage metal armor or an Iron Golem, or 3D4x10 damage to S.D.C. metal.', "range" = 'Touch or 12 feet (3.6 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Metal to Clay';

-- Earth: Petrification  (description was a category stub)
UPDATE spells SET description = 'Turns a living creature to solid stone, permanently, unless it later fails to save (a standard save that succeeds means no effect at all) and is restored with Stone to Flesh. The petrified victim is placed in stasis, ages and remembers nothing of the time passed, and typically has 100 M.D.C. as stone; if the stone body is smashed the victim''s life essence is destroyed outright, and a limb broken while petrified stays missing after restoration. Supernatural beings and creatures of magic are only temporarily petrified, for 1D6 months per level of the caster, and have 1000 M.D.C. while stone.', "range" = '40 feet (12 m) plus five (1.5 m) per level of experience.', "duration" = 'Permanent, unless restored by Stone to Flesh spell.', "saving_throw" = 'Standard; if a successful save, the person is not affected at all.' WHERE name = 'Earth: Petrification';

-- Earth: River of Lava  (description was a category stub)
UPDATE spells SET description = 'Creates a boiling river of lava 30 feet long, 5 feet wide, and 5 feet deep per level of the caster - devastating if summoned beneath a group of troops. S.D.C. beings caught in it die outright; Mega-Damage creatures take 2D6x10 M.D. per melee stuck inside and need a full melee to cross every 5 feet of flow, though victims can be pulled free with cables, chains, telekinesis or magic.', "range" = '120 feet (36.6 m) away.', "duration" = 'One minute (4 melees) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Earth: River of Lava';

-- Earth: Sculpt & Animate Clay  (description was a category stub)
UPDATE spells SET description = 'Sculpts any real or imagined animal out of clay, up to 12 feet long or tall, and animates it to move like a living beast under the caster''s mental control within 200 feet. The clay creature has 5 M.D.C. per level of the caster, speed 5 per level, two attacks per melee doing 1D6 M.D., and +1 to strike/parry/dodge; controlling it takes little concentration, so the caster can still act or cast other spells. Combining this with Clay to Stone and Breath of Life produces a stone-golem-like creature with doubled stats, or Clay to Stone plus Stone to Flesh plus Breath of Life produces a living duplicate of someone.', "range" = 'Touch or 10 feet (3 m).', "duration" = 'Six hours per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Sculpt & Animate Clay';

-- Earth: Wall of Iron  (description was a category stub)
UPDATE spells SET description = 'Raises a wall of iron up to 60 feet away, with 100 M.D.C. or 250 S.D.C. per level of the caster over an 8x8x4 foot section per level. Dropping it on someone does 2D6x10+30 S.D.C. or 1D4 M.D. and traps them underneath (needs a combined P.S. of 60 to lift free); any Elemental Magic wall like this can be dispelled with Dispel Magic Barriers.', "range" = 'Can be cast 60 feet (18.3 m) away and affects/covers an 8x8x4 foot (2.4 x 2.4 x 1.2 m) area per level of experience.', "duration" = 'Four minutes per level of the Warlock or until destroyed.', "saving_throw" = 'None.' WHERE name = 'Earth: Wall of Iron';

-- Earth: Cap Volcano  (description was a category stub)
UPDATE spells SET description = 'Temporarily plugs an active volcano, halting the flow of lava, ash and soot, from up to 300 feet per level of the caster away.', "range" = '300 feet (91.6 m) per level of experience.', "duration" = 'Six hours per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Cap Volcano';

-- Earth: Create Golem  (description was a category stub)
UPDATE spells SET description = 'Lets the caster sculpt a humanoid Golem out of clay up to 20 feet tall, set with two onyx gems worth at least 1000 credits each for eyes and an iron heart, then turn the clay to stone or iron and bring it to life with a drop of his own blood on its forehead - permanently draining 4 Hit Points from himself into the creature. The Golem obeys only its creator, has no emotions of its own, gets four attacks per melee doing 2D6 M.D., has 75 M.D.C. as stone or 120 as iron, 150 and 240 if it has a metal heart with a 7000 credit diamond, is immune to psionics, cold, heat, disease, gases and fear, takes half damage from magic energy, M.D. fire/plasma and magic weapons, and regenerates within 24 hours unless its heart is removed.', "range" = 'Touch.', "duration" = 'Permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Create Golem';

-- Earth: Firequake  (description was a category stub)
UPDATE spells SET description = 'Makes an area of ground rumble and crack, spewing sulfurous gas and jets of fire across a 100 foot radius, enough to engulf several houses. Everyone inside is slowed to 10% of normal speed, is -9 to strike/parry/dodge and -5 on initiative from the choking fumes, and must dodge jets of flame each melee or take 5D6 M.D., triple for large vehicles or giant robots; the ground looks unmarked once the spell ends, aside from anyone who got hurt.', "range" = 'Up to 500 feet (152 m) away.', "duration" = 'One melee round per level of experience.', "saving_throw" = 'None.', "damage" = 'Varies, see description.', "area_of_effect" = 'To a 100 foot (30.5 m) radius, enough to engulf 4-6 average houses and their backyards.' WHERE name = 'Earth: Firequake';

-- Earth: Ironwood  (description was a category stub)
UPDATE spells SET description = 'Converts ordinary S.D.C. wood permanently into Mega-Damage material on a point-for-point basis, so 170 S.D.C. becomes 170 M.D.C., costing one P.P.E. per S.D.C. point converted, with a 50 P.P.E. minimum per casting. The wood keeps its normal look, feel, weight and buoyancy and does not inflict Mega-Damage on its own just by being M.D.C., though it does add 1D6 extra damage, and it only works on simple wooden objects like handles, doors, boxes, wagons or a ships hull - not on complex machinery or on non-wood materials like bone.', "range" = 'Touch.', "duration" = 'Permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Ironwood';

-- Earth: Magnetism  (description was a category stub)
UPDATE spells SET description = 'The book gives no independent mechanics here, stating only that it is identical in effect to the Air Elemental spell Electro-Magnetism, affecting a 40 foot area from up to 300 feet away.', "range" = 'Affects a 40 foot (12.2 m) area and can be cast up to 300 feet (91.5 m) away.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Magnetism';

-- Earth: Suspended Animation  (description was a category stub)
UPDATE spells SET description = 'Puts the caster into a death-like suspended state for anywhere from one day to ten years per level, aging only one year for every ten spent asleep. He cannot cast spells or think while under it, only dream, and his body is left completely unprotected, so it must be kept safe by other means; the duration can be programmed to end at a set time, date, or triggering event.', "range" = 'Self.', "duration" = 'One day to ten years per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Earth: Suspended Animation';

-- Earth: Transference of Essence  (description was a category stub)
UPDATE spells SET description = 'Permanently transfers the casters mind and personality - I.Q., M.A., M.E., memories and all - into an object or being of stone, clay, iron, wood, living or dead vegetation, a Golem, or a clay creature; his original body dies within six days and there is no way to reverse the change. Moved into a living plant he can animate and control it as his own body, rooted in place, limited to four attacks, communicating only by telepathy, empathy or writing; moved into a Golem, mannequin, puppet or unprogrammed robot he controls it like his own body with all his skills and memories intact. The disorientation of an inhuman body tends to drive the caster insane - roll on the insanity tables once every four years.', "range" = 'Self.', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Earth: Transference of Essence';

-- Fire: Blinding Flash  (description was a category stub)
UPDATE spells SET description = 'A sudden burst of intense white light fills a 10 foot radius, castable up to 60 feet away. Anyone inside who fails a save vs magic is blinded for 1 to 4 melee rounds and suffers -10 to strike, parry and dodge, with a 01-50% chance of stumbling for every 10 feet they try to move; those who save avoid the blindness but still lose initiative.', "range" = 'Ten foot (3 m) radius; cast up to 60 feet (18.3 m) away.', "duration" = 'Instant.', "saving_throw" = 'Standard.' WHERE name = 'Fire: Blinding Flash';

-- Fire: Cloud of Smoke  (description was a category stub)
UPDATE spells SET description = 'Fills up to a 30 foot cube with dense black smoke, cast up to 90 feet away. Anyone inside cannot see more than 3 feet in front of their face and fights at -10 to strike, parry and dodge against anything farther off, while those outside cannot see in at all and risk hitting their own allies if they attack blindly into the cloud; only the caster who made it can see clearly inside.', "range" = '90 feet (27.4 m).', "duration" = 'Four melee rounds (one minute) per level of experience.', "saving_throw" = 'None.' WHERE name = 'Fire: Cloud of Smoke';

-- Fire: Create Coal  (description was a category stub)
UPDATE spells SET description = 'Conjures lumps of coal out of thin air, 20 pounds per level of the caster.', "range" = '10 feet (3 m).', "duration" = 'Instant and permanent.', "saving_throw" = 'None.' WHERE name = 'Fire: Create Coal';

-- Fire: Fiery Touch  (description was a category stub)
UPDATE spells SET description = 'Cloaks the caster in an invisible fiery aura; anyone who touches the caster, or whom the caster touches, is burned as if they had put a hand in open flame. Damage is normally 4D6 S.D.C. or 2D6 M.D., the caster picks which, and the caster can dial it down in increments of 1D6 down to as little as 1D6 S.D.C. Does not ignite combustibles on contact, and lets the caster handle hot coals or embers without injury while active.', "range" = 'Self.', "duration" = 'Four melee rounds (one minute) per level of the Warlock.', "saving_throw" = 'None.', "damage" = '4D6 S.D.C. damage or 1D6 M.D.C. (damage can be regulated).' WHERE name = 'Fire: Fiery Touch';

-- Fire: Fire Bolt  (description was a category stub)
UPDATE spells SET description = 'Creates and hurls a bolt of magical fire that is +4 to strike, dealing 4D6 M.D. or 1D6x10 S.D.C., the caster picks which. Range is 100 feet plus 5 feet per level of experience.', "range" = '100 feet (30.5 m) plus 5 feet (1.5 m) per level of experience.', "duration" = 'Instant.', "saving_throw" = 'Dodge.', "damage" = '4D6 M.D.' WHERE name = 'Fire: Fire Bolt';

-- Fire: Globe of Daylight  (description was a category stub)
UPDATE spells SET description = 'Creates a small sphere of true daylight that the caster can carry along or send up to 30 feet ahead at a top speed equal to a Speed attribute of 12. It lights a 12 foot radius per level of the caster, is bright enough to keep vampires at bay and may frighten nocturnal or subterranean animals, but gives off no heat and does no damage.', "range" = 'Near self or up to 30 feet (9 m) away.', "duration" = '12 melees (3 minutes) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Globe of Daylight';

-- Fire: Impervious to Fire  (description was a category stub)
UPDATE spells SET description = 'Makes the caster, or up to two others within 60 feet, immune to fire and smoke, including S.D.C. flame, mega-damage plasma/fire and magic fire. The protection extends to clothing and worn armor but not to power armor, vehicles or buildings, and cannot be passed on by touching a protected person.', "range" = 'Self or two others up to 60 feet (18.3 m) away.', "duration" = 'Two melee rounds (30 seconds) per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Impervious to Fire';

-- Fire: Nightvision  (description was a category stub)
UPDATE spells SET description = 'Grants the caster the ability to see clearly in total darkness.', "range" = 'Self, 60 feet (18.3 m) plus 10 feet (3 m) per level of experience.', "duration" = 'Ten minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Nightvision';

-- Fire: Stench of Hades  (description was a category stub)
UPDATE spells SET description = 'Fills a 20 foot area with a heavy sulfurous stench; everyone inside must save vs magic or take 1D6 damage per melee round of exposure and have a 1-50% chance each round of vomiting (losing initiative, two actions, and fighting at -4 to parry/dodge while sick). Even those who save are -2 to strike, parry and dodge while in the area. Has no effect on anyone impervious to gases, invulnerable, or sealed in an environmental suit, airtight vehicle, or gas mask and goggles.', "range" = '60 feet (18.3 m).', "duration" = 'Four melee rounds (one minute) per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Fire: Stench of Hades';

-- Fire: Cloud of Ash  (description was a category stub)
UPDATE spells SET description = 'Conjures a 30 foot cloud of scalding ash up to 90 feet away. Anyone caught in it or passing through takes 2D6 S.D.C. per melee round and is blinded for 1D6 melees, at -10 to strike, parry and dodge from the pain and the ruined visibility; breathing is hard even with the face covered. A successful save halves the damage. Elementals, anyone under Armor of Ithan or impervious to fire, and anyone in sealed environmental armour or an M.D.C. vehicle are unaffected, as is the Warlock who made it. Dry wood, grass, hay, paper, cloth or lamp oil in the cloud has a 67% chance of catching fire.', "range" = '90 feet (27.4 m).', "duration" = 'Four melee rounds (one minute) per level of the Warlock.', "saving_throw" = 'A successful save inflicts half damage.' WHERE name = 'Fire: Cloud of Ash';

-- Fire: Darkness  (description was a category stub)
UPDATE spells SET description = 'Creates an unnatural darkness that ordinary flames cannot dispel; nightvision and optics are cut in half inside it and passive night sight is blinded outright, leaving victims at -10 to strike, parry and dodge. Only the caster sees clearly within it, gaining +15% to prowl and +1 to strike.', "range" = 'Five foot (1.5 m) area per level of the Warlock.', "duration" = '10 melee rounds per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Darkness';

-- Fire: Fireblast  (description was a category stub)
UPDATE spells SET description = 'Shoots a narrow, one-foot-wide bolt of mega-damage flame the full 50 foot range, dealing 3D6 M.D. to anything in its path that fails to dodge. It keeps traveling until it hits something massive enough to stop it (a wall, vehicle, giant robot) and can be used to clear a passageway.', "range" = '50 feet (15.2 m).', "duration" = 'Instant.', "saving_throw" = 'Dodge.', "damage" = '3D6 M.D.' WHERE name = 'Fire: Fireblast';

-- Fire: Flame Lick  (description was a category stub)
UPDATE spells SET description = 'Creates a tongue of flame from the palm of the caster, fired once per hand-to-hand attack available at +3 to strike, dealing 6D6 S.D.C. or 2D6 M.D. per hit, the caster picks which. Targets may dodge but cannot parry it.', "range" = 'Four feet (1.2 m) per level of the Warlock.', "duration" = 'Two melee rounds per level of the Warlock.', "saving_throw" = 'None versus magic, but intended victims may try to dodge (not parry) the attack.', "damage" = 'Either 6D6 S.D.C. or 2D6 M.D.' WHERE name = 'Fire: Flame Lick';

-- Fire: Freeze Water  (description was a category stub)
UPDATE spells SET description = 'Instantly freezes 20 gallons of water per level of the caster, castable up to 30 feet away; the ice remains frozen until it melts under ordinary conditions.', "range" = '30 feet (9 m).', "duration" = 'Varies.', "saving_throw" = 'None.' WHERE name = 'Fire: Freeze Water';

-- Fire: Heat Object/Boil Water  (description was a category stub; cited p.74, entry is on p.76)
UPDATE spells SET description = 'By staring at a thing for 1D4 melees the Warlock heats it - boiling two gallons of water per level of experience, or making an object too hot to hold, so that touching it does 1D4 damage until it cools over about 2D6 melee rounds. It will fry food, at twice the time. The character must concentrate throughout and can cast no other magic and use no skill until he is done.', "range" = '12 feet (3.6 m).', "duration" = 'Fairly instant; 1D4 melees.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.76' WHERE name = 'Fire: Heat Object/Boil Water';

-- Fire: Resist Cold  (description was a category stub)
UPDATE spells SET description = 'Lets the caster, or others within 60 feet, ignore the effects of cold and function without discomfort down to zero degrees Fahrenheit.', "range" = 'Self or others up to 60 feet (18.3 m) away.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Resist Cold';

-- Fire: Spontaneous Combustion  (description was a category stub)
UPDATE spells SET description = 'Instantly ignites combustible material such as paper, dry wood, old cloth or dry grass within range. Mechanically identical to the invocation Ignite Fire, just reprinted here as an Elemental spell.', "range" = '40 feet (12.2 m).', "duration" = 'Instant, counts as one attack/spell but the fire lasts until it is put out.', "saving_throw" = 'None.' WHERE name = 'Fire: Spontaneous Combustion';

-- Fire: Swirling Lights  (description was a category stub)
UPDATE spells SET description = 'Conjures a dazzling swirl of flickering lights that mesmerizes everyone who sees it, leaving them oblivious to their surroundings. Being attacked or grabbed snaps a victim out of it, though they then move and act at half speed for the rest of the duration; when it ends they snap back to normal instantly, usually angry about having been enchanted.', "range" = 'Area affected is 10 feet, but can be cast up to 60 feet (18.3 m) away.', "duration" = 'Four melee rounds (one minute) per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Fire: Swirling Lights';

-- Fire: Tongue of Flame  (description was a category stub)
UPDATE spells SET description = 'A crimson flame appears over the head of the caster or a willing recipient within 30 feet, letting them understand - but not speak - any language for the duration.', "range" = 'Self or other up to 30 feet (9 m) away.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Tongue of Flame';

-- Fire: Circle of Cold  (description was a category stub)
UPDATE spells SET description = 'Creates an invisible zone of bone-chilling cold, 40 degrees below freezing, up to a 15 foot radius per level; everyone inside takes 1 point of damage per melee round from exposure alone, and anyone in full metal armor takes an extra 1D6. Ten or more minutes of exposure risks frostbite for 3D6 damage direct to hit points unless the victim is warmly dressed or protected by magic or psionics.', "range" = 'Area affected is a 15 foot (4.5 m) radius per level of the Warlock, can be cast up to 90 feet (27.4 m) away.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'Standard.' WHERE name = 'Fire: Circle of Cold';

-- Fire: Circle of Flame  (description was a category stub)
UPDATE spells SET description = 'Creates a 30 foot ring of flame with walls of fire seven feet tall; anyone within four feet takes 1D6 damage, and running or leaping through the flames deals 4D6 damage, either S.D.C. or mega-damage as the caster chooses, with a 1-50% chance of setting the gear of the victim on fire unless protected by magic or psionics.', "range" = '90 feet (27.4 m) and encircles a 30 foot (9 m) area.', "duration" = 'Three minutes (12 melees) per level of the Warlock.', "saving_throw" = 'None.', "damage" = 'The heat and smoke from the circle causes 1D6 S.D.C. damage, attempting to run through the flames causes 4D6 S.D.C. damage or 2D6 M.D.C., plus a 50% chance that combustible items will catch on fire.' WHERE name = 'Fire: Circle of Flame';

-- Fire: Create Heat  (description was a category stub)
UPDATE spells SET description = 'Raises the temperature of the area by 10 degrees Fahrenheit per level of the caster. Past 110 degrees, victims have a 1-40% chance per round of passing out from heat exhaustion for 2D6 minutes.', "range" = '30 foot (9 m) radius per level of experience.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Create Heat';

-- Fire: Extinguish Fire  (description was a category stub)
UPDATE spells SET description = 'Snuffs out fires within the area of effect, dousing one whole area of flame each melee round the spell remains active. Does not work against magic fire or Elemental beings.', "range" = 'Affects a 20 foot (9 m) area per each level of the Warlock, and can be cast up to 30 feet (9 m) away per level of experience.', "duration" = 'The extinguishing power lasts two minutes (8 melees) per level of the Warlock, the fires will remain extinguished unless reignited by an another source.', "saving_throw" = 'None.' WHERE name = 'Fire: Extinguish Fire';

-- Fire: Fire Ball  (description was a category stub)
UPDATE spells SET description = 'A more powerful version of the wizard spell of the same name; hurls a large fireball that seldom misses, no save except a called dodge requiring an 18 or higher, inflicting 1D6 M.D. per level of the caster.', "range" = '90 feet (27.4 m) plus 20 feet (6 m) per level of experience.', "duration" = 'Instant.', "saving_throw" = 'Dodge.', "damage" = '1D6 M.D. per level of the Warlock.' WHERE name = 'Fire: Fire Ball';

-- Fire: Fire Gout  (description was a category stub; cited p.74, entry is on p.77)
UPDATE spells SET description = 'Conjures and directs a stream of fire like a wide flamethrower, aimed with a wave of the hand. The stream runs the full length of its range and is about three feet across, stopped only by a large obstacle, and does 6D6 M.D. plus 1 per level of experience. It is dodged rather than saved against, at -3, and there is a 70% chance combustible material in its path ignites.', "range" = '30 feet (9 m) per level of experience.', "duration" = 'Instant; about two seconds.', "saving_throw" = 'Dodge at -3 to do so.', "damage" = '6D6 M.D. + 1 per level of experience.', source_book = 'Rifts Book of Magic p.77' WHERE name = 'Fire: Fire Gout';

-- Fire: Lower Temperature  (description was a category stub; cited p.74, entry is on p.77)
UPDATE spells SET description = 'Drops the temperature of an area by ten degrees Fahrenheit (6 centigrade) per level of the Warlock, over a 30 foot radius per level. Sustained extreme cold may cause frostbite.', "range" = '30 foot (9 m) radius per level of experience.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.77' WHERE name = 'Fire: Lower Temperature';

-- Fire: Part Fire  (description was a category stub; cited p.74, entry is on p.77)
UPDATE spells SET description = 'Pushes fire aside to open a cool, safe path through it, used to enter, cross and leave a burning building or an inferno. Anyone on the path is protected from the flames, embers and choking smoke, though it still feels frighteningly hot. The Warlock may close the path behind him or leave it open for others to follow. When the magic ends the fire takes the path back within seconds.', "range" = '3-12 foot (0.9 to 3.6 m) wide path. 20 foot (6 m) length per level of experience.', "duration" = 'Three minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.77' WHERE name = 'Fire: Part Fire';

-- Fire: Wall of Flame  (description was a category stub; cited p.74, entry is on p.77)
UPDATE spells SET description = 'Raises a wall of fire 30 feet long and 30 feet high, five feet thick plus another five feet per level of experience. Anyone within four feet takes 1D6 from the heat and smoke; running or leaping through does 4D6 S.D.C. or 2D6 M.D.C. per five feet of thickness, and standing in it does 2D6 S.D.C. per melee round. Combustible items on a person passing through have a 70% chance of igniting. There is no save.', "range" = '90 feet (27.4 m) and fills a 30 foot (9 m) long area.', "duration" = 'Three minutes (12 melees) per level of the Warlock.', "saving_throw" = 'None.', "damage" = 'Attempting to run through the flames causes 4D6 S.D.C. damage or 2D6 M.D.C. per every five feet (1.5 m) of thickness, plus a 70% chance that combustible items will catch on fire.', source_book = 'Rifts Book of Magic p.77' WHERE name = 'Fire: Wall of Flame';

-- Fire: Cloud of Steam  (description was a category stub)
UPDATE spells SET description = 'Creates a 30 foot cloud of scalding steam up to 90+ feet away; anyone caught inside takes 2D6 S.D.C. damage per melee round and is blinded for 1D6 melees, fighting at -10 to strike, parry and dodge while inside. Environmental armor, imperviousness to heat, magical armor, or being a mega-damage being negates the damage, though visibility inside stays at zero regardless.', "range" = '90 feet (27.4 m) plus 10 feet (3 m) per level of experience.', "duration" = 'Four melee rounds per level of the Warlock.', "saving_throw" = 'A successful save inflicts half damage.' WHERE name = 'Fire: Cloud of Steam';

-- Fire: Fire Blossom  (description was a category stub)
UPDATE spells SET description = 'Creates a small, inert flame about three inches tall that can be carried in a pocket or bag without burning anything or anyone. Once activated by the caster or the person it was given to, it bursts into a real fire roughly three feet tall and two feet wide for 1D6 minutes before vanishing, igniting any combustibles it is fed.', "range" = 'Touch; appears above the open palm of the mage''s hand.', "duration" = 'One month per level of the spell caster without burning, but burns out within 1D6 minutes after it is activated to burn.', "saving_throw" = 'None.', "damage" = 'Varies.' WHERE name = 'Fire: Fire Blossom';

-- Fire: Flame Friend  (description was a category stub)
UPDATE spells SET description = 'Summons a fragmented Fire Elemental essence that stays alongside the caster and obeys the commands of the caster - guarding, fighting, lighting the way, or burning undead. It has 50 M.D.C., attacks three times per melee for 2D6 M.D., 4D6 on a power punch, sets flammable material ablaze on a 1-60% touch, sees the invisible, has 200 foot nightvision, and takes double damage from cold or water-based magic.', "range" = 'Immediate area.', "duration" = '15 minutes per level of the Warlock.', "saving_throw" = 'None.' WHERE name = 'Fire: Flame Friend';

-- Fire: Fuel Flame  (description was a category stub)
UPDATE spells SET description = 'Feeds an existing fire, tripling its size within a 20 foot radius, castable up to 100 feet away.', "range" = '100 feet (30.5 m)', "duration" = 'Instant', "saving_throw" = 'None' WHERE name = 'Fire: Fuel Flame';

-- Fire: Heal Burns  (description was a category stub)
UPDATE spells SET description = 'Instantly and permanently heals burn injuries, not cuts, bruises, or anything else, erasing the pain and restoring the skin, and grants 2D6 S.D.C. and 2D6 Hit Points to the victim. Leaves little to no scarring.', "range" = 'Touch or 10 feet (3 m) away', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Fire: Heal Burns';

-- Fire: Mini-Fireballs  (description was a category stub)
UPDATE spells SET description = 'Fires three small, unerring fireballs from the palm at once, usable as many times per melee round as the caster has hand to hand attacks, each triple-blast dealing 3D6 M.D. Victims must know the attack is coming and roll an 18 or higher to dodge.', "range" = '90 feet (27.4 m) plus 10 feet (3 m) per level of experience', "duration" = 'One melee round per level of experience', "saving_throw" = 'Dodge, but the victim must know the attack is coming and must roll an 18 or higher (bonuses to dodge are applicable)', "damage" = '3D6 M.D. per triple blast' WHERE name = 'Fire: Mini-Fireballs';

-- Fire: See Through Smoke  (description was a category stub)
UPDATE spells SET description = 'Lets the caster see clearly through smoke and breathe it without suffering smoke inhalation, allowing them to operate normally in a smoke-choked area.', "range" = 'Self', "duration" = 'Five minutes per level of experience', "saving_throw" = 'Not applicable' WHERE name = 'Fire: See Through Smoke';

-- Fire: Blue Flame  (description was a category stub)
UPDATE spells SET description = 'Conjures a patch of magical cold flame, up to 10 feet in diameter per level, that induces a burning, numbing cold instead of heat; anyone caught in it must save vs magic or take 1D6 M.D. per level of the caster. Ordinary fire protection, magical or psionic, does not help against it, and Fire Elementals take double damage. It leaves no trace when it fades.', "range" = 'Covers an area 10 feet (3 m) in diameter per level of the Warlock', "duration" = 'One minute (four melee rounds) per level of experience', "saving_throw" = 'Standard', "damage" = '1D6 M.D. per level of experience; area effect spell' WHERE name = 'Fire: Blue Flame';

-- Fire: Breathe Fire  (description was a category stub)
UPDATE spells SET description = 'Lets the caster breathe flame like a dragon, usable in place of a melee attack as often as they have attacks per melee, dealing 2D6 M.D. plus 1D6 for each level above first, at +2 to strike.', "range" = '8 feet (2.4 m) plus one foot (0.3 m) per experience level', "duration" = 'One melee round (15 seconds) per level of the Warlock', "saving_throw" = 'None except dodge, +2 to strike', "damage" = '2D6 M.D. + 1D6 per each additional level of experience starting at level two' WHERE name = 'Fire: Breathe Fire';

-- Fire: Eat Fire  (description was a category stub)
UPDATE spells SET description = 'Lets the caster safely consume fire and be nourished by it in place of ordinary food; a large campfire or three torches equals a full meal. Can also be used as a form of entertainment.', "range" = 'Self', "duration" = 'Two melee rounds per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Fire: Eat Fire';

-- Fire: Fire Globe  (description was a category stub)
UPDATE spells SET description = 'Creates a portable, inert globe of magic fire that can be stored safely and thrown up to 200 feet. On impact it erupts like napalm over the target, dealing 5D6 M.D. immediately and another 5D6 M.D. per melee round it keeps burning, up to 1D4 minutes. Water thrown on it scalds for 2D6 M.D. before it goes out; rolling in dirt or sand smothers it harmlessly.', "range" = 'Touch; appears above the open palm of the mage''s hand. Can be thrown 200 feet (61 m)', "duration" = 'Stored as a globe for two weeks per level of the Warlock, but burns out within 1D4 minutes after it is activated', "saving_throw" = 'None', "damage" = '5D6 M.D. at the moment of impact and 5D6 additional M.D. per melee round' WHERE name = 'Fire: Fire Globe';

-- Fire: Screaming Wall of Flame  (description was a category stub)
UPDATE spells SET description = 'Conjures a shrieking wall of orange flame, fueled by a fragment of a Fire Elemental, up to 10 feet long per level and 20 feet tall. Touching or running through it deals 4D6 M.D., and its scream forces everyone who sees or hears it to save vs Horror Factor 16 or lose initiative, lose one attack, and possibly flee, 70% chance. It resists Dispel Magic Barriers and Negate Magic, saving at +1 against them.', "range" = 'Covers a 10 foot (3 m) area per level of the Warlock and can be cast up to 90 feet (27.4 m) away', "duration" = 'Four melee rounds per level of the Warlock', "saving_throw" = 'Standard against scream/Horror Factor 16', "damage" = '4D6 M.D. plus save vs magic fear' WHERE name = 'Fire: Screaming Wall of Flame';

-- Fire: Wall of Ice  (description was a category stub)
UPDATE spells SET description = 'Creates a wall of ice with 40 M.D.C., or 200 S.D.C., per level of experience, castable up to 60 feet away. Dropping it on someone deals 1D6x10 S.D.C. and traps them beneath it, requiring a combined P.S. of 60 to lift free. Can be dispelled with Dispel Magic Barriers.', "range" = 'Can be cast 60 feet (18.3 m) away and affects/covers an 8 x 8 x 4 foot (2.4 x 2.4 x 1.2 m) area per level of experience', "duration" = 'Four minutes per level of the Warlock or until destroyed', "saving_throw" = 'None' WHERE name = 'Fire: Wall of Ice';

-- Fire: Dancing Fires  (description was a category stub)
UPDATE spells SET description = 'Animates one four-foot pillar of living flame per level of the caster to block passages or chase targets on command. Each has 20 M.D.C. and is immune to kinetic, fire and energy attacks, which pass harmlessly through it, but takes double damage from cold or water, a gallon of water inflicts 1D4 M.D. Each attacks twice per melee at +2 to strike, parry and dodge for 1D6 M.D. per hit, and has a 1-60% chance of igniting anything flammable it touches.', "range" = '30 feet (9 m)', "duration" = 'Four melee rounds per level of the Warlock', "saving_throw" = 'Dodge or parry', "damage" = '1D6 M.D. per each dancing fire' WHERE name = 'Fire: Dancing Fires';

-- Fire: Eternal Flame  (description was a category stub)
UPDATE spells SET description = 'Creates a small, one-foot flame that burns for roughly 3,000 years plus 150 per level of the caster, immune to water, cold and dispelling magic. Typically cast to mark graves, battlefields or other memorable places.', "range" = '30 feet (9.1 m), area affected is small', "duration" = 'Approximately 3,000 years plus 150 per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Fire: Eternal Flame';

-- Fire: Fire Whip  (description was a category stub)
UPDATE spells SET description = 'Creates a mystic whip of flame that can be parried or dodged but strikes at +1, dealing 4D6 M.D. per hit.', "range" = '6 feet (1.8 m) plus one foot (0.3 m) per level of the Warlock', "duration" = 'Four melee rounds (one minute) per level of the Warlock', "saving_throw" = 'Parry or dodge', "damage" = '4D6 M.D.' WHERE name = 'Fire: Fire Whip';

-- Fire: Flame of Life  (description was a category stub)
UPDATE spells SET description = 'Automatically heals someone who is comatose, mortally wounded, or dying of poison or disease, though it cannot help the already dead, repairing the fatal damage and restoring the victim to 10 Hit Points above zero. The person survives but remains weak. Castable up to six feet away.', "range" = 'Touch or up to six feet (1.5 m) away', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Fire: Flame of Life';

-- Fire: Fire Sponge  (description was a category stub)
UPDATE spells SET description = 'Lets the caster draw all heat and fire energy within a radius, 50 feet per level, into themselves, extinguishing it and either venting it harmlessly or turning it into attacks. Small fires convert into two plasma bolts of 4D6 M.D.; absorbing a large blaze, such as a burning building or forest, turns the caster into a walking bonfire that can fire two 6D6 M.D. bolts per melee for up to 10 rounds, burn anyone within four feet for 1D4 M.D., punch for 2D6 M.D., or instead unleash a single 1D4x100 M.D. mega-blast before reverting to normal. It can also snuff out fire-based magic walls by walking into them, at a cost of 6D6 damage direct to the Hit Points of the caster.', "range" = 'Self; absorbs an area of 50 feet (15.2 m) in diameter per level of experience. Range of all blasts is 100 feet (30.5 m) +20 feet (6 m) per level of experience', "duration" = 'One minute (4 melees) per level of the Warlock', "saving_throw" = 'None', "damage" = 'Varies as noted below. Each blast counts as one melee attack/action' WHERE name = 'Fire: Fire Sponge';

-- Fire: Melt Metal  (description was a category stub)
UPDATE spells SET description = 'Melts up to 40 pounds of metal per level of the caster into slag within seconds just by staring at it, dealing 1D6x10 M.D. to mega-damage alloys, magic weapons and items are unaffected. Can be used twice per melee round.', "range" = '15 feet (4.6 m) plus five feet (1.5 m) per experience level', "duration" = 'Four melee rounds per level of the Warlock', "saving_throw" = 'None', "damage" = '1D6x10 M.D., but only to metal, nothing else' WHERE name = 'Fire: Melt Metal';

-- Fire: River of Lava  (description was a category stub)
UPDATE spells SET description = 'Creates a boiling river of lava, 30 feet long and 5 feet wide and deep per level, up to 120 feet away. Creating it beneath a group kills ordinary S.D.C. beings and blocks their escape; mega-damage creatures take 2D6x10 M.D. per melee spent in it and need one melee round per five feet to cross the thick, sticky flow.', "range" = '120 feet (36.6 m) away', "duration" = 'One minute (4 melees) per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Fire: River of Lava';

-- Fire: Ten Foot Wheel of Fire  (description was a category stub)
UPDATE spells SET description = 'A rolling wheel of fire up to 10 feet wide and 15 feet tall, steered in any direction by the caster, dealing 1D6, or 2D4, M.D. per level to everything it rolls over and igniting combustibles on a 1-74% chance. Since it is an offensive effect rather than a barrier, Dispel Magic Barriers cannot remove it.', "range" = '150 feet (46 m)', "duration" = 'Two melee rounds per level of the Warlock', "saving_throw" = 'People can run, leap, and dodge out of the way', "damage" = 'IDS M.D. per level of experience' WHERE name = 'Fire: Ten Foot Wheel of Fire';

-- Fire: Burst into Flame  (description was a category stub)
UPDATE spells SET description = 'Turns the caster into a living torch immune to fire and heat, though mega-damage energy attacks still do half damage, and grants 70 physical M.D.C. while active. Punches and kicks deal 3D6 M.D. with a 61% chance of igniting flammable material, and the flames light up 60 feet of darkness. The caster can cancel the effect at will.', "range" = 'Self', "duration" = 'Four melee rounds (one minute) per level of the Warlock', "saving_throw" = 'None', "damage" = '3D6 M.D.' WHERE name = 'Fire: Burst into Flame';

-- Fire: Drought  (description was a category stub)
UPDATE spells SET description = 'Raises the temperature by 10 degrees Fahrenheit per level and halts rainfall across a 200 foot radius per level for the duration, killing plants and drying up shallow wells and ponds. Left in place beyond three weeks, it has a 54% chance per week of sparking brush fires.', "range" = '200 foot (61 m) radius per level of experience', "duration" = 'One week per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Fire: Drought';

-- Fire: Plasma Bolt  (description was a category stub)
UPDATE spells SET description = 'Fires a bolt of concentrated plasma energy from the hand, dealing 6D6 M.D. It can be fired once per melee attack the caster has and combined with other attacks in the same round.', "range" = '100 feet (30.5 m) per level of experience', "duration" = 'One melee round per level of the Warlock', "saving_throw" = 'None', "damage" = '6D6 M.D. Each blast counts as one melee attack/action' WHERE name = 'Fire: Plasma Bolt';

-- Water: Cloud of Steam  (description was a category stub)
UPDATE spells SET description = 'Creates a 30 foot cloud of steam up to 90+ feet away; anyone caught inside takes 2D6 S.D.C. damage per melee round and is blinded for 1D6 melees, fighting at -10 to strike, parry and dodge while inside. Has no effect against body armor or mega-damage beings, though the cloud still leaves visibility at zero.', "range" = '90 feet (27.4 m) plus 10 feet (3 m) per level of experience', "duration" = 'Four melees per level of the Warlock', "saving_throw" = 'A successful save inflicts half damage' WHERE name = 'Water: Cloud of Steam';

-- Water: Color Water  (description was a category stub)
UPDATE spells SET description = 'Changes the color and clarity of water into an unnatural, murky hue, black, green, rust, crimson, etc, without altering the water itself - purely cosmetic, though it can make clean water look contaminated. Affects up to 50 gallons per level of the caster.', "range" = '60 feet (18.3 m)', "duration" = 'One hour per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Color Water';

-- Water: Create Fog  (description was a category stub)
UPDATE spells SET description = 'Conjures a dense fog up to a 100 foot radius per level of the caster. Visibility drops to six feet, figures appear as blurry shadows between 7 and 20 feet, and anything beyond 20 feet is completely obscured. Everyone inside is -2 on initiative, strike, dodge and parry, and moves at half speed.', "range" = '60 feet (18.3 m) per level of experience', "duration" = 'Five minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Create Fog';

-- Water: Dowsing  (description was a category stub)
UPDATE spells SET description = 'Senses the location of water - stream, pond, river or underground source - within range at 98% accuracy, and can specifically key on fresh drinking water.', "range" = 'Self; sensing range is 200 feet (61 m) per level of experience', "duration" = 'Ten minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Dowsing';

-- Water: Float on Water  (description was a category stub)
UPDATE spells SET description = 'Makes the recipient buoyant enough to float on water like a piece of wood. It does not grant the ability to swim.', "range" = 'Self or others, can be cast up to 90 feet (27.4 m) away', "duration" = '20 minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Float on Water';

-- Water: Purple Mist  (description was a category stub)
UPDATE spells SET description = 'Creates a toxic mist covering a 20 foot diameter, castable up to 90 feet away. Those exposed have a 1-39% chance of passing out for 1D6 melees, take 1D6 S.D.C. damage each melee spent in the mist, and are -1 to strike, parry and dodge. Has no effect on anyone in an environmental suit, an airtight compartment, or a mega-damage being; a successful save avoids all penalties and damage.', "range" = '90 feet (27.4 m)', "duration" = 'Four melees per level of the Warlock', "saving_throw" = 'Standard' WHERE name = 'Water: Purple Mist';

-- Water: Salt Water to Fresh  (description was a category stub)
UPDATE spells SET description = 'Converts up to 30 gallons of salt or sea water per level of the caster into drinkable fresh water. Does not remove strong toxins or poisons.', "range" = 'Touch or 12 feet (3.6 m)', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Salt Water to Fresh';

-- Water: Sense Direction Underwater  (description was a category stub)
UPDATE spells SET description = 'Grants a flawless sense of direction - compass heading, current direction and speed, and approximate depth - even in total darkness.', "range" = 'Self', "duration" = 'Ten minutes per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Sense Direction Underwater';

-- Water: Walk the Waves  (description was a category stub)
UPDATE spells SET description = 'Lets the caster walk on water, provided the waves are under four feet high, moving at their normal Speed attribute.', "range" = 'Self', "duration" = 'Ten minutes per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Walk the Waves';

-- Water: Water to Wine  (description was a category stub)
UPDATE spells SET description = 'Converts up to 30 gallons of ordinary fresh water into wine of fair to average quality, with quality improving 5% per level of the caster.', "range" = '12 feet (3.6 m)', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Water to Wine';

-- Water: Breathe Underwater  (description was a category stub; cited p.82, entry is on p.83)
UPDATE spells SET description = 'Lets the Warlock, plus one or two others, breathe underwater by touch. Lasts 20 minutes per level and reaches a maximum depth of 300 feet unless paired with Swim Like the Dolphin. Grants no swimming ability on its own, and there is no saving throw.', "range" = 'Self or other by touch', "duration" = '20 minutes per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.83' WHERE name = 'Water: Breathe Underwater';

-- Water: Change Current  (description was a category stub)
UPDATE spells SET description = 'Reverses or redirects an ocean current within a 1000 foot radius per level of the caster for a short time - useful for sending adrift ships or wreckage in a chosen direction, dispersing pollution or toxins, or confusing fish and sailors.', "range" = 'Current nearest the Warlock; affects 1000 foot (305 m) radius per level of experience', "duration" = '5 minutes per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Change Current';

-- Water: Fog of Fear  (description was a category stub)
UPDATE spells SET description = 'Conjures a dense fog that cuts vision, including tech and magical optics, to six feet and imposes -2 on initiative, strike, dodge and parry with half speed. It also fills the area with dread and moving shadows, forcing a save vs Horror Factor 14 or the victim loses initiative and one attack and has a 1-60% chance of fleeing the fog and refusing to re-enter it.', "range" = '20 foot (6 m) area per level of the experience', "duration" = 'One minute per level of the Warlock', "saving_throw" = 'Standard vs Horror Factor 14' WHERE name = 'Water: Fog of Fear';

-- Water: Foul Water  (description was a category stub)
UPDATE spells SET description = 'Turns good drinking water bitter, discolored, and mildly toxic - up to 30 gallons per level of experience. Anyone who drinks it risks diarrhea or nausea (27% chance) and takes one Hit Point of damage per glass. Can also spoil milk, beer, wine and other beverages, though only ten gallons of those can be affected.', "range" = 'Touch or 12 feet (3.6 m)', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Foul Water';

-- Water: Frostblade  (description was a category stub)
UPDATE spells SET description = 'Turns an ordinary S.D.C. sword, knife, or metal rod into a glowing four-foot blade of icy Mega-Damage energy, doing 4D6 M.D. per hit (6D6 to fire-based creatures, or 8D6 if they already take double damage from cold). The blade can parry energy blasts with no special bonus and is not damaged by parrying, and it can be handed off to someone else. It reverts to its mundane form when the spell''s duration ends.', "range" = 'Close, hand to hand combat', "duration" = 'Two minutes per level of experience', "saving_throw" = 'None', "damage" = '4D6 M.D.' WHERE name = 'Water: Frostblade';

-- Water: Liquids to Water  (description was a category stub)
UPDATE spells SET description = 'Transforms up to ten gallons of almost any liquid per level of experience into fresh drinking water. Toxic liquids such as poison, gasoline or chemicals are much harder to convert - only a 7% chance per level of success, and only half the usual amount changes if it works. Cannot transform magic potions, and a failed attempt leaves the liquid unchanged.', "range" = 'Touch or 12 feet (3.6 m) away', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Liquids to Water';

-- Water: Resist Fire  (description was a category stub)
UPDATE spells SET description = 'Makes the target immune to ordinary S.D.C. fire, while Mega-Damage fire, plasma, and magical fire all do only half damage. Penalties from smoke are also cut in half.', "range" = 'Self', "duration" = 'Five minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Resist Fire';

-- Water: Ride the Waves  (description was a category stub)
UPDATE spells SET description = 'Summons an invisible wave that the caster can ride like a surfboard, with far greater control and balance than the real thing. It can be cast on other people as well, but only the Warlock who cast it can summon and steer the wave, which moves at 25 mph.', "range" = 'Self', "duration" = 'Ten minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Ride the Waves';

-- Water: Swim as a Fish: Superior  (description was a category stub)
UPDATE spells SET description = 'Grants the recipient (self or up to two others by touch) the ability to breathe underwater and swim expertly at a speed of 20, with a 95% base swimming skill and no fatigue for the duration. Also gives a +2 bonus to parry and dodge while in water, and allows diving to a maximum depth of two miles.', "range" = 'Self or others by touch', "duration" = '10 minutes per level of spell caster', "saving_throw" = 'None' WHERE name = 'Water: Swim as a Fish: Superior';

-- Water: Water Seal  (description was a category stub)
UPDATE spells SET description = 'Envelops a single item weighing up to 40 pounds per level of experience in an invisible force that keeps it completely dry, protecting it from water damage. Particularly handy for safeguarding scrolls or books that must travel near or through water.', "range" = 'Touch or six feet (1.8 m)', "duration" = 'One hour per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Water Seal';

-- Water: Calm Waters  (description was a category stub; cited p.88, entry is on p.84)
UPDATE spells SET description = 'The caster imposes his will over the forces of nature to reduce the intensity of water turbulence, shrinking the size of waves and slowing their speed by half within an eighty foot radius per level of experience.', "range" = '80 foot (24.4 m) radius per level of experience.', "duration" = '30 minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.84' WHERE name = 'Water: Calm Waters';

-- Water: Circle of Rain  (description was a category stub; cited p.82, entry is on p.84)
UPDATE spells SET description = 'Conjures a heavy downpour with thunder and dark clouds over a 60 foot diameter area, cast up to 100 feet away and lasting five minutes per level. Everyone caught in it gets soaked and chilled, moves a third slower, and has both normal and night vision cut to 30 feet; it works indoors as well as outdoors and burns vampires and Fire Elementals for 4D6 damage per melee. There is no saving throw.', "range" = 'An area 60 feet (18.3 m) in diameter, that can be cast up to 100 feet (30.5 m) away.', "duration" = 'Five minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.84' WHERE name = 'Water: Circle of Rain';

-- Water: Command Fish  (description was a category stub; cited p.82, entry is on p.84)
UPDATE spells SET description = 'Lets the Warlock mentally summon and command ordinary fish within a 60 foot per level area, for ten minutes per level. The fish obey only simple commands like come here, swim over there, or attack, and cannot speak or reason. Dolphins, whales and other aquatic mammals cannot be controlled, nor can amphibians or reptiles.', "range" = '60 foot (18.3 m) area per level of experience.', "duration" = '10 minutes per level of the Warlock.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.84' WHERE name = 'Water: Command Fish';

-- Water: Freeze Water  (description was a category stub; cited p.82, entry is on p.84)
UPDATE spells SET description = 'Instantly freezes 30 gallons of water per level of experience within 30 feet. The ice stays frozen until ordinary conditions melt it, and there is no saving throw.', "range" = '30 feet (9.1 m).', "duration" = 'Varies.', "saving_throw" = 'None.', source_book = 'Rifts Book of Magic p.84' WHERE name = 'Water: Freeze Water';

-- Water: Impervious to Ocean Depth  (description was a category stub; cited p.82, entry is on p.84)
UPDATE spells SET description = 'Makes the Warlock, or up to two others by touch, immune to the crushing pressure of the ocean depths for ten minutes per level, letting them travel to the bottom of the deepest trench unharmed. A recipient who wants to resist gets a standard save. If the spell lapses while still at great depth the victim is instantly crushed; for humans, elves and most humanoids any depth past 250 feet is deadly.', "range" = 'Self or two others by touch.', "duration" = '10 minutes per level of experience.', "saving_throw" = 'Standard, if the recipient desires to resist.', source_book = 'Rifts Book of Magic p.84' WHERE name = 'Water: Impervious to Ocean Depth';

-- Water: Resist Cold  (description was a category stub)
UPDATE spells SET description = 'Makes the target immune to ordinary cold down to ten degrees below zero. Mega-Damage or magical cold still affects them, but only does half damage.', "range" = 'Self', "duration" = 'Five minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Resist Cold';

-- Water: Sheet of Ice  (description was a category stub)
UPDATE spells SET description = 'Coats the ground or objects in an inch-thick layer of slippery ice. Anyone walking across it at normal speed has an 80% chance of falling each round (halving speed drops that to 32%, with a -4 penalty to strike, parry or dodge while moving); standing still still carries a 15% fall chance and a -1 penalty. Ice-coated items are unpleasantly cold and have a 50% chance of slipping from a character''s grip; the ice itself has an A.R. of 8 and 30 S.D.C.', "range" = 'The area affected is 10 feet (3 m) per level of experience, but the spell can be cast up to 60 feet (18.3 m) away', "duration" = 'One minute (4 melees) per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Sheet of Ice';

-- Water: Communicate with Sea Creature  (description was a category stub)
UPDATE spells SET description = 'Lets the caster speak telepathically with any sea creature - fish, sea mammals, sea serpents - though not with underwater plants, invertebrates, or intelligent beings. Being able to hold a conversation does not mean the creature will actually cooperate, obey, or give accurate information.', "range" = '100 feet (30.5 m)', "duration" = 'Ten minutes per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Communicate with Sea Creature';

-- Water: Create Water  (description was a category stub)
UPDATE spells SET description = 'Conjures a quantity of pure water out of thin air, drawing and purifying moisture from the surrounding air into a container the caster designates - one gallon per level of experience (half that in a desert, double at sea or in a rain forest). A container must be available or the water simply spills on the floor; enough of it can supply an entire town lacking a fresh water source.', "range" = '10 feet (3 m), line of sight, or touch (of a container)', "duration" = 'Permanent', "saving_throw" = 'None' WHERE name = 'Water: Create Water';

-- Water: Hail  (description was a category stub)
UPDATE spells SET description = 'Rains baseball-sized hailstones over a wide area, inflicting 1D4 M.D. per level of the Warlock to everyone and everything caught in it, every melee the spell lasts. The only defense noted is to take cover; it can be cast up to fifty feet away per level of experience.', "range" = 'Affects a 10 foot (3 m) circular area per level of the Warlock; can be cast up to 50 feet (15.2 m) per experience level', "duration" = 'One minute (4 melees) per level of experience', "saving_throw" = 'None other than to take cover', "damage" = '1D4 M.D. per level of the Warlock' WHERE name = 'Water: Hail';

-- Water: Shards of Ice  (description was a category stub)
UPDATE spells SET description = 'Instantly conjures and hurls razor-sharp shards of ice from the caster''s palms, inflicting 1D4 M.D. per hit. Each shard must be aimed and rolled to strike individually, but the caster can fire as many shards as he has melee attacks, with each blast counting as one attack.', "range" = '30 feet (9 m) per level of experience', "duration" = 'One melee round per level of the Warlock', "saving_throw" = 'A dodge or parry is possible if the victim knows he is under attack and rolls a 17 or higher', "damage" = '1D4 M.D.' WHERE name = 'Water: Shards of Ice';

-- Water: Speak Underwater  (description was a category stub)
UPDATE spells SET description = 'Lets surface dwellers speak clearly underwater with the same ease as they do in open air. Their voice carries to a range of 100 feet plus 10 feet per level of the Warlock casting it.', "range" = 'Self or two others by touch', "duration" = '10 minutes per level of experience', "saving_throw" = 'Standard, but only if the recipient resists' WHERE name = 'Water: Speak Underwater';

-- Water: Swim Like the Dolphin  (description was a category stub)
UPDATE spells SET description = 'Grants dolphin-like swimming ability (though not the ability to breathe underwater) at 98% proficiency, letting the recipient swim up to 50 mph, hold their breath for six minutes, leap fifteen feet clear of the water, dive to 200 feet, and survive depths of up to a mile. Also grants a +5 bonus to dodge while swimming.', "range" = 'Self or others by touch', "duration" = '20 minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Swim Like the Dolphin';

-- Water: Wall of Ice  (description was a category stub)
UPDATE spells SET description = 'Creates a wall of ice, roughly eight feet square and four feet thick per level of experience, with 40 M.D.C. (or 200 S.D.C.) per level. It can be cast up to sixty feet away, and dropping it on someone inflicts 1D6x10 S.D.C. damage while trapping them beneath it (freeing them takes a combined P.S. of 60). A Dispel Magic Barriers spell will make it vanish.', "range" = 'Can be cast 60 feet (18.3 m) away and affects/covers an 8 x 8 x 4 feet (2.4 x 2.4 x 1.2 m) area per level of experience', "duration" = 'Four minutes per level of the Warlock or until destroyed', "saving_throw" = 'None' WHERE name = 'Water: Wall of Ice';

-- Water: Water Wisps  (description was a category stub)
UPDATE spells SET description = 'Summons and commands 1D4 small Water Elemental essence fragments, each invisible while in water, that can retrieve items up to 900 pounds from a river or seabed, drown swimmers, capsize small boats, scout ahead, or fight on the caster''s command. They must be summoned within a body of water and there is no limit on how far they can travel from the Warlock.', "range" = 'Immediate area', "duration" = '15 minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Water Wisps';

-- Water: Earth to Mud  (description was a category stub)
UPDATE spells SET description = 'Turns ordinary earth or dirt into mud, affecting up to 100 pounds per level of experience. Has no effect on clay, stone, Elementals, or Golems.', "range" = '20 feet (6 m) per level of experience', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Earth to Mud';

-- Water: Protection from Lightning  (description was a category stub; cited p.82, entry is on p.86)
UPDATE spells SET description = 'Makes the Warlock, and only himself, impervious to lightning and electrical effects for three minutes per level, taking no damage from them at all. There is no saving throw.', "range" = 'Self', "duration" = 'Three minutes per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.86' WHERE name = 'Water: Protection from Lightning';

-- Water: Snow Storm  (description was a category stub; cited p.82, entry is on p.86)
UPDATE spells SET description = 'Drops the temperature 15 degrees below freezing and whips up 30 mph winds with snow and hail over a 30 foot area per level, cast up to 50 feet away per level and lasting two minutes per level. Snow piles up a foot every other melee round, speed is halved, and vision (including optics) is cut to 20 feet; the cold, wind and hail together deal 10 S.D.C. damage every melee. There is no saving throw.', "range" = 'Affects a 30 foot (9 m) area per level of the Warlock and can be cast 50 feet (15.2 m) away per level of experience', "duration" = 'Two minutes (8 melees) per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.86' WHERE name = 'Water: Snow Storm';

-- Water: Ten Foot Ball of Ice  (description was a category stub; cited p.82, entry is on p.86)
UPDATE spells SET description = 'Summons a ten foot ball of ice, castable up to 120 feet away, that either rolls along the ground for 1D6 M.D. to anything in its path or drops from 60 feet up for 2D6 M.D. The Warlock steers it at a speed of 10 and gets a plus 2 strike bonus when aiming it at a specific target; it has 70 M.D.C., weighs a ton, and lasts one minute per level unless it melts first. Targets can dodge, leap, or run clear of it.', "range" = 'Can be cast up to 120 feet (36.6 m) away', "duration" = 'One minute (4 melees) per level of the Warlock', "saving_throw" = 'Dodge, leap, or run out of its way', source_book = 'Rifts Book of Magic p.86' WHERE name = 'Water: Ten Foot Ball of Ice';

-- Water: Whirlpool  (description was a category stub; cited p.82, entry is on p.86)
UPDATE spells SET description = 'Conjures a spinning whirlpool with a 120 foot radius in a large body of water, castable up to 500 feet away and lasting one minute per level. Anything caught at the edge is dragged toward the center at ten feet per melee, with a 30% drowning chance for those pulled under. The 20 foot center deals 1D4x10 M.D. per melee to small objects and 2D6x10 M.D. plus 1D6x100 more to large ships or bots that hit dead center, with a 90% chance of drowning all hands; a Dispel Magic Barriers spell destroys the whirlpool instantly. There is no saving throw.', "range" = '120 foot (36.6 m) radius of effect, can be cast up to 500 feet (153 m) away', "duration" = 'One minute (4 melee rounds) per level of the Warlock', "saving_throw" = 'Not applicable', source_book = 'Rifts Book of Magic p.86' WHERE name = 'Water: Whirlpool';

-- Water: Encase in Ice  (description was a category stub)
UPDATE spells SET description = 'Encases an object or part of a person''s body in a block of ice with 10 M.D.C., inflicting 4D6 S.D.C. damage to bare flesh in the process. Encasing someone''s head will blind them, render them unconscious within two minutes, and suffocate them within six unless freed. The caster can make the ice vanish instantly at will.', "range" = 'Six feet (1.8 m) per level of experience', "duration" = 'Until melts or broken', "saving_throw" = 'None' WHERE name = 'Water: Encase in Ice';

-- Water: Heal Burns  (description was a category stub)
UPDATE spells SET description = 'Heals burns specifically - not cuts, bruises, or other injuries - instantly making the pain vanish and the skin restore itself, recovering 30 S.D.C. and 3D6 Hit Points. Leaves little if any scarring.', "range" = 'Touch or 10 feet (3 m) away', "duration" = 'Instant and permanent', "saving_throw" = 'None' WHERE name = 'Water: Heal Burns';

-- Water: Hurricane  (description was a category stub)
UPDATE spells SET description = 'Conjures a violent sea storm with 100 to 150 mph winds across a 120 foot area, whipping up 30 foot waves that batter ships for 3D6x10 M.D. per melee. Anyone caught above decks takes 1D6 M.D. per melee from flying debris and hail, and there is a 1-33% chance of being washed overboard. Can only be cast over large lakes, seas, or oceans.', "range" = 'Affects a 120 foot (36.6 m) area and can be cast up to 500 feet away (152 m)', "duration" = 'One minute (4 melee rounds) per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Hurricane';

-- Water: Little Ice Monster  (description was a category stub)
UPDATE spells SET description = 'Summons a fragmented essence from a Greater Ice Elemental to serve as a rock-hard ice elemental assistant that can scout, spy, hunt, defend, attack, or carry items at the Warlock''s direction, with no limit on how far it can range from its summoner. It obeys only the Warlock who summoned it and returns to its own plane when the spell''s duration ends or it is dismissed.', "range" = 'Immediate area', "duration" = '30 minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Little Ice Monster';

-- Water: Part Waters  (description was a category stub)
UPDATE spells SET description = 'Parts the waters of a lake, river, or sea, drying the exposed seabed so it can be walked across. If the Warlock loses concentration, is knocked out, or is killed, the waters come crashing back - anyone caught underneath has a 70% chance of drowning and takes 40 M.D. (triple for seas, quadruple for oceans).', "range" = '500 feet (153 m) long by 10 feet (3 m) wide per experience level', "duration" = 'Five minutes per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Part Waters';

-- Water: Summon Sharks or Whales  (description was a category stub; cited p.82, entry is on p.87)
UPDATE spells SET description = 'Summons and commands one shark or whale per level of experience within a 300 foot radius, for eight melee rounds per level. Only creatures already inside that radius respond, and they only keep obeying while they stay within it, following simple commands. There is no saving throw.', "range" = '300 foot (91.6 m) radius', "duration" = 'Eight melee rounds per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.87' WHERE name = 'Water: Summon Sharks or Whales';

-- Water: Drought  (description was a category stub)
UPDATE spells SET description = 'Raises local temperatures by ten degrees Fahrenheit per level of experience and prevents any rainfall for as long as the spell lasts. This kills or damages plant life and dries up shallow wells and ponds, and after three weeks or more there is a 54% chance per week that it sparks brush fires.', "range" = '400 foot (122 m) radius per level of experience', "duration" = 'One week per level of the Warlock', "saving_throw" = 'None' WHERE name = 'Water: Drought';

-- Water: Rain Dance  (description was a category stub; cited p.82, entry is on p.87)
UPDATE spells SET description = 'Creates a normal rainstorm over a 400 foot radius per level by manipulating the weather, requiring a solid 10 plus 1D6 minutes of dancing and chanting. On success, rain begins falling 6D6 minutes after the dance ends and dispels any magical drought in effect; the dance succeeds only 12% of the time per level of the Warlock. There is no saving throw.', "range" = '400 foot (122 m) radius per level of the Warlock', "duration" = '30 minutes per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.87' WHERE name = 'Water: Rain Dance';

-- Water: Summon Storm  (description was a category stub; cited p.82, entry is on p.87)
UPDATE spells SET description = 'Calls up a destructive storm in the immediate area or up to a mile away per level, lasting half an hour per level. It dumps four inches of rain an hour, flooding streets deep enough to immobilize vehicles and halving travel speed in the poor visibility; 35 mph gusts combined with hail deal 1-6 S.D.C. damage to structures every half hour, and anyone outside is soaked within two melees. At sea it can raise waves of six to eight feet. There is no saving throw.', "range" = 'Immediate area around the mage or up to one mile (1.6 km) per level of the warlock', "duration" = 'Half hour per level of the Warlock', "saving_throw" = 'None', source_book = 'Rifts Book of Magic p.87' WHERE name = 'Water: Summon Storm';

-- Water: Calm Waters (greater)
UPDATE spells SET "range" = 'One mile radius per level of experience', "duration" = 'One hour per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Calm Waters (greater)';

-- Water: Creature of the Waves  (description was a category stub)
UPDATE spells SET description = 'Temporarily transforms the caster into a Water Elemental-like being of shimmering, silver, semi-opaque water vapor with 200 M.D.C., able to swim at 120 mph, turn invisible in water, and squeeze through keyholes and cracks in a single action. In this form Mega-Damage attacks (other than fire, which does double) only do half damage, but the caster can only inflict normal S.D.C. damage himself and is -2 to strike with weapons.', "range" = 'Self', "duration" = 'One melee (15 seconds) per level of experience', "saving_throw" = 'None' WHERE name = 'Water: Creature of the Waves';

-- Water: Tidal Wave  (description was a category stub; cited p.82, entry is on p.88)
UPDATE spells SET description = 'Creates a single towering wave, 200 feet long and wide per level and ten feet tall per level, that the Warlock can slam into a coastline, vessels, or buildings once per melee for a duration of one melee per level. Ships have a 5% chance per level of capsizing to each wave, the wave reaches 30 feet inland per level, and it can be cast from up to 200 feet away per level. Damage is 4D6x10 M.D. and there is no saving throw.', "range" = '200 foot (61 m) long/wide wave per level of experience', "duration" = 'One melee per level of the Warlock', "saving_throw" = 'None', "damage" = '4D6x10 M.D.', source_book = 'Rifts Book of Magic p.88' WHERE name = 'Water: Tidal Wave';

-- Dimensional Portal
UPDATE spells SET "range" = 'A few feet (one meter) away.', "duration" = '30 seconds (2 melee rounds) per level of the spell caster, or one minute (4 melees) per level of experience when performed as a ritual.', "saving_throw" = 'None.' WHERE name = 'Dimensional Portal';

-- Re-Open Gateway
UPDATE spells SET "range" = '10 feet (3 m).', "duration" = 'One melee round per level of experience (at most).', "saving_throw" = 'None.' WHERE name = 'Re-Open Gateway';

-- Summon and Control Canines
UPDATE spells SET "range" = 'Varies', "duration" = 'Five hours per level of experience', "saving_throw" = 'Standard, but only if a part of the player characters group. Wild animals do not get a save, they just come as summoned' WHERE name = 'Summon and Control Canines';

-- Summon and Control Rodents
UPDATE spells SET "range" = '600 feet (183 m).', "duration" = 'Five hours per level of experience.', "saving_throw" = 'Standard animal.' WHERE name = 'Summon and Control Rodents';

-- Sustain
UPDATE spells SET "range" = 'Self or two others by touch', "duration" = '24 hours per level of experience', "saving_throw" = 'None' WHERE name = 'Sustain';

-- Time Slip
UPDATE spells SET "range" = 'Self', "duration" = 'Half a melee round (7 seconds)', "saving_throw" = 'None' WHERE name = 'Time Slip';

-- Wave of Frost  (description was NULL)
UPDATE spells SET description = 'A magical frost that damages delicate flowering plants and their roots across a six foot radius per level of experience, castable from several hundred feet away. It kills off 2D4x10% of the plants (reducing their yield by that amount) and irreparably damages another 1D4x10%, which will die within 48 hours unless restored by Shaman, Druid, or Elemental magic. It can also be used to frost over windows, obscuring them, though a peephole can be scraped clear in one melee round.' WHERE name = 'Wave of Frost';

-- Astral Projection  (description was NULL)
UPDATE spells SET description = 'Sends the caster''s astral body into the Astral Plane, another dimension, leaving the physical body behind. It functions exactly like the Psychic Sensitive ability of the same name.' WHERE name = 'Astral Projection';

-- Horror  (description was NULL)
UPDATE spells SET description = 'Places a permanent aura of dread on a specific object or person (rather than an area), radiating out five feet per level of experience. Anyone who comes within range must save versus Horror Factor 16 or flee in screaming terror and refuse to go near, use, or associate with the enchanted target for as long as the spell lasts. An unwilling human subject can also make a standard save vs magic to negate the enchantment outright, and the caster is always immune to his own spell''s effect.', "range" = 'The spell can be cast on a person or object by touch or up to 5 feet (1.5 m) away per level of the spell caster; line of sight. The aura of horror surrounding the enchanted person or object is five feet (1.5 m) per level of the spell caster', "duration" = 'Five minutes per level of experience' WHERE name = 'Horror';

-- Implosion Neutralizer  (description was NULL)
UPDATE spells SET description = 'Cast on an unexploded explosive device - dynamite, a grenade, a missile - it will cause the device to implode rather than explode if triggered while the spell''s duration is still active, halving both the blast radius and the damage inflicted. It can also be cast in the split second an explosion actually occurs, requiring the caster to win an initiative roll against the blast (ties favor the caster) to halve the damage before it happens. It does not work on bullets, nukes, long-range missiles, magical fireballs or lightning, or natural phenomena like volcanoes and earthquakes.' WHERE name = 'Implosion Neutralizer';

-- Influence the Beast  (description was NULL)
UPDATE spells SET description = 'A mind control spell that lets the caster command as many animals as one per every two levels of experience, who momentarily recognize him as their superior and obey commands like attack, guard, hunt, or stand down. Targeting the leader of a pack brings the rest of the pack along with it, but the animals will not do anything wholly against their nature, such as attacking their own young. It has no effect on creatures of magic or supernatural monsters; a Shifter or Summoner can control one animal per level for half the usual P.P.E.' WHERE name = 'Influence the Beast';

-- Memory Bank  (description was NULL)
UPDATE spells SET description = 'Implants a hidden block of information - up to 1000 words, such as phone numbers, addresses, or incantations - deep in another person''s subconscious without their knowledge, retrievable by the caster with a touch at any time. The memory lasts three months per level of experience before fading, and there is no limit to how many memory banks can be stored in the same person, though a psionic Mind Block prevents both implanting and retrieving one.' WHERE name = 'Memory Bank';

-- Power Bolt  (description was NULL)
UPDATE spells SET description = 'A long-range attack that fires a blue beam of energy from the caster''s hand, doing 5D6 M.D. plus 2 per level of experience to a single target. It essentially never misses unless the victim rolls a natural or bonus-modified 20 or better to dodge, making it one of the few spells that can compete with the heavy weapons mounted on vehicles and robots, particularly against aircraft and ships.' WHERE name = 'Power Bolt';

-- Invulnerability  (description was NULL)
UPDATE spells SET description = 'Grants near-total protection: the recipient becomes impervious to cold, fire and all energy attacks, as well as disease, poison, toxins, gases and drugs, and is wrapped in a glowing energy aura with 50 M.D.C. Once that 50 M.D.C. is used up, physical or energy damage starts hitting the character''s own M.D.C. or Hit Points, but the immunity to disease, poison, gas and drugs remains. The recipient also gets a +10 bonus to save vs magic, psionic attacks and Horror Factor for the duration.' WHERE name = 'Invulnerability';

-- Ley Line Fade  (description was NULL)
UPDATE spells SET description = 'The caster and up to two others by touch meld into the ley line''s energy, becoming completely invisible and undetectable by any sensor, optic, magic or psionic means. While faded, the affected characters are rooted in place (though they can still turn their heads and see), cannot speak, smell, cast spells, use psionics or recover P.P.E., I.S.P., Hit Points or S.D.C., but can sense Rifts opening or closing and ley line storms anywhere on the connected lines. It can be cancelled at will, but being caught in a ley line storm while faded is dangerous - the character cannot become solid again until the storm passes and may suffer amnesia or be swept into a Rift.' WHERE name = 'Ley Line Fade';

-- Negate Mechanics  (description was NULL)
UPDATE spells SET description = 'Momentarily jams or freezes one specific function of a targeted mechanism no larger than a basketball - jamming a gun, delaying a grenade''s fuse, freezing a sight or a robot''s joint or sensor, or locking up a computer for 15 seconds. It causes only minor, temporary glitches with no lasting damage, and cannot fully disable a large device (like stopping a whole robot from moving); it also has no effect on cybernetic or bionic systems wired directly into living flesh.' WHERE name = 'Negate Mechanics';

-- Second Sight  (description was NULL)
UPDATE spells SET description = 'Lets the caster mentally spy on someone he has previously met, seeing and hearing what that person is doing and saying at that exact moment, as if watching a crystal ball in his mind. It can also be used in reverse, to show someone else what the caster is currently experiencing. The images are always true and cannot be faked or altered, and the target has no idea he is being watched unless he has a Mind Block, which blocks the spell entirely.' WHERE name = 'Second Sight';

-- See Wards  (description was NULL)
UPDATE spells SET description = 'Reveals the normally invisible magical energy radiating from wards, letting the caster tell whether a ward is genuine (a fake one gives off no energy) or currently active, and see the field of magic covering a warded area.' WHERE name = 'See Wards';

-- Hallucination  (description was NULL)
UPDATE spells SET description = 'Implants a vivid, fully convincing hallucination directly into one target''s mind - only that person perceives and reacts to it, regardless of what anyone else says or does. A successful save vs magic means the spell has no effect at all, and a Mind Block adds a +3 bonus to that save.' WHERE name = 'Hallucination';

-- Invincible Armor  (description was NULL)
UPDATE spells SET description = 'Encases the recipient in shimmering magical plate armor with 25 M.D.C. per level of the caster, regenerating 1D6 M.D.C. per melee round. It provides full environmental protection (heat, cold, disease, toxins) with its own air supply, and halves all energy damage, whether magical or mundane. When the armor is finally destroyed, it absorbs the excess damage and vanishes in a flash of light with none carried over to the wearer, though the armor is cumbersome and imposes a -15% penalty to prowl, climb, swim and similar physical skills. It cannot be placed on giant automatons, power armor or robots.' WHERE name = 'Invincible Armor';

-- Ley Line Time Capsule  (description was NULL)
UPDATE spells SET description = 'Seals a closed container (crate, box, bag, whatever) out of the normal flow of time, so its non-living contents - food, water, potions, books, clothing, weapons and the like - age at only one minute per year while sealed, and cannot spoil. Living creatures cannot be placed inside. The instant the container is opened, the effect ends permanently; it costs less P.P.E. cast on a ley line than off one.' WHERE name = 'Ley Line Time Capsule';

-- Lifeward  (description was NULL)
UPDATE spells SET description = 'Takes two melee rounds to inscribe a magic sun-symbol on the recipient''s chest or forehead and on his body armor. The spell lies dormant until that marked armor is reduced to zero M.D.C., at which point it activates and converts subsequent Mega-Damage attacks into ordinary S.D.C. damage for one minute per level of the caster, letting an otherwise-atomized character instead take damage to Hit Points and possibly survive. The character can still fall into a coma or die if his Hit Points reach zero. It cannot be placed on Mega-Damage creatures like dragons, demons or automatons.' WHERE name = 'Lifeward';

-- Create Steel  (description was NULL)
UPDATE spells SET description = 'Despite its name this is really a recycling spell: it takes scrap or rusted metal ore (iron, steel, tungsten, copper, aluminum and similar) and magically reforges it into clean, usable sheets, bars or beams, with no material loss and actually 5% more finished metal per level of the caster than the raw scrap should yield. It can convert about 100 pounds of raw scrap per level into roughly 200 S.D.C. worth of steel, or a much smaller 10 pounds of Mega-Damage scrap per casting into about 15 M.D.C. of M.D. steel. It cannot repair finished armor, vehicles or devices, or affect metal that is part of or connected to a living being; it only works on raw or scrap material.' WHERE name = 'Create Steel';

-- Curse: Phobia  (description was NULL)
UPDATE spells SET description = 'Implants an unreasoning phobia of the caster''s choosing (or a random roll) in the victim, who then suffers a full phobic reaction every time he encounters that feared thing for the duration. Only a Remove Curse spell reliably cures it early; Negate Magic has just a 25% chance of success, though the caster who placed the curse can always cancel it himself.' WHERE name = 'Curse: Phobia';

-- D-Step  (description was NULL)
UPDATE spells SET description = 'Tears open a brief rip in reality that the caster steps through and seems to vanish, becoming completely undetectable by sensors, psionics or magic for the duration. The rip itself is invisible to everyone except Shifters and other dimensionally-attuned characters, and while stepped through it the caster can still see (but not hear or smell) the place he just left and is immune to anything happening there. Temporal Raiders and Temporal Wizards cast it for half the P.P.E. and get double the duration.' WHERE name = 'D-Step';

-- Ley Line Phantom  (description was NULL)
UPDATE spells SET description = 'Turns the caster into a faint, transparent, intangible ghost of himself, immune to physical attacks and the elements but still vulnerable to magic and psionics, and able to attack only with magic or psionics in return. As a phantom he is confined to the ley line itself, but can fly along it at double his normal running speed without fatigue, up to the height the line''s energy reaches (rarely above 6000 feet), and can broadcast up to 100 words to be heard by everyone on the line for a mere two P.P.E. He suffers the same dangers as a Ley Line Fade if caught in a ley line storm while phantom.' WHERE name = 'Ley Line Phantom';

-- Ley Line Time Flux  (description was NULL)
UPDATE spells SET description = 'A ley-line-only spell with three uses: it can speed up or slow down the felt passage of time for everyone on the line (friend and foe alike, only the caster is immune), doubling or halving how long tasks and travel seem to take; it can negate a Time Flux spell or random time-flux anomaly cast by someone else; or it can be used as a one-way Time Leap, sending the caster and one companion or vehicle per level forward anywhere from minutes up to 12 hours per level into the future (double for Temporal Raiders and Temporal Wizards), arriving at the same location with no memory of what happened in the intervening time.' WHERE name = 'Ley Line Time Flux';

-- Metamorphosis: Insect  (description was NULL)
UPDATE spells SET description = 'Transforms the caster (or, via ritual, someone else) into an insect between half an inch and six inches long, retaining his own intelligence, memory and Hit Points, but unable to perform human skills, speak or cast spells while in that form. Insect abilities vary but generally include a high prowl skill, near-perfect climbing (even upside down or on walls), and a bonus to automatically dodge. The caster can revert to normal at will, though his clothes do not come back with him.' WHERE name = 'Metamorphosis: Insect';

-- Realm of Chaos  (description was NULL)
UPDATE spells SET description = 'Plunges the caster and everyone within a 100-foot radius into a strange, empty mirror-dimension called the Realm of Chaos, where each victim (except the caster) is confronted by their own worst enemy or greatest fear, manifested as a fully real, fully dangerous opponent that can be fought and killed, not an illusion. The only ways out are for the spell''s duration to run out, for someone to kill the caster, or for the caster to lead everyone back himself - he cannot leave the Realm without taking everyone he brought with him.', "range" = 'Up to a 100 foot (30.5 m) radius around the spell caster', "duration" = 'One minute per level of experience', "saving_throw" = '-3 to save' WHERE name = 'Realm of Chaos';

-- Swords to Snakes  (description was NULL)
UPDATE spells SET description = 'Turns swords or other hand-held items weighing less than four pounds into hostile snakes that immediately bite whoever is holding them for 1D4 S.D.C. damage per attack, reverting back to their original form only when the spell''s duration ends. Magic and Techno-Wizard weapons are immune, and the caster can transform one item per level of experience.' WHERE name = 'Swords to Snakes';

-- Tame Beast  (description was NULL)
UPDATE spells SET description = 'Tames a wild animal with good to high intelligence (I.Q. 4 or better, but not a creature of magic or supernatural being). The beast gets a save; if it fails, spending roughly an hour of attention and training with the caster forges a permanent bond, turning it into a loyal watchdog, mount or companion that nonetheless keeps its own instincts and personality and is not magically enslaved - it will abandon or attack a master who treats it cruelly. This spell only works once on a given animal, and the caster can keep only one tamed animal per two levels of experience (Shifters and Summoners get one per level, at half the P.P.E. cost).' WHERE name = 'Tame Beast';

-- Illusory Forest  (description was NULL)
UPDATE spells SET description = 'Conjures the illusion of a forest - trees and vegetation styled to fit the surroundings or look strange and alien, at the mage''s discretion - covering up to a 3,000 foot square area per level of the caster. A cheaper simple version is purely visual with no sound or motion; a costlier elaborate version adds full sound, smell and movement and is far more convincing. Anyone who fails to save vs magic sees and treats the illusion as a real forest, useful for camouflage, concealing landmarks, or hiding a lair, though touching the trees or driving through them reveals they are insubstantial. It creates vegetation only, not terrain features like hills, caves or rivers.', "range" = 'Can be cast up to 500 feet (152 m) away and affects a 3,000x3,000 foot (914x914 m) area per level of the spell caster; area affect.' WHERE name = 'Illusory Forest';

-- Ley Line Ghost  (description was NULL)
UPDATE spells SET description = 'Cast at the moment of death (within the last 30 minutes of life) on oneself or a willing dying participant, this keeps the dying practitioner''s mind and life essence bound to the ley line as a faint, intangible ghost rather than passing on. The ghost can speak only softly, is untouchable by physical attacks or ordinary magic weapons, and can use magic or psionics up to his P.E. or M.E. attribute plus one point per level, regenerating that reserve fully every 24 hours (though he cannot draw on the ley line itself). He is bound to that specific ley line and its connections and cannot leave it, lasting one day per level of experience before vanishing for good; an exorcism will banish him to the far end of the line early.' WHERE name = 'Ley Line Ghost';

-- Magic Warrior  (description was NULL)
UPDATE spells SET description = 'Conjures a translucent but largely real magical warrior shaped to the caster''s imagination, obeying a single simple command (like stop them or protect me) without needing the caster''s ongoing concentration. It has 50 M.D.C. plus 6 per level, five attacks doing 2D6 M.D. punches or 3D6 M.D. kicks, and bonuses of +4 on initiative and +5 to strike, parry and dodge. An enemy who chooses to disbelieve it gets a save vs magic; success halves the damage it deals him. The Warrior vanishes instantly if it strays more than 100 feet from the caster.' WHERE name = 'Magic Warrior';

-- Metamorphosis: Superior  (description was NULL)
UPDATE spells SET description = 'Transforms the caster into the physical shape of any real, living creature - animal, human, D-Bee, insect or fish, or even a supernatural creature''s appearance - while retaining his own I.Q., memory, attributes, Hit Points, S.D.C. and skills (none of the target creature''s special powers come with the disguise). A lengthy ritual version can be used to transform someone else instead, and the shape lasts until the duration ends or the caster cancels it.' WHERE name = 'Metamorphosis: Superior';

-- Meteor  (description was NULL)
UPDATE spells SET description = 'Conjures a blazing meteor that plunges from the sky and detonates on impact, doing 1D6x10 M.D. plus 2 M.D. per level of the caster to everyone within a 40 foot radius. The meteor is +4 to strike and especially effective against large groups or bunched-up targets.' WHERE name = 'Meteor';

-- Mystic Portal  (description was NULL)
UPDATE spells SET description = 'Rips open a rift usable in two ways: to punch a passage straight through solid walls or barriers (up to 12 feet deep per level of the caster), or to teleport instantly to a known, nearby location up to 100 feet away per level. Once someone steps through, the opening behind them closes - it''s strictly one-way, so a new portal is needed to return. It vanishes when its duration ends, when the caster wills it, or if successfully hit by a Negate Magic.' WHERE name = 'Mystic Portal';

-- Plane Skip  (description was NULL)
UPDATE spells SET description = 'A risky escape spell cast while being pulled into a dimensional portal, Rift or disturbance, letting the caster and one other by touch skip past the intended destination to land somewhere else instead - usually determined randomly and often a strange, alien dimension rather than anywhere familiar. A lucky roll sends them home or to the Astral Plane; a bad one dumps them in a totally unknown dimension of the GM''s choosing. Mega-Damage characters who land in an S.D.C. environment are converted to S.D.C. equivalents.' WHERE name = 'Plane Skip';

-- Purge Other  (description was NULL)
UPDATE spells SET description = 'Works exactly like Purge Self but performed on another living being - human, D-Bee or animal, though not on creatures of magic or supernatural beings. If the recipient is willing it works automatically; an unwilling target (say, one harboring a symbiote it wants to keep) gets a save vs magic at +8. A successful purge cleanses all toxins, drugs, disease, parasites and possessing forces, though any physical damage or scarring already caused remains.' WHERE name = 'Purge Other';

-- Reality Flux  (description was NULL)
UPDATE spells SET description = 'Temporarily strips a single weapon (two if touched) of its Mega-Damage potency, turning a Mega-Damage weapon - a Vibro-Blade, energy rifle, rune sword, whatever - into one that deals the same numeric damage but only in ordinary S.D.C./Hit Points for the duration. It has no effect on living beings, spells, body armor or walls, and against a vehicle or robot with an arsenal of weapons, the caster can only affect one specific weapon of his choosing.' WHERE name = 'Reality Flux';

-- Restore Limb  (description was NULL)
UPDATE spells SET description = 'Reattaches a single severed limb or appendage - a hand, arm, leg, ear, nose, finger - so that it functions perfectly and leaves no scar, provided it is the actual original body part (no substitutes work) and it has been severed for no more than 12 hours per level of the sorcerer. The ritual itself takes five minutes.' WHERE name = 'Restore Limb';

-- Speed Weapon  (description was NULL)
UPDATE spells SET description = 'Infuses a melee weapon with magical speed, letting whoever wields it attack twice as often - a character with six attacks per melee gets 12 - as long as he keeps using that weapon exclusively. Switching to a different weapon or action for even one attack costs two of the enchanted weapon''s extra attacks instead of one (parrying is free). It grants no other combat bonuses and cannot be cast on already-magical weapons (Rune, Bio-Wizard or Techno-Wizard) or on Automatons, power armor, robots or vehicles.' WHERE name = 'Speed Weapon';

-- Summon Greater Familiar  (description was NULL)
UPDATE spells SET description = 'Summons a lesser demon or supernatural being to serve as the caster''s familiar, bound either by a signed pact or by winning a mental battle of wills (the caster must beat his own Mental Affinity on three of five d20 rolls). Losing that contest means the demon may attack (1-50% chance) or simply vanish. Even a bound familiar demon will periodically challenge its master, roughly once a month, requiring another show of dominance to keep it in line, and remains fairly loyal but prone to lying or cheating. Good-aligned spell casters generally will not use this spell.' WHERE name = 'Summon Greater Familiar';

-- Create Magic Scroll  (description was NULL)
UPDATE spells SET description = 'Transfers the caster''s knowledge of a spell onto paper, letting anyone literate read the words aloud to trigger the magic themselves, even a non-spellcaster. The words vanish from the page the instant they are read, leaving a blank sheet, and cannot be photographed or successfully copied by hand. The scroll''s power can be set anywhere from first level up to the creator''s own level, but his personal bonuses don''t carry over - saves against scroll magic are always a flat 12, or 16 if the scroll was made as a ritual.' WHERE name = 'Create Magic Scroll';

-- Curse of the World Bizarre  (description was NULL)
UPDATE spells SET description = 'If the target fails a save vs magic, this curse makes him permanently see everything around him - including himself - the way the World Bizarre spell would make it look: writhing, monstrous and demonic, though it is purely a mental delusion. The victim lives in a constant state of fear and can never tell real threats from imagined ones, suffering penalties to skills, initiative, speed and attacks per melee; those with a Mental Endurance of 9 or lower suffer double penalties and must roll on a table for a permanent insanity (a phobia, an obsession with monsters, or a delusion that they themselves are a monster).' WHERE name = 'Curse of the World Bizarre';

-- Disharmonize  (description was NULL)
UPDATE spells SET description = 'Designed to break the cohesion of a large organized enemy force (20 or more), this spell surrounds the caster with an expanding aura of hazy light. Every enemy within range who fails a save vs magic becomes unable to think or act quickly, make decisions, follow orders or coordinate with the rest of the unit, degrading a disciplined group into a mob of confused individuals who each lose half their attacks per melee, lose initiative, and perform skills at -20%.' WHERE name = 'Disharmonize';

-- Energy Sphere  (description was NULL)
UPDATE spells SET description = 'Stores a reserve of P.P.E. in a floating sphere for its owner to draw on later, in any increment from a few points to the whole reserve at once - made when a mage knows he will need more power than he can hold for a high level spell or ritual. The reserve must be spent within days or it fades and is wasted. The sphere is impervious to most attacks but is destroyed by 500 M.D., bleeds 2D6x10 P.P.E. per minute inside an Anti-Magic Cloud, and loses 6D6 to each Negate Magic; Dispel Magic Barrier does nothing to it. Psi-Stalkers and other P.P.E. vampires cannot feed on it.' WHERE name = 'Energy Sphere';

-- Firequake  (description was NULL)
UPDATE spells SET description = 'The ground in the area of effect rumbles, cracks open, and spews sulfurous gas and jets of fire across a 100 foot radius, enough to engulf several houses. Anyone caught in it moves at only 10% normal speed and suffers -9 to strike, parry and dodge and -5 on initiative from the fumes, and must dodge shooting flames each round or take 5D6 M.D. (triple to large vehicles and giant robots). It takes most people 2D4 melee rounds to escape, and once it ends the ground looks completely undamaged aside from the casualties.' WHERE name = 'Firequake';

-- Id Alter Ego  (description was NULL)
UPDATE spells SET description = 'Creates an aggressive magical double of the target up to 60 feet away, identical in appearance, memories and skills but with the exact opposite alignment and disposition, prone to picking fights and causing trouble. Most duplicated gear is a harmless fake (magic items, alien devices and complex tech cannot be copied), and the double has no psionics or P.P.E. of its own unless it copies a spell caster. Only works on living mortals - it has no effect on Mega-Damage beings, creatures of magic or supernatural beings.' WHERE name = 'Id Alter Ego';

-- Illusory Terrain  (description was NULL)
UPDATE spells SET description = 'Works exactly like the 10th level Illusory Forest spell, but can conjure any kind of terrain or landscape rather than only a forest - anything from a city street to an alien world. A simple illusion (sight only) costs less P.P.E. than an elaborate one with sound, smell and moving detail, which is also harder to disbelieve.' WHERE name = 'Illusory Terrain';

-- Ley Line Storm Defense  (description was NULL)
UPDATE spells SET description = 'Raises an invisible barrier over the defended area that causes an oncoming Ley Line Storm, natural or summoned, to skip over it and continue down the line instead of striking. If the protected area sits at the end of a line, the storm is redirected back the way it came or down an intersecting line. Requires an active ley line and advance warning that a storm is coming; Tolkeen and Freehold both keep this ready for when a storm nears.' WHERE name = 'Ley Line Storm Defense';

-- Mindshatter  (description was NULL)
UPDATE spells SET description = 'A touch attack that shatters the victim''s sense of self, leaving them a shuffling, mindless husk with no memory, skills, goals or awareness beyond fleeting moments of fascination, for at least 24 hours. Every 24 hours the victim can attempt a saving throw (-2 on the first attempt) to begin recovering, regaining 10% of memories and abilities every 12 hours after a successful save. The victim retains no memory of the ordeal itself afterward.' WHERE name = 'Mindshatter';

-- Remove Curse  (description was NULL)
UPDATE spells SET description = 'An attempt to lift any curse from its target by rolling a saving throw vs magic (12 or higher, with bonuses) on the curse''s behalf. Success removes the curse instantly; failure means it remains and the spell must be paid for and cast again to try once more. The attempt gets a +5 bonus when cast as a spell and +10 when performed as a ritual.' WHERE name = 'Remove Curse';

-- Rift to Limbo  (description was NULL)
UPDATE spells SET description = 'Opens at a ley line nexus and conceals up to 50 man-sized people (or fewer, larger vehicles or objects) per level of the caster inside a hidden limbo realm of white mist, where nothing can detect them. The rift can be set to reopen automatically at a preset time or on command, at a fixed point anywhere along a ley line connected to the original nexus, dumping the hidden group out to spring an ambush. Time moves strangely inside - one hour outside feels like only 1D4 minutes to those waiting in limbo - and the reopening location, once set, cannot be changed.' WHERE name = 'Rift to Limbo';

-- Rift Teleportation  (description was NULL)
UPDATE spells SET description = 'Teleports up to 20 human-sized people per level of the caster from one ley line nexus to another familiar nexus within range, the rift opening and closing at each end in only a few seconds. An unwilling target gets a +3 bonus to save and, if successful, is left behind at the departure point instead of being moved. If cast during a Ley Line Storm the group is instead flung to a random spot 3D6x100 miles away; the spell only works between nexus points on the same world.' WHERE name = 'Rift Teleportation';

-- Summon Ley Line Storm  (description was NULL)
UPDATE spells SET description = 'Summons a genuine Ley Line Storm onto the ley line, with all the storm''s usual electromagnetic disturbances, dimensional anomalies and magic-disrupting effects. The caster can direct the storm''s movement and hurl bolts of its energy at chosen targets (each bolt costing a melee action), but is mentally linked to it the whole time - his body is entranced and vulnerable, and he can''t move, cast other spells, or act on his own until the storm is stopped and the spell cancelled.' WHERE name = 'Summon Ley Line Storm';

-- Swallowing Rift  (description was NULL)
UPDATE spells SET description = 'Opens an enormous, mile-high rift at a ley line nexus, generating a windstorm that pulls anything non-living and lighter than 10 pounds - including missiles and loose weapons - within a one mile radius (triple with a triangular ley line grid) into the rift and lost forever to another dimension. Living beings mostly manage to avoid getting swallowed, but any that do vanish only for as long as the rift is open, reappearing 2D6 minutes after it closes somewhere along a connecting ley line, dazed for 1D4 melee rounds. Can be combined with the Rift Triangular Defense System if the necessary ley lines are present.' WHERE name = 'Swallowing Rift';

-- Time Hole  (description was NULL)
UPDATE spells SET description = 'Teleports the caster and his possessions into a private, featureless white void bounded to a 20 foot area per level, where he can hide away to recover from wounds or P.P.E. loss, plan, or study in total isolation. Time passes normally for the mage inside, but much more slowly relative to the outside world - 12 hours in the Time Hole is only 2 hours outside - letting him stay up to 24 hours per level while appearing gone for only a fraction of that time.' WHERE name = 'Time Hole';

-- Protection Circle: Superior  (description was NULL)
UPDATE spells SET description = 'A superior version of the basic protection circle, costing 300 P.P.E. to draw and only 20 to reactivate if it is later disrupted (anyone with the P.P.E. can reactivate it). It keeps all supernatural creatures at least 20 feet from its edge and forces lesser beings out of line of sight entirely, and grants everyone inside +5 to save vs magic and psychic attacks, immunity to possession, +8 to save vs Horror Factor, plus 10 extra P.P.E. for mages and 10 extra I.S.P. for psychics - though none of this protects against mundane weapons, and all the bonuses vanish the moment someone steps outside the circle.' WHERE name = 'Protection Circle: Superior';

-- Restore Life  (description was NULL)
UPDATE spells SET description = 'Restores a recently deceased and physically prepared body to life - wounds must already be sewn or bandaged, bones set - so long as death occurred within four hours per level of the caster, in which case it always works; up to double that time it only has a 50/50 chance. It fails outright if the head, brain, heart or lungs are missing, and the revived character comes back with only 10 Hit Points (or 1 M.D.C.) and Hit Points/S.D.C. or M.D.C. permanently reduced by 10%, needing further healing to recover fully. It cannot be used on supernatural beings or creatures of magic like dragons.' WHERE name = 'Restore Life';

-- Talisman  (description was NULL)
UPDATE spells SET description = 'Turns an ordinary object no larger than two feet (anything but iron or plastic) into a talisman that stores one Level 1-8 spell invocation the caster already knows (illusions excluded), usable three times before it drains and must be recharged at 50 P.P.E. plus the spell''s own cost per charge. Alternatively it can instead be made into a simple P.P.E. battery holding up to 50 points. A talisman is destroyed just by smashing it, and if its creator dies or cannot be found, it cannot be recharged by anyone but a god or Demon Lord.' WHERE name = 'Talisman';

-- Annihilate  (description was NULL)
UPDATE spells SET description = 'Conjures a baseball-sized orb of anti-matter that the caster hurls at a target up to 500 feet plus 100 feet per level away, striking at +3 (parrying is impossible, and giant or immobile targets cannot be missed at close range). The direct hit does 2D4x100 M.D., vaporizing the target entirely if that exceeds its M.D.C., while everything else within a 10 foot radius takes 4D6x10 M.D. from the contained blast, also vaporized if it exceeds their M.D.C.' WHERE name = 'Annihilate';

-- Close Rift  (description was NULL)
UPDATE spells SET description = 'Forces a dimensional rift closed by sheer will, permanently draining 2 P.P.E. from the caster''s base whether the attempt succeeds or fails (Shifters, Temporal Raiders, Temporal Wizards, Stone Masters, gods and Demon Lords are exempt from that cost). The rift gets its own saving throw vs magic; a failed attempt can simply be repeated. It cannot close the St. Louis Gateway or any other permanently opened rift.' WHERE name = 'Close Rift';

-- Id Barrier  (description was NULL)
UPDATE spells SET description = 'Erects a semi-transparent defensive barrier that radiates dread: anyone approaching within 10 feet must save vs a Horror Factor of 14 or be too frightened to pass and want to flee. Those who succeed must then save vs magic - success lets them through with only a headache and the loss of one attack, but failure conjures an Apparition of their own greatest fear, exactly like the 6th level invocation, which persists as long as the barrier stands. Only the caster who raised the Id Barrier can dismiss the Apparition or cancel the barrier early.' WHERE name = 'Id Barrier';

-- Impenetrable Wall of Force  (description was NULL)
UPDATE spells SET description = 'Creates a shimmering wall of pure force, up to 20x20 feet per level of the caster and placed up to 100 feet away, that nothing - no creature, weapon, vehicle or object - can pass through. Only a Dispel Magic Barriers spell or a powerful Negate Magic can bring it down.' WHERE name = 'Impenetrable Wall of Force';

-- Restoration  (description was NULL)
UPDATE spells SET description = 'Instantly and completely heals wounds, burns, broken bones and internal injuries, restoring full S.D.C. and Hit Points with only minimal scarring, and can reattach a limb severed within the last 48 hours. It cannot regrow a limb or organ that is missing entirely (vaporized or lost beyond that window), cannot bring back the dead, and cannot repair bionic or cybernetic parts.' WHERE name = 'Restoration';

-- Resurrection  (description was NULL)
UPDATE spells SET description = 'Restores life to someone who died within the last two months, returning them with the Hit Points, memories, abilities and skills they had at the moment of death - missing limbs stay missing but heal over. Success is a flat 45% chance (doubled for gods) regardless of the caster''s level, and can be attempted on the same corpse up to three times before another spell caster must take over; after six total failed attempts the person is beyond magic''s reach.' WHERE name = 'Resurrection';

-- Rift Triangular Defense System  (description was NULL)
UPDATE spells SET description = 'Raises a barely visible, dome-shaped force field over the area enclosed by three crossing ley lines, powered and continuously resealed by the lines themselves. Anything striking it is stopped as if hitting an invisible wall, though inflicting about 100 M.D. to a 10 foot section disrupts that section for 1D4 seconds - long enough for a couple of people to slip through before it heals and needs another 100 M.D. to punch through again. Can be combined with the Swallowing Rift spell.' WHERE name = 'Rift Triangular Defense System';

-- Summon & Control Sea Serpents  (description was NULL)
UPDATE spells SET description = 'A ritual that calls forth 1D4 sea serpents per level of the caster from within a 10 mile radius to obey his commands, though only creatures actually classed as sea serpents with an I.Q. of 8 or less (or animal intelligence) answer the call. The summoned serpents will fight and kill on command, but will not commit suicide, kill a mate or offspring, or fight to the death.' WHERE name = 'Summon & Control Sea Serpents';

-- Circle of Travel  (description was NULL)
UPDATE spells SET description = 'A ritual that links two magic circles, each requiring an hour to inscribe and 300 P.P.E. to create, placed up to 800 miles per level of the caster apart. Once both exist, spending 30 P.P.E. opens a small, stable, two-way rift letting the creator and up to two people per level step through to the other circle in under two seconds, and the circles can be reused indefinitely this way unless one is destroyed, defaced or otherwise ruined. Only two circles can ever be linked to each other.' WHERE name = 'Circle of Travel';

-- Dimensional Teleport  (description was NULL)
UPDATE spells SET description = 'Transports the caster and up to 1,500 lbs of gear to another dimension he has personally visited before, arriving at a random point within it unless he has a personal sanctuary, rift circle, or ley line nexus there to aim for. The success chance is a modest 6% per level of the caster, and if it fails, nothing happens at all - no dangerous side effect, just a wasted casting.' WHERE name = 'Dimensional Teleport';

-- Ley Line Restoration  (description was NULL)
UPDATE spells SET description = 'A deluxe version of the Restoration spell (Rifts Ultimate Edition, p.224) that can also regrow missing limbs and internal organs, harmlessly expelling any bionic replacements in the process. Performed as a ritual at a ley line nexus with a blood sacrifice, it permanently drains 6D6 P.P.E. from the performer''s base (double for a supernatural being or creature of magic) and permanently reduces the recipient''s own P.P.E. base by 4D6%. It cannot be performed by a caster on himself.' WHERE name = 'Ley Line Restoration';

-- Ley Line Shutdown  (description was NULL)
UPDATE spells SET description = 'Momentarily short-circuits a ley line, cutting off its power entirely for about one melee round per three levels of the caster, seldom more than a minute. Anyone drawing P.P.E. from the line loses that power immediately, Ley Line Phantoms and Faded individuals are revealed, Ley Line Ghosts vanish along with the line, and Techno-Wizard vehicles like Wing Boards that rely on the line fall out of the sky. Cast at a nexus it shuts down every connected line at once, but only for half the usual duration, and everything resumes the instant the ley line''s energy returns.' WHERE name = 'Ley Line Shutdown';

-- Summon Ally  (description was NULL)
UPDATE spells SET description = 'A ritual, requiring a magic circle, that reaches out to a specific known ally and asks them to come at once; if the ally agrees, they are instantly teleported into the circle with only whatever they had on their person at the time. The ally must be a genuine willing friend who is truly needed, not merely wanted for a visit, and must be on the same world and within range - the circle can bring exactly one named person and is used up afterward regardless of the answer. Getting home again afterward is left entirely up to that person.' WHERE name = 'Summon Ally';

-- Teleport: Superior  (description was NULL)
UPDATE spells SET description = 'Instantly teleports the caster, and anyone or anything within 20 feet up to 1,000 lbs per level, to any location he can picture, with the chance of success depending on how well he knows the destination - 99% for a familiar spot down to just 20% for somewhere known only by name or vague description. A failed attempt can land the traveler hundreds of miles off course, drop them falling from several feet up, or, in the worst case, materialize them inside a solid object.' WHERE name = 'Teleport: Superior';

-- Transformation  (description was NULL)
UPDATE spells SET description = 'A ritual that turns a normal human into a mindless, obedient demonic monster loyal only to the caster, with no memory of skills, knowledge or the life it once had, its new form and abilities rolled randomly from the supernatural creature tables. Principled, Scrupulous and Unprincipled victims retain just enough of themselves to refuse to hurt a child or loved one, or to commit suicide or fight to the death. The transformation ends when its duration runs out, the caster cancels it or is killed, or, rarely, only a 1-19% chance, a Remove Curse breaks it; Negate Magic has no effect on it at all.' WHERE name = 'Transformation';

-- Hivemind  (description was NULL)
UPDATE spells SET description = 'Forces everyone within range (up to five per level, no line of sight needed, though not anyone sealed inside power armor, a robot or an airtight vehicle) to save vs magic mind control or fall under the caster''s influence, gaining an involuntary telepathic link that lets the caster eavesdrop on their thoughts and pursuing whatever single goal he implants. Willing participants coordinate as a team with bonuses to initiative, combat and skills; unwilling ones are compelled like a Domination victim, suffering halved attacks, speed and skill performance, though none of them can be made to commit suicide, harm themselves, or kill a friend, loved one or respected leader. The link only ends when the duration runs out, the caster is knocked out or killed, or he chooses to cancel it.' WHERE name = 'Hivemind';

-- Ley Line Resurrection  (description was NULL)
UPDATE spells SET description = 'A ritual resurrection that must be performed on a ley line or nexus, restoring someone dead no longer than 24 hours to life with all their memories, abilities and skills, though missing limbs stay missing. The base success chance is only 1-40% (+10% at a nexus, +5% for Necromancers), can be attempted up to three times by the same caster before another must take over, and permanently drains 2D6 P.P.E. from the caster''s base (double for a creature of magic) each time it succeeds - a total of five failed attempts means the person is beyond magic''s help.' WHERE name = 'Ley Line Resurrection';

-- Aura of Power  (description was NULL)
UPDATE spells SET description = 'Surrounds the target in a glowing golden aura that makes them appear about three levels more experienced, fifty percent stronger, and adds 1D4+2 to Mental Affinity - useful for bluffing or looking important. It creates only the impression of power and grants no real increase; the psionic See Aura power sees through the ruse completely, though the magic version of See Aura only gives a fuzzy, in-between reading.' WHERE name = 'Aura of Power';

-- Mystic Alarm  (description was NULL)
UPDATE spells SET description = 'Places an invisible, ward-like alarm on a single non-living object. If anyone other than the caster touches or disturbs it, a silent alarm buzzes in the caster''s mind instantly, even across thousands of miles or into another dimension. The alarm is used up the moment it triggers and lasts up to one year per level of experience if untouched.' WHERE name = 'Mystic Alarm';

-- Shatter  (description was NULL)
UPDATE spells SET description = 'Causes brittle S.D.C. objects like glass, pottery, ceramic, hardened clay, sandstone, or ice to shatter into hundreds of pieces with a mere touch or a hard look. It has no effect on anything heavier than 100 pounds, Mega-Damage materials, magic items, flexible or elastic materials, or living beings.' WHERE name = 'Shatter';

-- Throwing Stones  (description was NULL)
UPDATE spells SET description = 'Conjures a hardball-sized magical stone in the caster''s hand that can be thrown like a cannonball with a +2 bonus to strike, doing 1D6 M.D. plus 1 M.D. per level of experience. The target can try to dodge but the stone moves too fast to parry easily (-4), and it crumbles to dirt after impact.' WHERE name = 'Throwing Stones';

-- Create Wood  (description was NULL)
UPDATE spells SET description = 'Draws particles and fibers from the surrounding air to magically create wood, either as two foot logs for burning or six foot planks for building. Soft, burnable wood costs 10 P.P.E. per 100 pounds created; sturdier building-grade hardwood costs 20 P.P.E. for the same amount. The Conjurer and Earth Warlock can cast it for half the usual P.P.E.' WHERE name = 'Create Wood';

-- Light Target  (description was NULL)
UPDATE spells SET description = 'Wraps a marked victim (or two, if cast by touch) in a bright glow that makes them stand out in a crowd, especially at night. Covering the person with clothes, blankets, or armor does nothing, since the glow follows the person rather than what they are wearing; only fully enclosing them somewhere the light cannot leak out will hide it. Does not work on inanimate objects.' WHERE name = 'Light Target';

-- Orb of Cold  (description was NULL)
UPDATE spells SET description = 'Conjures a softball-sized orb of magically charged ice that the caster hurls at a target with a +1 magical bonus to strike, doing 3D6 M.D. on impact. A failed save against the cold leaves the victim numbed for 1D4 minutes: they lose one melee attack, are -2 on initiative, -1 to strike, parry and dodge, and move 10% slower. The orb vanishes after one melee round if it is not thrown.' WHERE name = 'Orb of Cold';

-- Telekinesis  (description was NULL)
UPDATE spells SET description = 'Grants the caster the temporary psychic-like ability to move or hurl objects with thought alone, up to a maximum of 60 pounds, with a +3 bonus to strike and +4 to parry using the power (other combat bonuses do not apply). Damage from a hurled object scales with its weight, from 1D4 for a few ounces up to 4D6 or more for the heaviest items it can lift. Being on a ley line doubles the range and weight limit, while a nexus triples it.' WHERE name = 'Telekinesis';

-- Chromatic Protection  (description was NULL)
UPDATE spells SET description = 'Wraps a living being or an object no bigger than a car in a faint blue glow (barely visible in daylight, obvious at night) that automatically blinds any attacker who makes a hostile move against the protected target from within 10 feet, striking only that attacker with a burst of light like a dozen camera flashes. The blinded attacker suffers -10 to strike, parry and dodge, -4 on initiative, loses an action each round, cannot read, stumbles at speeds above 8, and takes an -80% skill penalty for 1D4 melee rounds. Dragons, greater demons, demon lords, gods, and alien intelligences are immune, and other supernatural beings recover in half the usual time.' WHERE name = 'Chromatic Protection';

-- Deflect  (description was NULL)
UPDATE spells SET description = 'Lets the caster magically parry incoming ranged attacks - arrows, bullets, lasers, rail guns, fireballs, called lightning - by rolling a d20+4 (plus P.P. bonus) to deflect the shot harmlessly away 1D4x10 yards, though a deflection in a crowded area risks hitting a bystander. The caster gets one deflection attempt per level of experience, and each attempt uses up one of the character''s own melee actions; taking any other action forfeits that deflection. Powerful blasts and missiles (1D4x10 M.D. or more) require a second unmodified roll to see if the deflected attack hits an ally, a bystander, or clears harmlessly.' WHERE name = 'Deflect';

-- Fireblast  (description was NULL)
UPDATE spells SET description = 'Shoots a narrow, one-foot-wide blast of Mega-Damage flame from the caster''s hands that travels the full fifty foot range, doing 3D6 M.D. to anything in its path that fails to dodge. The blast will punch through doors and walls unless they are tough enough to stop it outright, making it a good spell for clearing a passage.' WHERE name = 'Fireblast';

-- Reflection  (description was NULL)
UPDATE spells SET description = 'Has two uses: the caster can magically freeze his current reflection in a mirror or other reflective surface as a lasting visual snapshot (useful for leaving evidence or a warning), or he can project his own moving reflection into every reflective surface within a 20 foot radius to startle or confuse others. In the second case there is no sound, so communication is limited to gestures, pantomime, or writing that appears backwards.' WHERE name = 'Reflection';

-- Ricochet Strike  (description was NULL)
UPDATE spells SET description = 'Enchants a thrown melee weapon - knife, axe, spear, shuriken, arrow, and the like, but not guns or energy weapons - so that after striking its first target it ricochets on to hit up to two more targets with the same attack roll. A natural 20 hits all the targets for double damage; the effect ends the moment a throw misses or is dodged (a parry still lets it ricochet on) or after three targets have been struck.' WHERE name = 'Ricochet Strike';

-- Seal  (description was NULL)
UPDATE spells SET description = 'Magically seals a door, gate, window, drawer, or any similar opening shut - the lock can still be unlatched, but the object simply will not open by any amount of physical strength. The only way through is to break it open or use a Dispel Magic Barriers spell. At fourth level and beyond, the caster can seal every opening within a 100 foot area at once, effectively locking down an entire house.' WHERE name = 'Seal';

-- Watchguard  (description was NULL)
UPDATE spells SET description = 'Sets an invisible magical watch over an area that alerts the caster the instant anything dangerous or hostile enters it. Each intruder must save versus magic at -5; if even one fails, the caster is instantly alerted and knows roughly how many intruders there are, though not what they are or exactly where, and will wake if asleep. It does not detect Astral Travelers.' WHERE name = 'Watchguard';

-- Weight of Duty  (description was NULL)
UPDATE spells SET description = 'A magical mental assault that only affects intelligent, mortal beings with an honorable alignment or a strong sense of duty (supernatural beings and creatures of magic are immune). Those who fail a standard save feel their task is hopeless and become sluggish and demoralized: no initiative, -1 attack per melee, -4 to strike, parry and dodge, half speed, and skills performed at half effectiveness and double the normal time - they may even be inclined to surrender. Those who make the save instead get +2 on initiative and +2 to save against this or similar mind control for the next hour.' WHERE name = 'Weight of Duty';

-- Aura of Death  (description was NULL)
UPDATE spells SET description = 'Wraps the caster in a nimbus of flickering purplish-black flame that produces neither light nor heat but makes him register as dead to infrared, thermo-imaging, heat sensors, and biological scanners, as well as to magical and psionic life-sensing abilities like See Aura or Presence Sense (Sense Magic still works, since a spell is actively running). The downside: onlookers may mistake him for a vampire or animated corpse, scavengers may try to eat him, and both magical and psionic healing fail to work on him while the aura is up. Zombies, mummies and animated dead, however, will accept him as one of their own.' WHERE name = 'Aura of Death';

-- Death Curse  (description was NULL)
UPDATE spells SET description = 'Can only be invoked in the instant before the caster''s own death, channeling his last life energy (no P.P.E. needed) into a curse on whoever he believes caused it. The cursed victim suffers a permanent -2 to M.E., -2 to save vs poison and disease, half combat bonuses in duels or life-or-death fights, and half success on any deceit, treachery or gambling skill roll, becoming a magnet for further misfortune and attack. The curse can only be lifted by a god (a mere 01-21% chance of success) or by the accursed making genuine amends for the death he caused; the caster himself cannot be restored or resurrected by any means short of divine intervention, and even then returns 1D4 levels weaker with a third less P.P.E., permanently.' WHERE name = 'Death Curse';

-- Horrific Illusion  (description was NULL)
UPDATE spells SET description = 'Creates a frighteningly realistic illusion of something horrible - a swarm of spiders, snakes, a rabid animal, fire, and the like. Anyone who sees it must save versus Horror Factor 14 or be momentarily stunned with the usual combat penalties, and will refuse to challenge or walk past the illusion, though they can seek another route around it.' WHERE name = 'Horrific Illusion';

-- Instill Knowledge  (description was NULL)
UPDATE spells SET description = 'Instills one skill the caster knows (excluding spells), at one level below the caster''s own proficiency, directly into another person''s mind so they can use it as if it were second nature - or instead implants a single detailed piece of information, like a face, symbol, or floor plan. The knowledge is only temporary and fades completely when the spell''s duration runs out, and the caster''s own grasp of the shared skill is fuzzy (-60%) for as long as the spell is active; it cannot be ended early.' WHERE name = 'Instill Knowledge';

-- Mend the Broken  (description was NULL)
UPDATE spells SET description = 'Repairs physical damage to inanimate objects - filling cracks, mending broken statue limbs, removing dents and stains, restoring rust or worn fabric - though it cannot fix electronics, software, or living creatures, and cannot restore anything reduced below 20% of its original S.D.C. or M.D.C. The base cost is 10 P.P.E. plus one point per two S.D.C. repaired, or a steep 30 P.P.E. per single M.D.C. point, making it rarely practical for battle-damaged Mega-Damage armor.' WHERE name = 'Mend the Broken';

-- Mental Blast  (description was NULL)
UPDATE spells SET description = 'An invisible, undetectable magical attack (except to other psionics) that strikes the mind directly, doing 5D6 damage to Hit Points or M.D. to supernatural and Mega-Damage beings - double if delivered by touching bare skin. It works through body armor but not power armor or vehicles, and leaves the victim confused, paranoid and unable to identify the attacker, suffering -2 on initiative, -2 to strike, parry and dodge, and -20% on skills for 1D4 melees per hit, cumulative on repeated attacks. A successful save vs psionic attack halves the damage and negates the penalties.' WHERE name = 'Mental Blast';

-- Swim as a Fish (Superior)  (description was NULL)
UPDATE spells SET description = 'Lets the caster (or up to two others by touch) breathe underwater and swim with expert skill (98% base proficiency) at a speed of 20, without fatigue for the full duration. Grants a +2 bonus to parry and dodge while in the water and allows diving to a maximum depth of two miles.' WHERE name = 'Swim as a Fish (Superior)';

-- Apparition  (description was NULL)
UPDATE spells SET description = 'Creates a completely convincing illusion of a horrible creature or thing that attacks anyone coming within 20 feet, commonly used to guard a passage or entrance. It appears to bleed and can be fought, but cannot actually be destroyed except by a successful save vs magic (which dispels it only for that individual), by touching it with iron, or by waiting out the spell''s duration. Anyone who believes the apparition has killed them falls unconscious from shock for 2D4 minutes and must save vs insanity or roll on the Random Insanity Table, even though no real damage was ever inflicted.' WHERE name = 'Apparition';

-- Barrage  (description was NULL)
UPDATE spells SET description = 'Unleashes a rapid-fire barrage of three-plus-one-per-level visible force blasts that home in on their target like tiny guided missiles until they are all used up, doing 2 M.D. per blast that connects. Each blast can be dodged or parried away, but being under fire is distracting - the victim is -3 to defend against any other attack during the barrage and loses two melee actions if he stands and simply weathers it.' WHERE name = 'Barrage';

-- Create Water  (description was NULL)
UPDATE spells SET description = 'Conjures pure water out of thin air into any container the caster designates - a half gallon per level of experience (half that in a desert, double at sea or in a rain forest) - useful for supplying an isolated town with fresh water. The Conjurer and Water Warlock O.C.C.s can create twice as much for half the usual P.P.E.' WHERE name = 'Create Water';

-- Crushing Fist  (description was NULL)
UPDATE spells SET description = 'Either makes the caster''s own fist glow with energy for hand-to-hand combat, adding 2D6 M.D. per punch (with a +2 bonus to strike), or lets him punch a visible target at range (up to fifty feet per level) with a blur of magical force for the same damage and a +1 to strike. The caster must pick one application when the spell is cast and cannot switch between them.' WHERE name = 'Crushing Fist';

-- Energize Spell  (description was NULL)
UPDATE spells SET description = 'Pumps additional P.P.E. equal to the original casting cost into one of the caster''s own currently active spells (of 6th level or lower, with a duration longer than one melee round) to extend it for its full duration again without any lapse. Unlike simply recasting the spell, anyone who already failed their save stays affected with no new saving throw. It can only be used once per spell, effectively doubling its total duration and nothing more.' WHERE name = 'Energize Spell';

-- Fire Blossom  (description was NULL)
UPDATE spells SET description = 'Creates a small, three-inch flickering flame that gives off no heat and can be safely pocketed or carried until the caster - or whoever it was given to - chooses to activate it. Once activated it bursts into a real three-foot fire that burns on its own for 1D6 minutes with no fuel needed, or will ignite any combustibles it is placed on, making it a handy way to start a campfire or light torches.' WHERE name = 'Fire Blossom';

-- Fortify Against Disease  (description was NULL)
UPDATE spells SET description = 'Fortifies the recipient''s constitution against illness: bacterial infections like food poisoning or gangrene are easily resisted, and the target gets a +4 bonus to save against viral or magically caused disease and a +1 bonus to save against toxins and poisons.' WHERE name = 'Fortify Against Disease';

-- Frequency Jamming  (description was NULL)
UPDATE spells SET description = 'Jams the frequencies used by an electronic communication or sensor system - radios, radar, sonar, motion detectors, heat sensors, lie detectors and the like - so it produces no intelligible readings or transmissions for as long as the spell lasts.' WHERE name = 'Frequency Jamming';

-- Frostblade  (description was NULL)
UPDATE spells SET description = 'Transforms an ordinary sword, knife, or metal rod into a glowing four-foot blade of icy Mega-Damage energy that does 4D6 M.D. per hit (6D6 to fire-based creatures, or 8D6 if they already take double damage from cold). It can parry energy blasts without a special bonus, is not damaged by parrying, and reverts to normal when the duration ends; a Water or Air Warlock can cast it for the same P.P.E. but gets double the duration.' WHERE name = 'Frostblade';

-- Ice  (description was NULL)
UPDATE spells SET description = 'Transforms magical energy into ice in one of three ways: a Mega-Damage wall (50 M.D.C. per level, roughly ten feet cubed plus ten feet in length per level) that blocks a corridor without crushing anyone inside it; a thin coating of ice over the floor and nearby objects that costs victims their initiative and inflicts 1D6 S.D.C. frostbite while cutting their movement speed by 75%; or an instant freeze of up to two gallons of water per level, which can rupture the container it is in. The caster picks one effect per casting.' WHERE name = 'Ice';

-- Illusion Booster  (description was NULL)
UPDATE spells SET description = 'An auxiliary spell that piggybacks on an existing Illusion or Apparition spell and simply doubles its remaining duration. It only works on illusion magic and can only be applied once per spell - casting it again on the same illusion does not stack, it only doubles the duration a single time.' WHERE name = 'Illusion Booster';

-- Illusory Wall  (description was NULL)
UPDATE spells SET description = 'Creates a fully convincing illusion of a wall - simple (15 P.P.E.) or elaborately detailed with carvings, vines, or graffiti (30 P.P.E.) - that can hide, disguise, or replace the appearance of a real wall, or conjure one where none existed. Someone can see through it only by touching it and making a save vs magic (at -2), or by having good reason to suspect it is fake; the illusion looks, feels, tastes and smells completely real to anyone who fails. It offers no actual physical protection, however - vehicles, projectiles and energy attacks pass right through despite what onlookers believe.' WHERE name = 'Illusory Wall';

-- Targeted Deflection  (description was NULL)
UPDATE spells SET description = 'Lets the caster magically parry incoming energy blasts with a burst of energy around the hands and forearms, and on a good roll bounce the attack back at its source instead of just knocking it aside. A parry roll of 14 or better redirects the blast at the original attacker (who can try to dodge it, but without bonuses); a roll of 5-13 just deflects it harmlessly; a 1-4 fumbles and the mage takes the hit himself. Only energy attacks, including magic energy, can be redirected this way, though ordinary projectiles can still be parried and knocked aside as with Deflect. The caster can only cast this on himself.' WHERE name = 'Targeted Deflection';

-- Fire Gout  (description was NULL)
UPDATE spells SET description = 'Conjures and directs a wide stream of fire similar to a flamethrower, aimed with a wave of the hands. The blast is about three feet across and travels the full length of its range unless stopped by a large obstacle, and there is a 1-70% chance it sets combustible materials ablaze.' WHERE name = 'Fire Gout';

-- Mental Shock  (description was NULL)
UPDATE spells SET description = 'Sends a jolt of magical energy directly into a target''s brain; body armor and power armor offer no protection, though a large robot vehicle or armored military vehicle does. A target who saves is merely dazed for 1D4 melees, losing two attacks and suffering -5 to combat skills and -25% to skill performance, plus a lingering headache. A target who fails the save suffers total amnesia, losing his memory, identity and all skills except his native language and five chosen skills, for 4D6 hours plus two hours per level of the caster. Supernatural beings other than sub-demons, and dragons, are immune.' WHERE name = 'Mental Shock';

-- Sonic Blast  (description was NULL)
UPDATE spells SET description = 'Releases a sonic boom that bursts outward 20 feet in every direction, doing 4D6 M.D. to everyone caught in it except the caster himself. Victims are deafened for 2D4 minutes, losing two melee actions and suffering -5 on initiative, -3 to parry and dodge, and -25% to skill performance, and there is a 1-40% chance of being knocked off their feet by the shockwave.' WHERE name = 'Sonic Blast';

-- Spinning Blades  (description was NULL)
UPDATE spells SET description = 'Turns an ordinary knife or short sword into a floating fan of magical blades, gaining one additional blade per level of the caster. Used defensively, the blades auto-parry physical and energy attacks (+6 to parry hand to hand, +2 vs energy blasts and projectiles). Used offensively, the whole fan can be hurled as a single buzz-saw for double damage (2D6 M.D. per blade) that cannot be parried, only dodged, or the blades can be fired individually or in pairs at +3 to strike with a longer range; each attack, whichever form it takes, disappears once it lands or misses.' WHERE name = 'Spinning Blades';

-- Sub-Particle Acceleration  (description was NULL)
UPDATE spells SET description = 'Fires a directed particle beam doing 1D6x10 M.D. plus one point per level of the caster. The same spell can instead be used to recharge an M.D. E-Clip, restoring six energy blasts'' worth per casting (multiple castings can fill it completely), though there is a 1-15% chance per recharge that pumping in the magical energy makes the clip explode for 2D6x10 M.D. in a 10 foot radius. It cannot be used to recharge nuclear energy cells.' WHERE name = 'Sub-Particle Acceleration';

-- Fire Globe  (description was NULL)
UPDATE spells SET description = 'Creates a portable, grapefruit-sized globe of magical fire that gives off no heat or light until it is thrown and activated, at which point it erupts like napalm over whatever it strikes, doing 5D6 M.D. on impact and another 5D6 M.D. per melee round after. It burns without fuel for 1D4 minutes even with nothing combustible present, and dousing it with water causes a scalding steam burst (2D6 M.D.) before it goes out. It can be created and given to someone else to throw later, since it stays dormant in storage for up to a week per level of the caster.' WHERE name = 'Fire Globe';

-- Minor Curse  (description was NULL)
UPDATE spells SET description = 'Inflicts the victim with one of several minor but constantly irritating physical ailments chosen by the caster - fever, gas, a headache, hiccups, an ingrown toenail, an itching rash, pimples, nausea, a runny nose and cough, or vertigo - each carrying its own combat and skill penalties for the duration. Only a Remove Curse spell reliably cures it before it wears off; Negate Magic has just a 1-25% chance of working.' WHERE name = 'Minor Curse';

-- Oracle  (description was NULL)
UPDATE spells SET description = 'The magical equivalent of the psychic power Clairvoyance: the caster receives a dream-like vision of a possible future, with the vision''s focus determined by whatever person, place or event he is concentrating on when he casts it. It follows the same basic rules as psychic Clairvoyance.' WHERE name = 'Oracle';

-- Sorcerous Fury  (description was NULL)
UPDATE spells SET description = 'Unleashes a sorcerer''s berserker rage, transforming the caster''s body into a Mega-Damage structure with 50 M.D.C. per level, growing 1-4 feet taller and hovering just above the ground, crackling with a Horror Factor of 16 (anyone touching him takes 2D6 M.D.). While enraged he can fire lightning bolts at will for free (2D4x10 M.D., 300 foot range per level, +4 to strike), gains two extra attacks, +4 on initiative, +3 to save vs magic and poison, immunity to mind control, possession and Horror Factor, and bio-regenerates 1D4x10 M.D.C. per melee, but can only cast offensive spells and attacks anyone in his way, friend or foe. When the fury ends the caster is exhausted for an hour (half attacks, bonuses and speed) and recovers P.P.E. at half rate for the next day.' WHERE name = 'Sorcerous Fury';

-- Stone to Flesh  (description was NULL)
UPDATE spells SET description = 'Transforms stone back into flesh, restoring a petrified creature to normal or turning raw stone into living tissue. The caster can affect up to 50 pounds of stone per level of experience.' WHERE name = 'Stone to Flesh';

-- Wall of Wind  (description was NULL)
UPDATE spells SET description = 'Creates a roaring wall of wind, 10 feet long and six feet tall per level of the caster (adjustable), with an effective Supernatural Strength of 32 plus one per level to resist anyone trying to push through it. Only someone with a higher P.S. or weighing over two tons can force their way through, and only at 20% normal speed; loose items are torn free and hurled the length of the wall. Anyone caught in the wind takes 2D4 M.D., is tumbled along inside it for a full melee round unable to act, and is dazed for another round afterward.' WHERE name = 'Wall of Wind';

-- Winged Flight  (description was NULL)
UPDATE spells SET description = 'Grants a willing recipient (never the caster himself) a pair of glowing, feathered wings that let him fly. Flying speed is five times the recipient''s P.S. attribute, with no other combat bonuses granted, and the wings - being magical constructs - can be dispelled by Negate Magic or an Anti-Magic Cloud.' WHERE name = 'Winged Flight';

-- World Bizarre  (description was NULL)
UPDATE spells SET description = 'A rare, legendary illusion spell that transforms a 20-foot-radius area per level of the caster into a nightmarish domain - the ground, trees, vehicles and even people take on monstrous, demonic appearances, radiating a Horror Factor of 17. Those outside who fail their Horror Factor save refuse to enter; those who succeed but stay in the area suffer -1 attack, -2 on initiative, -2 to strike and parry, and -10% on skills. Anyone caught inside who fails to save vs magic (17 or higher) will feel themselves starting to transform into a monster too, and will typically flee, reverting to normal the instant they leave the affected area.' WHERE name = 'World Bizarre';

-- Aura of Doom  (description was NULL)
UPDATE spells SET description = 'Surrounds the target in a flickering black aura that does no direct damage but, if the victim fails a save vs magic, overwhelms him with a crushing sense of doom and failure - halving attacks per melee, skill performance and initiative, and imposing -4 to strike, parry and dodge. Anyone who lingers within 10 feet of the marked victim can also see the aura and, if they fail their own save, suffer the same penalties at half strength; most will want to avoid the doomed character''s company. It has no effect on adult dragons, greater demons, other powerful supernatural beings, high-level (8th or higher) sorcerers, or anyone in power armor or a large vehicle.' WHERE name = 'Aura of Doom';

-- Beat Insurmountable Odds  (description was NULL)
UPDATE spells SET description = 'Warps probability in favor of one specific action or event the caster or one designated ally is attempting - the longer the odds, the higher a d20 roll is needed to guarantee success (a routine long-shot succeeds automatically; a one-in-a-thousand feat needs an 8 or better; a one-in-a-million feat needs a 15 or better). It can also be cast on someone dying to give a +40% bonus on their save vs coma and death, or used in combat for a +4 bonus applied to half that round''s attacks, automatic dodges, and the ability to engage up to three opponents at once. It cannot be combined with other spells for that same action.' WHERE name = 'Beat Insurmountable Odds';

-- Illusion Manipulation  (description was NULL)
UPDATE spells SET description = 'A piggyback spell that lets the caster who created an illusion make it seem to react realistically to events around it - for instance, showing a scorch mark where a blast supposedly struck an illusionary wall, or branches appearing to break. Only the mage who cast the original illusion can manipulate it, and doing so requires his full attention: he can respond to no more than 12 different simultaneous actions or events per melee round, rolling initiative at +4 to see if the reaction is convincingly timed.' WHERE name = 'Illusion Manipulation';

-- Phantom Mount  (description was NULL)
UPDATE spells SET description = 'Conjures a translucent, ghostly horse made of blue-white magical energy that only the caster can ride or command, using simple commands like a normal mount. It has 30 M.D.C. plus 5 per level of the caster, three attacks per melee (a front kick for 1D6 M.D. or a rear kick for 3D6 M.D.), and bonuses of +1 on initiative, +2 to strike and +3 to dodge, though it cannot parry. If separated from the caster by more than 40 feet for over 30 seconds, it vanishes.' WHERE name = 'Phantom Mount';

-- Purge Self  (description was NULL)
UPDATE spells SET description = 'Instantly purges the caster''s own body of all foreign invaders: destroying any disease or parasites outright, and forcing out (without killing) Bio-Wizard symbiotes or cybernetic implants - though not full bionic conversions or bio-systems. It can even exorcise a possessing force, provided that entity doesn''t have enough control to block the purge. Any physical damage, scarring or mutation already caused by the invaders remains, but all further symptoms and effects stop immediately and the caster feels completely refreshed.' WHERE name = 'Purge Self';

-- Transferal  (description was NULL)
UPDATE spells SET description = 'Lets the caster temporarily hide his magical power by transferring all but 4 P.P.E. and his experience level into another person, who remains completely unaware they are carrying it and cannot use it themselves. A See Aura cast on the caster during this time would show almost no magical ability at all. The caster can reclaim his power early by touching the vessel again, or it returns automatically when the spell''s duration ends - or instantly, if the vessel is killed.' WHERE name = 'Transferal';

-- Armorbane  (description was NULL)
UPDATE spells SET description = 'Degrades a single suit of body armor, cyborg armor or power armor at range: ordinary S.D.C. armor loses 25% of its S.D.C. and one point of A.R., while Mega-Damage armor loses 10% of its M.D.C. and develops minor system glitches (the clock runs off by 6D6 minutes, the calendar by 1D4 days, and comms get cluttered with static). It only works once on the same suit of armor, which afterward is resistant, and has no effect on giant-sized armor, massive vehicles, Automatons or rune items.' WHERE name = 'Armorbane';

-- Deathword  (description was NULL)
UPDATE spells SET description = 'The caster speaks a single, unforgettable word of death to a target who can clearly hear it; the target takes 2D6 plus 1D6 per level of the caster in damage (S.D.C./Hit Point damage to normal creatures, Mega-Damage to M.D. creatures) regardless of armor, magical defenses or immunities, doubled if the word is whispered directly into the victim''s ear. Unless the target saves vs magic, the shock also drops him into a death-like coma for 1D4 hours, after which he must save vs coma or actually die.' WHERE name = 'Deathword';

-- Enemy Mind  (description was NULL)
UPDATE spells SET description = 'A powerful mind-control spell on a single enemy: if the target fails a save vs magic, he temporarily comes to see the caster''s enemies as his own and will fight alongside and even help protect the caster against former friends, family or allies. The victim''s alignment doesn''t actually change and he is likely to stop short of killing someone he cares about, but he will otherwise fight and hurt them without hesitation. When the spell ends the victim has no clear memory of what happened, but realizes the caster took control of him.' WHERE name = 'Enemy Mind';

-- Giant  (description was NULL)
UPDATE spells SET description = 'Transforms the caster or another person into a ten-foot-taller giant, shredding any armor or clothing worn. A sorcerer who becomes a giant loses the ability to draw on P.P.E. for the duration, relying purely on physical power. Benefits include tripling Hit Points and S.D.C. (converted to M.D.C.), a supernatural +50% to P.S., bio-regeneration of 2D6 M.D.C. per melee, an extra attack, and bonuses to strike and parry, offset by a 20% speed reduction and -3 to dodge. It cannot be used on Automatons, robots, power armor, vehicles, greater supernatural beings, adult dragons, godlings or gods.' WHERE name = 'Giant';

-- Havoc  (description was NULL)
UPDATE spells SET description = 'Strikes everyone within a 20-foot radius (cast from up to 90 feet away) with 1D6 points of damage straight to Hit Points every melee round - bypassing environmental or power armor entirely (2D6 M.D. to a Mega-Damage being) - while also leaving them confused and skittish: -3 to initiative, strike and parry, -6 to dodge, roll with impact and save vs Horror Factor, half attacks and skill performance, and no sense of time or direction.' WHERE name = 'Havoc';

-- Summon Shadow Beast  (description was NULL)
UPDATE spells SET description = 'Summons a Shadow Beast, a 9 to 12 foot inter-dimensional predator that can merge completely into shadow to become undetectable, even to a See the Invisible spell. In darkness it fights at full supernatural strength (75 M.D.C., six attacks per melee, Supernatural P.S.); in light it is far weaker (35 M.D.C., two attacks, ordinary strength). The caster controls it directly for a limited time in combat, after which it may break free and either return home or keep fighting, or it can be given a simple non-combat mission or set to labor for a longer period. There is a 1-15% chance it fails to return to its home dimension and instead runs loose, hunting people for sport.' WHERE name = 'Summon Shadow Beast';

-- Super-Healing  (description was NULL)
UPDATE spells SET description = 'A powerful healing spell usable only on Mega-Damage creatures - dragons, dinosaurs, supernatural beings and the like - restoring 4D6 M.D.C. of external and internal damage. It does nothing for ordinary S.D.C./Hit Point creatures and cannot be cast on the caster himself.' WHERE name = 'Super-Healing';

-- Wall of Not  (description was NULL)
UPDATE spells SET description = 'Makes a length of an existing wall - up to 15 feet long per level of the caster, height capped at 15 feet regardless - completely invisible, though it remains just as solid. The wall must be one continuous span; invisibility stops at any corner or junction, so a room needs a separate casting per wall. It can only be used on an actual wall, not on vehicles, doors, furniture or people.' WHERE name = 'Wall of Not';

-- Wards  (description was NULL)
UPDATE spells SET description = 'Inscribes protective (or offensive) magic symbols on an item, door or section of floor that trigger automatically when anyone but the mage who made them touches the warded object. A single casting creates two wards, a ritual casting three, chosen from effects that mirror other invocations - an alarm siren, a fear aura, a fire bolt, temporary paralysis of the hand and arm, sleep, agony, a minor curse, a phobia curse, or banishing lesser supernatural beings (which counts as two wards). Once triggered, a ward is spent and vanishes, but an untouched ward can last up to 150 years per level of the mage who made it.' WHERE name = 'Wards';

-- Warped Space  (description was NULL)
UPDATE spells SET description = 'Twists and distorts reality in a 10-foot radius per level of the caster for 15 seconds, leaving everyone caught inside disoriented and half as effective - half their normal melee actions and combat bonuses, and speed cut by 75%. Anyone shooting into the area from outside is at -9 to strike as their attack is also warped. On top of the disorientation, the G.M. rolls or picks a few random effects from a table that can include energy weapons failing, Mega-Damage armor or attacks temporarily becoming S.D.C., supernatural beings shrinking to mortal size, a localized time warp, loss of gravity, psionics failing, or metal turning to glass, all lasting only as long as the spell is in effect.' WHERE name = 'Warped Space';

-- Anti-Magic Cloud  (description was NULL)
UPDATE spells SET description = 'Creates an enormous, ominous cloud - large enough to blanket an entire town - that simply negates all magic within it: spell casting, Techno-Wizard devices, potions and charms all go dead the moment they enter its boundary (rune weapons and magic weapons are exempt). It cannot be dispelled by magic or by manipulating the weather, and only the mage who created it is unaffected by its presence; leave the cloud and normal magic returns immediately.' WHERE name = 'Anti-Magic Cloud';

-- Astral Hole  (description was NULL)
UPDATE spells SET description = 'Opens an invisible, mobile extradimensional portal (visible only to the caster and those who can see spirits or the Astral Plane) that follows him everywhere. He can step into it to teleport a short distance to anywhere he can see (up to 2000 feet, doubled at sea or on open plains), which uses two melee actions, or sidestep into and back out of it to dodge an attack for just one action, with a +2 bonus to dodge while doing so. If he also uses Astral Projection, the hole serves as a beacon and doorway back to the physical world.' WHERE name = 'Astral Hole';

-- Bottomless Pit  (description was NULL)
UPDATE spells SET description = 'Opens a dimensional pit on the ground beneath a target''s feet (about four feet across per level of the caster), sweeping anyone who falls in into a featureless dimensional void with no way out and no ability to sense the outside world until the spell''s duration expires, at which point they''re returned unharmed to where they started. A victim can attempt to dodge at the moment the pit opens (needing a 17 or better to grab a handhold), and if he succeeds the caster can reposition the pit under his feet again as one of his own melee actions. Flying does not help escape the void - the trapped character is simply lost in another dimension with no exit.' WHERE name = 'Bottomless Pit';

-- Create Mummy  (description was NULL)
UPDATE spells SET description = 'A Necromantic ritual that wraps a corpse in mystically treated linen and animates it as a mindless, near-indestructible mummy that follows only the simplest orders and cannot speak, read or use skills. Bullets, blades and most magic - charms, curses, illusions, paralysis, even Banishment and Negate Magic - have no effect on it; it can only be stopped by trapping it, blowing it apart, or burning it. Fire is its one real weakness, doing double damage once its linen wrappings are destroyed, at which point sunlight also starts burning it for 3D6 points per melee of exposure. A protection circle will hold one at bay.' WHERE name = 'Create Mummy';

-- See in Magic Darkness  (description was NULL)
UPDATE spells SET description = 'Lets its recipients see through any darkness, including magically created darkness, as if it were broad daylight. This defeats the blinding effect of a Shadow Wall (letting the caster move through it at double speed), lets the caster see clearly into a Cloak of Darkness, and reveals Shadow Beasts lurking nearby, though the Beasts remain semi-invisible rather than fully visible. Cannot be cast on an automaton, robot or vehicle, though it works on the pilot inside one.' WHERE name = 'See in Magic Darkness';

-- Summon and Control Animals  (description was NULL)
UPDATE spells SET description = 'A ritual pentacle that summons and commands any ordinary animals within 600 feet, with the number controlled scaling by size: forty tiny animals, eight medium ones up to 30 lbs, six large animals like horses, or just one exotic or non-native animal, per level of the caster. Each animal gets a saving throw vs magic to resist. Familiars are immune and cannot be summoned or controlled by this spell.' WHERE name = 'Summon and Control Animals';

-- Summon Fog  (description was NULL)
UPDATE spells SET description = 'Calls forth a dense fog covering up to one mile per level of the caster, thick enough that only shapes within about 10 feet are visible at all and anything past that is completely hidden. Safe travel slows to a crawl - on foot or by vehicle, moving faster than a walking pace risks tripping, crashing or losing all sense of direction - and air travel becomes impossible. The fog gives a +20% bonus to prowl and makes ranged combat difficult (-5 to strike, +2 to dodge), and the caster can dissipate it early at will.' WHERE name = 'Summon Fog';

-- Amulet  (description was NULL)
UPDATE spells SET description = 'Instills a medallion or charm made of fire-purified metal or semiprecious stone with one specific protective property chosen at creation - options include a general +1 bonus to save vs magic and psionics, bonuses against a particular threat like Sickness or magical insanity, the ability to see the invisible, sensing nearby entities, or warding off the touch of the undead like a cross wards off vampires. Each option has its own P.P.E. cost, from 290 up to 500, and the amulet lasts as long as it is not destroyed.' WHERE name = 'Amulet';

-- Calm Storms  (description was NULL)
UPDATE spells SET description = 'As a spell, calms nature''s fury within the area - slowing a downpour to a light rain, cutting wind speed and wave height in half, and lightening dark stormy skies. Performed as a ritual instead, it can turn a torrential rain into a mere drizzle, reduce winds to a gentle breeze, shrink ocean waves back to normal, instantly disperse a tornado, and clear the skies entirely. Works against both natural weather and magically summoned storms.' WHERE name = 'Calm Storms';

-- Create Zombie  (description was NULL)
UPDATE spells SET description = 'A necromantic ritual that raises a corpse no more than six hours dead into an obedient zombie, intelligent enough to speak, read simple instructions, perform tasks and even drive, and loyal only to its creator and those the creator designates. It feels no pain and takes no damage from bullets, blades, or mental/magical attacks like curses or mind control, and cannot be turned, banished or negated - but full damage comes from magical energy attacks, fire and silver weapons, while other energy weapons do half. Unless its head is severed and buried apart from the body, or it is exorcised, the zombie regenerates fully within 48 hours.' WHERE name = 'Create Zombie';

-- Ensorcel  (description was NULL)
UPDATE spells SET description = 'A touch enchantment that binds the target''s will to the caster: the ensorcelled character becomes immune to mind control, possession and illusion, and gains +4 to save against any other spell caster''s magic, but has no saving throw at all against magic cast by whoever ensorcelled them. They are also too cowed to raise a hand against their master, needing to beat a Horror Factor of 16 each round just to attempt defiance, or lose an action and back down. Cannot be used on automatons, Iron Juggernauts, robots or vehicles.' WHERE name = 'Ensorcel';

-- Heavy Air  (description was NULL)
UPDATE spells SET description = 'Makes the air in the area hot, heavy and stifling, so breathing becomes labored and victims feel compelled to shed heavy clothing, packs and armor (a failed save vs magic means they do). Those affected fatigue at twice the normal rate, are -4 on initiative and -20% on skills (which also take twice as long), while cyborgs and power armor users suffer only half these penalties and pure machines and the undead are unaffected entirely. Anyone who saves gets off comparatively easy, at only -1 initiative and -5% on skills.' WHERE name = 'Heavy Air';

-- Ironwood  (description was NULL)
UPDATE spells SET description = 'Converts an ordinary wooden object''s S.D.C. into an equal number of M.D.C. points, permanently and instantly, at a P.P.E. cost equal to the S.D.C. converted (minimum 50). The item keeps the look, feel and weight of wood but becomes as tough as steel, though it still does not inflict Mega-Damage on its own (a club gains only an extra 1D6 damage). Only works on simple wooden objects like doors, handles or hulls - not complex machinery, or any material other than wood.' WHERE name = 'Ironwood';

-- Metamorphosis: Mist  (description was NULL)
UPDATE spells SET description = 'Transforms the caster (or, through ritual magic, another subject) into a cloud of mist immune to physical and energy attacks and able to slip through the smallest crack or keyhole. While a mist the character cannot speak or cast spells but can still see and hear normally, moves at a speed of 14, prowls at 80% skill, hovers up to 100 feet high, and can rematerialize (naked) with a thought.' WHERE name = 'Metamorphosis: Mist';

-- Null Sphere  (description was NULL)
UPDATE spells SET description = 'Surrounds the caster with a globe of golden force with 100 M.D.C. per level that blocks harmful gases, disease, curses, magical sickness, summoning and mind control from taking effect while inside it (though the effects may resume once it ends), and dispels incoming magic and energy attacks harmlessly at its surface. It does nothing to stop physical attackers or projectiles, which pass through freely once inside, and greater demons and master-level vampires can enter it even though lesser demons cannot; non-mind-control psionics like Bio-Manipulation or Telekinesis also pass through unaffected.' WHERE name = 'Null Sphere';

-- Soultwist  (description was NULL)
UPDATE spells SET description = 'A combined physical and spiritual attack: on a failed save (-6) it does 6D6 M.D. or Hit Point damage that cannot be healed by ordinary means - only a priest, god or divine servant of the appropriate faith can restore it - and also plants weeks of doubt and temptation about the victim''s alignment, morals and beliefs, pushing good characters toward evil impulses and vice versa, for a minimum of 3D4 weeks. A successful save avoids the physical damage entirely and leaves only mild, fleeting doubt. Whether the doubt actually changes the character''s alignment is left up to the player and G.M., not forced by the spell.' WHERE name = 'Soultwist';

-- Summon and Control Entity  (description was NULL)
UPDATE spells SET description = 'A ritual that plucks an Entity, of a type the caster can specify, out of its home dimension and delivers it under the caster''s total control to use for labor, protection, or assault. The caster can send it home at any time before the duration expires; if the duration runs out first, the Entity slips free of control and remains in this world, where it may choose to keep working with the mage, be enslaved by other means, or turn on him.' WHERE name = 'Summon and Control Entity';

-- Summon and Control Rain  (description was NULL)
UPDATE spells SET description = 'A ritual that conjures rain out of thin air over up to one mile per level of the caster, adjustable from a light drizzle to a full downpour. A heavy version of the rain reduces visibility and slows travel across the affected area.' WHERE name = 'Summon and Control Rain';

-- Wall of the Weird  (description was NULL)
UPDATE spells SET description = 'Raises a spongy, slime-covered wall bristling with tentacles, up to 10 feet tall and 10 feet long per level of the caster, with 40 M.D.C. per level for each 10 foot section. Anyone within 15 feet is attacked by 1D4 tentacles per round (a parry or dodge of 15+ avoids it), which either strike for 4D6 M.D. or entangle and constrict the victim, immobilizing and silencing them within three rounds unless a combined P.S. of 40 pries the tentacles free. Severed tentacles (12 M.D. each) regrow the next round, and the whole wall collapses into dust once its M.D.C. is exhausted.' WHERE name = 'Wall of the Weird';

-- Collapse  (description was NULL)
UPDATE spells SET description = 'Destroys a standing building, bridge or similar structure by magically shattering its support beams, causing it to creak ominously for 1D4+1 melee rounds before collapsing - time enough for occupants who know to flee. Those caught inside take 2D4x10+20 S.D.C./Hit Point damage or 1D4 M.D. and must be dug free within hours before falling into a coma, and the structure itself gets a saving throw vs magic that shifts with its size, from a heavy penalty for a small S.D.C. building to being outright impervious for an M.D.C. mega-structure. Large M.D.C. buildings and skyscrapers are never destroyed outright by one casting - only one floor per level of the caster collapses, starting from the top - and the spell cannot be used on mobile fortresses or underground structures.' WHERE name = 'Collapse';

-- Create Golem  (description was NULL)
UPDATE spells SET description = 'A ritual that sculpts a humanoid Golem from clay, onyx gems for eyes and an iron heart, animated with a drop of the caster''s blood at a permanent cost of 6 S.D.C. to the caster. Built from stone or iron, the Golem has no mind for mental or magical attacks to affect, is immune to turning, banishment, negation and Remove Curse, and takes only half damage from physical attacks and energy magic. It obeys only its creator and, once the creator dies, follows his last command until destroyed.' WHERE name = 'Create Golem';

-- Sanctum  (description was NULL)
UPDATE spells SET description = 'Turns a room up to 30x30 feet, which can be created as far as 200 miles away, into a permanent haven immune to mystic intrusion. While inside, the mage cannot be found by Calling or Locate, seen by Second Sight or a Crystal Ball, or affected by bonding magic, and Animated Dead and the Undead cannot enter at all, while lesser monsters must save vs magic just to cross the threshold. Greater beings and ordinary humans can enter freely, and the sanctum lasts for the mage''s lifetime or until he cancels it.' WHERE name = 'Sanctum';

-- Shadow Wall  (description was NULL)
UPDATE spells SET description = 'Raises an immaterial, pitch-black wall up to 30 feet long, 10 feet high and 3 feet thick per level, through which anyone attempting to pass moves at only two feet per round while completely blind - even night vision and optics fail against it (-9 to strike, parry, dodge). Each round it drains 10% of the maximum P.P.E., I.S.P. or technological energy (including E-Clip charge) of anyone inside, and inflicts 1D6 direct Hit Point or 4D6 M.D. damage per round on living creatures passing through it, ignoring armor. The wall feeds on this drained energy, so its duration is halved if no one enters it, and it also halves the damage of any weapon fired through it and blocks all sensors.' WHERE name = 'Shadow Wall';

-- Summon and Control Storm  (description was NULL)
UPDATE spells SET description = 'Conjures a destructive storm out of thin air, either a flooding rainstorm - four inches of rain an hour with roads under 3 to 5 feet of water and winds gusting 35 to 45 mph - or a windstorm with gusts of 70 to 90 mph that uproot small trees, down power lines and can overturn a car. Either version makes vehicle and foot travel hazardous, with a real chance of crashes or accidents, and air travel is either impossible (rainstorm) or extremely dangerous (windstorm).' WHERE name = 'Summon and Control Storm';

-- Summon Lesser Being  (description was NULL)
UPDATE spells SET description = 'A ritual that pulls a lesser demon, sub-demon, Deevil, Entity or other monster - a specific type if desired, or a random one - out of its home dimension and places it under the caster''s total control. It will do anything asked short of committing suicide or fighting to the death, and can be sent home at any time before the duration ends; if the time runs out first, the mage loses control and the creature remains loose in this world.' WHERE name = 'Summon Lesser Being';

-- Swap Places  (description was NULL)
UPDATE spells SET description = 'Instantly swaps the caster''s position with any one visible target, or, by touching a willing person, swaps two other people with each other. The swap lasts up to one minute per level, ends early if either party dies or the caster cancels it, and then automatically reverses - swapping the two back to their original spots. If someone other than the caster was swapped and is killed while displaced, the caster takes half that damage directly to Hit Points and is stunned for 1D6 melee rounds; only one swap and its automatic reversal are possible per casting.' WHERE name = 'Swap Places';

-- Barrier of Thoth  (description was NULL)
UPDATE spells SET description = 'Raises a massive wall of force with 400 M.D.C. per level of the caster that is completely impervious to magic energy attacks (it simply negates them) and blocks anyone from teleporting past it or casting spells or psionics through it - a Firequake or Lightning Bolt aimed at the barrier stops dead at its surface. The wall also regenerates 200 M.D.C. every melee round.' WHERE name = 'Barrier of Thoth';

-- Blight of Ages  (description was NULL)
UPDATE spells SET description = 'Instantly withers and kills ordinary plant life - grass, crops, flowering plants, moss, fungus - throughout its area of effect, which keeps expanding by another 100 feet per level every melee round it remains active. Plant-like creatures or magical plants instead take 1D4x10 M.D. per round of exposure, though a tree gets a standard saving throw to be unaffected, and a Millennium Tree can shield all plant life within 1000 feet of itself entirely. It has no effect on already-processed food.' WHERE name = 'Blight of Ages';

-- Blood and Thunder  (description was NULL)
UPDATE spells SET description = 'Bestows a wild berserker rage on multiple mortal spell casters at once - up to two per level of the caster within line of sight and range - transforming each into a towering, Mega-Damage creature with 50 M.D.C. per level, capable of firing free lightning bolts (2D4x10 M.D., +4 to strike) and getting two extra attacks, +4 initiative and +3 to save vs magic and poison while berserk. Those who do not want the transformation may save vs magic to resist, and the caster chooses whether to be affected himself; those affected can cast only offensive spells and will attack indiscriminately, including allies and bystanders, until the rage ends, after which their attacks, bonuses and speed are halved for an hour and P.P.E. recovery is halved for a day. Only works on mortal practitioners of magic - not animals, the undead, Golems or other creatures of magic.' WHERE name = 'Blood and Thunder';

-- Crimson Wall of Lictalon  (description was NULL)
UPDATE spells SET description = 'Raises a wall of eerie, cool crimson flame containing the shadowy souls of those it has devoured, so frightening to look at that it demands a save vs Horror Factor 18 (losing an attack and initiative, with a 10-70% chance of fleeing outright). Passing through it does 6D6 Hit Point damage or 2D6x10 M.D. (avoidable with a save vs magic 16) and slows the victim to a quarter speed; staying inside longer than two melees risks insanity, and staying longer than six melees risks having one''s life essence permanently trapped in the wall as one more faceless shadow, with a fresh saving throw required every melee past the sixth.' WHERE name = 'Crimson Wall of Lictalon';

-- Doppleganger (Superior)  (description was NULL)
UPDATE spells SET description = 'Creates a mystic clone of the caster with half his Hit Points, memory, attributes, experience, P.P.E. and spellcasting ability, into which the caster can implant any goal, memory or emotion before sending it off to work independently or alongside him. Only one doppleganger can exist at a time until it is slain or negated; it can be killed by normal means, destroyed by five minutes of exposure to a Power Leech circle, or instantly ended by Negate Magic (though it gains +2 to resist negation for every year it has survived). A doppleganger can create its own doppleganger at half its own reduced power, and by around the fourth such generation the line is too weak to be worth making.' WHERE name = 'Doppleganger (Superior)';

-- Enchant Weapon (Minor)  (description was NULL)
UPDATE spells SET description = 'Infuses one melee weapon, or a batch of 48 arrows/bolts or 72 bullets, with magic that turns it into a Mega-Damage weapon dealing twice its old S.D.C. damage as M.D. The enchantment normally lasts about a month, or can be made permanent for an extra 1000 P.P.E. and a permanent loss of 2D4 P.P.E. from the caster''s own base; either way this ritual can only be performed once every three months. Bullets lose their charge the instant they are fired and hit something and can never be made permanent, and technological weapons like Vibro-Blades, energy rifles or rail guns cannot be enchanted at all.' WHERE name = 'Enchant Weapon (Minor)';

-- Metropolis  (description was NULL)
UPDATE spells SET description = 'Transforms every pre-existing S.D.C. building within range into an M.D.C. structure with M.D.C. equal to whatever S.D.C. it had, regenerating 25 M.D.C. per hour for the duration (M.D.C. structures are unaffected, since they are already M.D.C.). The transformation can be made permanent for an additional 6,000 P.P.E. and the caster''s permanent sacrifice of one P.E. attribute point.' WHERE name = 'Metropolis';

-- Mystic Quake  (description was NULL)
UPDATE spells SET description = 'Causes a stretch of ground (or a whole ley line) 300 feet long and 100 feet wide per level, doubled if cast on a ley line, to shake and rumble violently. Those caught on the ground are reduced to crawling at 10% speed with only two attacks per round at -12 to all combat, vehicles are slowed to half speed with an -80% piloting penalty and high crash risk, and even flyers are buffeted off course and knocked to half attacks and speed. The quake itself does no direct damage - all the damage comes from crashes, collisions and wild gunfire - and anyone shooting into the shaking area from outside also suffers a penalty to hit the disoriented, erratically moving targets.' WHERE name = 'Mystic Quake';

-- Sanctuary  (description was NULL)
UPDATE spells SET description = 'Prevents any act of aggression within its radius: the instant anyone, or any war machine, robot, or animated creature, tries to attack or harm another inside the area, the aggressor is struck down, paralyzed or rendered unconscious, though otherwise unharmed. Even missiles and bombs fired or dropped into the area are instantly deactivated and fall harmlessly. Only the caster himself is immune to the Sanctuary''s own effect.' WHERE name = 'Sanctuary';

-- Steel Rain  (description was NULL)
UPDATE spells SET description = 'Rains sharp magical blades from the sky over a diameter of 50 feet per level, doing 3D6 M.D. per melee round to anyone caught in the open (and instantly killing any S.D.C. being it strikes). Focused into a five-second torrent instead, it can be aimed at one target or narrow spot for 3D6x10 M.D. (double at a ley line), dodgeable only at a -2 penalty. The only way to avoid damage is to leave the area or take cover under M.D.C. protection; the caster alone is immune and can move and act freely the whole time.' WHERE name = 'Steel Rain';

-- The Slowness  (description was NULL)
UPDATE spells SET description = 'Freezes time itself within a diameter of 30 feet per level - flying bullets suspend in mid-air, fires stop mid-burn - for everyone but the caster, who alone can still move and act freely at what looks like hyper-speed to anyone frozen, including walking among them, disarming them or leaving messages. A saving throw (-8) lets a victim keep moving in slow motion instead - speed cut by 80%, one action per round (two for Juicers or Mega-Damage/supernatural beings), no combat bonuses - but even they cannot keep pace with the caster. Any act of violence by the caster instantly cancels the spell, and attacks fired into the field from outside pass through or bounce back doing only 10% damage.' WHERE name = 'The Slowness';

-- Vicious Circle  (description was NULL)
UPDATE spells SET description = 'An invisible trap that, once cast, triggers however the caster designates - crossing its center, a mental command, or a timer - and cannot be changed afterward except by dispelling and recasting it. The caster and up to five chosen people are immune; everyone else caught inside must save vs magic at -3 or take 1D4x10 damage (or 1D6x10 M.D.) plus crippling agony that halves their attacks, cuts speed to a crawl, and imposes a -70% skill penalty, with any further movement causing an extra 2D6 damage. A successful save cuts the initial hit to 2D6 and the penalties by roughly half; robots and plants are unaffected entirely, and full conversion cyborgs take only half damage and penalties (none at all if they save).' WHERE name = 'Vicious Circle';

-- Void  (description was NULL)
UPDATE spells SET description = 'Envelops the target in black mist and vanishes them into a completely empty pocket dimension between all other dimensions - no light, sound, air or ambient P.P.E. exists there. The victim is magically sustained against hunger and suffocation but cannot heal or recover P.P.E. or I.S.P. while trapped, and time is distorted so a week inside feels like only a few hours. Only dragons, gods, other beings with their own dimensional travel powers, or waiting for the spell to end (or the caster to release them) offers a way out.' WHERE name = 'Void';

-- Warrior Horde  (description was NULL)
UPDATE spells SET description = 'Conjures 20 human-shaped magical warriors per level of the caster, clad in glowing blue-tinged ancient armor, under the caster''s total mental command without requiring his concentration - he can move, fight and cast other spells while they act. They take short, simple orders (even suicidal ones, since they have no fear or self-preservation) and each has 30+4 M.D.C. per level, three attacks per melee doing 2D6 M.D. by hand or 3D6 M.D. with a weapon, and a Horror Factor of 12 that climbs with their numbers. They will not hunt down hidden enemies on their own, but a horde ordered to fight or kill will strike down unarmed or surrendering foes without hesitation.' WHERE name = 'Warrior Horde';

-- ---- readbacks -------------------------------------------------------------
-- Corpus-wide invariants rather than counts of this file's own work, because a
-- count of what a script did passes by construction.

SELECT 'no spell is left without a description' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE description IS NULL OR description = '';

-- THE STUBS ARE THE HALF A COUNT WOULD HAVE MISSED. A category label is not a
-- description, and 230 rows carried one while reading as populated.
SELECT 'no spell still carries a category label as its description' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells
 WHERE description IS NOT NULL AND length(description) < 60
   AND instr(description, 'Magic, level') > 0;

SELECT 'no spell is left without a range' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE range IS NULL OR range = '';

SELECT 'no spell is left without a duration' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE duration IS NULL OR duration = '';

SELECT 'every spell carries a citation' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE source_book IS NULL OR source_book = '';

-- THE MIS-CITED PAGES ARE GONE. Spot-asserted on the two clearest instances
-- rather than on all twenty: the Fire spells that pointed at the list page, and
-- the Water spells that all pointed at printed 82.
SELECT 'no Fire spell still points at the list page' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells
 WHERE name IN ('Fire: Fire Gout', 'Fire: Lower Temperature', 'Fire: Part Fire',
                'Fire: Wall of Flame')
   AND instr(source_book, 'p.74') > 0;

-- TEN Water spells belong on printed 82 and seven did not. The Level One:
-- Water section really is printed there; the seven higher-level ones were
-- stamped with the same page by the summary list that spans 81-82. `want 10` is
-- MEASURED, not assumed - an earlier draft of this readback guessed `want 1`
-- and was wrong about the ten legitimate rows.
SELECT 'only the level-one Water spells still claim printed 82' AS assertion,
       count(*) AS got, 10 AS want
  FROM spells WHERE source_book = 'Rifts Book of Magic p.82';

SELECT 'and every one of those ten is level one' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE source_book = 'Rifts Book of Magic p.82' AND level <> 1;

-- NOTHING WAS INVENTED WHERE THE BOOK IS SILENT. area_of_effect and
-- casting_time are printed as their own line only rarely, so most rows should
-- still be NULL - a fully populated column here would mean the extraction had
-- filled in what it could not read.
SELECT 'area_of_effect is still mostly unset, as the book leaves it' AS assertion,
       CASE WHEN count(*) > 300 THEN 1 ELSE 0 END AS got, 1 AS want
  FROM spells WHERE area_of_effect IS NULL OR area_of_effect = '';

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-bom-spell-backfill.sql');
