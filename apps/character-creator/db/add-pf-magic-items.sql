-- The finished magic items: 175 rows an alchemist sells over the counter.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-pf-magic-items.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-pf-magic-items.sql
--
--   Magic armour, finished suits           3
--   Magic potions                         28
--   Magic powders                          8
--   Magic fumes                            7
--   Magic crystals and stones              9
--   Guardian stones                        3
--   Magic fabrics                         11
--   Magic bandages and make-up            10
--   Other articles of magic               11
--   Faerie foods                          28
--   Miscellaneous magic components        28
--   Poisons and toxins                    12
--   Herblore: drugs and herbal potions    17
--
-- THE OTHER HALF of printed 249-267. The enchantments are what an alchemist
-- puts INTO an object; these are the objects he sells finished. A Potion of
-- Healing is a row. "+1 A.R., 4,000 gold" is not, and lives in `enchantments`.
--
-- THE THREE MAGIC SUITS GO IN AS ARMOUR, not as an undifferentiated "magic"
-- row: the page prints an A.R. and an S.D.C. for each, and those columns exist.
--
--   cloak-of-armor        A.R. 14  S.D.C. 50   20,000 gold
--   cloak-of-protection   A.R. 12  S.D.C. 50   15,000 gold
--   leather-of-iron       A.R. 15  S.D.C. 60   30,000 gold
--
-- Everything else is category 'magic', which is a new value in a column that
-- has always been free text with a suggested list.
--
-- COST IS THE LOW END and cost_note carries the rest, the same division the
-- rest of `gear` uses. Most of these need it: the book prices in ranges far
-- more often than in figures, and four different ways -
--
--   a range        "20,000-40,000 gold"          Cloak of Guises
--   an open end    "700,000+ gold"               Cape of Dimensions
--   a per-unit     "80 gold per foot"            Cherubot Rope
--   a band         "500-1,500 gold"              the faerie foods
--
-- FAERIE FOODS ARE PRICED BY BAND rather than one by one, which their own
-- preamble states: the recreational ones - cinnamon sticks, bubbly wine,
-- cordials, tarts and the rest - run 500 to 1,500 gold, and the debilitating
-- ones 2,000 to 10,000. Cinnamon Sticks overrides its own band at 5,000-8,000.
--
-- ONE ITEM HAS NO PRICE AT ALL and keeps none: the Crystal Ball is "considered
-- priceless and sells for millions". A number there would be invented.
--
-- READING PROSE, NOT A TABLE. These entries are paragraphs with a price
-- somewhere inside, and an extractor found the boundaries rather than the
-- answers. Three classes of error had to be corrected by reading the page:
--
--   * A PRICE WRAPPED ACROSS A LINE. "20,000-\n30,000" rejoins as the single
--     number 2,000,030,000 if the de-hyphenation that fixes a broken WORD is
--     let near it. The Fright Wig and the Chaser crystal both read that way.
--   * A LONGER ENTRY LABELS ITS OWN PARTS - "Duration:", "A.R.:", "Cost:" -
--     and each looks exactly like the start of a new item. The Cape of
--     Dimensions' 700,000 gold was attributed to an item called "Use Limits".
--   * THE FIRST PRICE IN AN ENTRY IS NOT ITS PRICE. The Cape mentions 25,000
--     gold to repair a tear long before its own cost line.
--
-- NOT IMPORTED, and named so that skipping them reads as a decision: rune and
-- holy weapons are generated from a tier and a table rather than listed;
-- curses are effects applied to a person or an object, with no price and no
-- weight; transformable weapons are a kind of weapon rather than a property.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cloak-of-armor', 'Cloak of Armor', 'palladium-fantasy', 'armor', 20000, NULL, 14, 50, 'A.R. 14, S.D.C. 50. The garment appears to be an ordinary cloth cloak with a hood. Base Cost: 20,000 gold, plus additional S.D.C. may be added at a cost of 10,000 gold per 50 points, up to a maximum of 250 points!', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cloak-of-protection', 'Cloak of Protection', 'palladium-fantasy', 'armor', 15000, NULL, 12, 50, 'A.R. 12, S.D.C. 50 and impervious to fire, although the person wearing it will still suffer from heat and smoke, and his shoes and other clothes may catch fire. Additional S.D.C. cannot be added. Cost: 15,000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('leather-of-iron', 'Leather of Iron', 'palladium-fantasy', 'armor', 30000, NULL, 15, 60, 'The armor can be soft, hard, or studded leather. From all outward appearances, it is a normal suit of leather armor, but it is really enchanted with an A.R. 15 and S.D.C. 60. Base Cost: 30,000 gold, plus additional S.D.C. may be added at a cost of 10,000 gold per 50 points, up to a maximum of 300 points!', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('all-purpose-remedy', 'All-Purpose Remedy', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'A tonic that cures a number of miscellaneous ailments within 15 seconds after drinking! Eliminates headaches (reduces migraine to half), slight fevers, stuffy head/sinus, runny nose, minor stomach ailments, incontinence, hiccups, and drunkenness (instantly sober). It tastes terrible but works great. Cost: 300 gold. Note: It does not help against magic aliments, curses or faerie food.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('charm', 'Charm', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, 'Same as spell magic and costs 500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('love-charm', 'Love charm', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Same as spell magic and costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('chameleon', 'Chameleon', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Same as spell magic and costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('change-appearance-to-look-older', 'Change Appearance to Look Older', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Increases the character''s appearance (only) by twenty years; used for disguise. Lasts 8 hours. Cost: 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('change-appearance-to-look-youthful', 'Change Appearance to Look Youthful', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Reduce the character''s appearance (only) by Fifteen years. Lasts 8 hours. Cost: 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('fleet-feet', 'Fleet feet', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Same as spell magic and costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('fly-as-the-eagle', 'Fly (as the eagle)', 'palladium-fantasy', 'magic', 1200, NULL, NULL, NULL, 'Same as spell magic, costs 1200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('foresee-the-future', 'Foresee the future', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Divination same as clergy, costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('healing', 'Healing', 'palladium-fantasy', 'magic', 400, NULL, NULL, NULL, '1D6 hit points or 2D6 S.D.C. are restored. Cost: 400 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('healing-superior', 'Healing (superior)', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, '2D6 hit points or 4D6 S.D.C. are restored. Cost: 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('invisibility', 'Invisibility', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Same as spell magic and costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('impervious-to-fire', 'Impervious to fire', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'No damage and costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('impervious-to-cold', 'Impervious to cold', 'palladium-fantasy', 'magic', 400, NULL, NULL, NULL, 'Cold does no damage and costs 400 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('negate-magic-potions', 'Negate Magic Potions', 'palladium-fantasy', 'magic', 1200, NULL, NULL, NULL, '1-65% chance of negating any magic potion but causes nausea for 1D6 hours. Cost: 1200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('negate-poison', 'Negate Poison', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, '1-90% likelihood of negating any type of natural poison, but only 1-35% chance of negating magic poison like those from the bite or stinger of some creatures of magic. If successful the poison is instantly negated, however, damage suffered before drinking the potion remains. Cost: 500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('sleep', 'Sleep', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Same as spell and costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('shrinking-reduce-to-six-inches', 'Shrinking (reduce to six inches)', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Same as magic spell and costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('size-of-the-behemoth', 'Size of the Behemoth', 'palladium-fantasy', 'magic', 900, NULL, NULL, NULL, 'Same as spell magic and costs 900 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('superhuman-strength', 'Superhuman Strength', 'palladium-fantasy', 'magic', 1000, NULL, NULL, NULL, 'Same as spell magic and costs 1000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('speed-of-the-snail', 'Speed of the snail', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Same as spell magic and costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('turn-self-into-mist', 'Turn self into mist', 'palladium-fantasy', 'magic', 1500, NULL, NULL, NULL, 'Same as spell magic and costs 1500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('truth-serum', 'Truth Serum', 'palladium-fantasy', 'magic', 3000, NULL, NULL, NULL, 'Forces victim to tell the truth. Two questions can be asked per melee round. Cost: 800 gold. Metamorphosis (superior; any form except mist): Same as spell magic and costs 3000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('blind', 'Blind', 'palladium-fantasy', 'magic', 1000, NULL, NULL, NULL, 'Same as spell magic and costs 1000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('mute', 'Mute', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, 'Same as spell magic and costs 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('tongues', 'Tongues', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, 'Same as spell magic and costs 500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('swim-as-a-fish-minor', 'Swim as a Fish (minor)', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Same as spell magic and costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('might-of-the-palladium', 'Might of the Palladium', 'palladium-fantasy', 'magic', 1500, NULL, NULL, NULL, 'Adds one additional attack per melee round and a bonus of +2 to strike, parry, dodge, and damage! Cost: 1500 gold. Note: Characters who are forced to drink a potion get to save vs magic and need to roll 14 or above. 253', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('sneezing-powder-magic', 'Sneezing powder (magic)', 'palladium-fantasy', 'magic', 200, NULL, NULL, NULL, 'Must be blown or thrown in the victim''s face. Victim will sneeze constantly and uncontrollably for 1D6 melees; -3 to initiative, strike, parry, and dodge, -40% to prowl, -40% on skill performance. Costs: 200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('itching-powder-magic', 'Itching powder (magic)', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, 'Very uncomfortable, lasts for 2D4x10 minutes or until washed off. Victim is -4 on initiative, -5% on skills and is distracted. Affects bare skin only. Costs: 100 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('fire-dust-magic', 'Fire dust (magic)', 'palladium-fantasy', 'magic', 1500, NULL, NULL, NULL, 'Causes intense burning pain for 3D4 melee rounds or until washed off. Victim takes 1D4 damage from initial shock of the irritant, -6 on initiative, -4 to strike, parry, or dodge. Affects bare skin only. Costs: 1500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('heart-of-flame', 'Heart of flame', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, 'A phosphorus, quick burning powder that makes a torch sized fire grow three times its size for 1D4 melees. Costs: 100 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('goblin-dust-special', 'Goblin dust (special)', 'palladium-fantasy', 'magic', 15, '15-30 gold', NULL, NULL, 'Must be thrown into victim''s face, 40% chance of temporarily blinding him for 1D4 melees; -9 to strike, parry and dodge. The dust is supposed to have special properties that makes it especially effective against goblins, hobgoblins, orcs, and kobolds. It will be suggested that the person should hit the goblin in the head with the bag, using all his might. The bag that contains the dust is specially designed to burst on impact (cheap, flimsy material). This is really an old alchemist con in which he sells a five pound (2.3 kg) bag of soot, ash, and dirt from his furnaces and fireplace packed in a shabby bag. Note: Ironically, the goblin dust does really work sometimes (1-40% chance). Costs: 15-30 gold per five pound (2.3 kg) sack.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('moon-beams', 'Moon beams', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'A luminous powder sold in an 8 ounce container. Costs: 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('pixie-dust-magic', 'Pixie dust (magic)', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Shrinks victim to half normal size for 3D4 minutes. Costs: 600 gold. Fumes appear as smoke or vapor which produces the following special effects. They are sold as candles or incense. Price is per each candle or incense stick. Note: Saving Throw: 14 or higher.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('apparitions', 'Apparitions', 'palladium-fantasy', 'magic', 600, 'per stick, which burns for one hour', NULL, NULL, 'All types of terrible wraith-like creatures spring to life, assaulting the victims of this fume. Affects a 10 foot (3 m) radius; oppressive, heavy smell. Takes 1D6 melees to induce the hallucinations; roll to save vs insanity (14 or higher). Those who fail to save', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('daze', 'Daze', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'A light, flowery aroma that fills and affects a 12 foot (3.6 m) radius. Victims are dizzy, speed and skill performance are reduced by half, -4 on initiative, -2 to strike, parry, or dodge. Lasts as long as exposed to the fume or for 3D4 minutes after leaving the radius of influence or after the fume has been extinguished. A stick will bum for 45 minutes. Costs 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('divination', 'Divination', 'palladium-fantasy', 'magic', 350, NULL, NULL, NULL, 'Same as psionic clairvoyance; 1 -66% chance of inducing a true vision after the entire stick has burned (20 minutes). Costs 350 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('drive-away-evil-spirits', 'Drive away evil spirits', 'palladium-fantasy', 'magic', 400, NULL, NULL, NULL, 'Six foot (1.8 m) radius. Prevents ghosts, spirits, and undead from entering the magic radius unless the creature rolls an 18-20 to save vs magic. One hour duration per stick. Costs 400 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('fire-candles', 'Fire candles', 'palladium-fantasy', 'magic', 20, NULL, NULL, NULL, 'Shoots out sparks doing 1D6 damage twice per melee round. Range: 6 feet (1.8 m). Duration: two melee rounds; cost 20 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('raise-strange-shapes', 'Raise strange shapes', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'Shadows seem to take form and begin to move. Affects a 10 foot (3 m) radius; sweet smelling, heavy odor. Takes 1D4 melee rounds to induce the hallucinations and potential victims 254 get to roll to save (14 or higher). Those who fail to save cringe in terror and hide, afraid to move lest the monsters responsible for the menacing shadows attack them. One hour duration per stick; the phobic terror lasts for 2D4 minutes after the fume has been extinguished. Costs 600 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('roman-candle', 'Roman candle', 'palladium-fantasy', 'magic', 50, 'per candle; duration one melee round', NULL, NULL, 'Shoots out a bolt of fiery sparks and tiny fire balls three times in a single melee round. Does 2D6 damage as a weapon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('stink-bomb', 'Stink bomb', 'palladium-fantasy', 'magic', 75, '75-150 gold', NULL, NULL, 'Releases a putrid smelling, yellow vapor that fills a 12 foot (3.6 m) radius. People within the radius will gag, eyes water, and vomit unless they flee to at least 12 feet (3.6 m) away. Victims staying in the area are -2 on initiative, -1 to strike, parry, and dodge, and speed is reduced by 30%. Duration of the stench: 3D4 melee rounds per each bomb. Cost: 75 to 150 gold each.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('chasers', 'Chasers', 'palladium-fantasy', 'magic', 2000, '2,000-3,000 gold per Chaser crystal at human size; less for a small one', NULL, NULL, 'These are foul creatures locked within what appears to be a crystal of light. When smashed, by either dashing the crystal on the ground or hitting it with something, a Chaser is released and will instantly attack anybody in front of it - a Chaser will always face the opposite direction from which it was thrown. Even the alchemists who create Chaser crystals don''t know what these creatures of light are, or if they are living creatures at all or just weird animated energy. Whatever they are, they always react the same: appear as huge, brightly glowing, yellow or green skull-like energy spheres with a gaping toothless maw, a wispy tail like a comet, and emits a low, howling cry. Without hesitation the Chaser(s) will zoom forth with startling speed (about 30 mph/48 km), zipping down corridors, moaning its terrible groan. Spotting a victim (the first person it sees), it will race towards him, giving chase, slipping under doors and through cracks if it must, to fling itself Kamikaze-style, headlong into its terrified victim and ending in a blaze of light and bone chilling cold. If by some miracle the intended victim should escape, it will look for a new target.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('crystal-ball', 'Crystal Ball', 'palladium-fantasy', 'magic', NULL, 'Considered priceless; sells for millions', NULL, NULL, 'These legendary items are extremely rare, highly coveted and quite expensive; less than 2000 are believed to exist in the entire world! A crystal ball enables the user to gaze into it to locate any person, creature, or place within a 1000 mile (1600 km) radius. The only limitation is that the user must be familiar with the person, creature, or location (there is no P.P.E. cost to activate, only a need to see whomever). After 2D4 melee rounds of concentration and staring into the crystal ball, the target subject will appear. When located, the crystal will enable the viewer to see and hear all within his viewing area as if a magical video camera was pointed at the person or area and its sound and image were transmitted to a TV monitor. The angle of the image is a straight on shot, pointed at the subject. Approximately a ten foot (3 m) diameter around the subject can be seen and voices off camera (outside the image) can be heard, provided the subject of observation can hear them. Duration: Indefinite. As long as the viewer is interested, the crystal will observe the subject of observation wherever he goes. If the watcher becomes bored, distracted, falls asleep or leaves or covers the crystal, the image fades within one melee (15 seconds) and is effectively "turned off." Note: Practitioners of magic above third level experience, dragons, most creatures of magic and greater supernatural beings may sense the presence of enchantment and realize that they are being observed by a crystal ball (38% +2% per level of experience; roll once for every five minutes of observation). When this happens, the character will turn, as if looking directly into the camera and through concentration and the expenditure of 15 P.P.E., cancel the signal; the crystal goes cloudy. That particular character (or location) cannot be observed again for 4D4 hours. Fortunately for the user of a crystal ball, it is impossible for the subject being observed to sense or see who is watching him, or to sense where his spy is located. A crystal ball cannot see into other dimensions or see those protected by a sanctum, sanctuary, or anti-magic cloud spell, or those in a superior circle of protection, superior protection from magic circle or circles of all seeing, knowledge, power, power matrix, and wonder. Cost: Considered priceless and sells for millions.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('crystal-of-light', 'Crystal of Light', 'palladium-fantasy', 'magic', 1500, '1,500-3,000 gold', NULL, NULL, 'This is a handsome, many faceted, glass crystal which magically captures and holds light. The golf ball sized crystal perpetually emits a soft light equal to about one or two candles. Cost: 1500-3000 gold; burns out within 20 years. Fair availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('divination-ball', 'Divination Ball', 'palladium-fantasy', 'magic', 1000000, '1-6 million gold; rare', NULL, NULL, 'A crystal ball that can tell the future is another extremely rare and desirable enchanted object. Its power is basically the same as the psionic power of clairvoyance. The observer stares into the crystal while concentrating on one person whose future he''d like to glimpse. Chance of success is 52%. Divination can be attempted only once per every 12 hours. It cannot be used on oneself. Cost: 1-6 million in gold; rare.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('eye-of-the-cat', 'Eye of the Cat', 'palladium-fantasy', 'magic', 6000, '6,000-8,000 gold', NULL, NULL, 'A crystalline monocle that enables its wearer to see clearly in the dark; equal to 40 feet (12.2 m) nightvision. Note: All crystals, non-gems, are fragile glass items, easily broken if careless; 2D4 S.D.C. Cost: 6000-8000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('eye-of-the-eagle', 'Eye of the Eagle', 'palladium-fantasy', 'magic', 10000, '10,000+ gold', NULL, NULL, 'A crystalline monocle that enables its wearer to see great distances; up to 2000 feet (609.6 m) or approximately a third of a mile. The image will appear sharp and clear as one might expect from a hand-held telescope or modern binoculars. Cost: 10,000+ gold. Uncommon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('gem-of-direction', 'Gem of Direction', 'palladium-fantasy', 'magic', 8000, NULL, NULL, NULL, 'This is a unique item often used by navigators and merchant caravans. Within a faceted gem, about the diameter of a quarter, is a clearly visible sliver of light that always points north. Cost: 8000 gold. This item is comparatively common.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('gem-of-reality', 'Gem of Reality', 'palladium-fantasy', 'magic', 50000, '50,000+ gold', NULL, NULL, 'This is a crystal that enables anybody looking through it to see through all illusions and magic disguises! It cannot detect or reveal Changelings or metamorphosis altered creatures because these are real physical changes. No saves against the crystal are possible, all illusions will be revealed. Cost: 50,000+ gold, often 50-100% more. This item is fairly rare.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('marbles-of-transformation', 'Marbles of Transformation', 'palladium-fantasy', 'magic', 800, '800-1,200 gold', NULL, NULL, 'These small glass or marble balls appear to be ordinary marbles, but are actually a bizarre mystical transmutation of a common object such as a length of rope, weapon, clothes, gem, tool, ladder, etc. The marble will transform into the original object, in perfect condition, when the character mentally wills it to do so and says the magic word "Acba" three times. Although anybody can activate these marbles, the person must focus his mental energies/concentration to do so for at least one full melee round and say the magic words. Smugglers, thieves, assassins and spies have found the marbles to be an excellent means to conceal weapons and valuables. Limitations: Only one item can be transformed per each marble and it must weigh less than 10 pounds (4.5 kg). Furthermore, it cannot be magic, alive, organic (like food or plants), or a perishable item. To transform the marble, the person desiring to do so must be able to see it or have physical contact (touching) with it. Once transformed, the object will retain its normal shape and cannot turn back into a marble again. Cost: Base price is usually about 800 to 1200 gold plus the cost of the item being transformed. Most alchemists sell such items or are willing to transform items for a 25% service fee (takes 48 hours).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('beastiary-guardian', 'Beastiary Guardian', 'palladium-fantasy', 'magic', 100000, '100,000-300,000 gold', NULL, NULL, 'These statues will grow into fearsome animals, creatures of magic or imaginary beasts of terrible visage. All have the same abilities regardless of its appearance: 80 S.D.C./hit points, speed 14, natural A.R. 14, two attacks per melee round by bite (2D6 damage) or by claws, tail or other, doing 3D6+2 damage. The creature is never larger than 5-6 feet (1.5-1.8 m) long/tall, is +1 on initiative, +2 to strike, +3 to parry and dodge, and can prowl 40%, track by smell 60%, and will fight to the death. Crumbles into stone if all its S.D.C./hit points are destroyed. Otherwise, once intruders have been slain or leave the guarded area, they turn back into statues. Cost: 100,000-300,000 gold. Add 30,000 gold if winged and can fly (spd 33).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('demon-stone-guardians', 'Demon Stone Guardians', 'palladium-fantasy', 'magic', 500000, NULL, NULL, NULL, 'These are the largest, rarest, and most powerful of the Guardian Stones. They are always carved in jade and appear to be demons or frightful, imaginary, demon-like creatures. All have the same abilities regardless of its appearance: 140 S.D.C./hit points, speed 14, natural A.R. 14, three attacks per melee round by bite (3D6 damage) or by claws, tail or other, doing 4D6 damage. May also possess one special ability at a steep extra expense. The creature is usually 6 to 9 feet (1.8 to 2.7 m) tall, is +2 to initiative, and +3 to strike, parry and dodge. Many wield a weapon (4D6 damage), can see the invisible, nightvision 90 feet (27.4 m), climb 60/55% and will fight to the death. Crumbles into stone if all its S.D.C/hit points are destroyed. Cost: 500,000 gold. Those with one special power cost an additional 100,000 gold. Special Powers: Fire Breath (4D6 damage), Frost Breath (4D6 damage), Spit Lightning (4D6 damage), Turn Invisible (at will), or Fly. The breath and spit powers have a range of 60 feet (18.3 m), can be done once every melee and counts as an extra melee attack.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('little-guardians', 'Little Guardians', 'palladium-fantasy', 'magic', 50000, '50,000-80,000 gold', NULL, NULL, 'These include life-size spiders, scorpions, snakes, beetles and similar creatures. All have the same abilities: 40 S.D.C./hit points, speed 12, natural A.R. 12, one attack per melee round. Poisonous bite does 1D4 damage plus 4D6 from the poison unless a successful save is made (14 or higher). The creature is rarely larger than 8 inches long (0.26 m), is +1 to strike, +4 to dodge, can prowl 70%, and climb 85/80%. Will turn into crumbled stone when all S.D.C./hit points are destroyed. Fights to the death. Cost: 50,000-80,000 gold; rarish, poor availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('boots-of-fleetness', 'Boots of Fleetness', 'palladium-fantasy', 'magic', 30000, '30,000+ gold; uncommon', NULL, NULL, 'Doubles natural speed. Cost: 30,000+ gold; uncommon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('boots-of-mystery', 'Boots of Mystery', 'palladium-fantasy', 'magic', 30000, '30,000+ gold; fairly rare', NULL, NULL, 'These are mystic boots made of cloth or soft leather. They simply leave no tracks. Without footprints, the wearer cannot be easily followed or tracked. However, he or she can still be tracked by smell and other physical signs (remains of a campfire, broken twigs and plants, etc.), although the tracking animal or person is 20% to do so. Another bonus of the boots is their added stealth, providing +5% to prowl. Cost: 30,000+ gold; fairly rare - a favorite among rangers and prosperous thieves.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cape-of-dimensions', 'Cape of Dimensions', 'palladium-fantasy', 'magic', 700000, '700,000+ gold; triple if indestructible. Very rare', NULL, NULL, 'This is a truly rare and wondrous magic fabric that can temporarily shift into other dimensional planes (but where exactly, nobody knows). It can do the following: 1. Dimensional Shift: Momentarily transports its wearer into a dimensional void or pocket, causing him/her to seem to disappear. In effect, the person actually blinks out of existence or, more accurately, out of his normal space and time. Since the character no longer exists, he cannot be detected by psionics, magic or any other means. Duration: A maximum of five minutes. Limitations: While in limbo one cannot see, hear, or feel anything from his/her departed dimension, nor attack, move or perform magic or psionics, just wait.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cherubot-rope', 'Cherubot Rope', 'palladium-fantasy', 'magic', 80, '80 gold per foot; +100 per foot impervious to fire, +100 impervious to normal weapons, +200 for both', NULL, NULL, 'This rope bears the mystic name for air elementals because the rope can actually fly through the air and suspend itself as if anchored in mid-air. The Cherubot Rope is limited in that: 1. It must always have one end touching the ground. 2. It cannot be manipulated to entangle, tie-up or knot. 3. It will always move in a straight line whether it be straight up or straight down or in any straight angle. 4. It has all the strengths and WEAKNESSES of normal rope (i.e. can be cut, burnt, unraveled, etc.). Note: The rope can support up to 800 pounds (362 kg), but it cannot be used like an elevator by grabbing it at the top and allowing it to carry you up into the air with it. Instead the rope must be thrown into the air at the intended angle or area where it will continue to travel (fly) until its holder stops it by tugging on it or its maximum length is reached. The Cherubot Rope will return when the person using it commands it to do so and gives it four quick tugs. Cost: 80 gold per foot (0.3 m). Special Additional Magic Increases Its Expense: Impervious to fire is an extra 100 gold per foot (0.3 m); impervious to normal weapons (magic and magic weapons will do full damage) is an extra 100 gold per foot (.3 m); both impervious to fire and normal weapons costs 200 gold extra per foot.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cloak-of-guises', 'Cloak of Guises', 'palladium-fantasy', 'magic', 20000, '20,000-40,000 gold; add 20% for silk or a fancy design', NULL, NULL, 'This amazing full-length cloak can magically turn into several complete sets of clothing at will! This includes a shirt, pants, socks and vest, or coat, or a full-length dress. The clothing is limited to various shades of the cloak''s original color; i.e. red can change into deep crimson, light red, pink and shades in-between. The pieces of the mystic clothing cannot be separated and must be worn as one complete set. If a piece is removed the whole costume will revert into its cloak form. Another limitation is that the clothes cannot appear to be any fabric other than what the cloak itself is made of. The Cloak of Guises is often used by spies, thieves, assassins and others in need of instant disguise. Duration: Until taken off.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cloak-of-invisibility', 'Cloak of Invisibility', 'palladium-fantasy', 'magic', 50000, '50,000+ gold', NULL, NULL, 'This magic fabric comes as a long, full length cloak or cape that brushes the ground and comes with a hood. The wearer and everything beneath the cloak becomes invisible. The wearer can turn invisible (same as the lesser spell) and visible at will. Duration: 60 minute total per 24 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('cloak-of-shadows', 'Cloak of Shadows', 'palladium-fantasy', 'magic', 12000, '12,000+ gold', NULL, NULL, 'The wearer is difficult to see in shadows, but even in lighted areas the character moves silently and unobtrusively like a shadow; +20% to prowl. Cost: 12,000+ gold; uncommon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('environmental-tent', 'Environmental Tent', 'palladium-fantasy', 'magic', 2000, NULL, NULL, NULL, 'This looks like any other tent except that it has a circle of protection from elemental forces and various other mystic symbols and enchantment built into the fabric. Magically endowed, the inside of the tent will be a constant pleasant environment; always dry and warm (70 degrees Fahrenheit) regardless of the conditions outside. Note: The tent cannot protect against major acts of nature, such as lightning, floods, mud slides, earthquakes and so on. Nor can it protect against similar, magically induced elemental forces above 4th level strength. Cost: About 2,000 gold for a two-man tent, 3,500 gold for a four-man tent and 8,000 gold for a tent that can house up to eight people comfortably.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('enchanted-bags', 'Enchanted Bags', 'palladium-fantasy', 'magic', 15000, NULL, NULL, NULL, 'These are magic bags that will always appear to be empty, noiseless and lightweight, even upon close scrutiny. Any person who looks into an Enchanted Bag must roll to save vs magic. Only a roll of 18, 19 or 20 saves against the enchantment (only bonuses vs illusion are applicable). A successful save allows one to see the true contents of the bag. If that person fails his roll he will perceive the bag to be empty, hear nothing even if the bag is violently shaken, and detect no additional weight from its contents. However, if tipped upside-down, all the concealed articles will come visibly tumbling out. Note: The owner/carrier of the bag feels its full weight at all times. The purchaser/owner of the bag must have the alchemist, or he himself, inscribe his "true" name or place a drop of his blood somewhere on the bag to be free of its enchantment (for that particular bag). Otherwise, the character must also roll to save vs the illusionary enchantment each time he/she looks into the bag too. Of course, the owner of the bag will know what''s in it and knowing that, he can either feel for the object or dump everything out. Cost: This varies, depending on the size of bag and its maximum weight allowance. Small pouch, purse or bag: 5 Ib (2.3 kg) maximum weight, costs 2000 gold; medium-sized handbag, purse, or sack with a 15 Ib (6.8 kg) weight limit costs 6000 gold; while a large sack, backpack or saddlebags with a 30 Ib maximum weight limit costs 15,000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('flying-carpet', 'Flying Carpet', 'palladium-fantasy', 'magic', 225000, '225,000+ gold', NULL, NULL, 'An enchanted, colorful carpet that can fly at a speed of 30 mph (48 km). All flying carpets have an A.R. 6 and 50 S.D.C. points. The nature of the carpet is such that it gets no bonuses to dodge and passengers may fall off when sharp maneuvers and dives are performed - the carpet should be kept level at all times! Cost: A small carpet holds two human-sized people and costs 100,000+ gold. A large carpet holds five human-sized passengers and costs 225,000+ gold. Flying carpets are rare. Only in the Western Empire, where they originate, are they comparatively common (one in ten magic shops will have one or two for sale).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('gryphon-claws', 'Gryphon Claws', 'palladium-fantasy', 'magic', 45000, '45,000-90,000 gold', NULL, NULL, 'These appear to be an ordinary pair of gloves, but upon command, terrible magic claws extend from the fingertips. Only a few alchemists know the secrets of its creation so the Gryphon Claw gloves are quite rare. It is generally believed that the gloves were originally developed by the same ancient dwarven wizards who designed rune weapons. Abilities: Indestructible, claws extend and retract at the wearer''s will; adds +10% to scale walls and can be used to parry; +1 on initiative and to parry. Damage: 2D6 per each swipe of a claw. Cost: 45,000-90,000 gold; rare.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('magic-bandages', 'Magic Bandages', 'palladium-fantasy', 'magic', 30, NULL, NULL, NULL, 'These are an excellent life saving device especially for adventurers and men of arms. The magic strip of cloth looks like any ordinary roll of bandages, but once unrolled and placed near a wound, it will magically wrap and bind it, preventing blood loss. Large patch types are also available. Note: Magic bandages do not add bonuses against physical injury, coma, etc.; they simply and quickly bind a wound, preventing blood loss and the additional damage from blood loss (one hit point per melee round). Cost: 30 gold per foot (0.3 m) fora four inch wide strip or a 6 inch (0.25 m) diameter patch. Only one use per bandage, then throw away. Quite common.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('pillow-of-sleep', 'Pillow of Sleep', 'palladium-fantasy', 'magic', 10000, '10,000 gold; uncommon', NULL, NULL, 'This is yet another type of magic which places anyone who lays his head on the pillow into an enchanted slumber. The person will remain asleep as long as his head is on the pillow, awakening only when the pillow is removed. Unlike most magic sleeps, the duration is unusually long and could even make its enchanted victim sleep so long that he could die from hunger.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('pit-cloak-or-blanket', 'Pit Cloak (or blanket)', 'palladium-fantasy', 'magic', 16000, NULL, NULL, NULL, 'This cloak or blanket is an unusual magic fabric that transforms into a pit that''s 20 feet (6 m) deep and covers a 6 foot (1.8 m) diameter. The cloak or blanket instantly transforms when it is thrown across the ground, and the magic power word "Acba" is spoken. The magic fabric must be thrown horizontally on the ground, meaning earth, dirt, sand, clay, rock, etc. It will not open a hole or pit in mid-air, wood or any living thing, nor if placed vertically on a wall. Anybody or anything which has fallen into the pit must be removed before it can resume its cloak or blanket form. It cannot be turned back into a cloak and picked up as long as something is inside it. Damage: From falling into the pit is 2D4. It typically takes one full melee round to climb out (longer if the victim doesn''t have the climb skill or friends to lend a hand). Cost: 16,000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('suit-of-colors', 'Suit of Colors', 'palladium-fantasy', 'magic', 8000, 'about 8,000 gold; fancy garments cost more', NULL, NULL, 'This is similar to the Cloak of Guises except that rather than changing its shape, it can instantly change into ANY color, at will. The mystic garment can be a cloak, full-length coat, dress or a full suit of clothing. Duration: Indefinitely, until color change is requested or the clothes are destroyed.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('thread-of-iron', 'Thread of Iron', 'palladium-fantasy', 'magic', 50, NULL, NULL, NULL, 'This is a super strong, magical twine about as thick as a piece of string, but stronger than the best rope! Test strength is approximately 1500 pounds (675 kg), however, the thread cuts and burns as easily as normal string. Cost: 50 gold per foot. Magic Make-Up', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('fright-wig', 'Fright Wig', 'palladium-fantasy', 'magic', 20000, 'usually around 20,000-30,000 gold; fairly uncommon', NULL, NULL, 'This is a wild, sometimes bizarre mantle of hair or hairlike tendrils/dreadlocks (some have been known to resemble the head of a Medusa). The wig makes the wearer extremely intimidating. The wearer of the fright wig will also appear to be more physically imposing 258 to the point that he will seem bigger, more powerful and at least one O.C.C. level higher than he really is. Special Bonuses: 1-80% likelihood to intimidate all who behold the wearer or horror factor 15 when angry or trying to deliberately frighten someone. Always has the initiative in combat/first attack and people will usually back down from a challenge (80% to intimidate). Note: Conversely, opponents are likely to view this character as the most dangerous and therefore, the most likely to be attacked first or by greater numbers. A psionic see aura will not note any significant impression. Cost: Usually around 20,00030,000 gold; fairly uncommon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('magic-make-up', 'Magic Make-Up', 'palladium-fantasy', 'magic', 1200, NULL, NULL, NULL, 'The typical magic make-up kit includes a small sampling of special putty, paints, wax, etc., and can be combined with conventional make-up. The magic make-up looks much more realistic and life-like even when used in conjunction with conventional tools of the trade. Special Bonuses: +30% to disguise skill ability and half as likely to be recognized as being fake. Cost: A package of magic makeup, usually good for two complete make-up sessions, is about 1200 gold. Good availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('magic-make-up-paint', 'Magic Make-Up Paint', 'palladium-fantasy', 'magic', 600, NULL, NULL, NULL, 'This is a basic magic ingredient that can be mixed with conventional make-up paint/color. Bonus: Adds +10% to disguise skill. Cost: About 600 gold for three make-up doses. Good availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('miracle-cream', 'Miracle Cream', 'palladium-fantasy', 'magic', 40000, '40,000-100,000 gold per dose; poor to rare availability', NULL, NULL, 'This is an impressive magic fluid which enables the person to physically mold and reshape his facial features. The fluid must be completely massaged into the face. Within moments, the skin will take on a flexible consistency much like the very finest make-up pastes, putty and modeling clay. The facial features can be completely altered beyond recognition and while hair cannot be added, the hairline can be pushed back or pulled forward and similarly manipulated. Duration: Unless washed off within five hours, the disguise becomes permanent! If this happens, the only way to restore one''s original features is to resculpt them with another dose of miracle cream.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('vanishing-cream', 'Vanishing Cream', 'palladium-fantasy', 'magic', 400, '400-800 gold', NULL, NULL, 'This is a unique variation on invisibility. The cream will turn any living, organic material (skin, hair, etc.) invisible, but can be applied so that it covers only a specific part(s) of the body. This means it could be used to make only a person''s hand, arm, leg, or head, etc., appear to be missing (invisible). Duration: A maximum of one hour per application. It does not affect cloth, weapons, paper, etc. Cost: 400-800 gold per ounce. Note: One ounce can easily cover both arms, or head and hands with some left over. Four ounces should cover an average human under six feet (1.8 m) tall. Five ounces for a person over six feet or who is overweight, while eight or ten more ounces will be needed to completely cover an ogre or wolfen-size being.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('aura-of-non-scent', 'Aura of Non-Scent', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'This is a fluid applied as a spray, much like perfume. It completely masks one''s scent, which can be particularly handy in the wilderness or when infiltrating Wolfen territory. Duration: Approximately 20 minutes. Cost: 300 gold per ounce (one ounce is good for five doses).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('book-of-secrets-or-serpent-book', 'Book of Secrets or Serpent Book', 'palladium-fantasy', 'magic', 50000, '50,000-80,000 gold per silver serpent, sometimes more', NULL, NULL, 'An item popular among wealthy merchants, scholars and men of magic to guard their secret writings is the Book of Secrets. This mystic book is easily recognized by the winged serpent embossed in silver on the leather cover and binding. The paper is of the finest quality, numbers 150 to 300 pages and is impervious to fire. The best and most deadly of such books are those with two or three identical winged serpents. The book is attuned to its owner by smearing a drop of his/her blood into its leather spine. From that point forward, it can be read or used only by its owner. Anybody else will suddenly find the silver serpent(s) come to life as an eerie, ethereal manifestation of magic. The winged serpent(s) will instantly grow to about 3 feet long and weave around the book, hissing and snapping in warning for one melee round. The next melee, or if attacked, it will strike out by bite or wrapping around the defiler of the book with its tail/body. The Magic Silver Serpent', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('firewick', 'Firewick', 'palladium-fantasy', 'magic', 150, NULL, NULL, NULL, 'This appears to be a small candle melted down into a tiny lump with a wick sticking out of it. The magic power word, "Acba," will cause the wick to instantly ignite and stay lit for one minute. The firewick is commonly used as a quick light for campfires, torches and so on. Limited to 20 lights. Cost: 150 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('flying-broom', 'Flying Broom', 'palladium-fantasy', 'magic', 80000, '80,000+ gold', NULL, NULL, 'An enchanted broom that can fly. Accommodates two human-sized passengers. Speed: 35 mph (56 km), +2 to dodge while flying, A.R.: 8, S.D.C.: 60. Cost: 80,000+ gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('magic-restraints', 'Magic Restraints', 'palladium-fantasy', 'magic', 40000, '40,000+ gold', NULL, NULL, 'These are typically magic chains and a lock, handcuffs, manacles and similar bonds used to restrain, hold and imprison people. Magic restraints prevent those bound by them from using the wizard escape spell or any form of magical transformation (reduce size, metamorphosis, etc.) in order to slip one''s bonds! The locking mechanism is usually comparatively complex and difficult to open, but can be unlocked without magical means (thieves are -20% to pick 259 locks). The bonds, whether chain or enchanted leather, typically have 200 S.D.C., as does the lock. Cost: 40,000+ gold per each shackle/manacle and lock; fairly rare. Giant-sized restraints cost 50% more.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('mystic-ink', 'Mystic Ink', 'palladium-fantasy', 'magic', 150, '150-300 gold', NULL, NULL, 'This is an invisible ink often used by practitioners of magic in their notebooks, diaries, scrolls and spell books. Initially, the ink is visible as a light sepia color, but turns invisible within a few minutes. The ink can only be seen by the casting of a decipher magic spell or see the invisible (spell or psionics). Cost: 150-300 gold per ounce; fair availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('needle-of-sewing', 'Needle of Sewing', 'palladium-fantasy', 'magic', 1200, NULL, NULL, NULL, 'An ordinary looking needle that, when threaded and used to sew, will guide the hand of the user to make competent repairs, patches and the most basic articles of clothing at 60% skill proficiency. It''s not professional tailoring quality, but good, sturdy work that doesn''t look half bad. Cost: 1200 gold per enchanted needle; fair availability.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('quill-of-endless-ink', 'Quill of Endless Ink', 'palladium-fantasy', 'magic', 900, '900-1,500 gold', NULL, NULL, 'An ordinary looking crow quill pen that never runs dry of ink! Ideal for practitioners of magic, scholars and noblemen. Cost: 900-1,500 gold per pen; common.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('quill-of-literacy', 'Quill of Literacy', 'palladium-fantasy', 'magic', 10000, '10,000+ gold', NULL, NULL, 'This unique magic item enables an illiterate character to write up to 25 words of his choice simply by speaking the message aloud. The language in which the message is written varies with each individual quill. Since Elven is generally considered to be the universal written language, the most common quills write in Elven. However, any other non-magical (wards, runes, mystic symbols are not possible) language can be instilled in a quill of literacy. The human languages, especially Western and Eastern, as well as Dwarven, are the next most common. The quill is limited to 25 words every eight hours. Its expense arises, in part, in that only the feathers of a cockatrice can be embodied with the necessary magic. Cost: 10,000+ gold; poor availability/uncommon.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('screech-bottles', 'Screech Bottles', 'palladium-fantasy', 'magic', 125, NULL, NULL, NULL, 'These are ordinary looking corked bottles that release a hideous shriek or roar that lasts 1D4 melee rounds when smashed or uncorked. The screech is extremely startling and realistic, causing people to become nervous and jumpy. Cost: 125 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('tome-of-images', 'Tome of Images', 'palladium-fantasy', 'magic', 1000000, '1-10 million gold for a conventional one; rare', NULL, NULL, 'This is a rare and amazing book which can translate its owner''s thoughts into two dimensional images within its pages - words or pictures. How the book can do this is a mystery even to the world''s greatest men of magic, for its secrets have been lost even by alchemists for centuries. At a quick glance, the tome appears to be an ordinary leather-bound book commonly used by men of magic and scholars for their many notes and studies. Closer inspection will reveal that the black or grey leather cover is embossed with the runic symbol of magic/forces. On the upper right hand corner of each parchment page are the runic symbols of magic/forces, light and eternity, written in silver making its pages (and in this case, the entire book) indestructible. For this reason, the books are also known as "Rune Books." To create an image on the page, the book''s owner must be a user of magic, whether it be wizard, warlock, witch, Diabolist, Summoner or spell wielding clergy (Mind Mages do not utilize magic energy, consequently, they cannot use the Rune Books). The mage must concentrate on exactly what he (or she) wants depicted, prick his finger and place a blood smudged fingerprint on top of the silver rune symbols. Instantly an image will appear on the page; in full color if so desired. The image can be changed or erased by repeating the process. To make the image permanent, the mage must draw a mystic seal symbol around the silver runes on that particular page (also in silver). If the seal is not added, any mystic using the book can erase or alter the image. The imprinted image can appear as a line drawing or graphic design (perhaps of a circle or symbols) or an almost photographic picture complete with vivid color. It is rumored that some particularly ancient rune books are alive, possessing the same powers as the famous Rune Weapons. (G.M. Note: These ancient books of arcane magic do exist, but are even rarer than their less powerful counterparts just described. These "True" Rune Books have the following powers common to rune weapons: Numbers 1,2,6,7, and will possess either the clerical or psionic abilities common to greater rune weapons! Because of these powers, True Rune Books are often believed to be holy books and fanatically guarded. Less than a dozen are known to exist). Cost: 1-10 million gold for a conventional, rare. Tome of Images. A "True" Rune Book is even rarer, commanding unbelievable prices that can range from as little as a million gold to hundreds of millions, especially if a holy relic or ancient tome with valuable (magic?) information preserved on its pages.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-beets', 'Faerie beets', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'The victim becomes extremely violent and will attack the closest non-Faerie immediately. This rage will last 3D4 minutes, unless restrained.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-squash', 'Faerie squash', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This reduces the victim to half his normal size for 1D6 weeks! Only the victim''s body shrinks, not his clothes or weapons.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-sloe-wine', 'Faerie sloe Wine', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This faerie drink reduces speed and the number of attacks per melee by half for 1D6 days. It is also a wine, so it also has the normal effects of alcohol.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-cinnamon-sticks', 'Faerie cinnamon Sticks', 'palladium-fantasy', 'magic', 5000, '5,000-8,000 gold; always, whatever the band', NULL, NULL, 'These tasty treats give the victim the urge to commit acts of sinful evil at irregular periods for 1D6 months unless a remove curse is used. However, the person will be very pleased and self-satisfied during the entire time he or she is enchanted. Note: Always costs 5,000-8,000 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-tomatoes', 'Faerie tomatoes', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'Eating these delicious fruits causes the victim to temporarily grow 1D6 extra toes on each foot, making it impossible for them to wear normal shoes/boots. Effects last 1D6 months; -10% to prowl, but +5% to scale walls.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-pears', 'Faerie pears', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This creates a temporary double of the victim (a la the Doppleganger spell), but of the opposite alignment. The double will exist for only 2D4 days. The double will automatically dislike it''s opposite and flee from it. Note: Always costs 8,000-10,000 gold; rare.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-goose', 'Faerie goose', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'The victim will feel like he/she is being pinched at random times (usually when sleeping or when silence is required; stings but does no damage). The magic effects are permanent until a remove curse is successfully performed.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-roast-pigeon', 'Faerie roast Pigeon', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'After eating even a single mouthful of this succulent bird, the victim will believe anything he/she is told and respond accordingly. Effects last 24 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-turkey', 'Faerie turkey', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This causes the victim to become obnoxious and irritating for 1D4 days.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-mixed-nuts', 'Faerie mixed Nuts', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'The victim picks up 1D4 random phobias which last 1D6 weeks. 260', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-frog-s-legs', 'Faerie frog''s Legs', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'The victim''s legs assume the shape and function of a frog''s! The character can leap a number of feet straight up equal to his P.S., and twice his P.S. if jumping forward, doubling the person''s normal speed. The character is also +15% on his swimming skill, but is 10% to climb and his P.B. is reduced by 50%. The frog legs are permanent until a remove curse is used! Note: Always costs 3,0008,000 but is usually available.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-mussels', 'Faerie mussels', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This increases a person''s P.S. by 10 points, but the character is so muscle-bound that his P.P. and Spd attributes, as well as attacks per melee round are reduced by half. Lasts 1D6 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-bubbly-wine', 'Faerie bubbly Wine', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'This causes the victim to float in the air like a balloon without control, with little bubbles escaping from his nose and mouth. The victim feels very light-headed and happy, is -8 on initiative, -1 on all combat bonuses, and -10% on all skills (the victim just wants to float, giggle and enjoy himself). The effects last 1D4 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-burgundy-wine', 'Faerie burgundy Wine', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'The victim feels very happy and turns a vivid burgundy (purple) color. The purple color is permanent until a remove curse is used.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-beetle-nuts', 'Faerie beetle Nuts', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'A drug-filled nut that tastes delicious and causes mild hallucinations in which the victim will see everybody as giant, friendly beetles (not to mention beetles/people who aren''t there). Lasts 2D4 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-tarts', 'Faerie tarts', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'A yummy pastry that causes the victim to become extremely amorous and giddy, almost as if he/she were drunk and made to flirt with and desire every person of the opposite sex they encounter. The effects last for 1D4 days.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-peanuts', 'Faerie peanuts', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'This harmless looking snack makes the victim suffer the "call of nature" every hour and uncontrollably when under stress. The effects last 1D4 days.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-cordial', 'Faerie cordial', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'This is a light wine which makes the victim feel very relaxed and in a good mood, but also causes the character to behave extremely politely to everyone and everything they meet, including monsters and old enemies. The victim also completely loses initiative (the last to take action) and will only enter a fight if attacked first. The effects last 1D4 days.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-flounder', 'Faerie flounder', 'palladium-fantasy', 'magic', 500, '500-1,500 gold; one of the foods sought for recreation', NULL, NULL, 'A single mouthful of this fish will make the victim confused and unable to make up his mind. The character loses initiative, is 3 to strike, parry and dodge, and -20% on all skill performance. Furthermore, he or she can''t make a decision and will beg others to tell him what to do. The effects last 2D6 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-coffee', 'Faerie coffee', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'Even a sip of this delicious tasting beverage makes the victim cough continuously, ruining his sleep, interfering with his concentration and making it impossible to prowl/be quiet. The effects last 2D6 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-wine', 'Faerie wine', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'A wonderful tasting wine that causes extreme drunkenness. A half glass is the equivalent of three shots of hard liquor. Remains drunk for 2D6 hours. While drunk, the character''s speech is slurred, he staggers, and reaction time is off; -5 to initiative, strike, parry and dodge, -1 attack per melee, -50% on skill performance and -30% on speed. Despite the penalties, drunks love this stuff.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-walnut-candy', 'Faerie walnut Candy', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'A honey-dipped candy that induces a random phobia that lasts for 1D6 days.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-almond-candy', 'Faerie almond Candy', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'A tasty treat that causes the player''s skin to take on the look and texture of tree bark, temporarily reducing the player''s physical beauty by half. The effects last 1D4 days. No player can have a beauty less than one.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-beef-cake', 'Faerie beef Cake', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'Males who eat this will immediately consider themselves to be incredibly handsome, studly and debonair, enticing them to flirt, show-off and make absolute fools of themselves. Females who eat this will fall in love with the first male they see, regardless of the character''s looks and disposition. Effects last 1D4 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-duck', 'Faerie duck', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'Whether the character who eats this is lucky or not is a matter for consideration. A single mouthful provides the character with +3 to dodge/duck out of harm''s way. In fact, he can dodge automatically, like a parry, without using up a melee action. However, he becomes very timid, will never lead a charge and would much rather run than fight. The magic effects last 2D6 hours.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-skunk-cabbage', 'Faerie skunk Cabbage', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This food causes the player to have a rather offensive body odor which can be smelled up to 8 feet (2.4 m) away. This smell will last only 1D6 hours, but each player who smells this odor must roll under his/her mental endurance to avoid vomiting.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-green-beans', 'Faerie green Beans', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This vegetable simply causes the player to turn green. Unless a successful remove curse is cast on him, the effects are permanent.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-cauliflower', 'Faerie cauliflower', 'palladium-fantasy', 'magic', 2000, '2,000-10,000 gold; one of the rarer, more debilitating foods', NULL, NULL, 'This amusing vegetable causes the eater''s ears to grow four times larger than normal and into a cauliflower shape (reduce P.B. by 20%). This will last 1D4 weeks unless a remove curse is used.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('angel-feather', 'Angel feather', 'palladium-fantasy', 'magic', 20000, '20,000+ gold', NULL, NULL, '20,000+ gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('animal-s-blood-common', 'Animal''s blood (common)', 'palladium-fantasy', 'magic', 10, NULL, NULL, NULL, '10 gold per gallon (37.9 liters)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('bees-wax', 'Bees wax', 'palladium-fantasy', 'magic', 1, 'one gold per pound', NULL, NULL, 'One gold per pound (0.45 kg).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('butterfly-wings', 'Butterfly Wings', 'palladium-fantasy', 'magic', 1, 'one gold per dozen, triple out of season', NULL, NULL, 'One gold per dozen (triple when out of season)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('demon-or-deevil-blood', 'Demon (or deevil) blood', 'palladium-fantasy', 'magic', 6000, NULL, NULL, NULL, '6000 gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('demon-or-deevil-bones', 'Demon (or deevil) bones', 'palladium-fantasy', 'magic', 7000, NULL, NULL, NULL, '7000 gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('elf-bones', 'Elf bones', 'palladium-fantasy', 'magic', 60, NULL, NULL, NULL, '60 gold per pound (0.45 kg).', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-dust', 'Dragon dust', 'palladium-fantasy', 'magic', 20000, NULL, NULL, NULL, '20,000 gold per ounce (ground dragon bones)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-blood', 'Dragon blood', 'palladium-fantasy', 'magic', 8000, NULL, NULL, NULL, '8000 gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-bones', 'Dragon bones', 'palladium-fantasy', 'magic', 10000, NULL, NULL, NULL, '10,000 gold per pound (0.45 kg)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-claws', 'Dragon claws', 'palladium-fantasy', 'magic', 10000, NULL, NULL, NULL, '10,000 gold per pound (0.45 kg)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-eye', 'Dragon eye', 'palladium-fantasy', 'magic', 20000, '20,000+ gold', NULL, NULL, '20,000+ gold each', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-heart', 'Dragon heart', 'palladium-fantasy', 'magic', 50000, NULL, NULL, NULL, '50,000 gold', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-helm', 'Dragon helm', 'palladium-fantasy', 'magic', 200000, NULL, NULL, NULL, '200,000 gold', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-teeth', 'Dragon teeth', 'palladium-fantasy', 'magic', 5000, NULL, NULL, NULL, '5,000 gold per ounce', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-tongue', 'Dragon tongue', 'palladium-fantasy', 'magic', 50000, '50,000+ gold', NULL, NULL, '50,000+ gold', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('faerie-wings', 'Faerie wings', 'palladium-fantasy', 'magic', 20000, NULL, NULL, NULL, '20,000 gold each (35,000 per pair)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('god-or-godling-bone', 'God or Godling bone', 'palladium-fantasy', 'magic', 40000, NULL, NULL, NULL, '40,000 gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('goblin-tongue', 'Goblin tongue', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, '500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('ground-crystal-glass', 'Ground crystal/glass', 'palladium-fantasy', 'magic', 1, 'one gold per pound', NULL, NULL, 'one gold per pound (0.45 kg)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('ground-quartz-crystal', 'Ground quartz crystal', 'palladium-fantasy', 'magic', 1, 'one gold per pound', NULL, NULL, 'one gold per pound (0.45 kg)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('hydra-s-tooth-powdered', 'Hydra''s tooth, powdered', 'palladium-fantasy', 'magic', 8000, NULL, NULL, NULL, '8,000 gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('hydra-s-tooth-whole', 'Hydra''s tooth, whole', 'palladium-fantasy', 'magic', 40000, NULL, NULL, NULL, '40,000 gold each or 8,000 per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('lotus-petals', 'Lotus petals', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, '100 gold per dozen', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('quicksilver-mercury', 'Quicksilver (mercury)', 'palladium-fantasy', 'magic', 2, 'two gold per ounce', NULL, NULL, 'Two gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('snake-venom-for-circle-making', 'Snake venom (for circle making)', 'palladium-fantasy', 'magic', 10, NULL, NULL, NULL, '10 gold per six ounces (0.25 kg)', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('unicorn-horn-powdered', 'Unicorn horn, powdered', 'palladium-fantasy', 'magic', 32000, '32,000+ gold', NULL, NULL, '32,000+ gold per ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('unicorn-horn-whole', 'Unicorn horn, whole', 'palladium-fantasy', 'magic', 100000, '100,000+ gold', NULL, NULL, '100,000+ gold *Wolfen tongue: 400 gold. *Wizard tongue (low or unknown level): 15,000 gold. *Wizard tongue (mid or high level): 45,000+ gold. NOTE: Wizard and dragon tongues may cost as much as 200% more, while a known wizard''s tongue can cost as much as 1000% times more. The selling of tongues is outlawed in most civilized regions and may be available only on the black market, if at all. 261', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('hemlock', 'Hemlock', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, 'Heavy, sweet odor and taste, does 4D6+1O damage per dose. Costs: 100 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('nightshade', 'Nightshade', 'palladium-fantasy', 'magic', 120, NULL, NULL, NULL, 'Slight taste, virtually no odor, does 5D6+10 per dose. Costs: 120 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('mandrake', 'Mandrake', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, 'Bitter taste, virtually no odor, does 4D6 damage per dose. Costs: 100 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-s-venom', 'Dragon''s venom', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'Slight after taste, but no odor; does 1D6x10+6 damage per dose. Costs: 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('viper', 'Viper', 'palladium-fantasy', 'magic', 80, NULL, NULL, NULL, 'Slight tart taste, slight odor, does 6D6 damage per dose. Costs: 80 gold. Other Poisons & Toxins Note: Injected poisons are sometimes called "blood" poisons because they must enter the bloodstream via a cut, wound, or injection. Touching or tasting (a tiny smidgen of) the poison does no damage. Ingesting any contact or injected toxin will cause nausea and half damage. The victim must roll a 16 or higher to save. Contact poisons are absorbed through the skin by touch and requires a saving throw of 14 or higher. Contact poison usually comes as a salve/paste or powder. Ingested poisons require a save of 14 or higher. All prices are for a single application/use which is typically about one ounce.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('acid-organic', 'Acid (organic)', 'palladium-fantasy', 'magic', 200, NULL, NULL, NULL, 'Does 2D6 per melee round for four melees. Cost: 200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('acid-cleanser', 'Acid (cleanser)', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'Does 3D6 per melee round for three minutes. Cost: 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('acid-metal-dissolver', 'Acid (metal dissolver)', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, 'Does 3D6 per melee round for three minutes to metal. Does 2D4 damage for four melees to organic materials/leather/skin. Costs: 500 gold. Note: There is no saving throw against acids, but they stop burning as soon as the acid is washed away with soap and water or body lotion.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('contact-poison-numbstrike', 'Contact poison: Numbstrike', 'palladium-fantasy', 'magic', 150, NULL, NULL, NULL, 'Numbstrike: A blend of toxins that does 1D4 damage and causes the victim to temporarily lose feeling in his hands or extremities where the poison touched bare flesh. The numb fingers and/or arms have the following penalties: -20% on all skill performance and -1 to strike, parry and dodge. Numb feet and/or legs re264 duces speed by 30%. If rubbed into the eyes, the eyelids can barely remain opened as tiny slits, the eyes burn and water; penalties: -4 to initiative, strike, parry and dodge. Cost: 150 gold per single application.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('contact-poison-gut-wrench', 'Contact poison: Gut wrench', 'palladium-fantasy', 'magic', 250, NULL, NULL, NULL, 'Gut wrench: A toxin that does usually doesn''t cause serious damage but causes a severe headache and nausea for 4D6 minutes. Victims are -3 on initiative, -1 to strike, parry and dodge, 20% on speed and suffers from 1D4 cramps per minute. Each cramp cause one point of damage and causes the character to lose one melee attack/action. Cost: 250 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('contact-poison-wart-callo', 'Contact poison: Wart Callo', 'palladium-fantasy', 'magic', 120, NULL, NULL, NULL, 'Wart Callo: A blend of toxins that does 1D6 damage and causes itchy brown blotches to appear on the area of body exposed to the poison (typically the hands which then transfers it to parts of the face, arms and other extremities). The blotchy rash lasts for 1D4 days and makes the victim -1 on initiative (distracted by the itching). Cost: 120 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('contact-poison-witchbane', 'Contact poison: Witchbane', 'palladium-fantasy', 'magic', 200, NULL, NULL, NULL, 'Witchbane: A blend of toxins. Damage: 3D6 per melee round for two melees. Cost: 200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('basilisk-s-eye-blood-poison', 'Basilisk''s Eye (blood poison)', 'palladium-fantasy', 'magic', 200, NULL, NULL, NULL, 'A mixture of nerve toxins. Damage: 4D6 plus paralysis. Paralysis lasts for 2D4 minutes. Cost: 200 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('dragon-s-breath-blood-poison', 'Dragon''s Breath (blood poison)', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, 'A deadly blend of poisons. Damage: 6D6 every time it enters the bloodstream (each successful strike with a sword). Cost: 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('scorpion-s-blood-blood-poison', 'Scorpion''s Blood (blood poison)', 'palladium-fantasy', 'magic', 1000, NULL, NULL, NULL, 'Actually a mixture of scorpion, spider, and snake venom; yellow/green color. Damage: 4D6 points each time the poison is administered via cut/stab or injection. Cost: 150 gold. Effects: +2 on initiative, but -1 to strike, parry and dodge (the senses are heightened, increasing one''s initiative, but reducing coordination). Addicts suffer these penalties at all times and are very laid back and easy going. Reduces the M.E. by 2 points while addicted. Cost: 250 gold per dose. Kargalin (Kang, Zombie, Lightning) - Rare: This plant resembles a wild potato. The root is crushed, diluted with water, strained, then boiled into a concentrate. The result is brown colored crystals or powder. It is found only in scrub areas and around low water such as Ophid''s Grasslands and the Upper Western Empire. Addicts have a 140% chance of suffering from recurring flashbacks and withdrawal when placed under stress, with all the usual debilitating effects. Effects: 2D4 melee rounds after drinking a fraction of an ounce, diluted in a half pint of liquid, causes vivid hallucinations, intense emotions and loss of motor control (can barely crawl). Snorting a finger pinch will have the same result, only instantly. No initiative, -6 to strike, parry, dodge, all skills are -70% and speed and attacks per melee are reduced by -80% when under its influence. The drug''s effects last 1D4 hours. Highly addictive. Cost: 500 gold per half ounce. Approximately two doses per half ounce. Medina (Nirvana, Bliss) - Very Rare: This is made from a cactus-like plant. The leaves are crushed or pressed and the sap collected. It is then diluted with water, strained, and boiled twice to concentrate it, leaving a dry, white powder. One ounce of powder is yielded from two pounds of leaves. One half ounce of powder, diluted in a half pint of liquid, can be safely drunk to induce intense hallucinations, emotions, and muscle lock. Effects: This powerful hallucinogen makes all the person''s dreams, wants and desires seem as if they are real. During this time, no communication is possible with the person. The character exists in his own little dream world, oblivious to the real world around him. No initiative, -8 to strike, parry and dodge, -30% on all skills, and speed is -30%. If a psionic attempts to contact the victim in any way, there is a 1-38% chance that he will be caught in the mind numbing effects and experience the hallucinations of the drugged person as well. The effects last 1D6 hours and it is one of the most addictive drugs known. Mellina is so addictive that there is a 1-70% chance of addiction EACH time it is used. Once addicted, if the drug is not taken at least once a week, withdrawal occurs, often with fatal consequences. Addicts will be serene, easy going, function normally for the first 24 hours after taking the drug. With each passing day, the addict becomes increasingly irritable and is -1 on initiative and -10% on all skills, cumulative per day, until the next fix. Addicts will lie, cheat, steal and even murder to get a dose of Bliss, even if of good alignment, as he is now driven by needs that supersede his moral values. 265 Withdrawal is painful and occurs after one week of being drug free. In addition to the cumulative penalties noted previously, the addict is racked by high fever, delirium, severe vomiting and stomach cramps for 3D4+2 days (suffering 2D6 damage per day). During this time the person is virtually helpless and easily slain by enemies or may kill himself while delirious. Mellina is found only in the Baalgor Wastelands. Cost: 1000 gold per dose. Mind Alteration Drugs Fansolin (Mindbender) - Rare: The flowers of this tall plant are picked, crushed, and mixed with water. The mixture ferments for two months, is strained and distilled, and yields a purple liquid. Three pounds of plant material yields one ounce of drug. One half ounce taken straight or diluted with water will instill a hypnotic state that lasts for 1D4 hours. Effects: This mindbending state allows another person to command the victim to do anything. If the command is contrary to the drugged character''s beliefs, alignment, etc., he is allowed to save vs poisons (a 14 or higher). If successful, the victim can refuse the order, but must roll to save against each command. The drugged individual enjoys a feeling of complete euphoria and total loss of physical sensation. When the drug wears off, the character usually has no recollection of what happened while drugged. Addicts suffer memory loss, skills reduced by 5%, and M.E. is reduced 20%. It is found on the uppermost slopes of the mountains or in cooler climates in the Timiro Kingdom, Eastern Empire, Old Kingdom, and high on Mt. Nimro. Cost: 1000 gold per dose.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('jenelfin-vision', 'Jenelfin (Vision)', 'palladium-fantasy', 'magic', 9500, NULL, NULL, NULL, 'The drug is extracted from a bean on a tall, bushy plant. Picked when ripe, the beans are crushed and pressed to yield an oil. It is strained until there are no impurities in the golden transparent oil. Usually one pound (0.45 kg) of beans provides one ounce of oil. The oil extract is placed in a metal bowl and brought to a slow boil/simmer. This produces sweet smelling fumes which are inhaled. Best results are in a small enclosed room. Effects: After 1D4 melees, those breathing the fumes fall into a deep, almost coma-like sleep and experience vivid and often frightening dreams/hallucinations. While in this altered state the character enjoys a +10% bonus to commune with his god and/or +10% bonus to have a religious vision/divination. Furthermore, all skills increase by 5% and the character is +1 to strike, parry and dodge for 1D6 hours after the exhilarating experience. That having been said, each time the drug is used the character suffers 3D6 points of damage direct to hit points in the form of chest pains and there is a 1-20% chance of heart failure. Addicts suffer chronic heart trouble and develop permanent mental disorders. Fanatical clerics, shamans, and other users say the pain is the price one pays to talk to their god. Some claim one goes straight into the hands of their god if they die while using the drug. Usually people of good alignment will not use it except in the most desperate circumstances. It is only found in the Yin-Sloth Jungle, Southern part of the Land of the South Winds, and Floenry Isles. Cost: 1500 gold per dose. Yendari (Soulcatcher, Pawn) - Very Rare: Yendari is produced from a very rare, bushy plant that has long tap roots from 8 inches to 3 feet (0.27 m) and is found only in the deepest forests of the Yin-Sloth Jungles. It is very dangerous to produce, requiring gloves to be worn at every stage of preparation. The purple root must be gently dugout without damaging it. Washing will reveal darker purple nodules which must be removed without rupturing them. If cracked or ruptured, a transparent purple liquid sprays out of the nodule. Any contact with unprotected skin will cause instant death due to nerve poison! The nodules are then put in an enclosed press to safely crush the nodules and release the liquid. The resultant liquid and root pulp are placed in a sealed jar or glass and fermented for six months in a dark area - exposure to light ruins the batch at this stage. It is then carefully strained (it''s still deadly) and boiled to concentrate it. This also destroys the nerve toxin in the liquid. After evaporation, a fine crystal powder is produced. Effects: Half an ounce of yendari mixed into one cup of liquid will induce a trance-like state in the user. While in this state, the person remembers only peace and bliss, a sort of blank euphoria. However, while under the drug''s influence, the person also can also become extremely emotional and hostile. In this state, he or she will react in a very primal "Mr. Hyde" like way (miscreant alignment), responding to everything on a very base emotional level. The yendari also makes its user extremely vulnerable to psionic manipulation. Hypnotic suggestion, empathy, telepathic implants/suggestions and illusions can place the drugged individual under a psionic''s complete control. The person will obey any and all commands without compunction. Only characters with a P.E. over 16 are allowed a saving throw and then with no P.E. bonus. This includes the vilest deeds regardless of alignment and even against friends, family or party members. The state lasts 1D4 hours. The yendari user will recall absolutely nothing about what he did or experienced, remembering only total peace. Even a telepathic probe will provide no recollections other than dream-like flashes of incidents, but nothing comprehensible. Addicts must take the drug at least twice a week or suffer nausea and terrible headaches that make it difficult to think. All skills are performed at -15% during this period. If the drug is not available, the addict will fall into withdrawal within five or six days. The headaches will be so severe that all skills are -30%, speed is reduced by 30%, and the character is -2 to strike, parry and dodge. The headaches worsen until the person is violently ill with throbbing, excruciating migraines, insomnia, fever, stomach cramps and diarrhea. At this stage, all skills are reduced to 10%, the character has no initiative, speed is reduced by 60% and he is -6 to strike, parry or dodge. The severe withdrawal lasts 4D4 days. Note: The yendari addict is -6 to save vs psionics at all times while the drug is in his/her system. Cost: 5000 gold per dose. Other Types of Drugs AI-Kazin - Rare: The berries and leaves of this plant are dried and crushed into a coarse powder. It is brewed in one pint of water to one ounce of powder and ingested. This triples the normal rate of healing. It is found in the Northern Old Kingdom, Phi and Lopan. Cost: 600 gold per ounce. Rodoffrin - Uncommon: The leaves from this plant are mashed to a coarse paste which is sold in small jars. When applied to a wound it will stop further loss of blood (therefore, no further loss of hit points due to blood loss). This is handy if you are without the help of clergy, healers or magical means of healing. Rodoffrin is found in most cool forests in the east and north, but not in hot or dry areas. Cost: 375 gold per 4 ounce jar, good for approximately six applications. Lebarisine (Jumper) - Uncommon: This is a stimulant made from a mushroom that grows in shady, decaying areas of forests. It does not grow in hot, dry or humid climates. Dried, powdered and dissolved in water (usually it is one ounce to one gallon of liquid); a single dose usually requires drinking one pint. This will keep the user awake 4D6+4 hours, without him feeling the slightest bit tired or sleepy. Users are hyperactive, and unable to keep still. Prolonged usage will result in hallucinations, fatigue and weight loss of two pounds (0.9 kg) per week. When not high, the addict is extremely fatigued and groggy, needing twice as much sleep; -5% on all skills, speed is reduced by one-third and he is -4 on initiative. "Jumper" is often used by soldiers on watch or under siege, but it is illegal in most military camps. Cost: 400 gold per ounce. Wharifin (Downer, Dreamice) - Rare: This is a brown-green powder derived from a type of seaweed. It is collected, dried and powdered. Four pounds (1.8 kg) of plant yields 8 ounces of powder. It is not detectable when sprinkled on food, except for a slight, sweetish taste. In liquids, it dissolves clear with no taste. After 1D4 melee rounds, the victim falls into a deep slumber lasting 6D6 minutes. A double dose will induce a coma lasting 3D6 hours and has a possibility of killing the victim (roll to save vs coma/death to survive). 266 This plant is found only in scattered shallow seabeds off the coast of the Timiro Kingdom, Floenry Isles and parts of the coast of the Land of the South Winds, Cost: 650 gold per half ounce or one dose. Non-addictive. Gorvon (Bear, Lion''s Paw) - Uncommon: This drug is made from the massive seed pods of the gorvon plant. When ripe, the seeds are picked, dried and powdered. The powder is added to water, brewed, and ingested; typically one ounce per pint. The drink gives the user extra strength and endurance for approximately one hour. During that time, five points of strength is added to the character''s P.S. attribute. After the effects have worn off, the user is physically exhausted; P.S. attribute returns to normal and then temporarily drops -5 points, P.P. and speed are also reduced by -5; these penalties last until the character rests for 24 hours. If the user doesn''t rest within the next two hours for one full day (24 hours), he/she may collapse (85%) into a coma-like state (roll to save vs coma). Addicts suffer the penalties regardless of the amount of rest they may get. It is rumored that Wolfen take "Bear" before entering important battles (in reality, most Wolfen never touch the _ stuff, but Coyles often partake in it). The plant is found in the forests of the Northern Wilderness, Timiro Kingdom and the Eastern Territories. Cost: 850 gold per dose. Tershalin (Epim''s Tears) - Very Rare: This mixture is only made by a healing monastery on the Isle of Zy. It is made from a bushy plant whose flowers are white and teardrop shaped. The whole plant is picked, along with the flowers, dried and crushed. It is then diluted with distilled water, strained over very fine cheesecloth and boiled to concentrate it. This results in a white, crystalline powder; 4 pounds of plant results in one ounce of powder. This is truly a gift from Epim herself as Tershalin is a universal antidote to poisons. A dose of one half ounce to 4 ounces of liquid, taken orally, will negate poison if taken in time. It can also be mixed into Rodoffrin and sold as an ointment. Applying it to poisoned wounds will stop the poison and any bleeding. It is found growing in the rocky cliffs and stony areas along the shore of Zy. All money taken from the sale of Epim''s Tears goes to the upkeep of the abbey. Cost: 600 gold for a one ounce packet; 1200 gold for ointment (a one ounce jar is equal to two applications). Lavaryta (Psi-strength) - Super Rare: The plant, its location, and preparation of the drug is a secret held by one man and a few trusted associates. He is said to be named Darbor Shirak, a renowned Mind Mage. It is also said that he discovered the plant and, after years of research, perfected the production of the drug. Knowledgeable alchemists believe that it is the root of the plant that is picked, crushed and fermented in an unknown blend of liquids for three months. It is then distilled and dried into coarse, bluish crystals. This is all conjecture as only Darbor Shirak holds its secrets. One pinch, placed under the tongue or inhaled through the nose, will result in a slight dizziness. 1D4 melee rounds later, all senses are enhanced and the drug''s main effect takes place. This is the only drug found in the Palladium World that enhances the power of a psionic mind. It raises the I.S.P. of the person 1D4x10 points and increases the level of psionic powers by one level! The drug''s effects last for 1D4 hours. After it has worn off, the user is subject to severe headaches, nausea and fatigue. Worse, he cannot use his natural psionic powers for 24 hours unless he takes the drug again. There is also a 1-5% chance that an addict will permanently lose all psionic abilities after each use of the drug! Prolonged usage is also rumored to cause insanities. If a nonpsionic takes this drug, he falls into a catatonic state for 2D6 hours, but most recover without permanent damage. It is rumored that the only location of the plant is the Forest of Enchantment in the Old Kingdom. The only place to purchase the drug is through the most select alchemists in the City of Credia (Timiro Kingdom). Cost: 9500 gold per one quarter ounce (4 doses). Addiction is quick and terrible, occurring if the drug is used more than twice a month. Addicts must take the substance at least once a week. Negative Side Effects Include: Gains one phobia (roll on the phobia table), plus varying personality changes; roll on the following table once each day. 257 01-25 Extremely paranoid, trusts no one, including friends. Becomes secretive, sneaky and treacherous. 26-50 Befuddled, absent-minded, disoriented, difficulty in concentrating; -10% on all skills, -2 on initiative. 51-75 Megalomania: Exaggerated sense of self importance and power; -5% on all skills, +1 on initiative, +1 on all saving throws, and +1 to strike, parry, dodge, roll with impact and horror factor. Will believe himself to be invincible, jumping into the worst situations without fear. 76-00 Hallucinations: Usually about the object of his/her phobia or current danger. Will become uncontrollable; using psionic abilities to hide from, flee or combat the nonexistent danger. This is basically a self induced psionic illusion that appears terrifyingly real. Any telepathic communication/probe with the victim of a Lavaryta hallucination will subject that person to the addict''s mental illusions too. Hallucinations occur during periods of stress (1-35%) or when asleep (nightmares 150%). Natural Herbal Potions, Powders & Drugs All potions and powders are sold in a single dose, generally require 2-8 melee rounds to take effect, and their duration varies widely from person to person. Cost is in Eastern gold pieces. The following herbal items are made from natural substances and come in the form of powder, paste and/or potion/liquid. All must be ingested or injected and require a saving throw of 14 or higher. A successful save means no damage or effects. For easy use, they are listed by symptom followed by effect/penalties, duration and cost.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-blurred-vision', 'Herbal drug: Blurred vision', 'palladium-fantasy', 'magic', 150, NULL, NULL, NULL, '3D6 minutes, -3 to initiative, strike, parry, or dodge, also reduce speed by 10%. Cost: 150 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-convulsions', 'Herbal drug: Convulsions', 'palladium-fantasy', 'magic', 300, NULL, NULL, NULL, '2D4 melee rounds in which the victim is struck by uncontrollable seizures; reduce speed by 80%, reduce attacks per melee to one, no combat bonuses or skill performance. 1-40% chance of suffering 2D6 damage from injury during a seizure. Costs 300 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-coughing', 'Herbal drug: Coughing', 'palladium-fantasy', 'magic', 120, NULL, NULL, NULL, '5D6 minutes, irritates throat and sinuses; -1 to initiative and parry, -30 to prowl. Cost: 120 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-sneezing', 'Herbal drug: Sneezing', 'palladium-fantasy', 'magic', 120, NULL, NULL, NULL, '4D6 minutes, -1 to initiative, parry and dodge, -20 to prowl; costs 120 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-dizziness', 'Herbal drug: Dizziness', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, '6D6 minutes, speed reduced by 50%, -3 on initiative, -2 to strike, parry, and dodge. Cost: 500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-fever', 'Herbal drug: Fever', 'palladium-fantasy', 'magic', 250, NULL, NULL, NULL, '1D4 hours, -2 on initiative, -1 to strike, parry, or dodge. Cost: 250 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-itching-mild', 'Herbal drug: Itching (mild)', 'palladium-fantasy', 'magic', 60, NULL, NULL, NULL, '4D6 minutes of discomfort; -1 to initiative. Cost: 60 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-mental-confusion', 'Herbal drug: Mental confusion', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, '3D4 minutes in which the victim has no sense of direction, is easily startled, -6 on initiative, 1 -60% chance of memory loss (temporary), roll for each subject. Cost: 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-nausea', 'Herbal drug: Nausea', 'palladium-fantasy', 'magic', 100, NULL, NULL, NULL, '6D6 minutes; reduce speed by half, -5% on skill performance and -2 on initiative. Cost: 100 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-paralysis', 'Herbal drug: Paralysis', 'palladium-fantasy', 'magic', 800, NULL, NULL, NULL, '2D4 minutes; total incapacitation. Costs: 800 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-sleep', 'Herbal drug: Sleep', 'palladium-fantasy', 'magic', 500, NULL, NULL, NULL, 'Renders victim unconscious for 2D4 minutes. Cost: 500 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-stomach-cramps', 'Herbal drug: Stomach cramps', 'palladium-fantasy', 'magic', 400, NULL, NULL, NULL, '2D4 minutes, reduce speed by half, reduce attacks per melee by half, -2 on initiative, -1 to strike, parry, or dodge. Cost: 400 gold.', 'Palladium Fantasy RPG p.249-267');

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, description, source_book)
  VALUES ('herbal-drug-weakness', 'Herbal drug: Weakness', 'palladium-fantasy', 'magic', 200, NULL, NULL, NULL, '3D4 minutes, feels week and nauseous; reduce speed by half, reduce P.E. duration (vs fatigue) by half, -4 to damage, -1 to strike and parry. Costs: 200 gold.', 'Palladium Fantasy RPG p.249-267');


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS magic_items_total FROM gear WHERE source_book = 'Palladium Fantasy RPG p.249-267';
SELECT category, count(*) AS n FROM gear WHERE source_book = 'Palladium Fantasy RPG p.249-267' GROUP BY category;
SELECT count(*) AS priced FROM gear WHERE source_book = 'Palladium Fantasy RPG p.249-267' AND cost IS NOT NULL;
SELECT count(*) AS suits_with_both_numbers FROM gear
 WHERE source_book = 'Palladium Fantasy RPG p.249-267' AND ar IS NOT NULL AND sdc IS NOT NULL;
SELECT count(*) AS a_magic_row_that_claims_to_be_armour FROM gear
 WHERE source_book = 'Palladium Fantasy RPG p.249-267' AND category = 'magic' AND (ar IS NOT NULL OR sdc IS NOT NULL);

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-pf-magic-items.sql');
