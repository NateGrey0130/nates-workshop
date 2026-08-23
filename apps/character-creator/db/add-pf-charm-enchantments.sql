-- The 30 powers that go into a ring, and they are not rings.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Migration 036 widens applies_to to accept 'charm'.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-pf-charm-enchantments.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-pf-charm-enchantments.sql
--
-- WHY THESE ARE ENCHANTMENTS AND NOT ITEMS, in the book's own words, printed
-- 253:
--
--   "The following magic effects can be PLACED IN rings, bracelets, charms,
--    and medallions. They cannot be instilled in weapons."
--   "A maximum of three different powers can be placed in any one enchanted
--    item, but most have only one or two."
--
-- Same shape as the armour features and the weapon properties: a property with
-- a price and a cap, instilled into an ordinary object. Importing "Ring of
-- Chameleon" as a gear row would invent a name the book never prints, and would
-- have no way to say that one ring carries three of these at once.
--
-- max_per_item is 3, which the book states for this family directly, and
-- happens to match the weapon cap rather than the armour one.
--
-- THREE CARRY REAL SAVE BONUSES and two deliberately do not:
--
--   protection-from-spell-magic   saves.spell_magic +1
--   protection-from-psionics      saves.psionics    +1
--   protection-from-wards         saves.wards       +1
--
--   protection-from-circles       +1 (or +2) - PROSE
--   protection-from-witches       +1          - PROSE
--
-- The last two are as real in the book as the first three. They are stored as
-- prose because the sheet's save block covers spell magic, ritual magic, wards,
-- psionics and horror factor, and there is no save against circles or against
-- witches for a number to land on. A bonus on a key nothing renders is stored,
-- ignored, and indistinguishable from one that works - so the generator refuses
-- any save key the sheet does not show, rather than letting one through
-- silently.
--
-- COST IS THE LOW END. Two are priced in tiers - Protection from Circles is
-- 35,000 for +1 and 70,000 for +2, Protection from Undead 10,000 to hold the
-- undead at bay and 45,000 to also resist a vampire's gaze - and cost_note
-- carries the second figure.
--
-- DURATION AND FREQUENCY stay in the description. "20 melees, twice daily" is
-- two numbers and a unit; a column for each would be three columns used by one
-- family of one book, and the sheet has nowhere to put them yet.

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-chameleon', 'Chameleon', 'charm', 40000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 20 melees, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-diminish', 'Diminish', 'charm', 47000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Shrinks the wearer to six inches tall. Lasts 15 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-fleet-feet', 'Fleet Feet', 'charm', 30000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-fly', 'Fly', 'charm', 60000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Flight as an eagle. Lasts 60 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-impervious-to-fire', 'Impervious to Fire', 'charm', 30000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts 60 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-impervious-to-cold', 'Impervious to Cold', 'charm', 28000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts 60 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-impervious-to-horror-factor', 'Impervious to Horror Factor', 'charm', 28000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts 30 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-invisibility', 'Invisibility', 'charm', 46000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-levitation', 'Levitation', 'charm', 25000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, four times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-metamorphosis-animal', 'Metamorphosis: Animal', 'charm', 65000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Rare. Lasts 30 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-metamorphosis-human', 'Metamorphosis: Human', 'charm', 95000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Rare. Lasts 30 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-multiple-image', 'Multiple Image', 'charm', 30000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 20 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-nightvision', 'Nightvision', 'charm', 15000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Nightvision to 60 feet (18.3 m). Lasts 60 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-circles', 'Protection from Circles', 'charm', 35000, '35,000 gold for +1 to save, 70,000 for +2', 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'A constant +1 to save against circles, or +2 at the higher price. Stored as prose rather than as a bonus because the app models no save against circles; the sheet''s save block covers spell magic, ritual magic, wards, psionics and horror factor.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-spell-magic', 'Protection from Spell Magic', 'charm', 35000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', '{"saves":{"spell_magic":1}}', 'A constant +1 to save against spell magic.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-psionics', 'Protection from Psionics', 'charm', 35000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', '{"saves":{"psionics":1}}', 'A constant +1 to save against psionics.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-undead', 'Protection from Undead', 'charm', 10000, '10,000 gold to hold them at bay; 45,000 to also be impervious to a vampire''s hypnotic gaze and mind control', 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Holds the undead at bay. The dearer version also makes the wearer impervious to a vampire''s hypnotic gaze and mind control.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-wards', 'Protection from Wards', 'charm', 35000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', '{"saves":{"wards":1}}', 'A constant +1 to save against wards.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-protection-from-witches', 'Protection from Witches', 'charm', 28000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'A constant +1 to save against witches. Stored as prose rather than as a bonus because the app models no save against witches.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-resist-cold', 'Resist Cold', 'charm', 4000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts two hours, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-resist-fire', 'Resist Fire', 'charm', 4000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts two hours, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-sense-evil', 'Sense Evil', 'charm', 6000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 8 melee rounds, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-sense-magic', 'Sense Magic', 'charm', 8000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 8 melee rounds, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-sense-traps', 'Sense Traps', 'charm', 50000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Lasts 10 minutes, twice daily. Range: a 12 foot (3.6 m) radius.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-size-of-the-behemoth', 'Size of the Behemoth', 'charm', 35000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-superhuman-strength', 'Superhuman Strength', 'charm', 40000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-telepathy', 'Telepathy', 'charm', 40000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-teleport', 'Teleport', 'charm', 200000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'Rare. Instant, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-tongues', 'Tongues', 'charm', 20000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, three times daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');

INSERT OR IGNORE INTO enchantments
  (slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses, description, system, source_book)
  VALUES ('charm-x-ray-vision', 'X-Ray Vision', 'charm', 40000, NULL, 3, 'Rings, bracelets, charms and medallions. Cannot be instilled in weapons.', NULL, 'As the spell. Lasts 10 minutes, twice daily.', 'palladium-fantasy', 'Palladium Fantasy RPG p.253');


-- Read the result back rather than trusting the exit code.
SELECT applies_to, count(*) AS n FROM enchantments GROUP BY applies_to ORDER BY applies_to;
SELECT count(*) AS charm_total FROM enchantments WHERE applies_to = 'charm';
SELECT count(*) AS charm_with_a_save_bonus FROM enchantments
 WHERE applies_to = 'charm' AND bonuses IS NOT NULL;
SELECT count(*) AS wrong_cap FROM enchantments WHERE applies_to = 'charm' AND max_per_item <> 3;
SELECT count(*) AS the_two_earlier_families_survived_the_rebuild FROM enchantments
 WHERE applies_to IN ('weapon', 'armor');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-pf-charm-enchantments.sql');
