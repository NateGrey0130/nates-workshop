-- Book of Magic: five spells only this book prints
-- 5 spells rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~108-book-of-magic-five-spells.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO spells (name, level, ppe, ppe_note, variant_note, source, source_book, system, range, duration, damage, saving_throw, area_of_effect, casting_time, description, same_spell_as, tradition, ppe_permanent) VALUES
  ('Living Fire: Impervious to Fever', 6, 20, NULL, NULL, 'import', 'Rifts Book of Magic p.165', 'rifts', 'Self or other by touch.', '24 hours per level of the spell caster''s experience.', NULL, 'Not Applicable.', NULL, NULL, 'The recipient cannot catch any disease whose chief symptom is a fever - rheumatic, scarlet, yellow and hemorrhagic fevers among them. Suited to those nursing the sick.', NULL, 'living-fire', NULL),
  ('Nature: Keep (Preserve) Food', 5, 12, NULL, NULL, 'import', 'Rifts Book of Magic p.171', 'rifts', 'Touch or from 10 feet (3 m) away per level of the spell caster.', 'Special.', NULL, 'Not applicable.', NULL, NULL, 'Keeps fresh food free of bacteria and decay for one week with no refrigeration or sealed container, or for three weeks if it is also refrigerated or sealed airtight. Works on fresh baked goods, prepared meats, stews, soups and most other foods.', NULL, 'nature', NULL),
  ('Bone: Chicken Bone', 7, 20, NULL, NULL, 'import', 'Rifts Book of Magic p.192', 'rifts', 'Touch.', 'One hour per level of the spell caster.', NULL, 'None, requires willing participants.', NULL, NULL, 'Bone Magic, new in this book; used one of two ways. Wishbone & Luck: two people (never the Necromancer) pull a dried wishbone apart as the spell is cast. The one left with the bigger piece has good luck for the duration: +2 on initiative, +5% to skill performance, +2 to save vs Horror Factor, poison and disease. The other has bad luck: -2 on initiative, -5% to skill performance, -2 to save vs Horror Factor, poison and disease. Chicken Soup: a single chicken bone makes a cauldron or large pot of nourishing, meatless broth, ready in about 20 minutes.', NULL, 'bone', NULL),
  ('Bone: Mend Living Bone', 7, 20, '20 for mortal bones; 100 to mend M.D.C. bone.', NULL, 'import', 'Rifts Book of Magic p.192-193', 'rifts', 'Touch or 10 feet (3 m) and line of sight of the Necromancer.', 'Permanent.', NULL, 'Not applicable.', NULL, NULL, 'Bone Magic, new in this book. Limitations: one target per spell casting. Sets and mends fractured or broken bones in a living subject at once, restoring 1D6 Hit Points; it mends bone only, so torn muscle, skin and other wounds from the injury still need treatment or other healing. It can also rejoin old broken bones into a whole one, up to half a human skeleton per spell, with no sign of the break.', NULL, 'bone', NULL),
  ('Bone: Shape Bone', 13, 80, NULL, NULL, 'import', 'Rifts Book of Magic p.198', 'rifts', 'Self (and the bone one is working with).', 'Five minutes per level of experience.', NULL, 'Not applicable.', NULL, NULL, 'The Necromancer can squeeze, bend and mold bone like clay or soft rubber - into a dagger, sword or club, parts for a bone staff or body armor (joined by other magic), or tools such as needles, hooks and utensils. One complete bone per casting, whatever its size.', NULL, 'bone', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 5 spells rows are in' AS assertion, count(*) AS got, 5 AS want
  FROM spells WHERE name IN ('Living Fire: Impervious to Fever', 'Nature: Keep (Preserve) Food', 'Bone: Chicken Bone', 'Bone: Mend Living Bone', 'Bone: Shape Bone') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~108-book-of-magic-five-spells.sql');
