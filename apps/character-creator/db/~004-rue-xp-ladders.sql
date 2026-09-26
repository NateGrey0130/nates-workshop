-- Experience ladders from Rifts Ultimate Edition's O.C.C. Experience Tables
-- (RUE printed 295, cache p298), for the classes whose own ladder the catalog
-- lacked, and for the five Rifts World Book 6: South America classes whose book
-- prints "same as" one of them.
--
-- One-off data script, run once per environment.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~004-rue-xp-ladders.sql
--
-- WHY. South America's Tribal Shaman ("same as the Mystic"), Werejaguar ("same
-- as the Psi-Stalker"), Grimbor ("same as the Vagabond") and Pogtalian Dragon
-- Slayer ("same as the dragon R.C.C.") had nothing to copy: none of those RUE
-- classes stored an xp_table, so all of them used the app's default ladder.
-- The Shaydor Spherian prints no ladder; its survey borrows the Mind Melter's.
-- RUE prints every one of these on one page, so the RUE classes get the
-- ladders they were always meant to have, and the South America classes copy
-- them. No live character held any of the RUE classes on 2026-09-25, so no
-- existing character's level moves.
--
-- READ OFF A RENDER. The RUE cache is an OCR scan and sets this page's columns
-- out of order under the wrong headings; every figure was read from a 110 dpi
-- render. Stored as each band's LOWER bound (0 first), as xp_table requires:
--   Burster, Psi-Stalker & Mystic: 0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501
--   City Rat & Vagabond: 0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501
--   Mind Melter, Ley Line Walker & Ley Line Rifter: 0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921
--   Dragon Hatchling & Adult Dragon: 0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001
--
-- The ladder pairs RUE prints together stay together: Burster/Psi-Stalker/
-- Mystic, City Rat/Vagabond, Mind Melter/Ley Line Walker/Ley Line Rifter, and
-- the Dragon Hatchling with its six variants. Mystic Russia's
-- russian-ley-line-walker is a declared copy_of the Ley Line Walker (except
-- magic), so it takes the same ladder - regression holds a copy pair equal.
--
-- MECHANICS. Each class's frontmatter gets one xp_table line after its single
-- "category:" line, guarded on the class having no xp_table, so a re-run does
-- nothing. The name sorts after every script that writes these classes; check
-- with the class-import sort command before renaming it.
--
-- RENAMED AFTER IT WAS FIRST APPLIED. It reached production as
-- zzzzzzzzzzzzzzzzzz-rue-xp-ladders.sql - an eighteenth z, a tier the
-- ordering table in docs/operations.md retires in favour of ~NNN-. So it also
-- repoints the South America notes that named the old file, and deletes the
-- old run record, which names a file the repo does not have (the
-- zzzz-cite-pf-rows.sql precedent).

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'burster' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'psi-stalker' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'mystic' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'city-rat' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'vagabond' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)), updated_at = datetime('now') WHERE class_id = 'mind-melter' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)), updated_at = datetime('now') WHERE class_id = 'ley-line-walker' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)), updated_at = datetime('now') WHERE class_id = 'ley-line-rifter' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)), updated_at = datetime('now') WHERE class_id = 'russian-ley-line-walker' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-cats-eye' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-flame-wind' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-forest-runner' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-royal-frilled' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-snow-lizard' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'dragon-hatchling-whip-tailed' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'tribal-shaman' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'werejaguar' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]' || char(10)), updated_at = datetime('now') WHERE class_id = 'grimbor' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17421, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)), updated_at = datetime('now') WHERE class_id = 'shaydor-spherian' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'pogtalian-dragon-slayer' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- The South America classes' notes, which said there was no ladder to copy.
UPDATE imported_classes SET markdown = replace(markdown, 'NO xp_table, so none is stored and the class uses the app''s default Rifts' || char(10) || '    handling, exactly as the Mystic does. Revisit if the Mystic ever gets one.', 'NO xp_table at import. ~004-rue-xp-ladders.sql then gave the' || char(10) || '    Mystic RUE''s Burster, Psi-Stalker & Mystic ladder (RUE printed 295), and' || char(10) || '    this class stores the same.'), updated_at = datetime('now') WHERE class_id = 'tribal-shaman' AND instr(markdown, 'NO xp_table, so none is stored and the class uses the app''s default Rifts' || char(10) || '    handling, exactly as the Mystic does. Revisit if the Mystic ever gets one.') > 0;
UPDATE imported_classes SET markdown = replace(markdown, '  - NO xp_table IS STORED. The experience tables', '  - THE VAGABOND''S LADDER IS STORED. The experience tables'), updated_at = datetime('now') WHERE class_id = 'grimbor' AND instr(markdown, '  - NO xp_table IS STORED. The experience tables') > 0;
UPDATE imported_classes SET markdown = replace(markdown, 'xp_table, so there is nothing to copy. Checked 2026-09-25.', 'xp_table at import; ~004-rue-xp-ladders.sql then gave both' || char(10) || '    RUE''s City Rat & Vagabond ladder (RUE printed 295).'), updated_at = datetime('now') WHERE class_id = 'grimbor' AND instr(markdown, 'xp_table, so there is nothing to copy. Checked 2026-09-25.') > 0;
UPDATE imported_classes SET markdown = replace(markdown, 'xp_table in production (checked --remote 2026-09-25), so none is stored.', 'xp_table at import; ~004-rue-xp-ladders.sql then gave both' || char(10) || '    RUE''s Mind Melter, Ley Line Walker & Ley Line Rifter ladder (printed 295).'), updated_at = datetime('now') WHERE class_id = 'shaydor-spherian' AND instr(markdown, 'xp_table in production (checked --remote 2026-09-25), so none is stored.') > 0;
UPDATE imported_classes SET markdown = replace(markdown, 'chiang-ku-dragon, dragon-ray) stores an xp_table, so none is stored here.', 'chiang-ku-dragon, dragon-ray) stored an xp_table at import;' || char(10) || '    ~004-rue-xp-ladders.sql then gave the hatchlings and this' || char(10) || '    class RUE''s Dragon Hatchling & Adult Dragon ladder (RUE printed 295).'), updated_at = datetime('now') WHERE class_id = 'pogtalian-dragon-slayer' AND instr(markdown, 'chiang-ku-dragon, dragon-ray) stores an xp_table, so none is stored here.') > 0;
UPDATE imported_classes SET markdown = replace(markdown, 'psi-stalker in production stores no xp_table, so none is stored here.', 'psi-stalker stored no xp_table at import; ~004-rue-xp-ladders.sql then gave both RUE''s Burster, Psi-Stalker & Mystic ladder (RUE printed 295).'), updated_at = datetime('now') WHERE class_id = 'werejaguar' AND instr(markdown, 'psi-stalker in production stores no xp_table, so none is stored here.') > 0;

