-- The 32 properties an alchemist can put into ordinary gear.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Migration 035 creates the table this fills.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-pf-enchantments.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-pf-enchantments.sql
--
--   11 armour features   printed 249, four to a suit, cumulative
--   21 weapon properties  printed 249-250, three to a weapon, cumulative
--
-- THESE ARE NOT ITEMS. "Cloak of Armor, 20,000 gold" is a gear row; "+1 A.R.,
-- 4,000 gold" is a modifier that can sit on any of the armour rows the catalog
-- already has. Modelling the second as the first would mean a catalog entry per
-- combination of every feature with every suit.
--
-- COST IS THE LOW END, cost_note carries the rest, the same division
-- gear.cost/cost_note already uses. Four of these need it: Magic S.D.C. is
-- priced per twenty points with different caps for heavy and for leather, the
-- Flaming Sword is priced by its damage die, and the flaming knife and ball &
-- chain are priced as a set including the fireproof scabbard or case.
--
-- FOUR CARRY MECHANICAL BONUSES, in the same JSON block skills.bonuses uses and
-- validated through the same validateBonuses, so derive.js needs no new cases:
--
--   invisible-weapon        +3 initiative, +2 strike and parry
--   eternally-sharp-blade   +3 damage
--   additional-damage       +1D6 damage
--   thunder-hammer          +2D6 damage
--
-- The dice ones are stored as dice - "2d6" - rather than as a number they are
-- not. The bonus group has accepted a dice expression since the Godling's
-- "+1D4 on initiative" made it a hard parse error, so this needed nothing new.
--
-- The rest are abilities rather than modifiers - three fireballs a day, double
-- damage to demons, teleport three times daily - and stay prose, because a
-- number would be a lie about what the book grants. Invisible Weapon's bonuses
-- are conditional in the same way ("only against an opponent who cannot see the
-- invisible") and its description says so; the numbers are stored because the
-- common case is that they apply.
--
-- TWO NAMES APPEAR ON BOTH SIDES. Color and Continual Glow are printed once for
-- armour and once for weapons, at different prices - 600 against 500, and both
-- at 1,200 - so they are separate rows with prefixed slugs rather than one row
-- pretending the halves agree.
--
-- NOT IMPORTED, so that "we skipped them" reads as a decision: rune and holy
-- weapons are GENERATED from a tier and a table of powers rather than listed,
-- and importing them would invent about forty items the book does not print;
-- curses are effects applied to a person or an object, with no price and no
-- weight, and are closer to a spell than to a sword; transformable weapons are
-- a kind of weapon rather than a property, and the book says outright that one
-- "cannot have any other magic properties".

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('armor-rating-enhancement', 'Armor Rating Enhancement', 'armor', 4000, NULL, 4, NULL, NULL, 'Magically increases the armor''s natural A.R. by one point (maximum one).', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('buoyancy', 'Buoyancy', 'armor', 5000, NULL, 4, NULL, NULL, 'The armor floats in water even if full plate. The wearer can swim on the surface but cannot dive or swim underwater, because the armor holds him afloat.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('armor-color', 'Color', 'armor', 600, '600 gold for a single color', 4, NULL, NULL, 'Vibrant colors that never fade and are otherwise difficult or impossible to make out of metal: bright white, pitch black, vibrant greens, blues, reds, oranges, yellows, violets, or pure silver and gold (the last two are colors, not the metal, though they may fool many).', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('armor-continual-glow', 'Continual Glow', 'armor', 1200, '1,200 gold for a soft glow, 2,000 for a strong bright one', 4, NULL, NULL, 'The armor radiates a magical glow, usually purchased to impress or intimidate those who see it and may assume it is more than it seems. Amber, white, light blue or light red. A bright glow is not recommended.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('armor-fire-resistant', 'Fire Resistant', 'armor', 1500, NULL, 4, NULL, NULL, 'Normal fire does half damage. Magic fire does full damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('armor-impervious-to-fire', 'Impervious to Fire', 'armor', 12000, NULL, 4, NULL, NULL, 'Normal fire does no damage; magic fires inflict half.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('invisibility-on-armor', 'Invisibility on Armor', 'armor', 12000, NULL, 4, 'Any type of armor other than padded.', NULL, 'Only the wearer, or those who can see the invisible, can see the armor.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('lightweight-armor', 'Lightweight', 'armor', 6000, NULL, 4, NULL, NULL, 'Half normal weight. All penalties from armor encumbrance are reduced by half.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('magic-sdc', 'Magic S.D.C.', 'armor', 2000, '2,000 gold per 20 S.D.C., to a 200 S.D.C. maximum on heavy armor and 100 on leather and chain mail', 4, 'Cannot be used on cloth fabrics.', NULL, 'Additional S.D.C. added to ordinary armor in increments of 20 points. Magic S.D.C. cannot be repaired except by magic.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('noiseless-armor', 'Noiseless', 'armor', 12000, NULL, 4, NULL, NULL, 'The armor makes no sound; the wearer suffers no penalty to prowl.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('weightless-armor', 'Weightless', 'armor', 15000, NULL, 4, NULL, NULL, 'The armor weighs no more than one ounce. No movement or encumbrance penalty, and the prowl penalty is halved (unless also noiseless), even in full plate.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('additional-damage', 'Additional Damage', 'weapon', 8000, NULL, 3, NULL, '{"combat":{"damage":"1d6"}}', 'One die of damage (1D6) is added to the weapon''s normal damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('blinding-flash', 'Blinding Flash', 'weapon', 4000, NULL, 3, NULL, NULL, 'Three times daily, the same as the 4th level spell.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('weapon-color', 'Color', 'weapon', 500, NULL, 3, NULL, NULL, 'Any color, usually for dramatic effect: blood red, crimson, light blue, dark blue, solid black, gold, silver.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('weapon-continual-glow', 'Continual Glow', 'weapon', 1200, NULL, 3, NULL, NULL, 'The weapon radiates a soft magical glow, usually purchased to impress or intimidate an opponent. Amber, white, light blue or light red.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('weapon-impervious-to-fire', 'Impervious to Fire', 'weapon', 8000, NULL, 3, NULL, NULL, 'The weapon cannot be melted, even by magic.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('indestructible', 'Indestructible', 'weapon', 30000, NULL, 3, NULL, NULL, 'Cannot be destroyed by any means except by an alchemist, which takes 12 hours.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('invisible-weapon', 'Invisible Weapon', 'weapon', 25000, NULL, 3, NULL, '{"combat":{"initiative":3,"strike":2,"parry":2}}', 'Only the wielder can see the weapon, making it easy to conceal. The bonuses apply only against an opponent who cannot see the invisible.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('demon-slayer', 'Demon Slayer', 'weapon', 20000, NULL, 3, NULL, NULL, 'Normal damage to all creatures except demons, to which it inflicts double damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('deevil-slayer', 'Deevil Slayer', 'weapon', 18000, NULL, 3, NULL, NULL, 'Normal damage to all creatures except deevils, to which it inflicts double damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('dragon-slayer', 'Dragon Slayer', 'weapon', 25000, NULL, 3, NULL, NULL, 'Normal damage to all creatures except dragons and sea serpents, to which it inflicts double damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('eternally-sharp-blade', 'Eternally Sharp Blade', 'weapon', 25000, NULL, 3, 'Blade weapons only - sword, spear and the like.', '{"combat":{"damage":3}}', 'A blade that never dulls and is +3 to damage.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('flaming-ball-and-chain', 'Flaming Ball & Chain', 'weapon', 35000, 'the set, including the case', 3, 'Chain weapons only.', NULL, 'A chain weapon with a ball of flame, doing 4D6 damage (maximum). Comes with a covering/case impervious to fire.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('flaming-knife', 'Flaming Knife', 'weapon', 25000, 'the set, including the scabbard', 3, 'Knives only.', NULL, 'A knife of magic flame extending from a handle impervious to fire, doing 2D6 damage (maximum). Comes with a scabbard impervious to fire.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('flaming-sword', 'Flaming Sword', 'weapon', 40000, '40,000 gold at 4D6; 50,000 at 5D6; 60,000 at 6D6, which is the maximum', 3, 'Swords only.', NULL, 'A sword of magic flame extending from a handle impervious to fire. Standard damage 4D6. Comes with a scabbard impervious to fire.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('returns-to-wielder-when-thrown', 'Returns to Wielder When Thrown', 'weapon', 50000, NULL, 3, 'Throwable weapons only - most knives, small axes, hammers and javelins.', NULL, 'The weapon returns to the thrower immediately after striking, on a mental command. Counts as one melee attack. Maximum range 120 feet (36.5 m).', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('spits-fire-balls', 'Spits Fire Balls', 'weapon', 35000, NULL, 3, NULL, NULL, 'Shoots fire balls three times per day. Range 60 feet (18.3 m), damage 3D6+2.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('spits-lightning', 'Spits Lightning', 'weapon', 45000, NULL, 3, NULL, NULL, 'Shoots a lightning bolt three times a day. Range 40 feet (12.2 m), damage 3D6+6.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('teleports-wielder', 'Teleports Wielder', 'weapon', 200000, NULL, 3, NULL, NULL, 'The owner can teleport three times daily up to five miles (8 km), with the same limitations as the teleport spell. Very rare.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('thunder-hammer', 'Thunder Hammer', 'weapon', 30000, NULL, 3, 'Blunt weapons only, excluding ball & chain types.', '{"combat":{"damage":"2d6"}}', 'The weapon inflicts an extra 2D6 damage and lets out a booming thunderclap each time it strikes or is struck.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('turns-holder-invisible', 'Turns Holder Invisible', 'weapon', 50000, NULL, 3, NULL, NULL, 'On a mental command the weapon turns whoever holds its handle invisible - the wielder, or others he lets grasp it. Two people for a sword, hammer or chain weapon, four for a staff, spear or polearm. Three times per 24 hours, lasting 10 minutes.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('turns-holder-fire-resistant', 'Turns Holder Fire Resistant', 'weapon', 12000, NULL, 3, NULL, NULL, 'Normal fire does half damage and magic fire full, four times daily, lasting 20 minutes.', 'palladium-fantasy', 'Palladium Fantasy RPG p.249-250');


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS enchantments_total FROM enchantments;
SELECT applies_to, count(*) AS n, min(cost) AS cheapest, max(cost) AS dearest
  FROM enchantments GROUP BY applies_to;
SELECT count(*) AS carrying_bonuses FROM enchantments WHERE bonuses IS NOT NULL;
SELECT count(*) AS wrong_cap FROM enchantments
 WHERE (applies_to = 'armor' AND max_per_item <> 4)
    OR (applies_to = 'weapon' AND max_per_item <> 3);
SELECT count(*) AS missing_a_source FROM enchantments WHERE source_book IS NULL OR system IS NULL;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-pf-enchantments.sql');
