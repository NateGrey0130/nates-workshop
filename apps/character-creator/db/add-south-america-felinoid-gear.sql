-- Rifts World Book 6: South America - two cat warrior armors the Felinoid
-- R.C.C.s of Omagua are issued, which the book prints only inside their
-- Standard Equipment lines:
--
--   * the Flying Tiger's custom-fitted cat warrior body armor (printed 110)
--   * the Hunter Cat's heavy cat warrior armor (printed 114)
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-south-america-felinoid-gear.sql
--
-- BOTH ARE NEW - searched --remote by name and slug on 2026-09-25. Written as
-- real rows rather than the class-import STUB, because the book states each
-- one's M.D.C. Neither is priced: both are a Felinoid's starting kit, so cost
-- is NULL and cost_note says why. They are two rows, not one, because the book
-- gives them different M.D.C. and the Flying Tiger's is cut for its gliding
-- membrane.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('flying-tiger-cat-warrior-body-armor', 'Flying Tiger Cat Warrior Body Armor', 'rifts', 'armor', NULL, NULL, 'A Flying Tiger''s starting kit; no price given.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 60,
 'Custom-fitted M.D.C. body armor made for the Flying Tigers of Omagua, cut to leave the underarm gliding membrane free and to allow maximum movement.', 'Rifts World Book 6: South America p.110'),
('heavy-cat-warrior-armor', 'Heavy Cat Warrior Armor', 'rifts', 'armor', NULL, NULL, 'A Hunter Cat''s starting kit; no price given.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 90,
 'Heavy M.D.C. armor worn by the Hunter Cats of Omagua, the Felinoids'' heavily muscled warrior caste.', 'Rifts World Book 6: South America p.114');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the two Felinoid armors are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('flying-tiger-cat-warrior-body-armor', 'heavy-cat-warrior-armor');

INSERT INTO data_script_runs (filename) VALUES ('add-south-america-felinoid-gear.sql');
