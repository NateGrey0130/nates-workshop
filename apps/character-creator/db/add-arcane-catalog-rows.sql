-- Two skills and one spell the Palladium Fantasy practitioners of magic need.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-arcane-catalog-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-arcane-catalog-rows.sql
--
-- Prerequisite for add-wizard-class.sql, add-summoner-class.sql and
-- add-diabolist-class.sql.
--
-- THE FILENAME SORTS BEFORE ALL THREE ON PURPOSE. A clean rebuild applies this
-- directory as one sorted glob, and 'add-arcane-...' lands ahead of
-- 'add-diabolist-...', 'add-summoner-...' and 'add-wizard-...'. Same discipline
-- as add-hard-leather-gear.sql, and for the same reason: a class that goes in
-- citing a row created two files later reads fine by hand and wrong in a
-- rebuild.
--
-- ---- 1. Recognize Magic (Wizard, Diabolist) --------------------------------
-- Printed p107 for the wizard and p119 for the diabolist, identically: "Base
-- Skill: 20% +5% per level of experience." The catalog already holds Recognize
-- Enchantment, Recognize Authenticity, Recognize Machine Quality and Recognize
-- Wards, Runes & Circles - this is the fifth of that family and the only one
-- two classes were asking for.
--
-- No `systems` column: skills are cross-system on purpose. See
-- untag-cross-system.sql.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Recognize Magic', 'Technical', 20, 5, 'import', 'palladium-fantasy-core',
        'Recognises that an item is magical by shape, inscription, magic symbols or intuition - not what it does or how to use it.');

-- ---- 2. History (Summoner) -------------------------------------------------
-- Printed p58: "Base Skill: 30% +5% per level of experience." Basic historical
-- knowledge of the known world, weighted to humans, dwarves, elves and three
-- races of choice, plus the Tristine Chronicles.
--
-- NOT a duplicate of History: Pre-Rifts or History: Post-Apocalypse, which are
-- the two Rifts rows and are about a different world's history. The plain name
-- was free.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('History', 'Technical', 30, 5, 'import', 'palladium-fantasy-core',
        'The known world with an emphasis on humans, dwarves, elves and three racial groups of choice, plus the Tristine Chronicles. May be taken twice; the second time adds six more races.');

-- ---- 3. Decipher Magic (Wizard) --------------------------------------------
-- One of the wizard's six common knowledge spells, and the only one of the six
-- the catalog did not already hold. Printed p187 in the level-one invocation
-- list and p189 in full.
--
-- system stays NULL - unrestricted - which is how the other 127 untagged spells
-- read and what the pickers already expect. A first-level invocation is not
-- bound to the book it was first printed in any more than a skill is.
INSERT OR IGNORE INTO spells
  (name, level, ppe, range, duration, saving_throw, system, source_book, source, description)
VALUES ('Decipher Magic', 1, 4, 'Self',
        'Two minutes (8 melee rounds) per level of experience', 'None', NULL,
        'palladium-fantasy-core', 'import',
        'Read any magic scroll, inscription, text or book that uses magic symbols or runes, at 94% proficiency, for the duration only. Does not interpret other languages and their alphabets, does not decipher magic circles beyond the symbols used in them, and does not identify or decipher wards.');

-- ---- read the result back rather than trusting the exit code ---------------
SELECT name, category, base, per_level, systems FROM skills
 WHERE name IN ('Recognize Magic', 'History') ORDER BY name;
SELECT name, level, ppe, system FROM spells WHERE name = 'Decipher Magic';
-- Expect 0: no new row is a stub, and neither skill is tagged to one system.
SELECT count(*) AS bad_rows FROM skills
 WHERE name IN ('Recognize Magic', 'History') AND (base = 0 OR systems IS NOT NULL);

INSERT INTO data_script_runs (filename) VALUES ('add-arcane-catalog-rows.sql');
