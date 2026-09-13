-- The twelve named magic items of the Russian Mystic Kuznya, from Rifts World
-- Book 18: Mystic Russia printed 125-126. Twelve new gear rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-russia-kuznya-items.sql
--
-- The book has a TEXT LAYER; offset +1, so printed 125 is cache p126 and
-- printed 126 is cache p127. Neither page is on the welded or glyph-corrupt
-- list. Both carry this book's digit substitution: printed 124 prints
-- "!D4xlO M.D. costs 350 P.P.E." for 1D4x10, and the Serpent Rod's Palladium
-- Fantasy note prints "!D6xlO damage" for 1D6x10. No figure below was read
-- through it - the item damages are all plain NDN forms - but the pages it sits
-- on are the ones these rows came from, so it is recorded.
--
-- WHAT THE PAGES HOLD, AND WHAT IS NOT HERE:
--
--   printed 124-125  the ENCHANTMENTS a Mystic Kuznya applies - Indestructible,
--                    Flaming Weapon, Silent Armor, Fast Forge, the per-metal
--                    bonuses for gold, silver, bronze, copper, iron and steel.
--                    NOT gear rows: they are things the class does to an item
--                    that already exists, and they belong to the class entry
--                    rather than to the catalog.
--   printed 125      "Notable Lesser Magic Items" - five named items
--   printed 125-126  "Greater Magical Metal Items of the Mystic Kuznya" -
--                    seven named items
--
-- ONLY TWO OF THE TWELVE CARRY A MARKET PRICE. The rest are priced in the
-- P.P.E. it costs a Mystic Kuznya to FORGE them, which is not money and does
-- not belong in `cost`. Those rows carry cost NULL - 171 gear rows already do -
-- and the forging cost is stated in cost_note, where a reader sees it and no
-- shop arithmetic picks it up as credits.
--
-- Every row is category 'magic', which is where this catalog files enchanted
-- armour and swords: Armor Fetish, Dragon Bone Armor Fetish, Great Armor
-- Fetish and Valkyrie Magic Sword are all 'magic' rather than 'armor' or
-- 'weapon' (read --remote 2026-09-13).
--
-- No production row collided with any slug or name below (checked --remote
-- 2026-09-13; 0 slug collisions and 0 name collisions across all twelve).

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, ar, sdc, mdc, description, source_book) VALUES
('unbreakable-md-plow', 'Unbreakable (M.D.) Plow', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 100 P.P.E. to forge.', NULL, 1, NULL, NULL, NULL, NULL, 'A strong Mega-Damage plow that cuts through earth and strikes tree roots, stumps and rock without breaking. Very popular among farmers.', 'Rifts World Book 18: Mystic Russia p.125'),
('magic-md-scissors', 'Magic M.D. Scissors', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 90 P.P.E. to forge.', '1D4 M.D. per cut or stab', 1, NULL, NULL, NULL, NULL, 'Mega-Damage blades that stab or cut through M.D.C. material under an eighth of an inch thick, and through most S.D.C. material thinner than one inch.', 'Rifts World Book 18: Mystic Russia p.125'),
('magic-md-bolt-cutters', 'Magic M.D. Bolt Cutters', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 120 P.P.E. to forge.', '1D6+6 M.D.', 1, NULL, NULL, NULL, NULL, 'Cuts M.D.C. chain, cable or rods less than two inches in diameter, and S.D.C. material up to four inches like butter. Bolt cutters cut bolts, links, rods and cable; they cannot cut in a straight line the way scissors do.', 'Rifts World Book 18: Mystic Russia p.125'),
('magic-hammer', 'Magic Hammer', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 30 P.P.E. to forge - the cheapest of the twelve.', '2D6 S.D.C.', 0, NULL, NULL, NULL, NULL, 'A super-strong but lightweight hammer that never wears out and never breaks. It is still an S.D.C. item - the only one of the Mystic Kuznya''s twelve named items that does not deal Mega-Damage.', 'Rifts World Book 18: Mystic Russia p.125'),
('magic-md-arrows', 'Magic M.D. Arrows', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 30 P.P.E. per THREE arrows.', '1D6 M.D., or 2D6 M.D. if made of steel', 1, NULL, NULL, NULL, NULL, 'Three metal arrows turned into Mega-Damage projectiles per 30 P.P.E. The metal changes what they do, at no extra charge: gold is +2 to strike; silver has its usual effect on supernatural creatures; bronze flies twice as far; copper bursts into flame, is +2 to damage and sets combustibles alight; iron damages otherwise impervious energy beings, entities, Midnight Demons, ghosts and spirits; steel is +1 to strike and does 2D6 M.D. instead of 1D6.', 'Rifts World Book 18: Mystic Russia p.125'),
('angel-horseshoes', 'Angel Horseshoes', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 60 P.P.E. per set of four.', NULL, 0, NULL, NULL, NULL, NULL, 'A set of four horseshoes that lets a horse or similar riding animal run 30% faster and leap 50% higher and farther without additional stress or fatigue. The animal also tires at half the usual rate, so it can run twice as long, and the shoes themselves last three times longer than ordinary ones.', 'Rifts World Book 18: Mystic Russia p.125'),
('dragon-armor-kuznya', 'Dragon Armor', 'rifts', 'magic', 20, 50000, '50,000 to 70,000+ credits, and rare - the book''s figure is a floor. Costs a Mystic Kuznya 210 P.P.E. to forge.', NULL, 1, NULL, NULL, NULL, 200, 'A suit of metal scale armour, also known as Jazeraint, impervious to dragon''s breath of any kind and to heat and fire of all kinds, including Mega-Damage plasma blasts and magical fire. The upper body and 70% of the suit must be scale; the rest may be plate, chain mail or lighter flexible material over the arms, legs and groin. 200-300 M.D.C. and 20-25 pounds (9 to 11.2 kg); fair mobility, with -10% to prowl, climb, swim, acrobatics and gymnastics.', 'Rifts World Book 18: Mystic Russia p.126'),
('angels-armor', 'Angel''s Armor', 'rifts', 'magic', 30, 85000, '85,000 credits and up, and rare - the book''s figure is a floor. Costs a Mystic Kuznya 280 P.P.E. to forge.', NULL, 1, NULL, NULL, NULL, 300, 'Traditional plate and chain with polished gold chest, shoulders and upper arms, metal vambraces, and silver chain mail under the arms. A sun, an angel or a cross radiating light is always part of the chest design, and that design works as a holy symbol: it warns creatures of darkness that they face a champion of light and holds lesser vampires and others repelled by holy symbols at bay. The wearer can fly at will, carrying up to 200 pounds (90 kg) beyond his own body and armour, and can cast Globe of Daylight and Turn Dead three times per 24 hours. ONLY A CHARACTER OF GOOD ALIGNMENT can draw on the flight, turn dead and daylight. 300-400 M.D.C. and 30-35 pounds (13.6 to 15.7 kg); fair mobility, with -15% to prowl, climb, swim, acrobatics and gymnastics.', 'Rifts World Book 18: Mystic Russia p.126'),
('dragonblade', 'Dragonblade', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 200 P.P.E. to forge.', '1D6 M.D., or 4D6 M.D. against dragons, fire elementals and other supernatural creatures of magic', 1, NULL, NULL, NULL, NULL, 'A sword of bronze, copper or red metal. Its wielder is resistant to Mega-Damage fire and takes half damage from it. Adapted to a non-M.D.C. setting such as the Palladium Fantasy world, any sword strike above eight penetrates a dragon''s, elemental''s or demon''s natural A.R. and does damage.', 'Rifts World Book 18: Mystic Russia p.126'),
('spiritblade', 'Spiritblade', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 300 P.P.E. to forge.', '3D6 M.D., or 5D6 M.D. against energy beings, ghosts, spirits, entities, elementals and all ethereal beings', 1, NULL, NULL, NULL, NULL, 'A blue-grey sword made of iron. The 5D6 applies to every ethereal being, life essences and Astral Travellers included. Adapted to a non-M.D.C. setting such as the Palladium Fantasy world, any strike above six penetrates the spirit and does damage, provided it does not dodge or parry.', 'Rifts World Book 18: Mystic Russia p.126'),
('serpent-rod', 'Serpent Rod', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 380 P.P.E. to forge - the most expensive of the twelve.', '2D6 M.D., 4D6 M.D. against supernatural beings, and 8D6 M.D. against serpents', 1, NULL, NULL, NULL, NULL, 'An iron staff, surprisingly light, useful as both a weapon and a magic item; it is the staff drawn in the illustration of the Born Mystic. The doubled 8D6 covers dragons, the demonic Serpent Hound, the Wolf-Serpent and the Worms of Taut. It also makes its wielder impervious to snake venom - including the magical creations of the Snake to Sword spell - gives +3 to save against any type of poison (spoiling and disease excluded), and stops snakes biting the character for any reason. Worms of Taut are reluctant to attack it at all: no initiative, and all their combat bonuses and bite damage are halved. Adapted to a non-M.D.C. setting, any strike above 10 penetrates the creature''s Armor Rating and does 1D6x10 damage to serpents, 3D6 to mortals.', 'Rifts World Book 18: Mystic Russia p.126'),
('metal-claw-wand', 'Metal Claw Wand', 'rifts', 'magic', NULL, NULL, 'No market price is printed. Costs a Mystic Kuznya 160 P.P.E. to forge.', '4D6 M.D., and +1D6 M.D. if made of steel', 1, NULL, NULL, NULL, NULL, 'Something like a fireplace poker: a long thin metal rod ending in an open, clawing animal''s paw - a bear''s, a tiger''s, a monster''s, or an eagle''s talons. It stokes fires and is impervious to Mega-Damage fire, serves as a metalworking tool, and fights. The claw opens and closes to grasp, hold and carry items beyond the smith''s reach. The metal changes what it does: gold is +1 to strike, copper is +1 to parry, and iron can grab and hold energy beings, entities and ghosts.', 'Rifts World Book 18: Mystic Russia p.126');

-- Read the result back. Every want is from the pages, not the database.
SELECT 'the twelve new rows' AS assertion, count(*) AS got, 12 AS want
  FROM gear WHERE source_book IN ('Rifts World Book 18: Mystic Russia p.125', 'Rifts World Book 18: Mystic Russia p.126');

SELECT 'five are the Lesser Magic Items of printed 125, plus the horseshoes' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.125';

SELECT 'and six are the Greater Magical Metal Items of printed 126' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.126';

-- ONLY the two suits of armour carry money. If a later pass puts a credit price
-- on a forging cost, this fails.
SELECT 'only the two armours carry a credit price' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE cost IS NOT NULL
   AND source_book IN ('Rifts World Book 18: Mystic Russia p.125', 'Rifts World Book 18: Mystic Russia p.126');

SELECT 'and their prices are the printed floors' AS assertion, sum(cost) AS got, 135000 AS want
  FROM gear WHERE cost IS NOT NULL
   AND source_book IN ('Rifts World Book 18: Mystic Russia p.125', 'Rifts World Book 18: Mystic Russia p.126');

-- The Magic Hammer is the one S.D.C. item among twelve Mega-Damage ones, which
-- is the easiest thing on these pages to transcribe wrongly.
SELECT 'the Magic Hammer is the only S.D.C. item of the twelve' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE is_mega_damage = 0 AND damage IS NOT NULL
   AND source_book IN ('Rifts World Book 18: Mystic Russia p.125', 'Rifts World Book 18: Mystic Russia p.126');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-russia-kuznya-items.sql');
