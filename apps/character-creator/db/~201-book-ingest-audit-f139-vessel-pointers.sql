-- BOOK-INGEST-AUDIT F139: gear rows pointing at the Serpent Power Armor, the Samurai SAMAS and two Japan Glitter Boys
-- 4 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~201-book-ingest-audit-f139-vessel-pointers.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('vernulian-serpent-power-armor', 'Vernulian Serpent Power Armor', 'rifts', 'vehicle', NULL, NULL, 'No price printed. Military use only: the Vernulian military''s armor, not sold.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 300, 'The Vernulian military''s power armor, for military use only (printed 212). Its M.D.C. by location is the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 30: D-Bees of North America p.212', 'vernulian-serpent-power-armor'),
  ('at-samurai-samas-pa-10a', 'ArmaTech "Samurai Class" SAMAS Power Armor (PA-10A)', 'rifts', 'vehicle', 340, 1600000, '1.6 million credits new, full power, with particle beam rifle. Rarely on the black market, usually 3-4 million there. Issued to the SAMAS Samurai Pilot O.C.C. for field use; military property.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 290, 'The Republic of Japan''s SAMAS, issued to the SAMAS Samurai Pilot O.C.C. for field use (printed 91). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 8: Japan p.134-135', 'at-samurai-samas-pa-10a'),
  ('usa-g10a1-point-glitter-boy', '"Point" Glitter Boy (USA-G10A1)', 'rifts', 'vehicle', 2000, NULL, 'No price printed. Used exclusively by the Republic of Japan military. Very rare.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 480, 'The Republic of Japan''s reconnaissance Glitter Boy, one of the three models a Glitter Force Trooper may be issued for field use (printed 93-94). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 8: Japan p.137-140', 'usa-g10a1-point-glitter-boy'),
  ('usa-g10a2-hawkeye-glitter-boy', '"Hawkeye" Glitter Boy (USA-G10A2)', 'rifts', 'vehicle', 2400, NULL, 'No price printed. Used exclusively by the Republic of Japan military. Extremely rare.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 770, 'The Republic of Japan''s anti-aircraft Glitter Boy, one of the three models a Glitter Force Trooper may be issued for field use (printed 93-94). Its M.D.C. by location and weapon systems are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 8: Japan p.140-142', 'usa-g10a2-hawkeye-glitter-boy');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 4 gear rows are in' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE slug IN ('vernulian-serpent-power-armor', 'at-samurai-samas-pa-10a', 'usa-g10a1-point-glitter-boy', 'usa-g10a2-hawkeye-glitter-boy') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~201-book-ingest-audit-f139-vessel-pointers.sql');
