-- The three skills Rifts Dimension Book 1: Wormwood adds that the catalog does
-- not already hold.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-wormwood-skills.sql
--
-- The book is a SCAN with no text layer. These were read from the OCR cache
-- (.cache/books/ww, 300dpi) and cross-checked against the page renders.
-- Printed-to-PDF offset is ZERO in this book, verified on six folios.
--
-- THREE, not seven. The book's O.C.C. skill lists name four more that read as
-- new and are not - each is a spelling the catalog already holds, and a second
-- row would manufacture a duplicate that characters citing the old name keep
-- pointing away from:
--
--   book prints                catalog row                  decision
--   Lore: Monsters & Demons    Lore: Demons & Monsters      rename, cite the catalog
--   Language: American         Language: Native Tongue      rename (the Juicer sets this)
--   Literacy: American         Literacy: Native Language    rename
--   Math: Basic                Mathematics: Basic           rename
--
-- LORE: WORMWOOD'S BASE IS THE LOWEST GRANT, NOT THE FIRST ONE READ. Five
-- classes grant it and every one of them prints a different starting figure:
-- the monk 20% (p.62), the apok and the dark priest 25% (pp.57, 118), the
-- priest of light 35% (p.53) and the wormspeaker 40% (p.63). None of them
-- marks a bonus with a plus sign, so nothing on the page says which is the
-- base. The catalog holds the floor and each class file adds its own printed
-- figure on top, per the base-is-catalog-plus-bonus rule - so 20 here, and the
-- wormspeaker's file will say base: 40, not base: 20 with a bonus of 20.
--
-- The two languages follow Language: Other (50 / +5%), which is what every
-- named language in this catalog carries. The classes that grant them at 98%
-- state that in their own files.
--
-- systems is left NULL, matching all 333 existing rows: the column means
-- "restricted to", and nothing in the catalog is restricted today.

INSERT INTO skills (name, category, base, per_level, note, source, source_book) VALUES
('Lore: Wormwood', 'Technical', 20, 5,
 'The history, legends and world information of the living planet Wormwood: its geography, the Kingdom of Light, the Cathedral, the Forces of Darkness, symbiotic organisms, blood stones and magic crystals. Granted at 20% by the monk, 25% by the apok, 35% by the priest of light and 40% by the wormspeaker.',
 'import', 'Rifts Dimension Book 1: Wormwood p.53-63'),
('Language: Demongogian', 'Technical', 50, 5,
 'The tongue of the Forces of Darkness on Wormwood. The apok speaks it at 98%; the priest of light learns it at +20%.',
 'import', 'Rifts Dimension Book 1: Wormwood p.53-57'),
('Language: Gobblely', 'Technical', 50, 5,
 'The common trade tongue of goblins and lesser monster races. The apok speaks it at 98%.',
 'import', 'Rifts Dimension Book 1: Wormwood p.57')
ON CONFLICT(name) DO NOTHING;

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Lore: Wormwood', 'Language: Demongogian', 'Language: Gobblely')
 ORDER BY name;
SELECT COUNT(*) AS total_skills FROM skills;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-wormwood-skills.sql');