-- Where the first run already wrote those notes, they name the old file.
UPDATE imported_classes SET markdown = replace(markdown, 'zzzzzzzzzzzzzzzzzz-rue-xp-ladders.sql', '~004-rue-xp-ladders.sql'), updated_at = datetime('now') WHERE class_id IN ('tribal-shaman', 'werejaguar', 'grimbor', 'shaydor-spherian', 'pogtalian-dragon-slayer') AND instr(markdown, 'zzzzzzzzzzzzzzzzzz-rue-xp-ladders.sql') > 0;

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 21 classes now carry a ladder' AS assertion, count(*) AS got, 21 AS want
  FROM imported_classes WHERE class_id IN ('burster', 'psi-stalker', 'mystic', 'city-rat', 'vagabond', 'mind-melter', 'ley-line-walker', 'ley-line-rifter', 'russian-ley-line-walker', 'dragon-hatchling', 'dragon-hatchling-cats-eye', 'dragon-hatchling-flame-wind', 'dragon-hatchling-forest-runner', 'dragon-hatchling-royal-frilled', 'dragon-hatchling-snow-lizard', 'dragon-hatchling-whip-tailed', 'tribal-shaman', 'werejaguar', 'grimbor', 'shaydor-spherian', 'pogtalian-dragon-slayer') AND instr(markdown, 'xp_table:') > 0;
SELECT 'the Mystic ladder on its 5 classes' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes WHERE class_id IN ('burster', 'psi-stalker', 'mystic', 'tribal-shaman', 'werejaguar') AND instr(markdown, 'xp_table: [0, 2051, 4101,') > 0;
SELECT 'the Vagabond ladder on its 3' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes WHERE class_id IN ('city-rat', 'vagabond', 'grimbor') AND instr(markdown, 'xp_table: [0, 1876, 3751,') > 0;
SELECT 'the Mind Melter ladder on its 5' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes WHERE class_id IN ('mind-melter', 'ley-line-walker', 'ley-line-rifter', 'russian-ley-line-walker', 'shaydor-spherian') AND instr(markdown, 'xp_table: [0, 2241, 4481,') > 0;
SELECT 'the dragon ladder on its 8' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes WHERE class_id IN ('dragon-hatchling', 'dragon-hatchling-cats-eye', 'dragon-hatchling-flame-wind', 'dragon-hatchling-forest-runner', 'dragon-hatchling-royal-frilled', 'dragon-hatchling-snow-lizard', 'dragon-hatchling-whip-tailed', 'pogtalian-dragon-slayer') AND instr(markdown, 'xp_table: [0, 3001, 5001,') > 0;
SELECT 'no South America note still says there was nothing to copy' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id IN ('tribal-shaman', 'werejaguar', 'grimbor', 'shaydor-spherian', 'pogtalian-dragon-slayer')
   AND (instr(markdown, 'so none is stored') > 0 OR instr(markdown, 'nothing to copy') > 0 OR instr(markdown, 'NO xp_table IS STORED') > 0);
SELECT 'and no note names the old file' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE instr(markdown, 'zzzzzzzzzzzzzzzzzz-rue-xp-ladders.sql') > 0;

DELETE FROM data_script_runs WHERE filename = 'zzzzzzzzzzzzzzzzzz-rue-xp-ladders.sql';
INSERT INTO data_script_runs (filename) VALUES ('~004-rue-xp-ladders.sql');
