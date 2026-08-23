-- The rest of the Types of Armor table, and the rest of the shields.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-pf-armor-types.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-pf-armor-types.sql
--
--   14 suits    Palladium Fantasy RPG p.270
--    4 shields  Palladium Fantasy RPG p.60
--
-- THE TABLE ON PRINTED 270 HAS SIXTEEN ROWS and the catalog held five of them,
-- so a Palladium character could buy soft leather, hard leather, studded
-- leather, chain mail or scale mail and nothing else. No cloth, no padding, no
-- splint, no plate, and not one of the half suits - which is most of what a
-- poor character or a heavily armoured one would actually wear.
--
-- WHAT THIS SCRIPT REFUSES TO RUN AGAINST. The five rows already in the catalog
-- come from the same table these are read off, so they are a check on the
-- reading: the generator compares all five against the printed figures and
-- stops if any has drifted. All five matched.
--
--   soft-leather      A.R. 10  S.D.C. 20   75 gold
--   hard-leather      A.R. 11  S.D.C. 30  150 gold
--   studded-leather   A.R. 13  S.D.C. 38  200 gold
--   chain-mail        A.R. 14  S.D.C. 44  280 gold
--   scale-mail        A.R. 15  S.D.C. 75  650 gold
--
-- THREE HALF SUITS HAVE NO PRICE, and keep none. The table prices the metal
-- half suits, but the three leather ones are given only in the prose beneath
-- it - "half suit of Soft Leather has 10 S.D.C. & A.R. 6" - with no figure. A
-- number there would be invented. The same prose says a half suit of padded,
-- quilt or cloth "isn't worthwhile", so none is imported.
--
-- PROWL PENALTIES RIDE IN THE DESCRIPTION, as they already do for chain and
-- scale: -5% in studded leather, -10% in chain or scale mail, and -15% prowl
-- with -20% to climb or swim in full splint or plate. The A.R. and S.D.C. are
-- columns because the sheet does arithmetic with them; a percentage penalty
-- has nowhere to go yet.
--
-- SHIELDS ARE ON PRINTED 60, under W.P. Shield, not in the armour table. The
-- catalog had the small wood-and-leather one and mentioned the metal-plated
-- version inside its description; that version is now its own row, along with
-- all three large shields. The large iron shield needs a P.S. of 22 to use.

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('cloth-armor', 'Cloth Armor', 'palladium-fantasy', 'armor', 5, 6, 20, NULL, 2, 'Full suit of cloth armour, the cheapest protection there is. A full suit covers as much of the body as possible: leggings, knee, shoulder and elbow guards, helmet, coif, hauberk, arm bands, gloves and surcoat. Magic S.D.C. cannot be added to cloth fabrics.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('padded-armor', 'Padded or Quilt Armor', 'palladium-fantasy', 'armor', 8, 15, 50, NULL, 5, 'Full suit of padded or quilted armour. Light armour: comfortable and unrestrictive, with no penalties even for those untrained in armour. A half suit of padded, quilt or cloth is not worthwhile.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('soft-leather-half', 'Soft Leather (Half Suit)', 'palladium-fantasy', 'armor', 6, 10, NULL, 'the book prices the full suit at 75 gold and gives no figure for the half', NULL, 'Half suit of soft leather, protecting chest, neck, joints and head. Light armour, so it carries no prowl or movement penalty.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('hard-leather-half', 'Hard Leather (Half Suit)', 'palladium-fantasy', 'armor', 8, 12, NULL, 'the book prices the full suit at 150 gold and gives no figure for the half', NULL, 'Half suit of hard leather, protecting chest, neck, joints and head. Light armour, so it carries no prowl or movement penalty.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('studded-leather-half', 'Studded Leather (Half Suit)', 'palladium-fantasy', 'armor', 9, 20, NULL, 'the book prices the full suit at 200 gold and gives no figure for the half', NULL, 'Half suit of studded leather, protecting chest, neck, joints and head. -5% to prowl.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('chain-mail-half', 'Chain Mail (Half Suit)', 'palladium-fantasy', 'armor', 9, 20, 170, NULL, 18, 'Half suit of chain mail, protecting chest, neck, joints and head. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('double-mail', 'Double Mail', 'palladium-fantasy', 'armor', 15, 55, 340, NULL, 50, 'Full suit of double mail. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('double-mail-half', 'Double Mail (Half Suit)', 'palladium-fantasy', 'armor', 10, 28, 200, NULL, 20, 'Half suit of double mail, protecting chest, neck, joints and head. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('scale-mail-half', 'Scale Mail (Half Suit)', 'palladium-fantasy', 'armor', 11, 35, 300, NULL, 20, 'Half suit of scale mail, protecting chest, neck, joints and head. Chain and metal armours clank and jingle: -10% to prowl, swim or climb.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('splint-armor', 'Splint Armor', 'palladium-fantasy', 'armor', 16, 82, 700, NULL, 50, 'Full suit of splint armour. Heavy armour: -15% to prowl and -20% to climb, scale walls or swim.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('splint-armor-half', 'Splint Armor (Half Suit)', 'palladium-fantasy', 'armor', 12, 40, 400, NULL, 22, 'Half suit of splint armour, protecting chest, neck, joints and head. Heavy armour: -15% to prowl and -20% to climb, scale walls or swim.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('plate-and-chain', 'Plate and Chain', 'palladium-fantasy', 'armor', 15, 100, 800, NULL, 52, 'Plate and chain, made as a full suit only. Heavy armour: -15% to prowl and -20% to climb, scale walls or swim.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('plate-armor', 'Plate Armor', 'palladium-fantasy', 'armor', 17, 160, 1000, NULL, 58, 'Full suit of plate, the best protection the Palladium world sells. Heavy armour: -15% to prowl and -20% to climb, scale walls or swim.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('plate-armor-half', 'Plate Armor (Half Suit)', 'palladium-fantasy', 'armor', 14, 60, 450, NULL, 20, 'Half suit of plate, protecting chest, neck, joints and head. Heavy armour: -15% to prowl and -20% to climb, scale walls or swim.', 'Palladium Fantasy RPG p.270');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('small-shield-metal', 'Small Shield (Metal Plated)', 'palladium-fantasy', 'armor', NULL, 50, 65, NULL, NULL, 'A small wood and metal plated shield. Small shields can be thrown about 15 feet (4.6 m), inflicting 1D6 damage. Hitting or butting somebody with a shield does 2D4 damage.', 'Palladium Fantasy RPG p.60');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('large-shield', 'Large Shield', 'palladium-fantasy', 'armor', NULL, 60, 75, NULL, NULL, 'A large wood and leather shield. No large shield can be thrown. Hitting or butting somebody with a shield does 2D4 damage.', 'Palladium Fantasy RPG p.60');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('large-shield-metal', 'Large Shield (Metal Plated)', 'palladium-fantasy', 'armor', NULL, 100, 110, NULL, NULL, 'A large wood and metal plated shield. No large shield can be thrown. Hitting or butting somebody with a shield does 2D4 damage.', 'Palladium Fantasy RPG p.60');

INSERT OR IGNORE INTO gear (slug, name, system, category, ar, sdc, cost, cost_note, weight_lbs, description, source_book)
  VALUES ('large-shield-iron', 'Large Iron Shield', 'palladium-fantasy', 'armor', NULL, 130, 180, NULL, NULL, 'A large iron shield. Requires a P.S. of 22 or higher to use; otherwise -4 to parry. No large shield can be thrown.', 'Palladium Fantasy RPG p.60');


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS pf_armour_rows FROM gear
 WHERE system = 'palladium-fantasy' AND category = 'armor';
SELECT count(*) AS from_the_types_of_armor_table FROM gear WHERE source_book = 'Palladium Fantasy RPG p.270';
SELECT count(*) AS shields FROM gear WHERE source_book = 'Palladium Fantasy RPG p.60';
SELECT count(*) AS armour_missing_a_number FROM gear
 WHERE source_book = 'Palladium Fantasy RPG p.270' AND (ar IS NULL OR sdc IS NULL);
SELECT count(*) AS priced FROM gear
 WHERE source_book IN ('Palladium Fantasy RPG p.270', 'Palladium Fantasy RPG p.60') AND cost IS NOT NULL;
SELECT name, ar, sdc, cost FROM gear
 WHERE system = 'palladium-fantasy' AND category = 'armor' AND ar IS NOT NULL
 ORDER BY ar, sdc;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-pf-armor-types.sql');
