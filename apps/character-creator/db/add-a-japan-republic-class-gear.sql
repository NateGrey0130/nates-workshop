-- Rifts World Book 8: Japan - the items the Republic classes carry that no
-- catalog row covered: 8 new rows, shipped with the classes that grant them so
-- none of them needs a stub. See apps/character-creator/docs/surveys/japan.md,
-- step 6.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-japan-republic-class-gear.sql
--
-- Each is named in a class's equipment list and priced nowhere in the book, so
-- cost is NULL. The four cyborg body armor plates print M.D.C. and no price; the cyber-samurai armor's 1D6x10+60 M.D.C. is dice and is in the
-- description, not the integer column. It sorts before every class script
-- (add-a-).

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('micro-film-camera', 'Micro-Film Camera', 'rifts', 'gear', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A palm-sized micro-film camera, standard kit for the Republic''s tech-ninja, ninja juicers, ninja crazies and ninja ''borgs and techno-wizards (printed 83 and the ninja classes that follow). The book gives no price or other figures.', 'Rifts World Book 8: Japan p.83'),
('small-crowbar', 'Small Crowbar', 'rifts', 'gear', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A small crowbar, part of the Republic ninja classes'' standard kit (printed 83 and the ninja classes that follow). The book gives no price or other figures.', 'Rifts World Book 8: Japan p.83'),
('universal-headjack-and-ear-implant', 'Universal Headjack and Ear Implant', 'rifts', 'cybernetics', NULL, NULL, 'No price printed in this book; the Rifts RPG prices its implants.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'The head jack and ear implant the cyberoid starts with (printed 79), the standard computer and communications link of the Rifts RPG''s cybernetics. This book prints no price or figures for it.', 'Rifts World Book 8: Japan p.79'),
('cyber-samurai-armor', 'Cyber-Samurai Armor', 'rifts', 'armor', NULL, NULL, 'No price printed; issued to the cyber-samurai.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'The cyber-samurai''s high-tech mega-damage armor styled after a samurai''s (printed 82): 1D6x10+60 M.D.C. The book gives no weight, A.R. or price; a cyber-samurai may wear one of the other armor types instead.', 'Rifts World Book 8: Japan p.82'),
('cyborg-body-armor-light-undercover', 'Cyborg Body Armor: Light Undercover (Police)', 'rifts', 'armor', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 50, 'Cyborg body armor (printed 97): extra plates attached to a Republic cyborg for combat; a dragon ''borg has its armor built into the body instead. Ichto and H-Brand sell infantry versions with 20% more M.D.C. No price is printed.', 'Rifts World Book 8: Japan p.97'),
('cyborg-body-armor-light-infiltration', 'Cyborg Body Armor: Light Infiltration (Police and Military)', 'rifts', 'armor', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 110, 'Cyborg body armor (printed 97): extra plates attached to a Republic cyborg for combat; a dragon ''borg has its armor built into the body instead. Ichto and H-Brand sell infantry versions with 20% more M.D.C. No price is printed.', 'Rifts World Book 8: Japan p.97'),
('cyborg-body-armor-light-infantry', 'Cyborg Body Armor: Light Infantry (Military)', 'rifts', 'armor', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 150, 'Cyborg body armor (printed 97): extra plates attached to a Republic cyborg for combat; a dragon ''borg has its armor built into the body instead. Ichto and H-Brand sell infantry versions with 20% more M.D.C. No price is printed.', 'Rifts World Book 8: Japan p.97'),
('cyborg-body-armor-heavy-infantry', 'Cyborg Body Armor: Heavy Infantry (Military)', 'rifts', 'armor', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 240, 'Cyborg body armor (printed 97): extra plates attached to a Republic cyborg for combat; a dragon ''borg has its armor built into the body instead. Ichto and H-Brand sell infantry versions with 20% more M.D.C. No price is printed.', 'Rifts World Book 8: Japan p.97');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 8 rows of add-a-japan-republic-class-gear.sql are in' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE slug IN ('micro-film-camera', 'small-crowbar', 'universal-headjack-and-ear-implant', 'cyber-samurai-armor', 'cyborg-body-armor-light-undercover', 'cyborg-body-armor-light-infiltration', 'cyborg-body-armor-light-infantry', 'cyborg-body-armor-heavy-infantry') AND source_book LIKE 'Rifts World Book 8: Japan p.%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-japan-republic-class-gear.sql');
