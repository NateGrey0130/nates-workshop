-- Rifts World Book 6: South America - four gear rows its R.C.C.s issue, which
-- the first gear script (add-south-america-gear.sql) did not carry because the
-- book prints them only inside the classes' Standard Equipment lines:
--
--   * the Grimbor's Cibolan body armor and yumbuto club (printed 138)
--   * the NE-10 magazine the Grimbor carries eight of (priced on printed 139)
--   * the Pogtalian Dragon Slayer's dragon-skin armor (printed 136)
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-south-america-rcc-gear.sql
--
-- ALL FOUR ARE NEW - searched --remote by name and slug on 2026-09-25. Written
-- as real rows rather than the class-import STUB, because the book states each
-- one's figures. None is priced as an item: the armors and the club are
-- Cibolan issue, so cost is NULL and cost_note says why. The magazine's price
-- is the book's own: a full 20-round NE-10 magazine costs 800 credits.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('cibolan-grimbor-body-armor', 'Cibolan Grimbor Body Armor', 'rifts', 'armor', NULL, NULL, 'Issued to Cibolan grimbor scouts and warriors; no price given.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 120,
 'Body armor specially designed for the grimbor ape-men of Cibola, with a built-in force field that adds 35 M.D.C. on top of the armor''s 120. Built for the grimbor''s frame and unusable by normal humanoids.', 'Rifts World Book 6: South America p.138'),
('yumbuto-club', 'Yumbuto Club', 'rifts', 'weapon', NULL, NULL, 'Issued to Cibolan grimbor scouts and warriors; no price given.', '3D6 M.D. on a hit', 1, NULL, NULL, NULL, NULL, NULL, NULL,
 'A high-tech, energized version of the grimbor''s traditional club, carried by Cibola''s grimbor scouts and warriors.', 'Rifts World Book 6: South America p.138'),
('ne-10-plasma-cartridge-magazine', 'NE-10 Plasma Cartridge Magazine', 'rifts', 'gear', NULL, 800, 'A full magazine costs 800 credits; each round costs 40.', NULL, 0, NULL, '20 plasma cartridges', NULL, NULL, NULL, NULL,
 'A 20-shot magazine of the thick impact-primed cartridges the Naruni NE-10 Plasma Cartridge Rifle fires. The ammunition is sold only by Naruni Enterprises, so in South America it is found almost nowhere but Cibola.', 'Rifts World Book 6: South America p.139'),
('dragon-skin-armor', 'Dragon-Skin Armor', 'rifts', 'armor', NULL, NULL, 'Issued to Cibolan-trained Pogtalians; no price given. The book gives 250 to 300 M.D.C.; mdc holds the low end.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 250,
 'Armor made from dragon skin, worn by the Pogtalian dragon slayers Cibola trains. The book gives it 250 to 300 M.D.C.', 'Rifts World Book 6: South America p.136');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the four R.C.C. gear rows are in' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE slug IN ('cibolan-grimbor-body-armor', 'yumbuto-club', 'ne-10-plasma-cartridge-magazine', 'dragon-skin-armor');

INSERT INTO data_script_runs (filename) VALUES ('add-south-america-rcc-gear.sql');
