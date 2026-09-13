-- The Necromancer's component price list, from Rifts World Book 18: Mystic
-- Russia printed 107. 41 new gear rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-mystic-russia-necromancy-components.sql
--
-- The book has a TEXT LAYER; offset +1, so printed 107 is cache p108. It is not
-- on the welded or glyph-corrupt list, and it IS on the digit-substitution one.
--
-- TEN OF THE FORTY-ONE PRICES ARE DICE, AND EVERY ONE OF THEM IS CIPHERED.
-- The page prints them with 1 as `!` and 0 as `O`, so they were read through
-- BOOK-INGEST-AUDIT F53 rather than off the glyphs:
--
--   !D6xlOO   -> 1D6x100    Claw: Animal, Wings: Bird (large)
--   !D4xlOO   -> 1D4x100    Claw: Bird (large), Hooves: Animal, Tail: Monkey
--   2D6xlOO   -> 2D6x100    Claw: Ogre/Troll/Giant, Tongue: Humanoids
--   2D4xlOO   -> 2D4x100    Horn: Animal
--   2D4xlOOO  -> 2D4x1000   Horn: Supernatural Being
--   !D6xlOOO  -> 1D6x1000   Wings: Animal
--
-- A render cannot fix these and re-caching cannot either: the substitution is
-- in the INK, and `!D6xlOO` has no other reading. That is the whole reason
-- `substituted_digits` is a separate manifest key from `corrupt_pages` - the
-- two faults need opposite remedies.
--
-- A DICE PRICE IS NOT A NUMBER AND DOES NOT GO IN `cost`. Those ten rows carry
-- cost NULL and state the expression in cost_note. The other 31 carry the
-- printed figure, which for most of them is a FLOOR - the page writes
-- "500,000+ credits" - and the "+", the ranges and the two prices that top out
-- at "1D6 million" are all in cost_note beside it. `Super-Hide Armor` is the
-- catalog's precedent for a dice component of a price living in cost_note.
--
-- THREE PRICING RULES APPLY TO THE WHOLE PAGE and are repeated in every row's
-- cost_note, because that is where a reader is when the number matters:
--
--   "The cost can be as much as four times greater depending on the demand,
--    situation and exactly who the deceased was."
--   "The costs to Necromancers is usually 50% higher because the component has
--    greater value to the character and shop owners take advantage of that.
--    However, charging more than 50% above common market value is rare for fear
--    of retribution from the sorcerer."
--   "Selling such items to a magic shop is likely only to command 10% of the
--    average selling price."
--
-- THESE ARE NOT THE PALLADIUM FANTASY COMPONENTS AND MUST NOT BE MERGED WITH
-- THEM. The catalog already holds `Dragon claws`, `Dragon eye`, `Dragon tongue`
-- and their siblings from `Palladium Fantasy RPG p.249-267`, priced in GOLD at
-- quite different figures - a dragon's eye is 20,000 there and 50,000+ here.
-- A gold price is not a credit price, and the two lists name their rows
-- differently on purpose: this page is `Part: Source`, that one is
-- `Source part`. Checked --remote 2026-09-13: 0 name collisions and 0 slug
-- collisions across all 41, and no duplicate slug within the list.
--
-- Category is 'magic', which is where this catalog files a component:
-- `dragon-claws`, `unicorn-horn-whole` and `unicorn-horn-powdered` are all
-- 'magic' (read --remote 2026-09-13).

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, is_mega_damage, description, source_book) VALUES
('brain-cyclops', 'Brain: Cyclops', 'rifts', 'magic', 500000, '500,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a cyclops, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-dragon', 'Brain: Dragon', 'rifts', 'magic', 750000, '750,000+ credits; the printed figure is a floor, and the highest single price on the page. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a dragon, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-operator', 'Brain: Operator', 'rifts', 'magic', 45000, '45,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of an Operator, bought as a Necromancer''s component. The page prices four human brains by what the dead person COULD DO rather than by what they were.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-scholar', 'Brain: Scholar', 'rifts', 'magic', 25000, '25,000+ credits; the printed figure is a floor, and the cheapest of the seven brains. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a scholar, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-scientist', 'Brain: Scientist', 'rifts', 'magic', 35000, '35,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a scientist, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-warrior', 'Brain: Warrior', 'rifts', 'magic', 35000, '35,000+ credits; the printed figure is a floor, the same as a scientist''s. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a warrior, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('brain-practitioner-of-magic', 'Brain: Practitioner of Magic', 'rifts', 'magic', 200000, '200,000+ credits; the printed figure is a floor, and eight times a scholar''s. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The brain of a practitioner of magic, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-animal', 'Claw: Animal', 'rifts', 'magic', NULL, '1D6x100 credits - a rolled price, so no single figure is stored. The page prints it as "!D6xlOO", the digit substitution of BOOK-INGEST-AUDIT F53. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An ordinary animal''s claw, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-bird-large', 'Claw: Bird (large)', 'rifts', 'magic', NULL, '1D4x100 credits - a rolled price, so no single figure is stored. The page prints it as "!D4xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A large bird''s claw, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-creature-of-magic', 'Claw: Creature of Magic', 'rifts', 'magic', 250000, '250,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The claw of a creature of magic - the page gives a sphinx as its example. Bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-dragon-hatchling', 'Claw: Dragon Hatchling', 'rifts', 'magic', 200000, '200,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon hatchling''s claw, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-dragon-adult', 'Claw: Dragon Adult', 'rifts', 'magic', 600000, '600,000 to a million credits; the stored figure is the bottom of that range. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An adult dragon''s claw, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-lesser-supernatural-beings-demon', 'Claw: Lesser Supernatural Beings/Demon', 'rifts', 'magic', 50000, '50,000 to 100,000 credits; the stored figure is the bottom of that range. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The claw of a lesser supernatural being or demon, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-greater-supernatural-beings', 'Claw: Greater Supernatural Beings', 'rifts', 'magic', 200000, '200,000 to 500,000 credits; the stored figure is the bottom of that range. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The claw of a greater supernatural being, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('claw-ogre-troll-giant', 'Claw: Ogre, Troll, Giant', 'rifts', 'magic', NULL, '2D6x100 credits - a rolled price, so no single figure is stored. The page prints it as "2D6xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The claw of an ogre, a troll or a giant, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('eye-dragon', 'Eye: Dragon', 'rifts', 'magic', 50000, '50,000+ credits; the printed figure is a floor. NOTE the catalog also holds "Dragon eye" at 20,000 from the Palladium Fantasy RPG, priced in GOLD - a different list and a different currency. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon''s eye, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('eye-humanoid', 'Eye: Humanoid', 'rifts', 'magic', 2000, '2,000+ credits; the printed figure is a floor, and the cheapest thing the page prices in credits. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A humanoid eye, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('eye-supernatural-being', 'Eye: Supernatural Being', 'rifts', 'magic', 40000, '40,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The eye of a supernatural being, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('horn-animal', 'Horn: Animal', 'rifts', 'magic', NULL, '2D4x100 credits - a rolled price, so no single figure is stored. The page prints it as "2D4xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An ordinary animal''s horn, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('horn-supernatural-being', 'Horn: Supernatural Being', 'rifts', 'magic', NULL, '2D4x1000 credits - a rolled price, so no single figure is stored. The page prints it as "2D4xlOOO", and it is the only FOUR-zero substitution on the page. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The horn of a supernatural being, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('horn-dragon', 'Horn: Dragon', 'rifts', 'magic', 30000, '30,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon''s horn, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('horn-ki-lin', 'Horn: Ki-lin', 'rifts', 'magic', 20000, '20,000+ credits; the printed figure is a floor, and half a unicorn''s. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A ki-lin''s horn, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('horn-unicorn', 'Horn: Unicorn', 'rifts', 'magic', 40000, '40,000+ credits; the printed figure is a floor. NOTE the catalog also holds "Unicorn horn whole" and "Unicorn horn, powdered" from the Palladium Fantasy RPG, priced in GOLD. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A unicorn''s horn, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('hooves-animal', 'Hooves: Animal', 'rifts', 'magic', NULL, '1D4x100 credits - a rolled price, so no single figure is stored. The page prints it as "!D4xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An ordinary animal''s hooves, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('hooves-ki-lin', 'Hooves: Ki-lin', 'rifts', 'magic', 30000, '30,000 credits. This is one of only five prices on the page printed WITHOUT a trailing plus, so it is a figure rather than a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A ki-lin''s hooves, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('hooves-unicorn', 'Hooves: Unicorn', 'rifts', 'magic', 50000, '50,000 credits, printed without a trailing plus. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A unicorn''s hooves, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tail-dragon', 'Tail: Dragon', 'rifts', 'magic', 70000, '70,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon''s tail, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tail-manticore', 'Tail: Manticore', 'rifts', 'magic', 18000, '18,000 credits, printed without a trailing plus. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A manticore''s tail, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tail-malignous', 'Tail: Malignous', 'rifts', 'magic', 45000, '45,000 credits, printed without a trailing plus. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A malignous'' tail, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tail-monkey', 'Tail: Monkey', 'rifts', 'magic', NULL, '1D4x100 credits - a rolled price, so no single figure is stored. The page prints it as "!D4xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A monkey''s tail, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tongue-supernatural-creatures', 'Tongue: Supernatural Creatures', 'rifts', 'magic', 150000, '150,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The tongue of a supernatural creature, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tongue-dragon', 'Tongue: Dragon', 'rifts', 'magic', 500000, '500,000+ credits; the printed figure is a floor. NOTE the catalog also holds "Dragon tongue" at 50,000 from the Palladium Fantasy RPG, priced in GOLD. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon''s tongue, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tongue-faerie-folk', 'Tongue: Faerie Folk', 'rifts', 'magic', 50000, '50,000 credits, printed without a trailing plus. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The tongue of a faerie folk, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('tongue-humanoids', 'Tongue: Humanoids', 'rifts', 'magic', NULL, '2D6x100 credits - a rolled price, so no single figure is stored. The page prints it as "2D6xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A humanoid tongue - the page names D-Bees and elves - bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-animal', 'Wings: Animal', 'rifts', 'magic', NULL, '1D6x1000 credits - a rolled price, so no single figure is stored. The page prints it as "!D6xlOOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An animal''s wings - the page names a gryphon and a dragondactyl - bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-bird-large', 'Wings: Bird (large)', 'rifts', 'magic', NULL, '1D6x100 credits - a rolled price, so no single figure is stored. The page prints it as "!D6xlOO". Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A large bird''s wings, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-creatures-of-magic', 'Wings: Creatures of Magic', 'rifts', 'magic', 275000, '275,000+ credits; the printed figure is a floor. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The wings of a creature of magic - the page gives a sphinx as its example. Bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-dragon-hatchling', 'Wings: Dragon Hatchling', 'rifts', 'magic', 200000, '200,000+ credits; the printed figure is a floor, the same as a hatchling''s claw. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'A dragon hatchling''s wings, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-dragon-adult', 'Wings: Dragon Adult', 'rifts', 'magic', 850000, '850,000 to 1D6 million credits; the stored figure is the bottom of that range, and the ceiling is ROLLED. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'An adult dragon''s wings, bought as a Necromancer''s component. The most valuable single component on the page.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-lesser-supernatural-beings', 'Wings: Lesser Supernatural Beings', 'rifts', 'magic', 250000, '250,000 to 800,000 credits; the stored figure is the bottom of that range. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The wings of a lesser supernatural being, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107'),
('wings-greater-supernatural-beings', 'Wings: Greater Supernatural Beings', 'rifts', 'magic', 500000, '500,000 to 1D6 million credits; the stored figure is the bottom of that range, and the ceiling is ROLLED. Page rule: up to four times more by demand, 50% more to a Necromancer, and a magic shop buys at about 10%.', 0, 'The wings of a greater supernatural being, bought as a Necromancer''s component.', 'Rifts World Book 18: Mystic Russia p.107');

-- Read the result back. Every want is counted off the page, not the database.
--
-- TWO OF THESE WANTS WERE WRONG ON THE FIRST --remote APPLY and are corrected
-- here; nothing else in this file changed. The dearest component is the adult
-- dragon's wings at 850,000, not the dragon brain at 750,000, and the Palladium
-- Fantasy row is named "Unicorn horn, whole" WITH A COMMA. Both wrong sentences
-- also reached cost_note and are corrected by
-- fix-mystic-russia-component-price-claims.sql, which sorts after this file. A
-- readback constant writes no row, so correcting it leaves a rebuild producing
-- exactly the rows production holds - which is the reason the INSERT above is
-- untouched.
SELECT 'the 41 component rows' AS assertion, count(*) AS got, 41 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

SELECT 'thirty-one carry a credit figure' AS assertion, count(*) AS got, 31 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107' AND cost IS NOT NULL;

-- 500000+750000+45000+25000+35000+35000+200000 = 1590000 (brains)
-- 250000+200000+600000+50000+200000            = 1300000 (claws)
-- 50000+2000+40000                             =   92000 (eyes)
-- 30000+20000+40000                            =   90000 (horns)
-- 30000+50000                                  =   80000 (hooves)
-- 70000+18000+45000                            =  133000 (tails)
-- 150000+500000+50000                          =  700000 (tongues)
-- 275000+200000+850000+250000+500000           = 2075000 (wings)
SELECT 'and those figures sum to the page' AS assertion, sum(cost) AS got, 6060000 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

-- The ten ciphered dice prices. A row with neither a cost nor a dice expression
-- would mean a price was dropped on the way in.
SELECT 'ten carry a rolled price instead' AS assertion, count(*) AS got, 10 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107'
   AND cost IS NULL AND instr(cost_note, 'rolled price') > 0;

SELECT 'the cheapest thing the page prices in credits is the humanoid eye' AS assertion, min(cost) AS got, 2000 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

SELECT 'and the dearest is the adult dragon wings' AS assertion, max(cost) AS got, 850000 AS want
  FROM gear WHERE source_book = 'Rifts World Book 18: Mystic Russia p.107';

-- The Palladium Fantasy component rows are a DIFFERENT list in a DIFFERENT
-- currency and must still be sitting beside these, untouched.
SELECT 'the Palladium Fantasy components are untouched' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE name IN ('Dragon claws', 'Dragon eye', 'Dragon tongue', 'Unicorn horn, whole')
   AND source_book = 'Palladium Fantasy RPG p.249-267';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-mystic-russia-necromancy-components.sql');
